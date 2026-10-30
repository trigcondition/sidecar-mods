# Installing the Sidecar mods from the elekloader web page

The Sidecar's mods for the Analog Rytm MKII come as an [elekloader](https://github.com/irpina/elekloader) module. You
build your own firmware file from it in the web page at <https://irpina.github.io/elekloader/>, on your own computer,
from the stock OS file you download from Elektron. Then you flash that file like any OS update.

This is for **OS 1.73 only**. Read the whole page once before you start, the recovery section included.

## What you need

| file | what | sha256 (release 0.3.0) |
|---|---|---|
| `Analog-Rytm_MKII_OS1.73.syx` | the stock OS 1.73, from Elektron's support site | `8ad671087ec30433d5407c7380d2396e0915ab931c5d3dd18a78bf284d3d1e52` |
| `core-0.1.elemod` | elekloader's core-ar2 0.1: the boot copier and hook bus every elekloader mod builds on | `33de51c098ab0ecd9cc57e9dfc3efa3d95f8133b1f4a4e6abd80d5fdba2dd825` |
| `rytm-sidecar-0.3.0.elemod` | the Sidecar mods, all in one module | `e93a0b2794a8316dad1d6cfe52151820e153d6f86427d12343a5f947cae0c28a` |

The two `.elemod` files are published together in the release, with `SHA256SUMS`, `LICENSE`, `NOTICE`,
`TOOLCHAIN.txt` and the source of elekloader's parts (`elekloader-8972d70-core-ar2-src.tar.gz`,
`elekloader-c150ac5-src.tar.gz`). Check both hashes before you use them.

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
2. Make sure the recovery route works on your unit: one full DIN reflash of stock 1.73 through the STARTUP menu
   (below). `docs/FLASHING.md` stage S0 says why: the USB route needs a firmware that boots.
3. Use a scratch project for the first session under the mods. Projects saved while a track plays a Sidecar
   machine show that track as DISABLE on stock (`docs/FLASHING.md`, "Projects saved under the mods, on stock").

## Build the firmware in the web page

1. Open <https://irpina.github.io/elekloader/>.
2. Choose your stock firmware: `Analog-Rytm_MKII_OS1.73.syx`. The page knows it by its hash.
3. Add your own mods: `core-0.1.elemod` and `rytm-sidecar-0.3.0.elemod`. The page lists no Rytm core for OS 1.73
   (its cores for the Rytm are for 1.74), so the core file is one you add, like the module.
4. Tick `rytm-sidecar`. Ticking it ticks the core it requires. The check should say there are no conflicts.
5. **Set the version to `1.73`.** The page's default for the Rytm is `2.0a`. **Never flash a build whose version is
   not 1.73.** A 2.0a build has the same MAIN OS, but the unit then reports OS 2.0a, and going back to stock 1.73
   from there is untested: the OS carries "Downgrade not possible" and the bootstrap a VERSION CHECK
   (`docs/FLASHING.md`, "Downgrades"), so either route, USB or the STARTUP menu, may refuse it.
6. Build, and download the `.syx`. With version 1.73 its sha256 is
   `893ed9a5fc27ab18687c1ea95d7a07f4ff4b23fde235173ce332e54055a733ab`. That is the file our emulator suites ran
   (rytm-emu, not yet a unit: see "Status" below). If yours differs, do not flash it: see the next section.

### If your file's sha256 differs

The page builds with whatever elekloader commit it runs today. Our hash was made and checked with elekloader at
`c150ac5`; on 2026-10-27 the live page ran `b893c93`, which gives the same file (measured). A later packer or linker
can give another file. To see the page's commit: the page's footer names it, and
<https://irpina.github.io/elekloader/build.json> says it (`"commit"`). If the page has moved and your hash differs,
build with the command line at the pinned commit instead:

    git clone https://github.com/irpina/elekloader && cd elekloader
    git checkout c150ac583a4b7e6d64680d5592f4a40f409193f7
    python3 -m elekloader.patch --stock Analog-Rytm_MKII_OS1.73.syx --mod core-0.1.elemod \
        --mod rytm-sidecar-0.3.0.elemod --out sidecar.syx --version 1.73

