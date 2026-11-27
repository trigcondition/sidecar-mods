#!/usr/bin/env python3
"""One asset folder for the GitHub release, from the OS folder(s) `make release` / `make release-all` write.

    python3 tools/combine_release.py build/release/0.4.0 build/release/0.4.0-os1.74 build/release/0.4.0-assets --os-b 1.74
    python3 tools/combine_release.py build/release/0.5.2-os1.74 build/release/0.5.2-assets --os-a 1.74    (one OS)

`make release-assets` runs it. With one OS folder (a release that builds one OS, 0.5.x: 1.74) the asset folder is that
folder's files, checked as below, with one TOOLCHAIN.txt and one new SHA256SUMS; the file names are the OS's own, so
they are unique already. With two folders each OS folder holds its two .elemod files, its core's source archive, the builder's
source archive, LICENSE, NOTICE, TOOLCHAIN.txt and SHA256SUMS. The combined folder takes all of the first folder,
the second folder's own files, the second folder's TOOLCHAIN.txt as TOOLCHAIN-os<OS>.txt, and one new SHA256SUMS
over every file. It refuses (exit status 1, nothing written) when:

- a folder's SHA256SUMS does not list exactly its files with their hashes (a stale or hand-edited folder);
- a file is not one a release holds (only .elemod, .tar.gz, LICENSE, NOTICE, TOOLCHAIN*.txt, SHA256SUMS; never a .syx);
- LICENSE, NOTICE or the builder's archive is missing from a folder, or a file both folders hold differs between them;
- a TOOLCHAIN.txt does not name its OS, or says "(uncommitted changes)";
- the two TOOLCHAIN.txt do not name the same sidecar-mods commit, or it is not the checkout's `git rev-parse HEAD`
  (override with --expect-commit);
- a folder does not hold exactly the expected set (the core and the bundle .elemod, the core's and the builder's
  source archive, LICENSE, NOTICE, TOOLCHAIN.txt, SHA256SUMS), or the combined set is not the eleven files plus SHA256SUMS;
- the output folder exists and is not empty.

(One OS: the same checks for the one folder; the combined set is its eight files with SHA256SUMS: seven plus it.)
"""
import argparse
import hashlib
import os
import re
import shutil
import subprocess
import sys

SHARED = ("LICENSE", "NOTICE")
BUILDER = re.compile(r"^elekloader-[0-9a-f]{7}-src\.tar\.gz$")
ALLOWED = re.compile(r"^(.+\.elemod|.+\.tar\.gz|LICENSE|NOTICE|TOOLCHAIN(-os[0-9.]+)?\.txt|SHA256SUMS)$")


CORE_ELEMOD = re.compile(r"^core-.+\.elemod$")
BUNDLE_ELEMOD = re.compile(r"^rytm-sidecar-.+\.elemod$")
CORE_SRC = re.compile(r"^elekloader-[0-9a-f]{7}-core-ar2-src\.tar\.gz$")
FIXED = ("LICENSE", "NOTICE", "TOOLCHAIN.txt", "SHA256SUMS")
BUILT_FROM = re.compile(r"built from sidecar-mods ([0-9a-f]{40})\b")


class Refused(Exception):
    pass


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for block in iter(lambda: fh.read(1 << 20), b""):
            h.update(block)
    return h.hexdigest()


def read_folder(d):
    """The folder's files (name -> sha256), checked against its SHA256SUMS."""
    if not os.path.isdir(d):
        raise Refused(f"{d}: not a folder")
    names = sorted(os.listdir(d))
    for n in names:
        if not os.path.isfile(os.path.join(d, n)) or not ALLOWED.match(n):
            raise Refused(f"{d}: {n} is not a release file")
    if "SHA256SUMS" not in names:
        raise Refused(f"{d}: no SHA256SUMS")
    files = {n: sha256(os.path.join(d, n)) for n in names if n != "SHA256SUMS"}
    listed = {}
    with open(os.path.join(d, "SHA256SUMS")) as fh:
        for line in fh:
            if line.strip():
                digest, name = line.rstrip("\n").split(None, 1)
                listed[name.lstrip("*")] = digest.lower()
    if listed != files:
        raise Refused(f"{d}: SHA256SUMS does not match the folder "
                      f"(listed only: {sorted(set(listed) - set(files))}, "
                      f"not listed: {sorted(set(files) - set(listed))}, "
                      f"hash differs: {sorted(n for n in set(files) & set(listed) if files[n] != listed[n])})")
    for n in SHARED:
        if n not in files:
            raise Refused(f"{d}: no {n}")
    if not any(BUILDER.match(n) for n in files):
        raise Refused(f"{d}: no builder source archive (elekloader-<commit>-src.tar.gz)")
    if "TOOLCHAIN.txt" not in files:
        raise Refused(f"{d}: no TOOLCHAIN.txt")
    return files


def check_set(d, names):
    """Exactly: one core .elemod, one bundle .elemod, one core source archive, one builder archive, and the four fixed."""
    want = {"core elemod": CORE_ELEMOD, "bundle elemod": BUNDLE_ELEMOD, "core source archive": CORE_SRC,
            "builder source archive": BUILDER}
    left = [n for n in names if n not in FIXED]
    for what, rx in want.items():
        hit = [n for n in left if rx.match(n)]
        if len(hit) != 1:
            raise Refused(f"{d}: expected exactly one {what}, found {hit}")
        left.remove(hit[0])
    if left:
        raise Refused(f"{d}: unexpected files {left}")
    missing = [n for n in FIXED if n not in names]
    if missing:
        raise Refused(f"{d}: missing {missing}")


