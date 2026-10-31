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


TRIG = 0x8000e5b0            # trig_sound_array: track t at + 84 t
SFX_S = (0x1100, [0x2a54, 0x3b66, 0x1100, 0x2200, 0x3300, 0x4400])   # BD word 0; FX words 0, 29, 38..41


def kit_vals(kit, bd, fx, trig=True):
    """Pokes: BD's sound index 0 and FX words 0/29/38..41 in live kit `kit` (sound t's words at + 42 + 152 t + 20, the
    FX track's at + 1866) and, with trig, in the trig array."""
    k = LIVE_KIT0 + 2531 * kit
    ed = {k + 62: bd.to_bytes(2, "big")}
    for i, w in zip((0, 29, 38, 39, 40, 41), fx):
        ed[k + 1866 + 2 * i] = w.to_bytes(2, "big")
        if trig:
            ed[TRIG + 84 * 12 + 2 * i] = w.to_bytes(2, "big")
    if trig:
        ed[TRIG] = bd.to_bytes(2, "big")
    return ed


def sfx_rows(e, run):
    """A run's SENDFX messages of BD and the FX track as (clock M, (BD word,) or (FX words ...))."""
    return [(w, tr, tuple(ws)) for w, tr, ws in sendfx_rx(e, run) if tr in (0, 12) and w is not None]


def fmt(v):
    return " ".join("%04x" % x for x in v)


def _after(rows, frm, to, want):
    """rows from clock frm to to: (BD rows, FX rows, every one the wanted value)."""
    bd = [v for w, tr, v in rows if frm <= w < to and tr == 0]
    fx = [v for w, tr, v in rows if frm <= w < to and tr == 12]
    return bd, fx, bool(bd) and bool(fx) and all(v == (want[0],) for v in bd) and all(v == tuple(want[1]) for v in fx)


