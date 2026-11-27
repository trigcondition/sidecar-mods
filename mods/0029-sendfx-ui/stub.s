| Mod 0029 - Sidecar send FX pages: AMPLITUDE 2 (SEND FX 1/2) and the SEND FX 1/2 pages behind DELAY/REVERB.
| GENERATED from sfu.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit sfu.c.
#NO_APP
	.file	"sfu.c"
	.text
#APP
	.globl sfu_x
.set sfu_x, RAM_SFU_X
	.globl sfu_p
.set sfu_p, RAM_SFU_P
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

	  .text
  .globl sfu_tls_det, sfu_tg_det, sfu_tk_det, sfu_pg_det
  .align 2
sfu_tls_det:
  pea (%sp)
  jsr sfu_tls
  addq.l #4,%sp
  tst.l %d0
  bne.s 1f
  lea -12(%sp),%sp
  movem.l %d2-%d3/%a2,(%sp)
  jmp 0x400c0528
1:
  moveq #0,%d0
  rts
  .align 2
sfu_tg_det:
  move.l -72(%fp),-(%sp)
  move.l %a2,-(%sp)
  jsr sfu_tgpaste
  addq.l #8,%sp
  tst.l %d0
  bne.s 1f
  movea.l -72(%fp),%a0
  clr.l %d2
  jmp 0x400c39ea
1:
  pea -12(%fp)
  jsr 0x401a0018
  addq.l #4,%sp
  moveq #0,%d2
  jmp 0x400c3bf6
  .align 2
sfu_tk_det:
  move.l -16(%fp),-(%sp)
  move.l %a2,-(%sp)
  jsr sfu_tkpaste
  addq.l #8,%sp
  tst.l %d0
  bne.s 1f
  movea.l (%a2),%a0
  moveq #1,%d2
  move.l %a2,-(%sp)
  jmp 0x400c4840
1:
  jmp 0x400c4922
  .align 2
sfu_pg_det:
  move.l %a0,-(%sp)
  move.l %a2,-(%sp)
  jsr sfu_pgpaste
  addq.l #8,%sp
  tst.l %d0
  bne.s 1f
  movea.l -16(%fp),%a0
  move.l 6596(%a0),%d3
  movea.l %d5,%a0
  jmp 0x400c3452
1:
  jmp 0x400c35dc

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
	.type	half_of, @function
half_of:
	mov3q.l #1,%d1
	and.l 4(%sp),%d1
	move.l 8(%sp),%d0
	tst.l %d1
	jeq .L5
	lsl.l #7,%d0
.L5:
	and.l #32512,%d0
	rts
	.size	half_of, .-half_of
	.align	2
	.type	merge, @function
merge:
	move.l %d2,-(%sp)
	move.l 16(%sp),%d0
	move.l 12(%sp),%d1
	cmp.l #32512,%d0
	jle .L8
	mvz.w #32512,%d0
.L9:
	move.l 8(%sp),%d2
	btst #0,%d2
	jeq .L10
	asr.l #7,%d0
	and.l #32512,%d1
	and.l #254,%d0
.L12:
	or.l %d1,%d0
	move.l (%sp)+,%d2
	rts
.L8:
	tst.l %d0
	jge .L9
	clr.l %d0
	jra .L9
.L10:
	and.l #32512,%d0
	and.l #254,%d1
	jra .L12
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
	jeq .L14
.L17:
	move.l sfu_x+2452,%d0
	mov3q.l #-1,%a1
	mov3q.l #1,%d3
	lea sfu_x+2324,%a3
	move.l %d0,24(%sp)
	clr.l %d0
.L15:
	cmp.l 24(%sp),%d0
	jne .L20
	move.b %d2,2578(%a0)
	mov3q.l #-1,%d0
	cmp.l %a1,%d0
	jne .L21
	move.w #255,%a1
.L21:
	move.w %a1,%d0
	add.l #646,%d1
	move.l %d4,(%a2,%d1.l*4)
	move.b %d3,2582(%a0)
	move.b %d0,2580(%a0)
	jra .L13
.L14:
	move.l %d1,%d0
	add.l #646,%d0
	cmp.l (%a2,%d0.l*4),%d4
	jne .L17
.L13:
	movem.l (%sp),#3132
	lea (28,%sp),%sp
	rts
.L20:
	mvz.b (%a3,%d0.l),%d5
	cmp.l %d5,%d2
	jne .L18
	move.l %d0,%a1
.L19:
	addq.l #1,%d0
	jra .L15
.L18:
	tst.l %d0
	jeq .L19
	cmp.l %d5,%d2
	jle .L19
	addq.l #1,%d3
	jra .L19
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
	jge .L26
	clr.l %d1
.L26:
	cmp.l %d1,%d2
	jgt .L27
	move.l %d2,%d1
	subq.l #1,%d1
.L27:
	mvz.b %d0,%d0
	cmp.l #255,%d0
	jne .L31
	mvz.b 2582(%a0),%d0
	cmp.l %d0,%d1
	jeq .L29
	jle .L31
	subq.l #1,%d1
.L31:
	add.l %d1,%a1
	mvz.b 2324(%a1),%d0
	move.l %d0,12(%sp)
.L29:
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
	jge .L36
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
	jne .L34
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
	jne .L35
	move.b 2582(%a0),%d0
.L35:
	mvz.b %d0,%d0
.L42:
	lsl.l #8,%d0
.L36:
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L34:
	mov3q.l #1,%d5
	cmp.l %d3,%d5
	jne .L37
	moveq #63,%d1
	cmp.l %a1,%d1
	slt %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L42
.L37:
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
	jeq .L36
	move.l %d3,%d0
	subq.l #1,%d0
	tst.b %d1
	jeq .L39
	moveq #48,%d1
.L40:
	mulu.w #12,%d2
	add.l %d2,%d1
	move.l %d1,%a0
	add.l #sfu_x+2468,%a0
.L41:
	tst.l %d0
	jeq .L42
	mvz.b (%a0,%d0.l),%d1
	cmp.l %d1,%a1
	jge .L42
	subq.l #1,%d0
	jra .L41
.L39:
	clr.l %d1
	jra .L40
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
	jge .L49
	move.l %d0,%d2
	asr.l #8,%d2
	move.l %d2,%a1
	tst.l %d2
	jge .L50
	sub.l %a1,%a1
.L50:
	move.l %d1,%a2
	subq.l #2,%a2
	move.l %a2,%d3
	mov3q.l #6,%d4
	rems.l %d4,%d5:%d3
	move.l %d5,%a0
	tst.l %d5
	jne .L51
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
.L49:
	movem.l (%sp),#3132
	lea (24,%sp),%sp
	rts
.L51:
	mov3q.l #1,%d3
	cmp.l %d5,%d3
	jne .L52
	tst.l %d2
	jle .L55
	mvz.w #32512,%d0
	jra .L49
.L52:
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
	jeq .L49
	cmp.l %a1,%d2
	jgt .L54
	move.l %d2,%a1
	subq.l #1,%a1
.L54:
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
	jra .L49
.L55:
	clr.l %d0
	jra .L49
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
	jcc .L60
.L62:
	clr.l %d0
.L59:
	movem.l (%sp),#7292
	lea (32,%sp),%sp
	rts
.L60:
	tst.b sfu_st+1026.l
	jeq .L62
	move.l #1481856080,%d1
	cmp.l 1073848892.l,%d1
	jne .L62
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
	jeq .L63
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
	jcs .L64
	clr.b %d0
	move.b %d0,2600(%a2)
.L64:
	move.l sfu_st+1034,%d1
	move.l %d2,%a0
	addq.l #1,%d1
	add.l %d5,%a0
	move.l %d1,2854(%a0)
.L63:
	move.w %d3,%d0
	mulu.w #52,%d3
	move.l %d3,%a1
	add.l #1075575064,%a1
	mulu.w #84,%d0
	move.l %d0,%a0
	add.l #1100630152,%a0
	move.l 32(%a0),%d0
	tst.b 2600(%a2)
	jeq .L65
	cmp.l #sfu_xtext,%d0
	jeq .L66
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
.L66:
	mvz.b 2727(%a2),%d0
	subq.l #1,%d0
	lsl.l #8,%d0
	tst.b 6557(%a2)
	jeq .L69
	mvz.w #224,%d1
.L67:
	or.l %d1,%d0
.L72:
	move.l %d0,12(%a1)
.L68:
	mvz.b 2600(%a2),%d0
	jra .L59
.L69:
	clr.l %d1
	jra .L67
.L65:
	cmp.l #sfu_xtext,%d0
	jne .L68
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
	jra .L72
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
	jge .L74
	moveq #127,%d0
.L75:
	mvz.b 2600(%a0),%d2
	mov3q.l #1,%d3
	cmp.l %d2,%d3
	jne .L76
	move.w %a1,%d2
	muls.w %d2,%d0
	asr.l #7,%d0
.L77:
	lsl.l #8,%d0
	tst.b 6557(%a0)
	jeq .L82
	and.l #224,%d1
.L80:
	or.l %d1,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L74:
	tst.l %d0
	jge .L75
	clr.l %d0
	jra .L75
.L76:
	subq.l #2,%d2
	tst.l %d2
	jne .L77
	cmp.l %d0,%a1
	jgt .L77
	tst.b 6430(%a0)
	jne .L81
	move.l %a1,%d0
	subq.l #1,%d0
	jra .L77
.L81:
	clr.l %d0
	jra .L77
.L82:
	clr.l %d1
	jra .L80
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
	jge .L84
	clr.l %d0
.L84:
	mvz.b 2600(%a2),%d1
	cmp.l %a1,%d0
	jlt .L85
	tst.b 6430(%a2)
	jeq .L86
	mov3q.l #2,%d2
	cmp.l %d1,%d2
	jeq .L89
.L86:
	move.l %a1,%d0
	subq.l #1,%d0
.L85:
	subq.l #1,%d1
	tst.l %d1
	jne .L87
	lsl.l #7,%d0
	move.l %a1,%d2
	lea -1(%a1,%d0.l),%a3
	move.l %a3,%d0
	divs.l %d2,%d0
.L87:
	lsl.l #8,%d0
	addq.l #1,sfu_x+2592
	tst.b 6557(%a2)
	jeq .L90
	move.l %a0,%d1
	and.l #224,%d1
.L88:
	or.l %d1,%d0
	movem.l (%sp),#3084
	lea (16,%sp),%sp
	rts
.L89:
	clr.l %d0
	jra .L87
.L90:
	clr.l %d1
	jra .L88
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
	jcs .L92
	move.l %a0,%d5
	lsl.l #2,%d5
	lea sfu_x,%a1
	add.l %d5,%a1
	tst.l 3362(%a1)
	jeq .L92
	add.l #sfu_x,%a0
	tst.b 2600(%a0)
	jeq .L95
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	jsr x_half
	subq.l #1,sfu_x+2592
	addq.l #8,%sp
.L95:
	lea sfu_x,%a0
	add.l %d5,%a0
	move.l %d4,28(%sp)
	move.l %d3,20(%sp)
	movem.l (%sp),#60
	move.l %d0,24(%sp)
	move.l 3362(%a0),%a1
	lea (16,%sp),%sp
	jmp (%a1)
.L92:
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
	jcs .L98
	lea sfu_x,%a2
	lea (%a2,%a0.l*4),%a2
	tst.l 3362(%a2)
	jeq .L98
	add.l #sfu_x,%a0
	move.b 2600(%a0),%d1
	move.l %d1,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	lsr.l #1,%d0
	jne .L98
	move.l %a1,%d0
	asr.l #8,%d0
	tst.l %a1
	jge .L99
	clr.l %d0
.L99:
	mvz.b 2727(%a0),%d2
	cmp.l %d2,%d0
	jlt .L100
	tst.b 6430(%a0)
	jeq .L101
	mvz.b %d1,%d1
	subq.l #2,%d1
	tst.l %d1
	jeq .L103
.L101:
	move.l %d2,%d0
	subq.l #1,%d0
.L100:
	move.l %d0,%a0
	pea 1(%a0)
	pea s_empty
	pea fmt_d
	move.l %d3,-(%sp)
	jsr 1074365954
	movem.l 16(%sp),#1052
	lea (32,%sp),%sp
	rts
.L103:
	clr.l %d0
	jra .L100
.L98:
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
	tst.l sfu_st+1034
	jeq .L105
	move.l sfu_x+2132,%d1
	cmp.l %d1,%d0
	jeq .L105
	tst.l %d1
	jeq .L107
	addq.l #1,sfu_x+2140
.L107:
	move.l %d0,sfu_x+2132
.L105:
	rts
	.size	see_fxset, .-see_fxset
	.align	2
	.type	track_rows, @function
track_rows:
	lea (-20,%sp),%sp
	movem.l #1084,(%sp)
	move.l 32(%sp),%a0
	move.l 24(%sp),%a1
	move.l 24(%sp),%d1
	add.l #5716,%d1
	lea (84,%a1),%a1
	clr.l 4(%a0)
	clr.l (%a0)
.L115:
	tst.l (%a1)
	jle .L112
	lea (-84,%a1),%a2
	clr.l %d0
.L114:
	tst.w (%a2,%d0.l*2)
	jlt .L113
	moveq #31,%d5
	mov3q.l #1,%d4
	and.l %d0,%d5
	move.l %d0,%d2
	lsr.l #3,%d2
	and.l #262140,%d2
	lsl.l %d5,%d4
	or.l %d4,(%a0,%d2.l)
.L113:
	addq.l #1,%d0
	moveq #42,%d2
	cmp.l %d0,%d2
	jne .L114
.L112:
	lea (88,%a1),%a1
	cmp.l %a1,%d1
	jne .L115
	clr.l %d0
	clr.l %d1
.L118:
	move.l %d1,%d2
	lsr.l #3,%d2
	and.l #262140,%d2
	move.l (%a0,%d2.l),%d3
	moveq #31,%d2
	and.l %d1,%d2
	btst %d2,%d3
	jeq .L116
	move.l 28(%sp),%a1
	tst.b (%a1,%d1.l)
	jeq .L119
	mov3q.l #2,%a1
.L117:
	add.l %a1,%d0
.L116:
	addq.l #1,%d1
	moveq #42,%d2
	cmp.l %d1,%d2
	jne .L118
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L119:
	mov3q.l #1,%a1
	jra .L117
	.size	track_rows, .-track_rows
	.align	2
	.type	pat_locks, @function
pat_locks:
	move.l 4(%sp),%a1
	move.l 44(%a1),%a0
	tst.l %a0
	jeq .L126
	moveq #12,%d0
	cmp.l 64(%a1),%d0
	jcs .L126
	move.l (%a0),%a1
	move.l %a0,4(%sp)
	move.l 40(%a1),%a1
	jmp (%a1)
