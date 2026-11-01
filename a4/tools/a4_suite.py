#!/usr/bin/env python3
"""The mod's suite in the emulator: analog-emu's dtboot, the firmware's own USB stack. Nothing here talks to a unit.

    a4_suite.py --emu DIR --stock STOCK.syx --syx OS.syx --card IMG --out DIR [names...]

Firmware-derived outputs stay in --out. Exit 0 when every test passes."""
import argparse, hashlib, os, re, subprocess, sys, wave, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from decode import messages

RESULTS = []


def check(name, ok, detail=""):
    RESULTS.append((name, bool(ok)))
    print(f"  {'PASS' if ok else 'FAIL'}  {name}   [{detail}]", flush=True)


class Run:
    """One dtboot run, a key script with times in M instructions."""
    def __init__(self, a, name, syx=None, usb=True, strict=False, card=None, env=None):
        self.a, self.name = a, name
        self.syx = syx or a.syx
        self.dir = os.path.join(a.out, name)
        os.makedirs(self.dir, exist_ok=True)
        self.card = os.path.join(self.dir, "card.img")
        if os.path.exists(self.card):
            os.remove(self.card)
        subprocess.run(["cp", "-c", card or a.card, self.card], check=True)
        self.args, self.t, self.usb, self.strict = [], 4000, usb, strict
        self.env = env or {}
        self.usb_file = os.path.join(self.dir, "usb.bin")

    def key(self, name, gap=120, hold=None):
        self.args += ["--press", f"{name}@{self.t}M" + (f":{hold}M" if hold else "")]
        self.t += gap
        return self

    def nudge(self, enc, d=1, gap=60, n=1):
        self.args += ["--nudge", f"{enc}:{d}@{self.t}Mx{n}/{gap}M"]
        self.t += gap * n
        return self

    def turn(self, enc, d, n, every="300k", gap=None):
        self.args += ["--turn", f"{enc}:{d}@{self.t}Mx{n}/{every}"]
        self.t += gap or (n // 3 + 20)
        return self

    def midi(self, hex_, gap=0):
        self.args += ["--midi", f"{hex_}@{self.t}M"]
        self.t += gap
        return self

    def overbridge(self):
        self.key("GLOBAL", 200)
        for _ in range(10):
            self.key("DOWN", 80)
        self.key("YES", 250).key("DOWN", 100).key("YES", 250).key("UP", 100).key("YES", 250)
        for _ in range(3):
            self.key("NO", 200)
        return self

    def machine(self, track, steps):
        """TRACKn, OSC1 > NOISE > SIDECAR, knob A, back to OSC1."""
        self.key(f"TRACK{track}", 120).key("OSC1", 150).key("OSC1", 150)
        self.nudge(0, 1 if steps > 0 else -1, 60, abs(steps))
        return self.key("OSC1", 150)

    def go(self, extra=None, tail=300):
        env = dict(os.environ, DTBOOT_QUIET_USB="1", DTBOOT_USB_OUT=self.usb_file, DTEMU_USB_SEND_LOG="1", **self.env)
        if self.strict:
            env["DTEMU_STRICT"] = "1"
        cmd = [os.path.join(self.a.emu, "target/release/dtboot"), self.syx, "--card", self.card, "--instr", f"{self.t + tail}M", "--every", "1G",
               "--analog-wav", self.dir + "/out.wav", *self.args, *(extra or [])]
        if self.usb:
            cmd += ["--usb-host", "--usb-midi-real"]
        env["DTBOOT_END_PNG"] = self.dir + "/end.png"
        r = subprocess.run(cmd, capture_output=True, text=True, errors="replace", env=env)
        self.log = r.stdout + r.stderr
        open(self.dir + "/log.txt", "w").write(self.log)
        self.rc = r.returncode
        self.msgs = list(messages(open(self.usb_file, "rb").read())) if os.path.exists(self.usb_file) else []
        return self

    def count(self, cmd):
        return sum(1 for m in self.msgs if m[1:4] == b"\x7d\x52\x54" and m[4] == cmd)

    def sent(self):
        """(clock, cmd) of each message as the host read it."""
        return [(int(c), int(k, 16)) for c, k in re.findall(r"usb send: clock (\d+) len \d+ cmd ([0-9a-f]+)", self.log)]

    def faults(self):
        # strict: stock's own read of address 0 at 0x40105db8 stays out of it, it is there on stock
        return [l for l in self.log.splitlines() if ("FAULT" in l or l.startswith("strict:") or "panic" in l or "from interrupt level" in l.lower()) and "pc 40105db8" not in l]


def wav_rms(p):
    w = wave.open(p)
    n = w.getnframes()
    d = struct.unpack(f"<{n * w.getnchannels()}h", w.readframes(n))
    return (sum(x * x for x in d) / max(1, len(d))) ** 0.5


def sha(p):
    return hashlib.sha256(open(p, "rb").read()).hexdigest()[:12]


def script_play(r):
    """A stock session: pages, a knob, a pattern of trigs, played."""
    r.key("TRACK1").key("RECORD", 100)
    for s in (1, 5, 9, 13):
        r.key(f"T{s}", 60)
    r.key("RECORD", 100).key("FILTERS").key("AMP").nudge(2, 1, 40, 3).key("OSC1")
    r.key("PLAY", 1600).key("STOP", 200)
    return r


def t_no_pi(a):
    s = script_play(Run(a, "nopi_stock", syx=a.stock, usb=False)).go()
    m = script_play(Run(a, "nopi_mod", usb=False)).go()
    check("no_pi: the same screen as stock after a session, no USB host", sha(s.dir + "/end.png") == sha(m.dir + "/end.png"), f"{sha(s.dir + '/end.png')} {sha(m.dir + '/end.png')}")
    rs, rm = wav_rms(s.dir + "/out.wav"), wav_rms(m.dir + "/out.wav")
    check("no_pi: the same output level, 0.2 dB", abs(rs - rm) <= 0.024 * max(rs, 1), f"rms {rs:.1f} {rm:.1f}")
    check("no_pi: no fault", not m.faults() and m.rc == 0, "; ".join(m.faults()[:3]))


def t_computer(a):
    r = script_play(Run(a, "computer").overbridge()).go()
    n = [m[4] for m in r.msgs if m[1:4] == b"\x7d\x52\x54"]
    check("computer: Overbridge with no machine: a few hellos at each port-up, nothing else", r.count(0x4f) <= 14 and set(n) <= {0x4f}, f"{len(n)} messages")
    m = re.search(r"usb host: streaming=(\w+) UsbStats \{.*?in_frames: (\d+).*?bad_blocks: (\d+)", r.log)
    check("computer: the stream runs clean", m and m.group(1) == "true" and int(m.group(2)) > 48000 and m.group(3) == "0", m.group(0)[:100] if m else "no stream line")


def seq4(a, name, strict=False):
    r = Run(a, name, strict=strict).overbridge()
    for t, steps in ((1, 1), (2, 2), (3, 3), (4, 4)):
        r.machine(t, steps)
    for t, st in ((1, (1, 9)), (2, (5, 13)), (3, (3, 11)), (4, (7, 15))):
        r.key(f"TRACK{t}", 100).key("RECORD", 100)
        for s in st:
            r.key(f"T{s}", 60)
        r.key("RECORD", 100)
    return r


def t_seq(a):
    r = seq4(a, "seq").key("PLAY", 1800).key("STOP", 300).go()
    tr = [m for m in r.msgs if m[4] == 4]
    v = sorted({m[5] & 7 for m in tr})
    flags = {m[5] & 7: m[5] & 0x78 for m in tr}
    check("seq: the sequencer's trigs on all four tracks, each its machine", v == [0, 1, 2, 3] and flags == {0: 0x00, 1: 0x08, 2: 0x10, 3: 0x48}, f"{len(tr)} trigs, flags {flags}")
    check("seq: a note-off for each, within one", abs(r.count(0x11) - len(tr)) <= 4, f"{r.count(0x11)} offs, {len(tr)} trigs")
    gaps = {}
    last = {}
    voices = iter(m for m in r.msgs if m[4] in (3, 4))
    for c, k in r.sent():
        if k not in (3, 4):
            continue
        m = next(voices, None)
        if m is None or k != 3:
            if m is not None:
                last[m[5] & 7] = c
            continue
        v_ = m[5] & 7
        if v_ in last:
            gaps[v_] = min(gaps.get(v_, 1 << 60), c - last[v_])
        last[v_] = c
    g = min(gaps.values()) / 200000 if gaps else 0
    check("seq: a voice's parameters at most every 10.7 ms", g >= 10.0, f"smallest 03 gap {g:.2f} ms")
    secs = (r.t - 4000) / 200
    check("seq: no fault", not r.faults() and r.rc == 0, f"{len(r.msgs)} messages in {secs:.0f} s; " + "; ".join(r.faults()[:3]))


def t_strict(a):
    r = seq4(a, "strict", strict=True).key("PLAY", 800).key("STOP", 200).go(extra=["--every", "1G"])
    check("strict: DTEMU_STRICT, unmapped pages trap, no fault", not r.faults() and r.rc == 0, "; ".join(r.faults()[:3]))


def t_params(a):
    r = Run(a, "params").overbridge().machine(2, 1)
    r.key("TRACK2", 120).turn(7, 1, 200).key("OSC1", 10)       # OSC1 SPD on T2
    r.go()
    p = [m for m in r.msgs if m[4] == 3 and m[5] & 7 == 1]
    vals = [m[6 + 2 * 2] for m in p]                           # P3
    check("params: T2's SPD moves voice 1's P3", p and max(vals) - min(vals) >= 3, f"P3 {min(vals) if vals else None}..{max(vals) if vals else None} in {len(p)} reports")
    check("params: voice 0 silent", not [m for m in r.msgs if m[4] in (3, 4) and m[5] & 7 == 0])


def t_noread(a):
    r = seq4(a, "stall")
    t0 = r.t + 200
    r.key("PLAY", 1600).key("STOP", 200)
    r.go(extra=["--usb-host-noread", f"{t0}M:{t0 + 600}M"])
    frames = re.findall(r"frames=(\d+)", r.log)
    check("stall: a host that stops reading MIDI for 3 s: the OS runs on, no fault", not r.faults() and r.rc == 0 and len(frames) > 4, f"status lines {len(frames)}")
    check("stall: reports come back after it", r.count(0x04) >= 2, f"{r.count(0x04)} trigs, {r.count(0x03)} params")


def t_gone(a):
    r = seq4(a, "gone")
    t0 = r.t + 100
    r.key("PLAY", 1600).key("STOP", 200)
    r.go(extra=["--usb-host-gone", f"{t0}M:{t0 + 300}M"])
    check("gone: the host browns out and comes back: no fault, hellos again", not r.faults() and r.rc == 0 and r.count(0x4f) >= 2, f"{r.count(0x4f)} hellos, {r.count(4)} trigs")


def t_stock_after(a):
    """Machines on, power off on the mod; stock boots that state; the mod finds its machines again."""
    r = Run(a, "pow1").machine(1, 2).machine(2, 1)
    r.go(extra=["--power-off", f"{r.t + 100}M"], tail=800)
    check("power: the mod's power-off", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))
    s = Run(a, "pow2", syx=a.stock, usb=False, card=r.card)
    s.t = 4000
    s.key("TRACK1").key("TRACK2").midi("903c64", 100).midi("803c00", 100).go()
    check("power: stock 1.56 boots the mod's working state, plays, no fault", s.rc == 0 and not s.faults(), "; ".join(s.faults()[:2]))
    m = Run(a, "pow3", card=r.card)
    m.t = 4000
    m.midi("903c64", 100).midi("803c00", 100).midi("913c64", 100).midi("813c00", 100).go()
    tr = {x[5] & 7: x[5] & 0x78 for x in m.msgs if x[4] == 4}
    check("power: the mod again: the machines kept", tr == {0: 0x08, 1: 0x00}, str(tr))


TESTS = {"no_pi": t_no_pi, "computer": t_computer, "seq": t_seq, "strict": t_strict, "params": t_params, "stall": t_noread, "gone": t_gone, "power": t_stock_after}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--emu", required=True); ap.add_argument("--stock", required=True); ap.add_argument("--syx", required=True)
    ap.add_argument("--card", required=True); ap.add_argument("--out", required=True); ap.add_argument("names", nargs="*")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    for n in a.names or TESTS:
        print(n, flush=True)
        TESTS[n](a)
    bad = [n for n, ok in RESULTS if not ok]
    print(f"{'PASS' if not bad else 'FAIL'}: {len(RESULTS) - len(bad)}/{len(RESULTS)}")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
