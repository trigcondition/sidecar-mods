# User manual

What each mod in the default build does on the device and how to use it. For
building see `README.md`, for installing see `docs/FLASHING.md`, and read
`docs/HAZARDS.md` before flashing.

The default image is
`Analog-Rytm_MKII_OS1.73_0000_0002_0003_0004_0006_0008_0009_0010_0012_0013.syx`. It is stock
OS 1.73 with the mods below added; everything not mentioned here behaves as stock.

| mod | where | what |
|---|---|---|
| 0002 | TRIG > euclidean page, OP | euclid sets accents on your trigs instead of placing trigs |
| 0003 | TRIG page, FUNC + VEL | per-track random velocity |
| 0004 | LFO key, pressed twice | LFO RND page: two random modifiers per sound |
| 0006 | FX track, AMP key, pressed twice | compressor gain-reduction preview |
| 0008 | FILTER page, FRQ | cutoff shown in Hz |
| 0009 | FX track, compressor pages | VOL label lights when the main output is loud |
| 0010 | NO + PLAY | switch between the edited kit and the saved one |
| 0012 | FUNC + CHRO, SLICE LOOP | slice a one-bar loop across 16 trigs |
| 0013 | AUDIO ROUTING > DAC SUM; FILTER key, pressed twice | voices summed through the DAC, with a per-sound high-pass |

0000 is the shared code the others call into. It has no controls.

0002 to 0008, 0010, 0012 and 0013 have been verified on hardware. 0009's display has
been checked on the device.

## 0002 - Euclidean accents

Normally the euclidean generator decides which steps play. With this mod it can
instead leave the pattern's trigs alone and mark some of them with ACCENT: the
grid says when, euclid says which hits are accented.

**Use.** On the euclidean page, the Bool Operator (OP) now has eight values instead
of four:

| value | icon | behaviour |
|---|---|---|
| OR, XOR, AND, SUB | stock gate glyph | stock euclidean |
| OR\*, XOR\*, AND\*, SUB\* | the same glyph with a dot, top right | accent mode, same operator |

In accent mode:

- Only steps with a trig in the grid play. Euclid adds nothing.
- A trig on a step where the euclidean pattern has a hit plays accented.
- Accents you set by hand stay; euclid only ever adds accent.
- Turning euclid off with FUNC held bakes the result: the accents are written
  into the pattern. Turning it off without FUNC leaves the pattern as it was,
  as stock does.

The setting is per track and survives save, power cycle and reload.

**On stock firmware** a pattern saved with an accent-mode track loads with euclid
off on that track.

## 0003 - Velocity humanise

Adds a random offset to the velocity of every trig on a track.

**Use.** On the TRIG page, hold FUNC and turn the VEL knob. While FUNC is held
the label reads RND and the knob selects the amount N:

    0, 1, 2, 3, 4, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64

The sixteen settings sit on evenly spaced positions of the knob. Each trig then
plays at its velocity plus a random amount between -N and +N, kept within
1..127. Release FUNC and VEL behaves as stock. N = 0 is off.

The amount is per track and stored with the pattern. It needs 0002, which saves
it; the two are always built together.

**Limitations**

- Editing the amount may not mark the project as modified, so the device may
  not prompt you to save. Save explicitly.

## 0004 - LFO RND

A second LFO page with two random modifiers per sound. On every note trig each
modifier picks a random offset for its destination parameter and holds it until
the next note.

**Use.** Press the LFO page key a second time for LFO RND; press it again to
return to LFO.

| knob | label | setting |
|---|---|---|
| A | DS1 | modifier 1 destination |
| B | DS2 | modifier 2 destination |
| E | DP1 | modifier 1 depth |
| F | DP2 | modifier 2 depth |

A destination knob shows the parameter's short name instead of a dial. Turning it
opens the destination list, as LFO DST does. Pick with the knob, confirm with YES.
The list holds sixteen destinations:

- the eight machine parameters (SRC page), which follow the machine
- FIN, STA (sample)
- FRQ, RES (filter)
- DEC, PAN (amp)
- DEL, REV (sends)

A depth knob selects N from the same sixteen settings as 0003 (0 to 64). Each
note trig offsets the destination by a random amount between -N and +N, clamped
to the parameter's range. The offset is added on top of the parameter's value,
p-locks, slides and LFO 1. Depth 0 is off.

