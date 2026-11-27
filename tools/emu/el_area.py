#!/usr/bin/env python3
"""tools/emu/el_area.py FW.syx FREE_LO --blob-check TAG - is elekloader's DDR area, and the bundle's region, left alone?

Two runs in rytm-emu (DTEMU_STRICT=1), on a scratch copy of sections/led.img:
  1. a cold boot of FW, the startup dialogs answered, then a busy session: trigs recorded on
     BD (RECORD + T1/T5/T9/T13) and played, DIN MIDI notes and CCs, the USB host attached
     (--usb-host --usb-midi-real), a pattern switch, KIT SAVE and KIT RELOAD, the pads,
     STOP, and a power off (the firmware saves its working state to the card);
  2. a cold boot on that card (the saved state loaded), the dialogs, PLAY 5 s, STOP.
The bounds come from build/manifest_TAG.json (the build's "elek" record), none are hard-coded:
  - the free part of elekloader's area: FREE_LO .. elek.area[1];
  - every region the bundle declares (elek.regions, resources.regions: "sidecar buffers", 3 MB in elekloader's
    `big` area) minus the buffers claimed in it (elek.buffers, registry [[buffer]]).
Adjacent unclaimed spans are one span. Before each run each span gets a canary word every 32 bytes in the area and
every 512 bytes in a region (--poke, address ^ 0xC0DEF00D, as elekloader's hardware canary; fewer in the region to
keep the command line short) and a read/write watch (--watch-read: every CPU access, cached or through the uncached
alias; dtboot turns the JIT off while a watch is set; dtboot takes one range, so a span with a claim in the middle
runs the sessions once per span). After each run: no watch hit, every canary word intact, no strict access, no
FAULT. --blob-check TAG also compares the run image in the area with what the build's manifest says elekloader
appended (only the words the mods own may differ) and prints 0028-elek-hello's counters if present.
RYTM_EMU: rytm-emu's checkout (default ../rytm-emu). Strict mode (DTEMU_STRICT=1) is always on.

Run (b), --samples-host: instead of the busy session, the sample memory filled by the stock sample browser loading
six large wav files from the card (the base TAGw of tools/emu/lag_base.sh, run with LAG_WAV_SEC=N for N-second
files; the emulator has no other way to fill sample memory: dtboot pokes single words only), and the USB host
attached as in tools/emu/hostcost_emu.py's S2 case (the Overbridge link to RYTM_TEENSY's sim/remote_ui.py, BD PLAITS
+ SD U1 from the host's meta messages). Needs RYTM_TEENSY. See the function host_samples."""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

EMU = os.environ.get("RYTM_EMU", "../rytm-emu")
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
STEP = 32            # canary spacing in elekloader's area
STEP_REGION = 512    # ... and in a region (3 MB: the command line must stay short)
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


def spans(man, free_lo):
    """([(lo, hi)] to watch, [(lo, hi, canary step)] to poke), from the manifest's elek record: the free part of
    elekloader's area from free_lo, then each declared region minus the buffers claimed in it; the watched spans are
    merged where adjacent."""
    area_lo, area_hi = man["area"]
    free_lo = (free_lo + STEP - 1) // STEP * STEP
    if not area_lo <= free_lo <= area_hi:
        sys.exit(f"FREE_LO 0x{free_lo:08x} is outside the manifest's area 0x{area_lo:08x}-0x{area_hi:08x}")
    out = [(free_lo, area_hi, STEP)]
    claims = sorted((c["lo"], c["hi"]) for c in man.get("buffers", []))
    for g in sorted(man.get("regions", []), key=lambda g: g["lo"]):
        at = g["lo"]
        for lo, hi in claims + [(g["hi"], g["hi"])]:
            if hi <= at or lo >= g["hi"]:
                continue
            if lo > at:
                out.append((at, lo, STEP_REGION))
            at = max(at, hi)
        if at < g["hi"]:
            out.append((at, g["hi"], STEP_REGION))
    merged = []
    for lo, hi, st in sorted(out):
        if merged and merged[-1][1] == lo:
            merged[-1] = (merged[-1][0], hi)
        else:
            merged.append((lo, hi))
    return merged, sorted(out)


