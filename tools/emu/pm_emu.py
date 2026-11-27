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
    # (a sample between stage A and S's write reads the base: left out of the steps (mv5's longer pmo_pre widened that
    # window); the end read from the settled snapshot)
    later = [y for y in x[top[-1]:] if y != base] if top else []
    dif = [abs(a - b) for a, b in zip(later, later[1:])]
    end = eff(e, r["snap"], 0, W_RES)
    check("ramp: the new target 0 over 64 blocks: no jump (each 0.5 ms moves <= 0x100), down to the base",
          later and max(dif or [0]) <= 0x100 and end == base, (max(dif or [0]), hex(end)))


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
    _, a = series(e, "stack-lfo", T0 + 300, lfo_pokes(), [(0, W_VOL)], every="0.37M")
    _, b = series(e, "stack-off", T0 + 300, lfo_pokes() + msg(off_msg(k, 0, [(0, W_VOL, -640)])), [(0, W_VOL)],
                  every="0.37M")
    a, b = a[(0, W_VOL)], b[(0, W_VOL)]
    n0 = int(len(a) * (T0 + 20) / (T0 + 300))
    d = [x - y for x, y in zip(a[n0:], b[n0:])]
    print(f"    LFO alone {[hex(x) for x in a[n0:n0 + 6]]}  + offset {[hex(x) for x in b[n0:n0 + 6]]}")
    check("stack: the LFO moves VOL", len(set(a[n0:])) > 4, len(set(a[n0:])))
    # A status line can fall inside the audio interrupt between the stock's rebuild of the effective array and S-post:
    # that sample reads the LFO's value without the offset (difference 0). Which samples do depends on the build's
    # timing (measured: 0 of 140 on cpl2 and 1 on cpl3 at every 0.4M; 15 and 11 of 144 at 0.39M, on both, every 13th).
    # So: 0x0a00 everywhere, but for single samples of 0 between two of 0x0a00, at most one in eight.
    odd = [i for i, x in enumerate(d) if x != 0xa00]
    lone = all(d[i] == 0 and (i == 0 or d[i - 1] == 0xa00) and (i + 1 == len(d) or d[i + 1] == 0xa00) for i in odd)
    check("stack: with the offset, eff = the LFO's - 0x0a00 at every sample after the message (a sample taken mid-interrupt apart)",
          d and lone and len(odd) * 8 <= len(d), (len(odd), len(d), sorted(set(d))[:6]))
    _, c = series(e, "stack-dep", T0 + 300, lfo_pokes(0x5000) + msg(off_msg(k, 0, [(0, W_DEP, 1024)])), [(0, W_VOL)],
                  every="0.37M")
    _, dd = series(e, "stack-dep2", T0 + 300, lfo_pokes(0x6000), [(0, W_VOL)], every="0.37M")
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
    _, a = series(e, "ovr-lfo-a", T0 + 200, lfo_pokes(), [(0, W_VOL)], every="0.37M")
    _, b = series(e, "ovr-lfo-b", T0 + 200, lfo_pokes() + usb(e.at(T0), ovr_msg(k, 0, [(0, W_VOL, v, 127, 1)])),
                  [(0, W_VOL)], every="0.37M")
    a, b = a[(0, W_VOL)], b[(0, W_VOL)]
    n0 = int(len(a) * (T0 + 20) / (T0 + 200))
    # (a sample between stage A and pm's S write reads the LFO's word alone, b == a: the sampling gap, dropped; most
    # samples must be past it)
    idx = [i for i in range(n0, min(len(a), len(b))) if b[i] != a[i]]
    bad = [i for i in idx if b[i] != max(0, min(0x7fff, 0x3200 + a[i] - base))]
    check("override: with LFO 1 on VOL: eff = 0x3200 + (the LFO run's eff - base), every sample", len(a) > n0 and
          not bad and len(idx) * 3 > (len(a) - n0) * 2 and len(set(b[n0:])) > 3,
          [(hex(a[i]), hex(b[i])) for i in bad[:4]] or (len(idx), len(a) - n0))


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
          st and st[-1][6] & 3 == 3, st)


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
    # (on before: hello-on's snapshot is never moved (from_snap's base), so inside the interrupt read the entry's offset)
    sl = e.peek(r["snap"], a + PMO_IDX + W_RES, 1)[0] - 1
    on = eff(e, r["snap"], 0, W_RES) == base + 0xa00 or (
        mid_isr(e, r["snap"]) and sl >= 0 and
        int.from_bytes(e.peek(r["snap"], a + PMO_ENT + PMO_ENT_SZ * sl + 4, 4), "big", signed=True) == 640 << 10)
    check("hello_fade: on before (+10 steps); a fade (values between over 32 blocks: 1..45 samples of 0.5 ms); the "
          "base, freed, no timeout", on and 0 < len(mid) <= 45 and
          eff(e, r2["snap"], 0, W_RES) == base and d and d["used"] == 0 and d["timeouts"] == 0, (len(mid), d))


