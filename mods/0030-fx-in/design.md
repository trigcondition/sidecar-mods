# 0030-fx-in: the delay + reverb return on Overbridge IN L/R, switched by the Sidecar (2026-10-18)

Status: **built**, emulator only (rytm-emu). Never run on a Rytm. OS 1.73 only.

The Sidecar records the Rytm's 12 Overbridge channels (MAIN L/R, 8 voices, AUDIO IN L/R). With this mod its web UI
can swap AUDIO IN L/R for the Rytm's own FX return (delay + reverb, stereo) at run time, so the FX can be recorded
and scoped as a stem (FX_L / FX_R). Off at every boot: stock's stream.

## Feasibility (the evidence)

Tags as in rytm-mods: **[code]** read in the 1.73 disassembly, **[measured]** in rytm-emu, **[inferred]**.

- **The FX run on the ColdFire, not on a separate DSP.** `fx_generate` (0x4010e650) builds the sends and runs the
  delay (0x4010d3c8) and the reverb, in the audio interrupt [code, 0024 research.md A1; re/subsystems/audio-engine.md:
  the EMAC block loops, no DSP in the self-test]. Their outputs stay separate until the return mixers: `fx_delay_out`
  0x80007c44 and `fx_reverb_out` 0x80007b44, 32 stereo frames each, int32 Q31 interleaved L,R [code]. The return
  mixers (0x4010eb26 PRE, 0x4010ebfe POST) write the DAC words; the analog side mixes them into MAIN.
- **The Overbridge IN frames are the receive buffer verbatim.** `ob_in_write` 0x40005c6e builds the Rytm -> host
  packets: 368 B, a 32-byte header then 7 frames x 12 int32 big-endian, a 16-block ring at 0x80008c00, queued on
  endpoint index 7 [code]. Its only callers are the block driver's `ob_in_write(rx_buffer 0x80007440, 0, 32)` at
  0x4012144c (normal path) and 0x4011fe08 (the hold path) [code]. `rx_buffer`: 32 frames x 12 words, 48-byte stride;
  words 10/11 are AUDIO IN L/R, stored negated from the raw ADC words by 0x4010e944 [code]; a sine into AUDIO IN is
  on channels 10/11 of the stream [measured, 0024 and here].
- **Order in the block** [code]: return mixers (previous block's FX) -> receive copy -> `fx_generate` (this block's
  FX) -> 0x4009ef40 (sampler / meters read the buffer) -> `ob_in_write`. So at the `ob_in_write` call this block's FX
  exists and nothing but the USB copy reads words 10/11 again: overwriting them there changes the stream only.
  Sampling and the analog AUDIO IN path keep the input.
- So: **feasible, directly** - no "MAIN minus dry" derivation needed. Prior work: 0024-ob-mix (branch ob-fx) did
  this as a build param (`fxret`), measured there; 0030 is that mix made switchable at run time and put in the
  Sidecar builds (elekloader area).

## What it does

`fxin_ob` replaces both `jsr ob_in_write` operands (0x4012144e, 0x4011fe0a; from_symbol patches into the area).
Off: one compare and `jmp ob_in_write` (stock). On: words 10/11 of the 32 frames become, per side,
`gd * delay + 2 gr * reverb` (EMAC fractional, saturating; `gd`/`gr` the PRE + POST return gain targets
0x42fb4ab4.. / 0x42fb4abc.., the bank an effect is not in is zero; the 2 is stock's: both return mixers MAC the
reverb twice [code]), then `jmp ob_in_write`. The same 32-frame block as the voices on 2..9: the stem lines up with
the voice stems sample for sample (MAIN's copy of the FX comes later, through DAC, analog mix, ADC; 4 blocks in
rytm-emu). Constant time, no allocation: ~534 instructions a block on (~0.3 % of the CPU), 4 off. MACSR saved and
restored, accumulators left clear, d2-d4 saved.

## The host-link messages (for rytm-teensy `sim/protocol.py`)

| id | direction | message | meaning |
|---|---|---|---|
| `0x26` FXIN | host -> Rytm | `F0 7D 52 54 26 <v> F7` | `v` = 1: FX return on IN L/R; 0: AUDIO IN (stock); 0x7F: ask, no change. Other `v`: ask. |
| `0x27` FXIN_STATE | Rytm -> host | `F0 7D 52 54 27 <s> F7` | `s` = 1 on, 0 off. The answer to every 26 (an ask too), and sent unasked each time the Rytm's USB port comes up. |

