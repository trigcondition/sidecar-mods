| Mod 0030 - FX in: delay + reverb return on Overbridge IN L/R, switched by the host (26 / 27).
| GENERATED from fxin.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit fxin.c.
	.include "symbols.inc"
#NO_APP
	.file	"fxin.c"
	.text
#APP
	.text
	.align	2
	.globl	fxin_ob
	.if	fx_reverb_out != fx_delay_out - 256
	.error	"fxin_ob reads the reverb at fx_delay_out - 256"
	.endif
fxin_ob:
	move.l	0x401b9e64,%d0
	cmp.l	#0x46584931,%d0
	bne.w	2f
	lea	-12(%sp),%sp
	movem.l	%d2-%d4,(%sp)
	move.l	%macsr,%d4
	move.l	#0xa0,%macsr
	movclr.l %acc0,%d0
	movclr.l %acc1,%d0
	move.l	fx_return_gain_pre,%d1
	add.l	fx_return_gain_post,%d1
	move.l	fx_return_gain_pre+4,%d2
	add.l	fx_return_gain_post+4,%d2
	lea	fx_delay_out,%a0
	lea	0x80007440+40,%a1
	moveq	#32,%d3
1:	move.l	(%a0),%d0
	mac.l	%d0,%d1,-256(%a0),%d0,%acc0
	mac.l	%d0,%d2,%acc0
	mac.l	%d0,%d2,4(%a0),%d0,%acc0
	mac.l	%d0,%d1,-252(%a0),%d0,%acc1
	mac.l	%d0,%d2,%acc1
	mac.l	%d0,%d2,%acc1
	addq.l	#8,%a0
	movclr.l %acc0,%d0
	move.l	%d0,(%a1)+
	movclr.l %acc1,%d0
	move.l	%d0,(%a1)
	lea	44(%a1),%a1
	subq.l	#1,%d3
	bne.s	1b
	move.l	%d4,%macsr
	movem.l	(%sp),%d2-%d4
	lea	12(%sp),%sp
2:	jmp	ob_in_write

#NO_APP
	.text
.LC0:
	.string	"\360}RT'"
	.ascii	"\367"
	.text
	.align	2
	.globl	fxin_tick
	.type	fxin_tick, @function
fxin_tick:
	subq.l #8,%sp
	move.l %a6,-(%sp)
	move.w 1075551848,%a6
	move.l 1094562388,%d1
	move.l %d2,-(%sp)
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	seq %d0
	neg.l %d0
	tst.b st+2.l
	jne .L2
	move.w %a6,st
	move.b %d2,st+2
.L2:
	mov3q.l #1,%d2
	tst.b st+3.l
	jne .L3
	cmp.l %d1,%d2
	jne .L5
	moveq #1,%d1
	move.b %d1,st+4
	jra .L5
.L3:
	cmp.l %d1,%d2
	jeq .L5
	move.l #1180191025,%d1
	cmp.l 1075551844.l,%d1
	jne .L5
	move.l #1180191024,%d2
	move.l %d2,1075551844
.L5:
	move.b %d0,st+3
	mvz.w st,%d1
	mvz.w %a6,%d0
	cmp.l %d1,%d0
	jne .L6
	tst.b st+4.l
	jeq .L1
.L6:
	move.l %sp,%d2
	add.l #9,%d2
	mov3q.l #7,-(%sp)
	pea .LC0
	move.l %d2,-(%sp)
	jsr memcpy
	lea (12,%sp),%sp
	move.l #1180191025,%d1
	cmp.l 1075551844.l,%d1
	seq %d0
	neg.l %d0
	move.b %d0,14(%sp)
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L1
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jeq .L1
	move.l 1094562704,%a0
	clr.l %d0
.L9:
	tst.l %a0
	jeq .L10
	move.l 52(%a0),%a0
	addq.l #1,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L9
.L10:
	mvz.w #4027,%d1
	cmp.l 1094562392.l,%d1
	jlt .L12
	subq.l #4,%d0
	tst.l %d0
	jeq .L13
.L12:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #4,%sp
.L1:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a6
	addq.l #8,%sp
	rts
.L13:
	move.l %d2,-(%sp)
	clr.b %d2
	mov3q.l #7,-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	move.w %a6,st
	move.b %d2,st+4
	jra .L1
	.size	fxin_tick, .-fxin_tick
	.section	.bss,"aw",@nobits
	.align	2
	.type	st, @object
	.size	st, 6
st:
	.zero	6
	.ident	"GCC: (GNU) 16.2.0"
