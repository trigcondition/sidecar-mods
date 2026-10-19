#!/usr/bin/env python3
"""Emulator tests of the user slots (0021-ext: machines 35..39 as U1..U5) in rytm-emu, without a Teensy:
the Teensy's messages (rytm-teensy sim/protocol.py) injected on the USB MIDI port, the Rytm's own
messages read back from its USB MIDI out, its memory with dtpeek, its screen as PNGs.

    .venv/bin/python tools/emu/us_emu.py TAG TEST [TEST ...]      exit 0 when every check passes
    .venv/bin/python tools/emu/us_emu.py TAG all                  every test in TESTS, in order

TAG: a build (build/Analog-Rytm_MKII_OS1.73_<TAG>.syx) with its base made by tools/emu/us_base.sh TAG.
TEST: one of the names in TESTS below. Screens go to build/emu/<TAG>/<test>-<n>.png (build/ is
git-ignored); the checks say which PNG shows what, so a reviewer can look. Key walks measured in
rytm-emu (tools/emu/us_ui.json, research R0). RYTM_EMU and RYTM_TEENSY: the two checkouts (defaults
below). Firmware-derived files stay in rytm-emu's git-ignored fw/ and sections/ and in build/.
"""
import atexit
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
EMU = os.environ.get("RYTM_EMU", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "rytm-emu"))
TEENSY = os.environ.get("RYTM_TEENSY", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "sidecar-firmware"))
sys.path.insert(0, os.path.join(TEENSY, "sim"))
import protocol as P   # noqa: E402

UI = json.load(open(os.path.join(ROOT, "tools", "emu", "us_ui.json")))
fails = []


def check(what, ok, detail=""):
    print(f"{'PASS' if ok else 'FAIL'}: {what}{(' - ' + detail) if detail else ''}", flush=True)
    if not ok:
        fails.append(what)


def sysex(b):
    """The F0 .. F7 messages in a USB MIDI out dump (raw bytes as rytm-emu writes them)."""
    out, i = [], 0
    while True:
        i = b.find(b"\xf0", i)
        j = b.find(b"\xf7", i + 1) if i >= 0 else -1
        if i < 0 or j < 0:
            return out
        out.append(b[i:j + 1])
        i = j + 1


OBJ = None   # build/emu/<tag>: the tag's objects, copied by us_base.sh (Emu sets it)


def sym(name, mod="0021-ext"):
    """A symbol's address in the tag's object of a mod (build/emu/<tag>/<mod>.elf, 0021's by default)."""
    r = subprocess.run(["m68k-elf-nm", os.path.join(OBJ, f"{mod}.elf")], capture_output=True, text=True,
                       check=True)
    for line in r.stdout.splitlines():
        f = line.split()
        if len(f) == 3 and f[2] == name:
            return int(f[0], 16)
    raise KeyError(name)


def ret_of_call(fn, target, mod="0021-ext"):
    """The return address of fn's call to target (the instruction after its jsr): a --count there counts the calls."""
    a = sym(fn, mod)
    r = subprocess.run(["m68k-elf-objdump", "-d", os.path.join(OBJ, f"{mod}.elf"), f"--start-address={a}",
                        f"--stop-address={a + 0x400}"], capture_output=True, text=True, check=True)
    lines = [x for x in r.stdout.splitlines() if re.match(r"^\s*[0-9a-f]+:\t", x)]
    for x, y in zip(lines, lines[1:]):
        if re.search(rf"\bjsr {target:x}\b", x):
            return int(y.split(":")[0], 16)
    raise KeyError(f"{fn} -> {target:#x}")


class Emu:
    """The base (us_base.sh) resumed with events: ("press", KEY[:HOLD]), ("turn", "ENC:DELTA" or ("ENC:DELTA", count,
    spacing M)), ("usb", bytes) at M instructions after the base's clock."""

    def __init__(self, tag):
        self.tag = tag
        self.fw = os.path.join(EMU, "fw", f"AR173_us_{tag}.syx")
        self.card = os.path.join(EMU, "sections", f"us_{tag}.img")
        self.snap = os.path.join(EMU, "sections", f"us_{tag}.snap")
        self.clock = json.load(open(os.path.join(EMU, "sections", f"us_{tag}.json")))["clock"]
        self.out = os.path.join(ROOT, "build", "emu", tag)
        os.makedirs(self.out, exist_ok=True)
        self.tmp = tempfile.mkdtemp()
        atexit.register(shutil.rmtree, self.tmp, True)
        self.log, self.sent, self.counts = "", [], {}
        self.strict = False   # t_strict: every run under DTEMU_STRICT=1, each checked for strict accesses
        # the build's params and objects as us_base.sh copied them with the base (sym() reads them)
        global OBJ
        OBJ = self.out
        man = os.path.join(self.out, "manifest.json")
        if not os.path.exists(man):
            sys.exit(f"no {man}: make the base with tools/emu/us_base.sh {tag} (right after building {tag})")
        self.params = json.load(open(man))["params"]

    def run(self, name, length, events=(), count=(), save=False, snap=None, start=None, extra=(), env=None, card=None, fw=None,
            cold=False):
        """length M instructions from the base (or from snap, whose clock is start); returns the saved
        snapshot (save) else None. After it: self.sent the Rytm's USB MIDI messages, self.counts the
        visits of each `count` address, build/emu/<tag>/<name>.png the screen."""
        start = (0 if cold else self.clock) if start is None else start
        cmd = [os.path.join(EMU, "target", "release", "dtboot"), fw or self.fw] + ([] if cold else ["--load", snap or self.snap]) + \
              ["--card", card or self.card, "--instr", f"{length}M", "--every", f"{length}M", "--usb-host", "--usb-midi-real"]
        for i, (at, kind, val) in enumerate(events):
            t = start + at
            if kind == "press":
                k, _, hold = val.partition(":")
                cmd += ["--press", f"{k}@{t}M" + (f":{hold}" if hold else "")]
            elif kind == "turn":   # val: "ENC:DELTA" or ("ENC:DELTA", count, spacing M)
                spec, n, gap = (val, 1, 4) if isinstance(val, str) else val
                cmd += ["--turn", f"{spec}@{t}Mx{n}/{gap}M"]
            else:
                f = os.path.join(self.tmp, f"{name}-{i}.syx")
                with open(f, "wb") as fh:
                    fh.write(val)
                cmd += ["--usb-midi-file", f"{f}@{t}M"]
        for a in count:
            cmd += ["--count", f"{a:x}"]
        out_snap = os.path.join(self.tmp, f"{name}.snap") if save else None
        if save:
            cmd += ["--save", out_snap]
        cmd += list(extra)
        usb = os.path.join(self.tmp, f"{name}.usb")
        e = dict(os.environ, DTBOOT_USB_OUT=usb, DTBOOT_END_PNG=os.path.join(self.out, f"{name}.png"), **(env or {}))
        if self.strict:
            e["DTEMU_STRICT"] = "1"
        r = subprocess.run(cmd, cwd=EMU, env=e, capture_output=True, text=True)
        self.log = r.stdout + r.stderr
        check(f"{name}: runs without a fault", "FAULT" not in self.log and r.returncode == 0,
              "" if r.returncode == 0 and "FAULT" not in self.log else self.log[-400:])
        if self.strict:
            bad = [line for line in self.log.splitlines() if line.startswith("strict:")]
            check(f"{name}: no strict access (DTEMU_STRICT=1)", not bad, "; ".join(bad[:3]))
        self.sent = sysex(open(usb, "rb").read()) if os.path.exists(usb) else []
        self.counts = {int(a, 16): int(n) for a, n in re.findall(r"\b([0-9a-f]{8}):(\d+)\b", self.log)}
        return out_snap

    def peek(self, snap, addr, n, fw=None):
        r = subprocess.run([os.path.join(EMU, "target", "release", "dtpeek"), snap, "mem", f"{addr:x}", str(n)], cwd=EMU,
                           env=dict(os.environ, DTEMU_FW=fw or self.fw), capture_output=True, text=True, check=True)
        return bytes(int(x, 16) for line in r.stdout.splitlines() for x in line.split(":", 1)[1].split())

    def cstr(self, snap, addr, n=16):
        return self.peek(snap, addr, n).split(b"\0")[0].decode("ascii", "replace")

    def u32(self, snap, addr):
        return int.from_bytes(self.peek(snap, addr, 4), "big")

    def asks(self):
        """The Rytm's 19 messages (decoded) in the last run."""
        return [P.decode_ask(m[5:-1]) for m in self.sent if len(m) > 5 and m[4] == P.ASK]


def walk_list(at, downs, confirm=True):
    """Events opening the machine list of the selected track, moving down, confirming."""
    ev, t = [], at
    for k in UI["list_open"]:
        ev.append((t, "press", k))
        t += UI["step_M"]
    for _ in range(downs):
        ev.append((t, "press", "DOWN"))
        t += UI["step_M"]
    if confirm:
        ev.append((t, "press", UI["list_confirm"]))
        t += UI["step_M"]
    return ev, t + UI["settle_M"]


def rec(r):
    return 0x401bf918 + 0x34 * r


def elek_sym(e, name):
    """An area mod's symbol from the build's manifest (elek symbols, "rytm-<mod>:<name>"); None when not built in."""
    m = json.load(open(os.path.join(e.out, "manifest.json")))
    return (m.get("elek") or {}).get("symbols", {}).get(name)


def desc(r):
    return 0x419a4888 + 84 * r


# ---------------------------------------------------------------------------- the tests
def t_base(e):
    """(P0.1) The base resumes: the main screen (PNG base), the twelve tracks' machines read back (stock ones)."""
    png = os.path.join(e.out, "base.png")
    if os.path.exists(png):
        os.remove(png)   # so the check below sees this run's screen
    s = e.run("base", 200, save=True)
    m = e.peek(s, 0x8000ea00, 12)
    check("base: the twelve tracks' machine bytes read back, track BD on a stock machine", len(m) == 12 and m[0] < 35, m.hex())
    ts, usb = e.peek(s, 0x407c2d32, 1), e.peek(s, 0x405c8e4c, 1)
    check("base: TRANSPORT SEND (0x407c2d32) and USB CONFIG (0x405c8e4c) both 01", ts == b"\x01" and usb == b"\x01",
          f"transport send {ts.hex()}, usb config {usb.hex()}")
    check("base: the end screen written (build/emu/<tag>/base.png)", os.path.exists(png), png)


def t_exciter(e):
    """(Task 2) The exciter's test is exact: dsp_excite runs on a DAISYSP voice (flag 0x10), not on PLAITS (0x00)."""
    ex = sym("dsp_excite")
    downs = UI["downs"]
    for name, n, want in (("DAISYSP", downs["daisysp"], True), ("PLAITS", downs["plaits"], False)):
        ev, t = walk_list(100, n)
        ev.append((t, "press", "BD"))
        e.run(f"exciter-{name}", t + 300, ev, count=[ex])
        trig = [m for m in e.sent if len(m) > 20 and m[4] == 0x04]
        flag = trig[-1][5] & 0x78 if trig else -1
        v = e.counts.get(ex, -1)
        check(f"exciter: {name} (flag {flag:#x}): dsp_excite {'runs' if want else 'does not run'}", (v > 0) == want and
              flag == (0x10 if want else 0x00), f"{v} visits")


def t_variants(e):
    """(Task 3) 0014's variants list BT IMPROVED only: machines 35..39 (the "2" variants) stay unlisted for the user slots."""
    s = e.run("variants", 10, save=True)
    m = e.peek(s, 0x401bf1c0, 12)   # {home track, voice mask} of machines 34..39
    v = e.params.get("0014-hidden-machines", {}).get("variants", 0)   # us1 1, hwus1 0 (BT IMPROVED unlisted)
    want = (bytes.fromhex("0402") if v else bytes(2)) + b"\xff" * 10   # 0021 lists 35..39 itself (home -1, every voice)
    check(f"variants: 34 BT IMPROVED {'04 02' if v else '00 00 (variants=0)'}, 35..39 ff ff (0021's user slots)", m == want,
          m.hex())
    f = e.peek(s, 0x401bf1d2, 2)    # 43 FUNC. GEN.
    check("variants: 43 FUNC. GEN. unlisted (funcgen=0)", f == b"\0\0", f.hex())


def t_takeover(e):
    """(Task 7) U1..U5 in the machine list (PNG takeover-list), U1 on track BD: machine 35, voice flag 0x50,
    knobs P1..P8 with no Teensy; DAISYSP's exciter does not run on U1 (flag 0x50 has bit 4: the exact compare)."""
    ev, t = walk_list(100, UI["downs"]["u1"] + 3, confirm=False)
    e.run("takeover-list", t, ev)
    ev, t = walk_list(100, UI["downs"]["u1"])
    ev.append((t, "press", "BD"))
    s = e.run("takeover-u1", t + 300, ev, count=[sym("dsp_excite")], save=True)
    check("takeover: track BD plays machine 35 (U1)", e.peek(s, 0x8000ea00, 1)[0] == 35)
    trig = [m for m in e.sent if len(m) > 20 and m[4] == 0x04]
    check("takeover: its trig report carries the voice flag 0x50", bool(trig) and trig[-1][5] & 0x78 == 0x50,
          trig[-1].hex() if trig else "none")
    check("takeover: DAISYSP's exciter does not run on U1 (the exact compare of Task 2)", e.counts.get(sym("dsp_excite"), 1) == 0)
    names = [e.cstr(s, e.u32(s, rec(334 + k) + 40), 8) for k in range(8)]
    check("takeover: U1's knobs are P1..P8 without a Teensy", names == [f"P{k + 1}" for k in range(8)], str(names))
    check("takeover: U1's names are USER 1 / U1", (e.cstr(s, sym("us_l1")), e.cstr(s, sym("us_s1"))) == ("USER 1", "U1"))
    check("takeover: the Rytm asks the Teensy (19 what 0) for the slots", any(a and a["what"] == 0 for a in e.asks()),
          str(e.asks()[:3]))
    # R11: a record's kind gates the setter - U1's SRC records keep machine 35 in +0, so a stock knob turn writes
    # the kit word (track BD's word 9, knob A: 0x41255933) and the project copy (0x4076592f)
    kit0, proj0 = e.peek(s, 0x41255933, 1)[0], e.peek(s, 0x4076592f, 1)[0]
    s2 = e.run("takeover-knob", 300, [(20, "turn", ("0:+5", 20, 8))], save=True, snap=s, start=e.clock + t + 300)
    kit1, proj1 = e.peek(s2, 0x41255933, 1)[0], e.peek(s2, 0x4076592f, 1)[0]
    check("takeover: knob A on U1 writes the kit word and the project copy (R11's kind gate)",
          kit1 != kit0 and proj1 == kit1, f"kit {kit0} -> {kit1}, project {proj0} -> {proj1} (PNG takeover-knob)")


