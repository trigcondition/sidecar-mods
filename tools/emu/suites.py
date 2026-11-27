#!/usr/bin/env python3
"""The emulator suites, picked by what changed, run up to N at once, one line a suite.

    tools/emu/suites.py TAG --changed REV       the suites covering what differs from REV (commits, the working tree's
                                                edits, untracked files); REV may be a range A..B
    tools/emu/suites.py TAG --host-changed REV  the host checkout (RYTM_TEENSY) differs from REV: its sim/protocol.py or
                                                sim/remote_ui.py -> rui, pm, sv, bk (alone, or together with --changed)
    tools/emu/suites.py TAG --full              every suite (once, before a flash)
    tools/emu/suites.py TAG SUITE [SUITE ...]   these suites
    ... --plan                                  print the jobs (why each, its command, its estimate) and run nothing

    -j N            jobs at once (default 6; the machine has 10 cores and sq / rui run threads of their own)
    --retry-alone S suites rerun once alone when they fail in the parallel phase (default "rui": real-time host
                    threads, flaky under load); "none" turns it off. The alone result is the verdict.
    --no-shard      run every suite as one process (as build/suites/run.sh does)
    --fails N       FAIL lines printed a failing suite (default 8; the full log has them all)
    --keep-snaps    keep each job's end snapshots (otherwise deleted when the job ends)

Stdout: one line a suite (name, verdict, PASS / FAIL counts, wall seconds, log), the FAIL lines of a failing suite,
the wall clock. Nothing else: the PASS lines stay in the logs. Read a log only when its suite failed.

Files (build/suites/, as build/suites/run.sh writes them): SUITE.log the full output (a sharded suite: its shards'
logs one after another), SUITE.N.log each shard's, SUITE.times (seconds since the job's start, then the line: where the
time goes), summary.txt ("SUITE rc=N" sorted, then "done"), summary.json (counts, times, shards).

Isolation as run.sh's: a job gets build/emu_jobs/JOB/ as RYTM_OUT_ROOT (the manifests and .elf objects of every
build/emu/*/ copied in) and as TMPDIR; ports are ephemeral; the shared base cards are only read.

Shards: a suite whose tests share nothing between them (no state on the Emu object, no module cache another test needs
unmade) runs as several processes, each a subset of its tests (SPLITS: us, sfu, sfx, md, sq, bk, pj; rled also, for
stockupkeys / stockup, a subset of the keys through the suites' own UPKEYS / STOCKUP_KEYS). Every check still runs; a
sharded rled repeats a few baseline runs per shard (and stockup's one menu control check runs in both its shards). A
shard table that no longer matches the script's TESTS is not used: the suite runs as one process, with a note.

Estimates: build/suites/est.json keeps each passing job's seconds from its last run (keyed by the job and what it runs);
--plan and the longest-first order use them, then the table's est.
"""
import argparse
import ast
import json
import os
import shutil
import subprocess
import sys
import threading
import time

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ENV_DEFAULTS = {   # as build/suites/run.sh
    "RYTM_EMU": "../rytm-emu",
    "RYTM_TEENSY": "../rytm-teensy",
}

