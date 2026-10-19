# Flashing

The Rytm MKII has one delivery format, a `.syx`. There is no card slot and no
`.bin` equivalent of the Octatrack's CF-card path.

## Before the first modified image: prove recovery (stage S0)

Nothing modified goes onto a unit until its recovery route has worked on that
unit (docs/REVIEW-2026-10-09.md, HIGH 3 and the staged plan there):

1. Back up every project and sample (Transfer) and note the +Drive listing
   and byte counts.
2. Confirm a DIN MIDI interface and Transfer's legacy mode on the computer.
3. Do a full **DIN legacy reflash of stock 1.73** through the STARTUP menu
   (FUNC + power, TRIG 4, below) - about 16+ minutes for 3 MB. Only this route
   is served by the bootstrap; the USB route needs a booting MAIN OS and a
   working [YES], and 0022 hooks the panel path that [YES] uses.
4. Make a scratch project for every test.

Only then follow the stages S1..S5 of docs/REVIEW-2026-10-09.md, one change at
a time, each with its go / no-go.

## Hardware builds

The emulator build (`lp3n`) lists hidden engines that have never run on
hardware. Hardware builds keep 0014-hidden-machines' groups off (its defaults
are 0 since 2026-10-09; say so explicitly anyway) and the user slots off
(`slots=0`, also the default since 2026-10-11; say so explicitly too):

    .venv/bin/python tools/build.py --tag hw1 --mods 0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive \
        --param 0014-hidden-machines:variants=0 --param 0014-hidden-machines:funcgen=0 --param 0014-hidden-machines:test=0 \
        --param slots=0 --param 0021-ext:diag=1
    .venv/bin/python tools/verify.py --tag hw1

(diag=1: DSP SAMPLE's SMPL knob C is the read-only diagnostic DGN, for the
bring-up stages; normal builds leave it 0 and get MOD there.)

**The user slots are a build parameter (2026-10-11).** Everything they add - 0021's user-slot claims (caves, detours,
patches, all gated `slots` in the registry) and code (`EXT_SLOTS` in ext.c), 0022's router range for their SysEx and
0023's 12-byte mailbox - is gated on `slots` in 0021, 0022 and 0023. `--param slots=N` sets all three; build.py
refuses an image where they differ (`linked_params`: 0021 with slots=1 calls the mailbox's third word, which is
0023's code in the 8-byte mailbox). With `slots=0` the image is the pre-slot one byte for byte: `hw1` above has MAIN OS
sha256 `cfbb33464d73ccf7a1cd9a07af4b6cbd639d0b457abb3ad4428710ffb123b394` built on this branch and at c127fe8, the
tree the 2026-10-09 review and its evidence are for (measured 2026-10-11; `hw1s1` and `hw1s2` below match c127fe8's
too). The default is 0 so that no hardware command gains the user slots without asking for them.

(0014 with all three groups off adds nothing: the image is byte-identical to
one built without it.) For the stages, subsets of the same mods with the same
params (`slots=0`): S1 `--tag hw1s1 --mods 0022-looper`; S2 `--tag hw1s2 --mods
0021-ext` (or with 0022-looper once S1 passed); S3 and S4 `hw1` itself (0023
added; byte-identical to a build of 0021 0022 0023 alone). All of them build
and verify (2026-10-09, again 2026-10-11 with `slots=0`); `hw1` boots and runs the review's scenarios in
rytm-emu. A Teensy on the user-slot protocol plays them: their reports carry no sound tag (0x04 41 bytes, 0x03 39),
which it reads as untagged (rytm-teensy sim/protocol.py).
Read the whole build output: a cave overflow leaves the old image in place and
verify.py then passes on it. On hardware, DSP SAMPLE's DGN knob (SMPL page,
knob C) shows the diagnostic values (mods/0021-ext/design.md).

