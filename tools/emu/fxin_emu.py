#!/usr/bin/env python3
"""Emulator tests of 0030-fx-in in rytm-emu: the host's FX IN switch (host-link 26) puts the delay + reverb
return on Overbridge IN channels 10/11 in place of AUDIO IN, and the Rytm reports its state (27).

    .venv/bin/python tools/emu/fxin_emu.py TAG TEST [TEST ...]     exit 0 when every check passes
    .venv/bin/python tools/emu/fxin_emu.py TAG all

TAG: a build with 0030-fx-in and 0022-looper fxin=1, its base made by tools/emu/us_base.sh TAG. Every run is
under DTEMU_STRICT=1, with a simulated USB host streaming Overbridge (--usb-host --usb-midi-real --ob-link). The
host's SysEx goes in with dtboot --usb-midi at a fixed clock; the link client here records the Overbridge IN
frames (oblink R) and the Rytm's USB MIDI (M, after a HELLO_MIDI hello). Key walks and the DIN CCs (82 DEL
send, 83 REV send on the track's channel) are mods/0024-ob-mix's (ob-fx branch, research.md). RYTM_EMU:
rytm-emu's checkout. Firmware-derived files stay in rytm-emu's git-ignored fw/ and sections/ and in build/.
"""
import json
import os
import re
import socket
import struct
import subprocess
import sys
import tempfile
import threading
import time
import wave

import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EMU = os.environ.get("RYTM_EMU", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "rytm-emu"))
FS = 48000
IPS = 200          # M instructions an emulated second
SILENT = -100      # dBFS: nothing on a channel (idle channels are digital zero in the emulator)
HDR = "F07D5254"
FAILS = []


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"   [{detail}]" if detail else ""), flush=True)
    if not ok:
        FAILS.append(name)


def db(x):
    x = x.astype(np.float64) / 2 ** 31
    p = np.mean(x * x) if len(x) else 0.0
    return 10 * np.log10(p) if p > 0 else -200.0


def corr(a, b):
    a, b = a.astype(np.float64), b.astype(np.float64)
    d = np.sqrt(np.sum(a * a) * np.sum(b * b))
    return float(np.sum(a * b) / d) if d else 0.0


class Link(threading.Thread):
    """The Overbridge host stand-in: a HELLO_MIDI hello, then R frames (12 x int32) and the Rytm's USB MIDI (M)."""

    def __init__(self, port):
        super().__init__(daemon=True)
        self.port, self.frames, self.midi, self.err = port, [], bytearray(), None

    def run(self):
        t0 = time.time()
        while True:
            try:
                s = socket.create_connection(("127.0.0.1", self.port))
                break
            except OSError:
                if time.time() - t0 > 60:
                    self.err = "no link"
                    return
                time.sleep(0.05)
        s.sendall(b"H" + bytes([1, 1]))       # version 1, HELLO_MIDI
        buf = b""

        def need(n):
            nonlocal buf
            while len(buf) < n:
                d = s.recv(1 << 20)
                if not d:
                    raise EOFError
                buf += d
        try:
            while True:
                need(1)
                k = buf[0]
                if k == ord("N"):
                    need(5); buf = buf[5:]
                elif k == ord("T"):
                    need(4); buf = buf[4:]
                elif k == ord("P"):
                    need(10); buf = buf[10:]
                elif k == ord("H"):
                    need(3); buf = buf[3:]
                elif k == ord("M"):
                    need(3)
                    n = struct.unpack_from("<H", buf, 1)[0]
                    need(3 + n)
                    self.midi += buf[3:3 + n]
                    buf = buf[3 + n:]
                elif k == ord("R"):
                    need(5)
                    n = struct.unpack_from("<I", buf, 1)[0]
                    need(5 + 48 * n)
                    self.frames.append(np.frombuffer(buf[5:5 + 48 * n], "<i4").reshape(n, 12))
                    buf = buf[5 + 48 * n:]
                else:
                    self.err = f"bad message {k:#x}"
                    return
        except (EOFError, ConnectionResetError, OSError):
            pass

    def array(self):
        return np.concatenate(self.frames) if self.frames else np.zeros((0, 12), "i4")


