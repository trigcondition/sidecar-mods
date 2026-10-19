#!/usr/bin/env python3
"""Emulator test of 0025-sendfx-report in rytm-emu: the host stand-in reads the Rytm's USB MIDI out and decodes
SENDFX (0x20, rytm-teensy sim/protocol.py decode_sendfx).

    .venv/bin/python tools/emu/sfx_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a build with 0025 (e.g. us1's mods + 0025-sendfx-report) whose base tools/emu/us_base.sh TAG made. The test
writes, into the base's stored working state (OS 1.73 addresses, rytm-teensy
docs/superpowers/specs/2026-10-16-sidecar-send-fx-storage.md): kit word 0 of BD = 0x1100, FX words 0/29 = 0x2a54 /
0x3b66, and in bank pattern A01 trigs on BD steps 1, 5, 9, 13 and FX steps 1, 9 with p-locks: BD type 41 (sound
index 0) 0x33 + fine 0x21 on step 1, 0x44 + fine 0x05 on step 5, 0x10 on step 9; FX type 37 (FX word 0) 0x55 on
step 1, type 20 (FX word 29) 0x66 on step 9. Power off, cold boot, PLAY, every run under DTEMU_STRICT=1. The host
must see per step: BD 3342 440a 1000 1100, FX word 0 5500 on step 1 (else 2a54), word 29 6600 on step 9 (else
3b66), each in the 5M-instruction window of its step (DTBOOT_PEEK's usb_midi_out count). Firmware-derived files
stay in rytm-emu's git-ignored sections/ and in build/.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import us_emu as U          # noqa: E402  (Emu, check, card_copy, the protocol module as U.P)
P = U.P

ST_PAT = 0x405c8f38          # stored working pattern; bank pattern i at + 13101 (i + 1)
ST_KIT = 0x407658e5          # stored project kit copy (0xA32, the active kit's)
B0 = ST_PAT + 13101          # bank pattern A01
FREE_SLOT = 14               # led.img's A01 uses lock slots 0..13 [measured]


def hook_addr(e):
    """Where to count sfx_hook's calls: its cave entry (0x402cc920), or with 0025 in elekloader's area (dtboot counts
    only inside the OS image) the detour site 0x401213a0, which runs once a call."""
    import json
    m = json.load(open(os.path.join(e.out, "manifest.json")))
    for d in m.get("detours", []):
        if d.get("entry") == "sfx_hook":
            return d["addr"] if d.get("elek") else d["target"]
    return 0x402cc920


def lockslot(typ, track, steps):
    v = bytearray([0xff] * 64)
    for st, val in steps.items():
        v[st] = val
    return bytes([typ, track]) + bytes(v)


def trig_bits(e, snap, track, steps, flags=0x381):
    """A01's trig bits for `track` with `flags` (bit 0 trig) on `steps`: 64 x 14 bits, big-endian, at +4 + 641 t."""
    a = B0 + 4 + 641 * track
    n = int.from_bytes(e.peek(snap, a, 112), "big")
    for i in steps:
        sh = 14 * (63 - i)
        n = (n & ~(0x3fff << sh)) | (flags << sh)
    return {a: n.to_bytes(112, "big")}


def pokes(e, snap, edits):
    mem = {}
    for a, d in edits.items():
        for i, b in enumerate(d):
            mem[a + i] = b
    out = []
    for w in sorted({a & ~3 for a in mem}):
        cur = bytearray(e.peek(snap, w, 4))
        for i in range(4):
            if w + i in mem:
                cur[i] = mem[w + i]
        out += ["--poke", f"{w:x}={cur.hex()}"]
    return out


DIALOGS = [(2600, "press", "YES"), (3000, "press", "NO"), (3400, "press", "NO"), (3800, "press", "NO")]
LIVE_KIT0 = 0x412558e3       # live kit k at + 2531 k
LIVE_LOCKS = 0x407c89e3 + 11921   # the working pattern's live locks: + 5674 t + 88 step + 2 index
STOCK = U.STOCK


