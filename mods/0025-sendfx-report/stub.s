| Mod 0025 - Sidecar send FX reporter: sound index 0 per track and FX words 0/29/38..41 as host-link SysEx 0x20.
| GENERATED from sfx.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit sfx.c.
	.include "symbols.inc"
#NO_APP
	.file	"sfx.c"
	.text
#APP
	.if	(P_RR < 0) + (P_RR > 127)
	.error	"0025 rr: 0..127"
	.endif
	.if	(P_MAXB < 1) + (P_MAXB > 8)
	.error	"0025 maxb: 1..8"
	.endif
	.align	2
	.globl	sfx_hook
sfx_hook:
	lea	-16(%sp),%sp
	movem.l	%d0-%d1/%a0-%a1,(%sp)
	jsr	sfx_block
	movem.l	(%sp),%d0-%d1/%a0-%a1
	lea	16(%sp),%sp
	addq.l	#4,%sp
	clr.l	%d1
	lea	0x8000e508,%a1
	jmp	0x401213aa

	.align	2
	.globl	sfx_lock_load
sfx_lock_load:
	cmp.l	%d4,%d6
	blt.s	1f
	jmp	0x40009046
1:	moveq	#49,%d6
	cmp.l	%d4,%d6
	blt.s	2f
	moveq	#12,%d6
	cmp.l	%d2,%d6
	bne.s	2f
	move.l	%d2,-(%sp)
	move.l	%a3,-(%sp)
	move.l	%a2,-(%sp)
	jsr	sfx_lock_merge
	lea	12(%sp),%sp
	moveq	#-1,%d0
	moveq	#-1,%d1
2:	jmp	0x40009128
	.globl	sfx_rebuild
sfx_rebuild:
	moveq	#12,%d4
	cmp.l	%d1,%d4
	beq.s	1f
	tst.l	%d3
	beq.s	3f
	jmp	0x40009354
1:	cmp.l	#152,%d3
	blt.s	2f
3:	lea	-12(%sp),%sp
	movem.l	%d1/%a0-%a1,(%sp)
	move.l	%d1,-(%sp)
	move.l	%d2,-(%sp)
	move.l	%d3,-(%sp)
	move.l	%d0,-(%sp)
	move.l	%a1,-(%sp)
	move.l	%a0,-(%sp)
	jsr	sfx_rebuild_c
	lea	24(%sp),%sp
	movem.l	(%sp),%d1/%a0-%a1
	lea	12(%sp),%sp
	jmp	0x4000932c
2:	jmp	0x400092b2
	.globl	sfx_incr
sfx_incr:
	cmp.l	%d0,%d3
	bne.s	3f
	moveq	#37,%d2
	cmp.l	%a0,%d2
	bcs.s	4f
	bra.s	1f
3:	move.l	%a0,%d2
	bne.s	1f
4:	jmp	0x40009572
1:	move.l	(0,%a1,%a0.l*4),%d5
	clr.l	%d4
	jmp	0x4000945a
	.globl	sfx_fine
sfx_fine:
	tst.l	%d0
	bne.s	1f
	moveq	#12,%d2
	cmp.l	%d1,%d2
	beq.s	1f
	move.l	%d0,-(%sp)
	move.l	%d1,-(%sp)
	move.l	%d1,-(%sp)
	move.l	%a3,-(%sp)
	move.l	%a2,-(%sp)
	jsr	sfx_lock_merge
	lea	12(%sp),%sp
	move.l	(%sp)+,%d1
	move.l	(%sp)+,%d0
	jmp	0x40009128
1:	move.l	#5674,%d2
	jmp	0x400090de
	.globl	sfx_kload
sfx_kload:
	lsl.l	#8,%d0
	move.w	%d0,8(%a0)
	move.l	0x50(%a1),76(%a0)
	move.l	0x54(%a1),80(%a0)
	jmp	0x40007f48
	.globl	sfx_ksave
sfx_ksave:
	lsl.l	#8,%d0
	move.w	%d0,68(%a2)
	move.l	(%a1),0x50(%a2)
	move.l	4(%a1),0x54(%a2)
	jmp	0x40007f92
	.globl	sfx_play
sfx_play:
	move.w	(%a0),%d6
	move.w	4(%a0),%d4
	btst	#0,%d4
	bne.s	1f
	jmp	0x4012096e
1:	lea	-16(%sp),%sp
	movem.l	%d0-%d1/%a0-%a1,(%sp)
	move.l	%a0,-(%sp)
	jsr	sfx_play_c
	addq.l	#4,%sp
	movem.l	(%sp),%d0-%d1/%a0-%a1
	lea	16(%sp),%sp
	move.w	4(%a0),%d4
	jmp	0x4012096e