# struct us_cache's en[8][16][8] (after us_head 36 B, 16 us_knob of 28 B, eknob[8], ecount[8]): the absolute symbol
# us_off_en, which ext.c asserts (_Static_assert) and exports


def t_enum(e):
    """(Task 7 review) An enum list's names not sent read ---: a 1B that starts a list (replace) clears the names a
    longer earlier list left, the value text copies at most 7 characters; under DTEMU_STRICT=1 (PNG enum-turn*)."""
    knobs = [dict(p=1, look="list", kind="enum", enum_count=12, long="Mode", short="MOD", default=110)]
    old = [f"OLD{i:02d}LONG" for i in range(12)]   # 9 characters each: the cache keeps 7
    new = [f"NEW{i}" for i in range(8)]            # 8 of the 12: entries 8..11 not sent
    ev = [(100, "usb", b"".join(P.meta_messages(1, 5, P.ST_READY, 0, "ENUMS", "ENM", "", knobs))),
          (300, "usb", b"".join(P.list_messages(1, 0, 5, old))),
          (500, "usb", b"".join(P.list_messages(1, 0, 5, new, total=12)))]
    ev2, t = walk_list(700, UI["downs"]["u1"])
    ev2.append((t + 300, "turn", ("0:+5", 4, 8)))   # the first three move nothing, the fourth one step (R4): zone 10 stays
    turn_dir = os.path.join(e.out, "enum-turn")
    os.makedirs(turn_dir, exist_ok=True)
    s = e.run("enum", t + 340, ev + ev2, save=True, env={"DTEMU_STRICT": "1", "DTBOOT_TURN_PNG": turn_dir})
    c = e.u32(s, sym("us"))
    US_EN = sym("us_off_en")
    eknob = e.peek(s, c + US_EN - 16, 16)
    check("enum: U1's cache holds P1's list (eknob 0, 12 names)", 0 in eknob[:8] and eknob[8 + eknob.index(0)] == 12,
          eknob.hex())
    en = c + US_EN + 128 * (eknob.index(0) if 0 in eknob[:8] else 0)
    got = [e.cstr(s, en + 8 * n, 8) for n in range(12)]
    check("enum: the second list replaced the first: NEW0..NEW7, entries 8..11 empty (not OLD08..OLD11)",
          got == new + [""] * 4, str(got))
    kw = e.peek(s, 0x41255933, 1)[0]
    check("enum: knob A in zone 10 of 12 (107..117: a name not sent), from P1's default 110", 107 <= kw <= 117, str(kw))
    print(f"  look at {turn_dir}/turn04.png: knob A reads --- (zone 10's value text) in place of MOD while it turns")


NP_KNOBS = [dict(p=1, look="list", kind="enum", role="preset", enum_count=4, long="Algorithm", short="ALG"),
            dict(p=2, look="dial", kind="number", long="X", short="X"),
            dict(p=3, look="centred", kind="bipolar", long="Y", short="Y"),
            dict(p=4, look="dial", kind="note", long="Root", short="ROT", default=60),
            dict(p=8, look="fader", kind="number", long="Level", short="LEV", min=10, max=120, default=100)]


def meta_events(at, slot_msgs, gap=200):
    """Each slot's 1A on its own, gap M apart (one slot is staged at a time)."""
    return [(at + gap * i, "usb", b"".join(m)) for i, m in enumerate(slot_msgs)], at + gap * len(slot_msgs)


def t_names(e):
    """(Task 8) The machine list's names per state: READY the name, MISSING !NAME, EMPTY USER n ---, no answer
    USER n; a 1D with another generation makes the Rytm ask that slot."""
    ev, t = meta_events(100, [P.meta_messages(1, 5, P.ST_READY, 0, "NP CLUST1", "NPC1", "", NP_KNOBS),
                              P.meta_messages(2, 4, P.ST_EMPTY),
                              P.meta_messages(3, 2, P.ST_MISSING, P.FLAG_ON_CARD, "ATARI", "ATAR"),
                              P.meta_messages(4, 7, P.ST_MUTED, 0, "FAULT", "FLT")])
    ev.append((t, "usb", P.slots([5, 4, 2, 7, 9], 3)))   # U5's generation 9: the Rytm lacks it
    ev2, t2 = walk_list(t + 400, UI["downs"]["u1"] + 4, confirm=False)
    s = e.run("names-list", t2, ev + ev2, save=True)
    got = [(e.cstr(s, sym(f"us_l{i}")), e.cstr(s, sym(f"us_s{i}"))) for i in range(1, 6)]
    check("names: READY / EMPTY / MISSING / MUTED / no answer (PNG names-list)",
          got == [("NP CLUST1", "NPC1"), ("USER 2 ---", "U2--"), ("!ATARI", "!ATA"), ("!FAULT", "!FLT"), ("USER 5", "U5")],
          str(got))
    # struct us_ram: tgen[5], tinst, seen at us_off_tgen - the 1D arrived (the asks below come without it too)
    g = e.peek(s, sym("us") + sym("us_off_tgen"), 7)
    check("names: the 1D reached 0021 (us.tgen 5 4 2 7 9, seen)", g[:5] == bytes([5, 4, 2, 7, 9]) and g[6] == 1, g.hex())
    a5 = [a for a in e.asks() if a and a["slot"] == 5 and a["what"] == 0]
    check("names: U5's generation from 1D (9) is not the Rytm's (0): it asks 19 what 0 with gen 0", bool(a5) and a5[-1]["gen"] == 0,
          str(a5[-1:]))
    a1 = [a for a in e.asks() if a and a["slot"] == 1 and a["what"] == 1]
    check("names: U1 READY with an enum knob: it asks for P1's names (19 what 1 arg 0)", bool(a1) and a1[-1]["arg"] == 0,
          str(a1[-1:]))


def select_u1_with(e, name, msgs, extra_events=(), length_after=300, save=True, env=None):
    """1A (and anything else) injected, then U1 put on track BD."""
    ev, t = meta_events(100, msgs)
    ev2, t2 = walk_list(t + 200, UI["downs"]["u1"])
    allev = ev + ev2 + [(t2 + at, k, v) for (at, k, v) in extra_events]
    end = t2 + (max(at for at, _, _ in extra_events) if extra_events else 0) + length_after
    return e.run(name, end, allev, save=save, env=env), t2


def t_labels(e):
    """(Task 8) Labels, looks, ranges and value texts from 1A/1B: P1 enum (ALG, PNG labels-enum shows Fibonac),
    P3 bipolar, P4 note, P8 a fader with range 10..120 default 100."""
    turns = [(0, "usb", b"".join(P.list_messages(1, 0, 5, ["PrimeCl", "PrimeCn", "Fibonac", "Partial"]))),
             (100, "turn", (f"{UI['knob_enc']['A']}:8", 3, 20))]
    s, t = select_u1_with(e, "labels", [P.meta_messages(1, 5, P.ST_READY, 0, "NP CLUST1", "NPC1", "", NP_KNOBS)], turns)
    names = [e.cstr(s, e.u32(s, rec(334 + k) + 40), 13) for k in range(8)]
    check("labels: long names from 1A, P<n> for the knobs it does not name",
          names == ["Algorithm", "X", "Y", "Root", "P5", "P6", "P7", "Level"], str(names))
    check("labels: the group name is the short name", e.cstr(s, e.u32(s, rec(334) + 44), 5) == "NPC1")
    rng = [e.u32(s, rec(341) + o) >> 8 for o in (8, 12, 16)]
    check("labels: P8's record range 10..120, default 100", rng == [10, 120, 100], str(rng))
    try:
        inv = sym("us_thunks")   # R1's alternative: record 334's own thunk
    except KeyError:
        inv = sym("us_text")
    w8 = e.u32(s, desc(334) + 32)
    sx = elek_sym(e, "rytm-0029-sendfx-ui:sfu_xtext")
    if sx and w8 == sx:   # 0029 (sfx-enum-knobs) steps P1 (an enum: 4 zones) and wraps its text: 0021's is saved there
        w8 = e.u32(s, elek_sym(e, "rytm-0029-sendfx-ui:sfu_x") + 1560 + 2 * 127 + 4 * 127 + 4 * (334 - 334))
    check("labels: the value text is the user slots' (descriptor word 8; through 0029's enum wrapper when built in)",
          w8 == inv, f"{w8:#x} {inv:#x}")
    look = [e.u32(s, desc(334 + k) + 36) for k in (2, 7)]
    check("labels: P3 looks like a bipolar knob (record 40's widget), P8 like a fader (record 101's)",
          look == [e.u32(s, desc(40) + 36), e.u32(s, desc(101) + 36)], str([hex(x) for x in look]))
    check("labels: kit word P8 = the default 100 when the machine was chosen", e.peek(s, 0x41255933 + 2 * 7, 1)[0] == 100)
    print("  look at build/emu/%s/labels.png: SRC page ALG X Y ROT P5 P6 P7 LEV; knob A reads Fibonac" % e.tag)


def t_unused(e):
    """(1026) A knob the 1A does not name is unused once the 1A is in: on SRC its entry in the machine page table
    (0x40287cc8 + 36 m + 4 + 4 k, what the SRC view draws and edits) is record 0, as stock machines with fewer knobs
    have, so it draws stock's unused box and
    its turn does nothing; on page 2 (SMPL, a slot with params) likewise (ext_page_record answers record 0). Named knobs
    keep their records and turn as before."""
    ka = UI["knob_enc"]
    p2 = [dict(p=9 + j, look="dial", kind="number", long=f"Two{j + 1}", short=f"T{j + 1}") for j in range(4)]
    # the host's form for a P its manifest lacks: an entry with empty names (P6 on SRC, P13 on page 2), as unused as one
    # left out (P5, P7, P14..P16)
    empty = [dict(p=6, look="dial", kind="number", long="", short=""), dict(p=13, look="dial", kind="number", long="",
                                                                           short="")]
    kit = lambda s: list(e.peek(s, 0x41255933, 32)[::2])   # BD's words 9..24 (P1..P16), high bytes
    turns = [(50, "turn", (f"{ka['E']}:5", 3, 20)), (150, "turn", (f"{ka['B']}:5", 3, 20)), (250, "press", "SMPL"),
             (350, "turn", (f"{ka['F']}:5", 3, 20)), (450, "turn", (f"{ka['A']}:5", 3, 20)),
             (550, "turn", (f"{ka['E']}:5", 3, 20))]
    s0, t = select_u1_with(e, "unused0", [P.meta_messages(1, 7, P.ST_READY, P.FLAG_PARAMS, "UN TEST", "UNT", "UN PAGE 2",
                                                         NP_KNOBS + p2 + empty)], length_after=20)
    s, t = select_u1_with(e, "unused", [P.meta_messages(1, 7, P.ST_READY, P.FLAG_PARAMS, "UN TEST", "UNT", "UN PAGE 2",
                                                       NP_KNOBS + p2 + empty)], turns)
    tab = [e.u32(s, 0x40287ccc + 36 * 35 + 4 * k) for k in range(8)]
    check("unused: U1's SRC page records: P1..P4 and P8 records 334.., P5..P7 record 0", tab == [334, 335, 336, 337,
          0, 0, 0, 341], str(tab))
    stock0 = [e.u32(s, 0x40287ccc + 36 * m + 4 * k) for m in range(35) for k in range(8)].count(0)
    check("unused: (stock machines leave unused knobs at record 0 the same way)", stock0 > 0, str(stock0))
    k0, k1 = kit(s0), kit(s)
    print(f"  BD's P1..P16 before {k0}, after {k1}")
    check("unused: SRC knob E (P5, unused) turned: its kit word unchanged", k1[4] == k0[4], str((k0[4], k1[4])))
    check("unused: SRC knob B (P2, named) turned: its kit word moved", k1[1] != k0[1], str((k0[1], k1[1])))
    check("unused: SMPL knob F (P14, unused) turned: unchanged", k1[13] == k0[13], str((k0[13], k1[13])))
    check("unused: SMPL knob E (P13, an entry with empty names) turned: unchanged", k1[12] == k0[12],
          str((k0[12], k1[12])))
    check("unused: SMPL knob A (P9, named) turned: moved", k1[8] != k0[8], str((k0[8], k1[8])))
    print("  look at build/emu/%s/unused.png: page 2 (UN PAGE 2) T1..T4 and four stock unused boxes" % e.tag)


