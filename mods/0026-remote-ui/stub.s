| Mod 0026 - remote UI: the Rytm as a terminal for Sidecar-drawn pages (M1).
| GENERATED from rui.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit rui.c.
#NO_APP
	.file	"rui.c"
	.text
#APP
	  .text
  .globl pm_menu_det, pm_label, pm_action, pm_icon
  .align 2
pm_menu_det:
  move.l %d6,-(%sp)
  jsr pm_menu_add
  addq.l #4,%sp
  lea 24(%sp),%sp
  tst.l %d6
  jmp 0x400cb5c4
  .align 2
pm_label:
  link.w %fp,#-4
  move.l %a2,-(%sp)
  move.l %a0,%a2
  pea -1(%fp)
  pea pm_text
  move.l %a2,-(%sp)
  jsr 0x401bcd4c
  lea 12(%sp),%sp
  move.l %a2,%d0
  move.l (%sp)+,%a2
  unlk %fp
  rts
  .align 2
pm_action:
  move.l 4(%sp),%a0
  move.l (%a0),%a0
  move.l (%a0),-(%sp)
  jsr pm_pick
  addq.l #4,%sp
  rts
  .align 2
pm_icon:
  rts

	  .text
  .globl cu_setm_det
  .align 2
cu_setm_det:
  move.l 12(%sp),-(%sp)
  move.l 12(%sp),-(%sp)
  jsr cu_prep
  addq.l #8,%sp
  link.w %fp,#-40
  movem.l %d2-%d6/%a2-%a4,(%sp)
  jmp 0x400bd156

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

	  .text
  .globl rui_rec_det
  .align 2
