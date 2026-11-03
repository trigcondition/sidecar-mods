#!/usr/bin/env python3
"""tools/ostarget.py - one source tree, two Rytm OSes: the sources are written for OS 1.73; a port to another OS is
made at build time from a committed address map (re/os/<os>.toml).

    tools/ostarget.py info [KEY] [--os OS]      the OS's stock file, hashes and elekloader core (default: the tree's)
    tools/ostarget.py port OS [--out DIR]       the tree for OS in DIR (default build/os/OS): mods, registry, symbols
                                                and the suites with every image address translated; make there
    tools/ostarget.py derive OS FROM.syx TO.syx  maintainers: the map and the port's expect hashes from both stock
                                                images, into re/os/OS.toml (needs both; nothing of either is written)
    tools/ostarget.py check OS FROM.syx TO.syx   maintainers: every address the tree uses, classified and compared in
                                                both images (build/os/OS-check.csv); exit 1 on a refusal or mismatch
    tools/ostarget.py crosscheck OS FROM.syx TO.syx A.bin B.bin
                                                maintainers: one build for both OSes (each build/mainos_TAG.bin): the
                                                target's differs from the sources' OS's only by translated addresses

Why a map and not a second source tree: OS 1.74's MAIN OS is 1.73's with the Outbox's routing added and the code after
it shifted by a few bytes (+0x6c .. +0x364, in a few long segments); RAM did not move, structs did not change. So every
address the mods name is 1.73's plus its segment's shift, and the map says that in a few hundred lines. The port refuses
an address in a region 1.74 really changed (`[[changed]]`) or that falls between two segments, instead of guessing.

What the port rewrites, in a copy (never the sources):
- re/symbols.toml: [meta] for the target, every main-OS `addr`;
- registry/allocations.toml: every claim's `addr`, `rejoin`, `replace_from`, the image pointers inside a `replace`, pool
  bounds, and each `expect_sha256` / pool hash by the target's (re/os/OS.toml [expect] / [pool.*]: hashes of the
  target's stock bytes, as the registry keeps 1.73's; tools/hash_expect.py);
- the mods' sources (.c, .h, .s): hex literals in the image (and, in generated stubs, the decimal ones gcc folded);
- the emulator suites (tools/emu, tools/us_records.py): hex literals and bare 8-digit hex strings in the image.
Nothing else differs: build.py, verify.py and release_check.py take the OS's stock file, elekloader core and version
strings from re/os/OS.toml through info().

The guard that keeps this honest: each claim's stock bytes are checked against the target's hash at build time, as on
1.73; `derive` writes a hash only where the target's bytes equal 1.73's once absolute addresses and PC-relative operands
are translated by the same map, and `check` compares every address the tree uses in both images.
"""
import argparse
import bisect
import csv
import difflib
import hashlib
import os
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BASE = 0x40000400                       # MAIN OS load address
RAM = ((0x80000000, 0x80100000),)       # SRAM; DDR (0x40000000..) above the image did not move either
DDR_END = 0x48000000

# ------------------------------------------------------------------------------------------------- the OS's facts


def tree_os(root=ROOT) -> str:
    """The OS a tree's symbols are for ("1.73"), from re/symbols.toml [meta] target ("OS1.73")."""
    with open(root / "re" / "symbols.toml", "rb") as f:
        return tomllib.load(f)["meta"]["target"].removeprefix("OS")


def load(os_ver: str, root=ROOT) -> dict:
    with open(root / "re" / "os" / f"{os_ver}.toml", "rb") as f:
        return tomllib.load(f)


def info(os_ver: str | None = None, root=ROOT) -> dict:
    """re/os/OS.toml [meta] for OS (default: the tree's own), with `stock_path` the stock file in stock/."""
    v = os_ver or tree_os(root)
    m = dict(load(v, root)["meta"])
    m["stock_path"] = root / "stock" / m["stock"]
    return m


# ------------------------------------------------------------------------------------------------- the map


class Refused(Exception):
    """An address the port will not translate: in a region the target changed, or between two segments."""


class Map:
    """1.73 address -> target address, from re/os/OS.toml: [[segment]] (start, end exclusive, shift), [[changed]]
    (start, end: refuse), [[exception]] (addr, to). Outside the image (RAM, DDR, I/O): unchanged."""

    def __init__(self, doc: dict, image_end: int):
        self.end = image_end
        self.segs = sorted((s["start"], s["end"], s["shift"]) for s in doc.get("segment", []))
        self.starts = [s[0] for s in self.segs]
        self.changed = sorted((c["start"], c["end"], c.get("note", "")) for c in doc.get("changed", []))
        self.exc = {e["addr"]: e["to"] for e in doc.get("exception", [])}
        for (a0, a1, _), (b0, _b1, _) in zip(self.segs, self.segs[1:]):
            if a1 > b0:
                raise SystemExit(f"re/os: segments overlap at 0x{b0:08x}")

    def in_image(self, a: int) -> bool:
        return BASE <= a < self.end

    def tr(self, a: int) -> int:
        if a in self.exc:
            return self.exc[a]
        if not self.in_image(a):
            return a
        for lo, hi, note in self.changed:
            if lo <= a < hi:
                raise Refused(f"0x{a:08x} is in a region the target OS changed (0x{lo:08x}..0x{hi:08x}: {note})")
        i = bisect.bisect_right(self.starts, a) - 1
        if i >= 0 and a < self.segs[i][1]:
            return a + self.segs[i][2]
        raise Refused(f"0x{a:08x} is between two segments of the map (no counterpart in the target)")

    def shift(self, a: int) -> int:
        return self.tr(a) - a


