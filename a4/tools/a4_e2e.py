#!/usr/bin/env python3
"""The end-to-end proof: the A4 emulator (analog-emu's dtboot) running the mod, on its own USB stack in OVERBRIDGE mode, against the Sidecar emulator (the engine
on the Mac, sidecar-firmware tools/sidecar_emu.cpp) over the Overbridge link.

    a4_e2e.py --emu DIR --engine DIR --syx OS.syx --out DIR [--base 4G]

The panel is played by script: USB CONFIG > OVERBRIDGE, the NOISE page, a machine on T1, notes by DIN MIDI. Checked: the hello accepted (one restart of the
Sidecar into /.a4), trigs and params and note-offs through the real profile, the voice's audio on OUT channel 2 only, that audio through the A4's analog voice model to the
A4's output (compared with the same run with the Sidecar's voice silent), and the A4's channels back on IN. Firmware-derived outputs stay in --out."""
import argparse, json, math, os, shutil, struct, subprocess, sys, time, wave
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
    """NOISE, knob D up by `detents` steps. Boot page: OSC1, and OSC1 steps to NOISE. lev0: OSC1's LEV down first: a track that stays OFF; a pick from OFF sets it 0 itself."""
    a = ["--press", f"{track_key}@{M(t)}"]; t += 100
    if lev0:
        a += ["--turn", f"4:-1@{M(t)}x1400/300k"]; t += 520
    a += ["--press", f"OSC1@{M(t)}"]; t += 150
    a += ["--nudge", f"3:1@{M(t)}x{detents}/200M"]; t += detents * 200 + 100
    return a, t


def panel_poly(t):
    """KIT > POLY CONFIG, all four voices, on the selected track."""
    a = ["--press", f"KIT@{M(t)}"]; t += 120
    for _ in range(5):
        a += ["--press", f"DOWN@{M(t)}"]; t += 120
    a += ["--press", f"YES@{M(t)}"]; t += 120
    for i in range(4):
        a += ["--press", f"YES@{M(t)}"]; t += 100
        if i < 3:
            a += ["--press", f"RIGHT@{M(t)}"]; t += 100
    for w in (120, 120, 400):
        a += ["--press", f"NO@{M(t)}"]; t += w
    return a, t


def panel_step(t, keys=("KB_C1", "KB_E1", "KB_G1")):
    """An empty pattern, a chord on T1's step by GRID RECORD, the keys' sound let go, PLAY. Returns (args, t, PLAY's time)."""
    a = ["--press", f"BANK_H@{M(t)}"]; t += 120
    a += ["--press", f"T16@{M(t)}"]; t += 500
    a += ["--press", f"RECORD@{M(t)}"]; t += 150
    a += ["--press", f"T1@{M(t)}:700M"]
    for i, k in enumerate(keys):
        a += ["--press", f"{k}@{M(t + 100 + i * 60)}:{400 - i * 60}M"]
    t += 900
    a += ["--press", f"RECORD@{M(t)}"]; t += 600
    a += ["--press", f"PLAY@{M(t)}"]
    return a, t + 1000, t


def tone(x, f, rate=48000):
    """Goertzel: the power at f."""
    k, a, b = 2 * math.cos(2 * math.pi * f / rate), 0.0, 0.0
    for v in x:
        a, b = v + k * a - b, a
    return a * a + b * b - k * a * b


def notes_in(x):
    """x's power on each semitone of MIDI 36..96, the first 0.4 s from its onset, full scale 1."""
    on = next((i for i, v in enumerate(x) if abs(v) > 2**31 * 0.001), 0)
    w = [v / 2**31 for v in x[on:on + 19200]]
    return {n: tone(w, 440 * 2 ** ((n - 69) / 12)) for n in range(36, 97)}


def rms(x):
    return (sum(v * v for v in x) / max(1, len(x))) ** 0.5


def read_wav32(p):
    b = open(p, "rb").read()
    ch = struct.unpack_from("<H", b, 22)[0]
    n = (len(b) - 44) // 4
    d = struct.unpack_from(f"<{n}i", b, 44)
    return ch, [d[c::ch] for c in range(ch)]


