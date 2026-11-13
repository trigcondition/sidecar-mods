#!/usr/bin/env python3
"""Emulator tests of rui1031: 6-OP FM's chord knobs (SMPL E..H = CHD INV SPR VOI) and the MULTISAMPLE machine (52, voice
flag 0x30), labelled by 0026 (cu_tick, cu_setup, cu_steps through 0021's us_cubox).

    RYTM_EMU=... .venv/bin/python tools/emu/cu_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a rui build (0021 slots=1, 0026, 0029) with its base from tools/emu/us_base.sh TAG. Every run under DTEMU_STRICT=1
(pc_emu.py's Emu). Screens: build/emu/<TAG>/pc_cu_*.png. Records: 0x401bf918 + 0x34 r (+0x28 long name, +0x2c group, +0x30
short name), descriptors 0x419a4888 + 84 r (+32 the value text). The kit's P1..P16 of track t: 0x41255933 + 152 t + 2 k
(kit 0). Value texts as the host's (rytm-teensy core/poly.cpp value_text, sim/protocol.py chord_value_text).
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pc_emu as PC   # noqa: E402

FAILS = PC.FAILS
check = PC.check
P2 = (438, 457, 458, 459, 460, 403, 404, 405)          # 0021's us_p2rec: sample words 17..24
SRC = (398, 443, 399, 400, 401, 402, 406, 407)         # MULTISAMPLE P1..P8
SRC_LABELS = ["INST", "VEL", "LEV", "RTRG", "ATK", "DEC", "SUS", "REL"]
P2_LABELS = ["TUNE", "FINE", "STRT", "LOOP", "CHD", "INV", "SPR", "VOI"]
MS_DEFAULTS = [0, 127, 100, 0, 64, 64, 64, 64]
KIT = 0x41255933


def rec(r):
    return 0x401bf918 + 0x34 * r


def u32(e, s, a):
    return int.from_bytes(e.peek(s, a, 4), "big")


def cstr(e, s, a, n=16):
    return e.peek(s, a, n).split(b"\0")[0].decode("ascii", "replace")


def label(e, s, r, off=0x30):
    return cstr(e, s, u32(e, s, rec(r) + off))


def kit16(e, s, t=0):
    return list(e.peek(s, KIT + 152 * t, 32)[::2])


MS = None


def ms(e):
    """BD on MULTISAMPLE (machine 52): the machine list's last entry, from the base."""
    global MS
    if MS is None:
        keys = ["SRC", "SRC"] + ["DOWN"] * 32 + ["YES"]   # 1034: WAVETABLE and GRANULAR before DAISYSP; 1051: LIVE IN, CHOP; 7o: MIDI; 0.5.0: SAMPLER
        ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)]
        r = e.run("cu_ms", 500 + 500 * len(keys) + 1500, ev, usb=False)
        m = e.peek(r["snap"][0], 0x8000EA00, 1)[0]
        check("ms: BD's machine is MULTISAMPLE (52), the list's 32nd entry (after DAISYSP)", m == 52, m)
        MS = r["snap"]
    return MS


WT_SRC = ["TBL", "POS", "WARP", "AMT", "UNI", "SUB", "CUT", "RES"]
WT_P2 = ["ATK", "DEC", "SUS", "ENV", "CHD", "INV", "SPR", "VOI"]
WT_DEFAULTS = [1, 0, 0, 0, 0, 0, 64, 0]   # 1043: TBL 1 (A001; was 0)
GR_SRC = ["SRC", "POS", "SPRY", "SIZE", "DENS", "PRND", "REV", "WIN"]
GR_P2 = ["ATK", "REL", "HOLD", "ANIM", "CHD", "INV", "SPR", "VOI"]
GR_DEFAULTS = [10, 0, 20, 64, 64, 0, 0, 0]
# 1051: LIVE IN (48, flag 0x78; rytm-teensy docs/LIVE-IN.md 4) and CHOP (49, flag 0x18; docs/CHOP.md)
LI_SRC = ["INPT", "GAIN", "GATE", "HOLD", "MON", "ATK", "DEC", "SUS"]
LI_P2 = ["REL", "-", "-", "-", "-", "-", "-", "-"]
LI_DEFAULTS = [80, 64, 0, 28, 0, 0, 77, 0]
CP_SRC = ["SRC", "SLC", "TUNE", "MRPH", "SEED", "NBR", "VEL", "LEV"]
CP_P2 = ["STUT", "SLEN", "TAPE", "TTIM", "ATK", "DEC", "DIR", "LOOP"]
CP_DEFAULTS = [10, 0, 64, 0, 0, 0, 64, 100]
NM = {}


def nm(e, m, downs):
    """1034: BD on WAVETABLE (46, the list's 26th entry, after DSP SAMPLE) or GRANULAR (47, the 27th), from the base."""
    if m not in NM:
        keys = ["SRC", "SRC"] + ["DOWN"] * downs + ["YES"]
        ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)]
        r = e.run(f"cu_nm{m}", 500 + 500 * len(keys) + 1500, ev, usb=False)
        got = e.peek(r["snap"][0], 0x8000EA00, 1)[0]
        check(f"nm: BD's machine is {m}", got == m, got)
        NM[m] = r["snap"]
    return NM[m]


