#!/usr/bin/env python3
"""Knob latency under load: the table in the performance PRs (sidecar-firmware#67 / #25), rerunnable.

    RYTM_EMU=... RYTM_TEENSY=... .venv/bin/python tools/emu/knoblag.py CAND BASE [IPS] [--detents N] [--gap MS]
    e.g. (in build/os/1.74)    tools/emu/knoblag.py fix0 base0 122

CAND and BASE are build tags whose emulator bases tools/emu/us_base.sh made (rytm-emu fw/AR173_us_<tag>.syx and
sections/us_<tag>.*). The reference is "stock": this tree's stock OS (stock/Analog-Rytm_MKII_OS<os>.syx, the file you
supplied for the build), booted the way us_base.sh boots a build; knoblag makes that base on first use
(sections/us_stock.*). Stock runs with a bare USB host (the Overbridge stack up, nobody on the Sidecar link); CAND and
BASE talk to the real Sidecar core over the emulator's Overbridge link (RYTM_TEENSY: a sidecar-firmware checkout with
`make -C core engines` and `make -C core lib` done, of the version the builds belong to).

The scenario, per image, with and without scene edit, at IPS M instructions per emulated second (default 122: at the
emulator's normal 200 nothing lags; the scaled budget shows how close an image is to the edge):
  1. GRID REC, a trig on every step of all 12 tracks (16ths), GRID REC off -> a snapshot (made once per image, kept in
     build/knoblag/snaps).
  2. AMP page; with scene edit: SCNE, FUNC + SD (scene 2), PLAY, SD held 5.5 s; without: PLAY only.
  3. While it plays, knobs E (DELAY send) and F (REVERB send) turn, N detents each (--detents, default 50), a detent
     every GAP ms on each knob (--gap, default 113), the two knobs half a gap apart: all inside the 5.5 s hold. A gap that
     divides 50 ms locks the detents to the UI tick's 50 ms period, and each image's boot phase then moves its mean by
     several ms; 113 does not. (The
     PRs' first table used 100 detents every 50 ms; analog-emu's sidecar-upstream branch dispatches at most ~30
     detents a second, so that rate loses detents on every image there, stock included.)
  4. Latency of each detent: from its injection to the OS's encoder dispatch (a --count on it); the mean and the max.
     Also: CPU busy (executed / all instructions), the detents dispatched, key latency for three page presses.
Outputs: a table per mode, and the verdict of the gate the PRs used:
  FAIL when CAND's mean is more than 10 ms worse than BASE's, or more than twice stock's, or its max more than
  2x BASE's + 20 ms, or any detent was lost. (Note: on 0.5.1.1 the scene-edit mean is already > 2x stock: judge
  "BASE + 10" then.)

Everything it writes is firmware-derived and git-ignored: build/knoblag/ here, sections/us_stock.* and
fw/AR173_us_stock.syx in rytm-emu. Never commit or attach them. Addresses are 1.73's: run it in a port
(build/os/1.74 after tools/ostarget.py port 1.74), which translates them, as for every suite.
"""
import json
import os
import re
import shutil
import socket
import statistics as S
import subprocess
import sys
import tempfile
import time

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.dirname(HERE))
import ostarget   # noqa: E402

EMU = os.path.abspath(os.environ.get("RYTM_EMU", os.path.join(ROOT, "..", "rytm-emu")))
TEENSY = os.environ.get("RYTM_TEENSY", "")
WORK = os.path.join(ROOT, "build", "knoblag")
IPS = 122.0
DETENTS, GAP = 45, 113
RENDER, EVTICK, KEYD, ENCD = 0x400a2b16, 0x400a2bee, 0x400a47cc, 0x400a4816   # the engine render, the UI event tick,
TRIGS = 0x407dd8e3                     # the key and the encoder dispatch; the pattern's trig bits (917 B a track)
PADS = ["BD", "SD", "RS", "CP", "BT", "LT", "MT", "HT", "CH", "OH", "CY", "CB"]


def M(ms):
    return ms * IPS / 1000             # ms -> M instructions at IPS


def img(tag):
    j = os.path.join(EMU, "sections", f"us_{tag}.json")
    clock = json.load(open(j))["clock"] if os.path.exists(j) else 7400
    return dict(fw=f"fw/AR173_us_{tag}.syx", snap=f"sections/us_{tag}.snap", card=f"sections/us_{tag}.img", clock=clock)