# ---- what covers what
# mods: the mods a suite exercises (its docstring and symbols); imports: the suite scripts it imports (a change to
# one reruns this one too); est: a suite's wall seconds as one process, measured 2026-11-19 (OS 1.74, --full -j 4,
# before the shards), for the longest-first order and the plan's estimate when build/suites/est.json has no entry.
SUITES = {
    # 0029: its ev_key subscriber (order 5, ahead of 0026's) takes a page key's press on a user effect's SEND FX page
    "rled": dict(mods={"0026", "0029"}, est=6099),   # one process, 2026-10-29 (its shards: RLED_SHARDS)
    "us":   dict(mods={"0021", "0029", "0023", "0014", "0004"}, est=1890),
    "sfu":  dict(mods={"0029", "0021", "0025"}, imports={"us", "sfx"}, est=1369),
    "pj":   dict(mods={"0026"}, est=922),
    "sfx":  dict(mods={"0025"}, imports={"us"}, est=1010),
    "bk":   dict(mods={"0029", "0026"}, imports={"sv", "rui"}, est=915),
    "sq":   dict(mods={"0026", "0021"}, est=888),
    "cu":   dict(mods={"0021", "0029", "0026"}, imports={"pc"}, est=387),
    "sp":   dict(mods={"0021", "0029"}, imports={"us", "sfx"}, est=233),
    "rui":  dict(mods={"0026", "0029"}, est=276),   # (0029: the key subscriber, as for rled)
    "sv":   dict(mods={"0026", "0029", "0021"}, imports={"rui"}, est=239),
    "pc":   dict(mods={"0026", "0021", "0022"}, est=109),
    "mrep": dict(mods={"0026", "0021"}, est=93),
    "md":   dict(mods={"0021", "0029"}, imports={"us", "sfx"}, est=1520),
    "mi":   dict(mods={"0021", "0026", "0022"}, imports={"pc", "cu"}, est=168),
    "ar":   dict(mods={"0021", "0026", "0022"}, imports={"us"}, est=236),
    "fxin": dict(mods={"0030", "0022", "0024"}, est=66),
    "td":   dict(mods={"0023"}, imports={"us"}, est=37),
    "frz":  dict(mods={"0029"}, est=22),
    "sa44": dict(mods={"0021", "0026", "0014"}, imports={"us", "sfx"}, est=87),   # 0.5.0: SAMPLER on a 0.4.4 Rytm (needs build/emu/f44b)
    "pm":   dict(mods={"0026"}, imports={"rui"}, est=217),   # 0.5.0: the Rytm's own params modulated (ops 04..07)
    "ms":   dict(mods={"0026"}, imports={"sq", "rled"}, est=1100),   # the scene edit on stock pages (morph v2); its declared stock-fact probes print STOCK, not FAIL
    "ram":  dict(mods={"0026", "0029"}, imports={"rui", "sfu"}, est=120),   # the UI-task buffers in the bundle's DDR region (dirty DDR)
}
# rled's 24 tests by their dtboot runs (rel0-3-0's job dir): stockupkeys 254, stockup 116, stocktrigup 44, upstock 38,
# menustock 23 (long runs), upamp 20, the rest 6..18 each. Every rled test is independent (Emu keeps no run state;
# stock_kw makes sections/rled_stock.snap only when it is missing: then rled is not sharded, see shards()).
RLED_UPKEYS = ["TRIG", "SRC", "SMPL", "FLTR", "AMP", "LFO", "FX", "YES", "NO", "RECORD", "PLAY", "STOP", "PAGE",
               "BD", "SD", "RS", "CP", "BT", "LT", "MT", "HT", "CH", "OH", "CY", "CB", "T14", "T15", "T16", "LEFT", "RIGHT"]
RLED_REST = ["levelhdr", "stocktrktrig", "stocktrkfx", "stockyes", "kit", "hostclose", "stockcombo", "combo", "leds",
             "ledexit", "bad", "trigs", "trkled", "upmap", "menustock", "upmappage", "stocklockpush", "upmaplist",
             "upmapmenu", "upt14", "uplr", "uplrclaim", "stockuparrows"]
RLED_SHARDS = [   # (tests, env, est s after the stock_state peek change)
    (["stockupkeys"], {"UPKEYS": ",".join(RLED_UPKEYS[0:10])}, 260),
    (["stockupkeys"], {"UPKEYS": ",".join(RLED_UPKEYS[10:19])}, 240),
    (["stockupkeys"], {"UPKEYS": ",".join(RLED_UPKEYS[19:30])}, 290),
    (["stockup"], {"STOCKUP_KEYS": "6-9"}, 170),
    (["stockup", "stocktrigup"], {"STOCKUP_KEYS": "10-14"}, 290),
    (["upstock", "upamp"] + RLED_REST[:7], {}, 330),
    (RLED_REST[7:], {}, 260),
]

