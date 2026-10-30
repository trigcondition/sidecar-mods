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

## 1030: chord write-back (poly chord, proof of concept, emulator only)

Purpose: a chord played on the chromatic pads while live recording is stored in the Rytm pattern as p-locks the Sidecar
host can read back (rytm-teensy `docs/POLYPHONY.md` option (c), the "cheaper variant"). Stock records one note per step:
the last pad's [measured]. The host sees every pad on USB MIDI, works out the chord, and sends one write-back for the
step. The Rytm stores it with stock's own writers. The format does not change, and a stock OS loads the pattern (it
plays the root note and ignores the meaning of P13..P16).

**Messages** (host <-> Rytm; a command byte of its own, 0x28):

    host -> Rytm  F0 7D 52 54 28 01 <track 0..11> <root> <CHD> <INV> <SPR> <VOI> F7   (13 B)
    Rytm -> host  F0 7D 52 54 28 02 <track> <step | 7F> <status> F7                   (10 B)

Why 0x28: 0x30..0x3F are all taken by 0026 (host -> Rytm 34 36..3A 3C..3F, Rytm -> host 30..33 35 3B). The first
version overloaded the keepalive 3C by length, and the coordinator decided against that. 0x28 is used by no handler in
0021 / 0025 / 0026 / 0029 / 0030, nor by the host (rytm-teensy poly-fm `core/host_link.cpp`, `sim/protocol.py`)
[checked 2026-10-19]. 0022's router (rui=1) now passes 0x28 to 0026's mailbox along with 0x30..0x3F; the router's other
builds are unchanged.

- root: the 0x04's note unit (60 = the track default). CHD/INV/SPR/VOI: the coarse values of sound words 21..24
  (P13..P16), stored as value << 8. Their meaning is the host's (rytm-teensy poly-fm `core/poly.h`).
- status: 0 ok; 1 no step live-recorded on that track in the last 1 s (20 UI ticks); 2 the pattern's lock slots are
  full, nothing written; 3 not live recording, not a Sidecar machine on the track (0021's voice byte 7F) or track > 11.
  The step is 7F with status 1 and 3.
- A 28 of any other length is refused (rx_bad). A valid 28 counts as a host message for the 1 s timeout, as every
  valid one does. Keepalives (3C, 7 B or 13 B) get no reply [measured].

**Where stock records** [measured, rytm-emu rui1027 and rui1030poly, BD on 6-OP FM, CHRO, RECORD + PLAY]:
- A pad: the UI task's record-event handler (0x400a13ae, gated by `live_rec_active` 0x40036370(0x40181528())) calls
  `live_rec_trig` 0x400b45e0(this, track, note, vel, step, micro, len, -1). This is its only caller. It places the trig
  (`trig_place`), the note (`track_note_set` 0x400c070a), the velocity, the micro timing (micro + 64; zeroed when record
  quantise is on, test 0x400b5b7a) and the length. The step arrives already computed: a BD pad 0.8 s after PLAY at 127
  BPM gave step 7 and micro -9.
- A knob: `live_lock_rec` 0x400af6f6 takes the track's current step, places a trigless lock trig when the step has no
  trig, and calls `track_lock_set` 0x400c0520 at 0x400af7ca. SMPL knobs E..H on 6-OP FM gave sound words 21..24 with
  fine flags 1, 1, 0, 0.
- The stored copy: each lock change posts to the prio-2 task, which runs `lock_mirror_incr` 0x4000940c over the
  working pattern's stored slots (bank pattern i at 0x405c8f38 + 13101 (i + 1), +0x2091). That routine silently refuses
  a new (type, track) when used + cost > 71 [code]. The lock then exists only in the live array.

**How 0026 does it:**
- A detour at `live_rec_trig`'s entry (registry; 6 bytes, `linkw` + `moveq`, re-emitted) notes (track, step, UI tick).
- The MIDI task copies the request under a seqlock. The UI tick does the rest:
  1. the checks above (status 3, then 1);
  2. block = `pattern_track(pattern_active(project_singleton()), track)`, the lock pool at block +44, its live array
     (vtable +40) and its stored slots (+0x20);
  3. the slot count stock's mirror update makes: occupied slots, plus 1 (2 with the track's fine flag for that word) for
     each of words 21..24 without a slot yet, refused past 71 (status 2, nothing written);
  4. `track_note_set(block, step, root)`, then `track_lock_set(block, step, 21..24, value << 8, flag)`, where flag is the
     track's existing fine flag for the word, so a fine lock made by hand keeps its slot pair;
  5. the reply goes through the try-lock sender, and a busy sender retries on the next tick.
- The recorded trig itself stays stock's (velocity, micro timing, length). Only its NOTE changes, and the 4 locks are
  added. Nothing waits.

**Tests** [measured, `tools/emu/pc_emu.py rui1030poly all`, DTEMU_STRICT=1]:
- rec: the chord BD+RS+CH (60, 62, 68) recorded on step 7, then 28 1 0 62 2 1 1 3 sent 150 ms later. Reply 28 2 0 7 0.
  Live NOTE 0x3e and locks 0x200 0x100 0x100 0x300. A01 stored NOTE 0xbe and slots of types 12..15 for track 0 with
  2 1 1 3 on step 7. No other step written. On the next loop the step's 0x04 is (0x48, 62, P13..P16 = 2 1 1 3).
- status:
  - not recording: 3, nothing written;
  - SD (analog): 3;
  - sent 1.6 s after the pad: 1, the note stays 68;
  - 71 slots used: 2, nothing written;
  - 67 used: all four stored by stock's update, 71 used after it.
- keep: a 7-byte keepalive, a 13-byte 3C with the chord's bytes and a short 28 during recording: no reply, nothing
  locked.
- copy: FUNC + RECORD, A02, FUNC + STOP: A02's stored NOTE and 4 slots match A01's.
- save: power off (the firmware's handler writes the state to the card), cold boot on that card: live and stored NOTE
  and locks back, and PLAY gives the step's 0x04 with the chord.

**Limits / open:**
- Emulator only, not on hardware.
- A chord is written to the step the last pad recorded. A chord spread across a step boundary lands where that pad
  landed.
- The 1 s window starts at the last recorded pad.
- Undo is not handled (stock's undo record covers the trig, not 0026's note and locks).
- MIDI note-in live recording reaches the same `live_rec_trig` [inferred], so a host keyboard chord could use the same
  write-back.
- The meaning of P13..P16 on a Sidecar machine (records, value texts CHD/INV/SPR/VOI) is not part of this build. The
  stock page still labels them as the machine's page-2 knobs (6-OP FM: STA END LOP LEV).

## 1031: 6-OP FM's chord knobs and the MULTISAMPLE machine (emulator only)

**What the user sees.** On a 6-OP FM track the SMPL page's E..H read CHD INV SPR VOI, stepped list knobs with the
host's value texts (rytm-teensy core/poly.cpp `value_text`, sim/protocol.py `chord_value_text`): CHD OFF MAJ MIN SUS2
SUS4 7 MAJ7 MIN7 DIM AUG 6 MIN6 9 ADD9 MIN9 5, INV0..INV3, SPR0..SPR2, VOI AUTO 1..6; the stored value is the index, a
value beyond the list reads as its first entry (as the host's `idx()`: an old sound's STA 0 / END 120 / LOP 0 / LEV 100
read OFF INV0 SPR0 AUTO). A..D stay stock's (TUN FIN BR SMP). MULTISAMPLE is the machine list's last entry on every
track (machine 52, voice flag 0x30 = rytm-teensy core/machines.h `kMultiMachine`: the host plays it without
`msamp=voice:V`): SRC INST VEL LEV RTRG / ATK DEC SUS REL (defaults 0 127 100 0 64 64 64 64; INST one value a detent,
RTRG OFF/ON), SMPL TUNE FINE STRT LOOP / CHD INV SPR VOI (LOOP AUTO / OFF / ON in the host's zones 0..42 / 43..85 /
86..127). INST shows the number (no instrument names from the host yet).

**How.** 0021 (cave code, full) gains only the hooks: machine 52's engine entry = ext_render and its records (registry),
voice flag 0x30 in `us_flag_tab`, and `us_cubox` (.ush, a fixed 12 B {'CHRD', setup, steps} at 0x4001a3dc). For
machines 40 and 52 `us_page_record` forgets the user slots' page-2 set-up (`us.p2_slot = 0`), calls `setup(m)` and
answers the shared page-2 records (`us_p2rec`; 6-OP FM only E..H); `us_param_record` answers the same records; for a
record no slot owns `ext_steps_us` asks `steps(r)`. Without 0026 the pointers stay 0 and both machines keep stock's
SMPL page. 0026 (`cu_tick`, first ev_tick): names and looks of MULTISAMPLE's SRC records 398 443 399 400 401 402 406
407 (BT IMPROVED's five, DSP SAMPLE's word-19 copy unused since 2026-10-09, FUNC. GEN.'s last two), the box's pointers;
`cu_setup(m)` writes the eight shared records (names, looks, value text `cu_text`, ranges) unless they still hold ours
(labels compared); `cu_steps` gives 0029 the stepped modes (chords mode 2 with bit 10 = beyond the end reads entry 0,
new in 0029's `xf[]`; LOOP 3 zones; RTRG 2 zones; INST all 128). Machine 52's mask (every track) and names are 0026's
registry patches, so it is unlisted without 0026. With 0014 variants=1, BT IMPROVED (34) lists without knobs (records 398..402 are machine 52's).
.us1 room: `us_copy`, `us_zero`, `us_text_in` and `ext_vflag` moved to the free tails .extx .extz .exty and .extw.

**Tests** [measured, rytm-emu, DTEMU_STRICT=1]: `tools/emu/cu_emu.py TAG all` - FM's SMPL labels and group, knob E six
steps -> word 21 = 6, CHD range 0..15 under 0029; the texts at the stock words and at MIN/1/1/3 (PNGs); MULTISAMPLE
from the list (machine byte 52), its SRC and SMPL labels, defaults written by the choice, a BD pad's 0x04 with voice
byte 0x30 and P1..P8 = the defaults; RTRG -> 64, LOOP two steps -> 86, VOI from 100 -> 1..6; back to FM (labels follow),
to U1 (stock SAMPLE page).

## 1032: seq - the sequencer link (Sidecar sequencer MVP, Rytm side; emulator only)

Design and measurements: rytm-teensy `docs/SEQUENCER.md` (branch seq-research). The host half (core/seq, the remote
SEQ page) is rytm-teensy's; the byte layouts below were agreed with it and are mirrored in rytm-teensy
`sim/protocol.py`. 0022's router passes 2E and 2F to 0026 (rui=1), as 28. Everything here is off until the host sends
a 2E: a host that never does sees a stock rui1031 (no new message, no key or LED taken; `sq_emu.py stock`).

### Protocol (F0 7D 52 54 <cmd> <ver 1> <body> F7)

blk4 = the audio block counter 0x419ca2ac (1500 a second; 32 frames at 48 kHz) as 4 x 7 bits, MSB first (28 bits).

    host -> Rytm  2E 1 <mask lo7: tracks 0..6> <mask hi5: tracks 7..11> <flags> [<clock lo7> <clock hi5>]
                     the seq tracks (ticked in 2C, seq mode, live record refused); the optional clock mask: tracks
                     only ticked (2C), nothing else changes on them. flags bit 1: resync now; bit 0 reserved (0).
                     Any 2E turns the reports on (also mask 0); the first one after a hello gets a whole resync.
                     Forgotten at each hello (35) and when the USB port goes down: the host sends 2E after every 35.
                  2F 1 <page 1> <page 2> <page 3> <page 4>   the PAGE LEDs (panel LEDs 43 42 41 40), palette 0..111
                     as 34, 7F stock's. Honoured while the host owns the LEDs (below).
    Rytm -> host  2C 1 <blk4> <n> {<track 0..11> <step 0..127> <len 1..127> <speed 0..6>} x n
                     the steps that start in that audio block: the track's own step (a 2x track sends two per 1x
                     step), the length it wraps at (the track's in per-track scale mode, else the pattern's; capped at
                     127), the speed index (0 2x, 1 3/2x, 2 1x, 3 3/4x, 4 1/2x, 5 1/4x, 6 1/8x). Only while playing.
                  2D 1 01 <state 0 stop / 1 play / 2 pause> <blk4>   TRANSPORT (continue = pause -> play)
                       02 <now 0..127> <next 0..127 | 7F>          PATTERN: the active one, the one after it (queued /
                                                                    chained; 7F the same); on a change and in a resync
                       03 <from> <to> <blk4>                       SWITCH: the block where the new pattern's step 0
                                                                    starts (sent before that block's 2C); stopped: when
                                                                    the active pattern changes
                       05 <mask lo7> <mask hi6>                    MUTES, bit t = track t (0..12)
                       06 <live 0/1> <grid 0/1>                    REC: live recording, GRID REC
                       07 <t2> <t1> <t0>                           TEMPO, BPM x 120 as 21 bits
                       08 <on 0/1> <track | 7F>                    SEQMODE (below)
                       09 <blk4> <play> <master step & 7F> <drops> POS: once a second while playing and in a resync;
                                                                    master step for display only (2C is exact), drops:
                                                                    2C ticks lost to a full queue (127 max)
                     A resync: 08, 01 (the state now), 02, 05, 06, 07, 09.

Seq mode: reports on, the selected track (0x41318982) in the mask and GRID REC on. Then, with the remote page closed,
T1..T16 (0x00..0x0F) and PAGE (0x84) are the host's (31, press and release; the release goes where the press went,
also after seq mode ends), FUNC (0x80) both sides' (stock keeps its combos, the host gets 31), and encoders A..H
(0..7) the host's while one of those trig keys is held (32, summed, FUNC flag). With the page open (the host opens it on
08 1) its catch mask (37) decides, as before. The host owns the trig LEDs (34) and the PAGE LEDs (2F) while the page is
open or seq mode is on: from the moment it takes them only a 34 / 2F sent after that counts (as 1026), and seq mode keeps
them across the page's open and close; when neither holds, every LED is stock's again (B4 with stock's last slot
colours). PAGE is caught, so FUNC + PAGE (SCALE) is not reachable on a seq track in GRID REC: leave GRID REC first.
RECORD, PLAY and STOP stay stock's. Choice: GRID REC on, not "always on seq tracks", so the stock UX (select the track,
GRID REC, edit) is the gesture and a seq track with GRID REC off plays and mutes as any track.

Live recording (RECORD + PLAY) writes nothing on a seq track: rec_trig's detour (1030) returns at once for it; the pads
still play and report their notes (0x04 / note-ons) as always, so the host records them on its own grid. Knob locks
while recording (`live_lock_rec`) are not refused (a lock with no trig on an empty seq track does nothing audible).

### How it is built

- **Step ticks.** A detour at `trig_fire`'s entry (0x4009a9bc, 8 B displaced): the sequencer clock 0x4009b048 (a
  software interrupt at level 2, 96 PPQN) calls it once per track per step, trig or not, at the track's tick 0, with the
  current-step byte, which is one step ahead (trig_fire schedules the step it is given for the next boundary [code]); the
  step that starts at that call is the previous-step byte 0x405c8cea + t [measured: the 0x04 trig reports of 6-OP FM on
  BD fall between the 2C of their step and the next; 2D 01's play block = the first 2C's, step 0]. `sq_fire` queues
  (block, track, step, length, speed) for the ticked tracks while playing (at STOP trig_fire is called once more with
  step 0: not reported) in a 32-entry ring (IPL 7 for the few stores; a full ring drops and counts).
- **Transport, switch and the send.** A detour at the clock's only exit (0x4009bf9e, `moveml; lea; rte`): `sq_end`
  compares the transport (0x405c8c90, 0 / 1 / 2 [measured]) and the active pattern (0x405c8d04) with the last call's,
  queues 2D 01 at once; the active pattern is written a step ahead (trig_fire schedules the new pattern's step 0 while
  the old one's last step starts [measured: 30 blocks before step 15, 207 before the new step 0]), so 03 is queued by
  `sq_fire` at the first track's step 0 after the change (stopped: at once). Then it sends what is queued, the 2D first,
  then one 2C per block, by 0021's interrupt rules (no task holds the USB MIDI mutex 0x42f67a28, the sender's SysEx
  state 0x413db244 clear, the ring under 3800, 2 free requests) at IPL 5, so 0021's own sender in the audio interrupt
  (level 5) cannot cut in. What does not go waits for the next clock call (5 ms at 127 BPM). Cost: the exit hook
  measured at most 980 TIMER counts (~10 us at the 100 MHz bus clock) with three ticked tracks, 18 (~0.2 us) with
  nothing queued.
