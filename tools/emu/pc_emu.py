#!/usr/bin/env python3
"""Emulator tests of 0026's chord write-back (1030, poly chord proof of concept): while the Rytm live-records, the host's
28 1 <track> <root> <CHD> <INV> <SPR> <VOI> sets the step just recorded on that track to NOTE <root> and locks sound
words 21..24 (P13..P16) to the four values with stock's writers; the Rytm answers 28 2 <track> <step | 7F> <status>
(0x3C stays the remote UI's keepalive).

    RYTM_EMU=... .venv/bin/python tools/emu/pc_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a rui build (0021 slots=1, 0022 rui=1, 0026, 0027) with its base from tools/emu/us_base.sh TAG. The tests first set
BD to 6-OP FM (SRC SRC, DOWN x 20, YES: machine 40, voice byte 0x48), then CHRO, RECORD + PLAY and a chord on the pads
(BD, RS, CH 20 ms apart: stock records one note, the last pad's). The host's messages go in on the USB MIDI port
(--usb-midi, as the other suites' "usb" events), the Rytm's out through DTBOOT_USB_OUT. Every run under DTEMU_STRICT=1
with --usb-host --usb-midi-real. Times are ms after the run's start (200 M instructions = 1 s).
Addresses (rytm-emu, OS 1.73, [measured] in this build's base): the working pattern's live BD track data 0x407dd8e3
(+0x80 notes), live locks 0x407e0774 (+5674 t + 88 step + 2 k), the stored copy of bank pattern i at
0x405c8f38 + 13101 (i + 1) (+4 + 641 t + 0x70 notes, 0x80 | note; +0x2091 the 72 lock slots of 66 B {type, track,
64 coarse values}); stored lock types of sound words 21..24 are 12..15 (the map 0x401c59cc).
"""
import json
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EMU = os.environ.get("RYTM_EMU", os.path.join(os.path.dirname(ROOT), "rytm-emu"))
FAILS = []
ST_PAT = 0x405c8f38
LIVE_BD = 0x407dd8e3
LIVE_LOCKS_BD = 0x407e0774
TYPES = (12, 13, 14, 15)
CHORD = (62, 2, 1, 1, 3)          # root D (the 0x04's note unit: 60 the default), CHD MIN, INV 1, SPR 1, VOI 3
PADS = [(1500, "press", "BD", 200), (1520, "press", "RS", 180), (1540, "press", "CH", 160)]   # notes 60, 62, 68
REC = [(300, "press", "CHRO"), (600, "press", "RECORD", 300), (700, "press", "PLAY")]
DIALOGS = ["YES@2600M", "NO@3000M", "NO@3400M", "NO@3800M"]   # us_base.sh's cold-boot answers


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"   [{detail}]" if detail else ""), flush=True)
    if not ok:
        FAILS.append(name)


def msgchord(track, root, chd, inv, spr, voi):
    return bytes([0xF0, 0x7D, 0x52, 0x54, 0x28, 0x01, track, root, chd, inv, spr, voi, 0xF7])


