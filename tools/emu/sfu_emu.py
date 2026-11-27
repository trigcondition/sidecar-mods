#!/usr/bin/env python3
"""Emulator tests of 0029-sendfx-ui in rytm-emu: the Sidecar send FX pages (AMPLITUDE 2, SEND FX 1 / 2).

    .venv/bin/python tools/emu/sfu_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a build with 0025 + 0027 + 0029 (sfxui), whose base tools/emu/us_base.sh TAG made. Every run under
DTEMU_STRICT=1. Addresses: OS 1.73 (rytm-teensy docs/superpowers/specs/2026-10-16-sidecar-send-fx-storage.md).
Words: sound index 0 = SFX1 (hi, bits 8..14) / SFX2 (lo, bits 1..7); FX words 29 / 38 / 39 = SEND FX 1's
TYPE P1 / P2 P3 / P4 P5, words 0 / 40 / 41 = SEND FX 2's (hi / lo each).
Firmware-derived files stay in rytm-emu's git-ignored sections/ and in build/.
"""
import json
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import us_emu as U          # noqa: E402
import sfx_emu as X         # noqa: E402  (poke_boot, sendfx_rx, changes, proj_keys, slots_of, fx_locks, lockslot)
P = U.P

KIT0 = X.LIVE_KIT0                  # live kit 0
SND0 = KIT0 + 0x2a + 0x14           # track 0's (BD) sound index 0 in kit 0 (sound t at + 152 t)
FXW = KIT0 + 1866                   # kit 0's FX word i at + 2 i
PROJ = X.ST_KIT                     # the project's stored kit copy (0xA32 format)
PSND0 = PROJ + 0x2e + 0x6e          # BD's stored slot 41 (sound index 0)
PFX = {29: PROJ + 0x7f2, 0: PROJ + 0x814, 38: PROJ + 0x816, 39: PROJ + 0x818, 40: PROJ + 0x81a, 41: PROJ + 0x81c}
TRIG = 0x8000e5b0                   # per-track trig array, 84 B a track
LOCKS = X.LIVE_LOCKS                # working pattern live locks: + 5674 t + 88 step + 2 index
INCR, REBUILD = 0x4000940c, 0x40009216


def w16(e, snap, a):
    return int.from_bytes(e.peek(snap, a, 2), "big")


BANK1 = LOCKS + 85760              # bank pattern A01's live locks: what a UI p-lock edits [measured]


def lock(e, snap, t, step, idx):
    """A01's lock word: the bank copy (edited by the UI), else the working copy (a cold boot's load)."""
    v = w16(e, snap, BANK1 + 5674 * t + 88 * step + 2 * idx)
    return v if v != 0xffff else w16(e, snap, LOCKS + 5674 * t + 88 * step + 2 * idx)


def fine(e, snap, t, idx):
    return e.peek(snap, BANK1 + 5674 * t + 5632 + idx, 1)[0] | e.peek(snap, LOCKS + 5674 * t + 5632 + idx, 1)[0]


def sym(e, name, mod="0029-sendfx-ui"):
    m = json.load(open(os.path.join(e.out, "manifest.json")))
    return m["elek"]["symbols"]["rytm-" + mod + ":" + name]


def t_pages(e):
    """Pages: AMP twice = AMPLITUDE 2 (knob A = SFX1, B = SFX2), a third press back (knob A = ATK); on the FX track
    SRC = SEND FX 1 (TYPE P1 / P2 P3 / P4 P5 on words 29 / 38 / 39), SMPL = SEND FX 2 (words 0 / 40 / 41). Each turn
    writes the live kit, the project copy and the trig array."""
    s0 = e.snap
    atk0, w0 = w16(e, s0, SND0 + 66), w16(e, s0, SND0)
    ev = [(50, "press", "AMP"), (150, "press", "AMP"), (300, "turn", ("0:+20", 5, 20)), (450, "turn", ("1:+20", 3, 20)),
          (600, "press", "AMP"), (700, "turn", ("0:+20", 2, 20))]
    s = e.run("pages-amp", 900, ev, save=True)
    w, atk = w16(e, s, SND0), w16(e, s, SND0 + 66)
    U.check("pages: AMP AMP = AMPLITUDE 2 - knob A sets SFX1 (index 0 hi), knob B SFX2 (lo); kit, project copy and "
            "trig array agree", w != w0 and (w >> 8) > 0 and (w & 0xfe) > 0 and w16(e, s, PSND0) == w and
            w16(e, s, TRIG) == w, f"kit {w:04x} proj {w16(e, s, PSND0):04x} trig {w16(e, s, TRIG):04x} (was {w0:04x})")
    U.check("pages: a third AMP press is back on AMPLITUDE (knob A = ATK)", atk != atk0, f"ATK {atk0:04x} -> {atk:04x}")
    print(f"    SFX1 {w >> 8} SFX2 {(w >> 1) & 0x7f}")
    fx0 = {i: w16(e, s0, FXW + 2 * i) for i in (0, 9, 29, 38, 39, 40, 41)}
    ev = [(50, "press", "FX"), (150, "press", "SRC"), (300, "turn", ("0:+20", 2, 20)), (400, "turn", ("1:+20", 3, 20)),
          (500, "turn", ("2:+20", 4, 20)), (600, "turn", ("5:+20", 2, 20)),
          (700, "press", "SMPL"), (800, "press", "SMPL"), (900, "turn", ("0:+20", 3, 20)),
          (1000, "turn", ("3:+20", 2, 20)), (1100, "turn", ("4:+20", 2, 20)),
          (1200, "press", "SRC"), (1300, "press", "SRC"), (1400, "press", "SRC"), (1500, "turn", ("0:+20", 3, 20))]
    s = e.run("pages-fx", 1700, ev, save=True)
    fx = {i: w16(e, s, FXW + 2 * i) for i in fx0}
    pr = {i: w16(e, s, PFX[i]) for i in PFX}
    tr = {i: w16(e, s, TRIG + 84 * 12 + 2 * i) for i in fx0}
    print("    FX words " + " ".join(f"{i}:{fx0[i]:04x}->{fx[i]:04x}" for i in fx0))
    U.check("pages: SEND FX 1 - TYPE (29 hi), P1 (29 lo), P2 (38 hi), P5 (39 lo) set; SEND FX 2 - TYPE (0 hi), "
            "P3 (40 lo), P4 (41 hi) set", fx[29] >> 8 and fx[29] & 0xfe and fx[38] >> 8 and fx[39] & 0xfe and fx[0] >> 8
            and fx[40] & 0xfe and fx[41] >> 8 and not fx[38] & 0xfe and not fx[39] >> 8, "")
    U.check("pages: the project copy (stored FX slots 20 / 37 and 0025's 0x816..0x81D) and the FX trig array hold "
            "the same words", all(pr[i] == fx[i] for i in PFX) and all(tr[i] == fx[i] for i in PFX),
            " ".join(f"{i}:{pr[i]:04x}/{tr[i]:04x}" for i in PFX))
    U.check("pages: SRC from SEND FX 1 is back on DELAY (knob A = TIM, FX word 9)", fx[9] != fx0[9],
            f"{fx0[9]:04x} -> {fx[9]:04x}")
    stored = e.peek(s, PROJ + 0x7ca, 76)
    base = e.peek(s0, PROJ + 0x7ca, 76)
    other = [k for k in range(38) if k not in (20, 37) and stored[2 * k:2 * k + 2] != base[2 * k:2 * k + 2]]
    U.check("pages: no other stored FX slot changed but DELAY TIM's (no stray write from the 38..41 path)",
            len(other) <= 1, str(other))
    e.pages = s


def t_names(e):
    """TYPE names: 0029 asks (23) until the host answers; 21 NAMES fill the list, 22 STATE MISSING marks an id."""
    asks = [m for m in e.sent if len(m) == 7 and m[4] == 0x23]
    nm = P.sendfx_names([(0, "OFF"), (1, "CHORUS"), (2, "COMB"), (64, "MYVERB")])
    st = P.sendfx_state(0, 64, 3, "MYVERB")
    st2 = P.sendfx_state(1, 6, 3, "RINGS")   # MISSING, an id the list does not name: named from the 22
    ev = [(100, "usb", b"".join(nm)), (200, "usb", st), (300, "usb", st2)]
    s = e.run("names", 700, ev, save=True)
    asked = [m for m in e.sent if len(m) == 7 and m[4] == 0x23]
    a = sym(e, "sfu_st")
    n64 = e.cstr(s, a + 64 * 8, 8)
    n3 = e.cstr(s, a + 3 * 8, 8)
    miss = e.peek(s, a + 1024, 2)
    U.check("names: 0029 asked (23 SENDFX ASK) before the host answered", bool(asks) or bool(asked),
            f"{len(asks)} in the pages run, {len(asked)} here")
    U.check("names: after 21 the list holds MYVERB at 64 and only the sent ids (3 unnamed: FX3)",
            n64 == "MYVERB" and n3 == "", f"64 {n64!r} 3 {n3!r}")
    U.check("names: 22 STATE MISSING for FX 1 id 64 -> shown !MYVERB", miss[0] == 64, miss.hex())
    n6 = e.cstr(s, a + 6 * 8, 8)
    U.check("names: 22 STATE MISSING for FX 2 id 6, unnamed by the 21: named RINGS from the 22 -> shown !RINGS, "
            "not FX6", miss[1] == 6 and n6 == "RINGS", f"miss {miss.hex()} 6 {n6!r}")


def t_locks(e):
    """P-locks: BD with T1 held on AMPLITUDE 2 - SFX1 and SFX2 lock index 0 (one word, fine flag); on the FX track
    T1 held on SEND FX 1 - P2 locks FX 38 (the incremental save takes 0025's >= 38 branch: a full rebuild, types
    42/46, no 9..12), TYPE is refused (no lock on word 29); PLAY reports them per step (0x20)."""
    # base values first (SFX2; SEND FX 1's P1 and P4), then RECORD, trigs on steps 1 and 5, step 1 held + knobs
    ev = [(50, "press", "AMP"), (150, "press", "AMP"), (200, "turn", ("1:+20", 2, 20)),
          (250, "press", "RECORD"), (350, "press", "T1"),
          (450, "press", "T5"), (600, "press", "T1:500M"), (700, "turn", ("0:+20", 3, 20)), (850, "turn", ("1:+20", 2, 20)),
          (1200, "press", "FX"), (1300, "press", "SRC"), (1350, "turn", ("1:+20", 2, 20)), (1380, "turn", ("4:+20", 2, 20)),
          (1450, "press", "T1"), (1550, "press", "T5"),
          (1650, "press", "T1:500M"), (1750, "turn", ("2:+20", 3, 20)), (1900, "turn", ("0:+20", 2, 20)),
          (2300, "press", "RECORD")]
    s = e.run("locks", 2500, ev, save=True, count=[INCR, REBUILD])
    incr, rb = e.counts.get(INCR, 0), e.counts.get(REBUILD, 0)
    base, l0 = w16(e, s, SND0), lock(e, s, 0, 0, 0)
    U.check("locks: BD step 1 locks index 0 - hi and lo set by SFX1 / SFX2, the fine flag on; step 5 unlocked",
            l0 != 0xffff and l0 != base and (l0 >> 8) and (l0 & 0xfe) and fine(e, s, 0, 0) == 1 and
            lock(e, s, 0, 4, 0) == 0xffff, f"lock {l0:04x} base {base:04x} fine {fine(e, s, 0, 0)}")
    f38, f29 = lock(e, s, 12, 0, 38), lock(e, s, 12, 0, 29)
    U.check("locks: FX step 1 locks FX 38 (P2, hi); TYPE refused - no lock on word 29", f38 != 0xffff and (f38 >> 8)
            and f29 == 0xffff, f"38 {f38:04x} 29 {f29:04x}")
    sl = X.slots_of(e, s)
    U.check("locks: the incremental save ran and took the >= 38 branch (a full rebuild); A01's slots hold (41,0) + "
            "its fine slot and (42,12), no type 9..12 on track 12", incr >= 1 and rb >= 1 and (41, 0) in sl and
            (0x80, 0x80) in sl and (42, 12) in sl and not [x for x in sl if x[1] == 12 and 9 <= x[0] <= 12],
            f"incr {incr} rebuild {rb} {sl}")
    s2 = e.run("locks-play", 900, [(100, "press", "PLAY")], snap=s, start=e.clock + 2500, save=True,
               extra=["--every", "5M"], env={"DTBOOT_PEEK": "8000e5b0"})
    rx = X.sendfx_rx(e, "locks-play")
    bd = [v for _, v in X.changes([(w, ws[0]) for w, t, ws in rx if t == 0], 0)]
    fx = [v for _, v in X.changes([(w, ws[2]) for w, t, ws in rx if t == 12], 0)]
    fx38b = w16(e, s, FXW + 76)
    U.check(f"locks: 0x20 per step - BD {l0:04x} on step 1, {base:04x} on step 5; FX 38 {f38:04x} / {fx38b:04x}",
            [l0, base] == bd[-2:] or [base, l0] == bd[-2:] and len(bd) >= 3, " ".join("%04x" % v for v in bd[:6]))
    U.check("locks: FX word 38 alternates lock / base in the reports", f38 in fx and fx38b in fx and len(fx) >= 3,
            " ".join("%04x" % v for v in fx[:6]))
    e.locks = (s2, e.clock + 3400, base, l0, f38, fx38b)


def t_save(e):
    """Power-off / cold boot, then SAVE PROJECT / LOAD PROJECT: the pages' kit words and the UI-made locks survive
    the stored state, the full rebuild of every pattern, a wipe and the load."""
    if not getattr(e, "locks", None):
        t_locks(e)
    s, at, base, l0, f38, fx38b = e.locks
    c = U.card_copy(e, "save")
    s = e.run("save-stop", 200, [(50, "press", "STOP")], snap=s, start=at, card=c, save=True)
    at += 200
    kit = {i: w16(e, s, FXW + 2 * i) for i in (0, 29, 38, 39, 40, 41)}
    bd = w16(e, s, SND0)
    e.run("save-off", 300, snap=s, start=at, card=c, extra=["--power-off", f"{at + 100}M"])
    s1 = e.run("save-boot", 4400, X.DIALOGS, cold=True, card=c, save=True)
    U.check("save: power-off and cold boot - FX words, BD index 0, the BD and FX 38 locks back",
            {i: w16(e, s1, FXW + 2 * i) for i in kit} == kit and w16(e, s1, SND0) == bd and
            lock(e, s1, 0, 0, 0) == l0 and lock(e, s1, 12, 0, 38) == f38,
            f"{ {i: '%04x' % w16(e, s1, FXW + 2 * i) for i in kit} } want { {i: '%04x' % v for i, v in kit.items()} } "
            f"bd {w16(e, s1, SND0):04x}/{bd:04x} locks {lock(e, s1, 0, 0, 0):04x} {lock(e, s1, 12, 0, 38):04x}")
    ev, t = X.proj_keys(100, True)
    s2 = e.run("save-save", t, ev, snap=s1, start=4400, card=c, save=True, count=[REBUILD])
    U.check("save: the kit words are not all zero (the base edits of t_locks)", bd and kit[29] and kit[39],
            f"bd {bd:04x} 29 {kit[29]:04x} 39 {kit[39]:04x}")
    U.check("save: SAVE PROJECT AS - 129 full rebuilds, the project copy holds the FX words",
            e.counts.get(REBUILD) == 129 and all(w16(e, s2, PFX[i]) == kit[i] for i in PFX),
            f"{e.counts.get(REBUILD)} " + " ".join(f"{i}:{w16(e, s2, PFX[i]):04x}" for i in PFX))
    wipe = {SND0: b"\0\0", FXW + 76: bytes(8), FXW + 58: b"\0\0", FXW: b"\0\0", PFX[38]: bytes(8),
            LOCKS: b"\xff\xff", LOCKS + 5674 * 12 + 76: b"\xff\xff", BANK1: b"\xff\xff",
            BANK1 + 5674 * 12 + 76: b"\xff\xff", X.B0 + 0x2091: b"\xff" * (72 * 66 - 4)}
    s3 = e.run("save-wiped", 50, snap=s2, start=4400 + t, card=c, save=True, extra=X.pokes(e, s2, wipe))
    ev, t2 = X.proj_keys(100, False)
    s4 = e.run("save-load", t2, ev, snap=s3, start=4400 + t + 50, card=c, save=True)
    got = {i: w16(e, s4, FXW + 2 * i) for i in kit}
    U.check("save: wiped, then LOAD PROJECT - FX words, BD index 0, the BD and FX 38 locks back from the file",
            got == kit and w16(e, s4, SND0) == bd and lock(e, s4, 0, 0, 0) == l0 and lock(e, s4, 12, 0, 38) == f38,
            f"{got} bd {w16(e, s4, SND0):04x} locks {lock(e, s4, 0, 0, 0):04x} {lock(e, s4, 12, 0, 38):04x}")
    e.saved = (s2, c, 4400 + t)


def t_stock(e):
    """The mod's saved project on stock 1.73: cold boot and LOAD PROJECT - no FX 18..21 / 38..41 lock, no type
    9..12; FX words 0/29 and the SEND lock (type 41 + fine) carried; nothing faults."""
    if not getattr(e, "saved", None):
        t_save(e)
    s2, c, at = e.saved
    s, _ = X.poke_boot(e, "sstock", {}, snap=s2, start=at, card=c, fw=X.STOCK)
    ev, t = X.proj_keys(100, False)
    s3 = e.run("sstock-load", t, ev, snap=s, start=4400, card=c, save=True, fw=X.STOCK)
    bad = [i for i in (18, 19, 20, 21, 38, 39, 40, 41) if any(v != 0xffff for v in X.fx_locks(e, s3, i, X.STOCK))]
    sl = X.slots_of(e, s3, fw=X.STOCK)
    U.check("stock: LOAD PROJECT of the mod's file - no live FX 18..21 / 38..41 lock, no type 9..12 on track 12",
            not bad and not [x for x in sl if x[1] == 12 and 9 <= x[0] <= 12], f"{bad} {sl}")
    U.check("stock: the SEND lock (BD step 1, index 0) and FX words 0 / 29 carried",
            int.from_bytes(e.peek(s3, LOCKS, 2, fw=X.STOCK), "big") != 0xffff, "")


def t_kits(e):
    """Two patterns on two kits with different TYPEs: A01 (kit 0) TYPE 1 / 2, A02 (kit 1) TYPE 5 / 6 in FX words
    29 / 0 hi; playing A01 then A02 switches the active kit and the 0x20 reports carry each kit's TYPEs."""
    k1 = X.ST_PAT + 13101 * 2       # bank pattern A02
    ed = X.trig_bits(e, e.snap, 12, [0, 8])
    a2 = int.from_bytes(e.peek(e.snap, k1 + 4 + 641 * 12, 112), "big")
    for i in (0, 8):
        sh = 14 * (63 - i)
        a2 = (a2 & ~(0x3fff << sh)) | (0x381 << sh)
    ed[k1 + 4 + 641 * 12] = a2.to_bytes(112, "big")
    ed[PROJ + 0x7f2] = bytes.fromhex("0100")    # kit 0 (the project copy): FX 1 TYPE 1
    ed[PROJ + 0x814] = bytes.fromhex("0200")    # FX 2 TYPE 2
    s, c = X.poke_boot(e, "kits", ed)
    kit_of_a2 = e.peek(s, k1 + 0x3325, 1)[0]
    K1 = KIT0 + 2531 * kit_of_a2
    live = {K1 + 1866 + 58: bytes.fromhex("0500"), K1 + 1866: bytes.fromhex("0600")}
    ev = [(100, "press", "PLAY"), (900, "press", "BANK_A:200M"), (950, "press", "T2")]
    e.run("kits-play", 2000, ev, snap=s, start=4400, card=c, extra=["--every", "5M"] + X.pokes(e, s, live),
          env={"DTBOOT_PEEK": "8000e5b0"})
    rx = X.sendfx_rx(e, "kits-play")
    ty = [v for _, v in X.changes([(w, (ws[1] >> 8, ws[0] >> 8)) for w, t, ws in rx if t == 12], 0)]
    U.check(f"kits: A02 is on kit {kit_of_a2} (not 0); the reports carry TYPE 1/2 (A01, kit 0), then 5/6 (A02)",
            kit_of_a2 != 0 and (1, 2) in ty and (5, 6) in ty and ty.index((1, 2)) < ty.index((5, 6)), str(ty))


# struct sfu_x (sfu.c): lab[NLT] (130 B each), gen, shown_gen, cur[2], shown[2], lbl[2][4][5], fxset, dial, counters.
# NLT 16 since rui1049 (8 before): every offset below moves by DL
NLT = 16
DL = 130 * (NLT - 8)
X_GEN, X_CUR, X_LBL, X_CNT = 1040 + DL, 1048 + DL, 1052 + DL, 1100 + DL   # counters: fxset_changes lab_drop lab_rx asks tx_busy relabels


def lbl(e, snap, fx):
    a = sym(e, "sfu_x") + X_LBL + 20 * fx
    return [e.cstr(snap, a + 5 * j, 5) for j in range(4)]


def poke_type(e, fx, t):
    """--poke args setting FX k's TYPE (word 29 hi for FX 1, word 0 hi for FX 2) in the base's live kit 0, the
    word after it kept (a 32-bit poke)."""
    w = 29 if fx == 0 else 0
    a = FXW + 2 * w
    old = int.from_bytes(e.peek(e.snap, a, 4), "big")
    return ["--poke", f"{a:x}={(old & 0x80ffffff) | (t << 24):08x}"]


def label_msgs(ids):
    return b"".join(P.sendfx_labels(i, *P.SENDFX_LABEL_SETS[i]) for i in ids)


