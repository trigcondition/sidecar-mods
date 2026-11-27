| sfu_emu.py "pretick": calls 0029's F-set wrappers by hand, in the emulator, with whatever st.ticks the run gives them
| (the OS never calls them before the first tick, so a test must). The run pokes a `jmp stub` over sfu_tick's first
| word, so the stub runs in the UI task every tick and returns to the dispatcher without the real tick.
| Assembled by the test: m68k-elf-as -mcpu=5475 --defsym SET=.. FREAD=.. FWRITE=.. FLGET=.. FLSET=.. SEEFX=.. RES=..
| Results (u32 at RES + n): 0 f_read, 4 f_write, 8 f_lget, 12 f_lset, 16 f_write on a BW id.
        .text
        .globl  stub
stub:
        lea     -16(%sp),%sp
        movem.l %d0-%d1/%a0-%a1,(%sp)
        | f_read(set, ID0 + 4): P2 of SEND FX 1 (an even index: the hi half)
        move.l  #18,-(%sp)
        move.l  #SET,-(%sp)
        jsr     FREAD
        addq.l  #8,%sp
        move.l  %d0,RES
        | f_write(set, ID0 + 4, 0x3a00, 0, 0)
        clr.l   -(%sp)
        clr.l   -(%sp)
        move.l  #0x3a00,-(%sp)
        move.l  #18,-(%sp)
        move.l  #SET,-(%sp)
        jsr     FWRITE
        lea     20(%sp),%sp
        move.l  %d0,RES+4
        | f_lget(set, ID0 + 4, step 0)
        clr.l   -(%sp)
        move.l  #18,-(%sp)
        move.l  #SET,-(%sp)
        jsr     FLGET
        lea     12(%sp),%sp
        move.l  %d0,RES+8
        | f_lset(set, ID0 + 4, 0x3a00, step 2)
        move.l  #2,-(%sp)
        move.l  #0x3a00,-(%sp)
        move.l  #18,-(%sp)
        move.l  #SET,-(%sp)
        jsr     FLSET
        lea     16(%sp),%sp
        move.l  %d0,RES+12
        | f_write(set, 1, 0x2a00, 0, 0): record 1 = FX 1's BASE (the host's BASE / WIDTH words)
        clr.l   -(%sp)
        clr.l   -(%sp)
        move.l  #0x2a00,-(%sp)
        move.l  #1,-(%sp)
        move.l  #SET,-(%sp)
        jsr     FWRITE
        lea     20(%sp),%sp
        move.l  %d0,RES+16
        | see_fxset(another set): only compared, never dereferenced
        move.l  #0x80001234,-(%sp)
        jsr     SEEFX
        addq.l  #4,%sp
        movem.l (%sp),%d0-%d1/%a0-%a1
        lea     16(%sp),%sp
        rts