def the_map(os_ver: str, root=ROOT) -> Map:
    doc = load(os_ver, root)
    src = info(doc["meta"]["from"], root)
    return Map(doc, BASE + src["mainos_size"])


def addr(a: int, root=ROOT) -> int:
    """A source (1.73) address as the tree's OS has it: unchanged in the sources' own tree, translated in a port's
    (for the few addresses the tools themselves name, e.g. build.py's storage guard)."""
    v = tree_os(root)
    doc = load(v, root)
    if "from" not in doc["meta"]:
        return a
    return the_map(v, root).tr(a)


# ------------------------------------------------------------------------------------------------- the port

HEX = re.compile(r"(?<![\w])(?<![^.]\.)0[xX]([0-9a-fA-F]{8})([uUlL]*)\b")   # also after "..", a range
DEC = re.compile(r"(?<![\w.$-])(1\d{9})(?!\w)(?!\.\d)")   # also `1075551828.l` (gas absolute long)
BARE = re.compile(r"(?<![0-9a-fA-Fx_.])(40[0-2][0-9a-fA-F]{5})(?![0-9a-fA-F])")
# any number that could be an image address, in whatever form: what the forms above missed is refused (an address left
# as 1.73's would be the same word in both builds, which no comparison of the two builds can see)
ANY = re.compile(r"(?<![0-9a-zA-Z_])(?:0[xX]([0-9a-fA-F]{8})|(1\d{9}))(?![0-9a-zA-Z_])")
HEXU = re.compile(r"(?<![\w.])0x(40[0-2][0-9a-fA-F]_[0-9a-fA-F]{4})\b")      # Python's 0x4012_119a


class Translator:
    def __init__(self, m: Map):
        self.m, self.log, self.refused = m, [], []

    def _one(self, v, where, fmt):
        if not self.m.in_image(v) and v not in self.m.exc:
            return None
        try:
            t = self.m.tr(v)
        except Refused as e:
            self.refused.append(f"{where}: {e}")
            return None
        if t == v:
            return None
        self.log.append((where, v, t))
        return fmt(t)

    def text(self, s: str, where: str, dec=False, bare=False) -> str:
        """Every image address in s translated; refused ones left and recorded."""
        out = []
        for n, line in enumerate(s.splitlines(keepends=True), 1):
            w = f"{where}:{n}"

            def hx(mm):
                v = int(mm.group(1), 16)
                low = mm.group(1) == mm.group(1).lower()
                r = self._one(v, w, lambda t: (f"0x{t:08x}" if low else f"0x{t:08X}") + mm.group(2))
                return r or mm.group(0)
            line = HEX.sub(hx, line)
            line = HEXU.sub(lambda mm: self._one(int(mm.group(1).replace("_", ""), 16), w,
                                                 lambda t: f"0x{t >> 16:04x}_{t & 0xffff:04x}") or mm.group(0), line)
            if dec:
                line = DEC.sub(lambda mm: self._one(int(mm.group(1)), w, str) or mm.group(0), line)
            if bare:
                line = BARE.sub(lambda mm: self._one(int(mm.group(1), 16), w, lambda t: f"{t:08x}") or mm.group(0),
                                line)
            made = {b for ww, _a, b in self.log[-64:] if ww == w}
            for mm in ANY.finditer(line):
                v = int(mm.group(1), 16) if mm.group(1) else int(mm.group(2))
                if v in made or not self.m.in_image(v) or (mm.group(2) and not dec):
                    continue
                try:
                    if self.m.tr(v) != v:
                        self.refused.append(f"{w}: {mm.group(0)} looks like a moved image address in a form the port "
                                            f"does not translate")
                except Refused:
                    pass
            out.append(line)
        return "".join(out)


def _set(t: str, key: str, fmt, fn) -> str:
    """In one TOML table's text, the first `key = <int>` line's value through fn (kept as hex)."""
    def rep(mm):
        return f"{mm.group(1)}{fmt(fn(int(mm.group(2).replace('_', ''), 0)))}"
    return re.sub(rf"(?m)^({key}\s*=\s*)(0x[0-9a-fA-F_]+|\d+)", rep, t, count=1)


def _get(t: str, key: str):
    mm = re.search(rf"(?m)^{key}\s*=\s*(0x[0-9a-fA-F_]+|\d+|\"[^\"]*\")", t)
    if not mm:
        return None
    v = mm.group(1)
    return v.strip('"') if v.startswith('"') else int(v.replace("_", ""), 0)


def expect_key(addr: int, n: int, sha173: str) -> str:
    return f"0x{addr:08x}:{n}:{sha173[:16]}"


