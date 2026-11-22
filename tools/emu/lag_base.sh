#!/bin/bash
# tools/emu/lag_base.sh TAG - the emulator base TAGw for tools/emu/lag_emu.py's real-sample variants: the base of tools/emu/
# us_base.sh (run it for TAG first), but booted on a card whose /incoming holds six wav files (lag_emu.py --wavs writes them), so the
# stock sample browser can load them into the project's slots. Same boot, same settings as us_base.sh; the card image
# sections/lag_samples.img and the base sections/us_TAGw.* go to RYTM_EMU's git-ignored sections/.
set -eo pipefail
TAG=${1:?usage: lag_base.sh TAG}
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
EMU=${RYTM_EMU:-../rytm-emu}
W=${TAG}w
SYX=$(ls "$ROOT"/build/Analog-Rytm_MKII_OS*_"$TAG".syx | head -1)
[ -f "$SYX" ] && [ -d "$ROOT/build/emu/$TAG" ] || { echo "build $TAG and run tools/emu/us_base.sh $TAG first"; exit 1; }
mkdir -p "$ROOT/build/emu/$W"
cp "$ROOT/build/emu/$TAG"/* "$ROOT/build/emu/$W"/
rm -f "$ROOT"/build/emu/$W/lag-*.json
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
python3 "$ROOT/tools/emu/lag_emu.py" --wavs "$TMP/wav"
cd "$EMU"
FW=fw/AR173_us_$W.syx CARD=sections/us_$W.img SNAP=sections/us_$W.snap
cp "$SYX" "$FW"
cp -c sections/led.img sections/lag_samples.img
./target/release/dtcard sections/lag_samples.img add "$TMP"/wav/*.wav > /dev/null
cp -c sections/lag_samples.img "$CARD"
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
yes_if_off() { [ "$1" = "01" ] || echo YES; }
KEYS="GLOBAL DOWN DOWN DOWN YES YES DOWN DOWN DOWN $(yes_if_off $TS) NO NO"
KEYS="$KEYS DOWN DOWN DOWN DOWN YES DOWN YES $(yes_if_off $USB) NO NO NO"
P=(); t=4500
for k in $KEYS; do
  P+=(--press "$k@${t}M"); t=$((t+100))
done
END=$((t+600))
dtboot "$FW" --load "$TMP/cold.snap" --card "$CARD" --instr $((END-4400))M --every 100000M --save "$SNAP" "${P[@]}"
[ -f "$SNAP" ] || { echo "no $SNAP"; exit 1; }
echo "{\"clock\": $END}" > sections/us_$W.json
echo "base: $EMU/$SNAP at ${END}M"