def t_nm(e, m, name, short, flag, src_labels, p2_labels, defaults, downs, p2_defaults=None):
    s0 = nm(e, m, downs)
    s = s0[0]
    if p2_defaults is not None:   # 1051: LIVE IN / CHOP take page 2's defaults at the choice too
        k2 = kit16(e, s)[8:16]
        check(f"{name}: the machine choice set P9..P16 to its page 2's defaults {p2_defaults}", k2 == p2_defaults, k2)
    got = [label(e, s, x) for x in SRC]
    check(f"{name}: SRC records' short names {src_labels}", got == src_labels, got)
    check(f"{name}: their group is {short}", label(e, s, SRC[0], 0x2c) == short, label(e, s, SRC[0], 0x2c))
    check(f"{name}: the SRC records' machine field is {m}", all(u32(e, s, rec(x)) == m for x in SRC),
          [u32(e, s, rec(x)) for x in SRC])
    ids = [u32(e, s, 0x413DB5FC + 4 * (mm * 8 + k)) for mm in (m, 52) for k in range(8)]
    check(f"{name}: sound_param_id_for_index's ids for {m} = machine 52's", ids[:8] == ids[8:] and ids[0] != 0, ids)
    k = kit16(e, s)
    check(f"{name}: the machine choice set P1..P8 to its defaults {defaults}", k[:8] == defaults, k[:8])
    e.run(f"cu_{name}src", 1500, [(300, "press", "SRC")], snap=s0, usb=False)
    print(f"  look at build/emu/{e.tag}/pc_cu_{name}src.png: SRC page {' '.join(src_labels)}")
    r = e.run(f"cu_{name}smpl", 2500, [(300, "press", "SMPL"), (1200, "press", "BD", 200)], snap=s0)
    s2 = r["snap"][0]
    got = [label(e, s2, x) for x in P2]
    check(f"{name}: SMPL records' short names {p2_labels}", got == p2_labels, got)
    check(f"{name}: their group is {short}", label(e, s2, P2[0], 0x2c) == short, label(e, s2, P2[0], 0x2c))
    t = [x for x in r["sysex"] if len(x) > 8 and x[4] == 0x04]
    print(f"  0x04s: {[x.hex() for x in t]}")
    ok = bool(t) and t[0][5] == flag and [t[0][8 + 2 * i] for i in range(8)] == defaults
    check(f"{name}: the pad's 0x04: voice byte {flag:#x}, P1..P8 the defaults", ok, t[0].hex() if t else "none")
    print(f"  look at build/emu/{e.tag}/pc_cu_{name}smpl.png: SAMPLE page {' '.join(p2_labels)}")
    return s0


def t_wt(e):
    """1034 WAVETABLE (46, flag 0x28): labels on both pages, defaults, ids, the 0x04; WARP (C on SRC) stepped in 4 zones:
    turned up = a zone's low end (32 / 64 / 96), its text a PNG."""
    s0 = t_nm(e, 46, "wt", "WTBL", 0x28, WT_SRC, WT_P2, WT_DEFAULTS, 26)
    ev = [(300, "press", "SRC"), (900, "turn", "2:5", 8, 40)]
    r = e.run("cu_wtwarp", 2500, ev, snap=s0, usb=False)
    k = kit16(e, r["snap"][0])
    check("wt: WARP turned up: a zone's low end (32, 64 or 96)", k[2] in (32, 64, 96), k[:8])
    print(f"  look at build/emu/{e.tag}/pc_cu_wtwarp.png: WARP reads SYNC / PWM / FM")


def t_gr(e):
    """1034 GRANULAR (47, flag 0x38): labels on both pages, defaults, ids, the 0x04; WIN (H on SRC) 4 zones; HOLD (C on
    SMPL, continuous) and ANIM (D) turned; their texts in the PNG."""
    s0 = t_nm(e, 47, "gr", "GRAN", 0x38, GR_SRC, GR_P2, GR_DEFAULTS, 27)
    ev = [(300, "press", "SRC"), (900, "turn", "7:5", 8, 40), (1500, "press", "SMPL"), (2100, "turn", "2:5", 30, 40),
          (3500, "turn", "3:5", 6, 40)]
    r = e.run("cu_grknobs", 5000, ev, snap=s0, usb=False)
    k = kit16(e, r["snap"][0])
    check("gr: WIN turned up: a zone's low end (32, 64 or 96)", k[7] in (32, 64, 96), k[:8])
    check("gr: HOLD (continuous) moved from the stock word 64", k[10] != 64, k[8:])
    check("gr: ANIM turned up from 0", k[11] > 0, k[8:])
    print(f"  look at build/emu/{e.tag}/pc_cu_grknobs.png: HOLD's text v x 99 / 119 (37 -> 30), ANIM's rate (4 -> 8BAR)")