def reports(midi):
    """The Rytm's 27s, in order: [state, ...]."""
    return [int(m.group(1), 16) for m in re.finditer(r"f07d525427([0-9a-f]{2})f7", bytes(midi).hex())]


class Emu:
    def __init__(self, tag):
        self.tag = tag
        self.fw = f"fw/AR173_us_{tag}.syx"
        self.card = f"sections/us_{tag}.img"
        self.snap = f"sections/us_{tag}.snap"
        self.clock = json.load(open(os.path.join(EMU, f"sections/us_{tag}.json")))["clock"]
        self.out = os.path.join(ROOT, "build", "emu", tag)
        os.makedirs(self.out, exist_ok=True)
        self.tmp = tempfile.mkdtemp()

    def run(self, name, length, events=(), audio_in=None, dac=False, extra=()):
        """length M instructions from the base. events (M after the base): ("sx", HEX) host SysEx on USB MIDI,
        ("din", HEX) on DIN, ("press", KEY), ("gone", (from, to)) the host browns out and comes back."""
        s = socket.socket()
        s.bind(("127.0.0.1", 0))
        port = s.getsockname()[1]
        s.close()
        cmd = ["./target/release/dtboot", self.fw, "--load", self.snap, "--card", self.card,
               "--instr", f"{length}M", "--every", f"{50 if dac else 100}M", "--usb-host", "--usb-midi-real",
               "--ob-link", f"127.0.0.1:{port}", *extra]
        for at, kind, val in events:
            t = self.clock + at
            if kind == "sx":
                cmd += ["--usb-midi", f"{val}@{t}M"]
            elif kind == "din":
                cmd += ["--midi", f"{val}@{t}M"]
            elif kind == "press":
                cmd += ["--press", f"{val}@{t}M"]
            elif kind == "gone":
                cmd += ["--usb-host-gone", f"{self.clock + val[0]}M:{self.clock + val[1]}M"]
        if audio_in:
            cmd += ["--audio-in", audio_in]
        wav = os.path.join(self.tmp, f"{name}.wav")
        if dac:
            cmd += ["--wav", wav]
        link = Link(port)
        link.start()
        env = dict(os.environ, DTEMU_STRICT="1", DTBOOT_END_PNG=os.path.join(self.out, f"fxin_{name}.png"))
        r = subprocess.run(cmd, cwd=EMU, env=env, capture_output=True, text=True)
        link.join(30)
        log = r.stdout + r.stderr
        open(os.path.join(self.out, f"fxin_{name}.dt.txt"), "w").write(log)
        bad = r.returncode != 0 or "FAULT" in log or "strict:" in log
        check(f"{name}: dtboot ran clean (strict, no fault)", not bad,
              "" if not bad else str(re.findall(r".*(?:FAULT|strict:).*", log)[:3] or f"rc {r.returncode}"))
        check(f"{name}: the Overbridge stream was captured", link.err is None and len(link.frames) > 0,
              link.err or "")
        self.ob, self.midi = link.array(), link.midi
        if dac:
            with wave.open(wav) as w:
                self.dac = np.frombuffer(w.readframes(w.getnframes()), "<i2").reshape(-1, w.getnchannels())


def sine_wav(e, secs):
    wav = os.path.join(e.tmp, "sine.wav")        # 1 kHz at -18 dBFS, both sides
    x = (np.sin(2 * np.pi * 1000 * np.arange(secs * FS) / FS) * 32767 * 10 ** (-18 / 20)).astype("<i2")
    with wave.open(wav, "wb") as w:
        w.setnchannels(2), w.setsampwidth(2), w.setframerate(FS)
        w.writeframes(np.repeat(x, 2).tobytes())
    return wav


