#!/usr/bin/env python3
"""Emulator tests of the MD page (0021-ext: machine 42; the Sidecar's docs/MD-BUILTIN.md) in rytm-emu, no Sidecar: the
host's answers are built here from the tables the host answers with (plugins/mdkit/md_tables.h) and injected.

    tools/emu/md_emu.py TAG all | TEST ...     (RYTM_EMU, RYTM_TEENSY as tools/emu/us_emu.py; base: tools/emu/us_base.sh TAG)
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import us_emu as U     # noqa: E402  (Emu, check, the protocol module as U.P)
import ostarget        # noqa: E402  (us_emu put tools/ on the path: the tree's OS, address_in)
import sfx_emu as S    # noqa: E402  (pokes, poke_boot)

P = U.P
UI = U.UI
check = U.check
DOWNS_MD = 22             # the machine list from BD PLASTIC to machine 42 (tools/emu/us_ui.json's note: DIGIDRUM 22)
MD_TAG = 0x224D
REC_MD = 390
P2REC = [438, 457, 458, 459, 460, 403, 404, 405]   # page 2's shared records (0021 us_p2rec)
KIT = 0x41255933          # kit 0's BD word 9 (P1); + 152 t a track, + 2 i a P
TAG_KIT = 0x41255921 + 0x5a
TAG_PROJ = 0x4076598d
REC_PROJ = 0x40765913     # BD's project-copy record (stored format, 162 B a track): words at +0x14.. as slots
BASE, COUNT = (0, 8, 17), (8, 9, 13)


def tables():
    """md_tables.h: the TYPE names and each set's eight (long, short) labels."""
    src = open(os.path.join(U.TEENSY, "plugins", "mdkit", "md_tables.h")).read()
    names = re.findall(r'"([^"]*)"', src[src.index("mdt_type_names"):src.index("mdt_label")])
    body = src[src.index("mdt_label"):]
    lab = re.findall(r'\{"([^"]*)", "([^"]*)"\}', body)
    return names[:30], [lab[8 * i:8 * i + 8] for i in range(30)]


def defaults():
    """MD-BUILTIN.md section 4's table: set -> eight defaults (a control the TYPE lacks: 0)."""
    src = open(os.path.join(U.TEENSY, "docs", "MD-BUILTIN.md")).read()
    out = {}
    for m in re.finditer(r"^\| (\d+) \| (?:FM|PI|TRX) \| \w+ \| (.*) \|$", src, re.M):
        out[int(m.group(1))] = [0 if x.strip() == "-" else int(x) for x in m.group(2).split("|")]
    return [out[i] for i in range(30)]


TYPE_NAMES, LABELS = tables()
DEFAULTS = defaults()


def gen_of(s):
    return 1 + s


def meta(e_, t_):
    """The 1A the host answers for ENGINE e_, TYPE index t_ (core/md/md.cpp on_ask)."""
    s = BASE[e_] + t_
    knobs = []
    for k in range(8):
        lng, sh = LABELS[s][k]
        knobs.append(dict(p=k + 1, look="dial", kind="number", long=lng, short=sh, default=DEFAULTS[s][k],
                          **({} if lng else dict(max=0))))
    knobs.append(dict(p=9, look="list", kind="enum", long="Engine", short="ENG", enum_count=3))
    knobs.append(dict(p=10, look="list", kind="enum", long="Type", short="TYPE", enum_count=COUNT[e_]))
    knobs.append(dict(p=11, look="fader", kind="number", long="Level", short="LEV", default=100))
    for p in range(12, 17):
        knobs.append(dict(p=p, look="dial", kind="number", long="", short="", max=0))
    return P.meta_messages(0x40 + e_, gen_of(s), P.ST_READY, P.FLAG_PARAMS, "MD", "MD", "MD ENGINE", knobs, fp=0)


def lists(e_, g):
    tn = TYPE_NAMES[BASE[e_]:BASE[e_] + COUNT[e_]]
    return P.list_messages(0x40 + e_, 8, g, ["FM", "PI", "TRX"]) + P.list_messages(0x40 + e_, 9, g, tn)


def answers(at, e_, t_):
    """Events: the answers of a page opening on ENGINE e_, TYPE t_: the 1A, then both lists once it is committed (a 1B goes
    by the cache's generation; the host sends them to the page's asks, after its 1A)."""
    return [(at, "usb", b"".join(meta(e_, t_))), (at + 80, "usb", b"".join(lists(e_, gen_of(BASE[e_] + t_))))]


def kit16(e, s, t=0):
    return U.kit16(e, s, t)


def tag_kit(e, s, t=0):
    return int.from_bytes(e.peek(s, TAG_KIT + 152 * t, 2), "big")


def tag_proj(e, s, t=0):
    return int.from_bytes(e.peek(s, TAG_PROJ + 162 * t, 2), "big")


def marker(e, s, t=0):
    """The second marker: P15's and P16's fractions in the kit."""
    b = e.peek(s, KIT + 152 * t + 28, 4)
    return b == bytes([0, 0x4d, 0, 0x44])


def tag_live(e, s, t=0):
    return int.from_bytes(e.peek(s, U.sym("us_tag") + 2 * t, 2), "big")


def rec_names(e, s, recs=None):
    """Short names of the records."""
    return [e.cstr(s, e.u32(s, U.rec(r) + 48), 5) for r in (recs or range(REC_MD, REC_MD + 8))]


def src_row(e, s, at=0x40287ccc + 36 * 42):
    """Machine 42's SRC page row (0x40287cc8 + 36 m: name, 8 records); `at`: where it is in e's image."""
    b = e.peek(s, at, 32)
    return [int.from_bytes(b[i:i + 4], "big") for i in range(0, 32, 4)]


def chosen(e, name, extra=()):
    """MD chosen on BD in the machine list (YES), then the host's FM BD answers; -> (snapshot, clock after the base)."""
    ev, t = U.walk_list(100, DOWNS_MD)
    ev = ev + answers(t, 0, 0)
    t += 300
    return e.run(name, t, ev + list(extra), save=True), t