and check that `sidecar.syx` has the sha256 above.

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
3. Send the **stock** `Analog-Rytm_MKII_OS1.73.syx` over **DIN MIDI** (Transfer > CONNECTION, "LEGACY OS UPGRADE
   mode", or C6). USB does not work in this menu. It takes about 16 minutes or more.

The web page shows the same steps before every download.

## What you cannot do yet

- **Mix it with other people's mods on OS 1.73.** No one else publishes Rytm mods for 1.73: the other Rytm mods
  (Iced-Cream's rytm2_mods) and every Rytm core the web page lists are for OS 1.74. elekloader would refuse a mod made
  for another OS. Even a 1.73 mod by someone else would only combine if it touched none of our bytes; our module
  patches the firmware in many places, so expect it to be refused.
- **Use core-ar2 0.2 or newer.** Use `core-0.1.elemod` only. Core 0.2 and newer (0.2 is the last for 1.73; it is not
  released, but can be built from upstream's source) keep their "mod storage" in a sound's and a kit's spare bytes,
  the same bytes the Sidecar mods already keep their own settings in (0013/0021: the sound's spare bytes; 0025: kit
  FX words 38..41). Both would overwrite each other's settings, silently. The module says so in a way elekloader
  enforces: it claims the first two bytes of each of core 0.2's storage hooks (without changing them), so elekloader
  refuses the build with *"rytm-sidecar 0.3.0 site ... and core 0.2 site ... overlap"*. The format has no way to say
  "core 0.1 only" directly (`resources.core` is a minimum). If you see that message, you ticked a newer core: untick
  it and tick `core-0.1.elemod`. The guard has limits: it catches core 0.2's own storage hooks, at those addresses,
  under today's elekloader, whose overlap check counts any shared byte. A future 1.73 core that hooked storage
  elsewhere, or an elekloader that let byte-identical sites coexist, would not be refused. So the rule stands on its
  own: core 0.1, by its sha256 above, and nothing newer.
- **Pick single Sidecar mods.** The module is all or nothing (above).
- **Use it on OS 1.74.** The module is made for 1.73's addresses; elekloader refuses it with a 1.74 stock file.

## Status

0.3.0 has run in the emulator (rytm-emu: every Sidecar suite on exactly the file above), not yet on a unit. The
emulator enters MAIN OS directly with its own depacker, so it does not run the Rytm bootstrap's depacker on this
file. Two things are new against the rui1051 image the Sidecar's own unit runs: the MAIN OS lacks 0028-elek-hello
(a test counter), and the packed stream comes from elekloader's new packer. The new stream uses only what Elektron's own stock 1.73 stream
already uses (reuse of the last offset, also right after a match; offsets up to just under 1 MiB; counts up to 2048),
within its maxima, and every Rytm depacks the stock stream at every boot; so the first hardware boot is expected to
work, and the bootstrap (untouched) is the way back if it does not. First hardware boot: not yet.

## Source and licence

The mods are GPL-2.0-or-later (`LICENSE`, `NOTICE`). The source of release 0.3.0 is the tag `v0.3.0` of
<https://github.com/trigcondition/sidecar-mods> (the tag is made when the release is published): `make setup` then
`make release` builds both `.elemod` files from it, byte for byte with the toolchain in `TOOLCHAIN.txt` (GNU
binutils 2.47 `m68k-elf-as`, Python 3.14; another assembler version may give other bytes). `NOTICE` names the exact
elekloader commits: the core is core-ar2 0.1 built unchanged from elekloader's `mods/core-ar2` at `8972d70`, with
elekloader's builder at `c150ac5`; the source of both is in the release folder beside the files.

## For maintainers: the release

    make release          # build/release/<VERSION>/: the two elemods, elekloader's source archives, TOOLCHAIN.txt, LICENSE, NOTICE, SHA256SUMS
    make release-check    # those files only, through upstream's code

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
  - the module must be refused without a core, and with core-ar2 0.2 (built from upstream's `92a99c9`) at one of
    the guard's addresses.
- Then boot the image in rytm-emu and run the suites: `tools/emu/us_base.sh <tag>`, then
  `build/suites/run.sh -j 4 <tag>` (with `RYTM_EMU` and `RYTM_TEENSY` set). The image the web page builds with version
  1.73 is the same file as `build/Analog-Rytm_MKII_OS1.73_<tag>.syx`, so the suites run on exactly what a user
  flashes.
- Merging new mods (rui1052 and later): add them to `RELEASE_MODS` / `RELEASE_ARGS`. build.py refuses a bundle that
  lacks a mod one of its members needs, from the addresses in their bytes and their `[requires] mods`.
