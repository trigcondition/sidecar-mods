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
	lea (-80,%sp),%sp
	movem.l #31996,(%sp)
#APP
| 89 "sfx.c" 1
	moveq #P_RR,%d1
| 0 "" 2
#NO_APP
	tst.l %d1
	jeq .L2
	move.w st+72,%d0
	subq.l #1,%d0
	tst.w %d0
	jeq .L3
	move.w %d0,st+72
.L2:
	mvz.b st+75,%d2
	move.l %sp,%d6
	moveq #13,%d3
#APP
| 97 "sfx.c" 1
	moveq #P_MAXB,%d1
| 0 "" 2
#NO_APP
	clr.l %d4
	move.l %d1,44(%sp)
	lea fxw,%a3
	add.l #60,%d6
.L21:
	moveq #84,%d0
	moveq #11,%d5
	muls.l %d2,%d0
	move.l %d0,%a0
	add.l #trig_sound_array,%a0
	cmp.l %d2,%d5
	jlt .L10
	move.l %d2,%d0
	mov3q.l #1,%a6
	lsl.l #2,%d0
	move.w (%a0),48(%sp)
	move.l %d0,%a2
	add.l #st,%a2
.L11:
	lea (48,%sp),%a4
	sub.l %a0,%a0
	move.l %a4,%a1
	clr.l %d1
.L13:
	mvz.w (%a1)+,%d0
	move.l %a0,%d5
	cmp.l (%a2,%d1.l*4),%d0
	sne %d0
	addq.l #1,%d1
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d5
	move.l %d5,%a0
	cmp.l %d1,%a6
	jne .L13
	tst.l %d5
	jeq .L14
	cmp.l 44(%sp),%d4
	jge .L17
	tst.l 1123449384
	jne .L17
	tst.l 1094562372
	jne .L17
	mov3q.l #1,%d7
	cmp.l 1094562388.l,%d7
	jne .L17
	move.w #3800,%a0
	cmp.l 1094562392.l,%a0
	jcs .L17
	move.l 1094562704,%a0
	tst.l %a0
	jeq .L17
	move.l 52(%a0),%a0
	tst.l %a0
	jeq .L17
	move.w #8193,%d1
	move.b %d2,66(%sp)
	move.l 52(%a0),%d0
	lea (67,%sp),%a0
	move.l #-260222380,%d0
	move.l %d0,60(%sp)
	lea (48,%sp),%a5
	move.w %d1,64(%sp)
	clr.l %d1
.L18:
	move.w (%a5)+,%d0
	moveq #127,%d7
	addq.l #1,%d1
	addq.l #2,%a0
	move.l %d0,%d5
	lsr.l #1,%d0
	lsr.l #8,%d5
	and.l %d7,%d0
	and.l %d7,%d5
	move.b %d0,-1(%a0)
	move.b %d5,-2(%a0)
	cmp.l %d1,%a6
	jne .L18
	mvs.w %a6,%d0
	moveq #-9,%d1
	add.l %d0,%d0
	move.b %d1,67(%sp,%d0.l)
	move.l %d0,%a0
	move.l %d6,-(%sp)
	pea 8(%a0)
	jsr 1073752544
	addq.l #8,%sp
	clr.l %d0
.L19:
	mvz.w (%a4)+,%d1
	move.l %d1,(%a2,%d0.l*4)
	addq.l #1,%d0
	cmp.l %d0,%a6
	jne .L19
	addq.l #1,%d4
.L14:
	moveq #12,%d0
	cmp.l %d2,%d0
	jeq .L23
	addq.l #1,%d2
.L20:
	subq.l #1,%d3
	tst.l %d3
	jne .L21
.L17:
	move.b %d2,st+75
	movem.l (%sp),#31996
	lea (80,%sp),%sp
	rts
