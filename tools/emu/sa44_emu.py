#!/usr/bin/env python3
"""0.5.0 SAMPLER (machine 43) and a 0.4.4 Rytm: a project saved on this build with BD on SAMPLER (and SD untouched),
powered off onto the card, cold-booted on release 0.4.4's image (f44b, mods-044 6568d3c: no SAMPLER, 43's mask 0 there):
the boot runs clean (strict, no fault), BD's machine is then DISABLE (27) [measured on saa], a BD trig and SD's run clean.
boot48 (re-review F3): this build cold-booted with SD on SAMPLER and BD PLASTIC selected (no Sidecar machine selected
since the boot: 0026's shared records never set up, cu.p2m 0): the host's 48 to SD's STRT (P13), TUNE (P9) and SMP (P11)
answered 0 and written.

    tools/emu/sa44_emu.py TAG     (RYTM_EMU, RYTM_TEENSY as md_emu.py; build/emu/f44b the 0.4.4 release build, its base
                                   sections/us_f44b of tools/emu/us_base.sh f44b)
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import us_emu as U     # noqa: E402
import sfx_emu as S    # noqa: E402

check = U.check
MACH_BD = 0x8000EA00   # BD's machine (cu_emu / bk_emu)
DOWNS_SA = 23          # BD's machine list: DIGIDRUM 22, SAMPLER 23 (this build)
DOWNS_SA_SD = 26       # SD's (its U1 18, BD's 15; bk_emu sa_sd)


def sx(cmd, *body):
    return bytes([0xF0, 0x7D, 0x52, 0x54, cmd, 0x01, *body, 0xF7])


def boot48(e):
    ev = [(100, "press", "SD")]
    w, t = U.walk_list(300, DOWNS_SA_SD)
    ev += w + [(t + 100, "press", "BD")]
    s = e.run("sa48-chosen", t + 400, ev, save=True)
    m = list(e.peek(s, MACH_BD, 2))
    check("boot48: BD PLASTIC, SD SAMPLER", m[1] == 43 and m[0] != 43, str(m))
    s2, c = S.poke_boot(e, "sa48", {}, snap=s, start=e.clock + t + 400)
    m = list(e.peek(s2, MACH_BD, 2))
    check("boot48: after the cold boot SD still SAMPLER, BD stock", m[1] == 43 and m[0] != 43, str(m))
    sends = [(100, "usb", sx(0x48, 1, 12, 30, 0)), (200, "usb", sx(0x48, 1, 8, 100, 0)), (300, "usb", sx(0x48, 1, 10, 9, 1 << 4))]
    s3 = e.run("sa48", 600, sends, snap=s2, start=4400, card=c, save=True)
    st = [(x[6], x[7], x[8]) for x in e.sent if len(x) == 10 and x[4] == 0x48]
    k = U.kit16(e, s3, 1)
    print(f"  48 answers {st}; SD's words 17..24 {k[8:16]}")
    check("boot48: 48 1 12 / 1 8 / 1 10 answered 0", st == [(1, 12, 0), (1, 8, 0), (1, 10, 0)], str(st))
    check("boot48: SD's STRT 30, TUNE 100, SMP 9 written", k[12] == 30 and k[8] == 100 and k[10] == 9, str(k[8:16]))


def main():
    e = U.Emu(sys.argv[1])
    old = U.Emu("f44b")
    U.OBJ = e.out
    boot48(e)
    ev, t = U.walk_list(100, DOWNS_SA)
    s = e.run("sa44-chosen", t, ev, save=True)
    m = e.peek(s, MACH_BD, 1)[0]
    check("sa44: BD on SAMPLER (43) on this build", m == 43, str(m))
    s2, c = S.poke_boot(e, "sa44", {}, snap=s, start=e.clock + t)
    m = e.peek(s2, MACH_BD, 1)[0]
    check("sa44: the project on the card holds BD on 43 (this build's cold boot from it)", m == 43, str(m))
    s3 = old.run("sa44-old", 4400, S.DIALOGS, cold=True, card=c, save=True)
    m44 = old.peek(s3, MACH_BD, 1)[0]
    print(f"  0.4.4 cold boot on that card: BD's machine {m44}; look at build/emu/{old.tag}/sa44-old.png")
    check("sa44: 0.4.4 loads BD as DISABLE (27: 43's mask is 0 there; silent, no fault) [measured]", m44 == 27, str(m44))
    old.run("sa44-old-trig", 600, [(100, "press", "BD"), (250, "press", "SD"), (400, "press", "SRC")], snap=s3,
            start=4400, card=c)
    r = [x for x in old.sent if len(x) > 8 and x[4] in (3, 4)]
    print(f"  0.4.4 after BD / SD trigs: reports {[x[:6].hex() for x in r]}; look at build/emu/{old.tag}/sa44-old-trig.png")
    print(f"\n{'ALL PASS' if not U.fails else 'FAILED: ' + ', '.join(U.fails)}")
    sys.exit(1 if U.fails else 0)


if __name__ == "__main__":
    main()
