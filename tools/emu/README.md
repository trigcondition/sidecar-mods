# Emulator suites

`tools/emu/*_emu.py` are the emulator suites: each boots a build in rytm-emu (`RYTM_EMU`) from a saved post-boot
snapshot (`tools/emu/us_base.sh TAG` makes it once a build) and checks one area. Every suite takes `TAG all` or
`TAG TEST [TEST ...]`.

## How to run them

```
tools/emu/us_base.sh TAG                          # once, right after building TAG
tools/emu/suites.py TAG --changed REV --plan      # what would run, and why (runs nothing)
tools/emu/suites.py TAG --changed REV             # each fix round: only the suites covering what changed since REV
tools/emu/suites.py TAG --full                    # once, before a flash (every suite)
tools/emu/suites.py TAG rled sq                   # named suites
```

- `--changed REV`: the files differing from REV (commits, uncommitted edits, untracked files; `A..B` for a range)
  pick the suites: a mod's files the suites about that mod, a suite script that suite and the suites importing it,
  `mods/0000-shared`, `registry/`, `re/symbols.toml`, the build tools and the bases every suite. Docs and the RE notes
  pick none. The stock-site mods no suite is about (0002..0013, 0020) pick a quick smoke set (frz td fxin rui sv);
  `--full` covers them before a flash. A path not in the map picks every suite (and says so: map it in `suites.py`).
  A new `tools/emu/<x>_emu.py` not yet in `SUITES` runs alone (with a note to register it), not every suite.
  `re/os/` (the OS ports' address maps) picks every suite, on purpose.
  A change in the Sidecar host's checkout (`RYTM_TEENSY`) is outside this repo: `--host-changed REV` (alone, or with
  `--changed`) picks rui, pm, sv and bk when its `sim/protocol.py` or `sim/remote_ui.py` differs from REV.
- Output: one line a suite (verdict, PASS / FAIL counts, seconds, log path), a failing suite's FAIL lines, the wall
  clock. **Read a log only when its suite failed**, and then grep it (`grep -n FAIL build/suites/rled.log`): the logs
  are 1..63 KB of PASS lines.
- `RYTM_TEENSY` must point at a Sidecar host checkout of the build's version (its `sim/protocol.py` and
  `sim/remote_ui.py`; for 0.5.0 builds a 0.5.0 one such as `sidecar/firmware-050t`). The default `../rytm-teensy`
  rarely exists beside a worktree, and an older protocol module makes `rui`, `pm` and their importers stop with a
  traceback (no `HOST_CMD`) instead of failing a check.
- `-j N` (default 6). `rui` is rerun alone when it fails in the parallel phase (real-time host threads; it can flake
  under load); the alone result is its verdict, and both are in `build/suites/summary.txt`.
- `rled` runs as 7 shards (subsets of its tests, `UPKEYS` / `STOCKUP_KEYS` for its two key sweeps), each its own
  process: every check still runs. It falls back to one process when `sections/rled_stock.snap` is missing or a test
  / key was added to `rled_emu.py` and not to `RLED_SHARDS` / `RLED_UPKEYS` in `suites.py` (the plan says so).
  `--no-shard` turns sharding off.
- `us`, `sfu`, `sfx`, `md`, `sq`, `bk` and `pj` also run as 2..4 shards of about 500 s each (`SPLITS` in `suites.py`, the
  tests balanced by their seconds in a full OS 1.74 run; sfu's `pages` + `names` and sq's `pin` + `pinvel` stay together,
  as the second reads what the first made; sfu's and sfx's `stock` sit with the test whose result they read). A
  sharded suite's PASS count is higher than one process's: each shard repeats its setup checks. Its `.times` are
  per shard (`us.1.times`, ...); the merged log is `us.log`. The same rule: a table that no longer matches the script's `TESTS` means one
  process, and the plan says so.
