#!/usr/bin/env python3
"""Emulator tests of 0026's machine reports (1025): F0 7D 52 54 33 01 <t0> <n> {<machine> <vb>} x n F7 to the USB
host when a track's machine changes, and the snapshot (t0 0, n 12) when the page opens and with each hello.

    .venv/bin/python tools/emu/mrep_emu.py TAG TEST [TEST ...]     exit 0 when every check passes
    .venv/bin/python tools/emu/mrep_emu.py TAG all

TAG: a build with 0021-ext (slots=1) and 0026-remote-ui, its base made by tools/emu/us_base.sh TAG. Every run under
DTEMU_STRICT=1 with a simulated USB host (--usb-host --usb-midi-real); the Rytm's USB MIDI from DTBOOT_USB_OUT. Key
walks from tools/emu/us_ui.json (the machine list: SRC SRC, DOWNs, YES; JUNO 21 DOWNs from BD's machine on the base).
One UI tick is 10 M instructions (20 Hz at 200 M/s). RYTM_EMU: rytm-emu's checkout.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EMU = os.environ.get("RYTM_EMU", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "rytm-emu"))
UI = json.load(open(os.path.join(ROOT, "tools", "emu", "us_ui.json")))
JUNO, PLAITS = 41, 44
FAILS = []


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"   [{detail}]" if detail else ""), flush=True)
    if not ok:
        FAILS.append(name)


def sysex(b):
    return [m.group(0) for m in re.finditer(rb"\xf0[^\xf0\xf7]*\xf7", b)]


def mreports(msgs):
    """The 33s: [(t0, [(machine, vb), ...])]."""
    r = []
    for m in msgs:
        if m[:6] == b"\xf0\x7d\x52\x54\x33\x01" and len(m) >= 9:
            t0, n = m[6], m[7]
            pairs = [(m[8 + 2 * i], m[9 + 2 * i]) for i in range(n)]
            r.append((t0, pairs))
    return r


class Emu:
    def __init__(self, tag):
        self.tag = tag
        self.fw = f"fw/AR173_us_{tag}.syx"
        self.card = os.path.join(EMU, f"sections/us_{tag}.img")
        self.snap = f"sections/us_{tag}.snap"
        self.clock = json.load(open(os.path.join(EMU, f"sections/us_{tag}.json")))["clock"]
        self.out = os.path.join(ROOT, "build", "emu", tag)
        os.makedirs(self.out, exist_ok=True)
        self.tmp = tempfile.mkdtemp()

    def run(self, name, length, events=(), cold=False, card=None, extra=(), snap=None, usb=True):
        start = 0 if cold else self.clock if snap is None else snap[1]
        cmd = ["./target/release/dtboot", self.fw] + ([] if cold else ["--load", (snap or (self.snap,))[0]]) + \
              ["--card", card or self.card, "--instr", f"{length}M", "--every", f"{length}M",
               *(["--usb-host", "--usb-midi-real"] if usb else []), *extra]
        for at, kind, val in events:
            k, _, hold = val.partition(":")
            cmd += ["--press", f"{k}@{start + at}M" + (f":{hold}" if hold else "")]
        out = os.path.join(self.tmp, f"{name}.usb")
        env = dict(os.environ, DTEMU_STRICT="1", DTBOOT_USB_OUT=out,
                   DTBOOT_END_PNG=os.path.join(self.out, f"mrep_{name}.png"))
        r = subprocess.run(cmd, cwd=EMU, env=env, capture_output=True, text=True)
        log = r.stdout + r.stderr
        open(os.path.join(self.out, f"mrep_{name}.dt.txt"), "w").write(log)
        bad = r.returncode != 0 or "FAULT" in log or "strict:" in log
        check(f"{name}: dtboot ran clean (strict, no fault)", not bad,
              "" if not bad else str(re.findall(r".*(?:FAULT|strict:).*", log)[:3] or f"rc {r.returncode}"))
        self.msgs = sysex(open(out, "rb").read()) if os.path.exists(out) else []
        self.rep = mreports(self.msgs)
        return r


def walk(at, keys):
    ev, t = [], at
    for k in keys:
        ev.append((t, "press", k))
        t += UI["step_M"]
    return ev, t - UI["step_M"]   # t: the last press


def bd_reports(rep):
    """BD's (machine, vb) in each report that names track 0, in order."""
    return [p[0] for t0, p in rep if t0 == 0]


def t_portup(e):
    """From the base (the port comes up as the host attaches): a hello (35), then the snapshot of the 12 tracks, all
    analog (vb 7F) on the base's project, no other 33."""
    e.run("portup", 400)
    snaps = [p for t0, p in e.rep if t0 == 0 and len(p) == 12]
    hello = [i for i, m in enumerate(e.msgs) if m[4:5] == b"\x35"]
    first = next((i for i, m in enumerate(e.msgs) if m[4:6] == b"\x33\x01"), None)
    print(f"  33s: {e.rep}")
    check("portup: a snapshot (t0 0, n 12) after the hello", bool(snaps) and hello and first is not None and first > hello[0])
    check("portup: every track analog on the base (vb 7F)", bool(snaps) and all(vb == 0x7f for _, vb in snaps[0]),
          str(snaps[0] if snaps else None))
    check("portup: only snapshots, nothing per track (no machine moved)", all(len(p) == 12 for _, p in e.rep))