def main():
    fw = os.path.abspath(sys.argv[1])
    if "--blob-check" not in sys.argv:
        sys.exit(__doc__)
    tag = sys.argv[sys.argv.index("--blob-check") + 1]
    man = json.load(open(os.path.join(ROOT, "build", f"manifest_{tag}.json")))["elek"]
    free_lo = int(sys.argv[2], 16)
    sp, pieces = spans(man, free_lo)
    print("watched: " + ", ".join(f"0x{lo:08x}-0x{hi:08x} ({(hi - lo) // 1024} KB)" for lo, hi in sp) + "; canary: " +
          ", ".join(f"0x{lo:08x}-0x{hi:08x} every {st} B" for lo, hi, st in pieces), flush=True)
    rc = 0
    for span in sp:
        rc |= host_samples(tag, span, pieces) if "--samples-host" in sys.argv else session(fw, tag, span, pieces)
    print("PASS" if not fails else "FAIL: " + ", ".join(fails))
    return 1 if fails else rc


def session(fw, tag, span, all_spans):  # all_spans: the canary pieces
    """The two runs (and the power off between them) with the canary over every span and the watch on this one."""
    tmp = tempfile.mkdtemp()
    card = os.path.join(tmp, "card.img")
    shutil.copy(os.path.join(EMU, "sections/led.img"), card)
    canary = [(a, (a ^ 0xC0DEF00D) & 0xFFFFFFFF) for lo, hi, st in all_spans for a in range(lo, hi, st)]
    pokes = [x for a, v in canary for x in ("--poke", f"{a:x}={v:x}")]
    watch = ["--watch-read", f"{span[0]:x}", str(span[1] - span[0])]
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
    report(fw, "run 1 (busy session)", rc, log, s1, canary, tag, span, all_spans)
    # run 1b: from there, the power off (the firmware writes its working state to the card)
    rc, log = dtboot(fw, card, 300, [], ["--load", s1] + watch + ["--power-off", f"{end1 + 100}M"], None)
    report(fw, "run 1b (power off, state saved to the card)", rc, log, None, canary, tag, span, all_spans)
    # run 2: a cold boot on the saved card
    p2 = list(dialogs) + [("PLAY", 4500), ("STOP", 5500)]
    s2 = os.path.join(tmp, "s2.snap")
    rc, log = dtboot(fw, card, 6000, p2, pokes + watch + ["--usb-host"], s2)
    report(fw, "run 2 (cold boot on the saved card, play)", rc, log, s2, canary, tag, span, all_spans)
    shutil.rmtree(tmp, ignore_errors=True)
    return 0


# M instructions the stock UI is given to load one large file (EL_LOAD_WAIT; 4.8 MB loaded well inside 3000 M)
LOAD_WAIT = int(os.environ.get("EL_LOAD_WAIT", 3000))


def load_events(L, at, wait=LOAD_WAIT):
    """lag_emu's events for the stock UI loading the card's six files, with `wait` M instructions more after each
    loading YES before the browser is left (the files here are large; the encoder turns keep lag_emu's 150 M spacing:
    a longer one stops them registering)."""
    ev, t = L.load_events(at)
    shift, out, prev = 0, [], None
    for tt, kind, val in ev:
        if val == "NO" and prev != "NO":
            shift += wait
        out.append((tt + shift, kind, val))
        prev = val
    return out, t + shift