.L126:
	clr.l %d0
	rts
	.size	pat_locks, .-pat_locks
	.align	2
	.type	rows_but, @function
rows_but:
	lea (-24,%sp),%sp
	movem.l #19460,(%sp)
	move.l 28(%sp),%a2
	clr.l %d2
	sub.l %a6,%a6
.L134:
	cmp.l 32(%sp),%a6
	jeq .L133
	pea 16(%sp)
	pea 5632(%a2)
	move.l %a2,-(%sp)
	jsr track_rows
	lea (12,%sp),%sp
	add.l %d0,%d2
.L133:
	addq.l #1,%a6
	lea (5674,%a2),%a2
	moveq #13,%d0
	cmp.l %a6,%d0
	jne .L134
	move.l %d2,%d0
	movem.l (%sp),#19460
	lea (24,%sp),%sp
	rts
	.size	rows_but, .-rows_but
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
	jge .L137
	move.w #127,%a1
.L137:
	mvz.w %a1,%d1
	lsl.l #3,%d1
	move.l %d1,%a0
	add.l #sfu_st,%a0
	tst.b (%a0)
	jne .L138
	moveq #63,%d1
	cmp.l %d0,%d1
	jge .L142
	lea (-63,%a1),%a1
	move.l #s_ufx,%d0
.L139:
	move.l %a1,-(%sp)
	move.l %d0,-(%sp)
	pea fmt_d
	move.l %d3,-(%sp)
	jsr 1074365954
	movem.l 16(%sp),#1036
	lea (28,%sp),%sp
	rts
.L142:
	move.l #s_fx,%d0
	jra .L139
.L138:
	add.l #sfu_st,%d2
	move.l %d2,%a2
	mvz.b 1024(%a2),%d0
	cmp.l %d0,%a1
	jne .L143
	move.l #fmt_bang,%d0
.L141:
	move.l %d3,16(%sp)
	movem.l (%sp),#1036
	move.l %a0,24(%sp)
	move.l %d0,20(%sp)
	lea (12,%sp),%sp
	jmp 1074365954
.L143:
	move.l #fmt_s,%d0
	jra .L141
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
	jeq .L149
	move.l #s_post,%d0
.L148:
	move.l %d0,12(%sp)
	move.l #fmt_s,%d0
	move.l %d0,8(%sp)
	move.l %d1,4(%sp)
	jmp 1074365954
.L149:
	move.l #s_pre,%d0
	jra .L148
	.size	sfu_route_text, .-sfu_route_text
	.align	2
	.type	lab_of, @function
lab_of:
	move.l %d2,-(%sp)
	move.l 8(%sp),%d1
	clr.l %d0
	addq.l #1,%d1
	lea sfu_x,%a0
.L153:
	mvz.b (%a0),%d2
	cmp.l %d2,%d1
	jne .L151
	mulu.w #130,%d0
	add.l #sfu_x,%d0
.L150:
	move.l (%sp)+,%d2
	rts
.L151:
	addq.l #1,%d0
	lea (130,%a0),%a0
	moveq #16,%d2
	cmp.l %d0,%d2
	jne .L153
	clr.l %d0
	jra .L150
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
	jge .L156
	clr.l %d1
.L156:
	tst.l %d7
	jeq .L157
	cmp.l %d1,%d7
	jgt .L158
	move.l %d7,%d1
	subq.l #1,%d1
.L158:
	moveq #48,%d7
	muls.l %d7,%d3
	moveq #12,%d7
	muls.l %d5,%d7
	move.l %d7,%a0
	add.l %d3,%a0
	add.l #sfu_x,%a0
	add.l %d1,%a0
	mvz.b 2468(%a0),%d1
.L157:
	move.l %d1,%a0
	moveq #127,%d1
	cmp.l %a0,%d1
	jge .L159
	move.w #127,%a0
.L159:
	tst.l %d0
	jeq .L160
	move.l %d0,%a1
	clr.l %d1
	mvz.b 1(%a1),%d3
	lea (22,%a1),%a1
	move.l %d3,28(%sp)
	mov3q.l #-1,%d3
.L161:
	cmp.l 28(%sp),%d1
	jge .L163
	moveq #12,%d6
	cmp.l %d1,%d6
	jne .L164
.L163:
	mov3q.l #-1,%d7
	cmp.l %d3,%d7
	jeq .L160
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
	jlt .L173
	moveq #9,%d6
	cmp.l %a1,%d6
	jge .L174
	mov3q.l #2,%d3
.L165:
	move.l %d0,%a0
	lea 25(%a0,%d1.l),%a0
	move.l %a0,%d4
	move.l %d0,%a0
	add.l %d1,%a0
	move.b 22(%a0),%d0
	move.w %d0,%ccr
	jne .L166
	clr.l %d0
.L167:
	tst.b 25(%a0,%d0.l)
	jeq .L168
	addq.l #1,%d0
	mov3q.l #5,%d1
	cmp.l %d0,%d1
	jne .L167
.L168:
	move.l %d3,%a2
	lea 1(%a2,%d0.l),%a0
	mov3q.l #7,%d0
	cmp.l %a0,%d0
	jlt .L175
	move.l #fmt_sn,%d0
.L170:
	move.l %a1,56(%sp)
	move.l %d4,52(%sp)
	move.l %d0,48(%sp)
.L188:
	move.l %d2,44(%sp)
	movem.l (%sp),#1276
	lea (40,%sp),%sp
	jmp 1074365954
.L164:
	move.b (%a1),%d6
	mov3q.l #3,%d7
	and.l %d7,%d6
	cmp.l %d6,%d5
	jne .L162
	mvz.b 1(%a1),%d6
	cmp.l %d6,%a0
	jlt .L162
	move.l %d1,%d3
.L162:
	addq.l #1,%d1
	lea (9,%a1),%a1
	jra .L161
.L173:
	mov3q.l #3,%d3
	jra .L165
.L174:
	mov3q.l #1,%d3
	jra .L165
.L166:
	move.l %d4,52(%sp)
	move.l %d2,44(%sp)
	movem.l (%sp),#1276
	lea fmt_s,%a1
	move.l %a1,48(%sp)
	lea (40,%sp),%sp
	jmp 1074365954
.L175:
	move.l #fmt_n,%d0
	jra .L170
.L160:
	move.l sfu_x+2136,%a1
	tst.l %a1
	jeq .L171
	move.l %d2,52(%sp)
	move.l %d4,48(%sp)
	movem.l (%sp),#1276
	move.l 36(%sp),44(%sp)
	lea (40,%sp),%sp
	jmp (%a1)
.L171:
	move.l #s_empty,%d3
	move.l #fmt_d,%d6
	move.l %a0,56(%sp)
	move.l %d3,52(%sp)
	move.l %d6,48(%sp)
	jra .L188
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
	jge .L206
	move.l %d1,%d0
	mov3q.l #6,%d2
	subq.l #2,%d0
	divs.l %d2,%d0
	tst.l %d0
	jne .L207
	move.w #57,%a1
.L198:
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
	jne .L199
	tst.l %d1
	jeq .L200
	move.l #l_sfx2,%d3
	move.l %d3,40(%a0)
	move.l #s_sfx2,%d0
.L202:
	move.l (%sp)+,%d2
	move.l #s_empty,%d3
	move.l %d3,44(%a0)
	move.l %d0,48(%a0)
	move.l (%sp)+,%d3
	rts
.L206:
	move.w #53,%a1
	mov3q.l #-1,%d0
	jra .L198
.L207:
	move.w #56,%a1
	jra .L198
.L200:
	lea l_sfx1,%a1
	move.l %a1,1075575832
	move.l #s_sfx1,%d0
	jra .L202
.L199:
	subq.l #2,%d1
	mov3q.l #6,%d2
	rems.l %d2,%d3:%d1
	move.l %d3,%a1
	tst.l %d0
	jeq .L208
	move.l #l_fx2,%d1
.L203:
	move.l %d1,40(%a0)
	tst.l %a1
	jeq .L204
	mov3q.l #1,%d1
	cmp.l %a1,%d1
	jne .L205
	move.l #s_route,%d0
	jra .L202
.L208:
	move.l #l_fx1,%d1
	jra .L203
.L205:
	lea -10(%a1,%a1.l*4),%a1
	moveq #20,%d2
	muls.l %d2,%d0
	add.l %a1,%d0
	add.l #sfu_x+2092,%d0
	jra .L202
.L204:
	move.l #s_type,%d0
	jra .L202
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
	jlt .L214
	move.w #57,%a1
	moveq #29,%d0
.L210:
	move.l %d0,4(%a0)
	mov3q.l #1,%d0
	and.l %d1,%d0
	mvz.w #32512,%d2
	move.l %a1,(%a0)
	clr.l 8(%a0)
	move.l %d2,12(%a0)
	move.l %d0,%a1
	btst #0,%d1
	jeq .L215
	move.l %d2,%d0
.L211:
	move.l %d0,16(%a0)
	clr.l 20(%a0)
	mov3q.l #-1,24(%a0)
	mov3q.l #-1,28(%a0)
	clr.l 36(%a0)
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jlt .L216
	move.l #l_fx1,%d0
.L212:
	move.l %d0,40(%a0)
	move.l #s_empty,%d0
	move.l %d0,44(%a0)
	tst.l %a1
	jeq .L217
	move.l #s_wid,%d0
.L213:
	move.l %d0,48(%a0)
	move.l (%sp)+,%d2
	rts
.L214:
	move.w #56,%a1
	clr.l %d0
	jra .L210
.L215:
	clr.l %d0
	jra .L211
.L216:
	move.l #l_fx2,%d0
	jra .L212
.L217:
	move.l #s_base,%d0
	jra .L213
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
.L219:
	lea (%a0,%d0.l),%a2
	moveq #84,%d1
	move.l (%a2),(%a1,%a0.l)
	addq.l #4,%a0
	cmp.l %a0,%d1
	jne .L219
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
	jeq .L228
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jge .L229
	subq.l #1,%d1
	lsl.l #8,%d1
	move.l #1100634268,%a2
.L222:
	moveq #52,%d2
	muls.l %d0,%d2
	move.l #1075575076,%a4
	move.l %a0,%a3
	add.l #sfu_x,%a3
	move.l %d1,(%a4,%d2.l)
	mvz.b 2564(%a3),%d1
	cmp.l %d1,%a1
	jeq .L221
	moveq #84,%d1
	muls.l %d1,%d0
	move.l %d0,%a0
	add.l #1100630152,%a0
	move.l (%a2),(%a0)
	move.l 4(%a2),4(%a0)
	move.l 8(%a2),8(%a0)
	move.l 16(%a2),16(%a0)
	tst.l %a1
	jne .L224
	move.l 1100664640,%d0
.L225:
	move.w %a1,%d1
	move.l %d0,48(%a0)
	move.b %d1,2564(%a3)
.L221:
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	rts
.L228:
	mvz.w #32512,%d1
	move.l #1100664592,%a2
	jra .L222
.L229:
	mvz.w #256,%d1
	move.l #1100634268,%a2
	jra .L222
.L224:
	mov3q.l #2,%d2
	cmp.l %a1,%d2
	jne .L226
	move.l 1100633980,%d0
	jra .L225
.L226:
	mov3q.l #3,%d0
	cmp.l %a1,%d0
	jne .L227
	move.l 1100637004,%d0
	jra .L225
.L227:
	move.l #sfu_draw,%d0
	jra .L225
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
	jeq .L231
	move.l #sfu_type2_text,%d7
.L232:
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
.L235:
	move.l %d3,-(%sp)
	jsr (%a4)
	addq.l #4,%sp
	tst.l %d5
	jeq .L238
	mov3q.l #1,%d1
	cmp.l %d5,%d1
	jeq .L234
	move.l -8(%a2),%d0
.L233:
	moveq #84,%d1
	addq.l #1,%d5
	muls.l %d3,%d1
	addq.l #1,%d3
	addq.l #4,%a2
	move.l %d0,(%a3,%d1.l)
	mov3q.l #6,%d0
	cmp.l %d5,%d0
	jne .L235
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
.L237:
	mov3q.l #5,%d1
	cmp.l %d0,%d1
	jlt .L239
	lea 21(%a1,%d4.l),%a2
.L236:
	move.l %a2,(%a0)+
	moveq #8,%d1
	addq.l #1,%d0
	addq.l #1,%a1
	cmp.l %d0,%d1
	jne .L237
	movem.l (%sp),#7420
	lea (40,%sp),%sp
	rts
.L231:
	move.l #sfu_type1_text,%d7
	jra .L232
.L234:
	move.l #sfu_route_text,%d0
	jra .L233
.L238:
	move.l %d7,%d0
	jra .L233
.L239:
	move.l %a1,%a2
	jra .L236
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
	lea sfu_x+2088,%a0
	clr.l %d2
	lea sfu_p+4240,%a2
	move.l %a0,48(%sp)
	move.l #sfu_pages+36,%d3
	lea sfu_p+4668,%a4
	move.l %a2,%a3
	move.l %a0,%a5
	lea lab_of,%a6
.L255:
	mvz.b (%a5)+,%d4
	move.l %d4,-(%sp)
	jsr (%a6)
	addq.l #4,%sp
	tst.l %d0
	jne .L243
.L245:
	clr.b %d1
	moveq #1,%d0
.L244:
	move.b %d1,4(%a3)
	move.b (%a3),%d1
	move.b %d0,2(%a3)
	tst.b %d1
	jeq .L246
	mvz.b %d0,%d0
	mvz.b %d1,%d1
	cmp.l %d0,%d1
	jcc .L247
	mvz.b 1(%a5),%d0
	cmp.l %d4,%d0
	jeq .L248
.L247:
	clr.b (%a3)
	move.l %d2,-(%sp)
	jsr restore_recs
	move.b sfu_p+4724,%d1
	addq.l #1,sfu_p+4300
	addq.l #4,%sp
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	or.l %d1,%d0
	move.b %d0,sfu_p+4724
.L246:
	mvz.b 2(%a3),%d0
	lsr.l #1,%d0
	jeq .L249
.L248:
	tst.l %d2
	jeq .L300
	move.l #n_fx2,%d1
.L250:
	move.l %a4,%a1
	sub.l %a0,%a0
.L251:
	move.b (%a0,%d1.l),%d0
	jne .L252
	move.b #32,(%a1)
	clr.b %d1
	move.b (%a3),%d0
	add.l #49,%d0
	move.b %d0,1(%a0,%a4.l)
	moveq #47,%d0
	move.b %d0,2(%a4,%a0.l)
	move.b 2(%a3),%d0
	move.b %d1,4(%a4,%a0.l)
	add.l #48,%d0
	move.b %d0,3(%a4,%a0.l)
	move.l %d3,%a0
	move.l %a4,(%a0)