#NO_APP
	.align	2
	.type	lk_get.constprop.0, @function
lk_get.constprop.0:
	move.l 4(%sp),%d0
	move.l 8(%sp),%a0
	move.l 12(%sp),%a1
	tst.w %d0
	jmi .L5
	move.l %d0,%d1
	lsr.l #8,%d1
	btst #0,%d0
	jne .L3
	lsr.l #1,%d0
	move.l %d1,(%a0)
	moveq #127,%d1
	and.l %d0,%d1
	mov3q.l #3,%d0
	move.l %d1,(%a1)
.L1:
	rts
.L3:
	btst #1,%d0
	jeq .L4
	move.l %d1,(%a1)
	mov3q.l #2,%d0
	jra .L1
.L4:
	move.l %d1,(%a0)
	mov3q.l #1,%d0
	jra .L1
.L5:
	clr.l %d0
	jra .L1
	.size	lk_get.constprop.0, .-lk_get.constprop.0
	.align	2
	.globl	sfx_block
	.type	sfx_block, @function
sfx_block:
	lea (-68,%sp),%sp
	movem.l #23804,(%sp)
	move.l -2147457096,%d3
	cmp.l st+44.l,%d3
	jeq .L7
	mvz.w #8191,%d0
	move.l %d3,st+44
	move.l %d0,st+40
.L7:
#APP
| 109 "sfx.c" 1
	moveq #P_RR,%d1
| 0 "" 2
#NO_APP
	tst.l %d1
	jeq .L8
	move.b st+48,%d0
	subq.l #1,%d0
	tst.b %d0
	jeq .L9
	move.b %d0,st+48
.L8:
	mvz.w #2531,%d5
	mvz.b st+50,%d2
#APP
| 115 "sfx.c" 1
	moveq #P_MAXB,%d0
| 0 "" 2
#NO_APP
	moveq #13,%d6
	clr.l %d7
	muls.l %d3,%d5
	move.l %d0,40(%sp)
	lea fxw,%a2
.L25:
	moveq #84,%d0
	moveq #11,%d1
	muls.l %d2,%d0
	move.l %d0,%a0
	add.l #trig_sound_array,%a0
	cmp.l %d2,%d1
	jlt .L26
	mov3q.l #2,%a6
.L11:
	move.l st+40,%d1
	btst %d2,%d1
	jeq .L13
	move.l %d2,%d0
	lsl.l #2,%d0
	move.l %d0,%a1
	add.l #-2147419048,%a1
	cmp.l (%a1),%d3
	jne .L14
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	not.l %d0
	and.l %d1,%d0
	move.l %d0,st+40
.L13:
	lea (55,%sp),%a1
	clr.l %d0
	move.l %a1,%a4
.L17:
	move.l %d0,%d1
	asr.l #1,%d1
	moveq #127,%d4
	addq.l #2,%d0
	addq.l #2,%a1
	mvz.b (%a2,%d1.l),%d1
	lea (%a0,%d1.l*2),%a3
	move.b (%a3),%d1
	and.l %d4,%d1
	move.b %d1,-2(%a1)
	move.l %d1,44(%sp)
	mvz.b 1(%a3),%d1
	lsr.l #1,%d1
	move.b %d1,-1(%a1)
	cmp.l %d0,%a6
	jgt .L17
	move.l %d2,%d0
	sub.l %a0,%a0
	add.l %d0,%d0
	move.l st+36,%d1
	lsr.l %d2,%d1
	move.l %d0,%a3
	mov3q.l #1,%d0
	and.l %d0,%d1
	add.l #st,%a3
.L18:
	move.b (%a4,%a0.l),%d0
	move.b (%a3,%a0.l),%d4
	addq.l #1,%a0
	move.w %d0,%a1
	move.l %a1,%d0
	eor.l %d0,%d4
	tst.b %d4
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d1
	cmp.l %a0,%a6
	jne .L18
	tst.l %d1
	jeq .L19
	cmp.l 40(%sp),%d7
	jge .L22
	tst.l 1123449384
	jne .L22
	tst.l 1094562372
	jne .L22
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L22
	mvz.w #3800,%d4
	cmp.l 1094562392.l,%d4
	jcs .L22
	move.l 1094562704,%a0
	tst.l %a0
	jeq .L22
	move.l 52(%a0),%a0
	tst.l %a0
	jeq .L22
	move.l 52(%a0),%d0
	move.l #-260222380,%a0
	moveq #-9,%d1
	move.w #8193,%d0
	move.b %d2,54(%sp)
	move.l %a0,48(%sp)
	move.b %d1,55(%sp,%a6.l)
	move.w %d0,52(%sp)
	pea 48(%sp)
	pea 8(%a6)
	jsr 1073752544
	addq.l #8,%sp
	clr.l %d0
