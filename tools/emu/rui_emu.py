#!/usr/bin/env python3
"""Emulator tests of 0026-remote-ui (M1) in rytm-emu, with rytm-teensy sim/remote_ui.py as the Sidecar.

    .venv/bin/python tools/emu/rui_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a build with 0022 (rui=1) + 0026 + 0027 (rui), whose base tools/emu/us_base.sh TAG made. Every run under
DTEMU_STRICT=1 (interpreter), with --usb-host --usb-midi-real (the firmware's own USB MIDI sender) and --ob-link,
to which remote_ui.py connects; its clock is the emulator's frame requests, so it runs in emulated time.
Times below are ms after the base snapshot (200 M instructions = 1 emulated second).
Firmware-derived files (snapshots, screens) stay in build/emu/TAG (git-ignored) and rytm-emu's sections/.
RYTM_EMU, RYTM_TEENSY: the checkouts (defaults beside this one).
"""
import json
import os
import re
import socket
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EMU = os.environ.get("RYTM_EMU", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "rytm-emu"))
TEENSY = os.environ.get("RYTM_TEENSY", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "sidecar-firmware"))
sys.path.insert(0, os.path.join(TEENSY, "sim"))
import protocol as P   # noqa: E402

TILE_FN = 0x40095924   # panel tile writer (0x10|page, column, 8 bytes)
RENDER = 0x400a2aaa    # the UI render, 20 Hz
K_YES, K_NO, K_TRK = 0x44, 0x45, 0x86
ST = dict(init=0, active=4, ticks=8, idle=12, rx_seen=16, shown=20, enter_commits=24, blits=28, torn=32, tx_ok=36,
          tx_busy=40, tx_drop=44, enters=48, leaves=52, t_blit=56, lat_commit_blit=60, t_enc=64, lat_enc_report=68,
          last_key=72)
# struct rui after last_enc[5] (76) and acc[16] (96): func.. (160), kq (164..195), kq_n 196, stock_down 200,
# our_down 232, eat 264, last_reason 296
BITMAPS = (200, 232, 264, 904)   # 1022: both_down 904 (after bm[8], rui.c's struct end)
K_CAUGHT = 936   # k_caught, k_passed, k_transport, e_caught, e_passed
LAST_REASON = 296
T_TICK = 300
LAT = 304   # cb_sum, cb_n, cb_max, er_sum, er_n, er_max
# 1023 (after e_passed 952): port_ticks hello_n hello_rx hellos splash_on splash_left splashes splash_ignored splash_why
SPL = dict(port_ticks=956, hello_n=960, hellos=968, splash_on=972, splash_left=976, splashes=980, splash_ignored=984,
           splash_why=988)
WHY = {0: "-", 1: "time", 2: "host", 3: "idle", 4: "key", 5: "enc", 6: "open"}
# a dtboot with --usb-host-gone (a host that browns out and comes back) for the re-plug test; skipped without one
DTBOOT = os.environ.get("RUI_DTBOOT", os.path.join(EMU, "target/release/dtboot"))

FAILS = []


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"   [{detail}]" if detail else ""), flush=True)
    if not ok:
        FAILS.append(name)


