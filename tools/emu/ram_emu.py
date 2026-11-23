#!/usr/bin/env python3
"""Emulator tests of big-ram (mods/0026-remote-ui/design.md "big-ram"): the DDR claims outside elekloader's area are
zeroed and sealed at the first tick, and a changed sentinel makes the mod stop using its claim safely.

    .venv/bin/python tools/emu/ram_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: an OS 1.74 build of the Sidecar set with the DDR claims (registry [[ddr]]), whose base tools/emu/us_base.sh TAG
made; RYTM_EMU, RYTM_TEENSY as rui_emu.py (its Emu and the host sim/remote_ui.py). A damage is a --poke of one
sentinel word (the claim's first) before a run; DTEMU_STRICT=1 throughout.
    sealed   the base: every claim's 4 sentinel words are 'RAMS' ^ address, ram_ok 7 (0026), x_ok 1 (0029), none bad
    frame    the remote page open (TRK + YES, the host streaming), then rui_frame's sentinel changed: the page leaves
             with reason 4 (R_RAM), ram_ok loses bit 1 only, the report (55 01 00) goes out, the host's 38 / 39 are
             dropped from then on, the screen is the stock one with MOD RAM ERROR (not the host's frame), TRK + YES
             does not open the page again; no fault, no strict access
    pmo      rui_pmo's sentinel changed while playing: ram_ok loses bit 4 only, the param modulation's interrupt entries
             stop (pmo's counters stay), the audio interrupt runs on (no fault)
    names    rui_names's sentinel changed: bit 2 only; the source names stop, no fault
    sfux     0029's sfu_x sentinel changed, then the SEND FX 1 page and turns of its knobs: x_ok 0, x_bad 8, the report
             sent, the turns refused (x_drops), the FX words 38..41 unchanged, no fault
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rui_emu as R   # noqa: E402

check = R.check
RAMS = 0x52414D53
CLAIMS = {}   # name -> (addr, size), from the manifest


def sym(e, mod, name):
    return e.syms[f"rytm-{mod}:{name}"]


def word(e, snap, a):
    return int.from_bytes(e.peek(snap, a, 4), "big")


def u(e, snap, mod, name):
    return word(e, snap, sym(e, mod, name))


def flags(e, snap):
    return dict(ram_ok=u(e, snap, "0026-remote-ui", "ram_ok"), ram_bad=u(e, snap, "0026-remote-ui", "ram_bad"),
                rep=u(e, snap, "0026-remote-ui", "ram_rep_sent"), drops=u(e, snap, "0026-remote-ui", "ram_drops"),
                x_ok=u(e, snap, "0029-sendfx-ui", "x_ok"), x_bad=u(e, snap, "0029-sendfx-ui", "x_bad"),
                x_rep=u(e, snap, "0029-sendfx-ui", "x_rep_sent"), x_drops=u(e, snap, "0029-sendfx-ui", "x_drops"))


def run_from(e, name, ms, events, load, t0, poke=(), script=None):
    """e.run from another snapshot (load, its clock e.clock + t0 ms), with pokes before it."""
    snap0, clock0 = e.snap, e.clock
    try:
        e.snap, e.clock = load, clock0 + t0 / 5
        return e.run(name, ms, events, script=script, extra=[x for a, v in poke for x in ("--poke", f"{a:x}={v:x}")])
    finally:
        e.snap, e.clock = snap0, clock0


def t_sealed(e):
    s = os.path.join(R.EMU, e.snap)
    want = {"rui_frame", "rui_names", "rui_pmo", "sfu_x"}
    have = all(f"rytm-{m}:{n}" in e.syms for m, n in (("0026-remote-ui", "ram_ok"), ("0029-sendfx-ui", "x_ok")))
    check("sealed: the build keeps 0026 / 0029's buffers in DDR claims outside elekloader's area (manifest ddr)",
          set(CLAIMS) == want and have and all(not 0x47BE0000 <= a < 0x47C00000 for a, _ in CLAIMS.values()),
          sorted(CLAIMS))
    if set(CLAIMS) != want or not have:
        return
    for n, (a, z) in sorted(CLAIMS.items()):
        ws = [word(e, s, a), word(e, s, a + 4), word(e, s, a + z - 8), word(e, s, a + z - 4)]
        want = [RAMS ^ a, RAMS ^ (a + 4), RAMS ^ (a + z - 8), RAMS ^ (a + z - 4)]
        check(f"sealed: {n}'s four sentinel words are 'RAMS' ^ address", ws == want, [hex(x) for x in ws])
    f = flags(e, s)
    check("sealed: ram_ok 7, x_ok 1, nothing bad", f["ram_ok"] == 7 and f["x_ok"] == 1 and not f["ram_bad"]
          and not f["x_bad"], f)


def t_frame(e):
    """One run with rui_emu's host (remote_ui.py streaming frames, logging the 30s): TRK + YES opens the page, 2 s later
    rui_frame's first sentinel flips (0026's ram_test hook), then TRK + YES again."""
    a = CLAIMS["rui_frame"][0]
    t, ta = sym(e, "0026-remote-ui", "ram_test"), sym(e, "0026-remote-ui", "ram_test_at")
    ev = R.ENTER + [(3500, "press", "TRK", 300), (3600, "press", "YES")]
    r = e.run("ram-frame", 4500, ev, script=[], extra=["--poke", f"{t:x}=40", "--poke", f"{ta:x}={a:x}"])
    f = flags(e, r["snap"])
    modes = [(m["on"], m["reason"]) for m in R.evs(r, "mode")]
    check("frame: the page opened (user), then left with reason 4 (R_RAM), never opened again",
          modes in ([(1, "user"), (0, 4)], [(1, "user"), (0, "ram")]), modes)   # ("ram": a host sim that names reason 4)
    check("frame: inactive at the end", e.st(r["snap"], "active") == 0)
    check("frame: ram_ok lost bit 1 only (6), ram_bad 1", f["ram_ok"] == 6 and f["ram_bad"] == 1, f)
    check("frame: the damage report sent (55 01 00 01: ram_rep_sent 1), the first bad address rui_frame's sentinel",
          f["rep"] == 1 and u(e, r["snap"], "0026-remote-ui", "ram_bad_at") == a, f)
    frame = os.path.join(e.out, "ram-frame.frame")
    fr = open(frame, "rb").read() if os.path.exists(frame) else b""
    check("frame: the panel no longer shows the host's frame", r["oled"] is not None and r["oled"] != fr)
    print(f"    flags {f}; host commits {len(R.evs(r, 'commit'))}")


def t_pmo(e):
    a = CLAIMS["rui_pmo"][0]
    s0 = os.path.join(R.EMU, e.snap)
    runs0 = word(e, s0, sym(e, "0026-remote-ui", "pmo") + 24)   # pmo.runs (6th word)
    r = e.run("ram-pmo", 2000, [(100, "press", "PLAY"), (1800, "press", "STOP")],
              extra=["--poke", f"{a:x}=0"])
    f = flags(e, r["snap"])
    check("pmo: ram_ok lost bit 4 only (3), ram_bad 4", f["ram_ok"] == 3 and f["ram_bad"] == 4, f)
    runs1 = word(e, r["snap"], sym(e, "0026-remote-ui", "pmo") + 24)
    check("pmo: the interrupt's pmo_pre stopped within a tick of the damage (<= 100 of the run's ~3000 blocks)",
          runs1 - runs0 <= 100, f"{runs0} -> {runs1}")
    print(f"    flags {f}")


def t_names(e):
    a = CLAIMS["rui_names"][0]
    r = e.run("ram-names", 1000, [], extra=["--poke", f"{a:x}=0"])
    f = flags(e, r["snap"])
    check("names: ram_ok lost bit 2 only (5), ram_bad 2", f["ram_ok"] == 5 and f["ram_bad"] == 2, f)


def t_sfux(e):
    """With sfu_emu's own harness (us_emu.Emu: the Rytm's USB MIDI out in .sent), its "pages" turns."""
    import sfu_emu as S
    u = S.U.Emu(e.tag)
    a = CLAIMS["sfu_x"][0]
    words = lambda s: (S.w16(u, s, S.SND0), [S.w16(u, s, S.FXW + 2 * i) for i in (29, 38, 39, 40, 41)])   # noqa: E731
    ev = [(50, "press", "AMP"), (150, "press", "AMP"), (300, "turn", ("0:+20", 5, 20)), (450, "turn", ("1:+20", 3, 20)),
          (600, "press", "FX"), (700, "press", "SRC"), (850, "turn", ("0:+20", 2, 20)), (950, "turn", ("4:+20", 3, 20)),
          (1050, "turn", ("5:-20", 3, 20))]
    ctl = u.run("ram-sfux-ctl", 1300, ev, save=True)
    w_ctl = words(ctl)
    w0 = words(u.snap)
    sd = u.run("ram-sfux", 1300, ev, save=True, extra=["--poke", f"{a:x}=0"])
    f = flags(e, sd)
    check("sfux: (control, no damage: the same turns move SFX1 / SFX2 and the FX words)", w_ctl != w0, f"{w0} -> {w_ctl}")
    check("sfux: x_ok 0, x_bad 8 (0026's claims untouched: ram_ok 7)", f["x_ok"] == 0 and f["x_bad"] == 8 and
          f["ram_ok"] == 7, f)
    rep = [m for m in u.sent if bytes(m[:8]) == bytes([0xF0, 0x7D, 0x52, 0x54, 0x55, 0x01, 0x00, 0x08])]
    check("sfux: the damage report 55 01 00 08 <addr> <word> went out, the address sfu_x's first sentinel",
          len(rep) == 1 and len(rep[0]) == 19 and int.from_bytes(bytes([0]), "big") == 0 and
          sum(rep[0][8 + i] << (28 - 7 * i) for i in range(5)) == a, [bytes(m).hex() for m in rep])
    w1 = words(sd)
    check("sfux: SFX1 / SFX2 (BD's sound index 0) and the FX words 29, 38..41 unchanged by the turns", w1 == w0,
          f"{w0} -> {w1}")
    check("sfux: the turns on our records were refused (x_drops)", f["x_drops"] > 0, f)
    print(f"    flags {f}")


def t_diag(e):
    """The diagnostic image (ddrdiag=1) only: a canary word just ahead of the check's cursor changed before the run is
    found within a few ticks (512 B a tick) (dg.bad 1, its address and word kept, the canary written back), and the 10 s report
    55 01 01 <passes> <bad> <first address> <its word> <ram_ok> <ram_bad> carries it."""
    import us_emu as U
    ue = U.Emu(e.tag)
    dg = sym(e, "0026-remote-ui", "dg")
    s0 = os.path.join(R.EMU, e.snap)
    if not word(e, s0, dg):
        print("    (not a diagnostic image: skipped)")
        return
    pos = word(e, s0, dg + 4)
    bad_at = pos + 0x1000
    s = ue.run("ram-diag", 2200, [], save=True, extra=["--poke", f"{bad_at:x}=12345678"])
    w = [word(e, s, dg + 4 * i) for i in range(10)]
    check("diag: the changed word found: bad 1, its address and word", w[3] == 1 and w[4] == bad_at and
          w[5] == 0x12345678, [hex(x) for x in w])
    check("diag: the canary written back there", word(e, s, bad_at) == (bad_at ^ 0xC0DEF00D))
    rep = [bytes(m) for m in ue.sent if bytes(m[:7]) == bytes([0xF0, 0x7D, 0x52, 0x54, 0x55, 0x01, 0x01])]
    d = lambda m, o: sum(m[o + i] << (28 - 7 * i) for i in range(5))   # noqa: E731
    check("diag: the report (55 01 01, 30 B) says bad 1 at that address, ram_ok 7",
          rep and len(rep[-1]) == 30 and d(rep[-1], 12) == 1 and d(rep[-1], 17) == bad_at and rep[-1][27] == 7,
          [m.hex() for m in rep])


TESTS = dict(sealed=t_sealed, frame=t_frame, pmo=t_pmo, names=t_names, sfux=t_sfux, diag=t_diag)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    e = R.Emu(sys.argv[1])
    import json
    m = json.load(open(os.path.join(e.out, "manifest.json")))
    CLAIMS.update({c["name"]: (c["addr"], c["size"]) for c in m.get("ddr", [])})
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    for n in names:
        print(f"== {n}", flush=True)
        if n != "sealed" and (not CLAIMS or "rytm-0026-remote-ui:ram_ok" not in e.syms):
            check(f"{n}: the build has DDR claims (manifest ddr)", False, sorted(CLAIMS))
            continue
        TESTS[n](e)
    print("ALL PASS" if not R.FAILS else f"FAILED: {R.FAILS}")
    sys.exit(1 if R.FAILS else 0)


if __name__ == "__main__":
    main()
