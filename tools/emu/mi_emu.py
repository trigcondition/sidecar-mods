#!/usr/bin/env python3
"""Emulator tests of the MIDI machine (backlog 7o; rytm-teensy core/midim/midim.h): machine 50 (0021 ext_render, 0026's labels), its reports 44 / 43,
0026's 4F to the DIN port, in rytm-emu, no Sidecar.

    RYTM_EMU=... RYTM_TEENSY=... .venv/bin/python tools/emu/mi_emu.py TAG TEST [TEST ...]|all

TAG: a rui build with its base from tools/emu/us_base.sh TAG. Every run under DTEMU_STRICT=1 (pc_emu.py's Emu). DIN bytes: dtboot --midi-out.
"""
import os
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pc_emu as PC   # noqa: E402
import cu_emu as CU   # noqa: E402

FAILS = PC.FAILS
check = PC.check
DOWNS = 29            # the machine list from BD PLASTIC: DISABLE 14 .. LIVE IN 27, CHOP 28, MIDI 29, DAISYSP 30, MULTISAMP 31
SRC = ["DST", "CHAN", "BANK", "SBNK", "PROG", "PB", "AT", "MW"]
P2 = ["VAL1", "VAL2", "VAL3", "VAL4", "SEL1", "SEL2", "SEL3", "SEL4"]
DEFAULTS = [32, 0, 0, 0, 0, 0, 0, 0]
SX = bytes.fromhex("f07d5254")


def din(*b):
    return SX + bytes([0x4F, 1]) + bytes(b) + b"\xf7"


def din_out(e, name, ms, events, snap, **kw):
    f = os.path.join(e.out, f"mi_{name}.midi")
    if os.path.exists(f):
        os.remove(f)
    r = e.run(name, ms, events, snap=snap, extra=["--midi-out", f], **kw)
    return r, open(f, "rb").read() if os.path.exists(f) else b""


def rep(r, cmd):
    return [x for x in r["sysex"] if len(x) >= 7 and x[4] == cmd]


S = {}


def base(e):
    if "s" not in S:
        S["s"] = CU.nm(e, 50, DOWNS)
    return S["s"]


def t_list(e):
    """The list reaches MIDI; its records, group, ids and defaults; both pages' labels; a pad's report is 44, not 04, its voice byte plain."""
    s0 = base(e)
    s = s0[0]
    got = [CU.label(e, s, x) for x in CU.SRC]
    check("list: SRC records' short names", got == SRC, got)
    check("list: group MIDI", CU.label(e, s, CU.SRC[0], 0x2c) == "MIDI")
    check("list: the records' machine field 50", all(CU.u32(e, s, CU.rec(x)) == 50 for x in CU.SRC))
    ids = [CU.u32(e, s, 0x413DB5FC + 4 * (m * 8 + k)) for m in (50, 52) for k in range(8)]
    check("list: sound_param_id_for_index's ids", ids[:8] == ids[8:] and ids[0] != 0, ids)
    k = CU.kit16(e, s)
    check("list: the choice set P1..P8 to the defaults", k[:8] == DEFAULTS, k[:8])
    check("list: and P9..P16 to page 2's, zero (not the sample page's words)", k[8:16] == [0] * 8, k[8:16])
    e.run("mi_src", 1500, [(300, "press", "SRC")], snap=s0, usb=False)
    print(f"  look at build/emu/{e.tag}/pc_mi_src.png")
    r = e.run("mi_smpl", 2500, [(300, "press", "SMPL"), (1200, "press", "BD", 400)], snap=s0)
    s2 = r["snap"][0]
    got = [CU.label(e, s2, x) for x in CU.P2]
    check("list: SMPL records' short names", got == P2, got)
    t = rep(r, 0x44)
    check("list: the pad: 44, voice byte 0, P1 DST 32", bool(t) and t[0][5] == 0 and t[0][8] == 32, t[0].hex() if t else "none")
    check("list: no 04 for it", not rep(r, 0x04))
    check("list: the pad's release: 11", bool(rep(r, 0x11)))
    print(f"  look at build/emu/{e.tag}/pc_mi_smpl.png")
    # the 33 the host goes by
    r = e.run("mi_33", 1500, [(300, "press", "NO")], snap=s0)
    print(f"  33s: {[x.hex() for x in r['sysex'] if x[4] == 0x33][:2]}")