def t_reload(e):
    """(bug 2026-10-30) SAVE KIT, edits on the Rytm (AMPLITUDE 2 SFX1 on BD, SEND FX 1 / 2 knobs), RELOAD KIT, more
    edits (SEND FX 2), RELOAD ALL, stopped: after each reload the SENDFX messages carry the saved values (BD 1100, FX 2a54 3b66
    1100 2200 3300 4400) and none after it (the round robin's included) carries an edited one."""
    ev, t = U.kit_menu(100, 2)   # SAVE KIT: the kit list, its name, YES saves
    ev += [(t + 200, "press", "YES"), (t + 400, "press", "YES")]
    s = e.run("reload-save", t + 1200, ev, save=True, extra=pokes(e, e.snap, kit_vals(0, SFX_S[0], SFX_S[1])))
    def edits(at):
        return [(at - 600 + 150 * i, "press", "NO") for i in range(4)] + [(at, "press", "BD"), (at + 50, "press", "AMP"),
                (at + 100, "press", "AMP"), (at + 250, "turn", ("0:+20", 5, 20)), (at + 450, "press", "FX"),
                (at + 550, "press", "SRC"), (at + 650, "turn", ("0:+20", 2, 20)), (at + 750, "turn", ("2:+20", 4, 20)),
                (at + 850, "press", "SMPL"), (at + 950, "press", "SMPL"), (at + 1050, "turn", ("0:+20", 3, 20)),
                (at + 1150, "turn", ("3:+20", 3, 20))]
    def edits2(at):   # the page the first edits left (SEND FX 2 on the FX track): its knobs again
        return [(at - 600 + 150 * i, "press", "NO") for i in range(4)] + [(at, "turn", ("0:+20", 3, 20)),
                (at + 100, "turn", ("3:+20", 3, 20))]
    ev = edits(650)
    ev1, t1 = U.kit_menu(2200, 0)                      # RELOAD (KIT menu, its top), its YES
    yes1 = t1 + 200
    ev += ev1 + [(yes1, "press", "YES")] + edits2(yes1 + 1600)
    at = yes1 + 3200                                    # RELOAD ALL: the KIT menu's RELOAD set to ALL (RIGHT)
    ev += [(at, "press", "FUNC:300M"), (at + 20, "press", "PLAYMODE")]
    tt = at + 400
    for k in ["UP"] * 3 + ["RIGHT", "YES"]:
        ev.append((tt, "press", k))
        tt += U.UI["step_M"]
    yes2 = tt + 200
    ev.append((yes2, "press", "YES"))
    start = e.clock + t + 1200
    end = yes2 + 2000
    e.run("reload-run", end, ev, snap=s, start=start, count=[0x400af0d2, 0x400b131a], extra=["--every", "5M"],
          env={"DTBOOT_PEEK": "8000e5b0"})
    rows = sfx_rows(e, "reload-run")
    U.check("reload: RELOAD KIT ran once (0x400af0d2), RELOAD ALL once (0x400b131a)",
            e.counts.get(0x400af0d2) == 1 and e.counts.get(0x400b131a) == 1, str(e.counts))
    pre = [v for w, tr, v in rows if w < start + yes1]
    U.check("reload: the edits were reported before the reload (BD and FX values other than the saved ones)",
            any(v != (SFX_S[0],) for v in pre if len(v) == 1) and any(v != tuple(SFX_S[1]) for v in pre if len(v) == 6),
            " / ".join(fmt(v) for v in sorted(set(pre))[:6]))
    first = next((w for w, tr, v in rows if w >= start + yes1 and v in ((SFX_S[0],), tuple(SFX_S[1]))), None)
    print(f"    RELOAD KIT's YES at {start + yes1}M, the first saved value reported at {first}M")
    bd, fx, ok = _after(rows, (first or 0), start + yes1 + 1000, SFX_S)   # (the next edits from + 1600)
    U.check("reload: after RELOAD KIT, every BD / FX report up to the next edits is the saved value (no revert)",
            first is not None and first - (start + yes1) <= 200 and ok,
            f"{len(bd)} BD, {len(fx)} FX: {' / '.join(fmt(v) for v in sorted(set(bd + fx)))}")
    mid = [v for w, tr, v in rows if start + yes1 + 1600 <= w < start + yes2]
    U.check("reload: the second edits reported", any(v != tuple(SFX_S[1]) for v in mid if len(v) == 6),
            " / ".join(fmt(v) for v in sorted(set(mid))[:6]))
    first2 = next((w for w, tr, v in rows if w >= start + yes2 and v in ((SFX_S[0],), tuple(SFX_S[1]))), None)
    print(f"    RELOAD ALL's YES at {start + yes2}M, the first saved value reported at {first2}M")
    bd, fx, ok = _after(rows, (first2 or 0), start + end, SFX_S)
    U.check("reload: after RELOAD ALL, every BD / FX report to the end (2000M, the round robin twice over) is the "
            "saved value", first2 is not None and first2 - (start + yes2) <= 200 and ok and len(fx) >= 2,
            f"{len(bd)} BD, {len(fx)} FX: {' / '.join(fmt(v) for v in sorted(set(bd + fx)))}")


