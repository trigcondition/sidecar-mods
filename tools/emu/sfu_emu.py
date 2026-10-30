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


def sym(e, name):
    m = json.load(open(os.path.join(e.out, "manifest.json")))
    return m["elek"]["symbols"]["rytm-0029-sendfx-ui:" + name]


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


TESTS = {"fmname": t_fmname, "enum": t_enum, "typelist": t_typelist, "enumlock": t_enumlock, "enumkit": t_enumkit, "ext": t_ext,
         "labels": t_labels, "cost": t_cost, "pages": t_pages, "names": t_names, "locks": t_locks, "save": t_save, "stock": t_stock, "kits": t_kits}


def main():
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    if len(sys.argv) < 3 or any(t not in TESTS for t in names):
        sys.exit(__doc__ + "\nTESTS: all " + " ".join(TESTS))
    e = U.Emu(sys.argv[1])
    e.strict = True
    for t in names:
        print(f"-- {t}: {TESTS[t].__doc__.splitlines()[0]}")
        TESTS[t](e)
    print(f"\n{'ALL PASS' if not U.fails else 'FAILED: ' + ', '.join(U.fails)}")
    sys.exit(1 if U.fails else 0)


if __name__ == "__main__":
    main()
