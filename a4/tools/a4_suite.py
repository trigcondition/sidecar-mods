#!/usr/bin/env python3
"""The mod's suite in the emulator: analog-emu's dtboot, the firmware's own USB stack. Nothing here talks to a unit.

    a4_suite.py --emu DIR --stock STOCK.syx --syx OS.syx --card IMG --out DIR [names...]

Firmware-derived outputs stay in --out. Exit 0 when every test passes."""
import argparse, hashlib, os, re, subprocess, sys, wave, struct, zlib
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from decode import messages

RESULTS = []
TITLE_PLTS_HRM = "ffe3ff35a4e2"


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
    kits = [m[5] for m in r.msgs if m[4] == 0x3b]
    check("kit: the kit reported, and its change", len(set(kits)) >= 2, str(kits[:8]))
    check("kit: the machine stays with the sound of the kit it was set in", r.count(4) == 1, f"{r.count(4)} trigs")
    check("kit: no fault", r.rc == 0 and not r.faults(), "; ".join(r.faults()[:2]))


def t_user(a):
    """U5 turned past the end of the list, U1 one step on from B2 (the emulator's nudges drop some steps above 4, so the counts are by test)."""
    r = Run(a, "user").overbridge().machine(1, 30)
    r.midi("903c64", 100).midi("803c00", 100).go()
    q = Run(a, "user1").overbridge().machine(1, 8)
    q.midi("903c64", 100).midi("803c00", 100).go()
    tr = [x[5] for x in r.msgs + q.msgs if x[4] == 4]
    check("user: U5 past the end of the list, U1 after the last built-in, by their flags", tr == [0x70, 0x50], str(tr))
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


# P of each knob A..J on the four pages (a4_page.c's p_of_id), 0 a stock knob, and each machine's names (README).
KNOBS = {"osc1": (1, 0, 2, 0, 0, 0, 0, 3, 4, 5), "noise": (0, 11, 12, 0, 0, 0, 0, 0, 0, 0), "osc2": (6, 0, 7, 0, 0, 0, 0, 8, 9, 10), "x": (0, 0, 0, 13, 14, 0, 0, 15, 0, 0)}
STOCK_LABELS = {"osc1": STOCK_PAGES["OSC1"].split(), "osc2": STOCK_PAGES["OSC1"].split(), "x": STOCK_PAGES["OSC2"].split(), "noise": ["SNH", "COL", "FAD", "", "LEV", "", "", "", "", ""]}
NAMES = {"PLTS": "ENG HRM TIM MOR DEC LPG TUN LEV FM FIN AUX TMD MMD VEL GLD", "JUNO": "PAT CUT RES ENV ATK DEC REL LEN", "DSY": "ENG STR BRI DMP INP EXC TUN LEV XTN XDC FB OUT XP4 XLV XP5",
         "FM6": "PAT TIM MOR DEC LPG TUN LEV LEN", "MD": "CT1 CT2 CT3 CT4 CT5 CT6 CT7 CT8 ENG TYP LEV", "U1": "P1 P2 P3 P4 P5 P6 P7 P8 P9 P10 P11 P12 P13 P14 P15"}


def to_page(r, page):
    """From the OSC1 page, which machine() ends on, to a page, by stock's own keys."""
    {"osc1": lambda: None, "noise": lambda: r.key("OSC1", 150), "osc2": lambda: r.key("OSC2", 150), "x": lambda: r.key("OSC2", 150).key("OSC2", 150)}[page]()
    return r


def want_labels(machine, page):
    n = NAMES[machine].split()
    return [(n[p - 1] if p and p <= len(n) else s) for p, s in zip(KNOBS[page], STOCK_LABELS[page])]


def same(got, want):
    """A letter stock did not teach passes as ?; O is 0's glyph; an empty knob is hatched, no glyph of the font."""
    if not want:
        return set(got) <= {"?"}
    want = want.replace("0", "O")
    return len(got) == len(want) and all(g == w or (g == "?" and w != "?") for g, w in zip(got, want))