def t_kitswitch(e):
    """(2026-10-30) A pattern on another kit, stopped: A01 (kit 0) to A02 (kit 1) leaves the trig array on kit 0's
    sounds until each track trigs; the reports carry kit 1's values from the switch on (BD 4400, FX 0600 0700 7700
    0800 0900 0a00) and none of kit 0's after. Then PLAY: A02's FX trigs (steps 1 and 9, a FX word 0 lock 0x55 on
    step 1) report the lock on step 1 and kit 1's 0600 on step 9."""
    a2 = ST_PAT + 13101 * 2      # bank pattern A02
    kit1 = e.peek(e.snap, a2 + 0x3325, 1)[0]
    used = [i for i in range(72) if e.peek(e.snap, a2 + 0x2091 + 66 * i, 1)[0] != 0xff]
    free = max(used) + 1 if used else 0
    ed = {a2 + 0x2091 + 66 * free: lockslot(37, 12, {0: 0x55})}
    ed[a2 + 0x2091 + 66 * (free + 1)] = lockslot(41, 0, {0: 0x77})   # BD: sound index 0 lock 0x77 on step 1
    for tr, steps in ((12, (0, 8)), (0, (0, 4))):                     # FX trigs on 1, 9; BD trigs on 1, 5
        n = int.from_bytes(e.peek(e.snap, a2 + 4 + 641 * tr, 112), "big")
        for i in steps:
            sh = 14 * (63 - i)
            n = (n & ~(0x3fff << sh)) | (0x381 << sh)
        ed[a2 + 4 + 641 * tr] = n.to_bytes(112, "big")
    s, c = poke_boot(e, "kitswitch", ed)
    k0 = (int.from_bytes(e.peek(s, TRIG, 2), "big"),
          [int.from_bytes(e.peek(s, TRIG + 84 * 12 + 2 * i, 2), "big") for i in (0, 29, 38, 39, 40, 41)])
    want = (0x4400, [0x0600, 0x0700, 0x7700, 0x0800, 0x0900, 0x0a00])
    U.check(f"kitswitch: A02 is on kit {kit1} (not 0), lock slot {free}; kit 0's values differ from kit 1's",
            kit1 != 0 and k0[0] != want[0] and k0[1] != want[1], f"kit 0: {k0[0]:04x} {fmt(k0[1])}")
    sw, play = 300, 1600
    ev = [(sw, "press", "BANK_A:200M"), (sw + 50, "press", "T2"), (play, "press", "PLAY")]
    e.run("kitswitch-run", play + 900, ev, snap=s, start=4400, card=c, env={"DTBOOT_PEEK": "8000e5b0"},
               extra=["--every", "5M"] + pokes(e, s, kit_vals(kit1, want[0], want[1], trig=False)))
    rows = sfx_rows(e, "kitswitch-run")
    first = next((w for w, tr, v in rows if w >= 4400 + sw and v in ((want[0],), tuple(want[1]))), None)
    print(f"    the switch at {4400 + sw}M (T2 {4400 + sw + 50}M), kit 1's values first reported at {first}M")
    bd, fx, ok = _after(rows, (first or 0) + 5, 4400 + play, want)
    U.check("kitswitch: stopped, from the switch on every BD / FX report is kit 1's (the round robin's included)",
            first is not None and ok and len(fx) >= 2, f"{len(bd)} BD, {len(fx)} FX: "
            f"{' / '.join(fmt(v) for v in sorted(set(bd + fx)))}")
    fxp = [v[0] for _, v in changes([(w, v) for w, tr, v in rows if tr == 12], 4400 + play)]
    U.check("kitswitch: PLAY on A02 - FX word 0 5500 (the step 1 lock), then 0600 (kit 1's, step 9)",
            fxp[:2] == [0x5500, 0x0600], fmt(fxp[:6]))
    U.check("kitswitch: the other FX words stay kit 1's while playing",
            all(v[1:] == tuple(want[1][1:]) for w, tr, v in rows if tr == 12 and w >= 4400 + play),
            " / ".join(sorted({fmt(v[1:]) for w, tr, v in rows if tr == 12 and w >= 4400 + play})))
    bdp = [v[0] for _, v in changes([(w, v) for w, tr, v in rows if tr == 0], 4400 + play)]
    U.check("kitswitch: PLAY on A02 - BD's trigs: the step 1 lock 7700, then kit 1's 4400 (step 5)",
            0x7700 in bdp and set(bdp) <= {0x7700, 0x4400} and bdp[bdp.index(0x7700):][:2] == [0x7700, 0x4400],
            fmt(bdp[:8]))
    ev = [(sw, "press", "BANK_A:200M"), (sw + 50, "press", "T2"), (sw + 800, "press", "BANK_A:200M"),
          (sw + 850, "press", "T1")]
    e.run("kitswitch-back", sw + 1700, ev, snap=s, start=4400, card=c, env={"DTBOOT_PEEK": "8000e5b0"},
          extra=["--every", "5M"] + pokes(e, s, kit_vals(kit1, want[0], want[1], trig=False)))
    rows = sfx_rows(e, "kitswitch-back")
    back = 4400 + sw + 800
    mid = [v for w, tr, v in rows if 4400 + sw + 300 <= w < back]
    first = next((w for w, tr, v in rows if w >= back and v in ((k0[0],), tuple(k0[1]))), None)
    bd, fx, ok = _after(rows, (first or 0) + 5, 4400 + sw + 1700, k0)
    U.check("kitswitch: A01 -> A02 -> A01, stopped - kit 1's values in between, then kit 0's again, none of kit 1's "
            "after", bool(mid) and all(v in ((want[0],), tuple(want[1])) for v in mid) and first is not None and ok,
            f"between {' / '.join(fmt(v) for v in sorted(set(mid)))}; back at {first}M; {len(bd)} BD, {len(fx)} FX: "
            f"{' / '.join(fmt(v) for v in sorted(set(bd + fx)))}")
    # a switch while playing: A01 plays, A02 is queued (it starts at A01's end)
    ev = [(100, "press", "PLAY"), (150, "press", "BANK_A:200M"), (200, "press", "T2")]
    e.run("kitswitch-live", 2400, ev, snap=s, start=4400, card=c, env={"DTBOOT_PEEK": "8000e5b0"},
          extra=["--every", "5M"] + pokes(e, s, kit_vals(kit1, want[0], want[1], trig=False)))
    rows = sfx_rows(e, "kitswitch-live")
    a2 = next((w for w, tr, v in rows if tr == 0 and v == (0x7700,)), None)
    print(f"    PLAY at {4400 + 100}M, A02 queued at {4400 + 150}M, its BD step 1 lock first reported at {a2}M")
    bd = [v[0] for w, tr, v in rows if tr == 0 and a2 is not None and w >= a2 - 5]
    fx = [v for w, tr, v in rows if tr == 12 and a2 is not None and w >= a2 - 5]
    U.check("kitswitch: switch while playing - from A02's start BD reports 7700 / 4400 only (kit 1's, not kit 0's), "
            "FX words 29..41 are kit 1's, word 0 5500 / 0600", a2 is not None and set(bd) == {0x7700, 0x4400} and
            len(fx) >= 2 and all(v[1:] == tuple(want[1][1:]) and v[0] in (0x5500, 0x0600) for v in fx),
            f"{len(bd)} BD {' '.join('%04x' % x for x in sorted(set(bd)))}; {len(fx)} FX {' / '.join(sorted({fmt(v) for v in fx}))}")
    # a UI edit of FX 38 (SEND FX 1 knob 3) and FX 40 (SEND FX 2 knob 4) after a switch, stopped
    ev = [(sw, "press", "BANK_A:200M"), (sw + 50, "press", "T2")] + [(sw + 300 + 150 * i, "press", "NO") for i in range(4)]
    at = sw + 1000
    ev += [(at, "press", "FX"), (at + 50, "press", "SRC"), (at + 150, "turn", ("2:+20", 4, 20)),
           (at + 250, "press", "SMPL"), (at + 350, "press", "SMPL"), (at + 450, "turn", ("3:+20", 3, 20))]
    e.run("kitswitch-ui", at + 1100, ev, snap=s, start=4400, card=c, env={"DTBOOT_PEEK": "8000e5b0"},
          extra=["--every", "5M"] + pokes(e, s, kit_vals(kit1, want[0], want[1], trig=False)))
    rows = sfx_rows(e, "kitswitch-ui")
    pre = [v for w, tr, v in rows if tr == 12 and 4400 + sw + 300 <= w < 4400 + at]
    post = [v for w, tr, v in rows if tr == 12 and w >= 4400 + at + 700]
    bd = {v for w, tr, v in rows if tr == 0 and w >= 4400 + sw + 300}
    ok = bool(post) and len(set(post)) == 1 and post[0][2] != want[1][2] and post[0][4] != want[1][4] and \
        (post[0][:2], post[0][3], post[0][5]) == (tuple(want[1][:2]), want[1][3], want[1][5])
    U.check("kitswitch: UI edits of FX 38 / 40 after the switch - kit 1's before, then the edited words (0, 29, 39, 41 "
            "kit 1's) with no revert; BD stays 4400", bool(pre) and set(pre) == {tuple(want[1])} and ok and
            bd == {(want[0],)}, f"before {' / '.join(sorted({fmt(v) for v in pre}))}; after "
            f"{' / '.join(sorted({fmt(v) for v in post}))}; BD {' '.join(fmt(v) for v in sorted(bd))}")


