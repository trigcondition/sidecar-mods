#!/usr/bin/env python3
"""Emulator tests of 0026's sequencer link (1032, the Rytm side of the Sidecar sequencer MVP; design.md "1032"):
the host's 2E marks seq tracks; the Rytm reports their step ticks (2C, stamped with the audio block counter), the
transport, pattern, switch, record, tempo, mutes and seq mode (2D); in seq mode (a seq track selected, GRID REC on)
T1..T16, PAGE and the encoders under a held trig go to the host, which owns the trig LEDs (34) and the PAGE LEDs
(2F); live recording writes nothing on a seq track. Without a 2E everything is stock and nothing new is sent.

    RYTM_EMU=... .venv/bin/python tools/emu/sq_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a rui build with its base from tools/emu/us_base.sh TAG (A01 at 127.0 BPM, BD selected, kit 1). The host's
messages go in on the USB MIDI port, the Rytm's out through DTBOOT_USB_OUT; every run under DTEMU_STRICT=1 with
--usb-host --usb-midi-real. Times are M instructions after the base's clock (200 M = 1 s). The first 2E goes in at
+300 M, after the Rytm's hello (35, +0.5 s after the port came up: a hello forgets the seq tracks).
Addresses [measured, rytm-emu]: the working pattern A01's live track t at 0x407dd8e3 + 917 t (+0x2c5 length, +0x2c7
speed index), the PAGE LEDs 43..40 (page 1..4).
"""
import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EMU = os.environ.get("RYTM_EMU", os.path.join(os.path.dirname(ROOT), "rytm-emu"))
FAILS = []
LIVE = 0x407DD8E3
TRACK = 917
BLOCKS_PER_STEP = 1500 * 60 / 127.0 / 4      # 1x 16th at 127 BPM: 177.2 audio blocks


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"   [{detail}]" if detail != "" else ""), flush=True)
    if not ok:
        FAILS.append(name)


def sx(cmd, *body):
    return bytes([0xF0, 0x7D, 0x52, 0x54, cmd, 0x01, *body, 0xF7])


def mask2e(tracks=(), flags=0, clock=None):
    m = sum(1 << t for t in tracks)
    body = [m & 0x7F, m >> 7 & 0x1F, flags]
    if clock is not None:
        c = sum(1 << t for t in clock)
        body += [c & 0x7F, c >> 7 & 0x1F]
    return sx(0x2E, *body)


def blk(b):
    return b[0] << 21 | b[1] << 14 | b[2] << 7 | b[3]


class Emu:
    def __init__(self, tag):
        self.tag = tag
        self.fw = f"fw/AR173_us_{tag}.syx"
        self.card = f"sections/us_{tag}.img"
        self.base = (os.path.join(EMU, f"sections/us_{tag}.snap"), json.load(open(os.path.join(EMU, f"sections/us_{tag}.json")))["clock"])
        self.out = os.path.join(os.environ.get("RYTM_OUT_ROOT") or os.path.join(ROOT, "build", "emu"), tag)
        os.makedirs(self.out, exist_ok=True)
        self.syms = json.load(open(os.path.join(self.out, "manifest.json")))["elek"]["symbols"]

    def run(self, name, length, events=(), extra=(), base=None, env=None):
        """events: (M, 'press', KEY[, hold M]) / (M, 'turn', 'ENC:DELTA', count, spacing M) / (M, 'usb', bytes).
        base: (snapshot, its clock in M) instead of the tag's base."""
        snap, start = base or self.base
        at = lambda t: f"{start + t:g}M"   # noqa: E731
        save = os.path.join(self.out, f"sq_{name}.snap")
        cmd = [os.path.join(EMU, "target/release/dtboot"), self.fw, "--load", snap, "--card", self.card,
               "--instr", f"{length}M", "--every", "100000M", "--save", save, "--usb-host", "--usb-midi-real"]
        for e in events:
            if e[1] == "press":
                cmd += ["--press", f"{e[2]}@{at(e[0])}" + (f":{e[3]}M" if len(e) > 3 else "")]
            elif e[1] == "turn":
                cmd += ["--turn", f"{e[2]}@{at(e[0])}x{e[3]}/{e[4]}M"]
            elif e[1] == "midi":   # 1049: DIN MIDI in (bytes)
                cmd += ["--midi", f"{e[2].hex()}@{at(e[0])}"]
            else:
                cmd += ["--usb-midi", f"{e[2].hex()}@{at(e[0])}"]
        cmd += list(extra)
        uo = os.path.join(self.out, f"sq_{name}.usb")
        if os.path.exists(uo):
            os.remove(uo)
        r = subprocess.run(cmd, cwd=EMU, env=dict(os.environ, DTEMU_STRICT="1", DTBOOT_USB_OUT=uo,
                                                  DTBOOT_END_PNG=os.path.join(self.out, f"sq_{name}.png"), **(env or {})),
                           capture_output=True, text=True)
        out = r.stdout + r.stderr
        open(os.path.join(self.out, f"sq_{name}.dt.txt"), "w").write(" ".join(cmd) + "\n" + out)
        bad = r.returncode != 0 or "FAULT" in out or "strict:" in out
        check(f"{name}: dtboot ran clean (strict, no fault)", not bad,
              "" if not bad else str(re.findall(r".*(?:FAULT|strict:).*", out)[:3] or f"rc {r.returncode}"))
        msgs = []
        if os.path.exists(uo):
            d = open(uo, "rb").read()
            i = 0
            while True:
                i = d.find(b"\xf0\x7d\x52\x54", i)
                if i < 0:
                    break
                j = d.find(b"\xf7", i)
                if j < 0:
                    break
                msgs.append(d[i:j + 1])
                i = j + 1
        return dict(snap=save, msgs=msgs, out=out)

    def peek(self, snap, addr, n):
        r = subprocess.run([os.path.join(EMU, "target/release/dtpeek"), os.path.abspath(snap), "mem", f"{addr:x}",
                            str(n)], cwd=EMU, env=dict(os.environ, DTEMU_FW=self.fw), capture_output=True, text=True)
        b = bytearray()
        for line in r.stdout.splitlines():
            m = re.match(r"^[0-9a-f]+: ((?:[0-9a-f]{2} ?)+)", line)
            if m:
                b += bytes.fromhex(m.group(1).replace(" ", ""))
        return bytes(b[:n])

    def leds(self, snap):
        r = subprocess.run([os.path.join(EMU, "target/release/dtpeek"), os.path.abspath(snap), "leds"], cwd=EMU,
                           env=dict(os.environ, DTEMU_FW=self.fw), capture_output=True, text=True)
        out = {}
        for line in r.stdout.splitlines():
            m = re.match(r"^led (\d+): slots \[([0-9a-f, ]+)\]", line)
            if m:
                out[int(m.group(1))] = [int(x, 16) for x in m.group(2).split(", ")]
        return out

    def pokes(self, edits):
        """--poke arguments (32-bit words) writing edits {addr: bytes} over the base's memory."""
        mem = {}
        for a, d in edits.items():
            for i, b in enumerate(d):
                mem[a + i] = b
        out = []
        for w in sorted({a & ~3 for a in mem}):
            cur = bytearray(self.peek(self.base[0], w, 4))
            for i in range(4):
                if w + i in mem:
                    cur[i] = mem[w + i]
            out += ["--poke", f"{w:x}={cur.hex()}"]
        return out

    def sq(self, snap):
        """0026's sq diagnostics (the struct's fields in order)."""
        a = self.syms["rytm-0026-remote-ui:sq"]
        b = self.peek(snap, a, 512)
        w = lambda o: int.from_bytes(b[o:o + 4], "big")   # noqa: E731
        o = 12 + 32 * 8 + 8 + 64 + 4 + 4
        names = ("init last_play last_pat spare fires queued sent2c sentev drops ev_drops busy ends isr_max "
                 "seen owed mode mode_track play pat next live grid tempo mutes pos_tick refused resyncs "
                 "s2d keys encs").split()
        d = {n: w(o + 4 * i) for i, n in enumerate(names)}
        d.update(on=w(0), mask=w(4), ticks=w(8))
        return d


def ticks(r):
    """2C: [(blk, track, step, len, speed)]."""
    out = []
    for m in r["msgs"]:
        if m[4] == 0x2C and m[5] == 1:
            b, n = blk(m[6:10]), m[10]
            for i in range(n):
                t, s, ln, sp = m[11 + 4 * i:15 + 4 * i]
                out.append((b, t, s, ln, sp))
    return out


def reps(r, kind=None):
    """2D: [(kind, args)]."""
    return [(m[6], list(m[7:-1])) for m in r["msgs"] if m[4] == 0x2D and m[5] == 1 and (kind is None or m[6] == kind)]


def keys(r):
    return [((m[6] << 7) | m[7], m[8]) for m in r["msgs"] if m[4] == 0x31 and len(m) == 10]


def encs(r):
    return [(m[6], m[7] - 64) for m in r["msgs"] if m[4] == 0x32 and len(m) == 10]


def runs_of(tk, t):
    return [x for x in tk if x[1] == t]


def steps_ok(seq, length):
    s = [x[2] for x in seq]
    return all((b - a) % length == 1 for a, b in zip(s, s[1:]))


def t_ticks(e):
    """BD 16 steps 1x and SD poked to 32 steps at 2x (track +0x2c5 = 32, +0x2c7 = 0): 2E BD + SD; PLAY 3 s: 2D 01 1 at
    the first ticks' block; BD's ticks 0, 1, .. 15, 0 .. (len 16, speed 2) one per 177 blocks; SD's 0 .. 31 (len 32,
    speed 0) twice as often; no other track; STOP: 2D 01 0; the clock mask (CH) ticks CH only."""
    sd = LIVE + TRACK
    pk = e.pokes({sd + 0x2C5: bytes([32]), sd + 0x2C7: bytes([0])})
    ev = [(300, "usb", mask2e((0, 1), 0, clock=(8,))), (400, "press", "PLAY"), (1000, "press", "STOP")]
    r = e.run("ticks", 1100, ev, extra=pk)
    tk = ticks(r)
    tr = reps(r, 1)
    print(f"  2D 01 {tr[:4]}, {len(tk)} ticks, first {tk[:4]}")
    play = [blk(a[1:5]) for k, a in tr if a[0] == 1]
    stop = [blk(a[1:5]) for k, a in tr if a[0] == 0]
    check("ticks: 2D 01 TRANSPORT play then stop (after the resync's stop)", len(play) == 1 and len(stop) >= 2, tr)
    bd, sdt, ch = runs_of(tk, 0), runs_of(tk, 1), runs_of(tk, 8)
    check("ticks: the first ticks in the play block", play and bd and bd[0][0] == play[0] and bd[0][2] == 0 and
          sdt and sdt[0][0] == play[0] and sdt[0][2] == 0, (play, bd[:1], sdt[:1]))
    check("ticks: BD steps 0, 1, 2 .. wrapping at 16, len 16, speed 2 (1x)",
          len(bd) >= 20 and steps_ok(bd, 16) and {(x[3], x[4]) for x in bd} == {(16, 2)} and
          [x[2] for x in bd[:18]] == list(range(16)) + [0, 1], [x[2] for x in bd])
    gaps = [b[0] - a[0] for a, b in zip(bd, bd[1:])]
    check("ticks: BD one tick per 1x step (177 blocks at 127 BPM, +-2)",
          gaps and all(abs(g - BLOCKS_PER_STEP) <= 2 for g in gaps), sorted(set(gaps)))
    check("ticks: SD (32 steps, 2x) 0 .. 31 wrapping, len 32, speed 0, twice BD's rate",
          steps_ok(sdt, 32) and {(x[3], x[4]) for x in sdt} == {(32, 0)} and abs(len(sdt) - 2 * len(bd)) <= 2 and
          [x[2] for x in sdt[:33]] == list(range(32)) + [0], (len(sdt), len(bd), [x[2] for x in sdt[:34]]))
    sgaps = [b[0] - a[0] for a, b in zip(sdt, sdt[1:])]
    check("ticks: SD one tick per 88.6 blocks (+-2)", sgaps and all(abs(g - BLOCKS_PER_STEP / 2) <= 2 for g in sgaps),
          sorted(set(sgaps)))
    check("ticks: CH (the clock mask) ticked, len 16, speed 2", len(ch) == len(bd) and steps_ok(ch, 16), len(ch))
    check("ticks: no other track", {x[1] for x in tk} == {0, 1, 8}, {x[1] for x in tk})
    check("ticks: nothing after STOP", stop and all(x[0] <= stop[-1] for x in tk), (stop, tk[-1:]))
    d = e.sq(r["snap"])
    check("ticks: none dropped, the sender never busy, the exit hook under 50 us (TIMER 100 MHz)",
          d["drops"] == 0 and d["isr_max"] < 5000, (d["drops"], d["busy"], d["isr_max"]))


def t_switch(e):
    """PLAY; at BD's step 7 BANK_A + T2 queues A02: 2D 02 0 1 (next); at step 16 2D 03 SWITCH 0 1 with the block
    where the new pattern's step-0 ticks are, those ticks step 0, then 2D 02 1 7F."""
    ev = [(300, "usb", mask2e((0,))), (400, "press", "PLAY"), (400 + 7 * 24, "press", "BANK_A", 40),
          (400 + 7 * 24 + 10, "press", "T2"), (1000, "press", "STOP")]
    r = e.run("switch", 1100, ev)
    tk = runs_of(ticks(r), 0)
    pats = reps(r, 2)
    sw = reps(r, 3)
    print(f"  02 {pats}, 03 {sw}")
    check("switch: 2D 02: 0 7F (resync), 0 1 (queued), 1 7F (after the switch)",
          [a for k, a in pats] == [[0, 0x7F], [0, 1], [1, 0x7F]], pats)
    check("switch: one 2D 03 SWITCH 0 -> 1", len(sw) == 1 and sw[0][1][:2] == [0, 1], sw)
    seq_ = [(m[6], list(m[7:9])) for m in r["msgs"] if m[4] == 0x2D and m[6] in (2, 3)]
    i3 = next((i for i, x in enumerate(seq_) if x[0] == 3), None)
    check("switch: 02's now stays the playing pattern until its 03 (1033)", i3 is not None and
          all(x[1][0] == 0 for x in seq_[:i3] if x[0] == 2) and (2, [1, 0x7F]) in seq_[i3:], seq_)
    if sw and tk:
        b = blk(sw[0][1][2:6])
        at = [x for x in tk if x[0] == b]
        before = [x for x in tk if x[0] < b]
        check("switch: at the switch block BD's tick is step 0 (16 steps after PLAY)",
              at and at[0][2] == 0 and len(before) == 16, (at, len(before)))
    p = [m for m in r["msgs"] if m[4] in (0x2C, 0x2D)]
    i3 = next((i for i, m in enumerate(p) if m[4] == 0x2D and m[6] == 3), None)
    check("switch: the 03 goes out before that block's 2C", i3 is not None and i3 + 1 < len(p) and p[i3 + 1][4] == 0x2C and
          blk(p[i3 + 1][6:10]) == blk(p[i3][9:13]), i3)


