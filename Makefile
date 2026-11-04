# Analog Rytm MKII firmware mods.
PY := .venv/bin/python

.PHONY: all setup symbols layout build verify cavescan ghidra disasm clean port \
	comp-selftest comp-cal-gen comp-cal-check comp-cal-build cave-selftest release release-check

all: verify

# The container tool, pinned to the commit the build was verified against.
EFT_URL := https://github.com/mischa85/elektron-firmware-tool
EFT_REV := a5bce9a6af644386d900924082993a805e812874
# elekloader (GPL-2.0-or-later), executed only by builds with 0027-elekloader; tools/build.py
# checks this same commit (ELEK_REV). Its core-ar2 0.1 is built from the source at
# ELEK_CORE_REV in build.py. mods/0027-elekloader/design.md.
ELEK_URL := https://github.com/irpina/elekloader
ELEK_REV := c150ac583a4b7e6d64680d5592f4a40f409193f7

setup:
	python3 -m venv .venv
	.venv/bin/pip install -r requirements.txt
	test -d vendor/elektron-firmware-tool/.git || git clone $(EFT_URL) vendor/elektron-firmware-tool
	git -C vendor/elektron-firmware-tool checkout --quiet $(EFT_REV)
	$(MAKE) -C vendor/elektron-firmware-tool
	test -d vendor/elekloader/.git || git clone $(ELEK_URL) vendor/elekloader
	git -C vendor/elekloader checkout --quiet $(ELEK_REV)

symbols:
	$(PY) tools/symbols.py

# The OS: the tree's own (re/symbols.toml [meta] target, 1.73), or OS=1.74 for its port (re/os/1.74.toml): then
# `make release` / `release-check` / `build` / `verify` write the port's tree (tools/ostarget.py port, build/os/1.74)
# and run there; the release lands in build/release/<VERSION>-os1.74/ here. `make release-all`: both OSes.
TREE_OS := $(shell sed -n 's/^target *= *"OS\(.*\)"/\1/p' re/symbols.toml | head -1)
OS ?= $(TREE_OS)
osfact = $(shell $(PY) tools/ostarget.py info $(1))

# The release for the elekloader web page (docs/ELEKLOADER.md): the Sidecar set as ONE elemod,
# rytm-sidecar-$(VERSION).elemod (on 1.74 rytm-sidecar-$(VERSION)-os1.74.elemod), with core-ar2 0.1 beside it, in
# build/release/$(VERSION)/ (1.74: build/release/$(VERSION)-os1.74/). The set and its params are the rui1051 image's
# (the one on the user's unit). VERSION is the one place the release version is set (build.py reads it too).
VERSION := $(shell cat VERSION)
REL_TAG := rel$(subst .,-,$(VERSION))
# the rui1051 set without 0028-elek-hello (a test counter; nothing needs it). 0031-remote-keys stays out of production
# builds (the user, 2026-10-29: a dev / test feature; its sources stay for dev builds: RUI_DEV=1 tools/build_rui.sh)
RELEASE_MODS := 0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive 0025-sendfx-report \
	0026-remote-ui 0027-elekloader 0029-sendfx-ui 0030-fx-in
RELEASE_ARGS := --param 0014-hidden-machines:variants=0 --param 0014-hidden-machines:funcgen=0 \
	--param 0014-hidden-machines:test=0 --param slots=1 --param 0022-looper:keys=0 \
	--param 0022-looper:sfx=1 --param 0022-looper:rui=1 --param 0022-looper:fxin=1 \
	--area-elek 0021-ext --area-elek 0022-looper --area-elek 0025-sendfx-report

.PHONY: port release-all
ifneq ($(OS),$(TREE_OS))
# ---- another OS: the port's tree, and the same targets run there
PORT := build/os/$(OS)
PORT_REL := build/release/$(VERSION)-os$(OS)

port:
	$(PY) tools/ostarget.py port $(OS)

build verify: port
	$(MAKE) -C $(PORT) $@ $(if $(TAG),TAG=$(TAG),)

release: port
	$(MAKE) -C $(PORT) release
	rm -rf $(PORT_REL) && mkdir -p build/release && cp -R $(PORT)/build/release/$(VERSION) $(PORT_REL)
	cp $(PORT)/build/Analog-Rytm_MKII_OS$(OS)_$(REL_TAG).syx build/
	@echo "OS $(OS) release: $(PORT_REL)"

release-check:
	$(MAKE) -C $(PORT) release-check

else
# ---- the tree's own OS
REL := build/release/$(VERSION)
CORE_REV := $(call osfact,core_rev)
CORE_SHORT := $(shell echo $(CORE_REV) | cut -c1-7)
BUNDLE_SUFFIX := $(call osfact,bundle_suffix)

