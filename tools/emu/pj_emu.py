#!/usr/bin/env python3
"""Emulator tests of 0026's project slot reports (1052, 4B; design.md "1052") in rytm-emu.

    .venv/bin/python tools/emu/pj_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a build with 0026 (rui) whose base tools/emu/us_base.sh TAG made (its card: PRESETS in slots 1 and 2, slot 1
active). Each test drives the Rytm's project manager from the base snapshot with the panel sequences of the research
(rytm-teensy docs/superpowers/specs/2026-10-26-project-slot-identity-research.md, its tools/proj_ops.sh: first key at
snapshot + 100 M, keys 50 M apart, FUNC + key with FUNC held 80 M; 200 M instructions = 1 emulated second) on a clone
of the base card, with a host on the Overbridge link (--usb-host --usb-midi-real: the firmware's own USB MIDI sender)
that keeps every SysEx the Rytm sends, and checks the 4B messages the host saw (and, for the slot effects, the card's
slot headers after the run). DTEMU_STRICT=1 (the interpreter) as the other suites.
Firmware-derived files (snapshots, card clones) stay in build/emu/TAG (git-ignored) and the system temp dir.
RYTM_EMU: rytm-emu's checkout (default beside this one, rytm-emu-seqp2).
"""
import json
import re
import os
import socket
import struct
import subprocess
import sys
import tempfile
import threading
import time

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EMU = os.environ.get("RYTM_EMU", os.path.join(os.path.dirname(ROOT), "rytm-emu-seqp2"))
DTBOOT = os.path.join(EMU, "target/release/dtboot")
HELLO_MIDI, HELLO_NO_R, HELLO_VOICES = 1, 2, 4
OPS = {0: "ACTIVE", 1: "SAVE", 2: "PASTE", 3: "CLEAR", 4: "DELETE", 5: "RENAME", 6: "LOST", 7: "WRITE", 8: "LIST",
       9: "LIST_END", 10: "LOAD"}
KOPS = {1: "KSAVE", 2: "KRELOAD", 3: "KRESTORE", 4: "KRELOAD_ALL"}   # 1052d: 4C 01 <op> <kit> <src> (kits 1-based)
SLOT0 = 0x10000000   # slot n's 2 MB at SLOT0 + 0x200000 * (n - 1) on the card [measured, the research]

FAILS = []


def check(name, ok, detail=""):
    print(f"  {'PASS' if ok else 'FAIL'}  {name}" + (f"   [{detail}]" if detail else ""), flush=True)
    if not ok:
        FAILS.append(name)


# ---- the research's panel sequences (proj_ops.sh), as tokens
def dn(n):
    return [f"DOWN*{n - 1}"] if n > 1 else []


HOME = ["NO*6", "GLOBAL", "UP*9", "YES"]                  # -> PROJECT (LOAD PROJECT / SAVE PROJECT AS / MANAGE)
MANAGE = HOME + ["DOWN*2", "YES", "F+UP*16"]             # -> MANAGE PROJECTS, the cursor on 001
RTOP = ["RIGHT", "UP*7"]                                 # the slot's menu, the cursor on its first item


def seq(op, a=1, b=1):
    return {
        "saveas": HOME + ["UP*2", "DOWN", "YES", "F+UP*16"] + dn(a) + ["YES", "w:100", "YES", "w:500"],
        "load": HOME + ["UP*2", "YES", "F+UP*16"] + dn(a) + ["YES", "w:100", "NO", "w:100", "YES", "w:1200"],
        "loadsave": HOME + ["UP*2", "YES", "F+UP*16"] + dn(a) + ["YES", "w:100", "YES", "w:1200"],
        "createnew": HOME + ["UP*2", "YES", "F+DOWN*16", "YES", "w:100", "NO", "w:100", "YES", "w:1200"],
        "saveto": MANAGE + dn(a) + RTOP + ["DOWN*4", "YES", "w:100", "YES", "w:100", "YES", "w:600"],
        "saveto_empty": MANAGE + dn(a) + RTOP + ["DOWN", "YES", "w:100", "YES", "w:600"],
        "rename": MANAGE + dn(a) + RTOP + ["DOWN*2", "YES", "w:50", "UP", "YES", "w:300"],
        "copypaste": MANAGE + dn(a) + ["F+RECORD", "F+UP*16"] + dn(b) + ["F+STOP", "w:100", "YES", "w:500"],
        "clear": MANAGE + dn(a) + RTOP + ["YES", "w:100", "YES", "w:500"],
        "delete": MANAGE + dn(a) + RTOP + ["DOWN", "YES", "w:100", "YES", "w:500"],
        "init": MANAGE + dn(a) + RTOP + ["YES", "w:100", "YES", "w:600"],
    }[op]