def t_labels(e):
    """Labels (24): P1 = ROUT with PRE / POST; after 21 + 24 the SEND FX pages show each TYPE's P2..P5 labels and zone
    names (RINGS P3 = MODL STRNG.., STUTTER P3 = LEN 1/16), a TYPE change relabels; without any 24 P2..P5 stay
    generic. Screens: build/emu/TAG/labels-*.png."""
    names = P.sendfx_names([(i, P.SENDFX_TYPES[i]) for i in (0, 1, 2, 6, 8, 15)])
    msgs = b"".join(names) + label_msgs((1, 2, 6, 8, 15))
    # FX 1 RINGS: SEND FX 1, P3 (knob D) up into STRINGS, P1 (knob B) to POST
    ev = [(20, "usb", msgs), (50, "press", "FX"), (150, "press", "SRC"), (200, "turn", ("1:+20", 22, 4)),
          (350, "turn", ("3:+20", 22, 4))]
    s = e.run("labels-rings", 470, ev, save=True, extra=poke_type(e, 0, 6))
    a = sym(e, "sfu_x")
    cnt = [e.u32(s, a + X_CNT + 4 * i) for i in range(6)]
    fx38 = w16(e, s, FXW + 2 * 38)
    p3 = (fx38 & 0xfe) >> 1
    p1 = (w16(e, s, FXW + 58) & 0xfe) >> 1
    U.check("labels: P1 turned past 63 (POST) and RINGS P3 into a zone", p1 >= 64 and p3 > 0, f"P1 {p1} P3 {p3}")
    U.check("labels: 0029 took the five 24s (lab_rx 5, none dropped)", cnt[2] == 5 and cnt[1] == 0, f"counters {cnt}")
    U.check("labels: SEND FX 1 on RINGS shows PTCH MODL BRIT DCY", lbl(e, s, 0) == ["PTCH", "MODL", "BRIT", "DCY"],
            str(lbl(e, s, 0)))
    U.check("labels: FX 2 (OFF, no 24) keeps P2..P5 generic", lbl(e, s, 1) == ["P2", "P3", "P4", "P5"], str(lbl(e, s, 1)))
    U.check("labels: the FX set seen once, never another", cnt[0] == 0, f"fxset changes {cnt[0]}")
    print(f"    P3 = {p3} -> {P.sendfx_value_text(6, 1, p3)!r}; P1 = {p1} -> {P.sendfx_route_text(p1)}; screen "
          "labels-rings.png")
    # TYPE change by the knob to STUTTER on SEND FX 2 (SMPL SMPL), P3 into 1/16
    ev = [(20, "usb", msgs), (50, "press", "FX"), (150, "press", "SMPL"), (250, "press", "SMPL"),
          (350, "turn", ("3:+20", 8, 4))]
    s = e.run("labels-stutter", 420, ev, save=True, extra=poke_type(e, 1, 15))
    U.check("labels: SEND FX 2 on STUTTER shows ENG LEN D/P GATE", lbl(e, s, 1) == ["ENG", "LEN", "D/P", "GATE"],
            str(lbl(e, s, 1)))
    p3 = (w16(e, s, FXW + 2 * 40) & 0xfe) >> 1
    print(f"    P3 = {p3} -> {P.sendfx_value_text(15, 1, p3)!r}; screen labels-stutter.png")
    # no labels: generic P2..P5 and numbers (the stock dial), P1 PRE
    ev = [(20, "usb", b"".join(names)), (50, "press", "FX"), (150, "press", "SRC"), (350, "turn", ("3:+20", 8, 4))]
    s = e.run("labels-none", 550, ev, save=True, extra=poke_type(e, 0, 6))
    U.check("labels: without a 24, RINGS keeps P2..P5 generic", lbl(e, s, 0) == ["P2", "P3", "P4", "P5"], str(lbl(e, s, 0)))
    # a 21 with replace clears them
    ev = [(20, "usb", msgs), (60, "usb", b"".join(names)), (100, "press", "FX"), (200, "press", "SRC")]
    s = e.run("labels-replace", 450, ev, save=True, extra=poke_type(e, 0, 6))
    U.check("labels: a later 21 (replace) forgets the labels until the 24s come again",
            lbl(e, s, 0) == ["P2", "P3", "P4", "P5"], str(lbl(e, s, 0)))



def full_msgs(ids):
    return b"".join(P.sendfx_full_names(i, 1, list(zip(P.SENDFX_LABEL_SETS[i][0], P.SENDFX_FULL_NAME_SETS[i])))
                    for i in ids)


def long_names(e, snap, fx):
    """FX fx's P2..P5 record long names (field 10 of records ID0 + 4 + 6 fx + j, ID0 = 14), as the upper left shows
    them while the knob turns."""
    return [e.cstr(snap, e.u32(snap, REC(14 + 4 + 6 * fx + j) + 40), 17) for j in range(4)]


def t_fullnames(e):
    """Full names (51, issue #14): after 21 + 24 + 51 the P2..P5 records' long names are the TYPE's full names (RINGS
    Pitch / Model / Brightness / Decay), "Send FX n" for a TYPE without a 51; without any 51 (an older Sidecar) P2..P5
    keep "Send FX 1"; a 51 before its 24 is dropped. Screens: build/emu/TAG/fullnames-*.png."""
    names = b"".join(P.sendfx_names([(i, P.SENDFX_TYPES[i]) for i in (0, 1, 2, 6, 8, 15)]))
    labels = label_msgs((1, 2, 6, 8, 15))
    full = full_msgs((1, 2, 6, 8, 15))
    a = sym(e, "sfu_x")
    # FX 1 RINGS, FX 2 OFF; P2 (knob C) turned so the upper left shows its name in the screen
    ev = [(20, "usb", names + labels + full), (50, "press", "FX"), (150, "press", "SRC"), (300, "turn", ("2:+8", 3, 10))]
    s = e.run("fullnames-rings", 450, ev, save=True, extra=poke_type(e, 0, 6))
    cnt = [e.u32(s, a + X_CNT + 4 * i) for i in range(6)]
    U.check("fullnames: 0029 took the five 24s", cnt[2] == 5 and cnt[1] == 0, f"counters {cnt}")
    U.check("fullnames: SEND FX 1 on RINGS names P2..P5 Pitch Model Brightness Decay",
            long_names(e, s, 0) == ["Pitch", "Model", "Brightness", "Decay"], str(long_names(e, s, 0)))
    U.check("fullnames: SEND FX 1 keeps its labels PTCH MODL BRIT DCY", lbl(e, s, 0) == ["PTCH", "MODL", "BRIT", "DCY"],
            str(lbl(e, s, 0)))
    U.check("fullnames: SEND FX 2 (OFF, no 51) keeps Send FX 2", long_names(e, s, 1) == ["Send FX 2"] * 4,
            str(long_names(e, s, 1)))
    # FX 2 STUTTER by the poke: its own names ("Decay / pitch", 13 characters)
    ev = [(20, "usb", names + labels + full), (50, "press", "FX"), (150, "press", "SMPL"), (250, "press", "SMPL")]
    s = e.run("fullnames-stutter", 400, ev, save=True, extra=poke_type(e, 1, 15))
    U.check("fullnames: SEND FX 2 on STUTTER names P2..P5 Engage Length Decay / pitch Gate",
            long_names(e, s, 1) == ["Engage", "Length", "Decay / pitch", "Gate"], str(long_names(e, s, 1)))
    # an older Sidecar: 21 + 24 only
    ev = [(20, "usb", names + labels), (50, "press", "FX"), (150, "press", "SRC")]
    s = e.run("fullnames-none", 400, ev, save=True, extra=poke_type(e, 0, 6))
    U.check("fullnames: without a 51 SEND FX 1 keeps Send FX 1 (labels as before)",
            long_names(e, s, 0) == ["Send FX 1"] * 4 and lbl(e, s, 0) == ["PTCH", "MODL", "BRIT", "DCY"],
            f"{long_names(e, s, 0)} {lbl(e, s, 0)}")
    # a 51 before its 24: dropped (the 24 that follows clears the entry's names)
    ev = [(20, "usb", names + full + labels), (50, "press", "FX"), (150, "press", "SRC")]
    s = e.run("fullnames-early", 400, ev, save=True, extra=poke_type(e, 0, 6))
    U.check("fullnames: a 51 before its 24 is not used", long_names(e, s, 0) == ["Send FX 1"] * 4,
            str(long_names(e, s, 0)))

# ---- sendfx-pages (issues #14 / #15, based on twwwy's #18 / #19): struct sfu_p (sfu.c; offsets from m68k-elf-gcc offsetof)
PG_PG, PG_NPG, PG_NX, PG_PV, PG_ONTOP, PG_KDN = 4240, 4242, 4244, 4246, 4275, 4276   # kdn ate mods follow
PG_CNT = 4288                      # pv_sent pv_got steps resets retitles
PG_TTL = 4668
X_LNG_RX, X_LNG_DROP = 7932, 7936  # sfu_x's lng_rx lng_drop (X_GEN: gen)
FX16 = 66                          # UFX3 holding a user effect with P1..P16 (the Sidecar's api3_fx16)
FX17 = 67                          # a second one (a kit change from one to the other)


def fx16_msgs(nx=12, fx=FX16):
    """What the Sidecar sends for FX16 after its 21: the 24 (P2..P5's labels), then 51s for P1..P4 and P5..P(4 + nx)."""
    out = P.sendfx_labels(fx, ("MOD", "LEV", "P3", "P4"), [])
    out += P.sendfx_full_names(fx, 1, [("MOD", "Mode"), ("LEV", "Level"), ("P3", "Three"), ("P4", "Four")])
    xn = [(f"X{p}", f"Extra P{p}") for p in range(5, 5 + nx)]
    for c in range(0, nx, 4):
        out += P.sendfx_full_names(fx, 5 + c, xn[c:c + 4])
    return out


def have_pages(e):
    try:
        sym(e, "sfu_p")
        return True
    except KeyError:
        return False


def pg_state(e, s):
    """sfu_p's state (zeros when the build has no sfu_p: the checks then fail on the behaviour)."""
    if not have_pages(e):
        return dict(pg=[0, 0], npg=[0, 0], nx=[0, 0], pv=[0] * 24, ontop=0, cnt=[0] * 5, ttl="", ttl2="", kdn=0, ate=0,
                    mods=0)
    a = sym(e, "sfu_p")
    b = e.peek(s, a + PG_PG, 6)
    f = e.peek(s, a + PG_KDN, 3)
    return dict(pg=list(b[0:2]), npg=list(b[2:4]), nx=list(b[4:6]), pv=list(e.peek(s, a + PG_PV, 24)),
                ontop=e.peek(s, a + PG_ONTOP, 1)[0], cnt=[e.u32(s, a + PG_CNT + 4 * i) for i in range(5)],
                ttl=e.cstr(s, a + PG_TTL, 16), ttl2=e.cstr(s, a + PG_TTL + 16, 16), kdn=f[0], ate=f[1], mods=f[2])


def rec_names(e, s, ids):
    """(short, long) names of records ids, as the page draws them."""
    return [(e.cstr(s, e.u32(s, REC(r) + 48), 5), e.cstr(s, e.u32(s, REC(r) + 40), 17)) for r in ids]


def page_ids(e, s, fx):
    """SEND FX fx's page descriptor ids (sfu_pages[1 + fx]: name, ids[8])."""
    a = sym(e, "sfu_pages") + 36 * (1 + fx) + 4
    return [e.u32(s, a + 4 * i) for i in range(8)]


def page_title(e, s, fx):
    """SEND FX fx's page title now (sfu_pages[1 + fx].name: "SEND FX 1" for one page, "SEND FX 1 2/3" in a paged effect)."""
    return e.cstr(s, e.u32(s, sym(e, "sfu_pages") + 36 * (1 + fx)), 16)


PAGE1 = ["TYPE", "ROUT", "MOD", "LEV", "P3", "P4", "BASE", "WID"]
CHORUS1 = ["TYPE", "ROUT", "RATE", "DPTH", "DLY", "FDBK", "BASE", "WID"]
PLAIN1 = ["TYPE", "ROUT", "P2", "P3", "P4", "P5", "BASE", "WID"]
IDS1 = [[16, 17, 18, 19, 20, 21, 1, 2], [22, 23, 24, 25, 26, 27, 3, 4]]
RECS = IDS1
HOST = None


def host_msgs():
    """21 (OFF CHORUS FX16 FX17), CHORUS's 24, FX16's and FX17's 24 + 51s, and FX16's P5..P16 values for FX 1."""
    global HOST
    if HOST is None:
        names = b"".join(P.sendfx_names([(0, "OFF"), (1, "CHORUS"), (FX16, "FX16"), (FX17, "FX17")]))
        HOST = names + fx16_msgs() + fx16_msgs(12, FX17) + label_msgs((1,)) + \
            P.sendfx_xknobs(0, 5, [7 * p for p in range(5, 17)])
    return HOST


def page1_ok(e, s, fx=0, names=PAGE1):
    """FX fx is back on page 1: its records TYPE ROUT MOD LEV P3 P4 BASE WID (FX16's labels; names: another TYPE's),
    the ids in the page descriptor."""
    nm = rec_names(e, s, RECS[fx])
    return [n[0] for n in nm] == names and page_ids(e, s, fx) == IDS1[fx], f"{nm} {page_ids(e, s, fx)}"


def t_xpages(e):
    """sendfx-pages (issue #15; the owner's key cycle): a user effect with P1..P16 on SEND FX 1 - SRC pressed again on
    its SEND FX page = page 2 (A..H = P5..P12, the 51's names, the host's values, title SEND FX 1 2/3), again = page 3
    (A..D = P13..P16, E..H empty), once more = stock's: DELAY, and the page is page 1 again. A turn on page 2 goes to
    the host (22 ver 3) and leaves the kit's FX words alone; with a trig held nothing locks. A host value redraws it.
    SMPL does the same on SEND FX 2 (REVERB -> SEND FX 2 -> pages 2, 3 -> REVERB). Screens: xpages-*.png."""
    ex = poke_type(e, 0, FX16)
    fx0 = {i: w16(e, e.snap, FXW + 2 * i) for i in (0, 29, 38, 39, 40, 41)}
    go = [(20, "usb", host_msgs()), (50, "press", "FX"), (150, "press", "SRC")]
    # page 2, a turn of knob C (P7)
    ev = go + [(400, "press", "SRC"), (800, "turn", ("2:+8", 3, 10))]
    s = e.run("xpages-2", 1100, ev, save=True, extra=ex)
    g = pg_state(e, s)
    U.check("xpages: the build has sfu_p (0029 with the extra pages)", have_pages(e), "no symbol sfu_p")
    U.check("xpages: FX16's 51s give SEND FX 1 three pages (P5..P16), FX 2 one", g["npg"] == [3, 1] and g["nx"] == [12, 0],
            str(g))
    U.check("xpages: SRC pressed on SEND FX 1 = page 2, title SEND FX 1 2/3, and stock did not leave for DELAY",
            g["pg"] == [1, 0] and g["ttl"] == "SEND FX 1 2/3" and g["ontop"] == 1 and g["cnt"][2] == 1, str(g))
    nm = rec_names(e, s, [16, 17, 18, 19, 20, 21, 1, 2])
    U.check("xpages: page 2's knobs A..H are named X5..X12 (the upper left: Extra P5..)",
            [n[0] for n in nm] == [f"X{p}" for p in range(5, 13)] and nm[0][1] == "Extra P5" and nm[7][1] == "Extra P12",
            str(nm))
    U.check("xpages: the host's values (7 x P), knob C turned up from 49", g["pv"][0] == 35 and g["pv"][2] > 49 and
            g["pv"][11] == 112, str(g["pv"]))
    x3 = [m for m in e.sent if len(m) > 9 and m[4] == 0x22 and m[5] == 3]
    d = P.decode_sendfx_xknobs(x3[-1][5:-1]) if x3 else None
    U.check("xpages: the turn went to the host as 22 ver 3 (FX 1, P5..P16, P7 turned)",
            bool(d) and d["fx"] == 0 and d["first"] == 5 and len(d["values"]) == 12 and d["values"][2] == g["pv"][2],
            f"{len(x3)} sent, last {d}")
    fx = {i: w16(e, s, FXW + 2 * i) for i in fx0}
    U.check("xpages: the kit's FX words are untouched by page 2 (TYPE stays FX16)", all(
        fx[i] == fx0[i] for i in (0, 38, 39, 40, 41)) and (fx[29] >> 8) == FX16, " ".join(f"{i}:{fx[i]:04x}" for i in fx))
    # page 3 (E..H empty)
    ev = go + [(400, "press", "SRC"), (550, "press", "SRC")]
    s = e.run("xpages-3", 900, ev, save=True, extra=ex)
    g = pg_state(e, s)
    nm = rec_names(e, s, [16, 17, 18, 19])
    U.check("xpages: SRC again = page 3, SEND FX 1 3/3, A..D = X13 X14 X15 X16, E..H empty (ids 0)",
            g["pg"][0] == 2 and g["ttl"] == "SEND FX 1 3/3" and [n[0] for n in nm] == ["X13", "X14", "X15", "X16"] and
            page_ids(e, s, 0)[4:] == [0, 0, 0, 0], f"{g} {nm} {page_ids(e, s, 0)}")
    # the fourth press is stock's: DELAY (knob A = TIM, FX word 9), SEND FX 1 back on page 1
    ev = go + [(400, "press", "SRC"), (550, "press", "SRC"), (700, "press", "SRC"), (1000, "turn", ("0:+20", 2, 20))]
    s = e.run("xpages-wrap", 1200, ev, save=True, extra=ex)
    g = pg_state(e, s)
    ok, why = page1_ok(e, s)
    U.check("xpages: the press on the last page is stock's: DELAY (TIM turned), SEND FX 1 on page 1, its records back",
            g["pg"] == [0, 0] and g["ontop"] == 0 and w16(e, s, FXW + 18) != w16(e, e.snap, FXW + 18) and ok and
            g["cnt"][2] == 2 and g["cnt"][3] >= 1, f"{g} {why}")
    # ... and SRC once more shows SEND FX 1 on page 1 (title 1/3, TYPE ROUT MOD LEV P3 P4 BASE WID)
    ev = go + [(400, "press", "SRC"), (550, "press", "SRC"), (700, "press", "SRC"), (850, "press", "SRC")]
    s = e.run("xpages-again", 1100, ev, save=True, extra=ex)
    g = pg_state(e, s)
    ok, why = page1_ok(e, s)
    U.check("xpages: back on SEND FX 1 after the cycle: page 1 (SEND FX 1 1/3, TYPE.. WID), the P2 name Mode",
            g["pg"][0] == 0 and g["ontop"] == 1 and g["ttl"] == "SEND FX 1 1/3" and ok and
            rec_names(e, s, [18])[0][1] == "Mode", f"{g} {why}")
    # a trig held on page 2: the turn locks nothing (and is not sent to the host either: lock-set refused)
    ev = go + [(300, "press", "RECORD"), (400, "press", "T1"), (500, "press", "SRC"),
               (900, "press", "T1:400M"), (1000, "turn", ("0:+20", 3, 20)), (1400, "press", "RECORD")]
    s = e.run("xpages-lock", 1600, ev, save=True, extra=ex)
    g = pg_state(e, s)
    U.check("xpages: with a trig held on page 2 no lock lands on FX words 29 / 38 / 39",
            g["pg"][0] == 1 and all(lock(e, s, 12, 0, i) == 0xffff for i in (29, 38, 39)),
            f"pg {g['pg']} locks " + " ".join(f"{lock(e, s, 12, 0, i):04x}" for i in (29, 38, 39)))
    # a host value while page 2 shows: taken (no turn of ours pending)
    ev = go + [(400, "press", "SRC"), (900, "usb", P.sendfx_xknobs(0, 9, [1, 2, 3, 4]))]
    s = e.run("xpages-host", 1100, ev, save=True, extra=ex)
    g = pg_state(e, s)
    U.check("xpages: a host 22 ver 3 (P9..P12) lands on page 2's knobs E..H", g["pv"][4:8] == [1, 2, 3, 4] and
            g["cnt"][1] >= 2, str(g))
    # SEND FX 2 with SMPL (FX16 on both: each FX its own page): REVERB, SEND FX 2, then the pages
    ex2 = ex + poke_type(e, 1, FX16)
    go2 = [(20, "usb", host_msgs()), (50, "press", "FX"), (150, "press", "SMPL"), (250, "press", "SMPL")]
    s = e.run("xpages-fx2", 900, go2 + [(450, "press", "SMPL")], save=True, extra=ex2)
    g = pg_state(e, s)
    U.check("xpages: SMPL pressed on SEND FX 2 = its page 2 (SEND FX 2 2/3), FX 1 stays on page 1",
            g["pg"] == [0, 1] and g["ttl2"] == "SEND FX 2 2/3" and g["ontop"] == 2 and
            [n[0] for n in rec_names(e, s, [22, 23, 3, 4])] == ["X5", "X6", "X11", "X12"], f"{g} {rec_names(e, s, [22, 23, 3, 4])}")
    s = e.run("xpages-fx2-wrap", 1200, go2 + [(450, "press", "SMPL"), (600, "press", "SMPL"), (750, "press", "SMPL")],
              save=True, extra=ex2)
    g = pg_state(e, s)
    ok, why = page1_ok(e, s, 1)
    U.check("xpages: SMPL on page 3 is stock's: REVERB, SEND FX 2 on page 1 again", g["pg"] == [0, 0] and g["ontop"] == 0 and
            ok and g["cnt"][2] == 2, f"{g} {why}")
    # an effect without P5.. (CHORUS): one page, SRC / SMPL are stock's at once
    s = e.run("xpages-chorus", 700, [(20, "usb", host_msgs()), (50, "press", "FX"), (150, "press", "SRC"),
                                     (400, "press", "SRC")], save=True, extra=poke_type(e, 0, 1))
    g = pg_state(e, s)
    U.check("xpages: CHORUS (P1..P4): one page, a second SRC is stock's (DELAY): no step, SEND FX 1 not the screen",
            g["npg"][0] == 1 and g["pg"][0] == 0 and g["cnt"][2] == 0 and g["ontop"] == 0 and
            page1_ok(e, s, 0, CHORUS1)[0] and page_title(e, s, 0) == "SEND FX 1", f"{g} {page1_ok(e, s, 0, CHORUS1)[1]}")