The four settings belong to the sound. They are saved with the kit and survive a
power cycle, and they travel with the sound through copy/paste and the sound
pool. Sounds made before the mod read the first destination at depth 0.

**Limitations**

- Voice tracks only; the FX track has no LFO RND.
- The four settings cannot be p-locked.
- After the sequencer stops, the last offsets stay applied until the next note.
  You may hear this on ringing notes and on pads.
- Pads get no randomisation until the pattern has played at least once.
- A step that plays a sound from the pool (sound lock) uses the kit sound's
  settings.
- A destination is stored as a machine slot. After a machine change it points at
  the same slot on the new machine; where that slot is empty the knob reads `--`
  and the empty slot does not appear in the list.
- Edits may not mark the project as modified. Save explicitly.

## 0006 - Compressor preview

An extra compressor page showing a scrolling estimate of the master compressor's
gain reduction. The Rytm has no gain-reduction meter and nothing in the firmware
measures it, so the mod computes an estimate from the voices, the PRE delay and
reverb returns, master distortion and the compressor settings.

**Use.** On the FX track, the compressor page is on the AMP key. Press AMP again
to switch between the stock page and the preview. The knobs keep their stock
compressor parameters on both.

On the preview page:

| keys | action |
|---|---|
| FUNC + AMP | switch layout: full, or GR alone |
| FUNC + LEFT / RIGHT | slower / faster scrolling |
| FUNC + UP / DOWN | vertical scale: more / less range on screen |

- **Full layout:** the input level as a fill, the threshold as a dotted row, and
  the gain-reduction line dipping below the threshold row as the compressor
  works.
- **GR layout:** the gain-reduction line alone, 0 dB at the top.

Scrolling runs from 4 bars to 1/8 bar across the screen at 130 BPM, starting at
1/2 bar. The vertical scale runs from 0.25 to 4 dB a row, starting at 1 dB. The
screen shows the page you left when you come back to the compressor.

**Accuracy.** On drum patterns at random settings the estimate reads about
1.6 dB rms from the measured reduction, with no overall bias; on a steady tone,
0.56 dB. It is a guide to what the compressor is doing, not a measurement.

**Known limits**

- DIST symmetry (SYM) away from 64 is outside the model.
- Reduction beyond about 36 dB is capped.
- POST delay and reverb returns are not modelled; PRE returns register about
  4 ms early.
- Material whose crest factor is far from the calibration tone's (very spiky or
  very dense) reads off.
- To protect the UI, the estimate pauses when the device is busy (for example
  loading after a pattern change), and stops when the page has not been shown for
  about a second.

With 0013's DAC SUM on, the estimate follows the voices after their high-pass,
as the compressor hears them.

The model and the calibration behind these numbers are in
`re/subsystems/compressor-model.md` and `mods/0006-comp-preview/calibration_report.md`.

## 0008 - Filter frequency in Hz

The FILTER page's FRQ value popup reads as the cutoff frequency instead of
0..127, to three significant figures:

| FRQ | shows |
|---|---|
| 0 | 13.8Hz |
| 60 | 440Hz |
| 76 | 1.11kHz |
| 127 | 21.1kHz |

Each step is one semitone, with 440 Hz at 60.

**Limitations**

- It is the knob's value: filter envelope depth and LFO modulation are not
  included.
- The scale was measured on LP2 with the filter self-oscillating. That the other
  filter types share it is assumed.

## 0009 - Main output level indicator

For gain staging: on the compressor pages, the VOL knob's label is drawn inverted
while the main output is louder than -18 dBFS RMS.

**Use.** On the FX track, open the compressor page (AMP), stock or 0006's preview.
Play the pattern and watch the VOL label: inverted means the output is over the
threshold. It turns off again 1 dB below, so it does not flicker at the edge.

The level is the louder of the two sides, averaged over about 300 ms. A
full-scale square wave reads 0 dBFS and a full-scale sine -3 dBFS.

**Limitations**

- It measures the main output after the compressor, before the MAIN volume knob,
  so the knob does not set it. The knob's position can still shift it by a few
  dB.
- The threshold is set when the firmware is built (`rms_db` in the mod), not on
  the device.
- A label stock already highlights reads normal while over.

## 0010 - Kit A/B

Compare your edits to a kit against the saved version, and go back to your
edits.

