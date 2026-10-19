#!/usr/bin/env python3
"""Emulator tests of 0021's 25 SLOT PRINTS (slot-resolve, 2026-10-19; mods/0021-ext/design.md "Slot fingerprints at
project load") in rytm-emu: the Rytm's USB MIDI out read back and decoded with rytm-teensy sim/protocol.py
(decode_slot_prints), the sounds' machine bytes and tags poked into the 128 resident kits and the sound pool.

    .venv/bin/python tools/emu/sp_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a slots=1 build with 0029-sendfx-ui (us_live runs from its ev_tick: sfx1019, rui1019) whose base
tools/emu/us_base.sh TAG made. RYTM_TEENSY: a rytm-teensy checkout whose sim/protocol.py has slot_prints.
    prints   U1 on two sounds (kit 0 BD and SD, FP_A), U3 on kit 5's CP (FP_B), U1 on pool entry 5 (FP_B): within
             ~1 s the host gets 10 <project> then 25 with (1, FP_A, 2), (1, FP_B, 1), (3, FP_B, 1), seq moved; the
             25 is repeated every ~5 s with the same seq and content
    load     from a cold boot, the same entries in the active kit and the pool saved (SAVE PROJECT AS), the tags wiped
             in RAM (n 0, seq moves), LOAD PROJECT: the 10 + 25 with them again (from the card) ~1 s after the load's
             YES, before PLAY; PLAY's first trig report comes after it
    change   a choice (U1 on BD in the machine list) moves seq, the entry follows; RELOAD KIT (the kit back as
             saved: BD untagged) moves it again, n 0
    trunc    132 sounds on (2, FP_C) and 17 more distinct (1, fp) pairs: 16 entries, flags bit 0, (2, FP_C) counted 127
    mutex    the MIDI mutex held by another task (frz_emu's poke): the UI renders at 20 Hz and no 25 goes out; the
             mutex given back: the 10 + 25 at the next retry
Firmware-derived output stays in rytm-emu's git-ignored sections/ and in build/emu/TAG.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import us_emu as U          # noqa: E402  (Emu, check, the protocol module as U.P)
import sfx_emu as S         # noqa: E402  (pokes, proj_keys)
P = U.P

KIT = 0x4125590d            # resident kit k, track t: + 2531 k + 152 t (the live sound format)
POOL = 0x41313c47           # sound pool entry i: + 152 i
MACH, TAG = 0x68, 0x6e      # machine byte, tag (+0x6e / +0x6f, 14 bits)
FP_A, FP_B, FP_C = U.FP_A, U.FP_B, P.plugin_fp("rytm.third")
RENDER = 0x400a2aaa         # frz_emu: the UI renders (20 Hz)


def kit(k, t):
    return KIT + 2531 * k + 152 * t


def pool(i):
    return POOL + 152 * i


def sound(addr, machine, fp):
    """Pokes for one sound: its machine byte and its tag."""
    return {addr + MACH: bytes([machine]), addr + TAG: fp.to_bytes(2, "big")}


def edits(*sounds):
    ed = {}
    for a, m, fp in sounds:
        ed.update(sound(a, m, fp))
    return ed


THREE = [(kit(0, 0), 35, FP_A), (kit(0, 1), 35, FP_A), (kit(5, 3), 37, FP_B), (pool(5), 35, FP_B)]
WANT3 = sorted([(1, FP_A, 2), (1, FP_B, 1), (3, FP_B, 1)])
# the load test's: all in the active kit 0 (a poke into another resident kit is not written by SAVE PROJECT: measured,
# kit 5's poked U3 did not come back from the saved project - the save is not what is tested here)
LOADSET = [(kit(0, 0), 35, FP_A), (kit(0, 1), 35, FP_A), (kit(0, 3), 37, FP_B), (pool(5), 35, FP_B)]


def timed(e, run):
    """The Rytm's SysEx of run `run` in order, each with the clock (M, absolute) of the 10M window it appeared in
    (the run needs --every 10M and DTBOOT_PEEK, which prints usb_midi_out's length each window)."""
    marks, clock = [], None
    for line in e.log.splitlines():
        m = re.match(r"^\s*(\d+)M pc=", line)
        if m:
            clock = int(m.group(1))
        m = re.search(r"usb_midi_out=(\d+)", line)
        if m and clock is not None:
            marks.append((clock, int(m.group(1))))
    path = os.path.join(e.tmp, f"{run}.usb")
    dump = open(path, "rb").read() if os.path.exists(path) else b""
    out, pos = [], 0
    for msg in U.sysex(dump):
        pos = dump.index(msg, pos) + len(msg)
        out.append((next((ck for ck, n in marks if n >= pos), None), msg))
    return out


def run(e, name, length, events=(), ed=None, snap=None, start=None, extra=(), save=True, count=(), card=None):
    snap = snap or e.snap
    x = list(extra) + (S.pokes(e, snap, ed) if ed else []) + ["--every", "10M"]
    s = e.run(name, length, events, save=save, snap=snap, start=start, extra=x, count=count, card=card,
              env={"DTBOOT_PEEK": "407c89d3"})
    return s, timed(e, name)


def prints(rows):
    """[(clock, decoded 25, the message before it, its row)] of a run's rows."""
    out = []
    for i, (ck, m) in enumerate(rows):
        r = P.parse(m)
        if r and r[0] == P.SLOT_PRINTS:
            out.append((ck, P.decode_slot_prints(r[1]), rows[i - 1][1] if i else b"", i))
    return out


def ten(m):
    return len(m) > 5 and m[4] == 0x10


def seq0(e, s):
    return e.peek(s, U.sym("sp") + 9, 1)[0]


def desc(p):
    return f"seq {p['seq']} flags {p['flags']} {[(a, hex(b), c) for a, b, c in p['entries']]}" if p else "none"


def t_prints(e):
    """THREE poked into the base: the next 25 lists them (10 first), seq moved, then repeats every ~5 s unchanged."""
    s0 = e.snap
    base = seq0(e, s0)
    s, rows = run(e, "prints", 2400, ed=edits(*THREE))
    ps = prints(rows)
    got = [p for p in ps if p[1] and p[1]["entries"]]
    check = U.check
    check("prints: a 25 decodes (rytm-teensy decode_slot_prints)", bool(ps) and all(p[1] for p in ps), str(len(ps)))
    check("prints: the first 25 after the pokes - (1, FP_A, 2), (1, FP_B, 1), (3, FP_B, 1), flags 0, seq moved",
          bool(got) and sorted(got[0][1]["entries"]) == WANT3 and got[0][1]["entries"] == WANT3 and
          got[0][1]["flags"] == 0 and got[0][1]["seq"] == (base + 1) & 0x7f, desc(got[0][1] if got else None))
    t0 = got[0][0] - e.clock if got and got[0][0] else None
    check("prints: within ~1 s of the change (one scan a second: <= 210M)", t0 is not None and t0 <= 210, f"{t0}M")
    check("prints: every 25 right after a 10 <project> (one lock)", all(ten(p[2]) for p in ps),
          " ".join(p[2][:5].hex() for p in ps))
    rep = [p for p in got if p[1] == got[0][1]]
    gaps = [b[0] - a[0] for a, b in zip(rep, rep[1:])]
    check("prints: repeated unchanged (same seq, same entries) every ~5 s (1000M +- 60)",
          len(rep) == len(got) >= 2 and all(940 <= g <= 1060 for g in gaps), f"{len(rep)} of {len(got)}, gaps {gaps}")
    print(f"    first 25 at +{t0}M ({desc(got[0][1]) if got else '-'}); repeats {gaps}")
    return s


def t_load(e):
    """From a cold boot (sfx_emu's poke_boot: proj_keys' walks are measured from there): LOADSET (THREE, all in kit 0) poked, SAVE PROJECT AS
    (003), the tags wiped in RAM (n 0, seq moves), LOAD PROJECT 003: the 10 + 25 after the load lists LOADSET again;
    PLAY after it: its first U1 0x04 comes after that 25."""
    s0, c = S.poke_boot(e, "load", {})
    clk = 4400
    s, rows = run(e, "load-poked", 300, ed=edits(*LOADSET), snap=s0, start=clk, card=c)
    clk += 300
    ev, t = S.proj_keys(100, True)
    s2, rows = run(e, "load-saved", t, ev, snap=s, start=clk, card=c)
    name = e.cstr(s2, 0x407c89d3)
    clk += t
    wipe = {}
    for a, _, _ in LOADSET:
        wipe[a + TAG] = b"\0\0"
    s3, rows = run(e, "load-wiped", 400, ed=wipe, snap=s2, start=clk, card=c)
    ps = [p for p in prints(rows) if p[1]]
    U.check("load: the tags wiped in RAM - the next 25 says n 0, seq moved", bool(ps) and ps[-1][1]["entries"] == [],
            desc(ps[-1][1] if ps else None))
    wiped_seq = ps[-1][1]["seq"] if ps else None
    clk += 400
    ev, t = S.proj_keys(100, False)
    yes = ev[-1][0]   # the load's last key (LOAD PROJECT's YES)
    play = t          # PLAY at the end of proj_keys' wait (5000M after that YES)
    ev.append((play, "press", "PLAY"))
    s4, rows = run(e, "load", play + 400, ev, snap=s3, start=clk, card=c, count=[0x4011f6bc])
    loads = e.counts.get(0x4011f6bc, 0)
    ps = [x for x in prints(rows) if x[1]]
    after = [x for x in ps if x[1]["entries"]]
    U.check(f"load: LOAD PROJECT ({name!r}) ran a load (0x4011f6bc {loads})", loads >= 1)
    U.check("load: after the load a 25 lists LOADSET again, from the card, seq moved from the wiped one",
            bool(after) and after[0][1]["entries"] == WANT3 and after[0][1]["seq"] != wiped_seq,
            desc(after[0][1] if after else None))
    U.check("load: that 25 right after 10 <project>", bool(after) and ten(after[0][2]) and
            after[0][2][5:-1].decode("ascii", "replace") == name[:15], after[0][2].hex() if after else "")
    when = after[0][0] - (clk + yes) if after and after[0][0] else None
    tr = [i for i, (ck, m) in enumerate(rows) if len(m) > 20 and m[4] == P.TRIG_PARAMS]
    i25 = after[0][3] if after else None
    U.check("load: the 25 before PLAY (pressed 5000M after the load's YES) and before the first trig report",
            when is not None and when < play - yes and (not tr or (i25 is not None and i25 < tr[0])),
            f"25 at +{when}M after the YES, first 0x04 at row {tr[0] if tr else '-'}, 25 at row {i25}")
    seen = [(ck - (clk + yes) if ck else None, len(x["entries"]), x["seq"]) for ck, x, _, _ in ps]
    U.check("load: no half-loaded scan - every 25 of the run is the wiped state (n 0) or the whole LOADSET",
            all(x[1]["entries"] in ([], WANT3) for x in ps), f"(+M after the YES, n, seq): {seen}")
    print(f"    LOAD PROJECT's YES -> 25: {when}M (~{(when or 0) / 200:.2f} s emulated); trig reports after PLAY: {len(tr)}")
    return s4


def t_change(e):
    """A choice (U1 on BD in the machine list, its 1A with FP_A current) moves seq; RELOAD KIT moves it again."""
    base = seq0(e, e.snap)
    ev, t = U.meta_events(100, [U.u1_fp(FP_A)])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    ev2, t2 = U.walk_list(t + 100, U.UI["downs"]["u1"])
    s, rows = run(e, "change", t2 + 400, ev + ev2)
    ps = [p for p in prints(rows) if p[1] and p[1]["entries"]]
    U.check("change: U1 chosen on BD (FP_A) - the next 25 lists (1, FP_A, 1), seq moved",
            bool(ps) and ps[0][1]["entries"] == [(1, FP_A, 1)] and ps[0][1]["seq"] != base, desc(ps[0][1] if ps else None))
    sq = ps[0][1]["seq"] if ps else None
    ev, t3 = U.kit_menu(100, 0)   # RELOAD
    ev += [(t3 + 200, "press", "YES")]
    s3, rows = run(e, "change-reload", t3 + 800, ev, snap=s, start=e.clock + t2 + 400, count=[0x4011f6bc])
    ps = [p for p in prints(rows) if p[1]]
    U.check("change: RELOAD KIT (BD back as saved, untagged) - a load, then a 25 with n 0 and seq moved again",
            e.counts.get(0x4011f6bc, 0) >= 1 and bool(ps) and ps[-1][1]["entries"] == [] and ps[-1][1]["seq"] != sq,
            f"loads {e.counts.get(0x4011f6bc)}, {desc(ps[-1][1] if ps else None)}")


def t_trunc(e):
    """132 sounds on (2, FP_C) (kits 0..10) and 17 distinct (1, fp 1..17) (kits 20, 21): 16 entries, flags 1."""
    many = [(kit(k, t), 36, FP_C) for k in range(11) for t in range(12)]
    many += [(kit(20 + i // 12, i % 12), 35, i + 1) for i in range(17)]
    s, rows = run(e, "trunc", 400, ed=edits(*many))
    ps = [p for p in prints(rows) if p[1]]
    p = ps[-1][1] if ps else None
    want = [(1, i + 1, 1) for i in range(15)] + [(2, FP_C, 127)]
    U.check("trunc: 16 entries - slot 1's fp 1..15, then (2, FP_C) counted 127 (132 sounds); flags bit 0",
            bool(p) and p["entries"] == want and p["flags"] == 1, desc(p))
    m = [m for _, m in rows if m[4] == 0x25]
    U.check("trunc: the 25 is 74 bytes (9 + 16 x 4 + F7)", bool(m) and len(m[-1]) == 74, str(len(m[-1]) if m else 0))


def t_mutex(e):
    """The MIDI mutex owned by a task that never gives it (frz_emu's poke): THREE poked, 3 s: the UI renders at
    20 Hz, no 25; then the owner word back as it was: the 10 + 25 at once."""
    owner = e.peek(e.snap, 0x42f67a28, 4)
    ed = edits(*THREE)
    ed[0x42f67a28] = b"\0\0\0\1"
    s, rows = run(e, "mutex-held", 600, ed=ed, count=[RENDER])
    r = e.counts.get(RENDER, 0)
    ps = prints(rows)
    U.check("mutex: held 600M (3 s) - the UI renders on (>= 55 frames at 20 Hz)", r >= 55, f"{r} renders")
    U.check("mutex: held - no 25 (the try-lock says not now)", not ps, f"{len(ps)}")
    # given back, with sp.left = 10: the retry 10 ticks (50M) after the restore. (A message the firmware hands to
    # USB in the first few M after a snapshot restore does not reach rytm-emu's host: measured here - a release with
    # the retry at the first tick left sp as sent and the dump without it. A restore artifact; nothing on hardware.)
    s2, rows = run(e, "mutex-given", 200, ed={0x42f67a28: owner, U.sym("sp") + 8: b"\x0a"}, snap=s, start=e.clock + 600)
    ps = [p for p in prints(rows) if p[1]]
    t0 = ps[0][0] - (e.clock + 600) if ps and ps[0][0] else None
    U.check("mutex: given back - the 10 + 25 with THREE at the retry (50M) and its USB transfer (<= 120M)",
            bool(ps) and ps[0][1]["entries"] == WANT3 and ten(ps[0][2]) and t0 is not None and t0 <= 120,
            f"{desc(ps[0][1] if ps else None)} at +{t0}M")


def t_choose(e):
    """(fix-1020, the user's METAL-in-every-slot report) BD chosen on U1 (its plugin's tag FP_A), then the machine list
    opened again: DOWN over U2 and U3 with seconds on each (the sound previews on the slot; scans run once a second) and
    YES on U3, whose 1A never came. No 25 names U2 or U3 while the list previews or after the choice (the old tag is
    off at the YES, not carried to a slot that holds no plugin), and the sound's tag is 0 in the kit and the project."""
    s1, t1 = U.chosen(e, "spc-1")
    check = U.check
    check("choose: BD on U1 first - its tag FP_A in the kit and the project", U.word0(e, s1) == (U.FP_A, U.FP_A),
          str(U.word0(e, s1)))
    ev = [(100, "press", "SRC"), (200, "press", "SRC"), (300, "press", "DOWN"), (1500, "press", "DOWN"),
          (2700, "press", "YES")]
    s, rows = run(e, "spc-2", 3900, ev, snap=s1, start=e.clock + t1)
    ps = [p for p in prints(rows) if p[1]]
    slots = sorted({a for p in ps for a, _, _ in p[1]["entries"]})
    during = [p for p in ps if p[0] and p[0] - (e.clock + t1) < 2700]
    check("choose: 25s while the list previews U2 and U3 never name them (none at all: the scan waits for the YES)",
          not any(a in (2, 3) for p in during for a, _, _ in p[1]["entries"]),
          f"{[desc(p[1]) for p in during]}")
    check("choose: no 25 names U2 or U3 after the YES either (slots seen: %s)" % slots, not set(slots) & {2, 3}, str(slots))
    check("choose: U3 chosen with no 1A - the old tag is gone from the kit and the project copy", U.word0(e, s) == (0, 0),
          str(U.word0(e, s)))
    check("choose: BD plays U3 (machine 37)", e.peek(s, 0x8000ea00, 1)[0] == 37, str(e.peek(s, 0x8000ea00, 1)))


TESTS = dict(choose=t_choose, prints=t_prints, load=t_load, change=t_change, trunc=t_trunc, mutex=t_mutex)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    e = U.Emu(sys.argv[1])
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    for n in names:
        print(f"== {n}", flush=True)
        TESTS[n](e)
    print("ALL PASS" if not U.fails else f"FAILED: {len(U.fails)}: " + "; ".join(U.fails))
    sys.exit(1 if U.fails else 0)


if __name__ == "__main__":
    main()
