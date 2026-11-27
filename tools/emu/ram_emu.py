#!/usr/bin/env python3
"""Emulator tests of the big UI-task buffers in the bundle's DDR region (mods/0026-remote-ui/design.md and
0029-sendfx-ui/design.md, "big-ram"): 0026's frame, text and name buffers and 0029's sfu_x sit in claims of the
registry's `sidecar_buffers` pool (0x47C00000-0x47F00000, outside elekloader's 128 KB area), and the mods zero them in
their first tick, before anything publishes them.

    .venv/bin/python tools/emu/ram_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: an OS 1.74 build of the Sidecar set, whose base tools/emu/us_base.sh TAG made; RYTM_EMU, RYTM_TEENSY as rui_emu.py.
Every run under DTEMU_STRICT=1. The DDR is not zeroed by the boot copier (only the area's .bss is) and holds noise at
power-on: the dirty tests fill every claim with junk words (`--poke`, before the first instruction) and cold boot.
    region   the buffers' symbols lie in their claims, the claims in the region; the audio interrupt's state (pmo, fp)
             and the init flags stay in elekloader's area (.bss)
    dirty    a cold boot over junk: no junk word is left in any claim (a claim's last 12 bytes may be the registry's
             rounding); 0026's claims read all zero (no host, no page); 0029 has initialised (sfu_st.init, BASE / WIDTH
             defaults, its lists zero)
    first    check 2, direct: a read/write watch over each claim (and over its last 24 bytes, which `dirty` does not see) on the
             cold boot over junk: the first access to each is a zeroing write, not a read of junk
    dirtyui  a cold boot over junk with the host attached (the splash): the panel shows the host's frame byte for
             byte (shadow, staging, comp, the text slots all work from zero)
The features themselves run on a dirty base, the suites' own tests: make a base whose cold boot ran over junk
(`US_BASE_DIRTY=1 tools/emu/us_base.sh TAG`, TAG an alias of a built tag: its .syx and manifest copied under it) and run
rui_emu, sv_emu, sfu_emu ... on it. `ram_emu.py --pokes TAG` prints the junk fill's --poke arguments.
"""
import json
import os
import re
import sys
from concurrent.futures import ThreadPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rui_emu as R   # noqa: E402
import sfu_emu as S   # noqa: E402



def check(what, ok, detail=""):
    R.check(what, ok, detail)
    return ok


EMU = R.EMU
REGION = (0x47C00000, 0x47F00000)
AREA = (0x47BE0000, 0x47C00000)
# the buffers: claim name -> (mod, symbol). The symbol is the absolute label the suites already peek.
BUFFERS = {"rui_shadow": ("0026-remote-ui", "shadow"), "rui_staging": ("0026-remote-ui", "staging"),
           "rui_comp": ("0026-remote-ui", "comp"), "rui_comp_in": ("0026-remote-ui", "comp_in"),
           "rui_txt_st": ("0026-remote-ui", "txt_st"), "rui_txt_sh": ("0026-remote-ui", "txt_sh"),
           "rui_txt_tl": ("0026-remote-ui", "txt_tl"), "rui_ux": ("0026-remote-ui", "ux"),
           "sfu_x": ("0029-sendfx-ui", "sfu_x"), "sfu_p": ("0029-sendfx-ui", "sfu_p")}
# in .bss, in elekloader's area, on purpose: the audio interrupt reads them (pmo_pre / pmo_post / pmo_vel, fp_check)
# or they are the init flags and the small state
STAY = [("0026-remote-ui", "pmo"), ("0026-remote-ui", "fp"), ("0026-remote-ui", "st"), ("0026-remote-ui", "qp")]
JUNK = 0xA5C3E1F7


def manifest(e):
    return json.load(open(os.path.join(e.out, "manifest.json")))


def spans(e):
    """claim name -> (lo, hi) from the manifest's elek.buffers"""
    return {b["name"]: (b["lo"], b["hi"]) for b in manifest(e)["elek"]["buffers"]}


def sym(e, mod, name):
    return e.syms[f"rytm-{mod}:{name}"]


def junk(a):
    return ((JUNK ^ (a * 0x9E3779B1)) & 0xFFFFFFFF) | 1


def pokes_of(buffers):
    """--poke every word of every claim (junk, address-dependent and never 0)"""
    out = []
    for b in buffers:
        for a in range(b["lo"], b["hi"], 4):
            out += ["--poke", f"{a:x}={junk(a):x}"]
    return out


def pokes(e):
    return pokes_of(manifest(e)["elek"]["buffers"])


