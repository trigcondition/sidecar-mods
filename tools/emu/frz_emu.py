#!/usr/bin/env python3
"""The UI never waits on USB: host brown-outs, a stalled host and a stuck MIDI mutex in rytm-emu (2026-10-16).

    .venv/bin/python tools/emu/frz_emu.py TAG [TEST ...]|all      exit 0 when every check passes

TAG: a build whose base tools/emu/us_base.sh TAG made (rytm-emu fw/AR173_us_TAG.syx, sections/us_TAG.snap). Every
run DTEMU_STRICT=1 with --usb-host --usb-midi-real (the firmware's own USB MIDI sender and request pool), PLAY pressed
at the start. Each test checks, per 0.5 s of emulated time: the UI renders (0x400a2aaa, 20 Hz: >= 9 a window), the
sequencer steps (0x40120c38, the step counter 0x8000e570's writer [measured: +1 a 16th while playing, never while
stopped]), and that keys pressed late still reach the UI (0x400a02ca, the key dispatch).

    restart  the USB host browns out and comes back four times (rytm-emu --usb-host-gone: VBUS off, no bus, then a
             fresh enumeration), in the middle of the 0x20 report stream (SysEx) and of 0029's ASK cycle
    stall    the host stops reading MIDI IN for 3 s (--usb-host-noread), then sleeps 2 s (--usb-host-sleep)
    partial  the host sends half a SysEx (21 without F7) and vanishes; back 0.5 s later
    mutex    injected: the MIDI mutex 0x42f67a28 owned by a task that never gives it (--poke owner = 1; the state a
             task stuck in the sender's ring spin leaves): every UI-task MIDI_LOCK (0x40002914) waits forever
Firmware-derived output (logs) stays in build/emu/TAG (git-ignored).
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EMU = os.environ.get("RYTM_EMU", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "rytm-emu"))
RENDER, STEP, KEYS, LOCK = 0x400a2aaa, 0x40120c38, 0x400a02ca, 0x40002914
BASE = 7400   # M instructions: us_base.sh's snapshot clock
FAILS = []


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"   [{detail}]" if detail else ""), flush=True)
    if not ok:
        FAILS.append(name)


def at(ms):
    return f"{BASE + ms // 5}M"


def run(tag, name, ms, extra):
    out = os.path.join(ROOT, "build", "emu", tag)
    os.makedirs(out, exist_ok=True)
    cmd = [os.path.join(EMU, "target/release/dtboot"), f"fw/AR173_us_{tag}.syx", "--load", f"sections/us_{tag}.snap",
           "--card", f"sections/us_{tag}.img", "--instr", f"{ms // 5}M", "--every", "100M", "--usb-host",
           "--usb-midi-real", "--press", f"PLAY@{at(200)}", *extra]
    for a in (RENDER, STEP, KEYS, LOCK):
        cmd += ["--count", f"{a:x}"]
    r = subprocess.run(cmd, cwd=EMU, env=dict(os.environ, DTEMU_STRICT="1"), capture_output=True, text=True)
    txt = r.stdout + r.stderr
    open(os.path.join(out, f"frz-{name}.txt"), "w").write(txt)
    rows = []
    for m in re.finditer(r"^\s*(\d+)M pc=\S+ .*$", txt, re.M):
        cs = dict((int(a, 16), int(n)) for a, n in re.findall(r"([0-9a-f]{8}):(\d+)", m.group(0)))
        rows.append((int(m.group(1)), cs))
    fault = "FAULT" in txt or "strict:" in txt or r.returncode != 0
    check(f"{name}: dtboot ran clean (strict, no fault)", not fault, "" if not fault else f"rc {r.returncode}")
    return rows


def judge(name, rows, key_at_ms):
    """per 0.5 s window (a row = 100M): renders >= 9; steps advance in every 1 s from 0.5 s after PLAY on; the late
    keys reach the dispatch"""
    g = lambda row, a: row[1].get(a, 0)   # noqa: E731
    rend = [g(b, RENDER) - g(a, RENDER) for a, b in zip(rows, rows[1:])]
    steps = [g(b, STEP) - g(a, STEP) for a, b in zip(rows[1:], rows[3:])]
    before = [r for r in rows if r[0] <= BASE + key_at_ms // 5]
    k0 = g(before[-1], KEYS) if before else 0
    k1 = g(rows[-1], KEYS) if rows else 0
    check(f"{name}: the UI renders at 20 Hz throughout", rend and min(rend) >= 9,
          f"renders per 0.5 s: min {min(rend) if rend else '-'} max {max(rend) if rend else '-'}")
    check(f"{name}: play runs throughout (steps every second)", steps and min(steps) >= 6,
          f"steps per 1 s: min {min(steps) if steps else '-'}, total {g(rows[-1], STEP) if rows else 0}")
    check(f"{name}: keys pressed late reach the UI", k1 > k0, f"key dispatch {k0} -> {k1}")
    print(f"    UI-task MIDI_LOCK calls: {g(rows[-1], LOCK) if rows else 0}")


def t_restart(tag):
    ev = []
    for t in (600, 1500, 2300, 3100):
        ev += ["--usb-host-gone", f"{at(t)}:{at(t + 300)}"]
    ev += ["--press", f"AMP@{at(4000)}", "--press", f"FLTR@{at(4300)}"]
    judge("restart", run(tag, "restart", 5000, ev), 3900)


def t_stall(tag):
    ev = ["--usb-host-noread", f"{at(600)}:{at(3600)}", "--usb-host-sleep", f"{at(3600)}:{at(5600)}",
          "--press", f"AMP@{at(5000)}", "--press", f"FLTR@{at(5300)}"]
    judge("stall", run(tag, "stall", 6500, ev), 4900)


def t_partial(tag):
    ev = ["--usb-midi", f"f07d52542101010e434f4d4220@{at(800)}", "--usb-host-gone", f"{at(805)}:{at(1300)}",
          "--press", f"AMP@{at(2500)}", "--press", f"FLTR@{at(2800)}"]
    judge("partial", run(tag, "partial", 3500, ev), 2400)


def t_mutex(tag):
    ev = ["--poke", "42f67a28=00000001", "--press", f"AMP@{at(4000)}", "--press", f"FLTR@{at(4300)}"]
    judge("mutex", run(tag, "mutex", 5000, ev), 3900)


TESTS = dict(restart=t_restart, stall=t_stall, partial=t_partial, mutex=t_mutex)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    tag, names = sys.argv[1], sys.argv[2:]
    if names == ["all"]:
        names = list(TESTS)
    for n in names:
        print(f"== {n}", flush=True)
        TESTS[n](tag)
    print("ALL PASS" if not FAILS else f"FAILED: {len(FAILS)}: {', '.join(FAILS)}")
    sys.exit(1 if FAILS else 0)


if __name__ == "__main__":
    main()
