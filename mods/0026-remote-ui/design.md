# 0026-remote-ui: the Rytm as a terminal for pages the Sidecar draws (M1, design and status, 2026-10-16)

Milestone M1 of rytm-teensy `docs/superpowers/specs/2026-10-16-remote-ui-research.md` (section 6), adapted: the code
lives in elekloader's DDR area (`area = "elek"`, needs 0027) as 0029 does, so space is not an issue. Branch
`remote-ui` = `sendfx-ui` (105dc35) + this mod + 0022's `rui` param. Design intent (user): no animation, Syntakt-style
widgets later, and the Rytm side stays blit + input only; all layout and drawing is Sidecar code.

Tags: **[code]** read in the 1.73 disassembly; **[measured]** rytm-emu, DTEMU_STRICT=1, this tree, 2026-10-16;
**[inferred]** reasoned, not shown. No hardware was used and nothing was flashed.

## 1. What the user sees

- **TRK + YES** (hold TRK, press YES) opens the remote page. The screen shows whatever the Sidecar sends; until its
  first frame the page is blank (at most 1 s: no Sidecar -> back to stock by the timeout). 1022: the keys and
  encoders the Sidecar's catch mask names go to the Sidecar, the rest to the Rytm as on its stock screen (section 10);
  before any mask, every key and encoder but RECORD / PLAY / STOP goes to the Sidecar. Pads keep playing (their sound path runs before the key event, 0022's
  finding); their key events go to the Sidecar.
- **Leaving:** TRK + YES again (the local escape, never forwarded), the Sidecar's `3A <page> 0`, or **1 s without a
  host message** (20 ticks; the host sends `3C` every 250 ms when idle). The stock views redraw and the stock diff
  repaints only the tiles that differ.
- **Why TRK + YES:** TRK is the track-select modifier for the pads, and stock has no TRK + YES function that we know
  of; on stock 1.73's main screen TRK + YES leaves the screen exactly as TRK alone [measured]. In a menu, YES with TRK
  held now opens the page instead of confirming [inferred: nobody holds TRK there]. The combo's YES press and release
  never reach stock or the host; TRK's own press and release (taken before the combo) stay stock's. 0022's TRK + REC
  stays free for the looper; FUNC combos are all stock's. [measured: the escape test and the after-leave screen equal
  a Rytm that never left stock]
- No LEDs and no menu item in M1.

## 2. Protocol (rytm-teensy `sim/protocol.py`, 0x30..0x3F; clear of send FX 0x20..0x23)

Every message `F0 7D 52 54 <cmd> <ver 1> ... F7`.

| dir | cmd | body | meaning |
|---|---|---|---|
| host -> Rytm | 38 | `<seq> <col0 0..15> <page0 0..7> <ncols 1..16> <npages 1..8> <packed>` | framebuffer bytes of a tile rectangle into staging, column-major (byte = page + 8 x column) |
| | 39 | `<seq>` | commit staging -> shadow when seq is the 38s' (a partial frame never shows) |
| | 3A | `<page> <on>` | open (1) / close (0) |
| | 3C | - | keepalive (every valid 3x counts) |
| | 3D | `<seq> <slot 0..63> <x> <y top 0..63> <font 0..16> <flags> <chars 0..32>` | 1021: a text slot into staging, committed with the frame by 39, drawn by the Rytm's own text routine (section 9); flags bits 0-1 align (0 left of x, 1 centred, 2 right ending at x), bit 2 inverted; no chars: the slot empty |
| | 3E | `<seq>` | 1021: every staging text slot empty (a whole frame follows) |
| | 3F | `<enc> <slot / 7F none> <value> <lo> <hi> <flags> <prefix 0..11>` | 1021: the encoder's local echo (section 9); flags bit 0 FUNC x 8, bit 1 shown as value - 64 signed |
| | 37 | `<e0> <e1> <e2> <k0 .. k36>` (3..40 bytes) | 1022: the catch mask (section 10): encoder i (0..15) caught when bit i % 7 of e(i / 7) is set, key code c (0..255) when bit c % 7 of k(c / 7) is; key bytes not sent = 0 |
| Rytm -> host | 30 | `<page> <on> <reason>` | reason 0 user, 1 host, 2 timeout, 3 escape |
| | 31 | `<code >> 7> <code & 0x7f> <down>` | a key (firmware codes: YES 0x44, NO 0x45, FUNC 0x80, TRK 0x86, pads 0x90..) |
| | 32 | `<enc> <delta + 64> <func>` | turns, delta -63..63; 1021: sent at the turn when the port takes it, else summed to the next tick |