# Suites whose tests share nothing (each runs from the base snapshot; no state on the Emu object; a lazy cache is only
# made inside the tests that use it, so those stay in one shard: sfu's pages + names, sq's pin + pinvel) run as several
# processes. (tests, est s): the tests by their seconds in a full OS 1.74 run (.times files), balanced to about 500 s
# a shard, in the suite's own order. The runner checks the table against the script's TESTS and falls back to one
# process, with a note, when they differ (a test added to a script and not here).
SPLITS = {
    "us": [
        (["old16", "dspmod", "strict", "stale", "tagpower", "assigntrig", "installfail", "shortpart", "kitguard"], 488),
        (["base", "exciter", "names", "writeback", "page2", "stock", "choose", "tag", "tagkeep", "tag14"], 487),
        (["takeover", "enum", "enum36", "labels", "texts", "poweroff", "assign", "sound", "tagpool", "choosetrig",
          "assigngen"], 491),
        (["variants", "unused", "junopat", "menu", "load", "window", "taglock", "tagname", "untagged", "install",
          "tagkit1", "freshtrig"], 486),
        (["smplpage_u1", "smplayer", "smpvoices", "smpnoise", "smpswitch", "smpseq", "smplong", "smpcpu", "smpref",
          "smpshared", "smpall"], 552),   # the sample-layer tests (0.5.2): the table missed them, so us ran as one process (2,661 s)
    ],
    "sfu": [
        (["labels", "locks", "pretick", "save", "stock"], 560),   # stock reads save's (and locks') result: same shard
        (["enumlock", "enumkit", "ext", "bw", "bw2"], 441),
        (["fmname", "enum", "typelist", "cost", "bwwrap", "pages", "names", "kits"], 407),
        (["fullnames", "xpages", "xmisc", "xlock"], 430),   # the full names and the extra SEND FX pages (estimates, 2026-11-24)
        (["xkeys", "xcopy"], 340),
        (["xreset"], 370),
        (["xfix", "xcc"], 450),
    ],
    "sfx": [
        (["fx38", "stock"], 619),   # stock reads fx38's result: same shard (fx38 alone is ~470 s)
        (["nokit", "report", "migrate", "sendlock", "reload", "kitswitch"], 394),
    ],
    "md": [
        (["fresh", "nohost", "kitload", "convert", "hold", "dspold"], 503),
        (["list", "labels", "kit", "tracks", "stuck", "dspmix", "switch"], 502),
        (["sound", "stops", "ask", "plock", "paste", "old", "marker", "same030"], 503),
    ],
    "sq": [
        (["savereload", "fill", "pause", "stock", "rec", "state", "scale", "dirty", "freezeprobe", "trktrig", "trkyes",
          "playmode", "disp", "seqpage", "upcombo", "upseq", "fillwrite", "fillpersist", "fillqueue", "otherplay_live",
          "otherprobe"], 442),
        (["recleds", "jump", "ticks", "switch", "mode", "solo", "hello", "pin", "pinvel", "edits", "seqedit", "fetch",
          "fetchrace", "noreload", "yestime", "trkfx", "lockkeys", "yes", "trigkey", "trkpad", "otherplay",
          "otherfm", "bankcopy"], 455),   # (bankcopy's seconds added)
    ],
    "bk": [
        (["range", "lock", "browse", "salist", "sa2a", "sabusy", "upt", "nrpn", "popups", "dspknob", "dsplistlock",
          "dspnrpn", "upsrc", "latehost", "polymenu", "uplrlist", "wtwarp", "wtbank"], 540),
        (["preset", "knob", "text", "list", "browsefunc", "browseknob", "saopen", "listlock", "scale", "banka", "tbldef",
          "dsplist", "dspbrowse", "dsptext", "dsplock", "dspold", "wtftyp"], 520),
        (["tblblist", "tblbbrowse", "tblblock", "tblbold", "tblbguard", "tblbcover", "tblbgate", "tblbnodraw"], 420),   # (+ tblbgate, tblbnodraw: the script has had them; the table missed them, so bk ran as one process)
    ],
    "ms": [   # pagekeys is one test over 13 contexts (PAGECTX, as rled's UPKEYS): a shard each group; the rest in one
        (["pagekeys"], 300, {"PAGECTX": "main,grid,gridtrig"}),
        (["pagekeys"], 300, {"PAGECTX": "src,fltr,trig"}),
        (["pagekeys"], 300, {"PAGECTX": "chro,scne,perf"}),
        (["pagekeys"], 450, {"PAGECTX": "mute,bank,menu,fx"}),
        (["mute", "qpmute", "padword", "padtrig", "padbase", "pagelen", "pagecatch", "leds", "hdr", "edcap", "edfx", "edgrid",
          "edpick", "edpage", "edleds", "edread", "edhello", "edhold", "edrehello", "edclear", "m2", "pagelat", "pagefast",
          "pagechord", "pageplay", "pageunarm", "edrate"], 900),
    ],
    "pj": [
        (["hello", "saveto_empty", "copypaste", "clear", "locked", "init", "renameactive", "createnew", "setters"], 450),
        (["saveas", "saveto", "clearactive", "delete", "rename", "load", "loadsave", "lock", "reloadactive", "nohost",
          "kits"], 466),
    ],
}
DEFAULT_EST = 300   # a suite script not in SUITES yet (see pick)

