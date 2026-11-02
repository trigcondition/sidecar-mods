| SPDX-License-Identifier: GPL-2.0-or-later
| a4_label.s - where a page's knob asks the parameter set for its names, each `moveal %a0@(N),%a0; jsr %a0@`: the short label in the knob's draw (N 104, 0x40023678, the
| view in a5), the long name a turn or a knob's key makes the title (N 108, 0x40025c26 and 0x400263aa, the view in a2). On entry a0 is the set's vtable and the stack
| {return, set, id}. a4_label or a4_title says the machine's name, or 0 and the set answers as stock's. And where a note preview gets a trig's notes (0x400291cc: a0 the deque
| to fill, the stack {return, the track's sequence, step, ARP on}): a4_preview reads them. Not audio code: the UI task.
        .text
        .globl  a4_label_call, a4_title_call, a4_notes_call
        .align  2
a4_label_call:
        move.l  %a0,-(%sp)
        move.l  12(%sp),-(%sp)            | id
        move.l  %a5,-(%sp)                | view
        jsr     a4_label
        addq.l  #8,%sp
        move.l  (%sp)+,%a0
        tst.l   %d0
        bne.s   1f
        move.l  104(%a0),%a0
        jmp     (%a0)
1:      rts

a4_title_call:
        move.l  %a0,-(%sp)
        move.l  12(%sp),-(%sp)
        move.l  %a2,-(%sp)
        jsr     a4_title
        addq.l  #8,%sp
        move.l  (%sp)+,%a0
        tst.l   %d0
        bne.s   1f
        move.l  108(%a0),%a0
        jmp     (%a0)
1:      rts

a4_notes_call:
        move.l  %a0,-(%sp)
        move.l  16(%sp),-(%sp)
        move.l  16(%sp),-(%sp)
        move.l  16(%sp),-(%sp)
        jsr     0x400b9e16
        lea     12(%sp),%sp
        move.l  16(%sp),-(%sp)            | ARP on
        move.l  4(%sp),-(%sp)             | the deque
        jsr     a4_preview
        lea     12(%sp),%sp
        rts