`packed`: 7 bytes -> 8, groups of up to 7, each a byte of their MSBs (bit i = byte i's bit 7) then the low 7 bits; the
length must be exact. Framebuffer layout [measured, spec section 1]: glass pixel (x, y from the top) = byte
`(7 - y / 8) + 8 x`, bit `y % 8`; page 7 is the top band. A full frame is one `38 seq 0 0 16 8` (1183 B) + `39`.

## 3. How it is built

**core-ar2 events only, no patch site of its own.** The spec's two render patches and the key/encoder taps are
exactly core-ar2's sites, so 0026 subscribes instead of patching:

| event | core-ar2 site [code, 0027] | 0026 |
|---|---|---|
| `ev_tick` | 0x400a2bee (the dirty test before the render, 20 Hz, UI task) | `rui_tick`: mailbox init, host open/close, 1 s timeout, reports out, sets `ctrl + 0x20` (dirty) when a new frame was committed |
| `ev_draw` | 0x400a2c56 (after the stock `drawAll`, before `panel_diff`) | `rui_draw`: in remote mode the 1 KB shadow over the canvas pixels (`bmp + 16`, canvas ctor 0x4006f9c2 [code]) |
| `ev_key` | 0x400a47cc (`key_dispatch`) | `rui_key`: the combo; in remote mode takes every key (returns 1, stock never sees it) |
| `ev_enc` | 0x400a4816 (the encoder dispatcher 0x400a0364) | `rui_enc`: in remote mode takes every turn, sums it per encoder |

core-ar2's `ev_draw` gets the bitmap after the stock draw; 0026 copies raw bytes, so the canvas's y = 0 at the bottom
(fill_rect's view) does not matter: the bytes are the panel's. The stock draw still runs underneath (its cost is
stock's); the copy overwrites all 1024 B, so what the stock views drew never reaches the diff.

- **Event fields** [measured, `--turn 2:-3` / `--press YES`]: encoder event +12 = encoder index, +16 = signed delta,
  +8 a time stamp, +20 FUNC held (byte); key event +12 code, +16 flags (bit 0 down; a release had 0x10).
- **Host -> Rytm:** 0022's router (in the area, `rui=1`, needs `sfx=1`) passes 0x30..0x3F to the 8 B mailbox at
  0x401b9e5c (cave23's tail after 0029's `SFXU` at 0x401b9e54): magic `RUIP` + `rui_sysex`, written at the first
  `ev_tick`. The handler runs in the MIDI task and is the only writer of staging and the shadow; the shadow is under
  a seqlock (odd while copying), `rui_draw` copies when even and re-checks, else shows it next tick (`torn`, 0 in
  every run).
- **Memory:** shadow + staging 2 KB plus ~350 B of state in the area's `.bss` (zeroed by core-ar2's boot copier).
  No heap, no allocation at all (the spec's 2 KB from the firmware heap became static).
- **Nothing waits on USB** (the open hardware freeze after host brown-outs): the stock sender 0x400029e0 spins while
  its 4 KB ring is full (0x40002a4e: `while level + n > 4091`) and the request getter it calls can wait; the
  MIDI_LOCK mutex 0x40002914 pends forever. 0026 sends only when (a) the port is configured (0x413db254 == 1),
  (b) a **try-lock** of the same mutex succeeds (0x4000119c: owner 0 -> the current task, returns 1, else 0, never
  pends [code]; released with MIDI_UNLOCK's callee 0x400011ee), (c) the ring has room for 64 B more and (d) four free
  USB requests (0022's `usb_free`). Otherwise the report stays: keys in a 16-entry queue (dropped and counted when
  full), turns summed, the 30 kept (the newest replaces an unsent one) and the next tick tries again. The 1 s timeout
  counts ticks of host *input*, so it holds whatever the USB side does.
- **Keys at the edges:** a key whose press went to stock gets its release passed to stock; a key pressed on the page
  has its release eaten after leaving; the combo's YES is eaten both ways. No stuck keys [measured: books empty and the
  after-leave screen as stock's].

## 4. Builds

`rui` = `sfxui` + 0026 + 0022 `rui=1`:

    .venv/bin/python tools/build.py --tag rui --mods 0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive \
        0025-sendfx-report 0026-remote-ui 0027-elekloader 0028-elek-hello 0029-sendfx-ui \
        --param 0014-hidden-machines:variants=0 --param 0014-hidden-machines:funcgen=0 \
        --param 0014-hidden-machines:test=0 --param slots=1 --param 0021-ext:diag=1 --param 0022-looper:keys=0 \
        --param 0022-looper:sfx=1 --param 0022-looper:rui=1 --area-elek 0022-looper --area-elek 0025-sendfx-report
    .venv/bin/python tools/verify.py --tag rui          # PASS
    bash tools/emu/us_base.sh rui && .venv/bin/python tools/emu/rui_emu.py rui all

0022's `rui` defaults to 0: `stub.s` regenerates byte for byte for every existing variant (`.ifne P_RUI` wraps a
fourth compile), so `sfxui` and older builds are unchanged.

## 5. Coexistence with 0029 and 0022

- **No shared site.** 0026 claims only the mailbox (registry). The render path's two sites are core-ar2's; 0029's
  detours (page_info 0x400ff574, page_get_value 0x40038462, the page cycle 0x4003ab94) and vtable/record patches are
  not on it, and 0029 subscribes only to `ev_tick`. 0022 runs with `keys=0` (no key/pad/LED hook; 0027 refuses
  `keys=1`), so `ev_key`/`ev_enc` have one subscriber, 0026.
- **One router.** The router branch for 0x30..0x3F is in 0022 (the single dispatcher), beside 0029's 21/22 and 0021's
  and 0023's ranges; no second patch on 0x40083d6c.
- **Suites on `rui`** (section 6) pass, so 0029's pages and 0022's routing are unaffected.

## 6. Tests [measured] (`tools/emu/rui_emu.py rui all`, every run DTEMU_STRICT=1, `--usb-host --usb-midi-real
--ob-link`, rytm-teensy `sim/remote_ui.py` as the Sidecar, paced by the emulator's frame requests)

Results 2026-10-16: `rui_emu.py rui all` ALL PASS (44 checks); `us_emu.py rui all` ALL PASS (311); `sfu_emu.py rui
all` ALL PASS; strict cache-model cold boot 0 stale; build + verify PASS (624 checks). Latencies [measured, DTCN0]:
commit -> first blit mean 48 ms, max 49.1 ms (the script's 20 Hz steps run in phase just after the tick: worst case;
bounded by one tick); turn -> report mean 21 ms, max 38 ms (summed per tick); the host's frame request clock adds
< 1 ms. Full-frame streaming: 2560 tiles/s = 128 tiles x 20 frames/s (UART not modelled, section 7). The checks:
- **frame:** TRK + YES -> `30 0 1 user`; the combo's keys never reach the host; checkerboard + 1-px border, then an
  8x8 tile stepping a tile at 20 Hz and a bar for the last encoder value: the shadow **and the panel MCU's own OLED**
  equal the host's last frame byte for byte; with only the tile moving **2 panel tiles a frame** (old + new) at 20
  frames/s (`--count 0x40095924`), 0 tiles while the page is still; turns `3:+2 x5`, `0:-1 x3`, `7:+5 x2` arrive as
  +10 / -3 / +10 on encoders 3 / 0 / 7.
- **kill:** the Sidecar stops mid-stream -> the page leaves by the timeout (reason 2); NO and FUNC pressed on the page
  reached the host (down + up); 0026's key books are empty; two AMP presses after leaving give exactly the screen of
  a Rytm that never opened the page; 1.5 s after the stop the stock screen is back.
- **escape / host:** TRK + YES leaves (reason 3), the host saw TRK but never YES; `3A 0 1` / `3A 0 0` open and close
  (reason 1) and the stock screen returns.
- **noread:** the USB host stops reading MIDI IN, then suspends the bus, while turns go on: the UI renders 20 times a
  second throughout and the page still leaves by the timeout once the Sidecar stops.
- **full / cost:** full-frame streaming (the whole screen inverted every step: 128 tiles a frame) and per-entry
  timing (section 7).
- **Cache model:** strict cold boot to 4G under `DTEMU_CACHE=log`: 0 stale fetches.
- 0029's and 0022's suites on `rui`: `sfu_emu.py rui all`, `us_emu.py rui all`.

## 7. Cost against the budgets (rytm-teensy `2026-10-16-rytm-stress-budgets.md`)

Measured with DTCN0 (132 MHz [measured: two runs 1 s apart]) inside each entry, x 200/132 = instructions at the
emulator's 200 MIPS; an interrupt or a higher-priority task taken inside an entry counts too, so these are upper
bounds:
- **UI task:** ~350 instructions a tick idle (page closed), ~500 with the page streaming (budget 10 k). The worst
  single call timed at ~65 k in every run, identical with the page closed, i.e. a preemption inside an entry; the
  code's own worst paths [code]: `rui_draw` ~1.3 k (256-word copy), a tick with every report pending ~32 sends x a
  few hundred (the stock sender for 10 B) = < 15 k (budget 100 k).
- **MIDI task:** a full-frame 38 ~12 instructions a byte (~13 k) + the commit's 1 KB copy (~1 k); a tile 38 a few
  hundred. Timed worst 82 k with preemption (budget 100 k a call) [measured upper bound].
- **Audio ISR: nothing.** **Heap: none.** Nothing scales with patterns or locks: costs depend only on the host's
  rectangles and the keys/turns.
- **Panel link:** the emulator does not model UART8's 156 250 baud, so full-frame streaming measured 2560 tiles/s
  (128 tiles x 20 frames/s) there; on hardware the wire carries ~1560 tiles/s (15.9 KB/s / 10 B), i.e. ~12 full
  frames/s [inferred, spec section 1]. The Sidecar must diff (the design intent's widgets change a few tiles).

## 8. Open / M2

- **LEDs** (spec section 2, 0022's code): own the trig/pad LEDs at the UART writer 0x400019e4 and the selector
  callback 0x40287a10 while the page is on, `3B <led> <palette>` -> `B4`; re-send the cached slot colours and
  selectors on leaving. These are 0022's `keys=1` sites: move that code into 0022's area build as functions both
  can call (one filter, two owners), never a second patch.
- **Pads:** `33 <pad> <velocity | 0>` / `34 <pad> <pressure>`: pad key events already arrive in `ev_key`; muting the
  sound needs the pad handler 0x400c7854 (0022's `looper_pad` site) - one chained detour shared with the looper.
- **SIDECAR menu item -> Sidecar Manager:** append at 0021's track-menu detour 0x400f9e9c (the chain 0012/0021 use)
  or core-ar2's `ev_settings`; YES sends `30 <manager page> 1` and opens the page with a "WAITING FOR SIDECAR" line
  (a tiny built-in text) until the first commit; a stock popup "SIDECAR LOST" on the timeout.
- **0029's ASK** (`send_ask`) and 0022's looper reports still call the blocking MIDI_LOCK from the UI task; with a
  host that holds the mutex's owner stuck in the sender's ring spin they block the UI. Worth moving to 0026's
  try-lock `send` (a candidate for the open hardware freeze after host brown-outs; not shown).
- Hardware: never flashed. The 0x4000119c try-lock has no stock caller [code]; its use is [inferred] safe from its
  code (the same mutex layout MIDI_LOCK uses).

## 9. 1021: the Rytm's own text, the local echo, the round trip

Tags as above; [measured] = rytm-emu, this tree (rui1021), 2026-10-18, DTEMU_STRICT=1 for the suites. No hardware.

**Text in the Rytm's own fonts, drawn by its own routine at runtime.** The Sidecar sends pixels for graphics and,
for text, only (slot, x, y, font, flags, characters) - 3D. At the first blit of a newly committed frame (and when an
echo changes) the UI task composes: the shadow copied into `comp` (1 KB), a bitmap built over `comp` with stock's
`bitmap_ctor` 0x4006f9c2 (128 x 64, the stock canvas's geometry [code: the render 0x400a2c4a]), then for every
non-empty slot stock's `text_draw` 0x400714e0 (bitmap, font, x, y, align, box, the text as its own width string, "%s",
text). `rui_draw` then copies `comp` over the canvas as before. Nothing of the Rytm's glyphs or code is copied into
this repository or the Sidecar's: the Sidecar names a font by its index, the Rytm draws it.
- The fonts [code]: 17 objects of 8 B at 0x417e381c + 8 i (vtable, font data), set up at boot by 0x4018947a;
  `text_font` 0x40071b7c returns the data; its +4 word is (descent, height). 3D's font is i.
- Calling convention [measured, rui_probe.py on 0x3D items]: the first argument is the bitmap (the knob callbacks'
  "x" is their canvas; `re/symbols.toml` corrected), y the canvas's (0 at the bottom): 0026 passes
  64 - height - top so 3D's y is the glass top row; align 1 centres on x, 2 ends at x; box 1 inverts the text's box
  after drawing (clear text on a set bar: the title and bottom bars); the box (text width x height + descent) is
  cleared first.
- Which font matches stock [measured]: font 16 (`text_ctx` 0x417e389c, the knob label draw 0x40037ba0's) drawn at
  (2, 2) inverted on a set 9-row bar gives the stock main screen's title bar "K001:RYTMLINJE" pixel for pixel, and
  "TUN" / "BD LEV:" equal stock's label and bottom bar. Font heights (data +4) for reference: 5 (5, 16), 6 (8, 9,
  14), 6 + 1 (11..13), 8 (0), 9 (1, 2), 10 (7), 11 (15), 12 + 2 (10), 15 + 2 (6), 22 (3, 4).
- Geometry the Sidecar now uses (rytm-teensy core/ui/widgets.h) [measured on the stock main screen]: title bar rows
  0..8 inverted, text at x 2 rows 2..6; cells 32 px, dials rows 12..23 / 34..45 (a midpoint circle of radius 7
  without its lowest 3 rows), labels centred, rows 26..30 / 48..52; bottom bar rows 55..63 inverted, text at x 2.
- Storage: 64 slots x 44 B staged + committed (5.6 KB) and `comp` 1 KB in the area's .bss; area use 0x47be0000..
  0x47be8804 (96 KB spare).
- Cost [measured, DTCN0 132 MHz]: a compose of the PLAITS page (~14 slots) 0.35 ms mean; the SIDECAR status page
  (~30 slots) 0.77 ms max, i.e. ~25 us a slot (vsnprintf and two std::strings inside text_draw). Only on a new
  frame or an echo change, so a still page costs nothing; at the 20 Hz render at most ~1.5 % of the UI task. The
  stock draw underneath is unchanged.

**The local echo (3F).** The Sidecar binds each numeric encoder of the page to the bottom bar's slot with the value,
range and a prefix ("V1 HRM:"). A turn on the Rytm changes the value locally (FUNC x 8 as the Sidecar steps it),
writes prefix + value into that slot and marks the screen dirty: the next render shows it, before the round trip.
The echo holds 400 ms after the last turn (the Sidecar's own frame has the same value by then) and the Sidecar's
later 3F values for that encoder are not taken while it holds (no jump back). Lists (ENG) are not bound (the
Sidecar shows their names).

**The turn goes out at the turn.** `rui_enc` calls `flush()` itself (in order behind a pending 30 and keys, through
the same try-lock path), so a report no longer waits for the next tick; when the port is busy it is summed as before.

**Responsiveness [measured]** (rytm-teensy `sim/rui_e2e.py latency`: the real core as the Sidecar over the
Overbridge link, HRM +1 every 120 ms x 12; the Rytm's own clocks):

| | rui1020 + 1020 host | rui1021 + 1020 host | rui1021 + 1021 host |
|---|---|---|---|
| turn -> report (32 out) | 24.1 ms (max 38.0) | 0.0 | 0.0 |
| host: 32 in -> its frame out | 0.8 ms | 24.1 ms (max 38.1) | 0.6 ms (max 0.7) |
| commit -> first blit | 48.5 ms (max 49.1) | 48.8 ms (max 49.3) | 23.7 ms (max 48.1) |
| turn -> the host's frame on the panel | ~73 ms (sum) | 75.4 ms (max 88.7) | 24.9 ms (max 38.8) |
| turn -> the local echo on the panel | - | - | 24.9 ms (max 38.8) |

In the emulator the Sidecar answers within a millisecond, so the echo and the host's frame land at the same render;
the echo is for hardware, where USB, the Pi's control loop and the panel UART add their time. The 20 Hz render
itself (stock's UI loop) bounds both; 0026 does not change its rate.

## 10. 1022: the catch mask - only the page's keys and knobs

Tags as above; [measured] = rytm-emu, rui1022, 2026-10-18, DTEMU_STRICT=1. No hardware.

Hardware feedback on 1021: with the page open PLAY / STOP did nothing (every key went to the Sidecar). Now the page
takes only what it uses and everything else works as on the stock screen.

**37** (host -> Rytm, the next free id of the range; 33 / 34 / 3B stay reserved for M2's pads and LEDs):
`F0 7D 52 54 37 01 <e0> <e1> <e2> <k0 .. k36> F7`, 7 bits a byte. Encoder i (0..15; A..H = 0..7, LEVEL = 8
[measured: `--turn 8` is the LEVEL knob's event index]) is the host's when bit i % 7 of e(i / 7) is set; key code c
(the firmware's codes, 0..255) when bit c % 7 of k(c / 7) is. The key bytes may stop after the last caught code (the
rest 0). The MIDI task writes it word by word into 8 + 1 words; a key's decision reads one word, so a press during a
write sees the old or the new mask for its code, never a mix [code]. Malformed (fewer than 3 or more than 40 bytes):
`rx_bad`, the mask unchanged.

**Rules on the Rytm, whatever the mask** (`key_owner`, `rui_key`, `rui_enc`):
- **RECORD 0x50, PLAY 0x51, STOP 0x52: always stock's.** Also before any mask.
- **TRK + YES: always 0026's** (enter / leave; the YES never reaches either side).
- **A key's owner is taken at its press** (books `stock_down`, `our_down`, `both_down`, `eat`): its repeats and its
  release go to the same side, across a new mask and across leaving (a key pressed on the page and released after
  leaving: eaten; a key passed to stock: its release to stock). [measured: `rui_emu.py pass` "own", the books empty]
- **A caught FUNC reaches both sides:** stock keeps FUNC held (FUNC + PLAY / STOP / REC stay stock's combos) and the
  host gets 31 down / up. **A caught TRK is the host's alone** (as in 1021): stock opens a screen on a second TRK
  within ~1 s [measured: TRK twice 0.3 / 0.5 / 0.7 / 1.0 s apart changes the stock main screen, 1.3 s apart or held
  0.8 s does not], which leaving by TRK + YES shortly after a TRK on the page would do.
- **The FUNC flag in 32** is now the event's +20 or FUNC down in 0026's own books (every key event passes rui_key,
  whoever owns it), so FUNC x 8 works with FUNC passed to stock [measured: +20 stayed 0 with FUNC held in rytm-emu,
  stock or caught; with the books: func 1].
- **Default (no 37 since boot, or since the page left by the timeout):** every key and encoder caught but RECORD /
  PLAY / STOP, FUNC to both. So the 1021 host (which never sends 37) gets 1021's behaviour plus a working transport.
  The mask is forgotten when the page leaves by the timeout (the host is gone; the next one may be an older one); a
  leave by TRK + YES or 3A 0 keeps it, and the host sends it again after every open anyway.
- An encoder not in the mask goes to stock: it edits the stock parameter under the page (shown after leaving).

**What a passed key does under the page** [measured, `rui_emu.py rui1022 survey`: the page open with an empty mask,
each key pressed once; "frame kept" = the panel still the host's frame and **0 tiles written** while the page is still,
so no stock popup or redraw reaches the glass; "after leaving" = the stock screen after TRK + YES equals the same press
on a Rytm that never opened the page]: for **all 37 keys and encoders A and LEVEL** the frame was kept and after
leaving the stock screen was stock's own (TRK: once the escape's own TRK press is counted, see above). Stock's draw
runs underneath and `rui_draw` overwrites the whole canvas before the diff, so nothing flickers. The press changed the
stock screen (seen after leaving) for PLAY, RECORD, TEMPO, BANK A, PUSH A, TRIG, SMPL, FLTR, AMP, LFO, FX, GLOBAL,
SAMPLER, pad CB (selects its track), encoders A and LEVEL; not (on the main screen, a 100 ms press) for STOP, BD (track
1 already selected), MUTE, FUNC, RTRG, FILL, T1, PUSH LEVEL, SRC (already that page), CHRO, SCNE, PERF, QPER, FIX,
PLAYMODE, SONG, CHAIN, PAGE, YES, NO, LEFT, UP.

**The Sidecar's masks** (rytm-teensy core/ui/remote.cpp `kCatchKeys`, sent before a frame when it changes and after
every open): every page takes the navigation keys (LEFT RIGHT UP DOWN YES NO PAGE), the stock-screen keys (TRIG SRC
SMPL FLTR AMP LFO, FX, GLOBAL, SAMPLER, PLAYMODE, QPER, SONG, CHAIN: they open or change a stock screen, or are menus
whose effect is unknown [inferred for QPER / PLAYMODE / SONG / CHAIN]) and TRK; a voice page also its bound encoders
and their pushes; the status pages no encoder. Passed: transport, pads, T1..T16, BANK A..H, MUTE / CHRO / SCNE / PERF
(pad modes), FIX, RTRG, FILL, FUNC, TEMPO (tap tempo = FUNC + TEMPO stays stock's; TEMPO alone opens stock's tempo
screen under the page, shown after leaving), LEVEL and its push, unbound encoders.

**Tests** [measured]: `rui_emu.py rui1022 pass` (in `all`): a page catching encoder D and the navigation keys - PLAY
and STOP start and stop the sequencer (the Rytm's MIDI FA ... FC, transport send on in the base) while the page stays
open, the pad plays (the Rytm's note-on) and never reaches the host, D's turns reach the host and A's do not, the
panel equals the host's frame and 0 tiles are written after the last caught turn; ownership across a mask change and
leaving; the default (no 37): transport to stock, NO / FUNC to the host, FUNC + turn gives func 1; the mask forgotten
by the timeout. rytm-teensy `sim/rui_e2e.py keys`: the same against the real core (its masks per page).
The survey (`rui_emu.py rui1022 survey`, 117 runs, 4 at a time) and rui_e2e's `status` pass on an idle Mac; run beside
the other suites they failed a few rows (the scripted host is not paced by the emulator, so under load its mask or
frame arrived after the press) [measured: same build, both reruns alone ALL PASS].

Cost: one word test per key / turn; 37 is ~40 bytes once per page change. State +~170 B in .bss.

## 11. 1023: the connect splash

Tags as above; [measured] = rytm-emu, rui1023, 2026-10-18, DTEMU_STRICT=1. No hardware.

The user's ask: when the Sidecar connects to a Rytm that is already on (cable plugged in, the Sidecar started later,
a host restart), the Rytm shows a Sidecar screen for 3 s, then the stock screen as it was.

**Trigger: the Rytm says hello, the host decides.** The USB port's state word 0x413db254 is 1 while a host has the
device configured (the sender's own first test, section 3) [measured: 0 in the base snapshot without a host, 1 about
0.1 s after `--usb-host` enumerates; back to 0 and up again across `--usb-host-gone`]. 0026 counts the ticks it is 1;
at 10 (0.5 s: the host reads MIDI by then) it queues **35** with its uptime, again at 1 s and 2 s later while no valid
host message has come (a host that answers stops it), and anew whenever the port drops and comes back. Uptime = ticks
since 0026's first tick (the UI loop's start, after the boot logo: ~7 s after power on in rytm-emu [measured: no tick
at 1300 M, 33 ticks at 1600 M on a cold boot]). The host (rytm-teensy core/ui/remote.cpp) shows the splash only when
the uptime is >= 3 s and the page is closed: a Sidecar that boots with the Rytm is usually up before the UI loop runs,
so its hello says ~0.5 s and there is no splash; a later link (plug, restart) gets one. A slow Sidecar boot (the Pi)
may still greet after the Rytm's boot screen - that is fine, the screen is then the stock one. [inferred: on hardware
the port may configure before or after the UI loop starts; either way the uptime says which case it is. rytm-emu does
not keep USB CONFIG over a cold boot, so the boot-together case was not run there.]

**36 `<ticks 0..127>`** (host -> Rytm, a free id; 33 / 34 / 3B stay reserved for M2): show the last committed frame for
ticks x 50 ms with the page closed; 0 ends it. The MIDI task writes `0x100 | ticks` into one word; the UI task takes it
at its next tick. Ignored (`splash_ignored`) while the page is open (a user's session is never touched) or when nothing
was ever committed. The host sends its frame (38 / 3D / 39) first, then 36; later frames (the animation) show as they
commit; the screen leaves:
- after its ticks (the host sends 64 = 3.2 s and ends it with 36 0 at 3 s);
- on **36 0**;
- **1 s without a host message** (the page's own timeout rule): a host that disappears mid-splash leaves stock;
- on a key or a turn (below); on TRK + YES the page opens (enter() ends the splash).
Leaving sets the dirty flag: the stock views redraw and the diff repaints what differs, exactly as leaving the page.

**Keys during the splash: everything stays stock's, nothing reaches the host.** Transport (RECORD / PLAY / STOP) and
the pads play under it and keep it; a navigation key (LEFT RIGHT UP DOWN YES NO) only ends it (eaten with its release:
no confirm or cancel under a hidden menu or the startup dialogs); any other key ends it and reaches stock (TRK too, so
TRK + YES still opens the page; FUNC, the trig keys, the page keys...); a turn ends it and reaches stock (the edited
value is on the stock screen at once). Releases follow the books (section 10).

**Old / new:** a 1022 host never answers 35 (its remote_sysex returns on any unknown id) and never sends 36; a 1022
0026 never sends 35, so a 1023 host never sends it 36 (and if one came: the `default` case counts it in `rx_bad`,
nothing else [code]).

**Tests** [measured, `rui_emu.py rui1023 splash`, remote_ui.py `--splash` as the host]: no host answering: three
hellos, no splash; hello once with up > 20 s and caps 1; the panel shows the host's splash frame byte for byte while
PLAY runs the sequencer (FA) and the pad plays (note-on), nothing reaches the host, 0 panel tiles written by stock's
draws under it; after 3 s (why `time`) the stock screen equals the same presses without a splash and the books are
empty; LEFT ends it and is eaten (screen as without the press); AMP ends it and reaches stock (screen as the press
without a splash); a turn likewise (`enc`); 36 0 (`host`); the host stopped mid-splash (`idle`, stock back); TRK + YES
during it opens the page (30 on, user); a 36 while the page is open is ignored; re-plugged (`--usb-host-gone` 4.0..4.8
s; rytm-emu's dtboot has the option in its working tree, uncommitted there; the test is skipped by a dtboot without
it, RUI_DTBOOT picks another): a second hello and a second splash, over
by its time, stock back. rytm-teensy `sim/rui_e2e.py splash` runs the real core: its splash (icon sliding in, the line
running down: 128 tiles, then <= 18 a frame for 3 frames, then <= 3), CONNECTED / the address drawn by the Rytm in its
own fonts, 36 0 at 3 s, NO eaten, TRK + YES to the SIDECAR page, the core gone -> stock.

Cost: a word test per tick for the port and one for 36; the splash draws exactly as the page (the compose on a new
commit). State +~40 B.

## 1025: the tracks' machines (33)

The Sidecar's voice pages need to know which machine each track is set to before the track sounds: 0021 reports a
voice (03 / 04) only while it plays, so a machine chosen in the SRC list, or a track switched from an EXT machine back
to an analog one, said nothing until the next trig. 0026 now reports the machines itself. It lives here rather than
in 0021 because 0021's caves are full and 0026 is already in elekloader's area, with the UI tick, the try-lock sender,
the port-up hello and the page's open; the reports serve its host (rytm-teensy core/ui remote.cpp's page list).
Builds with 0026 only (the rui builds); 0026 builds always have 0021.

| | message | when |
|---|---|---|
| Rytm -> host | `F0 7D 52 54 33 01 <t0> <n> {<machine> <vb>} x n F7` | a change: `t0` = the track, `n` = 1; the snapshot: `t0` = 0, `n` = 12 |

- `machine`: 0..52, the active kit's sound of track `t0 + i`, its machine byte (kit k's sound at
  0x4125590d + 2531 k + 152 t, +104; the active kit 0x800067b8) - what the SRC page shows. It follows the SRC list's
  cursor (the preview, before YES), YES / NO, a kit or sound load and a project load [measured, rytm-emu rui1025]. The
  live byte 0x8000ea00 (what the engine plays) follows it at the track's next trig after a kit load [measured: A02
  left it at BD 0x15 until a trig]; the preview moves both at once.
- `vb`: the voice byte the track's 0021 03 / 04 reports carry, voice | 0021's machine flag (voice by track, fixed in
  1027 from the voice owner table 0x40290dd8 = 00 04 01 05 08 06 0a 02 [measured]: BD 0, SD 2, RS/CP 7, BT 1, LT 3,
  MT/HT 5, CH/OH 4, CY/CB 6 - 1025's table, BD 0 SD 1 RS/CP 2 BT 3 LT 4 MT/HT 5 CH/OH 6 CY/CB 7, was wrong for SD..CY; flags 0x50..0x70 U1..U5, 0x48 6-OP FM, 0x08 JUNO, 0x40 DIGIDRUM,
  0x00 PLAITS, 0x20 DSP SAMPLE, 0x10 DAISYSP), or **0x7F: not a Sidecar machine** (an analog machine, 0020's on a build
  without user slots). A Sidecar machine is one whose engine entry (machine_engine_table 0x4029037c) is 0021's
  ext_render, compared with machine 44's (PLAITS is 0021's in every build). Measured: JUNO on BD -> vb 0x08, and BD's
  next 0x04 carries 0x08.
- **Snapshot** (`t0` 0, `n` 12): with every hello (35, 0.5 s after the port comes up, and its repeats) - after the 35;
  when the page opens (TRK + YES or the host's 3A on) - after the 30; and whenever more than one track changed in one
  tick (a kit or project load).
- **Timing:** polled every UI tick (20 Hz); a change goes out at that tick, later only while the sender is busy (the
  try-lock; the host is told the newest value, the shadow keeps what it was last told). Behind the hello and the 30 in
  order. Moving the SRC list's cursor reports each machine it passes (what the Rytm previews).
- Cost: 12 byte compares a tick, a 10 / 33 B message on a change. State 16 B.
- Old hosts ignore 33 (unknown ids are dropped by remote_sysex / host_sysex).

**Tests** [measured, `tools/emu/mrep_emu.py rui1025 all`, DTEMU_STRICT=1]: `portup` the snapshot after the hello,
all analog (vb 7F) on the base, nothing else; `juno` BD's 33 (41, 08) as its own message within 12 M (1.2 ticks) of the
DOWN that reaches JUNO, no trig sent, then BD's 0x04 after YES carries vb 08; `analog` JUNO chosen, then the list
again up to an analog machine: BD's last 33 (16, 7F); `open` TRK + YES: 30 on, then the snapshot; `kit` pattern A02
(kit 1): snapshots, BD 28 analog; `project` JUNO on BD, power-off, cold boot on that card, the host attaches: the
snapshot has BD (41, 08).

## 1026: TRK + LFO, the trig key LEDs (34), the host's close

Tags as above; [measured] = rytm-emu, rui1026, 2026-10-19, DTEMU_STRICT=1 (`tools/emu/rled_emu.py rui1026 all`). No
hardware.

**TRK + LFO opens the page on the Sidecar's LFO page.** Stock 1.73 binds nothing to it: on the main screen TRK + LFO
leaves exactly the screen LFO alone leaves (the stock LFO page), and TRK alone changes nothing [measured,
`rled_emu.py stockcombo`, the stock image]. 0026 takes it like TRK + YES: the LFO press and release reach neither stock
(no LFO page opens under the page) nor the host. The page byte of the 30, until now always 0 and read by no host (core
remote.cpp `kMode` reads only `on`; sim/protocol.py passes it on as `page`), says which page to show:

    F0 7D 52 54 30 01 <page> <on> <reason> F7     page 0 the host's default (SIDECAR), 1 LFO; a close always 0

TRK + LFO with the page open sends `30 01 01 01 00` again (the host goes to its LFO page; the page stays open). The
message is unchanged in length, so every host still parses it; an old host opens its SIDECAR page (and, on the repeat,
starts that page again). TRK + YES still sends page 0. [measured: `combo`]

**The trig keys' LEDs (34, host -> Rytm):**

    F0 7D 52 54 34 01 00 F7                    the LEDs stock's (stock's own colours back at once)
    F0 7D 52 54 34 01 01 <c1> .. <c16> F7      T1..T16 shown in palette colours c (0..111)

What the panel offers [measured in rytm-emu, from the OS's own panel stream]: each LED has 4 colour slots and a 2-bit
selector; a colour is an index into a 128-entry palette the OS loads at boot as eight ramps of 16, 5 bits a channel:
0..15 red (15 = full), 16..31 green, 32..47 blue (47 = full, 43 dim), 48..63 amber / orange / yellow (52 orange
(11,6,0), 63 yellow (31,26,0)), 64..79 cyan, 80..95 magenta, 96..111 white (111 (30,29,29)); index 0 of each ramp is
(1,1,1), the stock "off". 112..127 are refused: the OS animates 0x74..0x78 (the pads' glow). Stock lights the trig keys
red 0x0f (a trig), white 0x6f (the play position), 0x00 off, so they are RGB [inferred; brightness on the glass not
checked]. Suggested for the REC page: recording enabled 47 (blue, a colour stock never uses on the trig keys), disabled
52 (dim orange) - clearly "another mode" and still readable; the host chooses.

- **Only while the page is open.** A 34 counts only when it came after the page's last open (the host sends it after
  each 30 on, as the mask); a 34 while closed is ignored, also at the next open. Leaving (TRK + YES, the host's 3A 0, the
  1 s timeout, a host gone) always gives the LEDs back. Malformed (mode > 1, not 16 colours, a colour > 111): `rx_bad`.
- **How:** every byte for the panel MCU passes the UART8 writer 0x400019e4 (the tile writer and the selector sender
  call it a byte or a few at a time [code]). 0026 detours its entry (registry; the site 0022's keys=1 used, which 0027
  refuses, so never both) and follows the stream with the MCU's message lengths (rytm-emu panel.rs). It keeps the last
  colour stock sent to each slot of LEDs 0..15, and while the host owns them rewrites the colour bytes of those
  messages to the host's colour as they pass: the stream never changes length, the MCU stays in step whatever stock
  sends, and the selectors (the play position, blinking) can do what they like - every slot holds the host's colour.
  Taking over paints `B4 <id> c c c c` per key; giving back sends `B4 <id>` with stock's last four colours, exactly what
  stock believes the panel shows (stock's own cache 0x42fb6f49 is not used: it holds 0xff for slots stock set some
  other way at boot [measured]).
- **Never waits on USB** (nothing here touches it); the LED mutex stock's LED senders take (0x41920560) only by a
  try-lock, a miss retried at the next tick (`led_busy`). The UART writer's own room wait is stock's (the panel ring).
- Cost: a few instructions per panel byte (~1.3 KB a frame at most); 96 B to the panel per paint or give-back. State
  ~110 B.

Tests [measured, `rled_emu.py rui1026 leds ledexit bad`]: trigs on T1 / T5 in GRID RECORD, the page open, 34 1 with
T1..T8 47 and T9..T16 52: all 4 slots of LEDs 0..15 hold the host's colours while PLAY starts the sequencer underneath
(stock's play-position colour bytes rewritten), every other LED as in the same run without the 34; STOP, TRK + YES:
every LED's slots and every selector equal the run without the 34 (the trigs red again, the play position's white
where stock left it). 34 0 gives them back with the page open; the timeout does; a 34 before the open does nothing;
three malformed 34s are counted and change nothing.

**The trig keys on the page** [measured, `trigs`]: codes 0x00..0x0F (T1..T16) are ordinary key codes for the catch mask
(k0 bits 0..6 = T1..T7, k1 = T8..T14, k2 bits 0..1 = T15, T16). Caught, T3 in GRID RECORD reaches the host (31 0 2 down
/ up) and places no trig (LED 3 as with no press; the same press without the page places one); stock's trig keys have
no path before the key event (unlike the pads). The default mask (no 37) catches them too.

**The host's close (the Sidecar's NO on its first status page)**: the existing `F0 7D 52 54 3A 01 <page> 00 F7` (3A
`<page> <on 0>`; page ignored) is that message - it leaves exactly as TRK + YES does (the stock screen redrawn, the LEDs
given back, the 30 with reason 1 host instead of 3 escape). The key rules hold: the NO the host reacts to was pressed
on the page, so its release is eaten after leaving and never reaches stock (no NO under the stock screen). [measured,
`hostclose`: page open, 34, NO pressed, 3A 0 0 while NO is held: 30 0 0 1, the host saw only NO down, and the stock
screen, every LED slot and selector equal a Rytm that never opened the page]

**The active kit (3B, Rytm -> host), for the host's per-kit settings (its LFOs):**

    F0 7D 52 54 3B 01 <kit 0..127> F7

The active kit (0x800067b8 & 127, the word the machine reports read): after the 33 snapshot of each hello (35) and of
each open (30), and whenever it changes (polled with the machines every tick, behind them; the try-lock sender: a busy
tick tries again). 0x3B was one of M2's reserved ids (0x34 is the LEDs now). Old hosts drop unknown ids. [measured,
`rled_emu.py kit`: 35, 33, 3B 0 on the base; pattern A02: 33, 3B 1; TRK + YES: 30, 33, 3B 1]

The research on modulating the Rytm's own parameters from the host without CCs (1026 item 3) is in
`re/subsystems/lfo.md`, "Host modulation".

**Build rui1026** (rui1025's mods; 0021 now with diag = 0, so DSP SAMPLE's SMPL knob C is MOD - 0021 design.md "1026"):

    .venv/bin/python tools/build.py --tag rui1026 --mods 0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive \
        0025-sendfx-report 0027-elekloader 0028-elek-hello 0029-sendfx-ui 0026-remote-ui 0030-fx-in \
        --param 0014-hidden-machines:variants=0 --param 0014-hidden-machines:funcgen=0 \
        --param 0014-hidden-machines:test=0 --param slots=1 --param 0022-looper:keys=0 --param 0022-looper:sfx=1 \
        --area-elek 0022-looper --area-elek 0025-sendfx-report --param 0022-looper:rui=1 --param 0022-looper:fxin=1
    .venv/bin/python tools/verify.py --tag rui1026      # PASS

## 1027: the SRC view - the host's page over the stock SRC page

While the Rytm's own SRC page is the screen and the selected track's machine is a Sidecar machine (its `vb` in 33 is
not 0x7F: U1..U5, 6-OP FM, JUNO, DIGIDRUM, PLAITS, DSP SAMPLE, DAISYSP), 0026 shows the host's last committed frame
(38 / 3D / 39, the same frames as the page) over the stock page. Unlike TRK + YES nothing is caught: every key and knob
is the Rytm's, so the stock SRC page's knobs keep editing the sound (p-locks, kits, saving, the LFO as stock).

| | message | when |
|---|---|---|
| Rytm -> host | `F0 7D 52 54 29 01 <track 0..11> <on 0/1> F7` | 1: the view of `track` started - on entering SRC, on a track change, on a machine change of the track (the SRC list's preview included), and again after every hello (35) while it is on; 0: the view ended (another page or menu, an analog machine) |
| Rytm -> host | `F0 7D 52 54 2A 01 <track> <first 0..15> <n> {<hi> <lo>} x n F7` | P(first+1) .. P(first+n): all 16 (`first` 0, `n` 16) after each 29 1; then at each UI tick (20 Hz) the span from the lowest to the highest value that changed (`n` 1: one knob) |

- **2A's values**: P1..P8 = the SRC knobs A..H = the sound's kit words 0..7, P9..P16 = the SMPL page = kit words
  8..15 (0021's order in 03 / 04: its knob word 9 + i at sound + 18 + 2 i; 17..24 are their container indices), of the active kit (0x41255933 + 2531 kit + 152 t + 2 w, two bytes value . fraction).
  `hi` = the value byte & 0x7F (0..127), `lo` = the fraction byte >> 1 - exactly 0021's 14-bit encoding. They are the
  stored (kit) values the stock page edits: not a p-lock shown while a trig is held, not the LFO. A stock knob turn
  writes the kit word through the bank's drain in the UI loop, so the 2A follows within a tick or two [measured, the
  `knob` test: knob B +48 -> word 1 0x4000 -> 0x4900, two 2A 0 1 1].
- **When the frame shows**: the view is on, a frame was committed (39) since the view's latest 29 1 (or since the TRK +
  YES page closed, or the host's `3A <page> 00` while that page is not open - "give the screen back"), host messages
  keep coming (1 s timeout, as the page; the host's 3C), the TRK + YES page and the splash are not up, and nothing covers
  the SRC page. Otherwise the stock screen, redrawn at once (the views' redraw flag).
- **Covered** (no message; the frame returns when the cover goes): the machine list (SRC twice), a popup (e.g. TEMPO),
  TRK held, PERF, and a BANK key held (the pattern selection drawn in the bottom bar).
- **No host -> Rytm 29**: 0022's router passes only 0x30..0x3F to 0026 (all taken); a host says "no page" by not
  committing, or `3A x 00`.
- **TRK + YES** takes precedence: while open the view stays logically on (no 29 0); after it closes the stock SRC page
  shows until the host commits again.

How the SRC page is recognised [measured, rytm-emu rui1026; the vtables by their typeinfo names in the stock image]:
drawAll 0x40079086 draws the view controller's (ev_tick's ctrl) views from `*(ctrl + 28)` along node +0 until
`ctrl + 20`, the view at node +8, the last drawn on top. On the SRC page: MainScreenView, TransportView,
PatternGridView, KeyboardView, **SynthPageView (vtable 0x401e34fc)**, PatternSelectionView (0x401cca04), HelpBubbleView,
QuickPerformanceView, **SamplerLedView (0x40234cfc)**. SMPL and FLTR swap the page view (SamplePageView 0x401e3170,
SoundPageView 0x401e32c4); the machine list (MachineListView 0x401e5bf4), TRK held, TEMPO and PERF add a view after
SamplerLedView; GLOBAL and the SOUND menu replace the list. PatternSelectionView's byte +0x84 is 1 while BANK is held.
So: SRC = SynthPageView in the list; covered = the last view is not SamplerLedView, or that byte is set. Value turns on
SRC add no view (the value replaces the label in place). Not handled: HelpBubbleView / QuickPerformanceView's own
states (no flag found; neither drew over SRC in the walks tried). The selected track: 0x41318982 (0021's).

Cost: per tick a walk of ~9 list nodes, 16 kit-word reads and compares; messages through the same try-lock sender,
behind the hello, the 30, the keys / turns and the 33s / 3B.

Tests [measured, `tools/emu/sv_emu.py rui1027 all`, DTEMU_STRICT=1, a host in the script answering each 29 1 with a
whole checkerboard frame]: **juno** (BD to JUNO on its SRC list: 29 0 1, 2A 0 0 16 = the kit words, the panel = the
host's frame byte for byte; the list's preview sent a 29 0 1 for each Sidecar machine it passed), **knob** (knob B: kit
word 1 moves, 2A 0 1 1 with its value, the frame stays), **list** (SRC SRC: the stock list exactly as without a host,
the view on but covered, no 29 0; NO: the frame back), **leave** (FLTR: 29 0 0, the stock FLTR page exactly as without
a host; SRC: 29 0 1 and the frame), **gone** (the host stops: the stock SRC page 1 s later; an old host that never
commits: stock throughout), **trk** (TRK + YES opens the blank page over the view, TRK + YES again: the stock SRC page
as without a host). A track change between two Sidecar tracks is not tested in the emulator (the code path is the
machine-change one: 29 t 1 for the new track).

The 2A buffer: the first build had it one byte short (41 for 9 + 32 + 1) and crashed the UI task at the first 16-value
2A in the emulator (PC 0xf7be0014, a smashed return) - fixed before any flash; a reminder that the strict emulator run is
the gate.

### 1027b: 2A from the page's own values (the hardware report "super slow")

Hardware (the first rui1027, 754e5aa3): the page lagged knob turns. 2A read the kit words, and the kit word lags a turn
by the bank's drain: in rytm-emu word 1 stayed 0x40 through 1.3 s of turning (a count every 20 ms) and 2As went out
0.45..1.35 s apart [measured]; the sender was never busy (tx_busy 0). Now **P1..P8 are read through the SRC page's own
methods** - the knob's record id by the view's vtable +0x9c (0x400d3544), its value by vtable +0x54 (page_get_value
0x40038462, lock -1), 8.8 as the kit word - what the stock page draws, the moment the turn is applied; an unused knob
(id 0) and P9..P16 (the SMPL page, not the view) stay the kit words. Same message format. Every compare is the full
14-bit value (a fraction-only change is a change). Measured (`1:+8` x 50, 20 ms apart): the first 2A ~58 ms after the
first count, then one each 50 ms tick while it moves, ending at the kit's settled value (127.0).
Latency floor: the 2A waits for the next UI tick (0..50 ms) and the host's commit is blitted at the tick after (50 ms),
so a turn reaches the glass in about 50..100 ms (the TRK + YES page sends its turns at the event: 0..50 ms + the host).
Not covered: a p-locked edit with a trig held (the page shows the lock; 2A reports the sound's own value).

### 1027c: P9..P16 from the right words

The 1027b build read P9..P16 from kit words 17..24 counted from P1 (0x41255933 + 2 w), past the knob words: on DSP SAMPLE
it reported [0, 64, 0, 64, 127, 0, 0, 0] (host report, rytm-teensy srcsmp), so the host picked the wrong view. The 16
knob words are contiguous (0021 us_defaults: word 9 + i at sound + 18 + 2 i, i = 0..15; "17..24" are SET_PARAM's
container indices 9 + i), so P9..P16 are kit words 8..15. The `juno` test now compares all 16 with words 0..15.
Also 1027c: 0029 steps 0021's list knobs (ENG, INP, OUT, MOD, PAT, a U slot's enums: mods/0021-ext/design.md
"Stepped list knobs"), and its page_get_value wrapper answers the step index for them (DSP SAMPLE ENG read 1 where the
word is 80). For a knob whose ext_steps (0021's ext_stepbox at 0x4001a23c, 'XSTP') says it is stepped, 2A carries the
kit word when it lies in the step the page shows (exact), else the step's stored value (zones: ceil(128 k / N); a list
or all 128: the index), with fraction 0 - what the word settles to [measured, `sv_emu.py dsp`: ENG one step -> 2A 86,
the kit word then 0x56]. Tests: `dsp` (DSP SAMPLE: all 16 = words 0..15, P9..P16 = 64 64 0 0 0 120 0 100; ENG turned).

### 1027d: an unknown stacked view no longer covers for good; 2B diagnostic

Hardware (rui1027c + the Pi host): after a USB replug at the Pi the SRC view stayed stock for good. TRK + YES still
worked, and leaving and re-entering SRC (even via TRIG) did not help, but a Rytm reboot did. The Pi log showed 29 0 1,
2A, whole frames with their 39, no 3A, and keepalives. Only "covered" fits: some stock view stacked after
SamplerLedView at the re-enumeration and stayed there [inferred; candidates by class name: ObSyncInProgressMenuView,
BlockerWindow, TimeoutView, OverlayWindow - 2B will name it].
Now a view after SamplerLedView covers the page only if its class is a known cover: MachineListView, TrackSelectionView,
PerformanceView and TempoMenuView [measured], and PopupWindow 0x401d6e18, TextWindow 0x401d6f84, SampleListView
0x401e70d4 and QuickPerformanceSelectionView 0x40230d44 [code: vtable after the typeinfo of that name]. A view of any
other class covers only for its first 3 s on top (60 ticks, counted from when the top view changed), so a transient
popup of an unlisted class still shows. A list without SamplerLedView still counts as covered.
Risk: a long-lived stock overlay of an unlisted class (not met in the walks tried) would be drawn over by the host's
frame after 3 s. The page underneath still works and leaving SRC shows it.

**2B (Rytm -> host, diagnostic)**: `F0 7D 52 54 2B 01 <state> <views> <vt0..vt4> <age> F7`
- state: bit 0 view on, 1 covered, 2 committed since the view's start or give-back, 3 host idle >= 1 s, 4 TRK + YES page
  open, 5 splash, 6 the frame shown.
- views: the list's length (9 on a plain SRC page).
- vt: the top view's vtable, vt0 << 28 | vt1 << 21 | vt2 << 14 | vt3 << 7 | vt4.
- age: ticks since the top view changed (capped at 127).
- Sent on every change of state or top view, and once a second while the SRC page is in the list. It goes behind the 29
  and ahead of the 2A, through the same try-lock.
- Tests [measured, `sv_emu.py`]: juno - the last 2B is 0x45, 9 views, SamplerLedView; list - a 2B names
  MachineListView with the covered bit set. rytm-emu's replug (--usb-host-gone) stacks no view, so the hardware case
  itself is not reproduced; the timed rule is checked only by the existing cover tests still passing.
