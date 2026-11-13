#!/usr/bin/env python3
"""Emulator tests of 0026's param modulation (pm, 0.5.0): the host's 5A ops 04 OFFSET / 05 OVERRIDE / 06 CLEAR /
07 STATUS, the stage S around the audio interrupt's LFO call, the trig velocity detour (the
param-mod contract, mods/0026-remote-ui/design.md "pm").

    .venv/bin/python tools/emu/pm_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a rui build (tools/build_rui.sh) whose base tools/emu/us_base.sh TAG made. rui_emu.py's Emu runs each case under
DTEMU_STRICT=1 with --usb-host --usb-midi-real and rytm-teensy sim/remote_ui.py as the host (it logs the 2D 01
reports). Times are ms after the base snapshot (200 M instructions = 1 emulated second; 1 audio block = 32 frames =
0.667 ms). The arrays (the same SRAM addresses on 1.73 and 1.74): g = 26 + 42 t + w; the target 0x8000e57c (u16), the
smoother's state 0x8000ee84 (u32, value << 16), the effective 0x8000f774 (u16, 8.8).
The M0 probes (not in "all"): m0a m0c m0d m0e. RYTM_EMU, RYTM_TEENSY: the checkouts (defaults beside this one).
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rui_emu as R    # noqa: E402  (Emu, check, usb, states, the protocol module as R.P)

P = R.P
check = R.check
TARGET, STATE, EFF = 0x8000e57c, 0x8000ee84, 0x8000f774
TRIG_VEL = 0x800067c4         # u16 [13]: the last trig's velocity << 8
VM_ROUTES, AT_ROUTES = 0x8000ea3c, 0x8000ea4c   # + 32 t: 4 x {u16 amount, u16 g}
SCN_G, SCN_V, SCN_GATE = 0x8000ecac, 0x8000ed0c, 0x8000fce8
OP_OFF, OP_OVR, OP_CLR, OP_STAT = 4, 5, 6, 7
PM_STATUS = 0x11              # 2D 01 11: op 07's answer
CAPS_PM = 64
W_FRQ, W_RES, W_DEP, W_VOL = 30, 31, 8, 37


def g_of(t, w):
    return 26 + 42 * t + w


def u16(b, i=0):
    return int.from_bytes(b[i:i + 2], "big")


def s14(v):
    return v & 0x3fff


def off_msg(kit, ramp, recs):
    """04 OFFSET: recs [(t, w, v)] with v in 1/64 parameter step (-8192..8191)."""
    b = [OP_OFF, kit, ramp, len(recs)]
    for t, w, v in recs:
        v = s14(v)
        b += [t, w, v >> 7, v & 0x7f]
    return P._msg(P.HOST_CMD, b)


def ovr_msg(kit, ramp, recs):
    """05 OVERRIDE: recs [(t, w, v, mix, jump)] with v in 1/128 step (0..16383), mix 0..127."""
    b = [OP_OVR, kit, ramp, len(recs)]
    for t, w, v, mix, jump in recs:
        b += [t, w | (0x40 if jump else 0), (v >> 7) & 0x7f, v & 0x7f, mix]
    return P._msg(P.HOST_CMD, b)


def clr_msg(kit, ramp, mask):
    return P._msg(P.HOST_CMD, [OP_CLR, kit, ramp, mask & 0x7f, (mask >> 7) & 0x3f])


def stat_msg():
    return P._msg(P.HOST_CMD, [OP_STAT])


def usb(ms, m):
    return list(R.usb(ms, m))


def peekw(e, snap, addr, n=1):
    """n u16 words at addr"""
    b = e.peek(snap, addr, 2 * n)
    return [u16(b, 2 * i) for i in range(n)]


def eff(e, snap, t, w):
    return peekw(e, snap, EFF + 2 * g_of(t, w))[0]


def tgt(e, snap, t, w):
    return peekw(e, snap, TARGET + 2 * g_of(t, w))[0]


def state(e, snap, t, w):
    return int.from_bytes(e.peek(snap, STATE + 4 * g_of(t, w), 4), "big")


def peek_series(r, addr):
    """DTBOOT_PEEK's words at each status line: [(clock M, u32)]"""
    out, clk = [], None
    for line in r["out"].splitlines():
        m = re.match(r"^\s*(\d+)M pc=", line)
        if m:
            clk = int(m.group(1))
            continue
        x = re.search(rf"\[{addr:08x}\]=([0-9a-f]{{8}})", line)
        if x and clk is not None and line.lstrip().startswith("peek"):
            out.append((clk, int(x.group(1), 16)))
    return out


def acks(r):
    return [b for t, b in R.states(r, P.HOST_ACK)]


def stats(r):
    return [b for t, b in R.states(r, PM_STATUS)]


# ---- M0 probes (answers in the param-mod contract's "M0 answers")

def m0d(e):
    """The 0x33 machine number -> the ROM parameter records of its synth words 9..16 (SPID 0x40007028's table
    0x413db5fc: 4 x (8 m + w - 9)), the record's label (rec + 48 -> a C string), on the base snapshot."""
    snap = os.path.join(R.EMU, e.snap)
    tab = e.peek(snap, 0x413db5fc, 53 * 8 * 4)
    rom = open(os.path.join(R.ROOT, "build", "stock_mainos.bin"), "rb").read()   # the tree's OS (1.73)
    rd = lambda a, n: rom[a - 0x40000400:a - 0x40000400 + n]   # noqa: E731
    cstr = lambda a: rd(a, 16).split(b"\0")[0].decode("latin1") if 0x40000400 <= a < 0x40000400 + len(rom) else "?"   # noqa: E731
    for m in range(53):
        recs = [int.from_bytes(tab[4 * (8 * m + k):4 * (8 * m + k) + 4], "big") for k in range(8)]
        nm = cstr(int.from_bytes(rd(0x401befa4 + 8 * m, 4), "big"))
        labs = [cstr(int.from_bytes(rd(0x401bf918 + 0x34 * r + 48, 4), "big")) if r else "--" for r in recs]
        print(f"    m{m:2d} {nm:16s} recs {recs} {labs}")


PLOCK_FRQ = [(50, "press", "FLTR"), (300, "press", "RECORD"), (550, "press", "T1", 1100), (1000, "turn", "4:-8", 5, 50),
             (1700, "press", "T5"), (1800, "press", "RECORD")]   # GRID REC, T1 held, knob E (FRQ) -40: a lock on step 1, then GRID REC off


def m0a(e):
    """M0a: with a Rytm p-lock on BD FRQ (step 1), does the smoother's state hold the lock for the whole step? Every
    1 ms: state[g] (u32), eff (u16 pair), target (u16 pair), and the trig apply's extra write 9 words below g."""
    g = g_of(0, W_FRQ)
    a_st, a_eff, a_tg, a_x = STATE + 4 * g, (EFF + 2 * g) & ~3, (TARGET + 2 * g) & ~3, (TARGET + 2 * (g - 9)) & ~3
    r = e.run("m0a", 3500, PLOCK_FRQ + [(2100, "press", "PLAY"), (3400, "press", "STOP")], script=None,
              extra=["--every", "0.2M"], env=dict(DTBOOT_PEEK=",".join(f"{a:x}" for a in (a_st, a_eff, a_tg, a_x))))
    st, ef, tg, x = ([v for c, v in peek_series(r, a)] for a in (a_st, a_eff, a_tg, a_x))
    sh = 16 if g % 2 == 0 else 0
    prev = None
    for i, row in enumerate(zip(st, ef, tg, x)):
        row = (row[0] >> 16, row[1] >> sh & 0xffff, row[2] >> sh & 0xffff, row[3])
        if prev is None or row[2:] != prev[2:] or abs(row[0] - prev[0]) > 0x80 or i % 100 == 0:
            print(f"    {i * 1.0:7.1f} ms  state {row[0]:04x}  eff {row[1]:04x}  target {row[2]:04x}  x {row[3]:08x}")
            prev = row


