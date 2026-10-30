#!/usr/bin/env python3
"""Emulator tests of 0026's SRC view (1027): the host's frame over the stock SRC page of a Sidecar track, every key and
knob the Rytm's own; 29 (view on / off) and 2A (the page's values) to the host.

    .venv/bin/python tools/emu/sv_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a rui build (0021 slots=1, 0022 rui=1, 0026, 0027) with its base from tools/emu/us_base.sh TAG (BD PLASTIC on BD,
the SRC page showing). Every run under DTEMU_STRICT=1 with --usb-host --usb-midi-real --ob-link; the host is this
script in --host mode (rytm-teensy sim/protocol.py's 38 / 39 / 3C): it answers each 29 t 1 with a whole checkerboard
frame and sends 3C every 250 ms (--no-answer: keepalives only, an old host). Times are ms after the base (200 M
instructions = 1 s). RYTM_EMU, RYTM_TEENSY: the checkouts.
"""
import json
import os
import re
import socket
import struct
import subprocess
import sys
import time

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EMU = os.environ.get("RYTM_EMU", os.path.join(os.path.dirname(ROOT), "rytm-emu"))
TEENSY = os.environ.get("RYTM_TEENSY", os.path.join(os.path.dirname(ROOT), "rytm-teensy"))
sys.path.insert(0, os.path.join(TEENSY, "sim"))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
UI = json.load(open(os.path.join(ROOT, "tools", "emu", "us_ui.json")))
FAILS = []


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"   [{detail}]" if detail else ""), flush=True)
    if not ok:
        FAILS.append(name)


