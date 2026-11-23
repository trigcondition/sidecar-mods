| Mod 0029 - Sidecar send FX pages: AMPLITUDE 2 (SEND FX 1/2) and the SEND FX 1/2 pages behind DELAY/REVERB.
| GENERATED from sfu.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit sfu.c.
#NO_APP
	.file	"sfu.c"
	.text
#APP
	.ifndef RAM_SFU_X
.pushsection .bss
.balign 16
sfu_x_bss: .space 6736
.popsection
.set RAM_SFU_X, sfu_x_bss
.set RAM_SFU_X_SIZE, 6736
.endif

	.globl sfu_x
.set sfu_x, RAM_SFU_X+8

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
	tst.l x_ok
	jeq .L1
	sub.l 4(%sp),%d0
	tst.l 8(%sp)
	jeq .L3
	add.l %d0,sfu_x+2176
	addq.l #1,sfu_x+2184
	cmp.l sfu_x+2180.l,%d0
	jls .L1
	move.l %d0,sfu_x+2180
.L1:
	rts
.L3:
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
	jge .L60
	moveq #127,%d0
.L61:
	mvz.b 2600(%a0),%d2
	mov3q.l #1,%d3
	cmp.l %d2,%d3
	jne .L62
	move.w %a1,%d2
	muls.w %d2,%d0
	asr.l #7,%d0
.L63:
	lsl.l #8,%d0
	tst.b 6557(%a0)
	jeq .L68
	and.l #224,%d1
.L66:
	or.l %d1,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L60:
	tst.l %d0
	jge .L61
	clr.l %d0
	jra .L61
.L62:
	subq.l #2,%d2
	tst.l %d2
	jne .L63
	cmp.l %d0,%a1
	jgt .L63
	tst.b 6430(%a0)
	jne .L67
	move.l %a1,%d0
	subq.l #1,%d0
	jra .L63
.L67:
	clr.l %d0
	jra .L63
.L68:
	clr.l %d1
	jra .L66
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
	jge .L70
	clr.l %d0
.L70:
	mvz.b 2600(%a2),%d1
	cmp.l %a1,%d0
	jlt .L71
	tst.b 6430(%a2)
	jeq .L72
	mov3q.l #2,%d2
	cmp.l %d1,%d2
	jeq .L75
.L72:
	move.l %a1,%d0
	subq.l #1,%d0
.L71:
	subq.l #1,%d1
	tst.l %d1
	jne .L73
	lsl.l #7,%d0
	move.l %a1,%d2
	lea -1(%a1,%d0.l),%a3
	move.l %a3,%d0
	divs.l %d2,%d0
.L73:
	lsl.l #8,%d0
	addq.l #1,sfu_x+2592
	tst.b 6557(%a2)
	jeq .L76
	move.l %a0,%d1
	and.l #224,%d1
.L74:
	or.l %d1,%d0
	movem.l (%sp),#3084
	lea (16,%sp),%sp
	rts
.L75:
	clr.l %d0
	jra .L73
.L76:
	clr.l %d1
	jra .L74
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
	jcs .L78
	move.l %a0,%d5
	lsl.l #2,%d5
	lea sfu_x,%a1
	add.l %d5,%a1
	tst.l 3362(%a1)
	jeq .L78
	add.l #sfu_x,%a0
	tst.b 2600(%a0)
	jeq .L81
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	jsr x_half
	subq.l #1,sfu_x+2592
	addq.l #8,%sp
.L81:
	lea sfu_x,%a0
	add.l %d5,%a0
	move.l %d4,28(%sp)
	move.l %d3,20(%sp)
	movem.l (%sp),#60
	move.l %d0,24(%sp)
	move.l 3362(%a0),%a1
	lea (16,%sp),%sp
	jmp (%a1)
.L78:
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
	lea (-20,%sp),%sp
	movem.l #1084,(%sp)
	move.l 24(%sp),%d3
	move.l 28(%sp),%d1
	move.l 32(%sp),%d2
	tst.l x_ok
	jne .L84
	asr.l #8,%d1
	move.l %d1,-(%sp)
.L91:
	pea s_empty
	pea fmt_d
	move.l %d2,-(%sp)
	jsr 1074365954
	lea (16,%sp),%sp
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L84:
	move.l %d3,%d0
	moveq #84,%d4
	add.l #-1100630172,%d0
	divu.l %d4,%d0
	move.l %d0,%a0
	moveq #126,%d0
	lea (-334,%a0),%a0
	cmp.l %a0,%d0
	jcs .L86
	lea sfu_x,%a1
	lea (%a1,%a0.l*4),%a2
	tst.l 3362(%a2)
	jeq .L86
	add.l %a1,%a0
	move.b 2600(%a0),%d0
	move.w %d0,%a1
	move.l %a1,%d0
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
	mvz.b 2727(%a0),%d1
	cmp.l %d1,%d0
	jlt .L88
	tst.b 6430(%a0)
	jeq .L89
	move.w %a1,%d5
	mvz.b %d5,%d0
	subq.l #2,%d0
	tst.l %d0
	jeq .L90
.L89:
	move.l %d1,%d0
	subq.l #1,%d0
.L88:
	move.l %d0,%a0
	pea 1(%a0)
	jra .L91
.L90:
	clr.l %d0
	jra .L88
.L86:
	move.l %d2,32(%sp)
	move.l %d3,24(%sp)
	movem.l (%sp),#1084
	move.l %d1,28(%sp)
	lea (20,%sp),%sp
	jra xname
	.size	sfu_xtext, .-sfu_xtext
	.align	2
	.type	see_fxset, @function
see_fxset:
	move.l 4(%sp),%d0
	move.l sfu_x+2132,%d1
	cmp.l %d1,%d0
	jeq .L92
	tst.l %d1
	jeq .L94
	addq.l #1,sfu_x+2140
.L94:
	move.l %d0,sfu_x+2132
.L92:
	rts
	.size	see_fxset, .-see_fxset
	.align	2
	.globl	sfu_route_text
	.type	sfu_route_text, @function
sfu_route_text:
	move.l 8(%sp),%d0
	asr.l #8,%d0
	move.l 12(%sp),%d1
	tst.l %d0
	jeq .L100
	move.l #s_post,%d0
.L99:
	move.l %d0,12(%sp)
	move.l #fmt_s,%d0
	move.l %d0,8(%sp)
	move.l %d1,4(%sp)
	jmp 1074365954
.L100:
	move.l #s_pre,%d0
	jra .L99
	.size	sfu_route_text, .-sfu_route_text
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
.L102:
	lea (%a0,%d0.l),%a2
	moveq #84,%d1
	move.l (%a2),(%a1,%a0.l)
	addq.l #4,%a0
	cmp.l %a0,%d1
	jne .L102
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
	jeq .L111
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jge .L112
	subq.l #1,%d1
	lsl.l #8,%d1
	move.l #1100634268,%a2
.L105:
	move.w %d0,%d2
	move.l #1075575076,%a4
	move.l %a0,%a3
	add.l #sfu_x,%a3
	mulu.w #52,%d2
	move.l %d1,(%a4,%d2.l)
	mvz.b 2564(%a3),%d1
	cmp.l %d1,%a1
	jeq .L104
	mulu.w #84,%d0
	move.l %d0,%a0
	add.l #1100630152,%a0
	move.l (%a2),(%a0)
	move.l 4(%a2),4(%a0)
	move.l 8(%a2),8(%a0)
	move.l 16(%a2),16(%a0)
	tst.l %a1
	jne .L107
	move.l 1100664640,%d0
.L108:
	move.l %d0,48(%a0)
	move.w %a1,%d0
	move.b %d0,2564(%a3)
.L104:
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	rts
.L111:
	mvz.w #32512,%d1
	move.l #1100664592,%a2
	jra .L105
.L112:
	mvz.w #256,%d1
	move.l #1100634268,%a2
	jra .L105
.L107:
	mov3q.l #2,%d0
	cmp.l %a1,%d0
	jne .L109
	move.l 1100633980,%d0
	jra .L108
.L109:
	mov3q.l #3,%d2
	cmp.l %a1,%d2
	jne .L110
	move.l 1100637004,%d0
	jra .L108
.L110:
	move.l #sfu_draw,%d0
	jra .L108
	.size	set_look, .-set_look
	.align	2
	.type	xmode, @function
xmode:
	lea (-32,%sp),%sp
	movem.l #7292,(%sp)
	move.l 36(%sp),%d3
	tst.l x_ok
	jne .L114
.L116:
	clr.l %d0
.L113:
	movem.l (%sp),#7292
	lea (32,%sp),%sp
	rts
.L114:
	move.l %d3,%d4
	moveq #126,%d0
	add.l #-334,%d4
	cmp.l %d4,%d0
	jcs .L116
	tst.b sfu_st+1026.l
	jeq .L116
	move.l #1481856080,%d1
	cmp.l 1073848892.l,%d1
	jne .L116
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
	jeq .L117
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
	jcs .L118
	clr.b %d0
	move.b %d0,2600(%a2)
