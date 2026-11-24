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
	.type	lab_of, @function
lab_of:
	move.l %d2,-(%sp)
	move.l 8(%sp),%d1
	clr.l %d0
	addq.l #1,%d1
	lea sfu_x,%a0
.L125:
	mvz.b (%a0),%d2
	cmp.l %d2,%d1
	jne .L123
	mulu.w #130,%d0
	add.l #sfu_x,%d0
.L122:
	move.l (%sp)+,%d2
	rts
.L123:
	addq.l #1,%d0
	lea (130,%a0),%a0
	moveq #16,%d2
	cmp.l %d0,%d2
	jne .L125
	clr.l %d0
	jra .L122
	.size	lab_of, .-lab_of
	.align	2
	.type	ptext, @function
ptext:
	lea (-40,%sp),%sp
	movem.l #1276,(%sp)
	lea sfu_x,%a0
	move.l 44(%sp),%d3
	add.l %d3,%a0
	move.l 48(%sp),%d5
	move.l 56(%sp),%d4
	move.l 52(%sp),36(%sp)
	move.l 60(%sp),%d2
	mvz.b 2090(%a0),%d0
	move.l %d0,-(%sp)
	jsr lab_of
	addq.l #4,%sp
	lea sfu_x,%a1
	lea (%a1,%d3.l*4),%a0
	move.l %d4,%d1
	asr.l #8,%d1
	add.l %d5,%a0
	mvz.b 2460(%a0),%d7
	tst.l %d4
	jge .L128
	clr.l %d1
.L128:
	tst.l %d7
	jeq .L129
	cmp.l %d1,%d7
	jgt .L130
	move.l %d7,%d1
	subq.l #1,%d1
.L130:
	moveq #48,%d7
	muls.l %d7,%d3
	moveq #12,%d7
	muls.l %d5,%d7
	move.l %d7,%a0
	add.l %d3,%a0
	add.l #sfu_x,%a0
	add.l %d1,%a0
	mvz.b 2468(%a0),%d1
.L129:
	move.l %d1,%a0
	moveq #127,%d1
	cmp.l %a0,%d1
	jge .L131
	move.w #127,%a0
.L131:
	tst.l %d0
	jeq .L132
	move.l %d0,%a1
	clr.l %d1
	mvz.b 1(%a1),%d3
	lea (22,%a1),%a1
	move.l %d3,28(%sp)
	mov3q.l #-1,%d3
.L133:
	cmp.l 28(%sp),%d1
	jge .L135
	moveq #12,%d6
	cmp.l %d1,%d6
	jne .L136
.L135:
	mov3q.l #-1,%d7
	cmp.l %d3,%d7
	jeq .L132
	move.l %d3,%d1
	lsl.l #3,%d1
	add.l %d3,%d1
	move.l %d0,%d3
	add.l %d1,%d3
	move.l %d3,%a1
	move.l %d3,%a2
	mvz.b 23(%a1),%d4
	mvz.b 24(%a2),%d3
	move.l %a0,%a1
	sub.l %d4,%a1
	add.l %d3,%a1
	moveq #99,%d3
	cmp.l %a1,%d3
	jlt .L145
	moveq #9,%d6
	cmp.l %a1,%d6
	jge .L146
	mov3q.l #2,%d3
.L137:
	move.l %d0,%a0
	lea 25(%a0,%d1.l),%a0
	move.l %a0,%d4
	move.l %d0,%a0
	add.l %d1,%a0
	move.b 22(%a0),%d0
	move.w %d0,%ccr
	jne .L138
	clr.l %d0
.L139:
	tst.b 25(%a0,%d0.l)
	jeq .L140
	addq.l #1,%d0
	mov3q.l #5,%d1
	cmp.l %d0,%d1
	jne .L139
.L140:
	move.l %d3,%a2
	lea 1(%a2,%d0.l),%a0
	mov3q.l #7,%d0
	cmp.l %a0,%d0
	jlt .L147
	move.l #fmt_sn,%d0
.L142:
	move.l %a1,56(%sp)
	move.l %d4,52(%sp)
	move.l %d0,48(%sp)
.L160:
	move.l %d2,44(%sp)
	movem.l (%sp),#1276
	lea (40,%sp),%sp
	jmp 1074365954
.L136:
	move.b (%a1),%d6
	mov3q.l #3,%d7
	and.l %d7,%d6
	cmp.l %d6,%d5
	jne .L134
	mvz.b 1(%a1),%d6
	cmp.l %d6,%a0
	jlt .L134
	move.l %d1,%d3
.L134:
	addq.l #1,%d1
	lea (9,%a1),%a1
	jra .L133
.L145:
	mov3q.l #3,%d3
	jra .L137
.L146:
	mov3q.l #1,%d3
	jra .L137
.L138:
	move.l %d4,52(%sp)
	move.l %d2,44(%sp)
	movem.l (%sp),#1276
	lea fmt_s,%a1
	move.l %a1,48(%sp)
	lea (40,%sp),%sp
	jmp 1074365954
.L147:
	move.l #fmt_n,%d0
	jra .L142
.L132:
	move.l sfu_x+2136,%a1
	tst.l %a1
	jeq .L143
	move.l %d2,52(%sp)
	move.l %d4,48(%sp)
	movem.l (%sp),#1276
	move.l 36(%sp),44(%sp)
	lea (40,%sp),%sp
	jmp (%a1)
.L143:
	move.l #s_empty,%d3
	move.l #fmt_d,%d6
	move.l %a0,56(%sp)
	move.l %d3,52(%sp)
	move.l %d6,48(%sp)
	jra .L160
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
	.type	set_rec, @function
set_rec:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	moveq #52,%d2
	move.l 12(%sp),%d1
	move.l %d1,%d0
	add.l #14,%d0
	muls.l %d2,%d0
	mov3q.l #1,%d3
	move.l %d0,%a0
	add.l #1075575064,%a0
	cmp.l %d1,%d3
	jge .L178
	move.l %d1,%d0
	mov3q.l #6,%d2
	subq.l #2,%d0
	divs.l %d2,%d0
	tst.l %d0
	jne .L179
	move.w #57,%a1
.L170:
	move.l %a1,(%a0)
	lea k_cidx,%a1
	mvz.b (%a1,%d1.l),%d2
	mvz.w #32512,%d3
	clr.l 8(%a0)
	mov3q.l #1,20(%a0)
	move.l %d2,4(%a0)
	move.l %d3,12(%a0)
	clr.l 16(%a0)
	mov3q.l #-1,24(%a0)
	mov3q.l #-1,28(%a0)
	clr.l 36(%a0)
	mov3q.l #-1,%d2
	cmp.l %d0,%d2
	jne .L171
	tst.l %d1
	jeq .L172
	move.l #l_sfx2,%d3
	move.l %d3,40(%a0)
	move.l #s_sfx2,%d0
.L174:
	move.l (%sp)+,%d2
	move.l #s_empty,%d3
	move.l %d3,44(%a0)
	move.l %d0,48(%a0)
	move.l (%sp)+,%d3
	rts
.L178:
	move.w #53,%a1
	mov3q.l #-1,%d0
	jra .L170
.L179:
	move.w #56,%a1
	jra .L170
.L172:
	lea l_sfx1,%a1
	move.l %a1,1075575832
	move.l #s_sfx1,%d0
	jra .L174
.L171:
	subq.l #2,%d1
	mov3q.l #6,%d2
	rems.l %d2,%d3:%d1
	move.l %d3,%a1
	tst.l %d0
	jeq .L180
	move.l #l_fx2,%d1
.L175:
	move.l %d1,40(%a0)
	tst.l %a1
	jeq .L176
	mov3q.l #1,%d1
	cmp.l %a1,%d1
	jne .L177
	move.l #s_route,%d0
	jra .L174
.L180:
	move.l #l_fx1,%d1
	jra .L175
.L177:
	lea -10(%a1,%a1.l*4),%a1
	moveq #20,%d2
	muls.l %d2,%d0
	add.l %a1,%d0
	add.l #sfu_x+2092,%d0
	jra .L174
.L176:
	move.l #s_type,%d0
	jra .L174
	.size	set_rec, .-set_rec
	.align	2
	.type	set_bw_rec, @function
set_bw_rec:
	move.l %d2,-(%sp)
	moveq #52,%d2
	move.l 8(%sp),%d1
	move.l %d1,%d0
	addq.l #1,%d0
	muls.l %d2,%d0
	move.l %d0,%a0
	mov3q.l #1,%d0
	add.l #1075575064,%a0
	cmp.l %d1,%d0
	jlt .L186
	move.w #57,%a1
	moveq #29,%d0
.L182:
	move.l %d0,4(%a0)
	mov3q.l #1,%d0
	and.l %d1,%d0
	mvz.w #32512,%d2
	move.l %a1,(%a0)
	clr.l 8(%a0)
	move.l %d2,12(%a0)
	move.l %d0,%a1
	btst #0,%d1
	jeq .L187
	move.l %d2,%d0
.L183:
	move.l %d0,16(%a0)
	clr.l 20(%a0)
	mov3q.l #-1,24(%a0)
	mov3q.l #-1,28(%a0)
	clr.l 36(%a0)
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jlt .L188
	move.l #l_fx1,%d0
.L184:
	move.l %d0,40(%a0)
	move.l #s_empty,%d0
	move.l %d0,44(%a0)
	tst.l %a1
	jeq .L189
	move.l #s_wid,%d0
.L185:
	move.l %d0,48(%a0)
	move.l (%sp)+,%d2
	rts
.L186:
	move.w #56,%a1
	clr.l %d0
	jra .L182
.L187:
	clr.l %d0
	jra .L183
.L188:
	move.l #l_fx2,%d0
	jra .L184
.L189:
	move.l #s_base,%d0
	jra .L185
	.size	set_bw_rec, .-set_bw_rec
	.align	2
	.type	copy_desc, @function
copy_desc:
	move.l %a2,-(%sp)
	move.w 10(%sp),%d0
	sub.l %a0,%a0
	mulu.w #84,%d0
	move.l %d0,%a1
	add.l #1100630152,%a1
	move.w 14(%sp),%d0
	mulu.w #84,%d0
	add.l #1100630152,%d0
.L191:
	lea (%a0,%d0.l),%a2
	moveq #84,%d1
	move.l (%a2),(%a1,%a0.l)
	addq.l #4,%a0
	cmp.l %a0,%d1
	jne .L191
	move.l (%sp)+,%a2
	rts
	.size	copy_desc, .-copy_desc
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
	jeq .L200
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jge .L201
	subq.l #1,%d1
	lsl.l #8,%d1
	move.l #1100634268,%a2
.L194:
	moveq #52,%d2
	muls.l %d0,%d2
	move.l #1075575076,%a4
	move.l %a0,%a3
	add.l #sfu_x,%a3
	move.l %d1,(%a4,%d2.l)
	mvz.b 2564(%a3),%d1
	cmp.l %d1,%a1
	jeq .L193
	moveq #84,%d1
	muls.l %d1,%d0
	move.l %d0,%a0
	add.l #1100630152,%a0
	move.l (%a2),(%a0)
	move.l 4(%a2),4(%a0)
	move.l 8(%a2),8(%a0)
	move.l 16(%a2),16(%a0)
	tst.l %a1
	jne .L196
	move.l 1100664640,%d0
.L197:
	move.w %a1,%d1
	move.l %d0,48(%a0)
	move.b %d1,2564(%a3)
.L193:
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	rts
.L200:
	mvz.w #32512,%d1
	move.l #1100664592,%a2
	jra .L194