def t_swap(e):
    """1034: GRANULAR -> WAVETABLE (UP one) -> MULTISAMPLE (DOWN five since 1051): the shared SRC records follow each choice and
    each choice writes its own machine's defaults."""
    s0 = nm(e, 47, 27)
    keys = ["SRC", "SRC", "UP", "YES"]
    ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)]
    r = e.run("cu_swap_wt", 4000, ev, snap=s0, usb=False)
    s = r["snap"][0]
    check("swap: BD on WAVETABLE", e.peek(s, 0x8000EA00, 1)[0] == 46, e.peek(s, 0x8000EA00, 1)[0])
    check("swap: WAVETABLE's labels and defaults", [label(e, s, x) for x in SRC] == WT_SRC and kit16(e, s)[:8] ==
          WT_DEFAULTS, ([label(e, s, x) for x in SRC], kit16(e, s)[:8]))
    keys = ["SRC", "SRC"] + ["DOWN"] * 6 + ["YES"]   # 46 -> 52 past 47, 48, 49 (1051), 50 (7o) and 51
    ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)] + [(5000, "press", "SMPL")]
    r = e.run("cu_swap_ms", 6500, ev, snap=r["snap"], usb=False)
    s = r["snap"][0]
    check("swap: BD on MULTISAMPLE", e.peek(s, 0x8000EA00, 1)[0] == 52, e.peek(s, 0x8000EA00, 1)[0])
    check("swap: MULTISAMPLE's labels and defaults", [label(e, s, x) for x in SRC] == SRC_LABELS and kit16(e, s)[:8] ==
          MS_DEFAULTS, ([label(e, s, x) for x in SRC], kit16(e, s)[:8]))
    check("swap: SMPL TUNE..VOI, group MSMP", [label(e, s, x) for x in P2] == P2_LABELS and
          label(e, s, P2[0], 0x2c) == "MSMP", [label(e, s, x) for x in P2])


def t_fm(e):
    """6-OP FM's SMPL page: E..H labelled CHD INV SPR VOI (group 6OP), A..D stock's; knob E stepped (a list of 16): six
    steps (24 counts of +5: an enum knob steps every fourth, us_emu t_enum) store 6 (MAJ7); the page's PNG."""
    f = PC.fm(e)
    ev = [(300, "press", "SMPL"), (1500, "turn", "4:5", 24, 40)]
    r = e.run("cu_fm", 3500, ev, snap=f, usb=False)
    s = r["snap"][0]
    got = [label(e, s, x) for x in P2[4:]]
    check("fm: SMPL E..H records' short names CHD INV SPR VOI", got == P2_LABELS[4:], got)
    check("fm: their group is 6OP", label(e, s, P2[4], 0x2c) == "6OP", label(e, s, P2[4], 0x2c))
    k = kit16(e, s)
    check("fm: knob E turned 6 steps: sound word 21 (P13) = 6 (MAJ7: a list knob, the value the index)", k[12] == 6, k)
    rng = u32(e, s, rec(P2[4]) + 12)
    check("fm: CHD's range 0..15 (0029's stepped list, 16 entries)", rng == 15 << 8, hex(rng))
    print(f"  look at build/emu/{e.tag}/pc_cu_fm.png: SAMPLE page, E..H CHD INV SPR VOI, E reads MAJ7 (or its step number)")


def t_fmtext(e):
    """The chord value texts at the stock words (STA 0, END 120, LOP 0, LEV 100: out of range reads the first) and at
    the 28 write-back's values: the page's PNG with OFF INV0 SPR0 AUTO, then MIN INV1 SPR1 3."""
    f = PC.fm(e)
    r = e.run("cu_fmtext0", 2000, [(300, "press", "SMPL")], snap=f, usb=False)
    s = r["snap"][0]
    k = kit16(e, s)
    print(f"  stock words 21..24: {k[12:16]}  look at build/emu/{e.tag}/pc_cu_fmtext0.png: OFF INV0 SPR0 AUTO")
    pk = e.pokes(s, {KIT + 2 * 12: bytes([2]), KIT + 2 * 13: bytes([1]), KIT + 2 * 14: bytes([1]),
                     KIT + 2 * 15: bytes([3])})
    r2 = e.run("cu_fmtext1", 1500, [(300, "press", "SMPL"), (800, "press", "SMPL")], snap=r["snap"], usb=False, extra=pk)
    check("fmtext: the run with the poked words ran", r2 is not None)
    print(f"  look at build/emu/{e.tag}/pc_cu_fmtext1.png: MIN INV1 SPR1 3")