def t_dspmod(e):
    """(1026) DSP SAMPLE's SMPL page in a build with diag = 0 (rui1026): knob C (word 20, record 444) is MOD, the host's
    playback mode (ONE LOOP SLICE GRAIN STRCH PLUCK WAVE), not the bring-up diagnostic DGN of the earlier rui builds."""
    if e.params.get("0021-ext", {}).get("diag", 0):
        check("dspmod: a diag = 0 build", False, "this build has 0021 diag = 1")
        return
    ev, t = walk_list(100, 24)
    s = e.run("dspmod", t + 300, ev + [(t, "press", "SMPL")], save=True)
    m = e.peek(s, 0x8000ea00, 1)[0]
    sh = e.cstr(s, e.u32(s, rec(444) + 48), 5)
    check("dspmod: BD plays DSP SAMPLE (45); SMPL knob C's short name is MOD", (m, sh) == (45, "MOD"), str((m, sh)))
    zones = []
    for n in (1, 3):   # MOD steps by zone (0021's zone list: 7 for MOD): n detents -> zone n (ONE LOOP SLICE GRAIN ..)
        # one slow turn (+8 x 3, 10 M apart: sfu_emu.py's "one") = one step, as stock's FILTER TYPE
        s2 = e.run(f"dspmod{n}", t + 400 + 200 * n, ev + [(t, "press", "SMPL")] +
                   [(t + 400 + 200 * i, "turn", (f"{UI['knob_enc']['C']}:+8", 3, 10)) for i in range(n)], save=True)
        zones.append(e.peek(s2, 0x41255933 + 2 * 11, 1)[0] * 7 // 128)
    check("dspmod: MOD is stepped: one detent LOOP (zone 1), three GRAIN (zone 3)", zones == [1, 3], str(zones))
    print("  look at build/emu/%s/dspmod.png: SD SAMPLE with MOD on knob C (ONE), dspmod3.png: GRAIN" % e.tag)


def t_junopat(e):
    """(1026) JUNO's page: its knobs edit (CUT, ENV: kit words 1, 4 move and the page shows them) - the Rytm side is
    wired; that the emulator sounds no different is the host's render (JUNO plays on the Sidecar). PAT's list cache:
    JUNO's list in (16), then FM's (17) takes the one cache (as at a project load): the PAT text asks for JUNO's again
    at once (13), not after its 200-draw throttle (~10 s)."""
    ev, t = walk_list(100, UI["downs"]["juno"])
    s0 = e.run("junopat0", t + 50, ev, save=True)
    s = e.run("junoknobs", t + 400, ev + [(t + 100, "turn", ("1:+8", 6, 10)), (t + 250, "turn", ("4:+8", 6, 10))],
              save=True)
    k0, k1 = list(e.peek(s0, 0x41255933, 16)[::2]), list(e.peek(s, 0x41255933, 16)[::2])
    check("junopat: BD plays JUNO (41); knobs B (CUT) and E (ENV) move kit words 1 and 4, the rest stay",
          e.peek(s, 0x8000ea00, 1)[0] == 41 and k1[1] > k0[1] and k1[4] > k0[4] and k1[2:4] == k0[2:4],
          str((k0, k1)))
    jn = b"".join(P.juno_names([f"JN{i:02d}" for i in range(16)]))
    fm = b"".join(P.fm_names([f"FM{i:02d}" for i in range(16)]))
    asks = lambda: sum(1 for m in e.sent if len(m) >= 6 and m[4] == 0x13)
    e.run("junopat-a", t + 600, ev + [(t + 100, "usb", jn)])
    a = asks()
    e.run("junopat-b", t + 600, ev + [(t + 100, "usb", jn), (t + 300, "usb", fm)])
    b = asks()
    check("junopat: FM's list evicting JUNO's makes the PAT text ask (13) again within 300 M", b == a + 1, str((a, b)))


def t_writeback(e):
    """(Task 8) 1C: the kit word and the live copy, clamped to the knob's range; nothing when the track plays
    another machine; P9..P16 too (R3)."""
    knobs = NP_KNOBS + [dict(p=9, look="dial", kind="number", long="Nine", short="NIN", min=0, max=50)]
    s, t = select_u1_with(e, "writeback", [P.meta_messages(1, 5, P.ST_READY, P.FLAG_PARAMS, "NP CLUST1", "NPC1", "", knobs)],
                          [(0, "usb", P.knobs(0, 1, [(7, 127), (1, 99), (8, 90)]))])
    w = e.peek(s, 0x41255933, 32)
    check("writeback: P2 = 99, P8 clamped to 120 (its max), P9 clamped to 50", (w[2], w[14], w[16]) == (99, 120, 50),
          w.hex())
    w = e.peek(s, 0x4076592f, 32)   # the project's copy of track 0's words (0x4076592f + 162 t + 2 (w - 9)), drained
    check("writeback: the project's copy too (P2 99, P8 120, P9 50)", (w[2], w[14], w[16]) == (99, 120, 50), w.hex())
    s2, _ = select_u1_with(e, "writeback-other", [P.meta_messages(1, 5, P.ST_READY, 0, "NP CLUST1", "NPC1", "", NP_KNOBS)],
                           [(0, "usb", P.knobs(0, 2, [(1, 11)]))])
    check("writeback: a 1C for U2 on a U1 track writes nothing", e.peek(s2, 0x41255933 + 2, 1)[0] != 11)


def t_texts(e):
    """(Task 8) The PRE knob's text from the slot's preset list (1B 0x20), a pool knob's from 0023's table (14)."""
    knobs = [dict(p=1, look="dial", kind="preset", long="Preset", short="PRE"),
             dict(p=5, look="dial", kind="pool", long="Sample", short="SMP", default=0)]
    pool = bytes(P.HDR) + bytes([P.POOL_TABLE, 1, 1, 1, 0, 3, 0, 4]) + bytes(P.name13("KICK01")) + b"\xf7"   # 14: slot 1 = KICK01
    # 0023 drops a 14 until its table exists: the first pool text of a value > 0 (0 is OFF without it) allocates it
    # and asks 13 (the Teensy answers), so the 14 goes after SMP left 0. With 0029's enum knobs (sfx-enum-knobs) PRE
    # is a list of the three presets (stored as the index) and SMP steps one slot at a time with the enum profile,
    # which wakes on turns of 8 counts (not 5): PRE 64 (past the end: Wide) -> 2 (Wide, the last), SMP 0 -> 1 or 2
    # (--- until the 14); without 0029 the dial's R4 step: PRE 65, SMP 1
    ev = [(0, "usb", b"".join(P.list_messages(1, P.LIST_PRESETS, 5, ["Bright", "Dark", "Wide"]))),
          (100, "turn", (f"{UI['knob_enc']['A']}:+8", 4, 8)),
          (300, "turn", (f"{UI['knob_enc']['E']}:+8", 4, 8)),
          (600, "usb", pool),
          (800, "turn", f"{UI['knob_enc']['E']}:1")]
    turn_dir = os.path.join(e.out, "texts-turn")
    shutil.rmtree(turn_dir, True)
    os.makedirs(turn_dir)
    s, t = select_u1_with(e, "texts", [P.meta_messages(1, 5, P.ST_READY, 0, "PRESETS", "PRST", "", knobs)], ev,
                          env={"DTBOOT_TURN_PNG": turn_dir})
    q = sym("jn_mailbox")
    # jn_mailbox: magic, hook, valid total wait pend, pend_track, val[6], list (+19), lgen (+20)
    check("texts: the one-list cache holds U1's presets (key 0x11, generation 5, 3 names)",
          e.peek(s, q + 19, 2) == bytes([0x11, 5]) and e.peek(s, q + 8, 2) == bytes([1, 3]), e.peek(s, q, 24).hex())
    check("texts: SMP's first text asked 0023's pool table (13)", any(m[4:6] == bytes([0x13, 0xf7]) for m in e.sent))
    tab = e.u32(s, sym("td_pool", "0023-teensy-drive"))   # struct pool: s (128 pslot of 18 B: f, e, name[14])
    kw = e.peek(s, 0x41255933, 9)
    enum = bool(elek_sym(e, "rytm-0029-sendfx-ui:sfu_xtext"))
    check("texts: 0023's table has slot 1 = KICK01, knob A (PRE) at Wide (enum: index 2; dial: 65), E (SMP) moved "
          "(enum: 1..2; dial: 1)", bool(tab) and e.cstr(s, tab + 18 + 4, 14) == "KICK01" and
          ((kw[0] == 2 and kw[8] in (1, 2)) if enum else (kw[0], kw[8]) == (65, 1)), f"{tab:#x} {kw.hex()}")
    print(f"  look at {turn_dir}/: knob A reads Wide while it turns, knob E --- then KICK01 (texts.png)")


def t_page2(e):
    """(Task 9, widened in Task 11) Page 2: U1 with params on BD (title V2 PAGE 2, its P9..P16), U2 with the sample
    page, U3 with params on SD; the shared records follow the selected track's slot (names, range, default) as the
    track changes; the sample layer flag per slot; PLAITS', DAISYSP's and DSP SAMPLE's page-2 records untouched."""
    p2 = [dict(p=9 + j, look="dial", kind="number", long=f"Two{j + 1}", short=f"T{j + 1}") for j in range(8)]
    p2[0].update(min=5, max=90, default=40)
    p3 = [dict(p=9 + j, look="dial", kind="number", long=f"Thr{j + 1}", short=f"H{j + 1}") for j in range(8)]
    p3[0].update(min=2, max=50, default=25)
    ev, t = meta_events(100, [P.meta_messages(1, 6, P.ST_READY, P.FLAG_PARAMS, "V2 TEST", "V2T", "V2 PAGE 2", NP_KNOBS + p2),
                              P.meta_messages(2, 3, P.ST_READY, 0, "SINE TEST", "SINE", "", []),
                              P.meta_messages(3, 4, P.ST_READY, P.FLAG_PARAMS, "V3 TEST", "V3T", "V3 PAGE 2", p3)])
    ev1, t1 = walk_list(t + 100, UI["downs"]["u1"])         # U1 on BD
    ev2, t2 = walk_list(t1 + 100, UI["downs_sd"]["u3"])     # U3 on SD (selected by its pad)
    ev += ev1 + [(t1, "press", "SD")] + ev2 + [(t2, "press", "SMPL")]
    s = e.run("page2-u3", t2 + 300, ev, save=True)
    m = e.peek(s, 0x8000ea00, 2)
    check("page2: BD plays U1 (35), SD U3 (37), SD selected", (m[0], m[1], e.peek(s, 0x41318982, 1)[0]) == (35, 37, 1),
          m.hex())

    def shared(s):
        return ([e.cstr(s, e.u32(s, rec(r) + 40), 8) for r in (438, 457, 403)],
                [e.u32(s, rec(438) + o) >> 8 for o in (8, 12, 16)])
    got = shared(s)
    check("page2: SD selected - the shared records are U3's (Thr1 Thr2 Thr6; 438's range 2..50, default 25)",
          got == (["Thr1", "Thr2", "Thr6"], [2, 50, 25]), str(got))
    s2 = e.run("page2-u1", 300, [(20, "press", "BD"), (120, "press", "SMPL")], save=True, snap=s, start=e.clock + t2 + 300)
    got = shared(s2)
    check("page2: BD selected again - they follow it to U1's (Two1 Two2 Two6; 438's range 5..90, default 40)",
          got == (["Two1", "Two2", "Two6"], [5, 90, 40]), str(got))
    c = [e.u32(s2, sym("us") + 4 * i) for i in range(3)]
    check("page2: the titles from 1A (U1 V2 PAGE 2, U3 V3 PAGE 2; us_head's title at +20)",
          [e.cstr(s2, c[0] + 20), e.cstr(s2, c[2] + 20)] == ["V2 PAGE 2", "V3 PAGE 2"])
    lay = list(e.peek(s2, sym("us") + sym("us_off_layer"), 3))
    check("page2: U1's and U3's sample layer muted (page 2 params), U2's kept (sample page)", lay == [0, 1, 0], str(lay))
    for arr, title, want in (("ext_p2_order", "ext_p2_title", "PLAITS PAGE 2"), ("dsp_p2_order", "dsp_p2_title", "EXCITER"),
                             ("dsps_p2_order", "dsps_p2_title", "SD SAMPLE")):
        recs = [e.u32(s2, sym(arr) + 4 * k) for k in range(8)]
        names = [e.cstr(s2, e.u32(s2, rec(r) + 40), 14) for r in recs]
        stock = [e.cstr(e.snap, e.u32(e.snap, rec(r) + 40), 14) for r in recs]
        check(f"page2: {want}'s eight records keep their long names (not the user slots' shared ones), title {want}",
              all(names) and names == stock and not set(recs) & {438, 457, 458, 459, 460, 403, 404, 405} and
              e.cstr(s2, sym(title), 16) == want, f"{recs} {names}")
    print("  look at build/emu/%s/page2-u1.png: title V2 PAGE 2, knobs T1..T8; page2-u3.png: V3 PAGE 2, H1..H8" % e.tag)


def card_copy(e, name):
    """A copy of the base's card for a run that writes it (a power-off)."""
    c = os.path.join(e.tmp, f"{name}.img")
    shutil.copy(e.card, c)
    return c


STOCK = os.path.join(ROOT, "stock", "Analog-Rytm_MKII_OS1.73.syx")


def t_poweroff(e):
    """(Task 10) U1 on track BD with words written back (P2, and P9 on page 2), the power goes (the working state to the card), the build cold
    boots on that card: U1 still there with its word, named USER 1 until a Teensy answers. JUNO's 15 the same."""
    c = card_copy(e, "poweroff")
    knobs = NP_KNOBS + [dict(p=9, look="dial", kind="number", long="Nine", short="NIN")]
    ev, t = meta_events(100, [P.meta_messages(1, 5, P.ST_READY, P.FLAG_PARAMS, "NP CLUST1", "NPC1", "", knobs)])
    ev2, t2 = walk_list(t + 200, UI["downs"]["u1"])
    ev3 = [(t2, "usb", P.knobs(0, 1, [(1, 99), (8, 50)]))]   # P2 99, P9 (page 2, record 438) 50
    e.run("poweroff-before", t2 + 1100, ev + ev2 + ev3, card=c, extra=["--power-off", f"{e.clock + t2 + 1000}M"])
    s = e.run("poweroff-after", 4400, cold=True, card=c, save=True)
    check("poweroff: the cold boot comes up with U1 on track BD", e.peek(s, 0x8000ea00, 1)[0] == 35)
    check("poweroff: P2's word kept (99)", e.peek(s, 0x41255933 + 2, 1)[0] == 99, f"kit {e.peek(s, 0x41255933 + 2, 1)[0]}")
    check("poweroff: P9's word kept (50, page 2)", e.peek(s, 0x41255933 + 16, 1)[0] == 50, f"kit {e.peek(s, 0x41255933 + 16, 1)[0]}")
    check("poweroff: named USER 1 (no Teensy after the boot)", e.cstr(s, sym("us_l1")) == "USER 1")
    s = e.run("poweroff-teensy", 600, [(100, "usb", b"".join(P.meta_messages(1, 5, P.ST_READY, P.FLAG_PARAMS, "NP CLUST1",
                                                                         "NPC1", "", knobs))),
                                       (300, "usb", P.slots([5, 0, 0, 0, 0], 0))], save=True, snap=s, start=4400, card=c)
    w = e.peek(s, 0x41255933, 32)
    check("poweroff: the Teensy's 1A after the boot names U1 and keeps its words (a load is not a choice: P2 99, P9 50)",
          (w[2], w[16]) == (99, 50) and e.cstr(s, sym("us_l1")) == "NP CLUST1", w.hex())
    # JUNO's 15 (voice 0, CUT..REL 10..60; rytm-teensy sim/protocol.py decode_juno_knobs) on BD, then the same
    c = card_copy(e, "poweroff-juno")
    ev, t = walk_list(100, UI["downs"]["juno"])
    ev.append((t, "usb", P.HDR + bytes([0x15, 0, 10, 20, 30, 40, 50, 60, 0xF7])))
    s = e.run("poweroff-juno-before", t + 1100, ev, card=c, save=True, extra=["--power-off", f"{e.clock + t + 1000}M"])
    w = e.peek(s, 0x41255933 + 2, 12)[0::2]
    check("poweroff: JUNO on BD, 15's CUT..REL in the kit before the power-off",
          e.peek(s, 0x8000ea00, 1)[0] == 41 and list(w) == [10, 20, 30, 40, 50, 60], w.hex())
    s = e.run("poweroff-juno-after", 4400, cold=True, card=c, save=True)
    w = e.peek(s, 0x41255933 + 2, 12)[0::2]
    check("poweroff: JUNO's CUT..REL kept (10..60) after the cold boot",
          e.peek(s, 0x8000ea00, 1)[0] == 41 and list(w) == [10, 20, 30, 40, 50, 60], w.hex())


def t_stock(e):
    """(Task 12, every slot since 2026-10-11) The working state with a U-track on stock 1.73, for each of U1..U5 with a
    tagged sound (its 1A's fp): no fault, the track DISABLE (PNG stock-boot<n>), its words and its tag kept; back on the
    build, U<n> comes back unchanged (spec 1.9)."""
    for n in range(1, 6):
        fp = P.plugin_fp(f"rytm.stock{n}")
        c = card_copy(e, f"stock{n}")
        ev, t = meta_events(100, [P.meta_messages(n, 5, P.ST_READY, 0, f"NP CLUST{n}", f"NPC{n}", "", NP_KNOBS, fp=fp)])
        ev2, t2 = walk_list(t + 200, UI["downs"]["u1"] + n - 1)
        ev3 = [(t2, "usb", P.knobs(0, n, [(1, 99)]))]
        s = e.run(f"stock{n}-before", t2 + 1100, ev + ev2 + ev3, card=c, save=True,
                  extra=["--power-off", f"{e.clock + t2 + 1000}M"])
        got = (e.peek(s, 0x8000ea00, 1)[0], e.peek(s, 0x41255933 + 2, 1)[0], word0(e, s)[0])
        check(f"stock: U{n} on BD before the power-off, P2 99, word 0 its fp", got == (34 + n, 99, fp), f"{got}, fp {fp:#x}")
        s = e.run(f"stock{n}-boot", 4400, cold=True, card=c, fw=STOCK, save=True)
        got = (e.peek(s, 0x8000ea00, 1, fw=STOCK)[0], e.peek(s, 0x41255933 + 2, 1, fw=STOCK)[0],
               int.from_bytes(e.peek(s, 0x4076598d, 2, fw=STOCK), "big"))
        check(f"stock: U{n}'s track on stock - DISABLE (27), P2's word 99, the project copy's slot 47 (the tag) kept raw",
              got == (27, 99, fp),
              f"{got}, fp {fp:#x}")
        s2 = e.run(f"stock{n}-back", 4400, cold=True, card=c, save=True)
        got = (e.peek(s2, 0x8000ea00, 1)[0], e.peek(s2, 0x41255933 + 2, 1)[0], word0(e, s2)[0])
        check(f"stock: back on the build, U{n} on BD with P2 99 and its tag", got == (34 + n, 99, fp), f"{got}, fp {fp:#x}")
    print("  look at build/emu/%s/stock1-boot.png: track BD shows DISABLE (knobs greyed)" % e.tag)


def t_strict(e):
    """(Task 12) The names, labels and write-back flows under DTEMU_STRICT=1 (interpreter, unmapped pages and the SRAM
    mirror fault): no strict access."""
    ev, t = meta_events(100, [P.meta_messages(1, 5, P.ST_READY, 0, "NP CLUST1", "NPC1", "", NP_KNOBS)])
    ev2, t2 = walk_list(t + 200, UI["downs"]["u1"])
    ev3 = [(t2, "usb", P.knobs(0, 1, [(1, 99)])), (t2 + 50, "usb", b"".join(P.list_messages(1, 0, 5, ["A", "B", "C", "D"])))]
    e.run("strict", t2 + 200, ev + ev2 + ev3, env={"DTEMU_STRICT": "1"})
    bad = [line for line in e.log.splitlines() if line.startswith("strict:")]
    check("strict: no strict access", not bad, "; ".join(bad[:3]))
    # the tag, the slot menu, its assign, a kit load and kit 1, every run of each under DTEMU_STRICT=1 (2026-10-11)
    e.strict = True
    try:
        for f in (t_tag, t_menu, t_assign, t_load, t_tagkit1):
            print(f"  strict: {f.__name__}")
            f(e)
    finally:
        e.strict = False


def open_menu(at):
    """Events opening the track menu (FUNC held + CHRO) and moving down to item U1."""
    ev = [(at, "press", f"FUNC:{UI['menu_hold_M']}M"), (at + 20, "press", "CHRO")]
    t = at + UI["menu_hold_M"] + 100
    for _ in range(UI["menu_downs_to_u1"]):
        ev.append((t, "press", "DOWN"))
        t += UI["step_M"]
    return ev, t


def assigns(e):
    return [P.decode_assign(m[5:-1]) for m in e.sent if len(m) > 5 and m[4] == P.ASSIGN]


def t_menu(e):
    """(Task 11) The track menu lists U1..U5; YES on U1 asks for the installed list (19 what 3), sends 1E for the next
    machine and shows the 1D answer as a popup (PNG menu-answer); without an answer: NO SIDECAR."""
    ev, t = meta_events(100, [P.meta_messages(1, 5, P.ST_EMPTY)])
    ev2, t = open_menu(t + 100)
    ev += ev2
    e.run("menu-list", t, ev)
    print("  look at build/emu/%s/menu-list.png: the track menu with U1 --- after SAVE TRACK, U2..U5 below" % e.tag)
    ev.append((t, "press", "YES"))
    ev.append((t + 30, "usb", b"".join(P.list_messages(0, P.LIST_INSTALLED, 3, ["SINE TEST", "V2 TEST"]))))
    ev.append((t + 30, "usb", P.slots([5, 1, 1, 1, 1], 3)))
    ev.append((t + 80, "usb", P.slots([6, 1, 1, 1, 1], 3, 1, P.RES_READY)))
    e.run("menu-answer", t + 300, ev)
    sent = assigns(e)
    check("menu: YES on U1 (EMPTY) asks for the installed list and sends 1E assign entry 0 at generation 3",
          any(a and a["what"] == 3 for a in e.asks()) and bool(sent) and sent[-1] == dict(slot=1, op=0, arg=0, installed_gen=3),
          str(sent))
    i = max(k for k, m in enumerate(e.sent) if len(m) > 5 and m[4] == P.ASSIGN)
    proj = e.peek(e.snap, 0x407c89d3, 16).split(b"\0")[0]
    check("menu: the 1E comes straight after 10 <project> (spec 2.1)", i > 0 and e.sent[i - 1][4] == 0x10 and
          e.sent[i - 1][5:-1] == proj, f"{e.sent[i - 1].hex() if i else None}, project {proj}")
    print("  look at build/emu/%s/menu-answer.png: the popup READY" % e.tag)
    pop, slp = sym("us_popup"), ret_of_call("us_wait", 0x40098c18)   # slp: us_wait's 10 ms steps
    early = [x for x in ev if x[1] != "usb" or x[0] < t]
    e.run("menu-none", t + 440, early, count=[pop])
    check("menu: without the Teensy no 1E goes out (the installed list never came), and the popup is up within 2.2 s "
          "(440M at ~200M/s)", not assigns(e) and e.counts.get(pop) == 1, f"{assigns(e)}, popups {e.counts.get(pop)}")
    print("  look at build/emu/%s/menu-none.png: the popup NO SIDECAR (no answer within 2 s)" % e.tag)
    # (review 2026-10-11, LOW 3) the list late in the 2 s (10 ms steps of ~2.15M; the 1D before the YES, as two
    # files at one instant can lose one): at ~140 steps the 1E goes out and the answer wait has the rest; at ~185
    # (fewer than 30 left) no 1E - NO SIDECAR at once, the Teensy never assigns behind it
    lst = b"".join(P.list_messages(0, P.LIST_INSTALLED, 3, ["SINE TEST", "V2 TEST"]))
    early = [x for x in early if x[0] < t] + [(t - 50, "usb", P.slots([5, 1, 1, 1, 1], 3)), (t, "press", "YES")]
    e.run("menu-late", t + 440, early + [(t + 300, "usb", lst)], count=[pop, slp])
    check("menu: the list at ~140 steps - the 1E goes out, no answer: the popup within 2.2 s, after the 2 s budget "
          "(199 sleeps: the step that found the list sleeps in neither wait)",
          len(assigns(e)) == 1 and e.counts.get(pop) == 1 and e.counts.get(slp) == 199,
          f"{assigns(e)}, popups {e.counts.get(pop)}, steps {e.counts.get(slp)}")
    e.run("menu-last", t + 440, early + [(t + 400, "usb", lst)], count=[pop, slp])
    check("menu: the list in the last 300 ms (step > 170) - no 1E, the popup NO SIDECAR at once (fewer than 200 steps)",
          not assigns(e) and e.counts.get(pop) == 1 and 170 < (e.counts.get(slp) or 0) < 200,
          f"{assigns(e)}, popups {e.counts.get(pop)}, steps {e.counts.get(slp)}")


# P1..P16 defaults of a slot whose page 2 is knobs; the knobs 1A leaves out default to 64
CH_KNOBS = [dict(p=1, long="One", short="ONE", default=10),
            dict(p=2, long="Two", short="TWO", default=20),
            dict(p=8, look="fader", long="Level", short="LEV", min=10, max=120, default=100),
            dict(p=9, long="Nine", short="NIN", default=33),
            dict(p=12, long="Twelve", short="TWL", default=44)]
CH_WANT = [10, 20, 64, 64, 64, 64, 64, 100, 33, 64, 64, 44, 64, 64, 64, 64]


def kit16(e, s, t=0):
    """Track t's sixteen kit words (P1..P8 machine words 9..16, P9..P16 sample words 17..24), integer parts."""
    return list(e.peek(s, 0x41255933 + 152 * t, 32)[0::2])


def t_choose(e):
    """(Task 11, the user's decision) U1 chosen in the machine list (YES) takes its 1A defaults on P1..P16 - at once
    when the 1A is current, when it arrives otherwise; a preview passing U1 to another machine, and NO, leave the
    sample words alone."""
    one = P.meta_messages(1, 5, P.ST_READY, P.FLAG_PARAMS, "CHOOSE", "CHS", "CHS PAGE 2", CH_KNOBS)
    base = kit16(e, e.snap)
    ev, t = meta_events(100, [one])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    ev2, t2 = walk_list(t + 100, UI["downs"]["u1"])
    s = e.run("choose-yes", t2 + 200, ev + ev2, save=True)
    got = kit16(e, s)
    check("choose: U1 on BD with its 1A current - P1..P16 are its defaults (P9..P16 on the sample words)",
          e.peek(s, 0x8000ea00, 1)[0] == 35 and got == CH_WANT, f"{got} (base {base})")
    w = e.peek(s, 0x4076592f, 32)[0::2]
    check("choose: the project's copy too", list(w) == CH_WANT, str(list(w)))
    ev2, t2 = walk_list(t + 100, UI["downs"]["u1"] + 5)   # through U1..U5 to 6-OP FM
    s = e.run("choose-past", t2 + 200, ev + ev2, save=True)
    got = kit16(e, s)
    check("choose: a preview passing U1 on the way to 6-OP FM (YES) leaves the sample words as they were",
          e.peek(s, 0x8000ea00, 1)[0] == 40 and got[8:] == base[8:], f"{got} (base {base})")
    ev2, t2 = walk_list(t + 100, UI["downs"]["u1"], confirm=False)
    ev2.append((t2, "press", "NO"))
    s = e.run("choose-no", t2 + 300, ev + ev2, save=True)
    got = kit16(e, s)
    check("choose: U1 previewed, then NO - the old machine back with its words, the sample words untouched",
          e.peek(s, 0x8000ea00, 1)[0] == e.peek(e.snap, 0x8000ea00, 1)[0] and got == base, f"{got} (base {base})")
    ev2, t2 = walk_list(100, UI["downs"]["u1"])
    ev2.append((t2 + 100, "usb", b"".join(u1_fp(FP_A))))
    s = e.run("choose-late", t2 + 400, ev2, save=True)
    got = kit16(e, s)
    check("choose: U1 chosen before its 1A (no Teensy yet) - the defaults go in when the 1A arrives, and its fp in word 0",
          got == CH_WANT and word0(e, s) == (FP_A, FP_A), f"{got} (base {base}) {word0(e, s)}")


def pslots(e, s):
    """The twelve tracks' pslot bytes (a choice waiting for its slot's 1A: 1..5, else 0)."""
    w = e.u32(s, sym("us") + sym("us_off_wb"))
    n = sym("us_wb_size")
    return list(e.peek(s, w, 12 * n)[sym("us_wb_pslot")::n]) if w else []


def u1_meta():
    return [P.meta_messages(1, 5, P.ST_READY, P.FLAG_PARAMS, "CHOOSE", "CHS", "CHS PAGE 2", CH_KNOBS)]


def t_stale(e):
    """(Task 11 review I1) The machine list left without its close (GLOBAL over it: measured, the preview stays, no
    close, the note stays): reopened and YES with no cursor move, BD keeps its sample words - the list's opening
    clears the note (us_open_thunk)."""
    base = kit16(e, e.snap)
    ev, t = meta_events(100, u1_meta())
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    ev2, t2 = walk_list(t + 100, UI["downs"]["u1"], confirm=False)
    ev += ev2 + [(t2, "press", "GLOBAL"), (t2 + 150, "press", "NO")]
    t2 += 400
    s = e.run("stale-left", t2, ev, save=True, count=[0x400dea82])
    ch = e.peek(s, sym("us") + sym("us_off_ch"), 1)[0]
    check("stale: list left by GLOBAL - U1 stays on BD, no close (0x400dea82 0), the note still there, no defaults",
          e.peek(s, 0x8000ea00, 1)[0] == 35 and e.counts.get(0x400dea82) == 0 and ch == 1 and kit16(e, s)[8:] == base[8:],
          f"close {e.counts.get(0x400dea82)}, ch {ch}, {kit16(e, s)}")
    ev2, t3 = walk_list(t2, 0)   # SRC SRC, YES at once
    s = e.run("stale", t3 + 200, ev + ev2, save=True, count=[0x400dea82, 0x400def0a])
    got = kit16(e, s)
    check("stale: reopened and YES with no move - the list opened (0x400def0a) and closed (0x400dea82), BD's sample "
          "words untouched (no defaults from the old note)", e.counts.get(0x400def0a) == 2 and e.counts.get(0x400dea82) == 1
          and got[8:] == base[8:] and e.peek(s, sym("us") + sym("us_off_ch"), 1)[0] == 0,
          f"open {e.counts.get(0x400def0a)}, close {e.counts.get(0x400dea82)}, {got} (base {base})")


def t_sound(e):
    """(Task 11 review I1) The SOUND menu's MACHINE item (FUNC + FLTR, RIGHT): a step onto U1 is a choice - stock resets
    P1..P8 on every step (0x400bcbac), U1's 1A defaults go on P1..P16 and its fp on word 0; no note for the machine list."""
    ev, t = meta_events(100, [u1_fp(FP_A)])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    ev += [(t + 100, "press", "FUNC:300M"), (t + 120, "press", "FLTR")]
    t += 500
    for _ in range(UI["sound_rights_to_u1"]):
        ev.append((t, "press", "RIGHT"))
        t += UI["step_M"]
    ev.append((t + 100, "press", "NO"))
    s = e.run("sound", t + 400, ev, save=True, count=[0x400bcbac, 0x400bed62, 0x4011f6bc])
    got = kit16(e, s)
    n = UI["sound_rights_to_u1"]
    check(f"sound: {n} RIGHTs - {n} steps through 0x400bed62, stock resets P1..P8 on each (0x400bcbac {n}), no load",
          e.counts.get(0x400bed62) == n and e.counts.get(0x400bcbac) == n and e.counts.get(0x4011f6bc) == 0,
          str({hex(a): c for a, c in e.counts.items()}))
    check("sound: U1 on BD with its 1A current - P1..P16 are its defaults, word 0 its fp in both copies, no note for the list",
          e.peek(s, 0x8000ea00, 1)[0] == 35 and got == CH_WANT and e.peek(s, sym("us") + sym("us_off_ch"), 1)[0] == 0
          and word0(e, s) == (FP_A, FP_A), f"{got} {word0(e, s)}")


def kit_menu(at, downs):
    """FUNC + PLAYMODE (the KIT menu: RELOAD, LOAD KIT, SAVE KIT, ...), back to its top, down `downs`, YES."""
    ev = [(at, "press", "FUNC:300M"), (at + 20, "press", "PLAYMODE")]
    t = at + 400
    for k in ["UP"] * 3 + ["DOWN"] * downs + ["YES"]:
        ev.append((t, "press", k))
        t += UI["step_M"]
    return ev, t


def t_load(e):
    """(Task 11 review M1) U1 chosen with no Teensy, the kit saved, then reloaded (a load: 0x4011f6bc once, not on the
    save): when U1's 1A arrives, BD keeps the loaded values - the load dropped the waiting choice (us_loaded)."""
    ev, t = walk_list(100, UI["downs"]["u1"])
    s = e.run("load-chosen", t, ev, save=True)
    check("load: U1 chosen with no 1A - BD waits (pslot 1)", pslots(e, s)[:1] == [1], str(pslots(e, s)))
    ev2, t2 = kit_menu(t, 2)   # SAVE KIT: the kit list (K001 selected), its name, YES saves
    ev2 += [(t2 + 200, "press", "YES"), (t2 + 400, "press", "YES")]
    s = e.run("load-saved", t2 + 1000, ev + ev2, save=True, count=[0x4011f6bc])
    check("load: SAVE KIT is no load (0x4011f6bc 0) - BD still waits", e.counts.get(0x4011f6bc) == 0 and
          pslots(e, s)[:1] == [1], f"{e.counts.get(0x4011f6bc)}, {pslots(e, s)}")
    ev3, t3 = kit_menu(t2 + 1000, 0)   # RELOAD
    ev3 += [(t3 + 200, "press", "YES")]   # its confirmation, if it asks
    s = e.run("load-reloaded", t3 + 800, ev + ev2 + ev3, save=True, count=[0x4011f6bc])
    kept = kit16(e, s)
    check("load: RELOAD KIT - one load (0x4011f6bc 1), BD on U1 from the kit, nothing waits",
          e.counts.get(0x4011f6bc) == 1 and e.peek(s, 0x8000ea00, 1)[0] == 35 and pslots(e, s)[:1] == [0],
          f"{e.counts.get(0x4011f6bc)}, machine {e.peek(s, 0x8000ea00, 1)[0]}, {pslots(e, s)}")
    ev4, t4 = meta_events(t3 + 800, u1_meta())
    ev4.append((t4, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    s = e.run("load", t4 + 400, ev + ev2 + ev3 + ev4, save=True)
    got = kit16(e, s)
    check("load: U1's 1A arrives after the load - BD keeps the loaded values (not the defaults)",
          got == kept and got != CH_WANT and e.cstr(s, sym("us_l1")) == "CHOOSE", f"{got} (loaded {kept})")


def t_window(e):
    """(Task 11 review M2) The wait is on the audio block counter 0x419ca2ac (1500 a second, 32-bit): +1500 per emulated
    second; a choice older than 60 s (90000 blocks) is dropped at the next tick, a younger one goes in."""
    ev, t = walk_list(100, UI["downs"]["u1"])
    s = e.run("window-chosen", t, ev, save=True)
    b0 = e.u32(s, 0x419ca2ac)
    s1 = e.run("window-rate", 200, snap=s, start=e.clock + t, save=True)
    b1 = e.u32(s1, 0x419ca2ac)
    check("window: the block counter runs 1500 a second (200M instructions = 1 emulated s)", abs((b1 - b0) - 1500) <= 2,
          f"{b0} -> {b1}: {b1 - b0}")
    meta = [(100, "usb", b"".join(u1_fp(FP_A))), (300, "usb", P.slots([5, 0, 0, 0, 0], 0))]
    for name, ahead, want in (("window-late", 90100, False), ("window-young", 80000, True)):
        s2 = e.run(name, 700, meta, snap=s, start=e.clock + t, save=True,
                   extra=["--poke", f"419ca2ac={b0 + ahead:x}"])
        got = kit16(e, s2)
        check(f"window: the 1A {ahead} blocks after the choice - defaults and tag {'in' if want else 'not in'}",
              (got == CH_WANT) == want and word0(e, s2) == ((FP_A, FP_A) if want else word0(e, s))
              and pslots(e, s2)[:1] == [0], f"{got} {word0(e, s2)}")


def t_assign(e):
    """(Task 11, the user's decision) The slot menu's assign: the tracks playing the slot take the new machine's
    defaults when its 1A comes (P2 99 written back before -> 77)."""
    sine = [dict(p=2, long="Two", short="TWO", default=20)]
    ev, t = meta_events(100, [P.meta_messages(1, 5, P.ST_READY, 0, "SINE TEST", "SINE", "", sine, fp=FP_A)])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 3)))
    ev2, t2 = walk_list(t + 100, UI["downs"]["u1"])
    ev += ev2 + [(t2, "usb", P.knobs(0, 1, [(1, 99)]))]
    ev2, t3 = open_menu(t2 + 300)
    ev += ev2 + [(t3, "press", "YES"),
                 (t3 + 30, "usb", b"".join(P.list_messages(0, P.LIST_INSTALLED, 3, ["SINE TEST", "V2 TEST"]))),
                 (t3 + 80, "usb", P.slots([6, 0, 0, 0, 0], 3, 1, P.RES_READY))]
    s = e.run("assign-before", t3 + 200, ev, save=True)
    check("assign: before the new 1A, P2 keeps the written-back 99, word 0 SINE TEST's fp",
          kit16(e, s)[1] == 99 and word0(e, s) == (FP_A, FP_A), f"{kit16(e, s)} {word0(e, s)}")
    sent = assigns(e)
    check("assign: YES on U1 (SINE TEST) sends 1E for the next installed machine (entry 1, V2 TEST)",
          bool(sent) and sent[-1] == dict(slot=1, op=0, arg=1, installed_gen=3), str(sent))
    i = max(k for k, m in enumerate(e.sent) if len(m) > 5 and m[4] == P.ASSIGN)
    check("assign: 10 <project> straight before the 1E", i > 0 and e.sent[i - 1][4] == 0x10)
    v2 = [dict(p=2, long="Two", short="TWO", default=77)]
    ev.append((t3 + 300, "usb", b"".join(P.meta_messages(1, 6, P.ST_READY, 0, "V2 TEST", "V2T", "", v2, fp=FP_B))))
    # the 1A commits in the UI tick, which runs on value texts: the menu draws none, so it is closed first
    ev += [(t3 + 400, "press", "NO"), (t3 + 500, "press", "NO")]
    s = e.run("assign", t3 + 800, ev, save=True)
    got = kit16(e, s)
    check("assign: the new machine's 1A (generation 6) gives BD's U1 its defaults (P2 77, P1 64) and its fp in word 0",
          (got[1], got[0]) == (77, 64) and e.cstr(s, sym("us_l1")) == "V2 TEST" and word0(e, s) == (FP_B, FP_B),
          f"{got} {word0(e, s)}")