def run(a, name, detents, lev0, trig=None, extra=(), chord=None, poly=False, step=False, screen=None, peek=None):
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
    env["DTBOOT_END_PNG"] = out + "/end.png"
    if peek:
        env["DTBOOT_PEEK"] = peek
    t = 4000
    args, t = panel_overbridge(t)
    t += 300                                    # re-enumerated, the hello met, the Sidecar restarted
    m, t = page_machine(t, "TRACK1", detents, lev0)
    args += m
    if poly:
        m, t = panel_poly(t)
        args += m
    t += 100
    notes = []
    if step:
        m, t, a.played = panel_step(t)
        args += m
    if screen is not None:                      # a note, so the voice reports; UP + YES; the keys
        args += ["--midi", f"90{a.note:02x}64@{M(t)}", "--midi", f"80{a.note:02x}00@{M(t + 100)}"]
        t += 300
        args += ["--press", f"UP@{M(t)}:300M", "--press", f"YES@{M(t + 220)}:30M"]; t += 650
        for k in screen:
            args += ["--press", f"{k}@{M(t)}"]; t += 200
    if chord:
        args += ["--midi", "".join(f"90{n:02x}64" for n in chord) + f"@{M(t)}", "--midi", "".join(f"80{n:02x}00" for n in chord) + f"@{M(t + 300)}"]
        t += 500
    for k in range(a.notes):
        at, off = t + 400 * k, t + 400 * k + 200
        args += ["--midi", f"90{a.note:02x}64@{M(at)}", "--midi", f"80{a.note:02x}00@{M(off)}"]
        notes.append((at, off))
    t += 400 * a.notes + 200 + getattr(a, "tail", 0)
    cmd = [dtboot, a.syx, "--card", img, "--usb-host", "--usb-midi-real", "--ob-link", f"127.0.0.1:{PORT}", "--analog-wav", out + "/a4_out.wav", "--instr", M(t), "--every", "100M" if peek else "1G", *args]
    emu = subprocess.Popen(cmd, stdout=emu_log, stderr=subprocess.STDOUT, env=env)
    time.sleep(1)
    sc = [os.path.join(a.engine, "core/build/sidecar_emu"), "--link", f"127.0.0.1:{PORT}", "--card", card, "--out-wav", out + "/to_a4.wav", "--in-wav", out + "/from_a4.wav", "--frame-out", out + "/frame.bin"]
    for tr in (trig.split(",") if trig else ()):
        sc += ["--trig", tr]
    sc += list(extra)
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


def symbol(syx, name):
    """A symbol's address from the build's map."""
    def walk(x):
        if isinstance(x, dict):
            for k, v in x.items():
                if k == name and isinstance(v, (int, str)):
                    return int(v, 0) if isinstance(v, str) else v
                r = walk(v)
                if r is not None:
                    return r
        elif isinstance(x, list):
            for v in x:
                r = walk(v)
                if r is not None:
                    return r
    return walk(json.load(open(syx + ".map.json")))


