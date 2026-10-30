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
   8972d70 until 2026-10-27, now c150ac5 with the core from 8972d70's source: section 8). elekloader's Rytm 1.73 release must also match ours: stock .syx sha256 (`stock/SHA256SUMS`), MAIN OS
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

## 8. Release 0.3.0: one bundle for the web page, on upstream c150ac5 (2026-10-27)

The user's decisions (2026-10-27): the Sidecar set ships as ONE `rytm-sidecar-0.3.0.elemod` with elekloader's
core-ar2 0.1 beside it, installable from the elekloader web page on OS 1.73; the build moves to the current upstream;
one hardware flash later, by the user; the mods are GPL-2.0-or-later. How a user installs it: `docs/ELEKLOADER.md`.
Feasibility: the assessment of 2026-10-27 (not in this tree). Tags as above; [measured] is this tree, rytm-emu,
2026-10-27. Nothing was flashed.

**The pin.** `ELEK_REV` is upstream `c150ac5` (2026-10-25, also the commit the live web page runs). Upstream's main
has moved core-ar2 to 0.6, OS 1.74 only, so build.py builds the core from its source as it was at `ELEK_CORE_REV`
(`8972d70`, core-ar2 0.1: `git archive` of `mods/core` and `mods/core-ar2`) with the current builder. That gives the
same `core-0.1.elemod` as before, sha256 `33de51c0...` [measured]. The rui1051 set built on the new pin: build and
verify PASS, MAIN OS `e4534dfb...` byte-identical to rui1051's [measured]. The `.syx` differs (`f0926cf4...`, was
`a5058810...`) only because upstream rewrote its aplib packer on 2026-10-24: the packed bytes are new, and the Rytm's
depacker has run them only in rytm-emu so far (below), not on a unit.

**The bundle.** `tools/build.py --elek-bundle` writes one elemod for every enabled mod: id `rytm-sidecar`, version
from `VERSION`, author trigcondition, licence GPL-2.0-or-later, the homepage in the description. Each area mod's stub
is one of its sources, with its params as `.set` lines (elekloader's `defsym` would give every source all of them),
its `.run` padded to 4 as the linker pads a mod's section. So the members land where their own elemods put them: the
bundle's image is byte-identical to the per-mod build's, MAIN OS `e4534dfb...` and `.syx` `f0926cf4...` [measured].
build.py refuses a bundle when a jmp / ptr / subscriber name is defined by two members, or when a member needs a mod
the bundle lacks.

**`requires` between per-mod files** (without `--elek-bundle`; still the default). Each file requires:
- `core` when it has area code;
- every mod whose cave claims a 32-bit word of its bytes points into (`cross_refs`: its sites' new bytes and its
  area code, every even offset): measured for the rui1051 set, 0021 -> 0023 (td_pool_tab, the pool table), 0022 ->
  0021, 0023, 0026, 0029, 0030 (the router's mailboxes and 0030's switch), 0026 -> 0021 (us_cubox), 0029 -> 0021
  (ext_stepbox);
- what its mod.toml names in `[requires] mods`, for what no address shows: 0021, 0023, 0026, 0030 -> 0022 (their
  host messages come only through the router), 0029 -> 0022 and 0025 (the names; FX words 38..41 in the kit).

The `excludes` become `conflicts` (`rytm-<id>`). elekloader then refuses `core + rytm-0021` alone ("requires
rytm-0023-teensy-drive") and `core + 0029 + 0030` [measured]. The manifest's `elek` record keeps `requires` and the
addresses found (`refs`).

**Not "core 0.1 only" in the format, so a guard.** `requires` names an id (every core is `core`) and
`resources.core` is a minimum. core-ar2 0.2 (92a99c9, the last 1.73 core, not released) keeps mod storage in the
sound's spare bytes (live +0x6d..+0x6f, stored +0x70..+0x73/+0x77) and the kit's (+0x816..+0x81d stored), where 0013
(HPF, stored slot 42 = +0x70), 0021 (slot 47 / live +0x6e) and 0025 (FX words 38..41, kit storage 0x816..0x81D)
already keep theirs. With the rui1051 per-mod files, core 0.2 combined: "OK: the mods combine" [measured]. Now
0013/0021 and 0025 (and so the bundle) carry, for their scope, a `bytes` site with new = stock over the first word of
core 0.2's st_sound_save / st_sound_load (0x4000843a, 0x400081f6) and st_kit_save / st_kit_load (0x400088d6,
0x4000863e): nothing in the image changes, and elekloader refuses core 0.2 with *"rytm-sidecar 0.3.0 site
0x400081f6 and core 0.2 site 0x400081f6 overlap"* [measured]. Its limits: it is bound to those
addresses and to today's overlap rule (elekloader's `common_checks`: any shared byte, identical bytes included). A
future 1.73 core that hooked storage at other instructions, or an elekloader that let byte-identical sites coexist,
would pass silently: release-check would catch the second at the next release, but files already published would then
combine on the live page. There is no later 1.73 core today (0.2 is the last; docs/CORES.md says each core keeps all
of the one before, so a 0.2.x would keep these sites). The rule in docs/ELEKLOADER.md therefore stands on its own:
core 0.1 by its sha256. The real fixes: a max-core version or a storage resource name upstream, or moving
0013/0021/0025 onto `core_store` fields (section 5, the 1.74 port).

