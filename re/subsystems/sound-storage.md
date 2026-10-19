# Sound storage

Where a sound lives on disk and in RAM, how it moves between the two, and what
room is left in each. Stock MKII 1.73, MAIN OS at `0x40000400`. Claims are
tagged **[measured]** (read from `build/mainos_emac.dis`) or **[inferred]**.

Builds on `lfo.md` Q1, Q8 and Q9, which found the six spare storage slots and
sound index 0. Investigated 2026-09-27 for a per-sound HPF, first dropped
because the voice path is analog end to end (`audio-engine.md`), then built by
mod 0013 once its voices went through the DAC: the design below, as built and
tested, is under "Built: mod 0013's HPF".

## Summary

- The stored record (`0xa2` bytes) has **six spare words, slots 42..47**, that
  stock carries in every file, never reads, and zeroes on every save. The
  version upgrades (`0x40009de4` v2->v3, `0x40009ec4` v3->v4) copy the whole
  `0x60` block at `+0x1c`, so they carry them too (`lfo.md` Q6).
- The live sound (`0x98` bytes) has **three unexplained bytes, `+0x6d..+0x6f`**.
  Load, save and the default initialiser never touch them.
- Every load path found goes through `sound_load` and every save through
  `sound_save`, so one detour on each would cover files, kits, the pool and
  transfers.
- Sounds are copied by raw `0x98` memcpy, which would carry the three bytes.
- So **up to 24 bits per sound** can be opened up with two detours, without a
  format change. Stock load ignores them; a stock save erases them.
- Sound index 0 (slot 41) is a free 16-bit word stock already carries end to
  end (`lfo.md` Q9), but mod 0004 uses all of it.

## The stored record, `SoundStorage` v4 [measured]

`0xa2` bytes, from `sound_save` (`0x4000843a`) and `sound_load` (`0x400081f6`):

| offset | size | content |
|---|---|---|
| `+0x00` | 4 | magic `0xbeefbace` |
| `+0x04` | 4 | version, 4; load rejects anything else |
| `+0x08` | 4 | live `+0x00` |
| `+0x0c` | 16 | name, live `+0x04` |
| `+0x1c` | 96 | 48 words: slots 0..41 mapped from sound indices, **42..47 spare** |
| `+0x7c` | 1 | live `+0x68` |
| `+0x7d` | 1 | live `+0x69..+0x6c`, two bits each, packed `69<<6 \| 6a<<4 \| 6b<<2 \| 6c` |
| `+0x7e` | 16 | live `+0x7c` sub-object, via `0x40007ed6` / `0x40007be2` |
| `+0x8e` | 8 | live `+0x70`, four 3-byte entries as four words, via `0x400083ec` / `0x4000819c` |
| `+0x96` | 8 | live `+0x8c`, four 3-byte entries as four words, via `0x4000816c` / `0x40008138` |
| `+0x9e` | 4 | sentinel `0xbacef00c` |

Slot `k` is at `+0x1c + 2k`, so the spare slots 42..47 are `+0x70..+0x7b`.
`sound_slot_map` (`0x401c59cc`, index -> slot) and its inverse
(`0x401c5a74`) are 42-entry permutations, adjacent, so neither can grow in
place. Sound index 0 maps to slot 41. The word at slot 36 (`+0x64`) is
converted through the map on both paths: it holds LFO 1's destination as a
sound index, and the file stores it as a slot.

## The live sound [measured]

`0x98` bytes, heap-allocated (`pea 0x98; jsr 0x400829d4`) and held behind
shared pointers:

| offset | size | content |
|---|---|---|
| `+0x00` | 4 | stored at `+0x08` |
| `+0x04` | 16 | name |
| `+0x14` | 84 | 42 parameter words, `+0x14 + 2 * sound index` |
| `+0x68` | 5 | bytes `+0x68..+0x6c`, stored at `+0x7c`/`+0x7d` |
| **`+0x6d`** | **3** | **unexplained** |
| `+0x70` | 12 | four `modTarget_t` (`{u16 amount, u8 destination}`) |
| `+0x7c` | 16 | sub-object, conditional on word `+0x3a` |
| `+0x8c` | 12 | four 3-byte entries |

`sound_init_defaults` (`0x400122b6`, reached from `0x40012404`) writes the
name, `+0x68..+0x6b`, the 42 words and the three sub-objects, not
`+0x6c..+0x6f`.

### Are `+0x6d..+0x6f` free?

- `sound_load`, `sound_save` and `sound_init_defaults` never read or write them
  **[measured]**.
- An image-wide scan for byte accesses at displacements 109..111, word accesses
  at 108..110 and long accesses at 106..110 (excluding `%sp`, `%fp`, `%pc`)
  finds 118 instructions **[measured]**. The ones in and near the sound code
  belong to other structures:

  | site | why it is not the live sound |
  |---|---|
  | `0x400077ba`, `0x40011cb2` | a struct of longs at `+100..+112` |
  | `0x40007af2` | a stride-4 byte array `+87..+123` |
  | `0x4000975c`, `0x40009980` | a packed struct, word at odd `+107`, clamped to +-5000 |
  | `0x40009f64` | inside the v3->v4 converter `0x40009ec4`, on stored slot 40 |
  | `0x40009cf8` | in `0x40009c6c`, the function before the v2->v3 converter, on stored slots 36 and 40; its role is not established |

  The other ~110, elsewhere in the image, are **not triaged** one by one.