def t_jump(e):
    """1042: the pattern modes (FUNC + BANK_A..D: SEQUENTIAL, DIRECT START, DIRECT JUMP, TEMP JUMP), BANK_A + T2 at BD's
    step 7 (A02: 64 steps). Each: one 2D 03 0 -> 1 at the block of A02's first step and before that block's 2C, no tick
    of step 127 (DIRECT START's first call has no step) and no step twice (a jump re-schedules the next step); DIRECT
    JUMP / TEMP JUMP: A02 from step 8 at the next boundary (rui1041: 03 at A02's step 0 two seconds later / never)."""
    from concurrent.futures import ThreadPoolExecutor

    def one(bk):
        ev = [(300, "usb", mask2e((0,))), (320, "press", "FUNC", 20), (325, "press", bk), (500, "press", "PLAY"),
              (500 + 7 * 24, "press", "BANK_A", 40), (500 + 7 * 24 + 10, "press", "T2"), (900, "press", "STOP")]
        return bk, e.run(f"jump_{bk}", 1000, ev)
    want = dict(BANK_A=0, BANK_B=0, BANK_C=None, BANK_D=None)   # None: a jump - the step after the old pattern's last
    with ThreadPoolExecutor(4) as x:
        res = list(x.map(one, want))
    for bk, r in res:
        tk = runs_of(ticks(r), 0)
        sw = [a for k, a in reps(r, 3)]
        first = [x for x in tk if sw and x[0] == blk(sw[0][2:6])]
        steps = [x[2] for x in tk]
        dups = [i for i in range(1, len(tk)) if tk[i][2] == tk[i - 1][2]]
        print(f"  {bk}: 03 {[(a[:2], blk(a[2:6])) for a in sw]}, its block's BD tick {first}, step 127 {127 in steps}, "
              f"twice {len(dups)}")
        before = [x for x in tk if sw and x[0] < blk(sw[0][2:6])]
        w = want[bk] if want[bk] is not None else (before[-1][2] + 1 if before else -1)
        check(f"jump {bk}: one 03 0 -> 1 at A02's first step ({w}) block", len(sw) >= 1 and sw[0][:2] == [0, 1] and
              len(first) == 1 and first[0][2] == w and first[0][3] == 64 and (want[bk] is not None or w > 0), (sw, first))
        check(f"jump {bk}: no tick of step 127, no step reported twice", 127 not in steps and not dups, (steps, dups))
        p = [m for m in r["msgs"] if m[4] in (0x2C, 0x2D)]
        i3 = next((i for i, m in enumerate(p) if m[4] == 0x2D and m[6] == 3), None)
        check(f"jump {bk}: the 03 before that block's 2C", i3 is not None and i3 + 1 < len(p) and p[i3 + 1][4] == 0x2C and
              blk(p[i3 + 1][6:10]) == blk(p[i3][9:13]), i3)


def t_fill(e):
    """1042: FILL reaches the host (2D 0C, the host's FILL / !FILL trig conditions): held while playing -> 0C 1, its release
    -> 0C 0; the same with the page open (TRK + YES; FILL is in no catch mask: stock's FILL plays as without the page)."""
    for name, pre in (("fill", []), ("fill-page", [(320, "press", "TRK", 30), (335, "press", "YES")])):
        ev = [(300, "usb", mask2e((0,)))] + pre + [(400, "press", "PLAY"), (500, "press", "FILL", 100), (700, "press", "STOP")]
        r = e.run(name, 800, ev)
        f = [a[0] for k, a in reps(r, 0x0C)]
        print(f"  {name}: 2D 0C {f}")
        check(f"fill ({name}): FILL held -> 2D 0C 1, released -> 0C 0", f[-2:] == [1, 0], f)


def t_pause(e):
    """PLAY, PLAY (pause: 2D 01 2, ticks stop), PLAY (continue: 2D 01 1, the steps go on, not from 0), STOP."""
    ev = [(300, "usb", mask2e((0,))), (400, "press", "PLAY"), (600, "press", "PLAY"), (800, "press", "PLAY"),
          (1000, "press", "STOP")]
    r = e.run("pause", 1100, ev)
    tr = [a[0] for k, a in reps(r, 1)]
    tk = runs_of(ticks(r), 0)
    print(f"  transport {tr}, steps {[x[2] for x in tk]}")
    check("pause: 2D 01: 0 (resync), 1, 2, 1, 0", tr == [0, 1, 2, 1, 0], tr)
    gaps = [b[0] - a[0] for a, b in zip(tk, tk[1:])]
    check("pause: the steps go on across the pause (0, 1, .. no restart), one gap of the pause's length",
          tk and tk[0][2] == 0 and steps_ok(tk, 16) and len(tk) >= 15 and
          sum(1 for g in gaps if g > 1.5 * BLOCKS_PER_STEP) == 1, [x[2] for x in tk])


def t_mode(e):
    """2E BD; GRID REC (RECORD): 2D 08 1 0, 06 0 1; T1 held + A turned 3 x +2: 31 T1 down, 32 0 +6, 31 T1 up; T5;
    PAGE (held); FUNC both sides'; 34 + 2F paint T1..T16 and the PAGE LEDs; no trig in BD's track (stock writes them
    in the same gestures, t_stock); GRID REC off: 2D 08 0 7F, T9 stock's again, every LED stock's."""
    c34 = [0x0F] * 8 + [0x6F] * 8
    ev = [(300, "usb", mask2e((0,))), (350, "press", "RECORD"), (400, "press", "T1", 60),
          (420, "turn", "0:2", 3, 5), (500, "press", "T5"), (550, "press", "PAGE", 40), (600, "press", "FUNC", 20),
          (650, "usb", sx(0x34, 1, *c34)), (650, "usb", sx(0x2F, 0x2F, 0x2B, 0x2B, 0x7F))]
    r = e.run("mode_on", 700, ev)
    k = keys(r)
    print(f"  keys {[(hex(c), d) for c, d in k]}, encs {encs(r)}")
    check("mode: 2D 08 SEQMODE 1 0 and 06 REC 0 1", ([1, 0] in [a for _, a in reps(r, 8)]) and
          ([0, 1] in [a for _, a in reps(r, 6)]), reps(r))
    check("mode: 31 T1 down / up, T5, PAGE down / up, FUNC down / up",
          k == [(0x00, 1), (0x00, 0), (0x04, 1), (0x04, 0), (0x84, 1), (0x84, 0), (0x80, 1), (0x80, 0)], k)
    check("mode: 32 encoder A +6 while T1 is held", encs(r) == [(0, 6)], encs(r))
    lv = e.leds(r["snap"])
    check("mode: T1..T8 red 0x0F, T9..T16 white 0x6F (the host's 34)",
          all(lv[i] == [0x0F] * 4 for i in range(8)) and all(lv[i] == [0x6F] * 4 for i in range(8, 16)),
          [lv.get(i) for i in (0, 8)])
    check("mode: PAGE LEDs 43 42 41 = 2F 2B 2B (the host's), 40 stock's (7F)",
          lv[43] == [0x2F] * 4 and lv[42] == [0x2B] * 4 and lv[41] == [0x2B] * 4 and lv[40] != [0x7F] * 4,
          [lv.get(i) for i in (43, 42, 41, 40)])
    base = e.peek(e.base[0], LIVE, TRACK)
    check("mode: BD's live track unchanged (no stock trig placed)", e.peek(r["snap"], LIVE, TRACK) == base)
    ev2 = ev + [(700, "press", "RECORD"), (750, "press", "T9")]
    r2 = e.run("mode_off", 800, ev2)
    check("mode: GRID REC off: 2D 08 0 7F", reps(r2, 8)[-1:] == [(8, [0, 0x7F])], reps(r2, 8))
    check("mode: T9 then not the host's", (0x08, 1) not in keys(r2), keys(r2))
    lb, lo = e.leds(e.base[0]), e.leds(r2["snap"])
    check("mode: every trig and PAGE LED stock's again (as in the base)",
          all(lo[i] == lb[i] for i in list(range(16)) + [40, 41, 42, 43]), [(i, lo[i], lb[i]) for i in (0, 43)])


def t_stock(e):
    """No 2E: PLAY, the pads, GRID REC + T1: no 2C / 2D at all; GRID REC + T1 / T5 writes BD's trigs (stock); a 2E
    marking SD only: GRID REC on BD is no seq mode (BD's T1 stock's)."""
    ev = [(350, "press", "RECORD"), (400, "press", "T1"), (450, "press", "T5"), (500, "press", "RECORD"),
          (550, "press", "PLAY"), (700, "press", "BD"), (900, "press", "STOP")]
    r = e.run("stock", 1000, ev)
    new = [m for m in r["msgs"] if m[4] in (0x2C, 0x2D, 0x31, 0x32)]
    check("stock: no 2C / 2D / 31 / 32 without a 2E", not new, [m.hex() for m in new[:3]])
    check("stock: GRID REC + T1 / T5 placed BD trigs", e.peek(r["snap"], LIVE, TRACK) != e.peek(e.base[0], LIVE, TRACK))
    d = e.sq(r["snap"])
    check("stock: reports off, nothing queued", d["on"] == 0 and d["queued"] == 0, (d["on"], d["queued"]))
    pl = [(400, "press", "PLAY")]
    a = e.run("play_stock", 700, pl)
    b = e.run("play_seq", 700, [(300, "usb", mask2e((0, 1, 2)))] + pl)
    check("stock: the sequencer's state after 1.5 s of play identical with and without seq tracks (0x405c8c90..)",
          e.peek(a["snap"], 0x405C8C90, 0xB0) == e.peek(b["snap"], 0x405C8C90, 0xB0))
    host = (0x2C, 0x2D, 0x35, 0x33, 0x3B, 0x2B, 0x49, 0x4B)   # ours, and what a host's presence changes (hello repeats and
    # the snapshots after each - 33, 3B, 1036b's 49, 1052's 4B ACTIVE -, 2B idle bit)
    # per command in order (1033's resync sends 13 SCALE + FILL through the same sender: the other reports keep their
    # content and their order, only their interleaving with each other may shift)
    per = lambda r: {c: [m for m in r["msgs"] if m[4] == c] for c in {m[4] for m in r["msgs"]} - set(host)}   # noqa: E731
    check("stock: and the same other reports to the host, each command's in order (0x2C 2D, and the hello / 33 / 3B / 2B "
          "a host's message moves, left out)", per(a) == per(b))
    ev = [(300, "usb", mask2e((1,))), (350, "press", "RECORD"), (400, "press", "T1")]
    r = e.run("other", 500, ev)
    check("stock: SD the seq track, BD selected: no seq mode, T1 stock's",
          not keys(r) and [a for _, a in reps(r, 8)] == [[0, 0x7F]], (keys(r), reps(r, 8)))


def t_rec(e):
    """2E BD; RECORD held + PLAY; pads BD and SD: 2D 06 1 0 (live); stock writes nothing on BD (rec_trig refused once),
    SD records as stock; 2D 06 0 0 after STOP."""
    ev = [(300, "usb", mask2e((0,))), (350, "press", "RECORD", 150), (400, "press", "PLAY"), (550, "press", "BD"),
          (600, "press", "SD"), (800, "press", "STOP")]
    r = e.run("rec", 900, ev)
    s = r["snap"]
    rec = [a for _, a in reps(r, 6)]
    print(f"  06 {rec}")
    check("rec: 2D 06 REC: 0 0, (RECORD's press: 0 1 grid), 1 0 (live), 0 0", rec[0] == [0, 0] and [1, 0] in rec and
          rec[-1] == [0, 0], rec)
    check("rec: BD's live track unchanged", e.peek(s, LIVE, TRACK) == e.peek(e.base[0], LIVE, TRACK))
    check("rec: SD's live track recorded (stock)", e.peek(s, LIVE + TRACK, TRACK) != e.peek(e.base[0], LIVE + TRACK, TRACK))
    d = e.sq(s)
    check("rec: rec_trig refused once (BD)", d["refused"] == 1, d["refused"])


def t_state(e):
    """The resync's 2D: 08 0 7F, 01 0, 02 0 7F, 05 0 0, 0D 0 0 (1049: SOLO), 06 0 0, 07 127.00 BPM (15240), 09; MUTE + SD:
    05 02 00; a 2E with flags bit 1: the whole resync again; 09 POS once a second while playing."""
    ev = [(300, "usb", mask2e((0,))), (350, "press", "MUTE", 60), (380, "press", "SD"),
          (500, "usb", mask2e((0,), 2)), (550, "press", "PLAY"), (1000, "press", "STOP")]
    r = e.run("state", 1100, ev)
    rp = reps(r)
    print(f"  {rp[:8]}")
    first = [k for k, a in rp[:8]]
    check("state: the resync: 08 01 02 05 0D 06 07 09", first == [8, 1, 2, 5, 0x0D, 6, 7, 9], first)
    check("state: the resync's SOLO: none soloed (0D 0 0)", [a for k, a in rp[:8] if k == 0x0D] == [[0, 0]], rp[:8])
    t7 = [a for k, a in rp if k == 7]
    check("state: tempo 127.0 BPM = 15240 (1/120 BPM)", t7 and (t7[0][0] << 14 | t7[0][1] << 7 | t7[0][2]) == 15240, t7)
    m5 = [a for k, a in rp if k == 5]
    check("state: MUTE + SD: 05 02 00", [2, 0] in m5, m5)
    check("state: the second 2E (flags 2) a second resync", [k for k, a in rp].count(9) >= 3 and
          e.sq(r["snap"])["resyncs"] == 2, [k for k, a in rp])
    pos = [a for k, a in rp if k == 9 and a[4] == 1]
    check("state: 09 POS while playing (about once a second)", 1 <= len(pos) <= 3, pos)