def t_ms(e):
    """MULTISAMPLE: the SRC records named INST VEL LEV RTRG ATK DEC SUS REL, the kit's P1..P8 = their defaults
    (0 127 100 0 64 64 64 64); SMPL: the shared records TUNE FINE STRT LOOP CHD INV SPR VOI (group MSMP); a BD pad's 0x04
    has the voice byte 0x30 (BD = voice 0) and P1..P8 = the defaults."""
    m = ms(e)
    s = m[0]
    got = [label(e, s, x) for x in SRC]
    check("ms: SRC records' short names", got == SRC_LABELS, got)
    k = kit16(e, s)
    check("ms: the machine choice set P1..P8 to the records' defaults", k[:8] == MS_DEFAULTS, k[:8])
    r = e.run("cu_mssrc", 1500, [(300, "press", "SRC")], snap=m, usb=False)
    print(f"  look at build/emu/{e.tag}/pc_cu_mssrc.png: SRC page INST VEL LEV RTRG / ATK DEC SUS REL")
    r = e.run("cu_mssmpl", 2500, [(300, "press", "SMPL"), (1200, "press", "BD", 200)], snap=m)
    s2 = r["snap"][0]
    got = [label(e, s2, x) for x in P2]
    check("ms: SMPL records' short names", got == P2_LABELS, got)
    check("ms: their group is MSMP", label(e, s2, P2[0], 0x2c) == "MSMP", label(e, s2, P2[0], 0x2c))
    t = [x for x in r["sysex"] if len(x) > 8 and x[4] == 0x04]
    print(f"  0x04s: {[x.hex() for x in t]}")
    ok = bool(t) and t[0][5] == 0x30 and [t[0][8 + 2 * i] for i in range(8)] == MS_DEFAULTS
    check("ms: the pad's 0x04: voice byte 0x30, P1..P8 the defaults", ok, t[0].hex() if t else "none")
    if t:
        check("ms: the 0x04's P13..P16 = the kit's words 21..24", [t[0][8 + 2 * i] for i in range(12, 16)] ==
              kit16(e, s2)[12:16], t[0].hex())
    print(f"  look at build/emu/{e.tag}/pc_cu_mssmpl.png: SAMPLE page TUNE FINE STRT LOOP / CHD INV SPR VOI")


def t_msknobs(e):
    """MULTISAMPLE's stepped knobs: RTRG (D on SRC) turned up = ON (64, two zones), LOOP (D on SMPL) two steps = ON
    (the zone's low end 86), VOI (H, from the stock word 100 = AUTO, out of range) turned up = a count 1..6."""
    m = ms(e)
    ev = [(300, "press", "SRC"), (900, "turn", "3:5", 8, 40), (1500, "press", "SMPL"), (2100, "turn", "3:5", 16, 40),
          (3100, "turn", "7:5", 12, 40)]   # (7o: 16 turns: how many steps 8 give depends on where they fall in the UI ticks)
    r = e.run("cu_msknobs", 5000, ev, snap=m, usb=False)
    k = kit16(e, r["snap"][0])
    check("msknobs: RTRG = 64 (ON)", k[3] == 64, k[:8])
    check("msknobs: LOOP = 86 (ON's zone, as the host reads 86..127)", k[11] == 86, k[8:])
    check("msknobs: VOI a count 1..6", 1 <= k[15] <= 6, k[8:])
    print(f"  look at build/emu/{e.tag}/pc_cu_msknobs.png")


def t_back(e):
    """Back to 6-OP FM and back to a user slot: the shared records follow the selected track's machine (FM: group 6OP,
    E..H the chord; U1 (no Sidecar: no 1A) stock's SAMPLE page)."""
    m = ms(e)
    keys = ["SRC", "SRC"] + ["UP"] * 12 + ["YES"]   # 52 -> 40 (1034: past 47 and 46; 1051: 49 and 48; 7o: 50; 0.5.0: 43)
    ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)] + [(8000, "press", "SMPL")]   # (0.5.0: after the 15th key, 7500)
    r = e.run("cu_back_fm", 9500, ev, snap=m, usb=False)
    s = r["snap"][0]
    check("back: BD on 6-OP FM again", e.peek(s, 0x8000EA00, 1)[0] == 40, e.peek(s, 0x8000EA00, 1)[0])
    check("back: group 6OP, E..H CHD..VOI", label(e, s, P2[4], 0x2c) == "6OP" and
          [label(e, s, x) for x in P2[4:]] == P2_LABELS[4:], [label(e, s, x) for x in P2])
    keys = ["SRC", "SRC"] + ["UP"] * 5 + ["YES"]   # 40 -> 35 (U1)
    ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)] + [(5000, "press", "SMPL")]
    r = e.run("cu_back_u1", 6500, ev, snap=r["snap"], usb=False)
    s = r["snap"][0]
    mm = e.peek(s, 0x8000EA00, 1)[0]
    check("back: BD on U1 (35)", mm == 35, mm)
    print(f"  look at build/emu/{e.tag}/pc_cu_back_u1.png: U1 without a Sidecar: stock's SAMPLE page (STA END LOP LEV)")


def t_li(e):
    """1051 LIVE IN (48, flag 0x78): labels on both pages (page 2: REL, the rest unused), defaults, ids, the 0x04; INPT
    (A on SRC) 4 zones, MON (E) 2 zones turned up: a zone's low end; the texts in the PNG."""
    s0 = t_nm(e, 48, "li", "LVIN", 0x78, LI_SRC, LI_P2, LI_DEFAULTS, 28, [77, 0, 0, 0, 0, 0, 0, 0])
    ev = [(300, "press", "SRC"), (900, "turn", "0:5", 8, 40), (1500, "turn", "4:5", 8, 40)]
    r = e.run("cu_liknobs", 3000, ev, snap=s0, usb=False)
    k = kit16(e, r["snap"][0])
    check("li: INPT turned: STR's zone (96) from L+R (80)", k[0] == 96, k[:8])
    check("li: MON turned up: TRIG's zone (64)", k[4] == 64, k[:8])
    print(f"  look at build/emu/{e.tag}/pc_cu_liknobs.png: INPT STR, MON TRIG, GATE OFF")


