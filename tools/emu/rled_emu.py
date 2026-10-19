#!/usr/bin/env python3
"""Emulator tests of 0026's 1026 additions: TRK + LFO opens the remote page on the Sidecar's LFO page (the 30's page byte
1), and the host's trig key LEDs (34) while the page is open; the trig keys caught by the catch mask (37).

    .venv/bin/python tools/emu/rled_emu.py TAG TEST [TEST ...]     exit 0 when every check passes
    .venv/bin/python tools/emu/rled_emu.py TAG all

TAG: a 0026 build (rui1026), its base made by tools/emu/us_base.sh TAG. Every run under DTEMU_STRICT=1 with a
simulated USB host (--usb-host --usb-midi-real); the host's SysEx goes in with dtboot --usb-midi at fixed clocks (a
keepalive 3C every 100 ms), the Rytm's USB MIDI comes out in DTBOOT_USB_OUT. The panel MCU's LED slots and selectors
are read from the run's end snapshot (dtpeek leds). Times are M instructions after the base (10 M = one UI tick, 200 M
= 1 s). `stockcombo` boots the stock 1.73 image (stock/, a fresh card) for the stock behaviour of TRK + LFO.
Firmware-derived files stay in rytm-emu's git-ignored fw/ and sections/ and in build/emu/TAG. RYTM_EMU: the checkout.
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
STOCK = os.path.join(ROOT, "stock", "Analog-Rytm_MKII_OS1.73.syx")
K_TRK, K_LFO, K_T3 = 0x86, 0x35, 0x02
BLUE, ORANGE = 47, 52        # palette: (0, 0, 31) and (11, 6, 0) [measured, the OS's palette in rytm-emu]
# struct rui (rui.c) after splash_why (988): pend_hello 992, pend_page 993, then these (m68k: ints on 2-byte bounds)
OFF = dict(active=4, last_reason=296, lfo_opens=994, lfo_hints=998, led_seen=1002, led_want=1006, led_paints=1010,
           led_restores=1014, led_busy=1018)
FAILS = []


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"   [{detail}]" if detail else ""), flush=True)
    if not ok:
        FAILS.append(name)


def sx(cmd, *body):
    return bytes([0xF0, 0x7D, 0x52, 0x54, cmd, 0x01, *body, 0xF7]).hex()


def mask_trigs():
    """37: no encoder; key codes 0..15 (T1..T16) caught: bit c % 7 of k(c / 7)."""
    k = [0] * 3
    for c in range(16):
        k[c // 7] |= 1 << (c % 7)
    return sx(0x37, 0, 0, 0, *k)


def leds(colours):
    return sx(0x34, 1, *colours)


class Emu:
    def __init__(self, tag):
        self.tag = tag
        self.fw = f"fw/AR173_us_{tag}.syx"
        self.card = os.path.join(EMU, f"sections/us_{tag}.img")
        self.snap = f"sections/us_{tag}.snap"
        self.clock = json.load(open(os.path.join(EMU, f"sections/us_{tag}.json")))["clock"]
        self.out = os.path.join(ROOT, "build", "emu", tag)
        os.makedirs(self.out, exist_ok=True)
        self.syms = json.load(open(os.path.join(self.out, "manifest.json")))["elek"]["symbols"]
        self.tmp = tempfile.mkdtemp()
        self.alive = os.path.join(self.tmp, "alive.syx")
        open(self.alive, "wb").write(bytes.fromhex(sx(0x3C)))

    def sym(self, name):
        return self.syms["rytm-0026-remote-ui:" + name]

    def run(self, name, length, events=(), alive=(0, None), fw=None, snap=None, clock=None, card=None):
        """events: (at, 'press', KEY[:hold M]) / (at, 'sx', HEX). alive: keepalives every 20 M from .. to (None: the
        end; () none). -> dict(msgs, snap, oled)."""
        start = self.clock if clock is None else clock
        end_snap = os.path.join(self.out, f"rled_{name}.snap")
        cmd = ["./target/release/dtboot", fw or self.fw, "--load", snap or self.snap, "--card", card or self.card,
               "--instr", f"{length}M", "--every", f"{length}M", "--usb-host", "--usb-midi-real", "--save", end_snap]
        if alive:
            a0, a1 = alive
            n = ((a1 if a1 is not None else length) - a0) // 20 + 1
            cmd += ["--usb-midi-file", f"{self.alive}@{start + a0}Mx{n}/20M"]
        for at, kind, val in events:
            if kind == "press":
                k, _, hold = val.partition(":")
                cmd += ["--press", f"{k}@{start + at}M" + (f":{hold}M" if hold else "")]
            elif kind == "sx":
                cmd += ["--usb-midi", f"{val}@{start + at}M"]
        out = os.path.join(self.tmp, f"{name}.usb")
        env = dict(os.environ, DTEMU_STRICT="1", DTBOOT_USB_OUT=out, DTBOOT_OLED="1")
        r = subprocess.run(cmd, cwd=EMU, env=env, capture_output=True, text=True)
        log = r.stdout + r.stderr
        open(os.path.join(self.out, f"rled_{name}.dt.txt"), "w").write(log)
        bad = r.returncode != 0 or "FAULT" in log or "strict:" in log
        check(f"{name}: dtboot ran clean (strict, no fault)", not bad,
              "" if not bad else str(re.findall(r".*(?:FAULT|strict:).*", log)[:3] or f"rc {r.returncode}"))
        raw = open(out, "rb").read() if os.path.exists(out) else b""
        i = log.rfind("panel MCU OLED")
        return dict(msgs=[m.group(0) for m in re.finditer(rb"\xf0[^\xf0\xf7]*\xf7", raw)], snap=end_snap,
                    oled=log[i:].split("\n", 1)[1][:4200] if i >= 0 else None, fw=fw or self.fw)

    def peek(self, res, addr, n):
        r = subprocess.run(["./target/release/dtpeek", res["snap"], "mem", f"{addr:x}", str(n)], cwd=EMU,
                           env=dict(os.environ, DTEMU_FW=res["fw"]), capture_output=True, text=True)
        b = bytearray()
        for line in r.stdout.splitlines():
            m = re.match(r"^[0-9a-f]+: ((?:[0-9a-f]{2} ?)+)", line)
            if m:
                b += bytes.fromhex(m.group(1).replace(" ", ""))
        return bytes(b[:n])

    def st(self, res, field):
        return int.from_bytes(self.peek(res, self.sym("st") + OFF[field], 4), "big")

    def panel(self, res):
        """The panel MCU: {led: [slot colours]}, the selector bytes, the unknown-message count."""
        r = subprocess.run(["./target/release/dtpeek", res["snap"], "leds"], cwd=EMU,
                           env=dict(os.environ, DTEMU_FW=res["fw"]), capture_output=True, text=True).stdout
        slots = {int(a): [int(x, 16) for x in b.split(", ")] for a, b in re.findall(r"^led (\d+): slots \[([^\]]*)\]", r, re.M)}
        sel = re.search(r"^selectors: (.*)$", r, re.M).group(1)
        unk = int(re.search(r"unknown (\d+)", r).group(1))
        return slots, sel, unk


def modes(msgs):
    """The 30s: [(page, on, reason)]."""
    return [(m[6], m[7], m[8]) for m in msgs if m[4:6] == b"\x30\x01" and len(m) == 10]


def keys(msgs):
    return [(m[6] << 7 | m[7], m[8]) for m in msgs if m[4:6] == b"\x31\x01" and len(m) == 10]


def t_combo(e):
    """TRK + LFO: 30 (page 1, on, user), the LFO key never reaches stock (after leaving, the screen is the one TRK + YES
    in and out leaves, not the stock LFO page) nor the host; again while open: the 30 again, the page stays open;
    TRK + YES leaves (escape); the machines' snapshot (33) after the first 30 only."""
    ev = [(20, "press", "TRK:60"), (30, "press", "LFO"), (100, "press", "TRK:60"), (110, "press", "LFO"),
          (200, "press", "TRK:60"), (210, "press", "YES")]
    a = e.run("combo", 300, ev)
    b = e.run("combo-yes", 300, [(20, "press", "TRK:60"), (30, "press", "YES"), (100, "press", "TRK:60"),
                                 (200, "press", "TRK:60"), (210, "press", "YES")])
    c = e.run("combo-lfo", 300, [(30, "press", "LFO")])
    md = modes(a["msgs"])
    print(f"  30s: {md}; host keys: {[(hex(k), d) for k, d in keys(a['msgs'])]}")
    check("combo: TRK + LFO opens the page on the LFO page (30 page 1, on, user)", md[:1] == [(1, 1, 0)], md)
    check("combo: again while open: the 30 (page 1, on, user) again, no close between", md[1:2] == [(1, 1, 0)], md)
    check("combo: TRK + YES then leaves (30 page 0, off, escape)", md[2:] == [(0, 0, 3)], md)
    check("combo: the LFO key never reaches the host", all(k != K_LFO for k, _ in keys(a["msgs"])))
    snaps = [i for i, m in enumerate(a["msgs"]) if m[4:6] == b"\x33\x01" and len(m) == 33]
    first = next(i for i, m in enumerate(a["msgs"]) if m[4:6] == b"\x30\x01")
    check("combo: the machines' snapshot follows the open", any(i > first for i in snaps), snaps)
    check("combo: lfo_opens 1, lfo_hints 1", (e.st(a, "lfo_opens"), e.st(a, "lfo_hints")) == (1, 1),
          (e.st(a, "lfo_opens"), e.st(a, "lfo_hints")))
    check("combo: after leaving, the stock screen equals TRK + YES in and out (the LFO page never opened)",
          a["oled"] is not None and a["oled"] == b["oled"])
    check("combo: (control) LFO alone opens the stock LFO page: a different screen", c["oled"] != b["oled"])
    check("combo: TRK + YES still opens page 0", modes(b["msgs"])[:1] == [(0, 1, 0)], modes(b["msgs"]))