def t_solo(e):
    """1049: the soloed tracks (0x407c23c5, BE word, bit t = track t [measured: CC 93 Track Solo on SD's channel 2]) as
    2D 0D <lo7> <hi6>, polled as the mutes (05): SD soloed -> 0D 02 00, BD too -> 0D 03 00, both off -> 0D 00 00; the mutes
    stay 00 00 (solo is not a mute). Nothing before the host's 2E."""
    ev = [(150, "midi", bytes([0xB1, 93, 1])), (300, "usb", mask2e((0,))), (450, "midi", bytes([0xB0, 93, 1])),
          (600, "midi", bytes([0xB1, 93, 0])), (650, "midi", bytes([0xB0, 93, 0]))]
    r = e.run("solo", 800, ev)
    so = [a for k, a in reps(r, 0x0D)]
    mu = [a for k, a in reps(r, 5)]
    print(f"  0D {so}  05 {mu}")
    check("solo: the resync says SD soloed (0D 02 00, before the 2E nothing), then BD too (03 00), then none (00 00)",
          so[:1] == [[2, 0]] and [3, 0] in so and so[-1] == [0, 0], so)
    check("solo: the mutes unchanged (05 00 00 only)", mu and all(a == [0, 0] for a in mu), mu)
    check("solo: the word read is stock's (0x407c23c5 = 00 00 at the end)", e.peek(r["snap"], 0x407C23C5, 2) == b"\x00\x00",
          e.peek(r["snap"], 0x407C23C5, 2))


def t_hello(e):
    """A USB host that browns out and comes back (a new enumeration, a new hello): the seq tracks are forgotten (no 2C
    after the hello until a new 2E)."""
    ev = [(300, "usb", mask2e((0,))), (350, "press", "PLAY"), (1400, "press", "STOP")]
    s0 = e.base[1]
    r = e.run("hello", 1500, ev, extra=["--usb-host-gone", f"{s0 + 600}M:{s0 + 700}M"])
    tk = runs_of(ticks(r), 0)
    hello = [i for i, m in enumerate(r["msgs"]) if m[4] == 0x35]
    after = [m for m in r["msgs"][hello[-1]:] if m[4] == 0x2C] if hello else []
    check("hello: ticks before the brown-out, none after the new hello", tk and hello and not after,
          (len(tk), hello, len(after)))
    check("hello: reports off", e.sq(r["snap"])["on"] == 0)


# ---- 1033: the analog pin, the edit reports, SCALE, pattern dirty, the pattern dump (design.md "1033")
FRAME = 0x800063C0
VEL = 0x800067C4


def mask2e_pin(tracks=(), flags=0, pin=()):
    """2E with the 1033 pin mask (7 bytes: mask, flags, clock 0, pin)."""
    m = sum(1 << t for t in tracks)
    pm = sum(1 << t for t in pin)
    return sx(0x2E, m & 0x7F, m >> 7 & 0x1F, flags, 0, 0, pm & 0x7F, pm >> 7 & 0x1F)


def silent46(tracks=()):
    m = sum(1 << t for t in tracks)
    return sx(0x46, m & 0x7F, m >> 7 & 0x1F)


def frame_words(e, snap, v):
    """voice v's (VCA L, VCA R, amp L rec, amp R rec, filter rec word 0) from a snapshot's control frame."""
    f = e.peek(snap, FRAME, 312)
    w16 = lambda o: int.from_bytes(f[o:o + 2], "big")   # noqa: E731
    return (w16(10 + 2 * v), w16(26 + 2 * v), f[168 + 8 * v:176 + 8 * v].hex(), f[232 + 8 * v:240 + 8 * v].hex(),
            f[296 + 8 * v:300 + 8 * v].hex())


def struct_words(e, snap, name, names):
    b = e.peek(snap, e.syms[f"rytm-0026-remote-ui:{name}"], 4 * len(names))
    return {n: int.from_bytes(b[4 * i:4 * i + 4], "big") for i, n in enumerate(names)}


# The control frame's records are read from the end snapshot. The firmware clears them between a block's sender and the
# next block's consumers, so a snapshot that lands in that window reads zeros. Where the window falls depends on the
# audio's phase against the clock, which a build's boot moves [measured, rui1036: 900 M lands in it, 899.9 M and 900.1 M
# read the held records]. The pin runs end 0.1 M (5 us) off the round numbers.
PH = 0.1
PIN_NAMES = "mask silent open closing was decay attack hold calls blocks starts closes vel_fix isr_max silents".split()


def sine_wav(path, secs=6.0, hz=220.0, amp=0.5):
    import math
    import struct
    import wave
    n = int(48000 * secs)
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(48000)
        w.writeframes(b"".join(struct.pack("<h", int(amp * 32767 * math.sin(2 * math.pi * hz * i / 48000)))
                               for i in range(n)))


def wav_rms(path, t0, t1):
    """RMS (full scale 1) of a 16/32-bit WAV's channels summed, from t0 to t1 s."""
    import wave
    import numpy as np
    with wave.open(path) as w:
        sr, ch, sw = w.getframerate(), w.getnchannels(), w.getsampwidth()
        a = np.frombuffer(w.readframes(w.getnframes()), dtype={2: "<i2", 4: "<i4"}[sw]).reshape(-1, ch)
    x = a[int(t0 * sr):int(t1 * sr)].astype(float).sum(axis=1) / (2 ** (8 * sw - 1))
    return float(np.sqrt((x ** 2).mean())) if len(x) else 0.0


FM_BASE = None


def fm_base(e):
    """The base with BD on 6-OP FM (machine 40, a Sidecar machine: 0021's ext_render; SRC SRC, DOWN x 20, YES), the
    Overbridge input then reaching BD's digital layer as with the Sidecar."""
    global FM_BASE
    if FM_BASE is None:
        keys = ["SRC", "SRC"] + ["DOWN"] * 20 + ["YES", "NO"]
        r = e.run("fmbase", 100 + 100 * len(keys) + 300, [(100 + 100 * i, "press", k) for i, k in enumerate(keys)])
        m = e.peek(r["snap"], 0x8000EA00, 1)[0]
        check("fm base: BD's machine is 6-OP FM (40)", m == 40, m)
        FM_BASE = (r["snap"], e.base[1] + 100 + 100 * len(keys) + 300)
    return FM_BASE


def held(rec, d):
    """an amp record (hex) is the pin's hold: 0000007f + stock's ATK-0 hold (mode 3; the firmware clears the mode byte
    after each send, as on its own records)"""
    return rec[:8] == "0000007f" and rec[8:11] in ("300", "000") and rec[11:] == f"{d['hold'] & 0xFFFFF:05x}"


def t_pin(e):
    """2E BD (a seq track, no trig anywhere): from the next block BD's voice 0 is pinned: amp records 0000007f 00000000
    (after one 4000007f start), filter record word 0 = 0, velocity word 0x7f00 and the VCA at its velocity-127 value
    (0 before: no trig ever); SD (voice 1) as in the base. The host's 46 BD: stock's decay record (00000080 b01..) every
    block, a 46 with nothing silent: open again (a second start). A sine into BD's Overbridge input (the Sidecar's audio)
    is heard in the analog mix (--analog-wav) only with the pin; stock: nothing (an empty track's VCA stays closed)."""
    wav = os.path.join(e.out, "sine.wav")
    if not os.path.exists(wav):
        sine_wav(wav)
    fb = fm_base(e)
    au = lambda n: ["--every", "50M", "--ob-in", f"{wav}:4", "--analog-wav", os.path.join(e.out, f"{n}.wav")]  # noqa: E731
    e.run("pin_stock", 600, [(100, "usb", mask2e(()))], extra=au("pin_stock"), base=fb)
    e.run("pin_fm", 600, [(100, "usb", mask2e((0,)))], extra=au("pin_fm"), base=fb)
    r = e.run("pin_on", 900 + PH, [(300, "usb", mask2e((0,)))])
    b0, b1 = frame_words(e, e.base[0], 0), frame_words(e, e.base[0], 1)
    w0, w1 = frame_words(e, r["snap"], 0), frame_words(e, r["snap"], 1)
    print(f"  base v0 {b0}, pinned v0 {w0}; v1 {b1} / {w1}")
    check("pin: base: BD's VCA 0 (no trig yet)", b0[0] == 0 and b0[1] == 0, b0)
    dp = struct_words(e, r["snap"], "pin", PIN_NAMES)
    check("pin: BD's amp records held at 127 (0000007f 30......: stock's ATK-0 hold), filter depth 0",
          held(w0[2], dp) and w0[3] == w0[2] and w0[4] == "00000000", w0)
    vel = int.from_bytes(e.peek(r["snap"], VEL, 2), "big")
    check("pin: velocity word 0x7f00 and the VCA open (L = R > 0)", vel == 0x7F00 and w0[0] > 0x1000 and w0[0] == w0[1],
          (hex(vel), w0[:2]))
    # (the amp records' mode byte, 0xb0 while a record is sent and 0 after it, toggles every few ms in any build: masked
    # [measured 2026-10-21: rui1037 and rui1038 alike at 895 / 900 / 905 / 910 ms, the base snapshot itself caught it set])
    nomode = lambda w: (w[0], w[1], w[2][:8] + w[2][10:], w[3][:8] + w[3][10:], w[4])   # noqa: E731
    check("pin: SD (voice 1, not pinned) untouched", nomode(w1) == nomode(b1), (w1, b1))
    d = struct_words(e, r["snap"], "pin", PIN_NAMES)
    check("pin: one start, BD the only pinned voice, the hook under 20 us",
          d["starts"] == 1 and d["was"] == 1 and d["mask"] == 1 and d["isr_max"] < 2000, d)
    t1, t2 = (100 + 50) / 200, 600 / 200
    rs, ro = wav_rms(os.path.join(e.out, "pin_stock.wav"), t1, t2), wav_rms(os.path.join(e.out, "pin_fm.wav"), t1, t2)
    print(f"  analog mix RMS with the sine on BD's input (BD on 6-OP FM, no trig): stock {rs:.5f}, pinned {ro:.5f}")
    check("pin: the Sidecar's audio on an empty BD track: silent in stock, heard pinned (> 30 dB more)",
          rs < 1e-4 and ro > 0.003 and ro > 30 * max(rs, 1e-6), (rs, ro))
    ev = [(300, "usb", mask2e((0,))), (400, "usb", silent46((0,)))]
    r2 = e.run("pin_silent", 500 + PH, ev)
    w = frame_words(e, r2["snap"], 0)
    d = struct_words(e, r2["snap"], "pin", PIN_NAMES)
    dec = f"{d['decay'] & 0xFFFFF:05x}"   # the firmware clears the mode byte after each send, as on stock's records
    check("pin: 46 BD silent: stock's decay record (00000080 b01..... / 001.....) on both copies",
          w[2][:8] == "00000080" and w[2][8:11] in ("b01", "001") and w[2][11:] == dec and w[3] == w[2] and
          d["closes"] == 1, (w, d["closes"]))
    r3 = e.run("pin_reopen", 600 + PH, ev + [(500, "usb", silent46(()))])
    w = frame_words(e, r3["snap"], 0)
    d = struct_words(e, r3["snap"], "pin", PIN_NAMES)
    check("pin: 46 with nothing silent: open again (held at 127, a second start)",
          held(w[2], d) and d["starts"] == 2, (w, d["starts"]))
    r4 = e.run("pin_off", 600 + PH, [(300, "usb", mask2e((0,))), (450, "usb", mask2e(()))])
    w = frame_words(e, r4["snap"], 0)
    d = struct_words(e, r4["snap"], "pin", PIN_NAMES)
    check("pin: unmarked (2E mask 0): BD closes (decay) until stock starts it", w[2][:8] == "00000080" and
          d["closing"] == 1 and d["was"] == 0, (w, d["closing"]))
    r5 = e.run("pin_hello", 1500, [(300, "usb", mask2e((0,)))],
               extra=["--usb-host-gone", f"{e.base[1] + 600}M:{e.base[1] + 700}M"])
    d = struct_words(e, r5["snap"], "pin", PIN_NAMES)
    check("pin: a new hello forgets the pin (mask 0, closing)", d["mask"] == 0 and d["was"] == 0, d)


def t_pinvel(e):
    """Pinned as a poly track (2E pin mask BD, no seq track): a velocity-32 note 36 on the auto channel (14) plays BD;
    stock's VCA follows velocity (0x0cc4 at 32, 0x32a9 at 127 [measured POLYPHONY.md 5.1]); pinned it stays at the
    127 value. A note on a stock track makes stock's start (the pin leaves other voices alone)."""
    note = bytes([0x9D, 0x24, 0x20])   # BD's note (36) on the auto channel, velocity 32
    a = e.run("vel_stock", 500, [(300, "usb", mask2e(())), (400, "usb", note)])
    b = e.run("vel_pin", 500, [(300, "usb", mask2e_pin((), 0, (0,))), (400, "usb", note)])
    wa, wb = frame_words(e, a["snap"], 0), frame_words(e, b["snap"], 0)
    print(f"  velocity 32: stock {wa}, pinned {wb}")
    check("pinvel: stock VCA at velocity 32 (0x0cc4 +-2)", abs(wa[0] - 0x0CC4) <= 2, hex(wa[0]))
    d = struct_words(e, b["snap"], "pin", PIN_NAMES)
    check("pinvel: pinned VCA at the velocity-127 value (0x32a9 +-4), records held", abs(wb[0] - 0x32A9) <= 4 and
          held(wb[2], d), wb)
    check("pinvel: pinned without a seq track (mask 0, pin 1), the velocity fixed once or more", d["mask"] == 1 and
          d["vel_fix"] >= 1, d)
    soft = bytes([0x9D, 0x24, 0x40])
    tr = e.run("vel_trace", 500, [(300, "usb", mask2e_pin((), 0, (0,))), (400, "usb", note), (450, "usb", soft)],
               env=dict(DTEMU_FRAME_TRACE="10,26"))
    vals = [int(x, 16) for x in re.findall(r"^frame +\d+ 10:([0-9a-f]{4})", tr["out"], re.M)]
    print(f"  the VCA as sent (velocity 32 then 64, pinned): {[hex(v) for v in vals]}")
    check("pinvel: the VCA as sent never dips at a softer trig (every value after the open the 127 one)",
          len(vals) >= 2 and all(abs(v - 0x32A9) <= 4 for v in vals[1:]), [hex(v) for v in vals])
    fb = fm_base(e)
    f4 = e.run("vel_fm", 300, [(100, "usb", mask2e_pin((), 0, (0,))), (200, "usb", note)], base=fb)
    t4 = [m for m in f4["msgs"] if m[4] == 0x04 and m[5] & 7 == 0]   # the voice byte: voice | machine flags
    check("pinvel: BD on 6-OP FM, pinned: its 0x04 still carries velocity 32 (the host's per-note velocity)",
          t4 and all(m[7] == 0x20 for m in t4), [m[:8].hex() for m in t4])
    c = e.run("vel_flags", 500, [(300, "usb", mask2e_pin((0,), 4, ())), (400, "usb", note)])
    wc = frame_words(e, c["snap"], 0)
    check("pinvel: 2E flags bit 2 (no pin on seq tracks): BD a seq track but stock's VCA", abs(wc[0] - 0x0CC4) <= 2, wc)


