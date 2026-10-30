| Mod 0029 - Sidecar send FX pages: AMPLITUDE 2 (SEND FX 1/2) and the SEND FX 1/2 pages behind DELAY/REVERB.
| GENERATED from sfu.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit sfu.c.
#NO_APP
	.file	"sfu.c"
	.text
#APP
	  .text
  .globl sfu_pinfo, sfu_getv, sfu_title
  .align 2
sfu_pinfo:
  move.l 4(%sp),%d0
  moveq #-12,%d1
  add.l %d1,%d0
  moveq #2,%d1
  cmp.l %d0,%d1
  bcs.s 1f
  mulu.w #36,%d0
  add.l #sfu_pages,%d0
  rts
1:
  moveq #11,%d1
  move.l 4(%sp),%d0
  jmp 0x400ff57a
  .align 2
sfu_getv:
  move.l 8(%sp),%d0
  moveq #-14,%d1
  add.l %d1,%d0
  moveq #13,%d1
  cmp.l %d0,%d1
  bcc.w sfu_get
  move.l 8(%sp),-(%sp)
  jsr sfu_isext
  addq.l #4,%sp
  tst.l %d0
  bne.w sfu_get
  lea -12(%sp),%sp
  movem.l %d2-%d3/%a2,(%sp)
  jmp 0x4003846a
  .align 2
sfu_title:
  move.l %a2,-(%sp)
  jsr 0x40078514
  lea -24(%sp),%sp
  movem.l %d0-%d1/%a0-%a1,(%sp)
  move.l %a2,-(%sp)
  move.l (%a2),%a0
  move.l 0x4c(%a0),%a0
  jsr (%a0)
  addq.l #4,%sp
  pea 19(%sp)
  move.l %d0,-(%sp)
  pea 28(%sp)
  jsr 0x401bcd4c
  lea 12(%sp),%sp
  pea 20(%sp)
  move.l 108(%a2),-(%sp)
  jsr 0x40035fe8
  addq.l #8,%sp
  pea 20(%sp)
  jsr 0x401bb29c
  addq.l #4,%sp
  movem.l (%sp),%d0-%d1/%a0-%a1
  lea 24(%sp),%sp
  jmp 0x4003ab9c

#NO_APP
	.align	2
	.type	timed, @function
timed:
	move.l -66650100,%d0
	sub.l 4(%sp),%d0
	tst.l 8(%sp)
	jeq .L2
	add.l %d0,sfu_x+2176
	addq.l #1,sfu_x+2184
	cmp.l sfu_x+2180.l,%d0
	jls .L1
	move.l %d0,sfu_x+2180
.L1:
	rts
.L2:
	add.l %d0,sfu_x+2164
	addq.l #1,sfu_x+2172
	cmp.l sfu_x+2168.l,%d0
	jls .L1
	move.l %d0,sfu_x+2168
	jra .L1
	.size	timed, .-timed
	.align	2
	.type	merge, @function
merge:
	move.l %d2,-(%sp)
	move.l 16(%sp),%d0
	move.l 12(%sp),%d1
	cmp.l #32512,%d0
	jle .L5
	mvz.w #32512,%d0
.L6:
	move.l 8(%sp),%d2
	btst #0,%d2
	jeq .L7
	asr.l #7,%d0
	and.l #32512,%d1
	and.l #254,%d0
.L9:
	or.l %d1,%d0
	move.l (%sp)+,%d2
	rts
.L5:
	tst.l %d0
	jge .L6
	clr.l %d0
	jra .L6
.L7:
	and.l #32512,%d0
	and.l #254,%d1
	jra .L9
	.size	merge, .-merge
	.align	2
	.type	tcache, @function
tcache:
	lea (-28,%sp),%sp
	movem.l #3132,(%sp)
	move.l 32(%sp),%d1
	lea sfu_x,%a2
	move.l 36(%sp),%d2
	lea (%a2,%d1.l),%a0
	move.l sfu_x+2456,%d4
	addq.l #1,%d4
	mvz.b 2578(%a0),%d0
	cmp.l %d0,%d2
	jeq .L11
.L14:
	move.l sfu_x+2452,%d0
	mov3q.l #-1,%a1
	mov3q.l #1,%d3
	lea sfu_x+2324,%a3
	move.l %d0,24(%sp)
	clr.l %d0
.L12:
	cmp.l 24(%sp),%d0
	jne .L17
	move.b %d2,2578(%a0)
	mov3q.l #-1,%d0
	cmp.l %a1,%d0
	jne .L18
	move.w #255,%a1
.L18:
	move.w %a1,%d0
	add.l #646,%d1
	move.l %d4,(%a2,%d1.l*4)
	move.b %d3,2582(%a0)
	move.b %d0,2580(%a0)
	jra .L10
.L11:
	move.l %d1,%d0
	add.l #646,%d0
	cmp.l (%a2,%d0.l*4),%d4
	jne .L14
.L10:
	movem.l (%sp),#3132
	lea (28,%sp),%sp
	rts
.L17:
	mvz.b (%a3,%d0.l),%d5
	cmp.l %d5,%d2
	jne .L15
	move.l %d0,%a1
.L16:
	addq.l #1,%d0
	jra .L12
.L15:
	tst.l %d0
	jeq .L16
	cmp.l %d5,%d2
	jle .L16
	addq.l #1,%d3
	jra .L16
	.size	tcache, .-tcache
	.align	2
	.type	tid, @function
tid:
	move.l %d2,-(%sp)
	move.l 8(%sp),%d2
	move.l 12(%sp),-(%sp)
	move.l %d2,-(%sp)
	jsr tcache
	addq.l #8,%sp
	lea sfu_x,%a1
	lea (%a1,%d2.l),%a0
	move.b 2580(%a0),%d0
	move.l sfu_x+2452,%d2
	move.l %d0,%d1
	not.l %d1
	tst.b %d1
	seq %d1
	mvs.b %d1,%d1
	sub.l %d1,%d2
	move.l 16(%sp),%d1
	tst.l %d1
	jge .L23
	clr.l %d1
.L23:
	cmp.l %d1,%d2
	jgt .L24
	move.l %d2,%d1
	subq.l #1,%d1
.L24:
	mvz.b %d0,%d0
	cmp.l #255,%d0
	jne .L28
	mvz.b 2582(%a0),%d0
	cmp.l %d0,%d1
	jeq .L26
	jle .L28
	subq.l #1,%d1
.L28:
	add.l %d1,%a1
	mvz.b 2324(%a1),%d0
	move.l %d0,12(%sp)
.L26:
	move.l 12(%sp),%d0
	move.l (%sp)+,%d2
	rts
	.size	tid, .-tid
	.align	2
	.type	to_knob, @function
to_knob:
	lea (-20,%sp),%sp
	move.l 24(%sp),%d1
	movem.l #1084,(%sp)
	move.l 28(%sp),%d0
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jge .L33
	move.l %d0,%d3
	asr.l #8,%d3
	move.l %d1,%d2
	subq.l #2,%d2
	move.l %d2,%d4
	mov3q.l #6,%d5
	move.l %d3,%a1
	rems.l %d5,%d3:%d4
	move.l %d3,%d2
	tst.l %d3
	jne .L31
	mov3q.l #7,%d4
	cmp.l %d1,%d4
	slt %d2
	move.l %a1,-(%sp)
	mvs.b %d2,%d2
	neg.l %d2
	move.l %d2,-(%sp)
	jsr tcache
	addq.l #8,%sp
	move.l %d2,%a0
	add.l #sfu_x,%a0
	move.b 2580(%a0),%d0
	mvz.b %d0,%d1
	cmp.l #255,%d1
	jne .L32
	move.b 2582(%a0),%d0
.L32:
	mvz.b %d0,%d0
.L39:
	lsl.l #8,%d0
.L33:
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L31:
	mov3q.l #1,%d5
	cmp.l %d3,%d5
	jne .L34
	moveq #63,%d1
	cmp.l %a1,%d1
	slt %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L39
.L34:
	mov3q.l #7,%d3
	cmp.l %d1,%d3
	slt %d1
	subq.l #2,%d2
	move.l %d2,%a2
	neg.l %d1
	mvz.b %d1,%d4
	lea (%a2,%d4.l*4),%a0
	add.l #sfu_x+2460,%a0
	mvz.b (%a0),%d3
	tst.l %d3
	jeq .L33
	move.l %d3,%d0
	subq.l #1,%d0
	tst.b %d1
	jeq .L36
	moveq #48,%d1
.L37:
	mulu.w #12,%d2
	add.l %d2,%d1
	move.l %d1,%a0
	add.l #sfu_x+2468,%a0
.L38:
	tst.l %d0
	jeq .L39
	mvz.b (%a0,%d0.l),%d1
	cmp.l %d1,%a1
	jge .L39
	subq.l #1,%d0
	jra .L38
.L36:
	clr.l %d1
	jra .L37
	.size	to_knob, .-to_knob
	.align	2
	.type	to_half, @function
to_half:
	lea (-24,%sp),%sp
	move.l 28(%sp),%d1
	movem.l #3132,(%sp)
	move.l 32(%sp),%d0
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jge .L46
	move.l %d0,%d2
	asr.l #8,%d2
	move.l %d2,%a1
	tst.l %d2
	jge .L47
	sub.l %a1,%a1
.L47:
	move.l %d1,%a2
	subq.l #2,%a2
	move.l %a2,%d3
	mov3q.l #6,%d4
	rems.l %d4,%d5:%d3
	move.l %d5,%a0
	tst.l %d5
	jne .L48
	mov3q.l #7,%d0
	cmp.l %d1,%d0
	slt %d1
	move.l %a1,-(%sp)
	move.l 40(%sp),-(%sp)
	mvs.b %d1,%d1
	neg.l %d1
	move.l %d1,-(%sp)
	jsr tid
	lea (12,%sp),%sp
	lsl.l #8,%d0
.L46:
	movem.l (%sp),#3132
	lea (24,%sp),%sp
	rts
.L48:
	mov3q.l #1,%d3
	cmp.l %d5,%d3
	jne .L49
	tst.l %d2
	jle .L52
	mvz.w #32512,%d0
	jra .L46
.L49:
	mov3q.l #7,%d4
	cmp.l %d1,%d4
	slt %d1
	lea sfu_x,%a2
	subq.l #2,%a0
	mvs.b %d1,%d1
	neg.l %d1
	lea (%a2,%d1.l*4),%a3
	add.l %a0,%a3
	mvz.b 2460(%a3),%d2
	tst.l %d2
	jeq .L46
	cmp.l %a1,%d2
	jgt .L51
	move.l %d2,%a1
	subq.l #1,%a1