def presses(tokens, t):
    """tokens -> dtboot --press arguments from clock t (M instructions); returns (args, the clock after them)."""
    p = []
    for tok in tokens:
        if tok.startswith("w:"):
            t += int(tok[2:])
            continue
        n = 1
        if "*" in tok:
            tok, n = tok.split("*")
            n = int(n)
        for _ in range(n):
            if "+" in tok:   # HOLD+KEY: HOLD held 80 M, KEY pressed 20 M in (F = FUNC)
                hold, key = tok.split("+", 1)
                p += ["--press", f"{'FUNC' if hold == 'F' else hold}@{t}M:80M", "--press", f"{key}@{t + 20}M"]
                t += 130
            else:
                p += ["--press", f"{tok}@{t}M"]
                t += 50
    return p, t


# ---- the host: the Overbridge link's MIDI pair, every SysEx kept with the time it came
class Host(threading.Thread):
    def __init__(self, port):
        super().__init__(daemon=True)
        self.port, self.msgs, self.stop = port, [], False

    def run(self):
        t0 = time.time()
        while True:
            try:
                s = socket.create_connection(("127.0.0.1", self.port), timeout=1)
                break
            except OSError:
                if time.time() - t0 > 60 or self.stop:
                    return
                time.sleep(0.2)
        s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        s.settimeout(0.2)
        s.sendall(bytes([ord("H"), 1, HELLO_MIDI | HELLO_NO_R | HELLO_VOICES]))
        buf, midi = b"", b""
        while not self.stop:
            try:
                d = s.recv(65536)
                if not d:
                    break
                buf += d
            except socket.timeout:
                continue
            except OSError:
                break
            while buf:
                k = buf[0:1]
                if k == b"N" and len(buf) >= 5:
                    n = struct.unpack("<I", buf[1:5])[0]
                    buf = buf[5:]
                    s.sendall(b"a" + struct.pack("<I", n) + bytes(16 * n))
                elif k == b"H" and len(buf) >= 3:
                    buf = buf[3:]
                elif k == b"M" and len(buf) >= 3 and len(buf) >= 3 + struct.unpack("<H", buf[1:3])[0]:
                    n = struct.unpack("<H", buf[1:3])[0]
                    midi += buf[3:3 + n]
                    buf = buf[3 + n:]
                    while b"\xf0" in midi and b"\xf7" in midi[midi.index(b"\xf0"):]:
                        i = midi.index(b"\xf0")
                        j = midi.index(b"\xf7", i)
                        self.msgs.append(midi[i:j + 1])
                        midi = midi[j + 1:]
                elif k == b"T" and len(buf) >= 4:
                    buf = buf[4:]
                elif k == b"P" and len(buf) >= 10:
                    buf = buf[10:]
                elif k == b"R" and len(buf) >= 5 and len(buf) >= 5 + 48 * struct.unpack("<I", buf[1:5])[0]:
                    buf = buf[5 + 48 * struct.unpack("<I", buf[1:5])[0]:]
                elif k in (b"N", b"H", b"M", b"T", b"P", b"R"):
                    break
                else:
                    return
        s.close()


def pj_msgs(msgs):
    """The 4B 01 messages -> (op name, a, b) / ('ACTIVE', slot, name); a 35 hello -> ('HELLO', caps)."""
    r = []
    for m in msgs:
        if len(m) >= 10 and m[1:4] == b"\x7d\x52\x54" and m[4] == 0x35:
            r.append(("HELLO", m[8]))
        if len(m) == 12 and m[1:4] == b"\x7d\x52\x54" and m[4] == 0x4C and m[5] == 1:   # 1052d: the kit reports
            r.append((KOPS.get(m[6], f"kop{m[6]}"), m[7] << 7 | m[8], m[9] << 7 | m[10]))
            continue
        if len(m) < 10 or m[1:4] != b"\x7d\x52\x54" or m[4] != 0x4B or m[5] != 1:
            continue
        op = m[6]
        if op == 0:
            r.append(("ACTIVE", m[7] << 7 | m[8], m[9:-1].decode("ascii", "replace")))
        elif op == 8:   # 1052b LIST: <first> <n> {<occ> <name 15>} x n
            first, n = m[7] << 7 | m[8], m[9]
            for i in range(n):
                e = m[10 + 16 * i:26 + 16 * i]
                r.append(("SLOT", first + i, e[1:].split(b"\0")[0].decode("ascii", "replace") if e[0] else None))
        elif len(m) == 12:
            r.append((OPS.get(op, f"op{op}"), m[7] << 7 | m[8], m[9] << 7 | m[10]))
        else:
            r.append(("BAD", m.hex(" ")))
    return r


