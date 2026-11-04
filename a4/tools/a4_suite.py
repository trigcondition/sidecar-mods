#!/usr/bin/env python3
"""The mod's suite in the emulator: analog-emu's dtboot, the firmware's own USB stack. Nothing here talks to a unit.

    a4_suite.py --emu DIR --stock STOCK.syx --syx OS.syx --card IMG --out DIR [--engine SIDECAR_FIRMWARE] [names...]

Firmware-derived outputs stay in --out. Exit 0 when every test passes."""
import argparse, hashlib, os, re, shutil, subprocess, sys, time, wave, struct, zlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from decode import messages

RESULTS = []
PORT = 7345
TITLE_PLTS_HRM = "ffe3ff35a4e2"


def check(name, ok, detail=""):
    RESULTS.append((name, bool(ok)))
    print(f"  {'PASS' if ok else 'FAIL'}  {name}   [{detail}]", flush=True)


class Run:
    """One dtboot run, a key script with times in M instructions."""
    def __init__(self, a, name, syx=None, usb=True, strict=False, card=None, env=None, host=None):
        self.a, self.name, self.host, self.old = a, name, host, None        # host: the real engine on the link, these extra arguments
        self.port, self.ob = a.port, False
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
        self.ob = True
        self.key("GLOBAL", 200)
        for _ in range(10):
            self.key("DOWN", 80)
        self.key("YES", 250).key("DOWN", 100).key("YES", 250).key("UP", 100).key("YES", 250)
        for _ in range(3):
            self.key("NO", 200)
        return self

    def machine(self, track, steps):
        """TRACKn on the OSC1 page, OSC1 to NOISE, knob D, back to OSC1."""
        self.key(f"TRACK{track}", 120).key("OSC1", 150)
        self.nudge(3, 1 if steps > 0 else -1, 120 if self.ob else 60, abs(steps))     # the list's own gap, 60 ms, is in blocks: on the stream the emulator gives far fewer of them a clock
        return self.key("OSC1", 150)

    def os2(self, up=True):
        """From the OSC1 page: NOISE, knob F, back."""
        return self.key("OSC1", 150).nudge(5, 1 if up else -1, 60, 1).key("OSC1", 150)

    def up_yes(self, hold=300):
        """UP held, then YES: the Sidecar's screen, as on the Rytm. Blocks, not clocks, time the hold: long enough for the emulator on USB."""
        t = self.t
        self.args += ["--press", f"UP@{t}M:{hold}M", "--press", f"YES@{t + hold - 80}M:30M"]
        self.t = t + hold + 30
        return self

    def go(self, extra=None, tail=300):
        env = dict(os.environ, DTBOOT_QUIET_USB="1", DTBOOT_USB_OUT=self.usb_file, DTEMU_USB_SEND_LOG="1", **self.env)
        if self.strict:
            env["DTEMU_STRICT"] = "1"
        cmd = [os.path.join(self.a.emu, "target/release/dtboot"), self.syx, "--card", self.card, "--instr", f"{self.t + tail}M", "--every", "1G",
               "--analog-wav", self.dir + "/out.wav", *self.args, *(extra or [])]
        if self.usb:
            cmd += ["--usb-host", "--usb-midi-real"]
        env["DTBOOT_END_PNG"] = self.dir + "/end.png"
        if self.host is None:
            r = subprocess.run(cmd, capture_output=True, text=True, errors="replace", env=env)
            self.log, self.rc = r.stdout + r.stderr, r.returncode
        else:
            shutil.rmtree(self.dir + "/sc", ignore_errors=True)
            os.makedirs(self.dir + "/sc")
            emu = subprocess.Popen(cmd + ["--ob-link", f"127.0.0.1:{self.port}"], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, errors="replace", env=env)
            time.sleep(1)
            with open(self.dir + "/sidecar.log", "w") as f:
                side = subprocess.Popen([os.path.join(self.old or self.a.engine, "core/build/sidecar_emu"), "--link", f"127.0.0.1:{self.port}", "--card", self.dir + "/sc", *([] if self.old else ["--frame-out", self.dir + "/frame.bin"]), *self.host], stdout=f, stderr=subprocess.STDOUT)
                self.log = emu.communicate()[0]
                self.rc = emu.returncode
                time.sleep(1)
                if side.poll() is None:
                    side.terminate()
                side.wait()
            self.side = open(self.dir + "/sidecar.log").read()
        open(self.dir + "/log.txt", "w").write(self.log)
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
    r = seq4(a, "seq").key("PLAY", 1800).key("STOP", 300).go(tail=2800)   # the default sounds' amps take up to 12 s to close
    tr = [m for m in r.msgs if m[4] == 4]
    v = sorted({m[5] & 7 for m in tr})
    flags = {m[5] & 7: m[5] & 0x78 for m in tr}
    check("seq: the sequencer's trigs on all four tracks, each its machine", v == [0, 1, 2, 3] and flags == {0: 0x00, 1: 0x08, 2: 0x10, 3: 0x48}, f"{len(tr)} trigs, flags {flags}")
    ended = all(any(m[4] == 0x11 and m[5] == vv for m in r.msgs[max(i for i, x in enumerate(r.msgs) if x[4] == 4 and x[5] & 7 == vv):]) for vv in range(4))
    check("seq: every voice's last note ended (a note retrigged inside the amp's tail has no off of its own)", ended, f"{r.count(0x11)} offs, {len(tr)} trigs")
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
    r.key("TRACK2", 120).turn(7, 1, 200).key("OSC1", 10)       # OSC1 PW on T2
    r.go()
    p = [m for m in r.msgs if m[4] == 3 and m[5] & 7 == 1]
    vals = [m[6 + 2 * 2] for m in p]                           # P3
    check("params: T2's PW moves voice 1's P3", p and max(vals) - min(vals) >= 3, f"P3 {min(vals) if vals else None}..{max(vals) if vals else None} in {len(p)} reports")
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


def t_kit(a):
    """A machine on kit 1's T1; LOAD KIT to kit 2: its T1 has none, and the Sidecar hears the kit."""
    r = Run(a, "kit").overbridge().machine(1, 1)
    r.midi("903c64", 100).midi("803c00", 200)
    r.key("KIT", 200).key("DOWN", 120).key("YES", 300).key("DOWN", 120).key("YES", 400).key("NO", 200)
    r.midi("903c64", 100).midi("803c00", 200).go()
    kits = [m[6] for m in r.msgs if m[4] == 0x3b and m[5] == 1 and len(m) == 8]
    check("kit: the kit reported, and its change", len(set(kits)) >= 2, str(kits[:8]))
    check("kit: the machine stays with the sound of the kit it was set in", r.count(4) == 1, f"{r.count(4)} trigs")
    check("kit: no fault", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))


def t_user(a):
    """U5 turned past the end of the list, then the list down from it."""
    r = Run(a, "user").overbridge().machine(1, 30)
    r.midi("903c64", 100).midi("803c00", 100).go()
    q = Run(a, "user1").overbridge().machine(1, 30).key("OSC1", 150).nudge(3, -1, 120, 2).key("OSC1", 150)
    q.midi("903c64", 100).midi("803c00", 100).go()
    tr = [x[5] for x in r.msgs + q.msgs if x[4] == 4]
    check("user: U5 past the end of the list, and back down the user flags", len(tr) == 2 and tr[0] == 0x70 and tr[1] in (0x60, 0x68), str(tr))
    check("user: no fault", r.rc == 0 and not r.faults() and q.rc == 0 and not q.faults(), "; ".join(r.faults()[:2]))


def t_poly(a):
    """KIT > POLY CONFIG, all four voices: a chord on the selected track. The event block is the track's, whichever analog voices play the notes."""
    peek = ",".join(hex(0x80003D80 + 26 * v) for v in range(4))
    r = Run(a, "poly", env={"DTBOOT_PEEK": peek}).overbridge()
    for t, st in ((1, 1), (2, 2), (3, 3), (4, 4)):
        r.machine(t, st)
    r.key("TRACK2", 150).key("KIT", 120)
    for _ in range(5):
        r.key("DOWN", 120)
    r.key("YES", 120)
    for i in range(4):
        r.key("YES", 100)
        if i < 3:
            r.key("RIGHT", 100)
    r.key("NO", 120).key("NO", 120).key("NO", 400)
    t = r.t
    for i, k in enumerate(("KB_C1", "KB_E1", "KB_G1")):
        r.args += ["--press", f"{k}@{t + i * 30}M:500M"]
    r.t += 300
    r.go(extra=["--every", "100M"], tail=500)
    tr = [(x[5], x[6]) for x in r.msgs if x[4] == 4]
    check("poly: a chord on T2: three trigs on T2's event block, with T2's machine", len(tr) == 3 and {x[0] for x in tr} == {0x09}, str(tr))
    open_ = {tuple((int(x, 16) & 0xffff) < 0x7f00 for x in re.findall(r"=([0-9a-f]{8})", l)) for l in r.log.splitlines() if "peek" in l}
    check("poly: while the notes play, on more than one analog voice", any(sum(o) >= 3 and not o[0] for o in open_), str(sorted(open_)[:6]))
    check("poly: no fault", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))


