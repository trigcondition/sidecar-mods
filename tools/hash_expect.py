#!/usr/bin/env python3
"""tools/hash_expect.py - keep stock bytes out of registry/allocations.toml.

    python3 tools/hash_expect.py [--check] [--image build/stock_mainos.bin]

A claim's `expect` (the stock bytes at a patch or detour host, the build's load-bearing guard) is firmware data, so
the registry stores it as `expect_len` + `expect_sha256` instead; build.py and verify.py read the bytes from your own
stock image and check them against the hash (layout.resolve_expect), exactly as they checked the hex before.

Write a new claim with `expect = "<hex>"` while you work on it, then run this to turn every such line into
`expect_len` / `expect_sha256` (a guard's `replace`, which equals its `expect`, is dropped: the build fills it in).
With --image (the stock MAIN OS that `make build` extracts), a patch's `replace` that is an exact copy of stock bytes
elsewhere (8 bytes or more: a copied parameter record, say) becomes `replace_from = <that address>`, which the build
reads from the same image.
--check: exit 1 if the registry still holds an `expect` (or a guard's `replace`, or with --image a copied `replace`)
as hex.
"""
import hashlib
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REG = ROOT / "registry" / "allocations.toml"
EXPECT = re.compile(r'^(\s*)expect(\s*)=(\s*)"([0-9a-fA-F]*)"(.*)$')
REPLACE = re.compile(r'^\s*replace\s*=\s*"([0-9a-fA-F]*)"')
REPLACE_LINE = re.compile(r'^(\s*)replace(\s*)=(\s*)"([0-9a-fA-F]*)"(.*)$')
BASE = 0x40000400   # MAIN OS load address (re/symbols.toml [meta] base)


def convert(text: str, image: bytes | None = None) -> tuple[str, int]:
    out, n = [], 0
    tables, cur = [], None
    for line in text.splitlines(keepends=True):
        if line.lstrip().startswith("[["):
            cur = []
            tables.append(cur)
        (cur if cur is not None else out).append(line)
    head = out
    body = []
    for t in tables:
        guard = any(re.match(r'^\s*guard\s*=\s*true', ln) for ln in t)
        exp = next((m.group(4) for ln in t if (m := EXPECT.match(ln))), None)
        for ln in t:
            m = EXPECT.match(ln)
            if m:
                ind, sp, sp2, hx, rest = m.groups()
                b = bytes.fromhex(hx)
                body.append(f"{ind}expect_len{sp[:-4] if len(sp) > 4 else ' '}={sp2}{len(b)}{rest}\n")
                body.append(f"{ind}expect_sha256 = \"{hashlib.sha256(b).hexdigest()}\"\n")
                n += 1
                continue
            r = REPLACE.match(ln)
            if r and guard and exp is not None and r.group(1).lower() == exp.lower():
                n += 1
                continue
            m = REPLACE_LINE.match(ln)
            if m and image is not None and t[0].strip() == "[[patch]]":
                b = bytes.fromhex(m.group(4))
                at = image.find(b) if len(b) >= 8 and b.strip(b"\0\xff") else -1
                if at >= 0:
                    ind, sp, sp2, _hx, rest = m.groups()
                    body.append(f"{ind}replace_from{sp[:-5] if len(sp) > 5 else ' '}={sp2}0x{BASE + at:08x}{rest}\n")
                    n += 1
                    continue
            body.append(ln)
    return "".join(head + body), n


def main():
    args = sys.argv[1:]
    image = Path(args[args.index("--image") + 1]).read_bytes() if "--image" in args else None
    text = REG.read_text()
    new, n = convert(text, image)
    if "--check" in args:
        if n:
            print(f"{REG.relative_to(ROOT)}: {n} stock byte strings left as hex; run tools/hash_expect.py")
            return 1
        print("registry holds no stock bytes as hex: PASS")
        return 0
    if n:
        REG.write_text(new)
    print(f"{n} lines converted")
    return 0


if __name__ == "__main__":
    sys.exit(main())