def t_cp(e):
    """1051 CHOP (49, flag 0x18): labels on both pages, defaults, ids, the 0x04; SLC (B on SRC) stepped in 64 zones (a
    zone's low end: even), TAPE (C on SMPL) 4 zones, DIR (G) 3 zones; their texts in the PNG."""
    s0 = t_nm(e, 49, "cp", "CHOP", 0x18, CP_SRC, CP_P2, CP_DEFAULTS, 29, [0] * 8)
    ev = [(300, "press", "SRC"), (900, "turn", "1:5", 12, 40), (1500, "press", "SMPL"), (2100, "turn", "2:5", 8, 40),
          (2700, "turn", "6:5", 8, 40)]
    r = e.run("cu_cpknobs", 4500, ev, snap=s0, usb=False)
    k = kit16(e, r["snap"][0])
    check("cp: SLC turned up: a slice's zone (even, > 0)", k[1] > 0 and k[1] % 2 == 0, k[:8])
    check("cp: TAPE turned up from SLC: a zone's low end (32, 64 or 96)", k[10] in (32, 64, 96), k[8:])
    check("cp: DIR turned up from SLC: FWD / REV's zone (43 or 86)", k[14] in (43, 86), k[8:])
    check("cp: STUT / LOOP untouched: SLC (0)", k[8] == 0 and k[15] == 0, k[8:])
    print(f"  look at build/emu/{e.tag}/pc_cu_cpknobs.png: SLC n, TAPE OFF / STOP, DIR FWD")


# 0.5.0 SAMPLER (43, FUNC. GEN.'s slot; voice flag 0x20 as DSP SAMPLE, the sound tag 0x29C1 in its reports, P1..P8 0).
# Its SRC page: SMP on DSP SAMPLE's 441 (word 19), the rest the shared sample-word records (us_p2rec) as words 17..24.
# Knob order (owner, 2026-11-12 hardware test): SMP STRT END PLAY / TUNE FINE LOOP LEV (STRT / END by the waveform, TUNE /
# FINE where the display shows their values); the words (P9..P16) are unchanged, only the knobs that show them moved.
SA_ROW = [441, 460, 403, 459, 438, 457, 404, 405]
SA_LABELS = ["SMP", "STRT", "END", "PLAY", "TUNE", "FINE", "LOOP", "LEV"]
SA_WORDS = [64, 64, 0, 0, 0, 120, 0, 100]       # words 17..24 at the choice: TUNE FINE SMP PLAY STRT END LOOP LEV
SA_TAG = 0x29C1


def t_sa(e):
    """0.5.0 SAMPLER (43): in BD's machine list after DIGIDRUM (23 downs); long name SAMPLER, short SMPR; its SRC row the
    records 441 460 403 459 438 457 404 405 named SMP STRT END PLAY / TUNE FINE LOOP LEV (group SMPR); TUNE's range
    4..124 (8.8 0x0400..0x7c00), STRT END LOOP 0..120; the choice writes words 17..24 = 64 64 0 0 0 120 0 100; the pad's
    0x04: voice byte 0x20, P1..P8 0, P9..P16 the kit's words 17..24, the tag 0x29C1 (bytes 53 41)."""
    s0 = nm(e, 43, 23)
    s = s0[0]
    nmp = 0x401befa4 + 8 * 43
    names = (cstr(e, s, u32(e, s, nmp)), cstr(e, s, u32(e, s, nmp + 4)))
    check("sa: machine 43's names SAMPLER / SMPR", names == ("SAMPLER", "SMPR"), names)
    row = [u32(e, s, 0x40287ccc + 36 * 43 + 4 * k) for k in range(8)]
    check(f"sa: the SRC row {SA_ROW}", row == SA_ROW, row)
    k = kit16(e, s)
    check(f"sa: the choice wrote words 17..24 = {SA_WORDS}", k[8:16] == SA_WORDS, k[8:16])
    r = e.run("cu_sasrc", 1500, [(300, "press", "SRC")], snap=s0, usb=False)
    s1 = r["snap"][0]
    got = [label(e, s1, x) for x in SA_ROW]
    check(f"sa: SRC records' short names {SA_LABELS}", got == SA_LABELS, got)
    check("sa: their group is SMPR", label(e, s1, 438, 0x2c) == "SMPR", label(e, s1, 438, 0x2c))
    check("sa: record 458 (word 19's shared record, not on its page) labelled -", label(e, s1, 458) == "-", label(e, s1, 458))
    rng = [(u32(e, s1, rec(x) + 8), u32(e, s1, rec(x) + 12)) for x in (438, 460, 403, 404)]
    check("sa: TUNE 4..124, STRT END LOOP 0..120 (8.8)", rng == [(0x400, 0x7c00), (0, 0x7800), (0, 0x7800), (0, 0x7800)],
          [(hex(a), hex(b)) for a, b in rng])
    print(f"  look at build/emu/{e.tag}/pc_cu_sasrc.png: SRC page SMP STRT END PLAY / TUNE FINE LOOP LEV")
    r = e.run("cu_sasmpl", 2500, [(300, "press", "SMPL"), (1200, "press", "BD", 200)], snap=s0)
    t = [x for x in r["sysex"] if len(x) > 8 and x[4] == 0x04]
    print(f"  0x04s: {[x.hex() for x in t]}")
    ok = bool(t) and len(t[0]) == 43 and t[0][5] == 0x20 and [t[0][8 + 2 * i] for i in range(8)] == [0] * 8
    check("sa: the pad's 0x04: voice byte 0x20, P1..P8 0", ok, t[0].hex() if t else "none")
    if t:
        check("sa: its P9..P16 the kit's words 17..24", [t[0][8 + 2 * i] for i in range(8, 16)] == kit16(e, r["snap"][0])[8:16],
              t[0].hex())
        check("sa: its tag 0x29C1 (53 41)", t[0][40] << 7 | t[0][41] == SA_TAG, t[0][40:42].hex())
    print(f"  look at build/emu/{e.tag}/pc_cu_sasmpl.png: the SMPL page empty")


