# The Sidecar on an Analog Four MKII

**Runs on the owner's unit, OS 1.56, on Overbridge: machines heard through filter, drive and FX.** A mod for OS 1.56, built with [elekloader](https://github.com/irpina/elekloader)'s core-a4. Unofficial: not affiliated with, endorsed by or supported by Elektron. No Elektron firmware is in this repository: you supply the stock `.syx`, and neither it nor anything built from it may be committed.

## What it does

A track's sound can pick a Sidecar machine. That track's trigs and parameters go to a Sidecar over USB MIDI, and the machine's audio comes back in OVERBRIDGE mode through stock's track inputs, into that voice's own analog path: its filters, overdrive, amp, pan and the A4's chorus, delay and reverb all act on it. No audio code is patched: OUT channels 2..5 are stock's.

- **SIDECAR page:** OSC1 key, pressed until after NOISE. Knob A: OFF PLTS JUNO DSY FM6 MD B2 U1 U2 U3 U4 U5 (U1..U5: what the Sidecar's User machines tab put in those slots). It is stored in the sound, so kits, the sound pool and copy and paste carry it, and every sound starts OFF.
- **Knobs:** a track with a machine shows that machine's names on the stock OSC1, OSC2, NOISE and OSC 1&2 pages, and a turned knob's title says PLTS HRM and its value the plain 0..127 the machine reads. The knobs are stock's: locks, LFOs and kit saves work as ever, after them the values go to the Sidecar as P1..P15. A track that is OFF shows stock's screens. The knobs of those pages that the machine does not read are empty, stock's own hatched knob with no name, title or value, and a turn does nothing; their values stay as the sound has them. Three stay: OSC1, OSC2 and NOISE LEV, which layer the analog voice under the machine, and on JUNO and 6-OP FM OSC1 FIN. U1..U5 show P1..P15: the mod does not know a plugin's names.

| P | Stock knob | P | Stock knob | P | Stock knob |
|---|---|---|---|---|---|
| 1 | OSC1 TUN + FIN | 6 | OSC2 TUN + FIN | 11 | NOISE COL |
| 2 | OSC1 DET | 7 | OSC2 DET | 12 | NOISE FAD |
| 3 | OSC1 PW | 8 | OSC2 PW | 13 | OSC 1&2 BND |
| 4 | OSC1 SPD | 9 | OSC2 SPD | 14 | OSC 1&2 SLI |
| 5 | OSC1 PWM | 10 | OSC2 PWM | 15 | OSC 1&2 FAD |

What each P means is the machine's, as on the Rytm's SRC page: PLAITS ENG HRM TIM MOR DEC LPG TUN LEV, FM FIN AUX TMD MMD VEL GLD; JUNO PAT CUT RES ENV ATK DEC REL LEN; DAISYSP ENG STR BRI DMP INP EXC TUN LEV, XTN XDC FB OUT XP4 XLV XP5; 6-OP FM PAT TIM MOR DEC LPG TUN LEV LEN; MD CT1..CT8, ENG TYP LEV.

Every P covers 0..127. TUN stops at 1 and 127: FIN adds or takes about 2.5, so the first entry of a list (JUNO, 6-OP FM PAT) needs TUN down and FIN down: that is why those two keep OSC1 FIN, stock's knob. Elsewhere FIN is empty: P1 and P6 keep whatever fraction the sound has. To change it, or any empty knob, set the track OFF for a moment. Copying, pasting or clearing such a page takes the shown knobs only.
P16 is fixed per machine. **The knobs still move the analog voice:** ENG is still its TUN, TIM its PW. Turn OSC1 and OSC2 LEV down for the Sidecar alone (those two LEV knobs are the analog oscillators', not the machine's LEV), or leave them up to layer and hear them follow. Noise LEV up adds the noise to the voice. **Start from a cleared sound:** a sound's own values and LFOs are the machine's too: a factory kit's LFO on DET sweeps PLAITS HRM, and an LFO on TUN would jump ENG between engines. The LFO and envelope destination lists keep stock's names: DET is HRM on PLAITS, by the table above. A voice only sounds while the A4's amp is open: the same trig opens it. **Chords and KIT > POLY CONFIG:** a chord on a step reaches the track's machine whole, whatever POLY CONFIG says, so a mono track plays a Sidecar chord and takes no analog voice from another track. POLY CONFIG decides the A4's own voices alone: a mono track's oscillators play the chord's first note. Each note is one 04 on the track's voice, in order. PLTS, JUNO, DSY, FM6 and user machines that declare instances play it; MD and B2 (drums) and a mono user machine stay one hit. A note preview (GRID RECORD, hold the trig, YES) reaches the machine the same way: all the step's notes, whatever POLY CONFIG says, one note-off at its end, while the A4's own voices play what stock plays them (with the track's ARP on, stock's preview alone). Keys and MIDI give one note at a time: on a poly track they make a chord too, on a mono track each note follows the last as ever, and two different trigs there closer than 20 ms get a note-off between them, so that the Sidecar does not take them for a chord. A chord ends when the last key is up or every analog voice the track owns has closed. **The limit:** all of a chord's audio is on that one channel, so it enters one analog voice, the one of the track's number, takes that voice's filters and amp and no others, and that amp must be open. On a mono track it is, as the same trig plays there. On a poly track, if the A4 gives none of the chord's notes to that voice, the chord is silent while the notes play elsewhere. With note send on, a 6-OP FM voice may take its notes from MIDI as well: nothing doubles. The A4's own amp envelope and filters shape the machine.

With no Sidecar, or with every sound OFF, nothing changes: on USB a few short SysEx hellos at each port-up, and the page. No audio code is patched. Five sites, all UI or MIDI task code: one reads each SysEx at the router's entry, three in the page's draw and turn ask the mod for a knob's names, and stock answers when the track is OFF, and one tells it a preview's notes.

## The Sidecar's screen

With a Sidecar connected, on a kernel that has the pages, press OSC1 on the SIDECAR page: the A4's screen shows the Sidecar's pages, as the Rytm's does. LEFT and RIGHT step SIDECAR, SYSTEM, a page for each track with a machine, SCOPE and REC; YES on SIDECAR is the MENU; NO goes back, and on SIDECAR leaves. Any stock page key leaves too and does its stock job. YES is the page's while it is open, so a held trig's note preview needs it closed. While a page is open only the arrows, YES, NO and the knobs and pushes A..H a page uses are the Sidecar's; I, J and LEVEL do nothing on the status pages; the keyboard, the track keys and the transport stay stock's. A Sidecar lost, its USB gone or a power cut gives the stock screen back by itself, within about a second. With no Sidecar, or a kernel without pages, the OSC1 key steps OSC1, NOISE, SIDECAR as ever, and nothing is captured. A Sidecar that connects shows its splash for 3 s and the pairing code when it asks for one, over the stock screen; any key ends them and is stock's.

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
3. **Back to stock:** first set every sound's machine OFF and save (a rollback with a machine set is not rehearsed), then the same with `Analog-Four_MKII_OS1.56.syx`.
4. **If it will not boot:** hold FUNC at power-on, TRIG 4 for OS UPGRADE, and send the stock `.syx` over MIDI DIN (Transfer's legacy mode).

A computer in Overbridge also gets the reports when a machine is set: not tested. Keep every sound OFF for computer sessions.

## With a Sidecar

Needs an engine with the A4 profile (`core/device/a4.*`). Set USB CONFIG to OVERBRIDGE and connect the A4 to the Pi's USB-A port. The first hello restarts the Pi once, into `/.a4` on its card. Expect `device: Analog Four MKII` in `/log`, then `rytmob: Analog Four MKII (1935:0b47) claimed`. With a Rytm on USB the Rytm keeps the Sidecar: an A4 waits.

## Not done

Machine names in the LFO and envelope destination lists, knob labels on the Sidecar's pages, sample machines (they need the Rytm's pool pages), the Rytm's pages that need its pools, sequencer, send FX or project reports, the project's name on the Sidecar, its transport report (use the A4's own CLOCK SEND and TRANSPORT SEND).