def t_assigngen(e):
    """(hardening) The slot menu's assign answered READY by a 1D carrying the OLD generation (a stale Teensy: the Rytm's
    cache still holds the old machine at that number): the old machine's defaults and fp never land - the pend notes the
    cache's generation then (pgen) and waits for another; the fresh 1D and 1A (V2 TEST, generation 6) give BD its
    defaults (P2 77) and FP_B."""
    sine = [dict(p=2, long="Two", short="TWO", default=20)]
    ev, t = meta_events(100, [P.meta_messages(1, 5, P.ST_READY, 0, "SINE TEST", "SINE", "", sine, fp=FP_A)])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 3)))
    ev2, t2 = walk_list(t + 100, UI["downs"]["u1"])
    ev += ev2 + [(t2, "usb", P.knobs(0, 1, [(1, 99)]))]
    ev2, t3 = open_menu(t2 + 300)
    ev += ev2 + [(t3, "press", "YES"),
                 (t3 + 30, "usb", b"".join(P.list_messages(0, P.LIST_INSTALLED, 3, ["SINE TEST", "V2 TEST"]))),
                 (t3 + 80, "usb", P.slots([5, 0, 0, 0, 0], 3, 1, P.RES_READY)),   # READY, the old generation 5
                 (t3 + 150, "press", "NO"), (t3 + 250, "press", "NO")]
    s = e.run("assigngen-stale", t3 + 600, ev, save=True)
    sent = assigns(e)
    check("assigngen: the 1E went out (entry 1, installed generation 3)",
          bool(sent) and sent[-1] == dict(slot=1, op=0, arg=1, installed_gen=3), str(sent))
    w = e.u32(s, sym("us") + sym("us_off_wb"))
    pgen = e.peek(s, w + sym("us_wb_pgen"), 1)[0] if w else None
    check("assigngen: READY with the old generation - BD keeps P2 99 and SINE TEST's word 0 (no old defaults, no fp "
          "written again), the choice still waits (pslot 1, pgen 5) with the cache unchanged (U1 SINE TEST)",
          kit16(e, s)[1] == 99 and word0(e, s) == (FP_A, FP_A) and pslots(e, s)[:1] == [1] and pgen == 5
          and e.cstr(s, sym("us_l1")) == "SINE TEST",
          f"{kit16(e, s)} {word0(e, s)} {pslots(e, s)} pgen {pgen} {e.cstr(s, sym('us_l1'))}")
    v2 = [dict(p=2, long="Two", short="TWO", default=77)]
    ev += [(t3 + 700, "usb", P.slots([6, 0, 0, 0, 0], 3)),
           (t3 + 750, "usb", b"".join(P.meta_messages(1, 6, P.ST_READY, 0, "V2 TEST", "V2T", "", v2, fp=FP_B)))]
    s = e.run("assigngen", t3 + 1100, ev, save=True)
    got = kit16(e, s)
    check("assigngen: the fresh 1D and 1A (generation 6) - BD's U1 takes V2 TEST's defaults (P2 77, P1 64) and FP_B, "
          "nothing waits", (got[1], got[0]) == (77, 64) and word0(e, s) == (FP_B, FP_B)
          and e.cstr(s, sym("us_l1")) == "V2 TEST" and pslots(e, s)[:1] == [0],
          f"{got} {word0(e, s)} {e.cstr(s, sym('us_l1'))} {pslots(e, s)}")


