#!/bin/bash
# tools/emu/us_base.sh TAG - the emulator base for the user-slot tests (tools/emu/us_emu.py): cold boot
# build/Analog-Rytm_MKII_OS1.73_<TAG>.syx in rytm-emu on a fresh card, the startup dialogs answered
# (YES, NO, NO, NO as rytm-emu's tools/looper_base.sh does), then USB CONFIG = OVERBRIDGE and TRANSPORT
# SEND on (GLOBAL > MIDI CONFIG > SYNC), only what is off switched on (its YES toggles), as looper_base.sh
# reads them. Writes, in rytm-emu (all git-ignored there; firmware-derived, never committed):
#   fw/AR173_us_<TAG>.syx          the firmware (a copy)
#   sections/us_<TAG>.img          the card (a copy of sections/led.img, as looper_base.sh starts from)
#   sections/us_<TAG>.snap         the state after the boot and the settings
#   sections/us_<TAG>.json         {"clock": the snapshot's clock in M instructions}
# and in this checkout build/emu/<TAG>/: the build's manifest and its 0021 / 0023 objects (us_emu.py's symbols).
# RYTM_EMU: rytm-emu's checkout (default ../rytm-emu, a sibling checkout of this repo).
set -eo pipefail
TAG=${1:?usage: us_base.sh TAG}
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
EMU=${RYTM_EMU:-$(cd "$(dirname "$0")/../../.." && pwd)/rytm-emu}
SYX="$ROOT/build/Analog-Rytm_MKII_OS1.73_$TAG.syx"
[ -f "$SYX" ] || { echo "no $SYX: build it first (tools/build.py --tag $TAG ...)"; exit 1; }
# the objects us_emu.py reads symbols from and the manifest (params): build/obj holds the last build's, so this runs
# right after building TAG; they are copied next to the tests' screens (build/emu/TAG, git-ignored)
python3 - "$ROOT" "$TAG" <<'PY'
import hashlib, json, sys
root, tag = sys.argv[1:]
m = json.load(open(f"{root}/build/manifest_{tag}.json"))
syx = open(f"{root}/build/{m['syx']}", "rb").read()
if hashlib.sha256(syx).hexdigest() != m["syx_sha256"]:
    sys.exit(f"build/manifest_{tag}.json is not the .syx's: build {tag} again")
PY
LAST=$(ls -t "$ROOT"/build/manifest_*.json | head -1)
[ "$LAST" = "$ROOT/build/manifest_$TAG.json" ] || { echo "build/obj is $(basename "$LAST")'s, not $TAG's: build $TAG again first"; exit 1; }
mkdir -p "$ROOT/build/emu/$TAG"
cp "$ROOT/build/manifest_$TAG.json" "$ROOT/build/emu/$TAG/manifest.json"
for m in 0021-ext 0023-teensy-drive; do cp "$ROOT/build/obj/$m.elf" "$ROOT/build/emu/$TAG/$m.elf"; done
cd "$EMU"
FW=fw/AR173_us_$TAG.syx CARD=sections/us_$TAG.img SNAP=sections/us_$TAG.snap
cp "$SYX" "$FW"
cp sections/led.img "$CARD"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
# dtboot RUN...: run dtboot, show its saved/FAULT lines, abort on a FAULT or a failed run
dtboot() {
  ./target/release/dtboot "$@" > "$TMP/log" 2>&1 || { tail -20 "$TMP/log"; echo "dtboot failed"; exit 1; }
  grep -E "saved|FAULT" "$TMP/log" || true
  if grep -q FAULT "$TMP/log"; then echo "FAULT in dtboot"; exit 1; fi
}
dtboot "$FW" --instr 4400M --every 4400M --card "$CARD" \
  --press YES@2600M --press NO@3000M --press NO@3400M --press NO@3800M --save "$TMP/cold.snap"
[ -f "$TMP/cold.snap" ] || { echo "no cold-boot snapshot"; exit 1; }
byte() { DTEMU_FW="$FW" ./target/release/dtpeek "$TMP/cold.snap" mem $1 1 | sed -n 's/^[0-9a-f]*: \([0-9a-f]*\).*/\1/p'; }
TS=$(byte 407c2d32); USB=$(byte 405c8e4c)
echo "after the cold boot: transport send $TS, usb config $USB"
yes_if_off() { [ "$1" = "01" ] || echo YES; }
# rytm-emu tools/looper_base.sh's walk: GLOBAL > MIDI CONFIG > SYNC (clock send left as it is), then USB CONFIG
KEYS="GLOBAL DOWN DOWN DOWN YES YES DOWN DOWN DOWN $(yes_if_off $TS) NO NO"
KEYS="$KEYS DOWN DOWN DOWN DOWN YES DOWN YES $(yes_if_off $USB) NO NO NO"
P=(); t=4500
for k in $KEYS; do
  P+=(--press "$k@${t}M"); t=$((t+100))
done
END=$((t+600))
dtboot "$FW" --load "$TMP/cold.snap" --card "$CARD" --instr $((END-4400))M --every 100000M --save "$SNAP" "${P[@]}"
[ -f "$SNAP" ] || { echo "no $SNAP"; exit 1; }
echo "{\"clock\": $END}" > sections/us_$TAG.json
echo "base: $EMU/$SNAP at ${END}M"