.L201:
	mvz.w #256,%d1
	move.l #1100634268,%a2
	jra .L194
.L196:
	mov3q.l #2,%d2
	cmp.l %a1,%d2
	jne .L198
	move.l 1100633980,%d0
	jra .L197
.L198:
	mov3q.l #3,%d0
	cmp.l %a1,%d0
	jne .L199
	move.l 1100637004,%d0
	jra .L197
.L199:
	move.l #sfu_draw,%d0
	jra .L197
	.size	set_look, .-set_look
	.align	2
	.type	restore_recs, @function
restore_recs:
	lea (-40,%sp),%sp
	movem.l #7420,(%sp)
	move.l 44(%sp),%d2
	move.w %d2,%d6
	muls.w #6,%d6
	move.l %d6,%d0
	addq.l #2,%d0
	move.l %d0,36(%sp)
	btst #0,%d2
	jeq .L203
	move.l #sfu_type2_text,%d7
.L204:
	move.w %d2,%d3
	mvz.w %d2,%d4
	clr.l %d5
	lea set_rec,%a4
	move.l #1100631360,%a3
	move.l %d4,%d0
	lsl.l #4,%d0
	mulu.w #6,%d3
	move.l %d0,%a2
	add.l #ptexts,%a2
	addq.l #2,%d3
.L207:
	move.l %d3,-(%sp)
	jsr (%a4)
	addq.l #4,%sp
	tst.l %d5
	jeq .L210
	mov3q.l #1,%d1
	cmp.l %d5,%d1
	jeq .L206
	move.l -8(%a2),%d0
.L205:
	moveq #84,%d1
	addq.l #1,%d5
	muls.l %d3,%d1
	addq.l #1,%d3
	addq.l #4,%a2
	move.l %d0,(%a3,%d1.l)
	mov3q.l #6,%d0
	cmp.l %d5,%d0
	jne .L207
	mvs.w %d2,%d3
	mov3q.l #2,-(%sp)
	mov3q.l #1,-(%sp)
	move.l 44(%sp),-(%sp)
	add.l %d3,%d3
	lea set_look,%a2
	addq.l #1,%d2
	jsr (%a2)
	mov3q.l #2,-(%sp)
	mov3q.l #3,-(%sp)
	mulu.w #36,%d2
	move.l %d6,%a0
	pea 3(%a0)
	jsr (%a2)
	lea set_bw_rec,%a2
	move.l %d3,-(%sp)
	jsr (%a2)
	move.l %d3,%a0
	pea 1(%a0)
	jsr (%a2)
	lea (32,%sp),%sp
	move.l %d4,%d0
	move.l %d2,%a0
	add.l %d0,%d0
	lsl.l #2,%d4
	add.l #sfu_pages+4,%a0
	move.l %d0,%a1
	clr.l %d0
	subq.l #5,%a1
.L209:
	mov3q.l #5,%d1
	cmp.l %d0,%d1
	jlt .L211
	lea 21(%a1,%d4.l),%a2
.L208:
	move.l %a2,(%a0)+
	moveq #8,%d1
	addq.l #1,%d0
	addq.l #1,%a1
	cmp.l %d0,%d1
	jne .L209
	movem.l (%sp),#7420
	lea (40,%sp),%sp
	rts
.L203:
	move.l #sfu_type1_text,%d7
	jra .L204
.L206:
	move.l #sfu_route_text,%d0
	jra .L205
.L210:
	move.l %d7,%d0
	jra .L205
.L211:
	move.l %a1,%a2
	jra .L208
	.size	restore_recs, .-restore_recs
	.text
.LC0:
	.string	"ON"
.LC1:
	.string	"OFF"
	.text
	.align	2
	.type	relabel, @function
relabel:
	lea (-108,%sp),%sp
	movem.l #31996,(%sp)
	lea sfu_p+4240,%a2
	mov3q.l #1,%d2
	lea sfu_p+4706,%a6
	clr.l %d4
	move.l #sfu_pages+36,%d3
	move.l %a2,%a3
	lea sfu_x+2087,%a4
.L225:
	mvz.b (%a4,%d2.l),%d0
	move.l %d0,-(%sp)
	jsr lab_of
	addq.l #4,%sp
	tst.l %d0
	jne .L215
.L217:
	clr.b %d1
	moveq #1,%d0
.L216:
	move.b %d1,4(%a3)
	move.b %d0,2(%a3)
	mvz.b %d0,%d0
	mvz.b (%a3),%d1
	cmp.l %d0,%d1
	jcs .L218
	clr.b (%a3)
	move.l %d4,-(%sp)
	jsr restore_recs
	addq.l #4,%sp
.L218:
	mvz.b 2(%a3),%d0
	lsr.l #1,%d0
	jeq .L219
	tst.l %d4
	jeq .L270
	move.l #n_fx2,%d1
.L220:
	move.l %a6,%a1
	sub.l %a0,%a0
.L221:
	move.b (%a0,%d1.l),%d0
	jne .L222
	move.b #32,(%a1)
	moveq #47,%d5
	clr.b %d7
	move.b (%a3),%d0
	move.b %d5,2(%a6,%a0.l)
	add.l #49,%d0
	move.b %d0,1(%a0,%a6.l)
	move.b 2(%a3),%d0
	move.b %d7,4(%a6,%a0.l)
	add.l #48,%d0
	move.b %d0,3(%a6,%a0.l)
	move.l %d3,%a0
	move.l %a6,(%a0)
.L223:
	addq.l #1,%d4
	addq.l #1,%a3
	lea (16,%a6),%a6
	add.l #36,%d3
	subq.l #2,%d2
	tst.l %d2
	jne .L272
	lea sfu_x+2088,%a0
	moveq #18,%d1
	lea sfu_x+2460,%a1
	clr.l %d6
	move.l %a0,48(%sp)
	move.l %a1,56(%sp)
	lea sfu_pages+40,%a6
	lea sfu_p+4434,%a0
	lea sfu_p+4354,%a1
	move.l %a6,60(%sp)
	move.l %a0,64(%sp)
	move.l %a1,76(%sp)
	clr.l 52(%sp)
	clr.l 68(%sp)
	move.l %d1,72(%sp)
.L268:
	move.l 48(%sp),%a0
	addq.l #1,48(%sp)
	mvz.b (%a0)+,%d0
	move.l %d0,-(%sp)
	jsr lab_of
	addq.l #4,%sp
	move.l #-1057222719,%d1
	move.l %d0,%a5
	sub.l #sfu_x,%d0
	asr.l #1,%d0
	muls.l %d1,%d0
	mov3q.l #1,%d1
	lsl.l %d0,%d1
	move.l %d1,88(%sp)
	tst.l %d6
	jeq .L226
	lea l_fx2,%a0
	move.l %a0,80(%sp)
.L227:
	sub.l %d6,%d0
	moveq #68,%d1
	moveq #48,%d3
	muls.l %d0,%d1
	muls.l %d6,%d3
	move.l 52(%sp),%a3
	clr.l %d2
	move.l 72(%sp),%d7
	add.l #sfu_x+7796,%a3
	move.l 68(%sp),%a4
	add.l #-14,%d7
	add.l #sfu_x+2092,%a4
	move.l %d1,84(%sp)
	move.l %d3,104(%sp)
.L252:
	clr.b (%a3)
	tst.l %a5
	jeq .L228
	sub.l %a0,%a0
	move.w %d2,%d0
	mulu.w #5,%d0
	lea (%a5,%d0.l),%a1
.L229:
	move.b 2(%a1,%a0.l),%d0
	jeq .L230
	move.b %d0,(%a4,%a0.l)
	addq.l #1,%a0
	mov3q.l #4,%d4
	cmp.l %a0,%d4
	jne .L229
.L230:
	clr.b %d5
	move.b %d5,(%a4,%a0.l)
	mvz.w sfu_x+7794,%d0
	and.l 88(%sp),%d0
	tst.l %d0
	jeq .L232
	move.l 84(%sp),%a1
	sub.l %a0,%a0
	lea (-1090,%a1),%a1
	add.l %a3,%a1
.L233:
	move.b (%a1,%a0.l),%d0
	move.b %d0,(%a3,%a0.l)
	jeq .L232
	addq.l #1,%a0
	moveq #17,%d0
	cmp.l %a0,%d0
	jne .L233
.L232:
	moveq #12,%d0
	clr.l %d4
	muls.l %d2,%d0
	lea (22,%a5),%a1
	sub.l %a0,%a0
	clr.l %d1
	add.l 104(%sp),%d0
	add.l #sfu_x,%d0
.L234:
	mvz.b 1(%a5),%d3
	cmp.l %d3,%d1
	jge .L236
	moveq #12,%d3
	cmp.l %d1,%d3
	jne .L237
.L236:
	tst.l %d4
	jeq .L311
	mov3q.l #1,%d5
	cmp.l %a0,%d5
	jge .L311
.L238:
	clr.b %d0
	move.w %a0,%d1
	move.l 56(%sp),%a1
	move.l %a2,100(%sp)
	move.b %d0,16(%a3)
	move.b %d1,(%a1,%d2.l)
	tst.b (%a2)
	jne .L240
	tst.b (%a3)
	jeq .L274
	move.l %a3,%d0
.L241:
	moveq #52,%d1
	muls.l %d7,%d1
	move.l #1075575832,%a6
	move.l %d0,(%a6,%d1.l)
	tst.l %a0
	jeq .L275
	mov3q.l #2,%d0
	cmp.l %a0,%d0
	jne .L276
	lea (22,%a5),%a1
	clr.l %d0
	mvz.b 1(%a5),%d1
	move.l %d1,96(%sp)
	clr.l %d1
.L243:
	cmp.l 96(%sp),%d0
	jge .L250
	moveq #12,%d4
	cmp.l %d0,%d4
	jne .L251
.L250:
	mov3q.l #2,%d5
	cmp.l %d1,%d5
	seq %d1
	mvs.b %d1,%d1
	neg.l %d1
	jra .L248
.L272:
	mov3q.l #2,%d2
	jra .L225
.L215:
	sub.l #sfu_x,%d0
	jmi .L217
	asr.l #1,%d0
	move.l #-1057222719,%d1
	muls.l %d1,%d0
	mvz.w sfu_x+7794,%d1
	btst %d0,%d1
	jeq .L217
	move.l %d0,%a0
	add.l #sfu_p,%a0
	move.b 4224(%a0),%d0
	mov3q.l #4,%d5
	mvz.b %d0,%d1
	cmp.l %d1,%d5
	jcc .L217
	subq.l #4,%d0
	move.b %d0,%d1
	mvz.b %d0,%d0
	moveq #8,%d7
	cmp.l %d0,%d7
	scc %d0
	addq.l #3,%d0
	jra .L216
.L270:
	move.l #n_fx1,%d1
	jra .L220
.L222:
	move.b %d0,(%a1)+
	addq.l #1,%a0
	jra .L221
.L219:
	tst.l %d4
	jeq .L271
	move.l #n_fx2,%d0
.L224:
	move.l %d3,%a1
	move.l %d0,(%a1)
	jra .L223
.L271:
	move.l #n_fx1,%d0
	jra .L224
.L282:
	mov3q.l #1,%d6
	jra .L268
.L226:
	lea l_fx1,%a1
	move.l %a1,80(%sp)
	jra .L227
.L237:
	move.b (%a1),%d3
	mov3q.l #3,%d5
	and.l %d3,%d5
	cmp.l %d5,%d2
	jne .L235
	moveq #8,%d5
	and.l %d5,%d3
	lea (%a0,%d0.l),%a6
	addq.l #1,%a0
	move.b 1(%a1),2468(%a6)
	or.l %d3,%d4