def dtboot(args, log=None, env=None):
    r = subprocess.run([os.path.join(EMU, "target", "release", "dtboot")] + args, cwd=EMU, capture_output=True,
                       text=True, env=dict(os.environ, **(env or {})))
    out = r.stdout + r.stderr
    if log:
        open(log, "w").write(" ".join(args) + "\n" + out)
    if r.returncode or "FAULT" in out:
        sys.exit(f"dtboot failed ({r.returncode}): {re.findall(r'.*FAULT.*', out)[:3] or out[-1500:]}")
    return out


def peek(tag, snap, a, n):
    r = subprocess.run([os.path.join(EMU, "target", "release", "dtpeek"), snap, "mem", f"{a:x}", str(n)], cwd=EMU,
                       env=dict(os.environ, DTEMU_FW=img(tag)["fw"]), capture_output=True, text=True)
    b = bytearray()
    for line in r.stdout.splitlines():
        m = re.match(r"^[0-9a-f]+: ((?:[0-9a-f]{2} ?)+)", line)
        if m:
            b += bytes.fromhex(m.group(1).replace(" ", ""))
    return bytes(b[:n])


def stock_base():
    """sections/us_stock.*: the stock OS booted as us_base.sh boots a build (fresh card, the startup dialogs answered,
    TRANSPORT SEND on and USB CONFIG = OVERBRIDGE where they are off)."""
    i = img("stock")
    if os.path.exists(os.path.join(EMU, i["snap"])):
        return
    osv = ostarget.tree_os()
    src = os.path.join(ROOT, "stock", f"Analog-Rytm_MKII_OS{osv}.syx")
    if not os.path.exists(src):
        sys.exit(f"no {src}: put your stock OS there (as for the build)")
    print(f"making the stock base from {os.path.basename(src)} ...", flush=True)
    shutil.copy(src, os.path.join(EMU, i["fw"]))
    subprocess.run(["cp", "-c", "sections/led.img", i["card"]], cwd=EMU, check=True)   # an APFS clone where possible
    tmp = tempfile.mkdtemp(prefix="knoblag-")
    cold = os.path.join(tmp, "cold.snap")
    dtboot([i["fw"], "--instr", "4400M", "--every", "4400M", "--card", i["card"], "--press", "YES@2600M",
            "--press", "NO@3000M", "--press", "NO@3400M", "--press", "NO@3800M", "--save", cold])
    ts, usb = peek("stock", cold, 0x407c2d32, 1), peek("stock", cold, 0x405c8e4c, 1)
    keys = "GLOBAL DOWN DOWN DOWN YES YES DOWN DOWN DOWN".split() + ([] if ts == b"\x01" else ["YES"]) + ["NO", "NO"]
    keys += "DOWN DOWN DOWN DOWN YES DOWN YES".split() + ([] if usb == b"\x01" else ["YES"]) + ["NO", "NO", "NO"]
    a, t = [], 4500
    for k in keys:
        a += ["--press", f"{k}@{t}M"]
        t += 100
    end = t + 600
    dtboot([i["fw"], "--load", cold, "--card", i["card"], "--instr", f"{end - 4400}M", "--every", "100000M",
            "--save", i["snap"]] + a)
    json.dump({"clock": end}, open(os.path.join(EMU, "sections", "us_stock.json"), "w"))
    shutil.rmtree(tmp)


def evargs(clock, events):
    a = []
    for e in events:
        at = f"{clock + M(e[0]):g}M"
        if e[1] == "press":
            a += ["--press", f"{e[2]}@{at}" + (f":{M(e[3]):g}M" if len(e) > 3 else "")]
        elif e[1] == "turn":
            a += ["--turn", f"{e[2]}@{at}x{e[3]}/{M(e[4]):g}M"]
    return a


