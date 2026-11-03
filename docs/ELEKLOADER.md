# Installing the Sidecar mods from the elekloader web page

The Sidecar's mods for the Analog Rytm MKII come as an [elekloader](https://github.com/irpina/elekloader) module. You
build your own firmware file from it in the web page at <https://irpina.github.io/elekloader/>, on your own computer,
from the stock OS file you download from Elektron. Then you flash that file like any OS update.

There are two builds of the same mods, one for **OS 1.74** (the OS Elektron offers now) and one for **OS 1.73**. Use
the one for the OS your stock file is: elekloader refuses a module made for another OS. If you have no OS 1.73 file,
use 1.74: Elektron's support page offers only 1.74 since 2026-10-01. Read the whole page once before you start, the
recovery section included.

## What you need

**OS 1.74:**

| file | what | sha256 (development snapshot of 0.4.0, not a release) |
|---|---|---|
| `Analog-Rytm_MKII_OS1.74.syx` | the stock OS 1.74, in Elektron's `Analog-Rytm_MKII_OS1.74_dist.zip` | `cb0f99d620edde994fb860c0e79cc2464e427d06882828cfdfb00fc53700e123` |
| `core-0.1-os1.74.elemod` | elekloader's core-ar2 0.1 for OS 1.74: the boot copier and hook bus every elekloader mod builds on | `89c00065e8f83ce839978c45a32200e09879682b8b95cbff0bdb71ca09dc3c8a` |
| `rytm-sidecar-0.4.0-os1.74.elemod` | the Sidecar mods, all in one module, for OS 1.74 | `794448662bb11fd2b9ece677640a431e2a6d9e169952aa3378cd0e3d9834e545` |

**OS 1.73:**

| file | what | sha256 (development snapshot of 0.4.0, not a release) |
|---|---|---|
| `Analog-Rytm_MKII_OS1.73.syx` | the stock OS 1.73 (Elektron no longer offers it; use the file you have) | `8ad671087ec30433d5407c7380d2396e0915ab931c5d3dd18a78bf284d3d1e52` |
| `core-0.1.elemod` | elekloader's core-ar2 0.1: the boot copier and hook bus every elekloader mod builds on | `33de51c098ab0ecd9cc57e9dfc3efa3d95f8133b1f4a4e6abd80d5fdba2dd825` |
| `rytm-sidecar-0.4.0.elemod` | the Sidecar mods, all in one module | `d003a738374ae3cb643c5d6c4cd4622dd1f7931398dcdfaf016b82576c956c44` |

Each OS's two `.elemod` files are published together, with `SHA256SUMS`, `LICENSE`, `NOTICE`, `TOOLCHAIN.txt` and the
source of elekloader's parts (1.73: `elekloader-8972d70-core-ar2-src.tar.gz`; 1.74:
`elekloader-13fa795-core-ar2-src.tar.gz`; both: `elekloader-c150ac5-src.tar.gz`). Check both hashes before you use
them. Both builds come from the same source and do the same; the 1.74 one differs only by the firmware addresses
that moved between the two OSes.

The bundle does not contain 0031-remote-keys (REMOTE KEYS, analoghealth's remote keys and diagnostics): it is a
development and test feature only, left out of production builds since 2026-10-29, and its sources are not part
of this public repository. The bundle does contain 0026's freeze probe: if the
Rytm's UI task ever stops for over 2 s, the Sidecar's log shows `rui: FREEZE PROBE` with where it stopped.

You also need, for flashing, Elektron Transfer (USB), or C6 / Transfer's legacy mode and a DIN MIDI interface (for the
recovery route).

The Sidecar module holds, built for one set: 0021 (the external machines), 0022 (the SysEx router), 0023 (the TEENSY
drive), 0025 and 0029 (the send FX), 0026 (the remote UI) and 0030 (FX in). They come as one file because they only work together: their parameters are fixed at build time,
and they call each other at fixed addresses.

## Before the first time: back up, and prove recovery

