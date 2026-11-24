#!/usr/bin/env python3
"""Emulator tests of 0021's params-delta (mods/0021-ext/design.md "params-delta"): a parameter-only report is 56 PARAMS
DELTA (the changed values after a mask) only after a 1D whose caps byte says HOST_CAPS_DELTA, else the 41-byte 03 as
before; the host's view rebuilt from the 56s ends on the same values as the 03s give.

    .venv/bin/python tools/emu/pd_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a slots=1 build whose base tools/emu/us_base.sh TAG made. RYTM_TEENSY: a Sidecar checkout whose sim/protocol.py
has params_delta (decode_params_delta, apply_params_delta, slots(caps=)).
    old      no 1D (an older host, or none): BD on PLAITS, trigged once, knob B turned: 03s only, no 56
    short    a 13-byte 1D (an older host's): the same, 03s only
    delta    a 1D with HOST_CAPS_DELTA, the same trig and turns: the 04, then 56s (15 bytes, one value), and at most
             two whole 03s (the refresh, each after a 56); as many reports as "old" (03's rate, 16 blocks), fewer
             bytes; the values rebuilt from them end where "old"'s last 03 ends, P2's the same values
    refresh  caps 1, a trig and turns, then 2.2 s with nothing moving: after the last 56 exactly one whole 03 (the
             refresh, within 1.37 s) and nothing more
    modes    caps 1, turns, caps 1 | RESYNC, turns, a 13-byte 1D, turns: 04 56.. 03 56.. 03 03..; every 56 applies
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import us_emu as U   # noqa: E402  (Emu, check, the protocol module as U.P)
P = U.P
UI = U.UI


def select_plaits(at=100):
    ev, t = [], at
    for k in UI["list_open"] + ["DOWN"] * UI["downs"]["plaits"] + [UI["list_confirm"]]:
        ev.append((t, "press", k))
        t += UI["step_M"]
    return ev, t + UI["settle_M"]


def turns(at, n=40):
    return [(at, "turn", ("1:+1", n, 4))], at + 4 * n + 150   # knob B (HRM, P2), a detent every 4 M (20 ms)


def reports(sent, voice=0):
    """Voice's reports in order: (kind '03' / '04' / '56', the message)."""
    out = []
    for m in sent:
        if len(m) > 6 and m[:4] == b"\xf0\x7d\x52\x54" and m[4] in (0x03, 0x04) and (m[5] & 7) == voice:
            out.append((f"{m[4]:02x}", m))
        elif len(m) > 7 and m[:5] == b"\xf0\x7d\x52\x54\x56" and (m[6] & 7) == voice:
            out.append(("56", m))
    return out


def rebuild(reps):
    """The host's values after each report (as core/host_link.cpp keeps them): [(kind, 16 values)]; None for a 56
    with no values before it."""
    last, out = None, []
    for k, m in reps:
        if k == "03" and len(m) == 41:
            last = [m[6 + 2 * i] << 7 | m[7 + 2 * i] for i in range(16)]
        elif k == "04" and len(m) == 43:
            last = [m[8 + 2 * i] << 7 | m[9 + 2 * i] for i in range(16)]
        elif k == "56":
            full = P.apply_params_delta(last, P.parse(m)[1])
            last = None if full is None else [full[6 + 2 * i] << 7 | full[7 + 2 * i] for i in range(16)]
        out.append((k, last))
    return out


def run(e, name, d1=None, tail=(), idle=0):
    ev = [(50, "usb", d1)] if d1 else []
    sel, t = select_plaits()
    tv, t = turns(t + 30)
    ev += sel + [(t - 4 * 40 - 180, "press", "BD")] + tv   # a trig: the engine runs (and reports) from it on
    for x in tail:
        ev.append((t, "usb", x))
        tv, t = turns(t + 20)
        ev += tv
    e.run(name, t + 100 + idle, ev)
    return reports(e.sent)


def t_old(e):
    """no 1D: 03s only"""
    r = run(e, "pd-old")
    kinds = [k for k, _ in r]
    U.check("old: parameter reports (03) for BD's turns", kinds.count("03") >= 5, str(len(kinds)))
    U.check("old: no 56 without the host's caps", "56" not in kinds)
    e.pd_old = r


def t_short(e):
    """a 13-byte 1D: 03s only"""
    r = run(e, "pd-short", P.slots([1] * 5, 1))
    kinds = [k for k, _ in r]
    U.check("short: an older host's 1D (13 bytes): no 56", "56" not in kinds and kinds.count("03") >= 5, "".join(kinds))


