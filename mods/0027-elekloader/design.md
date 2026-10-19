# 0027-elekloader: more code space through elekloader (design, 2026-10-16)

The caves are full (about 8 B free in hwus1nl). This mod builds the image with
[elekloader](https://github.com/irpina/elekloader), which already does what we were going to write ourselves:
a blob appended to MAIN OS, copied at early boot to a fixed 128 KB DDR area and linked there. Its Rytm core
(core-ar2 0.1, `vendor/elekloader/mods/core-ar2`) booted on a unit on 2026-10-11, and the DDR area passed a canary
there. This replaces route A of rytm-teensy `docs/superpowers/specs/2026-10-16-drive-code-loader.md` (section 0).
We write no boot stub of our own.

Tags: **[doc]** elekloader's or Modwerk's own docs, not re-checked by us; **[measured]** run in rytm-emu, this
tree, 2026-10-16; **[inferred]** reasoned, not shown. No hardware was used and nothing was flashed.

## 1. Decision: our mods become ordinary elekloader modules

There were two candidate paths:

- **(a) Port the mods to elekloader's source format.** Every mod would be rewritten as a `mod.json` with `sites`.
  The registry, its `expect` guards and verify.py would then exist twice, or be lost.
- **(b) build.py emits elekloader modules (chosen).** build.py keeps everything it does today: the registry, layout
  validation, `expect` guards, assembly at the cave addresses, gates and params. Then, instead of repacking with
  elektron-firmware-tool, it hands the result to elekloader:
  - **one format-2 `.elemod` per rytm-mods mod** (`rytm-<mod id>`). Its sites are the bytes that mod's registry
    claims changed: caves, detours and patches as `bytes` sites. Each site's stock bytes are pinned again by
    sha256 inside the `.elemod`.
  - **mods whose code lives in the area** (`area = "elek"` in mod.toml, or `--area-elek MOD` for an existing mod in
    one build) also contribute:
    - their stub as the elemod's sources, with every section renamed `.run`;
    - their params as `defsym`;
    - their registry detours as `jmp` sites;
    - their `from_symbol` patches as `ptr` sites;
    - `[elek] subscribe` entries for core-ar2's events.

    elekloader's linker places these at 0x47BE0000 and resolves the addresses.
  - `python -m elekloader.patch --stock ... --mod core-0.1.elemod --mod rytm-*.elemod --version 1.73` links and
    appends the blob. It then repacks and verifies with its own checks.

Path (b) keeps one source of truth per thing: the registry holds the addresses, elekloader holds the boot copier,
the linker and the packer. Both checkers run on every build. It is also what makes our mods *compatible with
elekloader as a standard*: the output is plain `.elemod` files that elekloader, its web page or Modwerk's kit can
combine with anyone else's Rytm mods under elekloader's own overlap, name and RAM checks (section 5).

## 2. How a build runs

```
.venv/bin/python tools/build.py --tag hwus1nlel --mods 0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive \
    0027-elekloader 0028-elek-hello --param 0014-hidden-machines:variants=0 --param 0014-hidden-machines:funcgen=0 \
    --param 0014-hidden-machines:test=0 --param slots=1 --param 0021-ext:diag=1 --param 0022-looper:keys=0
.venv/bin/python tools/verify.py --tag hwus1nlel
# the same with --area-elek 0022-looper: 0022's code (the SysEx router) moves from its five caves into the area
```

1. Everything up to the patched image is unchanged. Claims of area mods are skipped: their caves are not written,
   and their detours and `from_symbol` patches are queued for elekloader. Their stock bytes are still checked.
2. `elek_pinning`: `vendor/elekloader` must be at `ELEK_REV` (build.py and the Makefile name the same commit,
   8972d70). elekloader's Rytm 1.73 release must also match ours: stock .syx sha256 (`stock/SHA256SUMS`), MAIN OS
   sha256 and length (`re/symbols.toml` meta), and load address. **The two tools' hash pinning must agree, or the
   build stops.**
3. `owners_of_changes`: every byte that differs from stock is attributed to the applied claim that covers it. A
   byte no claim covers aborts the build, as in verify.py. The bytes are grouped per mod into runs, and those runs
   become that mod's `bytes` sites.
4. `elekloader.sdk.build` runs for core-ar2 and for each generated `build/elek/<tag>/mods/<id>/mod.json`, with
   `ELEKLOADER_CROSS=m68k-elf-`. elekloader re-checks every site's stock bytes, and every `jmp` site for whole
   instructions.
5. `elekloader.patch` links, appends, repacks and checks:
   - sections 1/2/5/8 byte for byte;
   - the main OS depacks in place from 0x40200000;
   - the container ends below 0x300000.

   The container's version field is kept at stock's `1.73`.
6. build.py extracts section 3 with *our* elektron-firmware-tool. It must equal elekloader's main OS by sha256. It
   is saved as `build/mainos_<tag>.bin`. The manifest records an `elek` entry containing:
   - the rev, the elemods and their hashes, the link layout, the area mods' symbols;
   - the elek detours and patches with their resolved targets;
   - flash end and in-place gap.

**verify.py** keeps every check and adds four:
- **The appended block.** It sits at the 16-byte-aligned end of stock (0x402ddff8): core's `.boot`, then the run
  image. Nothing else follows, and the run image plus `.bss` fit inside 0x47BE0000-0x47C00000.
- **The boot site.** 0x400008c0 holds `jsr` to that `.boot`.
- **The container header.** It is stock's (ELE3, build, version 1.73).
- **Area pointers.** An area mod's detours and pointers land on their elekloader-placed symbol, inside the area.
  Displaced and rejoin checks for area mods search the appended run image.

Changed bytes below stock's end must each lie in a claim the build made (the claim list is now filtered by the
manifest's `enabled` and gates). core-ar2's eight sites are claimed in the registry as `foreign` patches
(owner 0027, expect = stock bytes, no replace). As a result:
- layout.py keeps every other mod off them;
- verify.py accepts exactly those bytes.

The checks that stay: null repack, round-trip, bootstrap sha, other sections unchanged, frame check. For area mods
the frame check runs on a `-mcpu=5475` assembly of their stub, `build/obj/<id>.elf`.

A build without 0027 is byte-identical to before: hwus1nl is still `9b72c263...`, the file rytm-emu's
`fw/AR173_us_hwus1nl.syx` holds [measured].

## 3. Evidence in rytm-emu [measured, 2026-10-16]

### 3.1 elekloader's own proof of concept
core-ar2 + hello-marker-ar2 was built from our stock 1.73 by elekloader's CLI. The blob was 616 B and the file
sha256 was efdec1fa...

- Strict cold boot: the `.boot` at 0x402de00a copied the run image to 0x47BE0000 (`--watch-read`).
- The screen at 3G differs from stock in exactly the 3x3 marker's pixels.
- The strict access list matches stock's, except one more access to 0xFC04002D. That is core's PPMSR0 write when it
  starts DTIM0, as on hardware.

### 3.2 The area under heavy use (`tools/emu/el_area.py`, strict)
The free part of the area gets a canary every 32 B (address ^ 0xC0DEF00D, as the hardware canary) plus a read/write
watch over all of it. The watch covers both aliases, and dtboot turns the JIT off while a watch is set.

Run 1 is a busy cold-boot session:
- trigs recorded and played, pads;
- 80 DIN notes plus a CC sweep;
- USB host with the real USB MIDI sender;
- KIT SAVE and KIT RELOAD, a pattern switch, STOP.

Run 1b is a power off: the firmware writes its working state to the card. Run 2 is a cold boot on that card,
followed by PLAY and STOP.

Result: zero watch hits, all canary words intact (4079 / 4078), no fault, no strict access. This held for the PoC,
hwus1nlel and hwus1nlel2. In the hwus1nl builds, core's code in the area is still what elekloader appended. The
only words that change are the mods' own state.

Not covered: sampling, Overbridge audio streaming with a real host, SysEx dumps. The hardware canary
covered sampling and Overbridge [doc].

### 3.3 Milestone 1: hwus1nl + elekloader + 0028-elek-hello (`hwus1nlel`)
- The build is `b46a5b1b...`. It verifies: PASS, 542 checks. The area holds 532 B, with 130 524 B spare.
- **0028 runs from the area:**
  - its magic `EH01` is at 0x47BE01CC;
  - `eh_ticks` counts on core-ar2's `ev_tick`: 628 by the base snapshot (7.4G);
  - `eh_loops` counts through *our registry detour* at 0x400a4684 into the area: 1929.
- **Screen:** after boot plus dialogs plus PLAY/STOP, the screen is identical to hwus1nl's. So is that of
  `hwus1nle0` (0027 alone, no area mod: stock behaviour with the module absent).
- **Suites:**
  - `tools/emu/us_emu.py hwus1nlel all`: ALL PASS, 311 checks;
  - rytm-teensy `phase1.py --emu-only tracks` (PHASE1_TAG=hwus1nlel): ALL PASS.
- **Cache model:** `DTEMU_CACHE=log`, strict cold boot to 4G: `stale fetches: I-cache 0 no-push 0`. This held for
  the PoC, hwus1nlel and hwus1nlel2, as expected: the copy happens before CACR is set, and nothing is patched later.
- **Boot cost:** core's `.boot` runs once, with 133 copy iterations and 4 `.bss` iterations, about 425
  instructions (`--count`). That is about 2 us at 200 MIPS. The copy runs with caches off on DDR, so on hardware it
  is maybe tens of us [inferred]. A full 128 KB area would be about 100 k instructions, around a few ms uncached
  [inferred].

### 3.4 Milestone 2: an existing piece moved, `--area-elek 0022-looper` (`hwus1nlel2`)
0022 with keys=0 is the SysEx router that carries every host-to-Rytm message for 0021 and 0023:
- user slots 1A..1D, 0E, 14, 15..17, 07/08;
- 1628 B across five caves (cave4 tail, cave lp2/lp3/lp4, .lps data).

In hwus1nlel2 that code is linked into the area instead:
- **area:** 2140 B; the router's pointer patch at 0x40083d6e points to `looper_router` @ 0x47BE01EE;
- **caves:** all five of 0022's caves are free in this build.
- **checks:** it builds and verifies (`d55041bb...`, PASS). `el_area` passes and the strict cache-model boot is
  clean. us_emu all: ALL PASS, 311 checks, and every user-slot SysEx now goes through the router in the area.
  phase1 --emu-only tracks: ALL PASS.

**The cave limit is lifted.** 1.6 KB is back in the caves already, with 128 KB of area to move into.

## 4. Limits and open points

- **Only hwus1nl's mods are checked.** 0002..0013 have not been built through elekloader. They should work: their
  bytes are plain sites.
- **The ev_key conflict.** core-ar2 always patches all eight of its sites. Its `ev_key` site 0x400a47cc is the
  call whose operand 0022 keys=1 patches (`looper_key`). 0027 declares
  `excludes_params = ["0022-looper:keys"]`, so build.py refuses that combination, and layout.py treats 0022's
  `keys`-gated claims as exclusive with 0027. The looper should move to `ev_key`: a subscriber that returns
  nonzero takes the key. That is the clean fix, and it is also the elekloader-standard way.
- **ISR cost.** core-ar2 hooks the audio interrupt's entry and exit (`ev_render_in` / `ev_render_out`). With no
  subscriber, each block runs an empty table walk, about 10 instructions twice per 32 frames [inferred]. That is
  negligible next to the A.3 CPU budget in the rytm-teensy spec, but it is not measured.
- **DTIM0.** core-ar2 starts DTIM0 if it is held in reset. This is hardware-verified with core-ar2 on a unit
  [doc]. On the Digitakt II the same start broke a cold boot, which is why core-dt2 has NO_DTIM0. In rytm-emu the
  Rytm boots identically with it.
- **The assembler.** Area stubs are assembled by elekloader with `-mcpu=54455` and by build.py with
  `-mcpu=5475`, for the frame check. Both must accept the stub. EMAC and FPU instructions in area code need
  checking under 54455.
- **Generated elemods are per build.** Params are baked into the code, and the elemod version is the build tag.
  Cross-mod references are absolute: 0021 calls 0023's `td_pool_tab`, and 0022's router writes 0021's mailboxes.
  So the `rytm-*` elemods of one build only combine with each other (section 5).
- **Recovery is unchanged.** It is the untouched bootstrap: hold FUNC at power-on, TRIG 4, stock .syx over DIN.
- **The one-shot flag and run-time watchdog of route A** (rytm-teensy spec) are not part of elekloader's core.
  Add them later as an area mod on `ev_tick` if wanted.

## 5. Compatibility with elekloader as a standard, and with Modwerk

**What fits as is:**
- The generated `rytm-<id>.elemod` files are standard format-2 mods: target pinned by sha256, sites with stock
  sha256, relocatable `.run`, event subscriptions. elekloader's `lint`, `patch --check`, its web page and the
  Modwerk kit accept them like any mod. Anyone else's Rytm mod is checked against ours for overlapping bytes,
  names and RAM.
- 0028 is already shaped like an elekloader example: an `ev_tick` subscriber plus one `jmp` site.

**What needs adapting** before our mods are good standalone modules for other people:
1. **Fixed caves.** Our cave code is written to fixed image addresses as `bytes` sites. elekloader treats those as
   opaque bytes: correct, but not relocatable. Two other mods can still collide with our caves only by touching the
   same bytes, which elekloader refuses. elekloader's Rytm profile declares no `image_free`, so `fixed` sources are
   not available. Moving code into the area (`--area-elek`) is the long-term fix: it makes a mod relocatable and
   small in the image.
2. **Absolute cross-mod references.** These include 0021 to 0023 (`td_pool_tab`) and 0022 to 0021's mailboxes. To
   publish separately they should become exports/imports, resolved by elekloader's linker.
3. **Hooks on the shared event sites.** 0022 keys=1 conflicts with core-ar2 at 0x400a47cc. It should become an
   `ev_key` subscriber. No other registry claim overlaps a core-ar2 site; checked over the whole registry,
   2026-10-16. Our own hooks elsewhere in the UI loop are fine. When the same routine is hooked twice, prefer
   core-ar2's events, so other people's mods can share the site.
4. **Params.** Modwerk and elekloader have no build-time params. Each published variant would be its own elemod,
   or a param becomes a run-time setting (an `ev_settings` row).
5. **Metadata.** Each elemod needs a real `license` (now `NOASSERTION`), author and description. Modwerk also asks
   for its module contract, captures, a resource record and **hardware evidence on OS 1.73**.

**Modwerk** ([modwerk.app](https://modwerk.app), [github.com/repeat98/modwerk](https://github.com/repeat98/modwerk)):
- **What it is.** A browser builder plus a reviewed module library [doc]. For the Octatrack it is built on octabam
  (its own manifest format). For the Digitakt/Digitone families it vendors **elekloader's kit**: the TypeScript
  engine, worker and catalog, pinned by a lock file. Its Digitakt/Digitone modules are elemods.
- **The Rytm.** Modwerk already carries `sdk/analog-rytm-mkii/core-profile/interface.json`: upstream core-ar2 0.1
  with the same eight events. It has no Rytm module yet. A Rytm module is created with
  `npm run module:new -- <id> --machine analog-rytm-mkii`. It needs its own reviewed module contract, docs,
  licensed source, captures, resource record and hardware evidence on 1.73 before it enters the public catalog
  [doc].
- **What publishing takes.** Our elemods are in the format Modwerk's Rytm path consumes, so publishing there later
  means section 5's adaptations (1 to 5), plus a hardware run and a licence decision. It does not need a new format.
- **Licences.** Modwerk's backend is under Elastic-2.0 and its frontend under GPL-3.0-or-later; modules keep their
  own licences [doc].

## 6. Status

- **Built, verified, emulator only** (`status = "built"`): 0027 and 0028.
- **Suite results (2026-10-16):** hwus1nlel and hwus1nlel2 both pass every suite:
  - us_emu all: ALL PASS, 311 checks;
  - phase1 --emu-only tracks: ALL PASS;
  - el_area: PASS;
  - the strict cold boot under DTEMU_CACHE=log: 0 stale fetches.
- **Before any flash:**
  - review the generated elemods and core-ar2's .boot;
  - check the 0022 move against FLASHING.md's hwus1 checklist;
  - only then a hardware run of hwus1nlel. 0027 and 0028 are not hardware-verified, so no status is promoted.

## 7. Licence notes (for the user's decision before any public release)

- **elekloader is GPL-2.0-or-later** (LICENSE, NOTICE). Its TypeScript engine/kit (js/) is GPL-3.0-or-later, and
  so is the kit Modwerk vendors.
- **Repository.** rytm-mods only *executes* the vendored checkout, like elektron-firmware-tool. Nothing of
  elekloader's code is copied into the repository, and our tools call it as a separate program. That alone does not
  make rytm-mods' sources a derivative work [inferred; not legal advice].
- **Built images.** A built `.syx` contains core-ar2's compiled code (its `.boot` and hook bus) linked with our mod
  code in one blob. Distributing such an image, or `rytm-*.elemod` files built to link against core-ar2, is
  distributing a combined work with GPL code. The mod code in it would then have to be offered under GPL-compatible
  terms. Our elemods carry only our own bytes, but they are written to be linked with core-ar2 by elekloader's
  linker.
- **Nothing is published now.** Firmware images are never published anyway: they contain Elektron code. rytm-mods'
  own licence is still undecided. If the mods are ever shared as elemods or through Modwerk, choosing
  GPL-2.0-or-later (or another GPL-compatible licence) for the mod sources avoids the question. Note that 0028's
  stub was written for this repository and copies no elekloader code.
- **Third-party input.** The core-ar2 site list and the area's evidence come from elekloader's docs and
  Iced-Cream/rytm-mods-src (GPL-2.0). They were used as facts and are cited, not copied.