def program(tag):
    """GRID REC, every step of the 12 tracks, GRID REC off -> build/knoblag/snaps/<tag>.snap (once)."""
    out = os.path.join(WORK, "snaps", f"{tag}.snap")
    if os.path.exists(out):
        return json.load(open(out[:-5] + ".json"))["clock"]
    os.makedirs(os.path.dirname(out), exist_ok=True)
    i = img(tag)
    d = peek(tag, i["snap"], TRIGS, 917 * 12)
    have = [[int.from_bytes(d[917 * k + 2 * s:917 * k + 2 * s + 2], "big") & 1 for s in range(16)] for k in range(12)]
    ev, t = [(300, "press", "RECORD")], 600
    for k, p in enumerate(PADS):
        ev += [(t, "press", "TRK", 150), (t + 50, "press", p, 40)]
        t += 300
        for s in range(16):
            if not have[k][s]:
                ev.append((t, "press", f"T{s + 1}", 25))
                t += 60
        t += 100
    ev.append((t, "press", "RECORD"))
    t += 500
    print(f"programming 12 tracks on {tag} ...", flush=True)
    save_ips = IPS
    globals()["IPS"] = 200.0           # (programmed at the normal budget: the same snapshot for every IPS)
    dtboot([i["fw"], "--load", i["snap"], "--card", i["card"], "--instr", f"{M(t):g}M", "--every", "20M",
            "--save", out, "--ips", "200M"] + evargs(i["clock"], ev), log=out[:-5] + ".log")
    clock = i["clock"] + M(t)
    globals()["IPS"] = save_ips
    json.dump({"clock": clock}, open(out[:-5] + ".json", "w"))
    return clock


def host(port, name):
    """The real Sidecar core as the host on the Overbridge link (RYTM_TEENSY's sim/rui_link)."""
    card = tempfile.mkdtemp(prefix="knoblag-card-")
    os.makedirs(os.path.join(card, "Samples"))
    code = ("import sys; sys.path.insert(0, sys.argv[1]); import rui_link as R; h = R.Host(sys.argv[2], sys.argv[3], None);"
            " print('rui_link: ready', flush=True); R.serve(h, '127.0.0.1:' + sys.argv[4], 1800, None)")
    log = os.path.join(WORK, "runs", f"{name}.host.log")
    p = subprocess.Popen([sys.executable, "-c", code, os.path.join(TEENSY, "sim"), card,
                          os.path.join(WORK, "runs", f"{name}.jsonl"), str(port)], stdout=open(log, "w"),
                         stderr=subprocess.STDOUT, env=dict(os.environ, FWS=TEENSY, RUI_SEQ_TICK="1", RUI_EMU_CLOCK="1"))
    for _ in range(600):
        if "ready" in open(log).read():
            break
        time.sleep(0.1)
    return p


def times(rows, addr):
    t, last = [], None
    for x, cs in rows:
        v = cs.get(addr, 0)
        if last is not None and v > last:
            t += [x] * (v - last)
        last = v
    return t


