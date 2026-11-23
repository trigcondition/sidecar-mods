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
	lea (-72,%sp),%sp
	movem.l #31996,(%sp)
	move.l -2147457096,%d3
	cmp.l st+44.l,%d3
	jeq .L2
	mvz.w #8191,%d0
	move.l %d3,st+44
	move.l %d0,st+40
.L2:
#APP
| 113 "sfx.c" 1
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
#APP
| 119 "sfx.c" 1
	moveq #P_MAXB,%d0
| 0 "" 2
#NO_APP
	move.l %d0,44(%sp)
	tst.b clean.l
	jeq .L30
	move.l st+36,%d0
	or.l st+40,%d0
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
.L6:
	lea trig_sound_array,%a0
	clr.l %d1
	lea raw,%a1
.L8:
	move.w (%a0),%d2
	mvz.w (%a1)+,%d6
	mvz.w %d2,%d4
	cmp.l %d6,%d4
	jeq .L7
	move.w %d2,-2(%a1)
	clr.l %d0
.L7:
	addq.l #1,%d1
	lea (84,%a0),%a0
	moveq #12,%d2
	cmp.l %d1,%d2
	jne .L8
	lea raw+24,%a2
	sub.l %a1,%a1
	lea fxw,%a3
.L10:
	mvz.b (%a3,%a1.l),%d1
	mvz.w (%a2)+,%d4
	add.l %d1,%d1
	move.l %d1,%a0
	add.l #trig_sound_array+1008,%a0
	move.w (%a0),%d1
	mvz.w %d1,%d2
	cmp.l %d4,%d2
	jeq .L9
	move.w %d1,-2(%a2)
	clr.l %d0
.L9:
	addq.l #1,%a1
	mov3q.l #6,%d5
	cmp.l %a1,%d5
	jne .L10
	tst.l %d0
	jne .L1
	mvz.w #2531,%d6
	move.b %d0,clean
	mvz.b st+50,%d2
	sub.l %a5,%a5
	muls.l %d3,%d6
	clr.l %d4
.L26:
	moveq #84,%d0
	moveq #11,%d1
	muls.l %d2,%d0
	move.l %d0,%a0
	add.l #trig_sound_array,%a0
	cmp.l %d2,%d1
	jlt .L31
	mov3q.l #2,%a6
.L12:
	move.l st+40,%d1
	btst %d2,%d1
	jeq .L14
	move.l %d2,%d0
	lsl.l #2,%d0
	move.l %d0,%a1
	add.l #-2147419048,%a1
	cmp.l (%a1),%d3
	jne .L15
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	not.l %d0
	and.l %d1,%d0
	move.l %d0,st+40
.L14:
	lea (59,%sp),%a1
	clr.l %d0
	move.l %a1,%a4
.L18:
	move.l %d0,%d1
	asr.l #1,%d1
	moveq #127,%d5
	addq.l #2,%d0
	addq.l #2,%a1
	mvz.b (%a3,%d1.l),%d1
	lea (%a0,%d1.l*2),%a2
	move.b (%a2),%d1
	and.l %d5,%d1
	move.b %d1,-2(%a1)
	move.l %d1,48(%sp)
	mvz.b 1(%a2),%d1
	lsr.l #1,%d1
	move.b %d1,-1(%a1)
	cmp.l %d0,%a6
	jgt .L18
	move.l %d2,%d0
	sub.l %a1,%a1
	add.l %d0,%d0
	move.l st+36,%d1
	lsr.l %d2,%d1
	move.l %d0,%a2
	mov3q.l #1,%d0
	and.l %d0,%d1
	add.l #st,%a2
