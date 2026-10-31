#!/usr/bin/env python3
"""The emulator suites, picked by what changed, run up to N at once, one line a suite.

    tools/emu/suites.py TAG --changed REV       the suites covering what differs from REV (commits, the working tree's
                                                edits, untracked files); REV may be a range A..B
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
unmade) runs as several processes, each a subset of its tests (and, for stockupkeys / stockup, a subset of the keys
through the suites' own UPKEYS / STOCKUP_KEYS). Every check still runs; a sharded suite repeats a few baseline runs
per shard (and stockup's one menu control check runs in both its shards).
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
# one reruns this one too); est: wall seconds measured 2026-10-29 (rel0-3-0, run.sh -j 5, build/emu_jobs birth
# times to build/suites/*.log mtimes), for the longest-first order and the plan's estimate.
SUITES = {
    "rled": dict(mods={"0026"}, est=6099),
    "us":   dict(mods={"0021", "0029", "0023", "0014", "0004"}, est=1649),
    "sfu":  dict(mods={"0029", "0021", "0025"}, imports={"us", "sfx"}, est=1193),
    "pj":   dict(mods={"0026"}, est=904),
    "sfx":  dict(mods={"0025"}, imports={"us"}, est=709),
    "bk":   dict(mods={"0029", "0026"}, imports={"sv", "rui"}, est=665),
    "sq":   dict(mods={"0026", "0021"}, est=597),
    "cu":   dict(mods={"0021", "0029", "0026"}, imports={"pc"}, est=245),
    "sp":   dict(mods={"0021", "0029"}, imports={"us", "sfx"}, est=215),
    "rui":  dict(mods={"0026"}, est=187),
    "sv":   dict(mods={"0026", "0029", "0021"}, imports={"rui"}, est=173),
    "pc":   dict(mods={"0026", "0021", "0022"}, est=102),
    "mrep": dict(mods={"0026", "0021"}, est=91),
    "fxin": dict(mods={"0030", "0022", "0024"}, est=43),
    "td":   dict(mods={"0023"}, imports={"us"}, est=37),
    "frz":  dict(mods={"0029"}, est=22),
}
# rled's 24 tests by their dtboot runs (rel0-3-0's job dir): stockupkeys 254, stockup 116, stocktrigup 44, upstock 38,
# menustock 23 (long runs), upamp 20, the rest 6..18 each. Every rled test is independent (Emu keeps no run state;
# stock_kw makes sections/rled_stock.snap only when it is missing: then rled is not sharded, see shards()).
RLED_UPKEYS = ["TRIG", "SRC", "SMPL", "FLTR", "AMP", "LFO", "FX", "YES", "NO", "RECORD", "PLAY", "STOP", "PAGE",
               "BD", "SD", "RS", "CP", "BT", "LT", "MT", "HT", "CH", "OH", "CY", "CB", "T14", "T15", "T16"]
RLED_REST = ["levelhdr", "stocktrktrig", "stocktrkfx", "stockyes", "kit", "hostclose", "stockcombo", "combo", "leds",
             "ledexit", "bad", "trigs", "trkled", "upmap", "menustock", "upmappage", "stocklockpush", "upmaplist",
             "upmapmenu"]
RLED_SHARDS = [   # (tests, env, est s after the stock_state peek change)
    (["stockupkeys"], {"UPKEYS": ",".join(RLED_UPKEYS[0:10])}, 260),
    (["stockupkeys"], {"UPKEYS": ",".join(RLED_UPKEYS[10:19])}, 240),
    (["stockupkeys"], {"UPKEYS": ",".join(RLED_UPKEYS[19:28])}, 240),
    (["stockup"], {"STOCKUP_KEYS": "6-9"}, 170),
    (["stockup", "stocktrigup"], {"STOCKUP_KEYS": "10-13"}, 290),
    (["upstock", "upamp"] + RLED_REST[:7], {}, 330),
    (RLED_REST[7:], {}, 260),
]

# files -> suites. ALL: everything in the image or every harness reads it. NONE: nothing a suite runs.
ALL_PATHS = ("mods/0000-shared/", "mods/0027-elekloader/", "mods/0028-elek-hello/", "registry/", "re/symbols.toml",
             "stock/", "tools/build.py", "tools/layout.py", "tools/symbols.py", "Makefile", "tools/emu/us_base.sh",
             "tools/emu/us_ui.json", "tools/emu/us_window.py", "build/suites/run.sh", "VERSION")
NONE_PATHS = ("docs/", "re/subsystems/", "re/ghidra/", "tools/comp/", "tools/test_", "tools/cavescan.py",
              "tools/verify.py", "tools/release_check.py", "tools/voice_dac_timing.py", "tools/us_records.py",
              "tools/emu/suites.py", "tools/emu/README.md", "tools/emu/el_area.py", "LICENSE", "NOTICE", ".gitignore",
              "requirements.txt", "README.md", "CLAUDE.md")
PATH_SUITES = {"tools/build_rui.sh": set(SUITES), "tools/looper_base.sh": set(SUITES)}
# the mods every image carries (enabled by default, stock sites) that no suite is about: the quick suites that boot
# the image and drive its UI, as a smoke test (the full set runs before a flash)
SMOKE = ["frz", "td", "fxin", "rui", "sv"]
STOCK_SITE_MODS = {"0002", "0003", "0004", "0006", "0008", "0009", "0010", "0012", "0013", "0020"}


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
        elif f.startswith("tools/emu/") and f.endswith("_emu.py") and f[10:-7] in SUITES:
            add(importers(f[10:-7]), f)
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
        if not os.path.exists(os.path.join(emu, "sections", "rled_stock.snap")):
            notes.append("rled not sharded: sections/rled_stock.snap is missing (its first run makes it)")
        elif not rled_shards_ok():
            notes.append("rled not sharded: RLED_SHARDS / RLED_UPKEYS in suites.py miss rled_emu.py's TESTS / UPKEYS")
        else:
            return [(f"rled.{i + 1}", t, e, est) for i, (t, e, est) in enumerate(RLED_SHARDS)]
    est = SUITES[suite]["est"] if suite != "rled" else 1700   # rled unsharded after the peek change (estimate)
    return [(suite, None, {}, est)]


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
    ap.add_argument("--full", action="store_true")
    ap.add_argument("--plan", action="store_true")
    ap.add_argument("-j", type=int, default=6)
    ap.add_argument("--retry-alone", default="rui")
    ap.add_argument("--no-shard", action="store_true")
    ap.add_argument("--fails", type=int, default=8)
    ap.add_argument("--keep-snaps", action="store_true")
    a = ap.parse_args()
    if sum(map(bool, (a.changed, a.full, a.suites))) != 1:
        sys.exit("suites.py: give one of --changed REV, --full or SUITE names")
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
        files = changed_files(a.changed)
        why, notes = pick(files)
        print(f"changed since {a.changed}: {len(files)} file(s) -> {len(why)} suite(s)")

    env0 = dict(os.environ)
    for k, v in ENV_DEFAULTS.items():
        env0.setdefault(k, v)
    emu = os.path.expanduser(env0["RYTM_EMU"])
    py = os.path.join(ROOT, ".venv", "bin", "python")
    py = py if os.path.exists(py) else sys.executable
    jobs = []
    for s in why:
        for name, tests, env, est in shards(s, emu, not a.no_shard, notes):
            jobs.append(dict(name=name, suite=s, tests=tests, env=env, est=est))
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