- A freshly allocated sound holds whatever the allocator leaves there
  **[inferred]**: nothing in the constructor paths below clears them.

So they are free as far as static reading goes, not proved free. The
cheapest proof is on the device: write a marker to `+0x6d..+0x6f` of every
live sound and check it after save/reload, kit load, pool load and save,
copy/paste, randomize, undo and SysEx/Overbridge transfer.

## Load and save paths [measured]

- **Load**, `sound_load(live, storage)`: 4 callers (`0x4018bbc0`, `0x4018ca06`,
  `0x4018cb98`, `0x4018cc4e`), plus the loop at `0x40008384` that loads 130
  sounds (live stride `0x98`, stored stride `0xa2`) and falls back to
  `0x40012404` for any that fail.
- **Save**, `sound_save(storage, live, ...)`: 10 callers (listed in
  `re/symbols.toml`), plus the matching loop at `0x4000857e`.
- Both are handed `(live, storage)` only, no track. The live pointer is often
  a heap temporary, so a side table keyed by it does not work (`lfo.md` Q9).

## How sounds move [measured]

- **Copies are raw.** 15 sites call memcpy (`0x40098b54`) with `0x98`
  directly, found by size, so not each confirmed to be a sound; more go
  through registers (`0x4001245c`, `0x4003b9a2`,
  `0x400af248`, `0x400bdb36`, `0x400bdb82`, `0x4018cb1c..0x4018cb34`). Example:
  `0x400a74c4` gets a kit track's sound from its owner and copies it whole into
  a new object. `sound_apply_step_locks` (`0x4003b8aa`) copies the track's
  sound into a `0x98` temporary before overlaying locks. A raw copy carries
  `+0x6d..+0x6f`.
- **Fresh sounds** are allocated and filled by `0x40012404` ->
  `sound_init_defaults`, e.g. the factory at `0x40035a66`, which then hands the
  object to its owner's setter (vtable `+20`).
- **Owners.** Sounds sit behind objects reached through virtual getters and
  setters, off the project object from `0x4017f83e`:
  - kit tracks: `project + 205340`, then `0x400bf1f0(kit, track)`; per-track
    owners at `+60 + 352 * track`, getter at vtable `+40`
  - the 128 saved kits: `project + 7388 + 68 * i`, `i` = 0..127. The single
    kit reload `0x400af0d2` copies `0x9e3` bytes from entry `i`'s data (vtable
    `+40`) over the working kit's (`project + 352`), so these are kits, not
    the sound pool; where the pool lives is not located
  - thunks such as `0x400b34d4` tail-call vtable `+16` on these.

  **The setters' implementations are not read.** If any copies field by field
  rather than as a whole `0x98`, `+0x6d..+0x6f` would be lost on that path
  (for example pool -> track).

## Opening up the spare room

A design that fits what is established, not built:

- **Live:** keep the value in `+0x6d..+0x6f`: a tag byte and 16 bits of
  payload. A wrong tag reads as unset, so allocator garbage in fresh sounds
  and zeroed slots in old files both read as off.
- **Load detour** on `sound_load`: copy stored slot 42 (and a byte of 43) into
  live `+0x6d..+0x6f`.
- **Save detour** on `sound_save`, after its memset: write them back.
- **Capacity:** 24 bits, of which 16 are usable with a tag. The storage side
  has 12 bytes; the live object's three bytes are the limit.
- **Portability:** stock loads such a file normally and ignores the value; a
  stock save of that sound or kit erases it. Silent loss, not corruption.

## Built: mod 0013's HPF

Mod 0013 keeps each sound's high-pass step in the spare room, as above:

- **Live:** `+0x6d` the tag `0xb5`, `+0x6e` the step (0 = OFF, 1..48).
- **Stored:** slot 42 (`+0x70`) holds `(tag << 8) | step`.
- **Load** (`0x4000826a`, after `sound_load` clears the live array): tag and
  step from slot 42, or the tag cleared, so a stock-saved sound (slot zeroed)
  or a fresh object reads OFF.
- **Save** (`0x40008492`, after `sound_save`'s memset): slot 42 from the live
  bytes.

How the open questions came out:

1. **Whole-object copies, and nothing else writing `+0x6d..+0x6f`:** on the
   device (2026-09-28) the value survived kit save and reload, loading another
   kit and back, a pattern change to another kit and back, NO + PLAY kit reload,
   the sound pool, sound copy/paste and a power cycle, and an untouched sound
   read OFF. Not covered: SysEx and Overbridge transfers, undo, randomize, song
   mode.
2. **Runtime access:** still no stock push routine located. 0013 does not need
   one: a tick in the screen's idle routine (`0x400a2aaa`, about 20 a second,
   UI context) reads each track's live sound through `shared_sound_of` and
   copies the step into a 12-byte table the audio interrupt reads. Kit loads,
   pattern changes and sound loads reach the audio within a tick.
3. **Editing:** dead id 5, renamed HPF, on a second FILTER page (page 13),
   with gates on `page_get_value`, `param_apply_delta` and `param_value_text`
   chained behind 0004's (see 0013's registry entries). Its container index
   stays -1, so stock never treats it as one of the 42 words: as expected, it
   cannot be p-locked or reached over MIDI.
4. **Room:** cave9.
