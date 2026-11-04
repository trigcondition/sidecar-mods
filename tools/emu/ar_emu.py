#!/usr/bin/env python3
"""Emulator tests of the arpeggiator's Rytm half (backlog 7ae; rytm-teensy core/arp/arp.h): the code in the sound (0021's load and save, stored slot 46, live +0x6d and the
two bits above the tag), 45 both ways (0026, 0022's router), UP + FLTR's 30 page 4, no Sidecar.

    RYTM_EMU=... RYTM_TEENSY=... .venv/bin/python tools/emu/ar_emu.py TAG TEST [TEST ...]|all

TAG: a rui build with its base from tools/emu/us_base.sh TAG.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import us_emu as US   # noqa: E402

def check(what, ok, detail=""):
    US.check(what, ok, str(detail))


SX = bytes.fromhex("f07d5254")
KIT = 0x4125597a          # kit 0, track 0: live +0x6d
KIT_STEP, SND = 2531, 152
PROJ = 0x4076598b         # the project copy, track 0: stored slot 46
PROJ_SND = 162
A, B = 0x2A5, 0x31A       # codes with both top bits' patterns


def msg45(t, c):
    return SX + bytes([0x45, 1, t, c & 0x7F, c >> 7, 0xF7])


def live(e, s, t=0, k=0):
    b = e.peek(s, KIT + KIT_STEP * k + SND * t, 2)
    return (b[1] >> 6) << 8 | b[0]


def proj(e, s, t=0):
    b = e.peek(s, PROJ + PROJ_SND * t, 2)
    return b[0] << 8 | b[1]


def reports(e):
    return [(m[6], m[7] | m[8] << 7) for m in e.sent if len(m) == 10 and m[4] == 0x45]


def setcode(e, name, t, c):
    s = e.run(name, 400, [(100, "usb", msg45(t, c))], save=True)
    return s, 400


def t_wire(e):
    """45 written: the live sound and the project copy of the active kit; the Rytm says it back. Other tracks untouched. A hello's 45s: every track."""
    s, t = setcode(e, "ar-wire", 1, A)
    check("wire: track 1's live sound", live(e, s, 1) == A, hex(live(e, s, 1)))
    check("wire: its project copy, stored slot 46", proj(e, s, 1) == A, hex(proj(e, s, 1)))
    check("wire: no other track", all(live(e, s, x) == 0 for x in (0, 2, 11)))
    check("wire: reported back", (1, A) in reports(e), reports(e))
    e.run("ar-wire2", 300, [(50, "usb", msg45(1, B))], snap=s, start=e.clock + t, save=True)
    check("wire: a second write reported", (1, B) in reports(e), reports(e))


def t_bad(e):
    """Malformed 45s: nothing written, the next good one is."""
    ev = [(100, "usb", SX + bytes([0x45, 1, 12, 1, 0, 0xF7])), (120, "usb", SX + bytes([0x45, 1, 0, 1, 8, 0xF7])), (140, "usb", SX + bytes([0x45, 1, 0, 1, 0xF7])),
          (160, "usb", msg45(0, 5))]
    s = e.run("ar-bad", 400, ev, save=True)
    check("bad: only the good one", live(e, s, 0) == 5 and proj(e, s, 0) == 5, (live(e, s, 0), proj(e, s, 0)))


def t_tag(e):
    """A U sound's tag and the code live side by side: the choice keeps the code, the tag reads whole, a report's tag is the fingerprint."""
    s, t = US.chosen(e, "ar-tag-chosen")
    s2 = e.run("ar-tag", 400, [(50, "usb", msg45(0, 0x3FF))], snap=s, start=e.clock + t, save=True)
    t += 400
    w, st = US.word0(e, s2)
    check("tag: both: the tag under the code's bits, slot 47 the tag alone", w & 0x3FFF == US.FP_A and st == US.FP_A, (hex(w), hex(st)))
    e.run("ar-tag-trig", 500, [(50, "press", "BD")], snap=s2, start=e.clock + t)
    tr = [x for x in US.trigs(e) if x.get("machine") == 0x50]
    check("tag: the trig's tag is the fingerprint", bool(tr) and tr[-1]["tag"] == US.FP_A, str(tr[-1:]))
    check("tag: the code stayed", live(e, s2) == 0x3FF and proj(e, s2) == 0x3FF, hex(live(e, s2)))
    ev, t2 = US.walk_list(50, US.UI["downs"]["u1"])
    s3 = e.run("ar-tag-again", t2, ev, snap=s2, start=e.clock + t, save=True)
    check("tag: choosing the machine again keeps the code", live(e, s3) == 0x3FF, hex(live(e, s3)))


