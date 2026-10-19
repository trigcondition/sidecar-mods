#!/bin/bash
# Regenerate stub.s from dmach.c (needs m68k-elf-gcc). The build assembles stub.s
# like any other mod's; this is the only step that needs a C compiler.
set -e
cd "$(dirname "$0")"
python3 gen_tables.py
m68k-elf-gcc -mcpu=5475 -msoft-float -Os -ffreestanding -fno-builtin -fomit-frame-pointer -S dmach.c -o dmach.s.tmp
{
  echo "| Mod 0020 - digital machines on the digital layer (machines 35, 38, 39, 41, 42)."
  echo "| GENERATED from dmach.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit dmach.c."
  echo "| The FM core follows Mutable Instruments Braids (MIT, (c) 2012 Emilie Gillet)."
  grep -v '^\s*\.section\s\+\.note' dmach.s.tmp | sed 's/\.section\t\.text,"a"/.text/'
} > stub.s
rm dmach.s.tmp
