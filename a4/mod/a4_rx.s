| SPDX-License-Identifier: GPL-2.0-or-later
| a4_rx.s - the SysEx router's entry, 0x40066320 (data, len, interface), in the MIDI task: the mod sees each whole SysEx first [read: its caller 0x400654b8 from the task at
| 0x40065690]. a4_rx answers 1 for the Sidecar's head and stock never sees it; else the two instructions the site displaced, and on. Not audio code.
        .text
        .globl  a4_router
        .align  2
a4_router:
        move.l  12(%sp),-(%sp)
        move.l  12(%sp),-(%sp)
        move.l  12(%sp),-(%sp)
        jsr     a4_rx
        lea     12(%sp),%sp
        tst.l   %d0
        beq.s   1f
        rts
1:      lea     -16(%sp),%sp
        movem.l %d2-%d4/%a2,(%sp)
        jmp     0x40066328
