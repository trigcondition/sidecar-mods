#!/bin/bash
# Regenerate stub.s from ext.c (needs m68k-elf-gcc), as 0020-dmach does.
# Compiled twice: with EXT_SLOTS=1 (the user slots) and EXT_SLOTS=0 (the pre-slot image of
# c127fe8, byte for byte); the build's param slots (--defsym P_SLOTS) picks one with .if.
set -e
cd "$(dirname "$0")"
for v in 1 0; do
  m68k-elf-gcc -mcpu=5475 -msoft-float -Os -ffreestanding -fno-builtin -fomit-frame-pointer -fno-tree-switch-conversion -DEXT_SLOTS=$v -S ext.c -o ext$v.s.tmp
done
{
  echo "| Mod 0021 - external voice machines (PLAITS, DAISYSP) reporting trigs and P1..P16 over USB."
  echo "| GENERATED from ext.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os, EXT_SLOTS=1 and 0); edit ext.c."
  echo "	.ifne P_SLOTS"
  grep -v '^\s*\.section\s\+\.note' ext1.s.tmp | sed 's/\.section\t\.text,"a"/.text/'
  echo "	.else"
  grep -v '^\s*\.section\s\+\.note' ext0.s.tmp | sed 's/\.section\t\.text,"a"/.text/'
  echo "	.endif"
} > stub.s
rm ext1.s.tmp ext0.s.tmp
