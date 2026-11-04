#!/bin/bash
# pack_release.sh - the assets of an a4-v... release, in one folder, checked: never the .syx. Touches no network.
#   ELEKLOADER=/path/elekloader a4/tools/pack_release.sh BUILD_OUT RELEASE_DIR
# BUILD_OUT: build.sh's folder, the .elemod files are taken from it by name and nothing else is.
set -euo pipefail
H=$(cd "$(dirname "$0")/.." && pwd)
: "${ELEKLOADER:?ELEKLOADER: an elekloader checkout at c150ac5}"
OUT=${1:?build.sh output folder}; REL=${2:?release folder}
REV=c150ac583a4b7e6d64680d5592f4a40f409193f7
# no release while an UNRELEASED mark is left in the tree (a4/README.md, docs/ELEKLOADER.md, ...)
python3 "$H/../tools/check_unreleased.py"
V=$(python3 -c "import json,sys;print(json.load(open(sys.argv[1]))['version'])" "$H/mod/mod.json")
# RELEASE_DIR is emptied: only a missing or empty folder, or one this script packed before (its SHA256SUMS), and never
# the checkout, its parent or the home folder
if [ -e "$REL" ]; then
  R=$(cd "$REL" && pwd)
  case "$R" in /|"$HOME"|"$(cd "$H/.." && pwd)"|"$(cd "$H/../.." && pwd)") echo "pack_release.sh: refusing RELEASE_DIR $REL" >&2; exit 1 ;; esac
  if [ -n "$(ls -A "$REL")" ] && [ ! -f "$REL/SHA256SUMS" ]; then
    echo "pack_release.sh: $REL is not empty and holds no SHA256SUMS (not a release folder): refusing to empty it" >&2; exit 1
  fi
fi
rm -rf "$REL"; mkdir -p "$REL"
cp "$OUT/sidecar-a4-$V.elemod" "$OUT/core-0.3.elemod" "$H/a4156.lock.json" "$H/../LICENSE" "$H/../NOTICE" "$REL/"
# GPL-2.0 section 3: core-0.3.elemod's source and the builder
git -C "$ELEKLOADER" archive --format=tar.gz --prefix=elekloader-c150ac5/ $REV > "$REL/elekloader-c150ac5-src.tar.gz"
{ echo "a4 $V, built from sidecar-mods $(git -C "$H" rev-parse HEAD)$(git -C "$H" diff --quiet HEAD || echo ' (uncommitted changes)')"
  echo "elekloader $(git -C "$ELEKLOADER" rev-parse HEAD) (builder, core-a4)"
  "${ELEKLOADER_CROSS:-m68k-elf-}gcc" --version | head -1; "${ELEKLOADER_CROSS:-m68k-elf-}as" --version | head -1
  python3 --version; uname -sm; } > "$REL/TOOLCHAIN.txt"
( cd "$REL"; shasum -a 256 * > ../SHA256SUMS.$$; mv ../SHA256SUMS.$$ SHA256SUMS; cat SHA256SUMS )
python3 "$H/tools/release_assets.py" "$REL" --tag "a4-v$V"
