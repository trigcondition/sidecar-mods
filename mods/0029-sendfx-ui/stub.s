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
	add.l %d0,sfu_x+1136
	addq.l #1,sfu_x+1144
	cmp.l sfu_x+1140.l,%d0
	jls .L1
	move.l %d0,sfu_x+1140
.L1:
	rts
.L2:
	add.l %d0,sfu_x+1124
	addq.l #1,sfu_x+1132
	cmp.l sfu_x+1128.l,%d0
	jls .L1
	move.l %d0,sfu_x+1128
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
	move.l sfu_x+1416,%d4
	addq.l #1,%d4
	mvz.b 1538(%a0),%d0
	cmp.l %d0,%d2
	jeq .L11
.L14:
	move.l sfu_x+1412,%d0
	mov3q.l #-1,%a1
	mov3q.l #1,%d3
	lea sfu_x+1284,%a3
	move.l %d0,24(%sp)
	clr.l %d0
.L12:
	cmp.l 24(%sp),%d0
	jne .L17
	move.b %d2,1538(%a0)
	mov3q.l #-1,%d0
	cmp.l %a1,%d0
	jne .L18
	move.w #255,%a1
.L18:
	move.w %a1,%d0
	add.l #386,%d1
	move.l %d4,(%a2,%d1.l*4)
	move.b %d3,1542(%a0)
	move.b %d0,1540(%a0)
	jra .L10
.L11:
	move.l %d1,%d0
	add.l #386,%d0
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
	move.b 1540(%a0),%d0
	move.l sfu_x+1412,%d2
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
	mvz.b 1542(%a0),%d0
	cmp.l %d0,%d1
	jeq .L26
	jle .L28
	subq.l #1,%d1
.L28:
	add.l %d1,%a1
	mvz.b 1284(%a1),%d0
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
	move.b 1540(%a0),%d0
	mvz.b %d0,%d1
	cmp.l #255,%d1
	jne .L32
	move.b 1542(%a0),%d0
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
	add.l #sfu_x+1420,%a0
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
	add.l #sfu_x+1428,%a0
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
	mvz.b 1420(%a3),%d2
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
	addq.l #1,sfu_x+1552
	move.l %d0,%a0
	add.l %d1,%a0
	add.l %a2,%a0
	add.l %a1,%a0
	mvz.b 1428(%a0),%d0
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
	cmp.l 1814(%a0),%d0
	jeq .L60
	move.l 1073848896,%a0
	mov3q.l #3,%d6
	move.l %d3,-(%sp)
	jsr (%a0)
	addq.l #1,sfu_x+5370
	addq.l #4,%sp
	move.l %d0,%d1
	asr.l #8,%d1
	move.b %d0,1687(%a2)
	mvz.b %d0,%d0
	lsr.l #1,%d0
	and.l %d6,%d1
	move.b %d1,1560(%a2)
	tst.l %d0
	jne .L61
	clr.b %d6
	move.b %d6,1560(%a2)
.L61:
	move.l sfu_st+1034,%a3
	move.l %d2,%a0
	addq.l #1,%a3
	add.l %d5,%a0
	move.l %a3,1814(%a0)
.L60:
	move.w %d3,%d0
	mulu.w #52,%d3
	move.l %d3,%a1
	add.l #1075575064,%a1
	mulu.w #84,%d0
	move.l %d0,%a0
	add.l #1100630152,%a0
	move.l 32(%a0),%d0
	tst.b 1560(%a2)
	jeq .L62
	cmp.l #sfu_xtext,%d0
	jeq .L63
	moveq #20,%d0
	muls.l %d0,%d4
	move.l %d2,%a3
	add.l %d5,%d2
	move.l #1100634276,%a4
	move.l #sfu_xtext,%d0
	add.l %d4,%a3
	move.l (%a0),2830(%a3)
	move.l 4(%a0),2834(%a3)
	move.l 8(%a0),2838(%a3)
	move.l 16(%a0),2842(%a3)
	move.l 48(%a0),2846(%a3)
	move.l %d2,%a3
	move.l 32(%a0),2322(%a3)
	move.l 1100634268,(%a0)
	move.l #1100634272,%a3
	move.l (%a3),4(%a0)
	move.l #1100634284,%a3
	move.l (%a4),8(%a0)
	lea sfu_draw,%a4
	move.l (%a3),16(%a0)
	move.l %a4,48(%a0)
	move.l %d0,32(%a0)
	addq.l #1,sfu_x+5374
.L63:
	mvz.b 1687(%a2),%d0
	lsl.l #8,%d0
	add.l #-256,%d0
.L67:
	move.l %d0,12(%a1)
.L64:
	mvz.b 1560(%a2),%d0
	jra .L56
.L62:
	cmp.l #sfu_xtext,%d0
	jne .L64
	moveq #20,%d1
	muls.l %d1,%d4
	move.l %d2,%a3
	add.l %d5,%d2
	mvz.w #32512,%d0
	add.l %d4,%a3
	move.l 2830(%a3),(%a0)
	move.l 2834(%a3),4(%a0)
	move.l 2838(%a3),8(%a0)
	move.l 2842(%a3),16(%a0)
	move.l 2846(%a3),48(%a0)
	move.l %d2,%a3
	move.l 2322(%a3),32(%a0)
	jra .L67
	.size	xmode, .-xmode
	.align	2
	.type	x_knob, @function
x_knob:
	move.l %d2,-(%sp)
	moveq #127,%d2
	move.l 12(%sp),%d0
	asr.l #8,%d0
	move.l 8(%sp),%a0
	add.l #sfu_x-334,%a0
	mvz.b 1687(%a0),%d1
	cmp.l %d0,%d2
	jge .L69
	moveq #127,%d0
.L70:
	mvz.b 1560(%a0),%d2
	move.l %d2,%a0
	mov3q.l #1,%d2
	cmp.l %a0,%d2
	jne .L71
	muls.w %d1,%d0
	asr.l #7,%d0
.L72:
	lsl.l #8,%d0
	move.l (%sp)+,%d2
	rts
