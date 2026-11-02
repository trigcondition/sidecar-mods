#!/bin/bash
# build.sh - the Analog Four MKII OS with the Sidecar mod: your stock OS 1.56 with elekloader's core-a4 and the mod in mod/. Needs python3, m68k-elf-gcc and an
# elekloader checkout at c150ac5 (https://github.com/irpina/elekloader). Never commit the output: it holds Elektron's firmware.
#   STOCK=/path/Analog-Four_MKII_OS1.56.syx ELEKLOADER=/path/elekloader ./build.sh [OUTDIR]
set -euo pipefail
H=$(cd "$(dirname "$0")" && pwd)
: "${STOCK:?STOCK: your Analog-Four_MKII_OS1.56.syx}" "${ELEKLOADER:?ELEKLOADER: an elekloader checkout}"
STOCK=$(cd "$(dirname "$STOCK")" && pwd)/$(basename "$STOCK")
case $(shasum -a 256 "$STOCK" | cut -d' ' -f1) in
  5aea489db3e747547f71d5e08a2d20253149fe6258defad60306402d2fc23cb5) ;;
  *) echo "$STOCK is not stock Analog Four MKII OS 1.56" >&2; exit 1 ;;
esac
OUT=${1:-$H/out}; mkdir -p "$OUT"; OUT=$(cd "$OUT" && pwd)
V=$(python3 -c "import json;print(json.load(open('$H/mod/mod.json'))['version'])")
export ELEKLOADER_CROSS=${ELEKLOADER_CROSS:-m68k-elf-} PYTHONDONTWRITEBYTECODE=1
cd "$ELEKLOADER"
python3 -m elekloader.sdk.build mods/core-a4 --stock "$STOCK" --out "$OUT"
python3 -m elekloader.sdk.build "$H/mod" --stock "$STOCK" --out "$OUT"
python3 -m elekloader.lint "$OUT/sidecar-a4-$V.elemod" --stock "$STOCK" --with "$OUT/core-0.3.elemod"
python3 -m elekloader.patch --stock "$STOCK" --mod "$OUT/core-0.3.elemod" --mod "$OUT/sidecar-a4-$V.elemod" \
  --out "$OUT/a4156_sidecar.syx" --version ${STAMP:-SA02} --lockfile "$H/a4156.lock.json"
shasum -a 256 "$OUT/a4156_sidecar.syx"
