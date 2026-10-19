| 0028-elek-hello: code in elekloader's DDR area (0x47BE0000-0x47C00000).
| Assembled by elekloader's SDK (-mcpu=54455), linked and placed by its linker: no
| fixed address here. .run is copied out by core-ar2's .boot before the OS clears .bss.

        .section .run, "ax"
        .globl  eh_magic, eh_ticks, eh_loops, eh_tick, eh_loop
eh_magic:
        .ascii  "EH01"
eh_ticks:
        .long   0                       | ev_tick calls (core-ar2, ~20 Hz)
eh_loops:
        .long   0                       | passes of the UI message loop (0x400a4684)

| ev_tick handler: void f(ctrl), C convention (d0-d1/a0-a1 free)
eh_tick:
        addq.l  #1, eh_ticks
        rts

| detour from 0x400a4684 (jmp eh_loop over `pea 0x41943f54`): count, replay the pea,
| rejoin at 0x400a468a. No register is touched.
eh_loop:
        addq.l  #1, eh_loops
        pea     0x41943f54
        jmp     0x400a468a