def t_stockcombo(e):
    """Stock 1.73: TRK + LFO on the main screen does what LFO alone does (opens the LFO page; TRK adds nothing) and TRK
    alone changes nothing, so 0026 taking the combo takes no stock function."""
    fw, card, snap = "fw/AR173_rled_stock.syx", os.path.join(EMU, "sections/rled_stock.img"), "sections/rled_stock.snap"
    if not os.path.exists(os.path.join(EMU, snap)):
        shutil.copy(STOCK, os.path.join(EMU, fw))
        shutil.copy(os.path.join(EMU, "sections/led.img"), card)
        subprocess.run(["./target/release/dtboot", fw, "--instr", "4800M", "--every", "4800M", "--card", card,
                        "--press", "YES@2600M", "--press", "NO@3000M", "--press", "NO@3400M", "--press", "NO@3800M",
                        "--save", snap], cwd=EMU, capture_output=True)
    kw = dict(fw=fw, snap=snap, clock=4800, card=card, alive=())
    n = e.run("st-none", 300, **kw)
    t = e.run("st-trk", 300, [(20, "press", "TRK:60")], **kw)
    tl = e.run("st-trklfo", 300, [(20, "press", "TRK:60"), (40, "press", "LFO")], **kw)
    lf = e.run("st-lfo", 300, [(40, "press", "LFO")], **kw)
    check("stockcombo: TRK alone leaves the main screen as it was", t["oled"] == n["oled"])
    check("stockcombo: TRK + LFO = LFO alone (the stock LFO page)", tl["oled"] == lf["oled"])
    check("stockcombo: and that is a different screen (the LFO page opened)", lf["oled"] != n["oled"])


