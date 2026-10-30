#!/usr/bin/env python3
"""Emulator tests of 0026's source banks (1038): GRANULAR SRC / WAVETABLE TBL / MULTISAMPLE INST as one 14-bit word
(index 0..127 in the integer byte, bank A..H in the fraction's top 3 bits: index << 8 | bank << 5), the Sidecar's
bank list opened by turning the knob, the 47 names with a bank byte, the 48 lock variant, UP + T6..T10; 1043:
bank A's text like B..H's (banka), WAVETABLE's default TBL 1 (tbldef).

    .venv/bin/python tools/emu/bk_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a rui build with its base from tools/emu/us_base.sh TAG (BD PLASTIC on BD, the SRC page showing). Every run under
DTEMU_STRICT=1 with --usb-host --usb-midi-real --ob-link; the host is sv_emu.py's scripted host (--host mode: 3C every
250 ms, the 48 / 49 / 4A replies logged, its sends at emulated times) extended here with the 4A list reports. Times are
ms after the snapshot (200 M instructions = 1 s). RYTM_EMU, RYTM_TEENSY: the checkouts.
"""
import json
import os
import re
import socket
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sv_emu as S   # noqa: E402
import struct   # noqa: E402
import time   # noqa: E402

EMU, ROOT, UI = S.EMU, S.ROOT, S.UI
check, evs, sx = S.check, S.evs, S.sx
LIVE_LOCKS_BD = 0x407e0774        # pc_emu.py: live locks +5674 t + 88 step + 2 k [measured]
ST_PAT = 0x405c8f38               # pc_emu.py: bank pattern i's stored copy at + 13101 (i + 1), +0x2091 the lock slots
DIALOGS = ["YES@2600M", "NO@3000M", "NO@3400M", "NO@3800M"]   # us_base.sh's cold-boot answers
B_REC_P1 = 0x401bf918 + 0x34 * 398          # the shared SRC record P1 (398): +0x0c max, +0x14 the fine flag
REC_FINE = B_REC_P1 + 0x14
DOWNS = dict(wt=25, gr=26, ms=30, ds=24)   # us_ui.json: DSP SAMPLE 24, WAVETABLE 25, GRANULAR 26, (1051: LIVE IN 27, CHOP 28,) DAISYSP 29, MULTISAMP last
MACH = dict(wt=46, gr=47, ms=52, ds=45)


