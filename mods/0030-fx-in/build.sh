#!/bin/bash
# Regenerate stub.s from fxin.c (needs m68k-elf-gcc), as 0029 does. The stub's sections become
# elekloader's .run (build.py elek_source): this mod lives in the 128 KB DDR area only.
set -e
cd "$(dirname "$0")"
m68k-elf-gcc -mcpu=5475 -msoft-float -Os -ffreestanding -fno-builtin -fomit-frame-pointer -fno-tree-loop-distribute-patterns -S fxin.c -o fxin.s.tmp
{
  echo "| Mod 0030 - FX in: delay + reverb return on Overbridge IN L/R, switched by the host (26 / 27)."
  echo "| GENERATED from fxin.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit fxin.c."
  echo "	.include \"symbols.inc\""
  grep -v '^\s*\.section\s\+\.note' fxin.s.tmp | sed -e 's/\.section\t\.text,"a"/.text/' -e 's/^\t\.section\t\.rodata[^\t]*\t*.*/\t.text/' -e 's/^\t\.data$/\t.text/'
} > stub.s
rm fxin.s.tmp
