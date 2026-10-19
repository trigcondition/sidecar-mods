#!/usr/bin/env python3
"""tools/emu/el_area.py FW.syx FREE_LO [--blob-check TAG] - is elekloader's DDR area left alone?

Two runs in rytm-emu (DTEMU_STRICT=1), on a scratch copy of sections/led.img:
  1. a cold boot of FW, the startup dialogs answered, then a busy session: trigs recorded on
     BD (RECORD + T1/T5/T9/T13) and played, DIN MIDI notes and CCs, the USB host attached
     (--usb-host --usb-midi-real), a pattern switch, KIT SAVE and KIT RELOAD, the pads,
     STOP, and a power off (the firmware saves its working state to the card);
  2. a cold boot on that card (the saved state loaded), the dialogs, PLAY 5 s, STOP.
Before each run the free part of the area, FREE_LO..0x47C00000, gets a canary word every
32 bytes (--poke, address ^ 0xC0DEF00D, as elekloader's hardware canary) and a read/write
watch (--watch-read: every CPU access, cached or through the uncached alias; dtboot turns
the JIT off while a watch is set). After each run: no watch hit, every canary word intact,
no strict access, no FAULT. --blob-check TAG also compares the run image in the area with
what rytm-mods' build/manifest_TAG.json says elekloader appended (only the words the mods
own may differ) and prints 0028-elek-hello's counters if present.
RYTM_EMU: rytm-emu's checkout (default ../rytm-emu (a sibling checkout))."""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

EMU = os.environ.get("RYTM_EMU", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "rytm-emu"))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
AREA_HI = 0x47C00000
STEP = 32
fails = []


def check(what, ok, detail=""):
    print(("ok   " if ok else "FAIL ") + what + (f" - {detail}" if detail and not ok else ""))
    if not ok:
        fails.append(what)


def dtboot(fw, card, length, presses, extra, save):
    cmd = [os.path.join(EMU, "target/release/dtboot"), fw, "--card", card, "--card-save",
           "--instr", f"{length}M", "--every", f"{length}M"] + (["--save", save] if save else []) + extra
    for k, t in presses:
        k, _, hold = k.partition(":")
        cmd += ["--press", f"{k}@{t}M" + (f":{hold}" if hold else "")]
    r = subprocess.run(cmd, cwd=EMU, env=dict(os.environ, DTEMU_STRICT="1"),
                       capture_output=True, text=True)
    return r.returncode, r.stdout + r.stderr


def peek(fw, snap, addr, n):
    r = subprocess.run([os.path.join(EMU, "target/release/dtpeek"), snap, "mem", f"{addr:x}", str(n)],
                       cwd=EMU, env=dict(os.environ, DTEMU_FW=fw), capture_output=True, text=True, check=True)
    return bytes(int(x, 16) for line in r.stdout.splitlines() for x in line.split(":", 1)[1].split())


