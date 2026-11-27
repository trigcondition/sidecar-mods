#!/usr/bin/env python3
"""Emulator probes for MORPH scenes v2 (0026, 0.5.0): P0 of the morph-v2 plan, nothing of the mod changed. Each probe
prints what it measured and ends PASS / FAIL against the plan's guess.

    .venv/bin/python tools/emu/ms_emu.py TAG PROBE [PROBE ...]|all     exit 0 when every check passes

TAG: a rui build (tools/build_rui.sh) whose base tools/emu/us_base.sh TAG made (OS 1.74: run from the port tree,
build/os/1.74, so the stock base below is 1.74's). Runs reuse sq_emu.py's Emu (times are M instructions after the
base, 200 M = 1 emulated second, DTEMU_STRICT=1) and rled_emu.py's stock base and state comparison.

  mute        the QUICK PERF mute word: FUNC + QPER toggles 0x8000ed74 (the stage G gate), the kit's + 2495 behind it;
              muted, the knob still moves its macros' amounts and QP_POS, stage G adds nothing; per kit (RELOAD, SAVE,
              LOAD KIT)
  padword     param_apply_delta (0x400378a6, the same on 1.73 and 1.74): at +0x1c (0x400378c2) the record id, the
              track (d0), FUNC; the ROM record's +0x04 (stride 0x34) against the sound word map
  padtrig     GRID REC with T15 held, live REC while playing: a FLTR FRQ turn's p-lock is written inside
              param_apply_delta (a run with the function made a bare rts writes nothing)
  padbase     the target word 0x8000e57c[26 + 42 t + w]: the kit value, a p-lock, a pm override
  pagekeys    stock 1.74 (no mod): PAGE held + T1..T16 against T alone, PAGE alone; contexts as rled's stockup
  pagelen     stock 1.74: PAGE alone and PAGE + T15 on a 64-step pattern (PAGE steps the pattern page)
  pagecatch   the TAG build: 0026's key handler sees PAGE then T15 / T16 on every context (call count of rui_key)
  leds        seq mode (2E + GRID REC: 0026 owns the trig LEDs on a stock page): T15 blue / T16 yellow by 34, sampled
              while playing on FLTR / SRC: every slot holds the colour (stock's slot messages rewritten)
  edcap .. m2 P2 Task 9 (the scene edit on stock pages, "ms"): edcap (the turn reported, never written; T16), edfx
              (the FX track; the TRIG page refused), edgrid (GRID REC, live REC: nothing written), edpick (T3 under the
              side), edpage (PAGE alone as stock), edleds, edread (5A 01 08), edhello (a hello clears it), m2 (host page)
  qpmute      P2 Task 8: 0E flags bit 2 = the macros muted (FUNC + QPER, a knob move, RELOAD); caps2 bit 1
  hdr         the TAG build: rui_draw (ev_draw, after stock's drawAll) runs on stock pages every frame
  pagelat .. pageunarm, edrate   the flash review's gaps (M1 PAGE timing, M3 redraw rate): PAGE's latency table, fast
              taps, chords on every context, taps while playing, after a port drop; the readout's redraw count

RYTM_EMU, RYTM_TEENSY: as sq_emu.py.
"""
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sq_emu as S     # noqa: E402  (Emu, sx, mask2e)
import rled_emu as L   # noqa: E402  (stock base, stock_state, combo_only_parts)

FAILS = []
STOCK = []   # declared stock-fact probes (check(stock=True)), kept out of the verdict
REC_ROM = 0x401bf918        # the ROM parameter records (this tree's OS 1.73 value: the port moves it), stride 0x34 [code: 0x40006d34's lea]
PAD, PAD_1C = 0x400378a6, 0x400378c2
GATE, KIT0 = 0x8000ed74, 0x412558e3          # stage G's gate; kit 0 (kit k at + 2531 k: rui_emu KIT_SCENE - 0x97e)
KIT_MUTE = 2495                              # kit + 2495 (u32): the QPERF mute (0x4011f7f6 copies it to the gate)
PERF_AMT, EFF, TGT, STATE = 0x8000e57c, 0x8000f774, 0x8000e57c, 0x8000ee84
ROUTES, SRCS = 0x8000ebbc, 0x8000ec7c        # 48 x {u16 amount, u16 g}, 48 x u8 macro
QP_POS, ACTIVE_KIT = 0x42f9210c, 0x800067b8
LIVE, TRACK = 0x407DD8E3, 917                # the working pattern's live tracks


def check(name, ok, detail="", stock=False):
    """stock=True: a probe of a stock fact the P0 / P2 reports measured as failing on every build (the plan's guess was
    wrong): it prints STOCK, not FAIL, and is not in the verdict. If it ever passes, the fact changed: it says so."""
    tag = ("PASS (a declared stock fact failed before: recheck it)" if ok else "STOCK") if stock else "PASS" if ok else "FAIL"
    print(f"  {tag}  {name}" + (f"   [{detail}]" if detail != "" else ""), flush=True)
    if stock:
        if not ok:
            STOCK.append(name)
    elif not ok:
        FAILS.append(name)


def g_of(t, w):
    return 26 + 42 * t + w


def u(b, i=0, n=2):
    return int.from_bytes(b[i:i + n], "big")


def run(e, name, length, events=(), extra=(), env=None):
    """S.Emu.run with its own clean check kept out of the verdict (a --break run ends early)."""
    n0 = len(S.FAILS)
    r = e.run(name, length, events, extra=extra, env=env)
    del S.FAILS[n0:]
    return r


def watches(out):
    return [(int(a, 16), int(b, 16), int(v, 16)) for a, b, v in
            re.findall(r"watch: pc=([0-9a-f]+) \[([0-9a-f]+)\]\.\d <- ([0-9a-f]+)", out)]


def rom(e):
    """The build's MAIN OS image (the ROM tables are stock's)."""
    if not hasattr(e, "img"):
        sys.path.insert(0, os.path.join(S.ROOT, "tools"))
        import ostarget
        from pathlib import Path
        e.img = ostarget.extract_mainos(Path(ostarget.info()["stock_path"]))
    return e.img


def rec(e, i):
    img = rom(e)
    o = REC_ROM + 0x34 * i - 0x40000400
    r = img[o:o + 0x34]
    lab = u(r, 48, 4) - 0x40000400
    return int.from_bytes(r[4:8], "big", signed=True), img[lab:lab + 8].split(b"\0")[0].decode("latin1")


# ---------------------------------------------------------------- Task 1: the QPERF mute word
MUTE = [(40, "press", "FUNC", 60), (60, "press", "QPER")]


def t_mute(e):
    base = e.base[0]
    g0 = u(e.peek(base, GATE, 4), 0, 4)
    k0 = u(e.peek(base, KIT0 + KIT_MUTE, 4), 0, 4)
    r = run(e, "mute_gate", 400, MUTE + [(240, "press", "FUNC", 60), (260, "press", "QPER")],
            extra=["--watch", f"{GATE:x}"], env=dict(DTEMU_NO_JIT="1"))
    w = [x for x in watches(r["out"]) if x[1] == GATE]
    print(f"    base: gate {g0}, kit 0 + 2495 {k0}; writes of the gate {[(hex(p), v) for p, _, v in w]}")
    check("mute: the base is unmuted (gate 0, kit word 0)", g0 == 0 and k0 == 0, (g0, k0))
    check("mute: FUNC + QPER writes the gate 1, again 0 (one write each, 0x4011f816 in 0x4011f7f6: kit + 2495 -> gate)",
          [v for _, _, v in w] == [1, 0] and all(p == 0x4011f816 for p, _, _ in w), w)
    r = run(e, "mute_kitword", 200, MUTE, extra=["--watch", f"{KIT0 + KIT_MUTE:x}"], env=dict(DTEMU_NO_JIT="1"))
    w = [x for x in watches(r["out"]) if x[1] == KIT0 + KIT_MUTE]
    print(f"    writes of kit 0 + 2495: {[(hex(p), v) for p, _, v in w]}")
    check("mute: the press writes kit + 2495 = 1 first (0x400a6d7c, the toggle's move.l d2,a0@(2495))",
          [(p, v) for p, _, v in w] == [(0x400a6d7c, 1)], w)
    # the knob swept 0 -> 255 (macros 1 and 10 on it: mask 0x201), unmuted and muted
    rt = e.peek(base, ROUTES, 48 * 4)
    src = e.peek(base, SRCS, 48)
    dst = sorted({u(rt, 4 * j + 2) for j in range(48) if src[j] in (0, 9) and u(rt, 4 * j) and u(rt, 4 * j + 2) < 572})
    sweep = ["--qperf-sweep", f"0:255:5@{e.base[1] + 200}M/1000k"]
    res = {}
    for nm, ev, ex in (("none", [], []), ("un", [], sweep), ("mu", MUTE, sweep)):
        s = run(e, f"mute_sweep_{nm}", 400, ev, extra=ex)["snap"]
        res[nm] = dict(eff=[u(e.peek(s, EFF + 2 * g, 2)) for g in dst], tgt=[u(e.peek(s, TGT + 2 * g, 2)) for g in dst],
                       amt=u(e.peek(s, PERF_AMT, 2)), pos=u(e.peek(s, QP_POS, 4), 0, 4), gate=u(e.peek(s, GATE, 4), 0, 4))
    for nm in res:
        print(f"    {nm}: gate {res[nm]['gate']} pos {res[nm]['pos']} macro 1 amount {res[nm]['amt']:#06x}; "
              f"eff - target at the routes' {len(dst)} words {[a - b for a, b in zip(res[nm]['eff'], res[nm]['tgt'])]}")
    check("mute: QP_POS reaches 255 and macro 1's amount moves in both (the knob still writes the amounts)",
          all(res[n]["pos"] == 255 and res[n]["amt"] > 0x7000 for n in ("un", "mu")),
          [(res[n]["pos"], hex(res[n]["amt"])) for n in res])
    check("mute: unmuted, stage G moves the routes' words (eff != target somewhere)",
          res["un"]["eff"] != res["un"]["tgt"], dst)
    dm = [a - b for a, b in zip(res["mu"]["eff"], res["mu"]["tgt"])]
    dn = [a - b for a, b in zip(res["none"]["eff"], res["none"]["tgt"])]
    check("mute: muted, the knob's sweep moves no route word: eff - target as with no knob move at all (stage G "
          "skipped; what remains is the other stages', e.g. an LFO)", dm == dn, (dm, dn))
    # per kit: RELOAD (NO + PLAYMODE), SAVE (YES + PLAYMODE) then RELOAD, LOAD KIT K002 (the KIT menu)
    kitmenu = [(80, "press", "FUNC", 60), (84, "press", "PLAYMODE"), (160, "press", "UP"), (180, "press", "UP"),
               (200, "press", "UP"), (220, "press", "DOWN"), (240, "press", "YES"), (300, "press", "DOWN"),
               (320, "press", "YES"), (380, "press", "YES"), (440, "press", "YES")]
    cases = {"reload": (MUTE + [(160, "press", "NO", 60), (180, "press", "PLAYMODE")], 300, 0, 0),
             "save_reload": (MUTE + [(160, "press", "YES", 60), (180, "press", "PLAYMODE"), (280, "press", "NO", 60),
                                     (300, "press", "PLAYMODE")], 400, 1, 0),
             "load_k2": (MUTE + kitmenu, 700, 0, 1)}
    for nm, (ev, ln, want, kit) in cases.items():
        s = run(e, f"mute_{nm}", ln, ev)["snap"]
        g, k = u(e.peek(s, GATE, 4), 0, 4), u(e.peek(s, ACTIVE_KIT, 4), 0, 4) & 127
        kw = u(e.peek(s, KIT0 + 2531 * k + KIT_MUTE, 4), 0, 4)
        print(f"    {nm}: active kit {k}, gate {g}, the kit's + 2495 {kw}")
        check(f"mute {nm}: gate {want} (= the active kit's own + 2495) on kit {kit}", g == want and kw == g and k == kit,
              (g, kw, k))