# files -> suites. ALL: everything in the image or every harness reads it. NONE: nothing a suite runs.
ALL_PATHS = ("mods/0000-shared/", "mods/0027-elekloader/", "mods/0028-elek-hello/", "registry/", "re/symbols.toml",
             "re/os/",   # the OS ports' address maps: every suite runs on a ported tree
             
             "stock/", "tools/build.py", "tools/layout.py", "tools/symbols.py", "Makefile", "tools/emu/us_base.sh",
             "tools/emu/us_ui.json", "tools/emu/us_window.py", "build/suites/run.sh", "VERSION",
             "re/os/")   # the port's address map: every 1.74 suite runs through it

NONE_PATHS = ("docs/", "re/subsystems/", "re/ghidra/", "tools/comp/", "tools/test_", "tools/cavescan.py",
              "tools/verify.py", "tools/release_check.py", "tools/voice_dac_timing.py", "tools/us_records.py",
              "tools/emu/suites.py", "tools/emu/README.md", "tools/emu/el_area.py", "LICENSE", "NOTICE", ".gitignore",
              "requirements.txt", "README.md", "CLAUDE.md", ".github/")
# measurement scripts (F4 / machine-list lag), not suites; no suite imports them
NONE_PATHS += ("tools/emu/lag_emu.py", "tools/emu/lag_base.sh", "tools/emu/mll_emu.py", "tools/emu/soak_emu.py",
               "tools/emu/keytime_emu.py", "tools/emu/hostcost_emu.py", "tools/emu/modcost_emu.py",
               "tools/emu/boot_emu.py")
PATH_SUITES = {"tools/build_rui.sh": set(SUITES), "tools/looper_base.sh": set(SUITES),
               "tools/emu/sfu_pretick.s": {"sfu"}}   # sfu_emu pretick's stub
# the mods every image carries (enabled by default, stock sites) that no suite is about: the quick suites that boot
# the image and drive its UI, as a smoke test (the full set runs before a flash)
SMOKE = ["frz", "td", "fxin", "rui", "sv"]
STOCK_SITE_MODS = {"0002", "0003", "0004", "0006", "0008", "0009", "0010", "0012", "0013", "0020"}


HOST_FILES = ("sim/protocol.py", "sim/remote_ui.py")   # RYTM_TEENSY's modules the rui family imports


def importers(name):
    """name and every suite importing it, transitively."""
    out, todo = {name}, [name]
    while todo:
        n = todo.pop()
        for s, d in SUITES.items():
            if n in d.get("imports", ()) and s not in out:
                out.add(s)
                todo.append(s)
    return out


def pick(files):
    """-> ({suite: [reason]}, [notes])."""
    why, notes = {}, []

    def add(suites, reason):
        for s in suites:
            why.setdefault(s, []).append(reason)

    for f in files:
        if f in PATH_SUITES:
            add(PATH_SUITES[f], f)
        elif f.startswith(ALL_PATHS):
            add(SUITES, f)
        elif f.startswith(NONE_PATHS) or f.endswith(".md"):
            continue
        elif f.startswith("tools/emu/") and f.endswith("_emu.py"):
            name = f[10:-7]
            if name in SUITES:
                add(importers(name), f)
            else:   # a new suite script: it runs alone (a default estimate); not every suite
                add([name], f + " (new suite)")
                notes.append(f"{f}: not in SUITES (suites.py); it runs alone; register it there (mods, imports, est)")
        elif f.startswith("mods/"):
            mod = f.split("/")[1][:4]
            hit = [s for s, d in SUITES.items() if mod in d["mods"]]
            if hit:
                add(hit, f)
            elif mod in STOCK_SITE_MODS:
                add(SMOKE, f + " (smoke)")
                notes.append(f"{f}: no suite is about mod {mod}; the smoke set runs (and --full before a flash)")
            else:
                add(SUITES, f + " (unknown mod)")
        else:
            add(SUITES, f + " (unmapped path)")
            notes.append(f"{f}: not in suites.py's map, so every suite; map it (ALL_PATHS / NONE_PATHS)")
    return why, notes