def t_saknobs(e):
    """SAMPLER's knobs on the SRC page (SMP STRT END PLAY / TUNE FINE LOOP LEV): STRT (B) turned up moves word 21 only;
    END (C) down from 120 moves word 22 only; TUNE (E) far down 4, far up 124 (-60 / +60); PLAY (D) a few turns up a zone's low end (9
    zones: 0 15 29 43 57 72 86 100 114), on to 114 (WAVE); LOOP (G) up then fully down 0 (OFF); END (C) up stops at 120; the texts in the PNGs."""
    s0 = nm(e, 43, 23)
    ev = [(300, "press", "SRC"), (900, "turn", "1:5", 10, 40)]
    r = e.run("cu_saknobs0", 2000, ev, snap=s0, usb=False)
    k0 = kit16(e, r["snap"][0])
    ev = [(300, "press", "SRC"), (900, "turn", "2:-5", 10, 40)]
    r = e.run("cu_saknobs0c", 2000, ev, snap=s0, usb=False)
    k0c = kit16(e, r["snap"][0])
    print(f"  words 17..24 after B up: {k0[8:16]}, after C down: {k0c[8:16]}")
    check("saknobs: STRT is knob B: B turned up moves word 21 (STRT) only",
          k0[12] > 0 and k0[8:12] + k0[13:16] == SA_WORDS[:2] + [k0[10]] + SA_WORDS[3:4] + SA_WORDS[5:], k0[8:16])
    check("saknobs: END is knob C: C turned down moves word 22 (END) only",
          k0c[13] < 120 and k0c[8:13] + k0c[14:16] == SA_WORDS[:2] + [k0c[10]] + SA_WORDS[3:5] + SA_WORDS[6:], k0c[8:16])
    ev = [(300, "press", "SRC"), (900, "turn", "4:-5", 60, 20), (2400, "turn", "3:5", 6, 40)]
    r = e.run("cu_saknobs1", 3500, ev, snap=s0, usb=False)
    k1 = kit16(e, r["snap"][0])
    ev = [(300, "press", "SRC"), (900, "turn", "4:5", 60, 20), (2400, "turn", "3:5", 60, 20), (3800, "turn", "6:5", 30, 20),
          (4600, "turn", "6:-5", 60, 20), (6000, "turn", "2:5", 30, 20)]
    r = e.run("cu_saknobs2", 7500, ev, snap=s0, usb=False)
    k2 = kit16(e, r["snap"][0])
    print(f"  words 17..24: {k1[8:16]} / {k2[8:16]}")
    check("saknobs: TUNE fully down = 4 (-60)", k1[8] == 4, k1[8:16])
    check("saknobs: PLAY a few turns up: a zone's low end past FWD (15 REV, 29 FLP, ..: 9 zones)",
          k1[11] in (15, 29, 43, 57, 72, 86, 100), k1[8:16])
    check("saknobs: TUNE fully up = 124 (+60)", k2[8] == 124, k2[8:16])
    check("saknobs: PLAY turned on = 114 (WAVE, the 9th zone's low end)", k2[11] == 114, k2[8:16])
    check("saknobs: LOOP up and fully down = 0 (OFF)", k2[14] == 0, k2[8:16])
    check("saknobs: END stops at 120", k2[13] == 120, k2[8:16])
    print(f"  look at build/emu/{e.tag}/pc_cu_saknobs1.png (TUNE -60, PLAY REV) and pc_cu_saknobs2.png (+60, WAVE, OFF)")


