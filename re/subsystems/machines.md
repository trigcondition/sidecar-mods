# Machines

How a machine is defined, listed and run, and the 19 machines the firmware carries but
never lists. All addresses are **OS 1.74** (measured 2026-10-01 on the extracted MAIN
OS, sha256 `34cd0c4d...`); the same tables exist in 1.72 and 1.73 at other addresses.

## The machine enum: 53 slots, all used

`machineType_t` runs 0..52. Every per-machine table has exactly 53 entries, and the
per-machine RAM table behind `sound_param_id_for_index` is `0x6a0` B = 53 x 8 longs
**[measured]**. There is no free slot: a new machine has to take over an existing
one. The 19 hidden ones are the candidates.

| table | 1.74 addr | shape |
|---|---|---|
| names | `0x401bf254` | 53 x {long name, short name} pointers; getters `0x40007256` (long), `0x40007276` (short) |
| home + voice mask | `0x401bf42c` | 53 x {int8 home track, uint8 voice mask} |
| engine entry | `0x402906dc` | 53 code pointers into `0x4010ee74..0x4011ef00` |
| parameter records | `0x401bfbc8` | 469 x 0x34 B; a machine parameter's record has the machine index at `+0x00` and its sound index (9..16) at `+0x04` |
| track -> voice | `0x401bf498` | 12 longs: `0 2 7 7 1 3 5 5 4 4 6 6` |
| track -> default machine | `0x401bf3fc` | 12 longs: `0 2 4 6 7 8 8 8 9 10 11 12` |

Physical voice order, from track -> voice: **0 BD, 1 BT, 2 SD, 3 LT, 4 CH/OH,
5 MT/HT, 6 CY/CB, 7 RS/CP**. The masks below are in this order, bit n = voice n.

## What keeps a machine off a track

`machine_on_voice(m, v)` at `0x400070e6` returns `(mask[m] >> v) & 1` for `m <= 52`,
`v <= 7`. It decides both places a machine can appear **[measured]**:

- the list: `0x400bebce` walks m = 0..52 and keeps what it accepts, so
  `MachineListView` (vtable `0x401e5ea4`) only ever shows those;
- the engine: the sound-load paths in the audio code (`0x4011f5c4`, `0x4011f60a`, and
  callers at `0x40120232`, `0x40120602`) test the sound's machine byte (`+0x68`)
  against the track's voice and return -1 when it fails.

So a machine set by other means, for example CC 15 (Track Machine Type), is refused
at load if its mask bit is clear. The masks match the manual's per-track lists
exactly: BD HARD `0x85` = BD, SD, RS/CP; RS HARD `0x80`; BT CLASSIC `0x02`;
XT CLASSIC `0x28`; CH/OH machines `0x10`; CY/CB machines `0x40`; UT NOISE, UT
IMPULSE and DISABLE `0xff`.

## The hidden machines

Machines 34..52 have mask `0x00` and home 0, in 1.72 as in 1.74, so they were not
added for 1.72A's production change. Every one has a full name pair, parameter
records, and a substantial engine routine (70..765 instructions), not a stub
**[measured]**. What they sound like, and whether any of them drives the voice in a
way stock machines avoid, is **not established**: nothing here has run on hardware.

