        | Mod 0013 - every voice to MAIN through the DAC.
        |
        | All eight voices leave the analog main bus. Each audio interrupt the
        | voice slots of the receive buffer - the voices after their analog
        | filter and amp - are panned and summed here and added to the PRE
        | return pair of the output ring, which the DAC puts back into the
        | analog mix ahead of the master distortion and compressor. A voice
        | stock has off the main bus (ROUTE TO MAIN off) stays out of the sum.
        |
        | Switched at run time by DAC SUM, the last item of the AUDIO ROUTING
        | menu. OFF is stock's routing and no sum. It is saved with the
        | project's globals, beside the routing it overrides: stored bytes
        | +12 (tag) and +13 of projectGlobalsStorage_v2_t, which stock's load
        | and save never touch; a project without the tag loads as OFF.
        |
        | Each voice is high-passed before the sum, one pole, at the cutoff its
        | track's HPF sets: a knob on a second FILTER page (page 13, reached by
        | pressing FILTER again while DAC SUM is on), on the top-left knob. The value
        | lives in the live sound's spare bytes +0x6d (tag) and +0x6e (step),
        | which sound_save writes to the stored record's spare slot 42 and
        | sound_load reads back (sound-storage.md); a tick in the UI's idle
        | routine copies every track's into hpf_track for the audio interrupt.
        |
        | Three detours, and a fourth in the timing build:
        |   route_all     0x401212b6  the route mask store: every voice off main
        |   vs_main       0x40121364  after the receive buffer fills: the filter,
        |                             in place, and the sum
        |   vs_alt        0x4011fde2  the same on the interrupt's other path
        |   dac_menu_add  0x400d901c  the menu's item list: DAC SUM after USB TO MAIN
        |   t_emit        0x40121396  timing only: the timing words, before USB
        | and, for the HPF page and knob, chained behind 0004's gates where 0004
        | is built and standing alone where it is not:
        |   hpf_page_info 0x400ff592  page_info's out-of-range return: page 13
        |   hpf_cycle     0x4003ab86  the page key's cycle: FILTER's page 2 only
        |                             while DAC SUM is on
        |   hpf_get       0x4003846a  page_get_value: the dial, id 5
        |   hpf_delta     0x400378bc  param_apply_delta: the knob, id 5
        |   hpf_text      0x400a85f8  param_value_text: the popup, id 5
        | and for keeping the value:
        |   hpf_save      0x40008492  sound_save, after its memset: slot 42
        |   hpf_load      0x4000826a  sound_load, after its clear: the live bytes
        |   hpf_refresh   0x400a2aae  the screen's idle tick: hpf_track
        | and for keeping DAC SUM with the project:
        |   dac_load      0x40007660  projectGlobals_t's load, after its version check
        |   dac_save      0x40007bb0  projectGlobals_t's save, before its last fields
        |
        | Addresses and layouts: re/subsystems/compressor-hardware.md.

        .include "symbols.inc"
        .include "shared.inc"

        .equ    RXBUF,          0x80007440  | receive buffer, voice slot s at +8 + 4s
        .equ    RXSTRIDE,       48
        .equ    FRAMES,         32
        .equ    VCA_L,          0x800063ca  | uint16 per physical voice
        .equ    VCA_R,          0x800063da
        .equ    SLOT_MAP,       0x401ef1d0  | physical voice -> receive slot, longs
        .equ    VOICE_OWNER,    0x40290dd8  | physical voice -> owning track, bytes
        .equ    MAIN_OFF,       0x8000ed6c  | per-track main-disable bits, or
        .equ    MAIN_OFF_G,     0x8000ee58  | the global set when MAIN_OFF < 0

        | The output ring: four slots of 32 frames at 0x80000000 + idx * 2048,
        | idx at OUT_IDX, 16 channels a frame. The PRE consumer at 0x4010eb26
        | writes channels 12 and 13 as (acc >> 8), logical, so a word shifted
        | left 8 is its Q31 value again.
        .equ    OUT_RING,       0x80000000
        .equ    OUT_IDX,        0x42f92124
        .equ    OUT_PRE,        48          | channel 12's byte offset in a frame
        .equ    OUT_STRIDE,     64

        .equ    ROUTE_RESUME,   0x401212bc
        .equ    MAIN_RESUME,    0x4012136c        | after `lea 0x4013f56c,%a0`
        .equ    MAIN_LEA,       0x4013f56c
        .equ    ALT_FILL,       0x4010e944        | the other path's fill
        .equ    ALT_RESUME,     0x4011fde8
        .equ    FX_SENDS,       0x4010e650        | the timing build's emitter
        .equ    EMIT_RESUME,    0x401213a0
        .equ    DTCN0,          0xfc07000c        | DMA timer 0, about 130 MHz
        .equ    MUP_INT,        0x8000fbde        | compressor MUP's integer part, CC 81
        .equ    T_SLOT,         8 + 4 * 7         | voice slot 7, the timing build's channel
        | vs_body's stack table, above the saved MACSR and registers
        .equ    COEF,           64                | (cL, cR) per slot, and a spare word
        .equ    ATAB,           132               | a per slot

        | AudioRoutingMenuView's item list, 0x400d8cb6. Each item is four
        | std::function objects on the stack - label, an empty one, the value
        | drawer, the value changer - a 0x54-byte MenuItem, and an append
        | through the view's vtable +8. The label and drawer take USB OUT's
        | managers: its lambdas capture nothing, as those do. The changer
        | captures the view, for the redraw, and has a manager of its own.
        .equ    MENU_ITEM_CTOR, 0x40072f50
        .equ    MGR_LABEL,      0x400d8aca
        .equ    MGR_DRAW,       0x400d8b1c
        .equ    MENU_RESUME,    0x400d9022
        .equ    TEXT_WIDTH,     0x40071b86        | (font, -1, std::string *) -> px
        .equ    MENU_FONT,      0x4027a6c8
        .equ    VIEW_INVALIDATE, 0x40078514       | (view + 56), as 0x400d9038 does

        .if     P_K < 1 || P_K > 16384
        .error  "0013-voice-dac: k must be 1 .. 16384"
        .endif

        | The HPF page and knob.
        .equ    PAGE_FILTER,    6
        .equ    PAGE_HPF,       13
        .equ    ID_HPF,         5                 | a dead Error record, renamed
        .equ    HPF_STEPS,      48                | OFF, then steps 1..48
        .equ    OFF_HPF_TAG,    0x6d              | live sound: tag, then the step
        .equ    OFF_HPF_STEP,   0x6e
        .equ    HPF_TAG,        0xb5
        .equ    OFF_POLE,       0x7fff7fff        | hpf_pole[0], OFF: 1 - 2^-16
        .equ    VOICE_TRACKS,   12
        .equ    PROJ_TRACKSEL,  48                | as 0000-shared's
        .equ    VIEW_INVALIDATE, 0x40078514
        .equ    PAGE_DEFAULT,   0x401ec570        | page_info's answer above 11
        .equ    CYCLE_RESUME,   0x4003ab8c
        .equ    GET_RESUME,     0x40038472
        .equ    DELTA_RESUME,   0x400378c2
        .equ    DELTA_CALL,     0x400b68d2
        .equ    TEXT_RESUME,    0x400a8600
        .equ    TEXT_CALL,      0x400ff556
        .equ    OFF_SLOT42,     0x1c + 2 * 42     | stored record: spare slot 42
        .equ    SAVE_MAP,       0x401c59cc        | sound_slot_map, the displaced lea
        .equ    SAVE_RESUME,    0x40008498
        .equ    LOAD_MAP,       0x401c5a74        | its inverse, the displaced lea
        .equ    LOAD_RESUME,    0x40008270
        .equ    IDLE_RESUME,    0x400a2ab6
        | DAC SUM in the project's globals (projectGlobalsStorage_v2_t, loaded
        | by 0x4000763c and saved by 0x40007a5c; stored bytes 12..24 are
        | touched by neither). ProjectGlobals is the project's member at +236;
        | its vtable +80, called with (object, 0), is the change notice stock's
        | routing setters end with.
        .equ    OFF_DAC_TAG,    12
        .equ    OFF_DAC_ON,     13
        .equ    DAC_TAG,        0xd5
        .equ    PROJ_GLOBALS,   236
        .equ    VT_CHANGED,     80
        .equ    DLOAD_RESUME,   0x40007666
        .equ    DSAVE_RESUME,   0x40007bb8

        .if     P_TIMING
        | tpeak(side): the timing build's headroom counters - the block's
        | largest |sum| in Q31, and how many side-frames reached full scale, the
        | saturating movclr's ceiling (0x7fffff00 and up). d0 is free here.
        .macro  tpeak r
        move.l  \r,%d0
        bpl.s   1f
        neg.l   %d0