def changed_files(rev):
    """Files differing from rev (a commit: plus the working tree's edits and untracked files; a range A..B: only it)."""
    git = ["git", "-C", ROOT]
    out = subprocess.run(git + ["diff", "--name-only", rev], capture_output=True, text=True, check=True).stdout.split()
    if ".." not in rev:
        out += subprocess.run(git + ["ls-files", "--others", "--exclude-standard"], capture_output=True, text=True,
                              check=True).stdout.split()
    return sorted(set(out))


# ---- the jobs
def cmd(py, suite, tag, tests):
    return [py, os.path.join("tools", "emu", f"{suite}_emu.py"), tag] + (tests or ["all"])


def script_names(suite, var):
    """A suite script's TESTS keys (var "TESTS") or a list literal (var "UPKEYS"), read without importing it."""
    tree = ast.parse(open(os.path.join(ROOT, "tools", "emu", f"{suite}_emu.py")).read())
    for node in tree.body:
        if isinstance(node, ast.Assign) and any(getattr(t, "id", None) == var for t in node.targets):
            v = node.value
            if isinstance(v, ast.Call):   # dict(a=t_a, ...)
                return [k.arg for k in v.keywords]
            if isinstance(v, ast.Dict):
                return [k.value for k in v.keys]
            return [x.value for x in v.elts]
    return None


def rled_shards_ok():
    """The shards cover exactly rled_emu.py's TESTS and UPKEYS (a test or key added there and not here: no shards)."""
    tests = {t for ts, _, _ in RLED_SHARDS for t in ts}
    return tests == set(script_names("rled", "TESTS") or ()) and script_names("rled", "UPKEYS") == RLED_UPKEYS


def shards(suite, emu, shard, notes):
    """[(job name, tests or None for all, extra env, est s)]"""
    if suite == "rled" and shard:
        sys.path.insert(0, os.path.join(ROOT, "tools"))
        import ostarget                        # the tree's OS: rled_emu.py's STOCK_BASE
        base = "rled_stock" + ("" if ostarget.tree_os() == "1.73" else "_os" + ostarget.tree_os())
        if not os.path.exists(os.path.join(emu, "sections", base + ".snap")):
            notes.append(f"rled not sharded: sections/{base}.snap is missing (its first run makes it)")
        elif not rled_shards_ok():
            notes.append("rled not sharded: RLED_SHARDS / RLED_UPKEYS in suites.py miss rled_emu.py's TESTS / UPKEYS")
        else:
            return [(f"rled.{i + 1}", t, e, est) for i, (t, e, est) in enumerate(RLED_SHARDS)]
    elif suite in SPLITS and shard:
        ents = [(e[0], e[1], e[2] if len(e) > 2 else {}) for e in SPLITS[suite]]   # (tests, est s[, env])
        plain = [t for ts, _, env in ents if not env for t in ts]
        tests = sorted(set(plain) | {t for ts, _, env in ents if env for t in ts})   # an env shard repeats its test (ms pagekeys)
        if len(plain) != len(set(plain)) or tests != sorted(script_names(suite, "TESTS") or ()):
            notes.append(f"{suite} not sharded: SPLITS[{suite!r}] in suites.py misses {suite}_emu.py's TESTS")
        else:
            return [(f"{suite}.{i + 1}", ts, env, est) for i, (ts, est, env) in enumerate(ents)]
    est = SUITES.get(suite, {}).get("est", DEFAULT_EST) if suite != "rled" else 1700   # rled unsharded (estimate)
    return [(suite, None, {}, est)]


