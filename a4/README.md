# The Sidecar on an Analog Four MKII

**Runs on the owner's unit, OS 1.56, on Overbridge: machines heard through filter, drive and FX.** A mod for OS 1.56, built with [elekloader](https://github.com/irpina/elekloader)'s core-a4. Unofficial: not affiliated with, endorsed by or supported by Elektron. No Elektron firmware is in this repository: you supply the stock `.syx`, and neither it nor anything built from it may be committed.

## What it does

A track's sound can pick a Sidecar machine. That track's trigs and parameters go to a Sidecar over USB MIDI, and the machine's audio comes back in OVERBRIDGE mode through stock's track inputs, into that voice's own analog path: its filters, overdrive, amp, pan and the A4's chorus, delay and reverb all act on it. No audio code is patched: OUT channels 2..5 are stock's.

- **The selector:** knob D of the NOISE page, MCH, on the OSC1 key's second page: OFF PLTS JUNO DSY FM6 MD B2 U1 U2 U3 U4 U5 (U1..U5: what the Sidecar's User machines tab put in those slots). It is stored in the sound, so kits, the sound pool and copy and paste carry it, and every sound starts OFF. A pick from OFF writes the machine's defaults on its knobs and sets OSC1 LEV 0, and a turn through the list keeps writing them while no knob has moved; one machine to another with a knob moved writes nothing. A pick to OFF sets the hidden PM1 and FM1 back to centre and ACC to stock's 8192, and TRK, WAV, SUB and AM1 back into stock's ranges; OSC1 LEV stays where it is. That is the sound's word: locks on those knobs stay as they are, up to 127 on the switches, and reach the analog voice on their trigs. Stock's stages cope, no fault.
- **The machine's page:** OSC1's knobs are the machine's, plain 0..127 dials with its names, on every sound with a machine. A turned knob's title says PLTS HRM and its value the number the machine reads. LEV stays the analog oscillator's. NOISE G..J are four more. OSC2, NOISE A..C, E and OSC 1&2 stay stock's: with OSC1 LEV 0 the OSC1 knobs leak nothing, measured by ear on a unit: SUB is silent, AM2 and SYNC do not change OSC2's sound. On a machine's page a knob it does not read is empty, stock's own hatched knob with no name, title or value, and a turn does nothing.
- **OS2:** knob F of the NOISE page, ANALOG or MACHINE, one bit of the sound. MACHINE gives OSC2's page to the machine with its names, and takes NOISE G..J away; OSC2 LEV stays analog. JUNO and FM6 have nothing to give it, so there the knob is empty and OSC2 stays stock's. A flip writes no values: OSC2's knobs bring what they hold.

| Machine | TUN | FIN | DET | TRK | WAV | SUB | PW | SPD | PWM | NOISE G H I J, or OSC2 TUN DET PW SPD PWM TRK |
|---|---|---|---|---|---|---|---|---|---|---|
| PLAITS | ENG | TUN | HRM | LPG | LEV | FM | TIM | MOR | DEC | FIN AUX TMD MMD; with MACHINE also VEL GLD |
| JUNO | PAT | - | CUT | DEC | REL | LEN | RES | ENV | ATK | - |
| DAISYSP | ENG | TUN | STR | EXC | LEV | XTN | BRI | DMP | INP | XDC FB OUT XP4; with MACHINE also XLV XP5 |
| 6-OP FM | PAT | TUN | TIM | LEV | LEN | - | MOR | DEC | LPG | - |
| MD, B2 | CT1 | ENG | CT2 | CT6 | CT7 | CT8 | CT3 | CT4 | CT5 | TYP LEV |
| U1..U5 | P1 | P7 | P2 | P6 | P8 | P9 | P3 | P4 | P5 | P10..P13; with MACHINE also P14 P15 |

What each P means stays the machine's, as on the Rytm's SRC page; only the knob feeding it is this table's. NOISE G..J are stock's PM1, FM1, ACC and AM1, in the same order, no OSC 1&2 knob besides AM1: AM1 keeps its place on OSC 1&2 under the machine's name while NOISE J holds it. On ANALOG, VEL, GLD, XLV, XP5, U's P14 and P15 stay at the default the mod sends.