| m | name | short | engine | parameters |
|---|---|---|---|---|
| 34 | BT IMPROVED | BTIM | `0x4011b2e4` | LEV TUN DEC SNP(0..3) NOL |
| 35 | BD HARD 2 | B2HD | `0x4010f9fc` | same eight as BD HARD |
| 36 | BD CLASSIC 2 | B2CL | `0x4010ee74` | TUN LEV HLD DEC SWT SWD WAV TRA |
| 37 | SD HARD 2 | S2HD | `0x40116ec4` | SWD DEC LEV TIC NOD NOL TUN SWT |
| 38 | SD CLASSIC 2 | S2CL | `0x401165e8` | TUN BAL DET DEC NOD SNP NOL LEV |
| 39 | RS HARD 2 | R2HD | `0x40115844` | SWD DEC LEV TIC NOL SYM TUN SWT |
| 40 | RS CLASSIC 2 | R2CL | `0x40115488` | BAL DEC T1 T2 LEV TIC NOL SYM |
| 41 | BD FM 2 | B2FM | `0x4010f3b8` | TUN LEV FMA DEC SWT FMS FMD FMT |
| 42 | RS FM 2 | S2FM | `0x40116a64` | TUN FMA FMT DEC NOD FMD NOL LEV; group name "S2 FM", so probably SD FM 2 mislabelled |
| 43 | FUNC. GEN. | FUNC | `0x401142c8` | Noise Level, Sinus Level, Sinus Frequency, Pulse Level, Pulse Length |
| 44 | BD TEST | BD-T | `0x4011db5e` | BD_TUNE1, BD_TUNE2, BD_LEVEL1, BD_LEVEL2, BD_WAVE1 (0..1), BD_WAVE2 (0..5), BD_FMOD_EN, BD_RMOD_EN |
| 45 | SD TEST | SD-T | `0x4011d2f4` | SD_TUNE1/2, SD_LEVEL1/2, WAV bits "SAW1 SAW2 SINE2" (0..7), FRO bits "FM RM OFS" (0..7) |
| 46 | RS TEST | RS-T | `0x4011d478` | as SD TEST plus RS_RS1, RS_RS2 |
| 47 | BT TEST | BT-T | `0x4011df6c` | BT_TUNE, BT_DECAY, Pulse Level, Pulse Width, BT_BIT (0..1) |
| 48 | LT TEST | LT-T | `0x4011e904` | LT_TUNE, LT_DECAY, Pulse Level, Pulse Width |
| 49 | MT TEST | MT-T | `0x4011de7c` | MT_TUNE, MT_DECAY, Pulse Level, Pulse Width |
| 50 | HH TEST | | `0x401144cc` | HH_TUNE, HH_SELECT (0..3), HH_LEVEL, HH_VCA, HH_MIN, HH_MAX |
| 51 | CY TEST | | `0x4011d620` | CY_TUNE, CY_SELECT (0..2), CY_5ENV1, CY_5ENV2, CY_8ENV1, CY_8ENV2, CY_8ENV3, CY_VCA |
| 52 | CB TEST | | `0x4011d91c` | CB_OSC_SELECT (0..1), CB_5ENV, CB_8ENV, CB_VCA |

The TEST machines' parameter names read as the voice circuits' raw controls, which
makes them the best available inventory of what each circuit can do **[inferred from
names; the engine routines are not traced]**.

## Enabling one

A hidden machine needs its mask bit set, and should get a sensible home track (the
list and default handling read it through `0x40007116`). That is a two-byte
`[[patch]]` at `0x401bf42c + 2m` per machine. Masks by circuit: BD `0x01`, BT `0x02`,
SD `0x04`, LT `0x08`, CH/OH `0x10`, MT/HT `0x20`, CY/CB `0x40`, RS/CP `0x80`; homes are
track indices (BD 0, SD 1, RS 2, CP 3, BT 4, LT 5, MT 6, HT 7, CH 8, OH 9, CY 10,
CB 11).

A kit saved with a hidden machine on a track is refused at load by a stock OS (above),
so that track would not play after going back to stock.

## SY CHIP

Per the manual (OS 1.72, appendix D), SY CHIP is a hybrid. The static waveforms
sine, asymmetric sine, triangle, sinesaw, saw and square, and the ring-modulated
"Anim" variants, are analog; SID-style noise, PWM+/PWM-, the 1..99% pulse and the
noise bursts of the table waves are digital. It is listed on BD, SD and RS/CP
(mask `0x85`), the three dual-oscillator voices, so on RS it plays on the RS/CP voice's
oscillators.

In the firmware its engine routine (`0x40119ffc`, about 860 instructions) is
control-rate code: it calls the same voice helpers as BD HARD (`0x4011e8b0`,
`0x4011e8da`) and reads pitch and arpeggiator-speed tables (`0x401f6848`,
`0x401f6e48`, `0x401f7a48`), with no wavetable **[measured]**. So the arpeggio is
firmware stepping an analog oscillator's pitch. Where the digital waveforms are
produced is **not traced**.