.L69:
	tst.l %d0
	jge .L70
	clr.l %d0
	jra .L70
.L71:
	mov3q.l #2,%d2
	cmp.l %a0,%d2
	jne .L72
	cmp.l %d0,%d1
	jgt .L72
	move.l %d1,%d0
	subq.l #1,%d0
	jra .L72
	.size	x_knob, .-x_knob
	.align	2
	.type	x_half, @function
x_half:
	move.l %d2,-(%sp)
	move.l 12(%sp),%a1
	move.l %a1,%d0
	move.l 8(%sp),%a0
	add.l #sfu_x-334,%a0
	mvz.b 1687(%a0),%d1
	asr.l #8,%d0
	tst.l %a1
	jge .L76
	clr.l %d0
.L76:
	cmp.l %d1,%d0
	jlt .L77
	move.l %d1,%d0
	subq.l #1,%d0
.L77:
	mvz.b 1560(%a0),%d2
	move.l %d2,%a0
	mov3q.l #1,%d2
	cmp.l %a0,%d2
	jne .L78
	lsl.l #7,%d0
	move.l %d1,%a0
	lea -1(%a0,%d0.l),%a0
	move.l %a0,%d0
	divs.l %d1,%d0
.L78:
	lsl.l #8,%d0
	move.l (%sp)+,%d2
	addq.l #1,sfu_x+1552
	rts
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
	jcs .L80
	move.l %a0,%d5
	lsl.l #2,%d5
	lea sfu_x,%a1
	add.l %d5,%a1
	tst.l 2322(%a1)
	jeq .L80
	add.l #sfu_x,%a0
	tst.b 1560(%a0)
	jeq .L83
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	jsr x_half
	subq.l #1,sfu_x+1552
	addq.l #8,%sp
.L83:
	lea sfu_x,%a0
	add.l %d5,%a0
	move.l %d4,28(%sp)
	move.l %d3,20(%sp)
	movem.l (%sp),#60
	move.l %d0,24(%sp)
	move.l 2322(%a0),%a1
	lea (16,%sp),%sp
	jmp (%a1)
.L80:
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
	moveq #84,%d3
	move.l 20(%sp),%a1
	move.l %a1,%d0
	add.l #-1100630172,%d0
	divu.l %d3,%d0
	move.l 24(%sp),%d1
	moveq #126,%d3
	move.l 28(%sp),%d2
	add.l #-334,%d0
	cmp.l %d0,%d3
	jcs .L86
	lea sfu_x,%a0
	lea (%a0,%d0.l*4),%a2
	tst.l 2322(%a2)
	jeq .L86
	add.l %d0,%a0
	move.b 1560(%a0),%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	lsr.l #1,%d0
	jne .L86
	move.l %d1,%d0
	asr.l #8,%d0
	tst.l %d1
	jge .L87
	clr.l %d0
.L87:
	mvz.b 1687(%a0),%d1
	cmp.l %d1,%d0
	jlt .L88
	move.l %d1,%d0
	subq.l #1,%d0
.L88:
	move.l %d0,%a0
	pea 1(%a0)
	pea s_empty
	pea fmt_d
	move.l %d2,-(%sp)
	jsr 1074365954
	movem.l 16(%sp),#1052
	lea (32,%sp),%sp
	rts
.L86:
	move.l %d2,28(%sp)
	movem.l (%sp),#1052
	move.l %d1,24(%sp)
	move.l %a1,20(%sp)
	lea (16,%sp),%sp
	jra xname
	.size	sfu_xtext, .-sfu_xtext
	.align	2
	.type	see_fxset, @function
see_fxset:
	move.l 4(%sp),%d0
	move.l sfu_x+1092,%d1
	cmp.l %d1,%d0
	jeq .L91
	tst.l %d1
	jeq .L93
	addq.l #1,sfu_x+1100
.L93:
	move.l %d0,sfu_x+1092
.L91:
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
	mvz.b 1048(%a0),%d0
	move.l %d0,-(%sp)
	move.l %d2,-(%sp)
	jsr tid
	lea (12,%sp),%sp
	moveq #127,%d1
	move.l %d0,%a1
	cmp.l %d0,%d1
	jge .L98
	move.w #127,%a1
.L98:
	mvz.w %a1,%d1
	lsl.l #3,%d1
	move.l %d1,%a0
	add.l #sfu_st,%a0
	tst.b (%a0)
	jne .L99
	moveq #63,%d1
	cmp.l %d0,%d1
	jge .L103
	lea (-63,%a1),%a1
	move.l #s_ufx,%d0
.L100:
	move.l %a1,-(%sp)
	move.l %d0,-(%sp)
	pea fmt_d
	move.l %d3,-(%sp)
	jsr 1074365954
	movem.l 16(%sp),#1036
	lea (28,%sp),%sp
	rts
.L103:
	move.l #s_fx,%d0
	jra .L100
.L99:
	add.l #sfu_st,%d2
	move.l %d2,%a2
	mvz.b 1024(%a2),%d0
	cmp.l %d0,%a1
	jne .L104
	move.l #fmt_bang,%d0
.L102:
	move.l %d3,16(%sp)
	movem.l (%sp),#1036
	move.l %a0,24(%sp)
	move.l %d0,20(%sp)
	lea (12,%sp),%sp
	jmp 1074365954
.L104:
	move.l #fmt_s,%d0
	jra .L102
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
	jeq .L110
	move.l #s_post,%d0
.L109:
	move.l %d0,12(%sp)
	move.l #fmt_s,%d0
	move.l %d0,8(%sp)
	move.l %d1,4(%sp)
	jmp 1074365954
.L110:
	move.l #s_pre,%d0
	jra .L109
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
	mvz.b 1050(%a0),%d0
	lea sfu_x,%a0
	move.l %a0,%a2
	move.l %d0,%a1
	clr.l %d0
	addq.l #1,%a1
.L114:
	mvz.b (%a0),%d5
	cmp.l %d5,%a1
	jne .L112
	mulu.w #130,%d0
	move.l %d0,%a1
	add.l #sfu_x,%a1
