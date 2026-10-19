| Mod 0026 - remote UI: the Rytm as a terminal for Sidecar-drawn pages (M1).
| GENERATED from rui.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit rui.c.
#NO_APP
	.file	"rui.c"
	.text
#APP
	  .text
  .globl rui_uart_det, rui_uart_raw
  .align 2
rui_uart_det:
  move.l 8(%sp),-(%sp)
  move.l 8(%sp),-(%sp)
  jsr rui_uart
  addq.l #8,%sp
  tst.l %d0
  beq.s rui_uart_raw
  rts
  .align 2
rui_uart_raw:
  lea -12(%sp),%sp
  movem.l %d2-%d4,(%sp)
  jmp 0x400019ec

#NO_APP
	.align	2
	.type	copy32, @function
copy32:
	move.l %a2,-(%sp)
	mvz.w 18(%sp),%d1
	move.l 8(%sp),%a0
	clr.l %d0
	move.l 12(%sp),%a1
	lsl.l #2,%d1
.L2:
	cmp.l %d0,%d1
	jne .L3
	move.l (%sp)+,%a2
	rts
.L3:
	lea (%a1,%d0.l),%a2
	move.l (%a2),(%a0,%d0.l)
	addq.l #4,%d0
	jra .L2
	.size	copy32, .-copy32
	.align	2
	.type	mr_vb, @function
mr_vb:
	move.l %d2,-(%sp)
	moveq #16,%d2
	move.l 12(%sp),%d0
	move.l %d0,%d1
	add.l #-35,%d1
	cmp.l %d1,%d2
	jcc .L5
.L7:
	moveq #127,%d0
.L4:
	move.l (%sp)+,%d2
	rts
.L5:
	mvz.w %d0,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #1076429692,%a0
	move.l 1076429868,%d0
	cmp.l (%a0),%d0
	jne .L7
	lea mr_flag,%a0
	moveq #127,%d2
	move.b (%a0,%d1.l),%d0
	mvz.b %d0,%d1
	cmp.l %d1,%d2
	jeq .L4
	move.l 8(%sp),%d1
	lea mr_voice,%a0
	move.b (%a0,%d1.l),%d1
	or.l %d1,%d0
	jra .L4
	.size	mr_vb, .-mr_vb
	.align	2
	.type	splash_end, @function
splash_end:
	tst.l st+972
	jeq .L11
	moveq #1,%d0
	lea (8,%sp),%a0
	move.l (%a0),st+988
	move.l 4(%sp),%a0
	clr.l st+972
	move.b %d0,32(%a0)
.L11:
	rts
	.size	splash_end, .-splash_end
	.align	2
	.type	uart_byte, @function
uart_byte:
	move.b ps_left,%d1
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.b 15(%sp),%d0
	addq.l #1,uart_bytes
	tst.b %d1
	jne .L14
	move.b %d1,ps_pos
	mvz.b %d0,%d1
	move.b %d0,ps_hdr
	mov3q.l #1,%d3
	move.l %d1,%d2
	lsr.l #4,%d2
	cmp.l %d2,%d3
	jeq .L24
	moveq #11,%d3
	cmp.l %d2,%d3
	jeq .L16
	tst.l %d2
	jne .L25
.L28:
	mov3q.l #1,%d1
	jra .L15
.L16:
	cmp.l #179,%d1
	jhi .L17
.L18:
	mov3q.l #3,%d1
.L15:
	subq.l #1,%d1
	move.b %d1,ps_left
.L19:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L17:
	cmp.l #182,%d1
	jeq .L18
	cmp.l #180,%d1
	jeq .L26
	cmp.l #181,%d1
	jeq .L27
	cmp.l #184,%d1
	jeq .L28
.L25:
	mov3q.l #2,%d1
	jra .L15
.L24:
	moveq #10,%d1
	jra .L15
.L26:
	mov3q.l #6,%d1
	jra .L15
.L27:
	mov3q.l #5,%d1
	jra .L15
.L14:
	move.b ps_hdr,%d2
	subq.l #1,%d1
	move.b %d1,ps_left
	move.b ps_pos,%d1
	mov3q.l #4,%d3
	move.w %d2,%a0
	addq.l #1,%d1
	move.b %d1,ps_pos
	move.l %a0,%d2
	add.l #80,%d2
	mvz.b %d2,%d2
	cmp.l %d2,%d3
	jcs .L19
	mvz.b %d1,%d1
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jne .L21
	move.b %d0,ps_id
	jra .L19
.L21:
	mvz.b ps_id,%d3
	moveq #15,%d2
	move.l %d3,%a1
	cmp.l %d3,%d2
	jcs .L19
	move.w %a0,%d3
	mvz.b %d3,%d2
	cmp.l #180,%d2
	jne .L22
	move.l %d1,%a0
	subq.l #2,%a0
.L23:
	move.l %a1,%d1
	lsl.l #2,%d1
	add.l #sh,%d1
	move.b %d0,(%a0,%d1.l)
	tst.b ov_on.l
	jeq .L19
	lea ov_col,%a0
	move.b (%a0,%a1.l),%d0
	addq.l #1,uart_sub
	jra .L19
.L22:
	move.l %a0,%d1
	mov3q.l #3,%d2
	and.l %d2,%d1
	move.l %d1,%a0
	jra .L23
	.size	uart_byte, .-uart_byte
	.align	2
	.type	queue_key, @function
queue_key:
	move.l st+196,%d0
	moveq #15,%d1
	lea st,%a0
	cmp.l %d0,%d1
	jcc .L36
	addq.l #1,st+44
.L35:
	rts
.L36:
	move.l %d0,%d1
	add.l #82,%d1
	lea (7,%sp),%a1
	move.b (%a1),(%a0,%d1.l*2)
	lea (%a0,%d0.l*2),%a0
	addq.l #1,%d0
	move.l %d0,st+196
	move.b 11(%sp),165(%a0)
	jra .L35
	.size	queue_key, .-queue_key
	.align	2
	.type	enter, @function
enter:
	move.l %d2,-(%sp)
	move.b 15(%sp),%d1
	tst.l st+4
	jne .L38
	tst.l st+972
	jeq .L40
	clr.l st+972
	mov3q.l #6,st+988
.L40:
	lea commits,%a0
	moveq #16,%d0
	move.l (%a0),st+24
	mov3q.l #1,st+4
	clr.l st+12
	mov3q.l #-1,st+20
	lea st+96,%a0
	addq.l #1,st+48
.L41:
	clr.l (%a0)+
	subq.l #1,%d0
	tst.l %d0
	jne .L41
	lea st+408,%a0
.L42:
	clr.l (%a0)+
	moveq #16,%d2
	addq.l #1,%d0
	cmp.l %d0,%d2
	jne .L42
	mvz.b %d1,%d0
	lea (19,%sp),%a0
	move.b (%a0),st+993
	lea led_gen,%a0
	bset #8,%d0
	move.l (%a0),st+1002
	move.l 8(%sp),%a0
	move.b %d1,st+162
	clr.l st+196
	clr.l st+1006
	move.l %d0,st+296
	moveq #1,%d0
	move.b %d0,st+161
	move.b %d0,st+163
	move.b %d0,mr+13
	move.b %d0,mr+19
	move.b %d0,32(%a0)
.L38:
	move.l (%sp)+,%d2
	rts
	.size	enter, .-enter
	.align	2
	.type	led_restore, @function
led_restore:
	lea (-20,%sp),%sp
	movem.l #17412,(%sp)
	tst.b ov_on.l
	jeq .L45
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L47
	addq.l #1,st+1018
.L45:
	movem.l (%sp),#17412
	lea (20,%sp),%sp
	rts
.L47:
	clr.b %d0
	lea sh,%a6
	clr.l %d2
	lea rui_uart_raw,%a2
	move.b %d0,ov_on
.L48:
	moveq #-76,%d0
	move.b %d2,15(%sp)
	move.b (%a6),16(%sp)
	move.b 1(%a6),17(%sp)
	move.b 2(%a6),18(%sp)
	move.b 3(%a6),19(%sp)
	addq.l #1,%d2
	move.b %d0,14(%sp)
	pea 14(%sp)
	mov3q.l #6,-(%sp)
	jsr (%a2)
	addq.l #4,%a6
	addq.l #8,%sp
	moveq #16,%d0
	cmp.l %d2,%d0
	jne .L48
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #1,st+1014
	addq.l #4,%sp
	jra .L45
	.size	led_restore, .-led_restore
	.align	2
	.type	send, @function
send:
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jeq .L54
.L60:
	clr.l %d0
.L53:
	rts
.L54:
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L56
	addq.l #1,st+40
	jra .L53
.L56:
	mvz.w #4027,%d0
	cmp.l 1094562392.l,%d0
	jlt .L57
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L58:
	tst.l %a0
	jeq .L57
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L58
	move.l 4(%sp),-(%sp)
	move.l 12(%sp),-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	addq.l #1,st+36
	mov3q.l #1,%d0
	jra .L53
.L57:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #1,st+40
	addq.l #4,%sp
	jra .L60
	.size	send, .-send
	.align	2
	.type	send3, @function
send3:
	link.w %fp,#-12
	move.l #-260222380,%d0
	move.l %d0,-10(%fp)
	moveq #1,%d0
	pea 10.w
	pea -10(%fp)
	move.b 11(%fp),-6(%fp)
	move.b 15(%fp),-4(%fp)
	move.b 19(%fp),-3(%fp)
	move.b 23(%fp),-2(%fp)
	move.b %d0,-5(%fp)
	moveq #-9,%d0
	move.b %d0,-1(%fp)
	jsr send
	addq.l #8,%sp
	unlk %fp
	rts
	.size	send3, .-send3
	.align	2
	.type	flush, @function
flush:
	link.w %fp,#-28
	movem.l #3076,(%sp)
	tst.b st+992.l
	jeq .L68
	move.l st+8,%d0
	cmp.l #16383,%d0
	jls .L69
	mvz.w #16383,%d0