class Emu:
    def __init__(self, tag):
        self.tag = tag
        self.fw = f"fw/AR173_us_{tag}.syx"
        self.card = f"sections/us_{tag}.img"
        self.base = (f"sections/us_{tag}.snap", json.load(open(os.path.join(EMU, f"sections/us_{tag}.json")))["clock"])
        self.out = os.path.join(os.environ.get("RYTM_OUT_ROOT") or os.path.join(ROOT, "build", "emu"), tag)
        os.makedirs(self.out, exist_ok=True)
        self.fm = None

    def run(self, name, ms, events=(), snap=None, extra=(), usb=True, cold_card=None):
        """events: (ms, 'press', KEY[, hold ms]) / (ms, 'turn', 'ENC:DELTA', count, spacing ms) / (ms, 'usb', bytes).
        cold_card: a cold boot on that card (the dialogs answered), else from snap (path, clock M)."""
        snap = snap or self.base
        start = 0 if cold_card else snap[1]
        at = lambda t: f"{start + t / 5:g}M"   # noqa: E731
        save = os.path.join(self.out, f"pc_{name}.snap")
        cmd = [os.path.join(EMU, "target/release/dtboot"), self.fw]
        cmd += ["--card", cold_card] if cold_card else ["--load", snap[0], "--card", self.card]
        cmd += ["--instr", f"{ms // 5}M", "--every", "100000M", "--save", save]
        if usb:
            cmd += ["--usb-host", "--usb-midi-real"]
        if cold_card:
            for p in DIALOGS:
                cmd += ["--press", p]
        for e in events:
            if e[1] == "press":
                cmd += ["--press", f"{e[2]}@{at(e[0])}" + (f":{e[3] // 5}M" if len(e) > 3 else "")]
            elif e[1] == "turn":
                cmd += ["--turn", f"{e[2]}@{at(e[0])}x{e[3]}/{e[4] // 5}M"]
            else:
                cmd += ["--usb-midi", f"{e[2].hex()}@{at(e[0])}"]
        cmd += list(extra)
        uo = os.path.join(self.out, f"pc_{name}.usb")
        if os.path.exists(uo):
            os.remove(uo)
        r = subprocess.run(cmd, cwd=EMU, env=dict(os.environ, DTEMU_STRICT="1", DTBOOT_USB_OUT=uo,
                                                  DTBOOT_END_PNG=os.path.join(self.out, f"pc_{name}.png")),
                           capture_output=True, text=True)
        out = r.stdout + r.stderr
        open(os.path.join(self.out, f"pc_{name}.dt.txt"), "w").write(" ".join(cmd) + "\n" + out)
        bad = r.returncode != 0 or "FAULT" in out or "strict:" in out
        check(f"{name}: dtboot ran clean (strict, no fault)", not bad,
              "" if not bad else str(re.findall(r".*(?:FAULT|strict:).*", out)[:3] or f"rc {r.returncode}"))
        sysex = []
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
                sysex.append(d[i:j + 1])
                i = j + 1
        return dict(snap=(save, start + ms // 5), sysex=sysex, out=out)

    def peek(self, snap, addr, n):
        r = subprocess.run([os.path.join(EMU, "target/release/dtpeek"), os.path.abspath(snap), "mem", f"{addr:x}",
                            str(n)], cwd=EMU, env=dict(os.environ, DTEMU_FW=self.fw), capture_output=True, text=True)
        b = bytearray()
        for line in r.stdout.splitlines():
            m = re.match(r"^[0-9a-f]+: ((?:[0-9a-f]{2} ?)+)", line)
            if m:
                b += bytes.fromhex(m.group(1).replace(" ", ""))
        return bytes(b[:n])

    def pokes(self, snap, edits):
        """--poke arguments (32-bit words) writing edits {addr: bytes} over the snapshot's memory."""
        mem = {}
        for a, d in edits.items():
            for i, b in enumerate(d):
                mem[a + i] = b
        out = []
        for w in sorted({a & ~3 for a in mem}):
            cur = bytearray(self.peek(snap, w, 4))
            for i in range(4):
                if w + i in mem:
                    cur[i] = mem[w + i]
            out += ["--poke", f"{w:x}={cur.hex()}"]
        return out

    # ---- the pattern
    def live_note(self, snap, step):
        return self.peek(snap, LIVE_BD + 0x80 + step, 1)[0]

    def live_locks(self, snap, step):
        b = self.peek(snap, LIVE_LOCKS_BD + 88 * step + 2 * 21, 8)
        return [int.from_bytes(b[2 * i:2 * i + 2], "big") for i in range(4)]

    def stored(self, snap, pat, step):
        """bank pattern pat (0 = A01): BD's stored note at step, and its slots of types 12..15 {type: value at step}."""
        b = ST_PAT + 13101 * (pat + 1)
        note = self.peek(snap, b + 4 + 0x70 + step, 1)[0]
        L = self.peek(snap, b + 0x2091, 72 * 66)
        slots = {L[66 * j]: L[66 * j + 2 + step] for j in range(72) if L[66 * j] in TYPES and L[66 * j + 1] == 0}
        used = sum(1 for j in range(72) if L[66 * j] != 0xFF and L[66 * j + 1] != 0xFF)
        return note, slots, used


def replies(r):
    return [tuple(m[6:9]) for m in r["sysex"] if len(m) == 10 and m[4] == 0x28 and m[5] == 2]


def trigs(r):
    """0x04 trig reports: (voice byte, note, [P13..P16 coarse])."""
    out = []
    for m in r["sysex"]:
        if len(m) == 43 and m[4] == 0x04:
            p = [(m[8 + 2 * k] << 7) | m[9 + 2 * k] for k in range(16)]
            out.append((m[5], m[6], [v >> 7 for v in p[12:16]]))
    return out


def fm(e):
    """BD on 6-OP FM (machine 40), from the base."""
    if e.fm is None:
        keys = ["SRC", "SRC"] + ["DOWN"] * 20 + ["YES"]
        ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)]
        r = e.run("fm", 500 + 500 * len(keys) + 1500, ev, usb=False)
        m = e.peek(r["snap"][0], 0x8000EA00, 1)[0]
        check("fm: BD's machine is 6-OP FM (40)", m == 40, m)
        e.fm = r["snap"]
    return e.fm


