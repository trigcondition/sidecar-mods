# 0025-sendfx-report: the Sidecar send FX values to the USB host (2026-10-16)

Milestone M1 of the Sidecar send FX plan (rytm-teensy `docs/superpowers/specs/2026-10-16-sidecar-send-fx-storage.md`,
which also holds M0's stock measurements and the designs of the tag move and of persistent FX 38..41 locks). OS 1.73
only. The reporter writes nothing the firmware reads; since M1b the mod also stores FX words 38..41 (below). Emulator
only; never flashed.

## What it sends

Every audio block it reads the per-track trig array (`trig_sound_array`, 0x8000e5b0 + 84 t: the words the trig loop
last wrote, after p-locks, before the LFO) and sends a track whose words changed since it last sent them:

| track | words | message (rytm-teensy `sim/protocol.py` SENDFX, 0x20) |
|---|---|---|
| 0..11 | sound index 0 | `F0 7D 52 54 20 01 <t> <hi> <lo> F7` (10 B) |
| 12 (FX) | FX words 0, 29, 38, 39, 40, 41 | `F0 7D 52 54 20 01 0C {<hi> <lo>} x 6 F7` (20 B) |

`hi` = word bits 8..14, `lo` = bits 1..7: the lock slot's value and its `0x80 0x80` fine slot, so every value a stock
lock or knob can hold goes out losslessly. Sound index 0 is SEND FX 1 (hi) / SEND FX 2 (lo) in the storage spec's
plan; FX words 29/38/39 are SEND FX 1's knobs and 0/40/41 SEND FX 2's.

- 0x20 is the next free host-link id: 0x1F is reserved for the profile message
  (rytm-teensy `2026-10-11-platform-architecture-design.md`). Receivers ignore commands they do not know; the
  rytm-teensy core's `host_sysex` passes 0x20 to `voice_report`, which returns for anything but 0x03/0x04 [code].
- **Per trig:** a p-lock reaches the host in the audio block its trig plays (measured below: the BD and FX reports of
  one step land in the same 5M-instruction window, 25 ms).
- **Round robin:** one track in turn is marked unsent every `rr` blocks (default 115, ~77 ms, all 13 in ~1 s; 64 until browse-lag: 23 messages a second while idle), so all 13 go out again
  every ~0.55 s: a host that attaches late or lost a message has every value within that time (~24 messages/s,
  ~250 B/s).
- At most `maxb` messages a block (default 4); a track not sent stays pending (its shadow keeps the old value) and the
  scan resumes there next block, so 13 changes in one step take at most 4 blocks (2.7 ms).

## ISR safety

The hook runs in the audio interrupt (level 5) and never waits. It calls the OS's USB MIDI sender (0x400029e0, the
existing MIDI send path) only under 0021's measured conditions (`mods/0021-ext/ext.c`): the sender's mutex
(0x42f67a28) free, its SysEx state (0x413db244) idle, the ring fill (0x413db258) at most 3800 of 4 KB, two free USB
requests (pool head 0x413db390, next at +52), and in addition a host has configured the port (0x413db254 == 1),
because the sender would drop the message silently and the shadow would claim it sent. Messages are 10 or 20 B, under
0021's 48-B bound for the ring's wrap path. 0021's `ext_render` sends from the same interrupt; both test before each
call, nothing re-enters. No EMAC use (soft-float C); d0/d1/a0/a1 saved around the call.

## Hook and cave