.L253:
	addq.l #1,%a3
	lea (16,%a4),%a4
	add.l #36,%d3
	subq.l #1,%d2
	tst.l %d2
	jne .L302
	lea sfu_x+2460,%a0
	moveq #18,%d1
	move.l %a0,52(%sp)
	lea sfu_pages+40,%a1
	clr.l %d6
	lea sfu_p+4396,%a6
	lea sfu_p+4316,%a0
	move.l %a1,64(%sp)
	move.l %a6,56(%sp)
	move.l %a0,60(%sp)
	clr.l 68(%sp)
	clr.l 72(%sp)
	move.l %d1,76(%sp)
.L298:
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
	move.l %d1,96(%sp)
	tst.l %d6
	jeq .L256
	lea l_fx2,%a0
	move.l %a0,80(%sp)
.L257:
	sub.l %d6,%d0
	moveq #68,%d1
	moveq #48,%d3
	muls.l %d0,%d1
	muls.l %d6,%d3
	move.l 68(%sp),%a3
	clr.l %d2
	move.l 76(%sp),%d7
	add.l #sfu_x+7796,%a3
	move.l 72(%sp),%a4
	add.l #-14,%d7
	add.l #sfu_x+2092,%a4
	move.l %d1,92(%sp)
	move.l %d3,104(%sp)
.L282:
	clr.b (%a3)
	tst.l %a5
	jeq .L258
	sub.l %a0,%a0
	move.w %d2,%d0
	mulu.w #5,%d0
	lea (%a5,%d0.l),%a1
.L259:
	move.b 2(%a1,%a0.l),%d0
	jeq .L260
	move.b %d0,(%a4,%a0.l)
	addq.l #1,%a0
	mov3q.l #4,%d4
	cmp.l %a0,%d4
	jne .L259
.L260:
	clr.b %d5
	move.b %d5,(%a4,%a0.l)
	mvz.w sfu_x+7794,%d0
	and.l 96(%sp),%d0
	tst.l %d0
	jeq .L262
	move.l 92(%sp),%a1
	sub.l %a0,%a0
	lea (-1090,%a1),%a1
	add.l %a3,%a1
.L263:
	move.b (%a1,%a0.l),%d0
	move.b %d0,(%a3,%a0.l)
	jeq .L262
	addq.l #1,%a0
	moveq #17,%d0
	cmp.l %a0,%d0
	jne .L263
.L262:
	moveq #12,%d0
	clr.l %d4
	muls.l %d2,%d0
	lea (22,%a5),%a1
	sub.l %a0,%a0
	clr.l %d1
	add.l 104(%sp),%d0
	add.l #sfu_x,%d0
.L264:
	mvz.b 1(%a5),%d3
	cmp.l %d3,%d1
	jge .L266
	moveq #12,%d3
	cmp.l %d1,%d3
	jne .L267
.L266:
	tst.l %d4
	jeq .L341
	mov3q.l #1,%d5
	cmp.l %a0,%d5
	jge .L341
.L268:
	clr.b %d0
	move.w %a0,%d1
	move.l 52(%sp),%a1
	move.l %a2,100(%sp)
	move.b %d0,16(%a3)
	move.b %d1,(%a1,%d2.l)
	tst.b (%a2)
	jne .L270
	tst.b (%a3)
	jeq .L304
	move.l %a3,%d0
.L271:
	moveq #52,%d1
	muls.l %d7,%d1
	move.l #1075575832,%a6
	move.l %d0,(%a6,%d1.l)
	tst.l %a0
	jeq .L305
	mov3q.l #2,%d0
	cmp.l %a0,%d0
	jne .L306
	lea (22,%a5),%a1
	clr.l %d0
	mvz.b 1(%a5),%d1
	move.l %d1,88(%sp)
	clr.l %d1
.L273:
	cmp.l 88(%sp),%d0
	jge .L280
	moveq #12,%d4
	cmp.l %d0,%d4
	jne .L281
.L280:
	mov3q.l #2,%d5
	cmp.l %d1,%d5
	seq %d1
	mvs.b %d1,%d1
	neg.l %d1
	jra .L278
.L302:
	mov3q.l #1,%d2
	jra .L255
.L243:
	sub.l #sfu_x,%d0
	jmi .L245
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L245
	asr.l #1,%d0
	move.l #-1057222719,%d5
	mov3q.l #4,%d7
	muls.l %d5,%d0
	move.l %d0,%a0
	add.l #sfu_p,%a0
	move.b 4224(%a0),%d0
	mvz.b %d0,%d1
	cmp.l %d1,%d7
	jcc .L245
	subq.l #4,%d0
	move.b %d0,%d1
	mvz.b %d0,%d0
	moveq #8,%d5
	cmp.l %d0,%d5
	scc %d0
	addq.l #3,%d0
	jra .L244
.L300:
	move.l #n_fx1,%d1
	jra .L250
.L252:
	move.b %d0,(%a1)+
	addq.l #1,%a0
	jra .L251
.L249:
	tst.l %d2
	jeq .L301
	move.l #n_fx2,%d0
.L254:
	move.l %d3,%a1
	move.l %d0,(%a1)
	jra .L253
.L301:
	move.l #n_fx1,%d0
	jra .L254
.L312:
	mov3q.l #1,%d6
	jra .L298
.L256:
	lea l_fx1,%a1
	move.l %a1,80(%sp)
	jra .L257
.L267:
	move.b (%a1),%d3
	mov3q.l #3,%d5
	and.l %d3,%d5
	cmp.l %d5,%d2
	jne .L265
	moveq #8,%d5
	and.l %d5,%d3
	lea (%a0,%d0.l),%a6
	addq.l #1,%a0
	move.b 1(%a1),2468(%a6)
	or.l %d3,%d4
.L265:
	addq.l #1,%d1
	lea (9,%a1),%a1
	jra .L264
.L258:
	clr.b %d4
	move.l %d2,%d0
	add.l #50,%d0
	move.b #80,(%a4)
	move.b %d0,1(%a4)
	move.b %d4,2(%a4)
.L341:
	sub.l %a0,%a0
	jra .L268
.L304:
	move.l 80(%sp),%d0
	jra .L271
.L281:
	move.b (%a1),%d3
	mov3q.l #3,%d4
	and.l %d4,%d3
	cmp.l %d3,%d2
	jne .L274
	lea (3,%a1),%a6
	move.l %a6,84(%sp)
	tst.l %d1
	jeq .L307
	lea .LC0,%a6
.L342:
	move.l %a6,44(%sp)
	clr.l %d5
.L277:
	move.l 44(%sp),%a6
	move.b (%a6,%d5.l),%d4
	move.l 84(%sp),%a6
	move.b (%a6,%d5.l),%d3
	tst.b %d4
	jeq .L276
	mvs.b %d4,%d4
	mvs.b %d3,%d3
	addq.l #1,%d5
	cmp.l %d4,%d3
	jeq .L277
.L279:
	clr.l %d1
.L278:
	addq.l #1,%d1
.L272:
	move.l %a0,-(%sp)
	move.l %d1,-(%sp)
	move.l %d7,-(%sp)
	jsr set_look
	lea (12,%sp),%sp
.L270:
	addq.l #1,%d2
	lea (17,%a3),%a3
	addq.l #1,%d7
	addq.l #5,%a4
	mov3q.l #4,%d0
	cmp.l %d2,%d0
	jne .L282
	move.l 48(%sp),%a0
	addq.l #1,%a2
	move.l 100(%sp),%a1
	move.b -1(%a0),%d0
	move.b %d0,1(%a0)
	tst.b (%a1)
	jeq .L283
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	jsr lab_of
	addq.l #4,%sp
	tst.l %d0
	jeq .L308
	sub.l #sfu_x,%d0
	move.l %d0,%d1
	asr.l #1,%d1
	move.l #-1057222719,%d2
	muls.l %d2,%d1
	tst.l %d0
	jlt .L309
	mvz.w sfu_x+7794,%d3
	mov3q.l #1,%d4
	asr.l %d1,%d3
	and.l %d4,%d3
.L284:
	move.l %d6,%d0
	move.l %d6,%d5
	add.l %d0,%d0
	lsl.l #2,%d5
	moveq #60,%d7
	muls.l %d1,%d7
	move.l 60(%sp),%a3
	move.l 56(%sp),%a4
	move.l 64(%sp),%a6
	move.l %d0,%a5
	subq.l #5,%a5
	mvz.w #204,%d0
	move.l %d5,92(%sp)
	move.l %d7,84(%sp)
	clr.l %d5
	muls.l %d1,%d0
	move.l %d0,88(%sp)
.L297:
	mov3q.l #5,%d1
	cmp.l %d5,%d1
	jlt .L310
	move.l 92(%sp),%a0
	lea 21(%a5,%a0.l),%a0
	move.l %a0,%d4
.L285:
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
	jeq .L286
	mvz.b 3(%a2),%d0
	cmp.l %d2,%d0
	jle .L287
	move.l %d2,%a1
	lea (%a1,%d2.l*4),%a1
	move.l %a1,%d0
	sub.l %a1,%a1
	add.l 84(%sp),%d0
	add.l #sfu_p,%d0
.L288:
	move.b (%a1,%d0.l),%d1
	jeq .L289
	move.b %d1,(%a3,%a1.l)
	addq.l #1,%a1
	mov3q.l #4,%d1
	cmp.l %a1,%d1
	jne .L288
.L289:
	move.l %d2,%d0
	lsl.l #4,%d0
	clr.b %d7
	add.l %d2,%d0
	add.l 88(%sp),%d0
	move.b %d7,(%a3,%a1.l)
	sub.l %a1,%a1
	add.l #sfu_p+960,%d0
.L291:
	move.b (%a1,%d0.l),%d1
	jeq .L292
	move.b %d1,(%a4,%a1.l)
	addq.l #1,%a1
	moveq #16,%d1
	cmp.l %a1,%d1
	jne .L291
.L292:
	clr.b %d7
	move.b %d7,(%a4,%a1.l)
.L286:
	mvz.b 3(%a2),%d0
	cmp.l %d2,%d0
	jle .L287
	tst.b (%a3)
	jne .L287
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
.L287:
	move.l %a3,48(%a0)
	tst.b (%a4)
	jeq .L311
	move.l %a4,%d0
.L294:
	mvz.w #32512,%d1
	move.l %d0,40(%a0)
	clr.l 16(%a0)
	mov3q.l #5,%d7
	move.l %d1,12(%a0)
	cmp.l %d5,%d7
	jlt .L295
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
.L295:
	mvz.b 3(%a2),%d0
	cmp.l %d2,%d0
	jgt .L296
	clr.l 100(%sp)
.L296:
	move.l 100(%sp),(%a6)+
	addq.l #1,%d5
	lea (17,%a4),%a4
	addq.l #5,%a3
	addq.l #1,%a5
	moveq #8,%d0
	cmp.l %d5,%d0
	jne .L297
.L283:
	mvz.w #136,%d4
	moveq #20,%d1
	moveq #68,%d2
	moveq #36,%d3
	moveq #40,%d5
	addq.l #4,52(%sp)
	addq.l #6,76(%sp)
	add.l %d1,72(%sp)
	add.l %d2,68(%sp)
	subq.l #1,%d6
	add.l %d3,64(%sp)
	add.l %d4,56(%sp)
	add.l %d5,60(%sp)
	tst.l %d6
	jne .L312
	movem.l (%sp),#31996
	addq.l #1,sfu_x+2160
	lea (108,%sp),%sp
	rts
.L307:
	lea .LC1,%a6
	jra .L342
.L276:
	tst.b %d3
	jne .L279
	addq.l #1,%d1
	mov3q.l #2,%d3
	cmp.l %d1,%d3
	jlt .L279
.L274:
	addq.l #1,%d0
	lea (9,%a1),%a1
	jra .L273
.L305:
	clr.l %d1
	jra .L272
.L306:
	mov3q.l #1,%d1
	jra .L272
.L308:
	mov3q.l #-1,%d1
.L309:
	clr.l %d3
	jra .L284
.L310:
	move.l %a5,%d4
	jra .L285
.L311:
	move.l 80(%sp),%d0
	jra .L294
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
	jcs .L344
	moveq #84,%d0
	muls.l %d0,%d1
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	add.l #1100630172,%d1
	move.l %d1,-(%sp)
	jsr xname
.L350:
	lea (12,%sp),%sp
.L345:
	clr.b %d0
	move.b %d0,24(%sp)
	tst.b 16(%sp)
	jeq .L349
	move.l %a6,%d2
.L348:
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
.L344:
	add.l #-16,%d1
	moveq #11,%d2
	cmp.l %d1,%d2
	jcs .L345
	mov3q.l #6,%d3
	rems.l %d3,%d2:%d1
	cmp.l #1847,%d0
	shi %d0
	move.l %d2,%a1
	mvs.b %d0,%d0
	neg.l %d0
	tst.l %d2
	jne .L346
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	move.l %d0,-(%sp)
	jsr type_text
	jra .L350
.L346:
	mov3q.l #1,%d3
	cmp.l %d2,%d3
	jne .L347
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	clr.l -(%sp)
	jsr sfu_route_text
	jra .L350
.L347:
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	clr.l -(%sp)
	pea -2(%a1)
	move.l %d0,-(%sp)
	jsr ptext
	lea (20,%sp),%sp
	jra .L345
.L349:
	move.l #s_wide,%d2
	jra .L348
	.size	sfu_draw, .-sfu_draw
	.align	2
	.type	top_page, @function
top_page:
	lea (-16,%sp),%sp
	movem.l #1052,(%sp)
	move.l sfu_p+4308,%d3
	move.l 20(%sp),%a1
	tst.l %d3
	jeq .L352
	move.l 28(%a1),%a0
	moveq #16,%d4
	clr.l %d2
	clr.l %d0
	lea (20,%a1),%a1
.L353:
	tst.l %a0
	jeq .L360
	cmp.l %a0,%a1
	jeq .L360
	move.l 8(%a0),%a2
	tst.l %a2
	jne .L354
.L352:
	clr.l %d0
.L351:
	movem.l (%sp),#1052
	lea (16,%sp),%sp
	rts
.L354:
	move.l (%a2),%d1
	tst.l %d0
	jeq .L356
	cmp.l #1075718412,%d1
	jeq .L358
	cmp.l #1075712228,%d1
	jeq .L358
	cmp.l #1075719596,%d1
	jeq .L358
	cmp.l #1075717140,%d1
	jne .L352
.L358:
	move.l (%a0),%a0
	subq.l #1,%d4
	tst.l %d4
	jne .L353
.L360:
	tst.l %d0
	jeq .L351
	tst.l %d2
	jeq .L363
	move.l sfu_p+4312,%a0
	clr.l -(%sp)
	move.l %d3,-(%sp)
	move.l 156(%a0),%a0
	jsr (%a0)
	addq.l #8,%sp
	moveq #16,%d1
	cmp.l %d0,%d1
	jne .L364