def slots(card):
    """The card's occupied slots: {n: name} [the research: header BEEFBACE, the name at +8]."""
    out = {}
    with open(card, "rb") as f:
        for n in range(1, 129):
            f.seek(SLOT0 + 0x200000 * (n - 1))
            h = f.read(24)
            if h[:4] == bytes.fromhex("beefbace"):
                out[n] = h[8:24].split(b"\0")[0].decode("ascii", "replace")
    return out


class Emu:
    def __init__(self, tag):
        self.tag = tag
        self.fw = f"fw/AR173_us_{tag}.syx"
        self.card = os.path.join(EMU, f"sections/us_{tag}.img")
        self.snap = os.path.join(EMU, f"sections/us_{tag}.snap")
        self.clock = json.load(open(os.path.join(EMU, f"sections/us_{tag}.json")))["clock"]
        self.out = os.path.join(os.environ.get("RYTM_OUT_ROOT") or os.path.join(ROOT, "build", "emu"), tag)
        os.makedirs(self.out, exist_ok=True)

    def run(self, name, tokens, tail=600, card=None, snap=None, clock=None, host=True, counts=()):
        """The tokens from snap (default the base) on a clone of card; returns (the host's 4B list, the card clone)."""
        s = socket.socket()
        s.bind(("127.0.0.1", 0))
        port = s.getsockname()[1]
        s.close()
        start = clock if clock is not None else self.clock
        p, t = presses(tokens, start + 100)
        end = t + tail
        tmp = tempfile.mkdtemp(prefix=f"pj_{name}_")
        img = os.path.join(tmp, "card.img")
        subprocess.run(["cp", "-c", card or self.card, img], check=True)
        save = os.path.join(self.out, f"pj_{name}.snap")
        cmd = [DTBOOT, self.fw, "--load", snap or self.snap, "--card", img, "--card-save", "--instr", f"{end - start}M",
               "--every", "100000M"] + (["--usb-host", "--usb-midi-real", "--ob-link", f"127.0.0.1:{port}"] if host else []) + \
              ["--save", save] + p
        for c in counts:   # PCs visited (dtboot --count): the last status line's counts -> self.counts
            cmd += ["--count", f"{c:x}"]
        h = Host(port)
        if host:
            h.start()
        env = dict(os.environ, DTEMU_STRICT="1")
        if os.environ.get("PJ_PNG"):   # the screen after each key (debugging a sequence): build/emu/TAG/pj_NAME/
            d = os.path.join(self.out, f"pj_{name}")
            os.makedirs(d, exist_ok=True)
            env.update(DTBOOT_STEPS="1", DTBOOT_PNG_DIR=d, DTBOOT_END_PNG=os.path.join(d, "zz_end.png"))
        r = subprocess.run(cmd, cwd=EMU, env=env, capture_output=True, text=True)
        time.sleep(0.5)
        h.stop = True
        if host:
            h.join(timeout=5)
        out = r.stdout + r.stderr
        self.counts = {}
        for m in re.finditer(r"^\s*\d+M pc=.*$", out, re.M):
            self.counts = dict((int(a, 16), int(n)) for a, n in re.findall(r"([0-9a-f]{8}):(\d+)", m.group(0)))
        open(os.path.join(self.out, f"pj_{name}.dt.txt"), "w").write(" ".join(cmd) + "\n" + out)
        fault = "FAULT" in out or "strict:" in out or r.returncode != 0
        check(f"{name}: dtboot ran clean (strict, no fault)", not fault, "" if not fault else f"rc {r.returncode}")
        got = pj_msgs(h.msgs)
        open(os.path.join(self.out, f"pj_{name}.msgs.txt"), "w").write("\n".join(map(str, got)) + "\n")
        return got, img, save, end