.L118:
	move.l sfu_st+1034,%d1
	move.l %d2,%a0
	addq.l #1,%d1
	add.l %d5,%a0
	move.l %d1,2854(%a0)
.L117:
	move.w %d3,%d0
	mulu.w #52,%d3
	move.l %d3,%a1
	add.l #1075575064,%a1
	mulu.w #84,%d0
	move.l %d0,%a0
	add.l #1100630152,%a0
	move.l 32(%a0),%d0
	tst.b 2600(%a2)
	jeq .L119
	cmp.l #sfu_xtext,%d0
	jeq .L120
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
.L120:
	mvz.b 2727(%a2),%d0
	subq.l #1,%d0
	lsl.l #8,%d0
	tst.b 6557(%a2)
	jeq .L123
	mvz.w #224,%d1
.L121:
	or.l %d1,%d0
.L126:
	move.l %d0,12(%a1)
.L122:
	mvz.b 2600(%a2),%d0
	jra .L113
.L123:
	clr.l %d1
	jra .L121
.L119:
	cmp.l #sfu_xtext,%d0
	jne .L122
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
	jra .L126
	.size	xmode, .-xmode
	.align	2
	.type	type_text, @function
type_text:
	lea (-12,%sp),%sp
	movem.l #1036,(%sp)
	move.l 20(%sp),%d0
	asr.l #8,%d0
	move.l 16(%sp),%d2
	move.l 24(%sp),%d3
	tst.l x_ok
	jne .L128
	move.l %d0,-(%sp)
	pea s_empty
.L136:
	pea fmt_d
	move.l %d3,-(%sp)
	jsr 1074365954
	lea (16,%sp),%sp
	movem.l (%sp),#1036
	lea (12,%sp),%sp
	rts
.L128:
	move.l %d0,-(%sp)
	move.l %d2,%a0
	add.l #sfu_x,%a0
	mvz.b 2088(%a0),%d0
	move.l %d0,-(%sp)
	move.l %d2,-(%sp)
	jsr tid
	lea (12,%sp),%sp
	moveq #127,%d1
	move.l %d0,%a1
	cmp.l %d0,%d1
	jge .L130
	move.w #127,%a1
.L130:
	mvz.w %a1,%d1
	lsl.l #3,%d1
	move.l %d1,%a0
	add.l #sfu_st,%a0
	tst.b (%a0)
	jne .L131
	moveq #63,%d1
	cmp.l %d0,%d1
	jge .L134
	lea (-63,%a1),%a1
	move.l #s_ufx,%d0
.L132:
	move.l %a1,-(%sp)
	move.l %d0,-(%sp)
	jra .L136
.L134:
	move.l #s_fx,%d0
	jra .L132
.L131:
	add.l #sfu_st,%d2
	move.l %d2,%a2
	mvz.b 1024(%a2),%d0
	cmp.l %a1,%d0
	jne .L135
	move.l #fmt_bang,%d0
.L133:
	move.l %d3,16(%sp)
	movem.l (%sp),#1036
	move.l %a0,24(%sp)
	move.l %d0,20(%sp)
	lea (12,%sp),%sp
	jmp 1074365954
.L135:
	move.l #fmt_s,%d0
	jra .L133
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
	.type	ptext, @function
ptext:
	lea (-36,%sp),%sp
	movem.l #7292,(%sp)
	move.l 52(%sp),%d3
	move.l %d3,%d0
	move.l 40(%sp),%a0
	asr.l #8,%d0
	move.l 44(%sp),%d2
	move.l 56(%sp),%a1
	move.l 48(%sp),32(%sp)
	tst.l x_ok
	jne .L140
	move.l #s_empty,%d1
	move.l #fmt_d,%d2
	move.l %d0,52(%sp)
	move.l %d1,48(%sp)
	move.l %d2,44(%sp)
.L177:
	movem.l (%sp),#7292
	move.l %a1,40(%sp)
	lea (36,%sp),%sp
	jmp 1074365954
.L140:
	move.l %a0,%a2
	add.l #sfu_x,%a2
	mvz.b 2090(%a2),%d4
	lea sfu_x,%a2
	clr.l %d1
	move.l %a2,%a3
	addq.l #1,%d4
.L143:
	mvz.b (%a2),%d5
	cmp.l %d5,%d4
	jne .L141
	mulu.w #130,%d1
	move.l %d1,%a2
	add.l #sfu_x,%a2
.L142:
	lea (%a3,%a0.l*4),%a4
	move.l %a4,%d1
	add.l %d2,%d1
	move.l %d1,%a4
	mvz.b 2460(%a4),%d1
	tst.l %d0
	jge .L144
	clr.l %d0
.L144:
	tst.l %d1
	jeq .L145
	cmp.l %d1,%d0
	jlt .L146
	move.l %d1,%d0
	subq.l #1,%d0
.L146:
	move.l %a0,%d1
	moveq #48,%d4
	moveq #12,%d5
	muls.l %d4,%d1
	muls.l %d2,%d5
	move.l %d5,%a0
	add.l %d1,%a0
	add.l %a3,%a0
	add.l %d0,%a0
	mvz.b 2468(%a0),%d0
.L145:
	moveq #127,%d6
	cmp.l %d0,%d6
	jge .L147
	moveq #127,%d0
.L147:
	tst.l %a2
	jeq .L148
	mvz.b 1(%a2),%d5
	lea (22,%a2),%a3
	mov3q.l #-1,%a0
	clr.l %d1
.L149:
	cmp.l %d1,%d5
	jle .L151
	moveq #12,%d4
	cmp.l %d1,%d4
	jne .L152
.L151:
	mov3q.l #-1,%d5
	cmp.l %a0,%d5
	jeq .L148
	move.l %a0,%d1
	moveq #99,%d6
	lsl.l #3,%d1
	add.l %a0,%d1
	lea (%a2,%d1.l),%a0
	mvz.b 23(%a0),%d2
	sub.l %d2,%d0
	mvz.b 24(%a0),%d2
	add.l %d2,%d0
	cmp.l %d0,%d6
	jlt .L161
	moveq #9,%d2
	cmp.l %d0,%d2
	jge .L162
	mov3q.l #2,%a3
.L153:
	lea 25(%a2,%d1.l),%a0
	move.l %a0,%d2
	lea (%a2,%d1.l),%a0
	move.b 22(%a0),%d1
	move.w %d1,%ccr
	jne .L154
	sub.l %a2,%a2
.L155:
	tst.b 25(%a0,%a2.l)
	jeq .L156
	addq.l #1,%a2
	mov3q.l #5,%d1
	cmp.l %a2,%d1
	jne .L155
.L156:
	lea 1(%a3,%a2.l),%a0
	mov3q.l #7,%d4
	cmp.l %a0,%d4
	jlt .L163
	move.l #fmt_sn,%d1
.L158:
	move.l %d0,52(%sp)
	move.l %d2,48(%sp)
	move.l %d1,44(%sp)
	jra .L177
.L141:
	addq.l #1,%d1
	lea (130,%a2),%a2
	moveq #16,%d5
	cmp.l %d1,%d5
	jne .L143
	sub.l %a2,%a2
	jra .L142
.L152:
	move.b (%a3),%d4
	mov3q.l #3,%d6
	and.l %d6,%d4
	cmp.l %d2,%d4
	jne .L150
	mvz.b 1(%a3),%d4
	cmp.l %d0,%d4
	jgt .L150
	move.l %d1,%a0
.L150:
	addq.l #1,%d1
	lea (9,%a3),%a3
	jra .L149
.L161:
	mov3q.l #3,%a3
	jra .L153
.L162:
	mov3q.l #1,%a3
	jra .L153
.L154:
	lea fmt_s,%a4
	move.l %d2,48(%sp)
	move.l %a4,44(%sp)
	movem.l (%sp),#7292
	move.l %a1,40(%sp)
	lea (36,%sp),%sp
	jmp 1074365954
.L163:
	move.l #fmt_n,%d1
	jra .L158
.L148:
	move.l sfu_x+2136,%d1
	tst.l %d1
	jeq .L159
	move.l %d3,44(%sp)
	movem.l (%sp),#7292
	move.l %a1,48(%sp)
	move.l 32(%sp),40(%sp)
	move.l %d1,%a1
	lea (36,%sp),%sp
	jmp (%a1)
.L159:
	move.l #s_empty,%d6
	lea fmt_d,%a0
	move.l %d0,52(%sp)
	move.l %d6,48(%sp)
	move.l %a0,44(%sp)
	jra .L177
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
	.globl	sfu_draw
	.type	sfu_draw, @function
sfu_draw:
	lea (-44,%sp),%sp
	movem.l #16412,(%sp)
	clr.b %d3
	move.l -66650100,%d1
	move.l 64(%sp),%d2
	subq.l #2,%d2
	move.l 52(%sp),%a0
	move.l %d1,16(%sp)
	lea (20,%sp),%a6
	move.b %d3,20(%sp)
	tst.l x_ok
	jne .L187
	move.l %a0,%d0
	asr.l #8,%d0
	move.l %d0,-(%sp)
	pea s_empty
	pea fmt_d
	move.l %a6,-(%sp)
	jsr 1074365954
	move.b %d3,44(%sp)
	move.l #1098791068,-(%sp)
	jsr 1074207612
	move.l %a6,-(%sp)
	pea fmt_s
	move.l %a6,-(%sp)
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	move.l 104(%sp),-(%sp)
	move.l %d0,-(%sp)
	move.l 108(%sp),-(%sp)
	jsr 1074205920
	lea (56,%sp),%sp
