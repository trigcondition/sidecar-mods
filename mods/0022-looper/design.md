# 0022-looper: looper mode for an Overbridge host's master looper

TRK + REC toggles looper mode. In it the 12 pads are clip slots (TRK held or not), UP/DOWN pages
(8 pages of 12), and pad presses go to the USB host instead of the Rytm; with TRK
held the pads keep their stock action (track select). The host (rytm-teensy
sim/obhost.py `Looper`; later the Teensy) does the rest: an empty slot records
the master out for 4 bars from the next bar, then loops it; a slot with a clip
plays from the next bar; the playing slot stops at the next bar. Bars come from
the Rytm's MIDI clock (GLOBAL > MIDI CONFIG > SYNC: CLOCK SEND, TRANSPORT SEND).
Loops play into Overbridge MAIN L/R, which joins after the Rytm's master FX.

## Reports (SysEx over USB MIDI)

    F0 7D 52 54 05 <on 0/1> <page> F7     mode, page
    F0 7D 52 54 06 <slot> <down 1/0> F7   a pad, slot = page * 12 + pad

and from the host, taken at the SysEx router's entry (0x40083d6c: data, len,
interface; the MIDI task) before the stock router sees it:

    F0 7D 52 54 07 <slot> <state> F7      0 empty, 1 queued, 2 recording,
                                          3 playing, 4 stopped (has a clip)
    F0 7D 52 54 08 <on> F7                1: keep the track mutes, mute all 12
                                          (a loop took over); 0: put them back

## Handover

When a loop starts with none playing the host sends 08 1: the Rytm keeps its
mutes and mutes all tracks, on the bar, so the loop replaces the live pattern
instead of doubling it; patterns, kits and mutes can then change underneath
(unmute tracks to play over the loop). Stopping the loop sends 08 0: the kept
mutes come back on the bar. Switching between clips leaves the mutes alone. Only
the loops fade (10 ms in/out, 10 ms between clips, 5 ms at the loop point from
the audio recorded just after it); the mutes are instant and the live notes ring
out under the loop's fade-in.

Track mutes [measured]: a bit mask (bit t = track t) at 0x8000ed98 (the
sequencer's, 32-bit) and 0x41318997 (the settings', unaligned, big-endian):
MUTE + BD, SD, CH gave 0x103 in both; writing 0xfff at 0x8000ed98 alone
silenced the pattern. The mod writes both.

## Pad colours

In looper mode each pad shows its slot's state: dark, amber, red, blue, dim blue
(palette 0, 63, 15, 47, 43 [measured]). The firmware drives pad LEDs on several
paths - `led_set(led, on, colour)` 0x40095d2c, `led_colour(led, colour)`
0x40095f54, and slot selectors for the trig glow (2 bits a LED, sent per group
of four through the callback pointer 0x40287a10, stock 0x40095b48) - so the mod
owns them at the panel link: in looper mode it drops the firmware's colour
messages (B0..B4) for the pads' hardware LEDs 72..83 at the UART8 writer
(0x400019e4) and their selector groups 18..20 (pads only) at the callback, and
paints each pad with `B4 id c c c c` (one colour in all four slots, so any
selector shows it). Leaving looper mode re-sends the firmware's cached slot
colours (0x42fb6f49 + 4 x logical LED; pads are logical 16..27) and last-sent
selectors (0x41920534). The first try, hooking led_set alone, left the glow and
the selected-track colour showing through.

## Facts [measured, OS 1.73, rytm-emu, 2026-10-08]

- Key events reach `key_dispatch(ui, event)` (0x400a02ca), called once from the
  UI loop at 0x400a47cc; it walks the handler list at ui + 1784. Events: key code
  at +12, flags at +16 (bit 0 down). Codes: pads 0x90..0x9b (BD..CB), TRK 0x86,
  RECORD 0x50, PLAY 0x51, UP 0x42, DOWN 0x43.
- Pads also play on their own path before the key event: the pad handler
  0x400c7854 (sound, the MIDI note on the auto channel, live recording; returns
  1 when handled). Taking only the key event left the pad sounding.
- The USB MIDI sender 0x400029e0 is called by tasks under the mutex taken at
  0x40002914 and given at 0x40002924; looper_key runs in the UI task and does the
  same.

## Patches

- 0x400019e4: jmp.l looper_uart (the panel link filter).
- 0x40287a10: the selector callback -> looper_sel.
- 0x40083d6c: jmp.l looper_router (host SysEx).

- 0x400a47ce: the call's target -> looper_key, which passes on what looper mode
  does not take.
- 0x400c7854: jmp.l looper_pad: in looper mode without TRK held returns 1, else
  redoes the two instructions it replaced and goes on at 0x400c785c.

Code 478 B in cave13, 280 B in cave10 (.lp2), 360 B in cave18 (.lp3), 288 B in
cave14 (.lp4); state 110 B in cave24 (.lps).

## Checked in rytm-emu

Build with 0014 (test=0), 0021 and 0022 only. TRK + REC, BD: "rec at the next
bar", 4 bars recorded (7.56 s at 127 BPM), looping; after STOP the loop sounds on;
BD stops it. A pad in looper mode makes no sound and sends no note; outside it,
unchanged. Screenshots: BD red while recording, blue while playing, the other
pads dark (no glow); after TRK + REC again the stock colours and glow are back.
Handover (rms per second): live ~1150, loop alone with the tracks muted ~1080,
live again after the pad stops the loop on the bar ~1100 (host gain x21).

## Open

- Screen feedback (popup); the page number is only reported to the host.
- The loop's level on a real Rytm (the host's gain is set from the emulator).
- Release of TRK while REC is held; FUNC combinations.