# ---------------------------------------------------------------- Task 2: param_apply_delta
def pad_at(e, name, events, length, extra=()):
    """The first call's state at +0x1c (a --break there): (id, track, delta, func, this) or None."""
    r = run(e, name, length, events, extra=["--break", f"{PAD_1C:x}", *extra], env=dict(DTEMU_NO_JIT="1"))
    st = re.search(r"^stack: ((?:[0-9a-f]{8} ?)+)", r["out"], re.M)
    d = re.search(r"^d: ((?:[0-9a-f]{8} ?)+)", r["out"], re.M)
    if f"BREAK at 0x{PAD_1C:08x}" not in r["out"] or not st or not d:
        return None
    s = [int(x, 16) for x in st.group(1).split()]
    dd = [int(x, 16) for x in d.group(1).split()]
    delta = s[7] - (1 << 32) if s[7] & 0x80000000 else s[7]
    return dict(id=s[6], track=dd[0], delta=delta, func=s[8] & 0xff, view=s[5])


TURN = lambda at, enc: (at, "turn", f"{enc}:-8", 5, 10)   # noqa: E731  (5 detents' worth; the first calls the function)
WALK_PLAITS = [(20, "press", "SRC"), (120, "press", "SRC")] + [(220 + 100 * i, "press", "DOWN") for i in range(24)] + \
              [(2620, "press", "YES")]   # us_ui.json: PLAITS 24 downs in BD's list


def t_padword(e):
    pg = lambda k: [(20, "press", k)]   # noqa: E731
    fx = lambda k: [(20, "press", "FX"), (60, "press", k)]   # noqa: E731
    sd = lambda k: [(10, "press", "SD"), (30, "press", k)]   # noqa: E731
    cases = [  # name, events before the turn, encoder, want (track, word) or None = report only
        # BD PLASTIC (m 21): words 9..16 = records 206 205 208 207 210 212 211 209 (LEV TUN DEC TYP MOD SWT SWD TIC,
        # rytm-param-mod.md M0d); the knobs are in the page's order (A TUN, E TYP, H LEV), not the word order
        ("src_A", pg("SRC"), 0, (0, 10)), ("src_E", pg("SRC"), 4, (0, 12)), ("src_H", pg("SRC"), 7, (0, 9)),
        ("smpl_A", pg("SMPL"), 0, (0, 17)), ("smpl_D", pg("SMPL"), 3, (0, 19)), ("smpl_H", pg("SMPL"), 7, (0, 24)),
        ("fltr_A", pg("FLTR"), 0, (0, 26)), ("fltr_E", pg("FLTR"), 4, (0, 30)), ("fltr_G", pg("FLTR"), 6, (0, 32)),
        ("fltr_H", pg("FLTR"), 7, (0, 25)),
        ("amp_A", pg("AMP"), 0, (0, 33)), ("amp_E", pg("AMP"), 4, (0, 40)), ("amp_F", pg("AMP"), 5, (0, 41)),
        ("amp_G", pg("AMP"), 6, (0, 38)), ("amp_H", pg("AMP"), 7, (0, 37)),
        ("lfo_A", pg("LFO"), 0, (0, 5)), ("lfo_D", pg("LFO"), 3, (0, 4)), ("lfo_H", pg("LFO"), 7, (0, 8)),
        ("sd_fltr_E", sd("FLTR"), 4, (1, 30)),
        ("amp2_A", [(20, "press", "AMP"), (60, "press", "AMP")], 0, None),   # 0029's AMPLITUDE 2 (SFX1 send)
        ("fltr_E_func", [(20, "press", "FLTR"), (60, "press", "FUNC", 300)], 4, (0, 30)),
        ("trig_A", pg("TRIG"), 0, None), ("trig_B", pg("TRIG"), 1, None), ("trig_E", pg("TRIG"), 4, None),
        # FX alone: the FX track's first page (DELAY); FX then SRC: SRC's second press, 0029's SEND FX 1 (no Rytm word)
        ("fx_dly_A", [(20, "press", "FX")], 0, (12, 9)), ("fx_dly_H", [(20, "press", "FX")], 7, (12, 16)),
        ("fx_sfx1_A", fx("SRC"), 0, (12, -1)), ("fx_sfx1_H", fx("SRC"), 7, (12, -1)),
        ("fx_smpl_A", fx("SMPL"), 0, (12, 19)),
        ("fx_fltr_A", fx("FLTR"), 0, (12, 27)), ("fx_amp_A", fx("AMP"), 0, (12, 30)), ("fx_amp_H", fx("AMP"), 7, None),
        ("fx_lfo_A", fx("LFO"), 0, (12, 5)), ("fx_trig_A", fx("TRIG"), 0, None),
    ]
    want = os.environ.get("PADWORD")
    rows = []
    for nm, pre, enc, exp in cases:
        if want and nm not in want.split(","):
            continue
        at = max(x[0] for x in pre) + 60
        p = pad_at(e, f"pad_{nm}", pre + [(at, "turn", f"{enc}:-8", 10, 10)], at + 400)
        if p is None:
            check(f"padword {nm}: param_apply_delta reached (+0x1c)", False, "no break")
            continue
        w, lab = rec(e, p["id"])
        rows.append((nm, p["id"], lab, w, p["track"], p["delta"], p["func"]))
        print(f"    {nm:10s} id {p['id']:3d} {lab:5s} rec+04 {w:3d}  track {p['track']:2d}  delta {p['delta']} func {p['func']}")
        if exp:
            check(f"padword {nm}: track {exp[0]}, record +0x04 = word {exp[1]}", (p["track"], w) == exp,
                  (p["track"], w, lab))
        elif nm.startswith("amp2"):
            print(f"    {nm}: (report) 0029's AMPLITUDE 2 knob: id {p['id']} +0x04 {w}")
        elif nm.startswith("trig") or nm.startswith("fx_trig"):
            check(f"padword {nm}: a TRIG page id (28..38: +0x04 0..9 are NOT sound words)", 28 <= p["id"] <= 38,
                  (p["id"], w, lab))
    if not want or "plaits" in want:   # a Sidecar machine (PLAITS on BD, no Teensy: the choice waits) - SRC knob A
        at = 2900
        p = pad_at(e, "pad_plaits_src_A", WALK_PLAITS + [(2760, "press", "SRC"), TURN(at, 0)], at + 150)
        if p is None:
            check("padword plaits_src_A: param_apply_delta reached on a Sidecar machine's SRC page", False, "no break")
        else:
            w, lab = rec(e, p["id"])
            print(f"    plaits_src_A id {p['id']} {lab} rec+04 {w} track {p['track']}")
            check("padword plaits_src_A: a Sidecar machine (PLAITS on BD): knob A -> word 9 (= its P1), track 0",
                  (p["track"], w) == (0, 9), (p, lab))
    return rows


# the p-lock while T15 is held (GRID REC) and while live recording: written inside param_apply_delta?
REGIONS = ((0x407DD000, 0xB000), (KIT0, 2531), (0x405C8F38 + 13101, 13101))   # live pattern + its locks (BD's lock
# words at 0x407e0774: sq_emu fillpersist), kit 0, the stored A01


def mem(e, snap):
    return {a: e.peek(snap, a, n) for a, n in REGIONS}


def mdiff(a, b):
    out = []
    for k in a:
        out += [(hex(k + i), x, y) for i, (x, y) in enumerate(zip(a[k], b[k])) if x != y]
    return out


LOCK_SET = 0x400ac670   # (pattern, track, step, word, value, ..): the held trig's p-lock store


