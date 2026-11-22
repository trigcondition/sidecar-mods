#!/usr/bin/env python3
"""Long soak of the Rytm lag (F4 follow-up): does anything grow while a Sidecar session plays for minutes?

    RYTM_EMU=... RYTM_TEENSY=... .venv/bin/python tools/emu/soak_emu.py TAG [--windows N] [--secs S] [--noprobe] [--noread] [--rui] [--dense] [--name X] [--out FILE]

Same setup as lag_emu.py (BD on PLAITS, SD on U1 = a SOPHIE-like user machine, pattern A01 playing at 127 BPM), then N windows
of S emulated seconds (default 20 x 30 s), each a separate emulator run from the previous window's snapshot. In every window:
  - continuous knob modulation on the selected track (two bursts of six encoder ticks a second, a random encoder, +-4/+-8);
    the QUICK PERF pot sweeps once per window;
  - a page switch every 3 s (SRC / SMPL / FLTR in turn, as a user paging through), the other track selected every 9 s;
  - (--rui) the remote UI mirror: open, a 20 Hz two-tile update + commit, a whole 1 KB frame every 0.5 s;
  - the host's traffic: a keepalive (rui_keepalive) every second and the slot generations (1D) every 5 s.
Per window one JSON line (file --out): load, UI ticks, audio blocks, USB MIDI bytes out (raw) / in (injected), the key-to-UI latency
probe, and the fill of every Rytm-side queue found (peeked from the window's end snapshot, addresses from the build's 0026 object):
  usb_ring (0x413db258 bytes of 4091), usb_free (free USB requests of 32), pmo ring (rh - rt of 256, ring_drop, link_drop),
  sq ring (qh - qt of 32, drops, ev_drops), ed ring (qh - qt of 8, drops), pj ring (wr - rd of 32, lost), key queue (st.kq_n of 16,
  st.tx_drop, tx_busy).
"""
import json
import os
import random
import re
import subprocess
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import lag_emu as L   # noqa: E402
import us_emu as U    # noqa: E402
from us_emu import P, Emu, check, elek_sym   # noqa: E402

M_S = 200          # M instructions a second
RING_FILL, USB_POOL = 0x413db258, 0x413db390


def nm(tag_out):
    r = subprocess.run(["m68k-elf-nm", os.path.join(tag_out, "0026-remote-ui.elf")], capture_output=True, text=True)
    return r


def bss_syms(obj):
    r = subprocess.run(["m68k-elf-nm", "-S", obj], capture_output=True, text=True, check=True)
    out = {}
    for line in r.stdout.splitlines():
        f = line.split()
        if len(f) == 4 and f[2] in "bB":
            out[f[3]] = int(f[0], 16)
    return out


def u32(b, o):
    return int.from_bytes(b[o:o + 4], "big")


def dense_setup(t0=100):
    """L.setup_events with all 16 steps of BD and SD as trigs."""
    ev, t = L.setup_events(t0)
    base = [x for x in ev if not (x[1] == "press" and re.fullmatch(r"T\d+", str(x[2])))]
    # rebuild: the walk events come before the first RECORD press
    k = next(i for i, x in enumerate(base) if x[1] == "press" and x[2] == "RECORD")
    head, t1 = base[:k], base[k][0]
    out = head + [(t1, "press", "RECORD")]
    t1 += 40
    for n in range(1, 17):
        out.append((t1, "press", f"T{n}"))
        t1 += 30
    out.append((t1, "press", "BD"))
    t1 += 60
    for n in range(1, 17):
        out.append((t1, "press", f"T{n}"))
        t1 += 30
    out += [(t1, "press", "RECORD"), (t1 + 40, "press", "PLAY")]
    return out, t1 + 400


def window_events(w, secs, rng):
    """Events (relative M) of window w: modulation bursts, page switches, track selection, the host's traffic."""
    ev, pages = [], ["SRC", "SMPL", "FLTR"]
    n = secs * M_S
    for t in range(2, n, 100):                     # two bursts a second
        enc = rng.randrange(8)
        ev.append((t + 20, "turn", (f"{enc}:{rng.choice(['+8', '-8', '+4', '-4'])}", 6, 5)))
    for k, t in enumerate(range(10, n, 3 * M_S)):  # a page switch every 3 s
        ev.append((t, "press", pages[(w * 7 + k) % 3]))
    for k, t in enumerate(range(5 * M_S, n, 9 * M_S)):   # the other track every 9 s
        ev.append((t, "press", "BD" if (w + k) % 2 == 0 else "SD"))
    ev += host_traffic(n, w)
    if RUI:
        ev += rui_traffic(w, n, rng)
    return sorted(ev, key=lambda x: x[0])


