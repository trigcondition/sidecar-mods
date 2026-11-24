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
.set us_off_tgen, 40
.globl us_off_layer
.set us_off_layer, 53
.globl us_off_ch
.set us_off_ch, 63
.globl us_off_wb
.set us_off_wb, 36
.globl us_wb_pslot
.set us_wb_pslot, 3
.globl us_wb_pgen
.set us_wb_pgen, 22
.globl us_wb_size
.set us_wb_size, 28
.globl us_off_en
.set us_off_en, 500

	  .section .us1,"ax"
  .globl ext_mix_det
ext_mix_det:
  jsr ext_smute_apply
  jsr 0x4010ea2c
  jmp 0x40121234

	  .section .us1,"ax"
  .globl ext_sr_mac
ext_sr_mac:
  movel %sp@(88),%d1
  mvzb ext_smute,%d0
  btst %d1,%d0
  bnes 1f
  movel %a3@(12),%d5
  movel %d5,%d2
  jmp 0x4011cbb4
1:jmp 0x4011cc56
  .globl ext_sr_filt
ext_sr_filt:
  movel %sp@(88),%d1
  mvzb ext_smute,%d0
  btst %d1,%d0
  bnes 2f
  lea %a3@(44),%a0
  movel %a0,%sp@-
  jmp 0x4011cce0
2:clrb %a3@(40)
  lea %a3@(44),%a0
  moveq #11,%d0
3:clrl %a0@+
  subql #1,%d0
  bpls 3b
  jmp 0x4011ceee

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
	.globl	us_snd_init
us_snd_init:
	clr.b	109(%a2)
	clr.b	110(%a2)
	clr.b	111(%a2)
	lea	0x40007028,%a4
	jmp	0x400122ec
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
	mvz.b	us+64,%d0
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
	mov3q.l #2,%d1
	movem.l #7420,(%sp)
	move.l 44(%sp),%a3
	move.l 48(%sp),%d2
	move.l us+32,%a2
	mvz.b 6(%a3),%d0
	move.l %d0,%d4
	add.l #-64,%d4
	cmp.l %d4,%d1
	jcc .L76
	tst.l %a2
	jeq .L75
	subq.l #1,%d0
	mov3q.l #4,%d3
	cmp.l %d0,%d3
	jcs .L75
.L89:
	move.b 3(%a2),%d5
	mvz.b %d5,%d1
	cmp.l #255,%d1
	jeq .L75
	mvz.b 8(%a3),%d3
	moveq #127,%d7
	cmp.l %d3,%d7
	jeq .L75
	move.b 7(%a3),%d1
	tst.l %d3
	jne .L79
	moveq #40,%d3
	cmp.l %d2,%d3
	jge .L75
	move.b 12(%a3),%d3
	mov3q.l #4,%d5
	subq.l #1,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcs .L75
	addq.l #1,%d0
	move.b %d0,(%a2)
	move.b %d1,1(%a2)
	moveq #1,%d7
	lea us_text_in,%a4
	move.b 12(%a3),2(%a2)
	move.b %d1,4(%a2)
	move.b %d7,3(%a2)
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
	moveq #42,%d0
	cmp.l %d2,%d0
	jge .L91
	mvz.b 40(%a3),%d0
	move.b 41(%a3),%d1
	moveq #127,%d2
	lsl.l #7,%d0
	and.l %d2,%d1
	and.l #16256,%d0
	or.l %d1,%d0
.L80:
	move.w %d0,38(%a2)
	mov3q.l #2,%d3
	cmp.l %d4,%d3
	jcs .L81
	mvz.b 6(%a3),%d0
	add.l #-64,%d0
	move.w %d0,38(%a2)
.L81:
	move.l %a2,%d0
	add.l #488,%d0
	lea (40,%a2),%a0
.L82:
	clr.b (%a0)
	lea (28,%a0),%a0
	cmp.l %d0,%a0
	jne .L82
.L83:
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
.L91:
	clr.w %d0
	jra .L80
.L79:
	mvz.b (%a2),%d4
	addq.l #1,%d0
	cmp.l %d4,%d0
	jne .L75
	mvz.b %d1,%d1
	mvz.b 1(%a2),%d0
	cmp.l %d1,%d0
	jne .L75
	btst #0,%d5
	jeq .L75
	mvz.b 2(%a2),%d0
	cmp.l %d3,%d0
	jls .L75
	moveq #10,%d4
	cmp.l %d2,%d4
	jge .L75
	move.l %d2,%d0
	moveq #24,%d5
	add.l #-10,%d0
	rems.l %d5,%d1:%d0
	tst.l %d1
	jne .L75
	subq.l #1,%d2
	move.l %d2,36(%sp)
	moveq #32,%d4
	lea (9,%a3),%a3
	lea us_text_in,%a4
.L84:
	cmp.l 36(%sp),%d4
	jlt .L88
	mov3q.l #1,%d0
	move.b 3(%a2),%d1
	lsl.l %d3,%d0
	or.l %d1,%d0
	move.b %d0,3(%a2)
	jra .L83
.L88:
	move.b (%a3),%d1
	move.l %d1,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	lsr.l #4,%d0
	jne .L85
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
	jls .L86
	move.b %d5,%d1
.L86:
	move.b %d1,45(%a0)
	lea (%a2,%d0.l),%a0
	moveq #36,%d5
	move.b 6(%a3),46(%a0)
	move.b 7(%a3),%d0
	mvz.b %d0,%d1
	cmp.l %d1,%d5
	jcc .L87
	moveq #36,%d0
.L87:
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
.L85:
	add.l #24,%d4
	lea (24,%a3),%a3
	jra .L84
.L76:
	tst.l %a2
	jeq .L75
	mov3q.l #7,%d0
	jra .L89
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
	jge .L110
	move.b 7(%a2),%d3
	move.b 6(%a2),%d0
	moveq #15,%d4
	mvz.b %d3,%d1
	mvz.b %d0,%d2
	move.l %d1,%a0
	move.l %d2,%a1
	subq.l #1,%a1
	move.b 8(%a2),%d1
	cmp.l %a0,%d4
	jlt .L112
	mov3q.l #4,%d6
	cmp.l %a1,%d6
	jcs .L113
	lea us,%a3
	move.l (%a3,%a1.l*4),%a3
.L114:
	tst.l %a3
	jeq .L110
	mvz.b %d1,%d4
	mvz.b (%a3),%d0
	cmp.l %d4,%d0
	jne .L110
	clr.l %d2
	lea (484,%a3),%a1
.L115:
	mvz.b (%a1,%d2.l),%d0
	cmp.l %a0,%d0
	jeq .L116
	addq.l #1,%d2
	moveq #8,%d1
	cmp.l %d2,%d1
	jne .L115
.L116:
	move.b 9(%a2),%d0
	moveq #8,%d6
	cmp.l %d2,%d6
	jne .L118
	tst.b %d0
	jeq .L110
	clr.l %d2
.L119:
	mvz.b (%a1,%d2.l),%d0
	cmp.l #255,%d0
	jne .L120
.L121:
	move.w %d2,%d0
	pea 288.w
	moveq #36,%d6
	mulu.w #288,%d0
	add.l #500,%d0
	pea (%a3,%d0.l)
	jsr us_zero
	move.b 10(%a2),%d0
	addq.l #8,%sp
	lea (%a3,%d2.l),%a0
	mvz.b %d0,%d1
	cmp.l %d1,%d6
	jcc .L123
	moveq #36,%d0
.L123:
	move.b %d0,492(%a0)
	move.b %d3,484(%a0)
	jra .L122
.L113:
	add.l #-64,%d2
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	jcs .L110
	move.l us+28,%a3
	jra .L114
.L120:
	addq.l #1,%d2
	moveq #8,%d0
	cmp.l %d2,%d0
	jne .L119
.L110:
	movem.l (%sp),#3196
	lea (28,%sp),%sp
	rts
.L118:
	tst.b %d0
	jne .L121
.L122:
	move.l %d5,%d1
	moveq #12,%d3
	move.w %d2,%d5
	subq.l #1,%d1
	lea (11,%a2),%a2
	mulu.w #36,%d5
.L124:
	move.l %d3,%d0
	add.l #12,%d0
	cmp.l %d1,%d0
	jlt .L129
	mvz.b (%a3),%d0
	cmp.l %d4,%d0
	jeq .L110
	st %d0
	add.l %d2,%a3
	move.b %d0,484(%a3)
	jra .L110
.L129:
	mvz.b (%a2),%d0
	moveq #35,%d6
	cmp.l %d0,%d6
	jcs .L125
	add.l %d5,%d0
	mvz.w %d0,%d0
	sub.l %a1,%a1
	lsl.l #3,%d0
	move.l %d0,%a0
	lea (500,%a0),%a0
	add.l %a3,%a0
.L126:
	move.b 1(%a2,%a1.l),%d0
	jeq .L127
	move.b %d0,(%a0,%a1.l)
	addq.l #1,%a1
	mov3q.l #7,%d0
	cmp.l %a1,%d0
	jne .L126
.L127:
	clr.b %d6
	move.b %d6,(%a0,%a1.l)
.L125:
	add.l #14,%d3
	lea (14,%a2),%a2
	jra .L124
.L112:
	moveq #33,%d2
	cmp.l %a0,%d2
	jeq .L141
	moveq #32,%d4
	cmp.l %a0,%d4
	jne .L110
	mov3q.l #4,%d6
	cmp.l %a1,%d6
	jcs .L110
	add.l #16,%d0
	tst.b %d0
	jeq .L110
.L130:
	tst.b 9(%a2)
	jeq .L131
	move.w #127,%a0
	lea jn_mailbox+37,%a1
.L132:
	clr.b (%a1)
	subq.l #1,%a0
	lea (10,%a1),%a1
	tst.l %a0
	jne .L132
	move.b 10(%a2),%d2
	jpl .L133
	moveq #127,%d2
.L133:
	move.b %d0,jn_mailbox+19
	moveq #1,%d0
	move.b %d2,jn_mailbox+9
	move.b %d1,jn_mailbox+20
	move.b %d0,jn_mailbox+8
.L134:
	move.l %d5,%d1
	moveq #12,%d2
	subq.l #1,%d1
	lea (11,%a2),%a2
.L135:
	move.l %d2,%d0
	add.l #12,%d0
	cmp.l %d1,%d0
	jge .L110
	move.b (%a2),%d0
	moveq #126,%d4
	mvz.b %d0,%d3
	cmp.l %d3,%d4
	jcs .L136
	ext.w %d0
	sub.l %a1,%a1
	mulu.w #10,%d0
	move.l %d0,%a0
	add.l #jn_mailbox+37,%a0
.L137:
	move.b 1(%a2,%a1.l),%d0
	jeq .L138
	move.b %d0,(%a0,%a1.l)
	addq.l #1,%a1
	moveq #9,%d6
	cmp.l %a1,%d6
	jne .L137
.L138:
	clr.b %d0
	move.b %d0,(%a0,%a1.l)
.L136:
	add.l #14,%d2
	lea (14,%a2),%a2
	jra .L135
.L141:
	moveq #32,%d0
	jra .L130
.L131:
	mvz.b %d0,%d0
	mvz.b jn_mailbox+19,%d2
	cmp.l %d0,%d2
	jne .L110
	mvz.b %d1,%d1
	mvz.b jn_mailbox+20,%d0
	cmp.l %d1,%d0
	jne .L110
	jra .L134
	.size	us_list_in, .-us_list_in
	.align	2
	.type	us_knobs_in, @function
us_knobs_in:
	move.l us+36,%a0
	lea (-24,%sp),%sp
	movem.l #1148,(%sp)
	move.l 28(%sp),%a1
	tst.l %a0
	jeq .L167
	move.b 6(%a1),%d0
	mov3q.l #7,%d1
	moveq #11,%d2
	and.l %d1,%d0
	move.l #1076432344,%d1
	move.l %d0,%a2
	move.b (%a2,%d1.l),%d0
	mvz.b %d0,%d1
	cmp.l %d1,%d2
	jcs .L167
	move.b 7(%a1),%d3
	mov3q.l #4,%d4
	move.l %d3,%d1
	subq.l #1,%d1
	mvz.b %d1,%d1
	cmp.l %d1,%d4
	jcs .L167
	mvz.b 8(%a1),%d2
	moveq #16,%d6
	cmp.l %d2,%d6
	jlt .L167
	move.l %d2,%d1
	addq.l #5,%d1
	add.l %d1,%d1
	cmp.l 32(%sp),%d1
	jgt .L167
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
.L169:
	cmp.l %d3,%d2
	jgt .L170
	move.w %d1,4(%a0)
	move.b 1(%a0),%d0
	addq.l #1,%d0
	move.b %d0,1(%a0)
.L167:
	movem.l (%sp),#1148
	lea (24,%sp),%sp
	rts
.L170:
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
	jra .L169
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
	jge .L174
	moveq #15,%d2
	cmp.l %d1,%d2
	jge .L176
	move.b 14(%a0),%d0
	btst #0,%d0
	jeq .L176
	tst.b ext_dcap.l
	jeq .L177
	btst #1,%d0
	jeq .L178
.L177:
	move.b ext_dgen,%d0
	addq.l #1,%d0
	move.b %d0,ext_dgen
.L178:
	moveq #1,%d0
	move.b %d0,ext_dcap
.L179:
	clr.l %d0
	lea us+40,%a1
.L180:
	lea 6(%a0,%d0.l),%a2
	mov3q.l #5,%d2
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d2
	jne .L180
	moveq #1,%d0
	lea (11,%a0),%a1
	moveq #14,%d2
	move.b (%a1),us+45
	move.b %d0,us+46
	cmp.l %d1,%d2
	jge .L174
	move.b 12(%a0),%d0
	mov3q.l #4,%d1
	subq.l #1,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jcs .L174
	lea (13,%a0),%a1
	move.b (%a1),us+59
	lea (12,%a0),%a0
	move.b (%a0),us+58
.L174:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L176:
	clr.b %d2
	move.b %d2,ext_dcap
	jra .L179
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
	jeq .L192
	tst.b (%a0)
	jne .L193
.L192:
	move.l %d0,%d2
	addq.l #1,%d2
	move.l %d2,-(%sp)
	pea us_fmt_user
	move.l %a1,-(%sp)
	jsr 1074365954
	move.l %d2,-(%sp)
	pea us_fmt_u
.L225:
	move.l %a2,-(%sp)
	jsr 1074365954
	lea (24,%sp),%sp
.L191:
	movem.l (%sp),#3076
	lea (12,%sp),%sp
	rts
.L193:
	move.b 1(%a0),%d1
	jne .L195
	move.l %d0,%d2
	addq.l #1,%d2
	move.l %d2,-(%sp)
	pea us_fmt_empty
	move.l %a1,-(%sp)
	jsr 1074365954
	move.l %d2,-(%sp)
	pea us_fmt_uempty
	jra .L225
.L195:
	mvz.b %d1,%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L196
	mvz.b us+65,%d1
	addq.l #1,%d0
	cmp.l %d1,%d0
	jne .L209
.L196:
	move.b #33,(%a2)
	move.b #33,(%a1)
	clr.l %d0
.L203:
	move.b 4(%a0,%d0.l),%d1
	jeq .L204
	addq.l #1,%d0
	move.b %d1,(%a1,%d0.l)
	moveq #10,%d1
	cmp.l %d0,%d1
	jne .L203
.L204:
	clr.b %d2
	move.b %d2,1(%a1,%d0.l)
	clr.l %d0
.L206:
	move.b 15(%a0,%d0.l),%d1
	jeq .L207
	addq.l #1,%d0
	move.b %d1,(%a2,%d0.l)
	mov3q.l #3,%d1
	cmp.l %d0,%d1
	jne .L206
.L207:
	clr.b %d2
	move.b %d2,1(%a2,%d0.l)
	jra .L191
.L209:
	clr.l %d0
.L197:
	move.b 4(%a0,%d0.l),%d1
	jeq .L198
	move.b %d1,(%a1,%d0.l)
	addq.l #1,%d0
	moveq #10,%d1
	cmp.l %d0,%d1
	jne .L197
.L198:
	clr.b %d2
	move.b %d2,(%a1,%d0.l)
	clr.l %d0
.L200:
	move.b 15(%a0,%d0.l),%d1
	jeq .L201
	move.b %d1,(%a2,%d0.l)
	addq.l #1,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L200
.L201:
	clr.b %d2
	move.b %d2,(%a2,%d0.l)
	jra .L191
	.size	us_names, .-us_names
	.section	.us2
	.align	2
	.type	us_has_enum, @function
us_has_enum:
	move.l 4(%sp),%d0
	move.l %d0,%a0
	lea (484,%a0),%a0
	add.l #492,%d0
.L228:
	mvz.b (%a0),%d1
	cmp.l 8(%sp),%d1
	jeq .L229
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L228
	clr.l %d0