def t_padtrig(e):
    """Where stock writes what a FLTR FRQ turn changes, against a run with param_apply_delta made a bare rts:
    grid    GRID REC, no trig held: a kit edit (what stock sees when 0026 ate T15 / PAGE + T15)
    gridt15 GRID REC with T15 held as stock's own trig: a p-lock on step 15 (the plan's guess: inside the function)
    live    live REC while playing: the kit and a recorded lock"""
    rts = ["--poke", f"{PAD:x}=4e754e75"]   # param_apply_delta a bare rts (its caller pops the arguments)
    ctx = {
        "grid": ([(10, "press", "FLTR"), (60, "press", "RECORD")], 150, 400),
        "gridt15": ([(10, "press", "FLTR"), (60, "press", "RECORD"), (100, "press", "T15", 200)], 150, 400),
        "live": ([(10, "press", "FLTR"), (60, "press", "RECORD", 40), (70, "press", "PLAY")], 200, 450),
    }
    for nm, (pre, at, ln) in ctx.items():
        n = mem(e, run(e, f"pt_{nm}_none", ln, pre)["snap"])
        a = mem(e, run(e, f"pt_{nm}_turn", ln, pre + [TURN(at, 4)])["snap"])
        b = mem(e, run(e, f"pt_{nm}_rts", ln, pre + [TURN(at, 4)], extra=rts)["snap"])
        p = pad_at(e, f"pt_{nm}_brk", pre + [TURN(at, 4)], ln)
        da, db = mdiff(n, a), mdiff(n, b)
        kitw = [x for x in da if KIT0 <= int(x[0], 16) < KIT0 + 2531]
        print(f"    {nm}: the turn changes {len(da)} bytes ({len(kitw)} in the kit) {da[:6]}; "
              f"param_apply_delta an rts: {len(db)} {db[:4]}")
        print(f"    {nm}: at +0x1c: {p}")
        check(f"padtrig {nm}: (control) the turn writes something", len(da) > 0, len(da))
        if nm == "gridt15":
            w = watches(run(e, f"pt_{nm}_watch", ln, pre + [TURN(at, 4)], extra=["--watch", "407e0c80"])["out"])
            print(f"    {nm}: writers of the lock word 0x407e0c80 (BD step 15, FRQ): {[(hex(x[0]), hex(x[2])) for x in w]}")
            check(f"padtrig {nm}: (control) a p-lock, not a kit edit (the kit bytes unchanged)", not kitw, kitw)
        else:
            check(f"padtrig {nm}: (control) the kit word written (BD FRQ, kit + 0x7a)",
                  any(x[0] == hex(KIT0 + 0x7a) for x in kitw), kitw)
        st = nm == "gridt15"   # a stock fact (P0 report)
        check(f"padtrig {nm}: nothing is written when param_apply_delta returns at once (the write is inside it, "
              "so a detour at +0x1c, after only the track lookup, pre-empts it)", not db, db[:6], stock=st)
        check(f"padtrig {nm}: the turn reaches +0x1c (FRQ id 47, track 0)", p is not None and p["id"] == 47 and
              p["track"] == 0, p, stock=st)


def t_padbase(e):
    """target / state / effective of BD FRQ (g 56): stopped (the kit value), playing with a p-lock on step 1 (and a
    plain trig on step 5), after STOP; and an op 05 override (host command) on it."""
    g = g_of(0, 30)
    pk = ",".join(f"{a + 2 * g if a != STATE else a + 4 * g:x}" for a in (TGT, EFF)) + f",{STATE + 4 * g:x}"
    plock = [(10, "press", "FLTR"), (60, "press", "RECORD"), (110, "press", "T1", 300), (160, "turn", "4:-8", 5, 10),
             (500, "press", "T5"), (540, "press", "RECORD")]
    r = run(e, "pb_plock", 1200, plock + [(600, "press", "PLAY"), (1000, "press", "STOP")],
            extra=["--every", "10M"], env=dict(DTBOOT_PEEK=pk))
    ser = []
    clk = None
    for line in r["out"].splitlines():
        m = re.match(r"^\s*(\d+)M pc=", line)
        if m:
            clk = int(m.group(1)) - e.base[1]
        x = re.findall(r"\[([0-9a-f]{8})\]=([0-9a-f]{8})", line)
        if x and line.lstrip().startswith("peek") and clk is not None:
            d = {int(a, 16): int(v, 16) for a, v in x}
            ser.append((clk, d[(TGT + 2 * g) & ~3] >> (16 if g % 2 == 0 else 0) & 0xffff,
                        d[(EFF + 2 * g) & ~3] >> (16 if g % 2 == 0 else 0) & 0xffff, d[STATE + 4 * g] >> 16))
    print("    M      target  eff     state>>16")
    last = None
    for c, t, ef, s in ser:
        if (t, ef, s) != last:
            print(f"    {c:5d}  {t:#06x}  {ef:#06x}  {s:#06x}")
            last = (t, ef, s)
    kitv = [t for c, t, _, _ in ser if c < 600]
    lockv = [t for c, t, _, _ in ser if 600 < c < 1000]
    after = [t for c, t, _, _ in ser if c > 1050]
    check("padbase: stopped, before the lock: target = the kit value (the page's FRQ, 127 = 0x7f00)",
          kitv and set(kitv) == {0x7f00}, set(kitv))
    check("padbase: (report) playing: target takes the p-lock at step 1 and the kit value at step 5",
          len(set(lockv)) >= 2, sorted(set(lockv)))
    check("padbase: after STOP: target = the kit value again", after and after[-1] == 0x7f00,
          [hex(x) for x in after[-3:]], stock=True)   # a stock fact (P2 report)


# ---------------------------------------------------------------- Task 3: keys, LEDs, the header on stock pages
CTX = (("main", []), ("grid", [(10, "press", "RECORD")]),
       ("gridtrig", [(10, "press", "RECORD"), (20, "press", "T1:100")]),
       ("src", [(10, "press", "SRC")]), ("fltr", [(10, "press", "FLTR")]), ("trig", [(10, "press", "TRIG")]),
       ("chro", [(10, "press", "CHRO")]), ("scne", [(10, "press", "SCNE")]), ("perf", [(10, "press", "PERF")]),
       ("mute", [(10, "press", "MUTE")]), ("bank", [(10, "press", "BANK_A:150")]), ("menu", [(10, "press", "GLOBAL")]),
       ("fx", [(10, "press", "FX")]))


def t_pagekeys(e):
    """Stock 1.74 (rled's stock base): PAGE held + Tk against Tk alone, PAGE alone and nothing, the rled stockup rule:
    FREE (Tk alone + what PAGE alone leaves), SEQ (PAGE tapped, then Tk) or CLASH (a combo of stock's own)."""
    le = L.Emu(e.tag)
    kw = L.stock_kw(le)
    keys = os.environ.get("PAGEKEYS", ",".join(f"T{k}" for k in range(1, 17))).split(",")
    want = os.environ.get("PAGECTX")
    table = {}
    for ctx, pre in CTX:
        if want and ctx not in want.split(","):
            continue
        n = L.stock_state(le, le.run(f"pk-{ctx}-none", 300, pre, **kw))
        p = L.stock_state(le, le.run(f"pk-{ctx}-page", 300, pre + [(30, "press", "PAGE:60")], **kw))
        pmoves = [x for x in p if p[x] != n[x]]
        print(f"  {ctx}: PAGE alone changes {pmoves[:8]}")
        table[(ctx, "PAGE")] = "moves" if pmoves else "-"
        for k in keys:
            a = L.stock_state(le, le.run(f"pk-{ctx}-{k}", 300, pre + [(50, "press", k)], **kw))
            b = L.stock_state(le, le.run(f"pk-{ctx}-p{k}", 300, pre + [(30, "press", "PAGE:60"), (50, "press", k)], **kw))
            bad = L.combo_only_parts(b, a, p, n)
            how = "FREE"
            if bad:
                sq = L.stock_state(le, le.run(f"pk-{ctx}-ptap{k}", 300, pre + [(30, "press", "PAGE:10"), (50, "press", k)],
                                              **kw))
                bad = [x for x in b if b[x] != sq[x]]
                how = "CLASH" if bad else "SEQ"
            table[(ctx, k)] = how
            check(f"pagekeys {ctx}: PAGE held + {k}: {how}", not bad, bad[:6])
    ctxs = [c for c, _ in CTX if not want or c in want.split(",")]
    print("  key   " + " ".join(f"{c:8s}" for c in ctxs))
    for k in ["PAGE"] + keys:
        print(f"  {k:5s} " + " ".join(f"{table.get((c, k), '-'):8s}" for c in ctxs))
    L.FAILS.clear()


def t_pagelen(e):
    """Stock 1.74 on a 34-step pattern (FUNC + PAGE: the SCALE menu, UP x 18, NO): what PAGE does alone (tapped, and
    held to the end of the run: does it act at the press or the release?), PAGE held + T15, and T15 alone. On a long
    pattern PAGE steps the shown pattern page: if it acts at the press, PAGE + T15 always steps the page too."""
    le = L.Emu(e.tag)
    kw = L.stock_kw(le)
    pre = [(10, "press", "FUNC:40"), (20, "press", "PAGE")] + [(60 + 15 * i, "press", "UP") for i in range(18)] + \
          [(400, "press", "NO")]
    n = le.run("pl-none", 700, pre, **kw)
    sn = L.stock_state(le, n)
    ln = le.peek(n, LIVE + 0x2c5, 1)[0]
    print(f"    after the SCALE menu: BD length byte {ln}")
    st = {}
    for nm, ev in (("page", [(500, "press", "PAGE:30")]), ("pagehold", [(500, "press", "PAGE:400")]),
                   ("t15", [(520, "press", "T15")]), ("pt15", [(500, "press", "PAGE:60"), (520, "press", "T15")]),
                   ("pholdt15", [(500, "press", "PAGE:400"), (520, "press", "T15")])):
        st[nm] = L.stock_state(le, le.run(f"pl-{nm}", 700, pre + ev, **kw))
        mv = [x for x in st[nm] if st[nm][x] != sn[x]]
        print(f"    {nm}: changes {mv[:10]}")
    bad = L.combo_only_parts(st["pt15"], st["t15"], st["page"], sn)
    print(f"    PAGE + T15 on the long pattern: {'FREE' if not bad else bad[:6]}")
    check("pagelen: (report) the pattern is longer than 16 steps", ln > 16, ln)
    pmv = [x for x in st["page"] if st["page"][x] != sn[x]]
    hmv = [x for x in st["pagehold"] if st["pagehold"][x] != sn[x]]
    print(f"    PAGE acts at the {'press' if hmv else 'release' if pmv else '(no change seen)'}")
    L.FAILS.clear()


def t_pagecatch(e):
    """The TAG build on its base (no host): 0026's key handler (rui_key, core-ar2 ev_key) sees PAGE's press and T15's
    in every context, so 0026 can catch PAGE held + T15 / T16 wherever stock runs. Each key event rui_key gets is read
    from its st.last_key (st + 72: code | down << 8) by a --watch."""
    lk = e.syms["rytm-0026-remote-ui:st"] + 72
    names = {0x84: "PAGE", 14: "T15", 0: "T1", 0x50: "REC"}
    want = os.environ.get("PAGECTX")
    for ctx, pre in CTX:
        if want and ctx not in want.split(","):
            continue
        pre = [(x[0], x[1], *x[2].split(":")) if isinstance(x[2], str) and ":" in x[2] else x for x in pre]
        pre = [(x[0], x[1], x[2], int(x[3])) if len(x) > 3 else x for x in pre]
        r = run(e, f"pc_{ctx}_pt15", 300, pre + [(30, "press", "PAGE", 60), (50, "press", "T15")],
                extra=["--watch", f"{lk:x}"])
        ev = [(v & 0xff, v >> 8 & 1) for _, a, v in watches(r["out"]) if a == lk]
        seen = [f"{names.get(c, hex(c))}{'+' if d else '-'}" for c, d in ev]
        print(f"    {ctx}: rui_key got {seen}")
        check(f"pagecatch {ctx}: rui_key sees PAGE down, T15 down and up (PAGE first)",
              (0x84, 1) in ev and (14, 1) in ev and (14, 0) in ev and ev.index((0x84, 1)) < ev.index((14, 1)), seen)


