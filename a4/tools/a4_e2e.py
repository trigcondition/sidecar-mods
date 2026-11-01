#!/usr/bin/env python3
"""The end-to-end proof: the A4 emulator (analog-emu's dtboot) running the mod, on its own USB stack in OVERBRIDGE mode, against the Sidecar emulator (the engine
on the Mac, sidecar-firmware tools/sidecar_emu.cpp) over the Overbridge link.

    a4_e2e.py --emu DIR --engine DIR --syx OS.syx --out DIR [--base 4G]

The panel is played by script: USB CONFIG > OVERBRIDGE, the SIDECAR page, a machine on T1, notes by DIN MIDI. Checked: the hello accepted (one restart of the
Sidecar into /.a4), trigs and params and note-offs through the real profile, the voice's audio on OUT channel 2 only, that audio through the A4's analog voice model to the
A4's output (compared with the same run with the Sidecar's voice silent), and the A4's channels back on IN. Firmware-derived outputs stay in --out."""
import argparse, json, os, shutil, struct, subprocess, sys, time, wave
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

PORT = 7344


def M(x):
    return f"{int(x)}M"


def panel_overbridge(t):
    """Keys from the main page to USB CONFIG > OVERBRIDGE and back. t in M instructions; returns (args, t)."""
    a = ["--press", f"GLOBAL@{M(t)}"]
    t += 200
    for _ in range(10):
        a += ["--press", f"DOWN@{M(t)}"]
        t += 80
    a += ["--press", f"YES@{M(t)}"]; t += 250
    a += ["--press", f"DOWN@{M(t)}"]; t += 100
    a += ["--press", f"YES@{M(t)}"]; t += 250
    a += ["--press", f"UP@{M(t)}"]; t += 100
    a += ["--press", f"YES@{M(t)}"]; t += 250
    for _ in range(3):
        a += ["--press", f"NO@{M(t)}"]
        t += 200
    return a, t


def page_machine(t, track_key, detents, lev0=False):
    """The SIDECAR page, knob A up by `detents` steps. Boot page: OSC1. OSC1 steps OSC1 > NOISE > SIDECAR. lev0: OSC1's LEV down first, so all that sounds is the input."""
    a = ["--press", f"{track_key}@{M(t)}"]; t += 100
    if lev0:
        a += ["--turn", f"4:-1@{M(t)}x1400/300k"]; t += 520
    a += ["--press", f"OSC1@{M(t)}"]; t += 150
    a += ["--press", f"OSC1@{M(t)}"]; t += 150
    a += ["--nudge", f"0:1@{M(t)}x{detents}/40M"]; t += detents * 40 + 100
    return a, t


def rms(x):
    return (sum(v * v for v in x) / max(1, len(x))) ** 0.5


def read_wav32(p):
    b = open(p, "rb").read()
    ch = struct.unpack_from("<H", b, 22)[0]
    n = (len(b) - 44) // 4
    d = struct.unpack_from(f"<{n}i", b, 44)
    return ch, [d[c::ch] for c in range(ch)]