def poke_boot(e, name, ed, snap=None, start=None, card=None, fw=None):
    """edits poked into the state at snap (default the base), power off, cold boot on that card (dialogs answered):
    -> (snapshot, card). Firmware fw (default the build) for the boot."""
    snap = snap or e.snap
    start = e.clock if start is None else start
    c = card or U.card_copy(e, name)
    e.run(f"{name}-poke", 300, snap=snap, start=start, card=c,
          extra=pokes(e, snap, ed) + ["--power-off", f"{start + 100}M"])
    s = e.run(f"{name}-boot", 4400, DIALOGS, cold=True, card=c, save=True, fw=fw)
    return s, c


def sendfx_rx(e, run):
    """The 0x20 messages of run `run` (its USB dump) in order: (clock M of the 5M window, track, words)."""
    marks, clock = [], None
    for line in e.log.splitlines():
        m = re.match(r"^\s*(\d+)M pc=", line)
        if m:
            clock = int(m.group(1))
        m = re.search(r"usb_midi_out=(\d+)", line)
        if m and clock is not None:
            marks.append((clock, int(m.group(1))))
    dump = open(os.path.join(e.tmp, f"{run}.usb"), "rb").read()
    got, pos = [], 0
    for msg in U.sysex(dump):
        pos = dump.index(msg, pos) + len(msg)
        r = P.parse(msg)
        if not r or r[0] != P.SENDFX:
            continue
        d = P.decode_sendfx(r[1])
        when = next((ck for ck, n in marks if n >= pos), None)
        got.append((when, d["track"], d["words"] if d else None))
    return got


def changes(rows, after):
    """(clock, value) rows -> the changes from clock `after` on."""
    out = []
    for w, v in rows:
        if w is not None and w >= after and (not out or out[-1][1] != v):
            out.append((w, v))
    return out


def t_report(e):
    """(M1) The reporter: BD's index 0 and the FX words per step, as the host stand-in receives them."""
    ed = {ST_KIT + 0x2e + 0x6e: bytes.fromhex("1100"), ST_KIT + 0x814: bytes.fromhex("2a54"),
          ST_KIT + 0x7f2: bytes.fromhex("3b66"),
          B0 + 0x2091 + 66 * FREE_SLOT: lockslot(41, 0, {0: 0x33, 4: 0x44, 8: 0x10}) + bytes([0x80, 0x80]) +
          lockslot(0, 0, {0: 0x21, 4: 0x05})[2:] + lockslot(37, 12, {0: 0x55}) + lockslot(20, 12, {8: 0x66})}
    ed.update(trig_bits(e, e.snap, 0, [0, 4, 8, 12]))
    ed.update(trig_bits(e, e.snap, 12, [0, 8]))
    # the cold boot's dialogs answered as us_base.sh does (else MISSING CAL stays up and PLAY does nothing)
    s, c = poke_boot(e, "sfx", ed)
    U.check("sfx: the cold boot is on OVERBRIDGE (USB CONFIG 0x405c8e4c = 01)", e.peek(s, 0x405c8e4c, 1) == b"\x01")
    play = 4400 + 100
    # FX words 38..41 have no storage: written live into kit 0 (+1942, the storage spec's measured slots)
    live38 = pokes(e, s, {0x412558e3 + 1942: bytes.fromhex("1100220033004400")})
    e.run("sfx-play", 900, [(100, "press", "PLAY")], snap=s, start=4400, card=c,
          extra=live38 + ["--every", "5M", "--count", "%x" % hook_addr(e)], env={"DTBOOT_PEEK": "8000e5b0"})
    got = sendfx_rx(e, "sfx-play")
    dump = open(os.path.join(e.tmp, "sfx-play.usb"), "rb").read()
    U.check("sfx: SENDFX messages decode (sim/protocol.py)", bool(got) and all(g[2] is not None for g in got),
            f"{len(got)} messages of {len(U.sysex(dump))}")
    bd = [(w, ws[0]) for w, t, ws in got if t == 0]
    fx = [(w, ws[0], ws[1], ws[2:]) for w, t, ws in got if t == 12]
    for w, v in bd[:12]:
        print(f"    BD  {w}M {v:04x}")
    for w, a, b, rest in fx[:8]:
        print(f"    FX  {w}M w0 {a:04x} w29 {b:04x} w38..41 {' '.join('%04x' % x for x in rest)}")
    # the BD sequence after PLAY (changes; the round robin repeats the last value, filtered)
    seq = []
    for w, v in bd:
        if w is not None and w >= play and (not seq or seq[-1][1] != v):
            seq.append((w, v))
    vals = [v for _, v in seq]
    want = [0x3342, 0x440a, 0x1000, 0x1100] * 2
    U.check("sfx: BD's sound index 0 per step - 3342 440a 1000 1100, twice (p-locks with the fine slot, then the kit's)",
            vals[:8] == want, " ".join("%04x" % v for v in vals[:10]))
    steps = [w for w, _ in seq[:8]]
    gaps = [b - a for a, b in zip(steps, steps[1:])]
    U.check("sfx: one change per step - 4 steps apart (about 95M at 127 BPM)", all(85 <= g <= 105 for g in gaps), str(gaps))
    # the same step's trig array word (DTBOOT_PEEK 0x8000e5b0) - the window the change appeared in
    fxseq = []
    for w, a, b, rest in fx:
        if w is not None and w >= play and (not fxseq or fxseq[-1][1:] != (a, b)):
            fxseq.append((w, a, b))
    U.check("sfx: FX word 0 5500 on step 1, word 29 6600 on step 9, the kit's 2a54 / 3b66 otherwise",
            [(a, b) for _, a, b in fxseq[:4]] == [(0x5500, 0x3b66), (0x2a54, 0x6600)] * 2,
            " ".join("%04x/%04x" % (a, b) for _, a, b in fxseq[:6]))
    U.check("sfx: FX words 38..41 (live only) reported as written: 1100 2200 3300 4400",
            bool(fx) and fx[-1][3] == [0x1100, 0x2200, 0x3300, 0x4400], " ".join("%04x" % x for x in fx[-1][3]) if fx else "")
    U.check("sfx: the FX step 1 report in the BD step 1 report's window (same trig)",
            bool(fxseq) and bool(seq) and abs(fxseq[0][0] - seq[0][0]) <= 5, f"{fxseq[:1]} {seq[:1]}")
    rr = [w for w, t, ws in got if t == 5]
    U.check("sfx: the round robin resends a quiet track (track 6, value 0) at least twice in 900M", len(rr) >= 2,
            str(len(rr)))
    hook = e.counts.get(hook_addr(e), 0)
    U.check("sfx: the hook ran about once an audio block (1500/s: ~6750 in 900M at 200M/s)", 5000 <= hook <= 8000,
            str(hook))