1:      cmp.l   t_pk,%d0
        bls.s   2f
        move.l  %d0,t_pk
2:      cmp.l   #0x7fffff00,%d0
        bcs.s   3f
        addq.l  #1,t_clip
3:
        .endm
        .endif

        .text

        | ------------------------------------------------------------------
        | route_all: the interrupt's store of the main-disable mask, packed from
        | physical voices 7,6,5,4,0,1,2,3, MSB first. Every bit set takes every
        | voice off the analog main bus while DAC SUM is on; off, stock's mask
        | passes. d1 is reloaded straight after.
        | ------------------------------------------------------------------
        .align  2
route_all:
        tst.l   dac_on
        beq.s   1f
        moveq   #-1,%d1
1:      move.b  %d1,0x80006466                    | displaced
        jmp     ROUTE_RESUME

        | ------------------------------------------------------------------
        | vs_body: the voices, filtered in place, and their sum. It runs as
        | soon as the receive buffer holds this block's voices, before anything
        | else reads them - the sampler's meter, the FX sends, 0006's estimator,
        | USB - so all of them see the filtered voice, as they see the analog
        | filter's output; the high-pass is part of the voice. The buffer is
        | on-chip SRAM: the data cache is write-through over DRAM (ACR0), so a
        | DRAM buffer cost a store through to memory and a line fill per read.
        | Two entries, one on each of the interrupt's paths:
        |   vs_main  0x40121364  after the fill and 0009's hook, over `moveq
        |                        #5,%d1` and the first four bytes of `lea
        |                        0x4013f56c,%a0`, both re-emitted after
        |   vs_alt   0x4011fde2  the other path (0x4011fd96), over its `jsr
        |                        0x4010e944`, the fill, re-emitted first
        | Both paths have run the PRE consumer (0x4010ede2) for this interrupt's
        | output slot by then; the sum is added to that slot. vs_body keeps
        | every register.
        |
        | Each slot is high-passed first, one pole, a slot at a time over the
        | block with its state in registers:
        |   y = b * x - b * x1 + p * y1,  b = (1 + p) / 2
        | a bilinear one-pole (hpf_pole), p its track's pole, at the slot's own
        | scale, so the readers downstream see normal levels; an overshoot past
        | full scale saturates. Three multiply-accumulates into acc2, the next
        | x loaded during the third. x1 and y1 carry over between blocks in
        | hpf_state; y replaces x in the buffer. Then, frame by frame, for
        | physical voice p in slot s:
        |   f      = wL / (wL + wR), Q15, from the VCA words
        |   cL[s]  = f g[s]           } Q31
        |   cR[s]  = g[s] - cL[s]     }
        | both zero when p's owning track is off the main bus or both words are
        | zero. g[s] is the slot trim times K. The VCA words lead the audio by
        | four interrupts, so a p-locked pan change is briefly early.
        |
        | The sum costs the same every block, all eight slots multiplied
        | whatever their coefficients; the filter runs only for pairs of slots
        | with an HPF engaged, so the worst case is every pair. timing = 1
        | measures it. MACSR is held at 0xa0 - fractional, saturating on
        | overflow, as stock's PRE consumer sets it (0x4010ede8) - and restored
        | after; the accumulators are left clear, as stock's loops leave them.
        | ------------------------------------------------------------------
        .align  2
vs_main:
        bsr.w   vs_body
        moveq   #5,%d1                            | displaced
        lea     MAIN_LEA,%a0                      | displaced
        jmp     MAIN_RESUME

        .align  2
vs_alt:
        jsr     ALT_FILL                          | displaced
        bsr.w   vs_body
        jmp     ALT_RESUME

        .align  2
vs_body:
        .if     P_TIMING
        jsr     t_start
        .endif
        tst.l   dac_on
        bne.s   1f
        .if     P_TIMING
        jsr     t_end
        .endif
        rts                                       | DAC SUM off: no filter, no sum
1:      lea     -160(%sp),%sp
        movem.l %d0-%d7/%a0-%a6,(%sp)             | 60 B; (cL, cR) at +60, 68 B; a at +128
        move.l  %macsr,%d0
        move.l  %d0,-(%sp)
        move.l  #0xa0,%macsr

        move.l  MAIN_OFF,%d6
        bge.s   1f
        move.l  MAIN_OFF_G,%d6
1:
        lea     COEF(%sp),%a4                     | above the saved MACSR
        lea     SLOT_MAP,%a3
        lea     VCA_L,%a1
        lea     VOICE_OWNER,%a0
        lea     gaintab,%a2
        lea     hpf_track,%a5
        lea     hpf_pole,%a6
        moveq   #0,%d5                            | physical voice
2:      move.l  (%a3)+,%d3
        lsl.l   #3,%d3                            | slot * 8, one (cL, cR)
        move.l  %d3,%d0
        lsr.l   #1,%d0                            | slot * 4
        mvz.b   (%a0,%d5.l),%d2                   | owning track
        mvz.b   (%a5,%d2.l),%d1                   | its HPF step
        lsl.l   #2,%d1
        move.l  (%a6,%d1.l),%d1                   | its pole
        move.l  %d1,ATAB-COEF(%a4,%d0.l)
        moveq   #0,%d0
        moveq   #0,%d1
        move.l  %d6,%d4
        asr.l   %d2,%d4
        btst    #0,%d4
        bne.s   3f                                | off the main bus
        mvz.w   (%a1),%d0                         | wL
        mvz.w   VCA_R-VCA_L(%a1),%d1              | wR
        add.l   %d0,%d1
        beq.s   3f                                | both zero, and so is d0
        moveq   #15,%d2
        lsl.l   %d2,%d0
        divu.l  %d1,%d0                           | f, Q15
        move.l  -4(%a3),%d1
        add.l   %d1,%d1                           | slot * 2
        mvz.w   (%a2,%d1.l),%d1                   | g, Q15
        mulu.l  %d1,%d0                           | f * g, Q30
        add.l   %d0,%d0                           | cL = f g, Q31
        swap    %d1
        clr.w   %d1                               | g, Q31
        sub.l   %d0,%d1                           | cR
3:      move.l  %d0,(%a4,%d3.l)
        move.l  %d1,4(%a4,%d3.l)
        addq.l  #2,%a1
        addq.l  #1,%d5
        moveq   #8,%d0
        cmp.l   %d0,%d5
        blt.s   2b

        | The filter, two slots at a time - A in acc2, B in acc3, skipping a
        | pair whose slots are both OFF, so the cost follows the HPFs in use
        | (about 0.4% of a block a pair): 32 frames in
        | four runs of eight, a slot's word 48 B apart and B 4 B after A, y
        | written over the x already read. The last run's loads read the words
        | past the buffer, unused. The pair's column base is kept on the stack
        | across the run.
        .if     P_PROF
        mvz.b   MUP_INT,%d0
        btst    #0,%d0                            | profiling: no filter
        bne.w   9f
        .endif
        .if     P_PROF
        mvz.b   MUP_INT,%d0
        btst    #2,%d0                            | profiling: a slot at a time
        bne.w   filter_single
        .endif
        lea     hpf_state,%a0
        lea     ATAB(%sp),%a6
        lea     RXBUF+8,%a2
7:      move.l  %a2,-(%sp)
        move.l  (%a6)+,%d6                        | p, A
        move.l  (%a6)+,%d0                        | p, B
        cmp.l   #OFF_POLE,%d6
        bne.s   6f
        cmp.l   #OFF_POLE,%d0
        bne.s   6f
        | Both OFF: the pair is skipped and its slots keep the voices as the
        | ADC gave them. The state follows the signal - x1 and y1 both the
        | slot's last sample - so turning the HPF up starts from there.
        move.l  (FRAMES-1)*RXSTRIDE(%a2),%d1
        move.l  %d1,(%a0)+
        move.l  %d1,(%a0)+
        move.l  (FRAMES-1)*RXSTRIDE+4(%a2),%d1
        move.l  %d1,(%a0)+
        move.l  %d1,(%a0)+
        bra.w   5f
6:      move.l  %d6,%d7
        add.l   #0x80000000,%d7
        lsr.l   #1,%d7                            | (1 + p) / 2, A
        move.l  %d0,%a3                           | p, B
        add.l   #0x80000000,%d0
        lsr.l   #1,%d0
        move.l  %d0,%a4                           | (1 + p) / 2, B
        move.l  (%a0),%d3                         | x1, A
        move.l  4(%a0),%d4                        | y1, A
        move.l  8(%a0),%d2                        | x1, B
        move.l  12(%a0),%d5                       | y1, B
        lea     FRAMES*RXSTRIDE(%a2),%a5          | the run's end
        move.l  (%a2),%d0                         | x, A
        move.l  4(%a2),%d1                        | x, B
8:      .irp    i,0,1,2,3,4,5,6,7
        mac.l   %d0,%d7,%acc2
        mac.l   %d1,%a4,%acc3
        msac.l  %d3,%d7,%acc2
        msac.l  %d2,%a4,%acc3
        move.l  %d0,%d3                           | x1 = x, A
        move.l  %d1,%d2                           | x1 = x, B
        mac.l   %d4,%d6,RXSTRIDE*(\i+1)(%a2),%d0,%acc2
        mac.l   %d5,%a3,RXSTRIDE*(\i+1)+4(%a2),%d1,%acc3
        movclr.l %acc2,%d4                        | y, A
        movclr.l %acc3,%d5                        | y, B
        move.l  %d4,RXSTRIDE*\i(%a2)
        move.l  %d5,RXSTRIDE*\i+4(%a2)
        .endr
        lea     8*RXSTRIDE(%a2),%a2
        cmpa.l  %a5,%a2
        bne.w   8b
        move.l  %d3,(%a0)+
        move.l  %d4,(%a0)+
        move.l  %d2,(%a0)+
        move.l  %d5,(%a0)+
5:      move.l  (%sp)+,%a2
        addq.l  #8,%a2
        cmpa.l  #hpf_state+64,%a0
        bne.w   7b
        .if     P_PROF
        bra.w   9f

        | Profiling only: the same filter a slot at a time, for comparing
        | against the pair above on the in-place buffer.
filter_single:
        lea     hpf_state,%a0
        lea     ATAB(%sp),%a6
        lea     RXBUF+8,%a5
        moveq   #7,%d5
11:     move.l  (%a6)+,%d6                        | p
        move.l  %d6,%d7
        add.l   #0x80000000,%d7
        lsr.l   #1,%d7                            | (1 + p) / 2
        move.l  (%a0),%d3                         | x1
        move.l  4(%a0),%d4                        | y1
        move.l  %a5,%a2
        move.l  (%a2),%d0                         | x
        moveq   #3,%d2
12:     .irp    i,0,1,2,3,4,5,6,7
        mac.l   %d0,%d7,%acc2
        msac.l  %d3,%d7,%acc2
        move.l  %d0,%d3
        mac.l   %d4,%d6,RXSTRIDE*(\i+1)(%a2),%d0,%acc2
        movclr.l %acc2,%d4
        move.l  %d4,RXSTRIDE*\i(%a2)
        .endr
        lea     8*RXSTRIDE(%a2),%a2
        subq.l  #1,%d2
        bpl.w   12b
        move.l  %d3,(%a0)+
        move.l  %d4,(%a0)+
        addq.l  #4,%a5
        subq.l  #1,%d5
        bpl.w   11b
        .endif
9:
        .if     P_PROF
        mvz.b   MUP_INT,%d0
        btst    #1,%d0                        | profiling: no sum
        bne.w   10f
        .endif

        | The sum, frame by frame, into the PRE pair itself: each side's
        | accumulator starts from its PRE word (stored as acc >> 8, logical, so
        | << 8 is its Q31 value again), the voices are subtracted, and the
        | saturating movclr clamps the result at full scale. The voices are
        | subtracted because the PRE pair is inverted against the analog bus,
        | as the consumer's msac of the returns reflects (measured against
        | stock over USB, 2026-09-28). Each (cL, cR) loads during the multiply
        | before it; the last load reads the word past the table, unused.
        move.l  OUT_IDX,%d0
        moveq   #11,%d1
        lsl.l   %d1,%d0
        add.l   #OUT_RING+OUT_PRE,%d0
        move.l  %d0,%a1
        lea     RXBUF+8,%a3
        lea     COEF(%sp),%a4                     | the filter used a4
        moveq   #FRAMES-1,%d5
4:      move.l  %a4,%a2
        move.l  (%a1),%d0
        lsl.l   #8,%d0
        move.l  %d0,%acc0                         | PRE L, Q31
        move.l  4(%a1),%d0
        lsl.l   #8,%d0
        move.l  %d0,%acc1                         | PRE R, Q31
        move.l  (%a2)+,%d1                        | cL, slot 0
        .irp    i,0,1,2,3,4,5,6,7
        move.l  4*\i(%a3),%d0                     | y
        msac.l  %d0,%d1,(%a2)+,%d1,%acc0          | L; d1 = cR
        msac.l  %d0,%d1,(%a2)+,%d1,%acc1          | R; d1 = the next cL
        .endr
        movclr.l %acc0,%d2
        movclr.l %acc1,%d3
        .if     P_TIMING
        .irp    side,%d2,%d3
        tpeak   \side
        .endr
        .endif
        lsr.l   #8,%d2
        move.l  %d2,(%a1)+
        lsr.l   #8,%d3
        move.l  %d3,(%a1)+
        lea     OUT_STRIDE-8(%a1),%a1
        lea     RXSTRIDE(%a3),%a3
        subq.l  #1,%d5
        bpl.w   4b
10:

        move.l  (%sp)+,%d0
        move.l  %d0,%macsr
        movem.l (%sp),%d0-%d7/%a0-%a6
        lea     160(%sp),%sp
        .if     P_TIMING
        jsr     t_end
        .endif
        rts


        .if     P_TIMING
        | ------------------------------------------------------------------
        | The timing build: vs_body's run and the interval between
        | interrupts, in DMA timer 0 ticks, on voice slot 7's word - USB
        | channel 10 - as (tag << 24) | (data << 8):
        |   frames 0 mod 4  0xa5, vs_body's run
        |   frames 1 mod 4  0x5a, the interval since the last block, / 4
        |   frames 2 mod 4  0x3c, the block's largest |sum| on either side, Q31
        |                   >> 15 (65535 is full scale)
        |   frames 3 mod 4  0xc3, how many side-frames reached full scale
        | each held at 0xffff. t_end keeps the words, and t_emit - detoured after
        | the FX sends and before USB (0x40121396), on the main path only -
        | writes this block's over slot 7, which only USB, and the sampler,
        | read after the sends: a timing build is for timing. If the Mac loops
        | the Rytm's USB audio back, the words return into MAIN as clicks
        | (2026-09-28). t_start and t_end keep every register.
        | ------------------------------------------------------------------
        .align  2
t_start:
        move.l  %d0,-(%sp)
        move.l  DTCN0,%d0
        move.l  %d0,t_0
        sub.l   t_prev,%d0
        move.l  %d0,t_iv
        move.l  t_0,%d0
        move.l  %d0,t_prev
        move.l  (%sp)+,%d0
        rts

        .align  2
t_end:
        lea     -16(%sp),%sp
        movem.l %d0-%d2/%a0,(%sp)
        move.l  DTCN0,%d0
        sub.l   t_0,%d0                           | the run
        move.l  t_iv,%d1
        lsr.l   #2,%d1                            | the interval / 4
        .irp    r,%d0,%d1
        cmp.l   #0xffff,\r
        bls.s   1f
        move.l  #0xffff,\r
1:      lsl.l   #8,\r
        .endr
        or.l    #0xa5000000,%d0
        or.l    #0x5a000000,%d1
        move.l  %d0,t_w_run
        move.l  %d1,t_w_iv
        move.l  t_pk,%d0
        lsr.l   #8,%d0
        lsr.l   #7,%d0                            | Q31 >> 15, 16 bits
        lsl.l   #8,%d0
        or.l    #0x3c000000,%d0
        move.l  %d0,t_w_pk
        move.l  t_clip,%d0
        lsl.l   #8,%d0
        or.l    #0xc3000000,%d0
        move.l  %d0,t_w_clip
        clr.l   t_pk
        clr.l   t_clip
        movem.l (%sp),%d0-%d2/%a0
        lea     16(%sp),%sp
        rts

        | t_emit: reached by a jmp over `addql #4,%sp; movel %d2,%sp@` and the
        | first half of `jsr 0x4010e650`, all re-emitted.
        .align  2
