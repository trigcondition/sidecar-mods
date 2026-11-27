#!/usr/bin/env python3
"""Machine-list lag (a tester's black box 2026-11-21): does the Rytm's UI task fall behind while machines are auditioned in the
machine list on a Sidecar track during playback, and which part costs it? A measurement, not a pass/fail test.

    RYTM_EMU=... RYTM_TEENSY=... .venv/bin/python tools/emu/mll_emu.py TAG CASE [--ips N] [--browse S] [--tail S] [--step MS]

CASE: A  play (BD PLAITS + SD U1), no browsing, the host's quiet traffic (3C 4 a second)
      B  browse BD's list among Sidecar machines (6-OP FM .. WAVETABLE) while playing, the host answering each preview with
         a whole SRC frame (8 rects + 16 texts + commit, about 1.5 kB, 26 messages) and 2 commits a second
      C  as B, the host sends no frames (only its 3C)
      D  browse BD's list among stock machines (BD on its stock machine) while playing, host as B
      E  as B, stopped
      F  as B, the frames only (no list: the frames at the same times on the plain SRC page, no machine change)
Per window of 1 emulated second (IPS M instructions): rui_tick visits (0026's UI tick; top_age counts these), audio blocks,
load (executed / clock), BD's machine byte, the Rytm's USB bytes out; the profile by function (one sample per 64 instr).
"""
import bisect
import json
import os
import random
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import us_emu as U   # noqa: E402
from us_emu import P, UI, Emu, check, walk_list, meta_events, elek_sym   # noqa: E402
import lag_emu as L  # noqa: E402

A = sys.argv[1:]
def opt(k, d):
    return type(d)(A[A.index(k) + 1]) if k in A else d
IPS = opt("--ips", 200)
BROWSE = opt("--browse", 20)
TAIL = opt("--tail", 10)
STEP_MS = opt("--step", 300)
HOLD_MS = 80
MACH = 0x8000ea00
OUT = os.environ.get("MLL_OUT", "/tmp/mll")
NOHOST = False   # cases N / AN: no USB host after the setup (an unplugged cable): no reports, no frames
import subprocess   # noqa: E402
_orig_run = subprocess.run


def _run(cmd, **kw):
    if NOHOST and isinstance(cmd, list) and cmd and "dtboot" in str(cmd[0]):
        cmd = [c for c in cmd if c not in ("--usb-host", "--usb-midi-real")]
    return _orig_run(cmd, **kw)


subprocess.run = _run


def ms(x):
    return int(round(x * IPS / 1000.0))


def symtab(e):
    syms = {}
    elek = json.load(open(os.path.join(e.out, "manifest.json")))["elek"]
    area_lo = elek["area"][0]      # elekloader's area, from the manifest (not a constant)
    mp = json.load(open(os.path.join(U.ROOT, "build", f"Analog-Rytm_MKII_OS1.74_{e.tag}.syx.map.json")))
    for k, v in mp.items():
        if isinstance(v, str):
            try:
                v = int(v, 16)
            except ValueError:
                continue
        if ":" not in k and isinstance(v, int) and v < area_lo:
            syms[v] = k
    for k, v in elek["symbols"].items():
        if k.startswith("rytm-") and v >= area_lo and v not in syms:
            syms[v] = k
    keys = sorted(syms)
    return keys, syms


def fn_of(keys, syms, a):
    i = bisect.bisect_right(keys, a) - 1
    if i < 0:
        return f"?{a >> 16:x}xxxx"
    if a - keys[i] > 0x2000:
        return f"{syms[keys[i]]}+far({a >> 12:x}xxx)"
    return syms[keys[i]]