.L363:
	move.l %d2,%d0
	jra .L351
.L356:
	cmp.l #1076055292,%d1
	jeq .L365
	cmp.l %d3,%a2
	jne .L358
	cmp.l sfu_p+4312.l,%d1
	seq %d1
	mvs.b %d1,%d1
	neg.l %d1
	or.l %d1,%d2
	jra .L358
.L365:
	mov3q.l #1,%d0
	jra .L358
.L364:
	moveq #22,%d1
	cmp.l %d0,%d1
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
	add.l %d0,%d0
	jra .L351
	.size	top_page, .-top_page
	.align	2
	.type	retitle, @function
retitle:
	link.w %fp,#-8
	move.l %a2,-(%sp)
	move.l 8(%fp),%a2
	clr.l -4(%fp)
	move.l (%a2),%a0
	move.l %a2,-(%sp)
	move.l 76(%a0),%a0
	jsr (%a0)
	pea -5(%fp)
	move.l %d0,-(%sp)
	pea -4(%fp)
	jsr 1075563852
	pea -4(%fp)
	move.l 108(%a2),-(%sp)
	jsr 1073962984
	pea -4(%fp)
	jsr 1075557020
	lea (28,%sp),%sp
	move.l -12(%fp),%a2
	addq.l #1,sfu_p+4304
	unlk %fp
	rts
	.size	retitle, .-retitle
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
	jcs .L392
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
.L393:
	move.l 16(%sp),%a1
	move.l %a0,(%a1)
	tst.l sfu_st+1034
	jeq .L396
	add.l #sfu_p,%a0
	move.b 4240(%a0),%d0
	jeq .L396
	mvz.b %d0,%d0
	subq.l #1,%d0
	lsl.l #3,%d0
	add.l %d1,%d0
	mvz.b 4244(%a0),%d1
	cmp.l %d1,%d0
	jlt .L391
	moveq #-2,%d0
	jra .L391
.L392:
	subq.l #1,%d0
	mov3q.l #3,%d1
	cmp.l %d0,%d1
	jcc .L394
.L396:
	mov3q.l #-1,%d0
.L391:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L394:
	move.l %d0,%d2
	mov3q.l #1,%d3
	and.l %d3,%d0
	asr.l #1,%d2
	move.l %d2,%a0
	move.l %d0,%d1
	addq.l #6,%d1
	jra .L393
	.size	pq, .-pq
	.align	2
	.type	kitsig, @function
kitsig:
	lea (-12,%sp),%sp
	movem.l #3076,(%sp)
	tst.l sfu_x+2132
	jeq .L404
	move.w 18(%sp),%d1
	sub.l %a2,%a2
	clr.l %d0
	mulu.w #6,%d1
	move.l %d1,%a3
	lea (16,%a3),%a3
.L403:
	pea (%a3,%a2.l)
	move.l #-1640531535,%d2
	muls.l %d0,%d2
	move.l sfu_x+2132,-(%sp)
	jsr 1074433680
	addq.l #1,%a2
	addq.l #8,%sp
	mov3q.l #6,%d1
	add.l %d2,%d0
	cmp.l %a2,%d1
	jne .L403
.L401:
	movem.l (%sp),#3076
	lea (12,%sp),%sp
	rts
.L404:
	clr.l %d0
	jra .L401
	.size	kitsig, .-kitsig
	.align	2
	.type	try_send, @function
try_send:
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jeq .L407
.L413:
	clr.l %d0
.L406:
	rts
.L407:
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L409
	addq.l #1,sfu_x+2156
	jra .L406
.L409:
	mvz.w #4027,%d0
	cmp.l 1094562392.l,%d0
	jlt .L410
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L411:
	tst.l %a0
	jeq .L410
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L411
	move.l 4(%sp),-(%sp)
	move.l 12(%sp),-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	mov3q.l #1,%d0
	jra .L406
.L410:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #1,sfu_x+2156
	addq.l #4,%sp
	jra .L413
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
	jge .L420
	mvz.b 4(%a0),%d1
	moveq #34,%d3
	cmp.l %d1,%d3
	jne .L421
	mvz.b 5(%a0),%d1
	subq.l #3,%d1
	tst.l %d1
	jne .L422
	mvz.b 6(%a0),%d2
	mov3q.l #1,%d5
	cmp.l %d2,%d5
	jcs .L421
	mvz.b 7(%a0),%d3
	mov3q.l #4,%d7
	cmp.l %d3,%d7
	jcc .L421
	move.b 8(%a0),%d1
	jeq .L421
	mvz.b %d1,%d1
	moveq #17,%d4
	add.l %d1,%d3
	cmp.l %d3,%d4
	jlt .L421
	add.l #9,%d1
	cmp.l %d0,%d1
	jge .L421
	move.l %d2,%d0
	add.l #2135,%d0
	lea sfu_p,%a2
	tst.w (%a2,%d0.l*2)
	jne .L423
	add.l #-1065,%d0
	move.l (%a2,%d0.l*4),%d0
	tst.l %d0
	jeq .L496
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jhi .L496
.L423:
	addq.l #1,sfu_p+4292
.L428:
	mov3q.l #1,-(%sp)
	move.l 48(%sp),-(%sp)
	jsr timed
	movem.l 8(%sp),#15612
	mov3q.l #1,%d0
	lea (60,%sp),%sp
	rts
.L427:
	move.b 9(%a0,%a1.l),%d0
	mvz.b 7(%a0),%d3
	moveq #127,%d2
	lea -5(%a1,%d3.l),%a3
	and.l %d0,%d2
	add.l %a2,%a3
	mvz.b 4246(%a3),%d3
	cmp.l %d2,%d3
	jeq .L425
	move.b %d2,4246(%a3)
	mov3q.l #1,%d1
.L425:
	addq.l #1,%a1
.L426:
	mvz.b 8(%a0),%d0
	cmp.l %a1,%d0
	jgt .L427
	tst.l %d1
	jeq .L423
	moveq #1,%d0
	move.b %d0,sfu_p+4274
	jra .L423
.L496:
	moveq #12,%d7
	clr.l %d1
	muls.l %d7,%d2
	sub.l %a1,%a1
	add.l %d2,%a2
	jra .L426
.L420:
	moveq #10,%d1
	cmp.l %d0,%d1
	jne .L429
	mvz.b 4(%a0),%d1
	moveq #34,%d2
	cmp.l %d1,%d2
	jne .L421
.L422:
	mvz.b 5(%a0),%d1
	subq.l #2,%d1
	tst.l %d1
	jne .L421
	mvz.b 6(%a0),%d0
	mov3q.l #1,%d4
	cmp.l %d0,%d4
	jcs .L428
	mvz.b sfu_x+6688,%d1
	lea sfu_x,%a1
	btst %d0,%d1
	jne .L430
	lea (%a1,%d0.l*4),%a2
	move.l 6698(%a2),%d1
	tst.l %d1
	jeq .L431
	move.l -66650100,%d2
	sub.l %d1,%d2
	cmp.l #65999999,%d2
	jls .L430
.L431:
	move.b 7(%a0),%d1
	moveq #127,%d3
	moveq #127,%d5
	move.l %d0,%d2
	add.l #3342,%d2
	mvz.b (%a1,%d2.l*2),%d4
	and.l %d1,%d3
	cmp.l %d4,%d3
	jne .L432
	lea (%a1,%d0.l*2),%a2
	move.b 8(%a0),%d0
	mvz.b 6685(%a2),%d1
	and.l %d5,%d0
	cmp.l %d1,%d0
	jeq .L430
.L432:
	move.b %d3,(%a1,%d2.l*2)
	moveq #127,%d7
	mvz.b 6(%a0),%d0
	lea (%a1,%d0.l*2),%a1
	move.b 8(%a0),%d0
	and.l %d7,%d0
	move.b %d0,6685(%a1)
	moveq #1,%d0
	move.b %d0,sfu_x+6689
.L430:
	addq.l #1,sfu_x+6694
	jra .L428
.L429:
	mov3q.l #7,%d1
	cmp.l %d0,%d1
	jge .L428