def events(got):   # the slot events (not ACTIVE, the hello, the LIST, nor LOAD - checked on their own)
    return [g for g in got if g[0] not in ("ACTIVE", "HELLO", "SLOT", "LIST_END", "LOAD")]


def loads(got):
    return [g[2] for g in got if g[0] == "LOAD"]


def listed(got):
    """the last complete LIST: {slot: name} of the occupied slots, and its END count (None: no LIST)"""
    out, cur = None, {}
    for g in got:
        if g[0] == "SLOT" and g[2] is not None:
            cur[g[1]] = g[2]
        elif g[0] == "LIST_END":
            out, cur = (cur, g[1]), {}
    return out


def actives(got):
    return [g for g in got if g[0] == "ACTIVE"]


# ---- the tests
def t_hello(e):
    """The hello's caps carry bit 2, an ACTIVE follows it (slot 1, PRESETS), no event without a panel action."""
    got, img, _, _ = e.run("hello", ["w:400"])
    hellos = [g for g in got if g[0] == "HELLO"]
    check("hello: a 35 with caps 7 (36, 16 label tables, 4B)", hellos and all(g[1] == 7 for g in hellos), hellos)
    a = actives(got)
    check("hello: ACTIVE slot 1 PRESETS after it", a[:1] == [("ACTIVE", 1, "PRESETS")], a[:2])
    i_h = next((i for i, g in enumerate(got) if g[0] == "HELLO"), None)
    i_a = next((i for i, g in enumerate(got) if g[0] == "ACTIVE"), None)
    check("hello: the ACTIVE comes after the hello", i_h is not None and i_a is not None and i_a > i_h, got[:4])
    check("hello: no event", not events(got), events(got))
    check("hello: the card's slots as the base (PRESETS 1, 2)", slots(img) == {1: "PRESETS", 2: "PRESETS"}, slots(img))
    li = listed(got)
    check("hello: a LIST after it = the card's slots (1052b), END count 2", li == ({1: "PRESETS", 2: "PRESETS"}, 2), li)
    i_a = next((i for i, g in enumerate(got) if g[0] == "ACTIVE"), 99)
    i_l = next((i for i, g in enumerate(got) if g[0] == "SLOT"), -1)
    check("hello: the LIST after the ACTIVE", i_l > i_a, (i_a, i_l))
    whole = True   # each END follows slots 1..128 in order (a list a newer hello restarted is left out before it)
    for i, g in enumerate(got):
        if g[0] == "LIST_END":
            sl = [x[1] for x in got[:i] if x[0] == "SLOT"][-128:]
            whole = whole and sl == list(range(1, 129))
    check("hello: each LIST END follows slots 1..128", whole)
    ends = [g for g in got if g[0] == "LIST_END"]
    check("hello: each LIST sent twice (1052c: the host acts on two that agree)", len(ends) >= 2 and len(ends) % 2 == 0, ends)


def t_saveas(e):
    """SAVE PROJECT AS slot 4: SAVE(1 -> 4) before the ACTIVE(4)."""
    got, img, _, _ = e.run("saveas", seq("saveas", 4))
    ev = events(got)
    check("saveas: one event, SAVE 1 -> 4", ev == [("SAVE", 1, 4)], ev)
    a = actives(got)
    check("saveas: ACTIVE 1 then ACTIVE 4 PRESETS", a and a[0][1] == 1 and a[-1] == ("ACTIVE", 4, "PRESETS"), a)
    i_s = got.index(("SAVE", 1, 4)) if ("SAVE", 1, 4) in got else -1
    i_a = next((i for i, g in enumerate(got) if g[:2] == ("ACTIVE", 4)), -1)
    check("saveas: the SAVE before the ACTIVE 4", 0 <= i_s < i_a, (i_s, i_a))
    check("saveas: the card has slot 4", slots(img).get(4) == "PRESETS", slots(img))


def t_saveto(e):
    """MANAGE > slot 2 > SAVE TO (occupied, OVERWRITE): SAVE(1 -> 2), then ACTIVE(2)."""
    got, img, _, _ = e.run("saveto", seq("saveto", 2))
    ev = events(got)
    check("saveto: one event, SAVE 1 -> 2", ev == [("SAVE", 1, 2)], ev)
    a = actives(got)
    check("saveto: ACTIVE 2 at the end", a and a[-1][:2] == ("ACTIVE", 2), a)


