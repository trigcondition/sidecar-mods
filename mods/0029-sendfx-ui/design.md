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
  branch the storage spec's next step 2 asked to exercise [measured: below].
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
| DIGIDRUM ENG (390) | zones | 11 | as above |
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