- Detour 0x401213a0 (0006-comp-preview's site): the block driver right after `fx_generate`; `addql #4,%sp`,
  `clrl %d1` and the first half of `lea 0x8000e508,%a1` re-emitted after the call, rejoin 0x401213aa. 0006 is excluded
  (0021 excludes it too). The driver's other path (0x4011fe08) does not pass here: blocks on that path are not scanned,
  the next block on this path catches up [code; how often the other path runs on hardware is open, as for 0024].
  Measured: 6750 hook calls in 900M instructions = 1500 a second, every block in the emulator.
- Cave: 1098 B (reporter 646 incl. 52 B state, FX 38..41 storage 452) at 0x402cc920, 0002-euclid-accents' block at
  the head of `cave` (verified pool), claim 0x45c = 1116 B up to 0x402ccd7c, where 0021's `.ust` (302 B) takes the
  block's end. 0002 is excluded (0021 excludes it too), so every user-slot build has it free.
- Cost: 13 tracks x up to 6 compares a block (~150 instructions, ~0.1 % of the CPU) plus the sends.

## Params

| param | default | |
|---|---|---|
| `rr` | 115 | a track resent every `rr` audio blocks; 0 never; 0..127 (the assembler refuses others) |
| `maxb` | 4 | at most `maxb` messages an audio block, 1..8 |

## Builds

`sfx1` = us1 + 0025 (emulator), `hwsfx1` = hwus1 + 0025, `sfxonly` = 0025 alone on stock; all three build and
`verify.py` PASS (2026-10-16):

    .venv/bin/python tools/build.py --tag sfx1 --mods 0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive \
        0025-sendfx-report --param 0014-hidden-machines:variants=1 --param 0014-hidden-machines:funcgen=0 \
        --param 0014-hidden-machines:test=0 --param slots=1
    .venv/bin/python tools/verify.py --tag sfx1

## Tests (rytm-emu, 2026-10-16) [measured]

`tools/emu/us_base.sh sfx1`, then `.venv/bin/python tools/emu/sfx_emu.py sfx1` (every run under DTEMU_STRICT=1): the
test writes kit BD word 0 = 0x1100 and FX words 0/29 = 0x2a54/0x3b66 into the stored working state, trigs on BD
steps 1/5/9/13 and FX steps 1/9 of A01, and p-locks BD type 41 0x33 + fine 0x21 (step 1), 0x44 + fine 0x05 (5),
0x10 (9), FX type 37 0x55 (step 1), type 20 0x66 (step 9); FX words 38..41 written live (1100 2200 3300 4400);
power-off, cold boot, PLAY. The host stand-in (the script, decoding with `sim/protocol.py`) received:

- BD: 3342 440a 1000 1100, repeating, one change each step (90-95M apart at 127 BPM);
- FX: word 0 5500 / word 29 3b66 on step 1, 2a54 / 6600 on step 9; words 38..41 1100 2200 3300 4400;
- the BD and FX reports of step 1 in the same 5M window; the round robin resent quiet tracks; no strict access.

Also on sfx1: `tools/emu/us_emu.py sfx1 all` and rytm-teensy `PHASE1_TAG=sfx1 pi/engine/tests/phase1.py --emu-only
tracks`: both ALL PASS (us_emu 311 checks; phase1 --emu-only: hello 0x7, the four tracks' trigs, the SD p-lock and
the CH knob turn, 90912 B of Rytm USB MIDI to the host, which now includes the 0x20 reports).

## Not done / open

- Hardware: never flashed. The real USB host's pacing under the extra ~250 B/s is untested (as 0021's sends).
- The block driver's second path (0x4011fe08) is not hooked.
- Shared voices: each track reports its own word 0; which track the voice plays is the host's business (owner table).
- The writers (AMP page 2, FX pages), the tag move and persistent FX 38..41 locks: storage spec, "Next steps".

## M1b-b: FX words 38..41 stored (2026-10-16)

Live-only before: in every kit (+1942..+1949), in the live lock array (indices 38..41 exist on every track) and
applied to the trig array [measured], but with no kit slot and no lock type. Worse, stock's incremental save
(0x40009454) and full rebuild (0x400092b2) map a lock index to a type through the FX reverse map 0x401c589c, which has
38 entries: for FX 38..41 they read the next table and write **types 9..12 on track 12**, which load as FX 18..21 locks
[code]. So these hooks come before any writer of FX 38..41 locks.

