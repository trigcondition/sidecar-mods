#!/usr/bin/env python3
"""tools/emu/us_window.py - one step of the end-to-end run: rytm-emu's window, headless with its
USB MIDI ports open (so rytm-teensy's sim/teensy_bridge.py connects the real Teensy), started from a
base snapshot, keys by name, a screenshot after SECS. --ob-link too: the bridge reads the Teensy's
answers (its 1A names, its log lines) only while it serves the window's Overbridge link (127.0.0.1:7301),
and the window's link closes with it, so the bridge exits after each step: start it again per step. The Rytm's state is not kept between steps
(the card is written back: give each step a fresh copy); the Teensy's is (its assignments, its store).

    .venv/bin/python tools/emu/us_window.py TAG SNAP CARD SECS OUT.png EVENT...

EVENT: KEY@SECS[:HOLD] (names as in rytm-emu src/panel.rs RYTM_KEYS: SRC, DOWN, YES, FUNC, CHRO, BD, ...)
       or TURN:ENC:DELTA@SECS (ENC 0..7 = knobs A..H).
TAG picks fw/AR173_us_<TAG>.syx in rytm-emu. Seconds are wall-clock; the window runs about real time.
"""
import os
import re
import subprocess
import sys

EMU = os.environ.get("RYTM_EMU", "../rytm-emu")


def key_codes():
    """Key name -> the window's --press code (100 + index in RYTM_KEYS)."""
    src = open(os.path.join(EMU, "src", "panel.rs")).read()
    table = src[src.index("pub const RYTM_KEYS"):]
    table = table[:table.index("];")]
    names = re.findall(r'\("([A-Z0-9_]+)",', table)
    base = int(re.search(r"pub const RYTM_CODE_BASE: u8 = (\d+);", src).group(1))
    return {n: base + i for i, n in enumerate(names)}


def main():
    a = sys.argv[1:]
    if len(a) < 5:
        sys.exit(__doc__)
    tag, snap, card, secs, png, rest = a[0], a[1], a[2], a[3], a[4], a[5:]
    codes = key_codes()
    cmd = [os.path.join(EMU, "target", "release", "rytm"), os.path.join(EMU, "fw", f"AR173_us_{tag}.syx"),
           "--card", card, "--snapshot", snap, "--headless", "--midi", "--usb-host", "--ob-link", "--audio-null",
           "--after", secs, "--screenshot", os.path.abspath(png)]
    for ev in rest:
        what, at = ev.split("@", 1)
        if what.startswith("TURN:"):
            _, enc, delta = what.split(":")
            cmd += ["--turn", f"{enc}:{delta}@{at}"]
        elif what in codes:
            cmd += ["--press", f"{codes[what]}@{at}"]
        else:
            sys.exit(f"unknown key {what} (keys: {' '.join(codes)})")
    print(" ".join(cmd), flush=True)
    sys.exit(subprocess.run(cmd, cwd=EMU).returncode)


if __name__ == "__main__":
    main()
