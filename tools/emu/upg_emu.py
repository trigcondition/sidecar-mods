#!/usr/bin/env python3
"""Upgrade check 0.3.1 -> 0.4.0 in rytm-emu: a project saved under release 0.3.1's image with old DIGIDRUM sounds (two tracks,
P1 in two zones, P2..P8 set), powered off onto the card, cold-booted on this build: the kit words, the project records and
the host's reports (the 04 messages of a trig) are the same, no tag, DIGIDRUM's page.

    tools/emu/upg_emu.py TAG      (RYTM_EMU, RYTM_TEENSY as md_emu.py; build/emu/rel0-3-1 from rytm-mods-sfxreload, the base
                                   sections/us_rel0-3-1 of tools/emu/us_base.sh rel0-3-1)
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import us_emu as U     # noqa: E402
import sfx_emu as S    # noqa: E402
import md_emu as M     # noqa: E402

check = U.check
SOUNDS = [(0, 4, M.OLD), (1, 9, [90, 80, 70, 60, 50, 40, 30])]     # track, P1 zone, P2..P8


def reports(x):
    return [m for m in x.sent if len(m) > 20 and m[4] == 4]


def main():
    e = U.Emu(sys.argv[1])
    rel = U.Emu("rel0-3-1")
    U.OBJ = e.out
    ev, t = U.walk_list(100, M.DOWNS_MD)
    s = rel.run("upg-chosen", t, ev, save=True)
    ed = {}
    for tr, z, ps in SOUNDS:
        ed.update(M.old_sound(z, ps, tr))
    s2, c = S.poke_boot(rel, "upg", ed, snap=s, start=rel.clock + t)
    keys = [(100, "press", "BD"), (200, "press", "SD")]
    s3 = rel.run("upg-rel", 500, keys, snap=s2, start=4400, card=c, save=True, extra=["--power-off", "4900M"])
    w0 = [rel.peek(s3, M.KIT + 152 * k, 32) for k in (0, 1)]
    rec0 = [rel.peek(s3, M.REC_PROJ + 162 * k, 162) for k in (0, 1)]
    r0 = reports(rel)
    check("upg: 0.3.1 holds two DIGIDRUM sounds (machine 42, no tag)", all(rel.peek(s3, M.REC_PROJ + 162 * k + 0x7c, 1)[0] == 42 for k in (0, 1)))
    s4 = e.run("upg-boot", 4400, S.DIALOGS, cold=True, card=c, save=True)
    s5 = e.run("upg-new", 500, keys, snap=s4, start=4400, card=c, save=True)
    r1 = reports(e)
    w1 = [e.peek(s5, M.KIT + 152 * k, 32) for k in (0, 1)]
    rec1 = [e.peek(s5, M.REC_PROJ + 162 * k, 162) for k in (0, 1)]
    check("upg: the kit words of both tracks are 0.3.1's", w0 == w1, f"{[x.hex() for x in w0]} {[x.hex() for x in w1]}")
    check("upg: the project records are 0.3.1's, byte for byte", rec0 == rec1)
    check("upg: no tag, nothing converted", M.tag_kit(e, s5) == 0 and M.tag_kit(e, s5, 1) == 0)
    check("upg: reports of the trigs seen (both)", len(r0) >= 2 and len(r1) >= 2, f"{len(r0)} {len(r1)}")
    last = lambda r, ty: [m for m in r if m[4] == ty][-2:]
    check("upg: the 04 reports are 0.3.1's, byte for byte", last(r0, 4) == last(r1, 4) and bool(last(r0, 4)),
          str([(a.hex(), b.hex()) for a, b in zip(last(r0, 4), last(r1, 4)) if a != b][:2]))
    n = M.rec_names(e, s5)
    print(f"  records {n} row {M.src_row(e, s5)}; look at build/emu/{e.tag}/upg-new.png")
    print(f"\n{'ALL PASS' if not U.fails else 'FAILED: ' + ', '.join(U.fails)}")
    sys.exit(1 if U.fails else 0)


if __name__ == "__main__":
    main()
