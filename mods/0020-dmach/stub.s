| Mod 0020 - digital machines on the digital layer (machines 35, 38, 39, 41, 42).
| GENERATED from dmach.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit dmach.c.
| The FM core follows Mutable Instruments Braids (MIT, (c) 2012 Emilie Gillet).
#NO_APP
	.file	"dmach.c"
	.text
	.align	2
	.type	sine, @function
sine:
	move.l %d2,-(%sp)
	moveq #24,%d2
	move.l 8(%sp),%d1
	move.l %d1,%d0
	lsr.l %d2,%d0
	lea sine_table,%a1
	mvs.w (%a1,%d0.l*2),%d2
	mvs.w 2(%a1,%d0.l*2),%d0
	move.l %d2,%a0
	sub.l %d2,%d0
	moveq #9,%d2
	lsr.l %d2,%d1
	move.l (%sp)+,%d2
	and.l #32767,%d1
	muls.l %d1,%d0
	moveq #15,%d1
	asr.l %d1,%d0
	add.l %a0,%d0
	rts
	.size	sine, .-sine
	.align	2
	.type	note_increment, @function
note_increment:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	moveq #119,%d2
	move.l 12(%sp),%d0
	move.l %d0,%d1
	asr.l #7,%d1
	cmp.l %d1,%d2
	jlt .L7
	moveq #127,%d2
	and.l %d0,%d2
	move.l %d2,%a0
.L3:
	add.l #-108,%d1
	sub.l %a1,%a1
.L4:
	tst.l %d1
	jlt .L5
	moveq #31,%d0
	cmp.l %a1,%d0
	jlt .L8
	lea note_inc,%a2
	move.l (%a2,%d1.l*4),%d0
	move.l 4(%a2,%d1.l*4),%d1
	sub.l %d0,%d1
	asr.l #7,%d1
	move.l %a0,%d2
	muls.l %d2,%d1
	add.l %d1,%d0
	move.l %a1,%d1
	lsr.l %d1,%d0
.L2:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L7:
	move.w #127,%a0
	moveq #119,%d1
	jra .L3
.L5:
	add.l #12,%d1
	addq.l #1,%a1
	jra .L4
.L8:
	clr.l %d0
	jra .L2
	.size	note_increment, .-note_increment
	.align	2
	.type	decay, @function
decay:
	move.l %d2,-(%sp)
	moveq #127,%d0
	and.l 12(%sp),%d0
	lea decay_q15,%a0
	moveq #15,%d2
	move.l 8(%sp),%d1
	asr.l %d2,%d1
	move.l (%sp)+,%d2
	mvz.w (%a0,%d0.l*2),%d0
	muls.l %d1,%d0
	rts
	.size	decay, .-decay
	.align	2
	.type	begin, @function
begin:
	lea (-12,%sp),%sp
	move.l 16(%sp),%d0
	move.l %d0,%d1
	lsl.l #7,%d1
	movem.l #3076,(%sp)
	move.l 20(%sp),%a0
	move.l 24(%sp),%a2
	move.l %d1,%a1
	move.l %d0,%d1
	add.l #-268431872,%d1
	lsl.l #3,%d1
	add.l #-2147454912,%a1
	move.l %d1,%a3
	clr.l %d1
	clr.l 4(%a3)
	clr.l (%a3)
.L11:
	clr.l (%a1)+
	moveq #32,%d2
	addq.l #1,%d1
	cmp.l %d1,%d2
	jne .L11
	mov3q.l #2,%d1
	cmp.l %d0,%d1
	jeq .L17
	mov3q.l #7,%d2
	cmp.l %d0,%d2
	jeq .L18
	tst.l %d0
	jne .L13
	moveq #90,%d1
.L12:
	clr.b %d2
	move.b %d2,7(%a0,%d1.l)
	move.b %d2,6(%a0,%d1.l)
	move.b %d2,5(%a0,%d1.l)
	move.b %d2,4(%a0,%d1.l)
.L13:
	move.l (%a2),%d1
	tst.l %d1
	jne .L14
	mov3q.l #1,(%a2)
	move.l #1076432344,%a0
	mvz.b (%a0,%d0.l),%d0
	move.l #-2147457084,%a0
	moveq #127,%d1
	moveq #80,%d2
	move.b (%a0,%d0.l*2),%d0
	and.l %d1,%d0
	muls.l %d2,%d0
	moveq #127,%d2
	divs.l %d2,%d0
	add.l #48,%d0
	move.l %d0,28(%a2)
	mov3q.l #1,%d0
.L10:
	movem.l (%sp),#3076
	lea (12,%sp),%sp
	rts
.L17:
	moveq #98,%d1
	jra .L12
.L18:
	moveq #106,%d1
	jra .L12
.L14:
	subq.l #1,%d1
	tst.l %d1
	jeq .L19
	move.l 28(%sp),%a0
	move.l %a0,%d0
	add.l #128,%d0
.L16:
	clr.l (%a0)+
	cmp.l %a0,%d0
	jne .L16
	mov3q.l #-1,%d0
	jra .L10
.L19:
	clr.l %d0
	jra .L10
	.size	begin, .-begin
	.section	.fm4h,"ax",@progbits
	.align	2
	.type	fm4_view_is_fm4, @function
