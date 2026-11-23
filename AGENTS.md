# AGENTS.md: sidecar-mods

Guide for AI coding agents (and the humans who run them) working in this repository. It holds the source of the Analog
Rytm MKII OS mods that the Sidecar uses: patch sources in assembly and C, the symbol map, the allocation registry, the
build that turns **your own** stock OS file into a modded one, and the emulator test suites. A wrong byte in a mod can
brick a Rytm, so every change here goes through the same path. Read this file before you change anything.
`CONTRIBUTING.md` has the process for people; this file has the commands, the rules and the traps.

Where this file says "your human", it means the person whose Rytm, Pi and GitHub account you work for.

Items marked **(not verified)** were not run while this file was written. Run them yourself before you rely on them.

## 1. Hard safety rules

These never bend. If a task seems to need one broken, stop and ask your human.

| Rule | Detail |
|---|---|
| **Never flash a Rytm.** | Not for a test, not "just the elemod". You build `.elemod` files; your human flashes them, after the emulator checks below and only if they decide to. Read `docs/HAZARDS.md` first. |
| **Never contact a device.** | No MIDI, USB or network traffic to a Rytm or a Pi from this repo's tools, unless your human has told you to in this session. The emulator is the test bench. |
| **Never push a firmware image to a device without an explicit go.** | A yes covers one action, not the session. |
| **Only `.elemod` files go to testers.** | No `.syx` (firmware image, modded or stock) in a pull request, a release, an issue or a chat attachment. A `.syx` is a local build output, git-ignored. Users apply the `.elemod` files to their own stock OS in elekloader's web flasher (`docs/ELEKLOADER.md`). |
| **No Elektron code or firmware bytes in the repo.** | No `.syx`, sections, disassembly listings, memory dumps or bytes copied out of the OS image. Your own patch sources, addresses and symbol names as documentation are fine. A claim's `expect` bytes are stored **hashed** (section 8). |
| **Clean room.** | Never read leaked or decompiled vendor source, or third-party reverse-engineered code whose licence is incompatible with GPL-2.0-or-later. Sources under MIT-style licences (Mutable Instruments, Airwindows, 4ms SMR and similar) may be read and credited in `NOTICE`. Work from the stock image you own, from public documentation and from your own measurements. If you are unsure of a licence, treat the code as unreadable and ask. |
| **No secrets in URLs, logs or files.** | A Sidecar's pairing code, session tokens and client secrets never go into a URL, a log you paste, a commit or a file in the repo. |
| **No personal data in commits.** | No names, e-mail addresses, home-directory paths, serial numbers or Wi-Fi details in code, docs, commit messages or PR text. Use repo-relative paths and environment variables. |
| **Never `--no-verify`.** | If a hook refuses, fix the cause. |
| **Never `git add -A` or `git add .`.** | Add files by name. Check `git status` and `git diff --cached` before every commit: the build writes `.syx`, `.elemod`, `vendor/` and `stock/*.syx` into the tree, and none of them may be committed. |
| **Never push to `main`, never force-push.** | Pull requests go to `dev`. The maintainer merges. |
| **Kernels only for your own Pi.** | This repo has none, but its suites run against the firmware repo's host side. Kernels you build there are for a Pi your human owns and named. |

## 2. Repo map, and how this repo meets sidecar-firmware

| Path | What |
|---|---|
| `mods/NNNN-slug/` | One mod: `mod.toml` (manifest), `stub.s` (the assembly that is built), `design.md` (what it does and every address it touches). C mods also have a `.c` source and a `build.sh` that generates `stub.s`. |
| `re/` | Reverse-engineering knowledge: `symbols.toml`, `os/*.toml` (the per-OS address maps), subsystem notes, Ghidra bootstrap. |
| `registry/allocations.toml` | Every claim on cave space, detour sites and kit words. |
| `tools/` | `build.py`, `verify.py`, `layout.py`, `ostarget.py`, `hash_expect.py`, `build_rui.sh`, `release_check.py`, `cavescan.py`, and the emulator suites in `tools/emu/`. |
| `stock/` | The checksum of the pinned stock OS. **You supply the `.syx`** (git-ignored). Never write to it from a tool. |
| `a4/` | The Analog Four MKII mod (OS 1.56), with its own README, build and tests. |
| `docs/` | `HAZARDS.md`, `FLASHING.md`, `ELEKLOADER.md`, `MANUAL.md`. |
| `build/`, `vendor/`, `.venv/` | Build output and fetched tools. Git-ignored. |

