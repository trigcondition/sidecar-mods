# 0021-ext: an external voice machine for an Overbridge host

## Idea

A Teensy (or any host) on the Rytm's USB port plays the voices: the Rytm sends trigs
and knob values over MIDI, the host renders and returns audio on Overbridge's
per-voice inputs, and the Rytm plays that audio through the voice's own analog
filter, overdrive and amp. The Rytm side needs a machine that keeps the voice's
analog source silent and offers knobs that reach the host. No DSP on the Rytm.

## Facts it rests on [measured, OS 1.73, disassembly and rytm-emu, 2026-10-07]

- `voice_output_mix` (0x4010ea2c) adds each voice's Overbridge input channel into
  the voice's digital layer at a fixed weight (0.5) every block, from a double
  buffer at 0x42ac6f30 (index 0x8000fef4); the voice -> channel table 0x401bea90
  `[4,7,5,8,10,9,11,6]` matches Overwitch's per-voice inputs
  (rytm-teensy docs/overbridge-voice-inputs.md).
- The stock DISABLE machine (27, every voice) silences the voice's own source, and
  a voice on DISABLE still plays its Overbridge input while triggered: in rytm-emu
  a 220 Hz sine on BD's input was silent before the hit, played from the hit and
  stopped as the amp envelope closed after the release; without the input the
  voice was silent throughout.
- Machine parameters carry MIDI numbers in their records (+0x18: CC 16..23 by
  slot; +0x1c: NRPN 1:0..7); the stock MIDI out sends them when parameter output
  is enabled (GLOBAL > MIDI CONFIG). With the card used here it was off: turning a
  knob sent nothing, and pad hits sent notes on the auto channel (`9D nn`, nn the
  pad).

## The mod

Machine 44 (BD TEST, hidden; 0014 must be built with test=0, the build refuses the
overlap otherwise):
- engine entry -> `ext_render` (ext.c): DISABLE's routine (0x40113efc), then the
  report to the host (below);
- list entry home -1, mask 0xff (every track);
- names EXTERNAL / EXT; records 408..415 rewritten as ordinary machine parameters
  P1..P8 (0..127, default 64, CC 16..23, NRPN 1:0..7, group "EXT");
- its SRC page lists them in order (0x402882f8).

Checked in rytm-emu: CC 15 = 44 sets BD and the CH track to EXT; the SRC page shows
P1..P8; with a sine on CH/OH's input (channel 10) the CH voice plays it while held
and is silent otherwise; without the input it is silent.

## The report: trigs and P1..P8 as SysEx (2026-10-08)

The Rytm's sequencer sends no MIDI notes for its trigs (manual: OUTPUT CH covers
"the [PADS] and the knobs"; in rytm-emu, PLAY sent 0 bytes with every MIDI
setting), so a host never hears the pattern. `ext_render` reports instead, over
USB MIDI, which keeps running in Overbridge mode:

    F0 7D 52 54 04 <voice> <note> <vel> <P1..P8> F7   a trig, with its parameters
    F0 7D 52 54 03 <voice> <P1..P8> F7                P1..P8 changed

(rytm-teensy sim/protocol.py). Each P is 14-bit, two bytes: the value 0..127,
then the top 7 bits of its fraction (the stored parameter's low byte, which
slides and the LFO move). The parameters travel with the trig, so p-locks
land on their step; the parameter block the engine gets (0x8000f7ba + 84t) is the
modulated one, so the LFO reaches the host too [measured, rytm-emu: LFO DEST CC
105 = 9..16 is SYN1..8; at full depth P1 covered 0.000..127.992 in 1/128 steps,
15355 distinct values over about 3 s].