def screen_load(a):
    """The page drawn from the real engine while a machine plays, against the same notes with the page closed: the frame on the A4's screen, the stream, the audio interrupt's load (core_audio_load, 256ths, every 0.5 s), the voice's level on OUT."""
    from a4_suite import bitmap, frame_rows
    load = symbol(a.syx, "core_audio_load")
    a.notes, a.tail, ok, rows = 40, 200, True, {}
    for name, keys, ex in (("closed", None, ()), ("open", ("RIGHT", "RIGHT", "RIGHT"), ()), ("flood", ("RIGHT", "RIGHT", "RIGHT"), ("--flood",))):
        out, notes, t = run(a, "screen_" + name, 1, False, extra=ex, peek=f"{load:x},{symbol(a.syx, 'a4_rx_msgs'):x},{symbol(a.syx, 'a4_rui_torn'):x},{symbol(a.syx, 'a4_rui_drop'):x}", screen=keys if keys else None)
        log = open(out + "/dtboot.log", errors="replace").read()
        side = open(out + "/sidecar.log").read()
        lo = [int(x, 16) for x in __import__("re").findall(rf"\[{load:08x}\]=([0-9a-f]+)", log)][4:]
        print(name, "last peek", [l for l in log.splitlines() if "peek" in l][-1][:120])
        m = __import__("re").search(r"bad_blocks: (\d+).*?out_underruns: (\d+)", log)
        ch, d = read_wav32(out + "/to_a4.wav")
        rows[name] = dict(max=max(lo), mean=sum(lo) / len(lo), bad=int(m.group(1)), under=int(m.group(2)), rms=rms(d[2][-480000:]) / 2**31, sc=[l for l in side.splitlines() if "under" in l][-1].split("under ")[1])
        print(name, rows[name], [l for l in side.splitlines() if " screen " in l])
        if keys:
            bm, fr = bitmap(out + "/end.png"), frame_rows(out + "/frame.bin")
            print("PASS" if bm == fr else "FAIL", "the page on the A4's screen is the real engine's frame:", sum(x != y for p, q in zip(bm, fr) for x, y in zip(p, q)), "pixels differ")
            ok = ok and bm == fr
    good = True
    for n in ("open", "flood"):
        o, c = rows[n], rows["closed"]
        g = o["bad"] == 0 and o["sc"].startswith("0,") and o["max"] <= c["max"] + 3 and o["mean"] <= c["mean"] + 1
        good = good and g
        print("PASS" if g else "FAIL", f"the stream, page {n}:", f"bad blocks {o['bad']}, engine underruns {o['sc']}, audio load max {o['max']}/256 against {c['max']} closed, mean {o['mean']:.1f} against {c['mean']:.1f}; the link's own OUT underruns {o['under']} against {c['under']}: the emulator's host against the Mac's clock, up and down from run to run, not judged")
    return ok and good


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
            a.notes, a.tail = 1, 800                     # one A4 trig, then the sequencer's note, on its own
            trig = "11.5:0.3:0:60"
        out, notes, t = run(a, name, det, lev, trig)
        ch, d = read_wav32(out + "/to_a4.wav")
        ic, r = read_wav32(out + "/from_a4.wav")
        side = open(out + "/sidecar.log").read()
        res[name] = max(peaks(r[2]))
        ms = list(messages(open(out + "/usb.bin", "rb").read()))
        tr = sum(1 for m in ms if m[4] == 4)
        print(f"{name}: to A4 peaks {[round(max(abs(x) for x in c) / 2**31, 3) for c in d]}; voice 1 back on IN by the second {[round(v, 4) for v in peaks(r[2])]}; 04 from the A4 {tr}")
        print("   ", [l for l in side.splitlines() if l.startswith("sidecar_emu: end")], "voice trigs in the engine:", sum(1 for l in side.splitlines() if "core: trig voice" in l))
        res[name + "_trigs"] = (tr, sum(1 for l in side.splitlines() if "core: trig voice" in l))
    # a stop with notes held: two notes on voice 1, held on past the end, then the sequencer's all-off. Control: the same with no all-off.
    a.notes, a.tail = 1, 800                         # one A4 trig, then only the Sidecar's notes
    held = "11.5:100:0:60,11.6:100:0:64"
    for name, ex in (("held", ()), ("all_off", ("--all-off", "13.0"))):
        out, notes, t = run(a, name, 1, True, held, ex)
        ms = list(messages(open(out + "/usb.bin", "rb").read()))
        side = open(out + "/sidecar.log").read()
        to_box = [l.split("to the box ")[1] for l in side.splitlines() if "to the box" in l]
        print(f"{name}: to the box {to_box}; reports {[hex(m[4]) for m in ms if m[4] in (4, 0x11)]}")
        res[name] = (to_box, [m[4] for m in ms if m[4] in (4, 0x11)])
    # a chord on a poly track, each priority machine: its pitches on the voice's one channel. Control: the same three notes on a mono track
    ok_chord = True
    a.notes, a.tail = 0, 200
    for mach, det in (("plaits", 1), ("juno", 2), ("fm6", 4)):
        p = {}
        for name, poly in (("poly", True), ("mono", False)):
            out, notes, t = run(a, f"chord_{mach}_{name}", det, True, chord=(60, 64, 67), poly=poly)
            ch, d = read_wav32(out + "/to_a4.wav")
            ms = list(messages(open(out + "/usb.bin", "rb").read()))
            p[name] = notes_in(d[2])
            others = max(max(abs(v) for v in d[c]) for c in (0, 1, 3, 4, 5))
            print(f"{name} {mach}: 04s {[m[6] for m in ms if m[4] == 4]}, 11s {sum(1 for m in ms if m[4] == 0x11)}, peak on the voice's channel {max(abs(v) for v in d[2]) / 2**31:.3f}, other channels {others / 2**31:.5f}")
            ok_chord = ok_chord and others == 0
        # mono plays its last note, 67, alone: its strongest partial, whatever the machine's timbre and TUN. A chord adds that same partial where 60 and 64 put it, 7 and 3 semitones down
        q, r = p["poly"], p["mono"]
        top = max((n for n in r if n >= 48), key=lambda n: r[n])
        rise = [round(10 * math.log10(max(q[n], 1e-12) / max(r[n], 1e-12)), 1) for n in (top - 7, top - 3)]
        good = min(rise) >= 6 or mach == "plaits"        # the default knobs pick engine 11 with glide: close to noise, no partial to follow. Pitch: core/tests/test_device.cpp, a tonal engine
        print("NOT JUDGED" if mach == "plaits" else "PASS" if good else "FAIL", f"{mach}: mono's strongest partial on {top}; at -7 and -3 semitones the chord is {rise} dB over mono")
        ok_chord = ok_chord and good
        if mach == "plaits":
            continue
        # the same chord on a mono track's step: what POLY CONFIG leaves to the Sidecar. The keys' mono line above is the control, and the chord's first bar is what is heard
        out, notes, t = run(a, f"chord_{mach}_step", det, True, step=True)
        ch, d = read_wav32(out + "/to_a4.wav")
        ms = list(messages(open(out + "/usb.bin", "rb").read()))
        s = notes_in(window(d[2], a.played, 1.5, t))
        rise = [round(10 * math.log10(max(s[n], 1e-12) / max(r[n], 1e-12)), 1) for n in (top - 7, top - 3)]
        tr = [m[6] for m in ms if m[4] == 4][-6:]
        others = max(max(abs(v) for v in d[c]) for c in (0, 1, 3, 4, 5))
        good = min(rise) >= 6 and tr == [60, 64, 67] * 2 and others == 0
        print("PASS" if good else "FAIL", f"{mach}: a chord on a mono track's step: last 04s {tr}, at -7 and -3 semitones {rise} dB over the mono line, other channels {others / 2**31:.5f}")
        ok_chord = ok_chord and good
    ok_screen = screen_load(a)
    offs = [x for x in res["all_off"][0] if x.startswith("80")]
    legal = all(int(p, 16) < 128 for x in res["all_off"][0] for p in x.split()[1:3])
    good = len(offs) == 2 and legal and {x.split()[1] for x in offs} == {"3c", "40"}
    last = res["all_off"][1][-1] == 0x11 and res["held"][1][-1] == 4
    print("PASS" if good and last else "FAIL", "a stop with two notes held: an off for each, legal bytes, the A4's voice let go: its report ends in an 11, with no stop in a 04")
    ok_off = good and last
    ok = res["input_only"] > 10 * res["no_machine_lev0"]
    echo = res["seq_to_a4_trigs"]
    print("PASS" if echo == (2, 1) else "FAIL", "the sequencer's note: the A4 played it (04s: 1 DIN + 1), the engine logged the DIN trig and not that echo:", echo)
    ok = ok and echo == (2, 1) and ok_off and ok_chord and ok_screen
    print("PASS" if ok else "FAIL", "the Sidecar's voice through the A4's own voice and back on IN: input only", res["input_only"], "against no machine", res["no_machine_lev0"])
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