GRID = [(10, "press", "RECORD"), (20, "press", "T1"), (30, "press", "T5"), (40, "press", "RECORD")]
OPEN = [(70, "press", "TRK:60"), (80, "press", "YES")]
COLS = [BLUE] * 8 + [ORANGE] * 8


def t_leds(e):
    """Trigs on T1 / T5, playing; the page open; 34 1 (T1..T8 blue, T9..T16 orange): every slot of LEDs 0..15 holds the
    host's colour while the sequencer runs underneath (stock's slot messages rewritten), nothing else changes; STOP,
    TRK + YES: the LEDs equal a run without the 34 (stock's own state back)."""
    # GRID RECORD stays on and PLAY comes after the 34: stock writes the play position's white (0x6f) into the trig
    # LEDs' slots under the host's colours (later steps only move the selectors)
    base = GRID[:3] + OPEN + [(150, "press", "PLAY")]   # after TRK's release (130)
    a = e.run("leds-on", 220, base + [(100, "sx", leds(COLS))])
    ctl_a = e.run("leds-on-ctl", 220, base)
    s, sel, unk = e.panel(a)
    cs, csel, cunk = e.panel(ctl_a)
    sub = int.from_bytes(e.peek(a, e.sym("uart_sub"), 4), "big")
    print(f"  on: LED 0 {s[0]}, LED 8 {s[8]}, control LED 0 {cs[0]} / LED 4 {cs[4]}; rewritten {sub}")
    check("leds: T1..T8 blue, T9..T16 orange in every slot", all(s[i] == [COLS[i]] * 4 for i in range(16)),
          [s[i] for i in range(16)])
    check("leds: stock wrote the trig LEDs under it (the play position; rewritten bytes > 0)", sub > 0, sub)
    check("leds: every other LED as without the 34", all(s[i] == cs[i] for i in s if i >= 16))
    check("leds: one paint, page open, no unknown message more than without the 34", e.st(a, "led_paints") == 1 and
          e.st(a, "active") == 1 and unk == cunk, (e.st(a, "led_paints"), unk, cunk))
    tail = [(230, "press", "STOP"), (260, "press", "TRK:60"), (270, "press", "YES")]
    b = e.run("leds-off", 360, base + [(100, "sx", leds(COLS))] + tail)
    ctl = e.run("leds-off-ctl", 360, base + tail)
    s, sel, unk = e.panel(b)
    cs, csel, _ = e.panel(ctl)
    print(f"  off: LED 0 {s[0]}, LED 1 {s[1]}, LED 4 {s[4]}; control {cs[0]} {cs[1]} {cs[4]}")
    check("leds: after leaving every LED's slots equal the run without the 34", s == cs,
          [i for i in s if s[i] != cs.get(i)])
    check("leds: and the selectors", sel == csel)
    check("leds: trigs back red on T1 / T5 (slot 0x0f)", 0x0F in s[0] and 0x0F in s[4], (s[0], s[4]))
    check("leds: restored once, left by escape", e.st(b, "led_restores") == 1 and modes(b["msgs"])[-1] == (0, 0, 3),
          (e.st(b, "led_restores"), modes(b["msgs"])))