REC_RUN = None


def rec(e):
    global REC_RUN
    if REC_RUN is None:
        ev = REC + PADS + [(1700, "usb", msgchord(0, *CHORD)), (4000, "press", "STOP")]
        REC_RUN = e.run("rec", 4500, ev, snap=fm(e))
    return REC_RUN


def t_rec(e):
    """The chord recorded live (one step, the last pad's note), 28 1 150 ms later: reply 28 2 0 7 0; NOTE = root and
    the four locks live and in A01's stored slots (one slot each); the next loop's 0x04 for that step carries the root
    and P13..P16 = the chord."""
    r = rec(e)
    s = r["snap"][0]
    rp = replies(r)
    print(f"  replies {rp}")
    check("rec: one reply, 28 2 0 <step 7> 0 (ok)", rp == [(0, 7, 0)], rp)
    step = rp[0][1] if rp else 7
    n = e.live_note(s, step)
    check("rec: the step's live NOTE is the root", n == CHORD[0], hex(n))
    lk = e.live_locks(s, step)
    check("rec: live locks of sound words 21..24 = CHD INV SPR VOI (8.8)", lk == [v << 8 for v in CHORD[1:]],
          [hex(x) for x in lk])
    note, slots, used = e.stored(s, 0, step)
    print(f"  stored note {note:#x}, slots {slots}, {used} slots used")
    check("rec: A01's stored NOTE is 0x80 | root", note == 0x80 | CHORD[0], hex(note))
    check("rec: A01's stored slots 12..15 (track 0) hold the chord on the step", slots == dict(zip(TYPES, CHORD[1:])),
          slots)
    others = [st for st in range(16) if st != step and e.live_note(s, st) != 0xFF]
    check("rec: no other step was written", not others, others)
    t = trigs(r)
    print(f"  0x04s {t}")
    check("rec: the pads' 0x04s (60, 62, 68), then the step's playback: note root, P13..P16 the chord",
          len(t) >= 4 and [x[1] for x in t[:3]] == [60, 62, 68] and t[3] == (0x48, CHORD[0], list(CHORD[1:])), t)


def t_save(e):
    """Power off (the firmware saves the working state to the card), cold boot on that card: the NOTE and locks are
    back, live and stored; PLAY: the step's 0x04 carries them."""
    r = rec(e)
    card = os.path.join(e.out, "pc_save.img")
    subprocess.run(["cp", "-c", os.path.join(EMU, e.card), card], check=True)
    snap = r["snap"]
    p = e.run("poweroff", 1000, snap=snap, usb=False, extra=["--card", card, "--power-off", f"{snap[1] + 100}M"])
    check("save: the power-off handler saved the state", "power off: handler finished" in p["out"])
    c = e.run("cold", 22000, cold_card=card, usb=False)
    s = c["snap"][0]
    check("save: after the cold boot BD's live NOTE and locks are back",
          e.live_note(s, 7) == CHORD[0] and e.live_locks(s, 7) == [v << 8 for v in CHORD[1:]],
          (e.live_note(s, 7), e.live_locks(s, 7)))
    note, slots, _ = e.stored(s, 0, 7)
    check("save: and the stored copy", note == 0x80 | CHORD[0] and slots == dict(zip(TYPES, CHORD[1:])), (note, slots))
    pb = e.run("play", 3000, [(500, "press", "PLAY"), (2800, "press", "STOP")], snap=c["snap"])
    t = trigs(pb)
    print(f"  0x04s {t}")
    check("save: PLAY after the reload: the step's 0x04 = (0x48, root, the chord)", t[:1] == [(0x48, CHORD[0],
          list(CHORD[1:]))], t)
    e.cold = c["snap"]


def t_copy(e):
    """FUNC + RECORD (copy), A02 (BANK_A + T2), FUNC + STOP (paste): A02's stored copy has the NOTE and the 4 slots."""
    r = rec(e)
    ev = [(300, "press", "FUNC", 300), (400, "press", "RECORD"), (900, "press", "BANK_A", 400), (1000, "press", "T2"),
          (1600, "press", "FUNC", 300), (1700, "press", "STOP")]
    c = e.run("copy", 2500, ev, snap=r["snap"], usb=False)
    s = c["snap"][0]
    for pat in (0, 1):
        note, slots, _ = e.stored(s, pat, 7)
        check(f"copy: A0{pat + 1}'s stored NOTE and slots 12..15 hold the chord",
              note == 0x80 | CHORD[0] and slots == dict(zip(TYPES, CHORD[1:])), (hex(note), slots))