.L421:
	mvz.b 5(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L428
	mvz.b 4(%a0),%d1
	moveq #33,%d3
	cmp.l %d1,%d3
	jne .L433
	addq.l #1,sfu_x+2320
	tst.b 6(%a0)
	jeq .L434
	clr.b %d4
	mov3q.l #1,sfu_x+2316
	lea sfu_st,%a1
	clr.l %d1
	move.b %d4,sfu_x+2188
.L435:
	clr.b (%a1)
	addq.l #1,%d1
	addq.l #8,%a1
	cmp.l #128,%d1
	jne .L435
	lea sfu_x,%a1
	clr.l %d1
.L436:
	clr.b (%a1)
	addq.l #1,%d1
	lea (130,%a1),%a1
	moveq #16,%d5
	cmp.l %d1,%d5
	jne .L436
	move.l #1330005504,%d7
	addq.l #1,sfu_x+2080
	move.l %d7,sfu_st
.L434:
	subq.l #1,%d0
	addq.l #8,%a0
	moveq #9,%d3
	lea sfu_st,%a3
	lea sfu_x+2188,%a4
.L437:
	move.l %d3,%d1
	add.l #12,%d1
	cmp.l %d0,%d1
	jlt .L446
	moveq #2,%d0
	addq.l #1,sfu_x+2596
	addq.l #1,sfu_x+2320
	move.b %d0,sfu_st+1027
	jra .L428
.L446:
	move.b (%a0),%d2
	jmi .L438
	move.b %d2,%d1
	sub.l %a2,%a2
	ext.w %d1
	mvz.w %d1,%d1
	lsl.l #3,%d1
	move.l %d1,%a1
	add.l #sfu_st,%a1
.L442:
	move.b 1(%a0,%a2.l),%d1
	moveq #94,%d5
	move.l %d1,%d4
	add.l #-32,%d4
	mvz.b %d4,%d4
	cmp.l %d4,%d5
	jcs .L439
	move.b %d1,(%a1,%a2.l)
.L440:
	addq.l #1,%a2
	mov3q.l #7,%d1
	cmp.l %a2,%d1
	jne .L442
	jra .L441
.L439:
	clr.b %d7
	move.b %d7,(%a1,%a2.l)
	tst.b %d1
	jne .L440
.L441:
	mvz.b %d2,%d4
	clr.b %d5
	sub.l %a1,%a1
	move.l %d4,%d1
	lsl.l #3,%d1
	move.b %d5,7(%a3,%d1.l)
	move.l sfu_x+2316,%d1
.L443:
	cmp.l %a1,%d1
	jle .L444
	mvz.b (%a4,%a1.l),%d5
	cmp.l %d4,%d5
	jne .L445
.L444:
	cmp.l %d1,%a1
	jne .L438
	cmp.l #128,%d1
	jeq .L438
	move.l %d1,%d7
	add.l #sfu_x,%d1
	move.l %d1,%a1
	addq.l #1,%d7
	move.b %d2,2188(%a1)
	move.l %d7,sfu_x+2316
.L438:
	lea (14,%a0),%a0
	add.l #14,%d3
	jra .L437
.L445:
	addq.l #1,%a1
	jra .L443
.L433:
	moveq #36,%d2
	cmp.l %d1,%d2
	jne .L447
	moveq #23,%d3
	cmp.l %d0,%d3
	jge .L448
	mov3q.l #7,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L448
	move.b 6(%a0),%d3
	moveq #127,%d4
	mvz.b %d3,%d1
	cmp.l %d1,%d4
	jge .L449
.L448:
	addq.l #1,sfu_x+2144
	jra .L428
.L449:
	lea sfu_x,%a2
	addq.l #1,%d1
	move.l %a2,%a3
	clr.l %d2
.L452:
	mvz.b (%a3),%d4
	move.l %a3,%a1
	cmp.l %d4,%d1
	jeq .L450
	sub.l %a1,%a1
.L450:
	addq.l #1,%d2
	moveq #16,%d5
	cmp.l %d2,%d5
	jeq .L498
	lea (130,%a3),%a3
	tst.l %a1
	jeq .L452
.L498:
	clr.l %d1
.L454:
	tst.l %a1
	jeq .L456
.L457:
	tst.b (%a1)
	jne .L458
	move.l %a1,%d1
	sub.l #sfu_x,%d1
	asr.l #1,%d1
	move.l #-1057222719,%d2
	move.w sfu_x+7794,%d4
	muls.l %d2,%d1
	mov3q.l #1,%d2
	lsl.l %d1,%d2
	move.l %d1,%a2
	add.l #sfu_p,%a2
	not.l %d2
	and.l %d4,%d2
	clr.b %d4
	move.w %d2,sfu_x+7794
	move.b %d4,4224(%a2)
.L458:
	move.l %a1,%a4
	sub.l %a3,%a3
.L459:
	mvz.w %a3,%d1
	sub.l %a2,%a2
	lea (%a0,%d1.l*4),%a5
.L461:
	move.b 7(%a5,%a2.l),%d2
	moveq #94,%d5
	move.l %d2,%d1
	add.l #-32,%d1
	mvz.b %d1,%d1
	cmp.l %d1,%d5
	jcs .L460
	move.b %d2,2(%a4,%a2.l)
	addq.l #1,%a2
	mov3q.l #4,%d7
	cmp.l %a2,%d7
	jne .L461
.L460:
	lea (%a3,%a3.l*4),%a5
	clr.b %d1
	addq.l #1,%a3
	addq.l #5,%a4
	mov3q.l #4,%d2
	add.l %a1,%a5
	move.b %d1,2(%a2,%a5.l)
	cmp.l %a3,%d2
	jne .L459
	moveq #127,%d4
	cmp.l %d0,%d4
	jlt .L499
	asr.l #3,%d0
	subq.l #3,%d0
.L463:
	lea (23,%a0),%a0
	clr.l %d1
	lea (22,%a1),%a2
.L464:
	cmp.l %d1,%d0
	jne .L467
	addq.l #1,%d3
	move.b %d1,1(%a1)
	move.b %d3,(%a1)
	addq.l #1,sfu_x+2148
.L547:
	addq.l #1,sfu_x+2080
	jra .L428
.L456:
	tst.b (%a2)
	jne .L453
	move.l %a2,%a1
.L453:
	addq.l #1,%d1
	lea (130,%a2),%a2
	moveq #16,%d7
	cmp.l %d1,%d7
	jne .L454
	tst.l %a1
	jne .L457
	jra .L448
.L499:
	moveq #12,%d0
	jra .L463
.L467:
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
.L466:
	move.b 3(%a0,%a3.l),%d4
	moveq #94,%d5
	move.l %d4,%d2
	add.l #-32,%d2
	mvz.b %d2,%d2
	cmp.l %d2,%d5
	jcs .L465
	move.b %d4,25(%a4,%a3.l)
	addq.l #1,%a3
	mov3q.l #5,%d7
	cmp.l %a3,%d7
	jne .L466
.L465:
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
	jra .L464
.L447:
	moveq #81,%d3
	cmp.l %d1,%d3
	jne .L468
	moveq #9,%d4
	cmp.l %d0,%d4
	jge .L469
	mvz.b 6(%a0),%d2
	moveq #127,%d5
	cmp.l %d2,%d5
	jlt .L469
	move.b 7(%a0),%d3
	move.l %d3,%d1
	subq.l #1,%d1
	mvz.b %d1,%d1
	lsr.l #4,%d1
	jne .L469
	move.b 8(%a0),%d1
	move.l %d1,%d4
	subq.l #1,%d4
	mvz.b %d4,%d4
	lsr.l #2,%d4
	jne .L469
	mvz.b %d1,%d7
	ext.w %d1
	move.l %d7,48(%sp)
	muls.w #20,%d1
	add.l #9,%d1
	cmp.l %d0,%d1
	jlt .L470
.L469:
	addq.l #1,sfu_x+7936
	jra .L428
.L470:
	addq.l #1,%d2
	lea sfu_x,%a1
	clr.l %d1
.L473:
	mvz.b (%a1),%d4
	move.l %a1,%d0
	cmp.l %d4,%d2
	jeq .L471
	clr.l %d0
.L471:
	addq.l #1,%d1
	moveq #16,%d4
	cmp.l %d1,%d4
	jeq .L472
	lea (130,%a1),%a1
	tst.l %d0
	jeq .L473
.L474:
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
.L475:
	move.l %a1,%d1
	moveq #17,%d7
	muls.l %d7,%d1
	mov3q.l #3,%d0
	cmp.l %a1,%d0
	jlt .L477
	move.l %d6,%a2
.L546:
	add.l %d1,%a2
	clr.l %d1
.L480:
	move.b (%a0,%d1.l),%d7
	move.l %d7,%a5
	lea (-32,%a5),%a5
	move.w %a5,%d0
	mvz.b %d0,%d0
	move.l %d0,%a5
	moveq #94,%d0
	cmp.l %a5,%d0
	jcs .L481
	move.b %d7,(%a2,%d1.l)
	addq.l #1,%d1
	moveq #16,%d7
	cmp.l %d1,%d7
	jne .L480
.L481:
	tst.l %d1
	jeq .L501
	mvs.b -1(%a2,%d1.l),%d7
	move.l %d1,%a5
	moveq #32,%d0
	cmp.l %d7,%d0
	jeq .L483
.L482:
	clr.b %d1
	mov3q.l #3,%d7
	move.b %d1,(%a2,%a5.l)
	cmp.l %a1,%d7
	jge .L484
	lea (%a1,%a1.l*4),%a2
	clr.l %d1
	lea (%a2,%a4.l),%a5
.L486:
	move.b -4(%a0,%d1.l),%d7
	move.l %d7,%a2
	lea (-32,%a2),%a2
	move.w %a2,%d0
	mvz.b %d0,%d0
	move.l %d0,%a2
	moveq #94,%d0
	cmp.l %a2,%d0
	jcs .L485
	move.b %d7,-20(%a5,%d1.l)
	addq.l #1,%d1
	mov3q.l #4,%d7
	cmp.l %d1,%d7
	jne .L486
.L485:
	lea -20(%a1,%a1.l*4),%a2
	clr.b %d0
	add.l 40(%sp),%a2
	add.l %d4,%a2
	move.b %d0,(%a2,%d1.l)
.L484:
	mvz.b 4224(%a3),%d1
	cmp.l %d1,%a1
	jlt .L487
	move.l %a1,%d1
	addq.l #1,%d1
	move.b %d1,4224(%a3)
.L487:
	addq.l #1,%d3
	cmp.l 48(%sp),%d3
	jge .L476
	addq.l #1,%a1
	lea (20,%a0),%a0
	moveq #16,%d0
	cmp.l %a1,%d0
	jne .L475
.L476:
	move.w sfu_x+7794,%d0
	addq.l #1,sfu_x+7932
	or.l %d0,%d2
	move.w %d2,sfu_x+7794
	jra .L547
.L472:
	tst.l %d0
	jne .L474
	jra .L469
.L477:
	move.l %d5,%a2
	jra .L546
.L483:
	subq.l #1,%d1
	jra .L481
.L501:
	sub.l %a5,%a5
	jra .L482
.L468:
	moveq #34,%d2
	cmp.l %d1,%d2
	jne .L428
	moveq #8,%d3
	cmp.l %d0,%d3
	jeq .L428
	mvz.b 6(%a0),%d2
	mov3q.l #1,%d4
	cmp.l %d2,%d4
	jcs .L428
	mvz.b 8(%a0),%d3
	move.b 7(%a0),%d1
	subq.l #3,%d3
	tst.l %d3
	jne .L502
	move.b %d1,%d3
.L489:
	lea sfu_st,%a3
	lea (%a3,%d2.l),%a1
	move.b %d3,1024(%a1)
	mvz.b 8(%a0),%d2
	subq.l #3,%d2
	tst.l %d2
	jne .L428
	tst.b %d1
	jlt .L428
	mvz.b %d1,%d2
	lsl.l #3,%d2
	tst.b (%a3,%d2.l)
	jne .L428
	ext.w %d1
	subq.l #1,%d0
	sub.l %a2,%a2
	mvz.w %d1,%d1
	lsl.l #3,%d1
	lea (%a3,%d1.l),%a1
	moveq #9,%d1
.L490:
	cmp.l %d0,%d1
	jge .L492
	move.b (%a0,%d1.l),%d4
	moveq #94,%d5
	move.l %d4,%d3
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcs .L492
	move.b %d4,(%a1,%a2.l)
	addq.l #1,%a2
	addq.l #1,%d1
	mov3q.l #7,%d7
	cmp.l %a2,%d7
	jne .L490
.L492:
	clr.b %d0
	add.l %d2,%a3
	move.b %d0,(%a3,%a2.l)
	jra .L428
.L502:
	st %d3
	jra .L489
	.size	sfu_sysex, .-sfu_sysex
	.align	2
	.type	refuse.isra.0, @function
refuse.isra.0:
	addq.l #1,sfu_st+1038
	tst.l sfu_st+1042
	jne .L548
	moveq #1,%d0
	move.b %d0,sfu_st+1046
.L548:
	rts
	.size	refuse.isra.0, .-refuse.isra.0
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
	jne .L551
	mvz.b sfu_x+2090,%d0
	cmp.l %d0,%d3
	jne .L551
	mvz.b sfu_x+2091,%d0
	cmp.l %d0,%d2
	jeq .L552
.L551:
	lea sfu_x+2080,%a0
	move.l (%a0),sfu_x+2084
	jsr relabel
.L552:
	tst.b sfu_p+4240.l
	jne .L553
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
.L553:
	tst.b sfu_p+4241.l
	jne .L550
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
.L550:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
	.size	sync, .-sync
	.align	2
	.type	page_set, @function
page_set:
	lea (-16,%sp),%sp
	movem.l #3084,(%sp)
	move.l 20(%sp),%d2
	lea sfu_p,%a3
	move.l 24(%sp),%d3
	lea (%a3,%d2.l),%a2
	mvz.b 4242(%a2),%d0
	cmp.l %d0,%d3
	jlt .L556
	move.l %d0,%d3
	subq.l #1,%d3
.L556:
	move.b 4240(%a2),%d0
	mvz.b %d0,%d1
	cmp.l %d1,%d3
	jeq .L555
	tst.l %d3
	jne .L558
	clr.b %d0
	move.b %d0,4240(%a2)
	move.l %d2,-(%sp)
	jsr restore_recs
	addq.l #4,%sp
.L559:
	jsr relabel
	move.l sfu_x+2132,%d0
	tst.l %d0
	jeq .L555
	movem.l (%sp),#3084
	move.l %d0,20(%sp)
	lea (16,%sp),%sp
	jra sync
.L558:
	tst.b %d0
	jne .L560
	move.l %d2,%d0
	move.l #-2147457096,%a0
	add.l #1177,%d0
	move.l (%a0),(%a3,%d0.l*4)
	move.l %d2,-(%sp)
	jsr kitsig
	add.l #1179,%d2
	addq.l #4,%sp
	move.l %d0,(%a3,%d2.l*4)
.L560:
	move.b %d3,4240(%a2)
	jra .L559
.L555:
	movem.l (%sp),#3084
	lea (16,%sp),%sp
	rts
	.size	page_set, .-page_set
	.align	2
	.globl	sfu_isext
	.type	sfu_isext, @function
sfu_isext:
	move.l %d2,-(%sp)
	move.l 8(%sp),%d0
	move.l %d0,%d1
	subq.l #1,%d1
	lsr.l #2,%d1
	jeq .L566
	move.l %d0,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L564:
	move.l (%sp)+,%d2
	rts
.L566:
	mov3q.l #1,%d0
	jra .L564
	.size	sfu_isext, .-sfu_isext
	.align	2
	.globl	sfu_s_read
	.type	sfu_s_read, @function
sfu_s_read:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d2
	move.l %d2,-(%sp)
	move.l 16(%sp),-(%sp)
	jsr 1074433530
	addq.l #8,%sp
	moveq #13,%d1
	move.l %d0,%d3
	move.l %d2,%d0
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcs .L568
	move.l %d3,16(%sp)
	move.l %d0,12(%sp)
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	jra half_of
.L568:
	move.l %d2,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L567
	move.l %d3,16(%sp)
	move.l %d2,12(%sp)
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	jra x_knob
.L567:
	move.l (%sp)+,%d2
	move.l %d3,%d0
	move.l (%sp)+,%d3
	rts
	.size	sfu_s_read, .-sfu_s_read
	.align	2
	.globl	sfu_f_read
	.type	sfu_f_read, @function
sfu_f_read:
	link.w %fp,#-8
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	pea -4(%fp)
	move.l 12(%fp),%d2
	move.l %d2,-(%sp)
	move.l 8(%fp),%d3
	jsr pq
	addq.l #8,%sp
	mov3q.l #-1,%d1
	cmp.l %d0,%d1
	jeq .L571
	tst.l %d0
	jge .L572
.L575:
	clr.l -8(%fp)
.L570:
	move.l -8(%fp),%d0
	move.l -16(%fp),%d2
	move.l -12(%fp),%d3
	unlk %fp
	rts
.L572:
	move.l -4(%fp),%d1
	moveq #12,%d2
	muls.l %d2,%d1
	add.l %d1,%d0
	move.l %d0,%a0
	add.l #sfu_p+4246,%a0
.L578:
	mvz.b (%a0),%d0
	lsl.l #8,%d0
	move.l %d0,-8(%fp)
	jra .L570
.L571:
	move.l %d2,%d0
	mov3q.l #3,%d1
	subq.l #1,%d0
	cmp.l %d0,%d1
	jcs .L574
	tst.l sfu_st+1034
	jeq .L575
	add.l #sfu_x+6684,%d0
	move.l %d0,%a0
	jra .L578
.L574:
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr 1074433680
	move.l %d3,-(%sp)
	add.l #-14,%d2
	move.l %d0,-8(%fp)
	jsr see_fxset
	lea (12,%sp),%sp
	moveq #13,%d0
	cmp.l %d2,%d0
	jcs .L570
	tst.l sfu_st+1034
	jne .L576
	move.l %d2,8(%fp)
	move.l -16(%fp),%d2
	move.l -12(%fp),%d3
	move.l -8(%fp),12(%fp)
	unlk %fp
	jra half_of
.L576:
	tst.b sfu_st+1026.l
	jeq .L577
	move.l %d3,-(%sp)
	jsr sync
	addq.l #4,%sp
.L577:
	move.l -8(%fp),-(%sp)
	move.l %d2,-(%sp)
	jsr half_of
	addq.l #8,%sp
	move.l %d2,8(%fp)
	move.l -16(%fp),%d2
	move.l -12(%fp),%d3
	move.l %d0,12(%fp)
	unlk %fp
	jra to_knob
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
	jcs .L580
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
.L581:
	move.l %d2,36(%sp)
	move.l %d3,32(%sp)
	move.l %d5,28(%sp)
	movem.l (%sp),#60
	move.l 20(%sp),44(%sp)
	move.l 16(%sp),40(%sp)
	lea (24,%sp),%sp
	jmp 1074438046
.L580:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L581
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
	jeq .L581
	tst.l %d4
	jlt .L581
	and.l #32512,%d2
	and.l #224,%d4
	or.l %d4,%d2
	jra .L581
	.size	sfu_s_write, .-sfu_s_write
	.align	2
	.globl	sfu_f_write
	.type	sfu_f_write, @function
sfu_f_write:
	link.w %fp,#-40
	move.l 20(%fp),-12(%fp)
	movem.l #1084,(%sp)
	move.l 12(%fp),%d4
	pea -4(%fp)
	move.l %d4,-(%sp)
	move.l 8(%fp),%a2
	move.l 16(%fp),%d2
	move.l 24(%fp),-8(%fp)
	jsr pq
	addq.l #8,%sp
	mov3q.l #-1,%d1
	cmp.l %d0,%d1
	jeq .L588
	tst.l %d0
	jlt .L593
	asr.l #8,%d2
	moveq #127,%d5
	cmp.l %d2,%d5
	jge .L590
	moveq #127,%d2
.L591:
	move.l -4(%fp),%d3
	moveq #12,%d1
	lea sfu_p,%a1
	muls.l %d3,%d1
	lea (%a1,%d1.l),%a0
	add.l %d0,%a0
	mvz.b 4246(%a0),%d1
	cmp.l %d1,%d2
	jeq .L593
	move.b %d2,4246(%a0)
	mov3q.l #1,%d2
	lsl.l %d0,%d2
	move.l %d3,%d1
	add.l #2135,%d1
	move.w (%a1,%d1.l*2),%d0
	or.l %d0,%d2
	move.w %d2,(%a1,%d1.l*2)
.L593:
	movem.l -40(%fp),#1084
	mov3q.l #1,%d0
	unlk %fp
	rts
.L590:
	tst.l %d2
	jge .L591
	clr.l %d2
	jra .L591
.L588:
	move.l %d4,%d0
	mov3q.l #3,%d1
	subq.l #1,%d0
	cmp.l %d0,%d1
	jcs .L594
	tst.l sfu_st+1034
	jeq .L593
	asr.l #8,%d2
	moveq #127,%d5
	cmp.l %d2,%d5
	jge .L595
	moveq #127,%d2
.L596:
	move.l %d0,%d1
	move.l %d0,%a0
	add.l #sfu_x+6684,%a0
	mvz.b (%a0),%d0
	asr.l #1,%d1
	cmp.l %d0,%d2
	jeq .L593
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	move.b sfu_x+6688,%d1
	move.b %d2,(%a0)
	or.l %d1,%d0
	move.b %d0,sfu_x+6688
	jra .L593
.L595:
	tst.l %d2
	jge .L596
	clr.l %d2
	jra .L596
.L594:
	move.l %d4,%d3
	moveq #13,%d0
	add.l #-14,%d3
	cmp.l %d3,%d0
	jcs .L597
	lea k_cidx,%a0
	move.b (%a0,%d3.l),%d1
	move.l %d4,-(%sp)
	move.l %a2,-(%sp)
	move.b %d1,-13(%fp)
	jsr 1074433680
	addq.l #8,%sp
	move.l %d0,%d5
	tst.l sfu_st+1034
	jeq .L593
	mvz.b -13(%fp),%d1
	move.l %a2,-(%sp)
	addq.l #1,sfu_st+1030
	move.l %d1,-18(%fp)
	jsr see_fxset
	move.l %d5,%d0
	asr.l #8,%d0
	moveq #127,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr to_half
	move.l %d0,-(%sp)
	move.l %d5,-(%sp)
	move.l %d3,-(%sp)
	jsr merge
	lea (28,%sp),%sp
	mov3q.l #1,%d5
	move.l %d0,%d2
	cmp.l %d3,%d5
	jge .L598
	move.l %d4,%d0
	mov3q.l #6,%d5
	add.l #-16,%d0
	rems.l %d5,%d1:%d0
	tst.l %d1
	jne .L598
	mov3q.l #7,%d0
	cmp.l %d3,%d0
	slt %d3
	move.l %d2,%d0
	asr.l #8,%d0
	lea sfu_x,%a0
	mvs.b %d3,%d3
	sub.l %d3,%a0
	move.b %d0,2088(%a0)
.L598:
	moveq #37,%d1
	cmp.l -18(%fp),%d1
	jge .L597
	move.l 20(%a2),%a0
	move.l (%a0),%a1
	move.l %a0,-(%sp)
	move.l 40(%a1),%a0
	jsr (%a0)
	move.l -18(%fp),%d5
	addq.l #4,%sp
	move.l -18(%fp),%d1
	add.l #-38,%d1
	mvz.w %d1,%d1
	add.l %d5,%d5
	add.l %d1,%d1
	move.l %d5,%a1
	move.w %d2,(%a1,%d0.l)
	move.l %d2,%d0
	asr.l #8,%d0
	add.l #-2147423840,%a1
	move.w %d2,(%a1)
	move.l %d1,%a0
	add.l #1081499899,%a0
	move.b %d0,(%a0)
	move.b %d2,1(%a0)
	jra .L593
.L597:
	move.l %d2,16(%fp)
	move.l %d4,12(%fp)
	move.l %a2,8(%fp)
	movem.l -40(%fp),#1084
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
	jcs .L600
	mov3q.l #6,%d4
	rems.l %d4,%d2:%d0
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jge .L605
.L600:
	move.l %a0,-(%sp)
	move.l %d3,-(%sp)
	move.l %d1,-(%sp)
	jsr 1074436168
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jlt .L599
	move.l %d3,%d0
	moveq #13,%d1
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcs .L603
	move.l %d2,20(%sp)
	movem.l (%sp),#28
	move.l %d0,16(%sp)
	lea (12,%sp),%sp
	jra half_of
.L603:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L599
	move.l %d2,20(%sp)
	move.l %d3,16(%sp)
	movem.l (%sp),#28
	lea (12,%sp),%sp
	jra x_knob
.L605:
	mov3q.l #-1,%d2
.L599:
	move.l %d2,%d0
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
	.size	sfu_s_lget, .-sfu_s_lget
	.align	2
	.globl	sfu_f_lget
	.type	sfu_f_lget, @function
sfu_f_lget:
	link.w %fp,#-24
	move.l 16(%fp),-8(%fp)
	movem.l #28,(%sp)
	move.l 12(%fp),%d2
	pea -4(%fp)
	move.l %d2,-(%sp)
	move.l 8(%fp),%d4
	jsr pq
	addq.l #8,%sp
	move.l %d0,-12(%fp)
	addq.l #1,%d0
	tst.l %d0
	jne .L617
	move.l %d2,%d0
	mov3q.l #3,%d1
	subq.l #1,%d0
	cmp.l %d0,%d1
	jcc .L606
	add.l #-15,%d0
	moveq #11,%d3
	cmp.l %d0,%d3
	jcc .L609
.L613:
	move.l -8(%fp),-(%sp)
	move.l %d2,-(%sp)
	move.l %d4,-(%sp)
	jsr 1074436538
	move.l %d2,%d3
	add.l #-14,%d3
	lea (12,%sp),%sp
	move.l %d0,-12(%fp)
	moveq #13,%d0
	cmp.l %d3,%d0
	jcc .L618
.L606:
	movem.l -24(%fp),#28
	move.l -12(%fp),%d0
	unlk %fp
	rts
.L609:
	mov3q.l #6,%d3
	rems.l %d3,%d1:%d0
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jlt .L613
	jra .L606
.L618:
	tst.l -12(%fp)
	jlt .L606
	tst.l sfu_st+1034
	jne .L615
	move.l %d3,8(%fp)
	movem.l -24(%fp),#28
	move.l -12(%fp),12(%fp)
	unlk %fp
	jra half_of
.L615:
	tst.b sfu_st+1026.l
	jeq .L616
	move.l %d4,-(%sp)
	jsr sync
	addq.l #4,%sp
.L616:
	move.l -12(%fp),-(%sp)
	move.l %d3,-(%sp)
	jsr half_of
	addq.l #8,%sp
	move.l %d3,8(%fp)
	movem.l -24(%fp),#28
	move.l %d0,12(%fp)
	unlk %fp
	jra to_knob
.L617:
	mov3q.l #-1,-12(%fp)
	jra .L606
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
	jcs .L620
	moveq #15,%d7
	cmp.l %d3,%d7
	jge .L621
	move.l %d3,%d0
	mov3q.l #6,%d7
	add.l #-16,%d0
	rems.l %d7,%d1:%d0
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L622
.L621:
	move.l %d6,-(%sp)
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	addq.l #1,sfu_st+1030
	jsr 1074436168
	lea (12,%sp),%sp
	tst.l %d0
	jge .L623
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433530
	addq.l #8,%sp
.L623:
	move.l %d2,-(%sp)
	move.l %d0,-(%sp)
	move.l %d4,-(%sp)
	jsr merge
	lea (12,%sp),%sp
	move.l %d0,%d2
.L624:
	move.l %d6,40(%sp)
	move.l %d2,36(%sp)
	move.l %d3,32(%sp)
	move.l %d5,28(%sp)
	movem.l (%sp),#252
	lea (24,%sp),%sp
	jmp 1074436282
.L620:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L624
	move.l %d6,-(%sp)
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074436168
	lea (12,%sp),%sp
	move.l %d0,%d4
	tst.l %d0
	jge .L625
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433530
	addq.l #8,%sp
	move.l %d0,%d4
.L625:
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr x_half
	addq.l #8,%sp
	move.l %d3,%a0
	add.l #sfu_x,%a0
	move.l %d0,%d2
	tst.b 6223(%a0)
	jeq .L624
	tst.l %d4
	jlt .L624
	and.l #32512,%d2
	and.l #224,%d4
	or.l %d4,%d2
	jra .L624
.L622:
	movem.l (%sp),#252
	clr.l %d0
	lea (24,%sp),%sp
	rts
	.size	sfu_s_lset, .-sfu_s_lset
	.align	2
	.globl	sfu_tls
	.type	sfu_tls, @function
sfu_tls:
	link.w %fp,#-36
	move.l 8(%fp),%a1
	moveq #12,%d0
	movem.l #1148,(%sp)
	move.l 4(%a1),%a0
	move.l 12(%a1),%d3
	move.l 64(%a0),%d4
	cmp.l %d4,%d0
	jne .L632
	move.l %d3,%d0
	add.l #-38,%d0
	lsr.l #2,%d0
	jne .L632
	mov3q.l #1,%d6
	or.l %d6,20(%a1)
.L632:
	move.l 8(%fp),%a1
	move.l #1074543510,%d0
	cmp.l (%a1),%d0
	jne .L633
.L635:
	clr.l %d0
.L631:
	movem.l -36(%fp),#1148
	unlk %fp
	rts
.L633:
	moveq #41,%d1
	cmp.l %d3,%d1
	jcs .L635
	move.l 8(%fp),%a1
	moveq #63,%d6
	cmp.l 8(%a1),%d6
	jcs .L635
	tst.w 18(%a1)
	jlt .L635
	move.l %a0,-(%sp)
	jsr pat_locks
	addq.l #4,%sp
	move.l %d0,%d2
	tst.l %d0
	jeq .L635
	mvz.w #5674,%d0
	move.l 8(%fp),%a0
	move.l %d2,%a2
	muls.l %d4,%d0
	add.l %d0,%a2
	tst.b 23(%a0)
	jeq .L638
	mov3q.l #2,%d5
.L636:
	pea -8(%fp)
	pea 5632(%a2)
	move.l %a2,-(%sp)
	jsr track_rows
	lea (12,%sp),%sp
	move.l %d3,%d1
	asr.l #5,%d1
	move.l -8(%fp,%d1.l*4),%a0
	moveq #31,%d1
	and.l %d3,%d1
	move.l %a0,%d6
	btst %d1,%d6
	jeq .L639
	add.l %d3,%a2
	tst.b 5632(%a2)
	jne .L635
	mov3q.l #1,%d1
	cmp.l %d5,%d1
	jeq .L635
.L637:
	move.l %d4,-(%sp)
	moveq #71,%d6
	sub.l %d1,%d0
	add.l %d0,%d5
	move.l %d2,-(%sp)
	jsr rows_but
	addq.l #8,%sp
	add.l %d5,%d0
	cmp.l %d0,%d6
	jge .L635
	jsr (refuse.isra.0)
	mov3q.l #1,%d0
	jra .L631
.L638:
	mov3q.l #1,%d5
	jra .L636
.L639:
	clr.l %d1
	jra .L637
	.size	sfu_tls, .-sfu_tls
	.align	2
	.globl	sfu_tgpaste
	.type	sfu_tgpaste, @function
sfu_tgpaste:
	link.w %fp,#-96
	move.l 8(%fp),%a0
	movem.l #3324,(%sp)
	move.l 12(%fp),%a3
	clr.l -50(%fp)
	move.l 64(%a0),%d1
	move.l 8(%a3),%d2
	move.l %a0,-(%sp)
	move.l %d1,-64(%fp)
	clr.l -46(%fp)
	jsr pat_locks
	addq.l #4,%sp
	move.l %d0,%d3
	tst.l %d0
	jeq .L647
	mvz.w #5674,%d4
	move.l -64(%fp),%d0
	pea -58(%fp)
	muls.l %d4,%d0
	move.l %d3,%d4
	add.l %d0,%d4
	move.l %d4,%a2
	lea (5632,%a2),%a2
	move.l %a2,-(%sp)
	move.l %d4,-(%sp)
	jsr track_rows
	lea (12,%sp),%sp
	move.l 4(%a3),%a0
	move.l %a0,%a1
.L648:
	cmp.l %a1,%d2
	jne .L651
	move.l %d4,%a1
	clr.l %d4
	clr.l -54(%fp)
	clr.l -58(%fp)
	lea (84,%a1),%a1
.L655:
	move.l %d4,%d1
	asr.l #5,%d1
	move.l -50(%fp,%d1.l*4),%d5
	moveq #31,%d1
	and.l %d4,%d1
	btst %d1,%d5
	jne .L652
	tst.l (%a1)
	jle .L652
	lea (-84,%a1),%a3
	clr.l %d1
.L654:
	tst.w (%a3,%d1.l*2)
	jlt .L653
	moveq #31,%d5
	mov3q.l #1,%d7
	and.l %d1,%d5
	lsl.l %d5,%d7
	move.l %d1,%d5
	asr.l #5,%d5
	or.l %d7,-58(%fp,%d5.l*4)
.L653:
	addq.l #1,%d1
	moveq #42,%d5
	cmp.l %d1,%d5
	jne .L654
.L652:
	addq.l #1,%d4
	lea (88,%a1),%a1
	moveq #64,%d7
	cmp.l %d4,%d7
	jne .L655
	clr.l %d1
.L656:
	lea (%a2,%d1.l),%a1
	moveq #42,%d4
	move.b (%a1),-42(%fp,%d1.l)
	addq.l #1,%d1
	cmp.l %d1,%d4
	jne .L656
.L657:
	cmp.l %a0,%d2
	jne .L664
	clr.l %d2
	clr.l %d1
.L667:
	moveq #31,%d4
	and.l %d1,%d4
	move.l %d1,%d5
	asr.l #5,%d5
	move.l -58(%fp,%d5.l*4),%d5
	btst %d4,%d5
	jeq .L665
	tst.b -42(%fp,%d1.l)
	jeq .L672
	mov3q.l #2,%a0
.L666:
	add.l %a0,%d2
.L665:
	addq.l #1,%d1
	moveq #42,%d7
	cmp.l %d1,%d7
	jne .L667
	cmp.l %d2,%d0
	jlt .L668
.L647:
	clr.l %d0
.L646:
	movem.l -96(%fp),#3324
	unlk %fp
	rts
.L651:
	tst.b 4(%a1)
	jne .L649
	tst.b 5(%a1)
	jeq .L650
.L649:
	move.l (%a1),%d1
	moveq #63,%d5
	cmp.l %d1,%d5
	jcs .L650
	move.l %d1,%d5
	moveq #31,%d7
	and.l %d7,%d1
	mov3q.l #1,%d7
	asr.l #5,%d5
	lsl.l %d1,%d7
	or.l %d7,-50(%fp,%d5.l*4)
.L650:
	lea (64,%a1),%a1
	jra .L648
.L664:
	tst.b 4(%a0)
	jne .L658
	tst.b 5(%a0)
	jne .L658
.L663:
	lea (64,%a0),%a0
	jra .L657
.L658:
	move.l 52(%a0),%a2
	move.l 56(%a0),%d6
.L659:
	cmp.l %d6,%a2
	jeq .L663
	move.l 4(%a2),%d7
	moveq #41,%d1
	cmp.l %d7,%d1
	jcs .L660
	tst.l (%a2)
	jlt .L660
	tst.b 8(%a2)
	jne .L670
	moveq #12,%d4
	cmp.l -64(%fp),%d4
	jne .L671
	move.l %d7,%d1
	mov3q.l #3,%d4
	add.l #-38,%d1
	cmp.l %d1,%d4
	scc %d1
	mvs.b %d1,%d1
	neg.l %d1
.L661:
	move.b %d1,-42(%fp,%d7.l)
	tst.w 2(%a2)
	jlt .L660
	moveq #31,%d1
	and.l %d7,%d1
	move.l %d7,%d4
	mov3q.l #1,%d7
	asr.l #5,%d4
	lsl.l %d1,%d7
	or.l %d7,-58(%fp,%d4.l*4)
.L660:
	lea (12,%a2),%a2
	jra .L659
.L670:
	mov3q.l #1,%d1
	jra .L661
.L671:
	clr.l %d1
	jra .L661
.L672:
	mov3q.l #1,%a0
	jra .L666
.L668:
	move.l -64(%fp),-(%sp)
	move.l %d3,-(%sp)
	jsr rows_but
	addq.l #8,%sp
	moveq #71,%d1
	add.l %d2,%d0
	cmp.l %d0,%d1
	jge .L647
	jsr (refuse.isra.0)
	mov3q.l #1,%d0
	jra .L646
	.size	sfu_tgpaste, .-sfu_tgpaste
	.align	2
	.globl	sfu_pgpaste
	.type	sfu_pgpaste, @function
sfu_pgpaste:
	link.w %fp,#-104
	move.l 8(%fp),%a0
	movem.l #15484,(%sp)
	move.l 12(%fp),%d4
	move.l %d4,%a1
	clr.l -50(%fp)
	move.l 64(%a0),%d2
	move.l 6596(%a1),%d5
	move.l %a0,-(%sp)
	clr.l -46(%fp)
	jsr pat_locks
	addq.l #4,%sp
	move.l %d0,-68(%fp)
	tst.l %d0
	jeq .L684
	jsr 1075312702
	move.l %d0,-(%sp)
	jsr 1074455590
	move.l %d0,-(%sp)
	jsr 1074490046
	addq.l #8,%sp
	moveq #48,%d1
	move.l %d0,%d3
	move.l %d5,%d0
	lsl.l #4,%d0
	cmp.l %d0,%d1
	jcc .L685
.L684:
	clr.l %d0
.L683:
	movem.l -104(%fp),#15484
	unlk %fp
	rts
.L685:
	move.l %d3,%d0
	moveq #48,%d6
	lsl.l #4,%d0
	cmp.l %d0,%d6
	jcs .L684
	mvz.w #5674,%d0
	move.l -68(%fp),%a2
	sub.l %a3,%a3
	pea -58(%fp)
	muls.l %d2,%d0
	add.l %d0,%a2
	lea (5632,%a2),%a4
	move.l %a4,-(%sp)
	move.l %a2,-(%sp)
	jsr track_rows
	clr.l -54(%fp)
	clr.l -58(%fp)
	lea (12,%sp),%sp
	move.l %d3,%d1
	neg.l %d1
	move.l %d0,-64(%fp)
	move.l %d4,%a0
	move.w %d5,%d0
	lsl.l #4,%d1
	mulu.w #1408,%d0
	add.l %d0,%a0
	lea (921,%a0),%a0
.L692:
	moveq #15,%d0
	cmp.l %d1,%d0
	jcs .L687
	moveq #88,%d0
	muls.l %d1,%d0
	move.l %a0,%d3
	add.l %d0,%d3
.L688:
	move.l %d3,%a1
	tst.l 84(%a1)
	jle .L689
	sub.l %a1,%a1
.L691:
	move.l %d3,%a5
	tst.w (%a5,%a1.l*2)
	jlt .L690
	moveq #31,%d4
	move.l %a1,%d6
	move.l %a1,%d0
	and.l %d4,%d6
	mov3q.l #1,%d4
	asr.l #5,%d0
	lsl.l %d6,%d4
	moveq #15,%d6
	or.l %d4,-58(%fp,%d0.l*4)
	cmp.l %d1,%d6
	jcs .L690
	or.l %d4,-50(%fp,%d0.l*4)
.L690:
	addq.l #1,%a1
	moveq #42,%d0
	cmp.l %a1,%d0
	jne .L691
.L689:
	addq.l #1,%d1
	lea (88,%a3),%a3
	cmp.l #5632,%a3
	jne .L692
	sub.l %a3,%a3
	clr.l %d1
.L697:
	moveq #31,%d3
	and.l %d1,%d3
	tst.b (%a4,%d1.l)
	jne .L699
	moveq #12,%d4
	cmp.l %d2,%d4
	jne .L694
	move.l %d1,%d0
	add.l #-38,%d0
	lsr.l #2,%d0
	jeq .L695
.L694:
	clr.l %d4
.L693:
	move.l %d1,%d0
	asr.l #5,%d0
	move.b %d4,-42(%fp,%d1.l)
	move.l -58(%fp,%d0.l*4),%d0
	btst %d3,%d0
	jeq .L696
	lea 1(%a3,%d4.l),%a3
.L696:
	addq.l #1,%d1
	moveq #42,%d0
	cmp.l %d1,%d0
	jne .L697
	cmp.l -64(%fp),%a3
	jle .L698
	move.l %d2,-(%sp)
	move.l -68(%fp),-(%sp)
	jsr rows_but
	addq.l #8,%sp
	moveq #71,%d1
	add.l %a3,%d0
	cmp.l %d0,%d1
	jge .L698
	jsr (refuse.isra.0)
	mov3q.l #1,%d0
	jra .L683
.L687:
	move.l %a2,%d3
	add.l %a3,%d3
	jra .L688
.L695:
	move.l -46(%fp),%d0
	lsr.l %d3,%d0
	mov3q.l #1,%d4
	and.l %d0,%d4
	jra .L693
.L699:
	mov3q.l #1,%d4
	jra .L693
.L698:
	move.l -4(%fp),5670(%a2)
	jra .L684
	.size	sfu_pgpaste, .-sfu_pgpaste
	.align	2
	.globl	sfu_tkpaste
	.type	sfu_tkpaste, @function
sfu_tkpaste:
	lea (-84,%sp),%sp
	movem.l #23580,(%sp)
	move.l 88(%sp),%a0
	move.l 64(%a0),%d2
	move.l %a0,-(%sp)
	jsr pat_locks
	addq.l #4,%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L710
	mvz.w #5674,%d0
	move.l %sp,%d3
	add.l #34,%d3
	move.l %d3,-(%sp)
	lea track_rows,%a2
	muls.l %d2,%d0
	lea (%a6,%d0.l),%a3
	lea (5632,%a3),%a4
	move.l %a4,-(%sp)
	move.l %a3,-(%sp)
	jsr (%a2)
	move.l %d0,40(%sp)
	move.l %d3,-(%sp)
	move.l %a4,-(%sp)
	move.l 112(%sp),%a0
	lea (921,%a0),%a0
	move.l %a0,-(%sp)
	jsr (%a2)
	lea (24,%sp),%sp
	sub.l %a2,%a2
	clr.l %d1
.L715:
	moveq #31,%d0
	and.l %d1,%d0
	move.l %d0,%a0
	tst.b (%a4,%d1.l)
	jne .L718
	moveq #12,%d3
	cmp.l %d2,%d3
	jne .L712
	move.l %d1,%d0
	add.l #-38,%d0
	lsr.l #2,%d0
	jeq .L713
.L712:
	clr.l %d0
.L711:
	move.l %d1,%d3
	asr.l #5,%d3
	move.b %d0,42(%sp,%d1.l)
	move.l %a0,%d4
	move.l 34(%sp,%d3.l*4),%d3
	btst %d4,%d3
	jeq .L714
	lea 1(%a2,%d0.l),%a2
.L714:
	addq.l #1,%d1
	moveq #42,%d0
	cmp.l %d1,%d0
	jne .L715
	cmp.l 28(%sp),%a2
	jle .L716
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr rows_but
	addq.l #8,%sp
	moveq #71,%d1
	add.l %a2,%d0
	cmp.l %d0,%d1
	jge .L716
	jsr (refuse.isra.0)
	mov3q.l #1,%d0
.L709:
	movem.l (%sp),#23580
	lea (84,%sp),%sp
	rts
.L713:
	move.l 38(%sp),%d0
	move.l %a0,%d3
	lsr.l %d3,%d0
	mov3q.l #1,%d4
	and.l %d4,%d0
	jra .L711
.L718:
	mov3q.l #1,%d0
	jra .L711
.L716:
	move.l 80(%sp),5670(%a3)
.L710:
	clr.l %d0
	jra .L709
	.size	sfu_tkpaste, .-sfu_tkpaste
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
	jne .L728
	move.l -8(%fp),%d0
	subq.l #1,%d0
	lsr.l #2,%d0
	jeq .L728
	move.l -8(%fp),%d5
	moveq #13,%d2
	add.l #-14,%d5
	cmp.l %d5,%d2
	jcs .L730
	moveq #15,%d0
	cmp.l -8(%fp),%d0
	jge .L731
	move.l -8(%fp),%d0
	mov3q.l #6,%d2
	add.l #-16,%d0
	rems.l %d2,%d1:%d0
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L728
.L731:
	tst.l sfu_st+1034
	jeq .L728
	move.l %d6,-(%sp)
	move.l -8(%fp),-(%sp)
	move.l %d4,-(%sp)
	addq.l #1,sfu_st+1030
	jsr 1074436538
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jge .L732
	move.l -8(%fp),-(%sp)
	move.l %d4,-(%sp)
	jsr 1074433680
	addq.l #8,%sp
	move.l %d0,%d2
.L732:
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
.L730:
	move.l %d6,20(%fp)
	move.l %d3,16(%fp)
	move.l %d4,8(%fp)
	movem.l -28(%fp),#124
	move.l -8(%fp),12(%fp)
	unlk %fp
	jmp 1074436652
.L728:
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
	move.l %d0,%a2
	move.l (%a2),%a4
	tst.l sfu_st+1034
	jeq .L734
	move.l %d2,%d0
	moveq #11,%d1
	add.l #-16,%d0
	cmp.l %d0,%d1
	jcc .L735
	add.l #15,%d0
	lsr.l #2,%d0
	jne .L734
.L735:
	move.l %a3,sfu_p+4308
	move.l (%a3),sfu_p+4312
.L734:
	tst.l %d3
	jge .L736
.L737:
	move.l %d2,28(%sp)
	move.l %a2,24(%sp)
	move.l 40(%a4),%a1
	movem.l (%sp),#7180
	lea (20,%sp),%sp
	jmp (%a1)
.L736:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	move.l 60(%a4),%a0
	jsr (%a0)
	lea (12,%sp),%sp
	tst.l %d0
	jlt .L737
	movem.l (%sp),#7180
	lea (20,%sp),%sp
	rts
	.size	sfu_get, .-sfu_get
	.align	2
	.globl	sfu_key
	.type	sfu_key, @function
sfu_key:
	move.l -66650100,%d1
	lea (-24,%sp),%sp
	movem.l #124,(%sp)
	move.l 32(%sp),%a0
	move.l %d1,20(%sp)
	tst.b sfu_st+1026.l
	jeq .L751
	move.l 12(%a0),%d0
	mov3q.l #1,%d2
	and.l 16(%a0),%d2
	moveq #49,%d6
	mvz.b %d0,%d0
	cmp.l %d0,%d6
	jeq .L752
	moveq #50,%d1
	cmp.l %d0,%d1
	jeq .L753
	cmp.l #128,%d0
	jeq .L754
	moveq #66,%d6
	cmp.l %d0,%d6
	jne .L742
	mov3q.l #2,%d1
.L741:
	move.b sfu_p+4278,%d0
	tst.l %d2
	jeq .L743
	or.l %d1,%d0
.L744:
	move.b %d0,sfu_p+4278
.L742:
	clr.l %d2
.L745:
	clr.l -(%sp)
	move.l 24(%sp),-(%sp)
	jsr timed
	addq.l #8,%sp
.L738:
	move.l %d2,%d0
	movem.l (%sp),#124
	lea (24,%sp),%sp
	rts
.L754:
	mov3q.l #1,%d1
	jra .L741
.L743:
	not.l %d1
	and.l %d1,%d0
	jra .L744
.L752:
	clr.l %d3
.L740:
	move.b sfu_p+4276,%d1
	move.b sfu_p+4277,%d5
	tst.l %d2
	jne .L746
	mov3q.l #1,%d0
	lsl.l %d3,%d0
	mov3q.l #1,%d2
	not.l %d0
	and.l %d0,%d1
	move.b %d1,sfu_p+4276
	mvz.b %d5,%d1
	asr.l %d3,%d1
	and.l %d1,%d2
	btst #0,%d1
	jeq .L745
	and.l %d5,%d0
	move.b %d0,sfu_p+4277
	jra .L745
.L753:
	mov3q.l #1,%d3
	jra .L740
.L746:
	mvz.b %d1,%d0
	asr.l %d3,%d0
	mov3q.l #1,%d2
	and.l %d0,%d2
	btst #0,%d0
	jeq .L748
	mvz.b %d5,%d2
	asr.l %d3,%d2
	mov3q.l #1,%d0
	and.l %d0,%d2
	jra .L745
.L748:
	mov3q.l #1,%d4
	lsl.l %d3,%d4
	move.l %d4,%d0
	not.l %d0
	or.l %d4,%d1
	and.l %d5,%d0
	move.b %d1,sfu_p+4276
	move.b %d0,sfu_p+4277
	tst.b sfu_p+4278.l
	jne .L745
	tst.l sfu_p+4704
	jne .L745
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L745
	move.l sfu_p+4700,%d1
	tst.l %d1
	jeq .L745
	move.l %d3,%d5
	add.l #sfu_p,%d5
	move.l %d5,%a0
	mvz.b 4240(%a0),%d0
	mvz.b 4242(%a0),%d6
	addq.l #1,%d0
	cmp.l %d0,%d6
	jle .L745
	move.l %d1,-(%sp)
	jsr top_page
	addq.l #4,%sp
	move.l %d3,%d1
	addq.l #1,%d1
	cmp.l %d0,%d1
	jne .L745
	move.l %d5,%a0
	mov3q.l #1,%d2
	mvz.b 4240(%a0),%d0
	move.l %d0,%a1
	pea 1(%a1)
	move.l %d3,-(%sp)
	jsr page_set
	move.b sfu_p+4277,%d0
	move.l sfu_p+4308,-(%sp)
	addq.l #1,sfu_p+4296
	or.l %d0,%d4
	move.b %d4,sfu_p+4277
	jsr 1074234644
	move.l sfu_p+4308,-(%sp)
	jsr retitle
	lea (16,%sp),%sp
	jra .L745
.L751:
	clr.l %d2
	jra .L738
	.size	sfu_key, .-sfu_key
	.align	2
	.globl	sfu_tick
	.type	sfu_tick, @function
sfu_tick:
	link.w %fp,#-52
	move.l -66650100,%d1
	move.l sfu_st+1034,%d0
	movem.l #15372,(%sp)
	move.l %d1,-28(%fp)
	tst.l %d0
	jne .L762
#APP
| 1310 "sfu.c" 1
	.if RAM_SFU_X_SIZE < 7940
.error "registry buffer sfu_x is too small"
.endif
| 0 "" 2
| 1311 "sfu.c" 1
	.if RAM_SFU_P_SIZE < 4736
.error "registry buffer sfu_p is too small"
.endif
| 0 "" 2
#NO_APP
	clr.l %d1
.L763:
	move.l %d1,%a0
	add.l #sfu_x,%a0
	clr.l (%a0)
	addq.l #4,%d1
	cmp.l #7940,%d1
	jne .L763
.L764:
	move.l %d0,%a0
	add.l #sfu_p,%a0
	clr.l (%a0)
	addq.l #4,%d0
	cmp.l #4736,%d0
	jne .L764
.L762:
	addq.l #1,sfu_st+1034
	tst.b sfu_st+1026.l
	jne .L765
	tst.l 1100664624
	jeq .L766
	tst.l 1100635224
	jeq .L766
	lea copy_desc,%a2
	sub.l %a5,%a5
	lea set_rec,%a4
	move.l %a2,%a3
.L768:
	move.l %a5,-(%sp)
	jsr (%a4)
	addq.l #4,%sp
	mov3q.l #1,%d2
	cmp.l %a5,%d2
	jlt .L810
	moveq #60,%d0
.L767:
	move.l %d0,-(%sp)
	moveq #14,%d3
	pea 14(%a5)
	jsr (%a2)
	addq.l #1,%a5
	addq.l #8,%sp
	cmp.l %a5,%d3
	jne .L768
	clr.l %d2
	lea set_bw_rec,%a2
.L769:
	move.l %d2,-(%sp)
	jsr (%a2)
	pea 410.w
	addq.l #1,%d2
	move.l %d2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	mov3q.l #4,%d0
	cmp.l %d2,%d0
	jne .L769
	tst.l sfu_x+6694
	jne .L770
	moveq #127,%d1
	move.b %d1,sfu_x+6687
	move.b %d1,sfu_x+6685
.L770:
	move.l #1100664624,%a0
	move.l (%a0),sfu_x+2136
	lea sfu_type1_text,%a1
	move.l %a1,1100631528
	move.l #sfu_route_text,%d1
	lea sfu_p11_text,%a1
	move.l %a1,1100632284
	move.l #sfu_type2_text,%d0
	sub.l %a1,%a1
	move.l #sfu_p00_text,%d2
	move.l #sfu_p10_text,%d3
	lea sfu_p01_text,%a0
	move.l %d0,1100632032
	move.l #sfu_p02_text,%d0
	move.l %d1,1100631612
	move.l %d1,1100632116
	move.l #sfu_p12_text,%d1
	move.l %d2,1100631696
	move.l #sfu_p03_text,%d2
	move.l %d3,1100632200
	move.l #sfu_p13_text,%d3
	move.l %a0,1100631780
	move.l %d0,1100631864
	move.l %d1,1100632368
	move.l %d2,1100631948
	move.l %d3,1100632452
	lea sfu_st,%a0
	clr.l %d2
	move.l sfu_x+2316,%d1
	move.l %d1,%d0
.L772:
	tst.b (%a0)
	jeq .L771
	move.l %d0,%a1
	add.l #sfu_x,%a1
	move.b %d2,2188(%a1)
	move.w #1,%a1
	addq.l #1,%d0
.L771:
	addq.l #1,%d2
	addq.l #8,%a0
	cmp.l #128,%d2
	jne .L772
	move.w %a1,%d2
	tst.b %d2
	jeq .L773
	move.l %d0,sfu_x+2316
	move.l %d0,%d1
.L773:
	lea sfu_x+2188,%a0
	clr.l %d0
.L774:
	cmp.l %d0,%d1
	jgt .L775
	move.l %d1,sfu_x+2452
	clr.l %d0
	lea sfu_x+2564,%a0
.L776:
	clr.b %d3
	moveq #14,%d1
	move.b %d3,(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L776
	mov3q.l #2,-(%sp)
	move.l #sfu_sysex,%d2
	mov3q.l #1,-(%sp)
	move.l #1397119061,%d3
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
	move.l %d2,1075551832
	move.l %d3,1075551828
	moveq #1,%d0
	lea (12,%sp),%sp
	move.b %d0,sfu_st+1026
.L765:
	move.l sfu_x+2320,%d0
	mov3q.l #1,%d1
	and.l %d0,%d1
	btst #0,%d0
	jne .L777
	cmp.l sfu_x+2456.l,%d0
	jeq .L777
	move.l sfu_x+2316,%a0
	lea sfu_x+2188,%a1
.L778:
	cmp.l %a0,%d1
	jeq .L779
	cmp.l #128,%d1
	jne .L780
.L779:
	cmp.l sfu_x+2320.l,%d0
	jne .L777
	tst.l %a0
	jeq .L777
	moveq #1,%d1
	move.l %a0,sfu_x+2452
	move.l 8(%fp),%a0
	move.l %d0,sfu_x+2456
	move.b %d1,32(%a0)
.L777:
	move.l sfu_x+2132,%d0
	tst.l %d0
	jeq .L781
	move.l %d0,-(%sp)
	move.l sfu_x+2160,%d2
	jsr sync
	addq.l #4,%sp
	cmp.l sfu_x+2160.l,%d2
	jeq .L782
.L881:
	moveq #1,%d0
	move.l 8(%fp),%a0
	move.b %d0,32(%a0)
.L782:
	move.l 8(%fp),%a1
	clr.l %d2
	lea sfu_p,%a2
	move.l %a2,%a3
	move.l %a1,-(%sp)
	move.l %a1,sfu_p+4700
	jsr top_page
	addq.l #4,%sp
	lea sfu_p+4240,%a5
	move.b %d0,sfu_p+4275
.L785:
	move.l %d2,%a4
	addq.l #1,%a4
	tst.b (%a5,%d2.l)
	jeq .L783
	mvz.b sfu_p+4275,%d0
	cmp.l %d0,%a4
	jne .L784
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L784
	move.l 4708(%a3),%d1
	cmp.l -2147457096.l,%d1
	jne .L784
	move.l %d2,-(%sp)
	jsr kitsig
	addq.l #4,%sp
	cmp.l 4716(%a3),%d0
	jeq .L783
.L784:
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr page_set
	move.b sfu_p+4724,%d1
	addq.l #8,%sp
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	moveq #1,%d2
	move.l 8(%fp),%a0
	addq.l #1,sfu_p+4300
	or.l %d1,%d0
	move.b %d0,sfu_p+4724
	move.b %d2,32(%a0)
.L783:
	addq.l #4,%a3
	mov3q.l #1,%d2
	mov3q.l #2,%d0
	cmp.l %a4,%d0
	jne .L785
	cmp.l 1094562388.l,%d2
	seq %d0
	mvz.b sfu_p+4725,%d1
	mvs.b %d0,%d0
	neg.l %d0
	cmp.l %d0,%d1
	jeq .L786
	cmp.l 1094562388.l,%d2
	seq %d0
	neg.l %d0
	move.b %d0,sfu_p+4725
	jsr relabel
	move.b sfu_p+4724,%d0
	move.l 8(%fp),%a0
	mov3q.l #3,%d1
	or.l %d1,%d0
	move.b %d0,sfu_p+4724
	move.b %d2,32(%a0)
.L786:
	move.b sfu_p+4724,%d0
	btst #0,%d0
	jeq .L787
	moveq #-2,%d1
	and.l %d1,%d0
	move.b %d0,sfu_p+4724
	mvz.b sfu_p+4275,%d0
	subq.l #1,%d0
	tst.l %d0
	jne .L787
	move.l sfu_p+4308,-(%sp)
	jsr retitle
	addq.l #4,%sp
.L787:
	move.b sfu_p+4724,%d0
	btst #1,%d0
	jeq .L788
	moveq #-3,%d3
	and.l %d3,%d0
	move.b %d0,sfu_p+4724
	mvz.b sfu_p+4275,%d0
	subq.l #2,%d0
	tst.l %d0
	jne .L788
	move.l sfu_p+4308,-(%sp)
	jsr retitle
	addq.l #4,%sp
.L788:
	tst.b sfu_p+4274.l
	jeq .L789
	clr.b %d2
	moveq #1,%d3
	move.l 8(%fp),%a0
	move.b %d2,sfu_p+4274
	move.b %d3,32(%a0)
.L789:
	move.l sfu_p+4280,%d0
	tst.l %d0
	jeq .L790
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jls .L790
	clr.l sfu_p+4280
.L790:
	move.l sfu_p+4284,%d0
	tst.l %d0
	jeq .L791
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jls .L791
	clr.l sfu_p+4284
.L791:
	lea sfu_p+4270,%a3
	clr.l %d2
	lea sfu_p+4246,%a4
.L797:
	tst.w (%a3)+
	jeq .L792
	lea sfu_p+4244,%a0
	move.b (%a0,%d2.l),%d1
	jeq .L792
	move.w #8707,%d3
	move.b %d2,-16(%fp)
	move.b %d1,-14(%fp)
	mvz.b %d1,%d0
	move.l #-260222380,%a1
	sub.l %a0,%a0
	move.l %a1,-22(%fp)
	move.w %d3,-18(%fp)
	moveq #5,%d3
	move.b %d3,-15(%fp)
.L793:
	lea (%a4,%a0.l),%a1
	addq.l #1,%a0
	move.b (%a1),-14(%a0,%fp.l)
	cmp.l %d0,%a0
	jlt .L793
	moveq #-9,%d1
	move.l %d0,%a0
	move.b %d1,-13(%fp,%d0.l)
	pea 10(%a0)
	pea -22(%fp)
	jsr try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L796
	clr.w %d0
	mov3q.l #1,%d1
	or.l -66650100,%d1
	move.w %d0,-2(%a3)
	move.l %d1,4280(%a2)
	addq.l #1,sfu_p+4288
.L795:
	addq.l #4,%a2
	lea (12,%a4),%a4
	subq.l #1,%d2
	tst.l %d2
	jne .L811
.L796:
	tst.b sfu_x+6689.l
	jeq .L798
	clr.b %d1
	moveq #1,%d2
	move.l 8(%fp),%a0
	move.b %d1,sfu_x+6689
	move.b %d2,32(%a0)
.L798:
	move.l sfu_x+6698,%d0
	tst.l %d0
	jeq .L799
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jls .L799
	clr.l sfu_x+6698
.L799:
	move.l sfu_x+6702,%d0
	tst.l %d0
	jeq .L800
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jls .L800
	clr.l sfu_x+6702
.L800:
	lea sfu_x,%a3
	clr.l %d2
	lea sfu_x+6684,%a2
.L804:
	mvz.b sfu_x+6688,%d0
	btst %d2,%d0
	jeq .L801
	move.w #8706,%d0
	moveq #-9,%d1
	move.b (%a2),-15(%fp)
	move.b 1(%a2),-14(%fp)
	pea 10.w
	move.l #-260222380,%a1
	pea -22(%fp)
	move.b %d2,-16(%fp)
	move.l %a1,-22(%fp)
	move.w %d0,-18(%fp)
	move.b %d1,-13(%fp)
	jsr try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L803
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	move.b sfu_x+6688,%d1
	mov3q.l #1,%d3
	or.l -66650100,%d3
	not.l %d0
	and.l %d1,%d0
	move.b %d0,sfu_x+6688
	move.l %d3,6698(%a3)
	addq.l #1,sfu_x+6690
.L801:
	addq.l #4,%a3
	addq.l #2,%a2
	subq.l #1,%d2
	tst.l %d2
	jne .L812
.L803:
	mvz.b sfu_st+1027,%d0
	lsr.l #1,%d0
	jne .L766
	move.w sfu_st+1028,%d0
	moveq #99,%d2
	mvz.w %d0,%d1
	cmp.l %d1,%d2
	jcs .L805
	addq.l #1,%d0
	move.w %d0,sfu_st+1028
	mvz.w %d0,%d0
	moveq #100,%d3
	cmp.l %d0,%d3
	jne .L766
.L805:
	mov3q.l #7,-(%sp)
	pea (m.0)
	jsr try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L766
	clr.w %d0
	addq.l #1,sfu_x+2152
	move.w %d0,sfu_st+1028
.L766:
	clr.l -(%sp)
	move.l -28(%fp),-(%sp)
	jsr timed
	addq.l #8,%sp
	move.l sfu_st+1042,%d0
	tst.l %d0
	jeq .L806
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jls .L806
	clr.l sfu_st+1042
.L806:
	tst.b sfu_st+1046.l
	jeq .L807
	tst.l sfu_st+1042
	jne .L807
	mov3q.l #1,%d1
	or.l -66650100,%d1
	clr.b %d2
	clr.l -(%sp)
	clr.l -(%sp)
	move.l %d1,sfu_st+1042
	move.b %d2,sfu_st+1046
	jsr 1074449254
	addq.l #8,%sp
.L807:
	tst.b sfu_st+1026.l
	jeq .L761
	move.l #1481856080,%d3
	cmp.l 1073848892.l,%d3
	jne .L761
	tst.l 1073848900
	jeq .L761
	move.l -66650100,%d2
	move.l 1073848900,%a0
	move.l 8(%fp),-(%sp)
	jsr (%a0)
	addq.l #4,%sp
	tst.l %d0
	jeq .L809
	moveq #1,%d0
	move.l 8(%fp),%a0
	move.b %d0,32(%a0)
.L809:
	move.l -66650100,%d0
	sub.l %d2,%d0
	add.l %d0,sfu_x+6418
	addq.l #1,sfu_x+6426
	cmp.l sfu_x+6422.l,%d0
	jls .L761
	move.l %d0,sfu_x+6422
.L761:
	movem.l -52(%fp),#15372
	unlk %fp
	rts
.L810:
	mvz.w #410,%d0
	jra .L767
.L775:
	move.b (%a0)+,%d2
	addq.l #1,%d0
	move.b %d2,135(%a0)
	jra .L774
.L780:
	move.b (%a1)+,%d2
	addq.l #1,%d1
	move.b %d2,135(%a1)
	jra .L778
.L781:
	move.l sfu_x+2084,%a1
	cmp.l sfu_x+2080.l,%a1
	jeq .L782
	lea sfu_x+2080,%a0
	move.l (%a0),sfu_x+2084
	jsr relabel
	jra .L881
.L811:
	mov3q.l #1,%d2
	jra .L797
.L792:
	clr.w %d3
	move.w %d3,-2(%a3)
	jra .L795
.L812:
	mov3q.l #1,%d2
	jra .L804
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
	.globl	sfu_st
	.text
	.align	2
	.type	sfu_st, @object
	.size	sfu_st, 1048
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
	.long	0
	.long	0
	.zero	2
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