def t_steps(e):
    """DST's stepped knob: OFF DIN USBC USBA; CHAN 16 steps; a plain knob's word."""
    ev = [(300, "press", "SRC"), (900, "turn", "0:5", 16, 30), (1800, "turn", "1:5", 8, 40), (2500, "turn", "4:5", 12, 40)]
    r = e.run("mi_knobs", 4000, ev, snap=base(e), usb=False)
    k = CU.kit16(e, r["snap"][0])
    print(f"  words {k[:8]}")
    check("steps: DST two steps up from DIN: USBA's zone (96)", k[0] == 96, k[:8])
    check("steps: CHAN moved by zones of 8", k[1] % 8 == 0 and k[1] > 0, k[:8])
    check("steps: PROG a plain value", k[4] > 0, k[:8])
    print(f"  look at build/emu/{e.tag}/pc_mi_knobs.png: DST USBA")


def t_din(e):
    """4F: note on and off, a CC, a bend, a program and touch (two bytes), on the DIN port, byte for byte, in order."""
    ev = [(300, "usb", din(0x10, 60, 100)), (500, "usb", din(0x31, 7, 99)), (700, "usb", din(0x63, 0, 64)),
          (900, "usb", din(0x42, 5)), (1100, "usb", din(0x53, 77)), (1300, "usb", din(0x00, 60, 0))]
    r, b = din_out(e, "din", 2000, ev, e.base)
    want = bytes.fromhex("903c64 b10763 e30040 c205 d34d 803c00")
    check("din: the bytes on MIDI OUT", want in b or b == want, b.hex())


def t_dinbad(e):
    """Malformed 4F: nothing sent, the rest unharmed."""
    ev = [(300, "usb", din(0x10, 60)), (400, "usb", din(0x42, 5, 9)), (500, "usb", din(0x70, 1, 1)), (600, "usb", din(0x10, 61, 100))]
    r, b = din_out(e, "dinbad", 1500, ev, e.base)
    check("dinbad: only the good one", b == bytes.fromhex("903d64"), b.hex())


def t_dinburst(e):
    """1000 messages at once, more than the wire carries: no fault, no spin, the MIDI task lives (a later note arrives). Up to the ring goes out, the rest dropped."""
    burst = b"".join(din(0x10, n % 128, 100) for n in range(1000))
    ev = [(300, "usb", burst), (2500, "usb", din(0x00, 1, 0))]
    r, b = din_out(e, "dinburst", 6000, ev, e.base)
    print(f"  {len(b)} bytes out of {3 * 1000 + 3}")
    check("dinburst: most of it went out", len(b) >= 3000, len(b))
    check("dinburst: the wire still works", b.endswith(bytes.fromhex("800100")), b[-6:].hex())


def t_dinshed(e):
    """A ring short of room, its pending count poked (one message a run: the DMA then takes the poked count with it): values are shed first, then
    note-ons; a note-off still goes."""
    cc, on, of = din(0x30, 7, 99), din(0x10, 60, 100), din(0x00, 60, 0)
    wcc, won, wof = bytes.fromhex("b00763"), bytes.fromhex("903c64"), bytes.fromhex("803c00")
    for pend, m, want, sent in ((3000, cc, wcc, False), (3000, on, won, True), (3800, on, won, False), (3800, of, wof, True), (4040, of, wof, True)):
        f = os.path.join(e.out, "mi_dinshed.midi")
        if os.path.exists(f):
            os.remove(f)
        e.run("dinshed", 1000, [(300, "usb", m)], snap=e.base, extra=["--midi-out", f, "--poke", f"413da678={pend:08x}"])
        b = open(f, "rb").read() if os.path.exists(f) else b""
        check(f"dinshed: {pend} B pending, {want.hex()} {'goes' if sent else 'shed'}", (want in b) == sent, len(b))


def t_play(e):
    """A sequencer trig on BD with a value lock: 44 at each step with the lock, the note-off at LEN or STOP; STOP sends 11 with an open gate."""
    ev = [(300, "press", "RECORD"), (500, "press", "T1"), (900, "press", "RECORD"),
          (1200, "press", "PLAY"), (6000, "press", "STOP")]
    r = e.run("mi_play", 8000, ev, snap=base(e))
    t, o = rep(r, 0x44), rep(r, 0x11)
    print(f"  44s {len(t)} 11s {len(o)}")
    check("play: the trig plays as 44", len(t) >= 2, len(t))
    check("play: as many note-offs as trigs or one less at most before STOP's", len(o) >= len(t), (len(t), len(o)))
    check("play: no 04", not rep(r, 0x04))
    # the order: after the last 44 a 11 follows
    seq = [x[4] for x in r["sysex"] if x[4] in (0x44, 0x11)]
    check("play: the last of them is a 11 (nothing left open)", seq[-1] == 0x11, seq[-6:])