def t_labels(a):
    font = learn_font(a)
    check("labels: stock's screens teach enough letters", len(font) >= 20, "".join(sorted(font.values())))
    for machine, steps in (("PLTS", 1), ("JUNO", 2), ("DSY", 3), ("FM6", 4), ("MD", 5), ("U1", 8)):
        for page in KNOBS:
            r = to_page(Run(a, f"lab_{machine}_{page}", usb=False).machine(1, steps), page).go()
            got, want = page_text(r.dir + "/end.png", font), want_labels(machine, page)
            ok = all(same(g, w) for g, w in zip(got, want))
            check(f"labels: {machine} on {page}", ok and r.rc == 0 and not r.faults(), " ".join(x or "-" for x in got))


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
    q = Run(a, "side", usb=False).key("TRACK1", 120).key("OSC1", 150).key("OSC1", 150).go()
    check("title: the SIDECAR knob's label is its own", page_text(q.dir + "/end.png", font)[0][0] == "M" and page_text(q.dir + "/end.png", font)[0][2] == "H", page_text(q.dir + "/end.png", font)[0])


def t_off(a):
    """Every sound OFF, and a track OFF beside one with a machine: the screens step by step as stock's, a turned knob's title and value too."""
    def script(r, track):
        r.key(f"TRACK{track}", 120).key("OSC2", 150).key("OSC2", 150).key("OSC1", 150).key("FILTERS", 150).key("AMP", 150).key("OSC2", 150).key("OSC1", 150)
        return r.turn(2, -1, 30, every="3M", gap=100).key("OSC1", 150)
    def shots(r):
        return [sha(os.path.join(r.dir, f)) for f in sorted(os.listdir(r.dir)) if f.startswith("step") and f.endswith(".png")] + [sha(r.dir + "/end.png")]
    env = lambda n: {"DTBOOT_PNG_DIR": os.path.join(a.out, n), "DTBOOT_STEPS": "1"}
    s = script(Run(a, "off_s", syx=a.stock, usb=False, env=env("off_s")), 1).go(tail=50)
    m = script(Run(a, "off_m", usb=False, env=env("off_m")), 1).go(tail=50)
    x, y = shots(s), shots(m)
    check("off: every sound OFF: each screen as stock's", x == y and len(x) >= 8, f"{len(x)} screens, {sum(p != q for p, q in zip(x, y))} differ")
    s2 = script(Run(a, "off_s2", syx=a.stock, usb=False, env=env("off_s2")), 2).go(tail=50)
    m2 = script(Run(a, "off_m2", usb=False, env=env("off_m2")).machine(1, 1), 2).go(tail=50)
    x2, y2 = shots(s2), shots(m2)[-len(shots(s2)):]
    check("off: T2 OFF beside T1 with a machine: its screens as stock's", x2 == y2, f"{len(x2)} screens, {sum(p != q for p, q in zip(x2, y2))} differ")


def reports(r, voice=0):
    """(time in M, [P1..P15 as 14 bits]) of a voice's 03 reports."""
    it, out = iter(m for m in r.msgs if m[4] in (3, 4)), []
    for c, k in r.sent():
        if k in (3, 4):
            m = next(it, None)
            if m is not None and m[4] == 3 and m[5] & 7 == voice:
                out.append((c / 1e6, [h * 128 + l for h, l in zip(m[6::2][:15], m[7::2][:15])]))
    return out


def t_knobs(a):
    """Each knob the machine reads moves its P and no other, over 0..127; each stock knob none. The kit's own LFO on OSC1 DET runs through P2: left out of the moves, and proof that an LFO reaches a P."""
    for page, ps in KNOBS.items():
        r = to_page(Run(a, "knob_" + page).overbridge().machine(1, 1).key("OSC2", 150).key("OSC1", 150), page)
        win = []
        for e in range(10):
            t0 = r.t
            r.turn(e, -1, 500, gap=200).turn(e, 1, 500, gap=200)
            win.append((t0, r.t))
        r.go(tail=100)
        rep = reports(r)
        bad, full = [], True
        for e, (t0, t1) in enumerate(win):
            w = [v for c, v in rep if t0 <= c < t1]
            moved = {k + 1 for k in range(15) if k != 1 and len({x[k] for x in w}) > 1}
            if e == 2 and page == "osc1":                   # P2's own knob
                moved |= {2}
            want = {ps[e]} - {0}
            if (page == "osc1" and e == 1) or (page == "osc2" and e == 1):     # FIN is P1's, P6's fraction
                want = {1 if page == "osc1" else 6}
            if moved != want:
                bad.append((e, sorted(moved), sorted(want)))
            if ps[e]:
                lo, hi = min(x[ps[e] - 1] for x in w), max(x[ps[e] - 1] for x in w)
                top = 16256
                if not (lo <= 128 and hi >= top):
                    full, bad = False, bad + [(e, lo / 128, hi / 128)]
        check(f"knobs: {page}: each knob moves its P, 0..127 (TUN 1..127)", not bad and full and rep, str(bad[:4]))
        if page == "osc1":
            lfo = [v[1] for c, v in rep if c < win[0][1]]
            check("knobs: an LFO moves its P (this kit's LFO 2 on DET)", len(set(lfo)) > 20, f"P2 {min(lfo) / 128:.1f}..{max(lfo) / 128:.1f}")