def src_frame(seq, rng):
    """The Pi's whole SRC frame for a preview: 8 rects (one per page, 16 tiles), the 16 text slots, a commit."""
    fb = bytes(rng.randrange(256) for _ in range(1024))
    m = b"".join(P.rui_rect(seq, 0, p, 16, 1, fb) for p in range(8))
    m += P.rui_text_clear(seq)
    for s in range(16):
        m += P.rui_text(seq, s, (s % 4) * 32, 2 + (s // 4) * 14, 0, 0, f"P{s:02d} {rng.randrange(128):3d}")
    return m + P.rui_commit(seq)


def setup(case):
    t0 = 100
    fp = P.plugin_fp("sophie.perc")
    ev, t = meta_events(t0, [P.meta_messages(1, 5, P.ST_READY, P.FLAG_PARAMS, "SOPHIE", "SOPH", "SOPHIE MORE", L.soph_knobs(), fp=fp)])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    t += 100
    if case.startswith("P"):                          # BD parked on list row int(case[1:]) (no browsing)
        ev1, t = walk_list(t, int(case[1:]))
        ev += ev1
    elif case not in ("D", "AD"):
        ev1, t = walk_list(t, UI["downs"]["plaits"])     # BD on PLAITS (a Sidecar machine)
        ev += ev1
    ev += [(t, "press", "SD")]
    ev2, t = walk_list(t + 100, UI["downs_sd"]["u1"])    # SD on U1 (SOPHIE)
    ev += ev2
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
    t += 400
    if case == "E":
        ev.append((t, "press", "STOP"))
        t += 200
    ev.append((t, "press", "SRC"))   # the SRC page (the view the Pi mirrors)
    return ev, t + 200


def steps(case):
    """Key sequence of the browse: ping-pong in the list (each step a preview)."""
    if case == "D":
        seq = ["DOWN"] * 6 + ["UP"] * 6
    else:                                 # from PLAITS (24): up to 6-OP FM (20), down to WAVETABLE (26), back
        seq = ["UP"] * 4 + ["DOWN"] * 6 + ["UP"] * 2
    while True:
        for k in seq:
            yield k
        if case != "D":
            seq = ["UP"] * 4 + ["DOWN"] * 6 + ["UP"] * 2


def main():
    global NOHOST
    tag, case = A[0], A[1]
    os.makedirs(OUT, exist_ok=True)
    e = Emu(tag)
    keys, syms = symtab(e)
    rt = elek_sym(e, "rytm-0026-remote-ui:rui_tick")
    cnt = {"usb_svc": 0x400050dc, "usb_irq": 0x400040ae}
    for k in ("rytm-0021-ext:ext_ui_tick", "rytm-0021-ext:ext_view_machine", "rytm-0021-ext:md_store.constprop.0", "rytm-0021-ext:md_setup",
              "rytm-0021-ext:us_tick", "rytm-0021-ext:us_commit", "rytm-0026-remote-ui:sv_tick", "rytm-0026-remote-ui:cu_prep",
              "rytm-0026-remote-ui:cu_setup", "rytm-0026-remote-ui:cu_src_setup", "rytm-0026-remote-ui:t_commit"):
        try:
            cnt[k.split(":")[1]] = elek_sym(e, k)
        except Exception as x:
            print("no symbol", k, x)
    commits_a = elek_sym(e, "rytm-0026-remote-ui:commits")
    ev, t = setup(case)
    s = e.run(f"mll-{case}-setup", t, ev, save=True)
    m = e.peek(s, MACH, 2)
    print(f"setup: BD machine {m[0]}, SD machine {m[1]}", flush=True)
    snap, clock = s, e.clock + t
    NOHOST = case in ("N", "AN")
    rng = random.Random(5)
    W = IPS
    host = case in ("B", "D", "E", "F")
    browse = case in ("B", "C", "D", "E", "N")
    nwin = 3 + (BROWSE if case != "A" else BROWSE) + TAIL
    st = steps(case)
    seq = 1
    rows = []
    prof = os.path.join(e.tmp, "p.txt")
    cum_fn = {}
    for w in range(nwin):
        phase = "pre" if w < 3 else ("browse" if w < 3 + BROWSE else "tail")
        wev = []
        for k in range(4):                  # the host's 3C, 4 a second (the tester's case: the SRC view open)
            wev.append((ms(125 + 250 * k), "usb", P.rui_keepalive()))
        if w % 5 == 0:
            wev.append((ms(500), "usb", P.slots([5, 0, 0, 0, 0], 0)))
        npre = 0
        if phase == "browse" and case not in ("A", "AN", "AD") and not case.startswith("P"):
            t_ms = 50                       # (a press at a window's first instruction is lost)
            if w == 3 and browse:
                wev += [(ms(50), "press", f"SRC:{ms(HOLD_MS)}"), (ms(400), "press", f"SRC:{ms(HOLD_MS)}")]   # SRC SRC: the machine list
                t_ms = 750
            while t_ms < 1000 - HOLD_MS - 20:
                if browse:
                    wev.append((ms(t_ms), "press", f"{next(st)}:{max(1, ms(HOLD_MS))}"))
                if host and t_ms + 120 < 1000:
                    seq += 1
                    wev.append((ms(t_ms + 120), "usb", src_frame(seq, rng)))   # the Pi's answer to the 29
                npre += 1
                t_ms += STEP_MS
            if host:
                for k in (250, 750):
                    seq += 1
                    wev.append((ms(k), "usb", P.rui_commit(seq)))
            if w == 3 + BROWSE - 1 and browse:
                wev = [x for x in wev if x[0] < ms(800)] + [(ms(850), "press", f"YES:{ms(HOLD_MS)}")]
        if NOHOST:
            wev = [x for x in wev if x[1] != "usb"]
        wev.sort(key=lambda x: x[0])
        s2 = e.run(f"mll-{case}-w{w:02d}", W, wev, count=[rt, L.MIXER] + list(cnt.values()), save=True, snap=snap, start=clock,
                   extra=["--ips", f"{IPS}M", "--profile-after", "0"], env={"DTEMU_PROFILE_DUMP": prof})
        mm = re.search(r"(\d+) instructions \((\d+) executed", e.log)
        inst, ex = (int(mm.group(1)), int(mm.group(2))) if mm else (0, 0)
        fn, ptot = {}, 0
        for line in open(prof):
            f = line.split()
            if len(f) == 2 and re.fullmatch(r"[0-9a-f]{8}", f[0]):
                k = fn_of(keys, syms, int(f[0], 16))
                fn[k] = fn.get(k, 0) + int(f[1]) * 64
                ptot += int(f[1]) * 64
        mach = e.peek(s2, MACH, 1)[0]
        row = dict(w=w, phase=phase, ui=e.counts.get(rt, 0), blocks=e.counts.get(L.MIXER, 0), load=100.0 * ex / inst if inst else 0,
                   exec_M=ex / 1e6, mach=mach, usb_out=sum(len(x) for x in e.sent), nsent=len(e.sent), previews=npre,
                   fn={k: v for k, v in fn.items() if v >= 20000}, prof_M=ptot / 1e6, unprof_M=(ex - ptot) / 1e6,
                   cnt={k: e.counts.get(a, 0) for k, a in cnt.items()}, commits=e.u32(s2, commits_a),
                   blocking=[l for l in e.log.splitlines() if "BLOCKING" in l][:5],
                   cmds={f"{m[4]:02x}": sum(1 for x in e.sent if len(x) > 5 and x[4] == m[4]) for m in e.sent if len(m) > 5},
                   cmd_bytes={f"{m[4]:02x}": sum(len(x) for x in e.sent if len(x) > 5 and x[4] == m[4]) for m in e.sent if len(m) > 5})
        rows.append(row)
        print(f"{case} w{w:02d} {phase:6s} ui {row['ui']:3d} blocks {row['blocks']:4d} load {row['load']:5.1f}% exec {row['exec_M']:6.1f}M "
              f"BD m {mach:3d} out {row['usb_out']:5d} B / {row['nsent']:3d} msgs unprof {row['unprof_M']:5.2f}M commits {row['commits']} "
              f"svc {row['cnt']['usb_svc']} evm {row['cnt'].get('ext_view_machine')} blk {len(row['blocking'])}", flush=True)
        snap, clock = s2, clock + W
    json.dump(dict(case=case, ips=IPS, step=STEP_MS, rows=rows), open(os.path.join(OUT, f"mll-{tag}-{case}-{IPS}.json"), "w"))
    print("FAILS:", U.fails if U.fails else "none")


if __name__ == "__main__" and "--report" not in sys.argv and "--pair" not in sys.argv:
    main()


def report(files):
    """--report F1 [F2..]: per file, the browse windows' mean minus the pre windows' mean, by function (M instr/s)."""
    for f in files:
        d = json.load(open(f))
        rows = d["rows"]
        def mean_fn(ph):
            rs = [r for r in rows if r["phase"] == ph]
            acc = {}
            for r in rs:
                for k, v in r["fn"].items():
                    acc[k] = acc.get(k, 0) + v / len(rs)
            return acc, len(rs)
        pre, _ = mean_fn("pre")
        br, nb = mean_fn("browse")
        ui = [r["ui"] for r in rows]
        print(f"== {os.path.basename(f)}: ui per window {ui}")
        print(f"   exec M/s pre {sum(r['exec_M'] for r in rows if r['phase'] == 'pre') / 3:.2f}  browse "
              f"{sum(r['exec_M'] for r in rows if r['phase'] == 'browse') / nb:.2f}")
        diff = {k: br.get(k, 0) - pre.get(k, 0) for k in set(pre) | set(br)}
        for k, v in sorted(diff.items(), key=lambda x: -abs(x[1]))[:25]:
            print(f"   {v / 1e6:+8.3f}  {pre.get(k, 0) / 1e6:8.3f} -> {br.get(k, 0) / 1e6:8.3f}  {k}")


def pair(fa, fb, n=25):
    """--pair A.json B.json: the full browse windows (from the second on, without the last), B minus A by function (M instr/s)."""
    ra, rb = json.load(open(fa))["rows"], json.load(open(fb))["rows"]
    idx = [r["w"] for r in rb if r["phase"] == "browse"][1:-1]
    def acc(rows):
        out = {}
        for r in rows:
            if r["w"] in idx:
                for k, v in r["fn"].items():
                    k = k if os.environ.get("MLL_FAR") else k.split("+far")[0]
                    out[k] = out.get(k, 0) + v / len(idx)
        return out
    a, b = acc(ra), acc(rb)
    ex = sum(rb[i]["exec_M"] - ra[i]["exec_M"] for i in idx) / len(idx)
    print(f"== {os.path.basename(fb)} - {os.path.basename(fa)}: windows {idx}, executed {ex:+.3f} M/s, profiled "
          f"{(sum(b.values()) - sum(a.values())) / 1e6:+.3f} M/s")
    d = {k: b.get(k, 0) - a.get(k, 0) for k in set(a) | set(b)}
    mods = sum(v for k, v in d.items() if k.startswith("rytm-"))
    print(f"   mods' area total {mods / 1e6:+.3f} M/s; OS total {(sum(d.values()) - mods) / 1e6:+.3f} M/s")
    for k, v in sorted(d.items(), key=lambda x: -abs(x[1]))[:n]:
        print(f"   {v / 1e6:+8.3f}  {a.get(k, 0) / 1e6:8.3f} -> {b.get(k, 0) / 1e6:8.3f}  {k}")


if __name__ == "__main__" and "--pair" in sys.argv:
    x = [a for a in sys.argv[1:] if a != "--pair"]
    pair(x[0], x[1])

if __name__ == "__main__" and "--report" in sys.argv:
    report([a for a in sys.argv[1:] if a != "--report"])
