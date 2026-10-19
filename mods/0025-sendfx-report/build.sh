#!/bin/bash
# Regenerate stub.s from sfx.c (needs m68k-elf-gcc), as 0021-ext and 0024-ob-mix do.
# P_RR and P_MAXB are read by the assembler (the build's params rr and maxb).
set -e
cd "$(dirname "$0")"
m68k-elf-gcc -mcpu=5475 -msoft-float -Os -ffreestanding -fno-builtin -fomit-frame-pointer -fno-tree-loop-distribute-patterns -S sfx.c -o sfx.s.tmp
{
  echo "| Mod 0025 - Sidecar send FX reporter: sound index 0 per track and FX words 0/29/38..41 as host-link SysEx 0x20."
  echo "| GENERATED from sfx.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit sfx.c."
  echo "	.include \"symbols.inc\""
  grep -v '^\s*\.section\s\+\.note' sfx.s.tmp | sed -e 's/\.section\t\.text,"a"/.text/' -e 's/^\t\.section\t\.rodata[^\t]*\t*.*/\t.text/' -e 's/^\t\.data$/\t.text/'
} > stub.s
rm sfx.s.tmp