def t_rehello_nofade(e):
    """0.5.2 re-hello (review M2): the host asks the Rytm for its hello again (3C 01 01) while a modulation runs: the hello
    comes (a second one), the modulated word does not move (no fade: the link is the same). A port-up hello fades it
    (hello_fade)."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    base = tgt(e, s0, 0, W_RES)
    ex = []
    for i in range(8):   # (refreshed before the 250 ms timeout)
        ex += usb(e.at(T0 + 150 * i), off_msg(k, 0, [(0, W_RES, 640)]))
    ex += usb(e.at(T0 + 500), P.rui_rehello())
    r, v = series(e, "rehello-nofade", T0 + 1300, ex, [(0, W_RES)], every="0.2M")
    x = v[(0, W_RES)]
    up = [i for i, y in enumerate(x) if y != base]
    h = R.evs(r, "hello")
    print(f"    {len(x)} samples, first move at {up[:1]}, values {sorted({hex(y) for y in x})}, hellos {len(h)}")
    check("rehello_nofade: the request was answered (a second hello)", len(h) == 2, h)
    check("rehello_nofade: the modulated word rises to base + 0x0a00 and stays there across the re-hello (no fade)",
          up and {y for y in x[up[0]:]} == {base + 0xa00}, sorted({hex(y) for y in x}))


def t_portup_fade(e):
    """(M2's other side) The port-up hello (0.35 s after the base: pm_hello set by the tick, counted by flush) still fades a
    running modulation: an offset sent from 0.1 s on, refreshed, dips to between the base and its value at the hello."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    base = tgt(e, s0, 0, W_RES)
    ex = []
    for i in range(10):
        ex += usb(e.at(100 + 100 * i), off_msg(k, 0, [(0, W_RES, 640)]))
    r, v = series(e, "portup-fade", 1100, ex, [(0, W_RES)], every="0.2M")
    x = v[(0, W_RES)]
    up = [i for i, y in enumerate(x) if y != base]
    mid = [y for y in x[up[0]:] if y not in (base, base + 0xa00)] if up else []
    check("portup_fade: the offset rises, and the port-up hello fades it (values between the base and the offset)",
          up and mid, (up[:1], sorted({hex(y) for y in x})))


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
        # A snapshot can fall inside the audio interrupt between the stock's rebuild of the effective array and S-post:
        # the word then reads without the route's change. Sampled every 0.065 ms that is one reading in ten, once a
        # block (cpl4, tracks 0 and 1). A run's end is a whole number of 5 ms, 7.5 blocks, so plain end times meet a block
        # at two phases only and can sit in that window every time (cpl4: T0 + 300, 305, 310 all did on track 1). So five
        # ends spread over one block (133 k instructions), and the value most of them read.
        got = []
        for off in (0, 29, 61, 97, 127):
            r = e.run(name, T0 + 300, [(T0 + 100, "press", pad)], script=[],
                      extra=["--poke", f"{SOUND0 + 2531 * k + 152 * t + (0x8c if at else 0x70):x}={amt:04x}{w:02x}00"] +
                      list(pk) + m + ["--instr", f"{(T0 + 300) * 200 + off}k"])
            got.append(eff(e, r["snap"], t, w))
        return max(set(got), key=got.count), r
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
    """M11 / 07: 2D 01 11 <slots> <ring drops hi lo> <kit drops hi lo> <timeouts> <flags> <morph parts (P3)>: two
    entries, flags bit 1, no morph part."""
    k = kit_of(e)
    r = e.run("status", T0 + 100, [], script=[], extra=usb(e.at(T0), off_msg(k, 0, [(0, W_RES, 64), (1, W_RES, 64)])) +
              usb(e.at(T0 + 30), stat_msg()))
    st = stats(r)
    check("status: one answer, 8 bytes: slots 2, drops 0, kit drops 0, timeouts 0, flags bit 1 (ran), morph parts 0 (P3)",
          len(st) == 1 and len(st[0]) == 8 and st[0][:6] == [2, 0, 0, 0, 0, 0] and st[0][6] & 2 and st[0][7] == 0, st)


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


# ---- P3 (morph v2 Task 11): 09 MORPH-SET / 0A FADER, the Rytm interpolates (design.md "pm morph")
OP_MSET, OP_FAD = 0x09, 0x0A
PMO_MORPH = 10080              # pmo's morph fields (rui.c, after rany): fad, fad_st, fad_tg, fad_n, mused, then mph[128]


def mset_msg(kit, recs):
    """09 MORPH-SET: recs [(t, w, flags 1 A / 2 B, a, b)], a and b 1/128 step (0..16383); flags 0 removes the part."""
    b = [OP_MSET, kit, len(recs)]
    for t, w, fl, a, bb in recs:
        b += [t, w, fl, a >> 7 & 0x7f, a & 0x7f, bb >> 7 & 0x7f, bb & 0x7f]
    return P._msg(P.HOST_CMD, b)


def fad_msg(kit, f, ramp=0):
    """0A FADER: f 0..16383, ramp in blocks"""
    return P._msg(P.HOST_CMD, [OP_FAD, kit, f >> 7 & 0x7f, f & 0x7f, ramp])


def morph_want(base, fl, a, b, f):
    """The arithmetic model (the host's sim/pm_model.py, rytm-param-mod 5.3) in 8.8: both sides a + (b - a) f; A only
    the override a at the mix 1 - f; B only b at the mix f"""
    x = f / 16383.0
    if fl == 3:
        return 2 * a + 2 * (b - a) * x
    if fl == 1:
        return base + (1 - x) * (2 * a - base)
    return base + x * (2 * b - base)


def mused(e, snap):
    return int.from_bytes(e.peek(snap, e.sym("pmo") + PMO_MORPH + 16, 4), "big")


def eff_at(e, r, words):
    """{(t, w): [(ms after the base, u16)]} from a run with DTBOOT_PEEK of the words' longs"""
    out = {}
    for t, w in words:
        a = EFF + 2 * g_of(t, w)
        sh = 16 if a % 4 == 0 else 0
        out[(t, w)] = [((c - e.clock) * 5, v >> sh & 0xffff) for c, v in peek_series(r, a & ~3)]
    return out


def peek_run(e, name, ms, ex, words, every="0.37M"):
    addrs = sorted({(EFF + 2 * g_of(t, w)) & ~3 for t, w in words})
    r = e.run(name, ms, [], script=[], extra=list(ex) + ["--every", every],
              env=dict(DTBOOT_PEEK=",".join(f"{a:x}" for a in addrs)))
    return r, eff_at(e, r, words)


def settled(xs, t0, t1, base):
    """The value xs [(ms, v)] holds in [t0, t1]: the most common sample that is not the base. A sample can fall between
    stage A (eff = the base, every block) and S's write (P2's pm scene artifact): those are left out; none left: the
    base."""
    c = {}
    for t, v in xs:
        if t0 <= t <= t1 and v != base:
            c[v] = c.get(v, 0) + 1
    return max(c, key=c.get) if c else base


def near(xs, t, base):
    return settled(xs, t - 3, t + 3, base)


def t_pmoop(e):
    """Review L2 (the guard for P3): a frame whose op is not one pm knows, shaped as a 05 record (09, 0A, 0C, 7F):
    refused (2D 01 10 <op> 1) and nothing stored: the slot index and the entry table byte for byte as a run without
    them, no entry used. On rc5b qp_cmd filters (only 04..07 reach pmo_cmd); once 09 / 0A are routed, pmo_cmd must
    refuse what it does not know itself (it stored any other op as a 05)."""
    k = kit_of(e)
    a = e.sym("pmo")
    ops = [OP_MSET, OP_FAD, 0x0C, 0x7F]
    ex = []
    for i, op in enumerate(ops):
        ex += usb(e.at(T0 + 20 * i), P._msg(P.HOST_CMD, [op, k, 0, 1, 0, W_RES, 0x10, 0, 127]))
    r = e.run("pmoop", T0 + 120, [], script=[], extra=ex)
    n = e.run("pmoop-none", T0 + 120, [], script=[])
    tab = lambda s: e.peek(s, a + PMO_IDX, PMO_ENT - PMO_IDX) + e.peek(s, a + PMO_ENT, PMO_ENT_SZ * 128)   # noqa: E731
    d = pmo(e, r["snap"])
    check("pmoop: 09 / 0A / 0C / 7F shaped as a 05: each refused (10 <op> 1)", acks(r) == [[op & 0x7f, 1] for op in ops],
          acks(r))
    check("pmoop: nothing stored (index and entries as without the frames, no entry used, no record taken)",
          tab(r["snap"]) == tab(n["snap"]) and d and d["used"] == 0 and d["recs"] == 0, d)


MW = [(0, W_FRQ, 3, 0x1000, 0x3000), (0, W_RES, 3, 0x3800, 0x0800), (1, W_FRQ, 3, 0, 16383), (0, W_VOL, 3, 0x2000, 0x2400)]
FSTEPS = [0, 2048, 4096, 8192, 12288, 16383, 12288, 4096, 0]


def t_morph(e):
    """09 with 4 entries (both sides), then the fader stepped 0 -> 16383 -> 0 by 0A (ramp 0, 10 ms a step): at the
    middle of each step the effective word = the model's a + (b - a) f within 1 LSB (8.8); the kit's sound bytes and
    the targets untouched; 4 morph parts in use (07's last byte, the books)."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    ex = usb(e.at(T0), fad_msg(k, 0)) + usb(e.at(T0 + 1), mset_msg(k, MW))
    for i, f in enumerate(FSTEPS):
        ex += usb(e.at(T0 + 5 + 10 * i), fad_msg(k, f))
    ex += usb(e.at(T0 + 100), stat_msg())
    r, v = peek_run(e, "morph", T0 + 160, ex, [x[:2] for x in MW])   # 07 is answered by the UI tick: a whole tick after it
    sn = r["snap"]
    bad = []
    for t, w, fl, a, b in MW:
        for i, f in enumerate(FSTEPS):
            got, want = near(v[(t, w)], T0 + 10 + 10 * i, tgt(e, s0, t, w)), morph_want(0, fl, a, b, f)
            if got is None or abs(got - want) > 1:
                bad.append((t, w, f, got, round(want, 1)))
    print(f"    FRQ at each step {[hex(near(v[(0, W_FRQ)], T0 + 10 + 10 * i, tgt(e, s0, 0, W_FRQ))) for i in range(len(FSTEPS))]}")
    check("morph: the effective word = the model's a + (b - a) f (+-1) at every fader step, all 4 words", not bad, bad[:6])
    check("morph: the kit's sound bytes (BD, SD) and the targets unchanged",
          sound(e, sn) == sound(e, s0) and sound(e, sn, 1) == sound(e, s0, 1) and
          all(tgt(e, sn, t, w) == tgt(e, s0, t, w) for t, w, *_ in MW))
    st, d = stats(r), pmo(e, sn)
    check("morph: 4 entries, 4 morph parts (the books; 07's answer: slots 4, its 8th byte 4)",
          d and d["used"] == 4 and mused(e, sn) == 4 and st and len(st[-1]) == 8 and st[-1][0] == 4 and st[-1][7] == 4,
          (d and d["used"], mused(e, sn), st))
    h = R.evs(r, "hello")
    check("morph: the hello's caps2 has bit 3 (8: ops 09 / 0A)", bool(h) and all(x.get("caps2", 0) & 8 for x in h),
          [x.get("caps2") for x in h])


def t_morph_onesided(e):
    """A only (RES, flags 1) and B only (VOL, flags 2): f 0 -> RES the A value, VOL the base; f 8192 halfway; f 16383
    -> RES back to the base, VOL the B value (the model's override at the mix 1 - f / f, +-1); the entries kept at a
    mix of 0 (2 used)."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    rb, vb = tgt(e, s0, 0, W_RES), tgt(e, s0, 0, W_VOL)
    recs = [(0, W_RES, 1, 0x3000, 0), (0, W_VOL, 2, 0, 0x1000)]
    ex = usb(e.at(T0), fad_msg(k, 0)) + usb(e.at(T0 + 1), mset_msg(k, recs))
    fs = [0, 8192, 16383]
    for i, f in enumerate(fs):
        ex += usb(e.at(T0 + 5 + 10 * i), fad_msg(k, f))
    r, v = peek_run(e, "morph-1s", T0 + 40, ex, [(0, W_RES), (0, W_VOL)])
    bad = []
    for (t, w, fl, a, b), base in zip(recs, (rb, vb)):
        for i, f in enumerate(fs):
            got, want = near(v[(t, w)], T0 + 10 + 10 * i, base), morph_want(base, fl, a, b, f)
            if got is None or abs(got - want) > 1:
                bad.append((w, f, got, round(want, 1)))
    print(f"    RES {[hex(near(v[(0, W_RES)], T0 + 10 + 10 * i, rb)) for i in range(3)]} (base {rb:#x}), "
          f"VOL {[hex(near(v[(0, W_VOL)], T0 + 10 + 10 * i, vb)) for i in range(3)]} (base {vb:#x})")
    check("morph_onesided: A only: A at f 0, the base at f 1; B only: the base at f 0, B at f 1; halfway between (+-1)",
          not bad, bad)
    d = pmo(e, r["snap"])
    check("morph_onesided: both entries kept (a part at mix 0 is not freed)", d and d["used"] == 2 and mused(e, r["snap"]) == 2,
          (d, mused(e, r["snap"])))


def t_morph_ramp(e):
    """0A with ramp 8 (FRQ a 0, b 16383: 0 -> 0x7ffe): sampled every 0.25 ms, no step bigger than the model's one block
    (0x7ffe / 8, +2), the climb in between (at least 5 values between), then the top; 0A ramp 0 back down: one jump."""
    k = kit_of(e)
    ex = usb(e.at(T0), fad_msg(k, 0)) + usb(e.at(T0 + 1), mset_msg(k, [(0, W_FRQ, 3, 0, 16383)])) + \
        usb(e.at(T0 + 10), fad_msg(k, 16383, 8)) + usb(e.at(T0 + 30), fad_msg(k, 0, 0))
    base = tgt(e, os.path.join(R.EMU, e.snap), 0, W_FRQ)
    r, v = peek_run(e, "morph-ramp", T0 + 40, ex, [(0, W_FRQ)], every="0.05M")
    x = [y for t, y in v[(0, W_FRQ)] if T0 + 8 <= t <= T0 + 28 and y != base]   # (stage A's window left out: settled;
    #                                                                              from +8: the part's own ramp-in done)
    up = [b - a for a, b in zip(x, x[1:])]
    mid = [y for y in x if 0 < y < 0x7ffe]
    print(f"    the climb: {len(mid)} values between, the biggest step {max(up or [0]):#x}, {[hex(y) for y in mid[:10]]}")
    check("morph_ramp: ramp 8: no step above one block's (0x7ffe / 8 + 2), at least 5 values between, the top reached",
          up and max(up) <= 0x7ffe // 8 + 2 and min(up) >= 0 and len(mid) >= 5 and x[-1] == 0x7ffe, (max(up or [0]), len(mid)))
    y = settled(v[(0, W_FRQ)], T0 + 33, T0 + 40, base)
    check("morph_ramp: ramp 0 back to f 0: FRQ at a (0)", y == 0, hex(y))


def t_morph_start(e):
    """Review M3: a new part on a fresh word (FRQ, both sides 0x1000: 8.8 0x2000; the fader at 8192 first) ramps its mix
    in over PMO_MREL (8 blocks, 5.3 ms) as a 05 does, never one jump from the base: sampled every 0.25 ms, at least 3
    values between the base and the part's value (more than 1 LSB from both), then the part's value."""
    k = kit_of(e)
    base = tgt(e, os.path.join(R.EMU, e.snap), 0, W_FRQ)
    ex = usb(e.at(T0), fad_msg(k, 8192)) + usb(e.at(T0 + 5), mset_msg(k, [(0, W_FRQ, 3, 0x1000, 0x1000)]))
    r, v = peek_run(e, "morph-start", T0 + 30, ex, [(0, W_FRQ)], every="0.05M")
    xs = [y for t, y in v[(0, W_FRQ)] if T0 + 3 <= t <= T0 + 25]
    lo, hi = sorted((base, 0x2000))
    mid = sorted({y for y in xs if lo + 1 < y < hi - 1})
    print(f"    base {base:#x}: {len(mid)} values between, {[hex(y) for y in mid[:10]]}")
    check("morph_start: a new part ramps in: at least 3 values between the base and the part's value", len(mid) >= 3,
          [hex(y) for y in mid])
    y = settled(v[(0, W_FRQ)], T0 + 20, T0 + 30, base)
    check("morph_start: then the part's value (0x2000 +-1)", abs(y - 0x2000) <= 1, hex(y))


def t_morph_rehello(e):
    """(next build: morph v2 on the re-hello tip) A re-hello (3C 01 01) while a morph part plays: the hello comes (a
    second one) and the part stays: FRQ holds the model's value at the fader's 0.5 at every sample after it first gets
    there, no fade dip, one morph part and one entry at the end (a re-hello must not step pmo.hello_n, as for 04 / 05:
    rehello_nofade). The fader is re-sent every 150 ms (before the 250 ms timeout)."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    t, w, fl, a, b = 0, W_FRQ, 3, 0x1000, 0x3000
    want = morph_want(0, fl, a, b, 8192)
    ex = usb(e.at(T0), fad_msg(k, 8192)) + usb(e.at(T0 + 1), mset_msg(k, [(t, w, fl, a, b)]))
    for i in range(1, 8):
        ex += usb(e.at(T0 + 150 * i), fad_msg(k, 8192))
    ex += usb(e.at(T0 + 500), P.rui_rehello())
    r, v = series(e, "morph-rehello", T0 + 1300, ex, [(t, w)], every="0.2M")
    x = v[(t, w)]
    at = [i for i, y in enumerate(x) if abs(y - want) <= 1]
    off = [hex(y) for y in x[at[0]:] if abs(y - want) > 1] if at else []
    h = R.evs(r, "hello")
    d = pmo(e, r["snap"])
    print(f"    {len(x)} samples, at the value from {at[:1]}, off it after {off[:8]}, hellos {len(h)}, want {want:.1f}")
    check("morph_rehello: the request was answered (a second hello)", len(h) == 2, h)
    check("morph_rehello: FRQ at the morph's value (+-1) from the start and at every sample across the re-hello (no fade)",
          at and not off, (at[:1], off[:8], sorted({hex(y) for y in x})[:12]))
    check("morph_rehello: one entry, one morph part at the end (the part not dropped)",
          d and d["used"] == 1 and mused(e, r["snap"]) == 1, (d and d["used"], mused(e, r["snap"])))


def t_morph_timeout(e):
    """09 + 0A (f 8192) and no message after them: still on at +240 ms; the 250 ms timeout fades it out like a 05
    (values between, sampled every 1 ms: 1..22), back to the base by +275 ms, the entry and its part freed, one timeout."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    base = tgt(e, s0, 0, W_RES)
    m = usb(e.at(T0), fad_msg(k, 8192)) + usb(e.at(T0 + 1), mset_msg(k, [(0, W_RES, 3, 0x3000, 0x1000)]))
    want = round(morph_want(base, 3, 0x3000, 0x1000, 8192))
    r, v = peek_run(e, "morph-to", T0 + 280, m, [(0, W_RES)], every="0.2M")
    x = v[(0, W_RES)]
    on = near(x, T0 + 240, base)
    mid = [y for t, y in x if t > T0 + 240 and y not in (want - 1, want, want + 1) and min(base, want) < y < max(base, want)]
    d = pmo(e, r["snap"])
    check("morph_timeout: +240 ms still the morph's value (+-1)", on is not None and abs(on - want) <= 1, (hex(on or 0), hex(want)))
    check("morph_timeout: then a fade (1..22 values between), the base at +280 ms, freed (no entry, no part), one timeout",
          0 < len(mid) <= 22 and settled(x, T0 + 275, T0 + 280, base) == base and d and d["used"] == 0 and
          d["timeouts"] == 1 and mused(e, r["snap"]) == 0, (len(mid), d, mused(e, r["snap"])))


def t_morph_kit(e):
    """A kit change (the active kit poked between two runs, as t_kit) frees every entry and its morph part at once; a
    09 for the old kit after it is dropped (counted)."""
    k = kit_of(e)
    m = usb(e.at(T0), fad_msg(k, 4096)) + usb(e.at(T0 + 1), mset_msg(k, MW))
    r = e.run("morph-kit-on", T0 + 50, [], script=[], extra=m)
    check("morph_kit: on before (4 parts)", mused(e, r["snap"]) == 4, mused(e, r["snap"]))
    pk = ["--poke", f"{ACTIVE_KIT:x}={(k + 1) & 127:08x}"]
    r2 = from_snap(e, r["snap"], "morph-kit-chg", 20, events=[], script=None, extra=pk)
    d = pmo(e, r2["snap"])
    check("morph_kit: the kit change frees every entry and part", d and d["used"] == 0 and mused(e, r2["snap"]) == 0,
          (d, mused(e, r2["snap"])))


def t_morph_slots(e):
    """The 128 slots are shared with 04 / 05: 128 offsets live, a 09 on a 129th (t, w) refused (2D 01 10 09 2) and not
    stored; a 09 on a (t, w) that has an offset takes that slot (128 used, 1 part)."""
    k = kit_of(e)
    pairs = [(t, w) for t in range(12) for w in list(range(5, 42)) if w != 4][:129]
    ex = []
    for i in range(0, 128, 28):
        ex += usb(e.at(T0 + 10 * (i // 28)), off_msg(k, 0, [(t, w, 64) for t, w in pairs[i:min(128, i + 28)]]))
    t9, w9 = pairs[128]
    ex += usb(e.at(T0 + 80), mset_msg(k, [(t9, w9, 3, 0x1000, 0x2000)]))
    ex += usb(e.at(T0 + 100), mset_msg(k, [(pairs[0][0], pairs[0][1], 3, 0x1000, 0x2000)]))
    r = e.run("morph-slots", T0 + 160, [], script=[], extra=ex)
    d = pmo(e, r["snap"])
    a = acks(r)
    check("morph_slots: the 129th (a 09) refused full: 10 09 2, nothing else", a == [[OP_MSET, 2]], a)
    check("morph_slots: 128 used, 1 morph part (on a slot an offset had)", d and d["used"] == 128 and mused(e, r["snap"]) == 1,
          (d and d["used"], mused(e, r["snap"])))


def t_morph_mix_05(e):
    """A 05 override (VOL 50 steps, mix 127, jump) and a 09 morph (FRQ a 0x1000 b 0x3000, f 8192) at once, plus a 04
    offset on the morph's word (FRQ -4 steps): VOL 0x3200, FRQ the model's - 0x400 (+-1)."""
    k = kit_of(e)
    ex = usb(e.at(T0), fad_msg(k, 8192)) + usb(e.at(T0 + 1), mset_msg(k, [(0, W_FRQ, 3, 0x1000, 0x3000)])) + \
        usb(e.at(T0 + 2), ovr_msg(k, 0, [(0, W_VOL, 50 * 128, 127, 1)])) + usb(e.at(T0 + 3), off_msg(k, 0, [(0, W_FRQ, -256)]))
    s0 = os.path.join(R.EMU, e.snap)
    r, v = peek_run(e, "morph-05", T0 + 40, ex, [(0, W_VOL), (0, W_FRQ)])
    sn = r["snap"]
    want = morph_want(0, 3, 0x1000, 0x3000, 8192) - 0x400
    vol, frq = (settled(v[(0, w)], T0 + 20, T0 + 40, tgt(e, s0, 0, w)) for w in (W_VOL, W_FRQ))
    check("morph_mix_05: VOL the 05's 0x3200, FRQ the morph's - 4 steps (+-1)", vol == 0x3200 and abs(frq - want) <= 1,
          (hex(vol), hex(frq), hex(round(want))))
    d = pmo(e, sn)
    check("morph_mix_05: 2 entries, 1 part", d and d["used"] == 2 and mused(e, sn) == 1, (d, mused(e, sn)))


def t_morph_remove(e):
    """09 with flags 0 removes the part: the word ramps back to the base (8 blocks) and the entry is freed."""
    k = kit_of(e)
    s0 = os.path.join(R.EMU, e.snap)
    base = tgt(e, s0, 0, W_RES)
    ex = usb(e.at(T0), fad_msg(k, 16383)) + usb(e.at(T0 + 1), mset_msg(k, [(0, W_RES, 3, 0, 0x1000)])) + \
        usb(e.at(T0 + 20), mset_msg(k, [(0, W_RES, 0, 0, 0)]))
    r = e.run("morph-rm", T0 + 40, [], script=[], extra=ex)
    d = pmo(e, r["snap"])
    check("morph_remove: flags 0: back to the base, the entry and its part freed",
          eff(e, r["snap"], 0, W_RES) == base and d and d["used"] == 0 and mused(e, r["snap"]) == 0,
          (hex(eff(e, r["snap"], 0, W_RES)), d, mused(e, r["snap"])))


def t_morph_refuse(e):
    """09 / 0A refusals (2D 01 10 <op> 1): n 0, n 21, a bad length, flags 4, the jump bit on w, word 4, word 48 (VM),
    track 13; 0A with 4 bytes. Nothing stored."""
    k = kit_of(e)
    rec = [0, W_RES, 3, 0, 1, 0, 1]
    bad = [P._msg(P.HOST_CMD, [OP_MSET, k, 0]), P._msg(P.HOST_CMD, [OP_MSET, k, 21] + rec * 21),
           P._msg(P.HOST_CMD, [OP_MSET, k, 1] + rec[:6]), P._msg(P.HOST_CMD, [OP_MSET, k, 1, 0, W_RES, 4, 0, 1, 0, 1]),
           P._msg(P.HOST_CMD, [OP_MSET, k, 1, 0, W_RES | 0x40, 3, 0, 1, 0, 1]),
           P._msg(P.HOST_CMD, [OP_MSET, k, 1, 0, 4, 3, 0, 1, 0, 1]), P._msg(P.HOST_CMD, [OP_MSET, k, 1, 0, 48, 3, 0, 1, 0, 1]),
           P._msg(P.HOST_CMD, [OP_MSET, k, 1, 13, W_RES, 3, 0, 1, 0, 1]), P._msg(P.HOST_CMD, [OP_FAD, k, 0, 1])]
    ex = []
    for i, m in enumerate(bad):
        ex += usb(e.at(T0 + 20 * i), m)
    r = e.run("morph-refuse", T0 + 20 * len(bad) + 60, [], script=[], extra=ex)
    d = pmo(e, r["snap"])
    check("morph_refuse: each refused in order (10 09 1 x 8, 10 0A 1)", acks(r) == [[OP_MSET, 1]] * 8 + [[OP_FAD, 1]], acks(r))
    check("morph_refuse: nothing stored", d and d["used"] == 0 and d["recs"] == 0, d)


def t_morph_cost(e):
    """The S stage's time per block with 128 morph parts live (09 x 7, both sides) and the fader ramping (0A every 5 ms,
    ramp 8, 0 <-> 16383): max under 100 us (t_cost's margin); mean under 80 us (12 %: the parts' own pass is about as much
    again as t_cost's 128 plain entries, 38.6 us on mv8; measured 74.5 us. 128 parts is the worst case: the slots full)."""
    k = kit_of(e)
    hz = R.timer_hz(e)
    pairs = [(t, w) for t in range(12) for w in range(5, 42) if w != 4][:128]
    ex = []
    for i in range(0, 128, 20):
        ex += usb(e.at(T0 + i // 20), mset_msg(k, [(t, w, 3, 0x1000, 0x3000) for t, w in pairs[i:i + 20]]))
    for j in range(10, 400, 5):
        ex += usb(e.at(T0 + j), fad_msg(k, 16383 if (j // 5) % 2 else 0, 8))
    d = [pmo(e, e.run(f"mcost-{x}", T0 + x, [], script=[], extra=ex)["snap"]) for x in (200, 300)]
    mean = (d[1]["t_sum"] - d[0]["t_sum"]) / max(1, d[1]["t_n"] - d[0]["t_n"]) * 1e6 / hz
    mx = d[1]["t_max"] * 1e6 / hz
    print(f"    128 morph parts (used {d[1]['used']}), the fader ramping: S mean {mean:.1f} us, max {mx:.1f} us a block (667 us)")
    check("morph_cost: 128 parts live, mean under 80 us (12 %), max under 100 us (15 %) a block",
          d[1]["used"] == 128 and mean < 80 and mx < 100, (d[1]["used"], round(mean, 1), round(mx, 1)))


TESTS = dict(caps=t_caps, offset=t_offset, ramp=t_ramp, stack=t_stack, override=t_override,
             override_plock=t_override_plock, scene=t_scene, scene_first=t_scene_first, ovr_ramp=t_ovr_ramp,
             hello_fade=t_hello_fade, rehello_nofade=t_rehello_nofade, portup_fade=t_portup_fade, clear_then=t_clear_then, slots=t_slots, ring_drop=t_ring_drop, lifetime=t_lifetime, kit=t_kit, kitload=t_kitload,
             never_kit=t_never_kit, velocity=t_velocity, vm=t_vm, refuse=t_refuse, full=t_full, status=t_status,
             clear=t_clear, fx=t_fx, cost=t_cost, pmoop=t_pmoop, morph=t_morph, morph_onesided=t_morph_onesided,
             morph_ramp=t_morph_ramp, morph_start=t_morph_start, morph_rehello=t_morph_rehello, morph_timeout=t_morph_timeout, morph_kit=t_morph_kit, morph_slots=t_morph_slots,
             morph_mix_05=t_morph_mix_05, morph_remove=t_morph_remove, morph_refuse=t_morph_refuse, morph_cost=t_morph_cost)
EXTRA = dict(m0a=m0a, m0c=m0c, m0d=m0d)


def mid_isr(e, snap):
    """the snapshot ends inside the audio interrupt between pmo_pre and pmo_post's end: there the effective words 9..41
    may already be rebuilt from the state (stage A) without pm's entries, and read as the base. pmo.runs counts at
    pmo_pre, pmo.t_n at pmo_post's end. (Measured on mv5, 2026-11-14: P3's longer pmo_pre moved the end of a T0 + 100
    run past stage A; on mv4 the same point still showed the block before's words.)"""
    try:
        pa = e.sym("pmo")
    except KeyError:
        return False
    hdr = e.peek(snap, pa, 48)
    return int.from_bytes(hdr[24:28], "big") != int.from_bytes(hdr[44:48], "big")


FROM_SNAP_BASES = {"ring-pre", "hello-on", "cost-fill", "morph-kit-on",
                   "cost-comb"}   # (cost-comb: its 20 ms is inside the hello's 32-block fade: never moved past it)


def settled_runs(e):
    """e.run, its end moved on one run unit (5 ms: rui_emu runs whole M of instructions) while the snapshot is mid_isr
    (3 tries): a snapshot's words read whole. A run's events keep their times."""
    run = e.run

    def run_settled(name, ms, *a, **k):
        r = None
        if name in FROM_SNAP_BASES or "--instr" in k.get("extra", ()):   # (a later from_snap's events are timed from
            #                             this run's end; a run with its own end (vm's phases): never moved)
            return run(name, ms, *a, **k)
        for i in range(3):
            r = run(name, ms + 5 * i, *a, **k)
            if not r or not r.get("snap") or not mid_isr(e, r["snap"]):
                return r
        return r
    e.run = run_settled


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    e = R.Emu(sys.argv[1])
    settled_runs(e)
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    for n in names:
        print(f"== {n}", flush=True)
        try:
            (TESTS.get(n) or EXTRA[n])(e)
        except R.EmuTimeout as ex:
            print(f"  {ex} (the test is abandoned)", flush=True)
    print("ALL PASS" if not R.FAILS else f"FAILED: {R.FAILS}")
    sys.exit(1 if R.FAILS else 0)


if __name__ == "__main__":
    main()