**Knobs:** locks, LFOs and kit saves work on every parameter, stock's own path, after them the values go to the Sidecar as P1..P15. **TUN and FIN are in no LFO or envelope destination list:** so an LFO cannot jump ENG, and ENG cannot be LFOed. The other lists keep stock's names: DET is HRM on PLAITS, by the table above. PM1, FM1, ACC, AM1 are in the lists under those names. TUN and FIN are one word, its high and low byte: a lock on either is one lock of that word, and each keeps to its byte of the sound's word, so FIN turned on a TUN-locked step takes the sound's TUN back on that step, and the lock on ENG is lost. TUN turned on a FIN-locked step takes the sound's FIN back the same way. Lock one of the two on a step. While TUN moves, the OS's word glides, its own slew: FIN's P wobbles in a turn, and after a TUN lock P1 glides back over the next steps. A sound's own LFOs are the machine's too: a factory kit's LFO on DET sweeps PLAITS HRM: start from a cleared sound. Copying, pasting or clearing such a page takes the shown knobs only.

P16 is fixed per machine. A voice only sounds while the A4's amp is open: the same trig opens it. **Chords and KIT > POLY CONFIG:** a chord on a step reaches the track's machine whole, whatever POLY CONFIG says, so a mono track plays a Sidecar chord and takes no analog voice from another track. POLY CONFIG decides the A4's own voices alone: a mono track's oscillators play the chord's first note. Each note is one 04 on the track's voice, in order. PLTS, JUNO, DSY, FM6 and user machines that declare instances play it; MD and B2 (drums) and a mono user machine stay one hit. A note preview (GRID RECORD, hold the trig, YES) reaches the machine the same way: all the step's notes, whatever POLY CONFIG says, one note-off at its end, while the A4's own voices play what stock plays them (with the track's ARP on, stock's preview alone). Keys and MIDI give one note at a time: on a poly track they make a chord too, on a mono track each note follows the last as ever, and two different trigs there closer than 20 ms get a note-off between them, so that the Sidecar does not take them for a chord. A chord ends when the last key is up or every analog voice the track owns has closed. **The limit:** all of a chord's audio is on that one channel, so it enters one analog voice, the one of the track's number, takes that voice's filters and amp and no others, and that amp must be open. On a mono track it is, as the same trig plays there. On a poly track, if the A4 gives none of the chord's notes to that voice, the chord is silent while the notes play elsewhere. With note send on, a 6-OP FM voice may take its notes from MIDI as well: nothing doubles. The A4's own amp envelope and filters shape the machine.

With no Sidecar, or with every sound OFF, nothing changes: on USB a few short SysEx hellos at each port-up, and the page. No audio code is patched. Eight sites, all UI, MIDI task or load code: one reads each SysEx at the router's entry, three in the page's draw and turn ask the mod for a knob's names, and stock answers when the track is OFF, one tells it a preview's notes, one makes a machine's knob a plain dial in that draw, one, in the sound's load, gives a sound with a machine its PM1 and FM1 back, and one, in the keyboard's key handler, keeps UP and DOWN off the octave while a Sidecar answers. Ranges and dials follow the selected track by writes to stock's parameter table and knob descriptors. The UI and stock's MIDI CC path read those, no audio code, and the table is one for all tracks: an external CC takes the selected track's range. Stock's CC map holds TUN and FIN: with a machine selected, a FIN CC on an OFF track stays inside the selected sound's TUN byte, and that track's analog pitch jumps; WAV and SUB by CC can pass stock's range. Sound only, the next edit heals.

## The Sidecar's screen

With a Sidecar connected, on a kernel that has the pages, hold UP and press YES: the A4's screen shows the Sidecar's pages, as the Rytm's does; UP + YES again leaves. UP must be held a moment first, 100 ms: a menu's UP then YES pressed together stays stock's. Stock tests no held UP anywhere, so YES loses no stock meaning. **While a Sidecar answers, UP and DOWN do not change the keyboard's octave:** on a parameter page they do nothing, so UP + YES leaves the octave where it was; OCT+ and OCT- change it as ever. Everywhere else UP and DOWN are stock's: menus, lists, the sound browser, GLOBAL. With no Sidecar, UP and DOWN step the octave on a parameter page as stock does. "Answers": the host has sent its first message since the USB port came up; it holds until the port goes, so a Sidecar that hangs with its USB still up keeps UP and DOWN off the octave until the cable or the power goes. A held YES counts once. LEFT and RIGHT step SIDECAR, SYSTEM, a page for each track with a machine, SCOPE and REC; YES on SIDECAR is the MENU; NO goes back, and on SIDECAR leaves. Any stock page key leaves too and does its stock job. YES is the page's while it is open, so a held trig's note preview needs it closed. While a page is open only the arrows, YES, NO and the knobs and pushes A..H a page uses are the Sidecar's; a knob A..H it does not use does nothing; I, J and LEVEL do nothing on the status pages; the keyboard, the track keys and the transport stay stock's. A Sidecar lost, its USB gone or a power cut gives the stock screen back by itself, within about a second. Each draw shows one whole frame of the Sidecar's: a frame that arrives while the screen takes the last one is drawn at the next draw, never half of it, as on the Rytm. With no Sidecar, or a kernel without pages, UP and YES are stock's and nothing is captured. A Sidecar that connects shows its splash for 3 s and the pairing code when it asks for one, over the stock screen; any key ends them and is stock's.