def port_registry(text: str, m: Map, doc: dict, tr: Translator) -> str:
    target = doc["meta"]["os"]
    text = text.replace('target = "OS1.73"', f'target = "OS{target}"', 1)
    parts = re.split(r"(?m)^(?=\[\[(?:pool|cave|detour|patch)\]\])", text)
    out = [parts[0]]
    expects, pools = doc.get("expect", {}), doc.get("pool", {})
    gone = {(u["owner"], u["addr"]): u.get("note", "") for u in doc.get("unavailable", [])}
    hexs = lambda v: f"0x{v:08x}"   # noqa: E731
    for t in parts[1:]:
        kind = t[2:t.index("]")]
        if kind == "cave" and (_get(t, "owner"), _get(t, "addr")) in gone:
            # a claim with no room on this OS: left out, so a build that needs it fails ("no cave"), never misplaced
            tr.log.append((f"registry cave {_get(t, 'owner')} 0x{_get(t, 'addr'):08x} UNAVAILABLE on {target}",
                           _get(t, "addr"), _get(t, "addr")))
            continue
        if kind == "pool":
            name, st, en = _get(t, "name"), _get(t, "start"), _get(t, "end")
            p = pools.get(name)
            if p is None:
                raise SystemExit(f"re/os/{target}.toml has no [pool.{name}]: run derive")
            t = _set(t, "start", hexs, lambda v: p["start"])
            t = _set(t, "end", hexs, lambda v: p["end"])
            if "expect_sha256" in p:
                t = re.sub(r'(?m)^(expect_sha256\s*=\s*")[0-9a-f]+', lambda mm: mm.group(1) + p["expect_sha256"], t)
            out.append(t)
            continue
        addr = _get(t, "addr")
        where = f"registry {kind} {_get(t, 'owner')} 0x{addr:08x}"
        try:
            na = m.tr(addr)
        except Refused as e:
            tr.refused.append(f"{where}: {e}")
            out.append(t)
            continue
        t = _set(t, "addr", hexs, lambda v: na)
        if _get(t, "rejoin") is not None and isinstance(_get(t, "rejoin"), int):
            t = _set(t, "rejoin", hexs, m.tr)
        if _get(t, "replace_from") is not None:
            t = _set(t, "replace_from", hexs, m.tr)
        if kind in ("detour", "patch") and _get(t, "expect_sha256"):
            n, sha = _get(t, "expect_len"), _get(t, "expect_sha256")
            k = expect_key(addr, n, sha)
            if k not in expects:
                tr.refused.append(f"{where}: no target hash for its stock bytes ({k}): run derive")
            else:
                t = re.sub(r'(?m)^(expect_sha256\s*=\s*")[0-9a-f]+', lambda mm: mm.group(1) + expects[k], t, count=1)
        mm = re.search(r'(?m)^replace\s*=\s*"([0-9a-fA-F ]+)"', t)
        if mm:
            rb = bytearray(bytes.fromhex(mm.group(1).replace(" ", "")))
            i = 0
            while i + 4 <= len(rb):
                v = struct.unpack_from(">I", rb, i)[0]
                if m.in_image(v):
                    try:
                        nv = m.tr(v)
                    except Refused as e:
                        tr.refused.append(f"{where}: replace +{i}: {e}")
                        i += 2
                        continue
                    if nv != v:
                        struct.pack_into(">I", rb, i, nv)
                        tr.log.append((f"{where} replace +{i}", v, nv))
                    i += 4
                    continue
                i += 2
            t = t[:mm.start(1)] + rb.hex() + t[mm.end(1):]
        out.append(t)
    return "".join(out)


def port_symbols(text: str, m: Map, doc: dict, tr: Translator) -> str:
    meta = doc["meta"]
    for k in ("mainos_size", "bootstrap_size"):
        text = re.sub(rf"(?m)^({k}\s*=\s*)\d+", lambda mm: f"{mm.group(1)}{meta[k]}", text, count=1)
    for k in ("mainos_sha256", "bootstrap_sha256"):
        text = re.sub(rf'(?m)^({k}\s*=\s*")[0-9a-f]+', lambda mm: mm.group(1) + meta[k], text, count=1)
    text = re.sub(r'(?m)^(target\s*=\s*")OS[0-9.]+', lambda mm: f'{mm.group(1)}OS{meta["os"]}', text, count=1)
    out, sec, image = [], None, "mainos"
    for n, line in enumerate(text.splitlines(keepends=True), 1):
        h = re.match(r"\[(fn|data|const)\.", line)
        if h:
            sec, image = h.group(1), "mainos"
        if line.startswith("[") and not h:
            sec = None
        mm = re.match(r"(addr\s*=\s*)0x([0-9a-fA-F]+)(.*)", line, re.S)
        if mm and sec in ("fn", "data"):
            v = int(mm.group(2), 16)
            if m.in_image(v):
                try:
                    nv = m.tr(v)
                except Refused as e:
                    tr.refused.append(f"re/symbols.toml:{n}: {e}")
                    nv = v
                if nv != v:
                    tr.log.append((f"re/symbols.toml:{n}", v, nv))
                line = f"{mm.group(1)}0x{nv:08x}{mm.group(3)}"
        out.append(line)
    return "".join(out)


COPY = ["Makefile", "VERSION", "LICENSE", "NOTICE", "requirements.txt", "docs", "re", "registry", "mods", "tools"]
LINK = [".venv", "vendor"]