def t_list(e):
    """The machine is named MD in the list; the cursor previews it without any conversion; NO leaves all as it was."""
    ev, t = U.walk_list(100, DOWNS_MD, confirm=False)
    s = e.run("list-preview", t + 300, ev, save=True)
    check("list: the cursor is on machine 42", e.peek(s, 0x8000ea00, 1)[0] == 42, str(e.peek(s, 0x8000ea00, 1)[0]))
    check("list: 42's names are MD / MD", (e.cstr(s, e.u32(s, 0x401bf0f4)), e.cstr(s, e.u32(s, 0x401bf0f8))) == ("MD", "MD"))
    got = kit16(e, s)
    check("list: previewing converts nothing: no tag, P9..P11 not ENGINE TYPE LEV 0 0 100", tag_kit(e, s) == 0 and
          got[8:11] != [0, 0, 100], f"tag {tag_kit(e, s):#x} {got}")
    check("list: no label ask while the cursor previews", not any(a and a["slot"] >= 0x40 for a in e.asks()), str(e.asks()[:4]))
    s2 = e.run("list-held", 400, snap=s, start=e.clock + t + 300, save=True)
    check("list: a long preview still converts nothing", tag_kit(e, s2) == 0 and kit16(e, s2)[8:11] == got[8:11])
    s3 = e.run("list-no", 300, [(50, "press", "NO")], snap=s2, start=e.clock + t + 700, save=True)
    check("list: NO: back on BD's machine, untagged, nothing written", e.peek(s3, 0x8000ea00, 1)[0] < 35 and tag_kit(e, s3) == 0,
          f"{e.peek(s3, 0x8000ea00, 1)[0]} tag {tag_kit(e, s3):#x}")


def t_fresh(e):
    """A confirmed choice: FM BD fresh (P1..P8 set 0's defaults, P9 P10 0, P11 100, the rest 0), the tag in the kit, the
    project copy and the reports; the 04 is MD-BUILTIN.md's 43 bytes with 44 4D."""
    ev, t = U.walk_list(100, DOWNS_MD)
    ev.append((t + 200, "press", "BD"))
    s = e.run("fresh", t + 500, ev, save=True)
    want = DEFAULTS[0] + [0, 0, 100, 0, 0, 0, 0, 0]
    check("fresh: BD's sixteen words are FM BD's", kit16(e, s) == want, str(kit16(e, s)))
    check("fresh: tag 0x224D in the kit, the project copy and us_tag", (tag_kit(e, s), tag_proj(e, s), tag_live(e, s)) ==
          (MD_TAG, MD_TAG, MD_TAG), f"{tag_kit(e, s):#x} {tag_proj(e, s):#x} {tag_live(e, s):#x}")
    tr = [m for m in e.sent if len(m) > 20 and m[4] == 0x04]
    check("fresh: a trig: 04 of 43 B, voice flag 0x40, ending 44 4D F7", bool(tr) and len(tr[-1]) == 43 and tr[-1][5] & 0x78 == 0x40
          and tr[-1][-3:] == b"\x44\x4d\xf7", tr[-1].hex() if tr else "none")
    if tr:
        ps = [tr[-1][8 + 2 * i] for i in range(16)]
        check("fresh: its P1..P16 are the words", ps == want, str(ps))
    asks = [a for a in e.asks() if a and a["slot"] == 0x40]
    check("fresh: the page asks for its labels: 19 slot 0x40, what 0, arg 0 (TYPE value)", any(a["what"] == 0 and a["arg"] == 0 for a in asks),
          str(asks[:4]))
    proj = kit16(e, s)
    s2 = e.run("fresh-drain", 200, snap=s, start=e.clock + t + 500, save=True)
    pw = list(e.peek(s2, REC_PROJ + 0x1c, 32)[0::2])
    check("fresh: the words reach the project copy (the drain)", pw == proj, f"{pw} (kit {proj})")


def t_sound(e):
    """The SOUND menu's MACHINE item: a step onto 42 is a choice."""
    ev = [(100, "press", "FUNC:300M"), (120, "press", "FLTR")]
    t = 500
    for _ in range(UI["sound_rights_to_u1"] + 7):
        ev.append((t, "press", "RIGHT"))
        t += UI["step_M"]
    s = e.run("sound", t + 300, ev, save=True)
    m = e.peek(s, 0x8000ea00, 1)[0]
    check("sound: BD stepped onto 42, set up fresh", m == 42 and tag_kit(e, s) == MD_TAG and kit16(e, s)[:11] == DEFAULTS[0] + [0, 0, 100],
          f"machine {m} tag {tag_kit(e, s):#x} {kit16(e, s)}")


def t_labels(e):
    """Labels: P1..P8 take each of the 30 TYPEs' short and long names from a 1A, a control the TYPE lacks draws as stock's
    unused box (record 0 in the SRC row), P9..P11 on page 2 (SMPL), ENGINE / TYPE lists from 1B, under strict."""
    s, t = chosen(e, "labels-chosen")
    n0 = rec_names(e, s)
    check("labels: FM BD's on the SRC records", n0 == [x[1] for x in LABELS[0]], str(n0))
    check("labels: P9 P10 P11's records named ENG TYPE LEV, all of FM BD's eight in the row", rec_names(e, s, P2REC[:3]) == ["ENG", "TYPE", "LEV"]
          and src_row(e, s) == list(range(390, 398)), f"{rec_names(e, s, P2REC[:3])} {src_row(e, s)}")
    for ei, ti in [(ei, ti) for ei in range(3) for ti in range(COUNT[ei])]:
        st = BASE[ei] + ti
        s2 = e.run(f"labels-{st}", 60, [(10, "usb", b"".join(meta(ei, ti)))], snap=s, start=e.clock + t, save=True)
        got, row = rec_names(e, s2), src_row(e, s2)
        lng = [e.cstr(s2, e.u32(s2, U.rec(REC_MD + k) + 40), 13) for k in range(8)]
        want = [x[1] for x in LABELS[st]]
        wr = [REC_MD + k if LABELS[st][k][0] else 0 for k in range(8)]
        check(f"labels: {'FM PI TRX'.split()[ei]} {TYPE_NAMES[st]}: short names, long names, unused boxes",
              [g for g, r in zip(got, wr) if r] == [x for x in want if x] and row == wr and
              [g for g, r in zip(lng, wr) if r] == [x[0] for x in LABELS[st] if x[0]], f"{got} {row} {lng}")
    # SRC with TRX BD's labels on screen (look at the PNG), and page 2
    s3 = e.run("labels-src", 200, answers(10, 2, 12) + [(150, "press", "SRC")], snap=s, start=e.clock + t, save=True,
               env={"DTEMU_STRICT": "1"})
    s4 = e.run("labels-smpl", 200, answers(10, 0, 0) + [(150, "press", "SMPL")], snap=s, start=e.clock + t, save=True,
               env={"DTEMU_STRICT": "1"})
    us = U.sym("us") + 4 * 7
    c = e.u32(s4, us)
    eknob = e.peek(s4, c + U.sym("us_off_en") - 16, 16)
    check("labels: MD's cache holds both lists: P9's 3 names, P10's 8", 8 in eknob[:8] and 9 in eknob[:8] and
          eknob[8 + eknob.index(8)] == 3 and eknob[8 + eknob.index(9)] == 8, eknob.hex())
    print(f"  look at build/emu/{e.tag}/labels-src.png (TRX B2's page) and labels-smpl.png (MD ENGINE: FM BD LEV 100)")


