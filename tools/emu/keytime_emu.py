#!/usr/bin/env python3
"""F4 follow-up (a tester: mute pads less responsive while the pattern plays): key timing and the instruction budget.

    RYTM_EMU=... RYTM_TEENSY=... .venv/bin/python tools/emu/keytime_emu.py TAG KIND [--late-windows N] [--trials N] [--calib]

KIND: sc (Sidecar machines: BD PLAITS, SD U1 = SOPHIE-like, reporting, playing), stock (stock machines, the same pattern playing),
stopped (as sc, transport stopped). For each KIND, twice: early (right after the setup) and late (after --late-windows 30 s windows of
soak_emu.py's modulation / paging / host traffic, default 12 = 6 min emulated):
  - trials: MUTE held, BD and SD pressed in the same instant (gap 0) and 1 ms apart (0.2 M), at --trials phases of the 50 ms UI tick;
    per trial two runs from the same snapshot: break at stock's mute_set (0x400b78d8, 1.74) for the first and the second call = the
    press-to-mute-state latency of each pad; the mutes word (0x407c23c3, BE, bit t = track t) at the end = dropped presses;
  - a 1 s profile window: executed instructions by region (the audio interrupt's DSP region, the stock sample player, the mods' area
    per mod, the OS rest = tasks), the load (executed / clock), UI ticks (0026 rui_tick), audio blocks.
"""
import json
import os
import random
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lag_emu as L   # noqa: E402
import soak_emu as S  # noqa: E402
import us_emu as U    # noqa: E402
from us_emu import Emu, check, elek_sym   # noqa: E402

MUTE_SET, MUTES = 0x400b78d8, 0x407c23c3


def stock_setup(t0=100):
    """Stock machines: trigs on BD (1 5 9 13) and SD (1 3 5 9 11 13) in grid record, then play."""
    ev, t = [(t0, "press", "RECORD")], t0 + 40
    for n in (1, 5, 9, 13):
        ev.append((t, "press", f"T{n}"))
        t += 30
    ev.append((t, "press", "SD"))
    t += 60
    for n in (1, 3, 5, 9, 11, 13):
        ev.append((t, "press", f"T{n}"))
        t += 30
    ev += [(t, "press", "RECORD"), (t + 40, "press", "PLAY")]
    return ev, t + 400


def regions(prof, layout):
    """Executed instructions by region from a profile dump (addr count per block)."""
    secs = sorted((v, k) for k, v in layout["sections"].items() if k.endswith(".run"))
    out, tot = {}, 0
    for line in open(prof):
        f = line.split()
        if len(f) != 2 or not re.fullmatch(r"[0-9a-f]{8}", f[0]):
            continue
        a, n = int(f[0], 16), int(f[1])
        tot += n
        if L.SAMPLE_FN[0] <= a < L.SAMPLE_FN[1]:
            k = "stock sample player"
        elif layout["ddr"][0] <= a < layout["ddr"][1]:
            k = "mods: " + max(((v, s) for v, s in secs if v <= a), default=(0, "?"))[1].replace(" .run", "")
        elif 0x40100000 <= a < 0x40130000:
            k = "OS 0x4010..0x4012 (audio interrupt: mixer, voices, DSP)"
        elif a < 0x40100000:
            k = "OS 0x4000..0x400f (tasks: UI, sequencer, MIDI, RTOS)"
        else:
            k = "other"
        out[k] = out.get(k, 0) + n
    return out, tot


def trials(e, snap, clock, n, name, rt_phase_rng):
    res = []
    for i in range(n):
        gap = 0.0 if i % 2 == 0 else 0.2          # M: same instant / 1 ms apart
        o = 20 + rt_phase_rng.uniform(0, 10.0)      # the phase against the 10 M UI tick
        ev = [(o, "press", "MUTE:12"), (o + 2.0, "press", "BD:4"), (o + 2.0 + gap, "press", "SD:4")]
        extra = ["--break", f"{MUTE_SET:x}", "--break-after", f"{int((o + 1.9) * 1e6)}"]
        e.run(f"{name}-t{i}a", 400, ev, snap=snap, start=clock, extra=extra)
        m1 = re.search(r"BREAK at 0x([0-9a-f]+)", e.log)
        n1 = re.search(r"(\d+) instructions \(", e.log)
        t1 = int(n1.group(1)) if (m1 and n1) else None
        t2 = None
        if t1:
            extra = ["--break", f"{MUTE_SET:x}", "--break-after", f"{t1 + 200}"]
            e.run(f"{name}-t{i}b", 400, ev, snap=snap, start=clock, extra=extra)
            m2 = re.search(r"BREAK at 0x([0-9a-f]+)", e.log)
            n2 = re.search(r"(\d+) instructions \(", e.log)
            t2 = int(n2.group(1)) if (m2 and n2) else None
        s = e.run(f"{name}-t{i}c", 400, ev, snap=snap, start=clock, save=True)
        mw = e.peek(s, MUTES, 2)
        mut = int.from_bytes(mw, "big") & 0x1fff
        press = (o + 2.0) * 1e6
        res.append(dict(gap_ms=gap / 0.2, phase=round(o, 2), lat1_ms=(t1 - press) / 2e5 if t1 else None,
                        lat2_ms=(t2 - press) / 2e5 if t2 else None, d12_ms=(t2 - t1) / 2e5 if (t1 and t2) else None, mutes=mut, dropped=2 - bin(mut & 3).count("1")))
    return res