def port(os_ver: str, out: Path, root=ROOT, quiet=False) -> int:
    """The tree for os_ver in out (made afresh; its build/ kept). Exit status: 1 if anything was refused."""
    if os_ver == tree_os(root):
        raise SystemExit(f"the tree is {os_ver} already")
    doc = load(os_ver, root)
    m = the_map(os_ver, root)
    tr = Translator(m)
    out.mkdir(parents=True, exist_ok=True)
    for name in COPY:
        dst = out / name
        if dst.is_symlink() or dst.is_file():
            dst.unlink()
        elif dst.exists():
            shutil.rmtree(dst)
        src = root / name
        if src.is_dir():
            shutil.copytree(src, dst, ignore=shutil.ignore_patterns("__pycache__", "*.pyc", "*.o", "*.elf"))
        else:
            shutil.copy2(src, dst)
    for name in LINK:
        dst = out / name
        if not dst.exists() and (root / name).exists():
            dst.symlink_to((root / name).resolve())
    st = out / "stock"
    st.mkdir(exist_ok=True)
    meta = doc["meta"]
    src_stock = root / "stock" / meta["stock"]
    if (st / meta["stock"]).is_symlink() or (st / meta["stock"]).exists():
        (st / meta["stock"]).unlink()
    if src_stock.exists():
        (st / meta["stock"]).symlink_to(src_stock.resolve())
    (st / "SHA256SUMS").write_text(f"{meta['syx_sha256']}  {meta['stock']}\n")

    p = out / "re" / "symbols.toml"
    p.write_text(port_symbols(p.read_text(), m, doc, tr))
    p = out / "registry" / "allocations.toml"
    p.write_text(port_registry(p.read_text(), m, doc, tr))
    for f in sorted((out / "mods").rglob("*")):
        if f.suffix not in (".c", ".h", ".s", ".S", ".inc") or not f.is_file():
            continue
        s = f.read_text(errors="surrogateescape")
        gen = "GENERATED" in s[:400]
        n = tr.text(s, str(f.relative_to(out)), dec=gen)
        if n != s:
            f.write_text(n, errors="surrogateescape")
    for f in sorted(list((out / "tools" / "emu").iterdir()) + [out / "tools" / "us_records.py"]):
        if f.suffix not in (".py", ".json", ".sh") or not f.is_file():
            continue
        s = f.read_text()
        n = tr.text(s, str(f.relative_to(out)), bare=f.suffix != ".sh")
        if n != s:
            f.write_text(n)
    rep = out / "port.log"
    with open(rep, "w") as fh:
        fh.write(f"# port {tree_os(root)} -> {os_ver}: {len(tr.log)} translations, {len(tr.refused)} refused\n")
        for w in tr.refused:
            fh.write(f"REFUSED {w}\n")
        for w, a, b in tr.log:
            fh.write(f"{w}\t0x{a:08x}\t0x{b:08x}\t{b - a:+#x}\n")
    if not quiet:
        print(f"port {os_ver}: {out} ({len(tr.log)} addresses translated, {len(tr.refused)} refused; {rep.name})")
        for w in tr.refused[:20]:
            print("  REFUSED", w)
    return 1 if tr.refused else 0


# ------------------------------------------------------------------------------------------------- derive / check


def extract_mainos(syx: Path) -> bytes:
    eft = ROOT / "vendor" / "elektron-firmware-tool" / "elektron-firmware-tool"
    with tempfile.TemporaryDirectory() as d:
        subprocess.run([eft, "-i", syx, "-o", d], check=True, capture_output=True)
        return (Path(d) / "section_3_MAIN_OS.bin").read_bytes()


def _isptr(v):
    return 0x40000000 <= v < DDR_END or any(lo <= v < hi for lo, hi in RAM)


def _mask(d: bytes) -> bytes:
    """Image pointers (any 4 bytes at an even offset that read as one) replaced by a constant: what moves."""
    mm = bytearray(d)
    for i in range(0, len(d) - 3, 2):
        if _isptr(struct.unpack_from(">I", d, i)[0]):
            mm[i:i + 4] = b"\xaa\xaa\xaa\xaa"
    return bytes(mm)


def word_map(a: bytes, b: bytes) -> dict:
    """{1.73 even offset: target offset}: unique 16-byte masked windows as anchors, their longest increasing chain,
    then difflib on the words between anchors (runs of 3 words or more)."""
    K = 16
    ma, mb = _mask(a), _mask(b)

    def idx(mm):
        c = {}
        for i in range(0, len(mm) - K, 2):
            w = mm[i:i + K]
            if w.count(w[0]) == K:
                continue
            c.setdefault(w, []).append(i)
        return c
    ia, ib = idx(ma), idx(mb)
    anch = sorted((v[0], ib[k][0]) for k, v in ia.items() if len(v) == 1 and len(ib.get(k, ())) == 1)
    tails, tidx, prev = [], [], [-1] * len(anch)
    for n, (_x, y) in enumerate(anch):
        j = bisect.bisect_left(tails, y)
        if j == len(tails):
            tails.append(y)
            tidx.append(n)
        else:
            tails[j], tidx[j] = y, n
        prev[n] = tidx[j - 1] if j else -1
    ch, n = [], tidx[-1]
    while n >= 0:
        ch.append(anch[n])
        n = prev[n]
    ch.reverse()
    d = {}
    for x, y in ch:
        for i in range(0, K, 2):
            d.setdefault(x + i, y + i)
    keys, last, pairs = sorted(d), -1, []
    for k in keys:
        if d[k] > last:
            pairs.append((k, d[k]))
            last = d[k]
    gaps, pa, pb = [], -2, -2
    for x, y in pairs + [(len(a) & ~1, len(b) & ~1)]:
        if x - pa > 2 or y - pb > 2:
            gaps.append((pa + 2, x, pb + 2, y))
        pa, pb = x, y
    add = []
    for g in gaps:
        wa = [ma[i:i + 2] for i in range(g[0], g[1], 2)]
        wb = [mb[i:i + 2] for i in range(g[2], g[3], 2)]
        if not wa or not wb or len(wa) * len(wb) > 4e8:
            continue
        sm = difflib.SequenceMatcher(None, wa, wb, autojunk=False)
        for bl in sm.get_matching_blocks():
            if bl.size >= 3:
                for j in range(bl.size):
                    add.append((g[0] + 2 * (bl.a + j), g[2] + 2 * (bl.b + j)))
    return dict(sorted(pairs + add))