- Trig: the firmware zeroes word 0 of the voice's state block (0x8000fef8 + 32v)
  on every trig (the 0020 engines rely on it). DISABLE's routine clears the
  voice's buffers while that word is zero and never sets it, so `ext_render`
  keeps it zero while DISABLE runs and 1 between blocks: zero on entry is a trig.
  (The amp envelope's start command, tried first, caught only the first trig.)
- Note: the engine's pitch argument (16.16, integer part); velocity: the owner
  track's (0x800067c4 + 2t via 0x40290dd8[v]).
- Sending from the audio interrupt [measured, OS 1.73 disassembly]: the USB MIDI
  sender 0x400029e0 `(len, data)` copies into a 4 KB ring (0x4b80c000, fill
  0x413db258) and returns at once when no host has configured the port
  (0x413db254 != 1). Task callers hold the mutex at 0x42f67a28 (take 0x40002914,
  give 0x40002924), and its SysEx state is 0x413db244. `ext_render` calls it only
  with the mutex free, no SysEx half sent and the ring under 3800 bytes (the
  sender spins when full); otherwise the message stays pending for the next
  block. A trig and its parameters always go together.
- Cost: P1..P8 compare plus at most one 23-25 byte message per voice per block
  (under an LFO: 1500 a second, about 35 KB/s per voice).
  Code 581 B in 0x400bb15c (names included), state 304 B in cave24.

Checked in rytm-emu (dtboot, DTBOOT_USB_OUT): about 40 trig reports a second from
the sequencer's default pattern on two EXT voices, with the pad hit too; no faults.
Not checked: a real USB host on the port (the emulator takes the sender's calls
itself), and how the OS paces the ring under load.

Open: P1/P2 draw as centre dials and P7/P8 as switches (BD TEST's widgets come from
somewhere other than the records); a second page (SMPL) like FM4's.

## The knobs as Plaits parameters (2026-10-08)

ENG (0..127 in 24 equal zones, model = value x 24 / 128, its name shown while turning), HRM, TIM, MOR, DEC, LPG
(0..127), TUN (32..96, semitones from 64), LEV (0..127, default 100). Records:
ranges and names. Look: each record has a descriptor built at boot at
0x419a4888 + 84 x record [measured, OS 1.73]: flags and a style, then
std::function slots (storage, 0, manager, invoker) - +20 the value text
(param_value_text, 0x400a85e0, looks the descriptor up by record and jumps to
+32 with (functor, value 8.8, string); +36 the widget. They are shared by type,
not per record (plain dial: 238 records), and hold no record data, so a knob
looks like another record by copying its descriptor: ENG and HRM from P3 (plain
dial), TUN from BD HARD's TUN (centred dial, +-), LEV from BD HARD's LEV
(fader); ENG's text invoker is then ext_engine_text (the model's name through
the OS's string printf 0x40098602). BD TEST's own were bipolar P1/P2 and list
switches P7/P8. Done once at the first param_value_text, in the UI task, after
boot built the table [measured: a descriptor changed after boot takes effect when
the page is drawn; the copy from the audio engine never ran before a trig].
Checked by screenshots: dials, a centred TUN, a LEV fader; turning ENG shows
ENGINE / HARMONC.

## Page 2 (2026-10-08)

On an EXT track SMPL shows EXT PAGE 2: TMD MMD FM AUX /
FIN VEL GLD VOL - Plaits' internal-envelope amounts to timbre, morph and pitch,
the OUT -> AUX crossfade, fine tune, velocity sensitivity, glide and output gain.
They live in the sound's sample words (17..24), so they are stored, p-locked and
LFO'd as stock's sample parameters are, with the sample words' defaults (64 64
0 0 0 120 0 100); EXT mutes the voice's sample layer (sample gain 0x80007000 +
8v) since TMD sits in the sample-select word. RS TEST's records 422..429 are
rewritten for them (machine field 0x36 and SMPL's ids, as FM4's page 2), and
three lookups are replaced whole: a page's record (0x4003795a) and title
(0x4003793c) answer them on SMPL (page ids 4/5) for machine 44, and
sound_param_record (0x40007028) maps sample words 17..24 on machine 44 to them.
Their looks are copied from SMPL FIN (bipolar FM and FIN), P3 (dials) and BD
HARD LEV (VOL's fader). The report carries P1..P16 (41- and 39-byte messages).
SMPL is the only way in: a key hook turning a second SRC press into SMPL (0022,
cave20) was built and then removed at the user's request (2026-10-08), so a
second SRC press opens the machine list as stock. Checked by screenshots.

## PLAITS and DAISYSP (2026-10-08)

EXT is renamed PLAITS (long PLAITS, short PLTS; page 2 "PLAITS PAGE 2"). A
second machine, DAISYSP, is CY TEST (51) taken over the same way: engine entry
ext_render, home -1 and every voice, long DAISYSP / short DSP, records 449..456
(CY TEST's, slots 9..16; its SRC page already lists them in order) rewritten as
ENG STR BRI DMP ACC EXC TUN LEV (ENG 0..127 in four model zones: MODAL STRING
RESON DRIP, named while turning by dsp_engine_text; TUN 32..96; LEV default
100). ext_render looks up the voice's owner track's machine (0x8000ea00[t]) and
sets 0x10 in the reported voice byte for machine 51; only PLAITS mutes the sample
layer, so DAISYSP keeps stock's SMPL page and its samples play. Code in cave20
(.ext5 code 142 B, .ext6 names 108 B; free again since 0022's SRC toggle went).
Checked in rytm-emu: FUNC + SRC lists PLAITS and DAISYSP; CC 15 = 51 on SD shows
the DAISYSP page with its looks; ENG at 64 reads RESON; a SD hit reports voice
0x12, a BD (PLAITS) hit voice 0x00. Not handled: on a voice two tracks share
(CH/OH, CY/CB, ...), the flag follows the voice's owner track's machine.

### DAISYSP's INP: an analog voice as the exciter (2026-10-08)

Slot 4 (record 453) is INP instead of ACC: INT (the host's built-in strike) or
an analog voice, BD SD RS/CP BT LT MT/HT CH/OH CY/CB, in nine zones of 0..127
(dsp_input_text; default 7, INT). The host takes that voice's Overbridge output
(Rytm -> host channels 2..9 in track order [measured in rytm-emu: one pad at a
time, each lit only its channel]) as the resonator's input; EXC is then its gain.
In rytm-emu the per-voice channel is taken before the track's volume (BD VOL 0:
main silent, BD's channel unchanged) [measured, emulator model; to check on a
Rytm], so a voice can excite DAISYSP without being heard dry. The DAISYSP track
still needs its amp open (a trig; AMP DEC at infinite keeps it open).

### NAT and NOISE: the track's own voice as the exciter; the EXCITER page (2026-10-08)

INP now has eleven zones: INT, NAT, NOISE, then BD..CY/CB. With NAT (the track's
default machine, 0x401bf14c[track]: BD HARD on BD, SD HARD on SD, ...) or NOISE
(UT NOISE, 15), ext_render runs that machine's engine (0x4029037c + 4m) on the
voice instead of DISABLE's, with a parameter block of its own (dsp_excite): the
machine's record defaults (0x413db5fc[8m + slot - 9] -> record +16; range +8/+12)
with slots 9..13 (level, tune/tone/LPF, decay, then two of its own - the same
layout on every native machine) from the page's X knobs. The voice then sounds
as that machine, and its Overbridge output excites the host's resonator.
UT NOISE plays through the sample layer's gain, so the layer is left on for it.

DAISYSP page 2, EXCITER, on SMPL (records 430..437 = BT TEST 430..434 and LT TEST
435..437, rewritten as sample words 17..24): OUT (VOICE/MAIN), FB, XLV XTN XDC
XP4 XP5, WID. The sample words keep their values when the machine changes, so
each knob sits on the word whose stock default suits it (17 XTN 64, 18 XDC 64,
19 FB 0, 20 OUT 0 = VOICE, 21 XP4 0, 22 XLV 120, 23 XP5 0, 24 WID 100) and is shown
in the order OUT FB XLV XTN / XDC XP4 XP5 WID [measured: with XLV first put on
word 19 the exciter played at that word's value, 0, and was silent]. The sample
layer is now muted for DAISYSP too (except under NOISE).

OUT=VOICE: a voice's Overbridge output carries what the host sends back to it
[measured in rytm-emu: a sine sent to BD's input came out on BD's output, 5950
peak], so with NAT/NOISE the resonance goes round through the voice's analog
filter and amp - a feedback loop, kept by FB (the host cancels the rest).
OUT=MAIN: the resonance goes to MAIN, no loop.

Checked in rytm-emu (DAISYSP on SD): NAT puts SD HARD on SD's output (27996 peak
on a hit), NOISE UT NOISE (2934, decaying), INT nothing; 0021 now excludes
0020-dmach (same lookups) and uses its cave16.

## DSP SAMPLE: a sample as the exciter (2026-10-08)

Machine 45 (SD TEST) becomes DSP SAMPLE (short DSPS), on every track: ext_render
with DISABLE's engine (the analog source off) and the sample layer left playing,
reported with 0x20 in the voice byte. The SMPL page is stock's (the sound's own
sample); the SRC page holds the resonator: ENG STR BRI DMP OUT FB TUN LEV, on
records 416..419 (SD TEST's slots 9..12), 439/440 (MT TEST's, re-owned as slots
13/14) and 420/421 (slots 15/16), listed in that order on machine 45's page
(0x40287cc8 + 36 x 45). The host rings the resonator with the voice's own
Overbridge output - the sample - and routes the resonance by OUT/FB as on
DAISYSP's EXCITER page.

Checked in rytm-emu on a card with TESTSINE loaded into the project (GLOBAL >
SAMPLES > incoming > tick > LOAD TO PROJ): SD on DSP SAMPLE with the sample on
slot 1 puts it on SD's Overbridge output (5934 peak), with no sample nothing
(the analog source is off); trigs report 0x22; the SRC page shows the resonator
knobs and SMPL the stock sample page (SMP 5 etc.).

### DSP SAMPLE plays the host's card samples (2026-10-08)

The round trip (the Rytm's sample out to the host and its resonance back) was
audible as a delay between dry and wet. DSP SAMPLE's SMPL page is now SD SAMPLE:
records 441..448 (MT TEST 441/442, HH TEST 443..448) as copies of stock's sample
records 39..46 (words 17..24, their ranges, defaults and CCs), word 19 SMP the
file and word 20 (stock's BR) FLD the folder on the host's card, both shown as
plain numbers, laid out as stock's page (TUN FIN FLD SMP / STA END LOP LEV). The
host plays that file straight into the resonator; the Rytm's own sample layer is
muted again. SRC knob 5 is MIX (dry/wet, default 64) instead of OUT: the sound
always returns through the voice; FB still loops the voice's output back in.
0021's build.sh adds -fno-tree-switch-conversion (a switch table landed in an
unclaimed .rodata). Checked in rytm-emu: both pages; trigs report 0x22 with
P9..P16 = the page's words.

### Names from the host's card on FLD and SMP (2026-10-08)

The host sends names; the Rytm caches and shows them. Messages:
`09 <list> <folder>` (Rytm -> host: the folder list, 0, or one folder's files, 1)
and `0A <list> <folder> <first> <total> <n x 13 chars>` (host -> Rytm, 8 names a
message). Two caches of 128 x 14 B: the folders in dsp_mailbox (cave12, at the
fixed address 0x400279c4: magic 'NAME', the handler, both lists' state and
titles, the folder names) and one folder's files (cave11). 0022's router hands
commands 0x0A.. to the mailbox's handler when the magic is there (0022 alone:
nothing). The value texts of FLD and SMP ask for a list they lack (from the UI
task, the MIDI sender's mutex held, re-asking after ~200 redraws) and show the
name on the knob, about 7 characters visible [measured]. The title is drawn
before the value text runs - a title set there shows the previous step's name
and stays so when the knob stops [measured] - so it only carries what a turn
does not change: SMP's long name points at a buffer holding the folder's name,
FLD's at "FOLDER". The host puts the distinctive part of a folder's name first
("CH TR808"). Checked in rytm-emu with the host's messages injected as USB MIDI:
turning FLD shows FOLDER over the folder's name on the knob, turning SMP the
folder over the file's name; the Rytm asks once per list.

### Walking the card as a tree (2026-10-08)

A 32 GB card with 311 folders (some over 128 files) does not fit two flat
0..127 knobs. The host now keeps a place on the card per track: FLD steps
through the subfolders of the track's folder, YES on the SD SAMPLE page goes
into the one shown and NO up a level (0022 sends 0B/0C <track>; not the knob
push - rytm-emu's window pushes a knob whenever it is grabbed), SMP picks a file
in the folder reached. The name caches are per track (09/0A carry the track);
list 2 is the folder's own name, SMP's title; a list starting at entry 0
replaces the old one. The host sets FLD back to 0 (CC 26 on the track's
channel) after a move. The place lives on the host (in memory for now; kept
per project later, with the sample pool). Checked in rytm-emu: YES and NO send
0B/0C for the selected track, FLD shows the injected root folders (Synths/).

## DIGIDRUM, and PLAITS without its drums (2026-10-09)

Machine 42 (RS FM 2, one of 0014's hidden "2" variants; 0014 no longer lists it)
becomes DIGIDRUM (short DDRM) for the host's DIGIDRUM voices, soejrd/digidrum's
Machinedrum-style TRX and EFM machines (MIT; rytm-teensy sim/digidrum): engine
entry ext_render, on every track, reported with 0x40 in the voice byte. SRC:
records 390..397 (RS FM 2's, slots 9..16) as ENG and the engine's controls 1..7
(control 8 stays at the engine's default on the host: no spare records for a
page 2). ENG is 0..127 in 16 zones (TRX-B2, TRX SD CH OH CY RS CB CL, EFM BD SD
XT CP RS CB HH CY); its value text names the engine and points records
391..397's names at that engine's control names, so knobs 2..8 read PTCH DEC
RAMP .. for TRX-B2, GAP DEC HPF LPF MTAL for TRX-CH. The sample layer is not
muted: the SMPL page is stock's and the sound's sample plays under the drum.
PLAITS's ENG is 21 zones (models 0..20); its drums are left to DIGIDRUM.
Code in cave9's unclaimed tail (.exte names 325 B, .extd code 242 B) and
cave12 (.extg engine names 112 B). Checked in rytm-emu: DIGIDRUM on BD, CH, LT,
RS/CP lists (RS FM 2 gone); labels change with ENG without lag, 4 characters
drawn whole; a hit reports 0x40 with P1 = ENG; the sample-gain zeroing skipped
for DIGIDRUM (its sound had no sample to hear); PLAITS 127 reads MODAL.

Next (planned): a 6-OP FM machine split from PLAITS (another "2" variant's slot
and records), its PATCH knob picking DX7 voices from the Teensy's card - banks
indexed with an MD5 each, a per-project FM list like the sample pool, voice
names shown as SMP's are, the other knobs offsets on the loaded voice.

## JUNO (2026-10-09)

Machine 41 (BD FM 2, another of 0014's hidden "2" variants, no longer listed
there) becomes JUNO for the host's Juno-106 voices (rytm-teensy sim/juno: our
own float voice on AMY's 106 model - its factory patches as the 106's 18 sysex
bytes and its slider curves, MIT). ext_render, reported with 0x08 in the voice
byte, on every track, the sample layer muted. SRC: records 382..389 (BD FM 2's,
slots 9..16) as PAT CUT RES ENV ATK DEC REL LEN: PAT the factory patch 0..127
named as the 106's buttons (A11..B88, jn_patch_text), CUT..REL offsets on the
patch's sliders (64 = the patch; centred dials), LEN the gate (the Rytm sends
trigs only; 127 = until the next trig). Names set by jn_descriptors at the
descriptor rewrite. Code and names in the unclaimed tails of cave19 (.extj),
cave21 (.extl), cave22 (.extk) and cave8 (.extm). Checked in rytm-emu: JUNO and
DIGIDRUM in the BD and SD lists (BD FM 2, RS FM 2 gone); PAT reads A11 A26 A88
B11 B88 at 0 13 63 64 127; a hit reports 0x08 with the note and P1 = PAT;
DIGIDRUM's per-engine labels leave JUNO's alone.

## Note-offs (research 2026-10-09; built and tested in rytm-emu the same day)

The Rytm keeps three "held note" slots per track, int32 gate[13][3] at
0x8000fe58 (12 bytes a track; init -1 at 0x4011f974) [measured, rytm-emu lp3]:
slot 0 live play (pads, MIDI in: the note while held, -1 on release), slot 1 the
sequencer (grid trigs, p-locked LEN, live-recorded trigs: the note for the
trig's LEN, then -1), slot 2 a fourth source (never seen set). At most one slot
is set per track. Updated in the audio ISR 0x4011fafa before the engines run
(trigs/note-offs from 0x4011febe, countdown 0x40120b14, engines 0x4012110c),
so ext_render sees this block's gate. LEN countdown: 0x8000fc24[t], loaded with
~LEN x 2,700,000, minus *(int32*)0x40287c9c (BPM x 120) a block; gate time =
LEN to within one block (0.67 ms) [measured: .125, .75, 1/16, 2.4, 6.5 steps];
INF never closes, not even at STOP. (This note first named a play state at
0x41329b54, a typo for 0x41329c34; that word reads 1 while playing but drops to
3 within steps, so it is not a transport flag. The flag is 0x405c8c90, below.) A retrig or a new trig
while open restarts the countdown, the slot never drops between. Voices shared
by two tracks: gates are per track (OWNER per voice); remember the last owner
and close the old track's note when it changes. Stock engines get no gate in
their call; the amp record (frame + 168 + 8v) releases with the gate only at
AMP HLD AUTO.

Plan: per voice, open = any of the owner track's three slots != -1 (slot 1
counted only while 0x41329b54 == 1); on open -> closed send
F0 7D 52 54 11 <voice byte> F7 (retry while the sender is busy). The Teensy's
JUNO releases on it; LEN 127 (the new default) = follow the Rytm's note length.
.text is full (754 of 758 B): the check goes in its own section (cave16's 98
unclaimed bytes at 0x400b21c8).

Built (2026-10-09): ext_gate (ext.c, in cave12's .ext9 with ext_try_send, which
moved there from .text to make room for the call; .text 710 B now). Open = slot 0
or 2 set, or slot 1 while 0x405c8c90 != 0: 1 from PLAY to STOP, 0 when stopped
and after a double stop; the word after it counts steps [measured, rytm-emu lp3n:
the only stable word over 0x40280000..0x40800000, 0x41000000..0x41a00000,
0x42a00000..0x43000000 and SRAM across 16 snapshots, then sampled every 10M
instructions through play/stop/stop]. The voice byte is the plain voice (0..7).
A note-off waits while the voice's trig message is still pending (never ahead of
its trig) and is dropped when a trig reopens the gate first. Not tracked: the
last owner (a voice's owner changes with a trig, which opens). JUNO LEN's default
is now 127 (record 389).

Tested in rytm-emu (lp3n, JUNO on BD from the machine list, grid trigs, USB host):
- default LEN 1/16: `04 08 .. 11 00` for every trig, nothing open after STOP;
- a longer LEN with trigs inside the gate: no note-off between them (retrig),
  the last one at STOP;
- LEN INF: no note-offs while playing; one `11 00` right after FC (slot 1 stays
  set, the play flag drops).
Not tested: live play (slot 0: pads, MIDI in) - dtboot's DIN MIDI notes reached
no track in this setup, and the pads are not among dtboot's keys.


## JUNO's patches from the host (2026-10-09; built and tested in rytm-emu)

16 <replace> <total> {<slot> <13 name bytes>}: the project's JUNO list; PAT's
value text shows entry min(PAT, total - 1) ("---" for an empty one), the
factory names A11..B88 when the project has no list. A missing list or another
project's makes PAT's text send 10 <project> + 13 (once in ~200 draws). 15
<voice> <CUT RES ENV ATK DEC REL>: a patch's own sliders, written into the owner
track's sound in the UI task (ext_ui_tick): the kit's machine words at
0x41255933 + 152 t (what the screen draws; found by searching each track's live
words in the kit, the same in the user's own snapshot) and the live copy through
0x4011f3fa(value, track, index) (a knob turn's own call). The host takes CUT..REL
as absolute slider values now (rytm-teensy b9b5b18). 0022 routes 15/16 to the
mailbox at 0x40027a04 ('JUNO').
Tested (rytm-emu lp3n, injected 13/15/16): no list -> 10 + 13 sent; with a list
PAT reads the names by value (S2, S3 ..); 15 for voice 0 moved CUT..REL on the
screen, the kit words and the live block. Not tested: with the real Teensy; the
project copy at 0x40765931 follows the kit later (a knob turn's own copy).

## 6-OP FM (2026-10-09; built and tested in rytm-emu)

Machine 40 (RS CLASSIC 2's slot and records 374..381; 0014's variants patch
now ends at 39), ext_render, voice byte 0x48 (host decodes by vb & 0x78), on
every track, sample layer muted. SRC: PAT TIM MOR DEC LPG TUN LEV LEN (CC
16..23). PAT's text: the host's FM list names (17, asked with 18), sharing
JUNO's name cache (jn_mailbox.list: 0 JUNO, 1 FM; 127 x 12 characters now),
else the number. Code: names/looks in cave15 (.extr), fm_descriptors (.extc);
ext_gate/ext_try_send moved to .exto to make room in .ext9.
Tested (rytm-emu lp3n): 6-OP FM listed before JUNO; its page and names; an
injected 17 gives PAT 2 = MARIMBA; trigs report 04 48 .. with note-offs.

## Curated models (2026-10-09)

The user's pick: PLAITS ENG 17 zones (VA VCF, PHASE DIST, WAVE TERRAIN, STRING
MACH, CHIPTUNE, VA, WAVESHAPE, 2-OP FM, GRANULAR, HARMONIC, WAVETABLE, CHORDS,
SPEECH, SWARM, PARTICLE, STRING, MODAL; 6-OP FM 1-3 are the 6-OP FM machine's,
NOISE went, the drums are DIGIDRUM's); DIGIDRUM 11 (EFM BD SD XT CP RS CB HH
CY, TRX RS CB CL; the Rytm's analog voices cover TRX B2/SD/CH/OH/CY); DAISYSP
and DSP SAMPLE 3 (MODAL STRING RESON; DRIP went). Zone = value x N / 128, the
host decodes the same (rytm-teensy). Checked in rytm-emu: PLAITS ENG at the top
reads MODAL; DIGIDRUM's TRX-RS zone names its knobs PTCH DEC DIST.

## Diagnostic knob (2026-10-09; review fix 7)

For reading meaning and budget on hardware without a host: DSP SAMPLE's SMPL page
(SD SAMPLE), knob C, now DGN (word 20; FLD of the old folder walk, unused since
the pool list). Get there on any track: [SRC] twice, pick DSP SAMPLE, [YES],
[SMPL]; turn C. The header reads "Diag TUPKMRSC" and the knob one value per
eighth of its range (its stored value only selects; nothing is sent or written
elsewhere):

| range | shows | what |
|---|---|---|
| 0-15 | T | most DTIM2 counts one ext_render call took since boot or the last C |
| 16-31 | U | free USB requests (pool of 32; 27 idle in rytm-emu) |
| 32-47 | P | the play flag 0x405c8c90 |
| 48-63 | K | the selected track's (0x41318982) first kit word, KIT_WORD(t, 0) |
| 64-79 | M | its machine byte 0x8000ea00[t] |
| 80-95 | R | the USB MIDI sender's ring fill 0x413db258 |
| 96-111 | S | the selected track |
| 112-127 | C | clears T |

T: ext_render (the engine entry of machines 40/41/42/44/45/51) is now a wrapper
(.extw, cave16's unclaimed 98 B) that reads DTIM2's counter (0xfc07800c) before
and after ext_render_body and keeps the largest difference - two peripheral
reads, a subtraction and a compare per call. DTIM2 runs free on DTIN (the
bootstrap sets DTMR = 7; MAIN OS times a delay on it, 0x400055b2) [measured];
DTIN = 12.288 MHz [inferred], so 8192 counts = one 32-sample block. The text
itself (.extq: 228 B in cave10's end, taken from 0022's .lp2 claim, which used
280 of 552) runs in the UI task.
Checked in rytm-emu (lp3n + this, strict mode): T67 with a DSP SAMPLE voice
playing (~1100 emulated instructions; the emulator's instruction-to-count ratio
is its own), U27, P1 while playing, K80, M45, C0.

## MOD knob (2026-10-09; diag = 0)

DSP SAMPLE's SMPL knob C (word 20) is MOD in the normal builds: the host's
playback mode, ONE LOOP SLICE GRAIN STRCH PLUCK WAVE in seven zones (zone =
value x 7 / 128). Its value text (mod_text, .exto) also writes the long and short
names of records 445..447 (STA END LOP: STA END SLC for SLICE, POS SIZ DNS for
GRAIN, STA END SPD, STA DEC BRI, POS --- CYC), as DIGIDRUM's ENG names its
knobs.

Label lag (reported in the window: STA/END/LOP one refresh behind a mode
change) - not reproduced, so not changed [measured, rytm-emu, lp3n, JIT]: MOD
stepped from LOOP into SLICE on the knob page, the OLED captured every 50k
instructions (0.25 ms): G's label reads SLC at +11.60M and MOD's text SLICE at
+11.65M - the same frame (the panel transfer brings the bottom row first).
Likewise in the full-screen sample view. The page draws every label each frame
and calls the value text before the labels are used, so a mode change shows
complete in the next frame. What remains possible: the window showing a frame
caught mid-transfer, and a track change between two DSP SAMPLE tracks in
different modes, where the first frame could carry the other track's names
(the records are shared) - not seen; a fix there (setting the names from the
track's word 20 in ext_page_record) would cost .ext4/.exto space for one frame.

## User slots U1..U5 (machines 35..39; built 2026-10-10/11, tested in rytm-emu and with the real Teensy, not on a Rytm)

Machines 35..39 (0014's hidden "2" variants) are U1..U5, machine plugins that run on the Teensy (rytm-teensy spec
`docs/superpowers/specs/2026-10-10-user-slots-rytm-design.md`, protocol `sim/protocol.py` 19..1E). On the Rytm they
are ext_render tracks like PLAITS, on every track, with voice flags 0x50..0x70. Their names live in RAM buffers
(`us_l1..5`, `us_s1..5`), their SRC pages list records 334 + 8 s .. + 7 in order (P1..P8, CC 16..23), and page 2
uses the shared records 438, 457..460 and 403..405 (kind 0x36). The 69 registry claims of the takeover are generated
from the stock image by `tools/us_records.py`; three of them are guards (records 341, 346 and 364 already hold the
values, `guard = true`). The research is in `user-slots-research.md` (R0..R14, the E2E run), the tag's in
`sound-tag-research.md`.

### What the Rytm shows per slot state

| what the Teensy said (1A) | machine list, long | short | slot menu item |
|---|---|---|---|
| nothing yet (no Teensy, no 1A) | `USER n` | `Un` | `Un ?` |
| EMPTY | `USER n ---` | `Un--` | `Un ---` |
| READY | the manifest's name | its short name | `Un <name>` |
| MISSING, BAD, NO_ROOM, MUTED, LOADING | `!` + name | `!` + 3 of the short | `Un !<name>` |
| READY, but the selected track's sound is tagged for another plugin | `!` + name | `!` + 3 | `Un !<name>` |

The names are rewritten only in the UI task (`us_names`), whole names at once. A slot whose cache has no 1A yet shows
`P1`..`P16`, the range 0..127 and numbers (the descriptors' defaults).

### Messages

- **19 ASK** (Rytm -> Teensy; `us_ask`, only with 4 free USB requests, so a host that does not read never blocks the
  UI): the slot's 1A when its generation is not the 1D's or no 1D came yet (what 0, each slot at most once every 200
  UI ticks); a READY slot's missing enum list (what 1, at most eight lists); a preset page (what 2, from the PRE text);
  the installed list (what 3, the slot menu). At most one ask every 10 ticks overall.
- **1A META** (MIDI task): parts staged in one buffer (`us.st`, one slot and generation at a time; a part 0 for
  another slot while a commit is pending is dropped and asked again). Once all parts are in, the UI task commits it
  into the slot's cache (`us_commit`): names, records, looks and ranges rewritten, the enum lists asked anew, page 2
  set up again. Part 0x7f means "unchanged". Part 0 is 43 B with the fp (the tag's value); 41 B gives fp 0. A knob
  part must be whole 24-byte entries (`len > 10`, `(len - 10) % 24 == 0`, since 2026-10-11): a short one is dropped,
  the 1A stays incomplete and is asked again (emulator `shortpart`).
- **1B LIST**: list < 16 is P(list+1)'s enum names, into the slot's cache for its current generation (eight lists a
  slot; a ninth is dropped and not asked for). A list that starts (the replace flag) clears its names first, so names a
  message did not carry read `---`. A commit (UI task) that replaced the slot's 1A while a 1B's names were being
  written frees that list again (the generation re-read after the writes, 2026-10-11), so no old machine's names sit
  in the new one's list. 0x20 (a slot's presets, key 0x11..0x15) and 0x21 (the installed machines, key
  0x20) go into the JUNO mailbox's one-list cache, keyed by list and generation.
- **1C KNOBS** (Teensy write-back): noted per owner track in `us.wb[t]` by the MIDI task, applied by the UI task:
  re-checked (the track still plays that slot), clamped to the knob's range, P9..P16 only when page 2 is knobs, and
  written through `us_set` (below).
- **1D SLOTS**: the five generations and the installed list's (`us.tgen`, `us.tinst`, `us.seen`); 15 B with an answer
  pair (slot, result) answers a 1E. The Teensy also sends one when a 10 or a 19 what 3 comes from a Rytm that has none
  (rytm-teensy a55fe50, 8fdbc0e: E2E finding 1), and every 5 s (c29a05c).
- **1E ASSIGN** (Rytm -> Teensy): preceded by `10 <project>` under one MIDI lock; slot, op (0 assign the installed
  entry, 1 clear, 2 install from the card), entry, and the installed list's generation. The generation comes from the
  list the menu checked (`jn_mailbox.lgen`, 2026-10-11), not from the latest 1D, so the Teensy refuses an entry index
  of an older list.
- 0022's router passes 15..1D to the 'JUNO' mailbox (0x40027a04), whose hook `us_sysex` sends 15..17 to JUNO/FM
  (`jn_sysex`) and 1A..1D here. The router takes SysEx from USB and DIN alike, in one task (R13, measured).

### Caches and the hand-offs

- **Slot caches** (1524 B each: the committed 1A, sixteen knobs, eight enum lists; the allocator rounds each to 2048,
  ~10 KB for five), the staging buffer and the twelve `us_wb` hand-offs (28 B each) come from the firmware's
  allocator (0x400829d4) on the first UI tick. It does not clear, so `us_init` zeroes them before publishing the
  pointers to the MIDI task. A slot without a cache shows `USER n` and numbers.
- **The one-list cache is shared** with JUNO's and 6-OP FM's PAT lists (16, 17): a slot's presets, the installed list
  and the PAT lists evict each other, and whichever draws next is asked for again (throttled). A page showing a JUNO
  PAT and a U1 preset at once alternates between asks.
- **Seqlocks, one writer each.** The 1C hand-off: per track, `wseq` (odd while us_knobs_in writes, +2 a 1C; MIDI task
  only) and `rseq` (UI task only); the UI copies when `wseq` is even and new, and uses the copy only when `wseq` did
  not move meanwhile, so one 1C's values are never applied under another's slot. JUNO's 15 uses the same scheme
  (`jn_mailbox.pend`, odd while written, `taken` on the UI side). Both assume a single writer: DIN and USB SysEx are
  delivered by the same task (R13, measured in rytm-emu).

### Heap (2026-10-11; spec 1.6, measured)

The allocator (0x40082758, a buddy allocator in 16-byte units over a 16 MB arena at 0x41ac1340) has 13 880 896 B
free in the us1 base after `us_init` (largest block 8 MB), 13 876 560 B after five slots' 1A, a choice, a preset list
and 0023's pool table (user-slots-research.md R15). The user slots take 11 KB (five 2 KB caches, 512 B staging, 512 B
write-backs), 0023 4 KB for the pool table and 16 KB while the TEENSY folder is listed. The project's data lie outside
the arena (fixed addresses). `us_init` checks each allocation and a failure only degrades: no staging buffer - no 1A
committed (`USER n`); no write-backs - no 1C applied and no choice defaults; no cache - that slot shows `USER n` and
numbers. The popup's two allocations are checked too (no popup on failure).

### Knobs, value texts, page 2

- **Looks** (1A): 0 dial, 1 centred, 2 fader, 3 list (as a dial): the record's descriptor is copied from a stock
  record of that look. Ranges and defaults are written into the record at runtime (`rec[2..4]`); the LFO ignores a
  record's runtime range (R4).
- **Value texts** (`us_text`, one function for all 48 records, the functor = descriptor + 20 on every path, R1):
  number (kind 0, and time/list for now); bipolar `-64..+63`; enum in equal zones over 0..127, at most 7 characters,
  `---` for a name not sent; note `C-1..G9`; preset - the slot's preset list (1B 0x20) when the one-list cache holds
  it, else the number while it is asked for; pool - 0023's pool table (mailbox word 3, `td_pool_tab`), `OFF` for 0.
- **Page 2**: when the slot's 1A says page 2 is knobs (flag bit 0, READY), P9..P16 use the eight shared records,
  set up for the selected track's slot when its page draws (`us_page_record`, from `us_tick3` too); the title is
  the 1A's title, else its name. Otherwise page 2 is the stock sample page and the voice's sample layer plays.
- **Write-backs persist.** Every value 0021 sets (1C, a choice's defaults, JUNO's 15) goes through `us_set`, as a knob
  turn does (R11): the live copy (0x4011f3fa) and kit_param_changed (0x4003355c) on the KitBank, whose drain (every
  8th UI pass) writes the kit word and the project copy that saves and the power-off keep. UI task only (the bank's
  mutex).

### Choosing a slot gives its defaults

The user's decision (2026-10-10; research R12). An explicit choice sets P1..P16 to the plugin's 1A defaults (P9..P16
only when page 2 is knobs) through `us_set`, and tags the sound (below):
- the machine list's YES on U1..U5 (the cursor's set_machine call notes the track, detour 0x400bee40; the list's
  close takes the note on YES, 0x400dea8e; its opening clears it, 0x400d3f5a, since GLOBAL or the TRACK menu leave the
  list without its close - the previewed machine then stays, without defaults, as stock keeps that preview's P1..P8);
- a step onto U1..U5 with the SOUND menu's MACHINE item (FUNC + FLTR, LEFT/RIGHT; told from the list by 0x400bed62's
  return address);
- the slot menu's assign answered READY or LOADING, for each track playing that slot.

Never on an install from the card, a clear, a kit or project load, a plain 1A or a 1C. When the slot's 1A is not the
Teensy's current one (no Teensy yet, LOADING, stale) the track waits (`us_wb.pslot`) and takes the defaults at the
first UI tick that sees it current and READY:
- **the 60 s window** counts audio blocks (0x419ca2ac, 1500 a second, measured; 32-bit, no wrap for 33 days), so a
  wait older than 60 s (90000 blocks) is dropped at the first tick after it, however long no tick ran (menus and
  pages without value texts run none);
- **us_loaded / lgen**: any kit or project load (0x4011f6bc: RELOAD, LOAD KIT, a pattern's other kit, LOAD PROJECT;
  also from the audio interrupt on a pattern's kit switch) moves the load generation `us.lgen` on and clears every
  `pslot`, byte stores only. us_tick3 reads `lgen` before its checks and again with the machine byte just before the
  defaults; us_defaults checks it a third time inside the tag's mask (2026-10-11);
- **an assign waits for another generation** (`us_wb.pgen`, 2026-10-11, R14): the pend notes the cache's generation
  when the answer came, so a 1D answer naming the old machine's generation never applies the old cache.

### The slot menu

Five items `U<n> <name>` after SAVE TRACK (and after 0012's SLICE LOOP) in the track menu (FUNC + CHRO), appended by
a detour at 0x400f9e9c (R5). YES asks 19 for the installed list, sends `10 <project>` and 1E under one lock (the next
installed machine, clear after the last, install from the card for a MISSING slot whose machine is there) and shows
the 1D answer as a popup (READY, NOT INSTALLED, NO ROOM, STOP TO INSTALL, NOT ON CARD, BAD, LOADING; NO TEENSY).
- **It blocks the UI.** YES waits in the UI task (10 ms sleeps) for the installed list and then for the 1D answer,
  2 s at most for both together (one budget of 200 steps since 2026-10-11; before, up to 2 s each, ~4 s): the screen
  and keys stall that long with a Teensy that does not answer; the other tasks and the audio run on. The spec's
  "nothing waits" (3.2) holds for the asks on draws, not for this YES.
- **No 1E on a list that moved.** Just before sending, the one-list cache must still hold the installed list of the
  generation the entry was picked from (`list == 0x20`, `lgen == tinst`, re-read); otherwise no 1E (NO TEENSY).
- **An install that failed is not retried by the next YES** (2026-10-11): a MISSING on-card slot's YES installs (op 2);
  when that install got no answer, or an answer other than READY / LOADING, the next YES on that slot steps or clears
  it as for any other slot (`us.ifail`), so a slot whose install keeps failing can still be reassigned. Emulator
  `installfail`.
- **Names match on 9 characters** (`us_same`; the one-list cache keeps 9): two installed machines whose names agree
  that far are one for the step.

### Builds, exclusions and caves

The user slots are 0021's build param `slots` (2026-10-11): every user-slot claim in the registry is gated `slots`,
ext.c's user-slot code (and its changes to the older functions) sits under `EXT_SLOTS`, and the generated stub.s holds
both compiles, picked with `.ifne P_SLOTS`. 0022 (the router's 15..1D range) and 0023 (the 12-byte mailbox with
`td_pool_tab`) gate theirs on their own `slots`; build.py's `linked_params` refuses an image where the three differ,
and `--param slots=N` sets them all. Default 0: the image is c127fe8's byte for byte (hw1's MAIN OS sha256 cfbb3346...
on both, measured), so the hardware commands of the 2026-10-09 review stay what was reviewed; a user-slot build asks
for `slots=1`.

us1 (emulator): `0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive` with 0014 `variants=1 funcgen=0 test=0`
and `slots=1`; hwus1 (the hardware build): the same with `variants=0` and 0021 `diag=1` (docs/FLASHING.md). build.py
refuses (test_build_excludes.py):
- 0014 with `funcgen=1` or `test=1` (`excludes_params`, check_param_excludes): FUNC. GEN.'s, LT TEST's and CB TEST's
  records are page 2's shared records, and the PLAITS/DAISYSP/DSP SAMPLE list entries are TEST machines';
- 0002-euclid-accents (both own param_value_text's entry 0x400a85e0), 0004-lfo-rnd (it packs LFO RND into sound
  index 0, the tag; its cave2 holds `.us6`), 0006-comp-preview and 0013-voice-dac (their caves hold `.us1..4`,
  `.usd`, `.usr`; R6), 0009-main-rms (cave7's head holds `.us5`) and 0020-dmach (the same page-2 lookups).
- 0003-velocity-humanise (since 2026-10-11): it needs 0002 (its amount lives in bits only 0002 persists and masks),
  which 0021 excludes, so with 0021 euclid's accents went silently.

| section | cave (owner before) | address | claim | as built 2026-10-11 | holds |
|---|---|---|---|---|---|
| `.us1` | cave4 (0006) | 0x40029060 | 1960 | 1940 | voice flag, descriptors, value text, page 2 |
| `.us2` | cave9 (0013) | 0x4001976a | 2782 | 2594 | 1A..1D handlers, the UI tick, commits, write-backs, asks |
| `.usd` | cave9 | 0x4001a248 | 418 | 364 | constant data |
| `.usr` | cave9 | 0x4001a3ec | 198 | 164 | RAM: name buffers, `us` |
| `.us3` | cave3 (0006) | 0x40289ab8 | 1024 | 860 | the slot menu's action, waits, us_pend |
| `.us4` | cave5 (0006) | 0x4002871c | 760 | 660 | the slot menu's items, popup and thunks |
| `.us5` | cave7's head (0009) | 0x40137a48 | 264 | 262 | the choice's hooks, us_loaded, the 10 before a 1E |
| `.us6` | cave2 (0004) | 0x402cd8a0 | 1340 | 1028 | the tag: us_defaults, us_tick3, us_names |

0021's older sections (`.text` 742 of 756, `.extq` 240 of 248, `.ext9`, `.exto`, ...) are unchanged by the user slots.

### The sound tag (2026-10-10; built and tested in rytm-emu; sound-tag-research.md)

A saved U-sound stores only its slot number and words, so loaded where that slot holds another plugin its values
would play on the wrong plugin. The user's decision: tag sounds with the plugin's fingerprint; on a mismatch the
voice stays silent and the track shows `!NAME`.

- **Where:** sound index 0 - the active kit's word 0 (`0x41255921 + 2531 k + 152 t`, k the 32-bit active kit index
  `0x800067b8`, 0..127: all 128 kits are resident and a trig copies from the kit it plays; a pattern on kit 1 plays
  and edits kit 1 [measured, A02]) and the project copy's slot 41 (`0x40765981 + 162 t`: the active kit's working
  copy, rewritten on a kit switch, saved as that kit at power-off [measured]), byte stores (the parity changes with
  k). It is carried by kit, project, pool and +Drive saves and loads, power-off,
  stock 1.73 and the trig path, sound locks included [measured, research M1]. 0004-lfo-rnd uses the same word, so
  0021 excludes 0004 and takes its cave2 (`.us6`, 1340 B).
- **Value:** `fp = FNV-1a32(package id) mod 16383 + 1` (1..16383, below 0x8000); 0 = untagged, which plays. It
  arrives in 1A part 0 as two more bytes (`fp >> 7`, `fp & 0x7f`, 43 B in all); an older part 0 (41 B) gives 0.
- **Writer:** `us_defaults` only - the machine list's YES, the SOUND menu's MACHINE step, the slot menu's assign
  (op 0; not an install from the card, op 2, nor a clear) and the delayed wait for 1A. Never a plain 1A, a load or a
  1C (re-tagging there would make a mismatched sound look valid). All tag stores - the active kit's two bytes, the
  live word and the project copy's two bytes (inside since 2026-10-11) - run with interrupts masked (SR saved, IPL 7,
  restored), so a trig never copies half a new tag [measured, rytm-emu us1: SR 0x2004 in
  the UI task before the mask - supervisor, IPL 0 -, 0x2704 after; the audio interrupt v191 enters at IPL 5]. No
  other mod masks; ColdFire has no `ori` to SR, so it goes through a register. Inside the mask it reads the active
  kit and also writes the live word 0 (`0x8000e5b0 + 84 t`, one `move.w`, as SET_PARAM stores a knob's): a trig
  copies the kit sound there only when `0x8000fc58[t]` (the kit last copied for t) is not the kit it plays, so a
  track that had trigged kept the old tag (E2E bug 2, user-slots-research.md). (b4a8f74 stored -1 in `0x8000fc58[t]`
  instead; the next trig then copied the kit's P1..P16 while US_COMMIT still held the new ones queued, and a trig
  in that window - about 11M instructions - kept the old words for good [measured, review]. Now the knobs go to the
  live array at once, as a knob turn's do.) A sound-lock step and a kit load still re-copy the whole sound [measured];
  where stock forces such a copy within ~11M instructions of a choice (the first trig since boot or after a kit load,
  the step after a lock step) the P words came out old until 2026-10-11: us_defaults now stores each knob word
  straight into the active kit (8.8, the integer byte first, byte stores) before its `us_set`, so the copy brings the
  defaults (user-slots-research.md, bug 2, "Remaining risk"; emulator `freshtrig`).
- **Guards inside the mask** (2026-10-11): the tag goes in only when `us.lgen` is still the generation us_tick3 read,
  the track still plays the slot, and the kit word `0x800067b8` equals the applied kit `0x8000fc8c` (the audio
  interrupt's last applied kit: it calls us_loaded and then copies 0x800067b8 there on a switch; measured 0/0 on the
  base, 1/1 on A02). A pattern change set by the UI task but not yet applied (up to one audio block), or a switch
  during the sixteen `us_set` calls, can no longer send the tag to the wrong kit's track.
- **Reports:** `ext_render` appends the owner track's word 0 from the per-track array `0x8000e5b0 + 84 t`
  (unmodulated; a sound lock's own) to every 0x04 (43 B) and 0x03 (41 B) as `tag >> 7 & 0x7f`, `tag & 0x7f`, for
  every machine it reports. The Teensy compares it (rytm-teensy spec §2.6).
- **!NAME:** `us_tick3`, for the selected track (read once) on a slot: its word 0 in the active kit, low 14 bits (what the Teensy
  reads from the two 7-bit bytes; an older 0004 word of 0x4000 or more compares by those bits) nonzero, the slot's fp
  nonzero and the two different -> `us.mm = slot + 1`, and `us_names` takes READY's name through the `!` branch. Only the selected track;
  a mismatched lock step is silent (Teensy) but not shown.
- Copy/paste of a track sound was not driven in the emulator (no key walk found); it is a raw copy of the record
  [inferred: carried].
- Emulator: `tag tagpool taglock tagname untagged tagkeep install tag14 tagpower assigntrig choosetrig tagkit1 assigngen
  freshtrig` (tools/emu/us_emu.py; freshtrig: a track not trigged since boot, trigged between the choice's word 0
  and the drain; assigntrig and choosetrig: each writer on a track that has trigged, with a trig inside the
  kit words' queue window, the 0x04's and the live array's P words checked; tagkit1: pattern A02, kit 1); `choose`
  (the delayed 1A), `sound`, `assign` and `window` check word 0 too, `tag` the 0x03's tag (41 B).

### Status: what is tested, what is not (2026-10-11)

`status = "built"`. Nothing of this has run on a Rytm.
- **Emulator** (rytm-emu): `tools/emu/us_base.sh <tag>` right after building the tag (it also copies the build's
  objects and manifest to build/emu/<tag> for the tests' symbols), then `tools/emu/us_emu.py <tag> all`: 36 tests,
  293 checks, ALL PASS on both us1 and hwus1 at the 2026-10-11 review-fix commit (RYTM_TEENSY names the rytm-teensy
  checkout whose `sim/protocol.py` builds the messages; rytm-teensy-us at e5b0407). `strict` also runs `tag menu
  assign load tagkit1` with every run under DTEMU_STRICT=1; `stock` covers U1..U5, each with a tagged sound;
  `freshtrig`, `installfail` and `shortpart` are the review's (each has checks that fail on b2beef3's us1). hwus1's machine-list walks
  are us1's (BT IMPROVED is not in BD's list either way). `tools/verify.py --tag us1` / `--tag hwus1`, `make verify`,
  `tools/test_build_excludes.py` and `tools/test_layout.py` pass.
- **Stock 1.73** (R8): the working state with a track on U1..U5, powered off, cold-boots on stock without a fault,
  shows the track as DISABLE and keeps its words; the build gets it back. Only the working state: project load,
  copy/paste, the sound pool and the stock-machine reset are not re-checked for 35..39.
- **With the real Teensy** (2026-10-10, rytm-emu's window over the bridge, user-slots-research.md "E2E with the
  Teensy"): names arrive, U1 assigned from the slot menu (READY popup), V2 TEST on BD with its defaults and tag, PRE
  stepping written back (1C), a pool knob's name, a fault shown as `!FAULT`, the tag matched and a Teensy-side slot
  change silenced with `!SINE TEST`. Two bugs found and fixed: (1) a Rytm that came up after the Teensy got no 1D, so
  the slot menu said NO TEENSY (fixed on the Teensy: an owed 1D on 10 and 19 what 3, rytm-teensy a55fe50/8fdbc0e);
  (2) the assign left the trig's tag stale on a track that had trigged (fixed here: the tag goes into the live word
  too, b4a8f74 then d38b5ea; tests `assigntrig`, `choosetrig`).
- **Not tested** (needs the real Rytm): the tag through copy/paste of a track or sound (a raw record copy, inferred
  to carry it); DIN SysEx in the single-writer role on hardware (measured in the emulator only: one task, R13); the
  IPL-7 mask on the real CPU (SR values measured in the emulator); all timing - the slot menu's 2 s waits, the
  60 s window against the real audio clock, the kit-switch and drain windows, the stock copy windows of bug 2's
  "Remaining risk"; the analog side of a U-track; power-off persistence on the real supercap.


## The tag moves out of sound index 0 (2026-10-16)

The user's decision of 2026-10-16 (rytm-teensy `docs/superpowers/specs/2026-10-16-sidecar-send-fx-storage.md`,
"the sound tag out of sound index 0"): sound index 0 is the Sidecar's SEND FX 1 (bits 8..14) / SEND FX 2 (bits 1..7)
on **every** track, user slots included, so the tag moves to a stored, non-lockable place. Only with `slots=1`; the
`slots=0` image is unchanged (its stub section is identical but for a comment's line number).

- **Where:** live sound `+0x6e/+0x6f` (spare, not serialized; 0013's bytes, 0021 excludes 0013), stored slot 47
  (`+0x7a/+0x7b`; slots 42..47 are written by every stored-format copy and never read by stock's `sound_load`).
- **Hooks** (code in `.ust`, 302 B at 0x402ccd7c, the end of 0002-euclid-accents' block; 0021 excludes 0002):
  - `us_tag_save` at 0x40008492 (`sound_save` after its memset; 0013's site): slot 47 = live `+0x6e`, for machines
    35..39 only (the spare bytes are heap garbage on other sounds).
  - `us_tag_load` at 0x4000826a (`sound_load` after its memset; 0013's site): live `+0x6e` = slot 47 for machines
    35..39, else 0. **Migration:** slot 47 zero, slot 41 set and a U machine: the tag = slot 41's low 14 bits, slot 41
    and 47 rewritten in the record before stock reads it, so live index 0 starts at 0 (measured: the project copy is
    migrated in place on a cold boot).
  - `us_tag_copy` at 0x4011f58a (0x4011f558's copy path: the trig loop's kit copy, a sound lock's pool sound, kit
    loads): `us_tag[t]` = the copied sound's tag (machines 35..39, else 0). `ext_render` reports `us_tag[owner]`
    (before: trig array word 0), so a sound lock still reports the pool sound's own tag.
- **Writers/readers changed:** `us_defaults` writes the active kit sound's `+0x6e`, `us_tag[t]` and the project copy's
  slot 47 (`0x4076598d + 162 t`), and no longer touches index 0; `us_tick3`'s `!NAME` reads the kit sound's `+0x6e`.
- **Stock:** ignores slot 47 and zeroes it at its next sound save: the sound comes back untagged and plays. Measured:
  a stock cold boot keeps slot 47 raw in the project copy, the track shows DISABLE; back on the build the tag is back.
- **Tests** (rytm-emu, build `sfx1b`, 2026-10-16): `us_emu.py sfx1b all` with the tag helpers moved to `+0x6e`/slot 47
  (pool tag addresses `0x41313cb5` live, `0x407bd331` stored; `tag14` and `tagkit1` poke and read `+0x6e`;
  `assigntrig` and `tagkit1` read `us_tag` where they read the live word 0); `sfx_emu.py sfx1b migrate`
  (an old-style sound migrates and keeps playing on its plugin, no `!`) and `sendlock` (SEND p-locks on a U1 track
  reach the host per step, every 0x04 keeps the tag).

## UI-task sends never wait (2026-10-16, sendfx-ui2; slots builds only)

The list ask (10 + 13/18 in `pat_text`), the user slots' 19 ASK (`us_send`) and the 10 + 1E assign take the MIDI mutex
with `ext_ui_lock` (`.us2`): port configured (0x413db254 == 1), ring room (0x413db258 + 64 <= 4091), 4 free requests,
then the try-lock 0x4000119c (never pends [code, 1.73]); otherwise not now (the list ask after its 200-tick wait, the
19 ASK asked again, no 1E: NO TEENSY after the wait). Shown in rytm-emu with the MIDI mutex held forever: the old build
froze in the 19 ASK, this one renders at 20 Hz (rytm-mods-ui2 `tools/emu/frz_emu.py`, mods/0029-sendfx-ui/design.md
section 8). slots=0 compiles as before.

### Stepped list knobs and the open slot menu (sfx-enum-knobs, 2026-10-18)

- **ext_steps / ext_stepbox.** 0021's list knobs become stock-style enum records (FILTER TYPE's: N options = N
  detents, the name drawn where the dial was), done by 0029-sendfx-ui, which owns the Sound set's wrappers: 0021 only
  says which knobs are lists. `ext_steps(record)` (`.us3`, its U-slot half `ext_steps_us` in `.us6`) answers mode << 8
  | N - zones (PLAITS ENG 17, DIGIDRUM ENG 11, DAISYSP / DSP SAMPLE ENG 3, INP 11, OUT 2, MOD 7 when not diag, a U slot's
  enum knob its 1B count; stored as each zone's lowest value, ceil(128 k / N), so the host's v x N / 128 and old projects
  read the same zone), list (JUNO / FM PAT over the project's list, a U slot's presets: the index) or all 128 (PAT
  without a list, a pool knob). `ext_stepbox` (`.usm`, 12 B at 0x4001a23c, the end of `.us2`'s former claim: `.us2`
  2782 -> 2770 B) holds magic `XSTP`, `ext_steps` and `us_live`, for 0029 (mods/0029-sendfx-ui/design.md section 9).
- **The slot menu's YES (hardware report 2026-10-17, root cause by another agent).** The track menu (FUNC + CHRO > U1..U5)
  draws no value text, so `us_tick` never ran while it was open: the slot's new 1A was not asked for nor committed,
  the next YES stepped from the stale cached name and the item's label stayed old. `us_fetch(s)` (`.us2`), called from
  `us_menu_action` after the 1D answer and the pends: commits a staged 1A, asks 19 what 0 at steps 0 and 25, stops once
  the cache has the Teensy's generation (50 x 10 ms at most; the UI task sleeps there, as the assign's own 2 s wait).
- **Live refresh while the menu is open.** The Teensy / Pi pushes an unasked 1D on every assign, rescan or delete;
  `us_live` (`.us4`, its asks in `.ext4`) commits a staged 1A and asks again (19 what 0, once in 50 ticks) for a slot whose generation the
  Teensy moved - not the whole `us_tick`, which with no Teensy asks on every page - and is called from 0029's `ev_tick`
  (elekloader's UI loop, 20 Hz); a committed 1A sets the views' redraw (ctrl + 0x20). Without 0029 in the image this
  part is absent (us_tick still runs from the value texts, as before).
- Tested [measured, rytm-emu, sfx1018]: the open-menu repro (menu kept open, YES three times) assigns acid, grain,
  metal in turn (1E arg 0, 1, 2), each answered 0; `us_emu.py all`; 0029's `sfu_emu.py ext`.

## Slot fingerprints at project load (slot-resolve, 2026-10-19; slots builds with 0029)

A Sidecar that has no slot map for a project (a shared project, a fresh card) learned which plugin each U-slot needs
only from the trigs' tags (0x04 / 0x03), i.e. after PLAY. Now the Rytm tells it at load time (rytm-teensy
`sim/protocol.py` `slot_prints` / `decode_slot_prints`, "Slot fingerprints"; `docs/user-machines-pi.md`, "Which machine
a slot plays"):

    25 <ver 1> <seq> <flags> <n> {<slot 1..5> <fp hi7> <fp lo7> <count>} F7        Rytm -> host, SLOT PRINTS

- **Content:** every sound of the 128 resident kits and of the project's sound pool whose machine is 35..39 (U1..U5)
  and whose tag (`+0x6e/+0x6f & 0x3fff`, as us_tick3 reads it) is nonzero; one entry per distinct (slot, fp), count =
  the sounds, capped at 127; slot then fp ascending; at most 16 entries (flags bit 0: more were left out, the first 16
  in scan order - kits 0..127 by track, then the pool - kept, sorted). n 0: no tagged U-sound (still sent).
- **Always after `10 <project>`, under one MIDI lock** (`us_assign_send`, now `(a, n)`: the slot menu's 1E passes 11),
  taken with `ext_ui_lock` (the try-lock; never waits) and only with ring room for 21 + 74 B (`RING_FILL <= 3891`: the
  sender also spins when it wraps a message over 47 B while the ring holds wpos - 63 or more, 0x40002a0c [code]) and 8
  free requests; otherwise not now: again in 4 ticks (0.2 s; a rescan each time), or at the next scan (1 s) when the
  port is not configured (no host: 0x413db254 != 1), so a Rytm without a Sidecar scans once a second, not 20 times
  [measured: strict cold boot without a host, 378 ticks, 19 scans].
- **When** (`sp_tick`, from `us_live`, i.e. 0029's `ev_tick`, the UI loop at 20 Hz; without 0029 in the image there is
  no 25 and the Sidecar resolves from the trigs as before):
  - a load or another project: `us.lgen` (us_loaded: RELOAD, LOAD KIT, a pattern's other kit, LOAD PROJECT) and the
    project name (0x407c89d3) hashed together each tick; when the hash moves, wait 10 ticks (0.5 s) of no change, then
    scan and send, whatever the content (so a host gets a 25 after every 10 that follows a load). The boot counts as one.
    A pattern change onto another kit while playing also moves lgen (the audio interrupt's us_loaded): one 10 + 25
    (95 B, the same seq) per such switch, 0.5 s after it.
  - otherwise one scan a second; the content's hash moved: seq + 1 (mod 128) and send at once; unchanged: sent again
    every 5 scans (~5 s) with the same seq (a host that came up later).
  - measured [rytm-emu sfx1019]: LOAD PROJECT's YES -> the 25 210M (~1.05 s emulated; the load ~0.5 s, the settle 0.5 s),
    well before PLAY (pressed 5 s after the YES; its first trig report came ~1500 rows later); a RAM change (a choice, a
    poke) -> 25 within 30M..200M; repeats exactly 1000M apart; the scan never saw a half-loaded project (every 25 of the
    load run was the wiped state or the whole set: `sp_emu load`).
- **Scan addresses** (all OS 1.73, this image):
  - resident kit k (0..127), track t (0..11): `0x4125590d + 2531 k + 152 t`, the live sound format: machine `+0x68`, tag
    `+0x6e/+0x6f`. [measured: = US_TAG_KIT(k, t) - 0x14; names at +4 (kit 0 BD `KICK DIST`, SD `SNARE`, kit 1 `SOUND 1`,
    kit 127 track 11 `SOUND 12`); kit 0 BD's machine 0x15 and kit 1's 0x1c as the tag's notes measured; all 128 kits
    resident: sound-tag-research.md]
  - sound pool entry i (0..127): `0x41313c47 + 152 i`, the same format [measured, rytm-emu sfx1018 base: names at +4 for
    entries 0..127 (`KLAS`, `QUCK`, `YAP`, `ELEK` .. `COWBL BROKE`), zeros at entry 128; entry 0's tag `0x41313cb5` is
    the address us_emu's tagpool test reads after STORE TRK SOUND to "entry 1" (M4: the pool's live copy)]. The stored
    copies (project copy 0x4076591f.., pool stored 0x407bd2b7) are not scanned: the live ones are what plays and saves.
  - the project name `0x407c89d3` (ext_project's), `us.lgen` (`us + 52`, a _Static_assert).
- **Code** (`.us7`, 542 of 548 B at 0x402cdddc, cave2's tail after `.us6`: 0003-velocity-humanise's and 0006-comp-preview's
  `.state` claims, both excluded by 0021; the pool is padding below the SRAM load image, untouched on hardware with
  0003's canary, 2026-09-19). In assembly inside ext.c (the C it stands for is beside it): gcc's -Os took 686 B. sp_sounds takes its
  arguments in registers (a0 q, a1 the sounds, d1 n; only sp_tick calls it). The
  state `sp` (12 B) in `.usr`, whose claim grows 198 -> 222 B up to `.exte` (the 24 B were only 0013's, excluded).
  `.us4` +6 (the call in us_live), `.us3` +4 (us_assign_send's length). slots=0 is unchanged: the same image byte for
  byte (0014 0021 0022 0023 slots=0 at 80f2605 and here: sha256 72a3760e...).
- **Cost:** a scan reads 1664 sounds (~15 k instructions), once a second, in the UI task; nothing in the MIDI task or the
  audio interrupt. Stack 96 + 28 B.
- **Compatibility:** an older Sidecar ignores 0x25 (rytm-teensy core `voice_report` returns for any cmd but 0x03 / 0x04);
  the Rytm never receives it (0022's router needs nothing).
- **Tests** (`tools/emu/sp_emu.py TAG all`, RYTM_TEENSY = rytm-teensy slot-resolve): `prints` (U1 on kit 0 BD and SD with
  FP_A, U3 on kit 5's CP with FP_B, U1 on pool entry 5 with FP_B: 10 then 25 `(1, FP_A, 2) (1, FP_B, 1) (3, FP_B, 1)`,
  seq moved, repeats every 1000M unchanged), `load` (cold boot, the set in kit 0 and the pool, SAVE PROJECT AS, tags
  wiped in RAM - 25 n 0, seq moved -, LOAD PROJECT: 25 with the set from the card ~1 s after the YES, before PLAY and its
  first trig report; no half-loaded 25), `change` (U1 chosen on BD in the machine list: seq moves; RELOAD KIT: n 0, seq
  moves again), `trunc` (132 sounds on (2, FP_C) and 17 distinct (1, fp): 16 entries, flags 1, count 127, 74 B),
  `mutex` (the MIDI mutex held 3 s: 60 renders, no 25; given back: the 10 + 25 at the retry). Seen in passing: a poke
  into a non-active resident kit (kit 5) is not written by SAVE PROJECT (it did not come back from the file), so `load`
  keeps its set in the active kit; and a message handed to USB in the first few M after a snapshot restore never
  reaches rytm-emu's host (`mutex` retries 50M in) - both emulator-test details, not the mod's.

### fix-1020 (2026-10-17): METAL in every slot - previews and stale tags no longer reach the slot prints

Hardware report: on a track's SRC page, double SRC for the machine list, arrowing down over the user machines and
YES left METAL in every U slot. **Cause** [measured, rytm-emu sfx1019, rytm-teensy `sim/um_e2e.py srcsteps`, `tools/emu/sp_emu.py
choose`]: the Rytm's own 1E was sent only for the slot menu's YES, but the 25 SLOT PRINTS (one scan a second) report
every tagged U-sound of the 128 kits, and the machine list's cursor *previews* a machine on the track (stock's
set_machine on every DOWN): BD's sound, tagged with U1's plugin, then sat on U2, U3, U4 with the same tag, the print
changed, and the Sidecar's resolve filled each empty slot with that plugin (a slot holding another one, replaced when the
Sidecar had it as inherited). The YES had the same effect through the tag: a choice of a slot with no plugin (or no 1A
yet) never rewrote the tag (us_defaults only runs for a READY slot), so the sound kept the old plugin's tag on the new slot.
**Fix:** (1) `us_live` does not call `sp_tick` while `us.ch` is set (the list previewed a machine and has not closed:
`us_step` notes it, `us_confirm` / the list's open / `us_loaded` clear it), so no scan or print sees a preview; (2)
`us_untag`, called by `us_choose` (the machine list's YES through `us_confirm`, the SOUND menu's MACHINE step through
`us_step`; not the slot menu's assign, whose tracks keep the old tag until the new 1A as before) takes the sound's tag off
in the kit, the project copy and the live word at once, until us_defaults writes the slot's own fp. Code: `.us8` (new,
cave7's rest after .us5, 260 B; 0021 now excludes 0010-kit-ab, whose toggle it was); `us_pend` moved there from `.us3`
(full). Tests: sp_emu `choose`, rytm-teensy `um_e2e
srcsteps` (the user's key sequence against the real core).

## 1021: NO SIDECAR

The slot menu's popup when the Sidecar does not answer within 2 s reads `NO SIDECAR` (was `NO TEENSY`; `us_t_none`).
No other user-visible string on the Rytm side named the Teensy (grep of every mod's strings, 2026-10-18).

## 1026: unused user-slot knobs look like stock's unused boxes

Hardware feedback (rui1025): a user machine with fewer than 8 knobs on a page showed `P5`..`P7` / `P11`..`P16` dials
for the knobs its plugin does not have. Now, once the slot's 1A is in, **a knob the 1A does not list (no entry with
that P in any part) is unused**: it draws as the stock unused box (the hatched square) and its turn does nothing, on SRC
(P1..P8) and on page 2 (P9..P16, a slot with params). Only for a READY slot: before its 1A, or while it is MISSING / installing (a 1A with no knobs), the knobs stay `P<n>` as before [measured: marking a MISSING slot's knobs unused let the install path treat the 1C write-back of P2 as lost and apply the defaults - `us_emu.py install` failed - so `us_src_table` checks `h.state == 1`].

**Host contract:** list in 1A only the knobs the plugin has; for the others either leave them out or send an entry with empty long and short names (the host's choice, 2026-10-19: empty names for every P the manifest lacks, other bytes 0) - both are unused. No message changes; a host that
already sends only its real knobs gets the boxes, one that names every P keeps 1025's look.

How, as stock does it [code + measured, rytm-emu rui1026]: stock machines with fewer knobs have record 0 in their entry
of the machine page table (0x40287cc8 + 36 m: name, 8 records; `machine_page_info` 0x400ff59a), which the SRC view
reads for both the draw and the knob (0x400d3544 -> 0x40039f86: record 0, the turn is dropped) - 47 such entries in
machines 0..34. `us_src_table` (asm, .us3) rewrites U(s+1)'s entry (machines 35..39) with 334 + 8 s + k or 0 whenever
the slot's records are set up (boot, each 1A commit). Page 2 goes through `ext_page_record`: `us_page_record` answers
-1 for an unused knob and ext_page_record turns it into record 0 (2 bytes in .ext4). `sound_param_record`'s machine
table (0x413db5fc) is left as it was, so p-lock and LFO lists still name the knob `P<n>` (cosmetic; nothing to edit).
`.us1` grew to 1980 B: its claim 1960 -> 1984, over the first bytes of 0004's `.kgate`, which 0021 excludes.

Tests [measured, `us_emu.py rui1026 unused`]: U1 with knobs P1..P4, P8 and page 2 P9..P12: SRC records 334..337, 0,
0, 0, 341; knob E (P5) turned: its kit word unchanged, knob B (P2) moves; on SMPL knob F (P14) unchanged, knob A (P9)
moves; `unused0.png` / `unused.png` show three / four stock unused boxes.

**DSP SAMPLE's MOD** (1026): the rui builds carried `0021-ext:diag=1` since the hardware bring-up, so DSP SAMPLE's
SMPL knob C was the read-only diagnostic DGN instead of MOD (section "MOD knob"). rui1026 builds with diag = 0: knob C
is MOD again (ONE LOOP SLICE GRAIN STRCH PLUCK WAVE; `us_emu.py rui1026 dspmod`: record 444's short name MOD on a
DSP SAMPLE track).

**PAT's list cache** (1026): JUNO's 16 and FM's 17 (and the U slots' 1B lists) share one name cache (jn_mailbox). At a
project load the host sends 16 then 17, so FM's list took the cache and JUNO's PAT showed factory names (A11..) until
pat_text's throttle (200 draws, ~10 s, then the host's answer) asked again. Now, when the cache was valid for another
list (or project) and a PAT text needs its own, it asks (10 + 13 / 18) at once; the throttle still spaces the asks
while no answer comes, so a host that does not answer is not flooded. slots=0 keeps c127fe8's image (the change is
under EXT_SLOTS). Separate caches would need ~1.3 KB per list (127 x 10 B) that no cave has. [measured, `us_emu.py
junopat`: 16 then 17 -> one 13 within 300 M; the same build without the change: none]

**JUNO's knobs** (1026, a report that they do nothing in rytm-emu): they are wired on the Rytm - knobs B (CUT) and E
(ENV) move kit words 1 and 4 and the page shows the new values (`junopat`, `junoknobs.png`). JUNO is rendered by the
Sidecar (ext_render passes the words on in the 03 / 04 reports); rytm-emu without the Sidecar's JUNO engine sounds
nothing different, so the effect is the host's.

## rui1031: MULTISAMPLE (machine 52) and 6-OP FM's chord page

Machine 52 (CB TEST) runs ext_render with voice flag 0x30 (rytm-teensy `kMultiMachine`); its SRC records are 398 443
399 400 401 402 406 407 (registry: machine 52, sound indices 9..16, CC 16..23, NRPN 1:0..7). Its SMPL page and 6-OP
FM's SMPL E..H are the user slots' shared page-2 records, set up by 0026 through `us_cubox` (.ush, fixed 0x4001a3dc:
'CHRD', setup, steps). Labels, value texts, the list name and mask live in 0026 (mods/0026-remote-ui/design.md, "1031").
With 0014 variants=1 (BT IMPROVED listed) BT IMPROVED has no knobs: its records 398..402 are MULTISAMPLE's. Emulator only.

## rui1034: WAVETABLE (machine 46) and GRANULAR (machine 47)

Machines 46 (RS TEST) and 47 (BT TEST) run ext_render with voice flags 0x28 / 0x38 (rytm-teensy core/machines.h
`kWaveMachine`, `kGranMachine`; `us_flag_tab`). No parameter records are free (334..460 are all 0021's), so their SRC
pages list MULTISAMPLE's records 398 443 399 400 401 402 406 407 (registry); 0026 sets those up for whichever of the three
machines uses them (names, looks, texts, defaults, the machine field) and gives 46 / 47 machine 52's ids in
sound_param_id_for_index's table. `us_page_record` and `us_param_record` treat 46 and 47 as 52 (page 2: the shared
records through `us_cubox`). Labels, value texts, names and masks are 0026's (design.md "1034"). Emulator only.

## 1045: DSP SAMPLE's SMP banked (record 441)

DSP SAMPLE's SMP (word 19) moves from stock's record 41 to record 441 (index << 8 | bank << 5 over the Sidecar's
SAMPLES pool, fine-flagged, 0..0x7fe0 by registry patch); TUN (word 17), whose record 441 was a byte-identical copy of
stock's 39, uses 39 [measured, rytm-emu rui1043]. us_param_record (and ext_param_record for slots=0) map them, the SD
SAMPLE page lists 39 442 444 441 445..448, 441's look is a dial; 0026 gives it its value text, step and bank list (0026
design.md "1045"). The .us1 claim grew to all of cave4 (2004 B).

## 1051: LIVE IN (machine 48) and CHOP (machine 49)

Machines 48 (LT TEST) and 49 (MT TEST) run ext_render with voice flags 0x78 / 0x18 (rytm-teensy core/machines.h
`kLiveMachine`, `kChopMachine`; `us_flag_tab` idx 13 / 14; 0x18 was the host's GRAIN placeholder, never sent - the host
moved it to 0x98, off the wire). Their engine entries (0x4029043c / 0x40290440) are ext_render; their SRC pages
(0x4028838c / 0x402883b0) list MULTISAMPLE's records 398 443 399 400 401 402 406 407, set up by 0026 for whichever machine
uses them; `us_page_record` and `us_param_record` treat 46..49 (WT_MACHINES 4) as 52 (page 2: the shared records through
`us_cubox`). Labels, value texts, names, masks and page 2's defaults are 0026's (design.md "1051"). Emulator only.