def edits(r):
    """2D 0A: [(op, pattern, track, ok, src, arg)]."""
    return [(a[0], a[1], a[2], a[3], a[4], a[5] | a[6] << 7 | a[7] << 14) for k, a in reps(r, 0x0A) if len(a) == 8]


def t_edits(e):
    """The stock edit functions report 2D 0A (op, pattern, track, ok, src 0, arg): pattern copy / paste (+ its undo
    check) / undo / clear (FUNC + REC / STOP / PLAY outside GRID REC); in GRID REC on BD (not a seq track): track copy /
    paste / clear (+ their undo checks), PAGE held: page copy / paste, T1 / T5 held: trig copy / paste."""
    f = lambda t, k: [(t, "press", "FUNC", 30), (t + 10, "press", k)]   # noqa: E731
    ev = [(300, "usb", mask2e(()))] + f(350, "RECORD") + f(400, "STOP") + f(450, "STOP") + f(500, "PLAY")
    r = e.run("ed_pat", 600, ev)
    ed = edits(r)
    print(f"  pattern: {ed}")
    check("edits: pattern copy, paste (undo check 0 first), undo (ok 1, kind 2), clear (undo check kind 1: 0)",
          [(x[0], x[3], x[5]) for x in ed] == [(1, 1, 0), (4, 0, 2), (2, 1, 0), (4, 1, 2), (4, 0, 1), (3, 1, 0)] and
          all(x[1] == 0 and x[2] == 0x7F and x[4] == 0 for x in ed), ed)
    ev = ([(300, "usb", mask2e(())), (320, "press", "RECORD")] + f(400, "RECORD") + f(450, "STOP") + f(500, "PLAY") +
          [(550, "press", "PAGE", 60)] + f(560, "RECORD") + [(630, "press", "PAGE", 60)] + f(640, "STOP") +
          [(710, "press", "T1", 60)] + f(720, "RECORD") + [(790, "press", "T5", 60)] + f(800, "STOP"))
    r = e.run("ed_trk", 900, ev)
    ed = edits(r)
    print(f"  track: {ed}")
    ops = [(x[0], x[3]) for x in ed]
    check("edits: GRID REC: track copy, paste (+ undo check), clear (+ undo check), page copy, paste (+ undo check), "
          "trig copy, paste", ops == [(5, 1), (8, 0), (6, 1), (8, 0), (7, 1), (9, 1), (12, 0), (10, 1), (13, 1), (14, 1)],
          ops)
    check("edits: track 0 (BD), pattern 0, src 0", all(x[1] == 0 and x[2] == 0 and x[4] == 0 for x in ed), ed)
    d = e.peek(r["snap"], e.syms["rytm-0026-remote-ui:ed"] + 8 * 8 + 8, 4)
    check("edits: none dropped", int.from_bytes(d, "big") == 0, d.hex())


def t_savereload(e):
    """1042: the PATTERN menu's RELOAD / SAVE (FUNC + SCNE) and the TRACK menu's RELOAD / SAVE TRACK (FUNC + CHRO; UP x 10
    to its top, then DOWN 3 / 4) report 2D 0A ops 16 / 17 (pattern 0, track 7F) and 18 / 19 (track 0, BD), src 0."""
    f = lambda t, k: [(t, "press", "FUNC", 30), (t + 10, "press", k)]   # noqa: E731
    top = lambda t: [(t + 12 * i, "press", "UP") for i in range(10)]   # noqa: E731
    ev = ([(300, "usb", mask2e(()))] + f(350, "SCNE") + [(420, "press", "YES")] + f(500, "SCNE") +
          [(560, "press", "DOWN"), (600, "press", "YES"), (660, "press", "NO"), (680, "press", "NO")] +
          [(700, "press", "FUNC", 60), (720, "press", "CHRO")] + top(760) + [(900 + 20 * i, "press", "DOWN") for i in range(3)] +
          [(980, "press", "YES"), (1040, "press", "NO"), (1060, "press", "NO")] +
          [(1080, "press", "FUNC", 60), (1100, "press", "CHRO")] + top(1140) +
          [(1280 + 20 * i, "press", "DOWN") for i in range(4)] + [(1380, "press", "YES")])
    r = e.run("ed_sr", 1500, ev)
    ed = edits(r)
    print(f"  save / reload: {ed}")
    check("savereload: RELOAD PAT 16, SAVE PAT 17 (pattern 0, track 7F), RELOAD TRK 18, SAVE TRK 19 (track 0), src 0",
          [(x[0], x[1], x[2], x[4]) for x in ed] == [(16, 0, 0x7F, 0), (17, 0, 0x7F, 0), (18, 0, 0, 0), (19, 0, 0, 0)], ed)


def t_seqedit(e):
    """Seq mode (BD a seq track, GRID REC): a host-held trig + FUNC + REC / STOP / PLAY -> 2D 0A trigs copy / paste /
    clear (src 1, the held mask), PAGE held -> page copy (src 1); stock does nothing (no stock 0A, BD's track as in the
    base); FUNC + REC without a held key -> stock's track copy (src 0); FUNC + PAGE -> stock's SCALE (no 31 PAGE),
    DOWN x 2: 2D 04 BD length 14."""
    f = lambda t, k: [(t, "press", "FUNC", 30), (t + 10, "press", k)]   # noqa: E731
    ev = ([(300, "usb", mask2e((0,))), (330, "press", "RECORD"), (350, "press", "T1", 60), (352, "press", "T3", 58)] +
          f(370, "RECORD") + [(430, "press", "T2", 50)] + f(440, "STOP") + [(500, "press", "T2", 50)] + f(510, "PLAY") +
          [(570, "press", "PAGE", 50)] + f(580, "RECORD") + f(640, "RECORD"))
    r = e.run("ed_seq", 700, ev)
    ed = edits(r)
    print(f"  seq: {ed}")
    check("seqedit: trigs copy (T1 + T3: mask 5), paste (T2), clear (T2), page copy: src 1, track 0; then a stock track "
          "copy (src 0)", [(x[0], x[4], x[5]) for x in ed] == [(13, 1, 5), (14, 1, 2), (15, 1, 2), (9, 1, 0), (5, 1 - 1, 0)],
          ed)
    k = keys(r)
    check("seqedit: the trigs and PAGE reached the host (31), RECORD / STOP / PLAY did not", all(c in (0, 1, 2, 0x80, 0x84)
          for c, _ in k), k)
    check("seqedit: BD's live track as in the base", e.peek(r["snap"], LIVE, TRACK) == e.peek(e.base[0], LIVE, TRACK))
    ev = [(300, "usb", mask2e((0,))), (330, "press", "RECORD"), (380, "press", "FUNC", 40), (390, "press", "PAGE"),
          (450, "press", "DOWN"), (510, "press", "DOWN"), (570, "press", "NO")]
    r = e.run("ed_scale", 650, ev)
    sc = [a for k, a in reps(r, 4) if a[0] == 0]
    print(f"  scale BD: {sc[-3:]}, keys {keys(r)}")
    check("seqedit: FUNC + PAGE is stock's SCALE on a seq track in GRID REC (PAGE not sent to the host)",
          (0x84, 1) not in keys(r), keys(r))
    check("seqedit: SCALE DOWN x 2: 2D 04 BD length 14 (speed 2)", sc and sc[-1][1] | sc[-1][2] << 7 == 14 and
          sc[-1][3] == 2, sc)


def t_scale(e):
    """The resync's SCALE: 13 x 2D 04 (12 tracks + 7F, the pattern: length, speed, mode, change length) with the base's
    values; SD poked to 32 steps 2x before: its 04 says so; nothing more while nothing changes."""
    sd = LIVE + TRACK
    pk = e.pokes({sd + 0x2C5: bytes([32]), sd + 0x2C7: bytes([0])})
    r = e.run("scale", 700, [(300, "usb", mask2e((0,)))], extra=pk)
    sc = reps(r, 4)
    print(f"  {sc}")
    tr = {a[0]: a for k, a in sc}
    check("scale: 13 reports, tracks 0..11 and 7F", len(sc) == 13 and set(tr) == set(range(12)) | {0x7F}, sorted(tr))
    check("scale: SD 32 steps speed 0, BD 16 speed 2", tr.get(1, [0] * 5)[1:4] == [32, 0, 0] and
          tr.get(0, [0] * 5)[1:4] == [16, 0, 2], (tr.get(0), tr.get(1)))
    p = tr.get(0x7F, [])
    check("scale: the pattern's: 7 bytes (len, speed, mode, chg), mode 1 (per track), chg 16", len(p) == 7 and
          p[4] == 1 and (p[5] | p[6] << 7) == 16, p)


def t_dirty(e):
    """2D 0B DIRTY <pattern>: none in 3 s of play with nothing edited (the pattern bytes stay put while playing); a trig
    placed in GRID REC (BD, not a seq track): one 0B 00 within 1.3 s."""
    r = e.run("dirty_play", 1000, [(300, "usb", mask2e(())), (350, "press", "PLAY"), (950, "press", "STOP")])
    check("dirty: no 0B while playing an unedited pattern", not reps(r, 0x0B), reps(r, 0x0B))
    ev = [(300, "usb", mask2e(())), (500, "press", "RECORD"), (520, "press", "T3"), (540, "press", "RECORD")]
    r = e.run("dirty_trig", 900, ev)
    d = [m for m in r["msgs"] if m[4] == 0x2D and m[6] == 0x0B]
    print(f"  0B: {[m.hex() for m in d]}")
    check("dirty: a placed trig: 0B 00 (pattern A01)", len(d) >= 1 and d[0][7] == 0, [m.hex() for m in d])


def t_fetch(e):
    """The stock pattern dump, verified here (public format: request F0 00 20 3C 07 00 64 01 01 <n> 00 00 00 05 F7; n =
    the active pattern: its working buffer): the answer F0 00 20 3C 07 00 54 01 01 <pattern> 00 <00 00 00 05: the
    record's header> <13097 B 7-bit packed> <checksum hi lo: the sum of bytes 9.. before it & 0x3fff> <length hi lo: the
    message's - 10> F7, 14988 B; the record 13101 B. While playing with a seq track: the answer comes and no tick is
    dropped. A trig placed (GRID REC + T3, not saved) is in A01's answer, and 0x80 (the community's working buffer
    number, not a MIDI data byte) answers the same bytes."""
    req = bytes.fromhex("f000203c0700640101000000" "0005f7")
    r = e.run("fetch", 1000, [(300, "usb", mask2e((0,))), (350, "press", "PLAY"), (500, "usb", req),
                              (950, "press", "STOP")])
    d = open(os.path.join(e.out, "sq_fetch.usb"), "rb").read()
    i = d.find(b"\xf0\x00\x20\x3c\x07\x00\x54")
    j = d.find(b"\xf7", i)
    m = d[i:j + 1] if i >= 0 else b""
    print(f"  answer {len(m)} B: {m[:15].hex(' ')} .. {m[-5:].hex(' ')}")
    ok = len(m) == 14988 and m[9] == 0 and m[11:15] == b"\x00\x00\x00\x05"
    cs = (m[-5] << 7 | m[-4]) if ok else -1
    ln = (m[-3] << 7 | m[-2]) if ok else -1
    check("fetch: 14988 B, pattern 0, the record header 00000005", ok, len(m))
    check("fetch: checksum = sum(bytes 9 ..) & 0x3fff, length = size - 10",
          ok and cs == sum(m[9:-5]) & 0x3FFF and ln == len(m) - 10, (cs, ln))
    s = e.sq(r["snap"])
    tk = runs_of(ticks(r), 0)
    check("fetch: no tick dropped while the dump went out, ticks on", s["drops"] == 0 and steps_ok(tk, 16) and len(tk) > 15,
          (s["drops"], len(tk)))
    edit = [(300, "press", "RECORD"), (330, "press", "T3"), (360, "press", "RECORD")]
    got = []
    for nr in (0x00, 0x80):
        q = req[:9] + bytes([nr]) + req[10:]
        rr = e.run(f"fetch{nr:02x}", 500, edit + [(420, "usb", q)])
        d = open(os.path.join(e.out, f"sq_fetch{nr:02x}.usb"), "rb").read()
        i = d.find(b"\xf0\x00\x20\x3c\x07\x00\x54")
        got.append(d[i:d.find(b"\xf7", i) + 1] if i >= 0 else b"")
    check("fetch: an unsaved trig is in the active pattern's answer; 00 and 80 answer the same", got[0] and got[0] == got[1]
          and got[0] != m, [len(x) for x in got])