def t_install(e):
    """(coordinator, 2026-10-10) The slot menu's install from the card (1E op 2, a MISSING slot whose machine is on the
    card) answered READY is no machine choice: the tracks that played the slot keep their words when its 1A (READY) comes
    (P2 99 written back before stays; an assign would give 77)."""
    ev, t = meta_events(100, [P.meta_messages(1, 5, P.ST_MISSING, P.FLAG_ON_CARD, "ATARI", "ATAR")])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 3)))
    ev2, t2 = walk_list(t + 100, UI["downs"]["u1"])
    ev += ev2 + [(t2, "usb", P.knobs(0, 1, [(1, 99)]))]
    ev2, t3 = open_menu(t2 + 300)
    ev += ev2 + [(t3, "press", "YES"),
                 (t3 + 30, "usb", b"".join(P.list_messages(0, P.LIST_INSTALLED, 3, ["SINE TEST"]))),
                 (t3 + 80, "usb", P.slots([6, 0, 0, 0, 0], 3, 1, P.RES_READY)),
                 (t3 + 300, "usb", b"".join(P.meta_messages(1, 6, P.ST_READY, 0, "ATARI", "ATAR", "",
                                                            [dict(p=2, long="Two", short="TWO", default=77)], fp=FP_A))),
                 (t3 + 400, "press", "NO"), (t3 + 500, "press", "NO")]
    s = e.run("install", t3 + 800, ev, save=True)
    sent = assigns(e)
    check("install: YES on U1 (MISSING, on the card) sends 1E install (op 2)", bool(sent) and sent[-1]["op"] == P.OP_INSTALL,
          str(sent))
    got = kit16(e, s)
    check("install: READY, then its 1A - BD's U1 keeps P2 99 (no defaults), no tag written, named ATARI",
          got[1] == 99 and word0(e, s) == (0, 0) and e.cstr(s, sym("us_l1")) == "ATARI" and pslots(e, s)[:1] == [0],
          f"{got} {word0(e, s)} {e.cstr(s, sym('us_l1'))} {pslots(e, s)}")