t_emit:
        addq.l  #4,%sp                            | displaced
        move.l  %d2,(%sp)                         | displaced
        jsr     FX_SENDS                          | displaced
        lea     -16(%sp),%sp
        movem.l %d0-%d2/%a0,(%sp)
        lea     RXBUF+T_SLOT,%a0
        moveq   #FRAMES/4-1,%d2
2:      move.l  t_w_run,%d0
        move.l  %d0,(%a0)
        move.l  t_w_iv,%d0
        move.l  %d0,RXSTRIDE(%a0)
        move.l  t_w_pk,%d0
        move.l  %d0,2*RXSTRIDE(%a0)
        move.l  t_w_clip,%d0
        move.l  %d0,3*RXSTRIDE(%a0)
        lea     4*RXSTRIDE(%a0),%a0
        subq.l  #1,%d2
        bpl.s   2b
        movem.l (%sp),%d0-%d2/%a0
        lea     16(%sp),%sp
        jmp     EMIT_RESUME
        .endif

        | ------------------------------------------------------------------
        | The HPF steps: OFF, then 48 cutoffs spaced evenly in log frequency from
        | 20 Hz to 1 kHz, fc(i) = 20 * 50^(i / 47), about 1/8 octave a step. Each
        | voice is a bilinear one-pole high-pass,
        |   H(z) = ((1 + p) / 2) (1 - 1/z) / (1 - p/z),  p = (1 - K) / (1 + K),
        |   K = tan(pi fc / 48000),
        | exactly -3 dB at fc and flat to the top of the band at every cutoff.
        | hpf_pole is p in Q31, generated from that formula (the assembler has no
        | tan). OFF's is 1 - 2^-16, a cutoff of about 0.12 Hz: with no leak at
        | all (the largest Q31 value) the EMAC's truncation, half an LSB down a
        | sample, built up into a DC offset without bound - about 1.1e-5 of full
        | scale a second, -28 dBFS after an hour - where this leak holds it at
        | about -96 dBFS (modelled against an exact reference, 2026-09-28).
        | hpf_hz is fc rounded, for the popup.
        | ------------------------------------------------------------------
        .align  2