def t_leds(e):
    """Seq mode (2E BD + GRID REC): 0026 owns the trig LEDs on a stock page. 34 1: T1..T14 cyan, T15 blue (47),
    T16 yellow; FLTR, PLAY: at 20 sample points over 2 s every slot of LEDs 14 / 15 holds the host's colour."""
    BLUE, YEL, CY = 47, 60, 0x2B
    cols = [CY] * 14 + [BLUE, YEL]
    pre = [(300, "usb", S.mask2e((0,))), (330, "press", "RECORD"), (360, "usb", S.sx(0x34, 1, *cols)),
           (370, "press", "FLTR"), (430, "press", "PLAY")]
    alive = [(t, "usb", S.sx(0x3C)) for t in range(320, 1000, 20)]
    bad = []
    for end in range(450, 850, 20):
        r = run(e, f"leds_{end}", end, pre + [x for x in alive if x[0] < end])
        lv = e.leds(r["snap"])
        if lv.get(14) != [BLUE] * 4 or lv.get(15) != [YEL] * 4:
            bad.append((end, lv.get(14), lv.get(15)))
    sq = e.sq(r["snap"])
    print(f"    the last sample: seq mode {sq['mode']}, grid {sq['grid']}, playing {sq['last_play']}")
    check("leds: (control) seq mode on, GRID REC, playing (stock's playhead runs over the trig LEDs)",
          sq["mode"] == 1 and sq["grid"] == 1 and sq["last_play"] == 1, sq)
    c = run(e, "leds_ctl", 600, [x for x in pre if x[1] != "usb" or x[2][4] != 0x34] + [x for x in alive if x[0] < 600])
    lc = e.leds(c["snap"])
    print(f"    control (no 34): LED 14 {lc.get(14)}, LED 15 {lc.get(15)}; samples off: {bad[:4]}")
    check("leds: 20 samples over 2 s (playing, FLTR, seq mode): LEDs 14 / 15 blue / yellow in every slot", not bad, bad[:3])


def t_hdr(e):
    """rui_draw (core-ar2 ev_draw: after each frame stock drew, the canvas then sent) runs once a frame on stock pages:
    its count follows the panel frames on FLTR, SRC, TRIG and in GRID REC, playing."""
    a = e.syms["rytm-0026-remote-ui:rui_draw"]
    for ctx, pre in (("fltr", [(10, "press", "FLTR")]), ("src", [(10, "press", "SRC")]), ("trig", [(10, "press", "TRIG")]),
                     ("gridplay", [(10, "press", "RECORD"), (20, "press", "PLAY")])):
        r = run(e, f"hdr_{ctx}", 400, pre, extra=["--count", f"{a:x}", "--every", "100M"])
        st = [(int(c), int(f), int(n)) for c, f, n in re.findall(rf"^\s*(\d+)M pc=\S+ .*?frames=(\d+).*?{a:08x}:(\d+)",
                                                                  r["out"], re.M)]
        print(f"    {ctx}: (clock M, panel frames, rui_draw calls) {st}")
        if len(st) >= 2:
            df, dc = st[-1][1] - st[0][1], st[-1][2] - st[0][2]
            check(f"hdr {ctx}: rui_draw called at least once a panel frame on the stock page", dc >= df > 0, (df, dc))
        else:
            check(f"hdr {ctx}: status lines", False, st)


# ---------------------------------------------------------------- P2 Task 8: the mute flag in the 0E report
def qp0e(r):
    """2D 01 0E <pos hi lo> <mask lo hi> <flags>: [(pos, mask, flags)]."""
    return [(m[7] << 7 | m[8], m[9] | m[10] << 7, m[11]) for m in r["msgs"] if len(m) == 13 and m[4:7] == b"\x2d\x01\x0e"]


def t_qpmute(e):
    """0E flags bit 2 = the QUICK PERF macros muted (the gate 0x8000ed74, the active kit's + 2495): FUNC + QPER sets it,
    again clears it; muted, a knob move still reports (bit 2 kept); RELOAD (no FUNC, no knob) clears it by itself; the
    hello's caps2 has bit 1 (2: the build sends the flag)."""
    s0 = e.base[1]
    ev = MUTE + [(240, "press", "FUNC", 60), (260, "press", "QPER")]
    r = run(e, "qpmute_toggle", 400, ev)
    q = qp0e(r)
    print(f"    toggle: {q}")
    on = [i for i, x in enumerate(q) if x[2] & 4]
    check("qpmute: FUNC + QPER: a report with bit 2 (muted)", bool(on), q)
    check("qpmute: again: the last report has bit 2 clear (unmuted)", bool(q) and not q[-1][2] & 4, q[-1:])
    r = run(e, "qpmute_knob", 400, MUTE, extra=["--qperf", f"100@{s0 + 250}M"])
    q = qp0e(r)
    print(f"    muted + knob 100: {q}")
    check("qpmute: muted, the knob still reports: pos 100 with bits 1 (moved) and 2 (muted)",
          any(x[0] == 100 and x[2] & 6 == 6 for x in q), q)
    r = run(e, "qpmute_reload", 400, MUTE + [(200, "press", "NO", 60), (220, "press", "PLAYMODE")])
    q = qp0e(r)
    g = u(e.peek(r["snap"], GATE, 4), 0, 4)
    print(f"    muted, then RELOAD: {q}; gate {g}")
    check("qpmute: RELOAD unmutes (gate 0) and a report follows with bit 2 clear, no FUNC / knob in it",
          g == 0 and len(q) >= 2 and q[-1][2] & 4 == 0 and any(x[2] & 4 for x in q) and q[-1][2] & 1 == 0, q)
    r = run(e, "qpmute_hello", 900, [], extra=["--usb-host-gone", f"{s0 + 200}M:{s0 + 300}M"])
    hs = [m for m in r["msgs"] if len(m) == 11 and m[4] == 0x35]
    print(f"    hellos: {[m.hex() for m in hs]}")
    check("qpmute: the hello carries caps2 bit 1 (2) next to bit 0 (the arrows)", bool(hs) and all(m[9] & 3 == 3 for m in hs),
          [m.hex() for m in hs])


# ---------------------------------------------------------------- P2 Task 9: the scene edit on stock pages ("ms")
ARM = S.sx(0x5A, 0x0B, 1)
# The hello goes out ~100M (0.5 s, HELLO_TICKS) into every run and clears the arm, as on a Rytm: the host arms after
# it (and its answer stops the hello's repeats). So the tests arm at ARM_AT and act from 150 on.
ARM_AT = 140
RD_ROWS = 10    # the glass rows the readout's band covers at least (font 16, drawn 2 rows from the top)
FRQ_KIT = KIT0 + 0x7a                        # BD FLTR FRQ in kit 0 (a byte, 0..127) [P0 padtrig]
MS_OFF = dict(on=0, page_held=4, pdef=8, side=16, hside=20, rd_until=188, led_on=212, defers=216, fwd_alone=220,
              fwd_late=224, fwd_key=228, gestures=232, picks=236, caps=240, sent=244, nolock=248, cut=252, m2=256,
              gates=260, base_raw=264, clrs=268, pushd=272)


def msf(e, snap):
    """0026's ms struct after the run ({} on a build without it)."""
    a = e.syms.get("rytm-0026-remote-ui:ms")
    if a is None:
        return {}
    b = e.peek(snap, a, 276)
    return {k: u(b, o, 4) for k, o in MS_OFF.items()}


def caps(r):
    """2D 01 12: [(side, t, w, delta, func, base)]"""
    return [(m[7], m[8], m[9], m[10] - 128 if m[10] & 0x40 else m[10], m[11], m[12] << 7 | m[13])
            for m in r["msgs"] if len(m) == 15 and m[4:7] == b"\x2d\x01\x12"]


def edk(r):
    """2D 01 13: [(ev, side, n)]"""
    return [(m[7], m[8], m[9]) for m in r["msgs"] if len(m) == 11 and m[4:7] == b"\x2d\x01\x13"]


def gesture(side_key="T15", at=200, turn_at=250, enc=4, hold=250):
    ev = [(at, "press", "PAGE", hold), (at + 10, "press", side_key, hold - 50)]
    return ev + ([TURN(turn_at, enc)] if enc is not None else [])


def t_edcap(e):
    """Armed (5A 01 0B 1), stock FLTR, PAGE + T15 held, FRQ turned down: 2D 01 13 held / let go (side 0) around 2D 01 12
    side 0, BD (t 0), FRQ (w 30), the detents down (< 0), base = the kit's FRQ x 128; the kit's FRQ unchanged (a control
    run without the arm moves it). The same with T16: side 1."""
    k0 = e.peek(e.base[0], FRQ_KIT, 1)[0]
    for side, key in ((0, "T15"), (1, "T16")):
        r = run(e, f"ed_cap_{key}", 500, [(10, "press", "FLTR"), (ARM_AT, "usb", ARM)] + gesture(key))
        c, k, f = caps(r), edk(r), msf(e, r["snap"])
        kw = e.peek(r["snap"], FRQ_KIT, 1)[0]
        print(f"    {key}: 13 {k}; 12 {c}; kit FRQ {k0} -> {kw}; ms {f}")
        check(f"edcap {key}: 2D 01 13 side {side} held, then let go", k[:1] == [(1, side, 0x7f)] and k[-1:] == [(0, side, 0x7f)], k)
        check(f"edcap {key}: 2D 01 12 side {side}, t 0, w 30 (FRQ), turned down, base = kit FRQ x 128 ({k0 * 128})",
              bool(c) and all(x[:3] == (side, 0, 30) and x[5] == k0 * 128 for x in c) and sum(x[3] for x in c) < 0, c)
        check(f"edcap {key}: the kit's FRQ unchanged (no kit write)", kw == k0, (k0, kw))
    # review: FUNC held through the turn. Stock's FUNC + turn on FRQ never reaches param_apply_delta and writes
    # nothing (measured, mv3: no kit write, unarmed too), so under a side it is nothing either: no 2D 01 12, kit kept
    r = run(e, "ed_cap_func", 500, [(10, "press", "FLTR"), (ARM_AT, "usb", ARM), (230, "press", "FUNC", 120)] + gesture())
    c = caps(r)
    print(f"    FUNC: 12 {c}")
    check("edcap FUNC: FUNC + turn under the side: as stock (nothing), no 2D 01 12, the kit's FRQ unchanged",
          not c and e.peek(r["snap"], FRQ_KIT, 1)[0] == k0, (c, e.peek(r["snap"], FRQ_KIT, 1)[0]))
    n = run(e, "ed_cap_unarmed", 500, [(10, "press", "FLTR")] + gesture())
    check("edcap: (control) unarmed, the same keys and turn move the kit's FRQ, no 2D 01 12 / 13",
          e.peek(n["snap"], FRQ_KIT, 1)[0] != k0 and not caps(n) and not edk(n), (e.peek(n["snap"], FRQ_KIT, 1)[0], caps(n)))


