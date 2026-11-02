# The Sidecar on an Analog Four MKII

**Emulator only: this has never run on a real Analog Four.** A mod for OS 1.56, built with [elekloader](https://github.com/irpina/elekloader)'s core-a4. Unofficial: not affiliated with, endorsed by or supported by Elektron. No Elektron firmware is in this repository: you supply the stock `.syx`, and neither it nor anything built from it may be committed.

## What it does

A track's sound can pick a Sidecar machine. That track's trigs and parameters go to a Sidecar over USB MIDI, and the machine's audio comes back in OVERBRIDGE mode through stock's track inputs, into that voice's own analog path: its filters, overdrive, amp, pan and the A4's chorus, delay and reverb all act on it. No audio code is patched: OUT channels 2..5 are stock's.

- **SIDECAR page:** OSC1 key, pressed until after NOISE. Knob A: OFF PLTS JUNO DSY FM6 MD B2. It is stored in the sound, so kits, the sound pool and copy and paste carry it, and every sound starts OFF.
- **Knobs:** a Sidecar track reads OSC1 and OSC2's pages as the machine's P1..P15, after locks and LFOs. The screen still says TUN, DET and so on.

| P | Knob | P | Knob | P | Knob |
|---|---|---|---|---|---|
| 1 | OSC1 TUN + FIN | 6 | OSC2 TUN + FIN | 11 | NOISE B |
| 2 | OSC1 DET | 7 | OSC2 DET | 12 | NOISE C |
| 3 | OSC1 SPD | 8 | OSC2 SPD | 13 | OSC 1&2 D |
| 4 | OSC1 PW | 9 | OSC2 PW | 14 | OSC 1&2 E |
| 5 | OSC1 PWM | 10 | OSC2 PWM | 15 | OSC 1&2 H |

What each P means is the machine's, as on the Rytm's SRC page: PLAITS ENG HRM TIM MOR DEC LPG TUN LEV, FM FIN AUX TMD MMD VEL GLD; JUNO PAT CUT RES ENV ATK DEC REL LEN; DAISYSP ENG STR BRI DMP INP EXC TUN LEV, XTN XDC FB OUT XP4 XLV XP5; 6-OP FM PAT TIM MOR DEC LPG TUN LEV LEN; MD CT1..CT8, ENG TYP LEV.

P16 is fixed per machine. **LEV is not on the list:** turn OSC1 and OSC2 LEV down for the Sidecar alone, or leave them up to layer. A voice only sounds while the A4's amp is open: the same trig opens it. The A4's own amp envelope and filters shape the machine.

With no Sidecar, or with every sound OFF, nothing changes: on USB a few short SysEx hellos at each port-up, and the page.

## Build and rehearse

You need a stock `Analog-Four_MKII_OS1.56.syx`, `m68k-elf-gcc`, Python 3, an elekloader checkout at c150ac5 and, for the rehearsals, analog-emu with the OS upgrade tools.

```sh
STOCK=/path/Analog-Four_MKII_OS1.56.syx ELEKLOADER=/path/elekloader ./build.sh
tools/a4_suite.py --emu ANALOG_EMU --stock STOCK.syx --syx out/a4156_sidecar.syx --card CARD.img --out DIR
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

Knob labels on the Sidecar's pages, sample machines (they need the Rytm's pool pages), remote UI, the project's name on the Sidecar, its transport report (use the A4's own CLOCK SEND and TRANSPORT SEND).
