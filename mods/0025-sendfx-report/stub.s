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
	move.l	%a3,-(%sp)
	move.l	%a2,-(%sp)
	jsr	sfx_lock_merge
	addq.l	#8,%sp
	moveq	#-1,%d0
	moveq	#-1,%d1
2:	jmp	0x40009128
	.globl	sfx_rebuild
sfx_rebuild:
	moveq	#12,%d4
	cmp.l	%d1,%d4
	beq.s	1f
	jmp	0x40009354
1:	cmp.l	#152,%d3
	blt.s	2f
	lea	-12(%sp),%sp
	movem.l	%d1/%a0-%a1,(%sp)
	move.l	%d2,-(%sp)
	move.l	%d3,-(%sp)
	move.l	%d0,-(%sp)
	move.l	%a1,-(%sp)
	move.l	%a0,-(%sp)
	jsr	sfx_rebuild_c
	lea	20(%sp),%sp
	movem.l	(%sp),%d1/%a0-%a1
	lea	12(%sp),%sp
	jmp	0x4000932c
2:	jmp	0x400092b2
	.globl	sfx_incr
sfx_incr:
	cmp.l	%d0,%d3
	bne.s	1f
	moveq	#37,%d2
	cmp.l	%a0,%d2
	bcc.s	1f
	jmp	0x40009572
1:	move.l	(0,%a1,%a0.l*4),%d5
	clr.l	%d4
	jmp	0x4000945a
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
	lea (-48,%sp),%sp
	movem.l #23804,(%sp)
	move.l 52(%sp),%a0
	mvz.b (%a0),%d0
	move.l %d0,%a6
	mov3q.l #3,%d0
	lea (-42,%a6),%a6
	move.l %a6,%d2
	and.l %d0,%d2
	move.l %d2,%d3
	add.l #38,%d3
	cmp.l %a6,%d0
	jlt .L56
	mov3q.l #1,%d5
.L46:
	add.l %d3,%d3
	move.l 56(%sp),%a2
	clr.l %d4
	add.l #68172,%a2
.L54:
	move.l 52(%sp),%a0
	move.b 2(%a0,%d4.l),%d6
	clr.l 40(%sp)
	clr.l 44(%sp)
	tst.b %d6
	jlt .L47
	lea -84(%a2,%d3.l),%a4
	mvz.b %d6,%d6
	move.w (%a4),%d0
	pea 44(%sp)
	pea 44(%sp)
	move.w %d0,-(%sp)
	clr.w -(%sp)
	jsr (lk_get.constprop.0)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L48
	addq.l #1,(%a2)
.L48:
	mov3q.l #1,%d1
	cmp.l %d5,%d1
	jne .L49
	move.l %d6,40(%sp)
.L50:
	mov3q.l #3,%d7
	or.l %d5,%d0
	move.l 40(%sp),%d6
	cmp.l %d0,%d7
	jne .L51
	move.l 44(%sp),%d0
	lsl.l #8,%d6
	add.l %d0,%d0
	or.l %d6,%d0
.L52:
	move.w %d0,(%a4)
.L47:
	addq.l #1,%d4
	lea (88,%a2),%a2
	moveq #64,%d7
	cmp.l %d4,%d7
	jne .L54
	mov3q.l #3,%d0
	cmp.l %a6,%d0
	jge .L45
	moveq #1,%d1
	move.l 56(%sp),%a0
	add.l #73758,%d2
	move.b %d1,(%a0,%d2.l)
.L45:
	movem.l (%sp),#23804
	lea (48,%sp),%sp
	rts
.L56:
	mov3q.l #2,%d5
	jra .L46
.L49:
	move.l %d6,44(%sp)
	jra .L50
.L51:
	mov3q.l #1,%d7
	cmp.l %d0,%d7
	jne .L53
	move.l %d6,%d0
	lsl.l #8,%d0
	or.l %d7,%d0
	jra .L52
.L53:
	move.l 44(%sp),%d0
	mov3q.l #3,%d1
	lsl.l #8,%d0
	or.l %d1,%d0
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
	move.l 24(%sp),%a6
	muls.l %d1,%d0
	add.l %d0,%a6
	move.l 36(%sp),%d0
	asr.l #2,%d0
	move.l %d0,%d1
	addq.l #4,%d1
	move.b %d1,(%a6)
	moveq #12,%d1
	move.b %d1,1(%a6)
	tst.l 40(%sp)
	jeq .L59
	addq.l #8,%d0
	move.b %d0,66(%a6)
	move.b %d1,67(%a6)
.L59:
	lea (68,%a6),%a6
	clr.l %d2
.L63:
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
	jeq .L64
	move.b 15(%sp),%d1
.L60:
	move.b %d1,-66(%a6)
	tst.l 40(%sp)
	jeq .L61
	btst #1,%d0
	jeq .L65
	move.b 19(%sp),%d0
.L62:
	move.b %d0,(%a6)
.L61:
	add.l #88,%d2
	addq.l #1,%a6
	cmp.l #5632,%d2
	jne .L63
	movem.l (%sp),#17412
	lea (20,%sp),%sp
	rts
.L64:
	st %d1
	jra .L60
.L65:
	st %d0
	jra .L62
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
	move.w 2(%a2),%d0
	clr.l -8(%fp)
	clr.l -4(%fp)
	move.w %d0,-10(%fp)
	mvz.w (%a2),%d0
	cmp.l %d0,%d1
	jne .L73
	mvz.w -10(%fp),%d2
	move.l %d2,%d0
	add.l #-38,%d0
	lsr.l #2,%d0
	move.l %d2,-14(%fp)
	tst.l %d0
	jne .L73
	pea -4(%fp)
	mvz.w 4(%a2),%d0
	pea -8(%fp)
	add.l #504,%d2
	move.l %d0,-(%sp)
	jsr (lk_get.constprop.0)
	lea (12,%sp),%sp
	lea trig_sound_array,%a0
	move.w (%a0,%d2.l*2),%d1
	mov3q.l #1,%d2
	cmp.l %d0,%d2
	jne .L76
	move.l -8(%fp),%d0
	mvz.b %d1,%d1
	lsl.l #8,%d0
.L77:
	or.l %d1,%d0
	move.w %d0,4(%a2)
.L73:
	move.l -24(%fp),%d2
	move.l -20(%fp),%a2
	unlk %fp
	rts
.L76:
	subq.l #2,%d0
	tst.l %d0
	jne .L73
	move.l -4(%fp),%d0
	and.l #-256,%d1
	add.l %d0,%d0
	jra .L77
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