def t_edfx(e):
    """FX (DELAY) knob A under PAGE + T15: t 12, w 9 (DELAY TIME); TRIG page knob A: no 2D 01 12, NOT LOCKABLE, the kit
    unchanged (the TRIG ids' words collide with sound words: refused by id)."""
    r = run(e, "ed_fx", 500, [(10, "press", "FX"), (ARM_AT, "usb", ARM)] + gesture(enc=0))
    c = caps(r)
    print(f"    fx: 12 {c}")
    check("edfx: the FX track's DELAY knob A: t 12, w 9", bool(c) and all(x[1:3] == (12, 9) for x in c), c)
    kit = e.peek(e.base[0], KIT0, 2531)
    r = run(e, "ed_trig", 500, [(10, "press", "TRIG"), (ARM_AT, "usb", ARM)] + gesture(enc=0))
    f = msf(e, r["snap"])
    print(f"    trig: 12 {caps(r)}; ms {f}")
    check("edtrig: the TRIG page under the side: no 2D 01 12, refused (NOT LOCKABLE), the kit unchanged",
          not caps(r) and f.get("nolock", 0) > 0 and e.peek(r["snap"], KIT0, 2531) == kit, (caps(r), f.get("nolock")))


def t_edgrid(e):
    """GRID REC (no trig held) and live REC while playing: PAGE + T15 + a FRQ turn leaves the pattern (its locks, step 15)
    and the kit as PAGE + T15 without the turn does; reported (2D 01 12)."""
    for nm, pre, ln in (("grid", [(10, "press", "FLTR"), (ARM_AT, "usb", ARM), (60, "press", "RECORD")], 500),
                        ("live", [(10, "press", "FLTR"), (ARM_AT, "usb", ARM), (60, "press", "RECORD", 20), (70, "press", "PLAY")], 500)):
        a = run(e, f"ed_{nm}_turn", ln, pre + gesture())
        n = run(e, f"ed_{nm}_none", ln, pre + gesture(enc=None))
        d = mdiff(mem(e, n["snap"]), mem(e, a["snap"]))
        print(f"    {nm}: the turn changes {len(d)} bytes {d[:6]}; 12 {caps(a)}")
        check(f"edgrid {nm}: the turn under the side writes nothing (pattern, locks, step 15, kit) and is reported",
              not d and bool(caps(a)), (d[:6], caps(a)))
        if nm == "grid":
            o = run(e, "ed_grid_none_unarmed", ln, [x for x in pre if x[1] != "usb"] + gesture(enc=None))
            d2 = mdiff(mem(e, o["snap"]), mem(e, n["snap"]))
            print(f"    grid unarmed PAGE + T15 vs armed: {len(d2)} bytes {d2[:4]}")
            check("edgrid: (control) unarmed, PAGE + T15 in GRID REC places step 15 (armed: not)", bool(d2), len(d2))


def t_edpick(e):
    """Under the side, T3 picks scene 3 for it (2D 01 13 2 0 2) and never reaches stock (GRID REC: no step 3)."""
    pre = [(10, "press", "RECORD"), (ARM_AT, "usb", ARM)]
    r = run(e, "ed_pick", 500, pre + gesture(enc=None) + [(260, "press", "T3", 30)])
    n = run(e, "ed_pick_none", 500, pre + gesture(enc=None))
    d = mdiff(mem(e, n["snap"]), mem(e, r["snap"]))
    print(f"    13 {edk(r)}; T3 changes {len(d)} bytes")
    check("edpick: T3 under the side: 2D 01 13 2 0 2, between held and let go", edk(r) == [(1, 0, 0x7f), (2, 0, 2), (0, 0, 0x7f)], edk(r))
    check("edpick: T3 never reaches stock (no step 3 in GRID REC)", not d, d[:4])


def t_edpage(e):
    """Armed, PAGE alone keeps stock's behaviour: tapped, stock gets press and release at its release (the screen, LEDs,
    pattern state as unarmed); held past 300 ms stock gets it then (its popup up, as unarmed); PAGE + another key: PAGE
    first. PAGE + T15 after the popup came: the popup let go (ms cut), the gesture on."""
    le = L.Emu(e.tag)
    arm = [(ARM_AT, "sx", ARM.hex())]
    for nm, ev, ln in (("tap", [(150, "press", "PAGE:10")], 420), ("held", [(150, "press", "PAGE:300")], 370),
                       ("chro", [(130, "press", "CHRO"), (150, "press", "PAGE:10")], 420),
                       ("pagekey", [(150, "press", "PAGE:200"), (160, "press", "CHRO")], 420)):
        a = L.stock_state(le, le.run(f"edp-{nm}-arm", ln, arm + ev))
        u_ = L.stock_state(le, le.run(f"edp-{nm}-un", ln, ev))
        # held at the snapshot: T15 / T16 show blue / yellow (edleds), the rest as unarmed
        bad = [k for k in a if a[k] != u_.get(k) and not (nm == "held" and k in ("led14", "led15"))]
        print(f"    PAGE {nm}: armed vs unarmed differ in {bad[:6]}")
        check(f"edpage {nm}: armed PAGE alone leaves what it leaves unarmed", not bad, bad[:6])
        if nm == "pagekey":   # review: CHRO while PAGE is kept back: stock gets PAGE first (fwd_key)
            f = msf(e, le.run("edp-pagekey-ms", ln, arm + ev)["snap"])
            check("edpage pagekey: PAGE held, CHRO: PAGE given first (fwd_key 1, not late)",
                  f.get("fwd_key") == 1 and f.get("fwd_late") == 0, f)
    r = le.run("edp-late", 420, arm + [(150, "press", "PAGE:200"), (250, "press", "T15:60")])
    f = msf(e, r["snap"])
    k = edk(r)
    print(f"    PAGE held 500 ms, then T15: ms {f}; 13 {k}")
    check("edpage late: PAGE given after 300 ms (fwd_late 1), T15 then cuts its popup (cut 1) and starts the gesture",
          f.get("fwd_late") == 1 and f.get("cut") == 1 and k[:1] == [(1, 0, 0x7f)], (f, k))


def t_edleds(e):
    """Armed, PAGE held on a stock page: T15 blue (47) / T16 yellow (60) in every slot; released: stock's again."""
    le = L.Emu(e.tag)
    arm = [(ARM_AT, "sx", ARM.hex())]
    held = le.run("edl-held", 320, arm + [(150, "press", "PAGE:400")])
    sl = le.panel(held)[0]
    print(f"    PAGE held: LED 14 {sl.get(14)}, LED 15 {sl.get(15)}")
    check("edleds: PAGE held: LED 14 all 47, LED 15 all 60", sl.get(14) == [47] * 4 and sl.get(15) == [60] * 4, (sl.get(14), sl.get(15)))
    rel = le.panel(le.run("edl-rel", 420, arm + [(150, "press", "PAGE:60")]))[0]
    non = le.panel(le.run("edl-none", 420, [(150, "press", "PAGE:60")]))[0]
    print(f"    released: LED 14 {rel.get(14)} / 15 {rel.get(15)}; unarmed {non.get(14)} / {non.get(15)}")
    check("edleds: released: LEDs 14 / 15 as unarmed (stock's)", rel.get(14) == non.get(14) and rel.get(15) == non.get(15),
          (rel.get(14), non.get(14)))


def t_edread(e):
    """5A 01 08 <n> <text> on a stock page: drawn over the header (the screen differs from a run without it while it
    lasts, rd_until set), gone after ~1 s (the screen as without it)."""
    le = L.Emu(e.tag)
    txt = S.sx(0x5A, 0x08, 12, *b"A FRQ 87 >64").hex()
    a = le.run("edr-on", 150, [(10, "press", "FLTR"), (100, "sx", txt)])
    n = le.run("edr-none", 150, [(10, "press", "FLTR")])
    f = msf(e, a["snap"])
    print(f"    0.25 s after: screen differs {a['oled'] != n['oled']}; rd_until {f.get('rd_until')}")
    check("edread: the readout drawn on the stock page (the screen differs, rd_until set)", a["oled"] != n["oled"] and
          f.get("rd_until", 0) > 0, f)
    a = le.run("edr-gone", 450, [(10, "press", "FLTR"), (100, "sx", txt)])
    n = le.run("edr-none2", 450, [(10, "press", "FLTR")])
    check("edread: 1.75 s after: gone (the screen as without it)", a["oled"] == n["oled"] and msf(e, a["snap"]).get("rd_until") == 0,
          msf(e, a["snap"]).get("rd_until"))


def t_edhello(e):
    """A hello (the host gone and back) clears the arm: PAGE + T15 then is stock's (no 2D 01 13)."""
    s0 = e.base[1]
    r = run(e, "ed_hello", 700, [(ARM_AT, "usb", ARM)] + gesture(at=500, turn_at=None, enc=None),
            extra=["--usb-host-gone", f"{s0 + 200}M:{s0 + 300}M"])
    f = msf(e, r["snap"])
    print(f"    13 {edk(r)}; ms on {f.get('on')}")
    check("edhello: after the new hello the mode is off (ms.on 0) and PAGE + T15 is no gesture", f.get("on") == 0 and not edk(r)
          and "rytm-0026-remote-ui:ms" in e.syms, (f.get("on"), edk(r)))