## Build and rehearse

You need a stock `Analog-Four_MKII_OS1.56.syx`, `m68k-elf-gcc`, Python 3, an elekloader checkout at c150ac5 and, for the rehearsals, analog-emu with the OS upgrade tools.

```sh
STOCK=/path/Analog-Four_MKII_OS1.56.syx ELEKLOADER=/path/elekloader ./build.sh
tools/a4_suite.py --emu ANALOG_EMU --stock STOCK.syx --syx out/a4156_sidecar.syx --card CARD.img --out DIR --engine SIDECAR_FIRMWARE --old-engine OLDER_SIDECAR_FIRMWARE
tools/a4_e2e.py --emu ANALOG_EMU --engine SIDECAR_FIRMWARE --syx out/a4156_sidecar.syx --card CARD.img --out DIR
ANALOG_EMU/tools/rehearse_flash.py STOCK.syx $PWD/out/a4156_sidecar.syx --out DIR --card CARD.img --hello yes
ANALOG_EMU/tools/rehearse_flash.py $PWD/out/a4156_sidecar.syx STOCK.syx --out DIR2 --card DIR/card.img --hello no
```

`a4156.lock.json` is the mod storage's layout: keep it with the source, so that later builds read what earlier ones saved.

`tools/a4_e2e.py` runs the mod in analog-emu against the Sidecar engine on the Mac (`make -C core sidecar-emu` in sidecar-firmware): the hello, one restart into `/.a4`, trigs and parameters through the real profile, audio both ways.

## Install, and back to stock

Only with the stock file at hand, your projects backed up with Transfer, and a MIDI DIN interface in hand. **OS 1.56 only. Above 1.56 this is a downgrade: stop.** The emulator's reboot does not run the bootstrap, so that it takes this image, and recovery by DIN from a torn image, are not rehearsed.

1. GLOBAL > SYSTEM > USB CONFIG: USB MIDI (what the rehearsal used), connected to a computer. Back to OVERBRIDGE afterwards, for the Sidecar.
2. Send `a4156_sidecar.syx` with Elektron Transfer, as an OS update, and press YES at UPGRADE OS NOW?. The A4 restarts.
3. **Back to stock:** first set every sound's machine OFF and save (a rollback with a machine set is not rehearsed): that takes TRK, WAV, SUB and AM1 back into stock's ranges and PM1, FM1 to centre. Then the same with `Analog-Four_MKII_OS1.56.syx`. The other knobs keep what they hold, OSC1 LEV 0 among them, and locks stay as they are.
4. **If it will not boot:** hold FUNC at power-on, TRIG 4 for OS UPGRADE, and send the stock `.syx` over MIDI DIN (Transfer's legacy mode).

A computer in Overbridge also gets the reports when a machine is set: not tested. Keep every sound OFF for computer sessions.

## With a Sidecar

Needs an engine with the A4 profile (`core/device/a4.*`). Set USB CONFIG to OVERBRIDGE and connect the A4 to the Pi's USB-A port. The first hello restarts the Pi once, into `/.a4` on its card. Expect `device: Analog Four MKII` in `/log`, then `rytmob: Analog Four MKII (1935:0b47) claimed`. With a Rytm on USB the Rytm keeps the Sidecar: an A4 waits.

## Known

Left as they are, for a site or a tick more than they are worth:

- COPY and PASTE of a page write raw words by id: a machine's OSC1 page pasted on an OFF track puts wide TRK, WAV, SUB there, and its NOISE page PM1, FM1, which detune that analog voice with no knob to show it until a machine is picked and set OFF again.
- The load gives PM1 and FM1 back by the stored machine bits alone, not the layout: a sound from a later layout, which reads OFF, still gets them.

## Not done

Machine names in the LFO and envelope destination lists, knob labels on the Sidecar's pages, an LFO on TUN or FIN, sample machines (they need the Rytm's pool pages), the Rytm's pages that need its pools, sequencer, send FX or project reports, the project's name on the Sidecar, its transport report (use the A4's own CLOCK SEND and TRANSPORT SEND).