def t_ledexit(e):
    """34 0 gives the LEDs back at once; the timeout (host gone) gives them back; a 34 while the page is closed does
    nothing, nor does it come back at the next open."""
    a = e.run("lx-mode0", 260, GRID + OPEN + [(100, "sx", leds(COLS)), (160, "sx", sx(0x34, 0))])
    c = e.run("lx-ctl", 260, GRID + OPEN)
    s, _, _ = e.panel(a)
    cs, _, _ = e.panel(c)
    check("ledexit: 34 0 -> stock's LEDs, the page still open", s == cs and e.st(a, "active") == 1 and
          e.st(a, "led_restores") == 1, [i for i in s if s[i] != cs.get(i)])
    t = e.run("lx-timeout", 420, GRID + OPEN + [(100, "sx", leds(COLS))], alive=(0, 150))
    tc = e.run("lx-timeout-ctl", 420, GRID + OPEN, alive=(0, 150))
    s, _, _ = e.panel(t)
    cs, _, _ = e.panel(tc)
    md = modes(t["msgs"])
    check("ledexit: the host gone -> the page leaves (timeout) and the LEDs are stock's", md[-1:] == [(0, 0, 2)] and
          s == cs and e.st(t, "led_restores") == 1, (md, [i for i in s if s[i] != cs.get(i)]))
    k = e.run("lx-closed", 300, GRID + [(50, "sx", leds(COLS))] + OPEN)
    kc = e.run("lx-closed-ctl", 300, GRID + OPEN)
    s, _, _ = e.panel(k)
    cs, _, _ = e.panel(kc)
    check("ledexit: a 34 before the open does nothing, also after the open", s == cs and e.st(k, "led_paints") == 0,
          e.st(k, "led_paints"))


def t_bad(e):
    """Malformed 34s change nothing: mode 2, a short colour list, a colour of 112 (the animated palette)."""
    rx0 = None
    a = e.run("lx-bad", 260, GRID + OPEN + [(100, "sx", sx(0x34, 2)), (110, "sx", sx(0x34, 1, *COLS[:15])),
                                            (120, "sx", sx(0x34, 1, *([112] + COLS[1:])))])
    c = e.run("lx-bad-ctl", 260, GRID + OPEN)
    s, _, _ = e.panel(a)
    cs, _, _ = e.panel(c)
    bad = int.from_bytes(e.peek(a, e.sym("rx_bad"), 4), "big")
    check("bad: three malformed 34s counted, LEDs stock's, no paint", bad == 3 and s == cs and
          e.st(a, "led_paints") == 0, (bad, e.st(a, "led_paints"), rx0))