hpf_pole:
        .long   OFF_POLE, 2141868895, 2141382245, 2140853481
        .long   2140278968, 2139654765, 2138976588, 2138239791
        .long   2137439328, 2136569726, 2135625045, 2134598840
        .long   2133484119, 2132273300, 2130958160, 2129529782
        .long   2127978503, 2126293848, 2124464467, 2122478068
        .long   2120321337, 2117979862, 2115438047, 2112679017
        .long   2109684527, 2106434852, 2102908682, 2099083005
        .long   2094932985, 2090431829, 2085550658, 2080258364
        .long   2074521460, 2068303931, 2061567078, 2054269354
        .long   2046366206, 2037809906, 2028549391, 2018530099
        .long   2007693813, 1995978509, 1983318222, 1969642910
        .long   1954878353, 1938946057, 1921763197, 1903242573
        .long   1883292614
hpf_hz:
        .word   0, 20, 22, 24, 26, 28, 30, 33, 36, 39, 42, 46
        .word   50, 54, 59, 64, 70, 76, 82, 89, 97, 106, 115, 125
        .word   136, 147, 160, 174, 189, 206, 224, 243, 264, 287, 312, 339
        .word   368, 400, 435, 473, 514, 558, 607, 660, 717, 779, 847, 920
        .word   1000

        | ------------------------------------------------------------------
        | page_info's answer for ids above 11, `movel #0x401ec570,%d0` before its
        | rts: page 13 answers the HPF page. Reached with d0 the page id, from the
        | range compare 0004 rejoins at when it is built.
        | ------------------------------------------------------------------
        .align  2