.L3:
	move.w %d1,st+72
	move.b st+74,%d1
	moveq #11,%d2
	mvz.b %d1,%d0
	cmp.l %d0,%d2
	jcs .L22
	move.b %d1,%d0
	ext.w %d0
	mvz.w %d0,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	mov3q.l #1,%d0
	add.l #st,%a0
.L4:
	mov3q.l #1,%d5
	cmp.l %d0,%d5
	seq %d0
	neg.l %d0
	tst.b %d0
	jeq .L7
	mov3q.l #4,%a1
.L8:
	clr.l %d0
.L5:
	mov3q.l #-1,(%a0,%d0.l)
	addq.l #4,%d0
	cmp.l %a1,%d0
	jne .L5
	addq.l #1,%d1
	mvz.b %d1,%d0
	moveq #12,%d7
	cmp.l %d0,%d7
	jcs .L9
	move.b %d1,st+74
	jra .L2
.L22:
	lea st+48,%a0
	mov3q.l #6,%d0
	jra .L4
.L7:
	move.w #24,%a1
	jra .L8
.L9:
	clr.b %d0
	move.b %d0,st+74
	jra .L2
.L10:
	lea (48,%sp),%a1
	sub.l %a6,%a6
.L12:
	mvz.b (%a3,%a6.l),%d0
	mov3q.l #6,%d7
	addq.l #1,%a6
	move.w (%a0,%d0.l*2),(%a1)+
	cmp.l %a6,%d7
	jne .L12
	lea st+48,%a2
	jra .L11
.L23:
	clr.l %d2
	jra .L20
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
.L48:
	move.l 24(%sp),%a2
	move.b 2(%a2,%d3.l),%d1
	jmi .L44
	lea -8(%a1,%d4.l),%a2
	move.w (%a2),%d0
	mvz.w %d0,%d5
	cmp.l #65535,%d5
	jne .L45
	clr.w %d0
	addq.l #1,(%a1)
.L45:
	ext.w %d1
	mov3q.l #3,%d5
	cmp.l %a0,%d5
	jlt .L46
	mvz.b %d0,%d0
	lsl.l #8,%d1
.L51:
	or.l %d1,%d0
	move.w %d0,(%a2)
.L44:
	addq.l #1,%d3
	lea (88,%a1),%a1
	moveq #64,%d0
	cmp.l %d3,%d0
	jne .L48
	mov3q.l #3,%d5
	cmp.l %a0,%d5
	jge .L43
	moveq #1,%d0
	move.l 28(%sp),%a0
	add.l #73758,%d2
	move.b %d0,(%a0,%d2.l)
.L43:
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L46:
	and.l #-256,%d0
	add.l %d1,%d1
	jra .L51
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
	jeq .L53
	addq.l #8,%d0
	move.b %d0,66(%a0)
	move.b %d2,67(%a0)
.L53:
	lea (68,%a0),%a0
	clr.l %d1
.L57:
	move.l 16(%sp),%a2
	mvs.w (%a2,%d1.l),%d0
	tst.l %d0
	jlt .L58
	move.l %d0,%d2
	asr.l #8,%d2
.L54:
	move.b %d2,-66(%a0)
	tst.l %a1
	jeq .L55
	tst.l %d0
	jlt .L59
	asr.l #1,%d0
	moveq #127,%d2
	and.l %d2,%d0
.L56:
	move.b %d0,(%a0)
.L55:
	add.l #88,%d1
	addq.l #1,%a0
	cmp.l #5632,%d1
	jne .L57
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L58:
	st %d2
	jra .L54
.L59:
	st %d0
	jra .L56
	.size	sfx_rebuild_c, .-sfx_rebuild_c
	.text
	.type	fxw, @object
	.size	fxw, 6
fxw:
	.base64	"AB0mJygp"
	.text
	.align	2
	.type	st, @object
	.size	st, 76
st:
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.long	-1
	.word	1
	.byte	0
	.byte	0
	.ident	"GCC: (GNU) 16.2.0"