def t_nokit(e):
    """(2026-10-30, the user's key) SAVE KIT, SEND FX 1 / 2 knob edits on the FX track, NO + KIT (0x400cd4ae ->
    kit_reload) from that page, stopped; then PLAY, edits, NO + KIT again: each reload sends 4C RELOAD (0026) and the
    SENDFX reports carry the saved FX words from then on, none reverting."""
    ev, t = U.kit_menu(100, 2)
    ev += [(t + 200, "press", "YES"), (t + 400, "press", "YES")]
    s = e.run("nokit-save", t + 1200, ev, save=True, extra=pokes(e, e.snap, kit_vals(0, SFX_S[0], SFX_S[1])))
    def edits(at):
        return [(at, "turn", ("0:+20", 2, 20)), (at + 100, "turn", ("2:+20", 4, 20)), (at + 200, "turn", ("5:+20", 3, 20))]
    ev = [(50 + 150 * i, "press", "NO") for i in range(4)] + [(700, "press", "FX"), (800, "press", "SRC")] + edits(900)
    nk1, play, nk2, end = 1600, 2600, 3600, 5000
    ev += [(nk1, "press", "NO:80M"), (nk1 + 20, "press", "PLAYMODE"), (play, "press", "PLAY")] + edits(play + 300)
    ev += [(nk2, "press", "NO:80M"), (nk2 + 20, "press", "PLAYMODE")]
    start = e.clock + t + 1200
    e.run("nokit-run", end, ev, snap=s, start=start, count=[0x400cd4ae, 0x400af0d2], extra=["--every", "5M"],
          env={"DTBOOT_PEEK": "8000e5b0"})
    kr = [m for m in e.sent if len(m) >= 7 and m[4] == 0x4c and m[6] == 2]
    U.check("nokit: NO + KIT twice - the stock combo's kit_reload call (0x400cd4ae) twice, 4C RELOAD twice",
            e.counts.get(0x400cd4ae) == 2 and e.counts.get(0x400af0d2) == 2 and len(kr) == 2,
            f"{e.counts}, {[m.hex() for m in kr]}")
    rows = [(w, v) for w, tr, v in sfx_rows(e, "nokit-run") if tr == 12]
    want = tuple(SFX_S[1])
    for name, a, b in (("stopped", nk1, play + 300), ("playing", nk2, end)):
        pre = [v for w, v in rows if start + a - 300 <= w < start + a]
        first = next((w for w, v in rows if w >= start + a and v == want), None)
        after = [v for w, v in rows if first is not None and first <= w < start + b]
        U.check(f"nokit: {name} - edited FX words reported before NO + KIT, the saved ones within 200M after it and "
                f"every report after them up to {'PLAY' if b != end else 'the end'}", bool(pre) and want not in pre and
                first is not None and first - (start + a) <= 200 and bool(after) and all(v == want for v in after),
                f"before {fmt(pre[-1]) if pre else '-'}; first {first and first - start - a}M; "
                f"{' / '.join(sorted({fmt(v) for v in after}))}")


TESTS = {"report": t_report, "migrate": t_migrate, "sendlock": t_sendlock, "fx38": t_fx38, "stock": t_stock,
         "reload": t_reload, "kitswitch": t_kitswitch, "nokit": t_nokit}


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