release: symbols layout
	$(PY) tools/comp/calib_tables.py --check
	$(PY) tools/build.py --tag $(REL_TAG) --elek-bundle --mods $(RELEASE_MODS) $(RELEASE_ARGS)
	$(PY) tools/verify.py --tag $(REL_TAG)
	rm -rf $(REL) && mkdir -p $(REL)
	cp build/elek/$(REL_TAG)/core/core-*.elemod $(REL)/
	cp build/elek/$(REL_TAG)/mods/rytm-sidecar/out/rytm-sidecar-$(VERSION).elemod \
		$(REL)/rytm-sidecar-$(VERSION)$(BUNDLE_SUFFIX).elemod
	cp LICENSE NOTICE $(REL)/
	# GPL-2.0 section 3: the corresponding source of the core elemod (and the builder) beside it
	git -C vendor/elekloader archive --format=tar.gz --prefix=elekloader-$(CORE_SHORT)-core-ar2/ \
		$(CORE_REV) mods/core mods/core-ar2 LICENSE NOTICE \
		> $(REL)/elekloader-$(CORE_SHORT)-core-ar2-src.tar.gz
	git -C vendor/elekloader archive --format=tar.gz --prefix=elekloader-c150ac5/ \
		c150ac583a4b7e6d64680d5592f4a40f409193f7 > $(REL)/elekloader-c150ac5-src.tar.gz
	{ echo "release $(VERSION) for OS $(TREE_OS), built from sidecar-mods $$(git rev-parse HEAD)$$(git diff --quiet HEAD || echo ' (uncommitted changes)')"; \
	  echo "elekloader $$(git -C vendor/elekloader rev-parse HEAD) (builder), core-ar2 from $(CORE_REV)"; \
	  m68k-elf-as --version | head -1; $(PY) --version; uname -sm; } > $(REL)/TOOLCHAIN.txt
	cd $(REL) && { command -v sha256sum > /dev/null && SUM="sha256sum" || SUM="shasum -a 256"; \
		$$SUM *.elemod *.tar.gz LICENSE NOTICE TOOLCHAIN.txt > SHA256SUMS; } && cat SHA256SUMS

# Only the published files + the stock .syx, through upstream's command line and the web
# page's code path: MAIN OS must be the release build's, sections 1/2/5/8 stock.
release-check:
	$(PY) tools/release_check.py --dir $(REL) --expect build/mainos_$(REL_TAG).bin \
		--expect-syx build/Analog-Rytm_MKII_OS$(TREE_OS)_$(REL_TAG).syx --doc docs/ELEKLOADER.md
endif

# Both OSes' releases, each checked: the tree's own, then the port's.
release-all:
	$(MAKE) release release-check
	$(MAKE) release release-check OS=1.74

layout:
	$(PY) tools/layout.py

# Mod 0006's calib.inc must be what its calibration.toml gives before anything
# is assembled from it.
ifeq ($(OS),$(TREE_OS))
build: symbols layout
	$(PY) tools/comp/calib_tables.py --check
	$(PY) tools/build.py

verify: build
	$(PY) tools/verify.py $(if $(TAG),--tag $(TAG),)
endif

# Candidate code caves in the stock image. The cave pool in
# registry/allocations.toml comes from this scan, not from anyone else's survey.
cavescan: build
	$(PY) tools/cavescan.py

ghidra:
	./re/ghidra/import.sh

# Whole-image disassembly with ColdFire EMAC decoding. objdump takes the ISA
# from the ELF header, so a raw binary is read as plain m68k and every EMAC
# opcode - mac, msac and the movclr that reads an accumulator and clears it -
# comes out as ".short". The .archtag section holds one EMAC instruction purely
# so the assembler stamps the ISA; .text carries the image at its own addresses.
MAINOS_BASE := 0x40000400
disasm: build
	printf '\t.section .archtag,"a"\n\tmovclr.l %%acc0,%%d0\n\t.text\n\t.incbin "build/stock_mainos.bin"\n' \
		> build/mainos_wrap.s
	m68k-elf-as -mcpu=5475 build/mainos_wrap.s -o build/mainos_wrap.o
	m68k-elf-objdump -d -j .text --adjust-vma=$(MAINOS_BASE) build/mainos_wrap.o \
		| sed 's/^ *//' > build/mainos_emac.dis

# Regression tests for the cave analysis. Needs `make build` for the image and
# `make disasm` for the dead-code pass; the tests that need either skip without it.
cave-selftest:
	$(PY) tools/test_cavescan.py

# Mod 0006's calibration (re/subsystems/compressor-calibration.md). Every
# calibrated value lives in mods/0006-comp-preview/calibration.toml; the fits
# run from tools/comp/calibrate.py on a calibration's recordings.
# comp-selftest: host checks of the calibration frames' decoding, and of a
# run's preflight, verification and report on synthetic captures.
# comp-cal-gen: write calib.inc from calibration.toml.
# comp-cal-check: calib.inc is current.
comp-selftest:
	$(PY) tools/comp/calframes_selftest.py
	$(PY) tools/comp/verify_selftest.py > /dev/null && echo "verify: PASS"
	$(PY) tools/comp/preflight_selftest.py

comp-cal-gen:
	$(PY) tools/comp/calib_tables.py

comp-cal-check:
	$(PY) tools/comp/calib_tables.py --check

# The calibration image: 0006 alone, cal = 1. Flash
# build/Analog-Rytm_MKII_OS1.73_cal.syx, then calibrate.py.
comp-cal-build: symbols layout
	$(PY) tools/comp/calib_tables.py --check
	$(PY) tools/build.py --tag cal --mods 0006-comp-preview --param 0006-comp-preview:cal=1
	$(PY) tools/verify.py --tag cal

# Everything under build/ is regenerated from the image except build/comp, a
# calibration's recordings off the hardware, and build/comp_rig.json, the rig's
# ports and the calibration project's roles.
clean:
	find build -mindepth 1 -maxdepth 1 ! -name comp ! -name comp_rig.json -exec rm -rf {} +