def t_zones(a):
    """TUN turned slowly from end to end: every one of PLAITS' 17 ENG zones (core/machines.h eng_zone) reported, in order."""
    r = Run(a, "zones").overbridge().machine(1, 1).key("OSC2", 150).key("OSC1", 150).turn(0, -1, 500, gap=200)
    t = r.t
    r.turn(0, 1, 1000, every="1M", gap=1050).go(tail=100)
    z = [min(int(v[0] / 128) * 17 >> 7, 16) for c, v in reports(r) if c > t]
    check("zones: PLAITS ENG reaches all 17 engines, stepping up", sorted(set(z)) == list(range(17)) and z == sorted(z), f"{len(set(z))} zones, {len(z)} reports")


def t_fin(a):
    """FIN under TUN's lowest: PAT 0 of a list. FIN over TUN's highest stays in range."""
    r = Run(a, "fin").overbridge().machine(1, 2).key("OSC2", 150).key("OSC1", 150).turn(0, -1, 500, gap=200).turn(1, -1, 500, gap=200)
    t = r.t
    r.turn(0, 1, 500, gap=200).turn(1, 1, 500, gap=200).go(tail=100)
    v = [x[0] for c, x in reports(r)]
    lo, hi = [x[0] for c, x in reports(r) if c < t], [x[0] for c, x in reports(r) if c > t + 250]
    check("fin: TUN down and FIN down: P1's integer reaches 0; both up it stays at the top, no wrap", min(lo) < 128 and hi and min(hi) > 16000, f"P1 {min(lo) / 128:.2f}, then {min(hi) / 128:.2f}..{max(hi) / 128:.2f}")


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


def poly_kit(r, track):
    """TRACKn, KIT > POLY CONFIG, all four voices."""
    r.key(f"TRACK{track}", 150).key("KIT", 120)
    for _ in range(5):
        r.key("DOWN", 120)
    r.key("YES", 120)
    for i in range(4):
        r.key("YES", 100)
        if i < 3:
            r.key("RIGHT", 100)
    return r.key("NO", 120).key("NO", 120).key("NO", 400)


def grid_chord(r, step="T1", notes=("KB_C1", "KB_E1", "KB_G1")):
    """An empty pattern; a trig holding a chord: GRID RECORD, the step held, the keys held together."""
    r.key("BANK_H", 120).key("T16", 500).key("RECORD", 150)
    t = r.t
    r.args += ["--press", f"{step}@{t}M:700M"]
    for i, k in enumerate(notes):
        r.args += ["--press", f"{k}@{t + 100 + i * 60}M:{400 - i * 60}M"]
    r.t += 900
    return r.key("RECORD", 200)


def seq_trigs(r):
    """(note, voice byte) of the 04s after PLAY: the grid's own key presses come before."""
    return [(x[6], x[5]) for x in r.msgs if x[4] == 4]


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
    """No POLY CONFIG: a trig is one 04 and its end one 11, what it always was; a chord on a mono track's step plays its first note, as the A4 does; two notes closer than 20 ms get an 11 between them."""
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
    grid_chord(q)
    q.key("PLAY", 800).key("STOP", 300).go(tail=300)
    tr = [x for x in seq_trigs(q)][-1:]
    check("mono: a chord on a mono track's step: its first note", tr == [(60, 0)], str(seq_trigs(q)[-4:]))


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


TESTS = {"labels": t_labels, "title": t_title, "off": t_off, "knobs": t_knobs, "zones": t_zones, "fin": t_fin, "lock": t_lock, "chord": t_chord, "chord_keys": t_chord_keys, "mono": t_mono, "chord_labels": t_chord_labels, "kit": t_kit, "poly": t_poly, "user": t_user, "no_pi": t_no_pi, "computer": t_computer, "seq": t_seq, "strict": t_strict, "params": t_params, "stall": t_noread, "gone": t_gone, "power": t_stock_after}


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
