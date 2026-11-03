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
	moveq #127,%d1
	and.l -2147457096,%d1
	lea (-20,%sp),%sp
	move.l 28(%sp),%d0
	movem.l #1084,(%sp)
	move.w 26(%sp),%d2
	mulu.w #2531,%d1
	mulu.w #152,%d2
	move.l %d1,%a0
	add.l #1092966707,%a0
	mvz.w %d0,%d1
	lea (%a0,%d1.l*2),%a2
	moveq #127,%d1
	and.l -2147457096,%d1
	add.l %d2,%a2
	mulu.w #2531,%d1
	move.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0,%d2.l),%d1
	moveq #45,%d2
	cmp.l %d1,%d2
	jne .L25
	moveq #10,%d4
	cmp.l %d0,%d4
	jeq .L36
	tst.l %d0
	jeq .L27
.L25:
	mov3q.l #7,%d5
	cmp.l %d0,%d5
	jlt .L27
.L26:
	move.l sv+80,%a0
	tst.l %a0
	jeq .L27
	move.l (%a0),%d2
	move.l %d2,%a1
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	move.l 156(%a1),%a0
	jsr (%a0)
	addq.l #8,%sp
	move.l %d0,%d4
	tst.l %d0
	jle .L27
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
	jne .L28
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
	jcs .L28
	move.l %d0,%d4
	mvz.b %d4,%d4
	tst.b %d0
	jeq .L28
	move.l %d2,%d1
	move.l %a0,%d0
	moveq #127,%d2
	and.l %d2,%d0
	mvz.b %d1,%d1
	mov3q.l #1,%d2
	cmp.l %a1,%d2
	jne .L29
	move.l %d0,%d2
	muls.l %d4,%d2
	asr.l #7,%d2
	cmp.l %d1,%d2
	jne .L48
.L30:
	lsl.l #7,%d0
.L50:
	mvz.b 1(%a2),%d1
	lsr.l #1,%d1
	jra .L49
.L36:
	clr.l %d0
	jra .L26
.L29:
	cmp.l %d1,%d0
	jeq .L30
	mov3q.l #3,%d4
	cmp.l %a1,%d4
	jne .L37
	move.l %d3,%d0
	asr.l #1,%d0
	moveq #112,%d5
	and.l %d5,%d0
.L34:
	moveq #127,%d2
	cmp.l %d1,%d2
	jlt .L38
	lsl.l #7,%d1
.L49:
	or.l %d1,%d0
	jra .L24
.L48:
	mvs.w %d1,%d1
	move.l %d4,%a0
	lsl.l #7,%d1
	lea -1(%a0,%d1.l),%a0
	move.l %a0,%d1
	divs.l %d4,%d1
.L37:
	clr.l %d0
	jra .L34
.L38:
	move.w #16256,%d1
	jra .L49
.L28:
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
.L27:
	move.b (%a2),%d0
	lsl.l #7,%d0
	and.l #16256,%d0
	jra .L50
	.size	sv_word, .-sv_word
	.align	2
	.type	splash_end, @function
splash_end:
	tst.l st+972
	jeq .L51
	moveq #1,%d0
	lea (8,%sp),%a0
	move.l (%a0),st+988
	move.l 4(%sp),%a0
	clr.l st+972
	move.b %d0,32(%a0)
.L51:
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
	jne .L54
	move.b %d0,ps_pos
	mvz.b %d2,%d0
	move.b %d2,ps_hdr
	mov3q.l #1,%d3
	move.l %d0,%d1
	lsr.l #4,%d1
	cmp.l %d1,%d3
	jeq .L71
	moveq #11,%d3
	cmp.l %d1,%d3
	jeq .L56
	tst.l %d1
	jne .L72
.L75:
	mov3q.l #1,%d0
	jra .L55
.L56:
	cmp.l #179,%d0
	jhi .L57
.L58:
	mov3q.l #3,%d0
.L55:
	subq.l #1,%d0
	move.b %d0,ps_left
.L59:
	move.b %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L57:
	cmp.l #182,%d0
	jeq .L58
	cmp.l #180,%d0
	jeq .L73
	cmp.l #181,%d0
	jeq .L74
	cmp.l #184,%d0
	jeq .L75
.L72:
	mov3q.l #2,%d0
	jra .L55
.L71:
	moveq #10,%d0
	jra .L55
.L73:
	mov3q.l #6,%d0
	jra .L55
.L74:
	mov3q.l #5,%d0
	jra .L55
.L54:
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
	jcs .L60
	and.l %d3,%d0
	lea shs,%a0
	move.b %d2,(%a0,%d0.l)
	jra .L59
.L60:
	move.l %d0,%a0
	lea (80,%a0),%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #4,%d3
	cmp.l %a0,%d3
	jcs .L59
	mvz.b %d1,%d1
	mov3q.l #1,%d3
	cmp.l %d1,%d3
	jne .L62
	move.b %d2,ps_id
	jra .L59
.L62:
	move.b ps_id,%d3
	move.w %d3,%a0
	mvz.b %d3,%d3
	move.l %d3,%a1
	moveq #55,%d3
	cmp.l %a1,%d3
	jne .L63
	mvz.b %d0,%d3
	cmp.l #180,%d3
	jne .L64
	move.l %d1,%d0
	subq.l #2,%d0
.L65:
	lea sht,%a0
	move.b %d2,(%a0,%d0.l)
	tst.b ovt_on.l
	jeq .L59
	move.b ovt_col,%d2
	addq.l #1,uart_sub
	jra .L59
.L64:
	mov3q.l #3,%d1
	and.l %d1,%d0
	jra .L65
.L63:
	lea (-40,%a0),%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #3,%d3
	cmp.l %a0,%d3
	jcs .L66
	move.w #43,%a0
	mvz.b %d0,%d3
	sub.l %a1,%a0
	cmp.l #180,%d3
	jne .L67
	subq.l #2,%d1
.L68:
	move.l %a0,%d0
	lsl.l #2,%d0
	move.l %d0,%a1
	add.l #shp,%a1
	mvz.b ovp_on,%d0
	move.b %d2,(%a1,%d1.l)
	move.l %a0,%d1
	btst %d1,%d0
	jeq .L59
	addq.l #1,uart_sub
	lea ovp_col,%a1
.L88:
	move.b (%a0,%a1.l),%d2
	jra .L59
.L67:
	mov3q.l #3,%d1
	and.l %d0,%d1
	jra .L68
.L66:
	moveq #15,%d3
	cmp.l %a1,%d3
	jcs .L59
	mvz.b %d0,%d3
	cmp.l #180,%d3
	jne .L69
	subq.l #2,%d1
.L70:
	move.l %a1,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #sh,%a0
	move.b %d2,(%a0,%d1.l)
	tst.b ov_on.l
	jeq .L59
	addq.l #1,uart_sub
	lea ov_col,%a0
	jra .L88
.L69:
	mov3q.l #3,%d1
	and.l %d0,%d1
	jra .L70
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
	jcc .L91
	addq.l #1,sq+384
.L90:
	move.l (%sp)+,%a2
	rts
.L91:
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
	jeq .L93
	move.l %a2,%d0
	addq.l #8,%d0
.L94:
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
	jra .L90
.L93:
	move.l %a2,%d0
	add.l #9,%d0
	move.b 19(%sp),8(%a2)
	jra .L94
	.size	sq_event, .-sq_event
	.align	2
	.type	sq_grid, @function
sq_grid:
	move.l 1100949720,%a0
	move.l %a0,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L98
	tst.b 353(%a0)
	jeq .L98
	tst.b 360(%a0)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L95:
	rts
.L98:
	clr.l %d0
	jra .L95
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
	move.l 4(%sp),%d0
	moveq #41,%d1
	cmp.l %d0,%d1
	jcs .L102
	moveq #39,%d1
	cmp.l %d0,%d1
	jcs .L103
.L104:
	clr.l %d0
	jra .L101
.L102:
	move.l %d0,%d1
	mov3q.l #6,%d0
	add.l #-46,%d1
	cmp.l %d1,%d0
	jcs .L104
	moveq #75,%d0
	lsr.l %d1,%d0
	mov3q.l #1,%d1
	and.l %d1,%d0
.L101:
	rts