# ---- the sound tag (the user's decision, 2026-10-10; mods/0021-ext/sound-tag-research.md): a U-sound carries its
# plugin's fingerprint in sound index 0 - the kit's live word 0 (track t: 0x41255921 + 152 t) and the project copy's
# slot 41 (0x40765981 + 162 t) - written only when the user chooses the slot (us_defaults); ext_render appends the
# owner track's word 0 (0x8000e5b0 + 84 t) to 0x04 / 0x03 as two 7-bit bytes
FP_A, FP_B = P.plugin_fp("rytm.choose"), P.plugin_fp("rytm.other")


def word0(e, s, t=0):
    """Track t's sound tag: (the kit 0 sound's live +0x6e, the project copy's slot 47 at +0x7a). Since 2026-10-16 the
    tag is no longer sound index 0 (the Sidecar's SEND FX 1/2): rytm-teensy 2026-10-16-sidecar-send-fx-storage.md."""
    k, p = e.peek(s, 0x4125597b + 152 * t, 2), e.peek(s, 0x4076598d + 162 * t, 2)
    return int.from_bytes(k, "big"), int.from_bytes(p, "big")


def index0(e, s, t=0):
    """Track t's sound index 0 (SEND FX 1/2): (the kit 0 sound's live word, the project copy's slot 41)."""
    k, p = e.peek(s, 0x41255921 + 152 * t, 2), e.peek(s, 0x40765981 + 162 * t, 2)
    return int.from_bytes(k, "big"), int.from_bytes(p, "big")


def trigs(e):
    """The decoded 0x04 reports of the last run, with their lengths."""
    return [dict(P.decode_trig_params(m[5:-1]) or {}, n=len(m)) for m in e.sent if len(m) > 20 and m[4] == P.TRIG_PARAMS]


def u1_fp(fp, gen=5):
    return P.meta_messages(1, gen, P.ST_READY, P.FLAG_PARAMS, "CHOOSE", "CHS", "CHS PAGE 2", CH_KNOBS, fp=fp)


def chosen(e, name, msgs=None):
    """U1 (1A with FP_A, current) chosen on BD in the machine list; -> (snapshot, its clock after the base)."""
    ev, t = meta_events(100, [msgs or u1_fp(FP_A)])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    ev2, t2 = walk_list(t + 100, UI["downs"]["u1"])
    return e.run(name, t2, ev + ev2, save=True), t2


def keys(at, seq):
    """Key events from at: a name presses it (100 M apart), an int waits that long (M)."""
    ev, t = [], at
    for k in seq:
        if isinstance(k, int):
            t += k
            continue
        ev.append((t, "press", k))
        t += UI["step_M"]
    return ev, t


def sound_manager(at, pool, load):
    """The SOUND menu (FUNC + MUTE), back to its top, SOUND MANAGER: pool - LEFT, VIEW POOL, entry 1; else the +Drive
    library (A:001..A:128 are write-protected factory sounds): FUNC held, 20 UPs to its top and 20 DOWNs (7 a page) to
    A:141, empty. Then the entry's menu (RIGHT): load - LOAD TO TRACK, confirmed; else STORE TRK SOUND (pool: REPLACE
    confirmed) / SAVE TRK SOUND (an empty entry), the name and the tags screen saved; NO NO. Measured in rytm-emu (us1,
    2026-10-10)."""
    ev = [(at, "press", "FUNC:300M"), (at + 20, "press", "MUTE")]
    ev2, t = keys(at + 400, ["UP", "UP", "DOWN", "YES"] + (["LEFT", "YES"] if pool else []) + [100])
    if not pool:
        ev2.append((t, "press", "FUNC:5200M"))
        ev2 += [(t + 50 + 120 * i, "press", "UP" if i < 20 else "DOWN") for i in range(40)]
        t += 5400
    seq = ["RIGHT"] + (["YES", 100, "YES", 200] if load else
                       (["DOWN", "DOWN", "YES", 100, "YES", 100] if pool else ["YES", 100]) + ["YES", 100, "YES", 200]) + ["NO", 50, "NO", 50]
    ev3, t = keys(t, seq)
    return ev + ev2 + ev3, t


def t_tag(e):
    """(sound tag) U1 chosen with a 1A carrying fp: kit word 0 and project slot 41 hold fp; the next trig's 0x04 (43 B)
    carries it."""
    s, t = chosen(e, "tag-chosen")
    check("tag: U1 chosen with fp in 1A - BD's kit word 0 and project slot 41 hold it",
          word0(e, s) == (FP_A, FP_A), f"{word0(e, s)}, fp {FP_A:#x}")
    e.run("tag", 500, [(50, "press", "BD"), (200, "turn", (f"{UI['knob_enc']['A']}:+5", 4, 8))], snap=s, start=e.clock + t)
    tr = [x for x in trigs(e) if x.get("machine") == 0x50]
    check("tag: BD's trig - 0x04 of 43 bytes, U1, its tag fp", bool(tr) and tr[-1]["n"] == 43 and tr[-1]["tag"] == FP_A,
          str(tr[-1:]))
    pr = [dict(P.decode_params(m[5:-1]) or {}, n=len(m)) for m in e.sent if len(m) > 20 and m[4] == P.PARAMS]
    pr = [x for x in pr if x.get("machine") == 0x50]
    check("tag: knob A turned after the trig - 0x03 reports of 41 bytes, U1, the tag fp",
          bool(pr) and all(x["n"] == 41 and x["tag"] == FP_A for x in pr), f"{len(pr)} reports, last {pr[-1:]}")


def t_tagpool(e):
    """(sound tag) The tagged U-sound saved and loaded keeps its tag: to the +Drive library (A:141) and loaded onto SD;
    to the project's sound pool (entry 1) and loaded onto RS (SOUND MANAGER's STORE TRK SOUND / LOAD TO TRACK)."""
    s, t = chosen(e, "tagpool-chosen")
    for name, pool, track, pad in (("tagpool-drive", False, 1, "SD"), ("tagpool-pool", True, 2, "RS")):
        ev, t2 = sound_manager(50, pool, load=False)
        s2 = e.run(name + "-stored", t2 + 100, ev, snap=s, start=e.clock + t, save=True)
        if pool:
            pw = (int.from_bytes(e.peek(s2, 0x41313cb5, 2), "big"), int.from_bytes(e.peek(s2, 0x407bd331, 2), "big"),
                  e.peek(s2, 0x41313caf, 1)[0])
            check("tagpool: BD stored to pool entry 1 - the pool's live (0x41313c47) and stored (0x407bd2b7) copies hold "
                  "the tag, machine 35", pw == (FP_A, FP_A, 35), str(pw))
        ev2, t3 = sound_manager(t2 + 300, pool, load=True)
        s3 = e.run(name, t3 + 200, ev + [(t2 + 150, "press", pad)] + ev2, snap=s, start=e.clock + t, save=True)
        got = (e.peek(s3, 0x41255975 + 152 * track, 1)[0],) + word0(e, s3, track)
        check(f"tagpool: {'pool entry 1' if pool else '+Drive A:141'} loaded onto {pad} - machine 35, kit word 0 and "
              f"project slot 41 the tag", got == (35, FP_A, FP_A), f"{got}, fp {FP_A:#x}")


def t_taglock(e):
    """(sound tag) A sound lock from a pool sound tagged with another plugin's fp: the slot now says FP_B, pool entry 1
    holds BD's U1 sound tagged FP_A; RS (a stock track) locks entry 1 on step 1 - its 0x04 is U1's and carries FP_A,
    the pool sound's own tag (the Teensy compares it: no load hook sees a lock)."""
    s, t = chosen(e, "taglock-chosen")
    ev, t2 = sound_manager(50, True, load=False)
    ev += [(t2 + 100, "usb", b"".join(u1_fp(FP_B, 6))), (t2 + 250, "usb", P.slots([6, 0, 0, 0, 0], 0))]
    t2 += 400
    ev += [(t2, "press", "RS"), (t2 + 200, "press", "RECORD"), (t2 + 400, "press", "T1:400M"), (t2 + 900, "press", "RECORD"),
           (t2 + 1100, "press", "PLAY"), (t2 + 2300, "press", "STOP")]
    # LEVEL/DATA (encoder 8) while T1 is held: the lock list opens on TRACK SOUND, four nudges reach 1 (measured)
    s2 = e.run("taglock", t2 + 2500, ev, snap=s, start=e.clock + t, save=True,
               extra=["--nudge", f"8:1@{e.clock + t + t2 + 460}Mx4/40M"])
    tr = [x for x in trigs(e) if x.get("machine") == 0x50]
    check("taglock: RS's locked step plays U1 (0x04 with 0x50) carrying the pool sound's tag FP_A, not the slot's FP_B",
          bool(tr) and all(x["tag"] == FP_A for x in tr) and FP_A != FP_B, f"{tr}, A {FP_A:#x} B {FP_B:#x}")
    check("taglock: the 1A with FP_B wrote no tag (BD keeps FP_A)", word0(e, s2) == (FP_A, FP_A), str(word0(e, s2)))


def t_tagname(e):
    """(sound tag) !NAME: the selected track's kit word 0 is not the slot's fp (a 1A for another plugin): the machine
    list's names read !CHOOSE / !CHS; another track selected (stock): CHOOSE again."""
    s, t = chosen(e, "tagname-chosen")
    check("tagname: U1 with its own tag - CHOOSE", (e.cstr(s, sym("us_l1")), e.cstr(s, sym("us_s1"))) == ("CHOOSE", "CHS"))
    ev = [(50, "usb", b"".join(u1_fp(FP_B, 6))), (200, "usb", P.slots([6, 0, 0, 0, 0], 0))]
    ev2, t2 = walk_list(400, 0, confirm=False)   # the list open on U1, to look (PNG tagname)
    s2 = e.run("tagname", t2, ev + ev2, snap=s, start=e.clock + t, save=True)
    got = (e.cstr(s2, sym("us_l1")), e.cstr(s2, sym("us_s1")))
    check("tagname: U1's 1A now FP_B, BD's word 0 FP_A - !CHOOSE / !CHS (PNG tagname)", got == ("!CHOOSE", "!CHS"),
          f"{got}, word 0 {word0(e, s2)}")
    s3 = e.run("tagname-sd", 400, ev + [(300, "press", "SD")], snap=s, start=e.clock + t, save=True)
    got = (e.cstr(s3, sym("us_l1")), e.peek(s3, 0x41318982, 1)[0])
    check("tagname: SD selected (a stock machine) - CHOOSE again", got == ("CHOOSE", 1), str(got))


def t_untagged(e):
    """(sound tag) An untagged U-sound (word 0 = 0: chosen with an older Teensy's 1A, no fp) under a slot whose 1A says
    FP_B: no '!', its 0x04 carries tag 0 (allowed: it plays)."""
    s, t = chosen(e, "untagged-chosen", u1_meta()[0])
    check("untagged: chosen with a 1A without fp - word 0 is 0", word0(e, s) == (0, 0), str(word0(e, s)))
    ev = [(50, "usb", b"".join(u1_fp(FP_B, 6))), (200, "usb", P.slots([6, 0, 0, 0, 0], 0)), (400, "press", "BD")]
    s2 = e.run("untagged", 700, ev, snap=s, start=e.clock + t, save=True)
    tr = [x for x in trigs(e) if x.get("machine") == 0x50]
    check("untagged: no '!' (CHOOSE / CHS)", (e.cstr(s2, sym("us_l1")), e.cstr(s2, sym("us_s1"))) == ("CHOOSE", "CHS"))
    check("untagged: BD's 0x04 is 43 bytes with tag 0", bool(tr) and tr[-1]["n"] == 43 and tr[-1]["tag"] == 0, str(tr[-1:]))


