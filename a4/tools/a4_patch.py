#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""Make the patcher's file for one A4 build: the mods as address+bytes records against the decoded stock MAIN OS, with no
Elektron bytes in it. The docs site's scripts/make_patches.py runs this; the web patcher and sidecar_patch.py apply it to
the user's own stock OS 1.56 .syx and check the result is byte for byte the build that was tested.

This tool reads the two .syx files only (stock and our build) and decodes them with elekloader's codec, the reference:

- `w` records [offset, hex]: bytes our build changed (the mod's code, its sites, elekloader's core and boot copier);
- `c` records [offset, src, len] or [offset, src, len, section]: a span of our image that equals a span of a decoded stock
  section (MAIN OS unless named). The patcher copies it from the user's own stock file, so the patch never carries it.

No checksum, header, table or framing byte is stored. The tool refuses unless (a) the records, elekloader's packer and
writer reproduce our .syx byte for byte, and (b) no literal holds 4 consecutive bytes of any decoded stock section.

    a4/tools/a4_patch.py --tag a4-sa09 --dir BUILD --commit <sidecar-mods commit> --elekloader DIR -o OUT.json

--dir holds Analog-Four_MKII_OS1.56.syx and our Analog-Four_MKII_OS1.56_<tag>.syx. Neither ever goes into a repository.
"""
import argparse
import hashlib
import json
import struct
import sys
from pathlib import Path

STOCK_NAME = "Analog-Four_MKII_OS1.56.syx"
STOCK_SHA = "5aea489db3e747547f71d5e08a2d20253149fe6258defad60306402d2fc23cb5"
MIN_COPY = 4          # a literal never holds this many consecutive stock bytes
MAIN = 3              # the A4's MAIN OS section
VERSION_AT = 0x14     # the ELE3 header's 4-character version field
FORMAT = "sidecar-rytm-patch"


def sha(b):
    return hashlib.sha256(b).hexdigest()


def grams(data, n=MIN_COPY):
    """-> the set of every n-byte window of data, as ints."""
    v = int.from_bytes
    return {v(data[i:i + n], "big") for i in range(len(data) - n + 1)}


def longest_in(hay, buf, i, end, gset):
    """-> (pos, length) of the longest buf[i:j] (j <= end, length >= MIN_COPY) found in hay."""
    if end - i < MIN_COPY or int.from_bytes(buf[i:i + MIN_COPY], "big") not in gset:
        return None
    pos = hay.find(buf[i:i + MIN_COPY])
    if pos < 0:
        return None
    lo, hi = MIN_COPY, MIN_COPY
    while hi < end - i:                       # grow until it is no longer found
        nxt = min(hi * 2, end - i)
        if hay.find(buf[i:i + nxt]) < 0:
            break
        lo = hi = nxt
    else:
        return hay.find(buf[i:i + hi]), hi
    top = min(hi * 2, end - i)                # lo found, top not: binary search
    while top - lo > 1:
        mid = (lo + top) // 2
        if hay.find(buf[i:i + mid]) >= 0:
            lo = mid
        else:
            top = mid
    return hay.find(buf[i:i + lo]), lo


def make_ops(stock, img, others):
    """others: {section id: decoded bytes} of the other stock sections, also copy sources."""
    base = stock + bytes(max(0, len(img) - len(stock)))
    if len(img) < len(stock):
        raise SystemExit("the built MAIN OS is shorter than stock; not supported")
    hays = [(MAIN, stock, grams(stock))] + [(sid, b, grams(b)) for sid, b in sorted(others.items())]
    ops, i, n = [], 0, len(img)
    while i < n:
        if img[i] == base[i]:
            i += 1
            continue
        end = i
        while end < n and img[end] != base[end]:
            end += 1
        lit_at, lit = i, bytearray()
        while i < end:
            m, sid = None, MAIN
            for hid, hay, gset in hays:
                h = longest_in(hay, img, i, end, gset)
                if h and (m is None or h[1] > m[1]):
                    m, sid = h, hid
            if m:
                if lit:
                    ops.append([lit_at, lit.hex()])
                ops.append([i, m[0], m[1]] + ([] if sid == MAIN else [sid]))
                i += m[1]
                lit_at, lit = i, bytearray()
            else:
                lit.append(img[i])
                i += 1
        if lit:
            ops.append([lit_at, lit.hex()])
    return ops


def apply_ops(stock, ops, out_len, others):
    img = bytearray(stock) + bytearray(out_len - len(stock))
    for op in ops:
        if len(op) == 2:
            b = bytes.fromhex(op[1])
            img[op[0]:op[0] + len(b)] = b
        else:
            src = stock if len(op) == 3 else others[op[3]]
            img[op[0]:op[0] + op[2]] = src[op[1]:op[1] + op[2]]
    return bytes(img)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--tag", required=True, help="the build tag, e.g. a4-sa09")
    ap.add_argument("--dir", required=True, help="folder with %s and our <stock name>_<tag>.syx" % STOCK_NAME)
    ap.add_argument("--stock", help="the stock .syx (default: <dir>/%s)" % STOCK_NAME)
    ap.add_argument("--built", help="our .syx (default: <dir>/Analog-Four_MKII_OS1.56_<tag>.syx)")
    ap.add_argument("--commit", default="", help="the sidecar-mods commit the build came from")
    ap.add_argument("--title", default="", help="one line for the patcher to show")
    ap.add_argument("--description", default="", help="a sentence for the patcher to show")
    ap.add_argument("--elekloader", required=True, help="an elekloader checkout at c150ac5")
    ap.add_argument("-o", "--out", required=True)
    a = ap.parse_args()

    sys.path.insert(0, a.elekloader)
    from elekloader import syx as esyx            # the reference decoder, packer and writer
    from elekloader.devices import analog_four_mk2 as prof

    d = Path(a.dir)
    stock_p = Path(a.stock) if a.stock else d / STOCK_NAME
    built_p = Path(a.built) if a.built else d / f"Analog-Four_MKII_OS1.56_{a.tag}.syx"
    stock_raw, built_raw = stock_p.read_bytes(), built_p.read_bytes()
    if sha(stock_raw) != STOCK_SHA:
        raise SystemExit(f"{stock_p.name}: not the stock OS 1.56 file ({sha(stock_raw)})")
    st, bu = esyx.Syx(stock_raw), esyx.Syx(built_raw)
    if bu.device_id != st.device_id or [t[0] for t in bu.table] != [t[0] for t in st.table]:
        raise SystemExit("the build's container does not have stock's sections")
    for sid in st.stored:
        if sid != MAIN and bu.stored[sid] != st.stored[sid]:
            raise SystemExit(f"section {sid} differs from stock: only MAIN OS may change")
    hd = [i for i in range(len(st.header)) if st.header[i] != bu.header[i]]
    if any(not VERSION_AT <= i < VERSION_AT + 4 for i in hd):
        raise SystemExit(f"the ELE3 header differs outside the version field: {hd}")
    version = bu.header[VERSION_AT:VERSION_AT + 4].decode("ascii")

    stock_img, img = st.section(MAIN), bu.section(MAIN)
    others = {sid: st.section(sid) for sid in st.stored if sid != MAIN}
    ops = make_ops(stock_img, img, others)

    # (a) the records, our packer and writer reproduce our build byte for byte
    again = apply_ops(stock_img, ops, len(img), others)
    if again != img:
        raise SystemExit("internal: the records do not rebuild the image")
    out = esyx.write(st, esyx.pack_main(again), prof.DEVICE, version)
    if out != built_raw:
        raise SystemExit("re-encoding the image does not give the built .syx byte for byte")

    # (b) no literal carries MIN_COPY consecutive bytes of any stock section
    allg = grams(stock_img)
    for b in others.values():
        allg |= grams(b)
    leaks = []
    for op in ops:
        if len(op) == 2:
            b = bytes.fromhex(op[1])
            for k in range(len(b) - MIN_COPY + 1):
                if int.from_bytes(b[k:k + MIN_COPY], "big") in allg:
                    leaks.append((op[0] + k, b[k:k + MIN_COPY].hex()))
    if leaks:
        raise SystemExit(f"{len(leaks)} literal windows occur in stock (first {leaks[:5]})")

    lit = sum(len(op[1]) // 2 for op in ops if len(op) == 2)
    cop = sum(op[2] for op in ops if len(op) >= 3)
    doc = {
        "format": FORMAT,
        "format_version": 1,
        "tag": a.tag,
        "title": a.title or f"Sidecar mods {a.tag}",
        "description": a.description,
        "source_commit": a.commit,
        "device": "Analog Four MKII",
        "min_copy": MIN_COPY,
        "stock": {"name": STOCK_NAME, "os": "1.56", "syx_sha256": STOCK_SHA, "syx_len": len(stock_raw),
                  "main_section": MAIN, "main_len": len(stock_img), "main_sha256": sha(stock_img)},
        "output": {"name": built_p.name, "version": version, "main_len": len(img),
                   "main_sha256": sha(img), "syx_len": len(built_raw), "syx_sha256": sha(built_raw)},
        "stats": {"records": len(ops), "literal_bytes": lit, "copied_bytes": cop},
        "ops": ops,
    }
    Path(a.out).parent.mkdir(parents=True, exist_ok=True)
    with open(a.out, "w") as fh:
        json.dump(doc, fh, separators=(",", ":"))
        fh.write("\n")
    print(f"{a.out}: {len(ops)} records, {lit} literal + {cop} copied bytes; "
          f"output {built_p.name} sha256 {sha(built_raw)[:16]}..; no stock windows in literals")


if __name__ == "__main__":
    main()