.L51:
	move.l %a0,%d0
	moveq #12,%d2
	moveq #48,%d3
	muls.l %d2,%d0
	muls.l %d3,%d1
	addq.l #1,sfu_x+2592
	move.l %d0,%a0
	add.l %d1,%a0
	add.l %a2,%a0
	add.l %a1,%a0
	mvz.b 2468(%a0),%d0
	lsl.l #8,%d0
	jra .L46
.L52:
	clr.l %d0
	jra .L46
	.size	to_half, .-to_half
	.align	2
	.type	xmode, @function
xmode:
	lea (-32,%sp),%sp
	moveq #126,%d0
	movem.l #7292,(%sp)
	move.l 36(%sp),%d3
	move.l %d3,%d4
	add.l #-334,%d4
	cmp.l %d4,%d0
	jcc .L57
.L59:
	clr.l %d0
.L56:
	movem.l (%sp),#7292
	lea (32,%sp),%sp
	rts
.L57:
	tst.b sfu_st+1026.l
	jeq .L59
	move.l #1481856080,%d1
	cmp.l 1073848892.l,%d1
	jne .L59
	move.l %d4,%d5
	move.l #sfu_x,%d2
	lsl.l #2,%d5
	move.l sfu_st+1034,%d0
	move.l %d2,%a0
	move.l %d4,%a2
	addq.l #1,%d0
	add.l %d2,%a2
	add.l %d5,%a0
	cmp.l 2854(%a0),%d0
	jeq .L60
	move.l 1073848896,%a0
	mov3q.l #3,%d6
	move.l %d3,-(%sp)
	jsr (%a0)
	addq.l #1,sfu_x+6410
	addq.l #4,%sp
	move.l %d0,%d1
	asr.l #8,%d1
	move.b %d0,2727(%a2)
	and.l %d6,%d1
	moveq #10,%d6
	move.b %d1,2600(%a2)
	move.l %d0,%d1
	asr.l %d6,%d1
	mov3q.l #1,%d6
	and.l %d6,%d1
	moveq #11,%d6
	move.b %d1,6430(%a2)
	move.l %d0,%d1
	asr.l %d6,%d1
	mov3q.l #1,%d6
	mvz.b %d0,%d0
	and.l %d6,%d1
	move.b %d1,6557(%a2)
	cmp.l %d0,%d6
	jcs .L61
	clr.b %d0
	move.b %d0,2600(%a2)
.L61:
	move.l sfu_st+1034,%d1
	move.l %d2,%a0
	addq.l #1,%d1
	add.l %d5,%a0
	move.l %d1,2854(%a0)
.L60:
	move.w %d3,%d0
	mulu.w #52,%d3
	move.l %d3,%a1
	add.l #1075575064,%a1
	mulu.w #84,%d0
	move.l %d0,%a0
	add.l #1100630152,%a0
	move.l 32(%a0),%d0
	tst.b 2600(%a2)
	jeq .L62
	cmp.l #sfu_xtext,%d0
	jeq .L63
	moveq #20,%d6
	muls.l %d6,%d4
	move.l %d2,%a3
	add.l %d5,%d2
	move.l #1100634276,%a4
	move.l #sfu_xtext,%d0
	add.l %d4,%a3
	move.l (%a0),3870(%a3)
	move.l 4(%a0),3874(%a3)
	move.l 8(%a0),3878(%a3)
	move.l 16(%a0),3882(%a3)
	move.l 48(%a0),3886(%a3)
	move.l %d2,%a3
	move.l 32(%a0),3362(%a3)
	move.l 1100634268,(%a0)
	move.l #1100634272,%a3
	move.l (%a3),4(%a0)
	move.l #1100634284,%a3
	move.l (%a4),8(%a0)
	lea sfu_draw,%a4
	move.l (%a3),16(%a0)
	move.l %a4,48(%a0)
	move.l %d0,32(%a0)
	addq.l #1,sfu_x+6414
.L63:
	mvz.b 2727(%a2),%d0
	subq.l #1,%d0
	lsl.l #8,%d0
	tst.b 6557(%a2)
	jeq .L66
	mvz.w #224,%d1
.L64:
	or.l %d1,%d0
.L69:
	move.l %d0,12(%a1)
.L65:
	mvz.b 2600(%a2),%d0
	jra .L56
.L66:
	clr.l %d1
	jra .L64
.L62:
	cmp.l #sfu_xtext,%d0
	jne .L65
	moveq #20,%d1
	muls.l %d1,%d4
	move.l %d2,%a3
	add.l %d5,%d2
	mvz.w #32512,%d0
	add.l %d4,%a3
	move.l 3870(%a3),(%a0)
	move.l 3874(%a3),4(%a0)
	move.l 3878(%a3),8(%a0)
	move.l 3882(%a3),16(%a0)
	move.l 3886(%a3),48(%a0)
	move.l %d2,%a3
	move.l 3362(%a3),32(%a0)
	jra .L69
	.size	xmode, .-xmode
	.align	2
	.type	x_knob, @function
x_knob:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	moveq #127,%d2
	move.l 12(%sp),%a0
	add.l #sfu_x-334,%a0
	mvz.b 2727(%a0),%d0
	move.l 16(%sp),%d1
	move.l %d0,%a1
	move.l %d1,%d0
	asr.l #8,%d0
	cmp.l %d0,%d2
	jge .L71
	moveq #127,%d0
.L72:
	mvz.b 2600(%a0),%d2
	mov3q.l #1,%d3
	cmp.l %d2,%d3
	jne .L73
	move.w %a1,%d2
	muls.w %d2,%d0
	asr.l #7,%d0
.L74:
	lsl.l #8,%d0
	tst.b 6557(%a0)
	jeq .L79
	and.l #224,%d1
.L77:
	or.l %d1,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L71:
	tst.l %d0
	jge .L72
	clr.l %d0
	jra .L72
.L73:
	subq.l #2,%d2
	tst.l %d2
	jne .L74
	cmp.l %d0,%a1
	jgt .L74
	tst.b 6430(%a0)
	jne .L78
	move.l %a1,%d0
	subq.l #1,%d0
	jra .L74
.L78:
	clr.l %d0
	jra .L74
.L79:
	clr.l %d1
	jra .L77
	.size	x_knob, .-x_knob
	.align	2
	.type	x_half, @function
x_half:
	lea (-16,%sp),%sp
	movem.l #3084,(%sp)
	move.l 20(%sp),%a2
	add.l #sfu_x-334,%a2
	move.l 24(%sp),%a0
	mvz.b 2727(%a2),%d0
	move.l %d0,%a1
	move.l %a0,%d0
	asr.l #8,%d0
	tst.l %a0
	jge .L81
	clr.l %d0
.L81:
	mvz.b 2600(%a2),%d1
	cmp.l %a1,%d0
	jlt .L82
	tst.b 6430(%a2)
	jeq .L83
	mov3q.l #2,%d2
	cmp.l %d1,%d2
	jeq .L86
.L83:
	move.l %a1,%d0
	subq.l #1,%d0
.L82:
	subq.l #1,%d1
	tst.l %d1
	jne .L84
	lsl.l #7,%d0
	move.l %a1,%d2
	lea -1(%a1,%d0.l),%a3
	move.l %a3,%d0
	divs.l %d2,%d0
.L84:
	lsl.l #8,%d0
	addq.l #1,sfu_x+2592
	tst.b 6557(%a2)
	jeq .L87
	move.l %a0,%d1
	and.l #224,%d1
.L85:
	or.l %d1,%d0
	movem.l (%sp),#3084
	lea (16,%sp),%sp
	rts
.L86:
	clr.l %d0
	jra .L84
.L87:
	clr.l %d1
	jra .L85
	.size	x_half, .-x_half
	.align	2
	.type	xname, @function
xname:
	lea (-16,%sp),%sp
	movem.l #60,(%sp)
	move.l 20(%sp),%d3
	moveq #84,%d5
	move.l %d3,%d1
	add.l #-1100630172,%d1
	divu.l %d5,%d1
	move.l 24(%sp),%d0
	move.l 28(%sp),%d4
	moveq #126,%d2
	move.l %d1,%a0
	lea (-334,%a0),%a0
	cmp.l %a0,%d2
	jcs .L89
	move.l %a0,%d5
	lsl.l #2,%d5
	lea sfu_x,%a1
	add.l %d5,%a1
	tst.l 3362(%a1)
	jeq .L89
	add.l #sfu_x,%a0
	tst.b 2600(%a0)
	jeq .L92
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	jsr x_half
	subq.l #1,sfu_x+2592
	addq.l #8,%sp
.L92:
	lea sfu_x,%a0
	add.l %d5,%a0
	move.l %d4,28(%sp)
	move.l %d3,20(%sp)
	movem.l (%sp),#60
	move.l %d0,24(%sp)
	move.l 3362(%a0),%a1
	lea (16,%sp),%sp
	jmp (%a1)
.L89:
	asr.l #8,%d0
	move.l %d0,-(%sp)
	pea s_empty
	pea fmt_d
	move.l %d4,-(%sp)
	jsr 1074365954
	movem.l 16(%sp),#60
	lea (32,%sp),%sp
	rts
	.size	xname, .-xname
	.align	2
	.globl	sfu_xtext
	.type	sfu_xtext, @function
sfu_xtext:
	lea (-16,%sp),%sp
	movem.l #1052,(%sp)
	move.l 20(%sp),%d2
	moveq #84,%d4
	move.l %d2,%d0
	add.l #-1100630172,%d0
	divu.l %d4,%d0
	move.l 24(%sp),%a1
	move.l 28(%sp),%d3
	move.l %d0,%a0
	moveq #126,%d0
	lea (-334,%a0),%a0
	cmp.l %a0,%d0
	jcs .L95
	lea sfu_x,%a2
	lea (%a2,%a0.l*4),%a2
	tst.l 3362(%a2)
	jeq .L95
	add.l #sfu_x,%a0
	move.b 2600(%a0),%d1
	move.l %d1,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	lsr.l #1,%d0
	jne .L95
	move.l %a1,%d0
	asr.l #8,%d0
	tst.l %a1
	jge .L96
	clr.l %d0
.L96:
	mvz.b 2727(%a0),%d2
	cmp.l %d2,%d0
	jlt .L97
	tst.b 6430(%a0)
	jeq .L98
	mvz.b %d1,%d1
	subq.l #2,%d1
	tst.l %d1
	jeq .L100
.L98:
	move.l %d2,%d0
	subq.l #1,%d0
.L97:
	move.l %d0,%a0
	pea 1(%a0)
	pea s_empty
	pea fmt_d
	move.l %d3,-(%sp)
	jsr 1074365954
	movem.l 16(%sp),#1052
	lea (32,%sp),%sp
	rts