.L188:
	clr.l %d0
	movem.l (%sp),#16412
	lea (44,%sp),%sp
	rts
.L187:
	move.l 48(%sp),%d0
	add.l #-1100630188,%d0
	move.l %d0,%d1
	moveq #84,%d4
	divu.l %d4,%d1
	moveq #126,%d3
	move.l %d1,%a1
	lea (-334,%a1),%a1
	cmp.l %a1,%d3
	jcs .L189
	muls.l %d4,%d1
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	add.l #1100630172,%d1
	move.l %d1,-(%sp)
	jsr xname
.L195:
	lea (12,%sp),%sp
.L190:
	clr.b %d3
	move.b %d3,28(%sp)
	tst.b 20(%sp)
	jeq .L194
	move.l %a6,%d3
.L193:
	move.l #1098791068,-(%sp)
	jsr 1074207612
	move.l %a6,-(%sp)
	pea fmt_s
	move.l %d3,-(%sp)
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	move.l 88(%sp),-(%sp)
	move.l %d0,-(%sp)
	move.l 92(%sp),-(%sp)
	jsr 1074205920
	lea (36,%sp),%sp
	clr.l (%sp)
	move.l 20(%sp),-(%sp)
	jsr timed
	addq.l #8,%sp
	jra .L188
.L189:
	add.l #-16,%d1
	moveq #11,%d4
	cmp.l %d1,%d4
	jcs .L190
	mov3q.l #6,%d3
	rems.l %d3,%d4:%d1
	cmp.l #1847,%d0
	shi %d0
	move.l %d4,%a1
	mvs.b %d0,%d0
	neg.l %d0
	tst.l %d4
	jne .L191
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	move.l %d0,-(%sp)
	jsr type_text
	jra .L195
.L191:
	mov3q.l #1,%d1
	cmp.l %d4,%d1
	jne .L192
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	clr.l -(%sp)
	jsr sfu_route_text
	jra .L195
.L192:
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	clr.l -(%sp)
	pea -2(%a1)
	move.l %d0,-(%sp)
	jsr ptext
	lea (20,%sp),%sp
	jra .L190
.L194:
	move.l #s_wide,%d3
	jra .L193
	.size	sfu_draw, .-sfu_draw
	.align	2
	.globl	sfu_sysex
	.type	sfu_sysex, @function
sfu_sysex:
	move.l -66650100,%d1
	lea (-36,%sp),%sp
	movem.l #15420,(%sp)
	move.l 40(%sp),%a0
	move.l 44(%sp),%d0
	move.l %d1,32(%sp)
	tst.l x_ok
	jne .L197
	addq.l #1,x_drops
.L198:
	movem.l (%sp),#15420
	mov3q.l #1,%d0
	lea (36,%sp),%sp
	rts
.L197:
	moveq #9,%d2
	cmp.l %d0,%d2
	jge .L199
	mvz.b 4(%a0),%d1
	moveq #34,%d3
	cmp.l %d1,%d3
	jne .L200
	mvz.b 5(%a0),%d1
	subq.l #2,%d1
	tst.l %d1
	jne .L200
	mvz.b 6(%a0),%d0
	mov3q.l #1,%d5
	cmp.l %d0,%d5
	jcs .L201
	mvz.b sfu_x+6688,%d1
	lea sfu_x,%a1
	btst %d0,%d1
	jne .L202
	lea (%a1,%d0.l*4),%a2
	move.l 6698(%a2),%d1
	tst.l %d1
	jeq .L203
	move.l -66650100,%d2
	sub.l %d1,%d2
	cmp.l #65999999,%d2
	jls .L202
.L203:
	move.b 7(%a0),%d1
	moveq #127,%d3
	moveq #127,%d5
	move.l %d0,%d2
	add.l #3342,%d2
	mvz.b (%a1,%d2.l*2),%d4
	and.l %d1,%d3
	cmp.l %d4,%d3
	jne .L204
	lea (%a1,%d0.l*2),%a2
	move.b 8(%a0),%d0
	mvz.b 6685(%a2),%d1
	and.l %d5,%d0
	cmp.l %d1,%d0
	jeq .L202
.L204:
	move.b %d3,(%a1,%d2.l*2)
	moveq #127,%d1
	moveq #1,%d2
	mvz.b 6(%a0),%d0
	lea (%a1,%d0.l*2),%a1
	move.b 8(%a0),%d0
	move.b %d2,sfu_x+6689
	and.l %d1,%d0
	move.b %d0,6685(%a1)
.L202:
	addq.l #1,sfu_x+6694
.L201:
	mov3q.l #1,-(%sp)
	move.l 36(%sp),-(%sp)
	jsr timed
	addq.l #8,%sp
	jra .L198
.L199:
	mov3q.l #7,%d3
	cmp.l %d0,%d3
	jge .L201