def main():
    a = sys.argv[1:]
    if len(a) < 2:
        sys.exit(__doc__)
    tag, kind = a[0], a[1]
    opt = lambda k, d: a[a.index(k) + 1] if k in a else d   # noqa: E731
    late_w, ntr = int(opt("--late-windows", 12)), int(opt("--trials", 12))
    e = Emu(tag)
    man = json.load(open(os.path.join(e.out, "manifest.json")))["elek"]
    rt = elek_sym(e, "rytm-0026-remote-ui:rui_tick")
    ev, t = (stock_setup() if kind == "stock" else L.setup_events(100))
    syms = {n: man["symbols"]["rytm-0026-remote-ui:" + n] for n in ("pmo", "sq", "ed", "pj", "st")}
    run = S.Soak(e, f"kt-{kind}", syms)
    s = e.run(f"kt-{kind}-setup", t, ev, save=True)
    m = e.peek(s, 0x8000ea00, 2)
    check(f"{kind}: machines", (m[0], m[1]) == ((44, 35) if kind != "stock" else (m[0], m[1])), m.hex())
    run.snap, run.clock = s, e.clock + t
    out, rng = {}, random.Random(5)
    prof = os.path.join(e.tmp, "prof.txt")

    def phase(label):
        if kind == "stopped":
            s2 = e.run(f"kt-{kind}-{label}-stop", 400, [(10, "press", "STOP")], snap=run.snap, start=run.clock, save=True)
            run.snap, run.clock = s2, run.clock + 400
        r = dict(trials=trials(e, run.snap, run.clock, ntr, f"kt-{kind}-{label}", rng))
        e.run(f"kt-{kind}-{label}-prof", 200, [], snap=run.snap, start=run.clock, count=[rt, L.MIXER],
              extra=["--profile-after", "0"], env={"DTEMU_PROFILE_DUMP": prof})
        mm = re.search(r"(\d+) instructions \((\d+) executed", e.log)
        reg, tot = regions(prof, man["layout"])
        r["profile"] = dict(load=100.0 * int(mm.group(2)) / int(mm.group(1)), ui=e.counts.get(rt, 0), blocks=e.counts.get(L.MIXER, 0),
                            executed_M=int(mm.group(2)) / 1e6, regions_pct={k: round(100.0 * v / tot, 2) for k, v in sorted(reg.items(), key=lambda x: -x[1])})
        la = [x["lat1_ms"] for x in r["trials"] if x["lat1_ms"] is not None]
        lb = [x["lat2_ms"] for x in r["trials"] if x["lat2_ms"] is not None]
        r["summary"] = dict(n=len(r["trials"]), dropped=sum(x["dropped"] for x in r["trials"]),
                            lat1_ms=(min(la), sum(la) / len(la), max(la)) if la else None,
                            lat2_ms=(min(lb), sum(lb) / len(lb), max(lb)) if lb else None, no_call=sum(1 for x in r["trials"] if x["lat1_ms"] is None))
        print(f"  {kind}/{label}: {r['summary']}  load {r['profile']['load']:.1f}% ui {r['profile']['ui']} blocks {r['profile']['blocks']}", flush=True)
        for k, v in r["profile"]["regions_pct"].items():
            print(f"      {v:6.2f}%  {k}", flush=True)
        return r
    if "--calib" in a:
        r = trials(e, run.snap, run.clock, 4, f"kt-{kind}-calib", rng)
        print(json.dumps(r, indent=1))
        return
    out["early"] = phase("early")
    if kind != "stopped" or True:
        if kind == "stopped":     # (restart the transport for the long phase)
            s2 = e.run(f"kt-{kind}-restart", 400, [(10, "press", "PLAY")], snap=run.snap, start=run.clock, save=True)
            run.snap, run.clock = s2, run.clock + 400
        for w in range(late_w):
            run.soak_window(w, S.window_events(w, 30, rng), ["--qperf-sweep", "0:255:6@30M/4M"], 30)
            print(f"   long phase window {w + 1}/{late_w}", flush=True)
    out["late"] = phase("late")
    json.dump(out, open(os.path.join(e.out, f"keytime-{kind}.json"), "w"), indent=1)
    print("DONE", "FAILED: " + "; ".join(U.fails) if U.fails else "no fault")


if __name__ == "__main__":
    main()
