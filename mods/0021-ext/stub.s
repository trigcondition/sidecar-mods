| Mod 0021 - external voice machines (PLAITS, DAISYSP) reporting trigs and P1..P16 over USB.
| GENERATED from ext.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os, EXT_SLOTS=1 and 0); edit ext.c.
	.ifne P_SLOTS
#NO_APP
	.file	"ext.c"
	.text
#APP
	  .section .ext2,"ax"
  .globl ext_pvt
ext_pvt:
  jsr ext_ui_tick
  lea %sp@(-20),%sp
  moveml %d2-%d4/%a2-%a3,%sp@
  jmp 0x400a85e8

	.globl us_off_tgen
.set us_off_tgen, 28
.globl us_off_layer
.set us_off_layer, 41
.globl us_off_ch
.set us_off_ch, 51
.globl us_off_wb
.set us_off_wb, 24
.globl us_wb_pslot
.set us_wb_pslot, 3
.globl us_wb_pgen
.set us_wb_pgen, 22
.globl us_wb_size
.set us_wb_size, 28
.globl us_off_en
.set us_off_en, 500

	  .section .us3,"ax"
  .globl us_src_table
  .align 2
us_src_table:
  move.l 4(%sp),%d0
  lea us,%a1
  move.l (%a1,%d0.l*4),%a1
  move.l %d0,%d1
  lsl.l #3,%d1
  add.l #334,%d1
  mulu.w #36,%d0
  add.l #0x40287ccc+36*35,%d0
  move.l %d0,%a0
  tst.l %a1
  jeq 2f
  moveq #1,%d0
  cmp.b 1(%a1),%d0
  jne 3f
  lea 36(%a1),%a1
  jra 2f
3: sub.l %a1,%a1
2: moveq #8,%d0
1: move.l %d1,(%a0)
  tst.l %a1
  jeq 4f
  tst.b (%a1)
  jeq 6f
  tst.b 8(%a1)
  jne 5f
6: clr.l (%a0)
5: lea 28(%a1),%a1
4: addq.l #4,%a0
  addq.l #1,%d1
  subq.l #1,%d0
  jne 1b
  rts

	.pushsection	.ust,"ax",@progbits
	.align	2
	.globl	us_tag_load
us_tag_load:
	move.l	%a3,-(%sp)
	move.l	%a2,-(%sp)
	jsr	us_tag_load_c
	addq.l	#8,%sp
	lea	0x401c5a74,%a0
	jmp	0x40008270
	.globl	us_tag_save
us_tag_save:
	move.l	%a3,-(%sp)
	move.l	%a2,-(%sp)
	jsr	us_tag_save_c
	addq.l	#8,%sp
	lea	0x401c59cc,%a0
	jmp	0x40008498
	.globl	us_tag_copy
us_tag_copy:
	move.l	%d2,-(%sp)
	move.l	%a2,-(%sp)
	jsr	us_tag_copy_c
	addq.l	#8,%sp
	move.l	%d2,-(%sp)
	pea	20(%a2)
	jmp	0x4011f590
	.popsection

	  .section .us4,"ax"
  .globl us_menu_thunk
us_menu_thunk:
  movel %sp@(132),%sp@-
  jsr us_menu_add
  addql #4,%sp
  lea %sp@(128),%sp
  rts
  .globl us_label_1
us_label_1: moveq #0,%d0
  bras us_label
  moveq #1,%d0
  bras us_label
  moveq #2,%d0
  bras us_label
  moveq #3,%d0
  bras us_label
  moveq #4,%d0
us_label:
  link %fp,#-4
  movel %a2,%sp@-
  movel %a0,%a2
  movel %d0,%sp@-
  jsr us_label_text
  addql #4,%sp
  pea %fp@(-1)
  movel %d0,%sp@-
  movel %a2,%sp@-
  jsr 0x401bcd4c
  lea %sp@(12),%sp
  movel %a2,%d0
  movel %sp@+,%a2
  unlk %fp
  rts
  .globl us_action_1
us_action_1: moveq #0,%d0
  bras us_action
  moveq #1,%d0
  bras us_action
  moveq #2,%d0
  bras us_action
  moveq #3,%d0
  bras us_action
  moveq #4,%d0
us_action:
  moveal %sp@(4),%a0
  moveal %a0@,%a0
  movel %d0,%sp@-
  movel %a0@,%sp@-
  jsr us_menu_action
  addql #8,%sp
  rts
  .globl us_icon
us_icon:
  rts
  .globl us_close_thunk
us_close_thunk:
  moveq #0,%d0
  moveb %d2,%d0
  movel %d0,%sp@-
  jsr us_confirm
  addql #4,%sp
  moveal %fp@(8),%a2
  movel %a2,%sp@-
  jmp 0x400dea94
  .section .us5,"ax"
  .globl us_prev_thunk
us_prev_thunk:
  movel %d2,%sp@-
  jsr 0x400bd14e
  movel %sp@(64),%sp@-
  movel %d3,%sp@-
  jsr us_step
  addql #8,%sp
  jmp 0x400bee46
  .globl us_open_thunk
us_open_thunk:
  clrb us+us_off_ch
  jmp 0x400def0a
  .globl us_load_thunk
us_load_thunk:
  jsr us_loaded
  lea %sp@(-12),%sp
  moveal %sp@(16),%a1
  jmp 0x4011f6c4

	.pushsection	.us7,"ax",@progbits
	.align	2
sp_sounds:
	lea	-28(%sp),%sp
	movem.l	%d2-%d5/%a2-%a4,(%sp)
	move.l	%d1,%d5
	lea	12(%a0),%a2
1:	mvz.b	0x68(%a1),%d0
	moveq	#-35,%d1
	add.l	%d1,%d0
	moveq	#4,%d1
	cmp.l	%d1,%d0
	bhi.s	9f
	mvz.b	0x6f(%a1),%d2
	mvz.b	0x6e(%a1),%d1
	moveq	#0x3f,%d3
	and.l	%d3,%d1
	move.l	%d1,%d3
	or.l	%d2,%d3
	beq.s	9f
	add.l	%d1,%d1
	move.l	%d2,%d3
	lsr.l	#7,%d3
	or.l	%d3,%d1
	addq.l	#1,%d0
	lsl.l	#8,%d0
	or.l	%d1,%d0
	lsl.l	#8,%d0
	moveq	#0x7f,%d3
	and.l	%d3,%d2
	or.l	%d2,%d0
	lsl.l	#8,%d0
	mvz.b	11(%a0),%d3
	move.l	%a2,%a3
	moveq	#0,%d4
2:	cmp.l	%d3,%d4
	bcc.s	4f
	move.l	(%a3),%d1
	cmp.l	%d0,%d1
	bcc.s	3f
	addq.l	#4,%a3
	addq.l	#1,%d4
	bra.s	2b
3:	eor.l	%d0,%d1
	lsr.l	#8,%d1
	bne.s	4f
	mvz.b	3(%a3),%d2
	moveq	#127,%d1
	cmp.l	%d1,%d2
	bcc.s	9f
	addq.l	#1,(%a3)
	bra.s	9f
4:	moveq	#16,%d1
	cmp.l	%d1,%d3
	bne.s	5f
	moveq	#1,%d1
	move.b	%d1,10(%a0)
	bra.s	9f
5:	lea	(%a2,%d3.l*4),%a4
6:	cmp.l	%a3,%a4
	bls.s	7f
	move.l	-(%a4),4(%a4)
	bra.s	6b
7:	addq.l	#1,%d0
	move.l	%d0,(%a3)
	addq.l	#1,%d3
	move.b	%d3,11(%a0)
9:	lea	152(%a1),%a1
	subq.l	#1,%d5
	bne.w	1b
	movem.l	(%sp),%d2-%d5/%a2-%a4
	lea	28(%sp),%sp
	rts
	.globl	sp_tick
sp_tick:
	lea	-96(%sp),%sp
	movem.l	%d2-%d3/%a2-%a3,80(%sp)
	lea	sp,%a2
	mvz.b	us+52,%d0
	lea	0x407c89d3,%a0
	moveq	#16,%d2
1:	mvz.b	(%a0)+,%d1
	beq.s	2f
	moveq	#31,%d3
	muls.l	%d3,%d0
	add.l	%d1,%d0
	subq.l	#1,%d2
	bne.s	1b
2:	cmp.l	(%a2),%d0
	beq.s	3f
	move.l	%d0,(%a2)
	moveq	#10,%d0
	move.b	%d0,8(%a2)
	moveq	#5,%d0
	move.b	%d0,10(%a2)
	bra.w	9f
3:	mvz.b	8(%a2),%d0
	beq.s	4f
	subq.l	#1,%d0
	move.b	%d0,8(%a2)
	bne.w	9f
4:	moveq	#20,%d0
	move.b	%d0,8(%a2)
	clr.w	10(%sp)
	move.l	%sp,%a0
	lea	0x4125590d,%a3
	moveq	#64,%d3
	add.l	%d3,%d3
5:	move.l	%a3,%a1
	moveq	#12,%d1
	bsr	sp_sounds
	lea	2531(%a3),%a3
	subq.l	#1,%d3
	bne.s	5b
	lea	0x41313c47,%a1
	moveq	#64,%d1
	add.l	%d1,%d1
	bsr	sp_sounds
	mvz.b	10(%sp),%d0
	addq.l	#1,%d0
	mvz.b	11(%sp),%d2
	lea	12(%sp),%a0
	move.l	%d2,%d3
	beq.s	6f
5:	moveq	#31,%d1
	muls.l	%d1,%d0
	add.l	(%a0)+,%d0
	subq.l	#1,%d3
	bne.s	5b
6:	cmp.l	4(%a2),%d0
	beq.s	7f
	move.l	%d0,4(%a2)
	mvz.b	9(%a2),%d0
	addq.l	#1,%d0
	moveq	#0x7f,%d1
	and.l	%d1,%d0
	move.b	%d0,9(%a2)
	moveq	#5,%d0
	move.b	%d0,10(%a2)
7:	mvz.b	10(%a2),%d0
	moveq	#5,%d1
	cmp.l	%d1,%d0
	bcc.s	8f
	addq.l	#1,%d0
	move.b	%d0,10(%a2)
	cmp.l	%d1,%d0
	bcs.w	9f
8:
	moveq	#4,%d0
	move.b	%d0,8(%a2)
	jsr	ext_ui_lock
	tst.l	%d0
	bne.s	12f
	moveq	#1,%d0
	cmp.l	0x413db254,%d0
	beq.s	9f
	moveq	#20,%d0
	move.b	%d0,8(%a2)
	bra.s	9f
12:
	move.l	0x413db258,%d0
	cmp.l	#3891,%d0
	bhi.s	10f
	pea	8.w
	jsr	usb_free
	addq.l	#4,%sp
	tst.l	%d0
	bne.s	11f
10:	jsr	0x40002924
	bra.s	9f
11:	moveq	#-16,%d0
	move.l	%d0,(%sp)
	move.l	#0x7d525425,%d0
	move.l	%d0,4(%sp)
	moveq	#1,%d0
	move.b	%d0,8(%sp)
	move.b	9(%a2),9(%sp)
	move.l	%d2,%d0
	lsl.l	#2,%d0
	lea	12(%sp),%a0
	moveq	#-9,%d1
	move.b	%d1,(%a0,%d0.l)
	moveq	#10,%d1
	add.l	%d1,%d0
	move.l	%d0,-(%sp)
	pea	7(%sp)
	jsr	us_assign_send
	addq.l	#8,%sp
	clr.w	10(%a2)
	moveq	#20,%d0
	move.b	%d0,8(%a2)
9:	movem.l	80(%sp),%d2-%d3/%a2-%a3
	lea	96(%sp),%sp
	rts
	.popsection

#NO_APP
	.section	.ext2,"ax",@progbits
	.align	2
	.globl	ext_engine_text
	.type	ext_engine_text, @function
ext_engine_text:
	move.l 8(%sp),%d1
	move.l %d1,%d0
	lsl.l #4,%d0
	move.l 12(%sp),%a0
	add.l %d1,%d0
	moveq #15,%d1
	asr.l %d1,%d0
	moveq #16,%d1
	cmp.l %d0,%d1
	jge .L2
	moveq #16,%d0
.L3:
	mvz.w %d0,%d0
	move.l %a0,4(%sp)
	lsl.l #3,%d0
	add.l #ext_engine_names,%d0
	move.l %d0,12(%sp)
	move.l #ext_fmt_s,%d0
	move.l %d0,8(%sp)
	jmp 1074365954
.L2:
	tst.l %d0
	jge .L3
	clr.l %d0
	jra .L3
	.size	ext_engine_text, .-ext_engine_text
	.align	2
	.type	copy_desc, @function
copy_desc:
	move.l %a2,-(%sp)
	moveq #84,%d1
	move.l 8(%sp),%d0
	sub.l %a0,%a0
	muls.l %d1,%d0
	move.l %d0,%a1
	add.l #1100630152,%a1
	move.w 14(%sp),%d0
	mulu.w #84,%d0
	add.l #1100630152,%d0
.L5:
	lea (%a0,%d0.l),%a2
	moveq #84,%d1
	move.l (%a2),(%a1,%a0.l)
	addq.l #4,%a0
	cmp.l %a0,%d1
	jne .L5
	move.l (%sp)+,%a2
	rts
	.size	copy_desc, .-copy_desc
	.section	.ext5,"ax",@progbits
	.align	2
	.globl	dsp_engine_text
	.type	dsp_engine_text, @function
dsp_engine_text:
	move.l %d2,-(%sp)
	move.l 12(%sp),%d0
	mov3q.l #3,%d2
	move.l 16(%sp),%d1
	muls.l %d2,%d0
	moveq #15,%d2
	asr.l %d2,%d0
	mov3q.l #2,%d2
	cmp.l %d0,%d2
	jge .L8
	mov3q.l #2,%d0
.L9:
	mvz.w %d0,%d0
	move.l %d1,8(%sp)
	lsl.l #3,%d0
	add.l #dsp_engine_names,%d0
	move.l %d0,16(%sp)
	move.l #ext_fmt_s,%d0
	move.l %d0,12(%sp)
	move.l (%sp)+,%d2
	jmp 1074365954
.L8:
	tst.l %d0
	jge .L9
	clr.l %d0
	jra .L9
	.size	dsp_engine_text, .-dsp_engine_text
	.align	2
	.globl	dsp_input_text
	.type	dsp_input_text, @function
dsp_input_text:
	move.l %d2,-(%sp)
	moveq #11,%d2
	move.l 12(%sp),%d0
	move.l 16(%sp),%d1
	muls.l %d2,%d0
	moveq #15,%d2
	asr.l %d2,%d0
	moveq #10,%d2
	cmp.l %d0,%d2
	jge .L11
	moveq #10,%d0
.L12:
	mulu.w #6,%d0
	move.l %d1,8(%sp)
	add.l #dsp_input_names,%d0
	move.l %d0,16(%sp)
	move.l #ext_fmt_s,%d0
	move.l %d0,12(%sp)
	move.l (%sp)+,%d2
	jmp 1074365954
.L11:
	tst.l %d0
	jge .L12
	clr.l %d0
	jra .L12
	.size	dsp_input_text, .-dsp_input_text
	.section	.ext4,"ax",@progbits
	.align	2
	.type	ext_view_machine, @function