.L100:
	clr.l %d0
	jra .L97
.L95:
	move.l %d3,28(%sp)
	move.l %d2,20(%sp)
	movem.l (%sp),#1052
	move.l %a1,24(%sp)
	lea (16,%sp),%sp
	jra xname
	.size	sfu_xtext, .-sfu_xtext
	.align	2
	.type	see_fxset, @function
see_fxset:
	move.l 4(%sp),%d0
	move.l sfu_x+2132,%d1
	cmp.l %d1,%d0
	jeq .L102
	tst.l %d1
	jeq .L104
	addq.l #1,sfu_x+2140
.L104:
	move.l %d0,sfu_x+2132
.L102:
	rts
	.size	see_fxset, .-see_fxset
	.align	2
	.type	type_text, @function
type_text:
	lea (-12,%sp),%sp
	movem.l #1036,(%sp)
	move.l 20(%sp),%d0
	asr.l #8,%d0
	move.l 16(%sp),%d2
	move.l %d2,%a0
	move.l 24(%sp),%d3
	add.l #sfu_x,%a0
	move.l %d0,-(%sp)
	mvz.b 2088(%a0),%d0
	move.l %d0,-(%sp)
	move.l %d2,-(%sp)
	jsr tid
	lea (12,%sp),%sp
	moveq #127,%d1
	move.l %d0,%a1
	cmp.l %d0,%d1
	jge .L109
	move.w #127,%a1
.L109:
	mvz.w %a1,%d1
	lsl.l #3,%d1
	move.l %d1,%a0
	add.l #sfu_st,%a0
	tst.b (%a0)
	jne .L110
	moveq #63,%d1
	cmp.l %d0,%d1
	jge .L114
	lea (-63,%a1),%a1
	move.l #s_ufx,%d0
.L111:
	move.l %a1,-(%sp)
	move.l %d0,-(%sp)
	pea fmt_d
	move.l %d3,-(%sp)
	jsr 1074365954
	movem.l 16(%sp),#1036
	lea (28,%sp),%sp
	rts
.L114:
	move.l #s_fx,%d0
	jra .L111
.L110:
	add.l #sfu_st,%d2
	move.l %d2,%a2
	mvz.b 1024(%a2),%d0
	cmp.l %d0,%a1
	jne .L115
	move.l #fmt_bang,%d0
.L113:
	move.l %d3,16(%sp)
	movem.l (%sp),#1036
	move.l %a0,24(%sp)
	move.l %d0,20(%sp)
	lea (12,%sp),%sp
	jmp 1074365954
.L115:
	move.l #fmt_s,%d0
	jra .L113
	.size	type_text, .-type_text
	.align	2
	.globl	sfu_type1_text
	.type	sfu_type1_text, @function
sfu_type1_text:
	clr.l 4(%sp)
	jra type_text
	.size	sfu_type1_text, .-sfu_type1_text
	.align	2
	.globl	sfu_type2_text
	.type	sfu_type2_text, @function
sfu_type2_text:
	mov3q.l #1,4(%sp)
	jra type_text
	.size	sfu_type2_text, .-sfu_type2_text
	.align	2
	.globl	sfu_route_text
	.type	sfu_route_text, @function
sfu_route_text:
	move.l 8(%sp),%d0
	asr.l #8,%d0
	move.l 12(%sp),%d1
	tst.l %d0
	jeq .L121
	move.l #s_post,%d0
.L120:
	move.l %d0,12(%sp)
	move.l #fmt_s,%d0
	move.l %d0,8(%sp)
	move.l %d1,4(%sp)
	jmp 1074365954
.L121:
	move.l #s_pre,%d0
	jra .L120
	.size	sfu_route_text, .-sfu_route_text
	.align	2
	.type	ptext, @function
ptext:
	lea (-32,%sp),%sp
	movem.l #1276,(%sp)
	move.l 36(%sp),%d1
	move.l %d1,%a0
	add.l #sfu_x,%a0
	move.l 40(%sp),%d4
	move.l 48(%sp),%d3
	move.l 52(%sp),%d2
	move.l 44(%sp),28(%sp)
	mvz.b 2090(%a0),%d0
	lea sfu_x,%a0
	move.l %a0,%a2
	move.l %d0,%a1
	clr.l %d0
	addq.l #1,%a1
.L125:
	mvz.b (%a0),%d5
	cmp.l %d5,%a1
	jne .L123
	mulu.w #130,%d0
	move.l %d0,%a1
	add.l #sfu_x,%a1
.L124:
	lea (%a2,%d1.l*4),%a0
	move.l %d3,%d0
	asr.l #8,%d0
	add.l %d4,%a0
	mvz.b 2460(%a0),%d5
	tst.l %d3
	jge .L126
	clr.l %d0
.L126:
	tst.l %d5
	jeq .L127
	cmp.l %d0,%d5
	jgt .L128
	move.l %d5,%d0
	subq.l #1,%d0
.L128:
	moveq #48,%d7
	moveq #12,%d5
	muls.l %d7,%d1
	muls.l %d4,%d5
	move.l %d5,%a0
	add.l %d1,%a0
	add.l %a2,%a0
	add.l %d0,%a0
	mvz.b 2468(%a0),%d0
.L127:
	move.l %d0,%d1
	moveq #127,%d7
	cmp.l %d0,%d7
	jge .L129
	moveq #127,%d1
.L129:
	tst.l %a1
	jeq .L130
	mvz.b 1(%a1),%d6
	lea (22,%a1),%a2
	mov3q.l #-1,%a0
	clr.l %d0
.L131:
	cmp.l %d6,%d0
	jge .L133
	moveq #12,%d5
	cmp.l %d0,%d5
	jne .L134
.L133:
	mov3q.l #-1,%d7
	cmp.l %a0,%d7
	jeq .L130
	move.l %a0,%d0
	lsl.l #3,%d0
	add.l %a0,%d0
	lea (%a1,%d0.l),%a0
	mvz.b 23(%a0),%d3
	sub.l %d3,%d1
	mvz.b 24(%a0),%d3
	add.l %d3,%d1
	moveq #99,%d3
	cmp.l %d1,%d3
	jlt .L143
	moveq #9,%d5
	cmp.l %d1,%d5
	jge .L144
	mov3q.l #2,%a2
.L135:
	lea 25(%a1,%d0.l),%a0
	move.l %a0,%d3
	lea (%a1,%d0.l),%a0
	move.b 22(%a0),%d0
	move.w %d0,%ccr
	jne .L136
	sub.l %a1,%a1
.L137:
	tst.b 25(%a0,%a1.l)
	jeq .L138
	addq.l #1,%a1
	mov3q.l #5,%d5
	cmp.l %a1,%d5
	jne .L137
.L138:
	lea 1(%a2,%a1.l),%a0
	mov3q.l #7,%d7
	cmp.l %a0,%d7
	jlt .L145
	move.l #fmt_sn,%d0
.L140:
	move.l %d1,48(%sp)
	move.l %d3,44(%sp)
	move.l %d0,40(%sp)
.L159:
	move.l %d2,36(%sp)
	movem.l (%sp),#1276
	lea (32,%sp),%sp
	jmp 1074365954
.L123:
	addq.l #1,%d0
	lea (130,%a0),%a0
	moveq #16,%d5
	cmp.l %d0,%d5
	jne .L125
	sub.l %a1,%a1
	jra .L124
.L134:
	move.b (%a2),%d5
	mov3q.l #3,%d7
	and.l %d7,%d5
	cmp.l %d5,%d4
	jne .L132
	mvz.b 1(%a2),%d5
	cmp.l %d5,%d1
	jlt .L132
	move.l %d0,%a0
.L132:
	addq.l #1,%d0
	lea (9,%a2),%a2
	jra .L131
.L143:
	mov3q.l #3,%a2
	jra .L135
.L144:
	mov3q.l #1,%a2
	jra .L135
.L136:
	move.l %d3,44(%sp)
	move.l #fmt_s,%d0
	move.l %d2,36(%sp)
	movem.l (%sp),#1276
	move.l %d0,40(%sp)
	lea (32,%sp),%sp
	jmp 1074365954
.L145:
	move.l #fmt_n,%d0
	jra .L140
.L130:
	move.l sfu_x+2136,%a1
	tst.l %a1
	jeq .L141
	move.l %d2,44(%sp)
	move.l %d3,40(%sp)
	movem.l (%sp),#1276
	move.l 28(%sp),36(%sp)
	lea (32,%sp),%sp
	jmp (%a1)
.L141:
	move.l #s_empty,%d0
	move.l #fmt_d,%d3
	move.l %d1,48(%sp)
	move.l %d0,44(%sp)
	move.l %d3,40(%sp)
	jra .L159
	.size	ptext, .-ptext
	.align	2
	.globl	sfu_p00_text
	.type	sfu_p00_text, @function
