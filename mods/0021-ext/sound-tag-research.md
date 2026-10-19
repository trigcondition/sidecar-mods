# 0021 user slots: a plugin tag in saved sounds (research, OS 1.73)

The user's decision (2026-10-10): a Rytm SOUND on a user machine (35..39) stores only the machine byte and its
words, so loaded into a project whose slot holds another plugin it plays that plugin with foreign values. Tag
sounds with a short fingerprint of the plugin. On a mismatch the track stays silent and shows `!NAME`, as on a
project change (umbrella spec rytm-teensy docs/superpowers/specs/2026-10-10-user-machines-design.md, section 2,
Project change). This note answers: where the tag can live, where the check goes, who writes it, and what sound
locks do. Research only. No code changed.

Tags as in user-slots-research.md: **[measured]** means read in this image or run in rytm-emu; **[inferred]** means not run.
Build `ust` was built in a scratch worktree at f19aaad, with the mods and params of `us1`. Its base came from
`tools/emu/us_base.sh ust` (rytm-emu sections/led.img). Every emulator run started from one snapshot. In it,
track BD plays U1, chosen with 15 DOWNs and YES and no Teensy. Markers were then poked into that snapshot. The
firmware-derived files were deleted afterwards.

## Summary

- **Tag location: sound index 0** (live sound `+0x14`, stored slot 41 at `+0x6e`). It is the only spare word
  that every path carries. Measured carried by: kit save and reload, project save and load, power-off and cold
  boot, sound save to and load from the +Drive library, store to and load from the project's sound pool, a cold
  boot on **stock** 1.73, and the trig path into the audio-side arrays, sound locks included. No record names it,
  so no knob, p-lock, MIDI or LFO DST can write it [inferred]. It costs one exclusion: 0004-lfo-rnd packs its
  settings in the same word, so 0021 must exclude 0004. The hardware builds do not include 0004 today, and
  excluding it frees cave2's 1340 B and `.kgate`'s 48 B.
- **Rejected:** the live bytes `+0x6d..+0x6f` and stored slots 42..47. Both are lost at power-off. The slots are
  also zeroed by every stock `sound_save` (SAVE KIT measured). And `+0x6d..+0x6f` hold heap garbage after a
  `sound_load` (measured `00 f2 2f` from a buffer). Keeping either needs load and save detours.
- **Tag value:** 14 bits, `fp = (FNV-1a(package id) mod 16383) + 1`, stored as the word `0x0000..0x3fff`.
  `0` means untagged. Hash the id only, not the version, so an upgrade the manifest declares compatible keeps
  its sounds. The word must stay below `0x8000`: the modulated array clamps a negative word to `0x7fff` (measured).
- **Writer (Rytm):** `us_defaults` only. It already serves the three choice routes (the machine list's YES,
  the SOUND menu's MACHINE item, the slot menu's assign) and the delayed wait for 1A. It writes the slot's fp
  into the kit's live word 0 and the project copy's slot 41. The fp comes from 1A part 0 as two new bytes. Never
  on a kit or project load, a plain 1A or a 1C. Re-tagging on every 1A would erase the very mismatch the tag
  exists to catch.