def t_sakeep(e):
    """0.5.0 (owner): choosing SAMPLER keeps word 19 (SMP) when the track came from a machine with a host sample there
    (DSP SAMPLE 45, SAMPLER itself), the other words 17..24 SAMPLER's defaults (64 64 . 0 0 120 0 100); from any other
    machine SMP is 0 (OFF): from BD PLASTIC, whose word 19 is stock's own sample, too."""
    keys = ["SRC", "SRC"] + ["DOWN"] * 25 + ["YES"]
    ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)]
    t = 500 + 500 * len(keys) + 1000
    ev += [(t, "press", "SRC"), (t + 500, "turn", "0:5", 6, 40), (t + 1500, "press", "SMPL"), (t + 2000, "turn", "7:-5", 10, 40)]
    r = rds = e.run("cu_sakeep_ds", t + 3500, ev, usb=False)
    s = r["snap"][0]
    m, k0 = e.peek(s, 0x8000EA00, 1)[0], kit16(e, s)
    check("sakeep: BD on DSP SAMPLE with SMP set and LEV moved", m == 45 and k0[10] != 0 and k0[15] != 100, (m, k0[8:16]))
    keys = ["SRC", "SRC", "UP", "UP", "YES"]
    r = e.run("cu_sakeep", 4500, [(500 + 500 * i, "press", x) for i, x in enumerate(keys)], snap=r["snap"], usb=False)
    s = r["snap"][0]
    m, k = e.peek(s, 0x8000EA00, 1)[0], kit16(e, s)
    print(f"  DSP SAMPLE words 17..24 {k0[8:16]} -> SAMPLER {k[8:16]}")
    check("sakeep: BD on SAMPLER (45 -> 43)", m == 43, m)
    check("sakeep: from DSP SAMPLE: SMP (word 19) kept", k[10] == k0[10], (k0[10], k[10]))
    want = SA_WORDS[:2] + [k0[10]] + SA_WORDS[3:]
    check(f"sakeep: the other words SAMPLER's defaults", k[8:16] == want, k[8:16])
    # SAMPLER -> SAMPLER (YES on its own entry): no machine change, so nothing is reset: SMP and the turned LEV stay
    s1 = nm(e, 43, 23)
    ev = [(300, "press", "SRC"), (800, "turn", "0:5", 6, 40), (1500, "turn", "7:-5", 10, 40)]
    keys = ["SRC", "SRC", "YES"]
    ev += [(2500 + 500 * i, "press", x) for i, x in enumerate(keys)]
    r = e.run("cu_sakeep_sa", 2500 + 500 * len(keys) + 1500, ev, snap=s1, usb=False)
    k = kit16(e, r["snap"][0])
    print(f"  SAMPLER -> SAMPLER {k[8:16]}")
    check("sakeep: SAMPLER -> SAMPLER: still 43, SMP kept (non-zero), nothing reset (LEV stays below 100)",
          e.peek(r["snap"][0], 0x8000EA00, 1)[0] == 43 and k[10] != 0 and k[8:15] == SA_WORDS[:2] + [k[10]] + SA_WORDS[3:7] and k[15] < 100,
          k[8:16])
    # (re-review F1) the machine list is the selected track's: a pad while it is open closes it, selects that track, no machine changes
    s2 = nm(e, 45, 25)
    keys = ["SRC", "SRC", "SD", "UP", "UP", "YES"]
    r = e.run("cu_sakeep_pad", 500 * len(keys) + 2000, [(500 + 500 * i, "press", x) for i, x in enumerate(keys)], snap=s2, usb=False)
    m = list(e.peek(r["snap"][0], 0x8000EA00, 2))
    check("sakeep: SD pressed with BD's list open: the list closed, BD still DSP SAMPLE, SD not SAMPLER", m[0] == 45 and m[1] != 43, m)
    # (re-review F1) the home_t guard: BD's list open (cu.home 45, frozen), cu.home_t poked to SD as if the list's
    # track were not the one cu.home came from: the choice of SAMPLER on BD must not keep SMP
    r = e.run("cu_sakeep_ht0", 2000, [(300, "press", "SRC"), (800, "press", "SRC")], snap=rds["snap"], usb=False)
    cu = json.load(open(os.path.join(e.out, "manifest.json")))["elek"]["symbols"]["rytm-0026-remote-ui:cu"]
    pk = e.pokes(r["snap"][0], {cu + 30: bytes([1])})   # cu.home_t (init p2m setups texts p1m dm dt mi_t preps dtick defs mi_tick home dfrom home_t)
    keys = ["UP", "UP", "YES"]
    r = e.run("cu_sakeep_ht", 500 * len(keys) + 2000, [(500 + 500 * i, "press", x) for i, x in enumerate(keys)],
              snap=r["snap"], usb=False, extra=pk)
    m, k = e.peek(r["snap"][0], 0x8000EA00, 1)[0], kit16(e, r["snap"][0])
    check("sakeep: home_t is another track: BD on SAMPLER, SMP 0 (not DSP SAMPLE's)", m == 43 and k[8:16] == SA_WORDS, (m, k[8:16]))
    r = e.run("cu_sakeep_st0", 2600, [(300, "press", "SMPL"), (800, "turn", "3:5", 10, 40), (1800, "press", "YES")],
              usb=False)   # (stock SMPL: TUN FIN BR SMP; its sample list, confirmed)
    k0 = kit16(e, r["snap"][0])
    check("sakeep: BD PLASTIC with stock's SMP (word 19) turned up", k0[10] != 0, k0[8:16])
    keys = ["SRC", "SRC"] + ["DOWN"] * 23 + ["YES"]
    r = e.run("cu_sakeep_st", 500 * len(keys) + 1500, [(500 + 500 * i, "press", x) for i, x in enumerate(keys)],
              snap=r["snap"], usb=False)
    s = r["snap"][0]
    m, k = e.peek(s, 0x8000EA00, 1)[0], kit16(e, s)
    print(f"  BD PLASTIC (SMP turned) -> SAMPLER {k[8:16]}")
    check("sakeep: from BD PLASTIC (stock's sample in word 19): BD on SAMPLER, SMP 0 (OFF), the defaults",
          m == 43 and k[8:16] == SA_WORDS, (m, k[8:16]))