class Emu(S.Emu):
    def run(self, name, ms, events=(), host=True, answer=False, stop_at=None, snap=None, sends=(), extra=(),
            cold_card=None, midi_out=False):
        """sv_emu's run, plus extra dtboot arguments, a cold boot on a card (the dialogs answered) and DIN MIDI out."""
        snap = snap or self.base
        start = 0 if cold_card else snap[1]
        at = lambda t: f"{start + t / 5:g}M"   # noqa: E731
        s = socket.socket()
        s.bind(("127.0.0.1", 0))
        port = s.getsockname()[1]
        s.close()
        save = os.path.join(self.out, f"bk_{name}.snap")
        cmd = [os.path.join(EMU, "target/release/dtboot"), self.fw]
        cmd += ["--card", cold_card] if cold_card else ["--load", snap[0], "--card", self.card]
        cmd += ["--instr", f"{ms // 5}M", "--every", "100M", "--save", save]
        if host:
            cmd += ["--usb-host", "--usb-midi-real", "--ob-link", f"127.0.0.1:{port}"]
        if cold_card:
            for p in DIALOGS:
                cmd += ["--press", p]
        mo = os.path.join(self.out, f"bk_{name}.midi")
        if midi_out:
            cmd += ["--midi-out", mo]
        for e in events:
            if e[1] == "press":
                cmd += ["--press", f"{e[2]}@{at(e[0])}" + (f":{e[3] // 5}M" if len(e) > 3 else "")]
            else:
                cmd += ["--turn", f"{e[2]}@{at(e[0])}x{e[3]}/{e[4] // 5}M"]
        cmd += list(extra)
        log = os.path.join(self.out, f"bk_{name}.jsonl")
        frame = os.path.join(self.out, f"bk_{name}.frame")
        uo = os.path.join(self.out, f"bk_{name}.usb")
        for f in (log, frame, uo, mo):
            if os.path.exists(f):
                os.remove(f)
        hp = None
        sf = os.path.join(self.out, f"bk_{name}.sends.json")
        json.dump([(t / 1000.0, m.hex()) for t, m in sends], open(sf, "w"))
        if host:
            hp = subprocess.Popen([sys.executable, os.path.abspath(__file__), "--host", f"127.0.0.1:{port}", log, frame,
                                   "1" if answer else "0", "" if stop_at is None else str(stop_at), sf],
                                  stdout=subprocess.DEVNULL, stderr=open(log + ".err", "w"))
        r = subprocess.run(cmd, cwd=EMU, env=dict(os.environ, DTEMU_STRICT="1", DTBOOT_OLED="1", DTBOOT_USB_OUT=uo,
                                                  DTBOOT_END_PNG=os.path.join(self.out, f"bk_{name}.png")),
                           capture_output=True, text=True)
        if hp:
            try:
                hp.wait(timeout=30)
            except subprocess.TimeoutExpired:
                hp.kill()
        out = r.stdout + r.stderr
        open(os.path.join(self.out, f"bk_{name}.dt.txt"), "w").write(" ".join(cmd) + "\n" + out)
        bad = r.returncode != 0 or "FAULT" in out or "strict:" in out
        check(f"{name}: dtboot ran clean (strict, no fault)", not bad,
              "" if not bad else str(re.findall(r".*(?:FAULT|strict:).*", out)[:3] or f"rc {r.returncode}"))
        from rui_emu import oled
        res = dict(snap=(save, start + ms // 5), oled=oled(out), events=[], out=out)
        if os.path.exists(log):
            res["events"] = [json.loads(x) for x in open(log)]
        res["frame"] = open(frame, "rb").read() if os.path.exists(frame) else None
        res["midi"] = open(mo, "rb").read() if os.path.exists(mo) else b""
        res["usb"] = open(uo, "rb").read() if os.path.exists(uo) else b""
        return res

    def pokes(self, snap, edits):
        """--poke arguments (32-bit words) writing edits {addr: bytes} over the snapshot's memory (pc_emu.py's)."""
        mem = {}
        for a, d in edits.items():
            for i, b in enumerate(d):
                mem[a + i] = b
        out = []
        for w in sorted({a & ~3 for a in mem}):
            cur = bytearray(self.peek(snap, w, 4))
            for i in range(4):
                if w + i in mem:
                    cur[i] = mem[w + i]
            out += ["--poke", f"{w:x}={cur.hex()}"]
        return out

    def word0(self, snap, t=0):
        return int.from_bytes(self.kword(snap, t, 0), "big")

    def live_lock(self, snap, step, k=9, t=0):
        return int.from_bytes(self.peek(snap, LIVE_LOCKS_BD + 5674 * t + 88 * step + 2 * k, 2), "big")

    def stored_slots(self, snap, pat=0):
        """bank pattern pat's 72 stored lock slots (type, track, 64 values)."""
        L = self.peek(snap, ST_PAT + 13101 * (pat + 1) + 0x2091, 72 * 66)
        return [(L[66 * j], L[66 * j + 1], L[66 * j + 2:66 * j + 66]) for j in range(72)]


# ---- the host (sv_emu.py's, plus 4A / 32 / 49 logged) ----------------------------------------------------
def host(link, log, frame, answer, stop_at, secs=900, sends=None):
    import protocol as P  # noqa: F811
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
            elif c == 0x4A and len(m) == 12:
                ev(ev="ls", track=m[6], on=m[7], v=m[8] << 7 | m[9], why=m[10])
            elif c == 0x32 and len(m) == 10:
                ev(ev="enc", enc=m[6], delta=m[7] - 64, func=m[8])
            elif c == 0x49 and len(m) >= 9:
                ev(ev="d49", kind=m[6], body=list(m[7:-1]))
            elif c == 0x2D and len(m) >= 8:
                ev(ev="s2d", kind=m[6], body=list(m[7:-1]))
        if frames and emu() - last_tx >= 0.25:
            midi(P.rui_keepalive())
    open(frame, "wb").write(bytes(fb))
    s.close()



SNAPS = {}


def machine(e, key, drawn=False):
    """BD on WAVETABLE / GRANULAR / MULTISAMPLE from the base, the stock SRC page; drawn: the host answered the view's
    29 with a frame (the view shows the host's frame: the list can open), else no frame (the stock page)."""
    if (key, drawn) not in SNAPS:
        keys = UI["list_open"] + ["DOWN"] * DOWNS[key] + [UI["list_confirm"]]
        ev = [(500 + 300 * i, "press", k) for i, k in enumerate(keys)]
        r = e.run(key + ("-drawn" if drawn else ""), 500 + 300 * len(keys) + 1500, ev, answer=drawn)
        m = e.peek(r["snap"][0], 0x8000EA00, 1)[0]
        check(f"{key}: BD's machine is {MACH[key]}", m == MACH[key], m)
        SNAPS[(key, drawn)] = r["snap"]
    return SNAPS[(key, drawn)]


def w48(v, bank, *extra):
    """48 0 0 <index> <bank << 4> [flags]: BD's P1 = index << 8 | bank << 5."""
    return sx(0x48, 0, 0, v, bank << 4, *extra)


def word(v, bank):
    return v << 8 | bank << 5


def t_knob(e):
    """Check 1 [stock], and the banked knob: the word index 5 bank F (0x05a0) written by 48; knob A turned up / down
    (no frame from the host: no list, the stock page's knob) steps the index and keeps the bank, on all three machines
    (0029 mode 3 + bit 11); the 2A reports the 14 bits."""
    for key in ("gr", "wt", "ms"):
        sn = machine(e, key)
        r = e.run(f"knob-{key}-set", 1500, snap=sn, sends=[(300, w48(5, 5))])
        check(f"knob {key}: 48 0 0 5 <F> -> word 0x05a0, answered 0", e.word0(r["snap"][0]) == 0x05a0 and
              [x["status"] for x in evs(r, "w48")] == [0], (hex(e.word0(r["snap"][0])), evs(r, "w48")))
        for d, want in (("+8", 0x06a0), ("-8", 0x04a0)):
            r = e.run(f"knob-{key}{d}", 3500, [(1000, "turn", f"0:{d}", 3, 100)], snap=sn, sends=[(300, w48(5, 5))])
            w = e.word0(r["snap"][0])
            a = [x["vals"][0] for x in evs(r, "v2a") if x["first"] == 0]
            print(f"  {key} {d}: word {w:#06x}, 2A P1 {[(v >> 7, v & 0x7f) for v in a][-3:]}")
            check(f"knob {key} {d}: one index a detent, the bank kept (word {want:#06x})", w == want, hex(w))
            check(f"knob {key} {d}: the last 2A carries the word's 14 bits", bool(a) and a[-1] == (want >> 8) << 7 |
                  (want & 0xff) >> 1, a[-1:])


def t_range(e):
    """Bank H index 127 (0x7fe0) passes the record's range (0x7fe0, not 0x7f00); turned up it stays, down it keeps H."""
    sn = machine(e, "gr")
    r = e.run("range", 3500, [(1000, "turn", "0:+8", 3, 100)], snap=sn, sends=[(300, w48(127, 7))])
    check("range: 48 127 <H> -> 0x7fe0 kept through a turn up", e.word0(r["snap"][0]) == 0x7fe0, hex(e.word0(r["snap"][0])))
    r = e.run("range-dn", 3500, [(1000, "turn", "0:-8", 3, 100)], snap=sn, sends=[(300, w48(127, 7))])
    check("range: down -> 0x7ee0 (bank H kept)", e.word0(r["snap"][0]) == 0x7ee0, hex(e.word0(r["snap"][0])))
    rec = e.peek(sn[0], B_REC_P1, 0x34)
    print(f"  record 398: max {rec[12:16].hex()} fine {rec[20:24].hex()}")
    check("range: record P1's max 0x7fe0 and fine flag 1", rec[12:16] == bytes.fromhex("00007fe0") and
          rec[20:24] == bytes.fromhex("00000001"), rec.hex())


def names47(lst, replace, total, bank, first, names):
    body = [lst, replace, total] + ([bank] if bank is not None else [])
    for i, n in enumerate(names):
        body += [first + i] + list(n.encode()[:13].ljust(13, b"\0"))
    return sx(0x47, *body)


def t_text(e):
    """Check 4: the page shows the name, never index.fraction: GRANULAR on SRC with the word 2 . bank F; without names the
    knob reads F002 (bt_text_none.png); with bank F's names (47 + bank byte 5) the name (bt_text_f.png); bank A's names
    (an old 47, no bank byte) do not name a bank F word; index 0 of bank F reads OFF. The three screens differ."""
    sn = machine(e, "gr")
    nmf = names47(0, 1, 4, 5, 0, ["OFF", "VOX F1", "DRONE F2", "PAD F3"])
    nma = names47(0, 1, 4, None, 0, ["IN", "MAIN", "A-TWO", "A-THREE"])
    a = e.run("text-none", 1500, snap=sn, sends=[(300, w48(2, 5))])
    f = e.run("text-f", 1500, snap=sn, sends=[(200, nmf), (300, w48(2, 5))])
    o = e.run("text-a", 1500, snap=sn, sends=[(200, nma), (300, w48(2, 5))])
    z = e.run("text-off", 1500, snap=sn, sends=[(200, nmf), (300, w48(0, 5))])
    check("text: bank F's names change the knob's text (the screen differs from no names)", f["oled"] != a["oled"])
    check("text: bank A's names leave a bank F word as without names", o["oled"] == a["oled"], S.diff(o["oled"], a["oled"]))
    check("text: index 0 of bank F differs from index 2", z["oled"] != f["oled"])
    ux = e.sym("ux")
    nb = e.peek(f["snap"][0], ux + 4 * 9 + 3 + 1 + 3 * 128 * 10 + 8 + 8 * 4 + 8 * 3 + 4, 3)
    print(f"  nm_bank {nb.hex()}")
    check("text: the Rytm holds bank F's names for list 0 (ux.nm_bank[0] = 5)", nb[0] == 5, nb.hex())


def lockrun(e, name, sn, extra=(), sends=()):
    ev = [(800, "press", "RECORD"), (1500, "press", "T1", 1600), (1800, "turn", "0:+8", 3, 100), (3600, "press", "RECORD")]
    return e.run(name, 4500, ev, snap=sn, sends=[(300, w48(5, 5))] + list(sends), extra=extra)


def t_lock(e):
    """Check 2 on this build: GRID REC, T1 held, knob A turned (no host frame: stock's lock path through 0029): BD's
    step 1 lock keeps bank F (0x?? a0); the stored copy has P1's slot followed by its fine slot (0x80 0x80); power off,
    cold boot on that card: the live lock is back at 16 bits."""
    sn = machine(e, "gr")
    r = lockrun(e, "lock", sn)
    s = r["snap"]
    lk, w = e.live_lock(s[0], 0), e.word0(s[0])
    print(f"  lock {lk:#06x}, word {w:#06x}")
    check("lock: the step's live lock is index . bank F (fraction 0xa0), the sound's word still 0x05a0",
          lk != 0xffff and lk & 0xff == 0xa0 and w == 0x05a0, (hex(lk), hex(w)))
    sl = e.stored_slots(s[0])
    ty = [j for j, (t, tr, v) in enumerate(sl) if tr == 0 and t == 0]
    ok = bool(ty) and ty[0] + 1 < 72 and sl[ty[0] + 1][0] == 0x80 and sl[ty[0] + 1][2][0] == 0x50 and \
        sl[ty[0]][2][0] == lk >> 8
    check("lock: stored: P1's slot (type 0, BD) with the index, then the fine slot (80 80) with 0x50", ok,
          [(j, t, tr, v[:2].hex()) for j, (t, tr, v) in enumerate(sl) if t != 0xff][-4:])
    card = os.path.join(e.out, "bk_lock.img")
    if os.path.exists(card):
        os.remove(card)
    subprocess.run(["cp", "-c", os.path.join(EMU, e.card), card], check=True)
    try:
        p = e.run("lock-off", 1000, snap=s, host=False, extra=["--card", card, "--power-off", f"{s[1] + 100}M"])
        check("lock: the power-off handler saved the state", "power off: handler finished" in p["out"])
        c = e.run("lock-cold", 22000, cold_card=card, host=False)
        cl = e.live_lock(c["snap"][0], 0)
        print(f"  after the cold boot: lock {cl:#06x}, word {e.word0(c['snap'][0]):#06x}")
        check("lock: after the cold boot the lock is back at 16 bits (the bank kept)", cl == lk, hex(cl))
    finally:
        os.remove(card)


def lsev(r):
    return [(x["on"], x["v"], x["why"]) for x in evs(r, "ls")]


def t_list(e):
    """The list (the host draws the SRC view: answer on): knob A's first turn opens it (4A 0 1 <P1> 0) and moves nothing;
    further turns go to the host (32 0), LEFT / DOWN as 31 down / up; YES closes it (4A 0 0 .. 1), its release unseen,
    the word still the old one; the host's 48 0 0 9 <C> 1 (no trig held) writes the kit: 0x0940, answered 0; NO closes
    with 4A why 2 and nothing written; knob B closes it (why 3) and edits stock's P2; FLTR closes it (why 4)."""
    sn = machine(e, "gr", True)
    ev = [(800, "turn", "0:+8", 1, 50), (1100, "turn", "0:+8", 3, 100), (1600, "press", "LEFT", 100),
          (1900, "press", "DOWN", 100), (2300, "press", "YES", 100)]
    r = e.run("list", 3500, ev, snap=sn, answer=True, sends=[(300, w48(5, 5)), (2700, w48(9, 2, 1))])
    ls_, k, en = lsev(r), [(x["code"], x["down"]) for x in evs(r, "key")], evs(r, "enc")
    w = e.word0(r["snap"][0])
    print(f"  4A {ls_}; keys {k}; turns {[(x['enc'], x['delta']) for x in en]}; word {w:#06x}; 48 {evs(r, 'w48')}")
    v0 = 5 << 7 | 0x50
    check("list: opened by knob A (4A on, P1 = 5 . F, why 0), closed by YES (why 1)", ls_ == [(1, v0, 0), (0, v0, 1)], ls_)
    check("list: the turns after the opening one reach the host on encoder 0", bool(en) and all(x["enc"] == 0 for x in en)
          and sum(x["delta"] for x in en) > 0, en)
    check("list: LEFT and DOWN down / up reach the host, YES never as a 31", k == [(0x40, 1), (0x40, 0), (0x42 + 1, 1),
          (0x43, 0)], k)
    check("list: the host's 48 (flags 1, no trig held) wrote the kit: 9 . C (0x0940), answered 0",
          w == 0x0940 and [x["status"] for x in evs(r, "w48")][-1:] == [0], (hex(w), evs(r, "w48")))
    r = e.run("list-no", 2500, [(800, "turn", "0:+8", 1, 50), (1100, "turn", "0:+8", 3, 100), (1600, "press", "NO")],
              snap=sn, answer=True, sends=[(300, w48(5, 5))])
    check("list: NO closes it (why 2), the word unchanged (0x05a0)", lsev(r)[-1:] == [(0, v0, 2)] and
          e.word0(r["snap"][0]) == 0x05a0, (lsev(r), hex(e.word0(r["snap"][0]))))
    b0 = e.kword(sn[0], 0, 1)
    r = e.run("list-knob", 3000, [(800, "turn", "0:+8", 1, 50), (1200, "turn", "1:+8", 6, 50)], snap=sn, answer=True,
              sends=[(300, w48(5, 5))])
    check("list: knob B closes it (why 3) and edits stock's P2", lsev(r)[-1:] == [(0, v0, 3)] and
          e.kword(r["snap"][0], 0, 1) != b0, (lsev(r), b0.hex(), e.kword(r["snap"][0], 0, 1).hex()))
    r = e.run("list-page", 2500, [(800, "turn", "0:+8", 1, 50), (1200, "press", "FLTR")], snap=sn, answer=True,
              sends=[(300, w48(5, 5))])
    check("list: FLTR closes it (why 4)", lsev(r)[-1:] == [(0, v0, 4)], lsev(r))
    r = e.run("list-nohost", 2500, [(800, "turn", "0:+8", 3, 100)], snap=machine(e, "gr"), sends=[(300, w48(5, 5))])
    check("list: no frame from the host: no list, the knob steps as stock's (0x06a0)", not lsev(r) and
          e.word0(r["snap"][0]) == 0x06a0, (lsev(r), hex(e.word0(r["snap"][0]))))


def t_browse(e):
    """1040: FUNC + YES on the open list -> 4A 0 3 <P1> 0 (the host's file browser for the row), YES's press and release
    never a 31, the list stays open; the host's 4A 0 1: YES and NO now reach the host (31 down / up), the list still open;
    the host's 4A 0 0: YES closes the list again (why 1). No answer from the host within 1 s: YES / NO are the list's
    again (why 1)."""
    sn = machine(e, "gr", True)
    v0 = 5 << 7 | 0x50
    ev = [(800, "turn", "0:+8", 1, 50), (1100, "press", "FUNC", 150), (1150, "press", "YES", 50), (1500, "press", "YES", 50),
          (1700, "press", "NO", 50), (1900, "press", "DOWN", 50), (2600, "press", "YES", 50)]
    r = e.run("browse", 3200, ev, snap=sn, answer=True, sends=[(300, w48(5, 5)), (1300, sx(0x4A, 0, 1)), (2200, sx(0x4A, 0, 0))])
    ls_, k = lsev(r), [(x["code"], x["down"]) for x in evs(r, "key")]
    print(f"  4A {ls_}; keys {k}")
    check("browse: opened, FUNC + YES -> 4A on 3 (the row's files), then closed by YES after the host's 4A 0 0 (why 1)",
          ls_ == [(1, v0, 0), (3, v0, 0), (0, v0, 1)], ls_)
    check("browse: with the host's browser open YES, NO and DOWN reach the host (31 down / up); FUNC + YES's YES never",
          k == [(0x44, 1), (0x44, 0), (0x45, 1), (0x45, 0), (0x43, 1), (0x43, 0)], k)
    check("browse: the word unchanged (0x05a0)", e.word0(r["snap"][0]) == 0x05a0, hex(e.word0(r["snap"][0])))
    r = e.run("browse-noack", 3200, [(800, "turn", "0:+8", 1, 50), (1100, "press", "FUNC", 150), (1150, "press", "YES", 50),
                                     (2500, "press", "YES", 50)], snap=sn, answer=True, sends=[(300, w48(5, 5))])
    check("browse: no host answer within 1 s: YES is the list's again (4A why 1, no 31 YES)",
          lsev(r) == [(1, v0, 0), (3, v0, 0), (0, v0, 1)] and not [x for x in evs(r, "key") if x["code"] == 0x44],
          (lsev(r), evs(r, "key")))


def t_listlock(e):
    """GRID REC, T1 and T3 held, the list opened by knob A and YES pressed while they are held: the host's 48 0 0 9 <C> 1
    locks P1 on steps 1 and 3 (answered 4: locked) at 0x0940 (fine), the kit word stays 0x05a0."""
    sn = machine(e, "gr", True)
    ev = [(600, "press", "RECORD"), (900, "press", "T1", 1500), (950, "press", "T3", 1450), (1200, "turn", "0:+8", 1, 50),
          (1500, "turn", "0:+8", 2, 100), (1900, "press", "YES"), (2800, "press", "RECORD")]
    r = e.run("listlock", 3500, ev, snap=sn, answer=True, sends=[(300, w48(5, 5)), (2100, w48(9, 2, 1))])
    s = r["snap"][0]
    l1, l3, l2, w = e.live_lock(s, 0), e.live_lock(s, 2), e.live_lock(s, 1), e.word0(s)
    print(f"  4A {lsev(r)}; 48 {evs(r, 'w48')}; locks {l1:#06x} {l2:#06x} {l3:#06x}; word {w:#06x}")
    check("listlock: 4A open then YES", [x[2] for x in lsev(r)] == [0, 1], lsev(r))
    check("listlock: answered 48 1 0 0 4 (locked)", [x["status"] for x in evs(r, "w48")][-1:] == [4], evs(r, "w48"))
    check("listlock: steps 1 and 3 locked to 0x0940, step 2 not, the kit word still 0x05a0",
          l1 == 0x0940 and l3 == 0x0940 and l2 == 0xffff and w == 0x05a0, (hex(l1), hex(l2), hex(l3), hex(w)))
    fl = e.peek(s, LIVE_LOCKS_BD + 5632 + 9, 1)[0]
    check("listlock: the track's fine flag for P1 is set (the saved lock keeps the bank)", fl == 1, fl)


def t_upt(e):
    """UP held + T6..T13 -> 49 1 1 6..13 (the Pi display's pages, 1036b's T1..T5 extended; 1046: T11 SONG, T12 PROJECT,
    T13 POOL); in GRID REC the trigs are eaten (no trig placed on BD: its trig bytes as before)."""
    ev = [(330, "press", "RECORD")]
    t = 500
    for k in range(6, 14):
        ev += [(t, "press", "UP", 300), (t + 100, "press", f"T{k}")]
        t += 500
    ev += [(t, "press", "RECORD")]
    r = e.run("upt", t + 800, ev)
    ref = e.run("upt-ref", t + 800, [x for x in ev if not x[2].startswith("T")])
    pages = [x["body"][0] for x in evs(r, "d49") if x["kind"] == 1]
    print(f"  49 1 pages {pages}")
    check("upt: UP + T6..T13 -> 49 1 1 6, 7, .., 13", pages == list(range(6, 14)), pages)
    before = e.peek(ref["snap"][0], 0x407dd8e3, 917)
    after = e.peek(r["snap"][0], 0x407dd8e3, 917)
    check("upt: no trig placed on BD (its track as in the same run without the trig presses)", before == after)
    check("upt: no key reached the host's seq (no 31)", not evs(r, "key"), evs(r, "key"))


def t_nrpn(e):
    """Check 3 on this build: with PARAM OUTPUT NRPN, ENCODER DEST INT+EXT (rytm-teensy sim/song_e2e.py's walk), knob A on
    a banked GRANULAR SRC (no host frame: the stock knob) sends NRPN 1:0 with MSB = the index and LSB = the fraction's
    top 7 bits (the bank survives on NRPN; on CC only the index would)."""
    sys.path.insert(0, os.path.join(S.TEENSY, "sim"))
    from song_e2e import WALK
    ev = [(500 + 400 * i, "press", k) for i, k in enumerate(WALK)]
    W = e.run("nrpn-walk", 500 + 400 * len(WALK) + 1000, ev)["snap"]
    keys = UI["list_open"] + ["DOWN"] * DOWNS["gr"] + [UI["list_confirm"]]
    G = e.run("nrpn-gr", 500 + 300 * len(keys) + 1500, [(500 + 300 * i, "press", k) for i, k in enumerate(keys)],
              snap=W)["snap"]
    r = e.run("nrpn", 3000, [(1000, "turn", "0:+8", 3, 100)], snap=G, sends=[(300, w48(5, 5))], midi_out=True)
    m = r["midi"]
    want = bytes([0xB0, 0x63, 0x01, 0xB0, 0x62, 0x00, 0xB0, 0x06, 0x06, 0xB0, 0x26, 0x50])
    print(f"  DIN {m[-24:].hex(' ')}")
    check("nrpn: NRPN 1:0 = 6 / 0x50 (index 6, bank F in the LSB)", want in m, m.hex(" ")[:200])


def t_scale(e):
    """Hardware report on rui1037: on a seq track in GRID REC the host's page hid stock's SCALE menu (FUNC + PAGE). With the
    page open (TRK + YES, the host's frame on the glass) and BD a seq track (2E), FUNC + PAGE: stock's SCALE menu on the
    glass (its ScaleMenuView on top; the screen equals the same keys on a Rytm whose page never opened), PAGE never
    reaches the host, LEVEL in the menu edits stock's scale (BD's length as without the page) and 2D 04 reports it; NO closes the menu: the host's frame again, the page still open."""
    import protocol as P
    fb = bytearray(1024)
    for x in range(128):
        for y in range(64):
            if (x // 8 + y // 8) & 1:
                fb[(7 - y // 8) + 8 * x] |= 1 << (y % 8)
    frame = P.rui_rect(5, 0, 0, 16, 8, bytes(fb)) + P.rui_commit(5)
    seq = sx(0x2E, 1, 0, 0)   # BD the seq track (reports on)
    keys = [(1200, "press", "FUNC", 400), (1300, "press", "PAGE"), (1800, "turn", "8:+8", 3, 100)]   # LEVEL: BD's length
    opened = [(300, "press", "TRK", 200), (400, "press", "YES")]
    sends = [(800, seq), (700, frame)]   # the 2E after the hello (0.5 s: the Rytm forgets the seq tracks at it)
    a = e.run("scale-page", 2600, opened, sends=sends)
    r = e.run("scale-open", 2600, opened + keys, sends=sends)
    ref = e.run("scale-ref", 2600, keys, sends=[(800, seq)])
    sv = e.peek(r["snap"][0], e.sym("sv") + 88, 4).hex()
    print(f"  top view {sv}; keys to the host {[(x['code'], x['down']) for x in evs(r, 'key')]}")
    check("scale: (control) the page open shows the host's frame", a["oled"] == bytes(fb), S.diff(a["oled"], bytes(fb)))
    check("scale: FUNC + PAGE with the page open: stock's SCALE menu on top (ScaleMenuView 401d1e74)", sv == "401d1e74", sv)
    check("scale: the screen is stock's SCALE menu, as on a Rytm whose page never opened", r["oled"] == ref["oled"] and
          r["oled"] != bytes(fb), S.diff(r["oled"], ref["oled"]))
    check("scale: PAGE never reached the host", 0x84 not in [x["code"] for x in evs(r, "key")], evs(r, "key"))
    ln = lambda x: e.peek(x["snap"][0], 0x407dd8e3 + 0x2C5, 1)[0]   # noqa: E731  BD's length (sc_poll's)
    print(f"  BD's length: page {ln(a)}, SCALE edit {ln(r)}, stock {ln(ref)}")
    check("scale: the SCALE menu's edit (LEVEL: BD's length) applied as without the page", ln(r) == ln(ref) != ln(a),
          (ln(a), ln(r), ln(ref)))
    s4 = [x for x in evs(r, "s2d") if x["kind"] == 4 and x["t"] > 1.8 and x["body"][0] == 0]
    check("scale: 2D 04 (SCALE) reports BD's new length", bool(s4) and s4[-1]["body"][1] == ln(r), evs(r, "s2d")[-3:])
    n = e.run("scale-no", 3200, opened + keys + [(2500, "press", "NO")], sends=sends)
    m = [(x["on"], x["reason"]) for x in evs(n, "mode")]
    check("scale: NO closes the menu: the host's frame again, the page still open", n["oled"] == bytes(fb) and
          m == [(1, 0)], (S.diff(n["oled"], bytes(fb)), m))


# 1042: the real host's catch mask (rytm-teensy core/ui/remote.cpp kCatchKeys + a page with knobs A..H: send_mask)
HOST_KEYS = [0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x84, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x10, 0xB0, 0xB4, 0xB5, 0xB1,
             0x81, 0x82, 0x86] + list(range(0x70, 0x78))
# the stock overlays the host's mask leaves reachable with the page open: (name, keys, the overlay's vtable) [measured,
# rytm-emu rui1042: each one's top view on a Rytm whose page never opened]
POPUPS = [
    ("tempo", [(1200, "press", "TEMPO")], "401d55dc"),                                          # TempoMenuView
    ("taptempo", [(1200, "press", "FUNC", 1000), (1300, "press", "TEMPO", 800)], "401d54c0"),    # TapTempoView
    ("ptnmode", [(1200, "press", "FUNC", 400), (1300, "press", "BANK_A")], "401d6e18"),          # PopupWindow PTN: ...
    ("copy", [(1200, "press", "FUNC", 400), (1300, "press", "RECORD")], "401d6e18"),             # PopupWindow COPY PATTERN
    ("fix", [(1200, "press", "FUNC", 400), (1300, "press", "FIX")], "40234b90"),                 # FixSetupMenuView
    ("click", [(1200, "press", "FUNC", 400), (1300, "press", "RTRG")], "401cd758"),              # MetronomeMenuView
    ("sound", [(1200, "press", "FUNC", 400), (1300, "press", "MUTE")], "401e8df8"),              # SoundMenuView
    ("song", [(1200, "press", "FUNC", 400), (1300, "press", "PERF")], "401d2694"),               # SongMenuView
    ("pattern", [(1200, "press", "FUNC", 400), (1300, "press", "SCNE")], "401e6294"),            # PatternMenuView
    ("track", [(1200, "press", "FUNC", 400), (1300, "press", "CHRO")], "401ec0fc"),              # TrackMenuView
    ("browser", [(1200, "press", "FUNC", 400), (1300, "press", "PUSH_LEVEL")], "401d2904"),      # SoundBrowser
    ("save", [(1150, "press", "FUNC", 250), (1200, "press", "SCNE"), (1400, "press", "DOWN"), (1550, "press", "YES")],
     "401d6e18"),                                                     # PATTERN menu, SAVE PATTERN: PopupWindow SAVED
    ("songname", [(1100, "press", "FUNC", 400), (1200, "press", "PERF"), (1500, "press", "DOWN"), (1600, "press", "DOWN"),
                  (1700, "press", "YES")], "401d6af4", 2400),               # SONG menu, SAVE: NameView (the name prompt)
]


def t_popups(e):
    """1042: the stock overlays under the page. With the page open (TRK + YES, the host's frame and its real catch mask),
    each stock menu / popup the mask leaves reachable (TEMPO, FUNC + TEMPO, FUNC + BANK / REC / FIX / RTRG / MUTE / PERF /
    SCNE / CHRO / LEVEL's push) is on the glass as on a Rytm whose page never opened (the page steps aside, as 1038's
    SCALE), no key of the gesture reaches the host; TEMPO's knob edits the tempo as stock; NO closes TEMPO and the
    PATTERN menu (its DOWN / NO stock's) and the host's frame is back with the page still open; the COPY toast goes by
    itself and the frame comes back."""
    import protocol as P
    from concurrent.futures import ThreadPoolExecutor
    fb = bytearray(1024)
    for x in range(128):
        for y in range(64):
            if (x // 8 + y // 8) & 1:
                fb[(7 - y // 8) + 8 * x] |= 1 << (y % 8)
    frame = P.rui_rect(5, 0, 0, 16, 8, bytes(fb)) + P.rui_commit(5)
    mask = P.rui_mask(encs=range(8), keys=HOST_KEYS)
    opened = [(300, "press", "TRK", 200), (400, "press", "YES")]
    sends = [(650, mask), (700, frame)]
    top = lambda x: e.peek(x["snap"][0], e.sym("sv") + 88, 4).hex()   # noqa: E731

    def pair(p):
        n, keys, vt = p[:3]
        end = p[3] if len(p) > 3 else 1800
        return n, vt, e.run(f"pop-{n}", end, opened + keys, sends=sends), e.run(f"pop-{n}-ref", end, keys)
    sel = [p for p in POPUPS if not os.environ.get("POPUPS") or p[0] in os.environ["POPUPS"].split(",")]
    with ThreadPoolExecutor(4) as ex:
        res = list(ex.map(pair, sel))
    for n, vt, r, f in res:
        k = [(x["code"], x["down"]) for x in evs(r, "key")]
        print(f"  {n}: top {top(r)} (stock {top(f)}), keys to the host {k}")
        check(f"popups {n}: stock's overlay on top ({vt}), as without the page", top(r) == top(f) == vt, (top(r), top(f)))
        check(f"popups {n}: the screen is stock's overlay, as on a Rytm whose page never opened",
              r["oled"] == f["oled"] and r["oled"] != bytes(fb), S.diff(r["oled"], f["oled"]))
        check(f"popups {n}: no key of the gesture reached the host", not k, k)
    # TEMPO's UP edits the tempo as stock (+0.1 BPM a press; knobs A..H and LEVEL do not, stock 1.73 in rytm-emu); NO
    # closes the menu: the host's frame, the page still open
    tk = [(1200, "press", "TEMPO"), (1500, "press", "UP"), (1700, "press", "UP")]
    tempo = lambda x: int.from_bytes(e.peek(x["snap"][0], 0x40287c9c, 4), "big")   # noqa: E731
    a = e.run("pop-tempo-knob", 2200, opened + tk, sends=sends)
    b = e.run("pop-tempo-knob-ref", 2200, tk)
    print(f"  tempo word: page {tempo(a)}, stock {tempo(b)}; keys to the host {evs(a, 'key')[:3]}")
    check("popups tempo: the menu's UP edits the tempo as without the page", tempo(a) == tempo(b) != 15240,
          (tempo(a), tempo(b)))
    c = e.run("pop-tempo-no", 2600, opened + tk + [(2200, "press", "NO")], sends=sends)
    m = [(x["on"], x["reason"]) for x in evs(c, "mode")]
    check("popups tempo: NO closes the menu: the host's frame again, the page still open",
          c["oled"] == bytes(fb) and m == [(1, 0)], (S.diff(c["oled"], bytes(fb)), m))
    check("popups tempo: no key or turn to the host", not evs(c, "key") and not evs(c, "enc"),
          (evs(c, "key"), evs(c, "enc")[:2]))
    pk = [(1200, "press", "FUNC", 400), (1300, "press", "SCNE"), (1700, "press", "DOWN"), (2000, "press", "NO")]
    p = e.run("pop-pattern-no", 2600, opened + pk, sends=sends)
    m = [(x["on"], x["reason"]) for x in evs(p, "mode")]
    check("popups pattern: DOWN / NO in the PATTERN menu are stock's; after NO the host's frame, the page open",
          p["oled"] == bytes(fb) and m == [(1, 0)] and not evs(p, "key"), (S.diff(p["oled"], bytes(fb)), m, evs(p, "key")))
    q = e.run("pop-copy-gone", 4000, opened + [(1200, "press", "FUNC", 400), (1300, "press", "RECORD")], sends=sends)
    check("popups copy: the COPY PATTERN toast goes by itself and the host's frame is back", q["oled"] == bytes(fb),
          S.diff(q["oled"], bytes(fb)))


LIST = dict(gr=0, wt=1, ms=2)   # 47's list byte: 0 GRANULAR SRC, 1 WAVETABLE TBL, 2 MULTISAMPLE INST


def t_banka(e):
    """1043: bank A's text like B..H's on all three machines (no more GRANULAR's IN MAIN .. texts or a number, no more
    min(v, total - 1)). Each screen is compared with a run where the host names that row with the text expected, so
    equal screens mean that text: before any 47, index 5 reads A005 and index 0 OFF; a 47 with bank byte 0 (the host's
    form from now on, total 127) names its rows (row 5 VOX A5: the screen differs from A005 and equals the old bank-A
    form's, no bank byte, with the same row); a row the 47 left unnamed reads A009. rui1042 fails: GRANULAR's 5 read BT,
    WAVETABLE's / MULTISAMPLE's a number, index 0 IN / 0, the old form clamped."""
    for key in ("gr", "wt", "ms"):
        sn, l = machine(e, key), LIST[key]
        run = lambda n, v, *nm: e.run(f"banka-{key}-{n}", 1500, snap=sn,   # noqa: E731
                                      sends=[(150 + 20 * i, m) for i, m in enumerate(nm)] + [(300, w48(v, 0))])
        n5, a5 = run("n5", 5), run("a5", 5, names47(l, 1, 127, 0, 5, ["A005"]))
        n0, o0 = run("n0", 0), run("o0", 0, names47(l, 1, 127, 0, 0, ["OFF"]))
        check(f"banka {key}: no names, index 5 reads A005", n5["oled"] == a5["oled"], S.diff(n5["oled"], a5["oled"]))
        check(f"banka {key}: no names, index 0 reads OFF", n0["oled"] == o0["oled"], S.diff(n0["oled"], o0["oled"]))
        rows = ["OFF", "ONE", "TWO", "THREE", "FOUR", "VOX A5", "SIX", "SEVEN"]
        new = run("b0", 5, names47(l, 1, 127, 0, 0, rows))
        old = run("old", 5, names47(l, 1, 8, None, 0, rows))
        check(f"banka {key}: a 47 with bank byte 0 names row 5 (the screen differs from A005)", new["oled"] != n5["oled"])
        check(f"banka {key}: the old bank-A 47 (no bank byte) shows the same row 5 name", old["oled"] == new["oled"],
              S.diff(old["oled"], new["oled"]))
        nine, a9 = run("n9", 9, names47(l, 1, 127, 0, 0, rows)), run("a9", 9, names47(l, 1, 127, 0, 9, ["A009"]))
        check(f"banka {key}: a row the 47 left unnamed reads A009", nine["oled"] == a9["oled"], S.diff(nine["oled"], a9["oled"]))


def t_tbldef(e):
    """1043: WAVETABLE's default TBL 1 (A001): a new WAVETABLE track's P1 word is 0x0100 and the record's default (+0x10)
    0x100; its text is row 1's (A001 with no names: the screen equals the host naming row 1 A001; with bank A's names
    row 1's name). GRANULAR SRC stays 10 (0x0a00), MULTISAMPLE INST 0. rui1042 fails WAVETABLE's (0)."""
    for key, want in (("gr", 0x0a00), ("wt", 0x0100), ("ms", 0x0000)):
        sn = machine(e, key)
        w, d = e.word0(sn[0]), int.from_bytes(e.peek(sn[0], B_REC_P1 + 0x10, 4), "big")
        print(f"  {key}: P1 word {w:#06x}, record default {d:#x}")
        check(f"tbldef {key}: the new track's P1 word {want:#06x}", w == want, hex(w))
        check(f"tbldef {key}: the record's default {want:#x}", d == want, hex(d))
    sn = machine(e, "wt")
    n = e.run("tbldef-none", 1500, snap=sn)
    a = e.run("tbldef-a001", 1500, snap=sn, sends=[(300, names47(1, 1, 127, 0, 1, ["A001"]))])
    b = e.run("tbldef-basic", 1500, snap=sn, sends=[(300, names47(1, 1, 127, 0, 0, ["OFF", "BASIC"]))])
    z = e.run("tbldef-off", 1500, snap=sn, sends=[(300, w48(0, 0))])
    check("tbldef wt: the default's text is A001 with no names", n["oled"] == a["oled"], S.diff(n["oled"], a["oled"]))
    check("tbldef wt: the default's text is not index 0's (OFF)", n["oled"] != z["oled"])
    check("tbldef wt: with bank A's names the default shows row 1's name (differs from A001)", b["oled"] != n["oled"])
    check("tbldef wt: the word is still 0x0100 after the names", e.word0(b["snap"][0]) == 0x0100, hex(e.word0(b["snap"][0])))


# ---- 1045: DSP SAMPLE's SMP banked (word 19, P11: index << 8 | bank << 5, the SAMPLES pool's 8 banks) -------------
REC = lambda r: 0x401bf918 + 0x34 * r   # noqa: E731  (a parameter record: +0x04 index, +0x0c max, +0x14 fine)
REC_SMP = 441          # DSP SAMPLE's own word-19 record since 1045 (was stock's 41; TUN, word 17, is stock's 39)
P_SMP = 10             # P11 = word 19 (sound index 9 + 10)


def w48s(v, bank, *extra):
    """48 0 10 <index> <bank << 4> [flags]: BD's P11 (SMP) = index << 8 | bank << 5."""
    return sx(0x48, 0, P_SMP, v, bank << 4, *extra)


def smp(e, snap, t=0):
    return int.from_bytes(e.kword(snap, t, P_SMP), "big")


def t_dspknob(e):
    """DSP SAMPLE (BD), its SMPL page, SMP (knob D) with no host frame: the word C005 (0x0540) set by 48 0 10 5 <C>,
    answered 0; turned up / down one detent (3 x 8 counts, as t_knob) it steps the index and keeps bank C (0x0640 /
    0x0440), never opens stock's
    SAMPLE SLOT list (SampleListView); its 2A P11 carries the 14 bits. The records: SMP 441 (index 19, max 0x7fe0, fine
    1), TUN back on stock's 39, stock's 41 untouched (0x7f00, fine 0)."""
    sn = machine(e, "ds")
    r = e.run("dspknob-set", 1500, snap=sn, sends=[(300, w48s(5, 2))])
    check("dspknob: 48 0 10 5 <C> -> word 19 = 0x0540, answered 0", smp(e, r["snap"][0]) == 0x0540 and
          [x["status"] for x in evs(r, "w48")] == [0], (hex(smp(e, r["snap"][0])), evs(r, "w48")))
    for d, want in (("+8", 0x0640), ("-8", 0x0440)):
        r = e.run(f"dspknob{d}", 3500, [(600, "press", "SMPL"), (1200, "turn", f"3:{d}", 3, 100)], snap=sn,
                  sends=[(300, w48s(5, 2))])
        w = smp(e, r["snap"][0])
        b2 = [x["vt"] for x in evs(r, "v2b")]
        print(f"  {d}: word 19 {w:#06x}, tops {sorted(set(b2))}")
        check(f"dspknob {d}: one index a detent, bank C kept ({want:#06x})", w == want, hex(w))
        check(f"dspknob {d}: stock's SAMPLE SLOT list never opened (no SampleListView on top)", "401e70d4" not in b2, b2)
    rs = e.peek(sn[0], REC(REC_SMP), 0x34)
    r41 = e.peek(sn[0], REC(41), 0x34)
    r39 = e.peek(sn[0], REC(39), 0x28)
    print(f"  441 {rs[:0x28].hex()}\n  41  {r41[:0x28].hex()}\n  39  {r39.hex()}")
    check("dspknob: record 441 = SMP: index 19, max 0x7fe0, fine 1", rs[4:8] == bytes.fromhex("00000013") and
          rs[12:16] == bytes.fromhex("00007fe0") and rs[20:24] == bytes.fromhex("00000001"), rs[:24].hex())
    check("dspknob: stock's record 41 untouched (index 19, max 0x7f00, fine 0)", r41[4:8] == bytes.fromhex("00000013") and
          r41[12:16] == bytes.fromhex("00007f00") and r41[20:24] == bytes.fromhex("00000000"), r41[:24].hex())


def t_dsplist(e):
    """The list on DSP SAMPLE: SMP (knob D on the SMPL page, the host drawing): the first turn opens it (4A 0 1 <P11 =
    5 . C> 0, the word unmoved) and the Rytm turns the view on for the list (29 1 0: the host's frame over the SMPL page
    while it is open); further turns of D reach the host as 32 0 (the list's knob), RIGHT as 31; YES closes it (why 1)
    and the view ends (29 0 0); the host's 48 0 10 9 <B> 1 (no trig held) writes the kit: 0x0920, answered 0. NO closes
    with why 2, nothing written; knob A (ENG) closes it (why 3) and edits ENG; knob A on the SRC view opens nothing (ENG
    stays the engine chooser)."""
    sn = machine(e, "ds", True)
    v0 = 5 << 7 | 0x20
    ev = [(500, "press", "SMPL"), (1200, "turn", "3:+8", 1, 50), (1500, "turn", "3:+8", 3, 100), (1900, "press", "RIGHT", 100),
          (2300, "press", "YES", 100)]
    r = e.run("dsplist", 3600, ev, snap=sn, answer=True, sends=[(300, w48s(5, 2)), (2800, w48s(9, 1, 1))])
    ls_, k, en = lsev(r), [(x["code"], x["down"]) for x in evs(r, "key")], evs(r, "enc")
    v29 = [(x["track"], x["on"]) for x in evs(r, "v29")]
    w = smp(e, r["snap"][0])
    print(f"  4A {ls_}; 29 {v29}; keys {k}; turns {[(x['enc'], x['delta']) for x in en]}; word {w:#06x}; 48 {evs(r, 'w48')}")
    check("dsplist: opened by SMP (4A on, P11 = 5 . C, why 0), closed by YES (why 1)", ls_ == [(1, v0, 0), (0, v0, 1)], ls_)
    check("dsplist: the view on for the list over the SMPL page (29 1 after the SMPL page's 29 0), off after it",
          v29[-3:] == [(0, 0), (0, 1), (0, 0)], v29)
    check("dsplist: the turns after the opening one reach the host on encoder 0", bool(en) and
          all(x["enc"] == 0 for x in en) and sum(x["delta"] for x in en) > 0, en)
    check("dsplist: RIGHT down / up reaches the host, YES never as a 31", k == [(0x41, 1), (0x41, 0)], k)
    check("dsplist: the host's 48 0 10 9 <B> 1 wrote the kit: 0x0920, answered 0",
          w == 0x0920 and [x["status"] for x in evs(r, "w48")][-1:] == [0], (hex(w), evs(r, "w48")))
    a = [x["vals"][P_SMP - x["first"]] for x in evs(r, "v2a") if x["first"] <= P_SMP < x["first"] + x["n"]]
    check("dsplist: the view's 2A carries P11's 14 bits (5 . C; the 48 after the close needs none: the host wrote it)",
          a[-1:] == [5 << 7 | 0x20], a)
    r = e.run("dsplist-no", 2600, [(500, "press", "SMPL"), (1200, "turn", "3:+8", 1, 50), (1600, "press", "NO")],
              snap=sn, answer=True, sends=[(300, w48s(5, 2))])
    check("dsplist: NO closes it (why 2), the word unchanged (0x0540)", lsev(r)[-1:] == [(0, v0, 2)] and
          smp(e, r["snap"][0]) == 0x0540, (lsev(r), hex(smp(e, r["snap"][0]))))
    e0 = e.kword(sn[0], 0, 0)
    r = e.run("dsplist-knob", 3000, [(500, "press", "SMPL"), (1200, "turn", "3:+8", 1, 50), (1600, "turn", "0:+8", 6, 50)],
              snap=sn, answer=True, sends=[(300, w48s(5, 2))])
    check("dsplist: knob A closes it (why 3) and goes to stock (TUN, word 17 on this page)", lsev(r)[-1:] == [(0, v0, 3)],
          lsev(r))
    r = e.run("dsplist-src", 2500, [(1000, "turn", "0:+8", 6, 50)], snap=sn, answer=True, sends=[(300, w48s(5, 2))])
    check("dsplist: on the SRC view knob A (ENG) opens no list and edits ENG", not lsev(r) and e.kword(r["snap"][0], 0, 0) != e0,
          (lsev(r), e0.hex(), e.kword(r["snap"][0], 0, 0).hex()))
    r = e.run("dsplist-nohost", 2600, [(500, "press", "SMPL"), (1200, "turn", "3:+8", 3, 100)], snap=machine(e, "ds"),
              host=False, sends=[(300, w48s(5, 2))])
    check("dsplist: no host: no list", not lsev(r), lsev(r))


def t_dspbrowse(e):
    """FUNC + YES on DSP SAMPLE's open list -> 4A 0 3 <P11> 0 (the host's file browser for the row), as on GRANULAR."""
    sn = machine(e, "ds", True)
    v0 = 5 << 7 | 0x20
    ev = [(500, "press", "SMPL"), (1200, "turn", "3:+8", 1, 50), (1500, "press", "FUNC", 150), (1550, "press", "YES", 50),
          (1900, "press", "DOWN", 50), (2600, "press", "YES", 50)]
    # (the host's clock runs ~0.2 s behind the emulator's here: its 4A 0 0 well before the YES)
    r = e.run("dspbrowse", 3400, ev, snap=sn, answer=True, sends=[(300, w48s(5, 2)), (1700, sx(0x4A, 0, 1)),
                                                                 (2100, sx(0x4A, 0, 0))])
    ls_, k = lsev(r), [(x["code"], x["down"]) for x in evs(r, "key")]
    print(f"  4A {ls_}; keys {k}")
    check("dspbrowse: opened, FUNC + YES -> 4A on 3, closed by YES after the host's 4A 0 0 (why 1)",
          ls_ == [(1, v0, 0), (3, v0, 0), (0, v0, 1)], ls_)
    check("dspbrowse: DOWN reaches the host while its browser is open", (0x43, 1) in k, k)


def t_dsptext(e):
    """SMP's value text on the SMPL page (no host frame): the word C005 with no names reads C005 (the screen equals the
    host naming row 5 of bank C "C005"); bank C's names (47 list 0, bank byte 2) name it (the screen differs); index 0
    reads OFF; an old bank-A word 0x0500 reads A005."""
    sn = machine(e, "ds")
    run = lambda n, v, b, *nm: e.run(f"dsptext-{n}", 1800, [(500, "press", "SMPL")], snap=sn,   # noqa: E731
                                     sends=[(150 + 20 * i, m) for i, m in enumerate(nm)] + [(300, w48s(v, b))])
    n5, c5 = run("n5", 5, 2), run("c5", 5, 2, names47(0, 1, 127, 2, 5, ["C005"]))
    v5 = run("v5", 5, 2, names47(0, 1, 127, 2, 0, ["OFF", "ONE", "TWO", "THREE", "FOUR", "VOX C5"]))
    o0, f0 = run("o0", 0, 2), run("f0", 0, 2, names47(0, 1, 127, 2, 0, ["OFF"]))
    a5, aa = run("a5", 5, 0), run("aa", 5, 0, names47(0, 1, 127, 0, 5, ["A005"]))
    check("dsptext: no names, 5 . C reads C005", n5["oled"] == c5["oled"], S.diff(n5["oled"], c5["oled"]))
    check("dsptext: bank C's names name it (the screen differs from C005)", v5["oled"] != n5["oled"])
    check("dsptext: index 0 reads OFF", o0["oled"] == f0["oled"], S.diff(o0["oled"], f0["oled"]))
    check("dsptext: an old word 0x0500 reads A005", a5["oled"] == aa["oled"], S.diff(a5["oled"], aa["oled"]))


def t_dsplock(e):
    """A DSP SAMPLE lock on bank C over a power-off: GRID REC, T1 held, SMP turned on the SMPL page (no host frame: stock's
    lock path through 0029) from 5 . C: step 1's live lock keeps bank C (fraction 0x40), the word still 0x0540; the stored
    copy has SMP's slot then its fine slot (80 80); power off, cold boot on that card: the lock is back at 16 bits."""
    sn = machine(e, "ds")
    ev = [(500, "press", "SMPL"), (800, "press", "RECORD"), (1500, "press", "T1", 1900), (1800, "turn", "3:+8", 9, 100),
          (3600, "press", "RECORD")]
    r = e.run("dsplock", 4500, ev, snap=sn, sends=[(300, w48s(5, 2))])
    s = r["snap"]
    lk, w = e.live_lock(s[0], 0, k=19), smp(e, s[0])
    print(f"  lock {lk:#06x}, word {w:#06x}")
    check("dsplock: step 1's live lock is index . bank C (fraction 0x40), the word still 0x0540",
          lk != 0xffff and lk & 0xff == 0x40 and lk >> 8 != 5 and w == 0x0540, (hex(lk), hex(w)))
    fl = e.peek(s[0], LIVE_LOCKS_BD + 5632 + 19, 1)[0]
    check("dsplock: the track's fine flag for SMP is set", fl == 1, fl)
    sl = e.stored_slots(s[0])
    used = [(j, t, tr, v[:2].hex()) for j, (t, tr, v) in enumerate(sl) if t != 0xff]
    ty = [j for j, (t, tr, v) in enumerate(sl) if tr == 0 and t != 0xff and t != 0x80 and v[0] == lk >> 8]
    ok = bool(ty) and ty[-1] + 1 < 72 and sl[ty[-1] + 1][0] == 0x80 and sl[ty[-1] + 1][2][0] == (lk & 0xff) >> 1
    check("dsplock: stored: SMP's slot with the index, then the fine slot (80 80) with 0x20", ok, used[-4:])
    card = os.path.join(e.out, "bk_dsplock.img")
    if os.path.exists(card):
        os.remove(card)
    subprocess.run(["cp", "-c", os.path.join(EMU, e.card), card], check=True)
    try:
        p = e.run("dsplock-off", 1000, snap=s, host=False, extra=["--card", card, "--power-off", f"{s[1] + 100}M"])
        check("dsplock: the power-off handler saved the state", "power off: handler finished" in p["out"])
        c = e.run("dsplock-cold", 22000, cold_card=card, host=False)
        cl, cw = e.live_lock(c["snap"][0], 0, k=19), smp(e, c["snap"][0])
        print(f"  after the cold boot: lock {cl:#06x}, word {cw:#06x}")
        check("dsplock: after the cold boot the lock is back at 16 bits (bank C kept), the word 0x0540", cl == lk and cw == 0x0540,
              (hex(cl), hex(cw)))
    finally:
        os.remove(card)


def t_dspold(e):
    """Old kits read as bank A: on the previous build (OLD_TAG, default rui1043: SMP stock's record 41) BD on DSP SAMPLE with
    SMP 5 (stock's slot record: 7 bits) and a step-1 lock of 7 (T1 held, 48 cannot lock: the knob through stock's list is
    not scriptable, so the lock is made by 48 with flags 1 while T1 is held in GRID REC... on that build 48 1 on P11 writes
    the kit); powered off on a card; this build cold-booted on that card: word 19 = 0x0500 (A005: bank A), its 2A P11
    5 << 7 | 0."""
    old = os.environ.get("OLD_TAG", "rui1043")
    o = Emu(old)
    keys = UI["list_open"] + ["DOWN"] * DOWNS["ds"] + [UI["list_confirm"]]
    ev = [(500 + 300 * i, "press", k) for i, k in enumerate(keys)]
    t = 500 + 300 * len(keys) + 1500
    r = o.run("dspold-make", t + 1000, ev, sends=[(t, sx(0x48, 0, P_SMP, 5))])
    w_old = smp(o, r["snap"][0])
    check(f"dspold: on {old} SMP = 5 (0x0500)", w_old == 0x0500, hex(w_old))
    card = os.path.join(e.out, "bk_dspold.img")
    if os.path.exists(card):
        os.remove(card)
    subprocess.run(["cp", "-c", os.path.join(EMU, o.card), card], check=True)
    try:
        p = o.run("dspold-off", 1000, snap=r["snap"], host=False, extra=["--card", card, "--power-off", f"{r['snap'][1] + 100}M"])
        check("dspold: the power-off handler saved the state", "power off: handler finished" in p["out"])
        c = e.run("dspold-cold", 22000, cold_card=card, host=True)
        cw = smp(e, c["snap"][0])
        a = [x["vals"][P_SMP - x["first"]] for x in evs(c, "v2a") if x["first"] <= P_SMP < x["first"] + x["n"]]
        print(f"  this build on the old card: word 19 {cw:#06x}, machine {e.peek(c['snap'][0], 0x8000EA00, 1)[0]}")
        check("dspold: this build reads the old SMP 5 as 0x0500 (A005, bank A)", cw == 0x0500, hex(cw))
    finally:
        os.remove(card)


def t_dsplistlock(e):
    """GRID REC, T1 and T3 held, DSP SAMPLE's list opened by SMP on the SMPL page and YES pressed while they are held: the
    host's 48 0 10 9 <C> 1 locks P11 on steps 1 and 3 (answered 4) at 0x0940 (fine), the kit word stays 0x0540."""
    sn = machine(e, "ds", True)
    ev = [(400, "press", "SMPL"), (700, "press", "RECORD"), (900, "press", "T1", 1500), (950, "press", "T3", 1450),
          (1200, "turn", "3:+8", 1, 50), (1500, "turn", "3:+8", 2, 100), (1900, "press", "YES"), (2800, "press", "RECORD")]
    r = e.run("dsplistlock", 3500, ev, snap=sn, answer=True, sends=[(300, w48s(5, 2)), (2050, w48s(9, 2, 1))])
    s = r["snap"][0]
    l1, l3, l2, w = e.live_lock(s, 0, k=19), e.live_lock(s, 2, k=19), e.live_lock(s, 1, k=19), smp(e, s)
    print(f"  4A {lsev(r)}; 48 {evs(r, 'w48')}; locks {l1:#06x} {l2:#06x} {l3:#06x}; word {w:#06x}")
    check("dsplistlock: 4A open then YES", [x[2] for x in lsev(r)] == [0, 1], lsev(r))
    check("dsplistlock: answered 48 1 0 10 4 (locked)", [x["status"] for x in evs(r, "w48")][-1:] == [4], evs(r, "w48"))
    check("dsplistlock: steps 1 and 3 locked to 0x0940, step 2 not, the kit word still 0x0540",
          l1 == 0x0940 and l3 == 0x0940 and l2 == 0xffff and w == 0x0540, (hex(l1), hex(l2), hex(l3), hex(w)))


def t_dspoldhost(e):
    """A host that draws no list (answers no 29 with a frame: an older one): SMP's first turn opens the list (4A), no
    frame comes within a second, the list closes (why 5: the view ended) and SMP is the stock knob (0029's banked step)
    until the next hello: a later turn steps the word, no second 4A."""
    sn = machine(e, "ds", True)   # (a host that has drawn: commits since boot)
    ev = [(500, "press", "SMPL"), (1000, "turn", "3:+8", 1, 50), (2600, "turn", "3:+8", 3, 100)]
    r = e.run("dspoldhost", 4000, ev, snap=sn, answer=False, sends=[(300, w48s(5, 2))])
    w = smp(e, r["snap"][0])
    print(f"  4A {lsev(r)}; word {w:#06x}")
    check("dspoldhost: opened once, closed by the view's end (why 5) a second later", lsev(r) == [(1, 5 << 7 | 0x20, 0),
          (0, 5 << 7 | 0x20, 5)], lsev(r))
    check("dspoldhost: then SMP steps as the stock knob, bank C kept (0x0640)", w == 0x0640, hex(w))


def t_dspnrpn(e):
    """What SMP sends on MIDI (rytm-teensy sim/song_e2e.py's walk: ENCODER DEST INT+EXT; the song recorder drops a banked
    track's SMP CC / NRPN, its kSrc has the 14 bits): with PARAM OUTPUT NRPN, SMP from 5 . C one detent up sends NRPN
    1:11 = 6 / 0x20 (the bank in the LSB) [measured]; with PARAM OUTPUT CC (the walk without its CC -> NRPN step) a CC
    with the index alone."""
    sys.path.insert(0, os.path.join(S.TEENSY, "sim"))
    from song_e2e import WALK
    k = next(i for i in range(len(WALK) - 1) if WALK[i:i + 2] == ["DOWN", "LEFT"])
    out = {}
    for mode, walk in (("nrpn", list(WALK)), ("cc", list(WALK[:k + 1]) + list(WALK[k + 2:]))):
        ev = [(500 + 400 * i, "press", x) for i, x in enumerate(walk)]
        W = e.run(f"dspnrpn-walk-{mode}", 500 + 400 * len(walk) + 1000, ev)["snap"]
        keys = UI["list_open"] + ["DOWN"] * DOWNS["ds"] + [UI["list_confirm"]]
        D = e.run(f"dspnrpn-ds-{mode}", 500 + 300 * len(keys) + 1500, [(500 + 300 * i, "press", x) for i, x in enumerate(keys)],
                  snap=W)["snap"]
        r = e.run(f"dspnrpn-{mode}", 3000, [(500, "press", "SMPL"), (1000, "turn", "3:+8", 3, 100)], snap=D,
                  sends=[(300, w48s(5, 2))], midi_out=True)
        out[mode] = r["midi"]
        print(f"  {mode}: DIN {r['midi'][-24:].hex(' ')}")
    want = bytes([0xB0, 0x63, 0x01, 0xB0, 0x62, 0x0B, 0xB0, 0x06, 0x06, 0xB0, 0x26, 0x20])
    check("dspnrpn: NRPN 1:11 = 6 / 0x20 (index 6, bank C in the LSB)", want in out["nrpn"], out["nrpn"].hex(" ")[-120:])
    cc = [(out["cc"][i + 1], out["cc"][i + 2]) for i in range(len(out["cc"]) - 2) if out["cc"][i] == 0xB0]
    check("dspnrpn: CC mode: a CC with the index alone (6)", any(v == 6 for _, v in cc), cc[-4:])


def t_upsrc(e):
    """1046, UP + SRC: the selected track's source list in one press. GRANULAR (the host draws): from FLTR, UP + SRC ->
    the SRC page (stock's: SRC reaches it), and the list opens on knob A once the view shows the host's frame (4A 0 1
    <P1 = 5 . F> 0, the word unmoved); knob A's turns then go to the host (32 0). DSP SAMPLE: stock gets SMPL instead,
    the list opens on knob D (4A with P11 = 5 . C, the view on over the SMPL page: 29 1). No drawing host: no list (the
    SRC page as SRC alone). A held trig: UP + SRC is not taken (seq mode's lock key; here GRID REC on a stock track:
    stock's SRC)."""
    v0 = 5 << 7 | 0x50
    sn = machine(e, "gr", True)
    r = e.run("upsrc", 3000, [(500, "press", "FLTR"), (900, "press", "UP", 300), (1000, "press", "SRC"),
                              (2000, "turn", "0:+8", 2, 100)], snap=sn, answer=True, sends=[(300, w48(5, 5))])
    en = evs(r, "enc")
    print(f"  gr: 4A {lsev(r)}; turns {[(x['enc'], x['delta']) for x in en]}; word {e.word0(r['snap'][0]):#06x}")
    check("upsrc: GRANULAR, UP + SRC -> the list (4A on, P1 = 5 . F, why 0), the word unmoved",
          lsev(r)[:1] == [(1, v0, 0)] and e.word0(r["snap"][0]) == 0x05a0, (lsev(r), hex(e.word0(r["snap"][0]))))
    check("upsrc: knob A then the list's (32 0 to the host)", bool(en) and all(x["enc"] == 0 for x in en), en)
    r = e.run("upsrc-nohost", 2500, [(500, "press", "FLTR"), (900, "press", "UP", 300), (1000, "press", "SRC")],
              snap=machine(e, "gr"), sends=[(300, w48(5, 5))])
    check("upsrc: no frame from the host: no list", not lsev(r), lsev(r))
    ds = machine(e, "ds", True)
    r = e.run("upsrc-ds", 3000, [(900, "press", "UP", 300), (1000, "press", "SRC")], snap=ds, answer=True,
              sends=[(300, w48s(5, 2))])
    v29 = [(x["track"], x["on"]) for x in evs(r, "v29")]
    print(f"  ds: 4A {lsev(r)}; 29 {v29}")
    check("upsrc: DSP SAMPLE, UP + SRC -> the SMPL page and the list on SMP (4A on, P11 = 5 . C), the view on for it",
          lsev(r)[:1] == [(1, 5 << 7 | 0x20, 0)] and (0, 1) in v29, (lsev(r), v29))
    r = e.run("upsrc-trig", 2500, [(500, "press", "FLTR"), (700, "press", "RECORD"), (800, "press", "T1", 600),
                                   (900, "press", "UP", 300), (1000, "press", "SRC")], snap=sn, answer=True,
              sends=[(300, w48(5, 5))])
    check("upsrc: a trig held (GRID REC, a stock track: SRC its lock page): UP + SRC is stock's SRC, no list",
          not lsev(r), lsev(r))


# 1048: POLY CONFIG, the track menu's last item (FUNC + CHRO; TRIGS SETUP, PAD SCALE, RELOAD TRACK, SAVE TRACK, U1..U5,
# POLY CONFIG [measured]). The menu opens on its first item; nine DOWNs reach the tenth.
VT_TRACKMENU, VT_POPUP = "401ec0fc", "401d6e18"
TO_POLY = [(1000, "press", "FUNC", 300), (1050, "press", "CHRO")] + [(1600 + 200 * i, "press", "DOWN") for i in range(9)]
PM = ("owed", "adds", "picks", "opens", "hints", "nohost", "notrack")


def pm(e, r):
    b = e.peek(r["snap"][0], e.sym("pm"), 4 * len(PM))
    return {k: int.from_bytes(b[4 * i:4 * i + 4], "big") for i, k in enumerate(PM)}


def checker():
    fb = bytearray(1024)
    for x in range(128):
        for y in range(64):
            if (x // 8 + y // 8) & 1:
                fb[(7 - y // 8) + 8 * x] |= 1 << (y % 8)
    return fb


def t_polymenu(e):
    """1048: POLY CONFIG in the track menu. With a host that has drawn (a frame committed, the page closed): FUNC + CHRO,
    DOWN x 9, YES -> 30 0x20 1 0 (the page opens on BD's POLY CONFIG), the menu gone, the host's frame on the glass; the
    item was added once at boot. With TRK + SD selecting SD first: 30 0x21. With the page open (TRK + YES) the menu steps
    it aside (1042), YES on POLY CONFIG sends the 30 again (0x20, no leave) and the host's frame is back. Without a
    host that drew: no 30, the NO SIDECAR popup over the menu, pm.nohost 1; a frame drawn before the port's hello does
    not count (a host that has drawn on this connection)."""
    import protocol as P
    fb = checker()
    frame = P.rui_rect(5, 0, 0, 16, 8, bytes(fb)) + P.rui_commit(5)
    top = lambda x: e.peek(x["snap"][0], e.sym("sv") + 88, 4).hex()   # noqa: E731
    yes = [(3500, "press", "YES")]
    frame2 = P.rui_rect(6, 0, 0, 16, 8, bytes(fb)) + P.rui_commit(6)
    a = e.run("poly-menu", 4300, TO_POLY + yes, sends=[(800, frame), (3900, frame2)])   # (the real host draws after the 30)
    m = [(x["page"], x["on"], x["reason"]) for x in evs(a, "mode")]
    s = pm(e, a)
    print(f"  menu: 30s {m}, top {top(a)}, pm {s}")
    check("polymenu: POLY CONFIG's YES -> 30 0x20 1 0 (BD), once", m == [(0x20, 1, 0)], m)
    check("polymenu: the item added once at boot; one pick, one open", s["adds"] == 1 and s["picks"] == 1 and
          s["opens"] == 1 and not s["nohost"], s)
    check("polymenu: the menu closed (TrackMenuView no longer on top), the host's frame on the glass",
          top(a) != VT_TRACKMENU and a["oled"] == bytes(fb), (top(a), S.diff(a["oled"], bytes(fb))))
    b = e.run("poly-menu-sd", 4300, [(600, "press", "TRK", 250), (700, "press", "SD")] + TO_POLY + yes,
              sends=[(800, frame)])
    m = [(x["page"], x["on"], x["reason"]) for x in evs(b, "mode")]
    check("polymenu: SD selected (TRK + SD): 30 0x21 1 0", m == [(0x21, 1, 0)], m)
    opened = [(600, "press", "TRK", 200), (700, "press", "YES")]   # (after the port's hello, ~0.5 s)
    mask = P.rui_mask(encs=range(8), keys=HOST_KEYS)   # the real host's mask (1042's popups)
    later = [(x[0] + 1000,) + tuple(x[1:]) for x in TO_POLY + yes]   # (the mask on the Rytm before FUNC + CHRO)
    c = e.run("poly-menu-aside", 5300, opened + later, sends=[(850, mask), (900, frame)])
    m = [(x["page"], x["on"], x["reason"]) for x in evs(c, "mode")]
    s = pm(e, c)
    print(f"  aside: 30s {m}, pm {s}")
    check("polymenu: the page open, the menu over it: YES -> the 30 again (0x20), no leave", m == [(0, 1, 0), (0x20, 1, 0)]
          and s["hints"] == 1 and not s["opens"], (m, s))
    check("polymenu: the menu gone, the host's frame back", c["oled"] == bytes(fb) and top(c) != VT_TRACKMENU,
          (top(c), S.diff(c["oled"], bytes(fb))))
    d = e.run("poly-menu-nohost", 4300, TO_POLY + yes)
    m = [(x["page"], x["on"], x["reason"]) for x in evs(d, "mode")]
    s = pm(e, d)
    print(f"  no host: 30s {m}, top {top(d)}, pm {s}")
    check("polymenu: no host that drew: no 30, the popup (NO SIDECAR), nohost 1", not m and s["nohost"] == 1 and
          not s["owed"] and top(d) in (VT_POPUP, VT_TRACKMENU), (m, s, top(d)))
    f = e.run("poly-menu-early", 4300, TO_POLY + yes, sends=[(200, frame)])
    check("polymenu: a frame only before the hello: NO SIDECAR (nohost 1, no 30)",
          not evs(f, "mode") and pm(e, f)["nohost"] == 1, (evs(f, "mode"), pm(e, f)))
    ref = e.run("poly-menu-nohost-ref", 4300, TO_POLY)
    check("polymenu: no host: the screen is not the menu's alone (the popup over it)", d["oled"] != ref["oled"])


TESTS = dict(knob=t_knob, range=t_range, text=t_text, lock=t_lock, list=t_list, browse=t_browse, listlock=t_listlock, upt=t_upt,
             nrpn=t_nrpn, scale=t_scale, popups=t_popups, banka=t_banka, tbldef=t_tbldef,
             dspknob=t_dspknob, dsplist=t_dsplist, dspbrowse=t_dspbrowse, dsptext=t_dsptext, dsplock=t_dsplock,
             dspold=t_dspold, dsplistlock=t_dsplistlock, dspoldhost=t_dspoldhost,
             dspnrpn=t_dspnrpn, upsrc=t_upsrc, polymenu=t_polymenu)


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
    print("ALL PASS" if not S.FAILS else f"FAILED: {S.FAILS}")
    sys.exit(1 if S.FAILS else 0)


if __name__ == "__main__":
    main()