def t_tagkeep(e):
    """(sound tag) Only a choice writes the tag: a plain 1A (another fp), a 1C and a kit load (RELOAD KIT of the kit
    saved with FP_A) leave word 0 as it was."""
    s, t = chosen(e, "tagkeep-chosen")
    ev, t2 = kit_menu(50, 2)   # SAVE KIT
    ev += [(t2 + 200, "press", "YES"), (t2 + 400, "press", "YES")]
    t2 += 1000
    ev += [(t2, "usb", b"".join(u1_fp(FP_B, 6))), (t2 + 150, "usb", P.slots([6, 0, 0, 0, 0], 0)),
           (t2 + 300, "usb", P.knobs(0, 1, [(1, 99)]))]
    s2 = e.run("tagkeep-1a", t2 + 500, ev, snap=s, start=e.clock + t, save=True)
    check("tagkeep: a 1A with FP_B (committed: us_l1 !CHOOSE) and a 1C (P2 99) - word 0 still FP_A in both copies",
          word0(e, s2) == (FP_A, FP_A) and kit16(e, s2)[1] == 99 and e.cstr(s2, sym("us_l1")) == "!CHOOSE",
          f"{word0(e, s2)} {kit16(e, s2)[1]} {e.cstr(s2, sym('us_l1'))}")
    ev2, t3 = kit_menu(t2 + 500, 0)   # RELOAD KIT
    ev2 += [(t3 + 200, "press", "YES")]
    s3 = e.run("tagkeep", t3 + 800, ev + ev2, snap=s, start=e.clock + t, save=True, count=[0x4011f6bc])
    check("tagkeep: RELOAD KIT (one load) - word 0 FP_A from the saved kit, not the slot's FP_B; P2 back to the saved",
          e.counts.get(0x4011f6bc) == 1 and word0(e, s3) == (FP_A, FP_A) and kit16(e, s3)[1] != 99,
          f"{e.counts.get(0x4011f6bc)} {word0(e, s3)} {kit16(e, s3)[1]}")


def t_tag14(e):
    """(sound tag, review) Words of 0x4000 or more (0004-lfo-rnd's LFO RND packed there by an older build) compare by their
    low 14 bits, as the Teensy reads the two 7-bit bytes: no '!' when the low bits are the slot's fp or 0, '!' when they
    are another fp; the 0x04 carries the low 14 bits."""
    s, t = chosen(e, "tag14-chosen")
    rest = e.peek(s, 0x4125597d, 2)   # the 2 bytes after the tag (poke writes 4 bytes)
    for name, w, bang in (("tag14-fp", 0x4000 | FP_A, False), ("tag14-zero", 0xc000, False),
                          ("tag14-other", 0x4000 | FP_B, True)):
        poke = f"4125597b={w:04x}{rest.hex()}"
        s2 = e.run(name, 400, [(250, "press", "BD")], snap=s, start=e.clock + t, save=True, extra=["--poke", poke])
        tr = [x for x in trigs(e) if x.get("machine") == 0x50]
        got = (e.cstr(s2, sym("us_l1")), word0(e, s2)[0])
        check(f"{name}: word 0 {w:#06x} (low 14 bits {w & 0x3fff:#x}, slot fp {FP_A:#x}) - "
              f"{'!CHOOSE' if bang else 'CHOOSE'}, the 0x04's tag {w & 0x3fff:#x}",
              got == ("!CHOOSE" if bang else "CHOOSE", w) and bool(tr) and tr[-1]["tag"] == w & 0x3fff, f"{got} {tr[-1:]}")


def t_tagpower(e):
    """(sound tag, review) The tagged U-sound stored to the project's sound pool (entry 1), then the power goes: the cold
    boot keeps the tag in BD's kit word 0, its project copy and the pool's live and stored copies."""
    s, t = chosen(e, "tagpower-chosen")
    c = card_copy(e, "tagpower")
    ev, t2 = sound_manager(50, True, load=False)
    e.run("tagpower-before", t2 + 1100, ev, snap=s, start=e.clock + t, card=c,
          extra=["--power-off", f"{e.clock + t + t2 + 1000}M"])
    s2 = e.run("tagpower", 4400, cold=True, card=c, save=True)
    got = (e.peek(s2, 0x8000ea00, 1)[0],) + word0(e, s2) + (int.from_bytes(e.peek(s2, 0x41313cb5, 2), "big"),
                                                          int.from_bytes(e.peek(s2, 0x407bd331, 2), "big"))
    check("tagpower: after the cold boot - BD on U1, kit word 0, project slot 41, pool entry 1's live and stored copies "
          "all the tag", got == (35, FP_A, FP_A, FP_A, FP_A), f"{got}, fp {FP_A:#x}")


def bd_tags(e):
    """The tags of the last run's U1 0x04s (BD), in order."""
    return [x["tag"] for x in trigs(e) if x.get("machine") == 0x50]


def bd_params(e):
    """The last U1 0x04 (BD)'s P1..P16, integer parts (the 0x04 carries 14 bits: value << 7)."""
    tr = [x for x in trigs(e) if x.get("machine") == 0x50]
    return [p >> 7 for p in tr[-1]["params"]] if tr else []


def live16(e, s, t=0):
    """Track t's P1..P16 in the live array the voice plays (0x8000e5b0 + 84 t, sound indices 9..24), integer parts."""
    return list(e.peek(s, 0x8000e5b0 + 84 * t + 18, 32)[0::2])


def fc58(e, s, t=0):
    """0x8000fc58[t]: the kit last copied into track t's live array (-1: the next trig copies)."""
    return int.from_bytes(e.peek(s, 0x8000fc58 + 4 * t, 4), "big", signed=True)


def t_assigntrig(e):
    """(sound tag, E2E bug 2) The slot menu's assign on a track that has trigged: BD on U1 (FP_A) trigged, U1 assigned to
    V2 TEST (READY, its 1A with FP_B), BD trigged again - the second 0x04 carries FP_B. A trig copies the kit sound into
    0x8000e5b0 only when 0x8000fc58[t] is not the kit it plays; us_defaults sets it to -1, as a sound lock's step does."""
    sine = [dict(p=2, long="Two", short="TWO", default=20)]
    ev, t = meta_events(100, [P.meta_messages(1, 5, P.ST_READY, 0, "SINE TEST", "SINE", "", sine, fp=FP_A)])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 3)))
    ev2, t2 = walk_list(t + 100, UI["downs"]["u1"])
    ev += ev2 + [(t2 + 50, "press", "BD")]
    ev2, t3 = open_menu(t2 + 300)
    v2 = [dict(p=2, long="Two", short="TWO", default=77)]
    ev += ev2 + [(t3, "press", "YES"),
                 (t3 + 30, "usb", b"".join(P.list_messages(0, P.LIST_INSTALLED, 3, ["SINE TEST", "V2 TEST"]))),
                 (t3 + 80, "usb", P.slots([6, 0, 0, 0, 0], 3, 1, P.RES_READY)),
                 (t3 + 300, "usb", b"".join(P.meta_messages(1, 6, P.ST_READY, 0, "V2 TEST", "V2T", "", v2, fp=FP_B))),
                 (t3 + 400, "press", "NO"), (t3 + 450, "press", "BD"), (t3 + 500, "press", "NO"), (t3 + 800, "press", "BD")]
    s = e.run("assigntrig", t3 + 1000, ev, save=True)
    tags = bd_tags(e)
    arr = int.from_bytes(e.peek(s, sym("us_tag"), 2), "big")   # us_tag[0] (was the live word 0)
    check("assigntrig: BD trigged on U1 (FP_A), U1 assigned to V2 TEST (FP_B), BD again - the 0x04s carry FP_A then FP_B, "
          "word 0 and 0x8000e5b0 FP_B", tags[:1] == [FP_A] and tags[-1:] == [FP_B] and len(tags) >= 3
          and word0(e, s) == (FP_B, FP_B) and arr == FP_B and e.cstr(s, sym("us_l1")) == "V2 TEST",
          f"tags {[hex(x) for x in tags]}, word 0 {word0(e, s)}, e5b0 {arr:#x}, A {FP_A:#x} B {FP_B:#x}")
    # review (HIGH 1): BD trigged at the 1A + 150M, while the kit words are still queued (US_COMMIT) - the trig must
    # not copy the old kit words over the live array (b4a8f74's -1 in 0x8000fc58 did: P2 stayed 20)
    got = (bd_params(e)[:2], live16(e, s)[:8], kit16(e, s)[:8])
    check("assigntrig: BD trigged at the 1A + 150M too - the last 0x04 and the live array hold V2 TEST's defaults "
          "(P1 64, P2 77), as the kit", got[0] == [64, 77] and got[1] == got[2] and got[2][:2] == [64, 77], str(got))


def t_choosetrig(e):
    """(sound tag, E2E bug 2) The other writers on a track that has trigged (BD on its stock machine first, word 0 = 0):
    the machine list's YES, the SOUND menu's MACHINE step and the delayed 1A (choose-late) - BD's next 0x04 carries FP_A."""
    pre = [(50, "press", "BD")]
    s = e.run("choosetrig-first", 150, pre, save=True)
    check("choosetrig: the precondition - after BD's first trig 0x8000fc58[0] holds the kit copied (not -1)",
          fc58(e, s) == 0, str(fc58(e, s)))
    ev, t = meta_events(150, [u1_fp(FP_A)])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    ev2, t2 = walk_list(t + 100, UI["downs"]["u1"])
    s = e.run("choosetrig-list", t2 + 300, pre + ev + ev2 + [(t2 + 100, "press", "BD")], save=True)
    tags = bd_tags(e)
    check("choosetrig-list: BD trigged, U1 chosen in the machine list, BD again - the 0x04 carries FP_A and the defaults, "
          "the live array the defaults", tags[-1:] == [FP_A] and word0(e, s) == (FP_A, FP_A) and bd_params(e) == CH_WANT
          and live16(e, s) == CH_WANT, f"tags {[hex(x) for x in tags]}, word 0 {word0(e, s)}, {bd_params(e)} {live16(e, s)}")
    ev2 = [(t + 100, "press", "FUNC:300M"), (t + 120, "press", "FLTR")]
    t2 = t + 500
    for _ in range(UI["sound_rights_to_u1"]):
        ev2.append((t2, "press", "RIGHT"))
        t2 += UI["step_M"]
    ev2 += [(t2 + 100, "press", "NO"), (t2 + 300, "press", "BD")]
    s = e.run("choosetrig-sound", t2 + 500, pre + ev + ev2, save=True)
    tags = bd_tags(e)
    check("choosetrig-sound: BD trigged, U1 stepped to in the SOUND menu, BD again - the 0x04 carries FP_A and the "
          "defaults, the live array the defaults", tags[-1:] == [FP_A] and word0(e, s) == (FP_A, FP_A)
          and bd_params(e) == CH_WANT and live16(e, s) == CH_WANT,
          f"tags {[hex(x) for x in tags]}, word 0 {word0(e, s)}, {bd_params(e)} {live16(e, s)}")
    ev2, t2 = walk_list(150, UI["downs"]["u1"])
    ev2 += [(t2 + 50, "press", "BD"), (t2 + 150, "usb", b"".join(u1_fp(FP_A))), (t2 + 240, "press", "BD"),
            (t2 + 450, "press", "BD")]
    s = e.run("choosetrig-late", t2 + 650, pre + ev2, save=True)
    tags = bd_tags(e)
    check("choosetrig-late: U1 chosen before its 1A, BD trigged (tag 0), the 1A (FP_A), BD again - the 0x04 carries FP_A",
          tags[:1] == [0] and tags[-1:] == [FP_A] and word0(e, s) == (FP_A, FP_A),
          f"tags {[hex(x) for x in tags]}, word 0 {word0(e, s)}")
    # review (HIGH 1): one of those trigs at the 1A + 90M, while the kit words are still queued
    got = (bd_params(e), live16(e, s), kit16(e, s))
    check("choosetrig-late: BD trigged at the 1A + 90M too - the last 0x04 and the live array hold the defaults, as the kit",
          got[0] == CH_WANT and got[1] == CH_WANT and got[2] == CH_WANT, str(got))