.L235:
	addq.l #1,%d1
	lea (9,%a1),%a1
	jra .L234
.L228:
	clr.b %d4
	move.l %d2,%d0
	add.l #50,%d0
	move.b #80,(%a4)
	move.b %d0,1(%a4)
	move.b %d4,2(%a4)
.L311:
	sub.l %a0,%a0
	jra .L238
.L274:
	move.l 80(%sp),%d0
	jra .L241
.L251:
	move.b (%a1),%d3
	mov3q.l #3,%d4
	and.l %d4,%d3
	cmp.l %d3,%d2
	jne .L244
	lea (3,%a1),%a6
	move.l %a6,92(%sp)
	tst.l %d1
	jeq .L277
	lea .LC0,%a6
.L312:
	move.l %a6,44(%sp)
	clr.l %d5
.L247:
	move.l 44(%sp),%a6
	move.b (%a6,%d5.l),%d4
	move.l 92(%sp),%a6
	move.b (%a6,%d5.l),%d3
	tst.b %d4
	jeq .L246
	mvs.b %d4,%d4
	mvs.b %d3,%d3
	addq.l #1,%d5
	cmp.l %d4,%d3
	jeq .L247
.L249:
	clr.l %d1
.L248:
	addq.l #1,%d1
.L242:
	move.l %a0,-(%sp)
	move.l %d1,-(%sp)
	move.l %d7,-(%sp)
	jsr set_look
	lea (12,%sp),%sp
.L240:
	addq.l #1,%d2
	lea (17,%a3),%a3
	addq.l #1,%d7
	addq.l #5,%a4
	mov3q.l #4,%d0
	cmp.l %d2,%d0
	jne .L252
	move.l 48(%sp),%a0
	addq.l #1,%a2
	move.l 100(%sp),%a1
	move.b -1(%a0),%d0
	move.b %d0,1(%a0)
	tst.b (%a1)
	jeq .L253
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	jsr lab_of
	addq.l #4,%sp
	tst.l %d0
	jeq .L278
	sub.l #sfu_x,%d0
	move.l %d0,%d1
	asr.l #1,%d1
	move.l #-1057222719,%d2
	muls.l %d2,%d1
	tst.l %d0
	jlt .L279
	mvz.w sfu_x+7794,%d3
	mov3q.l #1,%d4
	asr.l %d1,%d3
	and.l %d4,%d3
.L254:
	move.l %d6,%d0
	move.l %d6,%d5
	add.l %d0,%d0
	lsl.l #2,%d5
	moveq #60,%d7
	muls.l %d1,%d7
	move.l 76(%sp),%a3
	move.l 64(%sp),%a4
	move.l 60(%sp),%a6
	move.l %d0,%a5
	subq.l #5,%a5
	mvz.w #204,%d0
	move.l %d5,92(%sp)
	move.l %d7,84(%sp)
	clr.l %d5
	muls.l %d1,%d0
	move.l %d0,88(%sp)
.L267:
	mov3q.l #5,%d1
	cmp.l %d5,%d1
	jlt .L280
	move.l 92(%sp),%a0
	lea 21(%a5,%a0.l),%a0
	move.l %a0,%d4
.L255:
	mvz.b -1(%a2),%d0
	clr.b (%a4)
	clr.b (%a3)
	move.l %d4,100(%sp)
	subq.l #1,%d0
	lsl.l #3,%d0
	move.l %d0,%d2
	add.l %d5,%d2
	move.w %d4,%d0
	mulu.w #52,%d0
	move.l %d0,%a0
	add.l #1075575064,%a0
	tst.l %d3
	jeq .L256
	mvz.b 3(%a2),%d0
	cmp.l %d2,%d0
	jle .L257
	move.l %d2,%a1
	lea (%a1,%d2.l*4),%a1
	move.l %a1,%d0
	sub.l %a1,%a1
	add.l 84(%sp),%d0
	add.l #sfu_p,%d0
.L258:
	move.b (%a1,%d0.l),%d1
	jeq .L259
	move.b %d1,(%a3,%a1.l)
	addq.l #1,%a1
	mov3q.l #4,%d1
	cmp.l %a1,%d1
	jne .L258
.L259:
	move.l %d2,%d0
	lsl.l #4,%d0
	clr.b %d7
	add.l %d2,%d0
	add.l 88(%sp),%d0
	move.b %d7,(%a3,%a1.l)
	sub.l %a1,%a1
	add.l #sfu_p+960,%d0
.L261:
	move.b (%a1,%d0.l),%d1
	jeq .L262
	move.b %d1,(%a4,%a1.l)
	addq.l #1,%a1
	moveq #16,%d1
	cmp.l %a1,%d1
	jne .L261
.L262:
	clr.b %d7
	move.b %d7,(%a4,%a1.l)
.L256:
	mvz.b 3(%a2),%d0
	cmp.l %d2,%d0
	jle .L257
	tst.b (%a3)
	jne .L257
	move.l %d2,%a1
	addq.l #5,%a1
	moveq #10,%d1
	move.l %a1,%d0
	rems.l %d1,%d7:%d0
	divs.l %d1,%d0
	move.b #80,(%a3)
	move.l %d0,96(%sp)
	add.l #48,%d0
	move.b %d0,1(%a3)
	clr.b %d0
	move.l %d7,%d1
	add.l #48,%d1
	move.b %d1,2(%a3)
	move.b %d0,3(%a3)
.L257:
	move.l %a3,48(%a0)
	tst.b (%a4)
	jeq .L281
	move.l %a4,%d0
.L264:
	mvz.w #32512,%d1
	move.l %d0,40(%a0)
	clr.l 16(%a0)
	mov3q.l #5,%d7
	move.l %d1,12(%a0)
	cmp.l %d5,%d7
	jlt .L265
	clr.l -(%sp)
	move.l %d4,%a0
	clr.l -(%sp)
	mulu.w #84,%d4
	pea -14(%a0)
	jsr set_look
	lea (12,%sp),%sp
	lea sfu_x+2136,%a0
	move.l #1100630184,%a1
	move.l (%a0),(%a1,%d4.l)
.L265:
	mvz.b 3(%a2),%d0
	cmp.l %d2,%d0
	jgt .L266
	clr.l 100(%sp)
.L266:
	move.l 100(%sp),(%a6)+
	addq.l #1,%d5
	lea (17,%a4),%a4
	addq.l #5,%a3
	addq.l #1,%a5
	moveq #8,%d0
	cmp.l %d5,%d0
	jne .L267
.L253:
	mvz.w #136,%d4
	moveq #20,%d1
	moveq #68,%d2
	moveq #36,%d3
	moveq #40,%d5
	addq.l #4,56(%sp)
	addq.l #6,72(%sp)
	add.l %d1,68(%sp)
	add.l %d2,52(%sp)
	subq.l #1,%d6
	add.l %d3,60(%sp)
	add.l %d4,64(%sp)
	add.l %d5,76(%sp)
	tst.l %d6
	jne .L282
	movem.l (%sp),#31996
	addq.l #1,sfu_x+2160
	lea (108,%sp),%sp
	rts
.L277:
	lea .LC1,%a6
	jra .L312
.L246:
	tst.b %d3
	jne .L249
	addq.l #1,%d1
	mov3q.l #2,%d3
	cmp.l %d1,%d3
	jlt .L249
.L244:
	addq.l #1,%d0
	lea (9,%a1),%a1
	jra .L243
.L275:
	clr.l %d1
	jra .L242
.L276:
	mov3q.l #1,%d1
	jra .L242
.L278:
	mov3q.l #-1,%d1
.L279:
	clr.l %d3
	jra .L254
.L280:
	move.l %a5,%d4
	jra .L255
.L281:
	move.l 80(%sp),%d0
	jra .L264
	.size	relabel, .-relabel
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
	jcs .L314
	moveq #84,%d0
	muls.l %d0,%d1
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	add.l #1100630172,%d1
	move.l %d1,-(%sp)
	jsr xname
.L320:
	lea (12,%sp),%sp
.L315:
	clr.b %d0
	move.b %d0,24(%sp)
	tst.b 16(%sp)
	jeq .L319
	move.l %a6,%d2
.L318:
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
.L314:
	add.l #-16,%d1
	moveq #11,%d2
	cmp.l %d1,%d2
	jcs .L315
	mov3q.l #6,%d3
	rems.l %d3,%d2:%d1
	cmp.l #1847,%d0
	shi %d0
	move.l %d2,%a1
	mvs.b %d0,%d0
	neg.l %d0
	tst.l %d2
	jne .L316
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	move.l %d0,-(%sp)
	jsr type_text
	jra .L320
.L316:
	mov3q.l #1,%d3
	cmp.l %d2,%d3
	jne .L317
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	clr.l -(%sp)
	jsr sfu_route_text
	jra .L320
.L317:
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	clr.l -(%sp)
	pea -2(%a1)
	move.l %d0,-(%sp)
	jsr ptext
	lea (20,%sp),%sp
	jra .L315
.L319:
	move.l #s_wide,%d2
	jra .L318
	.size	sfu_draw, .-sfu_draw
	.align	2
	.type	pq, @function
pq:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	moveq #11,%d2
	move.l 12(%sp),%d0
	move.l %d0,%d1
	add.l #-16,%d1
	cmp.l %d1,%d2
	jcs .L322
	moveq #21,%d3
	mov3q.l #6,%d2
	cmp.l %d0,%d3
	slt %d0
	mvs.b %d0,%d0
	neg.l %d0
	move.l %d0,%a0
	move.l %d1,%d0
	rems.l %d2,%d3:%d0
	move.l %d3,%d1
.L323:
	move.l 16(%sp),%a1
	move.l %a0,(%a1)
	add.l #sfu_p,%a0
	move.b 4240(%a0),%d0
	jeq .L326
	mvz.b %d0,%d0
	subq.l #1,%d0
	lsl.l #3,%d0
	add.l %d1,%d0
	mvz.b 4244(%a0),%d1
	cmp.l %d1,%d0
	jlt .L321
	moveq #-2,%d0
	jra .L321
.L322:
	subq.l #1,%d0
	mov3q.l #3,%d1
	cmp.l %d0,%d1
	jcc .L324
.L326:
	mov3q.l #-1,%d0
.L321:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L324:
	move.l %d0,%d2
	mov3q.l #1,%d3
	and.l %d3,%d0
	asr.l #1,%d2
	move.l %d2,%a0
	move.l %d0,%d1
	addq.l #6,%d1
	jra .L323
	.size	pq, .-pq
	.align	2
	.type	try_send, @function
try_send:
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jeq .L332
.L338:
	clr.l %d0
.L331:
	rts
.L332:
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L334
	addq.l #1,sfu_x+2156
	jra .L331
.L334:
	mvz.w #4027,%d0
	cmp.l 1094562392.l,%d0
	jlt .L335
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L336:
	tst.l %a0
	jeq .L335
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L336
	move.l 4(%sp),-(%sp)
	move.l 12(%sp),-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	mov3q.l #1,%d0
	jra .L331
.L335:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #1,sfu_x+2156
	addq.l #4,%sp
	jra .L338
	.size	try_send, .-try_send
	.align	2
	.globl	sfu_sysex
	.type	sfu_sysex, @function
