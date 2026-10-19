#!/bin/bash
# Regenerate stub.s from teensy_drive.c (needs m68k-elf-gcc), as 0021-ext does.
# Compiled twice: TD_SLOTS=1 (the 12 B mailbox with td_pool_tab for 0021's user slots) and 0
# (c127fe8's 8 B mailbox, byte for byte); the build's param slots (--defsym P_SLOTS) picks one.
set -e
cd "$(dirname "$0")"
for v in 1 0; do
  m68k-elf-gcc -mcpu=5475 -msoft-float -Os -ffreestanding -fno-builtin -fomit-frame-pointer -fno-tree-switch-conversion -DTD_SLOTS=$v -S teensy_drive.c -o td$v.s.tmp
done
{
  echo "| Mod 0023 - the Teensy's SD card as a folder TEENSY in the file browser."
  echo "| GENERATED from teensy_drive.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os, TD_SLOTS=1 and 0); edit teensy_drive.c."
  echo "	.ifne P_SLOTS"
  grep -v '^\s*\.section\s\+\.note' td1.s.tmp | sed 's/\.section\t\.text,"a"/.text/'
  echo "	.else"
  grep -v '^\s*\.section\s\+\.note' td0.s.tmp | sed 's/\.section\t\.text,"a"/.text/'
  echo "	.endif"
} > stub.s
rm td1.s.tmp td0.s.tmp