The emulator's old build `lp3n` (rytm-emu docs/RESUME.md) passed `funcgen=1`. Since the user slots (2026-10-10)
build.py refuses 0021 with 0014's `funcgen=1` or `test=1` (FUNC. GEN.'s and the TEST machines' records are the user
slots' page 2; refused with `slots=0` too): any build with 0021 needs `funcgen=0 test=0`, so lp3n is no longer
buildable as written - us1 below replaces it. (`variants=1` now lists only BT IMPROVED: 35..42 are 0021's. 0020-dmach
no longer gets its machines listed by it: build.py warns.)

The user slots' builds (2026-10-10/11; rytm-teensy docs/superpowers/plans/2026-10-10-user-slots-rytm.md;
mods/0021-ext/design.md "User slots"). `us1`, the emulator's, lists BT IMPROVED (`variants=1`), a hidden engine never
run on hardware:

    .venv/bin/python tools/build.py --tag us1 --mods 0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive \
        --param 0014-hidden-machines:variants=1 --param 0014-hidden-machines:funcgen=0 --param 0014-hidden-machines:test=0 \
        --param slots=1
    .venv/bin/python tools/verify.py --tag us1

`hwus1`, **the hardware build of the user slots**: 0014's groups all off, as `hw1`, and DSP SAMPLE's diagnostic knob:

    .venv/bin/python tools/build.py --tag hwus1 --mods 0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive \
        --param 0014-hidden-machines:variants=0 --param 0014-hidden-machines:funcgen=0 --param 0014-hidden-machines:test=0 \
        --param slots=1 --param 0021-ext:diag=1
    .venv/bin/python tools/verify.py --tag hwus1

