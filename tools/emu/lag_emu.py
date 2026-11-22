#!/usr/bin/env python3
"""F4 (Rytm lag after editing Sidecar machines): does the Rytm slow down when a project with samples in its slots has a
PLAITS and a SOPHIE-like user machine edited? Reproduction attempt in rytm-emu, a measurement, not a pass/fail feature test.

    RYTM_EMU=... RYTM_TEENSY=... .venv/bin/python tools/emu/lag_emu.py TAG [samples|nosamples|longsamples|both|real|realctl]
    (--quick: a 6 s sweep and a 4 s tail; --noprobe: no latency probes)

TAG: a rui build (OS 1.74) with its base from tools/emu/us_base.sh TAG; the real-sample variants need the base TAGw from
tools/emu/lag_base.sh TAG (a card with six wav files in /incoming). Scenario, per variant:
  1. BD on PLAITS, SD on U1 = a SOPHIE-like user machine (16 knobs, page 2 = the stock sample words 17..24, as the host
     sends it), a pattern A01 playing: 4 trigs a bar on each of the two tracks.
  2. Samples: `samples` pokes eight waves (saw, noise, square, triangle; 512..4096 frames) into the sample RAM and aims the
     stock sample table (0x41329e70) slots 1..127 at them; `longsamples` the same table with lengths of 1..20 s; `real`
     loads six wav files through the stock UI (SMPL page, FUNC + YES, the file browser), so the project's own bookkeeping
     (names, references) is filled too; `nosamples` and `realctl` are the controls (empty slots).
  3. A sweep of the two tracks' knobs: page 1 (SRC), page 2 (SMPL = words 17..24), the filter (FLTR), page 2 again with
     the QUICK PERF pot moving, in 1 s windows.
  4. A kit without Sidecar machines (pattern A02, kit 1), still playing, in 1 s windows.
Per 1 s window (200 M instructions) it prints: guest instructions executed (the rest the CPU idles: the load), UI ticks of
0026 (rui_tick, 20 a second when the UI task keeps up), audio blocks (1500 a second), the share of the executed
instructions inside the stock sample player (1.74 0x4011c6b8..0x4011cf8a: it runs every block, for every voice), the
Rytm's USB MIDI bytes out, the stock sample voices playing. Latency probes: a track key pressed, the clock until the
UI task has written the selected track (0x400b7df6). The checks compare each phase with the window before the sweep.
"""
import json
import os
import random
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import us_emu as U   # noqa: E402
from us_emu import P, UI, Emu, check, walk_list, meta_events, elek_sym   # noqa: E402

ROOT = U.ROOT

W = 200                       # one window: 200 M instructions = 1 s
SMP_TAB, PCM0 = 0x41329e70, 0x4b8372c0
S_BUF, VOICE_ST = 0x800067f8, 0x80005b30
SAMPLE_FN = (0x4011c6b8, 0x4011cf8c)   # 1.74: the stock sample player, entry .. rts
MIXER = 0x4010ea98            # called once per block
SEL_WRITE = 0x400b7df6        # the UI task's write of the selected track (0x41318982)
LENGTHS = [512, 768, 1024, 1536, 2048, 3072, 4096, 2560]