def t_fetchrace(e):
    """1052d: 0026's UI-tick reports (the once-a-second 2D 01 09 POS, ...) never land inside a stock dump: send() waits
    while the sender's SysEx state (0x413db244) is set, as isr_send does (the sq fetch race, found by the REMOTE KEYS
    work at a request at 500 M while playing). The request swept over 480..560 M: every answer whole (14988 B, its
    checksum and length right) and the POS reports still sent."""
    req = bytes.fromhex("f000203c0700640101000000" "0005f7")
    bad, pos, over = [], 0, []
    ov = e.syms["rytm-0026-remote-ui:txsx_over"]
    for t in range(480, 561, 10):   # (10 M = one 20 Hz tick: both tick parities, round 6 N1)
        r = e.run(f"fetchr{t}", 900, [(300, "usb", mask2e((0,))), (350, "press", "PLAY"), (t, "usb", req), (850, "press", "STOP")])
        d = open(os.path.join(e.out, f"sq_fetchr{t}.usb"), "rb").read()
        i = d.find(b"\xf0\x00\x20\x3c\x07\x00\x54")
        m = d[i:d.find(b"\xf7", i) + 1] if i >= 0 else b""
        ok = len(m) == 14988 and (m[-5] << 7 | m[-4]) == sum(m[9:-5]) & 0x3FFF and (m[-3] << 7 | m[-2]) == len(m) - 10
        if not ok:
            bad.append((t, len(m)))
        pos += len([a for k, a in reps(r) if k == 9])
        n = int.from_bytes(e.peek(r["snap"], ov, 4), "big")
        if n:
            over.append((t, n))
    check("fetchrace: the dump whole at every request time 480..560 M (no 0026 message inside it)", not bad, bad)
    check("fetchrace: the POS reports still sent (deferred, not dropped for good)", pos > 0, pos)
    check("fetchrace: the dump wait never ran out (txsx_over 0 at every request time)", not over, over)
    # round 6, N2: eight pattern dumps asked back to back (a C6-like transfer, about 120 KB): every answer whole, 0026's
    # wait follows the sender's progress (never runs out in the middle)
    reqs = [(500, "usb", b"".join(req[:9] + bytes([p]) + req[10:] for p in range(8)))]
    r = e.run("fetch8", 1600, [(300, "usb", mask2e((0,))), (350, "press", "PLAY")] + reqs + [(1550, "press", "STOP")])
    d = open(os.path.join(e.out, "sq_fetch8.usb"), "rb").read()
    got, i = [], 0
    while True:
        i = d.find(b"\xf0\x00\x20\x3c\x07\x00\x54", i)
        if i < 0:
            break
        j = d.find(b"\xf7", i)
        got.append(d[i:j + 1])
        i = j + 1
    whole = [len(m) == 14988 and (m[-5] << 7 | m[-4]) == sum(m[10:-5]) & 0x3FFF for m in got]   # (from byte 10: the
    # pattern number is not summed - patterns 1..7 show it; 0 hides it)
    n = int.from_bytes(e.peek(r["snap"], ov, 4), "big")
    check("fetchrace: 8 dumps back to back: all whole, the wait never ran out", len(got) == 8 and all(whole) and n == 0,
          ([len(m) for m in got], whole, n))
    # round 5, M2: ten trig taps on a seq track while the dump goes out (0026's keys wait for it): every key that went
    # down on the host comes up there (a release never dropped; a press dropped takes its release with it)
    taps = [(505 + 9 * i, "press", f"T{i + 1}", 4) for i in range(10)]   # (GRID REC, not playing: seq mode's trigs)
    r = e.run("fetchtaps", 900, [(300, "usb", mask2e((0,))), (330, "press", "RECORD"), (500, "usb", req)] + taps)
    k = keys(r)
    bal = {c: sum(1 if dn else -1 for cc, dn in k if cc == c) for c in range(10)}
    check("fetchrace: ten taps during the dump: every down matched by its up on the host", all(v == 0 for v in bal.values())
          and any(c < 10 for c, _ in k), (bal, len(k)))
    # round 5, M2: a dump cut by a cable pull (the host gone 3 M into it, a fresh host 100 M later): the sender's SysEx
    # flag is not left set (it is set and cleared per message, pc 0x40002c14 / 0x40002ab6 [measured, --watch]), so 0026
    # is not held by it; send()'s 2 s bound is a guard for a flag that would stay set (not reachable here)
    s0 = e.base[1]
    r = e.run("fetchcut", 1200, [(300, "usb", mask2e((0,))), (330, "press", "RECORD"), (500, "usb", req)],
              extra=["--usb-host-gone", f"{s0 + 503}M:{s0 + 600}M"])
    check("fetchrace: a dump cut by a cable pull leaves the sender's SysEx flag clear (0026 not held)",
          e.peek(r["snap"], 0x413DB244, 4) == bytes(4), e.peek(r["snap"], 0x413DB244, 4).hex())
    # round 6, N2: the key queue's overflow and the bound, driven by the test hook txsx_test (the flag held N ticks
    # with no progress, from 0026's first send): 12 trig taps while it holds 30 ticks overflow the queue - presses
    # dropped with their releases, every key the host saw go down comes up, 4D reports the drops; held 100 ticks the
    # bound (40 ticks without progress) lets the keys out before the hold ends (4D: the wait ran out)
    st_a = e.syms["rytm-0026-remote-ui:st"]
    hook = e.syms["rytm-0026-remote-ui:txsx_test"]
    taps = [(350 + 10 * i, "press", f"T{i + 1}", 4) for i in range(12)]   # (the hold starts at the first key queued)
    for hold, name in ((30, "hookq"), (100, "hookb")):
        r = e.run(name, 1000, [(300, "usb", mask2e((0,))), (330, "press", "RECORD")] + taps,
                  extra=e.pokes({hook: hold.to_bytes(4, "big")}))
        k = keys(r)
        bal = {c: sum(1 if dn else -1 for cc, dn in k if cc == c) for c in range(12)}
        drop = int.from_bytes(e.peek(r["snap"], st_a + 44, 4), "big")
        n = int.from_bytes(e.peek(r["snap"], ov, 4), "big")
        kd = [(m[6] << 7 | m[7], m[8] << 7 | m[9]) for m in r["msgs"] if m[4] == 0x4D and len(m) == 11]
        print(f"  {name}: keys {len(k)}, dropped {drop}, over {n}, 4D {kd}")
        if hold == 30:
            check("fetchrace: the key queue overflowed (flag held 1.5 s): presses dropped with their releases, every "
                  "down on the host matched by its up, 4D says so, the wait did not run out",
                  drop > 0 and all(v == 0 for v in bal.values()) and k and n == 0 and kd and kd[-1][0] == drop,
                  (bal, drop, n, kd))
        else:
            check("fetchrace: the flag held with no progress: the wait runs out after 2 s, the keys go out (4D says so)",
                  n > 0 and k and all(v == 0 for v in bal.values()) and kd and kd[-1][1] > 0, (bal, drop, n, kd))


# ---- 1052d: the user's key rules under a page (NO + a reload key; YES's timing)
CATCH = (0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x84, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x10, 0xB0, 0xB4, 0xB5, 0xB1, 0x81,
         0x82, 0x86)   # rytm-teensy core/ui/remote.cpp kCatchKeys (a voice / status page)
RELOAD_PAT, RELOAD_TRK, RELOAD_KIT, SAVE_KIT = 0x400AF5E0, 0x400AF64A, 0x400AF0D2, 0x400B119C