.L69:
	moveq #127,%d1
	and.l %d0,%d1
	lsr.l #7,%d0
	mov3q.l #1,-(%sp)
	mvz.b %d0,%d0
	move.l %d1,-(%sp)
	move.l %d0,-(%sp)
	pea 53.w
	jsr send3
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L67
	clr.b %d0
	addq.l #1,st+968
	move.b %d0,st+992
.L68:
	tst.b st+161.l
	jeq .L71
	move.l #-260222380,%d1
	move.l %d1,-10(%fp)
	move.w st+162,%d1
	move.w #12289,%a0
	mvz.w %d1,%d0
	lsl.l #8,%d1
	lsr.l #8,%d0
	move.w %a0,-6(%fp)
	lea st+993,%a0
	move.b (%a0),-4(%fp)
	pea 10.w
	pea -10(%fp)
	add.l %d1,%d0
	move.w %d0,-3(%fp)
	moveq #-9,%d0
	move.b %d0,-1(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L67
	clr.b %d1
	move.b %d1,st+161
.L71:
	lea st+164,%a2
	clr.l %d2
	move.l %a2,-16(%fp)
.L73:
	cmp.l st+196.l,%d2
	jcc .L77
	move.l -16(%fp),%a0
	move.b (%a0),%d0
	mvz.b 1(%a0),%d1
	move.l %d1,-(%sp)
	moveq #127,%d1
	and.l %d0,%d1
	lsr.l #7,%d0
	move.l %d1,-(%sp)
	mov3q.l #1,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	pea 49.w
	jsr send3
	lea (16,%sp),%sp
	tst.l %d0
	jne .L74
.L77:
	move.l st+196,%a0
	move.l %d2,%d0
	move.l %a0,-16(%fp)
.L75:
	cmp.l -16(%fp),%d0
	jcs .L78
	move.l -16(%fp),%d1
	sub.l %d2,%d1
	move.l %d1,-16(%fp)
	move.l %d1,st+196
	tst.l %d1
	jne .L67
	lea st+96,%a2
.L83:
	move.l (%a2)+,%d2
	tst.l %d2
	jeq .L79
	moveq #-63,%d0
	cmp.l %d2,%d0
	jle .L80
	moveq #-63,%d2
.L81:
	mvz.b st+160,%d0
	move.l -16(%fp),%d1
	move.l %d0,-(%sp)
	move.l %d2,%d0
	add.l #64,%d0
	mvz.b %d0,%d0
	mvz.b %d1,%d1
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	pea 50.w
	jsr send3
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L67
	sub.l %d2,-4(%a2)
	move.l st+64,%d1
	tst.l %d1
	jeq .L79
	move.l -66650100,%d0
	sub.l %d1,%d0
	move.l %d0,st+68
	add.l %d0,st+316
	addq.l #1,st+320
	cmp.l st+324.l,%d0
	jls .L82
	move.l %d0,st+324
.L82:
	clr.l st+64
.L79:
	moveq #16,%d0
	addq.l #1,-16(%fp)
	cmp.l -16(%fp),%d0
	jne .L83
.L67:
	movem.l -28(%fp),#3076
	unlk %fp
	rts
.L74:
	addq.l #2,-16(%fp)
	addq.l #1,%d2
	jra .L73
.L78:
	move.b (%a2,%d2.l*2),(%a2)
	lea 1(%a2,%d2.l*2),%a0
	addq.l #1,%d0
	addq.l #2,%a2
	move.b (%a0),-1(%a2)
	jra .L75
.L80:
	moveq #63,%d1
	cmp.l %d2,%d1
	jge .L81
	moveq #63,%d2
	jra .L81
	.size	flush, .-flush
	.align	2
	.type	mr_send, @function
mr_send:
	move.w #13057,%d1
	link.w %fp,#-52
	move.b 11(%fp),-27(%fp)
	movem.l #3084,(%sp)
	move.l 12(%fp),%d2
	move.l #-260222380,%d0
	move.l %d0,-33(%fp)
	move.l 8(%fp),%d3
	add.l %d2,%d3
	move.b %d2,-26(%fp)
	lea (-25,%fp),%a2
	move.w %d1,-29(%fp)
.L98:
	move.l 8(%fp),%d1
	addq.l #2,%a2
	move.l 16(%fp),%a0
	move.b (%a0,%d1.l),%d0
	moveq #127,%d1
	and.l %d0,%d1
	mvz.b %d0,%d0
	move.b %d1,-2(%a2)
	move.l %d0,-(%sp)
	move.l 8(%fp),-(%sp)
	jsr mr_vb
	addq.l #1,8(%fp)
	addq.l #8,%sp
	move.b %d0,-1(%a2)
	cmp.l 8(%fp),%d3
	jgt .L98
	moveq #-9,%d0
	move.b %d0,-25(%fp,%d2.l*2)
	add.l %d2,%d2
	move.l %d2,%a0
	pea 9(%a0)
	pea -33(%fp)
	jsr send
	movem.l -52(%fp),#3084
	addq.l #8,%sp
	unlk %fp
	rts
	.size	mr_send, .-mr_send
	.align	2
	.type	kit_tick, @function
kit_tick:
	link.w %fp,#-12
	moveq #127,%d0
	and.l -2147457096,%d0
	move.l #-260222380,%a0
	move.l %a0,-8(%fp)
	move.l %d0,-12(%fp)
	move.l #989921527,%d0
	move.l %d0,-4(%fp)
	tst.b mr+19.l
	jne .L101
	mvz.b mr+18,%d0
	cmp.l -12(%fp),%d0
	jeq .L100
.L101:
	pea 8.w
	pea -8(%fp)
	move.b -9(%fp),-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L100
	clr.b %d0
	lea (-9,%fp),%a0
	move.b (%a0),mr+18
	move.b %d0,mr+19
	move.w mr+20,%d0
	addq.l #1,%d0
	move.w %d0,mr+20
.L100:
	unlk %fp
	rts
	.size	kit_tick, .-kit_tick
	.align	2
	.globl	rui_sysex
	.type	rui_sysex, @function
rui_sysex:
	lea (-72,%sp),%sp
	move.l -66650100,%d1
	move.l 80(%sp),%d0
	movem.l #17660,(%sp)
	move.l 76(%sp),%a0
	mov3q.l #6,%d2
	move.l %d1,36(%sp)
	cmp.l %d0,%d2
	jge .L110
	mvz.b 5(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L110
	mvz.b -1(%a0,%d0.l),%d1
	cmp.l #247,%d1
	jeq .L108
.L110:
	addq.l #1,rx_bad
	jra .L109
.L108:
	move.b 4(%a0),%d2
	move.l %d0,%d1
	moveq #11,%d4
	subq.l #7,%d1
	move.l %d2,%d3
	add.l #-52,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d4
	jcs .L110
	move.w .L112(%pc,%d3.l*2),%a1
	jmp %pc@(2,%a1:l)
	.balignw 2,0x284c
	.swbeg	&12
.L112:
	.word .L121-.L112
	.word .L110-.L112
	.word .L120-.L112
	.word .L119-.L112
	.word .L118-.L112
	.word .L117-.L112
	.word .L116-.L112
	.word .L110-.L112
	.word .L115-.L112
	.word .L114-.L112
	.word .L113-.L112
	.word .L111-.L112
.L118:
	mov3q.l #4,%d5
	cmp.l %d1,%d5
	jge .L122
	move.b 7(%a0),%d6
	moveq #15,%d7
	mvz.b %d6,%d2
	cmp.l %d2,%d7
	jcs .L122
	mvz.b 8(%a0),%d3
	mov3q.l #7,%d1
	cmp.l %d3,%d1
	jcs .L122
	move.b 9(%a0),%d1
	jeq .L122
	move.b 10(%a0),%d4
	jeq .L122
	mvz.b %d1,%d5
	add.l %d5,%d2
	moveq #16,%d5
	cmp.l %d2,%d5
	jlt .L122
	mvz.b %d4,%d2
	move.l %d3,%a1
	moveq #8,%d7
	add.l %d2,%a1
	cmp.l %a1,%d7
	jlt .L122
	ext.w %d4
	ext.w %d1
	mov3q.l #7,%d7
	muls.w %d4,%d1
	move.l %d0,%d4
	add.l #-12,%d4
	lsl.l #3,%d1
	move.l %d1,%d0
	addq.l #6,%d0
	divs.l %d7,%d0
	move.l %d0,%a1
	add.l %d1,%a1
	cmp.l %d4,%a1
	jne .L122
	mvs.b %d6,%d0
	lea (11,%a0),%a2
	lsl.l #6,%d0
	move.l %d0,%a1
	add.l %d3,%a1
	add.l #staging,%a1
	clr.l %d0
.L126:
	move.l %d1,%d3
	mov3q.l #7,%d4
	cmp.l %d1,%d4
	jge .L123
	mov3q.l #7,%d3
.L123:
	move.l %a2,%a6
	sub.l %d3,%d1
	mvz.b (%a6)+,%d5
	clr.l %d4
.L125:
	move.l %d5,%d6
	lsr.l #1,%d5
	move.b 1(%a2,%d4.l),%d7
	lsl.l #7,%d6
	or.l %d7,%d6
	move.b %d6,(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d2,%d0
	jne .L124
	addq.l #8,%a1
	clr.l %d0
.L124:
	addq.l #1,%d4
	cmp.l %d3,%d4
	jne .L125
	lea (%a6,%d3.l),%a2
	tst.l %d1
	jgt .L126
	addq.l #6,%a0
	move.b (%a0),st_seq
	moveq #1,%d0
.L181:
	move.b %d0,st_valid
.L115:
	addq.l #1,rx
	jra .L109
.L122:
	clr.b %d1
	addq.l #1,rx_bad
	move.b %d1,st_valid
.L109:
	move.l -66650100,%d0
	addq.l #1,mt_calls
	sub.l 36(%sp),%d0
	add.l %d0,mt_sum
	cmp.l mt_max.l,%d0
	jls .L161
	move.l %d0,mt_max
.L161:
	movem.l (%sp),#17660
	mov3q.l #1,%d0
	lea (72,%sp),%sp
	rts
.L117:
	tst.l %d1
	jeq .L110
	tst.b st_valid.l
	jeq .L128
	mvz.b 6(%a0),%d1
	mvz.b st_seq,%d0
	cmp.l %d1,%d0
	jne .L128
	pea 256.w
	pea staging
	pea shadow
	lea copy32,%a2
	addq.l #1,sh_seq
	jsr (%a2)
	pea 704.w
	pea txt_st
	pea txt_sh
	jsr (%a2)
	lea (24,%sp),%sp
	addq.l #1,sh_seq
	addq.l #1,commits
	move.l #-66650100,%a0
	move.l (%a0),t_commit
.L128:
	clr.b %d0
	jra .L181
.L116:
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jge .L110
	tst.b 7(%a0)
	jeq .L130
	moveq #1,%d3
	move.b %d3,host_open
	jra .L115
.L130:
	moveq #1,%d4
	move.b %d4,host_close
	jra .L115
.L121:
	tst.l %d1
	jeq .L110
	move.b 6(%a0),%d0
	mov3q.l #1,%d5
	mvz.b %d0,%d2
	cmp.l %d2,%d5
	jcs .L110
	jne .L132
	moveq #17,%d6
	cmp.l %d1,%d6
	jne .L110
	move.l %a0,%d1
	add.l #23,%d1
	lea (7,%a0),%a1
.L135:
	mvz.b (%a1),%d2
	moveq #111,%d7
	cmp.l %d2,%d7
	jcs .L110
	addq.l #1,%a1
	cmp.l %d1,%a1
	jne .L135
.L132:
	addq.l #1,led_gen
	move.b %d0,led_req_mode
	clr.l %d0
	lea led_req,%a1
.L136:
	mvz.b 6(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jeq .L137
.L139:
	addq.l #1,led_gen
	jra .L115
.L137:
	moveq #16,%d3
	cmp.l %d0,%d3
	jeq .L139
	lea 7(%a0,%d0.l),%a2
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	jra .L136
.L120:
	tst.l %d1
	jeq .L110
	move.b 6(%a0),%d0
	moveq #127,%d4
	and.l %d4,%d0
	bset #8,%d0
	move.l %d0,splash_req
	jra .L115
.L119:
	move.l %d0,%d4
	moveq #37,%d5
	add.l #-10,%d4
	cmp.l %d4,%d5
	jcs .L110
	clr.l 48(%sp)
	moveq #127,%d6
	clr.l 52(%sp)
	moveq #14,%d7
	clr.l 56(%sp)
	clr.l 60(%sp)
	clr.l 64(%sp)
	clr.l 68(%sp)
	clr.l 44(%sp)
	clr.l 40(%sp)
	mov3q.l #1,%a6
	move.b 8(%a0),%d1
	move.b 7(%a0),%d2
	move.b 6(%a0),%d0
	and.l %d6,%d1
	and.l %d6,%d2
	and.l %d6,%d0
	lsl.l %d7,%d1
	lsl.l #7,%d2
	or.l %d2,%d1
	clr.l %d2
	or.l %d0,%d1
.L142:
	cmp.l %d2,%d4
	jgt .L145
	mvz.w %d1,%d1
	lea (40,%sp),%a0
	clr.l %d0
	lea mask_keys,%a1
	move.l %d1,mask_enc
.L146:
	move.l (%a0)+,(%a1,%d0.l*4)
	moveq #8,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L146
	mov3q.l #1,mask_set
	addq.l #1,masks
	jra .L115
.L145:
	move.w %d2,%d0
	mvz.b 9(%a0,%d2.l),%d6
	clr.l %d3
	mulu.w #7,%d0
.L144:
	btst %d3,%d6
	jeq .L143
	cmp.l #255,%d0
	jgt .L143
	moveq #31,%d5
	and.l %d0,%d5
	move.l %a6,%d7
	lsl.l %d5,%d7
	move.l %d0,%d5
	asr.l #5,%d5
	or.l %d7,40(%sp,%d5.l*4)
.L143:
	addq.l #1,%d3
	addq.l #1,%d0
	mov3q.l #7,%d7
	cmp.l %d3,%d7
	jne .L144
	addq.l #1,%d2
	jra .L142
.L114:
	mov3q.l #5,%d2
	cmp.l %d1,%d2
	jge .L147
	move.b 7(%a0),%d1
	moveq #63,%d3
	mvz.b %d1,%d5
	cmp.l %d5,%d3
	jcs .L147
	move.b 8(%a0),%d4
	jmi .L147
	mvz.b 9(%a0),%d2
	cmp.l %d2,%d3
	jcs .L147
	mvz.b 10(%a0),%d2
	moveq #16,%d6
	cmp.l %d2,%d6
	jcs .L147
	move.l %d0,%d2
	moveq #32,%d7
	add.l #-13,%d2
	cmp.l %d2,%d7
	jge .L162
.L147:
	clr.b %d0
	addq.l #1,rx_bad
	move.b %d0,st_valid
	jra .L109
.L150:
	move.b 12(%a0,%d3.l),%d0
	moveq #94,%d6
	add.l #-32,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d6
	jcc .L149
	clr.b %d7
	addq.l #1,rx_bad
	move.b %d7,st_valid
	jra .L109
.L149:
	addq.l #1,%d3
.L148:
	cmp.l %d2,%d3
	jlt .L150
	moveq #44,%d0
	ext.w %d1
	muls.l %d5,%d0
	lea txt_st,%a6
	mulu.w #44,%d1
	move.b %d4,(%a6,%d0.l)
	lea (%a6,%d0.l),%a1
	move.b 9(%a0),1(%a1)
	move.b 10(%a0),2(%a1)
	move.b 11(%a0),3(%a1)
	move.b %d2,4(%a1)
	lea (%a6,%d1.l),%a1
	clr.l %d1
.L151:
	cmp.l %d2,%d1
	jlt .L152
	add.l %d0,%a6
	clr.b %d0
	moveq #1,%d1
	addq.l #6,%a0
	move.b %d0,8(%a6,%d2.l)
	move.b %d1,st_valid
	move.b (%a0),st_seq
	jra .L115
.L162:
	clr.l %d3
	jra .L148
.L152:
	lea 12(%a0,%d1.l),%a2
	move.b (%a2),8(%a1,%d1.l)
	addq.l #1,%d1
	jra .L151
.L113:
	tst.l %d1
	jeq .L110
	lea txt_st+4,%a1
	moveq #64,%d0
.L154:
	clr.b (%a1)
	subq.l #1,%d0
	lea (44,%a1),%a1
	tst.l %d0
	jne .L154
	moveq #1,%d2
	addq.l #6,%a0
	move.b (%a0),st_seq
	move.b %d2,st_valid
	jra .L115
.L111:
	mov3q.l #5,%d3
	cmp.l %d1,%d3
	jge .L110
	move.b 6(%a0),%d1
	moveq #15,%d4
	mvz.b %d1,%d5
	cmp.l %d5,%d4
	jcs .L110
	add.l #-13,%d0
	moveq #11,%d6
	cmp.l %d0,%d6
	jlt .L110
	lea bind_gen,%a2
	addq.l #1,(%a2,%d5.l*4)
	move.b 7(%a0),%d3
	mvz.b %d3,%d4
	lsr.l #6,%d4
	jeq .L157
	st %d3
.L157:
	moveq #20,%d4
	ext.w %d1
	muls.l %d5,%d4
	lea bind_in,%a1
	mulu.w #20,%d1
	move.l %d4,%a6
	move.b %d3,(%a6,%a1.l)
	add.l %d4,%a1
	move.b 8(%a0),1(%a1)
	move.b 9(%a0),2(%a1)
	move.b 10(%a0),3(%a1)
	move.b 11(%a0),4(%a1)
	move.b %d0,5(%a1)
	move.l %d1,%a1
	clr.l %d1
	add.l #bind_in,%a1
.L158:
	cmp.l %d0,%d1
	jlt .L160
	mvz.b 6(%a0),%d0
	addq.l #1,(%a2,%d0.l*4)
	jra .L115
.L160:
	move.b 12(%a0,%d1.l),%d3
	moveq #94,%d5
	move.l %d3,%d4
	add.l #-32,%d4
	mvz.b %d4,%d4
	cmp.l %d4,%d5
	jcc .L159
	move.b %d2,%d3
.L159:
	move.b %d3,6(%a1,%d1.l)
	addq.l #1,%d1
	jra .L158
	.size	rui_sysex, .-rui_sysex
	.align	2
	.type	leave, @function
leave:
	move.b 11(%sp),%d0
	tst.l st+4
	jeq .L183
	mvs.b %d0,%d1
	lea commits,%a0
	move.b %d0,st+162
	move.l (%a0),sv+12
	move.l %d1,st+296
	moveq #1,%d1
	clr.l st+4
	clr.l st+196
	clr.l st+1006
	addq.l #1,st+52
	move.b %d1,st+161
	clr.b %d1
	move.b %d1,st+163
	move.b %d1,st+993
	jsr led_restore
	moveq #1,%d0
	move.l 4(%sp),%a0
	move.b %d0,32(%a0)
.L183:
	rts
	.size	leave, .-leave
	.align	2
	.globl	rui_uart
	.type	rui_uart, @function
rui_uart:
	lea (-40,%sp),%sp
	movem.l #19468,(%sp)
	tst.b ov_on.l
	jeq .L193
	move.l 44(%sp),%a0
	subq.l #1,%a0
	clr.l %d3
	sub.l %a6,%a6
	lea rui_uart_raw,%a3
	move.l %a0,20(%sp)
.L187:
	cmp.l 44(%sp),%a6
	jlt .L192
	mov3q.l #1,%d0
	jra .L185
.L188:
	move.l 48(%sp),%a0
	mvz.b (%a0,%d2.l),%d0
	addq.l #1,%d2
	move.l %d0,-(%sp)
	jsr uart_byte
	addq.l #4,%sp
.L186:
	cmp.l 44(%sp),%d2
	jlt .L188
	clr.l %d0
.L185:
	movem.l (%sp),#19468
	lea (40,%sp),%sp
	rts
.L193:
	clr.l %d2
	jra .L186
.L192:
	move.l 48(%sp),%a0
	move.l %d3,%d2
	addq.l #1,%d2
	mvz.b (%a0,%a6.l),%d0
	move.l %d0,-(%sp)
	jsr uart_byte
	move.b %d0,28(%sp,%d3.l)
	addq.l #4,%sp
	moveq #16,%d0
	cmp.l %d2,%d0
	jeq .L190
	cmp.l 20(%sp),%a6
	jne .L191
.L190:
	pea 24(%sp)
	move.l %d2,-(%sp)
	jsr (%a3)
	addq.l #8,%sp
	clr.l %d2
.L191:
	addq.l #1,%a6
	move.l %d2,%d3
	jra .L187
	.size	rui_uart, .-rui_uart
	.align	2
	.globl	rui_tick
	.type	rui_tick, @function
rui_tick:
	lea (-140,%sp),%sp
	move.l -66650100,%d1
	move.l #-66650100,%a0
	movem.l #31996,(%sp)
	move.l rx,%d2
	addq.l #1,st+8
	move.l 144(%sp),%a2
	move.l %d1,56(%sp)
	move.l (%a0),st+300
	tst.l st
	jne .L198
	lea rui_sysex,%a1
	move.l %a1,1075551840
	move.l #1381321040,%a3
	move.l %a3,1075551836
	mov3q.l #1,st
	move.l %d2,st+16
.L199:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 56(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L197
	move.l %d0,st+332
.L197:
	movem.l (%sp),#31996
	lea (140,%sp),%sp
	rts
.L198:
	tst.b host_close.l
	jeq .L200
	clr.b %d0
	lea commits,%a0
	move.b %d0,host_close
	move.b %d0,host_open
	move.l (%a0),sv+12
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	addq.l #8,%sp
.L200:
	tst.b host_open.l
	jeq .L201
	clr.b %d0
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	move.b %d0,host_open
	jsr enter
	lea (12,%sp),%sp
.L201:
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L202
	move.l st+956,%d0
	cmp.l #65534,%d0
	jhi .L203
	addq.l #1,%d0
	move.l %d0,st+956
	moveq #10,%d3
	cmp.l %d0,%d3
	jne .L203
	moveq #1,%d4
	move.l %d2,st+964
	mov3q.l #1,st+960
	move.b %d4,st+992
	move.b %d4,mr+13
	move.b %d4,mr+19
.L204:
	tst.b sv.l
	jeq .L209
	moveq #1,%d1
	move.w #257,%a1
	lea sv+1,%a0
	move.b (%a0),sv+5
	move.b %d1,sv+4
	move.w %a1,sv+6
	jra .L209
.L203:
	move.l st+960,%d3
	move.l %d3,%d1
	subq.l #1,%d1
	lsr.l #1,%d1
	jne .L205
	moveq #20,%d1
	moveq #20,%d6
	muls.l %d3,%d1
	cmp.l %d1,%d6
	seq %d1
	neg.l %d1
	tst.b %d1
	jeq .L206
	moveq #30,%d1
.L207:
	cmp.l %d1,%d0
	jne .L205
	cmp.l st+964.l,%d2
	jne .L208
	moveq #1,%d0
	addq.l #1,%d3
	move.l %d3,st+960
	move.b %d0,st+992
	move.b %d0,mr+13
	move.b %d0,mr+19
	jra .L204
.L206:
	moveq #50,%d1
	jra .L207
.L208:
	mov3q.l #3,st+960
.L205:
	tst.b st+992.l
	jne .L204
.L209:
	tst.l splash_req
	jeq .L210
	move.l splash_req,%d0
	clr.l splash_req
	tst.l st+4
	jne .L211
	moveq #127,%d1
	and.l %d1,%d0
	tst.l %d0
	jeq .L212
	tst.l commits
	jne .L213
.L211:
	addq.l #1,st+984
.L210:
	tst.l st+4
	jeq .L215
	cmp.l st+16.l,%d2
	jeq .L216
	clr.l st+12
.L217:
	move.l %d2,st+16
	clr.b %d0
	move.l st+8,%d5
	sub.l %a6,%a6
	lea st+408,%a0
	move.l %d5,48(%sp)
.L223:
	move.l (%a0)+,%d1
	tst.l %d1
	jeq .L221
	move.l 48(%sp),%a1
	sub.l %d1,%a1
	tst.l %a1
	jlt .L221
	moveq #1,%d0
	clr.l -4(%a0)
.L221:
	addq.l #1,%a6
	moveq #16,%d6
	cmp.l %a6,%d6
	jne .L223
	tst.b %d0
	jeq .L224
	mov3q.l #1,st+344
.L224:
	clr.b %d3
	move.l 28(%a2),%a0
	clr.l %d6
	move.b 1093765506,%d4
	lea (20,%a2),%a3
	sub.l %a5,%a5
	clr.l sv+80
	clr.l 52(%sp)
	clr.l %d1
	clr.l %d7
	sub.l %a1,%a1
	clr.l %d0
	move.l %a3,60(%sp)
.L225:
	tst.l %a0
	jne .L233
	tst.b %d3
	jeq .L232
	move.l 44(%sp),%d3
	move.l %d3,sv+80
	jra .L232
.L202:
	clr.b %d0
	clr.l st+956
	clr.l st+960
	move.b %d0,st+992
	jra .L209
.L212:
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr splash_end
	addq.l #8,%sp
	jra .L210
.L213:
	tst.l st+972
	jne .L214
	mov3q.l #1,st+972
	addq.l #1,st+980
	mov3q.l #-1,st+20
	clr.l st+12
	mov3q.l #1,st+344
.L214:
	move.l %d0,st+976
.L215:
	tst.l st+972
	jeq .L217
	cmp.l st+16.l,%d2
	jeq .L218
	clr.l st+12
.L219:
	move.l st+976,%d0
	subq.l #1,%d0
	move.l %d0,st+976
	tst.l %d0
	jne .L217
	mov3q.l #1,-(%sp)
	jra .L416
.L216:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d3
	cmp.l %d0,%d3
	jcc .L217
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	clr.l mask_set
.L415:
	addq.l #8,%sp
	jra .L217
.L218:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d4
	cmp.l %d0,%d4
	jcc .L219
	mov3q.l #3,-(%sp)
.L416:
	move.l %a2,-(%sp)
	jsr splash_end
	jra .L415
.L235:
	move.l 8(%a0),%a3
	tst.l %a3
	jeq .L226
	move.l (%a3),%d1
	move.l %a3,%d7
	cmp.l #1075721468,%d1
	jeq .L315
	cmp.l #1075628548,%d1
	jne .L227
	tst.b 132(%a3)
	sne %d5
	mvs.b %d5,%d5
	neg.l %d5
	or.l %d5,%d6
.L227:
	tst.l %d0
	jeq .L228
	lea sv_covers,%a3
	sub.l %a4,%a4
.L229:
	cmp.l (%a3),%d1
	jne .L230
	move.l %d0,%d6
.L228:
	cmp.l #1076055292,%d1
	seq %d5
	move.l (%a0),%a0
	addq.l #1,%a1
	mvs.b %d5,%d5
	neg.l %d5
	or.l %d5,%d0
	moveq #16,%d5
	cmp.l %a1,%d5
	jne .L225
	tst.b %d3
	jeq .L232
	move.l 44(%sp),%a3
	move.l %a3,sv+80
.L232:
	cmp.l sv+84.l,%d7
	jne .L236
	cmp.l sv+88.l,%d1
	jeq .L237
.L236:
	move.l %d7,sv+84
	move.l %d1,sv+88
	clr.l sv+96
.L238:
	move.l %a1,sv+92
	tst.l %a5
	jeq .L239
	moveq #16,%d3
	cmp.l %a1,%d3
	jeq .L239
	tst.l %a0
	jne .L240
.L239:
	clr.l sv+80
.L246:
	clr.l %d3
.L241:
	tst.b sv.l
	jeq .L248
	clr.b %d0
	lea sv+1,%a0
	moveq #1,%d1
	move.b (%a0),sv+5
	addq.l #1,sv+60
	move.b %d0,sv
	move.b %d0,sv+6
	move.b %d1,sv+4
	jra .L248
.L315:
	moveq #1,%d3
	move.l %a3,44(%sp)
	mov3q.l #1,%a5
	jra .L227
.L230:
	addq.l #4,%a3
	addq.l #1,%a4
	moveq #8,%d5
	cmp.l %a4,%d5
	jne .L229
	move.l %d0,52(%sp)
	jra .L228
.L233:
	cmp.l 60(%sp),%a0
	jne .L235
	tst.b %d3
	jeq .L232
	move.l 44(%sp),%d5
	move.l %d5,sv+80
	jra .L232
.L237:
	move.l sv+96,%d3
	cmp.l #65534,%d3
	jhi .L238
	addq.l #1,%d3
	move.l %d3,sv+96
	jra .L238
.L240:
	mvz.b %d4,%d5
	tst.l 52(%sp)
	jeq .L242
	cmp.l #1076055292,%d1
	jeq .L242
	moveq #59,%d1
	cmp.l sv+96.l,%d1
	jcc .L317
.L242:
	mov3q.l #1,%d3
	eor.l %d3,%d0
	or.l %d6,%d0
	move.l %d0,%d3
	addq.l #1,%d3
.L243:
	moveq #11,%d1
	cmp.l %d5,%d1
	jlt .L246
	move.b %d4,%d1
	moveq #127,%d0
	and.l -2147457096,%d0
	move.b sv,%d6
	ext.w %d1
	mulu.w #2531,%d0
	mulu.w #152,%d1
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	move.b (%a0),%d7
	mvz.b %d7,%d0
	move.l %d0,-(%sp)
	move.l %d5,-(%sp)
	move.l %d0,%a3
	jsr mr_vb
	addq.l #8,%sp
	moveq #127,%d1
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jeq .L241
	tst.b %d6
	jeq .L244
	mvz.b sv+1,%d0
	cmp.l %d5,%d0
	jne .L244
	mvz.b sv+2,%d0
	cmp.l %a3,%d0
	jeq .L248
.L244:
	moveq #1,%d5
	move.w #257,%a1
	move.b %d4,sv+1
	move.b %d7,sv+2
	move.b %d4,sv+5
	lea commits,%a0
	move.l (%a0),sv+12
	addq.l #1,sv+56
	move.b %d5,sv
	move.b %d5,sv+4
	move.w %a1,sv+6
.L248:
	mov3q.l #2,%d0
	cmp.l %d3,%d0
	seq %d7
	neg.l %d7
	move.b %d7,sv+3
	cmp.l sv+20.l,%d2
	jeq .L250
	clr.l sv+16
	clr.l %d0
.L251:
	move.b sv,%d1
	move.l %d2,sv+20
	move.l st+4,%d4
	move.l st+972,%d6
	move.w %d1,%a0
	move.l sv+12,%d1
	move.w %a0,%d2
	tst.b %d2
	jeq .L252
	mov3q.l #2,%d5
	cmp.l %d3,%d5
	jne .L253
.L252:
	clr.l %d2
.L254:
	cmp.l commits.l,%d1
	sne %d1
	tst.l %d4
	sne %d5
	tst.l %d6
	sne %d6
	add.l %d7,%d7
	move.w %d2,%a4
	move.b %d2,sv+8
	neg.l %d1
	lsl.l #2,%d1
	move.w %d5,%a1
	neg.l %d6
	lsl.l #5,%d6
	move.l %d1,%d5
	move.l %a1,%d1
	neg.l %d1
	lsl.l #4,%d1
	or.l %d1,%d5
	move.l %a0,%d1
	or.l %d1,%d5
	move.l %d5,%d1
	moveq #19,%d5
	cmp.l %d0,%d5
	scs %d0
	or.l %d6,%d1
	neg.l %d0
	lsl.l #3,%d0
	or.l %d7,%d1
	or.l %d0,%d1
	move.l %d2,%d0
	lsl.l #6,%d0
	or.l %d0,%d1
	mvz.b sv+101,%d0
	mvz.b %d1,%d6
	cmp.l %d6,%d0
	jne .L255
	move.l sv+104,%d6
	cmp.l sv+88.l,%d6
	jne .L255
	tst.l %d3
	jeq .L256
	move.l 48(%sp),%d0
	sub.l sv+108,%d0
	cmp.l %d0,%d5
	jge .L256
.L255:
	moveq #1,%d0
	move.b %d0,sv+102
.L256:
	move.b %d1,sv+100
	move.w %a4,%d1
	mvz.b %d1,%d0
	mvz.b sv+9,%d1
	cmp.l %d0,%d1
	jeq .L257
	tst.l %d2
	jeq .L258
	addq.l #1,sv+72
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
.L259:
	move.w %a4,%d6
	moveq #1,%d0
	move.b %d6,sv+9
	move.b %d0,32(%a2)
.L257:
	move.l %d4,%d0
	or.l st+972,%d0
	or.l %d2,%d0
	jne .L260
	move.l led_gen,%d0
.L261:
	clr.l st+1006
	jra .L318
.L226:
	tst.b %d3
	jeq .L246
	move.l 44(%sp),%a3
	move.l %a3,sv+80
	jra .L246
.L250:
	move.l sv+16,%d0
	cmp.l #65534,%d0
	jhi .L251
	addq.l #1,%d0
	move.l %d0,sv+16
	jra .L251
.L253:
	cmp.l commits.l,%d1
	jeq .L252
	moveq #19,%d2
	cmp.l %d0,%d2
	jcs .L252
	move.l %d4,%d2
	or.l %d6,%d2
	seq %d2
	mvs.b %d2,%d2
	neg.l %d2
	jra .L254
.L258:
	subq.l #2,%d3
	tst.l %d3
	jne .L259
	addq.l #1,sv+76
	jra .L259
.L260:
	move.l commits,%d1
	cmp.l st+20.l,%d1
	jne .L262
	tst.l st+344
	jeq .L263
.L262:
	moveq #1,%d2
	move.b %d2,32(%a2)
.L263:
	move.l led_gen,%d1
	tst.l %d4
	jeq .L261
	cmp.l st+1002.l,%d1
	jeq .L318
	btst #0,%d1
	jeq .L265
.L318:
	clr.l %d0
	jra .L266
.L265:
	move.b led_req_mode,%d2
	clr.l %d0
	lea led_req,%a0
.L267:
	lea (%a0,%d0.l),%a1
	moveq #16,%d3
	move.b (%a1),98(%sp,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d3
	jne .L267
	cmp.l led_gen.l,%d1
	jne .L318
	mvz.b %d2,%d2
	move.l %d1,st+1002
	clr.l %d0
	lea st+1022,%a0
	move.l %d2,st+1006
.L269:
	moveq #16,%d1
	lea 98(%sp,%d0.l),%a1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L269
	mov3q.l #1,%d0
.L266:
	mov3q.l #1,%d2
	cmp.l st+1006.l,%d2
	jeq .L270
	jsr led_restore
.L271:
	jsr flush
	move.b st+992,%d0
	move.b st+161,%d1
	or.l %d1,%d0
	tst.b %d0
	jne .L199
	lea (98,%sp),%a3
	sub.l %a1,%a1
	lea mr,%a5
	clr.l %d1
	move.l %a3,%d2
	move.l %a3,%a2
	move.l %a5,%a4
.L276:
	moveq #127,%d0
	and.l -2147457096,%d0
	mvz.b (%a5)+,%d3
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l #1092966773,%a0
	move.b (%a0,%a1.l),%d0
	move.l %d2,%a0
	move.b %d0,(%a0)+
	mvz.b %d0,%d0
	move.l %a0,%d2
	cmp.l %d0,%d3
	jeq .L275
	addq.l #1,%d1
.L275:
	lea (152,%a1),%a1
	cmp.l #1824,%a1
	jne .L276
	tst.b mr+12.l
	jne .L277
	sub.l %a0,%a0
.L278:
	lea (%a3,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a4,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L278
	moveq #127,%d0
	and.l -2147457096,%d0
	moveq #1,%d1
	move.b %d0,mr+18
	move.b %d1,mr+12
.L279:
	tst.b sv+4.l
	jeq .L286
	move.w #-2304,%a1
	move.w #10497,%d2
	lea sv+5,%a0
	move.w (%a0),104(%sp)
	move.l #-260222380,%d1
	move.l %d1,98(%sp)
	move.w %a1,106(%sp)
	move.w %d2,102(%sp)
	pea 9.w
	move.l %a2,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L199
	clr.b %d0
	addq.l #1,sv+64
	move.b %d0,sv+4
.L286:
	tst.b sv+102.l
	jeq .L289
	moveq #127,%d0
	moveq #127,%d4
	and.l sv+92,%d0
	move.w #11009,%d3
	move.l #-260222380,%d1
	moveq #14,%d5
	move.l %d1,66(%sp)
	moveq #28,%d1
	move.l sv+88,%d2
	moveq #127,%d6
	lea sv+100,%a0
	move.b (%a0),72(%sp)
	move.b %d0,73(%sp)
	move.l %d2,%d0
	lsr.l %d1,%d0
	move.w %d3,70(%sp)
	moveq #21,%d3
	move.b %d0,74(%sp)
	move.l %d2,%d0
	lsr.l %d3,%d0
	and.l %d4,%d0
	move.b %d0,75(%sp)
	move.l %d2,%d0
	lsr.l %d5,%d0
	and.l %d4,%d0
	move.b %d0,76(%sp)
	move.l %d2,%d0
	lsr.l #7,%d0
	and.l %d4,%d0
	move.b %d0,77(%sp)
	moveq #127,%d0
	and.l %d2,%d0
	move.b %d0,78(%sp)
	move.l sv+96,%d0
	cmp.l %d0,%d6
	jcc .L290
	moveq #127,%d0
.L290:
	move.b %d0,79(%sp)
	clr.l %d0
.L291:
	lea 66(%sp,%d0.l),%a0
	moveq #14,%d1
	move.b (%a0),(%a2,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L291
	moveq #-9,%d3
	move.b %d3,112(%sp)
	pea 15.w
	move.l %a2,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L199
	clr.b %d4
	lea sv+100,%a0
	move.b (%a0),sv+101
	lea st+8,%a1
	move.l %d2,sv+104
	move.l (%a1),sv+108
	addq.l #1,sv+112
	move.b %d4,sv+102
.L289:
	tst.b sv.l
	jeq .L199
	clr.l %d4
	mov3q.l #-1,%d3
	clr.l %d5
	lea sv+24,%a3
.L301:
	moveq #127,%d0
	and.l -2147457096,%d0
	mvz.b sv+1,%d1
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a4
	add.l %d1,%a4
	add.l #1092966707,%a4
	add.l %d4,%a4
	mov3q.l #7,%d0
	cmp.l %d5,%d0
	jlt .L293
	move.l sv+80,%a0
	tst.l %a0
	jeq .L293
	move.l (%a0),%a5
	move.l %d5,-(%sp)
	move.l %a0,-(%sp)
	move.l 156(%a5),%a0
	jsr (%a0)
	addq.l #8,%sp
	move.l %d0,%d7
	tst.l %d0
	jle .L293
	mov3q.l #-1,-(%sp)
	move.l %d0,-(%sp)
	move.l 84(%a5),%a0
	move.l sv+80,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	move.l #1481856080,%d1
	move.l %d0,%d2
	move.l %d0,%d6
	asr.l #8,%d2
	cmp.l 1073848892.l,%d1
	jne .L294
	move.l 1073848896,%a0
	move.l %d7,-(%sp)
	jsr (%a0)
	move.b (%a4),%d7
	addq.l #4,%sp
	move.l %d0,%d1
	asr.l #8,%d1
	move.l %d1,%a1
	mov3q.l #2,%d1
	lea (-1,%a1),%a0
	cmp.l %a0,%d1
	jcs .L294
	move.l %d0,%d1
	mvz.b %d1,%d1
	move.l %d1,%a0
	tst.b %d0
	jeq .L294
	move.l %d2,%d1
	moveq #127,%d0
	mvz.b %d1,%d1
	and.l %d7,%d0
	mov3q.l #1,%d6
	cmp.l %a1,%d6
	jne .L295
	move.l %a0,%d2
	muls.l %d0,%d2
	asr.l #7,%d2
	cmp.l %d1,%d2
	jne .L296
.L312:
	lsl.l #7,%d0
.L419:
	mvz.b 1(%a4),%d1
	lsr.l #1,%d1
	jra .L418
.L270:
	tst.b ov_on.l
	jeq .L272
	tst.l %d0
	jeq .L271
.L272:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L319
	addq.l #1,st+1018
	jra .L271
.L319:
	clr.l %d0
	lea st+1022,%a2
	lea ov_col,%a0
.L273:
	lea (%a2,%d0.l),%a1
	moveq #16,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L273
	moveq #1,%d2
	move.l %sp,%d3
	add.l #98,%d3
	lea rui_uart_raw,%a3
	move.b %d2,ov_on
	clr.l %d2
.L274:
	move.b (%a2,%d2.l),%d0
	moveq #-76,%d4
	move.b %d2,99(%sp)
	addq.l #1,%d2
	moveq #16,%d5
	move.b %d0,100(%sp)
	move.b %d4,98(%sp)
	move.b %d0,101(%sp)
	move.b %d0,102(%sp)
	move.b %d0,103(%sp)
	move.l %d3,-(%sp)
	mov3q.l #6,-(%sp)
	jsr (%a3)
	addq.l #8,%sp
	cmp.l %d2,%d5
	jne .L274
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #1,st+1010
	addq.l #4,%sp
	jra .L271
.L277:
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jge .L280
	moveq #1,%d3
	move.b %d3,mr+13
.L281:
	move.l %a3,-(%sp)
	pea 12.w
	clr.l -(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L199
	sub.l %a0,%a0
.L284:
	lea (%a3,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a4,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L284
	move.w mr+16,%d0
	clr.b %d1
	addq.l #1,%d0
	move.b %d1,mr+13
	move.w %d0,mr+16
.L417:
	jsr kit_tick
	jra .L279
.L280:
	clr.l %d2
	tst.b mr+13.l
	jne .L281
.L282:
	mvz.b (%a4,%d2.l),%d0
	mvz.b (%a3)+,%d1
	cmp.l %d1,%d0
	jeq .L285
	move.l %a2,-(%sp)
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L199
	lea (-1,%a3),%a0
	move.b (%a0),(%a4,%d2.l)
	move.w mr+14,%d0
	addq.l #1,%d0
	move.w %d0,mr+14
.L285:
	addq.l #1,%d2
	moveq #12,%d0
	cmp.l %d2,%d0
	jne .L282
	jra .L417
.L296:
	mvs.w %d1,%d1
	move.l %a0,%d2
	lsl.l #7,%d1
	lea -1(%a0,%d1.l),%a1
	move.l %a1,%d1
	divs.l %d2,%d1
.L313:
	moveq #127,%d6
	cmp.l %d1,%d6
	jlt .L321
	move.l %d1,%d0
	lsl.l #7,%d0
.L297:
	move.b sv+7,%d1
	move.w %d0,66(%sp,%d4.l)
	tst.b %d1
	jne .L298
	mvz.w (%a3,%d4.l),%d2
	mvz.w %d0,%d0
	cmp.l %d2,%d0
	jeq .L299
.L298:
	cmp.l %a6,%d5
	jge .L300
	move.l %d5,%a6
.L300:
	move.l %d5,%d3
.L299:
	addq.l #1,%d5
	addq.l #2,%d4
	moveq #16,%d6
	cmp.l %d5,%d6
	jne .L301
	tst.b %d1
	jne .L322
	mov3q.l #-1,%d0
	cmp.l %d3,%d0
	jeq .L199
.L302:
	move.w #10753,%d2
	move.w %a6,%d0
	move.l #-260222380,%d1
	move.l %d1,98(%sp)
	lea sv+1,%a0
	move.b (%a0),104(%sp)
	lea (107,%sp),%a0
	move.w %d2,102(%sp)
	move.b %d0,105(%sp)
	move.l %d3,%d0
	addq.l #1,%d0
	move.l %d0,%d1
	sub.l %a6,%d1
	move.b %d1,106(%sp)
	move.l %a6,%d1
.L303:
	cmp.l %d3,%d1
	jle .L304
	cmp.l %a6,%d0
	sge %d0
	move.l %d0,%d1
	neg.l %d1
	tst.b %d1
	jeq .L305
	move.l %d3,%d1
	sub.l %a6,%d1
	add.l %d1,%d1
	add.l #11,%d1
.L306:
	moveq #-9,%d5
	neg.l %d0
	move.b %d5,98(%sp,%d1.l)
	tst.b %d0
	jeq .L307
	move.l %d3,%d0
	addq.l #6,%d0
	sub.l %a6,%d0
	add.l %d0,%d0
.L308:
	move.l %d0,-(%sp)
	move.l %a2,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L199
	lea sv+24,%a0
.L309:
	cmp.l %d3,%a6
	jle .L310
	clr.b %d0
	addq.l #1,sv+68
	move.b %d0,sv+7
	jra .L199
.L294:
	move.l %d2,%d0
	move.l %d6,%d1
	lsl.l #7,%d0
	asr.l #1,%d1
	moveq #127,%d2
	and.l %d2,%d1
	and.l #16256,%d0
.L418:
	or.l %d1,%d0
	jra .L297
.L293:
	move.b (%a4),%d0
	lsl.l #7,%d0
	and.l #16256,%d0
	jra .L419
.L321:
	move.w #16256,%d0
	jra .L297
.L322:
	moveq #15,%d3
	sub.l %a6,%a6
	jra .L302
.L304:
	move.w 66(%sp,%d1.l*2),%d2
	addq.l #1,%d1
	addq.l #2,%a0
	move.l %d2,%d4
	lsr.l #7,%d4
	move.b %d4,-2(%a0)
	moveq #127,%d4
	and.l %d4,%d2
	move.b %d2,-1(%a0)
	jra .L303
.L305:
	moveq #9,%d1
	jra .L306
.L307:
	moveq #10,%d0
	jra .L308
.L310:
	lea 66(%sp,%a6.l*2),%a1
	move.w (%a1),(%a0,%a6.l*2)
	addq.l #1,%a6
	jra .L309
.L295:
	cmp.l %d1,%d0
	jne .L313
	jra .L312
.L317:
	mov3q.l #2,%d3
	jra .L243
	.size	rui_tick, .-rui_tick
	.text
.LC0:
	.string	"%s"
	.text
	.align	2
	.globl	rui_draw
	.type	rui_draw, @function
rui_draw:
	lea (-104,%sp),%sp
	movem.l #31996,(%sp)
	move.l -66650100,%d3
	move.l 108(%sp),%a0
	move.l %d3,56(%sp)
	move.l 16(%a0),%d2
	tst.l st+4
	jeq .L421
	move.l commits,%a6
	cmp.l st+24.l,%a6
	jne .L423
	move.l %d2,%d0
	move.l %d2,%a0
	add.l #1024,%d0
.L426:
	clr.l (%a0)+
	cmp.l %a0,%d0
	jne .L426
	move.l %a6,st+20
.L425:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 56(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L420
	move.l %d0,st+332
.L420:
	movem.l (%sp),#31996
	lea (104,%sp),%sp
	rts
.L421:
	tst.l st+972
	jne .L424
	tst.b sv+8.l
	jeq .L425
.L424:
	move.l commits,%a6
.L423:
	cmp.l st+340.l,%a6
	jne .L427
	tst.l st+344
	jeq .L428
.L427:
	move.l -66650100,%d5
	move.l sh_seq,%d3
	lea copy32,%a2
	move.l %d5,60(%sp)
	btst #0,%d3
	jne .L429
	pea 256.w
	pea shadow
	pea comp
	jsr (%a2)
	pea 704.w
	pea txt_sh
	pea (tl.0)
	jsr (%a2)
	lea (24,%sp),%sp
	cmp.l sh_seq.l,%d3
	jne .L429
	tst.l st+872
	jne .L430
	clr.l -(%sp)
	pea comp
	pea 64.w
	pea 128.w
	pea st+872
	jsr 1074198978
	lea (20,%sp),%sp
.L430:
	lea (tl.0),%a2
	clr.l %d4
	lea st+472,%a4
.L443:
	tst.b 4(%a2)
	jeq .L431
	lea st+408,%a0
	clr.l %d5
	move.l %a2,%d3
	addq.l #8,%d3
	move.l %a0,48(%sp)
	lea st+552,%a1
.L442:
	move.l 48(%sp),%a5
	addq.l #4,48(%sp)
	tst.l (%a5)+
	jeq .L433
	mvz.b (%a1),%d0
	cmp.l %d0,%d4
	jne .L433
	mvz.b (%a4,%d5.l),%d1
	mvz.b 5(%a1),%d3
	sub.l %a0,%a0
	lea (6,%a1),%a3
.L435:
	cmp.l %d3,%a0
	jlt .L436
	move.b 4(%a1),%d0
	lea 68(%sp,%d3.l),%a0
	btst #1,%d0
	jeq .L451
	move.l %d1,%d0
	add.l #-64,%d0
	move.l %d0,52(%sp)
	tst.l %d0
	jle .L438
	move.b #43,(%a0)
	addq.l #1,%d3
	lea 68(%sp,%d3.l),%a0
.L452:
	sub.l %a3,%a3
	jra .L437
.L436:
	lea (%a3,%a0.l),%a5
	move.b (%a5),68(%sp,%a0.l)
	addq.l #1,%a0
	jra .L435
.L438:
	tst.l 52(%sp)
	jeq .L452
	move.b #45,(%a0)
	moveq #64,%d6
	mov3q.l #1,%a3
	sub.l %d1,%d6
	move.l %d6,52(%sp)
.L437:
	lea (64,%sp),%a5
	clr.l %d1
.L440:
	move.l 52(%sp),%d7
	moveq #10,%d0
	addq.l #1,%d1
	rems.l %d0,%d6:%d7
	divs.l %d0,%d7
	move.l %d6,44(%sp)
	add.l #48,%d6
	move.b %d6,(%a5)
	move.l %d7,52(%sp)
	tst.l %d7
	jeq .L439
	addq.l #1,%a5
	mov3q.l #4,%d7
	cmp.l %d1,%d7
	jne .L440
.L439:
	add.l %a3,%a0
	move.l %d1,%d0
.L441:
	subq.l #1,%d0
	move.b 64(%sp,%d0.l),(%a0)+
	tst.l %d0
	jne .L441
	lea (104,%sp),%a0
	add.l %a0,%d1
	add.l %d3,%d1
	move.b %d0,-36(%a3,%d1.l)
	move.l %sp,%d3
	add.l #68,%d3
.L433:
	addq.l #1,%d5
	lea (20,%a1),%a1
	moveq #16,%d6
	cmp.l %d5,%d6
	jne .L442
	mvz.b 2(%a2),%d0
	lsl.l #3,%d0
	add.l #1098790940,%d0
	move.l %d0,-(%sp)
	jsr 1074207612
	addq.l #4,%sp
	move.l %d0,%a0
	moveq #64,%d0
	mvz.w 6(%a0),%d1
	sub.l %d1,%d0
	mvz.b 1(%a2),%d1
	sub.l %d1,%d0
	mvz.w 4(%a0),%d1
	cmp.l %d0,%d1
	jgt .L431
	move.b 3(%a2),%d1
	move.l %d3,-(%sp)
	pea .LC0
	move.l %d3,-(%sp)
	mov3q.l #1,%d7
	move.l %d1,%d3
	lsr.l #2,%d3
	and.l %d3,%d7
	mov3q.l #3,%d3
	and.l %d1,%d3
	move.l %d7,-(%sp)
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	mvz.b (%a2),%d0
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	pea st+872
	jsr 1074205920
	lea (36,%sp),%sp
	addq.l #1,st+352
.L431:
	addq.l #1,%d4
	lea (44,%a2),%a2
	moveq #64,%d5
	cmp.l %d4,%d5
	jne .L443
	move.l -66650100,%d0
	move.l %a6,st+340
	addq.l #1,st+348
	sub.l 60(%sp),%d0
	add.l %d0,st+356
	cmp.l st+360.l,%d0
	jls .L444
	move.l %d0,st+360
.L444:
	clr.l st+344
.L428:
	pea 256.w
	pea comp
	move.l %d2,-(%sp)
	jsr copy32
	lea (12,%sp),%sp
	cmp.l st+20.l,%a6
	jeq .L445
	move.l -66650100,%d0
	addq.l #1,st+308
	sub.l t_commit,%d0
	add.l %d0,st+304
	cmp.l st+312.l,%d0
	jls .L445
	move.l %d0,st+312
.L445:
	move.l st+388,%d1
	tst.l %d1
	jeq .L446
	cmp.l st+392.l,%a6
	jeq .L446
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+396
	addq.l #1,st+400
	cmp.l st+404.l,%d0
	jls .L447
	move.l %d0,st+404
.L447:
	clr.l st+388
.L446:
	move.l st+368,%d1
	tst.l %d1
	jeq .L448
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+372
	addq.l #1,st+376
	cmp.l st+380.l,%d0
	jls .L449
	move.l %d0,st+380
.L449:
	clr.l st+368
.L448:
	move.l %a6,st+20
	move.l -66650100,%d0
	move.l %d0,st+56
	sub.l t_commit,%d0
	addq.l #1,st+28
	move.l %d0,st+60
	jra .L425
.L451:
	move.l %d1,52(%sp)
	jra .L452
.L429:
	pea 256.w
	pea comp
	move.l %d2,-(%sp)
	addq.l #1,st+32
	jsr (%a2)
	lea (12,%sp),%sp
	jra .L425
	.size	rui_draw, .-rui_draw
	.align	2
	.globl	rui_key
	.type	rui_key, @function
rui_key:
	lea (-40,%sp),%sp
	move.l -66650100,%d0
	move.l 48(%sp),%a1
	movem.l #3324,(%sp)
	move.l %d0,36(%sp)
	moveq #31,%d2
	move.l 16(%a1),%d0
	mov3q.l #1,%d6
	move.l 12(%a1),%d5
	move.l %d5,%d3
	mvz.b %d3,%d3
	lea st,%a2
	and.l %d0,%d6
	lsl.l #8,%d0
	and.l %d5,%d2
	move.l 44(%sp),%a0
	move.l %d3,%d4
	lsr.l #5,%d4
	move.l %d6,%d1
	lsl.l #8,%d1
	and.l #65024,%d0
	move.l %d2,32(%sp)
	move.l 32(%sp),%d5
	mov3q.l #1,%d2
	move.l %d4,%a1
	lea (66,%a1),%a1
	lsl.l %d5,%d2
	or.l %d1,%d0
	move.l (%a2,%a1.l*4),%d1
	or.l %d3,%d0
	move.l %d0,st+72
	move.l %d1,%d0
	and.l %d2,%d0
	tst.l %d6
	jne .L468
	tst.l %d0
	jeq .L469
	not.l %d2
	and.l %d1,%d2
	move.l %d2,(%a2,%a1.l*4)
.L470:
	mov3q.l #1,%d0
	jra .L475
.L469:
	move.l %d4,%d0
	add.l #50,%d0
	move.l (%a2,%d0.l*4),%d1
	move.l %d1,%d5
	and.l %d2,%d5
	tst.l %d5
	jeq .L471
	not.l %d2
	and.l %d1,%d2
	move.l %d2,(%a2,%d0.l*4)
.L472:
	clr.l %d0
.L475:
	move.l -66650100,%d1
	addq.l #1,st+336
	sub.l 36(%sp),%d1
	add.l %d1,st+328
	cmp.l st+332.l,%d1
	jls .L467
	move.l %d1,st+332
.L467:
	movem.l (%sp),#3324
	lea (40,%sp),%sp
	rts
.L471:
	move.l %d4,%d0
	add.l #226,%d0
	move.l (%a2,%d0.l*4),%d1
	move.l %d1,%d5
	and.l %d2,%d5
	tst.l %d5
	jeq .L473
	not.l %d2
	and.l %d1,%d2
	move.l %d2,(%a2,%d0.l*4)
	tst.l st+4
	jeq .L472
	clr.l -(%sp)
	move.l %d3,-(%sp)
	jsr queue_key
	addq.l #8,%sp
	jra .L472
.L473:
	add.l #58,%d4
	move.l (%a2,%d4.l*4),%d0
	move.l %d0,%d1
	and.l %d2,%d1
	tst.l %d1
	jeq .L472
	not.l %d2
	and.l %d0,%d2
	move.l %d2,(%a2,%d4.l*4)
	tst.l st+4
	jeq .L470
	clr.l -(%sp)
	move.l %d3,-(%sp)
	jsr queue_key
.L509:
	addq.l #8,%sp
	jra .L470
.L468:
	tst.l %d0
	jne .L470
	move.l %d4,%d6
	move.l %d2,%d0
	add.l #58,%d6
	and.l (%a2,%d6.l*4),%d0
	tst.l %d0
	jne .L470
	move.l %d4,%d7
	move.l %d2,%d0
	add.l #50,%d7
	and.l (%a2,%d7.l*4),%d0
	tst.l %d0
	jne .L472
	move.l %d4,%a3
	move.l %d2,%d0
	lea (226,%a3),%a3
	and.l (%a2,%a3.l*4),%d0
	tst.l %d0
	jne .L472
	move.l st+4,%d0
	moveq #68,%d5
	cmp.l %d3,%d5
	jne .L477
	move.l st+216,%d5
	or.l st+248,%d5
	or.l st+920,%d5
	btst #6,%d5
	jeq .L478
	moveq #16,%d2
	or.l %d1,%d2
	move.l 32(%a0),%d1
	move.l %d2,st+272
	tst.l %d0
	jeq .L479
	mov3q.l #3,-(%sp)
	move.l %d1,-(%sp)
	jsr leave
	jra .L509
.L479:
	clr.l -(%sp)
	clr.l -(%sp)
	move.l %d1,-(%sp)
	jsr enter
.L510:
	lea (12,%sp),%sp
	jra .L470
.L477:
	moveq #53,%d5
	cmp.l %d3,%d5
	jne .L480
	move.l st+216,%d5
	or.l st+248,%d5
	or.l st+920,%d5
	btst #6,%d5
	jeq .L478
	bset #21,%d1
	move.l %d1,st+268
	tst.l %d0
	jeq .L481
	moveq #1,%d1
	moveq #1,%d2
	mvz.w #256,%d0
	moveq #1,%d5
	addq.l #1,st+998
	move.l %d0,st+296
	move.b %d1,st+161
	move.w %d2,st+162
	move.b %d5,st+993
	jsr flush
	jra .L470
.L481:
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l 32(%a0),-(%sp)
	jsr enter
	addq.l #1,st+994
	jra .L510
.L480:
	tst.l %d0
	jne .L482
.L494:
	tst.l st+972
	jeq .L483
	move.l %d3,%d0
	mov3q.l #2,%d1
	add.l #-80,%d0
	cmp.l %d0,%d1
	jcc .L483
	add.l #-64,%d0
	moveq #11,%d5
	cmp.l %d0,%d5
	jcc .L483
	mov3q.l #4,-(%sp)
	move.l 32(%a0),-(%sp)
	jsr splash_end
	addq.l #8,%sp
	move.l %d3,%d0
	mov3q.l #5,%d1
	add.l #-64,%d0
	cmp.l %d0,%d1
	jcs .L484
	or.l %d2,st+272
	jra .L470
.L484:
	tst.l st+4
	jeq .L483
.L485:
	tst.l mask_set
	jeq .L487
	lea mask_keys,%a0
	move.l (%a0,%d4.l*4),%d0
	move.l 32(%sp),%d1
	btst %d1,%d0
	jeq .L488
.L487:
	cmp.l #128,%d3
	jne .L508
	mov3q.l #2,%d4
	jra .L489
.L482:
	move.l %d3,%d0
	mov3q.l #2,%d5
	add.l #-80,%d0
	cmp.l %d0,%d5
	jcs .L485
	addq.l #1,st+944
.L483:
	or.l %d2,(%a2,%d7.l*4)
	jra .L472
.L488:
	addq.l #1,st+940
	jra .L483
.L508:
	mov3q.l #1,%d4
.L489:
	addq.l #1,st+936
	mov3q.l #2,%d5
	cmp.l %d4,%d5
	jne .L491
	or.l %d2,(%a2,%a3.l*4)
.L492:
	mov3q.l #1,-(%sp)
	move.l %d3,-(%sp)
	jsr queue_key
	jsr flush
	addq.l #8,%sp
	mov3q.l #2,%d1
	cmp.l %d4,%d1
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L475
.L491:
	or.l %d2,(%a2,%d6.l*4)
	jra .L492
.L478:
	tst.l %d0
	jne .L485
	jra .L494
	.size	rui_key, .-rui_key
	.align	2
	.globl	rui_enc
	.type	rui_enc, @function
rui_enc:
	lea (-68,%sp),%sp
	move.l 76(%sp),%a0
	movem.l #23804,(%sp)
	move.l -66650100,%d0
	lea (4,%a0),%a1
	move.l (%a1),st+76
	lea (8,%a0),%a1
	move.l (%a1),st+80
	lea (12,%a0),%a1
	move.l %d0,44(%sp)
	move.l (%a1),st+84
	lea (16,%a0),%a1
	move.l (%a1),st+88
	lea st,%a2
	mvz.b 20(%a0),%d0
	move.l %d0,st+92
	tst.l st+4
	jne .L512
	tst.l st+972
	jeq .L513
	mov3q.l #5,-(%sp)
	move.l 76(%sp),%a0
	move.l 32(%a0),-(%sp)
	jsr splash_end
	addq.l #8,%sp
.L513:
	clr.l %d0
.L514:
	move.l -66650100,%d1
	addq.l #1,st+336
	sub.l 44(%sp),%d1
	add.l %d1,st+328
	cmp.l st+332.l,%d1
	jls .L511
	move.l %d1,st+332
.L511:
	movem.l (%sp),#23804
	lea (68,%sp),%sp
	rts
.L512:
	move.l 12(%a0),%a6
	tst.l mask_set
	jeq .L515
	moveq #15,%d0
	cmp.l %a6,%d0
	jcs .L516
	move.l mask_enc,%d0
	move.l %a6,%d1
	btst %d1,%d0
	jne .L515
.L516:
	addq.l #1,st+952
	jra .L513
.L515:
	move.l 16(%a0),%d2
	addq.l #1,st+948
	tst.b 20(%a0)
	jne .L534
	move.l st+216,%d0
	mov3q.l #1,%d3
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d3,%d0
.L517:
	move.b %d0,st+160
	moveq #15,%d0
	cmp.l %a6,%d0
	jcs .L518
	move.l %a6,%d4
	add.l #24,%d4
	add.l %d2,(%a2,%d4.l*4)
	tst.l st+64
	jne .L519
	move.l #-66650100,%a0
	move.l (%a0),st+64
.L519:
	tst.l st+388
	jne .L520
	move.l #-66650100,%a1
	lea commits,%a0
	move.l (%a1),st+388
	move.l (%a0),st+392
.L520:
	move.l %a6,%d5
	add.l #122,%d5
	lea bind_gen,%a4
	move.l (%a4,%a6.l*4),%d6
	move.l (%a2,%d5.l*4),%a3
	cmp.l %d6,%a3
	jeq .L523
	btst #0,%d6
	jne .L523
	moveq #20,%d0
	move.l %a6,%d3
	muls.l %d0,%d3
	mov3q.l #5,-(%sp)
	lea copy32,%a0
	move.l %d3,%d1
	add.l #bind_in,%d1
	move.l %d1,-(%sp)
	move.l %sp,%d7
	add.l #56,%d7
	move.l %d7,-(%sp)
	move.l %a0,52(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	move.l 40(%sp),%a0
	cmp.l (%a4,%a6.l*4),%d6
	jne .L523
	move.l %d3,%d0
	move.l %a6,%d1
	add.l #st+552,%d0
	add.l #102,%d1
	tst.l (%a2,%d1.l*4)
	jeq .L535
	move.l %d0,%a1
	move.b 48(%sp),%d3
	move.b (%a1),%d1
	eor.l %d1,%d3
	tst.b %d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
.L525:
	mov3q.l #5,-(%sp)
	move.l %d7,-(%sp)
	move.l %d0,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	tst.l %d3
	jne .L526
	lea (%a2,%a6.l),%a0
	move.b 49(%sp),472(%a0)
.L526:
	move.l %d6,(%a2,%d5.l*4)
	move.l %d6,%a3
.L523:
	tst.l %a3
	jeq .L527
	move.l %a6,%d1
	moveq #20,%d3
	muls.l %d3,%d1
	lea (%a2,%d1.l),%a0
	mvz.b 552(%a0),%d0
	lsr.l #6,%d0
	jne .L527
	lea (102,%a6),%a1
	add.l #st,%a6
	tst.l (%a2,%a1.l*4)
	jne .L528
	move.b 553(%a0),472(%a6)
.L528:
	move.l %d1,%a0
	add.l #st+556,%a0
	move.b (%a0),%d0
	mvz.b 472(%a6),%d5
	btst #0,%d0
	jeq .L536
	tst.b st+160.l
	jne .L537
.L536:
	mov3q.l #1,%d0
.L529:
	muls.l %d2,%d0
	move.l %d1,%a0
	add.l #st+554,%a0
	mvz.b (%a0),%d3
	add.l %d5,%d0
	cmp.l %d0,%d3
	jle .L530
	move.l %d3,%d0
.L530:
	move.l %d1,%a0
	add.l #st+555,%a0
	mvz.b (%a0),%d2
	cmp.l %d0,%d2
	jge .L531
	move.l %d2,%d0
.L531:
	move.l %d1,%a0
	add.l #st+553,%a0
	move.b %d0,(%a0)
	move.l 8(%a2),%a0
	addq.l #8,%a0
	move.l %a0,(%a2,%a1.l*4)
	move.b %d0,472(%a6)
	mov3q.l #1,st+344
	addq.l #1,st+364
	tst.l st+368
	jne .L532
	move.l #-66650100,%a1
	move.l (%a1),st+368
.L532:
	moveq #1,%d0
	move.l 72(%sp),%a1
	move.l 32(%a1),%a0
	move.b %d0,32(%a0)
.L527:
	jsr flush
	tst.l (%a2,%d4.l*4)
	jne .L518
	addq.l #1,st+384
.L518:
	mov3q.l #1,%d0
	jra .L514
.L534:
	mov3q.l #1,%d0
	jra .L517
.L535:
	clr.l %d3
	jra .L525
.L537:
	moveq #8,%d0
	jra .L529
	.size	rui_enc, .-rui_enc
	.local	tl.0
	.comm	tl.0,2816,1
	.local	uart_sub
	.comm	uart_sub,4,4
	.local	uart_bytes
	.comm	uart_bytes,4,4
	.local	ps_id
	.comm	ps_id,1,1
	.local	ps_pos
	.comm	ps_pos,1,1
	.local	ps_hdr
	.comm	ps_hdr,1,1
	.local	ps_left
	.comm	ps_left,1,1
	.local	sh
	.comm	sh,64,1
	.local	ov_col
	.comm	ov_col,16,1
	.local	ov_on
	.comm	ov_on,1,1
	.text
	.align	2
	.type	sv_covers, @object
	.size	sv_covers, 32
sv_covers:
	.long	1075731444
	.long	1075721968
	.long	1075717140
	.long	1075664348
	.long	1075670552
	.long	1075670916
	.long	1075736788
	.long	1076038980
	.section	.bss,"aw",@nobits
	.align	4
	.type	sv, @object
	.size	sv, 116
sv:
	.zero	116
	.align	4
	.type	mr, @object
	.size	mr, 22
mr:
	.zero	22
	.text
	.type	mr_flag, @object
	.size	mr_flag, 17
mr_flag:
	.string	"PX`hpH\b@\177"
	.base64	"IH9/f39/EA=="
	.type	mr_voice, @object
	.size	mr_voice, 12
mr_voice:
	.base64	"AAIHBwEDBQUEBAYG"
	.local	st
	.comm	st,1040,4
	.local	led_req
	.comm	led_req,16,1
	.local	led_req_mode
	.comm	led_req_mode,1,1
	.local	led_gen
	.comm	led_gen,4,4
	.local	splash_req
	.comm	splash_req,4,4
	.local	masks
	.comm	masks,4,4
	.local	mask_set
	.comm	mask_set,4,4
	.local	mask_enc
	.comm	mask_enc,4,4
	.local	mask_keys
	.comm	mask_keys,32,4
	.local	mt_calls
	.comm	mt_calls,4,2
	.local	mt_max
	.comm	mt_max,4,2
	.local	mt_sum
	.comm	mt_sum,4,2
	.local	st_valid
	.comm	st_valid,1,1
	.local	st_seq
	.comm	st_seq,1,1
	.local	t_commit
	.comm	t_commit,4,4
	.local	host_close
	.comm	host_close,1,1
	.local	host_open
	.comm	host_open,1,1
	.local	rx_bad
	.comm	rx_bad,4,4
	.local	rx
	.comm	rx,4,4
	.local	commits
	.comm	commits,4,4
	.local	sh_seq
	.comm	sh_seq,4,4
	.local	bind_gen
	.comm	bind_gen,64,4
	.local	bind_in
	.comm	bind_in,320,4
	.local	txt_sh
	.comm	txt_sh,2816,4
	.local	txt_st
	.comm	txt_st,2816,4
	.local	comp
	.comm	comp,1024,4
	.local	staging
	.comm	staging,1024,4
	.local	shadow
	.comm	shadow,1024,4
	.ident	"GCC: (GNU) 16.2.0"