PCREL16 = {0x4eba, 0x41fa, 0x43fa, 0x45fa, 0x47fa, 0x49fa, 0x4bfa, 0x4dfa, 0x4ffa, 0x6100, 0x6000}


def compare(a: bytes, b: bytes, m: Map, x: int, t: int, n: int) -> list:
    """The words of a[x..x+n) (1.73) and b[t..) (target) that differ for any reason but a translated address: an
    absolute pointer the map translates, or a PC-relative operand whose target the map translates. [] = the same code."""
    def tr0(v):
        try:
            return m.tr(v)
        except Refused:
            return None
    ox, ot, i, bad = x - BASE, t - BASE, 0, []
    while i < n:
        if a[ox + i:ox + i + 2] == b[ot + i:ot + i + 2]:
            i += 2
            continue
        la, lb = struct.unpack_from(">I", a, ox + i)[0], struct.unpack_from(">I", b, ot + i)[0]
        if _isptr(la) and _isptr(lb) and tr0(la) == lb:
            i += 4
            continue
        la2, lb2 = struct.unpack_from(">I", a, ox + i - 2)[0], struct.unpack_from(">I", b, ot + i - 2)[0]
        if _isptr(la2) and _isptr(lb2) and tr0(la2) == lb2:
            i += 2
            continue
        pa = struct.unpack_from(">H", a, ox + i - 2)[0]
        sa, sb = struct.unpack_from(">h", a, ox + i)[0], struct.unpack_from(">h", b, ot + i)[0]
        if (pa in PCREL16 or (pa & 0xf0ff) == 0x6000) and tr0(x + i + sa) == t + i + sb:
            i += 2
            continue
        if (pa & 0xf0ff) == 0x60ff or pa == 0x61ff:
            da, db = struct.unpack_from(">i", a, ox + i)[0], struct.unpack_from(">i", b, ot + i)[0]
            if tr0(x + i + da) == t + i + db:
                i += 4
                continue
        pa2 = struct.unpack_from(">H", a, ox + i - 4)[0]
        if (pa2 & 0xf0ff) == 0x60ff or pa2 == 0x61ff:
            da, db = struct.unpack_from(">i", a, ox + i - 2)[0], struct.unpack_from(">i", b, ot + i - 2)[0]
            if tr0(x + i - 2 + da) == t + i - 2 + db:
                i += 2
                continue
        bad.append(x + i)
        i += 2
    return bad


def segments(d: dict, a: bytes, b: bytes, reach=48):
    """The word map as segments (start, end, shift): runs of one shift, joined across holes of up to 2 * reach bytes
    with that shift on both sides (words whose PC-relative operands differ, say)."""
    runs = []
    for k in sorted(d):
        sh = d[k] - k
        if runs and runs[-1][2] == sh and k == runs[-1][1]:
            runs[-1][1] = k + 2
        elif runs and runs[-1][2] == sh and k - runs[-1][1] <= 2 * reach:
            runs[-1][1] = k + 2
        else:
            runs.append([k, k + 2, sh])
    return [(s + BASE, e + BASE, sh) for s, e, sh in runs]


