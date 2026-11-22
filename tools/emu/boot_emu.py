#!/usr/bin/env python3
"""F4 follow-up (a tester's restart reports): a Rytm cold boot while the host side is already running, and what state comes back.

    RYTM_EMU=... RYTM_TEENSY=... .venv/bin/python tools/emu/boot_emu.py TAG [--saved|--unsaved|--both]

Prep (base snapshot, a card copy): BD on PLAITS, SD on U1 (a SOPHIE-like machine, host's 1A answered), SD's P9..P16 turned to
known values, the pattern playing; --saved: SAVE KIT (FUNC + PLAYMODE, the stock UI) afterwards; then --power-off (the working
state goes to the card). --unsaved: no SAVE KIT.
Cold boots on that card (4400 M = 22 s emulated, then 1000 M more):
  quiet    no host traffic (the control)
  host     the host already running before the boot ends: a keepalive every 200 M from 50 M, the slot generations every 1000 M,
           the SOPHIE 1A (twice) after the boot; a flood phase (a keepalive every 2 M) 100 M .. 2000 M
  noread   as host, and the host never reads the Rytm's MIDI out (--usb-host-noread 0)
Per boot: UI ticks (0026 rui_tick) in the 1000 M after the boot, the machines of BD / SD, SD's kit words P1..P16, the kit's tag,
the Rytm's USB bytes out, whether the main screen came up; then a kit round trip (pattern A02 = kit 1, then A01 again) and the same
words once more.
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lag_emu as L   # noqa: E402
import us_emu as U    # noqa: E402
from us_emu import P, UI, Emu, check, elek_sym, kit_menu, kit16, card_copy, meta_events   # noqa: E402


def host_events(flood=True, t_end=5400):
    ev = []
    t = 50
    while t < t_end:
        ev.append((t, "usb", P.rui_keepalive()))
        t += 2 if (flood and 100 <= t < 2000) else 200
    for t in range(1000, t_end, 1000):
        ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    fp = P.plugin_fp("sophie.perc")
    for t in (4500, 4900):
        ev.append((t, "usb", b"".join(P.meta_messages(1, 5, P.ST_READY, P.FLAG_PARAMS, "SOPHIE", "SOPH", "SOPHIE MORE", L.soph_knobs(), fp=fp))))
    return sorted(ev, key=lambda x: x[0])


def prep(e, save, tag):
    c = card_copy(e, f"prep-{tag}")
    ev, t = L.setup_events(100)
    ev += [(t + 50, "press", "SD")]
    t += 100
    ev += [(t + 20 * k, "turn", (f"{k % 8}:+8", 3, 5)) for k in range(1, 9)]   # SD's encoders: known kit words
    t += 400
    if save:
        ev2, t2 = kit_menu(t, 2)
        ev += ev2 + [(t2 + 200, "press", "YES"), (t2 + 400, "press", "YES")]
        t = t2 + 800
    off = e.clock + t + 600
    s = e.run(f"prep-{tag}", t + 700, ev, card=c, save=True, extra=["--power-off", f"{off}M"])
    want = dict(machines=e.peek(s, 0x8000ea00, 2).hex(), sd=kit16(e, s, 1), bd=kit16(e, s, 0))
    return c, want


def boot(e, c, name, host, noread=False):
    rt = elek_sym(e, "rytm-0026-remote-ui:rui_tick")
    ev = host_events() if host else []
    extra = ["--usb-host-noread", "0"] if noread else []
    s = e.run(f"{name}-boot", 4400, [x for x in ev if x[0] < 4400], card=c, cold=True, save=True, count=[rt], extra=extra)
    ui_boot = e.counts.get(rt, 0)
    out1 = len(e.sent)
    s2 = e.run(f"{name}-after", 1000, [(a - 4400, k, v) for a, k, v in ev if a >= 4400], card=c, snap=s, start=4400, save=True, count=[rt], extra=extra)
    r = dict(ui_boot=ui_boot, ui_after=e.counts.get(rt, 0), sent_boot=out1, machines=e.peek(s2, 0x8000ea00, 2).hex(),
             sd=kit16(e, s2, 1), bd=kit16(e, s2, 0), word0=U.word0(e, s2, 1))
    # a kit round trip: pattern A02 (kit 1) then A01 (kit 0)
    ev3 = [(10, "press", "BANK_A:60"), (30, "press", "T2")]
    s3 = e.run(f"{name}-kit1", 1000, ev3, card=c, snap=s2, start=5400, save=True, extra=extra)
    ev4 = [(10, "press", "BANK_A:60"), (30, "press", "T1")]
    s4 = e.run(f"{name}-kit0", 1000, ev4, card=c, snap=s3, start=6400, save=True, extra=extra)
    r.update(machines_back=e.peek(s4, 0x8000ea00, 2).hex(), sd_back=kit16(e, s4, 1), bd_back=kit16(e, s4, 0))
    return r


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    e = Emu(a[0])
    modes = {"--saved": [True], "--unsaved": [False], "--both": [True, False]}.get(a[1] if len(a) > 1 else "--both")
    res = {}
    for save in modes:
        tag = "saved" if save else "unsaved"
        c, want = prep(e, save, tag)
        print(f"== {tag}: before the power-off {want}", flush=True)
        res[tag] = dict(want=want)
        for name, host, nr in (("quiet", False, False), ("host", True, False), ("noread", True, True)):
            r = boot(e, c, f"{tag}-{name}", host, nr)
            res[tag][name] = r
            print(f"  {tag}/{name}: ui ticks in the 5 s after the boot {r['ui_after']} (boot {r['ui_boot']}), machines {r['machines']}, "
                  f"SD words {r['sd'][:16]} (want {want['sd'][:16]}), after kit round trip: machines {r['machines_back']}, SD {r['sd_back'][:16]}", flush=True)
    json.dump(res, open(os.path.join(e.out, "boot.json"), "w"), indent=1)
    print("DONE", "FAILED: " + "; ".join(U.fails) if U.fails else "no fault")


if __name__ == "__main__":
    main()
