# 0029-sendfx-ui: the Rytm's pages for the Sidecar send FX (design and status, 2026-10-16)

Milestone M4 of rytm-teensy `docs/superpowers/specs/2026-10-16-sidecar-send-fx-research.md` (UI, section 3), on
the storage of `-storage.md` and the word mapping of the M2 side (rytm-teensy `sim/protocol.py`, db56684). OS 1.73,
code in elekloader's DDR area (`area = "elek"`, needs 0027). Branch `sendfx-ui` = `elekloader` + `sendfx-report`.

Tags: **[code]** read in the 1.73 disassembly; **[measured]** rytm-emu, DTEMU_STRICT=1, this tree, 2026-10-16;
**[inferred]** reasoned, not shown. No hardware was used and nothing was flashed.

## 1. What the user sees

| page key | first press | second press (new) | knobs |
|---|---|---|---|
| AMP (tracks 1..12) | AMPLITUDE | **AMPLITUDE 2** (page 12) | A SFX1, B SFX2 |
| SRC on the FX track | DELAY | **SEND FX 1** (page 13) | A TYPE, B P1, C P2, D P3 / E P4, F P5 |
| SMPL on the FX track | REVERB | **SEND FX 2** (page 14) | as SEND FX 1 |

A further press returns to the first page (the stock cycle `index = (index + 1) % count`, 0x4003ab86, as SAMPLE /
SMPL WAVEFORM). The header shows the page's name on every cycle (stock pushes it only when a view activates; the
same fix 0004 made).

Labels are generic (P1..P5) because the effect lives on the Sidecar. TYPE shows the effect's **name**: ids 0..14 as
`SENDFX_TYPES` until the Sidecar sends its list (21 SENDFX NAMES); an id without a name shows `FX<n>` (1..63) or
`UFX<n>` (64..127); `!NAME` when the Sidecar reported that FX's TYPE MISSING (22 SENDFX STATE). 0029 asks (23) every
~5 s until a 21 arrives. Names and states reach 0029 through 0022's router (param `sfx=1`) and an 8-B mailbox at
0x401b9e54 (cave23's free tail: magic `SFXU`, `sfu_sysex`), as 0021/0023 receive theirs.

## 2. Where the values live (the M2 mapping, confirmed)

| knob | word | half | stored | p-lock |
|---|---|---|---|---|
| SFX1 / SFX2 (each track) | sound index 0 | hi / lo | kit sound, stored slot 41 (stock) | yes: type 41 + fine slot |
| SEND FX 1 TYPE / P1 | FX 29 | hi / lo | kit FX slot 20 (stock) | **no** (kit only) |
| SEND FX 1 P2 / P3 | FX 38 | hi / lo | kit 0x816 (0025) | yes: types 42 / 46 (0025) |
| SEND FX 1 P4 / P5 | FX 39 | hi / lo | kit 0x818 (0025) | yes: 43 / 47 |
| SEND FX 2 TYPE / P1 | FX 0 | hi / lo | kit FX slot 37 (stock) | **no** (kit only) |
| SEND FX 2 P2 / P3 | FX 40 | hi / lo | kit 0x81A (0025) | yes: 44 / 48 |
| SEND FX 2 P4 / P5 | FX 41 | hi / lo | kit 0x81C (0025) | yes: 45 / 49 |

hi = bits 8..14, lo = bits 1..7: a lock's coarse slot and its `0x80 0x80` fine slot. Everything is in the **kit**,
so each kit, and each pattern through its kit, has its own send-FX types and values; kit save / reload / copy and
the pattern->kit switch carry them as they carry the stock FX words ([measured] for 0/29 by M0 on stock; 38..41 by
0025's hooks; the two-kit test below).

**TYPE is not p-lockable (documented choice).** An abrupt effect switch per step is rarely wanted, and TYPE shares
its word with P1: a lock on P1 would freeze TYPE's half in the lock word too, so a later TYPE change would not reach
that step. So lock-set is refused for TYPE **and P1** (with a trig held the knob does nothing); words 29 and 0 never
carry a lock from 0029 and each FX has four lockable parameters (P2..P5). A stock or SysEx lock on type 20/37 still
plays (the Sidecar fades a TYPE change over 10 ms, its own rule).

Two knobs share a word: a lock made on one half takes the other half's current value (the step's lock if there is
one, else the base); turning the other knob with that step held updates it. Clearing a lock clears both halves.

## 3. How it is built [code; measured where noted]

- **Two pages per view.** The view factory 0x400ca9b2 builds AMPLITUDE (count `moveq #1` 0x400cafd4, vector
  0x401e1b18 = {7}), DELAY (0x400cb07c, 0x401e1b10 = {8}, key 0x31) and REVERB (0x400cb0d8, 0x401e1b0c = {9}, key
  0x32). Patched: count 2, vectors {7, 12}, {8, 13}, {9, 14} in the area (`ptr` sites).
- **Page ids 12..14:** `page_info` 0x400ff574 detour (`sfu_pinfo`) answers descriptors {name, ids[8]}.
- **Knob records:** parameter records 14..27 (dead `Error` records; the CC tables 0x413dc2d8 / 0x413dcb14 map no
  CC to ids 1..27 [measured]) get, at build (one registry patch): kind 0x35 / 0x39 / 0x38 (AMP / DELAY / REVERB group,
  >= 53 so the bank drain writes the kit word), container index (sound 0; FX 29, 38, 39, 0, 40, 41), range
  0..0x7f00, fine flag +0x14 = 1 (0x400071a6: stock then locks them with the fine slot), no CC / NRPN, no modflags.
  At the first `ev_tick` 0029 points their names (+0x28 long, +0x30 short) at its strings and copies the knob looks
  (descriptor 0x419a4888 + 84 r: AMP DEL's for SFX, a plain dial for the rest; TYPE's value text = `sfu_type*_text`).
- **Halves:** the Sound/FxParameterSet vtables (0x401dcb74, 0x401dcbf0) entries read +0x28, write +0x70, lock get
  +0x3c and lock set +0x40 point at wrappers (`ptr` sites): for ids 14..27 the value is the half, a write merges it
  into the word; other ids pass straight through. `page_get_value` 0x40038462 (detour `sfu_getv`, elek_size 8) reads
  ids 14..27 through the set (a step's lock first), because its own lock path reads the raw word by container index.
- **Writes:** sound index 0 and FX 0/29 through the stock write: live kit, trig array, kit_param_changed -> the
  project copy [measured: 1818 in kit, project slot 41 and trig array]. **FX 38..41 not:** the stock write's
  project-copy observer indexes the 38-entry FX reverse map with them and wrote a stray byte into stored FX slot 0
  [measured, before the fix]. 0029 writes those itself: the set's FX words, the FX trig array (what plays and what
  0025 reports) and the project copy's 0x816..0x81D (0025's storage).
- **Locks:** the stock path (view +0x74 -> set +0x40 -> `track_lock_set` 0x400c0520) with the merged word; the
  incremental save follows. For FX 38..41 it takes 0025's `sfx_incr` branch (a full rebuild, types 42..49) - the
  branch the storage spec's next step 2 asked to exercise [measured: below]. Since 0.5.2 any new lock (this mod's or
  stock's, any track, live record, a track or trig paste) that would take the pattern past the 71 rows the save keeps
  is refused, with stock's LOCK MEM FULL! popup (section 14).