# The screen as text: labels read from the PNG with a font learned from stock's own screens, so no glyph of the firmware's lives here and the mod cannot mark its own work.
def bitmap(p):
    """A PNG of the screen (384 x 192, 8-bit RGB, 3 pixels a dot) as 64 rows of 128 dots."""
    b = open(p, "rb").read()
    w, h = struct.unpack(">II", b[16:24])
    i, z = 8, b""
    while i < len(b):
        n, t = struct.unpack(">I4s", b[i:i + 8])
        if t == b"IDAT":
            z += b[i + 8:i + 8 + n]
        i += n + 12
    raw, st, rows, prev = zlib.decompress(z), w * 3, [], bytes(w * 3)
    for y in range(h):
        f, r = raw[y * (st + 1)], bytearray(raw[y * (st + 1) + 1:(y + 1) * (st + 1)])
        for x in range(st):
            a, c, u = r[x - 3] if x >= 3 else 0, prev[x - 3] if x >= 3 else 0, prev[x]
            pa, pb, pc = abs(u - c), abs(a - c), abs(a + u - 2 * c)
            r[x] = (r[x] + (0, a, u, (a + u) // 2, a if pa <= pb and pa <= pc else u if pb <= pc else c)[f]) & 255
        rows.append(r)
        prev = bytes(r)
    return [[rows[y * 3 + 1][(x * 3 + 1) * 3] > 128 for x in range(w // 3)] for y in range(h // 3)]


def glyphs(bm, c, row):
    """The letters of knob c's label, row 0 or 1, as tuples of columns."""
    y0, x0 = (26, 48)[row], 26 * c
    col = [tuple(bm[y0 + y][x] for y in range(7)) for x in range(x0, min(x0 + 26, 128))]
    out, g = [], []
    for k in col:
        if any(k):
            g.append(k)
        elif g:
            out.append(tuple(g)); g = []
    if g:
        out.append(tuple(g))
    return out


def page_text(p, font):
    """Knobs A..J as strings; a letter stock's screens did not teach reads ?."""
    bm = bitmap(p)
    return ["".join(font.get(g, "?") for g in glyphs(bm, c, r)) for r in (0, 1) for c in range(5)]


STOCK_PAGES = {"OSC1": "TUN FIN DET TRK LEV WAV SUB PW SPD PWM", "OSC2": "AM1 SMD SNC BND SLI AM2 TRG FAD SPD VIB", "FILTERS": "FRQ RES OVR TRK DEP FRQ RES TYP TRK DEP", "AMP": "ATK DEC SUS REL SHP CHO DEL REV PAN VOL"}


def learn_font(a):
    r = Run(a, "font", syx=a.stock, usb=False, env={"DTBOOT_PNG_DIR": os.path.join(a.out, "font"), "DTBOOT_STEPS": "1"})
    r.key("TRACK1").key("OSC2", 150).key("OSC2", 150).key("OSC1", 150).key("FILTERS", 150).key("AMP", 150).go()
    png = lambda k: sorted(f for f in os.listdir(r.dir) if f.endswith(f"_{k}.png"))[-1]
    font = {}
    for key, want in STOCK_PAGES.items():
        bm = bitmap(os.path.join(r.dir, png(key)))
        i = 0
        for row in (0, 1):
            for c in range(5):
                w = want.split()[i]
                i += 1
                g = glyphs(bm, c, row)
                if len(g) == len(w):
                    font.update(zip(g, w))
    return font


# P of each knob A..J (a4_page.c's a4_src_of), 0 a stock knob, and each machine's names (README). The layouts: PLTS DSY U1..U5, JUNO, FM6, MD B2.
OSC1 = {"PLTS": (1, 7, 2, 6, 0, 8, 9, 3, 4, 5), "JUNO": (1, 0, 2, 6, 0, 7, 8, 3, 4, 5), "FM6": (1, 6, 2, 7, 0, 8, 0, 3, 4, 5), "MD": (1, 9, 2, 6, 0, 7, 8, 3, 4, 5)}
NOISE = {"PLTS": (0, 0, 0, 0, 0, 0, 10, 11, 12, 13), "JUNO": (0,) * 10, "FM6": (0,) * 10, "MD": (0, 0, 0, 0, 0, 0, 10, 11, 0, 0)}
OSC2 = {"PLTS": (10, 0, 11, 15, 0, 0, 0, 12, 13, 14), "MD": (10, 0, 11, 0, 0, 0, 0, 0, 0, 0)}
LAYOUT = {"PLTS": "PLTS", "DSY": "PLTS", "U1": "PLTS", "JUNO": "JUNO", "FM6": "FM6", "MD": "MD"}
STEPS = {"PLTS": 1, "JUNO": 2, "DSY": 3, "FM6": 4, "MD": 5, "U1": 8}                  # U1 by the emulator's nudges, which drop a step on the way up to it
OB_STEPS = dict(STEPS, U1=30)                                                         # on the stream: the end of the list, U5, the same layout
STOCK_LABELS = {"osc1": STOCK_PAGES["OSC1"].split(), "osc2": STOCK_PAGES["OSC1"].split(), "x": STOCK_PAGES["OSC2"].split(), "noise": ["SNH", "COL", "FAD", "MCH", "LEV", "OS2", "", "", "", ""]}
NAMES = {"PLTS": "ENG HRM TIM MOR DEC LPG TUN LEV FM FIN AUX TMD MMD VEL GLD", "JUNO": "PAT CUT RES ENV ATK DEC REL LEN", "DSY": "ENG STR BRI DMP INP EXC TUN LEV XTN XDC FB OUT XP4 XLV XP5",
         "FM6": "PAT TIM MOR DEC LPG TUN LEV LEN", "MD": "CT1 CT2 CT3 CT4 CT5 CT6 CT7 CT8 ENG TYP LEV", "U1": "P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15"}
DEFAULTS = {"PLTS": (0, 64, 64, 64, 127, 64, 64, 100, 64, 64, 0, 0, 0, 120, 0), "JUNO": (0, 64, 0, 0, 0, 64, 64, 127), "DSY": (0, 64, 64, 64, 0, 64, 64, 100, 64, 64, 0, 0, 0, 120, 0),
            "FM6": (0, 64, 64, 127, 64, 64, 100, 127), "MD": (64,) * 8 + (0, 0, 100), "U1": (64,) * 15}


def knobs_of(machine, page, os2=False):
    """P of each knob, 0 none; None: the page is stock's."""
    l = LAYOUT[machine]
    if page == "osc1":
        return OSC1[l]
    if page == "noise":
        return (0,) * 10 if os2 else NOISE[l]
    if page == "osc2" and os2 and l in OSC2:
        return OSC2[l]
    if page == "x":                                                       # AM1: NOISE J's id, on its stock page too
        return (0 if os2 else NOISE[l][9],) + (0,) * 9
    return None


def to_page(r, page):
    """From the OSC1 page, which machine() ends on, to a page, by stock's own keys."""
    {"osc1": lambda: None, "noise": lambda: r.key("OSC1", 150), "osc2": lambda: r.key("OSC2", 150), "x": lambda: r.key("OSC2", 150).key("OSC2", 150)}[page]()
    return r


def want_labels(machine, page, os2=False):
    """The machine's names; LEV stays stock's, OSC 1&2 stock's but AM1 where NOISE J holds it; knobs the machine leaves empty are hatched."""
    n = NAMES[machine].split()
    ps = knobs_of(machine, page, os2)
    stock = STOCK_LABELS[page]
    if page == "x":
        return [n[ps[0] - 1] if ps[0] else stock[0]] + stock[1:]
    if ps is None:
        return list(stock)
    if page == "noise":
        w = list(stock)
        for i, p in enumerate(ps):
            if p:
                w[i] = n[p - 1]
        if machine in ("JUNO", "FM6"):
            w[5] = ""
        return w
    return [n[p - 1] if p else s if s == "LEV" else "" for p, s in zip(ps, stock)]


def same(got, want):
    """A letter stock did not teach passes as ?; O is 0's glyph; an empty knob is hatched, no glyph of the font."""
    if not want:
        return set(got) <= {"?"}
    want = want.replace("0", "O")
    return len(got) == len(want) and all(g == w or (g == "?" and w != "?") for g, w in zip(got, want))


def t_labels(a):
    font = learn_font(a)
    check("labels: stock's screens teach enough letters", len(font) >= 20, "".join(sorted(font.values())))
    for machine, steps in STEPS.items():
        for page in ("osc1", "noise", "osc2", "x"):
            r = to_page(Run(a, f"lab_{machine}_{page}", usb=False).machine(1, steps), page).go()
            got, want = page_text(r.dir + "/end.png", font), want_labels(machine, page)
            ok = all(same(g, w) for g, w in zip(got, want))
            check(f"labels: {machine} on {page}", ok and r.rc == 0 and not r.faults(), " ".join(x or "-" for x in got))
        if machine in ("JUNO", "FM6"):
            continue
        for page in ("noise", "osc2"):
            r = to_page(Run(a, f"lab_{machine}_{page}2", usb=False).machine(1, steps).os2(), page).go()
            got, want = page_text(r.dir + "/end.png", font), want_labels(machine, page, True)
            check(f"labels: {machine} on {page}, OS2 MACHINE", all(same(g, w) for g, w in zip(got, want)) and r.rc == 0 and not r.faults(), " ".join(x or "-" for x in got))


def t_title(a):
    """A turn's title and value: the machine's, on stock's the long name and tuning. The SIDECAR knob's own label."""
    r = Run(a, "title", usb=False).machine(1, 1).turn(2, -1, 30, every="3M", gap=100).go(tail=50)
    s = Run(a, "title_s", syx=a.stock, usb=False).key("TRACK1", 120).key("OSC2", 150).key("OSC1", 150).turn(2, -1, 30, every="3M", gap=100).go(tail=50)
    bm, bs = bitmap(r.dir + "/end.png"), bitmap(s.dir + "/end.png")
    h = hashlib.sha256(str([x[:68] for x in bm[:9]]).encode()).hexdigest()[:12]
    check("title: a turned knob's title says PLTS HRM (the band's hash, read by eye once)", h == TITLE_PLTS_HRM, h)
    check("title: not stock's", bm[:9] != bs[:9])
    check("title: its value is the number the machine reads, not stock's", glyphs(bm, 2, 0) != glyphs(bs, 2, 0))
    font = learn_font(a)
    q = Run(a, "side", usb=False).key("TRACK1", 120).key("OSC1", 150).go()
    check("title: the selector's label is its own", page_text(q.dir + "/end.png", font)[3][0] == "M" and page_text(q.dir + "/end.png", font)[3][2] == "H", page_text(q.dir + "/end.png", font)[3])


def noise_same(p, q):
    """Two NOISE screens: equal, apart from the two knobs an OFF track has more than stock's: D MCH, F OS2. The band over them and the rest of the page are stock's."""
    a, b = bitmap(p), bitmap(q)
    def rest(x):
        return [[v for i, v in enumerate(row) if not (9 <= y < 31 and 78 <= i < 104) and not (31 <= y < 53 and i < 26)] for y, row in enumerate(x)]
    return rest(a) == rest(b)


def t_off(a):
    """Every sound OFF, and a track OFF beside one with a machine: the screens step by step as stock's, a turned knob's title and value too; on NOISE all but its two knobs."""
    def script(r, track):
        r.key(f"TRACK{track}", 120).key("OSC2", 150).key("OSC2", 150).key("OSC1", 150).key("FILTERS", 150).key("AMP", 150).key("OSC2", 150).key("OSC1", 150)
        return r.turn(2, -1, 30, every="3M", gap=100).key("OSC1", 150).turn(1, 1, 30, every="3M", gap=100)
    def shots(r):
        return [os.path.join(r.dir, f) for f in sorted(os.listdir(r.dir)) if f.startswith("step") and f.endswith(".png")] + [r.dir + "/end.png"]
    env = lambda n: {"DTBOOT_PNG_DIR": os.path.join(a.out, n), "DTBOOT_STEPS": "1"}
    s = script(Run(a, "off_s", syx=a.stock, usb=False, env=env("off_s")), 1).go(tail=50)
    m = script(Run(a, "off_m", usb=False, env=env("off_m")), 1).go(tail=50)
    x, y = shots(s), shots(m)
    check("off: every sound OFF: each screen as stock's", [sha(p) for p in x[:-2]] == [sha(p) for p in y[:-2]] and len(x) >= 8, f"{len(x)} screens, {sum(sha(p) != sha(q) for p, q in zip(x[:-2], y[:-2]))} differ")
    check("off: its NOISE page is stock's but for D and F, a stock knob's turn too", all(noise_same(p, q) for p, q in zip(x[-2:], y[-2:])) and sha(x[-1]) != sha(y[-1]), "")
    s2 = script(Run(a, "off_s2", syx=a.stock, usb=False, env=env("off_s2")), 2).go(tail=50)
    m2 = script(Run(a, "off_m2", usb=False, env=env("off_m2")).machine(1, 1), 2).go(tail=50)
    x2, y2 = shots(s2), shots(m2)[-len(shots(s2)):]
    check("off: T2 OFF beside T1 with a machine: its screens as stock's", [sha(p) for p in x2[:-2]] == [sha(p) for p in y2[:-2]], f"{len(x2)} screens, {sum(sha(p) != sha(q) for p, q in zip(x2[:-2], y2[:-2]))} differ")
    check("off: and its NOISE page, but for D and F", all(noise_same(p, q) for p, q in zip(x2[-2:], y2[-2:])), "")


def reports(r, voice=0):
    """(time in M, [P1..P15 as 14 bits]) of a voice's 03 reports."""
    it, out = iter(m for m in r.msgs if m[4] in (3, 4)), []
    for c, k in r.sent():
        if k in (3, 4):
            m = next(it, None)
            if m is not None and m[4] == 3 and m[5] & 7 == voice:
                out.append((c / 1e6, [h * 128 + l for h, l in zip(m[6::2][:15], m[7::2][:15])]))
    return out


def sweep(a, name, machine, page, os2=False):
    """Each knob of a page down and up: (run, [(knob, P's that moved, lo, hi)])."""
    ps = knobs_of(machine, page, os2) or (0,) * 10
    r = Run(a, name).overbridge().machine(1, OB_STEPS[machine])
    if os2:
        r.os2()
    to_page(r, page)
    win = []
    cells = [e for e in range(10) if not (page == "noise" and e in (3, 5))]             # not the selector and OS2
    for e in cells:
        t0 = r.t
        r.turn(e, -1, 500, gap=200).turn(e, 1, 500, gap=200)
        win.append((t0, r.t))
    r.go(tail=100)
    rep, bad, full = reports(r), [], True
    for e, (t0, t1) in zip(cells, win):
        w = [v for c, v in rep if t0 <= c < t1]
        moved = {k + 1 for k in range(15) if k != 1 and len({x[k] for x in w}) > 1}      # P2 is DET's, which this kit's LFO runs
        if ps[e] == 2:
            moved |= {2}
        if page == "osc1" and e == 0:                                                 # the word glides under TUN, stock's slew: FIN's P wobbles and comes back (t_fin)
            moved -= {ps[1]}
        want = {ps[e]} - {0}
        if moved != want:
            bad.append((e, sorted(moved), sorted(want)))
        if ps[e]:
            lo, hi = min((x[ps[e] - 1] for x in w), default=-1), max((x[ps[e] - 1] for x in w), default=-1)
            if not (0 <= lo <= 128 and hi >= 16256):
                full, bad = False, bad + [(e, lo / 128, hi / 128)]
    return r, rep, win, bad, full


def t_knobs(a):
    """Each knob the machine reads moves its P and no other, over 0..127; each stock knob none. The kit's own LFO on OSC1 DET runs through P2: proof that an LFO reaches a P."""
    for page in ("osc1", "noise", "osc2", "x"):
        r, rep, win, bad, full = sweep(a, "knob_" + page, "PLTS", page)
        check(f"knobs: {page}: each knob moves its P, 0..127", not bad and full and rep, str(bad[:4]))
        if page == "osc1":
            lfo = [v[1] for c, v in rep if c < win[0][1]]
            check("knobs: an LFO moves its P (this kit's LFO 2 on DET)", len(set(lfo)) > 20, f"P2 {min(lfo) / 128:.1f}..{max(lfo) / 128:.1f}")


def t_map(a):
    """Decision 8, 10: every layout's knobs on their P, 0..127, the P's meaning the machine's: the numbers of the table, in the 03s."""
    for machine, page, os2 in (("JUNO", "osc1", 0), ("JUNO", "noise", 0), ("FM6", "osc1", 0), ("FM6", "noise", 0), ("MD", "osc1", 0), ("MD", "noise", 0), ("MD", "osc2", 1), ("PLTS", "osc2", 1), ("DSY", "osc1", 0), ("U1", "noise", 0)):
        r, rep, win, bad, full = sweep(a, f"map_{machine}_{page}{os2}", machine, page, bool(os2))
        check(f"map: {machine} {page}{' OS2 MACHINE' if os2 else ''}: each knob on its P, 0..127", not bad and full and rep, str(bad[:4]))


def t_zones(a):
    """TUN turned slowly from end to end: every one of PLAITS' 17 ENG zones (core/machines.h eng_zone) reported, in order."""
    r = Run(a, "zones").overbridge().machine(1, 1).key("OSC2", 150).key("OSC1", 150).turn(0, -1, 500, gap=200)
    t = r.t
    r.turn(0, 1, 1000, every="1M", gap=1050).go(tail=100)
    z = [min(int(v[0] / 128) * 17 >> 7, 16) for c, v in reports(r) if c > t]
    check("zones: PLAITS ENG reaches all 17 engines, stepping up", sorted(set(z)) == list(range(17)) and z == sorted(z), f"{len(set(z))} zones, {len(z)} reports")


def t_fin(a):
    """TUN and FIN are one word: as a machine's two parameters each keeps to its byte, each over 0..127, and a plain 0 at the bottom: a list's first entry needs no second knob."""
    r = Run(a, "fin").overbridge().machine(1, 1).turn(1, -1, 500, gap=200).turn(0, -1, 500, gap=200)
    t0 = r.t
    r.turn(1, 1, 500, gap=200)
    t1 = r.t
    r.turn(0, 1, 500, gap=200)
    t2 = r.t
    r.turn(1, -1, 500, gap=200).go(tail=100)
    rp = reports(r)
    down = [v for c, v in rp if c < t0][-1]
    a0 = [v for c, v in rp if t0 <= c < t1]
    b0 = [v for c, v in rp if t1 <= c < t2]
    c0 = [v for c, v in rp if c >= t2]
    check("fin: TUN down: P1 0", down[0] == 0, str(down[0]))
    check("fin: FIN up: P7 to 127, P1 stays", a0[-1][6] >= 16256 and {x[0] for x in a0} == {0}, f"P7 {a0[-1][6] / 128}, P1 {sorted({x[0] for x in a0})[:3]}")
    check("fin: TUN up: P1 to 127, P7 back where it was: the voice's word glides meanwhile, stock's own slew", b0[-1][0] == 16256 and b0[-1][6] == a0[-1][6], f"P1 {b0[-1][0] / 128}, P7 {b0[-1][6] / 128}")
    check("fin: FIN down: P7 to 0, P1 stays", c0[-1][6] <= 64 and {x[0] for x in c0} == {16256}, f"P7 {c0[-1][6] / 128}")


def cell(bm, c):
    """Knob c's square of the page, A..J, its name under it: no title band."""
    y0, x0 = (9, 31)[c // 5], 26 * (c % 5)
    return [r[x0:x0 + 26] for r in bm[y0:y0 + 22]]


def t_hatched(a):
    """The knobs a machine has no use for are stock's own empty knob: the very pixels of stock's NOISE page's empty ones, with nothing behind them."""
    s = Run(a, "h_stock", syx=a.stock, usb=False).key("TRACK1", 120).key("OSC1", 150).go(tail=50)
    empty = bitmap(s.dir + "/end.png")
    ref = lambda c: 5 + c % 5 if c < 5 and c != 3 else c                # D, F..J empty there; the others by their column
    for machine, os2, page, knobs in (("JUNO", 0, "osc1", (1,)), ("FM6", 0, "osc1", (6,)), ("JUNO", 0, "noise", (5, 6, 7, 8, 9)), ("MD", 0, "noise", (8, 9)), ("PLTS", 1, "noise", (6, 7, 8, 9)), ("PLTS", 1, "osc2", (1, 4 + 1, 6)), ("MD", 1, "osc2", (1, 3, 5, 6, 7, 8, 9))):
        r = Run(a, f"h_{machine}_{page}{os2}", usb=False).machine(1, STEPS[machine])
        if os2:
            r.os2()
        r = to_page(r, page).go(tail=50)
        bm = bitmap(r.dir + "/end.png")
        bad = [c for c in knobs if cell(bm, c) != cell(empty, ref(c))]
        check(f"hatched: {machine} on {page}: stock's empty knob", not bad and r.rc == 0 and not r.faults(), str(bad))
    def script(name, turn):
        r = Run(a, name).overbridge().machine(1, 2)                      # JUNO, on OSC1: knob B, FIN, empty
        if turn:
            r.turn(1, 1, 40, every="3M", gap=150)
        else:
            r.t += 150
        return r
    r = script("h_idle", False).go(tail=100)
    q = script("h_turn", True).go(tail=100)
    check("hatched: turned knobs: the screen stays, no title, no value", sha(r.dir + "/end.png") == sha(q.dir + "/end.png"), f"{sha(r.dir + '/end.png')} {sha(q.dir + '/end.png')}")
    x, y = [v for c, v in reports(r)][-1:], [v for c, v in reports(q)][-1:]
    check("hatched: turned knobs: the machine's values stay", [v[:1] + v[2:] for v in x] == [v[:1] + v[2:] for v in y] and x, str(len(reports(q))))
    def off(name, turn):                                                  # what it would have changed: back to OFF, and the page is the same
        r = Run(a, name, usb=False).machine(1, 2)
        if turn:
            r.turn(1, 1, 40, every="3M", gap=150)
        r.key("OSC1", 150).nudge(3, -1, 60, 3).key("OSC1", 150)
        return r.go(tail=50)
    u, v = off("h_off0", False), off("h_off1", True)
    check("hatched: a turn left the sound as it was: FIN unchanged once back OFF", sha(u.dir + "/end.png") == sha(v.dir + "/end.png"), f"{sha(u.dir + '/end.png')} {sha(v.dir + '/end.png')}")
    l0 = Run(a, "h_lev0", usb=False).machine(1, 4).go(tail=50)
    l1 = Run(a, "h_lev1", usb=False).machine(1, 4).turn(4, 1, 40, every="3M", gap=100).go(tail=50)
    b0, b1 = bitmap(l0.dir + "/end.png"), bitmap(l1.dir + "/end.png")
    check("hatched: LEV stays alive on a machine: its turn shows title and value", b0[:9] != b1[:9] and cell(b0, 4) != cell(b1, 4), "")
    m = Run(a, "h_t2").machine(1, 2).key("TRACK2", 150).go(tail=50)
    t = Run(a, "h_t2s", syx=a.stock).key("TRACK1", 120).key("OSC1", 150).key("OSC1", 150).key("TRACK2", 150).go(tail=50)
    check("hatched: TRACK2 OFF, on the same page after a machine's T1: stock's screen", sha(m.dir + "/end.png") == sha(t.dir + "/end.png"), f"{sha(m.dir + '/end.png')} {sha(t.dir + '/end.png')}")
    def kit(r):
        return r.key("KIT", 200).key("DOWN", 120).key("YES", 300).key("DOWN", 120).key("YES", 400).key("NO", 200).go(tail=100)
    m = kit(Run(a, "h_kit").machine(1, 2))
    t = kit(Run(a, "h_kits", syx=a.stock).key("TRACK1", 120).key("OSC1", 150).key("OSC1", 150))
    check("hatched: a kit with no machine loaded with the page open: stock's screen", sha(m.dir + "/end.png") == sha(t.dir + "/end.png"), f"{sha(m.dir + '/end.png')} {sha(t.dir + '/end.png')}")
    p = Run(a, "h_pow").machine(1, 2)
    p.go(extra=["--power-off", f"{p.t + 100}M"], tail=800)
    b = Run(a, "h_boot", card=p.card).go(tail=300)
    bm = bitmap(b.dir + "/end.png")
    check("hatched: on the page a boot opens, no key pressed", b.rc == 0 and not b.faults() and cell(bm, 1) == cell(empty, 6), "; ".join(b.faults()[:2]))


def t_lock(a):
    """A parameter lock on a trig: hold the trig, turn HRM: the step's report carries it, the track's own value stays."""
    r = Run(a, "lock").overbridge().machine(1, 1).key("OSC2", 150).key("OSC1", 150)
    r.turn(7, -1, 300, gap=120).key("RECORD", 100).key("T1", 100).key("T9", 100)
    r.args += ["--press", f"T9@{r.t}M:300M"]
    r.t += 100
    r.turn(7, 1, 40, every="3M", gap=220)
    r.key("RECORD", 100).key("PLAY", 1200).key("STOP", 200).go()
    tr = [m[8 + 2 * 2] for m in r.msgs if m[4] == 4 and m[5] & 7 == 0]
    check("lock: a locked trig moves TIM (knob H, P3); the others keep the track's 0", 0 < sum(x > 0 for x in tr) < len(tr), str(tr))


def voice_words(r, *words):
    """Words of the OS to peek in a run: its env."""
    r.env["DTBOOT_PEEK"] = ",".join(hex(w & ~3) for w in words)
    return r


def peeked(r, w):
    """That word at each --every line, 16 bits."""
    out = []
    for l in r.log.splitlines():
        m = re.findall(r"\[([0-9a-f]{8})\]=([0-9a-f]{8})", l)
        for x, y in m:
            if int(x, 16) == w & ~3:
                v = int(y, 16)
                out.append(v >> 16 & 0xFFFF if not w & 2 else v & 0xFFFF)
    return out


def t_pages(a):
    """Decision 4: the OSC1 key cycles OSC1, NOISE; the selector on NOISE, D; no SIDECAR page; the two knobs on an OFF track, the rest of NOISE stock's."""
    font = learn_font(a)
    env = lambda n: {"DTBOOT_PNG_DIR": os.path.join(a.out, n), "DTBOOT_STEPS": "1"}
    r = Run(a, "pg", usb=False, env=env("pg")).key("TRACK1", 120)
    for _ in range(5):
        r.key("OSC1", 150)
    r.go(tail=50)
    c = [sha(os.path.join(r.dir, f)) for f in sorted(os.listdir(r.dir)) if f.startswith("step") and f.endswith("_OSC1.png")]
    check("pages: the OSC1 key cycles two pages", len(c) == 5 and len(set(c)) == 2 and c[0] == c[2] == c[4] and c[1] == c[3], str(c))
    n = Run(a, "pg_n", usb=False).key("TRACK1", 120).key("OSC1", 150).go(tail=50)
    got = page_text(n.dir + "/end.png", font)
    s = Run(a, "pg_s", syx=a.stock, usb=False).key("TRACK1", 120).key("OSC1", 150).go(tail=50)
    check("pages: OFF: MCH on D, OS2 on F", same(got[3], "MCH") and same(got[5], "OS2"), " ".join(x or "-" for x in got))
    check("pages: OFF: the rest of NOISE is stock's", noise_same(n.dir + "/end.png", s.dir + "/end.png"), "")
    m = Run(a, "pg_m").overbridge().key("TRACK1", 120).key("OSC1", 150).nudge(3, 1, 60, 1).midi("903c64", 100).midi("803c00", 100).go(tail=100)
    check("pages: knob D picks: the trig reports PLAITS", [x[5] for x in m.msgs if x[4] == 4] == [0], str([x[5] for x in m.msgs if x[4] == 4]))
    k = Run(a, "pg_k", usb=False).key("TRACK1", 120).key("OSC1", 150).nudge(0, 1, 40, 5).nudge(1, 1, 40, 5).go(tail=50)
    t = Run(a, "pg_t", syx=a.stock, usb=False).key("TRACK1", 120).key("OSC1", 150).nudge(0, 1, 40, 5).nudge(1, 1, 40, 5).go(tail=50)
    check("pages: OFF: SNH, COL turned as stock's", noise_same(k.dir + "/end.png", t.dir + "/end.png"), "")


def t_analog2(a):
    """Decision 2: with a machine, OS2 ANALOG: OSC2's and NOISE's stock knobs are back, none hatched, none feeds a P, on OSC 1&2 too."""
    for page, cells in (("osc2", range(10)), ("x", range(1, 10))):
        r = to_page(Run(a, f"an_{page}", usb=False).machine(1, 1), page).go(tail=50)
        s = to_page(Run(a, f"an_{page}s", syx=a.stock, usb=False).key("TRACK1", 120).key("OSC2", 150).key("OSC1", 150), page).go(tail=50)
        bm, bs = bitmap(r.dir + "/end.png"), bitmap(s.dir + "/end.png")
        bad = [c for c in cells if cell(bm, c) != cell(bs, c)]
        check(f"analog2: {page}: stock's knobs, stock's pixels", not bad, str(bad))
    q = sweep(a, "an_col", "PLTS", "noise")
    check("analog2: NOISE A..C and E move no P (BND, SLI, FAD, COL, FAD are analog again)", not q[3] and q[4], str(q[3][:4]))


def t_os2(a):
    """Decision 3: OS2 MACHINE gives OSC2's page to the machine; JUNO, FM6 have nothing to give and hide the knob; back to ANALOG: stock's knobs."""
    font = learn_font(a)
    r, rep, win, bad, full = sweep(a, "os2_m", "PLTS", "osc2", True)
    check("os2: MACHINE: P10..P15 on OSC2 TUN DET PW SPD PWM TRK, 0..127", not bad and full and rep, str(bad[:4]))
    r = Run(a, "os2_j", usb=False).machine(1, 1).os2().key("OSC1", 150).nudge(3, 1, 60, 1).key("OSC2", 150).go(tail=50)
    s = Run(a, "os2_js", usb=False).machine(1, 2).key("OSC2", 150).go(tail=50)
    check("os2: set, then JUNO: OSC2 stays stock's", bitmap(r.dir + "/end.png") == bitmap(s.dir + "/end.png"), "")
    b = Run(a, "os2_b", usb=False).machine(1, 1).os2().key("OSC2", 150).turn(3, 1, 500, gap=200).key("OSC1", 150).key("OSC1", 150).nudge(5, -1, 60, 1).key("OSC2", 150).go(tail=50)
    t = Run(a, "os2_bs", usb=False).machine(1, 1).key("OSC2", 150).go(tail=50)
    c = page_text(b.dir + "/end.png", font)
    check("os2: back to ANALOG: OSC2's stock labels, TRK back in stock's range", same(c[3], "TRK") and cell(bitmap(b.dir + "/end.png"), 3)[:12] == cell(bitmap(t.dir + "/end.png"), 3)[:12], " ".join(c))
    f = Run(a, "os2_f", usb=False).machine(1, 1).os2().go(tail=50)
    q = Run(a, "os2_p").overbridge().machine(1, 1).midi("903c64", 100).midi("803c00", 100).os2().midi("903c64", 100).midi("803c00", 100).go(tail=50)
    tr = [[x[8 + 2 * i] for i in range(15)] for x in q.msgs if x[4] == 4]
    check("os2: the 04s change sources with it: P14 VEL default 120 in ANALOG, OSC2 PWM's 0 in MACHINE", len(tr) == 2 and tr[0][13] == 120 and tr[1][13] == 0, str([t_[9:] for t_ in tr]))


def t_pick(a):
    """Decision 7: a pick from OFF writes the machine's defaults and OSC1 LEV 0; one machine to another writes nothing; a pick to OFF recentres PM and FM, and TRK WAV SUB AM1 go back into stock's range."""
    for machine, steps in OB_STEPS.items():
        r = voice_words(Run(a, f"pk_{machine}").overbridge(), 0x80005B38)
        r.machine(1, steps).midi("903c64", 100).midi("803c00", 100).go(extra=["--every", "200M"], tail=60)
        tr = [[x[8 + 2 * i] for i in range(15)] for x in r.msgs if x[4] == 4]
        d = list(DEFAULTS[machine])
        ok = tr and all(tr[0][i] == d[i] for i in range(len(d)) if i != 1)
        check(f"pick: {machine}: the defaults in the trig's P (P2 under this kit's LFO)", ok, str(tr[:1]))
        lev = peeked(r, 0x80005B38)
        check(f"pick: {machine}: OSC1 LEV 0", lev and lev[-1] == 0, str(lev[-1:]))
    r = Run(a, "pk_mm").overbridge().machine(1, 1).turn(7, 1, 300, gap=120).key("OSC1", 150).nudge(3, 1, 60, 1).key("OSC1", 150).midi("903c64", 100).midi("803c00", 100).go(tail=60)
    tr = [[x[8 + 2 * i] for i in range(15)] for x in r.msgs if x[4] == 4]
    check("pick: PLTS to JUNO: no defaults, the turned P3 stays", tr and tr[0][2] == 127, str(tr[:1]))
    r = voice_words(Run(a, "pk_off").overbridge(), 0x80005B68, 0x80005B78, 0x80005C08).machine(1, 1).key("OSC1", 150)
    r.turn(6, 1, 300, gap=120).turn(7, -1, 300, gap=120).turn(8, 1, 300, gap=120)
    t = r.t
    r.nudge(3, -1, 60, 2)
    r.go(extra=["--every", "100M"], tail=100)
    pm, fm = peeked(r, 0x80005B68), peeked(r, 0x80005B78)
    i = int(t // 100) - 2
    check("pick: PM1, FM1 moved on the machine", pm[i] != 0x4000 and fm[i] != 0x4000, f"{pm[i]:04x} {fm[i]:04x}")
    check("pick: to OFF: PM1, FM1 centre", pm[-1] == 0x4000 and fm[-1] == 0x4000, f"{pm[-1]:04x} {fm[-1]:04x}")
    ac = peeked(r, 0x80005C08)
    check("pick: to OFF: ACC back to stock's 8192", ac[-1] == 0x2000 and ac[i] != 0x2000, f"{ac[i]:04x} {ac[-1]:04x}")
    o = Run(a, "pk_st", usb=False).machine(1, 1).turn(3, 1, 500, gap=200).turn(5, 1, 500, gap=200).turn(6, 1, 500, gap=200).key("OSC1", 150).nudge(3, -1, 60, 2).key("OSC1", 150).go(tail=50)
    w = voice_words(Run(a, "pk_st2", usb=False), 0x80005E78, 0x80005E88, 0x80005E98).machine(1, 1).turn(3, 1, 500, gap=200).turn(5, 1, 500, gap=200).turn(6, 1, 500, gap=200).key("OSC1", 150).nudge(3, -1, 60, 2).go(extra=["--every", "100M"], tail=60)
    v = [peeked(w, x)[-1] for x in (0x80005E78, 0x80005E88, 0x80005E98)]
    check("pick: to OFF: TRK, WAV, SUB back in stock's range", v[0] <= 0x100 and v[1] <= 0x700 and v[2] <= 0x400, str([hex(x) for x in v]))
    check("pick: no fault", o.rc == 0 and not o.faults() and w.rc == 0, "")


LOCKS = ((1, "osc1", 2, 7, 127), (2, "osc1", 3, 2, 127), (3, "osc1", 4, 6, 127), (5, "osc1", 5, 8, 127), (6, "osc1", 6, 9, 127), (7, "osc1", 7, 3, 127), (8, "osc1", 8, 4, 127), (9, "osc1", 9, 5, 0),
         (6, "noise", 10, 10, 127), (7, "noise", 11, 11, 127), (8, "noise", 12, 12, 127), (9, "noise", 13, 13, 127))


def t_locks(a):
    """Decision 1, 6: a lock on each OSC1 knob and each NOISE slot reaches its P on its trig, and that P alone; AM1's whole range among them."""
    r = Run(a, "locks").overbridge().machine(1, 1)
    r.key("BANK_H", 120).key("T16", 500).key("RECORD", 150)
    for s in range(1, 16):
        r.key(f"T{s}", 60)
    page = "osc1"
    for e, p, step, want_p, to in LOCKS:
        if p != page:
            r.key("OSC1", 150)
            page = p
        n = 700
        r.args += ["--press", f"T{step}@{r.t}M:{n + 80}M"]
        r.t += 40
        r.turn(e, 1 if to else -1, n, every="1M", gap=n + 60)
    r.key("RECORD", 150)
    t = r.t
    r.key("PLAY", 1800).key("STOP", 100).go(tail=60)
    it = iter(m for m in r.msgs if m[4] == 4)
    tr = [[m[8 + 2 * i] for i in range(15)] for c, k in r.sent() if k == 4 for m in [next(it, None)] if m and c / 1e6 >= t][15:30]   # the second bar
    base = tr[0]
    for e, p, step, want_p, to in LOCKS:
        got = tr[step - 1]
        others = [k + 1 for k in range(15) if k != 1 and k != want_p - 1 and got[k] != base[k]]
        check(f"locks: {p} knob {'ABCDEFGHIJ'[e]}: P{want_p} to {to} on its trig, no other", abs(got[want_p - 1] - to) <= 27 and got[want_p - 1] != base[want_p - 1] and not others, f"{base[want_p - 1]} > {got[want_p - 1]}, others {others}")
    check("locks: no fault", r.rc == 0 and not r.faults() and len(tr) == 15, f"{len(tr)} trigs; " + "; ".join(r.faults()[:2]))
    q = Run(a, "locks1").overbridge().machine(1, 1)                     # TUN alone: after its lock the voice's word glides back over steps, stock's slew
    q.key("BANK_H", 120).key("T16", 500).key("RECORD", 150).key("T1", 60).key("T9", 60)
    q.args += ["--press", f"T9@{q.t}M:780M"]
    q.t += 40
    q.turn(0, 1, 700, every="1M", gap=760)
    q.key("RECORD", 150)
    t = q.t
    q.key("PLAY", 1000).key("STOP", 100).go(tail=60)
    it = iter(m for m in q.msgs if m[4] == 4)
    p1 = [m[8] for c, k in q.sent() if k == 4 for m in [next(it, None)] if m and c / 1e6 >= t]
    check("locks: TUN: P1 on its trig, the other trig's stays", 127 in p1 and p1[:1] == [0], str(p1))


LFOS = (("DET", 4, 2), ("TRK", 5, 6), ("WAV", 7, 8), ("SUB", 8, 9), ("PW", 9, 3), ("SPD", 10, 4), ("PWM", 11, 5), ("PM1", 2, 10), ("FM1", 3, 11), ("AM1", 12, 13), ("ACC", 58, 12))


def t_lfos(a):
    """Decision 1, 6: an LFO on each knob stock's lists have reaches its P. TUN and FIN are in no list [measured, a4osc], so an LFO cannot jump ENG."""
    from concurrent.futures import ThreadPoolExecutor
    def one(e):
        name, k, p = e
        r = Run(a, "lfo_" + name).overbridge().machine(1, 1)
        r.key("BANK_H", 120).key("T16", 500).key("RECORD", 150)
        for s in ("T1", "T5", "T9", "T13"):
            r.key(s, 100)
        r.key("RECORD", 150).key("LFO", 150).key("LFO", 150).key("LFO", 150)
        r.nudge(6, -1, 14, 70)
        r.nudge(6, 1, 14, k)
        r.key("PUSH_G", 120).turn(7, 1, 140, every="1M", gap=170).key("PLAY", 500).key("STOP", 100).go(tail=30)
        return name, p, [v[p - 1] for c, v in reports(r)][-60:], r
    with ThreadPoolExecutor(4) as x:
        for name, p, v, r in x.map(one, LFOS):
            check(f"lfos: {name} moves P{p}", len(set(v)) > 3 and r.rc == 0 and not r.faults(), f"{min(v) / 128 if v else None}..{max(v) / 128 if v else None}, {len(set(v))} values")


def noise_set(r):
    """On OSC1: NOISE's four turned to known values, all moved from the defaults."""
    r.key("OSC1", 150).turn(6, 1, 500, gap=200).turn(7, -1, 500, gap=200).turn(8, 1, 500, gap=200).turn(9, 1, 500, gap=200)
    return r


def t_power2(a):
    """Decision 6: NOISE's four over a power cycle: the load site. An OFF sound keeps stock's centre; stock boots it, no fault."""
    r = noise_set(Run(a, "pw_n").overbridge().machine(1, 1)).midi("903c64", 100).midi("803c00", 100)
    r.go(extra=["--power-off", f"{r.t + 100}M"], tail=800)
    before = [[x[8 + 2 * i] for i in range(15)] for x in r.msgs if x[4] == 4][-1:]
    check("power2: the values before", before and before[0][9:13] == [127, 0, 127, 127], str(before))
    b = Run(a, "pw_b", card=r.card).overbridge()
    b.midi("903c64", 100).midi("803c00", 100).go(tail=100)
    after = [[x[8 + 2 * i] for i in range(15)] for x in b.msgs if x[4] == 4]
    check("power2: PM1 FM1 ACC AM1 back after a power cycle, the mod", after and after[0][9:13] == before[0][9:13], str(after[:1]))
    s = Run(a, "pw_s", syx=a.stock, usb=False, card=r.card, strict=True)
    s.key("TRACK1", 100).midi("903c64", 100).midi("803c00", 100).go(tail=50)
    check("power2: stock boots that state, plays, no fault", s.rc == 0 and not s.faults(), "; ".join(s.faults()[:2]))
    o = voice_words(Run(a, "pw_o"), 0x80005B70, 0x80005B68).machine(2, 1)
    o.go(extra=["--every", "100M", "--power-off", f"{o.t + 100}M"], tail=800)
    w = voice_words(Run(a, "pw_oo", card=o.card), 0x80005B68)
    w.go(extra=["--every", "100M"], tail=100)
    pm = peeked(w, 0x80005B68)
    check("power2: an OFF track's PM1 centre after a load", pm and pm[-1] == 0x4000, f"{pm[-1:]}")


def t_am1(a):
    """Decision 6: AM1 over its whole range, stock's a switch. With OSC1 LEV 0 only osc1's own words may move: nothing of the filters, drive, amp or OSC2's level and frequency words, stock's render takes the value, no fault."""
    F = 0x80003D6C
    W = (3, 5, 6, 7, 8, 9, 10, 11, 12, 72, 73, 74, 75)
    def run(name, turn):
        r = Run(a, name).overbridge().machine(1, 1)
        r.env["DTBOOT_PEEK"] = ",".join(hex(F + 2 * w & ~3) for w in W)
        r.key("OSC1", 150).key("OSC2", 150).key("OSC1", 150).key("OSC1", 150)
        r.t0 = r.t = r.t + 300
        if turn:
            r.turn(9, 1, 400, gap=200).turn(9, -1, 400, gap=200)
        else:
            r.t += 400
        return r.go(extra=["--every", "8M"], tail=50)
    r, c = run("am1", True), run("am1_c", False)
    v = [m[6 + 24] * 128 + m[7 + 24] for m in r.msgs if m[4] == 3 and m[5] & 7 == 0]
    check("am1: P13 0..127", v and min(v) == 0 and max(v) >= 16256, f"{min(v) / 128 if v else None}..{max(v) / 128 if v else None}")
    span = lambda q, w: (lambda x: (min(x), max(x)))(peeked(q, F + 2 * w)[int(q.t0 // 8):])
    moved = [(w, span(r, w), span(c, w)) for w in W if span(r, w) != span(c, w) and abs(span(r, w)[0] - span(c, w)[0]) + abs(span(r, w)[1] - span(c, w)[1]) > 8]
    check("am1: filters, drive, amp, OSC2's words: the same with the sweep as with no turn (this kit's LFO moves some in both)", not moved and len(peeked(r, F + 6)) > 50, str(moved))
    check("am1: no fault", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))


def t_rollback(a):
    """SA09's state on the build before: the layout's new, so the machines read OFF, stock's pages over what the knobs hold: it boots, plays, reports nothing. And a machine set on the build before reads on here: fresh."""
    if not a.prev:
        check("rollback: needs --prev", False)
        return
    r = Run(a, "rb0", usb=False).machine(1, 1).turn(3, 1, 500, gap=200).turn(5, 1, 500, gap=200).turn(6, 1, 500, gap=200)
    r.go(extra=["--power-off", f"{r.t + 100}M"], tail=800)
    b = Run(a, "rb1", syx=a.prev, card=r.card, strict=True).overbridge()
    b.key("TRACK1", 100).key("OSC2", 150).key("OSC1", 150).midi("903c64", 100).midi("803c00", 100).turn(3, -1, 30, gap=60).go(tail=100)
    check("rollback: the build before boots SA09's state, strict, no fault", b.rc == 0 and not b.faults(), "; ".join(b.faults()[:2]))
    check("rollback: the machines read OFF there: no report", not [x for x in b.msgs if x[4] in (3, 4)], f"{len([x for x in b.msgs if x[4] in (3, 4)])}")
    s = Run(a, "rb2", syx=a.stock, card=r.card, usb=False, strict=True)
    s.key("TRACK1", 100).key("OSC2", 150).key("OSC1", 150).midi("903c64", 100).midi("803c00", 100).go(tail=100)
    check("rollback: stock boots it, strict, no fault", s.rc == 0 and not s.faults(), "; ".join(s.faults()[:2]))


def t_fresh(a):
    """Decision 5: kits made on the last build: the machines stay, OS2 reads ANALOG, the sound's knobs change meaning."""
    if not a.prev:
        check("fresh: needs --prev", False)
        return
    font = learn_font(a)
    r = Run(a, "fr0", syx=a.prev, usb=False).key("TRACK1", 120).key("OSC1", 150).key("OSC1", 150).nudge(0, 1, 60, 2).key("OSC1", 150)
    r.go(extra=["--power-off", f"{r.t + 100}M"], tail=800)
    b = Run(a, "fr1", card=r.card).overbridge()
    b.midi("903c64", 100).midi("803c00", 100).go(tail=100)
    check("fresh: SA08's JUNO reads on: the trig reports it", [x[5] for x in b.msgs if x[4] == 4] == [8], str([x[5] for x in b.msgs if x[4] == 4]))
    n = Run(a, "fr2", usb=False, card=r.card).key("TRACK1", 120).key("OSC1", 150).go(tail=50)
    got = page_text(n.dir + "/end.png", font)
    check("fresh: the machine's NOISE: MCH, the rest stock's", same(got[3], "MCH") and b.rc == 0 and not b.faults(), " ".join(x or "-" for x in got))


def t_upyes(a):
    """Decision 9: UP + YES opens and leaves the pages as on the Rytm; a roll of UP into YES stays stock's; with no Sidecar stock's, step by step on the pages and menus that use YES."""
    r = open_page(Run(a, "uy_open", host=[]))
    r.t += 400
    r.go()
    bm, fr = bitmap(r.dir + "/end.png"), frame_rows(r.dir + "/frame.bin")
    check("upyes: opens, the engine's frame", bm == fr and [list(x[6:9]) for x in r.msgs if x[4] == 0x30] == [[0, 1, 0]], str([list(x[6:9]) for x in r.msgs if x[4] == 0x30]))
    check("upyes: YES itself reaches neither stock nor the host", not [x for x in r.msgs if x[4] == 0x31 and x[7] == 0x44], "")
    c = open_page(Run(a, "uy_close", host=[]))
    c.t += 300
    c.up_yes()
    c.t += 300
    c.go()
    check("upyes: again: leaves, told", [list(x[6:9]) for x in c.msgs if x[4] == 0x30] == [[0, 1, 0], [0, 0, 3]], str([list(x[6:9]) for x in c.msgs if x[4] == 0x30]))
    h = Run(a, "uy_long", host=[]).overbridge()
    h.t += SHOWN
    t = h.t
    h.args += ["--press", f"UP@{t}M:1800M", "--press", f"YES@{t + 220}M:1500M"]         # stock repeats a held key with its press bit set
    h.t = t + 2100
    h.go()
    o = [list(x[6:9]) for x in h.msgs if x[4] == 0x30]
    check("upyes: YES held long, 1500M: one open, no flapping, the page up", o == [[0, 1, 0]] and bitmap(h.dir + "/end.png") == frame_rows(h.dir + "/frame.bin") and h.rc == 0 and not h.faults(), f"{sum(x[1] for x in o)} opens, {sum(not x[1] for x in o)} closes")
    q = Run(a, "uy_roll", host=[]).overbridge()
    q.t += SHOWN
    t = q.t
    q.args += ["--press", f"UP@{t}M:40M", "--press", f"YES@{t + 10}M:20M"]
    q.t += 300
    q.go()
    check("upyes: UP rolled into YES, 50 ms: stock's", not [x for x in q.msgs if x[4] == 0x30], "")
    def chord(r):
        t = r.t
        r.args += ["--press", f"UP@{t}M:300M", "--press", f"YES@{t + 220}M:30M"]
        r.t = t + 400
        return r
    def session(r):
        r.key("TRACK1", 120)
        for k in ("AMP", "OSC2", "LFO", "KIT", "GLOBAL", "NOTE", "PERF"):
            r.key(k, 200)
            chord(r)
            r.key("NO", 150).key("NO", 150)
        return r
    env = lambda n: {"DTBOOT_PNG_DIR": os.path.join(a.out, n), "DTBOOT_STEPS": "1"}
    s = session(Run(a, "uy_s", syx=a.stock, env=env("uy_s"))).go(tail=50)
    m = session(Run(a, "uy_m", env=env("uy_m"))).go(tail=50)
    x, y = [[sha(os.path.join(d.dir, f)) for f in sorted(os.listdir(d.dir)) if f.startswith("step") and f.endswith(".png")] + [sha(d.dir + "/end.png")] for d in (s, m)]
    check("upyes: no Sidecar: stock's screens on each page and menu, UP and YES stock's", x == y and len(x) > 10, f"{len(x)} screens, {sum(p != q for p, q in zip(x, y))} differ")


def steps(d):
    """The run's step shots in the order taken: step9 before step10."""
    return [os.path.join(d, f) for f in sorted((f for f in os.listdir(d) if f.startswith("step") and f.endswith(".png")), key=lambda f: int(re.match(r"step(\d+)", f).group(1)))]


def t_octave(a):
    """While a Sidecar answers, UP and DOWN on a parameter page leave the keyboard's octave: KeyboardView's handler gets no code for them (0x400bd3e8). OCT+ and OCT-
    still step it. With none, stock's: an octave a press. Menus and lists keep UP and DOWN either way. KB_C1 on a track with a machine says the octave: its 04's note."""
    notes = lambda r: [x[6] for x in r.msgs if x[4] == 4]
    ok = lambda r: r.rc == 0 and not r.faults()
    def kb(name, keys, host, page="AMP", held=None):
        r = Run(a, name, host=host).overbridge()
        r.t += SHOWN
        r.machine(1, 1).key(page, 200).key("KB_C1", 200)
        for k in keys:
            if k == "UP+YES":
                r.up_yes()
                r.t += 400
            elif held:
                r.key(k, held + 200, hold=held)
            else:
                r.key(k, 250)
            r.key("KB_C1", 200)
        return r.go(tail=200)
    ud = ("UP", "UP", "DOWN", "DOWN", "DOWN")
    h, n = kb("oc_h", ud, []), kb("oc_n", ud, None)
    nh, nn = notes(h), notes(n)
    check("octave: a Sidecar: UP, UP, DOWN, DOWN, DOWN on AMP leave the octave", len(nh) == 6 and len(set(nh)) == 1 and ok(h), str(nh))
    b = nn[0] if nn else 0
    check("octave: no Sidecar: each UP and DOWN on AMP an octave, as stock", nn == [b, b + 12, b + 24, b + 12, b, b - 12] and ok(n), str(nn))
    o = kb("oc_h1", ("UP", "DOWN"), [], page="OSC1")
    check("octave: a Sidecar: on OSC1 with its machine too", len(notes(o)) == 3 and len(set(notes(o))) == 1 and ok(o), str(notes(o)))
    q = kb("oc_held", ("UP", "DOWN"), [], held=1500)
    check("octave: a Sidecar: UP held past stock's repeat, then DOWN held: still the octave", len(notes(q)) == 3 and len(set(notes(q))) == 1 and ok(q), str(notes(q)))
    k = kb("oc_keys", ("OCT_UP", "OCT_UP", "OCT_DOWN"), [])
    c = notes(k)[0] if notes(k) else 0
    check("octave: a Sidecar: OCT+ and OCT- still step it", notes(k) == [c, c + 12, c + 24, c + 12] and ok(k), str(notes(k)))
    y = kb("oc_upyes", ("UP+YES", "UP+YES"), [])
    oy = [list(x[6:9]) for x in y.msgs if x[4] == 0x30]
    check("octave: UP + YES opens, UP + YES closes", oy == [[0, 1, 0], [0, 0, 3]], str(oy))
    check("octave: and the octave is where it was", len(notes(y)) == 3 and len(set(notes(y))) == 1 and ok(y), str(notes(y)))
    def amp(name, up):
        r = Run(a, name, host=[]).overbridge()
        r.t += SHOWN
        r.machine(1, 1).key("AMP", 200)
        if up:                                                          # 100M after UP: SA10's band still says OCTAVE: 2 here
            r.key("UP", 80)
        else:
            r.t += 80
        return r.go(tail=20)
    s0, s1 = amp("oc_s0", False), amp("oc_s1", True)
    check("octave: a Sidecar: UP on AMP leaves stock's screen as no key does: no OCTAVE in the band", sha(s0.dir + "/end.png") == sha(s1.dir + "/end.png"), f"{sha(s0.dir + '/end.png')} {sha(s1.dir + '/end.png')}")

    def menu(name, keys, host, syx=None):
        r = Run(a, name, syx=syx, host=host, env={"DTBOOT_STEPS": "1"}).overbridge()
        r.env["DTBOOT_PNG_DIR"] = r.dir
        r.t += SHOWN
        r.key("TRACK1", 150)
        for k in keys:
            r.key(k, 300)
        r.go(tail=200)
        return [sha(p) for p in steps(r.dir)[-len(keys):]], r
    for m, keys in (("global", ("GLOBAL", "UP", "UP", "DOWN")), ("sound", ("SND", "DOWN", "DOWN", "UP")), ("browser", ("SND", "YES", "DOWN", "DOWN", "UP")), ("kit", ("KIT", "DOWN", "DOWN", "UP"))):
        (x, rx), (z, rz), (w, rw) = menu(f"oc_{m}_h", keys, []), menu(f"oc_{m}_n", keys, None), menu(f"oc_{m}_s", keys, None, syx=a.stock)
        moves = len(x) == len(keys) and x[-3] != x[-4] and x[-2] != x[-3] and x[-1] == x[-3]
        check(f"octave: {m}: {', '.join(keys[-3:])} move its cursor, a Sidecar there", moves and ok(rx) and not [v for v in rx.msgs if v[4] == 0x30], str(x[-4:]))
        check(f"octave: {m}: the same screens with no Sidecar, and on stock", x == z == w and ok(rz), f"{sum(p != q for p, q in zip(x, z))} differ from no Sidecar, {sum(p != q for p, q in zip(x, w))} from stock")


def din_notes(r):
    """Note-ons on the A4's MIDI OUT (DIN), from the emulator's end summary: they go out with the USB port down too. The summary holds 64 bytes, a dozen notes."""
    m = re.search(r"^midi out \(\d+ bytes\): ([0-9a-f ]*)$", r.log, re.M)
    out, st, i = [], 0, 0
    b = [int(x, 16) for x in m.group(1).split()] if m else []
    while i < len(b):
        if b[i] & 0x80:
            st, i = b[i], i + 1
            continue
        n = {0xC0: 1, 0xD0: 1}.get(st & 0xF0, 2)
        if st & 0xF0 == 0x90 and i + 1 < len(b) and b[i + 1]:
            out.append(b[i])
        i += n
    return out


def t_octave_back(a):
    """The octave comes back when the Sidecar goes (the sa12 review's MEDIUM). A Sidecar answering: UP leaves the octave; the USB host gone: UP and DOWN step it
    again, as stock (a4_kbd_key reads the port live, a4_ui_tick clears host_seen). A dead engine with the port up: UP stays off the octave, as the README says, until
    the port goes. KB_C1's note on MIDI OUT says the octave: the 04s stop with the port. The emulator's A4 does not come back on the bus after a gone host, so the
    port stays down to the end."""
    ok = lambda r: r.rc == 0 and not r.faults()
    def pre(name, host):                                                # a Sidecar there, a machine on T1, AMP; KB_C1, UP, KB_C1
        r = Run(a, name, host=host).overbridge()
        r.t += SHOWN
        return r.machine(1, 1).key("AMP", 200).key("KB_C1", 200).key("UP", 250).key("KB_C1", 200)
    def gone(r, keys):                                                  # the USB host gone, a tick past it, then the keys, each with KB_C1
        t0 = r.t + 50
        r.t += 400
        for k in keys:
            r.key(k, 250).key("KB_C1", 200)
        r.go(extra=["--usb-host-gone", f"{t0}M:{r.t + 1000}M"], tail=200)
        return t0, [c for c, k in r.sent() if c >= t0 * 1e6]
    g = pre("ob_gone", [])
    t0, after = gone(g, ("UP", "UP", "DOWN"))
    n = din_notes(g)
    b = n[0] if n else 0
    check("octave_back: a Sidecar answering: UP leaves the octave", len(n) >= 2 and n[:2] == [b, b] and g.count(4) == 2, f"{n}, {g.count(4)} 04s")
    check("octave_back: the USB host gone: UP, UP, DOWN step it again, as stock", n[2:] == [b + 12, b + 24, b + 12] and not after and ok(g), f"{n}, {len(after)} sends after the port went; " + "; ".join(g.faults()[:2]))
    d = pre("ob_dead", []).go()
    secs = float(re.search(r"end: .*?, ([\d.]+) s,", d.side).group(1))
    k = pre("ob_dead1", ["--seconds", f"{secs:.2f}"])                   # the engine gone after the prefix, the port up
    k.t += 1000
    k.key("UP", 250).key("KB_C1", 200)
    gone(k, ("UP",))
    m = din_notes(k)
    c = m[0] if m else 0
    check("octave_back: a dead engine, the port up: UP still leaves the octave, as documented", len(m) >= 3 and m[:3] == [c, c, c] and ", 2 trigs," in k.side, str(m))   # the engine heard the first two KB_C1s only: gone by the third
    check("octave_back: then the USB host gone: UP steps it again", m[3:] == [c + 12] and ok(k), f"{m}; " + "; ".join(k.faults()[:2]))


def sx(b):
    """A Sidecar SysEx, as hex for --usb-midi."""
    return "f07d5254" + b + "f7"


def t_low(a):
    """The review's LOW items and a4sa08's open one, by bytes on the USB port: bad SysEx; a one-frame popup between ticks; a dead Pi; a knob the mask does not name."""
    bad = ("3801000010" + "01" * 3, "38" + "01" + "0f" + "00" + "02" + "08" + "00" * 8, "38" + "01" + "00" + "07" + "01" + "03" + "00" * 8, "380100000108", "3801" + "00" * 4, "3701", "37", "3a01", "3a", "4f", "4f01", "4f0100", "36", "3601", "", "3c", "3b", "30")
    r = Run(a, "lo_bad").overbridge()
    t = r.t
    for i, h in enumerate(bad):
        r.args += ["--usb-midi", f"{sx(h)}@{t + i * 20}M"]
    r.args += ["--usb-midi", f"f07df7@{t + 400}M", "--usb-midi", f"f07d52f7@{t + 420}M"]
    r.t += 500
    r.key("AMP", 200).go(tail=100)
    s = Run(a, "lo_bad0").overbridge()
    s.t = r.t - 200
    s.key("AMP", 200).go(tail=100)
    check("low: short, cut, out of range SysEx: no fault, stock's screen", r.rc == 0 and not r.faults() and bitmap(r.dir + "/end.png") == bitmap(s.dir + "/end.png"), "; ".join(r.faults()[:2]))
    rect = "38" + "01" + "00" + "00" + "02" + "08" + "".join("007f" for _ in range(0)) + ("00" + "7f" * 7) * 2 + ("00" + "7f" * 1)
    p = Run(a, "lo_pop").overbridge()
    t = p.t
    p.args += ["--usb-midi", f"{sx(rect)}@{t}M", "--usb-midi", f"{sx('3901')}@{t + 5}M", "--usb-midi", f"{sx('360110')}@{t + 16}M"]
    p.t += 30
    p.go(tail=0)
    q = Run(a, "lo_pop0").overbridge()
    q.t = p.t
    q.go(tail=0)
    check("low: a popup's 36 a tick after its commit: on the screen at once", bitmap(p.dir + "/end.png") != bitmap(q.dir + "/end.png"), "")
    def maskrun(name, turn):
        r = Run(a, name).overbridge().machine(1, 1)
        t = r.t + 50
        r.t += 60
        r.up_yes()
        r.args += ["--usb-midi", f"{sx('3901')}@{t}M", "--usb-midi", f"{sx('3701' + '00' * 40)}@{t + 170}M"]
        for i in range(5):
            r.args += ["--usb-midi", f"{sx('3c01')}@{t + i * 60}M"]
        r.t += 80
        if turn:
            r.turn(7, 1, 30, every="1M", gap=40)
        return r.go(tail=20)
    x, y = maskrun("lo_m0", False), maskrun("lo_m1", True)
    v0, v1 = [v[2] for c, v in reports(x)][-1:], [v[2] for c, v in reports(y)][-1:]
    check("low: page open, a knob the mask does not name: nothing under it", v0 and v0 == v1, f"P3 {v0} {v1}")
    d = open_page(Run(a, "lo_dead", host=[])).go()
    secs = float(re.search(r"end: .*?, ([\d.]+) s,", d.side).group(1))
    k = Run(a, "lo_dead1", host=["--seconds", f"{secs:.2f}"]).overbridge()     # gone by the first try, the USB port up
    k.t += SHOWN + 1000
    k.up_yes()
    k.t += 1600
    k.up_yes()
    k.t += 300
    k.go()
    o = [list(x[6:9]) for x in k.msgs if x[4] == 0x30]
    check("low: a dead Pi, the port up: one try at the most, then the way in waits for a live answer", len([x for x in o if x[1]]) == 1 and k.rc == 0 and not k.faults(), str(o))


def poly_kit(r, track, voices=4):
    """TRACKn, KIT > POLY CONFIG, the first `voices` voices."""
    r.key(f"TRACK{track}", 150).key("KIT", 120)
    for _ in range(5):
        r.key("DOWN", 120)
    r.key("YES", 120)
    for i in range(voices):
        r.key("YES", 100)
        if i < voices - 1:
            r.key("RIGHT", 100)
    return r.key("NO", 120).key("NO", 120).key("NO", 400)


def grid_chord(r, step="T1", notes=("KB_C1", "KB_E1", "KB_G1"), stay=False):
    """An empty pattern; a trig holding a chord: GRID RECORD, the step held, the keys held together. stay: still in GRID RECORD."""
    r.key("BANK_H", 120).key("T16", 500).key("RECORD", 150)
    t = r.t
    r.args += ["--press", f"{step}@{t}M:700M"]
    for i, k in enumerate(notes):
        r.args += ["--press", f"{k}@{t + 100 + i * 60}M:{400 - i * 60}M"]
    r.t += 900
    return r if stay else r.key("RECORD", 200)


def seq_trigs(r):
    """(note, voice byte) of the 04s after PLAY: the grid's own key presses come before."""
    return [(x[6], x[5]) for x in r.msgs if x[4] == 4]


FOUR = ("KB_C1", "KB_E1", "KB_G1", "KB_B1")


def step_chord(a, name, voices=0, notes=FOUR, env=None, play=lambda r: None, extra=None):
    """FM6 on T1, a chord on its first step, played. (the run, its 04s and 11s after PLAY.)"""
    def prog():
        r = Run(a, name, env=env).overbridge().machine(1, 4)
        if voices:
            poly_kit(r, 1, voices)
        return grid_chord(r, notes=notes)
    t0 = len(seq_trigs(prog().go(tail=1)))
    r = prog()
    at = r.t
    r.key("PLAY", 1000)
    play(r)
    r.key("STOP", 300).go(extra=extra and extra(at), tail=500)
    ev, n = [], 0
    for m in r.msgs:
        n += m[4] == 4
        if m[4] == 4 and n > t0:
            ev.append((4, m[6], m[5]))
        elif m[4] == 0x11 and n >= t0 and ev:
            ev.append((0x11,))
    r.first = t0
    return r, ev


def whole_chords(ev, want):
    """ev splits into runs of 04s by its 11s and a new first note: every run is the chord, in order, on FM6's T1."""
    w, cut, cur = [(4, n, 0x48) for n in want], [], []
    for e in ev:
        if e[0] == 0x11 or (cur and e[1] == want[0]):
            cut.append(cur) if cur else None
            cur = []
        if e[0] == 4:
            cur.append(e)
    return (cut + [cur] if cur else cut), w


def t_chord(a):
    """A chord programmed on one step, the owner's case: one event with all its notes, one trig a step before this mod. Each note a 04, in order, every bar."""
    r = poly_kit(Run(a, "chord").overbridge().machine(1, 4), 1)        # FM6
    grid_chord(r, notes=("KB_C1", "KB_E1", "KB_G1", "KB_B1"))
    t0 = len(seq_trigs(r.go(tail=1)))
    r = poly_kit(Run(a, "chord").overbridge().machine(1, 4), 1)
    grid_chord(r, notes=("KB_C1", "KB_E1", "KB_G1", "KB_B1"))
    r.key("PLAY", 1000).key("STOP", 300).go(tail=500)
    tr = seq_trigs(r)[t0:]
    want = [(60, 0x48), (64, 0x48), (67, 0x48), (71, 0x48)]
    bars = [tr[i:i + 4] for i in range(0, len(tr), 4)]
    check("chord: four notes on a step: four 04s, in order, every bar, on the track's voice and machine", len(bars) >= 2 and all(b == want for b in bars), str(tr[:9]))
    sent = [(c, k) for c, k in r.sent() if k == 4][-len(tr):]
    gap = max((sent[i + 3][0] - sent[i][0]) / 200000 for i in range(0, len(sent) - 3, 4)) if len(sent) >= 4 else 1e9
    check("chord: the four within the engine's 20 ms", gap < 20, f"longest {gap:.2f} ms")
    check("chord: no fault", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))
    vel = {x[7] for x in r.msgs if x[4] == 4}
    check("chord: each note's velocity", vel == {100}, str(vel))


def t_chord_keys(a):
    """Three keys at one instant, MIDI's three in a row: a note a block; all reported. An 11 only when the last is up, though voice 0 closes first."""
    r = poly_kit(Run(a, "chord_keys").overbridge().machine(1, 1), 1)
    t = r.t
    for n in (0x3c, 0x40, 0x43):
        r.args += ["--midi", f"90{n:02x}64@{t}M"]
    r.args += ["--midi", f"803c00@{t + 150}M"]                         # voice 0's note lets go first
    r.args += ["--midi", f"804000@{t + 500}M", "--midi", f"804300@{t + 500}M"]
    r.t += 800
    r.go(tail=300)
    ev = [(x[4], x[6] if x[4] == 4 else None) for x in r.msgs if x[4] in (4, 0x11)]
    check("chord_keys: three notes, in order, then one 11", ev == [(4, 60), (4, 64), (4, 67), (0x11, None)], str(ev))
    log = [(c, k) for c, k in r.sent() if k == 0x11]
    check("chord_keys: the 11 waits for the last key: 500M after the first, not 150M", bool(log) and log[-1][0] / 1e6 >= t + 490, str(log[-1:]) + f" keys up at {t + 500}M")
    check("chord_keys: no fault", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))


def t_mono(a):
    """No POLY CONFIG: a trig is one 04 and its end one 11, what it always was; two notes closer than 20 ms get an 11 between them; keys and MIDI stay one note each."""
    r = Run(a, "mono").overbridge().machine(1, 1)
    r.midi("903c64", 200).midi("803c00", 300)
    t = r.t
    r.args += ["--midi", f"904064@{t}M", "--midi", f"904364@{t}M"]
    r.t += 300
    r.args += ["--midi", f"804000@{r.t}M", "--midi", f"804300@{r.t}M"]
    r.t += 200
    r.go(tail=200)
    ev = [(x[4], x[6] if x[4] == 4 else None) for x in r.msgs if x[4] in (4, 0x11)]
    check("mono: one 04, one 11; then two at once with an 11 between, so that the Sidecar never takes a chord", ev == [(4, 60), (0x11, None), (4, 64), (0x11, None), (4, 67), (0x11, None)], str(ev))
    q = Run(a, "mono_step").overbridge().machine(1, 1)
    q.key("BANK_H", 120).key("T16", 500).key("RECORD", 150).key("T1", 60).key("T5", 60).key("T9", 60).key("RECORD", 200)
    q.key("PLAY", 1000).key("STOP", 300).go(tail=300)
    ev = [(x[4], x[6] if x[4] == 4 else None) for x in q.msgs if x[4] in (4, 0x11)]
    check("mono: single trigs from the sequencer: a 04 a step, its note, an 11 after each", len(ev) >= 8 and ev == [(4, 48), (0x11, None)] * (len(ev) // 2), str(ev[:6]))


def t_mono_chord(a):
    """The owner's case: no POLY CONFIG, a chord on a step: all of it reaches the Sidecar, each bar."""
    r, ev = step_chord(a, "mono_chord")
    bars, want = whole_chords(ev, (60, 64, 67, 71))
    check("mono_chord: four notes on a mono track's step: four 04s, in order, every bar, one voice and machine", len(bars) >= 2 and all(b == want for b in bars), str(ev[:10]))
    tr = [e[0] for e in ev]
    inside = any(0x11 in tr[i + 1:i + 4] for i in range(0, len(tr) - 3) if ev[i][:2] == (4, 60))
    check("mono_chord: no 11 inside a chord, one after it", not inside and tr.count(0x11) >= 2 and tr.count(0x11) <= len(bars), str(tr[:12]))
    sent = [c for c, k in r.sent() if k == 4][r.first:]
    gap = max((sent[i + 3] - sent[i]) / 200000 for i in range(0, len(sent) - 3, 4)) if len(sent) >= 4 else 1e9
    check("mono_chord: the four within the engine's 20 ms", gap < 20, f"longest {gap:.2f} ms")
    check("mono_chord: each note's velocity, no fault", {x[7] for x in r.msgs if x[4] == 4} == {100} and r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))
    t3, ev3 = step_chord(a, "mono_chord3", notes=FOUR[:3])
    bars, want = whole_chords(ev3, (60, 64, 67))
    check("mono_chord: three notes: three 04s, the empty slot none", len(bars) >= 2 and all(b == want for b in bars), str(ev3[:8]))


def t_poly_voices(a):
    """POLY CONFIG with one voice and with two: all the notes all the same (four voices: the chord test). The event's +0x08 is 1 and 2 here."""
    for voices in (1, 2):
        r, ev = step_chord(a, f"polyv{voices}", voices=voices)
        bars, want = whole_chords(ev, (60, 64, 67, 71))
        check(f"poly_voices: {voices}: four notes, in order, every bar", len(bars) >= 2 and all(b == want for b in bars) and r.rc == 0 and not r.faults(), str(ev[:10]))


def t_mono_gap(a):
    """A mono track's different events closer than 20 ms stay apart, a chord being one of them: a note on MIDI just after the chord, the chord's last note at that, and one just before it."""
    r, ev = step_chord(a, "gap0")
    sent = [c for c, k in r.sent() if k == 4][r.first:]
    at = [sent[i] / 1e6 for i in (4, 8)]                            # the second chord, and the third, in M instructions
    check("mono_gap: the chord's times", len(sent) >= 12, str(at))
    def late(q):
        q.args += ["--midi", f"904764@{at[0] + 1:.0f}M", "--midi", f"804700@{at[0] + 100:.0f}M"]
    r, ev = step_chord(a, "gap1", play=late)
    i = next((k for k, e in enumerate(ev) if k >= 5 and e[:2] == (4, 71) and ev[k - 1][:2] == (0x11,)), None)
    check("mono_gap: the chord's own last note just after it comes after an 11, or the Sidecar would swallow it", i is not None and [e[:2] for e in ev[i - 5:i]] == [(4, 60), (4, 64), (4, 67), (4, 71), (0x11,)], str(ev[:14]))
    def early(q):
        q.args += ["--midi", f"903c64@{at[0] - 2:.0f}M", "--midi", f"803c00@{at[0] + 100:.0f}M"]
    r, ev = step_chord(a, "gap2", play=early)
    tr = [e[:2] for e in ev]
    i = next((k for k in range(1, len(tr) - 1) if tr[k - 1] == (4, 60) and tr[k] == (0x11,) and tr[k + 1:k + 5] == [(4, 60), (4, 64), (4, 67), (4, 71)]), None)
    check("mono_gap: a trig just ahead of the chord: an 11 between them, the chord whole", i is not None, str(tr[:14]))


def t_mono_stall(a):
    """A host that stops reading across chords: the emulator's port goes down meanwhile, so no send fails here, but the chord waits and stays whole after it."""
    r, ev = step_chord(a, "mstall", play=lambda q: setattr(q, "t", q.t + 1400), extra=lambda t: ["--usb-host-noread", f"{t + 100}M:{t + 900}M"])
    bars, want = whole_chords(ev, (60, 64, 67, 71))
    check("mono_stall: the chords after it are whole, no fault", len(bars) >= 2 and all(b == want for b in bars) and r.rc == 0 and not r.faults(), str([[e[1] for e in b] for b in bars]))


def preview(a, name, machine=4, voices=0, notes=FOUR, midi=None):
    """A chord on T1's first step, in GRID RECORD; the trig held, YES. (the run, the 04s and 11s from the press on.)"""
    r = Run(a, name).overbridge().machine(1, machine)
    if voices:
        poly_kit(r, 1, voices)
    grid_chord(r, notes=notes, stay=True)
    t = r.t
    r.args += ["--press", f"T1@{t}M:500M", "--press", f"YES@{t + 150}M:100M"]
    r.t = t + 520
    if midi:                                                            # the trig let go: while it is held, MIDI's notes go into it
        midi(r)
    r.t = max(r.t, t + 700)
    r.key("RECORD", 300).go(tail=500)
    it = iter(m for m in r.msgs if m[4] in (4, 0x11))
    ev = []
    for c, k in r.sent():
        if k in (4, 0x11):
            m = next(it, None)
            if m and c / 1e6 >= t:
                ev.append((4, m[6], m[5], m[7]) if k == 4 else (0x11,))
    return r, ev


def t_preview(a):
    """Hold a trig, YES: the whole chord, on a mono track too: the OS itself plays no more notes than the track has voices. One 11 at its end."""
    r, ev = preview(a, "prev4")
    check("preview: mono: four notes, the track's machine, then one 11", ev == [(4, n, 0x48, 100) for n in (60, 64, 67, 71)] + [(0x11,)], str(ev))
    check("preview: no fault", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))
    r, ev = preview(a, "prev3", notes=FOUR[:3])
    check("preview: mono: three notes, no fourth", ev == [(4, n, 0x48, 100) for n in (60, 64, 67)] + [(0x11,)], str(ev))
    for voices in (1, 2, 4):
        r, ev = preview(a, f"prevp{voices}", voices=voices)
        got = sorted(e[1] for e in ev if e[0] == 4)
        check(f"preview: POLY CONFIG {voices}: all four notes, one 11 when the last is off", got == [60, 64, 67, 71] and ev[-1] == (0x11,) and sum(e[0] == 0x11 for e in ev) == 1, str(ev))
    r, ev = preview(a, "prev1", notes=FOUR[:1])
    check("preview: a step of one note: one 04, one 11", ev == [(4, 60, 0x48, 100), (0x11,)], str(ev))
    def line(q):
        q.midi("904364", 40).midi("804300", 20).midi("904764", 40).midi("804700", 20)
    r, ev = preview(a, "prevl", midi=line)
    tr = [e[:2] for e in ev]
    check("preview: notes after it don't stack on it: each one note, in its turn", tr[:4] == [(4, 60), (4, 64), (4, 67), (4, 71)] and (4, 67) in tr[4:] and (4, 71) in tr[4:] and len([e for e in tr if e[0] == 4]) == 6, str(tr))
    o = Run(a, "prevo").overbridge()
    grid_chord(o, notes=FOUR, stay=True)
    t = o.t
    o.args += ["--press", f"T1@{t}M:500M", "--press", f"YES@{t + 150}M:100M"]
    o.t += 700
    o.key("RECORD", 300).go(tail=300)
    check("preview: OFF: nothing reported, no fault", o.count(4) == 0 and o.rc == 0 and not o.faults(), f"{o.count(4)} trigs")


def t_chord_labels(a):
    """Both features at once, on a machine with names: the page shows them while a programmed chord plays, a knob turned meanwhile asks for its title on the UI task, and every note still reports, in order, with the turned value."""
    font = learn_font(a)
    def prog(name):
        return grid_chord(poly_kit(Run(a, name).overbridge().machine(1, 1), 1), notes=("KB_C1", "KB_E1", "KB_G1", "KB_B1"))
    t0 = len(seq_trigs(prog("chlab0").go(tail=1)))
    r = prog("chlab").key("PLAY", 300)
    r.turn(7, 1, 40, every="3M", gap=300)                               # knob H on the OSC1 page: TIM, P3
    r.key("STOP", 300).go(tail=500)
    got, want = page_text(r.dir + "/end.png", font), want_labels("PLTS", "osc1")
    check("chord_labels: the machine's names on the OSC1 page, in the run with the chord", all(same(g, w) for g, w in zip(got, want)), " ".join(x or "-" for x in got))
    tr = seq_trigs(r)[t0:]
    want_b = [(60, 0x00), (64, 0x00), (67, 0x00), (71, 0x00)]
    bars = [tr[i:i + 4] for i in range(0, len(tr), 4)]
    check("chord_labels: four notes on a step: four 04s, in order, every bar, with a knob turning", len(bars) >= 2 and all(b == want_b for b in bars), str(tr[:9]))
    p3 = [m[8 + 2 * 2] for m in r.msgs if m[4] == 4][t0:]
    check("chord_labels: the turned knob's value rides on the trigs", len(set(p3)) > 1, str(p3[:12]))
    check("chord_labels: no fault", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))


# ---- the remote UI: the real engine on the link. Screens are read off the emulated panel; what the engine says it sent is its --frame-out.
def frame_rows(p):
    """The engine's last frame: glass pixel (x, y from the top) = byte (7 - y / 8) + 8 x, bit y % 8 [as the Rytm's]."""
    b = open(p, "rb").read()
    return [[bool(b[(7 - y // 8) + 8 * x] >> (y % 8) & 1) for x in range(128)] for y in range(64)]


SHOWN = 900     # after the port's hello: its splash has run
CODE = "9173 2046"      # sidecar_emu --pair-at's, made up for this test: a real code never comes near these logs


def open_page(r):
    """OVERBRIDGE, the splash let go by, UP + YES."""
    r.overbridge()
    r.t += SHOWN
    r.up_yes()
    r.t += 250
    return r


def closed_ref(a, name, keys=(), yes=False):
    """The same keys with no Sidecar at all: UP pressed, stock's; YES only where it reached stock under test."""
    r = Run(a, name).overbridge()
    r.t += SHOWN
    if yes:
        r.up_yes()
    else:
        t = r.t
        r.args += ["--press", f"UP@{t}M:300M"]
        r.t = t + 330
    r.t += 250
    r.t += 400
    for k in keys:
        r.key(k, 300)
    return r.go()


def t_remote_open(a):
    ref = closed_ref(a, "rui_ref")
    r = open_page(Run(a, "rui_open", host=[]))
    r.t += 400
    r.go()
    bm, fr = bitmap(r.dir + "/end.png"), frame_rows(r.dir + "/frame.bin")
    check("remote_open: the A4's screen is the engine's frame, pixel for pixel", bm == fr, f"{sum(x != y for p, q in zip(bm, fr) for x, y in zip(p, q))} pixels differ")
    check("remote_open: and not stock's", bm != bitmap(ref.dir + "/end.png") and sum(map(sum, bm)) > 300, f"{sum(map(sum, bm))} pixels on")
    m = re.search(r"opens (\d+), keys (\d+), turns (\d+), bad (\d+)", r.side)
    check("remote_open: one open, nothing the engine could not read", m and m.group(1) == "1" and m.group(4) == "0", m.group(0) if m else "no line")
    check("remote_open: no fault", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))
    o = [x for x in r.msgs if x[4] == 0x30]
    check("remote_open: 30 once, page 0, on, the user's", [list(x[6:9]) for x in o] == [[0, 1, 0]], str([list(x[6:9]) for x in o]))
    q = Run(a, "rui_nohost").overbridge()
    q.t += SHOWN
    q.env = dict(q.env, DTBOOT_PNG_DIR=q.dir, DTBOOT_STEPS="1")
    q.key("OSC1", 150).key("OSC1", 150).key("OSC1", 150).key("OSC1", 150).go()
    c = [sha(os.path.join(q.dir, f)) for f in sorted(os.listdir(q.dir)) if f.startswith("step") and f.endswith("_OSC1.png")]
    check("remote_open: no Sidecar: the OSC1 key's cycle, two pages, no SIDECAR page", len(c) >= 4 and c[-1] == c[-3] and c[-2] == c[-4] and len({*c[-4:]}) == 2 and not [x for x in q.msgs if x[4] == 0x30], str(c[-4:]))


def nav(a, name, keys, gap=300, **kw):
    r = open_page(Run(a, name, host=kw.pop("host", []), env={"DTBOOT_STEPS": "1"}))
    r.env["DTBOOT_PNG_DIR"] = r.dir
    r.t += 300
    for k in keys:
        r.key(k, gap)
    r.go(tail=300)
    names = sorted(f for f in os.listdir(r.dir) if f.startswith("step") and f.endswith(".png"))
    r.shots = [bitmap(os.path.join(r.dir, f)) for f in names[-len(keys):]] if keys else []
    return r


def t_remote_keys(a):
    """The six keys reach the engine as the Rytm's do: the Rytm's codes, press and release, and each moves the page as on the Rytm."""
    keys = ("RIGHT", "RIGHT", "RIGHT", "LEFT", "LEFT", "LEFT", "YES", "DOWN", "DOWN", "UP", "NO", "NO")
    r = nav(a, "rui_keys", keys)
    code = {"RIGHT": 0x41, "LEFT": 0x40, "YES": 0x44, "DOWN": 0x43, "UP": 0x42, "NO": 0x45}
    k = [(x[6] << 7 | x[7], x[8]) for x in r.msgs if x[4] == 0x31]
    want = [p for n in keys for p in ((code[n], 1), (code[n], 0))]
    check("remote_keys: 31 for each key, its code, press then release", k == want, str(k[:6]))
    s = r.shots
    sidecar, system, scope = s[2], s[0], s[1]
    check("remote_keys: RIGHT steps the ring and comes round, SIDECAR SYSTEM SCOPE", system != sidecar and scope != system and s[3] == scope and s[4] == system and s[5] == sidecar, "")
    check("remote_keys: YES opens the MENU, DOWN and UP move its cursor", s[6] != sidecar and s[7] != s[6] and s[8] != s[7] and s[9] == s[7], "")
    check("remote_keys: NO back to SIDECAR, NO again leaves", s[10] == sidecar and s[11] != sidecar, "")
    check("remote_keys: no fault", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))
    t = open_page(Run(a, "rui_turn", host=[], env={"DTBOOT_STEPS": "1"}))
    t.key("RIGHT", 300).key("RIGHT", 400)
    a0 = t.t
    t.turn(1, 1, 8, every="20M", gap=300).go(tail=200)
    tr = [x for x in t.msgs if x[4] == 0x32]
    check("remote_keys: a knob the page takes: 32 for knob B, none to stock", tr and all(x[6] == 1 for x in tr) and sum(x[7] - 64 for x in tr) > 0, str([list(x[6:9]) for x in tr[:4]]))


def t_remote_exit(a):
    ref = closed_ref(a, "rui_ref2", ("AMP",))
    r = nav(a, "rui_exit", ("AMP",))
    check("remote_exit: a stock page key leaves and does its job: stock's AMP page, pixel for pixel", bitmap(r.dir + "/end.png") == bitmap(ref.dir + "/end.png"), "")
    o = [list(x[6:9]) for x in r.msgs if x[4] == 0x30]
    check("remote_exit: told: 30 off, reason escape", o[-1:] == [[0, 0, 3]], str(o))
    q = nav(a, "rui_exit_no", ("NO",))
    ref0 = closed_ref(a, "rui_ref3")
    check("remote_exit: NO on the status page: stock's screen, pixel for pixel", bitmap(q.dir + "/end.png") == bitmap(ref0.dir + "/end.png"), "")
    u = nav(a, "rui_after", ("NO", "RIGHT", "YES", "NO"))
    n = [x for x in u.msgs if x[4] == 0x31]
    check("remote_exit: closed, the arrows and YES are stock's again: nothing to the host", len(n) == 2, f"{len(n)} 31s")
    s = closed_ref(a, "rui_ref4", ("RIGHT", "YES", "NO"))
    check("remote_exit: and the screen is stock's after them", bitmap(u.dir + "/end.png") == bitmap(s.dir + "/end.png"), "")


def t_remote_play(a):
    """Open, with the sequencer playing: transport stays stock's, the trigs go out, a trig on the panel is stock's while the page does not take it."""
    r = Run(a, "rui_play", host=[]).overbridge().machine(1, 1)
    r.key("RECORD", 100).key("T1", 60).key("T9", 60).key("RECORD", 100)
    r.t += SHOWN
    r.up_yes()
    r.t += 250
    t = r.t
    r.key("PLAY", 1200).key("STOP", 300).go(tail=200)
    sent = r.sent()
    n = [c for c, k in sent if k == 4 and c / 1e6 > t]
    check("remote_play: PLAY with the page open: the sequencer runs, its trigs report", len(n) >= 2, f"{len(n)} trigs")
    bm, fr = bitmap(r.dir + "/end.png"), frame_rows(r.dir + "/frame.bin")
    check("remote_play: the page stayed up, the engine's frame", bm == fr, "")
    check("remote_play: no fault", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))


def last_hello(a, name, **kw):
    r = Run(a, name, host=kw.get("host", [])).overbridge()
    r.t += 600
    r.go()
    c = [c for c, k in r.sent() if k == 0x36]
    return c[-1] / 1e6 if c else None


def t_remote_splash(a):
    """The connection animation: the frame on stock's screen for 3 s, the icon's slide and the line, every key stock's, stock's screen after."""
    t = last_hello(a, "rui_sp0")
    check("remote_splash: a 36 after the hello's answer", t is not None, str(t))
    if t is None:
        return
    fs = []
    for at in (30, 300, 500):
        r = Run(a, f"rui_sp{at}", host=[]).overbridge()
        r.t = 4000
        r.overbridge = None
        r.args = Run(a, "x").overbridge().args
        r.t = int(t) + at
        fs.append(r.go(tail=0))
    a0, a1, a2 = [bitmap(x.dir + "/end.png") for x in fs]
    st = closed_ref(a, "rui_ref5")
    check("remote_splash: the animation: the screen moves, slide then line", a0 != a1 and a1 != a2 and sum(map(sum, a1)) > 200, f"{sum(map(sum, a0))} {sum(map(sum, a1))} {sum(map(sum, a2))} pixels on")
    late = Run(a, "rui_splate", host=[]).overbridge()
    late.t = int(t) + 1000
    late.go(tail=0)
    check("remote_splash: over by itself: not the splash", bitmap(late.dir + "/end.png") not in (a0, a1, a2), "")
    k = Run(a, "rui_spkey", host=[]).overbridge()
    k.t = int(t) + 150
    k.key("AMP", 100).go(tail=0)
    check("remote_splash: a key ends it and is stock's", bitmap(k.dir + "/end.png") != a1 and not [x for x in k.msgs if x[4] == 0x30], "")


def t_remote_pair(a):
    """The pairing code on the A4's screen: the modal over stock's screen and on the status page. A made-up code, sidecar_emu's; nothing of it is printed here."""
    t = last_hello(a, "rui_pa0")
    r = Run(a, "rui_pair", host=["--pair-at", "6"]).overbridge()
    r.t = int(t) + 1500
    r.go(tail=0)
    bm = bitmap(r.dir + "/end.png")
    ref = Run(a, "rui_pair0", host=[]).overbridge()
    ref.t = int(t) + 1500
    ref.go(tail=0)
    box = bm[16][4:124]
    check("remote_pair: the box on the A4's screen, over stock's, closed page", bm != bitmap(ref.dir + "/end.png") and all(box), "")
    check("remote_pair: the code is in no log", CODE not in r.side + r.log, "")
    o = bitmap(a.out + "/rui_open/end.png")
    q = open_page(Run(a, "rui_pairst", host=["--pair-at", "1"]))
    q.t += 400
    q.go()
    b2 = bitmap(q.dir + "/end.png")
    rows = {y for y in range(64) if b2[y] != o[y]}
    check("remote_pair: its line on the status page, only there", rows and rows <= set(range(29, 39)) and b2 == frame_rows(q.dir + "/frame.bin"), str(sorted(rows)[:3]))
    check("remote_pair: the code is in no log, no fault", CODE not in q.side + q.log and r.rc == 0 and not r.faults() and q.rc == 0, "; ".join(r.faults()[:2]))


def t_remote_link(a):
    """The Sidecar gone with the page open: stock's screen by itself within a second or so, and it stays. The link closed, then the USB host gone, then a power cut."""
    ref = closed_ref(a, "rui_ref6")
    r = open_page(Run(a, "rui_lk0", host=[]))
    r.t += 400
    r.go()
    secs = float(re.search(r"end: .*?, ([\d.]+) s,", r.side).group(1))
    open_bm = bitmap(r.dir + "/end.png")
    q = open_page(Run(a, "rui_lk1", host=["--seconds", f"{secs:.2f}"]))
    q.t += 400 + 1000
    q.go()
    bm = bitmap(q.dir + "/end.png")
    o = [list(x[6:9]) for x in q.msgs if x[4] == 0x30]
    check("remote_link: the link closed while open: stock's screen, pixel for pixel", bm == bitmap(ref.dir + "/end.png") and bm != open_bm, str(o))
    check("remote_link: closed by the time-out, and told", o[-1:] == [[0, 0, 2]], str(o))
    check("remote_link: no fault, the A4 runs on", q.rc == 0 and not q.faults(), "; ".join(q.faults()[:2]))
    g = open_page(Run(a, "rui_lk2", host=[]))
    t0 = g.t + 200
    g.t += 1200
    g.go(extra=["--usb-host-gone", f"{t0}M:{t0 + 300}M"])
    check("remote_link: the USB host gone while open: stock's screen, no fault", bitmap(g.dir + "/end.png") == bitmap(ref.dir + "/end.png") and g.rc == 0 and not g.faults(), "; ".join(g.faults()[:2]))
    p = open_page(Run(a, "rui_lk3", host=[]))
    at = p.t + 200
    p.go(extra=["--power-off", f"{at}M"], tail=800)
    check("remote_link: a power cut while open: the mod's power-off", p.rc == 0 and not p.faults(), "; ".join(p.faults()[:2]))
    b = Run(a, "rui_lk4", card=p.card, usb=False)
    b.key("AMP", 300).go()
    s = Run(a, "rui_lk5", card=p.card, syx=a.stock, usb=False)
    s.key("AMP", 300).go()
    check("remote_link: and the next boot is stock's screen", bitmap(b.dir + "/end.png") == bitmap(s.dir + "/end.png"), "")


def t_remote_voice(a):
    """A voice's page: on the ring once the voice has reported, drawn from the engine, a knob reaches the engine's voice."""
    r = Run(a, "rui_voice", host=[], env={"DTBOOT_STEPS": "1"}).overbridge().machine(1, 1)
    r.env["DTBOOT_PNG_DIR"] = r.dir
    r.t += SHOWN
    r.midi("903c64", 100).midi("803c00", 200)
    r.up_yes()
    r.t += 250
    r.key("RIGHT", 300).key("RIGHT", 400)
    b0 = r.t
    r.turn(0, 1, 6, every="20M", gap=300).go(tail=200)
    bm, fr = bitmap(r.dir + "/end.png"), frame_rows(r.dir + "/frame.bin")
    names = sorted(f for f in os.listdir(r.dir) if f.startswith("step") and f.endswith("_RIGHT.png"))
    before = bitmap(os.path.join(r.dir, names[-1]))
    check("remote_voice: T1's page drawn, the engine's frame", bm == fr, "")
    check("remote_voice: a knob moves it on the screen", bm != before and [x for x in r.msgs if x[4] == 0x32], f"{sum(x != y for p, q in zip(bm, before) for x, y in zip(p, q))} pixels")


def t_remote_old(a):
    """This mod on the kernel before it, which has no pages: no restart past the one the hello asks, nothing to open, the key as it was."""
    if not a.old_engine:
        check("remote_old: needs --old-engine", False)
        return
    r = Run(a, "rui_old", host=[]).overbridge()
    r.old = a.old_engine
    r.t += SHOWN
    r.up_yes()
    r.t += 250
    r.key("RIGHT", 300).go(tail=300)
    ref = closed_ref(a, "rui_ref7", ("RIGHT",), yes=True)
    check("remote_old: one restart, the box served", r.side.count(": restart:") == 1 and "end: Analog Four" in r.side, f"{r.side.count(': restart:')} restarts")
    check("remote_old: nothing opens, stock's screen", bitmap(r.dir + "/end.png") == bitmap(ref.dir + "/end.png") and not [x for x in r.msgs if x[4] == 0x30], "")
    check("remote_old: no fault", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))


def t_remote_off(a):
    """A Sidecar connected, the page never opened: stock's screens step by step, with stock's hello-less USB, a turned knob's title too."""
    def script(r):
        r.overbridge()
        r.t += SHOWN
        r.key("TRACK1", 120).key("OSC2", 150).key("OSC2", 150).key("FILTERS", 150).key("AMP", 150).key("LFO", 150).key("LEFT", 150).key("RIGHT", 150).key("YES", 150).key("NO", 150).key("OSC1", 150)
        return r.turn(2, -1, 30, every="3M", gap=100).key("OSC1", 150)
    def shots(r):
        return [sha(os.path.join(r.dir, f)) for f in sorted(os.listdir(r.dir)) if f.startswith("step") and f.endswith(".png")] + [sha(r.dir + "/end.png")]
    s = script(Run(a, "rui_off_s", syx=a.stock, env={"DTBOOT_STEPS": "1"}))
    s.env["DTBOOT_PNG_DIR"] = s.dir
    s.go(tail=50)
    m = script(Run(a, "rui_off_m", host=[], env={"DTBOOT_STEPS": "1"}))
    m.env["DTBOOT_PNG_DIR"] = m.dir
    m.go(tail=50)
    x, y = shots(s)[-13:], shots(m)[-13:]
    check("remote_off: engine connected, closed: each screen as stock's, NOISE's last but for its two knobs", x[:-2] == y[:-2] and len(x) == 13 and noise_same(s.dir + "/end.png", m.dir + "/end.png"), f"{len(x)} screens, {sum(p != q for p, q in zip(x[:-2], y[:-2]))} differ")
    check("remote_off: nothing of the page on the wire", not [z for z in m.msgs if z[4] in (0x30, 0x31, 0x32)], "")


def t_remote_kit(a):
    """A kit change reaches the engine: 3B <version> <kit> on the wire, read, not counted bad. The kit's second T1 has a machine too, so that its 3B goes."""
    r = Run(a, "rui_kit", host=[]).overbridge().machine(1, 1)
    r.t += SHOWN
    r.midi("903c64", 100).midi("803c00", 200)
    r.key("KIT", 200).key("DOWN", 120).key("YES", 300).key("DOWN", 120).key("YES", 400).key("NO", 200)
    r.machine(1, 1)
    r.midi("903c64", 100).midi("803c00", 200).go(tail=400)
    said = [bytes(m) for m in r.msgs if m[4] == 0x3b]
    kits = [m[6] for m in said if len(m) == 8 and m[5] == 1]
    check("remote_kit: 3B as the engine reads it: 1, the kit", len(kits) == len(said) and kits, str([m.hex() for m in said[:4]]))
    check("remote_kit: the change goes out, both kits", len(set(kits)) >= 2 and kits[0] != kits[-1], str(kits[:8]))
    bad = re.findall(r"turns \d+, bad (\d+)", r.side)
    check("remote_kit: the engine counts none bad", bad and all(b == "0" for b in bad), str(bad))
    check("remote_kit: a machine in each kit plays, no fault", r.count(4) >= 2 and r.rc == 0 and not r.faults(), f"{r.count(4)} trigs; " + "; ".join(r.faults()[:2]))


def t_remote_pages(a):
    """The pages and the screen together: chords and a preview under an open page; a hatched knob with the page closed; open and close leave the hatched knobs right."""
    def picked(name, steps, **kw):                                      # the hello over, a machine on T1, still on NOISE
        r = Run(a, name, **kw).overbridge()
        r.t += SHOWN
        return r.key("TRACK1", 120).key("OSC1", 150).nudge(3, 1, 60, steps)
    def opened(r):
        r.up_yes()
        r.t += 250
        return r
    def since(r, t):
        it = iter(m for m in r.msgs if m[4] in (4, 0x11))
        return [(4, m[6]) if k == 4 else (0x11,) for c, k in r.sent() if k in (4, 0x11) for m in [next(it, None)] if m and c / 1e6 >= t]
    def frame(r):
        return bitmap(r.dir + "/end.png") == frame_rows(r.dir + "/frame.bin")
    def opens(r):
        return [list(x[6:9]) for x in r.msgs if x[4] == 0x30]
    def chord(name, stay):                                              # 6-OP FM, a mono track; four notes on its first step, on NOISE yet
        return grid_chord(picked(name, 4, host=[]), notes=FOUR, stay=stay)

    r = opened(chord("rp_seq", False))
    t = r.t
    r.key("PLAY", 1200).key("STOP", 300).go(tail=200)
    ev = [e for e in since(r, t) if e[0] == 4]
    bars = [ev[i:i + 4] for i in range(0, len(ev), 4)]
    check("remote_pages: page open: each bar's chord whole, in order", len(bars) >= 2 and all(b == [(4, n) for n in (60, 64, 67, 71)] for b in bars), str(ev[:9]))
    check("remote_pages: the page stayed up over the chords, the engine's frame", opens(r) == [[0, 1, 0]] and frame(r) and r.rc == 0 and not r.faults(), f"{opens(r)} " + "; ".join(r.faults()[:2]))
    def held(r, ms=700):                                                # the trig held, YES; a preview's press
        t = r.t
        r.args += ["--press", f"T1@{t}M:{ms}M", "--press", f"YES@{t + 150}M:100M"]
        r.t = t + ms + 100
        return t
    p = chord("rp_prev", True)                                          # a preview ringing when the page opens. With the page up YES is the page's: below
    t = held(p, 280)
    opened(p).go(tail=300)
    ev = since(p, t)
    check("remote_pages: a preview as the page opens: all four notes, one 11", ev == [(4, n) for n in (60, 64, 67, 71)] + [(0x11,)], str(ev))
    check("remote_pages: and the page opened over it, the engine's frame", opens(p) == [[0, 1, 0]] and frame(p) and p.rc == 0 and not p.faults(), str(opens(p)))
    y = opened(chord("rp_yes", True))                                   # the page open first: YES is the page's, so a held trig previews nothing
    t = held(y)
    y.go(tail=300)
    check("remote_pages: page open, YES on a held trig is the page's: no preview", not since(y, t) and [x for x in y.msgs if x[4] == 0x31 and x[7] == 0x44] and y.rc == 0 and not y.faults(), str(since(y, t)))
    c = opened(chord("rp_after", True)).key("NO", 300)
    t = held(c)
    c.go(tail=300)
    ev = since(c, t)
    check("remote_pages: the page closed again: the same trig previews whole", ev == [(4, n) for n in (60, 64, 67, 71)] + [(0x11,)] and opens(c) == [[0, 1, 0], [0, 0, 1]], str(ev))

    i, q = picked("rp_idle", 2, host=[]).key("OSC1", 150), picked("rp_turn", 2, host=[]).key("OSC1", 150)   # JUNO, never opened: OSC1's B empty
    i.t += 150
    q.turn(1, 1, 40, every="3M", gap=150)
    i.go(tail=100), q.go(tail=100)
    check("remote_pages: closed, an engine there: a hatched knob's turn leaves the screen", sha(i.dir + "/end.png") == sha(q.dir + "/end.png"), f"{sha(i.dir + '/end.png')} {sha(q.dir + '/end.png')}")
    check("remote_pages: closed: no 32 for it, the machine's values stay", not [x for x in q.msgs if x[4] == 0x32] and reports(q) and [v for c, v in reports(i)][-1:] == [v for c, v in reports(q)][-1:], f"{len(reports(q))} reports, 32s {len([x for x in q.msgs if x[4] == 0x32])}")

    s = Run(a, "rp_stock", syx=a.stock, usb=False).key("TRACK1", 120).key("OSC1", 150).go(tail=50)
    empty = bitmap(s.dir + "/end.png")
    def juno(name, keys=(), **kw):                                      # to OSC1, the page, and the keys: a Sidecar's page and out of it, or with none stock's UP alone
        r = picked(name, 2, **kw).key("OSC1", 300)
        if kw.get("host") is None:
            r.args += ["--press", f"UP@{r.t}M:300M"]
            r.t += 330 + 250
        else:
            opened(r)
        r.t += 300
        for k in keys:
            r.key(k, 300)
        return r
    x, w = juno("rp_x", ("NO",), host=[]).go(tail=100), juno("rp_w").go(tail=100)
    bx = bitmap(x.dir + "/end.png")
    check("remote_pages: open, NO: JUNO's OSC1 page as with no Sidecar", bx == bitmap(w.dir + "/end.png"), "")
    check("remote_pages: its empty knob is stock's empty knob", cell(bx, 1) == cell(empty, 6), "")
    check("remote_pages: both ways: opened, and NO on SIDECAR: the engine closes it", opens(x) == [[0, 1, 0], [0, 0, 1]], str(opens(x)))
    y, z = juno("rp_y", ("OSC2",), host=[]).go(tail=100), juno("rp_z", ("OSC2",)).go(tail=100)
    check("remote_pages: a page key out: OSC2 stock's, as with no Sidecar", bitmap(y.dir + "/end.png") == bitmap(z.dir + "/end.png") and opens(y) == [[0, 1, 0], [0, 0, 3]], str(opens(y)))
    m, n = juno("rp_m", ("TRACK2", "NO"), host=[]), juno("rp_n", ("TRACK2",))
    n.t += 300                                                          # the sound's name leaves the band as long after TRACK2 as NO's press
    m.go(tail=100), n.go(tail=100)
    check("remote_pages: TRACK2 chosen under the page, OFF: stock's knobs after it, no hatching left", bitmap(m.dir + "/end.png") == bitmap(n.dir + "/end.png"), str(opens(m)))
    u, v = juno("rp_u", ("NO",), host=[]), juno("rp_v", ("NO",), host=[])
    v.turn(1, 1, 40, every="3M", gap=150)
    u.t += 150
    u.go(tail=100), v.go(tail=100)
    check("remote_pages: after a close a hatched knob is still dead", sha(u.dir + "/end.png") == sha(v.dir + "/end.png") and not [z for z in v.msgs if z[4] == 0x32], "")


TESTS = {"labels": t_labels, "title": t_title, "off": t_off, "knobs": t_knobs, "zones": t_zones, "map": t_map, "fin": t_fin, "lock": t_lock, "pages": t_pages, "analog2": t_analog2, "os2": t_os2, "pick": t_pick, "locks": t_locks, "lfos": t_lfos, "power2": t_power2, "fresh": t_fresh, "am1": t_am1, "rollback": t_rollback, "chord": t_chord, "chord_keys": t_chord_keys, "mono": t_mono, "mono_chord": t_mono_chord, "poly_voices": t_poly_voices, "mono_gap": t_mono_gap, "mono_stall": t_mono_stall, "chord_labels": t_chord_labels, "hatched": t_hatched, "preview": t_preview, "kit": t_kit, "poly": t_poly, "user": t_user, "no_pi": t_no_pi, "computer": t_computer, "seq": t_seq, "strict": t_strict, "params": t_params, "stall": t_noread, "gone": t_gone, "power": t_stock_after,
         "remote_open": t_remote_open, "remote_keys": t_remote_keys, "remote_exit": t_remote_exit, "remote_play": t_remote_play, "remote_splash": t_remote_splash, "remote_pair": t_remote_pair, "remote_link": t_remote_link, "remote_voice": t_remote_voice, "remote_old": t_remote_old, "remote_off": t_remote_off, "remote_kit": t_remote_kit, "remote_pages": t_remote_pages, "upyes": t_upyes, "octave": t_octave, "octave_back": t_octave_back, "low": t_low}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--emu", required=True); ap.add_argument("--stock", required=True); ap.add_argument("--syx", required=True)
    ap.add_argument("--card", required=True); ap.add_argument("--out", required=True); ap.add_argument("--engine"); ap.add_argument("--old-engine"); ap.add_argument("--prev", help="the build before: its kits, for the fresh test"); ap.add_argument("--port", type=int, default=PORT); ap.add_argument("names", nargs="*")
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)
    for n in a.names or TESTS:
        if (n.startswith("remote_") or n in ("upyes", "octave", "octave_back", "low")) and not a.engine:
            check(f"{n}: needs --engine", False)
            continue
        print(n, flush=True)
        TESTS[n](a)
    bad = [n for n, ok in RESULTS if not ok]
    print(f"{'PASS' if not bad else 'FAIL'}: {len(RESULTS) - len(bad)}/{len(RESULTS)}")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