.L200:
	mvz.b 5(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L201
	mvz.b 4(%a0),%d1
	moveq #33,%d5
	cmp.l %d1,%d5
	jne .L205
	addq.l #1,sfu_x+2320
	tst.b 6(%a0)
	jeq .L206
	clr.b %d1
	mov3q.l #1,sfu_x+2316
	lea sfu_st,%a1
	move.b %d1,sfu_x+2188
	clr.l %d1
.L207:
	clr.b (%a1)
	addq.l #1,%d1
	addq.l #8,%a1
	cmp.l #128,%d1
	jne .L207
	lea sfu_x,%a1
	clr.l %d1
.L208:
	clr.b (%a1)
	addq.l #1,%d1
	lea (130,%a1),%a1
	moveq #16,%d2
	cmp.l %d1,%d2
	jne .L208
	move.l #1330005504,%d3
	addq.l #1,sfu_x+2080
	move.l %d3,sfu_st
.L206:
	subq.l #1,%d0
	addq.l #8,%a0
	moveq #9,%d3
	lea sfu_st,%a3
	lea sfu_x+2188,%a4
.L209:
	move.l %d3,%d1
	add.l #12,%d1
	cmp.l %d1,%d0
	jgt .L218
	moveq #2,%d0
	addq.l #1,sfu_x+2596
	addq.l #1,sfu_x+2320
	move.b %d0,sfu_st+1027
	jra .L201
.L218:
	move.b (%a0),%d2
	jmi .L210
	move.b %d2,%d1
	sub.l %a2,%a2
	ext.w %d1
	mvz.w %d1,%d1
	lsl.l #3,%d1
	move.l %d1,%a1
	add.l #sfu_st,%a1
.L214:
	move.b 1(%a0,%a2.l),%d1
	moveq #94,%d5
	move.l %d1,%d4
	add.l #-32,%d4
	mvz.b %d4,%d4
	cmp.l %d4,%d5
	jcs .L211
	move.b %d1,(%a1,%a2.l)
.L212:
	addq.l #1,%a2
	mov3q.l #7,%d5
	cmp.l %a2,%d5
	jne .L214
	jra .L213
.L211:
	clr.b %d4
	move.b %d4,(%a1,%a2.l)
	tst.b %d1
	jne .L212
.L213:
	mvz.b %d2,%d4
	clr.b %d5
	sub.l %a1,%a1
	move.l %d4,%d1
	lsl.l #3,%d1
	move.b %d5,7(%a3,%d1.l)
	move.l sfu_x+2316,%d1
.L215:
	cmp.l %a1,%d1
	jle .L216
	mvz.b (%a4,%a1.l),%d5
	cmp.l %d4,%d5
	jne .L217
.L216:
	cmp.l %d1,%a1
	jne .L210
	cmp.l #128,%d1
	jeq .L210
	move.l %d1,%a1
	add.l #sfu_x,%d1
	move.l %d1,%a2
	addq.l #1,%a1
	move.b %d2,2188(%a2)
	move.l %a1,sfu_x+2316
.L210:
	lea (14,%a0),%a0
	add.l #14,%d3
	jra .L209
.L217:
	addq.l #1,%a1
	jra .L215
.L205:
	moveq #36,%d2
	cmp.l %d1,%d2
	jne .L219
	moveq #23,%d3
	cmp.l %d0,%d3
	jge .L220
	mov3q.l #7,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L220
	move.b 6(%a0),%d2
	moveq #127,%d4
	mvz.b %d2,%d1
	cmp.l %d1,%d4
	jge .L221
.L220:
	addq.l #1,sfu_x+2144
	jra .L201
.L221:
	lea sfu_x,%a2
	addq.l #1,%d1
	move.l %a2,%a3
	clr.l %d3
.L224:
	mvz.b (%a3),%d4
	move.l %a3,%a1
	cmp.l %d4,%d1
	jeq .L222
	sub.l %a1,%a1
.L222:
	addq.l #1,%d3
	moveq #16,%d5
	cmp.l %d3,%d5
	jeq .L246
	lea (130,%a3),%a3
	tst.l %a1
	jeq .L224
.L246:
	clr.l %d1
.L226:
	tst.l %a1
	jeq .L228
.L229:
	clr.b (%a1)
	move.l %a1,%a3
	clr.l %d1
.L230:
	mvz.w %d1,%d3
	sub.l %a2,%a2
	lea (%a0,%d3.l*4),%a4
.L232:
	move.b 7(%a4,%a2.l),%d4
	moveq #94,%d5
	move.l %d4,%d3
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcs .L231
	move.b %d4,2(%a3,%a2.l)
	addq.l #1,%a2
	mov3q.l #4,%d3
	cmp.l %a2,%d3
	jne .L232
.L231:
	move.l %d1,%a5
	addq.l #5,%a3
	lea (%a5,%d1.l*4),%a4
	clr.b %d3
	addq.l #1,%d1
	mov3q.l #4,%d4
	add.l %a1,%a4
	move.b %d3,2(%a2,%a4.l)
	cmp.l %d1,%d4
	jne .L230
	moveq #127,%d5
	cmp.l %d0,%d5
	jlt .L247
	asr.l #3,%d0
	move.l %d0,%d3
	subq.l #3,%d3
.L234:
	move.l %a1,%d0
	clr.l %d1
	lea (23,%a0),%a0
	add.l #22,%d0
.L235:
	cmp.l %d1,%d3
	jne .L238
	addq.l #1,%d2
	move.b %d1,1(%a1)
	move.b %d2,(%a1)
	addq.l #1,sfu_x+2148
	addq.l #1,sfu_x+2080
	jra .L201
.L228:
	tst.b (%a2)
	jne .L225
	move.l %a2,%a1
.L225:
	addq.l #1,%d1
	lea (130,%a2),%a2
	moveq #16,%d3
	cmp.l %d1,%d3
	jne .L226
	tst.l %a1
	jne .L229
	jra .L220
.L247:
	moveq #12,%d3
	jra .L234
.L238:
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
.L237:
	move.b 3(%a0,%a2.l),%d4
	move.l %d4,%a3
	lea (-32,%a3),%a3
	move.w %a3,%d5
	mvz.b %d5,%d5
	move.l %d5,%a3
	moveq #94,%d5
	cmp.l %a3,%d5
	jcs .L236
	move.b %d4,25(%a4,%a2.l)
	addq.l #1,%a2
	mov3q.l #5,%d4
	cmp.l %a2,%d4
	jne .L237
.L236:
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
	jra .L235
.L219:
	moveq #34,%d2
	cmp.l %d1,%d2
	jne .L201
	moveq #8,%d3
	cmp.l %d0,%d3
	jeq .L201
	mvz.b 6(%a0),%d2
	mov3q.l #1,%d4
	cmp.l %d2,%d4
	jcs .L201
	mvz.b 8(%a0),%d3
	move.b 7(%a0),%d1
	subq.l #3,%d3
	tst.l %d3
	jne .L248
	move.b %d1,%d3
.L239:
	lea sfu_st,%a3
	lea (%a3,%d2.l),%a1
	move.b %d3,1024(%a1)
	mvz.b 8(%a0),%d2
	subq.l #3,%d2
	tst.l %d2
	jne .L201
	tst.b %d1
	jlt .L201
	mvz.b %d1,%d2
	lsl.l #3,%d2
	tst.b (%a3,%d2.l)
	jne .L201
	ext.w %d1
	subq.l #1,%d0
	sub.l %a2,%a2
	mvz.w %d1,%d1
	lsl.l #3,%d1
	lea (%a3,%d1.l),%a1
	moveq #9,%d1
.L240:
	cmp.l %d0,%d1
	jge .L242
	move.b (%a0,%d1.l),%d4
	moveq #94,%d5
	move.l %d4,%d3
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcs .L242
	move.b %d4,(%a1,%a2.l)
	addq.l #1,%a2
	addq.l #1,%d1
	mov3q.l #7,%d3
	cmp.l %a2,%d3
	jne .L240
.L242:
	clr.b %d4
	add.l %d2,%a3
	move.b %d4,(%a3,%a2.l)
	jra .L201
.L248:
	st %d3
	jra .L239
	.size	sfu_sysex, .-sfu_sysex
	.align	2
	.type	try_send, @function
try_send:
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jeq .L277
.L283:
	clr.l %d0
.L276:
	rts
.L277:
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L279
	addq.l #1,sfu_x+2156
	jra .L276
.L279:
	mvz.w #4027,%d0
	cmp.l 1094562392.l,%d0
	jlt .L280
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L281:
	tst.l %a0
	jeq .L280
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L281
	move.l 4(%sp),-(%sp)
	move.l 12(%sp),-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	mov3q.l #1,%d0
	jra .L276
.L280:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #1,sfu_x+2156
	addq.l #4,%sp
	jra .L283
	.size	try_send, .-try_send
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
.L314:
	mvz.b (%a6)+,%d1
	lea sfu_x,%a0
	clr.l %d0
	addq.l #1,%d1
.L292:
	mvz.b (%a0),%d2
	cmp.l %d2,%d1
	jne .L290
	mulu.w #130,%d0
	move.l %d0,%a2
	add.l #sfu_x,%a2
.L291:
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
.L313:
	tst.l %a2
	jeq .L328
	sub.l %a0,%a0
.L293:
	move.b 2(%a0,%d7.l),%d0
	jeq .L295
	move.b %d0,(%a4,%a0.l)
	addq.l #1,%a0
	mov3q.l #4,%d0
	cmp.l %a0,%d0
	jne .L293
.L295:
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
.L297:
	mvz.b 1(%a2),%d3
	cmp.l 56(%sp),%d3
	jle .L299
	moveq #12,%d3
	cmp.l 56(%sp),%d3
	jne .L300
.L299:
	tst.l %d4
	jeq .L301
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L301
	move.l 44(%sp),%a1
	mov3q.l #2,%d0
	move.b %d1,(%a1,%a3.l)
	cmp.l %d1,%d0
	jeq .L304
.L329:
	mov3q.l #1,%d0
	jra .L303
.L318:
	mov3q.l #1,48(%sp)
	jra .L314
.L290:
	addq.l #1,%d0
	lea (130,%a0),%a0
	moveq #16,%d2
	cmp.l %d0,%d2
	jne .L292
	sub.l %a2,%a2
	jra .L291
.L300:
	move.l %d2,%a1
	mov3q.l #3,%d6
	move.b (%a1),%d3
	and.l %d3,%d6
	cmp.l %d6,%a3
	jne .L298
	moveq #8,%d6
	and.l %d6,%d3
	lea (1,%a1),%a5
	or.l %d3,%d4
	move.l %d0,%d3
	add.l %d1,%d3
	move.l %d3,%a1
	addq.l #1,%d1
	move.b (%a5),2468(%a1)
.L298:
	addq.l #1,56(%sp)
	add.l #9,%d2
	jra .L297
.L328:
	clr.b %d6
	move.l %a3,%d0
	add.l #50,%d0
	move.b #80,(%a4)
	move.b %d0,1(%a4)
	move.b %d6,2(%a4)
.L301:
	clr.b %d1
	move.l 44(%sp),%a0
	clr.l %d0
	move.b %d1,(%a0,%a3.l)
	clr.l %d1
.L303:
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
	jne .L313
	move.b -1(%a6),1(%a6)
	addq.l #6,52(%sp)
	addq.l #4,44(%sp)
	add.l #20,%d5
	mov3q.l #1,%d1
	cmp.l 48(%sp),%d1
	jne .L318
	movem.l (%sp),#31996
	addq.l #1,sfu_x+2160
	lea (72,%sp),%sp
	rts
.L304:
	mvz.b 1(%a2),%d2
	clr.l %d0
	sub.l %a1,%a1
	move.l %d2,60(%sp)
.L305:
	cmp.l 60(%sp),%a1
	jge .L311
	moveq #12,%d3
	cmp.l %a1,%d3
	jne .L312
.L311:
	mov3q.l #2,%d6
	cmp.l %d0,%d6
	jne .L329
	mov3q.l #2,%d1
	jra .L303
.L312:
	move.b (%a0),%d2
	mov3q.l #3,%d3
	and.l %d3,%d2
	cmp.l %d2,%a3
	jne .L306
	lea (3,%a0),%a5
	move.l %a5,56(%sp)
	tst.l %d0
	jeq .L316
	move.l #.LC0,%d6
.L307:
	clr.l %d4
.L309:
	move.l %d6,%a5
	move.b (%a5,%d4.l),%d3
	move.l 56(%sp),%a5
	move.b (%a5,%d4.l),%d2
	tst.b %d3
	jeq .L308
	mvs.b %d3,%d3
	mvs.b %d2,%d2
	addq.l #1,%d4
	cmp.l %d3,%d2
	jeq .L309
	jra .L329
.L316:
	move.l #.LC1,%d6
	jra .L307
.L308:
	tst.b %d2
	jne .L329
	addq.l #1,%d0
	mov3q.l #2,%d2
	cmp.l %d0,%d2
	jlt .L329
.L306:
	addq.l #1,%a1
	lea (9,%a0),%a0
	jra .L305
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
	jne .L331
	mvz.b sfu_x+2090,%d0
	cmp.l %d0,%d3
	jne .L331
	mvz.b sfu_x+2091,%d0
	cmp.l %d0,%d2
	jeq .L332
.L331:
	lea sfu_x+2080,%a0
	move.l (%a0),sfu_x+2084
	jsr relabel
.L332:
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
	move.l %d2,-(%sp)
	move.l 8(%sp),%d0
	tst.l x_ok
	jeq .L335
	move.l %d0,%d1
	subq.l #1,%d1
	lsr.l #2,%d1
	jeq .L336
	move.l %d0,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L333:
	move.l (%sp)+,%d2
	rts
.L335:
	clr.l %d0
	jra .L333
.L336:
	mov3q.l #1,%d0
	jra .L333
	.size	sfu_isext, .-sfu_isext
	.align	2
	.globl	sfu_s_read
	.type	sfu_s_read, @function
sfu_s_read:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 12(%sp),%d0
	move.l 16(%sp),%d3
	tst.l x_ok
	jne .L338
	move.l %d3,16(%sp)
	move.l %d0,12(%sp)
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	jmp 1074433530
.L338:
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	jsr 1074433530
	addq.l #8,%sp
	moveq #13,%d1
	move.l %d0,%d2
	move.l %d3,%d0
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcs .L339
	btst #0,%d0
	jeq .L340
	lsl.l #7,%d2
.L340:
	and.l #32512,%d2
.L337:
	move.l %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L339:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L337
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
	mov3q.l #3,%d1
	movem.l #28,(%sp)
	move.l 20(%sp),%d3
	move.l %d3,%d0
	move.l 16(%sp),%d4
	subq.l #1,%d0
	tst.l x_ok
	jne .L346
	cmp.l %d0,%d1
	jcc .L352
	move.l %d3,20(%sp)
	move.l %d4,16(%sp)
	movem.l (%sp),#28
	lea (12,%sp),%sp
	jmp 1074433680
.L346:
	cmp.l %d0,%d1
	jcs .L348
	add.l #sfu_x+6684,%d0
	move.l %d0,%a0
	mvz.b (%a0),%d2
	lsl.l #8,%d2
.L345:
	move.l %d2,%d0
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L348:
	move.l %d3,-(%sp)
	move.l %d4,-(%sp)
	jsr 1074433680
	move.l %d4,-(%sp)
	add.l #-14,%d3
	move.l %d0,%d2
	jsr see_fxset
	lea (12,%sp),%sp
	moveq #13,%d0
	cmp.l %d3,%d0
	jcs .L345
	tst.b sfu_st+1026.l
	jeq .L349
	move.l %d4,-(%sp)
	jsr sync
	addq.l #4,%sp
.L349:
	btst #0,%d3
	jeq .L350
	lsl.l #7,%d2
.L350:
	and.l #32512,%d2
	move.l %d3,16(%sp)
	move.l %d2,20(%sp)
	movem.l (%sp),#28
	lea (12,%sp),%sp
	jra to_knob
.L352:
	clr.l %d2
	jra .L345
	.size	sfu_f_read, .-sfu_f_read
	.align	2
	.globl	sfu_s_write
	.type	sfu_s_write, @function
sfu_s_write:
	lea (-24,%sp),%sp
	movem.l #252,(%sp)
	move.l 28(%sp),%d4
	move.l 32(%sp),%d3
	move.l 36(%sp),%d2
	move.l 40(%sp),%d6
	move.l 44(%sp),%d7
	tst.l x_ok
	jne .L354
	move.l %d3,%d0
	moveq #13,%d1
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcc .L355
	add.l #13,%d0
	lsr.l #2,%d0
	jeq .L355
.L354:
	tst.l x_ok
	jne .L357
.L359:
	move.l %d7,44(%sp)
	move.l %d6,40(%sp)
	move.l %d2,36(%sp)
	move.l %d3,32(%sp)
	move.l %d4,28(%sp)
	movem.l (%sp),#252
	lea (24,%sp),%sp
	jmp 1074438046
.L357:
	move.l %d3,%d5
	moveq #13,%d0
	add.l #-14,%d5
	cmp.l %d5,%d0
	jcs .L358
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
	jra .L359
.L358:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L359
	move.l %d3,-(%sp)
	move.l %d4,-(%sp)
	jsr 1074433530
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	move.l %d0,%d5
	jsr x_half
	lea (16,%sp),%sp
	move.l %d3,%a0
	add.l #sfu_x,%a0
	move.l %d0,%d2
	tst.b 6223(%a0)
	jeq .L359
	tst.l %d5
	jlt .L359
	and.l #32512,%d2
	and.l #224,%d5
	or.l %d5,%d2
	jra .L359
.L355:
	movem.l (%sp),#252
	clr.l %d0
	addq.l #1,x_drops
	lea (24,%sp),%sp
	rts
	.size	sfu_s_write, .-sfu_s_write
	.align	2
	.globl	sfu_f_write
	.type	sfu_f_write, @function
sfu_f_write:
	lea (-32,%sp),%sp
	movem.l #3324,(%sp)
	move.l 36(%sp),%a2
	move.l 40(%sp),%d4
	move.l 44(%sp),%d2
	move.l 48(%sp),%d7
	move.l 52(%sp),%a3
	tst.l x_ok
	jne .L367
	tst.l x_ok
	jne .L375
	move.l %d4,%d0
	moveq #13,%d1
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcc .L369
	add.l #13,%d0
	lsr.l #2,%d0
	jne .L375
.L369:
	addq.l #1,x_drops
.L370:
	movem.l (%sp),#3324
	mov3q.l #1,%d0
	lea (32,%sp),%sp
	rts
.L367:
	move.l %d4,%d0
	mov3q.l #3,%d1
	subq.l #1,%d0
	cmp.l %d0,%d1
	jcs .L371
	asr.l #8,%d2
	moveq #127,%d6
	cmp.l %d2,%d6
	jge .L372
	moveq #127,%d2
.L373:
	move.l %d0,%d1
	move.l %d0,%a0
	add.l #sfu_x+6684,%a0
	mvz.b (%a0),%d0
	asr.l #1,%d1
	cmp.l %d0,%d2
	jeq .L370
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	move.b sfu_x+6688,%d1
	move.b %d2,(%a0)
	or.l %d1,%d0
	move.b %d0,sfu_x+6688
	jra .L370
.L372:
	tst.l %d2
	jge .L373
	clr.l %d2
	jra .L373
.L371:
	move.l %d4,%d3
	moveq #13,%d0
	add.l #-14,%d3
	cmp.l %d3,%d0
	jcs .L375
	lea k_cidx,%a0
	move.l %d4,-(%sp)
	mvz.b (%a0,%d3.l),%d5
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
	jge .L376
	move.l %d4,%d0
	mov3q.l #6,%d6
	add.l #-16,%d0
	rems.l %d6,%d1:%d0
	tst.l %d1
	jne .L376
	mov3q.l #7,%d0
	cmp.l %d3,%d0
	slt %d3
	move.l %d2,%d0
	asr.l #8,%d0
	lea sfu_x,%a0
	mvs.b %d3,%d3
	sub.l %d3,%a0
	move.b %d0,2088(%a0)
.L376:
	moveq #37,%d1
	cmp.l %d5,%d1
	jge .L375
	move.l 20(%a2),%a0
	move.l (%a0),%a1
	move.l %a0,-(%sp)
	move.l 40(%a1),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l %d5,%d1
	add.l #-38,%d1
	mvz.w %d1,%d1
	add.l %d5,%d5
	move.l %d0,%a1
	move.l %d2,%d0
	asr.l #8,%d0
	add.l %d1,%d1
	move.w %d2,(%a1,%d5.l)
	move.l %d5,%a1
	add.l #-2147423840,%a1
	move.w %d2,(%a1)
	move.l %d1,%a0
	add.l #1081499899,%a0
	move.b %d0,(%a0)
	move.b %d2,1(%a0)
	jra .L370
.L375:
	move.l %a3,52(%sp)
	move.l %d7,48(%sp)
	move.l %d2,44(%sp)
	move.l %d4,40(%sp)
	move.l %a2,36(%sp)
	movem.l (%sp),#3324
	lea (32,%sp),%sp
	jmp 1074438172
	.size	sfu_f_write, .-sfu_f_write
	.align	2
	.globl	sfu_s_lget
	.type	sfu_s_lget, @function
sfu_s_lget:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.l 16(%sp),%d1
	move.l 20(%sp),%d3
	move.l 24(%sp),%a0
	tst.l x_ok
	jne .L378
	move.l %d3,%d0
	moveq #13,%d2
	add.l #-14,%d0
	cmp.l %d0,%d2
	jcs .L379
.L381:
	mov3q.l #-1,%d2
.L377:
	move.l %d2,%d0
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L379:
	move.l %d3,%d0
	subq.l #1,%d0
	lsr.l #2,%d0
	jeq .L381
.L378:
	tst.l x_ok
	jne .L382
	move.l %d3,20(%sp)
	movem.l (%sp),#28
	move.l %a0,24(%sp)
	move.l %d1,16(%sp)
	lea (12,%sp),%sp
	jmp 1074436168
.L382:
	move.l %d3,%d0
	moveq #11,%d2
	add.l #-16,%d0
	cmp.l %d0,%d2
	jcs .L383
	mov3q.l #6,%d4
	rems.l %d4,%d2:%d0
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jge .L381
.L383:
	move.l %a0,-(%sp)
	move.l %d3,-(%sp)
	move.l %d1,-(%sp)
	jsr 1074436168
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jlt .L377
	move.l %d3,%d0
	moveq #13,%d1
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcs .L385
	btst #0,%d0
	jeq .L386
	lsl.l #7,%d2
.L386:
	and.l #32512,%d2
	jra .L377
.L385:
	move.l %d3,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L377
	move.l %d2,20(%sp)
	move.l %d3,16(%sp)
	movem.l (%sp),#28
	lea (12,%sp),%sp
	jra x_knob
	.size	sfu_s_lget, .-sfu_s_lget
	.align	2
	.globl	sfu_f_lget
	.type	sfu_f_lget, @function
sfu_f_lget:
	lea (-16,%sp),%sp
	movem.l #28,(%sp)
	move.l 20(%sp),%d3
	move.l 24(%sp),%d0
	move.l 28(%sp),%a0
	tst.l x_ok
	jne .L389
	tst.l x_ok
	jne .L390
	move.l %d0,%d1
	moveq #13,%d2
	add.l #-14,%d1
	cmp.l %d1,%d2
	jcs .L391
.L393:
	mov3q.l #-1,%d0
.L388:
	movem.l (%sp),#28
	lea (16,%sp),%sp
	rts
.L391:
	move.l %d0,%d1
	subq.l #1,%d1
	lsr.l #2,%d1
	jeq .L393
.L390:
	move.l %d3,20(%sp)
	movem.l (%sp),#28
	move.l %a0,28(%sp)
	move.l %d0,24(%sp)
	lea (16,%sp),%sp
	jmp 1074436538
.L389:
	move.l %d0,%d1
	mov3q.l #3,%d2
	subq.l #1,%d1
	cmp.l %d1,%d2
	jcc .L393
	add.l #-15,%d1
	moveq #11,%d4
	cmp.l %d1,%d4
	jcc .L394
.L397:
	move.l %a0,-(%sp)
	move.l %d0,-(%sp)
	move.l %d0,%d2
	add.l #-14,%d2
	move.l %d3,-(%sp)
	jsr 1074436538
	lea (12,%sp),%sp
	moveq #13,%d1
	cmp.l %d2,%d1
	jcs .L388
	tst.l %d0
	jlt .L388
	tst.b sfu_st+1026.l
	jeq .L399
	move.l %d3,-(%sp)
	move.l %d0,16(%sp)
	jsr sync
	addq.l #4,%sp
	move.l 12(%sp),%d0
.L399:
	btst #0,%d2
	jeq .L400
	lsl.l #7,%d0
.L400:
	and.l #32512,%d0
	move.l %d2,20(%sp)
	movem.l (%sp),#28
	move.l %d0,24(%sp)
	lea (16,%sp),%sp
	jra to_knob
.L394:
	mov3q.l #6,%d4
	rems.l %d4,%d2:%d1
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jlt .L397
	jra .L393
	.size	sfu_f_lget, .-sfu_f_lget
	.align	2
	.globl	sfu_s_lset
	.type	sfu_s_lset, @function
sfu_s_lset:
	lea (-24,%sp),%sp
	movem.l #252,(%sp)
	move.l 28(%sp),%d5
	move.l 32(%sp),%d2
	move.l 36(%sp),%d3
	move.l 40(%sp),%d6
	tst.l x_ok
	jne .L404
	move.l %d2,%d0
	moveq #13,%d1
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcc .L405
	add.l #13,%d0
	lsr.l #2,%d0
	jne .L404
.L405:
	addq.l #1,x_drops
.L406:
	movem.l (%sp),#252
	clr.l %d0
	lea (24,%sp),%sp
	rts
.L404:
	tst.l x_ok
	jne .L407
.L412:
	move.l %d6,40(%sp)
	move.l %d3,36(%sp)
	move.l %d2,32(%sp)
	move.l %d5,28(%sp)
	movem.l (%sp),#252
	lea (24,%sp),%sp
	jmp 1074436282
.L407:
	move.l %d2,%d4
	moveq #13,%d0
	add.l #-14,%d4
	cmp.l %d4,%d0
	jcs .L408
	moveq #15,%d1
	cmp.l %d2,%d1
	jge .L409
	move.l %d2,%d0
	mov3q.l #6,%d7
	add.l #-16,%d0
	rems.l %d7,%d1:%d0
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L406
.L409:
	move.l %d6,-(%sp)
	move.l %d2,-(%sp)
	move.l %d5,-(%sp)
	addq.l #1,sfu_st+1030
	jsr 1074436168
	lea (12,%sp),%sp
	tst.l %d0
	jge .L411
	move.l %d2,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433530
	addq.l #8,%sp
.L411:
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	move.l %d4,-(%sp)
	jsr merge
	lea (12,%sp),%sp
	move.l %d0,%d3
	jra .L412
.L408:
	move.l %d2,-(%sp)
	jsr xmode
	addq.l #4,%sp
	tst.l %d0
	jeq .L412
	move.l %d6,-(%sp)
	move.l %d2,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074436168
	lea (12,%sp),%sp
	move.l %d0,%d4
	tst.l %d0
	jge .L413
	move.l %d2,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433530
	addq.l #8,%sp
	move.l %d0,%d4
.L413:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	jsr x_half
	addq.l #8,%sp
	move.l %d2,%a0
	add.l #sfu_x,%a0
	move.l %d0,%d3
	tst.b 6223(%a0)
	jeq .L412
	tst.l %d4
	jlt .L412
	and.l #32512,%d3
	and.l #224,%d4
	or.l %d4,%d3
	jra .L412
	.size	sfu_s_lset, .-sfu_s_lset
	.align	2
	.globl	sfu_f_lset
	.type	sfu_f_lset, @function
sfu_f_lset:
	lea (-24,%sp),%sp
	movem.l #252,(%sp)
	move.l 28(%sp),%d5
	move.l 32(%sp),%d2
	move.l 36(%sp),%d4
	move.l 40(%sp),%d6
	tst.l x_ok
	jne .L420
	tst.l x_ok
	jne .L425
	move.l %d2,%d0
	moveq #13,%d1
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcc .L422
	add.l #13,%d0
	lsr.l #2,%d0
	jne .L425
.L422:
	addq.l #1,x_drops
.L423:
	movem.l (%sp),#252
	clr.l %d0
	lea (24,%sp),%sp
	rts
.L420:
	move.l %d2,%d0
	subq.l #1,%d0
	lsr.l #2,%d0
	jeq .L423
	move.l %d2,%d7
	moveq #13,%d3
	add.l #-14,%d7
	cmp.l %d7,%d3
	jcs .L425
	moveq #15,%d0
	cmp.l %d2,%d0
	jge .L426
	move.l %d2,%d0
	mov3q.l #6,%d3
	add.l #-16,%d0
	rems.l %d3,%d1:%d0
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L423
.L426:
	move.l %d6,-(%sp)
	move.l %d2,-(%sp)
	move.l %d5,-(%sp)
	addq.l #1,sfu_st+1030
	jsr 1074436538
	lea (12,%sp),%sp
	move.l %d0,%d3
	tst.l %d0
	jge .L427
	move.l %d2,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074433680
	addq.l #8,%sp
	move.l %d0,%d3
.L427:
	clr.l -(%sp)
	move.l %d4,-(%sp)
	move.l %d7,-(%sp)
	jsr to_half
	move.l %d0,-(%sp)
	move.l %d3,-(%sp)
	move.l %d7,-(%sp)
	jsr merge
	lea (24,%sp),%sp
	move.l %d0,%d4
.L425:
	move.l %d6,40(%sp)
	move.l %d4,36(%sp)
	move.l %d2,32(%sp)
	move.l %d5,28(%sp)
	movem.l (%sp),#252
	lea (24,%sp),%sp
	jmp 1074436652
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
	jge .L429
.L430:
	move.l %d2,24(%sp)
	move.l %a2,20(%sp)
	move.l 40(%a3),%a1
	movem.l (%sp),#3084
	lea (16,%sp),%sp
	jmp (%a1)
.L429:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l %d0,-(%sp)
	move.l 60(%a3),%a0
	jsr (%a0)
	lea (12,%sp),%sp
	tst.l %d0
	jlt .L430
	movem.l (%sp),#3084
	lea (16,%sp),%sp
	rts
	.size	sfu_get, .-sfu_get
	.align	2
	.globl	sfu_tick
	.type	sfu_tick, @function
sfu_tick:
	link.w %fp,#-88
	move.l -66650100,%d1
	movem.l #15612,(%sp)
	move.l 8(%fp),%a2
	move.l %d1,-44(%fp)
	tst.l sfu_st+1034
	jne .L432
	move.l x_ok,%d1
	or.l x_bad,%d1
	jne .L432
#APP
| 227 "sfu.c" 1
	move.l #RAM_SFU_X_SIZE,%d0
| 0 "" 2
| 229 "sfu.c" 1
	.if RAM_SFU_X_SIZE < 6722
.error "registry ddr claim sfu_x is too small"
.endif

| 0 "" 2
#NO_APP
	move.l %d0,%d2
	lsr.l #2,%d2
	lea RAM_SFU_X,%a0
.L433:
	cmp.l %d2,%d1
	jne .L434
	move.l #RAM_SFU_X,%d2
	add.l #RAM_SFU_X-8,%d0
	eor.l #1380011347,%d2
	move.l #RAM_SFU_X+4,%d3
	eor.l #1380011347,%d3
	move.l #1380011347,%d4
	eor.l %d0,%d4
	move.l %d0,%a0
	move.l %d0,%a1
	move.l %d2,RAM_SFU_X
	move.l %d3,RAM_SFU_X+4
	move.l %d4,(%a0)+
	move.l %a0,%d5
	eor.l #1380011347,%d5
	move.l %d5,4(%a1)
	mov3q.l #1,x_ok
.L431:
	movem.l -88(%fp),#15612
	unlk %fp
	rts
.L434:
	clr.l (%a0)+
	addq.l #1,%d1
	jra .L433
.L432:
	tst.l x_ok
	jeq .L436
	lea RAM_SFU_X,%a0
	move.l %a0,%d1
	eor.l #1380011347,%d1
#APP
| 218 "sfu.c" 1
	move.l #RAM_SFU_X_SIZE,%d0
| 0 "" 2
#NO_APP
	cmp.l (%a0),%d1
	jne .L437
	move.l #RAM_SFU_X+4,%d1
	eor.l #1380011347,%d1
	cmp.l RAM_SFU_X+4.l,%d1
	jne .L483
	move.l %d0,%a0
	add.l #RAM_SFU_X-8,%a0
	move.l %a0,%d0
	eor.l #1380011347,%d0
	cmp.l (%a0),%d0
	jne .L437
	move.l 4(%a0),%d1
	addq.l #4,%a0
	move.l %a0,%d0
	eor.l #1380011347,%d0
	cmp.l %d1,%d0
	jeq .L436
.L437:
	moveq #1,%d1
	moveq #8,%d0
	clr.l x_ok
	move.l %d0,x_bad
	move.l %a0,x_bad_at
	move.l (%a0),x_bad_word
	mov3q.l #1,x_rep_owed
	move.b %d1,32(%a2)
.L438:
	mov3q.l #1,%d2
	cmp.l 1094562388.l,%d2
	jne .L439
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jeq .L439
	move.w #21761,%d4
	moveq #28,%d2
	move.l x_bad_at,%d0
	move.l %d0,%d1
	lsr.l %d2,%d1
	move.l #-260222380,%d3
	move.l %d3,-37(%fp)
	moveq #21,%d3
	clr.b %d5
	move.b %d1,-29(%fp)
	move.l %d0,%d1
	lsr.l %d3,%d1
	lea x_bad+3,%a0
	move.w %d4,-33(%fp)
	moveq #127,%d4
	and.l %d4,%d1
	move.b (%a0),-30(%fp)
	move.w #4027,%a0
	move.b %d5,-31(%fp)
	moveq #14,%d5
	move.b %d1,-28(%fp)
	move.l %d0,%d1
	lsr.l %d5,%d1
	and.l %d4,%d1
	move.b %d1,-27(%fp)
	move.l %d0,%d1
	lsr.l #7,%d1
	and.l %d4,%d0
	and.l %d4,%d1
	move.b %d0,-25(%fp)
	move.l x_bad_word,%d0
	move.b %d1,-26(%fp)
	move.l %d0,%d1
	lsr.l %d2,%d1
	move.b %d1,-24(%fp)
	move.l %d0,%d1
	lsr.l %d3,%d1
	and.l %d4,%d1
	move.b %d1,-23(%fp)
	move.l %d0,%d1
	lsr.l %d5,%d1
	and.l %d4,%d1
	move.b %d1,-22(%fp)
	move.l %d0,%d1
	lsr.l #7,%d1
	and.l %d4,%d0
	and.l %d4,%d1
	move.b %d0,-20(%fp)
	move.b %d1,-21(%fp)
	cmp.l 1094562392.l,%a0
	jlt .L440
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L441:
	tst.l %a0
	jeq .L440
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L441
	lea (-19,%fp),%a0
.L442:
	lea -37(%fp,%d0.l),%a1
	addq.l #1,%d0
	moveq #18,%d1
	move.b (%a1),-1(%a0,%d0.l)
	cmp.l %d0,%d1
	jne .L442
	moveq #-9,%d2
	move.l %a0,-(%sp)
	pea 19.w
	move.b %d2,-1(%fp)
	jsr 1073752544
	clr.l x_rep_owed
	addq.l #1,x_rep_sent
	addq.l #8,%sp
.L440:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #4,%sp
	jra .L439
.L483:
	lea RAM_SFU_X+4,%a0
	jra .L437
.L436:
	tst.l x_rep_owed
	jne .L438
.L439:
	move.l sfu_st+1034,%d1
	addq.l #1,%d1
	move.b sfu_st+1026,%d0
	tst.l x_ok
	jne .L443
	move.l %d1,sfu_st+1034
	tst.b %d0
	jeq .L431
	move.l #1481856080,%d3
	cmp.l 1073848892.l,%d3
	jne .L431
	tst.l 1073848900
	jeq .L431
	move.l 1073848900,%a0
	move.l %a2,-(%sp)
	jsr (%a0)
	addq.l #4,%sp
	tst.l %d0
	jeq .L431
	moveq #1,%d4
	move.b %d4,32(%a2)
	jra .L431
.L443:
	move.l %d1,sfu_st+1034
	tst.b %d0
	jne .L444
	tst.l 1100664624
	jeq .L445
	tst.l 1100635224
	jeq .L445
	lea copy_desc,%a5
	clr.l %d2
	move.l #1075575792,%d6
	lea k_cidx,%a4
	move.l %a5,%a3
.L455:
	move.l %d2,%d7
	mov3q.l #1,%d5
	add.l #14,%d7
	cmp.l %d2,%d5
	jge .L484
	move.l %d2,%d0
	moveq #10,%d1
	addq.l #3,%d0
	cmp.l %d0,%d1
	jcs .L485
	clr.l %d0
	moveq #57,%d1
.L446:
	move.l %d6,%a0
	move.l %d1,(%a0)
	mvz.b (%a4,%d2.l),%d1
	move.w #32512,%a1
	clr.l 8(%a0)
	mov3q.l #1,20(%a0)
	move.l %d1,4(%a0)
	move.l %a1,12(%a0)
	clr.l 16(%a0)
	mov3q.l #-1,24(%a0)
	mov3q.l #-1,28(%a0)
	clr.l 36(%a0)
	mov3q.l #-1,%d1
	cmp.l %d0,%d1
	jne .L447
	tst.l %d2
	jeq .L448
	move.l #l_sfx2,%d3
	move.l %d3,40(%a0)
	move.l #s_sfx2,%d0
.L450:
	move.l %d6,%a0
	move.l %d0,48(%a0)
	lea s_empty,%a1
	mov3q.l #1,%d0
	move.l %a1,44(%a0)
	cmp.l %d2,%d0
	jlt .L487
	moveq #60,%d0
.L454:
	move.l %d0,-(%sp)
	move.l %d7,-(%sp)
	jsr (%a5)
	addq.l #1,%d2
	add.l #52,%d6
	addq.l #8,%sp
	moveq #14,%d1
	cmp.l %d2,%d1
	jne .L455
	move.l #1075575116,%a0
	clr.l %d2
	move.l %a0,-48(%fp)
.L460:
	move.l %d2,%d0
	mov3q.l #1,%d1
	addq.l #1,%d2
	cmp.l %d0,%d1
	jcs .L488
	move.w #57,%a0
	moveq #29,%d1
.L456:
	mov3q.l #1,%d3
	and.l %d0,%d3
	move.l -48(%fp),%a1
	move.l %d1,4(%a1)
	mvz.w #32512,%d1
	move.l %a0,(%a1)
	clr.l 8(%a1)
	move.l %d1,12(%a1)
	move.l %d3,%a0
	btst #0,%d0
	jne .L457
	clr.l %d1
.L457:
	move.l -48(%fp),%a1
	lsr.l #1,%d0
	move.l %d1,16(%a1)
	clr.l 20(%a1)
	mov3q.l #-1,24(%a1)
	mov3q.l #-1,28(%a1)
	clr.l 36(%a1)
	tst.l %d0
	jne .L490
	move.l #l_fx1,%d0
.L458:
	move.l -48(%fp),%a1
	move.l %d0,40(%a1)
	move.l #s_empty,%d0
	move.l %d0,44(%a1)
	tst.l %a0
	jeq .L491
	move.l #s_wid,%d0
.L459:
	move.l -48(%fp),%a0
	move.l %d0,48(%a0)
	pea 410.w
	move.l %d2,-(%sp)
	jsr (%a3)
	addq.l #8,%sp
	moveq #52,%d0
	mov3q.l #4,%d1
	add.l %d0,-48(%fp)
	cmp.l %d2,%d1
	jne .L460
	tst.l sfu_x+6694
	jne .L461
	moveq #127,%d2
	move.b %d2,sfu_x+6687
	move.b %d2,sfu_x+6685
.L461:
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
.L463:
	tst.b (%a0)
	jeq .L462
	move.l %d0,%a1
	add.l #sfu_x,%a1
	move.b %d2,2188(%a1)
	move.w #1,%a1
	addq.l #1,%d0
.L462:
	addq.l #1,%d2
	addq.l #8,%a0
	cmp.l #128,%d2
	jne .L463
	move.w %a1,%d2
	tst.b %d2
	jeq .L464
	move.l %d0,sfu_x+2316
	move.l %d0,%d1
.L464:
	lea sfu_x+2188,%a0
	clr.l %d0
.L465:
	cmp.l %d0,%d1
	jgt .L466
	move.l %d1,sfu_x+2452
	clr.l %d0
	lea sfu_x+2564,%a0
.L467:
	clr.b %d3
	moveq #14,%d4
	move.b %d3,(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d4
	jne .L467
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
.L444:
	move.l sfu_x+2320,%d0
	mov3q.l #1,%d1
	and.l %d0,%d1
	btst #0,%d0
	jne .L468
	cmp.l sfu_x+2456.l,%d0
	jeq .L468
	move.l sfu_x+2316,%a0
	lea sfu_x+2188,%a1
.L469:
	cmp.l %a0,%d1
	jeq .L470
	cmp.l #128,%d1
	jne .L471
.L470:
	cmp.l sfu_x+2320.l,%d0
	jne .L468
	tst.l %a0
	jeq .L468
	moveq #1,%d1
	move.l %a0,sfu_x+2452
	move.l %d0,sfu_x+2456
	move.b %d1,32(%a2)
.L468:
	move.l sfu_x+2132,%d0
	tst.l %d0
	jeq .L472
	move.l %d0,-(%sp)
	move.l sfu_x+2160,%d2
	jsr sync
	addq.l #4,%sp
	cmp.l sfu_x+2160.l,%d2
	jeq .L473
	moveq #1,%d2
	move.b %d2,32(%a2)
.L473:
	tst.b sfu_x+6689.l
	jeq .L474
	clr.b %d1
	moveq #1,%d2
	move.b %d1,sfu_x+6689
	move.b %d2,32(%a2)
.L474:
	move.l sfu_x+6698,%d0
	tst.l %d0
	jeq .L475
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jls .L475
	clr.l sfu_x+6698
.L475:
	move.l sfu_x+6702,%d0
	tst.l %d0
	jeq .L476
	move.l -66650100,%d1
	sub.l %d0,%d1
	cmp.l #65999999,%d1
	jls .L476
	clr.l sfu_x+6702
.L476:
	lea sfu_x,%a4
	clr.l %d2
	lea sfu_x+6684,%a3
.L480:
	mvz.b sfu_x+6688,%d0
	btst %d2,%d0
	jeq .L477
	move.w #8706,%d4
	moveq #-9,%d5
	move.b (%a3),-12(%fp)
	move.b 1(%a3),-11(%fp)
	pea 10.w
	move.l #-260222380,%d3
	pea -19(%fp)
	move.b %d2,-13(%fp)
	move.l %d3,-19(%fp)
	move.w %d4,-15(%fp)
	move.b %d5,-10(%fp)
	jsr try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L479
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	move.b sfu_x+6688,%d1
	not.l %d0
	and.l %d1,%d0
	move.b %d0,sfu_x+6688
	mov3q.l #1,%d0
	or.l -66650100,%d0
	move.l %d0,6698(%a4)
	addq.l #1,sfu_x+6690
.L477:
	addq.l #4,%a4
	addq.l #2,%a3
	subq.l #1,%d2
	tst.l %d2
	jne .L492
.L479:
	mvz.b sfu_st+1027,%d0
	lsr.l #1,%d0
	jne .L445
	move.w sfu_st+1028,%d0
	moveq #99,%d3
	mvz.w %d0,%d1
	cmp.l %d1,%d3
	jcs .L481
	addq.l #1,%d0
	move.w %d0,sfu_st+1028
	mvz.w %d0,%d0
	moveq #100,%d4
	cmp.l %d0,%d4
	jne .L445
.L481:
	mov3q.l #7,-(%sp)
	pea (m.0)
	jsr try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L445
	clr.w %d5
	addq.l #1,sfu_x+2152
	move.w %d5,sfu_st+1028
.L445:
	clr.l -(%sp)
	move.l -44(%fp),-(%sp)
	jsr timed
	addq.l #8,%sp
	tst.b sfu_st+1026.l
	jeq .L431
	move.l #1481856080,%a0
	cmp.l 1073848892.l,%a0
	jne .L431
	tst.l 1073848900
	jeq .L431
	move.l -66650100,%d2
	move.l 1073848900,%a0
	move.l %a2,-(%sp)
	jsr (%a0)
	addq.l #4,%sp
	tst.l %d0
	jeq .L482
	moveq #1,%d0
	move.b %d0,32(%a2)
.L482:
	move.l -66650100,%d0
	sub.l %d2,%d0
	add.l %d0,sfu_x+6418
	addq.l #1,sfu_x+6426
	cmp.l sfu_x+6422.l,%d0
	jls .L431
	move.l %d0,sfu_x+6422
	jra .L431
.L484:
	mov3q.l #-1,%d0
	moveq #53,%d1
	jra .L446
.L485:
	mov3q.l #1,%d0
	moveq #56,%d1
	jra .L446
.L448:
	move.l #l_sfx1,%d4
	move.l %d4,1075575832
	move.l #s_sfx1,%d0
	jra .L450
.L447:
	move.l %d2,%d1
	subq.l #2,%d1
	move.l %d1,%d5
	mov3q.l #6,%d3
	rems.l %d3,%d4:%d5
	move.l %d4,%d1
	tst.l %d0
	jeq .L486
	lea l_fx2,%a0
.L451:
	move.l %d6,%a1
	move.l %a0,40(%a1)
	tst.l %d1
	jeq .L452
	mov3q.l #1,%d3
	cmp.l %d1,%d3
	jne .L453
	move.l #s_route,%d0
	jra .L450
.L486:
	lea l_fx1,%a0
	jra .L451
.L453:
	move.l %d1,%a1
	lea -10(%a1,%d1.l*4),%a0
	mulu.w #20,%d0
	add.l %a0,%d0
	add.l #sfu_x+2092,%d0
	jra .L450
.L452:
	move.l #s_type,%d0
	jra .L450
.L487:
	mvz.w #410,%d0
	jra .L454
.L488:
	move.w #56,%a0
	clr.l %d1
	jra .L456
.L490:
	move.l #l_fx2,%d0
	jra .L458
.L491:
	move.l #s_base,%d0
	jra .L459
.L466:
	move.b (%a0)+,%d2
	addq.l #1,%d0
	move.b %d2,135(%a0)
	jra .L465
.L471:
	move.b (%a1)+,%d2
	addq.l #1,%d1
	move.b %d2,135(%a1)
	jra .L469
.L472:
	move.l sfu_x+2084,%d3
	cmp.l sfu_x+2080.l,%d3
	jeq .L473
	lea sfu_x+2080,%a0
	move.l (%a0),sfu_x+2084
	jsr relabel
	moveq #1,%d0
	move.b %d0,32(%a2)
	jra .L473
.L492:
	mov3q.l #1,%d2
	jra .L480
	.size	sfu_tick, .-sfu_tick
	.text
	.type	m.0, @object
	.size	m.0, 7
m.0:
	.base64	"8H1SVCMB9w=="
	.globl	x_drops
	.section	.bss
	.align	2
	.type	x_drops, @object
	.size	x_drops, 4
x_drops:
	.zero	4
	.globl	x_rep_sent
	.align	2
	.type	x_rep_sent, @object
	.size	x_rep_sent, 4
x_rep_sent:
	.zero	4
	.globl	x_rep_owed
	.align	2
	.type	x_rep_owed, @object
	.size	x_rep_owed, 4
x_rep_owed:
	.zero	4
	.globl	x_bad_word
	.align	2
	.type	x_bad_word, @object
	.size	x_bad_word, 4
x_bad_word:
	.zero	4
	.globl	x_bad_at
	.align	2
	.type	x_bad_at, @object
	.size	x_bad_at, 4
x_bad_at:
	.zero	4
	.globl	x_bad
	.align	2
	.type	x_bad, @object
	.size	x_bad, 4
x_bad:
	.zero	4
	.globl	x_ok
	.align	2
	.type	x_ok, @object
	.size	x_ok, 4
x_ok:
	.zero	4
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