def derive(os_ver: str, from_syx: Path, to_syx: Path) -> int:
    """The map ([[segment]], [[changed]]) and the hashes ([expect], [pool.*]) in re/os/OS.toml, from both images."""
    path = ROOT / "re" / "os" / f"{os_ver}.toml"
    doc = load(os_ver)
    src = info(doc["meta"]["from"])
    a, b = extract_mainos(from_syx), extract_mainos(to_syx)
    if hashlib.sha256(a).hexdigest() != src["mainos_sha256"]:
        raise SystemExit(f"{from_syx}: not stock {src['os']}")
    if hashlib.sha256(b).hexdigest() != doc["meta"]["mainos_sha256"]:
        raise SystemExit(f"{to_syx}: not stock {os_ver}")
    print("aligning ...", flush=True)
    d = word_map(a, b)
    # a short run inside reshuffled code (under 64 B) is as likely a chance match of a few words as a real
    # counterpart: it becomes part of the changed region around it, so nothing is translated through it
    segs = [s for s in segments(d, a, b) if s[1] - s[0] >= 64]
    # padding at the code's end: 1.73's zeros, which the target's code may have grown into; claims there are checked
    # against the pools ([pool.cave]), so the addresses themselves stay
    pad = doc.get("padding", {})
    if pad:
        segs = [s for s in segs if not (pad["start"] <= s[0] < pad["end"])]
        segs.append((pad["start"], pad["end"], 0))
        segs.sort()
        fixed = []
        for s in segs:
            if fixed and s[0] < fixed[-1][1]:
                if s[2] == 0 and s[0] == pad["start"]:
                    fixed[-1] = (fixed[-1][0], s[0], fixed[-1][2])
                else:
                    s = (fixed[-1][1], s[1], s[2])
            if s[1] > s[0]:
                fixed.append(s)
        segs = fixed
    m = Map({"segment": [dict(start=s, end=e, shift=h) for s, e, h in segs], "exception": doc.get("exception", [])},
            BASE + len(a))
    # the real changes: 1.73 words in no segment, or in one but different once addresses are translated
    print("comparing ...", flush=True)
    bad = []
    for s, e, _h in segs:
        if s >= pad.get("start", 1 << 40) and e <= pad.get("end", 0):
            continue
        bad += compare(a, b, m, s, m.tr(s), e - s)
    covered = [(s, e) for s, e, _ in segs]
    hole = []
    prev = BASE
    for s, e in covered:
        if s > prev:
            hole.append((prev, s))
        prev = max(prev, e)
    if prev < BASE + len(a):
        hole.append((prev, BASE + len(a)))
    spans = sorted([(x, x + 2) for x in bad] + hole)
    changed = []
    for s, e in spans:
        if changed and s - changed[-1][1] <= 64:
            changed[-1][1] = max(changed[-1][1], e)
        else:
            changed.append([s, e])
    # an exception wins over a change (a function the map placed by hand)
    print(f"{len(segs)} segments, {len(changed)} changed regions ({sum(e - s for s, e in changed)} B of 1.73)")

    # the hashes: every claim's stock bytes and every pool, read from the target where they equal 1.73's translated
    import layout  # noqa: E402  (tools/)
    m = Map({"segment": [dict(start=s, end=e, shift=h) for s, e, h in segs],
             "changed": [dict(start=s, end=e) for s, e in changed], "exception": doc.get("exception", [])},
            BASE + len(a))
    reg = layout.load(ROOT / "registry" / "allocations.toml")
    expects, problems = {}, []
    for table in ("detour", "patch"):
        for c in reg.get(table, []):
            if "expect_sha256" not in c:
                continue
            x, n = c["addr"], c["expect_len"]
            got = a[x - BASE:x - BASE + n]
            if hashlib.sha256(got).hexdigest() != c["expect_sha256"]:
                problems.append(f"{table} {c['owner']} 0x{x:08x}: 1.73's bytes do not match its expect_sha256")
                continue
            try:
                t = m.tr(x)
            except Refused as e:
                problems.append(f"{table} {c['owner']} 0x{x:08x}: {e}")
                continue
            diff = compare(a, b, m, x & ~1, t & ~1, (n + 1) & ~1)
            if diff:
                problems.append(f"{table} {c['owner']} 0x{x:08x} -> 0x{t:08x}: the target's bytes differ at "
                                f"{', '.join(f'0x{v:08x}' for v in diff[:4])}")
                continue
            expects[expect_key(x, n, c["expect_sha256"])] = hashlib.sha256(b[t - BASE:t - BASE + n]).hexdigest()
    pools = {}
    padpool = doc.get("pool_override", {})
    for p in reg.get("pool", []):
        name, s, e = p["name"], p["start"], p["end"]
        if name in padpool:
            q = dict(padpool[name])
            q.setdefault("end", e)
            if b[q["start"] - BASE:q["end"] - BASE].strip(b"\0"):
                problems.append(f"pool {name}: the target's 0x{q['start']:08x}..0x{q['end']:08x} is not all zeros")
            pools[name] = q
            continue
        try:
            ts, te = m.tr(s), m.tr(e - 2) + 2
        except Refused as ex:
            problems.append(f"pool {name}: {ex}")
            continue
        if te - ts != e - s:
            problems.append(f"pool {name}: 0x{s:08x}..0x{e:08x} spans two shifts")
            continue
        q = dict(start=ts, end=te)
        if "expect_sha256" in p:
            if hashlib.sha256(a[s - BASE:e - BASE]).hexdigest() != p["expect_sha256"]:
                problems.append(f"pool {name}: 1.73's bytes do not match its expect_sha256")
            diff = compare(a, b, m, s, ts, e - s)
            if diff:
                problems.append(f"pool {name}: the target's code differs at 0x{diff[0]:08x}")
            q["expect_sha256"] = hashlib.sha256(b[ts - BASE:te - BASE]).hexdigest()
        pools[name] = q
    for w in problems:
        print("PROBLEM", w)
    write_map(path, segs, changed, expects, pools)
    print(f"wrote {path.relative_to(ROOT)}: {len(expects)} expect hashes, {len(pools)} pools")
    return 1 if problems else 0