hpf_page_info:
        moveq   #PAGE_HPF,%d1
        cmp.l   %d1,%d0
        bne.s   1f
        move.l  #page_hpf,%d0
        rts
1:      move.l  #PAGE_DEFAULT,%d0                 | displaced
        rts                                       | as stock's, after it

        | The HPF page: FILTER's layout, HPF on the top-left knob.
        .align  2
page_hpf:
        .long   txt_page
        .long   ID_HPF, 0, 0, 0, 0, 0, 0, 0
        | The FILTER view's page vector, FILTER and then the HPF page.
filter_pages:
        .long   PAGE_FILTER, PAGE_HPF

        | ------------------------------------------------------------------
        | The page key's cycle, `movel %a2@(140),%d1; addql #1,%d1`, re-emitted,
        | before `remsl %d0,%d2,%d1` makes it the new index. On the FILTER view -
        | its first page is 6 - while DAC SUM is off the index stays 0, so the
        | HPF page is never shown. d2 is overwritten by the remsl and a0 reloaded
        | after, so both are free.
        | ------------------------------------------------------------------
        .align  2
hpf_cycle:
        move.l  140(%a2),%d1                      | displaced
        addq.l  #1,%d1                            | displaced
        tst.l   dac_on
        bne.s   9f
        move.l  124(%a2),%a0
        moveq   #PAGE_FILTER,%d2
        cmp.l   (%a0),%d2
        bne.s   9f
        moveq   #0,%d1
9:      jmp     CYCLE_RESUME

        | ------------------------------------------------------------------
        | hpf_cur_step() -> d0 = the selected track's HPF step, 0 when its sound
        | carries no tag. Clobbers d0/d1/a0/a1.
        | ------------------------------------------------------------------
        .align  2
hpf_cur_step:
        jsr     shared_cur_sound
        beq.s   9f
        mvz.b   OFF_HPF_TAG(%a0),%d1
        cmp.l   #HPF_TAG,%d1
        bne.s   8f
        mvz.b   OFF_HPF_STEP(%a0),%d0
        moveq   #HPF_STEPS,%d1
        cmp.l   %d1,%d0
        bls.s   9f
8:      moveq   #0,%d0
9:      rts

        | ------------------------------------------------------------------
        | hpf_set(d0 = step): the selected track's sound, tagged, and its entry
        | in hpf_track. Clobbers d0/d1/a0/a1.
        | ------------------------------------------------------------------
        .align  2
hpf_set:
        move.l  %d0,-(%sp)
        jsr     shared_cur_sound
        beq.s   9f
        move.b  #HPF_TAG,OFF_HPF_TAG(%a0)
        move.l  (%sp),%d0
        move.b  %d0,OFF_HPF_STEP(%a0)
        jsr     project_singleton
        move.l  %d0,%a0
        pea     PROJ_TRACKSEL(%a0)
        jsr     track_index_of
        addq.l  #4,%sp
        moveq   #VOICE_TRACKS,%d1
        cmp.l   %d1,%d0
        bcc.s   9f                                | the FX track has no voice
        lea     hpf_track,%a0
        move.l  (%sp),%d1
        move.b  %d1,(%a0,%d0.l)
9:      addq.l  #4,%sp
        rts

        | ------------------------------------------------------------------
        | page_get_value for id 5, the dial: after the prologue, over `moveal
        | %sp@(16),%a2; movel %sp@(20),%d2`, where 0004's gate rejoins. The frame
        | holds d2/d3/a2; 20(%sp) is the id. The step as a position, 8.8 on the
        | 0..127 scale, the 32 spread evenly over the knob's travel.
        | ------------------------------------------------------------------
        .align  2
hpf_get:
        moveq   #ID_HPF,%d0
        cmp.l   20(%sp),%d0
        bne.s   9f
        bsr.w   hpf_cur_step
        mulu.w  #127,%d0
        divu.w  #HPF_STEPS,%d0
        and.l   #0xffff,%d0
        lsl.l   #8,%d0
        movem.l (%sp),%d2-%d3/%a2                 | page_get_value's epilogue
        lea     12(%sp),%sp
        rts
9:      move.l  16(%sp),%a2                       | displaced
        move.l  20(%sp),%d2                       | displaced
        jmp     GET_RESUME

        | ------------------------------------------------------------------
        | param_apply_delta for id 5, the knob: over `jsr 0x400b68d2`, where 0004's
        | gate rejoins, with a2@(116) already pushed as its argument. The frame
        | holds d2/d3/a2 above that; 24(%sp) is the id, 28(%sp) the delta in 8.8,
        | a2 the view. A step a whole unit of delta, clamped; stock never sees
        | the id, so no lock is made. The view is invalidated after, as nothing
        | stock does redraws it.
        | ------------------------------------------------------------------
        .align  2
hpf_delta:
        moveq   #ID_HPF,%d0
        cmp.l   24(%sp),%d0
        bne.s   9f
        move.l  28(%sp),%d2
        asr.l   #8,%d2                            | whole steps, sign preserved
        beq.s   7f
        bsr.w   hpf_cur_step
        add.l   %d2,%d0
        bpl.s   1f
        moveq   #0,%d0
1:      moveq   #HPF_STEPS,%d1
        cmp.l   %d1,%d0
        ble.s   2f
        move.l  %d1,%d0
2:      bsr.w   hpf_set
        move.l  %a2,-(%sp)
        jsr     VIEW_INVALIDATE
        addq.l  #4,%sp
7:      addq.l  #4,%sp                            | the pushed argument
        movem.l (%sp),%d2-%d3/%a2                 | param_apply_delta's epilogue
        lea     12(%sp),%sp
        rts
9:      jsr     DELTA_CALL                        | displaced
        jmp     DELTA_RESUME

        | ------------------------------------------------------------------
        | param_value_text for id 5, the popup: over `movel %d4,%sp@-` and the
        | first half of `jsr 0x400ff556`, where 0004's gate rejoins. The frame
        | holds d2-d4/a2-a3; d4 is the id, d3 the output buffer. OFF, or the
        | cutoff: whole hertz, "20Hz" .. "920Hz", then "1.0kHz".
        | ------------------------------------------------------------------
        .align  2
hpf_text:
        moveq   #ID_HPF,%d0
        cmp.l   %d4,%d0
        bne.w   9f
        bsr.w   hpf_cur_step
        move.l  %d3,%a1
        tst.l   %d0
        bne.s   1f
        lea     txt_off,%a0
        bra.s   5f