def t_lock(e):
    """A p-lock on PROG (knob E): the step's 44 carries it, the next without: the base."""
    ev = [(300, "press", "SRC"), (500, "press", "RECORD"), (700, "press", "T1"), (900, "press", "T5"),
          (1100, "press", "T1", 900), (1300, "turn", "4:5", 6, 40), (2300, "press", "RECORD"),
          (2600, "press", "PLAY"), (7000, "press", "STOP")]
    r = e.run("mi_lock", 8500, ev, snap=base(e))
    t = rep(r, 0x44)
    vals = [x[8 + 2 * 4] for x in t]
    print(f"  PROG at the trigs: {vals}")
    check("lock: PROG locked on one step, the base on the other", len(set(vals)) == 2 and 0 in vals, vals)


def t_kit(e):
    """Pattern A02 (another kit): 3B and 33 go out, which the host's note-offs hang on."""
    ev = [(1000, "press", "BANK_A", 600), (1200, "press", "T2")]
    r = e.run("mi_kit", 3000, ev, snap=base(e))
    k = [x for x in r["sysex"] if x[4] == 0x3B]
    m = [x for x in r["sysex"] if x[4] == 0x33]
    check("kit: 3B says kit 1", any(x[6] == 1 for x in k), [x.hex() for x in k])
    check("kit: 33 says BD is no longer 50", bool(m) and any(x[8] != 50 for x in m if x[6] == 0), [x.hex() for x in m][:3])


def t_saved(e):
    """Chosen, DST moved, the power goes, a cold boot: BD still machine 50 with its words."""
    tmp = tempfile.mkdtemp()
    c = os.path.join(tmp, "saved.img")
    import subprocess
    subprocess.run(["cp", "-c", os.path.join(PC.EMU, e.card), c], check=True)
    keys = ["SRC", "SRC"] + ["DOWN"] * DOWNS + ["YES", "SRC"]
    ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)]
    n = 500 + 500 * len(keys)
    ev += [(n, "turn", "0:5", 8, 40), (n + 500, "turn", "4:5", 7, 40)]
    pw = e.base[1] + (n + 2500) // 5
    r = e.run("mi_saved", n + 3000, ev, extra=["--card", c, "--power-off", f"{pw}M"], usb=False)
    r = e.run("mi_boot", 22000, cold_card=c, usb=False)
    s = r["snap"][0]
    w = CU.kit16(e, s)
    got = e.peek(s, 0x4125590D + 104, 1)[0]
    print(f"  machine {got} words {w[:8]}")
    check("saved: BD is machine 50 after the cold boot", got == 50, got)
    check("saved: its words", w[0] > 32 and w[4] > 0, w[:8])   # (DST and PROG as turned)


def t_choose(e):
    """Choosing MIDI with the sequencer running: the list's preview makes no MIDI, nothing goes out with the words the machine has not set yet (the sample
    page's stock words would be CC numbers): after YES the first 44s carry P9..P16 zero."""
    keys = ["SRC", "SRC"] + ["DOWN"] * DOWNS
    ev = [(300, "press", "RECORD"), (500, "press", "T1"), (700, "press", "T5"), (900, "press", "T9"), (1100, "press", "T13"), (1300, "press", "RECORD"),
          (1500, "press", "PLAY")]
    ev += [(2000 + 300 * i, "press", k) for i, k in enumerate(keys)]
    y = 2000 + 300 * len(keys) + 1500
    ev += [(y, "press", "YES"), (y + 3000, "press", "STOP")]
    r = e.run("mi_choose", y + 3500, ev)
    t = rep(r, 0x44)
    bad = [x.hex() for x in t if any(x[8 + 16 + 2 * k] for k in range(8))]
    print(f"  44s {len(t)}, with stale words {len(bad)}")
    check("choose: the sequencer played the machine after YES", len(t) >= 2, len(t))
    check("choose: no 44 with the sample page's words", not bad, bad[:2])
    b = [x for x in r["sysex"] if len(x) >= 7 and x[4] == 0x43]
    bad = [x.hex() for x in b if any(x[6 + 16 + 2 * k] for k in range(8))]
    check("choose: no 43 with them either", not bad, bad[:2])