.L113:
	lea (%a2,%d1.l*4),%a0
	move.l %d3,%d0
	asr.l #8,%d0
	add.l %d4,%a0
	mvz.b 1420(%a0),%d5
	tst.l %d3
	jge .L115
	clr.l %d0
.L115:
	tst.l %d5
	jeq .L116
	cmp.l %d0,%d5
	jgt .L117
	move.l %d5,%d0
	subq.l #1,%d0
.L117:
	moveq #48,%d7
	moveq #12,%d5
	muls.l %d7,%d1
	muls.l %d4,%d5
	move.l %d5,%a0
	add.l %d1,%a0
	add.l %a2,%a0
	add.l %d0,%a0
	mvz.b 1428(%a0),%d0
.L116:
	move.l %d0,%d1
	moveq #127,%d7
	cmp.l %d0,%d7
	jge .L118
	moveq #127,%d1
.L118:
	tst.l %a1
	jeq .L119
	mvz.b 1(%a1),%d6
	lea (22,%a1),%a2
	mov3q.l #-1,%a0
	clr.l %d0
.L120:
	cmp.l %d6,%d0
	jge .L122
	moveq #12,%d5
	cmp.l %d0,%d5
	jne .L123
.L122:
	mov3q.l #-1,%d7
	cmp.l %a0,%d7
	jeq .L119
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
	jlt .L132
	moveq #9,%d5
	cmp.l %d1,%d5
	jge .L133
	mov3q.l #2,%a2
.L124:
	lea 25(%a1,%d0.l),%a0
	move.l %a0,%d3
	lea (%a1,%d0.l),%a0
	move.b 22(%a0),%d0
	move.w %d0,%ccr
	jne .L125
	sub.l %a1,%a1
.L126:
	tst.b 25(%a0,%a1.l)
	jeq .L127
	addq.l #1,%a1
	mov3q.l #5,%d5
	cmp.l %a1,%d5
	jne .L126
.L127:
	lea 1(%a2,%a1.l),%a0
	mov3q.l #7,%d7
	cmp.l %a0,%d7
	jlt .L134
	move.l #fmt_sn,%d0
.L129:
	move.l %d1,48(%sp)
	move.l %d3,44(%sp)
	move.l %d0,40(%sp)
.L148:
	move.l %d2,36(%sp)
	movem.l (%sp),#1276
	lea (32,%sp),%sp
	jmp 1074365954
.L112:
	addq.l #1,%d0
	lea (130,%a0),%a0
	moveq #8,%d5
	cmp.l %d0,%d5
	jne .L114
	sub.l %a1,%a1
	jra .L113
.L123:
	move.b (%a2),%d5
	mov3q.l #3,%d7
	and.l %d7,%d5
	cmp.l %d5,%d4
	jne .L121
	mvz.b 1(%a2),%d5
	cmp.l %d5,%d1
	jlt .L121
	move.l %d0,%a0
.L121:
	addq.l #1,%d0
	lea (9,%a2),%a2
	jra .L120
.L132:
	mov3q.l #3,%a2
	jra .L124
.L133:
	mov3q.l #1,%a2
	jra .L124
.L125:
	move.l %d3,44(%sp)
	move.l #fmt_s,%d0
	move.l %d2,36(%sp)
	movem.l (%sp),#1276
	move.l %d0,40(%sp)
	lea (32,%sp),%sp
	jmp 1074365954
.L134:
	move.l #fmt_n,%d0
	jra .L129
.L119:
	move.l sfu_x+1096,%a1
	tst.l %a1
	jeq .L130
	move.l %d2,44(%sp)
	move.l %d3,40(%sp)
	movem.l (%sp),#1276
	move.l 28(%sp),36(%sp)
	lea (32,%sp),%sp
	jmp (%a1)
.L130:
	move.l #s_empty,%d0
	move.l #fmt_d,%d3
	move.l %d1,48(%sp)
	move.l %d0,44(%sp)
	move.l %d3,40(%sp)
	jra .L148
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
	jeq .L164
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jge .L165
	subq.l #1,%d1
	lsl.l #8,%d1
	move.l #1100634268,%a2
.L158:
	move.w %d0,%d2
	move.l #1075575076,%a4
	move.l %a0,%a3
	add.l #sfu_x,%a3
	mulu.w #52,%d2
	move.l %d1,(%a4,%d2.l)
	mvz.b 1524(%a3),%d1
	cmp.l %d1,%a1
	jeq .L157
	mulu.w #84,%d0
	move.l %d0,%a0
	add.l #1100630152,%a0
	move.l (%a2),(%a0)
	move.l 4(%a2),4(%a0)
	move.l 8(%a2),8(%a0)
	move.l 16(%a2),16(%a0)
	tst.l %a1
	jne .L160
	move.l 1100664640,%d0
.L161:
	move.l %d0,48(%a0)
	move.w %a1,%d0
	move.b %d0,1524(%a3)
.L157:
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	rts
.L164:
	mvz.w #32512,%d1
	move.l #1100664592,%a2
	jra .L158
.L165:
	mvz.w #256,%d1
	move.l #1100634268,%a2
	jra .L158
.L160:
	mov3q.l #2,%d0
	cmp.l %a1,%d0
	jne .L162
	move.l 1100633980,%d0
	jra .L161
.L162:
	mov3q.l #3,%d2
	cmp.l %a1,%d2
	jne .L163
	move.l 1100637004,%d0
	jra .L161
.L163:
	move.l #sfu_draw,%d0
	jra .L161
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
	jcs .L167
	moveq #84,%d0
	muls.l %d0,%d1
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	add.l #1100630172,%d1
	move.l %d1,-(%sp)
	jsr xname
.L173:
	lea (12,%sp),%sp
.L168:
	clr.b %d0
	move.b %d0,24(%sp)
	tst.b 16(%sp)
	jeq .L172
	move.l %a6,%d2