def write_map(path: Path, segs, changed, expects, pools):
    """Replace re/os/OS.toml's generated part (from the GENERATED line on); the hand-written head stays."""
    text = path.read_text()
    mark = "# ---- GENERATED by tools/ostarget.py derive"
    head = text.split(mark)[0].rstrip() + "\n\n"
    out = [mark + " from both stock images; do not edit (the head above is hand-written)\n"]
    out.append("# segments: [start, end) of 1.73's MAIN OS and the shift to the target's address\n")
    for s, e, h in segs:
        out.append(f"[[segment]]\nstart = 0x{s:08x}\nend   = 0x{e:08x}\nshift = {h}\n")
    out.append("\n# the regions the target really changed (or that have no counterpart): an address in one is refused\n")
    for s, e in changed:
        out.append(f"[[changed]]\nstart = 0x{s:08x}\nend   = 0x{e:08x}\n")
    out.append("\n# each pool in the target (the bounds; a dead-code pool's hash: its stock bytes there)\n")
    for name, q in pools.items():
        out.append(f"[pool.{name}]\n" + "".join(
            f"{k} = " + (f'"{v}"' if isinstance(v, str) else f"0x{v:08x}") + "\n" for k, v in q.items()))
    out.append("\n# the target's stock bytes at each claim, as sha256 (the registry keeps 1.73's): "
               "\"<1.73 addr>:<len>:<1.73 sha256's first 16>\" = target sha256\n[expect]\n")
    for k in sorted(expects):
        out.append(f'"{k}" = "{expects[k]}"\n')
    path.write_text(head + "".join(out))


def used_addresses(root=ROOT):
    """(where, kind, address, size) for every image address the tree names."""
    import layout  # noqa: E402
    with open(root / "re" / "symbols.toml", "rb") as f:
        syms = tomllib.load(f)
    reg = layout.load(root / "registry" / "allocations.toml")
    out = []
    for k in ("fn", "data"):
        for n, e in syms.get(k, {}).items():
            if e.get("image", "mainos") == "mainos":
                out.append((f"symbols {k}.{n}", "sym-" + k, e["addr"], 16))
    for table in ("detour", "patch", "cave"):
        for c in reg.get(table, []):
            n = c.get("expect_len", min(c.get("size", 16), 64))
            out.append((f"registry {table} {c['owner']}", table, c["addr"], n))
            for k in ("rejoin", "replace_from"):
                if isinstance(c.get(k), int):
                    out.append((f"registry {table} {c['owner']} {k}", table, c[k], 2))
    for f in sorted((root / "mods").rglob("*")):
        if f.suffix not in (".c", ".h", ".s") or not f.is_file():
            continue
        s = f.read_text(errors="surrogateescape")
        gen = "GENERATED" in s[:400]
        for n, line in enumerate(s.splitlines(), 1):
            for mm in HEX.finditer(line):
                out.append((f"{f.relative_to(root)}:{n}", "literal", int(mm.group(1), 16), 2))
            if gen:
                for mm in DEC.finditer(line):
                    out.append((f"{f.relative_to(root)}:{n}", "literal-dec", int(mm.group(1)), 2))
    return out


def check(os_ver: str, from_syx: Path, to_syx: Path) -> int:
    """Every address the tree uses: refused, or the same bytes in the target once translated (16 B, a claim's own
    length, or to a function's first rts)."""
    a, b = extract_mainos(from_syx), extract_mainos(to_syx)
    m = the_map(os_ver)
    doc = load(os_ver)
    gone = {u["addr"] for u in doc.get("unavailable", [])}
    pad = doc.get("padding", {})
    rows, bad = [], 0
    for where, kind, x, n in used_addresses():
        if not m.in_image(x):
            continue
        if kind == "cave" and pad and pad["start"] <= x < pad["end"]:
            # mods' own data in the code's end padding: free in the target, or listed [[unavailable]]
            free = not b[x - BASE:x - BASE + n].strip(b"\0")
            cls = "padding" if free else ("unavailable" if x in gone else "TAKEN")
            bad += cls == "TAKEN"
            rows.append((where, kind, f"0x{x:08x}", f"0x{x:08x}", cls, ""))
            continue
        try:
            t = m.tr(x)
        except Refused as e:
            rows.append((where, kind, f"0x{x:08x}", "", "REFUSED", str(e)))
            bad += 1
            continue
        if kind == "sym-fn":
            o = x - BASE
            n = next((i + 2 for i in range(0, 400, 2) if a[o + i:o + i + 2] == b"\x4e\x75"), 400)
        n = min(max(n, 2), 2048)
        diff = compare(a, b, m, x & ~1, t & ~1, (n + 1) & ~1)
        cls = "identical" if t == x else "moved"
        if diff:
            cls = "DIFFERS"
            bad += 1
        rows.append((where, kind, f"0x{x:08x}", f"0x{t:08x}", cls,
                     ", ".join(f"0x{v:08x}" for v in diff[:4])))
    out = ROOT / "build" / "os" / f"{os_ver}-check.csv"
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(("where", "kind", "addr_1.73", f"addr_{os_ver}", "class", "detail"))
        w.writerows(rows)
    from collections import Counter
    c = Counter(r[4] for r in rows)
    u = Counter()
    for k in {(r[2], r[4]) for r in rows}:
        u[k[1]] += 1
    print(f"check {os_ver}: {len(rows)} uses {dict(c)}; unique addresses {dict(u)}; {out.relative_to(ROOT)}")
    for r in rows:
        if r[4] in ("REFUSED", "DIFFERS"):
            print("  ", *r)
    return 1 if bad else 0


