#!/usr/bin/env python3
"""Emulator tests of 0023-teensy-drive's UI-task behaviour in rytm-emu (browse-lag): the TEENSY folder never makes
the UI task wait on the host more than once, and a +Drive folder scrolls with no ask, no wait and no send.

    .venv/bin/python tools/emu/td_emu.py TAG TEST [TEST ...]|all     exit 0 when every check passes

TAG: a build with 0023 (sfxui-bl), whose base tools/emu/us_base.sh TAG made. Every run under DTEMU_STRICT=1. The
walk: FUNC+SMPL, DOWN (the slot list), FUNC+YES (the sample browser at the +Drive root: Factory, incoming, SIDECAR).
Counted: sleep_us 0x40098c18 (the UI's wait), 0023's td_ask (the 0D), the wrappers td_resolve / td_count, the row
drawer 0x400e5f28. Cache state read from td_cache (folder, parent, total, received, valid, failed, t_ask, t_fail).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import us_emu as U          # noqa: E402
P = U.P
SLEEP_US = 0x40098c18
ROW = 0x400e5f28
OPEN = [(100, "press", "FUNC:200M"), (150, "press", "SMPL"), (400, "press", "DOWN"), (500, "press", "FUNC:200M"),
        (550, "press", "YES")]


def listing(f, parent, total, ents):
    """A 0E (rytm-teensy core/sysex.cpp sysex_listing): ents = [(kind, id, size, name)]."""
    b = bytearray(b"\xf0\x7d\x52\x54\x0e")
    for v in (f, parent, 0, total):
        b += bytes([(v >> 7) & 0x7f, v & 0x7f])
    for kind, i, size, name in ents:
        b += bytes([kind, (i >> 7) & 0x7f, i & 0x7f, (size >> 21) & 0x7f, (size >> 14) & 0x7f, (size >> 7) & 0x7f,
                    size & 0x7f, len(name)]) + name.encode()
    return bytes(b) + b"\xf7"


def cache(e, snap):
    a = U.sym("td_cache", "0023-teensy-drive")
    d = e.peek(snap, a, 16)
    return dict(folder=int.from_bytes(d[0:2], "big"), total=int.from_bytes(d[4:6], "big"),
                received=int.from_bytes(d[6:8], "big"), valid=d[8], failed=d[9],
                t_ask=int.from_bytes(d[12:16], "big"))


def t_silent(e):
    """No host answer: the root read asks for TEENSY at once, entering it and entering it again never sleeps."""
    ask = U.sym("td_ask", "0023-teensy-drive")
    ev = OPEN + [(700, "press", "DOWN"), (800, "press", "YES"), (1200, "press", "NO"), (1300, "press", "YES"),
                 (1700, "press", "NO"), (1800, "press", "YES")]
    s = e.run("td-silent", 2400, ev, save=True, count=(SLEEP_US, ask))
    c = cache(e, s)
    n = e.counts.get(SLEEP_US, -1)
    U.check("silent host: the UI task never sleeps (sleep_us 0 calls; before the fix 40 per entry, 400 ms)", n == 0,
            f"sleep_us {n}")
    U.check("silent host: SIDECAR was asked for (the root read's prefetch, then at most once a second)",
            1 <= e.counts.get(ask, 0) <= 6, f"td_ask {e.counts.get(ask)}")
    U.check("silent host: the cache holds no entries and is marked failed", c["valid"] == 0 and c["failed"] == 1 and c["received"] == 0,
            str(c))


def t_answer(e):
    """A host answering after the root read: the prefetch fills the cache, entering TEENSY finds the listing at once."""
    ask = U.sym("td_ask", "0023-teensy-drive")
    ents = [(1, 1, 0, "Drums"), (0, 1, 3000, "Kick")]
    ev = OPEN + [(620, "usb", listing(0, 0, 2, ents)), (700, "press", "DOWN"), (800, "press", "YES")]
    s = e.run("td-answer", 1200, ev, save=True, count=(SLEEP_US, ask))
    c = cache(e, s)
    U.check("answering host: no sleep, one ask (the prefetch)", e.counts.get(SLEEP_US, -1) == 0 and
            e.counts.get(ask, 0) == 1, f"sleep_us {e.counts.get(SLEEP_US)} td_ask {e.counts.get(ask)}")
    U.check("answering host: the cache holds folder 0, 2 entries, valid, not failed",
            c["folder"] == 0 and c["received"] == 2 and c["total"] == 2 and c["valid"] == 1 and c["failed"] == 0, str(c))
    print(f"    screen build/emu/{e.tag}/td-answer.png: SIDECAR with Drums and Kick 0.01MB")


def t_scroll(e):
    """Scrolling a +Drive folder: the wrapped calls answer the stock paths; no ask, no sleep, no USB send."""
    ask = U.sym("td_ask", "0023-teensy-drive")
    res = U.sym("td_resolve_entry", "0023-teensy-drive")
    ev = OPEN + [(600, "press", "DOWN"), (700, "press", "YES")] + [(900 + 60 * i, "press", "DOWN") for i in range(30)]
    e.run("td-scroll", 3200, ev, count=(SLEEP_US, ask, res, ROW, 0x400029e0))
    c = e.counts
    U.check("scroll: no sleep and no ask while the folder scrolls (the one ask is the root read's)",
            c.get(SLEEP_US, -1) == 0 and c.get(ask, 0) <= 1, f"sleep {c.get(SLEEP_US)} ask {c.get(ask)}")
    print(f"    rows drawn {c.get(ROW)}, td_resolve calls {c.get(res)}, USB sends {c.get(0x400029e0)}")


TESTS = {"silent": t_silent, "answer": t_answer, "scroll": t_scroll}


def main():
    names = list(TESTS) if sys.argv[2:] == ["all"] else sys.argv[2:]
    if len(sys.argv) < 3 or any(t not in TESTS for t in names):
        sys.exit(__doc__ + "\nTESTS: all " + " ".join(TESTS))
    e = U.Emu(sys.argv[1])
    e.strict = True
    for t in names:
        print(f"-- {t}: {TESTS[t].__doc__.splitlines()[0]}")
        TESTS[t](e)
    print(f"\n{'ALL PASS' if not U.fails else 'FAILED: ' + ', '.join(U.fails)}")
    sys.exit(1 if U.fails else 0)


if __name__ == "__main__":
    main()
