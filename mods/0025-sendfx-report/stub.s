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

#NO_APP
	.align	2
	.globl	sfx_block
	.type	sfx_block, @function
sfx_block:
	lea (-68,%sp),%sp
	movem.l #23804,(%sp)
	move.l -2147457096,%d3
	cmp.l st+44.l,%d3
	jeq .L2
	mvz.w #8191,%d0
	move.l %d3,st+44
	move.l %d0,st+40
.L2:
#APP
| 109 "sfx.c" 1
	moveq #P_RR,%d1
| 0 "" 2
#NO_APP
	tst.l %d1
	jeq .L3
	move.b st+48,%d0
	subq.l #1,%d0
	tst.b %d0
	jeq .L4
	move.b %d0,st+48
.L3:
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
.L20:
	moveq #84,%d0
	moveq #11,%d1
	muls.l %d2,%d0
	move.l %d0,%a0
	add.l #trig_sound_array,%a0
	cmp.l %d2,%d1
	jlt .L21
	mov3q.l #2,%a6
.L6:
	move.l st+40,%d1
	btst %d2,%d1
	jeq .L8
	move.l %d2,%d0
	lsl.l #2,%d0
	move.l %d0,%a1
	add.l #-2147419048,%a1
	cmp.l (%a1),%d3
	jne .L9
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	not.l %d0
	and.l %d1,%d0
	move.l %d0,st+40
.L8:
	lea (55,%sp),%a1
	clr.l %d0
	move.l %a1,%a4
.L12:
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
	jgt .L12
	move.l %d2,%d0
	sub.l %a0,%a0
	add.l %d0,%d0
	move.l st+36,%d1
	lsr.l %d2,%d1
	move.l %d0,%a3
	mov3q.l #1,%d0
	and.l %d0,%d1
	add.l #st,%a3
.L13:
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
	jne .L13
	tst.l %d1
	jeq .L14
	cmp.l 40(%sp),%d7
	jge .L17
	tst.l 1123449384
	jne .L17
	tst.l 1094562372
	jne .L17
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L17
	mvz.w #3800,%d4
	cmp.l 1094562392.l,%d4
	jcs .L17
	move.l 1094562704,%a0
	tst.l %a0
	jeq .L17
	move.l 52(%a0),%a0
	tst.l %a0
	jeq .L17
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
.L18:
	lea (%a4,%d0.l),%a0
	move.b (%a0),(%a3,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%a6
	jne .L18
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	addq.l #1,%d7
	not.l %d0
	and.l %d0,st+36
.L14:
	moveq #12,%d0
	cmp.l %d2,%d0
	jeq .L23
	addq.l #1,%d2
.L19:
	subq.l #1,%d6
	tst.l %d6
	jne .L20
.L17:
	move.b %d2,st+50
	movem.l (%sp),#23804
	lea (68,%sp),%sp
	rts
.L4:
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
	jcs .L5
	move.b %d0,st+49
	jra .L3
.L5:
	clr.b %d4
	move.b %d4,st+49
	jra .L3
.L21:
	move.w #12,%a6
	jra .L6
.L9:
	mvz.w #152,%d0
	moveq #11,%d4
	muls.l %d2,%d0
	cmp.l %d2,%d4
	jlt .L22
	move.w #20,%a0
.L11:
	move.l %d0,%a3
	lea 42(%a3,%d5.l),%a1
	add.l %a1,%a0
	add.l #1092966627,%a0
	jra .L8
.L22:
	sub.l %a0,%a0
	jra .L11
.L23:
	clr.l %d2
	jra .L19
	.size	sfx_block, .-sfx_block
	.align	2
	.globl	sfx_lock_merge
	.type	sfx_lock_merge, @function
sfx_lock_merge:
	lea (-20,%sp),%sp
	movem.l #1084,(%sp)
	move.l 24(%sp),%a0
	clr.l %d3
	move.l 28(%sp),%a1
	add.l #68172,%a1
	mvz.b (%a0),%d0
	move.l %d0,%a0
	mov3q.l #3,%d0
	lea (-42,%a0),%a0
	move.l %a0,%d2
	and.l %d0,%d2
	move.l %d2,%d4
	add.l %d4,%d4
.L45:
	move.l 24(%sp),%a2
	move.b 2(%a2,%d3.l),%d1
	jmi .L41
	lea -8(%a1,%d4.l),%a2
	move.w (%a2),%d0
	mvz.w %d0,%d5
	cmp.l #65535,%d5
	jne .L42
	clr.w %d0
	addq.l #1,(%a1)
.L42:
	ext.w %d1
	mov3q.l #3,%d5
	cmp.l %a0,%d5
	jlt .L43
	mvz.b %d0,%d0
	lsl.l #8,%d1
.L48:
	or.l %d1,%d0
	move.w %d0,(%a2)
.L41:
	addq.l #1,%d3
	lea (88,%a1),%a1
	moveq #64,%d0
	cmp.l %d3,%d0
	jne .L45
	mov3q.l #3,%d5
	cmp.l %a0,%d5
	jge .L40
	moveq #1,%d0
	move.l 28(%sp),%a0
	add.l #73758,%d2
	move.b %d0,(%a0,%d2.l)
.L40:
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L43:
	and.l #-256,%d0
	add.l %d1,%d1
	jra .L48
	.size	sfx_lock_merge, .-sfx_lock_merge
	.align	2
	.globl	sfx_rebuild_c
	.type	sfx_rebuild_c, @function
sfx_rebuild_c:
	move.l %a2,-(%sp)
	moveq #66,%d1
	move.l %d2,-(%sp)
	move.l 20(%sp),%d0
	moveq #12,%d2
	muls.l %d1,%d0
	move.l 12(%sp),%a0
	move.l 28(%sp),%a1
	add.l %d0,%a0
	move.l 24(%sp),%d0
	asr.l #2,%d0
	move.l %d0,%d1
	addq.l #4,%d1
	move.b %d1,(%a0)
	move.b %d2,1(%a0)
	tst.l %a1
	jeq .L50
	addq.l #8,%d0
	move.b %d0,66(%a0)
	move.b %d2,67(%a0)
.L50:
	lea (68,%a0),%a0
	clr.l %d1
.L54:
	move.l 16(%sp),%a2
	mvs.w (%a2,%d1.l),%d0
	tst.l %d0
	jlt .L55
	move.l %d0,%d2
	asr.l #8,%d2
.L51:
	move.b %d2,-66(%a0)
	tst.l %a1
	jeq .L52
	tst.l %d0
	jlt .L56
	asr.l #1,%d0
	moveq #127,%d2
	and.l %d2,%d0
.L53:
	move.b %d0,(%a0)
.L52:
	add.l #88,%d1
	addq.l #1,%a0
	cmp.l #5632,%d1
	jne .L54
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L55:
	st %d2
	jra .L51
.L56:
	st %d0
	jra .L53
	.size	sfx_rebuild_c, .-sfx_rebuild_c
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