def t_saveto_empty(e):
    """MANAGE > slot 5 (empty) > SAVE TO: SAVE(1 -> 5), ACTIVE(5); the card's slot 5 written."""
    got, img, _, _ = e.run("saveto_empty", seq("saveto_empty", 5))
    ev = events(got)
    check("saveto_empty: one event, SAVE 1 -> 5", ev == [("SAVE", 1, 5)], ev)
    a = actives(got)
    check("saveto_empty: ACTIVE 5 at the end", a and a[-1][:2] == ("ACTIVE", 5), a)
    check("saveto_empty: the card has slot 5", 5 in slots(img), slots(img))


def t_copypaste(e):
    """MANAGE: slot 1 COPY (FUNC + REC), slot 3 PASTE (FUNC + STOP, YES): PASTE(1 -> 3); the active stays 1."""
    got, img, _, _ = e.run("copypaste", seq("copypaste", 1, 3))
    ev = events(got)
    check("copypaste: one event, PASTE 1 -> 3", ev == [("PASTE", 1, 3)], ev)
    a = actives(got)
    check("copypaste: the active stays slot 1", a and all(x[1] == 1 for x in a), a)
    check("copypaste: the card's slot 3 = PRESETS", slots(img).get(3) == "PRESETS", slots(img))


def t_clear(e):
    """MANAGE > slot 2 > CLEAR: CLEAR(2); the card's slot 2 a NEW PROJECT; the active stays 1."""
    got, img, _, _ = e.run("clear", seq("clear", 2))
    ev = events(got)
    check("clear: one event, CLEAR 2", ev == [("CLEAR", 0, 2)], ev)
    a = actives(got)
    check("clear: the active stays slot 1 PRESETS", a and all(x[1:] == (1, "PRESETS") for x in a), a)
    check("clear: the card's slot 2 changed", slots(img).get(2) != "PRESETS", slots(img))


def loaded2(e):
    """The base with slot 2 loaded (the base's slot 1 is write protected: the Rytm refuses CLEAR, RENAME and SAVE on it
    [measured: WRITE PROTECTED]): (card, snapshot, clock), run once."""
    if not hasattr(e, "l2"):
        got, img, snap, end = e.run("loaded2", seq("load", 2))
        check("loaded2: ACTIVE 2 at the end", actives(got)[-1:] == [("ACTIVE", 2, "PRESETS")], actives(got)[-1:])
        e.l2 = (img, snap, end)
    return e.l2


def t_locked(e):
    """MANAGE > slot 1 (write protected in the base) > CLEAR: the Rytm refuses, no event."""
    got, img, _, _ = e.run("locked", seq("clear", 1))
    check("locked: no event (WRITE PROTECTED)", not events(got), events(got))
    check("locked: the card's slot 1 kept", slots(img).get(1) == "PRESETS", slots(img))


def t_clearactive(e):
    """Slot 2 loaded; MANAGE > slot 2 (the active) > CLEAR: CLEAR(2); the active report stays 2 PRESETS (the RAM project
    kept), the card's slot 2 a new project."""
    img0, snap0, clock0 = loaded2(e)
    got, img, _, _ = e.run("clearactive", seq("clear", 2), card=img0, snap=snap0, clock=clock0)
    ev = events(got)
    check("clearactive: one event, CLEAR 2", ev == [("CLEAR", 0, 2)], ev)
    a = actives(got)
    check("clearactive: the active stays slot 2 PRESETS", a and all(x[1:] == (2, "PRESETS") for x in a), a)
    check("clearactive: the card's slot 2 changed", slots(img).get(2) != "PRESETS", slots(img))


def t_delete(e):
    """MANAGE > slot 2 > DELETE: DELETE(2); the card's slot 2 empty."""
    got, img, _, _ = e.run("delete", seq("delete", 2))
    ev = events(got)
    check("delete: one event, DELETE 2", ev == [("DELETE", 0, 2)], ev)
    check("delete: the card's slot 2 empty", 2 not in slots(img), slots(img))


def t_init(e):
    """MANAGE > slot 6 (empty) > INIT NEW: CLEAR(6); the card's slot 6 a new project."""
    got, img, _, _ = e.run("init", seq("init", 6))
    ev = events(got)
    check("init: one event, CLEAR 6", ev == [("CLEAR", 0, 6)], ev)
    check("init: the card's slot 6 occupied", 6 in slots(img), slots(img))