def t_edhold(e):
    """Flash review L1: PAGE + T15 held across a port drop and the hello after it: the side ends with the arm, so a trig
    pressed after it (T3, GRID REC) reaches stock (step 3 placed, as without the gesture); ms.side 0. The port drop's
    clear runs first, so this covers that one; the hello's (flush) is the same four lines, not reached separately."""
    s0 = e.base[1]
    gone = ["--usb-host-gone", f"{s0 + 300}M:{s0 + 400}M"]
    pre = [(10, "press", "RECORD"), (ARM_AT, "usb", ARM)] + gesture(at=200, enc=None, hold=700)
    r = run(e, "ed_hold_t3", 800, pre + [(650, "press", "T3", 30)], extra=gone)
    n = run(e, "ed_hold_none", 800, pre, extra=gone)
    d = mdiff(mem(e, n["snap"]), mem(e, r["snap"]))
    f = msf(e, r["snap"])
    print(f"    T3 after the drop: changes {len(d)} bytes {d[:4]}; ms {f}")
    check("edhold: after the port drop / hello the side is over (ms.side 0) and T3 reaches stock (step 3 placed)",
          f.get("side") == 0 and bool(d), (f.get("side"), d[:4]))


def t_edrehello(e):
    """A re-hello (3C 1: the host asks again, the link stays up) does not end a scene-edit gesture (review L1; a port-up
    hello does, and so does a drop; every hello clears the arm ms.on, the host arms again). PAGE + T15 held across it:
    ms.side stays 1, ms.on 0 (no re-arm), the let-go (2D 01 13 0) comes at the release; a host that re-arms after the
    hello (5A 01 0B 1) and a second gesture (T16) report as before. A re-hello with no re-arm: PAGE + T15 is stock's. PAGE alone, kept back (300 ms), a re-hello inside it and the release
    within it: stock gets the press and the release (the calls of its key handler as without the re-hello)."""
    s0 = e.base[1]
    rh = S.sx(0x3C, 1)
    hellos = lambda r: [i for i, m in enumerate(r["msgs"]) if len(m) == 11 and m[4:5] == b"\x35"]   # noqa: E731
    ev = [(10, "press", "FLTR"), (ARM_AT, "usb", ARM)] + gesture(at=200, turn_at=250, enc=4, hold=700)
    r = run(e, "ed_rehello_held", 600, ev + [(350, "usb", rh), TURN(450, 4)])
    f, h = msf(e, r["snap"]), hellos(r)
    c = [m for i, m in enumerate(r["msgs"]) if h and i > h[-1] and len(m) == 15 and m[4:7] == b"\x2d\x01\x12"]   # after the re-hello
    print(f"    hellos at {h}; 12 after the last hello {len(c)}; 13 {edk(r)}; ms {f}")
    check("edrehello: the re-hello was sent (a second hello after the port-up's)", len(h) >= 2, h)
    check("edrehello: PAGE + T15 held across it: the side stays (ms.side 1); the arm is cleared (ms.on 0: the host arms again)",
          f.get("side") == 1 and f.get("on") == 0, (f.get("side"), f.get("on")))
    check("edrehello: no re-arm, so the turn after the re-hello is not reported (no 2D 01 12 after the last hello)", not c, len(c))
    ev2 = [(10, "press", "FLTR"), (ARM_AT, "usb", ARM)] + gesture(at=200, turn_at=250, enc=4, hold=600) + \
          [(350, "usb", rh), (360, "usb", ARM), TURN(450, 4)] + gesture("T16", at=900, turn_at=950, hold=200)
    r = run(e, "ed_rehello_rearm", 1250, ev2)
    k, c, h = edk(r), caps(r), hellos(r)
    print(f"    hellos at {h}; 12 {c}; 13 {k}")
    check("edrehello: held, let go once (side 0) at the release, re-armed after the hello, a second gesture (T16) reports",
          k == [(1, 0, 0x7f), (0, 0, 0x7f), (1, 1, 0x7f), (0, 1, 0x7f)] and sorted({x[0] for x in c}) == [0, 1], (k, c))
    lg = [i for i, m in enumerate(r["msgs"]) if len(m) == 11 and m[4:7] == b"\x2d\x01\x13" and m[7:9] == b"\x00\x00"]
    check("edrehello: the first gesture's let-go comes after the re-hello's hello", bool(h and lg) and lg[0] > h[-1], (h, lg))
    # the arm: a re-hello clears it; a host that does not arm again leaves PAGE + T15 stock's (no gesture, no swallowed keys)
    g = {}
    for nm, ra in (("noarm", []), ("rearm", [(260, "usb", ARM)])):
        r = run(e, f"ed_rehello_arm_{nm}", 600, [(10, "press", "FLTR"), (ARM_AT, "usb", ARM), (250, "usb", rh)] + ra +
                gesture(at=400, turn_at=450, enc=4, hold=100))
        f = msf(e, r["snap"])
        g[nm] = (f.get("on"), f.get("gestures"), len(edk(r)))
    print(f"    re-hello then PAGE + T15: (ms.on, gestures, 13-reports) without re-arm {g['noarm']}, with {g['rearm']}")
    check("edrehello: a re-hello without a new arm: PAGE + T15 is stock's (ms.on 0, no gesture, no 2D 01 13)",
          g["noarm"] == (0, 0, 0), g["noarm"])
    check("edrehello: with the re-arm after the hello the gesture runs (ms.on 1, one gesture, held and let go)",
          g["rearm"][0] == 1 and g["rearm"][1] == 1 and g["rearm"][2] == 2, g["rearm"])
    cnt = ["--count", f"{STOCK_KEYH:x}", "--every", "1M"]
    n = {}
    for nm, re_ in (("rehello", [(215, "usb", rh)]), ("none", [])):
        cs = key_counts(run(e, f"ed_rehello_page_{nm}", 400, [(ARM_AT, "usb", ARM), (200, "press", "PAGE", 50)] + re_,
                            extra=cnt), STOCK_KEYH)
        c0 = max([x for c_, x in cs if c_ < s0 + 200] or [0])
        n[nm] = (cs[-1][1] - c0) if cs else None
    print(f"    stock's key handler calls: PAGE held back, re-hello inside {n['rehello']}, without {n['none']}")
    check("edrehello: PAGE kept back across the re-hello: stock gets its press and release as without it",
          n["rehello"] is not None and n["rehello"] == n["none"] >= 2, n)


def t_edclear(e):
    """Flash review M3: the readout is drawn on a cleared band: the glass's top rows are the same on two stock pages
    with different headers (FLTR, AMP) while it shows. A short readout ("A LEV 9", ~30 columns): stock's longer header
    (AMP's runs to column ~42) showed past its end."""
    le = L.Emu(e.tag)
    txt = S.sx(0x5A, 0x08, 7, *b"A LEV 9").hex()
    g = {}
    for pg in ("FLTR", "AMP"):
        g[pg] = L.glass(le.run(f"edc-{pg}", 150, [(10, "press", pg), (100, "sx", txt)])["oled"])[:RD_ROWS]
    bad = [i for i in range(RD_ROWS) if g["FLTR"][i] != g["AMP"][i]]
    print(f"    rows 0..{RD_ROWS - 1} differing between FLTR and AMP under the readout: {bad}")
    check("edclear: the readout's band is the same on FLTR and AMP (stock's header cleared behind it)", not bad, bad)
    txt_rows = [i for i in range(RD_ROWS) if "#" in g["AMP"][i][:70] and "." in g["AMP"][i][:70]]
    check("edclear: the readout is visible (its text cut out of the lit field, columns 0..69)", bool(txt_rows), txt_rows)


def clr_msgs(r):
    """2D 01 14: [(side, t, w)]"""
    return [(m[7], m[8], m[9]) for m in r["msgs"] if len(m) == 11 and m[4:7] == b"\x2d\x01\x14"]


