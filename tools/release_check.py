#!/usr/bin/env python3
"""The release gate for the elekloader bundle (docs/ELEKLOADER.md, mods/0027-elekloader/design.md).

    .venv/bin/python tools/release_check.py --dir build/release/0.3.0 --expect build/mainos_rel-0.3.0.bin

Takes ONLY what we publish (the folder's core-*.elemod and rytm-sidecar-*.elemod, checked against its
SHA256SUMS) and the user's stock .syx, and builds them the two ways a user would, with upstream's own code
at the pinned vendor/elekloader:

- the command line: `elekloader.lint`, `elekloader.patch --check`, `elekloader.patch --out`;
- the web page: web/bridge.py, the module the page's worker runs under Pyodide (gui.LoaderModel,
  gui.with_requirements, patch.build / patch.save), run here in CPython on a scratch folder in place of
  its in-memory /work. The files are added as the page adds a user's own files (add_mod: the page lists
  no Rytm core for OS 1.73), the bundle is ticked (its requirements tick the core), checked and built,
  once with version 1.73 (what the docs say to type) and once with the page's default version.

Each image must have our build's MAIN OS byte for byte (--expect), and sections 1, 2 (the bootstrap,
also by its pinned sha256, docs/HAZARDS.md), 5 and 8 as stock. Then the refusals: the bundle without a
core, and with core-ar2 0.2 (built from upstream's 92a99c9, the last 1.73 core) are refused.

Writes only under --work (default build/release_check). Exit status 0: every check passed.
"""
import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ELEK_DIR = ROOT / "vendor" / "elekloader"
EFT = ROOT / "vendor" / "elektron-firmware-tool" / "elektron-firmware-tool"
STOCK_SYX = ROOT / "stock" / "Analog-Rytm_MKII_OS1.73.syx"
BOOTSTRAP_SHA256 = "1b8d3b7288df118512740ac7c59d8dd9f71f44e6633a29628bcb068d756e2ed8"   # docs/HAZARDS.md
# core-ar2 0.1 as elekloader 8972d70 built it and as the rui builds since rui1051 carry it
CORE_SHA256 = "33de51c098ab0ecd9cc57e9dfc3efa3d95f8133b1f4a4e6abd80d5fdba2dd825"
CORE02_REV = "92a99c9"          # upstream's last core-ar2 for OS 1.73: 0.2, with mod storage (docs/CORES.md)
STOCK_SECTIONS = (1, 2, 5, 8)
MAIN_SECTION = 3

failures = []

sys.path.insert(0, str(ROOT / "tools"))
from build import CORE_STORE_GUARD                       # noqa: E402  the guard's addresses
GUARD_ADDRS = {f"0x{a:08x}" for sites in CORE_STORE_GUARD.values() for a, _n in sites}


def sha256(b):
    return hashlib.sha256(b).hexdigest()


def check(ok, what):
    print(("ok   " if ok else "FAIL ") + what)
    if not ok:
        failures.append(what)
    return ok