| detour | site | what |
|---|---|---|
| `sfx_lock_load` | 0x40009040 (`cmpl %d4,%d6` / `bltw`, reimplemented: pc-relative; rejoin 0x40009046) | types 0..41 as stock; 42..49 on track 12 merged into live FX index 38 + (type - 42) % 4, hi (42..45, bits 8..14) or lo (46..49, bits 1..7, sets the index's fine flag), the step's lock count bumped once; then the next slot with no continuation context (d0 = d1 = -1); other types skipped as stock skips them |
| `sfx_rebuild` | 0x400092aa (the rebuild's track test `moveq #12,%d4` / `cmpl %d1,%d4` / `bnew`, reimplemented; rejoin 0x400092b2) | track 12, k >= 38: writes {42 + k - 38, 12, msb[64]} and with the fine flag {46 + k - 38, 12, lsb[64]} into exactly the slots stock reserved, then 0x4000932c. Not 0x400092b2 itself: tracks 0..11 branch back to 0x400092b6 |
| `sfx_incr` | 0x40009454 (`movel %a1@(0,%a0:l:4),%d5` / `clrl %d4`, re-emitted) | track 12, index >= 38: the incremental save's own tail call into the full rebuild (0x40009572) |
| `sfx_kload` | 0x40007f42 (`lsll #8,%d0` / `movew %d0,%a0@(8)`, re-emitted) | kit FX loader: storage +0x50..+0x57 (kit 0x816..0x81D) -> live FX 38..41 |
| `sfx_ksave` | 0x40007f8c (`lsll #8,%d0` / `movew %d0,%a2@(68)`, re-emitted) | kit FX saver: live FX 38..41 -> storage 0x816..0x81D |

- Never a `0x80 0x80` continuation after our types (stock would OR it into the previous valid slot).
- Capacity: up to 8 of a pattern's 72 lock slots; k 38..41 come last in the rebuild, so a full pattern drops them first.
- Stock: skips types 42..49 at load, drops them at its next full rebuild, never reads 0x816 (a zeroing kit save path
  erases it): harmless loss.
- The misaligned long moves in `sfx_kload` / `sfx_ksave`: ColdFire splits misaligned accesses; stock itself moves words
  at odd stored addresses (the project copy at 0x40765913).
- Not exercised: `sfx_incr`'s index >= 38 branch (no writer of FX 38..41 locks exists yet; its k < 38 path ran in the
  incremental-save test).

**Tests** (`tools/emu/sfx_emu.py sfx1b fx38 stock`, DTEMU_STRICT=1, 2026-10-16) [measured]:

- kit storage 0x816 = 1100 2200 3300 4400 and A01 slots (42,12) step 1 0x21, (46,12) step 1 0x11, (45,12) step 9 0x7e
  poked, power-off, cold boot: live kit FX 38..41 1100 2200 3300 4400, live locks FX 38 step 1 0x2122 (fine flag set),
  FX 41 step 9 0x7e00; playing, the host receives FX words 38..41 2122 2200 3300 4400 on step 1 and
  1100 2200 3300 7e00 on step 9;
- SAVE PROJECT AS 003 (129 full rebuilds): the project copy's 0x816 written by the saver; then the live words, the
  project copy, the live locks and A01's stored slots wiped, LOAD PROJECT 003: all back (from the file);
- a stock p-lock on the FX track (RECORD, T1 held, knob A): the incremental save ran and added its slot (0,12);
  ours kept, no type 9..12 on track 12; after a power-off and cold boot all values again;
- the card on **stock 1.73**: cold boot and LOAD PROJECT 003 (the mod's file) - no live FX 18..21 or 38..41 lock, no
  type 9..12 slot; stock's SAVE PROJECT AS 005 and LOAD 005 - types 42..49 dropped, no 9..12, no FX 18..21 lock.

Builds `sfx1b` (us1 + 0025, emulator) and `hwsfx1b` (hwus1 + 0025): build.py / verify.py PASS.

## In elekloader's area (branch `sendfx-ui`, 2026-10-16)

`--area-elek 0025-sendfx-report` links 0025 into the 128 KB DDR area (build `sfxel`, and `sfxui` with 0029). Its ISR
detour 0x401213a0 and rebuild detour 0x400092aa end mid-instruction at 6 B; elekloader's `jmp` sites must cover whole
instructions, so the registry gives them `elek_size` 10 / 8 (the displaced span, nop padded, never run: the stubs
rejoin). The cave claim 0x402cc920+0x45c is then unused in that build; 0021's `.ust` still holds the block's tail.
`tools/emu/sfx_emu.py` counts the hook at the detour site when 0025 is in the area (dtboot counts only inside the OS
image). Results on `sfxui`: mods/0029-sendfx-ui/design.md section 5. The `sfx_incr` >= 38 branch is now exercised by
0029's FX-page p-locks (0029 design, "locks").

## Kits: reload and switch (2026-10-30)

Report: after RELOAD KIT the Sidecar kept the old send FX values. Measured in rytm-emu (DTEMU_STRICT=1, the 0.3.0 set,
tag `sfxr1`; `sfx_emu.py reload`): RELOAD KIT and RELOAD ALL need nothing from 0025. Both end in kit_push
(0x4011f89e), which copies every track's sound and the FX block into the trig array (0x4011f558 / 0x4011f686 ->
0x4011da62, memcpy to 0x8000e5b0 + 84 t) [code]; after SAVE KIT, edits on the AMPLITUDE 2 / SEND FX pages and a
RELOAD (stopped), the next block reports the saved values and no later message (the round robin's included)
carries an edited one [measured, also on the unchanged 0.3.0 build]. **The reported case is not reproduced in the
emulator**; on the Rytm side its cause is not known.

The staleness the bug was thought to have is real for a **kit switch**: a pattern on another kit (A01 kit 0 -> A02
kit 1) sets the active kit (0x4011f82a) without kit_push, and the trig loop copies a track's kit sound only at its
next trig (trig_kit_copied 0x8000fc58 + 4 t != the trig's kit, 0x4012062e) [code]. Stopped, or for a track with no
trigs (often the FX track), the trig array keeps the old kit's values, so 0025 kept reporting them [measured on
0.3.0: `sfx_emu.py kitswitch` fails there].

Fix: on an active-kit change (0x800067b8 != the last seen) every track's bit in `km` is set; a track with its bit
reads its words from the active live kit (0x412558e3 + 2531 k: sound t at + 42 + 152 t + 20, FX at + 1866) instead
of the trig array, until its trig_kit_copied equals the active kit (its first trig copied the kit, p-locks on top),
then the trig array again. Nothing is written that the OS reads. Known limit: a sound lock copies the pool sound and stores -1 in
trig_kit_copied (0x401205ba, 0x401205e2) [code]. -1 is not the active kit, so a track whose km bit is set stays on the live kit's words until its next plain trig copies
the kit: consecutive sound locks after the switch keep reporting the kit's value, not the lock's, and p-locks on them
too; a track whose trigs are all sound locks reports the kit word until the next kit change [inferred from the code,
not run]. -1 must not count as done: a stale -1 from before the switch (a sound lock played on the old kit) would clear
the bit at once and expose the old trig array, i.e. the old pool sound, on the new kit. A UI edit while a track reads the kit
is reported when the bank drain writes the kit word (ms) [inferred].

`copied == k` can be stale (pre-existing, not changed by the fix): A02 played, then A01, then A02 while stopped: each
track's trig_kit_copied is already A02's kit, so km clears at once and the track reports the trig array, i.e. the
last trig's p-lock, not the kit's word. A knob edit made on the other kit leaks the same way, and a trig will not copy
it away (the track counts as copied) [inferred from the code, not run]. FX track: without FX trigs its km bit never
clears, so anything that writes only the FX trig array goes unreported; scenes and performance were not traced.

To fit the cave (1116 B) the shadows now hold the message bytes (2 a word) and a pending mask replaces the
0xffffffff "not sent" shadows: a change in a word's bit 0 or 15 alone (not in the message) no longer sends a copy.
Cave: 1068 -> 1098 B of 1116 (18 B left); elekloader area 56152 -> 56120 B spare.

NO + KIT (the user's key, 2026-10-30): the stock combo is 0x400cd484.., gated by 0x400365f4 (NO held: object +426 and
key 0x45 down via 0x40081bbc), then `jsr 0x400af0d2` at 0x400cd4ae: kit_reload itself, so 0026's kt_reload_det
(4C RELOAD) and kit_push (the trig array) run as for the KIT menu's RELOAD [code]. `sfx_emu.py nokit`: from the
SEND FX 1 page, stopped and playing, short and long NO holds: 4C 02 each time and the saved FX words from the next
block on, no revert [measured, rytm-emu]. The hardware log (no 4C 02 after NO + KIT) says kit_reload was not entered
there; why is not known (the combo's gate, or another reload path such as the swap 0x400a81e6, which 0026 does not
hook and which calls kit_push) [inferred]. The sound-lock limit above is confirmed in code: 0x401205ba copies the
pool sound, 0x401205e2 stores -1 in trig_kit_copied [code, not run].

`sfx_emu.py kitswitch` also covers (tag `sfxr2`, DTEMU_STRICT=1, `sfx_emu.py all`: 39 checks pass): A01 -> A02 -> A01 stopped
(kit 0's values again), a switch while playing (A02 queued), BD's trigs after PLAY on A02 (lock 7700, then kit 1's
4400) and UI edits of FX 38 / 40 (SEND FX 1 knob 3, SEND FX 2 knob 4) after a switch, reported with no revert.

## lock-halves (2026-11-20): P1..P4 locks independent per knob

Each of FX words 38..41 holds two SEND FX knobs (hi = bits 8..14, lo = bits 1..7; 0029 design.md section 2). The project
file already kept one lock type per half (42..45 hi, 46..49 lo), but the live lock array has **one int16 per parameter
per step** (`lock_pool_set` 0x400ac670: index 2837 t + 44 step + k, -1 none [code]) and the fine flag is **per track and
parameter**, not per step (+5632 + k of the track's 5674 B [code]). So a lock on P1 froze P2's value into that step, and a
clear cleared both. Tags as above; rytm-emu 1.74, DTEMU_STRICT=1; nothing flashed.

**Which half is locked lives in the lock word itself** (no mask, no RAM). The word's bits 0 and 15 never carry a value
(the halves are bits 8..14 / 1..7, max 0x7f00); bit 15 is left alone (stock tests a lock word for -1 / < 0), bit 0 marks a
one-half lock, and the free half carries the locked half's value and which one it is:

| word | meaning |
|---|---|
| 0xffff | no lock (stock) |
| `hi << 8 \| lo << 1` (bit 0 clear) | both halves locked: the stock form, and every lock saved before this change |
| `hi << 8 \| 1` | the hi half only; the lo half plays the kit's |
| `lo << 8 \| 3` | the lo half only; the hi half plays the kit's |

Why not the per-step mask of the plan: all 128 patterns plus the working one are resident live pattern objects
(0x407c89e3 + 85760 p, the live kits start right after the 129th [measured addresses]; the loader 0x40009146 decodes each
into its own lock array), so a mask would be 129 x 64 B = 8.3 kB (a large share of the
elekloader area; the heap would do), would have to follow every stock copy of locks (step / track / pattern copy and
paste, undo, the bank-to-working copy) to stay right, and a stale mask would misplay a copied lock. In the word, a copy
of the word is a copy of its halves [inferred: stock copies lock words verbatim; not traced]. Stock code that reads these
words only tests -1 (lock or none, unchanged) or goes through the hooks below and 0029's wrappers.

| what | where | change |
|---|---|---|
| load | `sfx_lock_merge` (0x40009040's detour) | a type 42..45 slot's step sets the hi half, 46..49 the lo half; a step with only one of them gets the one-half form, with both the stock form; the step's lock count bumped once; a lo type sets the fine flag (as before) |
| save | `sfx_rebuild_c` (0x400092aa's detour; the incremental save goes there for k >= 38, `sfx_incr`) | the hi slot gets the step's hi value only where the hi half is locked, the lo slot (written when the track's fine flag for k is set: the slots stock reserved) only where the lo half is; 0xff elsewhere |
| playback | **new detour `sfx_play` at 0x40120968** (1.74 0x401209d4) | below |
| UI | 0029's FX set wrappers: lock get / set and **new lock clear (+0x44)** | 0029 design.md section 12 |

**Fine flag.** 0029's records lock with the fine flag (record +0x14 = 1, 0x400071a6), and the loader sets it for any lo
type, so a word with a lo half locked always has it set and its lo slot is reserved at save. A pattern whose locks on k
are all hi-only still gets a lo slot (all 0xff) when the flag is set: one slot of the 72, as before this change.

**Playback** [code; measured]. The trig loop in the audio interrupt (the function around 0x40120000; 1.74 +0x6c) gets a
trig's locks as a list, `{u16 track, u16 sound index, u16 value, u16 flags}` 8 B each (count at list +4, entries at +12;
measured on the FX track: `000c 0026 2122 0000`, `000c 0029 7e00 0000` for FX 38 / 41 locks), and writes each value into
the trig array (0x8000e5b0 + 84 t + 2 k: `movew %d4,%a1@(52,%d6:l:2)` with a1 0x8000e57c) and two arrays beside it
(0x8000e57c + 4 (42 t + 26 + k + 578) as value << 16, + 2 (42 t + 26 + k + 2300)), each re-read from the entry. No mod
hooked it before. The detour replaces the loop body's first two instructions (`movew %a0@,%d6`, `movew %a0@(4),%d4`, 6
bytes, no address operand: the same bytes on 1.73 and 1.74) and rejoins at the third: a value with bit 0 clear (every
stock lock value, an 8.8 word) goes straight on; with bit 0 set `sfx_play_c` checks track 12 and k 38..41 and writes the
locked half, merged with the trig array's current word (the kit's), back into the entry, so the stock body stores the
merged word in all three places. The trig array holds the kit's word there: the trig loop copies the kit into it at a
trig whose kit differs or after a trig with locks (the per-track dirty byte, 0x8000fe30-ish, counts the lock entries)
[code: 0x4012069a .. 0x40120a64 in 1.74], and a knob turn writes it directly (0029's `fx_write_hi`, which now writes
only the turned half there). Cost: two instructions and a bit test per lock entry; a C call only for a one-half lock.
The list is rebuilt per trig [inferred from `halves`' second PLAY, which plays the new kit half]; writing the entry back
is safe as long as nothing replays a list (a replay would see the merged word: the same value).

**The Sidecar** needs nothing: 0025's reporter sends the trig array's FX words 38..41 as played (above), so a one-half
lock reaches it merged with the kit's other half [measured: `sfu_emu.py TAG halves`].

**Area / cave.** 0025 grew 384 B (1098 -> 1482 B of code; its 52 B of state unchanged). It no longer fits its 1116-B
cave claim (0x402cc920; on 1.74 that span is 1.74's own code [re/os/1.74.toml padding note]), so 0025 builds with
`--area-elek 0025-sendfx-report` only, as the Makefile's release build does [inferred: a non-area build was not tried]. 0025 +384 B,
0029 +556 B of code, no new state.

## amp-halves (2026-11-20): SFX1 / SFX2 locks independent per knob

The same lock-word encoding as "lock-halves" above, now also on
**sound index 0 of the voice tracks 0..11** (SFX1 hi = bits 8..14, SFX2 lo = bits 1..7; 0029's AMPLITUDE 2 page). Stock
stores that index as lock type 41 (the coarse values, hi) plus its `0x80 0x80` fine slot (lo) [code: the sound reverse map
0x401c59cc (1.74 0x401c5c7c) [0] = 41, the forward map 0x401c5a74 [41] = 0]. Tags as above; rytm-emu 1.74, DTEMU_STRICT=1;
nothing flashed. Bit 0 of a sound index 0 lock word was free: stock's loader writes `coarse << 8 | fine << 1` [code], and
the sound tag that once lived in index 0 is at +0x6e / slot 47 since 2026-10-16 (0021 design.md) and never had locks.

| what | where (1.73; 1.74) | change |
|---|---|---|
| load | **new detour `sfx_fine` 0x400090d8** (same on 1.74; `movel #5674,%d2`, the first instruction of the fine slot's OR loop, reached only with a valid context: d0 the index >= 0, d1 the track != -1) | track < 12 and index 0: `sfx_lock_merge` (now `(slot, live, track)`) over the fine slot, keeping only the hi half the coarse pass wrote: fine value + coarse value = both (stock form), coarse value + fine 0xff = hi only, fine value + coarse 0xff = lo only (count bumped; stock ORs it into 0xffff: no lock); the fine flag set; then 0x40009128 with d0 / d1 kept. Anything else: the instruction re-emitted, rejoin 0x400090de |
| save, full | `sfx_rebuild` 0x400092aa (existing) | a voice track with d3 = 0 (index 0) also goes to `sfx_rebuild_c` (now with the track): type 41 and, with the fine flag, the `0x80 0x80` slot; only the locked halves, 0xff elsewhere |
| save, incremental | `sfx_incr` 0x40009454 (existing) | a voice track's index 0 also takes the tail call into the full rebuild (0x40009572), as FX >= 38 does |
| playback | `sfx_play` 0x40120968; 1.74 0x401209d4 (existing) | `sfx_play_c` accepts track < 12 with index 0: the locked half merged with that track's trig array word 0 (the kit's, or a sound lock's pool sound: the trig loop copies it first, as for any lock) |
| UI | 0029's Sound set wrappers (0029 design.md section 13) | |

The stock coarse pass stays as it is (it writes `hi << 8` for every coarse value): the new detour only reinterprets it
when a fine slot follows, so a type 41 slot with no fine slot (a lock made without the fine flag) loads as stock's
`hi << 8` [code]. Within a type 41 + fine pair, stock's own rebuild writes coarse and fine from the same word, so a stock
file never has a coarse value with fine 0xff or the reverse [code: 0x400092f6..0x4000931e]: every file saved before
loads into the same words (`ampold`).

**A stock (unmodded) Rytm with a file that has one-half SFX locks** [code; measured for both-halves files in `ampold`]:
a hi-only step (coarse value, fine 0xff) loads as `hi << 8`, i.e. SFX2 locked to 0 on that step; a lo-only step (coarse
0xff, fine value) is no lock. Stock plays sound index 0 nowhere audible (only 0025 reports it), so nothing sounds
different on stock; but a stock save rewrites the hi-only step as both halves with SFX2 = 0 and drops the lo-only one, which
is what a modded Rytm then loads back. A both-halves lock round-trips through stock unchanged.

**Base turns**: turning SFX1's or SFX2's base while a step plays a one-half lock keeps the locked half in the track's
trig array row (the Sound set's write stores the whole kit word there [code: 0x400a9e58 -> 0x4011f3fa(v, set + 8, k),
0x8000e5b0 + 84 t + 2 k]; 0029's `sfu_s_write` restores the other half after it, 0029 design.md section 13).

**Cost**: 0025 +142 B of code (1482 -> 1624: `sfx_fine` 50, `lk_load` shared by both load paths, `sfx_rebuild_c` +32,
`sfx_play_c` +8, the two existing stubs +6 each), no state.