def t_edclr(e):
    """A DATA ENTRY knob press under a held side (PAGE + T15 / T16) on a stock page: the scene lock of that knob's
    parameter is to be removed. The press (stock key PUSH_A..H, 0x70..0x77: the page's key handler resolves its
    parameter id with the same vtable lookup the turn's param_apply_delta uses) is eaten and reported, 2D 01 14 <side>
    <t> <w>; stock's p-lock clear (trig held + press) and the rest of its press never run; the release is eaten
    too while the side is held (after the side let go the repeats and the release go to stock: benign, below); a word that is not lockable shows NOT LOCKABLE and sends nothing; outside a held
    side the press is stock's (a held trig's lock is cleared)."""
    # 1. FLTR, knob E (FRQ: t 0, w 30), side A and B
    for side, key in ((0, "T15"), (1, "T16")):
        r = run(e, f"ed_clr_{key}", 500, [(10, "press", "FLTR"), (ARM_AT, "usb", ARM)] +
                gesture(key, enc=None) + [(300, "press", "PUSH_E", 20)])
        c, f = clr_msgs(r), msf(e, r["snap"])
        print(f"    {key}: 14 {c}; ms clrs {f.get('clrs')} pushd {f.get('pushd')} nolock {f.get('nolock')}")
        check(f"edclr {key}: one 2D 01 14 side {side}, t 0, w 30 (FRQ)", c == [(side, 0, 30)], c)
        check(f"edclr {key}: no NOT LOCKABLE, the release eaten (pushd 0)", f.get("nolock") == 0 and f.get("pushd") == 0, f)
    # 2. nothing written: the memory after the press under the side equals the run without the press
    pre = [(10, "press", "FLTR"), (60, "press", "RECORD"), (ARM_AT, "usb", ARM)]
    n = run(e, "ed_clr_none", 520, pre + gesture(enc=None))
    a = run(e, "ed_clr_grid", 520, pre + gesture(enc=None) + [(300, "press", "PUSH_E", 20)])
    d = mdiff(mem(e, n["snap"]), mem(e, a["snap"]))
    print(f"    GRID REC under side A: the press changes {len(d)} bytes {d[:6]}; 14 {clr_msgs(a)}")
    check("edclr grid: the press under the side writes nothing (pattern, locks, kit) and is reported",
          not d and clr_msgs(a) == [(0, 0, 30)], (d[:6], clr_msgs(a)))
    # 3. the release of an eaten press. The branches of ms_knob in the rc3 build (kc2, b3b93ce3...; the pcs follow the
    # build: re-read them from the watch of ms.pushd when rui.c changes): 0x47bec12e = press eaten (pushd set),
    # 0x47bec0ea = release eaten (side held, pushd cleared), 0x47bec10a = stale drop (a down event with no side: the
    # repeats of a press the side let go of clear the bit and go to stock, and so does the release: known, benign, the
    # fix is for the next release).
    # 0.5.2 rc4: the same branches as offsets from ms_knob (0x47bec0a8 in kc2), so they follow the build
    K = e.syms["rytm-0026-remote-ui:ms_knob"]
    P_PRESS, P_REL, P_STALE = K + 0x86, K + 0x42, K + 0x62
    PA = "%x" % (e.syms["rytm-0026-remote-ui:ms"] + 272)
    pcs = lambda r: sorted({p for p, _, _ in watches(r["out"])})   # noqa: E731
    r = run(e, "ed_clr_held_rel", 700, [(10, "press", "FLTR"), (ARM_AT, "usb", ARM)] + gesture(hold=600, enc=None) +
            [(300, "press", "PUSH_E", 100)], extra=["--watch", PA])
    c, f, w = clr_msgs(r), msf(e, r["snap"]), pcs(r)
    print(f"    release with the side held: 14 {c}; pushd {f.get('pushd')}; pcs {[hex(x) for x in w]}")
    check("edclr held release: the press reported once, its release eaten (the release-eaten branch 0x47bec0ea; pushd 0)",
          c == [(0, 0, 30)] and f.get("pushd") == 0 and P_PRESS in w and P_REL in w and P_STALE not in w, (c, [hex(x) for x in w]))
    r = run(e, "ed_clr_late", 700, [(10, "press", "FLTR"), (ARM_AT, "usb", ARM)] + gesture(hold=250, enc=None) +
            [(300, "press", "PUSH_E", 300)], extra=["--watch", PA])
    c, f, w = clr_msgs(r), msf(e, r["snap"]), pcs(r)
    print(f"    release after the side let go: 14 {c}; pushd {f.get('pushd')}; pcs {[hex(x) for x in w]}")
    check("edclr late: reported once; after the side let go the repeats and the release take the stale-drop branch "
          "0x47bec10a (go to stock, benign: memory diff 0), not the release-eaten one; pushd 0",
          c == [(0, 0, 30)] and f.get("pushd") == 0 and P_PRESS in w and P_STALE in w and P_REL not in w,
          (c, [hex(x) for x in w]))
    n = run(e, "ed_clr_late_none", 700, [(10, "press", "FLTR"), (ARM_AT, "usb", ARM)] + gesture(hold=250, enc=None))
    d = mdiff(mem(e, n["snap"]), mem(e, r["snap"]))
    check("edclr late: stock got the release without its press and wrote nothing (memory equals the run without the knob)",
          not d, d[:6])
    # positive cases on other tracks and pages: the op's (t, w) equals what the turn of the same knob reports
    for nm, pre3, enc, t_exp in (("lt_amp", [(10, "press", "LT"), (30, "press", "AMP")], 4, 5),
                                 ("lt_lfo", [(10, "press", "LT"), (30, "press", "LFO")], 0, 5),
                                 ("fx_dly", [(10, "press", "FX")], 0, 12), ("fx_fltr", [(10, "press", "FX"), (50, "press", "FLTR")], 0, 12)):
        tr = run(e, f"ed_clr_t_{nm}", 500, pre3 + [(ARM_AT, "usb", ARM)] + gesture(enc=enc))
        pr = run(e, f"ed_clr_p_{nm}", 500, pre3 + [(ARM_AT, "usb", ARM)] + gesture(enc=None) + [(300, "press", f"PUSH_{'ABCDEFGH'[enc]}", 20)])
        cc, c = caps(tr), clr_msgs(pr)
        print(f"    {nm}: turn 12 {[x[:3] for x in cc][:1]}; press 14 {c}")
        check(f"edclr {nm}: the press's (t, w) equals the turn's (track {t_exp})",
              bool(cc) and c == [(0, cc[0][1], cc[0][2])] and cc[0][1] == t_exp, (cc[:1], c))
    # 4. not lockable: the TRIG page (ids 28..38) and the FX track's SRC page (word 29)
    for nm, pre2 in (("trig", [(10, "press", "TRIG")]), ("fxsrc", [(10, "press", "FX"), (50, "press", "SRC")])):
        r = run(e, f"ed_clr_{nm}", 500, pre2 + [(ARM_AT, "usb", ARM)] + gesture(enc=None) + [(300, "press", "PUSH_A", 20)])
        f = msf(e, r["snap"])
        print(f"    {nm}: 14 {clr_msgs(r)}; nolock {f.get('nolock')} clrs {f.get('clrs')}")
        check(f"edclr {nm}: not lockable: NOT LOCKABLE, no 2D 01 14", not clr_msgs(r) and f.get("nolock", 0) > 0 and
              f.get("clrs") == 0, (clr_msgs(r), f.get("nolock")))
    # 5. outside a held side the press is stock's: GRID REC, T15 held as a trig with a lock (FRQ turned), press E: the
    # lock word (BD step 15, FRQ: 0x407e0c80) is cleared by stock (0xffff), armed and not, and nothing is reported
    stk = [(10, "press", "FLTR"), (60, "press", "RECORD"), (100, "press", "T15", 300), TURN(150, 4),
           (250, "press", "PUSH_E", 20)]
    for nm, ev in (("armed", [(ARM_AT, "usb", ARM)]), ("unarmed", [])):
        r = run(e, f"ed_clr_stock_{nm}", 450, stk + ev, extra=["--watch", "407e0c80"], env=dict(DTEMU_NO_JIT="1"))
        w = [v for _, _, v in watches(r["out"])]
        print(f"    stock press ({nm}): lock word writes {[hex(v) for v in w]}; 14 {clr_msgs(r)}")
        check(f"edclr stock {nm}: trig held + knob press clears the p-lock (0xffff written), nothing reported",
              w[-1:] == [0xffff] and not clr_msgs(r), (w, clr_msgs(r)))
    # 6. a trig held BEFORE the gesture (stock has it: T5 with a lock on FRQ), then PAGE + T15 and the press: stock's
    # clear of T5's lock does not run (the memory after the press equals the run without it)
    held = [(10, "press", "FLTR"), (60, "press", "RECORD"), (100, "press", "T5", 330), (ARM_AT, "usb", ARM), TURN(150, 4)]
    n = run(e, "ed_clr_held_none", 520, held + gesture(enc=None))
    a = run(e, "ed_clr_held_push", 520, held + gesture(enc=None) + [(300, "press", "PUSH_E", 20)])
    d = mdiff(mem(e, n["snap"]), mem(e, a["snap"]))
    print(f"    T5 held with a lock, side A, press: {len(d)} bytes {d[:6]}; 14 {clr_msgs(a)}")
    check("edclr held: a trig held before the side: the press under it clears no lock (nothing written) and is reported",
          not d and clr_msgs(a) == [(0, 0, 30)], (d[:6], clr_msgs(a)))


def t_m2(e):
    """Review M2: a host page (its mask without T1..T16), armed: PAGE (the host's) then T15 1 ms later, then T1 under it:
    T15 and T1 reach the host (31), not stock, before any new mask."""
    ev = S.page_ev(S.CATCH, 800) + [(400, "usb", ARM), (450, "press", "PAGE", 100), (451, "press", "T15", 60),
                                     (470, "press", "T1", 10)]
    r = run(e, "ed_m2", 800, ev)
    k = [x for x in S.keys(r) if x[0] in (0x84, 0x0e, 0)]
    print(f"    keys to the host: {k}")
    check("m2: PAGE, T15 and T1 (under T15) all reach the host, in order, releases too",
          k == [(0x84, 1), (0x0e, 1), (0, 1), (0, 0), (0x0e, 0), (0x84, 0)], k)


# ---------------------------------------------------------------- the flash review's gaps (notes: mods test gaps 2, 3)
STOCK_KEYH = 0x400a02ca      # stock's key handler (rui.c STOCK_KEY; the ev_key site's call when rui_key returns 0)
SCALE34 = [(10, "press", "FUNC:40"), (20, "press", "PAGE")] + [(60 + 15 * i, "press", "UP") for i in range(18)] + \
          [(400, "press", "NO")]   # pagelen's SCALE menu: a 34-step pattern (PAGE steps the pattern page)


def key_counts(r, a):
    """[(clock M, calls of a so far)] from the status lines"""
    return [(int(c), int(n)) for c, n in re.findall(rf"^\s*(\d+)M pc=\S+ .*?{a:08x}:(\d+)", r["out"], re.M)]


def latency(e, r, at):
    """ms from the key's press (at, M after the base) to stock's key handler's first call after it (None: never)"""
    cs = key_counts(r, STOCK_KEYH)
    t0 = e.base[1] + at
    c0 = max([n for c, n in cs if c < t0] or [0])
    later = [c for c, n in cs if c >= t0 and n > c0]
    return (later[0] - t0) * 5 if later else None


def t_pagelat(e):
    """Review M1: the time from PAGE's press to stock's key handler getting it (a --count at 0x400a02ca, sampled every
    1M = 5 ms). Unarmed: at the press. Armed tap of 20 / 100 / 250 ms: at the release (+10 ms at most). Armed held
    400 ms: after MS_PAGE_TICKS (6 ticks: 250..350 ms), never later. The table is printed (the owner's hardware test
    quotes it)."""
    rows = []
    for nm, armed, hold in (("unarmed tap 20", False, 4), ("armed tap 20", True, 4), ("armed tap 100", True, 20),
                            ("armed tap 250", True, 50), ("armed held 400", True, 80)):
        ev = ([(ARM_AT, "usb", ARM)] if armed else []) + [(200, "press", "PAGE", hold)]
        r = run(e, f"plat_{nm.replace(' ', '_')}", 400, ev, extra=["--count", f"{STOCK_KEYH:x}", "--every", "1M"])
        rows.append((nm, hold * 5, latency(e, r, 200)))
    print("    case               hold ms   stock gets PAGE after (ms)")
    for nm, h, lat in rows:
        print(f"    {nm:18s} {h:7d}   {lat}")
    lat = {nm: x for nm, _, x in rows}
    check("pagelat: unarmed: stock gets PAGE at its press (within 5 ms)", lat["unarmed tap 20"] is not None and
          lat["unarmed tap 20"] <= 5, lat["unarmed tap 20"])
    check("pagelat: armed taps: at the release (hold .. hold + 10 ms)",
          all(lat[n] is not None and h <= lat[n] <= h + 10 for n, h, _ in rows if "tap" in n and n.startswith("armed")),
          [(n, h, lat[n]) for n, h, _ in rows])
    check("pagelat: armed held 400 ms: after 6 ticks (250..350 ms), never later", lat["armed held 400"] is not None and
          250 <= lat["armed held 400"] <= 350, lat["armed held 400"])