def steps_env(e, name):
    """SFX_STEPS=1: a PNG after each key (build/emu/<tag>/steps-<name>/), to look at a key walk."""
    if not os.environ.get("SFX_STEPS"):
        return {}
    d = os.path.join(e.out, f"steps-{name}")
    os.makedirs(d, exist_ok=True)
    return {"DTBOOT_STEPS": "1", "DTBOOT_PNG_DIR": d}


def proj_keys(at, save):
    """SAVE PROJECT AS the next free project (003 on led.img's card: the list's cursor on the current one, two DOWNs)
    or LOAD PROJECT of the current one, from anywhere: NOs out, GLOBAL, its menu's top (it keeps its cursor), PROJECT,
    the item. Measured on stock 1.73 (M0, 2026-10-16)."""
    seq = ["NO"] * 4 + ["GLOBAL"] + ["UP"] * 6 + ["YES"] + ["UP"] * 3
    seq += ["DOWN", "YES", "DOWN", "DOWN", "YES", "YES"] if save else ["YES", "YES"]
    return [(at + 150 * i, "press", k) for i, k in enumerate(seq)], at + 150 * len(seq) + (4000 if save else 5000)


def slots_of(e, snap, pat=B0, fw=None):
    """A stored pattern's used lock slots: [(type, track)] (0x80 0x80 continuations included)."""
    L = e.peek(snap, pat + 0x2091, 72 * 66, fw=fw)
    return [(L[66 * i], L[66 * i + 1]) for i in range(72) if L[66 * i] != 0xff]


def fx_locks(e, snap, idx, fw=None):
    """The working pattern's live FX-track lock words at FX index idx, 64 steps."""
    b = e.peek(snap, LIVE_LOCKS + 5674 * 12, 5674, fw=fw)
    return [int.from_bytes(b[88 * st + 2 * idx: 88 * st + 2 * idx + 2], "big") for st in range(64)]


