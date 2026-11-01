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
  A change in the Sidecar host's checkout (`RYTM_TEENSY`, the protocol module) is outside this repo: name the suites.
- Output: one line a suite (verdict, PASS / FAIL counts, seconds, log path), a failing suite's FAIL lines, the wall
  clock. **Read a log only when its suite failed**, and then grep it (`grep -n FAIL build/suites/rled.log`): the logs
  are 1..63 KB of PASS lines.
- `-j N` (default 6). `rui` is rerun alone when it fails in the parallel phase (real-time host threads; it can flake
  under load); the alone result is its verdict, and both are in `build/suites/summary.txt`.
- `rled` runs as 7 shards (subsets of its tests, `UPKEYS` / `STOCKUP_KEYS` for its two key sweeps), each its own
  process: every check still runs. It falls back to one process when `sections/rled_stock.snap` is missing or a test
  / key was added to `rled_emu.py` and not to `RLED_SHARDS` / `RLED_UPKEYS` in `suites.py` (the plan says so).
  `--no-shard` turns sharding off.
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

## The area and `--count`

Since 0021 lives in elekloader's area (mdpage), a few of `us_emu.py`'s `--count` hooks are area addresses
(0x47BE....), past dtboot's 8 MB hook window, which panics "outside the hook window". dtboot needs `HOOK_WINDOW` =
0x0800_0000 (src/cpu.rs).
