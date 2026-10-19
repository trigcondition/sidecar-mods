# Subsystem notes

One file per subsystem, written as it is established from this exact image. Same
rule as the symbol map: say what was measured and what was inferred.

- `os-upgrade.md` - the two upgrade paths and the factory maintenance protocol
- [audio-engine.md](audio-engine.md) - hardware layout and historical inference corrections
- [compressor-model.md](compressor-model.md) - mod 0006's estimator as built: each stage, every calibrated constant, accuracy and limits
- [compressor-calibration.md](compressor-calibration.md) - how mod 0006 is calibrated end to end: the cal build, rig, stages and their commands, acceptance
- [compressor-hardware.md](compressor-hardware.md) - the compressor, its input and its page on stock 1.73: parameters, measured behaviour, the receive buffer, pan and routing, FX returns, the interrupt, the page hooks
- [midi-cc.md](midi-cc.md) - the MIDI CC map from the manual's implementation chart: trig, sequencer, kit, performance, sound and effect parameters, and which channel each is received on
- [machines.md](machines.md) - the 53-slot machine tables, the voice mask that gates the list and the engine, the 19 hidden machines (TEST, "2" variants, FUNC. GEN.), SY CHIP
- `lfo.md` - the per-track mod block, the parameter-record frame, and what a second LFO would cost
- [sound-storage.md](sound-storage.md) - the stored and live sound layouts, the load and save paths, how sounds are copied, and the spare room in each
- [tempo.md](tempo.md) - the tempo word, the top bar's BPM display bug, and the MIDI clock running fast of the setting

Starting point for anything else: MAIN OS is a C++ build with Itanium-ABI names
intact, so `strings build/stock_mainos.bin | c++filt` names most of the classes
before any disassembly happens - `ParameterPageView`, `ModDestListView`, `Kit`,
`Pattern`, `PatternSettings`, `FxSetup`, `MidiRpcDispatcher`, `FsRequestHandler`,
`Brain`. The Octatrack had none of this.