Mods in the Sidecar build: 0014 hidden machines, 0021 external voices and user slots, 0022 looper and shared
switches, 0023 SD folder in the sample browser, 0025 send FX reporter, 0026 remote UI (the Rytm as a terminal), 0027
elekloader's core, 0029 AMPLITUDE 2 / SEND FX pages, 0030 FX in. The build set is in `Makefile` (`RELEASE_MODS`) and
`tools/build_rui.sh`.

**The two repos meet over SysEx.** The Rytm mods and the Sidecar engine talk on the Rytm's USB MIDI port with
manufacturer ID `0x7D` and header `F0 7D 52 54 <cmd> ... F7`.

| Where | What it defines |
|---|---|
| `sim/protocol.py` in [sidecar-firmware](https://github.com/trigcondition/sidecar-firmware) | Every message, its layout, direction and the caps bit that gates it. The reference. |
| `docs/core.md`, `docs/remote-ui.md` in sidecar-firmware | The engine's side. |
| `mods/*/design.md` here | The Rytm side of each message and the addresses it touches. |

Compatibility rules:

1. **Both directions work with the previous release.** Your mod must run with the previous Sidecar release; the
   Sidecar must run with the previous mod release. The Rytm's hello carries caps bits that say what the Rytm has, and
   the host gates features on them.
2. **Additive only.** New messages use new command bytes, new trailing bytes or new caps bits. Never reuse or reorder
   an existing one. An older receiver ignores what it does not know; check that yours does.
3. **A change on both sides is one issue and two linked pull requests**, one per repo.
4. **Document a protocol addition in the same pull request**: what it carries, who sends it, what an older side does
   with it. Update the mod's `design.md` here and `sim/protocol.py` there.
5. New device addresses go through the OS address map (`re/os/*.toml`, `tools/ostarget.py`), never as raw `0x4...`
   literals in a new `.c` file. New operations on the `0x5A` host-command space must be safe on a box that does not
   know them (a capability mask; a refusal means "not supported"). Version a message when it grows.
6. The Rytm build a Sidecar version needs is named in that version's release notes. Do not assume the newest build.

## 3. Set up

Prerequisites (from `README.md`): Python 3.11 or newer, `git`, `make`, a C compiler, and `m68k-elf-binutils`
(`brew install m68k-elf-binutils` on macOS). **C mods also need `m68k-elf-gcc`** for their `build.sh` (the README does
not list it; the package name for your system is **not verified**).

```sh
make setup      # venv, Python deps, clones and builds the vendored tools at pinned commits (network)
```

Supply the stock OS yourself, from Elektron's support site, and put it where the build expects it:

```
stock/Analog-Rytm_MKII_OS1.74.syx    # the OS the mods build for (from Analog-Rytm_MKII_OS1.74_dist.zip)
```

The build refuses a file whose checksum differs from `stock/SHA256SUMS` and `re/os/<os>.toml`. Never commit it.

**OS 1.74 only, from 0.5.0 on.** The sources are written for OS 1.73 and ported to 1.74 at build time by a committed
address map (`re/os/1.74.toml`, `tools/ostarget.py`). All emulator tests, suites, probes and measurements use OS 1.74
builds and bases. If an old finding was made on 1.73, recheck it on 1.74.

```sh
python3 tools/ostarget.py info --os 1.74 stock   # prints the stock file name the 1.74 build wants
python3 tools/ostarget.py port 1.74              # writes the 1.74 tree to build/os/1.74 (it links .venv, vendor, stock)
make verify OS=1.74                              # build and assert, in the port
```

`ostarget.py port` writes a copy of the tree with every image address translated. **Edit the sources in the repo root,
never in `build/os/1.74`**, and run `port` again after each edit. The port keeps its own `build/` between runs.

Quick checks that need no stock file or emulator (all run from the repo root):

```sh
python3 tools/hash_expect.py --check   # the registry holds no stock bytes as hex
python3 tools/test_build_excludes.py
python3 tools/test_layout.py
python3 tools/test_cavescan.py         # the image tests skip without a build
make comp-selftest                     # needs make setup
```

## 4. The change path

Every change to a mod goes through these steps in order. Skipping one is how builds get bricked.

```
baseline build -> failing emulator test -> fix -> regenerate stub.s -> build -> test passes
   -> named tests (fix rounds) -> selected suites (before the pull request) -> review
```

**Where to run things.** Edit the sources in the repo root. Build and test in the 1.74 port: run
`python3 tools/ostarget.py port 1.74` after every edit, then `cd build/os/1.74` and run Steps 1 to 5 there
(`tools/build_rui.sh`, `us_base.sh`, the `*_emu.py` tests, `suites.py`). Run from the repo root, the same commands build
for OS 1.73, which the emulator tests no longer use.

### Step 0. Branch

```sh
git fetch origin
git worktree add -b fix/<name> ../mods-<name> origin/dev      # or: git checkout -b fix/<name> origin/dev
```

A new worktree lacks the untracked pieces the build needs: link or copy `.venv`, `vendor` and the stock `.syx` from a
working checkout (or run `make setup` and add the stock file again). Never commit them.

### Step 1. Build the baseline

Build the current code under a tag first. The tag names the build in file names and in the emulator's folders.

```sh
tools/build_rui.sh <base-tag>      # builds and verifies the Sidecar set; prints the verdict and the .syx sha256
tools/emu/us_base.sh <base-tag>    # once per build: the post-boot snapshot the suites start from
```

- `tools/build_rui.sh` builds the set of mods the Sidecar ships, then runs `tools/verify.py` on the exact `.syx`.
  `make verify` builds the `mod.toml` default set, which can never coexist with 0026's UART detour, so it is **not**
  the gate for this set.
- **Run `us_base.sh` right after you build that tag.** It copies the objects from `build/obj`, which holds the last
  build's. It refuses when `build/obj` is another tag's ("build <tag> again first").
- All of this runs inside `build/os/1.74` (see "Where to run things" above) (`docs/ELEKLOADER.md`: "for 1.74 the same in `build/os/1.74`").
  **(Not verified: the last line of `build_rui.sh` names the OS 1.73 file for its `shasum`. The build and verify steps
  before it are what count; read its output.)**

### Step 2. A failing emulator test first

Write the test that shows the bug or the new behaviour, in the suite that owns the area, and run it on the baseline.
It **must fail, for the reason you expect**. A test that passes on the baseline proves nothing.

```sh
.venv/bin/python tools/emu/<suite>_emu.py <base-tag> <new-test>
```

Suites and what they own (see `tools/emu/README.md` for the full list and the `suites.py` map): `rled` keys and LEDs,
`sv` the SRC view, `sfu` the send FX pages, `sfx` the send FX reporter, `rui` the remote UI, `us` user slots, `bk`
banks, `pm` 0026's parameter modulation, `sq` 0026's sequencer link, `md`, `pj` projects, `fxin`, `lag`, `upg`
(upgrade from an older build), and others. The test names of a suite are the keys of its `TESTS` dict
(`grep -n "^TESTS" tools/emu/<suite>_emu.py`).

### Step 3. The fix

- **After any C edit in a mod, run that mod's `build.sh`.** `mods/0026-remote-ui/build.sh` regenerates `stub.s` from
  `rui.c`; the other C mods (0020, 0021, 0022, 0023, 0025, 0029, 0030) have their own. **Without it the build silently
  uses the old `stub.s`**: the first build after the edit is byte-identical to the baseline and nothing says so. Commit
  `stub.s` with the `.c`. If your build matches the baseline's hash, you forgot this.
- **Append new struct fields at the end.** Tests peek at fixed offsets (such as `sv+88`). A field inserted in the
  middle breaks unrelated tests and old saved state.
- **Know the OS function's arguments before you call it.** Read existing callers of a symbol before you trust its name
  in `re/symbols.toml`. A name is a hypothesis; the status says how well it is established.
- **Watch code space.** Some mods have little room left (0021 and 0025 especially); the build reports what is left.
  A change that leaves less than the agreed reserve needs a "go" first (`CONTRIBUTING.md`, "Rytm mods: shared resources").
- **Write down every address and what it means** in the mod's `design.md`, a section per change.
- New addresses go to `re/symbols.toml` with an honest `status`; claims go to `registry/allocations.toml` (section 8).

Build the fix under a **new tag**, then run the test:

```sh
mods/0026-remote-ui/build.sh                          # if rui.c changed (or the mod's own build.sh)
tools/build_rui.sh <fix-tag>                          # verify must PASS on the exact .syx
tools/emu/us_base.sh <fix-tag>
.venv/bin/python tools/emu/<suite>_emu.py <fix-tag> <new-test>      # now PASS
```

**Bump the tag for every build** (`held0`, `held1`, `held2`, ...), so builds never get mixed up. Say the tag in your PR.

### Step 4. Fix rounds: only the tests for what changed

A fix round runs the new test and the **named tests that cover the changed code**, nothing more. A whole suite can take
more than an hour; the full set takes longer.

```sh
.venv/bin/python tools/emu/rled_emu.py <fix-tag> stockupkeys     # example: one named test
```

**Exception: risky Rytm code.** The audio-interrupt hook, the Rytm parameter mod, and anything that writes patterns or
kits. Every fix round of such a change also runs the suites the picker selects:

```sh
tools/emu/suites.py <fix-tag> --changed <base> [-j 2]
```

### Step 5. Before the pull request

Once the feature is done, run the plan, read it, then run it **once**:

```sh
tools/emu/suites.py <tag> --changed <base> --plan     # what runs, why, and the estimate (runs nothing)
tools/emu/suites.py <tag> --changed <base> -j 2       # the run
```

`<base>` is the git revision your branch started from (for example `origin/dev`). `--changed` picks the suites by the
files that differ: a mod's files pick the suites about that mod; `mods/0000-shared`, `registry/`, `re/symbols.toml`,
the build tools and the bases pick every suite; docs pick none. If you add `tools/emu/<x>_emu.py`, register it in
`SUITES` in `tools/emu/suites.py`. If your change is on the host side (`sim/protocol.py`, `sim/remote_ui.py` in
sidecar-firmware), add `--host-changed <rev>`.

Output is one line per suite. **Read a log only when its suite failed, and grep it** (`grep -n FAIL
build/suites/<suite>.log`): the logs are mostly PASS lines. The run writes `build/suites/summary.txt`.

### Step 6. What only the maintainer does

Not part of a contributor's pull request:

- `tools/emu/suites.py <tag> --full` (every suite) and the flash rehearsals both ways (stock to new, new to stock,
  previous release to new, per OS) are for **release candidates**.
- The 1.74 crosscheck (`tools/ostarget.py crosscheck`), `make release OS=1.74` and `make release-check OS=1.74`.
- The decision to flash, and the flash.

If your change is risky, say so in the PR and say which of these you think it needs. Do not run `--full` as a habit.

## 5. The emulator

The suites run the Rytm's OS in [analog-emu](https://github.com/trigcondition/analog-emu), a public emulator
(`rytm-emu` in the scripts' names), booted from your stock OS with your mod applied. It has its own `AGENTS.md` and a
step-by-step `docs/INSTALL.md`. It never touches hardware.

```sh
git clone https://github.com/trigcondition/analog-emu ../rytm-emu
cd ../rytm-emu && cargo build --release          # tools: rytm, dtboot, dtpeek, dtcard, ...
```

| Variable | Points at |
|---|---|
| `RYTM_EMU` | The emulator checkout. Default `../rytm-emu` beside this repo. |
| `RYTM_TEENSY` | A checkout of [sidecar-firmware](https://github.com/trigcondition/sidecar-firmware) **of the version your build belongs to** (its `sim/protocol.py` and `sim/remote_ui.py` are imported). The default `../rytm-teensy` does not exist in a public layout: always set it. An older protocol module makes `rui`, `pm` and the suites that import them stop with a traceback instead of failing a check. |
| `RYTM_OUT_ROOT` | Set by `suites.py` per job. Do not set it yourself. |

```sh
export RYTM_EMU=$PWD/../rytm-emu
export RYTM_TEENSY=$PWD/../firmware        # your sidecar-firmware checkout, at the matching version
```

- **`DTEMU_STRICT=1`** makes the emulator fault on unmapped pages and SRAM mirrors instead of ignoring them. The suites
  set it themselves. Set it too when you run `dtboot` by hand, and treat a fault as a bug in your mod.
- `us_base.sh` needs a base card `sections/led.img` in the emulator checkout and starts from a copy of it. A blank card
  can be made with `./target/release/dtcard NAME.img format`. **(Not verified: how `sections/led.img` is made for a
  clean checkout. The emulator's `tools/looper_base.sh` documents the same base. Ask the maintainer if `us_base.sh`
  stops at a missing card.)**
- Emulator output is firmware-derived: snapshots, card images, screens. They live in `build/emu/<tag>/`, in the
  emulator's `fw/` and `sections/`, and are all git-ignored. Never commit or attach them.
- `tools/ostarget.py` is the only place addresses are ported. In a new test, take addresses from the OS map or the
  build's objects, not from a hand-typed literal.

**Load.** Each emulator process is CPU-heavy. The default `-j 6` assumes a 10-core machine; pick `-j` for yours, and avoid
several suites runs at once.
`rui` runs real-time host threads and can flake under load; `suites.py` reruns a failed `rui` alone and the alone
result is its verdict.

**Reference builds.** Some suites compare against an older build and **stop with a traceback** (not a failed check)
when it is missing. They read `build/emu/<TAG>/` and a base made by `us_base.sh <TAG>`:

| Reference | Used by |
|---|---|
| `rel0-3-0` | `md` (an old release's behaviour) |
| `rel0-3-1` | `upg`, `ar` (upgrade from that release) |
| `rui1043` | `bk` (old kits read as bank A; `OLD_TAG` overrides) |
| `rui1048base` | `rled` (the stock-menu comparison; `MENU_PREV` overrides) |

Build them from the matching older sources (the tags `v0.3.0` and `v0.3.1` exist here; the other two were never tagged
and may not be rebuildable from public history **(not verified)**), then run `us_base.sh` for each. If you cannot
build one, say which suites you could not run and why. Do not report such a traceback as a failure of your change, and
do not delete the test.

**Disk.** A base card is about 900 MB (`us_base.sh` clones it where the filesystem allows), a snapshot is about 9 MB,
and a suites run keeps per-job scratch folders. Check free space first.

## 6. Build outputs and releases

```sh
make release OS=1.74         # build/release/<version>-os1.74/: the two .elemod files, LICENSE, NOTICE, TOOLCHAIN.txt, SHA256SUMS
make release-check OS=1.74   # the published files through elekloader's own code path
```

Both are the maintainer's. A contributor builds with `tools/build_rui.sh <tag>`, which makes a local `.syx` for the
emulator. That `.syx` stays on your machine. The release target builds the `.elemod` with
`tools/build.py --tag <tag> --elek-bundle --mods ...`; whether `build_rui.sh <tag> --elek-bundle` gives you one for a
tester **(not verified)**. If a tester needs your build, offer the `.elemod` only, and say the tag and its sha256.

**Hardware tests, by your human, not you.** Flashing carries risk (`docs/HAZARDS.md`, `docs/FLASHING.md`). A report
from hardware says the OS version, the build tag, the Pi model and the Sidecar version. A problem seen on hardware is
**reproduced in the emulator first, as a failing test**, then fixed from step 3.

## 7. Hazards in short

Read `docs/HAZARDS.md` in full. The rules that change how you work:

- **The bootstrap (section 2 of the image) is never touched.** It is the only recovery net. `tools/verify.py` asserts
  its hash and that sections 5, 2, 1 and 8 come back byte-identical to stock. Keep those checks.
- **Every byte that differs from stock lies inside a registry claim.** `verify.py` fails otherwise.
- **`built` means it assembled.** Only `hardware-verified` counts, and only for the image that was flashed.
- **Projects saved under the mods carry machines that stock does not list.** Mod work belongs in scratch projects; put
  stock machines back on those tracks before going back to stock.
- **A cave is a candidate until measured.** Free-looking space can be `.bss` that the engine writes. Use claims in
  `registry/allocations.toml`; never grab space on a guess.
- **The assembler target is ColdFire V4e** (`-mcpu=5475`). Too narrow a target fails loudly at assembly; too wide a
  one fails silently on hardware. Widen it only with a byte-identical rebuild check.
- **Verify before every flash, on the exact `.syx`.** A verify that passed on another build proves nothing.

## 8. Registry, symbols and "no firmware in the repo"

1. Add new addresses to `re/symbols.toml` with an honest `status` (`verified`, `inferred` or `external`; the file's
   header defines them). Say how you know. A mod's own status ladder is `re-only`, `built`, `hardware-verified`,
   `retracted` (`README.md`); only `hardware-verified` counts.
2. Claim cave space, detour sites and kit words in `registry/allocations.toml`. A mod may hold several cave claims, each
   naming its `section`. Record the stock bytes at each detour host in `expect` **while you work**.
3. Write `mods/NNNN-slug/{mod.toml,stub.s,design.md}`. Kit words that mods use are listed in the registry; nothing is
   written into a kit or pattern that the registry does not claim.
4. **Before you commit:** `python3 tools/hash_expect.py --image build/stock_mainos.bin`. It turns every `expect` into
   `expect_len` + `expect_sha256`, so no stock bytes reach the repo. Then `python3 tools/hash_expect.py --check` must
   say PASS.
5. Run `tools/layout.py` through `make layout` (also run by the build) after a registry change.
6. Do not write disassembly listings, decompiler output or byte dumps into `design.md` or `re/`. Describe behaviour,
   give addresses and names, and say how you measured.

The `expect` hash is the load-bearing guard: if an address is wrong or two mods collide, the build aborts instead of
patching the wrong place.

## 9. Working rules

- **Issue first, and claim it.** For anything bigger than a small fix, find or open an issue, say you want it, and wait
  for the `claimed` label and your name on it. The pinned roadmap issue shows what is planned and who is on it.
- **One topic per pull request**, linked with `Closes #n`. If it depends on another open pull request, say the order.
- **Pull requests go to `dev`.** Branch from `origin/dev`. `main` holds releases. The maintainer merges.
- **Two-sided changes:** two linked pull requests, one per repo, each compatible with the other side's previous release.
- **Release scope is the maintainer's.** Close to a release, only fixes for it may be taken; a new feature can wait for
  the next one. The roadmap issue shows what is planned; ask if unsure.
- **Review before merge.** The `test` check must pass and a code owner approves. Do not merge your own pull request.
- **Evidence over claims.** The PR says what was run and on what: the commands, the OS (1.74), the build tag, the
  `.syx`/`.elemod` sha256, the Pi model and Sidecar version for hardware reports. If you could not test it, say so.
- **Shared Rytm resources** (RAM, key handlers and their order, parameter records, kit words) are in `CONTRIBUTING.md`,
  "Rytm mods: shared resources". Read it and follow it. This file does not repeat it.
- **Every change has an emulator test that fails without it** (`tools/emu/*_emu.py`, OS 1.74, `DTEMU_STRICT=1`).
- **Docs move with the code.** `design.md`, `docs/` and the registry change in the same pull request as the mod.
- **Commits.** Plain messages, one logical change each. Never rewrite published history.

## 10. Lessons

Each of these cost someone a day or a flash.

| Lesson | What to do |
|---|---|
| **Stale `stub.s`.** After a C edit without `build.sh` the build uses the old code. The first build came out byte-identical to the baseline. | Run the mod's `build.sh` after every C edit. Compare the build's sha256 with the baseline's: equal means nothing changed. |
| **New struct fields go at the end.** Tests and saved state read fixed offsets. | Append. Never insert or reorder. |
| **A name in `re/symbols.toml` is a claim, not a fact.** | Read existing callers of the function before you trust the name. Check the argument meanings in the callers. |
| **`page_get_value`'s third argument is a sound index, not a step.** A held step's lock comes from the view's parameter set (vtable +160) and its lock-get (vtable +0x3c), as 0029's `sfu_get` does. | Copy the pattern of a working caller, then test with a locked step. |
| **A Pi that boots after the Rytm misses the Rytm's hello** (sent about 0.5 s after its USB port comes up). Caps-gated features stay off until the Rytm re-enumerates. | Test both start orders. Treat a missing feature as "caps not seen" first. |
| **Reference builds.** Some suites need older builds and traceback without them. | Section 5. Name the suites you could not run. |
| **zsh does not word-split unquoted variables; bash does.** A command like `build.py --mods $MODS` pasted into a zsh shell passes one long argument and fails oddly. | Use the scripts (`tools/build_rui.sh` is bash), use arrays, or run with `bash`. |
| **`rui` flakes under load.** | Rerun it alone. Its rerun result counts. `suites.py` does this for you. |
| **Known pre-existing failures.** `rled`'s `stockupkeys` gridtrig UP+RECORD and UP+PLAY CLASH fail the same way on older builds. The 1.74 map and a few suites also fail where the feature they test is absent. | Run the failing test on the baseline tag before you call a failure new. Put both results in the PR. |
| **Do not borrow parameter records.** There are no free records on OS 1.74. A mod that borrows records must restore them on every exit (page leave, kit change, project load, the Sidecar dropping out). | State the restore paths in `design.md` and test each. |
| **Key handler order matters.** Handlers run in a fixed order (0026 is at 10). | List every combo your change could collide with in `design.md` (see `CONTRIBUTING.md`). |
| **Code space is nearly gone in some mods** (0021, 0025). | Check the build's report. Move code to the elekloader area if the mod supports it; ask first. |
| **`--count` hooks in `us_emu.py` past the hook window** panic "outside the hook window" in `dtboot`. | The area needs `HOOK_WINDOW` = `0x0800_0000` in the emulator's `src/cpu.rs`. |
| **Disk space.** Emulator snapshots, base cards and builds are large and accumulate under `build/`, `build/emu_jobs/` and the emulator's `sections/`. | Check `df -h .` before a run. Delete only output you can rebuild; ask your human first for anything else. |
| **Parallel emulator runs slow each other down** and cause flakes. | Match `-j` to your cores; avoid parallel suites runs. |

## 11. Reporting

When you finish, write the pull request description as:

1. What changed and why (link the issue). For a mod: which mod, which addresses, the code and RAM cost, and what is
   left with the full set.
2. What you ran: the exact commands, the build tags (baseline and fix), the OS (1.74), the suites and tests that
   passed, and the baseline result of any failure.
3. What you did not run, and why (a missing reference build, no hardware).
4. Protocol, registry or default changes, and the linked pull request in the other repo.

Do not paste snapshots, screens from the emulator that show Elektron's UI in full, hex dumps of the OS, or logs with
paths and names in them.
