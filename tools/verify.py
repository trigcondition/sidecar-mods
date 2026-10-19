#!/usr/bin/env python3
"""Post-build checks: the .syx round-trips, the sections we do not touch come back
unchanged, and the image differs from stock in exactly the regions the registry
claims - nothing else moved."""

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import layout
import symbols as symmod

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build"
STOCK_SYX = ROOT / "stock" / "Analog-Rytm_MKII_OS1.73.syx"
EFT = ROOT / "vendor" / "elektron-firmware-tool" / "elektron-firmware-tool"


def run(cmd):
    p = subprocess.run(cmd, capture_output=True, text=True)
    if p.returncode != 0:
        raise SystemExit(f"failed: {' '.join(map(str, cmd))}\n{p.stdout}{p.stderr}")
    return p.stdout


def diff_regions(a: bytes, b: bytes, base: int):
    """Contiguous differing spans, merged across gaps of < 16 identical bytes."""
    spans, i, n = [], 0, len(a)
    while i < n:
        if a[i] != b[i]:
            j = i
            gap = 0
            k = i
            while k < n and gap < 16:
                if a[k] != b[k]:
                    j = k
                    gap = 0
                else:
                    gap += 1
                k += 1
            spans.append((i + base, j - i + 1))
            i = j + 1
        else:
            i += 1
    return spans


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tag", default=None, help="defaults to the most recent build")
    args = ap.parse_args()

    if args.tag is None:
        found = sorted(BUILD.glob("manifest_*.json"), key=lambda f: f.stat().st_mtime)
        if not found:
            raise SystemExit("no build found; run tools/build.py first")
        args.tag = found[-1].stem[len("manifest_"):]

    syms = symmod.load(ROOT / "re" / "symbols.toml")
    meta = syms["meta"]
    base = meta["base"]
    reg = layout.load(ROOT / "registry" / "allocations.toml")
    manifest = json.loads((BUILD / f"manifest_{args.tag}.json").read_text())

    stock = (BUILD / "stock_mainos.bin").read_bytes()
    layout.resolve_expect(reg, stock, base)
    patched = (BUILD / f"mainos_{args.tag}.bin").read_bytes()
    syx = BUILD / manifest["syx"]

    ok = True

    # The vendored tool can rebuild a container verbatim. That gives this project the
    # null-repack self-check octatrack-mods never had: if re-emitting Elektron's own
    # file does not reproduce it byte for byte, the packer is not trustworthy and no
    # claim about our own output means anything.
    null = BUILD / "null_repack.syx"
    run([EFT, "-i", STOCK_SYX, "-r", "-o", null])
    if null.read_bytes() == STOCK_SYX.read_bytes():
        print("ok   null repack: stock .syx rebuilds byte-identically")
    else:
        print("FAIL null repack: rebuilding the untouched stock .syx changed it")
        ok = False

    elek = manifest.get("elek")
    if elek:
        # an elekloader build (mods/0027-elekloader/design.md): the image is stock's length
        # plus the block elekloader appends (core's .boot, then the run image it copies to
        # the area at boot); everything below stock's end is checked as before
        lay = elek["layout"]
        end = base + len(stock)
        boot_lo, boot_hi = lay["boot"]
        run_lo = lay["run_load"]
        run_len = lay["ddr"][1] - lay["ddr"][0]
        tail_ok = (boot_lo >= end and boot_lo - end < 16 and run_lo == boot_hi
                   and base + len(patched) >= run_lo + run_len
                   and base + len(patched) - (run_lo + run_len) < 16
                   and not any(patched[len(stock):boot_lo - base]))
        area_ok = elek["area"][0] <= lay["ddr"][0] and lay["bss"][1] <= elek["area"][1]
        if tail_ok and area_ok:
            print(f"ok   elekloader block appended at 0x{boot_lo:08x}: .boot {boot_hi - boot_lo} B, "
                  f"run image {run_len} B -> 0x{lay['ddr'][0]:08x}..0x{lay['bss'][1]:08x} "
                  f"(.bss to the end), {lay['ddr_spare']} B of the area spare")
        else:
            print(f"FAIL elekloader block: tail {tail_ok}, inside its area {area_ok} ({lay})")
            ok = False
        site = 0x400008c0 - base
        want = b"\x4e\xb9" + boot_lo.to_bytes(4, "big")
        if bytes(patched[site:site + 6]) == want:
            print(f"ok   boot site 0x400008c0: jsr 0x{boot_lo:08x} (core's .boot, appended)")
        else:
            print(f"FAIL boot site 0x400008c0 holds {bytes(patched[site:site + 6]).hex()}, "
                  f"expected {want.hex()}")
            ok = False
        hdr, mine_hdr = STOCK_SYX.read_bytes()[0x24:0x40], syx.read_bytes()[0x24:0x40]
        if hdr == mine_hdr:
            print(f"ok   container header (ELE3, build, version {elek['version']}) as stock")
        else:
            print(f"FAIL container header {mine_hdr.hex()} != stock {hdr.hex()}")
            ok = False
        prefix = patched[:len(stock)]
    else:
        prefix = patched
    if len(stock) != len(prefix):
        print(f"FAIL size {len(stock)} -> {len(patched)}")
        ok = False
    else:
        print(f"ok   size unchanged ({len(prefix)} B{' below the appended block' if elek else ''})")

    # round-trip: unpack what we just packed, expect the same MAIN OS back, and expect
    # every other section to be exactly what stock carried - above all the bootstrap,
    # which is the recovery path and which nothing here is allowed to disturb.
    tmp = BUILD / "verify_extract"
    shutil.rmtree(tmp, ignore_errors=True)
    tmp.mkdir(parents=True)
    run([EFT, "-i", syx, "-o", tmp])
    back = (tmp / "section_3_MAIN_OS.bin").read_bytes()
    if back == patched:
        print(f"ok   {syx.name} round-trips to a byte-identical MAIN OS")
    else:
        print(f"FAIL round-trip differs (got {len(back)} B, "
              f"sha {hashlib.sha256(back).hexdigest()[:16]})")
        ok = False

    boot = (tmp / "section_2_bootstrap.bin").read_bytes()
    if hashlib.sha256(boot).hexdigest() == meta["bootstrap_sha256"]:
        print(f"ok   bootstrap unchanged ({len(boot)} B) - recovery path intact")
    else:
        print("FAIL bootstrap section changed; nothing here may write to it")
        ok = False

    stock_tmp = BUILD / "extract"
    for other in sorted(stock_tmp.glob("section_*")):
        if other.name.startswith(("section_2_", "section_3_")):
            continue
        mine = tmp / other.name
        if not mine.exists():
            print(f"FAIL {other.name} missing from the rebuilt .syx")
            ok = False
        elif mine.read_bytes() != other.read_bytes():
            print(f"FAIL {other.name} differs from stock")
            ok = False
        else:
            print(f"ok   {other.name} unchanged ({mine.stat().st_size:,} B)")

    # the diff must be exactly the claimed regions
    claimed = []
    # only the claims this build made (its mods, their gates as built): a manifest from
    # before "enabled" was recorded falls back to every claim
    on = manifest.get("enabled")
    prm = manifest.get("params", {})

    def made(c):
        return on is None or (c["owner"] in on and
                              not layout.gated_out(c.get("gate"), prm.get(c["owner"], {}), c["owner"]))
    for c in reg.get("cave", []):
        if made(c) and not (manifest.get("elek") and c["owner"] in manifest["elek"]["mods"]):
            claimed.append((c["addr"], c["size"], f"cave/{c['owner']}"))
    for d in reg.get("detour", []):
        if made(d):
            # elek_size: in an area build the jmp site covers the whole displaced span (nop padded)
            n = d.get("elek_size", d["size"]) if manifest.get("elek") and \
                d["owner"] in manifest["elek"]["mods"] else d["size"]
            claimed.append((d["addr"], n, f"detour/{d['owner']}"))
    for q in reg.get("patch", []):
        if made(q):
            claimed.append((q["addr"], q["size"], f"patch/{q['owner']}"))

    spans = diff_regions(stock, prefix, base)
    print(f"     {len(spans)} differing region(s):")
    for addr, size in spans:
        # The assertion is that every byte which ACTUALLY CHANGED lies inside some
        # claim - not that the whole span sits inside one. diff_regions deliberately
        # bridges short runs of identical bytes, so a span can legitimately straddle
        # two claims and the untouched bytes between them.
        off0 = addr - base
        owners, unclaimed = [], []
        for k in range(size):
            if stock[off0 + k] == patched[off0 + k]:
                continue
            va = base + off0 + k
            hit = next((n for a, sz, n in claimed if a <= va < a + sz), None)
            if hit is None:
                unclaimed.append(va)
            elif hit not in owners:
                owners.append(hit)
        if unclaimed:
            print(f"FAIL   0x{addr:08x} +{size:<4} UNCLAIMED - "
                  f"{len(unclaimed)} changed byte(s) outside the registry, "
                  f"first at 0x{unclaimed[0]:08x}")
            ok = False
        else:
            print(f"ok     0x{addr:08x} +{size:<4} {', '.join(owners)}")

    # every detour in the built image must jump to the symbol the build resolved -
    # a stale detour pointing into a stub that moved is a known way to brick the unit
    for q in manifest.get("patches", []):
        off = q["addr"] - base
        want = bytes.fromhex(q["replace"])
        got = bytes(patched[off:off + len(want)])
        if got == want:
            print(f"ok   patch 0x{q['addr']:08x} holds {want.hex()}")
        else:
            print(f"FAIL patch 0x{q['addr']:08x} holds {got.hex()}, expected {want.hex()}")
            ok = False
    for q in (elek or {}).get("patches", []):
        # a pointer into the area elekloader wrote (a from_symbol patch of an area mod)
        off = q["addr"] - base
        got = int.from_bytes(patched[off:off + 4], "big")
        if got == q["target"] and elek["area"][0] <= got < elek["area"][1]:
            print(f"ok   patch 0x{q['addr']:08x} -> {q['symbol']} @ 0x{got:08x} (elekloader area)")
        else:
            print(f"FAIL patch 0x{q['addr']:08x} holds 0x{got:08x}, expected {q['symbol']} "
                  f"@ 0x{q['target']:08x} in the area")
            ok = False
    for d in manifest.get("detours", []):
        off = d["addr"] - base
        got = bytes(patched[off:off + 6])
        want = b"\x4e\xf9" + d["target"].to_bytes(4, "big")
        if d.get("elek") and not (elek["area"][0] <= d["target"] < elek["area"][1]):
            print(f"FAIL detour 0x{d['addr']:08x} -> 0x{d['target']:08x}, outside the elekloader area")
            ok = False
        elif got == want:
            print(f"ok   detour 0x{d['addr']:08x} -> {d['entry']} @ 0x{d['target']:08x}")
        else:
            print(f"FAIL detour 0x{d['addr']:08x} holds {got.hex()}, expected {want.hex()}")
            ok = False

    # the displaced bytes must reappear verbatim inside the owner's stub - catches a
    # prologue that was never re-emitted, or re-emitted with the wrong registers.
    #
    # A detour may opt out with `reemit = false`, for the case where the stub
    # REIMPLEMENTS the displaced instructions instead of replaying them and resumes
    # past them. That is a real pattern, but it is also exactly how a forgotten
    # prologue looks, so the opt-out is per-claim, must be written down in the
    # registry next to the reasoning, and is reported here rather than skipped.
    # A mod may hold several claims across pools, so the block a stub is searched in
    # is all of them joined. A sequence spanning the join is not a real match, but
    # these are presence heuristics and the odds of a false one are negligible.
    caves = {}
    for c in reg.get("cave", []):
        caves.setdefault(c["owner"], []).append(c)
    def stub_bytes(mid):
        if elek and mid in elek["mods"]:
            # the run image as appended (what core's .boot copies to the area)
            lo = elek["layout"]["run_load"] - base
            return bytes(patched[lo:lo + elek["layout"]["ddr"][1] - elek["layout"]["ddr"][0]])
        return b"".join(bytes(patched[c["addr"] - base: c["addr"] - base + c["size"]])
                        for c in caves[mid])
    for d in manifest.get("detours", []):
        blk = stub_bytes(d["mod"])
        want = bytes.fromhex(d["displaced"])
        if not d.get("reemit", True):
            state = "also present" if want in blk else "absent as declared"
            print(f"ok   displaced {want.hex()} for 0x{d['addr']:08x} REIMPLEMENTED "
                  f"in {d['mod']}'s stub, not re-emitted ({state})")
        elif want in blk:
            print(f"ok   displaced {want.hex()} re-emitted in {d['mod']}'s stub")
        else:
            print(f"FAIL displaced {want.hex()} for 0x{d['addr']:08x} never re-emitted "
                  f"in {d['mod']}'s stub")
            ok = False

    # and it must rejoin stock exactly past the instructions it re-emitted. The
    # default is addr + the displaced length. A detour that deliberately resumes
    # further on says so with `rejoin = 0x...`, and one that handles the call outright
    # and returns says `rejoin = "none"`; both are declared in the registry and
    # reported here rather than skipped.
    #
    # What this catches: `expect` claiming more bytes than the stub actually rejoins
    # past. That is how 0004 shipped a stub that re-emitted a call AND the `addql`
    # after it, then landed back on that same `addql`, popping the arguments twice and
    # corrupting the stack of every list the constructor built - stock's own included.
    # Nothing else noticed: the displaced bytes were all present and the jmp target
    # was a real instruction.
    #
    # What it does NOT catch: a stub that re-emits an extra instruction the registry
    # never claimed, with `expect` and the jmp both self-consistent. Seeing that needs
    # the stub decoded, not just searched. The byte check below only spots it in the
    # narrow case where the duplicate sits immediately before the jmp.
    for d in manifest.get("detours", []):
        blk = stub_bytes(d["mod"])
        rejoin = d.get("rejoin")
        if rejoin == "none":
            print(f"ok   detour 0x{d['addr']:08x} handles it outright in {d['mod']}'s "
                  f"stub, no rejoin declared")
            continue
        want = b"\x4e\xf9" + int(rejoin).to_bytes(4, "big")
        past = d["addr"] + len(bytes.fromhex(d["displaced"]))
        where = "" if rejoin == past else f" (declared, not the default 0x{past:08x})"
        if want in blk:
            # ... and it must not re-emit the instruction it rejoins. The stub ending
            # <stock bytes at rejoin><jmp rejoin> means that instruction runs twice,
            # which no other check sees: the displaced bytes are all present and the
            # jmp lands where it should.
            at = blk.index(want)
            dup = next((n for n in (2, 4, 6)
                        if at >= n and blk[at - n:at] == stock[rejoin - base: rejoin - base + n]),
                       None)
            if dup:
                print(f"FAIL detour 0x{d['addr']:08x} re-emits the {dup} byte(s) at "
                      f"0x{rejoin:08x} and then rejoins there, so stock runs them "
                      f"twice - re-emit only what the detour displaced")
                ok = False
            else:
                print(f"ok   detour 0x{d['addr']:08x} rejoins 0x{rejoin:08x}{where}")
        else:
            print(f"FAIL detour 0x{d['addr']:08x} never jumps to 0x{rejoin:08x}{where} "
                  f"in {d['mod']}'s stub - re-emitting past the displaced bytes runs "
                  f"stock instructions twice")
            ok = False

    # ------------------------------------------------------------------
    # Stack frames. A `movem` that saves N registers at offset X needs the
    # frame to be at least X + 4N bytes; one long short and it writes over the
    # return address the bsr pushed, and the stub faults on its rts.
    #
    # Hardware, 2026-09-20: mod 0006 did exactly this - `lea -96(%sp),%sp`
    # with `movem.l %d2-%d4/%a3,88(%sp)`, four registers ending at 104 - and
    # the unit threw V03 at 0x40289E36, which is that rts. It is invisible to
    # every other check here because the image is perfectly well formed.
    order = "d0 d1 d2 d3 d4 d5 d6 d7 a0 a1 a2 a3 a4 a5 fp sp".split()

    def nregs(spec):
        n = 0
        for part in spec.replace("%", "").split("/"):
            if "-" in part:
                a, b = part.split("-")
                n += order.index(b) - order.index(a) + 1
            else:
                n += 1
        return n

    for mod in sorted({m["mod"] for m in manifest.get("mods", [])}):
        elf = BUILD / "obj" / f"{mod}.elf"
        if not elf.exists():
            continue
        try:
            # No -m: objdump rejects "m68k:5475" with a non-zero exit while still
            # printing the disassembly, and the ELF carries its own arch anyway.
            dis = subprocess.run(["m68k-elf-objdump", "-d", str(elf)],
                                 capture_output=True, text=True).stdout
        except OSError:
            print(f"warn {mod}: could not disassemble for the frame check")
            continue
        frame = None
        for line in dis.splitlines():
            # Each routine starts afresh at its label: a detour stub that saves
            # into the frame stock's own prologue made has no lea of its own and
            # must not be measured against the previous routine's.
            if re.match(r"^[0-9a-f]+ <[^>]+>:$", line):
                frame = None
                continue
            m = re.search(r"lea %sp@\(-(\d+)\),%sp", line)
            if m:
                frame = int(m.group(1))
                continue
            m = re.search(r"moveml %(\S+),%sp@(?:\((\d+)\))?", line)
            if m and frame is not None:
                at = int(m.group(2) or 0)
                end = at + nregs(m.group(1)) * 4
                if end > frame:
                    print(f"FAIL {mod}: movem saves {nregs(m.group(1))} registers at "
                          f"{at} of a {frame}-byte frame, ending at {end} - it "
                          f"overwrites the return address; widen the frame to {end}")
                    ok = False

    print("PASS" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