- **core-ar2 events:** `ev_tick` for the init and the ASK. No key hook: the page key's repeat press is the stock
  cycle; no new key or encoder detour (0022/core-ar2's key rules untouched).
- Registry: 6 patches (3 counts, 3 vectors), 8 vtable `ptr` patches, 1 record patch (728 B), 3 detours (page_info,
  page_get_value, the page cycle), the 8-B mailbox (cave23). `excludes = 0004, 0013` (same sites / page ids 12, 13).

## 4. Builds

`sfxui` = hwus1nlel2's mods + 0025 + 0029, with 0022 and 0025 in the area:

    .venv/bin/python tools/build.py --tag sfxui --mods 0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive \
        0025-sendfx-report 0027-elekloader 0028-elek-hello 0029-sendfx-ui --param 0014-hidden-machines:variants=0 \
        --param 0014-hidden-machines:funcgen=0 --param 0014-hidden-machines:test=0 --param slots=1 \
        --param 0021-ext:diag=1 --param 0022-looper:keys=0 --param 0022-looper:sfx=1 \
        --area-elek 0022-looper --area-elek 0025-sendfx-report
    .venv/bin/python tools/verify.py --tag sfxui          # PASS

Supporting changes on this branch:
- **0025 in the area** (`--area-elek 0025-sendfx-report`): its ISR hook 0x401213a0 and rebuild hook 0x400092aa end
  mid-instruction at 6 B, so a registry `elek_size` (10, 8) makes the jmp site cover the whole displaced span
  (elekloader pads it with nops, never run: the stub rejoins). build.py passes it, verify.py claims it. That frees
  0025's 1116 B at the head of `cave` (0x402cc920..0x402ccd7c); 0021's `.ust` (302 B) still holds the block's tail,
  so 0002's whole block is not free. `sfxel` (= sfxui without 0029) builds and verifies too.
- **0022 `sfx`** (default 0: every existing build byte-identical): with 1, its router passes 21/22 to the mailbox.

## 5. Tests [measured] (`tools/emu/sfu_emu.py sfxui all`, every run DTEMU_STRICT=1)

- **pages:** AMP AMP then knobs A/B: index 0 = 1818 (SFX1 24, SFX2 12) in the live kit, the project copy (slot 41)
  and the trig array; a third AMP press is back on AMPLITUDE (knob A changes ATK). FX track SRC: TYPE/P1 (29 =
  0618), P2 (38 = 1200), P5 (39 = 000c); SMPL SMPL: TYPE (0 = 0c00), P3 (40 = 000c), P4 (41 = 0600); project copy
  (slots 20/37, 0x816..0x81D) and FX trig array equal; no other stored FX slot changed; SRC back on DELAY.
- **names:** 23 ASK sent; after 21 the list holds the host's names only; 22 MISSING for FX 1 id 64 -> `!MYVERB`;
  22 MISSING for FX 2 id 6, which the 21 does not name, names it from the 22 -> `!RINGS` (fix 2026-10-16: before,
  an id the Sidecar lacks - a reserved built-in, an empty UFX slot - showed `FX<n>` / `UFX<n>` without the `!`,
  found by rytm-teensy `sim/sendfx_e2e.py names`, the emulated Rytm against the real engine core).
- **End to end with the core** (rytm-teensy `sim/sendfx_e2e.py all`: libcore on the Mac as the Overbridge-link
  host): pages, names (screens `COMB`, `!S4 RES`, `!MYVERB`, `!UFX2`), p-locks while playing, kit travel on
  pattern change, the core's SendFx on a synthetic stem. The value text shows 7 characters: an 8-character
  `!NAME` loses its last one (`!S4 RES`).
- **locks:** RECORD, trigs on steps 1 and 5, step 1 held: SFX1+SFX2 lock BD index 0 (0618, fine flag set, step 5
  free); on the FX track P2 locks FX 38 (0600), TYPE refused (no lock on 29); the incremental save ran (5) with
  full rebuilds (2: 0025's >= 38 branch); A01's stored slots (41,0)+fine, (42,12), (46,12), no type 9..12 on track
  12. PLAY: the 0x20 reports alternate BD 0618 / 000c and FX 38 0600 / 0000 per step.
- **save:** power-off + cold boot: FX words, BD index 0 and both locks back; SAVE PROJECT AS (129 rebuilds; the
  project copy holds the FX words); live words, project copy, live and stored locks wiped; LOAD PROJECT: all back.
- **stock:** stock 1.73 on that card, LOAD PROJECT: no FX 18..21 / 38..41 lock, no type 9..12; the SEND lock and
  FX 0/29 carried.
- **kits:** A01 on kit 0 with TYPE 1/2, A02 on kit 1 with TYPE 5/6; PLAY A01 then A02: the 0x20 reports carry
  (1, 2) then (5, 6).
- **Cache model:** strict cold boot to 4G under `DTEMU_CACHE=log`: `stale fetches: I-cache 0 no-push 0`.
- Suites on `sfxui`: `sfu_emu.py all` ALL PASS (55 checks), `us_emu.py all` ALL PASS (311), `sfx_emu.py all` ALL
  PASS (75), rytm-teensy `PHASE1_TAG=sfxui phase1.py --emu-only tracks` ALL PASS. A screenshot of SEND FX 1 after
  21 (6 = TESTFX) and 22 (FX 1 id 6 MISSING) with TYPE turned to 6 shows `!TESTFX`.

## 6. Cost against the budgets (rytm-teensy `2026-10-16-rytm-stress-budgets.md`)

- **Audio ISR: nothing.** 0029 has no interrupt code; 0025's reporter is unchanged (now run from the area).
- **UI task** [call counts measured, instructions inferred as each function's full length, an upper bound]: a
  12.5-s session of page switches, base turns and p-locks on both pages (254 ticks): page_info 5010 calls, the
  lock-get wrappers 3641 (the held-trig redraw), page_get_value 408, reads 419, writes/locks 7. 0029's own code
  <= 243 k instructions = **<= ~955 a tick** (budget 10 k), **<= 142 a call** (budget 100 k); the one-off init
  ~1 k. Nothing scales with patterns or locks.
- **Memory:** 2.2 kB of code and data in the area (0x47be0c80..0x47be1a66; 1 kB of it the name list), no heap.

## 7. Open

- **User-FX tags and the UFX slot menu (not built).** The user wants UFX1..n assigned per project like the user
  machines (0021's FUNC + CHRO menu, 19/1E style) and the kit to store each FX's 14-bit tag (reported as 0x20
  track 13). Storage needs a stored, non-lockable kit place **and a live home**: the stored gaps 0x832..0x841 /
  0x902..0x916 are not loaded into the live kit, and the live kit has no known spare bytes (storage spec, option F);
  a per-kit table in the area would not follow RAM kit copies. Next: search the live kit (2531 B) for spare bytes as
  the sound-tag research did, or decide on a per-kit table plus hooks on the kit copy paths; then the menu items.
- ~~Labels per effect type~~: done in sendfx-ui2 (section 8).
- Hardware: never flashed. The DDR-area code runs from cacheable DDR; its timing on the unit is [inferred] fine.

## 8. sendfx-ui2 (2026-10-16): P1 ROUTE, labels from the Sidecar, nothing waits on USB

Branch `sendfx-ui2` (off `remote-ui`: 0026's try-lock pattern, 0022's `rui`). Tags as above; rytm-emu, DTEMU_STRICT=1.
Nothing flashed.

**P1 = ROUTE** (rytm-teensy 3c73542, hardware-measured): label `ROUT` (fits; screens), value text `PRE` for 0..63
(Overbridge OUT 3-4, before the analog distortion / compressor) and `POST` for 64..127 (OUT 1-2). Static in 0029
(`sfu_route_text`), no message.

**24 SENDFX LABELS** (host -> Rytm; rytm-teensy `sim/protocol.py` `sendfx_labels`, tables next to each effect,
`core/fx/knob_labels.h`):

    F0 7D 52 54 24 01 <id> <P2 label 4> <P3 label 4> <P4 label 4> <P5 label 4> {<knob | show << 2> <lo> <base> <name 5>} F7

knob 0..3 = P2..P5; a zone runs from `lo` to the next zone's `lo` - 1 of the same knob (or 127). The value text is the
zone's name, with `show` also `v - lo + base` (a space when 7 characters allow: `MODAL 12`, `STRNG31`); a knob without
zones shows the plain dial's number (the stock text, record 410's functor). At most 12 zones (one message <= 120 B).
The Sidecar sends one 24 per TYPE it plays (a Teensy: CHORUS, COMB; the Pi also RINGS, CLOUDSEED, STUTTER) after the
21s and before the 22s, on 23 ASK and on a project change. A 21 with replace clears 0029's labels, so a Sidecar with
fewer effects leaves no stale ones. No 24 at all: P2..P5 stay `P2`..`P5` with numbers (the old pages).

| TYPE | P2 | P3 | P4 | P5 |
|---|---|---|---|---|
| 1 CHORUS | RATE | DPTH | DLY | FDBK |
| 2 COMB | TUNE | DCY: POS 0..63 / NEG 0..63 | DAMP | SPRD |
| 6 RINGS | PTCH | MODL: MODAL / MONO / STRNG / CHORD + 0..31 | BRIT | DCY |
| 8 CLOUDSEED | CHAR: ROOM / HALL / PLATE / AMBNC + 0..31 | DCY | DAMP | MOD |
| 15 STUTTER | ENG: OFF / ON | LEN: 1/64 1/32 1/16 1/8 1/4 1/2 1BAR | D/P: NONE / DCY 1..63 / PTCH 1..64 | GATE |

0029 side: fixed tables in `.bss` (8 TYPEs x 12 zones, 1040 B), written by the MIDI task (`take_labels`, the entry
hidden while written, `gen` bumped), read by the UI task. The P2..P5 records' short names point at per-FX buffers that
`sfu_tick` refills when FX k's TYPE (read from the FX parameter set, cached from the page's own reads) or `gen`
changes, then asks for a redraw (ctrl + 0x20, as 0026). The P2..P5 value texts are 0029's (`sfu_pNJ_text`), falling back
to the dial's. 0022's router (sfx=1) now passes 21, 22 **and 24** to the mailbox.

**Nothing in the UI task waits on USB.** 0029's ASK, 0022's looper reports (sfx=1 builds) and 0021's UI-task sends
(slots builds: the 10 + 13/18 list ask, the 19 ASK, the 10 + 1E assign) go through 0026's pattern: port configured
(0x413db254 == 1), ring room (0x413db258 + 64 <= 4091), 4 free requests, then a try-lock of the MIDI mutex 0x42f67a28
(0x4000119c: owner 0 -> current task, else 0 at once [code, 1.73: read at 0x4000119c..0x400011b8]); given back with
0x400011ee. Not now: the ASK retries next tick, 0021's list ask after its 200-tick wait, the 19 ASK is asked again, a
1E is not sent (the YES ends in NO TEENSY after the 2 s wait, as with no requests before). 0023 is unchanged (its sends
are on demand: browse, load; another branch works on it) - the only UI-task MIDI_LOCK left in these builds.

**The freeze, reproduced** (`tools/emu/frz_emu.py TAG all`; rytm-emu `--usb-host-gone`, new on its branch
`usb-host-gone`: VBUS off, no bus, then a fresh host and enumeration). Per 0.5 s: UI renders (0x400a2aaa), sequencer
steps (0x40120c38, the writer of the step counter 0x8000e570 [measured]), late key presses reaching the dispatch.

| scenario | sfxui (old) | sfxui2 / rui2 (new) |
|---|---|---|
| restart: 4 host brown-outs mid report stream (SysEx) | 20 Hz, play, keys [measured] | same |
| stall: no-read 3 s, then bus asleep 2 s | 20 Hz, play, keys | same |
| partial: half a 21 in, host gone 0.5 s | 20 Hz, play, keys | same |
| mutex: MIDI mutex owned by a task that never gives it (injected) | **UI frozen at once (0 renders), keys dead; play runs** | 20 Hz, play, keys; 0 MIDI_LOCK calls |

So in the emulator the stock sender survives brown-outs, stalls and restarts by itself (its 400-microframe watchdog
turns the port off, 0x40002566; the request pool stays at 27 free over 12 restarts) [measured]; the old builds freeze
only when the mutex is held forever - the state a task stuck inside the sender (ring spin, request wait) leaves, which
the emulator's host model does not produce. The first UI-task waiter in the old build is **0021's 19 ASK**
(us_ask, return 0x40019e36), not 0029's ASK: 0029's ASK stops once a 21 arrived. That the hardware freeze is this
mutex is [inferred], not shown; the new builds cannot block the UI on it [measured].

**Builds** (`sfxui2` = sfxui's mod set, `rui2` = + 0026 and 0022 `rui=1`; 0026 is optional - sfxui2 omits it):

    .venv/bin/python tools/build.py --tag sfxui2 --mods 0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive \
        0025-sendfx-report 0027-elekloader 0028-elek-hello 0029-sendfx-ui --param 0014-hidden-machines:variants=0 \
        --param 0014-hidden-machines:funcgen=0 --param 0014-hidden-machines:test=0 --param slots=1 \
        --param 0021-ext:diag=1 --param 0022-looper:keys=0 --param 0022-looper:sfx=1 \
        --area-elek 0022-looper --area-elek 0025-sendfx-report
    # rui2: the same + 0026-remote-ui and --param 0022-looper:rui=1
    .venv/bin/python tools/verify.py --tag sfxui2 / rui2          # PASS / PASS

0021's helper `ext_ui_lock` lives in `.us2` (cave12 is full); 0021 slots=0 and 0022 sfx=0 compile as before.

**Tests** [measured, RYTM_TEENSY = the sendfx-labels checkout]: sfxui2 - `sfu_emu.py all` (with the new `labels` and
`cost`), `sfx_emu.py all`, `us_emu.py all`, `frz_emu.py all`: ALL PASS; rui2 - `rui_emu.py all`, `frz_emu.py all`,
`sfu_emu.py labels cost`: ALL PASS. End to end with the real core as the Overbridge-link host (rytm-teensy sendfx-labels `RYTM_MODS=<this tree>
SFX_TAG=sfxui2 sim/sendfx_e2e.py names`): the Rytm's 23 answered by 21, five 24s and 22s; the screen shows COMB's TUNE
DCY DAMP SPRD: ALL PASS. Strict cold boot to 4G under `DTEMU_CACHE=log`, both: `stale fetches: I-cache 0
no-push 0`, no strict access. Screens (git-ignored): `build/emu/sfxui2/labels-rings.png` (SEND FX 1 RINGS: TYPE POST
PTCH CHORD31 / BRIT DCY), `labels-stutter.png` (SEND FX 2 STUTTER: ROUT ENG 1/64 / D/P GATE).

**Cost** (DTCN0 inside 0029's UI entries x 200/132; interrupts inside count: upper bounds): 410 instructions a tick on
average (sfxui2; 333 rui2) over a 12.5-s session of labels, page switches and 300 turns; worst call 68.7 k (an
interrupt inside a tick; 0026's worst is 65 k the same way); the MIDI task's handler 912 mean, 1.5 k worst per
message. Audio ISR: nothing. Memory: 1.2 kB more `.bss` in the area, no heap.

### Hardware checklist (sfxui2; the user flashes)

Files: `rytm-mods/build/sendfx2/` (git-ignored): `Analog-Rytm_MKII_OS1.73_sfxui2.syx` and stock
`Analog-Rytm_MKII_OS1.73.syx`, `SHA256SUMS` (check with `shasum -a 256 -c SHA256SUMS`).

1. Flash sfxui2 (as sfxui). Boot; the Sidecar (Pi on the sendfx-labels kernel) attached.
2. FX track, SRC: SEND FX 1. P1 reads `ROUT`; turning it shows `PRE` up to 63, `POST` from 64, and the return moves
   between OUT 3-4 and OUT 1-2 (as measured for 3c73542).
3. TYPE RINGS: labels PTCH MODL BRIT DCY; P3 shows MODAL n .. CHORD n. CLOUDSEED: CHAR shows ROOM/HALL/PLATE/AMBNC.
   STUTTER: ENG OFF/ON, LEN 1/64..1BAR, D/P NONE / DCY n / PTCH n. CHORUS, COMB: their labels; COMB DCY POS/NEG.
   SMPL: SEND FX 2 the same. A TYPE change relabels at once; a kit / pattern change with another TYPE too.
4. Old Sidecar kernel (no 24): P2..P5 stay P2..P5 with numbers.
5. Regression as sfxui: AMPLITUDE 2, p-locks on P2..P5, save / reload, user slots, +Drive.
6. **Host-yank test:** playing, Sidecar connected, pages open: pull the Pi's power (or its USB) 3-5 times, a few
   seconds apart, and let it reboot each time. Expect: the screen keeps updating, keys and PLAY/STOP work throughout,
   and the names and labels stay (0029 keeps what the Sidecar sent; it asks again only until a first 21 arrives).
   Also with a user slot's list open (0021) and while browsing +Drive (0023 is unchanged and may still wait: note it).
7. Restore: flash `Analog-Rytm_MKII_OS1.73.syx` (stock) from the same folder; the kit's SEND FX words stay in the
   kit (stock ignores 38..41 as before).

## 9. sfx-enum-knobs (2026-10-18): stepped knobs in the stock enum style

Branch `sfx-enum-knobs` (off `sidecar-1017`). Tags as above; rytm-emu, DTEMU_STRICT=1. Nothing flashed.

**The stock reference** [measured: the RAM descriptors 0x419a4888 + 84 r dumped from a booted 1.73 snapshot, all 469
classified; code read at the addresses given]:
- A parameter record (0x401bf918 + 0x34 r) holds the range: +8 min, +0xc max, +0x10 default, 8.8 fixed point. The set's
  value write (param_set_value 0x400a9000, and the delta apply 0x400a887e behind the set's vtable +0x2c) clamps to them
  through 0x40006ff0 (a 12-byte copy from record +8) and then calls the set's vtable +0x70; so an enum of N options is
  just a range 0..(N-1) << 8. FILTER TYPE (record 49): 0..0x600, 7 options. TRIG CONDITION (33): 0..0x4000.
- The step is the descriptor's: +4 / +8 the units per count (normal / pushed: 1 / 2 on every record but tunings), +0x10
  a pointer to a 28-byte encoder profile the knob handler (0x40039f3c) copies and hands to 0x4006f18e. Two profiles
  matter: **0x417e37e4** (the dials': bytes {1,1,1,0}, then {gain 2, 3 counts a step, x1} and {2, 3, x4} pushed - it
  accelerates) and **0x417e37ac** (the enums': {0,1,1,0}, {gain 0, 6 counts a step, x1}, {0, 6, x4}: no acceleration,
  whole steps, and after each step a hold-off that swallows the next counts - 48 units, 3 per count, above 24).
  FILTER TYPE, TRIG CONDITION, SAMPLE LOOP and SMP (0x417e3774, the same bytes), LFO WAV, the filter / LFO MOD types,
  EUC, OP use the enum profile; DISTORTION's DEL / REV PRE/POST (81 / 89: range 0..0x100) keep the dial profile with
  their own draw.
- The look: +0x14 the value text std::function (invoker +0x20, functor = descriptor + 20), +0x24 the knob draw
  (invoker +0x30, called by param_knob_draw 0x400a857c as (descriptor + 0x24, value, x, y, h, 1)). The PRE / POST draw
  0x400fbe1e draws a string where the dial was (text_draw 0x400714e0 with text_font(0x417e389c), "%s"); LOOP's
  0x400fed88 the OFF / ON switch bitmap; FILTER TYPE's 0x400ff0a6 its filter icons.
- Feel, measured under identical turns (3 turns of +8 counts 10M apart, 10 slow, 10 fast 2M apart, 5 of +32): the
  enum profile gives FILTER TYPE 1 / 2 / 5 / 6 steps from the base; the counts depend on the knob's history (after
  the machine list 1 / 4 / 5 / 6), and in the base's first seconds the FX track's views skip the two wake frames
  (an extra step) - so every comparison below runs the reference with the same history, 1500M in.

**What 0029 does now.** TYPE, P1 ROUTE and every P2..P5 whose zones carry the 24's step bit are enum records:
range 0..(N-1) << 8 (record +0xc, rewritten when N changes), FILTER TYPE's descriptor words 0, 1, 2 and its profile
(+0x10), a draw: 0029's `sfu_draw` (the value text centred where the dial was, as the PRE / POST draw) for text
enums, LOOP's switch for a 2-zone OFF / ON set, DISTORTION DEL's PRE / POST draw for P1. Through the set wrappers the
knob's value is the step index and the word keeps what the Sidecar reads:

| knob | steps | stored | an older value reads as |
|---|---|---|---|
| TYPE | OFF + the 21's ids in list order (+ the kit's unlisted id, in place, until moved away) | the id (hi half) | its id |
| P1 ROUTE | PRE, POST | 0 / 127 (lo half) | 0..63 PRE, 64..127 POST |
| P2..P5 with step | the zones in order | the zone's `lo` | the zone holding it |
| P2..P5 without | continuous 0..127 (a dial) | the value | - |

The knob type follows the **base** (kit) TYPE: `sync()` reads both TYPEs from the FX set on every read of a 0029
record and in `ev_tick`, and rebuilds labels, steps, looks and ranges at once when a TYPE, a kit (pattern change, kit
load) or a 24 changed them, so a turn is never stepped by the old TYPE's zones. Locks on a stepped P2..P5 store the
zone's lo (the lock set wrapper converts) and are saved and loaded as any lock word. The 21 list reaches the UI task
through a seqlock (`ogen`, odd while the MIDI task writes); before the first 21 the built-in names' ids are the list.

**0021's list knobs, the same way** (the user's extension, 2026-10-18). 0029 owns the Sound set's wrappers, so it
also steps 0021's lists: 0021 publishes `ext_steps(record)` at a fixed address (`ext_stepbox`, registry `.usm`, the
last 8 B of `.us2`'s former claim: magic `XSTP` + the function; `.us2` 2782 -> 2774 B). It answers mode << 8 | N:

| knob | mode | N | stored |
|---|---|---|---|
| PLAITS ENG (408) | zones | 17 | ceil(128 k / 17), so the host's v x 17 / 128 reads zone k |
| DIGIDRUM ENG (390), until mdpage: MD's page has no list on the SRC page (ENGINE and TYPE on SMPL: a U slot's enums) | zones | 11 | as above |
| DAISYSP / DSP SAMPLE ENG (449 / 416), INP (453), OUT (433), MOD (444, not in a diag build) | zones | 3 / 3 / 11 / 2 / 7 | as above |
| JUNO / FM PAT (382 / 374) with the project's list (16 / 17) | list | the list's total | the index |
| JUNO / FM PAT without a list | all 128 | 128 | the value (one per detent) |
| a U slot's enum knob (1A kind 2) | zones | its 1B count | as above (the plugin decodes v x N / 128) |
| a U slot's preset knob (kind 6) | list / all 128 | its preset list's total | the index |
| a U slot's pool knob (kind 7) | all 128 | 128 | the slot |

0029 asks once a UI tick per record (`xmode`), wraps the record's value text (`sfu_xtext` calls 0021's own text with
the stored value, so DIGIDRUM / MOD still rename their knobs) and swaps in the enum look; when 0021 copies a look in
again (its descriptor set-up, a 1A) or a list goes away, the next read re-wraps or restores the saved words. The page's
value gate (`sfu_getv`) sends a stepped 0021 record through the set (its lock too), not the raw word. DSP SAMPLE's SMP
is stock's sample-slot record (the enum profile already) and is left alone. Without 0021 (no `XSTP`) nothing changes.
CC / NRPN into a stepped knob: the value is taken as the step index, as stock's enums take theirs [inferred].

**24's step bit** (rytm-teensy `sim/protocol.py`, `core/fx/knob_labels.h` `Zone::step`): the zone byte is
`knob | show << 2 | step << 3`; set on every zone of a pure selector. Today: STUTTER ENG (OFF / ON) and LEN (7 lengths).
RINGS MODL, CLOUDSEED CHAR, COMB DCY and STUTTER D/P have numbers inside their zones and stay continuous. An older
Sidecar sends no bit (continuous, as before); an older 0029 masks it off (`kf & 7`).

**Tests** [measured; `RYTM_TEENSY` = the rytm-teensy sfx-enum-knobs checkout] `tools/emu/sfu_emu.py TAG enum typelist
enumlock enumkit ext` (new), with the old ones in `all`:
- enum: LEN and TYPE step exactly as FILTER TYPE under the four turn patterns (LEN 1 / 2 / 5 / 6, TYPE the same, capped
  at 7 options for the comparison), LEN's words only its zones' lo, P1 0 / 127, the looks (ENG the switch, LEN / TYPE
  text, P1 PRE / POST), an older Sidecar's 24 leaves STUTTER's knobs continuous;
- typelist: the UI list is the 21's; the steps follow the list order without skipping; big fast turns land on listed
  ids; an unlisted kit id (7) steps up to 15 and down to 6, and is gone once left;
- enumlock: a LEN lock stores a zone's lo, kept over power-off and a cold boot;
- enumkit: A01 (STUTTER) -> A02 on another kit (CHORUS): LEN's range 0x600 -> 0x7f00, labels follow;
- ext: PLAITS ENG steps as FILTER TYPE with the same history and stores zone lows; DAISYSP ENG / INP stepped; JUNO PAT
  over a 5-name list stores 0..4; a lock on ENG stores a zone low and survives power-off.

**0021's slot menu, from here** (hardware report 2026-10-17): `sfu_tick` also calls 0021's `us_live` (`ext_stepbox`'s
third word) after its own work, timed apart (`lv_*`): a staged 1A committed (the views redrawn), a slot whose
generation the Teensy moved asked again; with 0021's `us_fetch` on the menu's YES, the open track menu steps U1 ACID ->
GRAIN -> METAL and relabels (mods/0021-ext/design.md).

**Results** (builds `sfx1018` = sfxui2's set, `rui1018` = + 0026 / 0022 rui=1; both verify.py PASS) [measured]:
sfx1018 - `sfu_emu all` (196 checks), `sfx_emu all` (76), `us_emu all` (312), `td_emu all`, `frz_emu all`: ALL PASS;
rui1018 - `rui_emu all`, `frz_emu all`, `sfu_emu all`: ALL PASS (rui_emu's frame / escape each failed once while eight
suites shared the machine - the host missed the 30 page-on - and pass alone). rytm-teensy sfx-enum-knobs:
`sim/sendfx_e2e.py all` and `test_core_sendfx` (with the new `test_label_steps`) pass; rytm-teensy pi-user-machines
`sim/um_e2e.py all` with UM_TAG=sfx1018 passes. Strict cold boot to 4G under `DTEMU_CACHE=log`, both builds: `stale
fetches: I-cache 0 no-push 0`, no strict access. Cost (`sfu_emu cost`, x 200/132): 0029 1.6 k instructions a tick on
average, worst call 72 k (an interrupt inside a tick, as before); MIDI task 1.4 k worst; us_live ~100 a call. Audio ISR:
nothing. Memory: 5.4 kB `.bss` in the area (3.8 kB of it 0021's per-record cache), no heap. Screens (git-ignored)
`build/emu/sfx1018/enum-stutter.png` (SEND FX 1 STUTTER: TYPE / ROUT text, ENG the switch, LEN 1/64),
`enum-len-slow.png`, `enum-type-slow.png`, `ext-plaits-slow.png` (ENG's model name where the dial was).

**fix-1020 (2026-10-17): a list knob's name twice.** The stock UI shows a knob's value text where the label is while it
turns; for 0021's stepped list knobs the name is already drawn where the dial was (`sfu_draw`), so a 6-OP FM patch name
was on the screen twice while scrolling. The record's text (`sfu_xtext`, d[8]) now gives the step's 1-based number for
the named modes (zones, list); the draw keeps the name (`xname`). The 128-value knobs keep 0021's text (their number is
in the dial and the label as before). Test: `sfu_emu.py TAG fmname` (screen bands compared; fails on sfx1019).

## 10. rui1038 (2026-10-21): banked list knobs (ext_steps bit 11)

0021's ext_steps answer (mode << 8 | N, bit 10 "beyond the end reads entry 0") gains **bit 11, keep the bank**, which
0026 sets for GRANULAR SRC / WAVETABLE TBL / MULTISAMPLE INST (index << 8 | bank << 5; 0026 design.md "1038"). For such a
record (`xk[]`, appended to sfu_x so the fields before keep their offsets): x_knob passes the word's fraction bits 0xe0 into
the knob's value and x_half keeps them (the value text, 0026's cu_text, reads the bank from them); sfu_s_write and
sfu_s_lset store the index with the bank the word (or the step's lock) holds (`x_keep`), so the knob's arithmetic never
moves or clears the bank; the record's range is (N - 1) << 8 | 0xe0. Without bit 11 nothing changes. [measured, rytm-emu,
`tools/emu/bk_emu.py rui1038 knob range lock`: one index a detent, the bank kept, bank H's 127 within range, a lock by a
turn with a trig held keeps the bank]

## 11. sfx-basewidth (2026-11-12, 0.5.0): BASE / WIDTH on SEND FX 1 / 2 knobs G / H

The owner asked for the stock DELAY / REVERB's BASE / WIDTH filter on the send FX. The Sidecar already has it as DSP:
bus 1 / 2's post EQ is the send FX's return filter (rytm-teensy docs/INSERT-FX.md "POST EQ", "BASE / WIDTH"). So the
Rytm side is a view and a pair of knobs, nothing stored in the kit.

- **Knobs**: SEND FX 1 (page 13) and SEND FX 2 (page 14) had ids[6] / ids[7] = 0, so G and H were free [code, the
  descriptors]. 0026's enc_body passes these pages' encoders to stock (its remote page is not active, no host seq trig
  is held, no bank list), so nothing intercepts G / H there [code].
- **Records 1..4** (`BW0` = 1; FX 1 BASE, FX 1 WID, FX 2 BASE, FX 2 WID). They are the ids 0004-lfo-rnd repurposed on
  hardware, and 0029 already excludes 0004 (records 6..13 carry live CC / NRPN fields: LEV, CC120 / 121 and so on, so
  they were not taken). `set_bw_rec` writes each record at tick init: kind 0x39 / 0x38, container 29 / 0, 0..0x7f00,
  CC / NRPN 0xffffffff, modflags 0, short names `BASE` / `WID`, long name the FX's; `copy_desc` gives it REC_DIAL.
  Run-time only, no new patch site, so the 1.74 port has nothing to derive (the C constants go through ostarget).
- **Values never touch the kit**: the FxParameterSet wrappers take `BW(id)` first: read returns the cache
  (`X.bw[fx][knob] << 8`), write clamps to 0..127, stores and marks the FX to send (`bw_tx`), lock-get answers -1 and
  lock-set is refused (0). So a trig held over G / H locks nothing: there are no p-locks (the Sidecar's step-lock space
  is full at 32 params). `sfu_isext` is true for BW ids, so sfu_getv reads them through the wrapper.
- **Protocol: 0x22 ver 2**, both ways, `F0 7D 52 54 22 02 <fx> <base> <width> F7`. The tick sends a pending FX with
  the try_send pattern (never waits on USB; a busy port leaves the bit for the next tick). From the host, sysex_body
  takes it before the ver-1 check (len >= 10, fx < 2), sets the cache unless that FX has a turn still to send, and
  asks a redraw (`bw_rx` -> ctrl+0x20). An older 0029 drops ver 2 (it checks d[5] == 1); 0022's router already passes
  0x21..0x24 (but 0x23) to 0029's mailbox. Defaults before the host answers: BASE 0, WID 127 (the filter off).
- **Fields** appended at the end of sfu_x: `bw[2][2]`, `bw_tx`, `bw_rx`, `bw_sent`, `bw_got` (counters for tests).
- **Test** `tools/emu/sfu_emu.py TAG bw`: the host sends (40, 90) and (10, 127); SEND FX 1, G +20 x3 sends fx 0 with
  WID 90 and a BASE above 40; records 1..4 are named BASE WID BASE WID; FX words 0, 29, 38..41 unchanged; SEND FX 2,
  H -20 sends fx 1 BASE 10, WID < 127; with a trig held nothing is sent and the step has no lock on word 29.
  Fails on the baseline `sbw0` (nothing sent, the names LEV / ERR), passes on `sbw1` [measured].
- **Cost**: RAM area 29648 -> 29000 bytes spare (648 bytes), blob 74348 -> 74980 [measured, build log].

**Review round (2026-11-12, sbw4).** From notes/reports/sfx-basewidth-review.md:
- **Crossing** (review 2): a host value that crosses a turn on the wire no longer undoes it. Each FX's send is stamped
  (`bw_hold[k]` = DTCN0 | 1, appended after `bw_got`), and a host value for that FX within `BW_HOLD` (500 ms at the
  hardware's 132 MHz) is not taken. A turn not yet sent also wins, as before. The host (rytm-teensy core/host_link.cpp)
  now sends both FX again every 2 s, so a held-off or dropped value is right within 2 s.
- **Redraw only on a change** (`bw_rx`), because the host's 2 s refresh repeats the same values.
- **The WID records' default** `r[4]` is 0x7f00 (127, the filter off); BASE stays 0 (review 4).
- **Init keeps a host value that arrived first**: the WIDTH 127 defaults are set only while `bw_got == 0` (review 5).
- **Test** `sfu_emu.py TAG bw2` checks:
  - the fields hold a host value (offset `X_BW` = 5644 + DL, 2-byte alignment);
  - a host value that arrives while SEND FX 1 is open redraws knob G exactly as a fresh draw of that value, and
    differently from no value;
  - a 22 ver 2 for FX 3 and a ver-1 22 leave BASE / WIDTH alone;
  - a host value just after the turn's send is not taken, while one 600 ms later is;
  - the record defaults are 0 / 0x7f00 / 0 / 0x7f00.
- **Results:** on sbw1, the crossing check and the defaults check fail; on sbw4 all pass [measured].
- **Emulator timing:** rytm-emu's DTCN0 runs at 660 MHz against its event clock (5x the hardware's 132 MHz)
  [measured, hold stamps of the same turn 300 ms and 1000 ms apart], so the hold is 100 ms there. Its UI tick is
  10 ms.
- **Builds:**

  | Tag | .syx SHA256 | Note |
  |---|---|---|
  | sbw2 | 14e73e9d… | tick-based hold, too short; superseded |
  | sbw3 | 4a8510c9… | 200 ms hold, 40 ms in the emulator; superseded |
  | sbw4 | 7e77959f775df05f8a0d1defd76d92e827a0dff8a46ecaaa6f797ece520b39c0 | the fix |

**Re-review round (2026-11-12, sbw5).** Finding 4 of notes/reports/sfx-basewidth-rereview.md: DTCN0 wraps every
2^32 counts, which is 32.5 s at 132 MHz. A send stamp left in `bw_hold` therefore came back for `BW_HOLD` one wrap
after the turn and dropped a host value then.
- **Fix:** the tick now clears an expired hold (`TIMER - bw_hold >= BW_HOLD` -> 0). Only the UI task writes
  `bw_hold`; the MIDI task only reads it.
- **Test** `sfu_emu.py TAG bwwrap`: in the emulator a wrap is 6.51 s at 660 MHz. A host value 6.91 s after the turn
  (inside the stale window for any send between 330 and 380 ms) is taken, and the hold reads 0.
- **Results:** it fails on sbw4 (the value is dropped; the hold is still 0x30f4ac77) and passes on sbw5 [measured].
- **Build:** sbw5, .syx 6dc37d77d6eaf4e1b14c39cbd91b05ef347037659154d0b13a9b49d23ae2b244.

## big-ram: sfu_x in the bundle's DDR region (next build, A3)

Based on twwwy's #34 (sidecar-mods). `sfu_x` (6,706 B: the label lists, caches and counters of the send FX pages) moves from
elekloader's `.bss` to the registry claim `sfu_x` (`[[buffer]]`, pool `sidecar_buffers`, 0x47C04080, 6,720 B) in the bundle's
DDR region. Only the UI task and the MIDI task touch it ("Audio ISR: nothing", measured, as above). The symbol and every
`X.field` access stay: `DDR(struct sfu_x sfu_x, sfu_x, SFU_X)` (an absolute symbol of the same name, `RAM_SFU_X` from the
registry); to put it back, replace that line by `struct sfu_x sfu_x;` and drop the zeroing at the top of `tick_body`.

**Zeroing.** The first call of `tick_body` (`st.ticks == 0`, in `.data`, so the boot copier's image sets it) zeroes the claim,
before anything of this mod reads it; the assembler refuses a claim smaller than the struct. What can run before that first
tick: the parameter-set wrappers, which the OS calls during the project load. `xmode()` already returns 0 while `!st.init`,
`sfu_f_read`'s host-held BASE / WIDTH read returns 0 until `st.ticks` (as the zeroed `.bss` did), `sync()` already ran only
after `st.init`, and the OURS-id paths of the F-set wrappers (`sfu_f_read` / `sfu_f_lget`: the stored half without the knob
mapping; `sfu_f_write`: no write, returns 1; `sfu_f_lset`: no lock, returns 0), which reach `X` through `to_knob` / `to_half`
(`tcache` loops over `X.un`, junk before the zeroing), return those fallbacks until `st.ticks`. So do the BASE / WIDTH write (`sfu_f_write`
returns 1 and keeps nothing; the host's 2 s refresh sends BASE / WIDTH again) and `see_fxset` (returns before its compare): nothing of
`X` is read or written before the zeroing by an F-set wrapper. `sfu_emu pretick` calls the four wrappers, the BASE write and `see_fxset`
by hand with `st.ticks` 0 (tools/emu/sfu_pretick.s, poked over `sfu_tick`), against a control with the tick run. A host message before the
first tick is not expected [inferred]: the host talks after a Rytm hello, which 0026 sends after its own first tick (and 0029's
`ev_tick` order 60 runs before 0026's 70 in each tick).
`ram_emu.py` (suite `ram`) checks the zeroing over junk; the features run on a dirty base (see 0026's design.md).

**Step 6 (full names and extra pages): `sfu_x` grew and `sfu_p` was added.** `sfu_x` is 7,940 B now (claim `sfu_x`
0x47C04080, 7,952 B): A3's 6,706 B plus the full names (`lng`, `lname`, section 12). `sfu_p` (4,736 B, claim `sfu_p`, after fix round 1; was 4,704 B
0x47C05F90) holds section 13's names (`xsh`, `xlng`: 4,224 B for 16 TYPEs) and state. Both are zeroed together in the first
`tick_body` (the assembler checks both claims), and `sfu_p` is read before that by nothing: `pq()` returns "not paged"
until `st.ticks`, `sfu_get` leaves `fxview` alone until then, `key_body` returns while `!st.init`, and the MIDI task's
handlers (`sysex_body`: 51, 22 ver 3) only run after the mailbox is published, after the zeroing. What the two features
add to elekloader's area (`.run`/`.bss`): no `.bss`; the code and constants (3,592 B in all with `sfu_pages`, measured: the area spare went from
35,908 B to 32,316 B) and `sfu_pages` (108 B; it is written at run time now, the OS reads it before the first tick). The
tables would have cost 5.3 KB more in the area (the PR: 9,652 B in all).

## 12. sfx-full-names (issue #14): the effect's full name in the upper left while turning P2..P5

Based on twwwy's #18. Before this, the upper left showed "Send FX 1" / "Send FX 2" for P2..P5 whatever the TYPE. It now
shows the effect's own name for the knob ("Pre-delay", "High decay"), as the stock DELAY / REVERB pages do.

- **Message: 51 SENDFX FULL NAMES (host -> Rytm).** The host sends it right after each TYPE's 24, on the same triggers:
  `F0 7D 52 54 51 01 <id> <first p 1..16> <n 1..4> {<short 4> <long 16>} x n F7`.
  - `first p` counts the effect's own P1..P16, so the Rytm's P2..P5 are `first p` 1, n 4. Names from P5 on are the pages of
    section 13.
  - The 24 is left alone: `take_labels` drops a 24 of any other length, so an older 0029 would lose the labels too.
  - An older 0029 ignores 51 (and an older 0022 does not route it). An older Sidecar never sends it. Either way P2..P5
    keep "Send FX n".
- **0022:** its sfx router also passes 51 to 0029's mailbox (`looper.c`, one more compare in the `LP_SFX` build).
- **0029, appended to `struct sfu_x`** (the emulator tests' offsets stay as they were): `lng[NLT][4][17]` the full names
  beside `lab[]`, `lng_ok` (bit k: `lng[k]` belongs to `lab[k]`'s TYPE), `lname[2][4][17]` P2..P5's record long names now,
  `lng_rx`, `lng_drop` (counters).
- **MIDI task:** `take_names` needs the TYPE's 24 first, since its entry holds the names. It fills `lng[k]` with bit k
  clear, then sets the bit and bumps `gen`; trailing spaces are trimmed. A 51 whose first P is past P16 is dropped whole
  (review L6: no `lng_ok`, no `gen`; `lng_drop` counts it). A 21 replace frees the entries, which takes the names with it.
  A 24 for a TYPE the table has not got clears `lng_ok` bit k (its 51 follows); a 24 sent again for a TYPE it has keeps
  them (review L3, section 13).
- **UI task:** `relabel` (on a TYPE or `gen` change) copies the names into `lname` and points records `ID0 + 4 + 6k + j`
  field 10 (the long name) at `lname[k][j]`; with no name it points at `l_fx1` / `l_fx2` as before.
- **Tests:** `sfu_emu.py TAG fullnames`: RINGS on SEND FX 1 names P2..P5 Pitch / Model / Brightness / Decay and keeps its
  labels PTCH MODL BRIT DCY; SEND FX 2 on OFF keeps "Send FX 2"; STUTTER on SEND FX 2 names "Decay / pitch" (13
  characters); without any 51 "Send FX 1"; a 51 before its 24 is not used. The screen `fullnames-rings.png` shows PITCH in
  the upper left while P2 turns. Hardware: reported by the contributor (a 16-control user effect, OS 1.74 + Pi 4), not
  checked here.

## 13. sfx-pages (issue #15): a user effect's P5..P16 on SEND FX pages 2 and 3

Based on twwwy's #19, with the owner's key cycle (no SRC + DOWN gesture, no held-back press). A user effect (API 3) can
have P1..P16; SEND FX showed P1..P4 only (as P2..P5). Now an effect with more has pages:

| page | A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|---|
| 1 (as before) | TYPE | ROUT | P2 | P3 | P4 | P5 | BASE | WID |
| 2 | P5 | P6 | P7 | P8 | P9 | P10 | P11 | P12 |
| 3 | P13 | P14 | P15 | P16 | - | - | - | - |

(P = the effect's own; the Rytm's P2..P5 are its P1..P4.) The title says the page: `SEND FX 1 2/3`. An effect with only
P1..P4 (every built-in) has one page and nothing changes: no title suffix, no press taken.

- **Keys: a further press of the page key.** On the FX track SRC cycles DELAY -> SEND FX 1 -> DELAY and SMPL REVERB ->
  SEND FX 2 -> REVERB. For a user effect with more pages SRC cycles DELAY -> SEND FX 1 (page 1) -> page 2 -> page 3 ->
  DELAY (SMPL the same for SEND FX 2). On page 1 or 2 the press steps to the next page and is **eaten**; on the last page it
  is stock's, which returns to DELAY / REVERB. An `ev_key` subscriber, order 5 (before 0026's 10):
  - the press is taken only when SEND FX k is the screen **as worked out at the key** (`top_page(PG.ctrl)`, not the
    tick's `ontop`: review M1), FUNC and UP are up (0026 binds UP held, then SRC, the source list, 1046: it stays
    stock's and 0026's, as before; FUNC + page key likewise), and the effect has a page left;
  - a taken press's repeats and its release are taken too (`kdn` = the key is down, `ate` = its press was taken, both per
    key; a lost release leaves `kdn` up, so the key's next press is taken for a repeat: after an eaten press it is eaten
    without a step, after a passed one it is passed, and its own release then clears `kdn`: one press is wasted, then it
    heals [review L1; the first version of this text said a press of its own was never eaten]);
  - `PG.mods` follows FUNC and UP (down / up) only to know that they are held; they are never taken.
  There is no held-back press, no replay of a key through stock and no arrow takeover (review L1 and L2 are moot).
- **Always page 1.** Leaving the SEND FX page - to any other page or track, a menu, a pop-up, a kit change (the TYPE words
  another), a project load, a host 21 replace (the labels and names gone) or the port going down (the host dropped) -
  puts that FX back on page 1 and its real records back (`page_set(k, 0)`: `restore_recs`, `relabel`, `sync`; the tick does
  it when `top_page` is not that FX's page, `PORT_STATE != 1` or the kit changed (below), `page_count` when the TYPE changed
  or the page count fell below the page). Coming back shows page 1. The paged values are the Sidecar's per FX, not the
  kit's.
- **Fix round 1 (review of the step, 2026-11-24).**
  - **H1, the port down:** `key_body` passes SRC / SMPL to stock while `PORT_STATE != 1` (a paged effect's `np` is not
    touched when the host goes, so the key used to step to page 2 and the tick put it back 50 ms later: SRC could never
    leave the page), and `page_count` counts no pages while the port is down (title and key agree: `SEND FX 1`). The tick
    runs `relabel` when the port goes or comes back (`PG.up`), so the pages return with it, on page 1.
  - **M1, a kit change that keeps the TYPE:** when a page past 1 is entered (`page_set`, from page 1) the tick's reset has
    two more witnesses: `PG.kit[k]`, `ACTIVE_KIT` (0x800067b8, the kit number: 0025 and 0026 read it as well) and
    `PG.ksig[k]`, a fold of the FX k's six FX words read with the raw `F_READ` of the set (the kit's, never a lock). A
    page cannot change either (every write is routed to `pv` by the wrappers), so a difference is a kit load: another
    kit number, or the same slot loaded again with other words. Either resets to page 1.
  - **M2, 0026's page or splash over a stock SEND FX page:** 0026's host page and its splash are overlays; they push no view,
    so `top_page` still said SEND FX 1 and the press paged the hidden stock page (and, with SRC in the host's catch mask,
    the host never got the key). Guard: `sfu_p.ovl` (offset 4704 = 0x47C071F0), nonzero while `st.active | st.splash_on`
    of 0026; 0026 writes it at each change (`ovl_pub`), only once 0029's mailbox magic `SFXU` is up (set after the first
    tick's zeroing of `sfu_p`), and `key_body` passes the key on when it is set (FUNC / UP are still followed). Why not the
    other option, subscribing at order 15 after 0026: 0026 takes UP and FUNC itself (the combos, seq mode, a mask naming
    them), so 0029 would no longer see them held and UP + SRC would page; and a key 0026 passes while its page is open
    would still reach 0029, which pages the hidden stock page again. The order stays 5.
  - **L3:** a reset the tick or `page_count` makes while SEND FX k is the screen pushes its title again (`PG.rt`, worked
    in the tick), so `2/3` never stays on the glass. **L2:** `sfu_key` returns before `timed()` when `st.init` is 0 (sfu_x
    is zeroed by the first tick). **O1:** `take_labels` no longer sets `idp1` to 0 while it rewrites an entry in use (a
    24 sent again for the TYPE on the screen): a relabel in that window saw no entry, `np` 0, and reset the page; the
    copies are bounded and the `gen` bump redoes them. (Not showable in the emulator: it needs the MIDI task between two
    stores.) `sfu_p` is 4,736 B (4,726 B and a 10 B pad: the claim is 16-byte aligned and `ram_emu first` wants every claimed word zeroed).
- **A 24 sent again** (a reconnect, an ASK) for a TYPE the table has keeps the page (review L3): `take_labels` only clears
  `lng_ok` bit k and the page count `np[k]` for a TYPE new to the table; the 51s that follow the 24 write the same names
  and the page count is `np` alone, not `lng_ok`, so a name being rewritten never shortens it.
- **Which page is the screen** (`top_page`): the view the SEND FX knobs were read through (`sfu_get` keeps it) is in the
  controller's view list (ctrl + 28) before SamplerLedView, nothing but a pad mode's view after that, and its knob A is
  TYPE's record. [measured, rytm-emu 1.74, class names by RTTI: MainScreenView TransportView PatternGridView KeyboardView
  **FxPageView** PatternSelectionView HelpBubbleView QuickPerformanceView SamplerLedView on SEND FX 1; REVERB is another
  FxPageView object; GLOBAL leaves one menu view alone] A pop-up over the page (FUNC + RECORD's COPY PATTERN, TRK held +
  FUNC + STOP's PASTE FX SETTINGS) is not that list: it counts as leaving.
- **No free parameter records** [measured: the 1.74 record table (469 records) read from a booted base: 0 is the
  sentinel, 1..4 BASE / WID, 5 7 11 12 13 carry stock CC fields, 6 8 9 10 are live (TYP, Solo, Mute, LEV), 14..27 are
  0029's, the rest stock or 0021's]. So the FX's own 8 records switch while a page past 1 shows (`apply_page`): the FX
  set's wrappers take `pq()` first - read answers `pv[fx][q] << 8`, write keeps it and marks it to send, lock-get -1,
  lock-set refused (no p-locks, as BASE / WIDTH) - plain dials 0..127, the 51's names (short; long in the upper left,
  else "Send FX n"), and page 3's E..H get id 0 in the page descriptor (stock draws REVERB's gaps the same way: empty).
  Page 1 again (`restore_recs`): `set_rec`, the value texts, TYPE / ROUT's looks, `set_bw_rec`, the ids; then `relabel`.
  The kit's words are never touched: the switch is in the wrappers, before any word.
- **Protocol** (both sidecar-firmware `sim/protocol.py`):
  - 51 SENDFX FULL NAMES chunks P5..P8, P9..P12, P13..P16 (first p 5 / 9 / 13), each with the short name too; the page
    count is the highest P named (`np`). Built-ins send none.
  - **22 ver 3 SENDFX XKNOBS**, both ways: `F0 7D 52 54 22 03 <fx> <first p 5..16> <n 1..12> <values> F7`. The tick
    sends a turned FX's P5..P(4 + nx) with try_send; a host value is taken unless a turn is pending or was sent within
    `BW_HOLD` (the crossing rule of section 11). An older 0029 drops ver 3 (its ver checks); 0022 routes 0x22 already.
  - The key cycle needs nothing new from the host: it is all on the Rytm. The host must keep sending the 51s after each 24
    and the values (22 ver 3) after a TYPE change, as before.
- **State**: `struct sfu_p` (its own symbol, so sfu_x's offsets stay): names (`xsh`, `xlng`, `np` per label entry),
  `pg` / `npg` / `nx` / `pv` / `pv_tx` / `pv_hold` per FX, `kdn` / `ate` / `mods`, `fxview`, `ctrl`, the paged names and
  titles, counters (`pv_sent`, `pv_got`, `steps`, `resets`, `retitles`). `sfu_pages` is writable (the title and page 3's
  empty ids): 108 B of `.data` in the area, the one thing of this feature that must stay there (the OS reads the page
  descriptors before the first tick).
- **Where it lives (the owner's step 6):** every table and the state of this section and of section 12 sit in the bundle's
  DDR region with `sfu_x`: `sfu_x` grew to 7,940 B (claim 7,952) and `sfu_p` is its own claim (4,704 B, 4,736 B after fix round 1), zeroed in the first
  `tick_body` and guarded until `st.ticks` as `sfu_x` is (section "big-ram": `pq()` answers "not paged" and `sfu_get` leaves
  `sfu_p` alone before it; the key handler returns while `!st.init`; the MIDI task's handlers run only after the mailbox is
  published, which is after the zeroing). No ISR code in this mod: only the UI task and the MIDI task touch them. The
  PR's tables cost 9,652 B of the area (35.9 KB spare became 4.2 KB on its tree); here the tables cost none.
- **Tests** [measured, rytm-emu 1.74, DTEMU_STRICT=1] `sfu_emu.py TAG xpages xreset xkeys xlock xmisc xcopy fullnames`:
  - `xpages`: FX16 (a user TYPE 66 with P1..P16: its 24, 51 x 4, 22 ver 3) gives SEND FX 1 three pages, FX 2 one; SRC
    pressed on SEND FX 1: page 2, title `SEND FX 1 2/3`, A..H named X5..X12 (upper left Extra P5..), the host's values; a turn
    of C goes out as 22 ver 3 and the kit's FX words stay; SRC again: page 3 (A..D X13..X16, E..H id 0); once more: stock's
    DELAY (TIM turns) and SEND FX 1 is page 1 with its records back; a trig held on page 2 locks nothing; a host 22 ver 3
    lands on E..H; SMPL on SEND FX 2 the same (REVERB -> SEND FX 2 -> 2 -> 3 -> REVERB); CHORUS: one page, SRC stock's.
  - `xreset`: AMP, FLTR, TRK + BD, SMPL, a kit change (to CHORUS, to another user effect), a host 21 replace (and the 24 / 51
    again), a project load and the host gone each put SEND FX 1 back on page 1 with its records restored; coming back shows
    page 1; a 24 (and its 51s) sent again keeps page 2.
  - `xfix` (fix round 1): the host gone on page 2 then SRC (stock's DELAY), no pages and a plain title while it is down, the
    pages back after; another kit number and other FX words with the same TYPE reset the page (control: nothing changed,
    page 2 stays); a reset by the tick pushes the title again; 0026's page open over SEND FX 1 (TRK + YES, keepalives): SRC
    pages nothing, with SRC in the host's catch mask the host gets the key, and with the page closed SRC pages again.
  - `xkeys`: UP held then SRC, FUNC held then SRC: stock's, no step; FLTR and SRC 2M instructions apart: no step (M1 smoke: the race itself cannot be made in the emulator); SRC
    held 300M: one step, nothing booked after; a built-in with one page on SEND FX 1 / 2: SRC / SMPL cycle as before.
  - `xlock`: a trig held + PUSH_C on page 2 leaves the lock and the real word alone (control: on page 1 it clears it).
  - `xmisc`: a 51 past P16 and a 51 for a TYPE without a 24 are dropped; `xcopy`: see Q1 below.
  Screens `xpages-2.png`, `xpages-3.png` (E..H drawn empty), `xcopy-*.png`.
- **Q1 (the review's open question), probed in `xcopy`:** with nothing held FUNC + RECORD / STOP copy / paste the PATTERN
  (screens: COPY / PASTE PATTERN); with TRK held on the FX track they copy / paste the FX SETTINGS (the sound of the FX
  track = the kit's FX words); stock has no page copy. While page 2 shows, neither path touched the paged records: the
  copied FX words are the kit's (not the host's values), the paste puts them back, the host's P5..P16 (`pv`) are
  unchanged, nothing faults. (The overlay also makes `top_page` 0, so the page goes back to 1 within a tick.)
- **Hardware:** the contributor reports checking #14 and #15 on a Rytm MKII OS 1.74 + Pi 4 with a 16-control user effect;
  the owner's unit has not run this version (the key cycle is new). To test: a user effect with 16 controls: SRC cycle
  (DELAY, SEND FX 1, pages 2 and 3, DELAY), the knobs change the sound, leaving and coming back shows page 1, SMPL the same
  on SEND FX 2, a built-in unchanged, 0026's UP combos as before.

## 14. fxfull-refuse (0.5.2): a lock the save would drop is refused, with stock's LOCK MEM FULL!

**The loss (F1 of the track-B B2 review, `sfx_emu.py fxfull`, `sfu_emu.py fxfull`).** Stock's full pattern rebuild
(SAVE PROJECT; 0x40009216, the same address on 1.73 and 1.74) writes at most **71** lock rows a pattern, not the pool's 72
(0x400092a2: `moveq #71,%d4; cmpl %d6,%d4; bltw 0x40009330`) [code]. It walks lock index 0..41 outer, track 0..12 inner;
a (track, index) is a row when a step locks it (word >= 0 on a step whose lock count, the step's long at +84, is > 0) and
two rows when the track's fine flag for the index (+5632) is set; a pair that would pass 71 is skipped whole (pair-atomic),
later smaller rows can still fit. FX words 38..41 (0025's types 42..49) come last and every FX lock made here has the fine
flag (2 rows), so on a pattern with 70 other rows an FX lock was made, played, and was gone after the next save and load,
with nothing on the screen [measured on rc1 and 0.5.1.1].

**The rule (round 2, owner 2026-11-25).** Any new lock that would not be saved is refused: a Send FX lock, a stock lock
of any track and page, a lock recorded live, FREEZE TRACK's, and a track, page or trig paste as a whole. UNDO (track /
page) and RELOAD TRACK are not checked (below). "Would not be saved" is
counted as the rebuild counts: the pattern's rows (13 tracks x 64 steps, the per-track fine flags) after the lock pass
71. A lock that adds no row (a lock replacing the step's own, another step of an index the track already locks) is made
as before, even on a full pattern; it is found from the lock's own track (the other 12 are only counted for a new row).
Removing locks, and anything with room, is unchanged.

**Where.** Four detours (registry, owner 0029; elek area):
- `track_lock_set` (0x400c0520 1.73 / 0x400c058c 1.74) at its entry, `sfu_tls_det` -> `sfu_tls`. It is stock's one
  lock-set: its only callee `lock_pool_set` (0x400ac670) has no other caller, and its callers are the Sound / FX parameter
  sets' lock-set (+0x40: every page's knob lock, this mod's pages through the wrapped vtables), live
  record (0x400af6f6, from the sets' +0x30), trig paste's lock loop and FREEZE TRACK [disasm 1.73 / 1.74].
  The lock's row is `1 + fine` with the flag the caller passes; a refusal returns 0 as stock's own refusals do (nothing
  set: the words, the fine flag, the step's count; no incremental save). The call from inside trig paste is not
  counted again (its return address): the paste was counted whole.
- PASTE TRIGS (0x400c396a, entry 0026's `ed_rpaste_det`) past the loop that turns the clipboard's steps into the
  target's, `sfu_tg_det` -> `sfu_tgpaste`: the track's rows as the paste will leave them (each pasted step cleared, then
  its locks set with their flags; an entry with a negative value sets nothing, not even the flag, as `lock_pool_set`).
  PASTE TRACK (0x400c4754, `ed_tpaste_det`) with the clipboard's data in hand, `sfu_tk_det` -> `sfu_tkpaste`: the
  clipboard's 64 steps x 88 B over the track (the paste copies those, the track keeps its fine flags). PASTE PAGE
  (0x400c3342, `ed_gpaste_det`; round 3, review H1) with the clipboard's data tested, `sfu_pg_det` -> `sfu_pgpaste`:
  the clipboard's page (+6596) of 16 steps over the selected page's 16 steps (it clears each and copies the 88 B; the
  flags stay). Refused when the pattern would pass 71 and the paste adds rows: the function leaves by its own failure
  exit (the clipboard's reference released; track / page paste: the undo copy freed, no undo record; trig paste: the
  first record's copy's lock vector at -12(%fp), which only the normal end frees, freed first - review M1), so nothing
  is pasted, the handler shows no PASTE message and LOCK MEM FULL! shows. A paste that fits is pasted as before.
- Pattern copy / paste needs nothing: it replaces the target pattern whole with the source's rows and flags (fix round
  1's probe: 71 -> 71 with 45 / 49 kept), so it is over 71 only if the source pattern is, which takes one of the
  unchecked paths below.

**The fine flag (B).** The FX track's Send FX words 38..41 always take the fine flag (their lo half is P3 / P5):
`sfu_tls` sets it on every set of those words (trig paste passed 0, and stock's set writes the flag it gets), and
`sfu_tkpaste` sets it for the Send FX indexes the clipboard brings (track paste does not copy the flags). Before, a pasted
Send FX lock kept only its hi half's row: the save dropped P3 / P5 even with room.

**The message.** Stock's own: `LOCK MEM FULL!` in a popup window over the page, the one stock shows when its lock mirror
(PatternParamLocks::updateMirror) fails. 0029 calls the handler stock registers for that (0x400acb66 1.73 / 0x400acbd2
1.74, with ok = 0); it builds the popup (popup_ctor, a shared_ptr, view_show_popup on the app's view manager) and keeps
stock's guards. Shown at most once every 500 ms (`sfu_st.full_t`, DTCN0, cleared by `sfu_tick` 500 ms later so the
32-bit count's wrap never hides one): a knob turn calls the lock-set every detent, live record every played trig.
`sfu_st.full_n` counts the refusals. Round 4: the popup is only ever shown from `sfu_tick` (UI task, ~20 Hz). A CC
recorded live reaches `track_lock_set` in the MIDI task [measured: `fxlivecc`], and the popup builds a window and pushes
it on the UI's view stack, so a refusal never calls it: `refuse()` (every refusal: the lock-set and the three pastes)
counts and, while no popup is held, stores `sfu_st.full_p = 1`, one byte store. `sfu_tick` alone clears it and writes
`full_t`: when `full_p` is set and `full_t` is 0 it writes `full_t`, clears `full_p` and shows the popup. No
read-modify-write is shared: the refusing side only stores 1 (and reads `full_t`, one aligned long); a request that
races a show stays set and shows once the 500 ms are over. `full_n++` is a read-modify-write in two tasks (a count for
the tests only; a lost count changes nothing). A paste refusal (UI task) goes the same way: its popup shows at the next
tick, at most ~50 ms later. On a refused stock lock stock shows no popup of its own (`fxstock71`: 1 popup).

**Live record.** Recording a stock knob (FX track, DELAY knob A) while playing locks every trig it passes; on a full
pattern each of those sets is refused (`fxlive71`: 6 sets, 6 refusals, 6 popups 500 ms or more apart, the run goes on
to STOP; no hang). SEND FX 1 / 2's P2..P5 are not recorded live at all: their knobs write through the set's +0x70 (this
mod's wrapper), never the +0x30 path live record hangs on (`fxlive-p4-*`: live record's lock path not entered) - on
hardware too, presumably; a known limit, unchanged.

**Not covered (owner 2026-11-25: documented for 0.5.2, a fix in the next release).** Paths that restore lock words
wholesale, without `track_lock_set` [disasm 1.74; review M2]: UNDO after a track paste / clear (0x400c3808 1.73 / 0x400c3874 1.74: 917 B trig data, then 88 B a
step from the undo copy), UNDO after a page paste / clear (0x400c35fa / 0x400c3666: 16 steps x 88 B), RELOAD TRACK
(0x400af64a / 0x400af6b6: the track's 917 B and its whole 5674 B lock block, flags included, from the stored pattern).
Each puts back locks that fitted when they were taken, but other tracks may have grown since (CLEAR TRACK, 8 new rows
elsewhere, UNDO: over 71, the save drops the Send FX rows). Pattern UNDO (0x400abec0 / 0x400abf2c) and RELOAD PATTERN
(0x400af5e0) put back a whole pattern as it was, so they are over 71 only if it was. Also SysEx dumps and a pattern
loaded with more than 71 rows. A FREEZE TRACK onto a full pattern is refused lock by lock (the locks made before the
pattern is full stay): it calls the lock-set per lock, not counted as a whole.

**Cost.** The four detours run in the callers' context: the knob / record handlers of the UI task, the MIDI task for a
CC recorded live (`track_lock_set` only; no UI call there, above), and the paste / freeze key handlers; nothing in the audio interrupt (0025's ISR hook and its other stubs are unchanged;
0029 has no ISR hook). Each lock-set counts the lock's own track first (64 step tests plus 42 word reads per locked
step) and returns when the lock adds no row; only a new row counts the other 12 tracks. A paste counts the pattern once.
Area (the release bundle): 23,352 B spare (23,384 on ffx4, 23,828 on ffx3, 24,656 on ffx2, 25,132 on rc1).

**Tests** [measured, rytm-emu 1.74, DTEMU_STRICT=1] `sfu_emu.py TAG fxfull fxstock fxpaste fxlive fxpage fxpaste2 fxlivecc` (named only):
- `fxfull40` (control, room): the FX 41 lock is made (4a00, fine), no popup, saved as rows 45 / 49, back after LOAD.
- `fxfull69` (the boundary): 69 stock rows + the new FX lock = exactly 71: made, saved with 45 / 49. Fails with `< 71`.
- `fxfull70`: 70 stock rows: the FX 41 lock is refused, LOCK MEM FULL! on top, the live arrays unchanged, the save keeps
  the 70 rows.
- `fxfull71`: 69 + FX 41 (71, full): a replacing lock and a lock on step 2 of index 41 made, all 71 rows saved.
- `fxfull72`: 72 stock rows: FX 41 refused; a stock BD lock on a new row refused too (round 2; made on ffx2).
- `fxstock71` (review rvw71bd): 69 + FX 41 (71) + a new BD LFO knob A lock: refused, nothing changed, LOCK MEM FULL!, the
  save keeps all 71 rows with 45 / 49 (on ffx2: made, 72 live, the save dropped 45 / 49).
- `fxstock69`: 69 + a new 2-row stock lock (BD LFO knob H, fine) = 71: made; turned again on the full pattern (replacing):
  made; 71 rows saved.
- `fxpaste-track40 / track69 / trig40`: the paste with room is made with the fine flag; the save keeps 45 and 49, LOAD
  PROJECT brings 3020 back with the flag (on ffx2: no flag, row 45 only, 3000 after the load).
- `fxpaste-track70 / track71 / trig70 / trig71`: refused, A01's trig data and locks byte for byte unchanged, LOCK MEM
  FULL!, the save keeps the stock rows (on ffx2: pasted, 71 / 72 live, the lo half or the whole lock lost).
- `fxlive40 / fxlive71`: above.
- `fxpage` (round 3): `fxpaste-page40 / page69` made with the flag, both halves saved and loaded; `page70 / page71`
  refused, A01 unchanged, LOCK MEM FULL! (on ffx3: pasted without the flag, lost at the save).
- `fxpaste2` (round 3): `multi71` a two-trig paste replacing both FX 41 locks on a full pattern is made; `neg` a
  clipboard entry with a negative value (poked) counts as nothing, the paste onto 71 is made (refused on ffx3);
  `leak` operator new minus delete the same over 1 and 4 refused trig pastes (one block kept a refusal on ffx3).
- `fxpage` (round 3b): A01 32 steps long, A02's page 1 pasted onto A01's page 2: made on step 17 with room, refused onto 70
  rows, made when it replaces locks already there on a full pattern.
- `fxlivecc` (round 4): a CC sweep over USB MIDI in live record on 71 rows: refused, 71 rows, LOCK MEM FULL! 500 ms or
  more apart; live record's `track_lock_set` in another task than the knob's (the MIDI task), LOCK MEM FULL! in the
  knob's (the UI task; on ffx4 it ran in the MIDI task).
`sfx_emu.py TAG fxfull` (the stored-row cases) unchanged. `sfu_emu.py TAG fxpaths` (fix round 1's probe) kept.

**Only hardware shows:** the popup's look and timing on the real screen while a knob turns or live record runs, the
screen after a refused paste (no PASTE message, LOCK MEM FULL!), and that nothing else in the lock path (the step's LED,
the knob's value text) looks odd when a lock is refused.
