# 0020-dmach: digital machines through a voice's analog chain

## How it plugs in [measured, rytm-emu, OS 1.73, 2026-10-06]

- **Machine dispatch.** The audio block driver walks the eight physical voices
  (`0x401210e6`); for the machine a voice's track plays (`0x8000ea00[track]`) it
  copies the engine-table entry (`0x4029037c + 4m`) to the voice's routine slot
  (`0x419ca110[v]`) and calls it as `routine(voice, 0x800063c0, track params,
  pitch)` (`0x401211d6`): the params at `0x8000f7ba + 84*track`, the pitch the
  trig's note in 16.16 (60 by default). Every block while the voice plays.
- **Trig.** On a trig the block driver zeroes the voice's state block
  (`0x8000fef8 + 32v`, words 0 and 1; `0x40121064`). Machine routines own that
  block; stock ones park it at -1 when silent.
- **Parameters.** Stored in parameter-index order: record +4 holds 9..16, slot
  0..7 of the track's params. Machine 42 (records 390..397 at `0x401bf918 +
  0x34*i`): LEV TUN DEC FMT FMD NOD NOL FMA. The SRC page shows them in another
  order (TUN FMT FMD DEC / FMA NOD NOL LEV).
- **Pitch.** The dispatcher passes `0x80006388 + 4*track` (16.16) when the
  voice's flag byte (`0x8000ea18[v]`) has bit 0, else 60. Chromatic play and
  MIDI notes 12..59 on the auto channel write that entry: incoming note + 24.
- **Velocity.** A byte per track, the high byte of `0x800067c4 + 2*track`
  (found by diffing RAM between hits at 20 and 127 on SD and 51 on RS); the
  owning track of a voice is `0x40290dd8[v]`. The firmware already scales the
  voice's VCA words (control frame +10/+26) linearly with it.
- **Output.** `voice_output_mix` sends `-(A + B + g*S) >> 8` to the voice's DAC
  channel (rytm-mods voice-controls.md); the engine writes A
  (`0x80006bf8 + 128v`, 32 Q31 samples), zeroes B (`0x80007040 + 128v`) and g
  (`0x80007000 + 8v`), and sets the dual-oscillator voices' LEVEL CVs to 0.

## The engine

`efm.c`, compiled to `stub.s` by `build.sh` (m68k-elf-gcc 16.2, `-mcpu=5475
-msoft-float -O2`; no library calls). The phase-modulation core follows
Mutable Instruments Braids' `RenderFm` (MIT); envelopes are per-block exponential
decays interpolated across the block, the noise a 32-bit LFSR. 2672 bytes in
cave12 (0x400279c4), no RAM: the state is the voice's own 32-byte block.

## Checked in the emulator

- With 0014-hidden-machines' variants gate, SD's machine list shows "RS FM 2"
  (machine 42); selecting it sets `0x8000ea00[1] = 0x2a` and the defaults read
  LEV 100, TUN 52, DEC 64, FMT 88, FMD 64, NOD 32, NOL 64, FMA 127.
- `efm_render` runs every block (4500 calls in 3 s) and a SD hit through SD's
  modelled analog chain peaks about 3300..3900 and falls 20 dB in 0.16 s.
- Standalone (rytm-emu cfbench): about 3050 instructions a 32-sample block (95 a
  sample); with FMA and NOL at 0 and TUN 52 the carrier measures 185.1 Hz (F#3,
  185.0).

- Velocity (0..127 -> 0.375..1.0) scales FM depth and noise, stored at the trig
  in the state block's last word. Through the firmware, SD at velocity 20 peaks
  733 with a brightness (difference energy over energy) of 0.19; at 127, 4421 and
  0.51. Chromatic notes 24 and 48 (MIDI, auto channel) measure 92.5 and 369.2 Hz:
  F#2 and F#4, the note + 24 with TUN 52 six semitones down.
- 2866 bytes with velocity; the cave claim is 3200.

## Not established

- Anything on hardware: none of this has run on a Rytm.
- Whether the digital layer passes the voice's analog filter on hardware is
  [inferred] in voice-controls.md; the emulator models it that way.
- On BT/LT/MT/CH/CY voices the analog parts are not muted (machine 42 is only
  listed on BD, SD and RS/CP).

## More engines (2026-10-06)

`dmach.c` now holds four engines on hidden machines with BD/SD/RS masks, sharing
the tables and glue (`begin`: buffers, analog mute, trig, velocity):

| machine | engine | stored params | idea |
|---|---|---|---|
| 42 | EFM  | LEV TUN DEC FMT FMD NOD NOL FMA | two-operator FM drum |
| 41 | FMBD | LEV TUN DEC FMA SWT FMS FMD FMT | FM kick, pitch sweep FMS over SWT |
| 39 | GND  | LEV TUN DEC SWD TIC NOL SYM SWT | swept sine, click, noise, SYM shapes toward square |
| 38 | SWAV | LEV TUN DEC DET SNP NOD NOL BAL | five detuned saws, low-pass (SNP + velocity), breath noise |

Compiled `-Os` to fit the pools (each engine in its own section: `.fmbd`, `.gnd`,
`.swav`; names without the `.text.` prefix, which the linker would merge into
.text): .text 1836 B (common + EFM), .fmbd 522, .gnd 592 in cave12; .swav 816 in
cave23. Instructions per sample (cfbench, 4 blocks after a trig): EFM 116, FMBD
93, GND 85, SWAV 98 (-O2: 97, 68, 75, 103).

Checked in rytm-emu: MIDI CC 15 (machine type) on the track channel switches SD
to 38, 41, 42 and RS to 39; each routine then runs every block and a hit sounds:
SWAV 185 Hz, FMBD settling to 114 Hz, EFM 185 Hz, GND 257 Hz at the kit's
defaults. The machines keep their stock names and knob labels for now.

## FM4: a four-operator FM voice on machine 35 (2026-10-07)

(Stale since 2026-10-10: 0014's variants gate lists only BT IMPROVED now - 35..42 are 0021-ext's user slots,
6-OP FM, JUNO and DIGIDRUM, and 0021 excludes 0020 - so in a 0020 build machines 35, 38, 39, 41 and 42 keep mask 0:
unlisted, refused at sound load [measured: the masks at 0x401bf17c + 2 m in a `dm` build, 2026-10-11]. 0020 would
need its own mask patches to list them again. The text below describes the build as it was.)

Machine 35 (BD HARD 2; listed on BD, SD and RS/CP by 0014's variants gate) runs
`fm4_render`: four sine operators, eight routings (the classic four-operator
set: 4>3>2>1, (3+4)>2>1, 3>2>1 + 4>1, 4>3>1 + 2>1, two stacks, 4 into three
carriers, 4>3 + two carriers, four carriers), feedback on operator 4 (averaged
over its last two outputs). Operator 1 plays the note; 2 runs at ratio RTA with
level IXA; 3 and 4 at RTB with level IXB. One modulator envelope decays with DEC
(127 holds); IXA follows it, IXB its square, so B fades twice as fast. Velocity
scales both levels. It has no amp envelope of its own: the voice's AMP page
shapes it, as on an FM synth with a separate amp envelope.

| slot | stock | now | range | default |
|---|---|---|---|---|
| 0 | LEV | IXA "Index A" | 0..127 | 64 |
| 1 | TUN | TUN | 0..127 | 64 (the note) |
| 2 | DEC | DEC "Mod Decay" | 0..127 | 72 (about 0.3 s) |
| 3 | HLD | IXB "Index B" | 0..127 | 32 |
| 4 | SWT | RTA "Ratio A" | 0..21 | 3 (1:1) |
| 5 | SNP | RTB "Ratio B" | 0..21 | 5 (2:1) |
| 6 | WAV | ALG "Algorithm" | 0..7 (stock 0..2) | 0 |
| 7 | TIC | FB "Feedback" | 0..127 | 0 |

Ratios per step: 0.25 0.5 0.75 1 1.5 2 2.5 3 3.5 4 4.5 5 6 7 8 9 10 11 12 13 14 16.

The parameter records (`0x401bf918 + 0x34i`) hold min at +0x08, max +0x0c,
default +0x10 (8.8) and the long/short name pointers at +0x28/+0x30 [measured:
the stored defaults 64 3a 2f 28 5a 06 00 40 are what a selection loaded, and WAV's
max 2]. The registry patches those and the machine's name pair (`0x401befa4 +
8m`) to strings in `.fm4d`. tools/build.py now also resolves read-only data
symbols (nm type R) for `from_symbol`.

Budget: no RAM (state in the voice's 32-byte block: four phases, the envelope,
two feedback samples, velocity); code 1049 B (`.fm4`) and 136 B of tables and
names (`.fm4d`) in cave16. About 152..158 instructions a sample (cfbench, -Os),
against roughly 1800 spare a sample measured in the emulator: three FM4 voices
take about a quarter of the spare budget. Real hardware may need up to twice the
emulator's cycles per instruction.

Checked in rytm-emu: CC 15 = 35 on BD's channel selects it; the machine list and
SRC page show FM4 and TUN RTA RTB DEC / ALG IXB FB IXA (ALG keeps WAV's
switch-style widget; it steps 0..7 and stops at 7; the header shows the long
names); defaults load as patched. At the defaults a BD hit plays C4 (261.7 Hz),
velocity 100 vs 64 moves the spectral centroid 2611 vs 1750 Hz; algorithm 7
sounds. Not on hardware.

## FM4 page 2, on the SMPL page (2026-10-07)

A digital machine mutes the sample layer, so the SMPL page's eight values (the
track's slots 8..15, indices 17..24, stored right after the machine's eight
[measured: the track block holds 64 64 0 0 0 120 0 100 there]) are free. FM4 reads
them as a second page:

| slot | SMPL | FM4 | range | at the SMPL default |
|---|---|---|---|---|
| 8 | TUN | DTN detune ops 2..4 | 0..127 | 64: none |
| 9 | FIN | PSW pitch sweep with env A | 0..127 | 64: none (127: +63 semitones) |
| 10 | SMP | ATK attack of both mod envelopes | 0..127 | 0 |
| 11 | BR | END sustain level of the mod envelopes | 0..127 | 0 |
| 12 | STA | DCB decay of B | 0..127 | 0: twice as fast as A |
| 13 | END | VEL velocity to modulation | 0..127 | 120 |
| 14 | LOP | RTC carrier ratio (1, 0.5, 2..8) | 0..8 | 0: 1 |
| 15 | LEV | LEV output level | 0..127 | 100 |

A machine change does not reload the SMPL values, hence controls that are neutral
at SMPL's defaults.

How the page is relabelled [measured, disassembly and rytm-emu, 2026-10-07]:
- Pages take their records from a static table, page_info(id) at 0x400ff574 =
  0x4028843c + 36 id: {title, eight record numbers in display order}; ids 4 and 5
  are SMPL (39 40 42 41 43 44 45 46). Machine pages come from 0x400ff59a (0x40287cc8
  + 36 m) instead. The parameter-page view's generic methods read the table:
  record(view, k) 0x4003795a and title(view) 0x4003793c (shared by the six page
  classes whose vtables hold them; slot 0x68 is the page id).
- Both are replaced whole (detours, rejoin none). On ids 4/5 they find the view's
  machine the way the SRC page's record method (0x400d3544) does (vtable 0x90, then
  the sound from the view's track +116/+120 or slot +104, then 0x400bca70) and, for
  machine 35, answer records 449..456 and the title "FM4 PAGE 2".
- Records 449..456 were CY TEST's (machine 51); they are rewritten as SMPL-page
  records (machine 54, indices 17..24, FM4's names and maxima, CC/NRPN fields -1).
  So 0014 must be built with test=0. sound_param_record(index, machine) at
  0x40007028 is replaced too (the boot scan files the new records into its SMPL
  table; it answers them for machine 35 and the stock 39..46 otherwise).

Checked in rytm-emu: with FM4 on BD the SMPL page reads "FM4 PAGE 2" DTN PSW END
ATK / DCB VEL RTC LEV; switching BD back to BD HARD shows the stock SAMPLE page.
Turning RTC stops at 8; PSW 127 with RTC 8 sweeps the pitch down to 3327 Hz at
600 ms (8 semitones above 8 x C4, as the envelope predicts). Cost unchanged, about
155 instructions a sample; the page hooks run only when the UI asks.

Build: `.venv/bin/python tools/build.py --tag dm --mods 0000-shared
0014-hidden-machines 0020-dmach --param 0014-hidden-machines:variants=1 --param
0014-hidden-machines:funcgen=1 --param 0014-hidden-machines:test=0` (funcgen=1
explicit since 0014's defaults went to 0, 2026-10-09).

## FM4: sleep, smoothing, retrigger crossfade, half rate (2026-10-07)

Ideas taken from DT-FM (github.com/mtalikka/DT-FM, MIT; Digitakt MK1), FM4 keeps
its Digitone-style A/B envelope grouping.

- Sleep: FM4 reads its voice's AMP envelope record (control frame +168 + 8v) each
  block. When the target is at or below 0 and the envelope is ramping (rate bit 20
  set, or ramp mode 9/B/F; the rate itself is the low 20 bits, as the OS's encoder
  0x4011e7ae writes them) it accumulates the ramp's travel; after 160 levels it
  fades over 128 samples and parks the voice (state word -1) until the next trig.
  A hold (mode 3) or bit 20 clear (AMP DEC infinite: the release record is all
  zero) never sleeps [records measured in rytm-emu]. Checked: with AMP DEC turned
  down the voice parks within 0.25 s and the output is silent; the tail decays
  smoothly to -48 dB (the analog model's amp floor) before it stops; with the
  kit's infinite DEC it keeps running and sounding.
- Smoothing: IXA, IXB, FB and LEV slew a quarter of the way each block (IXA
  0 -> 127: 64, 112, 148, 175, 195, 210 ... of 254); levels ramp within the block.
- Retrigger crossfade: a trig over a sounding note fades from its last sample over
  32 samples. Checked on the CPU core: without it a retrigger jumped 23757 ->
  -6053; with it the output continues from 23757.
- Half rate (mod param fm4_half=1): 16 samples at 24 kHz, linearly interpolated.
- The algorithm switch became routing masks (fm4_route), and block-rate work moved
  to fm4_prep, so FM4 spans three caves: .fm4 (the sample loop, 1346 B) and .fm4s
  (8 x 32 B of state, zero at load) in cave16, .fm4h (fm4_prep and the page hooks,
  1650 B) in cave11, .fm4d (tables and names) in cave19.
- Cost (cfbench, 32-sample block): 5168 instructions (161 a sample; 148..155
  before); half rate 3189 (100 a sample). The sleep makes a released voice cost
  only begin()'s buffer clears.
