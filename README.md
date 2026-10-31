# Sidecar | Expander: Rytm mods

The source of the Analog Rytm MKII OS mods that Sidecar | Expander uses: the patch sources, the symbol map, the
allocation registry and the build that turns your own stock OS 1.73 `.syx` into a modded one.

This repository holds the source of the **Rytm firmware 0.3.1**, released with **Sidecar 0.3.1** (Raspberry Pi 4B and
Pi 5), a fix release: send FX values now follow a kit switch. It is one elekloader module, `rytm-sidecar-0.3.1.elemod`, used with elekloader's `core-0.1.elemod` on OS 1.73.
Build the `.syx` from your own stock file on elekloader's page or command line, or in the browser patcher (build
`rel0-3-1`); both give the same file.

> **Sidecar Mini (Teensy 4.1) is phased out.** It is frozen at 0.1.0, with its Rytm build `rui1027d` (below): no new
> features. The 0.1.0 release stays downloadable.

- Release (the two `.elemod` files, `SHA256SUMS`, `LICENSE`, `NOTICE`, the source of elekloader's parts):
  <https://github.com/trigcondition/sidecar-mods/releases/tag/v0.3.1>; install: `docs/ELEKLOADER.md`
- The older builds (`rui1027d`, `sfx1021`, for Sidecar 0.1.0, Sidecar Mini 0.1.0 and Sidecar 0.2.0) and install guides:
  <https://github.com/trigcondition/sidecar-expander/releases>
- Documentation and the browser patcher: <https://trigcondition.github.io/sidecar-expander/>
- The Sidecar engine: [sidecar-firmware](https://github.com/trigcondition/sidecar-firmware), its 0.3.1 release:
  <https://github.com/trigcondition/sidecar-firmware/releases/tag/v0.3.1>

> **Unofficial, experimental software.** Not affiliated with, endorsed by or supported by Elektron. No Elektron
> firmware, and nothing extracted from it, is in this repository: you supply the stock `.syx` yourself. Flashing a
> modded OS is at your own risk; read `docs/HAZARDS.md` and `docs/FLASHING.md` first.

Every build starts from the pinned stock image and rebuilds from source. The
`.syx` is an artifact; the patch sources, the symbol map and the allocation
registry are the project.

## Layout

| path | what |
|---|---|
| `stock/` | checksum of the pinned stock firmware, which you supply. Never written to. |
| `re/` | cumulative reverse-engineering knowledge: `symbols.toml`, subsystem notes, Ghidra bootstrap |
| `mods/NNNN-slug/` | one modification: manifest, stub source, design rationale |
| `requirements.txt` | Python packages for the mod 0006 calibration and telemetry tools and mod 0013's timing tool |
| `registry/` | `allocations.toml` - every claim on cave space and detour sites |
| `tools/` | build, layout validation, verification, symbol generation, cave scan |
| `vendor/` | third-party code that is **executed** (elektron-firmware-tool, MIT; elekloader for 0027 builds and the release, GPL-2.0-or-later), fetched by `make setup`; see `NOTICE` |
| `docs/` | user manual, flashing, hazards |
| `build/` | artifacts, gitignored |

## Build

Prerequisites:

- Python 3.11 or newer (build and verify use only the standard library)
- `git`, `make` and a C compiler, for the vendored container tool
- `m68k-elf-binutils` (`brew install m68k-elf-binutils` on macOS)
- a Ghidra install, only for `make ghidra`

The stock firmware is not included. Download Analog Rytm MKII OS 1.73 from
Elektron's support site and place the `.syx` at
`stock/Analog-Rytm_MKII_OS1.73.syx`. The build refuses any file whose checksum
differs from `stock/SHA256SUMS`.

    make setup     # venv + Python deps, clone and build the vendor tool at its pinned commit
    make verify    # build + assert the result

Produces `build/Analog-Rytm_MKII_OS1.73_<tag>.syx`, the only delivery format this
device has - there is no CF-card `.bin` equivalent. See `docs/FLASHING.md` to install it.

Build a subset for hardware bisection:

    .venv/bin/python tools/build.py --mods 0000-shared 0004-lfo-rnd

## The release (0.3.1)

The Sidecar mods as one elekloader module, `rytm-sidecar-<VERSION>.elemod`, with elekloader's core 0.1 beside it
(`VERSION`, `docs/ELEKLOADER.md`). From a clean checkout at tag `v0.3.1`, after `make setup` and with the stock file in
`stock/`:

    make release          # build/release/0.3.1/: the two .elemod files, LICENSE, NOTICE, TOOLCHAIN.txt, the
                          # source of elekloader's parts, SHA256SUMS
    make release-check    # the published files through elekloader's command line and web page code path

`make release-check` takes only the published files and the stock `.syx` through elekloader's command line and its web
page's code path: MAIN OS must come out as the release build's, the other sections stock.

With the toolchain `TOOLCHAIN.txt` names, `core-0.1.elemod` has sha256
`33de51c098ab0ecd9cc57e9dfc3efa3d95f8133b1f4a4e6abd80d5fdba2dd825` and `rytm-sidecar-0.3.1.elemod`
`e451fd6001f28d7cb0e9a05d46c712b49d1688c8873714d43f4ec1b786aaae5c`, the released files; the `.syx` elekloader
builds from them (version 1.73) has sha256 `a203db27201aabbdaa285ccb7c40a168075206c0ce91477671fcfae729c3df3c`.

## The Sidecar build `rui1027d` (Sidecar 0.1.0, Sidecar Mini 0.1.0, Sidecar 0.2.0)

The patch build released with Sidecar 0.1.0 and kept for 0.2.0 (the browser patcher's older build); Sidecar Mini, frozen
at 0.1.0, stays on it. From a clean checkout, after `make setup`
and with the stock file in `stock/`:

    .venv/bin/python tools/symbols.py
    .venv/bin/python tools/build.py --tag rui1027 \
      --mods 0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive 0025-sendfx-report \
             0027-elekloader 0028-elek-hello 0029-sendfx-ui 0026-remote-ui 0030-fx-in \
      --param 0014-hidden-machines:variants=0 --param 0014-hidden-machines:funcgen=0 \
      --param 0014-hidden-machines:test=0 --param slots=1 --param 0022-looper:keys=0 --param 0022-looper:sfx=1 \
      --area-elek 0022-looper --area-elek 0025-sendfx-report --param 0022-looper:rui=1 --param 0022-looper:fxin=1
    .venv/bin/python tools/verify.py --tag rui1027

`build/Analog-Rytm_MKII_OS1.73_rui1027.syx` then has MAIN OS sha256
`613a952fe2eff4eda5022b2180dad82ed1beaa0341bbdf154671dd26536f689a` and file sha256
`4843848805c0e08b3cf7c69bf5b68ca7e1453bb643d351709bdad9f59468dce8`, the same bytes as the released
`Analog-Rytm_MKII_OS1.73_rui1027d.syx`.

## The container

Unpacks and repacks with the vendored tool, all checksums verified, five sections:

| id | name | size | load base | we touch it |
|---|---|---|---|---|
| 5 | meta | 15 B raw | - | no |
| 2 | bootstrap | 42,302 | 0x07020000 | **no** - see `docs/HAZARDS.md` |
| 1 | FPGA | 149,516 | 0x00000000 | no |
| 3 | MAIN OS | 3,005,432 | 0x40000400 | yes, this is the whole project |
| 8 | ? | 159,948 | 0x00000000 | no |

MAIN OS is ColdFire big-endian, as on the Octatrack, but it is a C++ build with its
Itanium-ABI symbol names left in (`ParameterPageView::changeParameterLockValue`,
`AnalogRytm::logicalParamID_t`, `Kit::updateMirror`). Most of the map can be recovered
by demangling rather than by guessing.

Section 8 is new in 1.73, little-endian ARM Thumb rather than ColdFire, and carries
`{"version": "1.00E", "release": "0018"}`. 1.73's only listed improvement is
"[MKII] Added Outbox 8 configuration support", so it is almost certainly the Outbox 8's
own firmware riding along - inferred, not proven.

`make verify` asserts that sections 5, 2, 1 and 8 come back out of our rebuilt `.syx`
byte-identical to stock, so a mistake can only ever reach MAIN OS.

## Mods

In the 0.3.1 module and the Sidecar build `rui1027d` (0028 in `rui1027d` only); each folder's `mod.toml` and
`design.md` say more:

| id | what |
|---|---|
| 0014 | the hidden machines the firmware carries but never lists |
| 0021 | external voice machines on every track, for the USB host (the Sidecar), and the user slots |
| 0022 | looper mode, and switches the other Sidecar mods share |
| 0023 | the Sidecar's SD card as the SIDECAR folder in the Rytm's sample browser (the mod's name `teensy-drive` dates from Sidecar Mini) |
| 0025 | the send FX reporter and its storage |
| 0026 | the remote pages: the Rytm as a terminal for pages the Sidecar draws, and the SRC view |
| 0027 | elekloader's core: the boot copier, hook bus and code area for mod code |
| 0028 | elekloader smoke test (a counter in elekloader's area) |
| 0029 | the AMPLITUDE 2 and SEND FX 1/2 pages |
| 0030 | FX in: the delay and reverb return over USB, switched by the host |

0031-remote-keys (REMOTE KEYS, a development and test feature) is not in the release and not published here; its
entries in `registry/allocations.toml` and `re/symbols.toml` are kept as a record, and `tools/layout.py` checks only
the claims of mods in this tree.

The older stand-alone mods (not part of the Sidecar build, and mutually exclusive
with 0021). 0002-euclid-accents and 0003-velocity-humanise (older experiments, not in
any Sidecar release) are not published here: 0002's accent icons were made from the
stock glyph bitmaps. Retracted mods and one-off hardware probes are not part of this
package; the pool notes in `registry/allocations.toml`
still record what those probes established.

| id | title | status |
|---|---|---|
| 0000 | The shared runtime other mods call into | built |
| 0004 | Two per-sound random modifiers on a second LFO page | built |
| 0006 | Scrolling compressor gain-reduction estimate | hardware-verified |
| 0008 | Filter frequency shown in Hz | hardware-verified |
| 0009 | Main output RMS indicator on the compressor VOL label | built |
| 0010 | NO + PLAY toggles between the edited kit and the saved one | hardware-verified |
| 0012 | SLICE LOOP in the track menu: sixteen trigs slicing a one-bar loop | hardware-verified |
| 0013 | Voices to MAIN through the DAC, with a per-sound high-pass | hardware-verified |

Status ladder: `re-only` -> `built` -> `hardware-verified`, plus `retracted`.
Only `hardware-verified` counts.

## Adding a mod

1. Add any new addresses to `re/symbols.toml` with an honest `status`.
2. Claim cave space and detour sites in `registry/allocations.toml`, recording the
   stock bytes at each detour host in `expect`. A mod may hold several cave claims,
   each naming the `section` it holds (`.text` by default): the pools are separate
   regions of the image and can never merge, so anything larger than the biggest
   free run has to be split, and the split belongs in the registry rather than
   being implied by sizes.
3. Write `mods/NNNN-slug/{mod.toml,stub.s,design.md}`.
4. `make verify`, then flash that mod alone.
5. Before you commit, `python3 tools/hash_expect.py --image build/stock_mainos.bin`: it turns each `expect` into
   `expect_len` + `expect_sha256`, and a `replace` that copies stock bytes (a parameter record, say) into
   `replace_from = <address>`, so no stock bytes reach the repository. The build reads them from your stock image
   and checks the hash.

The `expect` bytes are the load-bearing guard: if an address is wrong or two mods
collide, the build aborts instead of quietly patching the wrong place.

Before the first mod ships, the cave pool has to be earned: `make cavescan` reports
the candidates, `registry/allocations.toml` explains why the current one was chosen,
and it stays `status = "candidate"` until it has been proven untouched at runtime on
hardware. octatrack-mods inherited a pool it had not checked and lost a round trip to
it.
