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
EMU = os.environ.get("RYTM_EMU", "../rytm-emu")
STOCK = os.path.join(ROOT, "stock", "Analog-Rytm_MKII_OS1.73.syx")
K_TRK, K_LFO, K_T3 = 0x86, 0x35, 0x02
BLUE, ORANGE = 47, 52        # palette: (0, 0, 31) and (11, 6, 0) [measured, the OS's palette in rytm-emu]
# struct rui (rui.c) after splash_why (988): pend_hello 992, pend_page 993, then these (m68k: ints on 2-byte bounds)
OFF = dict(hdrs=1086, active=4, last_reason=296, lfo_opens=994, lfo_hints=998, led_seen=1002, led_want=1006, led_paints=1010,
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
        self.out = os.path.join(os.environ.get("RYTM_OUT_ROOT") or os.path.join(ROOT, "build", "emu"), tag)
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
            elif kind == "turn":   # 1041: "ENC:DELTA" three times, 4 M (20 ms) apart
                cmd += ["--turn", f"{val}@{start + at}Mx3/4M"]
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


def glass(oled):
    """The OLED text (2 rows a character: the half blocks) -> 64 rows of 128 '#' / '.'."""
    rows = []
    for line in (oled or "").split("\n")[:32]:
        line = line[:128].ljust(128)
        rows.append("".join("#" if c in "\u2588\u2580" else "." for c in line))
        rows.append("".join("#" if c in "\u2588\u2584" else "." for c in line))
    return rows


def field(rows):   # stock's header field: rows 0..8, columns 0..69
    return [r[:70] for r in rows[:9]]


def rest(rows):    # everything else
    return [r[70:] for r in rows[:9]] + rows[9:]


def t_levelhdr(e):
    """1041: LEVEL turned with the page open (TRK + YES; nothing committed: a blank page; the host's mask passes LEVEL
    to stock, as every page with knobs does): 0.3 s after, the header's
    left field (rows 0..8, columns 0..69) is stock's own "TRK LEVEL" readout - equal to the same field in the run
    without the page - and the rest of the glass is the page's (blank); 3 s after it is the page's again (blank). The
    level itself changed as without the page (kit word)."""
    # the host's mask as for a page with knobs (core/ui/remote.cpp send_mask): A..H caught, LEVEL (8) passed to stock
    lv = [(70, "press", "TRK:60"), (80, "press", "YES"), (100, "sx", sx(0x37, 0x7F, 0x01, 0)), (120, "turn", "8:+3")]
    a = e.run("lh-page", 180, lv)
    b = e.run("lh-stock", 180, [(120, "turn", "8:+3")])
    n = e.run("lh-none", 180, [])
    c = e.run("lh-late", 720, lv)
    ga, gb, gn, gc = glass(a["oled"]), glass(b["oled"]), glass(n["oled"]), glass(c["oled"])
    check("levelhdr: stock's readout changed its header field (control: the turn's readout vs no turn)",
          field(gb) != field(gn))
    check("levelhdr: with the page open the field is stock's readout, as without the page", field(ga) == field(gb),
          "\n" + "\n".join(field(ga)))
    check("levelhdr: the rest of the glass is the page's (blank)", all(set(r) <= {"."} for r in rest(ga)))
    check("levelhdr: 3 s later the field is the page's again (blank)", all(set(r) <= {"."} for r in gc[:64]))
    check("levelhdr: the LEVEL turns passed to stock were counted (hdrs)", e.st(a, "hdrs") >= 1, e.st(a, "hdrs"))


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
    kw = stock_kw(e)
    n = e.run("st-none", 300, **kw)
    t = e.run("st-trk", 300, [(20, "press", "TRK:60")], **kw)
    tl = e.run("st-trklfo", 300, [(20, "press", "TRK:60"), (40, "press", "LFO")], **kw)
    lf = e.run("st-lfo", 300, [(40, "press", "LFO")], **kw)
    check("stockcombo: TRK alone leaves the main screen as it was", t["oled"] == n["oled"])
    check("stockcombo: TRK + LFO = LFO alone (the stock LFO page)", tl["oled"] == lf["oled"])
    check("stockcombo: and that is a different screen (the LFO page opened)", lf["oled"] != n["oled"])


def stock_kw(e):
    """The stock 1.73 image's base (rled_stock: a fresh card, the startup dialogs answered) as run() keywords."""
    fw, card, snap = "fw/AR173_rled_stock.syx", os.path.join(EMU, "sections/rled_stock.img"), "sections/rled_stock.snap"
    if not os.path.exists(os.path.join(EMU, snap)):
        shutil.copy(STOCK, os.path.join(EMU, fw))
        subprocess.run(["cp", "-c", os.path.join(EMU, "sections/led.img"), card], check=True)   # an APFS clone
        subprocess.run(["./target/release/dtboot", fw, "--instr", "4800M", "--every", "4800M", "--card", card,
                        "--press", "YES@2600M", "--press", "NO@3000M", "--press", "NO@3400M", "--press", "NO@3800M",
                        "--save", snap], cwd=EMU, capture_output=True)
    return dict(fw=fw, snap=snap, clock=4800, card=card, alive=())


# What a stock run leaves [rytm-emu, the stock image]: the screen, every LED's slots and selectors, the working
# pattern's 12 tracks (A01 live at 0x407dd8e3, 917 B a track), the sequencer's state (0x405c8c90..), the selected track
# (0x41318982), the next pattern / kit words (0x800067b8..)
STATE = ((0x407DD8E3, 917 * 12), (0x405C8C90, 0xB0), (0x41318982, 1), (0x800067B0, 16))


def stock_state(e, r):
    slots, sel = e.panel(r)[:2]
    d = dict(oled=r["oled"], **{f"led{i}": v for i, v in slots.items()})
    d.update({f"sel{i}": v for i, v in enumerate(sel.split(", "))})   # 1038: each selector byte its own item
    d.update({f"mem{a:x}+{i:x}": e.peek(r, a + i, min(256, n - i)) for a, n in STATE for i in range(0, n, 256)})
    return d


def combo_only_parts(ab, a, x, n):
    """ab (key x then key a) against a (key a alone), every item: equal, or the item key x alone changes (x != n), and
    there ab equals x alone. -> the items that differ otherwise (what the combo adds of its own)."""
    return [k for k in ab if ab[k] != a[k] and not (x[k] != n[k] and ab[k] == x[k])]


def t_stocktrktrig(e):
    """1037: stock 1.73 binds nothing to TRK + TRIG: on the main screen, in GRID REC (T1 / T5 placed first) and on the
    TRIG page, TRK + TRIG leaves what TRIG alone leaves, except what TRK alone changes (and there it leaves what TRK
    alone leaves); TRIG alone opens its page (a different screen). Compared: the screen, every LED's slots and the
    selectors, the working pattern's 12 tracks, the sequencer state, the selected track, the kit words."""
    kw = stock_kw(e)
    for ctx, pre in (("main", []), ("grid", [(10, "press", "RECORD"), (15, "press", "T1"), (18, "press", "T5")]),
                     ("trigpg", [(10, "press", "TRIG")])):
        n = stock_state(e, e.run(f"stt-{ctx}-none", 300, pre, **kw))
        t = stock_state(e, e.run(f"stt-{ctx}-trk", 300, pre + [(30, "press", "TRK:60")], **kw))
        tt = stock_state(e, e.run(f"stt-{ctx}-trktrig", 300, pre + [(30, "press", "TRK:60"), (50, "press", "TRIG")], **kw))
        tg = stock_state(e, e.run(f"stt-{ctx}-trig", 300, pre + [(50, "press", "TRIG")], **kw))
        print(f"  {ctx}: TRK alone changes {[k for k in t if t[k] != n[k]]}; TRIG alone {[k for k in tg if tg[k] != n[k]]}")
        check(f"stocktrktrig {ctx}: TRK + TRIG = TRIG alone + what TRK alone leaves (nothing of its own)",
              not combo_only_parts(tt, tg, t, n), combo_only_parts(tt, tg, t, n))
        check(f"stocktrktrig {ctx}: TRK alone leaves the screen and the pattern as no key does",
              t["oled"] == n["oled"] and all(t[k] == n[k] for k in t if k.startswith("mem")))
        if ctx != "trigpg":
            check(f"stocktrktrig {ctx}: (control) TRIG alone is a different screen (its page opened)",
                  tg["oled"] != n["oled"])


def t_stocktrkfx(e):
    """1041: stock 1.73 binds nothing to TRK + FX. On the main screen and in GRID REC (T1 / T5 placed first; seq mode is
    a Sidecar seq track in GRID REC) TRK + FX leaves what FX alone leaves, except what TRK alone changes (and there it
    leaves what TRK alone leaves); FX alone opens its page (a different screen). On the FX page (also in GRID REC) TRK
    alone and FX alone each leave it (the FX track deselected); there TRK held + FX leaves exactly what TRK tapped and
    released, then FX, leaves: each key's own action in turn, nothing of the combo's own. The same state list as
    stocktrktrig."""
    kw = stock_kw(e)
    for ctx, pre in (("main", []), ("grid", [(10, "press", "RECORD"), (15, "press", "T1"), (18, "press", "T5")]),
                     ("fxpg", [(10, "press", "FX")]),
                     ("gridfx", [(10, "press", "RECORD"), (15, "press", "T1"), (18, "press", "FX")])):
        n = stock_state(e, e.run(f"stf-{ctx}-none", 300, pre, **kw))
        t = stock_state(e, e.run(f"stf-{ctx}-trk", 300, pre + [(30, "press", "TRK:60")], **kw))
        tf = stock_state(e, e.run(f"stf-{ctx}-trkfx", 300, pre + [(30, "press", "TRK:60"), (50, "press", "FX")], **kw))
        fx = stock_state(e, e.run(f"stf-{ctx}-fx", 300, pre + [(50, "press", "FX")], **kw))
        print(f"  {ctx}: TRK alone changes {[k for k in t if t[k] != n[k]]}; FX alone {[k for k in fx if fx[k] != n[k]]}")
        if ctx in ("main", "grid"):
            check(f"stocktrkfx {ctx}: TRK + FX = FX alone + what TRK alone leaves (nothing of its own)",
                  not combo_only_parts(tf, fx, t, n), combo_only_parts(tf, fx, t, n))
            check(f"stocktrkfx {ctx}: TRK alone leaves the screen and the pattern as no key does",
                  t["oled"] == n["oled"] and all(t[k] == n[k] for k in t if k.startswith("mem")))
            check(f"stocktrkfx {ctx}: (control) FX alone is a different screen (its page opened)", fx["oled"] != n["oled"])
        else:
            seq = stock_state(e, e.run(f"stf-{ctx}-trkthenfx", 300, pre + [(30, "press", "TRK:10"), (50, "press", "FX")],
                                       **kw))
            diff = [k for k in tf if tf[k] != seq[k]]
            check(f"stocktrkfx {ctx}: TRK held + FX = TRK tapped, then FX (each key's own action)", not diff, diff)
            check(f"stocktrkfx {ctx}: (control) TRK alone and FX alone each leave the FX page",
                  t["oled"] != n["oled"] and fx["oled"] != n["oled"])
            check(f"stocktrkfx {ctx}: the pattern as with no key", all(tf[k] == n[k] for k in tf if k.startswith("mem4")
                                                                    and not k.startswith("mem41318982")))


def t_stockyes(e):
    """1037: stock 1.73's trig held + YES (T1 held, YES pressed and released while it is held): in GRID REC on the main
    screen and on the TRIG page, and outside GRID REC: T1 + YES leaves what T1 alone leaves, except what YES alone
    changes (and there it leaves what YES alone leaves). The same state list as stocktrktrig."""
    kw = stock_kw(e)
    for ctx, pre in (("main", [(10, "press", "RECORD")]), ("trigpg", [(10, "press", "RECORD"), (15, "press", "TRIG")]),
                     ("live", [])):
        a = stock_state(e, e.run(f"sty-{ctx}-t1", 300, pre + [(30, "press", "T1:60")], **kw))
        b = stock_state(e, e.run(f"sty-{ctx}-t1yes", 300, pre + [(30, "press", "T1:60"), (50, "press", "YES")], **kw))
        y = stock_state(e, e.run(f"sty-{ctx}-yes", 300, pre + [(50, "press", "YES")], **kw))
        n = stock_state(e, e.run(f"sty-{ctx}-none", 300, pre, **kw))
        print(f"  {ctx}: YES alone changes {[k for k in y if y[k] != n[k]]}; T1 alone {[k for k in a if a[k] != n[k]]}")
        check(f"stockyes {ctx}: T1 held + YES = T1 held alone + what YES alone leaves (nothing of its own)",
              not combo_only_parts(b, a, y, n), combo_only_parts(b, a, y, n))
        check(f"stockyes {ctx}: T1 held + YES leaves the screen as T1 held alone", a["oled"] == b["oled"])


def t_stockup(e):
    """1038: stock 1.73's UP held + T6..T10 (as 1036b's probe for T3 / T5): on the main screen, in GRID REC, on the FLTR
    page, in CHRO and in MUTE mode, UP held + Tn leaves what Tn alone leaves, except what UP alone changes (and there
    it leaves what UP alone leaves). The same state list as stocktrktrig. 1046: T11..T13 too, and a menu open (GLOBAL:
    its list, where UP moves the cursor). STOCKUP_KEYS=11-13 (first-last) limits the keys."""
    kw = stock_kw(e)
    lo, hi = (int(x) for x in os.environ.get("STOCKUP_KEYS", "6-13").split("-"))
    for ctx, pre in (("main", []), ("grid", [(10, "press", "RECORD")]), ("fltr", [(10, "press", "FLTR")]),
                     ("chro", [(10, "press", "CHRO")]), ("mute", [(10, "press", "MUTE")]),
                     ("menu", [(10, "press", "GLOBAL")])):
        n = stock_state(e, e.run(f"stu-{ctx}-none", 300, pre, **kw))
        u = stock_state(e, e.run(f"stu-{ctx}-up", 300, pre + [(30, "press", "UP:60")], **kw))
        if ctx == "menu":
            check("stockup menu: (control) GLOBAL opened a menu (a different screen) and UP alone moves in it",
                  n["oled"] != stock_state(e, e.run("stu-main-none", 300, [], **kw))["oled"] and u["oled"] != n["oled"])
        for k in range(lo, hi + 1):
            a = stock_state(e, e.run(f"stu-{ctx}-t{k}", 300, pre + [(50, "press", f"T{k}")], **kw))
            b = stock_state(e, e.run(f"stu-{ctx}-upt{k}", 300, pre + [(30, "press", "UP:60"), (50, "press", f"T{k}")],
                                     **kw))
            bad = combo_only_parts(b, a, u, n)
            if ctx == "menu":   # in a list UP moves the cursor and Tn acts where it now is: compare with UP tapped first
                seq = stock_state(e, e.run(f"stu-{ctx}-uptap-t{k}", 300, pre + [(30, "press", "UP:10"), (50, "press", f"T{k}")],
                                           **kw))
                bad = [x for x in b if b[x] != seq[x]]
                check(f"stockup {ctx}: UP held + T{k} = UP tapped, then T{k} (each key's own action)", not bad, bad)
                continue
            check(f"stockup {ctx}: UP held + T{k} = T{k} alone + what UP alone leaves (nothing of its own)", not bad, bad)


def t_stocktrigup(e):
    """1046: what stock 1.73 does with a held trig + UP (and + DOWN) in GRID REC, on every page (none, TRIG, SRC, SMPL,
    FLTR, AMP, LFO): T1 held, the arrow tapped while it is held, against T1 held alone. Prints every item that changes
    (the pattern bytes as their offsets in BD's track); no pass / fail of its own beyond the runs being clean."""
    kw = stock_kw(e)
    found = {}
    for pg in ("main", "TRIG", "SRC", "SMPL", "FLTR", "AMP", "LFO"):
        pre = [(10, "press", "RECORD")] + ([(15, "press", pg)] if pg != "main" else []) + [(30, "press", "T1:120")]
        for end, when in ((300, "after"), (100, "held")):   # after T1's release, and while it is still held
          n = stock_state(e, e.run(f"stg-{pg}-t1-{when}", end, pre, **kw))
          for arrow in ("UP", "DOWN", "RIGHT"):   # RIGHT: the control (stock's micro timing for a held trig)
            if arrow == "RIGHT" and pg != "main":
                continue
            r = e.run(f"stg-{pg}-t1{arrow}-{when}", end, pre + [(60, "press", f"{arrow}:10")], **kw)
            a = stock_state(e, r)
            diff = [k for k in a if a[k] != n[k]]
            mem = []
            for k in diff:
                if k.startswith("mem407dd8e3+"):
                    off = int(k.split("+")[1], 16)
                    mem += [f"trk{(off + i) // 917}+{(off + i) % 917:#x}:{n[k][i]:02x}->{a[k][i]:02x}"
                            for i in range(len(a[k])) if a[k][i] != n[k][i]]
            found[(pg, arrow, when)] = diff
            print(f"  {pg} T1 + {arrow} ({when}): changes {diff[:10]} {mem[:12]}")
    check("stocktrigup: (control) T1 held + RIGHT changes something (the method sees a held-trig arrow)",
          bool(found[("main", "RIGHT", "after")] or found[("main", "RIGHT", "held")]))
    check("stocktrigup: the runs are clean (see the table above)", True)


def t_upstock(e):
    """1046: where rui1046 / rui1047 bind nothing to UP + a key (AMP is bound since rui1047: stockupkeys AMP shows stock leaves it free), the key does on rui1046 what it does on stock 1.73: for UP held +
    SMPL / FLTR / AMP / NO / PAGE / a pad / T14 on the main screen and in GRID REC, and with T1 held in GRID REC (a stock
    track) UP + SRC / RECORD / PLAY / STOP, the items the gesture changes (against the same run without it) are the same
    on both, with the same new values for the pattern, the sequencer and the selected track (the two bases differ, so
    deltas are compared). UPSTOCK=A,B limits the keys."""
    kw = stock_kw(e)
    plain = os.environ.get("UPSTOCK", "SMPL,FLTR,NO,PAGE,SD,T14").split(",")
    held = os.environ.get("UPSTOCK_HELD", "SRC,RECORD,PLAY,STOP").split(",")
    for ctx, pre, keys in (("main", [], plain), ("grid", [(10, "press", "RECORD")], plain),
                           ("gridtrig", [(10, "press", "RECORD"), (20, "press", "T1:100")], held)):
        nm = stock_state(e, e.run(f"ups-{ctx}-none", 300, pre))
        ns = stock_state(e, e.run(f"ups-{ctx}-none-stock", 300, pre, **kw))
        for k in keys:
            bm = stock_state(e, e.run(f"ups-{ctx}-up{k}", 300, pre + [(30, "press", "UP:60"), (50, "press", k)]))
            bs = stock_state(e, e.run(f"ups-{ctx}-up{k}-stock", 300, pre + [(30, "press", "UP:60"), (50, "press", k)], **kw))
            dm = {x for x in bm if bm[x] != nm[x]}
            ds = {x for x in bs if bs[x] != ns[x]}
            vals = [x for x in dm & ds if x.startswith("mem") and bm[x] != bs[x]]
            check(f"upstock {ctx}: UP + {k} changes on rui1046 what it changes on stock", dm == ds and not vals,
                  (sorted(dm ^ ds)[:6], vals[:4]))


def t_upamp(e):
    """1047: UP + AMP is the Sidecar's now, so everything around it stays stock's: on the main screen and in GRID REC,
    AMP alone, TRK held + AMP, UP tapped (10 ms, released) then AMP, and a held trig (T1) + AMP change on rui1047
    what they change on stock 1.73 (deltas against the same run without the gesture, as upstock). That UP held + AMP is
    free on stock is stockupkeys' (UPKEYS=AMP)."""
    kw = stock_kw(e)
    for ctx, pre in (("main", []), ("grid", [(10, "press", "RECORD")])):
        nm = stock_state(e, e.run(f"upa-{ctx}-none", 300, pre))
        ns = stock_state(e, e.run(f"upa-{ctx}-none-stock", 300, pre, **kw))
        for name, ev in (("AMP", [(50, "press", "AMP")]), ("TRK+AMP", [(30, "press", "TRK:60"), (50, "press", "AMP")]),
                         ("UPtap+AMP", [(30, "press", "UP:10"), (80, "press", "AMP")]),
                         ("T1+AMP", [(30, "press", "T1:100"), (50, "press", "AMP")])):
            bm = stock_state(e, e.run(f"upa-{ctx}-{name}", 300, pre + ev))
            bs = stock_state(e, e.run(f"upa-{ctx}-{name}-stock", 300, pre + ev, **kw))
            dm = {x for x in bm if bm[x] != nm[x]}
            ds = {x for x in bs if bs[x] != ns[x]}
            vals = [x for x in dm & ds if x.startswith("mem") and bm[x] != bs[x]]
            check(f"upamp {ctx}: {name} changes on rui1047 what it changes on stock", dm == ds and not vals,
                  (sorted(dm ^ ds)[:6], vals[:4]))


UPKEYS = ["TRIG", "SRC", "SMPL", "FLTR", "AMP", "LFO", "FX", "YES", "NO", "RECORD", "PLAY", "STOP", "PAGE",
          "BD", "SD", "RS", "CP", "BT", "LT", "MT", "HT", "CH", "OH", "CY", "CB", "T14", "T15", "T16"]


def t_stockupkeys(e):
    """1046 (UP the one Sidecar modifier): stock 1.73's UP held + each key of UPKEYS (the page keys, YES NO, the
    transport, PAGE, the pads, T14..T16) on the main screen, in GRID REC, in GRID REC with T1 held (as seq mode's held
    trig) and with a menu open (GLOBAL). Free: UP held + X leaves what X alone leaves, except what UP alone changes (and
    there what UP alone leaves) - or, where that differs, exactly what UP tapped and released, then X, leaves (each key's
    own action in turn, as in a list where UP moves the cursor). Anything else is a combo of stock's own: a clash.
    The same state list as stocktrktrig. UPKEYS=A,B limits the keys; prints a FREE / SEQ / CLASH table at the end."""
    kw = stock_kw(e)
    keys = os.environ.get("UPKEYS", ",".join(UPKEYS)).split(",")
    table = {}
    for ctx, pre in (("main", []), ("grid", [(10, "press", "RECORD")]),
                     ("gridtrig", [(10, "press", "RECORD"), (20, "press", "T1:100")]),
                     ("menu", [(10, "press", "GLOBAL")])):
        n = stock_state(e, e.run(f"suk-{ctx}-none", 300, pre, **kw))
        u = stock_state(e, e.run(f"suk-{ctx}-up", 300, pre + [(30, "press", "UP:60")], **kw))
        for k in keys:
            a = stock_state(e, e.run(f"suk-{ctx}-{k}", 300, pre + [(50, "press", k)], **kw))
            b = stock_state(e, e.run(f"suk-{ctx}-up{k}", 300, pre + [(30, "press", "UP:60"), (50, "press", k)], **kw))
            bad = combo_only_parts(b, a, u, n)
            how = "FREE"
            if bad:
                seq = stock_state(e, e.run(f"suk-{ctx}-uptap{k}", 300, pre + [(30, "press", "UP:10"), (50, "press", k)],
                                           **kw))
                bad = [x for x in b if b[x] != seq[x]]
                how = "CLASH" if bad else "SEQ"
            table[(ctx, k)] = how
            check(f"stockupkeys {ctx}: UP held + {k}: {how}", not bad, bad[:6])
    print("  key      " + " ".join(f"{c:9s}" for c in ("main", "grid", "gridtrig", "menu")))
    for k in keys:
        print(f"  {k:8s} " + " ".join(f"{table.get((c, k), '-'):9s}" for c in ("main", "grid", "gridtrig", "menu")))


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
    """The Sidecar's page closed by the host (3A 0 0) while NO is still held: the page leaves (30 0 0 host), NO's
    release is eaten (never reaches stock), the LEDs are stock's, and the stock screen and LEDs equal a Rytm that never
    opened the page (only TRK pressed, which alone changes nothing). 1052d: NO on a page is kept back to its release (NO
    + a reload key is stock's), so a page closed before NO's release sends the host no NO at all."""
    ev = GRID + OPEN + [(100, "sx", leds(COLS)), (140, "press", "NO:40"), (150, "sx", sx(0x3A, 0, 0))]
    a = e.run("hostclose", 300, ev)
    c = e.run("hostclose-ctl", 300, GRID + [(70, "press", "TRK:60")])
    s, sel, _ = e.panel(a)
    cs, csel, _ = e.panel(c)
    md = modes(a["msgs"])
    check("hostclose: 3A 0 0 leaves (30 page 0, off, host)", md[-1:] == [(0, 0, 1)], md)
    check("hostclose: the host saw no NO (kept back to its release, the page closed before it: 1052d)",
          keys(a["msgs"]) == [], keys(a["msgs"]))
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


# 1044: k44 (rui.c): up_t0 0, map_on 4, map_off 8, trk_paints 12, trk_restores 16, up_on 20, up_trig 21, up_map 22,
# map_req 23, trk_on 24, trk_col 25
K44 = dict(map_on=4, map_off=8, trk_paints=12, trk_restores=16, pmap_on=28, pmap_off=32)   # 1050: map_page 26, pmap_*
TRK_LED, TRK_ON = 55, 0x6F


def k44(e, res, field):
    return int.from_bytes(e.peek(res, e.sym("k44") + K44[field], 4), "big")


def t_trkled(e):
    """1044 (rytm-teensy UX review R5): while the page has the keys TRK's LED (55) blinks, white / off at 1 Hz - every
    slot the one colour, so stock's selector shows it; TRK + YES out again gives stock's own slots back, equal to the run
    that never opened the page (TRK pressed as often)."""
    op = [(20, "press", "TRK:60"), (30, "press", "YES")]
    a = e.run("trk-open", 300, op)
    b = e.run("trk-close", 400, op + [(300, "press", "TRK:60"), (310, "press", "YES")])
    n = e.run("trk-none", 400, [(20, "press", "TRK:60"), (300, "press", "TRK:60")])
    sa, sb, sn = e.panel(a)[0], e.panel(b)[0], e.panel(n)[0]
    la = sa.get(TRK_LED)
    print(f"  TRK LED slots: open {la}, closed {sb.get(TRK_LED)}, never {sn.get(TRK_LED)}; paints {k44(e, a, 'trk_paints')}")
    check("trkled: with the page open every slot of TRK's LED is one colour, white or off",
          la is not None and len(set(la)) == 1 and la[0] in (0, TRK_ON), la)
    check("trkled: it blinked (painted at least 3 times in 1.3 s: open, off, on)", k44(e, a, "trk_paints") >= 3,
          k44(e, a, "trk_paints"))
    check("trkled: after TRK + YES out, the slots are stock's (as the run without the page)",
          sb.get(TRK_LED) == sn.get(TRK_LED), (sb.get(TRK_LED), sn.get(TRK_LED)))
    check("trkled: restored once at the close", k44(e, b, "trk_restores") >= 1, k44(e, b, "trk_restores"))
    others = [i for i in sn if i not in (TRK_LED,) and sb.get(i) != sn.get(i) and i >= 16]
    check("trkled: no other key LED differs from the run without the page (T1..T16 aside)", not others, others)


def t_upmap(e):
    """1044 (rytm-teensy UX review N3): UP held alone on the stock screen (the page closed) for 0.4 s: 49 1 4 1 (the
    host's combo map), its release 49 1 4 0; UP tapped (0.2 s): neither; UP + T3: the page request 49 1 1 3 as before
    and no map; UP stays stock's (the screen after equals the run with UP alone held as long without the mod's map:
    the same build, nothing sent back by the host)."""
    def map_msgs(r):
        return [m[7] for m in r["msgs"] if m[4:7] == b"\x49\x01\x04" and len(m) == 9]
    h = e.run("up-hold", 300, [(30, "press", "UP:120")])
    t = e.run("up-tap", 300, [(30, "press", "UP:20")])
    c = e.run("up-t3", 300, [(30, "press", "UP:120"), (40, "press", "T3")])
    print(f"  maps: hold {map_msgs(h)}, tap {map_msgs(t)}, UP + T3 {map_msgs(c)}")
    check("upmap: UP held 0.6 s: 49 1 4 1 then 49 1 4 0", map_msgs(h) == [1, 0], map_msgs(h))
    check("upmap: counters map_on 1, map_off 1", (k44(e, h, "map_on"), k44(e, h, "map_off")) == (1, 1),
          (k44(e, h, "map_on"), k44(e, h, "map_off")))
    check("upmap: UP tapped: no map", map_msgs(t) == [], map_msgs(t))
    pages = [m[7] for m in c["msgs"] if m[4:7] == b"\x49\x01\x01" and len(m) == 9]
    check("upmap: UP + T3: the page request (3), no map", pages == [3] and map_msgs(c) == [], (pages, map_msgs(c)))
    check("upmap: the screen after UP held equals UP tapped (UP stays stock's, nothing drawn by the map itself)",
          h["oled"] == t["oled"])


def mask_of(encs=(), keys=()):
    """37: encoders (0..8) and key codes caught: encoder e bit e % 7 of byte e / 7; key k bit k % 7 of byte 3 + k / 7."""
    b = [0] * (3 + max([k // 7 + 1 for k in keys] or [0]))
    for e in encs:
        b[e // 7] |= 1 << (e % 7)
    for k in keys:
        b[3 + k // 7] |= 1 << (k % 7)
    return sx(0x37, *b)


SEQ_KEYS = (0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x84, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x10, 0xB0, 0xB4, 0xB5, 0xB1,
            0x81, 0x82, 0x86)   # rytm-teensy core/ui/remote.cpp kCatchKeys


def t_upmappage(e):
    """1050: UP held alone with the page open (TRK + YES) for 0.6 s: 49 1 5 1 (the map over the page), its release 49 1 5 0;
    no 49 1 4 (an older host would close its page at 49 1 4 0); UP tapped: none; UP + T3: the page request, no map; UP
    held then YES (the map up): the page closes (30 off), as UP + YES without the map - not 1044's SIDECAR page."""
    def maps(r, sub):
        return [m[7] for m in r["msgs"] if m[4:7] == bytes([0x49, 1, sub]) and len(m) == 9]
    op = [(20, "press", "TRK:60"), (30, "press", "YES")]
    h = e.run("upp-hold", 400, op + [(100, "press", "UP:120")])
    t = e.run("upp-tap", 400, op + [(100, "press", "UP:20")])
    c = e.run("upp-t3", 400, op + [(100, "press", "UP:120"), (110, "press", "T3")])
    y = e.run("upp-yes", 400, op + [(100, "press", "UP:200"), (220, "press", "YES")])
    print(f"  over the page: hold {maps(h, 5)} / {maps(h, 4)}, tap {maps(t, 5)}, UP + T3 {maps(c, 5)}, UP held + YES "
          f"{maps(y, 5)} 30s {modes(y['msgs'])}")
    check("upmappage: UP held 0.6 s over the open page: 49 1 5 1 then 49 1 5 0, no 49 1 4", maps(h, 5) == [1, 0] and
          maps(h, 4) == [], (maps(h, 5), maps(h, 4)))
    check("upmappage: counters pmap_on 1, pmap_off 1, map_on 0", (k44(e, h, "pmap_on"), k44(e, h, "pmap_off"),
          k44(e, h, "map_on")) == (1, 1, 0), (k44(e, h, "pmap_on"), k44(e, h, "pmap_off"), k44(e, h, "map_on")))
    check("upmappage: UP tapped: no map", maps(t, 5) == [] and maps(t, 4) == [], maps(t, 5))
    pages = [m[7] for m in c["msgs"] if m[4:7] == b"\x49\x01\x01" and len(m) == 9]
    check("upmappage: UP + T3: the page request (3), no map", pages == [3] and maps(c, 5) == [], (pages, maps(c, 5)))
    check("upmappage: UP held (the map up) + YES: the page closes (30 0 0 ..), no SIDECAR request (30 0 1 0)",
          maps(y, 5)[:1] == [1] and modes(y["msgs"])[-1][1] == 0 and (0, 1, 0) not in modes(y["msgs"])[1:], modes(y["msgs"]))


def t_stocklockpush(e):
    """1050: the lock pages' new gestures - a long encoder push (that lock's COND) and FUNC + push (its SLIDE).
    (a) stock 1.73 on its own lock page (GRID REC, T1 held, SRC): PUSH_A held 0.5 s, and FUNC held + PUSH_A tapped, against
    T1 + SRC alone: printed (what a stock user's hands know there). (b) rui1050 with the page open and the SEQ page's
    mask (the encoders, their pushes and FUNC): the same gestures reach the host (31 PUSH_A down / up, FUNC down / up)
    and stock's state (the pattern, the sequencer, the selected track, the LEDs, the kit words) equals the run without
    them (FUNC is both sides': stock sees a FUNC press alone)."""
    kw = stock_kw(e)
    pre = [(10, "press", "RECORD"), (30, "press", "T1:260"), (45, "press", "SRC")]
    n = stock_state(e, e.run("slp-none", 340, pre, **kw))
    for name, ev in (("long", [(80, "press", "PUSH_A:100")]), ("func", [(80, "press", "FUNC:60"), (100, "press", "PUSH_A:10")])):
        a = stock_state(e, e.run(f"slp-{name}", 340, pre + ev, **kw))
        diff = [k for k in a if a[k] != n[k]]
        print(f"  stock 1.73, T1 held + SRC + {name} push: changes {diff[:12]}")
    op = [(20, "press", "TRK:60"), (30, "press", "YES"), (60, "sx", mask_of(range(8), SEQ_KEYS + tuple(range(0x70, 0x78)) + (0x80,)))]
    base = e.run("slp-r-none", 400, op)
    nb = stock_state(e, base)
    nb.pop("oled", None)
    for name, ev in (("long", [(150, "press", "PUSH_A:100")]), ("func", [(150, "press", "FUNC:60"), (170, "press", "PUSH_A:10")])):
        r = e.run(f"slp-r-{name}", 400, op + ev)
        a = stock_state(e, r)
        a.pop("oled", None)
        ks = keys(r["msgs"])
        diff = [k for k in a if a[k] != nb[k]]
        want = [(0x70, 1), (0x70, 0)] if name == "long" else [(0x80, 1), (0x70, 1), (0x70, 0), (0x80, 0)]
        check(f"stocklockpush: rui1050, the page open, {name} push: the host gets {want}", ks == want, ks)
        check(f"stocklockpush: rui1050, {name} push: stock's state as without it", not diff, diff[:8])


def t_menustock(e):
    """1048: POLY CONFIG is the track menu's last item and the rest of the menu is as before. FUNC + CHRO, the cursor
    moved by k DOWNs, the glass (the menu) compared without its scroll bar (columns 119..127: one more item moves it):
    items 0..8 (TRIGS SETUP, PAD SCALE, RELOAD TRACK, SAVE TRACK, U1..U5) equal the build before (MENU_PREV, default
    rui1048base: rui1047's sources); the four stock items' rows (0..51) equal stock 1.73's; item 9 is new (differs from
    item 8's screen). YES on each of items 0..4 leaves the glass as on the build before (U1: its NO SIDECAR after the
    2 s wait), and YES on items 0..1 (TRIGS SETUP, PAD SCALE: their views) as on stock."""
    kw = stock_kw(e)
    prev = Emu(os.environ.get("MENU_PREV", "rui1048base"))
    pkw = dict(fw=prev.fw, snap=prev.snap, clock=prev.clock, card=prev.card)
    opn = [(20, "press", "FUNC:30"), (25, "press", "CHRO")]
    cut = lambda r, rows=64: [x[:119] for x in glass(r["oled"])[:rows]]   # noqa: E731

    def at(k, yes=False):
        ev = opn + [(60 + 40 * i, "press", "DOWN") for i in range(k)]
        return ev + ([(80 + 40 * k, "press", "YES")] if yes else [])
    shots = {}
    for k in range(10):
        shots[k] = e.run(f"menu-{k}", 520, at(k))
        if k < 9:
            p = prev.run(f"menu-{k}-prev", 520, at(k), **pkw)
            check(f"menustock: item {k}: the menu as on the build before (no scroll bar)", cut(shots[k]) == cut(p))
        if k < 4:
            st = e.run(f"menu-{k}-stock", 520, at(k), **kw)
            check(f"menustock: item {k}: the stock items' rows as on stock 1.73", cut(shots[k], 52) == cut(st, 52))
    check("menustock: item 9 (POLY CONFIG) is a new row: its screen differs from item 8's", cut(shots[9]) != cut(shots[8]))
    n0, s0 = e.run("menu-none", 520, []), e.run("menu-none-stock", 520, [], **kw)
    s3 = e.run("menu-0-stock", 520, at(0), **kw)
    check("menustock: (control) FUNC + CHRO opened the menu on both builds", cut(shots[0]) != cut(n0) and cut(s3) != cut(s0))
    for k in range(5):
        n = e.run(f"menu-{k}-yes", 1000, at(k, True))
        p = prev.run(f"menu-{k}-yes-prev", 1000, at(k, True), **pkw)
        check(f"menustock: YES on item {k} leaves the glass as on the build before", cut(n) == cut(p))
        if k < 2:
            st = e.run(f"menu-{k}-yes-stock", 1000, at(k, True), **kw)
            check(f"menustock: YES on item {k} leaves the glass as on stock 1.73", n["oled"] == st["oled"])


def t_upmaplist(e):
    """1051 (a hardware report on rui1049: UP held to scroll the machine list popped the map): in the machine list (SRC
    twice) UP held 2 s is stock's auto-repeat - the cursor runs to the list's top - and no 49 1 4 / 49 1 5 goes out; the
    same held UP on the stock 1.73 image leaves the same screen (the list's top: the same stock BD machines there); UP
    tapped step by step to the top gives the same machine at YES as the held UP. The main screen keeps its map (upmap).
    (Only the list's scroll bar differs from stock: rui's machine list is longer.)"""
    def maps(r):
        return [m[6:8] for m in r["msgs"] if m[4:6] == b"\x49\x01" and len(m) == 9 and m[6] in (4, 5)]
    lst = [(20, "press", "SRC"), (60, "press", "SRC")]
    h = e.run("upl-hold", 700, lst + [(120, "press", "UP:400")])
    hy = e.run("upl-holdyes", 800, lst + [(120, "press", "UP:400"), (620, "press", "YES")])
    ty = e.run("upl-tapsyes", 1400, lst + [(120 + 30 * i, "press", "UP:8") for i in range(40)] + [(1320, "press", "YES")])
    s = e.run("upl-stock", 700, lst + [(120, "press", "UP:400")], **stock_kw(e))
    mh, mt = e.peek(hy, 0x8000EA00, 1)[0], e.peek(ty, 0x8000EA00, 1)[0]
    print(f"  maps: {maps(h)} {maps(hy)}; machine after held UP + YES {mh}, after 40 taps + YES {mt}")
    check("upmaplist: no map while UP is held in the machine list (no 49 1 4 / 49 1 5)", maps(h) == [] and maps(hy) == [],
          (maps(h), maps(hy)))
    check("upmaplist: the held UP scrolled to the list's top (= 40 taps)", mh == mt, (mh, mt))
    crop = lambda o: [ln[:120] for ln in (o or "").splitlines()[:32]]   # noqa: E731 (the scroll bar: rui's list is longer)
    check("upmaplist: the screen after the held UP equals stock 1.73's (the list's top, its cursor; the scroll bar aside)",
          crop(h["oled"]) == crop(s["oled"]) and bool(crop(h["oled"])))


def t_upmapmenu(e):
    """1051: the track menu (FUNC + CHRO), UP held 2 s: no map (49 1 4 / 49 1 5); the menu stays (the screen equals the
    same run with UP tapped twenty times: its cursor at the top either way)."""
    def maps(r):
        return [m[6:8] for m in r["msgs"] if m[4:6] == b"\x49\x01" and len(m) == 9 and m[6] in (4, 5)]
    mn = [(20, "press", "FUNC:60"), (30, "press", "CHRO")]
    h = e.run("upm-hold", 700, mn + [(120, "press", "UP:400")])
    t = e.run("upm-taps", 900, mn + [(120 + 30 * i, "press", "UP:8") for i in range(20)])
    print(f"  maps: {maps(h)}")
    check("upmapmenu: no map while UP is held in the track menu", maps(h) == [], maps(h))
    check("upmapmenu: the menu's screen after the held UP equals UP tapped to the top", h["oled"] == t["oled"])


TESTS = dict(levelhdr=t_levelhdr, stocktrktrig=t_stocktrktrig, stocktrkfx=t_stocktrkfx, stockyes=t_stockyes, stockup=t_stockup, stockupkeys=t_stockupkeys, stocktrigup=t_stocktrigup, upstock=t_upstock, upamp=t_upamp, kit=t_kit, hostclose=t_hostclose, stockcombo=t_stockcombo, combo=t_combo, leds=t_leds, ledexit=t_ledexit, bad=t_bad, trigs=t_trigs, trkled=t_trkled, upmap=t_upmap, menustock=t_menustock, upmappage=t_upmappage,
             stocklockpush=t_stocklockpush, upmaplist=t_upmaplist, upmapmenu=t_upmapmenu)


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