.L171:
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
.L167:
	add.l #-16,%d1
	moveq #11,%d2
	cmp.l %d1,%d2
	jcs .L168
	mov3q.l #6,%d3
	rems.l %d3,%d2:%d1
	cmp.l #1847,%d0
	shi %d0
	move.l %d2,%a1
	mvs.b %d0,%d0
	neg.l %d0
	tst.l %d2
	jne .L169
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	move.l %d0,-(%sp)
	jsr type_text
	jra .L173
.L169:
	mov3q.l #1,%d3
	cmp.l %d2,%d3
	jne .L170
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	clr.l -(%sp)
	jsr sfu_route_text
	jra .L173
.L170:
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	clr.l -(%sp)
	pea -2(%a1)
	move.l %d0,-(%sp)
	jsr ptext
	lea (20,%sp),%sp
	jra .L168
.L172:
	move.l #s_wide,%d2
	jra .L171
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
	jge .L175
	mvz.b 5(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L175
	mvz.b 4(%a0),%d1
	moveq #33,%d4
	cmp.l %d1,%d4
	jne .L176
	addq.l #1,sfu_x+1280
	tst.b 6(%a0)
	jeq .L177
	clr.b %d5
	mov3q.l #1,sfu_x+1276
	lea sfu_st,%a1
	clr.l %d1
	move.b %d5,sfu_x+1148
.L178:
	clr.b (%a1)
	addq.l #1,%d1
	addq.l #8,%a1
	cmp.l #128,%d1
	jne .L178
	clr.b %d1
	move.l #1330005504,%d2
	addq.l #1,sfu_x+1040
	move.l %d2,sfu_st
	move.b %d1,sfu_x
	move.b %d1,sfu_x+130
	move.b %d1,sfu_x+260
	move.b %d1,sfu_x+390
	move.b %d1,sfu_x+520
	move.b %d1,sfu_x+650
	move.b %d1,sfu_x+780
	move.b %d1,sfu_x+910
.L177:
	subq.l #1,%d0
	addq.l #8,%a0
	moveq #9,%d3
	lea sfu_st,%a3
	lea sfu_x+1148,%a4
.L179:
	move.l %d3,%d1
	add.l #12,%d1
	cmp.l %d0,%d1
	jlt .L188
	moveq #2,%d0
	addq.l #1,sfu_x+1556
	addq.l #1,sfu_x+1280
	move.b %d0,sfu_st+1027
.L175:
	mov3q.l #1,-(%sp)
	move.l 36(%sp),-(%sp)
	jsr timed
	movem.l 8(%sp),#15420
	mov3q.l #1,%d0
	lea (44,%sp),%sp
	rts
.L188:
	move.b (%a0),%d2
	jmi .L180
	move.b %d2,%d1
	sub.l %a2,%a2
	ext.w %d1
	mvz.w %d1,%d1
	lsl.l #3,%d1
	move.l %d1,%a1
	add.l #sfu_st,%a1
.L184:
	move.b 1(%a0,%a2.l),%d1
	moveq #94,%d5
	move.l %d1,%d4
	add.l #-32,%d4
	mvz.b %d4,%d4
	cmp.l %d4,%d5
	jcs .L181
	move.b %d1,(%a1,%a2.l)
.L182:
	addq.l #1,%a2
	mov3q.l #7,%d5
	cmp.l %a2,%d5
	jne .L184
	jra .L183
.L181:
	clr.b %d4
	move.b %d4,(%a1,%a2.l)
	tst.b %d1
	jne .L182
.L183:
	mvz.b %d2,%d4
	clr.b %d5
	sub.l %a1,%a1
	move.l %d4,%d1
	lsl.l #3,%d1
	move.b %d5,7(%a3,%d1.l)
	move.l sfu_x+1276,%d1
.L185:
	cmp.l %a1,%d1
	jle .L186
	mvz.b (%a4,%a1.l),%d5
	cmp.l %d4,%d5
	jne .L187
.L186:
	cmp.l %d1,%a1
	jne .L180
	cmp.l #128,%d1
	jeq .L180
	move.l %d1,%a1
	add.l #sfu_x,%d1
	move.l %d1,%a2
	addq.l #1,%a1
	move.b %d2,1148(%a2)
	move.l %a1,sfu_x+1276
.L180:
	lea (14,%a0),%a0
	add.l #14,%d3
	jra .L179
.L187:
	addq.l #1,%a1
	jra .L185
.L176:
	moveq #36,%d2
	cmp.l %d1,%d2
	jne .L189
	moveq #23,%d3
	cmp.l %d0,%d3
	jge .L190
	mov3q.l #7,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L190
	move.b 6(%a0),%d2
	moveq #127,%d4
	mvz.b %d2,%d1
	cmp.l %d1,%d4
	jge .L191
.L190:
	addq.l #1,sfu_x+1104
	jra .L175
.L191:
	lea sfu_x,%a2
	addq.l #1,%d1
	move.l %a2,%a3
	clr.l %d3
.L194:
	mvz.b (%a3),%d4
	move.l %a3,%a1
	cmp.l %d4,%d1
	jeq .L192
	sub.l %a1,%a1
.L192:
	addq.l #1,%d3
	moveq #8,%d5
	cmp.l %d3,%d5
	jeq .L216
	lea (130,%a3),%a3
	tst.l %a1
	jeq .L194
.L216:
	clr.l %d1
.L196:
	tst.l %a1
	jeq .L198
.L199:
	clr.b (%a1)
	move.l %a1,%a3
	clr.l %d1
.L200:
	mvz.w %d1,%d3
	sub.l %a2,%a2
	lea (%a0,%d3.l*4),%a4
.L202:
	move.b 7(%a4,%a2.l),%d4
	moveq #94,%d5
	move.l %d4,%d3
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcs .L201
	move.b %d4,2(%a3,%a2.l)
	addq.l #1,%a2
	mov3q.l #4,%d3
	cmp.l %a2,%d3
	jne .L202
.L201:
	move.l %d1,%a5
	addq.l #5,%a3
	lea (%a5,%d1.l*4),%a4
	clr.b %d3
	addq.l #1,%d1
	mov3q.l #4,%d4
	add.l %a1,%a4
	move.b %d3,2(%a2,%a4.l)
	cmp.l %d1,%d4
	jne .L200
	moveq #127,%d5
	cmp.l %d0,%d5
	jlt .L217
	asr.l #3,%d0
	move.l %d0,%d3
	subq.l #3,%d3
.L204:
	move.l %a1,%d0
	clr.l %d1
	lea (23,%a0),%a0
	add.l #22,%d0
.L205:
	cmp.l %d1,%d3
	jne .L208
	addq.l #1,%d2
	move.b %d1,1(%a1)
	move.b %d2,(%a1)
	addq.l #1,sfu_x+1108
	addq.l #1,sfu_x+1040
	jra .L175
.L198:
	tst.b (%a2)
	jne .L195
	move.l %a2,%a1
.L195:
	addq.l #1,%d1
	lea (130,%a2),%a2
	moveq #8,%d3
	cmp.l %d1,%d3
	jne .L196
	tst.l %a1
	jne .L199
	jra .L190
.L217:
	moveq #12,%d3
	jra .L204
.L208:
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
.L207:
	move.b 3(%a0,%a2.l),%d4
	move.l %d4,%a3
	lea (-32,%a3),%a3
	move.w %a3,%d5
	mvz.b %d5,%d5
	move.l %d5,%a3
	moveq #94,%d5
	cmp.l %a3,%d5
	jcs .L206
	move.b %d4,25(%a4,%a2.l)
	addq.l #1,%a2
	mov3q.l #5,%d4
	cmp.l %a2,%d4
	jne .L207
.L206:
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
	jra .L205
.L189:
	moveq #34,%d2
	cmp.l %d1,%d2
	jne .L175
	moveq #8,%d3
	cmp.l %d0,%d3
	jeq .L175
	mvz.b 6(%a0),%d2
	mov3q.l #1,%d4
	cmp.l %d2,%d4
	jcs .L175
	mvz.b 8(%a0),%d3
	move.b 7(%a0),%d1
	subq.l #3,%d3
	tst.l %d3
	jne .L218
	move.b %d1,%d3
.L209:
	lea sfu_st,%a3
	lea (%a3,%d2.l),%a1
	move.b %d3,1024(%a1)
	mvz.b 8(%a0),%d2
	subq.l #3,%d2
	tst.l %d2
	jne .L175
	tst.b %d1
	jlt .L175
	mvz.b %d1,%d2
	lsl.l #3,%d2
	tst.b (%a3,%d2.l)
	jne .L175
	ext.w %d1
	subq.l #1,%d0
	sub.l %a2,%a2
	mvz.w %d1,%d1
	lsl.l #3,%d1
	lea (%a3,%d1.l),%a1
	moveq #9,%d1
.L210:
	cmp.l %d0,%d1
	jge .L212
	move.b (%a0,%d1.l),%d4
	moveq #94,%d5
	move.l %d4,%d3
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcs .L212
	move.b %d4,(%a1,%a2.l)
	addq.l #1,%a2
	addq.l #1,%d1
	mov3q.l #7,%d3
	cmp.l %a2,%d3
	jne .L210
.L212:
	clr.b %d4
	add.l %d2,%a3
	move.b %d4,(%a3,%a2.l)
	jra .L175
.L218:
	st %d3
	jra .L209
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
	lea sfu_x+1420,%a0
	clr.l %d5
	lea sfu_x+1048,%a6
	move.l %a0,44(%sp)
	clr.l 52(%sp)
	clr.l 48(%sp)
.L267:
	mvz.b (%a6)+,%d1
	lea sfu_x,%a0
	clr.l %d0
	addq.l #1,%d1
.L245:
	mvz.b (%a0),%d2
	cmp.l %d2,%d1
	jne .L243
	mulu.w #130,%d0
	move.l %d0,%a2
	add.l #sfu_x,%a2
.L244:
	move.l 48(%sp),%d3
	moveq #48,%d6
	move.l 52(%sp),%a0
	addq.l #4,%a0
	move.l %d5,%a4
	move.l %a2,%d7
	muls.l %d6,%d3
	add.l #sfu_x+1052,%a4
	sub.l %a3,%a3
	move.l %a0,64(%sp)
	move.l %d3,68(%sp)
.L266:
	tst.l %a2
	jeq .L281
	sub.l %a0,%a0
.L246:
	move.b 2(%a0,%d7.l),%d0
	jeq .L248
	move.b %d0,(%a4,%a0.l)
	addq.l #1,%a0
	mov3q.l #4,%d0
	cmp.l %a0,%d0
	jne .L246
.L248:
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
.L250:
	mvz.b 1(%a2),%d3
	cmp.l 56(%sp),%d3
	jle .L252
	moveq #12,%d3
	cmp.l 56(%sp),%d3
	jne .L253
.L252:
	tst.l %d4
	jeq .L254
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L254
	move.l 44(%sp),%a1
	mov3q.l #2,%d0
	move.b %d1,(%a1,%a3.l)
	cmp.l %d1,%d0
	jeq .L257
.L282:
	mov3q.l #1,%d0
	jra .L256
.L271:
	mov3q.l #1,48(%sp)
	jra .L267
.L243:
	addq.l #1,%d0
	lea (130,%a0),%a0
	moveq #8,%d2
	cmp.l %d0,%d2
	jne .L245
	sub.l %a2,%a2
	jra .L244
.L253:
	move.l %d2,%a1
	mov3q.l #3,%d6
	move.b (%a1),%d3
	and.l %d3,%d6
	cmp.l %d6,%a3
	jne .L251
	moveq #8,%d6
	and.l %d6,%d3
	lea (1,%a1),%a5
	or.l %d3,%d4
	move.l %d0,%d3
	add.l %d1,%d3
	move.l %d3,%a1
	addq.l #1,%d1
	move.b (%a5),1428(%a1)
.L251:
	addq.l #1,56(%sp)
	add.l #9,%d2
	jra .L250
.L281:
	clr.b %d6
	move.l %a3,%d0
	add.l #50,%d0
	move.b #80,(%a4)
	move.b %d0,1(%a4)
	move.b %d6,2(%a4)
.L254:
	clr.b %d1
	move.l 44(%sp),%a0
	clr.l %d0
	move.b %d1,(%a0,%a3.l)
	clr.l %d1
.L256:
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
	jne .L266
	move.b -1(%a6),1(%a6)
	addq.l #6,52(%sp)
	addq.l #4,44(%sp)
	add.l #20,%d5
	mov3q.l #1,%d1
	cmp.l 48(%sp),%d1
	jne .L271
	movem.l (%sp),#31996
	addq.l #1,sfu_x+1120
	lea (72,%sp),%sp
	rts
.L257:
	mvz.b 1(%a2),%d2
	clr.l %d0
	sub.l %a1,%a1
	move.l %d2,60(%sp)
.L258:
	cmp.l 60(%sp),%a1
	jge .L264
	moveq #12,%d3
	cmp.l %a1,%d3
	jne .L265
.L264:
	mov3q.l #2,%d6
	cmp.l %d0,%d6
	jne .L282
	mov3q.l #2,%d1
	jra .L256
.L265:
	move.b (%a0),%d2
	mov3q.l #3,%d3
	and.l %d3,%d2
	cmp.l %d2,%a3
	jne .L259
	lea (3,%a0),%a5
	move.l %a5,56(%sp)
	tst.l %d0
	jeq .L269
	move.l #.LC0,%d6
.L260:
	clr.l %d4
.L262:
	move.l %d6,%a5
	move.b (%a5,%d4.l),%d3
	move.l 56(%sp),%a5
	move.b (%a5,%d4.l),%d2
	tst.b %d3
	jeq .L261
	mvs.b %d3,%d3
	mvs.b %d2,%d2
	addq.l #1,%d4
	cmp.l %d3,%d2
	jeq .L262
	jra .L282
.L269:
	move.l #.LC1,%d6
	jra .L260
.L261:
	tst.b %d2
	jne .L282
	addq.l #1,%d0
	mov3q.l #2,%d2
	cmp.l %d0,%d2
	jlt .L282
.L259:
	addq.l #1,%a1
	lea (9,%a0),%a0
	jra .L258
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
	move.l sfu_x+1044,%a0
	move.l %d0,%d2
	asr.l #8,%d2
	moveq #127,%d0
	and.l %d0,%d2
	move.b %d3,sfu_x+1048
	move.b %d2,sfu_x+1049
	cmp.l sfu_x+1040.l,%a0
	jne .L284
	mvz.b sfu_x+1050,%d0
	cmp.l %d0,%d3
	jne .L284
	mvz.b sfu_x+1051,%d0
	cmp.l %d0,%d2
	jeq .L285
.L284:
	lea sfu_x+1040,%a0
	move.l (%a0),sfu_x+1044
	jsr relabel
.L285:
	move.l %d3,-(%sp)
	clr.l -(%sp)
	lea tcache,%a0
	jsr (%a0)
	addq.l #8,%sp
	move.b sfu_x+1540,%d0
	move.l sfu_x+1412,%d1
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
	move.b sfu_x+1541,%d0
	move.l sfu_x+1412,%d1
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
	jcs .L288
	btst #0,%d0
	jeq .L289
	lsl.l #7,%d2
.L289:
	and.l #32512,%d2
.L287:
	move.l %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L288:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L287
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
	jcs .L294
	tst.b sfu_st+1026.l
	jeq .L296
	move.l %d4,-(%sp)
	jsr sync
	addq.l #4,%sp
.L296:
	btst #0,%d3
	jeq .L297
	lsl.l #7,%d2
.L297:
	and.l #32512,%d2
	move.l %d3,16(%sp)
	move.l %d2,20(%sp)
	movem.l (%sp),#28
	lea (12,%sp),%sp
	jra to_knob
.L294:
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
	move.l %d3,%d5
	move.l 28(%sp),%d4
	add.l #-14,%d5
	move.l 36(%sp),%d2
	move.l 40(%sp),16(%sp)
	move.l 44(%sp),20(%sp)
	cmp.l %d5,%d0
	jcs .L300
	move.l %d3,-(%sp)
	move.l %d4,-(%sp)
	addq.l #1,sfu_st+1030
	jsr 1074433530
	move.l %d2,-(%sp)
	move.l %d0,-(%sp)
	move.l %d5,-(%sp)
	jsr merge
	lea (20,%sp),%sp
	move.l %d0,%d2
.L301:
	move.l %d2,36(%sp)
	move.l %d3,32(%sp)
	move.l %d4,28(%sp)
	movem.l (%sp),#60
	move.l 20(%sp),44(%sp)
	move.l 16(%sp),40(%sp)
	lea (24,%sp),%sp
	jmp 1074438046
.L300:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L301
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr x_half
	addq.l #8,%sp
	move.l %d0,%d2
	jra .L301
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
	jcs .L306
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
	jge .L307
	move.l %d5,%d0
	mov3q.l #6,%d6
	add.l #-16,%d0
	rems.l %d6,%d1:%d0
	tst.l %d1
	jne .L307
	mov3q.l #7,%d0
	cmp.l %d3,%d0
	slt %d3
	move.l %d2,%d0
	asr.l #8,%d0
	lea sfu_x,%a0
	mvs.b %d3,%d3
	sub.l %d3,%a0
	move.b %d0,1048(%a0)
.L307:
	moveq #37,%d1
	cmp.l %d4,%d1
	jlt .L310
.L306:
	move.l %d2,44(%sp)
	move.l %d5,40(%sp)
	move.l %a2,36(%sp)
	movem.l (%sp),#1148
	move.l 28(%sp),52(%sp)
	move.l 24(%sp),48(%sp)
	lea (32,%sp),%sp
	jmp 1074438172
.L310:
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
	jcs .L312
	mov3q.l #6,%d4
	rems.l %d4,%d2:%d0
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jge .L318
.L312:
	move.l %a0,-(%sp)
	move.l %d3,-(%sp)
	move.l %d1,-(%sp)
	jsr 1074436168
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jlt .L311
	move.l %d3,%d0
	moveq #13,%d1
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcs .L315
	btst #0,%d0
	jeq .L316
	lsl.l #7,%d2
.L316:
	and.l #32512,%d2
.L311:
	move.l %d2,%d0
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L315:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L311
	move.l %d2,20(%sp)
	move.l %d3,16(%sp)
	movem.l (%sp),#28
	lea (12,%sp),%sp
	jra x_knob
.L318:
	mov3q.l #-1,%d2
	jra .L311
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
	jcc .L320
.L324:
	move.l %a0,-(%sp)
	moveq #13,%d4
	move.l %d1,-(%sp)
	move.l %d1,%d2
	add.l #-14,%d2
	move.l %d3,-(%sp)
	jsr 1074436538
	lea (12,%sp),%sp
	cmp.l %d2,%d4
	jcc .L330
.L319:
	movem.l (%sp),#28
	lea (16,%sp),%sp
	rts
.L320:
	mov3q.l #6,%d4
	rems.l %d4,%d2:%d0
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jlt .L324
	mov3q.l #-1,%d0
	jra .L319
.L330:
	tst.l %d0
	jlt .L319
	tst.b sfu_st+1026.l
	jeq .L326
	move.l %d3,-(%sp)
	move.l %d0,16(%sp)
	jsr sync
	addq.l #4,%sp
	move.l 12(%sp),%d0
.L326:
	btst #0,%d2
	jeq .L327
	lsl.l #7,%d0
.L327:
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
	move.l 32(%sp),%d4
	move.l %d4,%d3
	move.l 28(%sp),%d5
	add.l #-14,%d3
	move.l 36(%sp),%d2
	move.l 40(%sp),%d6
	cmp.l %d3,%d0
	jcs .L332
	moveq #15,%d7
	cmp.l %d4,%d7
	jge .L333
	move.l %d4,%d0
	mov3q.l #6,%d7
	add.l #-16,%d0
	rems.l %d7,%d1:%d0
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L334
.L333:
	move.l %d6,-(%sp)
	move.l %d4,-(%sp)
	move.l %d5,-(%sp)
	addq.l #1,sfu_st+1030
	jsr 1074436168
	lea (12,%sp),%sp
	tst.l %d0
	jge .L335
	move.l %d4,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433530
	addq.l #8,%sp
.L335:
	move.l %d2,-(%sp)
	move.l %d0,-(%sp)
	move.l %d3,-(%sp)
	jsr merge
	lea (12,%sp),%sp
	move.l %d0,%d2
.L336:
	move.l %d6,40(%sp)
	move.l %d2,36(%sp)
	move.l %d4,32(%sp)
	move.l %d5,28(%sp)
	movem.l (%sp),#252
	lea (24,%sp),%sp
	jmp 1074436282
.L332:
	move.l %d4,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L336
	move.l %d2,-(%sp)
	move.l %d4,-(%sp)
	jsr x_half
	addq.l #8,%sp
	move.l %d0,%d2
	jra .L336
.L334:
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
	jcs .L341
	moveq #15,%d2
	cmp.l %d3,%d2
	jge .L342
	move.l %d3,%d0
	mov3q.l #6,%d2
	add.l #-16,%d0
	rems.l %d2,%d1:%d0
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L343
.L342:
	move.l %d7,-(%sp)
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	addq.l #1,sfu_st+1030
	jsr 1074436538
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jge .L344
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433680
	addq.l #8,%sp
	move.l %d0,%d2
.L344:
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
.L341:
	move.l %d7,40(%sp)
	move.l %d4,36(%sp)
	move.l %d3,32(%sp)
	move.l %d5,28(%sp)
	movem.l (%sp),#252
	lea (24,%sp),%sp
	jmp 1074436652
.L343:
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
	jge .L346
.L347:
	move.l %d2,24(%sp)
	move.l %a2,20(%sp)
	move.l 40(%a3),%a1
	movem.l (%sp),#3084
	lea (16,%sp),%sp
	jmp (%a1)
.L346:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l %d0,-(%sp)
	move.l 60(%a3),%a0
	jsr (%a0)
	lea (12,%sp),%sp
	tst.l %d0
	jlt .L347
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
	jne .L349
	tst.l 1100664624
	jeq .L350
	tst.l 1100635224
	jeq .L350
	move.l #1075575792,%a0
	clr.l %d2
	clr.l %d1
	lea k_cidx,%a3
.L361:
	mov3q.l #1,%d3
	cmp.l %d1,%d3
	jge .L381
	move.l %d1,%d0
	moveq #10,%d4
	addq.l #3,%d0
	cmp.l %d0,%d4
	jcs .L382
	move.w #57,%a1
	clr.l %d0
.L351:
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
	jne .L352
	tst.l %d1
	jeq .L353
	move.l #l_sfx2,%d4
	move.l %d4,40(%a0)
	move.l #s_sfx2,%d0
.L355:
	move.l #s_empty,%d4
	mov3q.l #1,%d5
	move.l %d0,48(%a0)
	move.l %d4,44(%a0)
	cmp.l %d1,%d5
	jlt .L384
	moveq #60,%d0
.L359:
	mulu.w #84,%d0
	move.l %d0,%a1
	clr.l %d0
	add.l #1100630152,%a1
.L360:
	move.l %d2,%a4
	add.l %d0,%a4
	add.l #1100631328,%a4
	move.l (%a1,%d0.l),(%a4)
	moveq #84,%d3
	addq.l #4,%d0
	cmp.l %d0,%d3
	jne .L360
	addq.l #1,%d1
	add.l #84,%d2
	lea (52,%a0),%a0
	moveq #14,%d4
	cmp.l %d1,%d4
	jne .L361
	move.l #1100664624,%a0
	move.l (%a0),sfu_x+1096
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
	move.l sfu_x+1276,%d1
	move.l %d1,%d0
	move.l %d3,1100632200
	move.l %d4,1100631780
	move.l %d5,1100632284
	lea sfu_st,%a0
.L363:
	tst.b (%a0)
	jeq .L362
	move.l %d0,%a1
	add.l #sfu_x,%a1
	move.b %d2,1148(%a1)
	move.w #1,%a1
	addq.l #1,%d0
.L362:
	addq.l #1,%d2
	addq.l #8,%a0
	cmp.l #128,%d2
	jne .L363
	move.w %a1,%d2
	tst.b %d2
	jeq .L364
	move.l %d0,sfu_x+1276
	move.l %d0,%d1
.L364:
	lea sfu_x+1148,%a0
	clr.l %d0
.L365:
	cmp.l %d0,%d1
	jgt .L366
	move.l %d1,sfu_x+1412
	clr.l %d0
	lea sfu_x+1524,%a0
.L367:
	clr.b %d3
	moveq #14,%d4
	move.b %d3,(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d4
	jne .L367
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
.L349:
	move.l sfu_x+1280,%d0
	mov3q.l #1,%d1
	and.l %d0,%d1
	btst #0,%d0
	jne .L368
	cmp.l sfu_x+1416.l,%d0
	jeq .L368
	move.l sfu_x+1276,%a0
	lea sfu_x+1148,%a1
.L369:
	cmp.l %a0,%d1
	jeq .L370
	cmp.l #128,%d1
	jne .L371
.L370:
	cmp.l sfu_x+1280.l,%d0
	jne .L368
	tst.l %a0
	jeq .L368
	moveq #1,%d1
	move.l %a0,sfu_x+1412
	move.l %d0,sfu_x+1416
	move.b %d1,32(%a2)
.L368:
	move.l sfu_x+1092,%d0
	tst.l %d0
	jeq .L372
	move.l %d0,-(%sp)
	move.l sfu_x+1120,%d2
	jsr sync
	addq.l #4,%sp
	cmp.l sfu_x+1120.l,%d2
	jeq .L373
	moveq #1,%d2
	move.b %d2,32(%a2)
.L373:
	mvz.b sfu_st+1027,%d0
	lsr.l #1,%d0
	jne .L350
	move.w sfu_st+1028,%d0
	moveq #99,%d2
	mvz.w %d0,%d1
	cmp.l %d1,%d2
	jcs .L374
	addq.l #1,%d0
	move.w %d0,sfu_st+1028
	mvz.w %d0,%d0
	moveq #100,%d3
	cmp.l %d0,%d3
	jne .L350
.L374:
	mov3q.l #1,%d4
	cmp.l 1094562388.l,%d4
	jne .L350
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L375
	addq.l #1,sfu_x+1116
.L350:
	clr.l -(%sp)
	move.l 32(%sp),-(%sp)
	jsr timed
	addq.l #8,%sp
	tst.b sfu_st+1026.l
	jeq .L348
	move.l #1481856080,%a0
	cmp.l 1073848892.l,%a0
	jne .L348
	tst.l 1073848900
	jeq .L348
	move.l -66650100,%d2
	move.l 1073848900,%a0
	jsr (%a0)
	tst.l %d0
	jeq .L380
	moveq #1,%d0
	move.b %d0,32(%a2)
.L380:
	move.l -66650100,%d0
	sub.l %d2,%d0
	add.l %d0,sfu_x+5378
	addq.l #1,sfu_x+5386
	cmp.l sfu_x+5382.l,%d0
	jls .L348
	move.l %d0,sfu_x+5382
.L348:
	movem.l (%sp),#7228
	lea (32,%sp),%sp
	rts
.L381:
	move.w #53,%a1
	mov3q.l #-1,%d0
	jra .L351
.L382:
	move.w #56,%a1
	mov3q.l #1,%d0
	jra .L351
.L353:
	move.l #l_sfx1,%d5
	move.l %d5,1075575832
	move.l #s_sfx1,%d0
	jra .L355
.L352:
	move.l %d1,%a4
	subq.l #2,%a4
	move.l %a4,%d3
	mov3q.l #6,%d4
	rems.l %d4,%d5:%d3
	move.l %d5,%a1
	tst.l %d0
	jeq .L383
	lea l_fx2,%a4
.L356:
	move.l %a4,40(%a0)
	tst.l %a1
	jeq .L357
	mov3q.l #1,%d3
	cmp.l %a1,%d3
	jne .L358
	move.l #s_route,%d0
	jra .L355
.L383:
	lea l_fx1,%a4
	jra .L356
.L358:
	lea -10(%a1,%a1.l*4),%a1
	mulu.w #20,%d0
	add.l %a1,%d0
	add.l #sfu_x+1052,%d0
	jra .L355
.L357:
	move.l #s_type,%d0
	jra .L355
.L384:
	mvz.w #410,%d0
	jra .L359
.L366:
	move.b (%a0)+,%d2
	addq.l #1,%d0
	move.b %d2,135(%a0)
	jra .L365
.L371:
	move.b (%a1)+,%d2
	addq.l #1,%d1
	move.b %d2,135(%a1)
	jra .L369
.L372:
	move.l sfu_x+1044,%d3
	cmp.l sfu_x+1040.l,%d3
	jeq .L373
	lea sfu_x+1040,%a0
	move.l (%a0),sfu_x+1044
	jsr relabel
	moveq #1,%d0
	move.b %d0,32(%a2)
	jra .L373
.L375:
	mvz.w #4027,%d5
	cmp.l 1094562392.l,%d5
	jlt .L376
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L377:
	tst.l %a0
	jeq .L376
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L377
	pea (m.0)
	mov3q.l #7,-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	clr.w %d1
	addq.l #1,sfu_x+1112
	move.w %d1,sfu_st+1028
	jra .L350
.L376:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #1,sfu_x+1116
	addq.l #4,%sp
	jra .L350
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
	.size	sfu_x, 5390
sfu_x:
	.zero	5390
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