def crosscheck(os_ver: str, from_syx: Path, to_syx: Path, built_from: Path, built_to: Path) -> int:
    """One release built for both OSes (build/mainos_<tag>.bin of each): every byte the mods changed in the 1.73 image
    must be changed in the target's at the translated address, to the same bytes once addresses are translated, and
    nothing else; the appended block (core's .boot and the area's run image) must be the same but for translated
    image addresses."""
    a, b = extract_mainos(from_syx), extract_mainos(to_syx)
    pa, pb = built_from.read_bytes(), built_to.read_bytes()
    m = the_map(os_ver)
    n = len(a)
    if len(b) != n or len(pa) != len(pb):
        print(f"FAIL lengths: stock {len(a)} / {len(b)}, built {len(pa)} / {len(pb)}")
        return 1
    bad = []

    def site_runs(stock, built):
        out, i = [], 0
        while i < n:
            if stock[i] != built[i]:
                j = i
                while j < n and (stock[j] != built[j] or any(stock[k] != built[k] for k in range(j, min(n, j + 4)))):
                    j += 1
                out.append((i, j))
                i = j
            else:
                i += 1
        return out
    ra, rb = site_runs(a, pa), site_runs(b, pb)
    mapped = set()
    for i, j in ra:
        x = BASE + (i & ~1)
        try:
            t = m.tr(x)
        except Refused as e:
            bad.append(f"site 0x{x:08x}: {e}")
            continue
        ln = (j - (i & ~1) + 1) & ~1
        diff = compare(pa, pb, m, x, t, ln)
        if diff:
            bad.append(f"site 0x{x:08x} -> 0x{t:08x} ({ln} B): differs at {', '.join(f'0x{v:08x}' for v in diff[:4])}")
        mapped.update(range(t - BASE, t - BASE + ln))
    extra = [(i, j) for i, j in rb if not set(range(i, j)) <= mapped]
    for i, j in extra:
        bad.append(f"target site 0x{BASE + i:08x} ({j - i} B) has no 1.73 counterpart")
    # the appended block: words that differ must be translations of image addresses
    ta, tb = pa[n:], pb[n:]
    words = expl = 0
    i = 0
    while i + 2 <= len(ta):
        if ta[i:i + 2] == tb[i:i + 2]:
            i += 2
            continue
        words += 1
        ok = False
        for k in (i, i - 2):
            if k < 0 or k + 4 > len(ta):
                continue
            va, vb = struct.unpack_from(">I", ta, k)[0], struct.unpack_from(">I", tb, k)[0]
            try:
                if m.in_image(va) and m.tr(va) == vb:
                    ok = True
                    break
            except Refused:
                pass
        if ok:
            expl += 1
        else:
            bad.append(f"block +0x{i:x}: {ta[i:i + 4].hex()} / {tb[i:i + 4].hex()} not a translation")
        i += 2
    # the other way round: an image address in 1.73's block that moves must have moved in the target's (an
    # untranslated literal is the same word in both, so the loop above cannot see it)
    stale = []
    for i in range(0, len(ta) - 3, 2):
        va = struct.unpack_from(">I", ta, i)[0]
        if not m.in_image(va) or va < BASE + 0x100:
            continue
        try:
            t = m.tr(va)
        except Refused:
            continue
        if t != va and struct.unpack_from(">I", tb, i)[0] == va:
            stale.append(i)
    for i in stale:
        print(f"  LOOK block +0x{i:x}: 0x{struct.unpack_from('>I', ta, i)[0]:08x} reads as a moved image address and "
              f"is the same in both: instruction or table bytes, or an address the port missed (the port refuses "
              f"every literal form it does not translate, so normally the former)")
    print(f"crosscheck {os_ver}: {len(stale)} LOOK words; {len(ra)} site runs in 1.73's image, {len(rb)} in the target's; appended block "
          f"{len(ta)} B, {words} differing words, {expl} of them translated addresses; {len(bad)} problems")
    for w in bad[:30]:
        print("  FAIL", w)
    return 1 if bad else 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("info")
    p.add_argument("key", nargs="?", help="one fact (e.g. stock, core_rev); default: all")
    p.add_argument("--os", help="default: the tree's")
    p = sub.add_parser("port")
    p.add_argument("os")
    p.add_argument("--out", type=Path)
    for name in ("derive", "check", "crosscheck"):
        p = sub.add_parser(name)
        p.add_argument("os")
        p.add_argument("from_syx", type=Path)
        p.add_argument("to_syx", type=Path)
        if name == "crosscheck":
            p.add_argument("built_from", type=Path, help="the build's MAIN OS for the sources' OS (build/mainos_TAG.bin)")
            p.add_argument("built_to", type=Path, help="the same build's for the target (build/os/OS/build/...)")
    args = ap.parse_args()
    sys.path.insert(0, str(ROOT / "tools"))
    if args.cmd == "info":
        i = info(args.os)
        if args.key:
            print(i[args.key])
        else:
            for k, v in i.items():
                print(f"{k} = {v}")
        return 0
    if args.cmd == "port":
        return port(args.os, args.out or ROOT / "build" / "os" / args.os)
    if args.cmd == "derive":
        return derive(args.os, args.from_syx, args.to_syx)
    if args.cmd == "crosscheck":
        return crosscheck(args.os, args.from_syx, args.to_syx, args.built_from, args.built_to)
    return check(args.os, args.from_syx, args.to_syx)


if __name__ == "__main__":
    sys.exit(main())