.L23:
	lea (%a4,%d0.l),%a0
	move.b (%a0),(%a3,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%a6
	jne .L23
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	addq.l #1,%d7
	not.l %d0
	and.l %d0,st+36
.L19:
	moveq #12,%d0
	cmp.l %d2,%d0
	jeq .L28
	addq.l #1,%d2
.L24:
	subq.l #1,%d6
	tst.l %d6
	jne .L25
.L22:
	move.b %d2,st+50
	movem.l (%sp),#23804
	lea (68,%sp),%sp
	rts
.L9:
	move.b st+49,%d0
	move.b %d1,st+48
	mov3q.l #1,%d1
	mvz.b %d0,%d2
	addq.l #1,%d0
	lsl.l %d2,%d1
	moveq #12,%d2
	or.l %d1,st+36
	mvz.b %d0,%d1
	cmp.l %d1,%d2
	jcs .L10
	move.b %d0,st+49
	jra .L8
.L10:
	clr.b %d4
	move.b %d4,st+49
	jra .L8
.L26:
	move.w #12,%a6
	jra .L11
.L14:
	mvz.w #152,%d0
	moveq #11,%d4
	muls.l %d2,%d0
	cmp.l %d2,%d4
	jlt .L27
	move.w #20,%a0
.L16:
	move.l %d0,%a3
	lea 42(%a3,%d5.l),%a1
	add.l %a1,%a0
	add.l #1092966627,%a0
	jra .L13
.L27:
	sub.l %a0,%a0
	jra .L16
.L28:
	clr.l %d2
	jra .L24
	.size	sfx_block, .-sfx_block
	.align	2
	.globl	sfx_lock_merge
	.type	sfx_lock_merge, @function
sfx_lock_merge:
	lea (-52,%sp),%sp
	movem.l #31996,(%sp)
	move.l 56(%sp),%a0
	moveq #12,%d2
	move.l 64(%sp),%d1
	move.b (%a0),%d0
	cmp.l %d1,%d2
	jne .L56
	mvz.b %d0,%d0
	mov3q.l #3,%d2
	mov3q.l #3,%d3
	mov3q.l #3,%d6
	add.l #-42,%d0
	and.l %d0,%d2
	move.l %d2,%a6
	lea (38,%a6),%a6
	cmp.l %d0,%d3
	jge .L57
	mov3q.l #2,%d2
.L46:
	mvz.w #5674,%d7
	move.l %a6,%d4
	clr.l %d5
	add.l %d4,%d4
	move.l 60(%sp),%a2
	muls.l %d7,%d1
	add.l %d1,%a2
	lea (84,%a2),%a3
.L54:
	lea -84(%a3,%d4.l),%a5
	move.l 56(%sp),%a0
	move.b 2(%a0,%d5.l),%d3
	clr.l 44(%sp)
	clr.l 48(%sp)
	move.w (%a5),%d0
	pea 48(%sp)
	pea 48(%sp)
	move.w %d0,-(%sp)
	clr.w -(%sp)
	jsr (lk_get.constprop.0)
	lea (12,%sp),%sp
	move.l %d6,%d1
	and.l %d0,%d1
	tst.b %d3
	jlt .L47
	mvz.b %d3,%d3
	tst.l %d1
	jne .L48
	addq.l #1,(%a3)
.L48:
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jne .L49
	move.l %d3,44(%sp)
.L50:
	or.l %d2,%d1
.L47:
	move.l 48(%sp),%d0
	mov3q.l #3,%d7
	move.l 44(%sp),%d3
	cmp.l %d1,%d7
	jne .L51
	lsl.l #8,%d3
	add.l %d0,%d0
.L60:
	or.l %d3,%d0
.L52:
	move.w %d0,(%a5)
	addq.l #1,%d5
	lea (88,%a3),%a3
	moveq #64,%d0
	cmp.l %d5,%d0
	jne .L54
	subq.l #2,%d2
	tst.l %d2
	jne .L45
	moveq #1,%d2
	lea (5632,%a6),%a6
	move.b %d2,(%a2,%a6.l)
.L45:
	movem.l (%sp),#31996
	lea (52,%sp),%sp
	rts
.L56:
	mov3q.l #1,%d6
	mov3q.l #2,%d2
	sub.l %a6,%a6
	jra .L46
.L57:
	mov3q.l #1,%d2
	jra .L46
.L49:
	move.l %d3,48(%sp)
	jra .L50
.L51:
	mov3q.l #1,%d7
	cmp.l %d1,%d7
	jne .L53
	lsl.l #8,%d3
	mov3q.l #1,%d0
	jra .L60
.L53:
	subq.l #2,%d1
	tst.l %d1
	jne .L58
	lsl.l #8,%d0
	mov3q.l #3,%d7
	or.l %d7,%d0
	jra .L52
.L58:
	moveq #-1,%d0
	jra .L52
	.size	sfx_lock_merge, .-sfx_lock_merge
	.align	2
	.globl	sfx_rebuild_c
	.type	sfx_rebuild_c, @function
sfx_rebuild_c:
	lea (-20,%sp),%sp
	moveq #66,%d1
	move.l 32(%sp),%d0
	movem.l #17412,(%sp)
	move.l 44(%sp),%d2
	muls.l %d1,%d0
	move.l 24(%sp),%a6
	moveq #12,%d1
	add.l %d0,%a6
	move.l 36(%sp),%d0
	asr.l #2,%d0
	cmp.l %d2,%d1
	jne .L70
	move.l %d0,%d1
	addq.l #4,%d1
.L62:
	move.b %d1,(%a6)
	move.b %d2,1(%a6)
	tst.l 40(%sp)
	jeq .L63
	moveq #12,%d1
	cmp.l %d2,%d1
	jeq .L64
	moveq #-128,%d0
	move.b %d0,66(%a6)
.L65:
	move.b %d0,67(%a6)
.L63:
	lea (68,%a6),%a6
	clr.l %d2
.L69:
	move.l 28(%sp),%a0
	clr.l 12(%sp)
	clr.l 16(%sp)
	move.w (%a0,%d2.l),%d0
	pea 16(%sp)
	pea 16(%sp)
	move.w %d0,-(%sp)
	clr.w -(%sp)
	jsr (lk_get.constprop.0)
	lea (12,%sp),%sp
	btst #0,%d0
	jeq .L71
	move.b 15(%sp),%d1
.L66:
	move.b %d1,-66(%a6)
	tst.l 40(%sp)
	jeq .L67
	btst #1,%d0
	jeq .L72
	move.b 19(%sp),%d0
.L68:
	move.b %d0,(%a6)
.L67:
	add.l #88,%d2
	addq.l #1,%a6
	cmp.l #5632,%d2
	jne .L69
	movem.l (%sp),#17412
	lea (20,%sp),%sp
	rts
.L70:
	moveq #41,%d1
	jra .L62
.L64:
	addq.l #8,%d0
	move.b %d0,66(%a6)
	moveq #12,%d0
	jra .L65
.L71:
	st %d1
	jra .L66
.L72:
	st %d0
	jra .L68
	.size	sfx_rebuild_c, .-sfx_rebuild_c
	.align	2
	.globl	sfx_play_c
	.type	sfx_play_c, @function
sfx_play_c:
	link.w %fp,#-16
	moveq #12,%d1
	move.l %a2,-(%sp)
	move.l 8(%fp),%a2
	move.l %d2,-(%sp)
	move.w (%a2),-10(%fp)
	mvz.w 2(%a2),%d2
	clr.l -8(%fp)
	clr.l -4(%fp)
	mvz.w -10(%fp),%d0
	cmp.l %d0,%d1
	jne .L81
	move.l %d2,%d0
	add.l #-38,%d0
	lsr.l #2,%d0
	jeq .L83
.L80:
	move.l -24(%fp),%d2
	move.l -20(%fp),%a2
	unlk %fp
	rts
.L81:
	moveq #12,%d1
	cmp.l %d0,%d1
	jcs .L80
	tst.l %d2
	jne .L80
.L83:
	mvz.w 4(%a2),%d0
	pea -4(%fp)
	pea -8(%fp)
	move.l %d0,-(%sp)
	jsr (lk_get.constprop.0)
	lea (12,%sp),%sp
	move.w -10(%fp),%d1
	lea trig_sound_array,%a0
	mulu.w #42,%d1
	add.l %d1,%d2
	move.w (%a0,%d2.l*2),%d1
	mov3q.l #1,%d2
	cmp.l %d0,%d2
	jne .L84
	move.l -8(%fp),%d0
	mvz.b %d1,%d1
	lsl.l #8,%d0
.L88:
	or.l %d1,%d0
	move.w %d0,4(%a2)
	jra .L80
.L84:
	subq.l #2,%d0
	tst.l %d0
	jne .L80
	move.l -4(%fp),%d0
	and.l #-256,%d1
	add.l %d0,%d0
	jra .L88
	.size	sfx_play_c, .-sfx_play_c
	.text
	.type	fxw, @object
	.size	fxw, 6
fxw:
	.base64	"AB0mJygp"
	.text
	.align	2
	.type	st, @object
	.size	st, 52
st:
	.zero	2
	.zero	34
	.long	8191
	.long	0
	.long	0
	.byte	1
	.byte	0
	.byte	0
	.zero	1
	.ident	"GCC: (GNU) 16.2.0"