- 0x26 / 0x27 were free in every rytm-teensy `sim/protocol.py` (0x25 SLOT_PRINTS is the highest below 0x30).
- **Back to off when the USB port goes down** (host gone, cable pulled, host restarted): a DAW's Overbridge, or the
  Sidecar after a restart, never finds the FX on IN L/R without asking. So the host sends 26 01 after every
  connect if it wants the FX (the unasked 27 00 on connect is the cue), and shows the state from 27.
- The answer comes from the UI task (ev_tick, ~20 Hz) with a try-lock of the MIDI mutex: within ~50 ms, later if
  the USB MIDI ring is busy; never waits.
- On: the recorder's channels 10/11 are **FX_L / FX_R**; off: IN_L / IN_R. Overbridge itself keeps calling them
  Input L/R.
- **Never route channels 10/11 back into the Rytm** (Overbridge host -> Rytm MAIN FX / MAIN inputs): the return
  would feed the return mixers' host term and loop through the effects.

## Hooks, claims

| claim | where | |
|---|---|---|
| patch (from_symbol `fxin_ob`) | 0x4012144e, 0x4011fe0a, expect `40005c6e` | the two `jsr ob_in_write` operands (0024's sites) |
| cave (claim only) | 0x401b9e64, 6 B (cave23's last bytes, after 0026's mailbox) | the switch: u32 `'FXI1'` on, anything else off (stock's bytes `4a816ed8` at boot); u16 request count at +4 |
| ev_tick | `fxin_tick`, order 75 | the 27s, the reset to off on port down |
| 0022-looper `fxin=1` (needs `rui=1`) | the router | writes the switch on a 26: `'FXI0' + v` for v 0/1, the count += 1 always |

The router writes from the MIDI task, `fxin_tick` reads and writes from the UI task, `fxin_ob` reads in the audio
interrupt; aligned long / word stores, one writer at a time in practice (the reset happens only with the port down,
when no 26 can arrive). 0022 `fxin=0` (default) is its router byte for byte as before (the stub's other variants
are unchanged).

`excludes = ["0006-comp-preview"]` (its telemetry/calibration builds write the same words). 0024-ob-mix (not in this
branch) patches the same two operands: the two would collide in the registry.

## Tests (rytm-emu, DTEMU_STRICT=1) [measured]

`tools/emu/us_base.sh rui1024`, then `.venv/bin/python tools/emu/fxin_emu.py rui1024 all`. Simulated USB host
streaming Overbridge (`--usb-host --usb-midi-real --ob-link`), host SysEx in with `--usb-midi` at a fixed clock;
the link client records the IN frames (oblink R) and the Rytm's USB MIDI (M).

| test | checks |
|---|---|
| switch | a -18 dBFS sine into AUDIO IN: on 10/11, gone for exactly the 2.00 s between 26 01 and 26 00 (measured 1.99 s), back; 27 00 (port up), 01, 00, 00 (26 7F) in order |
| delay | 26 01, SD with DEL: echoes on 10/11 (first at 354 ms, correlation +0.62 with the dry hit), the dry hit only on channel 3, nothing on the other voices, stereo; stem energy = the DAC return words' (-8.39 / -8.39 dB) |
| reverb | 26 01, BD with REV: stereo tail on 10/11; stem energy = the DAC return words' (6.46 / 6.46 dB) |
| off | no 26: SD with DEL leaves 10/11 silent; only the 27 00 of the port coming up |
| gone | 26 01, the host browns out and comes back (`--usb-host-gone`): 27 00 unasked after the re-plug, AUDIO IN back on 10/11 |

## Limits / open

- Hardware: never flashed. **Polarity and scale against MAIN are not known for the hardware** (0024 design.md,
  Limits: the null test, delay-only and reverb-only separately). The stem is the DAC-side level, before the analog
  return amplifier. Keep the monitor low on the first tests.
- The master compressor and distortion are not on the stem (they act on MAIN after the analog mix).
- The return level steps once a block (the gain targets, not stock's 32-frame ramp): inaudible for a set level.
- The block driver's hold path (0x4011fe08, while 0x8000e578 != 0) is patched the same way but no emulator run
  enters it (as 0024).
- A 26 that arrives before the first ev_tick after boot is applied but its answer is lost (the port is not up then
  in practice; the unasked 27 on port up covers it).