- **Check:** at the trig, from the per-track array `0x8000e5b0 + 84 t`. That is the only place a sound lock
  passes. A sound lock does not go through `sound_load` or the kit (measured). So hooks on sound load, paste and
  kit load (the brief's option (a)) cannot be complete. **Recommended:** `ext_render` appends the word to 0x04
  and 0x03 (2 bytes). The Teensy compares it with the fp of the plugin it actually runs in that slot, and keeps
  the voice silent on a mismatch. The Rytm shows `!NAME` for the selected track from the kit word, in `us_tick3`.
- **Untagged (0):** allowed (it plays). That covers sounds made before the tag, a cleared track sound, and
  factory sounds.
- **Cost:** about 130 B on the Rytm, either way. That exceeds the ~30 B free, so it lands in 0004's cave once
  0021 excludes 0004. About 250 B of flash on the Teensy.

## M1 The sound record and the candidates

**Layout** [measured, ust]
- The kit's live sounds start at `0x4125590d + 152 t`, odd and packed:
  - `+0x04` holds the name;
  - `+0x14 + 2i` holds sound index `i`;
  - `+0x68` holds the machine byte;
  - `+0x6d..+0x6f` are the three spare bytes.
  These are the same objects as the words at `0x41255933 + 152 t` in user-slots-research.md R3: `+0x14 + 2*9 = +0x26`.
  **Correction (review, 2026-10-11):** that is kit 0. All 128 kits are resident, kit k at `0x412558e3 + 2531 k`
  (track t's sound `0x4125590d + 2531 k + 152 t`); a trig copies from its kit byte `0x42ade134 + 56 t`, set from the
  active kit `0x800067b8` (32-bit, written only by 0x4011f82a, which refuses values above 127) [read]. Pattern A02
  sets it to 1 [measured]; the tag and `!NAME` use the active kit.
- The project copy (working state) is stored-format, `0x40765913 + 162 t`. Slot 41 (index 0) is at `+0x6e`,
  slots 42..47 at `+0x70`, the machine at `+0x7c`. It matches R11's `0x4076592f`.
- Track BD's adapter `0x41b01500` points at both: `+0x10` = `0x4125590d` (the kit sound) and `+0x20` =
  `0x40765913` (the project sound). On A02 (kit 1) `+0x10` reads `0x412562f0` (kit 1's) and `+0x20` stays: the
  project copy is one working copy, the active kit's (a kit switch rewrites all twelve tracks there) [measured].

**Candidates** [measured: free per re/subsystems/sound-storage.md and lfo.md Q1, Q8, Q9]
- **Sound indices 1..41 are all used by 35..39.**
  - LFO 1..8, filter 25..32, amp 33..36 and FX 37..41 act on the slot's audio: the voice's filter and amp
    process the Overbridge input.
  - P1..P8 are 9..16, and P9..P16 (page 2) are 17..24.
  - No machine word is free across the five slots.
- **Index 0** (slot 41) has no record. It is the word stock carries end to end (lfo.md Q9), and the one 0004
  uses.
- **Slots 42..47** are serialized but never mapped.
- **Live `+0x6d..+0x6f`** are not serialized.
- **The name** is ruled out: the user can rename a sound.

**Persistence matrix**. Markers on BD, poked into the snapshot after U1 was chosen: kit word 0 = `a55a`,
kit `+0x6d` = `b1 b2 b3`, project slot 41 = `c33c`, project slot 42 = `d44d`. Then each operation ran.

| path | index 0 (kit / project) | `+0x6d..6f` | slot 42 | how |
|---|---|---|---|---|
| idle 1500M | kept | kept | kept | [measured] |
| SAVE KIT, markers zeroed, RELOAD KIT | `a55a` back in both | `b1b2b3` back (raw `0x9e3` copy) | zeroed by the save | [measured]: the save re-serializes the project copy from the live kit (12 `sound_save`) |
| power-off, cold boot (same build) | kit = `c33c` (from slot 41) | lost (`000000`) | kept raw in the project copy, never reaches the live sound | [measured] |
| SAVE PROJECT AS 003, markers zeroed, LOAD PROJECT 003 | `a55a` in both (the file took the **live** word, not the project copy's `c33c`) | lost | zeroed | [measured], 1676 `sound_save` / 3212 `sound_load` |
| SOUND MANAGER (YES + MUTE, +Drive bank A) save, then SOUND BROWSER load onto SD | SD: `a55a` in both, machine 35 | `00 f2 2f`, heap garbage | zeroed | [measured]: one `sound_load` |
| SOUND MANAGER, VIEW POOL: BD stored to pool entry 1, then SOUND BROWSER, VIEW POOL: loaded onto RS | RS: `5e3c` (BD's tag) in both; pool live `0x41313c47` and pool stored `0x407bd2b7` both hold it | carried (raw copies) | zeroed | [measured] |
| cold boot on **stock** 1.73 (spec 1.9) | kit = `c33c`, project = `c33c`; the track shows DISABLE (kit machine 27, project still 35) | lost | kept raw | [measured]. Back on `ust`: U1, `c33c` |
| stock `sound_save` (kit, pool, project) | carried: slot 41 is inside the mapped 42 | n/a | zeroed | [inferred]: same unpatched `0x4000843a` (lfo.md Q8). Stock's SAVE KIT walk did not run in the test |
| copy/paste of a track sound | carried | carried | n/a | [inferred]: raw `0x98` memcpy (sound-storage.md). On hardware, 0013's `+0x6d` byte survived copy/paste (2026-09-28), which is a stronger condition. **Not driven in the emulator**: TRK+REC, FUNC+REC and TRK+T2 with FUNC/TRK+STOP pasted nothing; the key walk is unknown |
| the trig → audio side | `0x8000e5b0 + 84 t` (per track, unmodulated), `0x8000eeec + 84 v` (per voice), `0x8000f7a8 + 84 t` (modulated; SD's `a55a` read `0x7fff` there) | n/a | n/a | [measured]: a poked kit word reached them at the next trig |
| sound lock | the locked pool sound's word 0 (see M4) | n/a | n/a | [measured] |
| CLEAR TRACK SOUND, Randomize, Elektron SysEx / Overbridge sound transfer | 0 (`sound_init_defaults`) / not written (the ids 28/29 randomisers are cleared statically) / carried as the stored record | | | [inferred] |

Pool layout [measured]:
- live copies at `0x41313c47 + 152 (i - 1)`;
- stored copies at `0x407bd2b7 + 162 (i - 1)`, inside the working state, so a power-off keeps them raw
  [inferred from the range];
- names at `0x41b81f54 + 36 (i - 1)`.

The SOUND MANAGER and SOUND BROWSER open on the +Drive library (A:nnn). Their LEFT menu toggles VIEW POOL.

## M2 Where the check goes

The trig is the only point every path passes. A sound lock (M4) never touches the kit, `sound_load` or
`0x4011f6bc`. So option (a), hooking sound load, paste and kit load, cannot cover it; each of those paths would
need its own hook as well (4 `sound_load` callers plus the loop, 15+ memcpy sites, `0x4011f6bc`). The check
must read `0x8000e5b0 + 84 * OWNER(v)` word 0 when the engine sees the trig. `ext_render` already detects that
trig and reads the owner track through `0x40290dd8[v]`. Read the unmodulated array, not `0x8000f7a8`: that one
is LFO-modulated, smoothed and clamped (`a55a` came out as `0x7fff`), and LFO DST 0 would move the word
[inferred]. The `0x57` report in M4 carried the locked sound's own P1..P16, which come from the same trig's
copy. So the array is filled before the engine builds the report [measured, indirectly].

Both remaining options check at the trig:

- **(A) Rytm only:** `ext_render` compares the word with `us.c[s]->h.fp` and drops the 0x04 on a mismatch, so
  the Teensy never starts the note. No protocol change. About 35 B in `.exto`, which is full. It reads a cache
  pointer in the ISR. And it is stale for the moments between a project change and the new 1A. The Teensy is
  then not READY anyway, so the slot is silent [inferred].
- **(B) Rytm reports, Teensy decides (recommended):** `ext_render` appends the word as two 7-bit bytes to 0x04
  (41 to 43 B; its buffer `m[44]` already fits) and to 0x03 (39 to 41 B). This also covers a voice still
  sounding when another sound loads. The Teensy compares it with the fp of the plugin it actually loaded in the
  slot. No race, no cache read in the ISR, and the Teensy can log it.
  - Backward compatible both ways: voiceloop.ino:3064 parses `len >= 41` and `len >= 39` and ignores the extra
    bytes, and an old Rytm sends no tag (read as 0, allowed) [read].
  - Teensy side: in `plug_report`, a tag that is nonzero and not the slot's fp sets a per-voice mismatch bit and
    returns. `plug_render` stays silent while the bit is set. A matching or untagged trig clears it.

Rytm cost is nearly the same for A and B (about 25 B to append, about 35 B to compare). B adds about 250 B of
Teensy flash. B is more robust.

## M3 Writing the tag, untagged sounds, the display

- **fp to the Rytm:** two bytes at the end of 1A part 0: `d[40] << 7 | d[41]`, total 43 B.
  - `us_meta_in` accepts `len >= 41` today [read: ext.c:1321]. A new Rytm reads fp when `len >= 43`; an old
    Rytm ignores it.
  - Add `uint16_t fp` to `struct us_head`; `us_cache` is heap-allocated, so this costs no cave data.
  - sim/protocol.py `decode_meta` checks `== 4 + 31` exactly and must widen with it [read].
- **Writer:** in `us_defaults(t, s)`, after the knobs:
  - `fp = us.c[s]->h.fp`;
  - kit word 0 at `0x41255921 + 2531 k + 152 t`, k the active kit (byte stores; kit 0 only until the review fix);
  - project slot 41 at `0x40765981 + 162 t`.

  Both writes are needed [measured]:
  - power-off keeps the project copy;
  - a project save serializes from the live kit;
  - SAVE KIT, the pool and the +Drive library serialize from the live kit.

  No stock commit is needed: index 0 has no record, the drain only writes changed records, and the next trig
  copies the kit word to the audio side [measured]. **Correction (E2E bug 2, user-slots-research.md):** only on a
  track that has not trigged since a kit load or a lock step; a trig copies the kit sound only when 0x8000fc58[t] is
  not the kit it plays, so us_defaults also writes the live word 0 (`0x8000e5b0 + 84 t`) under the mask [measured].
  (A -1 in 0x8000fc58[t], b4a8f74, was wrong: it re-copied the kit's P words before US_COMMIT's queue had written
  them.)
- **Not a writer:** kit or project loads, a 1A arriving, a 1C write-back. On a project change, the Teensy loads
  the project's slot set and sends a new 1A. Re-tagging then would make every mismatched sound look right.
- **Untagged (0) is allowed.** These sounds come from before the tag, CLEAR TRACK SOUND, stock-machine sounds
  switched to a slot by MIDI (`0x4010330c`: no defaults) and 0021 builds without the tag. An untagged sound
  takes a tag only when the user chooses the slot again. Optional later: adopt on the first knob edit
  (`us_writeback`), about 20 B. Hash collision: 1 in 16383.
- **`!NAME` per track:** today the names are per slot (`us_names(s)` fills `us_lnames[s]`, with `!` for a slot
  that is not READY). In `us_tick3`, already run every UI tick:
  - take the selected track `t` on slot `s` and compute `mm = (w0 != 0 && w0 != fp)` from the kit word;
  - when `mm` changes, call `us_names(s)` with `mm`, which puts READY's name through the `!` branch.

  So the selected track's machine name reads `!NAME` while its sound is foreign. Another track on the same slot
  shows the same while that track is selected. A sound-locked mismatched step is silent but not shown.

## M4 Sound locks

[measured, ust]
- A sound lock: RS (stock machine, track 2) selected, RECORD, T1 held, LEVEL/DATA (encoder 8) to pool entry 1,
  `1 KLAS`, released.
- Pool entry 1 was then poked into a U1 sound with distinct words 0 in each copy: live `0x41313c47`: machine
  `0x23`, word 0 `ab01`; stored `0x407bd2b7` `ab02`; a second stored copy `0x41eb56e7` `ab03`.
- PLAY, with `--watch 8000e658` (RS's `0x8000e5b0 + 84*2`) under DTEMU_NO_JIT=1.

Results:
- On step 1, memcpy (`0x40098b6a`) wrote `ab01 0400`: the pool's **live** copy, word 0 included.
- The Rytm sent `F0 7D 52 54 04 57 ...`: U1 on voice 7, with KLAS's own P1..P16.
- `sound_load` ran 0 times.
- The following trigs wrote RS's own word 0 (`0000`) and sent no report: a stock machine.

So a step can bring a machine-35..39 sound with any words mid-pattern, onto any track and any voice, without any
load, paste or kit hook. Only the per-trig check (M2) sees it. With B, a mismatched lock step is silent. An
untagged lock step plays (allowed).

## Code estimates

| side | item | bytes |
|---|---|---|
| Rytm | 1A part 0 fp (`us_meta_in`, `struct us_head` +2) | ~18 |
| Rytm | `us_defaults`: fp into kit word 0 and project slot 41 | ~32 |
| Rytm | `ext_render`: word 0 of `0x8000e5b0 + 84 OWNER(v)` appended to 0x04 and 0x03 (B) | ~26 (A: ~35 for the compare) |
| Rytm | `us_tick3` + `us_names` mismatch for the selected track, 1 B RAM | ~55 |
| Rytm | **total** | **~130** |
| Teensy | fp per slot at plugin load (FNV-1a of the id), 1A part 0 +2 B, tag parse, per-voice mismatch bit in `plug_report` / `plug_render`, a log line; sim/protocol.py | ~250 flash, ~20 RAM |

The Rytm has about 30 B free (.us2 2778/2782, .us3 1010/1024, .us4 720/760, .exto 730/736, .ext9 900/900). The tag
requires 0021 to exclude 0004-lfo-rnd. Its claims then become 0021's: cave2 `0x402cd8a0` 1340 B and `.kgate`
`0x40029808` 48 B. `ext_render`'s growth must move a few functions out of `.exto` into that room.

## Open risks

1. **Copy/paste not run in the emulator**. The key walk was not found. Hardware evidence is indirect (0013's
   `+0x6d`, 2026-09-28).
2. **0004 and index 0.** If 0004 ever ships together with user slots, its packed LFO-RND word reads as a tag and
   mutes U-sounds. The exclusion must be in mod.toml. A kit made on a build where 35..39 were 0014's "2"
   variants and 0004 was present carries a nonzero word 0, so it mutes. That is the safe direction.
3. **LFO DST 0.** The modulated array would move word 0. Reading `0x8000e5b0`, the unmodulated array, avoids
   it. That `0x8000e5b0` is never modulated is [inferred] (lfo.md Q7). Measured only at trigs: SD's `a55a` was
   intact there while `0x8000f7a8` read `0x7fff`.
4. **Fixed addresses** (`0x41255921 + 2531 k`, `0x40765981`): the kit base was measured constant in three boots (R11
   and here); k is read from `0x800067b8` at each use. BD's adapter `0x41b01500` (`+0x10` the kit sound, following
   the active kit; `+0x20` the project sound) is the firmware's own route [measured for BD only; the `+ 0x1c t`
   stride is wrong: `0x41b0152c` holds `0x401e0e08`, no sound].
5. **Ordering inside the audio block**: that `0x8000e5b0` is filled before `ext_render` sees its trig is shown
   only indirectly (the lock's 0x04 carried its own words).
6. **Display:** only the selected track's `!NAME`. Mismatched lock steps are silent but not shown. With B the
   Rytm's display compares with its cached fp (from 1A), and the Teensy with its loaded plugin. They agree once
   the 1A is current.
7. **A sounding voice when its sound changes:** covered only if the tag also rides in 0x03 (B as proposed).
8. **Stock SAVE KIT, project save and pool store were not run on stock.** The unchanged `sound_save` carries
   slot 41 [inferred].