class Emu:
    def __init__(self, tag):
        self.tag = tag
        self.fw = f"fw/AR173_us_{tag}.syx"
        self.card = f"sections/us_{tag}.img"
        self.snap = f"sections/us_{tag}.snap"
        self.clock = json.load(open(os.path.join(EMU, f"sections/us_{tag}.json")))["clock"]
        self.out = os.path.join(ROOT, "build", "emu", tag)
        os.makedirs(self.out, exist_ok=True)
        m = json.load(open(os.path.join(self.out, "manifest.json")))
        self.syms = m["elek"]["symbols"]

    def sym(self, name):
        return self.syms["rytm-0026-remote-ui:" + name]

    def at(self, ms):
        return f"{self.clock + ms / 5:g}M"

    def run(self, name, ms, events=(), script=None, counts=(), extra=(), env=None, save=True):
        """events: (ms, 'press', KEY[, hold ms]) / (ms, 'turn', 'ENC:DELTA', count, spacing ms) /
        (ms, 'noread', to_ms) / (ms, 'sleep', to_ms). script: remote_ui.py's arguments (None: no host)."""
        s = socket.socket()
        s.bind(("127.0.0.1", 0))
        port = s.getsockname()[1]
        s.close()
        snap = os.path.join(self.out, f"{name}.snap")
        cmd = [DTBOOT, self.fw, "--load", self.snap, "--card", self.card,
               "--instr", f"{ms // 5}M", "--every", "20M", "--usb-host", "--usb-midi-real",
               "--ob-link", f"127.0.0.1:{port}", *extra]
        for e in events:
            if e[1] == "press":
                cmd += ["--press", f"{e[2]}@{self.at(e[0])}" + (f":{e[3] // 5}M" if len(e) > 3 else "")]
            elif e[1] == "turn":
                cmd += ["--turn", f"{e[2]}@{self.at(e[0])}x{e[3]}/{e[4] // 5 if len(e) > 4 else 4}M"]
            elif e[1] == "noread":
                cmd += ["--usb-host-noread", f"{self.at(e[0])}:{self.at(e[2])}"]
            elif e[1] == "sleep":
                cmd += ["--usb-host-sleep", f"{self.at(e[0])}:{self.at(e[2])}"]
            elif e[1] == "gone":
                cmd += ["--usb-host-gone", f"{self.at(e[0])}:{self.at(e[2])}"]
        for c in counts:
            cmd += ["--count", f"{c:x}"]
        if save:
            cmd += ["--save", snap]
        en = dict(os.environ, DTEMU_STRICT="1", DTBOOT_OLED="1", **(env or {}))
        log = os.path.join(self.out, f"{name}.jsonl")
        sp = None
        if script is not None:
            if os.path.exists(log):
                os.remove(log)
            sp = subprocess.Popen([sys.executable, os.path.join(TEENSY, "sim/remote_ui.py"), "--link",
                                   f"127.0.0.1:{port}", "--secs", "900", "--log", log,
                                   "--frame", os.path.join(self.out, f"{name}.frame"), *script],
                                  stdout=open(os.path.join(self.out, f"{name}.script.txt"), "w"),
                                  stderr=subprocess.STDOUT)
        r = subprocess.run(cmd, cwd=EMU, env=en, capture_output=True, text=True)
        if sp:
            try:
                sp.wait(timeout=30)
            except subprocess.TimeoutExpired:
                sp.kill()
        open(os.path.join(self.out, f"{name}.dt.txt"), "w").write(r.stdout + r.stderr)
        res = dict(out=r.stdout + r.stderr, snap=snap, events=[], rc=r.returncode)
        if os.path.exists(log):
            res["events"] = [json.loads(x) for x in open(log)]
        res["oled"] = oled(res["out"])
        res["status"] = status(res["out"])
        fault = "FAULT" in res["out"] or "strict:" in res["out"] or r.returncode != 0
        check(f"{name}: dtboot ran clean (strict, no fault)", not fault,
              "" if not fault else (re.findall(r".*(?:FAULT|strict:).*", res["out"])[:3] or [f"rc {r.returncode}"]))
        return res

    def peek(self, snap, addr, n):
        r = subprocess.run([os.path.join(EMU, "target/release/dtpeek"), snap, "mem", f"{addr:x}", str(n)],
                           cwd=EMU, env=dict(os.environ, DTEMU_FW=self.fw), capture_output=True, text=True)
        b = bytearray()
        for line in r.stdout.splitlines():
            m = re.match(r"^[0-9a-f]+: ((?:[0-9a-f]{2} ?)+)", line)
            if m:
                b += bytes.fromhex(m.group(1).replace(" ", ""))
        return bytes(b[:n])

    def st(self, snap, field):
        off = ST[field] if isinstance(field, str) else field
        return int.from_bytes(self.peek(snap, self.sym("st") + off, 4), "big")