def t_rename(e):
    """MANAGE > slot 2 > RENAME (first character + 1): RENAME(2); the active stays 1 PRESETS."""
    got, img, _, _ = e.run("rename", seq("rename", 2))
    ev = events(got)
    check("rename: one event, RENAME 2", ev == [("RENAME", 0, 2)], ev)
    check("rename: the card's slot 2 renamed", slots(img).get(2) not in (None, "PRESETS"), slots(img))
    a = actives(got)
    check("rename: the active stays slot 1 PRESETS", a and all(x[1:] == (1, "PRESETS") for x in a), a)


def t_renameactive(e):
    """Slot 2 loaded; MANAGE > slot 2 (the active) > RENAME: RENAME(2), then an ACTIVE 2 with the new name."""
    img0, snap0, clock0 = loaded2(e)
    got, img, _, _ = e.run("renameactive", seq("rename", 2), card=img0, snap=snap0, clock=clock0)
    ev = events(got)
    check("renameactive: one event, RENAME 2", ev == [("RENAME", 0, 2)], ev)
    a = actives(got)
    new = slots(img).get(2)
    check("renameactive: the last ACTIVE is slot 2 with the card's new name", new != "PRESETS" and a and
          a[-1] == ("ACTIVE", 2, new), (a[-1:], new))


def t_load(e):
    """LOAD PROJECT, the 2nd entry (slot 2), NO (do not save first): no event, ACTIVE 2."""
    got, img, _, _ = e.run("load", seq("load", 2))
    check("load: no event", not events(got), events(got))
    a = actives(got)
    check("load: ACTIVE 1 then 2", a and a[0][1] == 1 and a[-1] == ("ACTIVE", 2, "PRESETS"), a)


def t_loadsave(e):
    """Slot 2 loaded; LOAD PROJECT slot 1, saving the active first: SAVE(2 -> 2), then ACTIVE 1."""
    img0, snap0, clock0 = loaded2(e)
    got, img, _, _ = e.run("loadsave", seq("loadsave", 1), card=img0, snap=snap0, clock=clock0)
    ev = events(got)
    check("loadsave: one event, SAVE 2 -> 2", ev == [("SAVE", 2, 2)], ev)
    a = actives(got)
    check("loadsave: ACTIVE 1 at the end", a and a[-1][:2] == ("ACTIVE", 1), a[-1:])


def t_createnew(e):
    """LOAD PROJECT > CREATE NEW: no event, ACTIVE 0 (no slot); then SAVE AS slot 5: SAVE(0 -> 5), ACTIVE 5."""
    got, img, snap, end = e.run("createnew", seq("createnew"))
    check("createnew: no event", not events(got), events(got))
    a = actives(got)
    check("createnew: ACTIVE 0 (no slot) at the end", a and a[-1][1] == 0, a)
    got2, img2, _, _ = e.run("createnew_saveas", seq("saveas", 5), card=img, snap=snap, clock=end)
    ev = events(got2)
    check("createnew_saveas: one event, SAVE 0 -> 5", ev == [("SAVE", 0, 5)], ev)
    a2 = actives(got2)
    check("createnew_saveas: ACTIVE 5 at the end", a2 and a2[-1][:2] == ("ACTIVE", 5), a2)


def t_reloadactive(e):
    """1052b: slot 2 loaded; MANAGE: slot 1 COPY, PASTE onto slot 2 (the active one): PASTE 1 -> 2; then LOAD slot 2 again
    (the same slot, the same name): LOAD 2 - the host acts on the paste at once (the active-slot setter's report)."""
    img0, snap0, clock0 = loaded2(e)
    got, img, snap, end = e.run("pasteactive", seq("copypaste", 1, 2), card=img0, snap=snap0, clock=clock0)
    check("pasteactive: PASTE 1 -> 2, no LOAD", events(got) == [("PASTE", 1, 2)] and not loads(got), (events(got), loads(got)))
    # (the active slot's LOAD asks only "ANY CHANGES WILL BE LOST. PROCEED?" - no "save first?" [measured])
    got2, _, _, _ = e.run("reloadactive", HOME + ["UP*2", "YES", "F+UP*16"] + dn(2) + ["YES", "w:100", "YES", "w:1200"],
                          card=img, snap=snap, clock=end)
    check("reloadactive: LOAD 2 (the same slot again), no other event", loads(got2) == [2] and not events(got2),
          (loads(got2), events(got2)))