.L19:
	move.b (%a4,%a1.l),%d0
	move.b (%a2,%a1.l),%d5
	addq.l #1,%a1
	move.w %d0,%a0
	move.l %a0,%d0
	eor.l %d0,%d5
	tst.b %d5
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d1
	cmp.l %a1,%a6
	jne .L19
	tst.l %d1
	jeq .L20
	cmp.l 44(%sp),%a5
	jge .L23
	tst.l 1123449384
	jne .L23
	tst.l 1094562372
	jne .L23
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L23
	mvz.w #3800,%d5
	cmp.l 1094562392.l,%d5
	jcs .L23
	move.l 1094562704,%a0
	tst.l %a0
	jeq .L23
	move.l 52(%a0),%a0
	tst.l %a0
	jeq .L23
	move.l 52(%a0),%d0
	move.l #-260222380,%a0
	moveq #-9,%d1
	move.w #8193,%d0
	move.b %d2,58(%sp)
	move.l %a0,52(%sp)
	move.b %d1,59(%sp,%a6.l)
	move.w %d0,56(%sp)
	pea 52(%sp)
	pea 8(%a6)
	jsr 1073752544
	addq.l #8,%sp
	clr.l %d0
.L24:
	lea (%a4,%d0.l),%a0
	move.b (%a0),(%a2,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%a6
	jne .L24
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	addq.l #1,%a5
	not.l %d0
	and.l %d0,st+36
.L20:
	addq.l #1,%d4
	moveq #12,%d0
	cmp.l %d2,%d0
	jeq .L33
	addq.l #1,%d2
.L25:
	moveq #13,%d1
	cmp.l %d4,%d1
	jne .L26
	tst.l st+40
	jne .L23
	moveq #1,%d5
	move.b %d5,clean
.L23:
	move.b %d2,st+50
.L1:
	movem.l (%sp),#31996
	lea (72,%sp),%sp
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
	clr.b %d5
	move.b %d5,st+49
	jra .L3
.L30:
	clr.l %d0
	jra .L6
.L31:
	move.w #12,%a6
	jra .L12
.L15:
	mvz.w #152,%d0
	moveq #11,%d5
	muls.l %d2,%d0
	cmp.l %d2,%d5
	jlt .L32
	move.w #20,%a0
.L17:
	move.l %d0,%a2
	lea 42(%a2,%d6.l),%a1
	add.l %a1,%a0
	add.l #1092966627,%a0
	jra .L14
.L32:
	sub.l %a0,%a0
	jra .L17
.L33:
	clr.l %d2
	jra .L25
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
.L58:
	move.l 24(%sp),%a2
	move.b 2(%a2,%d3.l),%d1
	jmi .L54
	lea -8(%a1,%d4.l),%a2
	move.w (%a2),%d0
	mvz.w %d0,%d5
	cmp.l #65535,%d5
	jne .L55
	clr.w %d0
	addq.l #1,(%a1)
.L55:
	ext.w %d1
	mov3q.l #3,%d5
	cmp.l %a0,%d5
	jlt .L56
	mvz.b %d0,%d0
	lsl.l #8,%d1
.L61:
	or.l %d1,%d0
	move.w %d0,(%a2)
.L54:
	addq.l #1,%d3
	lea (88,%a1),%a1
	moveq #64,%d0
	cmp.l %d3,%d0
	jne .L58
	mov3q.l #3,%d5
	cmp.l %a0,%d5
	jge .L53
	moveq #1,%d0
	move.l 28(%sp),%a0
	add.l #73758,%d2
	move.b %d0,(%a0,%d2.l)
.L53:
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L56:
	and.l #-256,%d0
	add.l %d1,%d1
	jra .L61
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
	jeq .L63
	addq.l #8,%d0
	move.b %d0,66(%a0)
	move.b %d2,67(%a0)
.L63:
	lea (68,%a0),%a0
	clr.l %d1
.L67:
	move.l 16(%sp),%a2
	mvs.w (%a2,%d1.l),%d0
	tst.l %d0
	jlt .L68
	move.l %d0,%d2
	asr.l #8,%d2
.L64:
	move.b %d2,-66(%a0)
	tst.l %a1
	jeq .L65
	tst.l %d0
	jlt .L69
	asr.l #1,%d0
	moveq #127,%d2
	and.l %d2,%d0
.L66:
	move.b %d0,(%a0)
.L65:
	add.l #88,%d1
	addq.l #1,%a0
	cmp.l #5632,%d1
	jne .L67
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L68:
	st %d2
	jra .L64
.L69:
	st %d0
	jra .L66
	.size	sfx_rebuild_c, .-sfx_rebuild_c
	.local	clean
	.comm	clean,1,1
	.local	raw
	.comm	raw,36,2
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