sfu_sysex:
	lea (-52,%sp),%sp
	move.l -66650100,%d1
	move.l 60(%sp),%d0
	movem.l #15612,(%sp)
	move.l 56(%sp),%a0
	moveq #10,%d2
	move.l %d1,44(%sp)
	cmp.l %d0,%d2
	jge .L345
	mvz.b 4(%a0),%d1
	moveq #34,%d3
	cmp.l %d1,%d3
	jne .L346
	mvz.b 5(%a0),%d1
	subq.l #3,%d1
	tst.l %d1
	jne .L347
	mvz.b 6(%a0),%d2
	mov3q.l #1,%d5
	cmp.l %d2,%d5
	jcs .L346
	mvz.b 7(%a0),%d3
	mov3q.l #4,%d7
	cmp.l %d3,%d7
	jcc .L346
	move.b 8(%a0),%d1
	jeq .L346
	mvz.b %d1,%d1
	moveq #17,%d4
	add.l %d1,%d3
	cmp.l %d3,%d4
	jlt .L346
	add.l #9,%d1
	cmp.l %d0,%d1
	jge .L346
	move.l %d2,%d0
	add.l #2135,%d0
	lea sfu_p,%a2
	tst.w (%a2,%d0.l*2)
	jne .L348
	lea (%a2,%d2.l*4),%a1
	move.l 4282(%a1),%d0
	tst.l %d0
	jeq .L419
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jhi .L419
.L348:
	addq.l #1,sfu_p+4294
.L353:
	mov3q.l #1,-(%sp)
	move.l 48(%sp),-(%sp)
	jsr timed
	movem.l 8(%sp),#15612
	mov3q.l #1,%d0
	lea (60,%sp),%sp
	rts
.L352:
	move.b 9(%a0,%a1.l),%d0
	mvz.b 7(%a0),%d3
	moveq #127,%d2
	lea -5(%a1,%d3.l),%a3
	and.l %d0,%d2
	add.l %a2,%a3
	mvz.b 4246(%a3),%d3
	cmp.l %d2,%d3
	jeq .L350
	move.b %d2,4246(%a3)
	mov3q.l #1,%d1
.L350:
	addq.l #1,%a1
.L351:
	mvz.b 8(%a0),%d0
	cmp.l %a1,%d0
	jgt .L352
	tst.l %d1
	jeq .L348
	moveq #1,%d0
	move.b %d0,sfu_p+4274
	jra .L348
.L419:
	moveq #12,%d7
	clr.l %d1
	muls.l %d7,%d2
	sub.l %a1,%a1
	add.l %d2,%a2
	jra .L351
.L345:
	moveq #10,%d1
	cmp.l %d0,%d1
	jne .L354
	mvz.b 4(%a0),%d1
	moveq #34,%d2
	cmp.l %d1,%d2
	jne .L346
.L347:
	mvz.b 5(%a0),%d1
	subq.l #2,%d1
	tst.l %d1
	jne .L346
	mvz.b 6(%a0),%d0
	mov3q.l #1,%d4
	cmp.l %d0,%d4
	jcs .L353
	mvz.b sfu_x+6688,%d1
	lea sfu_x,%a1
	btst %d0,%d1
	jne .L355
	lea (%a1,%d0.l*4),%a2
	move.l 6698(%a2),%d1
	tst.l %d1
	jeq .L356
	move.l -66650100,%d2
	sub.l %d1,%d2
	cmp.l #65999999,%d2
	jls .L355
.L356:
	move.b 7(%a0),%d1
	moveq #127,%d3
	moveq #127,%d5
	move.l %d0,%d2
	add.l #3342,%d2
	mvz.b (%a1,%d2.l*2),%d4
	and.l %d1,%d3
	cmp.l %d4,%d3
	jne .L357
	lea (%a1,%d0.l*2),%a2
	move.b 8(%a0),%d0
	mvz.b 6685(%a2),%d1
	and.l %d5,%d0
	cmp.l %d1,%d0
	jeq .L355
.L357:
	move.b %d3,(%a1,%d2.l*2)
	moveq #127,%d7
	mvz.b 6(%a0),%d0
	lea (%a1,%d0.l*2),%a1
	move.b 8(%a0),%d0
	and.l %d7,%d0
	move.b %d0,6685(%a1)
	moveq #1,%d0
	move.b %d0,sfu_x+6689
.L355:
	addq.l #1,sfu_x+6694
	jra .L353
.L354:
	mov3q.l #7,%d1
	cmp.l %d0,%d1
	jge .L353