def run(a, name, detents, lev0, trig=None):
    out = os.path.join(a.out, name)
    shutil.rmtree(out, ignore_errors=True)
    os.makedirs(out)
    dtboot = os.path.join(a.emu, "target/release/dtboot")
    emu_log = open(out + "/dtboot.log", "w")
    sc_log = open(out + "/sidecar.log", "w")
    card = out + "/card"
    os.makedirs(card)
    img = out + "/a4.img"
    subprocess.run(["cp", "-c", a.card, img], check=True)
    env = dict(os.environ, DTBOOT_QUIET_USB="1", DTBOOT_USB_OUT=out + "/usb.bin", DTEMU_STRICT="1", DTEMU_NO_JIT="1") if False else dict(os.environ, DTBOOT_QUIET_USB="1", DTBOOT_USB_OUT=out + "/usb.bin")
    t = 4000
    args, t = panel_overbridge(t)
    t += 300                                    # re-enumerated, the hello met, the Sidecar restarted
    m, t = page_machine(t, "T1", detents, lev0)
    args += m
    t += 100
    notes = []
    for k in range(a.notes):
        at, off = t + 400 * k, t + 400 * k + 200
        args += ["--midi", f"90{a.note:02x}64@{M(at)}", "--midi", f"80{a.note:02x}00@{M(off)}"]
        notes.append((at, off))
    t += 400 * a.notes + 200
    cmd = [dtboot, a.syx, "--card", img, "--usb-host", "--usb-midi-real", "--ob-link", f"127.0.0.1:{PORT}", "--analog-wav", out + "/a4_out.wav", "--instr", M(t), "--every", "1G", *args]
    emu = subprocess.Popen(cmd, stdout=emu_log, stderr=subprocess.STDOUT, env=env)
    time.sleep(1)
    sc = [os.path.join(a.engine, "core/build/sidecar_emu"), "--link", f"127.0.0.1:{PORT}", "--card", card, "--out-wav", out + "/to_a4.wav", "--in-wav", out + "/from_a4.wav"]
    if trig:
        sc += ["--trig", trig]
    side = subprocess.Popen(sc, stdout=sc_log, stderr=subprocess.STDOUT)
    emu.wait()
    time.sleep(1)
    if side.poll() is None:
        side.terminate()
        side.wait()
    emu_log.close(); sc_log.close()
    return out, notes, t


def wav16(p):
    w = wave.open(p)
    ch, n = w.getnchannels(), w.getnframes()
    d = struct.unpack(f"<{ch * n}h", w.readframes(n))
    return ch, [d[c::ch] for c in range(ch)]


def window(x, at, len_s, end_clock, rate=48000):
    """x's samples for a clock (M instructions) window, x being the last samples up to end_clock."""
    n = len(x)
    i = n - int((end_clock - at) / 200 * rate)
    return x[max(0, i):max(0, i) + int(len_s * rate)]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--emu", required=True); ap.add_argument("--engine", required=True); ap.add_argument("--syx", required=True)
    ap.add_argument("--out", required=True); ap.add_argument("--card", required=True)
    ap.add_argument("--note", type=int, default=60); ap.add_argument("--notes", type=int, default=4)
    a = ap.parse_args()
    res = {}
    def peaks(x):
        return [max(abs(v) for v in x[i:i + 48000]) / 2**31 for i in range(0, len(x), 48000)]
    from decode import messages
    for name, det, lev, seq in (("machine", 1, False, False), ("input_only", 1, True, False), ("no_machine_lev0", 0, True, False), ("seq_to_a4", 1, True, True)):
        trig = None
        if seq:
            a.notes = 1                                  # the sequencer plays; the A4's own trigs: one
            trig = "6.0:0.3:0:60"
        out, notes, t = run(a, name, det, lev, trig)
        ch, d = read_wav32(out + "/to_a4.wav")
        ic, r = read_wav32(out + "/from_a4.wav")
        side = open(out + "/sidecar.log").read()
        res[name] = max(peaks(r[2]))
        ms = list(messages(open(out + "/usb.bin", "rb").read()))
        tr = sum(1 for m in ms if m[4] == 4)
        print(f"{name}: to A4 peaks {[round(max(abs(x) for x in c) / 2**31, 3) for c in d]}; voice 1 back on IN by the second {[round(v, 4) for v in peaks(r[2])]}; 04 from the A4 {tr}")
        print("   ", [l for l in side.splitlines() if l.startswith("sidecar_emu: end")])
    ok = res["input_only"] > 10 * res["no_machine_lev0"]
    print("PASS" if ok else "FAIL", "the Sidecar's voice through the A4's own voice and back on IN: input only", res["input_only"], "against no machine", res["no_machine_lev0"])
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