def runs(mask):
    """[(start, length)] of the True runs in mask."""
    d = np.diff(np.concatenate([[0], mask.astype(np.int8), [0]]))
    return list(zip(np.flatnonzero(d == 1), np.flatnonzero(d == -1) - np.flatnonzero(d == 1)))


def t_switch(e):
    """AUDIO IN (a sine) on 10/11 until 26 01, gone while on, back after 26 00; replies 27 00 (port up), 01, 00;
    26 7F asks without a change."""
    on_at, off_at, ask_at = 300, 700, 900
    e.run("switch", 1100, [(on_at, "sx", f"{HDR}2601F7"), (off_at, "sx", f"{HDR}2600F7"),
                           (ask_at, "sx", f"{HDR}267FF7")], audio_in=sine_wav(e, 7))
    a = e.ob
    blk = 32 * 16                                     # per-512-frame levels on channel 10
    n = len(a) // blk
    lv = np.array([max(db(a[i * blk:(i + 1) * blk, 10]), db(a[i * blk:(i + 1) * blk, 11])) for i in range(n)])
    gap = runs(lv < SILENT)                            # AUDIO IN gone: the FX return (silent, no sends) instead
    print(f"  {len(a)} frames; the sine's level {np.median(lv[lv > -60]) if np.any(lv > -60) else -200:.1f} dB; "
          f"silent runs (frames): {[(int(s) * blk, int(l) * blk) for s, l in gap]}")
    check("switch: the sine is on 10/11 before the switch", n > 4 and np.all(lv[:2] > -40))
    want = (off_at - on_at) / IPS * FS
    one = [g for g in gap if abs(g[1] * blk - want) < 0.15 * FS]
    check("switch: 10/11 leave AUDIO IN exactly once, for the time between 26 01 and 26 00 (+-0.15 s)",
          len(gap) == 1 and len(one) == 1, f"want {want / FS:.2f} s, got {[round(g[1] * blk / FS, 2) for g in gap]}")
    check("switch: the sine is back on 10/11 at the end", np.all(lv[-2:] > -40))
    rep = reports(e.midi)
    print(f"  27 reports: {rep}")
    check("switch: reports 27 00 (port up), 27 01, 27 00, 27 00 (the ask), in order", rep == [0, 1, 0, 0])


def t_delay(e):
    """26 01, then SD with DEL: the echoes on 10/11 (correlating with the dry hit), the dry hit only on channel 3,
    the stem at the DAC return words' level."""
    e.run("delay", 1900, [(50, "sx", f"{HDR}2601F7"), (100, "din", "B15264"), (110, "din", "B15300"),
                          (1100, "press", "SD")], dac=True)
    fx_hit(e, "delay", 3, 0.30)


def t_reverb(e):
    """26 01, then BD with REV: a stereo tail on 10/11 at the DAC return words' level."""
    e.run("reverb", 1900, [(50, "sx", f"{HDR}2601F7"), (100, "din", "B05200"), (110, "din", "B05364"),
                           (1100, "press", "BD")], dac=True)
    fx_hit(e, "reverb", 2, 0.0)


def t_off(e):
    """No 26 (the boot's state): SD with DEL leaves 10/11 silent (stock: AUDIO IN, nothing connected); 27 00 on
    port up only."""
    e.run("off", 1900, [(100, "din", "B15264"), (110, "din", "B15300"), (1100, "press", "SD")])
    a = e.ob
    o = np.flatnonzero(np.abs(a[:, 3].astype(np.int64)) > 1 << 22)
    check("off: the SD hit is on channel 3", len(o) > 0)
    l10, l11 = db(a[:, 10]), db(a[:, 11])
    check("off: 10/11 silent (AUDIO IN, unplugged; no FX)", max(l10, l11) < SILENT, f"{l10:.1f} / {l11:.1f} dB")
    check("off: one 27 00 (the port came up), nothing else", reports(e.midi) == [0], str(reports(e.midi)))