def elek(*args, ok_codes=(0,)):
    """python -m <elekloader module> ... at the pinned checkout -> (returncode, output)."""
    env = dict(os.environ, ELEKLOADER_CROSS="m68k-elf-")
    p = subprocess.run([sys.executable, "-m", *map(str, args)], cwd=ELEK_DIR, env=env,
                       capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr


def sections(syx, out):
    """{section id: bytes} of a .syx, extracted by our own elektron-firmware-tool."""
    shutil.rmtree(out, ignore_errors=True)
    out.mkdir(parents=True)
    subprocess.run([EFT, "-i", syx, "-o", out], check=True, capture_output=True)
    got = {}
    for f in out.iterdir():
        if f.name.startswith("section_") and f.suffix in (".bin", ".raw"):
            got[int(f.name.split("_")[1])] = f.read_bytes()
    return got


# the web page's worker module, run on a folder: bridge.py's source with its /work replaced
WEB = r'''
import json, sys
sys.path.insert(0, ELEK)
src = open(ELEK + "/web/bridge.py").read()
assert "WORK = '/work'" in src
ns = {"__name__": "bridge"}
exec(compile(src.replace("WORK = '/work'", "WORK = %r" % WORK), "web/bridge.py", "exec"), ns)
call = ns["call"]
class Data:                                   # what the worker hands over (a JS buffer: .to_bytes())
    def __init__(self, path): self.raw = open(path, "rb").read()
    def to_bytes(self): return self.raw
def c(name, args, data=None):
    return json.loads(call(name, json.dumps(args), data))
st = c("set_stock", {"name": STOCK.rsplit("/", 1)[-1]}, Data(STOCK))
out = {"stock": {k: st.get(k) for k in ("ok", "error")}, "default_version": st["dev"]["default_version"]}
paths = {}
for f in FILES:
    r = c("add_mod", {"name": f.rsplit("/", 1)[-1]}, Data(f))
    out.setdefault("add", []).append({k: r.get(k) for k in ("ok", "error")})
    paths[f] = r["mod"]["path"]
listed = c("mods", {})
out["mods"] = [{k: d.get(k) for k in ("id", "version", "license", "requires", "status", "error")}
               for d in listed]
enabled = c("tick", {"enabled": [], "path": paths[BUNDLE]})
out["ticked"] = sorted(p.rsplit("/", 1)[-1] for p in enabled)
out["check"] = c("check", {"enabled": enabled})
out["builds"] = {}
for v in VERSIONS:
    out["version_" + v] = c("version", {"version": v, "enabled": enabled})
    b = json.loads(call("build", json.dumps({"enabled": enabled, "version": v, "name": "web-" + v}), None))
    out["builds"][v] = {k: b.get(k) for k in ("ok", "error", "sha256", "version", "mods", "untouched",
                                              "gap", "flash_end", "files")}
print(json.dumps(out))
'''


def web_build(work, files, bundle, versions):
    """Run the web page's code path; -> its result, and {version: built .syx path}."""
    shutil.rmtree(work, ignore_errors=True)
    work.mkdir(parents=True)
    pre = (f"ELEK = {str(ELEK_DIR)!r}\nWORK = {str(work / 'work')!r}\nSTOCK = {str(STOCK_SYX)!r}\n"
           f"FILES = {[str(f) for f in files]!r}\nBUNDLE = {str(bundle)!r}\nVERSIONS = {versions!r}\n")
    p = subprocess.run([sys.executable, "-I", "-c", pre + WEB], cwd=work, capture_output=True, text=True)
    if p.returncode != 0:
        check(False, "web page path ran: " + (p.stdout + p.stderr)[-2000:])
        return None, {}
    res = json.loads(p.stdout.strip().splitlines()[-1])
    built = {}
    for v, b in res["builds"].items():
        if b.get("ok"):
            # bridge.build saves into WORK/out, which it empties per build: keep each one
            src = work / "work" / "out" / ("web-" + v + ".syx")
            dst = work / ("web-" + v + ".syx")
            if check(src.exists(), f"web: build {v!r} wrote {src.name}"):
                shutil.copy(src, dst)
                built[v] = dst
    return res, built


def image_checks(label, syx, expect_main, stock_secs, work):
    secs = sections(syx, work / ("x-" + label))
    main = secs.get(MAIN_SECTION, b"")
    check(main == expect_main, f"{label}: MAIN OS is our build's, byte for byte "
                               f"({sha256(main)[:16]}..., {len(main)} B)")
    for n in STOCK_SECTIONS:
        check(secs.get(n) == stock_secs[n], f"{label}: section {n} as stock")
    check(sha256(secs.get(2, b"")) == BOOTSTRAP_SHA256, f"{label}: bootstrap sha256 {BOOTSTRAP_SHA256[:16]}...")
    return sha256(syx.read_bytes())


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    ap.add_argument("--dir", required=True, type=Path, help="the release folder (what we publish)")
    ap.add_argument("--expect", required=True, type=Path, help="our build's MAIN OS (build/mainos_<tag>.bin)")
    ap.add_argument("--expect-syx", required=True, type=Path,
                    help="the .syx build.py wrote for the release (the one the emulator suites run)")
    ap.add_argument("--doc", type=Path, help="the user guide whose hashes must be this release's")
    ap.add_argument("--work", type=Path, default=ROOT / "build" / "release_check")
    args = ap.parse_args()

    work = args.work.resolve()
    shutil.rmtree(work, ignore_errors=True)
    (work / "in").mkdir(parents=True)

    # 1. what is published, and nothing else
    sums = dict(reversed(l.split(None, 1)) for l in (args.dir / "SHA256SUMS").read_text().splitlines() if l)
    sums = {k.strip().lstrip("*"): v for k, v in sums.items()}
    elemods = sorted(p.name for p in args.dir.glob("*.elemod"))
    cores = [n for n in elemods if n.startswith("core-")]
    bundles = [n for n in elemods if n.startswith("rytm-sidecar-")]
    check(len(cores) == 1 and len(bundles) == 1 and len(elemods) == 2,
          f"published: one core and one bundle ({', '.join(elemods)})")
    if failures:
        return 1
    for n in elemods:
        raw = (args.dir / n).read_bytes()
        check(sums.get(n) == sha256(raw), f"{n}: sha256 {sha256(raw)} as SHA256SUMS")
        shutil.copy(args.dir / n, work / "in" / n)
    core, bundle = work / "in" / cores[0], work / "in" / bundles[0]
    doc = json.loads(bundle.read_text())
    cdoc = json.loads(core.read_text())
    check(sha256(core.read_bytes()) == CORE_SHA256, f"core: sha256 is the pinned {CORE_SHA256[:16]}...")
    check(cdoc["id"] == "core" and cdoc["version"] == "0.1" and cdoc["target"]["os"] == "1.73",
          f"core: {cdoc['id']} {cdoc['version']} for OS {cdoc['target']['os']}")
    check(doc["license"] == "GPL-2.0-or-later" and doc["author"] == "trigcondition"
          and doc["requires"] == ["core"] and doc.get("resources", {}).get("core") == "0.1",
          f"bundle: {doc['id']} {doc['version']}, {doc['license']}, by {doc['author']}, requires "
          f"{doc['requires']}, core >= {doc.get('resources', {}).get('core')}")

    want = {l.split()[1]: l.split()[0] for l in (ROOT / "stock" / "SHA256SUMS").read_text().splitlines() if l}
    check(sha256(STOCK_SYX.read_bytes()) == want[STOCK_SYX.name], f"stock: {STOCK_SYX.name} as stock/SHA256SUMS")
    stock_secs = sections(STOCK_SYX, work / "x-stock")
    expect_main = args.expect.read_bytes()
    results = {"files": {n: sums[n] for n in elemods}}

    # 2. the command line
    rc, out = elek("elekloader.lint", bundle, "--stock", STOCK_SYX, "--with", core)
    check(rc == 0, "lint " + bundle.name + " --with " + core.name + ": " +
          " | ".join(l for l in out.splitlines() if l.startswith(("OK", "PROBLEM")))[:400])
    rc, out = elek("elekloader.lint", core, bundle)
    check(rc == 0, "lint of each file on its own")
    rc, out = elek("elekloader.patch", "--stock", STOCK_SYX, "--mod", core, "--mod", bundle, "--check")
    check(rc == 0 and "OK: the mods combine" in out, "patch --check: " + out.strip().splitlines()[-1])
    cli = work / "cli.syx"
    rc, out = elek("elekloader.patch", "--stock", STOCK_SYX, "--mod", core, "--mod", bundle,
                   "--out", cli, "--version", "1.73")
    if check(rc == 0 and cli.exists(), "patch --out (version 1.73)"):
        print("     " + " | ".join(l.strip() for l in out.splitlines() if l.startswith(("linked", "verified"))))
        results["cli"] = image_checks("cli", cli, expect_main, stock_secs, work)

    # 3. the web page's code path
    res, built = web_build(work / "web", [core, bundle], bundle, ["1.73"])
    if res:
        dv = res["default_version"]
        if dv != "1.73":
            res2, built2 = web_build(work / "web-default", [core, bundle], bundle, [dv])
            if res2:
                res["builds"].update(res2["builds"])
                built.update(built2)
        check(res["stock"]["ok"], "web: the stock file is known")
        check(all(a["ok"] for a in res["add"]), "web: both files added as the user's own")
        check(sorted(res["ticked"]) == sorted([core.name, bundle.name]),
              f"web: ticking the bundle ticks {', '.join(res['ticked'])}")
        ck = res["check"]
        check(isinstance(ck, dict) and ck.get("ok"), "web: live check " +
              json.dumps({k: ck.get(k) for k in ("ok", "headline", "problems") if k in ck})[:300])
        for v, b in res["builds"].items():
            check(bool(b.get("ok")), f"web: build, version {v!r}: {b.get('error') or b.get('mods')}")
            if v in built:
                results["web-" + v] = image_checks("web " + v, built[v], expect_main, stock_secs, work)
        results["web_default_version"] = dv
    ours = sha256(args.expect_syx.read_bytes())
    results["build_py"] = ours
    for k in ("cli", "web-1.73"):
        check(results.get(k) == ours, f"{k} .syx is build.py's {args.expect_syx.name} ({ours[:16]}...)")

    # 4. what must be refused
    rc, out = elek("elekloader.patch", "--stock", STOCK_SYX, "--mod", bundle, "--check")
    check(rc != 0, "refused without a core: " + out.strip().splitlines()[-1][:200])
    c02 = work / "core02"
    (c02 / "src").mkdir(parents=True)
    arc = subprocess.run(["git", "-C", ELEK_DIR, "archive", CORE02_REV, "mods/core", "mods/core-ar2"],
                         check=True, capture_output=True).stdout
    subprocess.run(["tar", "-x", "-C", c02 / "src"], input=arc, check=True)
    rc, out = elek("elekloader.sdk.build", c02 / "src" / "mods" / "core-ar2", "--stock", STOCK_SYX,
                   "--out", c02 / "out")
    core02 = next((c02 / "out").glob("core-0.2*.elemod"), None)
    if check(rc == 0 and core02 is not None, f"core-ar2 0.2 built from {CORE02_REV} (for the refusal)"):
        rc, out = elek("elekloader.patch", "--stock", STOCK_SYX, "--mod", core02, "--mod", bundle, "--check")
        # the refusal must come from the guard: an overlap at one of its addresses
        why = [l for l in out.splitlines() if "overlap" in l and any(a in l for a in GUARD_ADDRS)]
        check(rc != 0 and bool(why), "refused with core 0.2 by the guard: " +
              (why[0].strip() if why else out[-300:]))

    # 5. the user guide's hashes are this release's
    if args.doc:
        text = args.doc.read_text()
        for what, h in (("core", sums[cores[0]]), ("bundle", sums[bundles[0]]), ("built .syx", ours)):
            check(h in text, f"{args.doc.name} gives the {what}'s sha256 {h[:16]}...")

    (work / "result.json").write_text(json.dumps(results, indent=1) + "\n")
    print("FAIL: %d check(s)" % len(failures) if failures else "PASS")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