sfu_p00_text:
	move.l -66650100,%d0
	subq.l #8,%sp
	move.l %d0,4(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	clr.l -(%sp)
	clr.l -(%sp)
	jsr ptext
	clr.l -(%sp)
	move.l 28(%sp),-(%sp)
	move.l %d0,28(%sp)
	jsr timed
	move.l 28(%sp),%d0
	lea (36,%sp),%sp
	rts
	.size	sfu_p00_text, .-sfu_p00_text
	.align	2
	.globl	sfu_p01_text
	.type	sfu_p01_text, @function
sfu_p01_text:
	move.l -66650100,%d0
	subq.l #8,%sp
	move.l %d0,4(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	jsr ptext
	clr.l -(%sp)
	move.l 28(%sp),-(%sp)
	move.l %d0,28(%sp)
	jsr timed
	move.l 28(%sp),%d0
	lea (36,%sp),%sp
	rts
	.size	sfu_p01_text, .-sfu_p01_text
	.align	2
	.globl	sfu_p02_text
	.type	sfu_p02_text, @function
sfu_p02_text:
	move.l -66650100,%d0
	subq.l #8,%sp
	move.l %d0,4(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	mov3q.l #2,-(%sp)
	clr.l -(%sp)
	jsr ptext
	clr.l -(%sp)
	move.l 28(%sp),-(%sp)
	move.l %d0,28(%sp)
	jsr timed
	move.l 28(%sp),%d0
	lea (36,%sp),%sp
	rts
	.size	sfu_p02_text, .-sfu_p02_text
	.align	2
	.globl	sfu_p03_text
	.type	sfu_p03_text, @function
sfu_p03_text:
	move.l -66650100,%d0
	subq.l #8,%sp
	move.l %d0,4(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	mov3q.l #3,-(%sp)
	clr.l -(%sp)
	jsr ptext
	clr.l -(%sp)
	move.l 28(%sp),-(%sp)
	move.l %d0,28(%sp)
	jsr timed
	move.l 28(%sp),%d0
	lea (36,%sp),%sp
	rts
	.size	sfu_p03_text, .-sfu_p03_text
	.align	2
	.globl	sfu_p10_text
	.type	sfu_p10_text, @function
sfu_p10_text:
	move.l -66650100,%d0
	subq.l #8,%sp
	move.l %d0,4(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	jsr ptext
	clr.l -(%sp)
	move.l 28(%sp),-(%sp)
	move.l %d0,28(%sp)
	jsr timed
	move.l 28(%sp),%d0
	lea (36,%sp),%sp
	rts
	.size	sfu_p10_text, .-sfu_p10_text
	.align	2
	.globl	sfu_p11_text
	.type	sfu_p11_text, @function
sfu_p11_text:
	move.l -66650100,%d0
	subq.l #8,%sp
	move.l %d0,4(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	mov3q.l #1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr ptext
	clr.l -(%sp)
	move.l 28(%sp),-(%sp)
	move.l %d0,28(%sp)
	jsr timed
	move.l 28(%sp),%d0
	lea (36,%sp),%sp
	rts
	.size	sfu_p11_text, .-sfu_p11_text
	.align	2
	.globl	sfu_p12_text
	.type	sfu_p12_text, @function
sfu_p12_text:
	move.l -66650100,%d0
	subq.l #8,%sp
	move.l %d0,4(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	mov3q.l #2,-(%sp)
	mov3q.l #1,-(%sp)
	jsr ptext
	clr.l -(%sp)
	move.l 28(%sp),-(%sp)
	move.l %d0,28(%sp)
	jsr timed
	move.l 28(%sp),%d0
	lea (36,%sp),%sp
	rts
	.size	sfu_p12_text, .-sfu_p12_text
	.align	2
	.globl	sfu_p13_text
	.type	sfu_p13_text, @function
sfu_p13_text:
	move.l -66650100,%d0
	subq.l #8,%sp
	move.l %d0,4(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	mov3q.l #3,-(%sp)
	mov3q.l #1,-(%sp)
	jsr ptext
	clr.l -(%sp)
	move.l 28(%sp),-(%sp)
	move.l %d0,28(%sp)
	jsr timed
	move.l 28(%sp),%d0
	lea (36,%sp),%sp
	rts
	.size	sfu_p13_text, .-sfu_p13_text
	.align	2
	.type	set_look, @function
set_look:
	lea (-16,%sp),%sp
	move.l 24(%sp),%a1
	move.l 20(%sp),%a0
	move.l %a0,%d0
	movem.l #7172,(%sp)
	move.l 28(%sp),%d1
	add.l #14,%d0
	tst.l %a1
	jeq .L175
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jge .L176
	subq.l #1,%d1
	lsl.l #8,%d1
	move.l #1100634268,%a2
.L169:
	move.w %d0,%d2
	move.l #1075575076,%a4
	move.l %a0,%a3
	add.l #sfu_x,%a3
	mulu.w #52,%d2
	move.l %d1,(%a4,%d2.l)
	mvz.b 2564(%a3),%d1
	cmp.l %d1,%a1
	jeq .L168
	mulu.w #84,%d0
	move.l %d0,%a0
	add.l #1100630152,%a0
	move.l (%a2),(%a0)
	move.l 4(%a2),4(%a0)
	move.l 8(%a2),8(%a0)
	move.l 16(%a2),16(%a0)
	tst.l %a1
	jne .L171
	move.l 1100664640,%d0
.L172:
	move.l %d0,48(%a0)
	move.w %a1,%d0
	move.b %d0,2564(%a3)
.L168:
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	rts
.L175:
	mvz.w #32512,%d1
	move.l #1100664592,%a2
	jra .L169
.L176:
	mvz.w #256,%d1
	move.l #1100634268,%a2
	jra .L169
.L171:
	mov3q.l #2,%d0
	cmp.l %a1,%d0
	jne .L173
	move.l 1100633980,%d0
	jra .L172
.L173:
	mov3q.l #3,%d2
	cmp.l %a1,%d2
	jne .L174
	move.l 1100637004,%d0
	jra .L172
.L174:
	move.l #sfu_draw,%d0
	jra .L172
	.size	set_look, .-set_look
	.align	2
	.globl	sfu_draw
	.type	sfu_draw, @function
sfu_draw:
	move.l -66650100,%d1
	lea (-40,%sp),%sp
	movem.l #16396,(%sp)
	move.l 44(%sp),%d0
	add.l #-1100630188,%d0
	move.l %d1,12(%sp)
	moveq #84,%d3
	move.l %d0,%d1
	divu.l %d3,%d1
	clr.b %d2
	move.l 48(%sp),%a0
	moveq #126,%d3
	lea (16,%sp),%a6
	move.l %d1,%a1
	lea (-334,%a1),%a1
	move.b %d2,16(%sp)
	cmp.l %a1,%d3
	jcs .L178
	moveq #84,%d0
	muls.l %d0,%d1
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	add.l #1100630172,%d1
	move.l %d1,-(%sp)
	jsr xname
.L184:
	lea (12,%sp),%sp
.L179:
	clr.b %d0
	move.b %d0,24(%sp)
	tst.b 16(%sp)
	jeq .L183
	move.l %a6,%d2
.L182:
	move.l #1098791068,-(%sp)
	jsr 1074207612
	move.l %a6,-(%sp)
	pea fmt_s
	move.l %d2,-(%sp)
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.l 84(%sp),%d1
	subq.l #2,%d1
	move.l %d1,-(%sp)
	move.l 84(%sp),-(%sp)
	move.l %d0,-(%sp)
	move.l 88(%sp),-(%sp)
	jsr 1074205920
	lea (36,%sp),%sp
	clr.l (%sp)
	move.l 16(%sp),-(%sp)
	jsr timed
	movem.l 8(%sp),#16396
	clr.l %d0
	lea (48,%sp),%sp
	rts
.L178:
	add.l #-16,%d1
	moveq #11,%d2
	cmp.l %d1,%d2
	jcs .L179
	mov3q.l #6,%d3
	rems.l %d3,%d2:%d1
	cmp.l #1847,%d0
	shi %d0
	move.l %d2,%a1
	mvs.b %d0,%d0
	neg.l %d0
	tst.l %d2
	jne .L180
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	move.l %d0,-(%sp)
	jsr type_text
	jra .L184
.L180:
	mov3q.l #1,%d3
	cmp.l %d2,%d3
	jne .L181
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	clr.l -(%sp)
	jsr sfu_route_text
	jra .L184
.L181:
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	clr.l -(%sp)
	pea -2(%a1)
	move.l %d0,-(%sp)
	jsr ptext
	lea (20,%sp),%sp
	jra .L179
.L183:
	move.l #s_wide,%d2
	jra .L182
	.size	sfu_draw, .-sfu_draw
	.align	2
	.globl	sfu_sysex
	.type	sfu_sysex, @function
sfu_sysex:
	lea (-36,%sp),%sp
	move.l -66650100,%d1
	move.l 44(%sp),%d0
	movem.l #15420,(%sp)
	move.l 40(%sp),%a0
	mov3q.l #7,%d2
	move.l %d1,32(%sp)
	cmp.l %d0,%d2
	jge .L186
	mvz.b 5(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L186
	mvz.b 4(%a0),%d1
	moveq #33,%d4
	cmp.l %d1,%d4
	jne .L187
	addq.l #1,sfu_x+2320
	tst.b 6(%a0)
	jeq .L188
	clr.b %d5
	mov3q.l #1,sfu_x+2316
	lea sfu_st,%a1
	clr.l %d1
	move.b %d5,sfu_x+2188
.L189:
	clr.b (%a1)
	addq.l #1,%d1
	addq.l #8,%a1
	cmp.l #128,%d1
	jne .L189
	lea sfu_x,%a1
	clr.l %d1
.L190:
	clr.b (%a1)
	addq.l #1,%d1
	lea (130,%a1),%a1
	moveq #16,%d2
	cmp.l %d1,%d2
	jne .L190
	move.l #1330005504,%d3
	addq.l #1,sfu_x+2080
	move.l %d3,sfu_st
.L188:
	subq.l #1,%d0
	addq.l #8,%a0
	moveq #9,%d3
	lea sfu_st,%a3
	lea sfu_x+2188,%a4
.L191:
	move.l %d3,%d1
	add.l #12,%d1
	cmp.l %d0,%d1
	jlt .L200
	moveq #2,%d0
	addq.l #1,sfu_x+2596
	addq.l #1,sfu_x+2320
	move.b %d0,sfu_st+1027
.L186:
	mov3q.l #1,-(%sp)
	move.l 36(%sp),-(%sp)
	jsr timed
	movem.l 8(%sp),#15420
	mov3q.l #1,%d0
	lea (44,%sp),%sp
	rts
.L200:
	move.b (%a0),%d2
	jmi .L192
	move.b %d2,%d1
	sub.l %a2,%a2
	ext.w %d1
	mvz.w %d1,%d1
	lsl.l #3,%d1
	move.l %d1,%a1
	add.l #sfu_st,%a1
.L196:
	move.b 1(%a0,%a2.l),%d1
	moveq #94,%d5
	move.l %d1,%d4
	add.l #-32,%d4
	mvz.b %d4,%d4
	cmp.l %d4,%d5
	jcs .L193
	move.b %d1,(%a1,%a2.l)
.L194:
	addq.l #1,%a2
	mov3q.l #7,%d5
	cmp.l %a2,%d5
	jne .L196
	jra .L195
.L193:
	clr.b %d4
	move.b %d4,(%a1,%a2.l)
	tst.b %d1
	jne .L194
.L195:
	mvz.b %d2,%d4
	clr.b %d5
	sub.l %a1,%a1
	move.l %d4,%d1
	lsl.l #3,%d1
	move.b %d5,7(%a3,%d1.l)
	move.l sfu_x+2316,%d1
.L197:
	cmp.l %a1,%d1
	jle .L198
	mvz.b (%a4,%a1.l),%d5
	cmp.l %d4,%d5
	jne .L199
.L198:
	cmp.l %d1,%a1
	jne .L192
	cmp.l #128,%d1
	jeq .L192
	move.l %d1,%a1
	add.l #sfu_x,%d1
	move.l %d1,%a2
	addq.l #1,%a1
	move.b %d2,2188(%a2)
	move.l %a1,sfu_x+2316
.L192:
	lea (14,%a0),%a0
	add.l #14,%d3
	jra .L191
.L199:
	addq.l #1,%a1
	jra .L197
.L187:
	moveq #36,%d2
	cmp.l %d1,%d2
	jne .L201
	moveq #23,%d3
	cmp.l %d0,%d3
	jge .L202
	mov3q.l #7,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L202
	move.b 6(%a0),%d2
	moveq #127,%d4
	mvz.b %d2,%d1
	cmp.l %d1,%d4
	jge .L203
.L202:
	addq.l #1,sfu_x+2144
	jra .L186
.L203:
	lea sfu_x,%a2
	addq.l #1,%d1
	move.l %a2,%a3
	clr.l %d3
.L206:
	mvz.b (%a3),%d4
	move.l %a3,%a1
	cmp.l %d4,%d1
	jeq .L204
	sub.l %a1,%a1
.L204:
	addq.l #1,%d3
	moveq #16,%d5
	cmp.l %d3,%d5
	jeq .L228
	lea (130,%a3),%a3
	tst.l %a1
	jeq .L206
.L228:
	clr.l %d1
.L208:
	tst.l %a1
	jeq .L210
.L211:
	clr.b (%a1)
	move.l %a1,%a3
	clr.l %d1
.L212:
	mvz.w %d1,%d3
	sub.l %a2,%a2
	lea (%a0,%d3.l*4),%a4
.L214:
	move.b 7(%a4,%a2.l),%d4
	moveq #94,%d5
	move.l %d4,%d3
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcs .L213
	move.b %d4,2(%a3,%a2.l)
	addq.l #1,%a2
	mov3q.l #4,%d3
	cmp.l %a2,%d3
	jne .L214
.L213:
	move.l %d1,%a5
	addq.l #5,%a3
	lea (%a5,%d1.l*4),%a4
	clr.b %d3
	addq.l #1,%d1
	mov3q.l #4,%d4
	add.l %a1,%a4
	move.b %d3,2(%a2,%a4.l)
	cmp.l %d1,%d4
	jne .L212
	moveq #127,%d5
	cmp.l %d0,%d5
	jlt .L229
	asr.l #3,%d0
	move.l %d0,%d3
	subq.l #3,%d3
.L216:
	move.l %a1,%d0
	clr.l %d1
	lea (23,%a0),%a0
	add.l #22,%d0
.L217:
	cmp.l %d1,%d3
	jne .L220
	addq.l #1,%d2
	move.b %d1,1(%a1)
	move.b %d2,(%a1)
	addq.l #1,sfu_x+2148
	addq.l #1,sfu_x+2080
	jra .L186
.L210:
	tst.b (%a2)
	jne .L207
	move.l %a2,%a1
.L207:
	addq.l #1,%d1
	lea (130,%a2),%a2
	moveq #16,%d3
	cmp.l %d1,%d3
	jne .L208
	tst.l %a1
	jne .L211
	jra .L202
.L229:
	moveq #12,%d3
	jra .L216
.L220:
	move.b (%a0),%d4
	moveq #15,%d5
	move.l %d0,%a2
	move.l %d0,%a4
	lea (-22,%a4),%a4
	and.l %d5,%d4
	moveq #127,%d5
	move.b %d4,(%a2)
	move.b 1(%a0),%d4
	and.l %d5,%d4
	move.b %d4,1(%a2)
	move.b 2(%a0),%d4
	and.l %d5,%d4
	move.b %d4,2(%a2)
	sub.l %a2,%a2
.L219:
	move.b 3(%a0,%a2.l),%d4
	move.l %d4,%a3
	lea (-32,%a3),%a3
	move.w %a3,%d5
	mvz.b %d5,%d5
	move.l %d5,%a3
	moveq #94,%d5
	cmp.l %a3,%d5
	jcs .L218
	move.b %d4,25(%a4,%a2.l)
	addq.l #1,%a2
	mov3q.l #5,%d4
	cmp.l %a2,%d4
	jne .L219
.L218:
	move.l %d1,%d4
	addq.l #8,%a0
	lsl.l #3,%d4
	clr.b %d5
	add.l #9,%d0
	move.l %d4,%a3
	add.l %d1,%a3
	add.l %a1,%a3
	move.b %d5,25(%a2,%a3.l)
	addq.l #1,%d1
	jra .L217
.L201:
	moveq #34,%d2
	cmp.l %d1,%d2
	jne .L186
	moveq #8,%d3
	cmp.l %d0,%d3
	jeq .L186
	mvz.b 6(%a0),%d2
	mov3q.l #1,%d4
	cmp.l %d2,%d4
	jcs .L186
	mvz.b 8(%a0),%d3
	move.b 7(%a0),%d1
	subq.l #3,%d3
	tst.l %d3
	jne .L230
	move.b %d1,%d3
.L221:
	lea sfu_st,%a3
	lea (%a3,%d2.l),%a1
	move.b %d3,1024(%a1)
	mvz.b 8(%a0),%d2
	subq.l #3,%d2
	tst.l %d2
	jne .L186
	tst.b %d1
	jlt .L186
	mvz.b %d1,%d2
	lsl.l #3,%d2
	tst.b (%a3,%d2.l)
	jne .L186
	ext.w %d1
	subq.l #1,%d0
	sub.l %a2,%a2
	mvz.w %d1,%d1
	lsl.l #3,%d1
	lea (%a3,%d1.l),%a1
	moveq #9,%d1
.L222:
	cmp.l %d0,%d1
	jge .L224
	move.b (%a0,%d1.l),%d4
	moveq #94,%d5
	move.l %d4,%d3
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcs .L224
	move.b %d4,(%a1,%a2.l)
	addq.l #1,%a2
	addq.l #1,%d1
	mov3q.l #7,%d3
	cmp.l %a2,%d3
	jne .L222
.L224:
	clr.b %d4
	add.l %d2,%a3
	move.b %d4,(%a3,%a2.l)
	jra .L186
.L230:
	st %d3
	jra .L221
	.size	sfu_sysex, .-sfu_sysex
	.text
.LC0:
	.string	"ON"
.LC1:
	.string	"OFF"
	.text
	.align	2
	.type	relabel, @function
relabel:
	lea (-72,%sp),%sp
	movem.l #31996,(%sp)
	lea sfu_x+2460,%a0
	clr.l %d5
	lea sfu_x+2088,%a6
	move.l %a0,44(%sp)
	clr.l 52(%sp)
	clr.l 48(%sp)
.L280:
	mvz.b (%a6)+,%d1
	lea sfu_x,%a0
	clr.l %d0
	addq.l #1,%d1
.L258:
	mvz.b (%a0),%d2
	cmp.l %d2,%d1
	jne .L256
	mulu.w #130,%d0
	move.l %d0,%a2
	add.l #sfu_x,%a2
.L257:
	move.l 48(%sp),%d3
	moveq #48,%d6
	move.l 52(%sp),%a0
	addq.l #4,%a0
	move.l %d5,%a4
	move.l %a2,%d7
	muls.l %d6,%d3
	add.l #sfu_x+2092,%a4
	sub.l %a3,%a3
	move.l %a0,64(%sp)
	move.l %d3,68(%sp)
.L279:
	tst.l %a2
	jeq .L294
	sub.l %a0,%a0
.L259:
	move.b 2(%a0,%d7.l),%d0
	jeq .L261
	move.b %d0,(%a4,%a0.l)
	addq.l #1,%a0
	mov3q.l #4,%d0
	cmp.l %a0,%d0
	jne .L259
.L261:
	clr.b %d1
	move.l %a3,%d0
	moveq #12,%d3
	muls.l %d3,%d0
	clr.l %d4
	clr.l 56(%sp)
	add.l 68(%sp),%d0
	move.b %d1,(%a4,%a0.l)
	lea (22,%a2),%a0
	clr.l %d1
	move.l %a0,%d2
	add.l #sfu_x,%d0
.L263:
	mvz.b 1(%a2),%d3
	cmp.l 56(%sp),%d3
	jle .L265
	moveq #12,%d3
	cmp.l 56(%sp),%d3
	jne .L266
.L265:
	tst.l %d4
	jeq .L267
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L267
	move.l 44(%sp),%a1
	mov3q.l #2,%d0
	move.b %d1,(%a1,%a3.l)
	cmp.l %d1,%d0
	jeq .L270
.L295:
	mov3q.l #1,%d0
	jra .L269
.L284:
	mov3q.l #1,48(%sp)
	jra .L280
.L256:
	addq.l #1,%d0
	lea (130,%a0),%a0
	moveq #16,%d2
	cmp.l %d0,%d2
	jne .L258
	sub.l %a2,%a2
	jra .L257
.L266:
	move.l %d2,%a1
	mov3q.l #3,%d6
	move.b (%a1),%d3
	and.l %d3,%d6
	cmp.l %d6,%a3
	jne .L264
	moveq #8,%d6
	and.l %d6,%d3
	lea (1,%a1),%a5
	or.l %d3,%d4
	move.l %d0,%d3
	add.l %d1,%d3
	move.l %d3,%a1
	addq.l #1,%d1
	move.b (%a5),2468(%a1)
.L264:
	addq.l #1,56(%sp)
	add.l #9,%d2
	jra .L263
.L294:
	clr.b %d6
	move.l %a3,%d0
	add.l #50,%d0
	move.b #80,(%a4)
	move.b %d0,1(%a4)
	move.b %d6,2(%a4)
.L267:
	clr.b %d1
	move.l 44(%sp),%a0
	clr.l %d0
	move.b %d1,(%a0,%a3.l)
	clr.l %d1
.L269:
	move.l %d1,-(%sp)
	move.l %d0,-(%sp)
	move.l 72(%sp),%a0
	addq.l #5,%a4
	addq.l #5,%d7
	pea (%a0,%a3.l)
	jsr set_look
	addq.l #1,%a3
	lea (12,%sp),%sp
	mov3q.l #4,%d0
	cmp.l %a3,%d0
	jne .L279
	move.b -1(%a6),1(%a6)
	addq.l #6,52(%sp)
	addq.l #4,44(%sp)
	add.l #20,%d5
	mov3q.l #1,%d1
	cmp.l 48(%sp),%d1
	jne .L284
	movem.l (%sp),#31996
	addq.l #1,sfu_x+2160
	lea (72,%sp),%sp
	rts
.L270:
	mvz.b 1(%a2),%d2
	clr.l %d0
	sub.l %a1,%a1
	move.l %d2,60(%sp)
.L271:
	cmp.l 60(%sp),%a1
	jge .L277
	moveq #12,%d3
	cmp.l %a1,%d3
	jne .L278
.L277:
	mov3q.l #2,%d6
	cmp.l %d0,%d6
	jne .L295
	mov3q.l #2,%d1
	jra .L269
.L278:
	move.b (%a0),%d2
	mov3q.l #3,%d3
	and.l %d3,%d2
	cmp.l %d2,%a3
	jne .L272
	lea (3,%a0),%a5
	move.l %a5,56(%sp)
	tst.l %d0
	jeq .L282
	move.l #.LC0,%d6
.L273:
	clr.l %d4
.L275:
	move.l %d6,%a5
	move.b (%a5,%d4.l),%d3
	move.l 56(%sp),%a5
	move.b (%a5,%d4.l),%d2
	tst.b %d3
	jeq .L274
	mvs.b %d3,%d3
	mvs.b %d2,%d2
	addq.l #1,%d4
	cmp.l %d3,%d2
	jeq .L275
	jra .L295
.L282:
	move.l #.LC1,%d6
	jra .L273
.L274:
	tst.b %d2
	jne .L295
	addq.l #1,%d0
	mov3q.l #2,%d2
	cmp.l %d0,%d2
	jlt .L295
.L272:
	addq.l #1,%a1
	lea (9,%a0),%a0
	jra .L271
	.size	relabel, .-relabel
	.align	2
	.type	sync, @function
sync:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	pea 16.w
	move.l 16(%sp),-(%sp)
	jsr 1074433680
	pea 22.w
	move.l 24(%sp),-(%sp)
	move.l %d0,%d3
	asr.l #8,%d3
	moveq #127,%d0
	and.l %d0,%d3
	jsr 1074433680
	lea (16,%sp),%sp
	move.l sfu_x+2084,%a0
	move.l %d0,%d2
	asr.l #8,%d2
	moveq #127,%d0
	and.l %d0,%d2
	move.b %d3,sfu_x+2088
	move.b %d2,sfu_x+2089
	cmp.l sfu_x+2080.l,%a0
	jne .L297
	mvz.b sfu_x+2090,%d0
	cmp.l %d0,%d3
	jne .L297
	mvz.b sfu_x+2091,%d0
	cmp.l %d0,%d2
	jeq .L298
.L297:
	lea sfu_x+2080,%a0
	move.l (%a0),sfu_x+2084
	jsr relabel
.L298:
	move.l %d3,-(%sp)
	clr.l -(%sp)
	lea tcache,%a0
	jsr (%a0)
	addq.l #8,%sp
	move.b sfu_x+2580,%d0
	move.l sfu_x+2452,%d1
	lea tcache,%a0
	not.l %d0
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	sub.l %d0,%d1
	lsl.l #8,%d1
	add.l #-256,%d1
	move.l %d1,1075575908
	move.l %d2,-(%sp)
	mov3q.l #1,-(%sp)
	jsr (%a0)
	addq.l #8,%sp
	move.b sfu_x+2581,%d0
	move.l sfu_x+2452,%d1
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	not.l %d0
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	sub.l %d0,%d1
	lsl.l #8,%d1
	add.l #-256,%d1
	move.l %d1,1075576220
	rts
	.size	sync, .-sync
	.align	2
	.globl	sfu_isext
	.type	sfu_isext, @function
sfu_isext:
	move.l 4(%sp),-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	rts
	.size	sfu_isext, .-sfu_isext
	.align	2
	.globl	sfu_s_read
	.type	sfu_s_read, @function
sfu_s_read:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d3
	move.l %d3,-(%sp)
	move.l 16(%sp),-(%sp)
	jsr 1074433530
	addq.l #8,%sp
	moveq #13,%d1
	move.l %d0,%d2
	move.l %d3,%d0
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcs .L301
	btst #0,%d0
	jeq .L302
	lsl.l #7,%d2
.L302:
	and.l #32512,%d2
.L300:
	move.l %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L301:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L300
	move.l %d2,16(%sp)
	move.l %d3,12(%sp)
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	jra x_knob
	.size	sfu_s_read, .-sfu_s_read
	.align	2
	.globl	sfu_f_read
	.type	sfu_f_read, @function
sfu_f_read:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.l 20(%sp),%d3
	move.l 16(%sp),%d4
	move.l %d3,-(%sp)
	move.l %d4,-(%sp)
	add.l #-14,%d3
	jsr 1074433680
	move.l %d4,-(%sp)
	move.l %d0,%d2
	jsr see_fxset
	lea (12,%sp),%sp
	moveq #13,%d0
	cmp.l %d3,%d0
	jcs .L307
	tst.b sfu_st+1026.l
	jeq .L309
	move.l %d4,-(%sp)
	jsr sync
	addq.l #4,%sp
.L309:
	btst #0,%d3
	jeq .L310
	lsl.l #7,%d2
.L310:
	and.l #32512,%d2
	move.l %d3,16(%sp)
	move.l %d2,20(%sp)
	movem.l (%sp),#28
	lea (12,%sp),%sp
	jra to_knob
.L307:
	move.l %d2,%d0
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
	.size	sfu_f_read, .-sfu_f_read
	.align	2
	.globl	sfu_s_write
	.type	sfu_s_write, @function
sfu_s_write:
	lea (-24,%sp),%sp
	moveq #13,%d0
	movem.l #60,(%sp)
	move.l 32(%sp),%d3
	move.l %d3,%d4
	move.l 28(%sp),%d5
	add.l #-14,%d4
	move.l 36(%sp),%d2
	move.l 40(%sp),16(%sp)
	move.l 44(%sp),20(%sp)
	cmp.l %d4,%d0
	jcs .L313
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	addq.l #1,sfu_st+1030
	jsr 1074433530
	move.l %d2,-(%sp)
	move.l %d0,-(%sp)
	move.l %d4,-(%sp)
	jsr merge
	lea (20,%sp),%sp
	move.l %d0,%d2
.L314:
	move.l %d2,36(%sp)
	move.l %d3,32(%sp)
	move.l %d5,28(%sp)
	movem.l (%sp),#60
	move.l 20(%sp),44(%sp)
	move.l 16(%sp),40(%sp)
	lea (24,%sp),%sp
	jmp 1074438046
.L313:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L314
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433530
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	move.l %d0,%d4
	jsr x_half
	lea (16,%sp),%sp
	move.l %d3,%a0
	add.l #sfu_x,%a0
	move.l %d0,%d2
	tst.b 6223(%a0)
	jeq .L314
	tst.l %d4
	jlt .L314
	and.l #32512,%d2
	and.l #224,%d4
	or.l %d4,%d2
	jra .L314
	.size	sfu_s_write, .-sfu_s_write
	.align	2
	.globl	sfu_f_write
	.type	sfu_f_write, @function
sfu_f_write:
	lea (-32,%sp),%sp
	moveq #13,%d0
	movem.l #1148,(%sp)
	move.l 40(%sp),%d5
	move.l %d5,%d3
	move.l 36(%sp),%a2
	add.l #-14,%d3
	move.l 44(%sp),%d2
	move.l 48(%sp),24(%sp)
	move.l 52(%sp),28(%sp)
	cmp.l %d3,%d0
	jcs .L321
	lea k_cidx,%a0
	move.l %d5,-(%sp)
	mvz.b (%a0,%d3.l),%d4
	move.l %a2,-(%sp)
	jsr 1074433680
	move.l %a2,-(%sp)
	addq.l #1,sfu_st+1030
	move.l %d0,%d6
	jsr see_fxset
	move.l %d6,%d0
	asr.l #8,%d0
	moveq #127,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr to_half
	move.l %d0,-(%sp)
	move.l %d6,-(%sp)
	move.l %d3,-(%sp)
	jsr merge
	lea (36,%sp),%sp
	mov3q.l #1,%d6
	move.l %d0,%d2
	cmp.l %d3,%d6
	jge .L322
	move.l %d5,%d0
	mov3q.l #6,%d6
	add.l #-16,%d0
	rems.l %d6,%d1:%d0
	tst.l %d1
	jne .L322
	mov3q.l #7,%d0
	cmp.l %d3,%d0
	slt %d3
	move.l %d2,%d0
	asr.l #8,%d0
	lea sfu_x,%a0
	mvs.b %d3,%d3
	sub.l %d3,%a0
	move.b %d0,2088(%a0)
.L322:
	moveq #37,%d1
	cmp.l %d4,%d1
	jlt .L325
.L321:
	move.l %d2,44(%sp)
	move.l %d5,40(%sp)
	move.l %a2,36(%sp)
	movem.l (%sp),#1148
	move.l 28(%sp),52(%sp)
	move.l 24(%sp),48(%sp)
	lea (32,%sp),%sp
	jmp 1074438172
.L325:
	move.l 20(%a2),%a0
	move.l (%a0),%a1
	move.l %a0,-(%sp)
	move.l 40(%a1),%a0
	jsr (%a0)
	move.l %d4,%d1
	add.l #-38,%d1
	mvz.w %d1,%d1
	add.l %d4,%d4
	move.l %d0,%a1
	move.l %d2,%d0
	asr.l #8,%d0
	add.l %d1,%d1
	move.w %d2,(%a1,%d4.l)
	move.l %d4,%a1
	add.l #-2147423840,%a1
	move.w %d2,(%a1)
	move.l %d1,%a0
	add.l #1081499899,%a0
	move.b %d0,(%a0)
	move.b %d2,1(%a0)
	mov3q.l #1,%d0
	movem.l 4(%sp),#1148
	lea (36,%sp),%sp
	rts
	.size	sfu_f_write, .-sfu_f_write
	.align	2
	.globl	sfu_s_lget
	.type	sfu_s_lget, @function
sfu_s_lget:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.l 20(%sp),%d3
	moveq #11,%d2
	move.l %d3,%d0
	add.l #-16,%d0
	move.l 16(%sp),%d1
	move.l 24(%sp),%a0
	cmp.l %d0,%d2
	jcs .L327
	mov3q.l #6,%d4
	rems.l %d4,%d2:%d0
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jge .L333
.L327:
	move.l %a0,-(%sp)
	move.l %d3,-(%sp)
	move.l %d1,-(%sp)
	jsr 1074436168
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jlt .L326
	move.l %d3,%d0
	moveq #13,%d1
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcs .L330
	btst #0,%d0
	jeq .L331
	lsl.l #7,%d2
.L331:
	and.l #32512,%d2
.L326:
	move.l %d2,%d0
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L330:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L326
	move.l %d2,20(%sp)
	move.l %d3,16(%sp)
	movem.l (%sp),#28
	lea (12,%sp),%sp
	jra x_knob
.L333:
	mov3q.l #-1,%d2
	jra .L326
	.size	sfu_s_lget, .-sfu_s_lget
	.align	2
	.globl	sfu_f_lget
	.type	sfu_f_lget, @function
sfu_f_lget:
	lea (-16,%sp),%sp
	movem.l #28,(%sp)
	move.l 24(%sp),%d1
	moveq #11,%d2
	move.l %d1,%d0
	add.l #-16,%d0
	move.l 20(%sp),%d3
	move.l 28(%sp),%a0
	cmp.l %d0,%d2
	jcc .L335
.L339:
	move.l %a0,-(%sp)
	moveq #13,%d4
	move.l %d1,-(%sp)
	move.l %d1,%d2
	add.l #-14,%d2
	move.l %d3,-(%sp)
	jsr 1074436538
	lea (12,%sp),%sp
	cmp.l %d2,%d4
	jcc .L345
.L334:
	movem.l (%sp),#28
	lea (16,%sp),%sp
	rts
.L335:
	mov3q.l #6,%d4
	rems.l %d4,%d2:%d0
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jlt .L339
	mov3q.l #-1,%d0
	jra .L334
.L345:
	tst.l %d0
	jlt .L334
	tst.b sfu_st+1026.l
	jeq .L341
	move.l %d3,-(%sp)
	move.l %d0,16(%sp)
	jsr sync
	addq.l #4,%sp
	move.l 12(%sp),%d0
.L341:
	btst #0,%d2
	jeq .L342
	lsl.l #7,%d0
.L342:
	and.l #32512,%d0
	move.l %d2,20(%sp)
	movem.l (%sp),#28
	move.l %d0,24(%sp)
	lea (16,%sp),%sp
	jra to_knob
	.size	sfu_f_lget, .-sfu_f_lget
	.align	2
	.globl	sfu_s_lset
	.type	sfu_s_lset, @function
sfu_s_lset:
	lea (-24,%sp),%sp
	moveq #13,%d0
	movem.l #252,(%sp)
	move.l 32(%sp),%d3
	move.l %d3,%d4
	move.l 28(%sp),%d5
	add.l #-14,%d4
	move.l 36(%sp),%d2
	move.l 40(%sp),%d6
	cmp.l %d4,%d0
	jcs .L347
	moveq #15,%d7
	cmp.l %d3,%d7
	jge .L348
	move.l %d3,%d0
	mov3q.l #6,%d7
	add.l #-16,%d0
	rems.l %d7,%d1:%d0
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L349
.L348:
	move.l %d6,-(%sp)
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	addq.l #1,sfu_st+1030
	jsr 1074436168
	lea (12,%sp),%sp
	tst.l %d0
	jge .L350
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433530
	addq.l #8,%sp
.L350:
	move.l %d2,-(%sp)
	move.l %d0,-(%sp)
	move.l %d4,-(%sp)
	jsr merge
	lea (12,%sp),%sp
	move.l %d0,%d2
.L351:
	move.l %d6,40(%sp)
	move.l %d2,36(%sp)
	move.l %d3,32(%sp)
	move.l %d5,28(%sp)
	movem.l (%sp),#252
	lea (24,%sp),%sp
	jmp 1074436282
.L347:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L351
	move.l %d6,-(%sp)
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074436168
	lea (12,%sp),%sp
	move.l %d0,%d4
	tst.l %d0
	jge .L352
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433530
	addq.l #8,%sp
	move.l %d0,%d4
.L352:
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr x_half
	addq.l #8,%sp
	move.l %d3,%a0
	add.l #sfu_x,%a0
	move.l %d0,%d2
	tst.b 6223(%a0)
	jeq .L351
	tst.l %d4
	jlt .L351
	and.l #32512,%d2
	and.l #224,%d4
	or.l %d4,%d2
	jra .L351
.L349:
	movem.l (%sp),#252
	clr.l %d0
	lea (24,%sp),%sp
	rts
	.size	sfu_s_lset, .-sfu_s_lset
	.align	2
	.globl	sfu_f_lset
	.type	sfu_f_lset, @function
sfu_f_lset:
	lea (-24,%sp),%sp
	moveq #13,%d0
	movem.l #252,(%sp)
	move.l 32(%sp),%d3
	move.l %d3,%d6
	move.l 28(%sp),%d5
	add.l #-14,%d6
	move.l 36(%sp),%d4
	move.l 40(%sp),%d7
	cmp.l %d6,%d0
	jcs .L359
	moveq #15,%d2
	cmp.l %d3,%d2
	jge .L360
	move.l %d3,%d0
	mov3q.l #6,%d2
	add.l #-16,%d0
	rems.l %d2,%d1:%d0
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L361
.L360:
	move.l %d7,-(%sp)
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	addq.l #1,sfu_st+1030
	jsr 1074436538
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jge .L362
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433680
	addq.l #8,%sp
	move.l %d0,%d2
.L362:
	clr.l -(%sp)
	move.l %d4,-(%sp)
	move.l %d6,-(%sp)
	jsr to_half
	move.l %d0,-(%sp)
	move.l %d2,-(%sp)
	move.l %d6,-(%sp)
	jsr merge
	lea (24,%sp),%sp
	move.l %d0,%d4
.L359:
	move.l %d7,40(%sp)
	move.l %d4,36(%sp)
	move.l %d3,32(%sp)
	move.l %d5,28(%sp)
	movem.l (%sp),#252
	lea (24,%sp),%sp
	jmp 1074436652
.L361:
	movem.l (%sp),#252
	clr.l %d0
	lea (24,%sp),%sp
	rts
	.size	sfu_f_lset, .-sfu_f_lset
	.align	2
	.globl	sfu_get
	.type	sfu_get, @function
sfu_get:
	lea (-16,%sp),%sp
	movem.l #3084,(%sp)
	move.l 20(%sp),%a0
	move.l 24(%sp),%d2
	move.l 28(%sp),%d3
	move.l (%a0),%a1
	mov3q.l #-1,-(%sp)
	move.l %a0,-(%sp)
	move.l 160(%a1),%a0
	jsr (%a0)
	addq.l #8,%sp
	move.l %d0,%a2
	move.l (%a2),%a3
	tst.l %d3
	jge .L364
.L365:
	move.l %d2,24(%sp)
	move.l %a2,20(%sp)
	move.l 40(%a3),%a1
	movem.l (%sp),#3084
	lea (16,%sp),%sp
	jmp (%a1)
.L364:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l %d0,-(%sp)
	move.l 60(%a3),%a0
	jsr (%a0)
	lea (12,%sp),%sp
	tst.l %d0
	jlt .L365
	movem.l (%sp),#3084
	lea (16,%sp),%sp
	rts
	.size	sfu_get, .-sfu_get
	.align	2
	.globl	sfu_tick
	.type	sfu_tick, @function
sfu_tick:
	move.l -66650100,%d1
	lea (-32,%sp),%sp
	movem.l #7228,(%sp)
	move.l 36(%sp),%a2
	move.l %d1,28(%sp)
	addq.l #1,sfu_st+1034
	tst.b sfu_st+1026.l
	jne .L367
	tst.l 1100664624
	jeq .L368
	tst.l 1100635224
	jeq .L368
	move.l #1075575792,%a0
	clr.l %d2
	clr.l %d1
	lea k_cidx,%a3
.L379:
	mov3q.l #1,%d3
	cmp.l %d1,%d3
	jge .L399
	move.l %d1,%d0
	moveq #10,%d4
	addq.l #3,%d0
	cmp.l %d0,%d4
	jcs .L400
	move.w #57,%a1
	clr.l %d0
.L369:
	mvz.b (%a3,%d1.l),%d5
	move.l %a1,(%a0)
	move.w #32512,%a1
	clr.l 8(%a0)
	move.l %d5,4(%a0)
	mov3q.l #1,20(%a0)
	move.l %a1,12(%a0)
	clr.l 16(%a0)
	mov3q.l #-1,24(%a0)
	mov3q.l #-1,28(%a0)
	clr.l 36(%a0)
	mov3q.l #-1,%d3
	cmp.l %d0,%d3
	jne .L370
	tst.l %d1
	jeq .L371
	move.l #l_sfx2,%d4
	move.l %d4,40(%a0)
	move.l #s_sfx2,%d0
.L373:
	move.l #s_empty,%d4
	mov3q.l #1,%d5
	move.l %d0,48(%a0)
	move.l %d4,44(%a0)
	cmp.l %d1,%d5
	jlt .L402
	moveq #60,%d0
.L377:
	mulu.w #84,%d0
	move.l %d0,%a1
	clr.l %d0
	add.l #1100630152,%a1
.L378:
	move.l %d2,%a4
	add.l %d0,%a4
	add.l #1100631328,%a4
	move.l (%a1,%d0.l),(%a4)
	moveq #84,%d3
	addq.l #4,%d0
	cmp.l %d0,%d3
	jne .L378
	addq.l #1,%d1
	add.l #84,%d2
	lea (52,%a0),%a0
	moveq #14,%d4
	cmp.l %d1,%d4
	jne .L379
	move.l #1100664624,%a0
	move.l (%a0),sfu_x+2136
	lea sfu_type1_text,%a1
	move.l %a1,1100631528
	move.l #sfu_route_text,%d1
	lea sfu_p12_text,%a1
	move.l %a1,1100632368
	move.l #sfu_type2_text,%d0
	sub.l %a1,%a1
	move.l #sfu_p00_text,%d2
	lea sfu_p02_text,%a0
	move.l %d0,1100632032
	move.l #sfu_p03_text,%d0
	move.l %d1,1100631612
	move.l #sfu_p10_text,%d3
	move.l %d1,1100632116
	move.l #sfu_p13_text,%d1
	move.l %d2,1100631696
	move.l #sfu_p01_text,%d4
	move.l #sfu_p11_text,%d5
	clr.l %d2
	move.l %a0,1100631864
	move.l %d0,1100631948
	move.l %d1,1100632452
	move.l sfu_x+2316,%d1
	move.l %d1,%d0
	move.l %d3,1100632200
	move.l %d4,1100631780
	move.l %d5,1100632284
	lea sfu_st,%a0
.L381:
	tst.b (%a0)
	jeq .L380
	move.l %d0,%a1
	add.l #sfu_x,%a1
	move.b %d2,2188(%a1)
	move.w #1,%a1
	addq.l #1,%d0
.L380:
	addq.l #1,%d2
	addq.l #8,%a0
	cmp.l #128,%d2
	jne .L381
	move.w %a1,%d2
	tst.b %d2
	jeq .L382
	move.l %d0,sfu_x+2316
	move.l %d0,%d1
.L382:
	lea sfu_x+2188,%a0
	clr.l %d0
.L383:
	cmp.l %d0,%d1
	jgt .L384
	move.l %d1,sfu_x+2452
	clr.l %d0
	lea sfu_x+2564,%a0
.L385:
	clr.b %d3
	moveq #14,%d4
	move.b %d3,(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d4
	jne .L385
	mov3q.l #2,-(%sp)
	move.l #sfu_sysex,%d5
	mov3q.l #1,-(%sp)
	mov3q.l #2,-(%sp)
	lea set_look,%a3
	jsr (%a3)
	mov3q.l #2,-(%sp)
	mov3q.l #1,-(%sp)
	pea 8.w
	jsr (%a3)
	mov3q.l #2,-(%sp)
	mov3q.l #3,-(%sp)
	mov3q.l #3,-(%sp)
	jsr (%a3)
	lea (32,%sp),%sp
	mov3q.l #2,(%sp)
	mov3q.l #3,-(%sp)
	pea 9.w
	jsr (%a3)
	jsr relabel
	move.l %d5,1075551832
	lea (12,%sp),%sp
	moveq #1,%d0
	move.l #1397119061,%a0
	move.l %a0,1075551828
	move.b %d0,sfu_st+1026
.L367:
	move.l sfu_x+2320,%d0
	mov3q.l #1,%d1
	and.l %d0,%d1
	btst #0,%d0
	jne .L386
	cmp.l sfu_x+2456.l,%d0
	jeq .L386
	move.l sfu_x+2316,%a0
	lea sfu_x+2188,%a1
.L387:
	cmp.l %a0,%d1
	jeq .L388
	cmp.l #128,%d1
	jne .L389
.L388:
	cmp.l sfu_x+2320.l,%d0
	jne .L386
	tst.l %a0
	jeq .L386
	moveq #1,%d1
	move.l %a0,sfu_x+2452
	move.l %d0,sfu_x+2456
	move.b %d1,32(%a2)
.L386:
	move.l sfu_x+2132,%d0
	tst.l %d0
	jeq .L390
	move.l %d0,-(%sp)
	move.l sfu_x+2160,%d2
	jsr sync
	addq.l #4,%sp
	cmp.l sfu_x+2160.l,%d2
	jeq .L391
	moveq #1,%d2
	move.b %d2,32(%a2)
.L391:
	mvz.b sfu_st+1027,%d0
	lsr.l #1,%d0
	jne .L368
	move.w sfu_st+1028,%d0
	moveq #99,%d2
	mvz.w %d0,%d1
	cmp.l %d1,%d2
	jcs .L392
	addq.l #1,%d0
	move.w %d0,sfu_st+1028
	mvz.w %d0,%d0
	moveq #100,%d3
	cmp.l %d0,%d3
	jne .L368
.L392:
	mov3q.l #1,%d4
	cmp.l 1094562388.l,%d4
	jne .L368
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L393
	addq.l #1,sfu_x+2156
.L368:
	clr.l -(%sp)
	move.l 32(%sp),-(%sp)
	jsr timed
	addq.l #8,%sp
	tst.b sfu_st+1026.l
	jeq .L366
	move.l #1481856080,%a0
	cmp.l 1073848892.l,%a0
	jne .L366
	tst.l 1073848900
	jeq .L366
	move.l -66650100,%d2
	move.l 1073848900,%a0
	jsr (%a0)
	tst.l %d0
	jeq .L398
	moveq #1,%d0
	move.b %d0,32(%a2)
.L398:
	move.l -66650100,%d0
	sub.l %d2,%d0
	add.l %d0,sfu_x+6418
	addq.l #1,sfu_x+6426
	cmp.l sfu_x+6422.l,%d0
	jls .L366
	move.l %d0,sfu_x+6422
.L366:
	movem.l (%sp),#7228
	lea (32,%sp),%sp
	rts
.L399:
	move.w #53,%a1
	mov3q.l #-1,%d0
	jra .L369
.L400:
	move.w #56,%a1
	mov3q.l #1,%d0
	jra .L369
.L371:
	move.l #l_sfx1,%d5
	move.l %d5,1075575832
	move.l #s_sfx1,%d0
	jra .L373
.L370:
	move.l %d1,%a4
	subq.l #2,%a4
	move.l %a4,%d3
	mov3q.l #6,%d4
	rems.l %d4,%d5:%d3
	move.l %d5,%a1
	tst.l %d0
	jeq .L401
	lea l_fx2,%a4
.L374:
	move.l %a4,40(%a0)
	tst.l %a1
	jeq .L375
	mov3q.l #1,%d3
	cmp.l %a1,%d3
	jne .L376
	move.l #s_route,%d0
	jra .L373
.L401:
	lea l_fx1,%a4
	jra .L374
.L376:
	lea -10(%a1,%a1.l*4),%a1
	mulu.w #20,%d0
	add.l %a1,%d0
	add.l #sfu_x+2092,%d0
	jra .L373
.L375:
	move.l #s_type,%d0
	jra .L373
.L402:
	mvz.w #410,%d0
	jra .L377
.L384:
	move.b (%a0)+,%d2
	addq.l #1,%d0
	move.b %d2,135(%a0)
	jra .L383
.L389:
	move.b (%a1)+,%d2
	addq.l #1,%d1
	move.b %d2,135(%a1)
	jra .L387
.L390:
	move.l sfu_x+2084,%d3
	cmp.l sfu_x+2080.l,%d3
	jeq .L391
	lea sfu_x+2080,%a0
	move.l (%a0),sfu_x+2084
	jsr relabel
	moveq #1,%d0
	move.b %d0,32(%a2)
	jra .L391
.L393:
	mvz.w #4027,%d5
	cmp.l 1094562392.l,%d5
	jlt .L394
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L395:
	tst.l %a0
	jeq .L394
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L395
	pea (m.0)
	mov3q.l #7,-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	clr.w %d1
	addq.l #1,sfu_x+2152
	move.w %d1,sfu_st+1028
	jra .L368
.L394:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #1,sfu_x+2156
	addq.l #4,%sp
	jra .L368
	.size	sfu_tick, .-sfu_tick
	.text
	.type	m.0, @object
	.size	m.0, 7
m.0:
	.base64	"8H1SVCMB9w=="
	.globl	sfu_x
	.section	.bss
	.align	2
	.type	sfu_x, @object
	.size	sfu_x, 6684
sfu_x:
	.zero	6684
	.globl	sfu_st
	.text
	.align	2
	.type	sfu_st, @object
	.size	sfu_st, 1038
sfu_st:
	.string	"OFF"
	.zero	4
	.string	"CHORUS"
	.zero	1
	.string	"COMB"
	.zero	3
	.string	"DELAY"
	.zero	2
	.string	"PINGPNG"
	.string	"TAPEDLY"
	.string	"RINGS"
	.zero	2
	.string	"S4 RESO"
	.string	"CLDSEED"
	.string	"PLASMA"
	.zero	1
	.string	"PLATE"
	.zero	2
	.string	"HALL"
	.zero	3
	.string	"SHIMMER"
	.string	"FLANGER"
	.string	"PHASER"
	.zero	1
	.zero	904
	.ascii	"\377\377"
	.byte	0
	.byte	0
	.word	0
	.long	0
	.long	0
	.globl	sfu_vec_rev
	.text
	.align	2
	.type	sfu_vec_rev, @object
	.size	sfu_vec_rev, 8
sfu_vec_rev:
	.long	9
	.long	14
	.globl	sfu_vec_del
	.align	2
	.type	sfu_vec_del, @object
	.size	sfu_vec_del, 8
sfu_vec_del:
	.long	8
	.long	13
	.globl	sfu_vec_amp
	.align	2
	.type	sfu_vec_amp, @object
	.size	sfu_vec_amp, 8
sfu_vec_amp:
	.long	7
	.long	12
	.globl	sfu_pages
	.align	2
	.type	sfu_pages, @object
	.size	sfu_pages, 108
sfu_pages:
	.long	n_amp2
	.long	14
	.long	15
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	0
	.long	n_fx1
	.long	16
	.long	17
	.long	18
	.long	19
	.long	20
	.long	21
	.long	0
	.long	0
	.long	n_fx2
	.long	22
	.long	23
	.long	24
	.long	25
	.long	26
	.long	27
	.long	0
	.long	0
	.type	n_fx2, @object
	.size	n_fx2, 10
n_fx2:
	.string	"SEND FX 2"
	.type	n_fx1, @object
	.size	n_fx1, 10
n_fx1:
	.string	"SEND FX 1"
	.type	n_amp2, @object
	.size	n_amp2, 12
n_amp2:
	.string	"AMPLITUDE 2"
	.type	s_ufx, @object
	.size	s_ufx, 4
s_ufx:
	.string	"UFX"
	.type	s_fx, @object
	.size	s_fx, 3
s_fx:
	.string	"FX"
	.type	s_wide, @object
	.size	s_wide, 5
s_wide:
	.string	"XXXX"
	.type	fmt_d, @object
	.size	fmt_d, 5
fmt_d:
	.string	"%s%d"
	.type	fmt_bang, @object
	.size	fmt_bang, 4
fmt_bang:
	.string	"!%s"
	.type	fmt_s, @object
	.size	fmt_s, 3
fmt_s:
	.string	"%s"
	.type	s_empty, @object
	.size	s_empty, 1
s_empty:
	.zero	1
	.type	l_fx2, @object
	.size	l_fx2, 10
l_fx2:
	.string	"Send FX 2"
	.type	l_fx1, @object
	.size	l_fx1, 10
l_fx1:
	.string	"Send FX 1"
	.type	l_sfx2, @object
	.size	l_sfx2, 10
l_sfx2:
	.string	"Send FX 2"
	.type	l_sfx1, @object
	.size	l_sfx1, 10
l_sfx1:
	.string	"Send FX 1"
	.type	fmt_sn, @object
	.size	fmt_sn, 6
fmt_sn:
	.string	"%s %d"
	.type	fmt_n, @object
	.size	fmt_n, 5
fmt_n:
	.string	"%s%d"
	.type	s_post, @object
	.size	s_post, 5
s_post:
	.string	"POST"
	.type	s_pre, @object
	.size	s_pre, 4
s_pre:
	.string	"PRE"
	.type	s_route, @object
	.size	s_route, 5
s_route:
	.string	"ROUT"
	.type	s_type, @object
	.size	s_type, 5
s_type:
	.string	"TYPE"
	.type	s_sfx2, @object
	.size	s_sfx2, 5
s_sfx2:
	.string	"SFX2"
	.type	s_sfx1, @object
	.size	s_sfx1, 5
s_sfx1:
	.string	"SFX1"
	.type	k_cidx, @object
	.size	k_cidx, 14
k_cidx:
	.base64	"AAAdHSYmJycAACgoKSk="
	.ident	"GCC: (GNU) 16.2.0"
