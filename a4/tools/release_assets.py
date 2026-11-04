#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""The check on an a4-v... release: only .elemod files and their papers leave, never a .syx.

    a4/tools/release_assets.py DIR --tag a4-v0.9 [--refused FILE]

A built .syx holds Elektron's firmware, so a file is judged by what it is, not only by its name. Every file in DIR must be
one of the names below and hold what that name promises:

  sidecar-a4-<version>.elemod   JSON with the elemod key, device analog-four-mk2, <version> as the tag's
  core-<version>.elemod         the same, id core
  a4156.lock.json               JSON with elekloader_store, device analog-four-mk2
  elekloader-<rev>-src.tar.gz   no member with a firmware name, no member with a firmware header
  LICENSE NOTICE TOOLCHAIN.txt  text
  SHA256SUMS                    names every other file, and each hash is right

and none may hold an Elektron SysEx message, the ELE3 container's mark, or a local path. An elemod's sections may only be
hex of our own code and ["stock", address, length] references. Exit status 1 on any refusal; --refused writes the refused
files' names, one a line.
"""
import argparse
import hashlib
import io
import json
import os
import re
import sys
import tarfile

SYSEX = re.compile(rb"\xf0\x00\x20\x3c[\x00-\x7f]{16}")   # an Elektron SysEx message's start, as the pre-push hook's
ELE3 = b"ELE3"
PATHS = re.compile(rb"/(?:Users|home|private|var/folders)/[^\s\"'<>]+")
FIRMWARE_NAME = re.compile(r"\.(syx|bin|img|hex|snap|dump|dis|elf)$", re.I)
MAX_ELEMOD = 1 << 20      # a real one is under 100 KB; an OS image is well over a megabyte
ELEMOD = re.compile(r"^(sidecar-a4|core)-(\d+\.\d+)\.elemod$")
PAPERS = ("LICENSE", "NOTICE", "TOOLCHAIN.txt")
SRC_TAR = re.compile(r"^elekloader-[0-9a-f]{7,40}-src\.tar\.gz$")


def bytes_problem(data):
    if SYSEX.search(data):
        return "holds an Elektron SysEx message"
    if ELE3 in data:
        return "holds an ELE3 container mark"
    return None


def check_elemod(name, data, version):
    if len(data) > MAX_ELEMOD:
        return f"{len(data)} bytes: too big for an .elemod"
    try:
        doc = json.loads(data)
    except ValueError:
        return "not JSON: not an .elemod"
    if not isinstance(doc, dict) or "elemod" not in doc or doc.get("target", {}).get("device") != "analog-four-mk2":
        return "not an .elemod for the analog-four-mk2"
    want, ver = ELEMOD.match(name).groups()
    if doc.get("id") != want or doc.get("version") != ver:
        return f"says {doc.get('id')} {doc.get('version')}, its name says {want} {ver}"
    if want == "sidecar-a4" and ver != version:
        return f"version {ver}, the tag says {version}"
    for sec in doc.get("sections", {}).values():
        for part in sec.get("parts", []):
            if part[0] not in ("hex", "stock"):
                return f"a section part of kind {part[0]!r}"
    if doc.get("sites") and any("stock" in s for s in doc["sites"]):
        return "a site carries stock bytes instead of their hash"
    return None


def check_tar(data):
    try:
        with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as t:
            for m in t:
                if FIRMWARE_NAME.search(m.name) or m.name.lower().endswith(".elemod"):
                    return f"member {m.name}: firmware file type"
                if m.isfile():
                    p = bytes_problem(t.extractfile(m).read().replace(ELE3, b""))   # source may name the mark
                    if p:
                        return f"member {m.name}: {p}"
    except (tarfile.TarError, OSError, EOFError) as e:
        return f"not a .tar.gz ({e})"
    return None


def check_sums(data, files):
    """-> a problem with SHA256SUMS, against {name: bytes} of the other files."""
    listed = {}
    for line in data.decode("ascii", "replace").splitlines():
        m = re.match(r"^([0-9a-f]{64})\s+\*?(\S+)$", line)
        if not m:
            return f"a line that is no hash and name: {line[:60]!r}"
        listed[m.group(2)] = m.group(1)
    if set(listed) != set(files):
        return f"lists {sorted(set(listed) ^ set(files))} differently from the folder"
    for n, h in listed.items():
        if hashlib.sha256(files[n]).hexdigest() != h:
            return f"{n}: wrong hash"
    return None


def check_file(name, data, version, others):
    if FIRMWARE_NAME.search(name):
        return "firmware file type"
    if SRC_TAR.match(name):
        return check_tar(data)
    p = bytes_problem(data)
    if p:
        return p
    m = PATHS.search(data)
    if m:
        return f"holds a local path {m.group(0)[:40].decode(errors='replace')}"
    if ELEMOD.match(name):
        return check_elemod(name, data, version)
    if name == "a4156.lock.json":
        try:
            doc = json.loads(data)
        except ValueError:
            return "not JSON"
        return None if "elekloader_store" in doc and doc.get("device") == "analog-four-mk2" else "not the store's lock file"
    if name in PAPERS:
        return None if b"\0" not in data and len(data) < 1 << 20 else "not a text file"
    if name == "SHA256SUMS":
        return check_sums(data, others)
    return "not a name an a4 release may hold"


PACK_MARK = ".sidecar-release-out"


def check_dir(path, tag):
    """-> {refused name: why}; a problem with the release as a whole is under ''."""
    refused = {}
    m = re.match(r"^a4-v(\d+\.\d+)$", tag)
    if not m:
        return {"": f"tag {tag}: an a4 release's tag is a4-v<mod version>"}
    names = sorted(n for n in os.listdir(path) if n != PACK_MARK)  # pack_release.sh's marker
    files = {}
    for n in names:
        p = os.path.join(path, n)
        if not os.path.isfile(p) or os.path.islink(p):
            refused[n] = "not a plain file"
            continue
        with open(p, "rb") as fh:
            files[n] = fh.read()
    others = {n: d for n, d in files.items() if n != "SHA256SUMS"}
    for n, d in files.items():
        why = check_file(n, d, m.group(1), others)
        if why:
            refused[n] = why
    kinds = [ELEMOD.match(n).group(1) for n in names if ELEMOD.match(n)]
    if sorted(kinds) != ["core", "sidecar-a4"]:
        refused[""] = "a release needs one sidecar-a4 and one core .elemod"
    elif "SHA256SUMS" not in files:
        refused[""] = "no SHA256SUMS"
    return refused


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("dir")
    ap.add_argument("--tag", required=True)
    ap.add_argument("--refused", help="write the refused files' names here, one a line")
    a = ap.parse_args()
    refused = check_dir(a.dir, a.tag)
    for n, why in sorted(refused.items()):
        print(f"REFUSED {n or a.dir}: {why}", file=sys.stderr)
    if a.refused:
        with open(a.refused, "w") as fh:
            fh.writelines(n + "\n" for n in sorted(refused) if n)
    if refused:
        return 1
    print(f"{a.tag}: {len([n for n in os.listdir(a.dir) if n != PACK_MARK])} files, nothing refused")
    return 0


if __name__ == "__main__":
    sys.exit(main())