**Use.** NO + PLAY, as for a stock reload.

| you press NO + PLAY when | it does | popup |
|---|---|---|
| you have edited the kit | keeps your edits aside and reloads the saved kit | KIT 1 RELOADED! |
| the saved kit plays, untouched since | brings your edits back | EDITS RESTORED! |
| the saved kit plays, but you have edited it | keeps those newer edits instead and reloads | KIT 1 RELOADED! |
| the kit has no edits | a plain reload, as stock | KIT 1 RELOADED! |

The number in KIT 1 RELOADED! is the current kit's, as stock shows it.

Only one set of edits is kept: editing the saved kit while comparing replaces the
edits kept aside. Changing to another kit, or any other reload, does the same.
The kit menu's reload behaves the same way; reloading all kits is stock.

**Limitations**

- The edits kept aside take 2.5 KB of the device's memory from the first press
  until power off.
- After EDITS RESTORED! the kit may not count as modified. Save explicitly.

## 0012 - Slice loop

Set up a track to play a one-bar loop sample as 16 slices, one per step.

**Use.** Select an empty track, FUNC + CHRO, choose SLICE LOOP. On a track with
16 or more steps and no trigs it:

- sets the track's TRIG page defaults to SYN off, SMP on;
- places a trig on steps 1 to 16;
- locks trig n's sample STA to 6(n-1) and END to 6n: 0/6, 6/12 .. 90/96;
- shows LOOP SLICED and closes the menu.

Swing, accents and micro timing then move each slice as they would a drum hit.
Assign the sample before or after; the locks do not depend on it.

**The sample.** The bar must fill 96/120 of the sample, the rest padding, so
that 16 slices of 6 land on the sixteenth notes.

| popup | cause | changes |
|---|---|---|
| LOOP SLICED | done | as above |
| TRACK NOT EMPTY | the track has a trig, lock trigs included | nothing |
| NEEDS 16 STEPS | the track is shorter than 16 steps | nothing |
| ONLY ON SOUND TRACKS | the FX track is selected | nothing |

**Limitations**

- Fixed at 16 slices of 6. Steps past 16 are left empty.

## 0013 - DAC sum and high-pass

Adds a high-pass filter to every voice, after its analog filter, as a second
FILTER page. The Rytm's voices are analog all the way to the mix, so there is
nowhere to put a filter; with DAC SUM on, the voices leave the analog main bus
and reach it again through the DAC, filtered on the way.

**DAC SUM.** In the GLOBAL menu, AUDIO ROUTING, the last item. ON routes every
voice to the main mix through the DAC; OFF is stock. The setting is kept with
the project, like the routing around it, and survives a power cycle.

With it on:

- level and pan are as through the analog path (within about 0.1 dB);
- the voices reach the mix about 2.6 ms later than through the analog path;
- ROUTE TO MAIN and track mutes work as usual;
- the delay and reverb sends, the compressor preview (0006), the sampler and
  the USB track channels all get the high-passed voice. The individual outputs
  do not: they carry the voice before the high-pass.

Switching DAC SUM clicks once.

**HIGH-PASS.** With DAC SUM on, press FILTER a second time for the HIGH-PASS
page. The top-left knob, HPF, sets the track's cutoff: OFF, then 48 steps from
20 Hz to 1.0 kHz, about an eighth of an octave apart. The slope is 6 dB/oct,
with no resonance: -3 dB at the cutoff and flat above it. The popup shows the
cutoff in Hz. With DAC SUM off, pressing FILTER again stays on the stock page.

HPF belongs to the sound: it is saved and loaded with the sound and the kit,
and moves with the sound through the pool and copy/paste. A sound that has
never had it set reads OFF.

**Known limits**

- HPF cannot be p-locked, and has no MIDI CC.
- Saving a sound or kit with stock firmware drops its HPF (it reads OFF).
- A voice driven very hot, with a high cutoff, can clip in the filter.
- The mod takes about 1.6% of the audio processing time with DAC SUM on, and
  about 0.4% more for each pair of voices with an HPF set.

The design and the measurements are in `mods/0013-voice-dac/mod.toml`.

## Returning to stock

Flash Elektron's stock OS 1.73 `.syx` the same way (`docs/FLASHING.md`). The mods
store their settings in bits stock firmware ignores, so projects open on stock
with the mod settings dropped.