.L346:
	mvz.b 5(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L353
	mvz.b 4(%a0),%d1
	moveq #33,%d3
	cmp.l %d1,%d3
	jne .L358
	addq.l #1,sfu_x+2320
	tst.b 6(%a0)
	jeq .L359
	clr.b %d4
	mov3q.l #1,sfu_x+2316
	lea sfu_st,%a1
	clr.l %d1
	move.b %d4,sfu_x+2188
.L360:
	clr.b (%a1)
	addq.l #1,%d1
	addq.l #8,%a1
	cmp.l #128,%d1
	jne .L360
	lea sfu_x,%a1
	clr.l %d1
.L361:
	clr.b (%a1)
	addq.l #1,%d1
	lea (130,%a1),%a1
	moveq #16,%d5
	cmp.l %d1,%d5
	jne .L361
	move.l #1330005504,%d7
	addq.l #1,sfu_x+2080
	move.l %d7,sfu_st
.L359:
	subq.l #1,%d0
	addq.l #8,%a0
	moveq #9,%d3
	lea sfu_st,%a3
	lea sfu_x+2188,%a4
.L362:
	move.l %d3,%d1
	add.l #12,%d1
	cmp.l %d0,%d1
	jlt .L371
	moveq #2,%d0
	addq.l #1,sfu_x+2596
	addq.l #1,sfu_x+2320
	move.b %d0,sfu_st+1027
	jra .L353
.L371:
	move.b (%a0),%d2
	jmi .L363
	move.b %d2,%d1
	sub.l %a2,%a2
	ext.w %d1
	mvz.w %d1,%d1
	lsl.l #3,%d1
	move.l %d1,%a1
	add.l #sfu_st,%a1
.L367:
	move.b 1(%a0,%a2.l),%d1
	moveq #94,%d5
	move.l %d1,%d4
	add.l #-32,%d4
	mvz.b %d4,%d4
	cmp.l %d4,%d5
	jcs .L364
	move.b %d1,(%a1,%a2.l)
.L365:
	addq.l #1,%a2
	mov3q.l #7,%d1
	cmp.l %a2,%d1
	jne .L367
	jra .L366
.L364:
	clr.b %d7
	move.b %d7,(%a1,%a2.l)
	tst.b %d1
	jne .L365
.L366:
	mvz.b %d2,%d4
	clr.b %d5
	sub.l %a1,%a1
	move.l %d4,%d1
	lsl.l #3,%d1
	move.b %d5,7(%a3,%d1.l)
	move.l sfu_x+2316,%d1
.L368:
	cmp.l %a1,%d1
	jle .L369
	mvz.b (%a4,%a1.l),%d5
	cmp.l %d4,%d5
	jne .L370
.L369:
	cmp.l %d1,%a1
	jne .L363
	cmp.l #128,%d1
	jeq .L363
	move.l %d1,%d7
	add.l #sfu_x,%d1
	move.l %d1,%a1
	addq.l #1,%d7
	move.b %d2,2188(%a1)
	move.l %d7,sfu_x+2316
.L363:
	lea (14,%a0),%a0
	add.l #14,%d3
	jra .L362
.L370:
	addq.l #1,%a1
	jra .L368
.L358:
	moveq #36,%d2
	cmp.l %d1,%d2
	jne .L372
	moveq #23,%d3
	cmp.l %d0,%d3
	jge .L373
	mov3q.l #7,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L373
	move.b 6(%a0),%d3
	moveq #127,%d4
	mvz.b %d3,%d1
	cmp.l %d1,%d4
	jge .L374
.L373:
	addq.l #1,sfu_x+2144
	jra .L353
.L374:
	lea sfu_x,%a2
	addq.l #1,%d1
	move.l %a2,%a3
	clr.l %d2
.L377:
	mvz.b (%a3),%d4
	move.l %a3,%a1
	cmp.l %d4,%d1
	jeq .L375
	sub.l %a1,%a1
.L375:
	addq.l #1,%d2
	moveq #16,%d5
	cmp.l %d2,%d5
	jeq .L421
	lea (130,%a3),%a3
	tst.l %a1
	jeq .L377
.L421:
	clr.l %d1
.L379:
	tst.l %a1
	jeq .L381
.L382:
	move.l %a1,%d1
	sub.l #sfu_x,%d1
	asr.l #1,%d1
	clr.b (%a1)
	move.l #-1057222719,%d2
	sub.l %a3,%a3
	move.l %a1,%a4
	muls.l %d2,%d1
	mov3q.l #1,%d2
	lsl.l %d1,%d2
	move.w sfu_x+7794,%d4
	move.l %d1,%a2
	add.l #sfu_p,%a2
	not.l %d2
	and.l %d4,%d2
	clr.b %d4
	move.w %d2,sfu_x+7794
	move.b %d4,4224(%a2)
.L383:
	mvz.w %a3,%d1
	sub.l %a2,%a2
	lea (%a0,%d1.l*4),%a5
.L385:
	move.b 7(%a5,%a2.l),%d2
	moveq #94,%d5
	move.l %d2,%d1
	add.l #-32,%d1
	mvz.b %d1,%d1
	cmp.l %d1,%d5
	jcs .L384
	move.b %d2,2(%a4,%a2.l)
	addq.l #1,%a2
	mov3q.l #4,%d7
	cmp.l %a2,%d7
	jne .L385
.L384:
	lea (%a3,%a3.l*4),%a5
	clr.b %d1
	addq.l #1,%a3
	addq.l #5,%a4
	mov3q.l #4,%d2
	add.l %a1,%a5
	move.b %d1,2(%a2,%a5.l)
	cmp.l %a3,%d2
	jne .L383
	moveq #127,%d4
	cmp.l %d0,%d4
	jlt .L422
	asr.l #3,%d0
	subq.l #3,%d0
.L387:
	lea (23,%a0),%a0
	clr.l %d1
	lea (22,%a1),%a2
.L388:
	cmp.l %d1,%d0
	jne .L391
	addq.l #1,%d3
	move.b %d1,1(%a1)
	move.b %d3,(%a1)
	addq.l #1,sfu_x+2148
.L471:
	addq.l #1,sfu_x+2080
	jra .L353
.L381:
	tst.b (%a2)
	jne .L378
	move.l %a2,%a1
.L378:
	addq.l #1,%d1
	lea (130,%a2),%a2
	moveq #16,%d7
	cmp.l %d1,%d7
	jne .L379
	tst.l %a1
	jne .L382
	jra .L373
.L422:
	moveq #12,%d0
	jra .L387
.L391:
	move.b (%a0),%d2
	moveq #15,%d5
	moveq #127,%d7
	sub.l %a3,%a3
	lea (-22,%a2),%a4
	and.l %d5,%d2
	move.b %d2,(%a2)
	move.b 1(%a0),%d2
	and.l %d7,%d2
	move.b %d2,1(%a2)
	move.b 2(%a0),%d2
	and.l %d7,%d2
	move.b %d2,2(%a2)
.L390:
	move.b 3(%a0,%a3.l),%d4
	moveq #94,%d5
	move.l %d4,%d2
	add.l #-32,%d2
	mvz.b %d2,%d2
	cmp.l %d2,%d5
	jcs .L389
	move.b %d4,25(%a4,%a3.l)
	addq.l #1,%a3
	mov3q.l #5,%d7
	cmp.l %a3,%d7
	jne .L390
.L389:
	move.l %d1,%d2
	addq.l #8,%a0
	lsl.l #3,%d2
	lea (9,%a2),%a2
	move.l %d2,%a4
	add.l %d1,%a4
	clr.b %d2
	add.l %a1,%a4
	addq.l #1,%d1
	move.b %d2,25(%a3,%a4.l)
	jra .L388
.L372:
	moveq #81,%d3
	cmp.l %d1,%d3
	jne .L392
	moveq #9,%d4
	cmp.l %d0,%d4
	jge .L393
	mvz.b 6(%a0),%d2
	moveq #127,%d5
	cmp.l %d2,%d5
	jlt .L393
	move.b 7(%a0),%d3
	jeq .L393
	move.b 8(%a0),%d1
	move.l %d1,%d4
	subq.l #1,%d4
	mvz.b %d4,%d4
	lsr.l #2,%d4
	jne .L393
	mvz.b %d1,%d4
	ext.w %d1
	move.l %d4,48(%sp)
	muls.w #20,%d1
	add.l #9,%d1
	cmp.l %d0,%d1
	jlt .L394
.L393:
	addq.l #1,sfu_x+7936
	jra .L353
.L394:
	addq.l #1,%d2
	lea sfu_x,%a1
	clr.l %d1
.L397:
	mvz.b (%a1),%d4
	move.l %a1,%d0
	cmp.l %d4,%d2
	jeq .L395
	clr.l %d0
.L395:
	addq.l #1,%d1
	moveq #16,%d5
	cmp.l %d1,%d5
	jeq .L396
	lea (130,%a1),%a1
	tst.l %d0
	jeq .L397
.L398:
	sub.l #sfu_x,%d0
	asr.l #1,%d0
	move.l #-1057222719,%d1
	mov3q.l #1,%d2
	move.w sfu_x+7794,%d5
	mvz.b %d3,%d3
	muls.l %d0,%d1
	move.l #1123299140,%d6
	move.l #991146300,%d7
	move.l %d3,%a1
	move.l #991146300,%d3
	muls.l %d0,%d3
	muls.l %d0,%d6
	muls.l %d0,%d7
	lsl.l %d1,%d2
	subq.l #1,%a1
	lea (13,%a0),%a0
	move.l %d3,%a4
	clr.l %d3
	add.l #sfu_x+6706,%d6
	move.l %d7,40(%sp)
	move.l %d2,%d4
	not.l %d4
	and.l %d5,%d4
	move.l #-925069876,%d5
	muls.l %d0,%d5
	add.l #sfu_p+892,%d5
	move.w %d4,sfu_x+7794
	move.l #sfu_p,%d4
	move.l %d4,%a3
	add.l %d4,%a4
	add.l %d1,%a3
.L411:
	moveq #15,%d0
	cmp.l %a1,%d0
	jlt .L399
	move.l %a1,%d1
	moveq #17,%d7
	muls.l %d7,%d1
	mov3q.l #3,%d0
	cmp.l %a1,%d0
	jlt .L400
	move.l %d6,%a2
.L470:
	add.l %d1,%a2
	clr.l %d1
.L403:
	move.b (%a0,%d1.l),%d7
	move.l %d7,%a5
	lea (-32,%a5),%a5
	move.w %a5,%d0
	mvz.b %d0,%d0
	move.l %d0,%a5
	moveq #94,%d0
	cmp.l %a5,%d0
	jcs .L404
	move.b %d7,(%a2,%d1.l)
	addq.l #1,%d1
	moveq #16,%d7
	cmp.l %d1,%d7
	jne .L403
.L404:
	tst.l %d1
	jeq .L424
	mvs.b -1(%a2,%d1.l),%d7
	move.l %d1,%a5
	moveq #32,%d0
	cmp.l %d7,%d0
	jeq .L406
.L405:
	clr.b %d1
	mov3q.l #3,%d7
	move.b %d1,(%a2,%a5.l)
	cmp.l %a1,%d7
	jge .L407
	lea (%a1,%a1.l*4),%a2
	clr.l %d1
	lea (%a2,%a4.l),%a5
.L409:
	move.b -4(%a0,%d1.l),%d7
	move.l %d7,%a2
	lea (-32,%a2),%a2
	move.w %a2,%d0
	mvz.b %d0,%d0
	move.l %d0,%a2
	moveq #94,%d0
	cmp.l %a2,%d0
	jcs .L408
	move.b %d7,-20(%a5,%d1.l)
	addq.l #1,%d1
	mov3q.l #4,%d7
	cmp.l %d1,%d7
	jne .L409
.L408:
	lea -20(%a1,%a1.l*4),%a2
	clr.b %d0
	add.l 40(%sp),%a2
	add.l %d4,%a2
	move.b %d0,(%a2,%d1.l)
.L407:
	mvz.b 4224(%a3),%d1
	move.l %d1,%a2
	move.l %a1,%d1
	addq.l #1,%d1
	cmp.l %a2,%a1
	jlt .L410
	move.b %d1,4224(%a3)
.L410:
	addq.l #1,%d3
	move.l %d1,%a1
	lea (20,%a0),%a0
	cmp.l 48(%sp),%d3
	jlt .L411
.L399:
	move.w sfu_x+7794,%d0
	addq.l #1,sfu_x+7932
	or.l %d0,%d2
	move.w %d2,sfu_x+7794
	jra .L471
.L396:
	tst.l %d0
	jne .L398
	jra .L393
.L400:
	move.l %d5,%a2
	jra .L470
.L406:
	subq.l #1,%d1
	jra .L404
.L424:
	sub.l %a5,%a5
	jra .L405
.L392:
	moveq #34,%d2
	cmp.l %d1,%d2
	jne .L353
	moveq #8,%d3
	cmp.l %d0,%d3
	jeq .L353
	mvz.b 6(%a0),%d2
	mov3q.l #1,%d4
	cmp.l %d2,%d4
	jcs .L353
	mvz.b 8(%a0),%d3
	move.b 7(%a0),%d1
	subq.l #3,%d3
	tst.l %d3
	jne .L425
	move.b %d1,%d3
.L412:
	lea sfu_st,%a3
	lea (%a3,%d2.l),%a1
	move.b %d3,1024(%a1)
	mvz.b 8(%a0),%d2
	subq.l #3,%d2
	tst.l %d2
	jne .L353
	tst.b %d1
	jlt .L353
	mvz.b %d1,%d2
	lsl.l #3,%d2
	tst.b (%a3,%d2.l)
	jne .L353
	ext.w %d1
	subq.l #1,%d0
	sub.l %a2,%a2
	mvz.w %d1,%d1
	lsl.l #3,%d1
	lea (%a3,%d1.l),%a1
	moveq #9,%d1
.L413:
	cmp.l %d0,%d1
	jge .L415
	move.b (%a0,%d1.l),%d4
	moveq #94,%d5
	move.l %d4,%d3
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcs .L415
	move.b %d4,(%a1,%a2.l)
	addq.l #1,%a2
	addq.l #1,%d1
	mov3q.l #7,%d7
	cmp.l %a2,%d7
	jne .L413
.L415:
	clr.b %d0
	add.l %d2,%a3
	move.b %d0,(%a3,%a2.l)
	jra .L353
.L425:
	st %d3
	jra .L412
	.size	sfu_sysex, .-sfu_sysex
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
	jne .L473
	mvz.b sfu_x+2090,%d0
	cmp.l %d0,%d3
	jne .L473
	mvz.b sfu_x+2091,%d0
	cmp.l %d0,%d2
	jeq .L474
.L473:
	lea sfu_x+2080,%a0
	move.l (%a0),sfu_x+2084
	jsr relabel
.L474:
	tst.b sfu_p+4240.l
	jne .L475
	move.l %d3,-(%sp)
	clr.l -(%sp)
	jsr tcache
	move.b sfu_x+2580,%d0
	addq.l #8,%sp
	move.l sfu_x+2452,%d1
	not.l %d0
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	sub.l %d0,%d1
	lsl.l #8,%d1
	add.l #-256,%d1
	move.l %d1,1075575908
.L475:
	tst.b sfu_p+4241.l
	jne .L472
	move.l %d2,-(%sp)
	mov3q.l #1,-(%sp)
	jsr tcache
	move.b sfu_x+2581,%d0
	addq.l #8,%sp
	move.l sfu_x+2452,%d1
	not.l %d0
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	sub.l %d0,%d1
	lsl.l #8,%d1
	add.l #-256,%d1
	move.l %d1,1075576220
.L472:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
	.size	sync, .-sync
	.align	2
	.globl	sfu_isext
	.type	sfu_isext, @function
sfu_isext:
	move.l %d2,-(%sp)
	move.l 8(%sp),%d0
	move.l %d0,%d1
	subq.l #1,%d1
	lsr.l #2,%d1
	jeq .L479
	move.l %d0,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L477:
	move.l (%sp)+,%d2
	rts
.L479:
	mov3q.l #1,%d0
	jra .L477
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
	jcs .L481
	btst #0,%d0
	jeq .L482
	lsl.l #7,%d2
.L482:
	and.l #32512,%d2
.L480:
	move.l %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L481:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L480
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
	link.w %fp,#-8
	move.l 12(%fp),%d1
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	pea -4(%fp)
	move.l %d1,-(%sp)
	move.l %d1,-8(%fp)
	mov3q.l #-1,%d2
	move.l 8(%fp),%d3
	jsr pq
	addq.l #8,%sp
	cmp.l %d0,%d2
	jeq .L488
	tst.l %d0
	jlt .L494
	move.l -4(%fp),%d1
	moveq #12,%d2
	muls.l %d2,%d1
	add.l %d1,%d0
	move.l %d0,%a0
	add.l #sfu_p+4246,%a0
.L495:
	mvz.b (%a0),%d2
	lsl.l #8,%d2
.L487:
	move.l %d2,%d0
	move.l -16(%fp),%d2
	move.l -12(%fp),%d3
	unlk %fp
	rts
.L488:
	move.l -8(%fp),%d0
	mov3q.l #3,%d1
	subq.l #1,%d0
	cmp.l %d0,%d1
	jcs .L490
	add.l #sfu_x+6684,%d0
	move.l %d0,%a0
	jra .L495
.L490:
	move.l -8(%fp),-(%sp)
	move.l %d3,-(%sp)
	jsr 1074433680
	move.l %d3,-(%sp)
	move.l %d0,%d2
	jsr see_fxset
	lea (12,%sp),%sp
	move.l -8(%fp),%d1
	add.l #-14,%d1
	move.l %d1,-8(%fp)
	moveq #13,%d0
	cmp.l %d1,%d0
	jcs .L487
	tst.b sfu_st+1026.l
	jeq .L491
	move.l %d3,-(%sp)
	jsr sync
	addq.l #4,%sp
.L491:
	move.l -8(%fp),%d1
	btst #0,%d1
	jeq .L492
	lsl.l #7,%d2
.L492:
	and.l #32512,%d2
	move.l -12(%fp),%d3
	move.l -8(%fp),8(%fp)
	move.l %d2,12(%fp)
	move.l -16(%fp),%d2
	unlk %fp
	jra to_knob
.L494:
	clr.l %d2
	jra .L487
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
	jcs .L497
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
.L498:
	move.l %d2,36(%sp)
	move.l %d3,32(%sp)
	move.l %d5,28(%sp)
	movem.l (%sp),#60
	move.l 20(%sp),44(%sp)
	move.l 16(%sp),40(%sp)
	lea (24,%sp),%sp
	jmp 1074438046
.L497:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L498
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
	jeq .L498
	tst.l %d4
	jlt .L498
	and.l #32512,%d2
	and.l #224,%d4
	or.l %d4,%d2
	jra .L498
	.size	sfu_s_write, .-sfu_s_write
	.align	2
	.globl	sfu_f_write
	.type	sfu_f_write, @function
sfu_f_write:
	link.w %fp,#-36
	move.l 20(%fp),-12(%fp)
	movem.l #1084,(%sp)
	move.l 12(%fp),%d3
	pea -4(%fp)
	move.l %d3,-(%sp)
	move.l 8(%fp),%a2
	move.l 16(%fp),%d2
	move.l 24(%fp),-8(%fp)
	jsr pq
	addq.l #8,%sp
	mov3q.l #-1,%d1
	cmp.l %d0,%d1
	jeq .L505
	tst.l %d0
	jlt .L509
	asr.l #8,%d2
	moveq #127,%d5
	cmp.l %d2,%d5
	jge .L507
	moveq #127,%d2
.L508:
	move.l -4(%fp),%d3
	moveq #12,%d1
	lea sfu_p,%a1
	muls.l %d3,%d1
	lea (%a1,%d1.l),%a0
	add.l %d0,%a0
	mvz.b 4246(%a0),%d1
	cmp.l %d1,%d2
	jeq .L509
	move.b %d2,4246(%a0)
	mov3q.l #1,%d2
	lsl.l %d0,%d2
	move.l %d3,%d1
	add.l #2135,%d1
	move.w (%a1,%d1.l*2),%d0
	or.l %d0,%d2
	move.w %d2,(%a1,%d1.l*2)
.L509:
	movem.l -36(%fp),#1084
	mov3q.l #1,%d0
	unlk %fp
	rts
.L507:
	tst.l %d2
	jge .L508
	clr.l %d2
	jra .L508
.L505:
	move.l %d3,%d0
	mov3q.l #3,%d1
	subq.l #1,%d0
	cmp.l %d0,%d1
	jcs .L510
	asr.l #8,%d2
	moveq #127,%d5
	cmp.l %d2,%d5
	jge .L511
	moveq #127,%d2
.L512:
	move.l %d0,%d1
	move.l %d0,%a0
	add.l #sfu_x+6684,%a0
	mvz.b (%a0),%d0
	asr.l #1,%d1
	cmp.l %d0,%d2
	jeq .L509
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	move.b sfu_x+6688,%d1
	move.b %d2,(%a0)
	or.l %d1,%d0
	move.b %d0,sfu_x+6688
	jra .L509
.L511:
	tst.l %d2
	jge .L512
	clr.l %d2
	jra .L512
.L510:
	move.l %d3,%a0
	moveq #13,%d0
	lea (-14,%a0),%a0
	move.l %a0,-16(%fp)
	cmp.l %a0,%d0
	jcs .L513
	move.l -16(%fp),%d1
	lea k_cidx,%a0
	move.l %d3,-(%sp)
	mvz.b (%a0,%d1.l),%d4
	move.l %a2,-(%sp)
	jsr 1074433680
	move.l %a2,-(%sp)
	addq.l #1,sfu_st+1030
	move.l %d0,%d5
	jsr see_fxset
	move.l %d5,%d0
	asr.l #8,%d0
	moveq #127,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	move.l %d2,-(%sp)
	move.l -16(%fp),-(%sp)
	jsr to_half
	move.l %d0,-(%sp)
	move.l %d5,-(%sp)
	move.l -16(%fp),-(%sp)
	jsr merge
	lea (36,%sp),%sp
	mov3q.l #1,%d5
	move.l %d0,%d2
	cmp.l -16(%fp),%d5
	jge .L514
	move.l %d3,%d0
	mov3q.l #6,%d5
	add.l #-16,%d0
	rems.l %d5,%d1:%d0
	tst.l %d1
	jne .L514
	mov3q.l #7,%d1
	cmp.l -16(%fp),%d1
	slt %d0
	lea sfu_x,%a0
	mvs.b %d0,%d0
	sub.l %d0,%a0
	move.l %d2,%d0
	asr.l #8,%d0
	move.b %d0,2088(%a0)
.L514:
	moveq #37,%d5
	cmp.l %d4,%d5
	jge .L513
	move.l 20(%a2),%a0
	move.l (%a0),%a1
	move.l %a0,-(%sp)
	move.l 40(%a1),%a0
	jsr (%a0)
	addq.l #4,%sp
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
	jra .L509
.L513:
	move.l %d2,16(%fp)
	move.l %d3,12(%fp)
	move.l %a2,8(%fp)
	movem.l -36(%fp),#1084
	move.l -8(%fp),24(%fp)
	move.l -12(%fp),20(%fp)
	unlk %fp
	jmp 1074438172
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
	jcs .L516
	mov3q.l #6,%d4
	rems.l %d4,%d2:%d0
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jge .L522
.L516:
	move.l %a0,-(%sp)
	move.l %d3,-(%sp)
	move.l %d1,-(%sp)
	jsr 1074436168
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jlt .L515
	move.l %d3,%d0
	moveq #13,%d1
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcs .L519
	btst #0,%d0
	jeq .L520
	lsl.l #7,%d2
.L520:
	and.l #32512,%d2
.L515:
	move.l %d2,%d0
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L519:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L515
	move.l %d2,20(%sp)
	move.l %d3,16(%sp)
	movem.l (%sp),#28
	lea (12,%sp),%sp
	jra x_knob
.L522:
	mov3q.l #-1,%d2
	jra .L515
	.size	sfu_s_lget, .-sfu_s_lget
	.align	2
	.globl	sfu_f_lget
	.type	sfu_f_lget, @function
sfu_f_lget:
	link.w %fp,#-28
	move.l 12(%fp),%d1
	movem.l #28,(%sp)
	pea -4(%fp)
	move.l %d1,-(%sp)
	move.l 8(%fp),%d3
	mov3q.l #-1,%d4
	move.l %d1,-16(%fp)
	move.l 16(%fp),-8(%fp)
	jsr pq
	addq.l #8,%sp
	cmp.l %d0,%d4
	jne .L535
	move.l -16(%fp),%d1
	subq.l #1,%d1
	lsr.l #2,%d1
	jeq .L523
	move.l -16(%fp),%d1
	moveq #11,%d4
	add.l #-16,%d1
	cmp.l %d1,%d4
	jcc .L526
.L530:
	move.l -8(%fp),-(%sp)
	move.l -16(%fp),-(%sp)
	move.l -16(%fp),%d2
	add.l #-14,%d2
	move.l %d3,-(%sp)
	jsr 1074436538
	lea (12,%sp),%sp
	moveq #13,%d1
	cmp.l %d2,%d1
	jcc .L536
.L523:
	movem.l -28(%fp),#28
	unlk %fp
	rts
.L526:
	mov3q.l #6,%d4
	rems.l %d4,%d2:%d1
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jlt .L530
	jra .L523
.L536:
	tst.l %d0
	jlt .L523
	tst.b sfu_st+1026.l
	jeq .L532
	move.l %d3,-(%sp)
	move.l %d0,-12(%fp)
	jsr sync
	addq.l #4,%sp
	move.l -12(%fp),%d0
.L532:
	btst #0,%d2
	jeq .L533
	lsl.l #7,%d0
.L533:
	and.l #32512,%d0
	move.l %d2,8(%fp)
	movem.l -28(%fp),#28
	move.l %d0,12(%fp)
	unlk %fp
	jra to_knob
.L535:
	mov3q.l #-1,%d0
	jra .L523
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
	jcs .L538
	moveq #15,%d7
	cmp.l %d3,%d7
	jge .L539
	move.l %d3,%d0
	mov3q.l #6,%d7
	add.l #-16,%d0
	rems.l %d7,%d1:%d0
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L540
.L539:
	move.l %d6,-(%sp)
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	addq.l #1,sfu_st+1030
	jsr 1074436168
	lea (12,%sp),%sp
	tst.l %d0
	jge .L541
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433530
	addq.l #8,%sp
.L541:
	move.l %d2,-(%sp)
	move.l %d0,-(%sp)
	move.l %d4,-(%sp)
	jsr merge
	lea (12,%sp),%sp
	move.l %d0,%d2
.L542:
	move.l %d6,40(%sp)
	move.l %d2,36(%sp)
	move.l %d3,32(%sp)
	move.l %d5,28(%sp)
	movem.l (%sp),#252
	lea (24,%sp),%sp
	jmp 1074436282
.L538:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L542
	move.l %d6,-(%sp)
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074436168
	lea (12,%sp),%sp
	move.l %d0,%d4
	tst.l %d0
	jge .L543
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433530
	addq.l #8,%sp
	move.l %d0,%d4
.L543:
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr x_half
	addq.l #8,%sp
	move.l %d3,%a0
	add.l #sfu_x,%a0
	move.l %d0,%d2
	tst.b 6223(%a0)
	jeq .L542
	tst.l %d4
	jlt .L542
	and.l #32512,%d2
	and.l #224,%d4
	or.l %d4,%d2
	jra .L542
.L540:
	movem.l (%sp),#252
	clr.l %d0
	lea (24,%sp),%sp
	rts
	.size	sfu_s_lset, .-sfu_s_lset
	.align	2
	.globl	sfu_f_lset
	.type	sfu_f_lset, @function
sfu_f_lset:
	link.w %fp,#-28
	move.l 12(%fp),%d1
	movem.l #124,(%sp)
	pea -4(%fp)
	move.l %d1,-(%sp)
	move.l 8(%fp),%d4
	move.l 16(%fp),%d3
	move.l %d1,-8(%fp)
	move.l 20(%fp),%d6
	jsr pq
	addq.l #8,%sp
	addq.l #1,%d0
	tst.l %d0
	jne .L551
	move.l -8(%fp),%d0
	subq.l #1,%d0
	lsr.l #2,%d0
	jeq .L551
	move.l -8(%fp),%d5
	moveq #13,%d2
	add.l #-14,%d5
	cmp.l %d5,%d2
	jcs .L553
	moveq #15,%d0
	cmp.l -8(%fp),%d0
	jge .L554
	move.l -8(%fp),%d0
	mov3q.l #6,%d2
	add.l #-16,%d0
	rems.l %d2,%d1:%d0
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L551
.L554:
	move.l %d6,-(%sp)
	move.l -8(%fp),-(%sp)
	move.l %d4,-(%sp)
	addq.l #1,sfu_st+1030
	jsr 1074436538
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jge .L555
	move.l -8(%fp),-(%sp)
	move.l %d4,-(%sp)
	jsr 1074433680
	addq.l #8,%sp
	move.l %d0,%d2
.L555:
	clr.l -(%sp)
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr to_half
	move.l %d0,-(%sp)
	move.l %d2,-(%sp)
	move.l %d5,-(%sp)
	jsr merge
	lea (24,%sp),%sp
	move.l %d0,%d3
.L553:
	move.l %d6,20(%fp)
	move.l %d3,16(%fp)
	move.l %d4,8(%fp)
	movem.l -28(%fp),#124
	move.l -8(%fp),12(%fp)
	unlk %fp
	jmp 1074436652
.L551:
	movem.l -28(%fp),#124
	clr.l %d0
	unlk %fp
	rts
	.size	sfu_f_lset, .-sfu_f_lset
	.align	2
	.globl	sfu_get
	.type	sfu_get, @function
sfu_get:
	lea (-20,%sp),%sp
	movem.l #7180,(%sp)
	move.l 24(%sp),%a3
	move.l 28(%sp),%d2
	move.l 32(%sp),%d3
	move.l (%a3),%a0
	mov3q.l #-1,-(%sp)
	move.l %a3,-(%sp)
	move.l 160(%a0),%a0
	jsr (%a0)
	addq.l #8,%sp
	moveq #11,%d1
	move.l %d0,%a2
	move.l %d2,%d0
	move.l (%a2),%a4
	add.l #-16,%d0
	cmp.l %d0,%d1
	jcc .L557
	add.l #15,%d0
	lsr.l #2,%d0
	jne .L558
.L557:
	move.l %a3,sfu_p+4314
	move.l (%a3),sfu_p+4318
.L558:
	tst.l %d3
	jge .L559
.L560:
	move.l %d2,28(%sp)
	move.l %a2,24(%sp)
	move.l 40(%a4),%a1
	movem.l (%sp),#7180
	lea (20,%sp),%sp
	jmp (%a1)
.L559:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	move.l 60(%a4),%a0
	jsr (%a0)
	lea (12,%sp),%sp
	tst.l %d0
	jlt .L560
	movem.l (%sp),#7180
	lea (20,%sp),%sp
	rts
	.size	sfu_get, .-sfu_get
	.align	2
	.globl	sfu_key
	.type	sfu_key, @function
sfu_key:
	link.w %fp,#-36
	move.l -66650100,%d1
	move.l 12(%fp),%a1
	movem.l #1052,(%sp)
	move.l %d1,-12(%fp)
	moveq #49,%d3
	move.l 12(%a1),%d2
	move.l %d2,%d1
	mvz.b %d1,%d1
	move.l %d2,-20(%fp)
	cmp.l %d1,%d3
	jeq .L585
	moveq #50,%d4
	cmp.l %d1,%d4
	jne .L586
	mov3q.l #1,%a0
.L562:
	tst.b sfu_st+1026.l
	jeq .L563
	mov3q.l #1,%d0
	and.l 16(%a1),%d0
	cmp.l #128,%d1
	jne .L564
	move.b %d0,sfu_p+4280
.L563:
	clr.l %d0
.L565:
	clr.l -(%sp)
	move.l -12(%fp),-(%sp)
	move.l %d0,-16(%fp)
	jsr timed
	addq.l #8,%sp
	movem.l -36(%fp),#1052
	move.l -16(%fp),%d0
	unlk %fp
	rts
.L585:
	sub.l %a0,%a0
	jra .L562
.L586:
	mov3q.l #-1,%a0
	jra .L562
.L564:
	mov3q.l #-1,%d2
	cmp.l %a0,%d2
	jeq .L566
	move.b sfu_p+4276,%d3
	move.b sfu_p+4278,%d4
	tst.l %d0
	jeq .L567
	mvz.b %d4,%d2
	move.l %a0,%d0
	asr.l %d0,%d2
	mov3q.l #1,%d0
	and.l %d2,%d0
	btst #0,%d2
	jeq .L568
	mvz.b %d3,%d0
	cmp.l %d0,%d1
	seq %d0
.L602:
	mvs.b %d0,%d0
	neg.l %d0
	jra .L565
.L568:
	mov3q.l #1,%d1
	move.l %a0,%d2
	lsl.l %d2,%d1
	or.l %d4,%d1
	move.b %d1,sfu_p+4278
	move.b sfu_p+4280,%d1
	or.l %d3,%d1
	tst.b %d1
	jne .L565
	mvz.b sfu_p+4275,%d2
	move.l %a0,%d1
	addq.l #1,%d1
	cmp.l %d2,%d1
	jne .L565
	add.l #sfu_p,%a0
	mvz.b 4242(%a0),%d1
	lsr.l #1,%d1
	jeq .L565
	clr.l %d0
	lea sfu_p+4322,%a0
.L571:
	lea (%a1,%d0.l),%a2
	moveq #32,%d1
	move.l (%a2),(%a0,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L571
	clr.b %d0
	lea (-17,%fp),%a0
	move.b (%a0),sfu_p+4276
	addq.l #1,sfu_p+4306
	move.b %d0,sfu_p+4277
.L572:
	mov3q.l #1,%d0
	jra .L565
.L567:
	mov3q.l #1,%d0
	move.l %a0,%d2
	lsl.l %d2,%d0
	mvz.b %d3,%d3
	not.l %d0
	and.l %d4,%d0
	move.b %d0,sfu_p+4278
	cmp.l %d1,%d3
	jne .L563
	clr.b %d3
	move.b %d3,sfu_p+4276
	tst.b sfu_p+4277.l
	jne .L572
	pea sfu_p+4322
	mov3q.l #1,%d4
	move.l 8(%fp),-(%sp)
	or.l %d4,sfu_p+4338
	jsr 1074397898
	addq.l #1,sfu_p+4302
	addq.l #8,%sp
	jra .L563
.L566:
	move.l %d1,%a1
	mov3q.l #1,%d2
	lea (-66,%a1),%a1
	cmp.l %a1,%d2
	jcs .L563
	moveq #66,%d3
	cmp.l %d1,%d3
	jeq .L573
	mov3q.l #2,%d2
.L573:
	tst.l %d0
	jne .L574
	move.b sfu_p+4279,%d1
	move.l %d2,%d0
	and.l %d1,%d0
	tst.l %d0
	jeq .L565
	move.l %d2,%d0
	not.l %d0
	and.l %d1,%d0
	move.b %d0,sfu_p+4279
	jra .L572
.L574:
	move.b sfu_p+4278,%d0
	btst #0,%d0
	jne .L588
	btst #1,%d0
	jeq .L576
	mov3q.l #1,-20(%fp)
.L575:
	mvz.b sfu_p+4275,%d3
	move.l -20(%fp),%d0
	addq.l #1,%d0
	cmp.l %d3,%d0
	jne .L576
	move.l -20(%fp),%a1
	add.l #sfu_p,%a1
	mvz.b 4242(%a1),%d0
	mov3q.l #1,%d4
	cmp.l %d0,%d4
	jcc .L576
	tst.b sfu_p+4280.l
	jeq .L577
.L576:
	mvz.b sfu_p+4279,%d0
	and.l %d2,%d0
	tst.l %d0
	sne %d0
	jra .L602
.L588:
	clr.l -20(%fp)
	jra .L575
.L577:
	mvz.b 4240(%a1),%d3
	moveq #67,%d4
	cmp.l %d1,%d4
	jne .L578
	mov3q.l #1,%a0
.L578:
	move.l %d3,%d1
	add.l %a0,%d1
	tst.l %d1
	jge .L579
	clr.l %d1
.L579:
	cmp.l %d1,%d0
	jgt .L580
	move.l %d0,%d1
	subq.l #1,%d1
.L580:
	cmp.l %d3,%d1
	jeq .L581
	move.b %d1,4240(%a1)
	tst.l %d1
	jne .L582
	move.l -20(%fp),-(%sp)
	jsr restore_recs
	addq.l #4,%sp
.L582:
	jsr relabel
	move.l sfu_x+2132,%d0
	tst.l %d0
	jeq .L583
	move.l %d0,-(%sp)
	jsr sync
	addq.l #4,%sp
.L583:
	addq.l #1,sfu_p+4298
.L581:
	move.b sfu_p+4279,%d0
	move.l -20(%fp),%a0
	lea (49,%a0),%a0
	or.l %d2,%d0
	move.b %d0,sfu_p+4279
	mvz.b sfu_p+4276,%d0
	cmp.l %d0,%a0
	jne .L584
	moveq #1,%d0
	move.b %d0,sfu_p+4277
.L584:
	move.l sfu_p+4314,%d0
	tst.l %d0
	jeq .L572
	move.l %d0,-(%sp)
	jsr 1074234644
	clr.l -4(%fp)
	move.l sfu_p+4314,%a0
	move.l %fp,%d2
	subq.l #4,%d2
	move.l %a0,%a1
	move.l %a0,-20(%fp)
	move.l (%a0),%a0
	move.l %a1,-(%sp)
	move.l 76(%a0),%a0
	jsr (%a0)
	pea -5(%fp)
	move.l %d0,-(%sp)
	move.l %d2,-(%sp)
	jsr 1075563852
	move.l -20(%fp),%a2
	move.l %d2,-(%sp)
	move.l 108(%a2),-(%sp)
	jsr 1073962984
	move.l %d2,-(%sp)
	jsr 1075557020
	lea (32,%sp),%sp
	addq.l #1,sfu_p+4310
	jra .L572
	.size	sfu_key, .-sfu_key
	.align	2
	.globl	sfu_tick
	.type	sfu_tick, @function
sfu_tick:
	link.w %fp,#-48
	move.l -66650100,%d1
	movem.l #15364,(%sp)
	addq.l #1,sfu_st+1034
	move.l %d1,-28(%fp)
	tst.b sfu_st+1026.l
	jne .L604
	tst.l 1100664624
	jeq .L605
	tst.l 1100635224
	jeq .L605
	lea copy_desc,%a3
	sub.l %a2,%a2
	lea set_rec,%a5
	move.l %a3,%a4
.L607:
	move.l %a2,-(%sp)
	jsr (%a5)
	addq.l #4,%sp
	mov3q.l #1,%d2
	cmp.l %a2,%d2
	jlt .L654
	moveq #60,%d0
.L606:
	move.l %d0,-(%sp)
	pea 14(%a2)
	jsr (%a3)
	addq.l #1,%a2
	addq.l #8,%sp
	moveq #14,%d0
	cmp.l %a2,%d0
	jne .L607
	sub.l %a2,%a2
	lea set_bw_rec,%a3
.L608:
	move.l %a2,-(%sp)
	jsr (%a3)
	pea 410.w
	addq.l #1,%a2
	move.l %a2,-(%sp)
	jsr (%a4)
	lea (12,%sp),%sp
	mov3q.l #4,%d1
	cmp.l %a2,%d1
	jne .L608
	tst.l sfu_x+6694
	jne .L609
	moveq #127,%d2
	move.b %d2,sfu_x+6687
	move.b %d2,sfu_x+6685
.L609:
	move.l #1100664624,%a0
	move.l (%a0),sfu_x+2136
	lea sfu_type2_text,%a2
	move.l %a2,1100632032
	move.l #sfu_route_text,%d0
	lea sfu_p02_text,%a2
	move.l %a2,1100631864
	move.l #sfu_p00_text,%d1
	sub.l %a2,%a2
	lea sfu_type1_text,%a1
	move.l %a1,1100631528
	move.l #sfu_p10_text,%d2
	lea sfu_p01_text,%a0
	lea sfu_p11_text,%a1
	move.l %d0,1100631612
	move.l %d0,1100632116
	move.l #sfu_p12_text,%d0
	move.l %d1,1100631696
	move.l #sfu_p03_text,%d1
	move.l %d2,1100632200
	move.l #sfu_p13_text,%d2
	move.l %a0,1100631780
	move.l %a1,1100632284
	move.l %d0,1100632368
	move.l %d1,1100631948
	move.l %d2,1100632452
	lea sfu_st,%a1
	sub.l %a0,%a0
	move.l sfu_x+2316,%d1
	move.l %d1,%d0
.L611:
	tst.b (%a1)
	jeq .L610
	move.w %a0,%d2
	move.l %d0,%a2
	add.l #sfu_x,%a2
	addq.l #1,%d0
	move.b %d2,2188(%a2)
	move.w #1,%a2
.L610:
	addq.l #1,%a0
	addq.l #8,%a1
	cmp.l #128,%a0
	jne .L611
	move.w %a2,%d2
	tst.b %d2
	jeq .L612
	move.l %d0,sfu_x+2316
	move.l %d0,%d1
.L612:
	lea sfu_x+2188,%a0
	clr.l %d0
.L613:
	cmp.l %d0,%d1
	jgt .L614
	move.l %d1,sfu_x+2452
	clr.l %d0
	lea sfu_x+2564,%a0
.L615:
	clr.b %d1
	moveq #14,%d2
	move.b %d1,(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d2
	jne .L615
	mov3q.l #2,-(%sp)
	mov3q.l #1,-(%sp)
	mov3q.l #2,-(%sp)
	lea set_look,%a2
	jsr (%a2)
	mov3q.l #2,-(%sp)
	mov3q.l #1,-(%sp)
	pea 8.w
	jsr (%a2)
	mov3q.l #2,-(%sp)
	mov3q.l #3,-(%sp)
	mov3q.l #3,-(%sp)
	jsr (%a2)
	lea (32,%sp),%sp
	mov3q.l #2,(%sp)
	mov3q.l #3,-(%sp)
	pea 9.w
	jsr (%a2)
	jsr relabel
	lea (12,%sp),%sp
	moveq #1,%d0
	lea sfu_sysex,%a0
	move.l %a0,1075551832
	move.l #1397119061,%a1
	move.l %a1,1075551828
	move.b %d0,sfu_st+1026
.L604:
	move.l sfu_x+2320,%d0
	mov3q.l #1,%d1
	and.l %d0,%d1
	btst #0,%d0
	jne .L616
	cmp.l sfu_x+2456.l,%d0
	jeq .L616
	move.l sfu_x+2316,%a0
	lea sfu_x+2188,%a1
.L617:
	cmp.l %a0,%d1
	jeq .L618
	cmp.l #128,%d1
	jne .L619
.L618:
	cmp.l sfu_x+2320.l,%d0
	jne .L616
	tst.l %a0
	jeq .L616
	move.l %d0,sfu_x+2456
	moveq #1,%d0
	move.l %a0,sfu_x+2452
	move.l 8(%fp),%a0
	move.b %d0,32(%a0)
.L616:
	move.l sfu_x+2132,%d0
	tst.l %d0
	jeq .L620
	move.l %d0,-(%sp)
	move.l sfu_x+2160,%a2
	jsr sync
	addq.l #4,%sp
	cmp.l sfu_x+2160.l,%a2
	jeq .L621
.L735:
	moveq #1,%d0
	move.l 8(%fp),%a0
	move.b %d0,32(%a0)
.L621:
	move.l 8(%fp),%a1
	move.l %a1,sfu_p+4738
	move.l sfu_p+4314,%a1
	tst.l %a1
	jeq .L622
	move.l 8(%fp),%a2
	clr.l %d0
	move.l 8(%fp),%a5
	move.w #16,%a3
	move.l 28(%a2),%a0
	sub.l %a2,%a2
	lea (20,%a5),%a5
.L623:
	tst.l %a0
	jeq .L630
	cmp.l %a0,%a5
	jeq .L630
	move.l 8(%a0),%a4
	tst.l %a4
	jne .L624
.L622:
	clr.l %d0
.L625:
	move.b %d0,sfu_p+4275
	tst.b sfu_p+4274.l
	jeq .L635
	clr.b %d0
	moveq #1,%d1
	move.l 8(%fp),%a0
	move.b %d0,sfu_p+4274
	move.b %d1,32(%a0)
.L635:
	move.l sfu_p+4282,%d0
	tst.l %d0
	jeq .L636
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jls .L636
	clr.l sfu_p+4282
.L636:
	move.l sfu_p+4286,%d0
	tst.l %d0
	jeq .L637
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jls .L637
	clr.l sfu_p+4286
.L637:
	lea sfu_p,%a5
	sub.l %a2,%a2
	lea sfu_p+4270,%a3
	lea sfu_p+4246,%a4
.L643:
	tst.w (%a3)+
	jeq .L638
	lea sfu_p+4244,%a0
	move.b (%a0,%a2.l),%d1
	jeq .L638
	move.w #8707,%d2
	move.b %d1,-14(%fp)
	mvz.b %d1,%d0
	move.l #-260222380,%a1
	sub.l %a0,%a0
	move.l %a1,-22(%fp)
	move.w %d2,-18(%fp)
	move.w %a2,%d2
	move.b %d2,-16(%fp)
	moveq #5,%d2
	move.b %d2,-15(%fp)
.L639:
	lea (%a4,%a0.l),%a1
	addq.l #1,%a0
	move.b (%a1),-14(%a0,%fp.l)
	cmp.l %d0,%a0
	jlt .L639
	moveq #-9,%d1
	move.l %d0,%a0
	move.b %d1,-13(%fp,%d0.l)
	pea 10(%a0)
	pea -22(%fp)
	jsr try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L642
	clr.w %d0
	mov3q.l #1,%d1
	or.l -66650100,%d1
	move.w %d0,-2(%a3)
	move.l %d1,4282(%a5)
	addq.l #1,sfu_p+4290
.L641:
	addq.l #4,%a5
	lea (12,%a4),%a4
	mov3q.l #1,%d0
	cmp.l %a2,%d0
	jne .L656
.L642:
	tst.b sfu_x+6689.l
	jeq .L644
	clr.b %d1
	moveq #1,%d2
	move.l 8(%fp),%a0
	move.b %d1,sfu_x+6689
	move.b %d2,32(%a0)
.L644:
	move.l sfu_x+6698,%d0
	tst.l %d0
	jeq .L645
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jls .L645
	clr.l sfu_x+6698
.L645:
	move.l sfu_x+6702,%d0
	tst.l %d0
	jeq .L646
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jls .L646
	clr.l sfu_x+6702
.L646:
	lea sfu_x,%a4
	sub.l %a2,%a2
	lea sfu_x+6684,%a3
.L650:
	mvz.b sfu_x+6688,%d0
	move.l %a2,%d1
	btst %d1,%d0
	jeq .L647
	move.w #8706,%a0
	moveq #-9,%d0
	move.b (%a3),-15(%fp)
	move.b 1(%a3),-14(%fp)
	pea 10.w
	move.l #-260222380,%d2
	pea -22(%fp)
	move.b %d1,-16(%fp)
	move.l %d2,-22(%fp)
	move.w %a0,-18(%fp)
	move.b %d0,-13(%fp)
	jsr try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L649
	move.l %a2,%d1
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	move.b sfu_x+6688,%d1
	mov3q.l #1,%d2
	or.l -66650100,%d2
	not.l %d0
	and.l %d1,%d0
	move.b %d0,sfu_x+6688
	move.l %d2,6698(%a4)
	addq.l #1,sfu_x+6690
.L647:
	addq.l #4,%a4
	addq.l #2,%a3
	mov3q.l #1,%d0
	cmp.l %a2,%d0
	jne .L657
.L649:
	mvz.b sfu_st+1027,%d0
	lsr.l #1,%d0
	jne .L605
	move.w sfu_st+1028,%d0
	moveq #99,%d2
	mvz.w %d0,%d1
	cmp.l %d1,%d2
	jcs .L651
	addq.l #1,%d0
	move.w %d0,sfu_st+1028
	mvz.w %d0,%d0
	moveq #100,%d1
	cmp.l %d0,%d1
	jne .L605
.L651:
	mov3q.l #7,-(%sp)
	pea (m.0)
	jsr try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L605
	clr.w %d2
	addq.l #1,sfu_x+2152
	move.w %d2,sfu_st+1028
.L605:
	clr.l -(%sp)
	move.l -28(%fp),-(%sp)
	jsr timed
	addq.l #8,%sp
	tst.b sfu_st+1026.l
	jeq .L603
	move.l #1481856080,%a0
	cmp.l 1073848892.l,%a0
	jne .L603
	tst.l 1073848900
	jeq .L603
	move.l -66650100,%a2
	move.l 1073848900,%a0
	move.l 8(%fp),-(%sp)
	jsr (%a0)
	addq.l #4,%sp
	tst.l %d0
	jeq .L653
	moveq #1,%d0
	move.l 8(%fp),%a0
	move.b %d0,32(%a0)
.L653:
	move.l -66650100,%d0
	sub.l %a2,%d0
	add.l %d0,sfu_x+6418
	addq.l #1,sfu_x+6426
	cmp.l sfu_x+6422.l,%d0
	jls .L603
	move.l %d0,sfu_x+6422
.L603:
	movem.l -48(%fp),#15364
	unlk %fp
	rts
.L654:
	mvz.w #410,%d0
	jra .L606
.L614:
	move.b (%a0)+,%d2
	addq.l #1,%d0
	move.b %d2,135(%a0)
	jra .L613
.L619:
	move.b (%a1)+,%d2
	addq.l #1,%d1
	move.b %d2,135(%a1)
	jra .L617
.L620:
	move.l sfu_x+2084,%a1
	cmp.l sfu_x+2080.l,%a1
	jeq .L621
	lea sfu_x+2080,%a2
	move.l (%a2),sfu_x+2084
	jsr relabel
	jra .L735
.L624:
	move.l (%a4),%d1
	tst.l %d0
	jeq .L626
	cmp.l #1075718412,%d1
	jeq .L628
	cmp.l #1075712228,%d1
	jeq .L628
	cmp.l #1075719596,%d1
	jeq .L628
	cmp.l #1075717140,%d1
	jne .L622
.L628:
	move.l (%a0),%a0
	subq.l #1,%a3
	tst.l %a3
	jne .L623
.L630:
	tst.l %d0
	jeq .L625
	tst.l %a2
	jne .L633
.L634:
	move.l %a2,%d0
	jra .L625
.L626:
	cmp.l #1076055292,%d1
	jeq .L655
	cmp.l %a1,%a4
	jne .L628
	cmp.l sfu_p+4318.l,%d1
	seq %d1
	move.l %a2,%d2
	mvs.b %d1,%d1
	neg.l %d1
	or.l %d1,%d2
	move.l %d2,%a2
	jra .L628
.L655:
	mov3q.l #1,%d0
	jra .L628
.L633:
	move.l sfu_p+4318,%a0
	clr.l -(%sp)
	move.l %a1,-(%sp)
	move.l 156(%a0),%a0
	jsr (%a0)
	addq.l #8,%sp
	moveq #16,%d1
	cmp.l %d0,%d1
	jeq .L634
	moveq #22,%d2
	cmp.l %d0,%d2
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
	add.l %d0,%d0
	jra .L625
.L656:
	mov3q.l #1,%a2
	jra .L643
.L638:
	clr.w %d2
	move.w %d2,-2(%a3)
	jra .L641
.L657:
	mov3q.l #1,%a2
	jra .L650
	.size	sfu_tick, .-sfu_tick
	.text
	.type	m.0, @object
	.size	m.0, 7
m.0:
	.base64	"8H1SVCMB9w=="
	.align	2
	.type	ptexts, @object
	.size	ptexts, 32
ptexts:
	.long	sfu_p00_text
	.long	sfu_p01_text
	.long	sfu_p02_text
	.long	sfu_p03_text
	.long	sfu_p10_text
	.long	sfu_p11_text
	.long	sfu_p12_text
	.long	sfu_p13_text
	.globl	sfu_p
	.section	.bss
	.align	2
	.type	sfu_p, @object
	.size	sfu_p, 4742
sfu_p:
	.zero	4742
	.globl	sfu_x
	.align	2
	.type	sfu_x, @object
	.size	sfu_x, 7940
sfu_x:
	.zero	7940
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
	.text
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
	.long	1
	.long	2
	.long	n_fx2
	.long	22
	.long	23
	.long	24
	.long	25
	.long	26
	.long	27
	.long	3
	.long	4
	.text
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
	.type	s_wid, @object
	.size	s_wid, 4
s_wid:
	.string	"WID"
	.type	s_base, @object
	.size	s_base, 5
s_base:
	.string	"BASE"
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