def t_trigs(e):
    """The REC page's channel keys: with the catch mask on T1..T16 (37), T3 in GRID RECORD goes to the host (31 0 2,
    down and up) and places no trig underneath (LED 3 as without the press); the control without the page places it.
    With the default mask (no 37) T3 is caught as well."""
    pre = [(10, "press", "RECORD")]
    ev = pre + [(20, "press", "TRK:60"), (30, "press", "YES"), (50, "sx", mask_trigs()), (80, "press", "T3"),
                (120, "press", "TRK:60"), (130, "press", "YES")]
    a = e.run("trigs", 200, ev)
    d = e.run("trigs-default", 200, [x for x in ev if x[1] != "sx"])
    c = e.run("trigs-ctl", 200, pre + [(80, "press", "T3")])
    n = e.run("trigs-none", 200, pre)
    s, _, _ = e.panel(a)
    sd, _, _ = e.panel(d)
    cs, _, _ = e.panel(c)
    ns, _, _ = e.panel(n)
    print(f"  LED 2: caught {s[2]}, default {sd[2]}, control {cs[2]}, no press {ns[2]}; keys {keys(a['msgs'])}")
    check("trigs: T3 reaches the host, down and up (31 0 2 1 / 0)", keys(a["msgs"]) == [(K_T3, 1), (K_T3, 0)],
          keys(a["msgs"]))
    check("trigs: (control) T3 in GRID RECORD places a trig (LED 2 red 0x0f)", 0x0F in cs[2], cs[2])
    check("trigs: caught, no trig underneath (LED 2 as with no press)", s[2] == ns[2] and 0x0F not in s[2], s[2])
    check("trigs: the default mask (no 37) catches it too", [k for k in keys(d["msgs"]) if k[0] < 16] == [(K_T3, 1), (K_T3, 0)] and
          sd[2] == ns[2], keys(d["msgs"]))


def t_hostclose(e):
    """The Sidecar's NO on its first status page: the host gets 31 NO down and answers 3A 0 0 (close) while NO is still
    held: the page leaves (30 0 0 host), NO's release is eaten (never reaches stock), the LEDs are stock's, and the stock
    screen and LEDs equal a Rytm that never opened the page (only TRK pressed, which alone changes nothing)."""
    ev = GRID + OPEN + [(100, "sx", leds(COLS)), (140, "press", "NO:40"), (150, "sx", sx(0x3A, 0, 0))]
    a = e.run("hostclose", 300, ev)
    c = e.run("hostclose-ctl", 300, GRID + [(70, "press", "TRK:60")])
    s, sel, _ = e.panel(a)
    cs, csel, _ = e.panel(c)
    md = modes(a["msgs"])
    check("hostclose: 3A 0 0 leaves (30 page 0, off, host)", md[-1:] == [(0, 0, 1)], md)
    check("hostclose: the host saw NO down (and its release only while open: none after)",
          keys(a["msgs"]) == [(0x45, 1)], keys(a["msgs"]))
    check("hostclose: the stock screen equals a Rytm that never opened the page", a["oled"] == c["oled"])
    check("hostclose: LEDs and selectors equal it too (restored once)", s == cs and sel == csel and
          e.st(a, "led_restores") == 1, [i for i in s if s[i] != cs.get(i)])


def t_kit(e):
    """3B, the active kit (8 bytes, F0 7D 52 54 3B 01 <kit> F7): after the hello's 33 snapshot (kit 0 on the base),
    when the kit changes (pattern A02: kit 1), after the open's 30 and snapshot (kit 1 again)."""
    a = e.run("kit", 600, [(150, "press", "BANK_A:150"), (200, "press", "T2"), (450, "press", "TRK:60"),
                           (460, "press", "YES")])
    seq = []
    for m in a["msgs"]:
        c = m[4]
        if c == 0x3B:
            seq.append(("3B", m[6], len(m)))
        elif c == 0x35:
            seq.append(("35",))
        elif c == 0x30:
            seq.append(("30", m[7]))
        elif c == 0x33 and len(m) == 33:
            seq.append(("33",))
    print(f"  {seq}")
    kits = [x for x in seq if x[0] == "3B"]
    check("kit: every 3B is 8 bytes", all(x[2] == 8 for x in kits), kits)
    check("kit: hello, its snapshot, then 3B kit 0", seq[:3] == [("35",), ("33",), ("3B", 0, 8)], seq[:3])
    check("kit: the pattern change to kit 1 sends 3B 1 before the open", ("3B", 1, 8) in seq[3:seq.index(("30", 1))]
          if ("30", 1) in seq else False)
    i = seq.index(("30", 1)) if ("30", 1) in seq else len(seq)
    check("kit: the open: 30, its snapshot, then 3B 1", seq[i:i + 3] == [("30", 1), ("33",), ("3B", 1, 8)], seq[i:])


TESTS = dict(kit=t_kit, hostclose=t_hostclose, stockcombo=t_stockcombo, combo=t_combo, leds=t_leds, ledexit=t_ledexit, bad=t_bad, trigs=t_trigs)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    e = Emu(sys.argv[1])
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    for n in names:
        print(f"== {n}", flush=True)
        TESTS[n](e)
    shutil.rmtree(e.tmp, ignore_errors=True)
    print("ALL PASS" if not FAILS else f"{len(FAILS)} FAILED: {FAILS}")
    sys.exit(1 if FAILS else 0)


if __name__ == "__main__":
    main()