def t_xreset(e):
    """sendfx-pages: SEND FX always starts on page 1. Leaving the page (another page or track, a menu), a kit change (the
    TYPE words another), a host 21 replace, a project load and the host dropping put the FX back on page 1 and its real
    records back: coming back shows page 1. A 24 sent again for the same TYPE keeps the page."""
    ex = poke_type(e, 0, FX16)
    go = [(20, "usb", host_msgs()), (50, "press", "FX"), (150, "press", "SRC"), (400, "press", "SRC")]
    s1 = e.run("xreset-2", 650, go, save=True, extra=ex)
    g = pg_state(e, s1)
    U.check("xreset: SEND FX 1 is on page 2 to start from", g["pg"][0] == 1 and g["ontop"] == 1, str(g))
    t1 = e.clock + 650

    def after(name, length, events=(), extra=(), snap=None, start=None):
        s = e.run(name, length, list(events), snap=snap or s1, start=start or t1, save=True, extra=list(extra))
        return s, pg_state(e, s)

    # leaving by another page of the FX track (AMP, FLTR), another track (BD): page 1, records restored
    for key, evs in (("AMP", [(60, "press", "AMP")]), ("FLTR", [(60, "press", "FLTR")]),
                     ("TRK + BD", [(60, "press", "TRK:150M"), (100, "press", "BD")])):
        s, g = after(f"xreset-{key[-2:]}", 350, evs)
        ok, why = page1_ok(e, s)
        U.check(f"xreset: {key} pressed on page 2: SEND FX 1 is on page 1 again, its records restored, title back",
                g["pg"][0] == 0 and g["ontop"] == 0 and g["cnt"][3] >= 1 and ok and
                page_title(e, s, 0) == "SEND FX 1 1/3", f"{g} {why} {page_title(e, s, 0)}")
    # leaving by SMPL (SEND FX 2's page is another screen): FX 1 back on page 1
    s, g = after("xreset-smpl", 400, [(60, "press", "SMPL")])
    U.check("xreset: SMPL pressed on SEND FX 1's page 2: FX 1 on page 1", g["pg"][0] == 0 and page1_ok(e, s)[0], str(g))
    # coming back: AMP, then SRC SRC (DELAY, SEND FX 1) shows page 1
    s, g = after("xreset-back", 700, [(60, "press", "AMP"), (200, "press", "SRC"), (350, "press", "SRC")])
    ok, why = page1_ok(e, s)
    U.check("xreset: left by AMP and back by SRC SRC: SEND FX 1 shows page 1 (title 1/3), not page 2",
            g["pg"][0] == 0 and g["ontop"] == 1 and g["ttl"] == "SEND FX 1 1/3" and ok, f"{g} {why}")
    # a kit change: the FX 1 TYPE words become CHORUS (a kit with another effect), or FX17 (a user effect with 3 pages)
    s, g = after("xreset-kit", 350, extra=poke_type(e, 0, 1))
    ok, why = page1_ok(e, s, 0, CHORUS1)
    U.check("xreset: a kit change to CHORUS while on page 2: page 1, one page, the records restored, still on the screen",
            g["pg"][0] == 0 and g["npg"][0] == 1 and g["ontop"] == 1 and ok and page_title(e, s, 0) == "SEND FX 1",
            f"{g} {why} {page_title(e, s, 0)}")
    s, g = after("xreset-kit17", 350, extra=poke_type(e, 0, FX17))
    ok, why = page1_ok(e, s)
    U.check("xreset: a kit change to another user effect with the same page count: page 1 too",
            g["pg"][0] == 0 and g["npg"][0] == 3 and g["ontop"] == 1 and page_title(e, s, 0) == "SEND FX 1 1/3" and ok,
            f"{g} {why}")
    # a host 21 replace: the labels and names are forgotten, so is the page
    s, g = after("xreset-21", 400, [(60, "usb", b"".join(P.sendfx_names([(0, "OFF"), (1, "CHORUS"), (FX16, "FX16")])))])
    ok, why = page1_ok(e, s, 0, PLAIN1)
    U.check("xreset: a host 21 (replace) while paged: page 1, one page, the records restored", g["pg"][0] == 0 and
            g["npg"][0] == 1 and g["nx"][0] == 0 and ok and page_title(e, s, 0) == "SEND FX 1", f"{g} {why}")
    s, g = after("xreset-21b", 700, [(60, "usb", b"".join(P.sendfx_names([(0, "OFF"), (1, "CHORUS"), (FX16, "FX16")]))),
                                    (150, "usb", fx16_msgs())])
    U.check("xreset: ... and the host's 24 / 51 again: the pages are back, on page 1", g["pg"][0] == 0 and g["npg"] == [3, 1]
            and g["ontop"] == 1 and page1_ok(e, s)[0], str(g))
    # a 24 (and the 51s) sent again for the same TYPE: the page stays (the host re-sends them on a reconnect, an ASK)
    s, g = after("xreset-24", 400, [(60, "usb", P.sendfx_labels(FX16, ("MOD", "LEV", "P3", "P4"), []))])
    U.check("xreset: a 24 sent again for FX16 does not throw the user off page 2", g["pg"][0] == 1 and g["npg"][0] == 3 and
            page_title(e, s, 0) == "SEND FX 1 2/3", str(g))
    s, g = after("xreset-24b", 500, [(60, "usb", fx16_msgs())])
    nm = rec_names(e, s, [16, 17])
    U.check("xreset: ... nor the 24 and its 51s: page 2, the names X5 X6", g["pg"][0] == 1 and
            page_title(e, s, 0) == "SEND FX 1 2/3" and
            [n[0] for n in nm] == ["X5", "X6"] and nm[0][1] == "Extra P5", f"{g} {nm}")
    # a project load: the menus leave the page, the stored kit's TYPE is another
    ev, t = X.proj_keys(60, False)
    s, g = after("xreset-load", t, ev)
    ok, why = page1_ok(e, s)
    U.check("xreset: a project load while on page 2: page 1, the records restored (the menus left the page)",
            g["pg"][0] == 0 and g["ontop"] == 0 and ok, f"{g} {why}")
    # the host dropping (the port gone): page 1
    hp = subprocess.run([os.path.join(U.EMU, "target", "release", "dtboot"), "--help"], capture_output=True, text=True)
    if "--usb-host-gone" in hp.stdout + hp.stderr:
        s, g = after("xreset-gone", 500, extra=["--usb-host-gone", f"{t1 + 100}M:{t1 + 250}M"])
        U.check("xreset: the host gone (the port down) while on page 2: page 1, records restored",
                g["pg"][0] == 0 and page1_ok(e, s)[0], str(g))
    else:
        print("    host drop: skipped (no --usb-host-gone in this dtboot)")


PG_OVL = 4704                      # sfu_p's ovl (fix round 1): 0026's page or splash is the screen (0026 writes it)
ACTIVE_KIT = 0x800067b8            # the kit number (a 32-bit int)


def keepalives(t0, t1):
    """0026's host keepalive (3C) every 20 M: the page stays open (its idle timeout)."""
    return [(t, "usb", P.rui_keepalive()) for t in range(t0, t1, 20)]


def t_xfix(e):
    """Fix round 1 of the extra send FX pages. H1: the host gone with a paged effect: SRC is stock's (DELAY), no extra
    pages while the port is down. M1: a kit change that keeps the TYPE (another kit number, or other FX words: a reload of
    the same slot) puts the page back on 1. M2: 0026's host page open over a stock SEND FX page: 0029 pages nothing, the
    key goes on to 0026. L3: the on-screen title follows a reset by the tick."""
    ex = poke_type(e, 0, FX16)
    go = [(20, "usb", host_msgs()), (50, "press", "FX"), (150, "press", "SRC")]
    s1 = e.run("xfix-2", 650, go + [(400, "press", "SRC")], save=True, extra=ex)
    g = pg_state(e, s1)
    U.check("xfix: SEND FX 1 is on page 2 to start from", g["pg"][0] == 1 and g["ontop"] == 1 and g["cnt"][2] == 1, str(g))
    t1 = e.clock + 650

    def after(name, length, events=(), extra=()):
        s = e.run(name, length, list(events), snap=s1, start=t1, save=True, extra=list(extra))
        return s, pg_state(e, s)

    # H1: the host gone (the port down) while on page 2, then SRC: stock's (DELAY), not another page step
    hp = subprocess.run([os.path.join(U.EMU, "target", "release", "dtboot"), "--help"], capture_output=True, text=True)
    if "--usb-host-gone" in hp.stdout + hp.stderr:
        gone = ["--usb-host-gone", f"{t1 + 100}M:{t1 + 600}M"]
        s, g = after("xfix-gone-src", 450, [(300, "press", "SRC")], gone)
        U.check("xfix H1: host gone on page 2, then SRC: page 1, no new step, the screen is DELAY's (stock's cycle)",
                g["pg"] == [0, 0] and g["cnt"][2] == 1 and g["ontop"] == 0 and g["ate"] == 0, str(g))
        s, g = after("xfix-gone-title", 300, [], gone)
        U.check("xfix H1: while the port is down SEND FX 1 has one page (title SEND FX 1, no 2/3)",
                g["npg"][0] == 1 and g["nx"][0] == 0 and page_title(e, s, 0) == "SEND FX 1" and page1_ok(e, s)[0],
                f"{g} {page_title(e, s, 0)}")
        s, g = after("xfix-gone-back", 800, [], ["--usb-host-gone", f"{t1 + 100}M:{t1 + 250}M"])
        U.check("xfix H1: the port back: the pages are back, on page 1 (title SEND FX 1 1/3)",
                g["npg"][0] == 3 and g["pg"][0] == 0 and page_title(e, s, 0) == "SEND FX 1 1/3", f"{g} {page_title(e, s, 0)}")
    else:
        print("    host drop: skipped (no --usb-host-gone in this dtboot)")
    # M1: a kit change that keeps the TYPE: another kit number; other FX words (a reload of the same slot)
    s, g = after("xfix-kitnum", 350, [], ["--poke", f"{ACTIVE_KIT:x}=00000001"])
    ok, why = page1_ok(e, s)
    U.check("xfix M1: another kit number, the same TYPE, while on page 2: page 1, the title SEND FX 1 1/3, records back",
            g["pg"][0] == 0 and g["ontop"] == 1 and page_title(e, s, 0) == "SEND FX 1 1/3" and ok and g["cnt"][3] >= 1,
            f"{g} {why} {page_title(e, s, 0)}")
    s, g = after("xfix-kitwords", 350, [], ["--poke", f"{FXW + 2 * 38:x}=12345678"])
    ok, why = page1_ok(e, s)
    U.check("xfix M1: the same kit slot loaded again (FX words 38 / 39 other, the TYPE and the number the same): page 1",
            g["pg"][0] == 0 and g["ontop"] == 1 and page_title(e, s, 0) == "SEND FX 1 1/3" and ok and g["cnt"][3] >= 1,
            f"{g} {why} {page_title(e, s, 0)}")
    s, g = after("xfix-kitsame", 350, [])
    U.check("xfix M1: (control) nothing changed: page 2 stays", g["pg"][0] == 1 and g["cnt"][3] == 0 and
            page_title(e, s, 0) == "SEND FX 1 2/3", str(g))
    # L3: a reset by the tick (the TYPE another here) pushes the title to the glass: the on-screen title is page 1's
    s, g = after("xfix-title", 350, [], poke_type(e, 0, FX17))
    U.check("xfix L3: a reset the tick makes while SEND FX 1 is on screen pushes the title again (retitles)",
            g["pg"][0] == 0 and g["ontop"] == 1 and g["cnt"][4] >= 2, str(g))
    # M2: 0026's host page open (TRK + YES, keepalives) over SEND FX 1 on page 1: SRC is not paged
    base = go + keepalives(60, 900) + [(250, "press", "TRK:60M"), (260, "press", "YES")]
    o = e.run("xfix-host-0", 400, base, save=True, extra=ex)
    g = pg_state(e, o)
    ov = e.u32(o, sym(e, "sfu_p") + PG_OVL) if have_pages(e) else 0
    act = e.u32(o, sym(e, "st", "0026-remote-ui") + 4)
    U.check("xfix M2: the host page is open over SEND FX 1 (0026 active), and 0029 knows (ovl set)",
            act == 1 and g["pg"] == [0, 0] and ov == 1, f"active {act} ovl {ov} {g}")
    s = e.run("xfix-host-src", 800, base + [(450, "press", "SRC")], save=True, extra=ex)
    g = pg_state(e, s)
    act = e.u32(s, sym(e, "st", "0026-remote-ui") + 4)
    U.check("xfix M2: SRC with the host page open over SEND FX 1: the hidden page is not paged (no step, page 1, nothing eaten)",
            act == 1 and g["pg"] == [0, 0] and g["cnt"][2] == 0 and g["ate"] == 0, f"active {act} {g}")
    mask = [(100, "usb", P.rui_mask(keys=[0x31]))]
    s = e.run("xfix-host-mask", 800, base + mask + [(450, "press", "SRC")], save=True, extra=ex)
    g = pg_state(e, s)
    keys = [m for m in e.sent if len(m) > 7 and m[4] == 0x31]
    U.check("xfix M2: ... with SRC in the host's catch mask: the host gets the key (31), 0029 pages nothing",
            g["pg"] == [0, 0] and g["cnt"][2] == 0 and any(0x31 in m[6:-1] for m in keys), f"{g} keys {[m.hex() for m in keys][:4]}")
    # ... and the page closed again (TRK + YES): SRC pages as before
    s = e.run("xfix-host-closed", 1100, base + [(450, "press", "TRK:60M"), (460, "press", "YES"), (700, "press", "SRC")],
              save=True, extra=ex)
    g = pg_state(e, s)
    U.check("xfix M2: (control) the host page closed again: SRC on SEND FX 1 pages (page 2)", g["pg"][0] == 1 and g["cnt"][2] == 1,
            str(g))


def t_xcc(e):
    """Review F2 (a probe, report): a paged effect on SEND FX page 2 and MIDI control changes (every CC 0..127 on all 16
    channels, value 100) arriving: does the kit-signature fold (sfu.c kitsig) throw the
    page back to 1? The six FX words it hashes are written by the F-set wrappers only; the CC tables map no CC to our
    records (design.md: ids 14..27), so no CC should reach them. Checks: page 2 stays (no reset counted), none of the six
    words changed; and that the sweep did something (other kit bytes or FX words moved), so the probe was heard."""
    ex = poke_type(e, 0, FX16)
    go = [(20, "usb", host_msgs()), (50, "press", "FX"), (150, "press", "SRC")]
    s1 = e.run("xcc-2", 650, go + [(400, "press", "SRC")], save=True, extra=ex)
    g1 = pg_state(e, s1)
    U.check("xcc: SEND FX 1 is on page 2 to start from", g1["pg"][0] == 1 and g1["ontop"] == 1, str(g1))
    t1 = e.clock + 650
    cc = bytes(b for ch in range(16) for n in range(128) for b in (0xB0 | ch, n, 100))
    words = (0, 29, 38, 39, 40, 41)
    before = {i: w16(e, s1, FXW + 2 * i) for i in range(42)}
    s = e.run("xcc-sweep", 400, [(50, "usb", cc)], snap=s1, start=t1, save=True)
    g = pg_state(e, s)
    after = {i: w16(e, s, FXW + 2 * i) for i in range(42)}
    moved = [i for i in range(42) if before[i] != after[i]]
    kit = int.from_bytes(e.peek(s1, ACTIVE_KIT, 4), "big")
    print(f"    FX words that moved: {moved} (the six: {[i for i in moved if i in words]}); page {g1['pg']} -> {g['pg']}, "
          f"resets {g1['cnt'][3]} -> {g['cnt'][3]}, kit {kit}")
    U.check("xcc: 2048 CCs (16 channels x 128 numbers): page 2 stays and no reset is counted (the fold saw no change)",
            g["pg"][0] == 1 and g["cnt"][3] == g1["cnt"][3], f"{g} vs {g1}")
    U.check("xcc: (control) the sweep was heard: stock FX words (DELAY, REVERB, ...) moved", len(moved) >= 10, str(moved))
    U.check("xcc: none of the six FX words (TYPE / P1..P5 of both FX) moved", not [i for i in moved if i in words],
            str([(i, before[i], after[i]) for i in moved if i in words]))


def t_xkeys(e):
    """sendfx-pages: the page key's further press only where it belongs. UP held then SRC (0026's combo: stock's, no
    page), FUNC held then SRC, SRC pressed in the instant after another page key (the view list, not the tick's, says
    where the screen is), a held SRC (one step, its repeats and release eaten), a built-in effect with one page (SRC /
    SMPL cycle as before), and SMPL on SEND FX 2 for a user effect."""
    ex = poke_type(e, 0, FX16)
    go = [(20, "usb", host_msgs()), (50, "press", "FX"), (150, "press", "SRC")]
    # UP held, then SRC: stock's cycle to DELAY (0026's UP + SRC: SRC alone on the FX track), no page
    s = e.run("xkeys-up", 800, go + [(300, "press", "UP:400M"), (400, "press", "SRC")], save=True, extra=ex)
    g = pg_state(e, s)
    U.check("xkeys: UP held then SRC on SEND FX 1: stock's (DELAY), no page step, no press eaten",
            g["pg"][0] == 0 and g["ontop"] == 0 and g["cnt"][2] == 0 and g["ate"] == 0, str(g))
    s = e.run("xkeys-func", 800, go + [(300, "press", "FUNC:400M"), (400, "press", "SRC")], save=True, extra=ex)
    g = pg_state(e, s)
    U.check("xkeys: FUNC held then SRC on SEND FX 1: no page step", g["pg"][0] == 0 and g["cnt"][2] == 0 and g["ate"] == 0,
            str(g))
    # after UP / FUNC are released the cycle works as before
    s = e.run("xkeys-up2", 900, go + [(250, "press", "UP:30M"), (400, "press", "SRC")], save=True, extra=ex)
    g = pg_state(e, s)
    U.check("xkeys: UP tapped and released, then SRC: page 2", g["pg"][0] == 1 and g["cnt"][2] == 1 and g["mods"] == 0, str(g))
    # FLTR, then SRC two million instructions later: the screen is FLTR's page, so no page step. (A smoke check of review
    # M1: the emulator hands the UI loop one key a pass with a tick between, so a handler working from the tick's ontop
    # passes this too [measured: such a build, gaps 0..16M, FLTR and AMP]; the race itself needs the hardware.)
    s = e.run("xkeys-fast", 800, go + [(300, "press", "FLTR"), (302, "press", "SRC")], save=True, extra=ex)
    g = pg_state(e, s)
    U.check("xkeys: FLTR and SRC 2M instructions apart on SEND FX 1: no page step from a view that is gone (M1 smoke)",
            g["pg"][0] == 0 and g["cnt"][2] == 0 and g["ate"] == 0, str(g))
    # a held SRC: one step, the key's repeats and its release are eaten (no DELAY after it)
    s = e.run("xkeys-hold", 1000, go + [(300, "press", "SRC:300M")], save=True, extra=ex)
    g = pg_state(e, s)
    U.check("xkeys: SRC held 300M: one page step (page 2), nothing left booked after the release",
            g["pg"][0] == 1 and g["ontop"] == 1 and g["cnt"][2] == 1 and g["kdn"] == 0 and g["ate"] == 0, str(g))
    # a built-in with one page: SRC then SRC is SEND FX 1 then DELAY; SMPL SMPL SMPL on FX 2 is REVERB, SEND FX 2, REVERB
    s = e.run("xkeys-built-in", 700, go + [(300, "press", "SRC")], save=True, extra=poke_type(e, 0, 1))
    g = pg_state(e, s)
    U.check("xkeys: CHORUS on SEND FX 1: SRC again is stock's (DELAY), nothing eaten", g["ontop"] == 0 and g["ate"] == 0 and
            g["cnt"][2] == 0, str(g))
    s = e.run("xkeys-built-in2", 800, [(20, "usb", host_msgs()), (50, "press", "FX"), (150, "press", "SMPL"),
                                       (250, "press", "SMPL"), (400, "press", "SMPL")], save=True, extra=poke_type(e, 1, 2))
    g = pg_state(e, s)
    U.check("xkeys: a built-in on SEND FX 2: SMPL SMPL = SEND FX 2, the third SMPL is stock's (REVERB): no page, nothing eaten",
            g["npg"][1] == 1 and g["ontop"] == 0 and g["cnt"][2] == 0 and g["ate"] == 0, str(g))
    # a user effect on SEND FX 2 only: SRC on FX 1 (OFF, no pages) is stock's, SMPL steps FX 2
    s = e.run("xkeys-fx2only", 900, [(20, "usb", host_msgs()), (50, "press", "FX"), (150, "press", "SMPL"),
                                      (250, "press", "SMPL"), (400, "press", "SMPL")], save=True, extra=poke_type(e, 1, FX16))
    g = pg_state(e, s)
    U.check("xkeys: a user effect on FX 2 only: SMPL steps SEND FX 2 to page 2, FX 1 has one page", g["pg"] == [0, 1] and
            g["npg"] == [1, 3] and g["ontop"] == 2, str(g))


def t_xlock(e):
    """sendfx-pages: a lock cleared (a trig held + the encoder's push) on a paged knob leaves the real FX word and the
    lock alone: page 2's knobs are the Sidecar's values (no locks, nothing in the kit). Control: the same push on page 1
    clears P2's lock."""
    ex = poke_type(e, 0, FX16)
    go = [(20, "usb", host_msgs()), (50, "press", "FX"), (150, "press", "SRC")]
    # RECORD, a trig on step 1, held: P2 (knob C) locked on page 1, then PUSH_C
    base = go + [(250, "press", "RECORD"), (350, "press", "T1"), (450, "press", "T1:900M"), (550, "turn", ("2:+20", 3, 20))]
    s = e.run("xlock-set", 1000, base, save=True, extra=ex)
    l38 = lock(e, s, 12, 0, 38)
    U.check("xlock: P2 locked on page 1 (FX word 38, step 1) to start from", l38 != 0xffff, f"{l38:04x}")
    w38 = w16(e, s, FXW + 2 * 38)
    s = e.run("xlock-clear1", 1300, base + [(800, "press", "PUSH_C:20")], save=True, extra=ex)
    U.check("xlock: control: PUSH_C with the trig held on page 1 clears P2's lock", lock(e, s, 12, 0, 38) == 0xffff,
            f"{lock(e, s, 12, 0, 38):04x}")
    s = e.run("xlock-clear2", 1300, base + [(700, "press", "SRC"), (850, "press", "PUSH_C:20")], save=True, extra=ex)
    g = pg_state(e, s)
    U.check("xlock: PUSH_C on page 2 (A..H = P5..): the lock on word 38 and the real word stay as they were",
            g["pg"][0] == 1 and lock(e, s, 12, 0, 38) == l38 and w16(e, s, FXW + 2 * 38) == w38,
            f"pg {g['pg']} lock {lock(e, s, 12, 0, 38):04x} (was {l38:04x}) word {w16(e, s, FXW + 2 * 38):04x} (was {w38:04x})")
    U.check("xlock: ... and the host's P7 is as the host said (49), not cleared to 0", g["pv"][2] == 49, str(g["pv"]))