def t_nohost(e):
    """1052b: CLEAR slot 2 and DELETE slot 2 with no host (no USB port): nothing kept in the ring; then a host connects:
    one LOST (the 2 events), then a LIST that shows the card as it is now - no stale CLEAR / DELETE replayed."""
    got, img, snap, end = e.run("nohost_ops", seq("clear", 2) + seq("delete", 2), host=False)
    check("nohost: the card's slot 2 empty", 2 not in slots(img), slots(img))
    got2, _, _, _ = e.run("nohost_connect", ["w:600"], card=img, snap=snap, clock=end)
    lost = [g for g in got2 if g[0] == "LOST"]
    check("nohost: one LOST of 2 at the connect", lost == [("LOST", 2, 0)], lost)
    check("nohost: no stale event", [g for g in events(got2) if g[0] != "LOST"] == [], events(got2))
    li = listed(got2)
    check("nohost: the LIST = the card now (slot 1 only)", li == ({1: "PRESETS"}, 1), li)


# the active-slot setter 0x400fa694's callers: the helper 0x400aecc0 (from these 9 jsr sites) and the boot's 0x400fb2d2
SETTER, HELPER = 0x400FA694, 0x400AECC0
SITES = (0x40094DFE, 0x400A2342, 0x400A3688, 0x400A377E, 0x400B077A, 0x400B0842, 0x400B1116, 0x400B3D6C, 0x400B405A)


def site_counts(e):
    return {f"{a:08x}": e.counts.get(a, 0) for a in SITES + (SETTER,) if e.counts.get(a, 0)}


def t_setters(e):
    """1052c: which of 0x400aecc0's call sites each panel operation drives (break-point counts), and the LOADs the host
    sees: a LOAD only from the load paths (a same-slot set that does not reload the project is filtered)."""
    cs = SITES + (SETTER, HELPER)
    runs = {}
    got, img, snap, end = e.run("set_load2", seq("load", 2), counts=cs)
    runs["load"] = (site_counts(e), loads(got))
    got, _, _, _ = e.run("set_saveas", seq("saveas", 4), counts=cs)
    runs["saveas"] = (site_counts(e), loads(got))
    got, _, _, _ = e.run("set_saveto", seq("saveto", 2), counts=cs)
    runs["saveto"] = (site_counts(e), loads(got))
    got, _, _, _ = e.run("set_createnew", seq("createnew"), counts=cs)
    runs["createnew"] = (site_counts(e), loads(got))
    got, _, _, _ = e.run("set_reload2", HOME + ["UP*2", "YES", "F+UP*16"] + dn(2) + ["YES", "w:100", "YES", "w:1200"],
                         card=img, snap=snap, clock=end, counts=cs)
    runs["reload_active"] = (site_counts(e), loads(got))
    got, _, _, _ = e.run("set_loadsave", seq("loadsave", 1), card=img, snap=snap, clock=end, counts=cs)
    runs["loadsave"] = (site_counts(e), loads(got))
    got, _, _, _ = e.run("set_fplay", MANAGE + dn(2) + ["F+PLAY", "w:100", "YES", "w:600"], card=img, snap=snap, clock=end,
                         counts=cs)
    runs["fplay_active"] = (site_counts(e), loads(got), events(got))
    got, _, _, _ = e.run("set_clearact", seq("clear", 2), card=img, snap=snap, clock=end, counts=cs)
    runs["clear_active"] = (site_counts(e), loads(got))
    for k, v in runs.items():
        print(f"    {k:14s} sites {v[0]}  LOADs {v[1]}" + (f"  events {v[2]}" if len(v) > 2 else ""), flush=True)
    check("setters: LOAD 2 for a load, LOAD 2 for the active slot loaded again", runs["load"][1] == [2] and
          runs["reload_active"][1] == [2], (runs["load"][1], runs["reload_active"][1]))
    check("setters: loadsave (save first, then LOAD 1): LOAD 1 only", runs["loadsave"][1] == [1], runs["loadsave"][1])
    check("setters: no LOAD from a save (SAVE AS, SAVE TO), CREATE NEW, CLEAR of the active slot",
          not runs["saveas"][1] and not runs["saveto"][1] and not runs["createnew"][1] and not runs["clear_active"][1],
          {k: runs[k][1] for k in ("saveas", "saveto", "createnew", "clear_active")})
    check("setters: FUNC + PLAY on the active slot: no LOAD (the RAM project stays)", not runs["fplay_active"][1],
          runs["fplay_active"])


