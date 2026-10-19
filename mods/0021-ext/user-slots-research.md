# 0021 user slots: research findings (OS 1.73)

The spec's open items (rytm-teensy docs/superpowers/specs/2026-10-10-user-slots-rytm-design.md, "Open questions"),
answered before the code relies on them. Tags as in re/: [measured] read in this image or run in rytm-emu, [inferred].
The emulator runs use tools/emu/us_emu.py on the base of tools/emu/us_base.sh (rytm-emu sections/led.img's project).

## R0 Key walks in rytm-emu
**Question** How the tests reach a track's machine list, the user slots and the track menu on the us_base.sh card.
**Method** tools/emu/us_emu.py walks (P0.2), screenshots build/emu/us0/walk-*.png, trackmenu.png.
**Result** [measured, rytm-emu, 2026-10-10] SRC SRC opens the machine list at the track's machine (BD PLASTIC on track BD);
each DOWN moves one entry (previewed, CONFIRM? Y/N), YES takes it. us0: PLAITS 20 and DAISYSP 22 DOWNs below BD
PLASTIC. FUNC held + CHRO opens TRACK: TRIGS SETUP, PAD SCALE, RELOAD TRACK, SAVE TRACK. Knobs A..H: encoders 0..7.
The us0 list below BD PLASTIC: UT IMPULSE 15, DISABLE 16, 6-OP FM 17, JUNO 18, DIGIDRUM 19, PLAITS 20, DSP SAMPLE 21,
DAISYSP 22 (the last: 23 DOWNs stay on it) - the plan's trial build counted 18/20, two fewer. YES at 20 shows CONFIRMED!
with PLAITS' page (ENG HRM TIM MOR DEC LPG TUN LEV) and track BD's machine byte (0x8000ea00) goes 0x15 -> 0x2c. Encoders
0, 3, 4, 7 turned on BD PLASTIC show TUNE, DECAY TIME, MOD TYPE (the TYP knob, E), LEVEL. FUNC held 300M is enough.
**Consequence** tools/emu/us_ui.json; Task 7 re-checks U1's walk (expected 15; on us0 15 is UT IMPULSE, so re-measure).

## R1 The value text's functor on every path
**Question** Does every caller of a record's value-text std::function pass descriptor + 20 (record = (functor - 20 - 0x419a4888) / 84)?
**Method** us0, DAISYSP on BD (22 DOWNs from BD PLASTIC, YES; snapshot at 10300M, machine byte 0x8000ea00 = 0x33),
dsp_engine_text = 0x40136520 (`m68k-elf-nm build/obj/0021-ext.elf`). DAISYSP's P1 is record 449: descriptor
0x419a4888 + 84*449 = 0x419adbdc, functor 0x419adbf0, invoker word at 0x419adbfc (= 0x40136520 in the snapshot).
(1) `--break 40136520 --trace 8` from snapshots taken during each path; (2) every CPU access to the functor's
16 bytes (`--watch-read 419adbf0 16`, DTEMU_NO_JIT=1) over chained 4..8M dtboot runs (dtboot prints 40 watch lines
per run) on: knob A turned (`--turn 0:5` x10, 8M apart; kit word 9 0x10 -> 0x1b), a p-lock (RECORD, T1 held 250M,
knob A turned; the kit word stays 0x10, REC lit, knob A highlighted), the LFO page (LFO, knob G turned 6 times).
**Result** [measured, rytm-emu, 2026-10-10] knob: functor 0x419adbf0, value 0x1000, id 0x1c1 (449), return address
0x40037b0a (the caller of param_value_text through a vtable, `moveal %a0@(84),%a0; jsr %a0@`); p-lock: the same
(0x419adbf0, caller 0x40037b0a). Over both paths the only accesses to the functor storage are param_value_text's
own: 0x400a8604 and 0x400a863c read +8 (the manager 0x400fc658), 0x400a8658 reads +12 (the invoker), three per
render, no copy of the std::function anywhere. LFO page: no access at all (it names destinations; it does not
print ENG's value). The machine list's preview (the plan's run, see below) broke in dsp_engine_text for DSP
SAMPLE's record 416 with functor 0x419ad11c = descriptor(416) + 20: the same rule on that path too.
Notes for later tasks [measured]: the plan's expected functor 0x419ad6a0 was miscomputed (84*449 = 0x9354, so
0x419adbf0); `--break-after N` has no effect with `--load` (dtboot runs the fresh machine to N and then loads the
snapshot, so the breakpoint is live from the snapshot's clock; the plan's run broke during the walk, on the
list's preview of DSP SAMPLE): break from a snapshot taken at the moment wanted instead; `--turn 0:1` single
steps do not move ENG (10 x +1 left the kit word at 0x10; 10 x +5 gave 0x1b).
**Consequence** Task 7: US_THUNKS 0 - every caller seen passes descriptor + 20 (0x419adbf0 for record 449), so
us_text recovers the record from its functor. Tests that break in our code (Task 7 on) take a snapshot at the
moment wanted and break from it; they do not rely on `--break-after` with `--load`.

## R2 Page 2's shared records
**Question** Are records 438, 457..460 and 403..405 (page 2's shared records, spec 1.5) read by number anywhere
but through ext_param_record and the page lookups?
**Method** Stock MAIN OS disassembled as `make disasm` does (its commands run directly, so build/obj stayed the
us0 build's): every `#<n>` immediate of the eight numbers (decimal or hex), every operand naming the record
(0x401bf918 + 0x34 r), the descriptor (0x419a4888 + 84 r) or its functor (+20), every big-endian word of those
addresses in build/stock_mainos.bin (the plan's script with `re.escape` added: unescaped bytes made it fail on
404's address); the RAM index -> record tables (0x413db5fc per machine, 0x413db554 per index, built by
param_tables_build) dumped from the us0 base snapshot (dtpeek).
**Result** [measured, OS 1.73 image and rytm-emu us0, 2026-10-10]
- Record addresses: no word and no operand anywhere (code reaches records by `lea 0x401bf918` + index * 0x34).
- Descriptors: one block per record in the descriptor array's static initialiser (0x401a84xx..0x401b0eex:
  `clrl <desc>`, `pea <desc + 0x14>`, `pea 0x419a4818` (the default formatter template), 233 such copies),
  which builds every descriptor; it is not a read by number. These are the only descriptor operands/words.
- Immediates, each explained: `oril #438,%d6` at 0x401c3b06 lies inside the record table itself (record 323's
  bytes, data); `movel #460,%d0` at 0x400366e0 is a this-adjust thunk (`addl %d0,%sp@(4); jmp 0x401bc524`,
  next to `lea %a0@(460),%a0` siblings): a struct offset; `addil #404,%dN` x12 (0x400444e4 .. 0x4012e612) all
  follow the view base constructor 0x4007807c (`movel %aN,%dN; addil #404,%dN` = a member at view + 0x194):
  struct offsets; every other hit (32) is a `cp0../cp1..` line, i.e. data in 0x4020..0x402d decoded as
  coprocessor instructions whose immediate field the disassembler synthesises from other bits (no 0x01b6 /
  0x01c9 / ... halfword present): not code.
- RAM tables: 0x413db5fc lists them only for machine 43 FUNC. GEN. [403 404 405 406 407 0 0 0], machine 48
  LT TEST [0 0 0 438 0 0 0 0] and machine 52 CB TEST [0 457 458 459 0 0 0 460]; 0x413db554 (indices 0..41) holds
  none of them. Those three machines are not listed with 0014's test=0 and funcgen=0 (us1), and no mod in the
  tree names any of the eight numbers.
**Consequence** Task 7's `us_p2rec` as given (438, 457..460, 403..405 for page 2). Remaining dependency
[inferred]: a kit loaded with machine 43, 48 or 52 on a track (made on a funcgen=1/test=1 build) would reach the
same records through 0x413db5fc - with funcgen=0 and test=0 no build of user slots can make such a kit.

## R3 Sample words in the kit
**Question** Where are the sound's sample words 17..24 (page 2's P9..P16) in the kit, and which index does
0x4011f3fa(value, track, index) take for them?
**Method** us0 base; SMPL pressed (snapshot), then knob A (TUN) turned (`--turn 0:5` x20, 8M apart); the
kit's 152 bytes of track 0 compared before/after (dtpeek 0x41255933); a second run from the same snapshot with
`--break 4011f3fa` (the break is live from the snapshot, so its first hit is the turn's first call). Repeated on
track SD (SD, SMPL; 3 tracks' bytes compared).
**Result** [measured, rytm-emu, 2026-10-10] BD: kit offset 16 (0x41255943) 64 -> 87, nothing else; the call
is `(0x4100, track 0, index 17)` from 0x400a9e5e (the sound parameter setter, which calls kit_param_changed at
0x400a9e6c next). SD: offset 152 + 16 (0x412559db) 64 -> 88, the call `(0x4100, 1, 17)`. So word 17 is at
0x41255933 + 152 t + 2 * (17 - 9): the sample words follow the machine words contiguously, and the setter's
index is the sound word number. Words 18..24 at +2 each [inferred: the same packing; only TUN turned].
**Consequence** Task 7: `US_SAMPLE_CONTIGUOUS 1` (kit word 17 + j at 0x41255933 + 152 t + 16 + 2 j, setter
index 17 + j). re/symbols.toml `[data.kit_track_words]`.

## R4 Runtime ranges
**Question** Do the knob, the p-lock and the LFO honour a record's range (+8 min, +12 max, +16 default, 8.8)
changed at runtime, and what does a stored word outside the new range do?
**Method** us0, PLAITS on BD (20 DOWNs, YES; snapshot at 10100M: kit P2 = 0x4000, 64). Record 409 (PLAITS
P2/HRM) at 0x401c4c2c reads min 0, max 0x7f00, default 0x4000; `--poke 401c4c38=00001400` (max 20) at the
resume. Knob B turned (`--turn 1:+-5` 1..20 times, 8M apart), kit word P2 read at 0x41255935 (dtpeek); p-lock:
RECORD, T1 held 250M, knob B up x20 (end PNG); LFO: LFO page, DST (knob D: 9 x +5, YES -> HRM), DEP (knob H)
+5 x40 (full), BD key presses for trigs, the Rytm's 0x03/0x04 reports (USB MIDI out, P2 = bytes 8/9 resp.
10/11) over 1600M; every run also without the poke as the control.
**Result** [measured, rytm-emu, 2026-10-10]
- Knob: max 20 honoured. Up x20: kit P2 0x1400 (20; control: 0x5700, 87); the popup shows 20. Down x20: 0.
  The first three turn events of a gesture do not move the value (also unpoked); the first that does
  clamps the stored 64 into the range: up or down x4 both give 0x1400 (control: 0x4100 / 0x3f00).
- P-lock: max 20 honoured - the lock shows 20 after 20 steps up (control: 83); the kit word stays 0x4000.
- LFO: NOT limited by the record's range. Stored 14 (knob turned down), DEP full on HRM: the reports' P2 swing
  0.0 .. 84.75 (control, stored 57: 0.0 .. 127.99): the LFO adds about +-70.75 to the stored value and only the
  full 0..127.99 clamp applies.
- A stored word outside the new range plays as stored until the knob moves: with max 20 and P2 = 64, trigs
  report P2 64.0 (two BD trigs, no turn); the knob dial is drawn as before; the first moving step clamps it
  to 20 and the reported value glides 64 -> 20 (0x03s 62.68 .. 20.0).
**Consequence** Task 8: the ranges stand as built for the knob and the p-lock. The LFO's behaviour is a limit to
document in design.md (an LFO on a user-slot parameter can drive it over the slot's range, up to 0..127.99; the
Teensy must clamp what it receives to its own ranges). Stored words outside a newly received range are not
clamped by the Rytm until the knob is touched: if the slot must never play outside its range, Task 8 clamps the
kit words (and the live copies, 0x4011f3fa) of the tracks on that slot when 1A/1B ranges arrive; otherwise the
Teensy's clamp covers it - Task 8 decides, the spec's "the Rytm clamps 1C values itself" does not cover it.

## R5 The track menu
**Question** In what order does TrackMenuView's constructor pass the item's std::functions to menu_item_ctor
(0x40072f50), and is the instruction pair after 0012's detour (0x400f9e9c) free for a second detour?
**Method** The stock disassembly 0x400f9b38..0x400f9ea0 (the plan's grep, and the whole constructor read);
`grep -c 400f9e9c build/mainos_emac.dis`; registry/allocations.toml; rytm-emu: a cold boot of us0 (the base's
startup keys) with `--break 400f9c94` (the first item's `jsr %fp@`), the stack and the four std::functions read
from the snapshot saved at the break (dtpeek), their invokers disassembled; `--count 400f9b38 --count 40072f50`
over FUNC (held 300M) + CHRO from the base.
**Result** [measured, OS 1.73 image and rytm-emu us0, 2026-10-10]
- The call: `pea 8; pea -1; movel %d2,-; movel %d3,-; d5 = sp+76; movel %d5,-; d4 = sp+64; movel %d4,-;
  movel %d0,-` (the 0x54-byte item from `pea 0x54; jsr 0x400829d4`), `jsr %fp@` = (item, d4, d5, d3, d2, -1, 8).
  At the break (a7 0x4196c514, boot clock 1369M): item 0x41bf6f40, d4 0x4196c55c, d5 0x4196c56c, d3 0x4196c57c,
  d2 0x4196c58c - four adjacent 16-byte std::functions (storage 8 B, manager +8, invoker +12): d4's invoker
  0x400f95e8 builds the string at 0x402585bb "TRIGS SETUP" (the label); d5's 0x400f9f0c allocates a 0x1b0-byte
  view and constructs it with 0x400dfa2e (the action: TRIGS SETUP's page); d3's 0x400f9688 tail-calls
  0x40071674 with the bitmap 0x419f2170 (the icon); d2 has manager 0 (empty). So `(item, label, action, icon,
  empty, -1, 8)`; relative to a7 at the call: label +0x48, action +0x58, icon +0x68, empty +0x78.
  (re/symbols.toml's track_menu_ctor note lists the stack objects as "label, action, an empty one, icon"; by
  argument the empty one is last.)
- 0x400f9e9c `4fef 0080 4e75` (`lea %sp@(128),%sp; rts`): one line in the disassembly, no branch or jump names
  it; the registry claims only 0012's detour at 0x400f9e96 (6 B, expect 4cef7c7c0018); 0012's stub rejoins at
  0x400f9e9c (CTOR_REJOIN in mods/0012-slice-loop/stub.s), so a detour there runs after 0012's item when 0012
  is in the image and directly after SAVE TRACK when it is not. The constructor's `this` is at sp + 132 there
  (entry sp + 4 = 104 + 24 + 4).
- The constructor runs once, at boot (break at 1369M in the cold boot); opening the menu from the base visits
  neither 0x400f9b38 nor 0x40072f50 (count 0): items are built at boot and kept; their label std::functions
  are what change a label afterwards [inferred: labels are drawn through the item's label function].
- Left open (not needed by the fallback): pushing a menu view of our own (spec open item 5).
**Consequence** Task 11 as written: a detour at 0x400f9e9c (6 B, expect 4fef00804e75), its items built with
(item, label, action, icon, empty, -1, 8); `U1 <name>` must come from the label std::function at draw time,
since the items are constructed once at boot, before any Teensy message.

## R6 Cave space
**Question** How much cave space is free for the user slots (~6.2 KB as built in the plan's trial: .us1 1856,
.us2 2600, .us3 818, .us4 380, .usd 402, .usr 158 B), and are 0006's and 0013's caves still theirs alone?
**Method** The plan's unclaimed-range script over registry/allocations.toml (caves, patches, detours; 0020-dmach
left out as mutually exclusive with 0021), then every claim intersecting cave3, cave4, cave5 and cave9 listed.
**Result** [measured, registry at b5aac67+, 2026-10-10]
- Free ranges of 16 B or more in all pools: only cave23 0x401b9e50, 26 B.
- 0006-comp-preview: cave4 0x40029060 1960 (.text), cave5 0x4002871c 224 (.tab) + 0x400287fc 536 (.ui),
  cave3 0x40289ab8 128 (.ring) + 0x40289b38 896 (.sc), 0x402ccfa8 88 (.aux), 0x402cdf94 108 (.state),
  0x401ba290 256/600/600 (.sat, gated by telem/cal). 0013-voice-dac: cave9 0x4001976a 2768 / 3424 (timing) /
  2976 (dbg), gated.
- The four caves' other claims lie outside 0006's/0013's ranges: cave4's tail 0x40029808..0x40029838 is
  0004-lfo-rnd's .kgate (48 B, after 0006's 1960), cave9's 0x4001a4ca..0x4001a718 is 0021's .exte 330 + .extd
  260 (after 0013's largest gate, 3424). No other mod claims any byte of cave4 0x40029060+1960, cave9
  0x4001976a+3424, cave3 0x40289ab8+1024 or cave5 0x4002871c+760: 7168 B.
- Decided by the user (2026-10-10): user-slot builds exclude 0006-comp-preview and 0013-voice-dac. Neither mod
  is in lp3n/hw1/us1; the default build keeps both (both stay hardware-verified); a build cannot have the
  compressor preview or the voice DAC together with Teensy machines. 0006's three small extra caves
  (0x402ccfa8 88, 0x402cdf94 108, 0x401ba290 up to 600) are further room if needed [inferred: same exclusion].
**Consequence** Task 4: 0021's mod.toml excludes 0006 and 0013; the user-slot sections claim cave4 1960, cave9
3424, cave3 1024 and cave5 760 (7168 B for ~6214 B), gated on the user-slot build as 0021's other claims are.

## R7 0023's mailbox
**Question** Does cave23 hold a 12-byte TDRV mailbox (a third word, td_pool_tab) without 0023 outgrowing it?
**Method** `m68k-elf-as -mcpu=5475 mods/0023-teensy-drive/stub.s; m68k-elf-size -A` (scratch object);
registry/allocations.toml's cave23 pool and 0023's claims.
**Result** [measured, 2026-10-10] cave23 is 0x401b9a72..0x401b9e6a (1016 B). 0023: `.tdm` 8 B claimed at
0x401b9a74, `.td2` claimed 980 at 0x401b9a7c (to 0x401b9e50; the 26 free bytes of R6 follow), 900 B as built.
`.tdm` at 12 B moves `.td2` to 0x401b9a80: the 980-byte claim ends at 0x401b9e54 <= 0x401b9e6a (22 B left),
the 900 B built end at 0x401b9e04.
**Consequence** Task 6: `.tdm` 12 B (magic 'TDRV', td_sysex, td_pool_tab), `.td2` claim moved to 0x401b9a80,
size 980 kept.

## R8 Stock with user-slot tracks
**Question** Does stock 1.73 take a working state with a track on a user slot (machines 35..39, spec 1.9) without a
fault, and does the build get the track back unchanged?
**Method** rytm-emu (df0f151's us1 build, base from `tools/emu/us_base.sh us1`): `tools/emu/us_emu.py us1 stock strict
poweroff` (stock: slot 1's 1A READY, U1 chosen on BD through the machine list, a 1C setting P2 to 99, `--power-off`
on a copy of the base's card; then a cold boot of stock 1.73 on that card, then a cold boot of us1 on it). The same
walk repeated for U2..U5 (walk +1..+4, slot n's 1A and 1C) with a local copy of t_stock (not committed). strict: the
names, labels and write-back flows under DTEMU_STRICT=1.
**Result** [measured, rytm-emu, OS 1.73 stock image and us1, 2026-10-10]
- Stock cold-boots the working state without a fault and shows track BD as DISABLE (machine byte 0x8000ea00 = 27;
  `build/emu/us1/stock-boot.png`, knobs greyed), P2's word (kit 0x41255935) kept at 99, for each of U1..U5.
- Back on us1, a cold boot of the same card: BD on the slot again with P2 99 - (35, 99), (36, 99), (37, 99),
  (38, 99), (39, 99) for U1..U5.
- strict: no `strict:` line. poweroff: PASS (a load is not a choice: P2 99, P9 50 kept through the cold boot).
**Consequence** Machines 35..39 join docs/FLASHING.md's "Projects saved under the mods, on stock" for the working
state only: stock treats a user-slot track as it treats the other mods' machines (DISABLE, words kept), the build
gets it back. Project load, copy/paste, the sound pool and the stock-machine reset are not re-checked for 35..39.

## R9 Name getters
**Question** Do the user slots need a hook in the machine-name getters (spec open item)?
**Method** None (not measured).
**Result** [inferred] Not needed: the user slots write the name table entries (0x401befa4 + 8 m, m 35..39)
themselves, the way 0014 and 0021 name their machines, so every getter reading the table sees the slot's name.
**Consequence** No getter detour; Task 7 patches the name table at runtime.

## R10 The transport
**Question** Does the Rytm's PLAY/STOP reach the Teensy on USB MIDI?
**Method** us0 base (TRANSPORT SEND on): PLAY at +100M, STOP at +600M, the USB MIDI out dump (us_emu.py,
`--usb-host --usb-midi-real`) searched for 0xFA/0xFC. Then TRANSPORT SEND switched off from the base (GLOBAL,
UP x4 to MIDI CONFIG - the GLOBAL menu reopens on SYSTEM -, YES, YES - SYNC reopens on TRANSPORT SEND -, YES,
NO x3; 0x407c2d32 read back 00) and the same PLAY/STOP (nothing committed: done in the test's own events, not
in us_base.sh).
**Result** [measured, rytm-emu, 2026-10-10] On: the dump is exactly `fa fc` (Start, Stop; no clock, CLOCK SEND
is off in the base). Off: nothing at all on USB MIDI out.
**Consequence** TRANSPORT SEND on (us_base.sh sets it): the Teensy sees Start/Stop. Off: no transport reaches it,
and plan 1's rule (a trig within 1 s counts as running) covers it. Tests that walk GLOBAL from the base must
start from SYSTEM (the menu reopens where the base's walk left it).

## R11 Persistence of a knob value
**Question** Where is the project's copy of the kit words (what the power-off's working state keeps), what writes
it on a stock knob turn, and what must a 1C write-back do so its value survives a power-off?
**Method** us0 base, SRC, knob B (encoder 1, BD PLASTIC's word 14) +5 x20: the kit (0x41255933) and the region
around the plan's 0x40765931 compared (dtpeek); `--watch` on the bytes that changed (DTEMU_NO_JIT=1); breaks
(from a snapshot taken after SRC) at the writer, its function's entry and its caller, at kit_param_changed
0x4003355c and at the setter 0x400a9d7e; the same diff for BD knobs A and H, BD SMPL knob A, SD knob B, RS, CY
and CB knob A; the record table read for the ids; a power-off (`--power-off`, on a copy of the card) 400M after
the turn and a cold boot on that card. Working-state range from rytm-emu docs/RYTM-PORT.md (0x405c8e10..
0x407c89cb).
**Result** [measured, rytm-emu, 2026-10-10]
- The project copy is NOT at 0x40765931 + 152 t + 2 k: track t's word w (9..24) is at
  **0x4076592f + 162 t + 2 (w - 9)** - BD word 9 (knob H) 0x4076592f, word 10 (A) 0x40765931, word 14 (B)
  0x40765939, word 17 (SMPL A) 0x4076593f; SD word 16 0x407659df (+162 + 14), RS word 10 0x40765a75
  (+2*162 + 2), CY 0x40765f85 (+10*162 + 2), CB 0x40766027 (+11*162 + 2). Each turn changes the kit word and
  this byte to the same value (BD B: 99 -> 123 in both) and nothing else in either region. It lies inside the
  working state; the kit (0x4125xxxx) does not.
- The chain of a knob turn: the sound parameter setter 0x400a9d7e (on SoundParameterSet t = 0x41b02580 + 0x1c t,
  whose +4 is the kit bank, +8 the track) calls 0x4011f3fa(value, track, index) (the live copy, return
  0x400a9e5e) and then kit_param_changed(bank, track, record, value) at 0x400a9e6c - here (0x41b41340, 0,
  0xd4 = record 212, 0x6400): the id is the RECORD number (212's +4 index is 14, the word that changed). The
  bank's drain 0x4003364a then calls 0x400aa8ce from 0x4003380e (11M instructions later), which writes the kit word (0x400aaa10, `movew %a1@,%a0@(0,%d1:l:2)`) and notifies the sound's
  observers (0x400aa9e2 -> 0x4019e0dc -> vtable +68 = 0x400bd3a6(src sound 0x41b01500, project sound
  0x40765913, ...)), which writes the project copy at 0x400bd458 (`movew %d2,%a3@(1c,%d5:l:2)`; project sound +
  0x1c + 2 (w - 9)).
- Corrected 2026-10-10 after the coordinator's cross-check (the first version said "kind >= 52 or the
  track's machine", and "a drain task 0x400333fa"; both wrong):
  - The gate is **kind == the track's machine, or kind >= 53**: 0x40006f18(id) returns 1 iff kind <= 52
    (unsigned compare with 52), 0x4000714a(id) returns the kind when <= 52, else -1 [read in the disassembly];
    [measured by the reviewer, rytm-emu: record 212's +0 poked, BD PLASTIC knob B turned] kind 0x15 (its own
    machine) written; 16 unchanged; 52 unchanged; 53 written; 60 written; the flush's gate alone confirmed with a
    break at 0x400a9e72. The same gate sits in the setter itself (0x400a9df8..0x400a9e4a), in front of both
    0x4011f3fa and kit_param_changed: with a wrong kind a stock knob turn on that record does nothing at all
    (no live copy, no kit word, no project copy). The word written is the record's +4 index (0x40006ea8).
  - The drain is not a task of its own: drain 0x4003364a has 9 call sites (0x400a2dae and the kit load/save
    paths 0x400b0606 .. 0x400b38a0); the knob's flush comes from 0x400a2dae, a UI-loop routine that runs the
    drain every 8th pass (counter 0x41943d70) on the bank from the getter 0x40194618(); 0x400333fa's loop never
    ran [measured by the reviewer]. The current task (owner word 0x42f67924 of the recursive mutex 0x40001124)
    is 0x41943f00 at the setter's kit_param_changed call, in param_value_text (where 0021's ext_ui_tick runs),
    in the drain and in the flush - one task, the UI task [measured by the reviewer].
  - So `0x4011f3fa` then kit_param_changed from ext_ui_tick is the stock route. kit_param_changed takes the
    recursive mutex at bank + 8: it must not be called from the MIDI task or an interrupt. Calling it from
    inside a render (ext_ui_tick runs in param_value_text) has no stock precedent [inferred safe: same task,
    recursive mutex].
- The bank pointer: the getter 0x40194618() returns it, creating the bank on first use (`tstl 0x419f29d8`,
  else allocates 0x11df4 B) and caching it at 0x419f29d8, which held 0x41b41340 in two boots [measured].
- Power-off: the stock turn survives it - kit word 14 0x63 -> 0x7b, power-off 400M later (handler 13M
  instructions, slot 0x7a000 written), cold boot on that card: kit 0x41255933+10 and project 0x4076592f+10
  both 0x7b. The plan's trial (a 1C writing only the kit word and 0x4011f3fa) lost its value because neither
  write reaches the project copy: the kit word is a copy the drain writes, not a source.
- (review, 2026-10-11) All of R11 ran on pattern A01, kit 0. The kit word is the active kit's,
  0x41255933 + 2531 k + 152 t + 2 (w - 9), k = 0x800067b8 (0..127): on A02 (k = 1) the drain wrote kit 1's words
  and kit 0's stayed [measured]. The project copy is one working copy, the active kit's: a kit switch rewrites its
  twelve tracks, and the power-off saves it as that kit [measured]. See E2E bug 2's "Kit 0 only".
**Consequence** Task 10 (both the 1C write-back and JUNO's 15): replace `KIT_WORD` + `SET_PARAM` by the stock
pair, from ext_ui_tick (the UI task) only - `SET_PARAM(value, t, w)` (0x4011f3fa) and `US_COMMIT` =
kit_param_changed 0x4003355c with `(bank, t, record, value)`, bank = the getter 0x40194618() (the stock route;
not the cached static 0x419f29d8), value 8.8 in the low 16 bits. The plan's `US_COMMIT(value, track, index)`
signature is wrong: the call takes the bank first and the RECORD number, not the word index. The record being the track's record for word w (0x413db5fc[8 m +
w - 9] for 9..16, the page-2 records for 17..24) - which also feeds the kit save (the bank's changed bitmap).
For that - and for a stock knob turn on a user slot to do anything at all - every taken-over record's +0 kind
must be the slot's machine (35..39) (or >= 53) and its +4 the word: Task 7 writes the slot's machine into +0 of
every record it takes over, page 2's included (stock: 438 kind 48, 403..405 kind 43, 457..460 kind 52 - 52 is
NOT enough).
Fallback if a call from the UI tick is unwanted: write `US_PROJ_WORD(t, w)` = 0x4076592f + 162 t + 2 (w - 9)
with the kit word (US_PROJ_BASE 0x4076592f, stride 162 - not the plan's 0x40765931/152); that persists through
a power-off but not into a kit saved to the +Drive [inferred: the kit save reads the bank].

## R12 Where the user chooses a machine (Task 11)
**Question** Which stock path is the user's choice of a machine (the machine list's YES), so a user slot's 1A defaults
can go onto P1..P16 then and never on a kit or project load (the user's decision, 2026-10-10)?
**Method** The stock disassembly (callers of sound_param_id_for_index 0x40007028, of 0x400bcbac and of 0x400bd14e);
rytm-emu us1 (db7d6ac+), `--count` on 0x400bcbac, 0x400bd14e, its callers' return addresses (0x400a6902,
0x400b2df2, 0x400b2f60, 0x400bee46, 0x40103312), 0x400b39bc and 0x400bd1ee over: the list opened and 15 DOWNs to
U1; the same and YES; the same and NO; a cold boot of the base's card; then every function entry in
0x400d3000..0x400d6000 and 0x400dd000..0x400e1000 counted over the same three walks (DOWNs, + YES, + NO);
`--break 400bcbac` after one DOWN (registers, stack).
**Result** [measured, OS 1.73 image and rytm-emu us1, 2026-10-10]
- 0x400bd14e is set_machine(sound, machine, track, flag) (the track is its third argument at every call site
  read: 0x400a68fc, 0x400bee42, 0x4010330c); when the machine changes it calls 0x400bcbac(sound), which writes
  the defaults of sound indices 9..16 only (0x40006e8a/0x40006e8e return 9 and 16; default from the record via
  0x40006ff0, then the sound's change notification) - P1..P8, never the sample words 17..24.
- Every DOWN previews: the list's cursor callback 0x400d40a4 calls 0x400bed62(sound, step, track, 1), which
  calls set_machine at 0x400bee42: 15 calls of 0x400bcbac for 15 DOWNs (break: sound 0x41b01500, BD, UI task
  prio 6). YES adds nothing (15 with or without it); NO adds one set_machine through 0x400a68a2 (from the
  confirm window's cancel function 0x400d337c, which then restores the old P1..P8 with 0x400bcb4c from the
  16 bytes it kept). A cold boot: 0 calls of either.
- Both keys close the confirm window through 0x400dea82(window, yes): yes = the second argument's low byte
  (`moveb %fp@(15),%d2`); YES branches to 0x400deaf6 (CONFIRMED!), NO invokes the cancel function (+448/+460).
  Counted: 0x400dea82 0 / 1 / 1 (DOWNs / YES / NO), 0x400deaf6 0 / 1 / 0.
- 0x400bee40 `2f02 4eba e30a` and 0x400dea8e `246e 0008 2f0a` are whole instructions no branch enters (the one
  branch to 0x400bee40 lands on the detour's start).
**Consequence** Task 11: the cursor's set_machine call notes its track (detour 0x400bee40), the window's close
takes the note on YES (detour 0x400dea8e, past the prologue: d2 = yes) - a choice is a confirmed list. P1..P8
already come from the records when the slot's 1A is current; P9..P16 are 0021's, written only on YES, so a
preview passing a user slot leaves the sample words alone. Kit and project loads do not pass the list.

**Review follow-up (Task 11 review I1, M1, M2; 2026-10-10)** [measured, rytm-emu us1, `--count`, machine byte
0x8000ea00, us.ch, PNGs; read: OS 1.73 disassembly]
- The list's class: MachineListView's constructor 0x400def0a (it names itself "MachineListView", 0x40257a1e) has one
  call, 0x400d3f5a; the close 0x400dea82 is called from 0x400d3e94, 0x400d41a8, 0x400deb5c, 0x400deb86 and 0x400df4bc,
  all the list's own code [read]: no other window passes it.
- Leaving the list (BD, U1 previewed by 15 DOWNs; counts of 0x400dea82 / 0x400deaf6 / 0x400a68a2, then the machine):
  SRC, FLTR, AMP, SMPL, TRIG, FUNC + NO: 1 / 0 / 1, machine back to 21 (NO's path); a track pad (SD): 2 / 0 / 2, back to
  21; LEFT, RIGHT, PLAY, FUNC + FLTR: 0 / 0 / 0, the list stays open. GLOBAL (then NO, or GLOBAL again, or NO and YES)
  and FUNC + CHRO (the TRACK menu, then NO, or NO and YES): 0 / 0 / 0, the list is gone (the main page after the menu
  closes; the constructor ran once), **machine 35 kept, us.ch still 1**: the list can be left without its close, the
  preview staying as if confirmed (stock keeps that machine's P1..P8 reset, P9..P16 untouched, as 0021 keeps them).
- The other caller of 0x400bed62, 0x400ef678 (return 0x400ef67e), is the action 0x400ef63a of the SOUND menu's
  MACHINE item (SoundSetupMenuView 0x400eeec2, title SOUND, item label MACHINE 0x4024c3e8; opened by FUNC + FLTR on
  tracks 0..11: the constructor's call 0x400cccd4 on key 0x33): `bed62(sound, step, track, 1)` with the step from
  LEFT/RIGHT. 3 RIGHTs: 0x400ef63a 3, 0x400bed62 3, set_machine 3, **0x400bcbac 3** - stock resets P1..P8 on every
  step; YES there does nothing. From BD PLASTIC the steps go 22, 26, 30, ... and 15 RIGHTs land on U1 (the list's
  order). A step onto U1..U5 always changes the machine: 0x400bed62 keeps the machine only at an end of its list
  (DISABLE .. DAISYSP), where no slot is [read].
- Loads: all 4777 `jsr` targets of the image counted over idle (1500M), a choice (15 DOWNs, YES, a knob turned), RELOAD
  KIT (FUNC + PLAYMODE, YES) and LOAD KIT (K002); 42 ran in both loads and in neither idle nor the choice. Counted
  further over SAVE KIT, a pattern change (BANK_A + T2: A02 has another kit) and LOAD PROJECT (GLOBAL, PROJECT, LOAD
  PROJECT, 002, NO to saving, YES): **0x4011f6bc** runs once in RELOAD KIT, LOAD KIT, the pattern's kit switch and
  LOAD PROJECT, never idle, in a choice, a knob turn, a SOUND-menu step or SAVE KIT. Its callers: 0x4011f906 (the
  routine 0x4011f89e that applies the kit to the twelve tracks, stride 152: RELOAD, LOAD PROJECT), 0x40120af0 (the
  engine's check of the kit index 0x800067b8 against the applied one 0x8000fc8c: a kit switch), 0x400afb30. It
  copies thirteen 5-byte entries from kit + 1950 into SRAM 0x8000ebbe / 0x8000ec7c [read]. Rejected: 0x400a6538 (it
  also runs on SAVE KIT), the drain's call sites (several per load, and the UI loop's). The call 0x40120af0 lies
  inside the audio interrupt's handler (the one ending 0x4012165e) [read, f19aaad re-review]: on a pattern's kit
  switch us_loaded runs from the audio interrupt, otherwise from the UI/load context. So us_loaded must stay
  interrupt-safe (byte stores only: a load generation `us.lgen` moved on, then each track's `pslot` cleared), and
  us_tick3, which may be interrupted between its checks and the commit, reads `lgen` before its checks and again,
  with the track's machine byte, just before writing the defaults (pslot read volatile) [inferred: the interleaving
  is not reproduced in the emulator; the load test still passes with the generation in]. A window of a few
  microseconds remains (an interrupt kit switch after the re-check or while us_defaults writes P1..P16): accepted;
  whether the ISR's kit switch rewrites the track words at once at all is not measured.
  **Narrowed (2026-10-11, review LOW-1/LOW-2).** us_defaults takes us_tick3's generation `g` and, inside its IPL-7
  mask, writes the tag (kit word, live word, and now the project copy's two bytes too) only if `us.lgen` is still
  `g`, the track still plays the slot, and the kit word 0x800067b8 equals the applied kit 0x8000fc8c. 0x8000fc8c has
  three accesses in the image [read]: -1 at init (0x4011fa3c), the audio interrupt's compare with 0x800067b8
  (0x40120ad6), then 0x4011f6bc (us_loaded) and the store of 0x800067b8 into it (0x40120afc). It is the kit the
  engine last applied. They differ from the UI task's 0x4011f82a (the kit set) until the next audio block. Measured
  (us1, `tagkit1`): 0 and 0 on the base, 1 and 1 on A02 after the switch. So a switch that lands during the sixteen
  us_set calls can no longer send the tag to the new kit's track. The P1..P16 words of that choice still go through
  us_set, as before; the drain writes the kit active when it runs [inferred from R11].
- The window's clock: DTIM2 counts DTIN, which rytm-emu models at 12.288 MHz by assumption (src/machine.rs,
  rytm_bootstrap_state), so its rate cannot be measured there, and as a 32-bit counter it wraps every ~349 s anyway.
  SRAM and DDR diffed over one emulated second (200M instructions): **0x419ca2ac** +1500 (`addql #1,0x419ca2ac` at
  0x401214f8, once per audio block; read at 0x4011fae2, 0x4011fb56) and 0x419ca0c0 +48000 (`addl %d0,0x419ca0c0` at
  0x4012160c, the block's samples): 32 samples a block at 48 kHz; at boot + 37 s it held 55421 (= the audio interrupt's
  count) and 1773472. 32-bit: 1500 a second wraps after 33 days. (0x8000e1c8 also moved by 48000, but it is a ring
  position masked to 19 bits, 0x4010e82e: ~11 s.)
**Consequence (review)** The list's note is cleared when the list opens (the constructor call 0x400d3f5a patched to
us_open_thunk), so a list left by GLOBAL or the TRACK menu leaves nothing for a later list's YES (emulator test stale:
with the clear removed, YES with no cursor move gave BD P9 33 and P12 44 from that old note). The cursor's call is told
from the SOUND menu's by 0x400bed62's return address (sp + 64 at the detour): 0x400d40da notes, 0x400ef67e chooses at
once (us_pend; test sound: 15 RIGHTs, 0x400bcbac 15, P1..P16 the defaults). A choice still waiting when 0x4011f6bc
runs is dropped (detour us_load_thunk -> us_loaded; test load: U1 chosen with no Teensy, SAVE KIT, RELOAD KIT, then
the 1A: BD keeps the loaded words, where without the hook it took the defaults). The wait is measured in audio blocks
(0x419ca2ac, 90000 = 60 s; test window: the 1A 90100 blocks after the choice - no defaults, 80000 - defaults).

## R13 DIN SysEx goes through the same task as USB SysEx (2026-10-11)

The 1C seqlock (`us.wb`: wseq written by the MIDI task only) and JUNO's 15 seqlock (`jn_mailbox.pend`) assume one
writer. They are fed by 0022's router at the SysEx router's entry (0x40083d6c, `looper_router`), which does not
look at the interface, so a message that arrives on DIN goes in the same way. Measured in rytm-emu (us1 at this
commit, the base of `tools/emu/us_base.sh`): the 13-byte 1D `F0 7D 52 54 1D 01 07 08 09 0A 0B 0C F7`, once on DIN
MIDI in (`dtboot --midi-file`) and once on USB MIDI (`--usb-midi-file`), each from the base, 300M:
- Both runs: `looper_router` 1, `looper_sysex` 1, `us_sysex` 1, `us_slots_in` 1 (`--count`), and `us.tgen`,
  `tinst`, `seen` = 07 08 09 0A 0B, 0C, 01 afterwards (dtpeek). The Rytm takes a Teensy message from DIN as from USB.
- `--break 0x40025c24` (looper_router): DIN - a7 = 0x418fcc2c, return address 0x40082db2, args (0x4185823c, 13,
  interface 8); USB - a7 = 0x418fcc2c, return 0x40082e38, args (0x42f6a02c, 13, interface 2). Both come from one
  dispatcher (the pc history runs 0x40082ad4 .. 0x40082ae8 -> 0x40083d6c in both), on the same stack at the same
  depth: one task, with its USB and DIN branches (0x40082dda.., 0x40082d56..) called one after the other.
So the single-writer assumption holds for both ports [measured in the emulator; on hardware it follows from the
same code, untested]. Two consequences: a DIN device that sends `F0 7D 52 54 15..1D` is taken as the Teensy (no
port filter; harmless for a real setup, where only the Teensy speaks this protocol); and the timing (a DIN SysEx
and a USB SysEx interleaved byte by byte) is the firmware's own reassembly per port, not modelled beyond what
rytm-emu does.

## R14 A 1E answer with a stale generation (2026-10-11)

A Teensy that rebooted while the Rytm stayed powered counted generations from 1 again, and a 1E's answer could name
the previous machine's generation. The Rytm's cache could then hold the OLD machine under the number the 1D answer
gives: READY with that generation made us_tick3 apply the old cache's defaults and fp at once (cache gen == tgen,
state READY). The Teensy side is fixed in rytm-teensy (f5bda38 H1: a READY or LOADING answer carries the slot's next
1A's generation; 3646edf M1: the generations start from a boot seed). Rytm-side hardening (the Teensy agent's
proposal, preferred over clearing `h.gen`, which would also blank the item label and the menu's `live` check):
us_menu_action, on an assign (op 0) answered READY or LOADING, notes the slot's cache generation at that moment in
each pended track's `us_wb.pgen` (a new byte; `struct us_wb` 26 -> 28 B, `us_wb_pgen` 22, `us_wb_size` 28), and
us_tick3 also waits while `c->h.gen == pgen`. During us_wait the UI task is in the menu, so no 1A commits before
the note: pgen is the old machine's generation. us_pend clears pgen, so the machine list's YES and the SOUND menu
step keep the old rule. An assign of the same machine cannot happen (YES steps to the next installed one); at worst
a pend runs out after US_PEND_WINDOW (60 s), which only means no defaults. Emulator `assigngen`: SINE TEST (gen 5,
FP_A) on BD, P2 written back to 99, the assign answered READY with generation 5 - BD keeps P2 99 and word 0 FP_A,
pslot 1, pgen 5, the label SINE TEST; then the 1D and the 1A of V2 TEST at generation 6 - P2 77, P1 64, word 0
FP_B, pslot 0. Without the `c->h.gen == pgen` condition both checks fail (P2 20 and the label !V2 TEST: the old
defaults and the old fp went in) [measured].

## R15 Heap headroom (2026-10-11; spec 1.6 "to measure")

The firmware's allocator 0x40082758 (mem_new 0x400829d4 is its thunk) is a binary buddy allocator in 16-byte units
[read, the disassembly]: its state at 0x40285830 holds +0 the init flag, +4 the arena's base, +8 a bitmap, +12 the
array of free-list heads by order (a block's unit index, -1 none), +16 the top order, +24 the number of live
allocations; a request is rounded up to 16 << order (`ff1` on n - 1), a free block holds its previous and next unit
index at +4 and +8 and its size at its end, and 0x400825c0 frees and merges. Walking the free lists in rytm-emu
(us1, led.img's project, 2026-10-11) [measured]:
- the base snapshot (booted, settings walked; `us_init` done: `us.c[0..4]` 2 KB apart from 0x41bffb40): arena
  0x41ac1340, 16 MB (top order 20), 13914 live allocations, free 13 880 896 B in 28 blocks, the largest 8 MB
  (orders 19, 18, 16, 13, 12, 11, 10, ...);
- after a 1A for each of U1..U5, U1 chosen, its preset list and a pool knob (0023's pool table, `td_pool`
  0x41c1d340): 13920 allocations, free 13 876 560 B, the largest 8 MB.
The user slots take 11 KB of it (five slot caches of 1524 B, each rounded to 2048; the 488-byte staging buffer and
the 336 bytes of write-backs, each rounded to 512), 0023 its pool table (2304 B -> 4 KB) and, while the TEENSY
folder is browsed, its 16 KB listing. The project's own data (the 128 kits at 0x412558e3, the sound pool at
0x41313c47, the project copy at 0x40765981) lie outside the arena [read: fixed addresses], so a fuller project does
not draw on it [inferred]. `us_init` checks each allocation: without the staging buffer no 1A is committed (the
slots stay `USER n`); without the write-backs no 1C is applied and no choice gives defaults (us_pend, us_loaded and
us_tick3 skip it); without a slot's cache that slot shows `USER n` and numbers. None of it faults; with ~13 MB free
none of it is expected.

## Consequences for the implementation tasks (findings that differ from the plan)
- R1 -> Task 7 and every emulator test that breaks: US_THUNKS 0 stands, but the plan's functor for record 449
  is 0x419adbf0 (not 0x419ad6a0), and `--break-after` does nothing with `--load` (break from a snapshot taken at
  the moment wanted). Single `--turn ENC:1` steps may not move a value; the first three events of a gesture
  never do (R4): turn with +-5 and enough events.
- R4 -> Task 8 / design.md: the LFO ignores a record's runtime range (up to 0..127.99); a stored word outside a
  newly received range plays as stored until the knob moves - Task 8 decides whether to clamp the kit words
  (and live copies) of the tracks on a slot when its ranges arrive.
- R5 -> Task 11: TrackMenuView's items are built once at boot, so `U<n> <name>` comes from the label
  std::function at draw time.
- R10 -> tests walking GLOBAL from the base: the menu reopens on SYSTEM, SYNC on TRANSPORT SEND.
- R12 -> Task 11: the user's choice is the machine list's YES (detours 0x400bee40, 0x400dea8e) or a SOUND-menu
  MACHINE step (0x400bed62 called from 0x400ef678); the defaults of P9..P16 are 0021's to write (0x400bcbac writes
  P1..P8 only); the list's note is cleared when it opens (0x400d3f5a), a waiting choice dropped on a load
  (0x4011f6bc), the wait timed in audio blocks (0x419ca2ac).
- R11 -> Task 10: the project copy is 0x4076592f + 162 t + 2 (w - 9) (not 0x40765931 + 152 t + 2 k); the stock
  commit is 0x4011f3fa then kit_param_changed(bank, t, record, value) with bank = 0x40194618() - not the plan's
  US_COMMIT(value, track, index) - called from ext_ui_tick (UI task) only, never the MIDI task or an ISR.
- R11 -> Task 7: the setter and the drain act on a record only when its kind is the track's machine or >= 53,
  so every taken-over record (457..460 too, kind 52 in stock) gets the slot's machine (35..39) in +0 and the
  word in +4; otherwise a knob turn on a user slot does nothing.
- R2 (note): the search missed the `pea #n` forms; `pea 0x194` (0x4003b616, 0x401a309c) and `pea 0x1cc`
  (0x4012a298) are operator-new sizes - the conclusion stands.
- R10 -> tests: poking 0x407c2d32 = 0 does NOT stop the fa fc [measured by the reviewer]: switch TRANSPORT
  SEND off with the menu walk.

## E2E with the Teensy (2026-10-10)

rytm-emu's window (`tools/emu/us_window.py`, headless, USB MIDI ports open) against the real Teensy over
rytm-teensy's `sim/teensy_bridge.py` (branch worktree rytm-teensy-us, serial voiceloop f5c1c12, 4 MB store, project
PRESETS). Firmware us1 = 0014 (variants=1, funcgen=0, test=0) + 0021 + 0022 + 0023 at b225fd5; `verify.py --tag us1`
PASS; base from `us_base.sh us1` (project name PRESETS, as the Teensy's). Installed (store order, which the slot
menu steps through): befaco.np.a, np.atari, np.b, np.c, rytm.fault_test, rytm.sine_test, rytm.state_test,
rytm.v2_test. At the start U1 = sine_test, U2 = fault_test in PRESETS (not EMPTY as the plan assumed). Fingerprints
(protocol.plugin_fp, as on the wire): v2_test 12437 (0x61 0x15), sine_test 716, fault_test 11133 (0x56 0x7d).
Screenshots in build/emu/ (git-ignored). All [measured] unless marked.

### Changes to the plan's procedure

- **`--ob-link` in us_window.py.** The bridge reads the Teensy's serial stream (its 'X' SysEx for the Rytm - 1A,
  1B, 1D - and its log lines) only inside its Overbridge-link loop; without the window's link it forwards reports
  but returns nothing (no names). With `--ob-link` the window's link closes with it, the bridge exits, so it is
  started again per step (`teensy_bridge.py` waits for the ports, ~1 s after the window opens). The other flags
  matched rytm-emu's CLI (`src/bin/rytm.rs`); no rytm-emu change.
- The bridge needs `sim/juno/build/libjuno.dylib` (obhost imports it): built in the worktree with
  `sim/juno/build.sh` (git-ignored).
- **A trig before a knob report.** ext_render runs only while a voice sounds, so a knob turned on an untrigged
  track sends no 0x03: the preset and pool steps press BD first.
- **Knob turns as several events.** One `TURN:0:1` or `TURN:0:4` event moved nothing (the encoder's first
  events only show the value, as us_emu's R4 note says); 3-5 `TURN:E:1` events 200 ms apart move about one step
  each.
- **The presets.** rmp_e2e's step 8 removes its presets afterwards, so none were on the card: Bright.txt (P2 120
  P3 30), Dark.txt (P2 40 P3 5) and Wide.v2p put into /PRESETS/rytm.v2_test/ with rmp_install for steps 5-6,
  removed at the end.
- **A 1D for the slot menu (see finding 1).** Each window run starts from the base snapshot, made without a Teensy,
  and the Teensy never pushes a 1D to it. For the runs that need one, a /tmp copy of the bridge (not committed)
  sent one rmp_install 'U' frame 0.5 s after the link came up - U5 set to state_test or cleared, alternately
  (assigning a slot its current machine is "unchanged, already loaded": no 1D) - so the Teensy pushed a real 1D.
  The same copy printed the SysEx in both directions (the excerpts below).

### Steps

1. **Helper alone** (no bridge): `w0.png` TRACK menu, `U1 ?` highlighted after SAVE TRACK - as the plan.
2. **Prepare**: the Teensy as above; `rmp_install.py info` lists the 8 packages under store.pkgs.
3. **Names arrive** (`e2e-1.png`): SRC SRC + 15 DOWNs - the machine list at `SINE TEST` (the Teensy's U1; the
   plan's `USER 1 ---` was for an empty U1). The Rytm asks 19 what 0 for U1..U5 and gets the 1As
   (`R->T 7d5254190101000000`, `T->R f07d52541a01010e00 01 00 03 02 "SINE TEST" ... 05 4c`). No `slots` log line
   on this Teensy build.
4. **Assign U1 = V2 TEST from the slot menu.** Without a 1D, YES asks 19 what 3, the Teensy answers 1B (installed
   generation 0x0a, 8 names), and no 1E follows: `us_wait(-1)` needs `us.seen` and `lgen == tinst`, both from a 1D
   (finding 1); no popup by 8 s (`e2e-2b.png`, the 2 s wait ran out; the NO TEENSY popup was not caught). With the
   1D: YES sends 10 PRESETS + 1E (`7d52541e010100060a`: U1, op 0, entry 6 = state_test), the Teensy answers BAD
   ("rytm.state_test needs 20000 B state, the voice has 16384": it cannot load without PSRAM). The next run's YES
   sends entry 7: `plugins: U1 = rytm.v2_test 1.0.0`, `U1 answered 0 (9 ms after the 1E)`; `e2e-2e.png` the
   READY popup 1 s after YES (the item still `U1 !STATE TEST`: the menu draws no value text, so the cache's
   1A is not fetched while it is open); the next run `e2e-2.png`: `U1 V2 TEST`. Two runs, not one per entry:
   the step started from U1 = sine_test.
5. **The machine, a preset, the knobs.** U1 chosen on BD (`CONFIRMED!`, `e2e-3-8.5.png`); the SRC page reads PRE
   LEV TON DET SMP MOD JMP GAN. BD's trig: `R->T 7d525404 50 3c 7f 0000 6400 4000 4000 ... 7f00 3c00 0f00 ... 61 15`
   (U1, V2 TEST's defaults LEV 100, TON/DET 64, GAN 127, ROT 60, SPR 15, and V2 TEST's tag),
   `teensy: trig voice 0 U1 rytm.v2_test note 60`. PRE turned (4 events) with the presets on the card:
   ```
   teensy: preset voice 0 U1 0 Bright (written back, 180 us)    T->R 1c 01 00 01 02 01 78 02 1e   (LEV 120 TON 30)
   teensy: preset voice 0 U1 1 Dark (written back, 132 us)      T->R 1c ... 01 28 02 05          (LEV 40 TON 5)
   teensy: preset voice 0 U1 2 Wide (written back, 159 us)      T->R 1c ... 01 5a 02 3c          (LEV 90 TON 60)
   ```
   The 0x03s show P2/P3 gliding to each written-back pair; the next trig carries LEV 90 TON 60 (P1 went to 4,
   clamped to the last entry, Wide). `e2e-3.png`: LEV and TON at Wide's values. PRE's value text: `2` without a
   1D (`us_tick` keeps re-asking the slots' 1As, `wait[s]` 200, which blocks `us_preset_text`'s 19 what 2 -
   finding 1 again); with it the Rytm asks 19 what 2, gets 1B 0x20 (Bright, Dark, Wide) and `e2e-3-pre.png` reads
   `Wide`.
6. **A pool knob** (`e2e-4.png`): SMP turned to 2 reads `Kick02-` - pool slot 2 from the Teensy's 14 table
   (answer to the Rytm's 13: slots 1..5 Kick01-DNBR .. Kick05-DNBR; boot log `pool /.rytm/pools/PRESETS.txt: 5
   slots`), cut to 7 characters. Turned to 6 (one more event) it reads `---`: slot 6 has no name.
7. **A fault shown as !NAME.** U2 was already FAULT. U2 on BD (16 DOWNs, YES), knob A up (P1 94), BD:
   `R->T 7d525404 58 3c 7f 5e00 ... 56 7d`, `teensy: trig voice 0 U2 rytm.fault_test note 60`,
   `teensy: plugins: U2 rytm.fault_test timed out - muted` (the plan expected "CRASHED - muted": this build reports
   the watchdog timeout), then a 1D (`T->R f07d52541d011311...`, U2's generation moved) and U2's 1A in state 6 with
   fp 0. `e2e-5.png` the FAULT page (MOD P2..P8); the next run's machine list (`e2e-6.png`): `!FAULT`.
7b. **The sound tag end to end.**
   - *Match*: U1 = V2 TEST chosen on BD with YES, BD trigged: the 0x04 carries 0x61 0x15 = 12437, the Teensy plays
     it (`trig voice 0 U1 rytm.v2_test note 60`), no mismatch line (step 5's runs, every one).
   - *Mismatch, the Teensy's slot changed behind the Rytm* (`e2e-7b.png`): as above, then at ~8.5 s the slot is
     set to sine_test on the Teensy (a 'U' frame, as rmp_install or another project's map would), BD trigged again:
     `teensy: trig voice 0 U1 rytm.sine_test: sound tag 12437, the slot's 716 - silent until a matching trig`;
     the machine list then shows `!SINE TEST` (the kit word 12437, the slot's fp 716).
   - *Reassigned from the slot menu* (`e2e-7a.png`): U1 = V2 TEST chosen on BD and trigged, then the slot menu's
     YES seven times (menu closed between them: the label, and so the next entry, only refreshes outside the menu;
     the menu keeps its cursor, so only the first opening walks 4 DOWNs): cleared, np.a, np.atari, np.b, np.c,
     fault_test, sine_test, each `answered 0`, BD trigged after each. Every trig keeps V2 TEST's tag and is
     silenced, for each machine:
     ```
     teensy: trig voice 0 U1 befaco.np.a: sound tag 12437, the slot's 11572 - silent until a matching trig
     ... np.atari 3424, np.b 15853, np.c 14426, fault_test 11133 ...
     teensy: trig voice 0 U1 rytm.sine_test: sound tag 12437, the slot's 716 - silent until a matching trig
     ```
     while P1..P8 do take the new machine's defaults (64 each) and the machine list shows `SINE TEST` without
     '!'. So the user's expectation held on the hardware - BD's sound still carries V2 TEST's tag and the Teensy
     stays silent - but not the `!NAME` part, and not by design (finding 2).

### Findings

1. **No 1D for a Rytm that comes up after the Teensy** [measured; the hardware case inferred]. The Teensy pushes a
   1D only when its meta changes (`rmp_meta_take`: once at boot, then on a slot or store change); a 19 ask is
   answered with a 1A or 1B, never a 1D, and a repeated 10 for the same project sends nothing. A Rytm that starts
   (or reconnects) while the Teensy runs has `us.seen` = 0 until some slot changes: the slot menu's YES always ends
   in NO TEENSY (no 1E is sent), and us_tick keeps re-asking every slot's 1A (`wait[s]` 200), which also starves the
   preset-name ask (PRE shows the number). The spec's "lost 1A/1D messages are caught up without a push" (3.2)
   holds for 1A only. Here every window run hit it (snapshot base); on hardware it would hit a Rytm power-cycled
   while the Teensy stays up, and the serial bridge loses even the boot 1D (`wait_ready` drops 'X' frames).
   Possible fixes (not made): the Teensy answers a 19 what 3 (or any 19 while it has seen no 1E/10 from this
   Rytm) with a 1D too, or the Rytm accepts the 1B's installed generation when no 1D came.
   **Fixed on the Teensy (rytm-teensy a55fe50, 8fdbc0e; c29a05c):** every 10 <project> and every 19 what 3 makes a
   1D owed (sent at most once a second), and a 1D goes out when the last is 5 s old.
2. **The slot menu's assign leaves the trig's tag stale** [measured in the window with the Teensy and in dtboot].
   us_defaults writes the kit's live word 0 and the project copy, but a track that has trigged keeps the old tag in
   the per-trig array 0x8000e5b0 + 84 t: the next trigs report it (the Teensy mutes a correctly retagged sound),
   and us_tick3 shows no '!' because it compares the kit word, which is right. Reproduced in rytm-emu with the
   injected messages of us_emu's `assign` test plus one BD trig before the assign: after the assign word0() =
   (FP_B, FP_B) but 0x8000e5b0 = FP_A, and the next trig's 0x04 carries FP_A (without that earlier trig the array
   was 0 and the next trig copied FP_B: what the `assign` test covers). So a trig does not always copy word 0 into
   0x8000e5b0, contrary to us_defaults' comment; the machine list's choose and the SOUND menu's MACHINE step work
   because they change the track's machine (the firmware re-copies the sound) [inferred]. The `assign` test checks
   word0() only. Fix (not made then; made 2026-10-11, below): us_defaults also writes 0x8000e5b0 + 84 t's word 0 under the same mask, plus a
   test that trigs before the assign.

   **Cause, measured (us1, rytm-emu, DTEMU_NO_JIT=1, 2026-10-10).** The inference above was wrong: no writer path
   works on a track that has trigged, the machine list's choose included.
   - What writes the array: `--watch 8000e5b0` (with DTEMU_STRICT=log for an exact pc) saw one write in the whole
     reproduction: memcpy's `moveml` (0x40098b70), at the first BD trig after the base. Its caller (by `--count` on
     every call site's return address): the audio interrupt's trig loop over the tracks (0x4011fe92 on) at
     0x40120678 -> 0x4011f558(kit sound, t) -> 0x4011da62(sound + 0x14, t): memcpy of 84 B to 0x8000e5b0 + 84 t and
     to 0x8000f7a8 + 84 t, the smoothing state 0x8000ee84 + 168 t, 0x80005f10 + 84 t cleared.
   - When: 0x4012062e copies only if the track's kit index (0x42ade134[...]) is not 0x8000fc58[t] (the kit last
     copied for t, an int) or the byte 0x8000fe30[t] is set; it then stores the kit index in 0x8000fc58[t] and clears
     the byte (0x401206da/0x401206e6). A sound-lock step copies the pool sound and stores -1 there (0x401205e2), so the
     step after it re-copies the kit; a kit load stores -1 for all twelve (0x4011f8da, in a loop). Watched during a machine
     list choose: neither 0x8000fc58 nor 0x8000fe30 is written; the base's BD had never trigged (0x8000fc58[0] = -1
     from the boot), which is why a choose before the first trig looked right. P1..P16 still change because each
     knob goes through its record (0x4011f698 writes 0x8000e57c + 2 index); index 0 has no record.
   - Reproduced before the fix (new tests): `assigntrig` (BD on U1 FP_A trigged, the assign to V2 TEST FP_B, BD
     again): tags 0x74d, 0x74d, word 0 (FP_B, FP_B), 0x8000e5b0 0x74d. `choosetrig` (BD trigged on its stock machine,
     then U1 with FP_A): the machine list's YES, the SOUND menu's MACHINE step and the delayed 1A all sent tag 0.

   **Fix (made, b4a8f74; replaced 2026-10-11).** us_defaults stored -1 in 0x8000fc58[t] inside the IPL-7 mask, so
   the next trig re-copied the whole kit sound. Wrong (review HIGH 1): us_set writes the live array at once
   (SET_PARAM 0x4011f3fa) but only queues the kit words (US_COMMIT 0x4003355c, drained every 8th UI pass, ~11M
   instructions later), so a trig in that window copied the OLD kit P words over the live array, for good.
   Measured before the replacement (b4a8f74 as tag usold): `choosetrig-late` with BD trigged at the 1A + 90M - the
   last 0x04 and the live P1..P16 64 64 64 ... (the stock reset) while the kit holds the defaults 10 20 ...;
   `assigntrig` with a trig at the 1A + 150M - P2 20 (the old default) in the 0x04 and the live array, 77 in the kit.

   **Fix (made, 2026-10-11).** us_defaults leaves 0x8000fc58 alone and writes the tag into the live word 0,
   `0x8000e5b0 + 84 t` (one `move.w`, even address), inside the same mask as the kit's two bytes. SET_PARAM(fp, t,
   0) would do the same plus clear 0x80005f10[42 t] (the smoothing step the full copy also clears); the direct store
   is smaller and calls nothing under IPL 7. 0x8000f7a8 (modulated/smoothed) is not written: ext_render reads
   0x8000e5b0 only [read]. A later lock step or kit load still re-copies the whole sound: RELOAD KIT after a choice,
   then a trig - 0x8000e5b0 word 0 back to the saved kit's 0, the live P words the kit's, 0x8000fc58[0] 0 [measured];
   `taglock` passes. After it: `assigntrig` tags 0x74d, 0x3f3c, 0x3f3c, the last 0x04 and the live P1/P2 64/77;
   `choosetrig-late` the defaults in the 0x04 and the live array.

   **Remaining risk (2026-10-11; closed the same day, below).** The stock trig loop still copies the kit sound itself
   in these cases, and a copy that lands within ~11M instructions of a choice (us_set's queued kit words not drained
   yet) put the OLD P words into the live array. Since the review fix (MEDIUM 4) us_defaults stores each knob word
   straight into the active kit before its us_set, so such a copy brings the defaults: emulator `freshtrig` (BD not
   trigged since boot, `0x8000fc58[0]` -1, U1 chosen, BD trigged 36..60M after the YES - between word 0, 30..35M, and
   the drain, 60..70M): on b2beef3's us1 the 0x04 and the live array keep the old P9..P16 (64 64 0 0 0 120 0 100,
   the kit the defaults), with the fix they hold the defaults [measured]. The cases, as they were:
   - **Kit load** (RELOAD KIT, LOAD KIT, a pattern's other kit, LOAD PROJECT): -1 for all twelve tracks
     (0x4011f8da). The first trig of each track after the load copies. A choice made after the load and before that
     trig hits the window if the trig comes within ~11M instructions. It does not heal by itself: the next copy
     comes only with a lock step or another kit load.
   - **Never trigged since boot**: -1 from the init loop (0x4011fa08). The same as a kit load, for the track's first
     trig.
   - **Sound-lock steps**: the lock step copies the pool sound and stores -1 (0x401205e2), so the step after it
     re-copies the kit. If that re-copy lands in the window, it heals at the next lock step, whose following step
     copies again (once a pattern loop, for a looping lock).
   - **0x8000fe30[t] set**: the trig loop copies and clears it (0x401206da). Its setter is not traced: there is no
     absolute writer in the image apart from the kit switch's store to entry 12, the FX track (0x40120aba) [read].
     It heals like a kit load, that is only with a later copy.
   In every case the tag survives: us_defaults writes it straight into the kit word and the live word under the
   mask, so a copy brings the new tag. Only P1..P16 can come out old. Turning a knob heals that one word, because
   SET_PARAM writes the live word. A choice writes the 16 words without any sign on the screen, so a user who hits
   this sees the defaults on the knobs and hears the old values. The same window exists in stock for any knob turn
   (a trig between SET_PARAM and the drain after a kit load) and 0021 does not widen it. It is not reproduced in
   the emulator; on hardware it is timing, which is untested.

   **Kit 0 only (review HIGH 2, fixed 2026-10-11).** The tag, `KIT_WORD` and us_tick3's compare addressed kit 0
   (`0x41255921 + 152 t`). The trig's copy source is `0x4125590d + 2531 k + 152 t` (0x40120670), k its kit byte
   `0x42ade134 + 56 t`, set from the active kit `0x800067b8` (0x4011d054 / 0x4011d090), a 32-bit int written only by
   0x4011f82a, which refuses values above 127 [read]. All 128 kits are resident. Measured on b4a8f74 (usold): A02
   (BANK_A held + T2; 0x800067b8 = 1), U1 chosen on BD (11 DOWNs from kit 1's BD machine 28) - kit 1's P1..P16 the
   defaults through the records, but the tag in kit 0's BD word 0 (0x74d, a kit not playing), kit 1's 0, the trig's
   tag 0. Fix: every use reads 0x800067b8 (& 127) - us_defaults inside the mask, us_tick3, the diagnostic's K.
   The project copy (`0x40765981 + 162 t`) is the active kit's working copy: the switch to kit 1 rewrote all twelve
   tracks there with kit 1's sounds, the drain writes kit 1's knobs there, and a power-off saves it as kit 1 (cold
   boot: kit 1 active, BD on U1, kit 1's word 0 the tag, kit 0's as on the card) [measured]; US_TAG_PROJ was right.
   JUNO's write-backs go through us_set records (no kit address). `tagkit1` covers it.
3. state_test cannot load on a Teensy without PSRAM (20000 B of state, the voice has 16384): an assign answers BAD.
4. The Teensy's arena fills over repeated loads ("U1 rytm.sine_test: no room ... arena full - reloading all slots",
   29200 of 32768 B before); the reload recovered it (8376 B) and the slot played.

### Teensy state after the run

/PRESETS/rytm.v2_test/ removed, U5 cleared, U1 = sine_test and U2 = fault_test in PRESETS again, then the branch's
serial build (f5c1c12) uploaded again (`teensy/run_sketch.sh voiceloop`); boot log: `project: PRESETS`,
`/.rytm/slots/PRESETS.txt: 2 slots to load`, `U1 rytm.sine_test ready`, `U2 rytm.fault_test ready`, `8 installed`.