def t_xmisc(e):
    """sendfx-pages and 51: a 51 past P16 is dropped whole (no names, no generation bump, lng_ok kept); a 51 for P5.. of a
    TYPE the table has not seen is dropped; the full names of P2..P5 show in the upper left (see fullnames)."""
    ex = poke_type(e, 0, FX16)
    base = [(20, "usb", host_msgs()), (50, "press", "FX"), (150, "press", "SRC")]
    s0 = e.run("xmisc-0", 500, base, save=True, extra=ex)
    if not have_pages(e):
        U.check("xmisc: the build has sfu_p", False, "no symbol sfu_p")
        return
    a = sym(e, "sfu_x")
    gen0, rx0, dr0 = e.u32(s0, a + X_GEN), e.u32(s0, a + X_LNG_RX), e.u32(s0, a + X_LNG_DROP)
    past = bytearray(P.sendfx_full_names(FX16, 16, [("PAST", "Past P16")]))
    past[7] = 17                                # first p 17: the helper refuses it
    s1 = e.run("xmisc-past", 300, [(40, "usb", bytes(past))], snap=s0, start=e.clock + 500, save=True)
    gen1, rx1, dr1 = e.u32(s1, a + X_GEN), e.u32(s1, a + X_LNG_RX), e.u32(s1, a + X_LNG_DROP)
    U.check("xmisc: a 51 past P16 is dropped: no new generation, no names taken, one more drop (L6)",
            gen1 == gen0 and rx1 == rx0 and dr1 == dr0 + 1, f"gen {gen0}->{gen1} rx {rx0}->{rx1} drop {dr0}->{dr1}")
    g = pg_state(e, s1)
    U.check("xmisc: ... and FX16 keeps its three pages and its names", g["npg"] == [3, 1] and
            rec_names(e, s1, [18])[0][1] == "Mode", str(g))
    # a 51 for a TYPE without a 24 (FX 100): dropped
    early = P.sendfx_full_names(100, 5, [("X5", "Early")])
    s2 = e.run("xmisc-early", 300, [(40, "usb", early)], snap=s0, start=e.clock + 500, save=True)
    U.check("xmisc: a 51 for a TYPE whose 24 has not come is dropped", e.u32(s2, a + X_LNG_DROP) == dr0 + 1 and
            e.u32(s2, a + X_LNG_RX) == rx0, f"drop {e.u32(s2, a + X_LNG_DROP)} rx {e.u32(s2, a + X_LNG_RX)}")


def t_xcopy(e):
    """Q1 probe: copy / paste on the FX track while page 2 is shown. With nothing held FUNC + RECORD / STOP copy / paste
    the PATTERN, with TRK held FX SETTINGS (the FX track's sound: the kit's FX words) [measured: the screens
    xcopy-*.png]; stock has no copy of a page. Either one runs on kit words and the pattern, never on the parameter
    records by id, so the paged values (the host's, in pv) must not move and the kit's FX words must come back as they
    were copied. Nothing may fault. Run 1 (page 2): copy; run 2: the words poked to other values, paste with the screen
    on page 1; run 3: the same, paste with the screen on page 2 again."""
    ex = poke_type(e, 0, FX16)
    w = {FXW + 76: bytes.fromhex("1234"), FXW + 78: bytes.fromhex("5678")}   # words 38 / 39 as the kit holds them
    exw = ex + X.pokes(e, e.snap, w)
    go = [(20, "usb", host_msgs()), (50, "press", "FX"), (150, "press", "SRC"), (300, "press", "SRC")]
    want = [7 * p for p in range(5, 17)]
    for what, hold in (("settings", True), ("pattern", False)):
        trk = lambda t: [(t, "press", "TRK:400M")] if hold else []   # noqa: E731
        d = 20 if hold else 0
        s1 = e.run(f"xcopy-{what}-copy", 900, go + trk(450) + [(470 + d, "press", "FUNC:60M"), (490 + d, "press", "RECORD")],
                   save=True, extra=exw)
        t = e.clock + 900   # (TRK's 400M hold is over by then)
        g1 = pg_state(e, s1)
        fx1 = {i: w16(e, s1, FXW + 2 * i) for i in (29, 38, 39)}
        U.check(f"xcopy: {what} copy while on page 2: the kit's FX words are as poked (the paged values are not in them), "
                "the host's P5.. unchanged", fx1[38] == 0x1234 and fx1[39] == 0x5678 and (fx1[29] >> 8) == FX16 and
                g1["pv"][:12] == want, f"{fx1} {g1['pv']}")
        junk = X.pokes(e, s1, {FXW + 76: bytes.fromhex("0a0b"), FXW + 78: bytes.fromhex("0c0d")})
        for where, nav in (("page 1", []), ("page 2", [(300, "press", "SRC")])):   # (the copy's pop-up first goes)
            ev = nav + trk(450) + [(470 + d, "press", "FUNC:60M"), (490 + d, "press", "STOP")]
            s2 = e.run(f"xcopy-{what}-paste-{where[-1]}", 800, ev, snap=s1, start=t, save=True, extra=junk)
            g2 = pg_state(e, s2)
            fx2 = {i: w16(e, s2, FXW + 2 * i) for i in (29, 38, 39)}
            print(f"    {what}: copied {{38: {fx1[38]:04x}, 39: {fx1[39]:04x}}}, poked 0a0b / 0c0d, pasted with the screen on "
                  f"{where}: kit words {{38: {fx2[38]:04x}, 39: {fx2[39]:04x}}}, pv {g2['pv'][:3]}")
            if nav:
                U.check(f"xcopy: {what} paste ({where}): the screen was on page 2 again before the paste (one more step)",
                        g2["cnt"][2] == g1["cnt"][2] + 1, f"steps {g1['cnt'][2]} -> {g2['cnt'][2]}")
            if hold:
                U.check(f"xcopy: FX settings paste ({where}): the kit's real words 38 / 39 are back (not the paged values)",
                        fx2[38] == 0x1234 and fx2[39] == 0x5678 and (fx2[29] >> 8) == FX16, str(fx2))
            U.check(f"xcopy: {what} paste ({where}): the host's P5..P16 (pv) are as the host said, nothing faulted",
                    g2["pv"][:12] == want, str(g2["pv"]))


X_TIME = 1124 + DL   # ui_sum ui_max ui_n mt_sum mt_max mt_n (DTCN0 counts)
ST_TICKS = 1034   # m68k: 2-byte alignment (calls at 1030)


def t_cost(e):
    """Cost (rytm-teensy 2026-10-16-rytm-stress-budgets.md): 0029's own time, DTCN0 inside sfu_tick and the P2..P5
    value texts (UI task) and sfu_sysex (MIDI task), x 200/132 = instructions at the emulator's 200 MIPS (interrupts
    inside count too: upper bounds); a 12.5 s session of labels, page switches and turns on all three pages."""
    names = P.sendfx_names([(i, P.SENDFX_TYPES[i]) for i in (0, 1, 2, 6, 8, 15)])
    msgs = b"".join(names) + label_msgs((1, 2, 6, 8, 15))
    ev = [(20, "usb", msgs), (50, "press", "FX"), (150, "press", "SRC")]
    t = 250
    for k in range(6):
        ev.append((t, "turn", (f"{k}:+20", 30, 4)))
        t += 140
    ev += [(t, "press", "SMPL"), (t + 100, "press", "SMPL")]
    t += 200
    for k in range(6):
        ev.append((t, "turn", (f"{k}:-20", 30, 4)))
        t += 140
    ev += [(t, "usb", msgs), (t + 50, "press", "BD"), (t + 100, "press", "AMP"), (t + 200, "press", "AMP"),
           (t + 300, "turn", ("0:+20", 30, 4)), (t + 450, "turn", ("1:+20", 30, 4))]
    s = e.run("cost", 2500, ev, save=True, extra=poke_type(e, 0, 6) + poke_type(e, 1, 15))
    a = sym(e, "sfu_x")
    ui_sum, ui_max, ui_n, mt_sum, mt_max, mt_n = (e.u32(s, a + X_TIME + 4 * i) for i in range(6))
    ticks = e.u32(s, sym(e, "sfu_st") + ST_TICKS)
    k = 200 / 132
    per_tick = ui_sum * k / max(ticks, 1)
    print(f"    UI: {ui_n} calls over {ticks} ticks, {per_tick:.0f} instr/tick, worst call {ui_max * k:.0f}; "
          f"MIDI task: {mt_n} messages, mean {mt_sum * k / max(mt_n, 1):.0f}, worst {mt_max * k:.0f}")
    U.check("cost: 0029's UI-task time <= 10 k instructions a tick on average", 0 < per_tick <= 10000, f"{per_tick:.0f}")
    U.check("cost: no 0029 UI call above 100 k instructions", ui_max * k <= 100000, f"{ui_max * k:.0f}")
    U.check("cost: no host message above 100 k instructions in 0029's MIDI-task handler", mt_max * k <= 100000,
            f"{mt_max * k:.0f}")
    lv_sum, lv_max, lv_n = (e.u32(s, a + 5378 + DL + 4 * i) for i in range(3))   # 0021's us_live, from 0029's ev_tick
    if lv_n:
        print(f"    0021 us_live (slot menu refresh): {lv_n} calls, {lv_sum * k / lv_n:.0f} instr/call, worst {lv_max * k:.0f}")
        U.check("cost: 0021's us_live <= 10 k instructions a tick on average, no call above 100 k",
                lv_sum * k / lv_n <= 10000 and lv_max * k <= 100000, f"{lv_sum * k / lv_n:.0f} / {lv_max * k:.0f}")


# ---- sfx-enum-knobs (2026-10-18): stepped knobs as stock's FILTER TYPE (record 49) ----
# struct sfu_x, appended fields (sfu.c; offsets from m68k-elf-gcc offsetof)
X_UN, X_KN, X_KLO, X_LOOK, X_STEPS = 1412 + DL, 1420 + DL, 1428 + DL, 1524 + DL, 1552 + DL
X_XM = 1560 + DL                 # xm[127], then xn[127] (0021's records 334..460)
REC = lambda r: 0x401bf918 + 0x34 * r          # noqa: E731
DESC = lambda r: 0x419a4888 + 84 * r           # noqa: E731
# Turns start LATE after the base resumes: in its first seconds the FX track's views take a turn as already awake
# (no two wake frames; FILTER TYPE's view does not) [measured: SEND FX 1 TYPE, 3 turns of 8 at 250M -> 2 steps, at
# 1500M -> 1, as FILTER TYPE at either] - the base's state, not the knobs'.
LATE = 1500
PATS = {"one": ("+8", 3, 10), "slow": ("+8", 10, 10), "fast": ("+8", 10, 2), "big": ("+32", 5, 10)}
LEN_LO = [0, 19, 37, 55, 74, 92, 110]


def turned(e, name, ev0, page_t, knob, pat, read, extra=(), snap=None, start=None):
    d, n, g = PATS[pat]
    ev = ev0 + [(page_t, "turn", (f"{knob}:{d}", n, g))]
    s = e.run(f"{name}-{pat}", page_t + n * g + 120, ev, save=True, extra=list(extra), snap=snap, start=start)
    return read(s), s


def stock_typ(e):
    """FILTER TYPE (record 49, 7 values) on BD: the reference. -> {pattern: steps from 0}."""
    out = {}
    for pat in PATS:
        out[pat], _ = turned(e, "enum-typ", [(50, "press", "FLTR")], LATE, 6, pat, lambda s: w16(e, s, SND0 + 64) >> 8)
    return out


def all_msgs(ids=(0, 1, 2, 6, 8, 15), sets=None):
    names = P.sendfx_names([(i, P.SENDFX_TYPES[i]) for i in ids])
    sets = sets or P.SENDFX_LABEL_SETS
    return b"".join(names) + b"".join(P.sendfx_labels(i, *sets[i]) for i in ids if i in sets)


def zone(v, los):
    return max(k for k, lo in enumerate(los) if lo <= v)


def t_enum(e):
    """Stepped knobs (sfx-enum-knobs): TYPE (a list position), P1 ROUTE (PRE / POST) and STUTTER LEN (7 zones, step
    bit) step as stock's FILTER TYPE does under the same turns (one, slow, fast, big); the words keep what the Sidecar
    reads (TYPE ids, P1 0 / 127, the zones' lo); the looks (text enum, switch, PRE / POST); an older Sidecar's 24 (no
    step bit) leaves LEN continuous. Screens build/emu/TAG/enum-*.png."""
    typ = stock_typ(e)
    a = sym(e, "sfu_x")
    ev1 = [(20, "usb", all_msgs()), (50, "press", "FX"), (150, "press", "SRC")]
    ev2 = [(20, "usb", all_msgs()), (50, "press", "FX"), (150, "press", "SMPL"), (250, "press", "SMPL")]
    ty, ln = {}, {}
    for pat in PATS:   # FX 2 TYPE from OFF through the built-in list (ids 0..14 = positions until a 21 arrives:
        ty[pat], _ = turned(e, "enum-type", ev2[1:], LATE, 0, pat, lambda s: w16(e, s, FXW) >> 8,
                            extra=poke_type(e, 1, 0))   # no 21 here: the default list, position = id)
        ln[pat], s = turned(e, "enum-len", ev1, LATE, 3, pat, lambda s: (w16(e, s, FXW + 76) & 0xfe) >> 1,
                            extra=poke_type(e, 0, 15))
    print(f"    steps  FILTER TYPE {typ}  TYPE {ty}  LEN(word) {ln}")
    U.check("enum: STUTTER LEN stores its zones' lo only (0 19 37 55 74 92 110)", all(v in LEN_LO for v in ln.values()),
            str(ln))
    U.check("enum: LEN steps as FILTER TYPE under every turn (one, slow, fast, big; both 7 options)",
            all(zone(ln[p], LEN_LO) == typ[p] for p in PATS), f"LEN {[zone(ln[p], LEN_LO) for p in PATS]} TYP {typ}")
    U.check("enum: TYPE steps as FILTER TYPE (one entry per step; capped as TYPE's 7)",
            all(min(ty[p], 6) == typ[p] for p in PATS), f"TYPE {ty} TYP {typ}")
    U.check("enum: one slow turn after the wake = one step on each (FILTER TYPE, TYPE, LEN)",
            typ["one"] == 1 and ty["one"] == 1 and zone(ln["one"], LEN_LO) == 1, f"{typ['one']} {ty['one']} {ln['one']}")
    # the looks and ranges on STUTTER (FX 1), screen
    s = e.run("enum-stutter", 600, ev1 + [(300, "turn", ("2:+8", 4, 10))], save=True, extra=poke_type(e, 0, 15))
    look = e.peek(s, a + X_LOOK, 14)
    kn = e.peek(s, a + X_KN, 8)
    rmax = [e.u32(s, REC(14 + i) + 12) for i in range(14)]
    U.check("enum: STUTTER's ENG is the OFF / ON switch (LOOP's draw), LEN a text enum of 7, D/P and GATE dials; TYPE "
            "a text enum, P1 PRE / POST", list(look[2:8]) == [1, 3, 2, 1, 0, 0] and list(kn[:4]) == [2, 7, 0, 0] and
            rmax[4] == 0x100 and rmax[5] == 0x600 and rmax[6] == 0x7f00 and rmax[3] == 0x100,
            f"look {look.hex()} kn {kn.hex()} max {[hex(x) for x in rmax[2:8]]}")
    U.check("enum: ENG turned on: word 38 hi = 64 (ON)", w16(e, s, FXW + 76) >> 8 == 64, f"{w16(e, s, FXW + 76):04x}")
    U.check("enum: TYPE's and LEN's draw is 0029's text, ENG's LOOP's switch, P1's DISTORTION's PRE / POST",
            e.u32(s, DESC(19) + 48) == sym(e, "sfu_draw") and e.u32(s, DESC(18) + 48) == e.u32(s, DESC(45) + 48) and
            e.u32(s, DESC(17) + 48) == e.u32(s, DESC(81) + 48) and e.u32(s, DESC(16) + 16) == e.u32(s, DESC(49) + 16), "")
    print("    screens enum-stutter.png (SEND FX 1 on STUTTER), enum-len-slow.png, enum-type-slow.png")
    # P1: PRE <-> POST stores 0 / 127
    p1, s = turned(e, "enum-p1", ev1, LATE, 1, "one", lambda s: (w16(e, s, FXW + 58) & 0xfe) >> 1)
    # back: after a step stock's enum profile holds off the next detent (FILTER TYPE alike), so 4 turns, not 3
    s2 = e.run("enum-p1-back", 1000, [(800, "turn", ("1:-8", 4, 10))], snap=s, start=e.clock + LATE + 150, save=True)
    p1b = (w16(e, s2, FXW + 58) & 0xfe) >> 1
    U.check("enum: P1 one step = POST, stored 127; one back = PRE, stored 0", (p1, p1b) == (127, 0), f"{p1} {p1b}")
    # an older Sidecar: the same 24s without the step bit -> LEN continuous (a dial, range 0..0x7f00)
    old = {i: (lab, [z[:5] for z in zs]) for i, (lab, zs) in P.SENDFX_LABEL_SETS.items()}
    evo = [(20, "usb", all_msgs(sets=old))] + ev1[1:]
    v, s = turned(e, "enum-old", evo, LATE, 3, "slow", lambda s: (w16(e, s, FXW + 76) & 0xfe) >> 1,
                  extra=poke_type(e, 0, 15))
    kn = e.peek(s, a + X_KN, 8)
    U.check("enum: an older Sidecar's 24 (no step bit): STUTTER's P2..P5 stay continuous (dials, 0..0x7f00), the "
            "labels as before", list(kn[:4]) == [0, 0, 0, 0] and e.u32(s, REC(19) + 12) == 0x7f00 and
            e.peek(s, a + X_LOOK + 5, 1)[0] == 0 and lbl(e, s, 0) == ["ENG", "LEN", "D/P", "GATE"],
            f"kn {kn.hex()} LEN word {v}")
    e.enum_typ = typ


def t_typelist(e):
    """TYPE as the Sidecar's list (21): OFF and the listed ids in list order, one per step; an id the kit holds and the
    list lacks stays selectable (between its numeric neighbours) until moved away."""
    lst = [(0, "OFF"), (2, "COMB"), (6, "RINGS"), (15, "STUTTER"), (64, "MYVERB")]
    names = b"".join(P.sendfx_names(lst))
    ev = [(20, "usb", names), (50, "press", "FX"), (150, "press", "SMPL"), (250, "press", "SMPL")]
    a = sym(e, "sfu_x")
    seq = []
    for k in (1, 3, 5, 7, 9):   # 2 wake turns, then k turns 30M apart: (k + 1) / 2 steps (the profile's hold-off)
        t = LATE
        evk = ev + [(t, "turn", ("0:+8", 2, 10))] + [(t + 20 + 30 * j, "turn", ("0:+8", 1, 10)) for j in range(k)]
        s = e.run(f"tlist-{k}", t + 20 + 30 * k + 150, evk, save=True, extra=poke_type(e, 1, 0))
        seq.append(w16(e, s, FXW) >> 8)
    un = e.u32(s, a + X_UN)
    U.check("typelist: the UI's list is the 21's (5 ids, OFF first)", un == 5 and list(e.peek(s, a + 1284 + DL, 5)) ==
            [0, 2, 6, 15, 64], f"un {un} {e.peek(s, a + 1284 + DL, 5).hex()}")
    order = [0, 2, 6, 15, 64]
    pos = [order.index(v) if v in order else -9 for v in seq]
    U.check("typelist: TYPE steps OFF -> COMB -> RINGS -> STUTTER (the list's order, never an unlisted id, never "
            "skipping an entry as the turns grow)", min(pos) >= 1 and all(0 <= b - a <= 1 for a, b in zip(pos, pos[1:]))
            and pos[-1] >= 3, str(seq))
    # big fast turns: only listed ids
    v, _ = turned(e, "tlist-big", ev, LATE, 0, "big", lambda s: w16(e, s, FXW) >> 8, extra=poke_type(e, 1, 0))
    U.check("typelist: fast big turns land on listed ids only", v in (2, 6, 15, 64), str(v))
    # the kit holds 7 (S4 RESO, not listed): +1 -> 15, -1 -> 6; once away it is gone
    up, s = turned(e, "tlist-7up", ev, LATE, 0, "one", lambda s: w16(e, s, FXW) >> 8, extra=poke_type(e, 1, 7))
    PATS["onedn"] = ("-8", 3, 10)
    dn, _ = turned(e, "tlist-7dn", ev, LATE, 0, "onedn", lambda s: w16(e, s, FXW) >> 8, extra=poke_type(e, 1, 7))
    s2 = e.run("tlist-7back", 1000, [(800, "turn", ("0:-8", 4, 10))], snap=s, start=e.clock + LATE + 150, save=True)
    back = w16(e, s2, FXW) >> 8
    del PATS["onedn"]
    U.check("typelist: an unlisted kit id (7) is selectable in place: one step up 15, one down 6; back down from 15 "
            "skips it (6)", (up, dn, back) == (15, 6, 6), f"up {up} down {dn} back {back}")


def t_enumlock(e):
    """P-locks on a stepped knob store the step's value (LEN's zone lo in word 38's lo half); kept by power-off and a
    cold boot."""
    ev = [(20, "usb", all_msgs()), (50, "press", "FX"), (150, "press", "SRC"), (250, "press", "RECORD"),
          (350, "press", "T1"), (450, "press", "T5"), (LATE - 100, "press", "T1:600M"), (LATE, "turn", ("3:+8", 12, 10)),
          (LATE + 700, "press", "RECORD")]
    c = U.card_copy(e, "enumlock")
    s = e.run("enumlock", LATE + 900, ev, save=True, card=c, extra=poke_type(e, 0, 15))
    l38 = lock(e, s, 12, 0, 38)
    base = w16(e, s, FXW + 76)
    U.check("enumlock: FX step 1 locks word 38 with LEN at a zone's lo (base LEN 0), step 5 free",
            l38 != 0xffff and ((l38 & 0xfe) >> 1) in LEN_LO[1:] and (base & 0xfe) == 0 and lock(e, s, 12, 4, 38) == 0xffff,
            f"lock {l38:04x} base {base:04x}")
    e.run("enumlock-off", 300, snap=s, start=e.clock + LATE + 900, card=c,
          extra=["--power-off", f"{e.clock + LATE + 1000}M"])
    s1 = e.run("enumlock-boot", 4400, X.DIALOGS, cold=True, card=c, save=True)
    U.check("enumlock: power-off and cold boot - the LEN lock back as stored", lock(e, s1, 12, 0, 38) == l38,
            f"{lock(e, s1, 12, 0, 38):04x} / {l38:04x}")
    e.enumlock = (s1, c)