def t_nohost(e):
    """Without a Sidecar the page still works: FM BD set up, ENGINE / TYPE / LEV as numbers on SMPL (P9..P11), nothing hangs."""
    ev, t = U.walk_list(100, DOWNS_MD)
    s = e.run("nohost", t + 400, ev + [(t + 100, "press", "SMPL"), (t + 200, "turn", ("2:+8", 3, 10))], save=True,
              env={"DTEMU_STRICT": "1"})
    check("nohost: FM BD fresh", tag_kit(e, s) == MD_TAG and kit16(e, s)[:8] == DEFAULTS[0], str(kit16(e, s)))
    check("nohost: knob C moves LEV", kit16(e, s)[10] != 100, str(kit16(e, s)))
    print(f"  look at build/emu/{e.tag}/nohost.png")


def step(enc):
    """One detent of a list knob: a slow turn (as sfu_emu's "one")."""
    return f"{enc}:+8", 3, 10


def t_stops(e):
    """On SMPL ENGINE stops at 0 43 86, TYPE at the doc's zone lo's for each ENGINE; LEV is plain; the reports follow."""
    s, t = chosen(e, "stops-chosen")
    lo = {i: [(z * 128 + COUNT[i] - 1) // COUNT[i] for z in range(COUNT[i])] for i in range(3)}
    snap, clock = s, e.clock + t
    ev, seen_e = [(10, "press", "SMPL")], []

    def go(name, events, n=450):
        nonlocal snap, clock
        snap = e.run(name, n, events, snap=snap, start=clock, save=True)
        clock += n
        return kit16(e, snap)

    for ei in range(3):
        k = go(f"stops-{ei}", ev + answers(60, ei, 0))
        ev = []
        seen = [k[9]]
        for i in range(COUNT[ei] + 4):   # a slow turn is one detent or, now and then, none or two (the panel's accumulator)
            seen.append(go(f"stops-{ei}-{i}", [(50, "turn", step(1))], 300)[9])
        check(f"stops: ENGINE {ei}: TYPE's values are the zones' lo's up to the top, {lo[ei][-1]}", seen[-1] == lo[ei][-1] and set(seen) <= set(lo[ei]),
              str(seen))
        for i in range(3):   # ENGINE one up; TYPE keeps its raw value (the doc's rule), which the next ENGINE reads in its zones
            k = go(f"stops-{ei}-e{i}", [(50, "turn", step(0))], 300)
            if k[8] != seen_e[-1:] and k[8] not in seen_e:
                seen_e.append(k[8])
            if k[8] != (0, 43, 86)[ei]:
                break
        k9 = k[9]
        check(f"stops: ENGINE {ei}: TYPE keeps its raw value over the change", k9 == lo[ei][-1], str(k9))
        for i in range(COUNT[ei] + 4):   # TYPE back down for the next ENGINE
            if go(f"stops-{ei}-d{i}", [(50, "turn", (f"1:-8", 3, 10))], 300)[9] == 0:
                break
    check("stops: ENGINE stops at 0, 43, 86", seen_e[:2] == [43, 86], str(seen_e))
    k = go("stops-lev", [(20, "turn", ("2:-8", 4, 8)), (200, "press", "BD")])
    tr = [m for m in e.sent if len(m) > 20 and m[4] == 0x04]
    check("stops: LEV (knob C) moves and the trig carries it; P12..P16 stay 0", k[10] != 100 and bool(tr) and tr[-1][8 + 20] == k[10]
          and k[11:] == [0] * 5, f"{k} {tr[-1].hex() if tr else None}")


def t_ask(e):
    """TYPE turned: 19 with the new value and the held generation; an 'unchanged' 7F is harmless; the lists asked once."""
    s, t = chosen(e, "ask-chosen")
    ev = [(10, "press", "SMPL"), (100, "turn", step(1))]
    s2 = e.run("ask", 300, ev, snap=s, start=e.clock + t, save=True)
    a = [x for x in e.asks() if x and x["slot"] == 0x40 and x["what"] == 0]
    check("ask: a TYPE step asks again: slot 0x40, gen FM BD's (1), arg the new value 16", any(x["arg"] == 16 and x["gen"] == 1 for x in a),
          str(a))
    s3 = e.run("ask-sd", 200, [(10, "usb", b"".join(meta(0, 1)))], snap=s2, start=e.clock + t + 300, save=True)
    check("ask: the 1A for FM SD relabels the SRC records", rec_names(e, s3)[2] == LABELS[1][2][1], str(rec_names(e, s3)))
    a = [x for x in e.asks() if x and x["slot"] == 0x40 and x["what"] == 1]
    check("ask: the same ENGINE's lists are not asked again", not a, str(a))
    un = P.meta_unchanged(0x40, 2)
    s4 = e.run("ask-7f", 100, [(10, "usb", un)], snap=s3, start=e.clock + t + 500, save=True)
    check("ask: 7F changes nothing", rec_names(e, s4)[2] == LABELS[1][2][1])


def t_plock(e):
    """p-locks reach the 04: step 1 with a lock on P2 (SRC, knob B) and on P10 (SMPL, knob B): that step's 04 carries the
    locks with the MD tag, step 5's the sound's own values."""
    s, t = chosen(e, "plock-chosen")
    ev = [(20, "press", "RECORD"), (150, "press", "T1:300M"), (200, "turn", ("1:+8", 10, 5)), (500, "press", "SMPL"),
          (560, "press", "T1:300M"), (610, "turn", ("1:+8", 20, 5)), (900, "press", "T5"), (1000, "press", "RECORD"),
          (1100, "press", "PLAY"), (3100, "press", "STOP")]
    s2 = e.run("plock", 3300, ev, snap=s, start=e.clock + t, save=True)
    tr = [x for x in U.trigs(e) if x.get("machine") == 0x40]
    check("plock: the trigs carry the tag", len(tr) >= 2 and all(x["tag"] == MD_TAG for x in tr), str(tr[:3]))
    k = kit16(e, s2)
    p2 = {x["params"][1] >> 7 for x in tr}
    p10 = {x["params"][9] >> 7 for x in tr}
    check("plock: P2's lock on its step reaches the 04, the other step the sound's value", k[1] in p2 and len(p2) == 2, f"{p2} (sound {k[1]})")
    check("plock: P10's (TYPE) lock on SMPL likewise", k[9] in p10 and len(p10) == 2, f"{p10} (sound {k[9]})")


def t_kit(e):
    """Save and reload: the words, marker and tag survive SAVE KIT + RELOAD; a pool store and LOAD TO TRACK carry the tag."""
    s, t = chosen(e, "kit-chosen", extra=[])
    ev = [(10, "press", "SMPL"), (100, "turn", step(1)), (250, "press", "SRC"), (300, "turn", ("3:-8", 6, 8))]
    s1 = e.run("kit-edit", 800, ev, snap=s, start=e.clock + t, save=True)
    edited = kit16(e, s1)
    check("kit: the edit took (TYPE 16, knob D moved)", edited[9] == 16 and edited[3] != DEFAULTS[0][3], str(edited))
    ev2, t2 = U.kit_menu(50, 2)
    ev2 += [(t2 + 200, "press", "YES"), (t2 + 400, "press", "YES")]
    ev3, t3 = U.kit_menu(t2 + 1000, 0)
    ev3 += [(t3 + 200, "press", "YES")]
    s2 = e.run("kit-reload", t3 + 800, ev2 + ev3, snap=s1, start=e.clock + t + 800, save=True, count=[0x4011f6bc])
    check("kit: SAVE KIT, RELOAD: one load, the words as saved, the tag and the marker kept", e.counts.get(0x4011f6bc) == 1 and kit16(e, s2) == edited and
          tag_kit(e, s2) == MD_TAG and marker(e, s2), f"{e.counts.get(0x4011f6bc)} {kit16(e, s2)} {tag_kit(e, s2):#x}")
    ev4, t4 = U.sound_manager(50, True, load=False)
    s3 = e.run("kit-store", t4 + 100, ev4, snap=s2, start=e.clock + t + 800 + t3 + 800, save=True)
    check("kit: the pool's entry 1 holds the tag", int.from_bytes(e.peek(s3, 0x41313cb5, 2), "big") == MD_TAG, e.peek(s3, 0x41313cb5, 2).hex())


def t_paste(e):
    """A sound loaded onto a track: an MD pool sound is MD there; one stored untagged stays as it is (no conversion on load)."""
    s, t = chosen(e, "paste-chosen")
    ev, t2 = U.sound_manager(50, True, load=False)
    s1 = e.run("paste-store", t2 + 100, ev, snap=s, start=e.clock + t, save=True)
    clock = e.clock + t + t2 + 100
    ev2, t3 = U.sound_manager(100, True, load=True)
    ev2 = [(20, "press", "SD")] + ev2 + [(t3 + 200, "press", "SD"), (t3 + 400, "press", "SD")]   # (its machine byte follows a trig or two)
    s2 = e.run("paste-load", t3 + 700, ev2, snap=s1, start=clock, save=True)
    check("paste: LOAD TO TRACK onto SD: machine 42, the tag and words as stored", e.peek(s2, 0x8000ea00, 2)[1] == 42 and tag_kit(e, s2, 1) == MD_TAG
          and kit16(e, s2, 1)[:11] == DEFAULTS[0] + [0, 0, 100], f"{e.peek(s2, 0x8000ea00, 2).hex()} {tag_kit(e, s2, 1):#x} {kit16(e, s2, 1)}")
    # the pool's entry made an older build's: tag 0, no marker, P1 in zone 3
    pool = 0x41313c47 + 0x26   # entry 1's P1 in the live pool (the kit format)
    ed = {0x407bd331: b"\0\0", 0x41313cb5: b"\0\0", pool: bytes([40, 0, 11, 0]), pool + 2 * 14: bytes(4)}
    s3 = e.run("paste-load2", t3 + 700, ev2, snap=s1, start=clock, save=True, extra=S.pokes(e, s1, ed))
    k = kit16(e, s3, 1)
    check("paste: an untagged pool sound on 42 stays untagged, its words as stored", e.peek(s3, 0x8000ea00, 2)[1] == 42 and tag_kit(e, s3, 1) == 0 and k[:2] == [40, 11], f"{tag_kit(e, s3, 1):#x} {k}")
    tr = [x for x in U.trigs(e) if x.get("machine") == 0x40]
    check("paste: its trigs report tag 0", bool(tr) and all(x["tag"] == 0 for x in tr), str(tr[-1:]))


def t_tracks(e):
    """Two tracks on MD with different TYPEs: selecting one asks for its ENGINE and TYPE."""
    s, t = chosen(e, "tracks-chosen")
    ev = [(20, "press", "SD")]
    ev2, t2 = U.walk_list(120, DOWNS_MD + UI["downs_sd"]["u1"] - UI["downs"]["u1"])
    s1 = e.run("tracks-sd", t2 + 100, ev + ev2, snap=s, start=e.clock + t, save=True)
    m = e.peek(s1, 0x8000ea00, 2)
    check("tracks: SD on 42 as well", m[1] == 42, m.hex())
    clock = e.clock + t + t2 + 100
    ev3 = [(10, "press", "SMPL"), (100, "turn", step(1)), (200, "turn", step(1)), (300, "press", "SRC")]
    s2 = e.run("tracks-type", 450, ev3, snap=s1, start=clock, save=True)
    check("tracks: SD's TYPE two stops up (32)", kit16(e, s2, 1)[9] == 32, str(kit16(e, s2, 1)))
    clock += 450
    e.run("tracks-bd", 200, [(20, "press", "BD")], snap=s2, start=clock)
    a = [x for x in e.asks() if x and x["slot"] == 0x40 and x["what"] == 0]
    check("tracks: selecting BD asks for its TYPE value 0", any(x["arg"] == 0 for x in a), str(a))
    e.run("tracks-sd2", 200, [(20, "press", "SD")], snap=s2, start=clock)
    a = [x for x in e.asks() if x and x["slot"] == 0x40 and x["what"] == 0]
    check("tracks: SD stays asked with its own (32), no ask for 0", all(x["arg"] == 32 for x in a), str(a))


def old_sound(z, ps, track=0):
    """Edits of the project copy making a track a DIGIDRUM sound as an older build stored it: machine 42, tag 0, no marker,
    P1 in zone z (its lo), P2..P8 ps."""
    r = REC_PROJ + 162 * track
    w = bytes([(z * 128 + 10) // 11, 0])
    for p in ps:
        w += bytes([p, 0])
    return {r + 0x1c: w, r + 0x1c + 2 * 14: bytes(4), r + 0x7a: b"\0\0", r + 0x7c: bytes([42])}


OLD = [11, 22, 33, 44, 55, 66, 77]
SETS = [(0, 0, 0, 7), (1, 0, 16, 7), (2, 0, 32, 7), (3, 0, 48, 7), (4, 0, 64, 7), (5, 0, 80, 7), (6, 0, 96, 7), (7, 0, 112, 7),
        (21, 86, 40, 3), (22, 86, 50, 3), (27, 86, 99, 6)]
DD_LABELS = [["PTCH", "DEC", "RAMP", "RDEC", "MOD", "MFRQ", "MDEC"], ["PTCH", "DEC", "NOIS", "NDEC", "MOD", "MFRQ", "MDEC"]]


def t_old(e):
    """An old kit (the project as an older build saved it) stays bit for bit: no tag, the words, the project record; trigs
    report tag 0 with the old P1; the page is DIGIDRUM's: ENG named, labels per zone, ENG stepped in 11 zones, stock's SMPL page."""
    s, t = chosen(e, "old-chosen")
    s2, c = S.poke_boot(e, "old", old_sound(1, OLD), snap=s, start=e.clock + t)
    rec0 = e.peek(s2, REC_PROJ, 162)
    w0 = e.peek(s2, KIT, 32)
    s3 = e.run("old-play", 500, [(100, "press", "BD"), (300, "press", "SRC")], snap=s2, start=4400, card=c, save=True, count=[0x4011f6bc])
    check("old: the kit words and the project record are bit-identical after the boot, ticks and a trig", e.peek(s3, KIT, 32) == w0 and
          e.peek(s3, REC_PROJ, 162) == rec0 and tag_kit(e, s3) == 0)
    tr = [x for x in U.trigs(e) if x.get("machine") == 0x40]
    check("old: trigs report tag 0 and the old layout", bool(tr) and all(x["tag"] == 0 and x["params"][0] >> 7 == 12 and x["params"][1] >> 7 == 11 for x in tr), str(tr[-1:]))
    check("old: no 19 on MD's slots", not any(a and a["slot"] >= 0x40 for a in e.asks()), str(e.asks()[:3]))
    n = rec_names(e, s3)
    check("old: DIGIDRUM's page: ENG and EFM-SD's labels on the SRC records, all eight in the row", n == ["ENG"] + DD_LABELS[1] and src_row(e, s3) == list(range(390, 398)),
          f"{n} {src_row(e, s3)}")
    print(f"  look at build/emu/{e.tag}/old-play.png")
    s4 = e.run("old-eng", 400, [(20, "turn", step(0)), (200, "press", "BD")], snap=s3, start=4900, card=c, save=True)
    k = kit16(e, s4)
    check("old: ENG steps by DIGIDRUM's 11 zones, no tag", k[0] in [(z * 128 + 10) // 11 for z in range(11)] and tag_kit(e, s4) == 0, str(k))
    s5 = e.run("old-smpl", 200, [(20, "press", "SMPL")], snap=s4, start=5300, card=c, save=True)
    print(f"  look at build/emu/{e.tag}/old-smpl.png: stock's SMPL page")
    s6 = e.run("old-reload", 300, snap=s5, start=5500, card=c, save=True)
    check("old: nothing changed later either", tag_kit(e, s6) == 0)


def t_kitload(e):
    """A kit stored old, loaded with RELOAD: nothing converts, whenever a trig falls."""
    s, t = chosen(e, "kitload-chosen")
    w = bytes([12, 0, 11, 0, 22, 0, 33, 0, 44, 0, 55, 0, 66, 0, 77, 0])
    ed = {KIT: w, TAG_KIT: b"\0\0", KIT + 2 * 14: bytes(4), U.sym("us_tag"): b"\0\0"}
    ev, t2 = U.kit_menu(50, 2)
    ev += [(t2 + 200, "press", "YES"), (t2 + 400, "press", "YES")]
    s2 = e.run("kitload-saved", t2 + 1000, ev, snap=s, start=e.clock + t, save=True, extra=S.pokes(e, s, ed))
    check("kitload: the kit saved old", tag_kit(e, s2) == 0 and kit16(e, s2)[:2] == [12, 11], f"{tag_kit(e, s2):#x} {kit16(e, s2)}")
    ev, t3 = U.kit_menu(50, 0)
    ev += [(t3 + 200, "press", "YES"), (t3 + 300, "press", "BD")]
    s3 = e.run("kitload", t3 + 800, ev, snap=s2, start=e.clock + t + t2 + 1000, save=True, count=[0x4011f6bc])
    tr = [x for x in U.trigs(e) if x.get("machine") == 0x40]
    check("kitload: one load, tag 0, the words as stored, trigs tag 0", e.counts.get(0x4011f6bc) == 1 and tag_kit(e, s3) == 0 and kit16(e, s3)[:2] == [12, 11] and
          bool(tr) and all(x["tag"] == 0 for x in tr), f"{e.counts.get(0x4011f6bc)} {tag_kit(e, s3):#x} {kit16(e, s3)} {tr[-1:]}")


def t_convert(e):
    """YES with no cursor move on an old sound converts it, each of the eleven zones, by the mapping; once (a second YES
    does nothing); it survives a cold boot."""
    s, t = chosen(e, "convert-chosen")
    for z, (st, v9, v10, keep) in enumerate(SETS):
        s2, c = S.poke_boot(e, f"convert{z}", old_sound(z, OLD), snap=s, start=e.clock + t)
        ev, t2 = U.walk_list(100, 0)
        s3 = e.run(f"convert{z}-yes", t2 + 300, ev + [(t2 + 100, "press", "BD")], snap=s2, start=4400, card=c, save=True)
        want = OLD[:keep] + DEFAULTS[st][keep:] + [v9, v10, 100, 0, 0, 0, 0, 0]
        got = kit16(e, s3)
        check(f"convert: zone {z} -> set {st}", got == want and tag_kit(e, s3) == MD_TAG and tag_proj(e, s3) == MD_TAG and marker(e, s3), f"{got} want {want} tag {tag_kit(e, s3):#x}")
        tr = [x for x in U.trigs(e) if x.get("machine") == 0x40]
        check(f"convert: zone {z}: the trig reports the tag", bool(tr) and tr[-1]["tag"] == MD_TAG, str(tr[-1:]))
        if z == 8:
            s4 = e.run("convert-again", 400, U.walk_list(50, 0)[0], snap=s3, start=4400 + t2 + 300, card=c, save=True)
            check("convert: a second YES changes nothing", kit16(e, s4) == want)
            s5 = e.run("convert-off", 300, snap=s4, start=4400 + t2 + 700, card=c, extra=["--power-off", f"{4400 + t2 + 800}M"], save=True)
            s6 = e.run("convert-boot", 4800, S.DIALOGS, cold=True, card=c, save=True)
            check("convert: power off and cold boot keep it", kit16(e, s6) == want and tag_kit(e, s6) == MD_TAG, str(kit16(e, s6)))
    # NO leaves it
    s2, c = S.poke_boot(e, "convert-n", old_sound(1, OLD), snap=s, start=e.clock + t)
    ev, t2 = U.walk_list(100, 0, confirm=False)
    s3 = e.run("convert-no", t2 + 300, ev + [(t2, "press", "NO")], snap=s2, start=4400, card=c, save=True)
    check("convert: NO converts nothing", tag_kit(e, s3) == 0 and kit16(e, s3)[:2] == [12, 11], str(kit16(e, s3)))


def t_hold(e):
    """While a conversion writes, reports hold: playing, every report on BD is (tag 0, old P1) or (the MD tag, new P1)."""
    s, t = chosen(e, "hold-chosen")
    ed = old_sound(1, OLD)
    ed.update(S.trig_bits(e, s, 0, [0, 2, 4, 6, 8, 10, 12, 14]))
    s2, c = S.poke_boot(e, "hold", ed, snap=s, start=e.clock + t)
    ev, t2 = U.walk_list(300, 0)
    ev = [(50, "press", "PLAY")] + ev
    e.run("hold-run", t2 + 400, ev, snap=s2, start=4400, card=c)
    rep = [(int.from_bytes(m[-3:-1], "big"), m[6 if m[4] == 3 else 8]) for m in e.sent if len(m) > 20 and m[4] in (3, 4) and m[5] & 0x78 == 0x40]
    tags = {(0x224d if a == 0x444d else a, b) for a, b in rep}
    check("hold: reports both sides of the conversion, none mixed", tags <= {(0, 12), (MD_TAG, 11)} and len(tags) == 2, str(sorted(tags)))


def t_marker(e):
    """The tag lost (slot 47 zeroed: a save on 0.3.x or stock, a transfer), the marker there: the tag back at the next tick, the words
    untouched; through a real power-off on stock 1.73 too."""
    s, t = chosen(e, "marker-chosen", extra=[(t_ev, "turn", ("3:-8", 6, 8)) for t_ev in ()])
    check("marker: in the kit and the project copy", marker(e, s) and e.peek(s, REC_PROJ + 0x1c + 29, 1) == bytes([0x4d]) and e.peek(s, REC_PROJ + 0x1c + 31, 1) == bytes([0x44]),
          e.peek(s, REC_PROJ + 0x1c + 28, 4).hex())
    s2, c = S.poke_boot(e, "marker", {REC_PROJ + 0x7a: b"\0\0"}, snap=s, start=e.clock + t)
    k = kit16(e, s)
    s3 = e.run("marker-tick", 100, snap=s2, start=4400, card=c, save=True)
    check("marker: tag 0 in the store: restored, in the project copy too, the words untouched", tag_kit(e, s3) == MD_TAG and tag_proj(e, s3) == MD_TAG and kit16(e, s3) == k, f"{tag_kit(e, s3):#x} {kit16(e, s3)}")
    c2 = U.card_copy(e, "marker-stock")
    e.run("marker-before", 200, snap=s, start=e.clock + t, card=c2, extra=["--power-off", f"{e.clock + t + 100}M"])
    st = e.run("marker-stock-boot", 4400, S.DIALOGS, cold=True, card=c2, fw=U.STOCK, save=True)
    e.run("marker-stock-off", 300, snap=st, start=4400, card=c2, fw=U.STOCK, extra=["--power-off", "4500M"])
    s4 = e.run("marker-back", 4800, S.DIALOGS, cold=True, card=c2, save=True)
    check("marker: after a power-off on stock: BD on 42, its words, tag back", e.peek(s4, 0x8000ea00, 1)[0] == 42 and kit16(e, s4) == k and tag_kit(e, s4) == MD_TAG, f"{e.peek(s4, 0x8000ea00, 1).hex()} {kit16(e, s4)} {tag_kit(e, s4):#x}")


def t_stuck(e):
    """The list left by GLOBAL on a preview of 42: only that track waits; other tracks' pages work; a stock sound stays
    untouched; reopened and YES: fresh FM BD, not a conversion of the stock sound's words."""
    base = kit16(e, e.snap)
    s0, t0 = chosen(e, "stuck-sd", extra=[])     # BD on MD with its answers
    ev = [(20, "press", "SD")]
    ev2, t = U.walk_list(120, DOWNS_MD + UI["downs_sd"]["u1"] - UI["downs"]["u1"], confirm=False)
    ev += ev2 + [(t, "press", "GLOBAL"), (t + 150, "press", "NO")]
    t += 400
    s = e.run("stuck-left", t, ev, snap=s0, start=e.clock + t0, save=True)
    ch = e.peek(s, U.sym("us") + U.sym("us_off_ch"), 1)[0]
    sd = kit16(e, s, 1)
    check("stuck: SD left on 42 by GLOBAL, the note cleared with the list gone, tag 0, nothing written", e.peek(s, 0x8000ea00, 2)[1] == 42 and ch == 0 and tag_kit(e, s, 1) == 0, f"{ch} {tag_kit(e, s, 1):#x}")
    check("stuck: the page of the stranded track switches: DIGIDRUM's labels", rec_names(e, s)[0] == "ENG" and md_mode(e, s) == 1, f"{rec_names(e, s)} {md_mode(e, s)}")
    clock = e.clock + t0 + t
    s1 = e.run("stuck-bd", 1200, [(20, "press", "BD")], snap=s, start=clock, save=True)
    a = [x for x in e.asks() if x and x["slot"] == 0x40]
    check("stuck: BD's page goes on: it asks", bool(a), str(a[:2]))
    check("stuck: SLOT PRINTS go on", any(len(m) > 4 and m[4] == 0x25 for m in e.sent), "no 25")
    check("stuck: SD still untouched", kit16(e, s1, 1) == sd and tag_kit(e, s1, 1) == 0)
    ev3 = [(20, "press", "SD")]
    ev4, t2 = U.walk_list(120, 0)
    s2 = e.run("stuck-yes", t2 + 300, ev3 + ev4, snap=s1, start=clock + 1200, save=True)
    check("stuck: reopened, YES: FM BD fresh (the words were the preview's, no DIGIDRUM sound)", tag_kit(e, s2, 1) == MD_TAG and kit16(e, s2, 1)[:11] == DEFAULTS[0] + [0, 0, 100],
          f"{tag_kit(e, s2, 1):#x} {kit16(e, s2, 1)}")
    # a stock track previewed elsewhere and left: untouched (BD on the base, a U-free machine)
    ev, t = U.walk_list(100, 3, confirm=False)
    ev += [(t, "press", "GLOBAL"), (t + 150, "press", "NO")]
    s3 = e.run("stuck-stock", t + 600, ev, save=True)
    check("stuck: a preview of a stock machine left: sample words and tag untouched", kit16(e, s3)[8:] == base[8:] and tag_kit(e, s3) == 0, str(kit16(e, s3)))


def md_mode(e, s):
    return e.peek(s, U.sym("md") + 4, 1)[0]


def os_of(x):
    """The OS of an Emu's build ("1.73", "1.74"), from its manifest."""
    return json.load(open(os.path.join(x.out, "manifest.json")))["target"].removeprefix("OS")


def own(x, a):
    """This tree's address a as x's image has it: 0.3.0's base is a 1.73 build, so in the 1.74 tree its records are
    read at 1.73's addresses (tools/ostarget.py address_in), never at 1.74's."""
    return ostarget.address_in(os_of(x), a)


def t_same030(e):
    """An old sound on this build against release 0.3.0's image, same words, same keys: the SRC and SMPL screens, the
    records' fields and names, the 04s are 0.3.0's. Each image's records are read at its own OS's addresses (0.3.0 is
    a 1.73 build), so on a 1.74 build the records are compared as on 1.73."""
    rel = U.Emu("rel0-3-0")
    U.OBJ = e.out
    ev, t = U.walk_list(100, DOWNS_MD)
    keys = [(100, "press", "BD"), (300, "press", "SRC"), (400, "turn", ("3:+8", 4, 8)), (500, "turn", step(0))]
    out = {}
    for x, name in ((e, "new"), (rel, "rel")):
        s = x.run(f"same-{name}", t, ev, save=True)
        ed = old_sound(4, OLD)
        ed[REC_PROJ + 0x1c + 16] = bytes([64, 0, 64, 0, 0, 0, 0, 0, 0, 0, 120, 0, 0, 0, 100, 0])   # the sample words alike (no MD words on either)
        ed.pop(REC_PROJ + 0x1c + 28)
        s2, c = S.poke_boot(x, f"same-{name}", ed, snap=s, start=x.clock + t)
        s3 = x.run(f"same-{name}-src", 800, keys, snap=s2, start=4400, card=c, save=True)
        rec = [x.peek(s3, own(x, U.rec(r)), 40) for r in range(390, 398)]
        nm = [[x.cstr(s3, x.u32(s3, own(x, U.rec(r)) + o), 13) for o in (40, 44, 48)] for r in range(390, 398)]
        tr = [m for m in x.sent if len(m) > 20 and m[4] in (3, 4)]
        src = open(os.path.join(x.out, f"same-{name}-src.png"), "rb").read()
        x.run(f"same-{name}-smpl", 200, [(20, "press", "SMPL")], snap=s3, start=5200, card=c)
        smp = open(os.path.join(x.out, f"same-{name}-smpl.png"), "rb").read()
        out[name] = dict(rec=rec, nm=nm, tr=tr, src=src, smp=smp, row=src_row(x, s3, own(x, 0x40287ccc + 36 * 42)))
        check(f"same030: {name}'s records found (the image's own OS, {os_of(x)}): names present",
              all(n[0] for n in nm), str(nm[:2]))
    a, b = out["new"], out["rel"]
    # the machine's name differs on purpose (MD): the records' group name
    for z in (a, b):
        z["nm"] = [[n[0], n[2]] for n in z["nm"]]
    check("same030: records 390..397: kind, slot, min, max, default, the rest of their fields", a["rec"] == b["rec"],
          str([(i, x.hex(), y.hex()) for i, (x, y) in enumerate(zip(a["rec"], b["rec"])) if x != y][:2]))
    check("same030: long and short names", a["nm"] == b["nm"], f"{a['nm']} {b['nm']}")
    check("same030: the SRC row", a["row"] == b["row"], f"{a['row']} {b['row']}")
    check("same030: the SRC screen", a["src"] == b["src"], "PNGs differ")
    check("same030: the SMPL screen", a["smp"] == b["smp"], "PNGs differ")
    check("same030: the reports", a["tr"] == b["tr"] and bool(a["tr"]), str([(x.hex(), y.hex()) for x, y in zip(a["tr"], b["tr"]) if x != y][:2]))


def t_dspold(e):
    """Old projects keep their samples (7h moved SMP on the page, not in the sound): DSP SAMPLE on BD saved by release 0.3.0's image
    with SMP C005 and ENG STRING, a lock-free sound; the card booted on this build: the sixteen words, and the 04's P1..P16, as 0.3.0's."""
    rel = U.Emu("rel0-3-0")
    U.OBJ = e.out
    ev, t = U.walk_list(100, 24)
    s = rel.run("dspold-chosen", t, ev, save=True)
    check("dspold: 0.3.0: BD on DSP SAMPLE", rel.peek(s, 0x8000ea00, 1)[0] == 45)
    ed = {REC_PROJ + 0x1c: bytes([43, 0]), REC_PROJ + 0x1c + 2 * 10: bytes([5, 0x40])}   # ENG's stop, SMP 5 . bank C
    s2, c = S.poke_boot(rel, "dspold", ed, snap=s, start=rel.clock + t)
    rel.run("dspold-rel", 400, [(100, "press", "BD")], snap=s2, start=4400, card=c, save=True, extra=["--power-off", "4700M"])
    tr0 = [m for m in rel.sent if len(m) > 20 and m[4] == 4]
    w0 = U.kit16(rel, s2)
    s3 = e.run("dspold-boot", 4400, S.DIALOGS, cold=True, card=c, save=True)
    s3 = e.run("dspold-new", 400, [(100, "press", "BD")], snap=s3, start=4400, card=c, save=True)
    tr1 = [m for m in e.sent if len(m) > 20 and m[4] == 4]
    check("dspold: the words on this build are 0.3.0's, SMP 0x0540", U.kit16(e, s3) == w0 and e.peek(s3, KIT + 2 * 10, 2) == bytes([5, 0x40]), f"{U.kit16(e, s3)} {w0}")
    check("dspold: the 04 is 0.3.0's, byte for byte (the host plays the same sample)", bool(tr0) and bool(tr1) and tr0[-1] == tr1[-1], f"{tr0[-1:]} {tr1[-1:]}")
    print(f"  look at build/emu/{e.tag}/dspold-new.png")
    s4 = e.run("dspold-pages", 300, [(50, "press", "SMPL")], snap=s3, start=4800, card=c, save=True)
    print(f"  look at build/emu/{e.tag}/dspold-pages.png: TUN FIN MOD ENG / STA END LOP LEV")


def t_dspmix(e):
    """DSP SAMPLE chosen fresh: MIX 0 (no resonator). A saved sound keeps its MIX: a sound with MIX 64 stored by the 0.3.0 image reads 64 here."""
    ev, t = U.walk_list(100, 25)   # (0.5.0: SAMPLER, 43, before it)
    s = e.run("dspmix", t + 100, ev, save=True)
    k = kit16(e, s)
    check("dspmix: BD on 45, P5 (MIX) 0, the rest the records' defaults", e.peek(s, 0x8000ea00, 1)[0] == 45 and k[4] == 0 and k[7] == 100, str(k))
    rel = U.Emu("rel0-3-0")
    U.OBJ = e.out
    ev, t = U.walk_list(100, 24)   # (0.3.0: no SAMPLER)
    s = rel.run("dspmix-rel", t + 100, ev, save=True)
    check("dspmix: 0.3.0's default was 64", kit16(rel, s)[4] == 64, str(kit16(rel, s)))
    s2, c = S.poke_boot(rel, "dspmix", {}, snap=s, start=rel.clock + t + 100)
    s3 = e.run("dspmix-boot", 4400, S.DIALOGS, cold=True, card=c, save=True)
    check("dspmix: a saved sound keeps MIX 64 on this build", kit16(e, s3)[4] == 64, str(kit16(e, s3)))


def t_switch(e):
    """Moving off 42 and back through the list: YES on 42 sets up afresh; a stock machine after MD leaves no tag in reports."""
    s, t = chosen(e, "switch-chosen")
    ev = [(20, "press", "SRC"), (120, "press", "SRC"), (220, "press", "UP"), (320, "press", "UP"), (420, "press", "YES"), (620, "press", "BD")]
    s2 = e.run("switch", 900, ev, snap=s, start=e.clock + t, save=True)
    m = e.peek(s2, 0x8000ea00, 1)[0]
    check("switch: BD left 42", m != 42, str(m))
    tr = [x for x in U.trigs(e) if x.get("tag") == MD_TAG]
    check("switch: its reports carry no MD tag", not tr, str(tr[:2]))


TESTS = {"list": t_list, "fresh": t_fresh, "sound": t_sound, "labels": t_labels, "nohost": t_nohost, "stops": t_stops, "ask": t_ask,
         "plock": t_plock, "kit": t_kit, "paste": t_paste, "tracks": t_tracks, "old": t_old, "kitload": t_kitload, "convert": t_convert,
         "hold": t_hold, "marker": t_marker, "stuck": t_stuck, "same030": t_same030, "dspold": t_dspold, "dspmix": t_dspmix, "switch": t_switch}


def main():
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    if len(sys.argv) < 3 or any(n not in TESTS for n in names):
        sys.exit(__doc__ + "\nTESTS: all " + " ".join(TESTS))
    e = U.Emu(sys.argv[1])
    for n in names:
        print(f"-- {n}: {TESTS[n].__doc__.splitlines()[0]}")
        TESTS[n](e)
    print(f"\n{'ALL PASS' if not U.fails else 'FAILED: ' + ', '.join(U.fails)}")
    sys.exit(1 if U.fails else 0)


if __name__ == "__main__":
    main()