def t_migrate(e):
    """(M1b-a) A U-sound tagged the old way (sound index 0 = the fp, slot 47 = 0) is migrated by sound_load: the tag to
    +0x6e / slot 47, index 0 cleared; it keeps playing on its plugin (the 0x04's tag the fp, no '!')."""
    s, t = U.chosen(e, "migrate-chosen")
    rec = 0x40765913   # BD's project-copy record (stored format)
    s2, c = poke_boot(e, "migrate", {rec + 0x6e: U.FP_A.to_bytes(2, "big"), rec + 0x7a: b"\0\0"}, snap=s,
                      start=e.clock + t)
    U.check("migrate: after the cold boot BD is on U1, its live tag the fp, its live index 0 cleared",
            e.peek(s2, 0x8000ea00, 1)[0] == 35 and U.word0(e, s2)[0] == U.FP_A and U.index0(e, s2)[0] == 0,
            f"tag {U.word0(e, s2)}, index 0 {U.index0(e, s2)}, fp {U.FP_A:#x}")
    print(f"    project copy after the boot: slot 47 {U.word0(e, s2)[1]:#06x}, slot 41 {U.index0(e, s2)[1]:#06x}")
    ev = [(100, "usb", b"".join(U.u1_fp(U.FP_A))), (250, "usb", P.slots([5, 0, 0, 0, 0], 0)), (400, "press", "BD")]
    s3 = e.run("migrate-play", 700, ev, snap=s2, start=4400, card=c, save=True)
    tr = [x for x in U.trigs(e) if x.get("machine") == 0x50]
    U.check("migrate: BD's trig - 0x04 of U1 with the tag fp (the host plays it); no '!' (CHOOSE)",
            bool(tr) and tr[-1]["tag"] == U.FP_A and e.cstr(s3, U.sym("us_l1")) == "CHOOSE", f"{tr[-1:]} {e.cstr(s3, U.sym('us_l1'))}")


def t_sendlock(e):
    """(M1b-a) SEND p-locks on a user-slot track: BD on U1 (tagged), type 41 locks with the fine slot on steps 1 and 5:
    the SENDFX reports carry them per step and every 0x04 keeps the tag (the locks no longer touch it)."""
    s, t = U.chosen(e, "sendlock-chosen")
    ed = {B0 + 0x2091 + 66 * FREE_SLOT: lockslot(41, 0, {0: 0x40, 4: 0x20}) + bytes([0x80, 0x80]) +
          lockslot(0, 0, {0: 0x10, 4: 0x7f})[2:]}
    ed.update(trig_bits(e, s, 0, [0, 4, 8, 12]))
    s2, c = poke_boot(e, "sendlock", ed, snap=s, start=e.clock + t)
    base = U.index0(e, s2)[0]
    ev = [(50, "usb", b"".join(U.u1_fp(U.FP_A))), (150, "usb", P.slots([5, 0, 0, 0, 0], 0)), (300, "press", "PLAY")]
    e.run("sendlock-play", 1000, ev, snap=s2, start=4400, card=c, extra=["--every", "5M"],
          env={"DTBOOT_PEEK": "8000e5b0"})
    seq = [v for _, v in changes([(w, ws[0]) for w, tr_, ws in sendfx_rx(e, "sendlock-play") if tr_ == 0], 4700)]
    want = [0x4020, 0x20fe, base] * 2
    U.check(f"sendlock: BD's SEND reports per step - 4020 20fe {base:04x}, twice", seq[:6] == want,
            " ".join("%04x" % v for v in seq[:8]))
    tags = [x["tag"] for x in U.trigs(e) if x.get("machine") == 0x50]
    U.check("sendlock: every U1 0x04 carries the tag fp (the SEND locks leave it)", len(tags) >= 6 and
            all(g == U.FP_A for g in tags), f"{len(tags)} trigs, tags {sorted(set(tags))}")