def t_pagefast(e):
    """Review M1: on a 32-step pattern (pagelen's SCALE menu) in GRID REC, armed, four PAGE taps 100 ms apart (20 ms each): the same
    end state as the same taps unarmed (the pattern page stepped four times); control: the taps change the state."""
    le = L.Emu(e.tag)
    taps = [(500 + 20 * i, "press", "PAGE:4") for i in range(4)]
    arm = [(450, "sx", ARM.hex())]
    pre = SCALE34 + [(430, "press", "RECORD")]   # GRID REC: PAGE steps the shown pattern page (the page LEDs)
    a = L.stock_state(le, le.run("pf-arm", 700, pre + arm + taps))
    u_ = L.stock_state(le, le.run("pf-un", 700, pre + taps))
    n = L.stock_state(le, le.run("pf-none", 700, pre))
    bad = [k for k in a if a[k] != u_.get(k)]
    print(f"    the taps change {[k for k in u_ if u_[k] != n.get(k)][:6]}; armed vs unarmed differ in {bad[:6]}")
    check("pagefast: (control) the four taps change the page state", any(u_[k] != n.get(k) for k in u_))
    check("pagefast: armed, four fast taps: the end state as unarmed", not bad, bad[:6])


def t_pagechord(e):
    """Review M1: armed, on the contexts of pagekeys (CTX; PAGECTX narrows them): FUNC + PAGE (the SCALE menu), PAGE
    then CHRO 50 ms later, PAGE then T1 50 ms later, PAGE then T1 400 ms later: the stock state (rled's compare) as
    the same keys unarmed, every case."""
    le = L.Emu(e.tag)
    arm = [(ARM_AT, "sx", ARM.hex())]
    want = os.environ.get("PAGECTX")
    cases = (("funcpage", [(160, "press", "FUNC:30"), (170, "press", "PAGE:10")]),
             ("pagekey", [(160, "press", "PAGE:30"), (170, "press", "CHRO")]),
             ("paget1", [(160, "press", "PAGE:30"), (170, "press", "T1:10")]),
             ("paget1late", [(160, "press", "PAGE:120"), (240, "press", "T1:10")]))
    for ctx, pre in CTX:
        if want and ctx not in want.split(","):
            continue
        for nm, ev in cases:
            a = L.stock_state(le, le.run(f"pch-{ctx}-{nm}-arm", 420, pre + arm + ev))
            u_ = L.stock_state(le, le.run(f"pch-{ctx}-{nm}-un", 420, pre + ev))
            bad = [k for k in a if a[k] != u_.get(k)]
            check(f"pagechord {ctx} {nm}: armed as unarmed", not bad, bad[:6])


TRIG_SITE = 0x4009afa0       # trig_fire where the velocity is final (pm's pmo_vel_det): once a trig


def l2s(ev):
    """rled-style events (KEY:HOLD, 'sx' hex, a turn of 3) as sq_emu's"""
    out = []
    for x in ev:
        if x[1] == "press":
            k, _, h = x[2].partition(":")
            out.append((x[0], "press", k, int(h)) if h else (x[0], "press", k))
        elif x[1] == "turn":
            out.append((x[0], "turn", x[2], 3, 4))
        else:
            out.append((x[0], "usb", bytes.fromhex(x[2])))
    return out


def t_pageplay(e):
    """Review M1: pagefast's four taps while the sequencer plays (34 steps) and a kit knob is turned: the end state as
    unarmed, and no trig eaten (trig_fire's calls over the run as unarmed, counted in sq_emu runs of the same events)."""
    le = L.Emu(e.tag)
    ev = SCALE34 + [(420, "press", "PLAY"), (505, "turn", "4:+8")] + [(500 + 20 * i, "press", "PAGE:4") for i in range(4)]
    arm = [(450, "sx", ARM.hex())]
    a, u_ = L.stock_state(le, le.run("pp-arm", 700, ev + arm)), L.stock_state(le, le.run("pp-un", 700, ev))
    cnt = ["--count", f"{TRIG_SITE:x}", "--every", "700M"]
    ta = key_counts(run(e, "pp_arm_trigs", 700, l2s(ev + arm), extra=cnt), TRIG_SITE)
    tu = key_counts(run(e, "pp_un_trigs", 700, l2s(ev), extra=cnt), TRIG_SITE)
    bad = [k for k in a if a[k] != u_.get(k)]
    print(f"    trig_fire calls armed {ta[-1:]} unarmed {tu[-1:]}; state differs in {bad[:6]}")
    check("pageplay: playing, taps and a turn: the end state as unarmed", not bad, bad[:6])
    check("pageplay: no trig eaten (trig_fire's calls as unarmed, some)", bool(ta and tu) and ta[-1][1] == tu[-1][1] > 0,
          (ta[-1:], tu[-1:]))


def t_pageunarm(e):
    """Review M1 / L1 from the user's side: armed, then a port drop (and its hello): a PAGE tap then reaches stock at
    its press (the unarmed figure). PAGE held across the drop: the stock state at the end as unarmed (the calls of
    stock's key handler printed for both)."""
    s0 = e.base[1]
    gone = ["--usb-host-gone", f"{s0 + 200}M:{s0 + 300}M"]
    cnt = ["--count", f"{STOCK_KEYH:x}", "--every", "1M"]
    r = run(e, "pun_tap", 600, [(ARM_AT, "usb", ARM), (450, "press", "PAGE", 4)], extra=gone + cnt)
    lat = latency(e, r, 450)
    print(f"    after the drop, a PAGE tap reaches stock after {lat} ms")
    check("pageunarm: after the drop a PAGE tap reaches stock at its press (within 5 ms)", lat is not None and lat <= 5, lat)
    held = [(180, "press", "PAGE", 200)]
    n = {}
    for nm, arm in (("arm", [(ARM_AT, "usb", ARM)]), ("un", [])):
        cs = key_counts(run(e, f"pun_held_{nm}", 600, arm + held, extra=gone + cnt), STOCK_KEYH)
        c0 = max([x for c, x in cs if c < s0 + 180] or [0])
        n[nm] = (cs[-1][1] - c0) if cs else None
    le = L.Emu(e.tag)
    a = L.stock_state(le, le.run("pun-held-arm", 600, [(ARM_AT, "sx", ARM.hex()), (180, "press", "PAGE:200")], extra=gone))
    u_ = L.stock_state(le, le.run("pun-held-un", 600, [(180, "press", "PAGE:200")], extra=gone))
    bad = [k for k in a if a[k] != u_.get(k)]
    print(f"    PAGE held across the drop: stock's key handler called {n['arm']} times armed, {n['un']} unarmed "
          f"(press, repeats, release); the state differs in {bad[:6]}")
    check("pageunarm: PAGE held across the drop: stock's state at the end as unarmed", not bad, bad[:6])


def t_edrate(e):
    """Review M3 (redraw rate): armed, FLTR, PAGE + T15 held, FRQ turned a detent every 100 ms for 5 s, the host's
    readout (5A 01 08) new after each turn (as the host sends it): the panel frames (full redraws) against the same
    sweep unarmed. Budget: the unarmed count plus one a readout change (+2). The readout's tick asks for a redraw
    every tick (20 Hz) while it lasts: the owner kept that (2026-11-14, M3) unless hardware shows lag."""
    turns = [(260 + 20 * i, "turn", "4:+8", 1, 4) for i in range(50)]
    rds = [(262 + 20 * i, "usb", S.sx(0x5A, 0x08, 8, *f"A FRQ {i:02d}".encode())) for i in range(50)]
    held = [(200, "press", "PAGE", 1100), (210, "press", "T15", 1050)]
    out = {}
    for nm, ev in (("armed", [(10, "press", "FLTR"), (ARM_AT, "usb", ARM)] + held + turns + rds),
                   ("unarmed", [(10, "press", "FLTR")] + turns)):
        r = run(e, f"edrate_{nm}", 1300, ev, extra=["--every", "10M"])
        st = [(int(c), int(f)) for c, f in re.findall(r"^\s*(\d+)M pc=\S+ .*?frames=(\d+)", r["out"], re.M)]
        w = [f for c, f in st if e.base[1] + 255 <= c <= e.base[1] + 1260]
        out[nm] = (w[-1] - w[0]) if len(w) > 1 else None
    print(f"    panel frames over the 5 s sweep: armed {out['armed']}, unarmed {out['unarmed']}, readouts 50")
    check("edrate: armed frames <= unarmed + one a readout (50) + 2", None not in out.values() and
          out["armed"] <= out["unarmed"] + 52, out)


TESTS = dict(mute=t_mute, qpmute=t_qpmute, padword=t_padword, padtrig=t_padtrig, padbase=t_padbase, pagekeys=t_pagekeys,
             pagelen=t_pagelen, pagecatch=t_pagecatch, leds=t_leds, hdr=t_hdr, edcap=t_edcap, edfx=t_edfx,
             edgrid=t_edgrid, edpick=t_edpick, edpage=t_edpage, edleds=t_edleds, edread=t_edread, edhello=t_edhello, edhold=t_edhold, edrehello=t_edrehello, edclear=t_edclear, edclr=t_edclr,
             m2=t_m2, pagelat=t_pagelat, pagefast=t_pagefast, pagechord=t_pagechord, pageplay=t_pageplay,
             pageunarm=t_pageunarm, edrate=t_edrate)


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(2)
    e = S.Emu(sys.argv[1])
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    for n in names:
        print(f"== {n}", flush=True)
        TESTS[n](e)
    print(f"\n{'ALL PASS' if not FAILS else f'{len(FAILS)} FAIL: ' + ', '.join(FAILS)}"
          + (f" (+ {len(STOCK)} declared stock-fact probes still failing, as measured)" if STOCK else ""))
    sys.exit(1 if FAILS else 0)


if __name__ == "__main__":
    main()