**The release gate.** `make release` builds the set (`RELEASE_MODS` / `RELEASE_ARGS`: the rui1051 set without
0028-elek-hello, a test counter nothing needs) with `--elek-bundle`, runs verify.py, and puts in
`build/release/0.3.0/`: `core-0.1.elemod`, `rytm-sidecar-0.3.0.elemod`, the source of elekloader's parts
(`elekloader-8972d70-core-ar2-src.tar.gz`, `elekloader-c150ac5-src.tar.gz`: GPL-2.0 section 3), `TOOLCHAIN.txt`
(rytm-mods and elekloader commits, `m68k-elf-as` and Python versions: the bytes depend on the assembler), `LICENSE`,
`NOTICE` and `SHA256SUMS`. The tag is `rel<VERSION with - for .>` (rel0-3-0). `make release-check`
(`tools/release_check.py`) takes only the published files and the stock `.syx`: lint, `patch --check`,
`patch --out --version 1.73`, and the web page's own `web/bridge.py` (run in CPython, its `/work` on a scratch
folder): add both as the user's own files, tick the bundle (it ticks the core), check, build with 1.73 and with the
page's default `2.0a`. Every image: MAIN OS the release build's, sections 1/2/5/8 stock, the bootstrap at
`1b8d3b72...`. The CLI's and the web page's 1.73 builds must be build.py's `.syx`, the core its pinned sha256, the
refusal with core 0.2 at one of the guard's addresses, and docs/ELEKLOADER.md's three hashes the release's.

Release 0.3.0 without 0028 [measured, 2026-10-27]: bundle `63d603d4...`, core `33de51c0...`, `.syx` (version 1.73)
`74348b99...`, MAIN OS `5cb34202...`: no longer rui1051's `e4534dfb...`, by 0028's code (40 B of area code, its
ev_tick entry) and its detour at 0x400a4684. release-check PASS, 45 checks. The live page's commit that day,
`b893c93` (10 commits past c150ac5, linker changes), builds the same `.syx` from the published files [measured, CLI
at b893c93].

The earlier set with 0028 (`rel030`: MAIN OS `e4534dfb...` = rui1051's, `.syx` `f0926cf4...`) passed every suite but
rled's two stockupkeys failures, which rui1051 shows too (below).

**Emulator [measured, rytm-emu-seqp2 50a0139, rytm-teensy integ-1027's sim].** rytm-emu enters MAIN OS directly and
depacks it with its own reimplementation (rytm-emu src/machine.rs, src/firmware.rs), so the suites prove the image,
not the Rytm bootstrap's depacker on the new packer's stream. For that, the argument is the stream's tokens
(reviewer's count, 2026-10-27): the new stream uses only what Elektron's own stock 1.73 stream uses, within its
maxima: reuse of the last offset (43,917 times; stock 32,751), also right after a match (31; stock 27), offsets up
to 1,048,116 (stock 1,048,473), counts up to 2048 (stock 2048). Every Rytm depacks the stock stream at every boot. The
old packer, which booted on the unit, never used reuse or offsets above 64 K. Size and in-place gap sit between
stock's and rui1051's, both of which boot. So the first hardware boot is expected to work; the bootstrap (untouched)
is the way back if not.

Release 0.3.0 (`rel0-3-0`, without 0028): `tools/emu/us_base.sh rel0-3-0` booted
`build/Analog-Rytm_MKII_OS1.73_rel0-3-0.syx` (the web page's and the CLI's 1.73 file, `74348b99...`), and
`build/suites/run.sh -j 4 rel0-3-0` ran every suite: bk, cu, frz, fxin, mrep, pc, rui, sfu, sfx, sp, sq, sv, td, us
ALL PASS. rled: the same 2 failures, `stockupkeys gridtrig: UP held + RECORD / PLAY: CLASH`, which rled gives on
rui1051 as built today too (run in this tree on rytm-emu's us_rui1051 base, 2026-10-27): pre-existing, not from
elekloader or the bundle. The suites read the manifest's `rytm-<id>:<label>` names, which a bundle build writes for its
members (equal to the per-mod build's). bk's comparisons need build/emu/rui1043's manifest, copied from rytm-mods-1051.

**Status.** Still `built`. The new packer's first hardware boot is the user's flash of the page-built file. Then
0027's status can move.

**Open.**
- The mailboxes in cave23's tail (0x401b9e54..0x401b9e6a: 0029's, 0026's, 0030's switch) are written only at run
  time, so no site claims them: elekloader cannot refuse someone else's site there. Not an issue on 1.73 today (no
  one else's mods), but a third-party mod could take those bytes.
- Version field (hardware question, unmeasured): the web page's default version for the Rytm is `2.0a`. Whether a
  unit reporting 2.0a can go back to stock 1.73, by USB (MAIN OS carries "Downgrade not possible") or by the STARTUP
  menu (the bootstrap carries a VERSION CHECK, re/subsystems/os-upgrade.md), is untested. The guide says never to
  flash a build whose version is not 1.73.
- The live page moves: the guide pins c150ac5, says how to see the page's commit (`build.json`), and gives the pinned
  command line for when the hash differs.