def _fx38_check(e, snap, what, fw=None):
    k = [int.from_bytes(e.peek(snap, LIVE_KIT0 + 1942 + 2 * i, 2, fw=fw), "big") for i in range(4)]
    l38, l41 = fx_locks(e, snap, 38, fw), fx_locks(e, snap, 41, fw)
    fine = e.peek(snap, LIVE_LOCKS + 5674 * 12 + 5632 + 38, 4, fw=fw)
    U.check(f"fx38: {what} - kit FX 38..41 1100 2200 3300 4400, locks FX 38 step 1 2122 (fine flag), FX 41 step 9 7e00",
            k == [0x1100, 0x2200, 0x3300, 0x4400] and l38[0] == 0x2122 and l41[8] == 0x7e00 and fine[0] == 1 and
            l38[1:].count(0xffff) == 63 and l41.count(0xffff) == 63,
            f"kit {' '.join('%04x' % x for x in k)}, 38 s1 {l38[0]:04x}, 41 s9 {l41[8]:04x}, fine {fine.hex()}")


def t_fx38(e):
    """(M1b-b) FX words 38..41: kit storage 0x816..0x81D and lock types 42..49 load, play, survive SAVE PROJECT (the
    full rebuild of every pattern), LOAD PROJECT and a stock incremental save; no types 9..12 written."""
    ed = {ST_KIT + 0x816: bytes.fromhex("1100220033004400"),
          B0 + 0x2091 + 66 * FREE_SLOT: lockslot(42, 12, {0: 0x21}) + lockslot(46, 12, {0: 0x11}) +
          lockslot(45, 12, {8: 0x7e})}
    ed.update(trig_bits(e, e.snap, 12, [0, 8]))
    s, c = poke_boot(e, "fx38", ed)
    _fx38_check(e, s, "after the cold boot (kit loader, lock loader)")
    e.run("fx38-play", 700, [(100, "press", "PLAY")], snap=s, start=4400, card=c, extra=["--every", "5M"],
          env={"DTBOOT_PEEK": "8000e5b0"})
    fx = changes([(w, tuple(ws[2:])) for w, tr_, ws in sendfx_rx(e, "fx38-play") if tr_ == 12], 4500)
    want = [(0x2122, 0x2200, 0x3300, 0x4400), (0x1100, 0x2200, 0x3300, 0x7e00)]
    U.check("fx38: SENDFX FX words 38..41 - step 1 2122 2200 3300 4400, step 9 1100 2200 3300 7e00",
            [v for _, v in fx][:4] == want * 2, str([tuple("%04x" % x for x in v) for _, v in fx[:4]]))
    ev, t = proj_keys(100, True)
    s2 = e.run("fx38-save", t, ev, snap=s, start=4400, card=c, save=True, count=[0x40009216])
    sl = slots_of(e, s2)
    U.check("fx38: SAVE PROJECT AS 003 - 129 full rebuilds; A01's stored slots hold (42,12) (46,12) (45,12), no type "
            "9..12 on track 12", e.counts.get(0x40009216) == 129 and {(42, 12), (46, 12), (45, 12)} <= set(sl) and
            not [x for x in sl if x[1] == 12 and 9 <= x[0] <= 12], f"{e.counts.get(0x40009216)} {sl}")
    U.check("fx38: the project copy's FX storage 0x816 holds 1100 2200 3300 4400 after the save (kit saver)",
            e.peek(s2, ST_KIT + 0x816, 8) == bytes.fromhex("1100220033004400"), e.peek(s2, ST_KIT + 0x816, 8).hex())
    # wipe the live kit words, the project copy's, the live locks and A01's stored slots, then LOAD PROJECT 003
    wipe = {LIVE_KIT0 + 1942: bytes(8), ST_KIT + 0x816: bytes(8), B0 + 0x2091: b"\xff" * (72 * 66 - 4)}
    for st in (0, 8):
        wipe[LIVE_LOCKS + 5674 * 12 + 88 * st + 76] = b"\xff" * 8
    s3 = e.run("fx38-wiped", 50, snap=s2, start=4400 + t, card=c, save=True, extra=pokes(e, s2, wipe))
    U.check("fx38: wiped", fx_locks(e, s3, 38)[0] == 0xffff and not slots_of(e, s3), str(slots_of(e, s3)[:3]))
    ev, t2 = proj_keys(100, False)
    s4 = e.run("fx38-load", t2, ev, snap=s3, start=4400 + t + 50, card=c, save=True)
    _fx38_check(e, s4, "LOAD PROJECT 003 (from the file)")
    # a stock incremental save: a p-lock on the FX track's page (T1 held, knob A turned)
    t3 = 4400 + t + 50 + t2
    ev = [(100 + 150 * i, "press", "NO") for i in range(4)] + [(800, "press", "FX"), (950, "press", "RECORD"),
          (1100, "press", "T1:500M"), (1200, "turn", ("0:+3", 4, 10)), (1700, "press", "RECORD")]
    s5 = e.run("fx38-incr", 2000, ev, snap=s4, start=t3, card=c, save=True, count=[0x4000940c, 0x40009216],
               env=steps_env(e, "incr"))
    incr = e.counts.get(0x4000940c, 0)
    sl5 = slots_of(e, s5)
    new = [x for x in sl5 if x not in slots_of(e, s4)]
    U.check("fx38: a stock p-lock on the FX track (RECORD, T1 held, knob A) - the incremental save ran once and added "
            "its slot; ours kept, no type 9..12 on track 12", incr >= 1 and bool(new) and
            {(42, 12), (46, 12), (45, 12)} <= set(sl5) and not [x for x in sl5 if x[1] == 12 and 9 <= x[0] <= 12],
            f"incremental saves {incr}, new slots {new}; {sl5}")
    # and the power-off after it (the state as stored, then a cold boot loads it again)
    e.run("fx38-incr-off", 400, snap=s5, start=t3 + 2000, card=c, extra=["--power-off", f"{t3 + 2100}M"])
    s6 = e.run("fx38-incr-boot", 4400, DIALOGS, cold=True, card=c, save=True)
    _fx38_check(e, s6, "the power-off and cold boot after it")
    _fx38_check(e, s5, "after the incremental save")
    e.fx38 = (s2, c, 4400 + t)   # the saved project's state, for t_stock