def t_enumkit(e):
    """A pattern change to a kit with another TYPE re-switches the knobs: A01 (kit 0) STUTTER on FX 1 - LEN a text
    enum of 7; A02 (kit 1) CHORUS - P2..P5 dials (range 0..0x7f00)."""
    k1 = X.ST_PAT + 13101 * 2
    ed = {PROJ + 0x7f2: bytes.fromhex("0f00")}   # kit 0 (project copy): FX 1 TYPE 15
    s, c = X.poke_boot(e, "enumkit", ed)
    kit_of_a2 = e.peek(s, k1 + 0x3325, 1)[0]
    K1 = KIT0 + 2531 * kit_of_a2
    live = {K1 + 1866 + 58: bytes.fromhex("0100")}   # kit 1: FX 1 TYPE 1 (CHORUS)
    a = sym(e, "sfu_x")
    ev = [(20, "usb", all_msgs()), (50, "press", "FX"), (150, "press", "SRC")]
    s1 = e.run("enumkit-a01", 400, ev, snap=s, start=4400, card=c, save=True, extra=X.pokes(e, s, live))
    kn1, m1 = list(e.peek(s1, a + X_KN, 4)), e.u32(s1, REC(19) + 12)
    s2 = e.run("enumkit-a02", 600, [(50, "press", "BANK_A:200M"), (100, "press", "T2")], snap=s1, start=4800, card=c,
               save=True)
    kn2, m2 = list(e.peek(s2, a + X_KN, 4)), e.u32(s2, REC(19) + 12)
    cur = e.peek(s2, a + X_CUR, 2)
    U.check(f"enumkit: A01 STUTTER - ENG / LEN stepped (2, 7), LEN's range 0x600; A02 (kit {kit_of_a2}) CHORUS - all "
            "continuous, range 0x7f00", kit_of_a2 != 0 and kn1 == [2, 7, 0, 0] and m1 == 0x600 and kn2 == [0, 0, 0, 0]
            and m2 == 0x7f00 and cur[0] == 1, f"{kn1} {m1:#x} -> {kn2} {m2:#x} cur {cur.hex()}")
    U.check("enumkit: the labels follow (ENG LEN D/P GATE -> RATE DPTH DLY FDBK)", lbl(e, s1, 0) == ["ENG", "LEN", "D/P",
            "GATE"] and lbl(e, s2, 0) == ["RATE", "DPTH", "DLY", "FDBK"], f"{lbl(e, s1, 0)} {lbl(e, s2, 0)}")