def t_sadsps(e):
    """DSP SAMPLE unchanged by 0.5.0: its pad's 04 has voice byte 0x20 and the tag 0 (00 00), SAMPLER's 0x29C1 never;
    its TUN record 39 keeps 40..88 and SMP 441 0..0x7fe0."""
    s0 = nm(e, 45, 25)
    r = e.run("cu_sadsps", 2500, [(300, "press", "SMPL"), (1200, "press", "BD", 200)], snap=s0)
    t = [x for x in r["sysex"] if len(x) > 8 and x[4] == 0x04]
    s = r["snap"][0]
    print(f"  0x04s: {[x.hex() for x in t]}")
    check("sadsps: DSP SAMPLE's 04: voice byte 0x20, tag 00 00", bool(t) and len(t[0]) == 43 and t[0][5] == 0x20 and t[0][40:42] == b"\0\0",
          t[0].hex() if t else "none")
    rng = [(u32(e, s, rec(x) + 8), u32(e, s, rec(x) + 12)) for x in (39, 441)]
    check("sadsps: TUN 39 40..88, SMP 441 0..0x7fe0", rng == [(40 << 8, 88 << 8), (0, 0x7fe0)], [(hex(a), hex(b)) for a, b in rng])


def t_sarestore(e):
    """SAMPLER -> MULTISAMPLE (9 downs, past 44..51): the shared records are MULTISAMPLE's again, TUNE's record 438 back to
    0..127 (8.8 0..0x7f00), FINE and STRT too, its SMPL labels."""
    s0 = nm(e, 43, 23)
    keys = ["SRC", "SRC"] + ["DOWN"] * 9 + ["YES"]
    ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)] + [(500 + 500 * len(keys) + 500, "press", "SMPL")]
    r = e.run("cu_sarestore", 500 + 500 * len(keys) + 2000, ev, snap=s0, usb=False)
    s = r["snap"][0]
    m = e.peek(s, 0x8000EA00, 1)[0]
    rng = [(u32(e, s, rec(x) + 8), u32(e, s, rec(x) + 12)) for x in (438, 457, 458)]
    got = [label(e, s, x) for x in P2]
    check("sarestore: BD on MULTISAMPLE (43 -> 52)", m == 52, m)
    check("sarestore: TUNE FINE STRT (438 457 458) 0..127 again (SAMPLER's TUNE 4..124 gone; the chord knobs are 0029's stepped ranges)",
          all(x == (0, 0x7f00) for x in rng), [(hex(a), hex(b)) for a, b in rng])
    check("sarestore: MULTISAMPLE's SMPL labels", got == P2_LABELS, got)


def t_sasound(e):
    """SAMPLER chosen in the SOUND menu (FUNC + FLTR, MACHINE: 23 RIGHTs from BD PLASTIC, the list's order) after BD's LEV was
    turned down: words 17..24 SAMPLER's defaults 64 64 0 0 0 120 0 100 (0021's us_step path, cu_steps r < -12)."""
    r = e.run("cu_sasound0", 2000, [(300, "press", "SMPL"), (800, "turn", "7:-5", 10, 40)], usb=False)
    k0 = kit16(e, r["snap"][0])
    check("sasound: BD PLASTIC's LEV moved", k0[15] != 100, k0[8:16])
    ev = [(300, "press", "FUNC", 500), (400, "press", "FLTR")] + [(1000 + 300 * i, "press", "RIGHT") for i in range(23)]
    t = 1000 + 300 * 23 + 300
    ev += [(t, "press", "NO")]
    r = e.run("cu_sasound", t + 1500, ev, snap=r["snap"], usb=False)
    s = r["snap"][0]
    m, k = e.peek(s, 0x8000EA00, 1)[0], kit16(e, s)
    print(f"  words 17..24 {k0[8:16]} -> {k[8:16]}")
    check("sasound: BD on SAMPLER by the SOUND menu", m == 43, m)
    check(f"sasound: words 17..24 SAMPLER's defaults {SA_WORDS}", k[8:16] == SA_WORDS, k[8:16])


TESTS = dict(sa=t_sa, saknobs=t_saknobs, sakeep=t_sakeep, sadsps=t_sadsps, sarestore=t_sarestore, sasound=t_sasound, fm=t_fm, fmtext=t_fmtext, ms=t_ms, msknobs=t_msknobs, back=t_back, wt=t_wt, gr=t_gr, swap=t_swap, li=t_li,
             cp=t_cp)


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