def card_copy(e, name):
    """the base's card, powered off in the base (its settings kept), as rui_emu's t_boot"""
    c = os.path.join(e.out, name)
    if os.path.exists(c):
        os.remove(c)
    os.system(f"cp -c '{os.path.join(EMU, e.card)}' '{c}'")
    e.run(f"{name}-off", 600, [], extra=["--power-off", f"{e.clock + 40:g}M"], card=c, save=False)
    return c


def t_region(e):
    sp = spans(e)
    check("region: the manifest lists a claim for each of the ten buffers", set(sp) == set(BUFFERS), sorted(sp))
    for claim, (mod, name) in sorted(BUFFERS.items()):
        a = sym(e, mod, name) if f"rytm-{mod}:{name}" in e.syms else None
        lo, hi = sp.get(claim, (0, 0))
        check(f"region: {name} lies in its claim {claim} (0x{lo:08x}-0x{hi:08x}), inside the bundle's region",
              a is not None and lo <= a < hi and REGION[0] <= lo and hi <= REGION[1],
              "no symbol" if a is None else f"0x{a:08x}")
    check("region: the claims are 16-byte aligned, do not overlap, and none touches elekloader's area",
          all(lo % 16 == 0 and hi % 16 == 0 for lo, hi in sp.values()) and
          all(a[1] <= b[0] or b[1] <= a[0] for i, a in enumerate(sorted(sp.values())) for b in sorted(sp.values())[i + 1:]) and
          all(hi <= AREA[0] or AREA[1] <= lo for lo, hi in sp.values()), sp)
    for mod, name in STAY:
        a = sym(e, mod, name)
        check(f"region: {name} (the audio interrupt's / the init flags') stays in elekloader's .bss",
              AREA[0] <= a < AREA[1], f"0x{a:08x}")
    m = manifest(e)
    check("region: the bundle declares the region", [(r["lo"], r["hi"]) for r in m["elek"]["regions"]
                                                     if r["name"] == "sidecar buffers"] == [REGION],
          m["elek"]["regions"])


def readback(e, snap):
    return {c: e.peek(snap, lo, hi - lo) for c, (lo, hi) in spans(e).items()}


def t_dirty(e):
    if not check("dirty: the build has the ten claims (the manifest's elek.buffers)", set(spans(e)) == set(BUFFERS), sorted(spans(e))):
        return
    c = card_copy(e, "ram-dirty.img")
    r = e.run("ram-dirty", 11500, [], cold=True, card=c, extra=pokes(e))
    mem = readback(e, r["snap"])
    left = {n: sum(int.from_bytes(b[i:i + 4], "big") == junk(spans(e)[n][0] + i) for i in range(0, len(b) - 12, 4))
            for n, b in mem.items()}
    check("dirty: no junk word is left in any claim after the first ticks", not any(left.values()), left)
    for n, b in sorted(mem.items()):
        if n not in ("sfu_x", "sfu_p"):
            check(f"dirty: {n} reads all zero (no host, no page: nothing wrote it since the init)", not any(b),
                  f"{sum(1 for x in b if x)} non-zero bytes")
    s = r["snap"]
    sx = sym(e, "0029-sendfx-ui", "sfu_x")
    bw = e.peek(s, sx + S.X_BW, 4)
    check("dirty: 0029 initialised over the junk: BASE 0 / WIDTH 127 for both send FX (the start-up defaults)",
          bw == bytes([0, 127, 0, 127]), bw.hex())
    check("dirty: 0029's labels, lists and caches (lab[], order, ulist) read zero", not any(mem["sfu_x"][:2080]),
          "lab[] not zero")
    check("dirty: 0029's extra-page names (sfu_p: xsh, xlng, np) and the full names (sfu_x: lng, lname) read zero",
          not any(mem["sfu_p"][:4240]) and not any(mem["sfu_x"][6706:7794]) and not any(mem["sfu_x"][7796:7932]),
          "a name table is not zero")
    check("dirty: the UI task ticked (0026 initialised: its st.init is 1)", e.st(s, "init") == 1)


def t_dirtyui(e):
    if not check("dirtyui: the build has the ten claims (the manifest's elek.buffers)", set(spans(e)) == set(BUFFERS), sorted(spans(e))):
        return
    c = card_copy(e, "ram-ui.img")
    host = [(1, "gone", 1000)]
    r = e.run("ram-ui", 11500, host, script=["--splash", "60"], cold=True, card=c, extra=pokes(e))
    frame = open(os.path.join(e.out, "ram-ui.frame"), "rb").read()
    s1 = R.spl(e, r["snap"])
    check("dirtyui: over junk, the splash shows and the panel is the host's frame byte for byte (every buffer on the "
          "frame path works from the init's zeros)", s1["splash_on"] == 1 and r["oled"] == frame,
          f"{s1}, {sum(a != b for a, b in zip(r['oled'] or b'', frame))} bytes differ")
    left = 0
    m = readback(e, r["snap"])
    for n in ("rui_comp_in", "rui_txt_tl"):
        lo = spans(e)[n][0]
        left += sum(int.from_bytes(m[n][i:i + 4], "big") == junk(lo + i) for i in range(0, len(m[n]), 4))
    check("dirtyui: no junk word in comp_in / txt_tl", not left, left)