def t_stock(e):
    """(M1b) The mod's saved project on stock 1.73: a cold boot of the stock image on that card and LOAD PROJECT 003
    there - no FX 18..21 (or 38..41) lock appears, slot 47 ignored (the U track DISABLE); stock's SAVE PROJECT drops
    types 42..49 and writes no 9..12."""
    if not getattr(e, "fx38", None):
        t_fx38(e)
    s2, c, at = e.fx38
    s, _ = poke_boot(e, "stock", {}, snap=s2, start=at, card=c, fw=STOCK)
    def none_18_21(snap):
        return all(v == 0xffff for i in (18, 19, 20, 21, 38, 39, 40, 41) for v in fx_locks(e, snap, i, STOCK))
    sl = slots_of(e, s, fw=STOCK)
    U.check("stock: cold boot on the mod's card - no live FX 18..21 / 38..41 lock; the stored slots kept raw, no "
            "type 9..12 on track 12", none_18_21(s) and not [x for x in sl if x[1] == 12 and 9 <= x[0] <= 12],
            str(sl))
    ev, t = proj_keys(100, False)
    s3 = e.run("stock-load", t, ev, snap=s, start=4400, card=c, save=True, fw=STOCK)
    U.check("stock: LOAD PROJECT 003 (saved by the mod) - no live FX 18..21 / 38..41 lock", none_18_21(s3))
    ev, t2 = proj_keys(100, True)
    s4 = e.run("stock-save", t2, ev, snap=s3, start=4400 + t, card=c, save=True, fw=STOCK, env=steps_env(e, "stocksave"))
    ev, t3 = proj_keys(100, False)   # LOAD PROJECT of what stock saved (005: the cursor on 003, two DOWNs)
    s5 = e.run("stock-reload", t3, ev, snap=s4, start=4400 + t + t2, card=c, save=True, fw=STOCK)
    sl = slots_of(e, s5, fw=STOCK)
    U.check("stock: SAVE PROJECT on stock, then LOAD it - types 42..49 dropped, no type 9..12 on track 12, no live "
            "FX 18..21 lock", not [x for x in sl if x[1] == 12 and (9 <= x[0] <= 12 or 42 <= x[0] <= 49)] and
            none_18_21(s5), str(sl))


TESTS = {"report": t_report, "migrate": t_migrate, "sendlock": t_sendlock, "fx38": t_fx38, "stock": t_stock}


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