1. Back up every project, sound and sample with Transfer.
2. Make sure the recovery route works on your unit: one full DIN reflash of your stock OS file through the STARTUP
   menu (below). `docs/FLASHING.md` stage S0 says why: the USB route needs a firmware that boots.
3. Use a scratch project for the first session under the mods. Projects saved while a track plays a Sidecar
   machine show that track as DISABLE on stock (`docs/FLASHING.md`, "Projects saved under the mods, on stock").

## Build the firmware in the web page

1. Open <https://irpina.github.io/elekloader/>.
2. Choose your stock firmware: `Analog-Rytm_MKII_OS1.74.syx` (or `Analog-Rytm_MKII_OS1.73.syx`). The page knows it
   by its hash.
3. Add your own mods: that OS's core and module (1.74: `core-0.1-os1.74.elemod` and
   `rytm-sidecar-0.4.0-os1.74.elemod`; 1.73: `core-0.1.elemod` and `rytm-sidecar-0.4.0.elemod`). Use our core
   file, not one the page lists: the page's Rytm cores are newer ones (0.3 and up, for 1.74), which keep mod storage
   where the Sidecar keeps its settings, and are refused (below); for 1.73 it lists none.
4. Tick `rytm-sidecar`. Ticking it ticks the core it requires. The check should say there are no conflicts.
5. **Set the version to your OS: `1.74` (or `1.73`).** The page's default for the Rytm is `2.0a`. **Never flash a
   build whose version is not your stock file's.** A 2.0a build has the same MAIN OS, but the unit then reports OS
   2.0a, and going back to stock from there is untested: the OS carries "Downgrade not possible" and the bootstrap a
   VERSION CHECK (`docs/FLASHING.md`, "Downgrades"), so either route, USB or the STARTUP menu, may refuse it.
6. Build, and download the `.syx`. Its sha256, as built from this branch:
   - version 1.74: `538ae6fa1a66dfb72141743036c40b4f3845ed73a4ea59f7e3b6aa9e51fab337`;
   - version 1.73: `07780e9eb4bce7f71c83da3134ede4782f7ea7af211eb6787c670607707bff18`.

   If yours differs, do not flash it: see the next section.

### If your file's sha256 differs

The page builds with whatever elekloader commit it runs today. Our hash was made and checked with elekloader at
`c150ac5`; on 2026-10-27 the live page ran `b893c93`, which gives the same file (measured). A later packer or linker
can give another file. To see the page's commit: the page's footer names it, and
<https://irpina.github.io/elekloader/build.json> says it (`"commit"`). If the page has moved and your hash differs,
build with the command line at the pinned commit instead:

    git clone https://github.com/irpina/elekloader && cd elekloader
    git checkout c150ac583a4b7e6d64680d5592f4a40f409193f7
    python3 -m elekloader.patch --stock Analog-Rytm_MKII_OS1.74.syx --mod core-0.1-os1.74.elemod \
        --mod rytm-sidecar-0.4.0-os1.74.elemod --out sidecar.syx --version 1.74

(for 1.73: `--stock Analog-Rytm_MKII_OS1.73.syx --mod core-0.1.elemod --mod rytm-sidecar-0.4.0.elemod --version
1.73`) and check that `sidecar.syx` has the sha256 above.

Never share the `.syx` you built: it contains Elektron's firmware. Share the `.elemod` files instead.

## Flash it

**Normal route, Elektron Transfer over USB:** connect and power on; Transfer > CONNECTION, MIDI IN and OUT set to the
Rytm; drag the `.syx` onto Transfer's DROP area; press `[YES]` on the Rytm. It restarts by itself. This route runs
inside the firmware, so it needs a firmware that boots.