def t_gone(e):
    """26 01, then the host browns out and comes back: the Rytm is off again (AUDIO IN on 10/11) and says so
    (27 00 when the port is up again) without being asked."""
    e.run("gone", 1100, [(150, "sx", f"{HDR}2601F7"), (450, "gone", (450, 600))], audio_in=sine_wav(e, 7))
    a = e.ob
    rep = reports(e.midi)
    print(f"  27 reports: {rep}; {len(a)} frames")
    check("gone: 27 00 (up), 27 01, then 27 00 after the re-plug", rep[:3] == [0, 1, 0] and len(rep) == 3, str(rep))
    tail = a[-FS // 2:]
    check("gone: AUDIO IN back on 10/11 after the re-plug", min(db(tail[:, 10]), db(tail[:, 11])) > -40,
          f"{db(tail[:, 10]):.1f} dB")


def fx_hit(e, name, ch, dry_s):
    a = e.ob
    rep = reports(e.midi)
    check(f"{name}: reports 27 00 (up) then 27 01", rep == [0, 1], str(rep))
    o = np.flatnonzero(np.abs(a[:, ch].astype(np.int64)) > 1 << 22)
    check(f"{name}: the hit is on channel {ch}", len(o) > 0)
    if not len(o):
        return
    o = int(o[0])
    wet = slice(o + int(max(dry_s, 0.05) * FS), o + int(2.5 * FS))
    w10, w11 = db(a[wet, 10]), db(a[wet, 11])
    others = max(db(a[wet, c]) for c in range(2, 10) if c != ch)
    print(f"  tail: ch10 {w10:.1f} dB, ch11 {w11:.1f} dB, other voices {others:.1f} dB")
    check(f"{name}: the return is on channels 10 and 11", min(w10, w11) > -80, f"{w10:.1f} / {w11:.1f} dB")
    check(f"{name}: nothing on the other voice channels", others < SILENT)
    check(f"{name}: the two sides differ (stereo)", not np.array_equal(a[wet, 10], a[wet, 11]))
    if dry_s:
        d3, d10 = db(a[o:o + int(dry_s * FS), ch]), max(db(a[o:o + int(dry_s * FS), c]) for c in (10, 11))
        check(f"{name}: the dry hit is not on 10/11 (30 dB under channel {ch})", d10 < d3 - 30,
              f"{d3:.1f} / {d10:.1f} dB")
        seg = a[o:o + int(0.25 * FS), ch]
        best = max((abs(corr(seg, a[o + k:o + k + len(seg), c])), k, c) for c in (10, 11)
                   for k in range(int(0.30 * FS), int(0.80 * FS), 16))
        check(f"{name}: an echo correlates with the dry hit", best[0] > 0.5,
              f"{best[0]:+.2f} at {best[1] * 1000 / FS:.0f} ms on channel {best[2]}")
    # the stem against the FX return words stock writes for the DAC (frame words 12..15: (gd delay + 2 gr reverb)
    # >> 8 per side, 0024 research.md A1), as energy over the run; Q31 against the WAV's int16: one full scale
    st = a[:, 10:12].astype(np.float64) / 2 ** 31
    dw = e.dac.astype(np.float64) / 2 ** 15
    ref = 10 * np.log10(max(np.sum(dw[:, 12:16] ** 2), 1e-30))
    got = 10 * np.log10(max(np.sum(st ** 2), 1e-30))
    check(f"{name}: the stem's level is the DAC return's (within 1 dB)", abs(got - ref) < 1.0,
          f"stem {got:.2f} dB, DAC FX words {ref:.2f} dB")


TESTS = {"switch": t_switch, "delay": t_delay, "reverb": t_reverb, "off": t_off, "gone": t_gone}


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
    print(f"{'ALL PASS' if not FAILS else f'{len(FAILS)} FAILED: ' + ', '.join(FAILS)}")
    sys.exit(1 if FAILS else 0)


if __name__ == "__main__":
    main()