def mask37(keys):
    b = [0] * 40
    for k in keys:
        b[3 + k // 7] |= 1 << (k % 7)
    return sx(0x37, *b)


def page_ev(keys, t1, t0=300):
    """TRK + YES opens the page, the host's mask (37), then its keepalive (3C) every 150 M until t1"""
    ev = [(t0, "usb", sx(0x3C)), (t0 + 10, "press", "TRK", 30), (t0 + 20, "press", "YES"), (t0 + 60, "usb", mask37(keys))]
    ev += [(t, "usb", sx(0x3C)) for t in range(t0 + 100, t1, 150)]
    return ev


def counted(r):
    """dtboot --count's last status line: {pc: n}"""
    c = {}
    for m in re.finditer(r"^\s*\d+M pc=.*$", r["out"], re.M):
        c = dict((int(a, 16), int(n)) for a, n in re.findall(r"([0-9a-f]{8}):(\d+)", m.group(0)))
    return c


def held_keys(e, snap):
    """0026's key books after the run: stock_down / our_down / eat / both_down, any bit set (a stuck key)"""
    a = e.syms["rytm-0026-remote-ui:st"]
    b = e.peek(snap, a, 940)
    return {n: b[o:o + 32].hex() for n, o in (("stock", 200), ("our", 232), ("eat", 264), ("both", 904))
            if any(b[o:o + 32])}


def t_noreload(e):
    """1052d (the user): on a page that catches NO (kCatchKeys), NO held + PLAYMODE / SCNE / CHRO is stock's reload of
    the kit / pattern / track (kit_reload, 0x400af5e0, 0x400af64a once) and the host sees neither key; NO alone is still
    the page's back (31 NO down / up, at its release, no reload); NO held + LEFT (another caught key): the host gets NO
    down, LEFT down / up, NO up in that order. No key stuck in 0026's books."""
    cnt = []
    for c in (RELOAD_PAT, RELOAD_TRK, RELOAD_KIT):
        cnt += ["--count", f"{c:x}"]
    for name, key, fn in (("kit", "PLAYMODE", RELOAD_KIT), ("pat", "SCNE", RELOAD_PAT), ("trk", "CHRO", RELOAD_TRK)):
        r = e.run(f"nr_{name}", 800, page_ev(CATCH, 800) + [(450, "press", "NO", 60), (480, "press", key, 20)], extra=cnt)
        c, k = counted(r), keys(r)
        check(f"noreload: NO + {key}: stock's reload ({fn:08x} once), neither key to the host",
              c.get(fn) == 1 and not [x for x in k if x[0] in (0x45, 0x13, 0x12, 0xB5)], (c, k))
        check(f"noreload: NO + {key}: the page stays open, no key stuck", (0, 1, 0) not in modes(r)[1:] and
              not held_keys(e, r["snap"]), (modes(r), held_keys(e, r["snap"])))
    r = e.run("nr_alone", 800, page_ev(CATCH, 800) + [(450, "press", "NO", 60)], extra=cnt)
    k = [x for x in keys(r) if x[0] == 0x45]
    check("noreload: NO alone: the page's (31 NO down / up), no reload", k == [(0x45, 1), (0x45, 0)] and
          not any(counted(r).get(f) for f in (RELOAD_PAT, RELOAD_TRK, RELOAD_KIT)), (k, counted(r)))
    r = e.run("nr_left", 800, page_ev(CATCH, 800) + [(450, "press", "NO", 60), (480, "press", "LEFT", 10)])
    k = [x for x in keys(r) if x[0] in (0x45, 0x40)]
    check("noreload: NO held + LEFT: NO down, LEFT down / up, NO up (in order), nothing stuck",
          k == [(0x45, 1), (0x40, 1), (0x40, 0), (0x45, 0)] and not held_keys(e, r["snap"]), (k, held_keys(e, r["snap"])))
    # round 5, M1: FUNC (caught: both sides') + NO is the host's FUNC + NO, NO never held back: a roll (FUNC up first)
    # gives FUNC down, NO down, FUNC up, NO up
    r = e.run("nr_func", 800, page_ev(CATCH + (0x80,), 800) + [(450, "press", "FUNC", 40), (470, "press", "NO", 40)])
    k = [x for x in keys(r) if x[0] in (0x45, 0x80)]
    check("noreload: FUNC + NO rolled (FUNC up first): FUNC down, NO down, FUNC up, NO up - not held back",
          k == [(0x80, 1), (0x45, 1), (0x80, 0), (0x45, 0)] and not held_keys(e, r["snap"]), (k, held_keys(e, r["snap"])))
    # round 5, L7: the host closes the page while NO is kept back, the page opens again while NO is still held: NO's
    # release is eaten (no NO to either page: no back on the new one)
    ev = page_ev(CATCH, 800) + [(450, "press", "NO", 250), (480, "usb", sx(0x3A, 0, 0))]
    ev += [(540, "press", "TRK", 30), (550, "press", "YES"), (590, "usb", mask37(CATCH))]
    ev += [(t, "usb", sx(0x3C)) for t in range(600, 800, 100)]
    r = e.run("nr_close", 800, ev)
    k = [x for x in keys(r) if x[0] == 0x45]
    check("noreload: page closed while NO is kept back, reopened, NO released: no NO to the host, nothing stuck",
          not k and not held_keys(e, r["snap"]) and (0, 0, 1) in modes(r), (k, modes(r), held_keys(e, r["snap"])))


def t_yestime(e):
    """1052d, the YES timing rule (ux1027): on a page whose mask leaves YES out (the poly SEQ page: kCatchKeys without
    YES, plus FUNC and T1..T16), YES is the host's when FUNC or a caught trig is down (31 YES down / up, no stock kit
    save); YES pressed first + PLAYMODE is stock's quick save (SAVE KIT once, no YES to the host). The same for UP /
    DOWN with FUNC down under a mask without them; UP / DOWN alone the Rytm's. No key stuck."""
    seqm = tuple(k for k in CATCH if k != 0x44) + (0x80,) + tuple(range(16))
    cnt = ["--count", f"{SAVE_KIT:x}"]
    r = e.run("yt_func", 800, page_ev(seqm, 800) + [(450, "press", "FUNC", 60), (480, "press", "YES", 10)], extra=cnt)
    k = [x for x in keys(r) if x[0] == 0x44]
    check("yestime: FUNC held + YES: the host's (31 YES down / up)", k == [(0x44, 1), (0x44, 0)] and
          not held_keys(e, r["snap"]), (k, held_keys(e, r["snap"])))
    r = e.run("yt_trig", 800, page_ev(seqm, 800) + [(450, "press", "T1", 60), (480, "press", "YES", 10)], extra=cnt)
    k = [x for x in keys(r) if x[0] == 0x44]
    check("yestime: T1 (the page's) held + YES: the host's", k == [(0x44, 1), (0x44, 0)] and
          not held_keys(e, r["snap"]), (k, held_keys(e, r["snap"])))
    r = e.run("yt_save", 800, page_ev(seqm, 800) + [(450, "press", "YES", 60), (480, "press", "PLAYMODE", 20)], extra=cnt)
    k = [x for x in keys(r) if x[0] in (0x44, 0xB5)]
    check("yestime: YES held + PLAYMODE: stock's SAVE KIT (once), no YES / PLAYMODE to the host",
          counted(r).get(SAVE_KIT) == 1 and not k and not held_keys(e, r["snap"]), (counted(r), k, held_keys(e, r["snap"])))
    # the same rule for UP / DOWN with FUNC (the poly SEQ page leaves UP / DOWN to the Rytm: CHRO's octave shift; its
    # track menu is FUNC + DOWN): a mask without YES, UP and DOWN
    updn = tuple(k for k in seqm if k not in (0x42, 0x43))
    for key, code in (("DOWN", 0x43), ("UP", 0x42)):
        r = e.run(f"yt_func{key.lower()}", 800, page_ev(updn, 800) + [(450, "press", "FUNC", 60), (480, "press", key, 10)])
        k = [x for x in keys(r) if x[0] == code]
        check(f"yestime: FUNC held + {key}: the host's (31 {key} down / up)", k == [(code, 1), (code, 0)] and
              not held_keys(e, r["snap"]), (k, held_keys(e, r["snap"])))
        r = e.run(f"yt_{key.lower()}", 800, page_ev(updn, 800) + [(480, "press", key, 10)])
        k = [x for x in keys(r) if x[0] == code]
        check(f"yestime: {key} alone (not in the mask): the Rytm's, not the host's", not k and not held_keys(e, r["snap"]),
              (k, held_keys(e, r["snap"])))
        # round 5, L6: once the host's next mask came (after FUNC went down) it decides: one without the key -> the Rytm's
        r = e.run(f"yt_func{key.lower()}_mask", 800, page_ev(updn, 800) + [(450, "press", "FUNC", 80), (470, "usb", mask37(updn)),
                                                                           (500, "press", key, 10)])
        k = [x for x in keys(r) if x[0] == code]
        check(f"yestime: FUNC + {key} after the host's next mask (without {key}): the mask's (the Rytm's)", not k and
              not held_keys(e, r["snap"]), (k, held_keys(e, r["snap"])))
    # round 5, L6: FUNC + UP held (the host's) starts no combo map (49 1 5)
    r = e.run("yt_funcup_hold", 800, page_ev(updn, 800) + [(450, "press", "FUNC", 300), (470, "press", "UP", 250)])
    check("yestime: FUNC + UP held 1.25 s: no combo map (no 49 1 4 / 5)", not disp(r, 5) and not disp(r, 4),
          (disp(r, 5), disp(r, 4)))


def t_freezeprobe(e):
    """(2026-10-29, the freezes on rel0-3-0) 0026's freeze probe: the UI task stuck for over 2 s - looping in it (fp.test
    1) or blocked (fp.test 2: asleep in a loop in rui_tick) - is reported from the audio interrupt as 4E 01 <running>
    <stalled s> {word x 9}: running 1 for the loop; for the blocked task its resume PC and stack, a return address into
    rui_tick among them. With nothing stuck, no 4E."""
    fpa = e.syms["rytm-0026-remote-ui:fp"]
    tick = e.syms["rytm-0026-remote-ui:rui_tick"]

    def probes(r):
        out = []
        for m in r["msgs"]:
            if m[4] == 0x4E and len(m) == 54:
                w = [m[8 + 5 * i] << 28 | m[9 + 5 * i] << 21 | m[10 + 5 * i] << 14 | m[11 + 5 * i] << 7 | m[12 + 5 * i]
                     for i in range(9)]
                out.append((m[6], m[7], w))
        return out
    r = e.run("fp_none", 1200, [(300, "usb", sx(0x3C))])
    check("freezeprobe: nothing stuck: no 4E", not probes(r), probes(r))
    r = e.run("fp_loop", 1200, [(300, "usb", sx(0x3C))], extra=e.pokes({fpa + 20: (1).to_bytes(4, "big")}))
    p = probes(r)
    print(f"  loop: {[(a, b, [hex(x) for x in w[:3]]) for a, b, w in p[:2]]}")
    check("freezeprobe: a loop in the UI task: 4E running 1, stalled >= 2 s", p and p[0][0] == 1 and p[0][1] >= 2, p[:1])
    r = e.run("fp_block", 1200, [(300, "usb", sx(0x3C))], extra=e.pokes({fpa + 20: (2).to_bytes(4, "big")}))
    p = probes(r)
    print(f"  blocked: {[(a, b, [hex(x) for x in w]) for a, b, w in p[:1]]}  rui_tick {tick:#x}")
    check("freezeprobe: the UI task blocked: 4E running 0 with its stack, a return address into rui_tick in it",
          p and p[0][0] == 0 and any(tick <= x < tick + 0x200 for x in p[0][2]), [(a, b, [hex(x) for x in w]) for a, b, w in p[:1]])


def modes(r):
    """30: [(page, on, reason)]."""
    return [tuple(m[6:9]) for m in r["msgs"] if m[4] == 0x30 and len(m) == 10]


def png(e, name):
    return open(os.path.join(e.out, f"sq_{name}.png"), "rb").read()


def t_trktrig(e):
    """1037: TRK + TRIG opens the page on the Sidecar's SEQ page of the selected track (30 page 0x10 + track, on, user);
    TRK + TRIG again leaves (reason 3); the TRIG key never reaches the host (no 31 0x30) nor stock (the screen after
    leaving = the base's); with SD selected (TRK + SD) page 0x11; with the TRK + YES page open TRK + TRIG sends the SEQ
    page again (30 0x10 1 0, the page stays) and a second TRK + TRIG leaves; TRIG alone afterwards is stock's (its page).
    FUNC + LFO is stock's again (1036 took it): no 30, the screen LFO alone leaves (the stock LFO page)."""
    tt = lambda t: [(t, "press", "TRK", 30), (t + 10, "press", "TRIG")]   # noqa: E731
    n = e.run("tt_none", 500, [(300, "usb", sx(0x3C))])
    r = e.run("tt_bd", 500, [(300, "usb", sx(0x3C))] + tt(320) + tt(400))
    md = modes(r)
    print(f"  30s {md}, keys {[(hex(c), d) for c, d in keys(r)]}")
    check("trktrig: TRK + TRIG -> 30 0x10 1 0 (BD's SEQ page, user), again -> 30 0 0 3 (escape)",
          md == [(0x10, 1, 0), (0, 0, 3)], md)
    check("trktrig: the TRIG key reached neither the host nor stock (no 31 TRIG; the screen after leaving = no gesture)",
          all(c != 0x30 for c, _ in keys(r)) and png(e, "tt_bd") == png(e, "tt_none"), keys(r))
    r = e.run("tt_sd", 500, [(300, "usb", sx(0x3C)), (310, "press", "TRK", 30), (320, "press", "SD")] + tt(380))
    check("trktrig: SD selected (TRK + SD): 30 0x11 1 0", modes(r)[-1:] == [(0x11, 1, 0)], modes(r))
    r = e.run("tt_open", 600, [(300, "usb", sx(0x3C)), (310, "press", "TRK", 30), (320, "press", "YES")] + tt(380) +
              [(420, "usb", sx(0x3C))] + tt(450) + [(520, "press", "TRIG")])
    md = modes(r)
    print(f"  open: 30s {md}")
    check("trktrig: TRK + YES open (30 0 1 0), TRK + TRIG -> 30 0x10 1 0 (the page stays), again -> 30 0 0 3",
          md == [(0, 1, 0), (0x10, 1, 0), (0, 0, 3)], md)
    e.run("tt_trig", 600, [(300, "usb", sx(0x3C)), (520, "press", "TRIG")])
    check("trktrig: TRIG alone afterwards is stock's (the stock TRIG page, as without the gestures)",
          png(e, "tt_open") == png(e, "tt_trig") and png(e, "tt_trig") != png(e, "tt_none"))
    r = e.run("tt_funclfo", 500, [(300, "usb", sx(0x3C)), (320, "press", "FUNC", 30), (330, "press", "LFO")])
    e.run("tt_lfo", 500, [(300, "usb", sx(0x3C)), (330, "press", "LFO")])
    check("trktrig: FUNC + LFO is stock's again: no 30, no 31 LFO, the screen LFO alone leaves (the stock LFO page)",
          not modes(r) and all(c != 0x35 for c, _ in keys(r)) and png(e, "tt_funclfo") == png(e, "tt_lfo")
          and png(e, "tt_lfo") != png(e, "tt_none"), (modes(r), keys(r)))


def t_trkfx(e):
    """1041: TRK + FX opens the page on the Sidecar's INSERT page (30 2 1 0) as TRK + LFO opens its LFO page; again while
    open: 30 2 1 0 again (the page stays); TRK + YES then leaves (30 0 0 3). The FX key reaches neither the host (no 31
    0x10) nor stock (the screen after leaving = TRK + YES in and out). With the TRK + YES page open: 30 2 1 0. Seq mode
    (BD a seq track, GRID REC, page closed): TRK + FX opens the INSERT page there too, and T1 held + FX without TRK stays
    the host's FX lock key (31 0x10 down / up, no 30)."""
    tf = lambda t: [(t, "press", "TRK", 30), (t + 10, "press", "FX")]   # noqa: E731
    ty = lambda t: [(t, "press", "TRK", 30), (t + 10, "press", "YES")]   # noqa: E731
    e.run("tf_yy", 600, [(300, "usb", sx(0x3C))] + ty(320) + [(400, "usb", sx(0x3C))] + ty(500))
    r = e.run("tf_main", 600, [(300, "usb", sx(0x3C))] + tf(320) + [(400, "usb", sx(0x3C))] + tf(420) + ty(500))
    md = modes(r)
    print(f"  30s {md}, keys {[(hex(c), d) for c, d in keys(r)]}")
    check("trkfx: TRK + FX -> 30 2 1 0 (INSERT, user), again -> 30 2 1 0 (the page stays), TRK + YES -> 30 0 0 3",
          md == [(2, 1, 0), (2, 1, 0), (0, 0, 3)], md)
    check("trkfx: FX reached neither the host nor stock (no 31 FX; the screen after leaving = TRK + YES in and out)",
          all(c != 0x10 for c, _ in keys(r)) and png(e, "tf_main") == png(e, "tf_yy"), keys(r))
    r = e.run("tf_open", 600, [(300, "usb", sx(0x3C))] + ty(320) + tf(380) + [(420, "usb", sx(0x3C))] + ty(500))
    check("trkfx: TRK + YES open (30 0 1 0), TRK + FX -> 30 2 1 0, TRK + YES leaves (30 0 0 3)",
          modes(r) == [(0, 1, 0), (2, 1, 0), (0, 0, 3)], modes(r))
    hold = [(300, "usb", mask2e((0,))), (330, "press", "RECORD")]
    r = e.run("tf_seq", 650, hold + tf(380))
    check("trkfx: seq mode (page closed): TRK + FX -> 30 2 1 0, FX not sent",
          (2, 1, 0) in modes(r) and all(c != 0x10 for c, _ in keys(r)), (modes(r), keys(r)))
    r = e.run("tf_lock", 650, hold + [(360, "press", "T1", 100), (380, "press", "FX")])
    check("trkfx: seq mode, T1 held + FX (no TRK): the host's lock key (31 0x10 down / up), no 30",
          not modes(r) and (0x10, 1) in keys(r) and (0x10, 0) in keys(r), (modes(r), keys(r)))


def t_trkyes(e):
    """1037b, the hardware report "the make prompt's YES did nothing; GRID REC then wrote stock trigs": TRK + TRIG opens
    the SEQ page (its make prompt) and YES pressed while TRK is still held is the page's YES (31 0x44 down / up to the
    host, the page stays open: no 30 close), not TRK + YES's leave. rui1037 left the page there (30 0 0 3) and the YES
    never reached the host. A fresh TRK hold + YES still leaves (30 0 0 3); with the page closed TRK + YES still opens
    (30 0 1 0); TRK + LFO's page the same as TRK + TRIG's. TRK's own LED (55) dark at the end: stock holds no TRK."""
    r = e.run("ty_held", 500, [(300, "usb", sx(0x3C)), (320, "press", "TRK", 60), (330, "press", "TRIG"),
                               (350, "press", "YES", 10), (400, "usb", sx(0x3C)), (420, "press", "TRK", 30),
                               (430, "press", "YES")])
    md, k = modes(r), keys(r)
    print(f"  30s {md}, keys {[(hex(c), d) for c, d in k]}")
    check("trkyes: TRK + TRIG opens (30 0x10 1 0); YES with TRK still held stays on the page; a fresh TRK + YES leaves "
          "(30 0 0 3)", md == [(0x10, 1, 0), (0, 0, 3)], md)
    check("trkyes: that YES reached the host (31 0x44 down / up), TRIG and the second YES did not",
          [x for x in k if x[0] in (0x30, 0x44)] == [(0x44, 1), (0x44, 0)], k)
    lit = subprocess.run([os.path.join(EMU, "target/release/dtpeek"), os.path.abspath(r["snap"]), "leds"], cwd=EMU,
                         env=dict(os.environ, DTEMU_FW=e.fw), capture_output=True, text=True).stdout
    m55 = re.search(r"^led 55: .*-> (.*)$", lit, re.M)
    check("trkyes: TRK's LED as in the base at the end (dark: stock holds no TRK)",
          m55 is not None and m55.group(1) == "Some((8, 8, 8))", m55.group(1) if m55 else lit[:80])
    r = e.run("ty_lfo", 500, [(300, "usb", sx(0x3C)), (320, "press", "TRK", 60), (330, "press", "LFO"),
                              (350, "press", "YES", 10)])
    check("trkyes: TRK + LFO, YES with TRK held: the page stays (30 1 1 0 only), YES the host's",
          modes(r) == [(1, 1, 0)] and (0x44, 1) in keys(r), (modes(r), keys(r)))
    r = e.run("ty_closed", 500, [(300, "usb", sx(0x3C)), (320, "press", "TRK", 60), (340, "press", "YES", 10)])
    check("trkyes: page closed, TRK + YES still opens (30 0 1 0), YES not sent", modes(r) == [(0, 1, 0)] and
          all(c != 0x44 for c, _ in keys(r)), (modes(r), keys(r)))
    r = e.run("ty_tt_close", 500, [(300, "usb", sx(0x3C)), (320, "press", "TRK", 30), (330, "press", "TRIG"),
                                   (380, "press", "TRK", 60), (390, "press", "TRIG"), (410, "press", "YES", 10)])
    check("trkyes: TRK + TRIG in, TRK + TRIG out, YES with that TRK held: TRK + YES opens the page again (30 0 1 0)",
          modes(r) == [(0x10, 1, 0), (0, 0, 3), (0, 1, 0)], modes(r))


def led_rgb(e, snap, led):
    """dtpeek's resolved colour of a panel LED ('Some((r, g, b))')."""
    out = subprocess.run([os.path.join(EMU, "target/release/dtpeek"), os.path.abspath(snap), "leds"], cwd=EMU,
                         env=dict(os.environ, DTEMU_FW=e.fw), capture_output=True, text=True).stdout
    m = re.search(rf"^led {led}: .*-> (.*)$", out, re.M)
    return m.group(1) if m else None


def t_playmode(e):
    """1037b, the hardware report "from MUTE mode the PLAY (mode) key needs MUTE again" (seq mode's page open): with the
    page open (TRK + YES, then the Sidecar's mask: MUTE passed, PLAYMODE caught) MUTE, then PLAYMODE: back in play mode (LED 50 lit,
    MUTE's 49 dark), as stock 1.73 does; PLAYMODE not sent to the host. FUNC + PLAYMODE (the KIT menu) stays the host's
    (31 0xB5). rui1037: PLAYMODE caught, MUTE mode stays."""
    b = [0] * 40   # 37: the Sidecar's page mask (rytm-teensy core/ui/remote.cpp kCatchKeys; MUTE passed), no encoder
    for k in (0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x84, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x10, 0xB0, 0xB4, 0xB5, 0xB1,
              0x81, 0x82, 0x86):
        b[3 + k // 7] |= 1 << (k % 7)
    op = [(300, "usb", sx(0x3C)), (310, "press", "TRK", 30), (320, "press", "YES"), (360, "usb", sx(0x37, *b)),
          (400, "usb", sx(0x3C)),
          (420, "press", "MUTE"), (450, "press", "PLAYMODE"), (470, "usb", sx(0x3C))]
    r = e.run("pm_open", 520, op)
    pm, mu = led_rgb(e, r["snap"], 50), led_rgb(e, r["snap"], 49)
    print(f"  PLAYMODE LED {pm}, MUTE LED {mu}, 30s {modes(r)}, keys {[(hex(c), d) for c, d in keys(r)]}")
    check("playmode: page open, MUTE then PLAYMODE: play mode again (LED 50 lit, 49 dark), PLAYMODE not the host's",
          (0, 1, 0) in modes(r) and pm == "Some((255, 0, 0))" and (0x11, 1) not in keys(r) and mu == "Some((8, 8, 8))" and
          all(c != 0xB5 for c, _ in keys(r)), (pm, mu, keys(r)))
    r0 = e.run("pm_mute", 520, op[:6])
    check("playmode: (control) MUTE alone under the page: MUTE mode (LED 49 lit)", led_rgb(e, r0["snap"], 49) ==
          "Some((255, 0, 0))", led_rgb(e, r0["snap"], 49))
    r = e.run("pm_func", 520, op[:5] + [(440, "press", "FUNC", 30), (450, "press", "PLAYMODE"), (470, "usb", sx(0x3C))])
    check("playmode: page open, FUNC + PLAYMODE (the KIT menu) the host's: 31 0xB5 down / up",
          (0xB5, 1) in keys(r) and (0xB5, 0) in keys(r), keys(r))


def t_lockkeys(e):
    """1036: seq mode (BD a seq track, GRID REC), the page closed (the script opens none): T1 held + SRC, the turns, NO,
    PUSH_A, SMPL, FLTR, AMP, FX, LFO, (1037) TRIG and YES: each reaches the host (31 down / up, 32 summed) and nothing of
    it stock (the screen = the same run without the page keys; BD's track as in the base); after T1's release FLTR is
    stock's again (no 31 0x33 for FLTR; the stock FLTR page); TRK + TRIG with T1 held still opens the SEQ page (30 0x10),
    and FUNC + LFO with T1 held is the host's LFO key (no 30)."""
    hold = [(300, "usb", mask2e((0,))), (330, "press", "RECORD"), (360, "press", "T1", 200)]
    pk = [(370, "press", "SRC"), (380, "turn", "0:2", 3, 5), (400, "press", "NO"), (410, "press", "PUSH_A"),
          (420, "press", "SMPL"), (430, "press", "FLTR"), (440, "press", "AMP"), (450, "press", "FX"),
          (460, "press", "LFO"), (470, "turn", "1:-1", 2, 5), (500, "press", "TRIG"), (520, "press", "YES")]
    a = e.run("lk_none", 650, hold)
    r = e.run("lk_keys", 650, hold + pk)
    k = keys(r)
    print(f"  keys {[(hex(c), d) for c, d in k]}, encs {encs(r)}")
    codes = (0x31, 0x45, 0x70, 0x32, 0x33, 0x34, 0x10, 0x35, 0x30, 0x44)
    check("lockkeys: T1 first and last, between them SRC NO PUSH_A SMPL FLTR AMP FX LFO TRIG YES (down / up each): all "
          "the host's",
          k[:1] == [(0, 1)] and k[-1:] == [(0, 0)] and sorted(k[1:-1]) == sorted(x for c in codes for x in ((c, 1), (c, 0)))
          and [c for c, d in k[1:-1] if d] == list(codes), k)
    tot = {}
    for x, d in encs(r):
        tot[x] = tot.get(x, 0) + d
    check("lockkeys: the turns under T1 (A +6, B -2) the host's", tot == {0: 6, 1: -2}, encs(r))
    check("lockkeys: stock saw none of it (the screen as without the keys, BD's track as in the base)",
          png(e, "lk_keys") == png(e, "lk_none") and e.peek(r["snap"], LIVE, TRACK) == e.peek(e.base[0], LIVE, TRACK))
    r2 = e.run("lk_after", 650, hold + [(600, "press", "FLTR")])
    check("lockkeys: FLTR after T1's release is stock's (no 31 FLTR; the stock FLTR page)", (0x33, 1) not in keys(r2) and
          png(e, "lk_after") != png(e, "lk_none"), keys(r2))
    r3 = e.run("lk_tt", 650, hold + [(380, "press", "TRK", 30), (390, "press", "TRIG")])
    check("lockkeys: TRK + TRIG with T1 held opens BD's SEQ page (30 0x10 1 0), TRIG not sent",
          (0x10, 1, 0) in modes(r3) and all(c != 0x30 for c, _ in keys(r3)), (modes(r3), keys(r3)))
    r4 = e.run("lk_fl", 650, hold + [(380, "press", "FUNC", 30), (390, "press", "LFO")])
    check("lockkeys: FUNC + LFO with T1 held: no 30, LFO the host's (31 0x35 down / up)",
          not modes(r4) and (0x35, 1) in keys(r4) and (0x35, 0) in keys(r4), (modes(r4), keys(r4)))


def t_yes(e):
    """1037, the step preview's key: seq mode (BD a seq track, GRID REC), the page closed, T1 held + YES: 31 0x44 down /
    up between T1's (lockkeys has it among the others); stock: the screen and BD's track as with T1 alone. Without a
    held trig YES is stock's (no 31 YES, the screen YES alone leaves without a 2E). SD the seq track and BD selected (no
    seq mode): T1 + YES both stock's (no 31; BD's track = the stock run's with T1 + YES)."""
    hold = [(300, "usb", mask2e((0,))), (330, "press", "RECORD"), (360, "press", "T1", 100)]
    a = e.run("yes_t1", 600, hold)
    r = e.run("yes_t1yes", 600, hold + [(400, "press", "YES", 20)])
    k = keys(r)
    print(f"  keys {[(hex(c), d) for c, d in k]}")
    check("yes: T1 down, YES down / up, T1 up (31s)", k == [(0, 1), (0x44, 1), (0x44, 0), (0, 0)], k)
    check("yes: stock saw nothing of it (the screen and BD's track as with T1 alone)",
          png(e, "yes_t1yes") == png(e, "yes_t1") and e.peek(r["snap"], LIVE, TRACK) == e.peek(a["snap"], LIVE, TRACK))
    r = e.run("yes_alone", 600, [(300, "usb", mask2e((0,))), (330, "press", "RECORD"), (400, "press", "YES", 20)])
    s = e.run("yes_alone_stock", 600, [(300, "usb", sx(0x3C)), (330, "press", "RECORD"), (400, "press", "YES", 20)])
    check("yes: without a held trig YES is stock's (no 31 YES; the screen as on a Rytm with no seq tracks)",
          all(c != 0x44 for c, _ in keys(r)) and png(e, "yes_alone") == png(e, "yes_alone_stock"), keys(r))
    o = [(300, "usb", mask2e((1,))), (330, "press", "RECORD"), (360, "press", "T1", 100), (400, "press", "YES", 20)]
    r = e.run("yes_other", 600, o)
    s = e.run("yes_other_stock", 600, [(300, "usb", sx(0x3C))] + o[1:])
    check("yes: SD the seq track, BD selected: T1 + YES stock's (no 31; BD's track and the screen as with no 2E)",
          not keys(r) and e.peek(r["snap"], LIVE, TRACK) == e.peek(s["snap"], LIVE, TRACK) and
          png(e, "yes_other") == png(e, "yes_other_stock"), keys(r))


def disp(r, kind):
    """49 1 <kind> ...: [args]."""
    return [list(m[7:-1]) for m in r["msgs"] if m[4] == 0x49 and m[5] == 1 and len(m) > 8 and m[6] == kind]


def t_disp(e):
    """1036b: UP held + T1 / T2 / T5 -> 49 1 1 <page 1 / 2 / 5> (the Pi display's page), the trigs eaten (in GRID REC no
    trig placed, no 31); after the hello 49 2 <BD> <machine> <name> and 49 3 BD's P1..P8 with labels; TRK + SD: 49 2 / 3
    for SD; knob B turned (the base's page: a knob of SD's P1..P8): a 49 3 with a value moved."""
    ev = [(300, "usb", sx(0x3C)), (330, "press", "RECORD"), (400, "press", "UP", 200), (430, "press", "T1"),
          (470, "press", "T2"), (510, "press", "T5"), (650, "press", "TRK", 40), (660, "press", "SD"),
          (750, "turn", "1:-4", 6, 20)]
    r = e.run("disp", 1400, ev)
    pg = [a[0] for a in disp(r, 1)]
    d2, d3 = disp(r, 2), disp(r, 3)
    name = lambda a: bytes(a[2:14]).split(b"\0")[0].decode()   # noqa: E731
    print(f"  pages {pg}; 49 2 {[(a[0], a[1], name(a)) for a in d2]}; 49 3 {[(a[0], a[1::5]) for a in d3][:4]}")
    check("disp: UP + T1 / T2 / T5 -> 49 1 1 1 / 2 / 5", pg == [1, 2, 5], pg)
    check("disp: the trigs eaten (no 31 T, BD's track as in the base: no trig placed in GRID REC)",
          not [k for k in keys(r) if k[0] <= 4] and e.peek(r["snap"], LIVE, TRACK) == e.peek(e.base[0], LIVE, TRACK), keys(r))
    check("disp: 49 2 BD (track 0, a machine and its name), then SD (track 1)",
          len(d2) >= 2 and d2[0][0] == 0 and name(d2[0]) and d2[-1][0] == 1 and name(d2[-1]), d2)
    labs = [bytes(d3[0][2 + 5 * k:6 + 5 * k]).split(b"\0")[0] for k in range(8)] if d3 else []
    print(f"  BD labels {labs}")
    check("disp: 49 3 BD's P1..P8 with labels", bool(d3) and d3[0][0] == 0 and sum(1 for x in labels if x) >= 4
          if (labels := labs) else False, labs)
    sd = [a for a in d3 if a[0] == 1]
    check("disp: SD's 49 3, then one with a value moved by knob B", len(sd) >= 2 and sd[-1][1::5] != sd[0][1::5],
          [a[1::5] for a in sd])


def t_seqpage(e):
    """1040: seq mode with the page open (TRK + TRIG: st.active; the real host opens its SEQ page on 2D 08 1): a held
    trig (the page's, st.our_down) + FUNC + REC / STOP / PLAY -> 2D 0A trigs copy / paste / clear (src 1, the held mask),
    PAGE held -> page copy (src 1), stock does nothing (no stock 0A, BD's track as in the base); FUNC + REC without a
    held key -> stock's track copy (src 0). rui1039 sent RECORD / STOP / PLAY to stock under the page (track ops 5 / 6 /
    7, the host then cleared its whole track)."""
    f = lambda t, k: [(t, "press", "FUNC", 16), (t + 6, "press", k)]   # noqa: E731
    # (the page closes after ~1 s without a host frame: every gesture within that)
    ev = ([(300, "usb", mask2e((0,))), (330, "press", "RECORD"), (345, "press", "TRK", 15), (352, "press", "TRIG"),
           (370, "press", "T1", 30), (371, "press", "T3", 29)] +
          f(380, "RECORD") + [(410, "press", "T2", 28)] + f(418, "STOP") + [(450, "press", "T2", 28)] + f(458, "PLAY") +
          [(490, "press", "PAGE", 28)] + f(498, "RECORD") + f(530, "RECORD"))
    r = e.run("ed_seqpage", 650, ev)
    ed = edits(r)
    print(f"  seq page: {ed}; modes {modes(r)}")
    check("seqpage: the page opened (30 0x10 1 0)", (0x10, 1, 0) in modes(r), modes(r))
    check("seqpage: trigs copy (T1 + T3: mask 5), paste (T2), clear (T2), page copy: src 1; then a stock track copy "
          "(src 0)", [(x[0], x[4], x[5]) for x in ed] == [(13, 1, 5), (14, 1, 2), (15, 1, 2), (9, 1, 0), (5, 0, 0)], ed)
    check("seqpage: BD's live track as in the base", e.peek(r["snap"], LIVE, TRACK) == e.peek(e.base[0], LIVE, TRACK))


def t_recleds(e):
    """1051 (a hardware report on rui1049: the trig LEDs stayed red after leaving GRID REC on a poly track with the SEQ
    page open): 2E BD, GRID REC, the page opened (TRK + TRIG), the host's 34 paints T1..T16 (blue / cyan); RECORD off,
    the page left: every trig and PAGE LED equals the same run without the page and the 34 (stock's own state there)."""
    c34 = [0x2F, 0x2B, 0x2B, 0x2B] * 4
    pre = [(300, "usb", mask2e((0,))), (330, "press", "RECORD")]
    pg = [(345, "press", "TRK", 15), (352, "press", "TRIG"), (380, "usb", sx(0x34, 1, *c34))]
    alive = [(t, "usb", sx(0x3C)) for t in range(360, 520, 20)]   # the host alive while its page shows
    off = [(450, "press", "RECORD")]
    close = [(480, "usb", sx(0x34, 0)), (490, "usb", sx(0x3A, 0, 0))]   # seq mode gone: the host hands back, closes
    a = e.run("recleds_page", 900, pre + pg + alive + off + close)
    b = e.run("recleds_stock", 900, pre + off)
    la, lb = e.leds(a["snap"]), e.leds(b["snap"])
    diff = [(i, la.get(i), lb.get(i)) for i in list(range(16)) + [40, 41, 42, 43] if la.get(i) != lb.get(i)]
    print(f"  modes {modes(a)}; LEDs that differ: {diff[:6]}")
    check("recleds: after RECORD off and the page gone, the trig and PAGE LEDs are stock's (as without the page)",
          not diff, diff[:6])


def t_trigkey(e):
    """1040: seq mode (BD a seq track, GRID REC), the page closed: TRIG alone goes to the host (31 0x30 down / up; it
    opens its SEQ page there, the TRIG view on a second press), stock's TRIG page does not open (the screen as without
    the press); with no 2E (no seq mode) TRIG is stock's (its TRIG page: the screen differs, no 31 TRIG)."""
    base = [(300, "usb", mask2e((0,))), (330, "press", "RECORD")]
    a = e.run("tk_none", 500, base)
    r = e.run("tk_trig", 500, base + [(400, "press", "TRIG", 20)])
    k = keys(r)
    print(f"  keys {[(hex(c), d) for c, d in k]}")
    check("trigkey: TRIG down / up to the host in seq mode", k == [(0x30, 1), (0x30, 0)], k)
    check("trigkey: stock's TRIG page did not open (the screen as without TRIG)", png(e, "tk_trig") == png(e, "tk_none"))
    s0 = e.run("tk_stock_none", 500, [(300, "usb", sx(0x3C)), (330, "press", "RECORD")])
    s = e.run("tk_stock", 500, [(300, "usb", sx(0x3C)), (330, "press", "RECORD"), (400, "press", "TRIG", 20)])
    check("trigkey: no seq mode: TRIG stock's (no 31; its TRIG page)", not keys(s) and png(e, "tk_stock") !=
          png(e, "tk_stock_none"), keys(s))


def t_trkpad(e):
    """1040: the page open with the SEQ page's catch mask (37: TRK caught, the pads passed): TRK + SD selects SD (the
    selected track 0x41318982 = 1); TRK's press and release still the host's (31), the pad stock's. tp_grid: seq mode
    (2E BD, GRID REC, TRK + TRIG's page), CHRO - rui1039 fails it (TRK the host's alone: stock saw SD's pad without TRK,
    a chromatic note, BD stayed selected). tp_chro: outside GRID REC (TRK + YES's page), CHRO - SD selected by rui1039
    too [measured]."""
    sel = 0x41318982
    # the SEQ page's catch mask (rytm-teensy core/ui/remote.cpp kCatchKeys + T1..T16, every encoder): pads and BANKs
    # passed, TRK caught, as on hardware (without a 37 every key is caught, the pads too)
    keys_ = [0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x84, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x10, 0xB0, 0xB4, 0xB5, 0xB1, 0x81,
             0x82, 0x86] + list(range(16)) + list(range(0x70, 0x79))
    mb = [0] * 40
    for x in range(9):
        mb[x // 7] |= 1 << (x % 7)
    for k_ in keys_:
        mb[3 + k_ // 7] |= 1 << (k_ % 7)
    m37 = sx(0x37, *mb)
    for name, pre in (("tp_chro", [(300, "usb", sx(0x3C)), (330, "press", "CHRO"), (360, "press", "TRK", 20), (370, "press", "YES"),
                                   (380, "usb", m37)]),
                      ("tp_grid", [(300, "usb", mask2e((0,))), (330, "press", "RECORD"), (345, "press", "TRK", 15),
                                   (352, "press", "TRIG"), (370, "usb", m37), (380, "press", "CHRO")])):
        base = e.run(name + "_none", 600, pre)
        r = e.run(name, 600, pre + [(420, "press", "TRK", 40), (430, "press", "SD", 10)])
        s0, s1 = e.peek(base["snap"], sel, 1)[0], e.peek(r["snap"], sel, 1)[0]
        k = keys(r)
        print(f"  {name}: selected {s0} -> {s1}; modes {modes(r)}; keys {[(hex(c), d) for c, d in k]}")
        check(f"trkpad ({name}): TRK + SD under the page selects SD (BD without it)", s0 == 0 and s1 == 1, (s0, s1))
        check(f"trkpad ({name}): TRK's press and release the host's (31 0x86), the pad stock's (no 31 0x91)",
              (0x86, 1) in k and (0x86, 0) in k and (0x91, 1) not in k, k)


def u46(e, snap):
    """1046's u46 diagnostics (rui.c: up_used up_d0 src_t src_m combos yes src src_lists seq_ups seq_ops yes_early amp)."""
    b = e.peek(snap, e.syms["rytm-0026-remote-ui:u46"], 48)
    n = "up_used up_d0 src_t src_m combos yes src src_lists seq_ups seq_ops yes_early amp".split()
    return {k: int.from_bytes(b[4 * i:4 * i + 4], "big") for i, k in enumerate(n)}


def t_upcombo(e):
    """1046, UP the one Sidecar modifier: UP + TRIG / LFO / FX / YES do what TRK + TRIG / LFO / FX / YES do (those still
    work: trktrig trkfx trkyes): UP + TRIG -> 30 0x10 1 0 (BD's SEQ page), again 30 0 0 3; UP + LFO 30 1 1 0; UP + FX
    30 2 1 0; the key reaches neither the host nor stock (the screen after leaving = no gesture); UP held 0.5 s with a
    combo asks no map (no 49 1 4). UP + YES (UP held 150 ms first) opens (30 0 1 0) and leaves (30 0 0 3), YES never
    sent; YES 25 ms after UP (a menu's UP then YES rolled over) is no combo: no 30. YES on the page UP + TRIG opened, UP
    still held: the page's (31 YES), the page stays."""
    up = lambda t, k, hold=100, dt=40: [(t, "press", "UP", hold), (t + dt, "press", k)]   # noqa: E731
    n = e.run("up_none", 600, [(300, "usb", sx(0x3C))])
    r = e.run("up_trig", 600, [(300, "usb", sx(0x3C))] + up(320, "TRIG") + up(450, "TRIG"))
    md = modes(r)
    print(f"  UP + TRIG: 30s {md}, keys {[(hex(c), d) for c, d in keys(r)]}, maps {disp(r, 4)}, u46 {u46(e, r['snap'])}")
    check("upcombo: UP + TRIG -> 30 0x10 1 0, again -> 30 0 0 3", md == [(0x10, 1, 0), (0, 0, 3)], md)
    check("upcombo: TRIG reached neither the host nor stock (no 31 TRIG; the screen after leaving = no gesture)",
          all(c != 0x30 for c, _ in keys(r)) and png(e, "up_trig") == png(e, "up_none"), keys(r))
    check("upcombo: UP held 0.5 s with a combo: no map asked (no 49 1 4)", not disp(r, 4), disp(r, 4))
    for k, pg in (("LFO", 1), ("FX", 2)):
        r = e.run(f"up_{k.lower()}", 500, [(300, "usb", sx(0x3C))] + up(320, k))
        check(f"upcombo: UP + {k} -> 30 {pg} 1 0, {k} not sent", modes(r) == [(pg, 1, 0)] and
              all(c not in (0x35, 0x10) for c, _ in keys(r)), (modes(r), keys(r)))
    r = e.run("up_amp", 500, [(300, "usb", sx(0x3C))] + up(320, "AMP"))
    check("upcombo: UP + AMP -> 30 3 1 0 (INSERT on its OUT view), AMP not sent (no 31 0x34)",
          modes(r) == [(3, 1, 0)] and all(c != 0x34 for c, _ in keys(r)) and u46(e, r["snap"])["amp"] == 1,
          (modes(r), keys(r), u46(e, r["snap"])))
    check("upcombo: UP + AMP: no map asked (no 49 1 4)", not disp(r, 4), disp(r, 4))
    r = e.run("up_amp2", 700, [(300, "usb", sx(0x3C))] + up(320, "AMP") + [(400, "usb", sx(0x3C))] + up(450, "AMP"))
    check("upcombo: UP + AMP again while open -> 30 3 1 0 again (go there; no leave)",
          modes(r)[:2] == [(3, 1, 0), (3, 1, 0)] and (3, 0, 0) not in modes(r), modes(r))
    r = e.run("up_lfoamp", 700, [(300, "usb", sx(0x3C))] + up(320, "LFO") + [(400, "usb", sx(0x3C))] + up(450, "AMP"))
    check("upcombo: UP + LFO, then UP + AMP with the page open -> 30 1 1 0, 30 3 1 0", modes(r)[:2] == [(1, 1, 0), (3, 1, 0)] and (3, 0, 0) not in modes(r), modes(r))
    r = e.run("up_amp_t1", 500, [(300, "usb", sx(0x3C)), (320, "press", "T1", 150), (340, "press", "UP", 80), (350, "press", "AMP")])
    check("upcombo: a held trig + UP + AMP: no OUT page (30 3 not sent)", (3, 1, 0) not in modes(r), modes(r))
    r = e.run("up_yes", 600, [(300, "usb", sx(0x3C))] + up(320, "YES") + [(400, "usb", sx(0x3C))] + up(450, "YES"))
    check("upcombo: UP + YES (UP held 200 ms first) -> 30 0 1 0, again -> 30 0 0 3, YES never sent",
          modes(r) == [(0, 1, 0), (0, 0, 3)] and all(c != 0x44 for c, _ in keys(r)), (modes(r), keys(r)))
    r = e.run("up_yesfast", 500, [(300, "usb", sx(0x3C))] + up(320, "YES", 30, 5))
    check("upcombo: YES 25 ms after UP: no combo (no 30; u46.yes_early 1)", not modes(r) and
          u46(e, r["snap"])["yes_early"] == 1, (modes(r), u46(e, r["snap"])))
    r = e.run("up_trigyes", 500, [(300, "usb", sx(0x3C)), (320, "press", "UP", 80), (330, "press", "TRIG"),
                                  (360, "press", "YES", 10)])
    check("upcombo: UP + TRIG opens; YES with UP still held is the page's (31 YES down / up), no close",
          modes(r) == [(0x10, 1, 0)] and (0x44, 1) in keys(r) and (0x44, 0) in keys(r), (modes(r), keys(r)))


def t_upseq(e):
    """1046, on a poly track (seq mode: BD a seq track, GRID REC) with a trig held, UP is the Sidecar's at once: T1 + T3
    held, UP + RECORD -> 2D 0A trigs copy (op 13, src 1, mask 5), T2 + UP + STOP paste (14), T2 + UP + PLAY clear (15),
    as T + FUNC + REC / STOP / PLAY (still: seqedit); RECORD / STOP / PLAY and UP reach neither stock nor the host (BD's
    track as in the base; no 31 UP), no map. Without a held trig UP + PLAY is stock's PLAY (2D 01 1: playing), no 0A of
    the host's. UP + T11 / T12 / T13 in seq mode with a trig held -> 49 1 11..13, no 31 of the trig."""
    u = lambda t, k: [(t, "press", "UP", 30), (t + 10, "press", k)]   # noqa: E731
    ev = ([(300, "usb", mask2e((0,))), (330, "press", "RECORD"), (350, "press", "T1", 60), (352, "press", "T3", 58)] +
          u(370, "RECORD") + [(430, "press", "T2", 50)] + u(440, "STOP") + [(500, "press", "T2", 50)] + u(510, "PLAY"))
    r = e.run("up_seq", 650, ev)
    ed = edits(r)
    print(f"  seq: {ed}; keys {[(hex(c), d) for c, d in keys(r)]}; u46 {u46(e, r['snap'])}")
    check("upseq: T + UP + REC / STOP / PLAY -> trigs copy (mask 5), paste (T2), clear (T2), src 1",
          [(x[0], x[4], x[5]) for x in ed] == [(13, 1, 5), (14, 1, 2), (15, 1, 2)], ed)
    check("upseq: UP and RECORD / STOP / PLAY never reached the host (31: the trigs only)",
          all(c in (0, 1, 2) for c, _ in keys(r)), keys(r))
    check("upseq: BD's live track as in the base (stock copied / pasted / cleared nothing)",
          e.peek(r["snap"], LIVE, TRACK) == e.peek(e.base[0], LIVE, TRACK))
    check("upseq: no map asked", not disp(r, 4), disp(r, 4))
    r = e.run("up_seqplay", 650, [(300, "usb", mask2e((0,))), (330, "press", "RECORD")] + u(400, "PLAY"))
    pl = [a for k, a in reps(r, 1)]
    print(f"  no trig: 0A {edits(r)}, 2D 01 {pl}")
    check("upseq: no held trig: UP + PLAY is stock's PLAY (2D 01 1), no 0A of the host's (src 1)",
          any(a and a[0] == 1 for a in pl) and not [x for x in edits(r) if x[4] == 1], (pl, edits(r)))
    ev = [(300, "usb", mask2e((0,))), (330, "press", "RECORD"), (350, "press", "T1", 200)]
    for i, k in enumerate(("T11", "T12", "T13")):
        ev += [(380 + 40 * i, "press", "UP", 20), (390 + 40 * i, "press", k)]
    r = e.run("up_seqt", 650, ev)
    pages = [a[0] for a in disp(r, 1)]
    check("upseq: T1 held, UP + T11 / T12 / T13 -> 49 1 11, 12, 13; only T1 reached the host",
          pages == [11, 12, 13] and all(c == 0 for c, _ in keys(r)), (pages, keys(r)))


TESTS = dict(recleds=t_recleds, savereload=t_savereload, jump=t_jump, fill=t_fill, ticks=t_ticks, switch=t_switch, pause=t_pause, mode=t_mode, stock=t_stock, rec=t_rec, state=t_state, solo=t_solo,
             hello=t_hello, pin=t_pin, pinvel=t_pinvel, edits=t_edits, seqedit=t_seqedit, scale=t_scale, dirty=t_dirty,
             fetch=t_fetch, fetchrace=t_fetchrace, freezeprobe=t_freezeprobe, noreload=t_noreload, yestime=t_yestime, trktrig=t_trktrig, trkfx=t_trkfx, trkyes=t_trkyes, playmode=t_playmode, lockkeys=t_lockkeys, yes=t_yes, disp=t_disp,
             seqpage=t_seqpage, trigkey=t_trigkey, trkpad=t_trkpad, upcombo=t_upcombo, upseq=t_upseq)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    e = Emu(sys.argv[1])
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    for n in names:
        print(f"== {n}", flush=True)
        TESTS[n](e)
    print("ALL PASS" if not FAILS else f"FAILED: {FAILS}")
    sys.exit(1 if FAILS else 0)


if __name__ == "__main__":
    main()