def m0c(e):
    """M0c: the route amount's scaling. Track 0's VELOCITY MOD route 1 poked to {amount A, g FRQ} (the runtime copy;
    the sound load rebuilds it, none happens here), BD played from its pad: eff FRQ = target - f(velocity, A). And the
    sound's stored amounts (sound + 0x70, 3 B a route: u16 amount, s8 word) as the loader copies them verbatim."""
    snap0 = os.path.join(R.EMU, e.snap)
    snd = e.peek(snap0, 0x4125590d + 0x70, 24)
    print(f"    BD sound +0x70 (VM) {snd[:12].hex()}  +0x8c (AT) {e.peek(snap0, 0x4125590d + 0x8c, 12).hex()}")
    print(f"    runtime VM {e.peek(snap0, VM_ROUTES, 16).hex()}  AT {e.peek(snap0, AT_ROUTES, 16).hex()}")
    for amt in (0x4000, 0x1000, 0x7f00, 0xc000):
        r = e.run(f"m0c-{amt:04x}", 900, [(300, "press", "BD")], script=None,
                  extra=["--poke", f"{0x4125590d + 0x70:x}={amt:04x}{W_RES:02x}00"])
        v = peekw(e, r["snap"], TRIG_VEL)[0]
        print(f"    amount {amt:04x}: trig_velocity {v:04x}  RES target {tgt(e, r['snap'], 0, W_RES):04x}  "
              f"eff {eff(e, r['snap'], 0, W_RES):04x}  route {e.peek(r['snap'], VM_ROUTES, 4).hex()}")

# ---- the tests (design rytm-param-mod.md 6.1: M1..M13)

ACTIVE_KIT = 0x800067b8
SOUND0 = 0x4125590d             # kit 0, track 0's sound (+ 2531 a kit, + 152 a track): machine +104, VM +0x70, AT +0x8c
T0 = 1500                       # ms: the first message (after the base's hellos and the host's answers)


def kit_of(e, snap=None):
    return int.from_bytes(e.peek(snap or os.path.join(R.EMU, e.snap), ACTIVE_KIT, 4), "big") & 127


def sound(e, snap, t=0, k=None):
    k = kit_of(e, snap) if k is None else k
    return e.peek(snap, SOUND0 + 2531 * k + 152 * t, 152)


def pmo(e, snap):
    """0026's pmo diagnostics (rui.c "pm"), None on a build without them"""
    try:
        a = e.sym("pmo")
    except KeyError:
        return None
    b = e.peek(snap, a, 64)
    w = lambda o: int.from_bytes(b[o:o + 4], "big")   # noqa: E731
    return dict(used=w(0), ring_drop=w(4), kit_drop=w(8), timeouts=w(12), full=w(16), refused=w(20), runs=w(24),
                recs=w(28), clears=w(32), t_max=w(36), t_sum=w(40), t_n=w(44), vel_n=w(48), scn_skips=w(52))


# pmo's fields past the counters (rui.c, a _Static_assert there keeps them): the ring's indices and records
PMO_RH, PMO_RT, PMO_HELLO_N, PMO_SMASK, PMO_RING = 56, 80, 68, 512, 1416
PMO_IDX, PMO_ENT, PMO_ENT_SZ, PMO_LINK_DROP = 584, 3464, 44, 9228   # idx[13][64] (slot + 1), ent[128]: {tp1, w, n_off, n_ovr, s32 off, ...}


def ring_pokes(a, rt, recs):
    """--poke pairs writing 8-byte pmo records recs [(t, w, op, ramp, v, mix, kit)] at the ring from index rt"""
    pk = []
    for i, (t, w, op, ramp, v, mix, kit) in enumerate(recs):
        ra = a + PMO_RING + 8 * ((rt + i) % 256)
        b = bytes([t, w, op, ramp, v >> 8 & 0xff, v & 0xff, mix, kit])
        pk += ["--poke", f"{ra:x}={b[:4].hex()}", "--poke", f"{ra + 4:x}={b[4:].hex()}"]
    return pk


def from_snap(e, snap, name, ms, **kw):
    """a run from another run's end snapshot"""
    old, e.snap = e.snap, snap
    try:
        return e.run(name, ms, **kw)
    finally:
        e.snap = old


def series(e, name, ms, ex, words, events=(), every="0.1M", extra=()):
    """a run with DTBOOT_PEEK of the effective words [(t, w)]: {(t, w): [u16 per status line]}"""
    addrs = sorted({(EFF + 2 * g_of(t, w)) & ~3 for t, w in words})
    r = e.run(name, ms, list(events), script=[], extra=list(ex) + ["--every", every] + list(extra),
              env=dict(DTBOOT_PEEK=",".join(f"{a:x}" for a in addrs)))
    out = {}
    for t, w in words:
        a = EFF + 2 * g_of(t, w)
        sh = 16 if a % 4 == 0 else 0
        out[(t, w)] = [v >> sh & 0xffff for c, v in peek_series(r, a & ~3)]
    return r, out


def t_offset(e):
    """M1: 04 (ramp 0) BD FRQ -10 steps and RES +10 steps: effective = base -/+ 0x0a00; target, state, kit sound
    unchanged; no answer (a done 04 sends nothing)."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    b_frq, b_res = tgt(e, s0, 0, W_FRQ), tgt(e, s0, 0, W_RES)
    r = e.run("offset", T0 + 100, [], script=[],
              extra=usb(e.at(T0), off_msg(k, 0, [(0, W_FRQ, -640), (0, W_RES, 640)])))
    sn = r["snap"]
    f, rs = eff(e, sn, 0, W_FRQ), eff(e, sn, 0, W_RES)
    check("offset: FRQ eff = base - 0x0a00, RES eff = base + 0x0a00", (f, rs) == (b_frq - 0xa00, b_res + 0xa00),
          (hex(b_frq), hex(f), hex(b_res), hex(rs)))
    check("offset: target and state unchanged", (tgt(e, sn, 0, W_FRQ), tgt(e, sn, 0, W_RES)) == (b_frq, b_res) and
          state(e, sn, 0, W_FRQ) >> 16 == b_frq and state(e, sn, 0, W_RES) >> 16 == b_res,
          (hex(tgt(e, sn, 0, W_FRQ)), hex(state(e, sn, 0, W_FRQ))))
    check("offset: the kit's sound bytes unchanged", sound(e, sn) == sound(e, s0))
    check("offset: no 2D 01 10 / 11 answer for a done 04", not acks(r) and not stats(r), (acks(r), stats(r)))
    d = pmo(e, sn)
    check("offset: pmo: 2 entries used, 2 records taken", d and d["used"] == 2 and d["recs"] == 2, d)


def t_ramp(e):
    """M2: 04 RES +16 steps with ramp 8: the effective word climbs 0 -> 0x1000 in 8 blocks (0.667 ms each: 5.3 ms,
    linear, each block 0x200); 20 ms later a new target 0 with ramp 64 continues from where it is (no jump)."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    base = tgt(e, s0, 0, W_RES)
    r, v = series(e, "ramp", T0 + 120, usb(e.at(T0), off_msg(k, 8, [(0, W_RES, 1024)])) +
                  usb(e.at(T0 + 60), off_msg(k, 64, [(0, W_RES, 0)])), [(0, W_RES)])
    x = v[(0, W_RES)]
    up = [i for i, y in enumerate(x) if y != base]
    top = [i for i, y in enumerate(x) if y == base + 0x1000]
    steps = sorted({y - base for y in x[up[0]:top[0] + 1]}) if up and top else []
    print(f"    first move at sample {up[:1]}, top at {top[:1]}, values {[hex(s) for s in steps]}")
    # samples every 0.1 M = 0.5 ms; 8 blocks = 5.33 ms = 10.7 samples
    check("ramp: 0 -> 0x1000 over 8 blocks (9..13 samples of 0.5 ms), every value a multiple of 0x200",
          up and top and 9 <= top[0] - up[0] + 1 <= 13 and all(s % 0x200 == 0 for s in steps) and len(steps) >= 7,
          (up[:1], top[:1], [hex(s) for s in steps]))
    later = x[top[-1]:] if top else []
    dif = [abs(a - b) for a, b in zip(later, later[1:])]
    check("ramp: the new target 0 over 64 blocks: no jump (each 0.5 ms moves <= 0x100), down to the base",
          later and max(dif or [0]) <= 0x100 and later[-1] == base, (max(dif or [0]), hex(later[-1]) if later else None))


