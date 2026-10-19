#!/bin/bash
# Regenerate stub.s from looper.c (needs m68k-elf-gcc), as 0021-ext does.
# Compiled twice: LP_SLOTS=1 (the router passes 0021's user-slot SysEx) and 0 (c127fe8's
# router, byte for byte); the build's param slots (--defsym P_SLOTS) picks one with .if.
set -e
cd "$(dirname "$0")"
for v in 1 0; do
  m68k-elf-gcc -mcpu=5475 -msoft-float -Os -ffreestanding -fno-builtin -fomit-frame-pointer -DLP_SLOTS=$v -DLP_SFX=0 -DLP_RUI=0 -DLP_FXIN=0 -S looper.c -o looper$v.s.tmp
done
# sfx=1 (with 0029-sendfx-ui): the slots router plus SENDFX 21/22 to 0029's mailbox
m68k-elf-gcc -mcpu=5475 -msoft-float -Os -ffreestanding -fno-builtin -fomit-frame-pointer -DLP_SLOTS=1 -DLP_SFX=1 -DLP_RUI=0 -DLP_FXIN=0 -S looper.c -o looper2.s.tmp
# rui=1 (with 0026-remote-ui; needs sfx=1): the sfx router plus 0x30..0x3F to 0026's mailbox
m68k-elf-gcc -mcpu=5475 -msoft-float -Os -ffreestanding -fno-builtin -fomit-frame-pointer -DLP_SLOTS=1 -DLP_SFX=1 -DLP_RUI=1 -DLP_FXIN=0 -S looper.c -o looper3.s.tmp
# fxin=1 (with 0030-fx-in; needs rui=1): the rui router plus FX IN (26) to 0030's switch
m68k-elf-gcc -mcpu=5475 -msoft-float -Os -ffreestanding -fno-builtin -fomit-frame-pointer -DLP_SLOTS=1 -DLP_SFX=1 -DLP_RUI=1 -DLP_FXIN=1 -S looper.c -o looper4.s.tmp
{
  echo "| Mod 0022 - looper mode: TRK + REC, pads as clip slots, reported to the USB host."
  echo "| GENERATED from looper.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os, LP_SLOTS=1 and 0); edit looper.c."
  echo "	.ifne P_FXIN"
  echo "	.ifeq P_RUI"
  echo "	.error \"0022-looper: fxin=1 needs rui=1 (and sfx=1, slots=1)\""
  echo "	.endif"
  grep -v '^\s*\.section\s\+\.note' looper4.s.tmp | sed -e 's/\.section\t\.text,"a"/.text/' -e 's/^\t\.section\t\.rodata[^\t]*\t*.*/\t.text/'
  echo "	.else"
  echo "	.ifne P_RUI"
  echo "	.ifeq P_SFX"
  echo "	.error \"0022-looper: rui=1 needs sfx=1 (and slots=1)\""
  echo "	.endif"
  grep -v '^\s*\.section\s\+\.note' looper3.s.tmp | sed -e 's/\.section\t\.text,"a"/.text/' -e 's/^\t\.section\t\.rodata[^\t]*\t*.*/\t.text/'
  echo "	.else"
  echo "	.ifne P_SFX"
  grep -v '^\s*\.section\s\+\.note' looper2.s.tmp | sed -e 's/\.section\t\.text,"a"/.text/' -e 's/^\t\.section\t\.rodata[^\t]*\t*.*/\t.text/'
  echo "	.else"
  echo "	.ifne P_SLOTS"
  grep -v '^\s*\.section\s\+\.note' looper1.s.tmp | sed -e 's/\.section\t\.text,"a"/.text/' -e 's/^\t\.section\t\.rodata[^\t]*\t*.*/\t.text/'
  echo "	.else"
  grep -v '^\s*\.section\s\+\.note' looper0.s.tmp | sed -e 's/\.section\t\.text,"a"/.text/' -e 's/^\t\.section\t\.rodata[^\t]*\t*.*/\t.text/'
  echo "	.endif"
  echo "	.endif"
  echo "	.endif"
  echo "	.endif"
} > stub.s
rm looper1.s.tmp looper0.s.tmp looper2.s.tmp looper3.s.tmp looper4.s.tmp
