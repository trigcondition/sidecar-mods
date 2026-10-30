#!/bin/bash
# tools/build_rui.sh TAG [extra build.py args] - the rui build set (the Sidecar's mods: 0026 remote UI with 0022's router,
# 0027 elekloader, ...) built and verified, as every rui<NNNN> .syx since rui1036 was made. `make verify` builds the
# mod.toml default set (0022 keys=1), which can never coexist with 0026's uart detour (registry: "never both in one
# build"), so it is not the gate for this set: this is. tools/verify.py must PASS on the exact .syx that is flashed
# (docs/HAZARDS.md "Verify before flashing, every time"). Prints the verdict and the .syx's SHA256.
set -e
cd "$(dirname "$0")/.."
tag=${1:?usage: tools/build_rui.sh TAG [extra build.py args]}; shift
MODS="0014-hidden-machines 0021-ext 0022-looper 0023-teensy-drive 0025-sendfx-report 0027-elekloader 0028-elek-hello 0029-sendfx-ui 0026-remote-ui 0030-fx-in"
[ -n "$RUI_DEV" ] && MODS="$MODS 0031-remote-keys"   # dev builds only: REMOTE KEYS is out of production (2026-10-29)
PARAMS="--param 0014-hidden-machines:variants=0 --param 0014-hidden-machines:funcgen=0 --param 0014-hidden-machines:test=0
 --param slots=1 --param 0022-looper:keys=0 --param 0022-looper:sfx=1 --param 0022-looper:rui=1 --param 0022-looper:fxin=1
 --area-elek 0022-looper --area-elek 0025-sendfx-report"
mkdir -p build
.venv/bin/python tools/build.py --tag "$tag" --mods $MODS $PARAMS "$@" > "build/b_$tag.log" 2>&1 || { echo "$tag build FAIL"; tail -15 "build/b_$tag.log"; exit 1; }
.venv/bin/python tools/verify.py --tag "$tag" > "build/v_$tag.log" 2>&1 || { echo "$tag verify FAIL"; tail -15 "build/v_$tag.log"; exit 1; }
echo "$tag: $(tail -1 "build/v_$tag.log")"
shasum -a 256 "build/Analog-Rytm_MKII_OS1.73_$tag.syx"