# ---- the host ------------------------------------------------------------------------------------------------------
def host(link, log, frame, answer, stop_at, secs=900, sends=None):
    import protocol as P
    h, p = link.rsplit(":", 1)
    t0 = time.time()
    while True:
        try:
            s = socket.create_connection((h, int(p)), timeout=1)
            break
        except OSError:
            if time.time() - t0 > 60:
                sys.exit("no link")
            time.sleep(0.2)
    s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    s.settimeout(0.05)
    s.sendall(bytes([ord("H"), 1, 1 | 2 | 4]))
    lg = open(log, "w")
    frames, seq, last_tx = 0, 0, -1.0
    fb = bytearray(1024)
    for x in range(128):
        for y in range(64):
            if x in (0, 127) or y in (0, 63) or (x // 4 + y // 4) & 1:
                fb[(7 - y // 8) + 8 * x] |= 1 << (y % 8)
    emu = lambda: frames / 48000   # noqa: E731

    def midi(m):
        nonlocal last_tx
        s.sendall(b"M" + struct.pack("<H", len(m)) + m)
        last_tx = emu()

    def ev(**kw):
        kw["t"] = round(emu(), 4)
        lg.write(json.dumps(kw) + "\n")
        lg.flush()
    buf, rm = b"", b""
    todo = sorted(json.load(open(sends))) if sends else []   # 1036: (s, hex) host messages at emulated times
    while time.time() - t0 < secs:
        while todo and frames and emu() >= todo[0][0]:
            midi(bytes.fromhex(todo.pop(0)[1]))
            ev(ev="sent")
        if stop_at is not None and emu() >= stop_at:
            ev(ev="stop")
            break
        try:
            d = s.recv(65536)
            if not d:
                break
            buf += d
        except socket.timeout:
            pass
        while buf:
            k = buf[0:1]
            if k == b"N" and len(buf) >= 5:
                n = struct.unpack("<I", buf[1:5])[0]
                buf = buf[5:]
                s.sendall(b"a" + struct.pack("<I", n) + bytes(16 * n))
                frames += n
            elif k == b"H" and len(buf) >= 3:
                buf = buf[3:]
            elif k == b"M" and len(buf) >= 3 and len(buf) >= 3 + struct.unpack("<H", buf[1:3])[0]:
                n = struct.unpack("<H", buf[1:3])[0]
                rm += buf[3:3 + n]
                buf = buf[3 + n:]
            elif k == b"T" and len(buf) >= 4:
                buf = buf[4:]
            elif k == b"P" and len(buf) >= 10:
                buf = buf[10:]
            elif k == b"R" and len(buf) >= 5 and len(buf) >= 5 + 48 * struct.unpack("<I", buf[1:5])[0]:
                buf = buf[5 + 48 * struct.unpack("<I", buf[1:5])[0]:]
            elif k in (b"N", b"H", b"M", b"T", b"P", b"R"):
                break
            else:
                sys.exit(f"bad message {buf[:8]!r}")
        while b"\xf0" in rm and b"\xf7" in rm[rm.index(b"\xf0"):]:
            i = rm.index(b"\xf0")
            j = rm.index(b"\xf7", i)
            m, rm = rm[i:j + 1], rm[j + 1:]
            if m[:4] != b"\xf0\x7d\x52\x54" or len(m) < 7:
                continue
            c = m[4]
            if c == 0x29 and len(m) == 9:
                ev(ev="v29", track=m[6], on=m[7])
                if m[7] and answer:
                    seq = (seq + 1) & 0x7F
                    midi(P.rui_rect(seq, 0, 0, 16, 8, fb) + P.rui_commit(seq))
                    ev(ev="commit", seq=seq)
            elif c == 0x2A and len(m) >= 10:
                n = m[8]
                vals = [(m[9 + 2 * i] << 7) | m[10 + 2 * i] for i in range(n)]
                ev(ev="v2a", track=m[6], first=m[7], n=n, vals=vals, ok=len(m) == 10 + 2 * n)
            elif c == 0x2B and len(m) == 15:
                vt = m[8] << 28 | m[9] << 21 | m[10] << 14 | m[11] << 7 | m[12]
                ev(ev="v2b", state=m[6], views=m[7], vt=f"{vt:08x}", age=m[13])
            elif c == 0x30 and len(m) >= 10:
                ev(ev="mode", page=m[6], on=m[7], reason=m[8])
            elif c == 0x35:
                ev(ev="hello")
            elif c == 0x31 and len(m) == 10:
                ev(ev="key", code=m[6] << 7 | m[7], down=m[8])
            elif c == 0x48 and len(m) == 10:
                ev(ev="w48", track=m[6], param=m[7], status=m[8])
        if frames and emu() - last_tx >= 0.25:
            midi(P.rui_keepalive())
    open(frame, "wb").write(bytes(fb))
    s.close()


# ---- the runs ------------------------------------------------------------------------------------------------------
class Emu:
    def __init__(self, tag):
        self.tag = tag
        self.fw = f"fw/AR173_us_{tag}.syx"
        self.card = f"sections/us_{tag}.img"
        self.base = (f"sections/us_{tag}.snap", json.load(open(os.path.join(EMU, f"sections/us_{tag}.json")))["clock"])
        self.out = os.path.join(os.environ.get("RYTM_OUT_ROOT") or os.path.join(ROOT, "build", "emu"), tag)
        os.makedirs(self.out, exist_ok=True)
        self.syms = json.load(open(os.path.join(self.out, "manifest.json")))["elek"]["symbols"]

    def sym(self, n):
        return self.syms["rytm-0026-remote-ui:" + n]

    def run(self, name, ms, events=(), host=True, answer=True, stop_at=None, snap=None, sends=()):
        """events: (ms, 'press', KEY[, hold ms]) / (ms, 'turn', 'ENC:DELTA', count, spacing ms); snap: (path, clock M)."""
        snap = snap or self.base
        at = lambda t: f"{snap[1] + t / 5:g}M"   # noqa: E731
        s = socket.socket()
        s.bind(("127.0.0.1", 0))
        port = s.getsockname()[1]
        s.close()
        save = os.path.join(self.out, f"sv_{name}.snap")
        cmd = [os.path.join(EMU, "target/release/dtboot"), self.fw, "--load", snap[0], "--card", self.card,
               "--instr", f"{ms // 5}M", "--every", "100M", "--usb-host", "--usb-midi-real",
               "--ob-link", f"127.0.0.1:{port}", "--save", save]
        for e in events:
            if e[1] == "press":
                cmd += ["--press", f"{e[2]}@{at(e[0])}" + (f":{e[3] // 5}M" if len(e) > 3 else "")]
            else:
                cmd += ["--turn", f"{e[2]}@{at(e[0])}x{e[3]}/{e[4] // 5}M"]
        log = os.path.join(self.out, f"sv_{name}.jsonl")
        frame = os.path.join(self.out, f"sv_{name}.frame")
        for f in (log, frame):
            if os.path.exists(f):
                os.remove(f)
        hp = None
        sf = os.path.join(self.out, f"sv_{name}.sends.json")
        json.dump([(t / 1000.0, m.hex()) for t, m in sends], open(sf, "w"))
        if host:
            hp = subprocess.Popen([sys.executable, os.path.abspath(__file__), "--host", f"127.0.0.1:{port}", log, frame,
                                   "1" if answer else "0", "" if stop_at is None else str(stop_at), sf],
                                  stdout=subprocess.DEVNULL, stderr=open(log + ".err", "w"))
        r = subprocess.run(cmd, cwd=EMU, env=dict(os.environ, DTEMU_STRICT="1", DTBOOT_OLED="1",
                                                  DTBOOT_END_PNG=os.path.join(self.out, f"sv_{name}.png")),
                           capture_output=True, text=True)
        if hp:
            try:
                hp.wait(timeout=30)
            except subprocess.TimeoutExpired:
                hp.kill()
        out = r.stdout + r.stderr
        open(os.path.join(self.out, f"sv_{name}.dt.txt"), "w").write(out)
        bad = r.returncode != 0 or "FAULT" in out or "strict:" in out
        check(f"{name}: dtboot ran clean (strict, no fault)", not bad,
              "" if not bad else str(re.findall(r".*(?:FAULT|strict:).*", out)[:3] or f"rc {r.returncode}"))
        from rui_emu import oled
        res = dict(snap=(save, snap[1] + ms // 5), oled=oled(out), events=[])
        if os.path.exists(log):
            res["events"] = [json.loads(x) for x in open(log)]
        res["frame"] = open(frame, "rb").read() if os.path.exists(frame) else None
        return res

    def peek(self, snap, addr, n):
        r = subprocess.run([os.path.join(EMU, "target/release/dtpeek"), os.path.abspath(snap), "mem", f"{addr:x}",
                            str(n)], cwd=EMU, env=dict(os.environ, DTEMU_FW=self.fw), capture_output=True, text=True)
        b = bytearray()
        for line in r.stdout.splitlines():
            m = re.match(r"^[0-9a-f]+: ((?:[0-9a-f]{2} ?)+)", line)
            if m:
                b += bytes.fromhex(m.group(1).replace(" ", ""))
        return bytes(b[:n])

    def sv(self, snap):
        b = self.peek(snap, self.sym("sv"), 12)
        return dict(on=b[0], track=b[1], mach=b[2], covered=b[3], show=b[8])

    def kword(self, snap, t, w):
        kit = int.from_bytes(self.peek(snap, 0x800067b8, 4), "big") & 127
        return self.peek(snap, 0x41255933 + 2531 * kit + 152 * t + 2 * w, 2)


def evs(r, kind):
    return [x for x in r["events"] if x["ev"] == kind]


def diff(a, b):
    return sum(x != y for x, y in zip(a or b"", b or b"")) if a and b else "missing"


J = None   # the JUNO snapshot (made by t_juno, used by the rest)


def juno(e):
    global J
    if J is None:
        keys = UI["list_open"] + ["DOWN"] * UI["downs"]["juno"] + [UI["list_confirm"]]
        ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)]
        e.jlast = 500 + 500 * (len(keys) - 1)
        e.jr = e.run("juno", e.jlast + 1500, ev)
        J = e.jr["snap"]
    return J


def t_juno(e):
    """BD set to JUNO on its SRC list (YES): 29 0 1, the 16 values (2A 0 0 16), the host's frame on the glass."""
    juno(e)
    r = e.jr
    v29 = [(x["track"], x["on"]) for x in evs(r, "v29")]
    a = evs(r, "v2a")
    print(f"  29s: {v29}; 2As: {[(x['first'], x['n']) for x in a]}")
    check("juno: the last 29 is BD's view on (29 0 1)", bool(v29) and v29[-1] == (0, 1), v29[-3:])
    last29 = max(i for i, x in enumerate(r["events"]) if x["ev"] == "v29")
    after = [x for x in r["events"][last29:] if x["ev"] == "v2a"]
    check("juno: all 16 values (2A 0 0 16) after it, well formed", bool(after) and after[0]["first"] == 0 and
          after[0]["n"] == 16 and after[0]["ok"] and after[0]["track"] == 0, after[:1])
    kw = [e.kword(J[0], 0, w) for w in range(16)]
    want = [((b[0] & 0x7f) << 7) | (b[1] >> 1) for b in kw]
    check("juno: the values are the kit words (P1..P16 = the sound's knob words 0..15)",
          bool(after) and after[-1]["vals"] == want if after and after[-1]["n"] == 16 else False,
          (after[-1]["vals"] if after else None, want))
    s = e.sv(J[0])
    check("juno: the view is on for BD and shows the host's frame", s["on"] == 1 and s["track"] == 0 and s["show"] == 1, s)
    check("juno: the panel shows the host's frame byte for byte", r["oled"] == r["frame"], diff(r["oled"], r["frame"]))
    b = evs(r, "v2b")
    print(f"  2Bs: {[(hex(x['state']), x['views'], x['vt']) for x in b[-4:]]} ({len(b)})")
    check("juno: 1027d's 2B: the last says on, committed, shown (bits 0, 2, 6), top view SamplerLedView, 9 views",
          bool(b) and b[-1]["state"] == 0x45 and b[-1]["vt"] == "40234cfc" and b[-1]["views"] == 9, b[-1:] if b else None)


def t_knob(e):
    """Knob B (CUT) turned on the shown view: a stock edit (kit word 1 moves), 2A 0 1 1 with the new value, the frame
    stays on the glass."""
    juno(e)
    before = e.kword(J[0], 0, 1)
    r = e.run("knob", 1500, [(300, "turn", "1:+8", 6, 50)], snap=J)
    after = e.kword(r["snap"][0], 0, 1)
    a = evs(r, "v2a")
    print(f"  word 1: {before.hex()} -> {after.hex()}; 2As {[(x['first'], x['n'], x['vals']) for x in a]}")
    check("knob: the kit word changed (the stock page edited it)", before != after)
    want = ((after[0] & 0x7f) << 7) | (after[1] >> 1)
    check("knob: 2A 0 1 1 reports P2 changing, its last value the kit word's", bool(a) and
          all(x["first"] == 1 and x["n"] == 1 for x in a) and a[-1]["vals"] == [want], [(x["first"], x["n"]) for x in a])
    check("knob: the host's frame stays on the glass", r["oled"] == r["frame"] and e.sv(r["snap"][0])["show"] == 1,
          diff(r["oled"], r["frame"]))


def t_list(e):
    """SRC SRC (the machine list) on the shown view: stock's list on the glass (as with no host), no 29 0; NO closes
    it and the frame is back."""
    juno(e)
    ev = [(300, "press", "SRC"), (800, "press", "SRC")]
    r = e.run("list", 1500, ev, snap=J)
    ref = e.run("list-ref", 1500, ev, host=False, snap=J)
    s = e.sv(r["snap"][0])
    check("list: the machine list open: the stock screen exactly as without a host", r["oled"] == ref["oled"] and
          ref["oled"] != r["frame"], diff(r["oled"], ref["oled"]))
    b = evs(r, "v2b")
    check("list: a 2B names the machine list on top (MachineListView 401e5bf4, covered: bit 1)",
          any(x["vt"] == "401e5bf4" and x["state"] & 2 for x in b), b[-3:])
    check("list: the view stays on (covered), no 29 0", s["on"] == 1 and s["covered"] == 1 and
          not [x for x in evs(r, "v29") if not x["on"]], (s, evs(r, "v29")))
    r = e.run("listno", 2000, ev + [(1500, "press", "NO")], snap=J)
    check("list: NO closes it: the host's frame again", r["oled"] == r["frame"], diff(r["oled"], r["frame"]))


def t_leave(e):
    """FLTR leaves the SRC page: 29 0 0, the stock FLTR page exactly as on a Rytm without the view; SRC again: 29 0 1
    and the host's frame."""
    juno(e)
    ev = [(300, "press", "FLTR")]
    r = e.run("leave", 1200, ev, snap=J)
    ref = e.run("leave-ref", 1200, ev, host=False, snap=J)
    v29 = [(x["track"], x["on"]) for x in evs(r, "v29")]
    check("leave: 29 0 0", v29 == [(0, 0)], v29)
    check("leave: the stock screen equals a Rytm without the view", r["oled"] == ref["oled"], diff(r["oled"], ref["oled"]))
    r = e.run("back", 2000, ev + [(1200, "press", "SRC")], snap=J)
    v29 = [(x["track"], x["on"]) for x in evs(r, "v29")]
    check("leave: SRC again: 29 0 1 and the host's frame", v29 == [(0, 0), (0, 1)] and r["oled"] == r["frame"],
          (v29, diff(r["oled"], r["frame"])))


def t_gone(e):
    """The host stops: 1 s later the stock SRC page; an old host (keepalives, never a frame) leaves stock throughout."""
    juno(e)
    r = e.run("gone", 2500, [], stop_at=0.3, snap=J)
    ref = e.run("gone-ref", 2500, [], host=False, snap=J)
    check("gone: the stock SRC page back after the host stopped", r["oled"] == ref["oled"] and ref["oled"] != r["frame"],
          diff(r["oled"], ref["oled"]))
    keys = UI["list_open"] + ["DOWN"] * UI["downs"]["juno"] + [UI["list_confirm"]]
    ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)]
    last = 500 + 500 * (len(keys) - 1)
    r = e.run("old", last + 1500, ev, answer=False)
    ref = e.run("old-ref", last + 1500, ev, host=False)
    check("gone: an old host (no frame): 29 0 1 sent, the stock SRC page shown, as without a host",
          (0, 1) in [(x["track"], x["on"]) for x in evs(r, "v29")] and r["oled"] == ref["oled"],
          diff(r["oled"], ref["oled"]))


def t_trk(e):
    """TRK + YES on the shown view opens the remote page (30 on; it takes precedence: nothing committed for it yet, a
    blank page); TRK + YES again: back to the stock SRC page (the host has not committed since), as without a host."""
    juno(e)
    ev = [(300, "press", "TRK", 200), (400, "press", "YES"), (800, "press", "TRK", 200), (900, "press", "YES")]   # inside the 1 s timeout
    r = e.run("trk", 2200, ev[:2], snap=J)
    m = [(x["on"], x["reason"]) for x in evs(r, "mode")]
    check("trk: TRK + YES opens the page (30 on) over the view: a blank page", m == [(1, 0)] and
          r["oled"] == bytes(1024), (m, diff(r["oled"], bytes(1024))))
    r = e.run("trk2", 2200, ev, snap=J)
    ref = e.run("trk2-ref", 2200, ev, host=False, snap=J)
    m = [(x["on"], x["reason"]) for x in evs(r, "mode")]
    check("trk: TRK + YES again leaves (30 off): the stock SRC page, no frame until the host commits again",
          m == [(1, 0), (0, 3)] and r["oled"] == ref["oled"] and e.sv(r["snap"][0])["show"] == 0,
          (m, diff(r["oled"], ref["oled"])))


def t_dsp(e):
    """BD set to DSP SAMPLE (its SMPL page holds the sample knobs): the 2A after its 29 0 1 carries P9..P16 = the
    sound's knob words 8..15 (1027c: not words 17..24)."""
    keys = UI["list_open"] + ["DOWN"] * 24 + [UI["list_confirm"]]
    ev = [(500 + 500 * i, "press", k) for i, k in enumerate(keys)]
    r = e.run("dsp", 500 + 500 * (len(keys) - 1) + 1500, ev)
    a = evs(r, "v2a")
    kw = [e.kword(r["snap"][0], 0, w) for w in range(16)]
    want = [((b[0] & 0x7f) << 7) | (b[1] >> 1) for b in kw]
    s = e.sv(r["snap"][0])
    print(f"  machine {s['mach']}; last 2A {a[-1]['vals'] if a else None}; words {[v >> 7 for v in want]}")
    check("dsp: BD is DSP SAMPLE (45) and its last 2A (all 16) equals the knob words 0..15", s["mach"] == 45 and
          bool(a) and a[-1]["n"] == 16 and a[-1]["vals"] == want, (a[-1] if a else None, want))
    # ENG (knob A) is a 3-zone list knob (0029 steps it; the page's value is the step): turned, the 2A carries the
    # stored value (the zone's lowest, as the word settles to), not the step index
    r2 = e.run("dsp-eng", 2500, [(300, "turn", "0:+8", 6, 50)], snap=r["snap"])
    a = [x for x in evs(r2, "v2a") if x["first"] == 0 and x["n"] == 1]
    w = e.kword(r2["snap"][0], 0, 0)
    print(f"  ENG 2As {[x['vals'][0] >> 7 for x in a]}; word {w.hex()}")
    check("dsp: ENG turned: 2A 0 0 1 with the stored value, the last one the settled kit word",
          bool(a) and a[-1]["vals"][0] == ((w[0] & 0x7f) << 7 | w[1] >> 1) and w[0] != 80, (a, w.hex()))


def sx(cmd, *body):
    return bytes([0xF0, 0x7D, 0x52, 0x54, cmd, 0x01, *body, 0xF7])


def names47(lst, replace, total, first, names):
    body = [lst, replace, total]
    for i, n in enumerate(names):
        body += [first + i] + list(n.encode()[:13].ljust(13, b"\0"))
    return sx(0x47, *body)


G = None   # the GRANULAR snapshot (BD on GRANULAR, the stock SRC page: no frame from the host)


def gran(e):
    global G
    if G is None:
        keys = UI["list_open"] + ["DOWN"] * 26 + [UI["list_confirm"]]
        ev = [(500 + 300 * i, "press", k) for i, k in enumerate(keys)]
        r = e.run("gran", 500 + 300 * len(keys) + 1500, ev, answer=False)
        G = r["snap"]
    return G


def t_padmode(e):
    """1041: in each pad mode (MUTE, CHRO, SCNE, PERF; PLAY as the control) the SRC view is on the glass 0.6 s after
    SRC, as in PLAY mode (rui1040: 3 s late in MUTE / CHRO / SCNE, never in PERF: the mode's own view stacked on top,
    1027d's unknown / cover rule). The stock SRC page in each mode is the PLAY mode's (the mode's view draws nothing
    over it), so taking them as transparent hides nothing."""
    juno(e)
    pre = [(300, "press", "FLTR")]
    base = e.run("pm-ref-none", 1600, pre + [(1000, "press", "SRC")], host=False, snap=J)["oled"]
    for mode in (None, "MUTE", "CHRO", "SCNE", "PERF"):
        ev = pre + ([(600, "press", mode)] if mode else []) + [(1000, "press", "SRC")]
        r = e.run(f"pm-{mode or 'play'}", 1600, ev, snap=J)
        ref = e.run(f"pm-ref-{mode or 'play'}", 1600, ev, host=False, snap=J)
        b = evs(r, "v2b")
        print(f"  {mode or 'PLAY'}: 2Bs {[(hex(x['state']), x['views'], x['vt']) for x in b[-3:]]}")
        check(f"padmode {mode or 'PLAY'}: the host's frame on the glass 0.6 s after SRC", r["oled"] == r["frame"],
              diff(r["oled"], r["frame"]))
        check(f"padmode {mode or 'PLAY'}: the stock SRC page (no host) is the PLAY mode's", ref["oled"] == base,
              diff(ref["oled"], base))
        check(f"padmode {mode or 'PLAY'}: the last 2B: on, committed, shown (0x45), top SamplerLedView",
              bool(b) and b[-1]["state"] == 0x45 and b[-1]["vt"] == "40234cfc", b[-1:])
    r = e.run("pm-perf-trk", 1600, pre + [(600, "press", "PERF"), (1000, "press", "SRC"), (1300, "press", "TRK", 600)],
              snap=J)
    s = e.sv(r["snap"][0])
    check("padmode PERF: TRK held over it still covers (TrackSelectionView after the mode's view)", s["covered"] == 1, s)


def t_level(e):
    """1041: LEVEL turned on the shown SRC view: 0.3 s after, the header's left field (rows 0..8, columns 0..69) is
    stock's "TRK LEVEL" readout (not the host's frame there), the rest of the glass the host's frame; 3 s after, the
    whole frame again."""
    juno(e)
    r = e.run("level", 600, [(300, "turn", "8:+3", 3, 20)], snap=J)
    late = e.run("level-late", 3600, [(300, "turn", "8:+3", 3, 20)], snap=J)
    o, f = r["oled"] or b"", r["frame"] or b""
    def bits(fb, x, y):   # the host frame / the panel's bytes: byte 8 x + 7 - (y >> 3), bit y & 7
        return fb[8 * x + 7 - (y >> 3)] >> (y & 7) & 1
    inf = [(x, y) for x in range(70) for y in range(9)]
    outside = [(x, y) for x in range(128) for y in range(64) if (x, y) not in set(inf)]
    check("level: the field is not the host's frame (stock's readout drawn there)",
          bool(o) and bool(f) and any(bits(o, x, y) != bits(f, x, y) for x, y in inf))
    check("level: the rest of the glass is the host's frame", bool(o) and all(bits(o, x, y) == bits(f, x, y) for x, y in outside))
    check("level: 3 s later the whole frame again", late["oled"] == late["frame"], diff(late["oled"], late["frame"]))


def t_push(e):
    """1036: the SRC view of a Sidecar track (BD on JUNO): PUSH_A and PUSH_C pressed and released reach the host (31
    0x70 / 0x72 down, up) and stock still has them (the stock SRC page as the same run without the host's frame: the
    view's screen equals the push-less run's)."""
    juno(e)
    a = e.run("push0", 1500, [], snap=J)
    r = e.run("push", 1500, [(300, "press", "PUSH_A", 200), (800, "press", "PUSH_C", 100)], snap=J)
    k = [(x["code"], x["down"]) for x in evs(r, "key")]
    print(f"  keys {k}")
    check("push: 31 PUSH_A down / up, PUSH_C down / up (the SRC view reports its pushes)",
          k == [(0x70, 1), (0x70, 0), (0x72, 1), (0x72, 0)], k)
    check("push: nothing caught (the view's frame and the sound as without the pushes)", r["oled"] == a["oled"] and
          e.kword(r["snap"][0], 0, 0) == e.kword(a["snap"][0], 0, 0))
    r2 = e.run("push_off", 1200, [(300, "press", "FLTR"), (700, "press", "PUSH_A")], snap=J)
    check("push: on another page (FLTR) a push is stock's alone (no 31)", not evs(r2, "key"), evs(r2, "key"))


def t_names(e):
    """1036: BD on GRANULAR, the stock SRC page (the host draws nothing): 47 list 0 (GRANULAR SRC) with 4 names (rows 8..11
    since 1043: a row's own name, no min(value, total - 1)); the SRC knob's value text is row 11's name (turned: the
    screen differs from the run without the list, A011: PNGs sv_names0 / sv_names); 48 0 0 2 (BD P1 = 2): kit word 0 =
    0x0200, answered 48 1 0 0 0, the view's 2A follows; 48 for a param SD's analog machine lacks: status 2; 47 malformed:
    refused, the names kept."""
    gran(e)
    nm = names47(0, 1, 12, 8, ["PADS", "VOX CHOIR", "BELLS LONG NAME", "DRONE"])
    turn = [(1000, "turn", "0:+1", 1, 50)]   # SRC turned by one: the page shows its value text (11: DRONE / A011)
    a = e.run("names0", 1300, turn, snap=G, answer=False)
    r = e.run("names", 1300, turn, snap=G, answer=False, sends=[(300, nm)])
    print(f"  word 0 {e.kword(r['snap'][0], 0, 0).hex()}")
    check("names: the SRC value text changed with the host's list (the screens differ)", r["oled"] != a["oled"])
    nb = e.peek(r["snap"][0], e.sym("ux") + 36, 4)
    check("names: the list's total 12 kept", nb[0] == 12, nb.hex())
    w = e.run("write", 2000, [], snap=G, answer=False,
              sends=[(300, nm), (500, sx(0x48, 0, 0, 2)), (900, sx(0x48, 1, 15, 5)), (1200, sx(0x47, 0, 1))])
    ws = [(x["track"], x["param"], x["status"]) for x in evs(w, "w48")]
    print(f"  48 replies {ws}; word 0 {e.kword(w['snap'][0], 0, 0).hex()}")
    check("names: 48 0 0 2 -> BD's kit word 0 = 0x0200 (as a knob turn: SRC on PADS..DRONE's BELLS)",
          e.kword(w["snap"][0], 0, 0)[:1] == b"\x02", e.kword(w["snap"][0], 0, 0).hex())
    check("names: answered 48 1 0 0 0 (written)", ws[:1] == [(0, 0, 0)], ws)
    a2 = [x for x in evs(w, "v2a") if x["track"] == 0 and x["first"] == 0]
    check("names: the view's 2A reports P1 = 2", bool(a2) and a2[-1]["vals"][0] >> 7 == 2, a2[-1:])
    check("names: a short 47 refused, the names kept",
          e.peek(w["snap"][0], e.sym("ux") + 36, 1)[0] == 12)


TESTS = dict(level=t_level, padmode=t_padmode, dsp=t_dsp, juno=t_juno, knob=t_knob, list=t_list, leave=t_leave, gone=t_gone, trk=t_trk, push=t_push,
             names=t_names)


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--host":
        link, log, frame, ans, stop = sys.argv[2:7]
        host(link, log, frame, ans == "1", float(stop) if stop else None, sends=sys.argv[7] if len(sys.argv) > 7 else None)
        return
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    e = Emu(sys.argv[1])
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    for n in names:
        print(f"== {n}", flush=True)
        TESTS[n](e)
    print("ALL PASS" if not FAILS else f"FAILED: {FAILS}")
    sys.exit(1 if FAILS else 0)


if __name__ == "__main__":
    main()