ext_view_machine:
	move.l %a2,-(%sp)
	move.l 8(%sp),%a2
	move.l (%a2),%a0
	move.l %a2,-(%sp)
	move.l 144(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	tst.l %d0
	jge .L14
	move.l 116(%a2),-(%sp)
	jsr 1074489554
	move.l %d0,-(%sp)
	move.l 120(%a2),-(%sp)
	jsr 1074423646
	lea (12,%sp),%sp
.L15:
	move.l %d0,8(%sp)
	move.l (%sp)+,%a2
	jmp 1074514544
.L14:
	move.l %d0,-(%sp)
	move.l 104(%a2),-(%sp)
	jsr 1074455700
	addq.l #8,%sp
	jra .L15
	.size	ext_view_machine, .-ext_view_machine
	.section	.extd,"ax",@progbits
	.align	2
	.type	dd_name_knobs, @function
dd_name_knobs:
	move.w 6(%sp),%d0
	move.l #1075595396,%a0
	mulu.w #7,%d0
	move.l %d0,%a1
	add.l #dd_label,%a1
.L17:
	mvz.b (%a1)+,%d0
	lea (52,%a0),%a0
	mulu.w #5,%d0
	move.l %d0,%d1
	add.l #dd_pool,%d1
	move.l %d1,-4(%a0)
	move.l %d1,-12(%a0)
	cmp.l #1075595760,%a0
	jne .L17
	rts
	.size	dd_name_knobs, .-dd_name_knobs
	.align	2
	.globl	dd_engine_text
	.type	dd_engine_text, @function
dd_engine_text:
	subq.l #4,%sp
	move.l %d2,-(%sp)
	moveq #11,%d0
	move.l 16(%sp),%d2
	move.l 20(%sp),4(%sp)
	muls.l %d0,%d2
	moveq #15,%d0
	asr.l %d0,%d2
	moveq #10,%d0
	cmp.l %d2,%d0
	jge .L20
	moveq #10,%d2
.L21:
	move.l %d2,-(%sp)
	mulu.w #7,%d2
	jsr dd_name_knobs
	addq.l #4,%sp
	move.l 4(%sp),12(%sp)
	move.l #ext_fmt_s,%d0
	move.l %d0,16(%sp)
	add.l #dd_names,%d2
	move.l %d2,20(%sp)
	move.l (%sp)+,%d2
	addq.l #4,%sp
	jmp 1074365954
.L20:
	tst.l %d2
	jge .L21
	clr.l %d2
	jra .L21
	.size	dd_engine_text, .-dd_engine_text
	.section	.ext7,"ax",@progbits
	.align	2
	.globl	dsp_out_text
	.type	dsp_out_text, @function
dsp_out_text:
	move.w #16383,%a0
	move.l 12(%sp),%d1
	cmp.l 8(%sp),%a0
	slt %d0
	neg.l %d0
	tst.b %d0
	jeq .L23
	mov3q.l #6,%d0
.L24:
	add.l #dsp_out_names,%d0
	move.l %d0,12(%sp)
	move.l #ext_fmt_s,%d0
	move.l %d0,8(%sp)
	move.l %d1,4(%sp)
	jmp 1074365954
.L23:
	clr.l %d0
	jra .L24
	.size	dsp_out_text, .-dsp_out_text
	.section	.exto,"ax",@progbits
	.align	2
	.type	mod_text, @function
mod_text:
	lea (-16,%sp),%sp
	move.l 24(%sp),%d1
	move.l %d1,%d0
	lsl.l #3,%d0
	movem.l #3084,(%sp)
	move.l 28(%sp),%a0
	mov3q.l #6,%d3
	sub.l %d1,%d0
	moveq #15,%d1
	asr.l %d1,%d0
	cmp.l %d0,%d3
	jge .L26
	mov3q.l #6,%d0
.L27:
	move.l %d0,%a3
	moveq #10,%d3
	lea (%a3,%d0.l*2),%a1
	lea mod_label,%a2
	move.b (%a1,%a2.l),%d1
	mvz.b %d1,%d2
	cmp.l %d2,%d3
	jcs .L31
	ext.w %d1
	mvz.w %d1,%d1
	lsl.l #2,%d1
	add.l #mod_pool,%d1
.L28:
	move.l %d1,1075598252
	moveq #10,%d3
	move.l %d1,1075598244
	move.b 1(%a2,%a1.l),%d1
	mvz.b %d1,%d2
	cmp.l %d2,%d3
	jcs .L32
	ext.w %d1
	mvz.w %d1,%d1
	lsl.l #2,%d1
	add.l #mod_pool,%d1
.L29:
	move.l %d1,1075598304
	moveq #10,%d3
	move.l %d1,1075598296
	move.b 2(%a2,%a1.l),%d1
	mvz.b %d1,%d2
	cmp.l %d2,%d3
	jcs .L33
	ext.w %d1
	mvz.w %d1,%d1
	lsl.l #2,%d1
	add.l #mod_pool,%d1
.L30:
	move.l %d1,1075598356
	move.l %d1,1075598348
	lea ext_fmt_s,%a3
	move.l %a3,24(%sp)
	mulu.w #6,%d0
	move.l %a0,20(%sp)
	movem.l (%sp),#3084
	add.l #mod_names,%d0
	move.l %d0,28(%sp)
	lea (16,%sp),%sp
	jmp 1074365954
.L26:
	tst.l %d0
	jge .L27
	clr.l %d0
	jra .L27
.L31:
	move.l #jn_empty,%d1
	jra .L28
.L32:
	move.l #jn_empty,%d1
	jra .L29
.L33:
	move.l #jn_empty,%d1
	jra .L30
	.size	mod_text, .-mod_text
	.section	.extx,"ax",@progbits
	.align	2
	.type	us_copy, @function
us_copy:
	move.l %a2,-(%sp)
	move.l 8(%sp),%a0
	clr.l %d0
	move.l 12(%sp),%a1
.L35:
	lea (%a1,%d0.l),%a2
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l 16(%sp),%d0
	jne .L35
	move.l (%sp)+,%a2
	rts
	.size	us_copy, .-us_copy
	.section	.extz,"ax",@progbits
	.align	2
	.type	us_zero, @function
us_zero:
	move.l 4(%sp),%a0
	clr.l %d0
.L38:
	clr.b %d1
	move.b %d1,(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l 8(%sp),%d0
	jne .L38
	rts
	.size	us_zero, .-us_zero
	.section	.exty,"ax",@progbits
	.align	2
	.type	us_text_in, @function
us_text_in:
	move.l 4(%sp),%a0
	clr.l %d0
	move.l 8(%sp),%a1
.L41:
	move.b (%a1,%d0.l),%d1
	jeq .L42
	move.b %d1,(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l 12(%sp),%d0
	jne .L41
.L42:
	clr.b %d1
	move.b %d1,(%a0,%d0.l)
	rts
	.size	us_text_in, .-us_text_in
	.section	.us1,"ax",@progbits
	.align	2
	.type	us_pool_text, @function
us_pool_text:
	tst.l 4(%sp)
	jne .L46
	pea us_off
.L57:
	pea ext_fmt_s
.L56:
	move.l 16(%sp),-(%sp)
	jsr 1074365954
	lea (12,%sp),%sp
	rts
.L46:
	move.l #1413763670,%d0
	cmp.l 1075550836.l,%d0
	jne .L48
	tst.l 1075550844
	jeq .L48
	move.l 1075550844,%a0
	jsr (%a0)
	tst.l %d0
	jeq .L48
	move.w 6(%sp),%d1
	move.l %d0,%a1
	muls.w #18,%d1
	lea 4(%a1,%d1.l),%a0
	tst.b (%a0)
	jne .L49
	lea us_none,%a0
.L49:
	move.l %a0,-(%sp)
	jra .L57
.L48:
	move.l 4(%sp),-(%sp)
	pea us_fmt_d
	jra .L56
	.size	us_pool_text, .-us_pool_text
	.align	2
	.type	us_record, @function
us_record:
	lea (-12,%sp),%sp
	move.l 20(%sp),%d0
	movem.l #3076,(%sp)
	lea us,%a0
	move.l (%a0,%d0.l*4),%a2
	move.l 24(%sp),%d2
	tst.l %a2
	jeq .L59
	tst.b (%a2)
	jne .L60
.L61:
	sub.l %a2,%a2
.L59:
	move.l 16(%sp),%d0
	moveq #52,%d1
	muls.l %d1,%d0
	move.l %d0,%a3
	add.l #1075575064,%a3
	tst.l %a2
	jeq .L67
	move.b 1(%a2),%d0
	mov3q.l #3,%d1
	and.l %d1,%d0
.L62:
	lea us_look_rec,%a0
	mvs.w (%a0,%d0.l*2),%d0
	move.l %d0,-(%sp)
	move.l 20(%sp),-(%sp)
	jsr copy_desc
	move.l 24(%sp),%d0
	moveq #84,%d1
	lea (36,%sp),%a1
	addq.l #8,%sp
	move.l #1100630184,%a0
	muls.l %d1,%d0
	move.l (%a1),(%a0,%d0.l)
	tst.l %a2
	jeq .L63
	move.l %a2,%d0
	addq.l #8,%d0
.L64:
	move.l %d0,40(%a3)
	lea us_snames,%a0
	move.l 20(%sp),%d0
	lea (%a0,%d0.l*4),%a1
	move.l (%a1),44(%a3)
	tst.l %a2
	jeq .L65
	lea (21,%a2),%a0
	move.l %a0,48(%a3)
	mvz.b 4(%a2),%d0
	lsl.l #8,%d0
	move.l %d0,8(%a3)
	mvz.b 5(%a2),%d0
	lsl.l #8,%d0
	move.l %d0,12(%a3)
	mvz.b 6(%a2),%d0
	lsl.l #8,%d0
.L66:
	move.l %d0,16(%a3)
	movem.l (%sp),#3076
	lea (12,%sp),%sp
	rts
.L60:
	moveq #28,%d0
	muls.l %d2,%d0
	tst.b 36(%a2,%d0.l)
	jeq .L61
	move.w %d2,%d0
	mulu.w #28,%d0
	lea 36(%a2,%d0.l),%a2
	jra .L59
.L67:
	clr.l %d0
	jra .L62
.L63:
	mvz.w %d2,%d0
	lsl.l #2,%d0
	add.l #us_pn,%d0
	jra .L64
.L65:
	mvz.w %d2,%d2
	move.w #32512,%a1
	mvz.w #16384,%d0
	clr.l 8(%a3)
	lsl.l #2,%d2
	move.l %a1,12(%a3)
	add.l #us_pn,%d2
	move.l %d2,48(%a3)
	jra .L66
	.size	us_record, .-us_record
	.align	2
	.type	us_params, @function
us_params:
	move.l 4(%sp),%d0
	lea us,%a0
	move.l (%a0,%d0.l*4),%a0
	tst.l %a0
	jne .L72
.L74:
	clr.l %d0
.L71:
	rts
.L72:
	tst.b (%a0)
	jeq .L74
	mvz.b 1(%a0),%d0
	mov3q.l #1,%d1
	cmp.l %d0,%d1
	jne .L74
	move.b 2(%a0),%d0
	and.l %d1,%d0
	jra .L71
	.size	us_params, .-us_params
	.section	.us2,"ax",@progbits
	.align	2
	.type	us_meta_in, @function
us_meta_in:
	lea (-40,%sp),%sp
	movem.l #7420,(%sp)
	move.l us+20,%a2
	move.l 44(%sp),%a3
	move.l 48(%sp),%d2
	tst.l %a2
	jeq .L75
	move.b 6(%a3),%d5
	mov3q.l #4,%d1
	mvz.b %d5,%d4
	move.l %d4,%d0
	subq.l #1,%d0
	cmp.l %d0,%d1
	jcs .L75
	move.b 3(%a2),%d1
	mvz.b %d1,%d0
	cmp.l #255,%d0
	jeq .L75
	mvz.b 8(%a3),%d3
	moveq #127,%d7
	cmp.l %d3,%d7
	jeq .L75
	move.b 7(%a3),%d0
	tst.l %d3
	jne .L77
	moveq #40,%d1
	cmp.l %d2,%d1
	jge .L75
	move.b 12(%a3),%d1
	mov3q.l #4,%d3
	subq.l #1,%d1
	mvz.b %d1,%d1
	cmp.l %d1,%d3
	jcs .L75
	move.b %d0,1(%a2)
	move.b %d5,(%a2)
	moveq #1,%d4
	lea us_text_in,%a4
	moveq #42,%d5
	move.b 12(%a3),2(%a2)
	move.b %d0,4(%a2)
	move.b %d4,3(%a2)
	move.b 9(%a3),5(%a2)
	move.b 10(%a3),6(%a2)
	move.b 11(%a3),7(%a2)
	pea 10.w
	pea 13(%a3)
	pea 8(%a2)
	jsr (%a4)
	mov3q.l #4,-(%sp)
	pea 23(%a3)
	pea 19(%a2)
	jsr (%a4)
	pea 13.w
	pea 27(%a3)
	pea 24(%a2)
	jsr (%a4)
	lea (36,%sp),%sp
	cmp.l %d2,%d5
	jge .L86
	mvz.b 40(%a3),%d0
	move.b 41(%a3),%d1
	lsl.l #7,%d0
	and.l %d7,%d1
	and.l #16256,%d0
	or.l %d1,%d0
.L78:
	move.w %d0,38(%a2)
	move.l %a2,%d0
	add.l #488,%d0
	lea (40,%a2),%a0
.L79:
	clr.b (%a0)
	lea (28,%a0),%a0
	cmp.l %d0,%a0
	jne .L79
.L80:
	mvz.b 2(%a2),%d1
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	mvz.b 3(%a2),%d1
	subq.l #1,%d0
	mvz.b %d0,%d0
	cmp.l %d1,%d0
	jne .L75
	st %d7
	move.b %d7,3(%a2)
.L75:
	movem.l (%sp),#7420
	lea (40,%sp),%sp
	rts
.L86:
	clr.w %d0
	jra .L78
.L77:
	mvz.b (%a2),%d5
	cmp.l %d4,%d5
	jne .L75
	mvz.b %d0,%d0
	mvz.b 1(%a2),%d4
	cmp.l %d0,%d4
	jne .L75
	btst #0,%d1
	jeq .L75
	mvz.b 2(%a2),%d0
	cmp.l %d3,%d0
	jls .L75
	moveq #10,%d7
	cmp.l %d2,%d7
	jge .L75
	move.l %d2,%d0
	moveq #24,%d4
	add.l #-10,%d0
	rems.l %d4,%d1:%d0
	tst.l %d1
	jne .L75
	subq.l #1,%d2
	move.l %d2,36(%sp)
	moveq #32,%d4
	lea (9,%a3),%a3
	lea us_text_in,%a4
.L81:
	cmp.l 36(%sp),%d4
	jlt .L85
	mov3q.l #1,%d0
	move.b 3(%a2),%d1
	lsl.l %d3,%d0
	or.l %d1,%d0
	move.b %d0,3(%a2)
	jra .L80
.L85:
	move.b (%a3),%d1
	move.l %d1,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	lsr.l #4,%d0
	jne .L82
	mvz.b %d1,%d2
	moveq #28,%d0
	subq.l #1,%d2
	muls.l %d2,%d0
	lea (%a2,%d0.l),%a0
	move.b %d1,40(%a0)
	move.b 1(%a3),41(%a0)
	move.b 2(%a3),42(%a0)
	move.b 3(%a3),43(%a0)
	move.b 4(%a3),%d5
	move.b %d5,44(%a0)
	mvz.b %d5,%d7
	move.b 5(%a3),%d1
	mvz.b %d1,%d6
	cmp.l %d6,%d7
	jls .L83
	move.b %d5,%d1
.L83:
	move.b %d1,45(%a0)
	lea (%a2,%d0.l),%a0
	moveq #16,%d5
	move.b 6(%a3),46(%a0)
	move.b 7(%a3),%d0
	mvz.b %d0,%d1
	cmp.l %d1,%d5
	jcc .L84
	moveq #16,%d0
.L84:
	move.b %d0,47(%a0)
	mulu.w #28,%d2
	pea 12.w
	pea 8(%a3)
	pea 48(%a2,%d2.l)
	jsr (%a4)
	mov3q.l #4,-(%sp)
	pea 20(%a3)
	pea 61(%a2,%d2.l)
	jsr (%a4)
	lea (24,%sp),%sp
.L82:
	add.l #24,%d4
	lea (24,%a3),%a3
	jra .L81
	.size	us_meta_in, .-us_meta_in
	.align	2
	.type	us_list_in, @function
us_list_in:
	lea (-28,%sp),%sp
	moveq #11,%d0
	movem.l #3196,(%sp)
	move.l 36(%sp),%d5
	move.l 32(%sp),%a2
	cmp.l %d5,%d0
	jge .L100
	move.b 7(%a2),%d4
	move.b 6(%a2),%d0
	moveq #15,%d3
	mvz.b %d4,%d2
	mvz.b %d0,%d1
	move.l %d2,%a0
	move.b 8(%a2),%d2
	subq.l #1,%d1
	cmp.l %a0,%d3
	jlt .L102
	mov3q.l #4,%d6
	cmp.l %d1,%d6
	jcs .L100
	lea us,%a1
	move.l (%a1,%d1.l*4),%a3
	tst.l %a3
	jeq .L100
	mvz.b %d2,%d3
	mvz.b (%a3),%d0
	cmp.l %d3,%d0
	jne .L100
	clr.l %d2
	lea (484,%a3),%a1
.L103:
	mvz.b (%a1,%d2.l),%d0
	cmp.l %a0,%d0
	jeq .L104
	addq.l #1,%d2
	moveq #8,%d0
	cmp.l %d2,%d0
	jne .L103
.L104:
	move.b 9(%a2),%d0
	moveq #8,%d1
	cmp.l %d2,%d1
	jne .L106
	tst.b %d0
	jeq .L100
	clr.l %d2
.L107:
	mvz.b (%a1,%d2.l),%d0
	cmp.l #255,%d0
	jne .L108
.L109:
	mvz.w %d2,%d0
	pea 128.w
	moveq #16,%d6
	lsl.l #7,%d0
	add.l #500,%d0
	pea (%a3,%d0.l)
	jsr us_zero
	move.b 10(%a2),%d0
	addq.l #8,%sp
	lea (%a3,%d2.l),%a0
	mvz.b %d0,%d1
	cmp.l %d1,%d6
	jcc .L111
	moveq #16,%d0
.L111:
	move.b %d0,492(%a0)
	move.b %d4,484(%a0)
	jra .L110
.L108:
	addq.l #1,%d2
	moveq #8,%d6
	cmp.l %d2,%d6
	jne .L107
.L100:
	movem.l (%sp),#3196
	lea (28,%sp),%sp
	rts
.L106:
	tst.b %d0
	jne .L109
.L110:
	move.l %d5,%d1
	move.l %d2,%d5
	lsl.l #4,%d5
	subq.l #1,%d1
	lea (11,%a2),%a2
	moveq #12,%d4
.L112:
	move.l %d4,%d0
	add.l #12,%d0
	cmp.l %d1,%d0
	jlt .L117
	mvz.b (%a3),%d0
	cmp.l %d3,%d0
	jeq .L100
	st %d0
	add.l %d2,%a3
	move.b %d0,484(%a3)
	jra .L100
.L117:
	mvz.b (%a2),%d0
	moveq #15,%d6
	cmp.l %d0,%d6
	jcs .L113
	add.l %d5,%d0
	mvz.w %d0,%d0
	sub.l %a1,%a1
	lsl.l #3,%d0
	move.l %d0,%a0
	lea (500,%a0),%a0
	add.l %a3,%a0
.L114:
	move.b 1(%a2,%a1.l),%d0
	jeq .L115
	move.b %d0,(%a0,%a1.l)
	addq.l #1,%a1
	mov3q.l #7,%d0
	cmp.l %a1,%d0
	jne .L114
.L115:
	clr.b %d6
	move.b %d6,(%a0,%a1.l)
.L113:
	add.l #14,%d4
	lea (14,%a2),%a2
	jra .L112
.L102:
	moveq #33,%d3
	cmp.l %a0,%d3
	jeq .L129
	moveq #32,%d4
	cmp.l %a0,%d4
	jne .L100
	mov3q.l #4,%d6
	cmp.l %d1,%d6
	jcs .L100
	add.l #16,%d0
	tst.b %d0
	jeq .L100
.L118:
	tst.b 9(%a2)
	jeq .L119
	lea jn_mailbox+37,%a0
	moveq #127,%d1
.L120:
	clr.b (%a0)
	subq.l #1,%d1
	lea (10,%a0),%a0
	tst.l %d1
	jne .L120
	move.b 10(%a2),%d1
	jpl .L121
	moveq #127,%d1
.L121:
	move.b %d0,jn_mailbox+19
	moveq #1,%d0
	move.b %d1,jn_mailbox+9
	move.b %d2,jn_mailbox+20
	move.b %d0,jn_mailbox+8
.L122:
	move.l %d5,%d1
	moveq #12,%d2
	subq.l #1,%d1
	lea (11,%a2),%a2
.L123:
	move.l %d2,%d0
	add.l #12,%d0
	cmp.l %d1,%d0
	jge .L100
	move.b (%a2),%d0
	moveq #126,%d4
	mvz.b %d0,%d3
	cmp.l %d3,%d4
	jcs .L124
	ext.w %d0
	sub.l %a1,%a1
	mulu.w #10,%d0
	move.l %d0,%a0
	add.l #jn_mailbox+37,%a0
.L125:
	move.b 1(%a2,%a1.l),%d0
	jeq .L126
	move.b %d0,(%a0,%a1.l)
	addq.l #1,%a1
	moveq #9,%d6
	cmp.l %a1,%d6
	jne .L125
.L126:
	clr.b %d0
	move.b %d0,(%a0,%a1.l)
.L124:
	add.l #14,%d2
	lea (14,%a2),%a2
	jra .L123
.L129:
	moveq #32,%d0
	jra .L118
.L119:
	mvz.b %d0,%d0
	mvz.b jn_mailbox+19,%d1
	cmp.l %d0,%d1
	jne .L100
	mvz.b %d2,%d2
	mvz.b jn_mailbox+20,%d0
	cmp.l %d2,%d0
	jne .L100
	jra .L122
	.size	us_list_in, .-us_list_in
	.align	2
	.type	us_knobs_in, @function
us_knobs_in:
	move.l us+24,%a0
	lea (-24,%sp),%sp
	movem.l #1148,(%sp)
	move.l 28(%sp),%a1
	tst.l %a0
	jeq .L155
	move.b 6(%a1),%d0
	mov3q.l #7,%d1
	moveq #11,%d2
	and.l %d1,%d0
	move.l #1076432344,%d1
	move.l %d0,%a2
	move.b (%a2,%d1.l),%d0
	mvz.b %d0,%d1
	cmp.l %d1,%d2
	jcs .L155
	move.b 7(%a1),%d3
	mov3q.l #4,%d4
	move.l %d3,%d1
	subq.l #1,%d1
	mvz.b %d1,%d1
	cmp.l %d1,%d4
	jcs .L155
	mvz.b 8(%a1),%d2
	moveq #16,%d6
	cmp.l %d2,%d6
	jlt .L155
	move.l %d2,%d1
	addq.l #5,%d1
	add.l %d1,%d1
	cmp.l 32(%sp),%d1
	jgt .L155
	ext.w %d0
	mov3q.l #1,%d1
	lea (9,%a1),%a1
	mulu.w #28,%d0
	add.l %d0,%a0
	move.b 1(%a0),%d0
	or.l %d1,%d0
	clr.l %d1
	move.b %d0,1(%a0)
	move.b %d3,(%a0)
	clr.l %d3
.L157:
	cmp.l %d3,%d2
	jgt .L158
	move.w %d1,4(%a0)
	move.b 1(%a0),%d0
	addq.l #1,%d0
	move.b %d0,1(%a0)
.L155:
	movem.l (%sp),#1148
	lea (24,%sp),%sp
	rts
.L158:
	move.b (%a1),%d0
	moveq #15,%d4
	moveq #127,%d6
	addq.l #1,%d3
	addq.l #2,%a1
	and.l %d4,%d0
	move.b -1(%a1),%d4
	and.l %d6,%d4
	move.b %d4,6(%a0,%d0.l)
	mov3q.l #1,%d4
	lsl.l %d0,%d4
	or.l %d4,%d1
	jra .L157
	.size	us_knobs_in, .-us_knobs_in
	.align	2
	.type	us_slots_in, @function
us_slots_in:
	move.l %a2,-(%sp)
	moveq #12,%d0
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	move.l 12(%sp),%a0
	cmp.l %d1,%d0
	jge .L162
	clr.l %d0
	lea us+28,%a1
.L164:
	lea 6(%a0,%d0.l),%a2
	mov3q.l #5,%d2
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d2
	jne .L164
	moveq #1,%d0
	lea (11,%a0),%a1
	moveq #14,%d2
	move.b (%a1),us+33
	move.b %d0,us+34
	cmp.l %d1,%d2
	jge .L162
	move.b 12(%a0),%d0
	mov3q.l #4,%d1
	subq.l #1,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jcs .L162
	lea (13,%a0),%a1
	move.b (%a1),us+47
	lea (12,%a0),%a0
	move.b (%a0),us+46
.L162:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
	.size	us_slots_in, .-us_slots_in
	.section	.us6,"ax",@progbits
	.align	2
	.type	us_names, @function
us_names:
	lea (-12,%sp),%sp
	move.l 16(%sp),%d0
	lea us_lnames,%a0
	movem.l #3076,(%sp)
	move.l (%a0,%d0.l*4),%a1
	lea us_snames,%a0
	move.l (%a0,%d0.l*4),%a2
	lea us,%a0
	move.l (%a0,%d0.l*4),%a0
	tst.l %a0
	jeq .L167
	tst.b (%a0)
	jne .L168
.L167:
	move.l %d0,%d2
	addq.l #1,%d2
	move.l %d2,-(%sp)
	pea us_fmt_user
	move.l %a1,-(%sp)
	jsr 1074365954
	move.l %d2,-(%sp)
	pea us_fmt_u
.L200:
	move.l %a2,-(%sp)
	jsr 1074365954
	lea (24,%sp),%sp
.L166:
	movem.l (%sp),#3076
	lea (12,%sp),%sp
	rts
.L168:
	move.b 1(%a0),%d1
	jne .L170
	move.l %d0,%d2
	addq.l #1,%d2
	move.l %d2,-(%sp)
	pea us_fmt_empty
	move.l %a1,-(%sp)
	jsr 1074365954
	move.l %d2,-(%sp)
	pea us_fmt_uempty
	jra .L200
.L170:
	mvz.b %d1,%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L171
	mvz.b us+53,%d1
	addq.l #1,%d0
	cmp.l %d1,%d0
	jne .L184
.L171:
	move.b #33,(%a2)
	move.b #33,(%a1)
	clr.l %d0
.L178:
	move.b 4(%a0,%d0.l),%d1
	jeq .L179
	addq.l #1,%d0
	move.b %d1,(%a1,%d0.l)
	moveq #10,%d1
	cmp.l %d0,%d1
	jne .L178
.L179:
	clr.b %d2
	move.b %d2,1(%a1,%d0.l)
	clr.l %d0
.L181:
	move.b 15(%a0,%d0.l),%d1
	jeq .L182
	addq.l #1,%d0
	move.b %d1,(%a2,%d0.l)
	mov3q.l #3,%d1
	cmp.l %d0,%d1
	jne .L181
.L182:
	clr.b %d2
	move.b %d2,1(%a2,%d0.l)
	jra .L166
.L184:
	clr.l %d0
.L172:
	move.b 4(%a0,%d0.l),%d1
	jeq .L173
	move.b %d1,(%a1,%d0.l)
	addq.l #1,%d0
	moveq #10,%d1
	cmp.l %d0,%d1
	jne .L172
.L173:
	clr.b %d2
	move.b %d2,(%a1,%d0.l)
	clr.l %d0
.L175:
	move.b 15(%a0,%d0.l),%d1
	jeq .L176
	move.b %d1,(%a2,%d0.l)
	addq.l #1,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L175
.L176:
	clr.b %d2
	move.b %d2,(%a2,%d0.l)
	jra .L166
	.size	us_names, .-us_names
	.section	.us2
	.align	2
	.type	us_has_enum, @function
us_has_enum:
	move.l 4(%sp),%d0
	move.l %d0,%a0
	lea (484,%a0),%a0
	add.l #492,%d0
.L203:
	mvz.b (%a0),%d1
	cmp.l 8(%sp),%d1
	jeq .L204
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L203
	clr.l %d0
.L201:
	rts
.L204:
	mov3q.l #1,%d0
	jra .L201
	.size	us_has_enum, .-us_has_enum
	.section	.us6
	.align	2
	.type	us_kit_sound, @function
us_kit_sound:
	move.l %d3,-(%sp)
	move.l -2147457096,%a0
	move.l %d2,-(%sp)
	mvz.b us+52,%d1
	mvz.b 23(%sp),%d0
	cmp.l %d1,%d0
	jne .L211
	move.l 12(%sp),%a1
	add.l #-2147423744,%a1
	mvz.b (%a1),%d1
	move.l 16(%sp),%d0
	add.l #35,%d0
	cmp.l %d1,%d0
	jeq .L208
.L211:
	clr.l %d0
	jra .L206
.L208:
	move.l -2147418996,%d0
	cmp.l %d0,%a0
	jne .L211
	moveq #127,%d2
	and.l %d2,%d0
	mvz.w #152,%d2
	move.l 12(%sp),%d3
	muls.l %d2,%d3
	mulu.w #2531,%d0
	add.l #1092966689,%d0
	add.l %d3,%d0
	move.l %d0,%a1
	mvz.b 84(%a1),%d3
	cmp.l %d1,%d3
	jne .L211
.L206:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
	.size	us_kit_sound, .-us_kit_sound
	.section	.us8,"ax",@progbits
	.align	2
	.type	us_untag, @function
us_untag:
	move.l %d2,-(%sp)
#APP
| 1980 "ext.c" 1
	move.w %sr,%d2
	move.l %d2,%d1
	ori.l #0x0700,%d1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
	mvz.b us+52,%d0
	move.l %d0,-(%sp)
	move.l 16(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	jsr us_kit_sound
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L213
	clr.b %d1
	move.l %d0,%a0
	clr.w %d0
	move.b %d1,90(%a0)
	move.b %d1,91(%a0)
	move.l 8(%sp),%d1
	lea us_tag,%a0
	move.w %d0,(%a0,%d1.l*2)
	move.l %d1,%d0
	mvz.w #162,%d1
	muls.l %d1,%d0
	move.l %d0,%a0
	add.l #1081497997,%a0
	clr.b (%a0)
	addq.l #1,%a0
	clr.b (%a0)
.L213:
#APP
| 1988 "ext.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	move.l (%sp)+,%d2
	rts
	.size	us_untag, .-us_untag
	.align	2
	.type	us_pend, @function
us_pend:
	move.l %d2,-(%sp)
	moveq #11,%d1
	move.l 8(%sp),%d0
	cmp.l %d0,%d1
	jcs .L217
	move.l #-2147423744,%a0
	move.b (%a0,%d0.l),%d1
	mvz.b %d1,%d2
	move.l %d2,%a0
	mov3q.l #4,%d2
	lea (-35,%a0),%a0
	cmp.l %a0,%d2
	jcs .L217
	move.l us+24,%a0
	tst.l %a0
	jeq .L217
	moveq #28,%d2
	add.l #-34,%d1
	muls.l %d2,%d0
	move.l #1100784300,%a1
	add.l %d0,%a0
	clr.b %d0
	move.b %d1,3(%a0)
	move.b %d0,22(%a0)
	move.l (%a1),24(%a0)
.L217:
	move.l (%sp)+,%d2
	rts
	.size	us_pend, .-us_pend
	.align	2
	.type	us_choose, @function
us_choose:
	move.l %a2,-(%sp)
	moveq #11,%d0
	move.l %d2,-(%sp)
	move.l 12(%sp),%a2
	cmp.l %a2,%d0
	jcs .L225
	move.l #-2147423744,%a0
	mvz.b (%a2,%a0.l),%d2
	add.l #-35,%d2
.L223:
	move.l %a2,-(%sp)
	jsr us_pend
	addq.l #4,%sp
	mov3q.l #4,%d0
	cmp.l %d2,%d0
	jcs .L222
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr us_untag
	addq.l #8,%sp
.L222:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L225:
	mov3q.l #-1,%d2
	jra .L223
	.size	us_choose, .-us_choose
	.section	.us4,"ax",@progbits
	.align	2
	.type	us_popup, @function
us_popup:
	link.w %fp,#-24
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	pea -17(%fp)
	move.l 12(%fp),-(%sp)
	move.l %fp,%d3
	add.l #-16,%d3
	move.l %d3,-(%sp)
	jsr 1075563852
	pea 160.w
	jsr 1074276820
	pea 16.w
	move.l %d0,%d2
	jsr 1074276820
	lea (20,%sp),%sp
	move.l %d0,-24(%fp)
	tst.l %d2
	jeq .L227
	tst.l %d0
	jeq .L227
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	jsr 1074226920
	move.l -24(%fp),%a0
	move.l #1075628724,(%a0)
	mov3q.l #1,4(%a0)
	mov3q.l #1,8(%a0)
	move.l %d2,12(%a0)
	move.l %a0,-4(%fp)
	clr.l -(%sp)
	pea -8(%fp)
	move.l %d2,-8(%fp)
	move.l 8(%fp),%a0
	move.l 100(%a0),-(%sp)
	jsr 1074238454
	pea -4(%fp)
	jsr 1075251724
	lea (24,%sp),%sp
.L227:
	move.l %d3,-(%sp)
	jsr 1075557020
	move.l -32(%fp),%d2
	addq.l #4,%sp
	move.l -28(%fp),%d3
	unlk %fp
	rts
	.size	us_popup, .-us_popup
	.section	.us3,"ax",@progbits
	.align	2
	.type	us_same, @function
us_same:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 12(%sp),%a0
	clr.l %d0
	move.l 16(%sp),%a1
.L237:
	mvs.b (%a1,%d0.l),%d2
	move.b (%a0,%d0.l),%d1
	mvs.b %d1,%d3
	cmp.l %d3,%d2
	jne .L239
	tst.b %d1
	jne .L236
.L238:
	mov3q.l #1,%d0
.L234:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L236:
	addq.l #1,%d0
	moveq #9,%d1
	cmp.l %d0,%d1
	jne .L237
	jra .L238
.L239:
	clr.l %d0
	jra .L234
	.size	us_same, .-us_same
	.section	.us1
	.align	2
	.type	us_slot_records, @function
us_slot_records:
	lea (-16,%sp),%sp
	movem.l #7172,(%sp)
	move.l 20(%sp),%d2
	sub.l %a2,%a2
	lea us_record,%a4
	mvz.w %d2,%d0
	lsl.l #3,%d0
	move.l %d0,%a3
	lea (334,%a3),%a3
.L242:
	pea us_text
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	pea (%a3,%a2.l)
	jsr (%a4)
	addq.l #1,%a2
	lea (16,%sp),%sp
	moveq #8,%d0
	cmp.l %a2,%d0
	jne .L242
	move.l %d2,20(%sp)
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	jra us_src_table
	.size	us_slot_records, .-us_slot_records
	.section	.us2
	.align	2
	.type	us_commit, @function
us_commit:
	lea (-24,%sp),%sp
	mov3q.l #4,%d0
	movem.l #15372,(%sp)
	move.l us+20,%a3
	lea us,%a4
	mvz.b (%a3),%d3
	move.l %d3,%d2
	subq.l #1,%d2
	cmp.l %d2,%d0
	jcs .L245
	move.l (%a4,%d2.l*4),%a2
	tst.l %a2
	jeq .L245
	pea 36.w
	pea 4(%a3)
	move.l %a2,-(%sp)
	lea us_copy,%a5
	jsr (%a5)
	pea 448.w
	pea 40(%a3)
	pea 36(%a2)
	jsr (%a5)
	mov3q.l #-1,484(%a2)
	mov3q.l #-1,488(%a2)
	lea (24,%sp),%sp
	mvz.b 1(%a2),%d0
	mov3q.l #1,%d1
	cmp.l %d0,%d1
	jne .L248
	move.b 2(%a2),%d0
	not.l %d0
	and.l %d1,%d0
.L246:
	move.b %d0,41(%a4,%d2.l)
	move.l %d2,-(%sp)
	jsr us_names
	move.l %d2,-(%sp)
	jsr us_slot_records
	addq.l #8,%sp
	mvz.b us+48,%d0
	cmp.l %d3,%d0
	jne .L247
	clr.b %d0
	move.b %d0,us+48
.L247:
	clr.b %d1
	move.b %d1,35(%a4,%d2.l)
.L245:
	clr.b %d0
	move.b %d0,3(%a3)
	movem.l (%sp),#15372
	lea (24,%sp),%sp
	rts
.L248:
	clr.l %d0
	jra .L246
	.size	us_commit, .-us_commit
	.align	2
	.type	us_init, @function
us_init:
	lea (-20,%sp),%sp
	moveq #1,%d0
	movem.l #15364,(%sp)
	pea 488.w
	move.b %d0,us+50
	jsr 1074276820
	addq.l #4,%sp
	move.l %d0,%a2
	tst.l %d0
	jeq .L253
	pea 488.w
	move.l %d0,-(%sp)
	jsr us_zero
	addq.l #8,%sp
.L253:
	move.l %a2,us+20
	pea 336.w
	jsr 1074276820
	addq.l #4,%sp
	move.l %d0,%a2
	tst.l %d0
	jeq .L254
	pea 336.w
	move.l %d0,-(%sp)
	jsr us_zero
	addq.l #8,%sp
.L254:
	move.l %a2,us+24
	lea us,%a3
	clr.l %d2
	lea us_zero,%a5
	lea us_slot_records,%a4
.L256:
	pea 1524.w
	jsr 1074276820
	addq.l #4,%sp
	move.l %d0,%a2
	tst.l %d0
	jeq .L255
	pea 1524.w
	move.l %d0,-(%sp)
	jsr (%a5)
	mov3q.l #-1,484(%a2)
	mov3q.l #-1,488(%a2)
	addq.l #8,%sp
.L255:
	move.l %a2,(%a3)+
	move.l %d2,-(%sp)
	jsr (%a4)
	addq.l #1,%d2
	addq.l #4,%sp
	mov3q.l #5,%d0
	cmp.l %d2,%d0
	jne .L256
	movem.l (%sp),#15364
	lea (20,%sp),%sp
	rts
	.size	us_init, .-us_init
	.section	.us1
	.align	2
	.type	us_which.constprop.0, @function
us_which.constprop.0:
	move.l %d2,-(%sp)
	moveq #39,%d2
	move.l 8(%sp),%d1
	move.l %d1,%d0
	move.l 12(%sp),%a1
	add.l #-334,%d0
	cmp.l %d0,%d2
	jcs .L268
	mov3q.l #7,%d1
	and.l %d0,%d1
	asr.l #3,%d0
	move.l %d1,(%a1)
.L267:
	move.l (%sp)+,%d2
	rts
.L268:
	lea us_p2rec,%a0
	clr.l %d0
.L272:
	mvs.w (%a0),%d2
	cmp.l %d1,%d2
	jne .L270
	addq.l #8,%d0
	move.l %d0,(%a1)
	moveq #11,%d2
	mvz.b 1093765506,%d0
	cmp.l %d0,%d2
	jcs .L273
	mvz.b 1093765506,%d0
	move.l %d0,%a0
	add.l #-2147423744,%a0
.L271:
	mvz.b (%a0),%d0
	mov3q.l #4,%d1
	add.l #-35,%d0
	cmp.l %d0,%d1
	jcc .L267
.L275:
	mov3q.l #-1,%d0
	jra .L267
.L273:
	move.l #-2147423744,%a0
	jra .L271
.L270:
	addq.l #2,%a0
	addq.l #1,%d0
	moveq #8,%d2
	cmp.l %d0,%d2
	jne .L272
	jra .L275
	.size	us_which.constprop.0, .-us_which.constprop.0
	.section	.us6
	.align	2
	.type	ext_steps_us, @function
ext_steps_us:
	link.w %fp,#-8
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	pea -4(%fp)
	move.l 8(%fp),%d2
	mov3q.l #-1,%d3
	clr.l -4(%fp)
	move.l %d2,-(%sp)
	move.l 12(%fp),-8(%fp)
	jsr (us_which.constprop.0)
	addq.l #8,%sp
	cmp.l %d0,%d3
	jne .L277
	tst.l us_cubox+8
	jeq .L278
	move.l %d2,8(%fp)
	move.l us_cubox+8,%a1
	move.l -16(%fp),%d2
	move.l -12(%fp),%d3
	unlk %fp
	jmp (%a1)
.L277:
	lea us,%a0
	move.l (%a0,%d0.l*4),%a0
	tst.l %a0
	jeq .L278
	move.b (%a0),%d1
	jeq .L278
	move.l -4(%fp),%d2
	moveq #28,%d3
	muls.l %d2,%d3
	lea (%a0,%d3.l),%a1
	tst.b 36(%a1)
	jeq .L278
	mvz.b 38(%a1),%d3
	move.l %d3,%a1
	mov3q.l #2,%d3
	cmp.l %a1,%d3
	jne .L302
	clr.l %d0
	lea (484,%a0),%a1
.L279:
	mvz.b (%a1,%d0.l),%d1
	cmp.l %d2,%d1
	jne .L281
	lea (%a0,%d0.l),%a0
	mov3q.l #1,%d1
	mvz.b 492(%a0),%d0
	cmp.l %d0,%d1
	jcc .L278
	bset #8,%d0
.L276:
	move.l -16(%fp),%d2
	move.l -12(%fp),%d3
	unlk %fp
	rts
.L281:
	addq.l #1,%d0
	moveq #8,%d1
	cmp.l %d0,%d1
	jne .L279
.L278:
	clr.l %d0
	jra .L276
.L302:
	mov3q.l #6,%d2
	cmp.l %a1,%d2
	jne .L284
	tst.l -8(%fp)
	jne .L285
.L289:
	mvz.w #896,%d0
	jra .L276
.L285:
	mvz.b jn_mailbox+19,%d2
	add.l #17,%d0
	cmp.l %d2,%d0
	jne .L289
	mvz.b %d1,%d1
	mvz.b jn_mailbox+20,%d0
	cmp.l %d1,%d0
	jne .L289
	move.l -8(%fp),%d0
	bset #9,%d0
	jra .L276
.L284:
	mov3q.l #7,%d3
	cmp.l %a1,%d3
	jne .L278
	jra .L289
	.size	ext_steps_us, .-ext_steps_us
	.section	.us3
	.align	2
	.globl	ext_steps
	.type	ext_steps, @function
ext_steps:
	move.l %d2,-(%sp)
	move.l 8(%sp),%d1
	clr.l %d0
	lea ext_step_tab,%a0
	move.l %a0,%a1
.L308:
	mvz.w (%a0),%d2
	cmp.l %d2,%d1
	jne .L305
	mov3q.l #6,%d2
#APP
| 2440 "ext.c" 1
	movel #P_DIAG,%d1
| 0 "" 2
#NO_APP
	cmp.l %d0,%d2
	jne .L306
	tst.l %d1
	jne .L314
.L306:
	mvz.w 2(%a1,%d0.l*4),%d0
.L304:
	move.l (%sp)+,%d2
	rts
.L305:
	addq.l #1,%d0
	addq.l #4,%a0
	mov3q.l #7,%d2
	cmp.l %d0,%d2
	jne .L308
	tst.b jn_mailbox+8.l
	jeq .L309
	mvz.b jn_mailbox+9,%d0
	cmp.l #382,%d1
	jeq .L310
	cmp.l #374,%d1
	jne .L311
.L310:
	tst.l %d0
	jne .L312
.L313:
	mvz.w #896,%d0
	jra .L304
.L312:
	cmp.l #374,%d1
	seq %d1
	mvz.b jn_mailbox+19,%d2
	neg.l %d1
	mvz.b %d1,%d1
	cmp.l %d2,%d1
	jne .L313
	bset #9,%d0
	jra .L304
.L314:
	clr.l %d0
	jra .L304
.L309:
	cmp.l #382,%d1
	jeq .L313
	cmp.l #374,%d1
	jeq .L313
	clr.l %d0
.L311:
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	jsr ext_steps_us
	addq.l #8,%sp
	jra .L304
	.size	ext_steps, .-ext_steps
	.section	.exto
	.align	2
	.globl	usb_free
	.type	usb_free, @function
usb_free:
	move.l 4(%sp),%d0
	move.l 1094562704,%a0
.L326:
	tst.l %d0
	jgt .L328
	mov3q.l #1,%d0
.L325:
	rts
.L328:
	tst.l %a0
	jeq .L329
	move.l 52(%a0),%a0
	subq.l #1,%d0
	jra .L326
.L329:
	clr.l %d0
	jra .L325
	.size	usb_free, .-usb_free
	.section	.ext9,"ax",@progbits
	.align	2
	.type	ext_try_send, @function
ext_try_send:
	subq.l #4,%sp
	tst.l 1123449384
	jeq .L331
.L333:
	clr.l %d0
.L330:
	addq.l #4,%sp
	rts
.L331:
	tst.l 1094562372
	jne .L333
	mvz.w #3800,%d0
	cmp.l 1094562392.l,%d0
	jcs .L333
	mov3q.l #2,-(%sp)
	jsr usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L330
	move.l 8(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	move.l %d0,8(%sp)
	jsr 1073752544
	addq.l #8,%sp
	move.l (%sp),%d0
	jra .L330
	.size	ext_try_send, .-ext_try_send
	.section	.extp,"ax",@progbits
	.align	2
	.type	ext_project, @function
ext_project:
	link.w %fp,#-28
	move.l ext_proj,%d1
	addq.l #1,%d1
	move.l %d2,-(%sp)
	move.l %d1,ext_proj
	tst.b %d1
	jne .L338
	move.l #1081903571,%a0
	mov3q.l #1,%a1
.L340:
	move.l #ext_proj-1081903567,%d2
	addq.l #1,%a0
	move.b -1(%a0,%d2.l),%d2
	move.b -1(%a0),%d0
	eor.l %d2,%d0
	move.l %a1,%d2
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
	and.l %d0,%d2
	move.l %d2,%a1
	cmp.l #1081903587,%a0
	jne .L340
	tst.l %d2
	jeq .L341
	and.l #16383,%d1
	tst.l %d1
	jne .L338
.L341:
	moveq #16,%d0
	move.l #-260222380,%a1
	mov3q.l #5,%a0
	move.l %a1,-22(%fp)
	move.l #1081903566,%a1
	move.b %d0,-18(%fp)
.L342:
	move.b (%a0,%a1.l),%d0
	jeq .L343
	moveq #127,%d1
	addq.l #1,%a0
	and.l %d1,%d0
	moveq #20,%d2
	move.b %d0,-23(%a0,%fp.l)
	cmp.l %a0,%d2
	jne .L342
.L343:
	moveq #-9,%d0
	move.b %d0,-22(%fp,%a0.l)
	pea 1(%a0)
	pea -22(%fp)
	jsr ext_try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L338
	move.l #1081903571,%a0
.L345:
	lea ext_proj-1081903567,%a1
	move.b (%a0),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L345
.L338:
	move.l -32(%fp),%d2
	unlk %fp
	rts
	.size	ext_project, .-ext_project
	.section	.extq,"ax",@progbits
	.align	2
	.type	diag_text, @function
diag_text:
	lea (-16,%sp),%sp
	moveq #12,%d0
	movem.l #1052,(%sp)
	move.l 24(%sp),%d3
	asr.l %d0,%d3
	mov3q.l #7,%d0
	and.l %d0,%d3
	moveq #11,%d0
	mvz.b 1093765506,%d2
	cmp.l %d2,%d0
	jge .L358
	clr.l %d2
.L358:
	mov3q.l #6,%d0
	cmp.l %d3,%d0
	jcs .L359
	move.w .L361(%pc,%d3.l*2),%d0
	ext.l %d0
	jmp %pc@(2,%d0:l)
	.balignw 2,0x284c
	.swbeg	&7
.L361:
	.word .L367-.L361
	.word .L370-.L361
	.word .L365-.L361
	.word .L364-.L361
	.word .L363-.L361
	.word .L362-.L361
	.word .L360-.L361
.L367:
	move.l ext_diag_max,%d2
.L360:
	lea diag_key,%a0
	mvs.b (%a0,%d3.l),%d3
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	pea diag_fmt
	move.l 40(%sp),-(%sp)
	jsr 1074365954
	movem.l 16(%sp),#1052
	lea (32,%sp),%sp
	rts
.L370:
	clr.l %d4
.L366:
	move.l %d4,%d2
	addq.l #1,%d4
	move.l %d4,-(%sp)
	jsr usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L360
	moveq #40,%d0
	cmp.l %d4,%d0
	jne .L366
	moveq #40,%d2
	jra .L360
.L365:
	move.l 1079807120,%d2
	jra .L360
.L364:
	moveq #127,%d0
	and.l -2147457096,%d0
	mulu.w #152,%d2
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l #1092966707,%a0
.L372:
	mvz.b (%a0,%d2.l),%d2
	jra .L360
.L363:
	move.l #-2147423744,%a0
	jra .L372
.L362:
	move.l 1094562392,%d2
	jra .L360
.L359:
	clr.l ext_diag_max
	clr.l %d2
	jra .L360
	.size	diag_text, .-diag_text
	.section	.us2
	.align	2
	.globl	ext_ui_lock
	.type	ext_ui_lock, @function
ext_ui_lock:
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jeq .L374
.L376:
	clr.l %d0
.L373:
	rts
.L374:
	move.l 1094562392,%d0
	add.l #64,%d0
	cmp.l #4091,%d0
	jhi .L376
	mov3q.l #4,-(%sp)
	jsr usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L373
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	jra .L373
	.size	ext_ui_lock, .-ext_ui_lock
	.align	2
	.type	us_send.constprop.0, @function
us_send.constprop.0:
	jsr ext_ui_lock
	tst.l %d0
	jeq .L380
	move.l 4(%sp),-(%sp)
	pea 11.w
	jsr 1073752544
	jsr 1073752356
	addq.l #8,%sp
	mov3q.l #1,%d0
.L380:
	rts
	.size	us_send.constprop.0, .-us_send.constprop.0
	.align	2
	.type	us_ask, @function
us_ask:
	link.w %fp,#-12
	move.l #-260222380,%d0
	move.l %d0,-11(%fp)
	move.w #6401,%d0
	pea -11(%fp)
	move.b 11(%fp),-5(%fp)
	move.b 15(%fp),-4(%fp)
	move.b 19(%fp),-3(%fp)
	move.b 23(%fp),-2(%fp)
	move.w %d0,-7(%fp)
	moveq #-9,%d0
	move.b %d0,-1(%fp)
	jsr (us_send.constprop.0)
	addq.l #4,%sp
	unlk %fp
	rts
	.size	us_ask, .-us_ask
	.section	.us1
	.align	2
	.type	us_preset_text, @function
us_preset_text:
	lea (-16,%sp),%sp
	movem.l #3084,(%sp)
	move.l 20(%sp),%a2
	lea us,%a3
	move.l 24(%sp),%d2
	move.l (%a3,%a2.l*4),%a0
	move.l 28(%sp),%d3
	tst.l %a0
	jeq .L387
	tst.b jn_mailbox+8.l
	jeq .L388
	mvz.b jn_mailbox+19,%d1
	move.l %a2,%d0
	add.l #17,%d0
	cmp.l %d1,%d0
	jne .L388
	mvz.b jn_mailbox+20,%d1
	mvz.b (%a0),%d0
	cmp.l %d1,%d0
	jne .L388
	move.b jn_mailbox+9,%d0
	jne .L389
	move.l #us_none,%d0
	move.l %d0,28(%sp)
.L406:
	move.l #ext_fmt_s,%d0
.L405:
	move.l %d3,20(%sp)
	movem.l (%sp),#3084
	move.l %d0,24(%sp)
	lea (16,%sp),%sp
	jmp 1074365954
.L389:
	mvz.b %d0,%d0
	cmp.l %d0,%d2
	jlt .L390
	move.l %d0,%d2
	subq.l #1,%d2
.L390:
	moveq #10,%d0
	muls.l %d2,%d0
	move.l %d0,%a1
	add.l #jn_mailbox+37,%a1
	tst.b (%a1)
	jeq .L395
	mulu.w #10,%d2
	add.l #jn_mailbox+37,%d2
	move.l %d2,28(%sp)
	jra .L406
.L388:
	clr.l %d0
.L391:
	tst.b us+40.l
	jne .L387
	tst.b 35(%a3,%a2.l)
	jne .L387
	tst.l %d0
	jeq .L394
	move.l %d2,%d0
	asr.l #4,%d0
.L394:
	move.l %d0,-(%sp)
	mov3q.l #2,-(%sp)
	mvz.b (%a0),%d0
	move.l %d0,-(%sp)
	pea 1(%a2)
	jsr us_ask
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L387
	moveq #10,%d0
	move.b %d0,us+40
	moveq #50,%d0
	move.b %d0,35(%a3,%a2.l)
.L387:
	move.l %d2,28(%sp)
	move.l #us_fmt_d,%d0
	jra .L405
.L395:
	mov3q.l #1,%d0
	jra .L391
	.size	us_preset_text, .-us_preset_text
	.align	2
	.globl	us_text
	.type	us_text, @function
us_text:
	link.w %fp,#-28
	move.l 8(%fp),%d0
	add.l #-1100630172,%d0
	movem.l #1036,(%sp)
	moveq #84,%d3
	divs.l %d3,%d0
	pea -12(%fp)
	move.l 12(%fp),%d2
	asr.l #8,%d2
	move.l 16(%fp),-16(%fp)
	clr.l -12(%fp)
	move.l %d0,-(%sp)
	jsr (us_which.constprop.0)
	addq.l #8,%sp
	mov3q.l #-1,%d1
	cmp.l %d0,%d1
	jeq .L432
	lea us,%a0
	move.l (%a0,%d0.l*4),%a1
	tst.l %a1
	jeq .L433
	tst.b (%a1)
	jne .L409
.L433:
	sub.l %a0,%a0
	jra .L408
.L409:
	move.l -12(%fp),%d1
	moveq #28,%d3
	muls.l %d3,%d1
	tst.b 36(%a1,%d1.l)
	jeq .L433
	lea 36(%a1,%d1.l),%a0
.L408:
	move.l %d2,%d1
	moveq #127,%d3
	cmp.l %d2,%d3
	jge .L411
	moveq #127,%d1
.L412:
	tst.l %a0
	jne .L413
.L414:
	lea us_fmt_d,%a0
	move.l %d1,16(%fp)
	move.l %a0,12(%fp)
	jra .L447
.L432:
	sub.l %a1,%a1
	jra .L433
.L411:
	tst.l %d2
	jge .L412
	clr.l %d1
	jra .L412
.L413:
	move.b 2(%a0),%d3
	move.w %d3,%a0
	subq.l #1,%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #6,%d3
	cmp.l %a0,%d3
	jcs .L414
	move.w .L416(%pc,%a0.l*2),%a0
	jmp %pc@(2,%a0:l)
	.balignw 2,0x284c
	.swbeg	&7
.L416:
	.word .L420-.L416
	.word .L419-.L416
	.word .L414-.L416
	.word .L418-.L416
	.word .L414-.L416
	.word .L417-.L416
	.word .L415-.L416
.L419:
	move.l -12(%fp),%d0
	sub.l %a0,%a0
	lea (484,%a1),%a2
.L421:
	mvz.b (%a2,%a0.l),%d2
	cmp.l %d2,%d0
	jne .L423
	lea (%a1,%a0.l),%a2
	mvz.b 492(%a2),%d0
	tst.l %d0
	jeq .L414
	move.l %d0,%d2
	subq.l #1,%d2
	muls.w %d1,%d0
	asr.l #7,%d0
	cmp.l %d0,%d2
	jge .L425
	move.l %d2,%d0
.L425:
	move.l %a0,%d1
	lsl.l #4,%d1
	add.l %d1,%d0
	mvz.w %d0,%d0
	lsl.l #3,%d0
	move.l %d0,%a0
	clr.l %d0
	lea (500,%a0),%a0
	add.l %a1,%a0
.L426:
	move.b (%a0,%d0.l),%d1
	jeq .L427
	move.b %d1,-8(%fp,%d0.l)
	addq.l #1,%d0
	mov3q.l #7,%d3
	cmp.l %d0,%d3
	jne .L426
.L427:
	clr.b %d1
	move.b %d1,-8(%fp,%d0.l)
	tst.l %d0
	jeq .L435
	move.l %fp,%d0
	subq.l #8,%d0
.L429:
	move.l %d0,-(%sp)
	pea ext_fmt_s
	move.l -16(%fp),-(%sp)
	jsr 1074365954
	lea (12,%sp),%sp
.L407:
	movem.l -28(%fp),#1036
	unlk %fp
	rts
.L420:
	add.l #-64,%d1
	moveq #64,%d0
	cmp.l %d2,%d0
	jge .L434
	move.l #us_fmt_pd,%d0
.L422:
	move.l %d1,16(%fp)
	move.l %d0,12(%fp)
.L447:
	movem.l -28(%fp),#1036
	move.l -16(%fp),8(%fp)
	unlk %fp
	jmp 1074365954
.L434:
	move.l #us_fmt_d,%d0
	jra .L422
.L423:
	addq.l #1,%a0
	moveq #8,%d2
	cmp.l %a0,%d2
	jne .L421
	jra .L414
.L435:
	move.l #us_none,%d0
	jra .L429
.L418:
	moveq #12,%d2
	rems.l %d2,%d0:%d1
	divs.l %d2,%d1
	mulu.w #3,%d0
	move.l %d1,%a0
	pea -1(%a0)
	add.l #us_notes,%d0
	move.l %d0,-(%sp)
	pea us_fmt_note
	move.l -16(%fp),-(%sp)
	jsr 1074365954
	lea (16,%sp),%sp
	jra .L407
.L417:
	movem.l -28(%fp),#1036
	move.l -16(%fp),16(%fp)
	move.l %d1,12(%fp)
	move.l %d0,8(%fp)
	unlk %fp
	jra us_preset_text
.L415:
	movem.l -28(%fp),#1036
	move.l -16(%fp),12(%fp)
	move.l %d1,8(%fp)
	unlk %fp
	jra us_pool_text
	.size	us_text, .-us_text
	.section	.us3
	.align	2
	.type	us_wait, @function
us_wait:
	lea (-20,%sp),%sp
	movem.l #7172,(%sp)
	move.l 28(%sp),%d2
	move.l 24(%sp),%d1
	addq.l #1,%d1
	move.l %d1,16(%sp)
	lea us,%a2
	lea jn_mailbox,%a3
.L452:
	tst.l 24(%sp)
	jge .L449
	tst.b 34(%a2)
	jeq .L450
	tst.b 8(%a3)
	jeq .L450
	mvz.b 19(%a3),%d0
	moveq #32,%d1
	cmp.l %d0,%d1
	jne .L450
	mvz.b 20(%a3),%d1
	mvz.b 33(%a2),%d0
	cmp.l %d1,%d0
	jne .L450
.L451:
	move.l %d2,%d0
	addq.l #1,%d0
	jra .L448
.L449:
	mvz.b 46(%a2),%d0
	cmp.l 16(%sp),%d0
	jeq .L451
.L454:
	pea 10000.w
	jsr 1074367512
	addq.l #1,%d2
	addq.l #4,%sp
	cmp.l #200,%d2
	jne .L452
	clr.l %d0
.L448:
	movem.l (%sp),#7172
	lea (20,%sp),%sp
	rts
.L450:
	tst.l %d2
	jne .L454
	clr.l -(%sp)
	mov3q.l #3,-(%sp)
	clr.l -(%sp)
	clr.l -(%sp)
	jsr us_ask
	lea (16,%sp),%sp
	tst.l %d0
	jne .L454
	jra .L448
	.size	us_wait, .-us_wait
	.section	.ext4
	.align	2
	.type	us_live_ask.constprop.0, @function
us_live_ask.constprop.0:
	lea (-12,%sp),%sp
	movem.l #3076,(%sp)
	lea us,%a3
	clr.l %d2
	move.l %a3,%a2
.L460:
	move.l (%a3)+,%a0
	tst.l %a0
	jeq .L461
	mvz.b (%a0),%d1
.L457:
	move.b 35(%a2),%d0
	addq.l #1,%d2
	tst.b %d0
	jeq .L458
	subq.l #1,%d0
.L466:
	move.b %d0,35(%a2)
.L459:
	addq.l #1,%a2
	mov3q.l #5,%d0
	cmp.l %d2,%d0
	jne .L460
	movem.l (%sp),#3076
	lea (12,%sp),%sp
	rts
.L461:
	clr.l %d1
	jra .L457
.L458:
	tst.b us+34.l
	jeq .L459
	mvz.b 28(%a2),%d0
	cmp.l %d0,%d1
	jeq .L459
	clr.l -(%sp)
	clr.l -(%sp)
	move.l %d1,-(%sp)
	move.l %d2,-(%sp)
	jsr us_ask
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L459
	moveq #50,%d0
	jra .L466
	.size	us_live_ask.constprop.0, .-us_live_ask.constprop.0
	.section	.us4
	.align	2
	.globl	us_live
	.type	us_live, @function
us_live:
	subq.l #4,%sp
	tst.b us+51.l
	jne .L468
	jsr sp_tick
.L468:
	tst.b us+50.l
	jeq .L473
	move.l us+20,%a0
	tst.l %a0
	jne .L470
.L472:
	clr.l %d0
.L471:
	move.l %d0,(%sp)
	jsr (us_live_ask.constprop.0)
	move.l (%sp),%d0
.L467:
	addq.l #4,%sp
	rts
.L470:
	mvz.b 3(%a0),%d0
	cmp.l #255,%d0
	jne .L472
	jsr us_commit
	mov3q.l #1,%d0
	jra .L471
.L473:
	clr.l %d0
	jra .L467
	.size	us_live, .-us_live
	.section	.extd
	.align	2
	.globl	dd_descriptors
	.type	dd_descriptors, @function
dd_descriptors:
	lea (-12,%sp),%sp
	movem.l #3076,(%sp)
	mvz.w #390,%d2
	move.l #1075595388,%a2
	lea copy_desc,%a3
.L475:
	pea 410.w
	move.l %d2,-(%sp)
	jsr (%a3)
	move.l #dd_short,(%a2)
	addq.l #1,%d2
	lea (52,%a2),%a2
	addq.l #8,%sp
	cmp.l #1075595804,%a2
	jne .L475
	move.l #dd_eng,%d0
	move.l %d0,1075595392
	move.l %d0,1075595384
	move.l #dd_engine_text,%d0
	move.l %d0,1100662944
	clr.l -(%sp)
	jsr dd_name_knobs
	movem.l 4(%sp),#3076
	lea (16,%sp),%sp
	rts
	.size	dd_descriptors, .-dd_descriptors
	.section	.extj,"ax",@progbits
	.align	2
	.globl	jn_patch_text
	.type	jn_patch_text, @function
jn_patch_text:
	move.l %d2,-(%sp)
	moveq #127,%d2
	move.l 12(%sp),%d1
	asr.l #8,%d1
	move.l %d1,%d0
	cmp.l %d1,%d2
	jge .L478
	moveq #127,%d0
.L479:
	mov3q.l #7,%d2
	and.l %d0,%d2
	asr.l #3,%d0
	move.l %d2,%a0
	mov3q.l #7,%d2
	and.l %d2,%d0
	addq.l #1,%a0
	moveq #63,%d2
	addq.l #1,%d0
	cmp.l %d1,%d2
	jlt .L481
	moveq #65,%d1
.L480:
	move.l %a0,-(%sp)
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	pea jn_fmt
	move.l 32(%sp),-(%sp)
	jsr 1074365954
	lea (20,%sp),%sp
	move.l (%sp)+,%d2
	rts
.L478:
	tst.l %d1
	jge .L479
	clr.l %d0
	jra .L479
.L481:
	moveq #66,%d1
	jra .L480
	.size	jn_patch_text, .-jn_patch_text
	.section	.ext9
	.align	2
	.type	pat_text, @function
pat_text:
	lea (-52,%sp),%sp
	movem.l #17468,(%sp)
	move.b 71(%sp),%d3
	move.b jn_mailbox+19,%d0
	move.l 60(%sp),%d4
	move.l %d4,%d5
	asr.l #8,%d5
	move.l 64(%sp),%d2
	move.l #1081903571,%a0
	move.l 56(%sp),24(%sp)
	lea jn_mailbox-1081903550,%a2
	move.l %d5,%a6
	eor.l %d3,%d0
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
.L483:
	move.b (%a2,%a0.l),%d1
	move.b (%a0)+,%d5
	move.w %d5,%a1
	move.l %a1,%d5
	eor.l %d5,%d1
	tst.b %d1
	seq %d1
	mvs.b %d1,%d1
	neg.l %d1
	and.l %d1,%d0
	cmp.l #1081903587,%a0
	jne .L483
	move.b jn_mailbox+8,%d1
	tst.l %d0
	jne .L484
	tst.b %d1
	jeq .L485
	move.b %d0,jn_mailbox+10
.L485:
	clr.b %d1
	move.b %d1,jn_mailbox+8
.L486:
	move.b jn_mailbox+10,%d0
	jeq .L488
	subq.l #1,%d0
	move.b %d0,jn_mailbox+10
.L489:
	tst.b %d3
	jeq .L498
	move.l #fm_fmt_d,%d5
	move.l %a6,64(%sp)
	move.l %d5,60(%sp)
	jra .L515
.L484:
	tst.b %d1
	jeq .L486
	move.b jn_mailbox+9,%d1
	jeq .L489
	move.l %a6,%d0
	tst.l %a6
	jge .L495
	clr.l %d0
.L495:
	mvz.b %d1,%d1
	cmp.l %d1,%d0
	jlt .L496
	move.l %d1,%d0
	subq.l #1,%d0
.L496:
	moveq #10,%d1
	muls.l %d0,%d1
	move.l %d1,%a0
	add.l #jn_mailbox+37,%a0
	tst.b (%a0)
	jeq .L500
	mulu.w #10,%d0
	add.l #jn_mailbox+37,%d0
.L497:
	move.l #ext_fmt_s,%d1
	move.l %d0,64(%sp)
	move.l %d1,60(%sp)
.L515:
	move.l %d2,56(%sp)
	movem.l (%sp),#17468
	lea (52,%sp),%sp
	jmp 1074365954
.L488:
	jsr ext_ui_lock
	tst.l %d0
	jeq .L489
	moveq #16,%d0
	move.l #-260222380,%d5
	mov3q.l #5,%a0
	move.l %d5,30(%sp)
	move.l #1081903566,%a1
	move.b %d0,34(%sp)
.L490:
	move.b (%a0,%a1.l),%d0
	jeq .L491
	moveq #127,%d1
	addq.l #1,%a0
	and.l %d1,%d0
	moveq #20,%d5
	move.b %d0,29(%a0,%sp.l)
	cmp.l %a0,%d5
	jne .L490
.L491:
	moveq #-9,%d1
	move.l %a0,%d0
	addq.l #1,%d0
	move.b %d1,30(%sp,%a0.l)
	move.l #1081903571,%a0
.L493:
	move.b (%a0),(%a2,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L493
	moveq #-56,%d5
	lea (30,%sp),%a2
	move.l %a2,-(%sp)
	move.l %d0,-(%sp)
	move.b %d5,jn_mailbox+10
	jsr 1073752544
	addq.l #8,%sp
	tst.b %d3
	jeq .L499
	moveq #24,%d0
.L494:
	move.b %d0,34(%sp)
	moveq #-9,%d0
	move.b %d0,35(%sp)
	move.l %a2,-(%sp)
	mov3q.l #6,-(%sp)
	jsr 1073752544
	jsr 1073752356
	addq.l #8,%sp
	jra .L489
.L499:
	moveq #19,%d0
	jra .L494
.L500:
	move.l #jn_empty,%d0
	jra .L497
.L498:
	move.l %d2,64(%sp)
	move.l %d4,60(%sp)
	movem.l (%sp),#17468
	move.l 24(%sp),56(%sp)
	lea (52,%sp),%sp
	jra jn_patch_text
	.size	pat_text, .-pat_text
	.align	2
	.globl	jn_pat_text
	.type	jn_pat_text, @function
jn_pat_text:
	clr.l -(%sp)
	move.l 16(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	jsr pat_text
	lea (16,%sp),%sp
	rts
	.size	jn_pat_text, .-jn_pat_text
	.align	2
	.globl	fm_pat_text
	.type	fm_pat_text, @function
fm_pat_text:
	mov3q.l #1,-(%sp)
	move.l 16(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	jsr pat_text
	lea (16,%sp),%sp
	rts
	.size	fm_pat_text, .-fm_pat_text
	.section	.extl,"ax",@progbits
	.align	2
	.globl	jn_descriptors
	.type	jn_descriptors, @function
jn_descriptors:
	lea (-24,%sp),%sp
	movem.l #3132,(%sp)
	move.l #jn_long,%d4
	mov3q.l #-1,%d2
	move.l #jn_short,%d3
	move.l #1075594928,%a2
	lea copy_desc,%a3
.L520:
	move.l %d2,%d1
	mov3q.l #5,%d5
	mvz.w #410,%d0
	add.l #383,%d1
	cmp.l %d2,%d5
	jcs .L519
	moveq #40,%d0
.L519:
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	jsr (%a3)
	move.l %d4,40(%a2)
	move.l %d3,48(%a2)
	addq.l #1,%d2
	move.l #jn_name,%d0
	add.l #11,%d4
	move.l %d0,44(%a2)
	lea (52,%a2),%a2
	addq.l #4,%d3
	addq.l #8,%sp
	mov3q.l #7,%d5
	cmp.l %d2,%d5
	jne .L520
	movem.l (%sp),#3132
	move.l #jn_pat_text,%d0
	move.l %d0,1100662272
	lea (24,%sp),%sp
	rts
	.size	jn_descriptors, .-jn_descriptors
	.section	.exto
	.align	2
	.globl	ext_gate
	.type	ext_gate, @function
ext_gate:
	link.w %fp,#-12
	move.l 8(%fp),%d0
	mov3q.l #7,%d1
	move.l %d2,-(%sp)
	move.l #1076432344,%a0
	mov3q.l #-1,%d2
	and.l %d0,%d1
	mvz.b (%a0,%d0.l),%d0
	mulu.w #12,%d0
	move.l %d0,%a0
	moveq #70,%d0
	muls.l %d1,%d0
	add.l #-2147418536,%a0
	cmp.l (%a0),%d2
	jne .L524
	cmp.l 8(%a0),%d2
	jne .L524
	cmp.l 4(%a0),%d2
	jeq .L525
	tst.l 1079807120
	jeq .L525
.L524:
	moveq #1,%d1
	lea ext_state,%a0
	move.b %d1,69(%a0,%d0.l)
.L526:
	move.l -16(%fp),%d2
	unlk %fp
	jra ext_project
.L525:
	lea ext_state,%a0
	add.l %d0,%a0
	move.l %a0,-12(%fp)
	tst.b 69(%a0)
	jeq .L526
	tst.b 66(%a0)
	jne .L526
	move.l #-260222380,%d0
	move.l %d0,-7(%fp)
	moveq #-9,%d0
	moveq #17,%d2
	mov3q.l #7,-(%sp)
	pea -7(%fp)
	move.b %d1,-2(%fp)
	move.b %d0,-1(%fp)
	move.b %d2,-3(%fp)
	jsr ext_try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L526
	clr.b %d1
	move.l -12(%fp),%a0
	move.b %d1,69(%a0)
	jra .L526
	.size	ext_gate, .-ext_gate
	.section	.ext7
	.align	2
	.globl	dsp_excite
	.type	dsp_excite, @function
dsp_excite:
	lea (-124,%sp),%sp
	movem.l #23676,(%sp)
	move.l 136(%sp),%a3
	mvz.b 8(%a3),%d0
	muls.w #11,%d0
	asr.l #7,%d0
	move.l %d0,%a6
	mov3q.l #1,%d0
	cmp.l %a6,%d0
	jne .L538
	move.l #1076432344,%a0
	move.l 128(%sp),%a1
	mvz.b (%a1,%a0.l),%d0
	move.l #1075573068,%a0
	move.l (%a0,%d0.l*4),%d2
.L539:
	clr.l %d0
	lea (40,%sp),%a2
.L541:
	lea (%a3,%d0.l),%a0
	moveq #84,%d1
	move.w (%a0),(%a2,%d0.l)
	addq.l #2,%d0
	cmp.l %d0,%d1
	jne .L541
	move.l %d2,%d0
	clr.l %d1
	lsl.l #5,%d0
	lea dsp_x_word,%a4
	move.l %d0,%a1
	add.l #1094563324,%a1
.L545:
	move.l (%a1),%d0
	tst.l %d0
	jle .L542
	moveq #52,%d3
	mov3q.l #4,%d4
	muls.l %d3,%d0
	move.l %d0,%a0
	add.l #1075575064,%a0
	cmp.l %d1,%d4
	jge .L543
	move.l 16(%a0),%d0
.L544:
	move.w %d0,(%a2,%d1.l*2)
.L542:
	addq.l #1,%d1
	addq.l #4,%a1
	moveq #8,%d5
	cmp.l %d1,%d5
	jne .L545
	move.l #1076429692,%a0
	move.l 140(%sp),-(%sp)
	move.l (%a0,%d2.l*4),%a0
	move.l %a2,-(%sp)
	move.l 140(%sp),-(%sp)
	move.l 140(%sp),-(%sp)
	jsr (%a0)
	lea (16,%sp),%sp
.L537:
	move.l %a6,%d0
	movem.l (%sp),#23676
	lea (124,%sp),%sp
	rts
.L538:
	mov3q.l #2,%d0
	cmp.l %a6,%d0
	jne .L546
	moveq #15,%d2
	jra .L539
.L543:
	move.l 8(%a0),%d0
	moveq #127,%d6
	move.l 12(%a0),%a0
	sub.l %d0,%a0
	move.l %a0,%d5
	divs.l %d6,%d5
	mvz.b (%a4,%d1.l),%d3
	mvz.b (%a3,%d3.l*2),%d3
	muls.l %d5,%d3
	add.l %d3,%d0
	jra .L544
.L546:
	sub.l %a6,%a6
	jra .L537
	.size	dsp_excite, .-dsp_excite
	.section	.extc,"ax",@progbits
	.align	2
	.globl	fm_descriptors
	.type	fm_descriptors, @function
fm_descriptors:
	lea (-24,%sp),%sp
	movem.l #7196,(%sp)
	mvz.w #374,%d4
	lea fm_look,%a3
	move.l #fm_long,%d3
	move.l #fm_short,%d2
	move.l #1075594512,%a2
	lea copy_desc,%a4
.L550:
	mvs.w (%a3)+,%d0
	lea (52,%a2),%a2
	move.l %d0,-(%sp)
	move.l %d4,-(%sp)
	jsr (%a4)
	move.l %d3,-12(%a2)
	move.l %d2,-4(%a2)
	addq.l #1,%d4
	move.l #fm_sname,%d0
	add.l #9,%d3
	move.l %d0,-8(%a2)
	addq.l #4,%d2
	addq.l #8,%sp
	cmp.l #1075594928,%a2
	jne .L550
	move.l #fm_pat_text,%d0
	movem.l (%sp),#7196
	move.l %d0,1100661600
	lea (24,%sp),%sp
	rts
	.size	fm_descriptors, .-fm_descriptors
	.section	.ext9
	.align	2
	.globl	jn_sysex
	.type	jn_sysex, @function
jn_sysex:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.l 16(%sp),%a0
	moveq #21,%d3
	move.l 20(%sp),%d1
	move.b 4(%a0),%d0
	mvz.b %d0,%d2
	cmp.l %d2,%d3
	jne .L553
	moveq #12,%d4
	cmp.l %d1,%d4
	jge .L554
	move.b 5(%a0),%d0
	mov3q.l #7,%d1
	move.l #1076432344,%a1
	moveq #11,%d2
	and.l %d1,%d0
	move.b (%a1,%d0.l),%d3
	mvz.b %d3,%d0
	cmp.l %d0,%d2
	jcs .L554
	move.l #-2147423744,%a1
	moveq #41,%d4
	mvz.b (%a1,%d0.l),%d0
	cmp.l %d0,%d4
	jne .L554
	move.b jn_mailbox+11,%d0
	addq.l #1,%d0
	move.b %d0,jn_mailbox+11
	clr.l %d1
	lea jn_mailbox+13,%a1
.L555:
	move.b 6(%a0,%d1.l),%d2
	moveq #127,%d4
	addq.l #1,%d1
	and.l %d4,%d2
	move.b %d2,-1(%a1,%d1.l)
	mov3q.l #6,%d2
	cmp.l %d1,%d2
	jne .L555
	move.b %d3,jn_mailbox+12
	addq.l #1,%d0
	move.b %d0,jn_mailbox+11
.L554:
	movem.l (%sp),#28
	mov3q.l #1,%d0
	lea (12,%sp),%sp
	rts
.L553:
	move.l %d0,%d2
	add.l #-22,%d2
	mvz.b %d2,%d2
	lsr.l #1,%d2
	jne .L554
	mov3q.l #7,%d4
	cmp.l %d1,%d4
	jge .L554
	tst.b 5(%a0)
	jeq .L556
	lea jn_mailbox+37,%a1
	moveq #127,%d0
.L557:
	clr.b (%a1)
	subq.l #1,%d0
	lea (10,%a1),%a1
	tst.l %d0
	jne .L557
	move.b 6(%a0),%d0
	jpl .L558
	moveq #127,%d0
.L558:
	move.b %d0,jn_mailbox+9
	move.b 4(%a0),%d0
	add.l #-22,%d0
	move.b %d0,jn_mailbox+19
	moveq #1,%d0
	move.b %d0,jn_mailbox+8
.L559:
	subq.l #1,%d1
	addq.l #7,%a0
	moveq #8,%d2
.L560:
	move.l %d2,%d0
	add.l #12,%d0
	cmp.l %d1,%d0
	jge .L554
	move.b (%a0),%d0
	moveq #126,%d4
	mvz.b %d0,%d3
	cmp.l %d3,%d4
	jcs .L561
	ext.w %d0
	mulu.w #10,%d0
	move.l %d0,%a1
	clr.l %d0
	add.l #jn_mailbox+37,%a1
.L562:
	move.b 1(%a0,%d0.l),%d3
	jeq .L563
	move.b %d3,(%a1,%d0.l)
	addq.l #1,%d0
	moveq #9,%d3
	cmp.l %d0,%d3
	jne .L562
.L563:
	clr.b %d4
	move.b %d4,(%a1,%d0.l)
.L561:
	add.l #14,%d2
	lea (14,%a0),%a0
	jra .L560
.L556:
	moveq #22,%d2
	eor.l %d2,%d0
	mvz.b jn_mailbox+19,%d2
	tst.b %d0
	sne %d0
	neg.l %d0
	mvz.b %d0,%d0
	cmp.l %d2,%d0
	jne .L554
	jra .L559
	.size	jn_sysex, .-jn_sysex
	.section	.us2
	.align	2
	.globl	us_sysex
	.type	us_sysex, @function
us_sysex:
	move.l %d2,-(%sp)
	moveq #23,%d2
	move.l 8(%sp),%a0
	move.l 12(%sp),%d0
	mvz.b 4(%a0),%d1
	cmp.l %d1,%d2
	jcs .L572
	move.l %d0,12(%sp)
	move.l %a0,8(%sp)
	move.l (%sp)+,%d2
	jra jn_sysex
.L572:
	mov3q.l #7,%d2
	cmp.l %d0,%d2
	jge .L573
	mvz.b 5(%a0),%d2
	move.l %d2,%a1
	mov3q.l #1,%d2
	cmp.l %a1,%d2
	jne .L573
	moveq #26,%d2
	cmp.l %d1,%d2
	jne .L574
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr us_meta_in
.L577:
	addq.l #8,%sp
.L573:
	mov3q.l #1,%d0
	move.l (%sp)+,%d2
	rts
.L574:
	moveq #27,%d2
	cmp.l %d1,%d2
	jne .L575
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr us_list_in
	jra .L577
.L575:
	moveq #28,%d2
	cmp.l %d1,%d2
	jne .L576
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr us_knobs_in
	jra .L577
.L576:
	moveq #29,%d2
	cmp.l %d1,%d2
	jne .L573
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr us_slots_in
	jra .L577
	.size	us_sysex, .-us_sysex
	.section	.exto
	.align	2
	.globl	us_set
	.type	us_set, @function
us_set:
	subq.l #4,%sp
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d2
	move.l 28(%sp),%d3
	move.l 24(%sp),8(%sp)
	move.l 20(%sp),-(%sp)
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr 1074918394
	jsr 1075398168
	lea (12,%sp),%sp
	move.l %d3,28(%sp)
	move.l 8(%sp),24(%sp)
	move.l %d2,20(%sp)
	move.l %d0,16(%sp)
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	addq.l #4,%sp
	jmp 1073952092
	.size	us_set, .-us_set
	.section	.us2
	.align	2
	.type	us_writeback, @function
us_writeback:
	lea (-56,%sp),%sp
	movem.l #31868,(%sp)
	clr.l %d4
	clr.l %d5
	lea us,%a4
.L590:
	move.l us+24,%a0
	add.l %d4,%a0
	move.b 1(%a0),%d1
	btst #0,%d1
	jne .L580
	mvz.b 2(%a0),%d0
	mvz.b %d1,%d3
	cmp.l %d0,%d3
	jeq .L580
	move.w 4(%a0),%d2
	move.b (%a0),%d0
	move.w %d0,%a6
	clr.l %d0
.L581:
	lea 6(%a0,%d0.l),%a1
	moveq #16,%d6
	move.b (%a1),40(%sp,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d6
	jne .L581
	mvz.b 1(%a0),%d0
	cmp.l %d0,%d3
	jne .L580
	move.b %d1,2(%a0)
	move.w %a6,%d0
	move.l #-2147423744,%a0
	mvz.b (%a0,%d5.l),%d1
	mvz.b %d0,%d3
	move.l %d3,%d0
	add.l #34,%d0
	cmp.l %d1,%d0
	jne .L580
	add.l #-35,%d0
	move.l (%a4,%d0.l*4),%a2
	tst.l %a2
	jeq .L580
	move.l %d0,-(%sp)
	jsr us_params
	addq.l #4,%sp
	tst.l %d0
	jne .L582
	mvz.b %d2,%d2
.L582:
	lsl.l #3,%d3
	mvz.w %d2,%d2
	lea us_p2rec,%a3
	sub.l %a6,%a6
	lea (36,%a2),%a2
	lea us_set,%a5
	add.l #326,%d3
.L589:
	move.l %a6,%d0
	btst %d0,%d2
	jeq .L583
	mvz.b 40(%sp,%a6.l),%d1
	tst.b (%a2)
	jeq .L591
	mvz.b 4(%a2),%d0
	cmp.l %d0,%d1
	jlt .L585
	mvz.b 5(%a2),%d0
.L584:
	cmp.l %d0,%d1
	jge .L585
	move.l %d1,%d0
.L585:
	lsl.l #8,%d0
	mov3q.l #7,%d1
	cmp.l %a6,%d1
	jlt .L587
	move.l %d3,%d1
	add.l %a6,%d1
.L588:
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	pea 9(%a6)
	move.l %d5,-(%sp)
	jsr (%a5)
	lea (16,%sp),%sp
.L583:
	addq.l #1,%a6
	addq.l #2,%a3
	lea (28,%a2),%a2
	moveq #16,%d6
	cmp.l %a6,%d6
	jne .L589
.L580:
	addq.l #1,%d5
	add.l #28,%d4
	moveq #12,%d0
	cmp.l %d5,%d0
	jne .L590
	movem.l (%sp),#31868
	lea (56,%sp),%sp
	rts
.L591:
	moveq #127,%d0
	jra .L584
.L587:
	mvs.w -16(%a3),%d1
	jra .L588
	.size	us_writeback, .-us_writeback
	.section	.us6
	.align	2
	.type	us_defaults, @function
us_defaults:
	lea (-48,%sp),%sp
	movem.l #31996,(%sp)
	move.l 56(%sp),%d4
	lea us,%a0
	move.l 52(%sp),%d2
	move.l (%a0,%d4.l*4),%a3
	move.l %d4,-(%sp)
	lea (36,%a3),%a2
	jsr us_params
	addq.l #4,%sp
	tst.l %d0
	jeq .L609
	move.w #16,%a4
.L602:
	mvz.w %d4,%d5
	move.w #18,%a6
	mvz.b 63(%sp),%d7
	move.w 34(%a3),%d6
	lsl.l #3,%d5
	sub.l %a5,%a5
	lea us_kit_sound,%a3
	add.l #334,%d5
	move.l %d5,44(%sp)
.L607:
	tst.b (%a2)
	jeq .L610
	move.b 6(%a2),%d3
.L603:
#APP
| 2009 "ext.c" 1
	move.w %sr,%d5
	move.l %d5,%d1
	ori.l #0x0700,%d1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
	move.l %d7,-(%sp)
	move.l %d4,-(%sp)
	move.l %d2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	lea (9,%a5),%a1
	tst.l %d0
	jeq .L604
	clr.b %d1
	move.b %d3,(%a6,%d0.l)
	move.b %d1,1(%a6,%d0.l)
.L604:
#APP
| 2014 "ext.c" 1
	move.w %d5,%sr
| 0 "" 2
#NO_APP
	mvz.b %d3,%d3
	mov3q.l #7,%d0
	lsl.l #8,%d3
	cmp.l %a5,%d0
	jlt .L605
	move.l 44(%sp),%d0
	add.l %a5,%d0
.L606:
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	move.l %a1,-(%sp)
	move.l %d2,-(%sp)
	jsr us_set
	addq.l #1,%a5
	lea (28,%a2),%a2
	addq.l #2,%a6
	lea (16,%sp),%sp
	cmp.l %a4,%a5
	jne .L607
#APP
| 2043 "ext.c" 1
	move.w %sr,%d3
	move.l %d3,%d1
	ori.l #0x0700,%d1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
	move.l %d7,-(%sp)
	move.l %d4,-(%sp)
	move.l %d2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L608
	move.l %d6,%d1
	lsr.l #8,%d1
	move.l %d0,%a0
	move.b %d1,90(%a0)
	move.b %d6,91(%a0)
	lea us_tag,%a0
	move.w %d6,(%a0,%d2.l*2)
	mulu.w #162,%d2
	move.l %d2,%a0
	add.l #1081497997,%a0
	move.b %d1,(%a0)
	move.b %d6,1(%a0)
.L608:
#APP
| 2051 "ext.c" 1
	move.w %d3,%sr
| 0 "" 2
#NO_APP
	movem.l (%sp),#31996
	lea (48,%sp),%sp
	rts
.L609:
	move.w #8,%a4
	jra .L602
.L610:
	moveq #64,%d3
	jra .L603
.L605:
	lea us_p2rec-34,%a0
	mvs.w (%a0,%a6.l),%d0
	jra .L606
	.size	us_defaults, .-us_defaults
	.section	.extq
	.align	2
	.globl	diag_desc
	.type	diag_desc, @function
diag_desc:
	pea 410.w
	pea 444.w
	jsr copy_desc
	addq.l #8,%sp
	move.l #diag_text,%d0
	move.l %d0,1100667480
	rts
	.size	diag_desc, .-diag_desc
	.section	.exto
	.align	2
	.globl	mod_desc
	.type	mod_desc, @function
mod_desc:
	pea 410.w
	pea 444.w
	jsr copy_desc
	addq.l #8,%sp
	move.l #mod_text,%d0
	move.l %d0,1100667480
	move.l #mod_long,%d0
	move.l %d0,1075598192
	move.l #mod_short,%d0
	move.l %d0,1075598200
	rts
	.size	mod_desc, .-mod_desc
	.section	.ext7
	.align	2
	.globl	dsp_descriptors2
	.type	dsp_descriptors2, @function
dsp_descriptors2:
	lea (-12,%sp),%sp
	movem.l #7168,(%sp)
	move.w #430,%a3
	lea copy_desc,%a4
	move.l %a4,%a2
.L621:
	pea 410.w
	move.l %a3,-(%sp)
	jsr (%a4)
	addq.l #1,%a3
	addq.l #8,%sp
	cmp.l #438,%a3
	jne .L621
	move.l #dsp_out_text,%d0
	mov3q.l #6,%a3
	move.l %d0,1100666556
	lea dsps_rec,%a4
.L622:
	pea 410.w
	mvs.w (%a4)+,%d0
	subq.l #1,%a3
	move.l %d0,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
	tst.l %a3
	jne .L622
	move.l #dsp_engine_text,%d0
	move.l %d0,1100665128
	pea 100.w
	pea 420.w
	jsr (%a2)
	pea 101.w
	move.w #441,%a3
	pea 421.w
	jsr (%a2)
	lea (16,%sp),%sp
.L623:
	pea -402(%a3)
	move.l %a3,-(%sp)
	jsr (%a2)
	addq.l #1,%a3
	addq.l #8,%sp
	cmp.l #449,%a3
	jne .L623
	pea 410.w
	pea 443.w
	jsr (%a2)
	pea 410.w
	pea 441.w
	jsr (%a2)
	lea (16,%sp),%sp
#APP
| 772 "ext.c" 1
	movel #P_DIAG,%d0
| 0 "" 2
#NO_APP
	tst.l %d0
	jeq .L624
	movem.l (%sp),#7168
	lea (12,%sp),%sp
	jra diag_desc
.L624:
	movem.l (%sp),#7168
	lea (12,%sp),%sp
	jra mod_desc
	.size	dsp_descriptors2, .-dsp_descriptors2
	.section	.ext5
	.align	2
	.globl	dsp_descriptors
	.type	dsp_descriptors, @function
dsp_descriptors:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	mvz.w #449,%d2
	lea copy_desc,%a2
.L629:
	pea 410.w
	move.l %d2,-(%sp)
	jsr (%a2)
	addq.l #1,%d2
	addq.l #8,%sp
	cmp.l #455,%d2
	jne .L629
	move.l #dsp_engine_text,%d0
	move.l %d0,1100667900
	move.l #dsp_input_text,%d0
	move.l %d0,1100668236
	pea 100.w
	move.l %d2,-(%sp)
	jsr (%a2)
	pea 101.w
	pea 456.w
	jsr (%a2)
	lea (16,%sp),%sp
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	jra dsp_descriptors2
	.size	dsp_descriptors, .-dsp_descriptors
	.section	.ext2
	.align	2
	.globl	ext_descriptors
	.type	ext_descriptors, @function
ext_descriptors:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	pea 410.w
	pea 408.w
	lea copy_desc,%a2
	jsr (%a2)
	mvz.w #424,%d2
	move.l #ext_engine_text,%d0
	move.l %d0,1100664456
	pea 410.w
	pea 409.w
	jsr (%a2)
	pea 100.w
	pea 414.w
	jsr (%a2)
	pea 101.w
	pea 415.w
	jsr (%a2)
	lea (32,%sp),%sp
	pea 40.w
	pea 422.w
	jsr (%a2)
	pea 40.w
	pea 423.w
	jsr (%a2)
	lea (16,%sp),%sp
.L632:
	pea 410.w
	move.l %d2,-(%sp)
	jsr (%a2)
	addq.l #1,%d2
	addq.l #8,%sp
	cmp.l #429,%d2
	jne .L632
	pea 101.w
	move.l %d2,-(%sp)
	jsr (%a2)
	jsr dsp_descriptors
	jsr dd_descriptors
	jsr jn_descriptors
	moveq #1,%d0
	addq.l #8,%sp
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	move.b %d0,ext_desc_done
	rts
	.size	ext_descriptors, .-ext_descriptors
	.section	.extw,"ax",@progbits
	.align	2
	.globl	ext_vflag
	.type	ext_vflag, @function
ext_vflag:
	move.l 4(%sp),%d0
	moveq #17,%d1
	add.l #-35,%d0
	cmp.l %d0,%d1
	jcs .L636
	lea us_flag_tab,%a0
	mvz.b (%a0,%d0.l),%d0
.L634:
	rts
.L636:
	clr.l %d0
	jra .L634
	.size	ext_vflag, .-ext_vflag
	.section	.us1
	.align	2
	.globl	ext_layer_kept
	.type	ext_layer_kept, @function
ext_layer_kept:
	move.l %d2,-(%sp)
	moveq #120,%d0
	and.l 8(%sp),%d0
	moveq #64,%d1
	cmp.l %d0,%d1
	jeq .L639
	move.l %d0,%d1
	moveq #32,%d2
	add.l #-80,%d1
	cmp.l %d1,%d2
	jcs .L640
	asr.l #3,%d0
	lea us,%a0
	mvz.b 31(%a0,%d0.l),%d0
.L637:
	move.l (%sp)+,%d2
	rts
.L639:
	mov3q.l #1,%d0
	jra .L637
.L640:
	clr.l %d0
	jra .L637
	.size	ext_layer_kept, .-ext_layer_kept
	.text
	.align	2
	.globl	ext_render_body
	.type	ext_render_body, @function
ext_render_body:
	lea (-108,%sp),%sp
	movem.l #23580,(%sp)
	move.l 112(%sp),%a3
	move.l %a3,%d0
	lsl.l #5,%d0
	move.l #1076432344,%a2
	moveq #120,%d4
	add.l %a3,%a2
	move.l #-2147423744,%a0
	move.l %a3,%d2
	move.l %d0,%a4
	add.l #-2147418376,%a4
	mvz.b (%a2),%d0
	move.l (%a4),%a6
	mvz.b (%a0,%d0.l),%d0
	move.l %d0,-(%sp)
	jsr ext_vflag
	addq.l #4,%sp
	mov3q.l #7,%d1
	and.l %d1,%d2
	moveq #16,%d1
	move.l %d2,%d3
	or.l %d0,%d3
	and.l %d4,%d0
	cmp.l %d0,%d1
	jeq .L642
.L644:
	clr.l (%a4)
	move.l 124(%sp),-(%sp)
	move.l 124(%sp),-(%sp)
	move.l 124(%sp),-(%sp)
	move.l %a3,-(%sp)
	jsr 1074872060
	mov3q.l #1,(%a4)
	lea (16,%sp),%sp
	clr.l %d0
.L643:
	move.l %a3,-(%sp)
	move.l %d0,32(%sp)
	jsr ext_gate
	addq.l #4,%sp
	mov3q.l #2,%d4
	cmp.l 28(%sp),%d4
	jeq .L645
	move.l %d3,%d0
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	jsr ext_layer_kept
	addq.l #4,%sp
	tst.l %d0
	jne .L645
	move.l %d2,%d0
	add.l #-268431872,%d0
	lsl.l #3,%d0
	move.l %d0,%a0
	move.l %d2,%d0
	lsl.l #3,%d0
	clr.l (%a0)
	move.l %d0,%a0
	add.l #-2147454972,%a0
	clr.l (%a0)
.L645:
	move.w %d2,%d0
	clr.l %d1
	sub.l %a0,%a0
	mulu.w #70,%d0
	move.l %d0,%a3
	add.l #ext_state,%a3
.L646:
	move.l 120(%sp),%a1
	mvz.w (%a1,%d1.l),%d0
	move.w (%a3,%d1.l),%a1
	addq.l #2,%d1
	lsr.l #1,%d0
	and.l #16383,%d0
	move.l %a1,%d4
	move.w %d0,30(%sp,%d1.l)
	eor.l %d4,%d0
	move.l %a0,%d4
	tst.w %d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d4
	moveq #32,%d0
	move.l %d4,%a0
	cmp.l %d1,%d0
	jne .L646
	tst.l %a6
	jne .L647
	moveq #70,%d0
	moveq #127,%d4
	muls.l %d2,%d0
	moveq #1,%d1
	move.l #-2147457084,%a1
	move.l %d0,%a0
	add.l #ext_state,%a0
	move.l 124(%sp),%d0
	swap %d0
	ext.l %d0
	move.b %d1,66(%a0)
	and.l %d4,%d0
	move.b %d0,64(%a0)
	mvz.b (%a2),%d0
	move.b (%a1,%d0.l*2),%d0
	and.l %d4,%d0
	move.b %d0,65(%a0)
.L648:
	clr.l %d0
.L650:
	lea 32(%sp,%d0.l),%a0
	moveq #32,%d1
	move.w (%a0),32(%a3,%d0.l)
	addq.l #2,%d0
	cmp.l %d0,%d1
	jne .L650
	moveq #70,%d0
	muls.l %d2,%d0
	move.l %d0,%a0
	add.l #ext_state+67,%a0
	move.b #1,(%a0)
	jra .L649
.L642:
	move.l 124(%sp),-(%sp)
	move.l 124(%sp),-(%sp)
	move.l 124(%sp),-(%sp)
	move.l %a3,-(%sp)
	jsr dsp_excite
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L644
	jra .L643
.L647:
	tst.l %d4
	jne .L648
	moveq #70,%d0
	muls.l %d2,%d0
	move.l %d0,%a0
	add.l #ext_state+66,%a0
	tst.b (%a0)
	jne .L648
.L649:
	moveq #70,%d4
	muls.l %d4,%d2
	lea ext_state,%a6
	move.b 68(%a6,%d2.l),%d0
	jeq .L652
	subq.l #1,%d0
	move.b %d0,68(%a6,%d2.l)
.L652:
	lea (%a6,%d2.l),%a0
	tst.b 67(%a0)
	jeq .L641
	move.b 66(%a0),%d0
	jne .L654
	tst.b 68(%a0)
	jne .L641
.L654:
	move.l #-260222380,%a0
	move.l %a0,64(%sp)
	tst.b %d0
	jeq .L655
	moveq #4,%d0
	lea 64(%a6,%d2.l),%a0
	move.b %d3,69(%sp)
	move.b %d0,68(%sp)
	move.w (%a0),70(%sp)
	move.w #8,%a0
.L656:
	lea (64,%sp),%a4
	clr.l %d0
	lea (%a4,%a0.l),%a1
.L657:
	move.w 32(%a3,%d0.l),%d1
	moveq #127,%d4
	addq.l #2,%d0
	addq.l #2,%a1
	move.l %d1,%d3
	lsr.l #7,%d3
	and.l %d4,%d1
	and.l %d4,%d3
	move.b %d1,-1(%a1)
	moveq #32,%d1
	move.b %d3,-2(%a1)
	cmp.l %d0,%d1
	jne .L657
	mvz.b (%a2),%d0
	lea us_tag,%a1
	moveq #-9,%d3
	move.w (%a1,%d0.l*2),%d0
	move.b %d3,98(%sp,%a0.l)
	move.l %d0,%d1
	lsr.l #7,%d1
	and.l %d4,%d0
	and.l %d4,%d1
	move.b %d0,97(%sp,%a0.l)
	move.b %d1,96(%sp,%a0.l)
	pea 35(%a0)
	move.l %a4,-(%sp)
	jsr ext_try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L641
	clr.l %d0
.L658:
	move.w 32(%a3),(%a3)
	addq.l #2,%a3
	addq.l #1,%d0
	moveq #16,%d4
	cmp.l %d0,%d4
	jne .L658
	clr.w %d0
	moveq #16,%d1
	move.w %d0,66(%a6,%d2.l)
	move.b %d1,68(%a6,%d2.l)
.L641:
	movem.l (%sp),#23580
	lea (108,%sp),%sp
	rts
.L655:
	moveq #3,%d0
	move.b %d3,69(%sp)
	mov3q.l #6,%a0
	move.b %d0,68(%sp)
	jra .L656
	.size	ext_render_body, .-ext_render_body
	.section	.extw
	.align	2
	.globl	ext_render
	.type	ext_render, @function
ext_render:
	subq.l #4,%sp
	move.l -66617332,(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	jsr ext_render_body
	move.l -66617332,%d0
	sub.l 16(%sp),%d0
	lea (16,%sp),%sp
	cmp.l ext_diag_max.l,%d0
	jls .L676
	move.l %d0,ext_diag_max
.L676:
	addq.l #4,%sp
	rts
	.size	ext_render, .-ext_render
	.section	.us1
	.align	2
	.globl	us_page_record
	.type	us_page_record, @function
us_page_record:
	lea (-24,%sp),%sp
	moveq #12,%d1
	movem.l #7196,(%sp)
	move.l 28(%sp),%d2
	move.l %d2,%d0
	move.l 32(%sp),%d3
	add.l #-40,%d0
	cmp.l %d0,%d1
	jcs .L679
	mvz.w #5057,%d1
	btst %d0,%d1
	jeq .L680
	move.l us_cubox+4,%a0
	tst.l %a0
	jeq .L681
	clr.b %d0
	move.l %d2,-(%sp)
	move.b %d0,us+48
	jsr (%a0)
	addq.l #4,%sp
	moveq #40,%d1
	cmp.l %d2,%d1
	jne .L699
	mov3q.l #3,%d0
	cmp.l %d3,%d0
	jcs .L699
.L681:
	clr.l %d0
.L678:
	movem.l (%sp),#7196
	lea (24,%sp),%sp
	rts
.L680:
	moveq #44,%d1
	cmp.l %d2,%d1
	jne .L684
	lea ext_p2_order,%a0
.L700:
	move.l (%a0,%d3.l*4),%d0
	jra .L678
.L684:
	moveq #51,%d0
	cmp.l %d2,%d0
	jne .L685
	lea dsp_p2_order,%a0
	jra .L700
.L685:
	moveq #45,%d1
	cmp.l %d2,%d1
	jne .L681
	lea dsps_p2_order,%a0
	jra .L700
.L679:
	move.l %d2,%d4
	mov3q.l #4,%d0
	add.l #-35,%d4
	cmp.l %d4,%d0
	jcs .L681
	move.l %d4,-(%sp)
	jsr us_params
	addq.l #4,%sp
	tst.l %d0
	jeq .L678
	mvz.b us+48,%d0
	lea us,%a0
	add.l #-34,%d2
	move.l (%a0,%d4.l*4),%a2
	cmp.l %d0,%d2
	jeq .L686
.L688:
	lea us_p2rec,%a3
	moveq #8,%d2
	lea us_record,%a4
.L687:
	mvs.w (%a3)+,%d1
	pea us_text
	move.l %d2,-(%sp)
	move.l %d4,-(%sp)
	move.l %d1,-(%sp)
	jsr (%a4)
	addq.l #1,%d2
	lea (16,%sp),%sp
	moveq #16,%d0
	cmp.l %d2,%d0
	jne .L687
	addq.l #1,%d4
	move.b %d4,us+48
	move.b (%a2),us+49
	jra .L689
.L686:
	mvz.b us+49,%d1
	mvz.b (%a2),%d0
	cmp.l %d1,%d0
	jne .L688
.L689:
	move.l %d3,%d0
	moveq #28,%d1
	addq.l #8,%d0
	muls.l %d1,%d0
	add.l %d0,%a2
	tst.b 36(%a2)
	jne .L690
.L691:
	mov3q.l #-1,%d0
	jra .L678
.L690:
	tst.b 44(%a2)
	jeq .L691
.L699:
	lea us_p2rec,%a0
	mvs.w (%a0,%d3.l*2),%d0
	jra .L678
	.size	us_page_record, .-us_page_record
	.section	.ext4
	.align	2
	.globl	ext_page_record
	.type	ext_page_record, @function
ext_page_record:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.l 12(%sp),%a2
	move.l (%a2),%a0
	move.l %a2,-(%sp)
	move.l 104(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l %d0,%d2
	mov3q.l #7,%d0
	cmp.l 16(%sp),%d0
	jcs .L705
	move.l %d2,%d0
	subq.l #4,%d0
	lsr.l #1,%d0
	jne .L703
	move.l %a2,-(%sp)
	jsr ext_view_machine
	move.l 20(%sp),-(%sp)
	move.l %d0,-(%sp)
	jsr us_page_record
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L703
	jge .L701
.L705:
	clr.l %d0
	jra .L701
.L703:
	move.l %d2,-(%sp)
	jsr 1074787700
	move.l 20(%sp),%d1
	addq.l #1,%d1
	mvz.w %d1,%d1
	addq.l #4,%sp
	move.l %d0,%a0
	move.l (%a0,%d1.l*4),%d0
.L701:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
	.size	ext_page_record, .-ext_page_record
	.section	.us1
	.align	2
	.globl	us_page_title
	.type	us_page_title, @function
us_page_title:
	move.l %d2,-(%sp)
	moveq #44,%d1
	move.l 8(%sp),%d0
	cmp.l %d0,%d1
	jne .L710
	move.l #ext_p2_title,%d0
.L709:
	move.l (%sp)+,%d2
	rts
.L710:
	moveq #51,%d1
	cmp.l %d0,%d1
	jne .L712
	move.l #dsp_p2_title,%d0
	jra .L709
.L712:
	moveq #45,%d1
	cmp.l %d0,%d1
	jne .L713
	move.l #dsps_p2_title,%d0
	jra .L709
.L713:
	move.l %d0,%d2
	mov3q.l #4,%d0
	add.l #-35,%d2
	cmp.l %d2,%d0
	jcs .L715
	move.l %d2,-(%sp)
	jsr us_params
	addq.l #4,%sp
	tst.l %d0
	jeq .L709
	lea us,%a0
	move.l (%a0,%d2.l*4),%d0
	move.l %d0,%a0
	tst.b 20(%a0)
	jeq .L714
	add.l #20,%d0
	jra .L709
.L714:
	addq.l #4,%d0
	jra .L709
.L715:
	clr.l %d0
	jra .L709
	.size	us_page_title, .-us_page_title
	.section	.ext4
	.align	2
	.globl	ext_page_title
	.type	ext_page_title, @function
ext_page_title:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.l 12(%sp),%a2
	move.l (%a2),%a0
	move.l %a2,-(%sp)
	move.l 104(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l %d0,%d2
	subq.l #4,%d0
	lsr.l #1,%d0
	jeq .L720
.L722:
	move.l %d2,-(%sp)
	jsr 1074787700
	addq.l #4,%sp
	move.l %d0,%a0
	move.l (%a0),%d0
.L719:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L720:
	move.l %a2,-(%sp)
	jsr ext_view_machine
	move.l %d0,-(%sp)
	jsr us_page_title
	addq.l #8,%sp
	tst.l %d0
	jeq .L722
	jra .L719
	.size	ext_page_title, .-ext_page_title
	.section	.us1
	.align	2
	.globl	us_param_record
	.type	us_param_record, @function
us_param_record:
	lea (-12,%sp),%sp
	moveq #44,%d0
	movem.l #28,(%sp)
	move.l 20(%sp),%d3
	move.l 16(%sp),%d2
	cmp.l %d3,%d0
	jne .L727
	add.l #405,%d2
.L726:
	move.l %d2,%d0
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L727:
	moveq #51,%d1
	cmp.l %d3,%d1
	jne .L729
	add.l #413,%d2
	jra .L726
.L729:
	move.l %d2,%d4
	moveq #45,%d0
	add.l #-17,%d4
	cmp.l %d3,%d0
	jne .L730
	tst.l %d4
	jeq .L734
	subq.l #2,%d4
	tst.l %d4
	jeq .L735
	add.l #424,%d2
	jra .L726
.L730:
	move.l %d3,%d0
	mov3q.l #4,%d1
	add.l #-35,%d0
	cmp.l %d0,%d1
	jcs .L731
	move.l %d0,-(%sp)
	jsr us_params
	addq.l #4,%sp
	tst.l %d0
	jeq .L731
.L733:
	lea us_p2rec,%a0
	mvs.w (%a0,%d4.l*2),%d2
	jra .L726
.L731:
	tst.l us_cubox+4
	jeq .L732
	moveq #52,%d0
	cmp.l %d3,%d0
	jeq .L733
	move.l %d3,%d0
	mov3q.l #3,%d1
	add.l #-46,%d0
	cmp.l %d0,%d1
	jcc .L733
	moveq #40,%d0
	cmp.l %d3,%d0
	jne .L732
	cmp.l %d4,%d1
	jlt .L733
.L732:
	add.l #22,%d2
	jra .L726
.L734:
	moveq #39,%d2
	jra .L726
.L735:
	mvz.w #441,%d2
	jra .L726
	.size	us_param_record, .-us_param_record
	.section	.ext4
	.align	2
	.globl	ext_param_record
	.type	ext_param_record, @function
ext_param_record:
	move.l %d2,-(%sp)
	moveq #41,%d2
	move.l 8(%sp),%d0
	move.l 12(%sp),%d1
	cmp.l %d0,%d2
	jcc .L746
.L749:
	clr.l %d0
.L745:
	move.l (%sp)+,%d2
	rts
.L746:
	move.l %d0,%a0
	mov3q.l #7,%d2
	lea (-9,%a0),%a0
	cmp.l %a0,%d2
	jcs .L748
	moveq #52,%d2
	cmp.l %d1,%d2
	jcs .L749
	lsl.l #3,%d1
	move.l #1094563324,%a0
	add.l %d1,%d0
	move.l -36(%a0,%d0.l*4),%d0
	jra .L745
.L748:
	move.l %d0,%a0
	mov3q.l #7,%d2
	lea (-17,%a0),%a0
	cmp.l %a0,%d2
	jcs .L750
	move.l %d1,12(%sp)
	move.l %d0,8(%sp)
	move.l (%sp)+,%d2
	jra us_param_record
.L750:
	move.l #1094563156,%a0
	move.l (%a0,%d0.l*4),%d0
	jra .L745
	.size	ext_param_record, .-ext_param_record
	.section	.us2
	.align	2
	.globl	us_fetch
	.type	us_fetch, @function
us_fetch:
	lea (-32,%sp),%sp
	movem.l #31756,(%sp)
	move.l us+20,%a2
	move.l 36(%sp),%d3
	lea us,%a4
	tst.l %a2
	jeq .L751
	move.l (%a4,%d3.l*4),%a3
	tst.l %a3
	jeq .L751
	move.l %d3,%d1
	addq.l #1,%d1
	clr.l %d2
	lea us_commit,%a5
	move.l %d1,28(%sp)
	lea us_ask,%a6
.L756:
	mvz.b 3(%a2),%d0
	cmp.l #255,%d0
	jne .L753
	jsr (%a5)
.L753:
	mvz.b 28(%a4,%d3.l),%d1
	mvz.b (%a3),%d0
	cmp.l %d0,%d1
	jeq .L751
	tst.l %d2
	jeq .L754
	moveq #25,%d1
	cmp.l %d2,%d1
	jne .L755
.L754:
	clr.l -(%sp)
	clr.l -(%sp)
	move.l %d0,-(%sp)
	move.l 40(%sp),-(%sp)
	jsr (%a6)
	lea (16,%sp),%sp
.L755:
	pea 10000.w
	jsr 1074367512
	addq.l #1,%d2
	addq.l #4,%sp
	moveq #50,%d0
	cmp.l %d2,%d0
	jne .L756
.L751:
	movem.l (%sp),#31756
	lea (32,%sp),%sp
	rts
	.size	us_fetch, .-us_fetch
	.section	.ust,"ax",@progbits
	.align	2
	.globl	us_tag_load_c
	.type	us_tag_load_c, @function
us_tag_load_c:
	move.l %d2,-(%sp)
	move.l 12(%sp),%a0
	move.b 122(%a0),%d0
	move.b 123(%a0),%d1
	mvz.b 124(%a0),%d2
	move.l %d2,%a1
	mov3q.l #4,%d2
	lea (-35,%a1),%a1
	cmp.l %a1,%d2
	jcs .L773
	mvz.b %d0,%d0
	mvz.b %d1,%d1
	lsl.l #8,%d0
	or.l %d1,%d0
	jne .L769
	move.b 110(%a0),%d0
	move.b 111(%a0),%d1
	or.l %d1,%d0
	tst.b %d0
	jne .L770
.L773:
	clr.l %d0
	jra .L771
.L770:
	move.b 110(%a0),%d0
	mvz.b 111(%a0),%d1
	lsl.l #8,%d0
	or.l %d1,%d0
	clr.b %d1
	and.l #16383,%d0
	move.b %d1,110(%a0)
	move.b %d1,111(%a0)
	move.l %d0,%d1
	lsr.l #8,%d1
	move.b %d1,122(%a0)
	move.b %d0,123(%a0)
.L771:
	move.l %d0,%d1
	lsr.l #8,%d1
	move.l 8(%sp),%a0
	move.b %d1,110(%a0)
	move.b %d0,111(%a0)
	move.l (%sp)+,%d2
	rts
.L769:
	cmp.l #16383,%d0
	jhi .L773
	jra .L771
	.size	us_tag_load_c, .-us_tag_load_c
	.align	2
	.globl	us_tag_save_c
	.type	us_tag_save_c, @function
us_tag_save_c:
	move.l 8(%sp),%a0
	mov3q.l #4,%d1
	move.l 4(%sp),%a1
	mvz.b 104(%a0),%d0
	add.l #-35,%d0
	cmp.l %d0,%d1
	jcs .L774
	move.b 110(%a0),%d0
	moveq #63,%d1
	and.l %d1,%d0
	move.b %d0,122(%a1)
	move.b 111(%a0),123(%a1)
.L774:
	rts
	.size	us_tag_save_c, .-us_tag_save_c
	.align	2
	.globl	us_tag_copy_c
	.type	us_tag_copy_c, @function
us_tag_copy_c:
	move.l 8(%sp),%a1
	moveq #12,%d0
	move.l 4(%sp),%a0
	cmp.l %a1,%d0
	jcs .L776
	mvz.b 104(%a0),%d0
	mov3q.l #4,%d1
	add.l #-35,%d0
	cmp.l %d0,%d1
	jcs .L779
	move.b 110(%a0),%d1
	mvz.b 111(%a0),%d0
	lsl.l #8,%d1
	or.l %d1,%d0
	and.l #16383,%d0
.L778:
	lea us_tag,%a0
	move.w %d0,(%a0,%a1.l*2)
.L776:
	rts
.L779:
	clr.w %d0
	jra .L778
	.size	us_tag_copy_c, .-us_tag_copy_c
	.section	.us3
	.align	2
	.globl	us_confirm
	.type	us_confirm, @function
us_confirm:
	clr.b %d1
	move.b us+51,%d0
	move.b %d1,us+51
	tst.l 4(%sp)
	jeq .L780
	mvz.b %d0,%d0
	moveq #11,%d1
	subq.l #1,%d0
	cmp.l %d0,%d1
	jcs .L780
	move.l %d0,4(%sp)
	jra us_choose
.L780:
	rts
	.size	us_confirm, .-us_confirm
	.section	.us5,"ax",@progbits
	.align	2
	.globl	us_step
	.type	us_step, @function
us_step:
	move.l 8(%sp),%d0
	cmp.l #1074610394,%d0
	jne .L786
	move.l 4(%sp),%d0
	addq.l #1,%d0
	move.b %d0,us+51
.L785:
	rts
.L786:
	cmp.l #1074722430,%d0
	jne .L785
	jra us_choose
	.size	us_step, .-us_step
	.align	2
	.globl	us_loaded
	.type	us_loaded, @function
us_loaded:
	move.b us+52,%d0
	move.l us+24,%a0
	addq.l #1,%d0
	move.b %d0,us+52
	clr.b %d0
	move.b %d0,us+51
	tst.l %a0
	jeq .L788
	addq.l #3,%a0
	moveq #12,%d0
.L790:
	clr.b (%a0)
	lea (28,%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L790
.L788:
	rts
	.size	us_loaded, .-us_loaded
	.section	.us6
	.align	2
	.globl	us_tick3
	.type	us_tick3, @function
us_tick3:
	lea (-32,%sp),%sp
	moveq #11,%d0
	movem.l #3196,(%sp)
	lea us,%a2
	mvz.b 1093765506,%d3
	cmp.l %d3,%d0
	jge .L796
	clr.l %d3
.L796:
	move.l #-2147423744,%a0
	move.b (%a0,%d3.l),%d2
	clr.l -(%sp)
	mvz.b %d2,%d0
	move.l %d0,%d4
	add.l #-35,%d4
	move.l %d0,-(%sp)
	jsr us_page_record
	addq.l #8,%sp
	mov3q.l #4,%d1
	cmp.l %d4,%d1
	jcs .L797
	move.l (%a2,%d4.l*4),%a0
	tst.l %a0
	jne .L798
.L797:
	clr.b %d2
.L799:
	move.b 53(%a2),%d1
	mvz.b %d2,%d3
	mvz.b %d1,%d0
	cmp.l %d0,%d3
	jeq .L800
	move.b %d2,53(%a2)
	tst.b %d1
	jeq .L801
	move.l %d0,%a0
	pea -1(%a0)
	jsr us_names
	addq.l #4,%sp
.L801:
	tst.b %d2
	jeq .L800
	move.l %d3,%a0
	pea -1(%a0)
	jsr us_names
	addq.l #4,%sp
.L800:
	tst.l 24(%a2)
	jeq .L795
	clr.l %d4
	move.b 52(%a2),%d0
	clr.l %d2
	move.b %d0,31(%sp)
.L807:
	move.l 24(%a2),%a0
	add.l %d4,%a0
	move.b 3(%a0),%d0
	jeq .L803
	move.l 1100784300,%d1
	sub.l 24(%a0),%d1
	cmp.l #89999,%d1
	jhi .L804
	mvz.b %d0,%d0
	move.l %d2,%a3
	add.l #-2147423744,%a3
	mvz.b (%a3),%d1
	move.l %d0,%d5
	add.l #34,%d5
	cmp.l %d1,%d5
	jeq .L805
.L804:
	clr.b %d1
	move.b %d1,3(%a0)
.L803:
	addq.l #1,%d2
	add.l #28,%d4
	moveq #12,%d6
	cmp.l %d2,%d6
	jne .L807
.L795:
	movem.l (%sp),#3196
	lea (32,%sp),%sp
	rts
.L798:
	move.w 34(%a0),%d1
	jeq .L797
	moveq #127,%d0
	and.l -2147457096,%d0
	mulu.w #152,%d3
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l #1092966689,%a0
	add.l %d3,%a0
	move.b 90(%a0),%d3
	mvz.b 91(%a0),%d0
	lsl.l #8,%d3
	or.l %d3,%d0
	and.l #16383,%d0
	tst.l %d0
	jeq .L797
	mvz.w %d1,%d1
	cmp.l %d1,%d0
	jeq .L797
	add.l #-34,%d2
	jra .L799
.L805:
	subq.l #1,%d0
	move.l (%a2,%d0.l*4),%a1
	tst.l %a1
	jeq .L803
	move.b (%a1),%d1
	jeq .L803
	tst.b 34(%a2)
	jeq .L806
	mvz.b 28(%a2,%d0.l),%d6
	mvz.b %d1,%d3
	cmp.l %d3,%d6
	jne .L803
.L806:
	mvz.b 1(%a1),%d3
	subq.l #2,%d3
	tst.l %d3
	jeq .L803
	mvz.b %d1,%d1
	mvz.b 22(%a0),%d3
	cmp.l %d1,%d3
	jeq .L803
	clr.b %d1
	move.b %d1,3(%a0)
	mvz.b 1(%a1),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L803
	mvz.b 52(%a2),%d1
	mvz.b 31(%sp),%d3
	cmp.l %d1,%d3
	jne .L803
	mvz.b (%a3),%d3
	cmp.l %d5,%d3
	jne .L803
	move.l %d1,-(%sp)
	move.l %d0,-(%sp)
	move.l %d2,-(%sp)
	jsr us_defaults
	lea (12,%sp),%sp
	jra .L803
	.size	us_tick3, .-us_tick3
	.section	.us2
	.align	2
	.globl	us_tick
	.type	us_tick, @function
us_tick:
	lea (-40,%sp),%sp
	movem.l #31804,(%sp)
	tst.b us+50.l
	jne .L835
	jsr us_init
.L835:
	move.l us+20,%a0
	tst.l %a0
	jeq .L836
	mvz.b 3(%a0),%d0
	cmp.l #255,%d0
	jne .L836
	jsr us_commit
.L836:
	tst.l us+24
	jeq .L837
	jsr us_writeback
.L837:
	jsr us_tick3
	lea us,%a5
	lea us+35,%a6
	move.l %a5,%d4
	move.l %a6,%a0
	clr.l %d1
.L839:
	move.b (%a0)+,%d0
	jeq .L838
	subq.l #1,%d0
	move.b %d0,-1(%a0)
.L838:
	addq.l #1,%d1
	mov3q.l #5,%d0
	cmp.l %d1,%d0
	jne .L839
	move.b us+40,%d0
	jeq .L840
	subq.l #1,%d0
	move.b %d0,us+40
.L834:
	movem.l (%sp),#31804
	lea (40,%sp),%sp
	rts
.L840:
	move.b us+34,%d1
	sub.l %a2,%a2
	move.b %d1,39(%sp)
.L850:
	move.l (%a5),%a3
	tst.l %a3
	jeq .L851
	mvz.b (%a3),%d3
.L842:
	tst.b (%a6)+
	jne .L843
	tst.b 39(%sp)
	jne .L844
.L846:
	clr.l -(%sp)
	clr.l -(%sp)
	move.l %d3,-(%sp)
	pea 1(%a2)
	jsr us_ask
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L834
	moveq #-56,%d0
.L871:
	moveq #10,%d1
	move.b %d0,35(%a2,%d4.l)
	move.b %d1,us+40
	jra .L834
.L851:
	clr.l %d3
	jra .L842
.L844:
	mvz.b -8(%a6),%d0
	cmp.l %d0,%d3
	jne .L846
	tst.l %a3
	jeq .L843
	mvz.b 1(%a3),%d0
	subq.l #1,%d0
	tst.l %d0
	jne .L843
	lea (36,%a3),%a4
	clr.l %d2
.L849:
	tst.b (%a4)
	jeq .L848
	mvz.b 2(%a4),%d0
	subq.l #2,%d0
	tst.l %d0
	jne .L848
	tst.b 7(%a4)
	jeq .L848
	move.l %d2,-(%sp)
	move.l %a3,-(%sp)
	jsr us_has_enum
	addq.l #8,%sp
	tst.l %d0
	jne .L848
	pea 255.w
	move.l %a3,-(%sp)
	jsr us_has_enum
	addq.l #8,%sp
	tst.l %d0
	jeq .L848
	move.l %d2,-(%sp)
	mov3q.l #1,-(%sp)
	move.l %d3,-(%sp)
	pea 1(%a2)
	jsr us_ask
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L834
	moveq #50,%d0
	jra .L871
.L848:
	addq.l #1,%d2
	lea (28,%a4),%a4
	moveq #16,%d0
	cmp.l %d2,%d0
	jne .L849
.L843:
	addq.l #4,%a5
	addq.l #1,%a2
	mov3q.l #5,%d1
	cmp.l %a2,%d1
	jne .L850
	jra .L834
	.size	us_tick, .-us_tick
	.section	.exto
	.align	2
	.globl	ext_ui_tick
	.type	ext_ui_tick, @function
ext_ui_tick:
	lea (-20,%sp),%sp
	movem.l #17412,(%sp)
	tst.b ext_desc_done.l
	jne .L873
	jsr ext_descriptors
	jsr fm_descriptors
.L873:
	jsr us_tick
	lea jn_mailbox,%a0
	move.b 11(%a0),%d0
	btst #0,%d0
	jne .L872
	mvz.b 1307(%a0),%d2
	mvz.b %d0,%d1
	cmp.l %d2,%d1
	jeq .L872
	move.l 12(%a0),12(%sp)
	move.l 16(%a0),16(%sp)
	mvz.b 11(%a0),%d2
	cmp.l %d2,%d1
	jne .L872
	mvz.b 12(%sp),%d2
	move.b %d0,1307(%a0)
	moveq #11,%d0
	cmp.l %d2,%d0
	jcs .L872
	move.l #-2147423744,%a0
	moveq #41,%d1
	mvz.b (%a0,%d2.l),%d0
	cmp.l %d0,%d1
	jne .L872
	mov3q.l #1,%a6
	lea us_set,%a2
.L875:
	mvz.b 12(%a6,%sp.l),%d0
	lsl.l #8,%d0
	move.l %d0,-(%sp)
	pea 382(%a6)
	pea 9(%a6)
	move.l %d2,-(%sp)
	jsr (%a2)
	addq.l #1,%a6
	lea (16,%sp),%sp
	mov3q.l #7,%d0
	cmp.l %a6,%d0
	jne .L875
.L872:
	movem.l (%sp),#17412
	lea (20,%sp),%sp
	rts
	.size	ext_ui_tick, .-ext_ui_tick
	.section	.us4
	.align	2
	.globl	us_label_text
	.type	us_label_text, @function
us_label_text:
	move.l 4(%sp),%a0
	lea us,%a1
	move.l (%a1,%a0.l*4),%a1
	tst.l %a1
	jne .L878
.L880:
	move.l #us_unknown,%d0
.L879:
	move.l %d0,-(%sp)
	pea 1(%a0)
	pea us_fmt_item
	pea us_lbuf
	jsr 1074365954
	lea (16,%sp),%sp
	move.l #us_lbuf,%d0
	rts
.L878:
	tst.b (%a1)
	jeq .L880
	tst.b 1(%a1)
	jeq .L881
	lea us_lnames,%a1
	move.l (%a1,%a0.l*4),%d0
	jra .L879
.L881:
	move.l #us_none,%d0
	jra .L879
	.size	us_label_text, .-us_label_text
	.section	.us5
	.align	2
	.globl	us_assign_send
	.type	us_assign_send, @function
us_assign_send:
	moveq #16,%d1
	link.w %fp,#-24
	move.l #-260222380,%d0
	mov3q.l #5,%a0
	move.l %d0,-21(%fp)
	move.l #1081903566,%a1
	move.b %d1,-17(%fp)
.L883:
	move.b (%a0,%a1.l),%d0
	jeq .L884
	moveq #127,%d1
	addq.l #1,%a0
	and.l %d1,%d0
	move.b %d0,-22(%a0,%fp.l)
	moveq #20,%d0
	cmp.l %a0,%d0
	jne .L883
.L884:
	moveq #-9,%d1
	move.b %d1,-21(%fp,%a0.l)
	pea -21(%fp)
	pea 1(%a0)
	jsr 1073752544
	move.l 8(%fp),-(%sp)
	move.l 12(%fp),-(%sp)
	jsr 1073752544
	jsr 1073752356
	lea (16,%sp),%sp
	unlk %fp
	rts
	.size	us_assign_send, .-us_assign_send
	.section	.us3
	.align	2
	.globl	us_menu_action
	.type	us_menu_action, @function
us_menu_action:
	link.w %fp,#-52
	movem.l #7420,(%sp)
	move.l 12(%fp),%d2
	lea us,%a2
	move.l (%a2,%d2.l*4),%a3
	move.b us+54,%d3
	tst.l %a3
	jeq .L890
	tst.b (%a3)
	jne .L891
.L890:
	clr.l %d6
.L892:
	clr.b %d0
	lea us_wait,%a4
	move.b %d0,54(%a2)
	clr.l -(%sp)
	mov3q.l #-1,-(%sp)
	jsr (%a4)
	addq.l #8,%sp
	move.l %d0,%d4
	tst.l %d0
	jeq .L893
	tst.l %d6
	jeq .L894
	mvz.b 1(%a3),%d0
	subq.l #3,%d0
	tst.l %d0
	jne .L895
	move.b 2(%a3),%d0
	btst #1,%d0
	jeq .L895
	mvz.b %d3,%d3
	move.l %d2,%d0
	addq.l #1,%d0
	cmp.l %d3,%d0
	jne .L909
.L895:
	move.l %a3,%d6
	move.l #jn_mailbox+37,%d3
	mvz.b jn_mailbox+9,%d7
	clr.l -16(%fp)
	addq.l #4,%d6
	jra .L897
.L891:
	tst.b 1(%a3)
	sne %d6
	mvs.b %d6,%d6
	neg.l %d6
	jra .L892
.L898:
	add.l #10,%d3
	addq.l #1,-16(%fp)
.L897:
	cmp.l -16(%fp),%d7
	jle .L910
	move.l %d6,-(%sp)
	move.l %d3,-(%sp)
	jsr us_same
	addq.l #8,%sp
	tst.l %d0
	jeq .L898
	move.l -16(%fp),%d6
	addq.l #1,%d6
.L894:
	mvz.b jn_mailbox+9,%d0
	cmp.l %d0,%d6
	jge .L911
	clr.l %d3
.L896:
	clr.b %d0
	move.w #7681,%a0
	move.l #-260222380,%d1
	move.l %d2,%d5
	addq.l #1,%d5
	move.b %d5,-5(%fp)
	move.b %d3,-4(%fp)
	move.b %d6,-3(%fp)
	move.l %d1,-11(%fp)
	move.b %d0,46(%a2)
	moveq #-9,%d0
	move.w %a0,-7(%fp)
	lea jn_mailbox+20,%a0
	move.b (%a0),-2(%fp)
	move.b %d0,-1(%fp)
	cmp.l #170,%d4
	jle .L899
.L893:
	lea us_t_none,%a0
	move.l %a0,-16(%fp)
.L900:
	move.l -16(%fp),-(%sp)
	move.l 8(%fp),-(%sp)
	jsr us_popup
	addq.l #8,%sp
	movem.l -52(%fp),#7420
	unlk %fp
	rts
.L910:
	clr.l %d6
	jra .L894
.L909:
	mov3q.l #2,%d3
.L950:
	clr.l %d6
	jra .L896
.L911:
	mov3q.l #1,%d3
	jra .L950
.L899:
	mvz.b jn_mailbox+19,%d0
	moveq #32,%d1
	cmp.l %d0,%d1
	jne .L893
	mvz.b jn_mailbox+20,%d1
	mvz.b 33(%a2),%d0
	cmp.l %d1,%d0
	jne .L893
	jsr ext_ui_lock
	tst.l %d0
	jeq .L893
	pea 11.w
	pea -11(%fp)
	jsr us_assign_send
	addq.l #8,%sp
	mov3q.l #2,%d0
	cmp.l %d3,%d0
	jne .L901
	move.b %d5,54(%a2)
.L901:
	move.l %d4,-(%sp)
	move.l %d2,-(%sp)
	jsr (%a4)
	addq.l #8,%sp
	tst.l %d0
	jeq .L893
	move.b 47(%a2),%d0
	mov3q.l #6,%d4
	mvz.b %d0,%d1
	cmp.l %d1,%d4
	jlt .L912
	ext.w %d0
	mvz.w %d0,%d0
	lsl.l #4,%d0
	add.l #us_t_res,%d0
	move.l %d0,-16(%fp)
	tst.l %d1
	jeq .L903
	cmp.l %d1,%d4
	jne .L902
.L903:
	clr.b %d0
	move.b %d0,54(%a2)
.L902:
	clr.b %d0
	move.b %d0,35(%a2,%d2.l)
	tst.l %d3
	jne .L905
	tst.l %d1
	jeq .L906
	subq.l #6,%d1
	tst.l %d1
	jne .L905
.L906:
	move.l %d2,%d6
	clr.l %d4
	add.l #35,%d6
	move.l #-2147423744,%d5
	lea us_pend,%a4
.L908:
	move.l %d3,%a0
	mvz.b (%a0,%d5.l),%d0
	cmp.l %d0,%d6
	jne .L907
	move.l %d3,-(%sp)
	jsr (%a4)
	addq.l #4,%sp
	move.l 24(%a2),%a0
	tst.l %a0
	jeq .L907
	tst.l %a3
	jeq .L907
	move.b (%a3),22(%a0,%d4.l)
.L907:
	addq.l #1,%d3
	add.l #28,%d4
	moveq #12,%d0
	cmp.l %d3,%d0
	jne .L908
.L905:
	move.l %d2,-(%sp)
	jsr us_fetch
	addq.l #4,%sp
	jra .L900
.L912:
	lea us_t_res+80,%a0
	move.l %a0,-16(%fp)
	jra .L902
	.size	us_menu_action, .-us_menu_action
	.section	.us4
	.align	2
	.globl	us_menu_add
	.type	us_menu_add, @function
us_menu_add:
	lea (-92,%sp),%sp
	movem.l #19516,(%sp)
	move.l %sp,%d3
	move.l %sp,%d4
	move.l %sp,%d5
	sub.l %a6,%a6
	lea (28,%sp),%a2
	add.l #76,%d3
	add.l #60,%d4
	add.l #44,%d5
.L952:
	move.l %a2,%a0
	clr.l %d0
.L953:
	clr.l 12(%a0)
	clr.l 8(%a0)
	clr.l (%a0)
	clr.l 4(%a0)
	addq.l #1,%d0
	lea (16,%a0),%a0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L953
	mov3q.l #1,-(%sp)
	move.l #1074276820,%a3
	jsr (%a3)
	move.l #1074764344,%a0
	move.l %d0,32(%sp)
	move.l %a6,%d0
	add.l #us_label_1,%d0
	move.l %a0,40(%sp)
	move.l %d0,44(%sp)
	mov3q.l #4,-(%sp)
	jsr (%a3)
	move.l %a6,%d1
	add.l #us_action_1,%d1
	move.l %d0,%a0
	move.l 104(%sp),(%a0)
	move.l %d0,52(%sp)
	move.l #1074764426,%d0
	move.l %d1,64(%sp)
	move.l %d0,60(%sp)
	mov3q.l #1,-(%sp)
	jsr (%a3)
	move.l #1074764518,%a0
	move.l %d0,72(%sp)
	move.l #us_icon,%d0
	move.l %a0,80(%sp)
	move.l %d0,84(%sp)
	pea 84.w
	jsr (%a3)
	pea 8.w
	mov3q.l #-1,-(%sp)
	move.l %d3,-(%sp)
	move.l %d4,-(%sp)
	move.l %d5,-(%sp)
	move.l %a2,-(%sp)
	move.l %d0,%d2
	move.l %d0,-(%sp)
	jsr 1074212688
	lea (40,%sp),%sp
	move.l %d2,(%sp)
	mov3q.l #3,%d2
	move.l 100(%sp),-(%sp)
	jsr 1074210694
	addq.l #8,%sp
.L954:
	mvz.w %d2,%d0
	subq.l #1,%d2
	lsl.l #4,%d0
	pea (%a2,%d0.l)
	jsr 1075251654
	addq.l #4,%sp
	mov3q.l #-1,%d1
	cmp.l %d2,%d1
	jne .L954
	addq.l #4,%a6
	moveq #20,%d0
	cmp.l %a6,%d0
	jne .L952
	movem.l (%sp),#19516
	lea (92,%sp),%sp
	rts
	.size	us_menu_add, .-us_menu_add
	.globl	ext_stepbox
	.section	.usm,"a"
	.align	4
	.type	ext_stepbox, @object
	.size	ext_stepbox, 12
ext_stepbox:
	.long	1481856080
	.long	ext_steps
	.long	us_live
	.globl	sp
	.section	.usr,"aw"
	.align	4
	.type	sp, @object
	.size	sp, 12
sp:
	.zero	12
	.section	.usd,"a"
	.align	2
	.type	ext_step_tab, @object
	.size	ext_step_tab, 28
ext_step_tab:
	.word	408
	.word	273
	.word	390
	.word	267
	.word	449
	.word	259
	.word	416
	.word	259
	.word	453
	.word	267
	.word	433
	.word	258
	.word	444
	.word	263
	.globl	us_lbuf
	.section	.usr
	.type	us_lbuf, @object
	.size	us_lbuf, 20
us_lbuf:
	.zero	20
	.section	.usd
	.type	us_unknown, @object
	.size	us_unknown, 2
us_unknown:
	.string	"?"
	.type	us_fmt_item, @object
	.size	us_fmt_item, 7
us_fmt_item:
	.string	"U%d %s"
	.type	us_t_none, @object
	.size	us_t_none, 11
us_t_none:
	.string	"NO SIDECAR"
	.type	us_t_res, @object
	.size	us_t_res, 112
us_t_res:
	.string	"READY"
	.zero	10
	.string	"NOT INSTALLED"
	.zero	2
	.string	"NO ROOM"
	.zero	8
	.string	"STOP TO INSTALL"
	.string	"NOT ON CARD"
	.zero	4
	.string	"BAD"
	.zero	12
	.string	"LOADING"
	.zero	8
	.globl	us_tag
	.section	.usr
	.align	2
	.type	us_tag, @object
	.size	us_tag, 26
us_tag:
	.zero	26
	.globl	us_cubox
	.section	.ush,"aw"
	.align	4
	.type	us_cubox, @object
	.size	us_cubox, 12
us_cubox:
	.long	1128813124
	.long	0
	.long	0
	.section	.usd
	.type	us_flag_tab, @object
	.size	us_flag_tab, 18
us_flag_tab:
	.string	"PX`hpH\b@"
	.base64	"ACAoOHgYABAw"
	.type	us_none, @object
	.size	us_none, 4
us_none:
	.string	"---"
	.type	us_off, @object
	.size	us_off, 4
us_off:
	.string	"OFF"
	.type	us_fmt_uempty, @object
	.size	us_fmt_uempty, 6
us_fmt_uempty:
	.string	"U%d--"
	.type	us_fmt_empty, @object
	.size	us_fmt_empty, 12
us_fmt_empty:
	.string	"USER %d ---"
	.type	us_fmt_u, @object
	.size	us_fmt_u, 4
us_fmt_u:
	.string	"U%d"
	.type	us_fmt_user, @object
	.size	us_fmt_user, 8
us_fmt_user:
	.string	"USER %d"
	.type	us_fmt_note, @object
	.size	us_fmt_note, 5
us_fmt_note:
	.string	"%s%d"
	.type	us_fmt_pd, @object
	.size	us_fmt_pd, 4
us_fmt_pd:
	.string	"+%d"
	.type	us_fmt_d, @object
	.size	us_fmt_d, 3
us_fmt_d:
	.string	"%d"
	.type	us_notes, @object
	.size	us_notes, 36
us_notes:
	.string	"C"
	.zero	1
	.string	"C#"
	.string	"D"
	.zero	1
	.string	"D#"
	.string	"E"
	.zero	1
	.string	"F"
	.zero	1
	.string	"F#"
	.string	"G"
	.zero	1
	.string	"G#"
	.string	"A"
	.zero	1
	.string	"A#"
	.string	"B"
	.zero	1
	.type	us_pn, @object
	.size	us_pn, 64
us_pn:
	.string	"P1"
	.zero	1
	.string	"P2"
	.zero	1
	.string	"P3"
	.zero	1
	.string	"P4"
	.zero	1
	.string	"P5"
	.zero	1
	.string	"P6"
	.zero	1
	.string	"P7"
	.zero	1
	.string	"P8"
	.zero	1
	.string	"P9"
	.zero	1
	.string	"P10"
	.string	"P11"
	.string	"P12"
	.string	"P13"
	.string	"P14"
	.string	"P15"
	.string	"P16"
	.align	2
	.type	us_look_rec, @object
	.size	us_look_rec, 8
us_look_rec:
	.word	410
	.word	40
	.word	101
	.word	410
	.align	2
	.type	us_p2rec, @object
	.size	us_p2rec, 16
us_p2rec:
	.word	438
	.word	457
	.word	458
	.word	459
	.word	460
	.word	403
	.word	404
	.word	405
	.align	4
	.type	us_snames, @object
	.size	us_snames, 20
us_snames:
	.long	us_s1
	.long	us_s2
	.long	us_s3
	.long	us_s4
	.long	us_s5
	.align	4
	.type	us_lnames, @object
	.size	us_lnames, 20
us_lnames:
	.long	us_l1
	.long	us_l2
	.long	us_l3
	.long	us_l4
	.long	us_l5
	.globl	us_s5
	.section	.usr
	.type	us_s5, @object
	.size	us_s5, 5
us_s5:
	.string	"U5"
	.zero	2
	.globl	us_s4
	.type	us_s4, @object
	.size	us_s4, 5
us_s4:
	.string	"U4"
	.zero	2
	.globl	us_s3
	.type	us_s3, @object
	.size	us_s3, 5
us_s3:
	.string	"U3"
	.zero	2
	.globl	us_s2
	.type	us_s2, @object
	.size	us_s2, 5
us_s2:
	.string	"U2"
	.zero	2
	.globl	us_s1
	.type	us_s1, @object
	.size	us_s1, 5
us_s1:
	.string	"U1"
	.zero	2
	.globl	us_l5
	.type	us_l5, @object
	.size	us_l5, 12
us_l5:
	.string	"USER 5"
	.zero	5
	.globl	us_l4
	.type	us_l4, @object
	.size	us_l4, 12
us_l4:
	.string	"USER 4"
	.zero	5
	.globl	us_l3
	.type	us_l3, @object
	.size	us_l3, 12
us_l3:
	.string	"USER 3"
	.zero	5
	.globl	us_l2
	.type	us_l2, @object
	.size	us_l2, 12
us_l2:
	.string	"USER 2"
	.zero	5
	.globl	us_l1
	.type	us_l1, @object
	.size	us_l1, 12
us_l1:
	.string	"USER 1"
	.zero	5
	.globl	us
	.align	4
	.type	us, @object
	.size	us, 56
us:
	.zero	56
	.section	.extg,"a"
	.type	mod_short, @object
	.size	mod_short, 4
mod_short:
	.string	"MOD"
	.type	mod_long, @object
	.size	mod_long, 5
mod_long:
	.string	"Mode"
	.type	mod_label, @object
	.size	mod_label, 21
mod_label:
	.base64	"AAEC"
	.base64	"AAEC"
	.base64	"AAED"
	.base64	"BAUG"
	.base64	"AAEH"
	.base64	"AAgJ"
	.base64	"BAsK"
	.section	.ext8,"a"
	.type	mod_pool, @object
	.size	mod_pool, 44
mod_pool:
	.string	"STA"
	.string	"END"
	.string	"LOP"
	.string	"SLC"
	.string	"POS"
	.string	"SIZ"
	.string	"DNS"
	.string	"SPD"
	.string	"DEC"
	.string	"BRI"
	.string	"CYC"
	.section	.ext3,"a"
	.type	mod_names, @object
	.size	mod_names, 42
mod_names:
	.string	"ONE"
	.zero	2
	.string	"LOOP"
	.zero	1
	.string	"SLICE"
	.string	"GRAIN"
	.string	"STRCH"
	.string	"PLUCK"
	.string	"WAVE"
	.zero	1
	.type	diag_fmt, @object
	.size	diag_fmt, 5
diag_fmt:
	.string	"%c%d"
	.type	diag_key, @object
	.size	diag_key, 8
diag_key:
	.ascii	"TUPKMRSC"
	.globl	ext_diag_max
	.section	.exts,"aw"
	.align	2
	.type	ext_diag_max, @object
	.size	ext_diag_max, 4
ext_diag_max:
	.zero	4
	.section	.extk,"a"
	.type	jn_empty, @object
	.size	jn_empty, 4
jn_empty:
	.string	"---"
	.globl	jn_mailbox
	.section	.extn,"aw"
	.align	2
	.type	jn_mailbox, @object
	.size	jn_mailbox, 1308
jn_mailbox:
	.long	1247104591
	.long	us_sysex
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.zero	2
	.zero	4
	.byte	0
	.byte	0
	.zero	2
	.zero	14
	.zero	2
	.zero	8
	.zero	1260
	.byte	0
	.section	.extr,"a"
	.align	2
	.type	fm_look, @object
	.size	fm_look, 16
fm_look:
	.word	410
	.word	40
	.word	40
	.word	410
	.word	410
	.word	100
	.word	101
	.word	410
	.type	fm_fmt_d, @object
	.size	fm_fmt_d, 3
fm_fmt_d:
	.string	"%d"
	.globl	fm_sname
	.type	fm_sname, @object
	.size	fm_sname, 4
fm_sname:
	.string	"6OP"
	.globl	fm_name
	.type	fm_name, @object
	.size	fm_name, 8
fm_name:
	.string	"6-OP FM"
	.type	fm_short, @object
	.size	fm_short, 32
fm_short:
	.string	"PAT"
	.string	"TIM"
	.string	"MOR"
	.string	"DEC"
	.string	"LPG"
	.string	"TUN"
	.string	"LEV"
	.string	"LEN"
	.type	fm_long, @object
	.size	fm_long, 72
fm_long:
	.string	"Voice"
	.zero	3
	.string	"Timbre"
	.zero	2
	.string	"Morph"
	.zero	3
	.string	"Decay"
	.zero	3
	.string	"LPG Col"
	.zero	1
	.string	"Tune"
	.zero	4
	.string	"Level"
	.zero	3
	.string	"Gate"
	.zero	4
	.section	.ext8
	.type	dsp_x_word, @object
	.size	dsp_x_word, 5
dsp_x_word:
	.base64	"DQgJDA4="
	.globl	dsps_s_fld
	.type	dsps_s_fld, @object
	.size	dsps_s_fld, 4
dsps_s_fld:
	.string	"DGN"
	.globl	dsps_n_fld
	.type	dsps_n_fld, @object
	.size	dsps_n_fld, 14
dsps_n_fld:
	.string	"Diag TUPKMRSC"
	.globl	dsps_n_smp
	.type	dsps_n_smp, @object
	.size	dsps_n_smp, 12
dsps_n_smp:
	.string	"Card Sample"
	.globl	dsps_s5
	.type	dsps_s5, @object
	.size	dsps_s5, 4
dsps_s5:
	.string	"MIX"
	.globl	dsps_n5
	.type	dsps_n5, @object
	.size	dsps_n5, 4
dsps_n5:
	.string	"Mix"
	.globl	dsps_p2_title
	.type	dsps_p2_title, @object
	.size	dsps_p2_title, 10
dsps_p2_title:
	.string	"SD SAMPLE"
	.globl	dsps_p2_order
	.align	2
	.type	dsps_p2_order, @object
	.size	dsps_p2_order, 32
dsps_p2_order:
	.long	39
	.long	442
	.long	444
	.long	441
	.long	445
	.long	446
	.long	447
	.long	448
	.align	2
	.type	dsps_rec, @object
	.size	dsps_rec, 16
dsps_rec:
	.word	416
	.word	417
	.word	418
	.word	419
	.word	439
	.word	440
	.word	420
	.word	421
	.globl	dsps_short
	.type	dsps_short, @object
	.size	dsps_short, 5
dsps_short:
	.string	"DSPS"
	.globl	dsps_long
	.type	dsps_long, @object
	.size	dsps_long, 11
dsps_long:
	.string	"DSP SAMPLE"
	.type	dsp_out_names, @object
	.size	dsp_out_names, 12
dsp_out_names:
	.string	"VOICE"
	.string	"MAIN"
	.zero	1
	.globl	dsp_p2_order
	.align	2
	.type	dsp_p2_order, @object
	.size	dsp_p2_order, 32
dsp_p2_order:
	.long	433
	.long	432
	.long	435
	.long	430
	.long	431
	.long	434
	.long	436
	.long	437
	.globl	dsp_s16
	.type	dsp_s16, @object
	.size	dsp_s16, 4
dsp_s16:
	.string	"WID"
	.globl	dsp_s15
	.type	dsp_s15, @object
	.size	dsp_s15, 4
dsp_s15:
	.string	"XP5"
	.globl	dsp_s14
	.type	dsp_s14, @object
	.size	dsp_s14, 4
dsp_s14:
	.string	"XLV"
	.globl	dsp_s13
	.type	dsp_s13, @object
	.size	dsp_s13, 4
dsp_s13:
	.string	"XP4"
	.globl	dsp_s12
	.type	dsp_s12, @object
	.size	dsp_s12, 4
dsp_s12:
	.string	"OUT"
	.globl	dsp_s11
	.type	dsp_s11, @object
	.size	dsp_s11, 5
dsp_s11:
	.string	"SEED"
	.globl	dsp_s10
	.type	dsp_s10, @object
	.size	dsp_s10, 4
dsp_s10:
	.string	"XDC"
	.globl	dsp_s9
	.type	dsp_s9, @object
	.size	dsp_s9, 4
dsp_s9:
	.string	"XTN"
	.globl	dsp_n16
	.type	dsp_n16, @object
	.size	dsp_n16, 6
dsp_n16:
	.string	"Width"
	.globl	dsp_n15
	.type	dsp_n15, @object
	.size	dsp_n15, 12
dsp_n15:
	.string	"Exc Param 5"
	.globl	dsp_n14
	.type	dsp_n14, @object
	.size	dsp_n14, 10
dsp_n14:
	.string	"Exc Level"
	.globl	dsp_n13
	.type	dsp_n13, @object
	.size	dsp_n13, 12
dsp_n13:
	.string	"Exc Param 4"
	.globl	dsp_n12
	.type	dsp_n12, @object
	.size	dsp_n12, 7
dsp_n12:
	.string	"Output"
	.globl	dsp_n11
	.type	dsp_n11, @object
	.size	dsp_n11, 5
dsp_n11:
	.string	"Seed"
	.globl	dsp_n10
	.type	dsp_n10, @object
	.size	dsp_n10, 10
dsp_n10:
	.string	"Exc Decay"
	.globl	dsp_n9
	.type	dsp_n9, @object
	.size	dsp_n9, 9
dsp_n9:
	.string	"Exc Tune"
	.globl	dsp_p2_title
	.type	dsp_p2_title, @object
	.size	dsp_p2_title, 8
dsp_p2_title:
	.string	"EXCITER"
	.globl	ext_proj
	.section	.exts
	.align	2
	.type	ext_proj, @object
	.size	ext_proj, 20
ext_proj:
	.zero	20
	.section	.extk
	.type	jn_fmt, @object
	.size	jn_fmt, 7
jn_fmt:
	.string	"%c%d%d"
	.globl	jn_name
	.type	jn_name, @object
	.size	jn_name, 5
jn_name:
	.string	"JUNO"
	.type	jn_short, @object
	.size	jn_short, 32
jn_short:
	.string	"PAT"
	.string	"CUT"
	.string	"RES"
	.string	"ENV"
	.string	"ATK"
	.string	"DEC"
	.string	"REL"
	.string	"LEN"
	.section	.extm,"a"
	.type	jn_long, @object
	.size	jn_long, 88
jn_long:
	.string	"Patch"
	.zero	5
	.string	"Cutoff"
	.zero	4
	.string	"Resonance"
	.zero	1
	.string	"Env Amount"
	.string	"Attack"
	.zero	4
	.string	"Decay"
	.zero	5
	.string	"Release"
	.zero	3
	.string	"Gate"
	.zero	6
	.section	.exte,"a"
	.type	dd_eng, @object
	.size	dd_eng, 4
dd_eng:
	.string	"ENG"
	.globl	dd_short
	.type	dd_short, @object
	.size	dd_short, 5
dd_short:
	.string	"DDRM"
	.globl	dd_long
	.type	dd_long, @object
	.size	dd_long, 9
dd_long:
	.string	"DIGIDRUM"
	.type	dd_label, @object
	.size	dd_label, 77
dd_label:
	.base64	"AAECGhscHQ=="
	.base64	"AAEFHhscHQ=="
	.base64	"AAECGhscHQ=="
	.base64	"AAEfIBscHQ=="
	.base64	"AAEbDSEiIw=="
	.base64	"AAEJJBscHQ=="
	.base64	"AAElJhscHQ=="
	.base64	"AAEkDRscHQ=="
	.base64	"AAEWEBAQEA=="
	.base64	"AAEXCgcQEA=="
	.base64	"AAEYFwsZEA=="
	.type	dd_pool, @object
	.size	dd_pool, 195
dd_pool:
	.string	"PTCH"
	.string	"DEC"
	.zero	1
	.string	"RAMP"
	.string	"HOLD"
	.string	"TICK"
	.string	"NOIS"
	.string	"DIRT"
	.string	"BUMP"
	.string	"BENV"
	.string	"SNAP"
	.string	"TONE"
	.string	"TUNE"
	.string	"GAP"
	.zero	1
	.string	"HPF"
	.zero	1
	.string	"LPF"
	.zero	1
	.string	"MTAL"
	.string	"-"
	.zero	3
	.string	"RICH"
	.string	"TOP"
	.zero	1
	.string	"TTUN"
	.string	"SIZE"
	.string	"PEAK"
	.string	"DIST"
	.string	"ENH"
	.zero	1
	.string	"DUAL"
	.string	"CLIC"
	.string	"RDEC"
	.string	"MOD"
	.zero	1
	.string	"MFRQ"
	.string	"MDEC"
	.string	"NDEC"
	.string	"CLPS"
	.string	"CDEC"
	.string	"SNAR"
	.string	"SPTC"
	.string	"SDEC"
	.string	"FB"
	.zero	2
	.string	"TREM"
	.string	"TFRQ"
	.section	.extg
	.type	dd_names, @object
	.size	dd_names, 77
dd_names:
	.string	"EFM-BD"
	.string	"EFM-SD"
	.string	"EFM-XT"
	.string	"EFM-CP"
	.string	"EFM-RS"
	.string	"EFM-CB"
	.string	"EFM-HH"
	.string	"EFM-CY"
	.string	"TRX-RS"
	.string	"TRX-CB"
	.string	"TRX-CL"
	.globl	ext_p2_title
	.section	.ext3
	.type	ext_p2_title, @object
	.size	ext_p2_title, 14
ext_p2_title:
	.string	"PLAITS PAGE 2"
	.align	2
	.type	ext_p2_order, @object
	.size	ext_p2_order, 32
ext_p2_order:
	.long	425
	.long	426
	.long	422
	.long	424
	.long	423
	.long	427
	.long	428
	.long	429
	.section	.ext6,"a"
	.type	dsp_input_names, @object
	.size	dsp_input_names, 66
dsp_input_names:
	.string	"INT"
	.zero	2
	.string	"NAT"
	.zero	2
	.string	"NOISE"
	.string	"BD"
	.zero	3
	.string	"SD"
	.zero	3
	.string	"RS/CP"
	.string	"BT"
	.zero	3
	.string	"LT"
	.zero	3
	.string	"MT/HT"
	.string	"CH/OH"
	.string	"CY/CB"
	.type	dsp_engine_names, @object
	.size	dsp_engine_names, 24
dsp_engine_names:
	.string	"MODAL"
	.zero	2
	.string	"STRING"
	.zero	1
	.string	"RESON"
	.zero	2
	.globl	ext_desc_done
	.section	.exts
	.type	ext_desc_done, @object
	.size	ext_desc_done, 1
ext_desc_done:
	.zero	1
	.section	.ext3
	.type	ext_fmt_s, @object
	.size	ext_fmt_s, 3
ext_fmt_s:
	.string	"%s"
	.type	ext_engine_names, @object
	.size	ext_engine_names, 136
ext_engine_names:
	.string	"VA VCF"
	.zero	1
	.string	"PHASDST"
	.string	"WAVTERR"
	.string	"STRMACH"
	.string	"CHIPTUN"
	.string	"VA"
	.zero	5
	.string	"WAVSHAP"
	.string	"2OP FM"
	.zero	1
	.string	"GRANULR"
	.string	"HARMONC"
	.string	"WAVETBL"
	.string	"CHORDS"
	.zero	1
	.string	"SPEECH"
	.zero	1
	.string	"SWARM"
	.zero	2
	.string	"PARTICL"
	.string	"STRING"
	.zero	1
	.string	"MODAL"
	.zero	2
	.globl	ext_state
	.section	.exts
	.align	2
	.type	ext_state, @object
	.size	ext_state, 560
ext_state:
	.zero	560
	.globl	ext_s16
	.section	.ext3
	.type	ext_s16, @object
	.size	ext_s16, 4
ext_s16:
	.string	"VOL"
	.globl	ext_s15
	.type	ext_s15, @object
	.size	ext_s15, 4
ext_s15:
	.string	"GLD"
	.globl	ext_s14
	.type	ext_s14, @object
	.size	ext_s14, 4
ext_s14:
	.string	"VEL"
	.globl	ext_s13
	.type	ext_s13, @object
	.size	ext_s13, 4
ext_s13:
	.string	"MMD"
	.globl	ext_s12
	.type	ext_s12, @object
	.size	ext_s12, 4
ext_s12:
	.string	"TMD"
	.globl	ext_s11
	.type	ext_s11, @object
	.size	ext_s11, 4
ext_s11:
	.string	"AUX"
	.globl	ext_s10
	.type	ext_s10, @object
	.size	ext_s10, 4
ext_s10:
	.string	"FIN"
	.globl	ext_s9
	.type	ext_s9, @object
	.size	ext_s9, 3
ext_s9:
	.string	"FM"
	.globl	ext_n16
	.type	ext_n16, @object
	.size	ext_n16, 7
ext_n16:
	.string	"Volume"
	.globl	ext_n15
	.type	ext_n15, @object
	.size	ext_n15, 6
ext_n15:
	.string	"Glide"
	.globl	ext_n14
	.type	ext_n14, @object
	.size	ext_n14, 9
ext_n14:
	.string	"Velocity"
	.globl	ext_n13
	.type	ext_n13, @object
	.size	ext_n13, 10
ext_n13:
	.string	"Morph Env"
	.globl	ext_n12
	.type	ext_n12, @object
	.size	ext_n12, 11
ext_n12:
	.string	"Timbre Env"
	.globl	ext_n11
	.type	ext_n11, @object
	.size	ext_n11, 8
ext_n11:
	.string	"Aux Mix"
	.globl	ext_n10
	.type	ext_n10, @object
	.size	ext_n10, 10
ext_n10:
	.string	"Fine Tune"
	.globl	ext_n9
	.type	ext_n9, @object
	.size	ext_n9, 10
ext_n9:
	.string	"Pitch Env"
	.globl	ext_s8
	.text
	.type	ext_s8, @object
	.size	ext_s8, 4
ext_s8:
	.string	"LEV"
	.globl	ext_s7
	.type	ext_s7, @object
	.size	ext_s7, 4
ext_s7:
	.string	"TUN"
	.globl	ext_s6
	.type	ext_s6, @object
	.size	ext_s6, 4
ext_s6:
	.string	"LPG"
	.globl	ext_s5
	.type	ext_s5, @object
	.size	ext_s5, 4
ext_s5:
	.string	"DEC"
	.globl	ext_s4
	.type	ext_s4, @object
	.size	ext_s4, 4
ext_s4:
	.string	"MOR"
	.globl	ext_s3
	.type	ext_s3, @object
	.size	ext_s3, 4
ext_s3:
	.string	"TIM"
	.globl	ext_s2
	.type	ext_s2, @object
	.size	ext_s2, 4
ext_s2:
	.string	"HRM"
	.globl	ext_s1
	.type	ext_s1, @object
	.size	ext_s1, 4
ext_s1:
	.string	"ENG"
	.globl	ext_n8
	.type	ext_n8, @object
	.size	ext_n8, 6
ext_n8:
	.string	"Level"
	.globl	ext_n7
	.type	ext_n7, @object
	.size	ext_n7, 5
ext_n7:
	.string	"Tune"
	.globl	ext_n6
	.type	ext_n6, @object
	.size	ext_n6, 11
ext_n6:
	.string	"LPG Colour"
	.globl	ext_n5
	.type	ext_n5, @object
	.size	ext_n5, 6
ext_n5:
	.string	"Decay"
	.globl	ext_n4
	.type	ext_n4, @object
	.size	ext_n4, 6
ext_n4:
	.string	"Morph"
	.globl	ext_n3
	.type	ext_n3, @object
	.size	ext_n3, 7
ext_n3:
	.string	"Timbre"
	.globl	ext_n2
	.type	ext_n2, @object
	.size	ext_n2, 10
ext_n2:
	.string	"Harmonics"
	.globl	ext_n1
	.type	ext_n1, @object
	.size	ext_n1, 7
ext_n1:
	.string	"Engine"
	.globl	ext_short
	.type	ext_short, @object
	.size	ext_short, 5
ext_short:
	.string	"PLTS"
	.globl	ext_long
	.type	ext_long, @object
	.size	ext_long, 7
ext_long:
	.string	"PLAITS"
	.globl	dsp_s6
	.section	.ext6
	.type	dsp_s6, @object
	.size	dsp_s6, 4
dsp_s6:
	.string	"EXC"
	.globl	dsp_s5
	.type	dsp_s5, @object
	.size	dsp_s5, 4
dsp_s5:
	.string	"INP"
	.globl	dsp_s4
	.type	dsp_s4, @object
	.size	dsp_s4, 4
dsp_s4:
	.string	"DMP"
	.globl	dsp_s3
	.type	dsp_s3, @object
	.size	dsp_s3, 4
dsp_s3:
	.string	"BRI"
	.globl	dsp_s2
	.type	dsp_s2, @object
	.size	dsp_s2, 4
dsp_s2:
	.string	"STR"
	.globl	dsp_n6
	.type	dsp_n6, @object
	.size	dsp_n6, 8
dsp_n6:
	.string	"Exciter"
	.globl	dsp_n5
	.type	dsp_n5, @object
	.size	dsp_n5, 6
dsp_n5:
	.string	"Input"
	.globl	dsp_n4
	.type	dsp_n4, @object
	.size	dsp_n4, 8
dsp_n4:
	.string	"Damping"
	.globl	dsp_n3
	.type	dsp_n3, @object
	.size	dsp_n3, 11
dsp_n3:
	.string	"Brightness"
	.globl	dsp_n2
	.type	dsp_n2, @object
	.size	dsp_n2, 10
dsp_n2:
	.string	"Structure"
	.globl	dsp_short
	.type	dsp_short, @object
	.size	dsp_short, 4
dsp_short:
	.string	"DSP"
	.globl	dsp_long
	.type	dsp_long, @object
	.size	dsp_long, 8
dsp_long:
	.string	"DAISYSP"
	.ident	"GCC: (GNU) 16.2.0"
	.else
#NO_APP
	.file	"ext.c"
	.text
#APP
	  .section .ext2,"ax"
  .globl ext_pvt
ext_pvt:
  jsr ext_ui_tick
  lea %sp@(-20),%sp
  moveml %d2-%d4/%a2-%a3,%sp@
  jmp 0x400a85e8

#NO_APP
	.section	.ext2,"ax",@progbits
	.align	2
	.globl	ext_engine_text
	.type	ext_engine_text, @function
ext_engine_text:
	move.l 8(%sp),%d1
	move.l %d1,%d0
	lsl.l #4,%d0
	move.l 12(%sp),%a0
	add.l %d1,%d0
	moveq #15,%d1
	asr.l %d1,%d0
	moveq #16,%d1
	cmp.l %d0,%d1
	jge .L2
	moveq #16,%d0
.L3:
	mvz.w %d0,%d0
	move.l %a0,4(%sp)
	lsl.l #3,%d0
	add.l #ext_engine_names,%d0
	move.l %d0,12(%sp)
	move.l #ext_fmt_s,%d0
	move.l %d0,8(%sp)
	jmp 1074365954
.L2:
	tst.l %d0
	jge .L3
	clr.l %d0
	jra .L3
	.size	ext_engine_text, .-ext_engine_text
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
.L5:
	lea (%a0,%d0.l),%a2
	moveq #84,%d1
	move.l (%a2),(%a1,%a0.l)
	addq.l #4,%a0
	cmp.l %a0,%d1
	jne .L5
	move.l (%sp)+,%a2
	rts
	.size	copy_desc, .-copy_desc
	.section	.ext5,"ax",@progbits
	.align	2
	.globl	dsp_engine_text
	.type	dsp_engine_text, @function
dsp_engine_text:
	move.l %d2,-(%sp)
	move.l 12(%sp),%d0
	mov3q.l #3,%d2
	move.l 16(%sp),%d1
	muls.l %d2,%d0
	moveq #15,%d2
	asr.l %d2,%d0
	mov3q.l #2,%d2
	cmp.l %d0,%d2
	jge .L8
	mov3q.l #2,%d0
.L9:
	mvz.w %d0,%d0
	move.l %d1,8(%sp)
	lsl.l #3,%d0
	add.l #dsp_engine_names,%d0
	move.l %d0,16(%sp)
	move.l #ext_fmt_s,%d0
	move.l %d0,12(%sp)
	move.l (%sp)+,%d2
	jmp 1074365954
.L8:
	tst.l %d0
	jge .L9
	clr.l %d0
	jra .L9
	.size	dsp_engine_text, .-dsp_engine_text
	.align	2
	.globl	dsp_input_text
	.type	dsp_input_text, @function
dsp_input_text:
	move.l %d2,-(%sp)
	moveq #11,%d2
	move.l 12(%sp),%d0
	move.l 16(%sp),%d1
	muls.l %d2,%d0
	moveq #15,%d2
	asr.l %d2,%d0
	moveq #10,%d2
	cmp.l %d0,%d2
	jge .L11
	moveq #10,%d0
.L12:
	mulu.w #6,%d0
	move.l %d1,8(%sp)
	add.l #dsp_input_names,%d0
	move.l %d0,16(%sp)
	move.l #ext_fmt_s,%d0
	move.l %d0,12(%sp)
	move.l (%sp)+,%d2
	jmp 1074365954
.L11:
	tst.l %d0
	jge .L12
	clr.l %d0
	jra .L12
	.size	dsp_input_text, .-dsp_input_text
	.section	.ext4,"ax",@progbits
	.align	2
	.type	ext_view_machine, @function
ext_view_machine:
	move.l %a2,-(%sp)
	move.l 8(%sp),%a2
	move.l (%a2),%a0
	move.l %a2,-(%sp)
	move.l 144(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	tst.l %d0
	jge .L14
	move.l 116(%a2),-(%sp)
	jsr 1074489554
	move.l %d0,-(%sp)
	move.l 120(%a2),-(%sp)
	jsr 1074423646
	lea (12,%sp),%sp
.L15:
	move.l %d0,8(%sp)
	move.l (%sp)+,%a2
	jmp 1074514544
.L14:
	move.l %d0,-(%sp)
	move.l 104(%a2),-(%sp)
	jsr 1074455700
	addq.l #8,%sp
	jra .L15
	.size	ext_view_machine, .-ext_view_machine
	.section	.extd,"ax",@progbits
	.align	2
	.type	dd_name_knobs, @function
dd_name_knobs:
	move.w 6(%sp),%d0
	move.l #1075595396,%a0
	mulu.w #7,%d0
	move.l %d0,%a1
	add.l #dd_label,%a1
.L17:
	mvz.b (%a1)+,%d0
	lea (52,%a0),%a0
	mulu.w #5,%d0
	move.l %d0,%d1
	add.l #dd_pool,%d1
	move.l %d1,-4(%a0)
	move.l %d1,-12(%a0)
	cmp.l #1075595760,%a0
	jne .L17
	rts
	.size	dd_name_knobs, .-dd_name_knobs
	.align	2
	.globl	dd_engine_text
	.type	dd_engine_text, @function
dd_engine_text:
	subq.l #4,%sp
	move.l %d2,-(%sp)
	moveq #11,%d0
	move.l 16(%sp),%d2
	move.l 20(%sp),4(%sp)
	muls.l %d0,%d2
	moveq #15,%d0
	asr.l %d0,%d2
	moveq #10,%d0
	cmp.l %d2,%d0
	jge .L20
	moveq #10,%d2
.L21:
	move.l %d2,-(%sp)
	mulu.w #7,%d2
	jsr dd_name_knobs
	addq.l #4,%sp
	move.l 4(%sp),12(%sp)
	move.l #ext_fmt_s,%d0
	move.l %d0,16(%sp)
	add.l #dd_names,%d2
	move.l %d2,20(%sp)
	move.l (%sp)+,%d2
	addq.l #4,%sp
	jmp 1074365954
.L20:
	tst.l %d2
	jge .L21
	clr.l %d2
	jra .L21
	.size	dd_engine_text, .-dd_engine_text
	.section	.ext7,"ax",@progbits
	.align	2
	.globl	dsp_out_text
	.type	dsp_out_text, @function
dsp_out_text:
	move.w #16383,%a0
	move.l 12(%sp),%d1
	cmp.l 8(%sp),%a0
	slt %d0
	neg.l %d0
	tst.b %d0
	jeq .L23
	mov3q.l #6,%d0
.L24:
	add.l #dsp_out_names,%d0
	move.l %d0,12(%sp)
	move.l #ext_fmt_s,%d0
	move.l %d0,8(%sp)
	move.l %d1,4(%sp)
	jmp 1074365954
.L23:
	clr.l %d0
	jra .L24
	.size	dsp_out_text, .-dsp_out_text
	.section	.ext9,"ax",@progbits
	.align	2
	.globl	jn_sysex
	.type	jn_sysex, @function
jn_sysex:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.l 16(%sp),%a0
	moveq #21,%d3
	move.l 20(%sp),%d1
	move.b 4(%a0),%d0
	mvz.b %d0,%d2
	cmp.l %d2,%d3
	jne .L26
	moveq #12,%d4
	cmp.l %d1,%d4
	jge .L27
	move.b 5(%a0),%d0
	mov3q.l #7,%d1
	move.l #1076432344,%a1
	moveq #11,%d3
	and.l %d1,%d0
	move.b (%a1,%d0.l),%d2
	mvz.b %d2,%d0
	cmp.l %d0,%d3
	jcs .L27
	move.l #-2147423744,%a1
	moveq #41,%d4
	mvz.b (%a1,%d0.l),%d0
	cmp.l %d0,%d4
	jne .L27
	clr.l %d0
	lea jn_mailbox+13,%a1
.L28:
	move.b 6(%a0,%d0.l),%d1
	moveq #127,%d3
	addq.l #1,%d0
	mov3q.l #6,%d4
	and.l %d3,%d1
	move.b %d1,-1(%a1,%d0.l)
	cmp.l %d0,%d4
	jne .L28
	moveq #1,%d0
	move.b %d2,jn_mailbox+12
	move.b %d0,jn_mailbox+11
.L27:
	movem.l (%sp),#28
	mov3q.l #1,%d0
	lea (12,%sp),%sp
	rts
.L26:
	move.l %d0,%d2
	add.l #-22,%d2
	mvz.b %d2,%d2
	lsr.l #1,%d2
	jne .L27
	mov3q.l #7,%d4
	cmp.l %d1,%d4
	jge .L27
	tst.b 5(%a0)
	jeq .L29
	lea jn_mailbox+36,%a1
	moveq #127,%d0
.L30:
	clr.b (%a1)
	subq.l #1,%d0
	lea (10,%a1),%a1
	tst.l %d0
	jne .L30
	move.b 6(%a0),%d0
	jpl .L31
	moveq #127,%d0
.L31:
	move.b %d0,jn_mailbox+9
	move.b 4(%a0),%d0
	add.l #-22,%d0
	move.b %d0,jn_mailbox+19
	moveq #1,%d0
	move.b %d0,jn_mailbox+8
.L32:
	subq.l #1,%d1
	addq.l #7,%a0
	moveq #8,%d2
.L33:
	move.l %d2,%d0
	add.l #12,%d0
	cmp.l %d1,%d0
	jge .L27
	move.b (%a0),%d0
	moveq #126,%d4
	mvz.b %d0,%d3
	cmp.l %d3,%d4
	jcs .L34
	ext.w %d0
	mulu.w #10,%d0
	move.l %d0,%a1
	clr.l %d0
	add.l #jn_mailbox+36,%a1
.L35:
	move.b 1(%a0,%d0.l),%d3
	jeq .L36
	move.b %d3,(%a1,%d0.l)
	addq.l #1,%d0
	moveq #9,%d3
	cmp.l %d0,%d3
	jne .L35
.L36:
	clr.b %d4
	move.b %d4,(%a1,%d0.l)
.L34:
	add.l #14,%d2
	lea (14,%a0),%a0
	jra .L33
.L29:
	moveq #22,%d2
	eor.l %d2,%d0
	mvz.b jn_mailbox+19,%d2
	tst.b %d0
	sne %d0
	neg.l %d0
	mvz.b %d0,%d0
	cmp.l %d2,%d0
	jne .L27
	jra .L32
	.size	jn_sysex, .-jn_sysex
	.section	.exto,"ax",@progbits
	.align	2
	.type	mod_text, @function
mod_text:
	lea (-16,%sp),%sp
	move.l 24(%sp),%d1
	move.l %d1,%d0
	lsl.l #3,%d0
	movem.l #3084,(%sp)
	move.l 28(%sp),%a0
	mov3q.l #6,%d3
	sub.l %d1,%d0
	moveq #15,%d1
	asr.l %d1,%d0
	cmp.l %d0,%d3
	jge .L45
	mov3q.l #6,%d0
.L46:
	move.l %d0,%a3
	moveq #10,%d3
	lea (%a3,%d0.l*2),%a1
	lea mod_label,%a2
	move.b (%a1,%a2.l),%d1
	mvz.b %d1,%d2
	cmp.l %d2,%d3
	jcs .L50
	ext.w %d1
	mvz.w %d1,%d1
	lsl.l #2,%d1
	add.l #mod_pool,%d1
.L47:
	move.l %d1,1075598252
	moveq #10,%d3
	move.l %d1,1075598244
	move.b 1(%a2,%a1.l),%d1
	mvz.b %d1,%d2
	cmp.l %d2,%d3
	jcs .L51
	ext.w %d1
	mvz.w %d1,%d1
	lsl.l #2,%d1
	add.l #mod_pool,%d1
.L48:
	move.l %d1,1075598304
	moveq #10,%d3
	move.l %d1,1075598296
	move.b 2(%a2,%a1.l),%d1
	mvz.b %d1,%d2
	cmp.l %d2,%d3
	jcs .L52
	ext.w %d1
	mvz.w %d1,%d1
	lsl.l #2,%d1
	add.l #mod_pool,%d1
.L49:
	move.l %d1,1075598356
	move.l %d1,1075598348
	lea ext_fmt_s,%a3
	move.l %a3,24(%sp)
	mulu.w #6,%d0
	move.l %a0,20(%sp)
	movem.l (%sp),#3084
	add.l #mod_names,%d0
	move.l %d0,28(%sp)
	lea (16,%sp),%sp
	jmp 1074365954
.L45:
	tst.l %d0
	jge .L46
	clr.l %d0
	jra .L46
.L50:
	move.l #jn_empty,%d1
	jra .L47
.L51:
	move.l #jn_empty,%d1
	jra .L48
.L52:
	move.l #jn_empty,%d1
	jra .L49
	.size	mod_text, .-mod_text
	.align	2
	.globl	usb_free
	.type	usb_free, @function
usb_free:
	move.l 4(%sp),%d0
	move.l 1094562704,%a0
.L54:
	tst.l %d0
	jgt .L56
	mov3q.l #1,%d0
.L53:
	rts
.L56:
	tst.l %a0
	jeq .L57
	move.l 52(%a0),%a0
	subq.l #1,%d0
	jra .L54
.L57:
	clr.l %d0
	jra .L53
	.size	usb_free, .-usb_free
	.section	.ext9
	.align	2
	.type	ext_try_send, @function
ext_try_send:
	subq.l #4,%sp
	tst.l 1123449384
	jeq .L59
.L61:
	clr.l %d0
.L58:
	addq.l #4,%sp
	rts
.L59:
	tst.l 1094562372
	jne .L61
	mvz.w #3800,%d0
	cmp.l 1094562392.l,%d0
	jcs .L61
	mov3q.l #2,-(%sp)
	jsr usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L58
	move.l 8(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	move.l %d0,8(%sp)
	jsr 1073752544
	addq.l #8,%sp
	move.l (%sp),%d0
	jra .L58
	.size	ext_try_send, .-ext_try_send
	.section	.extp,"ax",@progbits
	.align	2
	.type	ext_project, @function
ext_project:
	link.w %fp,#-28
	move.l ext_proj,%d1
	addq.l #1,%d1
	move.l %d2,-(%sp)
	move.l %d1,ext_proj
	tst.b %d1
	jne .L66
	move.l #1081903571,%a0
	mov3q.l #1,%a1
.L68:
	move.l #ext_proj-1081903567,%d2
	addq.l #1,%a0
	move.b -1(%a0,%d2.l),%d2
	move.b -1(%a0),%d0
	eor.l %d2,%d0
	move.l %a1,%d2
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
	and.l %d0,%d2
	move.l %d2,%a1
	cmp.l #1081903587,%a0
	jne .L68
	tst.l %d2
	jeq .L69
	and.l #16383,%d1
	tst.l %d1
	jne .L66
.L69:
	moveq #16,%d0
	move.l #-260222380,%a1
	mov3q.l #5,%a0
	move.l %a1,-22(%fp)
	move.l #1081903566,%a1
	move.b %d0,-18(%fp)
.L70:
	move.b (%a0,%a1.l),%d0
	jeq .L71
	moveq #127,%d1
	addq.l #1,%a0
	and.l %d1,%d0
	moveq #20,%d2
	move.b %d0,-23(%a0,%fp.l)
	cmp.l %a0,%d2
	jne .L70
.L71:
	moveq #-9,%d0
	move.b %d0,-22(%fp,%a0.l)
	pea 1(%a0)
	pea -22(%fp)
	jsr ext_try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L66
	move.l #1081903571,%a0
.L73:
	lea ext_proj-1081903567,%a1
	move.b (%a0),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L73
.L66:
	move.l -32(%fp),%d2
	unlk %fp
	rts
	.size	ext_project, .-ext_project
	.section	.extq,"ax",@progbits
	.align	2
	.type	diag_text, @function
diag_text:
	lea (-16,%sp),%sp
	moveq #12,%d0
	movem.l #1052,(%sp)
	move.l 24(%sp),%d3
	asr.l %d0,%d3
	mov3q.l #7,%d0
	and.l %d0,%d3
	moveq #11,%d0
	mvz.b 1093765506,%d2
	cmp.l %d2,%d0
	jge .L86
	clr.l %d2
.L86:
	mov3q.l #6,%d0
	cmp.l %d3,%d0
	jcs .L87
	move.w .L89(%pc,%d3.l*2),%d0
	ext.l %d0
	jmp %pc@(2,%d0:l)
	.balignw 2,0x284c
	.swbeg	&7
.L89:
	.word .L95-.L89
	.word .L98-.L89
	.word .L93-.L89
	.word .L92-.L89
	.word .L91-.L89
	.word .L90-.L89
	.word .L88-.L89
.L95:
	move.l ext_diag_max,%d2
.L88:
	lea diag_key,%a0
	mvs.b (%a0,%d3.l),%d3
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	pea diag_fmt
	move.l 40(%sp),-(%sp)
	jsr 1074365954
	movem.l 16(%sp),#1052
	lea (32,%sp),%sp
	rts
.L98:
	clr.l %d4
.L94:
	move.l %d4,%d2
	addq.l #1,%d4
	move.l %d4,-(%sp)
	jsr usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L88
	moveq #40,%d0
	cmp.l %d4,%d0
	jne .L94
	moveq #40,%d2
	jra .L88
.L93:
	move.l 1079807120,%d2
	jra .L88
.L92:
	mulu.w #152,%d2
	move.l %d2,%a0
	add.l #1092966707,%a0
	mvz.b (%a0),%d2
	jra .L88
.L91:
	move.l #-2147423744,%a0
	mvz.b (%a0,%d2.l),%d2
	jra .L88
.L90:
	move.l 1094562392,%d2
	jra .L88
.L87:
	clr.l ext_diag_max
	clr.l %d2
	jra .L88
	.size	diag_text, .-diag_text
	.section	.ext4
	.align	2
	.globl	ext_page_record
	.type	ext_page_record, @function
ext_page_record:
	lea (-12,%sp),%sp
	movem.l #1036,(%sp)
	move.l 16(%sp),%a2
	move.l 20(%sp),%d2
	move.l (%a2),%a0
	move.l %a2,-(%sp)
	move.l 104(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l %d0,%d3
	mov3q.l #7,%d0
	cmp.l %d2,%d0
	jcs .L105
	move.l %d3,%d0
	subq.l #4,%d0
	lsr.l #1,%d0
	jne .L102
	move.l %a2,-(%sp)
	jsr ext_view_machine
	addq.l #4,%sp
	moveq #44,%d1
	cmp.l %d0,%d1
	jne .L103
	lea ext_p2_order,%a0
.L106:
	move.l (%a0,%d2.l*4),%d0
.L100:
	movem.l (%sp),#1036
	lea (12,%sp),%sp
	rts
.L103:
	moveq #51,%d1
	cmp.l %d0,%d1
	jne .L104
	lea dsp_p2_order,%a0
	jra .L106
.L104:
	moveq #45,%d1
	cmp.l %d0,%d1
	jne .L102
	lea dsps_p2_order,%a0
	jra .L106
.L102:
	move.l %d3,-(%sp)
	jsr 1074787700
	addq.l #1,%d2
	mvz.w %d2,%d2
	addq.l #4,%sp
	move.l %d0,%a0
	move.l (%a0,%d2.l*4),%d0
	jra .L100
.L105:
	clr.l %d0
	jra .L100
	.size	ext_page_record, .-ext_page_record
	.align	2
	.globl	ext_page_title
	.type	ext_page_title, @function
ext_page_title:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.l 12(%sp),%a2
	move.l (%a2),%a0
	move.l %a2,-(%sp)
	move.l 104(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l %d0,%d2
	subq.l #4,%d0
	lsr.l #1,%d0
	jne .L108
	move.l %a2,-(%sp)
	jsr ext_view_machine
	addq.l #4,%sp
	moveq #44,%d1
	cmp.l %d0,%d1
	jne .L109
	move.l #ext_p2_title,%d0
.L107:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L109:
	moveq #51,%d1
	cmp.l %d0,%d1
	jne .L111
	move.l #dsp_p2_title,%d0
	jra .L107
.L111:
	moveq #45,%d1
	cmp.l %d0,%d1
	jne .L108
	move.l #dsps_p2_title,%d0
	jra .L107
.L108:
	move.l %d2,-(%sp)
	jsr 1074787700
	addq.l #4,%sp
	move.l %d0,%a0
	move.l (%a0),%d0
	jra .L107
	.size	ext_page_title, .-ext_page_title
	.align	2
	.globl	ext_param_record
	.type	ext_param_record, @function
ext_param_record:
	move.l %d2,-(%sp)
	moveq #41,%d1
	move.l 8(%sp),%a0
	move.l 12(%sp),%d0
	cmp.l %a0,%d1
	jcc .L113
.L116:
	clr.l %d0
.L112:
	move.l (%sp)+,%d2
	rts
.L113:
	move.l %a0,%d1
	add.l #-9,%d1
	lsr.l #3,%d1
	jne .L115
	moveq #52,%d1
	cmp.l %d0,%d1
	jcs .L116
	lsl.l #3,%d0
	add.l %a0,%d0
	move.l #1094563324,%a0
	move.l -36(%a0,%d0.l*4),%d0
	jra .L112
.L115:
	moveq #45,%d2
	cmp.l %d0,%d2
	jne .L117
	moveq #17,%d1
	cmp.l %a0,%d1
	jeq .L120
	moveq #19,%d2
	cmp.l %a0,%d2
	jeq .L121
.L117:
	move.l %a0,%d1
	add.l #-17,%d1
	lsr.l #3,%d1
	jne .L118
	moveq #45,%d1
	cmp.l %d0,%d1
	jeq .L122
	moveq #51,%d2
	cmp.l %d0,%d2
	jeq .L123
	moveq #44,%d1
	cmp.l %d0,%d1
	jeq .L124
	move.w #39,%a1
.L119:
	lea -17(%a1,%a0.l),%a0
	move.l %a0,%d0
	jra .L112
.L122:
	move.w #441,%a1
	jra .L119
.L123:
	move.w #430,%a1
	jra .L119
.L124:
	move.w #422,%a1
	jra .L119
.L118:
	move.l #1094563156,%a1
	move.l (%a1,%a0.l*4),%d0
	jra .L112
.L120:
	moveq #39,%d0
	jra .L112
.L121:
	mvz.w #441,%d0
	jra .L112
	.size	ext_param_record, .-ext_param_record
	.section	.extd
	.align	2
	.globl	dd_descriptors
	.type	dd_descriptors, @function
dd_descriptors:
	lea (-12,%sp),%sp
	movem.l #3076,(%sp)
	mvz.w #390,%d2
	move.l #1075595388,%a2
	lea copy_desc,%a3
.L126:
	pea 410.w
	move.l %d2,-(%sp)
	jsr (%a3)
	move.l #dd_short,(%a2)
	addq.l #1,%d2
	lea (52,%a2),%a2
	addq.l #8,%sp
	cmp.l #1075595804,%a2
	jne .L126
	move.l #dd_eng,%d0
	move.l %d0,1075595392
	move.l %d0,1075595384
	move.l #dd_engine_text,%d0
	move.l %d0,1100662944
	clr.l -(%sp)
	jsr dd_name_knobs
	movem.l 4(%sp),#3076
	lea (16,%sp),%sp
	rts
	.size	dd_descriptors, .-dd_descriptors
	.section	.extj,"ax",@progbits
	.align	2
	.globl	jn_patch_text
	.type	jn_patch_text, @function
jn_patch_text:
	move.l %d2,-(%sp)
	moveq #127,%d2
	move.l 12(%sp),%d1
	asr.l #8,%d1
	move.l %d1,%d0
	cmp.l %d1,%d2
	jge .L129
	moveq #127,%d0
.L130:
	mov3q.l #7,%d2
	and.l %d0,%d2
	asr.l #3,%d0
	move.l %d2,%a0
	mov3q.l #7,%d2
	and.l %d2,%d0
	addq.l #1,%a0
	moveq #63,%d2
	addq.l #1,%d0
	cmp.l %d1,%d2
	jlt .L132
	moveq #65,%d1
.L131:
	move.l %a0,-(%sp)
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	pea jn_fmt
	move.l 32(%sp),-(%sp)
	jsr 1074365954
	lea (20,%sp),%sp
	move.l (%sp)+,%d2
	rts
.L129:
	tst.l %d1
	jge .L130
	clr.l %d0
	jra .L130
.L132:
	moveq #66,%d1
	jra .L131
	.size	jn_patch_text, .-jn_patch_text
	.section	.ext9
	.align	2
	.type	pat_text, @function
pat_text:
	lea (-56,%sp),%sp
	movem.l #17468,(%sp)
	move.b 75(%sp),%d3
	move.b jn_mailbox+19,%d0
	move.l 64(%sp),%d4
	move.l %d4,%d5
	asr.l #8,%d5
	move.l 68(%sp),%d2
	move.l #1081903571,%a0
	move.l 60(%sp),28(%sp)
	lea jn_mailbox-1081903551,%a2
	move.l %d5,%a6
	eor.l %d3,%d0
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
.L134:
	move.b (%a0,%a2.l),%d1
	move.b (%a0)+,%d5
	move.w %d5,%a1
	move.l %a1,%d5
	eor.l %d5,%d1
	tst.b %d1
	seq %d1
	mvs.b %d1,%d1
	neg.l %d1
	and.l %d1,%d0
	cmp.l #1081903587,%a0
	jne .L134
	tst.l %d0
	jne .L135
	move.b %d0,jn_mailbox+8
.L136:
	move.b jn_mailbox+10,%d0
	jeq .L138
	subq.l #1,%d0
	move.b %d0,jn_mailbox+10
.L139:
	tst.b %d3
	jeq .L148
	move.l #fm_fmt_d,%d0
	move.l %a6,68(%sp)
	move.l %d0,64(%sp)
	jra .L162
.L135:
	tst.b jn_mailbox+8.l
	jeq .L136
	move.b jn_mailbox+9,%d1
	jeq .L139
	move.l %a6,%d0
	tst.l %a6
	jge .L145
	clr.l %d0
.L145:
	mvz.b %d1,%d1
	cmp.l %d1,%d0
	jlt .L146
	move.l %d1,%d0
	subq.l #1,%d0
.L146:
	moveq #10,%d1
	muls.l %d0,%d1
	move.l %d1,%a0
	add.l #jn_mailbox+36,%a0
	tst.b (%a0)
	jeq .L150
	mulu.w #10,%d0
	add.l #jn_mailbox+36,%d0
.L147:
	lea ext_fmt_s,%a1
	move.l %d0,68(%sp)
	move.l %a1,64(%sp)
.L162:
	move.l %d2,60(%sp)
	movem.l (%sp),#17468
	lea (56,%sp),%sp
	jmp 1074365954
.L138:
	mov3q.l #4,-(%sp)
	jsr usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L139
	moveq #16,%d5
	move.l #-260222380,%d1
	mov3q.l #5,%a0
	move.l %d1,34(%sp)
	move.l #1081903566,%a1
	move.b %d5,38(%sp)
.L140:
	move.b (%a0,%a1.l),%d0
	jeq .L141
	moveq #127,%d1
	addq.l #1,%a0
	and.l %d1,%d0
	moveq #20,%d5
	move.b %d0,33(%a0,%sp.l)
	cmp.l %a0,%d5
	jne .L140
.L141:
	moveq #-9,%d0
	lea (1,%a0),%a1
	move.l %a1,24(%sp)
	move.b %d0,34(%sp,%a0.l)
	move.l #1081903571,%a0
.L143:
	move.b (%a0),(%a2,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L143
	moveq #-56,%d1
	lea (34,%sp),%a2
	move.b %d1,jn_mailbox+10
	jsr 1073752340
	move.l %a2,-(%sp)
	move.l 28(%sp),-(%sp)
	jsr 1073752544
	addq.l #8,%sp
	tst.b %d3
	jeq .L149
	moveq #24,%d0
.L144:
	moveq #-9,%d5
	move.b %d0,38(%sp)
	move.b %d5,39(%sp)
	move.l %a2,-(%sp)
	mov3q.l #6,-(%sp)
	jsr 1073752544
	jsr 1073752356
	addq.l #8,%sp
	jra .L139
.L149:
	moveq #19,%d0
	jra .L144
.L150:
	move.l #jn_empty,%d0
	jra .L147
.L148:
	move.l %d2,68(%sp)
	move.l %d4,64(%sp)
	movem.l (%sp),#17468
	move.l 28(%sp),60(%sp)
	lea (56,%sp),%sp
	jra jn_patch_text
	.size	pat_text, .-pat_text
	.align	2
	.globl	jn_pat_text
	.type	jn_pat_text, @function
jn_pat_text:
	clr.l -(%sp)
	move.l 16(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	jsr pat_text
	lea (16,%sp),%sp
	rts
	.size	jn_pat_text, .-jn_pat_text
	.align	2
	.globl	fm_pat_text
	.type	fm_pat_text, @function
fm_pat_text:
	mov3q.l #1,-(%sp)
	move.l 16(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	jsr pat_text
	lea (16,%sp),%sp
	rts
	.size	fm_pat_text, .-fm_pat_text
	.section	.extl,"ax",@progbits
	.align	2
	.globl	jn_descriptors
	.type	jn_descriptors, @function
jn_descriptors:
	lea (-24,%sp),%sp
	movem.l #3132,(%sp)
	move.l #jn_long,%d4
	mov3q.l #-1,%d2
	move.l #jn_short,%d3
	move.l #1075594928,%a2
	lea copy_desc,%a3
.L167:
	move.l %d2,%d1
	mov3q.l #5,%d5
	mvz.w #410,%d0
	add.l #383,%d1
	cmp.l %d2,%d5
	jcs .L166
	moveq #40,%d0
.L166:
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	jsr (%a3)
	move.l %d4,40(%a2)
	move.l %d3,48(%a2)
	addq.l #1,%d2
	move.l #jn_name,%d0
	add.l #11,%d4
	move.l %d0,44(%a2)
	lea (52,%a2),%a2
	addq.l #4,%d3
	addq.l #8,%sp
	mov3q.l #7,%d5
	cmp.l %d2,%d5
	jne .L167
	movem.l (%sp),#3132
	move.l #jn_pat_text,%d0
	move.l %d0,1100662272
	lea (24,%sp),%sp
	rts
	.size	jn_descriptors, .-jn_descriptors
	.section	.exto
	.align	2
	.globl	ext_gate
	.type	ext_gate, @function
ext_gate:
	link.w %fp,#-12
	move.l 8(%fp),%d0
	mov3q.l #7,%d1
	move.l %d2,-(%sp)
	move.l #1076432344,%a0
	mov3q.l #-1,%d2
	and.l %d0,%d1
	mvz.b (%a0,%d0.l),%d0
	mulu.w #12,%d0
	move.l %d0,%a0
	moveq #70,%d0
	muls.l %d1,%d0
	add.l #-2147418536,%a0
	cmp.l (%a0),%d2
	jne .L171
	cmp.l 8(%a0),%d2
	jne .L171
	cmp.l 4(%a0),%d2
	jeq .L172
	tst.l 1079807120
	jeq .L172
.L171:
	moveq #1,%d1
	lea ext_state,%a0
	move.b %d1,69(%a0,%d0.l)
.L173:
	move.l -16(%fp),%d2
	unlk %fp
	jra ext_project
.L172:
	lea ext_state,%a0
	add.l %d0,%a0
	move.l %a0,-12(%fp)
	tst.b 69(%a0)
	jeq .L173
	tst.b 66(%a0)
	jne .L173
	move.l #-260222380,%d0
	move.l %d0,-7(%fp)
	moveq #-9,%d0
	moveq #17,%d2
	mov3q.l #7,-(%sp)
	pea -7(%fp)
	move.b %d1,-2(%fp)
	move.b %d0,-1(%fp)
	move.b %d2,-3(%fp)
	jsr ext_try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L173
	clr.b %d1
	move.l -12(%fp),%a0
	move.b %d1,69(%a0)
	jra .L173
	.size	ext_gate, .-ext_gate
	.section	.ext7
	.align	2
	.globl	dsp_excite
	.type	dsp_excite, @function
dsp_excite:
	lea (-124,%sp),%sp
	movem.l #23676,(%sp)
	move.l 136(%sp),%a3
	mvz.b 8(%a3),%d0
	muls.w #11,%d0
	asr.l #7,%d0
	move.l %d0,%a6
	mov3q.l #1,%d0
	cmp.l %a6,%d0
	jne .L185
	move.l #1076432344,%a0
	move.l 128(%sp),%a1
	mvz.b (%a1,%a0.l),%d0
	move.l #1075573068,%a0
	move.l (%a0,%d0.l*4),%d2
.L186:
	clr.l %d0
	lea (40,%sp),%a2
.L188:
	lea (%a3,%d0.l),%a0
	moveq #84,%d1
	move.w (%a0),(%a2,%d0.l)
	addq.l #2,%d0
	cmp.l %d0,%d1
	jne .L188
	move.l %d2,%d0
	clr.l %d1
	lsl.l #5,%d0
	lea dsp_x_word,%a4
	move.l %d0,%a1
	add.l #1094563324,%a1
.L192:
	move.l (%a1),%d0
	tst.l %d0
	jle .L189
	moveq #52,%d3
	mov3q.l #4,%d4
	muls.l %d3,%d0
	move.l %d0,%a0
	add.l #1075575064,%a0
	cmp.l %d1,%d4
	jge .L190
	move.l 16(%a0),%d0
.L191:
	move.w %d0,(%a2,%d1.l*2)
.L189:
	addq.l #1,%d1
	addq.l #4,%a1
	moveq #8,%d5
	cmp.l %d1,%d5
	jne .L192
	move.l #1076429692,%a0
	move.l 140(%sp),-(%sp)
	move.l (%a0,%d2.l*4),%a0
	move.l %a2,-(%sp)
	move.l 140(%sp),-(%sp)
	move.l 140(%sp),-(%sp)
	jsr (%a0)
	lea (16,%sp),%sp
.L184:
	move.l %a6,%d0
	movem.l (%sp),#23676
	lea (124,%sp),%sp
	rts
.L185:
	mov3q.l #2,%d0
	cmp.l %a6,%d0
	jne .L193
	moveq #15,%d2
	jra .L186
.L190:
	move.l 8(%a0),%d0
	moveq #127,%d6
	move.l 12(%a0),%a0
	sub.l %d0,%a0
	move.l %a0,%d5
	divs.l %d6,%d5
	mvz.b (%a4,%d1.l),%d3
	mvz.b (%a3,%d3.l*2),%d3
	muls.l %d5,%d3
	add.l %d3,%d0
	jra .L191
.L193:
	sub.l %a6,%a6
	jra .L184
	.size	dsp_excite, .-dsp_excite
	.text
	.align	2
	.globl	ext_render_body
	.type	ext_render_body, @function
ext_render_body:
	lea (-108,%sp),%sp
	moveq #11,%d1
	movem.l #23580,(%sp)
	move.l 112(%sp),%a3
	move.l %a3,%d0
	lsl.l #5,%d0
	move.l %a3,%d2
	move.l #1076432344,%a2
	add.l %a3,%a2
	move.l #-2147423744,%a0
	move.l %d0,%a4
	mov3q.l #7,%d0
	and.l %d0,%d2
	mvz.b (%a2),%d0
	add.l #-2147418376,%a4
	move.l (%a4),%a6
	move.b (%a0,%d0.l),%d0
	move.b %d2,%d3
	add.l #-40,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jcs .L197
	move.w .L199(%pc,%d0.l*2),%d0
	ext.l %d0
	jmp %pc@(2,%d0:l)
	.balignw 2,0x284c
	.swbeg	&12
.L199:
	.word .L203-.L199
	.word .L202-.L199
	.word .L201-.L199
	.word .L197-.L199
	.word .L197-.L199
	.word .L200-.L199
	.word .L197-.L199
	.word .L197-.L199
	.word .L197-.L199
	.word .L197-.L199
	.word .L197-.L199
	.word .L198-.L199
.L198:
	move.l 124(%sp),-(%sp)
	move.l 124(%sp),-(%sp)
	move.l 124(%sp),-(%sp)
	move.l %a3,-(%sp)
	moveq #16,%d3
	jsr dsp_excite
	lea (16,%sp),%sp
	or.l %d2,%d3
	tst.l %d0
	jeq .L197
.L204:
	move.l %a3,-(%sp)
	move.l %d0,32(%sp)
	jsr ext_gate
	addq.l #4,%sp
	mov3q.l #2,%d4
	cmp.l 28(%sp),%d4
	jeq .L205
	moveq #120,%d0
	moveq #64,%d1
	and.l %d3,%d0
	cmp.l %d0,%d1
	jeq .L205
	move.l %d2,%d0
	add.l #-268431872,%d0
	lsl.l #3,%d0
	move.l %d0,%a0
	move.l %d2,%d0
	lsl.l #3,%d0
	clr.l (%a0)
	move.l %d0,%a0
	add.l #-2147454972,%a0
	clr.l (%a0)
.L205:
	move.w %d2,%d0
	clr.l %d1
	sub.l %a0,%a0
	mulu.w #70,%d0
	move.l %d0,%a3
	add.l #ext_state,%a3
.L206:
	move.l 120(%sp),%a1
	mvz.w (%a1,%d1.l),%d0
	move.w (%a3,%d1.l),%a1
	addq.l #2,%d1
	lsr.l #1,%d0
	and.l #16383,%d0
	move.l %a1,%d4
	move.w %d0,30(%sp,%d1.l)
	eor.l %d4,%d0
	move.l %a0,%d4
	tst.w %d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d4
	moveq #32,%d0
	move.l %d4,%a0
	cmp.l %d1,%d0
	jne .L206
	tst.l %a6
	jne .L207
	moveq #70,%d0
	moveq #127,%d4
	muls.l %d2,%d0
	moveq #1,%d1
	move.l #-2147457084,%a1
	move.l %d0,%a0
	add.l #ext_state,%a0
	move.l 124(%sp),%d0
	swap %d0
	ext.l %d0
	move.b %d1,66(%a0)
	and.l %d4,%d0
	move.b %d0,64(%a0)
	mvz.b (%a2),%d0
	move.b (%a1,%d0.l*2),%d0
	and.l %d4,%d0
	move.b %d0,65(%a0)
.L208:
	clr.l %d0
.L210:
	lea 32(%sp,%d0.l),%a0
	moveq #32,%d1
	move.w (%a0),32(%a3,%d0.l)
	addq.l #2,%d0
	cmp.l %d0,%d1
	jne .L210
	moveq #70,%d0
	muls.l %d2,%d0
	move.l %d0,%a0
	add.l #ext_state+67,%a0
	move.b #1,(%a0)
	jra .L209
.L200:
	moveq #32,%d3
.L239:
	or.l %d2,%d3
.L197:
	clr.l (%a4)
	move.l 124(%sp),-(%sp)
	move.l 124(%sp),-(%sp)
	move.l 124(%sp),-(%sp)
	move.l %a3,-(%sp)
	jsr 1074872060
	mov3q.l #1,(%a4)
	lea (16,%sp),%sp
	clr.l %d0
	jra .L204
.L201:
	moveq #64,%d3
	jra .L239
.L202:
	moveq #8,%d3
	jra .L239
.L203:
	moveq #72,%d3
	jra .L239
.L207:
	tst.l %d4
	jne .L208
	moveq #70,%d0
	muls.l %d2,%d0
	move.l %d0,%a0
	add.l #ext_state+66,%a0
	tst.b (%a0)
	jne .L208
.L209:
	moveq #70,%d4
	muls.l %d4,%d2
	lea ext_state,%a2
	move.b 68(%a2,%d2.l),%d0
	jeq .L212
	subq.l #1,%d0
	move.b %d0,68(%a2,%d2.l)
.L212:
	lea (%a2,%d2.l),%a0
	tst.b 67(%a0)
	jeq .L196
	move.b 66(%a0),%d0
	jne .L214
	tst.b 68(%a0)
	jne .L196
.L214:
	move.l #-260222380,%a0
	move.l %a0,64(%sp)
	tst.b %d0
	jeq .L215
	moveq #4,%d0
	lea 64(%a2,%d2.l),%a0
	move.b %d3,69(%sp)
	move.b %d0,68(%sp)
	move.w (%a0),70(%sp)
	move.w #8,%a0
.L216:
	lea (64,%sp),%a4
	clr.l %d0
	lea (%a4,%a0.l),%a1
.L217:
	move.w 32(%a3,%d0.l),%d1
	moveq #127,%d4
	addq.l #2,%d0
	addq.l #2,%a1
	move.l %d1,%d3
	lsr.l #7,%d3
	and.l %d4,%d1
	and.l %d4,%d3
	move.b %d1,-1(%a1)
	moveq #32,%d1
	move.b %d3,-2(%a1)
	cmp.l %d0,%d1
	jne .L217
	moveq #-9,%d3
	move.b %d3,96(%sp,%a0.l)
	pea 33(%a0)
	move.l %a4,-(%sp)
	jsr ext_try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L196
	clr.l %d0
.L218:
	move.w 32(%a3),(%a3)
	addq.l #2,%a3
	addq.l #1,%d0
	moveq #16,%d4
	cmp.l %d0,%d4
	jne .L218
	clr.w %d0
	moveq #16,%d1
	move.w %d0,66(%a2,%d2.l)
	move.b %d1,68(%a2,%d2.l)
.L196:
	movem.l (%sp),#23580
	lea (108,%sp),%sp
	rts
.L215:
	moveq #3,%d0
	move.b %d3,69(%sp)
	mov3q.l #6,%a0
	move.b %d0,68(%sp)
	jra .L216
	.size	ext_render_body, .-ext_render_body
	.section	.extc,"ax",@progbits
	.align	2
	.globl	fm_descriptors
	.type	fm_descriptors, @function
fm_descriptors:
	lea (-24,%sp),%sp
	movem.l #7196,(%sp)
	mvz.w #374,%d4
	lea fm_look,%a3
	move.l #fm_long,%d3
	move.l #fm_short,%d2
	move.l #1075594512,%a2
	lea copy_desc,%a4
.L241:
	mvs.w (%a3)+,%d0
	lea (52,%a2),%a2
	move.l %d0,-(%sp)
	move.l %d4,-(%sp)
	jsr (%a4)
	move.l %d3,-12(%a2)
	move.l %d2,-4(%a2)
	addq.l #1,%d4
	move.l #fm_sname,%d0
	add.l #9,%d3
	move.l %d0,-8(%a2)
	addq.l #4,%d2
	addq.l #8,%sp
	cmp.l #1075594928,%a2
	jne .L241
	move.l #fm_pat_text,%d0
	movem.l (%sp),#7196
	move.l %d0,1100661600
	lea (24,%sp),%sp
	rts
	.size	fm_descriptors, .-fm_descriptors
	.section	.extw,"ax",@progbits
	.align	2
	.globl	ext_render
	.type	ext_render, @function
ext_render:
	subq.l #4,%sp
	move.l -66617332,(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	jsr ext_render_body
	move.l -66617332,%d0
	sub.l 16(%sp),%d0
	lea (16,%sp),%sp
	cmp.l ext_diag_max.l,%d0
	jls .L243
	move.l %d0,ext_diag_max
.L243:
	addq.l #4,%sp
	rts
	.size	ext_render, .-ext_render
	.section	.extq
	.align	2
	.globl	diag_desc
	.type	diag_desc, @function
diag_desc:
	pea 410.w
	pea 444.w
	jsr copy_desc
	addq.l #8,%sp
	move.l #diag_text,%d0
	move.l %d0,1100667480
	rts
	.size	diag_desc, .-diag_desc
	.section	.exto
	.align	2
	.globl	mod_desc
	.type	mod_desc, @function
mod_desc:
	pea 410.w
	pea 444.w
	jsr copy_desc
	addq.l #8,%sp
	move.l #mod_text,%d0
	move.l %d0,1100667480
	move.l #mod_long,%d0
	move.l %d0,1075598192
	move.l #mod_short,%d0
	move.l %d0,1075598200
	rts
	.size	mod_desc, .-mod_desc
	.section	.ext7
	.align	2
	.globl	dsp_descriptors2
	.type	dsp_descriptors2, @function
dsp_descriptors2:
	lea (-12,%sp),%sp
	movem.l #7168,(%sp)
	move.w #430,%a3
	lea copy_desc,%a4
	move.l %a4,%a2
.L248:
	pea 410.w
	move.l %a3,-(%sp)
	jsr (%a4)
	addq.l #1,%a3
	addq.l #8,%sp
	cmp.l #438,%a3
	jne .L248
	move.l #dsp_out_text,%d0
	mov3q.l #6,%a3
	move.l %d0,1100666556
	lea dsps_rec,%a4
.L249:
	pea 410.w
	mvs.w (%a4)+,%d0
	subq.l #1,%a3
	move.l %d0,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
	tst.l %a3
	jne .L249
	move.l #dsp_engine_text,%d0
	move.l %d0,1100665128
	pea 100.w
	pea 420.w
	jsr (%a2)
	pea 101.w
	move.w #441,%a3
	pea 421.w
	jsr (%a2)
	lea (16,%sp),%sp
.L250:
	pea -402(%a3)
	move.l %a3,-(%sp)
	jsr (%a2)
	addq.l #1,%a3
	addq.l #8,%sp
	cmp.l #449,%a3
	jne .L250
	pea 410.w
	pea 443.w
	jsr (%a2)
	pea 410.w
	pea 441.w
	jsr (%a2)
	lea (16,%sp),%sp
#APP
| 772 "ext.c" 1
	movel #P_DIAG,%d0
| 0 "" 2
#NO_APP
	tst.l %d0
	jeq .L251
	movem.l (%sp),#7168
	lea (12,%sp),%sp
	jra diag_desc
.L251:
	movem.l (%sp),#7168
	lea (12,%sp),%sp
	jra mod_desc
	.size	dsp_descriptors2, .-dsp_descriptors2
	.section	.ext5
	.align	2
	.globl	dsp_descriptors
	.type	dsp_descriptors, @function
dsp_descriptors:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	mvz.w #449,%d2
	lea copy_desc,%a2
.L256:
	pea 410.w
	move.l %d2,-(%sp)
	jsr (%a2)
	addq.l #1,%d2
	addq.l #8,%sp
	cmp.l #455,%d2
	jne .L256
	move.l #dsp_engine_text,%d0
	move.l %d0,1100667900
	move.l #dsp_input_text,%d0
	move.l %d0,1100668236
	pea 100.w
	move.l %d2,-(%sp)
	jsr (%a2)
	pea 101.w
	pea 456.w
	jsr (%a2)
	lea (16,%sp),%sp
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	jra dsp_descriptors2
	.size	dsp_descriptors, .-dsp_descriptors
	.section	.ext2
	.align	2
	.globl	ext_descriptors
	.type	ext_descriptors, @function
ext_descriptors:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	pea 410.w
	pea 408.w
	lea copy_desc,%a2
	jsr (%a2)
	mvz.w #424,%d2
	move.l #ext_engine_text,%d0
	move.l %d0,1100664456
	pea 410.w
	pea 409.w
	jsr (%a2)
	pea 100.w
	pea 414.w
	jsr (%a2)
	pea 101.w
	pea 415.w
	jsr (%a2)
	lea (32,%sp),%sp
	pea 40.w
	pea 422.w
	jsr (%a2)
	pea 40.w
	pea 423.w
	jsr (%a2)
	lea (16,%sp),%sp
.L259:
	pea 410.w
	move.l %d2,-(%sp)
	jsr (%a2)
	addq.l #1,%d2
	addq.l #8,%sp
	cmp.l #429,%d2
	jne .L259
	pea 101.w
	move.l %d2,-(%sp)
	jsr (%a2)
	jsr dsp_descriptors
	jsr dd_descriptors
	jsr jn_descriptors
	moveq #1,%d0
	addq.l #8,%sp
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	move.b %d0,ext_desc_done
	rts
	.size	ext_descriptors, .-ext_descriptors
	.section	.exto
	.align	2
	.globl	ext_ui_tick
	.type	ext_ui_tick, @function
ext_ui_tick:
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	tst.b ext_desc_done.l
	jne .L262
	jsr ext_descriptors
	jsr fm_descriptors
.L262:
	tst.b jn_mailbox+11.l
	jeq .L261
	clr.b %d0
	moveq #11,%d1
	move.b %d0,jn_mailbox+11
	mvz.b jn_mailbox+12,%d0
	cmp.l %d0,%d1
	jcs .L261
	move.l #-2147423744,%a0
	moveq #41,%d1
	mvz.b (%a0,%d0.l),%d0
	cmp.l %d0,%d1
	jne .L261
	sub.l %a2,%a2
	lea jn_mailbox+13,%a3
.L264:
	mvz.b jn_mailbox+12,%d0
	move.b (%a2,%a3.l),%d1
	mulu.w #76,%d0
	add.l %a2,%d0
	mvz.w %d0,%d0
	add.l %d0,%d0
	move.l %d0,%a0
	add.l #1092966709,%a0
	clr.b %d0
	move.b %d1,(%a0)
	lsl.l #8,%d1
	move.b %d0,1(%a0)
	and.l #65280,%d1
	pea 10(%a2)
	mvz.b jn_mailbox+12,%d0
	addq.l #1,%a2
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	jsr 1074918394
	lea (12,%sp),%sp
	mov3q.l #6,%d1
	cmp.l %a2,%d1
	jne .L264
.L261:
	move.l (%sp)+,%a2
	move.l (%sp)+,%a3
	rts
	.size	ext_ui_tick, .-ext_ui_tick
	.section	.extg,"a"
	.type	mod_short, @object
	.size	mod_short, 4
mod_short:
	.string	"MOD"
	.type	mod_long, @object
	.size	mod_long, 5
mod_long:
	.string	"Mode"
	.type	mod_label, @object
	.size	mod_label, 21
mod_label:
	.base64	"AAEC"
	.base64	"AAEC"
	.base64	"AAED"
	.base64	"BAUG"
	.base64	"AAEH"
	.base64	"AAgJ"
	.base64	"BAsK"
	.section	.ext8,"a"
	.type	mod_pool, @object
	.size	mod_pool, 44
mod_pool:
	.string	"STA"
	.string	"END"
	.string	"LOP"
	.string	"SLC"
	.string	"POS"
	.string	"SIZ"
	.string	"DNS"
	.string	"SPD"
	.string	"DEC"
	.string	"BRI"
	.string	"CYC"
	.section	.ext3,"a"
	.type	mod_names, @object
	.size	mod_names, 42
mod_names:
	.string	"ONE"
	.zero	2
	.string	"LOOP"
	.zero	1
	.string	"SLICE"
	.string	"GRAIN"
	.string	"STRCH"
	.string	"PLUCK"
	.string	"WAVE"
	.zero	1
	.type	diag_fmt, @object
	.size	diag_fmt, 5
diag_fmt:
	.string	"%c%d"
	.type	diag_key, @object
	.size	diag_key, 8
diag_key:
	.ascii	"TUPKMRSC"
	.globl	ext_diag_max
	.section	.exts,"aw"
	.align	2
	.type	ext_diag_max, @object
	.size	ext_diag_max, 4
ext_diag_max:
	.zero	4
	.section	.extk,"a"
	.type	jn_empty, @object
	.size	jn_empty, 4
jn_empty:
	.string	"---"
	.globl	jn_mailbox
	.section	.extn,"aw"
	.align	2
	.type	jn_mailbox, @object
	.size	jn_mailbox, 1306
jn_mailbox:
	.long	1247104591
	.long	jn_sysex
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.zero	2
	.zero	4
	.byte	0
	.zero	2
	.zero	14
	.zero	2
	.zero	8
	.zero	1260
	.section	.extr,"a"
	.align	2
	.type	fm_look, @object
	.size	fm_look, 16
fm_look:
	.word	410
	.word	40
	.word	40
	.word	410
	.word	410
	.word	100
	.word	101
	.word	410
	.type	fm_fmt_d, @object
	.size	fm_fmt_d, 3
fm_fmt_d:
	.string	"%d"
	.globl	fm_sname
	.type	fm_sname, @object
	.size	fm_sname, 4
fm_sname:
	.string	"6OP"
	.globl	fm_name
	.type	fm_name, @object
	.size	fm_name, 8
fm_name:
	.string	"6-OP FM"
	.type	fm_short, @object
	.size	fm_short, 32
fm_short:
	.string	"PAT"
	.string	"TIM"
	.string	"MOR"
	.string	"DEC"
	.string	"LPG"
	.string	"TUN"
	.string	"LEV"
	.string	"LEN"
	.type	fm_long, @object
	.size	fm_long, 72
fm_long:
	.string	"Voice"
	.zero	3
	.string	"Timbre"
	.zero	2
	.string	"Morph"
	.zero	3
	.string	"Decay"
	.zero	3
	.string	"LPG Col"
	.zero	1
	.string	"Tune"
	.zero	4
	.string	"Level"
	.zero	3
	.string	"Gate"
	.zero	4
	.section	.ext8
	.type	dsp_x_word, @object
	.size	dsp_x_word, 5
dsp_x_word:
	.base64	"DQgJDA4="
	.globl	dsps_s_fld
	.type	dsps_s_fld, @object
	.size	dsps_s_fld, 4
dsps_s_fld:
	.string	"DGN"
	.globl	dsps_n_fld
	.type	dsps_n_fld, @object
	.size	dsps_n_fld, 14
dsps_n_fld:
	.string	"Diag TUPKMRSC"
	.globl	dsps_n_smp
	.type	dsps_n_smp, @object
	.size	dsps_n_smp, 12
dsps_n_smp:
	.string	"Card Sample"
	.globl	dsps_s5
	.type	dsps_s5, @object
	.size	dsps_s5, 4
dsps_s5:
	.string	"MIX"
	.globl	dsps_n5
	.type	dsps_n5, @object
	.size	dsps_n5, 4
dsps_n5:
	.string	"Mix"
	.globl	dsps_p2_title
	.type	dsps_p2_title, @object
	.size	dsps_p2_title, 10
dsps_p2_title:
	.string	"SD SAMPLE"
	.globl	dsps_p2_order
	.align	2
	.type	dsps_p2_order, @object
	.size	dsps_p2_order, 32
dsps_p2_order:
	.long	39
	.long	442
	.long	444
	.long	441
	.long	445
	.long	446
	.long	447
	.long	448
	.align	2
	.type	dsps_rec, @object
	.size	dsps_rec, 16
dsps_rec:
	.word	416
	.word	417
	.word	418
	.word	419
	.word	439
	.word	440
	.word	420
	.word	421
	.globl	dsps_short
	.type	dsps_short, @object
	.size	dsps_short, 5
dsps_short:
	.string	"DSPS"
	.globl	dsps_long
	.type	dsps_long, @object
	.size	dsps_long, 11
dsps_long:
	.string	"DSP SAMPLE"
	.type	dsp_out_names, @object
	.size	dsp_out_names, 12
dsp_out_names:
	.string	"VOICE"
	.string	"MAIN"
	.zero	1
	.globl	dsp_p2_order
	.align	2
	.type	dsp_p2_order, @object
	.size	dsp_p2_order, 32
dsp_p2_order:
	.long	433
	.long	432
	.long	435
	.long	430
	.long	431
	.long	434
	.long	436
	.long	437
	.globl	dsp_s16
	.type	dsp_s16, @object
	.size	dsp_s16, 4
dsp_s16:
	.string	"WID"
	.globl	dsp_s15
	.type	dsp_s15, @object
	.size	dsp_s15, 4
dsp_s15:
	.string	"XP5"
	.globl	dsp_s14
	.type	dsp_s14, @object
	.size	dsp_s14, 4
dsp_s14:
	.string	"XLV"
	.globl	dsp_s13
	.type	dsp_s13, @object
	.size	dsp_s13, 4
dsp_s13:
	.string	"XP4"
	.globl	dsp_s12
	.type	dsp_s12, @object
	.size	dsp_s12, 4
dsp_s12:
	.string	"OUT"
	.globl	dsp_s11
	.type	dsp_s11, @object
	.size	dsp_s11, 3
dsp_s11:
	.string	"FB"
	.globl	dsp_s10
	.type	dsp_s10, @object
	.size	dsp_s10, 4
dsp_s10:
	.string	"XDC"
	.globl	dsp_s9
	.type	dsp_s9, @object
	.size	dsp_s9, 4
dsp_s9:
	.string	"XTN"
	.globl	dsp_n16
	.type	dsp_n16, @object
	.size	dsp_n16, 6
dsp_n16:
	.string	"Width"
	.globl	dsp_n15
	.type	dsp_n15, @object
	.size	dsp_n15, 12
dsp_n15:
	.string	"Exc Param 5"
	.globl	dsp_n14
	.type	dsp_n14, @object
	.size	dsp_n14, 10
dsp_n14:
	.string	"Exc Level"
	.globl	dsp_n13
	.type	dsp_n13, @object
	.size	dsp_n13, 12
dsp_n13:
	.string	"Exc Param 4"
	.globl	dsp_n12
	.type	dsp_n12, @object
	.size	dsp_n12, 7
dsp_n12:
	.string	"Output"
	.globl	dsp_n11
	.type	dsp_n11, @object
	.size	dsp_n11, 9
dsp_n11:
	.string	"Feedback"
	.globl	dsp_n10
	.type	dsp_n10, @object
	.size	dsp_n10, 10
dsp_n10:
	.string	"Exc Decay"
	.globl	dsp_n9
	.type	dsp_n9, @object
	.size	dsp_n9, 9
dsp_n9:
	.string	"Exc Tune"
	.globl	dsp_p2_title
	.type	dsp_p2_title, @object
	.size	dsp_p2_title, 8
dsp_p2_title:
	.string	"EXCITER"
	.globl	ext_proj
	.section	.exts
	.align	2
	.type	ext_proj, @object
	.size	ext_proj, 20
ext_proj:
	.zero	20
	.section	.extk
	.type	jn_fmt, @object
	.size	jn_fmt, 7
jn_fmt:
	.string	"%c%d%d"
	.globl	jn_name
	.type	jn_name, @object
	.size	jn_name, 5
jn_name:
	.string	"JUNO"
	.type	jn_short, @object
	.size	jn_short, 32
jn_short:
	.string	"PAT"
	.string	"CUT"
	.string	"RES"
	.string	"ENV"
	.string	"ATK"
	.string	"DEC"
	.string	"REL"
	.string	"LEN"
	.section	.extm,"a"
	.type	jn_long, @object
	.size	jn_long, 88
jn_long:
	.string	"Patch"
	.zero	5
	.string	"Cutoff"
	.zero	4
	.string	"Resonance"
	.zero	1
	.string	"Env Amount"
	.string	"Attack"
	.zero	4
	.string	"Decay"
	.zero	5
	.string	"Release"
	.zero	3
	.string	"Gate"
	.zero	6
	.section	.exte,"a"
	.type	dd_eng, @object
	.size	dd_eng, 4
dd_eng:
	.string	"ENG"
	.globl	dd_short
	.type	dd_short, @object
	.size	dd_short, 5
dd_short:
	.string	"DDRM"
	.globl	dd_long
	.type	dd_long, @object
	.size	dd_long, 9
dd_long:
	.string	"DIGIDRUM"
	.type	dd_label, @object
	.size	dd_label, 77
dd_label:
	.base64	"AAECGhscHQ=="
	.base64	"AAEFHhscHQ=="
	.base64	"AAECGhscHQ=="
	.base64	"AAEfIBscHQ=="
	.base64	"AAEbDSEiIw=="
	.base64	"AAEJJBscHQ=="
	.base64	"AAElJhscHQ=="
	.base64	"AAEkDRscHQ=="
	.base64	"AAEWEBAQEA=="
	.base64	"AAEXCgcQEA=="
	.base64	"AAEYFwsZEA=="
	.type	dd_pool, @object
	.size	dd_pool, 195
dd_pool:
	.string	"PTCH"
	.string	"DEC"
	.zero	1
	.string	"RAMP"
	.string	"HOLD"
	.string	"TICK"
	.string	"NOIS"
	.string	"DIRT"
	.string	"BUMP"
	.string	"BENV"
	.string	"SNAP"
	.string	"TONE"
	.string	"TUNE"
	.string	"GAP"
	.zero	1
	.string	"HPF"
	.zero	1
	.string	"LPF"
	.zero	1
	.string	"MTAL"
	.string	"-"
	.zero	3
	.string	"RICH"
	.string	"TOP"
	.zero	1
	.string	"TTUN"
	.string	"SIZE"
	.string	"PEAK"
	.string	"DIST"
	.string	"ENH"
	.zero	1
	.string	"DUAL"
	.string	"CLIC"
	.string	"RDEC"
	.string	"MOD"
	.zero	1
	.string	"MFRQ"
	.string	"MDEC"
	.string	"NDEC"
	.string	"CLPS"
	.string	"CDEC"
	.string	"SNAR"
	.string	"SPTC"
	.string	"SDEC"
	.string	"FB"
	.zero	2
	.string	"TREM"
	.string	"TFRQ"
	.section	.extg
	.type	dd_names, @object
	.size	dd_names, 77
dd_names:
	.string	"EFM-BD"
	.string	"EFM-SD"
	.string	"EFM-XT"
	.string	"EFM-CP"
	.string	"EFM-RS"
	.string	"EFM-CB"
	.string	"EFM-HH"
	.string	"EFM-CY"
	.string	"TRX-RS"
	.string	"TRX-CB"
	.string	"TRX-CL"
	.globl	ext_p2_title
	.section	.ext3
	.type	ext_p2_title, @object
	.size	ext_p2_title, 14
ext_p2_title:
	.string	"PLAITS PAGE 2"
	.align	2
	.type	ext_p2_order, @object
	.size	ext_p2_order, 32
ext_p2_order:
	.long	425
	.long	426
	.long	422
	.long	424
	.long	423
	.long	427
	.long	428
	.long	429
	.section	.ext6,"a"
	.type	dsp_input_names, @object
	.size	dsp_input_names, 66
dsp_input_names:
	.string	"INT"
	.zero	2
	.string	"NAT"
	.zero	2
	.string	"NOISE"
	.string	"BD"
	.zero	3
	.string	"SD"
	.zero	3
	.string	"RS/CP"
	.string	"BT"
	.zero	3
	.string	"LT"
	.zero	3
	.string	"MT/HT"
	.string	"CH/OH"
	.string	"CY/CB"
	.type	dsp_engine_names, @object
	.size	dsp_engine_names, 24
dsp_engine_names:
	.string	"MODAL"
	.zero	2
	.string	"STRING"
	.zero	1
	.string	"RESON"
	.zero	2
	.globl	ext_desc_done
	.section	.exts
	.type	ext_desc_done, @object
	.size	ext_desc_done, 1
ext_desc_done:
	.zero	1
	.section	.ext3
	.type	ext_fmt_s, @object
	.size	ext_fmt_s, 3
ext_fmt_s:
	.string	"%s"
	.type	ext_engine_names, @object
	.size	ext_engine_names, 136
ext_engine_names:
	.string	"VA VCF"
	.zero	1
	.string	"PHASDST"
	.string	"WAVTERR"
	.string	"STRMACH"
	.string	"CHIPTUN"
	.string	"VA"
	.zero	5
	.string	"WAVSHAP"
	.string	"2OP FM"
	.zero	1
	.string	"GRANULR"
	.string	"HARMONC"
	.string	"WAVETBL"
	.string	"CHORDS"
	.zero	1
	.string	"SPEECH"
	.zero	1
	.string	"SWARM"
	.zero	2
	.string	"PARTICL"
	.string	"STRING"
	.zero	1
	.string	"MODAL"
	.zero	2
	.globl	ext_state
	.section	.exts
	.align	2
	.type	ext_state, @object
	.size	ext_state, 560
ext_state:
	.zero	560
	.globl	ext_s16
	.section	.ext3
	.type	ext_s16, @object
	.size	ext_s16, 4
ext_s16:
	.string	"VOL"
	.globl	ext_s15
	.type	ext_s15, @object
	.size	ext_s15, 4
ext_s15:
	.string	"GLD"
	.globl	ext_s14
	.type	ext_s14, @object
	.size	ext_s14, 4
ext_s14:
	.string	"VEL"
	.globl	ext_s13
	.type	ext_s13, @object
	.size	ext_s13, 4
ext_s13:
	.string	"MMD"
	.globl	ext_s12
	.type	ext_s12, @object
	.size	ext_s12, 4
ext_s12:
	.string	"TMD"
	.globl	ext_s11
	.type	ext_s11, @object
	.size	ext_s11, 4
ext_s11:
	.string	"AUX"
	.globl	ext_s10
	.type	ext_s10, @object
	.size	ext_s10, 4
ext_s10:
	.string	"FIN"
	.globl	ext_s9
	.type	ext_s9, @object
	.size	ext_s9, 3
ext_s9:
	.string	"FM"
	.globl	ext_n16
	.type	ext_n16, @object
	.size	ext_n16, 7
ext_n16:
	.string	"Volume"
	.globl	ext_n15
	.type	ext_n15, @object
	.size	ext_n15, 6
ext_n15:
	.string	"Glide"
	.globl	ext_n14
	.type	ext_n14, @object
	.size	ext_n14, 9
ext_n14:
	.string	"Velocity"
	.globl	ext_n13
	.type	ext_n13, @object
	.size	ext_n13, 10
ext_n13:
	.string	"Morph Env"
	.globl	ext_n12
	.type	ext_n12, @object
	.size	ext_n12, 11
ext_n12:
	.string	"Timbre Env"
	.globl	ext_n11
	.type	ext_n11, @object
	.size	ext_n11, 8
ext_n11:
	.string	"Aux Mix"
	.globl	ext_n10
	.type	ext_n10, @object
	.size	ext_n10, 10
ext_n10:
	.string	"Fine Tune"
	.globl	ext_n9
	.type	ext_n9, @object
	.size	ext_n9, 10
ext_n9:
	.string	"Pitch Env"
	.globl	ext_s8
	.text
	.type	ext_s8, @object
	.size	ext_s8, 4
ext_s8:
	.string	"LEV"
	.globl	ext_s7
	.type	ext_s7, @object
	.size	ext_s7, 4
ext_s7:
	.string	"TUN"
	.globl	ext_s6
	.type	ext_s6, @object
	.size	ext_s6, 4
ext_s6:
	.string	"LPG"
	.globl	ext_s5
	.type	ext_s5, @object
	.size	ext_s5, 4
ext_s5:
	.string	"DEC"
	.globl	ext_s4
	.type	ext_s4, @object
	.size	ext_s4, 4
ext_s4:
	.string	"MOR"
	.globl	ext_s3
	.type	ext_s3, @object
	.size	ext_s3, 4
ext_s3:
	.string	"TIM"
	.globl	ext_s2
	.type	ext_s2, @object
	.size	ext_s2, 4
ext_s2:
	.string	"HRM"
	.globl	ext_s1
	.type	ext_s1, @object
	.size	ext_s1, 4
ext_s1:
	.string	"ENG"
	.globl	ext_n8
	.type	ext_n8, @object
	.size	ext_n8, 6
ext_n8:
	.string	"Level"
	.globl	ext_n7
	.type	ext_n7, @object
	.size	ext_n7, 5
ext_n7:
	.string	"Tune"
	.globl	ext_n6
	.type	ext_n6, @object
	.size	ext_n6, 11
ext_n6:
	.string	"LPG Colour"
	.globl	ext_n5
	.type	ext_n5, @object
	.size	ext_n5, 6
ext_n5:
	.string	"Decay"
	.globl	ext_n4
	.type	ext_n4, @object
	.size	ext_n4, 6
ext_n4:
	.string	"Morph"
	.globl	ext_n3
	.type	ext_n3, @object
	.size	ext_n3, 7
ext_n3:
	.string	"Timbre"
	.globl	ext_n2
	.type	ext_n2, @object
	.size	ext_n2, 10
ext_n2:
	.string	"Harmonics"
	.globl	ext_n1
	.type	ext_n1, @object
	.size	ext_n1, 7
ext_n1:
	.string	"Engine"
	.globl	ext_short
	.type	ext_short, @object
	.size	ext_short, 5
ext_short:
	.string	"PLTS"
	.globl	ext_long
	.type	ext_long, @object
	.size	ext_long, 7
ext_long:
	.string	"PLAITS"
	.globl	dsp_s6
	.section	.ext6
	.type	dsp_s6, @object
	.size	dsp_s6, 4
dsp_s6:
	.string	"EXC"
	.globl	dsp_s5
	.type	dsp_s5, @object
	.size	dsp_s5, 4
dsp_s5:
	.string	"INP"
	.globl	dsp_s4
	.type	dsp_s4, @object
	.size	dsp_s4, 4
dsp_s4:
	.string	"DMP"
	.globl	dsp_s3
	.type	dsp_s3, @object
	.size	dsp_s3, 4
dsp_s3:
	.string	"BRI"
	.globl	dsp_s2
	.type	dsp_s2, @object
	.size	dsp_s2, 4
dsp_s2:
	.string	"STR"
	.globl	dsp_n6
	.type	dsp_n6, @object
	.size	dsp_n6, 8
dsp_n6:
	.string	"Exciter"
	.globl	dsp_n5
	.type	dsp_n5, @object
	.size	dsp_n5, 6
dsp_n5:
	.string	"Input"
	.globl	dsp_n4
	.type	dsp_n4, @object
	.size	dsp_n4, 8
dsp_n4:
	.string	"Damping"
	.globl	dsp_n3
	.type	dsp_n3, @object
	.size	dsp_n3, 11
dsp_n3:
	.string	"Brightness"
	.globl	dsp_n2
	.type	dsp_n2, @object
	.size	dsp_n2, 10
dsp_n2:
	.string	"Structure"
	.globl	dsp_short
	.type	dsp_short, @object
	.size	dsp_short, 4
dsp_short:
	.string	"DSP"
	.globl	dsp_long
	.type	dsp_long, @object
	.size	dsp_long, 8
dsp_long:
	.string	"DAISYSP"
	.ident	"GCC: (GNU) 16.2.0"
	.endif
