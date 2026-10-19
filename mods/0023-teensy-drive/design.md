# 0023-teensy-drive: the Teensy's SD card in the Rytm's own file browser

Status: milestones 1-3 built and checked in rytm-emu (2026-10-08).

## Goal

GLOBAL > SAMPLES (and the SMPL slot browser) lists a folder **TEENSY** next to
the +Drive's own (Factory, incoming). Inside it the Teensy's card: folders and
.wav files with sizes, browsed with the browser's own keys. LOAD TO PROJ on
Teensy files adds them to the project's **Teensy pool** (on the Teensy) instead
of loading audio into the Rytm; DSP SAMPLE's SMP then picks from that pool, as
the Rytm's SMP picks project sample slots. The knob tree walk of 0021/0022 stays
as a fallback.

## How the browser reads the +Drive [measured, OS 1.73 disassembly, rytm-emu]

- The browser view keeps a **directory model** at view+0x538 (a second pointer
  at +0x540). Its class: vtable `0x401d7a0c`, 16 methods; ctor
  `0x4007ecdc(this, path, flag)`; `0x4007eb58`/`0x4007ebae` build it from the
  root / an id.
- Model fields: +260/+264/+268 a vector of 8-byte shared_ptrs (begin, end,
  capacity) to **entry records** of 0x114 bytes: +0 node id, +4 type (u16),
  +12 read position, +20 name (NUL-terminated); +272 a 16-byte **dir handle**
  (+0 dir id, +4 block, +8 offset, +12 index); +288 open flag; +292 dir id;
  +296 the ".." id (the way up); +300 a flag.
- Methods used by the row drawer (`0x400e5f28`): +12 count, +16 name(i) (copies
  rec+20), +24 is "."/"..", +28 is dir, +32 is file, +40/+60 size values (+60
  default 100,0 when unknown), +44 enter(i) -> `0x4007eb04`.
- Fill (`0x4007e8e4`): `rewind(dh)` `0x4007bf88`; check `exists(id)`
  `0x40080766` and `is_dir(id)` `0x4008095c`; then `readdir(dh, rec)`
  `0x4007c048` until it returns <= 0 (end) / -1 (error), each record wrapped in
  a shared_ptr (control block vtable `0x401d7a54`) and pushed. Non-root folders
  start with "." and ".."; ".."'s id goes to +296.
- Enter (`0x4007eb04(this, id)`): `exists(id)`, `is_dir(id)`, then
  `opendir_id(id, dh)` `0x4007c032` (only stores the id, clears the position)
  and fill. `opendir_path(path, dh)` `0x4007bf9a`; the root's id from
  `0x4007e7a4` (opendir of the root path string `0x4023e479`).
- readdir: FS mutex `0x419f5320` (take `0x400010bc`, give `0x400011ee`); reads
  the folder's block (`0x4007acde`), decodes one on-card entry
  `[id u32][reclen u16][namelen u8][type u8][name]` into the record
  (`0x4007adc0`).
- Node functions take an **id** and resolve it with `0x40080498`: ids 2..65535
  are on-card nodes (an LRU cache at `0x403c81f0..0x403c89f0`, released with
  `0x400803c0`, which only touches pointers inside that cache); ids
  `0x1000002..0x1000101` are RAM nodes at `0x41ab9340 + 128 x (id - 0x1000002)`;
  `exists()` checks larger ids against `0x41847e78 + 0x1000000`. Node bytes
  read: +0 bit 0 is_dir, +1 bits 0/1/2 flags (bit 1: size at +8), +4 a count,
  +12 bit 0; size `0x400808a4` walks the node's extents (`0x4007cdfe`,
  `0x4007cc90`).

## The hooks