def t_delta(e):
    """caps 1: 56s; fewer; the same end"""
    if not hasattr(e, "pd_old"):
        t_old(e)
    r = run(e, "pd-delta", P.slots([1] * 5, 1, caps=P.HOST_CAPS_DELTA))
    kinds = [k for k, _ in r]
    par = [k for k in kinds if k != "04"]
    U.check("delta: the trig whole (04, the host's values), then 56s; a whole 03 only as a refresh after a 56 (at most 2)",
            kinds[:1] == ["04"] and bool(par) and par[0] == "56" and all(k in ("56", "03") for k in par) and
            par.count("03") <= 2, " ".join(kinds))
    sizes = [len(m) for k, m in r if k == "56"]
    U.check("delta: each 56 13 + 2n bytes, n 1..13", all(15 <= s <= 39 and s % 2 for s in sizes), str(sorted(set(sizes))))
    old = [k for k, _ in e.pd_old if k != "04"]
    b_old = sum(len(m) for k, m in e.pd_old if k != "04")
    b_new = sum(len(m) for k, m in r if k != "04")
    U.check("delta: 03's rate (16 blocks): as many parameter reports as with 03s (within 2), fewer bytes",
            abs(len(par) - len(old)) <= 2 and b_new < b_old, f"{len(par)} vs {len(old)}, {b_new} B vs {b_old} B")
    print(f"  reports: 03 mode {len(old)} ({b_old} B), delta mode {len(par)} ({b_new} B)")
    rb = rebuild(r)
    ro = rebuild(e.pd_old)
    U.check("delta: every 56 applies (the host had the values)", all(v is not None for _, v in rb))
    U.check("delta: the host ends on the values the 03s end on", bool(rb) and bool(ro) and rb[-1][1] == ro[-1][1],
            f"{rb[-1][1] if rb else None} vs {ro[-1][1] if ro else None}")
    p2 = [v[1] for _, v in rb if v]
    p2o = [v[1] for _, v in ro if v]
    U.check("delta: P2's values in order, the 03s' values (never another value), the last the same",
            set(p2) <= set(p2o) and p2 == sorted(p2) and p2[-1:] == p2o[-1:], f"{p2[:8]}.. vs {p2o[:8]}..")


def t_refresh(e):
    """after the last 56: one whole 03 within 1.37 s, nothing moving"""
    r = run(e, "pd-refresh", P.slots([1] * 5, 1, caps=P.HOST_CAPS_DELTA), idle=440)   # 2.2 s after the turns
    kinds = [k for k, _ in r]
    last56 = max((i for i, k in enumerate(kinds) if k == "56"), default=-1)
    U.check("refresh: after the last 56, exactly one whole 03 (the refresh) and nothing more",
            last56 >= 0 and kinds[last56 + 1:] == ["03"], " ".join(kinds))
    rb = rebuild(r)
    U.check("refresh: the refresh 03 carries the values the 56s left", len(rb) >= 2 and rb[-1][1] == rb[last56][1],
            f"{rb[-1][1] if rb else None}")


def t_modes(e):
    """caps, resync, an older host's 1D again"""
    r = run(e, "pd-modes", P.slots([1] * 5, 1, caps=P.HOST_CAPS_DELTA),
            tail=[P.slots([1] * 5, 1, caps=P.HOST_CAPS_DELTA | P.HOST_CAPS_RESYNC), P.slots([1] * 5, 1)])
    s = "".join({"03": "f", "56": "d"}.get(k, "") for k, _ in r)
    U.check("modes: the trig, 56s; a resync: one whole 03, then 56s; an older host's 1D: 03s only",
            re.fullmatch(r"d+(?:f+d+)+f+", s) is not None, s)   # (a refresh 03 may fall inside a 56 run)
    U.check("modes: every 56 applies", all(v is not None for _, v in rebuild(r)))


TESTS = {"old": t_old, "short": t_short, "delta": t_delta, "refresh": t_refresh, "modes": t_modes}


def main():
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    if len(sys.argv) < 3 or any(t not in TESTS for t in names):
        sys.exit(__doc__ + "\nTESTS: all " + " ".join(TESTS))
    e = U.Emu(sys.argv[1])
    for t in names:
        print(f"-- {t}: {TESTS[t].__doc__.splitlines()[0]}")
        TESTS[t](e)
    print(f"\n{'ALL PASS' if not U.fails else 'FAILED: ' + ', '.join(U.fails)}")
    sys.exit(1 if U.fails else 0)


if __name__ == "__main__":
    main()