RUI = False   # --rui: the host also mirrors the Rytm's screen (remote UI open), as a Pi with a display does


def rui_traffic(w, n, rng):
    """The remote UI host (rytm-teensy sim/remote_ui.py's traffic): 3A open at the start, a two-tile update + commit every 50 ms
    (20 Hz), a whole frame (16 x 8 tiles, 1024 B) every 0.5 s (a knob burst redraws the page)."""
    import protocol as PP
    fb = bytearray(rng.randrange(256) for _ in range(1024))
    out, seq = [], w * 1000
    if w == 0:
        out.append((M_S // 10, "usb", PP.rui_open(0, 1)))
    if RUI == "quiet":      # a tester's black box: the open SRC view, a 3C keepalive 4 a second, no frames
        out += [(t, "usb", PP.rui_keepalive()) for t in range(M_S // 8, n, M_S // 4)]
        return out
    for k, t in enumerate(range(30, n, 10)):
        seq += 1
        c0, p0 = rng.randrange(16), rng.randrange(8)
        if k % 10 == 9:
            for i in range(1024):
                fb[i] ^= rng.choice((0, 0xFF))
            msg = PP.rui_rect(seq, 0, 0, 16, 8, fb) + PP.rui_commit(seq)
        else:
            for x in range(c0 * 8, c0 * 8 + 8):
                fb[p0 + 8 * x] ^= 0xFF
            msg = PP.rui_rect(seq, c0, p0, 1, 1, fb) + PP.rui_commit(seq)
        out.append((t, "usb", msg))
    return out


def host_traffic(n, _):
    out = []
    for t in range(M_S // 2, n, M_S):              # a keepalive a second
        out.append((t, "usb", P.rui_keepalive()))
    for t in range(2 * M_S, n, 5 * M_S):           # the slot generations every 5 s (as the Pi re-announces)
        out.append((t, "usb", P.slots([5, 0, 0, 0, 0], 0)))
    return out


class Soak(L.Run):
    def __init__(self, e, name, syms):
        super().__init__(e, name)
        self.s = syms
        self.in_total = 0

    def peek_queues(self, snap):
        e, s = self.e, self.s
        r = {}
        r["usb_ring"] = u32(e.peek(snap, RING_FILL, 4), 0)
        h, n = u32(e.peek(snap, USB_POOL, 4), 0), 0
        while h and n < 40:
            n += 1
            h = u32(e.peek(snap, h + 52, 4), 0)
        r["usb_free"] = n
        pm = e.peek(snap, s["pmo"], 96)
        r["pmo_fill"], r["pmo_rh"], r["pmo_rt"] = (u32(pm, 56) - u32(pm, 80)) & 0xffffffff, u32(pm, 56), u32(pm, 80)
        r["pmo_ring_drop"] = u32(pm, 4)
        sq = e.peek(snap, s["sq"], 0x60 + 0x130)
        r["sq_fill"], r["sq_drops"], r["sq_ev_drops"] = (u32(sq, 268) - u32(sq, 272)) & 0xffffffff, u32(sq, 380), u32(sq, 384)
        ed = e.peek(snap, s["ed"], 80)
        r["ed_fill"], r["ed_drops"] = (u32(ed, 64) - u32(ed, 68)) & 0xffffffff, u32(ed, 72)
        pj = e.peek(snap, s["pj"], 0xbc)
        r["pj_fill"], r["pj_lost"] = (u32(pj, 0) - u32(pj, 4)) & 0xffffffff, u32(pj, 156)
        st = e.peek(snap, s["st"], 208)
        r["kq_n"], r["tx_drop"], r["tx_busy"], r["tx_ok"], r["ticks_total"] = u32(st, 196), u32(st, 44), u32(st, 40), u32(st, 36), u32(st, 8)
        return r

    def soak_window(self, idx, ev, extra, secs):
        e = self.e
        for _, kind, val in ev:
            if kind == "press" and val in ("BD", "SD"):
                self.sel = val
        length = secs * M_S
        t0 = time.time()
        s = e.run(f"{self.name}-w{idx:03d}", length, list(ev), count=[self.rt, L.MIXER], save=True, snap=self.snap, start=self.clock,
                  extra=list(extra))
        wall = time.time() - t0
        m = re.search(r"(\d+) instructions \((\d+) executed, (\d+) idle-skipped\)", e.log)
        inst, ex = (int(m.group(1)), int(m.group(2))) if m else (0, 0)
        usb_out = os.path.getsize(os.path.join(e.tmp, f"{self.name}-w{idx:03d}.usb")) if os.path.exists(os.path.join(e.tmp, f"{self.name}-w{idx:03d}.usb")) else -1
        usb_in = sum(len(v) for _, k, v in ev if k == "usb")
        row = dict(idx=idx, t_s=(idx + 1) * secs, load=100.0 * ex / inst if inst else 0.0, ui_per_s=e.counts.get(self.rt, 0) / secs,
                   blocks_per_s=e.counts.get(L.MIXER, 0) / secs, usb_out=usb_out, usb_in=usb_in, wall_s=wall, sel=self.sel)
        cm = {}
        for mm in e.sent:
            if len(mm) > 5:
                cm[mm[4]] = cm.get(mm[4], 0) + 1
        row["sysex_per_s"] = len(e.sent) / secs
        row["sysex_bytes_avg"] = sum(len(mm) for mm in e.sent) / len(e.sent) if e.sent else 0
        row["cmds"] = {f"{k:02x}": round(v / secs, 2) for k, v in sorted(cm.items(), key=lambda x: -x[1])[:6]}
        row.update(self.peek_queues(s))
        self.snap, self.clock = s, self.clock + length
        return row


def main():
    a = sys.argv[1:]
    if not a:
        sys.exit(__doc__)
    tag = a[0]
    opt = lambda k, d: a[a.index(k) + 1] if k in a else d   # noqa: E731
    nwin, secs, outf = int(opt("--windows", 20)), int(opt("--secs", 30)), opt("--out", f"soak-{tag}.jsonl")
    probe = "--noprobe" not in a
    global RUI
    RUI = "quiet" if "--rui-quiet" in a else ("--rui" in a)
    e = Emu(tag)
    man = json.load(open(os.path.join(e.out, "manifest.json")))["elek"]["symbols"]
    syms = {n: man["rytm-0026-remote-ui:" + n] for n in ("pmo", "sq", "ed", "pj", "st")}   # run addresses (the area's .bss)
    name = opt("--name", "soak")
    noread = "--noread" in a   # from window 4 on the host does not read the Rytm's USB MIDI out (a stalled Pi)
    run = Soak(e, name, syms)
    ev, t = L.setup_events(100)
    if "--dense" in a:      # every one of the 16 steps a trig on both tracks (more trig reports)
        ev = [x for x in ev if not (x[1] == "press" and re.fullmatch(r"T\d+", str(x[2])))]
        tt = max(x[0] for x in ev if x[1] == "press" and x[2] in ("RECORD",)) if False else None
        ev, t = dense_setup()
    s = e.run("soak-setup", t, ev, save=True)
    m = e.peek(s, 0x8000ea00, 2)
    check("soak: BD plays PLAITS (44), SD plays U1 (35)", (m[0], m[1]) == (44, 35), m.hex())
    run.snap, run.clock = s, e.clock + t
    rng, rows = random.Random(11), []
    with open(outf, "w") as fh:
        for w in range(nwin):
            extra = (["--usb-host-noread", str(run.clock)] if noread and w >= 4 else []) + ["--qperf-sweep", "0:255:6@30M/4M" if w % 2 == 0 else "255:0:6@30M/4M"]
            row = run.soak_window(w, window_events(w, secs, rng), extra, secs)
            row["lat_ms"] = run.probe(f"t={row['t_s']} s", f"lat{w:03d}") if probe else None
            rows.append(row)
            fh.write(json.dumps(row) + "\n")
            fh.flush()
            print(f"  t={row['t_s']:4d}s load {row['load']:5.1f}% ui {row['ui_per_s']:5.1f}/s blk {row['blocks_per_s']:6.1f}/s out {row['usb_out']:6d} B in {row['usb_in']:5d} B "
                  f"lat {row['lat_ms']} ring {row['usb_ring']} free {row['usb_free']} pmo {row['pmo_fill']} sq {row['sq_fill']} ed {row['ed_fill']} "
                  f"pj {row['pj_fill']} kq {row['kq_n']} drops(pmo/sq/ed/tx) {row['pmo_ring_drop']}/{row['sq_drops']}/{row['ed_drops']}/{row['tx_drop']} wall {row['wall_s']:.0f}s", flush=True)
    print("SOAK DONE", "FAILED: " + "; ".join(U.fails) if U.fails else "no fault")


if __name__ == "__main__":
    main()
