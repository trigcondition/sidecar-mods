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
	tst.l	0x413db244
	bne.s	3f
	moveq	#1,%d0
	move.l	%d0,fxin_txsx_gap
3:	move.l	0x401b9e64,%d0
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
	.align	2
	.type	txsx_wait, @function
txsx_wait:
	tst.l 1094562372
	jne .L2
	clr.l st+24
	clr.l fxin_txsx_gap
.L7:
	clr.l %d0
.L1:
	rts
.L2:
	move.l st+16,%d0
	tst.l st+24
	jeq .L4
	tst.l fxin_txsx_gap
	jeq .L5
.L4:
	mov3q.l #1,st+24
	move.l %d0,st+20
	clr.l fxin_txsx_gap
.L6:
	mov3q.l #1,%d0
	jra .L1
.L5:
	sub.l st+20,%d0
	moveq #39,%d1
	cmp.l %d0,%d1
	jge .L6
	addq.l #1,st+28
	jra .L7
	.size	txsx_wait, .-txsx_wait
	.align	2
	.type	try_send, @function
try_send:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L23
	lea txsx_wait,%a2
	jsr (%a2)
	tst.l %d0
	jeq .L10
.L23:
	clr.l %d0
.L8:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L10:
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jeq .L8
	move.l 1094562704,%a0
	clr.l %d2
.L12:
	tst.l %a0
	jeq .L13
	move.l 52(%a0),%a0
	addq.l #1,%d2
	mov3q.l #4,%d0
	cmp.l %d2,%d0
	jne .L12
.L13:
	jsr (%a2)
	tst.l %d0
	jne .L15
	mvz.w #4027,%d0
	cmp.l 1094562392.l,%d0
	jlt .L15
	subq.l #4,%d2
	tst.l %d2
	jeq .L16
.L15:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #4,%sp
	jra .L23
.L16:
	move.l 12(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	mov3q.l #1,%d0
	jra .L8
	.size	try_send, .-try_send
	.text
.LC0:
	.string	"\360}RT'"
	.ascii	"\367"
	.text
	.align	2
	.globl	fxin_tick
	.type	fxin_tick, @function
fxin_tick:
	link.w %fp,#-44
	addq.l #1,st+16
	movem.l #1036,(%sp)
	move.w 1075551848,%d2
	move.l 1094562388,%d1
	move.l %d1,-32(%fp)
	mov3q.l #1,%d1
	cmp.l -32(%fp),%d1
	seq %d0
	neg.l %d0
	tst.b st+2.l
	jne .L25
	move.w %d2,st
	move.b %d1,st+2
.L25:
	mov3q.l #1,%d1
	tst.b st+3.l
	jne .L26
	cmp.l -32(%fp),%d1
	jne .L28
	moveq #1,%d1
	move.b %d1,st+4
	jra .L28
.L26:
	cmp.l -32(%fp),%d1
	jeq .L28
	move.l #1180191025,%a0
	cmp.l 1075551844.l,%a0
	jne .L28
	move.l #1180191024,%a1
	move.l %a1,1075551844
.L28:
	move.b %d0,st+3
	mvz.w st,%d1
	mvz.w %d2,%d0
	cmp.l %d1,%d0
	jne .L29
	tst.b st+4.l
	jeq .L30
.L29:
	mov3q.l #7,-(%sp)
	pea .LC0
	move.l %fp,%d3
	add.l #-16,%d3
	move.l %d3,-(%sp)
	jsr memcpy
	lea (12,%sp),%sp
	move.l #1180191025,%a0
	cmp.l 1075551844.l,%a0
	seq %d0
	mov3q.l #7,-(%sp)
	move.l %d3,-(%sp)
	neg.l %d0
	move.b %d0,-11(%fp)
	jsr try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L30
	clr.b %d0
	move.w %d2,st
	move.b %d0,st+4
.L30:
	mov3q.l #1,%d1
	cmp.l -32(%fp),%d1
	jne .L24
	move.b st+5,%d2
	mvz.b %d2,%d0
	move.w %d2,%a1
	moveq #19,%d2
	move.l %d0,-32(%fp)
	cmp.l %d0,%d2
	jcs .L33
	clr.l %d1
.L33:
	sub.l %a0,%a0
	move.l #stem_voice,%d2
.L36:
	mvz.b (%a0,%d2.l),%d0
	add.l #1076432344,%d0
	move.l %d0,%a2
	mvz.b (%a2),%d0
	lea lfo_track_array,%a2
	muls.w #42,%d0
	mvs.w 76(%a2,%d0.l*2),%d0
	tst.l %d0
	jlt .L41
	add.l #128,%d0
	asr.l #8,%d0
	cmp.l #128,%d0
	jne .L35
	moveq #127,%d0
	jra .L35
.L41:
	clr.l %d0
.L35:
	move.b %d0,-26(%fp,%a0.l)
	addq.l #1,%a0
	moveq #8,%d0
	cmp.l %a0,%d0
	jne .L36
	mvz.b -2147457946,%d0
	moveq #127,%d2
	move.l #-260222380,%a0
	lsr.l #7,%d0
	move.b %d0,-18(%fp)
	move.b -2147457946,%d0
	move.l %a0,-16(%fp)
	sub.l %a0,%a0
	and.l %d2,%d0
	moveq #-9,%d2
	move.b %d0,-17(%fp)
	moveq #80,%d0
	move.b %d2,-1(%fp)
	move.l #st+6,%d2
	move.b %d0,-12(%fp)
.L37:
	move.b -26(%fp,%a0.l),%d3
	move.b (%a0,%d2.l),%d0
	addq.l #1,%a0
	move.b %d3,-12(%a0,%fp.l)
	eor.l %d3,%d0
	tst.b %d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d1
	moveq #10,%d0
	cmp.l %a0,%d0
	jne .L37
	move.l -32(%fp),%d0
	cmp.l #255,%d0
	jeq .L38
	move.l %a1,%d0
	addq.l #1,%d0
	move.b %d0,st+5
.L38:
	tst.l %d1
	jeq .L24
	pea 16.w
	pea -16(%fp)
	jsr try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L24
	clr.l %d0
.L40:
	lea -26(%fp,%d0.l),%a1
	move.l %d2,%a0
	moveq #10,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L40
	clr.b %d2
	move.b %d2,st+5
.L24:
	movem.l -44(%fp),#1036
	unlk %fp
	rts
	.size	fxin_tick, .-fxin_tick
	.text
	.type	stem_voice, @object
	.size	stem_voice, 8
stem_voice:
	.base64	"AAIHAQMFBAY="
	.globl	fxin_txsx_gap
	.section	.bss,"aw",@nobits
	.align	2
	.type	fxin_txsx_gap, @object
	.size	fxin_txsx_gap, 4
fxin_txsx_gap:
	.zero	4
	.align	2
	.type	st, @object
	.size	st, 32
st:
	.zero	32
	.ident	"GCC: (GNU) 16.2.0"