rui_rec_det:
  move.l 20(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  jsr rui_rec_note
  lea 12(%sp),%sp
  tst.l %d0
  beq.s 1f
  rts
1:
  link.w %fp,#-48
  moveq #12,%d0
  jmp 0x400b45e6

	  .text
  .globl sq_fire_det, sq_end_det
  .align 2
sq_fire_det:
  move.l 12(%sp),-(%sp)
  move.l 12(%sp),-(%sp)
  move.l 12(%sp),-(%sp)
  jsr sq_fire
  lea 12(%sp),%sp
  lea -88(%sp),%sp
  move.l 96(%sp),%d0
  jmp 0x4009a9c4
  .align 2
sq_end_det:
  jsr sq_end
  movem.l (%sp),%d0-%fp
  lea 76(%sp),%sp
  jmp 0x4009bfa6

	  .text
  .globl ed_pcopy_det
  .align 2
ed_pcopy_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_pcopy_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #1,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_pcopy_orig:
  .short 0x4e56,0xffdc,0x48d7,0x1c0c
  jmp 0x400abde8
  .globl ed_ppaste_det
  .align 2
ed_ppaste_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_ppaste_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #2,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_ppaste_orig:
  .short 0x4e56,0xffd4,0x48d7,0x3c04
  jmp 0x400abffe
  .globl ed_pclear_det
  .align 2
ed_pclear_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_pclear_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #3,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_pclear_orig:
  .short 0x4e56,0xffd8,0x48d7,0x3c0c
  jmp 0x400ac124
  .globl ed_pundo_det
  .align 2
ed_pundo_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_pundo_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #4,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_pundo_orig:
  .short 0x4e56,0xffe4,0x48d7,0x0c04
  jmp 0x400abec8
  .globl ed_tcopy_det
  .align 2
ed_tcopy_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_tcopy_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #5,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_tcopy_orig:
  .short 0x4e56,0xffd8,0x48d7,0x3c0c
  jmp 0x400c2f04
  .globl ed_tpaste_det
  .align 2
ed_tpaste_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_tpaste_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #6,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_tpaste_orig:
  .short 0x4e56,0xffc4,0x48d7,0x3c7c
  jmp 0x400c475c
  .globl ed_tclear_det
  .align 2
ed_tclear_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_tclear_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #7,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_tclear_orig:
  .short 0x4e56,0xffd4,0x48d7,0x3c1c
  jmp 0x400c4952
  .globl ed_tundo_det
  .align 2
ed_tundo_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_tundo_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #8,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_tundo_orig:
  .short 0x4e56,0xffd0,0x48d7,0x3c3c
  jmp 0x400c3810
  .globl ed_gcopy_det
  .align 2
ed_gcopy_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_gcopy_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #9,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_gcopy_orig:
  .short 0x4e56,0xffd8,0x48d7,0x3c0c
  jmp 0x400c4628
  .globl ed_gpaste_det
  .align 2
ed_gpaste_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_gpaste_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #10,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_gpaste_orig:
  .short 0x4e56,0xffb8,0x48d7,0x3cfc
  jmp 0x400c334a
  .globl ed_gclear_det
  .align 2
ed_gclear_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_gclear_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #11,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_gclear_orig:
  .short 0x4e56,0xffc8,0x48d7,0x3cfc
  jmp 0x400c4456
  .globl ed_gundo_det
  .align 2
ed_gundo_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_gundo_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #12,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_gundo_orig:
  .short 0x4e56,0xffc8,0x48d7,0x3cfc
  jmp 0x400c3602
  .globl ed_rcopy_det
  .align 2
ed_rcopy_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_rcopy_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #13,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_rcopy_orig:
  .short 0x4e56,0xff84,0x48d7,0x3cfc
  jmp 0x400c4ad4
  .globl ed_rpaste_det
  .align 2
ed_rpaste_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_rpaste_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #14,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_rpaste_orig:
  .short 0x4e56,0xff90,0x41ee,0xffb8
  jmp 0x400c3972
  .globl ed_preload_det
  .align 2
ed_preload_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_preload_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #16,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_preload_orig:
  .short 0x4fef,0xfff4,0x48d7,0x0c04
  jmp 0x400af5e8
  .globl ed_psave_det
  .align 2
ed_psave_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_psave_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #17,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_psave_orig:
  .short 0x4fef,0xfff4,0x48d7,0x040c
  jmp 0x400ae590
  .globl ed_treload_det
  .align 2
ed_treload_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_treload_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #18,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_treload_orig:
  .short 0x4fef,0xffe8,0x48d7,0x3c0c
  jmp 0x400af652
  .globl ed_tsave_det
  .align 2
ed_tsave_det:
  lea -24(%sp),%sp
  move.l 28(%sp),(%sp)
  move.l 32(%sp),4(%sp)
  move.l 36(%sp),8(%sp)
  move.l 40(%sp),12(%sp)
  move.l 44(%sp),16(%sp)
  move.l 48(%sp),20(%sp)
  jsr ed_tsave_orig
  lea 24(%sp),%sp
  move.l %d0,-(%sp)
  move.l %d0,-(%sp)
  move.l 16(%sp),-(%sp)
  move.l 16(%sp),-(%sp)
  move.l #19,-(%sp)
  jsr ed_report
  lea 16(%sp),%sp
  move.l (%sp)+,%d0
  rts
ed_tsave_orig:
  .short 0x4fef,0xffe8,0x48d7,0x3c0c
  jmp 0x400ae61c

	  .text
  .globl pin_det
  .align 2
pin_det:
  move.l 4(%sp),-(%sp)
  jsr pin_frame
  addq.l #4,%sp
  .short 0x4fef,0xffec,0x7001
  jmp 0x4007a53e

	  .text
  .globl pj_write_det, pj_delete_det, pj_copy_det, pj_save_det, pj_act_det
  .globl kt_save_det, kt_reload_det, kt_all_det
  .align 2
pj_write_det:
  move.l 8(%sp),-(%sp)
  move.l 4(%sp),-(%sp)
  jsr pj_write
  addq.l #8,%sp
  .short 0x4fef,0xffe0,0x727f
  jmp 0x40034e9e
  .align 2
pj_delete_det:
  move.l 8(%sp),-(%sp)
  jsr pj_delete
  addq.l #4,%sp
  .short 0x2f02,0x70ff,0x242f,0x000c
  jmp 0x40034a5c
  .align 2
pj_copy_det:
  move.l 8(%sp),-(%sp)
  jsr pj_copy
  addq.l #4,%sp
  .short 0x4e56,0xffe4,0x48d7,0x040c
  jmp 0x40035034
  .align 2
pj_save_det:
  move.l 8(%sp),-(%sp)
  jsr pj_save
  addq.l #4,%sp
  .short 0x4fef,0xffd0,0x48d7,0x7c1c
  jmp 0x400b0740
  .align 2
pj_act_det:
  move.l 8(%sp),-(%sp)
  move.l 4(%sp),-(%sp)
  move.l 12(%sp),-(%sp)
  jsr pj_activate
  lea 12(%sp),%sp
  .short 0x7339,0x405c,0x8e4d
  jmp 0x400fa69a
  .align 2
kt_save_det:
  move.l 0x800067b8,-(%sp)
  lea -16(%sp),%sp
  move.l 24(%sp),(%sp)
  move.l 28(%sp),4(%sp)
  move.l 32(%sp),8(%sp)
  move.l 36(%sp),12(%sp)
  jsr kt_save_orig
  lea 16(%sp),%sp
  move.l %d0,-(%sp)
  move.l 4(%sp),-(%sp)
  move.l 20(%sp),-(%sp)
  jsr kt_saved
  addq.l #8,%sp
  move.l (%sp)+,%d0
  addq.l #4,%sp
  rts
kt_save_orig:
  .short 0x4fef,0xffc4,0x48d7,0x7cfc
  jmp 0x400b11a4
  .align 2
kt_reload_det:
  move.l 8(%sp),-(%sp)
  move.l 8(%sp),-(%sp)
  jsr kt_reload_orig
  addq.l #8,%sp
  move.l %d0,-(%sp)
  pea 0x42
  jsr kt_reloaded
  addq.l #4,%sp
  move.l (%sp)+,%d0
  rts
kt_reload_orig:
  .short 0x4fef,0xffec,0x48d7,0x0c1c
  jmp 0x400af0da
  .align 2
kt_all_det:
  move.l 8(%sp),-(%sp)
  move.l 8(%sp),-(%sp)
  jsr kt_all_orig
  addq.l #8,%sp
  move.l %d0,-(%sp)
  pea 0x44
  jsr kt_reloaded
  addq.l #4,%sp
  move.l (%sp)+,%d0
  rts
kt_all_orig:
  .short 0x4fef,0xffe4,0x48d7,0x3c1c
  jmp 0x400b1322

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
	.type	txsx_wait, @function
txsx_wait:
	move.l txsx_test_on,%d0
	tst.l %d0
	jeq .L6
	move.l st+8,%d1
	sub.l txsx_test_end,%d1
	jmi .L6
	clr.l txsx_test_on
	clr.l %d0
.L6:
	move.l 1094562372,%d1
	or.l %d0,%d1
	jne .L8
	clr.l txsx_on
	clr.l txsx_gap
.L13:
	clr.l %d0
.L4:
	rts
.L8:
	tst.l txsx_on
	jeq .L10
	tst.l txsx_gap
	jeq .L11
	tst.l %d0
	jne .L11
.L10:
	lea st+8,%a0
	mov3q.l #1,txsx_on
	move.l (%a0),txsx_t0
	clr.l txsx_gap
.L12:
	mov3q.l #1,%d0
	jra .L4
.L11:
	move.l st+8,%d0
	moveq #39,%d1
	sub.l txsx_t0,%d0
	cmp.l %d0,%d1
	jge .L12
	addq.l #1,txsx_over
	jra .L13
	.size	txsx_wait, .-txsx_wait
	.align	2
	.type	mr_vb, @function
mr_vb:
	move.l %d2,-(%sp)
	moveq #17,%d2
	move.l 12(%sp),%d0
	move.l %d0,%d1
	add.l #-35,%d1
	cmp.l %d1,%d2
	jcc .L18
.L20:
	moveq #127,%d0
.L17:
	move.l (%sp)+,%d2
	rts
.L18:
	mvz.w %d0,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #1076429692,%a0
	move.l 1076429868,%d0
	cmp.l (%a0),%d0
	jne .L20
	lea mr_flag,%a0
	moveq #127,%d2
	move.b (%a0,%d1.l),%d0
	mvz.b %d0,%d1
	cmp.l %d1,%d2
	jeq .L17
	move.l 8(%sp),%d1
	lea mr_voice,%a0
	move.b (%a0,%d1.l),%d1
	or.l %d1,%d0
	jra .L17
	.size	mr_vb, .-mr_vb
	.align	2
	.type	sv_word, @function
sv_word:
	moveq #127,%d0
	and.l -2147457096,%d0
	lea (-20,%sp),%sp
	move.l 28(%sp),%d1
	movem.l #1084,(%sp)
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l #1092966707,%a0
	mvz.w %d1,%d0
	lea (%a0,%d0.l*2),%a2
	move.w 26(%sp),%d0
	mulu.w #152,%d0
	add.l %d0,%a2
	mov3q.l #7,%d0
	cmp.l %d1,%d0
	jlt .L25
	move.l sv+80,%a0
	tst.l %a0
	jeq .L25
	move.l (%a0),%d2
	move.l %d2,%a1
	move.l %d1,-(%sp)
	move.l %a0,-(%sp)
	move.l 156(%a1),%a0
	jsr (%a0)
	addq.l #8,%sp
	move.l %d0,%d4
	tst.l %d0
	jle .L25
	mov3q.l #-1,-(%sp)
	move.l %d0,-(%sp)
	move.l %d2,%a1
	move.l 84(%a1),%a0
	move.l sv+80,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	move.l %d0,%d2
	move.l %d0,%d3
	asr.l #8,%d2
	move.l #1481856080,%d0
	cmp.l 1073848892.l,%d0
	jne .L26
	move.l 1073848896,%a0
	mov3q.l #2,%d5
	move.l %d4,-(%sp)
	jsr (%a0)
	move.b (%a2),%d4
	addq.l #4,%sp
	move.l %d0,%d1
	asr.l #8,%d1
	move.l %d1,%a1
	subq.l #1,%d1
	move.w %d4,%a0
	cmp.l %d1,%d5
	jcs .L26
	move.l %d0,%d4
	mvz.b %d4,%d4
	tst.b %d0
	jeq .L26
	move.l %d2,%d1
	move.l %a0,%d0
	moveq #127,%d2
	and.l %d2,%d0
	mvz.b %d1,%d1
	mov3q.l #1,%d2
	cmp.l %a1,%d2
	jne .L27
	move.l %d0,%d2
	muls.l %d4,%d2
	asr.l #7,%d2
	cmp.l %d1,%d2
	jne .L42
.L28:
	lsl.l #7,%d0
.L44:
	mvz.b 1(%a2),%d1
	lsr.l #1,%d1
	jra .L43
.L27:
	cmp.l %d1,%d0
	jeq .L28
	mov3q.l #3,%d4
	cmp.l %a1,%d4
	jne .L34
	move.l %d3,%d0
	asr.l #1,%d0
	moveq #112,%d5
	and.l %d5,%d0
.L32:
	moveq #127,%d2
	cmp.l %d1,%d2
	jlt .L35
	lsl.l #7,%d1
.L43:
	or.l %d1,%d0
	jra .L24
.L42:
	mvs.w %d1,%d1
	move.l %d4,%a0
	lsl.l #7,%d1
	lea -1(%a0,%d1.l),%a0
	move.l %a0,%d1
	divs.l %d4,%d1
.L34:
	clr.l %d0
	jra .L32
.L35:
	move.w #16256,%d1
	jra .L43
.L26:
	move.l %d2,%d0
	asr.l #1,%d3
	lsl.l #7,%d0
	moveq #127,%d4
	and.l %d4,%d3
	and.l #16256,%d0
	or.l %d3,%d0
.L24:
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L25:
	move.b (%a2),%d0
	lsl.l #7,%d0
	and.l #16256,%d0
	jra .L44
	.size	sv_word, .-sv_word
	.align	2
	.type	splash_end, @function
splash_end:
	tst.l st+972
	jeq .L45
	moveq #1,%d0
	lea (8,%sp),%a0
	move.l (%a0),st+988
	move.l 4(%sp),%a0
	clr.l st+972
	move.b %d0,32(%a0)
.L45:
	rts
	.size	splash_end, .-splash_end
	.align	2
	.type	uart_byte, @function
uart_byte:
	move.b ps_left,%d0
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.b 15(%sp),%d2
	addq.l #1,uart_bytes
	tst.b %d0
	jne .L48
	move.b %d0,ps_pos
	mvz.b %d2,%d0
	move.b %d2,ps_hdr
	mov3q.l #1,%d3
	move.l %d0,%d1
	lsr.l #4,%d1
	cmp.l %d1,%d3
	jeq .L65
	moveq #11,%d3
	cmp.l %d1,%d3
	jeq .L50
	tst.l %d1
	jne .L66
.L69:
	mov3q.l #1,%d0
	jra .L49
.L50:
	cmp.l #179,%d0
	jhi .L51
.L52:
	mov3q.l #3,%d0
.L49:
	subq.l #1,%d0
	move.b %d0,ps_left
.L53:
	move.b %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L51:
	cmp.l #182,%d0
	jeq .L52
	cmp.l #180,%d0
	jeq .L67
	cmp.l #181,%d0
	jeq .L68
	cmp.l #184,%d0
	jeq .L69
.L66:
	mov3q.l #2,%d0
	jra .L49
.L65:
	moveq #10,%d0
	jra .L49
.L67:
	mov3q.l #6,%d0
	jra .L49
.L68:
	mov3q.l #5,%d0
	jra .L49
.L48:
	subq.l #1,%d0
	move.b %d0,ps_left
	move.b ps_hdr,%d0
	move.b ps_pos,%d1
	move.l %d0,%a0
	lea (-32,%a0),%a0
	addq.l #1,%d1
	move.w %a0,%d3
	move.b %d1,ps_pos
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #3,%d3
	cmp.l %a0,%d3
	jcs .L54
	and.l %d3,%d0
	lea shs,%a0
	move.b %d2,(%a0,%d0.l)
	jra .L53
.L54:
	move.l %d0,%a0
	lea (80,%a0),%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #4,%d3
	cmp.l %a0,%d3
	jcs .L53
	mvz.b %d1,%d1
	mov3q.l #1,%d3
	cmp.l %d1,%d3
	jne .L56
	move.b %d2,ps_id
	jra .L53
.L56:
	move.b ps_id,%d3
	move.w %d3,%a0
	mvz.b %d3,%d3
	move.l %d3,%a1
	moveq #55,%d3
	cmp.l %a1,%d3
	jne .L57
	mvz.b %d0,%d3
	cmp.l #180,%d3
	jne .L58
	move.l %d1,%d0
	subq.l #2,%d0
.L59:
	lea sht,%a0
	move.b %d2,(%a0,%d0.l)
	tst.b ovt_on.l
	jeq .L53
	move.b ovt_col,%d2
	addq.l #1,uart_sub
	jra .L53
.L58:
	mov3q.l #3,%d1
	and.l %d1,%d0
	jra .L59
.L57:
	lea (-40,%a0),%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #3,%d3
	cmp.l %a0,%d3
	jcs .L60
	move.w #43,%a0
	mvz.b %d0,%d3
	sub.l %a1,%a0
	cmp.l #180,%d3
	jne .L61
	subq.l #2,%d1
.L62:
	move.l %a0,%d0
	lsl.l #2,%d0
	move.l %d0,%a1
	add.l #shp,%a1
	mvz.b ovp_on,%d0
	move.b %d2,(%a1,%d1.l)
	move.l %a0,%d1
	btst %d1,%d0
	jeq .L53
	addq.l #1,uart_sub
	lea ovp_col,%a1
.L82:
	move.b (%a0,%a1.l),%d2
	jra .L53
.L61:
	mov3q.l #3,%d1
	and.l %d0,%d1
	jra .L62
.L60:
	moveq #15,%d3
	cmp.l %a1,%d3
	jcs .L53
	mvz.b %d0,%d3
	cmp.l #180,%d3
	jne .L63
	subq.l #2,%d1
.L64:
	move.l %a1,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #sh,%a0
	move.b %d2,(%a0,%d1.l)
	tst.b ov_on.l
	jeq .L53
	addq.l #1,uart_sub
	lea ov_col,%a0
	jra .L82
.L63:
	mov3q.l #3,%d1
	and.l %d0,%d1
	jra .L64
	.size	uart_byte, .-uart_byte
	.align	2
	.type	blk4, @function
blk4:
	move.l %d2,-(%sp)
	moveq #21,%d2
	move.l 12(%sp),%d1
	move.l %d1,%d0
	lsr.l %d2,%d0
	moveq #127,%d2
	move.l 8(%sp),%a0
	and.l %d2,%d0
	moveq #14,%d2
	move.b %d0,(%a0)
	move.l %d1,%d0
	lsr.l %d2,%d0
	moveq #127,%d2
	and.l %d2,%d0
	move.b %d0,1(%a0)
	move.l %d1,%d0
	lsr.l #7,%d0
	and.l %d2,%d1
	and.l %d2,%d0
	move.b %d1,3(%a0)
	move.b %d0,2(%a0)
	move.l %a0,%d0
	addq.l #4,%d0
	move.l (%sp)+,%d2
	rts
	.size	blk4, .-blk4
	.align	2
	.type	sq_event, @function
sq_event:
	move.l sq+344,%d0
	mov3q.l #3,%d1
	move.l %a2,-(%sp)
	cmp.l %d0,%d1
	jcc .L85
	addq.l #1,sq+384
.L84:
	move.l (%sp)+,%a2
	rts
.L85:
	lsl.l #4,%d0
	move.w #11521,%a1
	move.l %d0,%a2
	add.l #sq+276,%a2
	move.w %a1,4(%a2)
	move.b 11(%sp),6(%a2)
	move.b 15(%sp),7(%a2)
	move.l #-260222380,(%a2)
	mov3q.l #2,%d0
	cmp.l 20(%sp),%d0
	jeq .L87
	move.l %a2,%d0
	addq.l #8,%d0
.L88:
	move.l 24(%sp),-(%sp)
	move.l %d0,-(%sp)
	jsr blk4
	addq.l #8,%sp
	move.l %d0,%a0
	move.b #-9,(%a0)+
	move.l sq+344,%d0
	move.l %d0,%d1
	addq.l #1,%d1
	move.l %d1,sq+344
	sub.l %a2,%a0
	move.w %a0,%d1
	add.l #sq,%d0
	move.l %d0,%a1
	move.b %d1,340(%a1)
	jra .L84
.L87:
	move.l %a2,%d0
	add.l #9,%d0
	move.b 19(%sp),8(%a2)
	jra .L88
	.size	sq_event, .-sq_event
	.align	2
	.type	sq_grid, @function
sq_grid:
	move.l 1100949720,%a0
	move.l %a0,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L92
	tst.b 353(%a0)
	jeq .L92
	tst.b 360(%a0)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L89:
	rts
.L92:
	clr.l %d0
	jra .L89
	.size	sq_grid, .-sq_grid
	.align	2
	.type	sq_forget, @function
sq_forget:
	clr.l sq
	clr.l sq+4
	clr.l pin
	clr.l pin+4
	clr.l sq+8
	clr.l sq+404
	clr.l sq+408
	rts
	.size	sq_forget, .-sq_forget
	.align	2
	.type	ls_banked, @function
ls_banked:
	move.l 4(%sp),%d1
	mov3q.l #6,%d0
	add.l #-46,%d1
	cmp.l %d1,%d0
	jcs .L97
	moveq #75,%d0
	lsr.l %d1,%d0
	mov3q.l #1,%d1
	and.l %d1,%d0
.L96:
	rts
.L97:
	clr.l %d0
	jra .L96
	.size	ls_banked, .-ls_banked
	.align	2
	.type	ls_dsps, @function
ls_dsps:
	move.l %d2,-(%sp)
	moveq #11,%d2
	move.b 1093765506,%d1
	mvz.b %d1,%d0
	move.l %d0,%a1
	cmp.l %d0,%d2
	jge .L99
.L101:
	clr.l %d0
.L98:
	move.l (%sp)+,%d2
	rts
.L99:
	mvz.b sv+10,%d0
	subq.l #1,%d0
	tst.l %d0
	jne .L101
	moveq #127,%d0
	ext.w %d1
	and.l -2147457096,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d0
	moveq #45,%d1
	cmp.l %d0,%d1
	jne .L101
	pea 45.w
	moveq #127,%d2
	move.l %a1,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	mvz.b %d0,%d0
	cmp.l %d0,%d2
	jeq .L101
	tst.l st+4
	jne .L101
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L101
	moveq #19,%d1
	cmp.l sv+16.l,%d1
	jcs .L101
	tst.l commits
	jeq .L101
	move.l st+968,%d0
	addq.l #1,%d0
	cmp.l ls+132.l,%d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L98
	.size	ls_dsps, .-ls_dsps
	.align	2
	.type	pm_popup, @function
pm_popup:
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
	jeq .L109
	tst.l %d0
	jeq .L109
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
.L109:
	move.l %d3,-(%sp)
	jsr 1075557020
	move.l -32(%fp),%d2
	addq.l #4,%sp
	move.l -28(%fp),%d3
	unlk %fp
	rts
	.size	pm_popup, .-pm_popup
	.align	2
	.type	cu_tab, @function
cu_tab:
	move.l %d2,-(%sp)
	moveq #12,%d2
	move.l 8(%sp),%d1
	add.l #-40,%d1
	move.l 12(%sp),%d0
	cmp.l %d1,%d2
	jcs .L125
	move.w .L119(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&13
.L119:
	.word .L124-.L119
	.word .L125-.L119
	.word .L125-.L119
	.word .L125-.L119
	.word .L125-.L119
	.word .L125-.L119
	.word .L123-.L119
	.word .L122-.L119
	.word .L121-.L119
	.word .L120-.L119
	.word .L125-.L119
	.word .L125-.L119
	.word .L118-.L119
.L123:
	tst.l %d0
	jeq .L126
	move.l #cu_wtp2k,%d0
.L116:
	move.l (%sp)+,%d2
	rts
.L122:
	tst.l %d0
	jeq .L127
	move.l #cu_grp2k,%d0
	jra .L116
.L118:
	tst.l %d0
	jne .L131
	move.l #cu_srck,%d0
	jra .L116
.L121:
	tst.l %d0
	jeq .L129
	move.l #cu_lip2k,%d0
	jra .L116
.L120:
	tst.l %d0
	jeq .L130
	move.l #cu_cpp2k,%d0
	jra .L116
.L124:
	tst.l %d0
	jeq .L116
.L131:
	move.l #cu_p2k,%d0
	jra .L116
.L125:
	clr.l %d0
	jra .L116
.L126:
	move.l #cu_wtk,%d0
	jra .L116
.L127:
	move.l #cu_grk,%d0
	jra .L116
.L129:
	move.l #cu_lik,%d0
	jra .L116
.L130:
	move.l #cu_cpk,%d0
	jra .L116
	.size	cu_tab, .-cu_tab
	.align	2
	.globl	cu_text
	.type	cu_text, @function
cu_text:
	lea (-32,%sp),%sp
	moveq #84,%d1
	movem.l #3324,(%sp)
	move.l 36(%sp),%d6
	add.l #-1100630172,%d6
	divu.l %d1,%d6
	move.b cu+8,%d5
	move.l 40(%sp),%d4
	move.l %d4,%d3
	move.l 44(%sp),%d2
	asr.l #8,%d3
	clr.l -(%sp)
	lea cu_tab,%a2
	mvz.b %d5,%d0
	move.l %d0,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
	mov3q.l #1,-(%sp)
	move.l %d0,%a3
	mvz.b cu+1,%d0
	move.l %d0,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
	lea cu_src,%a2
	lea cu_p2,%a1
	sub.l %a0,%a0
	clr.l %d1
.L137:
	mvs.w (%a2)+,%d7
	cmp.l %d7,%d6
	jne .L133
	tst.l %a3
	jeq .L135
	mvz.b 10(%a3,%a0.l),%d1
.L135:
	addq.l #2,%a1
	lea (14,%a0),%a0
	moveq #112,%d7
	cmp.l %a0,%d7
	jne .L137
	cmp.l #441,%d6
	jne .L138
	moveq #12,%d1
.L138:
	move.l %d3,%d0
	moveq #127,%d7
	cmp.l %d3,%d7
	jge .L139
	moveq #127,%d0
.L140:
	addq.l #1,cu+4
	subq.l #1,%d1
	moveq #25,%d7
	cmp.l %d1,%d7
	jcs .L141
	move.w .L143(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&26
.L143:
	.word .L166-.L143
	.word .L165-.L143
	.word .L164-.L143
	.word .L163-.L143
	.word .L162-.L143
	.word .L161-.L143
	.word .L160-.L143
	.word .L159-.L143
	.word .L156-.L143
	.word .L158-.L143
	.word .L157-.L143
	.word .L156-.L143
	.word .L155-.L143
	.word .L154-.L143
	.word .L153-.L143
	.word .L152-.L143
	.word .L151-.L143
	.word .L150-.L143
	.word .L149-.L143
	.word .L148-.L143
	.word .L141-.L143
	.word .L147-.L143
	.word .L146-.L143
	.word .L145-.L143
	.word .L144-.L143
	.word .L142-.L143
.L133:
	mvs.w (%a1),%d7
	cmp.l %d7,%d6
	jne .L135
	tst.l %d0
	jeq .L135
	mvz.b 10(%a0,%d0.l),%d1
	jra .L135
.L139:
	tst.l %d3
	jge .L140
	clr.l %d0
	jra .L140
.L166:
	moveq #63,%d0
	cmp.l %d3,%d0
	jge .L182
	move.l #cu_loop+10,%d0
.L214:
	move.l %d0,44(%sp)
	move.l #cu_fmt_s,%d1
.L204:
	move.l %d1,40(%sp)
	jra .L200
.L182:
	move.l #cu_loop+5,%d0
	jra .L214
.L165:
	muls.w #3,%d0
	move.l #cu_fmt_s,%d3
	asr.l #7,%d0
	mulu.w #5,%d0
	add.l #cu_loop,%d0
	move.l %d0,44(%sp)
.L206:
	move.l %d3,40(%sp)
.L200:
	move.l %d2,36(%sp)
	movem.l (%sp),#3324
	lea (32,%sp),%sp
	jmp 1074365954
.L164:
	moveq #15,%d5
	cmp.l %d3,%d5
	jge .L168
	clr.l %d0
.L168:
	mulu.w #5,%d0
	add.l #cu_chd,%d0
.L205:
	move.l %d0,44(%sp)
	move.l #cu_fmt_s,%d7
	jra .L207
.L163:
	mov3q.l #3,%d1
	cmp.l %d3,%d1
	jge .L169
	clr.l %d0
.L169:
	move.l %d0,44(%sp)
	move.l #cu_fmt_inv,%d3
	jra .L206
.L162:
	mov3q.l #2,%d5
	cmp.l %d3,%d5
	jge .L170
	clr.l %d0
.L170:
	move.l %d0,44(%sp)
	move.l #cu_fmt_spr,%d7
.L207:
	move.l %d7,40(%sp)
	jra .L200
.L161:
	move.l %d0,%d1
	mov3q.l #5,%d3
	subq.l #1,%d1
	cmp.l %d1,%d3
	jcs .L171
	move.l %d0,44(%sp)
	move.l #cu_fmt_d,%d5
.L208:
	move.l %d5,40(%sp)
	jra .L200
.L171:
	move.l #cu_loop,%d7
.L209:
	move.l %d7,44(%sp)
	jra .L211
.L160:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_warp,%d0
.L202:
	move.l %d0,44(%sp)
	jra .L203
.L159:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #6,%d0
	add.l #cu_win,%d0
	jra .L214
.L158:
	moveq #119,%d5
	cmp.l %d3,%d5
	jlt .L172
	muls.w #99,%d0
	divs.l %d5,%d0
.L213:
	move.l %d0,44(%sp)
	move.l #cu_fmt_d,%d7
	jra .L207
.L172:
	lea cu_frz,%a0
	move.l %a0,44(%sp)
.L203:
	move.l #cu_fmt_s,%d0
.L201:
	move.l %d0,40(%sp)
	jra .L200
.L157:
	tst.l %d3
	jle .L173
	asr.l #4,%d0
	mulu.w #5,%d0
	add.l #cu_anim,%d0
	jra .L214
.L173:
	move.l #cu_off,%d3
.L210:
	move.l %d3,44(%sp)
	move.l #cu_fmt_s,%d5
	jra .L208
.L155:
	mvs.w %d0,%d0
	lsr.l #3,%d0
	and.l #262140,%d0
	add.l #cu_inpt,%d0
	jra .L205
.L154:
	mvs.w %d0,%d0
	asr.l #6,%d0
	mulu.w #5,%d0
	add.l #cu_mon,%d0
.L215:
	move.l %d0,44(%sp)
.L211:
	lea cu_fmt_s,%a0
	jra .L212
.L153:
	tst.l %d3
	jle .L173
	muls.w #60,%d0
	moveq #126,%d3
	move.l #cu_fmt_db,%d5
	addq.l #3,%d0
	divs.l %d3,%d0
	add.l #-80,%d0
	move.l %d0,44(%sp)
	jra .L208
.L152:
	asr.l #1,%d0
	addq.l #1,%d0
	jra .L213
.L151:
	moveq #63,%d1
	cmp.l %d3,%d1
	jge .L174
	muls.w #48,%d0
	moveq #126,%d3
	add.l #-3009,%d0
	divs.l %d3,%d0
	tst.l %d0
	jeq .L186
	move.l #cu_fmt_pd,%d1
.L175:
	move.l %d0,44(%sp)
	jra .L204
.L174:
	moveq #64,%d1
	moveq #-126,%d5
	sub.l %d0,%d1
	muls.w #48,%d1
	move.l %d1,%d0
	add.l #63,%d0
	divs.l %d5,%d0
.L186:
	move.l #cu_fmt_d,%d1
	jra .L175
.L150:
	muls.w #100,%d0
	moveq #127,%d7
	lea cu_fmt_pct,%a0
	add.l #63,%d0
	divs.l %d7,%d0
	move.l %d0,44(%sp)
.L212:
	move.l %a0,40(%sp)
	jra .L200
.L149:
	tst.l %d3
	jle .L173
.L141:
	move.l %d0,44(%sp)
	move.l #cu_fmt_d,%d0
	jra .L201
.L148:
	mvs.w %d0,%d0
	asr.l #3,%d0
	jeq .L176
	addq.l #1,%d0
	move.l %d0,44(%sp)
	move.l #cu_fmt_x,%d1
	jra .L204
.L147:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_tape,%d0
	jra .L205
.L146:
	muls.w #3,%d0
	lsr.l #5,%d0
	and.l #262140,%d0
	add.l #cu_dir,%d0
	jra .L215
.L145:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_cloop,%d0
	jra .L202
.L144:
	tst.l %d3
	jle .L176
	move.l %d0,44(%sp)
	move.l #cu_fmt_d,%d1
	jra .L204
.L142:
	moveq #126,%d5
	cmp.l %d3,%d5
	jge .L177
	move.l #cu_hold,%d7
	jra .L209
.L177:
	tst.l %d3
	jgt .L141
.L176:
	move.l #cu_slc,%d3
	jra .L210
.L156:
	cmp.l #441,%d6
	jeq .L187
	add.l #-46,%d5
	mvz.b %d5,%d5
	mov3q.l #6,%d1
	cmp.l %d5,%d1
	jcs .L188
	lea CSWTCH.495,%a0
	mvs.b (%a0,%d5.l),%d1
.L178:
	tst.l %d3
	jle .L173
	asr.l #5,%d4
	mov3q.l #7,%d3
	mov3q.l #-1,%d5
	and.l %d3,%d4
	cmp.l %d1,%d5
	jeq .L179
	lea ux,%a1
	lea (%a1,%d1.l),%a0
	mvz.b 3948(%a0),%d3
	cmp.l %d3,%d4
	jne .L179
	mvz.w #1280,%d3
	moveq #10,%d7
	muls.l %d0,%d7
	muls.l %d1,%d3
	move.l %d7,%a0
	add.l %d3,%a0
	tst.b 40(%a1,%a0.l)
	jeq .L179
	mulu.w #10,%d0
	mulu.w #1280,%d1
	move.l %d0,%a0
	lea 40(%a0,%d1.l),%a0
	move.l %a0,%d0
	add.l %a1,%d0
	jra .L202
.L187:
	clr.l %d1
	jra .L178
.L188:
	mov3q.l #-1,%d1
	jra .L178
.L179:
	move.l %d0,-(%sp)
	move.l %d4,%a0
	pea 65(%a0)
	pea cu_fmt_bk
	move.l %d2,-(%sp)
	jsr 1074365954
	movem.l 16(%sp),#3324
	lea (48,%sp),%sp
	rts
	.size	cu_text, .-cu_text
	.align	2
	.type	cu_knob, @function
cu_knob:
	lea (-16,%sp),%sp
	move.w 22(%sp),%d0
	move.l 24(%sp),%a1
	move.w 22(%sp),%d1
	movem.l #7172,(%sp)
	mulu.w #52,%d0
	mulu.w #84,%d1
	move.l %d0,%a0
	add.l #1075575064,%a0
	move.w 8(%a1),%d0
	add.l #1100630152,%d1
	muls.w #84,%d0
	move.l %d0,%a2
	clr.l %d0
	add.l #1100630152,%a2
.L217:
	lea (%a2,%d0.l),%a4
	moveq #84,%d2
	move.l %d1,%a3
	move.l (%a4),(%a3,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d2
	jne .L217
	tst.b 10(%a1)
	jeq .L218
	lea cu_text,%a2
	move.l %a2,32(%a3)
.L218:
	move.w 12(%a1),%d0
	move.l (%a1),40(%a0)
	move.l 4(%a1),48(%a0)
	clr.l 8(%a0)
	move.l 28(%sp),44(%a0)
	move.l %d0,%d1
	and.l #2048,%d1
	btst #11,%d0
	jeq .L221
	mvz.w #32736,%d0
.L219:
	move.l %d0,12(%a0)
	mvz.b 11(%a1),%d0
	lsl.l #8,%d0
	move.l %d0,16(%a0)
	tst.w %d1
	jeq .L216
	mov3q.l #1,20(%a0)
.L216:
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	rts
.L221:
	mvz.w #32512,%d0
	jra .L219
	.size	cu_knob, .-cu_knob
	.align	2
	.type	cu_src_setup, @function
cu_src_setup:
	lea (-36,%sp),%sp
	movem.l #15484,(%sp)
	move.l 40(%sp),%d3
	clr.l -(%sp)
	move.l %d3,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L226
	moveq #40,%d1
	cmp.l %d3,%d1
	jeq .L226
	move.l #1094564988,%a0
.L228:
	move.l (%a0),%d1
	addq.l #4,%a0
	move.l %d1,-100(%a0)
	move.l %d1,-132(%a0)
	move.l %d1,-164(%a0)
	move.l %d1,-196(%a0)
	cmp.l #1094565020,%a0
	jne .L228
	mvz.b cu+8,%d1
	cmp.l %d1,%d3
	jeq .L229
.L231:
	move.l %d3,%d5
	move.l %d0,%d6
	add.l #-46,%d5
	lea cu_src,%a2
	add.l #112,%d6
	move.l %d0,%d2
	move.l #1075575064,%a3
	lea CSWTCH.493,%a5
	lea cu_knob,%a4
.L230:
	mov3q.l #6,%d0
	cmp.l %d5,%d0
	jcs .L233
	move.l (%a5,%d5.l*4),%d0
.L232:
	move.w (%a2)+,%d4
	move.l %d0,-(%sp)
	move.l %d2,-(%sp)
	add.l #14,%d2
	mvs.w %d4,%d1
	mulu.w #52,%d4
	move.l %d1,-(%sp)
	jsr (%a4)
	lea (12,%sp),%sp
	move.l %d3,(%a3,%d4.l)
	cmp.l %d6,%d2
	jne .L230
	move.b %d3,cu+8
	jra .L226
.L229:
	move.l 1075595808,%d1
	move.l %d0,%a0
	cmp.l 4(%a0),%d1
	jne .L231
	move.l 1075596276,%d1
	cmp.l 102(%a0),%d1
	jne .L231
	cmp.l 1075595760.l,%d3
	jne .L231
.L226:
	movem.l (%sp),#15484
	lea (36,%sp),%sp
	rts
.L233:
	move.l #cu_fm_short,%d0
	jra .L232
	.size	cu_src_setup, .-cu_src_setup
	.align	2
	.globl	cu_steps
	.type	cu_steps, @function
cu_steps:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 12(%sp),%d1
	move.b 1093765506,%d0
	cmp.l #441,%d1
	jeq .L254
	lea cu_src,%a0
	clr.l %d2
.L246:
	mvs.w (%a0),%d1
	cmp.l 12(%sp),%d1
	jne .L244
	mvz.b cu+8,%d0
	clr.l -(%sp)
	move.l %d0,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jne .L245
.L248:
	clr.l %d0
.L242:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L245:
	mulu.w #14,%d2
	move.l %d0,%a0
	mvz.w 12(%a0,%d2.l),%d0
	jra .L242
.L244:
	addq.l #2,%a0
	addq.l #1,%d2
	moveq #8,%d1
	cmp.l %d2,%d1
	jne .L246
	mvz.b %d0,%d0
	moveq #11,%d2
	cmp.l %d0,%d2
	jge .L247
	clr.l %d0
.L247:
	moveq #127,%d1
	and.l -2147457096,%d1
	mulu.w #152,%d0
	mulu.w #2531,%d1
	move.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0,%d0.l),%d2
	mvz.b cu+1,%d0
	cmp.l %d2,%d0
	jne .L248
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L248
	move.l 1075596172,%d1
	move.l %d0,%a0
	cmp.l 102(%a0),%d1
	jne .L248
	lea cu_p2,%a0
	clr.l %d1
.L249:
	mvs.w (%a0),%d3
	cmp.l 12(%sp),%d3
	jne .L250
	moveq #40,%d3
	cmp.l %d2,%d3
	jne .L253
	mov3q.l #3,%d2
	cmp.l %d1,%d2
	jge .L248
.L253:
	mulu.w #14,%d1
	move.l %d0,%a0
	mvz.w 12(%a0,%d1.l),%d0
	jra .L242
.L250:
	addq.l #2,%a0
	addq.l #1,%d1
	moveq #8,%d3
	cmp.l %d1,%d3
	jne .L249
	jra .L248
.L254:
	mvz.w #2944,%d0
	jra .L242
	.size	cu_steps, .-cu_steps
	.align	2
	.type	led_send4, @function
led_send4:
	moveq #-76,%d0
	link.w %fp,#-8
	move.l 12(%fp),%a0
	move.b 11(%fp),-5(%fp)
	move.l (%a0),-4(%fp)
	pea -6(%fp)
	mov3q.l #6,-(%sp)
	move.b %d0,-6(%fp)
	jsr rui_uart_raw
	addq.l #8,%sp
	unlk %fp
	rts
	.size	led_send4, .-led_send4
	.align	2
	.type	led_stock, @function
led_stock:
	lea (-24,%sp),%sp
	movem.l #19468,(%sp)
	move.l #sh,%d2
	sub.l %a6,%a6
	lea led_send4,%a2
.L266:
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr (%a2)
	addq.l #1,%a6
	addq.l #4,%d2
	addq.l #8,%sp
	moveq #16,%d0
	cmp.l %a6,%d0
	jne .L266
	move.l %sp,%d2
	sub.l %a6,%a6
	lea shs,%a3
	add.l #22,%d2
	lea rui_uart_raw,%a2
.L268:
	move.b (%a3,%a6.l),%d0
	mvz.b %d0,%d1
	cmp.l #255,%d1
	jeq .L267
	move.l %a6,%d1
	moveq #32,%d3
	or.l %d3,%d1
	move.b %d0,23(%sp)
	move.b %d1,22(%sp)
	move.l %d2,-(%sp)
	mov3q.l #2,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
.L267:
	addq.l #1,%a6
	mov3q.l #4,%d0
	cmp.l %a6,%d0
	jne .L268
	movem.l (%sp),#19468
	lea (24,%sp),%sp
	rts
	.size	led_stock, .-led_stock
	.align	2
	.type	send, @function
send:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L275
	lea txsx_wait,%a2
	jsr (%a2)
	move.l %d0,%d2
	tst.l %d0
	jeq .L276
	addq.l #1,st+40
.L275:
	clr.l %d2
.L274:
	move.l %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L276:
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L278
	addq.l #1,st+40
	jra .L274
.L278:
	jsr (%a2)
	tst.l %d0
	jne .L279
	mvz.w #4027,%d0
	cmp.l 1094562392.l,%d0
	jlt .L279
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L280:
	tst.l %a0
	jeq .L279
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L280
	move.l 12(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	mov3q.l #1,%d2
	addq.l #1,st+36
	jra .L274
.L279:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #1,st+40
	addq.l #4,%sp
	jra .L274
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
.L289:
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
	jgt .L289
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
	jne .L292
	mvz.b mr+18,%d0
	cmp.l -12(%fp),%d0
	jeq .L291
.L292:
	pea 8.w
	pea -8(%fp)
	move.b -9(%fp),-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L291
	clr.b %d0
	lea (-9,%fp),%a0
	move.b (%a0),mr+18
	move.b %d0,mr+19
	move.w mr+20,%d0
	addq.l #1,%d0
	move.w %d0,mr+20
.L291:
	unlk %fp
	rts
	.size	kit_tick, .-kit_tick
	.align	2
	.type	mr_tick, @function
mr_tick:
	lea (-32,%sp),%sp
	sub.l %a1,%a1
	movem.l #23556,(%sp)
	lea (20,%sp),%a2
	clr.l %d1
	lea mr,%a6
	move.l %a2,%a4
	move.l %a6,%a3
.L299:
	moveq #127,%d0
	and.l -2147457096,%d0
	mvz.b (%a6)+,%d2
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l #1092966773,%a0
	move.b (%a0,%a1.l),%d0
	move.b %d0,(%a4)+
	mvz.b %d0,%d0
	cmp.l %d0,%d2
	jeq .L298
	addq.l #1,%d1
.L298:
	lea (152,%a1),%a1
	cmp.l #1824,%a1
	jne .L299
	tst.b mr+12.l
	jne .L300
	sub.l %a0,%a0
.L301:
	lea (%a2,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a3,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L301
	moveq #127,%d0
	and.l -2147457096,%d0
	move.b %d0,mr+18
	moveq #1,%d0
	move.b %d0,mr+12
.L302:
	mov3q.l #1,%a6
	jra .L297
.L300:
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L303
	move.b %d0,mr+13
.L304:
	move.l %a2,-(%sp)
	pea 12.w
	clr.l -(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L297
	sub.l %a0,%a0
.L307:
	lea (%a2,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a3,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L307
	clr.b %d0
	move.b %d0,mr+13
	move.w mr+16,%d0
	addq.l #1,%d0
	move.w %d0,mr+16
	jsr kit_tick
.L297:
	move.l %a6,%d0
	movem.l (%sp),#23556
	lea (32,%sp),%sp
	rts
.L303:
	clr.l %d2
	tst.b mr+13.l
	jne .L304
.L305:
	mvz.b (%a3,%d2.l),%d0
	mvz.b (%a2)+,%d1
	cmp.l %d1,%d0
	jeq .L309
	pea 20(%sp)
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L297
	lea (-1,%a2),%a0
	move.b (%a0),(%a3,%d2.l)
	move.w mr+14,%d0
	addq.l #1,%d0
	move.w %d0,mr+14
.L309:
	addq.l #1,%d2
	moveq #12,%d0
	cmp.l %d2,%d0
	jne .L305
	jsr kit_tick
	jra .L302
	.size	mr_tick, .-mr_tick
	.align	2
	.type	sq_send2, @function
sq_send2:
	link.w %fp,#-16
	move.l #-260222380,%d0
	move.l %a2,-(%sp)
	move.w #11521,%a2
	move.l %d0,-16(%fp)
	move.b 11(%fp),-10(%fp)
	clr.l %d0
	move.l 12(%fp),%a1
	move.w %a2,-12(%fp)
.L323:
	lea (%a1,%d0.l),%a2
	move.b (%a2),-9(%fp,%d0.l)
	move.l %d0,%a0
	addq.l #1,%d0
	cmp.l 16(%fp),%d0
	jne .L323
	moveq #-9,%d0
	move.b %d0,-8(%fp,%a0.l)
	pea 9(%a0)
	pea -16(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L322
	addq.l #1,sq+456
.L322:
	move.l -20(%fp),%a2
	unlk %fp
	rts
	.size	sq_send2, .-sq_send2
	.align	2
	.type	pj_send, @function
pj_send:
	link.w %fp,#-12
	move.l #-260222380,%d0
	move.l %d2,-(%sp)
	moveq #64,%d2
	move.l %d0,-12(%fp)
	pea 12.w
	move.b 11(%fp),%d0
	pea -12(%fp)
	move.l 16(%fp),%d1
	and.l %d2,%d0
	moveq #63,%d2
	tst.b %d0
	seq %d0
	add.l #76,%d0
	move.b %d0,-8(%fp)
	moveq #1,%d0
	move.b %d0,-7(%fp)
	move.b 11(%fp),%d0
	and.l %d2,%d0
	moveq #127,%d2
	move.b %d0,-6(%fp)
	move.l 12(%fp),%d0
	lsr.l #7,%d0
	and.l %d2,%d0
	moveq #-9,%d2
	move.b %d0,-5(%fp)
	moveq #127,%d0
	and.l 12(%fp),%d0
	move.b %d2,-1(%fp)
	move.b %d0,-4(%fp)
	move.l %d1,%d0
	lsr.l #7,%d0
	move.b %d0,-3(%fp)
	moveq #127,%d0
	and.l %d0,%d1
	move.b %d1,-2(%fp)
	jsr send
	move.l -16(%fp),%d2
	addq.l #8,%sp
	unlk %fp
	rts
	.size	pj_send, .-pj_send
	.align	2
	.type	kq_owed_in.part.0, @function
kq_owed_in.part.0:
	lea (-32,%sp),%sp
	clr.l %d1
	movem.l #3324,(%sp)
	clr.b %d2
	move.l kq_owes,%a0
	move.l st+196,%d0
	lea kq_owed,%a2
	lea st,%a3
.L333:
	moveq #15,%d3
	cmp.l %d0,%d3
	jcs .L348
	moveq #31,%d6
	mov3q.l #1,%d7
	and.l %d1,%d6
	move.l %d1,%d3
	lsr.l #5,%d3
	move.l (%a2,%d3.l*4),%d4
	lsl.l %d6,%d7
	move.l %d7,%d6
	and.l %d4,%d6
	tst.l %d6
	jeq .L334
	move.l %d7,%d2
	not.l %d2
	and.l %d4,%d2
	move.l %d0,%a1
	subq.l #1,%a0
	lea (82,%a1),%a1
	move.b %d1,(%a3,%a1.l*2)
	lea (%a3,%d0.l*2),%a1
	addq.l #1,%d0
	move.l %d2,(%a2,%d3.l*4)
	clr.b %d2
	move.b %d2,165(%a1)
	moveq #1,%d2
.L334:
	addq.l #1,%d1
	cmp.l #256,%d1
	jne .L333
.L348:
	tst.b %d2
	jeq .L332
	move.l %a0,kq_owes
	move.l %d0,st+196
.L332:
	movem.l (%sp),#3324
	lea (32,%sp),%sp
	rts
	.size	kq_owed_in.part.0, .-kq_owed_in.part.0
	.align	2
	.type	flush, @function
flush:
	link.w %fp,#-36
	movem.l #7180,(%sp)
	tst.b st+992.l
	jeq .L350
	move.l st+8,%d0
	cmp.l #16383,%d0
	jls .L351
	mvz.w #16383,%d0
.L351:
	moveq #127,%d1
	and.l %d0,%d1
	lsr.l #7,%d0
	mov3q.l #7,-(%sp)
	mvz.b %d0,%d0
	move.l %d1,-(%sp)
	move.l %d0,-(%sp)
	pea 53.w
	jsr send3
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L349
	clr.b %d0
	addq.l #1,st+968
	move.b %d0,st+992
.L350:
	tst.b st+161.l
	jeq .L353
	move.l #-260222380,%d1
	move.l %d1,-12(%fp)
	move.w st+162,%d1
	move.w #12289,%a0
	lea st+993,%a1
	move.b (%a1),-6(%fp)
	pea 10.w
	pea -12(%fp)
	mvz.w %d1,%d0
	lsl.l #8,%d1
	lsr.l #8,%d0
	move.w %a0,-8(%fp)
	add.l %d1,%d0
	move.w %d0,-5(%fp)
	moveq #-9,%d0
	move.b %d0,-3(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L349
	clr.b %d1
	move.b %d1,st+161
.L353:
	lea ls+4,%a0
	clr.l %d2
	move.l %fp,%d3
	move.l #-260222380,%a3
	lea ls,%a2
	add.l #-12,%d3
	move.l %a0,-16(%fp)
.L355:
	cmp.l ls+24.l,%d2
	jcs .L358
.L357:
	move.w %d2,%d0
	move.l ls+24,%d1
	move.l %d1,-16(%fp)
	mulu.w #5,%d0
	lea (%a2,%d0.l),%a0
	move.l %d2,%d0
.L359:
	cmp.l -16(%fp),%d0
	jcs .L360
	move.l -16(%fp),%d1
	sub.l %d2,%d1
	move.l %d1,-16(%fp)
	move.l %d1,ls+24
	tst.l %d1
	jne .L349
	lea st+164,%a2
	move.l %a2,%a4
.L361:
	move.l -16(%fp),%a0
	cmp.l st+196.l,%a0
	jcc .L365
	move.b (%a4),%d0
	mvz.b 1(%a4),%d1
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
	jne .L362
.L365:
	move.l st+196,%d0
	move.l -16(%fp),%d1
.L363:
	cmp.l %d0,%d1
	jcs .L366
	sub.l -16(%fp),%d0
	move.l %d0,st+196
	tst.l %d0
	jne .L349
	move.l kq_owes,%d2
	tst.l %d2
	jeq .L367
	movem.l -36(%fp),#7180
	unlk %fp
	jra (kq_owed_in.part.0)
.L358:
	move.w #18945,%a1
	moveq #-9,%d0
	move.l -16(%fp),%a0
	move.l %a3,-12(%fp)
	move.b (%a0),-6(%fp)
	move.b 1(%a0),-5(%fp)
	move.b 2(%a0),-4(%fp)
	move.b 3(%a0),-3(%fp)
	move.b 4(%a0),-2(%fp)
	pea 12.w
	move.l %d3,-(%sp)
	move.w %a1,-8(%fp)
	move.b %d0,-1(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L357
	addq.l #5,-16(%fp)
	addq.l #1,%d2
	jra .L355
.L360:
	addq.l #5,%a0
	addq.l #5,%a2
	move.b -1(%a0),-1(%a2)
	addq.l #1,%d0
	move.b (%a0),(%a2)
	move.b 1(%a0),1(%a2)
	move.b 2(%a0),2(%a2)
	move.b 3(%a0),3(%a2)
	jra .L359
.L362:
	addq.l #2,%a4
	addq.l #1,-16(%fp)
	jra .L361
.L366:
	move.l -16(%fp),%a1
	addq.l #1,%d1
	move.b (%a2,%a1.l*2),(%a2)
	lea 1(%a2,%a1.l*2),%a0
	addq.l #2,%a2
	move.b (%a0),-1(%a2)
	jra .L363
.L367:
	lea st+96,%a2
.L372:
	move.l (%a2)+,-16(%fp)
	tst.l -16(%fp)
	jeq .L368
	moveq #-63,%d0
	cmp.l -16(%fp),%d0
	jle .L369
	moveq #-63,%d1
.L389:
	move.l %d1,-16(%fp)
.L370:
	mvz.b st+160,%d0
	move.l %d0,-(%sp)
	move.l -16(%fp),%d0
	add.l #64,%d0
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	move.l %d2,%d0
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	pea 50.w
	jsr send3
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L349
	move.l -16(%fp),%d1
	sub.l %d1,-4(%a2)
	move.l st+64,%d1
	tst.l %d1
	jeq .L368
	move.l -66650100,%d0
	sub.l %d1,%d0
	move.l %d0,st+68
	add.l %d0,st+316
	addq.l #1,st+320
	cmp.l st+324.l,%d0
	jls .L371
	move.l %d0,st+324
.L371:
	clr.l st+64
.L368:
	addq.l #1,%d2
	moveq #16,%d0
	cmp.l %d2,%d0
	jne .L372
.L349:
	movem.l -36(%fp),#7180
	unlk %fp
	rts
.L369:
	moveq #63,%d0
	cmp.l -16(%fp),%d0
	jge .L370
	moveq #63,%d1
	jra .L389
	.size	flush, .-flush
	.align	2
	.type	ed_queue, @function
ed_queue:
	move.l %d2,-(%sp)
	move.l 8(%sp),%a1
	move.l 20(%sp),%d1
	addq.l #1,ed+80
	mov3q.l #1,ed+376
	tst.l sq
	jeq .L390
	move.l ed+64,%d0
	move.l %d0,%a0
	mov3q.l #7,%d2
	sub.l ed+68,%a0
	cmp.l %a0,%d2
	jcc .L392
	addq.l #1,ed+72
.L390:
	move.l (%sp)+,%d2
	rts
.L392:
	mov3q.l #7,%d2
	and.l %d2,%d0
	moveq #127,%d2
	lsl.l #3,%d0
	move.l %d0,%a0
	add.l #ed,%a0
	move.w %a1,%d0
	move.b %d0,(%a0)
	move.b 1079807236,%d0
	and.l %d2,%d0
	move.b %d0,1(%a0)
	mov3q.l #4,%d0
	cmp.l %a1,%d0
	jcc .L393
	lea (-16,%a1),%a1
	mov3q.l #1,%d2
	cmp.l %a1,%d2
	jcc .L393
	mvz.b 1093765506,%d0
	moveq #11,%d2
	cmp.l %d0,%d2
	jcc .L394
.L393:
	moveq #127,%d0
.L395:
	move.b %d0,2(%a0)
	tst.l 12(%sp)
	sne %d0
	moveq #127,%d2
	move.b 19(%sp),4(%a0)
	neg.l %d0
	move.b %d0,3(%a0)
	moveq #127,%d0
	and.l %d1,%d0
	move.b %d0,5(%a0)
	move.l %d1,%d0
	lsr.l #7,%d0
	and.l %d2,%d0
	move.b %d0,6(%a0)
	moveq #14,%d0
	lsr.l %d0,%d1
	move.b %d1,7(%a0)
	addq.l #1,ed+64
	jra .L390
.L394:
	move.b 1093765506,%d0
	jra .L395
	.size	ed_queue, .-ed_queue
	.align	2
	.type	ls_queue, @function
ls_queue:
	mvz.b ls+124,%d0
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	lea ls,%a2
	move.l %d0,-(%sp)
	mvz.b ls+1,%d0
	move.l %d0,-(%sp)
	jsr sv_word
	addq.l #8,%sp
	move.l ls+24,%a0
	mov3q.l #3,%d1
	cmp.l %a0,%d1
	jcc .L400
	addq.l #1,ls+92
.L399:
	move.l (%sp)+,%a2
	move.l (%sp)+,%a3
	rts
.L400:
	lea (%a0,%a0.l*4),%a1
	lea ls+1,%a3
	addq.l #1,%a0
	move.l %a0,ls+24
	add.l %a2,%a1
	move.b (%a3),4(%a1)
	lea (%a0,%a0.l*4),%a3
	move.b 19(%sp),8(%a1)
	move.l %a3,%d1
	lea (15,%sp),%a3
	move.b (%a3),(%a2,%d1.l)
	move.l %d0,%d1
	lsr.l #7,%d1
	move.b %d1,6(%a1)
	moveq #127,%d1
	and.l %d1,%d0
	move.b %d0,7(%a1)
	jra .L399
	.size	ls_queue, .-ls_queue
	.align	2
	.type	ls_close, @function
ls_close:
	lea ls,%a0
	tst.b ls.l
	jeq .L402
	clr.b %d0
	clr.l ls+36
	addq.l #1,ls+80
	clr.l ls_smpl
	clr.l st+96
	move.b %d0,ls
	mvz.b 7(%sp),%d0
	addq.l #1,100(%a0,%d0.l*4)
	move.l %d0,-(%sp)
	clr.l -(%sp)
	jsr ls_queue
	addq.l #8,%sp
.L402:
	rts
	.size	ls_close, .-ls_close
	.align	2
	.type	ls_enc, @function
ls_enc:
	move.b ls,%d0
	move.l %d2,-(%sp)
	move.l 8(%sp),%d2
	tst.b %d0
	jeq .L405
	mvz.b ls+125,%d1
	cmp.l %d1,%d2
	jeq .L405
	mov3q.l #3,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L411:
	clr.l %d0
	jra .L404
.L405:
	tst.l %d2
	jeq .L407
	mov3q.l #3,%d1
	cmp.l %d2,%d1
	jne .L411
.L407:
	tst.l st+972
	jne .L411
	tst.b %d0
	jne .L409
	tst.l %d2
	jne .L410
	tst.b sv.l
	jeq .L411
	tst.b sv+8.l
	jeq .L411
	mvz.b sv+2,%d0
	move.l %d0,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jeq .L404
	clr.b %d0
	lea sv+1,%a0
	move.w (%a0),ls+1
	move.b %d0,ls+124
	move.b %d0,ls+126
.L412:
	moveq #1,%d0
	lea st+8,%a0
	move.l (%a0),ls+128
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.b %d2,ls+125
	addq.l #1,ls+76
	move.b %d0,ls
	jsr ls_queue
	jsr flush
	addq.l #8,%sp
.L413:
	mov3q.l #1,%d0
.L404:
	move.l (%sp)+,%d2
	rts
.L410:
	jsr ls_dsps
	tst.l %d0
	jeq .L404
	moveq #45,%d1
	move.b 1093765506,%d0
	addq.l #1,ls+136
	move.b %d1,ls+2
	moveq #10,%d1
	move.b %d0,ls+1
	mvz.b %d0,%d0
	addq.l #1,%d0
	move.l %d0,ls_smpl
	move.b %d1,ls+124
	moveq #1,%d1
	move.b %d1,ls+126
	jra .L412
.L409:
	move.l 12(%sp),%d0
	addq.l #1,ls+84
	add.l %d0,st+96
	jsr flush
	jra .L413
	.size	ls_enc, .-ls_enc
	.align	2
	.type	pj_push, @function
pj_push:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.l 20(%sp),%d1
	move.l 24(%sp),%a1
#APP
| 4205 "rui.c" 1
	tas pj+136
	smi %d2
| 0 "" 2
#NO_APP
	tst.b %d2
	jeq .L427
	addq.l #1,pj+156
.L426:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L427:
	move.l pj,%d3
	move.l %d3,%d0
	sub.l pj+4,%d0
	lsr.l #5,%d0
	jeq .L429
	addq.l #1,pj+156
.L430:
	clr.b %d0
	move.b %d0,pj+136
	jra .L426
.L429:
	moveq #31,%d0
	and.l %d3,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #pj+8,%a0
	move.b 19(%sp),(%a0)
	moveq #127,%d0
	cmp.l %d1,%d0
	jcs .L433
	move.l %d1,%d0
	addq.l #1,%d0
.L431:
	move.b %d0,1(%a0)
	moveq #127,%d4
	cmp.l %a1,%d4
	jcs .L432
	move.l %a1,%d2
	addq.l #1,%d2
.L432:
	move.b %d2,2(%a0)
	addq.l #1,%d3
	move.l %d3,pj
	jra .L430
.L433:
	clr.b %d0
	jra .L431
	.size	pj_push, .-pj_push
	.align	2
	.type	led_restore, @function
led_restore:
	tst.b ov_on.l
	jeq .L434
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L436
	addq.l #1,st+1018
.L434:
	rts
.L436:
	clr.b %d0
	move.b %d0,ov_on
	jsr led_stock
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #4,%sp
	move.l st+8,%d0
	addq.l #4,%d0
	tst.l %d0
	jne .L437
	mov3q.l #1,%d0
.L437:
	move.l %d0,led_again
	addq.l #1,st+1014
	jra .L434
	.size	led_restore, .-led_restore
	.align	2
	.globl	rui_sysex
	.type	rui_sysex, @function
rui_sysex:
	lea (-76,%sp),%sp
	move.l -66650100,%d1
	move.l 84(%sp),%d0
	movem.l #19708,(%sp)
	move.l 80(%sp),%a0
	mov3q.l #6,%d2
	move.l %d1,40(%sp)
	cmp.l %d0,%d2
	jge .L445
	mvz.b 5(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L445
	mvz.b -1(%a0,%d0.l),%d1
	cmp.l #247,%d1
	jeq .L443
.L445:
	addq.l #1,rx_bad
	jra .L444
.L443:
	move.b 4(%a0),%d2
	move.l %d0,%d1
	moveq #34,%d4
	subq.l #7,%d1
	move.l %d2,%d3
	add.l #-40,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d4
	jcs .L445
	move.w .L447(%pc,%d3.l*2),%a1
	jmp %pc@(2,%a1:l)
	.balignw 2,0x284c
	.swbeg	&35
.L447:
	.word .L463-.L447
	.word .L445-.L447
	.word .L445-.L447
	.word .L445-.L447
	.word .L445-.L447
	.word .L445-.L447
	.word .L462-.L447
	.word .L461-.L447
	.word .L445-.L447
	.word .L445-.L447
	.word .L445-.L447
	.word .L445-.L447
	.word .L460-.L447
	.word .L445-.L447
	.word .L459-.L447
	.word .L458-.L447
	.word .L457-.L447
	.word .L456-.L447
	.word .L455-.L447
	.word .L445-.L447
	.word .L454-.L447
	.word .L453-.L447
	.word .L452-.L447
	.word .L451-.L447
	.word .L445-.L447
	.word .L445-.L447
	.word .L445-.L447
	.word .L445-.L447
	.word .L445-.L447
	.word .L445-.L447
	.word .L450-.L447
	.word .L449-.L447
	.word .L448-.L447
	.word .L445-.L447
	.word .L446-.L447
.L457:
	mov3q.l #4,%d5
	cmp.l %d1,%d5
	jge .L464
	move.b 7(%a0),%d6
	moveq #15,%d7
	mvz.b %d6,%d2
	cmp.l %d2,%d7
	jcs .L464
	mvz.b 8(%a0),%d3
	mov3q.l #7,%d1
	cmp.l %d3,%d1
	jcs .L464
	move.b 9(%a0),%d1
	jeq .L464
	move.b 10(%a0),%d4
	jeq .L464
	mvz.b %d1,%d5
	add.l %d5,%d2
	moveq #16,%d5
	cmp.l %d2,%d5
	jlt .L464
	mvz.b %d4,%d2
	move.l %d3,%a1
	moveq #8,%d7
	add.l %d2,%a1
	cmp.l %a1,%d7
	jlt .L464
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
	jne .L464
	mvs.b %d6,%d0
	lea (11,%a0),%a2
	sub.l %a6,%a6
	lsl.l #6,%d0
	move.l %d0,%a1
	add.l %d3,%a1
	add.l #staging,%a1
.L468:
	move.l %d1,%d4
	mov3q.l #7,%d0
	cmp.l %d1,%d0
	jge .L465
	mov3q.l #7,%d4
.L465:
	move.l %a2,%a3
	sub.l %d4,%d1
	mvz.b (%a3)+,%d5
	clr.l %d0
	move.l %a3,%d3
.L467:
	move.l %d5,%d6
	lsr.l #1,%d5
	move.b 1(%a2,%d0.l),%d7
	lsl.l #7,%d6
	or.l %d7,%d6
	move.b %d6,(%a1,%a6.l)
	addq.l #1,%a6
	cmp.l %d2,%a6
	jne .L466
	addq.l #8,%a1
	sub.l %a6,%a6
.L466:
	addq.l #1,%d0
	cmp.l %d0,%d4
	jne .L467
	move.l %d3,%a2
	add.l %d0,%a2
	tst.l %d1
	jgt .L468
	addq.l #6,%a0
	move.b (%a0),st_seq
	moveq #1,%d0
.L582:
	move.b %d0,st_valid
.L454:
	addq.l #1,rx
	jra .L444
.L464:
	clr.b %d1
	addq.l #1,rx_bad
	move.b %d1,st_valid
.L444:
	move.l -66650100,%d0
	addq.l #1,mt_calls
	sub.l 40(%sp),%d0
	add.l %d0,mt_sum
	cmp.l mt_max.l,%d0
	jls .L553
	move.l %d0,mt_max
.L553:
	movem.l (%sp),#19708
	mov3q.l #1,%d0
	lea (76,%sp),%sp
	rts
.L456:
	tst.l %d1
	jeq .L445
	tst.b st_valid.l
	jeq .L470
	mvz.b 6(%a0),%d1
	mvz.b st_seq,%d0
	cmp.l %d1,%d0
	jne .L470
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
.L470:
	clr.b %d0
	jra .L582
.L455:
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jge .L445
	tst.b 7(%a0)
	jeq .L472
	moveq #1,%d3
	move.b %d3,host_open
	jra .L454
.L472:
	moveq #1,%d4
	move.b %d4,host_close
	jra .L454
.L446:
	subq.l #2,%d1
	tst.l %d1
	jne .L445
	mvz.b 6(%a0),%d0
	moveq #11,%d6
	cmp.l %d0,%d6
	jcs .L445
	mvz.b 7(%a0),%d0
	lsr.l #1,%d0
	jne .L445
	mvz.w 6(%a0),%d0
	move.l %d0,ls_in_v
	addq.l #1,ls_in_gen
	jra .L454
.L463:
	subq.l #6,%d1
	tst.l %d1
	jne .L445
	move.l %a0,%d0
	add.l #12,%d0
	lea (6,%a0),%a1
.L477:
	tst.b (%a1)
	jlt .L445
	addq.l #1,%a1
	cmp.l %d0,%a1
	jne .L477
	addq.l #1,pc_seq
	clr.l %d0
	lea pc_req,%a1
.L478:
	lea 6(%a0,%d0.l),%a2
	mov3q.l #6,%d1
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L478
	addq.l #1,pc_seq
	jra .L454
.L460:
	tst.l %d1
	jeq .L445
	move.b 6(%a0),%d0
	mov3q.l #1,%d3
	mvz.b %d0,%d2
	cmp.l %d2,%d3
	jcs .L445
	jne .L480
	moveq #17,%d4
	cmp.l %d1,%d4
	jne .L445
	move.l %a0,%d1
	add.l #23,%d1
	lea (7,%a0),%a1
.L483:
	mvz.b (%a1),%d2
	moveq #111,%d5
	cmp.l %d2,%d5
	jcs .L445
	addq.l #1,%a1
	cmp.l %d1,%a1
	jne .L483
.L480:
	addq.l #1,led_gen
	move.b %d0,led_req_mode
	clr.l %d0
	lea led_req,%a1
.L484:
	mvz.b 6(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L485
	moveq #16,%d3
	cmp.l %d0,%d3
	jne .L486
.L485:
	addq.l #1,led_gen
	jra .L454
.L486:
	lea 7(%a0,%d0.l),%a2
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	jra .L484
.L462:
	moveq #14,%d4
	cmp.l %d0,%d4
	jcs .L445
	mvz.w #21504,%d2
	btst %d0,%d2
	jeq .L445
	mvz.b 7(%a0),%d0
	moveq #31,%d5
	cmp.l %d0,%d5
	jcs .L445
	mov3q.l #4,%d6
	cmp.l %d1,%d6
	jge .L488
	mvz.b 10(%a0),%d0
	cmp.l %d0,%d5
	jcs .L445
	mov3q.l #7,%d7
	cmp.l %d1,%d7
	jne .L488
	mvz.b 12(%a0),%d0
	cmp.l %d0,%d5
	jcs .L445
.L488:
	addq.l #1,sq_gen
	clr.l %d0
	lea sq_req,%a1
.L490:
	cmp.l %d1,%d0
	jge .L541
	moveq #127,%d3
	move.b 6(%a0,%d0.l),%d2
	and.l %d3,%d2
.L489:
	move.b %d2,(%a1,%d0.l)
	addq.l #1,%d0
	mov3q.l #7,%d4
	cmp.l %d0,%d4
	jne .L490
	addq.l #1,sq_gen
	jra .L454
.L541:
	clr.b %d2
	jra .L489
.L450:
	subq.l #2,%d1
	tst.l %d1
	jne .L445
	mvz.b 7(%a0),%d0
	moveq #31,%d6
	cmp.l %d0,%d6
	jcs .L445
	lsl.l #7,%d0
	mvz.b 6(%a0),%d1
	addq.l #1,pin+56
	or.l %d0,%d1
	move.l %d1,pin+4
	jra .L454
.L449:
	move.l %d0,%d2
	moveq #14,%d7
	add.l #-10,%d2
	rems.l %d7,%d4:%d2
	tst.l %d4
	jne .L542
	mov3q.l #3,%a1
.L493:
	mov3q.l #2,%d2
	cmp.l %d1,%d2
	jge .L494
	move.b 6(%a0),%d5
	mvz.b %d5,%d3
	cmp.l %d3,%d2
	jcs .L494
	move.b 7(%a0),%d2
	mvz.b %d2,%d6
	lsr.l #1,%d6
	jne .L494
	tst.l %d4
	jeq .L495
	move.l %d0,%d4
	moveq #14,%d6
	add.l #-11,%d4
	rems.l %d6,%d0:%d4
	tst.l %d0
	jne .L494
.L495:
	mov3q.l #4,%d7
	cmp.l %a1,%d7
	jne .L496
	mvz.b 9(%a0),%d0
	lsr.l #3,%d0
	jeq .L496
.L494:
	addq.l #1,ux+12
	jra .L445
.L542:
	mov3q.l #4,%a1
	jra .L493
.L496:
	ext.w %d5
	tst.b %d2
	jne .L497
	move.l %d3,%a2
	add.l #ux,%a2
	mvz.b 3948(%a2),%d4
	mov3q.l #4,%d6
	cmp.l %a1,%d6
	jne .L498
	mvz.b 9(%a0),%d2
	cmp.l %d4,%d2
	jeq .L499
.L497:
	move.w %d5,%d2
	mulu.w #1280,%d2
	move.l %d2,%a6
	add.l #ux+40,%a6
	mvz.w #128,%d2
.L500:
	clr.b (%a6)
	subq.l #1,%d2
	lea (10,%a6),%a6
	tst.l %d2
	jne .L500
	mov3q.l #4,%d7
	cmp.l %a1,%d7
	jne .L543
.L499:
	move.b 9(%a0),%d2
.L501:
	lea ux,%a2
	moveq #127,%d0
	lea (%a2,%d3.l),%a6
	move.b %d2,3948(%a6)
	mulu.w #1280,%d5
	lea (%a0,%a1.l),%a6
	addq.l #1,%a1
	move.b 8(%a0),%d2
	and.l %d0,%d2
	move.b %d2,36(%a2,%d3.l)
.L502:
	move.l %a1,%d0
	add.l #12,%d0
	cmp.l %d1,%d0
	jlt .L507
	addq.l #1,ux+8
	jra .L454
.L543:
	clr.b %d2
	jra .L501
.L507:
	move.b 6(%a6),%d0
	jmi .L503
	ext.w %d0
	move.l %d5,%a0
	mulu.w #10,%d0
	lea 40(%a0,%d0.l),%a2
	sub.l %a0,%a0
	add.l #ux,%a2
.L504:
	move.b 7(%a6,%a0.l),%d3
	moveq #94,%d4
	move.l %d3,%d2
	add.l #-32,%d2
	mvz.b %d2,%d2
	cmp.l %d2,%d4
	jcs .L505
	move.b %d3,(%a2,%a0.l)
	addq.l #1,%a0
	moveq #9,%d0
	cmp.l %a0,%d0
	jne .L504
.L505:
	clr.b %d6
	move.b %d6,(%a2,%a0.l)
.L503:
	lea (14,%a6),%a6
	lea (14,%a1),%a1
	jra .L502
.L448:
	move.l ux+3880,%d3
	add.l #-10,%d0
	mov3q.l #2,%d7
	cmp.l %d0,%d7
	jcs .L445
	move.b 6(%a0),%d2
	moveq #11,%d4
	mvz.b %d2,%d0
	cmp.l %d0,%d4
	jcs .L445
	mvz.b 7(%a0),%d0
	lsr.l #4,%d0
	jne .L445
	tst.b 8(%a0)
	jlt .L445
	mov3q.l #3,%d6
	cmp.l %d1,%d6
	jge .L509
	tst.b 9(%a0)
	jlt .L445
	mov3q.l #5,%d7
	cmp.l %d1,%d7
	jne .L509
	tst.b 10(%a0)
	jlt .L445
.L509:
	move.l %d3,%d0
	sub.l ux+3884,%d0
	lea ux,%a1
	lsr.l #3,%d0
	jeq .L510
	addq.l #1,ux+28
	jra .L454
.L510:
	mov3q.l #7,%d0
	and.l %d3,%d0
	mov3q.l #3,%d5
	move.l %d0,%d4
	add.l #972,%d4
	move.b %d2,(%a1,%d4.l*4)
	lea (%a1,%d0.l*4),%a2
	move.b 7(%a0),3889(%a2)
	move.b 8(%a0),3890(%a2)
	cmp.l %d1,%d5
	jlt .L511
	clr.b %d6
	move.b %d6,3891(%a2)
.L512:
	clr.b %d1
.L514:
	add.l %d0,%a1
	addq.l #1,%d3
	move.b %d1,3952(%a1)
	move.l %d3,ux+3880
	addq.l #1,ux+16
	jra .L454
.L511:
	move.b 9(%a0),3891(%a2)
	subq.l #5,%d1
	tst.l %d1
	jne .L512
	move.b 10(%a0),%d1
	jra .L514
.L461:
	subq.l #4,%d1
	tst.l %d1
	jne .L445
	move.l %a0,%d1
	add.l #10,%d1
	lea (6,%a0),%a1
.L517:
	mvz.b (%a1),%d0
	moveq #111,%d2
	cmp.l %d0,%d2
	jcc .L516
	moveq #127,%d3
	cmp.l %d0,%d3
	jne .L445
.L516:
	addq.l #1,%a1
	cmp.l %a1,%d1
	jne .L517
	addq.l #1,pg_gen
	clr.l %d0
	lea pg_req,%a1
.L518:
	lea 6(%a0,%d0.l),%a2
	mov3q.l #4,%d1
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L518
	addq.l #1,pg_gen
	jra .L454
.L459:
	tst.l %d1
	jeq .L445
	move.b 6(%a0),%d0
	moveq #127,%d2
	and.l %d2,%d0
	bset #8,%d0
	move.l %d0,splash_req
	jra .L454
.L458:
	move.l %d0,%d4
	moveq #37,%d3
	add.l #-10,%d4
	cmp.l %d4,%d3
	jcs .L445
	clr.l 52(%sp)
	moveq #127,%d5
	clr.l 56(%sp)
	moveq #14,%d6
	clr.l 60(%sp)
	clr.l 64(%sp)
	clr.l 68(%sp)
	clr.l 72(%sp)
	clr.l 48(%sp)
	clr.l 44(%sp)
	mov3q.l #1,%a6
	move.b 8(%a0),%d1
	move.b 7(%a0),%d2
	move.b 6(%a0),%d0
	and.l %d5,%d1
	and.l %d5,%d2
	and.l %d5,%d0
	lsl.l %d6,%d1
	lsl.l #7,%d2
	or.l %d2,%d1
	clr.l %d2
	or.l %d0,%d1
.L521:
	cmp.l %d2,%d4
	jgt .L524
	mvz.w %d1,%d1
	lea (44,%sp),%a0
	clr.l %d0
	lea mask_keys,%a1
	move.l %d1,mask_enc
.L525:
	move.l (%a0)+,(%a1,%d0.l*4)
	moveq #8,%d6
	addq.l #1,%d0
	cmp.l %d0,%d6
	jne .L525
	mov3q.l #1,mask_set
	addq.l #1,masks
	jra .L454
.L524:
	move.w %d2,%d0
	mvz.b 9(%a0,%d2.l),%d6
	clr.l %d3
	mulu.w #7,%d0
.L523:
	btst %d3,%d6
	jeq .L522
	cmp.l #255,%d0
	jgt .L522
	moveq #31,%d7
	and.l %d0,%d7
	move.l %a6,%d5
	lsl.l %d7,%d5
	move.l %d0,%d7
	asr.l #5,%d7
	or.l %d5,44(%sp,%d7.l*4)
.L522:
	addq.l #1,%d3
	addq.l #1,%d0
	mov3q.l #7,%d5
	cmp.l %d3,%d5
	jne .L523
	addq.l #1,%d2
	jra .L521
.L453:
	mov3q.l #5,%d7
	cmp.l %d1,%d7
	jge .L526
	move.b 7(%a0),%d1
	moveq #63,%d2
	mvz.b %d1,%d5
	cmp.l %d5,%d2
	jcs .L526
	move.b 8(%a0),%d4
	jmi .L526
	mvz.b 9(%a0),%d2
	lsr.l #6,%d2
	jne .L526
	mvz.b 10(%a0),%d2
	moveq #16,%d6
	cmp.l %d2,%d6
	jcs .L526
	move.l %d0,%d2
	moveq #32,%d7
	add.l #-13,%d2
	cmp.l %d2,%d7
	jge .L544
.L526:
	clr.b %d0
	addq.l #1,rx_bad
	move.b %d0,st_valid
	jra .L444
.L529:
	move.b 12(%a0,%d3.l),%d0
	moveq #94,%d6
	add.l #-32,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d6
	jcc .L528
	clr.b %d7
	addq.l #1,rx_bad
	move.b %d7,st_valid
	jra .L444
.L528:
	addq.l #1,%d3
.L527:
	cmp.l %d2,%d3
	jlt .L529
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
.L530:
	cmp.l %d2,%d1
	jlt .L531
	add.l %d0,%a6
	clr.b %d0
	moveq #1,%d1
	addq.l #6,%a0
	move.b %d0,8(%a6,%d2.l)
	move.b %d1,st_valid
	move.b (%a0),st_seq
	jra .L454
.L544:
	clr.l %d3
	jra .L527
.L531:
	lea 12(%a0,%d1.l),%a2
	move.b (%a2),8(%a1,%d1.l)
	addq.l #1,%d1
	jra .L530
.L452:
	tst.l %d1
	jeq .L445
	lea txt_st+4,%a1
	moveq #64,%d0
.L533:
	clr.b (%a1)
	subq.l #1,%d0
	lea (44,%a1),%a1
	tst.l %d0
	jne .L533
	moveq #1,%d2
	addq.l #6,%a0
	move.b (%a0),st_seq
	move.b %d2,st_valid
	jra .L454
.L451:
	mov3q.l #5,%d3
	cmp.l %d1,%d3
	jge .L445
	move.b 6(%a0),%d1
	moveq #15,%d4
	mvz.b %d1,%d5
	cmp.l %d5,%d4
	jcs .L445
	add.l #-13,%d0
	moveq #11,%d6
	cmp.l %d0,%d6
	jlt .L445
	lea bind_gen,%a2
	addq.l #1,(%a2,%d5.l*4)
	move.b 7(%a0),%d3
	mvz.b %d3,%d4
	lsr.l #6,%d4
	jeq .L536
	st %d3
.L536:
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
.L537:
	cmp.l %d0,%d1
	jlt .L539
	mvz.b 6(%a0),%d0
	addq.l #1,(%a2,%d0.l*4)
	jra .L454
.L539:
	move.b 12(%a0,%d1.l),%d3
	moveq #94,%d5
	move.l %d3,%d4
	add.l #-32,%d4
	mvz.b %d4,%d4
	cmp.l %d4,%d5
	jcc .L538
	move.b %d2,%d3
.L538:
	move.b %d3,6(%a1,%d1.l)
	addq.l #1,%d1
	jra .L537
.L498:
	tst.l %d4
	jne .L497
	jra .L501
	.size	rui_sysex, .-rui_sysex
	.align	2
	.type	ov_suffix, @function
ov_suffix:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	clr.l %d0
.L585:
	move.l 20(%sp),%a0
	tst.b (%a0,%d0.l)
	jne .L586
	cmp.l %d1,%d0
	jle .L591
.L589:
	clr.l %d0
.L584:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L586:
	addq.l #1,%d0
	jra .L585
.L590:
	move.l 20(%sp),%a2
	mvs.b (%a0,%a1.l),%d2
	mvs.b (%a2,%a1.l),%d1
	cmp.l %d2,%d1
	jne .L589
	addq.l #1,%a1
.L587:
	cmp.l %a1,%d0
	jne .L590
	mov3q.l #1,%d0
	jra .L584
.L591:
	add.l 12(%sp),%d1
	sub.l %a1,%a1
	move.l %d1,%a0
	sub.l %d0,%a0
	jra .L587
	.size	ov_suffix, .-ov_suffix
	.text
.LC0:
	.string	"List"
.LC1:
	.string	"Browser"
.LC2:
	.string	"MenuView"
.LC3:
	.string	"QuickMuteMenuView"
.LC4:
	.string	"Window"
.LC5:
	.string	"ListView"
	.text
	.align	2
	.type	overlay, @function
overlay:
	lea (-20,%sp),%sp
	move.l 24(%sp),%d0
	movem.l #7180,(%sp)
	cmp.l ov_vt.l,%d0
	jne .L593
.L605:
	move.l ov_is,%d0
	jra .L592
.L593:
	move.l %d0,%d1
	add.l #-1073742852,%d1
	move.l %d0,ov_vt
	clr.l ov_is
	clr.l ov_list
	addq.l #1,ov_n
	cmp.l #2997243,%d1
	jls .L595
.L596:
	clr.l %d0
.L592:
	movem.l (%sp),#7180
	lea (20,%sp),%sp
	rts
.L595:
	mov3q.l #3,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L596
	move.l %d0,%a0
	move.l -4(%a0),%d0
	move.l %d0,%d1
	add.l #-1073742848,%d1
	cmp.l #2997247,%d1
	jhi .L596
	btst #0,%d0
	jne .L596
	move.l %d0,%a0
	move.l 4(%a0),%a2
	move.l %a2,%d0
	add.l #-1073742848,%d0
	cmp.l #2997247,%d0
	jhi .L596
.L597:
	move.b (%a2),%d0
	moveq #9,%d1
	add.l #-48,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jcc .L598
	clr.l %d2
.L599:
	tst.b (%a2,%d2.l)
	jne .L600
	pea .LC5
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	lea ov_suffix,%a3
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L602
	pea .LC0
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L602
	pea .LC1
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
.L602:
	pea .LC2
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	move.l %d0,ov_list
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L603
	moveq #17,%d1
	cmp.l %d2,%d1
	jne .L604
	pea .LC3
	pea 17.w
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	mov3q.l #1,%d1
	eor.l %d1,%d0
.L604:
	move.l %d0,ov_is
	jra .L605
.L598:
	addq.l #1,%a2
	jra .L597
.L600:
	addq.l #1,%d2
	moveq #48,%d0
	cmp.l %d2,%d0
	jne .L599
	jra .L596
.L603:
	pea .LC4
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L606
	mov3q.l #1,ov_is
	jra .L605
.L606:
	lea ov_names,%a4
	clr.l %d3
.L610:
	move.l (%a4)+,%a0
	clr.l %d0
.L607:
	tst.b (%a0,%d0.l)
	jne .L608
	cmp.l %d0,%d2
	jne .L609
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L609
	mov3q.l #1,ov_is
.L609:
	addq.l #1,%d3
	moveq #14,%d0
	cmp.l %d3,%d0
	jne .L610
	jra .L605
.L608:
	addq.l #1,%d0
	jra .L607
	.size	overlay, .-overlay
	.align	2
	.type	sv_tick, @function
sv_tick:
	lea (-52,%sp),%sp
	clr.l %d0
	movem.l #31996,(%sp)
	move.l 56(%sp),%a4
	clr.l %d6
	clr.l sv+80
	sub.l %a5,%a5
	move.l 28(%a4),%a2
	sub.l %a6,%a6
	lea (20,%a4),%a0
	clr.l %d5
	clr.l %d7
	clr.l %d2
	move.b 1093765506,%d1
	move.l %a0,48(%sp)
	move.b %d1,47(%sp)
	mvz.b %d1,%d4
.L622:
	tst.l %a2
	jeq .L634
	cmp.l 48(%sp),%a2
	jeq .L634
	move.l 8(%a2),%a3
	tst.l %a3
	jeq .L623
	move.l (%a3),%d3
	tst.l %d2
	jeq .L624
	cmp.l #1075718412,%d3
	jeq .L625
	cmp.l #1075712228,%d3
	jeq .L625
	cmp.l #1075719596,%d3
	jeq .L625
	cmp.l #1075717140,%d3
	jne .L624
.L625:
	move.l (%a2),%a2
.L626:
	addq.l #1,%d5
	moveq #16,%d1
	cmp.l %d5,%d1
	jne .L622
.L634:
	cmp.l sv+84.l,%d0
	jne .L636
	cmp.l sv+88.l,%a6
	jeq .L637
.L636:
	move.l %d0,sv+84
	move.l %a6,sv+88
	clr.l sv+96
.L638:
	clr.b %d0
	move.l %d5,sv+92
	move.b %d0,sv+10
	tst.l %d7
	jeq .L639
	moveq #16,%d1
	cmp.l %d5,%d1
	jeq .L639
	tst.l %a2
	jne .L640
.L639:
	clr.l sv+80
.L623:
	move.l %d4,%d0
	addq.l #1,%d0
	cmp.l ls_smpl.l,%d0
	jne .L645
	moveq #11,%d0
	cmp.l %d4,%d0
	jlt .L645
	mvz.b sv+10,%d2
	tst.l %d2
	jne .L646
.L647:
	tst.b sv.l
	jeq .L649
	clr.b %d1
	moveq #1,%d5
	lea sv+1,%a0
	move.b (%a0),sv+5
	addq.l #1,sv+60
	move.b %d1,sv
	move.b %d5,sv+4
	move.b %d1,sv+6
	jra .L649
.L624:
	move.l %d3,%a6
	cmp.l #1075721468,%d3
	jne .L627
	move.l %a3,sv+80
	mov3q.l #1,%d7
.L628:
	tst.l %d2
	jeq .L630
	lea sv_covers,%a0
	clr.l %d0
.L631:
	cmp.l (%a0),%d3
	jne .L633
.L662:
	move.l %d2,%d6
.L630:
	cmp.l #1076055292,%d3
	seq %d3
	move.l (%a2),%a2
	move.l %a3,%d0
	mvs.b %d3,%d3
	neg.l %d3
	or.l %d3,%d2
	jra .L626
.L627:
	cmp.l #1075720560,%d3
	jne .L629
	mov3q.l #2,%d0
	or.l %d0,%d7
	jra .L628
.L629:
	cmp.l #1075628548,%d3
	jne .L628
	tst.b 132(%a3)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d6
	jra .L628
.L633:
	addq.l #4,%a0
	addq.l #1,%d0
	moveq #8,%d1
	cmp.l %d0,%d1
	jne .L631
	move.l %d3,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jne .L662
	move.l %d2,%a5
	jra .L630
.L637:
	move.l sv+96,%d0
	cmp.l #65534,%d0
	jhi .L638
	addq.l #1,%d0
	move.l %d0,sv+96
	jra .L638
.L640:
	mov3q.l #1,%d5
	eor.l %d5,%d2
	or.l %d6,%d2
	tst.l %a5
	jeq .L642
	cmp.l #1076055292,%a6
	jeq .L642
	moveq #59,%d1
	cmp.l sv+96.l,%d1
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d2
.L642:
	addq.l #1,%d2
	btst #0,%d7
	jne .L644
	move.b %d2,sv+10
	clr.l sv+80
	jra .L623
.L644:
	moveq #11,%d5
	cmp.l %d4,%d5
	jlt .L645
.L646:
	move.b 47(%sp),%d1
	moveq #127,%d0
	and.l -2147457096,%d0
	ext.w %d1
	mulu.w #2531,%d0
	mulu.w #152,%d1
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	move.b (%a0),%d3
	mvz.b %d3,%d5
	move.l %d5,-(%sp)
	move.l %d4,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	moveq #127,%d1
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jeq .L647
	tst.b sv.l
	jeq .L648
	mvz.b sv+1,%d0
	cmp.l %d4,%d0
	jne .L648
	mvz.b sv+2,%d0
	cmp.l %d0,%d5
	jeq .L649
.L648:
	moveq #1,%d5
	move.b 47(%sp),%d1
	move.w #257,%d0
	move.b %d3,sv+2
	lea commits,%a0
	move.l (%a0),sv+12
	addq.l #1,sv+56
	move.b %d5,sv
	move.b %d1,sv+1
	move.b %d5,sv+4
	move.b %d1,sv+5
	move.w %d0,sv+6
.L649:
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	seq %d6
	move.l 60(%sp),%d1
	neg.l %d6
	move.b %d6,sv+3
	cmp.l sv+20.l,%d1
	jeq .L652
	clr.l sv+16
	sub.l %a0,%a0
.L653:
	move.b sv,%d0
	move.l 60(%sp),%d5
	move.l sv+12,%d1
	move.l %d5,sv+20
	move.l st+4,%d7
	move.l st+972,%d5
	move.w %d0,%a1
	tst.b %d0
	jeq .L654
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	jne .L655
.L654:
	clr.l %d3
.L656:
	cmp.l commits.l,%d1
	sne %d0
	tst.l %d7
	sne %d7
	tst.l %d5
	sne %d5
	move.l %a1,%d1
	add.l %d6,%d6
	move.b %d3,%d4
	move.b %d3,sv+8
	neg.l %d0
	neg.l %d7
	lsl.l #2,%d0
	lsl.l #4,%d7
	neg.l %d5
	lsl.l #5,%d5
	or.l %d7,%d0
	or.l %d1,%d0
	or.l %d5,%d0
	moveq #19,%d5
	cmp.l %a0,%d5
	scs %d1
	mvz.b sv+101,%d5
	or.l %d6,%d0
	neg.l %d1
	lsl.l #3,%d1
	or.l %d1,%d0
	move.l %d3,%d1
	lsl.l #6,%d1
	or.l %d1,%d0
	mvz.b %d0,%d1
	cmp.l %d5,%d1
	jne .L657
	move.l sv+104,%a0
	cmp.l sv+88.l,%a0
	jne .L657
	tst.l %d2
	jeq .L658
	move.l st+8,%d1
	moveq #19,%d5
	sub.l sv+108,%d1
	cmp.l %d1,%d5
	jge .L658
.L657:
	moveq #1,%d1
	move.b %d1,sv+102
.L658:
	move.b %d0,sv+100
	mvz.b %d4,%d0
	mvz.b sv+9,%d1
	cmp.l %d0,%d1
	jeq .L621
	tst.l %d3
	jeq .L660
	addq.l #1,sv+72
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
.L661:
	moveq #1,%d0
	move.b %d4,sv+9
	move.b %d0,32(%a4)
.L621:
	movem.l (%sp),#31996
	lea (52,%sp),%sp
	rts
.L645:
	clr.l %d2
	jra .L647
.L652:
	move.l sv+16,%a0
	cmp.l #65534,%a0
	jhi .L653
	addq.l #1,%a0
	move.l %a0,sv+16
	jra .L653
.L655:
	cmp.l commits.l,%d1
	jeq .L654
	moveq #19,%d0
	cmp.l %a0,%d0
	jcs .L654
	move.l %d7,%d3
	or.l %d5,%d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
	jra .L656
.L660:
	subq.l #2,%d2
	tst.l %d2
	jne .L661
	addq.l #1,sv+76
	jra .L661
	.size	sv_tick, .-sv_tick
	.align	2
	.type	enter, @function
enter:
	move.l %d2,-(%sp)
	move.b 15(%sp),%d1
	tst.l st+4
	jne .L708
	tst.l st+972
	jeq .L710
	clr.l st+972
	mov3q.l #6,st+988
.L710:
	lea commits,%a0
	moveq #16,%d0
	move.l (%a0),st+24
	mov3q.l #1,st+4
	clr.l st+12
	mov3q.l #-1,st+20
	lea st+96,%a0
	addq.l #1,st+48
.L711:
	clr.l (%a0)+
	subq.l #1,%d0
	tst.l %d0
	jne .L711
	lea st+408,%a0
.L712:
	clr.l (%a0)+
	moveq #16,%d2
	addq.l #1,%d0
	cmp.l %d0,%d2
	jne .L712
	mvz.b %d1,%d0
	lea (19,%sp),%a0
	move.b (%a0),st+993
	move.l 8(%sp),%a0
	bset #8,%d0
	move.b %d1,st+162
	clr.l st+196
	move.l %d0,st+296
	moveq #1,%d0
	move.b %d0,st+161
	move.b %d0,st+163
	move.b %d0,mr+13
	move.b %d0,mr+19
	move.b %d0,32(%a0)
.L708:
	move.l (%sp)+,%d2
	rts
	.size	enter, .-enter
	.align	2
	.type	leave, @function
leave:
	move.l %d2,-(%sp)
	move.b 15(%sp),%d1
	tst.l st+4
	jeq .L715
	clr.l st+4
	clr.l st+1038
	addq.l #1,st+52
	clr.l st+1058
	clr.l st+196
	tst.l nk
	jeq .L717
	moveq #-33,%d0
	moveq #32,%d2
	and.l %d0,st+240
	or.l %d2,st+272
	clr.l nk
.L717:
	clr.l %d0
	lea kq_nodown,%a1
	lea kq_owed,%a0
.L718:
	clr.l (%a1,%d0.l)
	moveq #32,%d2
	clr.l (%a0,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d2
	jne .L718
	mvs.b %d1,%d0
	moveq #1,%d2
	lea commits,%a0
	move.b %d1,st+162
	move.l %d0,st+296
	clr.b %d0
	clr.l kq_owes
	move.l (%a0),sv+12
	move.b %d2,st+161
	move.b %d0,st+163
	move.b %d0,st+993
	tst.l sq+408
	jne .L719
	clr.l st+1006
	jsr led_restore
.L719:
	moveq #1,%d0
	move.l 8(%sp),%a0
	move.b %d0,32(%a0)
.L715:
	move.l (%sp)+,%d2
	rts
	.size	leave, .-leave
	.align	2
	.type	queue_key, @function
queue_key:
	lea (-20,%sp),%sp
	movem.l #1084,(%sp)
	move.l 24(%sp),%d3
	tst.l txsx_test
	jeq .L722
	move.l st+8,%d0
	mov3q.l #1,txsx_test_on
	add.l txsx_test,%d0
	clr.l txsx_test
	move.l %d0,txsx_test_end
.L722:
	tst.l kq_owes
	jeq .L723
	jsr (kq_owed_in.part.0)
.L723:
	moveq #31,%d1
	mov3q.l #1,%d0
	and.l %d3,%d1
	move.l %d3,%d2
	lsr.l #5,%d2
	lea kq_nodown,%a0
	move.l (%a0,%d2.l*4),%d4
	lsl.l %d1,%d0
	tst.l 28(%sp)
	jeq .L724
	move.l %d0,%d1
	not.l %d1
	and.l %d4,%d1
	move.l %d1,(%a0,%d2.l*4)
	tst.l kq_owes
	jne .L725
	move.l st+196,%d1
	moveq #15,%d5
	move.l %d1,%a1
	addq.l #6,%a1
	cmp.l %a1,%d5
	jcc .L726
.L725:
	or.l %d0,%d4
	addq.l #1,st+44
	move.l %d4,(%a0,%d2.l*4)
.L721:
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L724:
	move.l %d4,%d1
	and.l %d0,%d1
	tst.l %d1
	jeq .L728
	not.l %d0
	and.l %d4,%d0
	move.l %d0,(%a0,%d2.l*4)
	jra .L721
.L728:
	move.l st+196,%d1
	moveq #15,%d4
	cmp.l %d1,%d4
	jcc .L726
	move.l %d1,%a1
	subq.l #1,%a1
	lea st+164,%a0
.L729:
	tst.l %a1
	jlt .L730
	mvz.b (%a0,%a1.l*2),%d4
	cmp.l %d4,%d3
	jne .L731
	move.l %a1,%d3
	add.l %d3,%d3
	move.l %d3,%d4
	add.l #st,%d4
	move.l %d4,%a2
	tst.b 165(%a2)
	jeq .L730
	add.l %d3,%a0
.L732:
	addq.l #1,%a1
	cmp.l %d1,%a1
	jlt .L733
	subq.l #1,%d1
	move.l %d1,st+196
	addq.l #1,st+44
	jra .L721
.L731:
	subq.l #1,%a1
	jra .L729
.L733:
	addq.l #2,%a0
	move.b (%a0),-2(%a0)
	move.b 1(%a0),-1(%a0)
	jra .L732
.L730:
	lea kq_owed,%a0
	move.l (%a0,%d2.l*4),%d1
	move.l %d1,%d3
	and.l %d0,%d3
	tst.l %d3
	jne .L721
	or.l %d0,%d1
	addq.l #1,kq_owes
	move.l %d1,(%a0,%d2.l*4)
	jra .L721
.L726:
	lea st,%a0
	move.l %d1,%d0
	add.l #82,%d0
	move.b %d3,(%a0,%d0.l*2)
	lea (%a0,%d1.l*2),%a0
	addq.l #1,%d1
	move.l %d1,st+196
	move.b 31(%sp),165(%a0)
	jra .L721
	.size	queue_key, .-queue_key
	.align	2
	.globl	cu_setup
	.type	cu_setup, @function
cu_setup:
	lea (-28,%sp),%sp
	movem.l #7228,(%sp)
	move.l 32(%sp),%d3
	mov3q.l #1,-(%sp)
	move.l %d3,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	move.l %d0,%a3
	tst.l %d0
	jeq .L737
	move.l %d3,-(%sp)
	jsr cu_src_setup
	mvz.b cu+1,%d0
	move.l %d3,%d4
	addq.l #4,%sp
	add.l #-46,%d4
	cmp.l %d0,%d3
	jne .L739
	move.l 1075597888,%d0
	cmp.l 4(%a3),%d0
	jne .L739
	move.l 1075596172,%d0
	cmp.l 102(%a3),%d0
	jne .L739
	move.l 1075597884,%d1
	mov3q.l #6,%d0
	cmp.l %d4,%d0
	jcs .L743
	lea CSWTCH.493,%a0
	move.l (%a0,%d4.l*4),%d0
.L740:
	cmp.l %d0,%d1
	jeq .L737
.L739:
	move.l %a3,%d5
	move.l %a3,%d2
	lea cu_p2,%a2
	add.l #112,%d5
	lea CSWTCH.493,%a4
	lea cu_knob,%a3
.L742:
	mov3q.l #6,%d0
	cmp.l %d4,%d0
	jcs .L744
	move.l (%a4,%d4.l*4),%d0
.L741:
	move.l %d0,-(%sp)
	mvs.w (%a2)+,%d0
	move.l %d2,-(%sp)
	add.l #14,%d2
	move.l %d0,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	cmp.l %d2,%d5
	jne .L742
	move.w cu+2,%d0
	move.b %d3,cu+1
	addq.l #1,%d0
	move.w %d0,cu+2
.L737:
	movem.l (%sp),#7228
	lea (28,%sp),%sp
	rts
.L743:
	move.l #cu_fm_short,%d0
	jra .L740
.L744:
	move.l #cu_fm_short,%d0
	jra .L741
	.size	cu_setup, .-cu_setup
	.align	2
	.type	isr_send, @function
isr_send:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jeq .L750
.L758:
	clr.l %d0
.L749:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L750:
#APP
| 1531 "rui.c" 1
	move.w %sr,%d0
| 0 "" 2
#NO_APP
	move.l %d0,%d3
	move.l %d0,%d2
	and.l #1792,%d3
	mvz.w %d2,%d2
	cmp.l #1279,%d3
	jhi .L752
	and.l #63743,%d0
	or.l #1280,%d0
#APP
| 1535 "rui.c" 1
	move.w %d0,%sr
| 0 "" 2
#NO_APP
.L752:
	tst.l 1123449384
	jeq .L753
.L755:
#APP
| 1540 "rui.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	addq.l #1,sq+388
	jra .L758
.L753:
	tst.l 1094562372
	jne .L755
	move.l %d1,%d0
	add.l 1094562392,%d0
	cmp.l #3800,%d0
	jgt .L755
	move.l 1094562704,%a0
	tst.l %a0
	jeq .L755
	move.l 52(%a0),%a0
	tst.l %a0
	jeq .L755
	move.l 52(%a0),%d0
	move.l 12(%sp),-(%sp)
	move.l %d1,-(%sp)
	jsr 1073752544
#APP
| 1540 "rui.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	mov3q.l #1,%d0
	addq.l #8,%sp
	jra .L749
	.size	isr_send, .-isr_send
	.align	2
	.globl	rui_render_in
	.type	rui_render_in, @function
rui_render_in:
	link.w %fp,#-108
	movem.l #1052,(%sp)
	tst.l 1094562372
	jne .L766
	mov3q.l #1,txsx_gap
.L766:
	lea fp,%a0
	addq.l #1,(%a0)
	tst.l fp+8
	jeq .L765
	move.l (%a0),%d0
	sub.l fp+4,%d0
	cmp.l #3000,%d0
	jls .L765
	move.l fp+8,%a0
	move.l fp,%d0
	move.l fp+4,%d1
	move.l 1123449124,%d3
	tst.l fp+12
	jeq .L768
	move.l fp,%a1
	sub.l fp+12,%a1
	cmp.l #7499,%a1
	jls .L765
.L768:
	cmp.l %a0,%d3
	seq %d2
	sub.l %d1,%d0
	lea (-90,%fp),%a1
	clr.l %d1
	move.l %a1,%a2
	neg.l %d2
.L769:
	clr.l (%a2)+
	moveq #9,%d4
	addq.l #1,%d1
	cmp.l %d1,%d4
	jne .L769
	cmp.l %a0,%d3
	jeq .L770
	mov3q.l #1,%d3
	move.l 72(%a0),%a0
	move.l %a0,%d1
	and.l %d3,%d1
	move.l %a0,%d4
	btst #0,%d4
	jne .L770
	move.l %a0,%d3
	add.l #-1073741824,%d3
	cmp.l #129892303,%d3
	jhi .L770
.L771:
	lea 4(%a0,%d1.l),%a2
	moveq #36,%d3
	move.l (%a2),(%a1,%d1.l)
	addq.l #4,%d1
	cmp.l %d1,%d3
	jne .L771
.L770:
	move.w #19969,%a0
	move.l #-260222380,%d4
	move.b %d2,-48(%fp)
	move.l %d4,-54(%fp)
	move.w %a0,-50(%fp)
	cmp.l #191999,%d0
	jhi .L776
	mvz.w #1500,%d2
	divu.l %d2,%d0
.L772:
	move.b %d0,-47(%fp)
	lea (-46,%fp),%a0
	clr.l %d1
.L773:
	moveq #28,%d3
	moveq #21,%d4
	move.l (%a1)+,%d0
	move.l %d0,%d2
	lsr.l %d3,%d2
	moveq #127,%d3
	addq.l #1,%d1
	addq.l #5,%a0
	move.b %d2,-5(%a0)
	move.l %d0,%d2
	lsr.l %d4,%d2
	moveq #14,%d4
	and.l %d3,%d2
	move.b %d2,-4(%a0)
	move.l %d0,%d2
	lsr.l %d4,%d2
	and.l %d3,%d2
	move.b %d2,-3(%a0)
	move.l %d0,%d2
	lsr.l #7,%d2
	and.l %d3,%d0
	and.l %d3,%d2
	move.b %d0,-1(%a0)
	moveq #9,%d0
	move.b %d2,-2(%a0)
	cmp.l %d1,%d0
	jne .L773
	moveq #-9,%d1
	pea 54.w
	pea -54(%fp)
	move.b %d1,-1(%fp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L765
	lea fp,%a0
	tst.l (%a0)
	jeq .L777
	move.l (%a0),%d0
.L775:
	move.l %d0,fp+12
	addq.l #1,fp+16
.L765:
	movem.l -108(%fp),#1052
	unlk %fp
	rts
.L776:
	moveq #127,%d0
	jra .L772
.L777:
	mov3q.l #1,%d0
	jra .L775
	.size	rui_render_in, .-rui_render_in
	.align	2
	.globl	rui_uart
	.type	rui_uart, @function
rui_uart:
	lea (-40,%sp),%sp
	movem.l #19468,(%sp)
	clr.l %d2
	tst.b ov_on.l
	jne .L805
	tst.b ovp_on.l
	jne .L805
	tst.b ovt_on.l
	jeq .L792
.L805:
	move.l 44(%sp),%a0
	subq.l #1,%a0
	sub.l %a6,%a6
	lea rui_uart_raw,%a3
	move.l %a0,20(%sp)
	jra .L797
.L793:
	move.l 48(%sp),%a0
	mvz.b (%a0,%d2.l),%d0
	addq.l #1,%d2
	move.l %d0,-(%sp)
	jsr uart_byte
	addq.l #4,%sp
.L792:
	cmp.l 44(%sp),%d2
	jlt .L793
	clr.l %d0
.L790:
	movem.l (%sp),#19468
	lea (40,%sp),%sp
	rts
.L798:
	move.l 48(%sp),%a0
	move.l %d2,%d3
	addq.l #1,%d3
	mvz.b (%a0,%a6.l),%d0
	move.l %d0,-(%sp)
	jsr uart_byte
	move.b %d0,28(%sp,%d2.l)
	addq.l #4,%sp
	moveq #16,%d0
	cmp.l %d3,%d0
	jeq .L795
	cmp.l 20(%sp),%a6
	jne .L796
.L795:
	pea 24(%sp)
	move.l %d3,-(%sp)
	jsr (%a3)
	addq.l #8,%sp
	clr.l %d3
.L796:
	addq.l #1,%a6
	move.l %d3,%d2
.L797:
	cmp.l 44(%sp),%a6
	jlt .L798
	mov3q.l #1,%d0
	jra .L790
	.size	rui_uart, .-rui_uart
	.align	2
	.globl	rui_rec_note
	.type	rui_rec_note, @function
rui_rec_note:
	move.w pc+80,%a0
	move.l %d2,-(%sp)
	moveq #11,%d2
	move.l 8(%sp),%d1
	move.l 16(%sp),%d0
	addq.l #1,%a0
	move.w %a0,pc+80
	cmp.l %d1,%d2
	jcc .L807
.L811:
	clr.l %d0
.L806:
	move.l (%sp)+,%d2
	rts
.L807:
	tst.l sq
	jeq .L809
	move.l sq+4,%a0
	move.l %a0,%d2
	btst %d1,%d2
	jeq .L809
	addq.l #1,sq+448
	mov3q.l #1,%d0
	jra .L806
.L809:
	tst.l %d0
	jlt .L812
	moveq #63,%d2
	cmp.l %d0,%d2
	jlt .L813
.L810:
	lea pc,%a0
	move.b %d0,48(%a0,%d1.l)
	moveq #1,%d0
	lea st+8,%a1
	move.l (%a1),(%a0,%d1.l*4)
	move.b %d0,60(%a0,%d1.l)
	jra .L811
.L812:
	clr.b %d0
	jra .L810
.L813:
	moveq #63,%d0
	jra .L810
	.size	rui_rec_note, .-rui_rec_note
	.align	2
	.globl	sq_fire
	.type	sq_fire, @function
sq_fire:
	lea (-24,%sp),%sp
	moveq #11,%d0
	movem.l #3132,(%sp)
	move.l 28(%sp),%d2
	addq.l #1,sq+364
	lea sq,%a2
	cmp.l %d2,%d0
	jcs .L820
	mov3q.l #1,%d1
	cmp.l 1079807120.l,%d1
	jeq .L822
	clr.l sq+540
	clr.l sq+544
.L820:
	movem.l (%sp),#3132
	lea (24,%sp),%sp
	rts
.L822:
	move.l %d2,%a0
	add.l #1079807210,%a0
	move.b (%a0),%d3
	move.l sq+540,%a1
	move.l %a1,%d1
	lsr.l %d2,%d1
	mov3q.l #1,%d0
	move.l %d2,%a0
	add.l #sq,%a0
	and.l %d1,%d0
	mvz.b %d3,%d4
	btst #0,%d1
	jeq .L824
	mvz.b 516(%a0),%d1
	cmp.l %d4,%d1
	jeq .L825
.L826:
	clr.l %d0
.L824:
	mov3q.l #1,%d1
	lsl.l %d2,%d1
	move.l %a1,%d5
	move.b %d3,516(%a0)
	move.b 35(%sp),528(%a0)
	or.l %d1,%d5
	move.l sq+360,%d1
	move.l %d5,sq+540
	btst #8,%d1
	jeq .L828
	tst.l %d0
	jne .L820
	tst.l %d4
	jeq .L829
	tst.l sq+544
	jeq .L830
.L829:
	mvz.b sq+359,%d0
	move.l 1100784300,-(%sp)
	mov3q.l #2,-(%sp)
	move.l %d0,-(%sp)
	moveq #127,%d0
	and.l %d1,%d0
	move.l %d0,-(%sp)
	mov3q.l #3,-(%sp)
	jsr sq_event
	clr.l sq+360
	clr.l sq+544
	lea (20,%sp),%sp
.L830:
	lsr.l #7,%d4
	jne .L820
	tst.l (%a2)
	jeq .L820
	move.l sq+8,%d0
	btst %d2,%d0
	jeq .L820
	moveq #127,%d0
	and.l 32(%sp),%d0
	move.l #85760,%d1
	move.l %d2,%a0
	add.l #1079807269,%a0
	move.b (%a0),%d5
	muls.l %d1,%d0
	move.w %d5,%a1
	move.l %d0,%a0
	move.l #85689,%d0
	add.l #1081989347,%a0
	mvz.b (%a0,%d0.l),%d0
	subq.l #1,%d0
	tst.l %d0
	jne .L831
	mvz.w #917,%d0
	muls.l %d2,%d0
	add.l #709,%d0
	move.b (%a0,%d0.l),%d0
	jpl .L833
	moveq #127,%d0
.L833:
#APP
| 1531 "rui.c" 1
	move.w %sr,%d1
| 0 "" 2
#NO_APP
	move.l %d1,%d5
	move.l %d1,%d4
	and.l #1792,%d5
	mvz.w %d4,%d4
	cmp.l #1792,%d5
	jeq .L835
	and.l #63743,%d1
	or.l #1792,%d1
#APP
| 1535 "rui.c" 1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
.L835:
	move.l sq+268,%d1
	sub.l sq+272,%d1
	lsr.l #5,%d1
	jeq .L836
	addq.l #1,sq+380
.L837:
#APP
| 1540 "rui.c" 1
	move.w %d4,%sr
| 0 "" 2
#NO_APP
	jra .L820
.L825:
	mvz.b 528(%a0),%d1
	cmp.l 32(%sp),%d1
	jeq .L826
	addq.l #1,sq+548
	mov3q.l #1,sq+544
	jra .L824
.L828:
	tst.l %d0
	jne .L820
	jra .L830
.L831:
	move.l #85683,%d0
	move.b (%a0,%d0.l),%d0
	move.l #85684,%d1
	mvz.b (%a0,%d1.l),%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	moveq #127,%d1
	cmp.l %d0,%d1
	jcc .L833
	moveq #127,%d0
	jra .L833
.L836:
	moveq #31,%d1
	and.l sq+268,%d1
	move.l #1100784300,%a3
	move.l %d1,%d5
	addq.l #2,%d1
	lsl.l #3,%d5
	lsl.l #3,%d1
	move.l (%a3),12(%a2,%d5.l)
	move.b %d0,18(%a2,%d5.l)
	move.w %a1,%d0
	move.b %d2,(%a2,%d1.l)
	move.b %d3,1(%a2,%d1.l)
	addq.l #1,sq+268
	addq.l #1,sq+368
	move.b %d0,19(%a2,%d5.l)
	jra .L837
	.size	sq_fire, .-sq_fire
	.align	2
	.globl	sq_end
	.type	sq_end, @function
sq_end:
	lea (-104,%sp),%sp
	mov3q.l #2,%d0
	movem.l #23612,(%sp)
	move.l 1079807120,%d2
	moveq #127,%d5
	addq.l #1,sq+392
	move.b 1079807236,%d3
	move.l 1100784300,%d4
	move.l -66650100,%d1
	move.l %d1,32(%sp)
	and.l %d3,%d5
	move.l %d5,%d3
	cmp.l %d2,%d0
	jcc .L851
	clr.l %d2
.L851:
	tst.l sq+348
	jne .L852
	move.l %d2,sq+352
	move.l %d3,sq+356
	mov3q.l #1,sq+348
.L852:
	lea sq,%a6
	tst.l (%a6)
	jeq .L853
	cmp.l sq+352.l,%d2
	jeq .L854
	move.l %d2,%d1
	mvz.b %d1,%d1
	move.l %d4,-(%sp)
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr sq_event
	lea (20,%sp),%sp
.L854:
	move.l sq+356,%d0
	cmp.l %d0,%d3
	jeq .L855
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jne .L856
	bset #8,%d0
	move.l %d0,sq+360
.L853:
	move.l %d2,sq+352
	move.l %d3,sq+356
.L858:
	tst.l sq+344
	jne .L863
	move.l %sp,%d3
	move.l %sp,%d2
	add.l #42,%d3
	add.l #36,%d2
.L864:
	move.l sq+272,%d4
	cmp.l sq+268.l,%d4
	jne .L870
.L869:
	move.l -66650100,%d0
	sub.l 32(%sp),%d0
	cmp.l sq+396.l,%d0
	jls .L850
	move.l %d0,sq+396
.L850:
	movem.l (%sp),#23612
	lea (104,%sp),%sp
	rts
.L856:
	mvz.b %d0,%d0
	move.l %d4,-(%sp)
	mov3q.l #2,-(%sp)
	move.l %d5,-(%sp)
	move.l %d0,-(%sp)
	mov3q.l #3,-(%sp)
	jsr sq_event
	lea (20,%sp),%sp
.L857:
	move.l sq+360,%d0
	btst #8,%d0
	jeq .L853
	moveq #127,%d1
	and.l %d0,%d1
	move.l %d4,-(%sp)
	mov3q.l #2,-(%sp)
	move.l %d5,-(%sp)
	move.l %d1,-(%sp)
	mov3q.l #3,-(%sp)
	jsr sq_event
	clr.l sq+360
	lea (20,%sp),%sp
	jra .L853
.L855:
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jne .L857
	jra .L853
.L863:
	mvz.b sq+340,%d0
	move.l %d0,-(%sp)
	pea sq+276
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L850
	move.l sq+344,%d3
	clr.l %d1
	addq.l #1,sq+376
	lea sq+340,%a0
.L860:
	cmp.l %d3,%d0
	jlt .L862
	subq.l #1,%d3
	move.l %d3,sq+344
	jra .L858
.L862:
	mvz.w %d0,%d2
	lea sq+276,%a2
	sub.l %a1,%a1
	sub.l %d1,%a2
	lsl.l #4,%d2
.L861:
	move.l %a2,%d4
	add.l %d1,%d4
	move.l %d4,%a4
	addq.l #1,%a1
	move.b (%a4,%d2.l),(%a2)+
	moveq #16,%d4
	cmp.l %a1,%d4
	jne .L861
	move.b 1(%a0),(%a0)
	addq.l #1,%a0
	addq.l #1,%d0
	add.l #-16,%d1
	jra .L860
.L870:
	moveq #31,%d0
	clr.l %d4
	and.l sq+272,%d0
	move.w #11265,%a4
	move.l #-260222380,%a1
	move.l %a1,36(%sp)
	lsl.l #3,%d0
	move.w %a4,40(%sp)
	move.l 12(%a6,%d0.l),%d5
	move.l %d5,-(%sp)
	move.l %d3,-(%sp)
	jsr blk4
	addq.l #8,%sp
	move.l %d0,%a0
	addq.l #1,%a0
.L865:
	move.l sq+272,%d0
	add.l %d4,%d0
	cmp.l sq+268.l,%d0
	jeq .L866
	moveq #14,%d0
	cmp.l %d4,%d0
	jeq .L866
	move.l sq+272,%d0
	moveq #31,%d1
	add.l %d4,%d0
	and.l %d1,%d0
	lsl.l #3,%d0
	cmp.l 12(%a6,%d0.l),%d5
	jeq .L867
.L866:
	move.b %d4,46(%sp)
	move.b #-9,(%a0)+
	sub.l %d2,%a0
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L869
	add.l %d4,sq+272
	addq.l #1,sq+372
	jra .L864
.L867:
	move.l sq+272,%d0
	moveq #31,%d1
	add.l %d4,%d0
	and.l %d1,%d0
	addq.l #1,%d4
	move.l %d0,%d1
	addq.l #2,%d1
	lsl.l #3,%d1
	lsl.l #3,%d0
	move.b (%a6,%d1.l),(%a0)
	lea 1(%a6,%d1.l),%a1
	addq.l #4,%a0
	move.b (%a1),-3(%a0)
	lea (%a6,%d0.l),%a1
	move.b 18(%a1),-2(%a0)
	move.b 19(%a1),-1(%a0)
	jra .L865
	.size	sq_end, .-sq_end
	.align	2
	.globl	pin_frame
	.type	pin_frame, @function
pin_frame:
	lea (-72,%sp),%sp
	movem.l #31996,(%sp)
	move.l pin,%d0
	move.l #-2147458112,%d7
	move.l pin+4,%d4
	move.l -66650100,%d5
	move.l %d0,58(%sp)
	move.l %d4,64(%sp)
	move.l %d5,68(%sp)
	cmp.l 76(%sp),%d7
	jne .L891
	move.l pin+16,%d0
	move.l pin+12,%d1
	addq.l #1,pin+32
	move.l %d0,50(%sp)
	or.l 58(%sp),%d0
	or.l %d1,%d0
	jeq .L891
	move.l pin+20,%a1
	tst.l %a1
	jne .L893
	move.l 1075766284,%d0
	and.l #1048575,%d0
	or.l #-1341128704,%d0
	move.l %d0,%a1
	move.l %d0,pin+20
	move.l 1075767148,%d0
	and.l #1048575,%d0
	or.l #-1342177280,%d0
	move.l %d0,pin+24
	move.l 1075767148,%d0
	and.l #1048575,%d0
	or.l #805306368,%d0
	move.l %d0,pin+28
.L893:
	clr.b %d4
	clr.b %d5
	sub.l %a0,%a0
	clr.l %d3
	move.l pin+8,%d2
	clr.l %d6
	move.l pin+48,%a6
	move.b %d4,63(%sp)
	move.b %d5,62(%sp)
.L907:
	move.l %d3,%a2
	add.l #1076432344,%a2
	move.b (%a2),%d7
	mvz.w %d3,%d4
	lsl.l #3,%d4
	mvz.b %d7,%d0
	move.w %d7,%a5
	move.l %d0,%a4
	mov3q.l #1,%d0
	move.l %d4,%a2
	move.l %d4,%a3
	move.l %d4,46(%sp)
	moveq #11,%d4
	lsl.l %d3,%d0
	add.l #-2147457944,%a2
	add.l #-2147457880,%a3
	cmp.l %a4,%d4
	jcs .L894
	move.l 58(%sp),%d5
	move.l %a4,%d7
	btst %d7,%d5
	jeq .L894
	move.w %a5,%d5
	move.l %d0,%d7
	move.l %d0,%d4
	and.l %d2,%d7
	not.l %d4
	and.l %d4,%d1
	move.l %d4,54(%sp)
	move.l 64(%sp),%d4
	or.l %d0,%d6
	ext.w %d5
	move.l %d7,%a5
	move.l %a4,%d7
	mvz.w %d5,%d5
	add.l %d5,%d5
	move.l %d5,%a0
	add.l #-2147457084,%a0
	mvz.w (%a0),%d5
	btst %d7,%d4
	jeq .L895
	move.l #128,(%a3)
	move.l #128,(%a2)
	move.l %a1,4(%a3)
	move.l %a1,4(%a2)
	tst.l %a5
	jeq .L896
	addq.l #1,pin+44
.L896:
	moveq #1,%d0
	and.l 54(%sp),%d2
	move.b %d0,62(%sp)
.L897:
	move.l 46(%sp),%a2
	add.l #-2147457816,%a2
	clr.l (%a2)
	cmp.l #32512,%d5
	jeq .L912
	cmp.l #255,%d5
	jls .L900
	mvz.w %d3,%d0
	add.l %d0,%d0
	move.l %d0,%a3
	add.l #-2147458102,%a3
	move.w (%a3),%d4
	move.l %d0,%a2
	add.l #-2147458086,%a2
	move.w (%a2),%d0
	mulu.w #32512,%d4
	divu.l %d5,%d4
	cmp.l #65535,%d4
	jls .L901
	mvz.w #65535,%d4
.L901:
	mulu.w #32512,%d0
	move.w %d4,(%a3)
	divu.l %d5,%d0
	cmp.l #65535,%d0
	jls .L902
	mvz.w #65535,%d0
.L902:
	move.w %d0,(%a2)
.L900:
	moveq #1,%d0
	move.w #32512,(%a0)
	addq.l #1,%a6
	move.b %d0,63(%sp)
.L912:
	move.w #1,%a0
	jra .L899
.L895:
	tst.l %a5
	jeq .L898
	moveq #127,%d0
	moveq #127,%d4
	move.l %d0,(%a3)
	move.l pin+28,%d0
	move.l %d4,(%a2)
	move.l %d0,4(%a3)
	move.l %d0,4(%a2)
	jra .L897
.L898:
	moveq #1,%d4
	move.l pin+24,%d7
	move.l #1073741951,(%a3)
	move.l #1073741951,(%a2)
	move.l %d7,4(%a3)
	or.l %d0,%d2
	move.l %d7,4(%a2)
	addq.l #1,pin+40
	move.b %d4,62(%sp)
	jra .L897
.L894:
	move.l 50(%sp),%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L903
	move.l %d0,%d4
	not.l %d4
	and.l %d4,%d2
	moveq #1,%d4
	or.l %d0,%d1
	move.w #1,%a0
	move.b %d4,62(%sp)
.L903:
	move.l %d1,%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L899
	btst #6,(%a2)
	jeq .L905
	not.l %d0
	and.l %d0,%d1
	jra .L912
.L905:
	move.l #128,(%a3)
	move.l #128,(%a2)
	move.l %a1,4(%a3)
	move.l %a1,4(%a2)
.L899:
	addq.l #1,%d3
	moveq #8,%d5
	cmp.l %d3,%d5
	jne .L907
	tst.b 63(%sp)
	jeq .L908
	move.l %a6,pin+48
.L908:
	tst.b 62(%sp)
	jeq .L909
	move.l %d2,pin+8
.L909:
	move.w %a0,%d7
	tst.b %d7
	jeq .L910
	move.l %d1,pin+12
.L910:
	tst.l %d6
	jeq .L911
	addq.l #1,pin+36
.L911:
	move.l -66650100,%d0
	move.l %d6,pin+16
	sub.l 68(%sp),%d0
	cmp.l pin+52.l,%d0
	jls .L891
	move.l %d0,pin+52
.L891:
	movem.l (%sp),#31996
	lea (72,%sp),%sp
	rts
	.size	pin_frame, .-pin_frame
	.align	2
	.globl	ed_report
	.type	ed_report, @function
ed_report:
	move.l 4(%sp),%d0
	moveq #12,%d1
	move.l 16(%sp),%a0
	cmp.l %d0,%d1
	jcc .L939
.L941:
	clr.l %d1
.L940:
	move.l %d1,16(%sp)
	move.l %a0,%d1
	mvz.b %d1,%d1
	clr.l 12(%sp)
	move.l %d0,4(%sp)
	move.l %d1,8(%sp)
	jra ed_queue
.L939:
	mvz.w #4368,%d1
	btst %d0,%d1
	jeq .L941
	mov3q.l #3,%d1
	and.l 12(%sp),%d1
	jra .L940
	.size	ed_report, .-ed_report
	.align	2
	.globl	pm_menu_add
	.type	pm_menu_add, @function
pm_menu_add:
	link.w %fp,#-68
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	tst.l 8(%fp)
	jeq .L945
	lea (-64,%fp),%a2
	clr.l %d0
	move.l %a2,%a0
.L947:
	clr.l 12(%a0)
	clr.l 8(%a0)
	clr.l (%a0)
	clr.l 4(%a0)
	addq.l #1,%d0
	lea (16,%a0),%a0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L947
	mov3q.l #1,-(%sp)
	jsr 1074276820
	mov3q.l #4,-(%sp)
	move.l #pm_label,%d1
	move.l %d0,-64(%fp)
	move.l #1074764344,%d0
	move.l %d1,-52(%fp)
	move.l %d0,-56(%fp)
	jsr 1074276820
	mov3q.l #1,-(%sp)
	move.l %d0,%a3
	jsr 1074276820
	pea 84.w
	move.l #pm_icon,%d1
	move.l %d0,-32(%fp)
	move.l #1074764518,%d0
	move.l %d0,-24(%fp)
	move.l %d1,-20(%fp)
	jsr 1074276820
	lea (16,%sp),%sp
	move.l %d0,-68(%fp)
	tst.l -64(%fp)
	jeq .L945
	tst.l %a3
	jeq .L945
	tst.l -32(%fp)
	jeq .L945
	tst.l %d0
	jeq .L945
	move.l 8(%fp),(%a3)
	pea 8.w
	move.l #1074764426,%d0
	mov3q.l #-1,-(%sp)
	move.l #pm_action,%d1
	pea -16(%fp)
	pea -32(%fp)
	pea -48(%fp)
	move.l %a2,-(%sp)
	move.l %d0,-40(%fp)
	move.l %d1,-36(%fp)
	move.l %a3,-48(%fp)
	move.l -68(%fp),-(%sp)
	jsr 1074212688
	move.l -68(%fp),-(%sp)
	move.l 8(%fp),-(%sp)
	jsr 1074210694
	lea (36,%sp),%sp
	mov3q.l #3,-68(%fp)
.L948:
	mvz.w -66(%fp),%d0
	lsl.l #4,%d0
	pea (%a2,%d0.l)
	jsr 1075251654
	subq.l #1,-68(%fp)
	addq.l #4,%sp
	mov3q.l #-1,%d0
	cmp.l -68(%fp),%d0
	jne .L948
	addq.l #1,pm+4
.L945:
	move.l -76(%fp),%a2
	move.l -72(%fp),%a3
	unlk %fp
	rts
	.size	pm_menu_add, .-pm_menu_add
	.align	2
	.globl	pm_pick
	.type	pm_pick, @function
pm_pick:
	mvz.b 1093765506,%d0
	move.l 4(%sp),%a0
	moveq #11,%d1
	addq.l #1,pm+8
	cmp.l %d0,%d1
	jcc .L961
	addq.l #1,pm+24
	pea pm_t_track
.L965:
	move.l %a0,-(%sp)
	jsr pm_popup
	addq.l #8,%sp
	rts
.L961:
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L963
	move.l commits,%d1
	cmp.l pm+28.l,%d1
	jne .L964
.L963:
	addq.l #1,pm+20
	pea pm_t_none
	jra .L965
.L964:
	move.l (%a0),%a1
	addq.l #1,%d0
	move.l %a0,4(%sp)
	move.l %d0,pm
	move.l 128(%a1),%a1
	jmp (%a1)
	.size	pm_pick, .-pm_pick
	.align	2
	.globl	cu_prep
	.type	cu_prep, @function
cu_prep:
	tst.b cu.l
	jeq .L966
	move.l 4(%sp),-(%sp)
	addq.l #1,cu+12
	jsr cu_src_setup
	move.l 8(%sp),%d0
	add.l #-48,%d0
	lsr.l #1,%d0
	addq.l #4,%sp
	tst.l %d0
	jne .L966
	moveq #11,%d0
	cmp.l 8(%sp),%d0
	jcs .L966
	move.l #1075731444,%d1
	cmp.l sv+88.l,%d1
	jne .L966
	lea (7,%sp),%a0
	move.b (%a0),cu+9
	lea (11,%sp),%a0
	move.b (%a0),cu+10
	lea st+8,%a0
	move.l (%a0),cu+16
.L966:
	rts
	.size	cu_prep, .-cu_prep
	.align	2
	.globl	rui_tick
	.type	rui_tick, @function
rui_tick:
	link.w %fp,#-228
	move.l #1123449124,%a0
	move.l -66650100,%d1
	movem.l #15612,(%sp)
	lea fp,%a1
	move.l (%a0),fp+8
	move.l 8(%fp),%a2
	move.l (%a1),fp+4
	move.l %d1,-176(%fp)
	clr.l fp+12
.L969:
	mov3q.l #1,%d0
	cmp.l fp+20.l,%d0
	jeq .L969
.L970:
	mov3q.l #2,%d1
	cmp.l fp+20.l,%d1
	jeq .L971
	move.l 1100667228,%d0
	cmp.l #cu_text,%d0
	jeq .L972
	cmp.l 1100664624.l,%d0
	jne .L972
	move.l #cu_text,%d2
	move.l %d2,1100667228
.L972:
	tst.b cu.l
	jne .L973
	move.l #1128813124,%d3
	cmp.l 1073849308.l,%d3
	jne .L973
	pea 52.w
	move.l #cu_steps,%d5
	moveq #1,%d4
	move.l #cu_setup,%d6
	move.b %d4,cu
	jsr cu_src_setup
	move.l %d5,1073849316
	move.l %d6,1073849312
	addq.l #4,%sp
.L973:
	move.l rx,%d2
	move.l #-66650100,%a0
	addq.l #1,st+8
	move.l (%a0),st+300
	tst.l st
	jne .L974
	lea rui_sysex,%a1
	move.l %a1,1075551840
	move.l #1381321040,%a2
	move.l %a2,1075551836
	mov3q.l #1,st
	move.l %d2,st+16
.L975:
	move.l #ux,%d5
	jra .L1167
.L971:
	pea 10000.w
	jsr 1074367512
	addq.l #4,%sp
	jra .L970
.L974:
	tst.b host_close.l
	jeq .L976
	clr.b %d0
	lea commits,%a0
	move.b %d0,host_close
	move.b %d0,host_open
	move.l (%a0),sv+12
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	addq.l #8,%sp
.L976:
	tst.b host_open.l
	jeq .L977
	clr.b %d0
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	move.b %d0,host_open
	jsr enter
	lea (12,%sp),%sp
.L977:
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L978
	move.l st+956,%d0
	cmp.l #65534,%d0
	jhi .L979
	addq.l #1,%d0
	move.l %d0,st+956
	moveq #10,%d3
	cmp.l %d0,%d3
	jne .L979
	moveq #1,%d4
	move.l %d2,st+964
	mov3q.l #1,st+960
	move.b %d4,st+992
	move.b %d4,mr+13
	move.b %d4,mr+19
	jsr sq_forget
	lea commits,%a0
	move.l (%a0),pm+28
.L980:
	tst.b st+992.l
	jne .L984
.L985:
	tst.l splash_req
	jeq .L986
	move.l splash_req,%d0
	clr.l splash_req
	tst.l st+4
	jne .L987
	moveq #127,%d1
	and.l %d1,%d0
	tst.l %d0
	jeq .L988
	tst.l commits
	jne .L989
.L987:
	addq.l #1,st+984
.L986:
	tst.l st+4
	jeq .L991
	cmp.l st+16.l,%d2
	jeq .L992
	clr.l st+12
.L993:
	move.l %d2,st+16
	clr.b %d0
	move.l st+8,%a1
	lea st+408,%a0
	clr.l -184(%fp)
.L999:
	move.l (%a0)+,%d1
	tst.l %d1
	jeq .L997
	move.l %a1,%d3
	sub.l %d1,%d3
	jmi .L997
	moveq #1,%d0
	clr.l -4(%a0)
.L997:
	addq.l #1,-184(%fp)
	moveq #16,%d5
	cmp.l -184(%fp),%d5
	jne .L999
	tst.b %d0
	jeq .L1000
	mov3q.l #1,st+344
.L1000:
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr sv_tick
	addq.l #8,%sp
	tst.b ls.l
	jeq .L1001
	move.b ls+126,%d1
	lea sv,%a0
	move.b (%a0),%d0
	tst.b %d1
	jeq .L1002
	tst.b sv+8.l
	jne .L1003
	tst.b %d0
	jeq .L1004
	tst.b sv+3.l
	jne .L1004
	mvz.b sv+1,%d1
	mvz.b ls+1,%d0
	cmp.l %d1,%d0
	jne .L1004
	tst.l st+4
	jne .L1004
	move.l commits,%d6
	cmp.l sv+12.l,%d6
	jne .L1004
	move.l st+8,%d0
	moveq #20,%d7
	sub.l ls+128,%d0
	cmp.l %d0,%d7
	jcc .L1001
.L1004:
	move.l commits,%d3
	cmp.l sv+12.l,%d3
	jne .L1006
	move.l st+8,%d0
	moveq #20,%d4
	sub.l ls+128,%d0
	cmp.l %d0,%d4
	jcc .L1006
	move.l st+968,%d5
	addq.l #1,%d5
	move.l %d5,ls+132
	addq.l #1,ls+140
	jra .L1006
.L979:
	move.l st+960,%d3
	move.l %d3,%d1
	subq.l #1,%d1
	lsr.l #1,%d1
	jne .L980
	moveq #20,%d1
	moveq #20,%d5
	muls.l %d3,%d1
	cmp.l %d1,%d5
	seq %d1
	neg.l %d1
	tst.b %d1
	jeq .L981
	moveq #30,%d1
.L982:
	cmp.l %d1,%d0
	jne .L980
	cmp.l st+964.l,%d2
	jne .L983
	moveq #1,%d6
	addq.l #1,%d3
	move.l %d3,st+960
	move.b %d6,st+992
	move.b %d6,mr+13
	move.b %d6,mr+19
.L984:
	tst.b sv.l
	jeq .L985
	moveq #1,%d7
	move.w #257,%a1
	lea sv+1,%a0
	move.b (%a0),sv+5
	move.b %d7,sv+4
	move.w %a1,sv+6
	jra .L985
.L981:
	moveq #50,%d1
	jra .L982
.L983:
	mov3q.l #3,st+960
	jra .L980
.L978:
	clr.b %d0
	clr.l st+956
	clr.l st+960
	move.b %d0,st+992
	tst.l sq
	jeq .L985
	jsr sq_forget
	jra .L985
.L988:
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr splash_end
	addq.l #8,%sp
	jra .L986
.L989:
	tst.l st+972
	jne .L990
	mov3q.l #1,st+972
	addq.l #1,st+980
	mov3q.l #-1,st+20
	clr.l st+12
	mov3q.l #1,st+344
.L990:
	move.l %d0,st+976
.L991:
	tst.l st+972
	jeq .L993
	cmp.l st+16.l,%d2
	jeq .L994
	clr.l st+12
.L995:
	move.l st+976,%d0
	subq.l #1,%d0
	move.l %d0,st+976
	tst.l %d0
	jne .L993
	mov3q.l #1,-(%sp)
	jra .L1582
.L992:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d3
	cmp.l %d0,%d3
	jcc .L993
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	clr.l mask_set
.L1581:
	addq.l #8,%sp
	jra .L993
.L994:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d4
	cmp.l %d0,%d4
	jcc .L995
	mov3q.l #3,-(%sp)
.L1582:
	move.l %a2,-(%sp)
	jsr splash_end
	jra .L1581
.L1011:
	moveq #45,%d5
	cmp.l %d1,%d5
	jne .L1012
	jsr ls_dsps
	tst.l %d0
	jeq .L1009
	mov3q.l #3,%d0
	jra .L1013
.L1012:
	tst.b sv.l
	jeq .L1009
	tst.b sv+8.l
	jeq .L1009
	mvz.b sv+1,%d2
	mvz.b (%a1),%d1
	cmp.l %d2,%d1
	jne .L1009
	mvz.b sv+2,%d1
	cmp.l %d0,%d1
	jne .L1009
	clr.l %d0
.L1013:
	clr.l -(%sp)
	move.l %d0,-(%sp)
	jsr ls_enc
	addq.l #8,%sp
	tst.l %d0
	jeq .L1009
	clr.l u46+8
	addq.l #1,u46+28
	jra .L1009
.L1016:
	mvz.b %d2,%d2
	move.l %d2,-(%sp)
	clr.l -(%sp)
	move.l %a2,-(%sp)
	jsr enter
	lea (12,%sp),%sp
	addq.l #1,pm+12
.L1014:
	tst.l st+4
	jne .L1017
.L1018:
	tst.l st+1058
	jne .L1019
.L1020:
	tst.l st+4
	jeq .L1022
.L1026:
	tst.l st+1058
	jne .L1027
	move.l commits,%d2
	cmp.l st+20.l,%d2
	jne .L1028
	tst.l st+344
	jeq .L1027
.L1028:
	moveq #1,%d3
	move.b %d3,32(%a2)
	jra .L1027
.L1021:
	move.l sv+88,%d0
	cmp.l #1075650164,%d0
	jeq .L1023
	move.l %d0,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jeq .L1024
.L1023:
	mov3q.l #1,st+1062
	jra .L1020
.L1024:
	tst.l st+1062
	jne .L1025
	move.l st+8,%d0
	moveq #20,%d1
	sub.l st+1066,%d0
	cmp.l %d0,%d1
	jcc .L1020
.L1025:
	clr.l st+1058
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
	jra .L1020
.L1037:
	mvz.b %d2,%d2
	lea sq_grid,%a2
	moveq #11,%d6
	cmp.l %d2,%d6
	jcs .L1039
	move.l sq+4,%d0
	btst %d2,%d0
	jne .L1040
.L1039:
	clr.l %d0
.L1041:
	cmp.l sq+408.l,%d0
	jne .L1042
	tst.l %d0
	jeq .L1043
	cmp.l sq+412.l,%d2
	jeq .L1043
.L1042:
	mov3q.l #1,%d7
	or.l %d7,sq+404
	move.l %d0,sq+408
	move.l %d2,sq+412
.L1043:
	move.b 1093615249,%d0
	move.b 1093615250,%d2
	moveq #127,%d3
	move.b 1079807236,%d1
	and.l %d3,%d1
	move.l sq+360,%d3
	btst #8,%d3
	jeq .L1044
	move.l %d1,%d0
	moveq #127,%d1
	and.l %d3,%d1
.L1045:
	cmp.l %d1,%d0
	jeq .L1277
.L1046:
	cmp.l sq+420.l,%d1
	jne .L1047
	cmp.l sq+424.l,%d0
	jeq .L1048
.L1047:
	mov3q.l #4,%d5
	or.l %d5,sq+404
	move.l %d1,sq+420
	move.l %d0,sq+424
.L1048:
	jsr 1075320104
	move.l %d0,-(%sp)
	jsr 1073963888
	addq.l #4,%sp
	tst.l %d0
	sne %d2
	mvs.b %d2,%d2
	neg.l %d2
	jsr (%a2)
	cmp.l sq+428.l,%d2
	jne .L1049
	cmp.l sq+432.l,%d0
	jeq .L1050
.L1049:
	moveq #16,%d6
	or.l %d6,sq+404
	move.l %d2,sq+428
	move.l %d0,sq+432
.L1050:
	move.l 1076395164,%d0
	and.l #2097151,%d0
	cmp.l sq+436.l,%d0
	jeq .L1051
	moveq #32,%d7
	or.l %d7,sq+404
	move.l %d0,sq+436
.L1051:
	move.b 1081877443,%d0
	mvz.b 1081877444,%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #8191,%d0
	cmp.l sq+440.l,%d0
	jeq .L1052
	move.l %d0,sq+440
	moveq #8,%d0
	or.l %d0,sq+404
.L1052:
	move.b 1081877445,%d0
	mvz.b 1081877446,%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #8191,%d0
	cmp.l sq+552.l,%d0
	jeq .L1053
	mvz.w #128,%d1
	move.l %d0,sq+552
	or.l %d1,sq+404
.L1053:
	mov3q.l #1,%d3
	move.l 1079807120,%d2
	cmp.l %d2,%d3
	jne .L1054
	move.l st+8,%d0
	moveq #19,%d4
	sub.l sq+444,%d0
	cmp.l %d0,%d4
	jcc .L1054
	moveq #64,%d5
	or.l %d5,sq+404
.L1054:
	move.l sq+404,%d0
	btst #0,%d0
	jeq .L1055
	move.l sq+408,%d0
	move.b %d0,-140(%fp)
	tst.l %d0
	jeq .L1278
	move.b sq+415,%d0
.L1056:
	mov3q.l #2,-(%sp)
	pea -140(%fp)
	pea 8.w
	move.b %d0,-139(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1038
	moveq #-2,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1055:
	btst #1,%d0
	jeq .L1057
	mov3q.l #2,%d6
	cmp.l %d2,%d6
	jcc .L1279
	clr.l %d0
.L1058:
	move.b %d0,-140(%fp)
	lea (-140,%fp),%a2
	move.l 1100784300,-(%sp)
	pea 1(%a2)
	jsr blk4
	mov3q.l #5,-(%sp)
	move.l %a2,-(%sp)
	mov3q.l #1,-(%sp)
	jsr sq_send2
	lea (20,%sp),%sp
	tst.l %d0
	jeq .L1038
	moveq #-3,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1057:
	move.w %d0,%ccr
	jne .L1059
	lea sq+423,%a0
	lea sq+427,%a1
	move.b (%a0),-140(%fp)
	move.b (%a1),-139(%fp)
	mov3q.l #2,-(%sp)
	pea -140(%fp)
	mov3q.l #2,-(%sp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1038
	moveq #-5,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1059:
	move.w %d0,%ccr
	jpl .L1060
	move.l sq+440,%d0
	moveq #127,%d1
	mov3q.l #2,-(%sp)
	pea -140(%fp)
	and.l %d0,%d1
	lsr.l #7,%d0
	mov3q.l #5,-(%sp)
	move.b %d1,-140(%fp)
	moveq #63,%d1
	and.l %d1,%d0
	move.b %d0,-139(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1038
	moveq #-9,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1060:
	tst.b %d0
	jpl .L1061
	move.l sq+552,%d0
	moveq #127,%d1
	moveq #63,%d3
	mov3q.l #2,-(%sp)
	and.l %d0,%d1
	lsr.l #7,%d0
	pea -140(%fp)
	pea 13.w
	and.l %d3,%d0
	move.b %d1,-140(%fp)
	move.b %d0,-139(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1038
	move.l sq+404,%d0
	bclr #7,%d0
	move.l %d0,sq+404
.L1061:
	btst #4,%d0
	jeq .L1062
	lea sq+431,%a0
	lea sq+435,%a1
	move.b (%a0),-140(%fp)
	move.b (%a1),-139(%fp)
	mov3q.l #2,-(%sp)
	pea -140(%fp)
	mov3q.l #6,-(%sp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1038
	moveq #-17,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1062:
	btst #5,%d0
	jeq .L1063
	moveq #14,%d3
	moveq #127,%d4
	move.l sq+436,%d0
	move.l %d0,%d1
	lsr.l %d3,%d1
	mov3q.l #3,-(%sp)
	pea -140(%fp)
	mov3q.l #7,-(%sp)
	and.l %d4,%d1
	move.b %d1,-140(%fp)
	move.l %d0,%d1
	lsr.l #7,%d1
	and.l %d4,%d0
	and.l %d4,%d1
	move.b %d0,-138(%fp)
	move.b %d1,-139(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1038
	moveq #-33,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1063:
	btst #6,%d0
	jeq .L1064
	move.l 1100784300,-(%sp)
	move.l %fp,%d3
	add.l #-140,%d3
	move.l %d3,-(%sp)
	jsr blk4
	addq.l #8,%sp
	mov3q.l #2,%d5
	cmp.l %d2,%d5
	jcc .L1065
	clr.l %d2
.L1065:
	move.b %d2,-136(%fp)
	moveq #127,%d6
	move.w 1079807124,%d0
	subq.l #1,%d0
	and.l %d6,%d0
	move.b %d0,-135(%fp)
	move.l sq+380,%d0
	cmp.l %d0,%d6
	jcc .L1066
	moveq #127,%d0
.L1066:
	mov3q.l #7,-(%sp)
	move.l %d3,-(%sp)
	pea 9.w
	move.b %d0,-134(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1038
	moveq #-65,%d7
	and.l %d7,sq+404
	lea st+8,%a0
	move.l (%a0),sq+444
.L1064:
	move.l sq+360,%d0
	btst #8,%d0
	jeq .L1067
	moveq #127,%d1
	and.l %d1,%d0
.L1068:
	move.l #85760,%d3
	clr.l %d1
	muls.l %d3,%d0
	move.l ed+96,%d4
	move.l #85685,%d6
	lea ed,%a3
	lea ed+100,%a1
	move.l %d4,-180(%fp)
	move.l #85686,%d7
	move.l %a3,%a4
	move.l %d0,%a2
	move.l %d0,%a0
	add.l #1081989347,%a2
	add.l #1081990056,%a0
.L1074:
	move.l #85689,%d5
	moveq #12,%d0
	mvz.b (%a2,%d5.l),%d4
	cmp.l %d1,%d0
	jeq .L1069
	mvz.b (%a0),%d0
	move.b 2(%a0),%d3
.L1070:
	mvz.b %d3,%d3
	cmp.l (%a1),%d0
	jne .L1071
	cmp.l 52(%a1),%d3
	jne .L1071
	cmp.l 104(%a1),%d4
	jne .L1071
	moveq #12,%d2
	cmp.l %d1,%d2
	jne .L1072
	move.l #85685,%d2
	move.b (%a2,%d2.l),%d2
	move.l #85686,%a5
	mvz.b (%a2,%a5.l),%d5
	mvz.b %d2,%d2
	lsl.l #8,%d2
	or.l %d5,%d2
	cmp.l ed+256.l,%d2
	jeq .L1072
.L1071:
	move.l %d0,(%a1)
	moveq #12,%d0
	move.l %d3,52(%a1)
	move.l %d4,104(%a1)
	cmp.l %d1,%d0
	jne .L1073
	move.b (%a2,%d6.l),%d0
	mvz.b (%a2,%d7.l),%d2
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d2,%d0
	move.l %d0,ed+256
.L1073:
	tst.l -180(%fp)
	jeq .L1072
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	or.l %d0,ed+260
.L1072:
	addq.l #1,%d1
	addq.l #4,%a1
	lea (917,%a0),%a0
	moveq #13,%d2
	cmp.l %d1,%d2
	jne .L1074
	move.b 1079807236,%d1
	moveq #127,%d3
	move.l #85760,%d0
	mov3q.l #1,ed+96
	and.l %d3,%d1
	muls.l %d1,%d0
	move.l %d0,%a1
	add.l #1081989344,%a1
	mvz.w #21441,%d0
	cmp.l ed+272.l,%d1
	jeq .L1075
	move.l %d1,ed+272
	clr.l ed+268
	clr.l ed+372
.L1075:
	move.l ed+268,%d2
	move.l %d2,%d3
	addq.l #1,%d3
	move.l %d3,%d1
	moveq #10,%d4
	lsl.l %d4,%d1
	cmp.l %d0,%d1
	jls .L1280
	move.l %d2,%d1
	move.l %d0,%d5
	lsl.l %d4,%d1
	sub.l %d1,%d5
.L1076:
	move.l %d2,%d1
	moveq #12,%d6
	lsl.l %d6,%d1
	clr.l %d4
	add.l %d1,%a1
	clr.l %d1
.L1077:
	move.l %d1,%d6
	addq.l #1,%d4
	add.l %d6,%d6
	subx.l %d6,%d6
	neg.l %d6
	move.l %d6,%a2
	lea (%a2,%d1.l*2),%a0
	move.l %a0,%d1
	add.l (%a1)+,%d1
	cmp.l %d4,%d5
	jne .L1077
	move.l ed+372,%d4
	move.l %d2,%a0
	lea (69,%a0),%a0
	btst %d2,%d4
	jeq .L1078
	cmp.l (%a4,%a0.l*4),%d1
	jeq .L1078
	mov3q.l #1,ed+376
.L1078:
	move.l %d1,(%a4,%a0.l*4)
	mov3q.l #1,%d1
	add.l #1023,%d0
	lsl.l %d2,%d1
	or.l %d4,%d1
	move.l %d1,ed+372
	moveq #10,%d1
	lsr.l %d1,%d0
	cmp.l %d3,%d0
	jhi .L1079
	clr.l %d3
.L1079:
	move.l %d3,ed+268
	move.l %fp,%d3
	clr.l %d2
	add.l #-172,%d3
.L1084:
	move.l ed+260,%d0
	btst %d2,%d0
	jeq .L1080
	moveq #12,%d5
	cmp.l %d2,%d5
	jne .L1281
	moveq #127,%d0
.L1081:
	move.b %d0,-172(%fp)
	move.l 100(%a3),%d0
	moveq #127,%d1
	moveq #127,%d6
	moveq #127,%d7
	and.l %d0,%d1
	lsr.l #7,%d0
	and.l %d6,%d0
	move.b %d1,-171(%fp)
	moveq #127,%d1
	move.b %d0,-170(%fp)
	moveq #127,%d0
	and.l 152(%a3),%d0
	move.b %d0,-169(%fp)
	moveq #127,%d0
	and.l 204(%a3),%d0
	move.b %d0,-168(%fp)
	move.l ed+256,%d0
	and.l %d0,%d1
	lsr.l #7,%d0
	and.l %d7,%d0
	move.b %d1,-167(%fp)
	move.b %d0,-166(%fp)
	moveq #12,%d0
	cmp.l %d2,%d0
	jeq .L1282
	mov3q.l #5,%d0
.L1082:
	move.l %d0,-(%sp)
	move.l %d3,-(%sp)
	mov3q.l #4,-(%sp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1038
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	addq.l #1,ed+264
	not.l %d0
	and.l %d0,ed+260
.L1080:
	addq.l #1,%d2
	addq.l #4,%a3
	moveq #13,%d1
	cmp.l %d2,%d1
	jne .L1084
.L1085:
	move.l ed+68,%d0
	cmp.l ed+64.l,%d0
	jne .L1086
	tst.l ed+92
	jeq .L1087
	lea ed+91,%a0
	move.b (%a0),-172(%fp)
	mov3q.l #1,-(%sp)
	pea -172(%fp)
	pea 12.w
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1038
	clr.l ed+92
.L1087:
	tst.l ed+376
	jeq .L1038
	move.l st+8,%d0
	sub.l ed+380,%d0
	lsr.l #2,%d0
	jeq .L1038
	move.b 1079807236,%d0
	moveq #127,%d2
	mov3q.l #1,-(%sp)
	pea -172(%fp)
	pea 11.w
	and.l %d2,%d0
	move.b %d0,-172(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1038
	lea st+8,%a0
	clr.l ed+376
	move.l (%a0),ed+380
	addq.l #1,ed+384
	jra .L1038
.L1040:
	jsr (%a2)
	jra .L1041
.L1044:
	mvz.b %d0,%d0
	mvz.b %d2,%d2
	moveq #127,%d4
	lsl.l #8,%d0
	or.l %d2,%d0
	cmp.l %d0,%d4
	jge .L1045
.L1277:
	moveq #127,%d0
	jra .L1046
.L1278:
	moveq #127,%d0
	jra .L1056
.L1279:
	move.l %d2,%d0
	jra .L1058
.L1067:
	move.b 1079807236,%d0
	moveq #127,%d2
	and.l %d2,%d0
	jra .L1068
.L1069:
	move.l #85683,%d2
	move.b (%a2,%d2.l),%d0
	move.l #85684,%d3
	move.l #85690,%d5
	mvz.b (%a2,%d3.l),%d2
	move.b (%a2,%d5.l),%d3
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d2,%d0
	jra .L1070
.L1280:
	mvz.w #1024,%d5
	jra .L1076
.L1281:
	move.l %d2,%d0
	jra .L1081
.L1282:
	mov3q.l #7,%d0
	jra .L1082
.L1086:
	mov3q.l #7,%d2
	and.l %d2,%d0
	pea 8.w
	lsl.l #3,%d0
	add.l #ed,%d0
	move.l %d0,-(%sp)
	pea 10.w
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1038
	addq.l #1,ed+68
	addq.l #1,ed+76
	jra .L1085
.L1088:
	clr.l sq+468
	clr.l st+1006
.L1090:
	clr.b %d4
	move.b %d4,led_owed
	jsr led_restore
	move.l led_again,%d0
	tst.l %d0
	jeq .L1097
	tst.b ov_on.l
	jne .L1097
	move.l st+8,%d1
	sub.l %d0,%d1
	jmi .L1097
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1098
.L1583:
	addq.l #1,st+1018
.L1097:
	move.l sq+468,%d2
	move.l pg_gen,%d0
	mvz.b ovp_on,%d3
	tst.l %d2
	jeq .L1102
	cmp.l sq+472.l,%d0
	jeq .L1103
	btst #0,%d0
	jne .L1103
	move.b pg_req,%d5
	move.b pg_req+1,%d4
	move.b pg_req+2,%d2
	move.b pg_req+3,%d1
	cmp.l pg_gen.l,%d0
	jne .L1103
	move.b %d5,sq+480
	move.b %d4,sq+481
	move.b %d2,sq+482
	move.b %d1,sq+483
	move.l %d0,sq+472
	mov3q.l #1,sq+476
.L1103:
	clr.l %d2
	clr.l %d0
	lea sq+480,%a0
.L1105:
	mvz.b (%a0,%d0.l),%d4
	moveq #111,%d6
	cmp.l %d4,%d6
	jcs .L1104
	mov3q.l #1,%d4
	lsl.l %d0,%d4
	or.l %d4,%d2
.L1104:
	addq.l #1,%d0
	mov3q.l #4,%d7
	cmp.l %d0,%d7
	jne .L1105
.L1102:
	cmp.l %d3,%d2
	jne .L1106
	tst.l sq+476
	jeq .L1107
.L1106:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1284
	addq.l #1,st+1018
.L1107:
	tst.l st+4
	jeq .L1285
	tst.l st+1058
	seq %d2
	mvs.b %d2,%d2
	neg.l %d2
.L1115:
	move.l st+8,%d0
	moveq #10,%d3
	divu.l %d3,%d0
	btst #0,%d0
	jeq .L1286
	clr.b %d3
.L1116:
	mvz.b k44+24,%d0
	cmp.l %d2,%d0
	jne .L1117
	tst.l %d2
	jeq .L1118
	mvz.b k44+25,%d1
	mvz.b %d3,%d0
	cmp.l %d1,%d0
	jeq .L1118
.L1117:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1119
	addq.l #1,st+1018
.L1118:
	jsr flush
	move.b pc+79,%d2
	move.l pc_seq,%d1
	lea pc,%a2
	tst.b %d2
	jne .L1122
	btst #0,%d1
	jne .L1123
	cmp.l pc+72.l,%d1
	jeq .L1123
	clr.l %d0
	lea pc_req,%a0
	lea (-140,%fp),%a3
.L1124:
	lea (%a0,%d0.l),%a1
	mov3q.l #6,%d3
	move.b (%a1),(%a3,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d3
	jne .L1124
	cmp.l pc_seq.l,%d1
	jne .L1123
	move.b -140(%fp),%d3
	move.w pc+82,%d0
	moveq #127,%d4
	move.l %d1,pc+72
	moveq #11,%d6
	mvz.b %d3,%d5
	addq.l #1,%d0
	move.w %d0,pc+82
	move.b %d4,pc+77
	cmp.l %d5,%d6
	jlt .L1126
	jsr 1075320104
	move.l %d0,-(%sp)
	jsr 1073963888
	addq.l #4,%sp
	tst.l %d0
	jne .L1127
.L1126:
	moveq #3,%d2
.L1128:
	move.b %d2,pc+78
	mvz.b %d2,%d2
	move.b %d3,pc+76
	add.l #42,%d2
	move.w (%a2,%d2.l*2),%d0
	addq.l #1,%d0
	move.w %d0,(%a2,%d2.l*2)
	moveq #1,%d0
	move.b %d0,pc+79
.L1122:
	moveq #-9,%d0
	move.w #10242,%d2
	lea pc+76,%a0
	lea pc+78,%a1
	move.w (%a0),-134(%fp)
	move.b (%a1),-132(%fp)
	pea 10.w
	move.l #-260222380,%d1
	pea -140(%fp)
	move.l %d1,-140(%fp)
	move.w %d2,-136(%fp)
	move.b %d0,-131(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1123
	move.w pc+92,%d0
	clr.b %d1
	addq.l #1,%d0
	move.b %d1,pc+79
	move.w %d0,pc+92
.L1123:
	move.b st+992,%d0
	move.b st+161,%d1
	or.l %d1,%d0
	tst.b %d0
	jne .L1143
	jsr mr_tick
	tst.l %d0
	jeq .L1143
	tst.b sv+4.l
	jeq .L1144
	move.w #-2304,%a1
	move.w #10497,%d3
	lea sv+5,%a0
	move.w (%a0),-134(%fp)
	pea 9.w
	move.l #-260222380,%d2
	pea -140(%fp)
	move.l %d2,-140(%fp)
	move.w %d3,-136(%fp)
	move.w %a1,-132(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1143
	clr.b %d0
	addq.l #1,sv+64
	move.b %d0,sv+4
.L1144:
	tst.b sv+102.l
	jeq .L1147
	moveq #127,%d0
	moveq #127,%d4
	and.l sv+92,%d0
	move.w #11009,%d3
	move.l #-260222380,%d1
	moveq #14,%d5
	move.l %d1,-172(%fp)
	moveq #28,%d1
	move.l sv+88,%d2
	moveq #127,%d6
	lea sv+100,%a0
	move.b (%a0),-166(%fp)
	move.b %d0,-165(%fp)
	move.l %d2,%d0
	lsr.l %d1,%d0
	move.w %d3,-168(%fp)
	moveq #21,%d3
	move.b %d0,-164(%fp)
	move.l %d2,%d0
	lsr.l %d3,%d0
	and.l %d4,%d0
	move.b %d0,-163(%fp)
	move.l %d2,%d0
	lsr.l %d5,%d0
	and.l %d4,%d0
	move.b %d0,-162(%fp)
	move.l %d2,%d0
	lsr.l #7,%d0
	and.l %d4,%d0
	move.b %d0,-161(%fp)
	moveq #127,%d0
	and.l %d2,%d0
	move.b %d0,-160(%fp)
	move.l sv+96,%d0
	cmp.l %d0,%d6
	jcc .L1148
	moveq #127,%d0
.L1148:
	move.b %d0,-159(%fp)
	clr.l %d0
	lea (-140,%fp),%a0
	lea (-172,%fp),%a1
.L1149:
	lea (%a1,%d0.l),%a2
	moveq #14,%d1
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1149
	moveq #-9,%d3
	pea 15.w
	move.l %a0,-(%sp)
	move.b %d3,-126(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1143
	clr.b %d4
	lea sv+100,%a0
	move.b (%a0),sv+101
	lea st+8,%a1
	move.l %d2,sv+104
	move.l (%a1),sv+108
	addq.l #1,sv+112
	move.b %d4,sv+102
.L1147:
	tst.b sv.l
	jeq .L1143
	lea (-172,%fp),%a4
	mov3q.l #-1,%d2
	lea sv,%a3
	clr.l %d3
	move.l %a4,%a2
.L1154:
	mvz.b sv+1,%d0
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	jsr sv_word
	move.b sv+7,%d1
	addq.l #8,%sp
	move.w %d0,(%a4)+
	tst.b %d1
	jne .L1151
	mvz.w %d0,%d0
	mvz.w 24(%a3),%d4
	cmp.l %d0,%d4
	jeq .L1152
.L1151:
	cmp.l -184(%fp),%d3
	jge .L1153
	move.l %d3,-184(%fp)
.L1153:
	move.l %d3,%d2
.L1152:
	addq.l #1,%d3
	addq.l #2,%a3
	moveq #16,%d0
	cmp.l %d3,%d0
	jne .L1154
	tst.b %d1
	jne .L1288
	mov3q.l #-1,%d1
	cmp.l %d2,%d1
	jne .L1155
.L1143:
	tst.l st
	jne .L975
.L1164:
	mvz.b cu+9,%d3
	tst.l %d3
	jeq .L1193
	mvz.b cu+10,%d5
	moveq #127,%d0
	and.l -2147457096,%d0
	move.w %d5,%d1
	mulu.w #2531,%d0
	mulu.w #152,%d1
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d0
	cmp.l %d3,%d0
	jeq .L1194
	move.l st+8,%d0
	mov3q.l #4,%d3
	sub.l cu+16,%d0
	cmp.l %d0,%d3
	jcc .L1193
	clr.b %d4
	move.b %d4,cu+9
.L1193:
	tst.l st
	jeq .L1197
	mov3q.l #1,%d2
	cmp.l 1094562388.l,%d2
	jne .L1198
	tst.l st+968
	jeq .L1198
	move.l dp,%d0
	move.b 1093765506,%d2
	tst.l %d0
	jeq .L1199
	move.w #18689,%d4
	moveq #1,%d5
	move.w #-2304,%d6
	pea 9.w
	move.l #-260222380,%d3
	pea -140(%fp)
	move.b %d0,-133(%fp)
	move.l %d3,-140(%fp)
	move.w %d4,-136(%fp)
	move.b %d5,-134(%fp)
	move.w %d6,-132(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1201
	clr.l dp
.L1199:
	tst.b k44+20.l
	jeq .L1202
	move.l k44+20,%d0
	and.l #16776960,%d0
	tst.l %d0
	jne .L1202
	tst.l st+4
	jeq .L1203
	tst.l st+1058
	jne .L1202
.L1203:
	move.l st+8,%d0
	sub.l k44,%d0
	lsr.l #3,%d0
	jeq .L1202
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	or.l ov_list,%d0
	jne .L1202
	tst.l st+4
	sne %d0
	move.w #257,%a0
	neg.l %d0
	move.b %d0,k44+26
	move.w %a0,k44+22
.L1202:
	move.b k44+23,%d0
	jeq .L1204
	tst.b k44+26.l
	seq %d1
	move.w #18689,%a2
	move.w #-2304,%d3
	pea 9.w
	move.l #-260222380,%a1
	pea -140(%fp)
	move.l %a1,-140(%fp)
	addq.l #5,%d1
	move.b %d1,-134(%fp)
	mov3q.l #1,%d1
	eor.l %d1,%d0
	move.w %a2,-136(%fp)
	move.w %d3,-132(%fp)
	tst.b %d0
	seq %d0
	neg.l %d0
	move.b %d0,-133(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1201
	mvz.b k44+23,%d0
	tst.b k44+26.l
	jeq .L1207
	mov3q.l #1,%d4
	cmp.l %d0,%d4
	jne .L1208
	addq.l #1,k44+28
.L1209:
	clr.b %d0
	move.b %d0,k44+23
.L1204:
	mvz.b %d2,%d1
	moveq #11,%d3
	cmp.l %d1,%d3
	jcs .L1201
	move.b %d2,%d3
	moveq #127,%d0
	and.l -2147457096,%d0
	ext.w %d3
	mulu.w #2531,%d0
	mulu.w #152,%d3
	move.l %d0,%a0
	move.l st+968,%d0
	add.l %d3,%a0
	add.l #1092966773,%a0
	move.b (%a0),%d5
	mvz.b %d5,%d4
	cmp.l dp+8.l,%d0
	jeq .L1212
	clr.b %d6
	move.l %d0,dp+8
	move.b %d6,dp+22
.L1213:
	moveq #52,%d7
	cmp.l %d4,%d7
	jcs .L1291
	move.b %d5,%d0
	move.l #1075572644,%a0
	ext.w %d0
	mvz.w %d0,%d0
	lsl.l #3,%d0
	move.l (%a0,%d0.l),%a0
.L1215:
	moveq #2,%d0
	move.w #18689,%a2
	move.l #-260222380,%a1
	move.b %d2,-133(%fp)
	move.l %a1,-140(%fp)
	move.b %d0,-134(%fp)
	moveq #127,%d0
	and.l %d5,%d0
	move.w %a2,-136(%fp)
	move.b %d0,-132(%fp)
	tst.l %a0
	jeq .L1292
	move.l %a0,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	sls %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1216:
	clr.l %d1
	lea (-140,%fp),%a1
.L1218:
	tst.l %d0
	jeq .L1586
	move.b (%a0,%d1.l),%d6
	move.l %d6,%d7
	subq.l #1,%d7
	mvz.b %d7,%d7
	move.l %d7,%a2
	moveq #125,%d7
	cmp.l %a2,%d7
	jcs .L1294
.L1217:
	move.b %d6,9(%a1,%d1.l)
	addq.l #1,%d1
	moveq #12,%d6
	cmp.l %d1,%d6
	jne .L1218
	moveq #-9,%d7
	pea 22.w
	move.l %a1,-(%sp)
	move.b %d7,-119(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1201
	move.w #257,%a0
	move.b %d2,dp+20
	move.b %d5,dp+21
	addq.l #1,dp+12
	move.w %a0,dp+22
	jra .L1214
.L1098:
	jsr led_stock
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.l led_again
.L1584:
	addq.l #4,%sp
	jra .L1097
.L1284:
	clr.l %d0
	lea sq+480,%a0
	lea ovp_col,%a1
.L1108:
	btst %d0,%d2
	jeq .L1109
	lea (%a0,%d0.l),%a2
	move.b (%a2),(%a1,%d0.l)
.L1109:
	addq.l #1,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L1108
	move.l %d3,%d4
	clr.l %d3
	move.b %d2,ovp_on
	or.l %d2,%d4
	lea shp,%a2
	lea sq+480,%a4
	lea (-140,%fp),%a3
	lea rui_uart_raw,%a5
.L1114:
	btst %d3,%d4
	jeq .L1110
	moveq #-76,%d5
	moveq #43,%d0
	mov3q.l #1,%d6
	sub.l %d3,%d0
	move.b %d0,-139(%fp)
	move.l %d2,%d0
	lsr.l %d3,%d0
	sub.l %a0,%a0
	and.l %d6,%d0
	move.b %d5,-140(%fp)
.L1113:
	tst.l %d0
	jeq .L1111
	move.b (%a4,%d3.l),%d1
.L1112:
	move.b %d1,2(%a3,%a0.l)
	addq.l #1,%a0
	mov3q.l #4,%d7
	cmp.l %a0,%d7
	jne .L1113
	move.l %a3,-(%sp)
	mov3q.l #6,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
.L1110:
	addq.l #1,%d3
	addq.l #4,%a2
	mov3q.l #4,%d0
	cmp.l %d3,%d0
	jne .L1114
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.l sq+476
	addq.l #4,%sp
	jra .L1107
.L1111:
	move.b (%a2,%a0.l),%d1
	jra .L1112
.L1285:
	clr.l %d2
	jra .L1115
.L1286:
	moveq #111,%d3
	jra .L1116
.L1119:
	move.b %d3,ovt_col
	move.b %d2,%d4
	move.b %d2,ovt_on
	lea led_send4,%a0
	tst.l %d2
	jeq .L1120
	move.b %d3,-137(%fp)
	move.b %d3,-138(%fp)
	move.b %d3,-139(%fp)
	move.b %d3,-140(%fp)
	pea -140(%fp)
	pea 55.w
	jsr (%a0)
	addq.l #1,k44+12
.L1585:
	addq.l #4,%sp
	move.l #1100088672,(%sp)
	jsr 1073746414
	addq.l #4,%sp
	move.b %d4,k44+24
	move.b %d3,k44+25
	jra .L1118
.L1120:
	pea sht
	pea 55.w
	jsr (%a0)
	addq.l #1,k44+16
	jra .L1585
.L1127:
	move.b %d3,%d4
	moveq #127,%d0
	moveq #127,%d7
	and.l -2147457096,%d0
	ext.w %d4
	mulu.w #2531,%d0
	move.w %d4,%d1
	move.l %d0,%a0
	mulu.w #152,%d1
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d0
	move.l %d0,-(%sp)
	move.l %d5,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	mvz.b %d0,%d0
	cmp.l %d0,%d7
	jeq .L1126
	tst.b 60(%a2,%d5.l)
	jeq .L1129
	move.l st+8,%d0
	moveq #20,%d1
	sub.l (%a2,%d5.l*4),%d0
	cmp.l %d0,%d1
	jcc .L1130
.L1129:
	moveq #1,%d2
	jra .L1128
.L1130:
	lea 48(%a2,%d5.l),%a0
	move.b (%a0),77(%a2)
	jsr 1075312702
	move.l %d0,-(%sp)
	jsr 1074458688
	move.l %d5,-(%sp)
	move.l %d0,-(%sp)
	jsr 1074442802
	lea (12,%sp),%sp
	move.l %d0,%a4
	move.l 44(%a4),%a5
	tst.l %a5
	jeq .L1126
	move.l (%a5),%a0
	move.l %a5,-(%sp)
	move.l 40(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l 32(%a5),%a1
	move.l %d0,-180(%fp)
	tst.l %a1
	jeq .L1131
	move.l %a1,%d5
	move.l %a1,%a0
	add.l #4752,%d5
	clr.l %d1
.L1135:
	mvz.b (%a0),%d6
	cmp.l #255,%d6
	jeq .L1133
	mvz.b 1(%a0),%d6
	cmp.l #255,%d6
	jeq .L1133
	addq.l #1,%d1
.L1133:
	lea (66,%a0),%a0
	cmp.l %d5,%a0
	jne .L1135
	mulu.w #5674,%d4
	mvz.b %d3,%d0
	move.l #1075599904,%a5
	add.l -180(%fp),%d4
.L1140:
	mvz.b 3(%a5),%d6
	move.l %a1,%a0
.L1138:
	mvz.b (%a0),%d7
	cmp.l %d7,%d6
	jne .L1136
	mvz.b 1(%a0),%d7
	cmp.l %d0,%d7
	jeq .L1137
.L1136:
	lea (66,%a0),%a0
	cmp.l %d5,%a0
	jne .L1138
	move.l %d4,%a0
	tst.b 5653(%a0)
	jne .L1272
	mov3q.l #1,%a0
	jra .L1273
.L1272:
	mov3q.l #2,%a0
.L1273:
	add.l %a0,%d1
	moveq #71,%d6
	cmp.l %d1,%d6
	jlt .L1287
.L1137:
	addq.l #4,%a5
	addq.l #1,%d4
	cmp.l #1075599920,%a5
	jne .L1140
.L1131:
	mvz.b -139(%fp),%d1
	moveq #21,%d4
	move.l %d1,-(%sp)
	mvz.b pc+77,%d1
	move.l %d1,-(%sp)
	move.l %a4,-(%sp)
	jsr 1074530058
	move.b %d3,%d1
	lea (12,%sp),%sp
	move.l -180(%fp),%d0
	ext.w %d1
	mulu.w #5674,%d1
	add.l %d1,%d0
	move.l %d0,%a5
	lea (5632,%a5),%a5
.L1141:
	tst.b (%a5,%d4.l)
	sne %d1
	mvz.b pc+77,%d0
	moveq #25,%d7
	mvs.b %d1,%d1
	neg.l %d1
	move.l %d1,-(%sp)
	mvz.b -19(%a3,%d4.l),%d1
	lsl.l #8,%d1
	move.l %d1,-(%sp)
	move.l %d4,-(%sp)
	move.l %d0,-(%sp)
	move.l %a4,-(%sp)
	jsr 1074529568
	addq.l #1,%d4
	lea (20,%sp),%sp
	cmp.l %d4,%d7
	jne .L1141
	jra .L1128
.L1287:
	moveq #2,%d2
	jra .L1128
.L1288:
	moveq #15,%d2
	clr.l -184(%fp)
.L1155:
	move.w #10753,%d4
	move.l %d2,%d1
	addq.l #1,%d1
	move.b -181(%fp),-133(%fp)
	move.l %d1,%d0
	move.l #-260222380,%d3
	sub.l -184(%fp),%d0
	lea sv+1,%a0
	move.b (%a0),-134(%fp)
	lea (-140,%fp),%a0
	move.b %d0,-132(%fp)
	move.l -184(%fp),%d0
	move.w %d4,-136(%fp)
	move.l %d3,-140(%fp)
	lea (9,%a0),%a1
.L1156:
	cmp.l %d2,%d0
	jle .L1157
	cmp.l -184(%fp),%d1
	sge %d1
	move.l %d1,%d0
	neg.l %d0
	tst.b %d0
	jeq .L1158
	move.l %d2,%d0
	sub.l -184(%fp),%d0
	add.l %d0,%d0
	add.l #11,%d0
.L1159:
	moveq #-9,%d5
	lea (%fp,%d0.l),%a1
	neg.l %d1
	move.b %d5,-140(%a1)
	tst.b %d1
	jeq .L1160
	move.l %d2,%d0
	addq.l #6,%d0
	sub.l -184(%fp),%d0
	add.l %d0,%d0
.L1161:
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1143
	lea sv+24,%a0
.L1162:
	cmp.l -184(%fp),%d2
	jge .L1163
	clr.b %d2
	addq.l #1,sv+68
	move.b %d2,sv+7
	jra .L1143
.L1157:
	move.w (%a2,%d0.l*2),%d3
	addq.l #1,%d0
	addq.l #2,%a1
	move.l %d3,%d4
	lsr.l #7,%d4
	move.b %d4,-2(%a1)
	moveq #127,%d4
	and.l %d4,%d3
	move.b %d3,-1(%a1)
	jra .L1156
.L1158:
	moveq #9,%d0
	jra .L1159
.L1160:
	moveq #10,%d0
	jra .L1161
.L1163:
	move.l -184(%fp),%d1
	lea (%a2,%d1.l*2),%a3
	move.w (%a3),(%a0,%d1.l*2)
	addq.l #1,%d1
	move.l %d1,-184(%fp)
	jra .L1162
.L1168:
	mvz.b ux+3922,%d0
	move.l %d0,-(%sp)
	mvz.b ux+3921,%d0
	move.l %d0,-(%sp)
	mvz.b ux+3920,%d0
	move.l %d0,-(%sp)
	pea 72.w
	jsr send3
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L1164
	move.l ux+3944,%d1
	mov3q.l #1,%d0
	lea ux+3920,%a0
.L1165:
	cmp.l %d0,%d1
	jhi .L1166
	subq.l #1,%d1
	move.l %d1,ux+3944
	addq.l #1,ux+32
.L1167:
	tst.l ux+3944
	jne .L1168
.L1169:
	move.l ux+3880,%d1
	cmp.l ux+3884.l,%d1
	jeq .L1164
	mov3q.l #7,%d2
	cmp.l ux+3944.l,%d2
	jcs .L1164
	mov3q.l #7,%d0
	and.l ux+3884,%d0
	lsl.l #2,%d0
	move.l %d0,%a2
	add.l #ux+3888,%a2
	move.b 1(%a2),%d6
	moveq #127,%d0
	and.l -2147457096,%d0
	move.b (%a2),%d7
	mvz.b %d6,%d3
	mulu.w #2531,%d0
	move.l %d3,%a1
	mvz.b %d7,%d3
	move.l %d0,%a0
	add.l #1092966773,%a0
	move.w %d3,%d0
	mulu.w #152,%d0
	move.b (%a0,%d0.l),%d0
	mvz.b %d0,%d4
	move.w %d0,%a3
	move.l %d4,%a5
	move.l %a1,%d4
	move.l %a5,-(%sp)
	add.l #9,%d4
	move.l %d4,-(%sp)
	move.l %a1,-188(%fp)
	jsr 1073770536
	addq.l #8,%sp
	move.l ux+3884,%a0
	move.l -188(%fp),%a1
	move.l %d0,%a4
	tst.l %d0
	jle .L1289
	mvz.b 2(%a2),%d2
	mvz.b 3(%a2),%d0
	lsl.l #8,%d2
	add.l %d0,%d0
	or.l %d0,%d2
	mov3q.l #7,%d0
	cmp.l %a1,%d0
	jlt .L1171
	move.l %a3,%d0
	add.l #-46,%d0
	mvz.b %d0,%d0
	lsr.l #2,%d0
	jeq .L1172
	moveq #52,%d0
	cmp.l %a5,%d0
	jne .L1173
.L1172:
	cmp.l 1075595760.l,%a5
	jne .L1174
.L1173:
	tst.l %a1
	jne .L1176
.L1177:
	move.l %a0,%d1
	mov3q.l #7,%d0
	and.l %d0,%d1
	move.l %d5,%a0
	add.l %d1,%a0
	move.b 3952(%a0),%d0
	btst #0,%d0
	jeq .L1176
	move.l ls+60,%d0
	or.l ls+64,%d0
	jeq .L1176
	cmp.l ls+68.l,%d3
	jne .L1176
	move.l st+8,%d0
	moveq #20,%d1
	sub.l ls+72,%d0
	cmp.l %d0,%d1
	jcs .L1176
	move.l #1075599820,%a0
	move.l (%a0,%d4.l*4),%a3
	jsr 1075312702
	move.l %d0,-(%sp)
	jsr 1074458688
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	jsr 1074442802
	lea (12,%sp),%sp
	move.l %d0,%a2
	move.l 44(%a2),%a5
	tst.l %a5
	jeq .L1176
	move.l (%a5),%a0
	move.l %a5,-(%sp)
	move.l 40(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l 32(%a5),%d0
	tst.l %d0
	jeq .L1178
	move.l %d0,%a0
	add.l #4753,%d0
	move.l %d0,-180(%fp)
	move.w %a3,%d0
	addq.l #1,%a0
	sub.l %a4,%a4
	sub.l %a1,%a1
	mvz.b %d0,%d0
	move.l %d0,%a3
.L1183:
	mvz.b -1(%a0),%d1
	cmp.l #255,%d1
	jeq .L1180
	mvz.b (%a0),%d0
	cmp.l #255,%d0
	jeq .L1180
	addq.l #1,%a1
.L1180:
	cmp.l %d1,%a3
	jne .L1182
	mvz.b (%a0),%d1
	move.l %a4,%d0
	cmp.l %d1,%d3
	seq %d1
	mvs.b %d1,%d1
	neg.l %d1
	or.l %d1,%d0
	move.l %d0,%a4
.L1182:
	lea (66,%a0),%a0
	cmp.l -180(%fp),%a0
	jne .L1183
	tst.l %a4
	jne .L1178
	moveq #69,%d1
	cmp.l %a1,%d1
	jlt .L1184
.L1178:
	move.l %a2,-(%sp)
	moveq #64,%d3
	jsr 1074529464
	addq.l #4,%sp
	move.l %d0,%a3
	cmp.l %d0,%d3
	jge .L1185
	move.w #64,%a3
.L1185:
	clr.l %d3
.L1186:
	cmp.l %a3,%d3
	jlt .L1190
	moveq #4,%d0
	clr.l ls+64
	clr.l ls+60
	addq.l #1,ux+3960
.L1191:
	move.l ux+3944,%a0
	lea (%a0,%a0.l*2),%a1
	addq.l #1,%a0
	move.l %a0,ux+3944
	addq.l #1,ux+3884
	add.l %d5,%a1
	move.b %d7,3920(%a1)
	move.b %d6,3921(%a1)
	move.b %d0,3922(%a1)
	jra .L1169
.L1166:
	addq.l #3,%a0
	move.b (%a0),-3(%a0)
	move.b 1(%a0),-2(%a0)
	move.b 2(%a0),-1(%a0)
	addq.l #1,%d0
	jra .L1165
.L1171:
	move.l %a5,%d0
	add.l #-48,%d0
	lsr.l #1,%d0
	jne .L1175
	mvz.b cu+1,%d0
	cmp.l %a5,%d0
	jne .L1174
.L1176:
	move.l %d4,-(%sp)
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	jsr 1074918394
	jsr 1075398168
	move.l %d2,-(%sp)
	move.l %a4,-(%sp)
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	jsr 1073952092
	lea (28,%sp),%sp
	clr.b %d0
	addq.l #1,ux+20
	jra .L1191
.L1175:
	moveq #10,%d0
	cmp.l %a1,%d0
	jne .L1176
	moveq #45,%d1
	cmp.l %a5,%d1
	jne .L1176
	jra .L1177
.L1190:
	moveq #31,%d0
	cmp.l %d3,%d0
	jlt .L1187
	move.l ls+60,%d1
	lsr.l %d3,%d1
.L1188:
	btst #0,%d1
	jeq .L1189
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	move.l %d4,-(%sp)
	move.l %d3,-(%sp)
	move.l %a2,-(%sp)
	jsr 1074529568
	lea (20,%sp),%sp
	addq.l #1,ls+96
.L1189:
	addq.l #1,%d3
	jra .L1186
.L1187:
	move.l %d3,%d0
	add.l #-32,%d0
	move.l ls+64,%d1
	lsr.l %d0,%d1
	jra .L1188
.L1184:
	moveq #3,%d0
	addq.l #1,ux+3964
.L1170:
	addq.l #1,ux+24
	jra .L1191
.L1174:
	moveq #1,%d0
	jra .L1170
.L1289:
	moveq #2,%d0
	jra .L1170
.L1194:
	move.l #1075731444,%d6
	cmp.l sv+88.l,%d6
	jeq .L1193
	move.l st+8,%d0
	sub.l cu+16,%d0
	lsr.l #1,%d0
	jeq .L1193
	mov3q.l #1,-(%sp)
	move.l %d3,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	move.l %d0,%a2
	tst.l %d0
	jeq .L1193
	move.l %d3,-(%sp)
	moveq #17,%d2
	jsr cu_setup
	lea (11,%a2),%a2
	addq.l #4,%sp
.L1196:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	jsr 1073770536
	addq.l #8,%sp
	move.l %d0,%d4
	tst.l %d0
	jle .L1195
	mvz.b (%a2),%d6
	move.l %d2,-(%sp)
	move.l %d5,-(%sp)
	lsl.l #8,%d6
	move.l %d6,-(%sp)
	jsr 1074918394
	jsr 1075398168
	move.l %d6,-(%sp)
	move.l %d4,-(%sp)
	move.l %d5,-(%sp)
	move.l %d0,-(%sp)
	jsr 1073952092
	lea (28,%sp),%sp
.L1195:
	addq.l #1,%d2
	lea (14,%a2),%a2
	moveq #25,%d0
	cmp.l %d2,%d0
	jne .L1196
	clr.b %d1
	addq.l #1,cu+20
	move.b %d1,cu+9
	jra .L1193
.L1208:
	addq.l #1,k44+32
.L1210:
	subq.l #2,%d0
	tst.l %d0
	jne .L1209
	clr.b %d7
	move.b %d7,k44+26
	jra .L1209
.L1207:
	mov3q.l #1,%d5
	cmp.l %d0,%d5
	jne .L1211
	addq.l #1,k44+4
	jra .L1209
.L1211:
	addq.l #1,k44+8
	jra .L1210
.L1212:
	tst.b dp+22.l
	jeq .L1213
	mvz.b dp+20,%d0
	cmp.l %d1,%d0
	jne .L1213
	mvz.b dp+21,%d0
	cmp.l %d4,%d0
	jne .L1213
.L1214:
	add.l #1092966707,%d3
	lea dp,%a4
	sub.l %a3,%a3
	move.l %d3,-180(%fp)
	lea dp+32,%a2
	move.l %a4,%a5
.L1225:
	moveq #127,%d0
	and.l -2147457096,%d0
	move.l -180(%fp),%a0
	mulu.w #2531,%d0
	add.l %d0,%a0
	mvz.w %a3,%d0
	move.b (%a0,%d0.l*2),%d3
	move.l %d4,-(%sp)
	moveq #127,%d0
	pea 9(%a3)
	and.l %d0,%d3
	jsr 1073770536
	addq.l #8,%sp
	tst.l %d0
	jgt .L1219
	clr.l -172(%fp)
.L1220:
	mvz.b 24(%a5),%d7
	move.b -172(%fp),%d6
	move.b -171(%fp),%d5
	move.b -170(%fp),%d1
	move.b -169(%fp),%d0
	cmp.l %d3,%d7
	jne .L1223
	mvs.b (%a2),%d7
	move.l %d7,%a1
	mvs.b %d6,%d7
	cmp.l %a1,%d7
	jne .L1223
	mvs.b 1(%a2),%d7
	move.l %d7,%a1
	mvs.b %d5,%d7
	cmp.l %a1,%d7
	jne .L1223
	mvs.b 2(%a2),%d7
	move.l %d7,%a1
	mvs.b %d1,%d7
	cmp.l %a1,%d7
	jne .L1223
	mvs.b 3(%a2),%d7
	move.l %d7,%a1
	mvs.b %d0,%d7
	cmp.l %a1,%d7
	jeq .L1224
.L1223:
	move.b %d3,24(%a5)
	move.b %d0,3(%a2)
	moveq #1,%d0
	move.b %d6,(%a2)
	move.b %d5,1(%a2)
	move.b %d1,2(%a2)
	move.b %d0,dp+23
.L1224:
	addq.l #1,%a3
	addq.l #4,%a2
	addq.l #1,%a5
	moveq #8,%d1
	cmp.l %a3,%d1
	jne .L1225
	tst.b dp+23.l
	jeq .L1201
	move.w #18689,%d4
	moveq #3,%d5
	move.b %d2,-133(%fp)
	move.l #-260222380,%d3
	moveq #9,%d0
	move.l %fp,%d1
	add.l #-140,%d1
	move.l %d1,%a1
	addq.l #8,%a1
	move.l %d3,-140(%fp)
	lea dp+24,%a2
	move.w %d4,-136(%fp)
	move.b %d5,-134(%fp)
.L1227:
	move.b (%a2)+,(%a1)
	mov3q.l #1,%a0
.L1226:
	lea 31(%a4,%a0.l),%a3
	mov3q.l #5,%d2
	move.b (%a3),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d2
	jne .L1226
	addq.l #5,%a1
	addq.l #5,%d0
	addq.l #4,%a4
	moveq #49,%d3
	cmp.l %d0,%d3
	jne .L1227
	moveq #-9,%d4
	pea 49.w
	move.l %d1,-(%sp)
	move.b %d4,-92(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1201
	clr.b %d5
	addq.l #1,dp+16
	move.b %d5,dp+23
.L1201:
	tst.l st
	jeq .L1197
.L1198:
	mov3q.l #1,%d6
	cmp.l 1094562388.l,%d6
	jne .L1197
	tst.l st+968
	jeq .L1197
	move.b 1079807565,%d2
	mvs.b %d2,%d0
	lsr.l #7,%d0
	jne .L1296
	addq.l #1,%d2
.L1228:
	move.l pj+160,%d0
	cmp.l pj+156.l,%d0
	jeq .L1232
	move.l pj+156,%d3
	sub.l %d0,%d3
	clr.l -(%sp)
	move.l %d3,%d0
	cmp.l #16383,%d3
	jls .L1230
	mvz.w #16383,%d0
.L1230:
	move.l %d0,-(%sp)
	mov3q.l #6,-(%sp)
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1262
	moveq #2,%d0
	add.l %d3,pj+160
	move.w %d0,pj+180
.L1232:
	move.l pj,%d1
	cmp.l pj+4.l,%d1
	jne .L1233
	tst.b pj+139.l
	jeq .L1234
	mvz.b pj+138,%d1
	mvz.b %d2,%d0
	cmp.l %d1,%d0
	jeq .L1235
.L1234:
	clr.l %d0
.L1236:
	move.l #1081903571,%a0
	lea pj-1081903431,%a1
.L1237:
	tst.l %d0
	jne .L1239
.L1240:
	move.l st+968,%d6
	cmp.l pj+164.l,%d6
	jeq .L1257
	moveq #2,%d7
	move.w %d7,pj+180
.L1257:
	clr.b %d0
	move.w #19201,%a1
	move.l #-260222380,%a0
	move.l %a0,-140(%fp)
	sub.l %a0,%a0
	move.b %d0,-134(%fp)
	mvz.b %d2,%d0
	lsr.l #7,%d0
	move.w %a1,-136(%fp)
	lea (-140,%fp),%a1
	move.b %d0,-133(%fp)
	moveq #127,%d0
	and.l %d2,%d0
	move.b %d0,-132(%fp)
.L1258:
	move.l #1081903571,%a2
	add.l %a0,%a2
	tst.b (%a2)
	jeq .L1259
	move.b (%a2),%d0
	moveq #127,%d1
	moveq #15,%d3
	and.l %d1,%d0
	move.b %d0,9(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d3
	jne .L1258
.L1259:
	moveq #-9,%d4
	lea (%fp,%a0.l),%a2
	move.b %d4,-131(%a2)
	pea 10(%a0)
	move.l %a1,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1262
	moveq #1,%d5
	move.b %d2,pj+138
	lea st+968,%a0
	lea st+8,%a1
	move.l (%a0),pj+164
	move.l (%a1),pj+168
	move.l #1081903571,%a0
	lea pj-1081903431,%a1
	move.b %d5,pj+139
.L1261:
	move.b (%a0),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L1261
	addq.l #1,pj+176
	jra .L1262
.L1291:
	sub.l %a0,%a0
	jra .L1215
.L1292:
	clr.l %d0
	jra .L1216
.L1294:
	clr.l %d0
.L1586:
	clr.b %d6
	jra .L1217
.L1219:
	moveq #52,%d1
	muls.l %d1,%d0
	move.l #1075575112,%a0
	move.l (%a0,%d0.l),%d6
	clr.l -172(%fp)
	move.l %d6,%d0
	sub.l %a0,%a0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L1220
.L1221:
	moveq #125,%d5
	move.b (%a0,%d6.l),%d1
	move.l %d1,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d5
	jcs .L1220
	lea (-172,%a0),%a1
	mov3q.l #4,%d0
	move.b %d1,(%a1,%fp.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L1221
	jra .L1220
.L1296:
	clr.b %d2
	jra .L1228
.L1233:
	moveq #31,%d0
	and.l pj+4,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #pj+8,%a0
	mvz.b 2(%a0),%d0
	move.l %d0,-(%sp)
	mvz.b 1(%a0),%d0
	move.l %d0,-(%sp)
	mvz.b (%a0),%d0
	move.l %d0,-(%sp)
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1262
	addq.l #1,pj+4
	addq.l #1,pj+172
	jra .L1232
.L1235:
	move.l st+968,%d3
	cmp.l pj+164.l,%d3
	jne .L1234
	move.l st+8,%d0
	moveq #99,%d4
	sub.l pj+168,%d0
	cmp.l %d0,%d4
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L1236
.L1239:
	move.b (%a0),%d3
	move.b (%a0,%a1.l),%d1
	addq.l #1,%a0
	move.l %d3,%d0
	eor.l %d1,%d0
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
	cmp.l #1081903587,%a0
	jne .L1237
	mvz.b %d3,%d3
	mvz.b %d1,%d1
	cmp.l %d3,%d1
	jne .L1240
	tst.b pj+181.l
	jeq .L1262
	move.l 1100949640,%d0
	mov3q.l #3,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L1241
	move.l %d0,%d1
	add.l #-1073741824,%d1
	cmp.l #129892351,%d1
	jhi .L1241
	move.l %d0,%a0
	add.l #1073744908,%d1
	lea (12,%a0),%a0
	move.l %a0,%a1
.L1244:
	mvz.b (%a1),%d0
	lsr.l #1,%d0
	jeq .L1242
.L1241:
	mvz.w #16383,%d0
	clr.l %d3
.L1243:
	clr.l -(%sp)
	move.l %d0,-(%sp)
	pea 9.w
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1262
	addq.l #1,pj+184
	tst.l %d3
	jeq .L1248
	move.b pj+181,%d0
	mvz.b %d0,%d1
	lsr.l #1,%d1
	jeq .L1248
	clr.b %d7
	subq.l #1,%d0
	move.b %d0,pj+181
	move.b %d7,pj+180
.L1262:
	tst.l st
	jeq .L1266
	mov3q.l #1,%d3
	cmp.l 1094562388.l,%d3
	jne .L1266
	tst.l st+968
	jeq .L1266
	move.l st+44,%d1
	move.l txsx_over,%d0
	cmp.l kd_drop.l,%d1
	jne .L1267
	cmp.l kd_over.l,%d0
	jeq .L1266
.L1267:
	move.l st+8,%a0
	moveq #19,%d4
	sub.l kd_t,%a0
	cmp.l %a0,%d4
	jcc .L1266
	cmp.l #16383,%d1
	jls .L1269
	mvz.w #16383,%d1
.L1269:
	cmp.l #16383,%d0
	jls .L1270
	mvz.w #16383,%d0
.L1270:
	move.l %d1,%d2
	moveq #127,%d7
	and.l %d7,%d1
	move.w #19713,%d6
	lsr.l #7,%d2
	pea 11.w
	move.l #-260222380,%d5
	pea -140(%fp)
	move.l %d5,-140(%fp)
	move.b %d2,-134(%fp)
	move.b %d1,-133(%fp)
	move.l %d0,%d1
	lsr.l #7,%d1
	and.l %d7,%d0
	move.w %d6,-136(%fp)
	move.b %d1,-132(%fp)
	move.b %d0,-131(%fp)
	moveq #-9,%d0
	move.b %d0,-130(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1266
	lea st+44,%a0
	lea txsx_over,%a1
	lea st+8,%a2
	move.l (%a0),kd_drop
	move.l (%a1),kd_over
	move.l (%a2),kd_t
.L1266:
	move.l -66650100,%d0
	sub.l -176(%fp),%d0
	addq.l #1,st+336
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L968
	move.l %d0,st+332
.L968:
	movem.l -228(%fp),#15612
	unlk %fp
	rts
.L1242:
	lea (24,%a1),%a1
	cmp.l %d1,%a1
	jne .L1244
	move.b pj+180,%d0
	move.l %a0,%d3
	tst.b %d0
	jge .L1245
	clr.l %d0
.L1246:
	tst.b (%a0)
	sne %d2
	lea (24,%a0),%a0
	mvs.b %d2,%d2
	sub.l %d2,%d0
	cmp.l %d1,%a0
	jne .L1246
	jra .L1243
.L1248:
	clr.b %d0
	move.b %d0,pj+181
	jra .L1262
.L1245:
	move.l #-260222380,%d1
	addq.l #1,%d0
	move.l %d1,-140(%fp)
	moveq #127,%d4
	mvz.b %d0,%d1
	moveq #8,%d3
	and.l %d4,%d0
	asr.l #7,%d1
	move.w #19201,%d2
	move.b %d1,-133(%fp)
	clr.l %d1
	move.b %d3,-134(%fp)
	move.b %d0,-132(%fp)
	move.b %d3,-131(%fp)
	move.w %d2,-136(%fp)
	move.l %fp,%d2
	add.l #-140,%d2
	move.l %d2,%a2
	lea (10,%a2),%a2
.L1256:
	mvz.b pj+180,%d0
	sub.l %a3,%a3
	add.l %d1,%d0
	muls.w #24,%d0
	lea (%a0,%d0.l),%a1
	tst.b (%a1)
	sne %d0
	neg.l %d0
	move.b %d0,(%a2)
.L1250:
	move.b (%a1),%d0
	jeq .L1249
	move.b 8(%a1,%a3.l),%d0
	moveq #127,%d5
	and.l %d5,%d0
.L1249:
	addq.l #1,%a3
	move.b %d0,(%a2,%a3.l)
	moveq #15,%d6
	cmp.l %a3,%d6
	jne .L1250
	sub.l %a1,%a1
.L1251:
	move.l %a1,%a3
	addq.l #1,%a1
	tst.b (%a2,%a1.l)
	jne .L1253
.L1254:
	moveq #15,%d3
	cmp.l %a3,%d3
	jeq .L1252
	clr.b %d0
	addq.l #1,%a3
	move.b %d0,(%a2,%a3.l)
	jra .L1254
.L1253:
	moveq #15,%d7
	cmp.l %a1,%d7
	jne .L1251
.L1252:
	addq.l #1,%d1
	lea (16,%a2),%a2
	moveq #8,%d4
	cmp.l %d1,%d4
	jne .L1256
	moveq #-9,%d5
	pea 139.w
	move.l %d2,-(%sp)
	move.b %d5,-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1262
	move.b pj+180,%d0
	addq.l #8,%d0
	move.b %d0,pj+180
	jra .L1262
.L1197:
	lea pj,%a0
	move.l (%a0),%d0
.L1263:
	cmp.l pj+4.l,%d0
	jeq .L1262
	moveq #31,%d1
	moveq #10,%d2
	and.l pj+4,%d1
	mvz.b 8(%a0,%d1.l*4),%d1
	cmp.l %d1,%d2
	jeq .L1264
	addq.l #1,pj+156
.L1264:
	addq.l #1,pj+4
	jra .L1263
.L1003:
	tst.b %d0
	jeq .L1004
.L1274:
	tst.b sv+8.l
	jeq .L1005
	move.l (%a0),%d0
	move.l ls,%d2
	eor.l %d2,%d0
	and.l #16776960,%d0
	or.l st+4,%d0
	jeq .L1001
.L1005:
	tst.b %d1
	jne .L1004
.L1006:
	mov3q.l #5,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1001:
	move.l ls_in_gen,%d6
	cmp.l ls+48.l,%d6
	jeq .L1007
	move.l ls_in_v,%d1
	lea ls_in_gen,%a0
	move.l (%a0),ls+48
	tst.b ls.l
	jeq .L1007
	move.l %d1,%d0
	lsr.l #8,%d0
	mvz.b ls+1,%d2
	cmp.l %d0,%d2
	jne .L1007
	mov3q.l #1,%d0
	and.l %d1,%d0
	mov3q.l #1,ls+40
	move.l %d0,ls+36
.L1007:
	tst.l ls+36
	jeq .L1008
	tst.l ls+40
	jne .L1008
	move.l st+8,%d0
	moveq #20,%d1
	sub.l ls+44,%d0
	cmp.l %d0,%d1
	jcc .L1008
	clr.l ls+36
	addq.l #1,ls+56
.L1008:
	move.l u46+8,%d0
	tst.l %d0
	jeq .L1009
	tst.b ls.l
	jne .L1010
	tst.l st+4
	jne .L1010
	move.l st+8,%d1
	moveq #20,%d2
	sub.l %d0,%d1
	cmp.l %d1,%d2
	jcs .L1010
	move.l #1093765506,%a1
	moveq #11,%d3
	mvz.b (%a1),%d0
	cmp.l %d0,%d3
	jcs .L1010
	move.l -2147457096,%d0
	moveq #127,%d4
	mvz.b (%a1),%d1
	and.l %d4,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d1
	move.l u46+12,%d0
	cmp.l %d1,%d0
	jeq .L1011
.L1010:
	clr.l u46+8
.L1009:
	move.l pm,%d2
	tst.l %d2
	jeq .L1014
	clr.l pm
	add.l #31,%d2
	tst.b ls.l
	jeq .L1015
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1015:
	clr.l st+1038
	tst.l st+4
	jeq .L1016
	moveq #1,%d7
	mvz.w #256,%d6
	moveq #1,%d0
	move.b %d2,st+993
	addq.l #1,pm+16
	move.l %d6,st+296
	move.b %d7,st+161
	move.w %d0,st+162
.L1017:
	tst.l st+1058
	jne .L1019
	tst.l sv+96
	jne .L1020
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jeq .L1018
	lea st+8,%a0
	mov3q.l #1,st+1058
	mov3q.l #1,st+1062
	move.l (%a0),st+1066
	addq.l #1,st+1070
	addq.l #1,st+1090
.L1019:
	tst.l st+4
	jne .L1021
	clr.l st+1058
.L1022:
	tst.l st+972
	jne .L1026
	tst.b sv+8.l
	jne .L1026
.L1027:
	move.l st+1082,%d0
	tst.l %d0
	jeq .L1029
	sub.l st+8,%d0
	tst.l %d0
	jgt .L1030
	clr.l st+1082
.L1030:
	moveq #1,%d4
	move.b %d4,32(%a2)
.L1029:
	move.l sq_gen,%d0
	move.b 1093765506,%d2
	cmp.l sq+400.l,%d0
	jeq .L1031
	mov3q.l #1,%d1
	and.l %d0,%d1
	btst #0,%d0
	jne .L1031
	sub.l %a0,%a0
	lea sq_req,%a1
.L1032:
	lea (%a1,%a0.l),%a3
	mov3q.l #7,%d3
	lea (-140,%fp),%a2
	move.b (%a3),(%a2,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d3
	jne .L1032
	cmp.l sq_gen.l,%d0
	jne .L1031
	move.l %d0,sq+400
	mvz.b -139(%fp),%d0
	mvz.b -140(%fp),%d3
	lsl.l #7,%d0
	or.l %d3,%d0
	mvz.b -137(%fp),%d3
	and.l #4095,%d0
	move.l %d0,sq+4
	mvz.b -136(%fp),%d0
	lsl.l #7,%d0
	or.l %d3,%d0
	move.b -138(%fp),%d3
	and.l #4095,%d0
	or.l sq+4,%d0
	move.l %d0,sq+8
	move.w %d3,%ccr
	jeq .L1034
	move.l sq+4,%d1
.L1034:
	mvz.b -134(%fp),%d0
	mvz.b -135(%fp),%d4
	lsl.l #7,%d0
	or.l %d4,%d0
	and.l #4095,%d0
	or.l %d1,%d0
	move.l %d0,pin
	tst.l sq
	jeq .L1035
	btst #1,%d3
	jeq .L1036
.L1035:
	mvz.w #255,%d4
	mvz.w #8191,%d5
	addq.l #1,sq+452
	mov3q.l #1,ed+92
	move.l %d4,sq+404
	move.l %d5,ed+260
.L1036:
	mov3q.l #1,sq
.L1031:
	tst.l sq
	jne .L1037
	clr.l sq+408
.L1038:
	move.l st+4,%d0
	move.l led_gen,%d1
	or.l sq+408,%d0
	jeq .L1088
	tst.l sq+468
	jne .L1089
	lea led_gen,%a1
	move.l (%a1),st+1002
	lea pg_gen,%a2
	move.l #2139062143,%a3
	clr.l st+1006
	mov3q.l #1,sq+476
	move.l (%a2),sq+472
	move.l %a3,sq+480
.L1089:
	mov3q.l #1,sq+468
	cmp.l st+1002.l,%d1
	jeq .L1091
	btst #0,%d1
	jne .L1091
	move.b led_req_mode,%d2
	clr.l %d0
	lea led_req,%a1
	lea (-140,%fp),%a0
.L1092:
	lea (%a1,%d0.l),%a2
	moveq #16,%d3
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d3
	jne .L1092
	cmp.l led_gen.l,%d1
	jne .L1091
	mvz.b %d2,%d2
	move.l %d1,st+1002
	clr.l %d0
	lea st+1022,%a1
	move.l %d2,st+1006
.L1094:
	lea (%a0,%d0.l),%a2
	moveq #16,%d1
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1094
	moveq #1,%d2
	move.b %d2,led_owed
.L1091:
	mov3q.l #1,%d3
	cmp.l st+1006.l,%d3
	jne .L1090
	clr.l led_again
	tst.b ov_on.l
	jeq .L1099
	tst.b led_owed.l
	jeq .L1097
.L1099:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jeq .L1583
	clr.l %d0
	lea st+1022,%a2
	lea ov_col,%a0
.L1100:
	lea (%a2,%d0.l),%a1
	moveq #16,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1100
	moveq #1,%d2
	move.l %fp,%d3
	add.l #-140,%d3
	lea led_send4,%a3
	move.b %d2,ov_on
	clr.l %d2
.L1101:
	move.b (%a2,%d2.l),%d0
	move.l %d3,-(%sp)
	moveq #16,%d4
	move.l %d2,-(%sp)
	addq.l #1,%d2
	move.b %d0,-137(%fp)
	move.b %d0,-138(%fp)
	move.b %d0,-139(%fp)
	move.b %d0,-140(%fp)
	jsr (%a3)
	addq.l #8,%sp
	cmp.l %d2,%d4
	jne .L1101
	clr.b %d5
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #1,st+1010
	move.b %d5,led_owed
	jra .L1584
.L1002:
	tst.b %d0
	jne .L1274
	jra .L1006
	.size	rui_tick, .-rui_tick
	.text
.LC6:
	.string	"%s"
	.text
	.align	2
	.globl	rui_draw
	.type	rui_draw, @function
rui_draw:
	lea (-248,%sp),%sp
	movem.l #31996,(%sp)
	move.l 252(%sp),%a2
	move.l -66650100,%d1
	move.l st+1082,%d0
	move.l 16(%a2),%d3
	move.l %d1,60(%sp)
	tst.l %d0
	jeq .L1588
	sub.l st+8,%d0
	tst.l %d0
	jgt .L1589
.L1588:
	clr.l 44(%sp)
.L1590:
	move.l 16(%a2),%a2
	move.l %a2,52(%sp)
	tst.l st+4
	jne .L1592
	tst.l st+972
	jne .L1593
	tst.b sv+8.l
	jne .L1593
	tst.l 44(%sp)
	jeq .L1595
	jra .L1627
.L1589:
	move.l %d3,%a0
	move.l %d3,%d0
	addq.l #6,%a0
	lea (108,%sp),%a1
	add.l #566,%d0
.L1591:
	move.b 1(%a0),(%a1)
	addq.l #8,%a0
	move.b -8(%a0),1(%a1)
	addq.l #2,%a1
	cmp.l %a0,%d0
	jne .L1591
	mov3q.l #1,44(%sp)
	jra .L1590
.L1592:
	tst.l st+1058
	jne .L1595
	move.l commits,%a6
	cmp.l st+24.l,%a6
	jne .L1597
	move.l 52(%sp),%a0
	move.l %a0,%d0
	add.l #1024,%d0
.L1598:
	clr.l (%a0)+
	cmp.l %a0,%d0
	jne .L1598
	move.l %a6,st+20
.L1599:
	tst.l 44(%sp)
	jeq .L1595
	tst.l st+4
	jne .L1623
	tst.l st+972
	jne .L1624
.L1627:
	tst.b sv+8.l
	jne .L1624
.L1595:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 60(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L1587
	move.l %d0,st+332
.L1587:
	movem.l (%sp),#31996
	lea (248,%sp),%sp
	rts
.L1593:
	move.l commits,%a6
.L1597:
	cmp.l st+340.l,%a6
	jne .L1600
	tst.l st+344
	jeq .L1601
.L1600:
	move.l -66650100,%d2
	move.l sh_seq,%d4
	lea copy32,%a2
	move.l %d2,64(%sp)
	btst #0,%d4
	jne .L1602
	pea 256.w
	pea shadow
	pea comp
	jsr (%a2)
	pea 704.w
	pea txt_sh
	pea (tl.0)
	jsr (%a2)
	lea (24,%sp),%sp
	cmp.l sh_seq.l,%d4
	jne .L1602
	tst.l st+872
	jne .L1603
	clr.l -(%sp)
	pea comp
	pea 64.w
	pea 128.w
	pea st+872
	jsr 1074198978
	lea (20,%sp),%sp
.L1603:
	lea (tl.0),%a2
	clr.l %d5
.L1616:
	tst.b 4(%a2)
	jeq .L1604
	move.l %a2,%d4
	clr.l %d7
	addq.l #8,%d4
	lea st+408,%a5
	lea st+552,%a0
.L1615:
	tst.l (%a5)+
	jeq .L1606
	mvz.b (%a0),%d0
	cmp.l %d0,%d5
	jne .L1606
	lea st+472,%a1
	mvz.b 5(%a0),%d1
	mvz.b (%a1,%d7.l),%d4
	lea (6,%a0),%a3
	sub.l %a1,%a1
.L1608:
	cmp.l %d1,%a1
	jlt .L1609
	move.b 4(%a0),%d0
	lea 72(%sp,%d1.l),%a3
	btst #1,%d0
	jeq .L1628
	move.l %d4,%d0
	add.l #-64,%d0
	move.l %d0,56(%sp)
	tst.l %d0
	jle .L1611
	move.b #43,(%a3)
	addq.l #1,%d1
	lea 72(%sp,%d1.l),%a3
.L1629:
	sub.l %a1,%a1
	jra .L1610
.L1609:
	lea (%a3,%a1.l),%a4
	move.b (%a4),72(%sp,%a1.l)
	addq.l #1,%a1
	jra .L1608
.L1611:
	tst.l 56(%sp)
	jeq .L1629
	move.b #45,(%a3)
	moveq #64,%d2
	mov3q.l #1,%a1
	sub.l %d4,%d2
	move.l %d2,56(%sp)
.L1610:
	lea (68,%sp),%a4
	clr.l %d4
.L1613:
	move.l 56(%sp),%d6
	moveq #10,%d0
	addq.l #1,%d4
	rems.l %d0,%d2:%d6
	divs.l %d0,%d6
	add.l #48,%d2
	move.b %d2,(%a4)
	move.l %d6,56(%sp)
	tst.l %d6
	jeq .L1612
	addq.l #1,%a4
	mov3q.l #4,%d6
	cmp.l %d4,%d6
	jne .L1613
.L1612:
	add.l %a1,%a3
	move.l %d4,%d0
.L1614:
	subq.l #1,%d0
	move.b 68(%sp,%d0.l),(%a3)+
	tst.l %d0
	jne .L1614
	mvz.w #248,%d0
	add.l %sp,%d0
	add.l %d1,%d0
	add.l %d4,%d0
	add.l %d0,%a1
	clr.b %d0
	move.l %sp,%d4
	add.l #72,%d4
	move.b %d0,-176(%a1)
.L1606:
	addq.l #1,%d7
	lea (20,%a0),%a0
	moveq #16,%d1
	cmp.l %d7,%d1
	jne .L1615
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
	jgt .L1604
	move.b 3(%a2),%d1
	move.l %d4,-(%sp)
	pea .LC6
	move.l %d4,-(%sp)
	mov3q.l #1,%d2
	mov3q.l #3,%d6
	move.l %d1,%d4
	lsr.l #2,%d4
	and.l %d1,%d6
	and.l %d4,%d2
	move.l %d2,-(%sp)
	move.l %d6,-(%sp)
	move.l %d0,-(%sp)
	mvz.b (%a2),%d0
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	pea st+872
	jsr 1074205920
	lea (36,%sp),%sp
	addq.l #1,st+352
.L1604:
	addq.l #1,%d5
	lea (44,%a2),%a2
	moveq #64,%d0
	cmp.l %d5,%d0
	jne .L1616
	move.l -66650100,%d0
	move.l %a6,st+340
	addq.l #1,st+348
	sub.l 64(%sp),%d0
	add.l %d0,st+356
	cmp.l st+360.l,%d0
	jls .L1617
	move.l %d0,st+360
.L1617:
	clr.l st+344
.L1601:
	pea 256.w
	pea comp
	move.l 60(%sp),-(%sp)
	jsr copy32
	lea (12,%sp),%sp
	cmp.l st+20.l,%a6
	jeq .L1618
	move.l -66650100,%d0
	addq.l #1,st+308
	sub.l t_commit,%d0
	add.l %d0,st+304
	cmp.l st+312.l,%d0
	jls .L1618
	move.l %d0,st+312
.L1618:
	move.l st+388,%d1
	tst.l %d1
	jeq .L1619
	cmp.l st+392.l,%a6
	jeq .L1619
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+396
	addq.l #1,st+400
	cmp.l st+404.l,%d0
	jls .L1620
	move.l %d0,st+404
.L1620:
	clr.l st+388
.L1619:
	move.l st+368,%d1
	tst.l %d1
	jeq .L1621
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+372
	addq.l #1,st+376
	cmp.l st+380.l,%d0
	jls .L1622
	move.l %d0,st+380
.L1622:
	clr.l st+368
.L1621:
	move.l %a6,st+20
	move.l -66650100,%d0
	move.l %d0,st+56
	sub.l t_commit,%d0
	addq.l #1,st+28
	move.l %d0,st+60
	jra .L1599
.L1628:
	move.l %d4,56(%sp)
	jra .L1629
.L1602:
	pea 256.w
	pea comp
	move.l 60(%sp),-(%sp)
	addq.l #1,st+32
	jsr (%a2)
	lea (12,%sp),%sp
	jra .L1599
.L1623:
	tst.l st+1058
	jne .L1595
.L1624:
	move.l %d3,%a0
	add.l #566,%d3
	lea (108,%sp),%a1
	addq.l #6,%a0
.L1625:
	move.b (%a0),%d0
	move.b (%a1),1(%a0)
	moveq #-2,%d1
	mov3q.l #1,%d2
	addq.l #2,%a1
	addq.l #8,%a0
	and.l %d1,%d0
	move.b -1(%a1),%d1
	and.l %d2,%d1
	or.l %d1,%d0
	move.b %d0,-8(%a0)
	cmp.l %d3,%a0
	jne .L1625
	jra .L1595
	.size	rui_draw, .-rui_draw
	.align	2
	.globl	rui_key
	.type	rui_key, @function
rui_key:
	lea (-100,%sp),%sp
	movem.l #31996,(%sp)
	move.l 108(%sp),%a4
	move.l -66650100,%d1
	move.l 104(%sp),%a3
	move.l 12(%a4),%d4
	move.l %d4,%d2
	mvz.b %d2,%d2
	move.l %d1,64(%sp)
	mov3q.l #1,%d1
	and.l 16(%a4),%d1
	cmp.l #178,%d2
	jne .L1653
	cmp.l ed+88.l,%d1
	jeq .L1653
	move.l %d1,ed+88
	mov3q.l #1,ed+92
.L1653:
	move.l 16(%a4),%d0
	move.l %d1,%d3
	lsl.l #8,%d3
	lea st,%a2
	lsl.l #8,%d0
	and.l #65024,%d0
	or.l %d3,%d0
	or.l %d2,%d0
	move.l %d0,st+72
	tst.l %d1
	jne .L1654
	moveq #66,%d5
	cmp.l %d2,%d5
	jne .L1655
	tst.b k44+20.l
	jeq .L1656
	clr.b %d6
	move.b %d6,k44+20
	tst.b k44+22.l
	jeq .L1656
	moveq #2,%d7
	move.w %d7,k44+22
.L1656:
	clr.l u46
	tst.b u46+48.l
	jeq .L1657
	clr.b %d0
	move.b %d0,u46+48
.L1664:
	mov3q.l #1,%d0
.L1658:
	move.l -66650100,%d1
	addq.l #1,st+336
	sub.l 64(%sp),%d1
	add.l %d1,st+328
	cmp.l st+332.l,%d1
	jls .L1652
	move.l %d1,st+332
.L1652:
	movem.l (%sp),#31996
	lea (100,%sp),%sp
	rts
.L1655:
	cmp.l #134,%d2
	jne .L1659
	clr.l tk
	tst.l tk+8
	jeq .L1657
	move.l st+248,%d0
	clr.l tk+8
	btst #6,%d0
	jeq .L1660
	moveq #-65,%d1
	and.l %d0,%d1
	move.l %d1,st+248
	tst.l st+4
	jne .L1938
.L1660:
	clr.l %d0
	jra .L1658
.L1659:
	move.l %d2,%d0
	add.l #-68,%d0
	lsr.l #1,%d0
	jne .L1657
	moveq #31,%d1
	mov3q.l #1,%d0
	and.l %d4,%d1
	lsl.l %d1,%d0
	and.l st+208,%d0
	tst.l %d0
	jeq .L1662
	move.l st+200,%d3
	move.l %d3,%d5
	move.l st+220,%d1
	move.l %d1,%d0
	and.l #2097152,%d0
	and.l #786432,%d5
	or.l %d5,%d0
	jeq .L1663
	addq.l #1,nk+16
.L1663:
	and.l #-786433,%d3
	bclr #21,%d1
	move.l %d3,st+200
	move.l %d1,st+220
.L1662:
	moveq #69,%d6
	cmp.l %d2,%d6
	jne .L1657
	tst.l nk
	jeq .L1657
	moveq #-33,%d7
	and.l %d7,st+240
	clr.l nk
	tst.l st+4
	jeq .L1664
	mov3q.l #1,-(%sp)
	pea 69.w
	lea queue_key,%a2
	jsr (%a2)
	clr.l -(%sp)
	pea 69.w
	jsr (%a2)
.L1944:
	jsr flush
	jra .L1933
.L1657:
	moveq #31,%d0
	and.l %d0,%d4
	move.l %d2,%d1
	lsr.l #5,%d1
	mov3q.l #1,%d0
	move.l %d1,%a0
	lea (66,%a0),%a0
	lsl.l %d4,%d0
	move.l (%a2,%a0.l*4),%d5
	move.l %d5,%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L1665
	not.l %d0
	and.l %d5,%d0
	move.l %d0,(%a2,%a0.l*4)
	jra .L1664
.L1665:
	move.l %d2,%d4
	mov3q.l #5,%d5
	add.l #-64,%d4
	cmp.l %d4,%d5
	jcs .L1666
	move.l ls+28,%d5
	btst %d4,%d5
	jeq .L1666
	mov3q.l #1,%d0
	lsl.l %d4,%d0
	move.l ls+32,%d1
	not.l %d0
	and.l %d0,%d5
	move.l %d5,ls+28
	btst %d4,%d1
	jeq .L1664
	and.l %d1,%d0
	move.l %d0,ls+32
.L1942:
	clr.l -(%sp)
.L1943:
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
.L1934:
	addq.l #8,%sp
	jra .L1664
.L1666:
	move.l %d1,%a1
	move.l %d0,%d4
	lea (121,%a1),%a1
	lea sq,%a0
	move.l (%a0,%a1.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L1667
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a0,%a1.l*4)
	jra .L1942
.L1667:
	move.l %d1,%a0
	move.l %d0,%d4
	lea (50,%a0),%a0
	move.l (%a2,%a0.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L1668
	not.l %d0
	and.l %d3,%d0
	move.l %d2,%d1
	mov3q.l #7,%d6
	add.l #-112,%d1
	move.l %d0,(%a2,%a0.l*4)
	cmp.l %d1,%d6
	jcs .L1660
	move.l ux,%d3
	btst %d1,%d3
	jeq .L1660
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	not.l %d0
	and.l %d3,%d0
	move.l %d0,ux
.L1938:
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
.L1939:
	addq.l #8,%sp
	jra .L1660
.L1668:
	move.l %d1,%a0
	move.l %d0,%d4
	lea (226,%a0),%a0
	move.l (%a2,%a0.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L1669
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a2,%a0.l*4)
	move.l st+4,%d0
	or.l sq+408,%d0
	jeq .L1660
	jra .L1938
.L1669:
	add.l #58,%d1
	move.l %d0,%d4
	move.l (%a2,%d1.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L1660
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a2,%d1.l*4)
	tst.l st+4
	jeq .L1664
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jra .L1934
.L1654:
	moveq #31,%d1
	mov3q.l #1,%d3
	and.l %d4,%d1
	move.l %d2,%d7
	lsr.l #5,%d7
	move.l %d7,%d0
	add.l #66,%d0
	move.l %d7,%a6
	move.l (%a2,%d0.l*4),%d0
	lsl.l %d1,%d3
	move.l %d1,60(%sp)
	and.l %d3,%d0
	tst.l %d0
	jne .L1664
	move.l %d7,%d5
	move.l %d3,%d0
	add.l #58,%d5
	and.l (%a2,%d5.l*4),%d0
	tst.l %d0
	jne .L1664
	move.l %d7,%d0
	add.l #121,%d0
	lea sq,%a5
	move.l (%a5,%d0.l*4),%d0
	and.l %d3,%d0
	tst.l %d0
	jne .L1664
	move.l %d7,%d6
	move.l %d3,%d0
	add.l #50,%d6
	and.l (%a2,%d6.l*4),%d0
	tst.l %d0
	jne .L1660
	move.l %d7,%d0
	add.l #226,%d0
	move.l (%a2,%d0.l*4),%d0
	and.l %d3,%d0
	tst.l %d0
	jne .L1660
	tst.l nk
	jeq .L1670
	move.l %d2,%d1
	add.l #-18,%d1
	lsr.l #1,%d1
	jeq .L1673
	cmp.l #181,%d2
	jne .L1672
.L1673:
	lea (%a4,%d0.l),%a0
	moveq #32,%d1
	move.l (%a0),68(%sp,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L1673
	moveq #69,%d2
	mov3q.l #1,%d4
	or.l %d4,84(%sp)
	moveq #-33,%d5
	and.l %d5,st+240
	or.l %d1,st+208
	clr.l nk
	addq.l #1,nk+4
	move.b %d2,83(%sp)
	pea 68(%sp)
	move.l %a3,-(%sp)
	jsr 1074397898
	or.l %d3,(%a2,%d6.l*4)
	jra .L1939
.L1672:
	clr.l nk
	addq.l #1,nk+8
	tst.l st+4
	jeq .L1670
	mov3q.l #1,-(%sp)
	pea 69.w
	jsr queue_key
	jsr flush
	addq.l #8,%sp
.L1670:
	moveq #66,%d6
	cmp.l %d2,%d6
	jne .L1674
	move.l st+4,%d0
	tst.l %d0
	jeq .L1675
	tst.l st+1058
	jne .L1676
.L1675:
	move.l st+216,%d1
	or.l st+248,%d1
	or.l st+920,%d1
	btst #0,%d1
	jne .L1676
	move.w #256,%d7
	lea st+8,%a0
	move.l (%a0),k44
	move.w %d7,k44+20
.L1676:
	lea st+8,%a0
	move.l (%a0),u46+4
	tst.l sq+408
	jeq .L1703
	tst.l %d0
	jeq .L1679
	tst.l st+1058
	jne .L1703
	move.l sq+484,%d1
	move.l st+232,%d0
.L1681:
	or.l %d1,%d0
	tst.w %d0
	jeq .L1703
	moveq #1,%d0
	clr.b %d1
	addq.l #1,u46+32
	move.b %d0,u46+48
	move.b %d1,k44+20
	jra .L1664
.L1674:
	cmp.l #128,%d2
	jne .L1677
	lea masks,%a0
	move.l (%a0),nk+20
.L1703:
	tst.l st+4
	jeq .L1719
	cmp.l #132,%d2
	jne .L1718
	move.l st+216,%d1
	move.l %d1,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L1718
	moveq #16,%d6
	or.l %d1,%d6
	move.l %d6,st+216
	tst.l st+1058
	jne .L1726
	lea st+8,%a0
	mov3q.l #1,st+1058
	clr.l st+1062
	move.l (%a0),st+1066
	addq.l #1,st+1070
.L1726:
	moveq #1,%d0
	move.l 32(%a3),%a0
	move.b %d0,32(%a0)
	jra .L1660
.L1679:
	move.l sq+484,%d1
	jra .L1681
.L1677:
	moveq #68,%d6
	cmp.l %d2,%d6
	jne .L1682
	move.l tk,%d0
	or.l u46,%d0
	jeq .L1683
	tst.l st+4
	jeq .L1683
	addq.l #1,tk+4
	jra .L1703
.L1683:
	move.l st+216,%d0
	moveq #64,%d7
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d0,%d7
	move.l %d7,%a0
	btst #6,%d0
	jne .L1685
	move.l st+240,%d0
	move.l st+208,%d7
	move.l %d7,%d1
	move.l st+912,%d6
	or.l %d0,%d1
	or.l %d6,%d1
	move.w %d1,%ccr
	jeq .L1686
	tst.b u46+48.l
	jeq .L1687
.L1686:
	move.l st+8,%a1
	mov3q.l #2,%d1
	sub.l u46+4,%a1
	cmp.l %a1,%d1
	jcc .L1688
.L1685:
	moveq #16,%d2
	or.l %d2,st+272
	tst.l %a0
	jne .L1689
	moveq #1,%d4
	addq.l #1,u46+20
	addq.l #1,u46+16
	move.b %d4,k44+21
.L1689:
	tst.l st+4
	jeq .L1690
	tst.b k44+22.l
	jeq .L1691
	tst.b k44+26.l
	jne .L1691
	tst.l %a0
	jne .L1691
	moveq #1,%d6
	moveq #1,%d7
	clr.b %d0
	mvz.w #256,%d5
	move.l %d5,st+296
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
.L1936:
	jsr flush
	jra .L1664
.L1691:
	mov3q.l #3,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr leave
	jra .L1934
.L1690:
	clr.l -(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
.L1937:
	lea (12,%sp),%sp
	jra .L1664
.L1688:
	move.w %d7,%ccr
	jeq .L1692
.L1687:
	or.l %d6,%d0
	move.w %d0,%ccr
	jeq .L1692
	tst.b u46+48.l
	jeq .L1703
.L1692:
	addq.l #1,u46+40
	jra .L1703
.L1682:
	moveq #53,%d1
	cmp.l %d2,%d1
	jne .L1693
	move.l st+216,%d6
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d6,50(%sp)
	btst #6,%d6
	jne .L1694
	move.l %a0,%d6
	moveq #64,%d0
	or.l %d7,%d6
	mov3q.l #4,%d1
	and.l %d0,%d6
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	and.l %d1,%d0
	or.l %d6,%d0
	jne .L1695
	tst.b u46+48.l
	jeq .L1703
.L1696:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L1694
.L1695:
	tst.l %d6
	jeq .L1696
.L1694:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #32,%d4
	swap %d4
	or.l %d7,%d1
	or.l %d4,st+268
	btst #6,%d1
	jeq .L1698
	mov3q.l #1,tk
.L1698:
	clr.l st+1038
	tst.l st+4
	jeq .L1699
	moveq #1,%d6
	mvz.w #256,%d5
	moveq #1,%d7
	moveq #1,%d0
	move.l %d5,st+296
	addq.l #1,st+998
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
	jra .L1936
.L1699:
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	addq.l #1,st+994
	jra .L1937
.L1693:
	moveq #16,%d1
	cmp.l %d2,%d1
	jne .L1678
	move.l st+216,%d6
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d6,50(%sp)
	btst #6,%d6
	jne .L1700
	move.l %a0,%d6
	moveq #64,%d0
	or.l %d7,%d6
	mov3q.l #4,%d1
	and.l %d0,%d6
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	and.l %d1,%d0
	or.l %d6,%d0
	jne .L1701
	tst.b u46+48.l
	jeq .L1703
.L1702:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L1700
.L1701:
	tst.l %d6
	jeq .L1702
.L1700:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #1,%d4
	swap %d4
	or.l %d7,%d1
	or.l %d4,st+264
	btst #6,%d1
	jeq .L1704
	mov3q.l #1,tk
.L1704:
	clr.l st+1038
	tst.l st+4
	jeq .L1705
	moveq #1,%d6
	mvz.w #256,%d5
	moveq #1,%d7
	moveq #2,%d0
	move.l %d5,st+296
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
.L1940:
	addq.l #1,st+1078
	jra .L1936
.L1705:
	mov3q.l #2,-(%sp)
.L1941:
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	addq.l #1,st+1074
	jra .L1937
.L1678:
	moveq #52,%d1
	cmp.l %d2,%d1
	jne .L1680
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L1706
	tst.b u46+48.l
	jeq .L1703
.L1706:
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #6,%d0
	jne .L1703
	tst.l sq+408
	jeq .L1707
	tst.w sq+486.l
	jne .L1703
.L1707:
	tst.w st+202.l
	jne .L1703
	moveq #1,%d2
	moveq #16,%d4
	swap %d4
	mov3q.l #1,u46
	addq.l #1,u46+16
	addq.l #1,u46+44
	clr.l st+1038
	move.b %d2,k44+21
	or.l %d4,st+268
	tst.l st+4
	jeq .L1708
	moveq #1,%d6
	moveq #3,%d7
	mvz.w #256,%d5
	move.b %d2,st+161
	move.l %d5,st+296
	move.w %d6,st+162
	move.b %d7,st+993
	jra .L1940
.L1708:
	mov3q.l #3,-(%sp)
	jra .L1941
.L1680:
	moveq #48,%d0
	cmp.l %d2,%d0
	jne .L1684
	move.l st+216,%d1
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d1,50(%sp)
	btst #6,%d1
	jne .L1709
	move.l %a0,%d6
	moveq #64,%d0
	or.l %d7,%d6
	mov3q.l #4,%d1
	and.l %d0,%d6
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	and.l %d1,%d0
	or.l %d6,%d0
	jne .L1710
	tst.b u46+48.l
	jeq .L1703
.L1711:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L1709
.L1710:
	tst.l %d6
	jeq .L1711
.L1709:
	mvz.b 1093765506,%d0
	moveq #11,%d4
	cmp.l %d0,%d4
	jcs .L1791
	move.b 1093765506,%d0
	add.l #16,%d0
.L1712:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #1,%d5
	swap %d5
	or.l %d7,%d1
	or.l %d5,st+268
	btst #6,%d1
	jeq .L1713
	mov3q.l #1,tk
.L1713:
	tst.l st+4
	jeq .L1714
	tst.l st+1038
	jeq .L1715
	mov3q.l #3,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr leave
	addq.l #1,st+1050
	jra .L1934
.L1791:
	moveq #16,%d0
	jra .L1712
.L1715:
	moveq #1,%d7
	moveq #1,%d1
	mvz.w #256,%d6
	move.b %d0,st+993
	mov3q.l #1,st+1038
	addq.l #1,st+1046
	move.l %d6,st+296
	move.b %d7,st+161
	move.w %d1,st+162
	jra .L1936
.L1714:
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	mov3q.l #1,st+1038
	addq.l #1,st+1042
	jra .L1937
.L1684:
	moveq #12,%d6
	cmp.l %d2,%d6
	jcs .L1697
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L1716
	tst.b u46+48.l
	jeq .L1703
.L1716:
	addq.l #1,%d2
	or.l %d3,st+264
	move.l %d2,dp
	addq.l #1,dp+4
	tst.b k44+22.l
	jne .L1664
	moveq #1,%d7
	move.b %d7,k44+21
	jra .L1664
.L1697:
	moveq #49,%d0
	cmp.l %d2,%d0
	jne .L1703
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L1717
	tst.b u46+48.l
	jeq .L1703
.L1717:
	tst.l st+4
	jne .L1718
	tst.l st+972
	jne .L1719
	tst.l sq+408
	jeq .L1720
	tst.w sq+486.l
	jne .L1719
.L1720:
	move.l st+200,%d6
	mvz.w %d6,%d6
	tst.l %d6
	jne .L1719
	move.b 1093765506,%d1
	moveq #11,%d2
	mvz.b %d1,%d3
	cmp.l %d3,%d2
	jlt .L1792
	moveq #127,%d0
	ext.w %d1
	and.l -2147457096,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d2
.L1721:
	moveq #1,%d4
	addq.l #1,u46+24
	addq.l #1,u46+16
	move.b %d4,k44+21
	tst.b ls.l
	jeq .L1722
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1722:
	clr.l u46+8
	moveq #11,%d5
	cmp.l %d3,%d5
	jlt .L1723
	move.l %d2,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L1724
	moveq #45,%d7
	cmp.l %d2,%d7
	jne .L1723
.L1724:
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	moveq #127,%d1
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jeq .L1723
	mov3q.l #1,%d4
	or.l st+8,%d4
	move.l %d2,u46+12
	moveq #45,%d5
	move.l %d4,u46+8
	cmp.l %d2,%d5
	jne .L1723
	lea (68,%sp),%a2
.L1725:
	lea (%a4,%d6.l),%a0
	moveq #32,%d0
	move.l (%a0),(%a2,%d6.l)
	addq.l #4,%d6
	cmp.l %d6,%d0
	jne .L1725
	moveq #50,%d1
	moveq #-2,%d2
	moveq #2,%d4
	swap %d4
	move.b %d1,83(%sp)
	move.l %a2,-(%sp)
	move.l %a3,-(%sp)
	jsr 1074397898
	and.l %d2,92(%sp)
	move.l %a2,-(%sp)
	move.l %a3,-(%sp)
	jsr 1074397898
	or.l %d4,st+268
.L1933:
	lea (16,%sp),%sp
	jra .L1664
.L1792:
	clr.l %d2
	jra .L1721
.L1723:
	moveq #2,%d5
	swap %d5
	or.l %d5,st+204
	jra .L1660
.L1719:
	tst.b ls.l
	jeq .L1727
	move.l %d2,%d1
	mov3q.l #5,%d6
	add.l #-64,%d1
	cmp.l %d1,%d6
	jcs .L1728
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	lea flush,%a2
	moveq #68,%d7
	or.l %d0,ls+28
	cmp.l %d2,%d7
	jne .L1729
	tst.l ls+36
	jne .L1730
	move.l st+216,%d0
	or.l st+920,%d0
	or.l st+248,%d0
	btst #0,%d0
	jeq .L1731
	lea st+8,%a0
	move.l (%a0),ls+44
	lea ls_in_gen,%a0
	move.l (%a0),ls+48
	clr.l -(%sp)
	mov3q.l #1,ls+36
	clr.l ls+40
	mov3q.l #3,-(%sp)
	addq.l #1,ls+52
	jsr ls_queue
.L1935:
	jsr (%a2)
	jra .L1934
.L1729:
	moveq #69,%d1
	cmp.l %d2,%d1
	jne .L1730
	tst.l ls+36
	jeq .L1793
.L1730:
	mov3q.l #1,-(%sp)
	or.l %d0,ls+32
	move.l %d2,-(%sp)
	addq.l #1,ls+88
	jsr queue_key
	jra .L1935
.L1731:
	move.l 1100949720,%a3
	move.l %a3,%d0
	clr.l ls+64
	clr.l ls+60
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L1733
	jsr sq_grid
	tst.l %d0
	jeq .L1733
	lea (348,%a3),%a0
	move.l (%a0),ls+60
	lea (344,%a3),%a3
	move.l (%a3),ls+64
.L1733:
	mvz.b ls+1,%d0
	lea st+8,%a0
	move.l (%a0),ls+72
	move.l %d0,ls+68
	moveq #1,%d0
.L1732:
	mov3q.l #3,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	jsr ls_close
	jsr (%a2)
	addq.l #4,%sp
	jra .L1664
.L1793:
	moveq #2,%d0
	jra .L1732
.L1728:
	move.l %d4,%d0
	and.l #240,%d0
	tst.l %d0
	jeq .L1727
	cmp.l #128,%d2
	jeq .L1727
	move.l %d2,%d0
	mov3q.l #2,%d6
	add.l #-80,%d0
	cmp.l %d0,%d6
	jcc .L1727
	add.l #-64,%d0
	moveq #11,%d7
	cmp.l %d0,%d7
	jcc .L1727
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
	tst.l st+4
	jne .L1718
.L1727:
	move.l st+972,%d0
	tst.b ls.l
	jne .L1734
	moveq #68,%d1
	cmp.l %d2,%d1
	jne .L1734
	tst.l %d0
	jne .L1735
	tst.b sv.l
	jeq .L1718
	tst.b sv+8.l
	jeq .L1718
	move.b sv+3,%d7
	jne .L1718
	move.l ls+24,%d0
	mov3q.l #4,%d6
	addq.l #2,%d0
	cmp.l %d0,%d6
	jcs .L1718
	move.b sv+1,%d1
	move.b %d1,59(%sp)
	mvz.b %d1,%d6
	mvz.b 1093765506,%d0
	cmp.l %d6,%d0
	jne .L1718
	move.b sv+2,%d6
	mvz.b %d6,%d1
	move.l %d1,-(%sp)
	move.l %d1,58(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L1736
	moveq #45,%d0
	cmp.l 54(%sp),%d0
	jne .L1718
.L1736:
	tst.l sq+408
	jeq .L1737
	tst.w sq+486.l
	jne .L1718
.L1737:
	move.l st+216,%d0
	or.l st+920,%d0
	or.l st+248,%d0
	btst #0,%d0
	jeq .L1718
	move.b 59(%sp),%d1
	move.b %d6,ls+2
	mvz.b %d6,%d6
	moveq #45,%d2
	move.b %d1,ls+1
	cmp.l %d6,%d2
	jne .L1794
	moveq #10,%d0
.L1738:
	clr.b %d4
	moveq #1,%d5
	move.b %d0,ls+124
	moveq #45,%d0
	move.b %d4,ls+126
	move.b %d5,ls
	cmp.l %d6,%d0
	jne .L1739
	moveq #3,%d7
.L1739:
	lea st+8,%a0
	move.l (%a0),ls+128
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	lea ls_queue,%a2
	move.b %d7,ls+125
	addq.l #1,ls+76
	addq.l #1,ls+144
	jsr (%a2)
	mov3q.l #1,ls+36
	clr.l ls+40
	lea st+8,%a0
	move.l (%a0),ls+44
	lea ls_in_gen,%a0
	move.l (%a0),ls+48
	mov3q.l #6,-(%sp)
	mov3q.l #3,-(%sp)
	addq.l #1,ls+52
	jsr (%a2)
	moveq #16,%d0
	or.l %d0,st+272
	jra .L1944
.L1794:
	clr.b %d0
	jra .L1738
.L1734:
	tst.l %d0
	jeq .L1718
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-80,%d0
	cmp.l %d0,%d1
	jcc .L1718
	add.l #-64,%d0
	moveq #11,%d6
	cmp.l %d0,%d6
	jcc .L1718
.L1735:
	mov3q.l #4,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr splash_end
	addq.l #8,%sp
	mov3q.l #5,%d7
	move.l %d2,%d0
	add.l #-64,%d0
	cmp.l %d0,%d7
	jcs .L1718
	or.l %d3,st+272
	jra .L1664
.L1718:
	move.l st+4,%d0
	tst.l sq+408
	jeq .L1740
	tst.l %d0
	jeq .L1741
	tst.l st+1058
	jne .L1742
.L1741:
	move.l %d2,%d1
	mov3q.l #2,%d6
	add.l #-80,%d1
	cmp.l %d1,%d6
	jcs .L1743
	move.l st+920,%d1
	move.l st+248,%d7
	move.l st+208,%d6
	or.l st+216,%d1
	move.l %d7,46(%sp)
	or.l st+240,%d6
	or.l %d7,%d1
	btst #0,%d1
	jeq .L1744
	move.l sq+484,%a0
	tst.l %d0
	jeq .L1795
	move.l st+232,%a1
.L1745:
	move.l %a0,%d7
	move.l %a1,%d1
	or.l %d7,%d1
	move.l %d1,%d7
	moveq #16,%d1
	mvz.w %d7,%d7
	and.l sq+500,%d1
	or.l %d7,%d1
	jne .L1747
	tst.l %d0
	jeq .L1744
	move.l 46(%sp),%d7
	btst #4,%d7
	jne .L1747
.L1744:
	move.l %d6,%d1
	or.l st+912,%d1
	move.w %d1,%ccr
	jeq .L1749
	tst.b u46+48.l
	jeq .L1750
.L1749:
	move.l sq+484,%a0
	tst.l %d0
	jeq .L1796
	move.l st+232,%d1
.L1751:
	move.l %a0,%d7
	or.l %d7,%d1
	tst.w %d1
	jeq .L1750
.L1747:
	or.l st+912,%d6
	move.w %d6,%ccr
	jeq .L1752
	tst.b u46+48.l
	jeq .L1753
.L1752:
	addq.l #1,u46+36
.L1753:
	tst.l %d0
	jeq .L1754
	move.l st+232,%d0
.L1754:
	move.l %a0,%d1
	or.l %d1,%d0
	move.l %d0,%d1
	mvz.w %d1,%d1
	tst.w %d0
	jeq .L1755
	moveq #80,%d4
	cmp.l %d2,%d4
	jeq .L1797
	moveq #82,%d5
	cmp.l %d2,%d5
	jne .L1798
	moveq #14,%d0
.L1756:
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	mov3q.l #1,-(%sp)
	or.l %d3,st+272
	move.l %d0,-(%sp)
	jsr ed_queue
	jra .L1933
.L1795:
	sub.l %a1,%a1
	jra .L1745
.L1796:
	clr.l %d1
	jra .L1751
.L1755:
	moveq #80,%d6
	cmp.l %d2,%d6
	jeq .L1799
	moveq #82,%d7
	cmp.l %d2,%d7
	jne .L1800
	moveq #10,%d0
	jra .L1756
.L1797:
	moveq #13,%d0
	jra .L1756
.L1798:
	moveq #15,%d0
	jra .L1756
.L1799:
	moveq #9,%d0
	jra .L1756
.L1800:
	moveq #11,%d0
	jra .L1756
.L1790:
	cmp.l #132,%d2
	jne .L1757
	move.l st+216,%d0
	move.l %d0,%d1
	or.l st+920,%d1
	btst #0,%d1
	jeq .L1757
	moveq #16,%d1
	or.l %d0,%d1
	addq.l #1,ed+84
	move.l %d1,st+216
	jra .L1660
.L1758:
	move.l %d4,%d0
	and.l #240,%d0
	tst.l %d0
	jeq .L1760
	and.l #251,%d4
	cmp.l #128,%d4
	jeq .L1760
	moveq #48,%d7
	cmp.l %d2,%d7
	jne .L1761
.L1760:
	lea sq,%a0
	addq.l #1,sq+460
	cmp.l #128,%d2
	jne .L1762
	mov3q.l #1,%d0
	or.l %d0,st+920
.L1763:
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	addq.l #8,%sp
	cmp.l #128,%d2
	sne %d0
.L1945:
	mvs.b %d0,%d0
	neg.l %d0
	jra .L1658
.L1762:
	lea (121,%a6),%a6
	or.l %d3,(%a0,%a6.l*4)
	jra .L1763
.L1768:
	move.l %d2,%d0
	add.l #-66,%d0
	lsr.l #1,%d0
	jne .L1771
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L1770
	move.l masks,%d6
	cmp.l nk+20.l,%d6
	jeq .L1769
.L1770:
	cmp.l #181,%d2
	jne .L1775
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L1779
.L1775:
	tst.l mask_set
	jeq .L1780
	lea mask_keys,%a0
	move.l (%a0,%a6.l*4),%d0
	move.l 60(%sp),%d7
	btst %d7,%d0
	jeq .L1779
.L1780:
	cmp.l #128,%d2
	jne .L1930
	mov3q.l #2,%d4
	jra .L1781
.L1772:
	addq.l #1,nk+24
	jra .L1773
.L1787:
	tst.l mask_set
	jeq .L1774
	lea mask_keys+8,%a0
	btst #5,3(%a0)
	jeq .L1775
.L1774:
	lea st+232,%a1
	clr.l %d1
	sub.l %a0,%a0
.L1777:
	tst.l (%a1)+
	jne .L1801
	tst.l 668(%a1)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1776:
	or.l %d0,%d1
	addq.l #1,%a0
	moveq #8,%d0
	cmp.l %a0,%d0
	jne .L1777
	move.l st+216,%d0
	mov3q.l #1,%d4
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d4,%d0
	or.l %d1,%d0
	jne .L1775
	moveq #32,%d5
	or.l %d5,st+240
	addq.l #1,st+936
	mov3q.l #1,nk
	jra .L1664
.L1801:
	mov3q.l #1,%d0
	jra .L1776
.L1930:
	mov3q.l #1,%d4
.L1781:
	addq.l #1,st+936
	mov3q.l #2,%d1
	cmp.l %d4,%d1
	jne .L1783
	lea (226,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
.L1784:
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	mov3q.l #2,%d2
	addq.l #8,%sp
	cmp.l %d4,%d2
	sne %d0
	jra .L1945
.L1783:
	or.l %d3,(%a2,%d5.l*4)
	jra .L1784
.L1771:
	moveq #69,%d0
	cmp.l %d2,%d0
	jeq .L1787
	move.l %d2,%d0
	mov3q.l #2,%d6
	add.l #-80,%d0
	cmp.l %d0,%d6
	jcs .L1770
.L1778:
	addq.l #1,st+944
.L1764:
	lea (50,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
	jra .L1660
.L1767:
	moveq #69,%d1
	cmp.l %d2,%d1
	jeq .L1779
	add.l #-80,%d2
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	jcc .L1778
.L1779:
	addq.l #1,st+940
	jra .L1764
.L1743:
	tst.l %d0
	jeq .L1790
.L1742:
	move.l %d2,%d0
	moveq #11,%d6
	add.l #-144,%d0
	cmp.l %d0,%d6
	jcs .L1765
	moveq #64,%d0
	and.l st+248,%d0
	tst.l %d0
	jeq .L1765
	move.l tk+8,%d0
	tst.l %d0
	jne .L1765
.L1766:
	lea (%a4,%d0.l),%a0
	moveq #32,%d1
	move.l (%a0),68(%sp,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L1766
	moveq #-122,%d4
	mov3q.l #1,%d6
	or.l %d6,84(%sp)
	mov3q.l #1,tk+8
	addq.l #1,tk+12
	move.b %d4,83(%sp)
	pea 68(%sp)
	move.l %a3,-(%sp)
	jsr 1074397898
	addq.l #8,%sp
.L1765:
	tst.l st+4
	jeq .L1764
	tst.l st+1058
	jne .L1767
	moveq #68,%d7
	cmp.l %d2,%d7
	jne .L1768
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
	move.l st+232,%d1
	mvz.w %d1,%d1
	or.l %d1,%d0
	jeq .L1775
.L1769:
	addq.l #1,st+936
	moveq #68,%d7
	cmp.l %d2,%d7
	jne .L1772
	addq.l #1,nk+12
.L1773:
	or.l %d3,st+240
	jra .L1946
.L1740:
	tst.l %d0
	jne .L1742
.L1761:
	tst.b sv.l
	jeq .L1742
	moveq #111,%d1
	cmp.l %d2,%d1
	jcc .L1764
	moveq #119,%d4
	cmp.l %d2,%d4
	jcs .L1742
	move.l %d2,%d1
	mov3q.l #1,%d0
	add.l #-112,%d1
	lsl.l %d1,%d0
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	addq.l #1,ux+4
	or.l %d0,ux
	jsr queue_key
	jsr flush
	or.l %d3,st+212
	jra .L1939
.L1750:
	tst.l %d0
	jne .L1765
.L1757:
	tst.w sq+486.l
	jeq .L1758
	move.l %d2,%d0
	mov3q.l #5,%d6
	add.l #-48,%d0
	cmp.l %d0,%d6
	jcc .L1759
	moveq #16,%d7
	cmp.l %d2,%d7
	jeq .L1759
	add.l #-20,%d0
	mov3q.l #1,%d1
	cmp.l %d0,%d1
	jcc .L1759
	add.l #-44,%d0
	lsr.l #3,%d0
	jne .L1758
.L1759:
	lea (121,%a6),%a6
	or.l %d3,(%a5,%a6.l*4)
	addq.l #1,st+1054
.L1946:
	mov3q.l #1,-(%sp)
	jra .L1943
	.size	rui_key, .-rui_key
	.align	2
	.globl	rui_enc
	.type	rui_enc, @function
rui_enc:
	lea (-68,%sp),%sp
	move.l 76(%sp),%a0
	movem.l #23804,(%sp)
	move.l -66650100,%d1
	lea (4,%a0),%a1
	move.l (%a1),st+76
	lea (8,%a0),%a1
	move.l (%a1),st+80
	lea (12,%a0),%a1
	move.l %d1,44(%sp)
	move.l (%a1),st+84
	lea (16,%a0),%a1
	move.l (%a1),st+88
	lea st,%a2
	mvz.b 20(%a0),%d0
	move.l %d0,st+92
	move.l 12(%a0),%a6
	move.l 16(%a0),%d2
	tst.l st+4
	jne .L1948
	tst.l sq+408
	jeq .L1949
	tst.w sq+486.l
	jeq .L1949
	mov3q.l #7,%d0
	cmp.l %a6,%d0
	jcs .L1949
	tst.b 20(%a0)
	jne .L1977
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+920,%d0
	and.l %d1,%d0
.L1950:
	add.l %d2,96(%a2,%a6.l*4)
	move.b %d0,st+160
	addq.l #1,sq+464
	jsr flush
.L1951:
	mov3q.l #1,%d2
	jra .L1954
.L1977:
	mov3q.l #1,%d0
	jra .L1950
.L1949:
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr ls_enc
	addq.l #8,%sp
	move.l %d0,%d2
	tst.l %d0
	jne .L1954
	moveq #8,%d3
	cmp.l %a6,%d3
	jne .L1953
	tst.b sv+8.l
	jeq .L1953
	move.l st+8,%a0
	addq.l #1,st+1086
	lea (47,%a0),%a0
	move.l %a0,st+1082
.L1953:
	tst.l st+972
	jeq .L1954
	mov3q.l #5,-(%sp)
	move.l 76(%sp),%a1
	move.l 32(%a1),-(%sp)
	jsr splash_end
	addq.l #8,%sp
.L1954:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 44(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L1947
	move.l %d0,st+332
.L1947:
	move.l %d2,%d0
	movem.l (%sp),#23804
	lea (68,%sp),%sp
	rts
.L1948:
	tst.l st+1058
	jeq .L1955
	addq.l #1,st+952
.L1956:
	clr.l %d2
	jra .L1954
.L1955:
	tst.l mask_set
	jeq .L1957
	moveq #15,%d0
	cmp.l %a6,%d0
	jcs .L1958
	move.l mask_enc,%d0
	move.l %a6,%d1
	btst %d1,%d0
	jne .L1957
.L1958:
	addq.l #1,st+952
	moveq #8,%d3
	cmp.l %a6,%d3
	jne .L1956
	move.l st+8,%a0
	addq.l #1,st+1086
	lea (47,%a0),%a0
	move.l %a0,st+1082
	jra .L1956
.L1957:
	addq.l #1,st+948
	tst.b 20(%a0)
	jne .L1978
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
.L1960:
	move.b %d0,st+160
	moveq #15,%d3
	cmp.l %a6,%d3
	jcs .L1951
	move.l %a6,%d4
	add.l #24,%d4
	add.l %d2,(%a2,%d4.l*4)
	tst.l st+64
	jne .L1962
	move.l #-66650100,%a0
	move.l (%a0),st+64
.L1962:
	tst.l st+388
	jne .L1963
	move.l #-66650100,%a1
	lea commits,%a0
	move.l (%a1),st+388
	move.l (%a0),st+392
.L1963:
	move.l %a6,%d5
	add.l #122,%d5
	lea bind_gen,%a4
	move.l (%a4,%a6.l*4),%d6
	move.l (%a2,%d5.l*4),%a3
	cmp.l %d6,%a3
	jeq .L1966
	btst #0,%d6
	jne .L1966
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
	jne .L1966
	move.l %d3,%d0
	move.l %a6,%d1
	add.l #st+552,%d0
	add.l #102,%d1
	tst.l (%a2,%d1.l*4)
	jeq .L1979
	move.l %d0,%a1
	move.b 48(%sp),%d3
	move.b (%a1),%d1
	eor.l %d1,%d3
	tst.b %d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
.L1968:
	mov3q.l #5,-(%sp)
	move.l %d7,-(%sp)
	move.l %d0,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	tst.l %d3
	jne .L1969
	lea (%a2,%a6.l),%a0
	move.b 49(%sp),472(%a0)
.L1969:
	move.l %d6,(%a2,%d5.l*4)
	move.l %d6,%a3
.L1966:
	tst.l %a3
	jeq .L1970
	move.l %a6,%d0
	moveq #20,%d3
	muls.l %d3,%d0
	lea (%a2,%d0.l),%a0
	mvz.b 552(%a0),%d1
	lsr.l #6,%d1
	jne .L1970
	lea (102,%a6),%a1
	add.l #st,%a6
	tst.l (%a2,%a1.l*4)
	jne .L1971
	move.b 553(%a0),472(%a6)
.L1971:
	move.l %d0,%a0
	add.l #st+556,%a0
	move.b (%a0),%d1
	mvz.b 472(%a6),%d3
	btst #0,%d1
	jeq .L1980
	tst.b st+160.l
	jne .L1981
.L1980:
	mov3q.l #1,%d1
.L1972:
	muls.l %d1,%d2
	move.l %d0,%a0
	add.l #st+554,%a0
	mvz.b (%a0),%d1
	add.l %d3,%d2
	cmp.l %d2,%d1
	jle .L1973
	move.l %d1,%d2
.L1973:
	move.l %d0,%a0
	add.l #st+555,%a0
	mvz.b (%a0),%d1
	cmp.l %d2,%d1
	jge .L1974
	move.l %d1,%d2
.L1974:
	move.l %d0,%a0
	add.l #st+553,%a0
	move.b %d2,(%a0)
	move.l 8(%a2),%a0
	addq.l #8,%a0
	move.l %a0,(%a2,%a1.l*4)
	move.b %d2,472(%a6)
	mov3q.l #1,st+344
	addq.l #1,st+364
	tst.l st+368
	jne .L1975
	move.l #-66650100,%a1
	move.l (%a1),st+368
.L1975:
	moveq #1,%d0
	move.l 72(%sp),%a1
	move.l 32(%a1),%a0
	move.b %d0,32(%a0)
.L1970:
	jsr flush
	tst.l (%a2,%d4.l*4)
	jne .L1951
	addq.l #1,st+384
	jra .L1951
.L1978:
	mov3q.l #1,%d0
	jra .L1960
.L1979:
	clr.l %d3
	jra .L1968
.L1981:
	moveq #8,%d1
	jra .L1972
	.size	rui_enc, .-rui_enc
	.align	2
	.globl	pj_write
	.type	pj_write, @function
pj_write:
	move.l 4(%sp),%d0
	move.l 8(%sp),%d1
	cmp.l #1074464814,%d0
	jeq .L1991
	cmp.l #1073958730,%d0
	jeq .L1991
	lea pj_push,%a0
	cmp.l #1074076072,%d0
	jne .L1993
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #5,-(%sp)
.L2006:
	jsr (%a0)
	lea (12,%sp),%sp
.L1991:
	rts
.L1993:
	cmp.l #1074076390,%d0
	jeq .L1994
	cmp.l #1074076276,%d0
	jne .L1995
.L1994:
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #3,-(%sp)
	jra .L2006
.L1995:
	cmp.l #1073959500,%d0
	jne .L1996
	mvz.b pj+137,%d0
	move.l %d1,-(%sp)
	move.l %d0,%a1
	pea -1(%a1)
	mov3q.l #2,-(%sp)
	jra .L2006
.L1996:
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #7,-(%sp)
	jra .L2006
	.size	pj_write, .-pj_write
	.align	2
	.globl	pj_delete
	.type	pj_delete, @function
pj_delete:
	move.l 4(%sp),-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #4,-(%sp)
	jsr pj_push
	lea (12,%sp),%sp
	rts
	.size	pj_delete, .-pj_delete
	.align	2
	.globl	pj_copy
	.type	pj_copy, @function
pj_copy:
	move.l 4(%sp),%d0
	moveq #127,%d1
	cmp.l %d0,%d1
	jcs .L2010
	addq.l #1,%d0
.L2009:
	move.b %d0,pj+137
	rts
.L2010:
	clr.b %d0
	jra .L2009
	.size	pj_copy, .-pj_copy
	.align	2
	.globl	pj_save
	.type	pj_save, @function
pj_save:
	move.l 4(%sp),%d0
	tst.l %d0
	jlt .L2011
	move.b 1079807565,%d1
	move.l %d0,-(%sp)
	mvs.b %d1,%d1
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr pj_push
	lea (12,%sp),%sp
.L2011:
	rts
	.size	pj_save, .-pj_save
	.align	2
	.globl	pj_activate
	.type	pj_activate, @function
pj_activate:
	move.l 4(%sp),%d0
	tst.l %d0
	jlt .L2013
	move.l #1074457822,%d1
	cmp.l 8(%sp),%d1
	jne .L2013
	move.l #1074479198,%d1
	cmp.l 12(%sp),%d1
	jne .L2013
	move.l %d0,12(%sp)
	moveq #10,%d0
	mov3q.l #-1,8(%sp)
	move.l %d0,4(%sp)
	jra pj_push
.L2013:
	rts
	.size	pj_activate, .-pj_activate
	.align	2
	.globl	kt_saved
	.type	kt_saved, @function
kt_saved:
	moveq #127,%d0
	moveq #127,%d1
	and.l 8(%sp),%d0
	move.l %d0,-(%sp)
	move.l 8(%sp),%d0
	cmp.l %d0,%d1
	jge .L2016
	moveq #127,%d0
.L2017:
	move.l %d0,-(%sp)
	pea 65.w
	jsr pj_push
	lea (12,%sp),%sp
	rts
.L2016:
	tst.l %d0
	jge .L2017
	clr.l %d0
	jra .L2017
	.size	kt_saved, .-kt_saved
	.align	2
	.globl	kt_reloaded
	.type	kt_reloaded, @function
kt_reloaded:
	move.l -2147457096,%d0
	moveq #127,%d1
	mov3q.l #-1,-(%sp)
	and.l %d0,%d1
	move.l %d1,-(%sp)
	mvz.b 15(%sp),%d0
	move.l %d0,-(%sp)
	jsr pj_push
	lea (12,%sp),%sp
	rts
	.size	kt_reloaded, .-kt_reloaded
	.text
	.type	CSWTCH.495, @object
	.size	CSWTCH.495, 7
CSWTCH.495:
	.byte	1
	.byte	0
	.byte	-1
	.byte	0
	.byte	-1
	.byte	-1
	.byte	2
	.zero	1
	.text
	.align	2
	.type	CSWTCH.493, @object
	.size	CSWTCH.493, 28
CSWTCH.493:
	.long	cu_wt_short
	.long	cu_gr_short
	.long	cu_li_short
	.long	cu_cp_short
	.long	cu_fm_short
	.long	cu_fm_short
	.long	cu_ms_short
	.local	tl.0
	.comm	tl.0,2816,1
	.section	.bss,"aw",@nobits
	.align	4
	.type	pj, @object
	.size	pj, 188
pj:
	.zero	188
	.local	kd_t
	.comm	kd_t,4,2
	.local	kd_over
	.comm	kd_over,4,2
	.local	kd_drop
	.comm	kd_drop,4,2
	.local	cu
	.comm	cu,24,4
	.text
.LC7:
	.string	"Stutter"
.LC8:
	.string	"STUT"
.LC9:
	.string	"Stutter Len"
.LC10:
	.string	"SLEN"
.LC11:
	.string	"Tape"
.LC12:
	.string	"TAPE"
.LC13:
	.string	"Tape Time"
.LC14:
	.string	"TTIM"
.LC15:
	.string	"Attack"
.LC16:
	.string	"ATK"
.LC17:
	.string	"Decay"
.LC18:
	.string	"DEC"
.LC19:
	.string	"Direction"
.LC20:
	.string	"DIR"
.LC21:
	.string	"Loop"
.LC22:
	.string	"LOOP"
	.text
	.align	2
	.type	cu_cpp2k, @object
	.size	cu_cpp2k, 112
cu_cpp2k:
	.long	.LC7
	.long	.LC8
	.word	410
	.byte	20
	.byte	0
	.word	272
	.long	.LC9
	.long	.LC10
	.word	410
	.byte	25
	.byte	0
	.word	0
	.long	.LC11
	.long	.LC12
	.word	410
	.byte	22
	.byte	0
	.word	260
	.long	.LC13
	.long	.LC14
	.word	410
	.byte	25
	.byte	0
	.word	0
	.long	.LC15
	.long	.LC16
	.word	410
	.byte	25
	.byte	0
	.word	0
	.long	.LC17
	.long	.LC18
	.word	410
	.byte	26
	.byte	0
	.word	0
	.long	.LC19
	.long	.LC20
	.word	410
	.byte	23
	.byte	0
	.word	259
	.long	.LC21
	.long	.LC22
	.word	410
	.byte	24
	.byte	0
	.word	260
	.text
.LC23:
	.string	"Sample"
.LC24:
	.string	"SRC"
.LC25:
	.string	"Slice"
.LC26:
	.string	"SLC"
.LC27:
	.string	"Tune"
.LC28:
	.string	"TUNE"
.LC29:
	.string	"Morph"
.LC30:
	.string	"MRPH"
.LC31:
	.string	"Shuffle Seed"
.LC32:
	.string	"SEED"
.LC33:
	.string	"Neighbour"
.LC34:
	.string	"NBR"
.LC35:
	.string	"Velocity"
.LC36:
	.string	"VEL"
.LC37:
	.string	"Level"
.LC38:
	.string	"LEV"
	.text
	.align	2
	.type	cu_cpk, @object
	.size	cu_cpk, 112
cu_cpk:
	.long	.LC23
	.long	.LC24
	.word	410
	.byte	9
	.byte	10
	.word	2944
	.long	.LC25
	.long	.LC26
	.word	410
	.byte	16
	.byte	0
	.word	320
	.long	.LC27
	.long	.LC28
	.word	40
	.byte	17
	.byte	64
	.word	0
	.long	.LC29
	.long	.LC30
	.word	410
	.byte	18
	.byte	0
	.word	0
	.long	.LC31
	.long	.LC32
	.word	410
	.byte	19
	.byte	0
	.word	0
	.long	.LC33
	.long	.LC34
	.word	410
	.byte	18
	.byte	0
	.word	0
	.long	.LC35
	.long	.LC36
	.word	410
	.byte	18
	.byte	64
	.word	0
	.long	.LC37
	.long	.LC38
	.word	101
	.byte	0
	.byte	100
	.word	0
	.text
.LC39:
	.string	"Release"
.LC40:
	.string	"REL"
.LC41:
	.string	"-"
	.text
	.align	2
	.type	cu_lip2k, @object
	.size	cu_lip2k, 112
cu_lip2k:
	.long	.LC39
	.long	.LC40
	.word	410
	.byte	0
	.byte	77
	.word	0
	.long	.LC41
	.long	.LC41
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC41
	.long	.LC41
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC41
	.long	.LC41
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC41
	.long	.LC41
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC41
	.long	.LC41
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC41
	.long	.LC41
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC41
	.long	.LC41
	.word	410
	.byte	0
	.byte	0
	.word	0
	.text
.LC42:
	.string	"Input"
.LC43:
	.string	"INPT"
.LC44:
	.string	"Gain"
.LC45:
	.string	"GAIN"
.LC46:
	.string	"Gate"
.LC47:
	.string	"GATE"
.LC48:
	.string	"Hold"
.LC49:
	.string	"HOLD"
.LC50:
	.string	"Monitor"
.LC51:
	.string	"MON"
.LC52:
	.string	"Sustain"
.LC53:
	.string	"SUS"
	.text
	.align	2
	.type	cu_lik, @object
	.size	cu_lik, 112
cu_lik:
	.long	.LC42
	.long	.LC43
	.word	410
	.byte	13
	.byte	80
	.word	260
	.long	.LC44
	.long	.LC45
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC46
	.long	.LC47
	.word	101
	.byte	15
	.byte	0
	.word	0
	.long	.LC48
	.long	.LC49
	.word	410
	.byte	0
	.byte	28
	.word	0
	.long	.LC50
	.long	.LC51
	.word	410
	.byte	14
	.byte	0
	.word	258
	.long	.LC15
	.long	.LC16
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC17
	.long	.LC18
	.word	410
	.byte	0
	.byte	77
	.word	0
	.long	.LC52
	.long	.LC53
	.word	101
	.byte	0
	.byte	0
	.word	0
	.text
.LC54:
	.string	"Hold/Freeze"
.LC55:
	.string	"Animate"
.LC56:
	.string	"ANIM"
.LC57:
	.string	"Chord"
.LC58:
	.string	"CHD"
.LC59:
	.string	"Inversion"
.LC60:
	.string	"INV"
.LC61:
	.string	"Spread"
.LC62:
	.string	"SPR"
.LC63:
	.string	"Voices"
.LC64:
	.string	"VOI"
	.text
	.align	2
	.type	cu_grp2k, @object
	.size	cu_grp2k, 112
cu_grp2k:
	.long	.LC15
	.long	.LC16
	.word	410
	.byte	0
	.byte	10
	.word	0
	.long	.LC39
	.long	.LC40
	.word	410
	.byte	0
	.byte	60
	.word	0
	.long	.LC54
	.long	.LC49
	.word	410
	.byte	10
	.byte	0
	.word	0
	.long	.LC55
	.long	.LC56
	.word	410
	.byte	11
	.byte	0
	.word	0
	.long	.LC57
	.long	.LC58
	.word	410
	.byte	3
	.byte	0
	.word	1552
	.long	.LC59
	.long	.LC60
	.word	410
	.byte	4
	.byte	0
	.word	1540
	.long	.LC61
	.long	.LC62
	.word	410
	.byte	5
	.byte	0
	.word	1539
	.long	.LC63
	.long	.LC64
	.word	410
	.byte	6
	.byte	0
	.word	1543
	.text
.LC65:
	.string	"Source"
.LC66:
	.string	"Position"
.LC67:
	.string	"POS"
.LC68:
	.string	"Spray"
.LC69:
	.string	"SPRY"
.LC70:
	.string	"Grain Size"
.LC71:
	.string	"SIZE"
.LC72:
	.string	"Density"
.LC73:
	.string	"DENS"
.LC74:
	.string	"Pitch Rand"
.LC75:
	.string	"PRND"
.LC76:
	.string	"Reverse"
.LC77:
	.string	"REV"
.LC78:
	.string	"WIN"
	.text
	.align	2
	.type	cu_grk, @object
	.size	cu_grk, 112
cu_grk:
	.long	.LC65
	.long	.LC24
	.word	410
	.byte	9
	.byte	10
	.word	2944
	.long	.LC66
	.long	.LC67
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC68
	.long	.LC69
	.word	410
	.byte	0
	.byte	20
	.word	0
	.long	.LC70
	.long	.LC71
	.word	410
	.byte	0
	.byte	64
	.word	0
	.long	.LC72
	.long	.LC73
	.word	410
	.byte	0
	.byte	64
	.word	0
	.long	.LC74
	.long	.LC75
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC76
	.long	.LC77
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC4
	.long	.LC78
	.word	410
	.byte	8
	.byte	0
	.word	260
	.text
.LC79:
	.string	"Env>Pos"
.LC80:
	.string	"ENV"
	.text
	.align	2
	.type	cu_wtp2k, @object
	.size	cu_wtp2k, 112
cu_wtp2k:
	.long	.LC15
	.long	.LC16
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC17
	.long	.LC18
	.word	410
	.byte	0
	.byte	64
	.word	0
	.long	.LC52
	.long	.LC53
	.word	410
	.byte	0
	.byte	100
	.word	0
	.long	.LC79
	.long	.LC80
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC57
	.long	.LC58
	.word	410
	.byte	3
	.byte	0
	.word	1552
	.long	.LC59
	.long	.LC60
	.word	410
	.byte	4
	.byte	0
	.word	1540
	.long	.LC61
	.long	.LC62
	.word	410
	.byte	5
	.byte	0
	.word	1539
	.long	.LC63
	.long	.LC64
	.word	410
	.byte	6
	.byte	0
	.word	1543
	.text
.LC81:
	.string	"Table"
.LC82:
	.string	"TBL"
.LC83:
	.string	"Warp"
.LC84:
	.string	"WARP"
.LC85:
	.string	"Amount"
.LC86:
	.string	"AMT"
.LC87:
	.string	"Unison"
.LC88:
	.string	"UNI"
.LC89:
	.string	"Sub Osc"
.LC90:
	.string	"SUB"
.LC91:
	.string	"Cutoff"
.LC92:
	.string	"CUT"
.LC93:
	.string	"Resonance"
.LC94:
	.string	"RES"
	.text
	.align	2
	.type	cu_wtk, @object
	.size	cu_wtk, 112
cu_wtk:
	.long	.LC81
	.long	.LC82
	.word	410
	.byte	12
	.byte	1
	.word	2944
	.long	.LC66
	.long	.LC67
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC83
	.long	.LC84
	.word	410
	.byte	7
	.byte	0
	.word	260
	.long	.LC85
	.long	.LC86
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC87
	.long	.LC88
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC89
	.long	.LC90
	.word	101
	.byte	0
	.byte	0
	.word	0
	.long	.LC91
	.long	.LC92
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC93
	.long	.LC94
	.word	410
	.byte	0
	.byte	0
	.word	0
	.text
.LC95:
	.string	"Fine Tune"
.LC96:
	.string	"FINE"
.LC97:
	.string	"Start"
.LC98:
	.string	"STRT"
	.text
	.align	2
	.type	cu_p2k, @object
	.size	cu_p2k, 112
cu_p2k:
	.long	.LC27
	.long	.LC28
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC95
	.long	.LC96
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC97
	.long	.LC98
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC21
	.long	.LC22
	.word	410
	.byte	2
	.byte	0
	.word	259
	.long	.LC57
	.long	.LC58
	.word	410
	.byte	3
	.byte	0
	.word	1552
	.long	.LC59
	.long	.LC60
	.word	410
	.byte	4
	.byte	0
	.word	1540
	.long	.LC61
	.long	.LC62
	.word	410
	.byte	5
	.byte	0
	.word	1539
	.long	.LC63
	.long	.LC64
	.word	410
	.byte	6
	.byte	0
	.word	1543
	.text
.LC99:
	.string	"Instrument"
.LC100:
	.string	"INST"
.LC101:
	.string	"Release Trig"
.LC102:
	.string	"RTRG"
	.text
	.align	2
	.type	cu_srck, @object
	.size	cu_srck, 112
cu_srck:
	.long	.LC99
	.long	.LC100
	.word	410
	.byte	12
	.byte	0
	.word	2944
	.long	.LC35
	.long	.LC36
	.word	410
	.byte	0
	.byte	127
	.word	0
	.long	.LC37
	.long	.LC38
	.word	101
	.byte	0
	.byte	100
	.word	0
	.long	.LC101
	.long	.LC102
	.word	410
	.byte	1
	.byte	0
	.word	258
	.long	.LC15
	.long	.LC16
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC17
	.long	.LC18
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC52
	.long	.LC53
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC39
	.long	.LC40
	.word	40
	.byte	0
	.byte	64
	.word	0
	.type	cu_fmt_spr, @object
	.size	cu_fmt_spr, 6
cu_fmt_spr:
	.string	"SPR%d"
	.type	cu_fmt_inv, @object
	.size	cu_fmt_inv, 6
cu_fmt_inv:
	.string	"INV%d"
	.type	cu_fmt_bk, @object
	.size	cu_fmt_bk, 7
cu_fmt_bk:
	.string	"%c%03d"
	.type	cu_fmt_d, @object
	.size	cu_fmt_d, 3
cu_fmt_d:
	.string	"%d"
	.type	cu_fmt_s, @object
	.size	cu_fmt_s, 3
cu_fmt_s:
	.string	"%s"
	.type	cu_fm_short, @object
	.size	cu_fm_short, 4
cu_fm_short:
	.string	"6OP"
	.type	cu_fmt_pct, @object
	.size	cu_fmt_pct, 5
cu_fmt_pct:
	.string	"%d%%"
	.type	cu_fmt_x, @object
	.size	cu_fmt_x, 4
cu_fmt_x:
	.string	"X%d"
	.type	cu_fmt_pd, @object
	.size	cu_fmt_pd, 4
cu_fmt_pd:
	.string	"+%d"
	.type	cu_fmt_db, @object
	.size	cu_fmt_db, 5
cu_fmt_db:
	.string	"%dDB"
	.type	cu_cloop, @object
	.size	cu_cloop, 20
cu_cloop:
	.string	"SLC"
	.zero	1
	.string	"OFF"
	.zero	1
	.string	"FWD"
	.zero	1
	.string	"PING"
	.type	cu_dir, @object
	.size	cu_dir, 12
cu_dir:
	.string	"SLC"
	.string	"FWD"
	.string	"REV"
	.type	cu_tape, @object
	.size	cu_tape, 20
cu_tape:
	.string	"SLC"
	.zero	1
	.string	"OFF"
	.zero	1
	.string	"STOP"
	.string	"SPIN"
	.type	cu_hold, @object
	.size	cu_hold, 5
cu_hold:
	.string	"HOLD"
	.type	cu_slc, @object
	.size	cu_slc, 4
cu_slc:
	.string	"SLC"
	.type	cu_mon, @object
	.size	cu_mon, 10
cu_mon:
	.string	"ALW"
	.zero	1
	.string	"TRIG"
	.type	cu_inpt, @object
	.size	cu_inpt, 16
cu_inpt:
	.string	"L"
	.zero	2
	.string	"R"
	.zero	2
	.string	"L+R"
	.string	"STR"
	.globl	cu_cp_short
	.type	cu_cp_short, @object
	.size	cu_cp_short, 5
cu_cp_short:
	.string	"CHOP"
	.globl	cu_cp_name
	.type	cu_cp_name, @object
	.size	cu_cp_name, 5
cu_cp_name:
	.string	"CHOP"
	.globl	cu_li_short
	.type	cu_li_short, @object
	.size	cu_li_short, 5
cu_li_short:
	.string	"LVIN"
	.globl	cu_li_name
	.type	cu_li_name, @object
	.size	cu_li_name, 8
cu_li_name:
	.string	"LIVE IN"
	.globl	cu_gr_short
	.type	cu_gr_short, @object
	.size	cu_gr_short, 5
cu_gr_short:
	.string	"GRAN"
	.globl	cu_gr_name
	.type	cu_gr_name, @object
	.size	cu_gr_name, 9
cu_gr_name:
	.string	"GRANULAR"
	.globl	cu_wt_short
	.type	cu_wt_short, @object
	.size	cu_wt_short, 5
cu_wt_short:
	.string	"WTBL"
	.globl	cu_wt_name
	.type	cu_wt_name, @object
	.size	cu_wt_name, 10
cu_wt_name:
	.string	"WAVETABLE"
	.globl	cu_ms_short
	.type	cu_ms_short, @object
	.size	cu_ms_short, 5
cu_ms_short:
	.string	"MSMP"
	.globl	cu_ms_name
	.type	cu_ms_name, @object
	.size	cu_ms_name, 10
cu_ms_name:
	.string	"MULTISAMP"
	.type	cu_off, @object
	.size	cu_off, 4
cu_off:
	.string	"OFF"
	.type	cu_frz, @object
	.size	cu_frz, 4
cu_frz:
	.string	"FRZ"
	.type	cu_anim, @object
	.size	cu_anim, 40
cu_anim:
	.string	"8BAR"
	.string	"4BAR"
	.string	"2BAR"
	.string	"1BAR"
	.string	"1/2"
	.zero	1
	.string	"1/4"
	.zero	1
	.string	"1/8"
	.zero	1
	.string	"1/16"
	.type	cu_win, @object
	.size	cu_win, 24
cu_win:
	.string	"HANN"
	.zero	1
	.string	"TRI"
	.zero	2
	.string	"TUKEY"
	.string	"PERC"
	.zero	1
	.type	cu_warp, @object
	.size	cu_warp, 20
cu_warp:
	.string	"OFF"
	.zero	1
	.string	"SYNC"
	.string	"PWM"
	.zero	1
	.string	"FM"
	.zero	2
	.type	cu_loop, @object
	.size	cu_loop, 15
cu_loop:
	.string	"AUTO"
	.string	"OFF"
	.zero	1
	.string	"ON"
	.zero	2
	.type	cu_chd, @object
	.size	cu_chd, 80
cu_chd:
	.string	"OFF"
	.zero	1
	.string	"MAJ"
	.zero	1
	.string	"MIN"
	.zero	1
	.string	"SUS2"
	.string	"SUS4"
	.string	"7"
	.zero	3
	.string	"MAJ7"
	.string	"MIN7"
	.string	"DIM"
	.zero	1
	.string	"AUG"
	.zero	1
	.string	"6"
	.zero	3
	.string	"MIN6"
	.string	"9"
	.zero	3
	.string	"ADD9"
	.string	"MIN9"
	.string	"5"
	.zero	3
	.align	2
	.type	cu_src, @object
	.size	cu_src, 16
cu_src:
	.word	398
	.word	443
	.word	399
	.word	400
	.word	401
	.word	402
	.word	406
	.word	407
	.align	2
	.type	cu_p2, @object
	.size	cu_p2, 16
cu_p2:
	.word	438
	.word	457
	.word	458
	.word	459
	.word	460
	.word	403
	.word	404
	.word	405
	.type	pm_t_track, @object
	.size	pm_t_track, 18
pm_t_track:
	.string	"SOUND TRACKS ONLY"
	.type	pm_t_none, @object
	.size	pm_t_none, 11
pm_t_none:
	.string	"NO SIDECAR"
	.globl	pm_text
	.type	pm_text, @object
	.size	pm_text, 12
pm_text:
	.string	"POLY CONFIG"
	.section	.bss
	.align	4
	.type	ls, @object
	.size	ls, 148
ls:
	.zero	148
	.align	4
	.type	pc, @object
	.size	pc, 94
pc:
	.zero	94
	.local	led_owed
	.comm	led_owed,1,1
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
	.local	sht
	.comm	sht,4,1
	.local	ovt_col
	.comm	ovt_col,1,1
	.local	ovt_on
	.comm	ovt_on,1,1
	.local	shp
	.comm	shp,16,1
	.local	ovp_col
	.comm	ovp_col,4,1
	.local	ovp_on
	.comm	ovp_on,1,1
	.local	led_again
	.comm	led_again,4,2
	.text
	.type	shs, @object
	.size	shs, 4
shs:
	.base64	"/////w=="
	.local	sh
	.comm	sh,64,1
	.local	ov_col
	.comm	ov_col,16,1
	.local	ov_on
	.comm	ov_on,1,1
	.local	ov_list
	.comm	ov_list,4,2
	.local	ov_n
	.comm	ov_n,4,2
	.local	ov_is
	.comm	ov_is,4,2
	.local	ov_vt
	.comm	ov_vt,4,2
	.text
.LC103:
	.string	"SoundBrowser"
.LC104:
	.string	"KitBrowserView"
.LC105:
	.string	"SongBrowserView"
.LC106:
	.string	"NameView"
.LC107:
	.string	"TapTempoView"
.LC108:
	.string	"ProjectManager"
.LC109:
	.string	"SoundManager"
.LC110:
	.string	"SampleManager"
.LC111:
	.string	"SongEditView"
.LC112:
	.string	"SoundSlotListView"
.LC113:
	.string	"SampleListView"
.LC114:
	.string	"TwoColumnMenu"
.LC115:
	.string	"SceneEditView"
.LC116:
	.string	"PerformanceEditView"
	.text
	.align	2
	.type	ov_names, @object
	.size	ov_names, 56
ov_names:
	.long	.LC103
	.long	.LC104
	.long	.LC105
	.long	.LC106
	.long	.LC107
	.long	.LC108
	.long	.LC109
	.long	.LC110
	.long	.LC111
	.long	.LC112
	.long	.LC113
	.long	.LC114
	.long	.LC115
	.long	.LC116
	.align	2
	.type	sv_covers, @object
	.size	sv_covers, 32
sv_covers:
	.long	1075731444
	.long	1075721968
	.long	1075664348
	.long	1075670552
	.long	1075670916
	.long	1075736788
	.long	1076038980
	.long	1075650164
	.section	.bss
	.align	4
	.type	sv, @object
	.size	sv, 116
sv:
	.zero	116
	.local	ls_smpl
	.comm	ls_smpl,4,2
	.align	4
	.type	mr, @object
	.size	mr, 22
mr:
	.zero	22
	.text
	.type	mr_flag, @object
	.size	mr_flag, 18
mr_flag:
	.string	"PX`hpH\b@\177"
	.base64	"ICg4eBh/EDA="
	.type	mr_voice, @object
	.size	mr_voice, 12
mr_voice:
	.base64	"AAIHBwEDBQUEBAYG"
	.local	kq_owes
	.comm	kq_owes,4,2
	.local	kq_owed
	.comm	kq_owed,32,2
	.local	kq_nodown
	.comm	kq_nodown,32,2
	.local	fp
	.comm	fp,24,4
	.local	txsx_test_on
	.comm	txsx_test_on,4,2
	.local	txsx_test_end
	.comm	txsx_test_end,4,2
	.local	txsx_test
	.comm	txsx_test,4,2
	.local	txsx_gap
	.comm	txsx_gap,4,2
	.local	txsx_over
	.comm	txsx_over,4,2
	.local	txsx_on
	.comm	txsx_on,4,2
	.local	txsx_t0
	.comm	txsx_t0,4,2
	.section	.bss
	.align	4
	.type	k44, @object
	.size	k44, 36
k44:
	.zero	36
	.align	4
	.type	dp, @object
	.size	dp, 64
dp:
	.zero	64
	.align	4
	.type	ux, @object
	.size	ux, 3968
ux:
	.zero	3968
	.local	pg_req
	.comm	pg_req,4,1
	.local	pg_gen
	.comm	pg_gen,4,4
	.align	4
	.type	ed, @object
	.size	ed, 392
ed:
	.zero	392
	.align	4
	.type	pin, @object
	.size	pin, 60
pin:
	.zero	60
	.local	sq_req
	.comm	sq_req,7,1
	.local	sq_gen
	.comm	sq_gen,4,4
	.align	4
	.type	sq, @object
	.size	sq, 556
sq:
	.zero	556
	.align	4
	.type	pm, @object
	.size	pm, 32
pm:
	.zero	32
	.align	4
	.type	u46, @object
	.size	u46, 50
u46:
	.zero	50
	.local	nk
	.comm	nk,28,4
	.local	tk
	.comm	tk,16,4
	.local	st
	.comm	st,1096,4
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
	.local	ls_in_gen
	.comm	ls_in_gen,4,4
	.local	ls_in_v
	.comm	ls_in_v,4,2
	.local	pc_req
	.comm	pc_req,6,1
	.local	pc_seq
	.comm	pc_seq,4,4
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