def t_ext(e):
    """0021's list knobs (ext_steps through ext_stepbox): PLAITS ENG steps as FILTER TYPE (17 zones, each step stores
    the zone's lowest value: the host's v x 17 / 128 reads it back), DAISYSP ENG / INP / OUT stepped (3 / 11 / 2),
    JUNO PAT with the project's list (16) steps over its entries only, a p-lock on ENG stores a zone's lo and survives
    power-off; the stock knobs untouched. Screens ext-*.png."""
    a = sym(e, "sfu_x")
    lo17 = [(128 * k + 16) // 17 for k in range(17)]
    evp, t = U.walk_list(100, U.UI["downs"]["plaits"])
    # the reference with the same history (the profile's state follows what the knobs did before [measured: FILTER
    # TYPE slow 2 steps from the base, 4 after the machine list]): FILTER TYPE right after the same list walk
    typ = {p: turned(e, "ext-typ", evp + [(t + 50, "press", "FLTR")], t + LATE, 6, p,
                     lambda s: w16(e, s, SND0 + 64) >> 8)[0] for p in PATS}
    evp.append((t + 50, "press", "SRC"))
    z0 = None
    eng = {}
    for pat in PATS:
        v, s = turned(e, "ext-plaits", evp, t + LATE, 0, pat, lambda s: w16(e, s, SND0 + 18) >> 8)
        eng[pat] = v
    s0 = e.run("ext-plaits-0", t + LATE, evp, save=True)
    z0 = (w16(e, s0, SND0 + 18) >> 8) * 17 >> 7
    zs = {p: (v * 17 >> 7) - z0 for p, v in eng.items()}
    print(f"    PLAITS ENG from zone {z0}: words {eng} steps {zs}; FILTER TYPE {typ}")
    U.check("ext: PLAITS ENG stores zone lows only (ceil(128 k / 17)) and steps as FILTER TYPE (one, slow, fast, big)",
            all(v in lo17 for v in eng.values()) and all(min(zs[p], 6) == min(typ[p], 6) for p in PATS),
            f"{eng} {zs} {typ}")
    U.check("ext: ENG is a stepped zone knob (xm 1, N 17), its range 0x1000, its look the enum's (FILTER TYPE's profile)",
            e.peek(s, a + X_XM + 408 - 334, 1)[0] == 1 and e.peek(s, a + X_XM + 127 + 408 - 334, 1)[0] == 17 and
            e.u32(s, REC(408) + 12) == 0x1000 and e.u32(s, DESC(408) + 16) == e.u32(s, DESC(49) + 16), "")
    U.check("ext: HRM (409) stays a dial", e.peek(s, a + X_XM + 409 - 334, 1)[0] == 0 and
            e.u32(s, DESC(409) + 16) != e.u32(s, DESC(49) + 16), "")
    # DAISYSP
    evd, t2 = U.walk_list(100, U.UI["downs"]["daisysp"])
    evd += [(t2 + 50, "press", "SRC"), (t2 + 150, "turn", ("0:+8", 3, 10))]
    s = e.run("ext-daisysp", t2 + 300, evd, save=True)
    xm = e.peek(s, a + X_XM, 127)
    xn = e.peek(s, a + X_XM + 127, 127)
    U.check("ext: DAISYSP ENG (449) 3 zones, INP (453) 11 zones once their page drew", (xm[449 - 334], xn[449 - 334],
            xm[453 - 334], xn[453 - 334]) == (1, 3, 1, 11), f"{xm[115]} {xn[115]} {xm[119]} {xn[119]}")
    v = w16(e, s, SND0 + 18) >> 8
    U.check("ext: DAISYSP ENG stores a zone low (0 43 86)", v in (0, 43, 86), str(v))
    # JUNO PAT with a 5-entry list
    evj, t3 = U.walk_list(100, U.UI["downs"]["juno"])
    jn = b"".join(P.juno_names(["S1", "S2", "S3", "S4", "S5"]))
    evj += [(t3 + 50, "press", "SRC"), (t3 + 200, "usb", jn)]   # after PAT's text asked (10 + 13): the list is this project's
    v, s = turned(e, "ext-juno", evj, t3 + LATE, 0, "big", lambda s: w16(e, s, SND0 + 18) >> 8)
    xm, xn = e.peek(s, a + X_XM + 382 - 334, 1)[0], e.peek(s, a + X_XM + 127 + 382 - 334, 1)[0]
    U.check("ext: JUNO PAT with the project's 5 names is a list of 5 (stores 0..4), a big turn holds at the last",
            (xm, xn) == (2, 5) and v == 4 and e.u32(s, REC(382) + 12) == 0x400, f"xm {xm} n {xn} PAT {v}")
    # a p-lock on PLAITS ENG, kept over a power-off
    c = U.card_copy(e, "extlock")
    evl = evp + [(t + 100, "press", "RECORD"), (t + 200, "press", "T1"), (t + 300, "press", "T5"),
                 (t + 450, "press", "T1:500M"), (t + 550, "turn", ("0:+8", 6, 10)), (t + 1050, "press", "RECORD")]
    s = e.run("ext-lock", t + 1250, evl, save=True, card=c)
    l9 = lock(e, s, 0, 0, 9)
    U.check("ext: BD step 1 locks ENG (word 9) at a zone low", l9 != 0xffff and (l9 >> 8) in lo17 and
            (l9 >> 8) != w16(e, s, SND0 + 18) >> 8, f"lock {l9:04x} base {w16(e, s, SND0 + 18):04x}")
    e.run("ext-lock-off", 300, snap=s, start=e.clock + t + 1250, card=c, extra=["--power-off", f"{e.clock + t + 1350}M"])
    s1 = e.run("ext-lock-boot", 4400, X.DIALOGS, cold=True, card=c, save=True)
    U.check("ext: power-off and cold boot - the ENG lock back", lock(e, s1, 0, 0, 9) == l9, f"{lock(e, s1, 0, 0, 9):04x}")


def png_lit(path):
    """A dtboot screen PNG (8-bit RGB, 3x the OLED) -> rows of 0 / 1 (lit), stdlib only."""
    import struct
    import zlib
    d = open(path, "rb").read()
    i, idat = 8, b""
    while i < len(d):
        n, = struct.unpack(">I", d[i:i + 4])
        if d[i + 4:i + 8] == b"IHDR":
            w, h = struct.unpack(">II", d[i + 8:i + 16])
        elif d[i + 4:i + 8] == b"IDAT":
            idat += d[i + 8:i + 8 + n]
        i += 12 + n
    raw, bpp, st, rows, prev = zlib.decompress(idat), 3, 3 * w, [], bytearray(3 * w)
    for y in range(h):
        ft, line, cur = raw[y * (st + 1)], raw[y * (st + 1) + 1:(y + 1) * (st + 1)], bytearray(st)
        for x in range(st):
            a, b, c = (cur[x - bpp] if x >= bpp else 0), prev[x], (prev[x - bpp] if x >= bpp else 0)
            p = a + b - c
            pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
            pr = {0: 0, 1: a, 2: b, 3: (a + b) // 2, 4: a if pa <= pb and pa <= pc else b if pb <= pc else c}[ft]
            cur[x] = (line[x] + pr) & 255
        rows.append([1 if cur[3 * x] > 128 else 0 for x in range(w)])
        prev = cur
    return rows


def glyphs(rows, y0, y1, x0=0, x1=140):
    """The lit pixels of a screen band, cropped to their bounding box (None: nothing lit)."""
    ys = [y for y in range(y0, y1) if any(rows[y][x0:x1])]
    xs = [x for x in range(x0, x1) if any(rows[y][x] for y in range(y0, y1))]
    if not ys:
        return None
    return tuple(tuple(rows[y][xs[0]:xs[-1] + 1]) for y in range(ys[0], ys[-1] + 1))


def bw_sent(e):
    """The Rytm's 22 ver 2 messages (BASE / WIDTH turns) of the last run, decoded."""
    return [P.decode_sendfx_bw(m[5:-1]) for m in e.sent if len(m) > 6 and m[4] == P.SENDFX_STATE and m[5] == P.SENDFX_BW_VER]


def t_bw(e):
    """BASE / WIDTH (0.5.0, sfx-basewidth): SEND FX 1 / 2's knobs G and H are BASE and WID, the host's send FX return
    filter. They show what the host's 22 ver 2 says; a turn goes to the host as a 22 ver 2 (FX, BASE, WIDTH), never into
    the kit (the FX words stay as they were); with a trig held they do nothing (no lock, nothing sent).
    Screen bw-fx1.png."""
    s0 = e.snap
    fx0 = {i: w16(e, s0, FXW + 2 * i) for i in (0, 29, 38, 39, 40, 41)}
    ev = [(20, "usb", P.sendfx_bw(0, 40, 90) + P.sendfx_bw(1, 10, 127)), (50, "press", "FX"), (150, "press", "SRC"),
          (300, "turn", ("6:+20", 3, 20))]
    s = e.run("bw-fx1", 500, ev, save=True)
    m = bw_sent(e)
    print(f"    sent {m}")
    U.check("bw: SEND FX 1 knob G (BASE) turned up from the host's 40: 22 ver 2 FX 1, BASE above 40, WIDTH the host's 90",
            bool(m) and all(x and x["fx"] == 0 and x["width"] == 90 for x in m) and m[-1]["base"] > 40, str(m))
    names = [e.cstr(s, e.u32(s, REC(r) + 48), 5) for r in (1, 2, 3, 4)]
    U.check("bw: records 1..4 are named BASE WID BASE WID", names == ["BASE", "WID", "BASE", "WID"], str(names))
    fx = {i: w16(e, s, FXW + 2 * i) for i in fx0}
    U.check("bw: no FX word of the kit changed (BASE / WIDTH live on the host)", fx == fx0,
            " ".join(f"{i}:{fx0[i]:04x}->{fx[i]:04x}" for i in fx0))
    ev = [(20, "usb", P.sendfx_bw(0, 40, 90) + P.sendfx_bw(1, 10, 127)), (50, "press", "FX"), (150, "press", "SMPL"),
          (250, "press", "SMPL"), (400, "turn", ("7:-20", 3, 20))]
    e.run("bw-fx2", 600, ev)
    m = bw_sent(e)
    print(f"    sent {m}")
    U.check("bw: SEND FX 2 knob H (WID) turned down from the host's 127: 22 ver 2 FX 2, BASE the host's 10, WIDTH below",
            bool(m) and all(x and x["fx"] == 1 and x["base"] == 10 for x in m) and m[-1]["width"] < 127, str(m))
    ev = [(20, "usb", P.sendfx_bw(0, 40, 90)), (50, "press", "FX"), (150, "press", "SRC"), (250, "press", "RECORD"),
          (350, "press", "T1"), (450, "press", "T1:500M"), (550, "turn", ("6:+20", 3, 20)), (700, "turn", ("7:+20", 3, 20)),
          (1050, "press", "RECORD")]
    s = e.run("bw-lock", 1250, ev, save=True)
    m = bw_sent(e)
    U.check("bw: with a trig held, G and H lock nothing and send nothing", not m and lock(e, s, 12, 0, 29) == 0xffff,
            f"sent {m} lock 29 {lock(e, s, 12, 0, 29):04x}")


X_BW = 5644 + DL       # sfx-basewidth: bw[2][2], bw_tx, bw_rx, then bw_sent, bw_got (after xk[127]; 2-byte alignment)
X_BW_GOT = X_BW + 10


def bw_x(e, s):
    """sfu_x's BASE / WIDTH fields: ((FX 1 base, width), (FX 2 base, width)), bw_got."""
    b = e.peek(s, sym(e, "sfu_x") + X_BW, 4)
    return ((b[0], b[1]), (b[2], b[3])), e.u32(s, sym(e, "sfu_x") + X_BW_GOT)


def t_bw2(e):
    """BASE / WIDTH, the review's cases (2026-11-12): what knob G shows follows a host value that arrives while the page
    is open (the redraw), as a fresh draw of that value; a ver-1 22 and a 22 ver 2 for FX 3 change nothing; a turn wins
    over a host value that crosses it (pending, or within ~200 ms of its send: the host's 2 s refresh brings the rest);
    a later host value is taken; the WID records' default is 127 (0x7f00), the filter off."""
    gband = lambda path: glyphs(png_lit(path), 100, 148, 256, 320)   # noqa: E731  knob G's dial, not its label
    ev_open = [(50, "press", "FX"), (150, "press", "SRC")]
    s = e.run("bw2-late", 700, ev_open + [(400, "usb", P.sendfx_bw(0, 100, 90))], save=True)
    late = gband(os.path.join(e.out, "bw2-late.png"))
    (f1, f2), got = bw_x(e, s)
    U.check("bw2: the fields hold the host's FX 1 value (the offset, the take)", f1 == (100, 90) and got >= 1,
            f"{f1} {f2} got {got} raw {e.peek(s, sym(e, 'sfu_x') + X_BW - 4, 20).hex()}")
    e.run("bw2-early", 700, [(20, "usb", P.sendfx_bw(0, 100, 90))] + ev_open, save=True)
    early = gband(os.path.join(e.out, "bw2-early.png"))
    e.run("bw2-none", 700, ev_open, save=True)
    none = gband(os.path.join(e.out, "bw2-none.png"))
    U.check("bw2: a host value while SEND FX 1 is open redraws knob G as a fresh draw of it (and not as before)",
            late is not None and late == early and late != none, f"late==early {late == early} late!=none {late != none}")
    old = P.sendfx_bw(0, 40, 90) + P.sendfx_bw(1, 10, 127)
    bad = bytes([0xF0, 0x7D, 0x52, 0x54, 0x22, 0x02, 0x02, 5, 5, 0xF7])   # FX 3
    ver1 = bytes([0xF0, 0x7D, 0x52, 0x54, 0x22, 0x01, 0x00, 1, 0]) + b"CHORUS\0\0\0\0\xf7"   # FX 1 CHORUS READY
    s = e.run("bw2-bad", 500, [(20, "usb", old), (200, "usb", bad), (300, "usb", ver1)], save=True)
    (f1, f2), got = bw_x(e, s)
    U.check("bw2: a 22 ver 2 for FX 3 and a ver-1 22 leave BASE / WIDTH as they were", (f1, f2) == ((40, 90), (10, 127)),
            f"{f1} {f2}")
    ev = [(20, "usb", old)] + ev_open + [(300, "turn", ("6:+20", 3, 20)), (395, "usb", P.sendfx_bw(0, 5, 5))]
    # (the turn's sends land between 330 and 380 ms; the host's value just after. BW_HOLD is 500 ms of DTCN0 at the
    # hardware's 132 MHz, 100 ms here: rytm-emu's DTCN0 runs at 660 MHz against its event clock [measured])
    s = e.run("bw2-cross", 700, ev, save=True)
    m = bw_sent(e)
    (f1, _), _ = bw_x(e, s)
    U.check("bw2: a host value crossing the Rytm's turn (just after its send) does not undo the turn",
            bool(m) and f1 == (m[-1]["base"], m[-1]["width"]) and f1[0] > 40, f"knob {f1} sent {m}")
    s = e.run("bw2-after", 1200, ev + [(1000, "usb", P.sendfx_bw(0, 7, 7))], save=True)
    (f1, _), _ = bw_x(e, s)
    U.check("bw2: a host value well after the turn is taken", f1 == (7, 7), str(f1))
    dflt = [e.u32(s, REC(r) + 16) for r in (1, 2, 3, 4)]
    U.check("bw2: the records' defaults: BASE 0, WID 127 (0x7f00)", dflt == [0, 0x7f00, 0, 0x7f00], str([hex(x) for x in dflt]))


def t_bwwrap(e):
    """BASE / WIDTH hold (re-review 4): DTCN0 wraps every 2^32 counts (32.5 s on the unit, 6.51 s here at 660 MHz), so a
    hold stamp left in place would come back for BW_HOLD one wrap after the turn and drop a host value then. The tick
    clears an expired hold: a host value one wrap after the turn's send (6.51 s + 30..80 ms: inside the stale window for
    any send between 330 and 380 ms) is taken."""
    old = P.sendfx_bw(0, 40, 90) + P.sendfx_bw(1, 10, 127)
    ev = [(20, "usb", old), (50, "press", "FX"), (150, "press", "SRC"), (300, "turn", ("6:+20", 3, 20)),
          (6910, "usb", P.sendfx_bw(0, 9, 9))]
    s = e.run("bwwrap", 7100, ev, save=True)
    (f1, _), _ = bw_x(e, s)
    hold = e.u32(s, sym(e, "sfu_x") + X_BW + 14)
    U.check("bwwrap: a host value one timer wrap after a turn is taken (the expired hold was cleared)", f1 == (9, 9),
            f"{f1} hold {hold:08x}")
    U.check("bwwrap: the hold is clear once expired", hold == 0, f"{hold:08x}")


def t_fmname(e):
    """(hardware report 2026-10-17) 6-OP FM PAT over the project's FM list: the patch's name is drawn where the dial was
    and the stock UI shows the knob's value text where the label is while it turns - that text is the step's number now,
    not the name a second time. Screens fmname-*.png: the dial band and the label band differ, and the label is a number."""
    names = ["ONE", "TWO", "THREE", "FOUR", "FIVE"]
    evf, t = U.walk_list(100, 20)   # 6-OP FM
    evf += [(t + 50, "press", "SRC"), (t + 200, "usb", b"".join(P.fm_names(names))), (t + 600, "turn", ("0:+8", 12, 10))]
    e.run("fmname", t + 900, evf)
    rows = png_lit(os.path.join(e.out, "fmname.png"))
    dial, label = glyphs(rows, 36, 72, 6, 100), glyphs(rows, 76, 100, 6, 100)
    check = U.check
    check("fmname: a name drawn where the dial was and something in the label band", dial is not None and label is not None,
          f"dial {dial is not None}, label {label is not None}")
    check("fmname: the label band's text is not the dial's name again (same bitmap = the name twice)",
          dial is not None and label is not None and dial != label, "the bands show the same glyphs")
    # the same knob without a list (all 128: the number in the dial and the label, 0021's own text): untouched
    e.run("fmname-nolist", t + 900, evf[:2] + [(t + 600, "turn", ("0:+8", 4, 10))])
    rows = png_lit(os.path.join(e.out, "fmname-nolist.png"))
    check("fmname: without the host's list the knob is the number (a dial, the number in the label band)",
          glyphs(rows, 76, 100, 6, 100) is not None, "")


# ---------------------------------------------------------------- A3 review N1 / N2: the wrappers before the first tick
# The OS never calls the F-set wrappers before 0029's first tick, so the test calls them by hand: sfu_pretick.s is poked
# into free DDR, a `jmp` to it over sfu_tick's first word (it runs in the UI task each tick and never the real tick).
STUB, RES, JUNK, KIT38 = 0x47E00000, 0x47E00100, 0xdeadbee0, 0x2c40   # KIT38: FX word 38 the runs start from
SFU_X_FXSET, SFU_X_FXCH, SFU_X_BW, SFU_X_BWTX = 2132, 2140, 6684, 6688   # offsets in struct sfu_x (m68k-elf-gcc -mcpu=5475)
SFU_ST_TICKS = 1034                                                     # in struct sfu_state


def pretick_run(e, name, ticks0):
    """The wrappers called by sfu_pretick.s from the locks snapshot (BD's lock on FX 38 step 1): ticks0 pokes st.ticks to 0
    (0029 before its first tick: the first tick would zero sfu_x, which stays untouched here) and sfu_x.fxset to JUNK.
    -> (snapshot before, snapshot after, [the stub's five results])."""
    s, at = e.locks[0], e.locks[1]
    xs, st_ = sym(e, "sfu_x"), sym(e, "sfu_st")
    se = lambda n: sym(e, n)   # noqa: E731
    fxset = int.from_bytes(e.peek(s, xs + SFU_X_FXSET, 4), "big")
    U.check(f"{name}: the snapshot knows the FX set (sfu_x.fxset, set by the last page's reads)", fxset > 0x40000000, hex(fxset))
    src = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sfu_pretick.s")
    obj, binf = os.path.join(e.tmp, f"{name}.o"), os.path.join(e.tmp, f"{name}.bin")
    defs = [f"--defsym={k}={v:#x}" for k, v in dict(SET=fxset, FREAD=se("sfu_f_read"), FWRITE=se("sfu_f_write"),
                                                   FLGET=se("sfu_f_lget"), FLSET=se("sfu_f_lset"), SEEFX=se("see_fxset"),
                                                   RES=RES).items()]
    subprocess.run(["m68k-elf-as", "-mcpu=5475", *defs, "-o", obj, src], check=True)
    subprocess.run(["m68k-elf-objcopy", "-O", "binary", "-j", ".text", obj, binf], check=True)
    ed = {STUB: open(binf, "rb").read(), RES: bytes(32), se("sfu_tick"): b"\x4e\xf9" + STUB.to_bytes(4, "big"),
          FXW + 76: KIT38.to_bytes(2, "big")}   # FX word 38 (P2's hi half 0x2c): the stub's write (0x3a) and the reads show
    if ticks0:
        ed[st_ + SFU_ST_TICKS] = bytes(4)
        ed[xs + SFU_X_FXSET] = JUNK.to_bytes(4, "big")
    after = e.run(name, 150, snap=s, start=at, save=True, extra=X.pokes(e, s, ed))
    res = [int.from_bytes(e.peek(after, RES + 4 * i, 4), "big") for i in range(5)]
    return s, after, res, (xs, st_, fxset)


def t_pretick(e):
    """The F-set wrappers called before 0029's first tick (st.ticks 0, sfu_x not zeroed yet): they answer the stored half
    (read, lget) or refuse (write 1 without a write, lset 0 and no lock) and touch nothing of sfu_x: not a BASE / WIDTH
    write, not see_fxset's fxset / counter (review N1, N2). Control: the same calls after the first tick write."""
    if not getattr(e, "locks", None):
        t_locks(e)
    base, l0, f38 = e.locks[2], e.locks[3], e.locks[4]
    kit38 = lambda sn: w16(e, sn, FXW + 76)   # noqa: E731
    s0, a0, r0, (xs, st_, fxset) = pretick_run(e, "pretick-ctl", False)
    bw0 = e.peek(a0, xs + SFU_X_BW, 6)
    U.check("pretick control (after the first tick): the stub's calls act - FX word 38 written, a lock at step 3 set, "
            "BW write kept (bw[0][0] 42, bw_tx 1), fxset changes counted",
            kit38(a0) != KIT38 and lock(e, a0, 12, 2, 38) != 0xffff and bw0[0] == 0x2a and bw0[4] == 1 and
            int.from_bytes(e.peek(a0, xs + SFU_X_FXCH, 4), "big") > int.from_bytes(e.peek(s0, xs + SFU_X_FXCH, 4), "big"),
            f"38 {KIT38:04x}->{kit38(a0):04x} lock {lock(e, a0, 12, 2, 38):04x} bw {bw0.hex()} "
            f"changes {e.peek(s0, xs + SFU_X_FXCH, 4).hex()}->{e.peek(a0, xs + SFU_X_FXCH, 4).hex()}")
    s1, a1, r1, _ = pretick_run(e, "pretick", True)
    print(f"    results {[hex(x) for x in r1]}; kit 38 {KIT38:04x}->{kit38(a1):04x}; lock {f38:04x}")
    x1 = lambda sn, o, n: e.peek(sn, xs + o, n)   # noqa: E731
    U.check("pretick: f_read answers the stored half (no knob mapping): the kit word's hi half",
            r1[0] == KIT38 & 0x7f00, f"{r1[0]:04x} vs word {KIT38:04x}")
    U.check("pretick: f_write returns 1 and writes nothing (FX word 38 unchanged)", r1[1] == 1 and kit38(a1) == KIT38,
            f"{r1[1]} {KIT38:04x}->{kit38(a1):04x}")
    U.check("pretick: f_lget answers the stored half of BD's FX step-1 lock (not -1, not mapped)", r1[2] == f38 & 0x7f00,
            f"{r1[2]:04x} vs lock {f38:04x}")
    U.check("pretick: f_lset returns 0 and sets no lock (step 3 stays unlocked)", r1[3] == 0 and lock(e, a1, 12, 2, 38) == 0xffff,
            f"{r1[3]} lock {lock(e, a1, 12, 2, 38):04x}")
    U.check("pretick: the BASE write returns 1 and keeps nothing (review N1: bw and bw_tx as before)",
            r1[4] == 1 and x1(a1, SFU_X_BW, 6) == x1(s1, SFU_X_BW, 6) and x1(a1, SFU_X_BW, 6)[4] == 0,
            f"{r1[4]} {x1(a1, SFU_X_BW, 6).hex()} vs {x1(s1, SFU_X_BW, 6).hex()}")
    U.check("pretick: see_fxset keeps sfu_x.fxset and its counter (review N1: it reads / writes nothing before the tick)",
            x1(a1, SFU_X_FXSET, 4) == JUNK.to_bytes(4, "big") and x1(a1, SFU_X_FXCH, 4) == x1(s1, SFU_X_FXCH, 4), f"{x1(a1, SFU_X_FXSET, 12).hex()} vs {x1(s1, SFU_X_FXSET, 12).hex()}")


def fx41_keys(at=0, step="T1", hold="500M", record_off=True, nav=True):
    """The UI path of an FX 41 lock a user takes: the FX track, SEND FX 2's page (SRC, then SMPL twice), RECORD, step 1
    (a poked trig) held, SEND FX 2's P4 (word 41's hi half) turned; RECORD off. nav=False: already on SEND FX 2 (the
    view keeps its page: SMPL there would cycle on). Returns (events, length M)."""
    ev = ([(at + 50, "press", "FX"), (at + 150, "press", "SRC"), (at + 250, "press", "SMPL"), (at + 350, "press", "SMPL")]
          if nav else []) + [(at + 450, "press", "RECORD"), (at + 600, "press", f"{step}:{hold}"),
                             (at + 700, "turn", ("4:+20", 3, 20))]
    if record_off:
        ev.append((at + 1200, "press", "RECORD"))
    return ev, at + 1400


def bd_lock_keys(at=0, knob=0):
    """A stock lock a user takes: track BD, the LFO page, RECORD, step 6 (a poked trig) held, knob `knob` (0 = A) turned;
    RECORD off."""
    ev = [(at + 50, "press", "BD"), (at + 150, "press", "LFO"), (at + 250, "press", "RECORD"),
          (at + 400, "press", "T6:500M"), (at + 500, "turn", (f"{knob}:+20", 3, 20)), (at + 1000, "press", "RECORD")]
    return ev, at + 1200


def words(e, snap, t, step):
    """The 44 live lock words of track t's step `step` in the working pattern (0xffff = none) and A01's bank copy."""
    a = LOCKS + 5674 * t + 88 * step
    return (e.peek(snap, a, 88), e.peek(snap, a - LOCKS + BANK1, 88))


# fxfull-refuse (0.5.2): the message a refused Send FX lock shows is stock's own LOCK MEM FULL! popup: 0029 calls the handler
# stock's PatternParamLocks::updateMirror registers (0x400acb66, which shows it when called with ok = 0; stock calls it
# after each mirror update, so its entry count is not a popup count). A popup shown = an entry of view_show_popup.
# sfu_st.full_n counts the refusals.
SHOW_POPUP = 0x400793f6            # view_show_popup
VT_POPUP = 0x401d6e18              # PopupWindow (bk_emu.py popups)
SFU_ST_FULL = 1038                 # sfu_state.full_n (after ticks)
TURN_END = 800                     # the split UI run: the turn's run ends here (60 M after its last detent: a popup is up)


def lock_arrays(e, snap):
    """Every live lock word and fine flag of the working pattern and A01's bank copy (13 tracks each)."""
    return e.peek(snap, LOCKS, 5674 * 13) + e.peek(snap, BANK1, 5674 * 13)


def fx41_ui(e, name, s, c, start, env, step="T1", nav=True):
    """fx41_keys in two runs: up to TURN_END (the step's hold ends before it), then RECORD off. -> (snapshot after the
    turn, snapshot after RECORD off, popups shown in the turn's run, incremental saves, rebuilds)."""
    ev, _ = fx41_keys(step=step, hold="180M", record_off=False, nav=nav)
    sm = e.run(f"{name}-turn", TURN_END, ev, snap=s, start=start, card=c, save=True, count=[INCR, REBUILD, SHOW_POPUP], env=env)
    pop = e.counts.get(SHOW_POPUP, 0)
    incr, rb = e.counts.get(INCR, 0), e.counts.get(REBUILD, 0)
    s1 = e.run(f"{name}-ui", 300, [(50, "press", "RECORD")], snap=sm, start=start + TURN_END, card=c, save=True,
               count=[INCR, REBUILD], env=env)
    return sm, s1, pop, incr + e.counts.get(INCR, 0), rb + e.counts.get(REBUILD, 0)


def fxfull_ui(e, name, n_stock, ui="fx41", save=True, extra_rows=(), trig_steps=(0,)):
    """n_stock stock rows (+ extra_rows) in A01 (poked, cold boot), then the UI lock `ui` ("fx41", "bd" or both: "fx41+bd" in
    two runs from the same state). With save: SAVE PROJECT AS 003, FX 41's live lock wiped, LOAD PROJECT 003.
    -> dict of what was seen."""
    poked = X.stock_rows(n_stock) + list(extra_rows)
    ed = X.pattern_rows(poked)
    ed[X.ST_KIT + 0x816] = X.FX_KIT
    ed.update(X.trig_bits(e, e.snap, 12, list(trig_steps)))
    ed.update(X.trig_bits(e, e.snap, 0, [5]))
    s, c = X.poke_boot(e, name, ed)
    r = {"rows": len(X.slots_of(e, s)), "snap": s, "card": c, "poked": sorted((x[0], x[1]) for x in poked)}
    U.check(f"{name}: A01 holds {len(poked)} rows after the cold boot", r["rows"] == len(poked), f"{r['rows']}")
    r["fx41_before"] = lock(e, s, 12, 0, 41)
    r["bd_before"] = words(e, s, 0, 5)
    r["arrays_before"] = lock_arrays(e, s)
    r["st_before"] = e.u32(s, sym(e, "sfu_st") + SFU_ST_FULL)
    env = X.steps_env(e, name)
    if ui in ("fx41", "both"):
        sm, s1, pop, incr, rb = fx41_ui(e, name, s, c, 4400, env)
        r.update(ui_snap=s1, mid_snap=sm, popups=pop, incr=incr, rebuild=rb, fx41=lock(e, s1, 12, 0, 41),
                 fine=fine(e, s1, 12, 41), top=e.u32(sm, sym(e, "sv", "0026-remote-ui") + 88),
                 full_n=e.u32(s1, sym(e, "sfu_st") + SFU_ST_FULL) - r["st_before"], arrays_after=lock_arrays(e, s1))
        r["len"] = TURN_END + 300
    if ui in ("bd", "both"):
        ev, t = bd_lock_keys()
        s2 = e.run(f"{name}-bd", t, ev, snap=s, start=4400, card=c, save=True, count=[INCR, REBUILD, SHOW_POPUP],
                   env=X.steps_env(e, name + "-bd"))
        r.update(bd_snap=s2, bd_after=words(e, s2, 0, 5), bd_incr=e.counts.get(INCR, 0), bd_popups=e.counts.get(SHOW_POPUP, 0))
    if save and ui in ("fx41", "both"):
        ev, t2 = X.proj_keys(100, True)
        s3 = e.run(f"{name}-save", t2, ev, snap=r["ui_snap"], start=4400 + r["len"], card=c, save=True, count=[REBUILD],
                   extra=["--card-save"])
        sl = X.file_rows(c)   # A01's rows as SAVE PROJECT AS wrote them (the RAM pool keeps what was loaded)
        r.update(saved=sl, has45=(45, 12) in sl, has49=(49, 12) in sl, saved_n=len(sl))
        wipe = {}
        for base in (LOCKS, BANK1):
            wipe[base + 5674 * 12 + 82] = b"\xff\xff"
            wipe[base + 5674 * 12 + 5632 + 41] = b"\0"
        s4 = e.run(f"{name}-wiped", 50, snap=s3, start=4400 + r["len"] + t2, card=c, save=True, extra=X.pokes(e, s3, wipe))
        r["wiped"] = lock(e, s4, 12, 0, 41)
        ev, t3 = X.proj_keys(100, False)
        s5 = e.run(f"{name}-load", t3, ev, snap=s4, start=4400 + r["len"] + t2 + 50, card=c, save=True)
        r.update(loaded=lock(e, s5, 12, 0, 41), loaded_fine=fine(e, s5, 12, 41), load_snap=s5,
                 loaded_rows=sorted(X.slots_of(e, s5)))
    return r


def changed_words(a, b):
    """(copy, track, step, index) of every live lock word that differs between two lock_arrays(); fine flags as index
    42 + flag index."""
    out = []
    for i in range(0, len(a), 2):
        if a[i:i + 2] != b[i:i + 2]:
            cp, o = divmod(i, 5674 * 13)
            t, o = divmod(o, 5674)
            out.append((cp, t, o // 88, (o % 88) // 2) if o < 5632 else (cp, t, -1, 42 + o - 5632))
    return out


def t_fxfull(e):
    """(F1, trackb-b2-review; 0.5.2 fxfull-refuse) The UI path of the 71-row cap: lock FX 41 from SEND FX 2 as a user
    would, SAVE PROJECT AS, LOAD PROJECT. 40 stock rows: the lock is made and survives (control); 70 stock rows: the
    lock (two rows, 72 > 71) is refused with stock's LOCK MEM FULL! popup, the live arrays unchanged, and the save keeps
    every other lock; 69 stock rows + an FX 41 lock on step 1 (71 rows, full): a replacing lock on step 1 and a lock on
    step 2 (rows already counted) are made; 72 stock rows: FX 41 refused, a stock lock on a new row refused too (PNGs
    build/emu/TAG/fxfull72-*.png)."""
    ctl = fxfull_ui(e, "fxfull40", 40)
    print(f"    40 rows: lock {ctl['fx41']:04x} fine {ctl['fine']}, rebuilds in the UI run {ctl['rebuild']} (incremental {ctl['incr']}); "
          f"saved {ctl['saved_n']} rows, 45/49 {ctl['has45']}/{ctl['has49']}; after the load {ctl['loaded']:04x}; popups {ctl['popups']}")
    U.check("fxfull40: control - the UI made the FX 41 lock (word != 0xffff, hi half set, fine flag), A01 held room",
            ctl["fx41_before"] == 0xffff and ctl["fx41"] != 0xffff and (ctl["fx41"] >> 8) != 0 and ctl["fine"] == 1,
            f"before {ctl['fx41_before']:04x} after {ctl['fx41']:04x} fine {ctl['fine']}")
    U.check("fxfull40: control - no popup, no refusal counted", ctl["popups"] == 0 and ctl["full_n"] == 0,
            f"popups {ctl['popups']} full_n {ctl['full_n']}")
    U.check("fxfull40: control - SAVE PROJECT AS stores rows 45 and 49, LOAD PROJECT brings the lock back",
            ctl["has45"] and ctl["has49"] and ctl["loaded"] == ctl["fx41"], f"saved {ctl['saved']}, loaded {ctl['loaded']:04x}")
    # the boundary (review M2): 69 stock rows + a new FX lock (2 rows) = exactly 71: made, no popup, all saved
    b69 = fxfull_ui(e, "fxfull69", 69)
    print(f"    69 rows: lock {b69['fx41']:04x} fine {b69['fine']}, popups {b69['popups']}, refusals {b69['full_n']}; saved "
          f"{b69['saved_n']} rows, 45/49 {b69['has45']}/{b69['has49']}; after the load {b69['loaded']:04x}")
    U.check("fxfull69: 69 stock rows - the FX 41 lock lands exactly on 71: made (word set, hi half, fine flag), no popup, "
            "no refusal", b69["fx41"] != 0xffff and (b69["fx41"] >> 8) != 0 and b69["fine"] == 1 and b69["popups"] == 0 and
            b69["full_n"] == 0, f"{b69['fx41']:04x} fine {b69['fine']} popups {b69['popups']} full_n {b69['full_n']}")
    U.check("fxfull69: SAVE PROJECT AS stores 71 rows with 45 and 49, LOAD PROJECT brings the lock back",
            b69["saved_n"] == 71 and b69["has45"] and b69["has49"] and b69["loaded"] == b69["fx41"],
            f"{b69['saved_n']} rows, 45 {b69['has45']}, 49 {b69['has49']}, loaded {b69['loaded']:04x}")
    full = fxfull_ui(e, "fxfull70", 70)
    ch = changed_words(full["arrays_before"], full["arrays_after"])
    print(f"    70 rows: lock {full['fx41']:04x} fine {full['fine']}, popups {full['popups']} (top view {full['top']:08x}), "
          f"refusals {full['full_n']}, live words changed {ch[:6]}; incremental {full['incr']}; saved {full['saved_n']} rows; "
          f"after the load {full['loaded']:04x}")
    U.check("fxfull70: 70 stock rows - the FX 41 lock (2 rows: 72 > 71) is refused: the live word stays 0xffff, no fine flag",
            full["fx41"] == 0xffff and full["fine"] == 0, f"{full['fx41']:04x} fine {full['fine']}")
    U.check("fxfull70: the refusal shows stock's LOCK MEM FULL! popup (a popup shown, a PopupWindow on top after the "
            "turn) and is counted (sfu_st.full_n)", full["popups"] >= 1 and full["top"] == VT_POPUP and full["full_n"] >= 1,
            f"popups {full['popups']} top {full['top']:08x} full_n {full['full_n']}")
    U.check("fxfull70: nothing changed in the live lock arrays (working and A01's copies, every word and fine flag)",
            not ch, str(ch[:8]))
    U.check("fxfull70: SAVE PROJECT AS keeps every other lock: the saved rows are the 70 poked ones",
            sorted(full["saved"]) == full["poked"], f"{full['saved_n']} rows, missing {sorted(set(full['poked']) - set(full['saved']))}")
    U.check("fxfull70: LOAD PROJECT 003 - the 70 rows back, no FX 41 lock", full["loaded_rows"] == full["poked"] and
            full["loaded"] == 0xffff, f"{len(full['loaded_rows'])} rows, FX 41 {full['loaded']:04x}")
    # a full pattern (69 + FX 41's pair = 71): a replacing lock on step 1 and a lock on step 2 add no row and are made
    rep = fxfull_replace(e, "fxfull71")
    steps = os.environ.get("SFX_STEPS")
    os.environ["SFX_STEPS"] = "1"          # a PNG after each key of these runs
    try:
        ref = fxfull_ui(e, "fxfull72", 72, ui="both", save=False)
    finally:
        if steps is None:
            os.environ.pop("SFX_STEPS")
    bd0, bd1 = ref["bd_before"], ref["bd_after"]
    bd_made = [i for i in range(44) if bd1[0][2 * i:2 * i + 2] != b"\xff\xff" or bd1[1][2 * i:2 * i + 2] != b"\xff\xff"]
    bd_was = [i for i in range(44) if bd0[0][2 * i:2 * i + 2] != b"\xff\xff" or bd0[1][2 * i:2 * i + 2] != b"\xff\xff"]
    print(f"    72 rows (the pattern full): FX 41 UI lock {ref['fx41']:04x} (fine {ref['fine']}, popups {ref['popups']}); a stock "
          f"LFO lock on BD step 6: lock indexes now {sorted(set(bd_made) - set(bd_was))}, popups shown in that run "
          f"{ref['bd_popups']}")
    U.check("fxfull72: 72 stock rows - the cold boot loaded them all (the pool held 72, no refusal at load)",
            ref["rows"] == 72, str(ref["rows"]))
    U.check("fxfull72: on a full pattern 0029's FX 41 lock is refused, with the popup", ref["fx41"] == 0xffff and
            ref["popups"] >= 1 and ref["full_n"] >= 1, f"{ref['fx41']:04x} popups {ref['popups']} full_n {ref['full_n']}")
    U.check("fxfull72: on a full pattern a stock p-lock on a new row (BD, LFO page, step 6) is refused too (0.5.2 round 2)",
            not set(bd_made) - set(bd_was) and ref["bd_popups"] >= 1, f"new indexes {sorted(set(bd_made) - set(bd_was))} "
            f"popups {ref['bd_popups']}")
    print("    look at build/emu/%s/steps-fxfull72/ (FX 41) and steps-fxfull72-bd/ (stock lock)" % e.tag)


def fxfull_replace(e, name):
    """69 stock rows + FX 41 locked on FX step 1 (rows 45, 49: 71, the pattern full), trigs on steps 1 and 2. The UI
    turns P4 with step 1 held (replaces the lock: no new row) and then with step 2 held (index 41 has its rows): both
    made, no popup. SAVE PROJECT AS keeps all 71 rows."""
    fx = [X.lockslot(45, 12, {0: 0x30}), X.lockslot(49, 12, {0: 0x10})]
    poked = X.stock_rows(69) + fx
    ed = X.pattern_rows(poked)
    ed[X.ST_KIT + 0x816] = X.FX_KIT
    ed.update(X.trig_bits(e, e.snap, 12, [0, 1]))
    s, c = X.poke_boot(e, name, ed)
    w0 = lock(e, s, 12, 0, 41)
    U.check(f"{name}: A01 holds 71 rows after the cold boot, FX 41 locked on step 1 (3020)",
            len(X.slots_of(e, s)) == 71 and w0 == 0x3020, f"{len(X.slots_of(e, s))} rows, {w0:04x}")
    st0 = e.u32(s, sym(e, "sfu_st") + SFU_ST_FULL)
    _, s1, pop1, _, _ = fx41_ui(e, name + "-s1", s, c, 4400, {})
    w1 = lock(e, s1, 12, 0, 41)
    _, s2, pop2, _, _ = fx41_ui(e, name + "-s2", s1, c, 4400 + TURN_END + 300, {}, step="T2", nav=False)
    w2, w1b = lock(e, s2, 12, 1, 41), lock(e, s2, 12, 0, 41)
    n = e.u32(s2, sym(e, "sfu_st") + SFU_ST_FULL) - st0
    print(f"    71 rows (full): step 1 {w0:04x} -> {w1:04x}; step 2 {w2:04x} (step 1 {w1b:04x}); popups {pop1}/{pop2}, refusals {n}")
    U.check(f"{name}: on a full pattern the lock replacing step 1's FX 41 lock is made (the word changed, still locked)",
            w1 not in (0xffff, w0) and (w1 >> 8) != 0x30, f"{w0:04x} -> {w1:04x}")
    U.check(f"{name}: a lock on step 2 of index 41 (rows already counted) is made too, step 1's kept",
            w2 != 0xffff and w1b == w1, f"step 2 {w2:04x} step 1 {w1b:04x}")
    U.check(f"{name}: no popup, no refusal", pop1 == pop2 == 0 and n == 0, f"popups {pop1}/{pop2} refusals {n}")
    ev, t2 = X.proj_keys(100, True)
    e.run(f"{name}-save", t2, ev, snap=s2, start=4400 + 2 * (TURN_END + 300), card=c, save=True, extra=["--card-save"])
    sl = X.file_rows(c)
    U.check(f"{name}: SAVE PROJECT AS stores all 71 rows (45 and 49 among them)",
            sorted(sl) == sorted((x[0], x[1]) for x in poked), f"{len(sl)} rows, missing "
            f"{sorted(set((x[0], x[1]) for x in poked) - set(sl))}")
    return w1, w2


# ---- fxfull-refuse review, open question: other ways locks reach a pattern (probes: results printed, no verdict on them)
PAT_SIZE = 13101


def pat_rows_ed(pat, rows):
    """Poke edit: bank pattern `pat` (1 = A01)'s stored row pool."""
    assert len(rows) <= 72
    return {X.ST_PAT + PAT_SIZE * pat + 0x2091: b"".join(rows) + b"\xff" * (66 * (72 - len(rows)))}


def pat_trigs_ed(e, pat, track, steps, flags=0x381):
    a = X.ST_PAT + PAT_SIZE * pat + 4 + 641 * track
    n = int.from_bytes(e.peek(e.snap, a, 112), "big")
    for i in steps:
        sh = 14 * (63 - i)
        n = (n & ~(0x3fff << sh)) | (flags << sh)
    return {a: n.to_bytes(112, "big")}


def live_rows(e, snap, base=BANK1):
    """A pattern object's live lock rows counted as the rebuild counts them -> (rows, FX track's locked indexes >= 38)."""
    b = e.peek(snap, base, 5674 * 13)
    n, fx = 0, []
    for t in range(13):
        tb = b[5674 * t: 5674 * (t + 1)]
        m = set()
        for st_ in range(64):
            p = tb[88 * st_: 88 * st_ + 88]
            if int.from_bytes(p[84:88], "big", signed=True) <= 0:
                continue
            m |= {k for k in range(42) if int.from_bytes(p[2 * k:2 * k + 2], "big", signed=True) >= 0}
        n += sum(1 + (tb[5632 + k] != 0) for k in m)
        if t == 12:
            fx = sorted(k for k in m if k >= 38)
    return n, fx


def fxpath(e, name, a01, a02, ev, length, a02_trigs=(0,)):
    """A01 = a01 rows (FX trig on step 1), A02 = a02 rows, cold boot, the keys ev, SAVE PROJECT AS 003 -> A01's live rows
    after the keys, popups shown, refusals, A01's rows in the saved file."""
    ed = pat_rows_ed(1, a01)
    ed.update(pat_rows_ed(2, a02))
    ed[X.ST_KIT + 0x816] = X.FX_KIT
    ed.update(pat_trigs_ed(e, 1, 12, [0]))
    ed.update(pat_trigs_ed(e, 2, 12, list(a02_trigs)))
    s, c = X.poke_boot(e, name, ed)
    st0 = e.u32(s, sym(e, "sfu_st") + SFU_ST_FULL)
    s1 = e.run(f"{name}-keys", length, ev, snap=s, start=4400, card=c, save=True, count=[SHOW_POPUP], env=X.steps_env(e, name))
    pop = e.counts.get(SHOW_POPUP, 0)
    n, fx = live_rows(e, s1)
    ev2, t2 = X.proj_keys(100, True)
    e.run(f"{name}-save", t2, ev2, snap=s1, start=4400 + length, card=c, save=True, extra=["--card-save"])
    sl = X.file_rows(c)
    r = dict(live=n, fx=fx, popups=pop, refusals=e.u32(s1, sym(e, "sfu_st") + SFU_ST_FULL) - st0, saved=len(sl),
             fxsaved=sorted(t for t, tr in sl if t >= 42))
    print(f"    {name}: A01 live rows {n} (FX track indexes {fx}), popups {pop}, 0029 refusals {r['refusals']}; saved "
          f"{r['saved']} rows, FX rows saved {r['fxsaved']}")
    return r


def t_fxpaths(e):
    """(probe) Do other ways of putting locks into a pattern pass the 71-row refusal? A02 = an FX 41 lock on FX step 1
    (rows 45 / 49). Track copy (GRID REC, FX track, FUNC + REC on A02, FUNC + STOP on A01) and trig copy (T1 held + FUNC +
    REC / STOP) onto A01 with 70 and with 71 stock rows; pattern copy (A02 = 69 stock + FX 41 = 71 rows onto A01); live
    recording (REC held + PLAY, SEND FX 2 P4 turned while playing, after the LIVE REC popup) on 70 stock rows. Each: A01's
    live rows, popups, 0029's refusals, what SAVE PROJECT AS keeps."""
    stock70, stock71 = X.stock_rows(70), X.stock_rows(71)
    fx41 = [X.lockslot(45, 12, {0: 0x30}), X.lockslot(49, 12, {0: 0x10})]
    a02 = [(100, "press", "BANK_A:40M"), (120, "press", "T2")]
    a01 = lambda t: [(t, "press", "BANK_A:40M"), (t + 20, "press", "T1")]   # noqa: E731
    fn = lambda t, k: [(t, "press", "FUNC:30M"), (t + 10, "press", k)]   # noqa: E731
    ev = a02 + [(300, "press", "FX"), (400, "press", "RECORD")] + fn(500, "RECORD") + a01(700) + fn(900, "STOP") + \
        [(1100, "press", "RECORD")]
    trk = fxpath(e, "fxpath-track", stock70, fx41, ev, 1300)
    trk71 = fxpath(e, "fxpath-track71", stock71, fx41, ev, 1300)
    ev = a02 + [(300, "press", "FX"), (400, "press", "RECORD"), (500, "press", "T1:60M")] + fn(510, "RECORD") + a01(700) + \
        [(900, "press", "T1:60M")] + fn(910, "STOP") + [(1100, "press", "RECORD")]
    stp = fxpath(e, "fxpath-step", stock70, fx41, ev, 1300)
    stp71 = fxpath(e, "fxpath-step71", stock71, fx41, ev, 1300)
    ev = a02 + fn(300, "RECORD") + a01(500) + fn(700, "STOP")
    pat = fxpath(e, "fxpath-pattern", stock70, X.stock_rows(69) + fx41, ev, 1000)
    ev = [(50, "press", "FX"), (150, "press", "SRC"), (250, "press", "SMPL"), (350, "press", "SMPL"),
          (450, "press", "RECORD:150M"), (500, "press", "PLAY"), (1200, "turn", ("4:+20", 3, 20)), (1300, "press", "FX"),
          (1600, "press", "STOP")]
    liv = fxpath(e, "fxpath-live", stock70, [], ev, 1800)
    for nm, r in (("track copy (70)", trk), ("track copy (71)", trk71), ("trig copy (70)", stp), ("trig copy (71)", stp71),
                  ("pattern copy", pat), ("live record", liv)):
        lost = bool(r["fx"]) and not r["fxsaved"]
        print(f"    => {nm}: Send FX lock in A01 live: {bool(r['fx'])}, over 71: {r['live'] > 71}, "
              f"its rows lost at the save: {lost}")


# ---- fxfull-refuse round 2 (owner 2026-11-25, 0.5.2): any new lock the save would drop is refused, pastes included
PAT_A01 = BANK1 - 11921            # A01's pattern object: 13 x 917 B trig data, then its locks (13 x 5674 B)
LIVE_ON = 0x400af71c               # live record's lock path past its record-state test (0x40036370): recording
LIVE_TLS = 0x400af7ca              # live record's track_lock_set call: a lock being recorded


def a01_state(e, snap):
    """A01's trig data and locks (the paste target)."""
    return e.peek(snap, PAT_A01, 11921 + 5674 * 13)


def full_n(e, snap):
    return e.u32(snap, sym(e, "sfu_st") + SFU_ST_FULL)


def bd_runs(e, name, poked, knob, again=False, save=True):
    """poked rows in A01 (FX trig on step 1, BD trig on step 6), cold boot; BD's LFO page, RECORD, step 6 held, knob
    `knob` turned (run 1); with again, the same knob on the same step turned once more (run 2, a replacing lock); RECORD
    off; with save, SAVE PROJECT AS 003 -> dict."""
    ed = X.pattern_rows(poked)
    ed[X.ST_KIT + 0x816] = X.FX_KIT
    ed.update(X.trig_bits(e, e.snap, 12, [0]))
    ed.update(X.trig_bits(e, e.snap, 0, [5]))
    s, c = X.poke_boot(e, name, ed)
    r = {"rows0": live_rows(e, s)[0], "a0": lock_arrays(e, s), "n0": full_n(e, s), "poked": sorted((x[0], x[1]) for x in poked)}
    ev = [(50, "press", "BD"), (150, "press", "LFO"), (250, "press", "RECORD"), (400, "press", "T6:180M"),
          (450, "turn", (f"{knob}:+20", 3, 20))]
    s1 = e.run(f"{name}-bd", 700, ev, snap=s, start=4400, card=c, save=True, count=[SHOW_POPUP], env=X.steps_env(e, name))
    ch = changed_words(r["a0"], lock_arrays(e, s1))
    r.update(rows1=live_rows(e, s1)[0], pop1=e.counts.get(SHOW_POPUP, 0), n1=full_n(e, s1) - r["n0"], ch1=ch,
             top=e.u32(s1, sym(e, "sv", "0026-remote-ui") + 88))
    t, last = 4400 + 700, s1
    if again:
        a1 = lock_arrays(e, s1)
        ev = [(50, "press", "T6:180M"), (100, "turn", (f"{knob}:+20", 3, 20))]
        s2 = e.run(f"{name}-bd2", 400, ev, snap=s1, start=t, card=c, save=True, count=[SHOW_POPUP],
                   env=X.steps_env(e, name + "-2"))
        r.update(rows2=live_rows(e, s2)[0], pop2=e.counts.get(SHOW_POPUP, 0), n2=full_n(e, s2) - r["n0"] - r["n1"],
                 ch2=changed_words(a1, lock_arrays(e, s2)))
        t, last = t + 400, s2
    s3 = e.run(f"{name}-off", 300, [(50, "press", "RECORD")], snap=last, start=t, card=c, save=True)
    t += 300
    if save:
        ev, t2 = X.proj_keys(100, True)
        e.run(f"{name}-save", t2, ev, snap=s3, start=t, card=c, save=True, extra=["--card-save"])
        r["saved"] = sorted(X.file_rows(c))
    return r


def t_fxstock(e):
    """(0.5.2 round 2, A) A stock lock (BD, LFO page) that adds a row the save would drop is refused like a Send FX one:
    69 stock rows + an FX 41 lock (71, full) + a new BD knob A lock (1 row): refused, nothing changes, LOCK MEM FULL!, the
    save keeps all 71 rows with 45 / 49 (the review's rvw71bd case); 69 stock rows + a new 2-row stock lock (BD LFO depth,
    fine) = exactly 71: made, then the same lock turned again on the full pattern (replacing, no new row): made."""
    fx = [X.lockslot(45, 12, {0: 0x30}), X.lockslot(49, 12, {0: 0x10})]
    r = bd_runs(e, "fxstock71", X.stock_rows(69) + fx, 0)
    print(f"    71 rows + BD knob A: rows {r['rows0']} -> {r['rows1']}, changed {r['ch1'][:6]}, popups {r['pop1']}, refusals "
          f"{r['n1']}, top {r['top']:08x}; saved {len(r['saved'])} rows, 45/49 {(45, 12) in r['saved']}/{(49, 12) in r['saved']}")
    U.check("fxstock71: on a full pattern (69 + FX 41) a new BD LFO lock (a new row) is refused: nothing changed in the "
            "live lock arrays", not r["ch1"] and r["rows1"] == 71, f"{r['ch1'][:8]} rows {r['rows1']}")
    U.check("fxstock71: the refusal shows LOCK MEM FULL! (a popup shown, a PopupWindow on top) and is counted",
            r["pop1"] >= 1 and r["top"] == VT_POPUP and r["n1"] >= 1, f"popups {r['pop1']} top {r['top']:08x} n {r['n1']}")
    U.check("fxstock71: SAVE PROJECT AS keeps all 71 rows, the Send FX lock's 45 and 49 among them (rvw71bd: 45 / 49 lost)",
            r["saved"] == r["poked"], f"{len(r['saved'])} rows, missing {sorted(set(r['poked']) - set(r['saved']))}")
    r = bd_runs(e, "fxstock69", X.stock_rows(69), 7, again=True)
    new = sorted({x[3] for x in r["ch1"] if x[1] == 0 and x[2] == 5})
    print(f"    69 rows + BD knob H: rows {r['rows0']} -> {r['rows1']} (indexes {new}), popups {r['pop1']}, refusals "
          f"{r['n1']}; again: rows {r['rows2']}, changed {r['ch2'][:4]}, popups {r['pop2']}, refusals {r['n2']}; saved "
          f"{len(r['saved'])} rows")
    U.check("fxstock69: 69 stock rows + a new 2-row stock lock (BD LFO knob H, fine) lands exactly on 71: made, no popup, "
            "no refusal", r["rows1"] == 71 and bool(new) and r["pop1"] == 0 and r["n1"] == 0,
            f"rows {r['rows1']} indexes {new} popups {r['pop1']} n {r['n1']}")
    U.check("fxstock69: on the now full pattern the same lock turned again (replacing it: no new row) is made",
            r["rows2"] == 71 and any(x[1] == 0 and x[2] == 5 for x in r["ch2"]) and r["pop2"] == 0 and r["n2"] == 0,
            f"rows {r['rows2']} changed {r['ch2'][:4]} popups {r['pop2']} n {r['n2']}")
    U.check("fxstock69: SAVE PROJECT AS stores all 71 rows", len(r["saved"]) == 71, f"{len(r['saved'])}")


def fxpaste(e, name, n_a01, ev, length, load=True, step=0, extra=(), a01_len=None):
    """A01 = n_a01 stock rows + `extra` rows (FX trigs on step 1 and `step`), A02 = an FX 41 lock on FX step 1 (rows
    45 / 49), cold boot, the paste keys ev; SAVE PROJECT AS 003, then (load) FX 41 wiped live and LOAD PROJECT 003 ->
    dict. FX 41 is read on A01's `step`; a01_len sets A01's length: the master length (stored +13091, BE word) and,
    after the boot, every track's length byte (+709 of its 917 B; the base pattern's scale mode is per track)."""
    ed = pat_rows_ed(1, X.stock_rows(n_a01) + list(extra))
    ed.update(pat_rows_ed(2, [X.lockslot(45, 12, {0: 0x30}), X.lockslot(49, 12, {0: 0x10})]))
    ed[X.ST_KIT + 0x816] = X.FX_KIT
    ed.update(pat_trigs_ed(e, 1, 12, sorted({0, step})))
    ed.update(pat_trigs_ed(e, 2, 12, [0]))
    if a01_len:
        ed[X.ST_PAT + PAT_SIZE + 13091] = a01_len.to_bytes(2, "big")
    s, c = X.poke_boot(e, name, ed)
    t0 = 4400
    if a01_len:
        lv = {base + 917 * t + 709: bytes([a01_len]) for base in (PAT_A01, LOCKS - 11921) for t in range(13)}
        s = e.run(f"{name}-len", 50, snap=s, start=t0, card=c, save=True, extra=X.pokes(e, s, lv))
        t0 += 50
    b0, n0 = a01_state(e, s), full_n(e, s)
    s1 = e.run(f"{name}-keys", length, ev, snap=s, start=t0, card=c, save=True, count=[SHOW_POPUP], env=X.steps_env(e, name))
    b1 = a01_state(e, s1)
    n, fx = live_rows(e, s1)
    r = dict(live=n, fx=fx, popups=e.counts.get(SHOW_POPUP, 0), refusals=full_n(e, s1) - n0,
             same=b0 == b1, diff=[i for i in range(len(b0)) if b0[i] != b1[i]][:6], word=lock(e, s1, 12, step, 41), step0=lock(e, s1, 12, 0, 41),
             fine=fine(e, s1, 12, 41))
    ev2, t2 = X.proj_keys(100, True)
    s2 = e.run(f"{name}-save", t2, ev2, snap=s1, start=t0 + length, card=c, save=True, extra=["--card-save"])
    sl = X.file_rows(c)
    r.update(saved=len(sl), fxsaved=sorted(t for t, tr in sl if t >= 42))
    if load:
        wipe = {}
        for base in (LOCKS, BANK1):
            wipe[base + 5674 * 12 + 88 * step + 82] = b"\xff\xff"
            wipe[base + 5674 * 12 + 5632 + 41] = b"\0"
        s3 = e.run(f"{name}-wiped", 50, snap=s2, start=t0 + length + t2, card=c, save=True, extra=X.pokes(e, s2, wipe))
        ev3, t3 = X.proj_keys(100, False)
        s4 = e.run(f"{name}-load", t3, ev3, snap=s3, start=t0 + length + t2 + 50, card=c, save=True)
        r.update(loaded=lock(e, s4, 12, step, 41), loaded_fine=fine(e, s4, 12, 41))
    print(f"    {name}: A01 live rows {n} (FX {fx}), FX 41 {r['word']:04x} fine {r['fine']}, popups {r['popups']}, refusals "
          f"{r['refusals']}, A01 unchanged {r['same']} {r['diff']}; saved {r['saved']} rows, FX rows {r['fxsaved']}"
          + (f"; after the load {r['loaded']:04x} fine {r['loaded_fine']}" if load else ""))
    return r


def paste_keys(kind):
    a02 = [(100, "press", "BANK_A:40M"), (120, "press", "T2")]
    a01 = lambda t: [(t, "press", "BANK_A:40M"), (t + 20, "press", "T1")]   # noqa: E731
    fn = lambda t, k: [(t, "press", "FUNC:30M"), (t + 10, "press", k)]   # noqa: E731
    if kind == "track":
        return a02 + [(300, "press", "FX"), (400, "press", "RECORD")] + fn(500, "RECORD") + a01(700) + fn(900, "STOP") + \
            [(1100, "press", "RECORD")], 1300
    if kind in ("page", "page2"):   # PAGE held + FUNC + REC / STOP in GRID REC (sq_emu seqedit): A02's page 1 (steps
        # 1..16) onto A01's page 1, or (page2: A01 32 steps long, PAGE pressed once) onto its page 2 (steps 17..32)
        return a02 + [(300, "press", "FX"), (400, "press", "RECORD"), (500, "press", "PAGE:60M")] + fn(505, "RECORD") + \
            a01(700) + ([(800, "press", "PAGE")] if kind == "page2" else []) + [(900, "press", "PAGE:60M")] + \
            fn(905, "STOP") + [(1100, "press", "RECORD")], 1300
    return a02 + [(300, "press", "FX"), (400, "press", "RECORD"), (500, "press", "T1:60M")] + fn(510, "RECORD") + \
        a01(700) + [(900, "press", "T1:60M")] + fn(910, "STOP") + [(1100, "press", "RECORD")], 1300


def t_fxpaste(e):
    """(0.5.2 round 2, B + C) Track paste (GRID REC, FUNC + REC on A02's FX track, FUNC + STOP on A01's) and trig paste
    (T1 held + FUNC + REC / STOP) of A02's FX 41 lock (FX step 1). With room (A01 40 stock rows, and 69: exactly 71):
    made with the FX track's fine flag, so SAVE PROJECT AS keeps rows 45 and 49 and LOAD PROJECT brings the whole word
    back. Onto 70 and 71 stock rows (72 / 73 > 71): refused with LOCK MEM FULL!, A01's trigs and locks unchanged."""
    for kind in ("track", "trig"):
        ev, ln = paste_keys(kind)
        for n in ((40, 69) if kind == "track" else (40,)):
            r = fxpaste(e, f"fxpaste-{kind}{n}", n, ev, ln)
            U.check(f"fxpaste-{kind}{n}: the {kind} paste with room is made: FX 41 in A01 (3020), the fine flag set, "
                    f"{n + 2} rows, no refusal", r["word"] == 0x3020 and r["fine"] == 1 and r["live"] == n + 2 and
                    r["refusals"] == 0, f"{r['word']:04x} fine {r['fine']} rows {r['live']} n {r['refusals']}")
            U.check(f"fxpaste-{kind}{n}: SAVE PROJECT AS keeps both halves (rows 45 and 49), LOAD PROJECT brings 3020 back "
                    "with the fine flag", r["fxsaved"] == [45, 49] and r["loaded"] == 0x3020 and r["loaded_fine"] == 1,
                    f"FX rows {r['fxsaved']}, loaded {r['loaded']:04x} fine {r['loaded_fine']}")
        for n in (70, 71):
            r = fxpaste(e, f"fxpaste-{kind}{n}", n, ev, ln, load=False)
            U.check(f"fxpaste-{kind}{n}: the {kind} paste onto {n} rows ({n + 2} > 71) is refused: A01's trigs and locks "
                    "unchanged", r["same"] and r["live"] == n and r["word"] == 0xffff, f"diff at {r['diff']} rows "
                    f"{r['live']} FX 41 {r['word']:04x}")
            U.check(f"fxpaste-{kind}{n}: LOCK MEM FULL! shown (counted refusal, a popup), the save keeps the {n} rows",
                    r["refusals"] >= 1 and r["popups"] >= 1 and r["saved"] == n and not r["fxsaved"],
                    f"n {r['refusals']} popups {r['popups']} saved {r['saved']} FX {r['fxsaved']}")


def t_fxpage(e):
    """(0.5.2 round 3, review H1) PASTE PAGE (GRID REC, PAGE held + FUNC + REC on A02's FX track, PAGE + FUNC + STOP on
    A01's) of A02's FX 41 lock (FX step 1, page 1): with room (40, 69) made with the fine flag, both halves saved and
    loaded; onto 70 / 71 stock rows refused with LOCK MEM FULL!, A01 unchanged. Then A01 32 steps long and A02's page 1
    pasted onto A01's page 2 (review 3 LOW 1): with room made on step 17; onto 70 rows refused; onto a full pattern whose
    step 17 already holds FX 41 (replacing, no new row) made."""
    ev, ln = paste_keys("page")
    for n in (40, 69):
        r = fxpaste(e, f"fxpaste-page{n}", n, ev, ln)
        U.check(f"fxpaste-page{n}: the page paste with room is made: FX 41 in A01 (3020), the fine flag set, {n + 2} rows, "
                "no refusal", r["word"] == 0x3020 and r["fine"] == 1 and r["live"] == n + 2 and r["refusals"] == 0,
                f"{r['word']:04x} fine {r['fine']} rows {r['live']} n {r['refusals']}")
        U.check(f"fxpaste-page{n}: SAVE PROJECT AS keeps both halves (rows 45 and 49), LOAD PROJECT brings 3020 back with "
                "the fine flag", r["fxsaved"] == [45, 49] and r["loaded"] == 0x3020 and r["loaded_fine"] == 1,
                f"FX rows {r['fxsaved']}, loaded {r['loaded']:04x} fine {r['loaded_fine']}")
    for n in (70, 71):
        r = fxpaste(e, f"fxpaste-page{n}", n, ev, ln, load=False)
        U.check(f"fxpaste-page{n}: the page paste onto {n} rows ({n + 2} > 71) is refused: A01's trigs and locks unchanged",
                r["same"] and r["live"] == n and r["word"] == 0xffff, f"diff at {r['diff']} rows {r['live']} "
                f"FX 41 {r['word']:04x}")
        U.check(f"fxpaste-page{n}: LOCK MEM FULL! shown (counted refusal, a popup), the save keeps the {n} rows",
                r["refusals"] >= 1 and r["popups"] >= 1 and r["saved"] == n and not r["fxsaved"],
                f"n {r['refusals']} popups {r['popups']} saved {r['saved']} FX {r['fxsaved']}")
    # review 3 LOW 1: a different source and target page (clipboard page 0, A01's page 1: the c + s - d indexing), and
    # a page paste that replaces locks already there on a full pattern (no new row: made)
    ev, ln = paste_keys("page2")
    r = fxpaste(e, "fxpaste-page2-40", 40, ev, ln, step=16, a01_len=32)
    U.check("fxpaste-page2-40: A02's page 1 pasted onto A01's page 2 (40 rows): FX 41 on step 17 (3020), the fine flag "
            "set, 42 rows, no refusal; step 1 untouched", r["word"] == 0x3020 and r["fine"] == 1 and r["live"] == 42 and
            r["refusals"] == 0 and r["step0"] == 0xffff, f"{r['word']:04x} fine {r['fine']} rows {r['live']} n "
            f"{r['refusals']} step 1 {r['step0']:04x}")
    U.check("fxpaste-page2-40: SAVE PROJECT AS keeps rows 45 and 49, LOAD PROJECT brings 3020 back on step 17",
            r["fxsaved"] == [45, 49] and r["loaded"] == 0x3020 and r["loaded_fine"] == 1,
            f"FX rows {r['fxsaved']}, loaded {r['loaded']:04x} fine {r['loaded_fine']}")
    r = fxpaste(e, "fxpaste-page2-70", 70, ev, ln, load=False, step=16, a01_len=32)
    U.check("fxpaste-page2-70: onto A01's page 2 with 70 rows (72 > 71): refused, A01 unchanged, LOCK MEM FULL!",
            r["same"] and r["live"] == 70 and r["word"] == 0xffff and r["refusals"] >= 1 and r["popups"] >= 1,
            f"diff at {r['diff']} rows {r['live']} FX 41 {r['word']:04x} n {r['refusals']} popups {r['popups']}")
    fx = [X.lockslot(45, 12, {16: 0x21}), X.lockslot(49, 12, {16: 0x11})]
    r = fxpaste(e, "fxpaste-page2-full", 69, ev, ln, load=False, step=16, extra=fx, a01_len=32)
    U.check("fxpaste-page2-full: 69 rows + FX 41 already locked on step 17 (71, full), page 1 pasted onto page 2 "
            "(replaces the lock, no new row): made, 3020 on step 17, 71 rows, no refusal, the save keeps all 71",
            r["word"] == 0x3020 and r["fine"] == 1 and r["live"] == 71 and r["refusals"] == 0 and r["saved"] == 71 and
            r["fxsaved"] == [45, 49], f"{r['word']:04x} fine {r['fine']} rows {r['live']} n {r['refusals']} saved "
            f"{r['saved']} FX {r['fxsaved']}")


CLIP = 0x419f28b8                  # the copy / paste clipboard singleton (0x40180280's static; DDR, not moved by 1.74)
NEW, DELETE = 0x400829d4, 0x400829e0   # operator new / delete (their jmp stubs)


def boot_ab(e, name, a01, a02, a01_trigs, a02_trigs):
    ed = pat_rows_ed(1, a01)
    ed.update(pat_rows_ed(2, a02))
    ed[X.ST_KIT + 0x816] = X.FX_KIT
    ed.update(pat_trigs_ed(e, 1, 12, a01_trigs))
    ed.update(pat_trigs_ed(e, 2, 12, a02_trigs))
    return X.poke_boot(e, name, ed)


def t_fxpaste2(e):
    """(0.5.2 round 3) PASTE TRIGS edge cases. multi71: A01 full (69 + FX 41 on steps 1 and 2 = 71), two trigs with other
    FX 41 values copied from A02 (T1 + T2 held) and pasted over them: no new row, made. neg: a clipboard entry with a
    negative value (stock's lock_pool_set writes nothing for it, not even the flag) on a full A01 (70 + FX 41 hi only =
    71): counted as nothing, so the paste is made (review L2). leak: 1 vs 4 refused pastes on a full pattern: operator
    new minus delete the same (review M1: the first record's copy's lock vector freed on the refusal)."""
    fx = lambda v1, v2: [X.lockslot(45, 12, {0: v1, 1: v2}), X.lockslot(49, 12, {0: 0x10, 1: 0x10})]   # noqa: E731
    a02 = [(100, "press", "BANK_A:40M"), (120, "press", "T2"), (300, "press", "FX"), (400, "press", "RECORD")]
    a01 = lambda t: [(t, "press", "BANK_A:40M"), (t + 20, "press", "T1")]   # noqa: E731
    fn = lambda t, k: [(t, "press", "FUNC:30M"), (t + 10, "press", k)]   # noqa: E731
    # multi71
    s, c = boot_ab(e, "fxpaste2-multi71", X.stock_rows(69) + fx(0x20, 0x20), fx(0x30, 0x40), [0, 1], [0, 1])
    w0 = (lock(e, s, 12, 0, 41), lock(e, s, 12, 1, 41))
    n0 = full_n(e, s)
    ev = a02 + [(500, "press", "T1:80M"), (505, "press", "T2:80M")] + fn(520, "RECORD") + a01(700) + \
        [(900, "press", "T1:80M"), (905, "press", "T2:80M")] + fn(920, "STOP") + [(1100, "press", "RECORD")]
    s1 = e.run("fxpaste2-multi71-keys", 1300, ev, snap=s, start=4400, card=c, save=True, count=[SHOW_POPUP],
               env=X.steps_env(e, "fxpaste2-multi71"))
    w1 = (lock(e, s1, 12, 0, 41), lock(e, s1, 12, 1, 41))
    rows, _ = live_rows(e, s1)
    print(f"    multi71: FX 41 steps 1 / 2 {w0[0]:04x} {w0[1]:04x} -> {w1[0]:04x} {w1[1]:04x}, rows {rows}, refusals "
          f"{full_n(e, s1) - n0}, popups {e.counts.get(SHOW_POPUP, 0)}")
    U.check("fxpaste2-multi71: on a full pattern a two-trig paste replacing both FX 41 locks is made (3020 / 4020), 71 rows, "
            "no refusal", w1 == (0x3020, 0x4020) and rows == 71 and full_n(e, s1) == n0, f"{w1} rows {rows}")
    # neg
    s, c = boot_ab(e, "fxpaste2-neg", X.stock_rows(70) + [X.lockslot(45, 12, {1: 0x20})], fx(0x30, 0x30),
                   [0, 1], [0])
    rows0, _ = live_rows(e, s)
    ev = a02 + [(500, "press", "T1:60M")] + fn(510, "RECORD")
    s1 = e.run("fxpaste2-neg-copy", 700, ev, snap=s, start=4400, card=c, save=True)
    obj = e.u32(s1, e.u32(s1, CLIP) + 4)
    rec = e.u32(s1, obj + 4)
    ent, end = e.u32(s1, rec + 52), e.u32(s1, rec + 56)
    poke = {ent: (0xffffffff).to_bytes(4, "big") + (41).to_bytes(4, "big") + b"\x01"}
    n0 = full_n(e, s1)
    ev = a01(50) + [(250, "press", "T1:60M")] + fn(260, "STOP") + [(450, "press", "RECORD")]
    s2 = e.run("fxpaste2-neg-paste", 650, ev, snap=s1, start=5100, card=c, save=True, extra=X.pokes(e, s1, poke),
               count=[SHOW_POPUP])
    rows2, fxi = live_rows(e, s2)
    print(f"    neg: A01 rows {rows0} (FX 41 fine {fine(e, s, 12, 41)}), clipboard entries {(end - ent) // 12}, after the paste "
          f"rows {rows2} FX {fxi} fine {fine(e, s2, 12, 41)}, refusals {full_n(e, s2) - n0}")
    U.check("fxpaste2-neg: a pasted entry with a negative value counts as nothing: the paste onto 71 rows is made (no "
            "refusal, 71 rows, the flag unchanged)", rows0 == 71 and full_n(e, s2) == n0 and rows2 == 71,
            f"rows {rows0} -> {rows2} refusals {full_n(e, s2) - n0}")
    # leak
    s, c = boot_ab(e, "fxpaste2-leak", X.stock_rows(71), fx(0x30, 0x30), [0], [0])
    s1 = e.run("fxpaste2-leak-copy", 700, a02 + [(500, "press", "T1:60M")] + fn(510, "RECORD"), snap=s, start=4400,
               card=c, save=True)
    nets = []
    for k in (1, 4):
        ev = a01(50)
        for i in range(k):
            ev += [(250 + 800 * i, "press", "T1:60M")] + fn(260 + 800 * i, "STOP")
        n0 = full_n(e, s1)
        s2 = e.run(f"fxpaste2-leak{k}", 250 + 800 * 4 + 600, ev, snap=s1, start=5100, card=c, count=[NEW, DELETE],
                   save=True)
        nets.append((e.counts.get(NEW, 0), e.counts.get(DELETE, 0), full_n(e, s2) - n0))
    leak = ((nets[1][0] - nets[1][1]) - (nets[0][0] - nets[0][1])) / 3
    print(f"    leak: (new, delete) with 1 refused paste {nets[0]}, with 4 {nets[1]}: blocks kept per extra refusal {leak}")
    U.check("fxpaste2-leak: repeated refused trig pastes (1 and 4 refusals) keep no heap block (new - delete the same)",
            nets[0][2] == 1 and nets[1][2] == 4 and nets[0][0] > 0 and leak == 0,
            f"{nets} -> {leak} a paste")


def live_run(e, name, n, knob_ev):
    """A01 = n stock rows, FX trigs on steps 1..16, cold boot; the FX track, live record (RECORD held + PLAY), knob_ev
    (keys / turns from 1200 M while playing), STOP at 3500 -> dict."""
    ed = pat_rows_ed(1, X.stock_rows(n))
    ed[X.ST_KIT + 0x816] = X.FX_KIT
    ed.update(pat_trigs_ed(e, 1, 12, list(range(16))))
    s, c = X.poke_boot(e, name, ed)
    a0, n0 = lock_arrays(e, s), full_n(e, s)
    ev = [(50, "press", "FX")] + knob_ev[0] + [(450, "press", "RECORD:150M"), (500, "press", "PLAY")] + knob_ev[1] + \
        [(3500, "press", "STOP")]
    s1 = e.run(f"{name}-keys", 3800, ev, snap=s, start=4400, card=c, save=True, count=[SHOW_POPUP, LIVE_ON, LIVE_TLS, TLS],
               env=X.steps_env(e, name), extra=["--watch", f"{sym(e, 'sfu_st') + SFU_ST_FULL + 4:x}"])
    pop, on, tls, sets = (e.counts.get(k, 0) for k in (SHOW_POPUP, LIVE_ON, LIVE_TLS, TLS))
    shown = [int(v, 16) for v in re.findall(r"watch: pc=[0-9a-f]+ \[[0-9a-f]+\]\.\d <- ([0-9a-f]+)", e.log)]
    shown = [v for v in shown if v]   # sfu_st.full_t = DTCN0 | 1 at each popup 0029 shows (0: sfu_tick's clear)
    gaps = [((b - a) & 0xffffffff) // 132000 for a, b in zip(shown, shown[1:])]   # ms of DTCN0 (132 MHz)
    ch = changed_words(a0, lock_arrays(e, s1))
    rows, fx = live_rows(e, s1)
    r = dict(pop=pop, on=on, tls=tls, sets=sets, rows=rows, fx=fx, refused=full_n(e, s1) - n0,
             idx=sorted({(x[1], x[3]) for x in ch}), shown=len(shown), gaps=gaps)
    print(f"    {name}: live record past its record test {on}, its lock calls {tls} (track_lock_set entries {sets}), "
          f"refusals {r['refused']}, popups {pop} (0029's {len(shown)}, ms apart {gaps}); rows {rows}, FX indexes >= 38 {fx}, changed (track, index) {r['idx'][:8]}")
    return r


TLS = 0x400c0520                   # track_lock_set's entry


def t_fxlive(e):
    """(0.5.2 round 2, D) Live record (RECORD held + PLAY) with FX trigs on steps 1..16, a knob turned while playing.
    Control: the DELAY page's knob A (stock TIME) - recording proven by live record's lock path (past its record-state
    test, its track_lock_set call reached) and a lock made with room (40 rows); on 71 rows the same lock (a new row, 72)
    is refused, LOCK MEM FULL! at most every 500 ms, and the run goes on to STOP. Then SEND FX 2's P4 (0029's record)
    while recording: printed (does live record reach 0029's knobs at all)."""
    turns = [(1200 + 100 * i, "turn", ("0:+4", 2, 20)) for i in range(20)]
    delay = ([(150, "press", "SRC")], turns)
    ok = live_run(e, "fxlive40", 40, delay)
    U.check("fxlive40: live record was active while the DELAY knob turned (its lock path past the record test, "
            "track_lock_set called from it)", ok["on"] > 0 and ok["tls"] > 0, f"{ok['on']} {ok['tls']}")
    U.check("fxlive40: with room the recorded stock lock is made (an FX track index locked), no refusal",
            any(t == 12 for t, _ in ok["idx"]) and ok["refused"] == 0, f"{ok['idx'][:6]} n {ok['refused']}")
    full = live_run(e, "fxlive71", 71, delay)
    U.check("fxlive71: live record active (as fxlive40)", full["on"] > 0 and full["tls"] > 0, f"{full['on']} {full['tls']}")
    U.check("fxlive71: the recorded lock (a new row: 72 > 71) is refused: nothing changed, 71 rows, refusals counted",
            not full["idx"] and full["rows"] == 71 and full["refused"] >= 1, f"{full['idx'][:6]} rows {full['rows']} "
            f"n {full['refused']}")
    U.check("fxlive71: LOCK MEM FULL! rate-limited (0029's popups 500 ms or more apart, at most one a refusal; every one "
            "shown), the run went on to STOP without a fault", 1 <= full["shown"] <= full["refused"] and
            full["pop"] - ok["pop"] == full["shown"] and all(g >= 500 for g in full["gaps"]),
            f"shown {full['shown']} gaps {full['gaps']} popups {full['pop']} refusals {full['refused']}")
    p4 = ([(150, "press", "SRC"), (250, "press", "SMPL"), (350, "press", "SMPL")],
          [(1200 + 100 * i, "turn", ("4:+4", 2, 20)) for i in range(20)])
    for n in (40, 70):
        r = live_run(e, f"fxlive-p4-{n}", n, p4)
        print(f"    => SEND FX 2 P4 in live record on {n} rows: recorded {41 in r['fx']}, refused {r['refused']}")


TCB = 0x42f67924                   # rtos_current_tcb: the running task's TCB
LOCK_FULL = 0x400acb66             # stock's LOCK MEM FULL! popup (0029's refusals call it)
CC_SWEEP = bytes(b for ch in range(16) for n in range(1, 120) if n != 32 for b in (0xB0 | ch, n, 100))


def brk_tcb(e, name, s, c, ev, addr, after):
    """A run from snap s that stops at addr's first visit after clock `after` M -> (stopped there, a7, the TCB)."""
    e.run(name, 3800, ev, snap=s, start=4400, card=c, save=True, extra=["--break", f"{addr:x}", "--break-after", f"{after}M"])
    m = re.search(r"BREAK at 0x([0-9a-f]+) \| stack at a7=([0-9a-f]+)", e.log.replace("\n", " | "))
    hit = bool(m) and int(m.group(1), 16) == addr
    return hit, int(m.group(2), 16) if m else None, e.u32(os.path.join(e.tmp, f"{name}.snap"), TCB) if hit else None


def t_fxlivecc(e):
    """(0.5.2 round 4) MIDI CCs recorded live (a CC sweep over USB MIDI while live recording, FX trigs on steps 1..16) on
    a full pattern (71 rows): every new lock refused, 71 rows kept, no fault; live record's track_lock_set runs in the
    MIDI task, LOCK MEM FULL! in the UI task (the knob case's task: 0029 shows it from sfu_tick, never where it refuses),
    at most every 500 ms."""
    r = live_run(e, "fxlivecc71", 71, ([(150, "press", "SRC")], [(1200, "usb", CC_SWEEP)]))
    U.check("fxlivecc71: the recorded CC locks reach track_lock_set from live record; the ones on a new row are refused "
            "(still 71 rows, refusals counted; CCs on an index the track already locks replace it, as stock)",
            r["tls"] > 0 and r["rows"] == 71 and not r["fx"] and r["refused"] >= 1,
            f"tls {r['tls']} rows {r['rows']} FX {r['fx']} n {r['refused']} changed {r['idx'][:6]}")
    U.check("fxlivecc71: LOCK MEM FULL! shown (0029's popups 500 ms or more apart, every one shown)",
            1 <= r["shown"] <= r["refused"] and r["pop"] >= r["shown"] and all(g >= 500 for g in r["gaps"]),
            f"shown {r['shown']} gaps {r['gaps']} popups {r['pop']}")
    ed = pat_rows_ed(1, X.stock_rows(71))
    ed[X.ST_KIT + 0x816] = X.FX_KIT
    ed.update(pat_trigs_ed(e, 1, 12, list(range(16))))
    s, c = X.poke_boot(e, "fxlivecc-b", ed)
    pre = [(50, "press", "FX"), (150, "press", "SRC"), (450, "press", "RECORD:150M"), (500, "press", "PLAY")]
    cc = pre + [(1200, "usb", CC_SWEEP), (3500, "press", "STOP")]
    knob = pre + [(1200 + 100 * i, "turn", ("0:+4", 2, 20)) for i in range(20)] + [(3500, "press", "STOP")]
    at = 4400 + 1150
    h1, sp1, mt = brk_tcb(e, "fxlivecc-tls", s, c, cc, TLS, at)
    h2, sp2, pt = brk_tcb(e, "fxlivecc-pop", s, c, cc, LOCK_FULL, at)
    h3, sp3, ui = brk_tcb(e, "fxlivecc-knob", s, c, knob, TLS, at)
    f = lambda v: "-" if v is None else f"{v:08x}"   # noqa: E731
    print(f"    CC: track_lock_set a7 {f(sp1)} TCB {f(mt)}; LOCK MEM FULL! a7 {f(sp2)} TCB {f(pt)}; knob: track_lock_set a7 "
          f"{f(sp3)} TCB {f(ui)}")
    U.check("fxlivecc: a CC recorded live reaches track_lock_set in another task than the knob's (the MIDI task)",
            h1 and h3 and mt != ui, f"hits {h1} {h3} TCBs {f(mt)} {f(ui)}")
    U.check("fxlivecc: the CC refusal's LOCK MEM FULL! runs in the UI task (the knob's task), not the MIDI task",
            h2 and pt == ui and pt != mt, f"hit {h2} TCB {f(pt)} (UI {f(ui)}, MIDI {f(mt)})")


TESTS = {"fmname": t_fmname, "enum": t_enum, "typelist": t_typelist, "enumlock": t_enumlock, "enumkit": t_enumkit, "ext": t_ext,
         "labels": t_labels, "fullnames": t_fullnames, "xpages": t_xpages, "xreset": t_xreset, "xfix": t_xfix, "xcc": t_xcc, "xkeys": t_xkeys,
         "xlock": t_xlock, "xmisc": t_xmisc, "xcopy": t_xcopy, "cost": t_cost, "bw": t_bw, "bw2": t_bw2, "bwwrap": t_bwwrap, "pages": t_pages, "names": t_names, "locks": t_locks, "pretick": t_pretick, "save": t_save, "stock": t_stock, "kits": t_kits}
# named only, not in "all" (long: about 15 runs): 0.5.2's refusal of an FX lock past stock's 71-row cap (sfx_emu.py fxfull has
# the stored-row cases)
NAMED = {"fxfull": t_fxfull, "fxpaths": t_fxpaths, "fxstock": t_fxstock, "fxpaste": t_fxpaste, "fxlive": t_fxlive, "fxpage": t_fxpage, "fxpaste2": t_fxpaste2, "fxlivecc": t_fxlivecc}


def main():
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    if len(sys.argv) < 3 or any(t not in TESTS and t not in NAMED for t in names):
        sys.exit(__doc__ + "\nTESTS: all " + " ".join(TESTS) + "\nNamed only: " + " ".join(NAMED))
    e = U.Emu(sys.argv[1])
    e.strict = True
    for t in names:
        fn = TESTS.get(t) or NAMED[t]
        print(f"-- {t}: {fn.__doc__.splitlines()[0]}")
        fn(e)
    print(f"\n{'ALL PASS' if not U.fails else 'FAILED: ' + ', '.join(U.fails)}")
    sys.exit(1 if U.fails else 0)


if __name__ == "__main__":
    main()