def main():
    fw = os.path.abspath(sys.argv[1])
    free_lo = (int(sys.argv[2], 16) + STEP - 1) // STEP * STEP
    tag = sys.argv[sys.argv.index("--blob-check") + 1] if "--blob-check" in sys.argv else None
    tmp = tempfile.mkdtemp()
    card = os.path.join(tmp, "card.img")
    shutil.copy(os.path.join(EMU, "sections/led.img"), card)
    canary = [(a, (a ^ 0xC0DEF00D) & 0xFFFFFFFF) for a in range(free_lo, AREA_HI, STEP)]
    pokes = [x for a, v in canary for x in ("--poke", f"{a:x}={v:x}")]
    watch = ["--watch-read", f"{free_lo:x}", str(AREA_HI - free_lo)]
    dialogs = [("YES", 2600), ("NO", 3000), ("NO", 3400), ("NO", 3800)]

    def kit_menu(at, downs):
        ev = [("FUNC:300M", at), ("PLAYMODE", at + 20)]
        t = at + 400
        for k in ["UP"] * 3 + ["DOWN"] * downs + ["YES"]:
            ev.append((k, t))
            t += 100
        return ev, t

    # run 1: the busy session
    p = list(dialogs)
    t = 4500
    for k in ["RECORD", "T1", "T5", "T9", "T13", "RECORD"]:
        p.append((k, t))
        t += 100
    p.append(("PLAY", t))
    t += 300
    for k in ["BD", "SD", "RS", "CP", "BD", "SD"]:
        p.append((k, t))
        t += 60
    ev, t = kit_menu(t + 200, 2)          # SAVE KIT: the kit list, its name, YES saves
    p += ev + [("YES", t + 200), ("YES", t + 400)]
    ev, t = kit_menu(t + 1000, 0)         # RELOAD KIT
    p += ev + [("YES", t + 200)]
    t += 800
    p += [("PTN", t), ("T2", t + 20)]      # the next pattern (switches at the pattern's end)
    t += 1500
    p.append(("STOP", t))
    end1 = t + 600
    midi = []
    for i in range(80):                    # DIN: notes on channel 1 and a CC sweep
        at = 4600 + 60 * i
        midi += ["--midi", f"90{0x24 + i % 12:02x}64@{at}M", "--midi", f"80{0x24 + i % 12:02x}00@{at + 20}M",
                 "--midi", f"b04a{i % 128:02x}@{at + 30}M"]
    extra1 = pokes + watch + midi + ["--usb-host", "--usb-midi-real"]
    s1 = os.path.join(tmp, "s1.snap")
    rc, log = dtboot(fw, card, end1, p, extra1, s1)
    report(fw, "run 1 (busy session)", rc, log, s1, canary, tag)
    # run 1b: from there, the power off (the firmware writes its working state to the card)
    rc, log = dtboot(fw, card, 300, [], ["--load", s1] + watch + ["--power-off", f"{end1 + 100}M"], None)
    report(fw, "run 1b (power off, state saved to the card)", rc, log, None, canary, tag)
    # run 2: a cold boot on the saved card
    p2 = list(dialogs) + [("PLAY", 4500), ("STOP", 5500)]
    s2 = os.path.join(tmp, "s2.snap")
    rc, log = dtboot(fw, card, 6000, p2, pokes + watch + ["--usb-host"], s2)
    report(fw, "run 2 (cold boot on the saved card, play)", rc, log, s2, canary, tag)
    shutil.rmtree(tmp, ignore_errors=True)
    print("PASS" if not fails else "FAIL: " + ", ".join(fails))
    return 1 if fails else 0


def report(fw, name, rc, log, snap, canary, tag):
    check(f"{name}: runs without a fault", rc == 0 and "FAULT" not in log, log[-300:])
    bad = [l for l in log.splitlines() if l.startswith("strict:")]
    check(f"{name}: no strict access", not bad, "; ".join(bad[:3]))
    hits = [l for l in log.splitlines() if l.startswith("watch:")]
    check(f"{name}: no CPU access to the free part of the area", not hits, "; ".join(hits[:4]))
    if snap is None or not os.path.exists(snap):
        return
    lo, hi = canary[0][0], AREA_HI
    mem = peek(fw, snap, lo, hi - lo)
    broken = [a for a, v in canary if int.from_bytes(mem[a - lo:a - lo + 4], "big") != v]
    check(f"{name}: {len(canary)} canary words intact", not broken,
          f"{len(broken)} changed, first 0x{broken[0]:08x}" if broken else "")
    if tag:
        man = json.load(open(os.path.join(ROOT, "build", f"manifest_{tag}.json")))
        lay = man["elek"]["layout"]
        base = 0x40000400
        img = open(os.path.join(ROOT, "build", f"mainos_{tag}.bin"), "rb").read()
        r0, n = lay["ddr"][0], lay["ddr"][1] - lay["ddr"][0]
        want = img[lay["run_load"] - base:lay["run_load"] - base + n]
        got = peek(fw, snap, r0, n)
        diff = [r0 + i for i in range(0, n, 4) if got[i:i + 4] != want[i:i + 4]]
        syms = man["elek"]["symbols"]
        secs = sorted(lay["sections"].items(), key=lambda kv: kv[1])
        core_run = lay["sections"]["core .run"]
        core_end = min(v for k, v in secs if v > core_run)
        in_core = [a for a in diff if core_run <= a < core_end]
        check(f"{name}: core's code in the area is what elekloader appended", not in_core,
              " ".join(f"0x{a:08x}" for a in in_core[:8]))
        if diff:
            print(f"     words changed at run time (the mods' own state): "
                  + " ".join(f"0x{a:08x}" for a in diff[:12]))
        magic = next((v for k, v in syms.items() if k.endswith(":eh_magic")), None)
        if magic:
            w = peek(fw, snap, magic, 12)
            print(f"     0028: magic {w[:4]!r}, eh_ticks {int.from_bytes(w[4:8], 'big')}, "
                  f"eh_loops {int.from_bytes(w[8:12], 'big')}")


if __name__ == "__main__":
    sys.exit(main())