Both build and verify, and pass the emulator suite (`tools/emu/us_base.sh <tag>`, then `tools/emu/us_emu.py <tag> all`,
2026-10-11; mods/0021-ext/design.md "Status"). `hwus1` is built, verified and emulator-tested only; it has never been
flashed. `funcgen=0` and `test=0` are required. build.py refuses (tools/test_build_excludes.py):
- 0014 with `funcgen=1` or `test=1` (0021's `excludes_params`);
- 0002-euclid-accents (param_value_text's entry), 0003-velocity-humanise (it needs 0002: euclid's accents would go
  silently; refused since 2026-10-11), 0004-lfo-rnd (sound index 0 is the U-sound's tag; its cave2 holds the tag's
  code), 0006-comp-preview and 0013-voice-dac (their caves hold the user slots), 0009-main-rms (cave7's head),
  0020-dmach (the same page-2 lookups);
- 0021, 0022 and 0023 with different `slots`, or `slots=1` without all three in the image (since 2026-10-11).

## User slots on the real Rytm: bring-up checklist

**The Rytm is not flashed with a user-slot build before the review gate passes**: the firmware review of the built
code and of this checklist comes first (after the optimisation and the Teensy's PSRAM and host-cable tests). Until
then everything below is a plan. The emulator results it builds on are in
mods/0021-ext/design.md ("Status") and user-slots-research.md.

Before anything:
- Backups: the user has backed up all projects, samples and sounds (Transfer). Keep that set read-only; note the
  +Drive listing and byte counts again on the day.
- Stage S0 above (a DIN legacy reflash of stock 1.73 proved on this unit) holds for this build too.
- A scratch project for every step; never the backed-up ones.
- The Teensy on its own tested build (rytm-teensy, host mode, the store with the test plugins: U1 sine_test,
  U2 fault_test).
- Record, before flashing: `verify.py --tag hwus1` PASS (its last line), the sha256 of the flashed
  `build/Analog-Rytm_MKII_OS1.73_hwus1.syx` (`shasum -a 256`), the rytm-mods commit it was built from, and the
  rytm-teensy commit on the Teensy (its user-slots branch was at e5b0407 on 2026-10-11). A finding is only worth
  something against exactly that pair.
- Projects made under 0002-euclid-accents / 0003-velocity-humanise lose their euclid accents and humanise on a
  user-slot build (0021 excludes both; their settings are not played). Use scratch projects, not those.
- Heap: the firmware's allocator (0x40082758, a buddy allocator over a 16 MB arena) has ~13.2 MB free after `us_init`
  (11 KB: five 2 KB slot caches, the staging buffer, the write-backs) and 0023's pool table; largest free block 8 MB
  (measured in rytm-emu, us1, 2026-10-11; mods/0021-ext/design.md "Heap"). Not a risk to watch on the day.

Staged steps, one at a time, each with a go / no-go (stop and flash stock back on any fault, hang or garbled screen):
1. **The build without a Teensy.** Flash `hwus1` (Transfer, USB; not us1, which lists BT IMPROVED). Boot: the main screen, the machine list shows
   `USER 1`..`USER 5` on every track, the track menu shows `U1 ?`..`U5 ?`, YES on one says NO TEENSY after ~2 s (the UI
   stalls that long: expected). Stock machines play as before. Go: no fault, ten minutes of a stock pattern.
2. **The Teensy connected.** Names arrive within seconds (`USER n ---` for EMPTY, the plugin's name for READY).
   Choose U1 on BD from the machine list: P1..P16 jump to the plugin's defaults, BD plays the Teensy's sound through
   its filter and amp. Turn knobs; the Teensy's write-backs (PRE) move them.
3. **The slot menu.** Assign U1 to the next installed machine: the popup (READY) comes within the 2 s; BD takes the
   new machine's defaults. Time the popup and the defaults (both should be well under a second with a Teensy that
   answers).
   - The no-answer case: the Teensy's names arrived (its 1D seen), then YES on U1 while the Teensy does not answer the
     1E (unplug its USB just after the names, or while it installs). The UI stalls at most 2 s in all (the list and
     the 1E share one 2 s wait since 2026-10-11; before, up to 4 s), then NO TEENSY; the menu and the knobs answer
     again at once. Time it.
   - An install from the card that fails (a MISSING slot, `NOT ON CARD` or no answer): the next YES on that slot
     steps it to the next installed machine (or clears it) instead of trying the install again.
4. **First things to verify on the hardware** (the untested list):
   - the sound tag through copy/paste: copy BD's U-sound, paste it on SD (both on U1 = the same plugin) - it plays;
     paste it onto a track whose slot holds another plugin - silent on the Teensy and `!NAME` on the selected track;
   - `!NAME`: change U1's machine on the Teensy side (not by the Rytm's menu); BD's sound is now foreign - silent,
     and the machine list shows `!` + the name while BD is selected;
   - the slot menu's timing on the real clock (above), and the 60 s window: choose U1 with the Teensy off, connect
     it within a minute (defaults go in) and, in another run, after more than a minute (they do not);
   - power-off persistence: a U-track with knobs moved, a written-back value and a tag; power off, on: the track,
     its words and its tag come back (cold boot); then the same project on stock 1.73 must show DISABLE without a
     fault (only after the build's own power-off cycle passed).
5. **Load and switch.** RELOAD KIT, LOAD KIT, a pattern on another kit, LOAD PROJECT right after a choice: the loaded
   words stay (no defaults over them). Sound locks from a pool sound tagged for another plugin: silent on that step.
6. **DIN.** Nothing on DIN should speak the Teensy's SysEx (`F0 7D 52 54 ...`): the router takes it from DIN as from
   USB (measured in rytm-emu, user-slots-research.md R13). Keep DIN MIDI devices that send SysEx unplugged for the
   first sessions.
7. **One hour** of a pattern on U-tracks with Overbridge streaming and knob turns, no fault, no dropouts on the
   Teensy's log.
8. **Back to stock.** Before flashing stock 1.73 back: put stock machines on every U-track (and the mods' other
   machines) in the scratch project and save it, and power off once on the build so the working state holds no
   U-track (stock boots that state directly; below).

## Projects saved under the mods, on stock

A project or sound saved while a track plays one of the mods' machines (35..39
U1..U5, 40 6-OP FM, 41 JUNO, 42 DIGIDRUM, 44 PLAITS, 45 DSP SAMPLE, 51 DAISYSP) carries that
machine number and knob words of 0..127 where stock has small lists (review
HIGH 2). Checked in rytm-emu (2026-10-09, stock 1.73 with strict memory checks;
for 40..51 only - 35..39 came later and only the working state below is checked
for them, not project load, copy/paste, the sound pool or the stock-machine reset):
stock loads such a project, shows those tracks as DISABLE (silent, knobs
greyed), copies and pastes their sounds, stores them to the sound pool and loads
them back from it, saves and reloads the project - no fault, no hang, no
unmapped access - and choosing a stock machine on such a track resets its words
to that machine's defaults. Not covered: the analog side and anything else the
emulator does not model. On hardware, until a unit has shown the same: use
scratch projects under the mods, and put stock machines on those tracks (and
save) before going back to stock.

The working state (what the Rytm boots into) goes the same way: OS 1.73 writes
it to two raw eMMC slots when the power goes (on its supercap) and before an OS
upgrade, and boots from it - so after flashing back to stock, stock boots the
mods' working state directly, without loading any project. rytm-emu models that
power-off (2026-10-09, rytm-emu docs/RYTM-PORT.md "Power-off and the working
state"): lp3n's state with all six machines, knobs far up, sounds in the pool,
kit and project saved, cold-booted and powered off on lp3n x3, stock x3, lp3n,
hw1 x2, hw1 diag=1, lp3n - no fault, no hang, no boot loop; stock shows the six
tracks as DISABLE and keeps their words, the mods get them back unchanged.
Checked in rytm-emu for 35..39 too (2026-10-10, tools/emu/us_emu.py stock:
working state across a power-off, stock shows DISABLE and keeps the words, the
build gets them back).
Power-off mid JUNO/FM name update, while playing, inside the TEENSY browser and
during Overbridge streaming: clean. Not covered: the OS upgrade's own save
(inferred from the code), the supercap running out mid-save.

## Normal route (Elektron Transfer, USB)

1. Connect over USB, power on.
2. Transfer > CONNECTION: set MIDI IN and OUT to the device.
3. Transfer > DROP: drag `build/Analog-Rytm_MKII_OS1.73_<tag>.syx` on.
4. Press `[YES]` on the device to confirm.

The unit restarts by itself. This path runs inside MAIN OS
(`OsUpgradeMenuView`), so it needs a MAIN OS that still boots.

## Recovery route (STARTUP menu, DIN MIDI only)

1. Hold `[FUNC]` while powering on.
2. `[TRIG 4]` enters OS UPGRADE.
3. Transfer > CONNECTION: "LEGACY OS UPGRADE mode", select the `.syx`, UPGRADE.

This one is served by the bootstrap, not by MAIN OS - the menu text lives in
section 2, at `0x9302` in the decompressed bootstrap:

    STARTUP MENU
      ... TEST MODE
    2 ... EMPTY RESET
    3 ... FACTORY RESET
    4 ... OS UPGRADE
    5 ... EXIT

so it should still come up after a MAIN OS that does not boot. USB is not available
here; it needs the DIN MIDI port.

## After flashing

Elektron's readme: "After some upgrades the bootstrap is also upgraded. This upgrade
is performed right after the first restart of the device. Do not turn the power off
during the upgrade." The bootstrap carries its own `BOOTSTRAP UPGRADE` /
`DO NOT TURN OFF!` screen. See `docs/HAZARDS.md`.

## Downgrades

Not supported by the device. MAIN OS carries "Downgrade not possible" and the
bootstrap carries a VERSION CHECK. Assume you cannot go back, and that this is why
the project pins the newest OS rather than an older one.