def lfo_pokes(dep=0x5000, dst=W_VOL):
    """LFO 1 of BD in the target array (the next sound copy would undo it; none happens): DST (word 4), SPD 0x7000
    (word 5); DEP (word 8). Target words 4/5 share the long at g 30/31, 8/9 at g 34/35."""
    w9 = tgt_base[0] if tgt_base else 0
    return ["--poke", f"{TARGET + 2 * g_of(0, 4):x}={dst << 8:04x}7000",
            "--poke", f"{TARGET + 2 * g_of(0, 8):x}={dep:04x}{w9:04x}"]


tgt_base = []


def t_stack(e):
    """M3: LFO 1 on VOL (DEP +16) and a Sidecar offset -10 steps on VOL: eff = the LFO run's eff - 0x0a00 at every
    sample (S-post after the LFO); an offset of +16 steps on DEP (word 8, S-pre) = the LFO with DEP +32 poked."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    tgt_base[:] = [tgt(e, s0, 0, 9)]
    msg = lambda m: usb(e.at(T0), m) + usb(e.at(T0 + 150), m)   # noqa: E731  (a refresh before the 250 ms timeout)
    _, a = series(e, "stack-lfo", T0 + 300, lfo_pokes(), [(0, W_VOL)], every="0.4M")
    _, b = series(e, "stack-off", T0 + 300, lfo_pokes() + msg(off_msg(k, 0, [(0, W_VOL, -640)])), [(0, W_VOL)],
                  every="0.4M")
    a, b = a[(0, W_VOL)], b[(0, W_VOL)]
    n0 = int(len(a) * (T0 + 20) / (T0 + 300))
    d = [x - y for x, y in zip(a[n0:], b[n0:])]
    print(f"    LFO alone {[hex(x) for x in a[n0:n0 + 6]]}  + offset {[hex(x) for x in b[n0:n0 + 6]]}")
    check("stack: the LFO moves VOL", len(set(a[n0:])) > 4, len(set(a[n0:])))
    check("stack: with the offset, eff = the LFO's - 0x0a00 at every sample after the message", d and
          all(x == 0xa00 for x in d), sorted(set(d))[:6])
    _, c = series(e, "stack-dep", T0 + 300, lfo_pokes(0x5000) + msg(off_msg(k, 0, [(0, W_DEP, 1024)])), [(0, W_VOL)],
                  every="0.4M")
    _, dd = series(e, "stack-dep2", T0 + 300, lfo_pokes(0x6000), [(0, W_VOL)], every="0.4M")
    c, dd = c[(0, W_VOL)], dd[(0, W_VOL)]
    m = [i for i in range(n0, min(len(c), len(dd))) if c[i] != dd[i]]
    check("stack: DEP +16 steps by the Sidecar = DEP poked 16 steps higher (LFO 1 reads the S-pre word)",
          len(c) > n0 and not m, (len(m), [(hex(c[i]), hex(dd[i])) for i in m[:4]]))


def t_override(e):
    """M4: 05 VOL v = 50 steps, mix 127, jump: eff = 0x3200 (no modulation on VOL); with LFO 1 on VOL: 0x3200 + the
    LFO's own move (eff - base of the LFO run); mix 64: about halfway; mix 0: released (eff = base again)."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    base = tgt(e, s0, 0, W_VOL)
    tgt_base[:] = [tgt(e, s0, 0, 9)]
    v = 50 * 128
    r = e.run("ovr", T0 + 100, [], script=[], extra=usb(e.at(T0), ovr_msg(k, 0, [(0, W_VOL, v, 127, 1)])))
    check("override: mix 127: eff VOL = 0x3200", eff(e, r["snap"], 0, W_VOL) == 0x3200, hex(eff(e, r["snap"], 0, W_VOL)))
    check("override: target and kit unchanged", tgt(e, r["snap"], 0, W_VOL) == base and sound(e, r["snap"]) == sound(e, s0))
    r = e.run("ovr-half", T0 + 100, [], script=[], extra=usb(e.at(T0), ovr_msg(k, 0, [(0, W_VOL, v, 64, 1)])))
    want = base + (64 * 32768 // 127) * (0x3200 - base) // 32768
    got = eff(e, r["snap"], 0, W_VOL)
    check("override: mix 64: base + 64/127 of the way (+-1)", abs(got - want) <= 1, (hex(base), hex(got), hex(want)))
    r = e.run("ovr-rel", T0 + 150, [], script=[], extra=usb(e.at(T0), ovr_msg(k, 0, [(0, W_VOL, v, 127, 1)])) +
              usb(e.at(T0 + 50), ovr_msg(k, 0, [(0, W_VOL, v, 0, 1)])))
    d = pmo(e, r["snap"])
    check("override: mix 0 (jump): released, eff = base, the entry freed", eff(e, r["snap"], 0, W_VOL) == base and
          d and d["used"] == 0, (hex(eff(e, r["snap"], 0, W_VOL)), d))
    _, a = series(e, "ovr-lfo-a", T0 + 200, lfo_pokes(), [(0, W_VOL)], every="0.4M")
    _, b = series(e, "ovr-lfo-b", T0 + 200, lfo_pokes() + usb(e.at(T0), ovr_msg(k, 0, [(0, W_VOL, v, 127, 1)])),
                  [(0, W_VOL)], every="0.4M")
    a, b = a[(0, W_VOL)], b[(0, W_VOL)]
    n0 = int(len(a) * (T0 + 20) / (T0 + 200))
    bad = [i for i in range(n0, min(len(a), len(b))) if b[i] != max(0, min(0x7fff, 0x3200 + a[i] - base))]
    check("override: with LFO 1 on VOL: eff = 0x3200 + (the LFO run's eff - base), every sample", len(a) > n0 and
          not bad and len(set(b[n0:])) > 3, [(hex(a[i]), hex(b[i])) for i in bad[:4]])


def t_override_plock(e):
    """M4: a Rytm p-lock on FRQ (step 1, as m0a), playing; the Sidecar override FRQ = 0x3000 (mix 127, jump) sent
    after the trig: eff = 0x3000 (the override replaces the base, the lock's 0x7d00 included)."""
    k = kit_of(e)
    v = 0x3000 >> 1
    ev = PLOCK_FRQ + [(2100, "press", "PLAY")]
    r = e.run("ovr-plock", 2450, ev, script=[], extra=usb(e.at(2300), ovr_msg(k, 0, [(0, W_FRQ, v, 127, 1)])))
    sn = r["snap"]
    check("override_plock: the lock is the base (target = state = the lock's value, not the sound's)",
          tgt(e, sn, 0, W_FRQ) != sound_word(e, sn, W_FRQ) and state(e, sn, 0, W_FRQ) >> 16 == tgt(e, sn, 0, W_FRQ),
          (hex(tgt(e, sn, 0, W_FRQ)), hex(sound_word(e, sn, W_FRQ))))
    check("override_plock: eff FRQ = the override 0x3000", eff(e, sn, 0, W_FRQ) == 0x3000, hex(eff(e, sn, 0, W_FRQ)))


def sound_word(e, snap, w, t=0):
    """the kit sound's stored word w (KWORD: kit + 0x26 + 2 w, u16)"""
    k = kit_of(e, snap)
    return u16(e.peek(snap, 0x41255933 + 2531 * k + 152 * t + 2 * w, 2))


SCENE_POKES = None


def t_scene(e):
    """M5 (O3): a scene lock on FRQ engaged (scene list poked: gate 1, lock 0 = {g FRQ, 0x2000}, the other 47 at
    g 25 as the loader leaves them): the override (mix 127) is skipped, the offset (-4 steps) still adds: eff 0x1c00;
    07's flags bit 0 set; RES (not scene locked) takes its override."""
    k = kit_of(e)
    g = g_of(0, W_FRQ)
    pk = ["--poke", f"{SCN_GATE:x}=00000001", "--poke", f"{SCN_G:x}={g:04x}0019", "--poke", f"{SCN_V:x}=20000000"]
    for i in range(1, 24):
        pk += ["--poke", f"{SCN_G + 4 * i:x}=00190019"]
    m = (usb(e.at(T0), ovr_msg(k, 0, [(0, W_FRQ, 0x7000 >> 1, 127, 1), (0, W_RES, 0x1000 >> 1, 127, 1)])) +
         usb(e.at(T0 + 10), off_msg(k, 0, [(0, W_FRQ, -256)])) + usb(e.at(T0 + 40), stat_msg()))
    r = e.run("scene", T0 + 120, [], script=[], extra=pk + m)
    sn = r["snap"]
    check("scene: FRQ: the scene's 0x2000 - 4 steps (the override skipped, the offset added)",
          eff(e, sn, 0, W_FRQ) == 0x1c00, hex(eff(e, sn, 0, W_FRQ)))
    check("scene: RES (no scene lock): the override 0x1000", eff(e, sn, 0, W_RES) == 0x1000, hex(eff(e, sn, 0, W_RES)))
    st = stats(r)
    check("scene: 07's answer: flags bit 0 (an override skipped for a scene lock) and bit 1 (the hook ran)",
          st and st[-1][-1] & 3 == 3, st)


def t_scene_first(e):
    """F4: the scene lock on FRQ engaged and no entry live; an override on FRQ (mix 127, jump) arrives: its very first
    block already skips it (eff sampled every 0.05 M instructions, 0.25 ms: never the override's 0x7000)."""
    k = kit_of(e)
    g = g_of(0, W_FRQ)
    pk = ["--poke", f"{SCN_GATE:x}=00000001", "--poke", f"{SCN_G:x}={g:04x}0019", "--poke", f"{SCN_V:x}=20000000"]
    for i in range(1, 24):
        pk += ["--poke", f"{SCN_G + 4 * i:x}=00190019"]
    m = usb(e.at(T0), ovr_msg(k, 0, [(0, W_FRQ, 0x7000 >> 1, 127, 1)]))
    r, v = series(e, "scene-first", T0 + 30, m, [(0, W_FRQ)], every="0.05M", extra=pk)
    x = v[(0, W_FRQ)]
    glitch = 0x2000 + 0x7000 - 0x7f00      # the override applied over the scene's value (base 0x7f00): 0x1100
    check("scene_first: FRQ never takes the override (the scene's 0x2000 from the first block on, never 0x1100)",
          x and glitch not in x and x[-1] == 0x2000, sorted(set(hex(y) for y in x)))


def t_ovr_ramp(e):
    """05 without the jump flag, ramp 8: RES's override 0x1000 (from the base 0) mixes in over 8 blocks (values in
    between, then 0x1000); a release (mix 0) with ramp 16 back to the base."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    base = tgt(e, s0, 0, W_RES)
    m = usb(e.at(T0), ovr_msg(k, 8, [(0, W_RES, 0x1000 >> 1, 127, 0)])) + usb(e.at(T0 + 40), ovr_msg(k, 16, [(0, W_RES, 0x1000 >> 1, 0, 0)]))
    r, v = series(e, "ovr-ramp", T0 + 80, m, [(0, W_RES)])
    x = v[(0, W_RES)]
    top = x.index(0x1000) if 0x1000 in x else len(x)
    up = [y for y in x[:top] if base < y < 0x1000]
    dn = [y for y in x[top:] if base < y < 0x1000]
    check("ovr_ramp: up over 8 blocks (1..12 samples of 0.5 ms between), down over 16 (1..23), back to the base",
          0 < len(up) <= 12 and 0 < len(dn) <= 23 and top < len(x) and x[-1] == base, (len(up), len(dn), hex(x[-1])))


def t_hello_fade(e):
    """A new hello (pmo.hello_n stepped, as flush does after sending one): every entry fades out over 32 blocks (values
    in between, sampled every 0.1 M = 0.5 ms), freed, no timeout counted."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    base = tgt(e, s0, 0, W_RES)
    r = e.run("hello-on", T0 + 20, [], script=[], extra=usb(e.at(T0), off_msg(k, 0, [(0, W_RES, 640)])))
    a = e.sym("pmo")
    hn = int.from_bytes(e.peek(r["snap"], a + PMO_HELLO_N, 4), "big")
    pk = ["--poke", f"{a + PMO_HELLO_N:x}={hn + 1:08x}"]
    addr = EFF + 2 * g_of(0, W_RES)
    r2 = from_snap(e, r["snap"], "hello-fade", 40, events=[], script=None, extra=pk + ["--every", "0.1M"],
                   env=dict(DTBOOT_PEEK=f"{addr & ~3:x}"))
    sh = 16 if addr % 4 == 0 else 0
    x = [v >> sh & 0xffff for c, v in peek_series(r2, addr & ~3)]
    mid = [y for y in x if base < y < base + 0xa00]
    d = pmo(e, r2["snap"])
    check("hello_fade: on before (+10 steps); a fade (values between over 32 blocks: 1..45 samples of 0.5 ms); the "
          "base, freed, no timeout", eff(e, r["snap"], 0, W_RES) == base + 0xa00 and 0 < len(mid) <= 45 and
          eff(e, r2["snap"], 0, W_RES) == base and d and d["used"] == 0 and d["timeouts"] == 0, (len(mid), d))


def t_clear_then(e):
    """06 then 04 in one USB burst (track 0): the CLEAR fades track 0 and the 04 behind it is applied in the next block,
    after the fade: RES at the 04's +20 steps (not the base, not lost)."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    base = tgt(e, s0, 0, W_RES)
    m = usb(e.at(T0), off_msg(k, 0, [(0, W_RES, 640), (0, W_FRQ, -640)])) + \
        usb(e.at(T0 + 20), clr_msg(k, 0, 1) + off_msg(k, 0, [(0, W_RES, 1280)]))
    r = e.run("clear-then", T0 + 40, [], script=[], extra=m)
    d = pmo(e, r["snap"])
    check("clear_then: RES = base + 20 steps (the 04 after the CLEAR), FRQ back to the base (cleared), 1 entry",
          eff(e, r["snap"], 0, W_RES) == base + 0x1400 and eff(e, r["snap"], 0, W_FRQ) == tgt(e, s0, 0, W_FRQ) and
          d and d["used"] == 1, (hex(eff(e, r["snap"], 0, W_RES)), hex(eff(e, r["snap"], 0, W_FRQ)), d))


def t_slots(e):
    """The free-slot stack after the top shrinks: 128 distinct (t, w) with offsets; slots 10..20 and 64..127 freed in
    one block (the top falls to 64, the stack holds stale 64..127 above the 11 holes); 70 new distinct (t, w): every
    live (t, w) applies its own offset (eff = the reference run's + its offset), 123 used."""
    k = kit_of(e)
    pairs = [(t, w) for t in range(12) for w in range(9, 42) if w not in (29,)]
    off = lambda i: 64 * (1 + i % 7)          # noqa: E731  1..7 steps
    fill = []
    for i in range(0, 128, 28):
        fill += usb(e.at(T0 + 2 * (i // 28)), off_msg(k, 0, [(t, w, off(j)) for j, (t, w) in enumerate(pairs) if i <= j < min(128, i + 28)]))
    gone = [j for j in range(128) if 10 <= j <= 20 or j >= 64]
    frees = []
    for i in range(0, len(gone), 28):
        frees += [(pairs[j][0], pairs[j][1], 0) for j in gone[i:i + 28]]
    fr = []
    for i in range(0, len(frees), 28):
        fr += usb(e.at(T0 + 20), off_msg(k, 0, frees[i:i + 28]))
    new = list(range(128, 198))
    nw = []
    for i in range(0, 70, 28):
        nw += usb(e.at(T0 + 40), off_msg(k, 0, [(pairs[j][0], pairs[j][1], off(j)) for j in new[i:i + 28]]))
    r = e.run("stack-pm", T0 + 70, [], script=[], extra=fill + fr + nw)
    live = [j for j in range(198) if j not in gone]
    a = e.sym("pmo")
    b = e.peek(r["snap"], a, PMO_ENT + PMO_ENT_SZ * 128)
    bad, seen = [], {}
    for j in live:                 # the books, not eff: a snapshot can fall inside the post pass
        t, w = pairs[j]
        sl = b[PMO_IDX + 64 * t + w] - 1
        o = PMO_ENT + PMO_ENT_SZ * sl
        got = (b[o], b[o + 1], int.from_bytes(b[o + 4:o + 8], "big", signed=True)) if sl >= 0 else None
        if got != (t + 1, w, off(j) << 10) or sl in seen:
            bad.append((t, w, sl, got, seen.get(sl)))
        seen[sl] = (t, w)
    d = pmo(e, r["snap"])
    check("slots: 123 used, each live (t, w) in its own slot with its own offset (no two sharing one)",
          d and d["used"] == 123 and not bad, (d and d["used"], bad[:6]))


def t_ring_drop(e):
    """The ring full (rh poked far ahead of rt, after the base's hello, which empties the ring: the drain works through
    stale records of another kit at 64 a block, so the ring stays full): a 04 of 3 records is counted in ring_drop (3),
    nothing live."""
    k = kit_of(e)
    a = e.sym("pmo")
    s0 = os.path.join(R.EMU, e.snap)
    r0 = e.run("ring-pre", T0, [], script=[])
    rt = int.from_bytes(e.peek(r0["snap"], a + PMO_RT, 4), "big")
    pk, kk = [], k
    if k == 0:                     # the ring's records carry kit 0: run on kit 1
        kk = 1
        pk += ["--poke", f"{ACTIVE_KIT:x}=00000001"]
    pk += ["--poke", f"{a + PMO_RH:x}={(rt + 0x40000000) & 0xffffffff:08x}"]
    r = from_snap(e, r0["snap"], "ring-drop", 40, events=[], script=None,
                  extra=pk + usb(e.at(T0 + 5), off_msg(kk, 0, [(0, W_RES, 64), (0, W_FRQ, 64), (1, W_RES, 64)])))
    d = pmo(e, r["snap"])
    check("ring_drop: 3 records dropped at a full ring, nothing live, the drain dropping the other kit's", d and
          d["ring_drop"] == 3 and d["used"] == 0 and d["kit_drop"] >= 64, d)


def t_lifetime(e):
    """M6: an offset (RES +10 steps) and no message after it: still on at +240 ms, back to the base by +250 + 21 ms
    (a 32-block fade); 07 counts the timeout. The host gone (USB VBUS off): back at once, before the timeout."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    base = tgt(e, s0, 0, W_RES)
    m = usb(e.at(T0), off_msg(k, 0, [(0, W_RES, 640)]))
    r = e.run("life-240", T0 + 240, [], script=[], extra=m)
    check("lifetime: +240 ms: the offset still on", eff(e, r["snap"], 0, W_RES) == base + 0xa00,
          hex(eff(e, r["snap"], 0, W_RES)))
    r = e.run("life-275", T0 + 275, [], script=[], extra=m + usb(e.at(T0 + 272), stat_msg()))
    d = pmo(e, r["snap"])
    check("lifetime: +275 ms: back to the base, the entry freed, one timeout", eff(e, r["snap"], 0, W_RES) == base and
          d and d["used"] == 0 and d["timeouts"] == 1, (hex(eff(e, r["snap"], 0, W_RES)), d))
    _, v = series(e, "life-fade", T0 + 300, m, [(0, W_RES)], every="0.2M")
    x = v[(0, W_RES)]
    mid = [y for y in x if base < y < base + 0xa00]
    check("lifetime: the timeout fades (values between, over <= 32 blocks: <= 22 samples of 1 ms)",
          0 < len(mid) <= 22, len(mid))
    hp = R.subprocess.run([R.DTBOOT, "--help"], capture_output=True, text=True)
    if "--usb-host-gone" in hp.stdout + hp.stderr:
        r = e.run("life-gone", T0 + 100, [(T0 + 30, "gone", T0 + 2000)], script=[], extra=m)
        check("lifetime: the host gone (port down) at +30 ms: the base at +100 ms (before the timeout)",
              eff(e, r["snap"], 0, W_RES) == base, hex(eff(e, r["snap"], 0, W_RES)))


def t_kit(e):
    """M6: a message whose kit byte is not the active kit: dropped (nothing moves), counted (07's kit_drop); a kit
    change (the active kit poked to another between two runs, as a load sets it) frees every entry at once."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    base = tgt(e, s0, 0, W_RES)
    r = e.run("kit-drop", T0 + 100, [], script=[], extra=usb(e.at(T0), off_msg((k + 1) & 127, 0, [(0, W_RES, 640)])) +
              usb(e.at(T0 + 50), stat_msg()))
    st = stats(r)
    check("kit: the other kit's message: nothing moves", eff(e, r["snap"], 0, W_RES) == base, hex(eff(e, r["snap"], 0, W_RES)))
    check("kit: 07: slots 0, kit_drop 1", st and st[-1][0] == 0 and (st[-1][3] << 7 | st[-1][4]) == 1, st)
    r = e.run("kit-on", T0 + 100, [], script=[], extra=usb(e.at(T0), off_msg(k, 0, [(0, W_RES, 640)])))
    pk = ["--poke", f"{ACTIVE_KIT:x}={(k + 1) & 127:08x}"]
    old, e.snap = e.snap, r["snap"]        # from the first run's end (rui_emu's Emu loads e.snap)
    try:
        r2 = e.run("kit-chg", 20, [], script=None, extra=pk)
    finally:
        e.snap = old
    d = pmo(e, r2["snap"])
    check("kit: a kit change frees every entry at once", d and d["used"] == 0, d)
    # a record the MIDI task pushed for the old kit just before the change, still in the ring (poked there: the
    # ring's next record, rh one on): dropped at the drain, counted, not applied to the new kit
    a = e.sym("pmo")
    rt = int.from_bytes(e.peek(r["snap"], a + PMO_RT, 4), "big")
    rec = bytes([0, W_VOL, OP_OFF, 0, 640 >> 8 & 0xff, 640 & 0xff, 0, k])
    ra = a + PMO_RING + 8 * (rt % 256)
    pk2 = pk + ["--poke", f"{ra:x}={rec[:4].hex()}", "--poke", f"{ra + 4:x}={rec[4:].hex()}",
                "--poke", f"{a + PMO_RH:x}={rt + 1:08x}"]
    e.snap = r["snap"]
    try:
        r3 = e.run("kit-stale", 20, [], script=None, extra=pk2)
    finally:
        e.snap = old
    d = pmo(e, r3["snap"])
    check("kit: a record for the old kit still in the ring at the change: dropped (kit_drop), nothing live",
          d and d["used"] == 0 and d["kit_drop"] == 1, d)


def kit_menu_load(at):
    """FUNC + PLAYMODE: the KIT menu, back to its top (UP x 3), DOWN to LOAD KIT, YES; the list: DOWN, YES (kit 2)."""
    ev = [(at, "press", "FUNC", 300), (at + 60, "press", "PLAYMODE")]
    t = at + 500
    for key in ["UP", "UP", "UP", "DOWN", "YES", "DOWN", "YES"]:
        ev.append((t, "press", key))
        t += 250
    return ev, t


def t_kitload(e):
    """M6: a kit loaded (KIT menu > LOAD KIT, the next kit) while an offset is on: the active kit changes and the
    entry is freed at once; the RES word is the new kit's (no offset)."""
    k = kit_of(e)
    ev, t = kit_menu_load(T0 + 50)
    refresh = []
    for i in range(0, t + 300 - T0, 100):
        refresh += usb(e.at(T0 + i), off_msg(k, 0, [(0, W_RES, 640)]))   # the host's refresh, with the old kit byte
    r = e.run("kitload", t + 300, ev, script=[], extra=refresh)
    sn = r["snap"]
    d = pmo(e, sn)
    check("kitload: the active kit changed", kit_of(e, sn) != k, (k, kit_of(e, sn)))
    check("kitload: the entry freed, eff RES = target (the old kit's refreshes dropped, counted)",
          d and d["used"] == 0 and d["kit_drop"] >= 1 and eff(e, sn, 0, W_RES) == tgt(e, sn, 0, W_RES),
          (d, hex(eff(e, sn, 0, W_RES)), hex(tgt(e, sn, 0, W_RES))))


def t_never_kit(e):
    """M7: SAVE KIT (YES + PLAY MODE) with offsets and an override on, then RELOAD KIT (NO + PLAY MODE): the kit's
    sound bytes are the base's before and after, the effective words the targets after the reload (the reload frees
    the entries)."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    m = []
    for i in range(0, 1500, 100):
        m += usb(e.at(T0 + i), off_msg(k, 0, [(0, W_RES, 640), (0, W_FRQ, -640)]))
    m += usb(e.at(T0 + 20), ovr_msg(k, 0, [(0, W_VOL, 0x2000 >> 1, 127, 1)]))
    ev = ([(T0 + 300, "press", "YES", 400), (T0 + 400, "press", "PLAYMODE")] +
          [(T0 + 1000 + 250 * i, "press", "NO") for i in range(4)] +
          [(T0 + 2300, "press", "NO", 400), (T0 + 2400, "press", "PLAYMODE")])
    r = e.run("neverkit", T0 + 2900, ev, script=[], extra=m)
    sn = r["snap"]
    check("never_kit: the kit's BD sound bytes after SAVE KIT and RELOAD = the base's", sound(e, sn) == sound(e, s0))
    check("never_kit: after the reload the effective words are the targets (RES FRQ VOL)",
          all(eff(e, sn, 0, w) == tgt(e, sn, 0, w) for w in (W_RES, W_FRQ, W_VOL)),
          [(hex(eff(e, sn, 0, w)), hex(tgt(e, sn, 0, w))) for w in (W_RES, W_FRQ, W_VOL)])
    d = pmo(e, sn)
    check("never_kit: no entry left (the reload cleared, then the timeout)", d and d["used"] == 0, d)


PATTERN0 = 0x407dd8e3            # pattern 0's data (trig_fire: a2 = pattern x 85760 + this), 85760 B


def t_velocity(e):
    """M8: the base pattern played (PLAY): track 2's trigs (velocity 127) at 0, 118, 237 ms and track 8's (100) at
    118 ms. VEL -20 on track 2 -> 107, +40 -> 127 (clamped), -127 -> 1, override 20 (mix 127) -> 20; VEL +20 on track 8
    -> 120; the pattern's bytes as without an entry (the site rewrites the stack copy only). A pad (BD, velocity 127 in
    the emulator): whether it passes the site."""
    k = kit_of(e)
    def play(name, msg):
        m = []
        for i in range(0, 700, 100):
            m += usb(e.at(1100 + i), msg)
        r = e.run(name, 1750, [(1400, "press", "PLAY")], script=None, extra=m)
        return [x >> 8 for x in peekw(e, r["snap"], TRIG_VEL, 13)], r
    v0, r0 = play("vel-0", stat_msg())
    check("velocity: without an entry: track 2 127, track 8 100", (v0[2], v0[8]) == (127, 100), v0)
    for name, msg, t, want in (("vel-20", off_msg(k, 0, [(2, 56, -20 * 64)]), 2, 107),
                               ("vel+40", off_msg(k, 0, [(2, 56, 40 * 64)]), 2, 127),
                               ("vel-127", off_msg(k, 0, [(2, 56, -127 * 64)]), 2, 1),
                               ("vel=20", ovr_msg(k, 0, [(2, 56, 20 << 7, 127, 1)]), 2, 20),
                               ("vel8+20", off_msg(k, 0, [(8, 56, 20 * 64)]), 8, 120)):
        v, r = play(name, msg)
        check(f"velocity: {name}: track {t}'s trig_velocity {want}, the others as without", v[t] == want and
              all(v[i] == v0[i] for i in range(13) if i != t), v)
        if name == "vel-20":
            check("velocity: the pattern's bytes as without an entry",
                  e.peek(r["snap"], PATTERN0, 85760) == e.peek(r0["snap"], PATTERN0, 85760))
    # the last entry freed (CLEAR, ramp 0) before the trigs: no VEL left on any track (track 8's word is cleared too)
    m = usb(e.at(1100), off_msg(k, 0, [(8, 56, -20 * 64)])) + usb(e.at(1200), clr_msg(k, 0, 1 << 8))
    r = e.run("vel-clr", 1750, [(1400, "press", "PLAY")], script=None, extra=m)
    v = [x >> 8 for x in peekw(e, r["snap"], TRIG_VEL, 13)]
    check("velocity: VEL -20 on track 8 cleared before the trigs: every track as without", v == v0, v)
    m = []
    for i in range(0, 300, 100):
        m += usb(e.at(1100 + i), off_msg(k, 0, [(0, 56, -20 * 64)]))
    r = e.run("vel-pad", 1400, [(1250, "press", "BD")], script=None, extra=m)
    v = peekw(e, r["snap"], TRIG_VEL)[0] >> 8
    print(f"    the BD pad (127) with VEL -20: trig_velocity {v} ({'the site sees pads' if v == 107 else 'pads do not pass it'})")
    check("velocity: the pad's velocity 127 or 107 (nothing broken)", v in (107, 127), v)


def t_vm(e):
    """M9: VELOCITY MOD route 1 -> RES with amount 0 (the sound poked), VM1 offset +64 displayed steps (v = 4096):
    after a pad hit (velocity 127) eff RES = the run with the stock amount +64 (0x4000): 0x3f80 (+-1). The same on
    track 1 (SD); a route into word 8 (DEP, words 1..8: S-pre's path); AFTERTOUCH 1 (w 52) with the aftertouch poked;
    a route at 'none' (word 0): nothing written."""
    k = kit_of(e)
    def hit(name, amt, msg, t=0, w=W_RES, at=False, pad="BD", pk=()):
        m = []
        for i in range(0, 300, 100):
            m += usb(e.at(T0 + i), msg) if msg else []
        r = e.run(name, T0 + 300, [(T0 + 100, "press", pad)], script=[],
                  extra=["--poke", f"{SOUND0 + 2531 * k + 152 * t + (0x8c if at else 0x70):x}={amt:04x}{w:02x}00"] +
                  list(pk) + m)
        return eff(e, r["snap"], t, w), r
    a, _ = hit("vm-stock", 0x4000, None)
    b, r = hit("vm-pm", 0x0000, off_msg(k, 0, [(0, 48, 4096)]))
    check("vm: stock amount +64: RES 0x3f80", a == 0x3f80, hex(a))
    check("vm: amount 0 + VM1 offset +64 steps: the same RES (+-1)", abs(a - b) <= 1, (hex(a), hex(b)))
    a, _ = hit("vm1-stock", 0x4000, None, t=1, pad="SD")
    b, _ = hit("vm1-pm", 0x0000, off_msg(k, 0, [(1, 48, 4096)]), t=1, pad="SD")
    check("vm: track 1 (SD): VM1 +64 = the stock amount +64 (+-1), moved", abs(a - b) <= 1 and a != hit("vm1-0", 0, None, t=1, pad="SD")[0],
          (hex(a), hex(b)))
    a, _ = hit("vmd-stock", 0x4000, None, w=W_DEP)
    b, _ = hit("vmd-pm", 0x0000, off_msg(k, 0, [(0, 48, 4096)]), w=W_DEP)
    z, _ = hit("vmd-0", 0x0000, None, w=W_DEP)
    check("vm: a route into word 8 (DEP, S-pre): VM1 +64 = the stock amount +64 (+-1), moved", abs(a - b) <= 1 and a != z,
          (hex(a), hex(b), hex(z)))
    atp = ["--poke", f"{0x800067de:x}=40000000"]   # (a 32-bit poke: track 0's s16 first)
    a, _ = hit("at-stock", 0x4000, None, at=True, pk=atp)
    b, _ = hit("at-pm", 0x0000, off_msg(k, 0, [(0, 52, 4096)]), at=True, pk=atp)
    z, _ = hit("at-0", 0x0000, None, at=True, pk=atp)
    check("vm: AFTERTOUCH 1 (aftertouch poked 0x4000): AT1 +64 = the stock amount +64 (+-1), moved", abs(a - b) <= 1 and a != z,
          (hex(a), hex(b), hex(z)))
    z, rz = hit("vmn-0", 0x0000, None, w=0)
    c, rc = hit("vm-none", 0x0000, off_msg(k, 0, [(0, 48, 4096)]), w=0)
    check("vm: a route at 'none' (word 0) with an offset: RES and word 0 as without",
          (eff(e, rc["snap"], 0, W_RES), c) == (eff(e, rz["snap"], 0, W_RES), z), (hex(c), hex(z)))


def t_refuse(e):
    """M11: refusals 2D 01 10 <op> 1: words 0, 4, 42..47, 57, FX 29 / 38..41, track 13, VM on the FX track, VM in
    05, jump in 04, a byte > 0x7f, n 0, a bad length; done ops nothing. The 0.5.0 ops unchanged (PERF done)."""
    k = kit_of(e)
    bad = [off_msg(k, 0, [(0, 0, 64)]), off_msg(k, 0, [(0, 4, 64)]), off_msg(k, 0, [(0, 42, 64)]),
           off_msg(k, 0, [(0, 57, 64)]), off_msg(k, 0, [(12, 29, 64)]), off_msg(k, 0, [(12, 38, 64)]),
           off_msg(k, 0, [(13, 30, 64)]), off_msg(k, 0, [(12, 48, 64)]), ovr_msg(k, 0, [(0, 48, 64, 127, 0)]),
           P._msg(P.HOST_CMD, [OP_OFF, k, 0, 1, 0, W_RES | 0x40, 0, 1]), P._msg(P.HOST_CMD, [OP_OFF, k, 0, 1, 0, W_RES, 0x80, 1]),
           P._msg(P.HOST_CMD, [OP_OFF, k, 0, 0]), P._msg(P.HOST_CMD, [OP_OFF, k, 0, 2, 0, W_RES, 0, 1]),
           P._msg(P.HOST_CMD, [OP_CLR, k, 0, 0]), P._msg(P.HOST_CMD, [OP_STAT, 0])]
    want = [[4, 1]] * 8 + [[5, 1]] + [[4, 1]] * 4 + [[6, 1], [7, 1]]
    ex = []
    for i, m in enumerate(bad):
        ex += usb(e.at(T0 + 40 * i), m)
    t = T0 + 40 * len(bad)
    good = [off_msg(k, 0, [(0, W_RES, 64), (12, 30, 64), (12, 37, 64), (0, 41, 64)]),
            ovr_msg(k, 0, [(0, W_FRQ, 64, 127, 1), (0, 56, 100 << 7, 127, 0)]), clr_msg(k, 0, 0x1fff),
            P.host_cmd(P.HOST_PERF, 2, 5)]
    for i, m in enumerate(good):
        ex += usb(e.at(t + 40 * i), m)
    r = e.run("refuse", t + 300, [], script=[], extra=ex)
    a = acks(r)
    check("refuse: each bad message refused in order (10 <op> 1), the good 04 / 05 / 06 silent, PERF done (10 03 00)",
          a == want + [[3, 0]], a)


def t_full(e):
    """M11: 129 (t, w) pairs: 128 taken, the 129th dropped: 2D 01 10 04 2 once (at most one a second); 07: 128 slots."""
    k = kit_of(e)
    pairs = [(t, w) for t in range(12) for w in list(range(5, 42)) if w != 4][:129]
    ex = []
    for i in range(0, 129, 28):
        ex += usb(e.at(T0 + 10 * (i // 28)), off_msg(k, 0, [(t, w, 64) for t, w in pairs[i:i + 28]]))
    ex += usb(e.at(T0 + 100), off_msg(k, 0, [(t, w, 64) for t, w in pairs[100:129]][:28]))
    ex += usb(e.at(T0 + 150), stat_msg())
    r = e.run("full", T0 + 220, [], script=[], extra=ex)
    a = acks(r)
    st = stats(r)
    check("full: one 10 04 2 (full), nothing else", a == [[4, 2]], a)
    d = pmo(e, r["snap"])
    check("full: 07: slots 127 (the byte saturates), 128 used", st and st[-1][0] == 127 and d and d["used"] == 128,
          (st, d))


def t_status(e):
    """M11 / 07: 2D 01 11 <slots> <ring drops hi lo> <kit drops hi lo> <timeouts> <flags>: two entries, flags bit 1."""
    k = kit_of(e)
    r = e.run("status", T0 + 100, [], script=[], extra=usb(e.at(T0), off_msg(k, 0, [(0, W_RES, 64), (1, W_RES, 64)])) +
              usb(e.at(T0 + 30), stat_msg()))
    st = stats(r)
    check("status: one answer, 8 bytes: slots 2, drops 0, kit drops 0, timeouts 0, flags bit 1 (ran)",
          len(st) == 1 and len(st[0]) == 7 and st[0][:6] == [2, 0, 0, 0, 0, 0] and st[0][6] & 2, st)


def t_caps(e):
    """M13: the hello's caps 127 (bit 6, 64: param modulation)."""
    r = e.run("caps", T0, [], script=[])
    h = R.evs(r, "hello")
    check("caps: the hello says 127", h and h[0]["caps"] == 127, h)


def t_clear(e):
    """06 CLEAR: mask track 1 only, ramp 0: track 1's entries freed at once, track 0's stay."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    r = e.run("clear", T0 + 100, [], script=[], extra=usb(e.at(T0), off_msg(k, 0, [(0, W_RES, 640), (1, W_RES, 640)])) +
              usb(e.at(T0 + 40), clr_msg(k, 0, 0x002)))
    sn = r["snap"]
    check("clear: track 1 back to its base, track 0 still moved",
          eff(e, sn, 1, W_RES) == tgt(e, s0, 1, W_RES) and eff(e, sn, 0, W_RES) == tgt(e, s0, 0, W_RES) + 0xa00,
          (hex(eff(e, sn, 1, W_RES)), hex(eff(e, sn, 0, W_RES))))
    d = pmo(e, sn)
    check("clear: one entry left", d and d["used"] == 1, d)


def t_fx(e):
    """FX track (t 12): an offset on the delay TIM (word 9) and the compressor THR (word 30): both effective words
    move (the consumers read them: [code] 0x4010e1a0 gets 0x8000fbd4)."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    r = e.run("fx", T0 + 100, [], script=[], extra=usb(e.at(T0), off_msg(k, 0, [(12, 9, -640), (12, 30, -640)])))
    sn = r["snap"]
    check("fx: TIM and THR eff = target - 0x0a00",
          eff(e, sn, 12, 9) == tgt(e, s0, 12, 9) - 0xa00 and eff(e, sn, 12, 30) == tgt(e, s0, 12, 30) - 0xa00,
          (hex(eff(e, sn, 12, 9)), hex(tgt(e, s0, 12, 9)), hex(eff(e, sn, 12, 30)), hex(tgt(e, s0, 12, 30))))


def t_cost(e):
    """M10: the S stage's time per audio block (DTCN0; the mod's own max and sum): idle, and with 16 / 64 / 128 entries
    whose offsets the host refreshes with ramps at 200 messages a second (28-record 04s every 5 ms). The mean over the
    active stretch = the difference of two runs (100 ms apart, the same events) over their block counts."""
    k = kit_of(e)
    hz = R.timer_hz(e)
    pairs = [(t, w) for t in range(12) for w in range(5, 42) if w != 4]
    res = {}
    for n in (0, 16, 64, 128):
        ex = []
        for j in range(0, 400, 5):
            i = (j // 5 * 28) % max(1, n)
            recs = [(t, w, (j % 40) * 16 - 300) for t, w in (pairs[:n] * 3)[i:i + min(28, n)]]
            ex += usb(e.at(T0 + j), off_msg(k, 8, recs)) if n else []
        d = [pmo(e, e.run(f"cost{n}-{x}", T0 + x, [], script=[], extra=ex)["snap"]) for x in (200, 300)]
        if not d[0]:
            check(f"cost: {n} entries: pmo diagnostics there", False)
            return
        mean = (d[1]["t_sum"] - d[0]["t_sum"]) / max(1, d[1]["t_n"] - d[0]["t_n"]) * 1e6 / hz
        res[n] = (d[1]["used"], mean, d[1]["t_max"] * 1e6 / hz)
        print(f"    {n:3d} entries (used {d[1]['used']}): S mean {mean:.1f} us, max {res[n][2]:.1f} us a block (667 us)")
    # the worst cases: 128 live, then (a) 64 CLEARs in one USB burst, (b) 64 entries freed below the top and 64 new
    # ones in a burst (the holes), (c) a timeout fade of 128 (a reviewer's probe, scratch burst.py)
    pairs = [(t, w) for t in range(12) for w in range(5, 42) if w != 4]
    fill = []
    for i in range(0, 128, 28):
        fill += usb(e.at(T0 + 2 * (i // 28)), off_msg(k, 8, [(t, w, 640) for t, w in pairs[i:i + 28]]))
    worst = {}
    r = e.run("cost-clr", T0 + 60, [], script=[], extra=fill + usb(e.at(T0 + 30), clr_msg(k, 8, 1) * 64))
    worst["64 CLEARs"] = pmo(e, r["snap"])
    holes = []
    for i in range(63, 127, 28):
        holes += usb(e.at(T0 + 20 + (i - 63) // 28), off_msg(k, 0, [(t, w, 0) for t, w in pairs[i:min(127, i + 28)]]))
    new = []
    for i in range(128, 192, 28):
        new += usb(e.at(T0 + 40), off_msg(k, 8, [(t, w, 640) for t, w in pairs[i:min(192, i + 28)]]))
    r = e.run("cost-holes", T0 + 70, [], script=[], extra=fill + holes + new)
    worst["64 into holes"] = pmo(e, r["snap"])
    r = e.run("cost-fade", T0 + 300, [], script=[], extra=fill)
    worst["timeout fade"] = pmo(e, r["snap"])
    # (d) a hello and, in the same block, 63 overrides with a ramp and a CLEAR of every track queued (poked into the
    # ring: the same block for sure); (e) 128 entries: 96 route amounts (VM / AT 1..4 on 12 tracks, the SRAM routes
    # poked into words 1..8 and 9..41: 48 route4 calls a block) and 32 words, refreshed with ramps
    a = e.sym("pmo")
    rb = e.run("cost-fill", T0 + 40, [], script=[], extra=fill)
    rt = int.from_bytes(e.peek(rb["snap"], a + PMO_RT, 4), "big")
    hn = int.from_bytes(e.peek(rb["snap"], a + PMO_HELLO_N, 4), "big")
    recs = [(t, w, OP_OVR, 8, 0x2000, 64, k) for t, w in pairs[:63]] + [(0, 0, OP_CLR, 8, 0x1fff, 0, k)]
    pk = ring_pokes(a, rt, recs) + ["--poke", f"{a + PMO_RH:x}={rt + 64:08x}", "--poke", f"{a + PMO_HELLO_N:x}={hn + 1:08x}"]
    rc = from_snap(e, rb["snap"], "cost-comb", 20, events=[], script=None, extra=pk)
    d = pmo(e, rc["snap"])
    worst["hello + 64 records + CLEAR"] = dict(d, t_max=d["t_max"])
    ld = int.from_bytes(e.peek(rc["snap"], a + PMO_LINK_DROP, 4), "big")
    check("cost: the hello discards the 64 records still in the ring (link_drop 64): no drain, one fade",
          ld == 64 and d["used"] == 128, (ld, d["used"]))
    rpk = []
    for t in range(12):
        for j in range(8):
            w = (1 + j) if j in (0, 1, 4, 5) else (30 + j)
            rpk += ["--poke", f"{VM_ROUTES + 32 * t + 4 * j:x}={g_of(t, w):08x}"]
    rrec = [(t, 48 + j, 640 if j % 2 else -640) for t in range(12) for j in range(8)] + \
           [(t, w, 640) for t in range(4) for w in range(30, 38)]
    rex = []
    for j in range(0, 200, 5):
        i = (j // 5 * 28) % 128
        rex += usb(e.at(T0 + j), off_msg(k, 8, (rrec * 2)[i:i + 28]))
    rr = e.run("cost-routes", T0 + 220, [], script=[], extra=rpk + rex)
    worst["128 with 96 route amounts"] = pmo(e, rr["snap"])
    for n, d in worst.items():
        print(f"    {n}: used {d['used']}, S max {d['t_max'] * 1e6 / hz:.1f} us a block")
    check("cost: worst cases (64 CLEARs queued, 64 new entries into holes, a timeout fade, a hello with 64 records and a "
          "CLEAR, 96 route amounts; 128 live): max under 100 us",
          all(d["t_max"] * 1e6 / hz < 100 for d in worst.values()) and worst["64 into holes"]["used"] == 128,
          {n: round(d["t_max"] * 1e6 / hz, 1) for n, d in worst.items()})
    check("cost: idle: under 1 us a block", res[0][1] < 1, res[0])
    check("cost: 128 entries live, mean under 40 us (6 %), max under 100 us (15 %) a block",
          res[128][0] == 128 and res[128][1] < 40 and res[128][2] < 100, res[128])


TESTS = dict(caps=t_caps, offset=t_offset, ramp=t_ramp, stack=t_stack, override=t_override,
             override_plock=t_override_plock, scene=t_scene, scene_first=t_scene_first, ovr_ramp=t_ovr_ramp,
             hello_fade=t_hello_fade, clear_then=t_clear_then, slots=t_slots, ring_drop=t_ring_drop, lifetime=t_lifetime, kit=t_kit, kitload=t_kitload,
             never_kit=t_never_kit, velocity=t_velocity, vm=t_vm, refuse=t_refuse, full=t_full, status=t_status,
             clear=t_clear, fx=t_fx, cost=t_cost)
EXTRA = dict(m0a=m0a, m0c=m0c, m0d=m0d)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    e = R.Emu(sys.argv[1])
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    for n in names:
        print(f"== {n}", flush=True)
        (TESTS.get(n) or EXTRA[n])(e)
    print("ALL PASS" if not R.FAILS else f"FAILED: {R.FAILS}")
    sys.exit(1 if R.FAILS else 0)


if __name__ == "__main__":
    main()