.L103:
	tst.l ls_host_presets
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L101
	.size	ls_banked, .-ls_banked
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
	jeq .L108
	tst.l %d0
	jeq .L108
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
.L108:
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
	move.w .L118(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&13
.L118:
	.word .L124-.L118
	.word .L125-.L118
	.word .L125-.L118
	.word .L125-.L118
	.word .L125-.L118
	.word .L125-.L118
	.word .L123-.L118
	.word .L122-.L118
	.word .L121-.L118
	.word .L120-.L118
	.word .L119-.L118
	.word .L125-.L118
	.word .L117-.L118
.L123:
	tst.l %d0
	jeq .L126
	move.l #cu_wtp2k,%d0
.L115:
	move.l (%sp)+,%d2
	rts
.L122:
	tst.l %d0
	jeq .L127
	move.l #cu_grp2k,%d0
	jra .L115
.L117:
	tst.l %d0
	jne .L132
	move.l #cu_srck,%d0
	jra .L115
.L121:
	tst.l %d0
	jeq .L129
	move.l #cu_lip2k,%d0
	jra .L115
.L120:
	tst.l %d0
	jeq .L130
	move.l #cu_cpp2k,%d0
	jra .L115
.L119:
	tst.l %d0
	jeq .L131
	move.l #cu_mip2k,%d0
	jra .L115
.L124:
	tst.l %d0
	jeq .L115
.L132:
	move.l #cu_p2k,%d0
	jra .L115
.L125:
	clr.l %d0
	jra .L115
.L126:
	move.l #cu_wtk,%d0
	jra .L115
.L127:
	move.l #cu_grk,%d0
	jra .L115
.L129:
	move.l #cu_lik,%d0
	jra .L115
.L130:
	move.l #cu_cpk,%d0
	jra .L115
.L131:
	move.l #cu_mik,%d0
	jra .L115
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
.L138:
	mvs.w (%a2)+,%d7
	cmp.l %d7,%d6
	jne .L134
	tst.l %a3
	jeq .L136
	mvz.b 10(%a3,%a0.l),%d1
.L136:
	addq.l #2,%a1
	lea (14,%a0),%a0
	moveq #112,%d7
	cmp.l %a0,%d7
	jne .L138
	cmp.l #441,%d6
	jne .L139
	moveq #12,%d1
.L139:
	move.l %d3,%d0
	moveq #127,%d7
	cmp.l %d3,%d7
	jge .L140
	moveq #127,%d0
.L141:
	addq.l #1,cu+4
	subq.l #1,%d1
	moveq #31,%d7
	cmp.l %d1,%d7
	jcs .L142
	move.w .L144(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&32
.L144:
	.word .L173-.L144
	.word .L172-.L144
	.word .L171-.L144
	.word .L170-.L144
	.word .L169-.L144
	.word .L168-.L144
	.word .L167-.L144
	.word .L166-.L144
	.word .L163-.L144
	.word .L165-.L144
	.word .L164-.L144
	.word .L163-.L144
	.word .L162-.L144
	.word .L161-.L144
	.word .L160-.L144
	.word .L159-.L144
	.word .L158-.L144
	.word .L157-.L144
	.word .L156-.L144
	.word .L155-.L144
	.word .L142-.L144
	.word .L154-.L144
	.word .L153-.L144
	.word .L152-.L144
	.word .L151-.L144
	.word .L150-.L144
	.word .L149-.L144
	.word .L148-.L144
	.word .L147-.L144
	.word .L146-.L144
	.word .L145-.L144
	.word .L143-.L144
.L134:
	mvs.w (%a1),%d7
	cmp.l %d7,%d6
	jne .L136
	tst.l %d0
	jeq .L136
	mvz.b 10(%a0,%d0.l),%d1
	jra .L136
.L140:
	tst.l %d3
	jge .L141
	clr.l %d0
	jra .L141
.L173:
	moveq #63,%d0
	cmp.l %d3,%d0
	jge .L190
	move.l #cu_loop+10,%d0
.L222:
	move.l %d0,44(%sp)
	move.l #cu_fmt_s,%d1
.L213:
	move.l %d1,40(%sp)
	jra .L209
.L190:
	move.l #cu_loop+5,%d0
	jra .L222
.L172:
	muls.w #3,%d0
	asr.l #7,%d0
	mulu.w #5,%d0
	add.l #cu_loop,%d0
.L220:
	move.l %d0,44(%sp)
	move.l #cu_fmt_s,%d3
	jra .L215
.L171:
	moveq #15,%d5
	cmp.l %d3,%d5
	jge .L175
	clr.l %d0
.L175:
	mulu.w #5,%d0
	add.l #cu_chd,%d0
.L226:
	move.l %d0,44(%sp)
	move.l #cu_fmt_s,%d7
	jra .L214
.L170:
	mov3q.l #3,%d1
	cmp.l %d3,%d1
	jge .L176
	clr.l %d0
.L176:
	move.l %d0,44(%sp)
	move.l #cu_fmt_inv,%d3
.L215:
	move.l %d3,40(%sp)
.L209:
	move.l %d2,36(%sp)
	movem.l (%sp),#3324
	lea (32,%sp),%sp
	jmp 1074365954
.L169:
	mov3q.l #2,%d5
	cmp.l %d3,%d5
	jge .L177
	clr.l %d0
.L177:
	move.l %d0,44(%sp)
	move.l #cu_fmt_spr,%d7
.L214:
	move.l %d7,40(%sp)
	jra .L209
.L168:
	move.l %d0,%d1
	mov3q.l #5,%d3
	subq.l #1,%d1
	cmp.l %d1,%d3
	jcs .L178
.L225:
	move.l %d0,44(%sp)
	move.l #cu_fmt_d,%d5
	jra .L216
.L178:
	move.l #cu_loop,%d7
	move.l %d7,44(%sp)
.L223:
	lea cu_fmt_s,%a0
.L217:
	move.l %a0,40(%sp)
	jra .L209
.L167:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_warp,%d0
.L211:
	move.l %d0,44(%sp)
	jra .L212
.L166:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #6,%d0
	add.l #cu_win,%d0
	jra .L222
.L165:
	moveq #119,%d5
	cmp.l %d3,%d5
	jlt .L179
	muls.w #99,%d0
	divs.l %d5,%d0
.L218:
	move.l %d0,44(%sp)
	move.l #cu_fmt_d,%d7
	jra .L214
.L179:
	lea cu_frz,%a0
	move.l %a0,44(%sp)
.L212:
	move.l #cu_fmt_s,%d0
.L210:
	move.l %d0,40(%sp)
	jra .L209
.L164:
	tst.l %d3
	jle .L180
	asr.l #4,%d0
	mulu.w #5,%d0
	add.l #cu_anim,%d0
	jra .L222
.L180:
	move.l #cu_off,%d3
.L219:
	move.l %d3,44(%sp)
	move.l #cu_fmt_s,%d5
	jra .L216
.L162:
	mvs.w %d0,%d0
	lsr.l #3,%d0
	and.l #262140,%d0
	add.l #cu_inpt,%d0
	jra .L226
.L161:
	mvs.w %d0,%d0
	asr.l #6,%d0
	mulu.w #5,%d0
	add.l #cu_mon,%d0
.L224:
	move.l %d0,44(%sp)
	jra .L223
.L160:
	tst.l %d3
	jle .L180
	muls.w #60,%d0
	moveq #126,%d3
	move.l #cu_fmt_db,%d5
	addq.l #3,%d0
	divs.l %d3,%d0
	add.l #-80,%d0
	move.l %d0,44(%sp)
.L216:
	move.l %d5,40(%sp)
	jra .L209
.L159:
	asr.l #1,%d0
	addq.l #1,%d0
	jra .L218
.L158:
	moveq #63,%d1
	cmp.l %d3,%d1
	jge .L181
	muls.w #48,%d0
	moveq #126,%d3
	add.l #-3009,%d0
	divs.l %d3,%d0
	tst.l %d0
	jeq .L195
.L221:
	move.l #cu_fmt_pd,%d1
.L184:
	move.l %d0,44(%sp)
	jra .L213
.L181:
	moveq #64,%d1
	moveq #-126,%d5
	sub.l %d0,%d1
	muls.w #48,%d1
	move.l %d1,%d0
	add.l #63,%d0
	divs.l %d5,%d0
.L195:
	move.l #cu_fmt_d,%d1
	jra .L184
.L157:
	muls.w #100,%d0
	moveq #127,%d7
	lea cu_fmt_pct,%a0
	add.l #63,%d0
	divs.l %d7,%d0
	move.l %d0,44(%sp)
	jra .L217
.L156:
	tst.l %d3
	jle .L180
.L142:
	move.l %d0,44(%sp)
	move.l #cu_fmt_d,%d0
	jra .L210
.L155:
	mvs.w %d0,%d0
	asr.l #3,%d0
	jeq .L183
	addq.l #1,%d0
	move.l %d0,44(%sp)
	move.l #cu_fmt_x,%d1
	jra .L213
.L154:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_tape,%d0
	jra .L226
.L153:
	muls.w #3,%d0
	lsr.l #5,%d0
	and.l #262140,%d0
	add.l #cu_dir,%d0
	jra .L224
.L152:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_cloop,%d0
	jra .L211
.L151:
	tst.l %d3
	jle .L183
	move.l %d0,44(%sp)
	move.l #cu_fmt_d,%d1
	jra .L213
.L149:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_dst,%d0
	jra .L220
.L148:
	mvs.w %d0,%d0
	asr.l #3,%d0
	addq.l #1,%d0
	jra .L225
.L147:
	tst.l %d3
	jle .L180
	add.l #-64,%d0
	moveq #64,%d7
	cmp.l %d3,%d7
	jge .L195
	jra .L221
.L146:
	tst.l %d3
	jle .L180
	subq.l #1,%d0
	move.l %d0,44(%sp)
	lea cu_fmt_d,%a0
	jra .L217
.L145:
	tst.l %d3
	jle .L180
	subq.l #1,%d0
	muls.w #127,%d0
	moveq #126,%d3
	divs.l %d3,%d0
	jra .L225
.L143:
	tst.l %d3
	jle .L180
	subq.l #1,%d0
	jra .L218
.L150:
	moveq #126,%d1
	cmp.l %d3,%d1
	jge .L185
	move.l #cu_hold,%d3
	jra .L219
.L185:
	tst.l %d3
	jgt .L218
.L183:
	move.l #cu_slc,%d3
	jra .L219
.L163:
	cmp.l #441,%d6
	jeq .L196
	add.l #-46,%d5
	mvz.b %d5,%d5
	mov3q.l #6,%d1
	cmp.l %d5,%d1
	jcs .L197
	lea CSWTCH.502,%a0
	mvs.b (%a0,%d5.l),%d1
.L186:
	tst.l %d3
	jle .L180
	asr.l #5,%d4
	mov3q.l #7,%d3
	mov3q.l #-1,%d5
	and.l %d3,%d4
	cmp.l %d1,%d5
	jeq .L187
	lea ux,%a1
	lea (%a1,%d1.l),%a0
	mvz.b 3948(%a0),%d3
	cmp.l %d3,%d4
	jne .L187
	mvz.w #1280,%d3
	moveq #10,%d7
	muls.l %d0,%d7
	muls.l %d1,%d3
	move.l %d7,%a0
	add.l %d3,%a0
	tst.b 40(%a1,%a0.l)
	jeq .L187
	mulu.w #10,%d0
	mulu.w #1280,%d1
	move.l %d0,%a0
	lea 40(%a0,%d1.l),%a0
	move.l %a0,%d0
	add.l %a1,%d0
	jra .L211
.L196:
	clr.l %d1
	jra .L186
.L197:
	mov3q.l #-1,%d1
	jra .L186
.L187:
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
.L228:
	lea (%a2,%d0.l),%a4
	moveq #84,%d2
	move.l %d1,%a3
	move.l (%a4),(%a3,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d2
	jne .L228
	tst.b 10(%a1)
	jeq .L229
	lea cu_text,%a2
	move.l %a2,32(%a3)
.L229:
	move.w 12(%a1),%d0
	move.l (%a1),40(%a0)
	move.l 4(%a1),48(%a0)
	clr.l 8(%a0)
	move.l 28(%sp),44(%a0)
	move.l %d0,%d1
	and.l #2048,%d1
	btst #11,%d0
	jeq .L232
	mvz.w #32736,%d0
.L230:
	move.l %d0,12(%a0)
	mvz.b 11(%a1),%d0
	lsl.l #8,%d0
	move.l %d0,16(%a0)
	tst.w %d1
	jeq .L227
	mov3q.l #1,20(%a0)
.L227:
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	rts
.L232:
	mvz.w #32512,%d0
	jra .L230
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
	jeq .L237
	moveq #40,%d1
	cmp.l %d3,%d1
	jeq .L237
	move.l #1094564988,%a0
.L239:
	move.l (%a0),%d1
	addq.l #4,%a0
	move.l %d1,-68(%a0)
	move.l %d1,-100(%a0)
	move.l %d1,-132(%a0)
	move.l %d1,-164(%a0)
	move.l %d1,-196(%a0)
	cmp.l #1094565020,%a0
	jne .L239
	mvz.b cu+8,%d1
	cmp.l %d1,%d3
	jeq .L240
.L242:
	move.l %d3,%d5
	move.l %d0,%d6
	add.l #-46,%d5
	lea cu_src,%a2
	add.l #112,%d6
	move.l %d0,%d2
	move.l #1075575064,%a3
	lea CSWTCH.500,%a5
	lea cu_knob,%a4
.L241:
	mov3q.l #6,%d0
	cmp.l %d5,%d0
	jcs .L244
	move.l (%a5,%d5.l*4),%d0
.L243:
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
	jne .L241
	move.b %d3,cu+8
	jra .L237
.L240:
	move.l 1075595808,%d1
	move.l %d0,%a0
	cmp.l 4(%a0),%d1
	jne .L242
	move.l 1075596276,%d1
	cmp.l 102(%a0),%d1
	jne .L242
	cmp.l 1075595760.l,%d3
	jne .L242
.L237:
	movem.l (%sp),#15484
	lea (36,%sp),%sp
	rts
.L244:
	move.l #cu_fm_short,%d0
	jra .L243
	.size	cu_src_setup, .-cu_src_setup
	.align	2
	.globl	cu_steps
	.type	cu_steps, @function
cu_steps:
	lea (-12,%sp),%sp
	moveq #-12,%d1
	movem.l #28,(%sp)
	move.l 16(%sp),%d2
	move.b 1093765506,%d0
	cmp.l %d2,%d1
	jle .L254
	moveq #127,%d0
	moveq #-13,%d1
	and.l -2147457096,%d0
	sub.l %d2,%d1
	moveq #-24,%d4
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l #1092966773,%a0
	mvz.w #152,%d0
	muls.l %d1,%d0
	move.b (%a0,%d0.l),%d3
	cmp.l %d2,%d4
	jgt .L255
	mvz.b %d3,%d0
	mov3q.l #2,%d2
	add.l #-48,%d0
	cmp.l %d0,%d2
	jcs .L255
	move.b %d3,cu+9
	move.b %d1,cu+10
	lea st+8,%a0
	move.l (%a0),cu+16
.L255:
	clr.l %d0
.L253:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L254:
	tst.l %d2
	jge .L257
	mvz.b cu+9,%d0
	moveq #50,%d1
	cmp.l %d0,%d1
	jne .L258
	mvz.b cu+10,%d1
	move.l %d2,%d0
	not.l %d0
	cmp.l %d1,%d0
	jeq .L267
.L258:
	mvz.b cu+11,%d0
	neg.l %d2
	cmp.l %d0,%d2
	jne .L255
	move.l st+8,%d0
	mov3q.l #3,%d2
	sub.l cu+24,%d0
	cmp.l %d0,%d2
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L253
.L257:
	cmp.l #441,%d2
	jeq .L268
	lea cu_src,%a0
	clr.l %d3
.L260:
	mvs.w (%a0),%d1
	cmp.l %d1,%d2
	jne .L259
	mvz.b cu+8,%d0
	clr.l -(%sp)
	move.l %d0,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L255
	mulu.w #14,%d3
	move.l %d0,%a0
	mvz.w 12(%a0,%d3.l),%d0
	jra .L253
.L259:
	addq.l #2,%a0
	addq.l #1,%d3
	moveq #8,%d1
	cmp.l %d3,%d1
	jne .L260
	mvz.b %d0,%d0
	moveq #11,%d4
	cmp.l %d0,%d4
	jge .L261
	clr.l %d0
.L261:
	moveq #127,%d1
	and.l -2147457096,%d1
	mulu.w #152,%d0
	mulu.w #2531,%d1
	move.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0,%d0.l),%d3
	mvz.b cu+1,%d0
	cmp.l %d3,%d0
	jne .L255
	mov3q.l #1,-(%sp)
	move.l %d3,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L255
	move.l 1075596172,%d1
	move.l %d0,%a0
	cmp.l 102(%a0),%d1
	jne .L255
	lea cu_p2,%a0
	clr.l %d1
.L262:
	mvs.w (%a0),%d4
	cmp.l %d4,%d2
	jne .L263
	moveq #40,%d2
	cmp.l %d3,%d2
	jne .L266
	mov3q.l #3,%d2
	cmp.l %d1,%d2
	jge .L255
.L266:
	mulu.w #14,%d1
	move.l %d0,%a0
	mvz.w 12(%a0,%d1.l),%d0
	jra .L253
.L263:
	addq.l #2,%a0
	addq.l #1,%d1
	moveq #8,%d4
	cmp.l %d1,%d4
	jne .L262
	jra .L255
.L267:
	mov3q.l #1,%d0
	jra .L253
.L268:
	mvz.w #2944,%d0
	jra .L253
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
.L283:
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr (%a2)
	addq.l #1,%a6
	addq.l #4,%d2
	addq.l #8,%sp
	moveq #16,%d0
	cmp.l %a6,%d0
	jne .L283
	move.l %sp,%d2
	sub.l %a6,%a6
	lea shs,%a3
	add.l #22,%d2
	lea rui_uart_raw,%a2
.L285:
	move.b (%a3,%a6.l),%d0
	mvz.b %d0,%d1
	cmp.l #255,%d1
	jeq .L284
	move.l %a6,%d1
	moveq #32,%d3
	or.l %d3,%d1
	move.b %d0,23(%sp)
	move.b %d1,22(%sp)
	move.l %d2,-(%sp)
	mov3q.l #2,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
.L284:
	addq.l #1,%a6
	mov3q.l #4,%d0
	cmp.l %a6,%d0
	jne .L285
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
	jne .L292
	lea txsx_wait,%a2
	jsr (%a2)
	move.l %d0,%d2
	tst.l %d0
	jeq .L293
	addq.l #1,st+40
.L292:
	clr.l %d2
.L291:
	move.l %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L293:
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L295
	addq.l #1,st+40
	jra .L291
.L295:
	jsr (%a2)
	tst.l %d0
	jne .L296
	mvz.w #4027,%d0
	cmp.l 1094562392.l,%d0
	jlt .L296
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L297:
	tst.l %a0
	jeq .L296
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L297
	move.l 12(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	mov3q.l #1,%d2
	addq.l #1,st+36
	jra .L291
.L296:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #1,st+40
	addq.l #4,%sp
	jra .L291
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
.L306:
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
	jgt .L306
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
	jne .L309
	mvz.b mr+18,%d0
	cmp.l -12(%fp),%d0
	jeq .L308
.L309:
	pea 8.w
	pea -8(%fp)
	move.b -9(%fp),-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L308
	clr.b %d0
	lea (-9,%fp),%a0
	move.b (%a0),mr+18
	move.b %d0,mr+19
	move.w mr+20,%d0
	addq.l #1,%d0
	move.w %d0,mr+20
.L308:
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
.L316:
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
	jeq .L315
	addq.l #1,%d1
.L315:
	lea (152,%a1),%a1
	cmp.l #1824,%a1
	jne .L316
	tst.b mr+12.l
	jne .L317
	sub.l %a0,%a0
.L318:
	lea (%a2,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a3,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L318
	moveq #127,%d0
	and.l -2147457096,%d0
	move.b %d0,mr+18
	moveq #1,%d0
	move.b %d0,mr+12
.L319:
	mov3q.l #1,%a6
	jra .L314
.L317:
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L320
	move.b %d0,mr+13
.L321:
	move.l %a2,-(%sp)
	pea 12.w
	clr.l -(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L314
	sub.l %a0,%a0
.L324:
	lea (%a2,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a3,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L324
	clr.b %d0
	move.b %d0,mr+13
	move.w mr+16,%d0
	addq.l #1,%d0
	move.w %d0,mr+16
	jsr kit_tick
.L314:
	move.l %a6,%d0
	movem.l (%sp),#23556
	lea (32,%sp),%sp
	rts
.L320:
	clr.l %d2
	tst.b mr+13.l
	jne .L321
.L322:
	mvz.b (%a3,%d2.l),%d0
	mvz.b (%a2)+,%d1
	cmp.l %d1,%d0
	jeq .L326
	pea 20(%sp)
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L314
	lea (-1,%a2),%a0
	move.b (%a0),(%a3,%d2.l)
	move.w mr+14,%d0
	addq.l #1,%d0
	move.w %d0,mr+14
.L326:
	addq.l #1,%d2
	moveq #12,%d0
	cmp.l %d2,%d0
	jne .L322
	jsr kit_tick
	jra .L319
	.size	mr_tick, .-mr_tick
	.align	2
	.type	arp_tick, @function
arp_tick:
	lea (-56,%sp),%sp
	movem.l #31996,(%sp)
	lea ar,%a2
	clr.l %d5
	move.l %sp,%d2
	move.l #1081497995,%d4
	sub.l %a6,%a6
	move.l %a2,%a5
	add.l #46,%d2
.L345:
	moveq #127,%d0
	and.l -2147457096,%d0
	move.l %a6,%d1
	add.l #12,%d1
	move.w (%a5,%d1.l*2),%a1
	mulu.w #2531,%d0
	move.w %a1,%d6
	move.l %d0,%a0
	add.l #1092966778,%a0
	mvz.w %a1,%d0
	add.l %d5,%a0
	tst.w %d6
	jeq .L340
	clr.w %d7
	lea ar+48,%a3
	move.w %d7,(%a5,%d1.l*2)
	moveq #127,%d1
	and.l -2147457096,%d1
	mvz.b (%a3,%a6.l),%d6
	cmp.l %d6,%d1
	jne .L340
	move.w %a1,%d1
	lsr.l #8,%d0
	moveq #63,%d6
	mov3q.l #3,%d7
	move.l %d4,%a3
	move.b %d1,(%a0)
	move.b 1(%a0),%d1
	and.l %d6,%d1
	move.l %d0,%d6
	lsl.l #6,%d6
	and.l %d7,%d0
	or.l %d6,%d1
	move.b %d1,1(%a0)
	move.b %d0,(%a3)+
	move.w %a1,%d0
	move.b %d0,(%a3)
	addq.l #1,ar+66
.L340:
	move.b 1(%a0),%d6
	move.b (%a0),%d0
	lsl.l #2,%d6
	mvz.b %d0,%d1
	and.l #768,%d6
	or.l %d1,%d6
	mvz.w (%a2),%d1
	cmp.l %d1,%d6
	jne .L341
	mvz.w ar+60,%d1
	move.l %a6,%d7
	btst %d7,%d1
	jeq .L342
.L341:
	move.w #17665,%d1
	move.w %a6,%d7
	move.l #-260222380,%a3
	move.l %a3,46(%sp)
	move.w %d1,50(%sp)
	moveq #127,%d1
	and.l %d1,%d0
	move.b %d7,52(%sp)
	moveq #-9,%d7
	move.b %d0,53(%sp)
	move.l %d6,%d0
	lsr.l #7,%d0
	move.b %d7,55(%sp)
	move.b %d0,54(%sp)
	pea 10.w
	move.l %d2,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L339
	move.w %d6,(%a2)
	move.l %a6,%d1
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	addq.l #1,ar+62
	move.w ar+60,%d1
	not.l %d0
	and.l %d1,%d0
	move.w %d0,ar+60
.L342:
	addq.l #1,%a6
	add.l #152,%d5
	addq.l #2,%a2
	add.l #162,%d4
	moveq #12,%d6
	cmp.l %a6,%d6
	jne .L345
.L339:
	movem.l (%sp),#31996
	lea (56,%sp),%sp
	rts
	.size	arp_tick, .-arp_tick
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
.L354:
	lea (%a1,%d0.l),%a2
	move.b (%a2),-9(%fp,%d0.l)
	move.l %d0,%a0
	addq.l #1,%d0
	cmp.l 16(%fp),%d0
	jne .L354
	moveq #-9,%d0
	move.b %d0,-8(%fp,%a0.l)
	pea 9(%a0)
	pea -16(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L353
	addq.l #1,sq+456
.L353:
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
.L364:
	moveq #15,%d3
	cmp.l %d0,%d3
	jcs .L379
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
	jeq .L365
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
.L365:
	addq.l #1,%d1
	cmp.l #256,%d1
	jne .L364
.L379:
	tst.b %d2
	jeq .L363
	move.l %a0,kq_owes
	move.l %d0,st+196
.L363:
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
	jeq .L381
	move.l st+8,%d0
	cmp.l #16383,%d0
	jls .L382
	mvz.w #16383,%d0
.L382:
	moveq #127,%d1
	and.l %d0,%d1
	lsr.l #7,%d0
	pea 15.w
	mvz.b %d0,%d0
	move.l %d1,-(%sp)
	move.l %d0,-(%sp)
	pea 53.w
	jsr send3
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L380
	clr.b %d0
	addq.l #1,st+968
	move.b %d0,st+992
.L381:
	tst.b st+161.l
	jeq .L384
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
	jeq .L380
	clr.b %d1
	move.b %d1,st+161
.L384:
	lea ls+4,%a0
	clr.l %d2
	move.l %fp,%d3
	move.l #-260222380,%a3
	lea ls,%a2
	add.l #-12,%d3
	move.l %a0,-16(%fp)
.L386:
	cmp.l ls+24.l,%d2
	jcs .L389
.L388:
	move.w %d2,%d0
	move.l ls+24,%d1
	move.l %d1,-16(%fp)
	mulu.w #5,%d0
	lea (%a2,%d0.l),%a0
	move.l %d2,%d0
.L390:
	cmp.l -16(%fp),%d0
	jcs .L391
	move.l -16(%fp),%d1
	sub.l %d2,%d1
	move.l %d1,-16(%fp)
	move.l %d1,ls+24
	tst.l %d1
	jne .L380
	lea st+164,%a2
	move.l %a2,%a4
.L392:
	move.l -16(%fp),%a0
	cmp.l st+196.l,%a0
	jcc .L396
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
	jne .L393
.L396:
	move.l st+196,%d0
	move.l -16(%fp),%d1
.L394:
	cmp.l %d0,%d1
	jcs .L397
	sub.l -16(%fp),%d0
	move.l %d0,st+196
	tst.l %d0
	jne .L380
	move.l kq_owes,%d2
	tst.l %d2
	jeq .L398
	movem.l -36(%fp),#7180
	unlk %fp
	jra (kq_owed_in.part.0)
.L389:
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
	jeq .L388
	addq.l #5,-16(%fp)
	addq.l #1,%d2
	jra .L386
.L391:
	addq.l #5,%a0
	addq.l #5,%a2
	move.b -1(%a0),-1(%a2)
	addq.l #1,%d0
	move.b (%a0),(%a2)
	move.b 1(%a0),1(%a2)
	move.b 2(%a0),2(%a2)
	move.b 3(%a0),3(%a2)
	jra .L390
.L393:
	addq.l #2,%a4
	addq.l #1,-16(%fp)
	jra .L392
.L397:
	move.l -16(%fp),%a1
	addq.l #1,%d1
	move.b (%a2,%a1.l*2),(%a2)
	lea 1(%a2,%a1.l*2),%a0
	addq.l #2,%a2
	move.b (%a0),-1(%a2)
	jra .L394
.L398:
	lea st+96,%a2
.L403:
	move.l (%a2)+,-16(%fp)
	tst.l -16(%fp)
	jeq .L399
	moveq #-63,%d0
	cmp.l -16(%fp),%d0
	jle .L400
	moveq #-63,%d1
.L420:
	move.l %d1,-16(%fp)
.L401:
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
	jeq .L380
	move.l -16(%fp),%d1
	sub.l %d1,-4(%a2)
	move.l st+64,%d1
	tst.l %d1
	jeq .L399
	move.l -66650100,%d0
	sub.l %d1,%d0
	move.l %d0,st+68
	add.l %d0,st+316
	addq.l #1,st+320
	cmp.l st+324.l,%d0
	jls .L402
	move.l %d0,st+324
.L402:
	clr.l st+64
.L399:
	addq.l #1,%d2
	moveq #16,%d0
	cmp.l %d2,%d0
	jne .L403
.L380:
	movem.l -36(%fp),#7180
	unlk %fp
	rts
.L400:
	moveq #63,%d0
	cmp.l -16(%fp),%d0
	jge .L401
	moveq #63,%d1
	jra .L420
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
	jeq .L421
	move.l ed+64,%d0
	move.l %d0,%a0
	mov3q.l #7,%d2
	sub.l ed+68,%a0
	cmp.l %a0,%d2
	jcc .L423
	addq.l #1,ed+72
.L421:
	move.l (%sp)+,%d2
	rts
.L423:
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
	jcc .L424
	lea (-16,%a1),%a1
	mov3q.l #1,%d2
	cmp.l %a1,%d2
	jcc .L424
	mvz.b 1093765506,%d0
	moveq #11,%d2
	cmp.l %d0,%d2
	jcc .L425
.L424:
	moveq #127,%d0
.L426:
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
	jra .L421
.L425:
	move.b 1093765506,%d0
	jra .L426
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
	jcc .L431
	addq.l #1,ls+92
.L430:
	move.l (%sp)+,%a2
	move.l (%sp)+,%a3
	rts
.L431:
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
	jra .L430
	.size	ls_queue, .-ls_queue
	.align	2
	.type	ls_close, @function
ls_close:
	lea ls,%a0
	tst.b ls.l
	jeq .L433
	clr.b %d0
	clr.l ls+36
	addq.l #1,ls+80
	clr.l st+96
	move.b %d0,ls
	mvz.b 7(%sp),%d0
	addq.l #1,100(%a0,%d0.l*4)
	move.l %d0,-(%sp)
	clr.l -(%sp)
	jsr ls_queue
	addq.l #8,%sp
.L433:
	rts
	.size	ls_close, .-ls_close
	.align	2
	.type	ls_enc, @function
ls_enc:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.b ls,%d2
	move.l 16(%sp),%d0
	tst.b %d2
	jeq .L436
	mvz.b ls+125,%d1
	cmp.l %d1,%d0
	jeq .L436
	mov3q.l #3,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L438:
	clr.l %d0
.L435:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L436:
	or.l st+972,%d0
	jne .L438
	tst.b %d2
	jne .L439
	tst.b sv.l
	jeq .L438
	tst.b sv+8.l
	jeq .L438
	move.b sv+2,%d4
	mvz.b %d4,%d3
	move.l %d3,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L440
	moveq #45,%d1
	cmp.l %d3,%d1
	jne .L435
.L440:
	lea sv+1,%a0
	moveq #45,%d0
	move.b (%a0),ls+1
	move.b %d4,ls+2
	cmp.l %d3,%d0
	jne .L441
	moveq #10,%d2
.L441:
	moveq #1,%d1
	clr.b %d0
	lea st+8,%a0
	move.l (%a0),ls+126
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.b %d2,ls+124
	move.b %d1,ls
	move.b %d0,ls+125
	addq.l #1,ls+76
	jsr ls_queue
	jsr flush
	addq.l #8,%sp
.L442:
	mov3q.l #1,%d0
	jra .L435
.L439:
	move.l 20(%sp),%d0
	addq.l #1,ls+84
	add.l %d0,st+96
	jsr flush
	jra .L442
	.size	ls_enc, .-ls_enc
	.align	2
	.type	pj_push, @function
pj_push:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.l 20(%sp),%d1
	move.l 24(%sp),%a1
#APP
| 4298 "rui.c" 1
	tas pj+136
	smi %d2
| 0 "" 2
#NO_APP
	tst.b %d2
	jeq .L447
	addq.l #1,pj+156
.L446:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L447:
	move.l pj,%d3
	move.l %d3,%d0
	sub.l pj+4,%d0
	lsr.l #5,%d0
	jeq .L449
	addq.l #1,pj+156
.L450:
	clr.b %d0
	move.b %d0,pj+136
	jra .L446
.L449:
	moveq #31,%d0
	and.l %d3,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #pj+8,%a0
	move.b 19(%sp),(%a0)
	moveq #127,%d0
	cmp.l %d1,%d0
	jcs .L453
	move.l %d1,%d0
	addq.l #1,%d0
.L451:
	move.b %d0,1(%a0)
	moveq #127,%d4
	cmp.l %a1,%d4
	jcs .L452
	move.l %a1,%d2
	addq.l #1,%d2
.L452:
	move.b %d2,2(%a0)
	addq.l #1,%d3
	move.l %d3,pj
	jra .L450
.L453:
	clr.b %d0
	jra .L451
	.size	pj_push, .-pj_push
	.align	2
	.type	led_restore, @function
led_restore:
	tst.b ov_on.l
	jeq .L454
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L456
	addq.l #1,st+1018
.L454:
	rts
.L456:
	clr.b %d0
	move.b %d0,ov_on
	jsr led_stock
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #4,%sp
	move.l st+8,%d0
	addq.l #4,%d0
	tst.l %d0
	jne .L457
	mov3q.l #1,%d0
.L457:
	move.l %d0,led_again
	addq.l #1,st+1014
	jra .L454
	.size	led_restore, .-led_restore
	.align	2
	.globl	rui_sysex
	.type	rui_sysex, @function
rui_sysex:
	link.w %fp,#-76
	move.l -66650100,%d1
	move.l 12(%fp),%d0
	movem.l #3324,(%sp)
	move.l %d1,-36(%fp)
	move.l 8(%fp),%a0
	mov3q.l #6,%d2
	cmp.l %d0,%d2
	jge .L465
	mvz.b 5(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L465
	mvz.b -1(%a0,%d0.l),%d1
	cmp.l #247,%d1
	jeq .L463
.L465:
	addq.l #1,rx_bad
	jra .L464
.L463:
	move.b 4(%a0),%d2
	move.l %d0,%d1
	moveq #39,%d4
	subq.l #7,%d1
	move.l %d2,%d3
	add.l #-40,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d4
	jcs .L465
	move.w .L467(%pc,%d3.l*2),%a1
	jmp %pc@(2,%a1:l)
	.balignw 2,0x284c
	.swbeg	&40
.L467:
	.word .L485-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L484-.L467
	.word .L483-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L482-.L467
	.word .L465-.L467
	.word .L481-.L467
	.word .L480-.L467
	.word .L479-.L467
	.word .L478-.L467
	.word .L477-.L467
	.word .L465-.L467
	.word .L476-.L467
	.word .L475-.L467
	.word .L474-.L467
	.word .L473-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L472-.L467
	.word .L471-.L467
	.word .L470-.L467
	.word .L469-.L467
	.word .L465-.L467
	.word .L468-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L465-.L467
	.word .L466-.L467
.L479:
	mov3q.l #4,%d5
	cmp.l %d1,%d5
	jge .L559
	move.b 7(%a0),%d6
	moveq #15,%d7
	mvz.b %d6,%d3
	move.b %d6,-40(%fp)
	cmp.l %d3,%d7
	jcs .L559
	mvz.b 8(%a0),%d5
	mov3q.l #7,%d1
	cmp.l %d5,%d1
	jcs .L559
	move.b 9(%a0),%d1
	jeq .L559
	move.b 10(%a0),%d2
	jeq .L559
	mvz.b %d1,%d4
	add.l %d4,%d3
	moveq #16,%d4
	cmp.l %d3,%d4
	jlt .L559
	mvz.b %d2,%d3
	move.l %d5,%d4
	moveq #8,%d6
	add.l %d3,%d4
	cmp.l %d4,%d6
	jlt .L559
	ext.w %d2
	ext.w %d1
	mov3q.l #7,%d7
	add.l #-12,%d0
	muls.w %d2,%d1
	lsl.l #3,%d1
	move.l %d1,%d2
	addq.l #6,%d2
	divs.l %d7,%d2
	add.l %d1,%d2
	cmp.l %d0,%d2
	jne .L559
	mvs.b -40(%fp),%d0
	lea (11,%a0),%a3
	lsl.l #6,%d0
	move.l %d0,%a1
	add.l %d5,%a1
	add.l #staging,%a1
	clr.l %d0
.L490:
	move.l %d1,%d2
	mov3q.l #7,%d4
	cmp.l %d1,%d4
	jge .L487
	mov3q.l #7,%d2
.L487:
	move.l %a3,%a2
	sub.l %d2,%d1
	mvz.b (%a2)+,%d4
	move.l %a3,-44(%fp)
	addq.l #1,-44(%fp)
	sub.l %a2,%a2
.L489:
	move.l %d4,%d5
	lsr.l #1,%d4
	move.b 1(%a3,%a2.l),%d6
	lsl.l #7,%d5
	or.l %d6,%d5
	move.b %d5,(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d3,%d0
	jne .L488
	addq.l #8,%a1
	clr.l %d0
.L488:
	addq.l #1,%a2
	cmp.l %d2,%a2
	jne .L489
	move.l -44(%fp),%a3
	add.l %d2,%a3
	tst.l %d1
	jgt .L490
	moveq #1,%d7
	addq.l #6,%a0
	move.b (%a0),st_seq
	move.b %d7,st_valid
.L476:
	addq.l #1,rx
	jra .L464
.L478:
	tst.l %d1
	jeq .L465
	tst.b st_valid.l
	jeq .L492
	mvz.b 6(%a0),%d1
	mvz.b st_seq,%d0
	cmp.l %d1,%d0
	jne .L492
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
.L492:
	clr.b %d0
	move.b %d0,st_valid
	jra .L476
.L477:
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jge .L465
	tst.b 7(%a0)
	jeq .L494
	moveq #1,%d3
	move.b %d3,host_open
	jra .L476
.L494:
	moveq #1,%d4
	move.b %d4,host_close
	jra .L476
.L468:
	subq.l #2,%d1
	tst.l %d1
	jne .L465
	mvz.b 6(%a0),%d0
	moveq #127,%d6
	cmp.l %d0,%d6
	jne .L496
	mvz.b 7(%a0),%d0
	mov3q.l #1,%d7
	cmp.l %d0,%d7
	jcs .L465
	move.l %d0,ls_host_presets
	jra .L476
.L496:
	moveq #11,%d1
	cmp.l %d0,%d1
	jcs .L465
	mvz.b 7(%a0),%d0
	lsr.l #1,%d0
	jne .L465
	mvz.w 6(%a0),%d0
	move.l %d0,ls_in_v
	addq.l #1,ls_in_gen
	jra .L476
.L485:
	subq.l #6,%d1
	tst.l %d1
	jne .L465
	move.l %a0,%d0
	add.l #12,%d0
	lea (6,%a0),%a1
.L500:
	tst.b (%a1)
	jlt .L465
	addq.l #1,%a1
	cmp.l %a1,%d0
	jne .L500
	addq.l #1,pc_seq
	clr.l %d0
	lea pc_req,%a1
.L501:
	lea 6(%a0,%d0.l),%a2
	mov3q.l #6,%d1
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L501
	addq.l #1,pc_seq
	jra .L476
.L482:
	tst.l %d1
	jeq .L465
	move.b 6(%a0),%d0
	mov3q.l #1,%d3
	mvz.b %d0,%d2
	cmp.l %d2,%d3
	jcs .L465
	jne .L503
	moveq #17,%d4
	cmp.l %d1,%d4
	jne .L465
	move.l %a0,%d1
	add.l #23,%d1
	lea (7,%a0),%a1
.L506:
	mvz.b (%a1),%d2
	moveq #111,%d5
	cmp.l %d2,%d5
	jcs .L465
	addq.l #1,%a1
	cmp.l %a1,%d1
	jne .L506
.L503:
	addq.l #1,led_gen
	move.b %d0,led_req_mode
	clr.l %d0
	lea led_req,%a1
.L507:
	mvz.b 6(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L508
	moveq #16,%d3
	cmp.l %d0,%d3
	jne .L509
.L508:
	addq.l #1,led_gen
	jra .L476
.L509:
	lea 7(%a0,%d0.l),%a2
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	jra .L507
.L484:
	moveq #14,%d4
	cmp.l %d0,%d4
	jcs .L465
	mvz.w #21504,%d2
	btst %d0,%d2
	jeq .L465
	mvz.b 7(%a0),%d0
	moveq #31,%d5
	cmp.l %d0,%d5
	jcs .L465
	mov3q.l #4,%d6
	cmp.l %d1,%d6
	jge .L511
	mvz.b 10(%a0),%d0
	cmp.l %d0,%d5
	jcs .L465
	mov3q.l #7,%d7
	cmp.l %d1,%d7
	jne .L511
	mvz.b 12(%a0),%d0
	cmp.l %d0,%d5
	jcs .L465
.L511:
	addq.l #1,sq_gen
	clr.l %d0
	lea sq_req,%a1
.L513:
	cmp.l %d1,%d0
	jge .L574
	moveq #127,%d3
	move.b 6(%a0,%d0.l),%d2
	and.l %d3,%d2
.L512:
	move.b %d2,(%a1,%d0.l)
	addq.l #1,%d0
	mov3q.l #7,%d4
	cmp.l %d0,%d4
	jne .L513
	addq.l #1,sq_gen
	jra .L476
.L574:
	clr.b %d2
	jra .L512
.L471:
	subq.l #2,%d1
	tst.l %d1
	jne .L465
	mvz.b 7(%a0),%d0
	moveq #31,%d6
	cmp.l %d0,%d6
	jcs .L465
	lsl.l #7,%d0
	mvz.b 6(%a0),%d1
	addq.l #1,pin+56
	or.l %d0,%d1
	move.l %d1,pin+4
	jra .L476
.L470:
	move.l %d0,%d2
	moveq #14,%d7
	add.l #-10,%d2
	rems.l %d7,%d5:%d2
	tst.l %d5
	jne .L575
	mov3q.l #3,%a1
.L516:
	mov3q.l #2,%d2
	cmp.l %d1,%d2
	jge .L517
	move.b 6(%a0),%d4
	mvz.b %d4,%d3
	cmp.l %d3,%d2
	jcs .L517
	move.b 7(%a0),%d2
	mvz.b %d2,%d6
	lsr.l #1,%d6
	jne .L517
	tst.l %d5
	jeq .L518
	add.l #-11,%d0
	moveq #14,%d6
	rems.l %d6,%d5:%d0
	tst.l %d5
	jne .L517
.L518:
	mov3q.l #4,%d7
	cmp.l %a1,%d7
	jne .L519
	mvz.b 9(%a0),%d0
	lsr.l #3,%d0
	jeq .L519
.L517:
	addq.l #1,ux+12
	jra .L465
.L575:
	mov3q.l #4,%a1
	jra .L516
.L519:
	move.b %d4,%d0
	ext.w %d0
	tst.b %d2
	jne .L520
	move.l %d3,%a2
	add.l #ux,%a2
	mvz.b 3948(%a2),%d4
	mov3q.l #4,%d6
	cmp.l %a1,%d6
	jne .L521
	mvz.b 9(%a0),%d2
	cmp.l %d4,%d2
	jeq .L522
.L520:
	move.w %d0,%d2
	mulu.w #1280,%d2
	move.l %d2,%a2
	add.l #ux+40,%a2
	mvz.w #128,%d2
	move.l %a2,-40(%fp)
.L523:
	move.l -40(%fp),%a3
	moveq #10,%d4
	subq.l #1,%d2
	add.l %d4,-40(%fp)
	clr.b (%a3)
	tst.l %d2
	jne .L523
	mov3q.l #4,%d5
	cmp.l %a1,%d5
	jne .L576
.L522:
	move.b 9(%a0),%d2
.L524:
	lea ux,%a2
	moveq #127,%d6
	lea (%a2,%d3.l),%a3
	move.b %d2,3948(%a3)
	move.w %d0,%d4
	lea (%a0,%a1.l),%a3
	addq.l #1,%a1
	move.b 8(%a0),%d2
	mulu.w #1280,%d4
	and.l %d6,%d2
	move.b %d2,36(%a2,%d3.l)
.L525:
	move.l %a1,%d0
	add.l #12,%d0
	cmp.l %d1,%d0
	jlt .L530
	addq.l #1,ux+8
	jra .L476
.L576:
	clr.b %d2
	jra .L524
.L530:
	move.b 6(%a3),%d0
	jmi .L526
	ext.w %d0
	move.l %d4,%a0
	mulu.w #10,%d0
	lea 40(%a0,%d0.l),%a2
	sub.l %a0,%a0
	add.l #ux,%a2
.L527:
	move.b 7(%a3,%a0.l),%d3
	moveq #94,%d5
	move.l %d3,%d2
	add.l #-32,%d2
	mvz.b %d2,%d2
	cmp.l %d2,%d5
	jcs .L528
	move.b %d3,(%a2,%a0.l)
	addq.l #1,%a0
	moveq #9,%d0
	cmp.l %a0,%d0
	jne .L527
.L528:
	clr.b %d6
	move.b %d6,(%a2,%a0.l)
.L526:
	lea (14,%a3),%a3
	lea (14,%a1),%a1
	jra .L525
.L466:
	move.b 6(%a0),%d2
	moveq #96,%d0
	moveq #64,%d7
	and.l %d2,%d0
	cmp.l %d0,%d7
	jne .L577
	tst.l %d1
	jeq .L465
	mov3q.l #1,%d3
	mov3q.l #2,%d0
.L531:
	cmp.l %d1,%d0
	jne .L465
	mvz.b %d2,%d0
	moveq #111,%d4
	cmp.l %d0,%d4
	jcs .L465
	moveq #-128,%d0
	or.l %d2,%d0
	move.b %d0,-32(%fp)
	move.b 7(%a0),-31(%fp)
	tst.l %d3
	jne .L578
	move.b 8(%a0),%d0
.L534:
	move.b %d0,-30(%fp)
	moveq #112,%d5
	moveq #16,%d6
	and.l %d5,%d2
	move.l 1094559344,%a1
	move.l 1094559356,%d4
	move.w -66825036,%d0
	mvz.w %d0,%d0
	sub.l %d4,%d0
	mvz.w -66825028,%d4
	add.l %a1,%d0
	move.l 1094559352,%a1
	add.l %d1,%a1
	sub.l %d4,%d0
	and.l #4095,%d0
	mvz.w #4096,%d4
	sub.l %d0,%d4
	cmp.l %d2,%d6
	jne .L535
	tst.l %d3
	jne .L581
	tst.b 8(%a0)
	jeq .L581
	mvz.w #512,%d0
.L536:
	add.l %a1,%d0
	cmp.l %d0,%d4
	jge .L537
	addq.l #1,din_drop
	jra .L476
.L577:
	clr.l %d3
	mov3q.l #3,%d0
	jra .L531
.L578:
	clr.b %d0
	jra .L534
.L535:
	lsr.l #5,%d2
	jeq .L581
	mvz.w #1536,%d0
	jra .L536
.L581:
	moveq #8,%d0
	jra .L536
.L537:
	mov3q.l #3,-(%sp)
	pea -32(%fp)
	move.l %d1,-(%sp)
	jsr 1074288478
	lea (12,%sp),%sp
	addq.l #1,din_sent
	jra .L476
.L472:
	subq.l #3,%d1
	tst.l %d1
	jne .L465
	mvz.b 6(%a0),%d0
	moveq #11,%d1
	cmp.l %d0,%d1
	jcs .L465
	tst.b 7(%a0)
	jlt .L465
	mvz.b 8(%a0),%d1
	lsr.l #3,%d1
	jne .L465
	moveq #127,%d1
	and.l -2147457096,%d1
	lea ar,%a1
	move.b %d1,48(%a1,%d0.l)
	mvz.b 8(%a0),%d1
	mvz.b 7(%a0),%d0
	mvz.b 6(%a0),%d2
	lsl.l #7,%d1
	or.l %d1,%d0
	or.l #-32768,%d0
	move.w %d0,24(%a1,%d2.l*2)
	jra .L476
.L469:
	move.l ux+3880,%d3
	add.l #-10,%d0
	mov3q.l #2,%d4
	cmp.l %d0,%d4
	jcs .L465
	move.b 6(%a0),%d2
	moveq #11,%d5
	mvz.b %d2,%d0
	cmp.l %d0,%d5
	jcs .L465
	mvz.b 7(%a0),%d0
	lsr.l #4,%d0
	jne .L465
	tst.b 8(%a0)
	jlt .L465
	mov3q.l #3,%d7
	cmp.l %d1,%d7
	jge .L542
	tst.b 9(%a0)
	jlt .L465
	mov3q.l #5,%d0
	cmp.l %d1,%d0
	jne .L542
	tst.b 10(%a0)
	jlt .L465
.L542:
	move.l %d3,%d0
	sub.l ux+3884,%d0
	lea ux,%a1
	lsr.l #3,%d0
	jeq .L543
	addq.l #1,ux+28
	jra .L476
.L543:
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
	jlt .L544
	clr.b %d6
	move.b %d6,3891(%a2)
.L545:
	clr.b %d1
.L547:
	add.l %d0,%a1
	addq.l #1,%d3
	move.b %d1,3952(%a1)
	move.l %d3,ux+3880
	addq.l #1,ux+16
	jra .L476
.L544:
	move.b 9(%a0),3891(%a2)
	subq.l #5,%d1
	tst.l %d1
	jne .L545
	move.b 10(%a0),%d1
	jra .L547
.L483:
	subq.l #4,%d1
	tst.l %d1
	jne .L465
	move.l %a0,%d1
	add.l #10,%d1
	lea (6,%a0),%a1
.L550:
	mvz.b (%a1),%d0
	moveq #111,%d2
	cmp.l %d0,%d2
	jcc .L549
	moveq #127,%d3
	cmp.l %d0,%d3
	jne .L465
.L549:
	addq.l #1,%a1
	cmp.l %d1,%a1
	jne .L550
	addq.l #1,pg_gen
	clr.l %d0
	lea pg_req,%a1
.L551:
	lea 6(%a0,%d0.l),%a2
	mov3q.l #4,%d1
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L551
	addq.l #1,pg_gen
	jra .L476
.L481:
	tst.l %d1
	jeq .L465
	move.b 6(%a0),%d0
	moveq #127,%d2
	and.l %d2,%d0
	bset #8,%d0
	move.l %d0,splash_req
	jra .L476
.L480:
	move.l %d0,%a2
	moveq #37,%d3
	lea (-10,%a2),%a2
	cmp.l %a2,%d3
	jcs .L465
	clr.l -32(%fp)
	moveq #127,%d4
	clr.l -28(%fp)
	moveq #14,%d5
	clr.l -24(%fp)
	clr.l -20(%fp)
	clr.l -16(%fp)
	clr.l -12(%fp)
	clr.l -8(%fp)
	clr.l -4(%fp)
	move.b 8(%a0),%d1
	move.b 7(%a0),%d2
	move.b 6(%a0),%d0
	and.l %d4,%d1
	and.l %d4,%d2
	and.l %d4,%d0
	lsl.l %d5,%d1
	lsl.l #7,%d2
	or.l %d2,%d1
	clr.l %d2
	or.l %d0,%d1
.L554:
	cmp.l %d2,%a2
	jgt .L557
	mvz.w %d1,%d1
	lea (-32,%fp),%a0
	clr.l %d0
	lea mask_keys,%a1
	move.l %d1,mask_enc
.L558:
	move.l (%a0)+,(%a1,%d0.l*4)
	moveq #8,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L558
	mov3q.l #1,mask_set
	addq.l #1,masks
	jra .L476
.L557:
	move.w %d2,%d3
	mvz.b 9(%a0,%d2.l),%d5
	clr.l %d0
	mulu.w #7,%d3
.L556:
	btst %d0,%d5
	jeq .L555
	cmp.l #255,%d3
	jgt .L555
	moveq #31,%d6
	mov3q.l #1,%d7
	and.l %d3,%d6
	lsl.l %d6,%d7
	move.l %d3,%d6
	asr.l #5,%d6
	or.l %d7,-32(%fp,%d6.l*4)
.L555:
	addq.l #1,%d0
	addq.l #1,%d3
	mov3q.l #7,%d7
	cmp.l %d0,%d7
	jne .L556
	addq.l #1,%d2
	jra .L554
.L475:
	mov3q.l #5,%d2
	cmp.l %d1,%d2
	jge .L559
	move.b 7(%a0),%d1
	moveq #63,%d3
	mvz.b %d1,%d2
	cmp.l %d2,%d3
	jcs .L559
	move.b 8(%a0),%d4
	jmi .L559
	mvz.b 9(%a0),%d3
	lsr.l #6,%d3
	jne .L559
	mvz.b 10(%a0),%d3
	moveq #16,%d6
	cmp.l %d3,%d6
	jcs .L559
	add.l #-13,%d0
	moveq #32,%d7
	cmp.l %d0,%d7
	jge .L582
.L559:
	clr.b %d0
	addq.l #1,rx_bad
	move.b %d0,st_valid
.L464:
	move.l -66650100,%d0
	addq.l #1,mt_calls
	sub.l -36(%fp),%d0
	add.l %d0,mt_sum
	cmp.l mt_max.l,%d0
	jls .L592
	move.l %d0,mt_max
.L592:
	movem.l -76(%fp),#3324
	mov3q.l #1,%d0
	unlk %fp
	rts
.L562:
	move.b 12(%a0,%a1.l),%d3
	moveq #94,%d5
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcc .L561
	clr.b %d6
	addq.l #1,rx_bad
	move.b %d6,st_valid
	jra .L464
.L561:
	addq.l #1,%a1
.L560:
	cmp.l %d0,%a1
	jlt .L562
	moveq #44,%d7
	ext.w %d1
	muls.l %d7,%d2
	lea txt_st,%a1
	mulu.w #44,%d1
	move.b %d4,(%a1,%d2.l)
	add.l %d2,%a1
	move.b 9(%a0),1(%a1)
	move.b 10(%a0),2(%a1)
	move.b 11(%a0),3(%a1)
	move.b %d0,4(%a1)
	move.l %d1,%a1
	clr.l %d1
	add.l #txt_st,%a1
.L563:
	cmp.l %d0,%d1
	jlt .L564
	clr.b %d1
	lea txt_st,%a3
	addq.l #6,%a0
	add.l %d2,%a3
	moveq #1,%d2
	move.b %d1,8(%a3,%d0.l)
	move.b %d2,st_valid
	move.b (%a0),st_seq
	jra .L476
.L582:
	sub.l %a1,%a1
	jra .L560
.L564:
	lea 12(%a0,%d1.l),%a2
	move.b (%a2),8(%a1,%d1.l)
	addq.l #1,%d1
	jra .L563
.L474:
	tst.l %d1
	jeq .L465
	lea txt_st+4,%a1
	moveq #64,%d0
.L566:
	clr.b (%a1)
	subq.l #1,%d0
	lea (44,%a1),%a1
	tst.l %d0
	jne .L566
	moveq #1,%d3
	addq.l #6,%a0
	move.b (%a0),st_seq
	move.b %d3,st_valid
	jra .L476
.L473:
	mov3q.l #5,%d4
	cmp.l %d1,%d4
	jge .L465
	move.b 6(%a0),%d1
	moveq #15,%d6
	mvz.b %d1,%d5
	cmp.l %d5,%d6
	jcs .L465
	add.l #-13,%d0
	moveq #11,%d7
	cmp.l %d0,%d7
	jlt .L465
	lea bind_gen,%a2
	addq.l #1,(%a2,%d5.l*4)
	move.b 7(%a0),%d3
	mvz.b %d3,%d4
	lsr.l #6,%d4
	jeq .L569
	st %d3
.L569:
	moveq #20,%d7
	ext.w %d1
	muls.l %d5,%d7
	lea bind_in,%a1
	mulu.w #20,%d1
	move.b %d3,(%a1,%d7.l)
	add.l %d7,%a1
	move.l %d7,-40(%fp)
	move.b 8(%a0),1(%a1)
	move.b 9(%a0),2(%a1)
	move.b 10(%a0),3(%a1)
	move.b 11(%a0),4(%a1)
	move.b %d0,5(%a1)
	move.l %d1,%a1
	clr.l %d1
	add.l #bind_in,%a1
.L570:
	cmp.l %d0,%d1
	jlt .L572
	mvz.b 6(%a0),%d0
	addq.l #1,(%a2,%d0.l*4)
	jra .L476
.L572:
	move.b 12(%a0,%d1.l),%d3
	moveq #94,%d5
	move.l %d3,%d4
	add.l #-32,%d4
	mvz.b %d4,%d4
	cmp.l %d4,%d5
	jcc .L571
	move.b %d2,%d3
.L571:
	move.b %d3,6(%a1,%d1.l)
	addq.l #1,%d1
	jra .L570
.L521:
	tst.l %d4
	jne .L520
	jra .L524
	.size	rui_sysex, .-rui_sysex
	.align	2
	.type	ov_suffix, @function
ov_suffix:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	clr.l %d0
.L625:
	move.l 20(%sp),%a0
	tst.b (%a0,%d0.l)
	jne .L626
	cmp.l %d1,%d0
	jle .L631
.L629:
	clr.l %d0
.L624:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L626:
	addq.l #1,%d0
	jra .L625
.L630:
	move.l 20(%sp),%a2
	mvs.b (%a0,%a1.l),%d2
	mvs.b (%a2,%a1.l),%d1
	cmp.l %d2,%d1
	jne .L629
	addq.l #1,%a1
.L627:
	cmp.l %a1,%d0
	jne .L630
	mov3q.l #1,%d0
	jra .L624
.L631:
	add.l 12(%sp),%d1
	sub.l %a1,%a1
	move.l %d1,%a0
	sub.l %d0,%a0
	jra .L627
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
	jne .L633
.L645:
	move.l ov_is,%d0
	jra .L632
.L633:
	move.l %d0,%d1
	add.l #-1073742852,%d1
	move.l %d0,ov_vt
	clr.l ov_is
	clr.l ov_list
	addq.l #1,ov_n
	cmp.l #2997243,%d1
	jls .L635
.L636:
	clr.l %d0
.L632:
	movem.l (%sp),#7180
	lea (20,%sp),%sp
	rts
.L635:
	mov3q.l #3,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L636
	move.l %d0,%a0
	move.l -4(%a0),%d0
	move.l %d0,%d1
	add.l #-1073742848,%d1
	cmp.l #2997247,%d1
	jhi .L636
	btst #0,%d0
	jne .L636
	move.l %d0,%a0
	move.l 4(%a0),%a2
	move.l %a2,%d0
	add.l #-1073742848,%d0
	cmp.l #2997247,%d0
	jhi .L636
.L637:
	move.b (%a2),%d0
	moveq #9,%d1
	add.l #-48,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jcc .L638
	clr.l %d2
.L639:
	tst.b (%a2,%d2.l)
	jne .L640
	pea .LC5
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	lea ov_suffix,%a3
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L642
	pea .LC0
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L642
	pea .LC1
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
.L642:
	pea .LC2
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	move.l %d0,ov_list
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L643
	moveq #17,%d1
	cmp.l %d2,%d1
	jne .L644
	pea .LC3
	pea 17.w
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	mov3q.l #1,%d1
	eor.l %d1,%d0
.L644:
	move.l %d0,ov_is
	jra .L645
.L638:
	addq.l #1,%a2
	jra .L637
.L640:
	addq.l #1,%d2
	moveq #48,%d0
	cmp.l %d2,%d0
	jne .L639
	jra .L636
.L643:
	pea .LC4
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L646
	mov3q.l #1,ov_is
	jra .L645
.L646:
	lea ov_names,%a4
	clr.l %d3
.L650:
	move.l (%a4)+,%a0
	clr.l %d0
.L647:
	tst.b (%a0,%d0.l)
	jne .L648
	cmp.l %d0,%d2
	jne .L649
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L649
	mov3q.l #1,ov_is
.L649:
	addq.l #1,%d3
	moveq #14,%d0
	cmp.l %d3,%d0
	jne .L650
	jra .L645
.L648:
	addq.l #1,%d0
	jra .L647
	.size	overlay, .-overlay
	.align	2
	.type	sv_tick, @function
sv_tick:
	lea (-52,%sp),%sp
	clr.l %d0
	movem.l #31996,(%sp)
	move.l 56(%sp),%a2
	sub.l %a6,%a6
	clr.l sv+80
	sub.l %a5,%a5
	move.l 28(%a2),%d6
	sub.l %a3,%a3
	clr.l %d3
	clr.l %d5
	lea (20,%a2),%a4
	move.b 1093765506,%d1
	move.b %d1,47(%sp)
	clr.l %d1
.L662:
	tst.l %d6
	jeq .L674
	cmp.l %d6,%a4
	jeq .L674
	move.l %d6,%a0
	move.l 8(%a0),%d7
	tst.l %d7
	jeq .L663
	move.l %d7,%a0
	move.l (%a0),%d2
	tst.l %d5
	jeq .L664
	cmp.l #1075718412,%d2
	jeq .L665
	cmp.l #1075712228,%d2
	jeq .L665
	cmp.l #1075719596,%d2
	jeq .L665
	cmp.l #1075717140,%d2
	jne .L664
.L665:
	move.l %d6,%a0
	move.l (%a0),%d6
.L666:
	addq.l #1,%d3
	moveq #16,%d2
	cmp.l %d3,%d2
	jne .L662
.L674:
	cmp.l sv+84.l,%d0
	jne .L678
	cmp.l sv+88.l,%a3
	jeq .L679
.L678:
	move.l %d0,sv+84
	move.l %a3,sv+88
	clr.l sv+96
.L680:
	move.l %d3,sv+92
	tst.l %d1
	jeq .L681
	moveq #16,%d4
	cmp.l %d3,%d4
	jeq .L681
	tst.l %d6
	jne .L682
.L681:
	clr.l sv+80
.L663:
	clr.l %d2
.L686:
	tst.b sv.l
	jeq .L688
	clr.b %d1
	lea sv+1,%a0
	moveq #1,%d3
	move.b (%a0),sv+5
	addq.l #1,sv+60
	move.b %d1,sv
	move.b %d1,sv+6
	move.b %d3,sv+4
	jra .L688
.L664:
	move.l %d2,%a3
	cmp.l #1075721468,%d2
	jne .L667
	move.l %d7,sv+80
	mov3q.l #1,%d1
.L668:
	tst.l %d5
	jeq .L670
	lea sv_covers,%a1
	sub.l %a0,%a0
.L671:
	cmp.l (%a1),%d2
	jne .L673
.L701:
	move.l %d5,%a6
.L670:
	cmp.l #1076055292,%d2
	seq %d0
	move.l %d6,%a0
	move.l (%a0),%d6
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d5
	move.l %d7,%d0
	jra .L666
.L667:
	cmp.l #1075720560,%d2
	jne .L669
	mov3q.l #2,%d0
	or.l %d0,%d1
	jra .L668
.L669:
	cmp.l #1075628548,%d2
	jne .L668
	move.l %d7,%a0
	move.l %a6,%d4
	tst.b 127(%a0)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d4
	move.l %d4,%a6
	jra .L668
.L673:
	addq.l #4,%a1
	addq.l #1,%a0
	moveq #8,%d0
	cmp.l %a0,%d0
	jne .L671
	move.l %d2,-(%sp)
	move.l %d1,52(%sp)
	jsr overlay
	addq.l #4,%sp
	move.l 48(%sp),%d1
	tst.l %d0
	jne .L701
	move.l %d5,%a5
	jra .L670
.L679:
	move.l sv+96,%d0
	cmp.l #65534,%d0
	jhi .L680
	addq.l #1,%d0
	move.l %d0,sv+96
	jra .L680
.L682:
	mov3q.l #1,%d2
	eor.l %d5,%d2
	move.l %a6,%d0
	or.l %d0,%d2
	tst.l %a5
	jeq .L684
	cmp.l #1076055292,%a3
	jeq .L684
	moveq #59,%d3
	cmp.l sv+96.l,%d3
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d2
.L684:
	btst #0,%d1
	jeq .L681
	mvz.b 47(%sp),%d5
	moveq #11,%d4
	cmp.l %d5,%d4
	jlt .L663
	move.b 47(%sp),%d1
	moveq #127,%d0
	addq.l #1,%d2
	and.l -2147457096,%d0
	move.b sv,%d6
	ext.w %d1
	mulu.w #2531,%d0
	mulu.w #152,%d1
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	move.b (%a0),%d7
	mvz.b %d7,%d3
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	moveq #127,%d1
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jeq .L686
	tst.b %d6
	jeq .L687
	mvz.b sv+1,%d0
	cmp.l %d5,%d0
	jne .L687
	mvz.b sv+2,%d0
	cmp.l %d0,%d3
	jeq .L688
.L687:
	moveq #1,%d3
	move.b 47(%sp),%d4
	move.w #257,%d0
	move.b %d7,sv+2
	lea commits,%a0
	move.l (%a0),sv+12
	addq.l #1,sv+56
	move.b %d3,sv
	move.b %d4,sv+1
	move.b %d3,sv+4
	move.b %d4,sv+5
	move.w %d0,sv+6
.L688:
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	seq %d5
	move.l 60(%sp),%d1
	neg.l %d5
	move.b %d5,sv+3
	cmp.l sv+20.l,%d1
	jeq .L691
	clr.l sv+16
	sub.l %a0,%a0
.L692:
	move.b sv,%d7
	move.l 60(%sp),%d3
	move.l sv+12,%d1
	move.l st+4,%d6
	move.l st+972,%d4
	move.l %d3,sv+20
	tst.b %d7
	jeq .L693
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	jne .L694
.L693:
	clr.l %d3
.L695:
	cmp.l commits.l,%d1
	sne %d0
	tst.l %d6
	sne %d6
	tst.l %d4
	sne %d4
	add.l %d5,%d5
	move.w %d3,%a1
	move.b %d3,sv+8
	neg.l %d0
	neg.l %d6
	lsl.l #2,%d0
	lsl.l #4,%d6
	neg.l %d4
	lsl.l #5,%d4
	or.l %d6,%d0
	or.l %d7,%d0
	or.l %d4,%d0
	moveq #19,%d4
	cmp.l %a0,%d4
	scs %d1
	mvz.b sv+101,%d4
	or.l %d5,%d0
	neg.l %d1
	lsl.l #3,%d1
	or.l %d1,%d0
	move.l %d3,%d1
	lsl.l #6,%d1
	or.l %d1,%d0
	mvz.b %d0,%d1
	cmp.l %d4,%d1
	jne .L696
	move.l sv+104,%a0
	cmp.l sv+88.l,%a0
	jne .L696
	tst.l %d2
	jeq .L697
	move.l st+8,%d1
	moveq #19,%d4
	sub.l sv+108,%d1
	cmp.l %d1,%d4
	jge .L697
.L696:
	moveq #1,%d1
	move.b %d1,sv+102
.L697:
	move.w %a1,%d4
	move.b %d0,sv+100
	mvz.b sv+9,%d1
	mvz.b %d4,%d0
	cmp.l %d0,%d1
	jeq .L661
	tst.l %d3
	jeq .L699
	addq.l #1,sv+72
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
.L700:
	move.w %a1,%d1
	moveq #1,%d2
	move.b %d1,sv+9
	move.b %d2,32(%a2)
.L661:
	movem.l (%sp),#31996
	lea (52,%sp),%sp
	rts
.L691:
	move.l sv+16,%a0
	cmp.l #65534,%a0
	jhi .L692
	addq.l #1,%a0
	move.l %a0,sv+16
	jra .L692
.L694:
	cmp.l commits.l,%d1
	jeq .L693
	moveq #19,%d3
	cmp.l %a0,%d3
	jcs .L693
	move.l %d6,%d3
	or.l %d4,%d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
	jra .L695
.L699:
	subq.l #2,%d2
	tst.l %d2
	jne .L700
	addq.l #1,sv+76
	jra .L700
	.size	sv_tick, .-sv_tick
	.align	2
	.type	enter, @function
enter:
	move.l %d2,-(%sp)
	move.b 15(%sp),%d1
	tst.l st+4
	jne .L747
	tst.l st+972
	jeq .L749
	clr.l st+972
	mov3q.l #6,st+988
.L749:
	lea commits,%a0
	moveq #16,%d0
	move.l (%a0),st+24
	mov3q.l #1,st+4
	clr.l st+12
	mov3q.l #-1,st+20
	lea st+96,%a0
	addq.l #1,st+48
.L750:
	clr.l (%a0)+
	subq.l #1,%d0
	tst.l %d0
	jne .L750
	lea st+408,%a0
.L751:
	clr.l (%a0)+
	moveq #16,%d2
	addq.l #1,%d0
	cmp.l %d0,%d2
	jne .L751
	mvz.b %d1,%d0
	moveq #1,%d2
	lea (19,%sp),%a0
	move.b (%a0),st+993
	bset #8,%d0
	move.l 8(%sp),%a0
	move.b %d1,st+162
	clr.l st+196
	move.l %d0,st+296
	moveq #1,%d0
	move.b %d0,st+161
	move.b %d0,st+163
	move.b %d0,mr+13
	move.b %d0,mr+19
	move.w #4095,%d0
	move.w %d0,ar+60
	move.b %d2,32(%a0)
.L747:
	move.l (%sp)+,%d2
	rts
	.size	enter, .-enter
	.align	2
	.type	leave, @function
leave:
	move.l %d2,-(%sp)
	move.b 15(%sp),%d1
	tst.l st+4
	jeq .L754
	clr.l st+4
	clr.l st+1038
	addq.l #1,st+52
	clr.l st+1058
	clr.l st+196
	tst.l nk
	jeq .L756
	moveq #-33,%d0
	moveq #32,%d2
	and.l %d0,st+240
	or.l %d2,st+272
	clr.l nk
.L756:
	clr.l %d0
	lea kq_nodown,%a1
	lea kq_owed,%a0
.L757:
	clr.l (%a1,%d0.l)
	moveq #32,%d2
	clr.l (%a0,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d2
	jne .L757
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
	jne .L758
	clr.l st+1006
	jsr led_restore
.L758:
	moveq #1,%d0
	move.l 8(%sp),%a0
	move.b %d0,32(%a0)
.L754:
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
	jeq .L761
	move.l st+8,%d0
	mov3q.l #1,txsx_test_on
	add.l txsx_test,%d0
	clr.l txsx_test
	move.l %d0,txsx_test_end
.L761:
	tst.l kq_owes
	jeq .L762
	jsr (kq_owed_in.part.0)
.L762:
	moveq #31,%d1
	mov3q.l #1,%d0
	and.l %d3,%d1
	move.l %d3,%d2
	lsr.l #5,%d2
	lea kq_nodown,%a0
	move.l (%a0,%d2.l*4),%d4
	lsl.l %d1,%d0
	tst.l 28(%sp)
	jeq .L763
	move.l %d0,%d1
	not.l %d1
	and.l %d4,%d1
	move.l %d1,(%a0,%d2.l*4)
	tst.l kq_owes
	jne .L764
	move.l st+196,%d1
	moveq #15,%d5
	move.l %d1,%a1
	addq.l #6,%a1
	cmp.l %a1,%d5
	jcc .L765
.L764:
	or.l %d0,%d4
	addq.l #1,st+44
	move.l %d4,(%a0,%d2.l*4)
.L760:
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L763:
	move.l %d4,%d1
	and.l %d0,%d1
	tst.l %d1
	jeq .L767
	not.l %d0
	and.l %d4,%d0
	move.l %d0,(%a0,%d2.l*4)
	jra .L760
.L767:
	move.l st+196,%d1
	moveq #15,%d4
	cmp.l %d1,%d4
	jcc .L765
	move.l %d1,%a1
	subq.l #1,%a1
	lea st+164,%a0
.L768:
	tst.l %a1
	jlt .L769
	mvz.b (%a0,%a1.l*2),%d4
	cmp.l %d4,%d3
	jne .L770
	move.l %a1,%d3
	add.l %d3,%d3
	move.l %d3,%d4
	add.l #st,%d4
	move.l %d4,%a2
	tst.b 165(%a2)
	jeq .L769
	add.l %d3,%a0
.L771:
	addq.l #1,%a1
	cmp.l %d1,%a1
	jlt .L772
	subq.l #1,%d1
	move.l %d1,st+196
	addq.l #1,st+44
	jra .L760
.L770:
	subq.l #1,%a1
	jra .L768
.L772:
	addq.l #2,%a0
	move.b (%a0),-2(%a0)
	move.b 1(%a0),-1(%a0)
	jra .L771
.L769:
	lea kq_owed,%a0
	move.l (%a0,%d2.l*4),%d1
	move.l %d1,%d3
	and.l %d0,%d3
	tst.l %d3
	jne .L760
	or.l %d0,%d1
	addq.l #1,kq_owes
	move.l %d1,(%a0,%d2.l*4)
	jra .L760
.L765:
	lea st,%a0
	move.l %d1,%d0
	add.l #82,%d0
	move.b %d3,(%a0,%d0.l*2)
	lea (%a0,%d1.l*2),%a0
	addq.l #1,%d1
	move.l %d1,st+196
	move.b 31(%sp),165(%a0)
	jra .L760
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
	jeq .L776
	move.l %d3,-(%sp)
	jsr cu_src_setup
	mvz.b cu+1,%d0
	move.l %d3,%d4
	addq.l #4,%sp
	add.l #-46,%d4
	cmp.l %d0,%d3
	jne .L778
	move.l 1075597888,%d0
	cmp.l 4(%a3),%d0
	jne .L778
	move.l 1075596172,%d0
	cmp.l 102(%a3),%d0
	jne .L778
	move.l 1075597884,%d1
	mov3q.l #6,%d0
	cmp.l %d4,%d0
	jcs .L782
	lea CSWTCH.500,%a0
	move.l (%a0,%d4.l*4),%d0
.L779:
	cmp.l %d0,%d1
	jeq .L776
.L778:
	move.l %a3,%d5
	move.l %a3,%d2
	lea cu_p2,%a2
	add.l #112,%d5
	lea CSWTCH.500,%a4
	lea cu_knob,%a3
.L781:
	mov3q.l #6,%d0
	cmp.l %d4,%d0
	jcs .L783
	move.l (%a4,%d4.l*4),%d0
.L780:
	move.l %d0,-(%sp)
	mvs.w (%a2)+,%d0
	move.l %d2,-(%sp)
	add.l #14,%d2
	move.l %d0,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	cmp.l %d2,%d5
	jne .L781
	move.w cu+2,%d0
	move.b %d3,cu+1
	addq.l #1,%d0
	move.w %d0,cu+2
.L776:
	movem.l (%sp),#7228
	lea (28,%sp),%sp
	rts
.L782:
	move.l #cu_fm_short,%d0
	jra .L779
.L783:
	move.l #cu_fm_short,%d0
	jra .L780
	.size	cu_setup, .-cu_setup
	.align	2
	.type	isr_send, @function
isr_send:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jeq .L789
.L797:
	clr.l %d0
.L788:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L789:
#APP
| 1604 "rui.c" 1
	move.w %sr,%d0
| 0 "" 2
#NO_APP
	move.l %d0,%d3
	move.l %d0,%d2
	and.l #1792,%d3
	mvz.w %d2,%d2
	cmp.l #1279,%d3
	jhi .L791
	and.l #63743,%d0
	or.l #1280,%d0
#APP
| 1608 "rui.c" 1
	move.w %d0,%sr
| 0 "" 2
#NO_APP
.L791:
	tst.l 1123449384
	jeq .L792
.L794:
#APP
| 1613 "rui.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	addq.l #1,sq+388
	jra .L797
.L792:
	tst.l 1094562372
	jne .L794
	move.l %d1,%d0
	add.l 1094562392,%d0
	cmp.l #3800,%d0
	jgt .L794
	move.l 1094562704,%a0
	tst.l %a0
	jeq .L794
	move.l 52(%a0),%a0
	tst.l %a0
	jeq .L794
	move.l 52(%a0),%d0
	move.l 12(%sp),-(%sp)
	move.l %d1,-(%sp)
	jsr 1073752544
#APP
| 1613 "rui.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	mov3q.l #1,%d0
	addq.l #8,%sp
	jra .L788
	.size	isr_send, .-isr_send
	.align	2
	.globl	rui_render_in
	.type	rui_render_in, @function
rui_render_in:
	link.w %fp,#-108
	movem.l #1052,(%sp)
	tst.l 1094562372
	jne .L805
	mov3q.l #1,txsx_gap
.L805:
	lea fp,%a0
	addq.l #1,(%a0)
	tst.l fp+8
	jeq .L804
	move.l (%a0),%d0
	sub.l fp+4,%d0
	cmp.l #3000,%d0
	jls .L804
	move.l fp+8,%a0
	move.l fp,%d0
	move.l fp+4,%d1
	move.l 1123449124,%d3
	tst.l fp+12
	jeq .L807
	move.l fp,%a1
	sub.l fp+12,%a1
	cmp.l #7499,%a1
	jls .L804
.L807:
	cmp.l %a0,%d3
	seq %d2
	sub.l %d1,%d0
	lea (-90,%fp),%a1
	clr.l %d1
	move.l %a1,%a2
	neg.l %d2
.L808:
	clr.l (%a2)+
	moveq #9,%d4
	addq.l #1,%d1
	cmp.l %d1,%d4
	jne .L808
	cmp.l %a0,%d3
	jeq .L809
	mov3q.l #1,%d3
	move.l 72(%a0),%a0
	move.l %a0,%d1
	and.l %d3,%d1
	move.l %a0,%d4
	btst #0,%d4
	jne .L809
	move.l %a0,%d3
	add.l #-1073741824,%d3
	cmp.l #129892303,%d3
	jhi .L809
.L810:
	lea 4(%a0,%d1.l),%a2
	moveq #36,%d3
	move.l (%a2),(%a1,%d1.l)
	addq.l #4,%d1
	cmp.l %d1,%d3
	jne .L810
.L809:
	move.w #19969,%a0
	move.l #-260222380,%d4
	move.b %d2,-48(%fp)
	move.l %d4,-54(%fp)
	move.w %a0,-50(%fp)
	cmp.l #191999,%d0
	jhi .L815
	mvz.w #1500,%d2
	divu.l %d2,%d0
.L811:
	move.b %d0,-47(%fp)
	lea (-46,%fp),%a0
	clr.l %d1
.L812:
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
	jne .L812
	moveq #-9,%d1
	pea 54.w
	pea -54(%fp)
	move.b %d1,-1(%fp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L804
	lea fp,%a0
	tst.l (%a0)
	jeq .L816
	move.l (%a0),%d0
.L814:
	move.l %d0,fp+12
	addq.l #1,fp+16
.L804:
	movem.l -108(%fp),#1052
	unlk %fp
	rts
.L815:
	moveq #127,%d0
	jra .L811
.L816:
	mov3q.l #1,%d0
	jra .L814
	.size	rui_render_in, .-rui_render_in
	.align	2
	.globl	rui_uart
	.type	rui_uart, @function
rui_uart:
	lea (-40,%sp),%sp
	movem.l #19468,(%sp)
	clr.l %d2
	tst.b ov_on.l
	jne .L844
	tst.b ovp_on.l
	jne .L844
	tst.b ovt_on.l
	jeq .L831
.L844:
	move.l 44(%sp),%a0
	subq.l #1,%a0
	sub.l %a6,%a6
	lea rui_uart_raw,%a3
	move.l %a0,20(%sp)
	jra .L836
.L832:
	move.l 48(%sp),%a0
	mvz.b (%a0,%d2.l),%d0
	addq.l #1,%d2
	move.l %d0,-(%sp)
	jsr uart_byte
	addq.l #4,%sp
.L831:
	cmp.l 44(%sp),%d2
	jlt .L832
	clr.l %d0
.L829:
	movem.l (%sp),#19468
	lea (40,%sp),%sp
	rts
.L837:
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
	jeq .L834
	cmp.l 20(%sp),%a6
	jne .L835
.L834:
	pea 24(%sp)
	move.l %d3,-(%sp)
	jsr (%a3)
	addq.l #8,%sp
	clr.l %d3
.L835:
	addq.l #1,%a6
	move.l %d3,%d2
.L836:
	cmp.l 44(%sp),%a6
	jlt .L837
	mov3q.l #1,%d0
	jra .L829
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
	jcc .L846
.L850:
	clr.l %d0
.L845:
	move.l (%sp)+,%d2
	rts
.L846:
	tst.l sq
	jeq .L848
	move.l sq+4,%a0
	move.l %a0,%d2
	btst %d1,%d2
	jeq .L848
	addq.l #1,sq+448
	mov3q.l #1,%d0
	jra .L845
.L848:
	tst.l %d0
	jlt .L851
	moveq #63,%d2
	cmp.l %d0,%d2
	jlt .L852
.L849:
	lea pc,%a0
	move.b %d0,48(%a0,%d1.l)
	moveq #1,%d0
	lea st+8,%a1
	move.l (%a1),(%a0,%d1.l*4)
	move.b %d0,60(%a0,%d1.l)
	jra .L850
.L851:
	clr.b %d0
	jra .L849
.L852:
	moveq #63,%d0
	jra .L849
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
	jcs .L859
	mov3q.l #1,%d1
	cmp.l 1079807120.l,%d1
	jeq .L861
	clr.l sq+540
	clr.l sq+544
.L859:
	movem.l (%sp),#3132
	lea (24,%sp),%sp
	rts
.L861:
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
	jeq .L863
	mvz.b 516(%a0),%d1
	cmp.l %d4,%d1
	jeq .L864
.L865:
	clr.l %d0
.L863:
	mov3q.l #1,%d1
	lsl.l %d2,%d1
	move.l %a1,%d5
	move.b %d3,516(%a0)
	move.b 35(%sp),528(%a0)
	or.l %d1,%d5
	move.l sq+360,%d1
	move.l %d5,sq+540
	btst #8,%d1
	jeq .L867
	tst.l %d0
	jne .L859
	tst.l %d4
	jeq .L868
	tst.l sq+544
	jeq .L869
.L868:
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
.L869:
	lsr.l #7,%d4
	jne .L859
	tst.l (%a2)
	jeq .L859
	move.l sq+8,%d0
	btst %d2,%d0
	jeq .L859
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
	jne .L870
	mvz.w #917,%d0
	muls.l %d2,%d0
	add.l #709,%d0
	move.b (%a0,%d0.l),%d0
	jpl .L872
	moveq #127,%d0
.L872:
#APP
| 1604 "rui.c" 1
	move.w %sr,%d1
| 0 "" 2
#NO_APP
	move.l %d1,%d5
	move.l %d1,%d4
	and.l #1792,%d5
	mvz.w %d4,%d4
	cmp.l #1792,%d5
	jeq .L874
	and.l #63743,%d1
	or.l #1792,%d1
#APP
| 1608 "rui.c" 1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
.L874:
	move.l sq+268,%d1
	sub.l sq+272,%d1
	lsr.l #5,%d1
	jeq .L875
	addq.l #1,sq+380
.L876:
#APP
| 1613 "rui.c" 1
	move.w %d4,%sr
| 0 "" 2
#NO_APP
	jra .L859
.L864:
	mvz.b 528(%a0),%d1
	cmp.l 32(%sp),%d1
	jeq .L865
	addq.l #1,sq+548
	mov3q.l #1,sq+544
	jra .L863
.L867:
	tst.l %d0
	jne .L859
	jra .L869
.L870:
	move.l #85683,%d0
	move.b (%a0,%d0.l),%d0
	move.l #85684,%d1
	mvz.b (%a0,%d1.l),%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	moveq #127,%d1
	cmp.l %d0,%d1
	jcc .L872
	moveq #127,%d0
	jra .L872
.L875:
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
	jra .L876
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
	jcc .L890
	clr.l %d2
.L890:
	tst.l sq+348
	jne .L891
	move.l %d2,sq+352
	move.l %d3,sq+356
	mov3q.l #1,sq+348
.L891:
	lea sq,%a6
	tst.l (%a6)
	jeq .L892
	cmp.l sq+352.l,%d2
	jeq .L893
	move.l %d2,%d1
	mvz.b %d1,%d1
	move.l %d4,-(%sp)
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr sq_event
	lea (20,%sp),%sp
.L893:
	move.l sq+356,%d0
	cmp.l %d0,%d3
	jeq .L894
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jne .L895
	bset #8,%d0
	move.l %d0,sq+360
.L892:
	move.l %d2,sq+352
	move.l %d3,sq+356
.L897:
	tst.l sq+344
	jne .L902
	move.l %sp,%d3
	move.l %sp,%d2
	add.l #42,%d3
	add.l #36,%d2
.L903:
	move.l sq+272,%d4
	cmp.l sq+268.l,%d4
	jne .L909
.L908:
	move.l -66650100,%d0
	sub.l 32(%sp),%d0
	cmp.l sq+396.l,%d0
	jls .L889
	move.l %d0,sq+396
.L889:
	movem.l (%sp),#23612
	lea (104,%sp),%sp
	rts
.L895:
	mvz.b %d0,%d0
	move.l %d4,-(%sp)
	mov3q.l #2,-(%sp)
	move.l %d5,-(%sp)
	move.l %d0,-(%sp)
	mov3q.l #3,-(%sp)
	jsr sq_event
	lea (20,%sp),%sp
.L896:
	move.l sq+360,%d0
	btst #8,%d0
	jeq .L892
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
	jra .L892
.L894:
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jne .L896
	jra .L892
.L902:
	mvz.b sq+340,%d0
	move.l %d0,-(%sp)
	pea sq+276
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L889
	move.l sq+344,%d3
	clr.l %d1
	addq.l #1,sq+376
	lea sq+340,%a0
.L899:
	cmp.l %d3,%d0
	jlt .L901
	subq.l #1,%d3
	move.l %d3,sq+344
	jra .L897
.L901:
	mvz.w %d0,%d2
	lea sq+276,%a2
	sub.l %a1,%a1
	sub.l %d1,%a2
	lsl.l #4,%d2
.L900:
	move.l %a2,%d4
	add.l %d1,%d4
	move.l %d4,%a4
	addq.l #1,%a1
	move.b (%a4,%d2.l),(%a2)+
	moveq #16,%d4
	cmp.l %a1,%d4
	jne .L900
	move.b 1(%a0),(%a0)
	addq.l #1,%a0
	addq.l #1,%d0
	add.l #-16,%d1
	jra .L899
.L909:
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
.L904:
	move.l sq+272,%d0
	add.l %d4,%d0
	cmp.l sq+268.l,%d0
	jeq .L905
	moveq #14,%d0
	cmp.l %d4,%d0
	jeq .L905
	move.l sq+272,%d0
	moveq #31,%d1
	add.l %d4,%d0
	and.l %d1,%d0
	lsl.l #3,%d0
	cmp.l 12(%a6,%d0.l),%d5
	jeq .L906
.L905:
	move.b %d4,46(%sp)
	move.b #-9,(%a0)+
	sub.l %d2,%a0
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L908
	add.l %d4,sq+272
	addq.l #1,sq+372
	jra .L903
.L906:
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
	jra .L904
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
	jne .L930
	move.l pin+16,%d0
	move.l pin+12,%d1
	addq.l #1,pin+32
	move.l %d0,50(%sp)
	or.l 58(%sp),%d0
	or.l %d1,%d0
	jeq .L930
	move.l pin+20,%a1
	tst.l %a1
	jne .L932
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
.L932:
	clr.b %d4
	clr.b %d5
	sub.l %a0,%a0
	clr.l %d3
	move.l pin+8,%d2
	clr.l %d6
	move.l pin+48,%a6
	move.b %d4,63(%sp)
	move.b %d5,62(%sp)
.L946:
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
	jcs .L933
	move.l 58(%sp),%d5
	move.l %a4,%d7
	btst %d7,%d5
	jeq .L933
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
	jeq .L934
	move.l #128,(%a3)
	move.l #128,(%a2)
	move.l %a1,4(%a3)
	move.l %a1,4(%a2)
	tst.l %a5
	jeq .L935
	addq.l #1,pin+44
.L935:
	moveq #1,%d0
	and.l 54(%sp),%d2
	move.b %d0,62(%sp)
.L936:
	move.l 46(%sp),%a2
	add.l #-2147457816,%a2
	clr.l (%a2)
	cmp.l #32512,%d5
	jeq .L951
	cmp.l #255,%d5
	jls .L939
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
	jls .L940
	mvz.w #65535,%d4
.L940:
	mulu.w #32512,%d0
	move.w %d4,(%a3)
	divu.l %d5,%d0
	cmp.l #65535,%d0
	jls .L941
	mvz.w #65535,%d0
.L941:
	move.w %d0,(%a2)
.L939:
	moveq #1,%d0
	move.w #32512,(%a0)
	addq.l #1,%a6
	move.b %d0,63(%sp)
.L951:
	move.w #1,%a0
	jra .L938
.L934:
	tst.l %a5
	jeq .L937
	moveq #127,%d0
	moveq #127,%d4
	move.l %d0,(%a3)
	move.l pin+28,%d0
	move.l %d4,(%a2)
	move.l %d0,4(%a3)
	move.l %d0,4(%a2)
	jra .L936
.L937:
	moveq #1,%d4
	move.l pin+24,%d7
	move.l #1073741951,(%a3)
	move.l #1073741951,(%a2)
	move.l %d7,4(%a3)
	or.l %d0,%d2
	move.l %d7,4(%a2)
	addq.l #1,pin+40
	move.b %d4,62(%sp)
	jra .L936
.L933:
	move.l 50(%sp),%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L942
	move.l %d0,%d4
	not.l %d4
	and.l %d4,%d2
	moveq #1,%d4
	or.l %d0,%d1
	move.w #1,%a0
	move.b %d4,62(%sp)
.L942:
	move.l %d1,%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L938
	btst #6,(%a2)
	jeq .L944
	not.l %d0
	and.l %d0,%d1
	jra .L951
.L944:
	move.l #128,(%a3)
	move.l #128,(%a2)
	move.l %a1,4(%a3)
	move.l %a1,4(%a2)
.L938:
	addq.l #1,%d3
	moveq #8,%d5
	cmp.l %d3,%d5
	jne .L946
	tst.b 63(%sp)
	jeq .L947
	move.l %a6,pin+48
.L947:
	tst.b 62(%sp)
	jeq .L948
	move.l %d2,pin+8
.L948:
	move.w %a0,%d7
	tst.b %d7
	jeq .L949
	move.l %d1,pin+12
.L949:
	tst.l %d6
	jeq .L950
	addq.l #1,pin+36
.L950:
	move.l -66650100,%d0
	move.l %d6,pin+16
	sub.l 68(%sp),%d0
	cmp.l pin+52.l,%d0
	jls .L930
	move.l %d0,pin+52
.L930:
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
	jcc .L978
.L980:
	clr.l %d1
.L979:
	move.l %d1,16(%sp)
	move.l %a0,%d1
	mvz.b %d1,%d1
	clr.l 12(%sp)
	move.l %d0,4(%sp)
	move.l %d1,8(%sp)
	jra ed_queue
.L978:
	mvz.w #4368,%d1
	btst %d0,%d1
	jeq .L980
	mov3q.l #3,%d1
	and.l 12(%sp),%d1
	jra .L979
	.size	ed_report, .-ed_report
	.align	2
	.globl	pm_menu_add
	.type	pm_menu_add, @function
pm_menu_add:
	link.w %fp,#-68
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	tst.l 8(%fp)
	jeq .L984
	lea (-64,%fp),%a2
	clr.l %d0
	move.l %a2,%a0
.L986:
	clr.l 12(%a0)
	clr.l 8(%a0)
	clr.l (%a0)
	clr.l 4(%a0)
	addq.l #1,%d0
	lea (16,%a0),%a0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L986
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
	jeq .L984
	tst.l %a3
	jeq .L984
	tst.l -32(%fp)
	jeq .L984
	tst.l %d0
	jeq .L984
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
.L987:
	mvz.w -66(%fp),%d0
	lsl.l #4,%d0
	pea (%a2,%d0.l)
	jsr 1075251654
	subq.l #1,-68(%fp)
	addq.l #4,%sp
	mov3q.l #-1,%d0
	cmp.l -68(%fp),%d0
	jne .L987
	addq.l #1,pm+4
.L984:
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
	jcc .L1000
	addq.l #1,pm+24
	pea pm_t_track
.L1004:
	move.l %a0,-(%sp)
	jsr pm_popup
	addq.l #8,%sp
	rts
.L1000:
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L1002
	move.l commits,%d1
	cmp.l pm+28.l,%d1
	jne .L1003
.L1002:
	addq.l #1,pm+20
	pea pm_t_none
	jra .L1004
.L1003:
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
	jeq .L1005
	move.l 4(%sp),-(%sp)
	addq.l #1,cu+12
	jsr cu_src_setup
	move.l 8(%sp),%d0
	mov3q.l #2,%d1
	add.l #-48,%d0
	addq.l #4,%sp
	cmp.l %d0,%d1
	jcs .L1005
	moveq #11,%d0
	cmp.l 8(%sp),%d0
	jcs .L1005
	move.l #1075731444,%d1
	cmp.l sv+88.l,%d1
	jne .L1005
	lea (7,%sp),%a0
	move.b (%a0),cu+9
	lea (11,%sp),%a0
	move.b (%a0),cu+10
	lea st+8,%a0
	move.l (%a0),cu+16
.L1005:
	rts
	.size	cu_prep, .-cu_prep
	.align	2
	.globl	cu_mi_settling
	.type	cu_mi_settling, @function
cu_mi_settling:
	mvz.b cu+11,%d1
	move.l 4(%sp),%d0
	addq.l #1,%d0
	cmp.l %d1,%d0
	jne .L1009
	move.l st+8,%d0
	moveq #15,%d1
	sub.l cu+24,%d0
	cmp.l %d0,%d1
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1007:
	rts
.L1009:
	clr.l %d0
	jra .L1007
	.size	cu_mi_settling, .-cu_mi_settling
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
.L1011:
	mov3q.l #1,%d0
	cmp.l fp+20.l,%d0
	jeq .L1011
.L1012:
	mov3q.l #2,%d1
	cmp.l fp+20.l,%d1
	jeq .L1013
	move.l 1100667228,%d0
	cmp.l #cu_text,%d0
	jeq .L1014
	cmp.l 1100664624.l,%d0
	jne .L1014
	move.l #cu_text,%d2
	move.l %d2,1100667228
.L1014:
	tst.b cu.l
	jne .L1015
	move.l #1128813124,%d3
	cmp.l 1073849308.l,%d3
	jne .L1015
	pea 52.w
	move.l #cu_steps,%d5
	moveq #1,%d4
	move.l #cu_setup,%d6
	move.b %d4,cu
	jsr cu_src_setup
	move.l %d5,1073849316
	move.l %d6,1073849312
	addq.l #4,%sp
.L1015:
	move.l rx,%d2
	move.l #-66650100,%a0
	addq.l #1,st+8
	move.l (%a0),st+300
	tst.l st
	jne .L1016
	lea rui_sysex,%a1
	move.l %a1,1075551840
	move.l #1381321040,%a2
	move.l %a2,1075551836
	mov3q.l #1,st
	move.l %d2,st+16
.L1017:
	move.l #ux,%d5
	jra .L1204
.L1013:
	pea 10000.w
	jsr 1074367512
	addq.l #4,%sp
	jra .L1012
.L1016:
	tst.b host_close.l
	jeq .L1018
	clr.b %d0
	lea commits,%a0
	move.b %d0,host_close
	move.b %d0,host_open
	move.l (%a0),sv+12
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	addq.l #8,%sp
.L1018:
	tst.b host_open.l
	jeq .L1019
	clr.b %d0
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	move.b %d0,host_open
	jsr enter
	lea (12,%sp),%sp
.L1019:
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L1020
	move.l st+956,%d0
	cmp.l #65534,%d0
	jhi .L1021
	addq.l #1,%d0
	move.l %d0,st+956
	moveq #10,%d3
	cmp.l %d0,%d3
	jne .L1021
	moveq #1,%d4
	move.w #4095,%d5
	move.l %d2,st+964
	mov3q.l #1,st+960
	move.b %d4,st+992
	move.b %d4,mr+13
	move.b %d4,mr+19
	move.w %d5,ar+60
	jsr sq_forget
	lea commits,%a0
	move.l (%a0),pm+28
.L1022:
	tst.b st+992.l
	jne .L1026
.L1027:
	tst.l splash_req
	jeq .L1028
	move.l splash_req,%d0
	clr.l splash_req
	tst.l st+4
	jne .L1029
	moveq #127,%d1
	and.l %d1,%d0
	tst.l %d0
	jeq .L1030
	tst.l commits
	jne .L1031
.L1029:
	addq.l #1,st+984
.L1028:
	tst.l st+4
	jeq .L1033
	cmp.l st+16.l,%d2
	jeq .L1034
	clr.l st+12
.L1035:
	move.l %d2,st+16
	clr.b %d0
	move.l st+8,%a1
	lea st+408,%a0
	clr.l -184(%fp)
.L1041:
	move.l (%a0)+,%d1
	tst.l %d1
	jeq .L1039
	move.l %a1,%d3
	sub.l %d1,%d3
	jmi .L1039
	moveq #1,%d0
	clr.l -4(%a0)
.L1039:
	addq.l #1,-184(%fp)
	moveq #16,%d5
	cmp.l -184(%fp),%d5
	jne .L1041
	tst.b %d0
	jeq .L1042
	mov3q.l #1,st+344
.L1042:
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr sv_tick
	addq.l #8,%sp
	tst.b ls.l
	jeq .L1043
	tst.b sv.l
	jeq .L1044
	tst.b sv+8.l
	jeq .L1044
	move.l sv,%d0
	move.l ls,%d6
	eor.l %d6,%d0
	and.l #16776960,%d0
	or.l st+4,%d0
	jeq .L1043
.L1044:
	mov3q.l #5,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1043:
	move.l ls_in_gen,%d7
	cmp.l ls+48.l,%d7
	jeq .L1045
	move.l ls_in_v,%d1
	lea ls_in_gen,%a0
	move.l (%a0),ls+48
	tst.b ls.l
	jeq .L1045
	move.l %d1,%d0
	lsr.l #8,%d0
	mvz.b ls+1,%d2
	cmp.l %d0,%d2
	jne .L1045
	mov3q.l #1,%d0
	and.l %d1,%d0
	mov3q.l #1,ls+40
	move.l %d0,ls+36
.L1045:
	tst.l ls+36
	jeq .L1046
	tst.l ls+40
	jne .L1046
	move.l st+8,%d0
	moveq #20,%d1
	sub.l ls+44,%d0
	cmp.l %d0,%d1
	jcc .L1046
	clr.l ls+36
	addq.l #1,ls+56
.L1046:
	move.l u46+8,%d0
	tst.l %d0
	jeq .L1047
	tst.b ls.l
	jne .L1048
	tst.l st+4
	jne .L1048
	move.l st+8,%d1
	moveq #20,%d2
	sub.l %d0,%d1
	cmp.l %d1,%d2
	jcs .L1048
	move.l #1093765506,%a1
	moveq #11,%d3
	mvz.b (%a1),%d0
	cmp.l %d0,%d3
	jcs .L1048
	move.l -2147457096,%d0
	moveq #127,%d4
	mvz.b (%a1),%d1
	and.l %d4,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d0
	cmp.l u46+12.l,%d0
	jeq .L1049
.L1048:
	clr.l u46+8
.L1047:
	move.l pm,%d2
	tst.l %d2
	jeq .L1050
	clr.l pm
	add.l #31,%d2
	tst.b ls.l
	jeq .L1051
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1051:
	clr.l st+1038
	tst.l st+4
	jeq .L1052
	moveq #1,%d6
	mvz.w #256,%d5
	moveq #1,%d7
	move.b %d2,st+993
	addq.l #1,pm+16
	move.l %d5,st+296
	move.b %d6,st+161
	move.w %d7,st+162
.L1053:
	tst.l st+1058
	jne .L1055
	tst.l sv+96
	jne .L1056
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jeq .L1054
	lea st+8,%a0
	mov3q.l #1,st+1058
	mov3q.l #1,st+1062
	move.l (%a0),st+1066
	addq.l #1,st+1070
	addq.l #1,st+1090
.L1055:
	tst.l st+4
	jne .L1057
	clr.l st+1058
.L1058:
	tst.l st+972
	jne .L1062
	tst.b sv+8.l
	jne .L1062
.L1063:
	move.l st+1082,%d0
	tst.l %d0
	jeq .L1065
	sub.l st+8,%d0
	tst.l %d0
	jgt .L1066
	clr.l st+1082
.L1066:
	moveq #1,%d4
	move.b %d4,32(%a2)
.L1065:
	move.l sq_gen,%d0
	move.b 1093765506,%d2
	cmp.l sq+400.l,%d0
	jeq .L1067
	mov3q.l #1,%d1
	and.l %d0,%d1
	btst #0,%d0
	jne .L1067
	sub.l %a0,%a0
	lea sq_req,%a1
.L1068:
	lea (%a1,%a0.l),%a3
	mov3q.l #7,%d3
	lea (-140,%fp),%a2
	move.b (%a3),(%a2,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d3
	jne .L1068
	cmp.l sq_gen.l,%d0
	jne .L1067
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
	jeq .L1070
	move.l sq+4,%d1
.L1070:
	mvz.b -134(%fp),%d0
	mvz.b -135(%fp),%d4
	lsl.l #7,%d0
	or.l %d4,%d0
	and.l #4095,%d0
	or.l %d1,%d0
	move.l %d0,pin
	tst.l sq
	jeq .L1071
	btst #1,%d3
	jeq .L1072
.L1071:
	mvz.w #255,%d4
	mvz.w #8191,%d5
	addq.l #1,sq+452
	mov3q.l #1,ed+92
	move.l %d4,sq+404
	move.l %d5,ed+260
.L1072:
	mov3q.l #1,sq
.L1067:
	tst.l sq
	jne .L1073
	clr.l sq+408
.L1074:
	move.l st+4,%d0
	move.l led_gen,%d1
	or.l sq+408,%d0
	jeq .L1124
	tst.l sq+468
	jne .L1125
	lea led_gen,%a1
	move.l (%a1),st+1002
	lea pg_gen,%a2
	move.l #2139062143,%a3
	clr.l st+1006
	mov3q.l #1,sq+476
	move.l (%a2),sq+472
	move.l %a3,sq+480
.L1125:
	mov3q.l #1,sq+468
	cmp.l st+1002.l,%d1
	jeq .L1127
	btst #0,%d1
	jne .L1127
	move.b led_req_mode,%d2
	clr.l %d0
	lea led_req,%a1
	lea (-140,%fp),%a0
.L1128:
	lea (%a1,%d0.l),%a2
	moveq #16,%d3
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d3
	jne .L1128
	cmp.l led_gen.l,%d1
	jne .L1127
	mvz.b %d2,%d2
	move.l %d1,st+1002
	clr.l %d0
	lea st+1022,%a1
	move.l %d2,st+1006
.L1130:
	lea (%a0,%d0.l),%a2
	moveq #16,%d1
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1130
	moveq #1,%d2
	move.b %d2,led_owed
.L1127:
	mov3q.l #1,%d3
	cmp.l st+1006.l,%d3
	jne .L1126
	clr.l led_again
	tst.b ov_on.l
	jeq .L1135
	tst.b led_owed.l
	jeq .L1133
.L1135:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jeq .L1610
	clr.l %d0
	lea st+1022,%a2
	lea ov_col,%a0
.L1136:
	lea (%a2,%d0.l),%a1
	moveq #16,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1136
	moveq #1,%d2
	move.l %fp,%d3
	add.l #-140,%d3
	lea led_send4,%a3
	move.b %d2,ov_on
	clr.l %d2
.L1137:
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
	jne .L1137
	clr.b %d5
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #1,st+1010
	move.b %d5,led_owed
	jra .L1611
.L1021:
	move.l st+960,%d3
	move.l %d3,%d1
	subq.l #1,%d1
	lsr.l #1,%d1
	jne .L1022
	moveq #20,%d1
	moveq #20,%d5
	muls.l %d3,%d1
	cmp.l %d1,%d5
	seq %d1
	neg.l %d1
	tst.b %d1
	jeq .L1023
	moveq #30,%d1
.L1024:
	cmp.l %d1,%d0
	jne .L1022
	cmp.l st+964.l,%d2
	jne .L1025
	moveq #1,%d6
	move.w #4095,%d7
	addq.l #1,%d3
	move.l %d3,st+960
	move.b %d6,st+992
	move.b %d6,mr+13
	move.b %d6,mr+19
	move.w %d7,ar+60
.L1026:
	tst.b sv.l
	jeq .L1027
	moveq #1,%d0
	move.w #257,%a1
	lea sv+1,%a0
	move.b (%a0),sv+5
	move.b %d0,sv+4
	move.w %a1,sv+6
	jra .L1027
.L1023:
	moveq #50,%d1
	jra .L1024
.L1025:
	mov3q.l #3,st+960
	jra .L1022
.L1020:
	clr.b %d0
	clr.l st+956
	clr.l st+960
	clr.l ls_host_presets
	move.b %d0,st+992
	tst.l sq
	jeq .L1027
	jsr sq_forget
	jra .L1027
.L1030:
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr splash_end
	addq.l #8,%sp
	jra .L1028
.L1031:
	tst.l st+972
	jne .L1032
	mov3q.l #1,st+972
	addq.l #1,st+980
	mov3q.l #-1,st+20
	clr.l st+12
	mov3q.l #1,st+344
.L1032:
	move.l %d0,st+976
.L1033:
	tst.l st+972
	jeq .L1035
	cmp.l st+16.l,%d2
	jeq .L1036
	clr.l st+12
.L1037:
	move.l st+976,%d0
	subq.l #1,%d0
	move.l %d0,st+976
	tst.l %d0
	jne .L1035
	mov3q.l #1,-(%sp)
	jra .L1609
.L1034:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d3
	cmp.l %d0,%d3
	jcc .L1035
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	clr.l mask_set
.L1608:
	addq.l #8,%sp
	jra .L1035
.L1036:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d4
	cmp.l %d0,%d4
	jcc .L1037
	mov3q.l #3,-(%sp)
.L1609:
	move.l %a2,-(%sp)
	jsr splash_end
	jra .L1608
.L1049:
	tst.b sv.l
	jeq .L1047
	tst.b sv+8.l
	jeq .L1047
	mvz.b sv+1,%d2
	mvz.b (%a1),%d1
	cmp.l %d2,%d1
	jne .L1047
	mvz.b sv+2,%d1
	cmp.l %d0,%d1
	jne .L1047
	clr.l -(%sp)
	clr.l -(%sp)
	jsr ls_enc
	addq.l #8,%sp
	tst.l %d0
	jeq .L1047
	clr.l u46+8
	addq.l #1,u46+28
	jra .L1047
.L1052:
	mvz.b %d2,%d2
	move.l %d2,-(%sp)
	clr.l -(%sp)
	move.l %a2,-(%sp)
	jsr enter
	lea (12,%sp),%sp
	addq.l #1,pm+12
.L1050:
	tst.l st+4
	jne .L1053
.L1054:
	tst.l st+1058
	jne .L1055
.L1056:
	tst.l st+4
	jeq .L1058
.L1062:
	tst.l st+1058
	jne .L1063
	move.l commits,%d2
	cmp.l st+20.l,%d2
	jne .L1064
	tst.l st+344
	jeq .L1063
.L1064:
	moveq #1,%d3
	move.b %d3,32(%a2)
	jra .L1063
.L1057:
	move.l sv+88,%d0
	cmp.l #1075650164,%d0
	jeq .L1059
	move.l %d0,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jeq .L1060
.L1059:
	mov3q.l #1,st+1062
	jra .L1056
.L1060:
	tst.l st+1062
	jne .L1061
	move.l st+8,%d0
	moveq #20,%d1
	sub.l st+1066,%d0
	cmp.l %d0,%d1
	jcc .L1056
.L1061:
	clr.l st+1058
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
	jra .L1056
.L1073:
	mvz.b %d2,%d2
	lea sq_grid,%a2
	moveq #11,%d6
	cmp.l %d2,%d6
	jcs .L1075
	move.l sq+4,%d0
	btst %d2,%d0
	jne .L1076
.L1075:
	clr.l %d0
.L1077:
	cmp.l sq+408.l,%d0
	jne .L1078
	tst.l %d0
	jeq .L1079
	cmp.l sq+412.l,%d2
	jeq .L1079
.L1078:
	mov3q.l #1,%d7
	or.l %d7,sq+404
	move.l %d0,sq+408
	move.l %d2,sq+412
.L1079:
	move.b 1093615249,%d0
	move.b 1093615250,%d2
	moveq #127,%d3
	move.b 1079807236,%d1
	and.l %d3,%d1
	move.l sq+360,%d3
	btst #8,%d3
	jeq .L1080
	move.l %d1,%d0
	moveq #127,%d1
	and.l %d3,%d1
.L1081:
	cmp.l %d0,%d1
	jeq .L1313
.L1082:
	cmp.l sq+420.l,%d1
	jne .L1083
	cmp.l sq+424.l,%d0
	jeq .L1084
.L1083:
	mov3q.l #4,%d5
	or.l %d5,sq+404
	move.l %d1,sq+420
	move.l %d0,sq+424
.L1084:
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
	jne .L1085
	cmp.l sq+432.l,%d0
	jeq .L1086
.L1085:
	moveq #16,%d6
	or.l %d6,sq+404
	move.l %d2,sq+428
	move.l %d0,sq+432
.L1086:
	move.l 1076395164,%d0
	and.l #2097151,%d0
	cmp.l sq+436.l,%d0
	jeq .L1087
	moveq #32,%d7
	or.l %d7,sq+404
	move.l %d0,sq+436
.L1087:
	move.b 1081877443,%d0
	mvz.b 1081877444,%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #8191,%d0
	cmp.l sq+440.l,%d0
	jeq .L1088
	move.l %d0,sq+440
	moveq #8,%d0
	or.l %d0,sq+404
.L1088:
	move.b 1081877445,%d0
	mvz.b 1081877446,%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #8191,%d0
	cmp.l sq+552.l,%d0
	jeq .L1089
	mvz.w #128,%d1
	move.l %d0,sq+552
	or.l %d1,sq+404
.L1089:
	mov3q.l #1,%d3
	move.l 1079807120,%d2
	cmp.l %d2,%d3
	jne .L1090
	move.l st+8,%d0
	moveq #19,%d4
	sub.l sq+444,%d0
	cmp.l %d0,%d4
	jcc .L1090
	moveq #64,%d5
	or.l %d5,sq+404
.L1090:
	move.l sq+404,%d0
	btst #0,%d0
	jeq .L1091
	move.l sq+408,%d0
	move.b %d0,-140(%fp)
	tst.l %d0
	jeq .L1314
	move.b sq+415,%d0
.L1092:
	mov3q.l #2,-(%sp)
	pea -140(%fp)
	pea 8.w
	move.b %d0,-139(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1074
	moveq #-2,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1091:
	btst #1,%d0
	jeq .L1093
	mov3q.l #2,%d6
	cmp.l %d2,%d6
	jcc .L1315
	clr.l %d0
.L1094:
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
	jeq .L1074
	moveq #-3,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1093:
	move.w %d0,%ccr
	jne .L1095
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
	jeq .L1074
	moveq #-5,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1095:
	move.w %d0,%ccr
	jpl .L1096
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
	jeq .L1074
	moveq #-9,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1096:
	tst.b %d0
	jpl .L1097
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
	jeq .L1074
	move.l sq+404,%d0
	bclr #7,%d0
	move.l %d0,sq+404
.L1097:
	btst #4,%d0
	jeq .L1098
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
	jeq .L1074
	moveq #-17,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1098:
	btst #5,%d0
	jeq .L1099
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
	jeq .L1074
	moveq #-33,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1099:
	btst #6,%d0
	jeq .L1100
	move.l 1100784300,-(%sp)
	move.l %fp,%d3
	add.l #-140,%d3
	move.l %d3,-(%sp)
	jsr blk4
	addq.l #8,%sp
	mov3q.l #2,%d5
	cmp.l %d2,%d5
	jcc .L1101
	clr.l %d2
.L1101:
	move.b %d2,-136(%fp)
	moveq #127,%d6
	move.w 1079807124,%d0
	subq.l #1,%d0
	and.l %d6,%d0
	move.b %d0,-135(%fp)
	move.l sq+380,%d0
	cmp.l %d0,%d6
	jcc .L1102
	moveq #127,%d0
.L1102:
	mov3q.l #7,-(%sp)
	move.l %d3,-(%sp)
	pea 9.w
	move.b %d0,-134(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1074
	moveq #-65,%d7
	and.l %d7,sq+404
	lea st+8,%a0
	move.l (%a0),sq+444
.L1100:
	move.l sq+360,%d0
	btst #8,%d0
	jeq .L1103
	moveq #127,%d1
	and.l %d1,%d0
.L1104:
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
.L1110:
	move.l #85689,%d5
	moveq #12,%d0
	mvz.b (%a2,%d5.l),%d4
	cmp.l %d1,%d0
	jeq .L1105
	mvz.b (%a0),%d0
	move.b 2(%a0),%d3
.L1106:
	mvz.b %d3,%d3
	cmp.l (%a1),%d0
	jne .L1107
	cmp.l 52(%a1),%d3
	jne .L1107
	cmp.l 104(%a1),%d4
	jne .L1107
	moveq #12,%d2
	cmp.l %d1,%d2
	jne .L1108
	move.l #85685,%d2
	move.b (%a2,%d2.l),%d2
	move.l #85686,%a5
	mvz.b (%a2,%a5.l),%d5
	mvz.b %d2,%d2
	lsl.l #8,%d2
	or.l %d5,%d2
	cmp.l ed+256.l,%d2
	jeq .L1108
.L1107:
	move.l %d0,(%a1)
	moveq #12,%d0
	move.l %d3,52(%a1)
	move.l %d4,104(%a1)
	cmp.l %d1,%d0
	jne .L1109
	move.b (%a2,%d6.l),%d0
	mvz.b (%a2,%d7.l),%d2
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d2,%d0
	move.l %d0,ed+256
.L1109:
	tst.l -180(%fp)
	jeq .L1108
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	or.l %d0,ed+260
.L1108:
	addq.l #1,%d1
	addq.l #4,%a1
	lea (917,%a0),%a0
	moveq #13,%d2
	cmp.l %d1,%d2
	jne .L1110
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
	jeq .L1111
	move.l %d1,ed+272
	clr.l ed+268
	clr.l ed+372
.L1111:
	move.l ed+268,%d2
	move.l %d2,%d3
	addq.l #1,%d3
	move.l %d3,%d1
	moveq #10,%d4
	lsl.l %d4,%d1
	cmp.l %d0,%d1
	jls .L1316
	move.l %d2,%d1
	move.l %d0,%d5
	lsl.l %d4,%d1
	sub.l %d1,%d5
.L1112:
	move.l %d2,%d1
	moveq #12,%d6
	lsl.l %d6,%d1
	clr.l %d4
	add.l %d1,%a1
	clr.l %d1
.L1113:
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
	jne .L1113
	move.l ed+372,%d4
	move.l %d2,%a0
	lea (69,%a0),%a0
	btst %d2,%d4
	jeq .L1114
	cmp.l (%a4,%a0.l*4),%d1
	jeq .L1114
	mov3q.l #1,ed+376
.L1114:
	move.l %d1,(%a4,%a0.l*4)
	mov3q.l #1,%d1
	add.l #1023,%d0
	lsl.l %d2,%d1
	or.l %d4,%d1
	move.l %d1,ed+372
	moveq #10,%d1
	lsr.l %d1,%d0
	cmp.l %d3,%d0
	jhi .L1115
	clr.l %d3
.L1115:
	move.l %d3,ed+268
	move.l %fp,%d3
	clr.l %d2
	add.l #-172,%d3
.L1120:
	move.l ed+260,%d0
	btst %d2,%d0
	jeq .L1116
	moveq #12,%d5
	cmp.l %d2,%d5
	jne .L1317
	moveq #127,%d0
.L1117:
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
	jeq .L1318
	mov3q.l #5,%d0
.L1118:
	move.l %d0,-(%sp)
	move.l %d3,-(%sp)
	mov3q.l #4,-(%sp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1074
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	addq.l #1,ed+264
	not.l %d0
	and.l %d0,ed+260
.L1116:
	addq.l #1,%d2
	addq.l #4,%a3
	moveq #13,%d1
	cmp.l %d2,%d1
	jne .L1120
.L1121:
	move.l ed+68,%d0
	cmp.l ed+64.l,%d0
	jne .L1122
	tst.l ed+92
	jeq .L1123
	lea ed+91,%a0
	move.b (%a0),-172(%fp)
	mov3q.l #1,-(%sp)
	pea -172(%fp)
	pea 12.w
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1074
	clr.l ed+92
.L1123:
	tst.l ed+376
	jeq .L1074
	move.l st+8,%d0
	sub.l ed+380,%d0
	lsr.l #2,%d0
	jeq .L1074
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
	jeq .L1074
	lea st+8,%a0
	clr.l ed+376
	move.l (%a0),ed+380
	addq.l #1,ed+384
	jra .L1074
.L1076:
	jsr (%a2)
	jra .L1077
.L1080:
	mvz.b %d0,%d0
	mvz.b %d2,%d2
	moveq #127,%d4
	lsl.l #8,%d0
	or.l %d2,%d0
	cmp.l %d0,%d4
	jge .L1081
.L1313:
	moveq #127,%d0
	jra .L1082
.L1314:
	moveq #127,%d0
	jra .L1092
.L1315:
	move.l %d2,%d0
	jra .L1094
.L1103:
	move.b 1079807236,%d0
	moveq #127,%d2
	and.l %d2,%d0
	jra .L1104
.L1105:
	move.l #85683,%d2
	move.b (%a2,%d2.l),%d0
	move.l #85684,%d3
	move.l #85690,%d5
	mvz.b (%a2,%d3.l),%d2
	move.b (%a2,%d5.l),%d3
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d2,%d0
	jra .L1106
.L1316:
	mvz.w #1024,%d5
	jra .L1112
.L1317:
	move.l %d2,%d0
	jra .L1117
.L1318:
	mov3q.l #7,%d0
	jra .L1118
.L1122:
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
	jeq .L1074
	addq.l #1,ed+68
	addq.l #1,ed+76
	jra .L1121
.L1124:
	clr.l sq+468
	clr.l st+1006
.L1126:
	clr.b %d4
	move.b %d4,led_owed
	jsr led_restore
	move.l led_again,%d0
	tst.l %d0
	jeq .L1133
	tst.b ov_on.l
	jne .L1133
	move.l st+8,%d1
	sub.l %d0,%d1
	jmi .L1133
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1134
.L1610:
	addq.l #1,st+1018
.L1133:
	move.l sq+468,%d2
	move.l pg_gen,%d0
	mvz.b ovp_on,%d3
	tst.l %d2
	jeq .L1138
	cmp.l sq+472.l,%d0
	jeq .L1139
	btst #0,%d0
	jne .L1139
	move.b pg_req,%d5
	move.b pg_req+1,%d4
	move.b pg_req+2,%d2
	move.b pg_req+3,%d1
	cmp.l pg_gen.l,%d0
	jne .L1139
	move.b %d5,sq+480
	move.b %d4,sq+481
	move.b %d2,sq+482
	move.b %d1,sq+483
	move.l %d0,sq+472
	mov3q.l #1,sq+476
.L1139:
	clr.l %d2
	clr.l %d0
	lea sq+480,%a0
.L1141:
	mvz.b (%a0,%d0.l),%d4
	moveq #111,%d6
	cmp.l %d4,%d6
	jcs .L1140
	mov3q.l #1,%d4
	lsl.l %d0,%d4
	or.l %d4,%d2
.L1140:
	addq.l #1,%d0
	mov3q.l #4,%d7
	cmp.l %d0,%d7
	jne .L1141
.L1138:
	cmp.l %d3,%d2
	jne .L1142
	tst.l sq+476
	jeq .L1143
.L1142:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1320
	addq.l #1,st+1018
.L1143:
	tst.l st+4
	jeq .L1321
	tst.l st+1058
	seq %d2
	mvs.b %d2,%d2
	neg.l %d2
.L1151:
	move.l st+8,%d0
	moveq #10,%d3
	divu.l %d3,%d0
	btst #0,%d0
	jeq .L1322
	clr.b %d3
.L1152:
	mvz.b k44+24,%d0
	cmp.l %d2,%d0
	jne .L1153
	tst.l %d2
	jeq .L1154
	mvz.b k44+25,%d1
	mvz.b %d3,%d0
	cmp.l %d1,%d0
	jeq .L1154
.L1153:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1155
	addq.l #1,st+1018
.L1154:
	jsr flush
	move.b pc+79,%d2
	move.l pc_seq,%d1
	lea pc,%a2
	tst.b %d2
	jne .L1158
	btst #0,%d1
	jne .L1159
	cmp.l pc+72.l,%d1
	jeq .L1159
	clr.l %d0
	lea pc_req,%a0
	lea (-140,%fp),%a3
.L1160:
	lea (%a0,%d0.l),%a1
	mov3q.l #6,%d3
	move.b (%a1),(%a3,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d3
	jne .L1160
	cmp.l pc_seq.l,%d1
	jne .L1159
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
	jlt .L1162
	jsr 1075320104
	move.l %d0,-(%sp)
	jsr 1073963888
	addq.l #4,%sp
	tst.l %d0
	jne .L1163
.L1162:
	moveq #3,%d2
.L1164:
	move.b %d2,pc+78
	mvz.b %d2,%d2
	move.b %d3,pc+76
	add.l #42,%d2
	move.w (%a2,%d2.l*2),%d0
	addq.l #1,%d0
	move.w %d0,(%a2,%d2.l*2)
	moveq #1,%d0
	move.b %d0,pc+79
.L1158:
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
	jeq .L1159
	move.w pc+92,%d0
	clr.b %d1
	addq.l #1,%d0
	move.b %d1,pc+79
	move.w %d0,pc+92
.L1159:
	move.b st+992,%d0
	move.b st+161,%d1
	or.l %d1,%d0
	tst.b %d0
	jne .L1179
	jsr mr_tick
	tst.l %d0
	jeq .L1179
	tst.b sv+4.l
	jeq .L1180
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
	jeq .L1182
	clr.b %d0
	addq.l #1,sv+64
	move.b %d0,sv+4
.L1180:
	tst.b sv+102.l
	jeq .L1183
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
	jcc .L1184
	moveq #127,%d0
.L1184:
	move.b %d0,-159(%fp)
	clr.l %d0
	lea (-140,%fp),%a0
	lea (-172,%fp),%a1
.L1185:
	lea (%a1,%d0.l),%a2
	moveq #14,%d1
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1185
	moveq #-9,%d3
	pea 15.w
	move.l %a0,-(%sp)
	move.b %d3,-126(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1182
	clr.b %d4
	lea sv+100,%a0
	move.b (%a0),sv+101
	lea st+8,%a1
	move.l %d2,sv+104
	move.l (%a1),sv+108
	addq.l #1,sv+112
	move.b %d4,sv+102
.L1183:
	tst.b sv.l
	jeq .L1182
	mvz.b sv+1,%d0
	not.l %d0
	move.l %d0,-(%sp)
	jsr cu_steps
	addq.l #4,%sp
	tst.l %d0
	jne .L1182
	lea (-172,%fp),%a3
	clr.l %d3
	lea sv,%a4
	mov3q.l #-1,%d2
	move.l %a3,%a2
.L1191:
	mvz.b sv+1,%d0
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	jsr sv_word
	move.b sv+7,%d4
	addq.l #8,%sp
	move.w %d0,(%a3)
	tst.b %d4
	jne .L1187
	mvz.w %d0,%d1
	mvz.w 24(%a4),%d6
	cmp.l %d1,%d6
	jeq .L1188
.L1187:
	cmp.l -184(%fp),%d3
	jge .L1189
	move.l %d3,-184(%fp)
.L1189:
	move.l %d3,%d2
.L1188:
	mov3q.l #7,%d1
	cmp.l %d3,%d1
	jge .L1190
	tst.w %d0
	jeq .L1190
	mvz.b sv+1,%d0
	move.l %d0,-(%sp)
	jsr cu_mi_settling
	addq.l #4,%sp
	tst.l %d0
	jne .L1182
.L1190:
	addq.l #2,%a3
	addq.l #1,%d3
	addq.l #2,%a4
	moveq #16,%d0
	cmp.l %d3,%d0
	jne .L1191
	tst.b %d4
	jne .L1324
	mov3q.l #-1,%d1
	cmp.l %d2,%d1
	jne .L1192
.L1182:
	jsr arp_tick
.L1179:
	tst.l st
	jne .L1017
.L1201:
	mvz.b cu+9,%d2
	tst.l %d2
	jeq .L1230
	move.b cu+10,%d4
	moveq #127,%d0
	and.l -2147457096,%d0
	mvz.b %d4,%d6
	mulu.w #2531,%d0
	move.w %d6,%d1
	move.l %d0,%a0
	mulu.w #152,%d1
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d0
	cmp.l %d2,%d0
	jeq .L1231
	move.l st+8,%d0
	mov3q.l #4,%d3
	sub.l cu+16,%d0
	cmp.l %d0,%d3
	jcc .L1230
.L1234:
	clr.b %d4
	move.b %d4,cu+9
.L1230:
	tst.l st
	jeq .L1235
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L1236
	tst.l st+968
	jeq .L1236
	move.l dp,%d0
	move.b 1093765506,%d2
	tst.l %d0
	jeq .L1237
	move.w #18689,%d3
	moveq #1,%d4
	move.w #-2304,%d5
	pea 9.w
	move.l #-260222380,%d1
	pea -140(%fp)
	move.b %d0,-133(%fp)
	move.l %d1,-140(%fp)
	move.w %d3,-136(%fp)
	move.b %d4,-134(%fp)
	move.w %d5,-132(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1239
	clr.l dp
.L1237:
	tst.b k44+20.l
	jeq .L1240
	move.l k44+20,%d0
	and.l #16776960,%d0
	tst.l %d0
	jne .L1240
	tst.l st+4
	jeq .L1241
	tst.l st+1058
	jne .L1240
.L1241:
	move.l st+8,%d0
	sub.l k44,%d0
	lsr.l #3,%d0
	jeq .L1240
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	or.l ov_list,%d0
	jne .L1240
	tst.l st+4
	sne %d0
	move.w #257,%d7
	neg.l %d0
	move.b %d0,k44+26
	move.w %d7,k44+22
.L1240:
	move.b k44+23,%d0
	jeq .L1242
	tst.b k44+26.l
	seq %d1
	move.w #18689,%a1
	move.w #-2304,%d3
	pea 9.w
	move.l #-260222380,%a0
	pea -140(%fp)
	move.l %a0,-140(%fp)
	addq.l #5,%d1
	move.b %d1,-134(%fp)
	mov3q.l #1,%d1
	eor.l %d1,%d0
	move.w %a1,-136(%fp)
	move.w %d3,-132(%fp)
	tst.b %d0
	seq %d0
	neg.l %d0
	move.b %d0,-133(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1239
	mvz.b k44+23,%d0
	tst.b k44+26.l
	jeq .L1245
	mov3q.l #1,%d4
	cmp.l %d0,%d4
	jne .L1246
	addq.l #1,k44+28
.L1247:
	clr.b %d0
	move.b %d0,k44+23
.L1242:
	mvz.b %d2,%d1
	moveq #11,%d3
	cmp.l %d1,%d3
	jcs .L1239
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
	jeq .L1250
	clr.b %d6
	move.l %d0,dp+8
	move.b %d6,dp+22
.L1251:
	moveq #52,%d7
	cmp.l %d4,%d7
	jcs .L1327
	move.b %d5,%d0
	move.l #1075572644,%a0
	ext.w %d0
	mvz.w %d0,%d0
	lsl.l #3,%d0
	move.l (%a0,%d0.l),%a0
.L1253:
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
	jeq .L1328
	move.l %a0,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	sls %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1254:
	clr.l %d1
	lea (-140,%fp),%a1
.L1256:
	tst.l %d0
	jeq .L1613
	move.b (%a0,%d1.l),%d6
	move.l %d6,%d7
	subq.l #1,%d7
	mvz.b %d7,%d7
	move.l %d7,%a2
	moveq #125,%d7
	cmp.l %a2,%d7
	jcs .L1330
.L1255:
	move.b %d6,9(%a1,%d1.l)
	addq.l #1,%d1
	moveq #12,%d6
	cmp.l %d1,%d6
	jne .L1256
	moveq #-9,%d7
	pea 22.w
	move.l %a1,-(%sp)
	move.b %d7,-119(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1239
	move.w #257,%a0
	move.b %d2,dp+20
	move.b %d5,dp+21
	addq.l #1,dp+12
	move.w %a0,dp+22
	jra .L1252
.L1134:
	jsr led_stock
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.l led_again
.L1611:
	addq.l #4,%sp
	jra .L1133
.L1320:
	clr.l %d0
	lea sq+480,%a0
	lea ovp_col,%a1
.L1144:
	btst %d0,%d2
	jeq .L1145
	lea (%a0,%d0.l),%a2
	move.b (%a2),(%a1,%d0.l)
.L1145:
	addq.l #1,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L1144
	move.l %d3,%d4
	clr.l %d3
	move.b %d2,ovp_on
	or.l %d2,%d4
	lea shp,%a2
	lea sq+480,%a4
	lea (-140,%fp),%a3
	lea rui_uart_raw,%a5
.L1150:
	btst %d3,%d4
	jeq .L1146
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
.L1149:
	tst.l %d0
	jeq .L1147
	move.b (%a4,%d3.l),%d1
.L1148:
	move.b %d1,2(%a3,%a0.l)
	addq.l #1,%a0
	mov3q.l #4,%d7
	cmp.l %a0,%d7
	jne .L1149
	move.l %a3,-(%sp)
	mov3q.l #6,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
.L1146:
	addq.l #1,%d3
	addq.l #4,%a2
	mov3q.l #4,%d0
	cmp.l %d3,%d0
	jne .L1150
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.l sq+476
	addq.l #4,%sp
	jra .L1143
.L1147:
	move.b (%a2,%a0.l),%d1
	jra .L1148
.L1321:
	clr.l %d2
	jra .L1151
.L1322:
	moveq #111,%d3
	jra .L1152
.L1155:
	move.b %d3,ovt_col
	move.b %d2,%d4
	move.b %d2,ovt_on
	lea led_send4,%a0
	tst.l %d2
	jeq .L1156
	move.b %d3,-137(%fp)
	move.b %d3,-138(%fp)
	move.b %d3,-139(%fp)
	move.b %d3,-140(%fp)
	pea -140(%fp)
	pea 55.w
	jsr (%a0)
	addq.l #1,k44+12
.L1612:
	addq.l #4,%sp
	move.l #1100088672,(%sp)
	jsr 1073746414
	addq.l #4,%sp
	move.b %d4,k44+24
	move.b %d3,k44+25
	jra .L1154
.L1156:
	pea sht
	pea 55.w
	jsr (%a0)
	addq.l #1,k44+16
	jra .L1612
.L1163:
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
	jeq .L1162
	tst.b 60(%a2,%d5.l)
	jeq .L1165
	move.l st+8,%d0
	moveq #20,%d1
	sub.l (%a2,%d5.l*4),%d0
	cmp.l %d0,%d1
	jcc .L1166
.L1165:
	moveq #1,%d2
	jra .L1164
.L1166:
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
	jeq .L1162
	move.l (%a5),%a0
	move.l %a5,-(%sp)
	move.l 40(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l 32(%a5),%a1
	move.l %d0,-180(%fp)
	tst.l %a1
	jeq .L1167
	move.l %a1,%d5
	move.l %a1,%a0
	add.l #4752,%d5
	clr.l %d1
.L1171:
	mvz.b (%a0),%d6
	cmp.l #255,%d6
	jeq .L1169
	mvz.b 1(%a0),%d6
	cmp.l #255,%d6
	jeq .L1169
	addq.l #1,%d1
.L1169:
	lea (66,%a0),%a0
	cmp.l %d5,%a0
	jne .L1171
	mulu.w #5674,%d4
	mvz.b %d3,%d0
	move.l #1075599904,%a5
	add.l -180(%fp),%d4
.L1176:
	mvz.b 3(%a5),%d6
	move.l %a1,%a0
.L1174:
	mvz.b (%a0),%d7
	cmp.l %d7,%d6
	jne .L1172
	mvz.b 1(%a0),%d7
	cmp.l %d0,%d7
	jeq .L1173
.L1172:
	lea (66,%a0),%a0
	cmp.l %d5,%a0
	jne .L1174
	move.l %d4,%a0
	tst.b 5653(%a0)
	jne .L1310
	mov3q.l #1,%a0
	jra .L1311
.L1310:
	mov3q.l #2,%a0
.L1311:
	add.l %a0,%d1
	moveq #71,%d6
	cmp.l %d1,%d6
	jlt .L1323
.L1173:
	addq.l #4,%a5
	addq.l #1,%d4
	cmp.l #1075599920,%a5
	jne .L1176
.L1167:
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
.L1177:
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
	jne .L1177
	jra .L1164
.L1323:
	moveq #2,%d2
	jra .L1164
.L1324:
	clr.l -184(%fp)
	moveq #15,%d2
.L1192:
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
.L1193:
	cmp.l %d2,%d0
	jle .L1194
	cmp.l -184(%fp),%d1
	sge %d1
	move.l %d1,%d0
	neg.l %d0
	tst.b %d0
	jeq .L1195
	move.l %d2,%d0
	sub.l -184(%fp),%d0
	add.l %d0,%d0
	add.l #11,%d0
.L1196:
	moveq #-9,%d5
	lea (%fp,%d0.l),%a1
	neg.l %d1
	move.b %d5,-140(%a1)
	tst.b %d1
	jeq .L1197
	move.l %d2,%d0
	addq.l #6,%d0
	sub.l -184(%fp),%d0
	add.l %d0,%d0
.L1198:
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1182
	lea sv+24,%a0
.L1199:
	cmp.l -184(%fp),%d2
	jge .L1200
	clr.b %d2
	addq.l #1,sv+68
	move.b %d2,sv+7
	jra .L1182
.L1194:
	move.w (%a2,%d0.l*2),%d3
	addq.l #1,%d0
	addq.l #2,%a1
	move.l %d3,%d4
	lsr.l #7,%d4
	move.b %d4,-2(%a1)
	moveq #127,%d4
	and.l %d4,%d3
	move.b %d3,-1(%a1)
	jra .L1193
.L1195:
	moveq #9,%d0
	jra .L1196
.L1197:
	moveq #10,%d0
	jra .L1198
.L1200:
	move.l -184(%fp),%d1
	lea (%a2,%d1.l*2),%a3
	move.w (%a3),(%a0,%d1.l*2)
	addq.l #1,%d1
	move.l %d1,-184(%fp)
	jra .L1199
.L1205:
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
	jeq .L1201
	move.l ux+3944,%d1
	mov3q.l #1,%d0
	lea ux+3920,%a0
.L1202:
	cmp.l %d0,%d1
	jhi .L1203
	subq.l #1,%d1
	move.l %d1,ux+3944
	addq.l #1,ux+32
.L1204:
	tst.l ux+3944
	jne .L1205
.L1206:
	move.l ux+3880,%d1
	cmp.l ux+3884.l,%d1
	jeq .L1201
	mov3q.l #7,%d2
	cmp.l ux+3944.l,%d2
	jcs .L1201
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
	jle .L1325
	mvz.b 2(%a2),%d2
	mvz.b 3(%a2),%d0
	lsl.l #8,%d2
	add.l %d0,%d0
	or.l %d0,%d2
	mov3q.l #7,%d0
	cmp.l %a1,%d0
	jlt .L1208
	move.l %a3,%d0
	add.l #-46,%d0
	mvz.b %d0,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jcc .L1209
	moveq #52,%d0
	cmp.l %a5,%d0
	jne .L1210
.L1209:
	cmp.l 1075595760.l,%a5
	jne .L1211
.L1210:
	tst.l %a1
	jne .L1213
.L1214:
	move.l %a0,%d1
	mov3q.l #7,%d0
	and.l %d0,%d1
	move.l %d5,%a0
	add.l %d1,%a0
	move.b 3952(%a0),%d0
	btst #0,%d0
	jeq .L1213
	move.l ls+60,%d0
	or.l ls+64,%d0
	jeq .L1213
	cmp.l ls+68.l,%d3
	jne .L1213
	move.l st+8,%d0
	moveq #20,%d1
	sub.l ls+72,%d0
	cmp.l %d0,%d1
	jcs .L1213
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
	jeq .L1213
	move.l (%a5),%a0
	move.l %a5,-(%sp)
	move.l 40(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l 32(%a5),%d0
	tst.l %d0
	jeq .L1215
	move.l %d0,%a0
	add.l #4753,%d0
	move.l %d0,-180(%fp)
	move.w %a3,%d0
	addq.l #1,%a0
	sub.l %a4,%a4
	sub.l %a1,%a1
	mvz.b %d0,%d0
	move.l %d0,%a3
.L1220:
	mvz.b -1(%a0),%d1
	cmp.l #255,%d1
	jeq .L1217
	mvz.b (%a0),%d0
	cmp.l #255,%d0
	jeq .L1217
	addq.l #1,%a1
.L1217:
	cmp.l %d1,%a3
	jne .L1219
	mvz.b (%a0),%d1
	move.l %a4,%d0
	cmp.l %d1,%d3
	seq %d1
	mvs.b %d1,%d1
	neg.l %d1
	or.l %d1,%d0
	move.l %d0,%a4
.L1219:
	lea (66,%a0),%a0
	cmp.l -180(%fp),%a0
	jne .L1220
	tst.l %a4
	jne .L1215
	moveq #69,%d1
	cmp.l %a1,%d1
	jlt .L1221
.L1215:
	move.l %a2,-(%sp)
	moveq #64,%d3
	jsr 1074529464
	addq.l #4,%sp
	move.l %d0,%a3
	cmp.l %d0,%d3
	jge .L1222
	move.w #64,%a3
.L1222:
	clr.l %d3
.L1223:
	cmp.l %a3,%d3
	jlt .L1227
	moveq #4,%d0
	clr.l ls+64
	clr.l ls+60
	addq.l #1,ux+3960
.L1228:
	move.l ux+3944,%a0
	lea (%a0,%a0.l*2),%a1
	addq.l #1,%a0
	move.l %a0,ux+3944
	addq.l #1,ux+3884
	add.l %d5,%a1
	move.b %d7,3920(%a1)
	move.b %d6,3921(%a1)
	move.b %d0,3922(%a1)
	jra .L1206
.L1203:
	addq.l #3,%a0
	move.b (%a0),-3(%a0)
	move.b 1(%a0),-2(%a0)
	move.b 2(%a0),-1(%a0)
	addq.l #1,%d0
	jra .L1202
.L1208:
	move.l %a5,%d0
	mov3q.l #2,%d1
	add.l #-48,%d0
	cmp.l %d0,%d1
	jcs .L1212
	mvz.b cu+1,%d0
	cmp.l %a5,%d0
	jne .L1211
.L1213:
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
	jra .L1228
.L1212:
	moveq #10,%d0
	cmp.l %a1,%d0
	jne .L1213
	moveq #45,%d1
	cmp.l %a5,%d1
	jeq .L1214
	jra .L1213
.L1227:
	moveq #31,%d0
	cmp.l %d3,%d0
	jlt .L1224
	move.l ls+60,%d1
	lsr.l %d3,%d1
.L1225:
	btst #0,%d1
	jeq .L1226
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	move.l %d4,-(%sp)
	move.l %d3,-(%sp)
	move.l %a2,-(%sp)
	jsr 1074529568
	lea (20,%sp),%sp
	addq.l #1,ls+96
.L1226:
	addq.l #1,%d3
	jra .L1223
.L1224:
	move.l %d3,%d0
	add.l #-32,%d0
	move.l ls+64,%d1
	lsr.l %d0,%d1
	jra .L1225
.L1221:
	moveq #3,%d0
	addq.l #1,ux+3964
.L1207:
	addq.l #1,ux+24
	jra .L1228
.L1211:
	moveq #1,%d0
	jra .L1207
.L1325:
	moveq #2,%d0
	jra .L1207
.L1231:
	move.l #1075731444,%d5
	cmp.l sv+88.l,%d5
	jeq .L1230
	move.l st+8,%d0
	sub.l cu+16,%d0
	lsr.l #1,%d0
	jeq .L1230
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	move.l %d0,%a2
	tst.l %d0
	jeq .L1230
	move.l %d2,-(%sp)
	moveq #17,%d3
	jsr cu_setup
	lea (11,%a2),%a2
	addq.l #4,%sp
.L1233:
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr 1073770536
	addq.l #8,%sp
	move.l %d0,%d5
	tst.l %d0
	jle .L1232
	mvz.b (%a2),%d7
	move.l %d3,-(%sp)
	move.l %d6,-(%sp)
	lsl.l #8,%d7
	move.l %d7,-(%sp)
	jsr 1074918394
	jsr 1075398168
	move.l %d7,-(%sp)
	move.l %d5,-(%sp)
	move.l %d6,-(%sp)
	move.l %d0,-(%sp)
	jsr 1073952092
	lea (28,%sp),%sp
.L1232:
	addq.l #1,%d3
	lea (14,%a2),%a2
	moveq #25,%d0
	cmp.l %d3,%d0
	jne .L1233
	addq.l #1,cu+20
	moveq #50,%d1
	cmp.l %d2,%d1
	jne .L1234
	addq.l #1,%d4
	lea st+8,%a0
	move.b %d4,cu+11
	move.l (%a0),cu+24
	jra .L1234
.L1246:
	addq.l #1,k44+32
.L1248:
	subq.l #2,%d0
	tst.l %d0
	jne .L1247
	clr.b %d7
	move.b %d7,k44+26
	jra .L1247
.L1245:
	mov3q.l #1,%d5
	cmp.l %d0,%d5
	jne .L1249
	addq.l #1,k44+4
	jra .L1247
.L1249:
	addq.l #1,k44+8
	jra .L1248
.L1250:
	tst.b dp+22.l
	jeq .L1251
	mvz.b dp+20,%d0
	cmp.l %d1,%d0
	jne .L1251
	mvz.b dp+21,%d0
	cmp.l %d4,%d0
	jne .L1251
.L1252:
	add.l #1092966707,%d3
	lea dp,%a4
	sub.l %a3,%a3
	move.l %d3,-180(%fp)
	lea dp+32,%a2
	move.l %a4,%a5
.L1263:
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
	jgt .L1257
	clr.l -172(%fp)
.L1258:
	mvz.b 24(%a5),%d7
	move.b -172(%fp),%d6
	move.b -171(%fp),%d5
	move.b -170(%fp),%d1
	move.b -169(%fp),%d0
	cmp.l %d3,%d7
	jne .L1261
	mvs.b (%a2),%d7
	move.l %d7,%a1
	mvs.b %d6,%d7
	cmp.l %a1,%d7
	jne .L1261
	mvs.b 1(%a2),%d7
	move.l %d7,%a1
	mvs.b %d5,%d7
	cmp.l %a1,%d7
	jne .L1261
	mvs.b 2(%a2),%d7
	move.l %d7,%a1
	mvs.b %d1,%d7
	cmp.l %a1,%d7
	jne .L1261
	mvs.b 3(%a2),%d7
	move.l %d7,%a1
	mvs.b %d0,%d7
	cmp.l %a1,%d7
	jeq .L1262
.L1261:
	move.b %d3,24(%a5)
	move.b %d0,3(%a2)
	moveq #1,%d0
	move.b %d6,(%a2)
	move.b %d5,1(%a2)
	move.b %d1,2(%a2)
	move.b %d0,dp+23
.L1262:
	addq.l #1,%a3
	addq.l #4,%a2
	addq.l #1,%a5
	moveq #8,%d1
	cmp.l %a3,%d1
	jne .L1263
	tst.b dp+23.l
	jeq .L1239
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
.L1265:
	move.b (%a2)+,(%a1)
	mov3q.l #1,%a0
.L1264:
	lea 31(%a4,%a0.l),%a3
	mov3q.l #5,%d2
	move.b (%a3),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d2
	jne .L1264
	addq.l #5,%a1
	addq.l #5,%d0
	addq.l #4,%a4
	moveq #49,%d3
	cmp.l %d0,%d3
	jne .L1265
	moveq #-9,%d4
	pea 49.w
	move.l %d1,-(%sp)
	move.b %d4,-92(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1239
	clr.b %d5
	addq.l #1,dp+16
	move.b %d5,dp+23
.L1239:
	tst.l st
	jeq .L1235
.L1236:
	mov3q.l #1,%d6
	cmp.l 1094562388.l,%d6
	jne .L1235
	tst.l st+968
	jeq .L1235
	move.b 1079807565,%d2
	mvs.b %d2,%d0
	lsr.l #7,%d0
	jne .L1332
	addq.l #1,%d2
.L1266:
	move.l pj+160,%d0
	cmp.l pj+156.l,%d0
	jeq .L1270
	move.l pj+156,%d3
	sub.l %d0,%d3
	clr.l -(%sp)
	move.l %d3,%d0
	cmp.l #16383,%d3
	jls .L1268
	mvz.w #16383,%d0
.L1268:
	move.l %d0,-(%sp)
	mov3q.l #6,-(%sp)
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1300
	moveq #2,%d0
	add.l %d3,pj+160
	move.w %d0,pj+180
.L1270:
	move.l pj,%d1
	cmp.l pj+4.l,%d1
	jne .L1271
	tst.b pj+139.l
	jeq .L1272
	mvz.b pj+138,%d1
	mvz.b %d2,%d0
	cmp.l %d1,%d0
	jeq .L1273
.L1272:
	clr.l %d0
.L1274:
	move.l #1081903571,%a0
	lea pj-1081903431,%a1
.L1275:
	tst.l %d0
	jne .L1277
.L1278:
	move.l st+968,%d6
	cmp.l pj+164.l,%d6
	jeq .L1295
	moveq #2,%d7
	move.w %d7,pj+180
.L1295:
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
.L1296:
	move.l #1081903571,%a2
	add.l %a0,%a2
	tst.b (%a2)
	jeq .L1297
	move.b (%a2),%d0
	moveq #127,%d1
	moveq #15,%d3
	and.l %d1,%d0
	move.b %d0,9(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d3
	jne .L1296
.L1297:
	moveq #-9,%d4
	lea (%fp,%a0.l),%a2
	move.b %d4,-131(%a2)
	pea 10(%a0)
	move.l %a1,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1300
	moveq #1,%d5
	move.b %d2,pj+138
	lea st+968,%a0
	lea st+8,%a1
	move.l (%a0),pj+164
	move.l (%a1),pj+168
	move.l #1081903571,%a0
	lea pj-1081903431,%a1
	move.b %d5,pj+139
.L1299:
	move.b (%a0),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L1299
	addq.l #1,pj+176
	jra .L1300
.L1327:
	sub.l %a0,%a0
	jra .L1253
.L1328:
	clr.l %d0
	jra .L1254
.L1330:
	clr.l %d0
.L1613:
	clr.b %d6
	jra .L1255
.L1257:
	moveq #52,%d1
	muls.l %d1,%d0
	move.l #1075575112,%a0
	move.l (%a0,%d0.l),%d6
	clr.l -172(%fp)
	move.l %d6,%d0
	sub.l %a0,%a0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L1258
.L1259:
	moveq #125,%d5
	move.b (%a0,%d6.l),%d1
	move.l %d1,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d5
	jcs .L1258
	lea (-172,%a0),%a1
	mov3q.l #4,%d0
	move.b %d1,(%a1,%fp.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L1259
	jra .L1258
.L1332:
	clr.b %d2
	jra .L1266
.L1271:
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
	jeq .L1300
	addq.l #1,pj+4
	addq.l #1,pj+172
	jra .L1270
.L1273:
	move.l st+968,%d3
	cmp.l pj+164.l,%d3
	jne .L1272
	move.l st+8,%d0
	moveq #99,%d4
	sub.l pj+168,%d0
	cmp.l %d0,%d4
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L1274
.L1277:
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
	jne .L1275
	mvz.b %d3,%d3
	mvz.b %d1,%d1
	cmp.l %d3,%d1
	jne .L1278
	tst.b pj+181.l
	jeq .L1300
	move.l 1100949640,%d0
	mov3q.l #3,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L1279
	move.l %d0,%d1
	add.l #-1073741824,%d1
	cmp.l #129892351,%d1
	jhi .L1279
	move.l %d0,%a0
	add.l #1073744908,%d1
	lea (12,%a0),%a0
	move.l %a0,%a1
.L1282:
	mvz.b (%a1),%d0
	lsr.l #1,%d0
	jeq .L1280
.L1279:
	mvz.w #16383,%d0
	clr.l %d3
.L1281:
	clr.l -(%sp)
	move.l %d0,-(%sp)
	pea 9.w
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1300
	addq.l #1,pj+184
	tst.l %d3
	jeq .L1286
	move.b pj+181,%d0
	mvz.b %d0,%d1
	lsr.l #1,%d1
	jeq .L1286
	clr.b %d7
	subq.l #1,%d0
	move.b %d0,pj+181
	move.b %d7,pj+180
.L1300:
	tst.l st
	jeq .L1304
	mov3q.l #1,%d3
	cmp.l 1094562388.l,%d3
	jne .L1304
	tst.l st+968
	jeq .L1304
	move.l st+44,%d1
	move.l txsx_over,%d0
	cmp.l kd_drop.l,%d1
	jne .L1305
	cmp.l kd_over.l,%d0
	jeq .L1304
.L1305:
	move.l st+8,%a0
	moveq #19,%d4
	sub.l kd_t,%a0
	cmp.l %a0,%d4
	jcc .L1304
	cmp.l #16383,%d1
	jls .L1307
	mvz.w #16383,%d1
.L1307:
	cmp.l #16383,%d0
	jls .L1308
	mvz.w #16383,%d0
.L1308:
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
	jeq .L1304
	lea st+44,%a0
	lea txsx_over,%a1
	lea st+8,%a2
	move.l (%a0),kd_drop
	move.l (%a1),kd_over
	move.l (%a2),kd_t
.L1304:
	move.l -66650100,%d0
	sub.l -176(%fp),%d0
	addq.l #1,st+336
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L1010
	move.l %d0,st+332
.L1010:
	movem.l -228(%fp),#15612
	unlk %fp
	rts
.L1280:
	lea (24,%a1),%a1
	cmp.l %d1,%a1
	jne .L1282
	move.b pj+180,%d0
	move.l %a0,%d3
	tst.b %d0
	jge .L1283
	clr.l %d0
.L1284:
	tst.b (%a0)
	sne %d2
	lea (24,%a0),%a0
	mvs.b %d2,%d2
	sub.l %d2,%d0
	cmp.l %d1,%a0
	jne .L1284
	jra .L1281
.L1286:
	clr.b %d0
	move.b %d0,pj+181
	jra .L1300
.L1283:
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
.L1294:
	mvz.b pj+180,%d0
	sub.l %a3,%a3
	add.l %d1,%d0
	muls.w #24,%d0
	lea (%a0,%d0.l),%a1
	tst.b (%a1)
	sne %d0
	neg.l %d0
	move.b %d0,(%a2)
.L1288:
	move.b (%a1),%d0
	jeq .L1287
	move.b 8(%a1,%a3.l),%d0
	moveq #127,%d5
	and.l %d5,%d0
.L1287:
	addq.l #1,%a3
	move.b %d0,(%a2,%a3.l)
	moveq #15,%d6
	cmp.l %a3,%d6
	jne .L1288
	sub.l %a1,%a1
.L1289:
	move.l %a1,%a3
	addq.l #1,%a1
	tst.b (%a2,%a1.l)
	jne .L1291
.L1292:
	moveq #15,%d3
	cmp.l %a3,%d3
	jeq .L1290
	clr.b %d0
	addq.l #1,%a3
	move.b %d0,(%a2,%a3.l)
	jra .L1292
.L1291:
	moveq #15,%d7
	cmp.l %a1,%d7
	jne .L1289
.L1290:
	addq.l #1,%d1
	lea (16,%a2),%a2
	moveq #8,%d4
	cmp.l %d1,%d4
	jne .L1294
	moveq #-9,%d5
	pea 139.w
	move.l %d2,-(%sp)
	move.b %d5,-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1300
	move.b pj+180,%d0
	addq.l #8,%d0
	move.b %d0,pj+180
	jra .L1300
.L1235:
	lea pj,%a0
	move.l (%a0),%d0
.L1301:
	cmp.l pj+4.l,%d0
	jeq .L1300
	moveq #31,%d1
	moveq #10,%d2
	and.l pj+4,%d1
	mvz.b 8(%a0,%d1.l*4),%d1
	cmp.l %d1,%d2
	jeq .L1302
	addq.l #1,pj+156
.L1302:
	addq.l #1,pj+4
	jra .L1301
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
	jeq .L1615
	sub.l st+8,%d0
	tst.l %d0
	jgt .L1616
.L1615:
	clr.l 44(%sp)
.L1617:
	move.l 16(%a2),%a2
	move.l %a2,52(%sp)
	tst.l st+4
	jne .L1619
	tst.l st+972
	jne .L1620
	tst.b sv+8.l
	jne .L1620
	tst.l 44(%sp)
	jeq .L1622
	jra .L1654
.L1616:
	move.l %d3,%a0
	move.l %d3,%d0
	addq.l #6,%a0
	lea (108,%sp),%a1
	add.l #566,%d0
.L1618:
	move.b 1(%a0),(%a1)
	addq.l #8,%a0
	move.b -8(%a0),1(%a1)
	addq.l #2,%a1
	cmp.l %a0,%d0
	jne .L1618
	mov3q.l #1,44(%sp)
	jra .L1617
.L1619:
	tst.l st+1058
	jne .L1622
	move.l commits,%a6
	cmp.l st+24.l,%a6
	jne .L1624
	move.l 52(%sp),%a0
	move.l %a0,%d0
	add.l #1024,%d0
.L1625:
	clr.l (%a0)+
	cmp.l %a0,%d0
	jne .L1625
	move.l %a6,st+20
.L1626:
	tst.l 44(%sp)
	jeq .L1622
	tst.l st+4
	jne .L1650
	tst.l st+972
	jne .L1651
.L1654:
	tst.b sv+8.l
	jne .L1651
.L1622:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 60(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L1614
	move.l %d0,st+332
.L1614:
	movem.l (%sp),#31996
	lea (248,%sp),%sp
	rts
.L1620:
	move.l commits,%a6
.L1624:
	cmp.l st+340.l,%a6
	jne .L1627
	tst.l st+344
	jeq .L1628
.L1627:
	move.l -66650100,%d2
	move.l sh_seq,%d4
	lea copy32,%a2
	move.l %d2,64(%sp)
	btst #0,%d4
	jne .L1629
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
	jne .L1629
	tst.l st+872
	jne .L1630
	clr.l -(%sp)
	pea comp
	pea 64.w
	pea 128.w
	pea st+872
	jsr 1074198978
	lea (20,%sp),%sp
.L1630:
	lea (tl.0),%a2
	clr.l %d5
.L1643:
	tst.b 4(%a2)
	jeq .L1631
	move.l %a2,%d4
	clr.l %d7
	addq.l #8,%d4
	lea st+408,%a5
	lea st+552,%a0
.L1642:
	tst.l (%a5)+
	jeq .L1633
	mvz.b (%a0),%d0
	cmp.l %d0,%d5
	jne .L1633
	lea st+472,%a1
	mvz.b 5(%a0),%d1
	mvz.b (%a1,%d7.l),%d4
	lea (6,%a0),%a3
	sub.l %a1,%a1
.L1635:
	cmp.l %d1,%a1
	jlt .L1636
	move.b 4(%a0),%d0
	lea 72(%sp,%d1.l),%a3
	btst #1,%d0
	jeq .L1655
	move.l %d4,%d0
	add.l #-64,%d0
	move.l %d0,56(%sp)
	tst.l %d0
	jle .L1638
	move.b #43,(%a3)
	addq.l #1,%d1
	lea 72(%sp,%d1.l),%a3
.L1656:
	sub.l %a1,%a1
	jra .L1637
.L1636:
	lea (%a3,%a1.l),%a4
	move.b (%a4),72(%sp,%a1.l)
	addq.l #1,%a1
	jra .L1635
.L1638:
	tst.l 56(%sp)
	jeq .L1656
	move.b #45,(%a3)
	moveq #64,%d2
	mov3q.l #1,%a1
	sub.l %d4,%d2
	move.l %d2,56(%sp)
.L1637:
	lea (68,%sp),%a4
	clr.l %d4
.L1640:
	move.l 56(%sp),%d6
	moveq #10,%d0
	addq.l #1,%d4
	rems.l %d0,%d2:%d6
	divs.l %d0,%d6
	add.l #48,%d2
	move.b %d2,(%a4)
	move.l %d6,56(%sp)
	tst.l %d6
	jeq .L1639
	addq.l #1,%a4
	mov3q.l #4,%d6
	cmp.l %d4,%d6
	jne .L1640
.L1639:
	add.l %a1,%a3
	move.l %d4,%d0
.L1641:
	subq.l #1,%d0
	move.b 68(%sp,%d0.l),(%a3)+
	tst.l %d0
	jne .L1641
	mvz.w #248,%d0
	add.l %sp,%d0
	add.l %d1,%d0
	add.l %d4,%d0
	add.l %d0,%a1
	clr.b %d0
	move.l %sp,%d4
	add.l #72,%d4
	move.b %d0,-176(%a1)
.L1633:
	addq.l #1,%d7
	lea (20,%a0),%a0
	moveq #16,%d1
	cmp.l %d7,%d1
	jne .L1642
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
	jgt .L1631
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
.L1631:
	addq.l #1,%d5
	lea (44,%a2),%a2
	moveq #64,%d0
	cmp.l %d5,%d0
	jne .L1643
	move.l -66650100,%d0
	move.l %a6,st+340
	addq.l #1,st+348
	sub.l 64(%sp),%d0
	add.l %d0,st+356
	cmp.l st+360.l,%d0
	jls .L1644
	move.l %d0,st+360
.L1644:
	clr.l st+344
.L1628:
	pea 256.w
	pea comp
	move.l 60(%sp),-(%sp)
	jsr copy32
	lea (12,%sp),%sp
	cmp.l st+20.l,%a6
	jeq .L1645
	move.l -66650100,%d0
	addq.l #1,st+308
	sub.l t_commit,%d0
	add.l %d0,st+304
	cmp.l st+312.l,%d0
	jls .L1645
	move.l %d0,st+312
.L1645:
	move.l st+388,%d1
	tst.l %d1
	jeq .L1646
	cmp.l st+392.l,%a6
	jeq .L1646
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+396
	addq.l #1,st+400
	cmp.l st+404.l,%d0
	jls .L1647
	move.l %d0,st+404
.L1647:
	clr.l st+388
.L1646:
	move.l st+368,%d1
	tst.l %d1
	jeq .L1648
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+372
	addq.l #1,st+376
	cmp.l st+380.l,%d0
	jls .L1649
	move.l %d0,st+380
.L1649:
	clr.l st+368
.L1648:
	move.l %a6,st+20
	move.l -66650100,%d0
	move.l %d0,st+56
	sub.l t_commit,%d0
	addq.l #1,st+28
	move.l %d0,st+60
	jra .L1626
.L1655:
	move.l %d4,56(%sp)
	jra .L1656
.L1629:
	pea 256.w
	pea comp
	move.l 60(%sp),-(%sp)
	addq.l #1,st+32
	jsr (%a2)
	lea (12,%sp),%sp
	jra .L1626
.L1650:
	tst.l st+1058
	jne .L1622
.L1651:
	move.l %d3,%a0
	add.l #566,%d3
	lea (108,%sp),%a1
	addq.l #6,%a0
.L1652:
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
	jne .L1652
	jra .L1622
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
	jne .L1680
	cmp.l ed+88.l,%d1
	jeq .L1680
	move.l %d1,ed+88
	mov3q.l #1,ed+92
.L1680:
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
	jne .L1681
	moveq #66,%d5
	cmp.l %d2,%d5
	jne .L1682
	tst.b k44+20.l
	jeq .L1683
	clr.b %d6
	move.b %d6,k44+20
	tst.b k44+22.l
	jeq .L1683
	moveq #2,%d7
	move.w %d7,k44+22
.L1683:
	clr.l u46
	tst.b u46+48.l
	jeq .L1684
	clr.b %d0
	move.b %d0,u46+48
.L1691:
	mov3q.l #1,%d0
.L1685:
	move.l -66650100,%d1
	addq.l #1,st+336
	sub.l 64(%sp),%d1
	add.l %d1,st+328
	cmp.l st+332.l,%d1
	jls .L1679
	move.l %d1,st+332
.L1679:
	movem.l (%sp),#31996
	lea (100,%sp),%sp
	rts
.L1682:
	cmp.l #134,%d2
	jne .L1686
	clr.l tk
	tst.l tk+8
	jeq .L1684
	move.l st+248,%d0
	clr.l tk+8
	btst #6,%d0
	jeq .L1687
	moveq #-65,%d1
	and.l %d0,%d1
	move.l %d1,st+248
	tst.l st+4
	jne .L1964
.L1687:
	clr.l %d0
	jra .L1685
.L1686:
	move.l %d2,%d0
	add.l #-68,%d0
	lsr.l #1,%d0
	jne .L1684
	moveq #31,%d1
	mov3q.l #1,%d0
	and.l %d4,%d1
	lsl.l %d1,%d0
	and.l st+208,%d0
	tst.l %d0
	jeq .L1689
	move.l st+200,%d3
	move.l %d3,%d5
	move.l st+220,%d1
	move.l %d1,%d0
	and.l #2097152,%d0
	and.l #786432,%d5
	or.l %d5,%d0
	jeq .L1690
	addq.l #1,nk+16
.L1690:
	and.l #-786433,%d3
	bclr #21,%d1
	move.l %d3,st+200
	move.l %d1,st+220
.L1689:
	moveq #69,%d6
	cmp.l %d2,%d6
	jne .L1684
	tst.l nk
	jeq .L1684
	moveq #-33,%d7
	and.l %d7,st+240
	clr.l nk
	tst.l st+4
	jeq .L1691
	mov3q.l #1,-(%sp)
	pea 69.w
	lea queue_key,%a2
	jsr (%a2)
	clr.l -(%sp)
	pea 69.w
	jsr (%a2)
.L1971:
	jsr flush
.L1959:
	lea (16,%sp),%sp
	jra .L1691
.L1684:
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
	jeq .L1692
	not.l %d0
	and.l %d5,%d0
	move.l %d0,(%a2,%a0.l*4)
	jra .L1691
.L1692:
	move.l %d2,%d4
	mov3q.l #5,%d5
	add.l #-64,%d4
	cmp.l %d4,%d5
	jcs .L1693
	move.l ls+28,%d5
	btst %d4,%d5
	jeq .L1693
	mov3q.l #1,%d0
	lsl.l %d4,%d0
	move.l ls+32,%d1
	not.l %d0
	and.l %d0,%d5
	move.l %d5,ls+28
	btst %d4,%d1
	jeq .L1691
	and.l %d1,%d0
	move.l %d0,ls+32
.L1969:
	clr.l -(%sp)
.L1970:
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
.L1960:
	addq.l #8,%sp
	jra .L1691
.L1693:
	move.l %d1,%a1
	move.l %d0,%d4
	lea (121,%a1),%a1
	lea sq,%a0
	move.l (%a0,%a1.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L1694
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a0,%a1.l*4)
	jra .L1969
.L1694:
	move.l %d1,%a0
	move.l %d0,%d4
	lea (50,%a0),%a0
	move.l (%a2,%a0.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L1695
	not.l %d0
	and.l %d3,%d0
	move.l %d2,%d1
	mov3q.l #7,%d6
	add.l #-112,%d1
	move.l %d0,(%a2,%a0.l*4)
	cmp.l %d1,%d6
	jcs .L1687
	move.l ux,%d3
	btst %d1,%d3
	jeq .L1687
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	not.l %d0
	and.l %d3,%d0
	move.l %d0,ux
.L1964:
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
.L1965:
	addq.l #8,%sp
	jra .L1687
.L1695:
	move.l %d1,%a0
	move.l %d0,%d4
	lea (226,%a0),%a0
	move.l (%a2,%a0.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L1696
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a2,%a0.l*4)
	move.l st+4,%d0
	or.l sq+408,%d0
	jeq .L1687
	jra .L1964
.L1696:
	add.l #58,%d1
	move.l %d0,%d4
	move.l (%a2,%d1.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L1687
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a2,%d1.l*4)
	tst.l st+4
	jeq .L1691
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jra .L1960
.L1681:
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
	jne .L1691
	move.l %d7,%d5
	move.l %d3,%d0
	add.l #58,%d5
	and.l (%a2,%d5.l*4),%d0
	tst.l %d0
	jne .L1691
	move.l %d7,%d0
	add.l #121,%d0
	lea sq,%a5
	move.l (%a5,%d0.l*4),%d0
	and.l %d3,%d0
	tst.l %d0
	jne .L1691
	move.l %d7,%d6
	move.l %d3,%d0
	add.l #50,%d6
	and.l (%a2,%d6.l*4),%d0
	tst.l %d0
	jne .L1687
	move.l %d7,%d0
	add.l #226,%d0
	move.l (%a2,%d0.l*4),%d0
	and.l %d3,%d0
	tst.l %d0
	jne .L1687
	tst.l nk
	jeq .L1697
	move.l %d2,%d1
	add.l #-18,%d1
	lsr.l #1,%d1
	jeq .L1700
	cmp.l #181,%d2
	jne .L1699
.L1700:
	lea (%a4,%d0.l),%a0
	moveq #32,%d1
	move.l (%a0),68(%sp,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L1700
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
	jra .L1965
.L1699:
	clr.l nk
	addq.l #1,nk+8
	tst.l st+4
	jeq .L1697
	mov3q.l #1,-(%sp)
	pea 69.w
	jsr queue_key
	jsr flush
	addq.l #8,%sp
.L1697:
	moveq #66,%d6
	cmp.l %d2,%d6
	jne .L1701
	move.l st+4,%d0
	tst.l %d0
	jeq .L1702
	tst.l st+1058
	jne .L1703
.L1702:
	move.l st+216,%d1
	or.l st+248,%d1
	or.l st+920,%d1
	btst #0,%d1
	jne .L1703
	move.w #256,%d7
	lea st+8,%a0
	move.l (%a0),k44
	move.w %d7,k44+20
.L1703:
	lea st+8,%a0
	move.l (%a0),u46+4
	tst.l sq+408
	jeq .L1734
	tst.l %d0
	jeq .L1706
	tst.l st+1058
	jne .L1734
	move.l sq+484,%d1
	move.l st+232,%d0
.L1708:
	or.l %d1,%d0
	tst.w %d0
	jeq .L1734
	moveq #1,%d0
	clr.b %d1
	addq.l #1,u46+32
	move.b %d0,u46+48
	move.b %d1,k44+20
	jra .L1691
.L1701:
	cmp.l #128,%d2
	jne .L1704
	lea masks,%a0
	move.l (%a0),nk+20
.L1734:
	tst.l st+4
	jeq .L1750
	cmp.l #132,%d2
	jne .L1749
	move.l st+216,%d1
	move.l %d1,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L1749
	moveq #16,%d5
	or.l %d1,%d5
	move.l %d5,st+216
	tst.l st+1058
	jne .L1756
	lea st+8,%a0
	mov3q.l #1,st+1058
	clr.l st+1062
	move.l (%a0),st+1066
	addq.l #1,st+1070
.L1756:
	moveq #1,%d0
	move.l 32(%a3),%a0
	move.b %d0,32(%a0)
	jra .L1687
.L1706:
	move.l sq+484,%d1
	jra .L1708
.L1704:
	moveq #68,%d6
	cmp.l %d2,%d6
	jne .L1709
	move.l tk,%d0
	or.l u46,%d0
	jeq .L1710
	tst.l st+4
	jeq .L1710
	addq.l #1,tk+4
	jra .L1734
.L1710:
	move.l st+216,%d0
	moveq #64,%d7
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d0,%d7
	move.l %d7,%a0
	btst #6,%d0
	jne .L1712
	move.l st+240,%d0
	move.l st+208,%d7
	move.l %d7,%d1
	move.l st+912,%d6
	or.l %d0,%d1
	or.l %d6,%d1
	move.w %d1,%ccr
	jeq .L1713
	tst.b u46+48.l
	jeq .L1714
.L1713:
	move.l st+8,%a1
	mov3q.l #2,%d1
	sub.l u46+4,%a1
	cmp.l %a1,%d1
	jcc .L1715
.L1712:
	moveq #16,%d2
	or.l %d2,st+272
	tst.l %a0
	jne .L1716
	moveq #1,%d4
	addq.l #1,u46+20
	addq.l #1,u46+16
	move.b %d4,k44+21
.L1716:
	tst.l st+4
	jeq .L1717
	tst.b k44+22.l
	jeq .L1718
	tst.b k44+26.l
	jne .L1718
	tst.l %a0
	jne .L1718
	moveq #1,%d6
	moveq #1,%d7
	clr.b %d0
	mvz.w #256,%d5
	move.l %d5,st+296
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
.L1961:
	jsr flush
	jra .L1691
.L1718:
	mov3q.l #3,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr leave
	jra .L1960
.L1717:
	clr.l -(%sp)
.L1967:
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	jra .L1963
.L1715:
	move.w %d7,%ccr
	jeq .L1719
.L1714:
	or.l %d6,%d0
	move.w %d0,%ccr
	jeq .L1719
	tst.b u46+48.l
	jeq .L1734
.L1719:
	addq.l #1,u46+40
	jra .L1734
.L1709:
	moveq #53,%d1
	cmp.l %d2,%d1
	jne .L1720
	move.l st+216,%d6
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d6,50(%sp)
	btst #6,%d6
	jne .L1721
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
	jne .L1722
	tst.b u46+48.l
	jeq .L1734
.L1723:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L1721
.L1722:
	tst.l %d6
	jeq .L1723
.L1721:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #32,%d4
	swap %d4
	or.l %d7,%d1
	or.l %d4,st+268
	btst #6,%d1
	jeq .L1725
	mov3q.l #1,tk
.L1725:
	clr.l st+1038
	tst.l st+4
	jeq .L1726
	moveq #1,%d6
	mvz.w #256,%d5
	moveq #1,%d7
	moveq #1,%d0
	move.l %d5,st+296
	addq.l #1,st+998
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
	jra .L1961
.L1726:
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	addq.l #1,st+994
.L1963:
	lea (12,%sp),%sp
	jra .L1691
.L1720:
	moveq #16,%d1
	cmp.l %d2,%d1
	jne .L1705
	move.l st+216,%d6
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d6,50(%sp)
	btst #6,%d6
	jne .L1727
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
	jne .L1728
	tst.b u46+48.l
	jeq .L1734
.L1729:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L1727
.L1728:
	tst.l %d6
	jeq .L1729
.L1727:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #1,%d4
	swap %d4
	or.l %d7,%d1
	or.l %d4,st+264
	btst #6,%d1
	jeq .L1731
	mov3q.l #1,tk
.L1731:
	clr.l st+1038
	tst.l st+4
	jeq .L1732
	moveq #1,%d6
	mvz.w #256,%d5
	moveq #1,%d7
	moveq #2,%d0
	move.l %d5,st+296
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
.L1966:
	addq.l #1,st+1078
	jra .L1961
.L1732:
	mov3q.l #2,-(%sp)
.L1968:
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	addq.l #1,st+1074
	jra .L1963
.L1705:
	moveq #52,%d1
	cmp.l %d2,%d1
	jne .L1707
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L1733
	tst.b u46+48.l
	jeq .L1734
.L1733:
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #6,%d0
	jne .L1734
	tst.l sq+408
	jeq .L1735
	tst.w sq+486.l
	jne .L1734
.L1735:
	tst.w st+202.l
	jne .L1734
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
	jeq .L1736
	moveq #1,%d6
	moveq #3,%d7
	mvz.w #256,%d5
	move.b %d2,st+161
	move.l %d5,st+296
	move.w %d6,st+162
	move.b %d7,st+993
	jra .L1966
.L1736:
	mov3q.l #3,-(%sp)
	jra .L1968
.L1707:
	moveq #51,%d0
	cmp.l %d2,%d0
	jne .L1711
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L1737
	tst.b u46+48.l
	jeq .L1734
.L1737:
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #6,%d0
	jne .L1734
	tst.l sq+408
	jeq .L1738
	tst.w sq+486.l
	jne .L1734
.L1738:
	tst.w st+202.l
	jne .L1734
	moveq #1,%d1
	moveq #8,%d2
	swap %d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	clr.l st+1038
	move.b %d1,k44+21
	or.l %d2,st+268
	tst.l st+4
	jeq .L1739
	moveq #1,%d5
	moveq #4,%d6
	mvz.w #256,%d4
	move.b %d1,st+161
	move.l %d4,st+296
	move.w %d5,st+162
	move.b %d6,st+993
	jra .L1961
.L1739:
	mov3q.l #4,-(%sp)
	jra .L1967
.L1711:
	moveq #48,%d7
	cmp.l %d2,%d7
	jne .L1724
	move.l st+216,%d0
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d0,50(%sp)
	btst #6,%d0
	jne .L1740
	move.l st+208,%d0
	move.l %a0,%d6
	or.l %d7,%d6
	moveq #64,%d1
	or.l st+240,%d0
	and.l %d1,%d6
	mov3q.l #4,%d1
	or.l st+912,%d0
	and.l %d1,%d0
	or.l %d6,%d0
	jne .L1741
	tst.b u46+48.l
	jeq .L1734
.L1742:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L1740
.L1741:
	tst.l %d6
	jeq .L1742
.L1740:
	mvz.b 1093765506,%d0
	moveq #11,%d4
	cmp.l %d0,%d4
	jcs .L1820
	move.b 1093765506,%d0
	add.l #16,%d0
.L1743:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #1,%d5
	swap %d5
	or.l %d7,%d1
	or.l %d5,st+268
	btst #6,%d1
	jeq .L1744
	mov3q.l #1,tk
.L1744:
	tst.l st+4
	jeq .L1745
	tst.l st+1038
	jeq .L1746
	mov3q.l #3,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr leave
	addq.l #1,st+1050
	jra .L1960
.L1820:
	moveq #16,%d0
	jra .L1743
.L1746:
	moveq #1,%d7
	moveq #1,%d1
	mvz.w #256,%d6
	move.b %d0,st+993
	mov3q.l #1,st+1038
	addq.l #1,st+1046
	move.l %d6,st+296
	move.b %d7,st+161
	move.w %d1,st+162
	jra .L1961
.L1745:
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	mov3q.l #1,st+1038
	addq.l #1,st+1042
	jra .L1963
.L1724:
	moveq #12,%d6
	cmp.l %d2,%d6
	jcs .L1730
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L1747
	tst.b u46+48.l
	jeq .L1734
.L1747:
	addq.l #1,%d2
	or.l %d3,st+264
	move.l %d2,dp
	addq.l #1,dp+4
	tst.b k44+22.l
	jne .L1691
	moveq #1,%d7
	move.b %d7,k44+21
	jra .L1691
.L1730:
	moveq #49,%d0
	cmp.l %d2,%d0
	jne .L1734
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L1748
	tst.b u46+48.l
	jeq .L1734
.L1748:
	tst.l st+4
	jne .L1749
	tst.l st+972
	jne .L1750
	tst.l sq+408
	jeq .L1751
	tst.w sq+486.l
	jne .L1750
.L1751:
	move.l st+200,%d6
	mvz.w %d6,%d6
	tst.l %d6
	jne .L1750
	move.b 1093765506,%d1
	moveq #11,%d4
	mvz.b %d1,%d2
	cmp.l %d2,%d4
	jlt .L1752
	moveq #127,%d0
	ext.w %d1
	and.l -2147457096,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d6
.L1752:
	moveq #1,%d5
	addq.l #1,u46+24
	addq.l #1,u46+16
	move.b %d5,k44+21
	tst.b ls.l
	jeq .L1753
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1753:
	clr.l u46+8
	moveq #11,%d7
	cmp.l %d2,%d7
	jlt .L1754
	move.l %d6,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L1755
	moveq #45,%d0
	cmp.l %d6,%d0
	jne .L1754
.L1755:
	move.l %d6,-(%sp)
	move.l %d2,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	moveq #127,%d1
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jeq .L1754
	mov3q.l #1,%d2
	or.l st+8,%d2
	move.l %d6,u46+12
	move.l %d2,u46+8
.L1754:
	moveq #2,%d4
	swap %d4
	or.l %d4,st+204
	jra .L1687
.L1750:
	tst.b ls.l
	jeq .L1757
	move.l %d2,%d1
	mov3q.l #5,%d6
	add.l #-64,%d1
	cmp.l %d1,%d6
	jcs .L1758
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	lea flush,%a2
	moveq #68,%d7
	or.l %d0,ls+28
	cmp.l %d2,%d7
	jne .L1759
	tst.l ls+36
	jne .L1760
	move.l st+216,%d0
	or.l st+920,%d0
	or.l st+248,%d0
	btst #0,%d0
	jeq .L1761
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
.L1962:
	jsr (%a2)
	jra .L1960
.L1759:
	moveq #69,%d1
	cmp.l %d2,%d1
	jne .L1760
	tst.l ls+36
	jeq .L1821
.L1760:
	mov3q.l #1,-(%sp)
	or.l %d0,ls+32
	move.l %d2,-(%sp)
	addq.l #1,ls+88
	jsr queue_key
	jra .L1962
.L1761:
	move.l 1100949720,%a3
	move.l %a3,%d0
	clr.l ls+64
	clr.l ls+60
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L1763
	jsr sq_grid
	tst.l %d0
	jeq .L1763
	lea (348,%a3),%a0
	move.l (%a0),ls+60
	lea (344,%a3),%a3
	move.l (%a3),ls+64
.L1763:
	mvz.b ls+1,%d0
	lea st+8,%a0
	move.l (%a0),ls+72
	move.l %d0,ls+68
	moveq #1,%d0
.L1762:
	mov3q.l #3,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	jsr ls_close
	jsr (%a2)
	addq.l #4,%sp
	jra .L1691
.L1821:
	moveq #2,%d0
	jra .L1762
.L1758:
	move.l %d4,%d0
	and.l #240,%d0
	tst.l %d0
	jeq .L1757
	cmp.l #128,%d2
	jeq .L1757
	move.l %d2,%d0
	mov3q.l #2,%d6
	add.l #-80,%d0
	cmp.l %d0,%d6
	jcc .L1757
	add.l #-64,%d0
	moveq #11,%d7
	cmp.l %d0,%d7
	jcc .L1757
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
	tst.l st+4
	jne .L1749
.L1757:
	move.l st+972,%d0
	tst.b ls.l
	jne .L1764
	moveq #68,%d1
	cmp.l %d2,%d1
	jne .L1764
	tst.l %d0
	jne .L1765
	tst.b sv.l
	jeq .L1749
	tst.b sv+8.l
	jeq .L1749
	move.b sv+3,%d7
	jne .L1749
	move.l ls+24,%d0
	mov3q.l #4,%d6
	addq.l #2,%d0
	cmp.l %d0,%d6
	jcs .L1749
	move.b sv+1,%d1
	move.b %d1,59(%sp)
	mvz.b %d1,%d6
	mvz.b 1093765506,%d0
	cmp.l %d6,%d0
	jne .L1749
	move.b sv+2,%d6
	mvz.b %d6,%d1
	move.l %d1,-(%sp)
	move.l %d1,58(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L1766
	moveq #45,%d0
	cmp.l 54(%sp),%d0
	jne .L1749
.L1766:
	tst.l sq+408
	jeq .L1767
	tst.w sq+486.l
	jne .L1749
.L1767:
	move.l st+216,%d0
	or.l st+920,%d0
	or.l st+248,%d0
	btst #0,%d0
	jeq .L1749
	move.b 59(%sp),%d1
	move.b %d6,ls+2
	mvz.b %d6,%d6
	moveq #45,%d2
	move.b %d1,ls+1
	cmp.l %d6,%d2
	jne .L1768
	moveq #10,%d7
.L1768:
	moveq #1,%d4
	clr.b %d5
	lea st+8,%a0
	move.l (%a0),ls+126
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	lea ls_queue,%a2
	move.b %d7,ls+124
	move.b %d4,ls
	move.b %d5,ls+125
	addq.l #1,ls+76
	addq.l #1,ls+130
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
	jra .L1971
.L1764:
	tst.l %d0
	jeq .L1749
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-80,%d0
	cmp.l %d0,%d1
	jcc .L1749
	add.l #-64,%d0
	moveq #11,%d6
	cmp.l %d0,%d6
	jcc .L1749
.L1765:
	mov3q.l #4,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr splash_end
	addq.l #8,%sp
	mov3q.l #5,%d7
	move.l %d2,%d0
	add.l #-64,%d0
	cmp.l %d0,%d7
	jcs .L1749
	or.l %d3,st+272
	jra .L1691
.L1749:
	move.l st+4,%d0
	tst.l sq+408
	jeq .L1769
	tst.l %d0
	jeq .L1770
	tst.l st+1058
	jne .L1771
.L1770:
	move.l %d2,%d1
	mov3q.l #2,%d6
	add.l #-80,%d1
	cmp.l %d1,%d6
	jcs .L1772
	move.l st+920,%d1
	move.l st+248,%d7
	move.l st+208,%d6
	or.l st+216,%d1
	move.l %d7,46(%sp)
	or.l st+240,%d6
	or.l %d7,%d1
	btst #0,%d1
	jeq .L1773
	move.l sq+484,%a0
	tst.l %d0
	jeq .L1822
	move.l st+232,%a1
.L1774:
	move.l %a0,%d7
	move.l %a1,%d1
	or.l %d7,%d1
	move.l %d1,%d7
	moveq #16,%d1
	mvz.w %d7,%d7
	and.l sq+500,%d1
	or.l %d7,%d1
	jne .L1776
	tst.l %d0
	jeq .L1773
	move.l 46(%sp),%d7
	btst #4,%d7
	jne .L1776
.L1773:
	move.l %d6,%d1
	or.l st+912,%d1
	move.w %d1,%ccr
	jeq .L1778
	tst.b u46+48.l
	jeq .L1779
.L1778:
	move.l sq+484,%a0
	tst.l %d0
	jeq .L1823
	move.l st+232,%d1
.L1780:
	move.l %a0,%d7
	or.l %d7,%d1
	tst.w %d1
	jeq .L1779
.L1776:
	or.l st+912,%d6
	move.w %d6,%ccr
	jeq .L1781
	tst.b u46+48.l
	jeq .L1782
.L1781:
	addq.l #1,u46+36
.L1782:
	tst.l %d0
	jeq .L1783
	move.l st+232,%d0
.L1783:
	move.l %a0,%d1
	or.l %d1,%d0
	move.l %d0,%d1
	mvz.w %d1,%d1
	tst.w %d0
	jeq .L1784
	moveq #80,%d4
	cmp.l %d2,%d4
	jeq .L1824
	moveq #82,%d5
	cmp.l %d2,%d5
	jne .L1825
	moveq #14,%d0
.L1785:
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	mov3q.l #1,-(%sp)
	or.l %d3,st+272
	move.l %d0,-(%sp)
	jsr ed_queue
	jra .L1959
.L1822:
	sub.l %a1,%a1
	jra .L1774
.L1823:
	clr.l %d1
	jra .L1780
.L1784:
	moveq #80,%d6
	cmp.l %d2,%d6
	jeq .L1826
	moveq #82,%d7
	cmp.l %d2,%d7
	jne .L1827
	moveq #10,%d0
	jra .L1785
.L1824:
	moveq #13,%d0
	jra .L1785
.L1825:
	moveq #15,%d0
	jra .L1785
.L1826:
	moveq #9,%d0
	jra .L1785
.L1827:
	moveq #11,%d0
	jra .L1785
.L1819:
	cmp.l #132,%d2
	jne .L1786
	move.l st+216,%d0
	move.l %d0,%d1
	or.l st+920,%d1
	btst #0,%d1
	jeq .L1786
	moveq #16,%d1
	or.l %d0,%d1
	addq.l #1,ed+84
	move.l %d1,st+216
	jra .L1687
.L1787:
	move.l %d4,%d0
	and.l #240,%d0
	tst.l %d0
	jeq .L1789
	and.l #251,%d4
	cmp.l #128,%d4
	jeq .L1789
	moveq #48,%d7
	cmp.l %d2,%d7
	jne .L1790
.L1789:
	lea sq,%a0
	addq.l #1,sq+460
	cmp.l #128,%d2
	jne .L1791
	mov3q.l #1,%d0
	or.l %d0,st+920
.L1792:
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	addq.l #8,%sp
	cmp.l #128,%d2
	sne %d0
.L1972:
	mvs.b %d0,%d0
	neg.l %d0
	jra .L1685
.L1791:
	lea (121,%a6),%a6
	or.l %d3,(%a0,%a6.l*4)
	jra .L1792
.L1797:
	move.l %d2,%d0
	add.l #-66,%d0
	lsr.l #1,%d0
	jne .L1800
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L1799
	move.l masks,%d6
	cmp.l nk+20.l,%d6
	jeq .L1798
.L1799:
	cmp.l #181,%d2
	jne .L1804
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L1808
.L1804:
	tst.l mask_set
	jeq .L1809
	lea mask_keys,%a0
	move.l (%a0,%a6.l*4),%d0
	move.l 60(%sp),%d7
	btst %d7,%d0
	jeq .L1808
.L1809:
	cmp.l #128,%d2
	jne .L1956
	mov3q.l #2,%d4
	jra .L1810
.L1801:
	addq.l #1,nk+24
	jra .L1802
.L1828:
	mov3q.l #1,%d0
	jra .L1805
.L1957:
	move.l %d2,%d0
	mov3q.l #2,%d6
	add.l #-80,%d0
	cmp.l %d0,%d6
	jcs .L1799
.L1807:
	addq.l #1,st+944
.L1793:
	lea (50,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
	jra .L1687
.L1956:
	mov3q.l #1,%d4
.L1810:
	addq.l #1,st+936
	mov3q.l #2,%d1
	cmp.l %d4,%d1
	jne .L1812
	lea (226,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
.L1813:
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	mov3q.l #2,%d2
	addq.l #8,%sp
	cmp.l %d4,%d2
	sne %d0
	jra .L1972
.L1812:
	or.l %d3,(%a2,%d5.l*4)
	jra .L1813
.L1800:
	moveq #69,%d0
	cmp.l %d2,%d0
	jne .L1957
	tst.l mask_set
	jeq .L1803
	lea mask_keys+8,%a0
	btst #5,3(%a0)
	jeq .L1804
.L1803:
	lea st+232,%a1
	clr.l %d1
	sub.l %a0,%a0
.L1806:
	tst.l (%a1)+
	jne .L1828
	tst.l 668(%a1)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1805:
	or.l %d0,%d1
	addq.l #1,%a0
	moveq #8,%d0
	cmp.l %a0,%d0
	jne .L1806
	move.l st+216,%d0
	mov3q.l #1,%d4
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d4,%d0
	or.l %d1,%d0
	jne .L1804
	moveq #32,%d5
	or.l %d5,st+240
	addq.l #1,st+936
	mov3q.l #1,nk
	jra .L1691
.L1796:
	moveq #69,%d1
	cmp.l %d2,%d1
	jeq .L1808
	add.l #-80,%d2
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	jcc .L1807
.L1808:
	addq.l #1,st+940
	jra .L1793
.L1772:
	tst.l %d0
	jeq .L1819
.L1771:
	move.l %d2,%d0
	moveq #11,%d6
	add.l #-144,%d0
	cmp.l %d0,%d6
	jcs .L1794
	moveq #64,%d0
	and.l st+248,%d0
	tst.l %d0
	jeq .L1794
	move.l tk+8,%d0
	tst.l %d0
	jne .L1794
.L1795:
	lea (%a4,%d0.l),%a0
	moveq #32,%d1
	move.l (%a0),68(%sp,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L1795
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
.L1794:
	tst.l st+4
	jeq .L1793
	tst.l st+1058
	jne .L1796
	moveq #68,%d7
	cmp.l %d2,%d7
	jne .L1797
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
	move.l st+232,%d1
	mvz.w %d1,%d1
	or.l %d1,%d0
	jeq .L1804
.L1798:
	addq.l #1,st+936
	moveq #68,%d7
	cmp.l %d2,%d7
	jne .L1801
	addq.l #1,nk+12
.L1802:
	or.l %d3,st+240
	jra .L1973
.L1769:
	tst.l %d0
	jne .L1771
.L1790:
	tst.b sv.l
	jeq .L1771
	moveq #111,%d1
	cmp.l %d2,%d1
	jcc .L1793
	moveq #119,%d4
	cmp.l %d2,%d4
	jcs .L1771
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
	jra .L1965
.L1779:
	tst.l %d0
	jne .L1794
.L1786:
	tst.w sq+486.l
	jeq .L1787
	move.l %d2,%d0
	mov3q.l #5,%d6
	add.l #-48,%d0
	cmp.l %d0,%d6
	jcc .L1788
	moveq #16,%d7
	cmp.l %d2,%d7
	jeq .L1788
	add.l #-20,%d0
	mov3q.l #1,%d1
	cmp.l %d0,%d1
	jcc .L1788
	add.l #-44,%d0
	lsr.l #3,%d0
	jne .L1787
.L1788:
	lea (121,%a6),%a6
	or.l %d3,(%a5,%a6.l*4)
	addq.l #1,st+1054
.L1973:
	mov3q.l #1,-(%sp)
	jra .L1970
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
	jne .L1975
	tst.l sq+408
	jeq .L1976
	tst.w sq+486.l
	jeq .L1976
	mov3q.l #7,%d0
	cmp.l %a6,%d0
	jcs .L1976
	tst.b 20(%a0)
	jne .L2004
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+920,%d0
	and.l %d1,%d0
.L1977:
	add.l %d2,96(%a2,%a6.l*4)
	move.b %d0,st+160
	addq.l #1,sq+464
	jsr flush
.L1978:
	mov3q.l #1,%d2
	jra .L1981
.L2004:
	mov3q.l #1,%d0
	jra .L1977
.L1976:
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr ls_enc
	addq.l #8,%sp
	move.l %d0,%d2
	tst.l %d0
	jne .L1981
	moveq #8,%d3
	cmp.l %a6,%d3
	jne .L1980
	tst.b sv+8.l
	jeq .L1980
	move.l st+8,%a0
	addq.l #1,st+1086
	lea (47,%a0),%a0
	move.l %a0,st+1082
.L1980:
	tst.l st+972
	jeq .L1981
	mov3q.l #5,-(%sp)
	move.l 76(%sp),%a1
	move.l 32(%a1),-(%sp)
	jsr splash_end
	addq.l #8,%sp
.L1981:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 44(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L1974
	move.l %d0,st+332
.L1974:
	move.l %d2,%d0
	movem.l (%sp),#23804
	lea (68,%sp),%sp
	rts
.L1975:
	tst.l st+1058
	jeq .L1982
	addq.l #1,st+952
.L1983:
	clr.l %d2
	jra .L1981
.L1982:
	tst.l mask_set
	jeq .L1984
	moveq #15,%d0
	cmp.l %a6,%d0
	jcs .L1985
	move.l mask_enc,%d0
	move.l %a6,%d1
	btst %d1,%d0
	jne .L1984
.L1985:
	addq.l #1,st+952
	moveq #8,%d3
	cmp.l %a6,%d3
	jne .L1983
	move.l st+8,%a0
	addq.l #1,st+1086
	lea (47,%a0),%a0
	move.l %a0,st+1082
	jra .L1983
.L1984:
	addq.l #1,st+948
	tst.b 20(%a0)
	jne .L2005
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
.L1987:
	move.b %d0,st+160
	moveq #15,%d3
	cmp.l %a6,%d3
	jcs .L1978
	move.l %a6,%d4
	add.l #24,%d4
	add.l %d2,(%a2,%d4.l*4)
	tst.l st+64
	jne .L1989
	move.l #-66650100,%a0
	move.l (%a0),st+64
.L1989:
	tst.l st+388
	jne .L1990
	move.l #-66650100,%a1
	lea commits,%a0
	move.l (%a1),st+388
	move.l (%a0),st+392
.L1990:
	move.l %a6,%d5
	add.l #122,%d5
	lea bind_gen,%a4
	move.l (%a4,%a6.l*4),%d6
	move.l (%a2,%d5.l*4),%a3
	cmp.l %d6,%a3
	jeq .L1993
	btst #0,%d6
	jne .L1993
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
	jne .L1993
	move.l %d3,%d0
	move.l %a6,%d1
	add.l #st+552,%d0
	add.l #102,%d1
	tst.l (%a2,%d1.l*4)
	jeq .L2006
	move.l %d0,%a1
	move.b 48(%sp),%d3
	move.b (%a1),%d1
	eor.l %d1,%d3
	tst.b %d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
.L1995:
	mov3q.l #5,-(%sp)
	move.l %d7,-(%sp)
	move.l %d0,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	tst.l %d3
	jne .L1996
	lea (%a2,%a6.l),%a0
	move.b 49(%sp),472(%a0)
.L1996:
	move.l %d6,(%a2,%d5.l*4)
	move.l %d6,%a3
.L1993:
	tst.l %a3
	jeq .L1997
	move.l %a6,%d0
	moveq #20,%d3
	muls.l %d3,%d0
	lea (%a2,%d0.l),%a0
	mvz.b 552(%a0),%d1
	lsr.l #6,%d1
	jne .L1997
	lea (102,%a6),%a1
	add.l #st,%a6
	tst.l (%a2,%a1.l*4)
	jne .L1998
	move.b 553(%a0),472(%a6)
.L1998:
	move.l %d0,%a0
	add.l #st+556,%a0
	move.b (%a0),%d1
	mvz.b 472(%a6),%d3
	btst #0,%d1
	jeq .L2007
	tst.b st+160.l
	jne .L2008
.L2007:
	mov3q.l #1,%d1
.L1999:
	muls.l %d1,%d2
	move.l %d0,%a0
	add.l #st+554,%a0
	mvz.b (%a0),%d1
	add.l %d3,%d2
	cmp.l %d2,%d1
	jle .L2000
	move.l %d1,%d2
.L2000:
	move.l %d0,%a0
	add.l #st+555,%a0
	mvz.b (%a0),%d1
	cmp.l %d2,%d1
	jge .L2001
	move.l %d1,%d2
.L2001:
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
	jne .L2002
	move.l #-66650100,%a1
	move.l (%a1),st+368
.L2002:
	moveq #1,%d0
	move.l 72(%sp),%a1
	move.l 32(%a1),%a0
	move.b %d0,32(%a0)
.L1997:
	jsr flush
	tst.l (%a2,%d4.l*4)
	jne .L1978
	addq.l #1,st+384
	jra .L1978
.L2005:
	mov3q.l #1,%d0
	jra .L1987
.L2006:
	clr.l %d3
	jra .L1995
.L2008:
	moveq #8,%d1
	jra .L1999
	.size	rui_enc, .-rui_enc
	.align	2
	.globl	pj_write
	.type	pj_write, @function
pj_write:
	move.l 4(%sp),%d0
	move.l 8(%sp),%d1
	cmp.l #1074464814,%d0
	jeq .L2018
	cmp.l #1073958730,%d0
	jeq .L2018
	lea pj_push,%a0
	cmp.l #1074076072,%d0
	jne .L2020
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #5,-(%sp)
.L2033:
	jsr (%a0)
	lea (12,%sp),%sp
.L2018:
	rts
.L2020:
	cmp.l #1074076390,%d0
	jeq .L2021
	cmp.l #1074076276,%d0
	jne .L2022
.L2021:
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #3,-(%sp)
	jra .L2033
.L2022:
	cmp.l #1073959500,%d0
	jne .L2023
	mvz.b pj+137,%d0
	move.l %d1,-(%sp)
	move.l %d0,%a1
	pea -1(%a1)
	mov3q.l #2,-(%sp)
	jra .L2033
.L2023:
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #7,-(%sp)
	jra .L2033
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
	jcs .L2037
	addq.l #1,%d0
.L2036:
	move.b %d0,pj+137
	rts
.L2037:
	clr.b %d0
	jra .L2036
	.size	pj_copy, .-pj_copy
	.align	2
	.globl	pj_save
	.type	pj_save, @function
pj_save:
	move.l 4(%sp),%d0
	tst.l %d0
	jlt .L2038
	move.b 1079807565,%d1
	move.l %d0,-(%sp)
	mvs.b %d1,%d1
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr pj_push
	lea (12,%sp),%sp
.L2038:
	rts
	.size	pj_save, .-pj_save
	.align	2
	.globl	pj_activate
	.type	pj_activate, @function
pj_activate:
	move.l 4(%sp),%d0
	tst.l %d0
	jlt .L2040
	move.l #1074457822,%d1
	cmp.l 8(%sp),%d1
	jne .L2040
	move.l #1074479198,%d1
	cmp.l 12(%sp),%d1
	jne .L2040
	move.l %d0,12(%sp)
	moveq #10,%d0
	mov3q.l #-1,8(%sp)
	move.l %d0,4(%sp)
	jra pj_push
.L2040:
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
	jge .L2043
	moveq #127,%d0
.L2044:
	move.l %d0,-(%sp)
	pea 65.w
	jsr pj_push
	lea (12,%sp),%sp
	rts
.L2043:
	tst.l %d0
	jge .L2044
	clr.l %d0
	jra .L2044
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
	.type	CSWTCH.502, @object
	.size	CSWTCH.502, 7
CSWTCH.502:
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
	.type	CSWTCH.500, @object
	.size	CSWTCH.500, 28
CSWTCH.500:
	.long	cu_wt_short
	.long	cu_gr_short
	.long	cu_li_short
	.long	cu_cp_short
	.long	cu_mi_name
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
	.comm	cu,28,4
	.text
.LC7:
	.string	"CC 1 Value"
.LC8:
	.string	"VAL1"
.LC9:
	.string	"CC 2 Value"
.LC10:
	.string	"VAL2"
.LC11:
	.string	"CC 3 Value"
.LC12:
	.string	"VAL3"
.LC13:
	.string	"CC 4 Value"
.LC14:
	.string	"VAL4"
.LC15:
	.string	"CC 1 Select"
.LC16:
	.string	"SEL1"
.LC17:
	.string	"CC 2 Select"
.LC18:
	.string	"SEL2"
.LC19:
	.string	"CC 3 Select"
.LC20:
	.string	"SEL3"
.LC21:
	.string	"CC 4 Select"
.LC22:
	.string	"SEL4"
	.text
	.align	2
	.type	cu_mip2k, @object
	.size	cu_mip2k, 112
cu_mip2k:
	.long	.LC7
	.long	.LC8
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC9
	.long	.LC10
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC11
	.long	.LC12
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC13
	.long	.LC14
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC15
	.long	.LC16
	.word	410
	.byte	32
	.byte	0
	.word	0
	.long	.LC17
	.long	.LC18
	.word	410
	.byte	32
	.byte	0
	.word	0
	.long	.LC19
	.long	.LC20
	.word	410
	.byte	32
	.byte	0
	.word	0
	.long	.LC21
	.long	.LC22
	.word	410
	.byte	32
	.byte	0
	.word	0
	.text
.LC23:
	.string	"Destination"
.LC24:
	.string	"DST"
.LC25:
	.string	"Channel"
.LC26:
	.string	"CHAN"
.LC27:
	.string	"Bank"
.LC28:
	.string	"BANK"
.LC29:
	.string	"Sub Bank"
.LC30:
	.string	"SBNK"
.LC31:
	.string	"Program"
.LC32:
	.string	"PROG"
.LC33:
	.string	"Pitch Bend"
.LC34:
	.string	"PB"
.LC35:
	.string	"Aftertouch"
.LC36:
	.string	"AT"
.LC37:
	.string	"Mod Wheel"
.LC38:
	.string	"MW"
	.text
	.align	2
	.type	cu_mik, @object
	.size	cu_mik, 112
cu_mik:
	.long	.LC23
	.long	.LC24
	.word	410
	.byte	27
	.byte	32
	.word	260
	.long	.LC25
	.long	.LC26
	.word	410
	.byte	28
	.byte	0
	.word	272
	.long	.LC27
	.long	.LC28
	.word	410
	.byte	30
	.byte	0
	.word	0
	.long	.LC29
	.long	.LC30
	.word	410
	.byte	30
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
	.byte	29
	.byte	0
	.word	0
	.long	.LC35
	.long	.LC36
	.word	410
	.byte	31
	.byte	0
	.word	0
	.long	.LC37
	.long	.LC38
	.word	410
	.byte	31
	.byte	0
	.word	0
	.text
.LC39:
	.string	"Stutter"
.LC40:
	.string	"STUT"
.LC41:
	.string	"Stutter Len"
.LC42:
	.string	"SLEN"
.LC43:
	.string	"Tape"
.LC44:
	.string	"TAPE"
.LC45:
	.string	"Tape Time"
.LC46:
	.string	"TTIM"
.LC47:
	.string	"Attack"
.LC48:
	.string	"ATK"
.LC49:
	.string	"Decay"
.LC50:
	.string	"DEC"
.LC51:
	.string	"Direction"
.LC52:
	.string	"DIR"
.LC53:
	.string	"Loop"
.LC54:
	.string	"LOOP"
	.text
	.align	2
	.type	cu_cpp2k, @object
	.size	cu_cpp2k, 112
cu_cpp2k:
	.long	.LC39
	.long	.LC40
	.word	410
	.byte	20
	.byte	0
	.word	272
	.long	.LC41
	.long	.LC42
	.word	410
	.byte	25
	.byte	0
	.word	0
	.long	.LC43
	.long	.LC44
	.word	410
	.byte	22
	.byte	0
	.word	260
	.long	.LC45
	.long	.LC46
	.word	410
	.byte	25
	.byte	0
	.word	0
	.long	.LC47
	.long	.LC48
	.word	410
	.byte	25
	.byte	0
	.word	0
	.long	.LC49
	.long	.LC50
	.word	410
	.byte	26
	.byte	0
	.word	0
	.long	.LC51
	.long	.LC52
	.word	410
	.byte	23
	.byte	0
	.word	259
	.long	.LC53
	.long	.LC54
	.word	410
	.byte	24
	.byte	0
	.word	260
	.text
.LC55:
	.string	"Sample"
.LC56:
	.string	"SRC"
.LC57:
	.string	"Slice"
.LC58:
	.string	"SLC"
.LC59:
	.string	"Tune"
.LC60:
	.string	"TUNE"
.LC61:
	.string	"Morph"
.LC62:
	.string	"MRPH"
.LC63:
	.string	"Shuffle Seed"
.LC64:
	.string	"SEED"
.LC65:
	.string	"Neighbour"
.LC66:
	.string	"NBR"
.LC67:
	.string	"Velocity"
.LC68:
	.string	"VEL"
.LC69:
	.string	"Level"
.LC70:
	.string	"LEV"
	.text
	.align	2
	.type	cu_cpk, @object
	.size	cu_cpk, 112
cu_cpk:
	.long	.LC55
	.long	.LC56
	.word	410
	.byte	9
	.byte	10
	.word	2944
	.long	.LC57
	.long	.LC58
	.word	410
	.byte	16
	.byte	0
	.word	320
	.long	.LC59
	.long	.LC60
	.word	40
	.byte	17
	.byte	64
	.word	0
	.long	.LC61
	.long	.LC62
	.word	410
	.byte	18
	.byte	0
	.word	0
	.long	.LC63
	.long	.LC64
	.word	410
	.byte	19
	.byte	0
	.word	0
	.long	.LC65
	.long	.LC66
	.word	410
	.byte	18
	.byte	0
	.word	0
	.long	.LC67
	.long	.LC68
	.word	410
	.byte	18
	.byte	64
	.word	0
	.long	.LC69
	.long	.LC70
	.word	101
	.byte	0
	.byte	100
	.word	0
	.text
.LC71:
	.string	"Release"
.LC72:
	.string	"REL"
.LC73:
	.string	"-"
	.text
	.align	2
	.type	cu_lip2k, @object
	.size	cu_lip2k, 112
cu_lip2k:
	.long	.LC71
	.long	.LC72
	.word	410
	.byte	0
	.byte	77
	.word	0
	.long	.LC73
	.long	.LC73
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC73
	.long	.LC73
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC73
	.long	.LC73
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC73
	.long	.LC73
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC73
	.long	.LC73
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC73
	.long	.LC73
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC73
	.long	.LC73
	.word	410
	.byte	0
	.byte	0
	.word	0
	.text
.LC74:
	.string	"Input"
.LC75:
	.string	"INPT"
.LC76:
	.string	"Gain"
.LC77:
	.string	"GAIN"
.LC78:
	.string	"Gate"
.LC79:
	.string	"GATE"
.LC80:
	.string	"Hold"
.LC81:
	.string	"HOLD"
.LC82:
	.string	"Monitor"
.LC83:
	.string	"MON"
.LC84:
	.string	"Sustain"
.LC85:
	.string	"SUS"
	.text
	.align	2
	.type	cu_lik, @object
	.size	cu_lik, 112
cu_lik:
	.long	.LC74
	.long	.LC75
	.word	410
	.byte	13
	.byte	80
	.word	260
	.long	.LC76
	.long	.LC77
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC78
	.long	.LC79
	.word	101
	.byte	15
	.byte	0
	.word	0
	.long	.LC80
	.long	.LC81
	.word	410
	.byte	0
	.byte	28
	.word	0
	.long	.LC82
	.long	.LC83
	.word	410
	.byte	14
	.byte	0
	.word	258
	.long	.LC47
	.long	.LC48
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC49
	.long	.LC50
	.word	410
	.byte	0
	.byte	77
	.word	0
	.long	.LC84
	.long	.LC85
	.word	101
	.byte	0
	.byte	0
	.word	0
	.text
.LC86:
	.string	"Hold/Freeze"
.LC87:
	.string	"Animate"
.LC88:
	.string	"ANIM"
.LC89:
	.string	"Chord"
.LC90:
	.string	"CHD"
.LC91:
	.string	"Inversion"
.LC92:
	.string	"INV"
.LC93:
	.string	"Spread"
.LC94:
	.string	"SPR"
.LC95:
	.string	"Voices"
.LC96:
	.string	"VOI"
	.text
	.align	2
	.type	cu_grp2k, @object
	.size	cu_grp2k, 112
cu_grp2k:
	.long	.LC47
	.long	.LC48
	.word	410
	.byte	0
	.byte	10
	.word	0
	.long	.LC71
	.long	.LC72
	.word	410
	.byte	0
	.byte	60
	.word	0
	.long	.LC86
	.long	.LC81
	.word	410
	.byte	10
	.byte	0
	.word	0
	.long	.LC87
	.long	.LC88
	.word	410
	.byte	11
	.byte	0
	.word	0
	.long	.LC89
	.long	.LC90
	.word	410
	.byte	3
	.byte	0
	.word	1552
	.long	.LC91
	.long	.LC92
	.word	410
	.byte	4
	.byte	0
	.word	1540
	.long	.LC93
	.long	.LC94
	.word	410
	.byte	5
	.byte	0
	.word	1539
	.long	.LC95
	.long	.LC96
	.word	410
	.byte	6
	.byte	0
	.word	1543
	.text
.LC97:
	.string	"Source"
.LC98:
	.string	"Position"
.LC99:
	.string	"POS"
.LC100:
	.string	"Spray"
.LC101:
	.string	"SPRY"
.LC102:
	.string	"Grain Size"
.LC103:
	.string	"SIZE"
.LC104:
	.string	"Density"
.LC105:
	.string	"DENS"
.LC106:
	.string	"Pitch Rand"
.LC107:
	.string	"PRND"
.LC108:
	.string	"Reverse"
.LC109:
	.string	"REV"
.LC110:
	.string	"WIN"
	.text
	.align	2
	.type	cu_grk, @object
	.size	cu_grk, 112
cu_grk:
	.long	.LC97
	.long	.LC56
	.word	410
	.byte	9
	.byte	10
	.word	2944
	.long	.LC98
	.long	.LC99
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC100
	.long	.LC101
	.word	410
	.byte	0
	.byte	20
	.word	0
	.long	.LC102
	.long	.LC103
	.word	410
	.byte	0
	.byte	64
	.word	0
	.long	.LC104
	.long	.LC105
	.word	410
	.byte	0
	.byte	64
	.word	0
	.long	.LC106
	.long	.LC107
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC108
	.long	.LC109
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC4
	.long	.LC110
	.word	410
	.byte	8
	.byte	0
	.word	260
	.text
.LC111:
	.string	"Env>Pos"
.LC112:
	.string	"ENV"
	.text
	.align	2
	.type	cu_wtp2k, @object
	.size	cu_wtp2k, 112
cu_wtp2k:
	.long	.LC47
	.long	.LC48
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC49
	.long	.LC50
	.word	410
	.byte	0
	.byte	64
	.word	0
	.long	.LC84
	.long	.LC85
	.word	410
	.byte	0
	.byte	100
	.word	0
	.long	.LC111
	.long	.LC112
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC89
	.long	.LC90
	.word	410
	.byte	3
	.byte	0
	.word	1552
	.long	.LC91
	.long	.LC92
	.word	410
	.byte	4
	.byte	0
	.word	1540
	.long	.LC93
	.long	.LC94
	.word	410
	.byte	5
	.byte	0
	.word	1539
	.long	.LC95
	.long	.LC96
	.word	410
	.byte	6
	.byte	0
	.word	1543
	.text
.LC113:
	.string	"Table"
.LC114:
	.string	"TBL"
.LC115:
	.string	"Warp"
.LC116:
	.string	"WARP"
.LC117:
	.string	"Amount"
.LC118:
	.string	"AMT"
.LC119:
	.string	"Unison"
.LC120:
	.string	"UNI"
.LC121:
	.string	"Sub Osc"
.LC122:
	.string	"SUB"
.LC123:
	.string	"Cutoff"
.LC124:
	.string	"CUT"
.LC125:
	.string	"Resonance"
.LC126:
	.string	"RES"
	.text
	.align	2
	.type	cu_wtk, @object
	.size	cu_wtk, 112
cu_wtk:
	.long	.LC113
	.long	.LC114
	.word	410
	.byte	12
	.byte	1
	.word	2944
	.long	.LC98
	.long	.LC99
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC115
	.long	.LC116
	.word	410
	.byte	7
	.byte	0
	.word	260
	.long	.LC117
	.long	.LC118
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC119
	.long	.LC120
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC121
	.long	.LC122
	.word	101
	.byte	0
	.byte	0
	.word	0
	.long	.LC123
	.long	.LC124
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC125
	.long	.LC126
	.word	410
	.byte	0
	.byte	0
	.word	0
	.text
.LC127:
	.string	"Fine Tune"
.LC128:
	.string	"FINE"
.LC129:
	.string	"Start"
.LC130:
	.string	"STRT"
	.text
	.align	2
	.type	cu_p2k, @object
	.size	cu_p2k, 112
cu_p2k:
	.long	.LC59
	.long	.LC60
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC127
	.long	.LC128
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC129
	.long	.LC130
	.word	410
	.byte	0
	.byte	0
	.word	0
	.long	.LC53
	.long	.LC54
	.word	410
	.byte	2
	.byte	0
	.word	259
	.long	.LC89
	.long	.LC90
	.word	410
	.byte	3
	.byte	0
	.word	1552
	.long	.LC91
	.long	.LC92
	.word	410
	.byte	4
	.byte	0
	.word	1540
	.long	.LC93
	.long	.LC94
	.word	410
	.byte	5
	.byte	0
	.word	1539
	.long	.LC95
	.long	.LC96
	.word	410
	.byte	6
	.byte	0
	.word	1543
	.text
.LC131:
	.string	"Instrument"
.LC132:
	.string	"INST"
.LC133:
	.string	"Release Trig"
.LC134:
	.string	"RTRG"
	.text
	.align	2
	.type	cu_srck, @object
	.size	cu_srck, 112
cu_srck:
	.long	.LC131
	.long	.LC132
	.word	410
	.byte	12
	.byte	0
	.word	2944
	.long	.LC67
	.long	.LC68
	.word	410
	.byte	0
	.byte	127
	.word	0
	.long	.LC69
	.long	.LC70
	.word	101
	.byte	0
	.byte	100
	.word	0
	.long	.LC133
	.long	.LC134
	.word	410
	.byte	1
	.byte	0
	.word	258
	.long	.LC47
	.long	.LC48
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC49
	.long	.LC50
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC84
	.long	.LC85
	.word	40
	.byte	0
	.byte	64
	.word	0
	.long	.LC71
	.long	.LC72
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
	.type	cu_dst, @object
	.size	cu_dst, 20
cu_dst:
	.string	"OFF"
	.zero	1
	.string	"DIN"
	.zero	1
	.string	"USBC"
	.string	"USBA"
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
	.globl	cu_mi_name
	.type	cu_mi_name, @object
	.size	cu_mi_name, 5
cu_mi_name:
	.string	"MIDI"
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
	.size	ls, 134
ls:
	.zero	134
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
	.local	din_drop
	.comm	din_drop,4,2
	.local	din_sent
	.comm	din_sent,4,2
	.local	ov_list
	.comm	ov_list,4,2
	.local	ov_n
	.comm	ov_n,4,2
	.local	ov_is
	.comm	ov_is,4,2
	.local	ov_vt
	.comm	ov_vt,4,2
	.text
.LC135:
	.string	"SoundBrowser"
.LC136:
	.string	"KitBrowserView"
.LC137:
	.string	"SongBrowserView"
.LC138:
	.string	"NameView"
.LC139:
	.string	"TapTempoView"
.LC140:
	.string	"ProjectManager"
.LC141:
	.string	"SoundManager"
.LC142:
	.string	"SampleManager"
.LC143:
	.string	"SongEditView"
.LC144:
	.string	"SoundSlotListView"
.LC145:
	.string	"SampleListView"
.LC146:
	.string	"TwoColumnMenu"
.LC147:
	.string	"SceneEditView"
.LC148:
	.string	"PerformanceEditView"
	.text
	.align	2
	.type	ov_names, @object
	.size	ov_names, 56
ov_names:
	.long	.LC135
	.long	.LC136
	.long	.LC137
	.long	.LC138
	.long	.LC139
	.long	.LC140
	.long	.LC141
	.long	.LC142
	.long	.LC143
	.long	.LC144
	.long	.LC145
	.long	.LC146
	.long	.LC147
	.long	.LC148
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
	.local	ar
	.comm	ar,70,2
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
	.string	" (8x\030"
	.ascii	"\0200"
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
	.local	ls_host_presets
	.comm	ls_host_presets,4,2
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