def host_samples(tag, span, all_spans):
    """Run (b): the stock sample browser loads six large wav files into sample memory (tools/emu/lag_emu.py's `real`
    setup: the base TAGw of tools/emu/lag_base.sh, made with LAG_WAV_SEC=N-second files; 110 s files are 63 MB of the
    sample memory's 68 MB), BD on PLAITS and SD on U1 are set
    up from the host's meta messages, and the Overbridge link is open to RYTM_TEENSY's sim/remote_ui.py, as in
    tools/emu/hostcost_emu.py's S2 case; then a pattern plays. Canary over every span, watch on this one, strict mode."""
    import socket
    import lag_emu as L
    import us_emu as U
    e = U.Emu(tag + "w")
    e.strict = True
    canary = [(a, (a ^ 0xC0DEF00D) & 0xFFFFFFFF) for lo, hi, st in all_spans for a in range(lo, hi, st)]
    pokes = [x for a, v in canary for x in ("--poke", f"{a:x}={v:x}")]
    watch = ["--watch-read", f"{span[0]:x}", str(span[1] - span[0])]
    # stage 1: the stock UI loads the six files; stage 2, resumed: the host's meta messages set BD and SD up and the
    # pattern plays; stage 3: 5 s more with the Overbridge link open to the host, as hostcost_emu.py's S2 case (a link
    # open from the start of a resumed run keeps the UI from taking the key presses, so it comes last)
    ev, t = load_events(L, 100)
    snap1 = e.run("el-samples-load", t, ev, save=True, extra=pokes + watch)
    hits1 = [l for l in e.log.splitlines() if l.startswith("watch:")]
    ev2, t2 = L.setup_events(100)
    snap2 = e.run("el-samples-setup", t2, ev2, save=True, snap=snap1, start=e.clock + t, extra=watch)
    hits1 += [l for l in e.log.splitlines() if l.startswith("watch:")]
    so = socket.socket()
    so.bind(("127.0.0.1", 0))
    port = so.getsockname()[1]
    so.close()
    host = subprocess.Popen([sys.executable, os.path.join(U.TEENSY, "sim/remote_ui.py"), "--link", f"127.0.0.1:{port}",
                             "--secs", "600", "--open"], stdout=open(os.path.join(e.tmp, "host.txt"), "w"),
                            stderr=subprocess.STDOUT)
    try:
        snap = e.run("el-samples-host", 1000, [], save=True, snap=snap2, start=e.clock + t + t2,
                     extra=watch + ["--ob-link", f"127.0.0.1:{port}"])
    finally:
        host.kill()
    m = e.peek(snap2, 0x8000ea00, 2)
    name = "run (b) (sample memory filled, USB host attached)"
    hits = [l for l in e.log.splitlines() if l.startswith("watch:")]
    check(f"{name}: no CPU access to 0x{span[0]:08x}-0x{span[1]:08x} while the files load and while the host is attached",
          not hits and not hits1, "; ".join((hits1 + hits)[:4]))
    lens = [int.from_bytes(e.peek(snap, L.SMP_TAB + 16 * k + 8, 4), "big") for k in range(1, 7)]
    ents = [e.peek(snap, L.SMP_TAB + 16 * k, 16) for k in (1, 6)]
    print("     sample table entries 1 and 6: " + " | ".join(x.hex() for x in ents) + f" (sample RAM starts 0x{L.PCM0:08x})")
    want = [int(sec * 48000) for _, sec in L.WAVS]
    check(f"{name}: the stock browser loaded all six files ({sum(lens)} frames, {sum(lens) * 2 / 1e6:.1f} MB as 16-bit)",
          lens == want, str(lens))
    check(f"{name}: BD plays PLAITS (44), SD plays U1 (35): the host's meta messages arrived", (m[0], m[1]) == (44, 35), m.hex())
    check(f"{name}: the Rytm talked to the host over USB", sum(len(x) for x in e.sent) > 0, "no USB MIDI out")
    broken = []
    for lo, hi, _st in all_spans:
        mem = e.peek(snap, lo, hi - lo)
        broken += [a for a, v in canary if lo <= a < hi and int.from_bytes(mem[a - lo:a - lo + 4], "big") != v]
    check(f"{name}: {len(canary)} canary words intact", not broken,
          f"{len(broken)} changed, first 0x{broken[0]:08x}" if broken else "")
    fails.extend(f for f in U.fails if f not in fails)
    return 0


def report(fw, name, rc, log, snap, canary, tag, span=None, all_spans=()):
    check(f"{name}: runs without a fault", rc == 0 and "FAULT" not in log, log[-300:])
    bad = [l for l in log.splitlines() if l.startswith("strict:")]
    check(f"{name}: no strict access", not bad, "; ".join(bad[:3]))
    hits = [l for l in log.splitlines() if l.startswith("watch:")]
    check(f"{name}: no CPU access to 0x{span[0]:08x}-0x{span[1]:08x} (the area's free part and the declared regions, "
          f"minus claims)", not hits, "; ".join(hits[:4]))
    if snap is None or not os.path.exists(snap):
        return
    broken = []
    for lo, hi, _st in all_spans:
        mem = peek(fw, snap, lo, hi - lo)
        broken += [a for a, v in canary if lo <= a < hi and int.from_bytes(mem[a - lo:a - lo + 4], "big") != v]
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