def est_key(j):
    """A job's key in build/suites/est.json: its name and what it runs (a changed shard table is a new key)."""
    return j["name"] + "|" + ",".join(j["tests"] or ["all"]) + "|" + ",".join(f"{k}={v}" for k, v in j["env"].items())


def load_est(sdir):
    try:
        return json.load(open(os.path.join(sdir, "est.json")))
    except (OSError, ValueError):
        return {}


def setup(jobdir):
    """A fresh job dir: the manifests and symbol objects of every build, nothing else (run.sh's setup)."""
    shutil.rmtree(jobdir, ignore_errors=True)
    os.makedirs(os.path.join(jobdir, "tmp"))
    src = os.path.join(ROOT, "build", "emu")
    for t in sorted(os.listdir(src)) if os.path.isdir(src) else []:
        if not os.path.isdir(os.path.join(src, t)):
            continue
        os.makedirs(os.path.join(jobdir, t), exist_ok=True)
        for f in os.listdir(os.path.join(src, t)):
            if f == "manifest.json" or f.endswith(".elf"):
                shutil.copy(os.path.join(src, t, f), os.path.join(jobdir, t, f))


def counts(path):
    p = f = 0
    for line in open(path, errors="replace"):
        s = line.lstrip()
        if s.startswith(("PASS ", "PASS:")):
            p += 1
        elif s.startswith(("FAIL ", "FAIL:")):
            f += 1
    return p, f


def run_job(job, py, tag, env0, keep, suffix=""):
    """Run one job, its output to build/suites/JOB[.alone].log and JOB.times. -> rc, seconds."""
    name, suite, tests, env = job["name"], job["suite"], job["tests"], job["env"]
    sdir = os.path.join(ROOT, "build", "suites")
    jobdir = os.path.join(ROOT, "build", "emu_jobs", name)
    setup(jobdir)
    e = dict(env0, RYTM_OUT_ROOT=jobdir, TMPDIR=os.path.join(jobdir, "tmp"), PYTHONUNBUFFERED="1", **env)
    log_path = os.path.join(sdir, f"{name}{suffix}.log")
    t0 = time.monotonic()
    with open(log_path, "w") as log, open(os.path.join(sdir, f"{name}{suffix}.times"), "w") as tl:
        p = subprocess.Popen(cmd(py, suite, tag, tests), cwd=ROOT, env=e, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, text=True, errors="replace")
        for line in p.stdout:
            log.write(line)
            tl.write(f"{time.monotonic() - t0:8.1f}\t{line}")
        rc = p.wait()
    dt = time.monotonic() - t0
    if not keep:
        for d, _, fs in os.walk(jobdir):
            for f in fs:
                if f.endswith(".snap"):
                    os.remove(os.path.join(d, f))
    shutil.rmtree(os.path.join(jobdir, "tmp"), ignore_errors=True)
    return rc, dt, log_path