def t_tagkit1(e):
    """(sound tag, review HIGH 2) On pattern A02 (kit 1: 0x800067b8 = 1), U1 chosen on BD: the tag goes into kit 1's BD
    word 0 (0x4125597b + 2531), kit 0's stays as it was; the trig carries it; !NAME compares kit 1's word."""
    k1 = 0x4125597b + 2531
    pre = [(50, "press", "BANK_A:300M"), (150, "press", "T2")]
    ev, t = meta_events(600, [u1_fp(FP_A)])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    ev2, t2 = walk_list(t + 100, UI["downs_kit1"]["u1"])
    s = e.run("tagkit1", t2 + 300, pre + ev + ev2 + [(t2 + 100, "press", "BD")], save=True)
    kit = e.u32(s, 0x800067b8)
    # the applied kit 0x8000fc8c (us_defaults' check): the audio interrupt follows 0x800067b8 there on a switch
    applied = (e.u32(e.snap, 0x800067b8), e.u32(e.snap, 0x8000fc8c), kit, e.u32(s, 0x8000fc8c))
    check("tagkit1: the applied kit 0x8000fc8c follows 0x800067b8 - 0 and 0 on the base, 1 and 1 on A02",
          applied == (0, 0, 1, 1), str(applied))
    w1, w0 = int.from_bytes(e.peek(s, k1, 2), "big"), int.from_bytes(e.peek(s, 0x4125597b, 2), "big")
    base0 = int.from_bytes(e.peek(e.snap, 0x4125597b, 2), "big")
    kit0 = (list(e.peek(s, 0x41255933, 32)[0::2]), kit16(e, e.snap))
    k1w = list(e.peek(s, 0x41255933 + 2531, 32)[0::2])
    check("tagkit1: A02 plays kit 1, BD on U1 - kit 1's BD P1..P16 the defaults and word 0 FP_A, the project copy's slot "
          "41 FP_A; kit 0's BD word 0 and words as before",
          kit == 1 and e.peek(s, 0x8000ea00, 1)[0] == 35 and k1w == CH_WANT and w1 == FP_A and word0(e, s)[1] == FP_A
          and w0 == base0 and kit0[0] == kit0[1],
          f"kit {kit}, kit 1 {k1w} w0 {w1:#x}, proj {word0(e, s)[1]:#x}, kit 0 w0 {w0:#x} (base {base0:#x}) {kit0[0]}")
    tags = bd_tags(e)
    check("tagkit1: BD's trig on kit 1 carries FP_A, the live word 0 too", tags[-1:] == [FP_A]
          and int.from_bytes(e.peek(s, sym("us_tag"), 2), "big") == FP_A, f"tags {[hex(x) for x in tags]}")
    # !NAME: kit 0's BD word 0 made FP_B (another plugin's sound in the kit not playing; poke writes 4 bytes) - the compare
    # must read kit 1's word (FP_A), not kit 0's
    poke = ["--poke", f"4125597b={FP_B:04x}{e.peek(s, 0x4125597d, 2).hex()}"]
    s2 = e.run("tagkit1-same", 300, snap=s, start=e.clock + t2 + 300, save=True, extra=poke)
    got = (e.cstr(s2, sym("us_l1")), int.from_bytes(e.peek(s2, 0x4125597b, 2), "big"))
    check("tagkit1: kit 0's BD word FP_B, kit 1's FP_A, the slot's 1A FP_A - CHOOSE (kit 1's word compared)",
          got == ("CHOOSE", FP_B), str(got))
    ev = [(50, "usb", b"".join(u1_fp(FP_B, 6))), (200, "usb", P.slots([6, 0, 0, 0, 0], 0))]
    ev2, t3 = walk_list(400, 0, confirm=False)
    s2 = e.run("tagkit1-name", t3, ev + ev2, snap=s, start=e.clock + t2 + 300, save=True, extra=poke)
    got = (e.cstr(s2, sym("us_l1")), e.cstr(s2, sym("us_s1")))
    check("tagkit1: kit 0's BD word FP_B, U1's 1A now FP_B, kit 1's BD word FP_A - !CHOOSE / !CHS (PNG tagkit1-name)",
          got == ("!CHOOSE", "!CHS"), str(got))
    c = card_copy(e, "tagkit1")
    e.run("tagkit1-off", 300, snap=s, start=e.clock + t2 + 300, card=c, extra=["--power-off", f"{e.clock + t2 + 300 + 100}M"])
    s3 = e.run("tagkit1-cold", 4400, cold=True, card=c, save=True)
    got = (e.u32(s3, 0x800067b8), e.peek(s3, 0x8000ea00, 1)[0], int.from_bytes(e.peek(s3, k1, 2), "big"),
           int.from_bytes(e.peek(s3, 0x4125597b, 2), "big"), word0(e, s3)[1])
    # the project copy (0x40765981 + 162 t) is the active kit's working copy: the power-off saves it as kit 1, and kit 0
    # comes back from the card (measured: b4a8f74, whose kit store went to kit 0, also comes up with FP_A in kit 1 here)
    check("tagkit1: power-off and cold boot - kit 1 active, BD on U1, kit 1's BD word 0 FP_A, kit 0's as before, the "
          "project copy (the active kit's) FP_A", got == (1, 35, FP_A, base0, FP_A), str(got))


def t_freshtrig(e):
    """(review 2026-10-11, MEDIUM 4) A track not trigged since boot (0x8000fc58 -1: its next trig copies the kit sound)
    chooses U1 (1A current) and is trigged within a few M instructions, before kit_param_changed's queue drains: the
    copy must bring the defaults (us_defaults stores the knob words straight into the active kit), so the 0x04 and the
    live array hold them. Several trig times, measured to land in that window on b2beef3's us1 (the old words then)."""
    check("freshtrig: the precondition - BD not trigged since boot (0x8000fc58[0] -1 on the base)", fc58(e, e.snap) == -1,
          str(fc58(e, e.snap)))
    ev, t = meta_events(100, [u1_fp(FP_A)])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    ev2, t2 = walk_list(t + 100, UI["downs"]["u1"])
    yes = t2 - UI["settle_M"] - UI["step_M"]   # the list's YES
    for d in UI["freshtrig_after_yes_M"]:
        s = e.run(f"freshtrig-{d}", yes + d + 150, ev + ev2 + [(yes + d, "press", "BD")], save=True)
        got = (bd_params(e), live16(e, s), kit16(e, s))
        check(f"freshtrig: BD trigged {d}M after the YES - the 0x04 and the live array hold U1's defaults, as the kit",
              got[0] == CH_WANT and got[1] == CH_WANT and got[2] == CH_WANT and word0(e, s) == (FP_A, FP_A),
              f"{got} {word0(e, s)}")


def t_installfail(e):
    """(review 2026-10-11, MEDIUM 6) The slot menu's install from the card that fails: U1 MISSING on the card, YES sends
    1E install (op 2), the Teensy answers NOT ON CARD; the next YES steps to the installed machine (op 0) instead of
    installing again, so a slot whose install keeps failing can still be reassigned; an install answered by nothing
    (NO SIDECAR) the same."""
    ev, t = meta_events(100, [P.meta_messages(1, 5, P.ST_MISSING, P.FLAG_ON_CARD, "ATARI", "ATAR")])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 3)))
    lst = b"".join(P.list_messages(0, P.LIST_INSTALLED, 3, ["SINE TEST"]))
    ev2, t2 = open_menu(t + 100)
    ev += ev2 + [(t2, "press", "YES"), (t2 + 30, "usb", lst),
                 (t2 + 80, "usb", P.slots([5, 0, 0, 0, 0], 3, 1, P.RES_NOT_ON_CARD)),
                 (t2 + 300, "press", "NO"), (t2 + 400, "press", "YES"),
                 (t2 + 480, "usb", P.slots([6, 0, 0, 0, 0], 3, 1, P.RES_READY))]
    e.run("installfail", t2 + 700, ev)
    sent = assigns(e)
    check("installfail: YES on U1 (MISSING, on the card) installs (op 2); answered NOT ON CARD, the next YES assigns "
          "the installed machine (op 0, entry 0)", [a["op"] for a in sent] == [P.OP_INSTALL, P.OP_ASSIGN]
          and sent[-1]["arg"] == 0, str(sent))
    ev = ev[:-3] + [(t2 + 300, "press", "NO"), (t2 + 400, "press", "YES"),
                    (t2 + 480, "usb", P.slots([5, 0, 0, 0, 0], 3, 1, P.RES_READY))]
    ev = [x for x in ev if not (x[1] == "usb" and t2 + 50 < x[0] < t2 + 100)]   # no answer to the install
    e.run("installfail-none", t2 + 900, ev)
    sent = assigns(e)
    check("installfail: an install with no answer (NO SIDECAR after 2 s), the next YES assigns (op 0)",
          [a["op"] for a in sent] == [P.OP_INSTALL, P.OP_ASSIGN], str(sent))
    ev, t = meta_events(100, [P.meta_messages(1, 5, P.ST_MISSING, P.FLAG_ON_CARD, "ATARI", "ATAR")])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 3)))
    ev2, t2 = open_menu(t + 100)
    ev += ev2 + [(t2, "press", "YES"), (t2 + 30, "usb", lst), (t2 + 80, "usb", P.slots([5, 0, 0, 0, 0], 3, 1, P.RES_LOADING)),
                 (t2 + 300, "press", "NO"), (t2 + 400, "press", "YES"), (t2 + 480, "usb", P.slots([5, 0, 0, 0, 0], 3, 1, P.RES_READY))]
    e.run("installfail-loading", t2 + 700, ev)
    sent = assigns(e)
    check("installfail: an install answered LOADING is no failure - the next YES (still MISSING) installs again (op 2)",
          [a["op"] for a in sent] == [P.OP_INSTALL, P.OP_INSTALL], str(sent))
    # (review 2026-10-11, LOW 2) an install that never went out (the list in the last 300 ms: no 1E) is no failure
    # either - the next YES installs (op 2), not steps past it
    ev, t = meta_events(100, [P.meta_messages(1, 5, P.ST_MISSING, P.FLAG_ON_CARD, "ATARI", "ATAR")])
    ev.append((t, "usb", P.slots([5, 0, 0, 0, 0], 3)))
    ev2, t2 = open_menu(t + 100)
    ev += ev2 + [(t2, "press", "YES"), (t2 + 400, "usb", lst), (t2 + 600, "press", "YES"),
                 (t2 + 680, "usb", P.slots([6, 0, 0, 0, 0], 3, 1, P.RES_READY))]   # (after a NO before it, this YES reached no action: measured)
    e.run("installfail-unsent", t2 + 1000, ev)
    sent = assigns(e)
    check("installfail: the first YES's list too late (no 1E), the next YES installs (op 2): the slot was not marked failed",
          [a["op"] for a in sent] == [P.OP_INSTALL], str(sent))


def t_shortpart(e):
    """(review 2026-10-11, LOW 9) A 1A knob part that is not whole 24-byte entries (one byte short) is dropped: the slot's
    1A never completes (USER 1, P1..P8), and the next whole one commits (NP CLUST1, Algorithm)."""
    msgs = P.meta_messages(1, 5, P.ST_READY, 0, "NP CLUST1", "NPC1", "", NP_KNOBS)
    short = [msgs[0]] + [m[:-2] + m[-1:] for m in msgs[1:]]   # each knob part one byte short
    s = e.run("shortpart", 600, [(100, "usb", b"".join(short))], save=True)
    got = (e.cstr(s, sym("us_l1")), e.cstr(s, e.u32(s, rec(334) + 40), 13))
    check("shortpart: knob parts one byte short - not committed (USER 1, P1)", got == ("USER 1", "P1"), str(got))
    s = e.run("shortpart-whole", 300, [(50, "usb", b"".join(msgs))], snap=s, start=e.clock + 600, save=True)
    got = (e.cstr(s, sym("us_l1")), e.cstr(s, e.u32(s, rec(334) + 40), 13))
    check("shortpart: then whole parts - committed (NP CLUST1, Algorithm)", got == ("NP CLUST1", "Algorithm"), str(got))


def t_kitguard(e):
    """(review 2026-10-11, MEDIUM 1) us_defaults' direct kit-word stores are guarded: U1 chosen on BD before its 1A, then
    the active kit made kit 1 (0x800067b8 and the applied 0x8000fc8c both 1, poked: a pattern's kit switch that landed
    after us_tick3's checks, the live tracks still kit 0's) whose BD plays a stock machine (its kit sound's machine byte
    +0x68): when the 1A lands, kit 1's BD words 0..24 stay as they were. The control, unpoked: kit 0 takes them."""
    k1 = 0x41255921 + 2531   # kit 1's BD word 0
    ev, t = walk_list(100, UI["downs"]["u1"])
    s = e.run("kitguard-pend", t + 50, ev, save=True)
    m1 = e.peek(s, 0x4125590d + 2531 + 0x68, 1)[0]
    check("kitguard: the precondition - BD on U1 waiting for its 1A (pslot 1), kit 1's BD a stock machine (+0x68)",
          e.peek(s, 0x8000ea00, 1)[0] == 35 and pslots(e, s)[:1] == [1] and m1 < 35
          and e.peek(s, 0x4125590d + 0x68, 1)[0] == 35, f"pslots {pslots(e, s)}, kit 1 BD machine {m1}")
    before = e.peek(s, k1, 50)
    ev = [(50, "usb", b"".join(u1_fp(FP_A)))]
    poke = ["--poke", "800067b8=1", "--poke", "8000fc8c=1"]
    s2 = e.run("kitguard", 300, ev, snap=s, start=e.clock + t + 50, save=True, extra=poke)
    got = e.peek(s2, k1, 50)
    check("kitguard: the 1A lands with kit 1 active, its BD stock - the choice was taken (pslot 0), kit 1's BD words "
          "0..24 unchanged", pslots(e, s2)[:1] == [0] and e.u32(s2, 0x800067b8) == 1 and got == before,
          f"pslots {pslots(e, s2)}, kit {e.u32(s2, 0x800067b8)}, kit 1 BD {list(got[18::2])} (was {list(before[18::2])})")
    s2 = e.run("kitguard-control", 300, ev, snap=s, start=e.clock + t + 50, save=True)
    got = kit16(e, s2)
    check("kitguard: the control (no poke) - kit 0's BD takes U1's defaults and FP_A", got == CH_WANT
          and word0(e, s2) == (FP_A, FP_A), f"{got} {word0(e, s2)}")


TESTS = {"base": t_base,"exciter": t_exciter, "variants": t_variants, "takeover": t_takeover, "enum": t_enum,
         "names": t_names, "labels": t_labels, "unused": t_unused, "dspmod": t_dspmod, "junopat": t_junopat, "writeback": t_writeback, "texts": t_texts,
         "page2": t_page2, "poweroff": t_poweroff, "stock": t_stock, "strict": t_strict, "menu": t_menu,
         "choose": t_choose, "assign": t_assign, "stale": t_stale, "sound": t_sound, "load": t_load, "window": t_window,
         "tag": t_tag, "tagpool": t_tagpool, "taglock": t_taglock, "tagname": t_tagname, "untagged": t_untagged,
         "tagkeep": t_tagkeep, "install": t_install, "tag14": t_tag14, "tagpower": t_tagpower,
         "assigntrig": t_assigntrig, "choosetrig": t_choosetrig, "tagkit1": t_tagkit1, "assigngen": t_assigngen,
         "freshtrig": t_freshtrig, "installfail": t_installfail, "shortpart": t_shortpart, "kitguard": t_kitguard}


def main():
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    if len(sys.argv) < 3 or any(t not in TESTS for t in names):
        sys.exit(__doc__ + "\nTESTS: all " + " ".join(TESTS))
    e = Emu(sys.argv[1])
    for t in names:
        print(f"-- {t}: {TESTS[t].__doc__.splitlines()[0]}")
        TESTS[t](e)
    print(f"\n{'ALL PASS' if not fails else 'FAILED: ' + ', '.join(fails)}")
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