fm4_view_is_fm4:
	move.l %a2,-(%sp)
	move.l 12(%sp),%d0
	subq.l #4,%d0
	lsr.l #1,%d0
	move.l 8(%sp),%a2
	tst.l %d0
	jne .L26
	move.l (%a2),%a0
	move.l %a2,-(%sp)
	move.l 144(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	tst.l %d0
	jge .L24
	move.l 116(%a2),-(%sp)
	jsr 1074489554
	move.l %d0,-(%sp)
	move.l 120(%a2),-(%sp)
	jsr 1074423646
	lea (12,%sp),%sp
.L25:
	move.l %d0,-(%sp)
	jsr 1074514544
	addq.l #4,%sp
	moveq #35,%d1
	cmp.l %d0,%d1
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
.L22:
	move.l (%sp)+,%a2
	rts
.L24:
	move.l %d0,-(%sp)
	move.l 104(%a2),-(%sp)
	jsr 1074455700
	addq.l #8,%sp
	jra .L25
.L26:
	clr.l %d0
	jra .L22
	.size	fm4_view_is_fm4, .-fm4_view_is_fm4
	.align	2
	.type	fm4_slew, @function
fm4_slew:
	move.l 8(%sp),%d0
	mvz.b 7(%sp),%d1
	add.l %d0,%d0
	sub.l %d1,%d0
	tst.l %d0
	jle .L28
	addq.l #3,%d0
	asr.l #2,%d0
.L29:
	move.b 7(%sp),%d1
	add.l %d1,%d0
	rts
.L28:
	mov3q.l #3,%d1
	sub.l %d0,%d1
	move.l %d1,%d0
	asr.l #2,%d0
	neg.l %d0
	jra .L29
	.size	fm4_slew, .-fm4_slew
	.text
	.align	2
	.globl	efm_render
	.type	efm_render, @function
efm_render:
	lea (-96,%sp),%sp
	move.l 100(%sp),%d0
	move.l %d0,%d1
	lsl.l #5,%d1
	movem.l #31996,(%sp)
	move.l 108(%sp),%a4
	move.l %d1,%a2
	move.l %d0,%d1
	lsl.l #7,%d1
	add.l #-2147418376,%a2
	move.l %d1,%a3
	add.l #-2147456008,%a3
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	move.l 112(%sp),-(%sp)
	move.l %d0,-(%sp)
	jsr begin
	lea (16,%sp),%sp
	mov3q.l #-1,%d1
	cmp.l %d0,%d1
	jeq .L30
	mvz.b (%a4),%d6
	mvz.b 8(%a4),%d1
	mvz.b 2(%a4),%d2
	mvz.b 4(%a4),%d3
	move.l %d6,76(%sp)
	mvz.b 10(%a4),%d6
	mvz.b 6(%a4),%d5
	mvz.b 12(%a4),%d7
	move.l %d1,%a6
	mvz.b 14(%a4),%d4
	move.l %d6,56(%sp)
	tst.l %d0
	jeq .L32
	move.l #1073741824,%a0
	clr.l 8(%a2)
	clr.l 4(%a2)
	move.l %a0,20(%a2)
	move.l %a0,16(%a2)
	move.l %a0,12(%a2)
	tst.l 24(%a2)
	jne .L32
	move.l #19088743,%a1
	move.l %a1,24(%a2)
.L32:
	add.l #-64,%d2
	lsl.l #6,%d2
	moveq #9,%d6
	lsr.l #3,%d5
	lea decay,%a4
	move.l 112(%sp),%d0
	asr.l %d6,%d0
	move.l 28(%a2),%d1
	lsl.l #8,%d4
	move.l %d2,%a0
	pea (%a0,%d0.l)
	move.l %d1,56(%sp)
	jsr note_increment
	move.l 12(%a2),%a5
	move.l %d3,(%sp)
	lea ratio_q2,%a0
	move.l %d0,%d2
	moveq #15,%d0
	move.l %a5,-(%sp)
	and.l %d0,%d5
	move.l %d2,%d0
	lsr.l #2,%d0
	mvz.b (%a0,%d5.l),%d5
	muls.l %d0,%d5
	jsr (%a4)
	addq.l #8,%sp
	move.l 16(%a2),%d3
	move.l %d0,60(%sp)
	move.l %a6,-(%sp)
	move.l %d3,-(%sp)
	jsr (%a4)
	addq.l #8,%sp
	move.l 20(%a2),%a6
	move.l %d0,68(%sp)
	move.l 56(%sp),-(%sp)
	move.l %a6,-(%sp)
	jsr (%a4)
	addq.l #8,%sp
	move.l 4(%a2),%d6
	move.l %d0,%a0
	move.l 60(%sp),%d0
	sub.l %a5,%d0
	asr.l #5,%d0
	move.l 8(%a2),%a1
	move.l %d6,56(%sp)
	move.l %a1,%d6
	move.l %d0,80(%sp)
	move.l 68(%sp),%d0
	sub.l %d3,%d0
	asr.l #5,%d0
	move.l %d0,84(%sp)
	move.l %a0,%d0
	sub.l %a6,%d0
	asr.l #5,%d0
	move.l %d0,88(%sp)
	move.l %a1,64(%sp)
	move.l 52(%sp),%d1
	move.l 24(%a2),%a4
	muls.l %d1,%d4
	muls.l %d7,%d1
	clr.l %d7
	asr.l #7,%d4
	lsr.l #7,%d1
	move.l %d4,92(%sp)
	move.l %d1,72(%sp)
	mvz.w 78(%sp),%d1
	move.l 56(%sp),%d4
	move.l %d1,76(%sp)
.L33:
	add.l %d5,%d6
	move.l %d6,-(%sp)
	move.l %a0,56(%sp)
	jsr sine
	addq.l #4,%sp
	add.l %d2,%d4
	addq.l #1,%d7
	move.l %d3,%d1
	move.l %d0,%a1
	moveq #15,%d0
	asr.l %d0,%d1
	move.l 92(%sp),%d0
	muls.l %d0,%d1
	moveq #15,%d0
	asr.l %d0,%d1
	move.l %a1,%d0
	muls.l %d0,%d1
	lsl.l #3,%d1
	move.l %d1,%a1
	pea (%a1,%d4.l)
	jsr sine
	addq.l #4,%sp
	move.l %a4,%d1
	move.l %d0,44(%sp)
	mov3q.l #1,%d0
	and.l %d0,%d1
	move.l %a4,%d0
	lsr.l #1,%d0
	add.l 84(%sp),%d3
	move.l 52(%sp),%a0
	neg.l %d1
	and.l #-805306367,%d1
	eor.l %d1,%d0
	mvs.w %d0,%d1
	move.l %d0,%a4
	move.l 72(%sp),%d0
	muls.l %d0,%d1
	moveq #15,%d0
	asr.l #7,%d1
	move.l %d1,48(%sp)
	move.l %a6,%d1
	asr.l %d0,%d1
	add.l 88(%sp),%a6
	move.l %d1,%d0
	move.l 48(%sp),%d1
	muls.l %d0,%d1
	moveq #15,%d0
	asr.l %d0,%d1
	move.l %d1,48(%sp)
	move.l %a5,%d1
	asr.l %d0,%d1
	move.l 44(%sp),%d0
	add.l 80(%sp),%a5
	muls.l %d1,%d0
	moveq #15,%d1
	asr.l %d1,%d0
	move.l 48(%sp),%d1
	add.l %d0,%d1
	move.l 76(%sp),%d0
	muls.l %d0,%d1
	moveq #9,%d0
	lsl.l %d0,%d1
	move.l %d1,(%a3)+
	moveq #32,%d1
	cmp.l %d7,%d1
	jne .L33
	move.l %d5,%d0
	lsl.l #5,%d2
	lsl.l #5,%d0
	move.l 60(%sp),%d6
	move.l 68(%sp),16(%a2)
	move.l %a0,20(%a2)
	move.l %d6,12(%a2)
	swap %d6
	move.l %a4,24(%a2)
	add.l 56(%sp),%d2
	add.l 64(%sp),%d0
	move.l %d2,4(%a2)
	move.l %d0,8(%a2)
	tst.w %d6
	jgt .L30
	cmp.l #65535,%a0
	jgt .L30
	mov3q.l #-1,(%a2)
.L30:
	movem.l (%sp),#31996
	lea (96,%sp),%sp
	rts
	.size	efm_render, .-efm_render
	.section	.fmbd,"ax",@progbits
	.align	2
	.globl	fmbd_render
	.type	fmbd_render, @function
fmbd_render:
	lea (-84,%sp),%sp
	move.l 88(%sp),%d0
	move.l %d0,%d1
	lsl.l #5,%d1
	movem.l #31996,(%sp)
	move.l 96(%sp),%a4
	move.l %d1,%a2
	move.l %d0,%d1
	lsl.l #7,%d1
	add.l #-2147418376,%a2
	move.l %d1,%a3
	add.l #-2147456008,%a3
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	move.l 100(%sp),-(%sp)
	move.l %d0,-(%sp)
	jsr begin
	lea (16,%sp),%sp
	mov3q.l #-1,%d1
	cmp.l %d0,%d1
	jeq .L41
	mvz.b (%a4),%d2
	mvz.b 12(%a4),%d7
	mvz.b 2(%a4),%d5
	mvz.b 4(%a4),%d4
	move.l %d2,44(%sp)
	mvz.b 6(%a4),%d1
	mvz.b 8(%a4),%d6
	mvz.b 10(%a4),%d3
	move.l %d7,%a6
	mvz.b 14(%a4),%d2
	tst.l %d0
	jeq .L43
	move.l #1073741824,%a4
	clr.l 8(%a2)
	clr.l 4(%a2)
	move.l %a4,20(%a2)
	move.l %a4,16(%a2)
	move.l %a4,12(%a2)
.L43:
	lsr.l #1,%d6
	lea decay,%a4
	add.l #-64,%d5
	lsr.l #3,%d2
	move.l 28(%a2),%d7
	move.l 20(%a2),%a5
	lsl.l #6,%d5
	move.l %d7,60(%sp)
	moveq #9,%d7
	move.l %d6,-(%sp)
	move.l %a5,-(%sp)
	move.l %d1,64(%sp)
	jsr (%a4)
	addq.l #8,%sp
	move.l %d0,%d6
	move.l %a5,%d0
	add.l %d6,%d0
	swap %d0
	ext.l %d0
	move.l %d5,%a0
	muls.l %d3,%d0
	move.l %d0,%a5
	moveq #9,%d0
	lea (%a5,%a5.l*2),%a5
	move.l %a5,%d3
	asr.l %d0,%d3
	move.l 100(%sp),%d0
	asr.l %d7,%d0
	add.l %d0,%a0
	pea (%a0,%d3.l*2)
	jsr note_increment
	move.l 12(%a2),%a5
	move.l %d4,(%sp)
	lea ratio_q2,%a0
	move.l %d0,%d3
	moveq #15,%d0
	move.l %a5,-(%sp)
	and.l %d0,%d2
	move.l %d3,%d0
	lsr.l #2,%d0
	mvz.b (%a0,%d2.l),%d2
	muls.l %d0,%d2
	jsr (%a4)
	move.l 16(%a2),%d4
	addq.l #8,%sp
	move.l %a6,-(%sp)
	move.l %d4,-(%sp)
	move.l %d0,%d5
	jsr (%a4)
	addq.l #8,%sp
	lea sine,%a6
	move.l 8(%a2),%a4
	move.l 4(%a2),%d7
	move.l %a4,%a1
	move.l %d0,68(%sp)
	move.l %d5,%d0
	sub.l %a5,%d0
	asr.l #5,%d0
	move.l 56(%sp),%d1
	sub.l %a0,%a0
	move.l %d7,64(%sp)
	move.l %a4,48(%sp)
	move.l %d0,72(%sp)
	lsl.l #8,%d1
	move.l 68(%sp),%d0
	sub.l %d4,%d0
	asr.l #5,%d0
	move.l %d0,76(%sp)
	move.l 60(%sp),%d7
	muls.l %d7,%d1
	move.l 64(%sp),%d7
	asr.l #7,%d1
	move.l %d1,80(%sp)
	mvz.w 46(%sp),%d1
	move.l %d1,60(%sp)
.L44:
	add.l %d2,%a1
	move.l %a1,-(%sp)
	move.l %a0,56(%sp)
	move.l %a1,60(%sp)
	jsr (%a6)
	addq.l #4,%sp
	add.l %d3,%d7
	move.l %d4,%d1
	move.l %d0,%a4
	moveq #15,%d0
	asr.l %d0,%d1
	move.l 80(%sp),%d0
	muls.l %d0,%d1
	moveq #15,%d0
	asr.l %d0,%d1
	move.l %a4,%d0
	muls.l %d0,%d1
	lsl.l #3,%d1
	move.l %d1,%a4
	pea (%a4,%d7.l)
	jsr (%a6)
	addq.l #4,%sp
	move.l %a5,%d1
	move.l %d0,%a4
	moveq #15,%d0
	asr.l %d0,%d1
	move.l %a4,%d0
	move.l 52(%sp),%a0
	addq.l #1,%a0
	add.l 72(%sp),%a5
	muls.l %d0,%d1
	moveq #15,%d0
	add.l 76(%sp),%d4
	move.l 56(%sp),%a1
	asr.l %d0,%d1
	move.l 60(%sp),%d0
	muls.l %d0,%d1
	moveq #9,%d0
	lsl.l %d0,%d1
	move.l %d1,(%a3)+
	moveq #32,%d1
	cmp.l %a0,%d1
	jne .L44
	lsl.l #5,%d3
	lsl.l #5,%d2
	move.l %d5,12(%a2)
	swap %d5
	move.l 68(%sp),16(%a2)
	move.l %d6,20(%a2)
	add.l 64(%sp),%d3
	add.l 48(%sp),%d2
	move.l %d3,4(%a2)
	move.l %d2,8(%a2)
	tst.w %d5
	jgt .L41
	mov3q.l #-1,(%a2)
.L41:
	movem.l (%sp),#31996
	lea (84,%sp),%sp
	rts
	.size	fmbd_render, .-fmbd_render
	.section	.gnd,"ax",@progbits
	.align	2
	.globl	gnd_render
	.type	gnd_render, @function
gnd_render:
	lea (-76,%sp),%sp
	move.l 80(%sp),%d0
	move.l %d0,%d1
	lsl.l #5,%d1
	movem.l #31996,(%sp)
	move.l 88(%sp),%a4
	move.l %d1,%a2
	move.l %d0,%d1
	lsl.l #7,%d1
	add.l #-2147418376,%a2
	move.l %d1,%a3
	add.l #-2147456008,%a3
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	move.l 92(%sp),-(%sp)
	move.l %d0,-(%sp)
	jsr begin
	lea (16,%sp),%sp
	move.l %d0,%a0
	mov3q.l #-1,%d0
	cmp.l %a0,%d0
	jeq .L52
	mvz.b (%a4),%d1
	mvz.b 4(%a4),%d2
	mvz.b 10(%a4),%d6
	mvz.b 2(%a4),%d4
	move.l %d1,48(%sp)
	mvz.b 6(%a4),%d3
	mvz.b 8(%a4),%d7
	mvz.b 12(%a4),%d1
	move.l %d2,52(%sp)
	mvz.b 14(%a4),%d0
	move.l %d6,72(%sp)
	tst.l %a0
	jeq .L54
	move.l #1073741824,%a0
	clr.l 4(%a2)
	move.l %a0,16(%a2)
	move.l %a0,12(%a2)
	move.l %a0,8(%a2)
	tst.l 20(%a2)
	jne .L54
	move.l #38177486,%d2
	move.l %d2,20(%a2)
.L54:
	lsr.l #1,%d0
	move.l 12(%a2),%d5
	moveq #9,%d2
	move.l 28(%a2),%d6
	add.l #-64,%d4
	lea decay,%a6
	move.l %d0,-(%sp)
	move.l %d5,-(%sp)
	move.l %d1,52(%sp)
	jsr (%a6)
	addq.l #8,%sp
	muls.l %d6,%d7
	lsl.l #6,%d4
	move.l %d0,%a4
	add.l %a4,%d5
	add.l %d5,%d5
	subx.l %d5,%d5
	move.l 92(%sp),%d0
	asr.l %d2,%d0
	moveq #15,%d2
	asr.l #7,%d7
	move.l %d0,%a0
	mov3q.l #6,%d0
	add.l %d4,%a0
	muls.l %d3,%d5
	muls.l %d0,%d5
	pea (%a0,%d5.l)
	jsr note_increment
	move.l 8(%a2),%a5
	addq.l #4,%sp
	move.l 52(%sp),-(%sp)
	move.l %a5,-(%sp)
	move.l %d0,%d5
	jsr (%a6)
	addq.l #8,%sp
	move.l %d7,68(%sp)
	move.l 16(%a2),%d3
	move.l %d3,%d4
	asr.l %d2,%d4
	move.l 44(%sp),%d1
	lsr.l #3,%d1
	move.l %d0,%a6
	clr.l %d7
	mvz.w #29558,%d0
	move.l 4(%a2),%d2
	addq.l #1,%d1
	move.l %d1,64(%sp)
	move.l 72(%sp),%d1
	muls.l %d0,%d4
	move.l %a6,%d0
	sub.l %a5,%d0
	muls.l %d1,%d6
	asr.l #5,%d0
	move.l %d2,52(%sp)
	move.l 20(%a2),%d2
	move.l %d0,56(%sp)
	move.l %d4,%d0
	sub.l %d3,%d0
	asr.l #7,%d6
	asr.l #5,%d0
	move.l %d6,72(%sp)
	mvz.w 50(%sp),%d6
	move.l %d0,60(%sp)
	move.l %d6,48(%sp)
	move.l 52(%sp),%a0
.L60:
	add.l %d5,%a0
	move.l %a0,-(%sp)
	move.l %a0,48(%sp)
	jsr sine
	addq.l #4,%sp
	mov3q.l #1,%d1
	and.l %d2,%d1
	lsr.l #1,%d2
	move.l 44(%sp),%a0
	neg.l %d1
	and.l #-805306367,%d1
	eor.l %d1,%d2
	move.l 64(%sp),%d1
	muls.l %d0,%d1
	cmp.l #-32767,%d1
	jge .L55
	mvs.w #-32767,%d1
.L56:
	mvs.w %d2,%d0
	move.l 72(%sp),%d6
	muls.l %d6,%d0
	moveq #15,%d6
	asr.l #7,%d0
	add.l %d1,%d0
	move.l %a5,%d1
	asr.l %d6,%d1
	muls.l %d1,%d0
	move.l %d3,%d1
	asr.l %d6,%d1
	asr.l %d6,%d0
	move.l 68(%sp),%d6
	muls.l %d6,%d1
	asr.l #7,%d1
	btst #0,%d2
	jeq .L61
	mov3q.l #1,%a1
.L57:
	move.l %a1,%d6
	muls.l %d6,%d1
	asr.l #1,%d1
	add.l %d0,%d1
	cmp.l #-32767,%d1
	jge .L58
	mvs.w #-32767,%d1
.L59:
	move.l 48(%sp),%d6
	moveq #9,%d0
	add.l 56(%sp),%a5
	add.l 60(%sp),%d3
	muls.l %d6,%d1
	addq.l #1,%d7
	lsl.l %d0,%d1
	move.l %d1,(%a3)+
	moveq #32,%d1
	cmp.l %d7,%d1
	jne .L60
	lsl.l #5,%d5
	move.l %a6,8(%a2)
	move.l %a4,12(%a2)
	move.l %d4,16(%a2)
	move.l %d2,20(%a2)
	add.l 52(%sp),%d5
	move.l %d5,4(%a2)
	cmp.l #65535,%a6
	jgt .L52
	mov3q.l #-1,(%a2)
.L52:
	movem.l (%sp),#31996
	lea (76,%sp),%sp
	rts
.L55:
	cmp.l #32767,%d1
	jle .L56
	mvz.w #32767,%d1
	jra .L56
.L61:
	mov3q.l #-1,%a1
	jra .L57
.L58:
	cmp.l #32767,%d1
	jle .L59
	mvz.w #32767,%d1
	jra .L59
	.size	gnd_render, .-gnd_render
	.section	.swav,"ax",@progbits
	.align	2
	.globl	swav_render
	.type	swav_render, @function
swav_render:
	lea (-128,%sp),%sp
	move.l 132(%sp),%d0
	move.l %d0,%d1
	lsl.l #5,%d1
	movem.l #31996,(%sp)
	move.l 140(%sp),%a3
	move.l %d1,%a2
	move.l %d0,%d1
	lsl.l #7,%d1
	add.l #-2147418376,%a2
	move.l %d1,%a6
	add.l #-2147456008,%a6
	move.l %a6,-(%sp)
	move.l %a2,-(%sp)
	move.l 144(%sp),-(%sp)
	move.l %d0,-(%sp)
	jsr begin
	lea (16,%sp),%sp
	mov3q.l #-1,%d1
	cmp.l %d0,%d1
	jeq .L69
	mvz.b 8(%a3),%d3
	mvz.b (%a3),%d5
	mvz.b 2(%a3),%d2
	mvz.b 4(%a3),%d6
	move.l %d3,%a4
	mvz.b 12(%a3),%d3
	mvz.b 6(%a3),%d4
	mvz.b 10(%a3),%d1
	move.l %d3,120(%sp)
	mvz.b 14(%a3),%d3
	move.l %d3,%a5
	tst.l %d0
	jeq .L71
	move.l 28(%a2),%d0
	move.l #858993459,%a0
	move.l #1717986918,%d3
	move.l %a0,4(%a2)
	move.l #-1717986919,%a0
	mvz.b %d0,%d0
	move.l %d3,8(%a2)
	move.l #-858993460,%d3
	move.l %a0,12(%a2)
	move.l #1073741824,%a0
	move.l %d3,16(%a2)
	mov3q.l #-1,20(%a2)
	move.l %a0,24(%a2)
	or.l #2147418112,%d0
	move.l %d0,28(%a2)
.L71:
	move.l 28(%a2),%d7
	move.l %d7,%d3
	clr.w %d3
	swap %d3
	moveq #15,%d0
	add.l #-64,%d2
	move.l %d1,-(%sp)
	lsl.l #6,%d2
	lea decay,%a3
	mvz.b %d7,%d7
	lsl.l %d0,%d3
	add.l #-88,%d7
	asr.l #1,%d7
	move.l %d3,-(%sp)
	jsr (%a3)
	addq.l #8,%sp
	moveq #9,%d1
	move.l %d0,100(%sp)
	move.l 144(%sp),%d0
	asr.l %d1,%d0
	move.l %d2,%a0
	pea (%a0,%d0.l)
	jsr note_increment
	move.l %d0,%d1
	lsr.l #7,%d1
	move.l %d0,%d2
	muls.l %d4,%d1
	move.l %d2,%d4
	lsr.l #7,%d1
	move.l %d1,%d0
	add.l %d0,%d0
	sub.l %d0,%d4
	move.l %d4,72(%sp)
	move.l %d2,%d4
	sub.l %d1,%d4
	add.l %d2,%d1
	move.l %d1,80(%sp)
	move.l %a5,%d1
	add.l %d2,%d0
	add.l %d1,%d1
	move.l %d4,76(%sp)
	mvz.w #256,%d4
	move.l %d0,84(%sp)
	sub.l %d1,%d4
	move.l %d4,112(%sp)
	move.l 24(%a2),%d4
	move.l %d1,88(%sp)
	move.l %d6,(%sp)
	move.l %d4,-(%sp)
	jsr (%a3)
	addq.l #8,%sp
	lea (%a4,%d7.l),%a1
	move.l %d0,64(%sp)
	sub.l %d4,%d0
	asr.l #5,%d0
	move.l %d0,112(%sp)
	move.l 100(%sp),%d0
	sub.l %d3,%d0
	asr.l #5,%d0
	move.l %d0,116(%sp)
	moveq #127,%d0
	cmp.l %a1,%d0
	jge .L72
	move.w #127,%a1
.L73:
	move.l 8(%a2),%d0
	mvz.w %d5,%d5
	move.l 12(%a2),%d1
	move.l %d0,52(%sp)
	move.l 16(%a2),%d0
	move.l %d1,92(%sp)
	move.l 20(%a2),%d1
	move.l %d0,56(%sp)
	lsr.l #7,%d0
	move.l %d1,96(%sp)
	move.l 52(%sp),%d1
	move.l %d5,104(%sp)
	move.l 4(%a2),%a0
	clr.l %d5
	move.l %a0,%a5
	eor.l %d0,%d1
	move.l %a0,88(%sp)
	move.l 96(%sp),%d7
	move.l 56(%sp),%a3
	move.l 92(%sp),%d6
	clr.l 60(%sp)
	move.l 52(%sp),%a4
	move.l %d1,48(%sp)
.L74:
	add.l 68(%sp),%a5
	add.l 72(%sp),%a4
	add.l 76(%sp),%a3
	add.l %d2,%d6
	move.l %a5,%d0
	move.l %a4,%d1
	clr.w %d0
	swap %d0
	clr.w %d1
	swap %d1
	add.l 80(%sp),%d7
	addq.l #1,60(%sp)
	move.l %d0,%a0
	move.l %d1,%d0
	move.l %a3,%d1
	clr.w %d1
	swap %d1
	add.l %a0,%d0
	add.l %d1,%d0
	move.l %d7,%d1
	clr.w %d1
	swap %d1
	move.l %d1,%a0
	move.l %d0,%d1
	add.l %a0,%d1
	add.l #-131072,%d1
	move.l %d1,%d0
	asr.l #2,%d0
	move.l 84(%sp),%d1
	muls.l %d0,%d1
	move.l %d6,%d0
	clr.w %d0
	swap %d0
	move.l %d1,124(%sp)
	move.l %d0,%a0
	move.l 108(%sp),%d0
	lea (-32768,%a0),%a0
	move.l %a0,%d1
	muls.l %d0,%d1
	move.l 48(%sp),%d0
	move.l %d1,%a0
	move.l 124(%sp),%d1
	add.l %a0,%d1
	asr.l #8,%d1
	move.l %d1,%a0
	move.l #1664525,%d1
	muls.l %d1,%d0
	add.l #1013904223,%d0
	move.l %d0,%d1
	clr.w %d1
	swap %d1
	move.l %d0,48(%sp)
	move.l %d3,%d0
	add.l 116(%sp),%d3
	muls.w 122(%sp),%d1
	asr.l #7,%d1
	move.l %d1,44(%sp)
	moveq #15,%d1
	asr.l %d1,%d0
	move.l 44(%sp),%d1
	muls.l %d0,%d1
	moveq #15,%d0
	asr.l %d0,%d1
	move.l %a1,%d0
	add.l %a0,%d1
	sub.l %d5,%d1
	muls.l %d0,%d1
	mvz.w #258,%d0
	muls.l %d0,%d1
	moveq #15,%d0
	asr.l %d0,%d1
	add.l %d1,%d5
	move.l %d4,%d1
	asr.l %d0,%d1
	add.l 112(%sp),%d4
	muls.l %d5,%d1
	asr.l %d0,%d1
	move.l 104(%sp),%d0
	muls.l %d0,%d1
	moveq #9,%d0
	lsl.l %d0,%d1
	move.l %d1,(%a6)+
	moveq #32,%d1
	cmp.l 60(%sp),%d1
	jne .L74
	move.l 68(%sp),%d0
	moveq #15,%d3
	move.l 28(%a2),%d1
	lsl.l #5,%d2
	lsl.l #5,%d0
	mvz.b %d1,%d1
	add.l 92(%sp),%d2
	add.l 88(%sp),%d0
	move.l %d2,12(%a2)
	move.l %d0,4(%a2)
	move.l 72(%sp),%d0
	move.l 64(%sp),%d2
	lsl.l #5,%d0
	move.l %d2,24(%a2)
	swap %d2
	add.l 52(%sp),%d0
	move.l %d0,8(%a2)
	move.l 76(%sp),%d0
	lsl.l #5,%d0
	add.l 56(%sp),%d0
	move.l %d0,16(%a2)
	move.l 80(%sp),%d0
	lsl.l #5,%d0
	add.l 96(%sp),%d0
	move.l %d0,20(%a2)
	move.l 100(%sp),%d0
	asr.l %d3,%d0
	swap %d0
	clr.w %d0
	or.l %d0,%d1
	move.l %d1,28(%a2)
	tst.w %d2
	jgt .L69
	mov3q.l #-1,(%a2)
.L69:
	movem.l (%sp),#31996
	lea (128,%sp),%sp
	rts
.L72:
	mov3q.l #4,%d1
	cmp.l %a1,%d1
	jle .L73
	mov3q.l #4,%a1
	jra .L73
	.size	swav_render, .-swav_render
	.section	.fm4h
	.align	2
	.globl	fm4_param_record
	.type	fm4_param_record, @function
fm4_param_record:
	move.l %d2,-(%sp)
	moveq #41,%d1
	move.l 8(%sp),%a0
	move.l 12(%sp),%d0
	cmp.l %a0,%d1
	jcc .L83
.L86:
	clr.l %d0
.L82:
	move.l (%sp)+,%d2
	rts
.L83:
	move.l %a0,%d1
	add.l #-9,%d1
	lsr.l #3,%d1
	jne .L85
	moveq #52,%d1
	cmp.l %d0,%d1
	jcs .L86
	lsl.l #3,%d0
	add.l %a0,%d0
	move.l #1094563324,%a0
	move.l -36(%a0,%d0.l*4),%d0
	jra .L82
.L85:
	move.l %a0,%d1
	add.l #-17,%d1
	lsr.l #3,%d1
	jne .L87
	moveq #35,%d1
	cmp.l %d0,%d1
	jne .L89
	move.w #449,%a1
.L88:
	lea -17(%a1,%a0.l),%a0
	move.l %a0,%d0
	jra .L82
.L89:
	move.w #39,%a1
	jra .L88
.L87:
	move.l #1094563156,%a1
	move.l (%a1,%a0.l*4),%d0
	jra .L82
	.size	fm4_param_record, .-fm4_param_record
	.align	2
	.globl	fm4_page_record
	.type	fm4_page_record, @function
fm4_page_record:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.l 12(%sp),%a2
	mov3q.l #7,%d0
	cmp.l 16(%sp),%d0
	jcs .L93
	move.l (%a2),%a0
	move.l %a2,-(%sp)
	move.l 104(%a0),%a0
	jsr (%a0)
	move.l %d0,-(%sp)
	move.l %a2,-(%sp)
	move.l %d0,%d2
	jsr fm4_view_is_fm4
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L92
	move.l 16(%sp),%d1
	lea fm4_p2_records,%a0
	move.l (%a0,%d1.l*4),%d0
.L90:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L92:
	move.l %d2,-(%sp)
	jsr 1074787700
	move.l 20(%sp),%d1
	addq.l #1,%d1
	mvz.w %d1,%d1
	addq.l #4,%sp
	move.l %d0,%a0
	move.l (%a0,%d1.l*4),%d0
	jra .L90
.L93:
	clr.l %d0
	jra .L90
	.size	fm4_page_record, .-fm4_page_record
	.align	2
	.globl	fm4_page_title
	.type	fm4_page_title, @function
fm4_page_title:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.l 12(%sp),%a2
	move.l (%a2),%a0
	move.l %a2,-(%sp)
	move.l 104(%a0),%a0
	jsr (%a0)
	move.l %d0,-(%sp)
	move.l %a2,-(%sp)
	move.l %d0,%d2
	jsr fm4_view_is_fm4
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L95
	move.l #fm4_p2_title,%d0
.L94:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L95:
	move.l %d2,-(%sp)
	jsr 1074787700
	addq.l #4,%sp
	move.l %d0,%a0
	move.l (%a0),%d0
	jra .L94
	.size	fm4_page_title, .-fm4_page_title
	.align	2
	.globl	fm4_prep
	.type	fm4_prep, @function
fm4_prep:
	lea (-104,%sp),%sp
	move.l 116(%sp),%a1
	movem.l #31996,(%sp)
	mov3q.l #7,%d2
	mvz.b 12(%a1),%d0
	move.w 24(%a1),%d7
	mvz.b 14(%a1),%d5
	mvz.b 2(%a1),%d1
	and.l %d0,%d2
	mvz.b 16(%a1),%d0
	mvz.w %d5,%d3
	move.w 4(%a1),%a0
	mvz.b (%a1),%d4
	add.l #-64,%d0
	move.l %d0,52(%sp)
	mvz.b 18(%a1),%d0
	move.w %d7,56(%sp)
	move.l %d3,80(%sp)
	move.l %d2,64(%sp)
	add.l #-64,%d0
	move.l %d0,84(%sp)
	move.l %d1,76(%sp)
	mvz.b 6(%a1),%d6
	mvz.b 20(%a1),%d2
	move.l 124(%sp),%a3
	move.l 128(%sp),%a6
	move.l 136(%sp),%a2
	move.w 22(%a1),%d1
	mvz.b 26(%a1),%d0
	mvz.b 8(%a1),%d7
	move.l %d0,%a4
	mvz.b 30(%a1),%d0
	mvz.w %d0,%d3
	move.l %d3,88(%sp)
	moveq #21,%d3
	cmp.l %d7,%d3
	jcc .L98
	moveq #21,%d7
.L98:
	mvz.w %d7,%d7
	moveq #21,%d3
	move.l %d7,100(%sp)
	mvz.b 10(%a1),%d7
	cmp.l %d7,%d3
	jcc .L99
	moveq #21,%d7
.L99:
	mvz.w %d7,%d7
	moveq #8,%d3
	move.l %d7,96(%sp)
	mvz.b 28(%a1),%d7
	move.w %d7,%a1
	cmp.l %d7,%d3
	jcc .L100
	move.w #8,%a1
.L100:
	mvz.w %a1,%d7
	move.l %d7,92(%sp)
	tst.l 132(%sp)
	jeq .L101
	clr.l 16(%a3)
	clr.l 12(%a3)
	clr.l 8(%a3)
	clr.l 4(%a3)
	tst.w %d2
	jeq .L121
	sub.l %a1,%a1
.L102:
	move.l 28(%a3),%d7
	move.l %a1,20(%a3)
	clr.l 24(%a3)
	mvz.b %d7,%d7
	or.l #2147483392,%d7
	move.l %d7,28(%a3)
	move.w 4(%a6),%d7
	jeq .L122
	move.w %d7,6(%a6)
	moveq #64,%d7
.L103:
	move.b %d7,8(%a6)
	move.l %d4,%d7
	add.l %d7,%d7
	add.l %d0,%d0
	add.l %d5,%d5
	clr.l 12(%a6)
	move.b %d7,(%a6)
	move.b %d0,3(%a6)
	move.l %d6,%d7
	add.l %d7,%d7
	clr.b %d0
	move.b %d5,2(%a6)
	move.b %d7,1(%a6)
	move.b %d0,9(%a6)
.L104:
	move.l 108(%sp),%d0
	mov3q.l #1,%d3
	mvz.w #35328,%d5
	lsl.l #3,%d0
	move.l %d0,%a1
	lea (168,%a1),%a1
	add.l 112(%sp),%a1
	mvz.b 4(%a1),%d7
	move.l 4(%a1),%d0
	lsr.l #4,%d7
	lsr.l %d7,%d5
	and.l %d3,%d5
	move.l %d0,%d3
	and.l #1048576,%d3
	or.l %d3,%d5
	sne %d5
	mvs.b %d5,%d5
	neg.l %d5
	tst.b 3(%a1)
	jgt .L106
	subq.l #3,%d7
	tst.l %d7
	jeq .L106
	tst.l %d5
	jne .L107
.L106:
	clr.l 12(%a6)
	jra .L105
.L121:
	move.l #1073741825,%a1
	jra .L102
.L122:
	clr.b %d7
	jra .L103
.L101:
	tst.b 9(%a6)
	jeq .L104
.L105:
	move.l 28(%a3),%d7
	move.l %d7,%d5
	mvz.b %d5,%d5
	mvz.w #128,%d0
	move.l %a4,%d3
	move.l 20(%a3),%a1
	sub.l %d5,%d0
	muls.l %d3,%d0
	mvz.w #128,%d3
	asr.l #7,%d0
	sub.l %d0,%d3
	move.l %d3,48(%sp)
	moveq #-2,%d0
	move.l %a1,%d3
	and.l %d3,%d0
	move.l %d0,%a4
	moveq #15,%d0
	asr.l %d0,%d3
	move.l %d3,72(%sp)
	move.l %a1,%d3
	btst #0,%d3
	jne .L111
	lea decay_q15,%a0
	moveq #15,%d7
	mvz.w (%a0,%d2.l*2),%d1
	mvz.w #32768,%d0
	sub.l %d1,%d0
	lsl.l %d7,%d0
	add.l %a4,%d0
	move.l %d0,%d2
	cmp.l #1073741824,%d0
	jle .L112
	move.l #1073741824,%d2
.L112:
	moveq #15,%d1
	move.l %d2,%d3
	asr.l %d1,%d3
	cmp.l #1073741823,%d0
	sgt %d1
	move.l 72(%sp),56(%sp)
	move.l #1073741824,%d0
	move.l %d3,60(%sp)
	mvs.b %d1,%d1
	neg.l %d1
	or.l %d2,%d1
.L113:
	asr.l #7,%d0
	move.l %d1,20(%a3)
	lea fm4_slew,%a5
	add.l %a4,%d2
	swap %d2
	ext.l %d2
	lsl.l #8,%d0
	or.l %d5,%d0
	move.l %d0,28(%a3)
	mvz.b 1(%a6),%d1
	mvz.b (%a6),%d5
	mvz.b 3(%a6),%d7
	move.l %d1,68(%sp)
	move.l %d4,-(%sp)
	move.l %d5,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
	move.l %d7,%a3
	move.b %d0,(%a6)
	mvz.b %d0,%d7
	move.l %d6,-(%sp)
	move.l 72(%sp),-(%sp)
	jsr (%a5)
	addq.l #8,%sp
	move.b %d0,1(%a6)
	mvz.b %d0,%d4
	move.l 80(%sp),-(%sp)
	mvz.b 2(%a6),%d0
	move.l %d0,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
	move.b %d0,2(%a6)
	move.b %d0,%d6
	move.l 88(%sp),-(%sp)
	move.l %a3,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
	move.l %d7,80(%sp)
	moveq #127,%d1
	move.b %d0,3(%a6)
	move.l %d4,%a6
	mvz.b %d0,%d4
	move.l %d6,%d0
	lsr.l #1,%d0
	moveq #9,%d6
	and.l %d0,%d1
	move.l 120(%sp),%d0
	asr.l %d6,%d0
	move.l %d1,44(%a2)
	move.l 76(%sp),%d1
	add.l #-64,%d1
	move.l 84(%sp),%d7
	lsl.l #6,%d1
	muls.l %d7,%d2
	moveq #11,%d7
	asr.l #8,%d2
	move.l %d1,%a0
	add.l %d0,%a0
	pea (%a0,%d2.l)
	jsr note_increment
	addq.l #4,%sp
	lea fm4_ratio_q2,%a1
	move.l 100(%sp),%a0
	move.l %d0,%d6
	lsr.l #2,%d6
	move.l 96(%sp),%d2
	mvz.b (%a1,%a0.l),%d0
	mvz.b (%a1,%d2.l),%d1
	muls.l %d6,%d0
	muls.l %d6,%d1
	move.l %d0,%d2
	lsr.l %d7,%d2
	move.l 52(%sp),%d7
	muls.l %d7,%d2
	moveq #11,%d7
	add.l %d0,%d2
	move.l %d1,%d0
	lsr.l %d7,%d0
	move.l 52(%sp),%d7
	muls.l %d7,%d0
	sub.l %d0,%d1
	mov3q.l #1,%d0
	and.l #P_FM4_HALF,%d0
	tst.l %d0
	jeq .L126
	move.w #16,%a4
	move.l %d0,%a5
	mov3q.l #4,%a1
.L120:
	move.l 92(%sp),%d7
	sub.l %a3,%d4
	move.l %a4,52(%a2)
	lsl.l %d0,%d2
	lea fm4_rtc_q2,%a4
	lsl.l #8,%d4
	mvz.b (%a4,%d7.l),%d7
	lea fm4_gain,%a0
	move.l %a5,56(%a2)
	muls.l %d6,%d7
	moveq #12,%d6
	move.l %d2,4(%a2)
	move.l %d1,%d2
	lsl.l %d0,%d2
	lsl.l %d0,%d7
	move.l %d2,8(%a2)
	move.l %d1,%d2
	lsr.l %d6,%d2
	moveq #15,%d6
	move.l %d7,(%a2)
	move.l 52(%sp),%d7
	muls.l %d7,%d2
	move.l 68(%sp),%d7
	add.l %d1,%d2
	move.l 72(%sp),%d1
	lsl.l %d0,%d2
	move.l 56(%sp),%d0
	muls.l %d1,%d5
	move.l 80(%sp),%d1
	muls.l %d7,%d0
	moveq #15,%d7
	muls.l %d1,%d3
	move.l 60(%sp),%d1
	move.l %d2,12(%a2)
	move.l 48(%sp),%d2
	muls.l %d2,%d5
	muls.l %d2,%d3
	muls.l %d2,%d0
	move.l %a1,%d2
	asr.l %d2,%d4
	asr.l %d6,%d5
	asr.l %d6,%d3
	asr.l %d6,%d0
	move.l 48(%sp),%d6
	move.l %d5,16(%a2)
	sub.l %d5,%d3
	asr.l %d2,%d3
	move.l %d0,20(%a2)
	move.l %d4,36(%a2)
	move.l %d3,24(%a2)
	move.l %a6,%d3
	muls.l %d3,%d1
	muls.l %d6,%d1
	asr.l %d7,%d1
	sub.l %d0,%d1
	move.l %a3,%d0
	asr.l %d2,%d1
	lsl.l #8,%d0
	move.l %d1,28(%a2)
	move.l 64(%sp),%d1
	move.l %d0,32(%a2)
	move.l 64(%sp),%d0
	mvs.w (%a0,%d0.l*2),%d0
	lea fm4_route,%a0
	mvs.w (%a0,%d1.l*2),%d1
	move.l %d0,40(%a2)
	move.l %d1,48(%a2)
	movem.l (%sp),#31996
	lea (104,%sp),%sp
	rts
.L107:
	move.l %d0,%d7
	moveq #14,%d3
	lsl.l %d3,%d7
	clr.w %d0
	swap %d0
	move.l #2147483647,%d5
	and.l #1073725440,%d7
	sub.l %d7,%d5
	moveq #15,%d7
	and.l %d7,%d0
	lsr.l %d0,%d5
	cmp.l #268435455,%d5
	jhi .L123
	lsl.l #4,%d5
.L108:
	move.l 12(%a6),%d0
	move.l %d0,%a1
	add.l %d5,%a1
	cmp.l %d0,%a1
	jcc .L109
	mov3q.l #-1,12(%a6)
.L110:
	moveq #-128,%d0
	move.b %d0,9(%a6)
	jra .L105
.L123:
	mov3q.l #-1,%d5
	jra .L108
.L109:
	move.l %a1,12(%a6)
	cmp.l #1342177279,%a1
	jhi .L110
	jra .L105
.L111:
	moveq #15,%d2
	lsl.l %d2,%d1
	mvz.w 56(%sp),%d3
	mvz.w %a0,%d0
	lsr.l #8,%d0
	lsr.l #8,%d3
	and.l #2139095040,%d1
	move.l %d1,%a5
	cmp.l #1073741824,%d1
	jle .L114
	move.l #1073741824,%a5
.L114:
	lsr.l #8,%d7
	mvz.w %d0,%d1
	moveq #126,%d2
	lsl.l #7,%d7
	cmp.l %d0,%d2
	jcs .L124
	move.l %d1,-(%sp)
	move.l %a4,%d0
	sub.l %a5,%d0
	move.l %d0,-(%sp)
	move.l %d1,52(%sp)
	jsr decay
	addq.l #8,%sp
	move.l %a5,%d2
	move.l 44(%sp),%d1
	add.l %d0,%d2
.L115:
	tst.w %d3
	jeq .L116
	mvz.w %d3,%d1
.L117:
	moveq #126,%d0
	cmp.l %d1,%d0
	jcs .L125
	move.l %d1,-(%sp)
	move.l %d7,%d1
	sub.l %a5,%d1
	move.l %d1,-(%sp)
	jsr decay
	addq.l #8,%sp
	add.l %a5,%d0
.L119:
	moveq #15,%d1
	asr.l %d1,%d7
	move.l %d2,%d3
	asr.l %d1,%d3
	move.l %d7,56(%sp)
	move.l %d0,%d7
	asr.l %d1,%d7
	mov3q.l #1,%d1
	or.l %d2,%d1
	move.l %d7,60(%sp)
	jra .L113
.L124:
	move.l %a4,%d2
	jra .L115
.L116:
	moveq #12,%d3
	cmp.l %d1,%d3
	jle .L118
	moveq #12,%d1
.L118:
	add.l #-12,%d1
	jra .L117
.L125:
	move.l %d7,%d0
	jra .L119
.L126:
	move.w #32,%a4
	sub.l %a5,%a5
	mov3q.l #5,%a1
	jra .L120
	.size	fm4_prep, .-fm4_prep
	.section	.fm4,"ax",@progbits
	.align	2
	.globl	fm4_render
	.type	fm4_render, @function
fm4_render:
	link.w %fp,#-232
	move.l 8(%fp),%d1
	move.l 8(%fp),%d0
	movem.l #15612,(%sp)
	mov3q.l #-1,%d3
	lsl.l #5,%d1
	lsl.l #7,%d0
	move.l 12(%fp),%d2
	move.l %d1,-132(%fp)
	move.l %d1,%a0
	mov3q.l #7,%d1
	and.l 8(%fp),%d1
	move.l %d0,%a2
	add.l #-2147456008,%a2
	move.l %a2,-(%sp)
	add.l #-2147418376,%a0
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	move.l %a0,-188(%fp)
	move.l 8(%fp),-(%sp)
	move.l %d1,-184(%fp)
	jsr begin
	lea (16,%sp),%sp
	cmp.l %d0,%d3
	jne .L131
	move.l -184(%fp),%d0
	lsl.l #5,%d0
	move.l %d0,%a0
	add.l #fm4_ext+4,%a0
	clr.w (%a0)
.L130:
	movem.l -232(%fp),#15612
	unlk %fp
	rts
.L131:
	pea -60(%fp)
	move.l %d0,-(%sp)
	move.l -184(%fp),%d0
	mov3q.l #1,%d3
	mov3q.l #1,%d4
	mov3q.l #1,%d5
	mov3q.l #1,%d6
	lsl.l #5,%d0
	add.l #fm4_ext,%d0
	move.l %d0,-(%sp)
	move.l -188(%fp),-(%sp)
	move.l 20(%fp),-(%sp)
	move.l 16(%fp),-(%sp)
	move.l %d2,-(%sp)
	move.l 8(%fp),-(%sp)
	jsr fm4_prep
	move.l -188(%fp),%a3
	move.l -12(%fp),%d1
	move.l %d1,%d7
	lsr.l #4,%d7
	move.l 12(%a3),%a3
	and.l %d1,%d3
	move.l -188(%fp),%a0
	move.l %a3,-168(%fp)
	move.l -188(%fp),%a1
	move.l 4(%a0),%a0
	move.l -188(%fp),%a5
	lea (32,%sp),%sp
	move.l %a0,-128(%fp)
	move.l -188(%fp),%a0
	move.l 16(%a5),%a5
	move.l %d3,%a3
	move.l %d1,%d3
	lsr.l #1,%d3
	move.l 24(%a0),%d0
	move.l 8(%a1),%a1
	move.l %a5,-172(%fp)
	and.l %d3,%d4
	move.l %d1,%d3
	lsr.l #2,%d3
	mvs.w %d0,%d2
	move.l %a1,-176(%fp)
	move.l -4(%fp),%a4
	and.l %d3,%d5
	move.l %d2,-180(%fp)
	mov3q.l #1,%d3
	move.l -40(%fp),%d2
	move.l -44(%fp),-152(%fp)
	lea sine_table,%a1
	move.l -28(%fp),-148(%fp)
	move.l -16(%fp),-104(%fp)
	move.l -20(%fp),-100(%fp)
	move.l -60(%fp),-124(%fp)
	move.l -56(%fp),-120(%fp)
	move.l -52(%fp),-116(%fp)
	move.l -48(%fp),-112(%fp)
	move.l %d5,-136(%fp)
	move.l %d1,%d5
	lsr.l #3,%d5
	move.l %d4,-140(%fp)
	move.l %d1,%d4
	lsr.l #6,%d4
	move.l %a5,-156(%fp)
	and.l %d5,%d6
	move.l %d1,%d5
	lsr.l #7,%d5
	and.l %d3,%d7
	move.l %a2,-108(%fp)
	and.l %d3,%d4
	and.l %d3,%d5
	swap %d0
	ext.l %d0
	clr.l -164(%fp)
	move.l -8(%fp),%a0
	move.l -176(%fp),%a5
	move.l %d6,-76(%fp)
	move.l %d1,%d6
	lsr.l #5,%d6
	lsr.l #8,%d1
	neg.l %d7
	move.l %d7,-84(%fp)
	and.l %d3,%d6
	and.l %d3,%d1
	move.l %d5,-68(%fp)
	move.l %a3,%d5
	neg.l %d5
	move.l %d5,-144(%fp)
	move.l -140(%fp),%d3
	neg.l %d4
	neg.l %d3
	move.l -136(%fp),%d5
	neg.l %d5
	move.l %d3,-140(%fp)
	move.l -68(%fp),%d7
	neg.l %d7
	neg.l %d6
	move.l %d6,-80(%fp)
	move.l %d5,-136(%fp)
	move.l -76(%fp),%d6
	neg.l %d6
	move.l -36(%fp),-96(%fp)
	move.l %d6,-76(%fp)
	move.l %d4,-72(%fp)
	move.l -32(%fp),-92(%fp)
	neg.l %d1
	move.l -24(%fp),-88(%fp)
	move.l -168(%fp),-160(%fp)
	move.l -128(%fp),-192(%fp)
	move.l %d7,-68(%fp)
	move.l %d1,-64(%fp)
.L133:
	cmp.l -164(%fp),%a0
	jgt .L136
	move.l %a0,%d1
	tst.l %a0
	jge .L137
	clr.l %d1
.L137:
	move.l -112(%fp),%d2
	muls.l %d1,%d2
	add.l -172(%fp),%d2
	move.l %d2,-172(%fp)
	move.l -116(%fp),%d2
	muls.l %d1,%d2
	add.l -168(%fp),%d2
	move.l %d2,-168(%fp)
	move.l -120(%fp),%d2
	muls.l %d1,%d2
	add.l -176(%fp),%d2
	move.l %d2,-176(%fp)
	move.l -124(%fp),%d2
	muls.l %d2,%d1
	add.l -128(%fp),%d1
	move.l %d1,-164(%fp)
	move.l -184(%fp),%d1
	lsl.l #5,%d1
	move.l %d1,%a1
	add.l #fm4_ext,%a1
	move.b 8(%a1),%d1
	move.b 9(%a1),%d3
	move.l %d1,%d2
	or.l %d3,%d2
	tst.b %d2
	jeq .L153
	mvz.b %d1,%d1
	mvz.b %d3,%d3
	mvs.w 6(%a1),%d7
	tst.l %a4
	jeq .L154
	mov3q.l #4,%d4
	mov3q.l #2,%d6
.L139:
	move.l %a2,%a3
	sub.l %a1,%a1
.L140:
	cmp.l %a1,%a0
	jgt .L144
.L138:
	tst.l %a4
	jeq .L145
	move.l -184(%fp),%d2
	move.l #-536864004,%a3
	add.l %a0,%a3
	add.l -132(%fp),%a3
	lsl.l #5,%d2
	move.l %a0,%d4
	subq.l #1,%d4
	move.l %d2,%a1
	add.l #fm4_ext+4,%a1
	move.l 8(%fp),%d2
	mvs.w (%a1),%d7
	lsl.l #4,%d2
	add.l %a0,%d2
	lsl.l #3,%d2
	move.l %d2,%a1
	move.l %a3,%d2
	lsl.l #2,%d2
	add.l #-2147456012,%a1
	move.l %d2,%a3
.L146:
	tst.l %d4
	jge .L148
	move.l %a0,%d7
	lsl.l #3,%d7
	mvs.w -4(%a2,%d7.l),%d4
.L149:
	move.l -188(%fp),%a0
	mov3q.l #-1,%d2
	cmp.l (%a0),%d2
	jne .L152
	clr.l %d4
.L152:
	move.l -184(%fp),%d2
	swap %d0
	clr.w %d0
	move.l -188(%fp),%a0
	lsl.l #5,%d2
	move.l %d2,%a4
	add.l #fm4_ext,%a4
	move.b %d1,8(%a4)
	move.l -180(%fp),%d1
	move.w %d4,4(%a4)
	move.b %d3,9(%a4)
	mvz.w %d1,%d1
	move.l -164(%fp),4(%a0)
	move.l -176(%fp),8(%a0)
	or.l %d0,%d1
	move.l -168(%fp),12(%a0)
	move.l -172(%fp),16(%a0)
	move.l %d1,24(%a0)
	jra .L130
.L136:
	add.l -180(%fp),%d0
	move.l -104(%fp),%d5
	moveq #9,%d7
	move.l -112(%fp),%d4
	moveq #24,%d6
	move.l -116(%fp),%d3
	muls.l %d5,%d0
	add.l %d4,-156(%fp)
	add.l %d3,-160(%fp)
	move.l -124(%fp),%d1
	move.l %d2,%d5
	add.l -120(%fp),%a5
	lsl.l #8,%d0
	add.l %d1,-192(%fp)
	add.l -156(%fp),%d0
	move.l %d0,%d3
	lsr.l %d7,%d0
	lsr.l %d6,%d3
	and.l #32767,%d0
	mvs.w (%a1,%d3.l*2),%d1
	mvs.w 2(%a1,%d3.l*2),%d4
	move.l -160(%fp),%d3
	sub.l %d1,%d4
	muls.l %d0,%d4
	moveq #15,%d0
	asr.l %d0,%d4
	move.l -144(%fp),%d0
	add.l %d1,%d4
	muls.l %d4,%d5
	and.l %d5,%d0
	lsl.l #3,%d0
	add.l %d0,%d3
	move.l %d3,%d0
	lsr.l %d7,%d3
	lsr.l %d6,%d0
	moveq #24,%d7
	and.l #32767,%d3
	mvs.w (%a1,%d0.l*2),%d1
	mvs.w 2(%a1,%d0.l*2),%d0
	sub.l %d1,%d0
	muls.l %d3,%d0
	moveq #15,%d3
	asr.l %d3,%d0
	move.l -136(%fp),%d3
	add.l %d0,%d1
	muls.l %d2,%d1
	move.l -140(%fp),%d0
	and.l %d5,%d3
	and.l %d1,%d0
	add.l %d3,%d0
	lsl.l #3,%d0
	move.l %d0,%d6
	add.l %a5,%d6
	move.l %d6,%d0
	lsr.l %d7,%d0
	moveq #9,%d7
	lsr.l %d7,%d6
	move.l -152(%fp),%d7
	mvs.w (%a1,%d0.l*2),%d3
	and.l #32767,%d6
	mvs.w 2(%a1,%d0.l*2),%d0
	sub.l %d3,%d0
	muls.l %d6,%d0
	moveq #15,%d6
	asr.l %d6,%d0
	move.l -84(%fp),%d6
	add.l %d0,%d3
	move.l -80(%fp),%d0
	and.l %d1,%d6
	muls.l %d7,%d3
	and.l %d5,%d0
	moveq #24,%d7
	and.l -68(%fp),%d1
	add.l %d6,%d0
	move.l -76(%fp),%d6
	and.l %d3,%d6
	and.l -72(%fp),%d3
	add.l %d6,%d0
	lsl.l #3,%d0
	move.l -192(%fp),%d6
	add.l %d0,%d6
	move.l %d6,%d0
	lsr.l %d7,%d0
	mvs.w (%a1,%d0.l*2),%d7
	mvs.w 2(%a1,%d0.l*2),%d0
	and.l -64(%fp),%d5
	move.l %d0,%a3
	moveq #9,%d0
	lsr.l %d0,%d6
	sub.l %d7,%a3
	move.l %a3,%d0
	and.l #32767,%d6
	muls.l %d6,%d0
	moveq #15,%d6
	asr.l %d6,%d3
	asr.l %d6,%d1
	asr.l %d6,%d5
	asr.l %d6,%d0
	add.l %d7,%d0
	move.l -100(%fp),%d7
	add.l %d3,%d0
	add.l %d1,%d0
	add.l %d5,%d0
	muls.l %d7,%d0
	asr.l %d6,%d0
	cmp.l #-32767,%d0
	jge .L134
	mvs.w #-32767,%d0
.L135:
	move.l -148(%fp),%d1
	asr.l #8,%d1
	move.l -108(%fp),%a3
	add.l -92(%fp),%d2
	addq.l #4,-108(%fp)
	muls.l %d1,%d0
	move.l -88(%fp),%d1
	addq.l #1,-164(%fp)
	add.l %d1,-148(%fp)
	asr.l #8,%d0
	move.l %d0,(%a3)+
	move.l -96(%fp),%d0
	add.l %d0,-152(%fp)
	move.l -180(%fp),%d0
	move.l %d4,-180(%fp)
	jra .L133
.L134:
	cmp.l #32767,%d0
	jle .L135
	mvz.w #32767,%d0
	jra .L135
.L154:
	mov3q.l #2,%d4
	mov3q.l #1,%d6
	jra .L139
.L144:
	move.l (%a3),%d2
	tst.l %d1
	jeq .L141
	move.w #64,%a5
	sub.l %d1,%a5
	move.l %a5,%d5
	muls.l %d5,%d2
	move.l %d1,%d5
	muls.l %d7,%d5
	add.l %d5,%d2
	asr.l #6,%d2
	cmp.l %d1,%d4
	jge .L155
	sub.l %d4,%d1
.L141:
	tst.l %d3
	jeq .L142
	muls.l %d3,%d2
	sub.l %d6,%d3
	asr.l #7,%d2
	tst.l %d3
	jgt .L143
	move.l -188(%fp),%a5
	clr.l %d3
	mov3q.l #-1,(%a5)
.L143:
	move.l %d2,(%a3)+
	addq.l #1,%a1
	jra .L140
.L155:
	clr.l %d1
	jra .L141
.L142:
	move.l -188(%fp),%a5
	mov3q.l #-1,%d5
	cmp.l (%a5),%d5
	jne .L143
	clr.l %d2
	jra .L143
.L153:
	clr.l %d3
	clr.l %d1
	jra .L138
.L148:
	move.l 4(%a3),%d6
	tst.l %d4
	jeq .L157
	move.l (%a3),%d2
.L147:
	add.l %d6,%d2
	move.l %d6,%d5
	moveq #15,%d6
	swap %d5
	clr.w %d5
	lsl.l %d6,%d2
	subq.l #1,%d4
	subq.l #8,%a1
	subq.l #4,%a3
	move.l %d5,8(%a1)
	move.l %d2,4(%a1)
	jra .L146
.L157:
	move.l %d7,%d2
	jra .L147
.L145:
	move.l -4(%a2,%a0.l*4),%d4
.L150:
	cmp.l %a4,%a0
	jle .L149
	move.l (%a2),%d2
	addq.l #1,%a4
	swap %d2
	clr.w %d2
	move.l %d2,(%a2)+
	jra .L150
	.size	fm4_render, .-fm4_render
	.globl	fm4_ext
	.section	.fm4s,"aw"
	.align	2
	.type	fm4_ext, @object
	.size	fm4_ext, 256
fm4_ext:
	.zero	256
	.globl	fm4_p2_title
	.section	.fm4d,"a"
	.type	fm4_p2_title, @object
	.size	fm4_p2_title, 11
fm4_p2_title:
	.string	"FM4 PAGE 2"
	.align	2
	.type	fm4_p2_records, @object
	.size	fm4_p2_records, 32
fm4_p2_records:
	.long	449
	.long	450
	.long	452
	.long	451
	.long	453
	.long	454
	.long	455
	.long	456
	.globl	fm4_s_lev
	.type	fm4_s_lev, @object
	.size	fm4_s_lev, 4
fm4_s_lev:
	.string	"LEV"
	.globl	fm4_n_lev
	.type	fm4_n_lev, @object
	.size	fm4_n_lev, 6
fm4_n_lev:
	.string	"Level"
	.globl	fm4_s_rtc
	.type	fm4_s_rtc, @object
	.size	fm4_s_rtc, 4
fm4_s_rtc:
	.string	"RTC"
	.globl	fm4_n_rtc
	.type	fm4_n_rtc, @object
	.size	fm4_n_rtc, 8
fm4_n_rtc:
	.string	"Ratio C"
	.globl	fm4_s_vel
	.type	fm4_s_vel, @object
	.size	fm4_s_vel, 4
fm4_s_vel:
	.string	"VEL"
	.globl	fm4_n_vel
	.type	fm4_n_vel, @object
	.size	fm4_n_vel, 13
fm4_n_vel:
	.string	"Velocity Mod"
	.globl	fm4_s_dcb
	.type	fm4_s_dcb, @object
	.size	fm4_s_dcb, 4
fm4_s_dcb:
	.string	"DCB"
	.globl	fm4_n_dcb
	.type	fm4_n_dcb, @object
	.size	fm4_n_dcb, 8
fm4_n_dcb:
	.string	"Decay B"
	.globl	fm4_s_end
	.type	fm4_s_end, @object
	.size	fm4_s_end, 4
fm4_s_end:
	.string	"END"
	.globl	fm4_n_end
	.type	fm4_n_end, @object
	.size	fm4_n_end, 14
fm4_n_end:
	.string	"Env End Level"
	.globl	fm4_s_atk
	.type	fm4_s_atk, @object
	.size	fm4_s_atk, 4
fm4_s_atk:
	.string	"ATK"
	.globl	fm4_n_atk
	.type	fm4_n_atk, @object
	.size	fm4_n_atk, 7
fm4_n_atk:
	.string	"Attack"
	.globl	fm4_s_psw
	.type	fm4_s_psw, @object
	.size	fm4_s_psw, 4
fm4_s_psw:
	.string	"PSW"
	.globl	fm4_n_psw
	.type	fm4_n_psw, @object
	.size	fm4_n_psw, 12
fm4_n_psw:
	.string	"Pitch Sweep"
	.globl	fm4_s_dtn
	.type	fm4_s_dtn, @object
	.size	fm4_s_dtn, 4
fm4_s_dtn:
	.string	"DTN"
	.globl	fm4_n_dtn
	.type	fm4_n_dtn, @object
	.size	fm4_n_dtn, 7
fm4_n_dtn:
	.string	"Detune"
	.globl	fm4_s_fb
	.type	fm4_s_fb, @object
	.size	fm4_s_fb, 3
fm4_s_fb:
	.string	"FB"
	.globl	fm4_n_fb
	.type	fm4_n_fb, @object
	.size	fm4_n_fb, 9
fm4_n_fb:
	.string	"Feedback"
	.globl	fm4_s_alg
	.type	fm4_s_alg, @object
	.size	fm4_s_alg, 4
fm4_s_alg:
	.string	"ALG"
	.globl	fm4_n_alg
	.type	fm4_n_alg, @object
	.size	fm4_n_alg, 10
fm4_n_alg:
	.string	"Algorithm"
	.globl	fm4_s_rtb
	.type	fm4_s_rtb, @object
	.size	fm4_s_rtb, 4
fm4_s_rtb:
	.string	"RTB"
	.globl	fm4_n_rtb
	.type	fm4_n_rtb, @object
	.size	fm4_n_rtb, 8
fm4_n_rtb:
	.string	"Ratio B"
	.globl	fm4_s_rta
	.type	fm4_s_rta, @object
	.size	fm4_s_rta, 4
fm4_s_rta:
	.string	"RTA"
	.globl	fm4_n_rta
	.type	fm4_n_rta, @object
	.size	fm4_n_rta, 8
fm4_n_rta:
	.string	"Ratio A"
	.globl	fm4_s_ixb
	.type	fm4_s_ixb, @object
	.size	fm4_s_ixb, 4
fm4_s_ixb:
	.string	"IXB"
	.globl	fm4_n_ixb
	.type	fm4_n_ixb, @object
	.size	fm4_n_ixb, 8
fm4_n_ixb:
	.string	"Index B"
	.globl	fm4_n_dec
	.type	fm4_n_dec, @object
	.size	fm4_n_dec, 8
fm4_n_dec:
	.string	"Decay A"
	.globl	fm4_s_ixa
	.type	fm4_s_ixa, @object
	.size	fm4_s_ixa, 4
fm4_s_ixa:
	.string	"IXA"
	.globl	fm4_n_ixa
	.type	fm4_n_ixa, @object
	.size	fm4_n_ixa, 8
fm4_n_ixa:
	.string	"Index A"
	.globl	fm4_short
	.type	fm4_short, @object
	.size	fm4_short, 4
fm4_short:
	.string	"FM4"
	.globl	fm4_long
	.type	fm4_long, @object
	.size	fm4_long, 9
fm4_long:
	.string	"FM4 4-OP"
	.align	2
	.type	fm4_gain, @object
	.size	fm4_gain, 16
fm4_gain:
	.word	32767
	.word	32767
	.word	32767
	.word	32767
	.word	23170
	.word	18919
	.word	18919
	.word	16384
	.align	2
	.type	fm4_route, @object
	.size	fm4_route, 16
fm4_route:
	.word	11
	.word	14
	.word	42
	.word	25
	.word	137
	.word	229
	.word	193
	.word	448
	.type	fm4_rtc_q2, @object
	.size	fm4_rtc_q2, 9
fm4_rtc_q2:
	.base64	"BAIIDBAUGBwg"
	.type	fm4_ratio_q2, @object
	.size	fm4_ratio_q2, 22
fm4_ratio_q2:
	.base64	"AQIDBAYICgwOEBIUGBwgJCgsMDQ4QA=="
	.text
	.type	ratio_q2, @object
	.size	ratio_q2, 16
ratio_q2:
	.base64	"AgQGCAoMDhAUGBwgJCw0QA=="
	.align	2
	.type	decay_q15, @object
	.size	decay_q15, 256
decay_q15:
	.word	27738
	.word	28008
	.word	28266
	.word	28510
	.word	28742
	.word	28963
	.word	29172
	.word	29370
	.word	29558
	.word	29736
	.word	29905
	.word	30064
	.word	30216
	.word	30359
	.word	30494
	.word	30622
	.word	30743
	.word	30858
	.word	30966
	.word	31068
	.word	31165
	.word	31256
	.word	31342
	.word	31424
	.word	31500
	.word	31573
	.word	31641
	.word	31706
	.word	31767
	.word	31824
	.word	31879
	.word	31930
	.word	31978
	.word	32023
	.word	32066
	.word	32107
	.word	32145
	.word	32181
	.word	32215
	.word	32247
	.word	32277
	.word	32305
	.word	32332
	.word	32357
	.word	32381
	.word	32404
	.word	32425
	.word	32445
	.word	32463
	.word	32481
	.word	32498
	.word	32513
	.word	32528
	.word	32542
	.word	32555
	.word	32568
	.word	32579
	.word	32590
	.word	32601
	.word	32610
	.word	32619
	.word	32628
	.word	32636
	.word	32644
	.word	32651
	.word	32658
	.word	32664
	.word	32670
	.word	32676
	.word	32681
	.word	32686
	.word	32691
	.word	32696
	.word	32700
	.word	32704
	.word	32708
	.word	32711
	.word	32714
	.word	32718
	.word	32720
	.word	32723
	.word	32726
	.word	32728
	.word	32731
	.word	32733
	.word	32735
	.word	32737
	.word	32739
	.word	32740
	.word	32742
	.word	32743
	.word	32745
	.word	32746
	.word	32747
	.word	32749
	.word	32750
	.word	32751
	.word	32752
	.word	32753
	.word	32754
	.word	32755
	.word	32755
	.word	32756
	.word	32757
	.word	32757
	.word	32758
	.word	32759
	.word	32759
	.word	32760
	.word	32760
	.word	32761
	.word	32761
	.word	32761
	.word	32762
	.word	32762
	.word	32763
	.word	32763
	.word	32763
	.word	32763
	.word	32764
	.word	32764
	.word	32764
	.word	32764
	.word	32765
	.word	32765
	.word	32765
	.word	32765
	.word	32765
	.align	2
	.type	note_inc, @object
	.size	note_inc, 52
note_inc:
	.long	374557749
	.long	396830112
	.long	420426858
	.long	445426740
	.long	471913192
	.long	499974611
	.long	529704648
	.long	561202526
	.long	594573365
	.long	629928537
	.long	667386037
	.long	707070876
	.long	749115498
	.align	2
	.type	sine_table, @object
	.size	sine_table, 514
sine_table:
	.word	0
	.word	804
	.word	1608
	.word	2410
	.word	3212
	.word	4011
	.word	4808
	.word	5602
	.word	6393
	.word	7179
	.word	7962
	.word	8739
	.word	9512
	.word	10278
	.word	11039
	.word	11793
	.word	12539
	.word	13279
	.word	14010
	.word	14732
	.word	15446
	.word	16151
	.word	16846
	.word	17530
	.word	18204
	.word	18868
	.word	19519
	.word	20159
	.word	20787
	.word	21403
	.word	22005
	.word	22594
	.word	23170
	.word	23731
	.word	24279
	.word	24811
	.word	25329
	.word	25832
	.word	26319
	.word	26790
	.word	27245
	.word	27683
	.word	28105
	.word	28510
	.word	28898
	.word	29268
	.word	29621
	.word	29956
	.word	30273
	.word	30571
	.word	30852
	.word	31113
	.word	31356
	.word	31580
	.word	31785
	.word	31971
	.word	32137
	.word	32285
	.word	32412
	.word	32521
	.word	32609
	.word	32678
	.word	32728
	.word	32757
	.word	32767
	.word	32757
	.word	32728
	.word	32678
	.word	32609
	.word	32521
	.word	32412
	.word	32285
	.word	32137
	.word	31971
	.word	31785
	.word	31580
	.word	31356
	.word	31113
	.word	30852
	.word	30571
	.word	30273
	.word	29956
	.word	29621
	.word	29268
	.word	28898
	.word	28510
	.word	28105
	.word	27683
	.word	27245
	.word	26790
	.word	26319
	.word	25832
	.word	25329
	.word	24811
	.word	24279
	.word	23731
	.word	23170
	.word	22594
	.word	22005
	.word	21403
	.word	20787
	.word	20159
	.word	19519
	.word	18868
	.word	18204
	.word	17530
	.word	16846
	.word	16151
	.word	15446
	.word	14732
	.word	14010
	.word	13279
	.word	12539
	.word	11793
	.word	11039
	.word	10278
	.word	9512
	.word	8739
	.word	7962
	.word	7179
	.word	6393
	.word	5602
	.word	4808
	.word	4011
	.word	3212
	.word	2410
	.word	1608
	.word	804
	.word	0
	.word	-804
	.word	-1608
	.word	-2410
	.word	-3212
	.word	-4011
	.word	-4808
	.word	-5602
	.word	-6393
	.word	-7179
	.word	-7962
	.word	-8739
	.word	-9512
	.word	-10278
	.word	-11039
	.word	-11793
	.word	-12539
	.word	-13279
	.word	-14010
	.word	-14732
	.word	-15446
	.word	-16151
	.word	-16846
	.word	-17530
	.word	-18204
	.word	-18868
	.word	-19519
	.word	-20159
	.word	-20787
	.word	-21403
	.word	-22005
	.word	-22594
	.word	-23170
	.word	-23731
	.word	-24279
	.word	-24811
	.word	-25329
	.word	-25832
	.word	-26319
	.word	-26790
	.word	-27245
	.word	-27683
	.word	-28105
	.word	-28510
	.word	-28898
	.word	-29268
	.word	-29621
	.word	-29956
	.word	-30273
	.word	-30571
	.word	-30852
	.word	-31113
	.word	-31356
	.word	-31580
	.word	-31785
	.word	-31971
	.word	-32137
	.word	-32285
	.word	-32412
	.word	-32521
	.word	-32609
	.word	-32678
	.word	-32728
	.word	-32757
	.word	-32767
	.word	-32757
	.word	-32728
	.word	-32678
	.word	-32609
	.word	-32521
	.word	-32412
	.word	-32285
	.word	-32137
	.word	-31971
	.word	-31785
	.word	-31580
	.word	-31356
	.word	-31113
	.word	-30852
	.word	-30571
	.word	-30273
	.word	-29956
	.word	-29621
	.word	-29268
	.word	-28898
	.word	-28510
	.word	-28105
	.word	-27683
	.word	-27245
	.word	-26790
	.word	-26319
	.word	-25832
	.word	-25329
	.word	-24811
	.word	-24279
	.word	-23731
	.word	-23170
	.word	-22594
	.word	-22005
	.word	-21403
	.word	-20787
	.word	-20159
	.word	-19519
	.word	-18868
	.word	-18204
	.word	-17530
	.word	-16846
	.word	-16151
	.word	-15446
	.word	-14732
	.word	-14010
	.word	-13279
	.word	-12539
	.word	-11793
	.word	-11039
	.word	-10278
	.word	-9512
	.word	-8739
	.word	-7962
	.word	-7179
	.word	-6393
	.word	-5602
	.word	-4808
	.word	-4011
	.word	-3212
	.word	-2410
	.word	-1608
	.word	-804
	.word	0
	.ident	"GCC: (GNU) 16.2.0"