def pool(jobs, n, fn):
    """Run fn(job) for every job, at most n at once, in list order (longest first)."""
    sem, threads = threading.Semaphore(n), []

    def one(j):
        try:
            fn(j)
        finally:
            sem.release()

    for j in jobs:
        sem.acquire()
        t = threading.Thread(target=one, args=(j,))
        t.start()
        threads.append(t)
    for t in threads:
        t.join()


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("tag")
    ap.add_argument("suites", nargs="*")
    ap.add_argument("--changed", metavar="REV")
    ap.add_argument("--host-changed", metavar="REV",
                    help="the host checkout (RYTM_TEENSY) differs from REV: sim/protocol.py, sim/remote_ui.py -> rui, pm, sv, bk")
    ap.add_argument("--full", action="store_true")
    ap.add_argument("--plan", action="store_true")
    ap.add_argument("-j", type=int, default=6)
    ap.add_argument("--retry-alone", default="rui")
    ap.add_argument("--no-shard", action="store_true")
    ap.add_argument("--fails", type=int, default=8)
    ap.add_argument("--keep-snaps", action="store_true")
    a = ap.parse_args()
    if sum(map(bool, (a.changed or a.host_changed, a.full, a.suites))) != 1:
        sys.exit("suites.py: give one of --changed REV and / or --host-changed REV, --full or SUITE names")
    bad = [s for s in a.suites if s not in SUITES]
    if bad:
        sys.exit(f"suites.py: no suite {bad}; known: {' '.join(SUITES)}")
    if a.j < 1:
        sys.exit("suites.py: -j needs a positive number")

    notes = []
    if a.full:
        why = {s: ["--full"] for s in SUITES}
    elif a.suites:
        why = {s: ["named"] for s in a.suites}
    else:
        why, notes = {}, []
        if a.changed:
            files = changed_files(a.changed)
            why, notes = pick(files)
            print(f"changed since {a.changed}: {len(files)} file(s) -> {len(why)} suite(s)")

    env0 = dict(os.environ)
    for k, v in ENV_DEFAULTS.items():
        env0.setdefault(k, v)
    if a.host_changed:   # the host checkout's protocol modules are what rui and its importers talk to
        host = os.path.expanduser(env0["RYTM_TEENSY"])
        hfiles = subprocess.run(["git", "-C", host, "diff", "--name-only", a.host_changed], capture_output=True,
                                text=True, check=True).stdout.split()
        hit = [f for f in hfiles if f in HOST_FILES]
        for s in importers("rui") if hit else ():
            why.setdefault(s, []).append("host " + hit[0])
        print(f"host changed since {a.host_changed}: {len(hfiles)} file(s) -> {len(hit)} protocol file(s)")
    emu = os.path.expanduser(env0["RYTM_EMU"])
    py = os.path.join(ROOT, ".venv", "bin", "python")
    py = py if os.path.exists(py) else sys.executable
    jobs = []
    for s in why:
        for name, tests, env, est in shards(s, emu, not a.no_shard, notes):
            jobs.append(dict(name=name, suite=s, tests=tests, env=env, est=est))
    seen = load_est(os.path.join(ROOT, "build", "suites"))   # the last runs' seconds: the plan tells the truth
    for j in jobs:
        j["est"] = seen.get(est_key(j), j["est"])
    jobs.sort(key=lambda j: -j["est"])   # longest first: the pool stays full to the end

    base = os.path.join(emu, "sections", f"us_{a.tag}.snap")
    if a.plan:
        for s in sorted(why):
            print(f"{s:5s} <- {', '.join(why[s][:4])}" + (f" (+{len(why[s]) - 4})" if len(why[s]) > 4 else ""))
        for j in jobs:
            env = " ".join(f"{k}={v}" for k, v in j["env"].items())
            print(f"  job {j['name']:8s} ~{j['est']:5d} s  {env + ' ' if env else ''}"
                  f"{' '.join(cmd('PY', j['suite'], a.tag, j['tests'])[1:])}")
        # longest-first list scheduling onto -j slots: the wall clock estimate
        slots = [0.0] * a.j
        for j in jobs:
            i = slots.index(min(slots))
            slots[i] += j["est"]
        print(f"estimate: {max(slots or [0]):.0f} s wall at -j {a.j} ({sum(j['est'] for j in jobs)} s of jobs)"
              + ("" if os.path.exists(base) else f"; NO BASE {base}: tools/emu/us_base.sh {a.tag} first"))
        for n in notes:
            print("note: " + n)
        return 0
    if not jobs:
        print("no suite covers these changes")
        for n in notes:
            print("note: " + n)
        return 0
    if not os.path.exists(base):
        sys.exit(f"suites.py: no base {base}: make it with tools/emu/us_base.sh {a.tag} (right after building it)")

    sdir = os.path.join(ROOT, "build", "suites")
    os.makedirs(sdir, exist_ok=True)
    res, lock, t_start = {}, threading.Lock(), time.monotonic()

    def go(j, suffix=""):
        rc, dt, log = run_job(j, py, a.tag, env0, a.keep_snaps, suffix)
        with lock:
            res[(j["name"], suffix)] = dict(rc=rc, secs=round(dt), log=log)

    pool(jobs, a.j, go)
    retry = set() if a.retry_alone == "none" else set(a.retry_alone.split())
    again = [j for j in jobs if j["suite"] in retry and res[(j["name"], "")]["rc"] != 0]
    if again:
        pool(again, 1, lambda j: go(j, ".alone"))

    # one line a suite: its shards' final verdicts (the alone rerun's where there is one) together
    summary, bad_any, lines = {}, False, []
    for s in sorted(why):
        mine = sorted((j for j in jobs if j["suite"] == s), key=lambda j: j["name"])
        fin = [res.get((j["name"], ".alone")) or res[(j["name"], "")] for j in mine]
        rc = next((r["rc"] for r in fin if r["rc"] != 0), 0)
        p = f = 0
        for r in fin:
            pp, ff = counts(r["log"])
            p, f = p + pp, f + ff
        secs = max(r["secs"] for r in fin)
        log = fin[0]["log"]
        if len(mine) > 1:   # SUITE.log: the shards' logs in order, for whoever reads build/suites/SUITE.log
            log = os.path.join(sdir, f"{s}.log")
            with open(log, "w") as out:
                for j, r in zip(mine, fin):
                    out.write(f"#### {j['name']} {' '.join(f'{k}={v}' for k, v in j['env'].items())} rc={r['rc']}\n")
                    out.write(open(r["log"], errors="replace").read())
        alone = any((j["name"], ".alone") in res for j in mine)
        note = " (rerun alone)" if alone else ""
        bad_any |= rc != 0
        summary[s] = dict(rc=rc, passed=p, failed=f, secs=secs, log=os.path.relpath(log, ROOT),
                          shards={j["name"]: res.get((j["name"], ".alone")) or res[(j["name"], "")] for j in mine},
                          parallel_rc={j["name"]: res[(j["name"], "")]["rc"] for j in mine})
        lines.append(f"{s:5s} {'ok  ' if rc == 0 else 'FAIL'} rc={rc:<3d} {p:4d} pass {f:3d} fail {secs:5d} s"
                     f"{f' ({len(mine)} shards)' if len(mine) > 1 else ''}{note}  {os.path.relpath(log, ROOT)}")
    for s, line in zip(sorted(why), lines):
        print(line)
        if summary[s]["rc"] != 0:
            shown = 0
            for r in summary[s]["shards"].values():
                for x in open(r["log"], errors="replace"):
                    if x.lstrip().startswith(("FAIL", "Traceback")) or "FAILED" in x:
                        if shown < a.fails:
                            print("      " + x.strip()[:300])
                        shown += 1
            if shown > a.fails:
                print(f"      ... {shown - a.fails} more in the log")
            if shown == 0:
                print("      (no FAIL line: the log's tail)")
                for x in open(list(summary[s]["shards"].values())[0]["log"], errors="replace").readlines()[-5:]:
                    print("      " + x.rstrip()[:300])
    wall = round(time.monotonic() - t_start)
    seen = load_est(sdir)   # passing jobs' seconds (the parallel run's: the alone rerun is not typical)
    seen.update({est_key(j): res[(j["name"], "")]["secs"] for j in jobs if res[(j["name"], "")]["rc"] == 0})
    tmp = os.path.join(sdir, f"est.json.{os.getpid()}")   # whole file or none: a reader never sees half of it
    with open(tmp, "w") as f:
        json.dump(seen, f, indent=1, sort_keys=True)
    os.replace(tmp, os.path.join(sdir, "est.json"))
    with open(os.path.join(sdir, "summary.txt"), "w") as out:
        for s in sorted(summary):
            pr = next((rc for rc in summary[s]["parallel_rc"].values() if rc != 0), 0)
            if any(sfx == ".alone" and n in summary[s]["parallel_rc"] for n, sfx in res):
                out.write(f"{s} rc={pr} (parallel)\n{s} rc={summary[s]['rc']} (alone)\n")
            else:
                out.write(f"{s} rc={summary[s]['rc']}\n")
        out.write("done\n")
    json.dump(dict(tag=a.tag, j=a.j, wall=wall, why=why, suites=summary), open(os.path.join(sdir, "summary.json"), "w"),
              indent=1)
    print(f"wall clock {wall} s, -j {a.j}; build/suites/summary.json")
    return 1 if bad_any else 0


if __name__ == "__main__":
    sys.exit(main())