- **The UI tick (20 Hz).** `sq_tick` takes the 2E (seqlock), decides seq mode (GRID REC = the grid object's +360 while
  +353, the object at 0x419f28d8 [measured: 0x4003625c's argument; RECORD writes +360 at 0x400362ec]), polls next pattern
  (0x412f3e91, BE word [measured: 1 / 4 after BANK + T2 / T5]), live record (`live_rec_active`), tempo (0x40287c9c),
  mutes (0x407c23c3, BE word) and sends the 2D through 0026's try-lock, in a fixed order, the rest at the next tick.
  `pg_tick` paints / restores the PAGE LEDs through the UART8 writer's detour (1026), which now also follows LEDs 40..43.

### Tests [measured, rytm-emu, DTEMU_STRICT=1]: `tools/emu/sq_emu.py TAG all`

- `ticks`: BD 16 steps 1x, SD poked to 32 steps 2x, CH on the clock mask: 2D 01 1 in the block of the first ticks (step
  0); BD 0..15, 0, 1.. (len 16, speed 2) every 177 blocks (+-2, 127 BPM), SD 0..31 (len 32, speed 0) every 88-89, CH
  as BD; no other track; nothing after STOP; no drop.
- `switch`: BANK_A + T2 at step 7: 02 0 1, then 03 0 1 at the block of the new pattern's step 0 (16 ticks after PLAY),
  sent before that block's 2C, then 02 1 7F (and 07: A02's own tempo).
- `pause`: 01 0, 1, 2, 1, 0; the steps continue across the pause (one long gap, no restart).
- `mode`: GRID REC on BD: 08 1 0, 06 0 1; T1 held + A 3 x +2 -> 31 T1, 32 0 +6; T5; PAGE; FUNC (both); 34 + 2F paint
  T1..T16 and PAGE 1..3 (page 4 7F stays stock's); BD's live track unchanged (stock writes trigs for the same keys,
  `stock`); GRID REC off: 08 0 7F, T9 stock's, every trig and PAGE LED as in the base.
- `stock`: no 2E: no 2C / 2D / 31 / 32; GRID REC + T1 / T5 write BD's trigs; 1.5 s of play with three seq tracks leaves
  the sequencer's state (0x405c8c90..0x405c8d40) identical to stock's, and the other reports identical (but the hello
  repeats and 2B's idle bit, which any host message moves); a 2E for SD with BD selected: no seq mode.
- `rec`: RECORD held + PLAY, pads BD and SD: 06 1 0 while live; BD's live track unchanged (rec_trig refused once), SD
  recorded as stock.
- `state`: the resync's order, tempo 15240 (127.0), MUTE + SD -> 05 02 00, flags bit 1 -> a second resync, 09 while
  playing.
- `hello`: a host brown-out and re-enumeration (`--usb-host-gone`): ticks before, none after the new hello, reports off.

### Not in 1032

Mod B (POLYPHONY.md 5: the analog AMP / filter held open on seq tracks, at the transport entry 0x4007a538) is not built.
Until it is, a seq track needs **one stock trig with AMP ATK 0 / DEC INF** (e.g. step 1, GRID REC off, or before marking
the track) so the analog chain stays open for the Sidecar's audio; 2C ticks do not need any trig. The phase-2 hooks
(copy / paste / clear, SCALE, reload / save reports: 2D 04 / 08-EDIT in SEQUENCER.md) are not built either; 2D's kind
08 is SEQMODE here, the edit report will take another kind.

All suites (cu frz fxin mrep pc rled rui sfu sfx sp sq sv td us) pass under DTEMU_STRICT=1 with rytm-emu poly-chord's
dtboot after its event fix (2026-10-20): dtboot dropped an event whose clock the CPU had already passed (it stops at
block boundaries, so an event at the same clock as the one before, or at a status-line boundary, could be skipped);
1032's extra code moved those boundaries and pc / rui lost a pad release, a STOP and a host 28 that way.

## 1033: seq2 - the analog pin (Mod B), edit reports, SCALE, pattern dirty (Sidecar sequencer phase 2; emulator only)

rytm-teensy `docs/SEQUENCER.md` ("Built: phase 2") and `docs/POLYPHONY.md` 5 (Mod B). Wire format mirrored in
rytm-teensy `sim/protocol.py`. Off until the host sends a 2E, as 1032: a host that never does sees rui1031.

### Protocol additions (F0 7D 52 54 <cmd> <ver 1> <body> F7)

    host -> Rytm  2E 1 <mask lo7> <mask hi5> <flags> [<clock lo7> <clock hi5> [<pin lo7> <pin hi5>]]
                     7 bytes: the pin mask, more tracks pinned (the host's poly tracks); every seq track is pinned unless
                     flags bit 2. 3 / 5 bytes as 1032 (pin = the seq tracks).
                  46 1 <silent lo7> <silent hi5>   the pinned tracks on which nothing of the host's sounds: VCA closed
                     (stock's decay record) until a 46 without them (one start, then held). 0022's router passes 46.
    Rytm -> host  2D 1 04 <track 0..11 | 7F> <len lo7> <len hi7> <speed> <mode> [<chg lo7> <chg hi7>]   SCALE: the
                     working pattern's track lengths (+0x2c5) and speeds (+0x2c7), the pattern's master length
                     (+85683), speed (+85690), mode (+85689) and change length (+85685, 7F only); polled at 20 Hz, on a
                     change and in each resync (13 reports)
                       0A <op> <pattern> <track | 7F> <ok> <src> <a0> <a1> <a2>   EDIT (below)
                       0B <pattern>                DIRTY: the working pattern's bytes changed (at most every 200 ms)
                       0C <held 0/1>               FILL: the FILL key (0xb2), seen in ev_key; stock keeps it
                     The 02 PATTERN report keeps the playing pattern until its 03: the active-pattern byte moves a step
                     before the switch (1032 reported the new one up to a step early).

### The analog pin (Mod B)

A detour at the voice frame sender's entry 0x4007a538 (`lea; moveq`, 6 B; registry). Every block path calls it with the
control frame 0x800063c0 after the filter and amp consumers wrote it; other callers pass other buffers, which are left
alone. `pin_frame`, per physical voice v whose owner track (0x40290dd8[v], the amp consumer's own table) is pinned:

- amp records +168+8v / +232+8v: the first block stock's trig record at ATK 0 (`4000007f`, `b0000000 | rate`), then stock's
  ATK-0 hold (`0000007f`, `30000000 | rate`) every block: every stock retrig's start command is masked, the envelope
  held at 127. The encodings are the consumer's own [code: 0x40109ae2..0x40109b9c]; the firmware clears the mode byte
  after each send, as on its own records [measured];
- filter record +296+8v: first word 0 (stock's ENV 64: no envelope) [measured POLYPHONY.md 5.1];
- velocity: the track's velocity word 0x800067c4 + 2t is set to 0x7f00 after the frame went out, so the consumer's next
  VCA words +10/+26 are velocity 127's; in a trig's own block the VCA words are rescaled x 0x7f00 / vel first. An
  empty track (velocity word 0, VCA 0 [measured]) gets an open VCA from its second pinned block;
- silent (46): stock's decay record (`00000080`, `b0100000 | DEC 40's rate`) every block; not silent again: one start;
- unpinned (the mask, a hello, a shared voice's owner moving to an unpinned track): the decay until stock starts the
  voice again (a record with the start command).

OVR, FRQ, RES, the filter type, level, pan and sends stay stock's. The hook costs at most 238 TIMER counts (~2.4 us) with
one pinned voice [measured]. rytm-emu's analog model now takes the frame as sent (its `voice_frame_sent` hook at
0x4007a598, rytm-emu seq-p2): it read the live frame, between the consumers' and the pin's writes.

### Edit reports

Each stock edit function is wrapped by a detour at its entry (`linkw` + the next instruction, 8 B, elek_size 8;
registry): ed_X_det calls it through ed_X_orig (the displaced bytes, then a jmp past them) with six argument words copied,
then `ed_report(op, arg1, arg2, d0)` queues 2D 0A and marks the pattern dirty; the caller gets d0 back. The UI tick sends
the queue (8 entries; a full queue drops and counts) through 0026's try-lock after 1032's reports.

| op | function | gesture |
|---|---|---|
| 1 COPY PAT / 2 PASTE PAT / 3 CLEAR PAT / 4 UNDO PAT | 0x400abde0 / 0x400abff6 / 0x400ac11c / 0x400abec0 | FUNC + REC / STOP / PLAY outside GRID REC |
| 5 COPY TRK / 6 PASTE TRK / 7 CLEAR TRK / 8 UNDO TRK | 0x400c2efc / 0x400c4754 / 0x400c494a / 0x400c3808 | GRID REC, FUNC + REC / STOP / PLAY |
| 9 COPY PAGE / 10 PASTE PAGE / 11 CLEAR PAGE / 12 UNDO PAGE | 0x400c4620 / 0x400c3342 / 0x400c444e / 0x400c35fa | GRID REC, PAGE held + FUNC + ... |
| 13 COPY TRIGS / 14 PASTE TRIGS | 0x400c4acc / 0x400c396a | GRID REC, trig held + FUNC + REC / STOP |

pattern = the working pattern (0x405c8d04), track = the selected one (7F for pattern ops), ok = the function's result
byte, arg = the undo kind (1 clear, 2 paste) for the undo functions, else 0. Stock calls the undo function first on
every paste and clear: ok 0 (nothing undone, the paste follows) or ok 1 (undone, no paste): the host undoes on ok 1.
The page index is not located (arg 0).

Seq mode: the trig keys and PAGE are the host's, so stock's page and trig ops cannot happen on a seq track. A host-held
trig (or PAGE) + FUNC + RECORD / STOP / PLAY is caught instead (press and release eaten) and reported with src 1: ops
13 / 14 / 15 (copy / paste / clear the held trigs, arg = their mask) or 9 / 10 / 11 (the host's page); stock does nothing.
FUNC + RECORD / STOP / PLAY without a held key stays stock's (the track ops, reported). FUNC + PAGE is stock's again in
seq mode (PAGE with FUNC held is not caught): SCALE is reachable on a seq track in GRID REC.

### Pattern dirty, the dump

A rolling checksum of the working pattern's 85 760 bytes, 4 KB a UI tick (a pass in 1.05 s); a changed chunk or an
edit report sets dirty; 2D 0B goes out at most every 4 ticks. The host refetches the pattern by the stock SysEx dump:
request `F0 00 20 3C 07 00 64 01 01 <n> 00 00 00 05 F7` with n = the active pattern (2D 02): its answer is the working
buffer as edited, saved or not; `0x80` (the community's working-buffer number) answers the same, but 0x80 is not a MIDI
data byte and a byte-stream MIDI path cuts the SysEx there (rytm-emu's link did). The answer `F0 00 20 3C 07 00 54 01 01
<pattern> 00 <00 00 00 05: the record's header> <13097 B 7-bit packed> <checksum hi lo: the sum of the bytes from
<pattern> up to it & 0x3FFF> <length hi lo: size - 10> F7`, 14988 bytes, the record 13101 B [measured: sq_emu.py fetch;
an unsaved trig is in it; while playing with a seq track no tick is dropped].

### Tests [measured, rytm-emu seq-p2, DTEMU_STRICT=1]: `tools/emu/sq_emu.py TAG all` (1032's + these)

- `pin`: 2E BD, no trig anywhere: BD's records held (`0000007f` + the hold), filter word 0, velocity 0x7f00, VCA open
  (0 in the base), SD untouched, one start, the hook under 20 us; BD on 6-OP FM with a sine into its Overbridge input:
  the analog mix silent stock, RMS 0.075 pinned; 46 BD: the decay record, `closes` 1; 46 nothing: a second start; 2E
  mask 0: closing (decay); a host brown-out and new hello: the pin forgotten.
- `pinvel`: velocity-32 notes (9D 24 20): stock VCA 0x0cc4, pinned 0x32a9 (as sent, never dipping at a velocity-32 or -64
  trig: DTEMU_FRAME_TRACE); the pin mask without a seq track; BD on 6-OP FM pinned: its 0x04 still velocity 32; flags
  bit 2: stock's VCA.
- `edits`: pattern copy, the paste's undo check (0), paste, UNDO PASTE (1, kind 2), the clear's check (0, kind 1), clear;
  GRID REC: track copy / paste / clear with their checks, page copy / paste with its check, trig copy / paste.
- `seqedit`: seq mode on BD: T1 + T3 held + FUNC + REC -> 13 src 1 mask 5, T2 + FUNC + STOP / PLAY -> 14 / 15 mask 2, PAGE
  + FUNC + REC -> 9 src 1, FUNC + REC alone -> stock's 5; no stock change in BD's track; FUNC + PAGE: stock's SCALE (no
  31 PAGE), DOWN x 2 -> 2D 04 BD 15, 14.
- `scale`: the resync's 13 reports (SD poked to 32 steps at 2x reported so; the pattern: mode 1, chg 16).
- `dirty`: none in 3 s of play; a trig placed in GRID REC: 0B 00.
- `fetch`: the dump answer's layout, checksum and length rule while playing; no tick dropped; an unsaved trig in A01's
  answer, 00 and 80 the same bytes.

All suites (cu frz fxin mrep pc rled rui sfu sfx sp sq sv td us) pass under DTEMU_STRICT=1 with rytm-emu seq-p2.

### Not in 1033

Swing is not located (the 1.73 TEMPO screen shows BPM only; the swing menu reads byte +5 of an object the pattern's
vfunc returns [code]): the host keeps its own swing per track. A latched FILL is not followed (the key only). Page clear
was not run (its function is wrapped by its code address). The page index of stock page ops is not located (arg 0; on
seq tracks the host's own page is used). Hardware listening is mandatory before relying on the pin (clicks at the start
command, the open voice's noise floor, the close record's speed).

## 1034: WAVETABLE and GRANULAR (emulator only)

**What the user sees.** WAVETABLE (machine 46, voice flag 0x28) and GRANULAR (47, 0x38) on every track's machine list,
after DSP SAMPLE (so DAISYSP and MULTISAMP move two entries down). Names, looks, defaults and texts are the host's
(rytm-teensy docs/WAVETABLE.md 6, docs/GRANULAR.md 5):
- WAVETABLE SRC: TBL POS WARP AMT UNI SUB CUT RES (defaults 0 0 0 0 0 0 64 0; WARP OFF SYNC PWM FM, 4 zones); SMPL: ATK
  DEC SUS ENV / CHD INV SPR VOI (MULTISAMPLE's chord knobs).
- GRANULAR SRC: SRC POS SPRY SIZE DENS PRND REV WIN (defaults 10 0 20 64 64 0 0 0; SRC IN MAIN BD SD RS-CP BT LT MT-HT
  CH-OH CY-CB PAD BELLS for 0..11, a number above; WIN HANN TRI TUKEY PERC, 4 zones); SMPL: ATK REL HOLD ANIM / CHD INV SPR
  VOI (integ-0.3: HOLD 0..119 reads v x 99 / 119, 120..127 FRZ; ANIM 0 OFF, then 8BAR 4BAR 2BAR 1BAR 1/2 1/4 1/8 1/16 by
  16s; both continuous).
TBL is a number. The page-2 defaults in the tables (WAVETABLE 0 64 100 64, GRANULAR 10 60 0 0) are the records'; as for
MULTISAMPLE, a machine choice keeps the sound's sample words 17..24 (stock's set_machine writes only P1..P8).

**How.** No parameter records are free, so the three machines share MULTISAMPLE's SRC records (cu_src). The tables are
per machine (`cu_tab`: cu_srck / cu_p2k MULTISAMPLE, cu_wtk / cu_wtp2k, cu_grk / cu_grp2k; P11 / P12 of GRANULAR may
change with the host's ANIM). `cu_src_setup(m)` writes the eight records as m's (descriptor look and text, names, group,
range, default, and the machine field +0x00 = m, which US_COMMIT's drain compares) and copies machine 52's eight ids of
sound_param_id_for_index's table (0x413db5fc, built at boot from the machine fields) to 46 and 47. It runs from
`cu_setup` (0021's us_page_record for the selected track's machine, every UI tick) and from `cu_prep`, called by a
detour at set_machine's entry (0x400bd14e, `cu_setm_det`), so the machine's own defaults are written by the choice.
`cu_text` and `cu_steps` read the set the records hold (cu.p1m / cu.p2m). Names and masks: registry patches (cu_wt_name,
cu_gr_name, ...).

**Limit.** The shared records hold one machine's set at a time (the selected track's): a MIDI CC or a queued knob
commit for another track on a different one of the three machines lands where the record's machine field is that
track's machine only.

**Tests** [measured, rytm-emu, DTEMU_STRICT=1]: `tools/emu/cu_emu.py TAG wt gr swap` - each from the list (machine byte
46 / 47), SRC and SMPL labels and group, the records' machine field, 46's / 47's ids = 52's, P1..P8 = the defaults, a BD
pad's 0x04 with 0x28 / 0x38 and the defaults; WARP / WIN turned to a zone's low end, HOLD and ANIM turned (PNGs: SYNC, HANN, HOLD 37 -> 30, ANIM 4 -> 8BAR);
GRANULAR -> WAVETABLE -> MULTISAMPLE: each choice's labels and defaults.

## 1036: FUNC + LFO's SEQ page, p-lock keys in seq mode, the SRC view's pushes, source names (47), parameter writes (48) (emulator only)

Tags as above; [measured] = rytm-emu seq-p2, rui1036, 2026-10-20, DTEMU_STRICT=1. No hardware. Host half: rytm-teensy
`seq-ux` (docs/SEQUENCER.md "Built: seq-ux"; the wire in sim/protocol.py).

(1037 moved this gesture to TRK + TRIG and gave FUNC + LFO back to stock: "1037" below.)

**FUNC + LFO** opens the remote page on the Sidecar's SEQ page of the selected track (0x41318982). Stock 1.73's FUNC +
LFO is the same as LFO alone (the stock LFO page), and FUNC alone changes nothing on the main screen [measured, the stock
image]. So, as with TRK + LFO, 0026 takes the gesture: the LFO press and release reach neither stock nor the host, and
FUNC stays with whoever it went to. The 30's page byte carries the track:

    F0 7D 52 54 30 01 <0x10 + track> <on 1> <reason 0 user> F7     page 16..27: the SEQ page of track 0..11

When the page is already open (TRK + YES), FUNC + LFO sends the same 30 again and the page stays. Once FUNC + LFO has
sent the page there, FUNC + LFO again leaves (30 0 0 3, as TRK + YES does). TRK + LFO afterwards is the LFO page again.
An old host opens its SIDECAR page (it ignores the page byte). If the track is no seq track, the host asks whether to
make it one (rytm-teensy docs/SEQUENCER.md). [measured, `sq_emu.py funclfo`: 30 10 1 0, then 30 0 0 3; LFO never in a
31; the screen after leaving is the screen with no gesture; SD selected: 30 11; with the page open: 30 0 1 0, 30 10 1
0, 30 0 0 3; LFO alone afterwards is stock's LFO page]

**Seq mode, page closed, a trig held:** the page keys TRIG SRC SMPL FLTR AMP LFO (0x30..0x35), FX (0x10), NO (0x45)
and the encoder pushes (0x70..0x77) go to the host (31 down / up; the release goes where the press went: `sq.down`).
Stock does not get them: its page would open showing the sound's own values, and the turns under a held trig are the
host's anyway. These keys are the host's p-lock gestures (hold trig + SRC + turn = locks on the held steps; NO = clear
them; a push = clear that knob's lock). With the page open, its catch mask already routes them (they are in the SEQ
page's mask). FUNC + LFO with a trig held still opens the SEQ page. Without a held trig the keys stay stock's.
[measured, `sq_emu.py lockkeys`: T1 held, then SRC NO PUSH_A SMPL FLTR AMP FX LFO each down / up, and the turns A +6 /
B -2, all reach the host; the screen and BD's track are as in the run without them; FLTR after the release is stock's
FLTR page]

**The SRC view's pushes (31, nothing caught):** while the 1027 SRC view is on (a Sidecar track's stock SRC page), an
encoder push is reported as `31 01 00 <0x70..0x77> <down>` at its press and at its release, and stock still gets it.
The host keeps its source list (GRANULAR SRC, WAVETABLE TBL, MULTISAMPLE INST) open while P1's push is held.
[measured, `sv_emu.py push`: PUSH_A and PUSH_C down / up reported; screen and kit as in the run without them; on FLTR
no 31]

**Source names (47, host -> Rytm):**

    F0 7D 52 54 47 01 <list> <replace 0/1> <total 0..127> {<slot> <13 name bytes>} x 0..8 F7
    list 0 GRANULAR SRC, 1 WAVETABLE TBL, 2 MULTISAMPLE INST

The layout is 16 / 17's (JUNO, FM) with the list byte in front. 9 characters are kept per name (0021's JN_NAME), for
128 values, 3.8 KB in the area's .bss. cu_text gives those knobs (text kinds 9 and 12) the name of entry
min(value, total - 1). With no list (total 0), GRANULAR keeps its own IN MAIN BD .. BELLS texts and TBL / INST show the
number. Value texts are read by the stock page, its p-lock display and the bottom bar alike. Malformed (a list > 2, a
length that is not 3 + 14 n): rx_bad, names kept. [measured, `sv_emu.py names`: BD on GRANULAR, 4 names, SRC turned to
11: the page shows DRONE (sv_names.png) where the run without the list shows 11]

**Parameter write (48, host -> Rytm; the answer Rytm -> host):**

    host -> Rytm  F0 7D 52 54 48 01 <track 0..11> <param 0..15> <value 0..127> [<fraction 0..127>] F7
    Rytm -> host  F0 7D 52 54 48 01 <track> <param> <status 0 written / 1 refused / 2 no such parameter> F7

The MIDI task queues it (8 entries; a full queue drops and counts). The UI tick applies it as a knob turn does, through
0021's us_set path: SET_PARAM 0x4011f3fa (the live copy, container index 9 + param) and kit_param_changed 0x4003355c
on the KitBank (0x40194618()) with the record sound_param_id_for_index 0x40007028(9 + param, machine). The bank's drain
then writes the kit word and the project's copy (saved, kept over a power-off). Limit (1034): MULTISAMPLE, WAVETABLE
and GRANULAR share their SRC records. The drain keeps a record of the track's machine only, so a P1..P8 write to such
a track is refused (status 1) unless the records are set up for its machine (the selected track's machine). The host
keeps its own override then (rytm-teensy gr::pick). [measured, `sv_emu.py names`: 48 0 0 2 -> BD's kit word 0 =
0x0200, answered 48 1 0 0 0, the SRC view's 2A reports P1 = 2]

0022's router (rui=1) now also passes 47 and 48 to 0026 (46..48). The router's other builds are unchanged.

Tests [measured, DTEMU_STRICT=1]: `sq_emu.py rui1036 funclfo lockkeys` and `sv_emu.py rui1036 push names`, plus every
suite (cu frz fxin mrep pc rled rui sfu sfx sp sq sv td us) under DTEMU_STRICT=1. End to end with the real core as the
host (rytm-teensy `sim/seq_e2e.py ux lock`): FUNC + LFO on BD (6-OP FM) shows the make prompt on the Rytm's screen, YES
makes it a seq track, hold T1 + SRC + B / G shows LOCK SRC with the locked knobs marked, and a CY pattern with LEV
locked on steps 5 / 13 plays them at 12 / 100 of the others.

**Build rui1036** (rui1035's mods and parameters): `build/b.sh rui1036`; verify PASS.

### 1036b: UP + T1..T5, the Pi display's pages; the selected track for its VOICE view (49)

The user asked for a MegaCommand-style way to drive the whole Pi touchscreen from the Rytm: hold a key, press T1..T5 to
switch the display's page.

**Which combo is free [measured, rytm-emu, the stock 1.73 image (rled_stock), 2026-10-20]:** for 30 hold keys, the
probe compared two runs: the key held alone, and the key held + T3 + T5. It compared the screen, the working pattern,
the sequencer state, the next pattern, the kit and the active kit, the selected track, the mutes and every LED, on the
main screen and in GRID REC (UP and DOWN also on the FLTR page and in CHRO and MUTE mode).

- FUNC + trig: a no-op on the main screen, but in GRID REC it changes the pattern (a stock function).
- PERF and SCNE: open their own screens when pressed.
- CHRO: changes the pads' mode.
- PAGE + trig: seq mode's page select (1032).
- SRC + trig and FX + trig: the lock pages' keys (hold trig + SRC; the other order would collide).
- Every other key (TRK, MUTE, YES, NO, the BANKs, TEMPO, FIX, RTRG, FILL, QPER, SONG, CHAIN, PLAYMODE, GLOBAL, SAMPLER, the
  page keys) changes the result of the trig or the LEDs.
- **UP and DOWN** (the arrows) + trig leave exactly what the trig alone leaves, in every context tried, and the arrow
  alone changes nothing on the main screen or in GRID REC.

UP was chosen (up to the display). The cost: in a menu the arrow moves its cursor once, as it always does. FUNC + pad 1..5
were not needed.

**What 0026 does:** with UP held (whoever got its press), T1..T5 are eaten, press and release; no trig is placed and
nothing goes to the host's seq keys. Each one sends:

    Rytm -> host  F0 7D 52 54 49 01 01 <page 1..5> F7     1 HOME, 2 SEQ, 3 PAT, 4 VOICE, 5 SET

**The selected track (for VOICE and the touchscreen's follow):** polled every UI tick, sent through the try-lock after the
first hello, behind everything else:

    49 01 02 <track> <machine 0..52> <name 12 B>           on a track or machine change and after each hello
    49 01 03 <track> {<value 0..127> <label 4 B>} x 8      P1..P8 of the active kit's sound (kit words 0..7) and the
                                                           records' short names; on any change and after each hello

The long names come from the machine table (0x401befa4 + 8 m, long then short; 0026's own names for 46, 47 and 52 by
registry patch) [code]. Each label is the record's short-name pointer (+0x30, which cu_knob sets), the record from
sound_param_id_for_index(9 + k, m). An analog track sends its own names too (BD PLASTIC: LEV TUN DEC TYP MOD SWT SWD TIC
[measured]).

Tests [measured, `sq_emu.py rui1036 disp`]:
- UP + T1 / T2 / T5 -> 49 1 1 / 2 / 5. In GRID REC, BD's track is as in the base and no 31 is sent.
- 49 2 0 21 "BD PLASTIC", then TRK + SD -> 49 2 1 2 "SD HARD". 49 3 carries BD's values and labels.
- Turning knob B sends a 49 3 with the moved value.

## 1037: TRK + TRIG opens the SEQ page (FUNC + LFO stock's again); trig held + YES is the host's step preview (emulator only)

Tags as above; [measured] = rytm-emu seq-p2 (50a0139), rui1037, 2026-10-21, DTEMU_STRICT=1. No hardware. Host half:
rytm-teensy `song-mvp` (docs/SEQUENCER.md "Built: rui1037").

**Why:** the user asked for TRK + TRIG instead of FUNC + LFO (TRK + key is already the Sidecar's family: TRK + YES, TRK +
LFO), and for the stock FUNC + LFO back.

**Stock 1.73 binds nothing to TRK + TRIG [measured, `rled_emu.py stocktrktrig`, the stock image (rled_stock: a fresh
card, the startup dialogs answered)].** Four runs per context, on the main screen, in GRID REC (T1 / T5 placed) and on
the TRIG page: no key, TRK alone (held 0.3 s), TRIG alone, TRK held + TRIG. Compared at the end: the screen, every LED's
four colour slots and the selectors, the working pattern's 12 tracks (A01 live, 0x407dd8e3, 917 B a track), the
sequencer's state (0x405c8c90..+0xB0), the selected track (0x41318982) and the kit words (0x800067b0..+16).
- TRK alone changes only LED 55's slot 1 (0x52 -> 0x0f; TRK's own LED [inferred]), in every context.
- TRIG alone opens the TRIG page (the screen, the selectors, LEDs 38 / 39); on the TRIG page it changes the screen.
- TRK + TRIG leaves exactly what TRIG alone leaves, plus TRK's LED 55: nothing of its own.

So 0026 takes TRK + TRIG exactly as 1036 took FUNC + LFO; the code is the same block with the key and the modifier
swapped:

    TRK held (whoever got its press) + TRIG (0x30): 30 01 <0x10 + track> 01 00   the SEQ page of the selected track

TRIG's press and release reach neither stock nor the host; TRK stays whose it was. With the page open (TRK + YES) it
sends the same 30 again and the page stays; once TRK + TRIG has sent the page there, TRK + TRIG again leaves (30 0 0 3).
TRK + LFO afterwards is the LFO page again. The block sits before seq mode's held-trig keys, so with a trig held TRK +
TRIG still opens the SEQ page, and hold trig + TRIG without TRK stays the host's lock key (TRIG's lock page). The wire is
unchanged, so every host since 1036 works as before. FUNC + LFO has no 0026 code any more: stock's LFO page, and in seq
mode under a held trig the host's LFO lock key like LFO alone. [measured, `sq_emu.py trktrig`: 30 10 1 0 then 30 0 0 3, no
31 TRIG, the screen after leaving = no gesture; SD selected: 30 11; with the page open: 30 0 1 0, 30 10 1 0, 30 0 0 3;
TRIG alone afterwards is stock's TRIG page; FUNC + LFO: no 30, no 31 LFO, the screen LFO alone leaves (the stock LFO
page)]

**Trig held + YES: the host's step preview.** In seq mode (a Sidecar seq track selected, GRID REC on) with the page
closed and a host trig held, YES (0x44) joins the held-trig keys (the page keys, NO, the pushes): 31 down / up to the
host, the release where the press went (sq.down), stock gets neither. The host plays the held steps' notes
(rytm-teensy core/seq preview). With the page open YES is in every page's catch mask already (core/ui/remote.cpp
kCatchKeys), so no mask change.
- **What stock 1.73 does with trig held + YES [measured, `rled_emu.py stockyes`, the stock image]:** in GRID REC on the
  main screen and on the TRIG page, and outside GRID REC: T1 held + YES leaves what T1 held alone leaves, plus what YES
  alone leaves. YES alone changes one word, 0x405c8d20: 0 -> 0xffffffff (meaning not known), nothing else in the list
  (no screen, no LED, no trig). So stock has no trig preview or other function on this combo, and nothing is lost.
- **Only on Sidecar seq tracks:** seq mode needs the selected track in the host's 2E mask, so on any other track a held
  trig is stock's and so is YES [measured, `sq_emu.py yes`: SD the seq track and BD selected, T1 + YES: no 31, BD's track
  and the screen as with no 2E]. Without a held trig YES is stock's in seq mode too [measured: no 31 YES, the screen as on a
  Rytm with no seq tracks]. TRK + YES (the page in / out) still wins over a held trig (it is checked first).

Tests [measured, DTEMU_STRICT=1]: `rled_emu.py rui1036 stocktrktrig stockyes` (the stock image; the tag only names the
harness's symbols), `sq_emu.py rui1037 trktrig lockkeys yes` (lockkeys now also TRIG and YES under T1, TRK + TRIG with T1
held -> 30 10, FUNC + LFO with T1 held -> 31 LFO and no 30), and every suite (cu frz fxin mrep pc rled rui sfu sfx sp sq sv
td us). End to end with the real core as the host (rytm-teensy `sim/seq_e2e.py ux preview`, SEQ_TAG=rui1037): TRK + TRIG
on BD shows the make prompt; CY with a chord on step 1, GRID REC, T1 held + YES: the chord in the host's render with the
Rytm stopped.

**Build rui1037** (rui1036's mods and parameters): `build/b.sh rui1037`; verify PASS.

## 1038: source banks for GRANULAR / WAVETABLE / MULTISAMPLE, the bank list, UP + T6..T10 (emulator only)

Tags as above; [measured] = rytm-emu seq-p2 (50a0139), 2026-10-21, DTEMU_STRICT=1. No hardware. Host half: rytm-teensy
`banks` (docs/SRC-BANKS.md, the full design and the host's pool model).

**The word.** GRANULAR SRC, WAVETABLE TBL and MULTISAMPLE INST (P1, the shared record 398) hold one 14-bit value:
index 0..127 in the integer byte, bank 0..7 (A..H) in the fraction's top 3 bits: `word = index << 8 | bank << 5`. On the
wire (03 / 04, 2A, 48) that is `hi = index`, `lo = bank << 4`. A word whose bank bits are 0 is bank A, so every existing
kit and project reads as before.

**The four checks before building (design note section 5), and what they changed:**
1. *A coarse knob's step and the fraction.* Stock keeps it [measured, rui1037 image, BD on GRANULAR, the word set to
   0x05a0 by 48: knob A +8 x 3 -> 0x07a0, -8 x 3 -> 0x03a0, the SRC record continuous]. 0029's stepped path (mode 3, all
   128: MULTISAMPLE INST in 1037) clears it [measured: 0x05a0 -> 0x0600 / 0x0400]. The record's fine flag (+0x14) does not
   change the knob's step [measured: poked to 1, the same 0x07a0 / 0x03a0]; the step is the look's. So 0029 got a keep
   rule (below) and all three knobs use it, one index a detent.
2. *A fine-flagged lock over a power-off.* With the flag, a lock made by knob A with T1 held in GRID REC saves P1's slot
   (type 0, track 0, the index) followed by the fine slot (0x80 0x80, `word >> 1 & 0x7f` = 0x50), and after the power-off
   handler and a cold boot on that card the live lock is 0x05a0 again [measured, rui1037 with the flag poked, and
   rui1038 `bk_emu.py lock`]. Without the flag only the index slot is saved (7 bits) [measured]. The per-track flag byte
   (+5632 + k of the live lock block) is set by track_lock_set from the record's flag [measured: 1 for k = 9].
3. *What stock sends on MIDI.* Nothing in the base (ENCODER DEST INT). With PARAM OUTPUT NRPN and ENCODER DEST INT+EXT
   (rytm-teensy sim/song_e2e.py's walk) every knob sends NRPN with MSB = the integer and LSB = the fraction's top 7 bits:
   STA (fine) 1:12 6 0 / 38 4, TUN 1:8 0x42 / 0, GRANULAR SRC (word 0x07a0) 1:0 7 / 0x50, flag or not [measured, DIN and
   USB alike]. **This corrects the design note's [inferred] "CC = index only, bank lost": in NRPN mode the bank is on
   the wire (LSB >> 4); only CC mode (CC 16) carries the index alone.** The host still records SRC from its own 14-bit
   reports (the user's rule), never from CC / NRPN.
4. *The display.* The page and the bottom bar show the name (bank F's names from 47: the name; none: `F002`; index 0 of
   B..H: `OFF`), never index.fraction [measured, `bk_emu.py text`, bk_text-*.png].

**The record and the knob.** cu_knob gives P1's record (only it: `CU_KEEP`, bit 11 of the steps word) the fine flag
(+0x14 = 1) and the range 0..0x7fe0 (bank H's 127 passes: 48 127 <H> -> 0x7fe0, a turn up keeps it, down 0x7ee0
[measured, `range`]). cu_steps answers 0x380 | 0x800 for the three P1s: 0029 mode 3 (all 128) plus keep. In 0029
(`sfu.c`, `xk[]` appended): x_knob carries the word's fraction bits 0xe0 into the knob's value (so the value text knows
the bank), x_half keeps them, and the set's write and lock-set (sfu_s_write, sfu_s_lset) store `index << 8 | the stored
word's (or lock's) 0xe0`, whatever the knob arithmetic did to the fraction; the range is (N - 1) << 8 | 0xe0. Knob A on
all three machines: one index a detent, the bank kept, the 2A with the 14 bits [measured, `knob`: 0x05a0 -> 0x06a0 /
0x04a0]. With a trig held stock's lock path through 0029 keeps the bank in the lock [measured, `lock`].

**The names (47).** A bank byte after `total`: `47 01 <list> <replace> <total> <bank 0..7> {<slot> <13 bytes>} x 0..8`
(4 + 14 n bytes; the old 3 + 14 n form is bank A, so older hosts work). The Rytm keeps one bank a list (`ux.nm_bank`, the
same 3.8 KB); a 47 of another bank replaces the names. cu_text: bank A as before (min(v, total - 1), GRANULAR's built-in
texts, a number); B..H: index 0 `OFF`, the name when that bank's names are held and the row has one, else `B005`.

**The bank list (4A), opened by turning knob A** (as stock's SMPL knob D opens SAMPLE SLOT [measured, the rui1037 image on
BD PLASTIC, stock's code path: the first turn opens the list on the current entry without moving it, later turns move
the cursor and retitle CONFIRM? Y/N, DOWN moves it, LEFT does nothing, NO closes with nothing changed, the list stays
open with no key (the title goes back), and with a trig held in GRID REC a turn opens it too]):
- When: the 1027 SRC view of a WAVETABLE / GRANULAR / MULTISAMPLE track is on **and shows the host's frame** (sv.show:
  a host that draws), the page and the splash closed, not seq mode with a held trig (1032's turns are the host's). Then
  the first turn of knob A is eaten (the value does not move) and `4A 01 <track> 1 <hi> <lo> 0` goes out (P1 then).
  Without a drawing host the knob is stock's (0029's step, the bank kept) [measured, `list` "no frame"].
- Open: knob A's turns go to the host as 32 0 (summed, at the event); LEFT RIGHT UP DOWN as 31 down / up (the release
  where the press went, `ls.down`); YES / NO close it (`4A .. 0 <hi> <lo> 1` / `2`), their release eaten, never a 31;
  another knob closes it (why 3) and goes to stock; another key (not transport, pads, trig keys, FUNC) closes it (why 4)
  and goes on; the view ending (another page, a cover, a track or machine change, the TRK + YES page, the host gone)
  closes it (why 5). The 4A goes through flush() behind the 30 and before the keys and turns, so the host sees the open
  before its turns.
- Commit: the host answers why 1 with `48 01 <track> 0 <index> <bank << 4> <flags 1>`. Flags bit 0 = the list's commit:
  if trig keys were held at the YES (GRID REC: the grid object's 64-bit held-trig bitmap, `*(0x419f28d8) + 0x158` steps
  32..63, `+0x15c` steps 0..31 [measured, rytm-emu: T1 T2 T4 T7 T9 held -> 0x14b, T3 T5 T6 T11 T12 -> 0xc34; steps past
  16 on page 2.. [inferred] from trig_keys_held's (1 << len) - 1 mask]) and the 48 comes within 1 s for that track, P1
  is locked on those steps (track_lock_set, k 9, fine 1; 1030's slot budget check first: status 3 full, nothing
  written) and the reply is status 4 (locked); else the kit is written as before (status 0). [measured, `listlock`: T1 +
  T3 held, YES: 48 .. 1 -> locks 0x0940 on steps 1 and 3, step 2 none, the kit word still 0x05a0, the track's fine flag
  1; `list`: no trig held -> the kit 0x0940, status 0]
- [measured, `list`]: 4A open with P1 = 5 . F (720), three turns +8 as 32 0, LEFT and DOWN down / up as 31, YES -> 4A 0
  why 1 and no 31 YES; NO -> why 2, the word 0x05a0 unchanged; knob B -> why 3 and stock's P2 edited; FLTR -> why 4.

**UP + T6..T10.** `code <= 4` became `code <= 9`: 49 1 1 6..10 (6 INSERT FX, 7 SAMPLE / AUTO, 8 REC, 9 SCOPE, 10 SIDECAR;
the host's side exists since song-mvp). Stock 1.73 first [measured, `rled_emu.py stockup`, the stock image: on the main
screen, in GRID REC, on FLTR, in CHRO and in MUTE mode UP held + Tn leaves what Tn alone leaves plus what UP alone
leaves, for each n of 6..10: 25 of 25]; the checker now compares each LED selector byte on its own (in CHRO, UP alone and
T6 / T7 / T10 alone change different selector bytes, which the old one-string compare called a combo). The trig keys
are eaten as for T1..T5 [measured, `upt`: 49 1 1 6..10, BD's track as the same run without the trig presses, no 31].

**FUNC + PAGE over the page: stock's SCALE menu** (hardware report on rui1037: on a seq track in GRID REC the host's SEQ
page stayed over the SCALE menu, PAGE being in every page's catch mask). Stock's SCALE menu is a view stacked on top,
ScaleMenuView (vtable 0x401d1e74) [measured: the top view while it is open; NO or FUNC + PAGE again removes it]. Now with
the page open, PAGE with FUNC held (whoever got FUNC) goes to stock and the page **steps aside** (`st.aside`): draw_body
leaves the canvas to stock, every key and knob is stock's, the tick no longer forces redraws; when ScaleMenuView has
been on top and is gone (or never came within 1 s) the page is back (the shadow, the host's last frame, composed again).
TRK + YES, the host's 3A 0 and the timeout still leave as before (aside cleared). ScaleMenuView is also a known cover of
the 1027 SRC view. The host needs nothing new: it never sees PAGE, it keeps committing frames (shown after the menu) and
gets the new scale by 2D 04 as before. [measured, `bk_emu.py scale`: page open with the host's checkerboard, BD a seq
track (2E): FUNC + PAGE -> ScaleMenuView on top, the screen byte for byte the same keys' on a Rytm whose page never
opened, no 31 PAGE (FUNC down / up only), LEVEL in the menu sets BD's length 16 -> 17 as without the page, 2D 04 0 17 0 2
1 to the host; NO -> the host's frame on the glass, the page still open (one 30 on)]

**Cost.** Per tick one compare for the list's view; per turn on the view one word test. Memory: ls ~60 B, ux +16 B. The
lock path walks the 72 stored slots once per commit.

**Tests** [measured, DTEMU_STRICT=1]: `tools/emu/bk_emu.py rui1038 all` (knob range text lock list listlock upt nrpn scale),
`rled_emu.py rui1038 stockup` (the stock image), and every suite (cu frz fxin mrep pc rled rui sfu sfx sp sq sv td us).
End to end with the real core as the host: rytm-teensy `sim/rui_e2e.py srclist` (RUI_TAG_1038=rui1038).

**Build rui1038** (rui1037's mods and parameters): `build/b.sh rui1038`; verify PASS.

## 1037b: the hardware report on rui1037 - YES on the make prompt with TRK held, PLAY MODE under the page, the dirty poll's cost (emulator only)

Tags as above; [measured] = rytm-emu seq-p2 (50a0139), rui1037 / rui1037b, 2026-10-21, DTEMU_STRICT=1, the host the real
core (rytm-teensy `dbg`, sim/seq_e2e.py) or the suites' scripted one. No hardware.

**1. "After leaving poly mode the trig keys are broken; the LEDs stay red on the steps I entered."** Cause: YES on the
make prompt while TRK is still held from TRK + TRIG (natural: TRK + TRIG, then YES at once). rui1037 took that YES as
TRK + YES and left the page (30 0 0 3): the prompt went unanswered, so no seq track was made (host mask 0x000), GRID
REC's trig keys then went to stock and placed stock trigs on the track's own pattern (red), which play the 6-OP FM voice
(its chord), and outside GRID REC the trig keys select tracks and play them, as stock 1.73 does [measured on the stock
image: T2 outside GRID REC selects SD]. Clearing the stock track removed them. [measured, real core: TRK held 1.5 s over
TRIG and YES, then GRID REC and T1 T2 T3 T4 T9 T11 T13: rui1037 mask 0x000, those 7 steps red stock trigs on BD; rui1037b
mask 0x001, the 7 steps the host's (blue), BD's own track unchanged; `seq_e2e.py makeheld`] No TRK was ever left held in
stock (TRK's LED 55 dark at the end of every variant tried: TRK released before / after TRIG, across the prompt, the
page's open and close, seq mode's start and end, TRK + TRIG / TRK + YES / NO / RECORD to leave).

Fix: TRK + TRIG and TRK + LFO mark the TRK hold (`tk.used`, cleared at TRK's release); YES during that hold with the page
open is the page's YES (by its mask, the host's prompt answer; `tk.yes_page` counts them), not TRK + YES. A fresh TRK
hold + YES leaves as before; with the page closed TRK + YES opens as before (also after TRK + TRIG closed it in the same
hold). [measured, `sq_emu.py trkyes`: TRK + TRIG then YES with TRK held: 30 10 1 0 only, 31 YES down / up; a fresh TRK +
YES 30 0 0 3; TRK + LFO the same; rui1037 fails it (30 0 0 3, no 31 YES)]

**2. "The UI is much slower with the SEQ page open while playing."** Two costs:
- 0026's own UI-task time per tick was dominated by the dirty poll (1033: a rolling checksum of 4 KB of the working
  pattern a tick, byte loads, from the first 2E on). Now a long word a load over the aligned span around the pattern
  (it starts at 0x407dd8e3: up to 3 bytes of the neighbouring patterns are in it, written only when those are), 1024
  loads a tick. [measured, 0026's ui_sum per UI tick x 200 / 132, 5 s at 127 BPM, real core: page open playing 162.8 k ->
  45.3 k instructions a tick; page closed in seq mode 105.1 k -> 15.0 k; a host with no seq track 88.3 k -> 14.0 k;
  the page open, stopped 85.7 k -> 14.3 k]
- Each host commit (39) redraws the stock screen under the page. The host's SEQ page moved its playhead every frame
  while playing; rytm-teensy `dbg` moves it at most every 250 ms (the trig LEDs still show every step). [measured: stock
  draws (0x400a2c56) in 100 UI ticks, page open playing: 100 with the host before that change (rui1037 or rui1037b) ->
  55 (rui1037b + dbg); 43 with the page closed (stock's own while playing in GRID REC); core/tests/test_traffic.cpp case
  7: 8 -> 4 commits a second]

**3. "From MUTE mode the PLAY (mode) key needs MUTE again."** PLAY MODE (0xB5) is a pad-mode key like MUTE and CHRO,
but the host's masks caught it (it is also FUNC + PLAY MODE = the KIT menu), so with the page open (seq mode opens it)
PLAY MODE never reached stock. [measured: stock 1.73 MUTE then PLAY MODE: play mode again (LED 50 lit, 49 dark); rui1037
with the page open (TRK + YES, or seq mode): MUTE mode stays; MUTE again leaves it] Fix: PLAY MODE without FUNC is always
stock's (key_owner); FUNC + PLAY MODE stays the mask's (the KIT menu would open unseen under the page). [measured,
`sq_emu.py playmode`: the host's mask, MUTE then PLAY MODE: LED 50 lit, no 31 0xB5; FUNC + PLAY MODE: 31 0xB5; rui1037
fails it]

Tests [measured, DTEMU_STRICT=1]: `sq_emu.py rui1037b trkyes playmode` and every suite (cu frz fxin mrep pc rled rui sfu
sfx sp sq sv td us); rytm-teensy `dbg`: `sim/seq_e2e.py` (all runs, SEQ_TAG=rui1037b; new: makeheld, fresh) and
`make -C core test` (test_traffic case 7, test_seq's fresh chord).

**Build rui1037b** (rui1037's mods and parameters): `build/b.sh rui1037b`; verify PASS.

## 1039: rui1038 + rui1037b merged (emulator only, no new behaviour)

`rui1039` = `rui1038` (d75ad0f) with `rui1037b` (d735b46) merged, both from rui1037 (495bb48). rui.c merged without
conflict; design.md / mod.toml keep both sides; stub.s regenerated from the merged rui.c by `build.sh` (the same
m68k-elf-gcc reproduces rui1038's stub.s byte for byte from its rui.c). The interactions, checked in the merged source
[inferred from the code; the tests below measure them]:
- 1037b's YES-to-page rule (`tk.used && st.active`) only applies with the page open; 1038's bank list only runs with the
  page closed (`!st.active && ls_key`), so the list's YES / NO and its nav keys (31 / 32 while open) are unchanged. With
  SCALE aside (1038), a YES under TRK + TRIG's hold falls through to `key_owner`'s `st.aside` test and stays stock's (the
  SCALE menu's YES), as every key there.
- 1037b's PLAY MODE rule sits in `key_owner`, reached only with the page open and not aside; with the bank list open
  PLAY MODE closes the list (ls_key's "another key") and is stock's, as in 1038.
- The dirty poll (1037b's long-word dk_poll) covers the aligned span around the working pattern (SQ_PATD, 85760 B);
  rui1038 changed neither SQ_PATD nor the pattern's size: 21 chunks of 1024 words, within dk_sum[24] / dk_init's bits.

**Tests** [measured, rytm-emu seq-p2, DTEMU_STRICT=1, 2026-10-21]: the 14 suites (cu frz fxin mrep pc rled rui sfu sfx sp
sq sv td us) all PASS (rui failed escape / full once with all 14 running in parallel, the scripted host starved; alone
ALL PASS), `bk_emu.py rui1039 all`, `rled_emu.py rui1039 stockup`, `sq_emu.py rui1039 trkyes playmode yes trktrig
lockkeys`. End to end with the real core as the host (rytm-teensy `song-mvp`, both host sides): `sim/seq_e2e.py` (all
runs, SEQ_TAG=rui1039) and `sim/rui_e2e.py srclist` (RUI_TAG_1038=rui1039).

**Build rui1039** (rui1038's mods and parameters): `build/b.sh rui1039`; verify PASS.

## 1040: the hardware report on rui1039 - step copy in seq mode, FUNC + YES's file browser, TRIG on seq tracks (emulator only)

Tags as above; [measured] = rytm-emu seq-p2 (50a0139), rui1039 / rui1040, 2026-10-21, DTEMU_STRICT=1, the host the real
core (rytm-teensy `fix1040`, sim/seq_e2e.py, sim/rui_e2e.py) or the suites' scripted one. No hardware. Host half:
rytm-teensy `fix1040` (docs/SEQUENCER.md "rui1040", docs/SRC-BANKS.md "rui1040").

**1. "Step copy in seq mode breaks out of the seq track" (trig held + FUNC + REC / STOP / PLAY).** Cause: 1033's catch
of the held-trig copy / paste / clear only ran with the remote page closed (`!st.active`), but seq mode opens the host's
SEQ page (core/seq on 2D 08 1). With the page open the held trigs and PAGE are the page's (st.our_down, by its catch
mask), not sq.down, and RECORD / STOP / PLAY are always stock's (key_owner). Stock got FUNC + REC in GRID REC with no trig
of its own held: COPY TRK, FUNC + STOP PASTE TRK, FUNC + PLAY CLEAR TRK (2D 0A ops 5 / 6 / 7, src 0), PAGE + FUNC + REC its
COPY PAGE (9, src 0), and the host applied them to its whole track. [measured, rui1039: `sq_emu.py seqpage` -> ops 5, 8 /
6, 8 / 7, 9 (src 0), 5; with the real core (seq_e2e stepedit's gesture): T1 + FUNC + PLAY cleared every step of BD,
T1 copy then T5 paste left T5 empty] TRK is not involved (no TRK in the gesture; key_body's TRK rules are not reached).
The red trig LEDs the user saw were not reproduced in the emulator (its LEDs stayed the host's); stock's track paste of
its own (red) trigs is the likely source on hardware [inferred].
Fix: the catch also runs with the page open (not with SCALE aside): held trigs = sq.down | st.our_down (T1..T16), PAGE
held from either. [measured, rui1040: `sq_emu.py seqpage` -> 13 mask 5, 14 mask 2, 15 mask 2, 9, all src 1, then FUNC +
REC alone stock's 5 (src 0); BD's track unchanged; end to end `seq_e2e.py stepedit`: T1 copy, T5 paste, T3 clear -> the
host's steps 1:60 5:60, reports 0D 0E 0F src 1, no stock track op] Without a held trig or PAGE the pattern / track
ops stay stock's (`sq_emu.py edits seqedit` unchanged). The host now also marks the held keys used on a src 1 report (no
tap toggle, no page step at their release).

**2. FUNC + YES on the bank list: the host's file browser for that row.** (Stock's sample list has the same Fn + YES
hint.) With the list open (1038) FUNC (stock's, it keeps the list open) + YES: YES's press and release are eaten and
`4A 01 <track> 3 <hi> <lo> 0` goes out (on 3). From then until the host gives them back, YES and NO go to the host as 31
down / up like LEFT RIGHT UP DOWN (their release where the press went: `ls.fwd`); knob A stays 32. New host -> Rytm
message (0022's router passes 4A with rui=1):

    host -> Rytm  F0 7D 52 54 4A 01 <track 0..11> <browse 0/1> F7   1: the browser is open (YES / NO the host's);
                                                                    0: closed (YES / NO the list's again)

The Rytm takes it at the UI tick (ls_tick) for the list's track. No answer within 1 s (an older host): YES / NO are the
list's again. Another knob, another key or the view ending close the list as before (and the browser with it; the 4A
off tells the host). The host's side: rytm-teensy docs/SRC-BANKS.md "rui1040" (banks B..H rows 1..127; bank A and row
000 refused with a note; YES on a file writes the pool line 128 * bank + row and returns to the list on that row).
[measured, `bk_emu.py browse`: 4A on 3, after the host's 4A 0 1 YES / NO / DOWN as 31, after its 4A 0 0 YES closes (why
1), the word unchanged; no answer: YES closes after 1 s; end to end `rui_e2e.py srcbrowse`: bank C row 1, FUNC + YES,
YES into /Banks, DOWN, YES on beta.wav -> C001 = /Banks/beta.wav, the list on 001 BETA, YES commits 48 0 0 1 0x20 1]

**3. "The bank indicator covers the bank letter".** Host side (rytm-teensy core/ui/page_wavegrain.cpp): the tab row was
one text item "< A B C D E F G H >" with the bank's letter drawn again, inverted, at 5 px a character; the Rytm's own
glyphs are narrower (its space ~2 px), so the box landed on the next letter and over it [measured, rytm-emu rui1039 +
the real core: bank B's box over "C"]. Now each letter is its own item at a 9 px pitch, the selected one in a filled box
with its letter inverted (as the row cursor), the arrows as pixels. No Rytm change.

**4. "I can go to the SRC page in seq mode when I press a step."** What happens [measured, rui1039 + the real core]: in
seq mode the host's SEQ page is open; T1 held + SRC shows the host's LOCK SRC page (the machine's P1..P8 with the held
step's lock values, locked knobs framed; turning locks), and releasing T1 returns to the SEQ page. SRC without a held
trig does nothing under the page (caught, the host ignores it). With the page closed in seq mode (after TRK + YES),
SRC alone is stock's SRC page, T1 held + SRC opens the host's page on LOCK SRC (1036), and after the release the SEQ page
stays. The user then asked for the stock-like model: TRIG on a seq track shows the SEQ page (the notes), TRIG again its
trig values (the host's TRIG view, with Elektron-style trig conditions), held step + SRC / SMPL / FX the lock pages with
the held step's values (as before), FLTR / AMP / LFO the host's page explaining they are not locked per step (the
Rytm's analog side, 1036's "Not built"). Rytm change: TRIG alone in seq mode with the page closed goes to the host (31;
with the page open its mask already sends it), so stock's TRIG page no longer opens over a seq track in GRID REC.
[measured, `sq_emu.py trigkey`: 31 0x30 down / up, the screen as without the press; without a 2E TRIG stock's. End to
end `seq_e2e.py trigview`: TRIG -> SEQ TRIG, TRIG again -> the notes view byte for byte, TRIG + T1 held + COND +9 ->
step 1 on 1:2, T1 + SRC -> LOCK SRC] Host-drawn pages were chosen over stock's own pages: stock's SRC / TRIG pages under
a held trig would show and lock the Rytm track's own (red) trigs, which a seq track does not play, and the host's lock
values never reach the Rytm's lock storage.

**5. "After selecting another track the pads and trigs still play the seq track's 6-OP FM" (and "TRK + pad does not
switch in seq mode").** Measured with the real core [rytm-emu, rui1039 / rui1040, `seq_e2e.py padsel`]:
- In GRID REC a plain pad press selects its track (stock), so the SD pad ends seq mode on the Rytm (2D 08 0) - but the
  SEQ page TRK + TRIG opened stayed open, so the trig keys were still the host's SEQ page's and T2 placed a host note on
  BD (host fix: the 49 02 selection change closes the SEQ view's page when the new track is no seq track).
- The pads: in the normal pad mode a pad sends note t (0..11, its track) on the auto channel (14), in CHRO the selected
  track's chromatic notes (12..) [measured: BD / SD / BT -> ch 14 notes 0 / 1 / 4; re/subsystems/midi-cc.md]. The host's
  live binding (rytm-teensy core/poly.cpp, a channel bound to the voice whose 0x04 trig coincides with its note-ons)
  bound ch 14 to BD's 6-OP FM voice from BD's own normal-mode pad hits, and from then every pad (SD's too) played that
  voice; no 0026 code forces or changes the pad mode. Host fix: notes 0..11 on the auto channel are pad triggers (no
  binding, no Sidecar note, no step entry), and a selection change unbinds a channel bound to another voice. CHRO on a
  seq track still plays its poly voice (the binding), CHRO on another track its own chromatic.
- TRK + pad under the page: the page's catch mask takes TRK (the host's alone), so stock saw the pad without TRK; in
  GRID REC + CHRO that is a chromatic note and no selection [measured, rui1039: `sq_emu.py trkpad` tp_grid selected stays
  BD; padsel: TRK + SD in CHRO under the page leaves seq mode on]. Fix (this mod): a pad pressed while a caught TRK is
  held first gives stock the TRK press - stock's key handler 0x400a02ca (the ev_key site 0x400a47cc's call, (brain, ev)
  [code]) with a copy of the pad's event as TRK down - then the pad; TRK's release then goes to stock too. TRK + YES /
  TRK + TRIG / TRK + LFO are unchanged (no pad). [measured, rui1040: trkpad SD selected in both contexts, TRK still 31
  to the host; padsel all checks]. Limit: the selecting pad's own CHRO note can reach the old binding once before the
  selection report (49 02, the next UI tick) arrives: one note on the old voice at the gesture [measured: 1 note].

Tests [measured, DTEMU_STRICT=1]: `sq_emu.py rui1040 seqpage trigkey trkpad` (rui1039 fails seqpage, trigkey and trkpad
tp_grid), `bk_emu.py rui1040 browse`,
the 14 suites, `bk_emu.py all`, `rled_emu.py stockup`; rytm-teensy `make -C core test`, `sim/seq_e2e.py` (all runs, new:
stepedit trigview cond padsel) and `sim/rui_e2e.py srclist srcbrowse` with the real core.

**Build rui1040** (rui1039's mods and parameters): `build/b.sh rui1040`; verify PASS.

## 1041: TRK + FX opens the INSERT page; the SRC view in every pad mode; stock's TRK LEVEL readout over the page (emulator only)

Tags as above; [measured] = rytm-emu seq-p2 (50a0139), rui1040 / rui1041, 2026-10-21, DTEMU_STRICT=1. No hardware. Host
half: rytm-teensy `fix1041` (the INSERT page's `30 02` was already there: core/ui/remote.cpp `kPageIns`; docs/INSERT-FX.md).

**1. TRK + FX opens the page on the Sidecar's INSERT page**, exactly as TRK + LFO opens its LFO page:

    TRK held (whoever got its press) + FX (0x10): 30 01 02 01 00      page 2: INSERT

With the page open TRK + FX sends `30 01 02 01 00` again (the host goes there; the page stays). FX's press and release
reach neither stock (its FX page would open under ours) nor the host. The block sits before seq mode's held-trig keys,
so a held trig + FX without TRK stays the host's FX lock key (INS locks, 1036), unchanged; TRK + FX with a trig held
opens the INSERT page. An old host opens its SIDECAR page (it ignores the page byte).
- **Stock 1.73 binds nothing to TRK + FX [measured, `rled_emu.py stocktrkfx`, the stock image (rled_stock)].** The
  same state list as stocktrktrig (screen, every LED slot and selector, the working pattern's 12 tracks, the sequencer
  state, the selected track, the kit words). On the main screen and in GRID REC (T1 / T5 placed; seq mode is a Sidecar
  seq track in GRID REC, so this is its stock context) TRK + FX = FX alone (the FX page, the FX track selected) plus
  TRK's own LED 55. On the FX page (also in GRID REC) TRK alone and FX alone each leave it (the FX track deselected),
  and TRK held + FX leaves exactly what TRK tapped, released, then FX leaves: each key's own action in turn, nothing of
  the combo's own. What 0026 takes there: FX's second press (the FX page again) is the INSERT page's instead.
- Tests [measured, `sq_emu.py rui1041 trkfx`]: 30 2 1 0, again 30 2 1 0, TRK + YES 30 0 0 3; no 31 FX, the screen after
  leaving = TRK + YES in and out; with the TRK + YES page open: 30 0 1 0, 30 2 1 0, 30 0 0 3; seq mode (BD a seq track,
  GRID REC): TRK + FX -> 30 2 1 0; T1 held + FX: 31 0x10 down / up, no 30.

**2. The SRC view in MUTE, CHRO, SCENE and PERF pad mode** (hardware report on rui1040: seconds late in MUTE / CHRO /
SCENE, never in PERF). Cause [measured, 2B in rytm-emu]: each pad mode other than PLAY stacks its own view on top of
SamplerLedView while the mode lasts - QuickMuteMenuView 0x401e290c, ChromPadsView 0x401e10e4, SceneSelectView 0x401e2dac,
PerformanceView 0x401e2414 (class names by typeinfo in the stock image) - 10 views instead of 9. 1027d takes an
unlisted view on top as a cover for its first 3 s (MUTE / CHRO / SCENE: the 2B went 0x3 covered, 0x7, and only after
3 s 0x45), and PerformanceView was in the cover list (1027's "PERF", then taken for a screen): covered for good. These
views draw nothing over the SRC page: the stock SRC screen in each pad mode equals the PLAY mode's, 0.2 / 0.6 / 1.7 s
after the mode key and with a pad held [measured]. Fix: they are skipped in the view walk (as if not stacked), and
PerformanceView left the cover list; a real cover above them (TRK held: TrackSelectionView) still covers.
Tests [measured, `sv_emu.py rui1041 padmode`]: in each of PLAY MUTE CHRO SCNE PERF, FLTR then SRC: the host's frame on
the glass 0.6 s after SRC, the last 2B 0x45 with SamplerLedView on top, the stock SRC page (no host) the PLAY mode's;
PERF + TRK held: covered. rui1041 before the fix failed all four modes (the 2B on the mode's view, covered).

**3. Stock's TRK LEVEL readout over the page** (the user: turning LEVEL with the page open changes the level, but
stock's notification is hidden). What stock does [measured, the stock image, main screen, LEVEL 3 x +3]: the header's
left field (glass rows 0..8, columns 0..69; the separator at 70, `BPM:127.0` and the transport icon to its right
unchanged) shows `TRK LEVEL 100` instead of the kit name (`K001:RYTMLINJE`), from the turn until ~2.4 s after the last
one (still shown 2.36 s after, gone 2.56 s after). The LEVEL / DATA encoder is index 8; every host page with knobs passes
it to stock (core/ui/remote.cpp send_mask), the status pages catch it.
Choice: (a), stock draws it. Stock keeps drawing its whole screen under the page on every draw (drawAll runs before
ev_draw's copy of the host's frame, as the SCALE aside relies on), so while the readout lasts 0026 keeps that field of
the canvas stock's: the 70 x 9 pixels saved before the page's copy and put back after it (the page's own row 8 bits
outside the field kept). The trigger is a LEVEL turn passed to stock with the page open or the SRC view shown; the
window is 47 ticks (2.35 s, inside stock's own time, so the field never shows stock's plain kit name), the page redrawn
each tick while it lasts and once at its end. (b) (a new report and the host drawing the same words) would need a new
message and a copy of stock's wording and font on the host, and could drift from stock; (a) is the stock readout
itself, for no host change.
- Tests [measured]: `rled_emu.py rui1041 levelhdr` (the page open, nothing committed: a blank page; the host's mask as
  for a page with knobs; LEVEL 3 x +3: 0.3 s later the field equals the run without the page bit for bit, the rest of
  the glass blank; 3 s later blank again), `sv_emu.py rui1041 level` (the SRC view shown: the field stock's, the rest
  the host's frame; 3 s later the whole frame).
- Other stock readouts: not handled - TEMPO (and its SWING) is TempoMenuView, a whole popup window, not the header:
  the host's mask does not catch TEMPO (core/ui/remote.cpp kCatchKeys), so with the page open it opens under the page,
  hidden, and its knobs are the host's [inferred from the mask; not run] - a candidate for the SCALE aside (1038) keyed
  on TempoMenuView on top, not built; under the SRC view it already covers (1027d). The pattern / kit name and the queued
  pattern are the header's normal content and the bottom bar (the host draws its own header); the master volume is an
  analog knob (no readout). Not measured: other encoder readouts in that field (knobs A..H are the host's on its
  pages).

**Build rui1041** (rui1040's mods and parameters): `build/b.sh rui1041`; verify PASS.

## 1042: stock overlays step the page aside; RELOAD / SAVE PATTERN and TRACK reported; pattern jumps (emulator only)

Tags as above; [measured] = rytm-emu seq-p2 (50a0139), rui1042, 2026-10-21, DTEMU_STRICT=1. No hardware. Host half:
rytm-teensy `fix1042` (docs/SEQUENCER.md "fix1042").

**1. Stock overlays hidden under the page.** The host's real catch mask (core/ui/remote.cpp kCatchKeys + a page with
knobs A..H) leaves TEMPO, FIX, RTRG, MUTE / PERF / SCNE / CHRO, the BANKs, FILL, the trig keys, RECORD / PLAY / STOP, FUNC
and the LEVEL push to stock. The probe (`bk_emu.py popups`, each gesture with the page open and on a Rytm whose page
never opened; the top view by sv's walk and its class by typeinfo):

| gesture | stock overlay (class, vtable) | rui1041 with the page open | rui1042 |
|---|---|---|---|
| TEMPO | tempo menu (TempoMenuView 401d55dc) | hidden, its UP / DOWN (the BPM) the host's | stock's on the glass, every key stock's |
| FUNC + TEMPO (held) | TAP TEMPO (TapTempoView 401d54c0) | hidden | shown |
| FUNC + BANK | PTN: mode toast (PopupWindow 401d6e18) | hidden | shown |
| FUNC + REC / PLAY | COPY / CLEAR PATTERN toast (PopupWindow) | hidden | shown, the page back when it goes |
| FUNC + FIX | FIXED VELOCITY (FixSetupMenuView 40234b90) | hidden | shown |
| FUNC + RTRG | CLICK menu (MetronomeMenuView 401cd758) | hidden, its keys the host's | shown |
| FUNC + MUTE | SOUND menu (SoundMenuView 401e8df8) | hidden | shown |
| FUNC + PERF | SONG menu (SongMenuView 401d2694); SAVE: the name prompt (NameView 401d6af4) | hidden | shown |
| FUNC + SCNE | PATTERN menu: RELOAD / SAVE PATTERN (PatternMenuView 401e6294), their toasts | hidden | shown; DOWN / NO stock's, NO: the page back |
| FUNC + CHRO | TRACK menu: RELOAD / SAVE TRACK (TrackMenuView 401ec0fc) | hidden | shown |
| FUNC + LEVEL push | the sound browser (SoundBrowser 401d2904) | hidden | shown |
| FUNC + PAGE | SCALE (ScaleMenuView) | shown (1038) | unchanged |
| FUNC + GLOBAL / SONG / CHAIN / PLAY MODE / SAMPLER / QPER / YES / NO / SRC / FX | (their key is in the mask: the host's) | not stock's | unchanged |
| BANK held, FIX, RTRG, FUNC + FILL / T1 / pad, LEVEL push | nothing stacked | - | - |

(SWING: SwingMenuView exists in the image; no gesture opened it in rytm-emu, FUNC + TEMPO is tap tempo [measured]. It is
covered by the rule below like any menu.)

Fix: `overlay(vt)` classifies the top view by its class name (vtable - 4 = typeinfo, typeinfo + 4 = the name; MAIN OS
keeps RTTI [code]): a name ending in MenuView (not QuickMuteMenuView, MUTE's pad-mode view, 1041) or Window, or one of
the browsers / managers / NameView / TapTempoView; the answer for the last vtable is kept. At the UI tick, when such a
view becomes the top while the page is open, the page steps aside exactly as 1038's SCALE menu (st.aside: stock draws,
every key and knob stock's) until no overlay is on top; an overlay already on top when the page opened does not count.
The SRC view's cover test takes any overlay too (FixSetupMenuView / TapTempoView were 1027d's 3 s unknowns). [measured,
`bk_emu.py popups`: for the 13 gestures the top view and the screen equal the run without the page byte for byte, no key
to the host; TEMPO + UP x 2 sets 15264 as stock (knobs A..H and LEVEL do not move the BPM in the tempo menu); NO: the
host's frame and the page still open; the PATTERN menu's DOWN / NO stock's; the COPY toast goes by itself, frame back.
rui1041 fails 13 screens, the BPM and the PATTERN menu's keys.]

**2. CHRO leftover (TRK + pad selecting another track played one note on the old seq voice).** Measured [rytm-emu
rui1041 + the real core, `seq_e2e.py padsel`]: with the page open TRK is the page's; stock sends the pad's note on the
auto channel (in CHRO the old track's chromatic note) before 1040's injected TRK press can make it a selection - the
note left before 0026's key hook ran (USB order: note-on, then 49 02, even with the 49 02 sent from the key hook first:
tried and reverted). With the page closed stock has TRK and sends no note for TRK + pad [measured: no note-on]. Fixed on
the host (rytm-teensy fix1042 core/poly.cpp): the page's TRK 31 marks TRK held; a note on the auto channel while it is
held is the selection's (no voice, no binding, no step entry), its note-off too; cleared at TRK's release, the page's
close or after 10 s. No Rytm change.

**3. RELOAD / SAVE PATTERN and RELOAD / SAVE TRACK (2D 0A ops 16..19).** Four more edit wrappers as 1033's (registry
detours, 8 B displaced: `lea; movem`, nothing pc-relative): 16 RELOAD PAT 0x400af5e0, 17 SAVE PAT 0x400ae588, 18 RELOAD
TRK 0x400af64a, 19 SAVE TRK 0x400ae614 [measured, rytm-emu: each ran once for its menu item, `--count`]. Pattern ops
carry track 7F, track ops the selected track; ok is the function's d0 (no success flag). [measured, `sq_emu.py
savereload`: 16 0 7F, 17 0 7F, 18 0 0, 19 0 0, src 0] The host keeps the saved state per pattern (fix1042).

**4. Pattern jumps.** FUNC + BANK_A..D = SEQUENTIAL / DIRECT START / DIRECT JUMP / TEMP JUMP [measured]. trig_fire is
called at once at the jump with the new pattern: DIRECT START with the starting-step byte 0xff (rui1041 reported a tick
of step 127), DIRECT / TEMP JUMP with the same starting step as the call before (a re-schedule: rui1041 reported that
step twice), and the new pattern's steps begin at the next boundary at the old position. 1032's 03 waited for the new
pattern's step 0: DIRECT JUMP 2 s late, TEMP JUMP never (back to the old pattern first). Now (sq_fire): a call with the
same starting step from another pattern is a re-schedule (no tick) and marks a jump; the 03 goes at the next call with a
new step (step 0 as before for the others); no tick for a 0xff step. [measured, `sq_emu.py jump`: each mode one 03 0 -> 1
at the block of A02's first step (0, 0, 8, 9: the step after the old one's last), before that block's 2C, no step 127, no
step twice; `switch ticks` unchanged] The host's step clock now restarts at the tick's step (fix1042).

**5. FILL** [measured, `sq_emu.py fill`]: FILL held while playing -> 2D 0C 1, released -> 0C 0, the page closed or open
(FILL is in no mask). A latched FILL is still not followed.

Tests [measured, DTEMU_STRICT=1]: `bk_emu.py rui1042 popups`, `sq_emu.py rui1042 savereload jump fill`, the 14 suites,
`bk_emu.py all`; rytm-teensy: `make -C core test`, `sim/seq_e2e.py` (all runs, padsel's new check) and `sim/rui_e2e.py`.

**Build rui1042** (rui1041's mods and parameters): `build/b.sh rui1042`; verify PASS.

## 1043: bank A's text like B..H's; WAVETABLE's default TBL 1 (emulator only)

Tags as above; [measured] = rytm-emu seq-p2 (50a0139), rui1043, 2026-10-22, DTEMU_STRICT=1. No hardware. Host half: the
pools redesign (rytm-teensy song-mvp docs/superpowers/specs/2026-10-22-pools-tonverk-design.md, 3.5 and open questions
2 and 5: the host sends bank A's names in the 47 form with bank byte 0, total 127, every row named, and its wavetable
list template has BASIC on A001). The wire is unchanged (47 / 4A / 48, the 14-bit word).

**1. cu_text: bank A like B..H** (GRANULAR SRC, WAVETABLE TBL, MULTISAMPLE INST alike). Before (1036 / 1038): bank A
showed name min(v, total - 1) of the held bank-A list, else GRANULAR's built-in IN MAIN BD .. BELLS for 0..11, else the
number; so after a cold boot, until the host's first 47, GRANULAR's rows 0..11 read IN, MAIN, ... and WAVETABLE /
MULTISAMPLE a bare number. Now one rule for every bank: index 0 `OFF`; the host's name when the list holds that bank's
names (`ux.nm_bank[l] == bank`) and the row has one; else the bank letter and three digits (`A005`). For bank A both 47
forms fill the list as before (with bank byte 0, or the old form without one: nm_bank 0); the 47 handler is unchanged.
GRANULAR's built-in texts (cu_srcn) are gone. `total` is still stored but no longer read by cu_text.
- What older hosts see [inferred from the code, not run against an old host]: an old bank-A list is shown row by row
  (no clamp: a row past the names reads `A0nn`), and its row 0 reads OFF instead of the old entry 0's name.
- [measured, `bk_emu.py banka`, each of GR / WT / MS: a screen equals the run where the host names that row with the
  expected text]: no 47, index 5 = `A005`, index 0 = `OFF`; a 47 with bank byte 0 (total 127) naming rows 0..7: row 5's
  name shown (differs from `A005`) and equal to the old form's (no bank byte, same rows); an unnamed row 9 = `A009`.
  The same checks on rui1042's code fail 9 of 15 (GR 5 read BT, WT / MS a number, index 0 IN / 0, row 9 clamped):
  that run was the first rui1043 build before stub.s was regenerated, byte-identical to rui1042's .syx (sha256 f46693ce..).
- `sv_emu.py names` (1036) relied on the clamp (4 names, row 11 read row 3's name): its names now sit on rows 8..11
  (total 12), the check unchanged otherwise.

**2. WAVETABLE's default TBL 1** (A001; was 0). The P1 default lives only in 0026's knob table (`cu_wtk[0].def`, written
into the shared record's default +0x10 by cu_knob; set_machine writes the records' defaults through cu_prep, 1034).
0021 holds no default of its own for these machines [code]. GRANULAR SRC 10 and MULTISAMPLE INST 0 stay.
- [measured, `bk_emu.py tbldef`]: BD to WAVETABLE from the machine list: P1 word 0x0100, record default 0x100; the text
  `A001` (equal to the host naming row 1 A001, differs from index 0's OFF); with bank A's names (row 1 BASIC) the name,
  the word still 0x0100. GRANULAR 0x0a00, MULTISAMPLE 0. rui1042: 0. `cu_emu.py` (wt, swap GR -> WT -> MS): WT_DEFAULTS
  now 1 0 0 0 0 0 64 0, passing.
- Kits and projects saved before keep their stored TBL (only a machine choice writes the default).

Tests [measured, DTEMU_STRICT=1, sequential]: the 14 suites (cu frz fxin mrep pc rled rui sfu sfx sp sq sv td us) PASS,
fxin after one rerun (its `gone` check missed the first 27 00 once, `[1, 0]` for `[0, 1, 0]`; alone it passed, nothing
of it touched here [inferred: timing]); `bk_emu.py all` (new banka tbldef) 224 checks; `rled_emu.py stockup` PASS.

**Build rui1043** (rui1042's mods and parameters): `build/b.sh rui1043`; verify PASS.

## 1044: TRK's LED blinks while the page has the keys; UP held alone asks the host for its combo map (emulator only)

Tags as above; [measured] = rytm-emu seq-p2, rui1044, 2026-10-22, DTEMU_STRICT=1. No hardware. Host half: rytm-teensy
`ux` (docs/UX-REVIEW-2026-10-22.md R5 and N3: the KEYS page on the Rytm's screen and T1..T10 lit while UP is held).

**1. TRK's LED (panel LED 55) while the page has the keys** (R5). The review's finding: with the Sidecar page open the
pads, trigs and knobs are the host's, and nothing on the panel says so outside the screen. Pad mode is not used for
this: the pad LEDs are stock's (and the host's in its own pages) and a pad-mode change would be a stock state change.
TRK is the key that opens the page (TRK + YES) and closes it, so its LED is where the mode is shown.
- Shadowed like the trig / PAGE LEDs (1032): stock's last four slot colours of LED 55 are kept from the UART8 stream
  (`sht`); while the page is open and not stepped aside (1042) every slot is white (0x6f) / off at 1 Hz (`trk_tick`,
  sent under a try-lock of the LED mutex, `ovt_on` / `ovt_col` rewrite stock's sends meanwhile); at the close or
  aside stock's slots are sent back once.
- TRK_LED 55 is [measured in rytm-emu: panel.rs RYTM_LEDS, a mode key lights its own on 1.73]; that this is the
  physical TRK key's LED on a Rytm is [inferred]: check on hardware.
- [measured, `rled_emu.py trkled`]: page open: all four slots one colour, white or off; at least 3 paints in 1.3 s;
  after TRK + YES out the slots equal the run without the page; one restore; no other key LED differs (T1..T16 aside).

**2. UP held alone on the stock screen: 49 1 4 1, its release 49 1 4 0** (N3: the combos are not discoverable). The
host answers with its KEYS page (the cheat sheet) and T1..T10 lit in their pages' colours, and closes it at the
release. UP stays stock's: the key still goes to stock (its cursor in stock's menus), the map is asked only when UP is
held UP_MAP_TICKS (8, 400 ms) with the page closed, no trig pressed with it and no stock menu up (overlay()). UP + Tn
is a page request as before, without the map; a trig pressed while the map shows does both.
- [measured, `rled_emu.py upmap`]: UP held 0.6 s: 49 1 4 1 then 49 1 4 0 (map_on 1, map_off 1); UP tapped: none;
  UP + T3: the page request 3, no map; the screen after UP held equals UP tapped (nothing drawn by the mod itself).
- An older host ignores 49 1 4 [code: song-mvp's 49 handler has no sub-id 4 and drops it].

Tests [measured, DTEMU_STRICT=1, sequential]: the 14 suites (cu frz fxin mrep pc rled rui sfu sfx sp sq sv td us)
PASS; `bk_emu.py all` PASS after `browse`'s last YES moved from 2400 to 2600 ms (rui1044's guest timing put that YES
37 ms after the host's 4A 0 0, before the mod had read it; 1043: 61 ms; nothing of the list code changed [inferred: timing]); `rled_emu.py trkled upmap` PASS; rytm-teensy `sim/seq_e2e.py`, `sim/rui_e2e.py` and
`sim/rui_e2e.py pools` with SEQ_TAG / RUI_TAG=rui1044 against the `ux` host.

Open: (a) TRK_LED on hardware; (b) the PAGE LEDs (1032) use panel LEDs 43..40 (rytm-emu `PAGE_LEDS`, the Digitakt /
Syntakt table) while rytm-emu's `RYTM_PAGE_LEDS` is 64..67 - which is right on a Rytm is to be checked on hardware.

**Build rui1044** (rui1043's mods and parameters): `build/b.sh rui1044`; verify PASS.

## 1045: DSP SAMPLE's SMP on the SAMPLES pool's eight banks (emulator only)

Tags as above; [measured] = rytm-emu seq-p2 (50a0139), rui1045, 2026-10-22, DTEMU_STRICT=1. No hardware. Host half:
rytm-teensy `dspbank` (docs/POOLS.md 7). The hardware report on rui1043: on a DSP SAMPLE track the POOL was not
reachable from the Rytm - turning knob A on its SRC page changed ENG (DSP SAMPLE's knob A is ENG, record 416, a 0029
stepped list: MODAL STRING RESON; the host's bottom bar then reads `BD ENG:nn` [measured, rytm-emu rui1043 + the real
core]; no "choosing" text exists in either repository or the stock image), and SMP (knob D of its SMPL page) was stock's
record 41: its turn opened stock's SAMPLE SLOT list (SampleListView) drawn from 0023's 14 table, bank A only (7 bits).

**The record.** SMP needs the fine flag and the range 0..0x7fe0 (1038's word) without touching stock's record 41 (every
stock machine's SMP). No record is free (334..460 are 0021's, 443 is the cu machines' P2), but DSP SAMPLE's word-17 TUN
record 441 is byte for byte stock's 39 in +0x00..+0x27 [measured, rytm-emu rui1043: records 39 and 441]. So TUN uses 39
and 441 becomes SMP: the registry patch gives it record 41's fields (index 19, its id / ordinal / CC words: SMP sends
NRPN 1:11 with the bank in the LSB, CC 27 with the index alone [measured, `bk_emu.py dspnrpn`]) with max 0x7fe0 and the
fine flag, record 41's names (Sample Slot / Sample / SMP); 0021 maps word 17 -> 39 and 19 -> 441 (us_param_record, the
.us1 claim widened to all of cave4, 2004 B; ext_param_record for slots=0), the SMPL page order 39 442 444 441 445..448,
441's look a dial. 0026 gives 441 cu_text (kind 12, list 0: the SAMPLES names, OFF / the name / C005) once 0021 has
given it the dial (cu_tick), and cu_steps answers CU_BANKED (0029 mode 3, all 128, keep the bank). Stock's 41 is
unchanged [measured: index 19, max 0x7f00, fine 0]; stock's SAMPLE SLOT list no longer opens on DSP SAMPLE, so 0023's
14-table hooks are idle there (left in place: the Rytm builds before this one still use them).

**The list from the SMPL page.** 1038's list is drawn by the host over the SRC view (sv.show). On DSP SAMPLE SMP is on
the SMPL page, where no view is on: sv_page now also finds SamplePageView (vtable 0x401e3170, its typeinfo
"14SamplePageView" [code]) and keeps it apart (sv.spage 1 the screen / 2 covered; never the view). ls_enc opens the list
on knob D when the selected track is a Sidecar DSP SAMPLE, sv.spage is 1, the page and the splash are closed and a host
is there that has drawn (PORT up, a message within the timeout, a commit since boot, and not refused since the last
hello): the turn is eaten, 4A 1 <t> 1 <P11 hi lo> 0 goes out (ls.p = 10: ls_queue reads P11), and ls_smpl makes sv_tick
turn the view on for that track over the SMPL page (29 1; sv.view 0: the 2A's values are the kit words), so the host's
list shows at its first frame. D's turns go to the host as 32 0 (the list's knob, whichever opened it); another knob
closes it (why 3); YES / NO / FUNC + YES as 1038 / 1040; the close ends the view (29 0). A host that draws nothing within
a second of the open (an older host, which ignores a 4A of a machine it has no list for) closes it (why 5) and SMP is the
stock knob until the next hello. The 48 that commits names P11 (48 1 <t> 10 <index> <bank << 4> 1); with trigs held
wr_tick locks P11 (ls_lock with the sound index 19: LOCK_TYPE(19), track_lock_set k 19, fine).

[measured, `bk_emu.py rui1045`]:
- `dspknob`: no host frame: 48 0 10 5 <C> -> 0x0540; SMP one detent up / down 0x0640 / 0x0440 (bank C kept), no
  SampleListView; record 441 index 19, 0x7fe0, fine 1; record 41 unchanged. On rui1043: 0x0640 / 0x0440 through stock's
  list (SampleListView on top), record 441 = TUN.
- `dsplist`: SMPL, D turned: 4A on (P11 5 . C = 672), 29 0 (SMPL) then 29 1 / 0 around the list, D's turns as 32 0,
  RIGHT as 31, YES why 1, the host's 48 0 10 9 <B> 1 -> 0x0920; NO why 2 (0x0540 kept); knob A why 3; knob A on the SRC
  view edits ENG, no list. On rui1043: no 4A.
- `dspbrowse`: FUNC + YES -> 4A on 3, the host's browser keys, YES after 4A 0 0 closes (why 1).
- `dsplistlock`: T1 + T3 held at the YES: 48 .. 10 9 <C> 1 answered 4, steps 1 and 3 locked 0x0940, step 2 none,
  the word 0x0540.
- `dsplock`: GRID REC, T1 held, SMP turned (no host frame): the live lock 0x0740 (bank C), the track's fine flag for k 19
  set, stored SMP's slot (07) then the fine slot (80 80, 0x20); power off, cold boot on that card: 0x0740 again.
- `dspold`: rui1043 (SMP stock's 41) sets SMP 5 (0x0500), powered off on a card; rui1045 cold-booted on it reads
  0x0500 (A005: bank A).
- `dsptext`: SMP's text: 5 . C with no names = C005, bank C's names name it, 0 = OFF, 0x0500 = A005.
- `dspoldhost`: a host that has drawn but sends no frame for the list: 4A on, 4A off why 5 a second later, then SMP
  steps as the stock knob (0x0640).
- `dspnrpn`: NRPN 1:11 = 6 / 0x20, CC 27 = 6.
End to end with the real core (rytm-teensy `sim/rui_e2e.py dspbank`, RUI_TAG_1043=rui1045): the list on bank C, FUNC +
YES into C020, the commit (48 0 10 20 0x20 1), the word 0x1440, the view's DSP SAMPLE page draws C020's waveform and the
BD pad plays it; FUNC + YES opens the core's browser on row 20 of every bank A..H.

Tests [measured, DTEMU_STRICT=1, sequential, rui1045]: the 14 suites (cu frz fxin mrep pc rled rui sfu sfx sp sq sv td
us), `bk_emu.py all` (with dspknob dsplist dspbrowse dsptext dsplock dspold dsplistlock dspoldhost dspnrpn) and
`rled_emu.py stockup` PASS. (On the rui1043b trial build `rui` failed 5 checks of the TRK + YES page once while the core
tests ran beside it; on rui1045, run alone, it passes: nothing of it touched here [inferred: load].)

**Build rui1045** (rui1044's mods and parameters): `build/b.sh rui1045`; verify PASS. Package: build/sidecar-1045.

## 1046: UP + T11..T13; UP the one Sidecar modifier (emulator only)

Tags as above; [measured] = rytm-emu seq-p2 (50a0139), rui1046, 2026-10-22, DTEMU_STRICT=1. No hardware. Host half:
rytm-teensy `upt` (the device's shortcut table `core/ui/page_keys.h`, docs/UI-THEMES.md "The device's shortcuts").

**UP + T11..T13.** `code <= 9` became `code <= 12`: 49 1 1 11..13 (the host's table: 11 SONG, 12 PROJECT, 13 POOL; the
Pi's touchscreen pages when it has them, else the Rytm screen's). Stock 1.73 first [measured, `rled_emu.py stockup`, the
stock image, T6..T13]: on the main screen, in GRID REC, on FLTR, in CHRO and in MUTE mode UP held + Tn leaves what Tn
alone leaves plus what UP alone leaves; with a menu open (GLOBAL) UP held + Tn leaves exactly what UP tapped and
released, then Tn, leave (UP moves the list's cursor, Tn then acts as alone: each key's own action, nothing of the
combo's own), for T6..T10 as for T11..T13. The trigs are eaten as before [measured, `bk_emu.py upt`: 49 1 1 6..13, BD's
track as without the trig presses, no 31; `sq_emu.py upseq`: in seq mode with T1 held, UP + T11 / T12 / T13 -> 49 1
11, 12, 13, only T1 to the host].

**UP the one modifier (the user's request: TRK is stock's busiest key, UP held alone shows the map).** Stock 1.73 first
[measured, `rled_emu.py stockupkeys`, the stock image]: UP held + each of TRIG SRC SMPL FLTR AMP LFO FX YES NO RECORD
PLAY STOP PAGE, the 12 pads and T14..T16, on the main screen, in GRID REC, in GRID REC with T1 held and with GLOBAL's
menu open. FREE = the key alone + what UP alone leaves; SEQ = what UP tapped, then the key, leave (in a list):

| key | main | GRID REC | GRID REC, T1 held | menu |
|---|---|---|---|---|
| TRIG SMPL FLTR AMP LFO FX YES, pads SD..CB | FREE | FREE | FREE | SEQ |
| SRC NO STOP PAGE BD T14 T15 T16 | FREE | FREE | FREE | FREE |
| RECORD PLAY | FREE | FREE | **a combo of stock's own** | SEQ |

The one clash: with a trig held in GRID REC, stock's trig + RECORD shows COPY TRIG and trig + PLAY CLEAR LOCKS (their
popups); with UP held as well neither popup comes (nothing else tracked differs: the pattern, the sequencer, the LEDs).
So on a normal track rui1046 leaves UP + RECORD / PLAY to stock exactly as it was [measured, `rled_emu.py upstock`: the
deltas of UP + SMPL / FLTR / AMP / NO / PAGE / SD / T14 (main, GRID REC) and T1 + UP + SRC / RECORD / PLAY / STOP (GRID
REC) on rui1046 equal stock's]. **Held trig + UP / DOWN** (the user's caution: stock may use it) [measured, `rled_emu.py
stocktrigup`, GRID REC, T1 held, the arrow tapped, on the main screen and on TRIG SRC SMPL FLTR AMP LFO]: while the trig
is held stock opens a popup over the page (a framed box with the trig's values - its text reads like the retrig
settings, a RATE 1/16 among them [inferred from the screen]); UP, DOWN and RIGHT (the control) leave the same popup; a
single tap changes nothing in the pattern, the sequencer or the LEDs, and after the trig's release the screen is as
without the arrow. So stock does use held trig + arrow (its popup, edits from there [inferred]): rui1046 never takes UP
under a stock trig. On a poly track the trig is the host's (stock never saw it, so its popup never comes): there UP is
taken at once, no chord wait needed (the user's decision, 2026-10-22).

What rui1046 binds (rui.c `u46`, `UPH()` = UP held by stock, the page or taken on a poly track):
- **UP + TRIG / LFO / FX / YES** = TRK + TRIG / LFO / FX / YES, which stay (legacy). UP + YES needs UP held 3 ticks
  (100..150 ms) first: in a menu UP then YES pressed a little early stays stock's (u46.yes_early counts those). With UP's
  map on the glass (the host's KEYS page, opened by UP held) UP + YES asks the SIDECAR page (30 0 1 0 again) instead of
  leaving, so the map's release leaves it open. YES on the page UP + TRIG / LFO / FX opened while UP is still held is
  the page's (up_used, as tk.used). A combo marks k44.up_trig: no map for that hold.
- **UP + SRC** (the page closed, no trig held - seq mode's or stock's, whose SRC is the lock page): the selected track's
  source list in one press. SRC goes to stock (the SRC page, the 1027 view); on GRANULAR / WAVETABLE / MULTISAMPLE
  u46_tick opens the bank list on knob A once the view shows the host's frame (within a second), as knob A's first turn
  would (ls_enc); on DSP SAMPLE stock gets SMPL instead (a press and release through STOCK_KEY) and the list opens on
  knob D (1045's path). Any other track: SRC alone. Why SRC: SRC alone already shows the view; the one thing a single
  press can add is the list (the POOL bank), which otherwise needs a turn.
- **Poly track, a trig held: UP + RECORD / STOP / PLAY** = the steps' copy / paste / clear (2D 0A 13 / 14 / 15, src 1,
  the held mask), as trig + FUNC + REC / STOP / PLAY (kept). On a poly track (seq mode) with a trig held (sq.down, or
  the page's) UP is taken at its press (u46.seq; no chord wait): the user's call - stock never saw that trig (it is
  the host's), so stock's held trig + arrow has nothing to act on there. Order: the trig first, then UP (UP first, then
  a trig, is UP + Tn). Without a held trig UP + RECORD / STOP / PLAY is stock's transport, nothing new. On a normal
  track nothing here applies.
- Not bound (free on stock, kept for later): SMPL, FLTR, AMP, NO, PAGE, the pads, T14..T16.

[measured, `sq_emu.py upcombo`]: UP + TRIG -> 30 0x10 1 0, again 30 0 0 3, TRIG to neither side (the screen after =
no gesture), UP held 0.5 s with a combo asks no map; UP + LFO 30 1 1 0; UP + FX 30 2 1 0; UP + YES (UP 200 ms first)
30 0 1 0 / 30 0 0 3, YES never sent; YES 25 ms after UP: no 30 (yes_early 1); UP + TRIG, then YES with UP held: 31 YES
down / up, no close. With the page open UP's press reaches the page (31 UP) before the combo, as for UP + Tn.
[measured, `sq_emu.py upseq`]: T1 + T3 held, UP + REC -> 0A 13 src 1 mask 5; T2 + UP + STOP 14; T2 + UP + PLAY 15; no
31 of UP / REC / STOP / PLAY, BD's track as in the base, no map; seq mode without a trig, UP + PLAY -> 2D 01 1 (stock
played), no 0A.
[measured, `bk_emu.py upsrc`]: GRANULAR (the host draws), from FLTR: UP + SRC -> 4A on (P1 = 5 . F, why 0), the word
unmoved, knob A's turns then 32 0; no drawing host: no list; DSP SAMPLE: UP + SRC -> 29 1 (the view over the SMPL page)
and 4A on with P11 = 5 . C; T1 held in GRID REC (a stock track): no list.

**Cost.** Per key press a few bit tests; u46_tick one compare a tick while waiting (a second at most). Memory: u46 48 B.

Tests [measured, DTEMU_STRICT=1, sequential, rui1046]: the 14 suites (cu frz fxin mrep pc rled rui sfu sfx sp sq sv td
us), `bk_emu.py all` (with upsrc), `rled_emu.py stockup stockupkeys stocktrigup upstock`, `sq_emu.py upcombo upseq`
PASS (stockupkeys reports its one clash, above). End to end with the real core (rytm-teensy `upt`, RUI_TAG =
RUI_TAG_1043 = SEQ_TAG = rui1046): `sim/seq_e2e.py` and `sim/rui_e2e.py pools latehello` PASS; the default
`sim/rui_e2e.py` run fails the same 36 checks with the host's base (song-mvp 0368224) as with `upt` (plaits keys scope
wave rec play gfx extmach lfo: older page orders), none new [measured: a second run of extmach machines srcwave on
`upt` = the base's].

**Build rui1046** (rui1045's mods and parameters): `build/b.sh rui1046`; verify PASS.


## 1047: UP + AMP opens the INSERT page on its OUT view (emulator only)

Tags as above; [measured] = rytm-emu seq-p2 (50a0139), rui1047, 2026-10-22, DTEMU_STRICT=1. No hardware. Host half:
rytm-teensy `upamp` (core/ui/remote.cpp `kPageInsOut`, page_ins.cpp `ins_open_out`, the device's table
`core/ui/page_keys.h`, docs/STEREO.md "Where to set it", docs/UI-THEMES.md "The device's shortcuts").

**What.** The user's request: UP + AMP opens the stereo / POST OUT view (OUT TRK / PRE / POST, LEV, PAN, WID, DEC; the
INSERT page's third view, otherwise YES twice away) of the selected track. Stock 1.73 first: UP held + AMP is FREE on the
main screen, in GRID REC and in GRID REC with a trig held (AMP alone + what UP alone leaves), and SEQ in a menu (UP tapped,
then AMP) [measured, `rled_emu.py stockupkeys`, the stock image, UPKEYS=AMP: main FREE, grid FREE, gridtrig FREE, menu SEQ;
all four contexts leave it free, as design 1046 had it]. A trig held in GRID REC + AMP is stock's lock page, so the new
combo is not taken under a held trig (the host's in seq mode, stock's otherwise), as UP + SRC.

**Message.** The form of UP + FX: `30 1 <page> <on> <reason>` with the page byte 3 (INSERT page on its OUT view; UP + LFO
1, UP + FX 2, TRK + TRIG 0x10 + t). No extra sub-view byte: the 30 stays 10 bytes. An older host reads the unknown
page byte as 0 (its SIDECAR page): UP + AMP then still opens the remote page, on SIDECAR, instead of doing nothing. With
the page already open UP + AMP sends the 30 again (the host goes to the OUT view), never a leave (as UP + FX). rui.c:
`PG_INSOUT 3`, `K_AMP 0x34`, the block after UP + FX's, `u46.amp` counts it; AMP press and release reach neither stock
(its AMP page would open under ours) nor the host (no 31 0x34). UP only: TRK + AMP stays stock's (`rled_emu.py upamp`:
AMP alone, TRK + AMP, UP tapped then AMP and T1 + AMP change on rui1047 what they change on stock, main screen and GRID REC).
UP + AMP is a combo as UP + FX: no map for that hold (k44.up_trig), YES on the page it opened while UP is still held is
the page's (up_used), the INSERT page's own opens counters (ins_opens / ins_hints) count it.

[measured, `sq_emu.py upcombo`]: UP + AMP -> 30 3 1 0 and nothing else, AMP not sent, no map asked, u46.amp 1; UP + AMP
twice (page open the second time) -> 30 3 1 0 twice, no 30 off; UP + LFO then UP + AMP with the page open -> 30 1 1 0, 30 3 1
0; T1 held (a trig, the page closed) + UP + AMP: no 30 3.

**Cost.** One compare per key press when AMP is pressed; u46 gained a word (52 B).

Tests [measured, DTEMU_STRICT=1, sequential, rui1047]: the 14 suites (cu frz fxin mrep pc rled rui sfu sfx sp sq sv td us)
PASS (rled with its 1046 list plus `stockup stockupkeys stocktrigup upstock upamp`: stockupkeys reports 1046's one clash,
gridtrig + RECORD / PLAY, and AMP FREE in main / GRID REC / trig held, SEQ in a menu), `bk_emu.py all` PASS (306 checks,
with the rui1043 base for dspold), `sq_emu.py upcombo upseq` PASS. End to end with the real core (rytm-teensy `upamp`,
RUI_TAG = RUI_TAG_1043 = SEQ_TAG = rui1047): `sim/rui_e2e.py pools latehello upamp` PASS (upamp: 30 page 3, the core's frame is
INSERT OUT with A OUT / B LEV / C PAN, the panel equals the frame) and `sim/seq_e2e.py` PASS.

**Build rui1047** (rui1046's mods and parameters): `build/b.sh rui1047`; verify PASS.


## 1048: POLY CONFIG in the track menu (FUNC + CHRO); E0's make prompt on every Sidecar machine (emulator only)

Tags as above; [measured] = rytm-emu seq-p2 (50a0139), rui1048, 2026-10-22, DTEMU_STRICT=1. No hardware. Host half:
rytm-teensy `polycfg` (core/ui/page_poly.cpp, docs/SEQUENCER.md "rui1048", docs/SEQ-IDEAS.md E0).

**The user's preferred place.** The per-track poly config (VOICES, ALLOCATION, UNISON, DETUNE, SPREAD, GROUP: the
Analog Four MKII's POLY CONFIG words, SEQ-IDEAS E0) belongs where a Rytm user looks for a track's settings: the stock
track menu, FUNC + CHRO. Research first [measured unless tagged]:
- The menu is TrackMenuView (vtable 0x401ec0fc; 1042's popups probe). On rui1048base (rui1047's sources) it lists
  TRIGS SETUP, PAD SCALE, RELOAD TRACK, SAVE TRACK, U1 .. U5 (0021's slot items, `slots=1`), opening on its first item;
  FUNC + DOWN moves five rows.
- How its list is built [code, re/symbols.toml 0x400f9b38 and 0012 / 0021's notes]: the constructor builds each item
  from four std::function objects (label, action, icon, empty) on its stack, a 0x54-byte MenuItem (menu_item_ctor
  0x40072f50) appended by 0x40072786 to a vector of shared_ptr<MenuItem> at the view's +4 (begin / end / capacity; the
  append also passes the item the list's size first, 0x40072caa: its index [inferred]). Items are built once, at boot. The label is an invoker called at
  draw time (0021's `U<n> <name>` changes without a rebuild).
- Two mods already append there: 0012's SLICE LOOP (a detour at the constructor's epilogue 0x400f9e96) and 0021's
  U1..U5 (0x400f9e9c, chained after 0012's: the two never name each other). A third detour in the epilogue would have
  to join that chain (0021's thunk returns itself, `rejoin = "none"`), and inserting in the middle of the vector would
  mean renumbering the items' indices: both rejected.
- The constructor has one caller [code: `jsr 0x400f9b38` only at 0x400cb5b8, the boot-time view setup], `this` in d6
  and pushed; after it `lea %sp@(24),%sp; tstl %d6` (6 B, nothing pc-relative) and a `beqs` on that test. [measured:
  `--break 400cb5be` on a cold boot of rui1048base is reached once, at ~1369 M, the new view (0x41bfad40) on the
  stack.]

**Built.** `pm_menu_det` (registry detour at 0x400cb5be, elek area) calls pm_menu_add(d6), re-emits the two
instructions and rejoins the `beqs` at 0x400cb5c4 (the flags from its own tstl; d0 / d1 / a0 / a1 are free there: the
constructor just returned). pm_menu_add builds one item exactly as stock (and 0021) do - SAVE TRACK's three
std::function managers (0x400f9a38 label, 0x400f9a8a action, 0x400f9ae6 icon: their captures match, nothing for the
label and icon, the menu for the action), our invokers (pm_label: `POLY CONFIG` into the std::string at a0 through
0x401bcd4c; pm_action: the functor's storage holds the menu; pm_icon: none), menu_item_ctor(item, label, action, icon,
empty, -1, 8), the append, the four functions destroyed. It is the last item, after U5: the stock items and 0012's /
0021's are untouched and nothing names another mod. A heap failure at boot (any of the four blocks null) adds no item.
YES on it (pm_pick, the UI task, as every menu action):
- a sound track selected (SEL_TRACK 0..11; else the popup SOUND TRACKS ONLY, the menu stays),
- a host there that has drawn - the USB port configured and a commit since the port's first hello (pm.c_hello: the
  commit count at that hello); else the popup NO SIDECAR (0021's words), the menu stays. The first build tested a host
  message within the 1 s timeout as ls_dsps does: against the real core (rui_e2e polycfg) that said NO SIDECAR, since an
  idle host sends nothing while the page is closed [measured]; fixed;
- then the menu closes (its vtable +128, as SAVE TRACK's action closes it) and pm.owed = track + 1; the next UI tick
  (pm_tick) opens the page on 30 page `PG_POLY + track` (0x20..0x2B, reason user), or, with the page already open and
  stepped aside under the menu (1042), sends the 30 again: the host goes to that page, and the aside ends when the menu
  has gone. A bank list open (1038) closes first (why 4).
The popup is SAVE TRACK's sequence (std::string, popup_ctor 0x400766e8, a shared_ptr with control block vtable
0x401ccab4, view_show_popup 0x400793f6 through the menu's +100), as 0021's us_popup.

**The message.** `30 1 <0x20 + t> 1 0`: one more page byte in the form 1036 began (0x10 + t the SEQ page of track t).
It names a device-neutral thing - "POLY CONFIG of track t" - the host's page (rytm-teensy `kPagePoly`), so the protocol
stays device-agnostic; the Rytm specifics (the track menu, FUNC + CHRO) are in the host's per-device table
(core/ui/page_keys.h row `poly`). The edits are the page's knobs (32) and keys (31) as on every Sidecar page; the host
applies them as its console's `seq=poly:T:...`. An older host reads an unknown page byte as 0: its SIDECAR page opens
(nothing breaks).

**The make prompt (UP + TRIG, 30 page 0x10 + t) on every Sidecar machine.** 0026 sends that 30 for any selected track
(1037); which tracks may become poly tracks is the host's (`can_seq`: since E0 only an analog machine is refused). So
no Rytm change was needed for it; the host's texts changed (the explain prompt now only for an analog track, its old
"mono machine" reasons gone, FREEZE's future place marked, `FUNC+CHRO: POLY CONFIG` on the make prompt).

Tests [measured, DTEMU_STRICT=1, sequential, rui1048 sha256 d0c9568b..; the machine shared with other builds]:
- `bk_emu.py rui1048 polymenu`: the host drew after the hello: FUNC + CHRO, DOWN x 9, YES -> 30 0x20 1 0 once, pm adds 1
  picks 1 opens 1, TrackMenuView no longer on top, the host's frame on the glass; TRK + SD first -> 30 0x21; the page
  open (TRK + YES, the host's real mask): the menu steps it aside, YES -> 30 0x20 again (hints 1, no leave), the frame
  back; no host frame: no 30, the PopupWindow (401d6e18) on top, nohost 1; a frame only before the hello: NO SIDECAR.
- `rled_emu.py rui1048a menustock` (rui1048's code before the host-test fix; the menu part is the same): items 0..8 equal
  rui1048base (rui1047's sources) without the scroll bar, the four stock items' rows equal stock 1.73's, item 9 new;
  YES on items 0..4 as rui1048base, on TRIGS SETUP / PAD SCALE as stock 1.73; the menu opened on both images.
- The 14 suites and bk: cu frz fxin mrep pc rui sfu sfx sp sq sv td us rc=0 each; `bk_emu.py all` rc=0 (321 checks, with
  polymenu; the rui1043 base for dspold); rled (1047's list plus menustock) rc=1: only 1046's known stockupkeys gridtrig clash (UP + RECORD / PLAY under a held trig in GRID REC), menustock and every other check PASS.
- End to end with the real core (rytm-teensy `polycfg`, RUI_TAG = RUI_TAG_1043 = SEQ_TAG = rui1048): `sim/rui_e2e.py pools
  latehello upamp polycfg polymake` rc=0 ALL PASS (polycfg: BD to PLAITS, the menu item -> 30 page 0x20, the core's POLY
  CONFIG page "PLAITS: NOT A POLY TRACK", YES -> "4 NOTES 4 INST 2.92%", knob A x 3 -> "3 NOTES 3 INST 2.19%", NO ->
  30 off and BD's SRC view again; polymake: UP + TRIG's make prompt on PLAITS JUNO DIGIDRUM DSP SAMPLE DAISYSP WAVETABLE
  GRANULAR MULTISAMPLE 6-OP FM, the analog BD explained); `sim/seq_e2e.py` rc=0 ALL PASS.
- A first suite run was void (the rui1048 base was rebuilt under it); its rui failure (one key-timing check) did not
  come back in the clean run.

**Cost.** Boot: one more item (0x54 B + three small blocks of heap, once). Per tick one load and compare (pm.owed).
Memory: pm 32 B. The menu's draw is stock's (one more row's label invoker when it scrolls into view).

**Build rui1048** (rui1047's mods and parameters): `build/b.sh rui1048`; verify PASS.

## 1049: SOLO reported (2D 0D); FUNC + YES on the SRC view opens the bank list's browser; 16 send FX label tables (emulator only)

Tags as above; [measured] = rytm-emu seq-p2, rui1049, 2026-10-23, DTEMU_STRICT=1. No hardware. Host half: rytm-teensy
`fixes1` (fix1049: core/seq/seq.cpp SOLO, core/ui/page_wavegrain.cpp, core/host_link.cpp; docs/SEQUENCER.md, POOLS.md).
From the hardware pass of rui1048 + the Pi (2026-10-23): (3) soloing a Rytm track left the Sidecar voices playing while
MUTE silenced them; (4) FUNC + YES on DSP SAMPLE's SRC page opened nothing (SMP OFF, the SAMPLES list empty: every project
made before the pools); (8) the Pi has 9 send FX TYPEs with labels since SPACE, 0029 kept 8.

**SOLO.** Stock keeps the soloed tracks in a BE word next to the mutes: `0x407c23c5`, bit t = track t [measured: CC 93
(Track Solo, re/subsystems/midi-cc.md) value 1 on SD's channel 2 -> 0x0002, on BD's channel 1 -> 0x0001, either value
1 or 127; CC 94 on channel 2 writes the mute word 0x407c23c3 -> 0x0002 as MUTE + SD does; mirrors 0x8000ed9e and the
settings copy 0x4131899d move with it]. sq_poll reads it beside the mutes (one more load and compare a tick) and sends
`2D 1 0D <lo7> <hi6>` on a change and in every resync (Q_SOLO, after 05: the resync is now 08 01 02 05 0D 06 07 09).
Device-neutral: "the soloed tracks" as 05 is "the muted tracks"; the host silences the tracks not soloed exactly as muted
ones. An older host ignores an unknown 2D kind (rytm-teensy seq.cpp's default), so no version or capability is needed;
an older Rytm never sends 0D. sq.solos is appended at the struct's end (sq_emu.py reads the fields before it by offset).

**FUNC + YES on the SRC view.** With the page and the bank list closed, the SRC view of a banked machine (GRANULAR,
WAVETABLE, MULTISAMPLE) or of DSP SAMPLE showing (the host draws it), its track selected, no seq-mode trig held: FUNC +
YES opens the list on the current entry (4A 1 .. why 0; DSP SAMPLE: P11, knob D) and asks the host's file browser at
once (4A 3 .. why 6, 1040's browse state set as its FUNC + YES in the list does). The YES and its release are eaten;
stock 1.73 binds nothing to FUNC + YES there (the hardware report: "opens nothing"). The host aims an OFF entry at the
bank's first free row (why 6 only; in the list FUNC + YES on row 000 stays refused). Then 1040 as before: YES on a file
sets the row, the browser ends (4A 0 0), the list stays on that row, YES commits (48). ls.srcyes counts these.

**16 label tables.** 0029 sfu.c NLT 8 -> 16 (2080 B of the elek area's .bss instead of 1040). The hello's caps byte is
now 3: bit 1 tells a host that the Rytm keeps 16 tables (the host sends the labels of 16 TYPEs, else 8 as before).
sfu_emu.py's offsets of the fields after lab[] move by 130 x 8 (DL), us_emu.py's one read too; rui_emu's splash check
reads caps 3.

Tests [measured, DTEMU_STRICT=1, rui1049 sha256 8104f08c..; the machine shared]:
- `sq_emu.py rui1049 solo`: SD soloed by CC 93 before the 2E -> the resync's 0D 02 00, BD too -> 03 00, SD off -> 01 00,
  BD off -> 00 00; the mutes stay 05 00 00; `state`: the resync 08 01 02 05 0D 06 07 09 (0D 0 0).
- The 14 suites and bk: cu frz fxin mrep pc sfu sfx sp sq sv td us rc=0; rui rc=1 in the first run (frame / escape / pass
  / own timing checks while the Pi kernel and the host tests built beside it), rc=0 run again alone; `bk_emu.py all`
  rc=0 (321 checks; it needs build/emu/rui1043's manifest, copied from rui1048's checkout); rled (1048's list) rc=1: only
  the known stockupkeys gridtrig clash (UP + RECORD / PLAY under a held trig in GRID REC), 873 PASS, menustock PASS.
- sfu: the first run failed typelist and cost - two offsets past lab[] (X_TIME, the order list at 1284, us_live at 5378)
  not moved with NLT; fixed (DL), rc=0.
- End to end with the real core (rytm-teensy fixes1, RUI_TAG = RUI_TAG_1043 = SEQ_TAG = rui1049): `sim/rui_e2e.py pools
  latehello upamp polycfg polymake dspsrcyes` rc=0 ALL PASS (dspsrcyes: SMP OFF on DSP SAMPLE's SRC view, FUNC + YES ->
  4A on, 4A on 3 srcyes, the core's browser on A003 - the first free row after the card's seeded A001 / A002 -, SET A003,
  YES -> 48 0 10 3 0 1, the waveform, the pad's trig smp 3 slot 3); `sim/seq_e2e.py` rc=0 ALL PASS (solo: BD's seq notes
  0 with SD soloed, 20 with BD soloed, 20 with none).

**Build rui1049** (rui1048's mods and parameters): `build/b.sh rui1049`; verify PASS.

## 1050: the Rytm side of the Sidecar sequencer's top 8; UP's map over an open page; SEED named on DAISYSP / DSP SAMPLE (emulator only)

Tags as above; [measured] = rytm-emu seq-p2, rui1050, 2026-10-24, DTEMU_STRICT=1. No hardware. Host half: rytm-teensy
`seqrytm` (core/seq/seq.cpp, core/ui/page_seq.cpp, core/ui/page_keys.h; docs/SEQUENCER.md "rui1050", docs/UI-THEMES.md).

**Almost all of it is the host's.** The SEQ page, its TRIG view and the lock pages are host-drawn pages; the Rytm already
sends what they need: TRIG, the trig keys, YES / NO / the arrows and the encoders' pushes (31) with the page open (the
host's catch mask) and in seq mode with the page closed (1032 / 1036), the turns with FUNC (32's func byte). The new pages
(DEFAULTS / SCALE / RANDOM without a held trig, TRIG / RTRG / FX under held trigs, the track menu's PLAY MODE and PRINT RND)
and the lock pages' gestures (a long encoder push: that lock's COND; FUNC + push: its SLIDE) need no new message:
- **FUNC at a push.** 31 carries no modifier. The host's SEQ page now catches FUNC (0x80) in its mask (37): key_owner gives a
  caught FUNC to both sides (2, as since 1022), so stock keeps it held (its FUNC combos are unchanged) and the host sees 31 0x80
  down / up. No Rytm change. [measured, `rled_emu.py rui1050 stocklockpush`: with the page open and the SEQ page's mask
  (the encoders, their pushes, FUNC) a long PUSH_A gives the host 31 0x70 1 / 0, FUNC + PUSH_A 31 0x80 1, 0x70 1, 0x70 0,
  0x80 0, and stock's state (the pattern, the sequencer, the selected track, every LED, the kit words) equals the run
  without the gesture.]
- **Stock on its own lock page** [measured, the same test on the stock image: GRID REC, T1 held, SRC]: PUSH_A held 0.5 s
  and FUNC + PUSH_A change only the glass - stock shows that knob's value in place of its label and its long name in the
  header while the push lasts (a peek), nothing in the pattern, the sequencer or the LEDs. So neither gesture clashes with
  a stock action; under the Sidecar's lock pages the pushes are caught (stock never sees them) and FUNC alone does nothing
  there.
- **A turn right after a push** [measured, rytm-emu, the stock image on FLTR and rui1050 with the page open alike]: a turn of
  the same encoder ~0.3 s after its push's release does not arrive (stock's screen does not change; 0026 gets no event, so
  no 32), 0.75 s after it does. Stock's own guard, not 0026's: after the long push (COND) the first turn wants a short wait.

**UP's map over an open page (the open item of bug 5).** 1044's map is asked only with the page closed (49 1 4). Now UP held
alone UP_MAP_TICKS with the page open (not stepped aside: then UP is a stock menu's cursor) sends `49 1 5 1`, its release
`49 1 5 0`. A new sub-id, device-neutral ("the modifier held alone over the open page"): an older host ignores an unknown
49 sub-id, where it would have closed its page at a 49 1 4 0. The host shows its KEYS page as the map and the page under
it again at the release; UP alone still steps no page (fix1049). UP + YES with that map up leaves as before (k44.map_page:
1044's SIDECAR request is only for a map asked over the stock screen). A trig or a combo with UP: no map, as before; a held
trig on a poly track takes UP (1046's u46.seq): no map. rui.c: k44 gains map_page and pmap_on / pmap_off (appended).
[measured, `rled_emu.py rui1050 upmappage`: TRK + YES, UP held 0.6 s -> 49 1 5 1 then 49 1 5 0, no 49 1 4, pmap 1 / 1;
UP tapped: none; UP + T3: 49 1 1 3, no map; UP held + YES: 30 off (no 30 0 1 0); `upmap` (page closed) unchanged; end to end
`sim/rui_e2e.py upmapover`: the core's KEYS map over SIDECAR, SIDECAR again after the release]

**SEED MOD's slot named SEED (0021).** R1b reads the seed's modulation from a machine param the machine leaves free (a scene
or PERF lock on it moves the seed). Measured against the host's machines (each P1..P16's reader in rytm-teensy core):
DAISYSP's SMPL B (P11, "FB") and DSP SAMPLE's SRC F (P6, "FB") are never read by the host (DSP SAMPLE's feedback is fixed);
both use record pointers to 0021's `dsp_n11` / `dsp_s11`, which now read `Seed` / `SEED` (EXT_SLOTS 1; the EXT_SLOTS 0 build
keeps c127fe8's bytes). 6-OP FM's P9..P12 and JUNO's P9..P16 are free too, but their SMPL page is stock's (6-OP FM's A..D
stock records, `us_page_record`'s `k < 4`); naming one would need code in 0021's .us1, which has 4 B left: not done - the
host takes P12 (stock's BR) as their SEED slot. PLAITS, DSP SAMPLE's SMPL page, MULTISAMPLE, WAVETABLE and GRANULAR read
all 16 params (no free slot); DIGIDRUM's P9..P16 drive the Rytm's own sample layer. A user machine names its free param
itself (1A META; the convention, docs/SEQUENCER.md).

**Messages.** New: `49 1 5 <on>` (Rytm -> host). None other (the host's sequencer state needs nothing new: SEQUENCER.md).

Also: with the page open UP's press still reaches the page (31 UP: a list's cursor there), and only a trig (UP + T1..T13)
or a combo marks the hold a combo; UP held 0.4 s with an arrow, a turn or T14..T16 also shows the map (harmless: the map
goes at the release).

**Cost.** UP's press: one more compare; dp_tick the same test with one flag more. Memory: k44 +12 B. 0021: `Seed` / `SEED`
for `Feedback` / `FB` (-4 / +2 B of .ext8 before alignment).


Tests [measured, DTEMU_STRICT=1, sequential, rui1050 sha256 720ab03f..]:
- The 14 suites and bk: cu frz fxin mrep pc rui sfu sfx sp sq sv td us rc=0; `bk_emu.py all` rc=1 in the run beside the
  host's builds (scale, dspold: timing), rc=0 run again alone (`bk_emu.py rui1050 scale dspold`); rled (1048's list plus
  upmappage stocklockpush) rc=1: only 1046's known stockupkeys gridtrig clash (UP + RECORD / PLAY under a held trig in GRID
  REC), every other check PASS.
- End to end with the real core (rytm-teensy seqrytm, SEQ_TAG = RUI_TAG = RUI_TAG_1043 = rui1050): `sim/seq_e2e.py` rc=0 ALL
  PASS (new: r50dir PEND's order 1 2 3 4 3 2, r50spd 3/2, r50key E4 -> Eb4 in C minor QNT PLAY, r50seed a fixed seed's
  same random notes on two PLAYs, r50rtrg CNT 4, r50fx JMP 4 (step 3 never), r50cond the lock on 1:2 in the file, r50slide
  the lock's slide in the file, r50menu PLAY MODE REV and PRINT RND; trigview's TRIG x4 back to the notes); `sim/rui_e2e.py
  pools latehello upamp polycfg polymake dspsrcyes upmapover` rc=0 ALL PASS.
- Flash rehearsal rui1049 -> rui1050 (rytm-emu-osup tools/rehearse_flash.py, the real erase / program timings): 9/9 PASS.

**Build rui1050** (rui1049's mods and parameters): `build/b.sh rui1050`; verify PASS.

## 1051: LIVE IN and CHOP in the machine list; UP's map not in stock lists; the trig LEDs after GRID REC and after PAGE (emulator only)

Tags as above; [measured] = rytm-emu seq-p2, rui1051, 2026-10-24, DTEMU_STRICT=1. No hardware. Host half: rytm-teensy
`chop` (core/chop, core/ui/page_chop.cpp, core/livein; docs/CHOP.md, docs/LIVE-IN.md section 4).

**Machines 48 LIVE IN and 49 CHOP** (0021: ext_render, voice flags 0x78 / 0x18; 0021 design.md "1051"). Listed on every
track (home / mask word 0x401bf1dc = -1, as 44) with 0026's names `LIVE IN` / `LVIN` and `CHOP` / `CHOP` (registry
patches 0x401bf124..0x401bf130). Their SRC pages list MULTISAMPLE's shared records (as 46 / 47, 1034), set up by cu_setup /
cu_src_setup for the machine using them (CU_IDS copied to 48 / 49): LIVE IN INPT GAIN GATE HOLD MON ATK DEC SUS (page 2:
REL on P9, the rest unused), CHOP SRC SLC TUNE MRPH SEED NBR VEL LEV (page 2: STUT SLEN TAPE TTIM ATK DEC DIR LOOP, each
fully down = the slice's own setting). Value texts 13..26 (cu_text: INPT L R L+R STR, MON ALW TRIG, GATE OFF / -80..-20 DB
rounded as the host, SLC 1..64, TUNE -24..+24, the percentages, SEED OFF / n, STUT SLC / X2..X16, TAPE SLC OFF STOP SPIN,
DIR SLC FWD REV, LOOP SLC OFF FWD PING, the times SLC / n, DEC SLC / n / HOLD at 127). CHOP's SRC is a SAMPLES row
(ls_banked: the bank list and its browser, as GRANULAR's).
- **Page-2 defaults.** set_machine leaves page 2 as the stock sample page's words (TUN 64, LOP 100 .. [measured, cu_emu]):
  on CHOP those would stutter, tape-stop, reverse and loop every hit. cu_prep (set_machine's entry; the detour now also
  passes the track) notes a LIVE IN / CHOP choice made in the machine list (MachineListView on top: a kit, sound or
  project load that calls set_machine keeps its own words [inferred: those paths not measured]); cu_defs_tick writes P9..P16's defaults as knob turns (SET_PARAM +
  kit_param_changed, us_set's way) once the machine list has closed (MachineListView 0x401e5bf4 not on top: its cursor's
  previews call set_machine too) and the track still plays that machine; a choice that went is dropped.
- **48 from the host** (wr_tick): LIVE IN / CHOP are refused (status 1) when the shared SRC records, or for P9..P16 page
  2's, are set up for another machine - as MULTISAMPLE / WAVETABLE / GRANULAR since 1036 (code review M1).

**UP's map in stock lists (the hardware report on rui1049).** UP held to scroll the machine list popped the host's map
(49 1 4 / 5): the list's held UP is stock's auto-repeat. overlay() now also notes a list view (a class name ending in
ListView, List or Browser: the machine list, the sound / sample browsers), and the map is asked only where UP is not a
stock cursor (up_cursor: an overlay or a list). The main screen and an open Sidecar page keep 1044's / 1050's map.
[measured, `rled_emu.py rui1051 upmaplist`: in the machine list UP held 2 s runs the cursor to the top, no 49 1 4 / 5,
the screen equal to stock 1.73's same run but for the list's scroll bar (rui's list is longer); `upmapmenu`: FUNC + CHRO's
track menu, UP held: no map, the menu's cursor at the top as with UP tapped; `upmap` / `upmappage` unchanged]

**The trig LEDs after GRID REC (the hardware report on rui1050: a poly track, GRID REC with the SEQ page open, the host's
34 on the trig keys; REC pressed: the screen stock's again, all 16 trig LEDs stayed GRID REC's dim red, 1 / 5 / 9 / 13
brighter, until stock changed each - PLAY's playhead, a TRK press).** Not reproduced: in rytm-emu stock's sends at REC
off reach the shadow and the hand-back writes them (`sq_emu.py recleds`, the page left after REC off with the host's 34
painted: every trig and PAGE LED equal to the same run without page and 34; `rytm-teensy sim/seq_e2e.py recleds` with the
real core: T1 / T3 placed in GRID REC, REC off, all 16 dark as stock's). Two changes from reading the code [inferred]:
- the hand-back (led_restore) writes stock's last selector bytes of LEDs 0..15 (0x20..0x23, now shadowed: shs) after its
  last slot colours, and the whole of it again LED_AGAIN (4) ticks later: a hand-back that crossed stock's own repaint of
  the same moment, or bytes the panel MCU lost at 156 250 baud (the emulator does not model the rate), end with what
  stock last sent either way;
- a 34 whose paint missed the LED lock (stock's LED senders hold it: a try-lock, `led_busy`) was dropped: `fresh` lasted
  one tick, so the trig LEDs kept the previous 34 until the host sent another. Now owed until painted (led_owed, as
  pg_tick's pg_fresh always was). This is the likely cause of the next report too.

**PAGE moved the PAGE LEDs, not the trig LEDs (the hardware report on rui1050: a 2-page poly track, GRID REC, stopped;
playing it worked).** The host's page did move (its PAGE LEDs are its 2F, painted at the next tick when the lock is busy:
pg_fresh); its 34 for page 2's trig LEDs could be lost to a busy lock (above) and, stopped, no later 34 came to repaint
them; playing, the playhead sends one every step. [inferred: the emulator never contends for the lock; end to end with the
real core, `rytm-teensy sim/seq_e2e.py pagestop` (page open) and its page-closed run: T1, PAGE, T3 stopped -> the host's
steps 1 and 19, the trig LEDs page 2's (T3 lit, T1 dark), page 2's PAGE LED the lit one - PASS before and after] The host
had a second cause, the same report's touchscreen half (one page while stopped, two once playing): on PATTERN scale the
host took a track's length from the track's own length byte until the clock ticked; it now takes the pattern's
(rytm-teensy docs/SEQUENCER.md "rui1051 fixes"). No Rytm change for that: 2D 04 already reports the pattern's length
and mode.

**Messages.** None new (LIVE IN / CHOP are 33's / 0x04's voice flags 0x78 / 0x18; the host side's).

**Cost.** uart_byte: one range compare more per byte; led_restore: 8 B more a hand-back, once again 0.2 s later. Memory:
shs 4 B, led_again 4 B, led_owed 1 B; cu +12 B (dm dt dtick defs).

## 1052: the project slot reports (4B) - the Sidecar's projects keyed by the Rytm's slot (emulator only)

Why: the Sidecar keyed a project's files by the Rytm's project name, so RENAME looked like a new project, SAVE AS left
the copy without its files, and the user's two projects named PRESETS (slots 1 and 2) shared one set of files. The Rytm
has 128 fixed project slots and no ID inside a project: the slot is the identity [measured, rytm-emu rui1051, the
research of 2026-10-26: rytm-teensy docs/superpowers/specs/2026-10-26-project-slot-identity-research.md]. 1052 reports
the active slot and the project manager's slot events; the Sidecar keys a project by its slot and copies / trashes its
files with them (rytm-teensy docs/superpowers/specs/2026-10-27-project-slot-keys-design.md).

**Messages (Rytm -> host; the host sends nothing new, 0022's router unchanged).** `F0 7D 52 54 4B 01 <op> ... F7`, slots
1-based in two 7-bit bytes `<n >> 7> <n & 0x7f>` (0 none):

| op | body | when |
|---|---|---|
| 00 ACTIVE | `<slot hi lo> <name, up to 15 ASCII>` | the active slot (0x405c8e4d, signed, 0-based, -1 none) or the name (0x407c89d3) changed - polled each UI tick; after each hello; every 5 s unchanged (PJ_EVERY) |
| 01 SAVE | `<from hi lo> <to hi lo>` | save's entry 0x400b0738(project, slot, cb), slot >= 0; from the active slot then (0: after CREATE NEW) |
| 02 PASTE | `<src hi lo> <dst hi lo>` | write-slot called from the paste (return 0x4003524c); src the slot the last COPY (0x4003502c) took, 0 none |
| 03 CLEAR | `<0 0> <slot hi lo>` | write-slot from the clear job (0x40051ae6: CLEAR, INIT NEW) or the init job (0x40051a74: FUNC + PLAY) |
| 04 DELETE | `<0 0> <slot hi lo>` | delete 0x40034a54(lib, slot), once per selected slot |
| 05 RENAME | `<0 0> <slot hi lo>` | write-slot from the rename job (0x400519a8) |
| 06 LOST | `<n hi lo> <0 0>` | n events dropped (the 32-entry ring full, or a second producer at the same instant) |
| 07 WRITE | `<0 0> <slot hi lo>` | write-slot from any other caller (Transfer / SysEx receive paths, not traced): the host logs it |

The hello's caps byte gains bit 2: 1052's caps = 7 (36, 1049's 16 label tables, 4B).

**Opcode registry.** 4B is the project reports' (sub-ids 00..07 used; 08..3F reserved for projects). 4C is the next free
opcode: the kits' SAVE / RELOAD reports planned on this branch take 4C (or a 4B sub-id range agreed here).

**Hooks (registry detours, four; the displaced bytes re-emitted as words).** All in the project job task [measured
stacks, a7 0x413e3bxx: the research's break points and `brk.sh t_saveas 7500 400b0738`, 2026-10-27]:
- write-slot 0x40034e98 (lib, slot), `lea -32(sp),sp; moveq #127,d1` (6 B): pj_write(return address, slot) - the caller
  by its return address (above), save's own write (0x400b082e) and write-slot's call of itself (0x40034f4a) skipped.
- delete 0x40034a54 (lib, slot), `move.l d2,-(sp); moveq #-1,d0; move.l 12(sp),d2` (8 B).
- copy 0x4003502c (lib, slot), `link.w fp,#-28; movem.l d2-d3/a2,(sp)` (8 B): the clipboard's slot, no message.
- save 0x400b0738 (project, slot, cb), `lea -48(sp),sp; movem.l d2-d4/a2-fp,(sp)` (8 B).
The C halves note (op, a, b) in a 32-entry ring under a TAS lock (one producer at a time; a second one at the same
instant counts as LOST, never spins - TAS is ISA_B, assembled for -mcpu=5475). pj_tick (UI task, from rui_tick after
the first hello) sends through send()'s try-lock: LOST first, the events in order, then the ACTIVE only when no event
waits (the host sees SAVE 1 -> 4 before ACTIVE 4). Nothing waits; a busy sender leaves the rest for the next tick.

**Tests [measured, rytm-emu seqp2, DTEMU_STRICT=1]:** `tools/emu/pj_emu.py rui1052 all` - the research's panel
sequences (its proj_ops.sh, ported) from the us_base snapshot (PRESETS in slots 1 and 2, slot 1 active and write
protected) with a host on the Overbridge link keeping every SysEx:
- hello: caps 7 in each 35, ACTIVE 1 PRESETS after it, no event;
- saveas (slot 4): SAVE 1 -> 4 before ACTIVE 4; saveto (occupied slot 2, OVERWRITE): SAVE 1 -> 2, ACTIVE 2;
  saveto_empty (slot 5): SAVE 1 -> 5, ACTIVE 5, the card's slot 5 written;
- copypaste (1 onto 3): PASTE 1 -> 3, the active stays 1, the card's slot 3 = PRESETS;
- clear (2): CLEAR 2, the card's slot 2 changed; delete (2): DELETE 2, slot 2 empty; init (empty slot 6): CLEAR 6;
- rename (2): RENAME 2, the card's slot 2 renamed, the active report unchanged;
- locked: CLEAR on the write-protected slot 1 - the Rytm refuses (WRITE PROTECTED), no event;
- from slot 2 loaded (loaded2): clearactive - CLEAR 2, the ACTIVE stays 2 PRESETS (the RAM project and its name kept
  while the card's slot 2 is NEW PROJECT); renameactive - RENAME 2, then ACTIVE 2 with the card's new name (QRESETS: the
  RAM name follows); loadsave (LOAD slot 1, saving first) - SAVE 2 -> 2, then ACTIVE 1;
- load (slot 2): no event, ACTIVE 1 then 2; createnew: no event, ACTIVE 0; then SAVE AS 5 from there: SAVE 0 -> 5,
  ACTIVE 5; lock (TOGGLE): no event.
The existing suites with rui1052: build/suites/run.sh -j (summary in the commit). rytm-teensy sim/prjslot_e2e.py: the
Sidecar's core against these messages end to end.

**Not in 1052.** A list of the 128 slots' names (for a migration with no questions): the Rytm keeps a 24-byte header
per slot in RAM (flag, version - -1 empty -, name; at 0x41b8134c in rytm-emu after a boot) but on the heap, reached
through objects not understood yet, so not read here. Loading the active slot again (same name) is not reported (the
setter 0x400fa694 with an unchanged value): a paste onto the active slot followed by that reload is seen only when the
slot is left.

**Cost.** Per hooked call ~40 instructions (a compare chain, the TAS, three bytes); per UI tick: one signed byte and up
to 16 name bytes compared. Memory: pj 160 B (the ring 128 B); code ~0.9 KB in the elek area (59120 bytes spare).

### 1052b: the slot list, LOAD, no stale events (the review of 2026-10-27; the user's decisions)

**Messages added** (Rytm -> host, 4B sub-ids; 4C stays free for the kits' reports):

| op | body | when |
|---|---|---|
| 08 LIST | `<first hi lo> <n 8> {<occ 0/1> <name 15, NUL padded>} x 8` | 16 messages (all 128 slots), one a UI tick, after the ACTIVE that follows each hello and after each LOST |
| 09 LIST END | `<count hi lo> <0 0>` | after the 16th LIST: the projects listed; 0x3fff: the table did not look right, no LIST sent |
| 0A LOAD | `<0 0> <slot hi lo>` | the active-slot setter 0x400fa694 called with a slot (a LOAD, also of the active slot again; inside SAVE AS with the new slot) |

**The slot table** [measured, rytm-emu rui1052]: a pointer in .bss at 0x419f2888 (0x41b81340 in every snapshot of these
runs, cold boot included); slot n's 24-byte header at +12 + 24 n: byte 0 = 1 a project there (0 empty or deleted - a
DELETE keeps the version and the name and clears the flag), the name at +8 (16 B, its tail not cleared on a rename:
LIST sends up to the NUL). It follows the card: matched after SAVE AS, PASTE, CLEAR, INIT, DELETE and RENAME (the
pj_*.snap of every pj_emu run). Read only when the pointer is in DDR below the elek area, 4-aligned, and all 128 flags
are 0 or 1; else LIST END 0x3fff and no list (the Sidecar then asks per slot, as before).

**LOAD**: a detour at the setter's entry (`mvs.b 0x405c8e4d,d1`, 6 B, an absolute address; rejoin 0x400fa69a). One call
per LOAD, two per SAVE AS (from 0x400aecde in the job task: the new slot) [measured counts and a break point]. The host
acts on a LOAD of the active slot (a paste onto it then a reload: resolved at once); the others it ignores.

**No host, no stale events**: rui_tick drains the ring while there is no host (the port down, or no hello sent yet):
every event but LOAD counts as LOST, so a host that connects later gets one LOST (and the LIST after it), never old
SAVE / PASTE / CLEAR replayed against the card as it is now. (A LOAD drained is not counted: the boot's own setter call
would otherwise make every connect a LOST.)

**Tests [measured, rytm-emu seqp2, DTEMU_STRICT=1]** `tools/emu/pj_emu.py rui1052 all`, the 1052 tests plus:
- hello: a LIST after the ACTIVE = the card's slots, END count 2, 128 slots a LIST;
- reloadactive: slot 2 loaded, slot 1 pasted onto it (PASTE 1 -> 2, no LOAD), then LOAD of slot 2 again (the active
  slot's load asks only "ANY CHANGES WILL BE LOST. PROCEED?"): LOAD 2, no other event;
- nohost: CLEAR and DELETE of slot 2 with no USB port, then a host: one LOST 2, no stale event, the LIST = the card now;
- load / saveas / loadsave / createnew: their LOADs (load: 2; saveas: the new slot).
Build gate: `tools/build_rui.sh rui1052` (build.py with the rui set + verify.py; `make verify` builds the mod.toml
default set, 0022 keys=1, which can never sit beside 0026's uart detour - registry "never both in one build").

### 1052c: LOAD only from LOAD PROJECT, each LIST twice (the round-2 re-review of 2026-10-27)

**LOAD filtered.** A second detour, at the entry of the helper 0x400aecc0 (`movea.l 4(sp),a0; movea.l (a0),a1`, 6 B,
rejoin 0x400aecc6), keeps the helper's return address in `pj_act_ret`. The setter's detour (1052b) reads and clears it
and pushes LOAD only when it is 0x400b405e (the call at 0x400b405a, LOAD PROJECT). The helper's 9 call sites [code],
driven in rytm-emu with `--count` break points (pj_emu setters) [measured]:

| path | sites hit | LOAD |
|---|---|---|
| LOAD PROJECT (also the active slot again) | 0x400b405a | yes |
| SAVE / SAVE AS / SAVE TO | 0x400b077a, 0x400b0842 (in save 0x400b0738) | no (the SAVE event says it) |
| LOAD + SAVE | all three | one |
| CREATE NEW | 0x400b3d6c | no |
| CLEAR / INIT / RENAME of the active slot, FUNC + PLAY | none | no |

The other sites were not reached by any panel path the emulator drives; a call from them sends no LOAD (fail safe: the
host does nothing it was not told). A same-slot set with no reload (the saves) so never reads as a reload to the host.

**LIST twice.** Each list (after a hello or a LOST) is sent two rounds: slots 1..128, END, slots 1..128, END. The host
acts on a list only when it is whole (all 16 messages, END count = the occupied slots, count > 0, the active slot
occupied) and two consecutive lists are identical. A hello or LOST restarts at slot 1 (a list cut short is never
ended).

**The slot table pointer** stays `inferred` in re/symbols.toml: a data watchpoint (`dtboot --watch 419f2888`, cold boot)
shows its only writes, the .bss clear (0x4000085a) and the lazy getter 0x4017d17e (`move.l %d0,0x419f2888` at
0x4017d1e6) [measured]; the header layout is inferred from snapshots, not traced through the getter.

**Tests [measured, rytm-emu seqp2, DTEMU_STRICT=1]** `tools/emu/pj_emu.py rui1052 all` plus: setters (the site counts
above and the LOADs: load [2], reloadactive [2], loadsave [1], none from saveas / saveto / createnew / clear of the active
slot / FUNC + PLAY); hello (each LIST sent twice, each END after slots 1..128 in order).

### 1052d: the kit reports (4C), the NO + reload key and YES timing rules, the round-3 LOWs (2026-10-28)

**Kit reports** (Rytm -> host, `4C 01 <op> <kit hi lo> <src hi lo>`, kits 1-based; rytm-teensy core/bundle/kits.h
mirrors them on the Sidecar's per-kit files). Through the 4B ring (in order with the project events; with no host
they drain into LOST like the others):

| op | when | function, its callers [measured: pj_emu kits' break-point counts] |
|---|---|---|
| 01 SAVE `<kit> <src>` | SAVE KIT, YES + KIT (PLAYMODE) | kit_save 0x400b119c (project, index, flag): 0x400cd562 (YES + KIT), 0x400dd69a (the KIT menu); src the active kit at its entry. SAVE KIT to K002 from K001: SAVE 2 1, and K002 is the active kit after it (a NO + KIT then reloads 2) |
| 02 RELOAD `<kit>` | RELOAD KIT, NO + KIT | kit_reload 0x400af0d2: 0x400cd4ae (NO + KIT), 0x400dd5de (the menu); the active kit after |
| 03 RESTORE `<kit>` | (kept for 0010-kit-ab's EDITS RESTORED) | not sent: 0010 cannot be in a build with 0021 (excludes, cave7 since fix-1020), so never in the rui set |
| 04 RELOAD ALL `<kit>` | the KIT menu's RELOAD set to ALL (LEFT / RIGHT on the item) | 0x400b131a (kit_reload_key's flag branch) |

Detours (6 B registry, 8 B displaced, as the 1042 wrappers): kit_save `lea -60(sp),sp; movem.l d2-d7/a2-fp,(sp)`,
kit_reload `lea -20(sp),sp; movem.l d2-d4/a2-a3,(sp)`, every kit `lea -28(sp),sp; movem.l d2-d4/a2-a5,(sp)`: the
stock function runs first, the report after it. A LOAD PROJECT sends no kit report (kit_apply is called from its own
stock site, not through these). Stock's NO / YES + SCNE / CHRO / PLAYMODE: the gestures measured by brute force on
the emulator (NO + SCNE 0x400af5e0 RELOAD PAT, NO + CHRO 0x400af64a RELOAD TRK, YES + SCNE / CHRO the saves).

**NO + a reload key under a page** (the user, 2026-10-27): a page that catches NO (its mask) keeps NO's press back
(nk.no_def) until NO's release (then the host gets NO down and up: the page's back, as before) or the next key. That
key SCNE / CHRO / PLAYMODE: NO's press is given to stock (an injected key event, as 1040's TRK) and booked stock's,
the key stock's too - stock's reload runs under the page, the host sees neither key. Any other key: NO's press goes
to the host first (order kept), then that key as always. Not when another of the page's keys is already held (a
host combo with NO: sent at once, as before).

**The YES timing rule** (ux1027's review): with the page open (not aside) YES is the host's whenever FUNC (any book)
or a page trig (our_down T1..T16) is down, before the mask is asked - FUNC + YES (UNDO) and trig + YES (the preview)
within the moment before the host's mask has YES. YES pressed with neither down goes by the mask, so on a page whose
mask leaves YES out (ux1027's poly SEQ page) YES held + SCNE / PLAYMODE / CHRO (stock's quick saves) work. The same
for UP / DOWN with FUNC down (the controller, 2026-10-28: the poly SEQ page leaves UP / DOWN to the Rytm - CHRO's
octave shift - and its track menu moves to FUNC + DOWN): FUNC then UP / DOWN is the host's before its mask with them
arrives; UP / DOWN without FUNC go by the mask.

**Releases stock takes**: stock's NO / YES + SCNE / CHRO / PLAYMODE takes that key's release before 0026's ev_key
sees it [measured, the page open or not: the key stayed in stock_down]; at NO's / YES's release those keys are
unbooked (nk.unbooked), and a later release of one still goes to stock (a press nobody booked).

**LOAD from the setter's own stack** (round-3 LOW): the helper detour and pj_act_ret are gone; the setter's detour
reads its return address ((sp) = 0x400aecde when the helper called it) and the helper's (8(sp): the helper has no
frame and saves nothing [code]) - nothing stale when the helper's check fails, nothing another task can overwrite.

**send() and a stock dump** (the sq fetch race, found by the REMOTE KEYS work): the UI-tick send() also waits while the
sender's SysEx state (0x413db244) is set, as isr_send does: a stock pattern / kit dump gives the mutex back between its
parts, and a POS report sent then cut it. The message goes at a later tick.

**Tests [measured, rytm-emu seqp2, DTEMU_STRICT=1]**: `pj_emu.py rui1052 kits` (the table above, the sites' counts, a
LOAD PROJECT without kit reports, no host -> one LOST); `sq_emu.py rui1052 noreload` (NO + PLAYMODE / SCNE / CHRO:
the reload once, neither key to the host, the page open, no key left in 0026's books; NO alone: 31 NO down / up; NO +
LEFT: NO down, LEFT down / up, NO up), `yestime` (FUNC + YES and T1 + YES the host's under a mask without YES; YES +
PLAYMODE stock's SAVE KIT, no YES to the host; FUNC + DOWN / UP the host's under a mask without them, DOWN / UP
alone the Rytm's), `fetchrace` (the stock pattern dump requested at 480..560 M while
playing: whole every time, the POS reports still sent).

### 1052d, review round 5 (2026-10-29)

- **FUNC + NO** (M1): NO is never kept back while FUNC is down (any book) or another of the page's keys is held: FUNC +
  NO reaches the host as FUNC + NO in the order pressed and released (a roll with FUNC let go first included - the
  host's NOTE EDIT delete).
- **Keys never left down on the host** (M2): queue_key drops a press (counted, tx_drop) when fewer than KQ_REL (6)
  places are left, and then its release too; a release is never dropped - with the queue full its own unsent press
  goes out with it, else it is owed (kq_owed) and goes first as room comes. send()'s wait for a stock dump is bounded
  (TXSX_TICKS, 2 s, then it sends anyway: txsx_over). The flag (0x413db244) is set and cleared per SysEx message by
  the sender (pc 0x40002c14 / 0x40002ab6, --watch [measured]); a dump cut by a cable pull (--usb-host-gone 3 M into
  it) leaves it clear [measured], so the bound is a guard only.
- **L5**: SCNE / CHRO / PLAYMODE are unbooked only at the release of a NO / YES that was stock's (the combo stock ran).
- **L6**: FUNC + UP / DOWN go to the host only until the host's next mask (masks unchanged since FUNC went down: the
  moment before it can answer), then its mask decides; only on the host's page (st.active, not aside). UP pressed with
  FUNC down starts no combo map (49 1 4 / 5).
- **L7**: the page leaving while NO is kept back books NO to be eaten: its release reaches neither stock nor a page
  opened again meanwhile.
- **kit_save's other callers** [code + measured]: 0x400cc34a ends in "KIT SAVED!" (0x40255e0f, as SAVE KIT's), a second
  kit-save view: a SAVE report is right for it. 0x40103b62 / 0x40103f46 (and kit_reload's 0x40103afc) are inside
  0x40102f64 (a 2.5 KB-frame job reached by the thunks 0x400a3842 / 0x400a3882, with the file-system strings "VERIFYING
  FILE SYSTEM...", "ERROR - File Not Found" near it: a +Drive / file transfer job, inferred). A SysEx kit dump sent to the
  Rytm (to stored kit 1, to kit 3, to the working kit) reaches none of them and sends no 4C [measured: kprobe, the
  kit dump requested with 0x62 and sent back]; SAVE PROJECT / SAVE AS send none (pj_emu's events lists). If the file
  job ever reports a SAVE, the Sidecar takes it as a SAVE KIT (its record of its working kit files): no data lost.
- **The active kit** 0x800067b8 is written only by 0x4011f82a, which refuses values above 127 (re/symbols.toml
  data.active_kit), 0 from the .bss clear: always 0..127, `& 127` never folds a "none".
- **REMOTE KEYS (0031, branch rkeys)**: it injects at the panel's button level (core_keys_set -> core_stock_buttons,
  the stock panel parser, into the UI event queue), so its keys reach 0026's ev_key / key_body like physical ones: the
  held-back NO, NO + reload key, the YES / UP / DOWN rules and the release books apply to them unchanged (a remote
  TAP of NO is the page's back at its release; a remote PRESS of NO, then a TAP of PLAYMODE, stock's reload). The
  merge must check: the elek area's room for both (0031: 7.3 KB .run + 7.1 KB .bss), the registry (no shared detour
  sites), and that 0031's own injected NO / FUNC go through ev_key (not STOCK_KEY): 0026's injected NO (NO + reload)
  uses STOCK_KEY and so never touches 0031's physical / synthetic books.
- Tests: sq_emu noreload (FUNC + NO rolled; the page closed and opened again while NO is kept back), yestime (FUNC +
  UP / DOWN after the host's next mask: the mask's; FUNC + UP held: no map), fetchrace (ten taps during the dump:
  every down matched by its up; a dump cut by a cable pull leaves the flag clear).

### 1052d, review round 6 (2026-10-29)

- **N1**: the dump wait's count runs on its own flag (txsx_on) and a signed compare - before, a count started on an even
  tick read as already run out (`st.ticks | 1`), so about half of all dumps had 0026's first-tick output inside them.
  fetchrace now checks txsx_over == 0 at every request time (nine, both tick parities).
- **N2**: the bound counts ticks with the flag never seen clear: the audio interrupt's entry (ev_render_in,
  rui_render_in, 1500 / s) notes any moment it is clear (txsx_gap), which restarts the count, so back-to-back stock
  messages are waited out whole (the flag is set and cleared per message [measured]). Tested: eight pattern dumps asked
  at once (about 120 KB): all whole, the wait never ran out. 0026 reports its dropped key presses and the waits run out
  to the host (4D 01 <dropped hi lo> <over hi lo>, on a change, at most once a second; rytm-teensy logs it). A test
  hook (txsx_test, poked: the flag held N ticks from the next key queued, with no gap) drives the overflow: 12 taps
  with it held 30 ticks - 7 presses dropped with their releases, every down on the host matched by its up, 4D 7; held
  100 ticks - the wait runs out after 2 s (4D's over), the keys go out balanced.
- **Parked for 0.3.1** (the user froze the flash scope, 2026-10-29):
  - N4: a repeat press dropped while the queue is full marks its key so the real release is dropped too (key_body
    never queues repeats today, so not reachable from the panel).
  - N7: after the page closes with NO kept back, NO + SCNE / CHRO / PLAYMODE is no longer stock's reload (NO is eaten).
  - L6: UP pressed before FUNC still starts the combo map (UP held alone, as before).