def scene(tag, linked, noscene):
    """One run: the scenario above on tag's programmed snapshot -> its numbers."""
    clock = program(tag)
    i = img(tag)
    name = f"{tag}-i{IPS:g}-d{DETENTS}g{GAP}" + ("-noscene" if noscene else "")
    os.makedirs(os.path.join(WORK, "runs"), exist_ok=True)
    ev = [(1000, "press", "AMP", 40)]
    if not noscene:
        ev += [(1400, "press", "SCNE", 40), (1450, "press", "FUNC", 150), (1500, "press", "SD", 40)]
    ev += [(2000, "press", "PLAY", 40)]
    if not noscene:
        ev += [(4000, "press", "SD", 5500)]
    turns = []
    for k in range(DETENTS):
        turns += [4100 + GAP * k, 4100 + GAP // 2 + GAP * k]
    ev += [(4100, "turn", "4:+1", DETENTS, GAP), (4100 + GAP // 2, "turn", "5:-1", DETENTS, GAP)]
    presses = [(9800, 60), (10100, 60), (10400, 60)]
    ev += [(t, "press", k, 60) for (t, _), k in zip(presses, ["FLTR", "AMP", "LFO"])]
    h, link = None, []
    if linked:
        s = socket.socket()
        s.bind(("127.0.0.1", 0))
        port = s.getsockname()[1]
        s.close()
        h = host(port, name)
        link = ["--ob-link", f"127.0.0.1:{port}"]
    every = f"{0.002 * IPS:g}M"        # a row every 2 ms
    args = [i["fw"], "--load", os.path.join(WORK, "snaps", f"{tag}.snap"), "--card", i["card"],
            "--instr", f"{M(11500):g}M", "--every", every, "--usb-host", "--usb-midi-real", *link,
            *evargs(clock, ev), "--ips", f"{IPS:g}M"]
    for a in (RENDER, EVTICK, KEYD, ENCD):
        args += ["--count", f"{a:x}"]
    out = dtboot(args, log=os.path.join(WORK, "runs", f"{name}.dt.txt"))
    if h:
        try:
            h.wait(timeout=60)
        except subprocess.TimeoutExpired:
            h.kill()
    rows = []
    for m in re.finditer(r"^\s*([\d.]+)M pc=\S+ .*?$", out, re.M):
        cs = dict((int(a, 16), int(n)) for a, n in re.findall(r"([0-9a-f]{8}):(\d+)", m.group(0)))
        rows.append(((float(m.group(1)) - clock) * 1000 / IPS, cs))
    ed = [x for x in times(rows, ENCD) if x >= 4000]
    lat, j = [], 0
    for t in turns:
        while j < len(ed) and ed[j] < t - 3:
            j += 1
        if j < len(ed):
            lat.append(ed[j] - t)
            j += 1
    kd = times(rows, KEYD)
    klat, j = [], 0
    for t in sorted(p for t0, hd in presses for p in (t0, t0 + hd)):
        while j < len(kd) and kd[j] < t - 3:
            j += 1
        if j < len(kd):
            klat.append(kd[j] - t)
            j += 1
    m = re.search(r"(\d+) instructions \((\d+) executed, (\d+) idle-skipped\)", out)
    return dict(busy=round(int(m.group(2)) / int(m.group(1)), 4) if m else None, injected=len(turns),
                dispatched=len(ed), mean=round(S.mean(lat), 1) if lat else None, max=round(max(lat)) if lat else None,
                key_mean=round(S.mean(klat), 1) if klat else None)


def main():
    global IPS, DETENTS, GAP
    a = sys.argv[1:]
    for opt in ("--detents", "--gap"):
        if opt in a:
            i = a.index(opt)
            v = int(a[i + 1])
            del a[i:i + 2]
            if opt == "--detents":
                DETENTS = v
            else:
                GAP = v
    if len(a) < 2:
        sys.exit(__doc__)
    cand, base = a[:2]
    IPS = float(a[2]) if len(a) > 2 else 122.0
    if not TEENSY:
        sys.exit("set RYTM_TEENSY to a sidecar-firmware checkout (core lib built)")
    stock_base()
    res = {}
    for noscene in (False, True):
        for tag, linked in (("stock", False), (base, True), (cand, True)):
            r = res[(tag, noscene)] = scene(tag, linked, noscene)
            print(f"{tag:>10} {'no scene' if noscene else 'scene':>8}: knob {r['mean']} / {r['max']} ms  busy {r['busy']}"
                  f"  dispatched {r['dispatched']}/{r['injected']}  keys {r['key_mean']} ms", flush=True)
    bad = []
    for noscene in (False, True):
        mode = "no scene" if noscene else "scene"
        s, b, c = (res[(t, noscene)] for t in ("stock", base, cand))
        if c["mean"] is None or c["dispatched"] < c["injected"]:
            bad.append(f"{mode}: knob turns lost ({c['dispatched']}/{c['injected']})")
            continue
        if c["mean"] > b["mean"] + 10:
            bad.append(f"{mode}: mean {c['mean']} ms > {base} {b['mean']} + 10")
        if c["mean"] > 2 * s["mean"]:
            bad.append(f"{mode}: mean {c['mean']} ms > 2x stock {s['mean']}")
        if c["max"] > 2 * b["max"] + 20:
            bad.append(f"{mode}: max {c['max']} ms > 2x {base} {b['max']} + 20")
    json.dump({f"{t}{'-noscene' if n else ''}": r for (t, n), r in res.items()},
              open(os.path.join(WORK, "runs", f"knoblag-{cand}-vs-{base}-i{IPS:g}-d{DETENTS}g{GAP}.json"), "w"), indent=1)
    print(f"\n| image | scene edit, mean / max ms | no scene edit, mean / max ms |\n|---|---|---|")
    for tag in ("stock", base, cand):
        a, b = res[(tag, False)], res[(tag, True)]
        print(f"| {tag} | {a['mean']} / {a['max']} | {b['mean']} / {b['max']} |")
    print("\nKNOBLAG " + ("FAIL\n  " + "\n  ".join(bad) if bad else "PASS"))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