1:      lea     hpf_hz,%a0
        add.l   %d0,%d0
        mvz.w   (%a0,%d0.l),%d0                   | hertz, 20..1000
        cmp.l   #1000,%d0
        bcs.s   6f
        divu.w  #1000,%d0                         | kilohertz, remainder above
        moveq   #'0',%d1
        add.l   %d0,%d1                           | the low byte is the digit
        move.b  %d1,(%a1)+
        move.b  #'.',(%a1)+
        swap    %d0
        and.l   #0xffff,%d0
        divu.w  #100,%d0                          | tenths
        moveq   #'0',%d1
        add.l   %d0,%d1
        move.b  %d1,(%a1)+
        lea     txt_khz,%a0
        bra.s   5f
6:      moveq   #100,%d1
        cmp.l   %d1,%d0
        bcs.s   2f
        divu.w  #100,%d0                          | hundreds, remainder above
        moveq   #'0',%d1
        add.l   %d0,%d1                           | the low byte is the digit
        move.b  %d1,(%a1)+
        swap    %d0
        and.l   #0xffff,%d0
        divu.w  #10,%d0
        bra.s   3f
2:      divu.w  #10,%d0
3:      moveq   #'0',%d1
        add.l   %d0,%d1                           | the low byte is the digit
        move.b  %d1,(%a1)+                        | tens
        swap    %d0
        moveq   #'0',%d1
        add.l   %d0,%d1                           | the low byte is the digit
        move.b  %d1,(%a1)+                        | units
        lea     txt_hz,%a0
5:      move.b  (%a0)+,(%a1)+
        bne.s   5b
        movem.l (%sp),%d2-%d4/%a2-%a3             | param_value_text's epilogue
        lea     20(%sp),%sp
        rts
9:      move.l  %d4,-(%sp)                        | displaced
        jsr     TEXT_CALL                         | displaced
        jmp     TEXT_RESUME

        | ------------------------------------------------------------------
        | sound_save, after its memset of the stored parameter block, over
        | `lea 0x401c59cc,%a0`: a2 the stored record, a3 the live sound. Slot 42
        | (+0x70), which stock zeroes and never reads, carries the HPF as
        | (tag << 8) | step, or 0 when the live sound has no tag. d0/d1 and a0
        | are set again straight after.
        | ------------------------------------------------------------------
        .align  2
hpf_save:
        moveq   #0,%d0
        mvz.b   OFF_HPF_TAG(%a3),%d1
        cmp.l   #HPF_TAG,%d1
        bne.s   1f
        mvz.b   OFF_HPF_STEP(%a3),%d0
        or.l    #HPF_TAG << 8,%d0
1:      move.w  %d0,OFF_SLOT42(%a2)
        lea     SAVE_MAP,%a0                      | displaced
        jmp     SAVE_RESUME

        | ------------------------------------------------------------------
        | sound_load, after it clears the live parameter array, over `lea
        | 0x401c5a74,%a0`: a2 the live sound, a3 the stored record. The live tag
        | and step from slot 42, or the tag cleared, so a sound saved without
        | an HPF - or by stock, which zeroes the slot - reads OFF rather than
        | whatever the object held. d0/d1 and a0 are set again straight after.
        | ------------------------------------------------------------------
        .align  2
hpf_load:
        mvz.w   OFF_SLOT42(%a3),%d0
        move.l  %d0,%d1
        lsr.l   #8,%d1
        cmp.l   #HPF_TAG,%d1
        bne.s   1f
        move.b  %d1,OFF_HPF_TAG(%a2)
        move.b  %d0,OFF_HPF_STEP(%a2)
        bra.s   2f
1:      clr.b   OFF_HPF_TAG(%a2)
2:      lea     LOAD_MAP,%a0                      | displaced
        jmp     LOAD_RESUME

        | ------------------------------------------------------------------
        | The screen's idle tick (0x400a2aaa, about 20 a second, UI context),
        | past its link, over `moveml %d2/%a2-%a4,%sp@` and the first half of
        | `moveal %fp@(8),%a2`, both re-emitted. Every voice track's HPF step,
        | from the sound its active kit holds, into hpf_track, so the audio
        | interrupt follows kit loads, pattern changes and sound loads within a
        | tick without looking up a sound itself. Then DAC SUM, from the
        | active globals record's entry, so it follows a project load.
        | ------------------------------------------------------------------
        .align  2
hpf_refresh:
        movem.l %d2/%a2-%a4,(%sp)                 | displaced
        move.l  8(%fp),%a2                        | displaced
        lea     -8(%sp),%sp
        movem.l %d2-%d3,(%sp)
        moveq   #0,%d2                            | track
1:      move.l  %d2,%d0
        jsr     shared_sound_of
        beq.s   3f                                | no sound: OFF
        mvz.b   OFF_HPF_TAG(%a0),%d1
        cmp.l   #HPF_TAG,%d1
        bne.s   3f
        mvz.b   OFF_HPF_STEP(%a0),%d3
        moveq   #HPF_STEPS,%d1
        cmp.l   %d1,%d3
        bls.s   4f
3:      moveq   #0,%d3
4:      lea     hpf_track,%a0
        move.b  %d3,(%a0,%d2.l)
        addq.l  #1,%d2
        moveq   #VOICE_TRACKS,%d1
        cmp.l   %d1,%d2
        blt.s   1b
        bsr.w   dac_active                        | DAC SUM: the active record's
        bsr.w   dac_find
        tst.l   %d0
        bmi.s   5f
        lea     dac_rec,%a1
        mvz.b   (%a1,%d0.l),%d0
        move.l  %d0,dac_on
5:      movem.l (%sp),%d2-%d3
        lea     8(%sp),%sp
        jmp     IDLE_RESUME                       | a2 kept: calls clobber d0/d1/a0/a1

        | ------------------------------------------------------------------
        | projectGlobals_t's load (0x4000763c), after its version check, over
        | `mvsb %a2@(4),%d1; moveq #1,%d2`, both re-emitted: a2 the stored
        | record, a3 the live one. The boot loop loads four (0x4000ce1c), so
        | the value goes to that live record's entry in dac_rec - stored +13
        | under the tag at +12, or OFF - and hpf_refresh picks the active
        | record's. A single flag, set by every load, took the last record's
        | and lost the active one's (hardware, 2026-09-28); an untouched record
        | can hold leftovers there (the fourth read 00 01), which the tag keeps
        | out. d0 is written again before it is read.
        | ------------------------------------------------------------------
        .align  2
dac_load:
        lea     -8(%sp),%sp
        movem.l %a0-%a1,(%sp)
        move.l  %a3,%a0
        bsr.w   dac_slot                          | d0 = this live record's entry
        moveq   #0,%d1
        mvz.b   OFF_DAC_TAG(%a2),%d2              | d2 is set again after
        cmp.l   #DAC_TAG,%d2
        bne.s   1f
        tst.b   OFF_DAC_ON(%a2)
        sne     %d1
        and.l   #1,%d1                            | 1 or 0