def t_kit(e):
    """SAVE KIT, a new code, RELOAD KIT: the saved code back in the sound and reported."""
    s, t = setcode(e, "ar-kit0", 0, A)
    ev, t2 = US.kit_menu(50, 2)   # SAVE KIT
    ev += [(t2 + 200, "press", "YES"), (t2 + 400, "press", "YES")]
    s2 = e.run("ar-kit-save", t2 + 1000, ev, snap=s, start=e.clock + t, save=True)
    t += t2 + 1000
    s3 = e.run("ar-kit-other", 300, [(50, "usb", msg45(0, B))], snap=s2, start=e.clock + t, save=True)
    t += 300
    check("kit: a new code", live(e, s3) == B, hex(live(e, s3)))
    ev, t2 = US.kit_menu(50, 0)   # RELOAD
    ev += [(t2 + 200, "press", "YES")]
    s4 = e.run("ar-kit-reload", t2 + 900, ev, snap=s3, start=e.clock + t, save=True)
    check("kit: RELOAD KIT: the saved code", live(e, s4) == A, hex(live(e, s4)))
    check("kit: reported", (0, A) in reports(e), reports(e))


def t_pool(e):
    """The sound to the project's pool and loaded onto RS, to the +Drive library and loaded onto SD: the code comes with it. A sound without one loaded over: 0."""
    s, t = setcode(e, "ar-pool0", 0, B)
    for name, pool, track, pad in (("ar-drive", False, 1, "SD"), ("ar-pool", True, 2, "RS")):
        ev, t2 = US.sound_manager(50, pool, load=False)
        ev2, t3 = US.sound_manager(t2 + 300, pool, load=True)
        s3 = e.run(name, t3 + 300, ev + [(t2 + 150, "press", pad)] + ev2, snap=s, start=e.clock + t, save=True)
        check(f"pool: {name}: the code on {pad}", live(e, s3, track) == B, hex(live(e, s3, track)))
        check(f"pool: {name}: reported", (track, B) in reports(e), reports(e))


def t_power(e):
    """Power off and a cold boot: the code from the project copy. The switch of kit between (A02's kit 1) reports that kit's, 0, and back."""
    s, t = setcode(e, "ar-pw0", 0, A)
    c = US.card_copy(e, "ar-power")
    e.run("ar-power-off", 1100, [], snap=s, start=e.clock + t, card=c, extra=["--power-off", f"{e.clock + t + 1000}M"])
    s2 = e.run("ar-power", 4400, cold=True, card=c, save=True)
    check("power: after the cold boot", live(e, s2) == A, hex(live(e, s2)))


def t_fresh(e):
    """No kit of the base reads a code: the old and fresh sounds are 0 (the load's slot 46, sound_init_defaults' clear)."""
    b = e.peek(e.snap, KIT, KIT_STEP * 128)
    bad = [(k, t) for k in range(128) for t in range(12) if b[KIT_STEP * k + SND * t] or b[KIT_STEP * k + SND * t + 1] >> 6]
    check("fresh: every kit's every sound 0", not bad, bad[:6])


def t_old(e):
    """A card from the last release, booted on this build: every code 0, a hello reports them so."""
    old = os.path.join(US.EMU, "sections", "us_rel0-3-1.img")
    if not os.path.exists(old):
        check("old: the 0.3.1 card is there", False, old)
        return
    c = os.path.join(e.tmp, "old.img")
    US.shutil.copy(old, c)
    s = e.run("ar-old", 4400, cold=True, card=c, save=True)
    b = e.peek(s, KIT, KIT_STEP * 128)
    bad = [(k, t) for k in range(128) for t in range(12) if b[KIT_STEP * k + SND * t] or b[KIT_STEP * k + SND * t + 1] >> 6]
    check("old: every kit's every sound 0", not bad, bad[:6])
    check("old: no 45 says otherwise", all(c == 0 for t, c in reports(e)), reports(e))


def t_up(e):
    """UP + FLTR opens the page on 30 page 4, the Rytm's FLTR page does not open under it; TRK + FLTR and FLTR alone stay stock's: no 30."""
    e.run("ar-up", 400, [(50, "press", "UP:60M"), (70, "press", "FLTR")])
    m = [x for x in e.sent if x[4] == 0x30]
    check("up: 30 page 4 on", bool(m) and m[0][6] == 4 and m[0][7] == 1, [x.hex() for x in m])
    e.run("ar-fltr", 400, [(70, "press", "FLTR")])
    check("up: FLTR alone sends no 30", not [x for x in e.sent if x[4] == 0x30])