def t_juno(e):
    """JUNO picked on BD's SRC list: a 33 for BD with machine 41, vb 0x08 (voice 0 | JUNO's flag) within about one UI
    tick of the cursor reaching it, no trig; YES; then BD trigged: its 0x04 carries the same voice byte."""
    keys = UI["list_open"] + ["DOWN"] * UI["downs"]["juno"]
    ev, last = walk(100, keys)
    for slack in (12, 25):
        e.run(f"juno+{slack}", last + slack, ev)
        bd = bd_reports(e.rep)
        trig = [m for m in e.msgs if m[4:5] == b"\x04"]
        print(f"  +{slack}M: BD's reports {bd[-4:]} ({len(bd)} in all)")
        if bd and bd[-1] == (JUNO, 0x08):
            break
    check(f"juno: BD now JUNO (41, vb 08) within {slack} M of the last DOWN (one tick = 10 M), as its own 33 (n 1)",
          bool(bd) and bd[-1] == (JUNO, 0x08) and any(t0 == 0 and len(p) == 1 for t0, p in e.rep), str(bd[-3:]))
    check("juno: no trig report (no trig)", not trig)
    ev2 = ev + [(last + 100, "press", UI["list_confirm"]), (last + 300, "press", "BD")]
    e.run("juno-trig", last + 500, ev2)
    trig = [m for m in e.msgs if m[4:5] == b"\x04"]
    check("juno: BD's 0x04 after YES carries vb 08, the 33's", bool(trig) and trig[-1][5] == 0x08,
          trig[-1][:8].hex() if trig else "none")


def t_analog(e):
    """JUNO chosen (YES), then the list again and up to an analog machine (YES): BD's last 33 is vb 7F, machine < 35."""
    keys = UI["list_open"] + ["DOWN"] * UI["downs"]["juno"] + [UI["list_confirm"]] + UI["list_open"] + ["UP"] * 8 + \
        [UI["list_confirm"]]
    ev, last = walk(100, keys)
    e.run("analog", last + 25, ev)
    bd = bd_reports(e.rep)
    print(f"  BD's reports: {bd}")
    check("analog: BD was JUNO (41, 08) on the way", (JUNO, 0x08) in bd)
    check("analog: BD's last 33 says no Sidecar machine (vb 7F)", bool(bd) and bd[-1][1] == 0x7f and bd[-1][0] < 35,
          str(bd[-1] if bd else None))


def t_open(e):
    """TRK + YES opens the page: 30 1 0 1 0, then the snapshot."""
    e.run("open", 300, [(100, "press", "TRK:60M"), (130, "press", "YES")])
    i30 = next((i for i, m in enumerate(e.msgs) if m[4:6] == b"\x30\x01" and len(m) > 7 and m[7] == 1), None)
    after = [m for m in e.msgs[i30 + 1:]] if i30 is not None else []
    snaps = [p for t0, p in mreports(after) if t0 == 0 and len(p) == 12]
    print(f"  30 at {i30}; 33s after it: {len(snaps)}")
    check("open: the page opened (30 ... on 1)", i30 is not None)
    check("open: a snapshot of all 12 tracks after the 30", bool(snaps))


def t_kit(e):
    """Pattern A02 (kit 1, BD machine 28): BD's 33 says 28 (a snapshot if more than one track moved)."""
    e.run("kit", 600, [(50, "press", "BANK_A:300M"), (150, "press", "T2")])
    bd = bd_reports(e.rep)
    print(f"  33s: {[(t0, len(p)) for t0, p in e.rep]}; BD's: {bd}")
    check("kit: BD's last 33 says machine 28, analog", bool(bd) and bd[-1] == (28, 0x7f), str(bd[-1] if bd else None))


def t_project(e):
    """JUNO chosen on BD, the power goes (the working state to the card), a cold boot on that card (the project
    load): the snapshot after the port comes up has BD = JUNO (41, 08)."""
    c = os.path.join(e.tmp, "project.img")
    shutil.copy(e.card, c)
    keys = UI["list_open"] + ["DOWN"] * UI["downs"]["juno"] + [UI["list_confirm"]]
    ev, last = walk(100, keys)
    e.run("project-before", last + 1100, ev, card=c, extra=["--power-off", f"{e.clock + last + 1000}M"])
    # the cold boot loads the project from the card; rytm-emu's simulated host does not enumerate a cold-booted
    # Rytm, so the host attaches on a snapshot after the boot (as on the base): the port comes up, the hello, the snapshot
    after = os.path.join(e.tmp, "project-after.snap")
    e.run("project-boot", 4400, cold=True, card=c, usb=False, extra=["--save", after])
    e.run("project-after", 400, card=c, snap=(after, 4400))
    snaps = [p for t0, p in e.rep if t0 == 0 and len(p) == 12]
    print(f"  snapshots: {len(snaps)}; BD in the first: {snaps[0][0] if snaps else None}")
    check("project: after the cold boot the snapshot has BD = JUNO (41, 08)", bool(snaps) and snaps[0][0] == (JUNO, 0x08))


TESTS = {"portup": t_portup, "juno": t_juno, "analog": t_analog, "open": t_open, "kit": t_kit, "project": t_project}


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    tag, names = sys.argv[1], sys.argv[2:]
    if names == ["all"]:
        names = list(TESTS)
    e = Emu(tag)
    for n in names:
        print(f"{n}:", flush=True)
        TESTS[n](e)
    shutil.rmtree(e.tmp, True)
    print(f"{'ALL PASS' if not FAILS else f'{len(FAILS)} FAILED: ' + ', '.join(FAILS)}")
    sys.exit(1 if FAILS else 0)


if __name__ == "__main__":
    main()