1:      lea     dac_rec,%a1
        move.b  %d1,(%a1,%d0.l)
        .if     P_DBG
        addq.l  #1,dbg_loads
        lea     dbg_tags,%a1
        mvz.b   OFF_DAC_TAG(%a2),%d1
        move.b  %d1,(%a1,%d0.l)                   | the tag each record's load found
        .endif
        movem.l (%sp),%a0-%a1
        lea     8(%sp),%sp
        mvs.b   4(%a2),%d1                        | displaced
        moveq   #1,%d2                            | displaced
        jmp     DLOAD_RESUME

        | ------------------------------------------------------------------
        | projectGlobals_t's save (0x40007a5c), over `moveq #2,%d0` and the
        | first four bytes of `moveb %a3@(211),%a2@(70)`, both re-emitted: a2
        | the stored record. The tag at +12 and DAC SUM at +13. d1 is not read
        | again.
        | ------------------------------------------------------------------
        .align  2
dac_save:
        .if     P_DBG
        addq.l  #1,dbg_saves
        .endif
        lea     -8(%sp),%sp
        movem.l %a0-%a1,(%sp)
        move.l  #DAC_TAG,%d1
        move.b  %d1,OFF_DAC_TAG(%a2)
        move.l  dac_on,%d1                        | a record never loaded: DAC SUM
        move.l  %a3,%a0
        bsr.w   dac_find
        tst.l   %d0
        bmi.s   1f
        lea     dac_rec,%a1
        mvz.b   (%a1,%d0.l),%d1                   | this record's