# 1052d: the kit functions and their measured callers (break points): kit_save 0x400b119c (YES + KIT 0x400cd562, SAVE KIT
# 0x400dd69a), kit_reload 0x400af0d2 (NO + KIT 0x400cd4ae, the KIT menu's RELOAD 0x400dd5de), every kit 0x400b131a
KIT_FNS = (0x400B119C, 0x400AF0D2, 0x400B131A, 0x400CD562, 0x400DD69A, 0x400CD4AE, 0x400DD5DE)
KMENU = ["NO*4", "F+PLAYMODE", "w:200", "UP*3"]   # the KIT menu (FUNC + PLAY MODE), its top: RELOAD, LOAD, SAVE KIT ...


def kits(got):
    return [g for g in got if g[0].startswith("K")]


def t_kits(e):
    """1052d: 4C kit reports: YES + KIT and the KIT menu's SAVE KIT -> KSAVE <kit> <the active kit before> (to K002: KSAVE
    2 1, and K002 is then the active kit: a NO + KIT after it reloads 2); NO + KIT and the menu's RELOAD -> KRELOAD 1; the
    menu's RELOAD set to ALL (RIGHT) -> KRELOAD_ALL 1; a LOAD PROJECT sends no kit report; with no host a kit save is
    one LOST at the next connect (nothing stale)."""
    runs = {
        "yes_kit": (["NO*4", "YES+PLAYMODE", "w:400"], [("KSAVE", 1, 1)]),
        "save_kit": (KMENU + ["DOWN*2", "YES", "w:200", "YES", "w:200", "YES", "w:400"], [("KSAVE", 1, 1)]),
        "save_k2": (KMENU + ["DOWN*2", "YES", "w:200", "DOWN", "YES", "w:200", "YES", "w:400", "NO*3", "NO+PLAYMODE",
                             "w:400"], [("KSAVE", 2, 1), ("KRELOAD", 2, 0)]),
        "no_kit": (["NO*4", "NO+PLAYMODE", "w:400"], [("KRELOAD", 1, 0)]),
        "reload_menu": (KMENU + ["YES", "w:100", "YES", "w:400"], [("KRELOAD", 1, 0)]),
        "reload_all": (KMENU + ["RIGHT", "w:100", "YES", "w:100", "YES", "w:400"], [("KRELOAD_ALL", 1, 0)]),
        "load_project": (seq("load", 2), []),
    }
    for name, (tok, want) in runs.items():
        got, _, _, _ = e.run(f"kit_{name}", tok, counts=KIT_FNS)
        c = {f"{a:08x}": n for a, n in e.counts.items() if n}
        print(f"    {name:12s} {kits(got)}  sites {c}", flush=True)
        check(f"kits: {name}: {want}", kits(got) == want and not [g for g in got if g[0] == "BAD"], (kits(got), c))
    got, img, snap, end = e.run("kit_nohost", ["NO*4", "YES+PLAYMODE", "w:400"], host=False)
    got2, _, _, _ = e.run("kit_nohost_connect", ["w:600"], card=img, snap=snap, clock=end)
    check("kits: no host: the save is one LOST at the connect, no stale KSAVE", not kits(got2) and
          [g for g in got2 if g[0] == "LOST"] == [("LOST", 1, 0)], [g for g in got2 if g[0] in ("LOST",) or g[0][0] == "K"])


def t_lock(e):
    """MANAGE > slot 2 > TOGGLE (the lock): no event."""
    got, img, _, _ = e.run("lock", MANAGE + dn(2) + RTOP + ["DOWN*5", "YES", "w:300"])
    check("lock: no event", not events(got), events(got))


TESTS = dict(hello=t_hello, saveas=t_saveas, saveto=t_saveto, saveto_empty=t_saveto_empty, copypaste=t_copypaste,
             clear=t_clear, locked=t_locked, clearactive=t_clearactive, delete=t_delete, init=t_init, rename=t_rename,
             renameactive=t_renameactive, load=t_load, loadsave=t_loadsave, createnew=t_createnew, lock=t_lock,
             reloadactive=t_reloadactive, nohost=t_nohost, setters=t_setters, kits=t_kits)


def main():
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    e = Emu(sys.argv[1])
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    for n in names:
        print(f"== {n}", flush=True)
        TESTS[n](e)
    print(f"\n{'PASS' if not FAILS else 'FAIL'}: {len(FAILS)} failed" + (": " + ", ".join(FAILS) if FAILS else ""))
    sys.exit(1 if FAILS else 0)


if __name__ == "__main__":
    main()