- Measured 2026-11-19 (OS 1.74, `--full -j 4`, same tag both runs): 5050 s before these shards, 3588 s after, the
  same checks and verdicts (rled's two known stockupkeys CLASH fails in both). The longest jobs now are sfx's and
  sfu's shards (~500..970 s); rled's 7 shards take ~640 s together.
- `build/suites/est.json` keeps each passing job's seconds, so `--plan` and the longest-first order use the last run's
  times, not the table's.
- Files: `build/suites/SUITE.log` (full output), `SUITE.times` (each line with its seconds since the start: where the
  time goes), `summary.txt` (as `build/suites/run.sh` writes it), `summary.json`. Each job's scratch dir
  `build/emu_jobs/JOB/` (its `.snap` files deleted at the end unless `--keep-snaps`).

`build/suites/run.sh` (all suites, no selection, no shards) still works.

## What costs time (measured 2026-10-29, rel0-3-0, run.sh -j 5: 6099 s wall)

- `rled`: 6099 s alone, the whole run's tail (every other suite was done after 2061 s). 603 dtboot runs, 723 s of
  emulation; the rest was `stock_state`'s 47 dtpeek processes a state (one a 256-byte item), about 0.2 s each.
  Now one dtpeek a range (5 a state, the same bytes, the same items).
- `us` 1649 s, `sfu` 1193 s, `pj` 904 s (860 s of it emulation), `sfx` 709 s, `bk` 665 s, `sq` 597 s.
- Boots: every dtboot run starts from the post-boot snapshot (9 MB), not a cold boot; only the tests about cold boots
  / power-off do.

## Knob latency under load: `knoblag.py`

Not a suite (it needs the Sidecar's core as the host, and takes minutes): a measurement with a verdict, for changes to
the audio interrupt's hooks, the UI tick or the link traffic, where the suites pass and the unit still lags. It plays
12 tracks of 16ths and turns two knobs (45 detents each, one every 113 ms a knob: `--detents`, `--gap`; a gap that divides 50 ms would lock the detents to
the UI tick and let each image's boot phase move its mean), with and
without scene edit, on stock, a baseline
and a candidate, with the emulator held to a budget of IPS M instructions per emulated second, and prints the mean /
max latency from a detent to the OS's encoder dispatch, the CPU busy share and the key latency.

```
# in build/os/1.74 (after tools/ostarget.py port 1.74), both tags built with tools/build_rui.sh and based with us_base.sh
export RYTM_EMU=...      # rytm-emu, built
export RYTM_TEENSY=...   # sidecar-firmware of the builds' version: make -C core engines && make -C core lib
.venv/bin/python tools/emu/knoblag.py CAND BASE [IPS]
```

- `stock` is your stock OS from `stock/` (the file the build uses), booted as `us_base.sh` boots a build; made once
  (rytm-emu `sections/us_stock.*`). It runs with a bare USB host, the builds with the core on the Overbridge link.
- The 12-track snapshot of each image is made once (`build/knoblag/snaps/`); runs and the JSON go to
  `build/knoblag/runs/`. All of it is firmware-derived and git-ignored: never commit or attach it.
- The verdict (exit 1): a lost detent; CAND's mean > BASE's + 10 ms or > 2x stock's; CAND's max > 2x BASE's + 20 ms.
- The budget: 122 M puts stock close to the edge (a scene-edit mean of ~50 ms on analog-emu's sidecar-upstream
  branch). At the emulator's normal 200 M nothing lags. That branch's panel takes about 30 detents a second at most,
  so a faster turn rate (the performance PRs' first table: 100 detents every 50 ms) loses detents on every image,
  stock included, and measures the panel instead of the Rytm.

## The area and `--count`

Since 0021 lives in elekloader's area (mdpage), a few of `us_emu.py`'s `--count` hooks are area addresses
(0x47BE....), past dtboot's 8 MB hook window, which panics "outside the hook window". dtboot needs `HOOK_WINDOW` =
0x0800_0000 (src/cpu.rs).