def t_hello(e):
    """35 from the Rytm comes with caps bit 3 (the host's ARP page checks it); a 3A open owes the codes again."""
    s, t = setcode(e, "ar-h0", 3, A)
    e.run("ar-h1", 400, [(50, "usb", SX + bytes([0x3A, 1, 0, 1, 0xF7]))], snap=s, start=e.clock + t)
    r = reports(e)
    check("hello: an open reports all twelve", sorted(x for x, _ in r) == list(range(12)) and (3, A) in r, r)


def t_trig(e):
    """A trig whose code the Rytm has not said from ext_render: 45 straight before its 04, none before the next trig. The kit byte it reads is the kit played."""
    s, t = US.chosen(e, "ar-trig-chosen")
    s2 = e.run("ar-trig0", 400, [(50, "usb", msg45(0, A))], snap=s, start=e.clock + t, save=True)
    t += 400
    check("trig: the trig's kit byte is the active kit", e.peek(s2, 0x42ade134, 1)[0] == e.peek(s2, 0x800067b8, 4)[3], e.peek(s2, 0x42ade134, 1).hex())
    s3 = e.run("ar-trig", 700, [(50, "press", "BD"), (300, "press", "BD")], snap=s2, start=e.clock + t, save=True)
    seq = [m[4] for m in e.sent if m[4] in (0x45, 0x04)]
    print(f"  {[hex(x) for x in seq]}")
    i = seq.index(0x04) if 0x04 in seq else -1
    check("trig: 45 then 04", i > 0 and seq[i - 1] == 0x45, seq)
    check("trig: its code", any(m[4] == 0x45 and m[6:9] == bytes([0, A & 0x7F, A >> 7]) for m in e.sent))
    check("trig: the next trig has none before it", seq.count(0x04) >= 2 and seq[i + 1:].count(0x45) == 0, seq)
    s4 = e.run("ar-trig2", 400, [(50, "usb", msg45(0, B)), (52, "press", "BD")], snap=s3, start=e.clock + t + 700)
    seq = [(m[4], m[7] | m[8] << 7 if m[4] == 0x45 else 0) for m in e.sent if m[4] in (0x45, 0x04)]
    check("trig: an edit said before the trig, or by the tick: the host hears B", (0x45, B) in seq, seq)


def t_kitmove(e):
    """A 45 from the host waits for the next UI tick; a kit that lands before it: the edit is not written into that kit. The kit moved by a poke of the active kit's
    word, between a run that ended with the 45 queued and the tick; found by ending the run at each M after the 45 until the control (no poke) still writes."""
    s, t = setcode(e, "ar-km0", 0, A)
    kit = e.peek(s, 0x800067b8, 4)
    other = bytes([kit[0], kit[1], kit[2], kit[3] ^ 1])
    was = live(e, s, 0, other[3])
    n = 0
    for end in range(10, 40):
        s2 = e.run(f"ar-km1{end}", end, [(5, "usb", msg45(0, B))], snap=s, start=e.clock + t, save=True)
        if live(e, s2) == B:
            continue                     # the tick ran: too late
        c = e.run(f"ar-kmc{end}", 60, snap=s2, start=e.clock + t + end, save=True)
        if live(e, c) != B:
            continue                     # still in the USB path: not queued yet (the poke would come first)
        p = e.run(f"ar-kmp{end}", 60, snap=s2, start=e.clock + t + end, save=True, extra=["--poke", f"800067b8={other.hex()}"])
        n += 1
        check(f"kitmove: {end} M: not written into the kit that came", live(e, p, 0, other[3]) == was, hex(live(e, p, 0, other[3])))
        check(f"kitmove: {end} M: nor into the one it was for (its report stands)", live(e, p, 0, kit[3]) == A, hex(live(e, p, 0, kit[3])))
    check("kitmove: the window was hit", n > 0, n)


TESTS = dict(kitmove=t_kitmove, trig=t_trig, wire=t_wire, bad=t_bad, tag=t_tag, kit=t_kit, pool=t_pool, power=t_power, fresh=t_fresh, old=t_old, up=t_up, hello=t_hello)


def main():
    tag = sys.argv[1]
    names = sys.argv[2:]
    e = US.Emu(tag)
    for n in (list(TESTS) if not names or names == ["all"] else names):
        print(f"== {n}")
        TESTS[n](e)
    print(f"\nar: {'ALL PASS' if not US.fails else 'FAILED: ' + str(len(US.fails))}")
    sys.exit(1 if US.fails else 0)


if __name__ == "__main__":
    main()