WATCH_RE = re.compile(r"^watch: pc=([0-9a-f]+) \[([0-9a-f]+)\]\.(\d+) <- ([0-9a-f]+)$")
TAIL = 24   # the watched tail of a claim: its last 24 bytes (the 12 `dirty` skips, and the 12 before them)


def watch_hits(out):
    """dtboot's `watch:` lines (the first 40 hits, in order) as (pc, addr, size, value)"""
    return [(int(m[1], 16), int(m[2], 16), int(m[3]), int(m[4], 16))
            for m in map(WATCH_RE.match, out.splitlines()) if m]


def watched_boot(e, name, card, lo, n):
    """a cold boot over junk in every claim, with a read/write watch over [lo, lo + n): the hits, in order"""
    c = card + "." + name
    os.system(f"cp -c '{card}' '{c}'")
    try:
        r = e.run(name, 11500, [], cold=True, card=c, extra=pokes(e) + ["--watch-read", f"{lo:x}", str(n)], save=False)
    finally:
        os.remove(c)   # (also after an EmuTimeout: no clone of the card left behind)
    return watch_hits(r["out"])


def t_first(e):
    """check 2, direct: over junk, the first access to each claim is its zeroing write (a 4-byte write of 0, not a read
    of a junk word, which would show the junk), and so is the first access to each word of its last 24 bytes (the last
    12 are what `dirty` skips); 0026's claims are exactly sized, so all six tail words are zeroed; sfu_x's claim is
    rounded up by the registry (12 bytes beyond the struct), so its tail words 12..24 from the end are"""
    sp = spans(e)
    if not check("first: the build has the ten claims (the manifest's elek.buffers)", set(sp) == set(BUFFERS), sorted(sp)):
        return
    card = card_copy(e, "ram-first.img")
    jobs = [(n, kind) for n in sorted(sp) for kind in ("claim", "tail")]

    def one(job):
        n, kind = job
        lo, hi = sp[n]
        wl, wn = (lo, hi - lo) if kind == "claim" else (hi - TAIL, TAIL)
        try:
            return job, watched_boot(e, f"ram-first-{n}-{kind}", card, wl, wn)
        except R.EmuTimeout:
            return job, None
    with ThreadPoolExecutor(max_workers=int(os.environ.get("RAM_EMU_JOBS", "2"))) as ex:   # emulator processes at once: RAM_EMU_JOBS, default 2
        res = dict(ex.map(one, jobs))
    for n in sorted(sp):
        lo, hi = sp[n]
        h = res[(n, "claim")]
        if h is None:
            continue
        check(f"first: {n}: the first access to the claim is a zeroing write ({len(h)} hits seen, up to 40 logged)",
              bool(h) and all(lo <= a < hi and sz == 4 and v == 0 for _, a, sz, v in h), h[:2])
        t = res[(n, "tail")]
        if t is None:
            continue
        first = {}
        for _, a, sz, v in t:
            first.setdefault(a & ~3, (sz, v))
        words = [hi - TAIL + 4 * i for i in range(TAIL // 4)]
        want = words[:3] if n == "sfu_x" else words   # (sfu_p's claim is its struct's size)
        check(f"first: {n}: the first access to each of its last {len(want)} tail words is a zeroing write",
              all(w in first and first[w] == (4, 0) for w in want) and all(f == (4, 0) for f in first.values()),
              {f"{w:08x}": first.get(w) for w in words})


TESTS = dict(region=t_region, dirty=t_dirty, dirtyui=t_dirtyui, first=t_first)


def main():
    if len(sys.argv) == 3 and sys.argv[1] == "--pokes":   # us_base.sh's dirty base: build/manifest_TAG.json's claims
        m = json.load(open(os.path.join(R.ROOT, "build", f"manifest_{sys.argv[2]}.json")))
        print(" ".join(pokes_of(m["elek"]["buffers"])))
        return
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    e = R.Emu(sys.argv[1])
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    for n in names:
        print(f"== {n}", flush=True)
        try:
            TESTS[n](e)
        except R.EmuTimeout as ex:
            print(f"  {ex} (the test is abandoned)", flush=True)
    print("ALL PASS" if not R.FAILS else f"FAILED: {R.FAILS}")
    sys.exit(1 if R.FAILS else 0)


if __name__ == "__main__":
    main()
