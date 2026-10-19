#!/bin/bash
# Regenerate stub.s from rui.c (needs m68k-elf-gcc), as 0029 does. The stub's sections become elekloader's .run
# (build.py elek_source); .comm/.bss stays .bss in the area: this mod lives in the 128 KB DDR area only.
set -e
cd "$(dirname "$0")"
m68k-elf-gcc -mcpu=5475 -msoft-float -Os -ffreestanding -fno-builtin -fomit-frame-pointer -fno-tree-loop-distribute-patterns -Wall -Werror -S rui.c -o rui.s.tmp
{
  echo "| Mod 0026 - remote UI: the Rytm as a terminal for Sidecar-drawn pages (M1)."
  echo "| GENERATED from rui.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit rui.c."
  grep -v '^\s*\.section\s\+\.note' rui.s.tmp | sed -e 's/\.section\t\.text,"a"/.text/' -e 's/^\t\.section\t\.rodata[^\t]*\t*.*/\t.text/' -e 's/^\t\.data$/\t.text/'
} > stub.s
rm rui.s.tmp
