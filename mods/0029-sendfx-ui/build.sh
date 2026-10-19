#!/bin/bash
# Regenerate stub.s from sfu.c (needs m68k-elf-gcc), as 0025 does. The stub's sections become
# elekloader's .run (build.py elek_source): this mod lives in the 128 KB DDR area only.
set -e
cd "$(dirname "$0")"
m68k-elf-gcc -mcpu=5475 -msoft-float -Os -ffreestanding -fno-builtin -fomit-frame-pointer -fno-tree-loop-distribute-patterns -S sfu.c -o sfu.s.tmp
{
  echo "| Mod 0029 - Sidecar send FX pages: AMPLITUDE 2 (SEND FX 1/2) and the SEND FX 1/2 pages behind DELAY/REVERB."
  echo "| GENERATED from sfu.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit sfu.c."
  grep -v '^\s*\.section\s\+\.note' sfu.s.tmp | sed -e 's/\.section\t\.text,"a"/.text/' -e 's/^\t\.section\t\.rodata[^\t]*\t*.*/\t.text/' -e 's/^\t\.data$/\t.text/'
} > stub.s
rm sfu.s.tmp