.L226:
	rts
.L229:
	mov3q.l #1,%d0
	jra .L226
	.size	us_has_enum, .-us_has_enum
	.section	.us6
	.align	2
	.type	us_kit_sound, @function
us_kit_sound:
	move.l %d3,-(%sp)
	move.l -2147457096,%a0
	move.l %d2,-(%sp)
	mvz.b us+64,%d1
	mvz.b 23(%sp),%d0
	cmp.l %d1,%d0
	jne .L236
	move.l 12(%sp),%a1
	add.l #-2147423744,%a1
	mvz.b (%a1),%d1
	move.l 16(%sp),%d0
	add.l #35,%d0
	cmp.l %d1,%d0
	jeq .L233
.L236:
	clr.l %d0
	jra .L231
.L233:
	move.l -2147418996,%d0
	cmp.l %d0,%a0
	jne .L236
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
	jne .L236
.L231:
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
| 2259 "ext.c" 1
	move.w %sr,%d2
	move.l %d2,%d1
	ori.l #0x0700,%d1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
	mvz.b us+64,%d0
	move.l %d0,-(%sp)
	move.l 16(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	jsr us_kit_sound
	lea (12,%sp),%sp
	move.l %d0,%a0
	tst.l %d0
	jeq .L238
	move.b 90(%a0),%d0
	moveq #-64,%d1
	and.l %d1,%d0
	clr.w %d1
	move.b %d0,90(%a0)
	clr.b %d0
	move.b %d0,91(%a0)
	move.l 8(%sp),%d0
	lea us_tag,%a0
	move.w %d1,(%a0,%d0.l*2)
	mvz.w #162,%d1
	muls.l %d1,%d0
	move.l %d0,%a0
	add.l #1081497997,%a0
	clr.b (%a0)
	addq.l #1,%a0
	clr.b (%a0)
.L238:
#APP
| 2267 "ext.c" 1
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
	jcs .L242
	move.l #-2147423744,%a0
	move.b (%a0,%d0.l),%d1
	mvz.b %d1,%d2
	move.l %d2,%a0
	mov3q.l #4,%d2
	lea (-35,%a0),%a0
	cmp.l %a0,%d2
	jcs .L244
.L246:
	move.l us+36,%a0
	tst.l %a0
	jne .L250
.L242:
	move.l (%sp)+,%d2
	rts
.L244:
	mov3q.l #7,%d2
	cmp.l %a0,%d2
	jne .L242
	jra .L246
.L250:
	moveq #28,%d2
	add.l #-34,%d1
	muls.l %d2,%d0
	move.l #1100784300,%a1
	add.l %d0,%a0
	clr.b %d0
	move.b %d1,3(%a0)
	move.b %d0,22(%a0)
	move.l (%a1),24(%a0)
	jra .L242
	.size	us_pend, .-us_pend
	.align	2
	.type	us_choose, @function
us_choose:
	move.l %d3,-(%sp)
	moveq #11,%d0
	move.l %d2,-(%sp)
	move.l 12(%sp),%d2
	cmp.l %d2,%d0
	jcs .L255
	move.l #-2147423744,%a0
	mvz.b (%a0,%d2.l),%d3
	add.l #-35,%d3
.L252:
	move.l %d2,-(%sp)
	jsr us_pend
	addq.l #4,%sp
	mov3q.l #4,%d0
	cmp.l %d3,%d0
	jcs .L253
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	jsr us_untag
	addq.l #8,%sp
.L251:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L255:
	mov3q.l #-1,%d3
	jra .L252
.L253:
	subq.l #7,%d3
	tst.l %d3
	jne .L251
	move.l us+36,%a0
	tst.l %a0
	jeq .L251
	moveq #28,%d0
	muls.l %d0,%d2
	clr.b %d0
	move.b %d0,23(%a0,%d2.l)
	jra .L251
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
	jeq .L260
	tst.l %d0
	jeq .L260
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
.L260:
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
.L270:
	mvs.b (%a1,%d0.l),%d2
	move.b (%a0,%d0.l),%d1
	mvs.b %d1,%d3
	cmp.l %d3,%d2
	jne .L272
	tst.b %d1
	jne .L269
.L271:
	mov3q.l #1,%d0
.L267:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L269:
	addq.l #1,%d0
	moveq #9,%d1
	cmp.l %d0,%d1
	jne .L270
	jra .L271
.L272:
	clr.l %d0
	jra .L267
	.size	us_same, .-us_same
	.text
	.align	2
	.type	md_old, @function
md_old:
	moveq #127,%d0
	and.l -2147457096,%d0
	move.l %d2,-(%sp)
	moveq #11,%d2
	mvz.b 1093765506,%d1
	mulu.w #2531,%d0
	cmp.l %d1,%d2
	jcs .L276
	mvz.b 1093765506,%d1
	mulu.w #152,%d1
.L275:
	move.l %d0,%a0
	add.l #1092966689,%a0
	add.l %d1,%a0
	move.b 90(%a0),%d0
	mvz.b 91(%a0),%d1
	move.l (%sp)+,%d2
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #16383,%d0
	cmp.l #8781,%d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	rts
.L276:
	clr.l %d1
	jra .L275
	.size	md_old, .-md_old
	.section	.us4
	.align	2
	.type	md_list_open, @function
md_list_open:
	move.l %a2,-(%sp)
	moveq #32,%d0
	move.l %d2,-(%sp)
	move.l 12(%sp),%a1
	lea (20,%a1),%a1
	move.l 8(%a1),%a0
.L278:
	cmp.l %a1,%a0
	jeq .L282
	move.l 8(%a0),%d1
	tst.l %d1
	jeq .L279
	move.l #1075731444,%d2
	move.l %d1,%a2
	cmp.l (%a2),%d2
	jeq .L283
.L279:
	move.l (%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L278
.L282:
	clr.l %d0
.L277:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L283:
	mov3q.l #1,%d0
	jra .L277
	.size	md_list_open, .-md_list_open
	.section	.us1
	.align	2
	.type	us_slot_records, @function
us_slot_records:
	lea (-16,%sp),%sp
	movem.l #7172,(%sp)
	move.l 20(%sp),%d2
	move.l %d2,%d0
	lsl.l #3,%d0
	sub.l %a2,%a2
	lea us_record,%a4
	move.l %d0,%a3
	lea (334,%a3),%a3
.L289:
	pea us_text
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	pea (%a3,%a2.l)
	jsr (%a4)
	addq.l #1,%a2
	lea (16,%sp),%sp
	moveq #8,%d0
	cmp.l %a2,%d0
	jne .L289
	move.l %d2,20(%sp)
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	jra us_src_table
	.size	us_slot_records, .-us_slot_records
	.section	.us2
	.align	2
	.type	us_commit, @function
us_commit:
	lea (-28,%sp),%sp
	mov3q.l #4,%d0
	movem.l #15388,(%sp)
	move.l us+32,%a3
	mvz.b (%a3),%d4
	move.l %d4,%d3
	subq.l #1,%d3
	cmp.l %d3,%d0
	jcc .L292
	mov3q.l #7,%d1
	cmp.l %d3,%d1
	jne .L293
.L292:
	lea us,%a4
	move.l (%a4,%d3.l*4),%a2
	tst.l %a2
	jeq .L293
	mov3q.l #7,%d0
	cmp.l %d3,%d0
	jne .L294
	tst.b (%a2)
	jne .L295
.L294:
	clr.l %d2
.L296:
	pea 36.w
	pea 4(%a3)
	move.l %a2,-(%sp)
	lea us_copy,%a5
	jsr (%a5)
	pea 448.w
	pea 40(%a3)
	pea 36(%a2)
	jsr (%a5)
	lea (24,%sp),%sp
	tst.l %d2
	jne .L297
	mov3q.l #-1,484(%a2)
	mov3q.l #-1,488(%a2)
.L297:
	mov3q.l #7,%d1
	cmp.l %d3,%d1
	jeq .L298
	mov3q.l #1,%d1
	mvz.b 1(%a2),%d0
	cmp.l %d0,%d1
	jne .L302
	move.b 2(%a2),%d0
	not.l %d0
	and.l %d1,%d0
.L299:
	move.b %d0,53(%a4,%d3.l)
	move.l %d3,-(%sp)
	jsr us_names
	clr.b %d0
	addq.l #4,%sp
	move.b %d0,47(%a4,%d3.l)
.L300:
	move.l %d3,-(%sp)
	jsr us_slot_records
	addq.l #4,%sp
	jra .L301
.L295:
	move.w 34(%a2),%d2
	move.w 38(%a3),%d0
	eor.l %d0,%d2
	tst.w %d2
	seq %d2
	mvs.b %d2,%d2
	neg.l %d2
	jra .L296
.L302:
	clr.l %d0
	jra .L299
.L298:
	mvz.b md+4,%d0
	subq.l #2,%d0
	tst.l %d0
	jeq .L300
.L301:
	mvz.b us+60,%d0
	cmp.l %d4,%d0
	jne .L293
	clr.b %d0
	move.b %d0,us+60
.L293:
	clr.b %d1
	move.b %d1,3(%a3)
	movem.l (%sp),#15388
	lea (28,%sp),%sp
	rts
	.size	us_commit, .-us_commit
	.align	2
	.type	us_init, @function
us_init:
	lea (-20,%sp),%sp
	moveq #1,%d0
	movem.l #15364,(%sp)
	pea 488.w
	move.b %d0,us+62
	jsr 1074276820
	addq.l #4,%sp
	move.l %d0,%d2
	tst.l %d0
	jeq .L307
	pea 488.w
	move.l %d0,-(%sp)
	jsr us_zero
	addq.l #8,%sp
.L307:
	move.l %d2,us+32
	pea 336.w
	jsr 1074276820
	addq.l #4,%sp
	move.l %d0,%d2
	tst.l %d0
	jeq .L308
	pea 336.w
	move.l %d0,-(%sp)
	jsr us_zero
	addq.l #8,%sp
.L308:
	move.l %d2,us+36
	move.l #1075595352,%a0
	lea md_rec,%a1
.L309:
	move.l (%a0),(%a1)
	move.l 4(%a0),4(%a1)
	lea (52,%a0),%a0
	move.l -44(%a0),8(%a1)
	lea (12,%a1),%a1
	cmp.l #1075595768,%a0
	jne .L309
	clr.l %d2
	lea us_zero,%a5
	lea us,%a3
	lea us_slot_records,%a4
.L313:
	pea 2804.w
	jsr 1074276820
	addq.l #4,%sp
	move.l %d0,%a2
	tst.l %d0
	jeq .L310
	pea 2804.w
	move.l %d0,-(%sp)
	jsr (%a5)
	mov3q.l #-1,484(%a2)
	mov3q.l #-1,488(%a2)
	addq.l #8,%sp
.L310:
	move.l %a2,(%a3,%d2.l*4)
	move.l %d2,-(%sp)
	jsr (%a4)
	addq.l #4,%sp
	mov3q.l #4,%d0
	cmp.l %d2,%d0
	jeq .L314
	addq.l #1,%d2
	moveq #8,%d0
	cmp.l %d2,%d0
	jne .L313
	movem.l (%sp),#15364
	lea (20,%sp),%sp
	rts
.L314:
	mov3q.l #7,%d2
	jra .L313
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
	jcs .L326
	mov3q.l #7,%d1
	and.l %d0,%d1
	asr.l #3,%d0
	move.l %d1,(%a1)
.L325:
	move.l (%sp)+,%d2
	rts
.L326:
	move.l %d1,%d0
	mov3q.l #7,%d2
	add.l #-390,%d0
	cmp.l %d0,%d2
	jcs .L328
	move.l %d0,(%a1)
	mov3q.l #7,%d0
	jra .L325
.L328:
	lea us_p2rec,%a0
	clr.l %d0
.L331:
	mvs.w (%a0),%d2
	cmp.l %d1,%d2
	jne .L329
	addq.l #8,%d0
	move.l %d0,(%a1)
	moveq #11,%d1
	mvz.b 1093765506,%d0
	cmp.l %d0,%d1
	jcs .L332
	mvz.b 1093765506,%d0
	move.l %d0,%a0
	add.l #-2147423744,%a0
.L330:
	mvz.b (%a0),%d0
	mov3q.l #4,%d2
	add.l #-35,%d0
	cmp.l %d0,%d2
	jcc .L325
	mov3q.l #7,%d1
	cmp.l %d0,%d1
	jeq .L325
.L337:
	mov3q.l #-1,%d0
	jra .L325
.L332:
	move.l #-2147423744,%a0
	jra .L330
.L329:
	addq.l #2,%a0
	addq.l #1,%d0
	moveq #8,%d2
	cmp.l %d0,%d2
	jne .L331
	jra .L337
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
	jne .L339
	tst.l 1073849316
	jeq .L340
	move.l 1073849316,%a1
	move.l %d2,8(%fp)
	move.l -16(%fp),%d2
	move.l -12(%fp),%d3
	unlk %fp
	jmp (%a1)
.L339:
	lea us,%a0
	move.l (%a0,%d0.l*4),%a0
	tst.l %a0
	jeq .L340
	move.b (%a0),%d1
	jeq .L340
	move.l -4(%fp),%d2
	moveq #28,%d3
	muls.l %d2,%d3
	lea (%a0,%d3.l),%a1
	tst.b 36(%a1)
	jeq .L340
	mvz.b 38(%a1),%d3
	move.l %d3,%a1
	mov3q.l #2,%d3
	cmp.l %a1,%d3
	jne .L364
	clr.l %d0
	lea (484,%a0),%a1
.L341:
	mvz.b (%a1,%d0.l),%d1
	cmp.l %d2,%d1
	jne .L343
	lea (%a0,%d0.l),%a0
	mov3q.l #1,%d1
	mvz.b 492(%a0),%d0
	cmp.l %d0,%d1
	jcc .L340
	bset #8,%d0
.L338:
	move.l -16(%fp),%d2
	move.l -12(%fp),%d3
	unlk %fp
	rts
.L343:
	addq.l #1,%d0
	moveq #8,%d1
	cmp.l %d0,%d1
	jne .L341
.L340:
	clr.l %d0
	jra .L338
.L364:
	mov3q.l #6,%d2
	cmp.l %a1,%d2
	jne .L346
	tst.l -8(%fp)
	jne .L347
.L351:
	mvz.w #896,%d0
	jra .L338
.L347:
	mvz.b jn_mailbox+19,%d2
	add.l #17,%d0
	cmp.l %d2,%d0
	jne .L351
	mvz.b %d1,%d1
	mvz.b jn_mailbox+20,%d0
	cmp.l %d1,%d0
	jne .L351
	move.l -8(%fp),%d0
	bset #9,%d0
	jra .L338
.L346:
	mov3q.l #7,%d3
	cmp.l %a1,%d3
	jne .L340
	jra .L351
	.size	ext_steps_us, .-ext_steps_us
	.section	.exto
	.align	2
	.globl	usb_free
	.type	usb_free, @function
usb_free:
	move.l 4(%sp),%d0
	move.l 1094562704,%a0
.L367:
	tst.l %d0
	jgt .L369
	mov3q.l #1,%d0
.L366:
	rts
.L369:
	tst.l %a0
	jeq .L370
	move.l 52(%a0),%a0
	subq.l #1,%d0
	jra .L367
.L370:
	clr.l %d0
	jra .L366
	.size	usb_free, .-usb_free
	.section	.ext9,"ax",@progbits
	.align	2
	.type	ext_try_send, @function
ext_try_send:
	subq.l #4,%sp
	tst.l 1123449384
	jeq .L372
.L374:
	clr.l %d0
.L371:
	addq.l #4,%sp
	rts
.L372:
	tst.l 1094562372
	jne .L374
	mvz.w #3800,%d0
	cmp.l 1094562392.l,%d0
	jcs .L374
	mov3q.l #2,-(%sp)
	jsr usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L371
	move.l 8(%sp),-(%sp)
	move.l 16(%sp),-(%sp)
	move.l %d0,8(%sp)
	jsr 1073752544
	addq.l #8,%sp
	move.l (%sp),%d0
	jra .L371
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
	jne .L379
	move.l #1081903571,%a0
	mov3q.l #1,%a1
.L381:
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
	jne .L381
	tst.l %d2
	jeq .L382
	and.l #16383,%d1
	tst.l %d1
	jne .L379
.L382:
	moveq #16,%d0
	move.l #-260222380,%a1
	mov3q.l #5,%a0
	move.l %a1,-22(%fp)
	move.l #1081903566,%a1
	move.b %d0,-18(%fp)
.L383:
	move.b (%a0,%a1.l),%d0
	jeq .L384
	moveq #127,%d1
	addq.l #1,%a0
	and.l %d1,%d0
	moveq #20,%d2
	move.b %d0,-23(%a0,%fp.l)
	cmp.l %a0,%d2
	jne .L383
.L384:
	moveq #-9,%d0
	move.b %d0,-22(%fp,%a0.l)
	pea 1(%a0)
	pea -22(%fp)
	jsr ext_try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L379
	move.l #1081903571,%a0
.L386:
	lea ext_proj-1081903567,%a1
	move.b (%a0),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L386
.L379:
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
	jge .L399
	clr.l %d2
.L399:
	mov3q.l #6,%d0
	cmp.l %d3,%d0
	jcs .L400
	move.w .L402(%pc,%d3.l*2),%d0
	ext.l %d0
	jmp %pc@(2,%d0:l)
	.balignw 2,0x284c
	.swbeg	&7
.L402:
	.word .L408-.L402
	.word .L411-.L402
	.word .L406-.L402
	.word .L405-.L402
	.word .L404-.L402
	.word .L403-.L402
	.word .L401-.L402
.L408:
	move.l ext_diag_max,%d2
.L401:
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
.L411:
	clr.l %d4
.L407:
	move.l %d4,%d2
	addq.l #1,%d4
	move.l %d4,-(%sp)
	jsr usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L401
	moveq #40,%d0
	cmp.l %d4,%d0
	jne .L407
	moveq #40,%d2
	jra .L401
.L406:
	move.l 1079807120,%d2
	jra .L401
.L405:
	moveq #127,%d0
	and.l -2147457096,%d0
	mulu.w #152,%d2
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l #1092966707,%a0
.L413:
	mvz.b (%a0,%d2.l),%d2
	jra .L401
.L404:
	move.l #-2147423744,%a0
	jra .L413
.L403:
	move.l 1094562392,%d2
	jra .L401
.L400:
	clr.l ext_diag_max
	clr.l %d2
	jra .L401
	.size	diag_text, .-diag_text
	.section	.us2
	.align	2
	.globl	ext_ui_lock
	.type	ext_ui_lock, @function
ext_ui_lock:
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jeq .L415
.L417:
	clr.l %d0
.L414:
	rts
.L415:
	move.l 1094562392,%d0
	add.l #64,%d0
	cmp.l #4091,%d0
	jhi .L417
	mov3q.l #4,-(%sp)
	jsr usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L414
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	jra .L414
	.size	ext_ui_lock, .-ext_ui_lock
	.align	2
	.type	us_send.constprop.0, @function
us_send.constprop.0:
	jsr ext_ui_lock
	tst.l %d0
	jeq .L421
	move.l 4(%sp),-(%sp)
	pea 11.w
	jsr 1073752544
	jsr 1073752356
	addq.l #8,%sp
	mov3q.l #1,%d0
.L421:
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
	jeq .L428
	tst.b jn_mailbox+8.l
	jeq .L429
	mvz.b jn_mailbox+19,%d1
	move.l %a2,%d0
	add.l #17,%d0
	cmp.l %d1,%d0
	jne .L429
	mvz.b jn_mailbox+20,%d1
	mvz.b (%a0),%d0
	cmp.l %d1,%d0
	jne .L429
	move.b jn_mailbox+9,%d0
	jne .L430
	move.l #us_none,%d0
	move.l %d0,28(%sp)
.L447:
	move.l #ext_fmt_s,%d0
.L446:
	move.l %d3,20(%sp)
	movem.l (%sp),#3084
	move.l %d0,24(%sp)
	lea (16,%sp),%sp
	jmp 1074365954
.L430:
	mvz.b %d0,%d0
	cmp.l %d0,%d2
	jlt .L431
	move.l %d0,%d2
	subq.l #1,%d2
.L431:
	moveq #10,%d0
	muls.l %d2,%d0
	move.l %d0,%a1
	add.l #jn_mailbox+37,%a1
	tst.b (%a1)
	jeq .L436
	mulu.w #10,%d2
	add.l #jn_mailbox+37,%d2
	move.l %d2,28(%sp)
	jra .L447
.L429:
	clr.l %d0
.L432:
	tst.b us+52.l
	jne .L428
	tst.b 47(%a3,%a2.l)
	jne .L428
	tst.l %d0
	jeq .L435
	move.l %d2,%d0
	asr.l #4,%d0
.L435:
	move.l %d0,-(%sp)
	mov3q.l #2,-(%sp)
	mvz.b (%a0),%d0
	move.l %d0,-(%sp)
	pea 1(%a2)
	jsr us_ask
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L428
	moveq #10,%d0
	move.b %d0,us+52
	moveq #50,%d0
	move.b %d0,47(%a3,%a2.l)
.L428:
	move.l %d2,28(%sp)
	move.l #us_fmt_d,%d0
	jra .L446
.L436:
	mov3q.l #1,%d0
	jra .L432
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
	jeq .L473
	lea us,%a0
	move.l (%a0,%d0.l*4),%a1
	tst.l %a1
	jeq .L474
	tst.b (%a1)
	jne .L450
.L474:
	sub.l %a0,%a0
	jra .L449
.L450:
	move.l -12(%fp),%d1
	moveq #28,%d3
	muls.l %d3,%d1
	tst.b 36(%a1,%d1.l)
	jeq .L474
	lea 36(%a1,%d1.l),%a0
.L449:
	move.l %d2,%d1
	moveq #127,%d3
	cmp.l %d2,%d3
	jge .L452
	moveq #127,%d1
.L453:
	tst.l %a0
	jne .L454
.L455:
	lea us_fmt_d,%a0
	move.l %d1,16(%fp)
	move.l %a0,12(%fp)
	jra .L488
.L473:
	sub.l %a1,%a1
	jra .L474
.L452:
	tst.l %d2
	jge .L453
	clr.l %d1
	jra .L453
.L454:
	move.b 2(%a0),%d3
	move.w %d3,%a0
	subq.l #1,%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #6,%d3
	cmp.l %a0,%d3
	jcs .L455
	move.w .L457(%pc,%a0.l*2),%a0
	jmp %pc@(2,%a0:l)
	.balignw 2,0x284c
	.swbeg	&7
.L457:
	.word .L461-.L457
	.word .L460-.L457
	.word .L455-.L457
	.word .L459-.L457
	.word .L455-.L457
	.word .L458-.L457
	.word .L456-.L457
.L460:
	move.l -12(%fp),%d0
	sub.l %a0,%a0
	lea (484,%a1),%a2
.L462:
	mvz.b (%a2,%a0.l),%d2
	cmp.l %d2,%d0
	jne .L464
	lea (%a1,%a0.l),%a2
	mvz.b 492(%a2),%d0
	tst.l %d0
	jeq .L455
	move.l %d0,%d2
	subq.l #1,%d2
	muls.w %d1,%d0
	asr.l #7,%d0
	cmp.l %d0,%d2
	jge .L466
	move.l %d2,%d0
.L466:
	move.w %a0,%d1
	mulu.w #36,%d1
	add.l %d1,%d0
	mvz.w %d0,%d0
	lsl.l #3,%d0
	move.l %d0,%a0
	clr.l %d0
	lea (500,%a0),%a0
	add.l %a1,%a0
.L467:
	move.b (%a0,%d0.l),%d1
	jeq .L468
	move.b %d1,-8(%fp,%d0.l)
	addq.l #1,%d0
	mov3q.l #7,%d3
	cmp.l %d0,%d3
	jne .L467
.L468:
	clr.b %d1
	move.b %d1,-8(%fp,%d0.l)
	tst.l %d0
	jeq .L476
	move.l %fp,%d0
	subq.l #8,%d0
.L470:
	move.l %d0,-(%sp)
	pea ext_fmt_s
	move.l -16(%fp),-(%sp)
	jsr 1074365954
	lea (12,%sp),%sp
.L448:
	movem.l -28(%fp),#1036
	unlk %fp
	rts
.L461:
	add.l #-64,%d1
	moveq #64,%d0
	cmp.l %d2,%d0
	jge .L475
	move.l #us_fmt_pd,%d0
.L463:
	move.l %d1,16(%fp)
	move.l %d0,12(%fp)
.L488:
	movem.l -28(%fp),#1036
	move.l -16(%fp),8(%fp)
	unlk %fp
	jmp 1074365954
.L475:
	move.l #us_fmt_d,%d0
	jra .L463
.L464:
	addq.l #1,%a0
	moveq #8,%d2
	cmp.l %a0,%d2
	jne .L462
	jra .L455
.L476:
	move.l #us_none,%d0
	jra .L470
.L459:
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
	jra .L448
.L458:
	movem.l -28(%fp),#1036
	move.l -16(%fp),16(%fp)
	move.l %d1,12(%fp)
	move.l %d0,8(%fp)
	unlk %fp
	jra us_preset_text
.L456:
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
.L493:
	tst.l 24(%sp)
	jge .L490
	tst.b 46(%a2)
	jeq .L491
	tst.b 8(%a3)
	jeq .L491
	mvz.b 19(%a3),%d0
	moveq #32,%d1
	cmp.l %d0,%d1
	jne .L491
	mvz.b 20(%a3),%d1
	mvz.b 45(%a2),%d0
	cmp.l %d1,%d0
	jne .L491
.L492:
	move.l %d2,%d0
	addq.l #1,%d0
	jra .L489
.L490:
	mvz.b 58(%a2),%d0
	cmp.l 16(%sp),%d0
	jeq .L492
.L495:
	pea 10000.w
	jsr 1074367512
	addq.l #1,%d2
	addq.l #4,%sp
	cmp.l #200,%d2
	jne .L493
	clr.l %d0
.L489:
	movem.l (%sp),#7172
	lea (20,%sp),%sp
	rts
.L491:
	tst.l %d2
	jne .L495
	clr.l -(%sp)
	mov3q.l #3,-(%sp)
	clr.l -(%sp)
	clr.l -(%sp)
	jsr us_ask
	lea (16,%sp),%sp
	tst.l %d0
	jne .L495
	jra .L489
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
.L501:
	move.l (%a3)+,%a0
	tst.l %a0
	jeq .L502
	mvz.b (%a0),%d1
.L498:
	move.b 47(%a2),%d0
	addq.l #1,%d2
	tst.b %d0
	jeq .L499
	subq.l #1,%d0
.L507:
	move.b %d0,47(%a2)
.L500:
	addq.l #1,%a2
	mov3q.l #5,%d0
	cmp.l %d2,%d0
	jne .L501
	movem.l (%sp),#3076
	lea (12,%sp),%sp
	rts
.L502:
	clr.l %d1
	jra .L498
.L499:
	tst.b us+46.l
	jeq .L500
	mvz.b 40(%a2),%d0
	cmp.l %d0,%d1
	jeq .L500
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l %d1,-(%sp)
	move.l %d2,-(%sp)
	jsr us_ask
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L500
	moveq #50,%d0
	jra .L507
	.size	us_live_ask.constprop.0, .-us_live_ask.constprop.0
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
.L509:
	pea 410.w
	move.l %d2,-(%sp)
	jsr (%a3)
	move.l #dd_short,(%a2)
	addq.l #1,%d2
	lea (52,%a2),%a2
	addq.l #8,%sp
	cmp.l #1075595804,%a2
	jne .L509
	move.l #dd_eng,%d0
	move.l %d0,1075595392
	move.l #1076395164,%a2
	move.l %d0,1075595384
	move.l #dd_engine_text,%d0
	move.l %d0,1100662944
	clr.l -(%sp)
	jsr dd_name_knobs
	mvz.w #390,%d0
	addq.l #4,%sp
	lea md_rec,%a1
	move.l #1075595344,%a0
.L510:
	mvz.w %d0,%d1
	move.l (%a1),8(%a0)
	move.l 4(%a1),12(%a0)
	move.l 8(%a1),16(%a0)
	move.l %d0,(%a2,%d1.l*4)
	lea (12,%a1),%a1
	addq.l #1,%d0
	lea (52,%a0),%a0
	cmp.l #398,%d0
	jne .L510
	movem.l (%sp),#3076
	lea (12,%sp),%sp
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
	jge .L514
	moveq #127,%d0
.L515:
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
	jlt .L517
	moveq #65,%d1
.L516:
	move.l %a0,-(%sp)
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	pea jn_fmt
	move.l 32(%sp),-(%sp)
	jsr 1074365954
	lea (20,%sp),%sp
	move.l (%sp)+,%d2
	rts
.L514:
	tst.l %d1
	jge .L515
	clr.l %d0
	jra .L515
.L517:
	moveq #66,%d1
	jra .L516
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
.L519:
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
	jne .L519
	move.b jn_mailbox+8,%d1
	tst.l %d0
	jne .L520
	tst.b %d1
	jeq .L521
	move.b %d0,jn_mailbox+10
.L521:
	clr.b %d1
	move.b %d1,jn_mailbox+8
.L522:
	move.b jn_mailbox+10,%d0
	jeq .L524
	subq.l #1,%d0
	move.b %d0,jn_mailbox+10
.L525:
	tst.b %d3
	jeq .L534
	move.l #fm_fmt_d,%d5
	move.l %a6,64(%sp)
	move.l %d5,60(%sp)
	jra .L551
.L520:
	tst.b %d1
	jeq .L522
	move.b jn_mailbox+9,%d1
	jeq .L525
	move.l %a6,%d0
	tst.l %a6
	jge .L531
	clr.l %d0
.L531:
	mvz.b %d1,%d1
	cmp.l %d1,%d0
	jlt .L532
	move.l %d1,%d0
	subq.l #1,%d0
.L532:
	moveq #10,%d1
	muls.l %d0,%d1
	move.l %d1,%a0
	add.l #jn_mailbox+37,%a0
	tst.b (%a0)
	jeq .L536
	mulu.w #10,%d0
	add.l #jn_mailbox+37,%d0
.L533:
	move.l #ext_fmt_s,%d1
	move.l %d0,64(%sp)
	move.l %d1,60(%sp)
.L551:
	move.l %d2,56(%sp)
	movem.l (%sp),#17468
	lea (52,%sp),%sp
	jmp 1074365954
.L524:
	jsr ext_ui_lock
	tst.l %d0
	jeq .L525
	moveq #16,%d0
	move.l #-260222380,%d5
	mov3q.l #5,%a0
	move.l %d5,30(%sp)
	move.l #1081903566,%a1
	move.b %d0,34(%sp)
.L526:
	move.b (%a0,%a1.l),%d0
	jeq .L527
	moveq #127,%d1
	addq.l #1,%a0
	and.l %d1,%d0
	moveq #20,%d5
	move.b %d0,29(%a0,%sp.l)
	cmp.l %a0,%d5
	jne .L526
.L527:
	moveq #-9,%d1
	move.l %a0,%d0
	addq.l #1,%d0
	move.b %d1,30(%sp,%a0.l)
	move.l #1081903571,%a0
.L529:
	move.b (%a0),(%a2,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L529
	moveq #-56,%d5
	lea (30,%sp),%a2
	move.l %a2,-(%sp)
	move.l %d0,-(%sp)
	move.b %d5,jn_mailbox+10
	jsr 1073752544
	addq.l #8,%sp
	tst.b %d3
	jeq .L535
	moveq #24,%d0
.L530:
	move.b %d0,34(%sp)
	moveq #-9,%d0
	move.b %d0,35(%sp)
	move.l %a2,-(%sp)
	mov3q.l #6,-(%sp)
	jsr 1073752544
	jsr 1073752356
	addq.l #8,%sp
	jra .L525
.L535:
	moveq #19,%d0
	jra .L530
.L536:
	move.l #jn_empty,%d0
	jra .L533
.L534:
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
.L556:
	move.l %d2,%d1
	mov3q.l #5,%d5
	mvz.w #410,%d0
	add.l #383,%d1
	cmp.l %d2,%d5
	jcs .L555
	moveq #40,%d0
.L555:
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
	jne .L556
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
	moveq #72,%d0
	muls.l %d1,%d0
	add.l #-2147418536,%a0
	cmp.l (%a0),%d2
	jne .L560
	cmp.l 8(%a0),%d2
	jne .L560
	cmp.l 4(%a0),%d2
	jeq .L561
	tst.l 1079807120
	jeq .L561
.L560:
	moveq #1,%d1
	lea ext_state,%a0
	move.b %d1,69(%a0,%d0.l)
.L562:
	move.l -16(%fp),%d2
	unlk %fp
	jra ext_project
.L561:
	lea ext_state,%a0
	add.l %d0,%a0
	move.l %a0,-12(%fp)
	tst.b 69(%a0)
	jeq .L562
	tst.b 66(%a0)
	jne .L562
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
	jeq .L562
	clr.b %d1
	move.l -12(%fp),%a0
	move.b %d1,69(%a0)
	jra .L562
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
	jne .L574
	move.l #1076432344,%a0
	move.l 128(%sp),%a1
	mvz.b (%a1,%a0.l),%d0
	move.l #1075573068,%a0
	move.l (%a0,%d0.l*4),%d2
.L575:
	clr.l %d0
	lea (40,%sp),%a2
.L577:
	lea (%a3,%d0.l),%a0
	moveq #84,%d1
	move.w (%a0),(%a2,%d0.l)
	addq.l #2,%d0
	cmp.l %d0,%d1
	jne .L577
	move.l %d2,%d0
	clr.l %d1
	lsl.l #5,%d0
	lea dsp_x_word,%a4
	move.l %d0,%a1
	add.l #1094563324,%a1
.L581:
	move.l (%a1),%d0
	tst.l %d0
	jle .L578
	moveq #52,%d3
	mov3q.l #4,%d4
	muls.l %d3,%d0
	move.l %d0,%a0
	add.l #1075575064,%a0
	cmp.l %d1,%d4
	jge .L579
	move.l 16(%a0),%d0
.L580:
	move.w %d0,(%a2,%d1.l*2)
.L578:
	addq.l #1,%d1
	addq.l #4,%a1
	moveq #8,%d5
	cmp.l %d1,%d5
	jne .L581
	move.l #1076429692,%a0
	move.l 140(%sp),-(%sp)
	move.l (%a0,%d2.l*4),%a0
	move.l %a2,-(%sp)
	move.l 140(%sp),-(%sp)
	move.l 140(%sp),-(%sp)
	jsr (%a0)
	lea (16,%sp),%sp
.L573:
	move.l %a6,%d0
	movem.l (%sp),#23676
	lea (124,%sp),%sp
	rts
.L574:
	mov3q.l #2,%d0
	cmp.l %a6,%d0
	jne .L582
	moveq #15,%d2
	jra .L575
.L579:
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
	jra .L580
.L582:
	sub.l %a6,%a6
	jra .L573
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
.L586:
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
	jne .L586
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
	jne .L589
	moveq #12,%d4
	cmp.l %d1,%d4
	jge .L590
	move.b 5(%a0),%d0
	mov3q.l #7,%d1
	move.l #1076432344,%a1
	moveq #11,%d2
	and.l %d1,%d0
	move.b (%a1,%d0.l),%d3
	mvz.b %d3,%d0
	cmp.l %d0,%d2
	jcs .L590
	move.l #-2147423744,%a1
	moveq #41,%d4
	mvz.b (%a1,%d0.l),%d0
	cmp.l %d0,%d4
	jne .L590
	move.b jn_mailbox+11,%d0
	addq.l #1,%d0
	move.b %d0,jn_mailbox+11
	clr.l %d1
	lea jn_mailbox+13,%a1
.L591:
	move.b 6(%a0,%d1.l),%d2
	moveq #127,%d4
	addq.l #1,%d1
	and.l %d4,%d2
	move.b %d2,-1(%a1,%d1.l)
	mov3q.l #6,%d2
	cmp.l %d1,%d2
	jne .L591
	move.b %d3,jn_mailbox+12
	addq.l #1,%d0
	move.b %d0,jn_mailbox+11
.L590:
	movem.l (%sp),#28
	mov3q.l #1,%d0
	lea (12,%sp),%sp
	rts
.L589:
	move.l %d0,%d2
	add.l #-22,%d2
	mvz.b %d2,%d2
	lsr.l #1,%d2
	jne .L590
	mov3q.l #7,%d4
	cmp.l %d1,%d4
	jge .L590
	tst.b 5(%a0)
	jeq .L592
	lea jn_mailbox+37,%a1
	moveq #127,%d0
.L593:
	clr.b (%a1)
	subq.l #1,%d0
	lea (10,%a1),%a1
	tst.l %d0
	jne .L593
	move.b 6(%a0),%d0
	jpl .L594
	moveq #127,%d0
.L594:
	move.b %d0,jn_mailbox+9
	move.b 4(%a0),%d0
	add.l #-22,%d0
	move.b %d0,jn_mailbox+19
	moveq #1,%d0
	move.b %d0,jn_mailbox+8
.L595:
	subq.l #1,%d1
	addq.l #7,%a0
	moveq #8,%d2
.L596:
	move.l %d2,%d0
	add.l #12,%d0
	cmp.l %d1,%d0
	jge .L590
	move.b (%a0),%d0
	moveq #126,%d4
	mvz.b %d0,%d3
	cmp.l %d3,%d4
	jcs .L597
	ext.w %d0
	mulu.w #10,%d0
	move.l %d0,%a1
	clr.l %d0
	add.l #jn_mailbox+37,%a1
.L598:
	move.b 1(%a0,%d0.l),%d3
	jeq .L599
	move.b %d3,(%a1,%d0.l)
	addq.l #1,%d0
	moveq #9,%d3
	cmp.l %d0,%d3
	jne .L598
.L599:
	clr.b %d4
	move.b %d4,(%a1,%d0.l)
.L597:
	add.l #14,%d2
	lea (14,%a0),%a0
	jra .L596
.L592:
	moveq #22,%d2
	eor.l %d2,%d0
	mvz.b jn_mailbox+19,%d2
	tst.b %d0
	sne %d0
	neg.l %d0
	mvz.b %d0,%d0
	cmp.l %d2,%d0
	jne .L590
	jra .L595
	.size	jn_sysex, .-jn_sysex
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
.L619:
	move.l us+36,%a0
	add.l %d4,%a0
	move.b 1(%a0),%d1
	btst #0,%d1
	jne .L609
	mvz.b 2(%a0),%d0
	mvz.b %d1,%d3
	cmp.l %d0,%d3
	jeq .L609
	move.w 4(%a0),%d2
	move.b (%a0),%d0
	move.w %d0,%a6
	clr.l %d0
.L610:
	lea 6(%a0,%d0.l),%a1
	moveq #16,%d6
	move.b (%a1),40(%sp,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d6
	jne .L610
	mvz.b 1(%a0),%d0
	cmp.l %d0,%d3
	jne .L609
	move.b %d1,2(%a0)
	move.w %a6,%d0
	move.l #-2147423744,%a0
	mvz.b (%a0,%d5.l),%d1
	mvz.b %d0,%d3
	move.l %d3,%d0
	add.l #34,%d0
	cmp.l %d1,%d0
	jne .L609
	add.l #-35,%d0
	move.l (%a4,%d0.l*4),%a2
	tst.l %a2
	jeq .L609
	move.l %d0,-(%sp)
	jsr us_params
	addq.l #4,%sp
	tst.l %d0
	jne .L611
	mvz.b %d2,%d2
.L611:
	lsl.l #3,%d3
	mvz.w %d2,%d2
	lea us_p2rec,%a3
	sub.l %a6,%a6
	lea (36,%a2),%a2
	lea us_set,%a5
	add.l #326,%d3
.L618:
	move.l %a6,%d0
	btst %d0,%d2
	jeq .L612
	mvz.b 40(%sp,%a6.l),%d1
	tst.b (%a2)
	jeq .L620
	mvz.b 4(%a2),%d0
	cmp.l %d0,%d1
	jlt .L614
	mvz.b 5(%a2),%d0
.L613:
	cmp.l %d0,%d1
	jge .L614
	move.l %d1,%d0
.L614:
	lsl.l #8,%d0
	mov3q.l #7,%d1
	cmp.l %a6,%d1
	jlt .L616
	move.l %d3,%d1
	add.l %a6,%d1
.L617:
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	pea 9(%a6)
	move.l %d5,-(%sp)
	jsr (%a5)
	lea (16,%sp),%sp
.L612:
	addq.l #1,%a6
	addq.l #2,%a3
	lea (28,%a2),%a2
	moveq #16,%d6
	cmp.l %a6,%d6
	jne .L618
.L609:
	addq.l #1,%d5
	add.l #28,%d4
	moveq #12,%d0
	cmp.l %d5,%d0
	jne .L619
	movem.l (%sp),#31868
	lea (56,%sp),%sp
	rts
.L620:
	moveq #127,%d0
	jra .L613
.L616:
	mvs.w -16(%a3),%d1
	jra .L617
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
	jeq .L638
	move.w #16,%a4
.L631:
	mvz.w %d4,%d5
	move.w #18,%a6
	mvz.b 63(%sp),%d7
	move.w 34(%a3),%d6
	lsl.l #3,%d5
	sub.l %a5,%a5
	lea us_kit_sound,%a3
	add.l #334,%d5
	move.l %d5,44(%sp)
.L636:
	tst.b (%a2)
	jeq .L639
	move.b 6(%a2),%d3
.L632:
#APP
| 2288 "ext.c" 1
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
	jeq .L633
	clr.b %d1
	move.b %d3,(%a6,%d0.l)
	move.b %d1,1(%a6,%d0.l)
.L633:
#APP
| 2293 "ext.c" 1
	move.w %d5,%sr
| 0 "" 2
#NO_APP
	mvz.b %d3,%d3
	mov3q.l #7,%d0
	lsl.l #8,%d3
	cmp.l %a5,%d0
	jlt .L634
	move.l 44(%sp),%d0
	add.l %a5,%d0
.L635:
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
	jne .L636
#APP
| 2322 "ext.c" 1
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
	move.l %d0,%a0
	tst.l %d0
	jeq .L637
	move.b 90(%a0),%d1
	moveq #-64,%d4
	move.l %d6,%d0
	lsr.l #8,%d0
	and.l %d4,%d1
	or.l %d0,%d1
	move.b %d1,90(%a0)
	move.b %d6,91(%a0)
	lea us_tag,%a0
	move.w %d6,(%a0,%d2.l*2)
	mulu.w #162,%d2
	move.l %d2,%a0
	add.l #1081497997,%a0
	move.b %d0,(%a0)
	move.b %d6,1(%a0)
.L637:
#APP
| 2330 "ext.c" 1
	move.w %d3,%sr
| 0 "" 2
#NO_APP
	movem.l (%sp),#31996
	lea (48,%sp),%sp
	rts
.L638:
	move.w #8,%a4
	jra .L631
.L639:
	moveq #64,%d3
	jra .L632
.L634:
	lea us_p2rec-34,%a0
	mvs.w (%a0,%a6.l),%d0
	jra .L635
	.size	us_defaults, .-us_defaults
	.align	2
	.type	md_store.constprop.0, @function
md_store.constprop.0:
	lea (-24,%sp),%sp
	movem.l #15372,(%sp)
	move.l 28(%sp),%d2
	move.l %d2,%d0
	addq.l #1,%d0
	move.b %d0,md_wr
#APP
| 3098 "ext.c" 1
	move.w %sr,%d0
	move.l %d0,%d1
	ori.l #0x0700,%d1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
	mvz.b 39(%sp),%d3
	move.l %d0,%a2
	lea us_kit_sound,%a3
	move.l %d3,-(%sp)
	mov3q.l #7,-(%sp)
	move.l %d2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	move.l %d0,%a0
	tst.l %d0
	jne .L648
	move.l %a2,%d1
#APP
| 3106 "ext.c" 1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
.L649:
	tst.l %a0
	sne %d0
	clr.b %d1
	movem.l (%sp),#15372
	mvs.b %d0,%d0
	move.b %d1,md_wr
	neg.l %d0
	lea (24,%sp),%sp
	rts
.L648:
	lea (18,%a0),%a1
	clr.l %d0
.L651:
	move.l 32(%sp),%a4
	moveq #14,%d1
	move.b (%a4,%d0.l),(%a1)
	cmp.l %d0,%d1
	jeq .L658
	moveq #15,%d1
	cmp.l %d0,%d1
	jne .L659
	moveq #68,%d1
.L650:
	move.b %d1,1(%a1)
	addq.l #1,%d0
	addq.l #2,%a1
	moveq #16,%d1
	cmp.l %d0,%d1
	jne .L651
	move.b 90(%a0),%d0
	moveq #-64,%d1
	and.l %d1,%d0
	moveq #34,%d1
	or.l %d1,%d0
	move.l %a2,%d1
	move.b %d0,90(%a0)
	moveq #77,%d0
	move.b %d0,91(%a0)
	move.w %d2,%d0
	mulu.w #162,%d0
	move.l %d0,%a0
	add.l #1081497997,%a0
	move.b #34,(%a0)
	addq.l #1,%a0
	move.b #77,(%a0)
#APP
| 3106 "ext.c" 1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
	lea us_p2rec,%a4
	sub.l %a2,%a2
	lea us_set,%a5
.L656:
	move.l 32(%sp),%a0
	moveq #14,%d1
	mvz.b (%a0,%a2.l),%d0
	lsl.l #8,%d0
	cmp.l %a2,%d1
	jne .L652
	moveq #77,%d1
.L665:
	or.l %d1,%d0
.L653:
	mvs.w -16(%a4),%d1
	jra .L655
.L658:
	moveq #77,%d1
	jra .L650
.L659:
	clr.b %d1
	jra .L650
.L652:
	moveq #15,%d1
	cmp.l %a2,%d1
	jne .L654
	moveq #68,%d1
	jra .L665
.L654:
	mov3q.l #7,%d1
	cmp.l %a2,%d1
	jlt .L653
	move.l %a2,%d1
	add.l #390,%d1
.L655:
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	pea 9(%a2)
	move.l %d2,-(%sp)
	jsr (%a5)
	addq.l #1,%a2
	addq.l #2,%a4
	lea (16,%sp),%sp
	moveq #16,%d0
	cmp.l %a2,%d0
	jne .L656
#APP
| 3110 "ext.c" 1
	move.w %sr,%d0
	move.l %d0,%d1
	ori.l #0x0700,%d1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
	move.l %d3,-(%sp)
	mov3q.l #7,-(%sp)
	move.l %d2,-(%sp)
	move.l %d0,%a2
	jsr (%a3)
	lea (12,%sp),%sp
	move.l %d0,%a0
	tst.l %d0
	jeq .L657
	move.w #8781,%d1
	lea us_tag,%a1
	move.w %d1,(%a1,%d2.l*2)
.L657:
	move.l %a2,%d0
#APP
| 3112 "ext.c" 1
	move.w %d0,%sr
| 0 "" 2
#NO_APP
	jra .L649
	.size	md_store.constprop.0, .-md_store.constprop.0
	.align	2
	.type	md_setup, @function
md_setup:
	lea (-32,%sp),%sp
	movem.l #19460,(%sp)
	move.l 40(%sp),%a2
	pea 16.w
	lea (20,%sp),%a3
	move.l %a3,-(%sp)
	jsr us_zero
	addq.l #8,%sp
	tst.l %a2
	jeq .L671
	move.b 18(%a2),%d0
	moveq #127,%d1
	moveq #11,%d2
	and.l %d1,%d0
	muls.l %d2,%d0
	lsr.l #7,%d0
	lsl.l #2,%d0
	move.l %d0,%a6
	add.l #md_map,%a6
	move.b (%a6),%d0
.L667:
	mvz.b %d0,%d0
	pea 8.w
	lsl.l #3,%d0
	add.l #md_defaults,%d0
	move.l %d0,-(%sp)
	move.l %a3,-(%sp)
	jsr us_copy
	lea (12,%sp),%sp
	tst.l %a2
	jeq .L668
	lea (20,%a2),%a2
	clr.l %d0
.L669:
	mvz.b 3(%a6),%d1
	cmp.l %d1,%d0
	jlt .L670
.L668:
	move.b 1(%a6),24(%sp)
	moveq #100,%d0
	move.b 2(%a6),25(%sp)
	move.b %d0,26(%sp)
	mvz.b 47(%sp),%d0
	move.l %d0,-(%sp)
	move.l %a3,-(%sp)
	move.l 44(%sp),-(%sp)
	jsr (md_store.constprop.0)
	movem.l 12(%sp),#19460
	lea (44,%sp),%sp
	rts
.L671:
	clr.b %d0
	lea md_map,%a6
	jra .L667
.L670:
	move.b (%a2),%d1
	moveq #127,%d2
	addq.l #2,%a2
	and.l %d2,%d1
	move.b %d1,(%a3,%d0.l)
	addq.l #1,%d0
	jra .L669
	.size	md_setup, .-md_setup
	.align	2
	.type	md_tick.constprop.0, @function
md_tick.constprop.0:
	lea (-48,%sp),%sp
	movem.l #31996,(%sp)
	move.l us+36,%a2
	move.b us+64,%d5
	tst.l %a2
	jeq .L676
	move.l us+28,%a3
	tst.l %a3
	jeq .L676
	mvz.b %d5,%d2
	addq.l #3,%a2
	move.l #1081497997,%d4
	clr.l %d3
	sub.l %a4,%a4
	move.l #-2147423744,%a5
	move.l %d2,44(%sp)
	lea md_setup,%a6
.L686:
	move.b (%a4,%a5.l),%d1
	move.l %a4,%d6
	moveq #42,%d7
	addq.l #1,%a4
	move.b (%a2),%d2
	move.l -2147457096,%d0
	mvz.b %d1,%d1
	cmp.l %d1,%d7
	jeq .L678
	mvz.b %d2,%d2
	mov3q.l #5,%d0
	cmp.l %d2,%d0
	jcc .L679
.L685:
	clr.b (%a2)
	jra .L679
.L678:
	moveq #127,%d1
	moveq #42,%d7
	and.l %d1,%d0
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l #1092966689,%a0
	add.l %d3,%a0
	mvz.b 84(%a0),%d0
	cmp.l %d0,%d7
	jne .L679
	mvz.b us+63,%d0
	cmp.l %d0,%a4
	jeq .L679
	move.b 90(%a0),%d0
	mvz.b 91(%a0),%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #16383,%d0
	cmp.l #8781,%d0
	jeq .L681
	tst.b 46(%a0)
	jne .L681
	mvz.b 47(%a0),%d0
	moveq #77,%d1
	cmp.l %d0,%d1
	jne .L681
	tst.b 48(%a0)
	jne .L681
	mvz.b 49(%a0),%d0
	moveq #68,%d7
	cmp.l %d0,%d7
	jne .L681
#APP
| 3160 "ext.c" 1
	move.w %sr,%d7
	move.l %d7,%d1
	ori.l #0x0700,%d1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
	mvz.b %d5,%d0
	move.l %d0,-(%sp)
	mov3q.l #7,-(%sp)
	move.l %d6,-(%sp)
	jsr us_kit_sound
	lea (12,%sp),%sp
	move.l %d0,%a0
	tst.l %d0
	jeq .L683
	move.b 90(%a0),%d1
	moveq #-64,%d0
	and.l %d0,%d1
	moveq #34,%d0
	or.l %d0,%d1
	move.w #8781,%d0
	move.b %d1,90(%a0)
	moveq #77,%d1
	move.b %d1,91(%a0)
	move.l %d4,%a0
	move.b #34,(%a0)+
	move.b #77,(%a0)
	lea us_tag,%a0
	move.w %d0,(%a0,%d6.l*2)
.L683:
#APP
| 3165 "ext.c" 1
	move.w %d7,%sr
| 0 "" 2
#NO_APP
	moveq #127,%d0
	and.l -2147457096,%d0
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l #1092966689,%a0
	add.l %d3,%a0
.L681:
	mvz.b %d2,%d2
	mov3q.l #5,%d1
	cmp.l %d2,%d1
	jcc .L679
	moveq #9,%d7
	cmp.l %d2,%d7
	jne .L696
	move.b 90(%a0),%d0
	mvz.b 91(%a0),%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #16383,%d0
	cmp.l #8781,%d0
	jeq .L685
.L684:
	move.l 44(%sp),-(%sp)
	move.l %a0,-(%sp)
	move.l %d6,-(%sp)
	jsr (%a6)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L685
.L679:
	lea (28,%a2),%a2
	add.l #152,%d3
	add.l #162,%d4
	moveq #12,%d0
	cmp.l %a4,%d0
	jne .L686
	mvz.b 1093765506,%d1
	moveq #11,%d2
	cmp.l %d1,%d2
	jge .L687
	clr.l %d1
.L687:
	move.l #-2147423744,%a0
	moveq #42,%d3
	mvz.b (%a0,%d1.l),%d2
	move.l -2147457096,%d0
	cmp.l %d2,%d3
	jne .L676
	mvz.b us+63,%d2
	move.l %d1,%a0
	addq.l #1,%a0
	cmp.l %d2,%a0
	jeq .L676
	moveq #127,%d7
	and.l %d7,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a2
	add.l #1092966689,%a2
	add.l %d1,%a2
	move.b 90(%a2),%d0
	mvz.b 91(%a2),%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	mvz.b md+4,%d1
	and.l #16383,%d0
	cmp.l #8781,%d0
	jeq .L688
	subq.l #1,%d1
	tst.l %d1
	jeq .L676
	clr.b %d2
	moveq #1,%d1
	move.b %d2,us+60
	movem.l (%sp),#31996
	move.b %d1,md+4
	lea (48,%sp),%sp
	jra dd_descriptors
.L696:
	sub.l %a0,%a0
	jra .L684
.L688:
	subq.l #2,%d1
	tst.l %d1
	jeq .L689
	moveq #2,%d7
	mov3q.l #7,-(%sp)
	move.b %d7,md+4
	jsr us_slot_records
	clr.w %d0
	addq.l #4,%sp
	move.w %d0,md
.L689:
	move.b 36(%a2),%d1
	move.b 34(%a2),%d0
	moveq #127,%d2
	mov3q.l #3,%d3
	and.l %d2,%d1
	and.l %d2,%d0
	mvz.w md,%d2
	muls.l %d3,%d0
	asr.l #7,%d0
	move.l %d0,%a2
	lsl.l #8,%d0
	or.l %d1,%d0
	bset #15,%d0
	cmp.l %d0,%d2
	jeq .L690
	clr.b %d7
	move.w %d0,md
	move.b %d7,md+2
.L690:
	move.b md+2,%d0
	jeq .L691
	subq.l #1,%d0
.L730:
	move.b %d0,md+2
.L692:
	move.b md+3,%d0
	jeq .L693
	subq.l #1,%d0
	move.b %d0,md+3
.L676:
	movem.l (%sp),#31996
	lea (48,%sp),%sp
	rts
.L691:
	move.l %d1,-(%sp)
	clr.l -(%sp)
	mvz.b (%a3),%d0
	move.l %d0,-(%sp)
	pea 64(%a2)
	jsr us_ask
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L692
	moveq #40,%d0
	jra .L730
.L693:
	move.b (%a3),%d2
	jeq .L676
	mvz.w 34(%a3),%d0
	cmp.l %d0,%a2
	jne .L676
	mvz.b 1(%a3),%d0
	subq.l #1,%d0
	tst.l %d0
	jne .L676
	tst.b 267(%a3)
	jeq .L694
	pea 8.w
	move.l %a3,-(%sp)
	jsr us_has_enum
	addq.l #8,%sp
	tst.l %d0
	jeq .L698
.L694:
	tst.b 295(%a3)
	jeq .L676
	pea 9.w
	move.l %a3,-(%sp)
	jsr us_has_enum
	addq.l #8,%sp
	tst.l %d0
	jne .L676
	moveq #9,%d0
.L695:
	mvz.b %d2,%d2
	move.l %d0,-(%sp)
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	pea 64(%a2)
	jsr us_ask
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L676
	moveq #4,%d2
	move.b %d2,md+3
	jra .L676
.L698:
	moveq #8,%d0
	jra .L695
	.size	md_tick.constprop.0, .-md_tick.constprop.0
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
.L734:
	pea 410.w
	move.l %a3,-(%sp)
	jsr (%a4)
	addq.l #1,%a3
	addq.l #8,%sp
	cmp.l #438,%a3
	jne .L734
	move.l #dsp_out_text,%d0
	mov3q.l #6,%a3
	move.l %d0,1100666556
	lea dsps_rec,%a4
.L735:
	pea 410.w
	mvs.w (%a4)+,%d0
	subq.l #1,%a3
	move.l %d0,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
	tst.l %a3
	jne .L735
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
.L736:
	pea -402(%a3)
	move.l %a3,-(%sp)
	jsr (%a2)
	addq.l #1,%a3
	addq.l #8,%sp
	cmp.l #449,%a3
	jne .L736
	pea 410.w
	pea 443.w
	jsr (%a2)
	pea 410.w
	pea 441.w
	jsr (%a2)
	mvz.w #441,%d0
	clr.l 1075597908
	lea (16,%sp),%sp
	move.l %d0,1076396832
#APP
| 909 "ext.c" 1
	movel #P_DIAG,%d0
| 0 "" 2
#NO_APP
	tst.l %d0
	jeq .L737
	movem.l (%sp),#7168
	lea (12,%sp),%sp
	jra diag_desc
.L737:
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
.L742:
	pea 410.w
	move.l %d2,-(%sp)
	jsr (%a2)
	addq.l #1,%d2
	addq.l #8,%sp
	cmp.l #455,%d2
	jne .L742
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
.L745:
	pea 410.w
	move.l %d2,-(%sp)
	jsr (%a2)
	addq.l #1,%d2
	addq.l #8,%sp
	cmp.l #429,%d2
	jne .L745
	pea 101.w
	move.l %d2,-(%sp)
	jsr (%a2)
	jsr dsp_descriptors
	jsr jn_descriptors
	addq.l #8,%sp
	moveq #1,%d0
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
	jcs .L749
	lea us_flag_tab,%a0
	mvz.b (%a0,%d0.l),%d0
.L747:
	rts
.L749:
	clr.l %d0
	jra .L747
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
	jne .L751
	move.l #1076432344,%a0
	move.l 12(%sp),%a1
	mvz.b (%a1,%a0.l),%d0
	lea us_tag,%a0
	move.w (%a0,%d0.l*2),%d0
	eor.l #8781,%d0
	tst.w %d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L750:
	move.l (%sp)+,%d2
	rts
.L751:
	move.l %d0,%d1
	moveq #32,%d2
	add.l #-80,%d1
	cmp.l %d1,%d2
	jcs .L753
	asr.l #3,%d0
	lea us,%a0
	mvz.b 43(%a0,%d0.l),%d0
	jra .L750
.L753:
	clr.l %d0
	jra .L750
	.size	ext_layer_kept, .-ext_layer_kept
	.align	2
	.globl	ext_smute_apply
	.type	ext_smute_apply, @function
ext_smute_apply:
	clr.b %d1
	mvz.b ext_smute,%d0
	move.l %d2,-(%sp)
	move.b %d1,ext_smute
	move.l #-536864258,%d1
.L755:
	tst.l %d0
	jne .L758
	move.l (%sp)+,%d2
	rts
.L758:
	btst #0,%d0
	jeq .L756
	move.l %d1,%d2
	sub.l %a0,%a0
	lsl.l #2,%d2
	move.l %d2,%a1
.L757:
	clr.l (%a1)+
	moveq #32,%d2
	addq.l #1,%a0
	cmp.l %a0,%d2
	jne .L757
.L756:
	lsr.l #1,%d0
	add.l #32,%d1
	jra .L755
	.size	ext_smute_apply, .-ext_smute_apply
	.align	2
	.globl	ext_midi_hold
	.type	ext_midi_hold, @function
ext_midi_hold:
	move.l 1073849316,%a1
	tst.l %a1
	jeq .L764
	move.l 4(%sp),%d0
	not.l %d0
	move.l %d0,4(%sp)
	jmp (%a1)
.L764:
	clr.l %d0
	rts
	.size	ext_midi_hold, .-ext_midi_hold
	.text
	.align	2
	.globl	ext_render_body
	.type	ext_render_body, @function
ext_render_body:
	link.w %fp,#-124
	move.l #-2147423744,%a0
	movem.l #15612,(%sp)
	move.l 8(%fp),%d5
	move.l %d5,%d0
	move.l %d5,%a2
	add.l #1076432344,%a2
	lsl.l #5,%d0
	mov3q.l #7,%d2
	and.l %d5,%d2
	move.l 12(%fp),%d7
	move.l 16(%fp),%d4
	move.l %d0,%a3
	add.l #-2147418376,%a3
	mvz.b (%a2),%d0
	move.l (%a3),%a4
	move.l %d2,%d3
	move.b (%a0,%d0.l),%d0
	move.b %d0,-81(%fp)
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	jsr ext_vflag
	addq.l #4,%sp
	moveq #16,%d1
	or.l %d0,%d3
	moveq #120,%d0
	and.l %d3,%d0
	cmp.l %d0,%d1
	jne .L766
	move.l 20(%fp),-(%sp)
	move.l %d4,-(%sp)
	move.l %d7,-(%sp)
	move.l %d5,-(%sp)
	jsr dsp_excite
	lea (16,%sp),%sp
	move.l %d0,%d6
	tst.l %d0
	jne .L767
.L766:
	clr.l (%a3)
	move.l 20(%fp),-(%sp)
	move.l %d4,-(%sp)
	move.l %d7,-(%sp)
	move.l %d5,-(%sp)
	jsr 1074872060
	mov3q.l #1,(%a3)
	lea (16,%sp),%sp
	clr.l %d6
.L767:
	move.l %d5,-(%sp)
	jsr ext_gate
	addq.l #4,%sp
	subq.l #2,%d6
	tst.l %d6
	jeq .L768
	move.l %d3,%d0
	mvz.b %d0,%d0
	move.l %d5,-(%sp)
	move.l %d0,-(%sp)
	jsr ext_layer_kept
	addq.l #8,%sp
	tst.l %d0
	jne .L768
	move.l %d2,%d0
	add.l #-268431872,%d0
	lsl.l #3,%d0
	moveq #17,%d1
	move.l %d0,%a0
	move.l %d2,%d0
	lsl.l #3,%d0
	clr.l (%a0)
	move.l %d0,%a0
	add.l #-2147454972,%a0
	clr.l (%a0)
	move.l #-2147423744,%a0
	mvz.b (%a2),%d0
	mvz.b (%a0,%d0.l),%d0
	add.l #-35,%d0
	cmp.l %d0,%d1
	jcs .L768
	mov3q.l #1,%d0
	move.b ext_smute,%d1
	lsl.l %d2,%d0
	or.l %d1,%d0
	move.b %d0,ext_smute
.L768:
	move.w %d2,%d5
	mvz.b -81(%fp),%d7
	lea (-76,%fp),%a1
	clr.l %d1
	mulu.w #72,%d5
	move.l %d5,%a0
	add.l #ext_state,%a0
	move.l %a0,-80(%fp)
	move.l %a0,%a3
	sub.l %a0,%a0
.L772:
	move.l %d4,%a5
	mvz.w (%a5,%d1.l*2),%d0
	lsr.l #1,%d0
	and.l #16383,%d0
	move.w %d0,%d6
	move.w %d0,(%a1)+
	moveq #43,%d0
	cmp.l %d7,%d0
	jne .L770
	mov3q.l #7,%d0
	cmp.l %d1,%d0
	jlt .L770
	clr.w %d6
	move.w %d6,-2(%a1)
.L770:
	move.w (%a3)+,%d0
	addq.l #1,%d1
	eor.l %d6,%d0
	move.l %a0,%d6
	tst.w %d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d6
	moveq #16,%d0
	move.l %d6,%a0
	cmp.l %d1,%d0
	jne .L772
	moveq #72,%d6
	muls.l %d2,%d6
	lea ext_state,%a3
	tst.l %a4
	jne .L773
	move.l 20(%fp),%d0
	moveq #127,%d4
	moveq #1,%d1
	move.l #-2147457084,%a4
	swap %d0
	ext.l %d0
	move.b %d1,66(%a3,%d6.l)
	and.l %d4,%d0
	move.b %d0,64(%a3,%d6.l)
	mvz.b (%a2),%d0
	move.b (%a4,%d0.l*2),%d0
	and.l %d4,%d0
	move.b %d0,65(%a3,%d6.l)
.L773:
	mov3q.l #1,%d7
	cmp.l 1094562388.l,%d7
	jeq .L774
	clr.b %d0
	move.b %d0,ext_dcap
.L774:
	tst.b 71(%a3,%d6.l)
	jeq .L775
	tst.b ext_dcap.l
	jeq .L775
	lsl.l #8,%d2
	add.l 1100784300,%d2
	and.l #2047,%d2
	tst.l %d2
	jne .L775
	move.b ext_dgen,%d0
	moveq #1,%d1
	subq.l #1,%d0
	move.b %d0,70(%a3,%d6.l)
	move.b %d1,67(%a3,%d6.l)
.L775:
	tst.l %a0
	jne .L776
	tst.b 66(%a3,%d6.l)
	jeq .L777
.L776:
	move.l %d5,%a0
	clr.l %d0
	add.l #ext_state,%a0
.L778:
	lea -76(%fp,%d0.l),%a1
	moveq #32,%d1
	move.w (%a1),32(%a0,%d0.l)
	addq.l #2,%d0
	cmp.l %d0,%d1
	jne .L778
	moveq #1,%d2
	move.b %d2,67(%a3,%d6.l)
.L777:
	move.b 68(%a3,%d6.l),%d0
	jeq .L779
	subq.l #1,%d0
	move.b %d0,68(%a3,%d6.l)
.L779:
	lea (%a3,%d6.l),%a0
	tst.b 67(%a0)
	jeq .L765
	tst.b 66(%a0)
	jne .L781
	tst.b 68(%a0)
	jne .L765
.L781:
	mvz.b (%a2),%d0
	mvz.b md_wr,%d2
	move.l %d0,%d1
	addq.l #1,%d1
	cmp.l %d2,%d1
	jeq .L765
	tst.b %d3
	jge .L782
	move.l %d0,-(%sp)
	jsr ext_midi_hold
	addq.l #4,%sp
	tst.l %d0
	jeq .L782
	clr.w %d3
	move.w %d3,66(%a3,%d6.l)
.L765:
	movem.l -124(%fp),#15612
	unlk %fp
	rts
.L782:
	tst.b 66(%a3,%d6.l)
	jeq .L783
	move.b (%a2),%d1
	moveq #11,%d4
	mvz.b %d1,%d7
	cmp.l %d7,%d4
	jcs .L783
	move.b %d1,%d0
	lea us_ar,%a4
	ext.w %d0
	move.w %d0,%d2
	mulu.w #152,%d0
	mulu.w #56,%d2
	move.l %d2,%a0
	add.l #1118691636,%a0
	move.b (%a0),%d2
	move.w %d2,%a0
	moveq #127,%d2
	move.l %a0,%d4
	move.l %d0,%a0
	and.l %d2,%d4
	mvz.w #2531,%d2
	add.l #1092966778,%a0
	muls.l %d2,%d4
	add.l %d4,%a0
	move.b 1(%a0),%d2
	move.b (%a0),%d4
	lsl.l #2,%d2
	mvz.b %d4,%d0
	move.w %d4,%a1
	mvz.w (%a4,%d7.l*2),%d4
	and.l #768,%d2
	or.l %d0,%d2
	cmp.l %d4,%d2
	jeq .L783
	move.b %d1,-38(%fp)
	move.l %a1,%d0
	moveq #127,%d1
	and.l %d1,%d0
	move.w #17665,%a5
	moveq #-9,%d4
	pea 10.w
	move.l #-260222380,%a0
	pea -44(%fp)
	move.l %a0,-44(%fp)
	move.b %d0,-37(%fp)
	move.l %d2,%d0
	lsr.l #7,%d0
	move.w %a5,-40(%fp)
	move.b %d4,-35(%fp)
	move.b %d0,-36(%fp)
	jsr ext_try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L765
	move.w %d2,(%a4,%d7.l*2)
.L783:
	tst.b ext_dcap.l
	jeq .L836
	lea (%a3,%d6.l),%a0
	tst.b 66(%a0)
	jeq .L786
.L836:
	clr.l %d2
	jra .L787
.L786:
	tst.b %d3
	jlt .L836
	mvz.b 70(%a0),%d1
	mvz.b ext_dgen,%d0
	cmp.l %d1,%d0
	jne .L836
	move.l -80(%fp),%a1
	clr.l %d1
	clr.l %d2
	clr.l %d0
.L789:
	move.l %a1,%a0
	addq.l #2,%a1
	mvz.w 30(%a1),%d7
	mvz.w (%a0),%d4
	cmp.l %d7,%d4
	jeq .L788
	mov3q.l #1,%d7
	lsl.l %d0,%d7
	addq.l #1,%d1
	or.l %d7,%d2
.L788:
	addq.l #1,%d0
	moveq #16,%d4
	cmp.l %d0,%d4
	jne .L789
	tst.l %d2
	jne .L790
	clr.b %d5
	move.b %d5,67(%a3,%d6.l)
	jra .L765
.L790:
	moveq #13,%d7
	cmp.l %d1,%d7
	jlt .L836
.L787:
	move.l #-260222380,%a0
	moveq #127,%d0
	and.l %d3,%d0
	move.l %a0,-44(%fp)
	tst.l %d2
	jeq .L791
	move.b %d0,-38(%fp)
	moveq #127,%d0
	moveq #127,%d1
	moveq #14,%d3
	and.l %d2,%d0
	move.w #22017,%a1
	move.w #10,%a0
	move.b %d0,-37(%fp)
	move.l %d2,%d0
	lsr.l #7,%d0
	move.w %a1,-40(%fp)
	move.l -80(%fp),%a1
	and.l %d1,%d0
	move.b %d0,-36(%fp)
	move.l %d2,%d0
	lsr.l %d3,%d0
	move.b %d0,-35(%fp)
	clr.l %d0
.L793:
	mov3q.l #1,%d1
	lsl.l %d0,%d1
	and.l %d2,%d1
	tst.l %d1
	jeq .L792
	move.w 32(%a1),%d1
	moveq #127,%d4
	move.l %d1,%d3
	lsr.l #7,%d3
	and.l %d4,%d1
	and.l %d4,%d3
	move.b %d1,-43(%fp,%a0.l)
	move.b %d3,-44(%fp,%a0.l)
	addq.l #2,%a0
.L792:
	addq.l #1,%d0
	addq.l #2,%a1
	moveq #16,%d7
	cmp.l %d0,%d7
	jne .L793
.L794:
	mvz.b -81(%fp),%d4
	moveq #43,%d7
	cmp.l %d4,%d7
	jeq .L805
	mvz.b (%a2),%d0
	lea us_tag,%a1
	move.w (%a1,%d0.l*2),%d0
.L800:
	move.l %d0,%d1
	lsr.l #7,%d1
	moveq #127,%d3
	and.l %d3,%d0
	moveq #-9,%d4
	and.l %d3,%d1
	move.b %d0,-43(%fp,%a0.l)
	move.b %d4,-42(%fp,%a0.l)
	move.b %d1,-44(%fp,%a0.l)
	pea 3(%a0)
	pea -44(%fp)
	jsr ext_try_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L765
	clr.l %d0
.L801:
	move.l -80(%fp),%a0
	addq.l #1,%d0
	moveq #16,%d1
	move.w 32(%a0),(%a0)
	addq.l #2,%a0
	move.l %a0,-80(%fp)
	cmp.l %d0,%d1
	jne .L801
	tst.l %d2
	sne %d2
	clr.w %d3
	moveq #16,%d0
	lea ext_dgen,%a0
	move.b (%a0),70(%a3,%d6.l)
	neg.l %d2
	move.w %d3,66(%a3,%d6.l)
	move.b %d2,71(%a3,%d6.l)
	move.b %d0,68(%a3,%d6.l)
	jra .L765
.L791:
	tst.b 66(%a3,%d6.l)
	jeq .L795
	tst.b %d3
	jge .L803
	moveq #68,%d1
.L796:
	move.b %d1,-40(%fp)
	move.b %d0,-39(%fp)
	lea 64(%a3,%d6.l),%a0
	moveq #8,%d3
	move.w (%a0),-38(%fp)
.L797:
	lea -44(%fp,%d3.l),%a0
	move.l %d5,%a1
	clr.l %d0
	add.l #ext_state,%a1
.L799:
	move.w 32(%a1,%d0.l),%d1
	moveq #127,%d4
	addq.l #2,%d0
	addq.l #2,%a0
	move.l %d1,%d5
	lsr.l #7,%d5
	and.l %d4,%d1
	and.l %d4,%d5
	move.b %d1,-1(%a0)
	move.b %d5,-2(%a0)
	moveq #32,%d5
	cmp.l %d0,%d5
	jne .L799
	move.l %d3,%a0
	lea (32,%a0),%a0
	jra .L794
.L803:
	moveq #4,%d1
	jra .L796
.L795:
	tst.b %d3
	jge .L804
	moveq #67,%d1
.L798:
	move.b %d1,-40(%fp)
	move.b %d0,-39(%fp)
	mov3q.l #6,%d3
	jra .L797
.L804:
	moveq #3,%d1
	jra .L798
.L805:
	move.w #10689,%d0
	jra .L800
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
	jls .L837
	move.l %d0,ext_diag_max
.L837:
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
	move.l 28(%sp),%d4
	move.l %d4,%d0
	move.l 32(%sp),%d2
	add.l #-40,%d0
	cmp.l %d0,%d1
	jcs .L840
	mvz.w #6081,%d1
	btst %d0,%d1
	jeq .L840
	move.l 1073849312,%a0
	tst.l %a0
	jeq .L840
	clr.b %d0
	move.l %d4,-(%sp)
	move.b %d0,us+60
	jsr (%a0)
	addq.l #4,%sp
	moveq #40,%d1
	cmp.l %d4,%d1
	jne .L859
	mov3q.l #3,%d0
	cmp.l %d2,%d0
	jcc .L842
.L859:
	lea us_p2rec,%a0
	mvs.w (%a0,%d2.l*2),%d0
	jra .L839
.L840:
	move.l %d4,%d3
	moveq #16,%d1
	add.l #-35,%d3
	cmp.l %d3,%d1
	jcs .L842
	move.w .L845(%pc,%d3.l*2),%d0
	ext.l %d0
	jmp %pc@(2,%d0:l)
	.balignw 2,0x284c
	.swbeg	&17
.L845:
	.word .L850-.L845
	.word .L850-.L845
	.word .L850-.L845
	.word .L850-.L845
	.word .L850-.L845
	.word .L842-.L845
	.word .L842-.L845
	.word .L849-.L845
	.word .L848-.L845
	.word .L847-.L845
	.word .L846-.L845
	.word .L842-.L845
	.word .L842-.L845
	.word .L842-.L845
	.word .L842-.L845
	.word .L842-.L845
	.word .L844-.L845
.L848:
	move.l 1073849312,%a0
	tst.l %a0
	jeq .L851
	clr.b %d0
	pea 43.w
	move.b %d0,us+60
	jsr (%a0)
	addq.l #4,%sp
.L851:
	mov3q.l #-1,%d0
	jra .L839
.L847:
	lea ext_p2_order,%a0
.L874:
	move.l (%a0,%d2.l*4),%d0
.L839:
	movem.l (%sp),#7196
	lea (24,%sp),%sp
	rts
.L844:
	lea dsp_p2_order,%a0
	jra .L874
.L846:
	lea dsps_p2_order,%a0
	jra .L874
.L849:
	tst.l us+28
	jne .L852
.L842:
	clr.l %d0
	jra .L839
.L852:
	jsr md_old
	tst.l %d0
	jne .L842
.L855:
	mvz.b us+60,%d0
	lea us,%a0
	add.l #-34,%d4
	move.l (%a0,%d3.l*4),%a2
	cmp.l %d0,%d4
	jne .L853
	mvz.b us+61,%d1
	mvz.b (%a2),%d0
	cmp.l %d1,%d0
	jne .L853
.L857:
	subq.l #7,%d3
	tst.l %d3
	jne .L858
	tst.b (%a2)
	jne .L858
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	jcc .L859
	jra .L851
.L850:
	move.l %d3,-(%sp)
	jsr us_params
	addq.l #4,%sp
	tst.l %d0
	jne .L855
	jra .L839
.L853:
	lea us_p2rec,%a3
	moveq #8,%d4
	lea us_record,%a4
.L856:
	mvs.w (%a3)+,%d1
	pea us_text
	move.l %d4,-(%sp)
	move.l %d3,-(%sp)
	move.l %d1,-(%sp)
	jsr (%a4)
	addq.l #1,%d4
	lea (16,%sp),%sp
	moveq #16,%d0
	cmp.l %d4,%d0
	jne .L856
	move.l %d3,%d0
	addq.l #1,%d0
	move.b %d0,us+60
	move.b (%a2),us+61
	jra .L857
.L858:
	move.l %d2,%d0
	moveq #28,%d1
	addq.l #8,%d0
	muls.l %d1,%d0
	add.l %d0,%a2
	tst.b 36(%a2)
	jeq .L851
	tst.b 44(%a2)
	jne .L859
	jra .L851
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
	jcs .L879
	move.l %d2,%d0
	subq.l #4,%d0
	lsr.l #1,%d0
	jne .L877
	move.l %a2,-(%sp)
	jsr ext_view_machine
	move.l 20(%sp),-(%sp)
	move.l %d0,-(%sp)
	jsr us_page_record
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L877
	jge .L875
.L879:
	clr.l %d0
	jra .L875
.L877:
	move.l %d2,-(%sp)
	jsr 1074787700
	move.l 20(%sp),%d1
	addq.l #1,%d1
	mvz.w %d1,%d1
	addq.l #4,%sp
	move.l %d0,%a0
	move.l (%a0,%d1.l*4),%d0
.L875:
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
	moveq #16,%d0
	move.l 8(%sp),%d2
	add.l #-35,%d2
	cmp.l %d2,%d0
	jcs .L884
	move.w .L886(%pc,%d2.l*2),%d0
	ext.l %d0
	jmp %pc@(2,%d0:l)
	.balignw 2,0x284c
	.swbeg	&17
.L886:
	.word .L890-.L886
	.word .L890-.L886
	.word .L890-.L886
	.word .L890-.L886
	.word .L890-.L886
	.word .L884-.L886
	.word .L884-.L886
	.word .L889-.L886
	.word .L884-.L886
	.word .L888-.L886
	.word .L887-.L886
	.word .L884-.L886
	.word .L884-.L886
	.word .L884-.L886
	.word .L884-.L886
	.word .L884-.L886
	.word .L885-.L886
.L884:
	clr.l %d0
.L883:
	move.l (%sp)+,%d2
	rts
.L888:
	move.l #ext_p2_title,%d0
	jra .L883
.L885:
	move.l #dsp_p2_title,%d0
	jra .L883
.L887:
	move.l #dsps_p2_title,%d0
	jra .L883
.L889:
	jsr md_old
	tst.l %d0
	jne .L884
	mov3q.l #7,-(%sp)
	jsr us_params
	addq.l #4,%sp
	tst.l %d0
	jeq .L892
	move.l us+28,%d0
	move.l %d0,%a0
	tst.b 20(%a0)
	jeq .L892
.L900:
	add.l #20,%d0
	jra .L883
.L892:
	move.l #dd_long,%d0
	jra .L883
.L890:
	move.l %d2,-(%sp)
	jsr us_params
	addq.l #4,%sp
	tst.l %d0
	jeq .L883
	lea us,%a0
	move.l (%a0,%d2.l*4),%d0
	move.l %d0,%a0
	tst.b 20(%a0)
	jne .L900
	addq.l #4,%d0
	jra .L883
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
	jeq .L902
.L904:
	move.l %d2,-(%sp)
	jsr 1074787700
	addq.l #4,%sp
	move.l %d0,%a0
	move.l (%a0),%d0
.L901:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L902:
	move.l %a2,-(%sp)
	jsr ext_view_machine
	move.l %d0,-(%sp)
	jsr us_page_title
	addq.l #8,%sp
	tst.l %d0
	jeq .L904
	jra .L901
	.size	ext_page_title, .-ext_page_title
	.section	.us1
	.align	2
	.globl	us_param_record
	.type	us_param_record, @function
us_param_record:
	lea (-12,%sp),%sp
	moveq #16,%d1
	movem.l #28,(%sp)
	move.l 16(%sp),%d2
	move.l %d2,%d3
	move.l 20(%sp),%d4
	add.l #-17,%d3
	move.l %d4,%d0
	add.l #-35,%d0
	cmp.l %d0,%d1
	jcs .L909
	move.w .L911(%pc,%d0.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&17
.L911:
	.word .L915-.L911
	.word .L915-.L911
	.word .L915-.L911
	.word .L915-.L911
	.word .L915-.L911
	.word .L909-.L911
	.word .L909-.L911
	.word .L909-.L911
	.word .L914-.L911
	.word .L913-.L911
	.word .L912-.L911
	.word .L909-.L911
	.word .L909-.L911
	.word .L909-.L911
	.word .L909-.L911
	.word .L909-.L911
	.word .L910-.L911
.L913:
	add.l #405,%d2
.L908:
	move.l %d2,%d0
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L910:
	add.l #413,%d2
	jra .L908
.L912:
	tst.l %d3
	jeq .L923
	subq.l #2,%d3
	tst.l %d3
	jne .L917
.L918:
	mvz.w #441,%d2
	jra .L908
.L917:
	add.l #424,%d2
	jra .L908
.L914:
	mov3q.l #2,%d1
	cmp.l %d3,%d1
	jeq .L918
.L922:
	lea us_p2rec,%a0
	mvs.w (%a0,%d3.l*2),%d2
	jra .L908
.L915:
	move.l %d0,-(%sp)
	jsr us_params
	addq.l #4,%sp
	tst.l %d0
	jne .L922
.L919:
	tst.l 1073849312
	jeq .L921
	moveq #52,%d1
	cmp.l %d4,%d1
	jeq .L922
	move.l %d4,%d0
	mov3q.l #4,%d1
	add.l #-46,%d0
	cmp.l %d0,%d1
	jcc .L922
	moveq #40,%d0
	cmp.l %d4,%d0
	jne .L921
	mov3q.l #3,%d1
	cmp.l %d3,%d1
	jlt .L922
.L921:
	add.l #22,%d2
	jra .L908
.L909:
	moveq #42,%d0
	cmp.l %d4,%d0
	jne .L919
	jsr md_old
	tst.l %d0
	jne .L919
	jra .L922
.L923:
	moveq #39,%d2
	jra .L908
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
	jcc .L940
.L943:
	clr.l %d0
.L939:
	move.l (%sp)+,%d2
	rts
.L940:
	move.l %d0,%a0
	mov3q.l #7,%d2
	lea (-9,%a0),%a0
	cmp.l %a0,%d2
	jcs .L942
	moveq #52,%d2
	cmp.l %d1,%d2
	jcs .L943
	lsl.l #3,%d1
	move.l #1094563324,%a0
	add.l %d1,%d0
	move.l -36(%a0,%d0.l*4),%d0
	jra .L939
.L942:
	move.l %d0,%a0
	mov3q.l #7,%d2
	lea (-17,%a0),%a0
	cmp.l %a0,%d2
	jcs .L944
	move.l %d1,12(%sp)
	move.l %d0,8(%sp)
	move.l (%sp)+,%d2
	jra us_param_record
.L944:
	move.l #1094563156,%a0
	move.l (%a0,%d0.l*4),%d0
	jra .L939
	.size	ext_param_record, .-ext_param_record
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
	jcs .L946
	move.l %d0,12(%sp)
	move.l %a0,8(%sp)
	move.l (%sp)+,%d2
	jra jn_sysex
.L946:
	mov3q.l #7,%d2
	cmp.l %d0,%d2
	jge .L947
	mvz.b 5(%a0),%d2
	move.l %d2,%a1
	mov3q.l #1,%d2
	cmp.l %a1,%d2
	jne .L947
	moveq #26,%d2
	cmp.l %d1,%d2
	jne .L948
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr us_meta_in
.L951:
	addq.l #8,%sp
.L947:
	mov3q.l #1,%d0
	move.l (%sp)+,%d2
	rts
.L948:
	moveq #27,%d2
	cmp.l %d1,%d2
	jne .L949
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr us_list_in
	jra .L951
.L949:
	moveq #28,%d2
	cmp.l %d1,%d2
	jne .L950
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr us_knobs_in
	jra .L951
.L950:
	moveq #29,%d2
	cmp.l %d1,%d2
	jne .L947
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr us_slots_in
	jra .L951
	.size	us_sysex, .-us_sysex
	.align	2
	.globl	us_fetch
	.type	us_fetch, @function
us_fetch:
	lea (-32,%sp),%sp
	movem.l #31756,(%sp)
	move.l us+32,%a2
	move.l 36(%sp),%d3
	lea us,%a4
	tst.l %a2
	jeq .L952
	move.l (%a4,%d3.l*4),%a3
	tst.l %a3
	jeq .L952
	move.l %d3,%d1
	addq.l #1,%d1
	clr.l %d2
	lea us_commit,%a5
	move.l %d1,28(%sp)
	lea us_ask,%a6
.L957:
	mvz.b 3(%a2),%d0
	cmp.l #255,%d0
	jne .L954
	jsr (%a5)
.L954:
	mvz.b 40(%a4,%d3.l),%d1
	mvz.b (%a3),%d0
	cmp.l %d0,%d1
	jeq .L952
	tst.l %d2
	jeq .L955
	moveq #25,%d1
	cmp.l %d2,%d1
	jne .L956
.L955:
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l %d0,-(%sp)
	move.l 40(%sp),-(%sp)
	jsr (%a6)
	lea (16,%sp),%sp
.L956:
	pea 10000.w
	jsr 1074367512
	addq.l #1,%d2
	addq.l #4,%sp
	moveq #50,%d0
	cmp.l %d2,%d0
	jne .L957
.L952:
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
	moveq #42,%d2
	move.l 12(%sp),%a1
	move.l 8(%sp),%a0
	move.b 122(%a1),%d0
	mvz.b 123(%a1),%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	mvz.b 124(%a1),%d1
	cmp.l %d1,%d2
	jne .L969
	cmp.l #8781,%d0
	jne .L976
.L970:
	move.b 120(%a1),%d1
	mvz.b 121(%a1),%d2
	mvz.b %d1,%d1
	lsl.l #8,%d1
	or.l %d2,%d1
	cmp.l #1023,%d1
	jls .L974
	clr.l %d1
.L974:
	move.b %d1,109(%a0)
	lsr.l #8,%d1
	move.l %d0,%d2
	lsr.l #8,%d2
	lsl.l #6,%d1
	or.l %d2,%d1
	move.b %d1,110(%a0)
	move.b %d0,111(%a0)
	move.l (%sp)+,%d2
	rts
.L969:
	mvz.b 124(%a1),%d1
	mov3q.l #4,%d2
	add.l #-35,%d1
	cmp.l %d1,%d2
	jcs .L976
	tst.l %d0
	jne .L972
	move.b 110(%a1),%d0
	move.b 111(%a1),%d1
	or.l %d1,%d0
	tst.b %d0
	jne .L973
.L976:
	clr.l %d0
	jra .L970
.L973:
	move.b 110(%a1),%d0
	mvz.b 111(%a1),%d1
	lsl.l #8,%d0
	or.l %d1,%d0
	clr.b %d1
	and.l #16383,%d0
	move.b %d1,110(%a1)
	move.b %d1,111(%a1)
	move.l %d0,%d1
	lsr.l #8,%d1
	move.b %d1,122(%a1)
	move.b %d0,123(%a1)
	jra .L970
.L972:
	cmp.l #16383,%d0
	jhi .L976
	jra .L970
	.size	us_tag_load_c, .-us_tag_load_c
	.align	2
	.globl	us_tag_save_c
	.type	us_tag_save_c, @function
us_tag_save_c:
	move.l 8(%sp),%a0
	mov3q.l #4,%d1
	move.l 4(%sp),%a1
	mvz.b 110(%a0),%d0
	lsr.l #6,%d0
	move.b %d0,120(%a1)
	move.b 109(%a0),121(%a1)
	mvz.b 104(%a0),%d0
	add.l #-35,%d0
	cmp.l %d0,%d1
	jcc .L979
	mvz.b 104(%a0),%d0
	moveq #42,%d1
	cmp.l %d0,%d1
	jne .L978
.L979:
	move.b 110(%a0),%d0
	moveq #63,%d1
	and.l %d1,%d0
	move.b %d0,122(%a1)
	move.b 111(%a0),123(%a1)
.L978:
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
	jcs .L981
	mvz.b 104(%a0),%d0
	mov3q.l #4,%d1
	add.l #-35,%d0
	cmp.l %d0,%d1
	jcc .L983
	mvz.b 104(%a0),%d0
	moveq #42,%d1
	cmp.l %d0,%d1
	jne .L985
.L983:
	move.b 110(%a0),%d1
	mvz.b 111(%a0),%d0
	lsl.l #8,%d1
	or.l %d1,%d0
	and.l #16383,%d0
.L984:
	lea us_tag,%a0
	move.w %d0,(%a0,%a1.l*2)
.L981:
	rts
.L985:
	clr.w %d0
	jra .L984
	.size	us_tag_copy_c, .-us_tag_copy_c
	.section	.us3
	.align	2
	.globl	us_confirm
	.type	us_confirm, @function
us_confirm:
	clr.b %d1
	move.b us+63,%d0
	move.l %d2,-(%sp)
	move.b %d1,us+63
	tst.l 8(%sp)
	jeq .L987
	mvz.b %d0,%d0
	moveq #11,%d2
	subq.l #1,%d0
	cmp.l %d0,%d2
	jcs .L988
	move.l %d0,8(%sp)
.L999:
	move.l (%sp)+,%d2
	jra us_choose
.L987:
	move.l us+36,%d0
	tst.l %d0
	jeq .L986
	move.l %d0,%a0
	add.l #359,%d0
	lea (23,%a0),%a0
.L990:
	clr.b (%a0)
	lea (28,%a0),%a0
	cmp.l %a0,%d0
	jne .L990
.L986:
	move.l (%sp)+,%d2
	rts
.L988:
	move.b 1093765506,%d0
	moveq #11,%d2
	mvz.b %d0,%d1
	cmp.l %d1,%d2
	jlt .L986
	move.l #-2147423744,%a0
	mvz.b (%a0,%d1.l),%d2
	move.l %d2,%a0
	moveq #42,%d2
	cmp.l %a0,%d2
	jne .L986
	move.l us+36,%a0
	tst.l %a0
	jeq .L986
	ext.w %d0
	mulu.w #28,%d0
	add.l %d0,%a0
	tst.b 23(%a0)
	jeq .L991
	move.l %d1,8(%sp)
	jra .L999
.L991:
	moveq #9,%d0
	move.b %d0,3(%a0)
	jra .L986
	.size	us_confirm, .-us_confirm
	.section	.us5,"ax",@progbits
	.align	2
	.globl	us_step
	.type	us_step, @function
us_step:
	subq.l #4,%sp
	move.l %d2,-(%sp)
	move.l 16(%sp),%d0
	move.l 12(%sp),%d2
	cmp.l #1074610394,%d0
	jne .L1001
	move.l %d2,%d0
	addq.l #1,%d0
	move.b %d0,us+63
	moveq #11,%d0
	cmp.l %d2,%d0
	jcs .L1000
	move.l us+36,%a0
	tst.l %a0
	jeq .L1000
	move.l #-2147423744,%a1
	moveq #28,%d1
	move.b (%a1,%d2.l),%d0
	muls.l %d2,%d1
	moveq #42,%d2
	eor.l %d2,%d0
	tst.b %d0
	seq %d0
	neg.l %d0
	move.b %d0,23(%a0,%d1.l)
.L1000:
	move.l (%sp)+,%d2
	addq.l #4,%sp
	rts
.L1001:
	cmp.l #1074722430,%d0
	jne .L1000
	move.l 1073849316,%a1
	move.l %d2,-(%sp)
	move.l %a1,8(%sp)
	jsr us_choose
	addq.l #4,%sp
	move.l 4(%sp),%a1
	tst.l %a1
	jeq .L1000
	moveq #-13,%d0
	sub.l %d2,%d0
	move.l %d0,12(%sp)
	move.l (%sp)+,%d2
	addq.l #4,%sp
	jmp (%a1)
	.size	us_step, .-us_step
	.align	2
	.globl	us_loaded
	.type	us_loaded, @function
us_loaded:
	move.b us+64,%d0
	move.l us+36,%a0
	addq.l #1,%d0
	move.b %d0,us+64
	clr.b %d0
	move.b %d0,us+63
	tst.l %a0
	jeq .L1009
	addq.l #3,%a0
	moveq #12,%d0
.L1011:
	clr.b %d1
	clr.b (%a0)
	lea (28,%a0),%a0
	subq.l #1,%d0
	move.b %d1,-8(%a0)
	tst.l %d0
	jne .L1011
.L1009:
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
	jge .L1017
	clr.l %d3
.L1017:
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
	jcs .L1018
	move.l (%a2,%d4.l*4),%a0
	tst.l %a0
	jne .L1019
.L1018:
	clr.b %d2
.L1020:
	move.b 65(%a2),%d1
	mvz.b %d2,%d3
	mvz.b %d1,%d0
	cmp.l %d0,%d3
	jeq .L1021
	move.b %d2,65(%a2)
	tst.b %d1
	jeq .L1022
	move.l %d0,%a0
	pea -1(%a0)
	jsr us_names
	addq.l #4,%sp
.L1022:
	tst.b %d2
	jeq .L1021
	move.l %d3,%a0
	pea -1(%a0)
	jsr us_names
	addq.l #4,%sp
.L1021:
	tst.l 36(%a2)
	jeq .L1016
	clr.l %d4
	move.b 64(%a2),%d0
	clr.l %d2
	move.b %d0,31(%sp)
.L1028:
	move.l 36(%a2),%a0
	add.l %d4,%a0
	move.b 3(%a0),%d0
	mov3q.l #4,%d3
	move.l %d0,%d1
	subq.l #1,%d1
	mvz.b %d1,%d1
	cmp.l %d1,%d3
	jcs .L1024
	move.l 1100784300,%d1
	sub.l 24(%a0),%d1
	cmp.l #89999,%d1
	jhi .L1025
	mvz.b %d0,%d0
	move.l %d2,%a3
	add.l #-2147423744,%a3
	mvz.b (%a3),%d1
	move.l %d0,%d5
	add.l #34,%d5
	cmp.l %d1,%d5
	jeq .L1026
.L1025:
	clr.b %d6
	move.b %d6,3(%a0)
.L1024:
	addq.l #1,%d2
	add.l #28,%d4
	moveq #12,%d6
	cmp.l %d2,%d6
	jne .L1028
.L1016:
	movem.l (%sp),#3196
	lea (32,%sp),%sp
	rts
.L1019:
	move.w 34(%a0),%d1
	jeq .L1018
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
	jeq .L1018
	mvz.w %d1,%d1
	cmp.l %d1,%d0
	jeq .L1018
	add.l #-34,%d2
	jra .L1020
.L1026:
	subq.l #1,%d0
	move.l (%a2,%d0.l*4),%a1
	tst.l %a1
	jeq .L1024
	move.b (%a1),%d1
	jeq .L1024
	tst.b 46(%a2)
	jeq .L1027
	mvz.b 40(%a2,%d0.l),%d6
	mvz.b %d1,%d3
	cmp.l %d3,%d6
	jne .L1024
.L1027:
	mvz.b 1(%a1),%d3
	subq.l #2,%d3
	tst.l %d3
	jeq .L1024
	mvz.b %d1,%d1
	mvz.b 22(%a0),%d3
	cmp.l %d1,%d3
	jeq .L1024
	clr.b %d1
	move.b %d1,3(%a0)
	mvz.b 1(%a1),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L1024
	mvz.b 64(%a2),%d1
	mvz.b 31(%sp),%d3
	cmp.l %d1,%d3
	jne .L1024
	mvz.b (%a3),%d3
	cmp.l %d5,%d3
	jne .L1024
	move.l %d1,-(%sp)
	move.l %d0,-(%sp)
	move.l %d2,-(%sp)
	jsr us_defaults
	lea (12,%sp),%sp
	jra .L1024
	.size	us_tick3, .-us_tick3
	.section	.us2
	.align	2
	.globl	us_tick
	.type	us_tick, @function
us_tick:
	lea (-40,%sp),%sp
	movem.l #31804,(%sp)
	move.l 1100784300,%d2
	tst.b us+62.l
	jne .L1053
	jsr us_init
.L1053:
	cmp.l us_lblk.l,%d2
	jne .L1054
	tst.l %d2
	jne .L1055
.L1054:
	move.l us+32,%a0
	move.l %d2,us_lblk
	tst.l %a0
	jeq .L1056
	mvz.b 3(%a0),%d0
	cmp.l #255,%d0
	jne .L1056
	jsr us_commit
.L1056:
	tst.l us+36
	jeq .L1057
	jsr us_writeback
.L1057:
	jsr us_tick3
.L1055:
	lea us,%a5
	clr.l %d1
	lea us+47,%a6
	move.l %a6,%a0
	move.l %a5,%d4
.L1059:
	move.b (%a0)+,%d0
	jeq .L1058
	subq.l #1,%d0
	move.b %d0,-1(%a0)
.L1058:
	addq.l #1,%d1
	mov3q.l #5,%d0
	cmp.l %d1,%d0
	jne .L1059
	move.b us+52,%d0
	jeq .L1060
	subq.l #1,%d0
.L1092:
	move.b %d0,us+52
	jra .L1052
.L1060:
	move.b us+46,%d1
	sub.l %a2,%a2
	move.b %d1,39(%sp)
.L1070:
	move.l (%a5),%a3
	tst.l %a3
	jeq .L1071
	mvz.b (%a3),%d3
.L1062:
	tst.b (%a6)+
	jne .L1063
	tst.b 39(%sp)
	jne .L1064
.L1066:
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l %d3,-(%sp)
	pea 1(%a2)
	jsr us_ask
	lea (16,%sp),%sp
	tst.l %d0
	jne .L1065
.L1052:
	movem.l (%sp),#31804
	lea (40,%sp),%sp
	rts
.L1071:
	clr.l %d3
	jra .L1062
.L1064:
	mvz.b -8(%a6),%d0
	cmp.l %d0,%d3
	jne .L1066
	tst.l %a3
	jeq .L1063
	mvz.b 1(%a3),%d0
	subq.l #1,%d0
	tst.l %d0
	jne .L1063
	pea 255.w
	move.l %a3,-(%sp)
	jsr us_has_enum
	addq.l #8,%sp
	tst.l %d0
	jeq .L1063
	lea (36,%a3),%a4
	clr.l %d2
.L1069:
	tst.b (%a4)
	jeq .L1068
	mvz.b 2(%a4),%d0
	subq.l #2,%d0
	tst.l %d0
	jne .L1068
	tst.b 7(%a4)
	jeq .L1068
	move.l %d2,-(%sp)
	move.l %a3,-(%sp)
	jsr us_has_enum
	addq.l #8,%sp
	tst.l %d0
	jne .L1068
	move.l %d2,-(%sp)
	mov3q.l #1,-(%sp)
	move.l %d3,-(%sp)
	pea 1(%a2)
	jsr us_ask
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L1052
	moveq #50,%d0
	jra .L1091
.L1065:
	moveq #-56,%d0
.L1091:
	moveq #10,%d1
	move.b %d0,47(%a2,%d4.l)
	move.b %d1,us+52
	jra .L1052
.L1068:
	addq.l #1,%d2
	lea (28,%a4),%a4
	moveq #16,%d0
	cmp.l %d2,%d0
	jne .L1069
.L1063:
	addq.l #4,%a5
	addq.l #1,%a2
	mov3q.l #5,%d1
	cmp.l %a2,%d1
	jne .L1070
	moveq #10,%d0
	jra .L1092
	.size	us_tick, .-us_tick
	.section	.exto
	.align	2
	.globl	ext_ui_tick
	.type	ext_ui_tick, @function
ext_ui_tick:
	lea (-20,%sp),%sp
	movem.l #17412,(%sp)
	tst.b ext_desc_done.l
	jne .L1094
	jsr ext_descriptors
	jsr fm_descriptors
.L1094:
	jsr us_tick
	lea jn_mailbox,%a0
	move.b 11(%a0),%d0
	btst #0,%d0
	jne .L1093
	mvz.b 1307(%a0),%d2
	mvz.b %d0,%d1
	cmp.l %d2,%d1
	jeq .L1093
	move.l 12(%a0),12(%sp)
	move.l 16(%a0),16(%sp)
	mvz.b 11(%a0),%d2
	cmp.l %d2,%d1
	jne .L1093
	mvz.b 12(%sp),%d2
	move.b %d0,1307(%a0)
	moveq #11,%d0
	cmp.l %d2,%d0
	jcs .L1093
	move.l #-2147423744,%a0
	moveq #41,%d1
	mvz.b (%a0,%d2.l),%d0
	cmp.l %d0,%d1
	jne .L1093
	mov3q.l #1,%a6
	lea us_set,%a2
.L1096:
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
	jne .L1096
.L1093:
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
	jne .L1099
.L1101:
	move.l #us_unknown,%d0
.L1100:
	move.l %d0,-(%sp)
	pea 1(%a0)
	pea us_fmt_item
	pea us_lbuf
	jsr 1074365954
	lea (16,%sp),%sp
	move.l #us_lbuf,%d0
	rts
.L1099:
	tst.b (%a1)
	jeq .L1101
	tst.b 1(%a1)
	jeq .L1102
	lea us_lnames,%a1
	move.l (%a1,%a0.l*4),%d0
	jra .L1100
.L1102:
	move.l #us_none,%d0
	jra .L1100
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
.L1104:
	move.b (%a0,%a1.l),%d0
	jeq .L1105
	moveq #127,%d1
	addq.l #1,%a0
	and.l %d1,%d0
	move.b %d0,-22(%a0,%fp.l)
	moveq #20,%d0
	cmp.l %a0,%d0
	jne .L1104
.L1105:
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
	move.b us+66,%d3
	tst.l %a3
	jeq .L1111
	tst.b (%a3)
	jne .L1112
.L1111:
	clr.l %d6
.L1113:
	clr.b %d0
	lea us_wait,%a4
	move.b %d0,66(%a2)
	clr.l -(%sp)
	mov3q.l #-1,-(%sp)
	jsr (%a4)
	addq.l #8,%sp
	move.l %d0,%d4
	tst.l %d0
	jeq .L1114
	tst.l %d6
	jeq .L1115
	mvz.b 1(%a3),%d0
	subq.l #3,%d0
	tst.l %d0
	jne .L1116
	move.b 2(%a3),%d0
	btst #1,%d0
	jeq .L1116
	mvz.b %d3,%d3
	move.l %d2,%d0
	addq.l #1,%d0
	cmp.l %d3,%d0
	jne .L1130
.L1116:
	move.l %a3,%d6
	move.l #jn_mailbox+37,%d3
	mvz.b jn_mailbox+9,%d7
	clr.l -16(%fp)
	addq.l #4,%d6
	jra .L1118
.L1112:
	tst.b 1(%a3)
	sne %d6
	mvs.b %d6,%d6
	neg.l %d6
	jra .L1113
.L1119:
	add.l #10,%d3
	addq.l #1,-16(%fp)
.L1118:
	cmp.l -16(%fp),%d7
	jle .L1131
	move.l %d6,-(%sp)
	move.l %d3,-(%sp)
	jsr us_same
	addq.l #8,%sp
	tst.l %d0
	jeq .L1119
	move.l -16(%fp),%d6
	addq.l #1,%d6
.L1115:
	mvz.b jn_mailbox+9,%d0
	cmp.l %d0,%d6
	jge .L1132
	clr.l %d3
.L1117:
	clr.b %d0
	move.w #7681,%a0
	move.l #-260222380,%d1
	move.l %d2,%d5
	addq.l #1,%d5
	move.b %d5,-5(%fp)
	move.b %d3,-4(%fp)
	move.b %d6,-3(%fp)
	move.l %d1,-11(%fp)
	move.b %d0,58(%a2)
	moveq #-9,%d0
	move.w %a0,-7(%fp)
	lea jn_mailbox+20,%a0
	move.b (%a0),-2(%fp)
	move.b %d0,-1(%fp)
	cmp.l #170,%d4
	jle .L1120
.L1114:
	lea us_t_none,%a0
	move.l %a0,-16(%fp)
.L1121:
	move.l -16(%fp),-(%sp)
	move.l 8(%fp),-(%sp)
	jsr us_popup
	addq.l #8,%sp
	movem.l -52(%fp),#7420
	unlk %fp
	rts
.L1131:
	clr.l %d6
	jra .L1115
.L1130:
	mov3q.l #2,%d3
.L1171:
	clr.l %d6
	jra .L1117
.L1132:
	mov3q.l #1,%d3
	jra .L1171
.L1120:
	mvz.b jn_mailbox+19,%d0
	moveq #32,%d1
	cmp.l %d0,%d1
	jne .L1114
	mvz.b jn_mailbox+20,%d1
	mvz.b 45(%a2),%d0
	cmp.l %d1,%d0
	jne .L1114
	jsr ext_ui_lock
	tst.l %d0
	jeq .L1114
	pea 11.w
	pea -11(%fp)
	jsr us_assign_send
	addq.l #8,%sp
	mov3q.l #2,%d0
	cmp.l %d3,%d0
	jne .L1122
	move.b %d5,66(%a2)
.L1122:
	move.l %d4,-(%sp)
	move.l %d2,-(%sp)
	jsr (%a4)
	addq.l #8,%sp
	tst.l %d0
	jeq .L1114
	move.b 59(%a2),%d0
	mov3q.l #6,%d4
	mvz.b %d0,%d1
	cmp.l %d1,%d4
	jlt .L1133
	ext.w %d0
	mvz.w %d0,%d0
	lsl.l #4,%d0
	add.l #us_t_res,%d0
	move.l %d0,-16(%fp)
	tst.l %d1
	jeq .L1124
	cmp.l %d1,%d4
	jne .L1123
.L1124:
	clr.b %d0
	move.b %d0,66(%a2)
.L1123:
	clr.b %d0
	move.b %d0,47(%a2,%d2.l)
	tst.l %d3
	jne .L1126
	tst.l %d1
	jeq .L1127
	subq.l #6,%d1
	tst.l %d1
	jne .L1126
.L1127:
	move.l %d2,%d6
	clr.l %d4
	add.l #35,%d6
	move.l #-2147423744,%d5
	lea us_pend,%a4
.L1129:
	move.l %d3,%a0
	mvz.b (%a0,%d5.l),%d0
	cmp.l %d0,%d6
	jne .L1128
	move.l %d3,-(%sp)
	jsr (%a4)
	addq.l #4,%sp
	move.l 36(%a2),%a0
	tst.l %a0
	jeq .L1128
	tst.l %a3
	jeq .L1128
	move.b (%a3),22(%a0,%d4.l)
.L1128:
	addq.l #1,%d3
	add.l #28,%d4
	moveq #12,%d0
	cmp.l %d3,%d0
	jne .L1129
.L1126:
	move.l %d2,-(%sp)
	jsr us_fetch
	addq.l #4,%sp
	jra .L1121
.L1133:
	lea us_t_res+80,%a0
	move.l %a0,-16(%fp)
	jra .L1123
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
.L1173:
	move.l %a2,%a0
	clr.l %d0
.L1174:
	clr.l 12(%a0)
	clr.l 8(%a0)
	clr.l (%a0)
	clr.l 4(%a0)
	addq.l #1,%d0
	lea (16,%a0),%a0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L1174
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
.L1175:
	mvz.w %d2,%d0
	subq.l #1,%d2
	lsl.l #4,%d0
	pea (%a2,%d0.l)
	jsr 1075251654
	addq.l #4,%sp
	mov3q.l #-1,%d1
	cmp.l %d2,%d1
	jne .L1175
	addq.l #4,%a6
	moveq #20,%d0
	cmp.l %a6,%d0
	jne .L1173
	movem.l (%sp),#19516
	lea (92,%sp),%sp
	rts
	.size	us_menu_add, .-us_menu_add
	.section	.us3
	.align	2
	.globl	ext_steps
	.type	ext_steps, @function
ext_steps:
	move.l %d2,-(%sp)
	move.l 8(%sp),%d1
	cmp.l #390,%d1
	jne .L1180
	mvz.b md+4,%d0
	subq.l #1,%d0
	tst.l %d0
	jeq .L1189
.L1195:
	clr.l %d0
	jra .L1179
.L1180:
	cmp.l #408,%d1
	jeq .L1190
	cmp.l #449,%d1
	jeq .L1191
	cmp.l #416,%d1
	jeq .L1192
	cmp.l #453,%d1
	jeq .L1193
	cmp.l #433,%d1
	jeq .L1194
	cmp.l #444,%d1
	jne .L1183
#APP
| 2745 "ext.c" 1
	movel #P_DIAG,%d0
| 0 "" 2
#NO_APP
	tst.l %d0
	jne .L1195
	mov3q.l #5,%d0
.L1182:
	lea ext_step_tab,%a0
	mvz.w 2(%a0,%d0.l*4),%d0
.L1179:
	move.l (%sp)+,%d2
	rts
.L1190:
	clr.l %d0
	jra .L1182
.L1191:
	mov3q.l #1,%d0
	jra .L1182
.L1192:
	mov3q.l #2,%d0
	jra .L1182
.L1193:
	mov3q.l #3,%d0
	jra .L1182
.L1194:
	mov3q.l #4,%d0
	jra .L1182
.L1183:
	tst.b jn_mailbox+8.l
	jeq .L1184
	mvz.b jn_mailbox+9,%d0
	cmp.l #382,%d1
	jeq .L1185
	cmp.l #374,%d1
	jne .L1186
.L1185:
	tst.l %d0
	jne .L1187
.L1188:
	mvz.w #896,%d0
	jra .L1179
.L1187:
	cmp.l #374,%d1
	seq %d1
	mvz.b jn_mailbox+19,%d2
	neg.l %d1
	mvz.b %d1,%d1
	cmp.l %d2,%d1
	jne .L1188
	bset #9,%d0
	jra .L1179
.L1189:
	mvz.w #267,%d0
	jra .L1179
.L1184:
	cmp.l #382,%d1
	jeq .L1188
	cmp.l #374,%d1
	jeq .L1188
	clr.l %d0
.L1186:
	move.l %d0,-(%sp)
	move.l %d1,-(%sp)
	jsr ext_steps_us
	addq.l #8,%sp
	jra .L1179
	.size	ext_steps, .-ext_steps
	.section	.us4
	.align	2
	.globl	us_live
	.type	us_live, @function
us_live:
	subq.l #4,%sp
	tst.b us+63.l
	jeq .L1206
	move.l 8(%sp),-(%sp)
	jsr md_list_open
	addq.l #4,%sp
	tst.l %d0
	jne .L1207
	move.b %d0,us+63
.L1206:
	jsr sp_tick
.L1207:
	tst.b us+62.l
	jeq .L1212
	move.l us+32,%a0
	tst.l %a0
	jne .L1209
.L1211:
	clr.l %d0
.L1210:
	move.l %d0,(%sp)
	jsr (us_live_ask.constprop.0)
	jsr (md_tick.constprop.0)
	move.l (%sp),%d0
.L1205:
	addq.l #4,%sp
	rts
.L1209:
	mvz.b 3(%a0),%d0
	cmp.l #255,%d0
	jne .L1211
	jsr us_commit
	mov3q.l #1,%d0
	jra .L1210
.L1212:
	clr.l %d0
	jra .L1205
	.size	us_live, .-us_live
	.section	.usd,"a"
	.type	md_map, @object
	.size	md_map, 44
md_map:
	.base64	"AAAABw=="
	.base64	"AQAQBw=="
	.base64	"AgAgBw=="
	.base64	"AwAwBw=="
	.base64	"BABABw=="
	.base64	"BQBQBw=="
	.base64	"BgBgBw=="
	.base64	"BwBwBw=="
	.base64	"FVYoAw=="
	.base64	"FlYyAw=="
	.base64	"G1ZjBg=="
	.type	md_defaults, @object
	.size	md_defaults, 240
md_defaults:
	.base64	"AEAgfyMOQBg="
	.base64	"GzwOTwAFfx0="
	.base64	"GTJ/bwUETwA="
	.base64	"Mih/GHMkVwg="
	.base64	"QwoIDyYZOwA="
	.string	"6=\\8\021p*"
	.base64	"GjYaLwBWXUs="
	.string	"@H`\\- @"
	.string	"@#d"
	.base64	"f2QAAA=="
	.string	"@@\n(ZPP"
	.base64	"FBR/f39QWkA="
	.base64	"AEB/AAAAAAA="
	.string	"Z"
	.string	"H`@"
	.zero	2
	.string	"Z0@@@@"
	.string	""
	.base64	"QEZgIH9/QH8="
	.base64	"QEZaIH9/QH8="
	.base64	"QEZkHn9/PH8="
	.string	"@@"
	.base64	"AAAAAAA="
	.base64	"IwcAQH8AZFo="
	.string	"F\0312\036@ "
	.string	""
	.string	"2d\007\177(@"
	.ascii	"Z"
	.string	"2"
	.string	"2"
	.base64	"AAAAAA=="
	.base64	"ZDJ/fwAAAAA="
	.base64	"AAgAfwAAAAA="
	.string	"2<\b\177"
	.base64	"AAAA"
	.base64	"fwAAfwB/AAA="
	.string	"  "
	.base64	"AEBAQEA="
	.string	"@ @"
	.string	"@"
	.zero	2
	.string	"@  d"
	.base64	"AAAA"
	.ascii	"<A)>[,8:"
	.globl	sp
	.section	.usr,"aw"
	.align	4
	.type	sp, @object
	.size	sp, 12
sp:
	.zero	12
	.section	.usd
	.align	2
	.type	ext_step_tab, @object
	.size	ext_step_tab, 24
ext_step_tab:
	.word	408
	.word	273
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
	.globl	us_ar
	.section	.usr
	.align	2
	.type	us_ar, @object
	.size	us_ar, 24
us_ar:
	.zero	24
	.globl	us_tag
	.align	2
	.type	us_tag, @object
	.size	us_tag, 26
us_tag:
	.zero	26
	.align	4
	.type	us_lblk, @object
	.size	us_lblk, 4
us_lblk:
	.zero	4
	.globl	ext_smute
	.type	ext_smute, @object
	.size	ext_smute, 1
ext_smute:
	.zero	1
	.section	.usd
	.type	us_flag_tab, @object
	.size	us_flag_tab, 18
us_flag_tab:
	.string	"PX`hpH\b@ "
	.base64	"ICg4eBiAEDA="
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
	.size	us_snames, 32
us_snames:
	.long	us_s1
	.long	us_s2
	.long	us_s3
	.long	us_s4
	.long	us_s5
	.long	0
	.long	0
	.long	dd_short
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
	.globl	md_wr
	.type	md_wr, @object
	.size	md_wr, 1
md_wr:
	.zero	1
	.globl	md
	.align	2
	.type	md, @object
	.size	md, 6
md:
	.zero	6
	.globl	md_rec
	.align	2
	.type	md_rec, @object
	.size	md_rec, 96
md_rec:
	.zero	96
	.globl	us
	.align	4
	.type	us, @object
	.size	us, 68
us:
	.zero	68
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
	.section	.usr
	.align	4
	.type	jn_mailbox, @object
	.size	jn_mailbox, 1308
jn_mailbox:
	.zero	1308
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
	.long	416
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
	.size	dd_short, 3
dd_short:
	.string	"MD"
	.globl	dd_long
	.type	dd_long, @object
	.size	dd_long, 3
dd_long:
	.string	"MD"
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
	.globl	ext_dgen
	.section	.exts
	.type	ext_dgen, @object
	.size	ext_dgen, 1
ext_dgen:
	.zero	1
	.globl	ext_dcap
	.type	ext_dcap, @object
	.size	ext_dcap, 1
ext_dcap:
	.zero	1
	.globl	ext_state
	.align	2
	.type	ext_state, @object
	.size	ext_state, 576
ext_state:
	.zero	576
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
| 909 "ext.c" 1
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