def t_status(e):
    """Refusals change nothing: not recording -> 3 (step 7F); SD (an analog machine) -> 3; a 28 1.5 s after the pad
    -> 1; the pattern's lock slots full (A01's free slots poked used) -> 2."""
    f = fm(e)
    r = e.run("norec", 1500, [(300, "press", "CHRO"), (500, "press", "BD", 100), (700, "usb", msgchord(0, *CHORD))], snap=f)
    check("status: not recording: 28 2 0 7F 3", replies(r) == [(0, 0x7F, 3)], replies(r))
    check("status: not recording: nothing locked", e.live_locks(r["snap"][0], 7)[0] == 0xFFFF)
    ev = REC + PADS + [(1700, "usb", msgchord(1, *CHORD)), (4000, "press", "STOP")]
    r = e.run("analog", 4500, ev, snap=f)
    check("status: SD (not a Sidecar machine): 28 2 1 7F 3", replies(r) == [(1, 0x7F, 3)], replies(r))
    ev = REC + PADS + [(3100, "usb", msgchord(0, *CHORD)), (4000, "press", "STOP")]
    r = e.run("late", 4500, ev, snap=f)
    s = r["snap"][0]
    check("status: 1.5 s late: 28 2 0 7F 1", replies(r) == [(0, 0x7F, 1)], replies(r))
    check("status: late: the recorded note stays the last pad's, nothing locked",
          e.live_note(s, 7) == 68 and e.live_locks(s, 7) == [0xFFFF] * 4, (e.live_note(s, 7), e.live_locks(s, 7)))
    _, _, used = e.stored(f[0], 0, 7)
    b = ST_PAT + 13101 + 0x2091
    L = e.peek(f[0], b, 72 * 66)
    free = [j for j in range(72) if L[66 * j] == 0xFF]
    fill = {b + 66 * j: bytes([30, 11]) for j in free[:len(free) - 1]}   # one slot left: 71 used, the first new fails
    ev = REC + PADS + [(1700, "usb", msgchord(0, *CHORD)), (4000, "press", "STOP")]
    r = e.run("full", 4500, ev, snap=f, extra=e.pokes(f[0], fill))
    s = r["snap"][0]
    print(f"  slots used before {used}, poked {len(fill)}")
    check("status: lock slots full: 28 2 0 7 2", replies(r) == [(0, 7, 2)], replies(r))
    check("status: full: nothing written (the note the last pad's, no lock)",
          e.live_note(s, 7) == 68 and e.live_locks(s, 7) == [0xFFFF] * 4, (e.live_note(s, 7), e.live_locks(s, 7)))
    fill = {b + 66 * j: bytes([30, 11]) for j in free[:len(free) - 5]}   # 4 + 1 free: all four fit (used + 1 <= 71)
    r = e.run("fit", 4500, ev, snap=f, extra=e.pokes(f[0], fill))
    check("status: 5 slots free: the four fit, ok", replies(r) == [(0, 7, 0)], replies(r))
    check("status: fit: live locks written", e.live_locks(r["snap"][0], 7) == [v << 8 for v in CHORD[1:]])
    _, slots, used = e.stored(r["snap"][0], 0, 7)
    check("status: fit: stock's mirror update stored all four (71 slots used: its limit)",
          slots == dict(zip(TYPES, CHORD[1:])) and used == 71, (slots, used))


def t_keep(e):
    """Keepalives (3C 1, 7 B; and a 13-byte 3C 1 with the chord's bytes, the overloading first tried) are no chord: no
    28 2 reply, nothing locked; a 28 of the wrong length neither."""
    f = fm(e)
    ka = bytes([0xF0, 0x7D, 0x52, 0x54, 0x3C, 0x01, 0xF7])
    ka13 = bytes([0xF0, 0x7D, 0x52, 0x54, 0x3C, 0x01, 0, *CHORD, 0xF7])
    short = bytes([0xF0, 0x7D, 0x52, 0x54, 0x28, 0x01, 0, *CHORD[:4], 0xF7])
    ev = REC + PADS + [(1650, "usb", ka), (1700, "usb", ka13), (1750, "usb", short), (4000, "press", "STOP")]
    r = e.run("keep", 4500, ev, snap=f)
    check("keep: keepalives and a short 28 get no 28 2 and lock nothing", replies(r) == [] and
          e.live_locks(r["snap"][0], 7)[0] == 0xFFFF, replies(r))


TESTS = dict(rec=t_rec, status=t_status, keep=t_keep, copy=t_copy, save=t_save)


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