def t_sound(e):
    """MIDI chosen in the SOUND menu (FUNC + FLTR, its MACHINE item): a choice as the list's: page 2's words zero, nothing reported before them. Reached from
    MULTISAMPLE with SEL words set, the stepped route that does not cross 42: without the choice P9..P16 stayed and each trig sent CCs on DIN."""
    s0 = CU.nm(e, 52, DOWNS + 2)
    r = e.run("mi_snd0", 3000, [(300, "press", "SMPL"), (1000, "turn", "4:5", 16, 40), (1800, "turn", "5:5", 16, 40)], snap=s0, usb=False)
    s1 = r["snap"]
    k = CU.kit16(e, s1[0])
    print(f"  before: {k}")
    check("sound: MULTISAMPLE's words on P13, P14", k[12] or k[13], k)
    ev = [(300, "press", "FUNC", 1500), (400, "press", "FLTR")]   # (LEFT: the list's order: MIDI two before MULTISAMPLE)
    ev += [(2500 + 600 * i, "press", x) for i, x in enumerate(["LEFT", "LEFT"])]
    ev += [(4000, "press", "NO"), (6000, "press", "BD", 400), (7000, "press", "BD", 400)]
    r = e.run("mi_snd1", 8000, ev, snap=s1)
    s = r["snap"][0]
    got, k = e.peek(s, 0x8000EA00, 1)[0], CU.kit16(e, s)
    print(f"  machine {got}, words {k}")
    check("sound: the menu chose MIDI", got == 50, got)
    check("sound: P1..P8 the defaults", k[:8] == DEFAULTS, k[:8])
    check("sound: P9..P16 page 2's, zero", k[8:16] == [0] * 8, k[8:16])
    t = rep(r, 0x44)
    check("sound: the trigs reported", len(t) >= 1, len(t))
    bad = [x.hex() for x in t + rep(r, 0x43) if any(x[(8 if x[4] == 0x44 else 6) + 16 + 2 * n] for n in range(8))]
    check("sound: no report with SEL words", not bad, bad[:2])


def t_sv2a(e):
    """2A with the SRC view open: nothing with the old machine's words while MIDI is being set up (the host feeds a 2A to the machine, as CCs on DIN): from
    the moment 33 says MIDI to the settled defaults, no 2A carries a nonzero SEL."""
    s0 = CU.nm(e, 52, DOWNS + 2)
    r = e.run("mi_2a0", 3000, [(300, "press", "SMPL"), (1000, "turn", "4:5", 16, 40), (1800, "turn", "5:5", 16, 40), (2500, "press", "SRC")], snap=s0, usb=False)
    open3a = (SX + bytes([0x3A, 1, 0, 1, 0xF7]))
    keys = ["SRC", "SRC"] + ["UP"] * 2 + ["YES"]
    ev = [(100, "usb", open3a)] + [(800 + 400 * i, "press", k) for i, k in enumerate(keys)]
    r = e.run("mi_2a1", 7000, ev, snap=r["snap"])
    s = r["snap"][0]
    got = e.peek(s, 0x8000EA00, 1)[0]
    check("sv2a: the list chose MIDI", got == 50, got)
    i33 = [i for i, x in enumerate(r["sysex"]) if len(x) >= 11 and x[4] == 0x33 and x[8] == 50]
    check("sv2a: 33 said MIDI", bool(i33), len(r["sysex"]))
    after = [x for x in r["sysex"][i33[-1]:] if len(x) >= 10 and x[4] == 0x2A] if i33 else []
    print(f"  33 at {i33}, 2As after it {[x.hex() for x in after][:4]}")
    bad = []
    for x in after:
        first, n = x[7], x[8]
        bad += [x.hex() for w in range(n) if first + w >= 12 and (x[9 + 2 * w] or x[10 + 2 * w])]
    check("sv2a: no 2A with the old SEL words", not bad, bad[:2])
    check("sv2a: the view gets MIDI's words after", any(x[7] <= 8 and x[7] + x[8] > 12 for x in after), [x.hex() for x in after][:3])


TESTS = dict(sound=t_sound, sv2a=t_sv2a, choose=t_choose, list=t_list, steps=t_steps, din=t_din, dinbad=t_dinbad, dinburst=t_dinburst, dinshed=t_dinshed, play=t_play, lock=t_lock, kit=t_kit, saved=t_saved)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    e = PC.Emu(sys.argv[1])
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    for n in names:
        print(f"== {n}", flush=True)
        TESTS[n](e)
    print("ALL PASS" if not FAILS else f"FAILED: {FAILS}")
    sys.exit(1 if FAILS else 0)


if __name__ == "__main__":
    main()