Teensy ids: `0x7E000000 | kind << 23 | folder << 12 | entry` (kind 0 folder, 1
file; folder < 1024 as the Teensy's index, entry < 4096); `0x7E000000` itself
is the TEENSY folder (the card's /Samples).

1. **readdir** `0x4007c048`: dir id is a Teensy id -> "." and "..", then the
   folder's subfolders and files from the cache, as records (id, type, name).
   The +Drive root (id from `0x4007e7a4`): after its own last entry, one more:
   TEENSY.
2. **resolve** `0x40080498`: Teensy ids -> a small fake node (is_dir bit, size)
   outside the cache, so release ignores it.
3. **exists** `0x40080766`: Teensy ids -> true.
4. **size** `0x400808a4` (and `0x4008084a`): Teensy files -> their size from
   the cache (the extent walk would read garbage from a fake node).
5. Later (milestone 3): **LOAD TO PROJ** (the menu action behind the string at
   `0x40257c10`, refs `0x400e4a9a`/`0x400e4c52`): ticked Teensy files -> a
   "pool add" message to the Teensy, not the Rytm's loader.

## The data: the Teensy's listings, asked for and cached

- Rytm -> Teensy `0D <folder hi> <folder lo>`: list a folder; Teensy -> Rytm
  `0E <folder hi lo> <first> <total> <entries>`: per entry kind, size (4 x 7
  bits), name (up to 24 chars). A cache of a few folders on the Rytm (a cave in
  RAM; 0021's cave11/12 neighbours, or a new one).
- **The open question: waiting.** The browser fills a folder in one go
  (readdir until the end), in the UI task. Options: (a) readdir asks and waits
  for the answer (~50..200 ms over USB) with the RTOS's task delay so the MIDI
  task can take the reply - needs the delay function found (not among the
  emulator's known RTOS calls: task_create, queue_send/recv); (b) answer "."
  "..", "(loading)" at once and make the browser refill when the reply comes -
  needs a safe way to ask the UI task to refresh; (c) have the Teensy push the
  whole tree ahead of time - too big for the Rytm's spare RAM (1737 files x
  ~32 B = 55 KB; 15580 on a large card). Prefer (a); research first.

## Milestones (each tested in rytm-emu, committed, never near hardware untested)

1. **A TEENSY folder with fixed test entries** (no Teensy): hooks 1-4 with a
   built-in list (two folders, three files). GLOBAL > SAMPLES shows TEENSY;
   entering shows the test entries with sizes; ".." goes back; the +Drive's own
   folders unchanged. This proves the hooks.
2. **Real listings from the Teensy**: 0D/0E, the cache, the wait (above), the
   Teensy (sim and sketch) answering from its index.
3. **LOAD TO PROJ -> the Teensy pool**: per project, IDs on the Teensy; DSP
   SAMPLE's SMP picks pool slots, named on the knob; the pool kept on the card
   per project (the plan's "pool and IDs").
4. **Review before hardware**: these hooks sit in the filesystem code; a bug
   there could harm the +Drive on a real Rytm. Read-only paths only (no hook
   writes or alters on-card data), checked against every FS call the browser
   makes.

## Milestone 1, built (2026-10-08)

teensy_drive.c wraps readdir, resolve, exists and the two size functions
(detours re-emitting each function's first instructions; .td/.tdd/.tds in
cave16's tail). Measured in rytm-emu (build tag lp3, cold boot of a copy of the
user's card): GLOBAL > SAMPLES lists Factory, incoming, **TEENSY**; TEENSY shows
.., Drums, Synths, Kick 808 0.11MB, Pad Long 4.57MB; Drums shows .., BD Test 1,
BD Test 2; ".." goes back up with the folder selected; the +Drive's own folders
as before; no faults. Facts found on the way [measured]: entry records' type is
1 for a folder, 0 for a file, +8 the containing folder's id; the root's id is
2 and Factory's 0x01000000 (the RAM range); a file row draws its size as text
only when its node has +12 bit 0 set (else a bar) and +1 bit 1 (size at +8).

## Milestone 2, built (2026-10-08): the Teensy's real listings

- The wait: the firmware has no task delay, but a microsecond sleep that blocks
  only its caller, `sleep_us(n)` at `0x40098c18` (DMA timer 1, ~1 us a count,
  a binary semaphore; used by the OS itself for 1 ms SD polls up to 3 s)
  [measured in rytm-emu by a subagent: other tasks ran during a 50 ms sleep].
  The first readdir of a Teensy folder sends `0D <folder>` and sleeps in 10 ms
  steps, ~400 ms at most, until the listing is complete.
- `0E` (6 entries a message: kind, id, size in 4 x 7 bits, name up to 23)
  reaches td_sysex through 0022's router, which calls the mailbox at
  `0x401b9a74` (magic 'TDRV') - the same scheme as 0021's names mailbox. (Since
  2026-10-10 the mailbox is 12 B: magic, `td_hook` for 0E and 14, and
  `td_pool_tab`, which 0021's user-slot pool knobs call in the UI task for the
  project's pool table - the table, or 13 asked once in ~200 draws while it is
  stale; `.td2` moved 4 B to 0x401b9a80, research R7.) One
  folder is cached, up to 512 entries, in 16 KB from the firmware's allocator
  (`0x400829d4`, on first use).
- Folder numbers are the Teensy index's (breadth first, folders with .wav below,
  name order); the simulator numbers its library the same way.
- Checked in rytm-emu (build lp3, a headless window with the simulated Teensy on
  the user's library): GLOBAL > SAMPLES > TEENSY shows Drums, Packs, Synths;
  Drums > Hits > TR808 > BD lists its 25 files with sizes (BD0000 0.02MB, BD0010
  0.25MB, ...) and the scroll bar; each folder asked once (0, 1, 4, 13, 19).
- Not yet: the real Teensy answering over the bridge (the sketch compiles with
  the 0D handler; untested on the board); LOAD TO PROJ (milestone 3).

## Milestone 3, built (2026-10-08): LOAD TO PROJ -> the Teensy pool

The Rytm's own samples are "flex" (its RAM), the Teensy pool "static" (streamed
from its card), as the Octatrack's two lists. LOAD TO PROJ runs a job (lambda
`0x400ea710`) that per ticked entry finds a free slot (`0x400b81c4`), makes a
16-byte file reference (`0x4007e62c(model, index)`, via `0x4007fa6e(id)`), and
loads it (`0x400b712e(manager, &ref, slot)`, counted for "N SAMPLES LOADED")
[measured]. The job's two calls (`0x400ea7b4`, `0x400ea7ca`) are pointed at
0023's wrappers: a TEENSY file sends `0F <folder hi lo> <file hi lo>` and gets a
marked reference ("~POO"), which the load wrapper counts as loaded - nothing
read, no Rytm sample memory used. [measured: a detour on 0x4007e62c itself
fired for every visible row on each redraw, adding seven files over and over;
hence the call sites.] The Teensy (sim: pool.json; sketch: /.rytm/pool.bin with
names, checked against the index at boot) keeps the pool; DSP SAMPLE's SMP picks
a pool slot when the pool is not empty (else the knob tree walk), named on the
knob, the title "POOL".

Checked in rytm-emu (dtboot, the Teensy's 0E listings injected as USB MIDI 50M
after each YES): TEENSY > Drums > Hits > TR808 > BD, BD0000 ticked, LOAD TO
PROJ: the Rytm sends exactly 0F 00 13 00 00 (folder 19, file 0) and shows
"1 SAMPLE LOADED". (DTBOOT_STEPS screenshots change the timing enough that the
injected listings miss the wait; and the headless window's timed presses can
land while the UI task waits - both test artefacts.)

Open: the pool per Rytm project (the project's name not found yet); the real
Teensy's 0D/0F handling untested on the board (compiled); a review before any
hardware (milestone 4).

## Milestone 4, built (2026-10-08): safety guards

A review of every filesystem path the TEENSY folder reaches [measured, rytm-emu]
found one write - CREATE DIR inside TEENSY made the folder in the +Drive's root
(its path was "") - and three hazards: 16-byte fake nodes read past their end
(an id -> path walk of 21312 rounds), the stock slot browser able to hand a
Teensy file to the real loader (which copies the reference into the slot before
checking it), and the fake folder not write-protected. Fixed:

- fake nodes 128 B zeroed (.tdn, cave12); the folder's b1 bit 0 set: RENAME,
  DELETE DIR answer "WRITE PROTECTED" before asking for a path
- 0x4007c5d4 (id -> path): Teensy ids 0 at once
- 0x4007fff4 (a reference's check): Teensy ids -1 (not found)
- 0x400b712e (load) wrapped itself: the pool mark loaded, other Teensy
  references fail first - no slot ever holds one
- CREATE DIR's mkdir (0x400ea646): refused when the folder's path is "" ("ERROR")
- no Teensy: one ~400 ms wait per folder open, not three; cache zeroed when
  allocated; parent masked; a root readdir error no longer hidden

Re-checked on the build (rytm-emu, scratch card copy): CREATE DIR inside TEENSY
and a subfolder (no mkdir, no sector writes), CREATE DIR in the root (works),
RENAME/DELETE on folders and files, browsing with listings, LOAD TO PROJ (0F,
"1 SAMPLE LOADED"), the slot browser picking a TEENSY file (refused, no 0x7E
reference in RAM), no Teensy (one ask, ~400 ms). Not covered: Transfer, hardware.

### No real TEENSY in the root (2026-10-09; review MEDIUM 6)

Transfer lists the fake TEENSY too, and its mkdir /TEENSY/x made a real /TEENSY
in the +Drive's root (stock does the same for any path: its FS mkdir request
makes each level in turn), which the browser then listed as a second TEENSY
[measured, rytm-emu]. Hiding a real one would hide its files; renaming ours
would not stop the duplicate. So a real one is never made:

- 0x4007b3b0 (add an entry to a folder: under mkdir, file create, rename, move,
  format) is wrapped (td_link_entry): no entry named TEENSY, any case, in the
  root (id 2) - -1, which every caller treats as failure.
- 0x4007c170 (mkdir(path)) is wrapped (td_mkdir_entry): /TEENSY and everything
  below it refused before stock's code. Needed because Transfer's request goes
  on to the next level after one fails, and stock mkdir reads the new name at a
  stale stack offset when the parent is missing - a wild read [measured: stock
  1.73, Transfer's mkdir /factory/x/y (factory is write-protected) reads
  0x8351e2e8 from 0x4007c1d2 under strict mode]. A stock bug, reachable on
  stock through Factory; this keeps TEENSY from becoming a common way to it.

Checked (rytm-emu, lp3n, `DTEMU_STRICT=1`): Transfer's mkdir /TEENSY, /teensy,
/TEENSY/new and the renames /incoming/BD KNOCK -> /TEENSY and -> /TEENSY/BD KNOCK
all fail (reply 00); mkdir /Teensyx and /incoming/TEENSY work; the root lists
one TEENSY. The browser's CREATE DIR named TEENSY in the root answers "ERROR";
CREATE DIR "A" in the root, project save and load, and the review's TEENSY
scenarios (S3, LOAD TO PROJ, the slot browser) unchanged; no strict access. A
real TEENSY already on a card (only an emulator card made under an earlier
0023 can have one) still lists twice; RENAME or DELETE it in the browser.

### The 12 callers of id -> path (2026-10-09; review HIGH 1)

td_path_entry returns 0 (no path) for Teensy ids. Stock's 0x4007c5d4 itself
returns 0 when the +Drive is not mounted or the id does not resolve, and every
caller copes [read in the disassembly, stock 1.73]:

| caller | function | on 0 | can a Teensy id reach it |
|---|---|---|---|
| 0x4007ddd0 | 0x4007ddb8: id -> std::string | empty string 0x419f2a0c | not seen |
| 0x4007e44c | 0x4007e41c: a browser row's path | "" (0x4024084f) | not seen |
| 0x4007e544 | 0x4007e524: the browser folder's path | "" (0x4024084f) | yes: CREATE DIR in TEENSY ("" -> refused, "ERROR") |
| 0x4007e5b2 | 0x4007e588: folder write-protected? | 1 (protected) | yes: UPLOAD HERE / MOVE HERE into TEENSY ("WRITE PROTECTED DIR") |
| 0x4007e604 | 0x4007e5da: a folder flag (b1 bit 2) | 1 | not seen |
| 0x4009e2c6 | the sample loader into a slot | dereferences | no: its id comes from open 0x4008014c, which fails first through 0x4007fff4 (Teensy references -1) |
| 0x400b71e0 | slot reference -> a path buffer | result unused | no: behind 0x4007fff4 != -1 |
| 0x400bcd80 | after 0x4007fff4 >= 0 | error text | no |
| 0x400e38fe | slot browser: dirname(path) | strcpy from 0 | no: behind 0x4007fff4 != -1; a pool slot's reference is -1 (td_slotref) |
| 0x400ea912 | a job over the ticked entries (called at 0x400ea936) | skips the entry | not seen |
| 0x401028be | after 0x4007fff4 and 0x4007fa6e | skipped | no |
| 0x401029ae | - | skipped | not seen |

So 0 is the right answer: with "" 0x4007e588 would test a folder record it never
filled (it is how MOVE HERE / UPLOAD HERE into TEENSY get "WRITE PROTECTED
DIR"), and the callers that skip an entry on 0 would go on with "" [inferred].
Measured in rytm-emu
(lp3n, strict, counters on td_path_entry's Teensy branch and on each caller's
return): browse TEENSY and TEENSY/Drums, LOAD TO PROJ, RENAME, DELETE, DELETE
DIR, RENAME DIR, SEL FOR MOVE out of TEENSY, MOVE HERE and UPLOAD HERE into it,
CREATE DIR in TEENSY and Drums, the DSP SAMPLE slot browser's TEENSY pick, and
Transfer's FS requests on /TEENSY: Teensy ids reached only 0x4007e544 (CREATE
DIR, once each) and 0x4007e5b2 (MOVE HERE, UPLOAD HERE, twice each), both
handled as above; no strict access.

## A pool per project (2026-10-08)

The Teensy keeps a pool per Rytm project (/.rytm/pools/<PROJECT>.txt, a path
under /Samples per slot, empty slots kept; rytm-teensy). The Rytm names its
project with 10 <name> (the active project's name: 16 bytes at 0x407c89d3, up to
15 characters [measured: follows SAVE AS NEW and LOAD, fixed across a cold
boot]): td_project (.td4) before each 0F, and 0021's ext_project now and then
while one of its machines plays (every 256 voice blocks a check, sent on a
change and every 64th check). Measured in rytm-emu: LOAD TO PROJ sends
10 PRESETS then 0F; PLAITS playing, the first 10 within ~0.2 s, again ~11 s
later with one voice; SAVE AS NEW "QRESETS" sent within 0.5 s. A project loaded
with none of 0021's machines playing reaches the Teensy at the next play or
LOAD TO PROJ. Later: the pool on the +Drive with the project.

## The pool in the stock slot list (2026-10-09; built and tested in rytm-emu)

Research: rytm-emu docs/smpl-slot-list-research.md. On a DSP SAMPLE track
(0021 machine 45) SMP is stock's record 41, so its knob opens the stock slot
list; six jsr-operand patches (registry) make the list and the slot browser
answer with the project's Teensy pool there and stock's everywhere else
(td_empty, td_name_entry, td_browse_entry, td_slotref_entry, td_mark_entry;
td_load_entry hands slot | 0x1000 picks to td_assign). Protocol (rytm-teensy
sim/protocol.py): Rytm -> host 12 <slot> <f hi lo> <e hi lo> (assign, after
10 <project>), 13 (ask); host -> Rytm 14 <replace> <count> {<slot> <f hi lo>
<e hi lo> <13 name bytes>}, routed by 0022 to td_hook. Pool slot N = the pool
file's line N-1; SMP 0 = OFF. Code in cave11 (.td5) and state in cave12 (.td6),
both freed by 0021's folder-walk names, which went (09/0A, 0B/0C, fld_push).

Tested in rytm-emu (lp3n, injected 14/0E as the host would send them):
- SMP turn on DSP SAMPLE: 10 + 13 sent once; after the 14, "0:OFF 1:KICK 909
  2:--- 3:SNARE LONGN";
- YES on a used slot: CONFIRMED, SMP = 1; FUNC+YES: the browser at the root
  (TEENSY listed); into TEENSY, pick HAT OPEN: 10 + 12 01 00 00 00 01, no Rytm
  load (0x4009df06 x0), the row shows >1 at once; NO, list again: 1:HAT OPEN;
- stock track: the list is stock's, no 13, the browser's slot reference takes
  stock's path. Not tested: a +Drive pick on a stock track (this card's Factory
  folders list no files, also with lp3), a +Drive pick in a pool slot (refused by
  design), sound save/reload, the real Teensy.

## Browse lag (browse-lag, 2026-10-16): the UI task never waits on the host twice

Report: with the Pi (USB host) connected the sample browser lags, with the Pi unplugged it does not. Measured in
rytm-emu (OS 1.73, `sfxui`, a card with a folder of 30 samples, the SMPL slot browser, a quiet and a sendfx_link.py
host, `--usb-host-noread`/`-sleep` windows, `--count` on the sites; stock 1.73 as the reference):

- **A scroll step in a +Drive folder costs what stock costs.** Per DOWN: ~124 node resolves (`td_resolve`), ~24 size
  calls (`td_count`), ~21 row draws, 0 readdir, 0 asks, 0 `sleep_us`, 0 USB sends; stock has the same 124 / 21. The
  wrappers answer a non-TEENSY id in ~6 instructions each (an `IS_TID` test and the re-emitted first instructions),
  ~1 k instructions a step; executed instructions for the same 30-step window: stock 981.6 M, sfxui 990.2 M (all of
  the difference is the always-on 0025 reporter, none of it is 0023), with the host absent 946.0 M / 947.2 M. No
  host-linked cost is visible in 0023's stock-path wrappers, with a quiet, answering, non-reading or sleeping host.
- **The one host-linked wait is entering TEENSY.** `td_ensure` (UI task) sent 0D and slept in 10 ms steps up to
  400 ms (40 `sleep_us` calls) for the 0E, and `td_readdir` reset `failed` on every +Drive read, so a host that never
  answers (the Pi without a card: `send_listing` returns when `!card_ok`, rytm-teensy core/pool/pool.cpp:439) cost
  400 ms again at every entry after a visit to another folder. [measured: before, silent host 40 `sleep_us`
  at one entry; answering host 1.]

Fix (0023 only, teensy_drive.c):

- `td_prefetch`: when the +Drive root read appends TEENSY, 0D 0 goes out at once (no wait; `usb_free` guard as
  before), so by the time the user presses YES on TEENSY the answer is in the cache.
- `td_ensure`: waits only for what is left of the 400 ms since the ask (an ask older than that is given up at
  once: no sleep). After a wait or an old ask got no answer, the host is not waited for again for 60 s (`t_fail`,
  `US_NOW()` = the audio block counter 0x419ca2ac, 1500/s [measured 1.73: +1500 per 200 M instructions]); in that
  window entering a TEENSY folder shows it empty at once and re-asks at most once a second, so a late or
  newly attached host fills the cache for the next visit. `td_readdir` no longer touches the cache on +Drive reads.
- Sizes: `.td` 866 of 900 B, `.td2` 958 of 980, `.td5` 1782 of 1792 (td_alloc, td_start there), `.tds` 24 of 64.

Measured after (same runs): silent host 0 `sleep_us` (was 40), 2 asks; answering host 0 sleeps (was 1), the listing
shown (Drums, Kick); scroll counts unchanged. tools/emu/td_emu.py (silent, answer, scroll) ALL PASS.
Not shown by the emulator: any per-step wait; if the real Rytm still lags per scroll step with the Pi, the cause is
outside 0023's wrappers (timing the emulator's USB host does not model) - see the report of this branch.

## 1021: the folder is SIDECAR

The virtual folder's name (`td_teensy`, also what `td_tname` refuses as a real root entry and as a mkdir target) is
now `SIDECAR` (the Sidecar may be a Pi or a Teensy). One byte longer; it still fits (the code is in elekloader's area,
96 KB spare in rui1021). Nothing on the host side names the folder (the Sidecar answers by folder number), so no
host change. A real root folder named TEENSY on a card is now an ordinary folder; one named SIDECAR is refused as
TEENSY was. `td_emu.py` sfx1021 passes [measured, rytm-emu].
