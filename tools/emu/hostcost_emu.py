#!/usr/bin/env python3
"""F4 follow-up (a tester: unplugging the Pi's USB cures the lag): where the Rytm's instructions go with no host, a quiet host and
a streaming host.

    RYTM_EMU=... RYTM_TEENSY=... .venv/bin/python tools/emu/hostcost_emu.py TAG [--secs N]

Cases (each: a setup run to a snapshot, then one N-second profile window with --profile-after 0; the same knob turns and page switches in all):
  N   no host: stock machines, a pattern playing, dtboot without --usb-host (an unplugged USB cable)
  Q   quiet host: the same, --usb-host --usb-midi-real (enumerated, MIDI port open), no traffic from it
  S1  streaming (MIDI): BD PLAITS + SD U1 (SOPHIE-like) from the host's 1A, the host's keepalives / slot generations / remote-UI mirror frames
  S2  S1 plus --ob-link with rytm-teensy sim/remote_ui.py as the host (the Overbridge input stream and its frame requests)
Prints, per case, the executed instructions per emulated second by function (nearest preceding symbol: the OS map of the build
and the mods' area symbols) and the differences Q-N, S1-Q, S2-S1.
"""
import bisect
import json
import os
import random
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lag_emu as L   # noqa: E402
import soak_emu as S  # noqa: E402
import keytime_emu as K   # noqa: E402
import us_emu as U    # noqa: E402
from us_emu import Emu, elek_sym   # noqa: E402

NOHOST = False
_orig = subprocess.run


def _patched(cmd, **kw):
    if NOHOST and isinstance(cmd, list) and cmd and "dtboot" in str(cmd[0]):
        cmd = [c for c in cmd if c not in ("--usb-host", "--usb-midi-real")]
    return _orig(cmd, **kw)


subprocess.run = _patched


def symtab(e, tag_dir):
    syms = {}
    mp = json.load(open(os.path.join(tag_dir, "Analog-Rytm_MKII_OS1.74_lag0.syx.map.json")))
    for k, v in mp.items():
        if isinstance(v, str):
            v = int(v, 16)
        if ":" not in k and isinstance(v, int) and v < 0x47be0000:
            syms[v] = k
    for k, v in json.load(open(os.path.join(e.out, "manifest.json")))["elek"]["symbols"].items():
        if k.startswith("rytm-") and v >= 0x47be0000 and v not in syms:
            syms[v] = k
    keys = sorted(syms)
    return keys, syms


def fn_of(keys, syms, a):
    i = bisect.bisect_right(keys, a) - 1
    return syms[keys[i]] + (f"+{a - keys[i]:#x}" if a - keys[i] > 0x400 else "") if i >= 0 else f"?{a:x}"


def profile(e, snap, clock, ev, secs, name, ob=False):
    prof = os.path.join(e.tmp, f"{name}.prof")
    rt = elek_sym(e, "rytm-0026-remote-ui:rui_tick")
    extra = ["--profile-after", "0"]
    sp = None
    if ob:
        import socket
        so = socket.socket()
        so.bind(("127.0.0.1", 0))
        port = so.getsockname()[1]
        so.close()
        extra += ["--ob-link", f"127.0.0.1:{port}"]
        sp = subprocess.Popen([sys.executable, os.path.join(U.TEENSY, "sim/remote_ui.py"), "--link", f"127.0.0.1:{port}", "--secs", "600",
                               "--open"], stdout=open(os.path.join(e.tmp, f"{name}.script.txt"), "w"), stderr=subprocess.STDOUT)
    e.run(name, secs * 200, ev, snap=snap, start=clock, count=[rt, L.MIXER], extra=extra, env={"DTEMU_PROFILE_DUMP": prof})
    if sp:
        try:
            sp.wait(timeout=20)
        except subprocess.TimeoutExpired:
            sp.kill()
    m = re.search(r"(\d+) instructions \((\d+) executed", e.log)
    blocks = {}
    for line in open(prof):
        f = line.split()
        if len(f) == 2 and re.fullmatch(r"[0-9a-f]{8}", f[0]):
            blocks[int(f[0], 16)] = int(f[1])
    return dict(blocks=blocks, executed=int(m.group(2)), clock=int(m.group(1)), ui=e.counts.get(rt, 0), mix=e.counts.get(L.MIXER, 0),
                usb_out=sum(len(x) for x in e.sent))


def by_fn(p, keys, syms, secs):
    out = {}
    for a, n in p["blocks"].items():
        f = fn_of(keys, syms, a).split("+")[0]
        out[f] = out.get(f, 0) + n / secs
    return out


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    global NOHOST
    tag = a[0]
    secs = int(a[a.index("--secs") + 1]) if "--secs" in a else 5
    e = Emu(tag)
    keys, syms = symtab(e, os.path.join(U.ROOT, "build"))
    res = {}
    for case in ("N", "Q", "S1", "S2"):
        NOHOST = case == "N"
        sc = case.startswith("S")
        ev, t = L.setup_events(100) if sc else K.stock_setup()
        s = e.run(f"hc-{case}-setup", t, ev, save=True)
        rng = random.Random(9)
        pev = S.window_events(3, secs, rng)
        pev = [x for x in pev if sc or x[1] != "usb"]
        if case == "S2":
            pev = [x for x in pev if not (x[1] == "usb" and False)]
        res[case] = profile(e, s, e.clock + t, pev, secs, f"hc-{case}", ob=(case == "S2"))
        p = res[case]
        print(f"{case}: executed {p['executed'] / 1e6 / secs:.1f} M/s of 200 ({100 * p['executed'] / p['clock']:.1f}%), ui {p['ui'] / secs:.1f}/s, "
              f"blocks {p['mix'] / secs:.0f}/s, Rytm USB out {p['usb_out'] / secs:.0f} B/s", flush=True)
    fns = {c: by_fn(res[c], keys, syms, secs) for c in res}
    json.dump({c: {k: round(v) for k, v in fns[c].items()} for c in fns}, open(os.path.join(e.out, "hostcost.json"), "w"), indent=0)
    for c in ("N", "Q", "S1", "S2"):
        print(f"\n== top functions, case {c} (instructions/s)")
        for k, v in sorted(fns[c].items(), key=lambda x: -x[1])[:22]:
            print(f"  {v:12.0f}  {k}")
    for a_, b_ in (("N", "Q"), ("Q", "S1"), ("S1", "S2")):
        d = {k: fns[b_].get(k, 0) - fns[a_].get(k, 0) for k in set(fns[a_]) | set(fns[b_])}
        print(f"\n== biggest differences {b_} - {a_} (instructions/s)")
        for k, v in sorted(d.items(), key=lambda x: -abs(x[1]))[:22]:
            print(f"  {v:+12.0f}  {k}")
    print("DONE", "FAILED: " + "; ".join(U.fails) if U.fails else "no fault")


if __name__ == "__main__":
    main()
