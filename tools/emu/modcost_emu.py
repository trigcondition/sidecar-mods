#!/usr/bin/env python3
"""F4 follow-up: the mods' own instruction cost while a pattern plays (the profile of dtboot does not cover the mods' area: elekloader's area, bounds in the manifest's elek.area).

    RYTM_EMU=... RYTM_TEENSY=... .venv/bin/python tools/emu/modcost_emu.py TAG [--secs N]

The same cold boot (YES NO NO NO as us_base.sh) and the same stock-machine pattern (keytime_emu.stock_setup) on the stock 1.74
firmware and on TAG's build; then N seconds measured from a snapshot: instructions executed (the rest the emulator skips as idle)
per second, the UI ticks and audio blocks. The difference is what the mods' hooks cost in total with stock machines.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import keytime_emu as K   # noqa: E402
import us_emu as U        # noqa: E402
from us_emu import Emu, card_copy   # noqa: E402


def one(e, fw, label, secs):
    c = card_copy(e, f"mc-{label}")
    pre = [(2600, "press", "YES"), (3000, "press", "NO"), (3400, "press", "NO"), (3800, "press", "NO")]
    ev, t = K.stock_setup(4500)
    s = e.run(f"mc-{label}", t + 100, pre + ev, cold=True, card=c, fw=fw, save=True)
    e.run(f"mc-{label}-win", secs * 200, [], card=c, fw=fw, snap=s, start=t + 100)
    m = re.search(r"(\d+) instructions \((\d+) executed", e.log)
    inst, ex = int(m.group(1)), int(m.group(2))
    print(f"  {label}: executed {ex / 1e6 / secs:.2f} M/s of {inst / 1e6 / secs:.0f} ({100.0 * ex / inst:.2f}%)", flush=True)
    return ex / secs


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    secs = int(a[a.index("--secs") + 1]) if "--secs" in a else 5
    e = Emu(a[0])
    st = one(e, U.STOCK, "stock", secs)
    mo = one(e, e.fw, a[0], secs)
    print(f"mods' total with stock machines, a pattern playing: {(mo - st) / 1e6:+.3f} M instr/s = {(mo - st) / 2e6:+.3f} points of the 200 M/s clock")
    print("DONE", "FAILED: " + "; ".join(U.fails) if U.fails else "no fault")


if __name__ == "__main__":
    main()
