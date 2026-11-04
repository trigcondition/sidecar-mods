| SPDX-License-Identifier: GPL-2.0-or-later
| a4_label.s - where a page's knob asks the parameter set for its names, each `moveal %a0@(N),%a0; jsr %a0@`: the short label in the knob's draw (N 104, 0x40023678, the
| view in a5), the long name a turn or a knob's key makes the title (N 108, 0x40025c26 and 0x400263aa, the view in a2). On entry a0 is the set's vtable and the stack
| {return, set, id}. a4_label or a4_title says the machine's name, or 0 and the set answers as stock's. And where a note preview gets a trig's notes (0x400291cc: a0 the deque
| to fill, the stack {return, the track's sequence, step, ARP on}): a4_preview reads them. Where a knob's draw calls the set's draw of its icon (0x40023532, the stack {return, set, id,
| value, ...}): a4_widget may name another id. Not audio code: the UI task. And the sound's load, 0x40008b58, in stock's load after it has written centre over the PM and FM ids
| [read: 0x40008870]: a2 live, a3 the stored sound, +8 from live. A sound with a machine gets PM1 and FM1 back: its NOISE G and H. The load's own call goes on, by a jmp: a jsr would
| shift its arguments. No machine, no copy: a stored word stock never reads stays out of an analog voice.
        .text
        .globl  a4_label_call, a4_title_call, a4_notes_call, a4_widget_call, a4_sound_loaded, a4_kbd_key_call
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

a4_widget_call:
        move.l  %a0,-(%sp)
        pea     8(%sp)                    | the draw's arguments
        jsr     a4_widget
        addq.l  #4,%sp
        move.l  (%sp)+,%a0
        move.l  132(%a0),%a0
        jmp     (%a0)

a4_sound_loaded:
        move.b  0xdc(%a3),%d0             | the stored sound's first mod byte: the machine, its top 4 bits (core-a4 store.c)
        and.l   #0xF0,%d0
        beq.s   1f
        move.w  64(%a3),56(%a2)           | slot 18 PM1
        move.w  222(%a3),214(%a2)         | slot 97 FM1
1:      jmp     0x40095988

| KeyboardView's key handler (0x400bd3d2) asks the event's code at 0x400bd3e8: `move.l %d2,-(%sp); jsr (%a3); addq.l #4,%sp`, a3 the getter 0x4005b6f0, d2 the
| event. The six bytes become this jsr: the code in d0, or none, as a4_kbd_key says (a4_remote.c). a3 stays the getter: the handler calls it again further on.
a4_kbd_key_call:
        move.l  %d2,-(%sp)
        jsr     a4_kbd_key
        addq.l  #4,%sp
        rts