def toolchain_commit(d):
    with open(os.path.join(d, "TOOLCHAIN.txt"), errors="replace") as fh:
        m = BUILT_FROM.search(fh.read())
    if not m:
        raise Refused(f"{d}/TOOLCHAIN.txt: no \"built from sidecar-mods <40-hex commit>\"")
    return m.group(1)


def head_commit():
    here = os.path.dirname(os.path.abspath(__file__))
    try:
        return subprocess.check_output(["git", "-C", here, "rev-parse", "HEAD"], text=True).strip()
    except (OSError, subprocess.CalledProcessError):
        raise Refused("cannot read git rev-parse HEAD (pass --expect-commit)")


def check_toolchain(d, os_name):
    with open(os.path.join(d, "TOOLCHAIN.txt"), errors="replace") as fh:
        text = fh.read()
    first = text.splitlines()[0] if text else ""
    if f"for OS {os_name}," not in first:
        raise Refused(f"{d}/TOOLCHAIN.txt: its first line does not say \"for OS {os_name},\"")
    if "(uncommitted changes)" in text:
        raise Refused(f"{d}/TOOLCHAIN.txt: built from uncommitted changes")


def check_folder(d, files, os_name):
    """One OS folder: exactly its set, its TOOLCHAIN.txt naming the OS and the checkout's commit, built from a clean
    tree. Returns the commit its TOOLCHAIN.txt names."""
    check_set(d, sorted(files) + ["SHA256SUMS"])
    check_toolchain(d, os_name)
    return toolchain_commit(d)


def check_out(out):
    if os.path.exists(out) and (not os.path.isdir(out) or os.listdir(out)):
        raise Refused(f"{out}: exists and is not an empty folder")


def write_out(plan, out):
    os.makedirs(out, exist_ok=True)
    for n, src in sorted(plan.items()):
        shutil.copyfile(src, os.path.join(out, n))
    sums = "".join(f"{sha256(os.path.join(out, n))}  {n}\n" for n in sorted(plan))
    with open(os.path.join(out, "SHA256SUMS"), "w") as fh:
        fh.write(sums)
    return sums


def combine_one(a, out, os_a, expect_commit=None):
    """A release that builds one OS: its folder's files, one TOOLCHAIN.txt, one new SHA256SUMS."""
    fa = read_folder(a)
    ca = check_folder(a, fa, os_a)
    expect = expect_commit or head_commit()
    if ca != expect:
        raise Refused(f"the folder was built from sidecar-mods {ca[:10]}, the checkout is at {expect[:10]}")
    check_out(out)
    plan = {n: os.path.join(a, n) for n in fa}
    if len(plan) != 7:
        raise Refused(f"the asset set would hold {len(plan)} files besides SHA256SUMS, not 7: {sorted(plan)}")
    return write_out(plan, out)


def combine(a, b, out, os_a, os_b, expect_commit=None):
    fa, fb = read_folder(a), read_folder(b)
    ca = check_folder(a, fa, os_a)
    cb = check_folder(b, fb, os_b)
    if ca != cb:
        raise Refused(f"the two folders were built from different sidecar-mods commits ({ca[:10]} vs {cb[:10]})")
    expect = expect_commit or head_commit()
    if ca != expect:
        raise Refused(f"the folders were built from sidecar-mods {ca[:10]}, the checkout is at {expect[:10]}")
    for n in sorted(set(fa) & set(fb) - {"TOOLCHAIN.txt"}):
        if fa[n] != fb[n]:
            raise Refused(f"{n} differs between {a} and {b}")
    for n in SHARED:
        if n not in fb:
            raise Refused(f"{b}: no {n}")
    if not any(BUILDER.match(n) and n in fa for n in fb):
        raise Refused(f"no builder source archive common to {a} and {b}")
    check_out(out)
    plan = {n: os.path.join(a, n) for n in fa}
    plan.update({n: os.path.join(b, n) for n in fb if n not in fa})
    plan[f"TOOLCHAIN-os{os_b}.txt"] = os.path.join(b, "TOOLCHAIN.txt")
    if len(plan) != 11:
        raise Refused(f"the combined set would hold {len(plan)} files besides SHA256SUMS, not 11: {sorted(plan)}")
    return write_out(plan, out)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("paths", nargs="+", metavar="FOLDER",
                    help="the OS folder(s) then the combined folder: first [second] out (must not exist, or be empty)")
    ap.add_argument("--os-a", default="1.73", help="the first folder's OS (default 1.73; its TOOLCHAIN.txt keeps its name)")
    ap.add_argument("--os-b", default="1.74", help="the second folder's OS (default 1.74)")
    ap.add_argument("--expect-commit", help="the sidecar-mods commit the folders must name (default: git rev-parse HEAD)")
    args = ap.parse_args(argv)
    if len(args.paths) not in (2, 3):
        ap.error("give one OS folder and the output folder, or two OS folders and the output folder")
    try:
        if len(args.paths) == 2:
            sums = combine_one(args.paths[0], args.paths[1], args.os_a, args.expect_commit)
        else:
            sums = combine(*args.paths, args.os_a, args.os_b, args.expect_commit)
    except Refused as e:
        print("NOT COMBINED: " + str(e), file=sys.stderr)
        return 1
    sys.stdout.write(sums)
    print(f"{len(sums.splitlines()) + 1} files in {args.paths[-1]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