**Or C6** (or Transfer's legacy mode) over DIN MIDI, through the STARTUP menu's OS UPGRADE: the steps of the
recovery route below, with your built `.syx` in place of the stock one. Slower (16 minutes or more), but it works
whatever firmware the unit has.

After an OS upgrade the Rytm may also upgrade its bootstrap on the first restart. Do not turn the power off then.

## Recovery

If the Rytm does not boot after flashing, the STARTUP menu still works: our builds and elekloader never change the
bootstrap (section 2), and the release check (below) checks that byte for byte.

1. Hold `[FUNC]` while you power on. The STARTUP menu comes up.
2. Press `[TRIG 4]`: OS UPGRADE.
3. Send the **stock** OS file (`Analog-Rytm_MKII_OS1.74.syx`, or the 1.73 one) over **DIN MIDI** (Transfer > CONNECTION, "LEGACY OS UPGRADE
   mode", or C6). USB does not work in this menu. It takes about 16 minutes or more.

The web page shows the same steps before every download.

### From 1.73 to 1.74

A unit on 1.73 (stock or with the Sidecar's 1.73 build) can take the 1.74 build directly: the file is a whole OS, and
projects carry over (1.74 changed no project format: its additions are the Outbox's main-output routing). Treat it as
**one-way**: going back from 1.74 to 1.73 has passed in the emulator, but has not been tried on a unit, and the OS
carries "Downgrade not possible". Once on 1.74, recover with stock 1.74, and back up first.

## What you cannot do yet

- **Mix it with other people's mods.** On 1.73 no one else publishes Rytm mods. On 1.74 the other Rytm mods
  (Iced-Cream's rytm2_mods) need core-ar2 0.3 or newer, which this module refuses (next point), and they patch some of
  the same firmware places. elekloader refuses a set that overlaps, so expect it to be refused.
- **Use core-ar2 0.2 or newer.** Use our core 0.1 file only (`core-0.1.elemod`, or `core-0.1-os1.74.elemod`). Core
  0.2 and newer (0.2 is the last for 1.73; it is not released, but can be built from upstream's source; 0.3 to 0.6 are
  the web page's cores for 1.74) keep their "mod storage" in a sound's and a kit's spare bytes,
  the same bytes the Sidecar mods already keep their own settings in (0013/0021: the sound's spare bytes; 0025: kit
  FX words 38..41). Both would overwrite each other's settings, silently. The module says so in a way elekloader
  enforces: it claims the first two bytes of each of core 0.2's storage hooks (without changing them), so elekloader
  refuses the build with *"rytm-sidecar 0.4.0 site ... and core 0.2 site ... overlap"*. The format has no way to say
  "core 0.1 only" directly (`resources.core` is a minimum). If you see that message, you ticked a newer core: untick
  it and tick `core-0.1.elemod`. The guard has limits: it catches core 0.2's own storage hooks, at those addresses,
  under today's elekloader, whose overlap check counts any shared byte (on 1.74 the cores 0.2 to 0.6 hook the same
  storage sites, and are refused alike). A future core that hooked storage elsewhere, or an elekloader that let
  byte-identical sites coexist, would not be refused. So the rule stands on its own: core 0.1, by its sha256 above,
  and nothing newer.
- **Pick single Sidecar mods.** The module is all or nothing (above).
- **Use one OS's module with the other OS's stock file.** Each module names its OS; elekloader refuses the pair.

## Status

This snapshot's release files above have not been run on a unit. The 1.74 build has run only in the emulator (its
suites, as the 1.73 build's, and flash rehearsals from stock 1.74, from the 1.73 build and back to stock 1.74); no
unit has run any Sidecar build on 1.74 yet. On 1.73, a test build from the same source has passed the emulator suites
and a flash rehearsal and has run on a unit. The emulator enters MAIN OS directly with its own depacker, so it does not run the Rytm bootstrap's depacker on this
file. Two things are new against the rui1051 image the Sidecar's own unit runs: the MAIN OS lacks 0028-elek-hello
(a test counter), and the packed stream comes from elekloader's new packer. The new stream uses only what Elektron's own stock 1.73 stream
already uses (reuse of the last offset, also right after a match; offsets up to just under 1 MiB; counts up to 2048),
within its maxima, and every Rytm depacks the stock stream at every boot; so the first hardware boot is expected to
work, and the bootstrap (untouched) is the way back if it does not. First hardware boot: not yet.

## Source and licence

The mods are GPL-2.0-or-later (`LICENSE`, `NOTICE`). The source of this development snapshot is the branch `dev` of
<https://github.com/trigcondition/sidecar-mods> (no release, no tag): `make setup` then
`make release` builds the 1.73 `.elemod` files from it and `make release OS=1.74` the 1.74 ones, byte for byte with the toolchain in `TOOLCHAIN.txt` (GNU
binutils 2.47 `m68k-elf-as`, Python 3.14; another assembler version may give other bytes). `NOTICE` names the exact
elekloader commits: the core is core-ar2 0.1 built unchanged from elekloader's `mods/core-ar2` at `8972d70` (for 1.74:
its upstream port at `13fa795`), with elekloader's builder at `c150ac5`; the source of both is in the release folder
beside the files.

## For maintainers: the release

    make release          # build/release/<VERSION>/: the two elemods, elekloader's source archives, TOOLCHAIN.txt, LICENSE, NOTICE, SHA256SUMS
    make release-check    # those files only, through upstream's code
    make release OS=1.74  # the same for OS 1.74: build/release/<VERSION>-os1.74/ (the port's tree: build/os/1.74)
    make release-check OS=1.74
    make release-all      # both, each checked

- One source tree, two OSes: the sources hold OS 1.73's addresses; `re/os/1.74.toml` maps them to 1.74's
  (segments with their shifts, the regions 1.74 really changed, which refuse any address, and 1.74's stock-byte
  hashes for every claim), and `tools/ostarget.py port 1.74` writes the translated tree that `make OS=1.74` builds.
  Maintainers with both stock files: `tools/ostarget.py derive` remakes the map, `check` compares every address the
  tree uses in both images, and `crosscheck` compares one release built for both OSes (only translated addresses may
  differ). A new mod's addresses need nothing extra, unless they fall in a changed region: the port then refuses.

- The version is set in one place, `VERSION`. The set and its params are `RELEASE_MODS` / `RELEASE_ARGS` in the
  Makefile (the rui1051 set without 0028-elek-hello, a test counter). `tools/build.py --elek-bundle` writes one elemod for every enabled mod; without it,
  one per mod (`rytm-<id>-<tag>.elemod`), each with `requires` for the mods it needs.
- `make release` runs `tools/verify.py` on the build, as every build.
- `make release-check` (`tools/release_check.py`) takes only the published files and the stock `.syx`:
  - `elekloader.lint`, `patch --check` and `patch --out`;
  - the web page's own module (`web/bridge.py`, run in CPython in place of the page's Pyodide): add both files,
    tick, check, build with version 1.73 and with the page's default;
  - each image's MAIN OS must be the release build's byte for byte, sections 1/2/5/8 stock, the bootstrap at its
    pinned sha256;
  - the CLI's and the web page's 1.73 builds must be build.py's `.syx` (the one the suites run), the core its pinned
    sha256, and this guide's three hashes the release's;
  - the module must be refused without a core, and with core-ar2 0.2 (built from upstream's `92a99c9`; on 1.74
    also 0.6, the pinned elekloader's own) at one of the guard's addresses.
- Then boot the image in rytm-emu and run the suites: `tools/emu/us_base.sh <tag>`, then
  `build/suites/run.sh -j 4 <tag>` (with `RYTM_EMU` and `RYTM_TEENSY` set); for 1.74 the same in `build/os/1.74`.
  The image the web page builds with the OS's version is the same file as
  `build/Analog-Rytm_MKII_OS<os>_<tag>.syx`, so the suites run on exactly what a user flashes.
- Merging new mods (rui1052 and later): add them to `RELEASE_MODS` / `RELEASE_ARGS`. build.py refuses a bundle that
  lacks a mod one of its members needs, from the addresses in their bytes and their `[requires] mods`.