1:      move.b  %d1,OFF_DAC_ON(%a2)
        movem.l (%sp),%a0-%a1
        lea     8(%sp),%sp
        moveq   #2,%d0                            | displaced
        move.b  211(%a3),70(%a2)                  | displaced
        jmp     DSAVE_RESUME

        | ------------------------------------------------------------------
        | The four globals records' DAC SUM, keyed by live record: dac_live
        | holds each record's address as its load saw it, dac_rec its value.
        |   dac_find(a0 = live record) -> d0 = its entry, or -1
        |   dac_slot(a0 = live record) -> d0 = its entry, taking the next one
        |                                 round when it has none
        |   dac_active() -> a0 = the active live record (ProjectGlobals'
        |                   vtable +52, as stock's routing getters ask)
        | dac_find and dac_slot clobber d0/a1, dac_active d0/d1/a0/a1.
        | ------------------------------------------------------------------
        .align  2
dac_find:
        lea     dac_live,%a1
        moveq   #0,%d0
1:      cmpa.l  (%a1)+,%a0
        beq.s   2f
        addq.l  #1,%d0
        cmp.l   #4,%d0
        bne.s   1b
        moveq   #-1,%d0
2:      rts

        .align  2
dac_slot:
        bsr.s   dac_find
        tst.l   %d0
        bpl.s   9f
        move.l  dac_next,%d0
        lea     dac_live,%a1
        move.l  %a0,(%a1,%d0.l*4)
        move.l  %d0,-(%sp)
        addq.l  #1,%d0
        and.l   #3,%d0
        move.l  %d0,dac_next
        move.l  (%sp)+,%d0
9:      rts

        .align  2
dac_active:
        jsr     project_singleton
        add.l   #PROJ_GLOBALS,%d0
        move.l  %d0,%a0
        move.l  %a0,-(%sp)
        move.l  (%a0),%a0
        move.l  52(%a0),%a0
        jsr     (%a0)
        addq.l  #4,%sp
        move.l  %d0,%a0
        rts

        .if     P_DBG
        | ------------------------------------------------------------------
        | The debug build: DAC SUM's value reads "A<i> <t0><t1><t2><t3>": the
        | active globals record's entry in dac_live, X when it has none, then
        | the tag byte each entry's last load found, in hex.
        | Clobbers d0/d1/a0/a1.
        | ------------------------------------------------------------------
        .align  2
dbg_fmt:
        bsr.w   dac_active
        bsr.w   dac_find
        lea     dbg_txt,%a1
        move.b  #'A',(%a1)+
        tst.l   %d0
        bmi.s   8f
        add.l   #'0',%d0
        move.b  %d0,(%a1)+
        bra.s   9f
8:      move.b  #'X',(%a1)+
9:      move.b  #' ',(%a1)+
        moveq   #0,%d0
7:      move.l  %d0,-(%sp)
        lea     dbg_tags,%a0
        mvz.b   (%a0,%d0.l),%d0
        bsr.s   dbg_hex
        move.l  (%sp)+,%d0
        addq.l  #1,%d0
        cmp.l   #4,%d0
        bne.s   7b
        clr.b   (%a1)
        rts
        | dbg_dec(d0, a1): 0..99, two digits, wrapping
dbg_dec:
        divu.w  #100,%d0
        swap    %d0
        and.l   #0xffff,%d0
        divu.w  #10,%d0
        moveq   #'0',%d1
        add.l   %d0,%d1
        move.b  %d1,(%a1)+
        swap    %d0
        moveq   #'0',%d1
        add.l   %d0,%d1
        move.b  %d1,(%a1)+
        rts
        | dbg_hex(d0 = a byte, a1): two hex digits
dbg_hex:
        move.l  %d0,%d1
        lsr.l   #4,%d1
        bsr.s   1f
        move.l  %d0,%d1
1:      and.l   #15,%d1
        cmp.l   #10,%d1
        bcs.s   2f
        addq.l  #7,%d1
2:      add.l   #'0',%d1
        move.b  %d1,(%a1)+
        rts
        .endif

txt_page:
        .asciz  "HIGH-PASS"
txt_hpf_long:
        .asciz  "HIGH-PASS"
txt_hpf_short:
        .asciz  "HPF"
txt_hz:
        .asciz  "Hz"
txt_khz:
        .asciz  "kHz"

        | Per-slot gain g, Q15: the slot trim times K. The trims are 0006's
        | (mods/0006-comp-preview/calibration.toml, slot_trim_db): slots 5 and 6
        | read hot against their contribution to MAIN. Slot 6's is 0.53 dB, not
        | 0006's 1.10: at 1.10 it read 0.57 dB low against the analog path, DAC
        | SUM on against off over USB, A02 and A04 (build/mix/20260928_114438,
        | _114542), 2026-09-28.
        .align  2
gaintab:
        .irp    t,32767,32757,32767,32637,32469,29460,30828,32037
        .word   (\t * P_K) / 32768
        .endr

        | ------------------------------------------------------------------
        | dac_menu_add: AudioRoutingMenuView's item list, after USB TO MAIN.
        |
        | Reached by a jmp over `moveal %a4@,%a0; pea 0x2`, re-emitted after.
        | USB OUT's item sequence follows unchanged but for its three invokers
        | and the allocator: USB TO MAIN's sequence left its item in a3, where
        | the others keep mem_new. The changer's storage holds the view itself
        | rather than an allocation. The registers it uses still hold what it
        | needs - a4 the view, a5 the MenuItem constructor, a2 the std::function
        | destructor, d2..d5 the four functions' slots - and the stack is at
        | the depth each item starts at. d6 is free; d7 is kept.
        | ------------------------------------------------------------------
        .align  2
dac_menu_add:
        move.l  (%a4),%a0
        move.l  8(%a0),%fp                        | append
        clr.l   76(%sp)
        pea     0x1
        jsr     mem_new
        clr.l   96(%sp)
        clr.l   112(%sp)
        move.l  %d0,72(%sp)
        move.l  #dac_label,%d0
        move.l  %d0,84(%sp)
        move.l  #MGR_LABEL,%d0
        move.l  %d0,80(%sp)
        pea     0x1
        jsr     mem_new
        clr.l   132(%sp)
        move.l  %d0,108(%sp)
        move.l  #dac_draw,%d0
        move.l  %d0,120(%sp)
        move.l  #MGR_DRAW,%d0
        move.l  %d0,116(%sp)
        lea     32(%sp),%sp
        pea     0x1
        move.l  %a4,%d0                           | the view, stored in place
        move.l  %d0,96(%sp)
        move.l  #dac_change,%d0
        move.l  %d0,108(%sp)
        move.l  #dac_mgr,%d0
        move.l  %d0,104(%sp)
        pea     0x54
        jsr     mem_new
        pea     0x8
        pea     -1
        move.l  %d5,-(%sp)
        move.l  %d4,-(%sp)
        move.l  %d3,-(%sp)
        move.l  %d2,-(%sp)
        move.l  %d0,-(%sp)
        move.l  %d0,%d6
        jsr     (%a5)
        lea     32(%sp),%sp
        move.l  %d6,(%sp)
        move.l  %a4,-(%sp)
        jsr     (%fp)
        move.l  %d5,-(%sp)
        jsr     (%a2)
        move.l  %d4,-(%sp)
        jsr     (%a2)
        move.l  %d3,-(%sp)
        jsr     (%a2)
        move.l  %d2,-(%sp)
        jsr     (%a2)
        move.l  (%a4),%a0                         | displaced
        pea     0x2                               | displaced
        jmp     MENU_RESUME

        | dac_label(a0 = the std::string to construct) -> d0 = a0, as stock's
        | label invokers.
        .align  2
dac_label:
        link.w  %fp,#-4
        move.l  %d2,-(%sp)
        pea     -1(%fp)
        pea     txt_label
        move.l  %a0,%d2
        move.l  %a0,-(%sp)
        jsr     std_string_from_cstr
        lea     12(%sp),%sp
        move.l  %d2,%d0
        move.l  -8(%fp),%d2
        unlk    %fp
        rts

        | dac_draw(functor, -, canvas, x, y): ON or OFF, right-aligned at
        | x + 19 as USB IN's value is - measured, then drawn from x less its
        | width.
        .align  2
dac_draw:
        lea     -32(%sp),%sp
        movem.l %d2-%d7,(%sp)                     | the string at +24, its allocator +28
        move.l  44(%sp),%d5                       | canvas
        move.l  48(%sp),%d6
        add.l   #19,%d6                           | right edge
        move.l  52(%sp),%d7
        addq.l  #2,%d7                            | y
        lea     24(%sp),%a0
        move.l  %a0,%d3
        lea     28(%sp),%a0
        move.l  %a0,%d4
        move.l  #txt_off,%d2
        tst.l   dac_on
        beq.s   1f
        move.l  #txt_on,%d2
1:
        .if     P_DBG
        bsr.w   dbg_fmt
        move.l  #dbg_txt,%d2
        .endif
        move.l  %d4,-(%sp)
        move.l  %d2,-(%sp)
        move.l  %d3,-(%sp)
        jsr     std_string_from_cstr
        move.l  %d3,-(%sp)
        pea     -1
        pea     MENU_FONT
        jsr     TEXT_WIDTH
        sub.l   %d0,%d6
        move.l  %d3,-(%sp)
        jsr     std_string_dtor
        move.l  %d2,-(%sp)                        | the text as format, no %
        move.l  %d2,-(%sp)                        | and as width
        clr.l   -(%sp)
        pea     -1
        move.l  %d7,-(%sp)
        move.l  %d6,-(%sp)
        pea     MENU_FONT
        move.l  %d5,-(%sp)
        jsr     text_draw
        lea     60(%sp),%sp
        movem.l (%sp),%d2-%d7
        lea     32(%sp),%sp
        rts

        | dac_change(functor, -, delta): up turns DAC SUM on, down off, marks
        | the project's globals changed, then invalidates the view the functor
        | holds. The value is not a stock
        | setting, so no setter's notification redraws it.
        .align  2
dac_change:
        move.l  12(%sp),%d0
        beq.s   2f
        bmi.s   1f
        moveq   #1,%d0
        bra.s   3f
1:      moveq   #0,%d0
3:      move.l  %d0,dac_on
        move.l  %d0,-(%sp)
        bsr.w   dac_active
        bsr.w   dac_find
        tst.l   %d0
        bmi.s   4f
        lea     dac_rec,%a1
        move.l  (%sp),%d1
        move.b  %d1,(%a1,%d0.l)                   | the active record's entry
4:      addq.l  #4,%sp
        jsr     project_singleton                 | the project's globals changed,
        add.l   #PROJ_GLOBALS,%d0                 | so they are saved with it, as
        move.l  %d0,%a0                           | a routing change is
        clr.l   -(%sp)
        move.l  %a0,-(%sp)
        move.l  (%a0),%a0
        move.l  VT_CHANGED(%a0),%a0
        jsr     (%a0)
        addq.l  #8,%sp
        move.l  4(%sp),%a0
        move.l  (%a0),%a0                         | the view
        pea     56(%a0)
        jsr     VIEW_INVALIDATE
        addq.l  #4,%sp
2:      rts

        | dac_mgr(dest, source, op): the changer's std::function manager, for a
        | functor stored in place - the view pointer. 0 names the type (this
        | routine's address stands in for its typeinfo), 1 answers the
        | functor's address, 2 copies the pointer, 3 has nothing to free.
        .align  2
dac_mgr:
        move.l  4(%sp),%a0                        | dest
        move.l  12(%sp),%d0                       | op
        bne.s   1f
        move.l  #dac_mgr,(%a0)
        bra.s   9f
1:      subq.l  #1,%d0
        bne.s   2f
        move.l  8(%sp),(%a0)
        bra.s   9f
2:      subq.l  #1,%d0
        bne.s   9f
        move.l  8(%sp),%a1
        move.l  (%a1),(%a0)
9:      moveq   #0,%d0
        rts

txt_label:
        .asciz  "DAC SUM"
txt_on:
        .asciz  "ON"
txt_off:
        .asciz  "OFF"

        | Written at run time, as 0010's data in cave6 is: 0 until the project
        | loads, then as its globals were saved.
        .align  2
dac_on:
        .long   0
        | The globals records' DAC SUM (dac_find, dac_slot).
dac_live: .long 0, 0, 0, 0
dac_next: .long 0
dac_rec: .byte  0, 0, 0, 0
        | Each voice track's HPF step, as hpf_set leaves it. 0 at power-on.
hpf_track:
        .space  VOICE_TRACKS
        .align  2
        .if     P_DBG
dbg_loads: .long 0
dbg_saves: .long 0
dbg_tags: .byte 0, 0, 0, 0
dbg_txt: .space 16
        .align  2
        .endif
hpf_state:
        .rept   8
        .long   0, 0                              | x1 (the slot), y1 (Q30), per slot
        .endr
        .if     P_TIMING
t_prev: .long   0
t_0:    .long   0
t_iv:   .long   0
t_w_run: .long  0
t_w_iv: .long   0
t_w_pk: .long   0
t_w_clip: .long 0
t_pk:   .long   0
t_clip: .long   0
        .endif