def waves():
    rng = random.Random(7)
    out = []
    for k, n in enumerate(LENGTHS):
        kind = k % 4
        s = []
        for i in range(n):
            if kind == 0:
                v = ((i * 37) % 256) / 256 * 2 - 1
            elif kind == 1:
                v = rng.uniform(-1, 1)
            elif kind == 2:
                v = 1 if (i // 40) % 2 else -1
            else:
                v = abs(((i * 11) % 512) / 256 - 1) * 2 - 1
            s.append(int(v * 0x5000) & 0xFFFF)
        out.append(s)
    return out


def sample_pokes():
    """--poke args: eight waves in the sample RAM, slots 1..127 pointing at them (slot s -> wave s % 8)."""
    pk, base, at = [], [], PCM0
    for w in waves():
        base.append(at)
        data = b"".join(x.to_bytes(2, "big") for x in w)
        data += b"\0" * (-len(data) % 4)
        for i in range(0, len(data), 4):
            pk += ["--poke", f"{at + i:x}={data[i:i + 4].hex()}"]
        at += len(data)
    for slot in range(1, 128):
        k = slot % len(base)
        ent = base[k].to_bytes(4, "big") + (0xBB800000).to_bytes(4, "big") + LENGTHS[k].to_bytes(4, "big") + \
            (0x40000000).to_bytes(4, "big")
        for i in range(0, 16, 4):
            pk += ["--poke", f"{SMP_TAB + 16 * slot + i:x}={ent[i:i + 4].hex()}"]
    return pk


WAVS = [("KICK", 0.5), ("SNARE", 0.7), ("HAT", 0.3), ("PAD", 3.0), ("LOOP", 2.0), ("NOISE", 1.0)]


def write_wavs(d):
    """Six mono 16-bit 48 kHz wavs (0.3 .. 3 s) in d; tools/emu/lag_base.sh puts them on the card's /incoming."""
    import math
    import struct
    import wave
    rng = random.Random(1)
    os.makedirs(d, exist_ok=True)
    for n, (name, sec) in enumerate(WAVS):
        fr = []
        for i in range(int(48000 * sec)):
            t = i / 48000
            if name == "KICK":
                v = math.sin(2 * math.pi * (60 + 200 * math.exp(-t * 30)) * t) * math.exp(-t * 6)
            elif name == "SNARE":
                v = (rng.uniform(-1, 1) * 0.7 + math.sin(2 * math.pi * 190 * t) * 0.3) * math.exp(-t * 8)
            elif name == "HAT":
                v = rng.uniform(-1, 1) * math.exp(-t * 30)
            elif name == "PAD":
                v = 0.4 * math.sin(2 * math.pi * 220 * t) + 0.3 * math.sin(2 * math.pi * 330 * t)
            elif name == "LOOP":
                v = 0.5 * math.sin(2 * math.pi * 110 * t * (1 + 0.5 * ((i // 12000) % 2)))
            else:
                v = rng.uniform(-1, 1) * 0.6
            fr.append(int(v * 0.8 * 32767))
        w = wave.open(os.path.join(d, f"{n + 1:02d}-{name}.wav"), "wb")
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(48000)
        w.writeframes(b"".join(struct.pack("<h", x) for x in fr))
        w.close()


def load_events(at, n=len(WAVS), step=150):
    """The stock UI loading the card's /incoming files into slots 1..n of track BD (selected, a stock machine): SMPL page, D
    turned to slot k (the first turn opens the list, every fourth moves a step), FUNC + YES opens the file browser at the
    root, DOWN to incoming, YES, DOWN k times to file k, YES loads it (the row shows >k), NO out of browser and list."""
    ev, t = [(at, "press", "SMPL")], at + 2 * step
    for k in range(1, n + 1):
        for _ in range(5):
            ev.append((t, "turn", "3:+8"))
            t += step
        t += 2 * step
        ev += [(t, "press", "FUNC:30"), (t + 10, "press", "YES")]
        t += 3 * step
        for key in ["DOWN", "YES"] + ["DOWN"] * k + ["YES"]:
            ev.append((t, "press", key))
            t += step
        for _ in range(3):
            ev.append((t, "press", "NO"))
            t += step
        t += step
    return ev, t


def long_pokes():
    """--poke args: slots 1..127 = long samples (1 s .. 20 s at 48 kHz, 48000..960000 frames; the data is whatever the RAM
    holds there: the stock player's cost does not depend on it), to see whether anything scales with the sample's length."""
    pk, at = [], PCM0 + 0x40000
    for slot in range(1, 128):
        n = 48000 * (1 + (slot * 7) % 20)
        ent = at.to_bytes(4, "big") + (0xBB800000).to_bytes(4, "big") + n.to_bytes(4, "big") + (0x40000000).to_bytes(4, "big")
        for i in range(0, 16, 4):
            pk += ["--poke", f"{SMP_TAB + 16 * slot + i:x}={ent[i:i + 4].hex()}"]
        at += 0x1000
    return pk


def soph_knobs():
    """SOPHIE as the host sends it: P1..P8 (SRC page), P9..P16 = the sample words 17..24 (page 2 'SOPHIE MORE')."""
    names = ["TUN", "MODL", "COLR", "DCY", "AMT", "HPF", "SPD", "LEV", "DRV", "CUT", "RES", "FLT", "RTIM", "RFB", "RMIX", "RTON"]
    return [dict(p=i + 1, look="dial", kind="number", long=n, short=n) for i, n in enumerate(names)]


def setup_events(t0=100):
    fp = P.plugin_fp("sophie.perc")
    ev, t = meta_events(t0, [P.meta_messages(1, 5, P.ST_READY, P.FLAG_PARAMS, "SOPHIE", "SOPH", "SOPHIE MORE", soph_knobs(), fp=fp)])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    t += 100
    ev1, t = walk_list(t, UI["downs"]["plaits"])                       # BD on PLAITS
    ev += ev1 + [(t, "press", "SD")]
    ev2, t = walk_list(t + 100, UI["downs_sd"]["u1"])                  # SD on U1 (SOPHIE)
    ev += ev2
    # grid trigs: SD (selected) on 1 5 9 13 and 3 11, BD on 1 5 9 13, then play
    ev.append((t, "press", "RECORD"))
    t += 40
    for n in (1, 3, 5, 9, 11, 13):
        ev.append((t, "press", f"T{n}"))
        t += 30
    ev.append((t, "press", "BD"))
    t += 60
    for n in (1, 5, 9, 13):
        ev.append((t, "press", f"T{n}"))
        t += 30
    ev += [(t, "press", "RECORD"), (t + 40, "press", "PLAY")]
    return ev, t + 400


def sweep_events(seconds, rng):
    """(window, [events relative to the window's start], extra args) for the sweep: 4 phases of seconds/4 windows."""
    per = max(1, seconds // 4)
    phases = [("SRC", "page 1"), ("SMPL", "page 2"), ("FLTR", "filter"), ("SMPL", "page 2 + QUICK PERF")]
    out = []
    for ph, (key, label) in enumerate(phases):
        for w in range(per):
            ev, extra = [], []
            if w == 0:
                ev.append((2, "press", key))
            if w % 2 == 0:
                ev.append((6, "press", "BD"))
                ev.append((10, "press", key))
            else:
                ev.append((6, "press", "SD"))
                ev.append((10, "press", key))
            for j in range(12):                           # a knob turn every ~12 M
                enc = rng.randrange(8)
                d = rng.choice(["+8", "-8", "+4", "-4"])
                ev.append((24 + j * 13, "turn", (f"{enc}:{d}", 6, 5)))
            if ph == 3:
                extra = ["--qperf-sweep", "0:255:6@30M/4M"] if w % 2 == 0 else ["--qperf-sweep", "255:0:6@30M/4M"]
            out.append((label, ev, extra))
    return out


class Run:
    """The chain of 1 s windows from the setup's snapshot; each window's numbers."""

    def __init__(self, e, name):
        self.e, self.name, self.rows = e, name, []
        self.snap, self.clock = None, None
        self.sel = "BD"   # the track selected after the setup (BD: its trigs are entered last)
        self.rt = elek_sym(e, "rytm-0026-remote-ui:rui_tick")
        self.prof = os.path.join(e.tmp, "prof.txt")

    def window(self, label, ev=(), extra=(), length=W):
        e = self.e
        idx = len(self.rows)
        for _, kind, val in ev:
            if kind == "press" and val in ("BD", "SD"):
                self.sel = val
        s = e.run(f"{self.name}-w{idx:02d}", length, list(ev), count=[self.rt, MIXER, SAMPLE_FN[0]], save=True, snap=self.snap,
                  start=self.clock, extra=["--profile-after", "0"] + list(extra), env={"DTEMU_PROFILE_DUMP": self.prof})
        m = re.search(r"(\d+) instructions \((\d+) executed, (\d+) idle-skipped\)", e.log)
        inst, ex = (int(m.group(1)), int(m.group(2))) if m else (0, 0)
        tot = in_fn = 0
        top = (0, 0)
        for line in open(self.prof):
            f = line.split()
            if len(f) == 2 and re.fullmatch(r"[0-9a-f]{8}", f[0]):
                a, n = int(f[0], 16), int(f[1])
                tot += n
                if SAMPLE_FN[0] <= a < SAMPLE_FN[1]:
                    in_fn += n
                top = max(top, (n, a))
        vox = sum(1 for v in range(12) if e.peek(s, VOICE_ST + 92 * v + 40, 1)[0])
        slev = sum(1 for v in range(12) if any(e.peek(s, S_BUF + 128 * v, 128)))
        row = dict(label=label, idx=idx, load=100.0 * ex / inst if inst else 0.0, exec_M=ex / 1e6,
                   ui=e.counts.get(self.rt, 0), blocks=e.counts.get(MIXER, 0), fn_pct=100.0 * in_fn / tot if tot else 0.0,
                   usb=sum(len(m) for m in e.sent), vox=vox, slev=slev, hot=f"{top[1]:x}:{100.0 * top[0] / tot if tot else 0:.1f}%")
        self.rows.append(row)
        self.snap, self.clock = s, self.clock + length
        print(f"  {self.name} w{idx:02d} {label:22s} load {row['load']:5.1f}%  ui {row['ui']:3d}  blocks {row['blocks']:4d}  "
              f"sample fn {row['fn_pct']:4.1f}%  usb {row['usb']:5d} B  voices {vox}  S {slev}  hot {row['hot']}", flush=True)
        return row

    def probe(self, label, name):
        """Key-press-to-action latency: the clock from the press of the other track's key to the UI task's write of the
        selected track."""
        e = self.e
        key = "BD" if self.sel == "SD" else "SD"   # (the probe's run is not saved: the selection stays)
        at = 40
        s = e.run(f"{self.name}-{name}", 400, [(at, "press", key)], snap=self.snap, start=self.clock,
                  extra=["--break", f"{SEL_WRITE:x}", "--break-after", f"{at}M"])
        m = re.search(r"BREAK at 0x([0-9a-f]+)", e.log)
        n = re.search(r"(\d+) instructions \(", e.log)
        lat = (int(n.group(1)) / 1e6 - at) / 0.2 if (m and n) else None   # M instructions -> ms (200 M = 1 s)
        print(f"  {self.name} probe {label:24s} key {key}: " + (f"{lat:.1f} ms" if lat is not None else "no response in 1.8 s"))
        return lat


def run_variant(e, name, samples, seconds, tail, probe):
    print(f"-- {name}: {dict(samples='eight short waves poked into slots 1..127', nosamples='empty slots (control)', longsamples='long samples (1..20 s) poked into slots 1..127', real='six real files loaded through the stock UI (slots 1..6)', realctl='the same base, nothing loaded (control)')[name]}", flush=True)
    r = Run(e, name)
    ev, t = [], 100
    if name == "real":      # the stock UI loads the six files of the card's /incoming into slots 1..6 first
        ev, t = load_events(100)
    ev2, t = setup_events(t + 100)
    s = e.run(f"{name}-setup", t, ev + ev2, save=True, extra={"samples": sample_pokes, "longsamples": long_pokes}.get(name, list)())
    m = e.peek(s, 0x8000ea00, 2)
    check(f"{name}: BD plays PLAITS (44), SD plays U1 (35)", (m[0], m[1]) == (44, 35), m.hex())
    if name == "real":
        got = [int.from_bytes(e.peek(s, SMP_TAB + 16 * k + 8, 4), "big") for k in range(1, 8)]
        check(f"{name}: the stock UI loaded six samples (slots 1..6 hold their lengths)",
              got[:6] == [int(sec * 48000) for _, sec in WAVS], str(got))
    if name in ("samples", "longsamples"):
        got = e.peek(s, SMP_TAB + 16 * 8, 16)
        want = LENGTHS[0] if name == "samples" else 48000 * (1 + (8 * 7) % 20)
        check(f"{name}: the sample table points at the samples", int.from_bytes(got[8:12], "big") == want, got.hex())
    r.snap, r.clock = s, e.clock + t
    rows = {}
    rows["pre"] = [r.window("pre-sweep (page 1, idle)") for _ in range(3)]
    rows["pre_lat"] = r.probe("before the sweep", "lat-pre") if probe else None
    sweep = sweep_events(seconds, random.Random(3))
    ph = {}
    for label, ev, extra in sweep:
        ph.setdefault(label, []).append(r.window(label, ev, extra))
    rows["sweep"] = ph
    rows["end_lat"] = r.probe("end of the sweep", "lat-sweep") if probe else None
    # a kit without Sidecar machines: pattern A02 (BANK_A held + T2), playing on
    r.window("kit change A02", [(10, "press", "BANK_A:60"), (30, "press", "T2")])
    rows["post"] = [r.window("kit 1, no Sidecar machine") for _ in range(tail)]
    rows["post_lat"] = r.probe("after the kit change", "lat-post") if probe else None
    return rows


def mean(rows, k):
    return sum(x[k] for x in rows) / len(rows) if rows else 0.0


def judge(name, rows):
    pre = rows["pre"]
    base_load, base_ui, base_fn = mean(pre, "load"), mean(pre, "ui"), mean(pre, "fn_pct")
    worst_sweep = max((mean(v, "load"), k) for k, v in rows["sweep"].items())
    post = rows["post"][-max(2, len(rows["post"]) // 2):]
    print(f"   {name}: before {base_load:.1f}% load, ui {base_ui:.0f}/s, sample fn {base_fn:.1f}%; worst sweep phase "
          f"'{worst_sweep[1]}' {worst_sweep[0]:.1f}%; after the kit change {mean(post, 'load'):.1f}%, ui {mean(post, 'ui'):.0f}/s")
    check(f"{name}: the UI task keeps 20 ticks/s through the sweep (>= 19)",
          all(x["ui"] >= 19 for v in rows["sweep"].values() for x in v), str([x["ui"] for v in rows["sweep"].values() for x in v]))
    check(f"{name}: the UI task keeps 20 ticks/s after the kit change (>= 19)", all(x["ui"] >= 19 for x in rows["post"]),
          str([x["ui"] for x in rows["post"]]))
    check(f"{name}: the load after the kit change is within 1.25x of the load before the sweep (+2 points)",
          mean(post, "load") <= base_load * 1.25 + 2, f"{mean(post, 'load'):.1f}% vs {base_load:.1f}%")
    check(f"{name}: the audio blocks never fall behind (1500 +-5 a second)", all(abs(x["blocks"] - 1500) <= 5 for x in
          rows["pre"] + [y for v in rows["sweep"].values() for y in v] + rows["post"]), "")
    lats = [rows[k] for k in ("pre_lat", "end_lat", "post_lat") if k in rows and rows[k] is not None]
    if lats:
        check(f"{name}: key press to action stays under 150 ms (before / end of the sweep / after the kit change)",
              all(x < 150 for x in lats) and all(rows[k] is not None for k in ("pre_lat", "end_lat", "post_lat")), str(lats))


def main():
    if sys.argv[1:2] == ["--wavs"]:
        return write_wavs(sys.argv[2])
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        sys.exit(__doc__)
    quick, probe = "--quick" in sys.argv, "--noprobe" not in sys.argv
    variants = {"both": ("samples", "nosamples"), "real": ("real", "realctl")}.get(args[1] if len(args) > 1 else "both", (args[1],) if len(args) > 1 else ())
    seconds, tail = (6, 4) if quick else (16, 12)
    out = {}
    for v in variants:
        out[v] = run_variant(Emu(args[0] + ("w" if v.startswith("real") else "")), v, False, seconds, tail, probe)
        judge(v, out[v])
    json.dump(out, open(os.path.join(ROOT, "build", "emu", args[0], f"lag-{'-'.join(variants)}.json"), "w"), indent=1)
    print(f"\n{'ALL PASS' if not U.fails else 'FAILED: ' + '; '.join(U.fails)}")
    sys.exit(1 if U.fails else 0)


if __name__ == "__main__":
    main()