def oled(out):
    """dtboot's last screen (DTBOOT_OLED: the panel MCU's own pixels), half blocks -> the 1024 B framebuffer."""
    i = out.rfind("panel MCU OLED")
    if i < 0:
        return None
    lines = out[i:].splitlines()[1:33]
    fb = bytearray(1024)
    for ty, line in enumerate(lines):
        for x, ch in enumerate(line[:128]):
            for dy, on in enumerate({"█": (1, 1), "▀": (1, 0), "▄": (0, 1)}.get(ch, (0, 0))):
                if on:
                    y = 2 * ty + dy
                    fb[(7 - y // 8) + 8 * x] |= 1 << (y % 8)
    return bytes(fb)


def status(out):
    """The status lines: [(clock M, panel frames, {counter: n})]."""
    r = []
    for m in re.finditer(r"^\s*(\d+)M pc=\S+ .*?frames=(\d+).*?$", out, re.M):
        cs = dict((int(a, 16), int(n)) for a, n in re.findall(r"([0-9a-f]{8}):(\d+)", m.group(0)))
        r.append((int(m.group(1)), int(m.group(2)), cs))
    return r


def evs(res, kind):
    return [e for e in res["events"] if e["ev"] == kind]


ENTER = [(100, "press", "TRK", 300), (200, "press", "YES")]


def timer_hz(e):
    """DTCN0's rate in the emulator: TIMER at the last tick, two runs 1 s apart (the ticks keep their phase)."""
    if not hasattr(e, "hz"):
        a = e.st(e.run("cal-a", 500, [])["snap"], T_TICK)
        b = e.st(e.run("cal-b", 1500, [])["snap"], T_TICK)
        e.hz = (b - a) & 0xffffffff
        print(f"    DTCN0: {e.hz / 1e6:.3f} MHz (emulated)")
    return e.hz


def t_frame(e):
    """The pattern on glass byte for byte; the moving tile costs 2 tiles a tick; turns arrive with encoder + sign."""
    r = e.run("frame", 4000, ENTER + [(1500, "turn", "3:+2", 5, 20), (2000, "turn", "0:-1", 3, 20),
                                      (2500, "turn", "7:+5", 2, 20)],
              script=["--still-at", "3.0"], counts=(TILE_FN, RENDER))
    modes = evs(r, "mode")
    check("frame: TRK + YES opens the page (30 page 0 on, user)", modes[:1] and modes[0]["on"] == 1 and
          modes[0]["reason"] == "user", modes[:1])
    keys = evs(r, "key")
    check("frame: the combo's YES (and TRK, pressed before) never reach the host", not keys, keys)
    frame = open(os.path.join(e.out, "frame.frame"), "rb").read()
    sh = e.peek(r["snap"], e.sym("shadow"), 1024)
    check("frame: the shadow holds the last committed frame byte for byte", sh == frame,
          f"{sum(a != b for a, b in zip(sh, frame))} bytes differ")
    check("frame: the panel's pixels (the OLED the panel MCU holds) are that frame byte for byte", r["oled"] == frame,
          f"{sum(a != b for a, b in zip(r['oled'] or b'', frame))} bytes differ")
    enc = {}
    for x in evs(r, "enc"):
        enc[x["enc"]] = enc.get(x["enc"], 0) + x["delta"]
    check("frame: turns arrive summed with the right encoder and sign (3: +10, 0: -3, 7: +10)",
          enc == {3: 10, 0: -3, 7: 10}, enc)
    # steady streaming window: 1.0..1.5 s (tile moving, no turn): panel tiles per panel frame
    st = r["status"]
    w = [x for x in st if e.clock + 200 <= x[0] <= e.clock + 300]
    if len(w) >= 2:
        dt, df = w[-1][2].get(TILE_FN, 0) - w[0][2].get(TILE_FN, 0), w[-1][1] - w[0][1]
        dr = w[-1][2].get(RENDER, 0) - w[0][2].get(RENDER, 0)
        check("frame: with only the 8x8 tile moving, 2 panel tiles a frame (old + new) and 20 frames/s",
              df > 0 and dt == 2 * df and df == dr == 10, f"{dt} tiles, {df} panel frames, {dr} renders in 0.5 s")
    still = [x for x in st if e.clock + 700 <= x[0] <= e.clock + 800]
    if len(still) >= 2:
        dt = still[-1][2].get(TILE_FN, 0) - still[0][2].get(TILE_FN, 0)
        check("frame: a still remote page sends no tiles (keepalives only)", dt == 0, f"{dt} tiles in 0.5 s")
    lat_cb = e.st(r["snap"], "lat_commit_blit")
    lat_er = e.st(r["snap"], "lat_enc_report")
    hz = timer_hz(e) / 1e3
    L = [e.st(r["snap"], LAT + 4 * i) for i in range(6)]
    print(f"    commit -> first blit: mean {L[0] / max(L[1], 1) / hz:.1f} ms, max {L[2] / hz:.1f} ms over {L[1]} frames; "
          f"turn -> report: mean {L[3] / max(L[4], 1) / hz:.1f} ms, max {L[5] / hz:.1f} ms over {L[4]}")
    print(f"    commit -> blit {lat_cb / hz:.2f} ms, last first-turn -> report {lat_er / hz:.2f} ms; "
          f"torn {e.st(r['snap'], 'torn')}, blits {e.st(r['snap'], 'blits')}, tx ok {e.st(r['snap'], 'tx_ok')} "
          f"busy {e.st(r['snap'], 'tx_busy')} drop {e.st(r['snap'], 'tx_drop')}")
    commits = evs(r, "commit")
    done = evs(r, "done")
    print(f"    host: {len(commits)} commits, {done[-1] if done else '-'}")
    return r


def bitmaps_clear(e, snap):
    return all(not any(e.peek(snap, e.sym("st") + o, 32)) for o in BITMAPS)


def ref_screen(e, name, ms, events):
    return e.run(name, ms, events)["oled"]


def t_kill(e):
    """The Sidecar killed mid-stream: back to the stock screen within ~1 s (timeout), no key stuck, and a stock page
    change after leaving redraws exactly as without the remote page."""
    tail = [(3200, "press", "AMP"), (3600, "press", "AMP")]
    r = e.run("kill", 4200, ENTER + [(900, "press", "NO"), (1100, "press", "FUNC", 200)] + tail,
              script=["--stop-at", "1.3"], counts=(TILE_FN, RENDER))
    lr = e.st(r["snap"], LAST_REASON)
    check("kill: the page left on its own, reason timeout", e.st(r["snap"], "active") == 0 and lr == 2, f"{lr:#x}")
    keys = [(x["key"], x["down"]) for x in evs(r, "key")]
    check("kill: NO and FUNC pressed on the page went to the host (down and up)",
          (K_NO, 1) in keys and (K_NO, 0) in keys, keys)
    check("kill: no key held in 0026's books (stock / ours / eaten all empty)", bitmaps_clear(e, r["snap"]))
    # when: the panel frames after the stop until the stock screen
    ref = ref_screen(e, "kill-ref", 4200, tail)
    check("kill: after leaving, two AMP presses redraw the same screen as on a Rytm that never left stock",
          r["oled"] == ref, f"{sum(a != b for a, b in zip(r['oled'] or b'', ref or b''))} bytes differ")
    r2 = e.run("kill-when", 2800, ENTER, script=["--stop-at", "1.3"])
    ref2 = ref_screen(e, "kill-when-ref", 2800, [])
    check("kill: 1.5 s after the Sidecar stopped (at ~1.1 s on the Rytm's clock + the 1 s timeout) the stock screen is "
          "back", r2["oled"] == ref2, f"{sum(a != b for a, b in zip(r2['oled'] or b'', ref2 or b''))} bytes differ")


def t_escape(e):
    """TRK + YES on the page leaves (reason escape), never forwarded; the host's 3A 0 leaves (reason host)."""
    r = e.run("escape", 2500, ENTER + [(1200, "press", "TRK", 300), (1300, "press", "YES")], script=[])
    m = evs(r, "mode")
    check("escape: TRK + YES again leaves (30 off, escape)", len(m) == 2 and m[1]["on"] == 0 and
          m[1]["reason"] == "escape", m)
    keys = [(x["key"], x["down"]) for x in evs(r, "key")]
    check("escape: the host saw TRK (pressed on the page) but never YES", (K_TRK, 1) in keys and
          all(k != K_YES for k, _ in keys), keys)
    check("escape: no key held in 0026's books", bitmaps_clear(e, r["snap"]))
    r = e.run("hostclose", 2500, [], script=["--open", "--close-at", "1.5"])
    m = evs(r, "mode")
    check("host: 3A 0 1 opens (reason host), 3A 0 0 closes (reason host)", [(x["on"], x["reason"]) for x in m] ==
          [(1, "host"), (0, "host")], m)
    ref = ref_screen(e, "hostclose-ref", 2500, [])
    check("host: after 3A 0 0 the stock screen is back", r["oled"] == ref)


def t_noread(e):
    """The USB host stops reading MIDI IN (and then sleeps): the UI task never waits - 20 renders a second throughout,
    keys still reach stock after leaving; reports are held, not blocked on."""
    r = e.run("noread", 5000, ENTER + [(800, "noread", 2400), (1000, "turn", "1:+1", 40, 20),
                                       (2400, "sleep", 3200), (2500, "turn", "1:+1", 10, 20)],
              script=["--stop-at", "2.0"], counts=(RENDER,))
    st = r["status"]
    rates = []
    for a, b in zip(st, st[5:]):
        rates.append(b[2].get(RENDER, 0) - a[2].get(RENDER, 0))
    check("noread: the UI renders 20 times a second through no-read, sleep and the timeout",
          rates and min(rates) >= 10, f"per 0.5 s (10 = 20 Hz): min {min(rates) if rates else '-'} max {max(rates) if rates else '-'}")
    check("noread: the page left by the timeout once the Sidecar stopped", e.st(r["snap"], "active") == 0 and
          e.st(r["snap"], LAST_REASON) == 2)
    print(f"    tx ok {e.st(r['snap'], 'tx_ok')} busy {e.st(r['snap'], 'tx_busy')} drop {e.st(r['snap'], 'tx_drop')}")


def t_full(e):
    """Full-frame streaming (every step a whole 38): panel tiles per second (the UART's limit)."""
    r = e.run("full", 3000, ENTER, script=["--full"], counts=(TILE_FN, RENDER))
    st = r["status"]
    w = [x for x in st if e.clock + 200 <= x[0] <= e.clock + 500]
    dt = w[-1][2].get(TILE_FN, 0) - w[0][2].get(TILE_FN, 0)
    e.full_rate = dt / ((w[-1][0] - w[0][0]) / 200)
    df = w[-1][1] - w[0][1]
    secs = (w[-1][0] - w[0][0]) / 200
    print(f"    full frames: {dt / secs:.0f} tiles/s, {df / secs:.1f} panel frames/s")
    check("full: full-frame streaming runs (tiles reach the panel)", dt > 0)
    done = evs(r, "done")
    print(f"    host: {done[-1] if done else '-'}")


UI = LAT + 24        # ui_sum, ui_max, ui_calls (TIMER counts inside the UI-task entries)


def t_cost(e):
    """0026's own cost, timed inside each entry with DTCN0 (132 MHz; x 200/132 = instructions at the emulator's
    200 MIPS; an interrupt taken inside an entry counts too, so these are upper bounds): per tick in the UI task, the
    worst UI call, the MIDI task's handler per host message; against rytm-teensy 2026-10-16-rytm-stress-budgets.md."""
    k = 200 / 132
    for name, script, evts in (("cost-idle", None, [(500, "press", "BD"), (1000, "turn", "3:+1", 20, 20)]),
                               ("cost-tile", ["--still-at", "3.0"], ENTER + [(1500, "turn", "3:+1", 20, 20),
                                                                            (2200, "press", "NO"), (2400, "press", "BD")]),
                               ("cost-full", ["--full"], ENTER)):
        r = e.run(name, 4000, evts, script=script)
        sn = r["snap"]
        ui_sum, ui_max, ui_calls = (e.st(sn, UI + 4 * i) for i in range(3))
        ticks = e.st(sn, "ticks")
        g = lambda n: int.from_bytes(e.peek(sn, e.sym(n), 4), "big")   # noqa: E731
        mt_sum, mt_max, mt_calls = g("mt_sum"), g("mt_max"), g("mt_calls")
        per_tick = ui_sum * k / max(ticks, 1)
        print(f"    {name}: UI {per_tick:.0f} instr/tick ({ui_calls} calls over {ticks} ticks), worst call {ui_max * k:.0f}; "
              f"MIDI task {mt_calls} messages, mean {mt_sum * k / max(mt_calls, 1):.0f}, worst {mt_max * k:.0f}")
        check(f"{name}: UI-task cost <= 10 k instructions a tick on average", per_tick <= 10000, f"{per_tick:.0f}")
        check(f"{name}: no UI call above 100 k instructions", ui_max * k <= 100000, f"{ui_max * k:.0f}")
        check(f"{name}: no host message above 100 k instructions in the MIDI task", mt_max * k <= 100000,
              f"{mt_max * k:.0f}")


def counters(e, snap):
    return dict(zip(("k_caught", "k_passed", "k_transport", "e_caught", "e_passed"),
                    (e.st(snap, K_CAUGHT + 4 * i) for i in range(5))))


def g32(e, snap, name):
    return int.from_bytes(e.peek(snap, e.sym(name), 4), "big")


def tiles_between(e, r, a_ms, b_ms):
    w = [x for x in r["status"] if e.clock + a_ms / 5 <= x[0] <= e.clock + b_ms / 5]
    return (w[-1][2].get(TILE_FN, 0) - w[0][2].get(TILE_FN, 0)) if len(w) >= 2 else None


NAV = "k=LEFT,RIGHT,UP,DOWN,YES,NO,PAGE"


def t_pass(e):
    """1022: the catch mask. A page catching encoder D and the navigation keys: PLAY / STOP start and stop the
    sequencer (the Rytm's MIDI transport out) while the page stays, a pad and encoder A go to stock, encoder D still to
    the host; no stock draw reaches the panel. Then a key's owner across a mask change and leaving; and the mask
    forgotten when the host goes."""
    r = e.run("pass", 1900, ENTER + [(800, "press", "PLAY"), (1000, "press", "BD"), (1050, "turn", "3:+2", 3, 20),
                                     (1200, "turn", "0:+1", 3, 20), (1500, "press", "STOP")],
              script=["--still-at", "0.6", "--mask", f"e=3;{NAV}"], counts=(TILE_FN, RENDER))
    rt = [x["b"] for x in evs(r, "rt")]
    check("pass: PLAY started and STOP stopped the sequencer with the page open (MIDI FA ... FC from the Rytm)",
          0xFA in rt and 0xFC in rt and rt.index(0xFA) < len(rt) - 1 - rt[::-1].index(0xFC), [hex(b) for b in rt])
    keys = [(x["key"], x["down"]) for x in evs(r, "key")]
    check("pass: PLAY, STOP and the pad never reached the host", not keys, keys)
    enc = {}
    for x in evs(r, "enc"):
        enc[x["enc"]] = enc.get(x["enc"], 0) + x["delta"]
    check("pass: the caught encoder D reached the host (+6), the passed encoder A did not", enc == {3: 6}, enc)
    modes = evs(r, "mode")
    check("pass: the page stayed open throughout (one 30 on, no 30 off)", [m["on"] for m in modes] == [1] and
          e.st(r["snap"], "active") == 1, modes)
    frame = open(os.path.join(e.out, "pass.frame"), "rb").read()
    check("pass: the panel shows the host's last frame byte for byte", r["oled"] == frame,
          f"{sum(a != b for a, b in zip(r['oled'] or b'', frame))} bytes differ")
    t = tiles_between(e, r, 1150, 1900)
    check("pass: no stock draw reached the panel after the last caught turn (encoder A, PLAY / STOP on stock)",
          t == 0, f"{t} tiles written 1.15..1.9 s")
    c = counters(e, r["snap"])
    check("pass: 0026's counts: 2 transport presses, the pad passed, turn events caught and passed",
          c["k_transport"] == 2 and c["k_passed"] == 1 and c["e_caught"] >= 1 and c["e_passed"] >= 1, c)
    notes = evs(r, "note")
    t_pad = [x["t"] for x in evs(r, "rt") if x["b"] == 0xFA][:1]   # the host's clock: PLAY was at 800, BD at 1000
    check("pass: the pad played (the Rytm's MIDI note-on for BD, 0.2 s after PLAY's FA)",
          bool(t_pad) and any(0.1 < n["t"] - t_pad[0] < 0.35 for n in notes), [(n["t"], n["note"]) for n in notes])
    print(f"    MIDI from the Rytm: transport {[hex(b) for b in rt]}, note-ons "
          f"{[(hex(n['status']), n['note'], n['t']) for n in notes]}")

    # ownership: NO caught and BANK_A passed at their press, held across a new mask that flips both; then BANK_A caught
    # and held across leaving
    r = e.run("own", 2700, ENTER + [(1000, "press", "NO", 400), (1000, "press", "BANK_A", 400), (1700, "press", "NO"),
                                    (1900, "press", "BANK_A", 600), (2100, "press", "TRK", 300), (2200, "press", "YES")],
              script=["--still-at", "0.6", "--mask", "k=NO", "--mask-at", "1.2=k=BANK_A"])
    keys = [(x["key"], x["down"], round(x["t"], 2)) for x in evs(r, "key")]
    kd = [(k, d) for k, d, _ in keys]
    check("own: NO (caught at its press) went to the host down and up, its release after the new mask",
          kd[:2] == [(K_NO, 1), (K_NO, 0)] and keys[1][2] >= 1.2, keys)
    check("own: NO pressed again under the new mask went to stock (the host saw no second NO)",
          kd.count((K_NO, 1)) == 1, keys)
    check("own: BANK_A passed at its first press (never to the host then), caught at its second (down; its release "
          "after leaving eaten)", kd.count((0xC0, 1)) == 1 and (0xC0, 0) not in kd and
          [t for k, d, t in keys if k == 0xC0][0] >= 1.6, keys)
    m = evs(r, "mode")
    check("own: left by TRK + YES", len(m) == 2 and m[1]["reason"] == "escape", m)
    check("own: no key held in 0026's books (stock / ours / both / eaten all empty)", bitmaps_clear(e, r["snap"]))

    # the default (no 37: an older host) and FUNC: a caught modifier reaches both sides
    r = e.run("default", 1900, ENTER + [(800, "press", "PLAY"), (900, "press", "NO"), (1000, "press", "FUNC", 300),
                                        (1100, "turn", "0:+1", 2, 20), (1500, "press", "STOP")],
              script=["--still-at", "0.6"], counts=(TILE_FN,))
    rt = [x["b"] for x in evs(r, "rt")]
    kd = [(x["key"], x["down"]) for x in evs(r, "key")]
    turns = [(x["enc"], x["delta"], x["func"]) for x in evs(r, "enc")]
    check("default: without a mask PLAY / STOP still go to stock (FA, FC) and not to the host",
          0xFA in rt and 0xFC in rt and all(k not in (0x51, 0x52) for k, _ in kd), ([hex(b) for b in rt], kd))
    check("default: everything else caught as before: NO and FUNC down + up, encoder A's turns with FUNC held (func 1)",
          sorted(kd) == sorted([(K_NO, 1), (K_NO, 0), (0x80, 1), (0x80, 0)]) and turns and all(t[0] == 0 and t[2] == 1 for t in turns),
          (kd, turns))
    t = tiles_between(e, r, 1250, 1900)
    check("default: no stock draw reached the panel after the host's last frame (PLAY / STOP on stock)", t == 0,
          f"{t} tiles 1.25..1.9 s")
    check("default: no key held in 0026's books", bitmaps_clear(e, r["snap"]))

    # the host goes: the page leaves by the timeout and the mask is forgotten (the next host starts from the default)
    r = e.run("maskgone", 2700, ENTER, script=["--mask", NAV, "--stop-at", "1.0"])
    check("maskgone: the mask was taken, then forgotten when the page left by the timeout",
          g32(e, r["snap"], "masks") == 1 and g32(e, r["snap"], "mask_set") == 0 and
          e.st(r["snap"], LAST_REASON) == 2, (g32(e, r["snap"], "masks"), g32(e, r["snap"], "mask_set")))


SURVEY_KEYS = ["PLAY", "STOP", "RECORD", "BD", "CB", "MUTE", "TEMPO", "FUNC", "TRK", "RTRG", "FILL", "T1", "BANK_A",
               "PUSH_A", "PUSH_LEVEL", "TRIG", "SRC", "SMPL", "FLTR", "AMP", "LFO", "FX", "CHRO", "SCNE", "PERF",
               "GLOBAL", "QPER", "FIX", "SAMPLER", "PLAYMODE", "SONG", "CHAIN", "PAGE", "YES", "NO", "LEFT", "UP"]


def t_survey(e):
    """1022 [measured]: every key (and encoder A, LEVEL) passed to stock with the page open (mask: nothing caught):
    the remote frame stays on the panel untouched (no tile written while the page is still), and what the key did to
    stock's screen, seen after leaving, against the same press on a Rytm that never opened the page."""
    import concurrent.futures as cf
    ref0 = e.run("sv-ref0", 2600, [])["oled"]

    def one(k):
        ev_ = [(900, "press", k, 100)] if not k.startswith("enc") else [(900, "turn", f"{k[3:]}:+3", 3, 20)]
        a = e.run(f"sv-{k}-on", 1500, ENTER + ev_, script=["--still-at", "0.6", "--mask", "k="],
                  counts=(TILE_FN,), save=False)
        b = e.run(f"sv-{k}-left", 2600, ENTER + ev_ + [(1600, "press", "TRK", 300), (1700, "press", "YES")],
                  script=["--still-at", "0.6", "--mask", "k="], save=False)
        ref = e.run(f"sv-{k}-ref", 2600, [x for x in ev_], save=False)
        frame = open(os.path.join(e.out, f"sv-{k}-on.frame"), "rb").read()
        return k, a, b, ref, frame
    rows = []
    with cf.ThreadPoolExecutor(4) as ex:
        for k, a, b, ref, frame in ex.map(one, SURVEY_KEYS + ["enc0", "enc8"]):
            t = tiles_between(e, a, 800, 1500)
            intact = a["oled"] == frame and t == 0
            same = b["oled"] == ref["oled"]
            changed = ref["oled"] != ref0
            hk = [x for x in evs(a, "key")] + [x for x in evs(a, "enc")]
            rows.append((k, intact, t, same, changed, hk))
            check(f"survey {k}: passed to stock, nothing to the host, the remote frame untouched", intact and not hk,
                  f"tiles {t}, host {hk}")
    print("    key        frame kept  after leave = stock's  stock screen changed by it")
    for k, intact, t, same, changed, _ in rows:
        print(f"    {k:<10} {str(intact):<11} {str(same):<22} {changed}")
    json.dump([dict(key=k, intact=i, tiles=t, after_leave_as_stock=s_, stock_changed=c) for k, i, t, s_, c, _ in rows],
              open(os.path.join(e.out, "survey.json"), "w"), indent=1)


def spl(e, snap):
    return {k: e.st(snap, o) for k, o in SPL.items()}


def t_splash(e):
    """1023: the connect splash. The base Rytm has been up ~30 s; the run's USB host enumerates it at once, so 0026 says
    hello (35) ~0.5 s in and the host answers with a frame (the checkerboard inverted) and 36. Keys during it stay
    stock's (PLAY runs the sequencer, a pad plays, nothing to the host); it leaves after its time, early on a key (a
    navigation key only ends it), on 36 0, or 1 s after the host went; never while the page is open; TRK + YES opens
    the page over it; the stock screen afterwards equals a Rytm that never showed it."""
    ref0 = e.run("spl-ref0", 4300, [])
    s0 = spl(e, ref0["snap"])
    check("splash: no host answering: the hello went out 3 times (0.5 s, 1.5 s, 2.5 s after the port came up), no "
          "splash", s0["hellos"] == 3 and s0["splashes"] == 0, s0)
    play = [(1200, "press", "PLAY"), (1400, "press", "BD")]
    r = e.run("spl-on", 2500, play, script=["--splash", "60"], counts=(TILE_FN,))
    h = evs(r, "hello")
    s1 = spl(e, r["snap"])
    check("splash: hello (35) once with the Rytm's uptime (> 20 s, the base's boot) and caps 1",
          len(h) == 1 and h[0]["up"] > 400 and h[0]["caps"] == 1, h)
    frame = open(os.path.join(e.out, "spl-on.frame"), "rb").read()
    check("splash: on, the panel shows the host's splash frame byte for byte", s1["splash_on"] == 1 and r["oled"] == frame,
          f"{s1}, {sum(a != b for a, b in zip(r['oled'] or b'', frame))} bytes differ")
    rt = [x["b"] for x in evs(r, "rt")]
    notes = evs(r, "note")
    check("splash: PLAY ran the sequencer (FA) and the pad played under it, the splash stayed",
          0xFA in rt and notes and s1["splash_on"] == 1, ([hex(b) for b in rt], len(notes)))
    check("splash: no key or turn reached the host, the page never opened", not evs(r, "key") and not evs(r, "enc") and
          not evs(r, "mode") and e.st(r["snap"], "active") == 0)
    t = tiles_between(e, r, 1300, 2500)
    check("splash: stock's draws (PLAY, the pad) never reached the panel under it", t == 0, f"{t} tiles 1.3..2.5 s")
    # after its time (60 ticks from ~0.6 s): the stock screen as on a Rytm that never showed it
    r = e.run("spl-time", 4300, play, script=["--splash", "60"])
    ref = e.run("spl-time-ref", 4300, play)
    s2 = spl(e, r["snap"])
    check("splash: gone after its 3 s (why: time), the stock screen equals the same presses without a splash",
          s2["splash_on"] == 0 and WHY[s2["splash_why"]] == "time" and r["oled"] == ref["oled"],
          f"{s2}, {sum(a != b for a, b in zip(r['oled'] or b'', ref['oled'] or b''))} bytes differ")
    check("splash: no key held in 0026's books", bitmaps_clear(e, r["snap"]))
    # a navigation key ends it and is eaten (never reaches stock); another key ends it and reaches stock
    r = e.run("spl-left", 2600, [(1500, "press", "LEFT")], script=["--splash", "127"])
    s3 = spl(e, r["snap"])
    ref = e.run("spl-left-ref", 2600, [])
    check("splash: LEFT ended it early (why: key) and was eaten: the stock screen as without the press",
          s3["splash_on"] == 0 and WHY[s3["splash_why"]] == "key" and r["oled"] == ref["oled"] and
          bitmaps_clear(e, r["snap"]), s3)
    r = e.run("spl-amp", 2600, [(1500, "press", "AMP")], script=["--splash", "127"])
    s4 = spl(e, r["snap"])
    ref = e.run("spl-amp-ref", 2600, [(1500, "press", "AMP")])
    check("splash: AMP ended it early and reached stock: the stock screen as the same press without a splash",
          s4["splash_on"] == 0 and WHY[s4["splash_why"]] == "key" and r["oled"] == ref["oled"] and
          ref["oled"] != ref0["oled"], s4)
    r = e.run("spl-enc", 2600, [(1500, "turn", "0:+2", 2, 20)], script=["--splash", "127"])
    s5 = spl(e, r["snap"])
    ref = e.run("spl-enc-ref", 2600, [(1500, "turn", "0:+2", 2, 20)])
    check("splash: a turn ended it and reached stock (the same screen as the turn without a splash)",
          WHY[s5["splash_why"]] == "enc" and r["oled"] == ref["oled"] and not evs(r, "enc"), s5)
    # the host ends it (36 0); the host goes (no message for 1 s)
    r = e.run("spl-host", 2600, [], script=["--splash", "127", "--splash-end-at", "1.5"])
    s6 = spl(e, r["snap"])
    check("splash: 36 0 ended it (why: host), the stock screen back", WHY[s6["splash_why"]] == "host" and
          r["oled"] == ref0_at(e, 2600), s6)
    r = e.run("spl-gone", 3000, [], script=["--splash", "127", "--stop-at", "1.2"])
    s7 = spl(e, r["snap"])
    check("splash: the host stopped mid-splash: gone ~1 s later (why: idle), the stock screen back",
          WHY[s7["splash_why"]] == "idle" and s7["splash_on"] == 0 and r["oled"] == ref0_at(e, 3000), s7)
    # TRK + YES during the splash opens the page over it; a 36 while the page is open is ignored
    r = e.run("spl-user", 2600, [(1300, "press", "TRK", 300), (1400, "press", "YES")], script=["--splash", "127"])
    s8 = spl(e, r["snap"])
    m = evs(r, "mode")
    check("splash: TRK + YES during it opens the page (30 on, user; TRK, a non-playing key, ends the splash first)",
          m[:1] and m[0]["on"] == 1 and m[0]["reason"] == "user" and WHY[s8["splash_why"]] in ("key", "open") and
          e.st(r["snap"], "active") == 1, (m, s8))
    r = e.run("spl-active", 2000, ENTER, script=["--splash", "60"])
    s9 = spl(e, r["snap"])
    check("splash: a 36 while the page is open is ignored (the page stays, no splash)", s9["splash_ignored"] == 1 and
          s9["splashes"] == 0 and e.st(r["snap"], "active") == 1, s9)
    # the cable re-plugged: the host gone and back (a fresh enumeration): a new hello and a new splash
    hp = subprocess.run([DTBOOT, "--help"], capture_output=True, text=True)
    if "--usb-host-gone" in hp.stdout + hp.stderr:
        r = e.run("spl-replug", 8500, [(4000, "gone", 4800)], script=["--splash", "60"])
        s10 = spl(e, r["snap"])
        h = evs(r, "hello")
        check("splash: re-plugged (the host gone 4.0..4.8 s): hello again and a second splash, over by its time",
              len(h) == 2 and s10["splashes"] == 2 and s10["splash_on"] == 0 and WHY[s10["splash_why"]] == "time" and
              r["oled"] == ref0_at(e, 8500), (h, s10))
    else:
        print("    re-plug: skipped (no --usb-host-gone in this dtboot; RUI_DTBOOT)")


def ref0_at(e, ms):
    if not hasattr(e, "ref0s"):
        e.ref0s = {}
    if ms not in e.ref0s:
        e.ref0s[ms] = e.run(f"spl-ref0-{ms}", ms, [])["oled"]
    return e.ref0s[ms]


TESTS = dict(frame=t_frame, kill=t_kill, escape=t_escape, noread=t_noread, full=t_full, cost=t_cost, pass_=t_pass, splash=t_splash)
EXTRA = dict(survey=t_survey)   # not in "all": 3 runs a key


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    e = Emu(sys.argv[1])
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    for n in names:
        n = "pass_" if n == "pass" else n
        print(f"== {n.rstrip('_')}", flush=True)
        (TESTS.get(n) or EXTRA[n])(e)
    print("ALL PASS" if not FAILS else f"FAILED: {FAILS}")
    sys.exit(1 if FAILS else 0)


if __name__ == "__main__":
    main()
