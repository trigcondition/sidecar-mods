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
	lea (-32,%sp),%sp
	move.l 40(%sp),%d0
	movem.l #3196,(%sp)
	move.w 38(%sp),%d3
	move.l 44(%sp),%d2
	mulu.w #2531,%d1
	mulu.w #152,%d3
	move.l %d1,%a0
	add.l #1092966707,%a0
	mvz.w %d0,%d1
	lea (%a0,%d1.l*2),%a2
	moveq #127,%d1
	and.l -2147457096,%d1
	add.l %d3,%a2
	mulu.w #2531,%d1
	move.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0,%d3.l),%d1
	moveq #45,%d3
	cmp.l %d1,%d3
	jne .L25
	moveq #10,%d5
	cmp.l %d0,%d5
	jeq .L41
	tst.l %d0
	jeq .L27
.L25:
	mov3q.l #7,%d6
	cmp.l %d0,%d6
	jlt .L27
.L26:
	move.l sv+80,%a0
	tst.l %a0
	jeq .L27
	move.l (%a0),%a3
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	move.l 156(%a3),%a0
	jsr (%a0)
	addq.l #8,%sp
	move.l %d0,%d4
	tst.l %d0
	jle .L27
	tst.l %d2
	jlt .L28
	mov3q.l #-1,-(%sp)
	move.l 160(%a3),%a0
	move.l sv+80,-(%sp)
	jsr (%a0)
	addq.l #8,%sp
	move.l %d0,%a0
	tst.l %d0
	jeq .L28
	move.l (%a0),%a1
	move.l %d2,-(%sp)
	move.l %d4,-(%sp)
	move.l 60(%a1),%a0
	move.l %d0,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jge .L42
.L28:
	mov3q.l #-1,-(%sp)
	move.l %d4,-(%sp)
	move.l 84(%a3),%a0
	clr.l %d3
	move.l sv+80,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	move.l %d0,%d2
.L29:
	move.l %d2,%d1
	move.l #1481856080,%a0
	asr.l #8,%d1
	cmp.l 1073848892.l,%a0
	jne .L30
	move.l 1073848896,%a0
	mov3q.l #2,%d6
	move.l %d4,-(%sp)
	move.l %d1,32(%sp)
	jsr (%a0)
	move.b (%a2),%d5
	addq.l #4,%sp
	move.l %d0,%d4
	asr.l #8,%d4
	move.l 28(%sp),%d1
	move.l %d4,%a1
	subq.l #1,%a1
	move.w %d5,%a0
	cmp.l %a1,%d6
	jcs .L30
	move.l %d0,%d5
	mvz.b %d5,%d5
	move.l %d5,%a1
	tst.b %d0
	jeq .L30
	mvz.b %d1,%d1
	tst.l %d3
	jne .L31
	moveq #127,%d6
	move.l %a0,%d0
	and.l %d6,%d0
	mov3q.l #1,%d6
	cmp.l %d4,%d6
	jne .L32
	move.l %d5,%d2
	muls.l %d0,%d2
	asr.l #7,%d2
	cmp.l %d1,%d2
	jne .L34
.L33:
	move.l %d0,%d1
	lsl.l #7,%d1
	mvz.b 1(%a2),%d0
	lsr.l #1,%d0
.L60:
	or.l %d1,%d0
	jra .L24
.L41:
	clr.l %d0
	jra .L26
.L42:
	mov3q.l #1,%d3
	jra .L29
.L32:
	cmp.l %d1,%d0
	jeq .L33
	subq.l #3,%d4
	tst.l %d4
	jne .L38
	jra .L40
.L31:
	mov3q.l #3,%d0
	cmp.l %d4,%d0
	jne .L37
.L40:
	move.l %d2,%d3
	asr.l #1,%d3
	moveq #112,%d2
	and.l %d2,%d3
.L38:
	moveq #127,%d5
	cmp.l %d1,%d5
	jlt .L44
	move.l %d1,%d0
	lsl.l #7,%d0
.L39:
	or.l %d3,%d0
.L24:
	movem.l (%sp),#3196
	lea (32,%sp),%sp
	rts
.L37:
	subq.l #1,%d4
	tst.l %d4
	jne .L43
.L34:
	mvs.w %d1,%d1
	move.l %a1,%d2
	lsl.l #7,%d1
	lea -1(%a1,%d1.l),%a0
	move.l %a0,%d1
	divs.l %d2,%d1
.L43:
	clr.l %d3
	jra .L38
.L44:
	move.w #16256,%d0
	jra .L39
.L30:
	lsl.l #7,%d1
	asr.l #1,%d2
	moveq #127,%d6
	and.l %d6,%d2
	and.l #16256,%d1
	move.l %d1,%d0
	or.l %d2,%d0
	jra .L24
.L27:
	move.b (%a2),%d0
	mvz.b 1(%a2),%d1
	lsr.l #1,%d1
	lsl.l #7,%d0
	and.l #16256,%d0
	jra .L60
	.size	sv_word, .-sv_word
	.align	2
	.type	splash_end, @function
splash_end:
	tst.l st+972
	jeq .L61
	moveq #1,%d0
	lea (8,%sp),%a0
	move.l (%a0),st+988
	move.l 4(%sp),%a0
	clr.l st+972
	move.b %d0,32(%a0)
.L61:
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
	jne .L64
	move.b %d0,ps_pos
	mvz.b %d2,%d0
	move.b %d2,ps_hdr
	mov3q.l #1,%d3
	move.l %d0,%d1
	lsr.l #4,%d1
	cmp.l %d1,%d3
	jeq .L81
	moveq #11,%d3
	cmp.l %d1,%d3
	jeq .L66
	tst.l %d1
	jne .L82
.L85:
	mov3q.l #1,%d0
	jra .L65
.L66:
	cmp.l #179,%d0
	jhi .L67
.L68:
	mov3q.l #3,%d0
.L65:
	subq.l #1,%d0
	move.b %d0,ps_left
.L69:
	move.b %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L67:
	cmp.l #182,%d0
	jeq .L68
	cmp.l #180,%d0
	jeq .L83
	cmp.l #181,%d0
	jeq .L84
	cmp.l #184,%d0
	jeq .L85
.L82:
	mov3q.l #2,%d0
	jra .L65
.L81:
	moveq #10,%d0
	jra .L65
.L83:
	mov3q.l #6,%d0
	jra .L65
.L84:
	mov3q.l #5,%d0
	jra .L65
.L64:
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
	jcs .L70
	and.l %d3,%d0
	lea shs,%a0
	move.b %d2,(%a0,%d0.l)
	jra .L69
.L70:
	move.l %d0,%a0
	lea (80,%a0),%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #4,%d3
	cmp.l %a0,%d3
	jcs .L69
	mvz.b %d1,%d1
	mov3q.l #1,%d3
	cmp.l %d1,%d3
	jne .L72
	move.b %d2,ps_id
	jra .L69
.L72:
	move.b ps_id,%d3
	move.w %d3,%a0
	mvz.b %d3,%d3
	move.l %d3,%a1
	moveq #55,%d3
	cmp.l %a1,%d3
	jne .L73
	mvz.b %d0,%d3
	cmp.l #180,%d3
	jne .L74
	move.l %d1,%d0
	subq.l #2,%d0
.L75:
	lea sht,%a0
	move.b %d2,(%a0,%d0.l)
	tst.b ovt_on.l
	jeq .L69
	move.b ovt_col,%d2
	addq.l #1,uart_sub
	jra .L69
.L74:
	mov3q.l #3,%d1
	and.l %d1,%d0
	jra .L75
.L73:
	lea (-40,%a0),%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #3,%d3
	cmp.l %a0,%d3
	jcs .L76
	move.w #43,%a0
	mvz.b %d0,%d3
	sub.l %a1,%a0
	cmp.l #180,%d3
	jne .L77
	subq.l #2,%d1
.L78:
	move.l %a0,%d0
	lsl.l #2,%d0
	move.l %d0,%a1
	add.l #shp,%a1
	mvz.b ovp_on,%d0
	move.b %d2,(%a1,%d1.l)
	move.l %a0,%d1
	btst %d1,%d0
	jeq .L69
	addq.l #1,uart_sub
	lea ovp_col,%a1
.L98:
	move.b (%a0,%a1.l),%d2
	jra .L69
.L77:
	mov3q.l #3,%d1
	and.l %d0,%d1
	jra .L78
.L76:
	moveq #15,%d3
	cmp.l %a1,%d3
	jcs .L69
	mvz.b %d0,%d3
	cmp.l #180,%d3
	jne .L79
	subq.l #2,%d1
.L80:
	move.l %a1,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #sh,%a0
	move.b %d2,(%a0,%d1.l)
	tst.b ov_on.l
	jeq .L69
	addq.l #1,uart_sub
	lea ov_col,%a0
	jra .L98
.L79:
	mov3q.l #3,%d1
	and.l %d0,%d1
	jra .L80
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
	jcc .L101
	addq.l #1,sq+384
.L100:
	move.l (%sp)+,%a2
	rts
.L101:
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
	jeq .L103
	move.l %a2,%d0
	addq.l #8,%d0
.L104:
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
	jra .L100
.L103:
	move.l %a2,%d0
	add.l #9,%d0
	move.b 19(%sp),8(%a2)
	jra .L104
	.size	sq_event, .-sq_event
	.align	2
	.type	sq_grid, @function
sq_grid:
	move.l 1100949720,%a0
	move.l %a0,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L108
	tst.b 353(%a0)
	jeq .L108
	tst.b 360(%a0)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L105:
	rts
.L108:
	clr.l %d0
	jra .L105
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
	jcs .L112
	moveq #39,%d1
	cmp.l %d0,%d1
	jcs .L113
.L114:
	clr.l %d0
	jra .L111
.L112:
	move.l %d0,%d1
	mov3q.l #6,%d0
	add.l #-46,%d1
	cmp.l %d1,%d0
	jcs .L114
	moveq #75,%d0
	lsr.l %d1,%d0
	mov3q.l #1,%d1
	and.l %d1,%d0
.L111:
	rts
.L113:
	tst.l ls_host_presets
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L111
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
	jeq .L118
	tst.l %d0
	jeq .L118
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
.L118:
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
	jcs .L135
	move.w .L128(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&13
.L128:
	.word .L134-.L128
	.word .L135-.L128
	.word .L135-.L128
	.word .L135-.L128
	.word .L135-.L128
	.word .L135-.L128
	.word .L133-.L128
	.word .L132-.L128
	.word .L131-.L128
	.word .L130-.L128
	.word .L129-.L128
	.word .L135-.L128
	.word .L127-.L128
.L133:
	tst.l %d0
	jeq .L136
	move.l #cu_wtp2k,%d0
.L125:
	move.l (%sp)+,%d2
	rts
.L132:
	tst.l %d0
	jeq .L137
	move.l #cu_grp2k,%d0
	jra .L125
.L127:
	tst.l %d0
	jne .L142
	move.l #cu_srck,%d0
	jra .L125
.L131:
	tst.l %d0
	jeq .L139
	move.l #cu_lip2k,%d0
	jra .L125
.L130:
	tst.l %d0
	jeq .L140
	move.l #cu_cpp2k,%d0
	jra .L125
.L129:
	tst.l %d0
	jeq .L141
	move.l #cu_mip2k,%d0
	jra .L125
.L134:
	tst.l %d0
	jeq .L125
.L142:
	move.l #cu_p2k,%d0
	jra .L125
.L135:
	clr.l %d0
	jra .L125
.L136:
	move.l #cu_wtk,%d0
	jra .L125
.L137:
	move.l #cu_grk,%d0
	jra .L125
.L139:
	move.l #cu_lik,%d0
	jra .L125
.L140:
	move.l #cu_cpk,%d0
	jra .L125
.L141:
	move.l #cu_mik,%d0
	jra .L125
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
.L148:
	mvs.w (%a2)+,%d7
	cmp.l %d7,%d6
	jne .L144
	tst.l %a3
	jeq .L146
	mvz.b 10(%a3,%a0.l),%d1
.L146:
	addq.l #2,%a1
	lea (14,%a0),%a0
	moveq #112,%d7
	cmp.l %a0,%d7
	jne .L148
	cmp.l #441,%d6
	jne .L149
	moveq #12,%d1
.L149:
	move.l %d3,%d0
	moveq #127,%d7
	cmp.l %d3,%d7
	jge .L150
	moveq #127,%d0
.L151:
	addq.l #1,cu+4
	subq.l #1,%d1
	moveq #31,%d7
	cmp.l %d1,%d7
	jcs .L152
	move.w .L154(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&32
.L154:
	.word .L183-.L154
	.word .L182-.L154
	.word .L181-.L154
	.word .L180-.L154
	.word .L179-.L154
	.word .L178-.L154
	.word .L177-.L154
	.word .L176-.L154
	.word .L173-.L154
	.word .L175-.L154
	.word .L174-.L154
	.word .L173-.L154
	.word .L172-.L154
	.word .L171-.L154
	.word .L170-.L154
	.word .L169-.L154
	.word .L168-.L154
	.word .L167-.L154
	.word .L166-.L154
	.word .L165-.L154
	.word .L152-.L154
	.word .L164-.L154
	.word .L163-.L154
	.word .L162-.L154
	.word .L161-.L154
	.word .L160-.L154
	.word .L159-.L154
	.word .L158-.L154
	.word .L157-.L154
	.word .L156-.L154
	.word .L155-.L154
	.word .L153-.L154
.L144:
	mvs.w (%a1),%d7
	cmp.l %d7,%d6
	jne .L146
	tst.l %d0
	jeq .L146
	mvz.b 10(%a0,%d0.l),%d1
	jra .L146
.L150:
	tst.l %d3
	jge .L151
	clr.l %d0
	jra .L151
.L183:
	moveq #63,%d0
	cmp.l %d3,%d0
	jge .L200
	move.l #cu_loop+10,%d0
.L232:
	move.l %d0,44(%sp)
	move.l #cu_fmt_s,%d1
.L223:
	move.l %d1,40(%sp)
	jra .L219
.L200:
	move.l #cu_loop+5,%d0
	jra .L232
.L182:
	muls.w #3,%d0
	asr.l #7,%d0
	mulu.w #5,%d0
	add.l #cu_loop,%d0
.L230:
	move.l %d0,44(%sp)
	move.l #cu_fmt_s,%d3
	jra .L225
.L181:
	moveq #15,%d5
	cmp.l %d3,%d5
	jge .L185
	clr.l %d0
.L185:
	mulu.w #5,%d0
	add.l #cu_chd,%d0
.L236:
	move.l %d0,44(%sp)
	move.l #cu_fmt_s,%d7
	jra .L224
.L180:
	mov3q.l #3,%d1
	cmp.l %d3,%d1
	jge .L186
	clr.l %d0
.L186:
	move.l %d0,44(%sp)
	move.l #cu_fmt_inv,%d3
.L225:
	move.l %d3,40(%sp)
.L219:
	move.l %d2,36(%sp)
	movem.l (%sp),#3324
	lea (32,%sp),%sp
	jmp 1074365954
.L179:
	mov3q.l #2,%d5
	cmp.l %d3,%d5
	jge .L187
	clr.l %d0
.L187:
	move.l %d0,44(%sp)
	move.l #cu_fmt_spr,%d7
.L224:
	move.l %d7,40(%sp)
	jra .L219
.L178:
	move.l %d0,%d1
	mov3q.l #5,%d3
	subq.l #1,%d1
	cmp.l %d1,%d3
	jcs .L188
.L235:
	move.l %d0,44(%sp)
	move.l #cu_fmt_d,%d5
	jra .L226
.L188:
	move.l #cu_loop,%d7
	move.l %d7,44(%sp)
.L233:
	lea cu_fmt_s,%a0
.L227:
	move.l %a0,40(%sp)
	jra .L219
.L177:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_warp,%d0
.L221:
	move.l %d0,44(%sp)
	jra .L222
.L176:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #6,%d0
	add.l #cu_win,%d0
	jra .L232
.L175:
	moveq #119,%d5
	cmp.l %d3,%d5
	jlt .L189
	muls.w #99,%d0
	divs.l %d5,%d0
.L228:
	move.l %d0,44(%sp)
	move.l #cu_fmt_d,%d7
	jra .L224
.L189:
	lea cu_frz,%a0
	move.l %a0,44(%sp)
.L222:
	move.l #cu_fmt_s,%d0
.L220:
	move.l %d0,40(%sp)
	jra .L219
.L174:
	tst.l %d3
	jle .L190
	asr.l #4,%d0
	mulu.w #5,%d0
	add.l #cu_anim,%d0
	jra .L232
.L190:
	move.l #cu_off,%d3
.L229:
	move.l %d3,44(%sp)
	move.l #cu_fmt_s,%d5
	jra .L226
.L172:
	mvs.w %d0,%d0
	lsr.l #3,%d0
	and.l #262140,%d0
	add.l #cu_inpt,%d0
	jra .L236
.L171:
	mvs.w %d0,%d0
	asr.l #6,%d0
	mulu.w #5,%d0
	add.l #cu_mon,%d0
.L234:
	move.l %d0,44(%sp)
	jra .L233
.L170:
	tst.l %d3
	jle .L190
	muls.w #60,%d0
	moveq #126,%d3
	move.l #cu_fmt_db,%d5
	addq.l #3,%d0
	divs.l %d3,%d0
	add.l #-80,%d0
	move.l %d0,44(%sp)
.L226:
	move.l %d5,40(%sp)
	jra .L219
.L169:
	asr.l #1,%d0
	addq.l #1,%d0
	jra .L228
.L168:
	moveq #63,%d1
	cmp.l %d3,%d1
	jge .L191
	muls.w #48,%d0
	moveq #126,%d3
	add.l #-3009,%d0
	divs.l %d3,%d0
	tst.l %d0
	jeq .L205
.L231:
	move.l #cu_fmt_pd,%d1
.L194:
	move.l %d0,44(%sp)
	jra .L223
.L191:
	moveq #64,%d1
	moveq #-126,%d5
	sub.l %d0,%d1
	muls.w #48,%d1
	move.l %d1,%d0
	add.l #63,%d0
	divs.l %d5,%d0
.L205:
	move.l #cu_fmt_d,%d1
	jra .L194
.L167:
	muls.w #100,%d0
	moveq #127,%d7
	lea cu_fmt_pct,%a0
	add.l #63,%d0
	divs.l %d7,%d0
	move.l %d0,44(%sp)
	jra .L227
.L166:
	tst.l %d3
	jle .L190
.L152:
	move.l %d0,44(%sp)
	move.l #cu_fmt_d,%d0
	jra .L220
.L165:
	mvs.w %d0,%d0
	asr.l #3,%d0
	jeq .L193
	addq.l #1,%d0
	move.l %d0,44(%sp)
	move.l #cu_fmt_x,%d1
	jra .L223
.L164:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_tape,%d0
	jra .L236
.L163:
	muls.w #3,%d0
	lsr.l #5,%d0
	and.l #262140,%d0
	add.l #cu_dir,%d0
	jra .L234
.L162:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_cloop,%d0
	jra .L221
.L161:
	tst.l %d3
	jle .L193
	move.l %d0,44(%sp)
	move.l #cu_fmt_d,%d1
	jra .L223
.L159:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_dst,%d0
	jra .L230
.L158:
	mvs.w %d0,%d0
	asr.l #3,%d0
	addq.l #1,%d0
	jra .L235
.L157:
	tst.l %d3
	jle .L190
	add.l #-64,%d0
	moveq #64,%d7
	cmp.l %d3,%d7
	jge .L205
	jra .L231
.L156:
	tst.l %d3
	jle .L190
	subq.l #1,%d0
	move.l %d0,44(%sp)
	lea cu_fmt_d,%a0
	jra .L227
.L155:
	tst.l %d3
	jle .L190
	subq.l #1,%d0
	muls.w #127,%d0
	moveq #126,%d3
	divs.l %d3,%d0
	jra .L235
.L153:
	tst.l %d3
	jle .L190
	subq.l #1,%d0
	jra .L228
.L160:
	moveq #126,%d1
	cmp.l %d3,%d1
	jge .L195
	move.l #cu_hold,%d3
	jra .L229
.L195:
	tst.l %d3
	jgt .L228
.L193:
	move.l #cu_slc,%d3
	jra .L229
.L173:
	cmp.l #441,%d6
	jeq .L206
	add.l #-46,%d5
	mvz.b %d5,%d5
	mov3q.l #6,%d1
	cmp.l %d5,%d1
	jcs .L207
	lea CSWTCH.505,%a0
	mvs.b (%a0,%d5.l),%d1
.L196:
	tst.l %d3
	jle .L190
	asr.l #5,%d4
	mov3q.l #7,%d3
	mov3q.l #-1,%d5
	and.l %d3,%d4
	cmp.l %d1,%d5
	jeq .L197
	lea ux,%a1
	lea (%a1,%d1.l),%a0
	mvz.b 3948(%a0),%d3
	cmp.l %d3,%d4
	jne .L197
	mvz.w #1280,%d3
	moveq #10,%d7
	muls.l %d0,%d7
	muls.l %d1,%d3
	move.l %d7,%a0
	add.l %d3,%a0
	tst.b 40(%a1,%a0.l)
	jeq .L197
	mulu.w #10,%d0
	mulu.w #1280,%d1
	move.l %d0,%a0
	lea 40(%a0,%d1.l),%a0
	move.l %a0,%d0
	add.l %a1,%d0
	jra .L221
.L206:
	clr.l %d1
	jra .L196
.L207:
	mov3q.l #-1,%d1
	jra .L196
.L197:
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
.L238:
	lea (%a2,%d0.l),%a4
	moveq #84,%d2
	move.l %d1,%a3
	move.l (%a4),(%a3,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d2
	jne .L238
	tst.b 10(%a1)
	jeq .L239
	lea cu_text,%a2
	move.l %a2,32(%a3)
.L239:
	move.w 12(%a1),%d0
	move.l (%a1),40(%a0)
	move.l 4(%a1),48(%a0)
	clr.l 8(%a0)
	move.l 28(%sp),44(%a0)
	move.l %d0,%d1
	and.l #2048,%d1
	btst #11,%d0
	jeq .L242
	mvz.w #32736,%d0
.L240:
	move.l %d0,12(%a0)
	mvz.b 11(%a1),%d0
	lsl.l #8,%d0
	move.l %d0,16(%a0)
	tst.w %d1
	jeq .L237
	mov3q.l #1,20(%a0)
.L237:
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	rts
.L242:
	mvz.w #32512,%d0
	jra .L240
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
	jeq .L247
	moveq #40,%d1
	cmp.l %d3,%d1
	jeq .L247
	move.l #1094564988,%a0
.L249:
	move.l (%a0),%d1
	addq.l #4,%a0
	move.l %d1,-68(%a0)
	move.l %d1,-100(%a0)
	move.l %d1,-132(%a0)
	move.l %d1,-164(%a0)
	move.l %d1,-196(%a0)
	cmp.l #1094565020,%a0
	jne .L249
	mvz.b cu+8,%d1
	cmp.l %d1,%d3
	jeq .L250
.L252:
	move.l %d3,%d5
	move.l %d0,%d6
	add.l #-46,%d5
	lea cu_src,%a2
	add.l #112,%d6
	move.l %d0,%d2
	move.l #1075575064,%a3
	lea CSWTCH.503,%a5
	lea cu_knob,%a4
.L251:
	mov3q.l #6,%d0
	cmp.l %d5,%d0
	jcs .L254
	move.l (%a5,%d5.l*4),%d0
.L253:
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
	jne .L251
	move.b %d3,cu+8
	jra .L247
.L250:
	move.l 1075595808,%d1
	move.l %d0,%a0
	cmp.l 4(%a0),%d1
	jne .L252
	move.l 1075596276,%d1
	cmp.l 102(%a0),%d1
	jne .L252
	cmp.l 1075595760.l,%d3
	jne .L252
.L247:
	movem.l (%sp),#15484
	lea (36,%sp),%sp
	rts
.L254:
	move.l #cu_fm_short,%d0
	jra .L253
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
	jle .L264
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
	jgt .L265
	mvz.b %d3,%d0
	mov3q.l #2,%d2
	add.l #-48,%d0
	cmp.l %d0,%d2
	jcs .L265
	move.b %d3,cu+9
	move.b %d1,cu+10
	lea st+8,%a0
	move.l (%a0),cu+16
.L265:
	clr.l %d0
.L263:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L264:
	tst.l %d2
	jge .L267
	mvz.b cu+9,%d0
	moveq #50,%d1
	cmp.l %d0,%d1
	jne .L268
	mvz.b cu+10,%d1
	move.l %d2,%d0
	not.l %d0
	cmp.l %d1,%d0
	jeq .L277
.L268:
	mvz.b cu+11,%d0
	neg.l %d2
	cmp.l %d0,%d2
	jne .L265
	move.l st+8,%d0
	mov3q.l #3,%d2
	sub.l cu+24,%d0
	cmp.l %d0,%d2
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L263
.L267:
	cmp.l #441,%d2
	jeq .L278
	lea cu_src,%a0
	clr.l %d3
.L270:
	mvs.w (%a0),%d1
	cmp.l %d1,%d2
	jne .L269
	mvz.b cu+8,%d0
	clr.l -(%sp)
	move.l %d0,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L265
	mulu.w #14,%d3
	move.l %d0,%a0
	mvz.w 12(%a0,%d3.l),%d0
	jra .L263
.L269:
	addq.l #2,%a0
	addq.l #1,%d3
	moveq #8,%d1
	cmp.l %d3,%d1
	jne .L270
	mvz.b %d0,%d0
	moveq #11,%d4
	cmp.l %d0,%d4
	jge .L271
	clr.l %d0
.L271:
	moveq #127,%d1
	and.l -2147457096,%d1
	mulu.w #152,%d0
	mulu.w #2531,%d1
	move.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0,%d0.l),%d3
	mvz.b cu+1,%d0
	cmp.l %d3,%d0
	jne .L265
	mov3q.l #1,-(%sp)
	move.l %d3,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L265
	move.l 1075596172,%d1
	move.l %d0,%a0
	cmp.l 102(%a0),%d1
	jne .L265
	lea cu_p2,%a0
	clr.l %d1
.L272:
	mvs.w (%a0),%d4
	cmp.l %d4,%d2
	jne .L273
	moveq #40,%d2
	cmp.l %d3,%d2
	jne .L276
	mov3q.l #3,%d2
	cmp.l %d1,%d2
	jge .L265
.L276:
	mulu.w #14,%d1
	move.l %d0,%a0
	mvz.w 12(%a0,%d1.l),%d0
	jra .L263
.L273:
	addq.l #2,%a0
	addq.l #1,%d1
	moveq #8,%d4
	cmp.l %d1,%d4
	jne .L272
	jra .L265
.L277:
	mov3q.l #1,%d0
	jra .L263
.L278:
	mvz.w #2944,%d0
	jra .L263
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
.L293:
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr (%a2)
	addq.l #1,%a6
	addq.l #4,%d2
	addq.l #8,%sp
	moveq #16,%d0
	cmp.l %a6,%d0
	jne .L293
	move.l %sp,%d2
	sub.l %a6,%a6
	lea shs,%a3
	add.l #22,%d2
	lea rui_uart_raw,%a2
.L295:
	move.b (%a3,%a6.l),%d0
	mvz.b %d0,%d1
	cmp.l #255,%d1
	jeq .L294
	move.l %a6,%d1
	moveq #32,%d3
	or.l %d3,%d1
	move.b %d0,23(%sp)
	move.b %d1,22(%sp)
	move.l %d2,-(%sp)
	mov3q.l #2,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
.L294:
	addq.l #1,%a6
	mov3q.l #4,%d0
	cmp.l %a6,%d0
	jne .L295
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
	jne .L302
	lea txsx_wait,%a2
	jsr (%a2)
	move.l %d0,%d2
	tst.l %d0
	jeq .L303
	addq.l #1,st+40
.L302:
	clr.l %d2
.L301:
	move.l %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L303:
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L305
	addq.l #1,st+40
	jra .L301
.L305:
	jsr (%a2)
	tst.l %d0
	jne .L306
	mvz.w #4027,%d0
	cmp.l 1094562392.l,%d0
	jlt .L306
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L307:
	tst.l %a0
	jeq .L306
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L307
	move.l 12(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	mov3q.l #1,%d2
	addq.l #1,st+36
	jra .L301
.L306:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #1,st+40
	addq.l #4,%sp
	jra .L301
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
.L316:
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
	jgt .L316
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
	jne .L319
	mvz.b mr+18,%d0
	cmp.l -12(%fp),%d0
	jeq .L318
.L319:
	pea 8.w
	pea -8(%fp)
	move.b -9(%fp),-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L318
	clr.b %d0
	lea (-9,%fp),%a0
	move.b (%a0),mr+18
	move.b %d0,mr+19
	move.w mr+20,%d0
	addq.l #1,%d0
	move.w %d0,mr+20
.L318:
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
.L326:
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
	jeq .L325
	addq.l #1,%d1
.L325:
	lea (152,%a1),%a1
	cmp.l #1824,%a1
	jne .L326
	tst.b mr+12.l
	jne .L327
	sub.l %a0,%a0
.L328:
	lea (%a2,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a3,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L328
	moveq #127,%d0
	and.l -2147457096,%d0
	move.b %d0,mr+18
	moveq #1,%d0
	move.b %d0,mr+12
.L329:
	mov3q.l #1,%a6
	jra .L324
.L327:
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L330
	move.b %d0,mr+13
.L331:
	move.l %a2,-(%sp)
	pea 12.w
	clr.l -(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L324
	sub.l %a0,%a0
.L334:
	lea (%a2,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a3,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L334
	clr.b %d0
	move.b %d0,mr+13
	move.w mr+16,%d0
	addq.l #1,%d0
	move.w %d0,mr+16
	jsr kit_tick
.L324:
	move.l %a6,%d0
	movem.l (%sp),#23556
	lea (32,%sp),%sp
	rts
.L330:
	clr.l %d2
	tst.b mr+13.l
	jne .L331
.L332:
	mvz.b (%a3,%d2.l),%d0
	mvz.b (%a2)+,%d1
	cmp.l %d1,%d0
	jeq .L336
	pea 20(%sp)
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L324
	lea (-1,%a2),%a0
	move.b (%a0),(%a3,%d2.l)
	move.w mr+14,%d0
	addq.l #1,%d0
	move.w %d0,mr+14
.L336:
	addq.l #1,%d2
	moveq #12,%d0
	cmp.l %d2,%d0
	jne .L332
	jsr kit_tick
	jra .L329
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
.L355:
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
	jeq .L350
	clr.w %d7
	lea ar+48,%a3
	move.w %d7,(%a5,%d1.l*2)
	moveq #127,%d1
	and.l -2147457096,%d1
	mvz.b (%a3,%a6.l),%d6
	cmp.l %d6,%d1
	jne .L350
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
.L350:
	move.b 1(%a0),%d6
	move.b (%a0),%d0
	lsl.l #2,%d6
	mvz.b %d0,%d1
	and.l #768,%d6
	or.l %d1,%d6
	mvz.w (%a2),%d1
	cmp.l %d1,%d6
	jne .L351
	mvz.w ar+60,%d1
	move.l %a6,%d7
	btst %d7,%d1
	jeq .L352
.L351:
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
	jeq .L349
	move.w %d6,(%a2)
	move.l %a6,%d1
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	addq.l #1,ar+62
	move.w ar+60,%d1
	not.l %d0
	and.l %d1,%d0
	move.w %d0,ar+60
.L352:
	addq.l #1,%a6
	add.l #152,%d5
	addq.l #2,%a2
	add.l #162,%d4
	moveq #12,%d6
	cmp.l %a6,%d6
	jne .L355
.L349:
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
.L364:
	lea (%a1,%d0.l),%a2
	move.b (%a2),-9(%fp,%d0.l)
	move.l %d0,%a0
	addq.l #1,%d0
	cmp.l 16(%fp),%d0
	jne .L364
	moveq #-9,%d0
	move.b %d0,-8(%fp,%a0.l)
	pea 9(%a0)
	pea -16(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L363
	addq.l #1,sq+456
.L363:
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
.L374:
	moveq #15,%d3
	cmp.l %d0,%d3
	jcs .L389
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
	jeq .L375
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
.L375:
	addq.l #1,%d1
	cmp.l #256,%d1
	jne .L374
.L389:
	tst.b %d2
	jeq .L373
	move.l %a0,kq_owes
	move.l %d0,st+196
.L373:
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
	jeq .L391
	move.l st+8,%d0
	cmp.l #16383,%d0
	jls .L392
	mvz.w #16383,%d0
.L392:
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
	jeq .L390
	clr.b %d0
	addq.l #1,st+968
	move.b %d0,st+992
.L391:
	tst.b st+161.l
	jeq .L394
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
	jeq .L390
	clr.b %d1
	move.b %d1,st+161
.L394:
	lea ls+4,%a0
	clr.l %d2
	move.l %fp,%d3
	move.l #-260222380,%a3
	lea ls,%a2
	add.l #-12,%d3
	move.l %a0,-16(%fp)
.L396:
	cmp.l ls+24.l,%d2
	jcs .L399
.L398:
	move.w %d2,%d0
	move.l ls+24,%d1
	move.l %d1,-16(%fp)
	mulu.w #5,%d0
	lea (%a2,%d0.l),%a0
	move.l %d2,%d0
.L400:
	cmp.l -16(%fp),%d0
	jcs .L401
	move.l -16(%fp),%d1
	sub.l %d2,%d1
	move.l %d1,-16(%fp)
	move.l %d1,ls+24
	tst.l %d1
	jne .L390
	lea st+164,%a2
	move.l %a2,%a4
.L402:
	move.l -16(%fp),%a0
	cmp.l st+196.l,%a0
	jcc .L406
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
	jne .L403
.L406:
	move.l st+196,%d0
	move.l -16(%fp),%d1
.L404:
	cmp.l %d0,%d1
	jcs .L407
	sub.l -16(%fp),%d0
	move.l %d0,st+196
	tst.l %d0
	jne .L390
	move.l kq_owes,%d2
	tst.l %d2
	jeq .L408
	movem.l -36(%fp),#7180
	unlk %fp
	jra (kq_owed_in.part.0)
.L399:
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
	jeq .L398
	addq.l #5,-16(%fp)
	addq.l #1,%d2
	jra .L396
.L401:
	addq.l #5,%a0
	addq.l #5,%a2
	move.b -1(%a0),-1(%a2)
	addq.l #1,%d0
	move.b (%a0),(%a2)
	move.b 1(%a0),1(%a2)
	move.b 2(%a0),2(%a2)
	move.b 3(%a0),3(%a2)
	jra .L400
.L403:
	addq.l #2,%a4
	addq.l #1,-16(%fp)
	jra .L402
.L407:
	move.l -16(%fp),%a1
	addq.l #1,%d1
	move.b (%a2,%a1.l*2),(%a2)
	lea 1(%a2,%a1.l*2),%a0
	addq.l #2,%a2
	move.b (%a0),-1(%a2)
	jra .L404
.L408:
	lea st+96,%a2
.L413:
	move.l (%a2)+,-16(%fp)
	tst.l -16(%fp)
	jeq .L409
	moveq #-63,%d0
	cmp.l -16(%fp),%d0
	jle .L410
	moveq #-63,%d1
.L430:
	move.l %d1,-16(%fp)
.L411:
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
	jeq .L390
	move.l -16(%fp),%d1
	sub.l %d1,-4(%a2)
	move.l st+64,%d1
	tst.l %d1
	jeq .L409
	move.l -66650100,%d0
	sub.l %d1,%d0
	move.l %d0,st+68
	add.l %d0,st+316
	addq.l #1,st+320
	cmp.l st+324.l,%d0
	jls .L412
	move.l %d0,st+324
.L412:
	clr.l st+64
.L409:
	addq.l #1,%d2
	moveq #16,%d0
	cmp.l %d2,%d0
	jne .L413
.L390:
	movem.l -36(%fp),#7180
	unlk %fp
	rts
.L410:
	moveq #63,%d0
	cmp.l -16(%fp),%d0
	jge .L411
	moveq #63,%d1
	jra .L430
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
	jeq .L431
	move.l ed+64,%d0
	move.l %d0,%a0
	mov3q.l #7,%d2
	sub.l ed+68,%a0
	cmp.l %a0,%d2
	jcc .L433
	addq.l #1,ed+72
.L431:
	move.l (%sp)+,%d2
	rts
.L433:
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
	jcc .L434
	lea (-16,%a1),%a1
	mov3q.l #1,%d2
	cmp.l %a1,%d2
	jcc .L434
	mvz.b 1093765506,%d0
	moveq #11,%d2
	cmp.l %d0,%d2
	jcc .L435
.L434:
	moveq #127,%d0
.L436:
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
	jra .L431
.L435:
	move.b 1093765506,%d0
	jra .L436
	.size	ed_queue, .-ed_queue
	.align	2
	.type	ls_queue, @function
ls_queue:
	mvz.b ls+124,%d0
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	mov3q.l #-1,-(%sp)
	move.l %d0,-(%sp)
	lea ls,%a2
	mvz.b ls+1,%d0
	move.l %d0,-(%sp)
	jsr sv_word
	lea (12,%sp),%sp
	move.l ls+24,%a0
	mov3q.l #3,%d1
	cmp.l %a0,%d1
	jcc .L441
	addq.l #1,ls+92
.L440:
	move.l (%sp)+,%a2
	move.l (%sp)+,%a3
	rts
.L441:
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
	jra .L440
	.size	ls_queue, .-ls_queue
	.align	2
	.type	ls_close, @function
ls_close:
	lea ls,%a0
	tst.b ls.l
	jeq .L443
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
.L443:
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
	jeq .L446
	mvz.b ls+125,%d1
	cmp.l %d1,%d0
	jeq .L446
	mov3q.l #3,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L448:
	clr.l %d0
.L445:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L446:
	or.l st+972,%d0
	jne .L448
	tst.b %d2
	jne .L449
	tst.b sv.l
	jeq .L448
	tst.b sv+8.l
	jeq .L448
	move.b sv+2,%d4
	mvz.b %d4,%d3
	move.l %d3,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L450
	moveq #45,%d1
	cmp.l %d3,%d1
	jne .L445
.L450:
	lea sv+1,%a0
	moveq #45,%d0
	move.b (%a0),ls+1
	move.b %d4,ls+2
	cmp.l %d3,%d0
	jne .L451
	moveq #10,%d2
.L451:
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
.L452:
	mov3q.l #1,%d0
	jra .L445
.L449:
	move.l 20(%sp),%d0
	addq.l #1,ls+84
	add.l %d0,st+96
	jsr flush
	jra .L452
	.size	ls_enc, .-ls_enc
	.align	2
	.type	pj_push, @function
pj_push:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.l 20(%sp),%d1
	move.l 24(%sp),%a1
#APP
| 4335 "rui.c" 1
	tas pj+136
	smi %d2
| 0 "" 2
#NO_APP
	tst.b %d2
	jeq .L457
	addq.l #1,pj+156
.L456:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L457:
	move.l pj,%d3
	move.l %d3,%d0
	sub.l pj+4,%d0
	lsr.l #5,%d0
	jeq .L459
	addq.l #1,pj+156
.L460:
	clr.b %d0
	move.b %d0,pj+136
	jra .L456
.L459:
	moveq #31,%d0
	and.l %d3,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #pj+8,%a0
	move.b 19(%sp),(%a0)
	moveq #127,%d0
	cmp.l %d1,%d0
	jcs .L463
	move.l %d1,%d0
	addq.l #1,%d0
.L461:
	move.b %d0,1(%a0)
	moveq #127,%d4
	cmp.l %a1,%d4
	jcs .L462
	move.l %a1,%d2
	addq.l #1,%d2
.L462:
	move.b %d2,2(%a0)
	addq.l #1,%d3
	move.l %d3,pj
	jra .L460
.L463:
	clr.b %d0
	jra .L461
	.size	pj_push, .-pj_push
	.align	2
	.type	led_restore, @function
led_restore:
	tst.b ov_on.l
	jeq .L464
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L466
	addq.l #1,st+1018
.L464:
	rts
.L466:
	clr.b %d0
	move.b %d0,ov_on
	jsr led_stock
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #4,%sp
	move.l st+8,%d0
	addq.l #4,%d0
	tst.l %d0
	jne .L467
	mov3q.l #1,%d0
.L467:
	move.l %d0,led_again
	addq.l #1,st+1014
	jra .L464
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
	jge .L475
	mvz.b 5(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L475
	mvz.b -1(%a0,%d0.l),%d1
	cmp.l #247,%d1
	jeq .L473
.L475:
	addq.l #1,rx_bad
	jra .L474
.L473:
	move.b 4(%a0),%d2
	move.l %d0,%d1
	moveq #39,%d4
	subq.l #7,%d1
	move.l %d2,%d3
	add.l #-40,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d4
	jcs .L475
	move.w .L477(%pc,%d3.l*2),%a1
	jmp %pc@(2,%a1:l)
	.balignw 2,0x284c
	.swbeg	&40
.L477:
	.word .L495-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L494-.L477
	.word .L493-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L492-.L477
	.word .L475-.L477
	.word .L491-.L477
	.word .L490-.L477
	.word .L489-.L477
	.word .L488-.L477
	.word .L487-.L477
	.word .L475-.L477
	.word .L486-.L477
	.word .L485-.L477
	.word .L484-.L477
	.word .L483-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L482-.L477
	.word .L481-.L477
	.word .L480-.L477
	.word .L479-.L477
	.word .L475-.L477
	.word .L478-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L475-.L477
	.word .L476-.L477
.L489:
	mov3q.l #4,%d5
	cmp.l %d1,%d5
	jge .L569
	move.b 7(%a0),%d6
	moveq #15,%d7
	mvz.b %d6,%d3
	move.b %d6,-40(%fp)
	cmp.l %d3,%d7
	jcs .L569
	mvz.b 8(%a0),%d5
	mov3q.l #7,%d1
	cmp.l %d5,%d1
	jcs .L569
	move.b 9(%a0),%d1
	jeq .L569
	move.b 10(%a0),%d2
	jeq .L569
	mvz.b %d1,%d4
	add.l %d4,%d3
	moveq #16,%d4
	cmp.l %d3,%d4
	jlt .L569
	mvz.b %d2,%d3
	move.l %d5,%d4
	moveq #8,%d6
	add.l %d3,%d4
	cmp.l %d4,%d6
	jlt .L569
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
	jne .L569
	mvs.b -40(%fp),%d0
	lea (11,%a0),%a3
	lsl.l #6,%d0
	move.l %d0,%a1
	add.l %d5,%a1
	add.l #staging,%a1
	clr.l %d0
.L500:
	move.l %d1,%d2
	mov3q.l #7,%d4
	cmp.l %d1,%d4
	jge .L497
	mov3q.l #7,%d2
.L497:
	move.l %a3,%a2
	sub.l %d2,%d1
	mvz.b (%a2)+,%d4
	move.l %a3,-44(%fp)
	addq.l #1,-44(%fp)
	sub.l %a2,%a2
.L499:
	move.l %d4,%d5
	lsr.l #1,%d4
	move.b 1(%a3,%a2.l),%d6
	lsl.l #7,%d5
	or.l %d6,%d5
	move.b %d5,(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d3,%d0
	jne .L498
	addq.l #8,%a1
	clr.l %d0
.L498:
	addq.l #1,%a2
	cmp.l %d2,%a2
	jne .L499
	move.l -44(%fp),%a3
	add.l %d2,%a3
	tst.l %d1
	jgt .L500
	moveq #1,%d7
	addq.l #6,%a0
	move.b (%a0),st_seq
	move.b %d7,st_valid
.L486:
	addq.l #1,rx
	jra .L474
.L488:
	tst.l %d1
	jeq .L475
	tst.b st_valid.l
	jeq .L502
	mvz.b 6(%a0),%d1
	mvz.b st_seq,%d0
	cmp.l %d1,%d0
	jne .L502
	addq.l #1,sh_seq
	pea 256.w
	pea staging
	pea shadow
	lea copy32,%a2
	jsr (%a2)
	pea 704.w
	pea txt_st
	pea txt_sh
	jsr (%a2)
	move.l #-66650100,%a0
	lea (24,%sp),%sp
	addq.l #1,sh_seq
	addq.l #1,commits
	move.l (%a0),t_commit
.L502:
	clr.b %d0
	move.b %d0,st_valid
	jra .L486
.L487:
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jge .L475
	tst.b 7(%a0)
	jeq .L504
	moveq #1,%d3
	move.b %d3,host_open
	jra .L486
.L504:
	moveq #1,%d4
	move.b %d4,host_close
	jra .L486
.L478:
	subq.l #2,%d1
	tst.l %d1
	jne .L475
	mvz.b 6(%a0),%d0
	moveq #127,%d6
	cmp.l %d0,%d6
	jne .L506
	mvz.b 7(%a0),%d0
	mov3q.l #1,%d7
	cmp.l %d0,%d7
	jcs .L475
	move.l %d0,ls_host_presets
	jra .L486
.L506:
	moveq #11,%d1
	cmp.l %d0,%d1
	jcs .L475
	mvz.b 7(%a0),%d0
	lsr.l #1,%d0
	jne .L475
	mvz.w 6(%a0),%d0
	move.l %d0,ls_in_v
	addq.l #1,ls_in_gen
	jra .L486
.L495:
	subq.l #6,%d1
	tst.l %d1
	jne .L475
	move.l %a0,%d0
	add.l #12,%d0
	lea (6,%a0),%a1
.L510:
	tst.b (%a1)
	jlt .L475
	addq.l #1,%a1
	cmp.l %a1,%d0
	jne .L510
	addq.l #1,pc_seq
	clr.l %d0
	lea pc_req,%a1
.L511:
	lea 6(%a0,%d0.l),%a2
	mov3q.l #6,%d1
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L511
	addq.l #1,pc_seq
	jra .L486
.L492:
	tst.l %d1
	jeq .L475
	move.b 6(%a0),%d0
	mov3q.l #1,%d3
	mvz.b %d0,%d2
	cmp.l %d2,%d3
	jcs .L475
	jne .L513
	moveq #17,%d4
	cmp.l %d1,%d4
	jne .L475
	move.l %a0,%d1
	add.l #23,%d1
	lea (7,%a0),%a1
.L516:
	mvz.b (%a1),%d2
	moveq #111,%d5
	cmp.l %d2,%d5
	jcs .L475
	addq.l #1,%a1
	cmp.l %a1,%d1
	jne .L516
.L513:
	addq.l #1,led_gen
	move.b %d0,led_req_mode
	clr.l %d0
	lea led_req,%a1
.L517:
	mvz.b 6(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L518
	moveq #16,%d3
	cmp.l %d0,%d3
	jne .L519
.L518:
	addq.l #1,led_gen
	jra .L486
.L519:
	lea 7(%a0,%d0.l),%a2
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	jra .L517
.L494:
	moveq #14,%d4
	cmp.l %d0,%d4
	jcs .L475
	mvz.w #21504,%d2
	btst %d0,%d2
	jeq .L475
	mvz.b 7(%a0),%d0
	moveq #31,%d5
	cmp.l %d0,%d5
	jcs .L475
	mov3q.l #4,%d6
	cmp.l %d1,%d6
	jge .L521
	mvz.b 10(%a0),%d0
	cmp.l %d0,%d5
	jcs .L475
	mov3q.l #7,%d7
	cmp.l %d1,%d7
	jne .L521
	mvz.b 12(%a0),%d0
	cmp.l %d0,%d5
	jcs .L475
.L521:
	addq.l #1,sq_gen
	clr.l %d0
	lea sq_req,%a1
.L523:
	cmp.l %d1,%d0
	jge .L584
	moveq #127,%d3
	move.b 6(%a0,%d0.l),%d2
	and.l %d3,%d2
.L522:
	move.b %d2,(%a1,%d0.l)
	addq.l #1,%d0
	mov3q.l #7,%d4
	cmp.l %d0,%d4
	jne .L523
	addq.l #1,sq_gen
	jra .L486
.L584:
	clr.b %d2
	jra .L522
.L481:
	subq.l #2,%d1
	tst.l %d1
	jne .L475
	mvz.b 7(%a0),%d0
	moveq #31,%d6
	cmp.l %d0,%d6
	jcs .L475
	lsl.l #7,%d0
	mvz.b 6(%a0),%d1
	addq.l #1,pin+56
	or.l %d0,%d1
	move.l %d1,pin+4
	jra .L486
.L480:
	move.l %d0,%d2
	moveq #14,%d7
	add.l #-10,%d2
	rems.l %d7,%d5:%d2
	tst.l %d5
	jne .L585
	mov3q.l #3,%a1
.L526:
	mov3q.l #2,%d2
	cmp.l %d1,%d2
	jge .L527
	move.b 6(%a0),%d4
	mvz.b %d4,%d3
	cmp.l %d3,%d2
	jcs .L527
	move.b 7(%a0),%d2
	mvz.b %d2,%d6
	lsr.l #1,%d6
	jne .L527
	tst.l %d5
	jeq .L528
	add.l #-11,%d0
	moveq #14,%d6
	rems.l %d6,%d5:%d0
	tst.l %d5
	jne .L527
.L528:
	mov3q.l #4,%d7
	cmp.l %a1,%d7
	jne .L529
	mvz.b 9(%a0),%d0
	lsr.l #3,%d0
	jeq .L529
.L527:
	addq.l #1,ux+12
	jra .L475
.L585:
	mov3q.l #4,%a1
	jra .L526
.L529:
	move.b %d4,%d0
	ext.w %d0
	tst.b %d2
	jne .L530
	move.l %d3,%a2
	add.l #ux,%a2
	mvz.b 3948(%a2),%d4
	mov3q.l #4,%d6
	cmp.l %a1,%d6
	jne .L531
	mvz.b 9(%a0),%d2
	cmp.l %d4,%d2
	jeq .L532
.L530:
	move.w %d0,%d2
	mulu.w #1280,%d2
	move.l %d2,%a2
	add.l #ux+40,%a2
	mvz.w #128,%d2
	move.l %a2,-40(%fp)
.L533:
	move.l -40(%fp),%a3
	moveq #10,%d4
	subq.l #1,%d2
	add.l %d4,-40(%fp)
	clr.b (%a3)
	tst.l %d2
	jne .L533
	mov3q.l #4,%d5
	cmp.l %a1,%d5
	jne .L586
.L532:
	move.b 9(%a0),%d2
.L534:
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
.L535:
	move.l %a1,%d0
	add.l #12,%d0
	cmp.l %d1,%d0
	jlt .L540
	addq.l #1,ux+8
	jra .L486
.L586:
	clr.b %d2
	jra .L534
.L540:
	move.b 6(%a3),%d0
	jmi .L536
	ext.w %d0
	move.l %d4,%a0
	mulu.w #10,%d0
	lea 40(%a0,%d0.l),%a2
	sub.l %a0,%a0
	add.l #ux,%a2
.L537:
	move.b 7(%a3,%a0.l),%d3
	moveq #94,%d5
	move.l %d3,%d2
	add.l #-32,%d2
	mvz.b %d2,%d2
	cmp.l %d2,%d5
	jcs .L538
	move.b %d3,(%a2,%a0.l)
	addq.l #1,%a0
	moveq #9,%d0
	cmp.l %a0,%d0
	jne .L537
.L538:
	clr.b %d6
	move.b %d6,(%a2,%a0.l)
.L536:
	lea (14,%a3),%a3
	lea (14,%a1),%a1
	jra .L535
.L476:
	move.b 6(%a0),%d2
	moveq #96,%d0
	moveq #64,%d7
	and.l %d2,%d0
	cmp.l %d0,%d7
	jne .L587
	tst.l %d1
	jeq .L475
	mov3q.l #1,%d3
	mov3q.l #2,%d0
.L541:
	cmp.l %d1,%d0
	jne .L475
	mvz.b %d2,%d0
	moveq #111,%d4
	cmp.l %d0,%d4
	jcs .L475
	moveq #-128,%d0
	or.l %d2,%d0
	move.b %d0,-32(%fp)
	move.b 7(%a0),-31(%fp)
	tst.l %d3
	jne .L588
	move.b 8(%a0),%d0
.L544:
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
	jne .L545
	tst.l %d3
	jne .L591
	tst.b 8(%a0)
	jeq .L591
	mvz.w #512,%d0
.L546:
	add.l %a1,%d0
	cmp.l %d0,%d4
	jge .L547
	addq.l #1,din_drop
	jra .L486
.L587:
	clr.l %d3
	mov3q.l #3,%d0
	jra .L541
.L588:
	clr.b %d0
	jra .L544
.L545:
	lsr.l #5,%d2
	jeq .L591
	mvz.w #1536,%d0
	jra .L546
.L591:
	moveq #8,%d0
	jra .L546
.L547:
	mov3q.l #3,-(%sp)
	pea -32(%fp)
	move.l %d1,-(%sp)
	jsr 1074288478
	lea (12,%sp),%sp
	addq.l #1,din_sent
	jra .L486
.L482:
	subq.l #3,%d1
	tst.l %d1
	jne .L475
	mvz.b 6(%a0),%d0
	moveq #11,%d1
	cmp.l %d0,%d1
	jcs .L475
	tst.b 7(%a0)
	jlt .L475
	mvz.b 8(%a0),%d1
	lsr.l #3,%d1
	jne .L475
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
	jra .L486
.L479:
	move.l ux+3880,%d3
	add.l #-10,%d0
	mov3q.l #2,%d4
	cmp.l %d0,%d4
	jcs .L475
	move.b 6(%a0),%d2
	moveq #11,%d5
	mvz.b %d2,%d0
	cmp.l %d0,%d5
	jcs .L475
	mvz.b 7(%a0),%d0
	lsr.l #4,%d0
	jne .L475
	tst.b 8(%a0)
	jlt .L475
	mov3q.l #3,%d7
	cmp.l %d1,%d7
	jge .L552
	tst.b 9(%a0)
	jlt .L475
	mov3q.l #5,%d0
	cmp.l %d1,%d0
	jne .L552
	tst.b 10(%a0)
	jlt .L475
.L552:
	move.l %d3,%d0
	sub.l ux+3884,%d0
	lea ux,%a1
	lsr.l #3,%d0
	jeq .L553
	addq.l #1,ux+28
	jra .L486
.L553:
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
	jlt .L554
	clr.b %d6
	move.b %d6,3891(%a2)
.L555:
	clr.b %d1
.L557:
	add.l %d0,%a1
	addq.l #1,%d3
	move.b %d1,3952(%a1)
	move.l %d3,ux+3880
	addq.l #1,ux+16
	jra .L486
.L554:
	move.b 9(%a0),3891(%a2)
	subq.l #5,%d1
	tst.l %d1
	jne .L555
	move.b 10(%a0),%d1
	jra .L557
.L493:
	subq.l #4,%d1
	tst.l %d1
	jne .L475
	move.l %a0,%d1
	add.l #10,%d1
	lea (6,%a0),%a1
.L560:
	mvz.b (%a1),%d0
	moveq #111,%d2
	cmp.l %d0,%d2
	jcc .L559
	moveq #127,%d3
	cmp.l %d0,%d3
	jne .L475
.L559:
	addq.l #1,%a1
	cmp.l %d1,%a1
	jne .L560
	addq.l #1,pg_gen
	clr.l %d0
	lea pg_req,%a1
.L561:
	lea 6(%a0,%d0.l),%a2
	mov3q.l #4,%d1
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L561
	addq.l #1,pg_gen
	jra .L486
.L491:
	tst.l %d1
	jeq .L475
	move.b 6(%a0),%d0
	moveq #127,%d2
	and.l %d2,%d0
	bset #8,%d0
	move.l %d0,splash_req
	jra .L486
.L490:
	move.l %d0,%a2
	moveq #37,%d3
	lea (-10,%a2),%a2
	cmp.l %a2,%d3
	jcs .L475
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
.L564:
	cmp.l %d2,%a2
	jgt .L567
	mvz.w %d1,%d1
	lea (-32,%fp),%a0
	clr.l %d0
	lea mask_keys,%a1
	move.l %d1,mask_enc
.L568:
	move.l (%a0)+,(%a1,%d0.l*4)
	moveq #8,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L568
	mov3q.l #1,mask_set
	addq.l #1,masks
	jra .L486
.L567:
	move.w %d2,%d3
	mvz.b 9(%a0,%d2.l),%d5
	clr.l %d0
	mulu.w #7,%d3
.L566:
	btst %d0,%d5
	jeq .L565
	cmp.l #255,%d3
	jgt .L565
	moveq #31,%d6
	mov3q.l #1,%d7
	and.l %d3,%d6
	lsl.l %d6,%d7
	move.l %d3,%d6
	asr.l #5,%d6
	or.l %d7,-32(%fp,%d6.l*4)
.L565:
	addq.l #1,%d0
	addq.l #1,%d3
	mov3q.l #7,%d7
	cmp.l %d0,%d7
	jne .L566
	addq.l #1,%d2
	jra .L564
.L485:
	mov3q.l #5,%d2
	cmp.l %d1,%d2
	jge .L569
	move.b 7(%a0),%d1
	moveq #63,%d3
	mvz.b %d1,%d2
	cmp.l %d2,%d3
	jcs .L569
	move.b 8(%a0),%d4
	jmi .L569
	mvz.b 9(%a0),%d3
	lsr.l #6,%d3
	jne .L569
	mvz.b 10(%a0),%d3
	moveq #16,%d6
	cmp.l %d3,%d6
	jcs .L569
	add.l #-13,%d0
	moveq #32,%d7
	cmp.l %d0,%d7
	jge .L592
.L569:
	clr.b %d0
	addq.l #1,rx_bad
	move.b %d0,st_valid
.L474:
	move.l -66650100,%d0
	addq.l #1,mt_calls
	sub.l -36(%fp),%d0
	add.l %d0,mt_sum
	cmp.l mt_max.l,%d0
	jls .L602
	move.l %d0,mt_max
.L602:
	movem.l -76(%fp),#3324
	mov3q.l #1,%d0
	unlk %fp
	rts
.L572:
	move.b 12(%a0,%a1.l),%d3
	moveq #94,%d5
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcc .L571
	clr.b %d6
	addq.l #1,rx_bad
	move.b %d6,st_valid
	jra .L474
.L571:
	addq.l #1,%a1
.L570:
	cmp.l %d0,%a1
	jlt .L572
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
.L573:
	cmp.l %d0,%d1
	jlt .L574
	clr.b %d1
	lea txt_st,%a3
	addq.l #6,%a0
	add.l %d2,%a3
	moveq #1,%d2
	move.b %d1,8(%a3,%d0.l)
	move.b %d2,st_valid
	move.b (%a0),st_seq
	jra .L486
.L592:
	sub.l %a1,%a1
	jra .L570
.L574:
	lea 12(%a0,%d1.l),%a2
	move.b (%a2),8(%a1,%d1.l)
	addq.l #1,%d1
	jra .L573
.L484:
	tst.l %d1
	jeq .L475
	lea txt_st+4,%a1
	moveq #64,%d0
.L576:
	clr.b (%a1)
	subq.l #1,%d0
	lea (44,%a1),%a1
	tst.l %d0
	jne .L576
	moveq #1,%d3
	addq.l #6,%a0
	move.b (%a0),st_seq
	move.b %d3,st_valid
	jra .L486
.L483:
	mov3q.l #5,%d4
	cmp.l %d1,%d4
	jge .L475
	move.b 6(%a0),%d1
	moveq #15,%d6
	mvz.b %d1,%d5
	cmp.l %d5,%d6
	jcs .L475
	add.l #-13,%d0
	moveq #11,%d7
	cmp.l %d0,%d7
	jlt .L475
	lea bind_gen,%a2
	addq.l #1,(%a2,%d5.l*4)
	move.b 7(%a0),%d3
	mvz.b %d3,%d4
	lsr.l #6,%d4
	jeq .L579
	st %d3
.L579:
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
.L580:
	cmp.l %d0,%d1
	jlt .L582
	mvz.b 6(%a0),%d0
	addq.l #1,(%a2,%d0.l*4)
	jra .L486
.L582:
	move.b 12(%a0,%d1.l),%d3
	moveq #94,%d5
	move.l %d3,%d4
	add.l #-32,%d4
	mvz.b %d4,%d4
	cmp.l %d4,%d5
	jcc .L581
	move.b %d2,%d3
.L581:
	move.b %d3,6(%a1,%d1.l)
	addq.l #1,%d1
	jra .L580
.L531:
	tst.l %d4
	jne .L530
	jra .L534
	.size	rui_sysex, .-rui_sysex
	.align	2
	.type	ov_suffix, @function
ov_suffix:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	clr.l %d0
.L635:
	move.l 20(%sp),%a0
	tst.b (%a0,%d0.l)
	jne .L636
	cmp.l %d1,%d0
	jle .L641
.L639:
	clr.l %d0
.L634:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L636:
	addq.l #1,%d0
	jra .L635
.L640:
	move.l 20(%sp),%a2
	mvs.b (%a0,%a1.l),%d2
	mvs.b (%a2,%a1.l),%d1
	cmp.l %d2,%d1
	jne .L639
	addq.l #1,%a1
.L637:
	cmp.l %a1,%d0
	jne .L640
	mov3q.l #1,%d0
	jra .L634
.L641:
	add.l 12(%sp),%d1
	sub.l %a1,%a1
	move.l %d1,%a0
	sub.l %d0,%a0
	jra .L637
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
	jne .L643
.L655:
	move.l ov_is,%d0
	jra .L642
.L643:
	move.l %d0,%d1
	add.l #-1073742852,%d1
	move.l %d0,ov_vt
	clr.l ov_is
	clr.l ov_list
	addq.l #1,ov_n
	cmp.l #2997243,%d1
	jls .L645
.L646:
	clr.l %d0
.L642:
	movem.l (%sp),#7180
	lea (20,%sp),%sp
	rts
.L645:
	mov3q.l #3,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L646
	move.l %d0,%a0
	move.l -4(%a0),%d0
	move.l %d0,%d1
	add.l #-1073742848,%d1
	cmp.l #2997247,%d1
	jhi .L646
	btst #0,%d0
	jne .L646
	move.l %d0,%a0
	move.l 4(%a0),%a2
	move.l %a2,%d0
	add.l #-1073742848,%d0
	cmp.l #2997247,%d0
	jhi .L646
.L647:
	move.b (%a2),%d0
	moveq #9,%d1
	add.l #-48,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jcc .L648
	clr.l %d2
.L649:
	tst.b (%a2,%d2.l)
	jne .L650
	pea .LC5
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	lea ov_suffix,%a3
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L652
	pea .LC0
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L652
	pea .LC1
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
.L652:
	pea .LC2
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	move.l %d0,ov_list
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L653
	moveq #17,%d1
	cmp.l %d2,%d1
	jne .L654
	pea .LC3
	pea 17.w
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	mov3q.l #1,%d1
	eor.l %d1,%d0
.L654:
	move.l %d0,ov_is
	jra .L655
.L648:
	addq.l #1,%a2
	jra .L647
.L650:
	addq.l #1,%d2
	moveq #48,%d0
	cmp.l %d2,%d0
	jne .L649
	jra .L646
.L653:
	pea .LC4
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L656
	mov3q.l #1,ov_is
	jra .L655
.L656:
	lea ov_names,%a4
	clr.l %d3
.L660:
	move.l (%a4)+,%a0
	clr.l %d0
.L657:
	tst.b (%a0,%d0.l)
	jne .L658
	cmp.l %d0,%d2
	jne .L659
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L659
	mov3q.l #1,ov_is
.L659:
	addq.l #1,%d3
	moveq #14,%d0
	cmp.l %d3,%d0
	jne .L660
	jra .L655
.L658:
	addq.l #1,%d0
	jra .L657
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
.L672:
	tst.l %d6
	jeq .L684
	cmp.l %d6,%a4
	jeq .L684
	move.l %d6,%a0
	move.l 8(%a0),%d7
	tst.l %d7
	jeq .L673
	move.l %d7,%a0
	move.l (%a0),%d2
	tst.l %d5
	jeq .L674
	cmp.l #1075718412,%d2
	jeq .L675
	cmp.l #1075712228,%d2
	jeq .L675
	cmp.l #1075719596,%d2
	jeq .L675
	cmp.l #1075717140,%d2
	jne .L674
.L675:
	move.l %d6,%a0
	move.l (%a0),%d6
.L676:
	addq.l #1,%d3
	moveq #16,%d2
	cmp.l %d3,%d2
	jne .L672
.L684:
	cmp.l sv+84.l,%d0
	jne .L688
	cmp.l sv+88.l,%a3
	jeq .L689
.L688:
	move.l %d0,sv+84
	move.l %a3,sv+88
	clr.l sv+96
.L690:
	move.l %d3,sv+92
	tst.l %d1
	jeq .L691
	moveq #16,%d4
	cmp.l %d3,%d4
	jeq .L691
	tst.l %d6
	jne .L692
.L691:
	clr.l sv+80
.L673:
	clr.l %d2
.L696:
	tst.b sv.l
	jeq .L698
	clr.b %d1
	lea sv+1,%a0
	moveq #1,%d3
	move.b (%a0),sv+5
	addq.l #1,sv+60
	move.b %d1,sv
	move.b %d1,sv+6
	move.b %d3,sv+4
	jra .L698
.L674:
	move.l %d2,%a3
	cmp.l #1075721468,%d2
	jne .L677
	move.l %d7,sv+80
	mov3q.l #1,%d1
.L678:
	tst.l %d5
	jeq .L680
	lea sv_covers,%a1
	sub.l %a0,%a0
.L681:
	cmp.l (%a1),%d2
	jne .L683
.L721:
	move.l %d5,%a6
.L680:
	cmp.l #1076055292,%d2
	seq %d0
	move.l %d6,%a0
	move.l (%a0),%d6
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d5
	move.l %d7,%d0
	jra .L676
.L677:
	cmp.l #1075720560,%d2
	jne .L679
	mov3q.l #2,%d0
	or.l %d0,%d1
	jra .L678
.L679:
	cmp.l #1075628548,%d2
	jne .L678
	move.l %d7,%a0
	move.l %a6,%d4
	tst.b 127(%a0)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d4
	move.l %d4,%a6
	jra .L678
.L683:
	addq.l #4,%a1
	addq.l #1,%a0
	moveq #8,%d0
	cmp.l %a0,%d0
	jne .L681
	move.l %d2,-(%sp)
	move.l %d1,52(%sp)
	jsr overlay
	addq.l #4,%sp
	move.l 48(%sp),%d1
	tst.l %d0
	jne .L721
	move.l %d5,%a5
	jra .L680
.L689:
	move.l sv+96,%d0
	cmp.l #65534,%d0
	jhi .L690
	addq.l #1,%d0
	move.l %d0,sv+96
	jra .L690
.L692:
	mov3q.l #1,%d2
	eor.l %d5,%d2
	move.l %a6,%d0
	or.l %d0,%d2
	tst.l %a5
	jeq .L694
	cmp.l #1076055292,%a3
	jeq .L694
	moveq #59,%d3
	cmp.l sv+96.l,%d3
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d2
.L694:
	btst #0,%d1
	jeq .L691
	mvz.b 47(%sp),%d5
	moveq #11,%d4
	cmp.l %d5,%d4
	jlt .L673
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
	jeq .L696
	tst.b %d6
	jeq .L697
	mvz.b sv+1,%d0
	cmp.l %d5,%d0
	jne .L697
	mvz.b sv+2,%d0
	cmp.l %d0,%d3
	jeq .L698
.L697:
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
.L698:
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	seq %d4
	move.b sv,%d5
	neg.l %d4
	move.b %d4,sv+3
	tst.b %d5
	jeq .L701
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jeq .L702
.L701:
	mov3q.l #-1,%d0
.L703:
	move.l 60(%sp),%d3
	move.l %d0,sv+116
	cmp.l sv+20.l,%d3
	jeq .L709
	clr.l sv+16
	sub.l %a1,%a1
.L710:
	move.l 60(%sp),%a0
	move.l sv+12,%d1
	move.l st+4,%d7
	move.l st+972,%d6
	move.l %a0,sv+20
	tst.b %d5
	jeq .L711
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	jne .L712
.L711:
	clr.l %d3
.L713:
	cmp.l commits.l,%d1
	sne %d0
	tst.l %d7
	sne %d7
	tst.l %d6
	sne %d6
	add.l %d4,%d4
	move.w %d3,%a0
	move.b %d3,sv+8
	neg.l %d0
	neg.l %d7
	lsl.l #2,%d0
	lsl.l #4,%d7
	neg.l %d6
	lsl.l #5,%d6
	or.l %d7,%d0
	or.l %d5,%d0
	or.l %d6,%d0
	or.l %d4,%d0
	moveq #19,%d4
	cmp.l %a1,%d4
	scs %d1
	mvz.b sv+101,%d4
	neg.l %d1
	lsl.l #3,%d1
	or.l %d1,%d0
	move.l %d3,%d1
	lsl.l #6,%d1
	or.l %d1,%d0
	mvz.b %d0,%d1
	cmp.l %d4,%d1
	jne .L714
	move.l sv+104,%d1
	cmp.l sv+88.l,%d1
	jne .L714
	tst.l %d2
	jeq .L715
	move.l st+8,%d1
	moveq #19,%d4
	sub.l sv+108,%d1
	cmp.l %d1,%d4
	jge .L715
.L714:
	moveq #1,%d1
	move.b %d1,sv+102
.L715:
	move.w %a0,%d4
	move.b %d0,sv+100
	mvz.b sv+9,%d1
	mvz.b %d4,%d0
	cmp.l %d0,%d1
	jeq .L671
	tst.l %d3
	jeq .L717
	addq.l #1,sv+72
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
.L718:
	move.w %a0,%d1
	moveq #1,%d2
	move.b %d1,sv+9
	move.b %d2,32(%a2)
.L671:
	movem.l (%sp),#31996
	lea (52,%sp),%sp
	rts
.L702:
	move.l 1100949720,%a3
	move.l %a3,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L701
	jsr sq_grid
	tst.l %d0
	jeq .L701
	move.l 348(%a3),%d1
	tst.l %d1
	jeq .L774
	clr.l %d0
	jra .L704
.L706:
	addq.l #1,%d0
.L704:
	btst %d0,%d1
	jeq .L706
	jra .L703
.L774:
	move.l 344(%a3),%d1
	clr.l %d0
	tst.l %d1
	jeq .L701
.L707:
	btst %d0,%d1
	jeq .L708
	add.l #32,%d0
	jra .L703
.L708:
	addq.l #1,%d0
	jra .L707
.L709:
	move.l sv+16,%a1
	cmp.l #65534,%a1
	jhi .L710
	addq.l #1,%a1
	move.l %a1,sv+16
	jra .L710
.L712:
	cmp.l commits.l,%d1
	jeq .L711
	moveq #19,%d3
	cmp.l %a1,%d3
	jcs .L711
	move.l %d7,%d3
	or.l %d6,%d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
	jra .L713
.L717:
	subq.l #2,%d2
	tst.l %d2
	jne .L718
	addq.l #1,sv+76
	jra .L718
	.size	sv_tick, .-sv_tick
	.align	2
	.type	enter, @function
enter:
	move.l %d2,-(%sp)
	move.b 15(%sp),%d1
	tst.l st+4
	jne .L775
	tst.l st+972
	jeq .L777
	clr.l st+972
	mov3q.l #6,st+988
.L777:
	lea commits,%a0
	moveq #16,%d0
	move.l (%a0),st+24
	mov3q.l #1,st+4
	clr.l st+12
	mov3q.l #-1,st+20
	lea st+96,%a0
	addq.l #1,st+48
.L778:
	clr.l (%a0)+
	subq.l #1,%d0
	tst.l %d0
	jne .L778
	lea st+408,%a0
.L779:
	clr.l (%a0)+
	moveq #16,%d2
	addq.l #1,%d0
	cmp.l %d0,%d2
	jne .L779
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
.L775:
	move.l (%sp)+,%d2
	rts
	.size	enter, .-enter
	.align	2
	.type	leave, @function
leave:
	move.l %d2,-(%sp)
	move.b 15(%sp),%d1
	tst.l st+4
	jeq .L782
	clr.l st+4
	clr.l st+1038
	addq.l #1,st+52
	clr.l st+1058
	clr.l st+196
	tst.l nk
	jeq .L784
	moveq #-33,%d0
	moveq #32,%d2
	and.l %d0,st+240
	or.l %d2,st+272
	clr.l nk
.L784:
	clr.l %d0
	lea kq_nodown,%a1
	lea kq_owed,%a0
.L785:
	clr.l (%a1,%d0.l)
	moveq #32,%d2
	clr.l (%a0,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d2
	jne .L785
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
	jne .L786
	clr.l st+1006
	jsr led_restore
.L786:
	moveq #1,%d0
	move.l 8(%sp),%a0
	move.b %d0,32(%a0)
.L782:
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
	jeq .L789
	move.l st+8,%d0
	mov3q.l #1,txsx_test_on
	add.l txsx_test,%d0
	clr.l txsx_test
	move.l %d0,txsx_test_end
.L789:
	tst.l kq_owes
	jeq .L790
	jsr (kq_owed_in.part.0)
.L790:
	moveq #31,%d1
	mov3q.l #1,%d0
	and.l %d3,%d1
	move.l %d3,%d2
	lsr.l #5,%d2
	lea kq_nodown,%a0
	move.l (%a0,%d2.l*4),%d4
	lsl.l %d1,%d0
	tst.l 28(%sp)
	jeq .L791
	move.l %d0,%d1
	not.l %d1
	and.l %d4,%d1
	move.l %d1,(%a0,%d2.l*4)
	tst.l kq_owes
	jne .L792
	move.l st+196,%d1
	moveq #15,%d5
	move.l %d1,%a1
	addq.l #6,%a1
	cmp.l %a1,%d5
	jcc .L793
.L792:
	or.l %d0,%d4
	addq.l #1,st+44
	move.l %d4,(%a0,%d2.l*4)
.L788:
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L791:
	move.l %d4,%d1
	and.l %d0,%d1
	tst.l %d1
	jeq .L795
	not.l %d0
	and.l %d4,%d0
	move.l %d0,(%a0,%d2.l*4)
	jra .L788
.L795:
	move.l st+196,%d1
	moveq #15,%d4
	cmp.l %d1,%d4
	jcc .L793
	move.l %d1,%a1
	subq.l #1,%a1
	lea st+164,%a0
.L796:
	tst.l %a1
	jlt .L797
	mvz.b (%a0,%a1.l*2),%d4
	cmp.l %d4,%d3
	jne .L798
	move.l %a1,%d3
	add.l %d3,%d3
	move.l %d3,%d4
	add.l #st,%d4
	move.l %d4,%a2
	tst.b 165(%a2)
	jeq .L797
	add.l %d3,%a0
.L799:
	addq.l #1,%a1
	cmp.l %d1,%a1
	jlt .L800
	subq.l #1,%d1
	move.l %d1,st+196
	addq.l #1,st+44
	jra .L788
.L798:
	subq.l #1,%a1
	jra .L796
.L800:
	addq.l #2,%a0
	move.b (%a0),-2(%a0)
	move.b 1(%a0),-1(%a0)
	jra .L799
.L797:
	lea kq_owed,%a0
	move.l (%a0,%d2.l*4),%d1
	move.l %d1,%d3
	and.l %d0,%d3
	tst.l %d3
	jne .L788
	or.l %d0,%d1
	addq.l #1,kq_owes
	move.l %d1,(%a0,%d2.l*4)
	jra .L788
.L793:
	lea st,%a0
	move.l %d1,%d0
	add.l #82,%d0
	move.b %d3,(%a0,%d0.l*2)
	lea (%a0,%d1.l*2),%a0
	addq.l #1,%d1
	move.l %d1,st+196
	move.b 31(%sp),165(%a0)
	jra .L788
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
	jeq .L804
	move.l %d3,-(%sp)
	jsr cu_src_setup
	mvz.b cu+1,%d0
	move.l %d3,%d4
	addq.l #4,%sp
	add.l #-46,%d4
	cmp.l %d0,%d3
	jne .L806
	move.l 1075597888,%d0
	cmp.l 4(%a3),%d0
	jne .L806
	move.l 1075596172,%d0
	cmp.l 102(%a3),%d0
	jne .L806
	move.l 1075597884,%d1
	mov3q.l #6,%d0
	cmp.l %d4,%d0
	jcs .L810
	lea CSWTCH.503,%a0
	move.l (%a0,%d4.l*4),%d0
.L807:
	cmp.l %d0,%d1
	jeq .L804
.L806:
	move.l %a3,%d5
	move.l %a3,%d2
	lea cu_p2,%a2
	add.l #112,%d5
	lea CSWTCH.503,%a4
	lea cu_knob,%a3
.L809:
	mov3q.l #6,%d0
	cmp.l %d4,%d0
	jcs .L811
	move.l (%a4,%d4.l*4),%d0
.L808:
	move.l %d0,-(%sp)
	mvs.w (%a2)+,%d0
	move.l %d2,-(%sp)
	add.l #14,%d2
	move.l %d0,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	cmp.l %d2,%d5
	jne .L809
	move.w cu+2,%d0
	move.b %d3,cu+1
	addq.l #1,%d0
	move.w %d0,cu+2
.L804:
	movem.l (%sp),#7228
	lea (28,%sp),%sp
	rts
.L810:
	move.l #cu_fm_short,%d0
	jra .L807
.L811:
	move.l #cu_fm_short,%d0
	jra .L808
	.size	cu_setup, .-cu_setup
	.align	2
	.type	isr_send, @function
isr_send:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jeq .L817
.L825:
	clr.l %d0
.L816:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L817:
#APP
| 1624 "rui.c" 1
	move.w %sr,%d0
| 0 "" 2
#NO_APP
	move.l %d0,%d3
	move.l %d0,%d2
	and.l #1792,%d3
	mvz.w %d2,%d2
	cmp.l #1279,%d3
	jhi .L819
	and.l #63743,%d0
	or.l #1280,%d0
#APP
| 1628 "rui.c" 1
	move.w %d0,%sr
| 0 "" 2
#NO_APP
.L819:
	tst.l 1123449384
	jeq .L820
.L822:
#APP
| 1633 "rui.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	addq.l #1,sq+388
	jra .L825
.L820:
	tst.l 1094562372
	jne .L822
	move.l %d1,%d0
	add.l 1094562392,%d0
	cmp.l #3800,%d0
	jgt .L822
	move.l 1094562704,%a0
	tst.l %a0
	jeq .L822
	move.l 52(%a0),%a0
	tst.l %a0
	jeq .L822
	move.l 52(%a0),%d0
	move.l 12(%sp),-(%sp)
	move.l %d1,-(%sp)
	jsr 1073752544
#APP
| 1633 "rui.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	mov3q.l #1,%d0
	addq.l #8,%sp
	jra .L816
	.size	isr_send, .-isr_send
	.align	2
	.globl	rui_render_in
	.type	rui_render_in, @function
rui_render_in:
	link.w %fp,#-108
	movem.l #1052,(%sp)
	tst.l 1094562372
	jne .L833
	mov3q.l #1,txsx_gap
.L833:
	lea fp,%a0
	addq.l #1,(%a0)
	tst.l fp+8
	jeq .L832
	move.l (%a0),%d0
	sub.l fp+4,%d0
	cmp.l #3000,%d0
	jls .L832
	move.l fp+8,%a0
	move.l fp,%d0
	move.l fp+4,%d1
	move.l 1123449124,%d3
	tst.l fp+12
	jeq .L835
	move.l fp,%a1
	sub.l fp+12,%a1
	cmp.l #7499,%a1
	jls .L832
.L835:
	cmp.l %a0,%d3
	seq %d2
	sub.l %d1,%d0
	lea (-90,%fp),%a1
	clr.l %d1
	move.l %a1,%a2
	neg.l %d2
.L836:
	clr.l (%a2)+
	moveq #9,%d4
	addq.l #1,%d1
	cmp.l %d1,%d4
	jne .L836
	cmp.l %a0,%d3
	jeq .L837
	mov3q.l #1,%d3
	move.l 72(%a0),%a0
	move.l %a0,%d1
	and.l %d3,%d1
	move.l %a0,%d4
	btst #0,%d4
	jne .L837
	move.l %a0,%d3
	add.l #-1073741824,%d3
	cmp.l #129892303,%d3
	jhi .L837
.L838:
	lea 4(%a0,%d1.l),%a2
	moveq #36,%d3
	move.l (%a2),(%a1,%d1.l)
	addq.l #4,%d1
	cmp.l %d1,%d3
	jne .L838
.L837:
	move.w #19969,%a0
	move.l #-260222380,%d4
	move.b %d2,-48(%fp)
	move.l %d4,-54(%fp)
	move.w %a0,-50(%fp)
	cmp.l #191999,%d0
	jhi .L843
	mvz.w #1500,%d2
	divu.l %d2,%d0
.L839:
	move.b %d0,-47(%fp)
	lea (-46,%fp),%a0
	clr.l %d1
.L840:
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
	jne .L840
	moveq #-9,%d1
	pea 54.w
	pea -54(%fp)
	move.b %d1,-1(%fp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L832
	lea fp,%a0
	tst.l (%a0)
	jeq .L844
	move.l (%a0),%d0
.L842:
	move.l %d0,fp+12
	addq.l #1,fp+16
.L832:
	movem.l -108(%fp),#1052
	unlk %fp
	rts
.L843:
	moveq #127,%d0
	jra .L839
.L844:
	mov3q.l #1,%d0
	jra .L842
	.size	rui_render_in, .-rui_render_in
	.align	2
	.globl	rui_uart
	.type	rui_uart, @function
rui_uart:
	lea (-40,%sp),%sp
	movem.l #19468,(%sp)
	clr.l %d2
	tst.b ov_on.l
	jne .L872
	tst.b ovp_on.l
	jne .L872
	tst.b ovt_on.l
	jeq .L859
.L872:
	move.l 44(%sp),%a0
	subq.l #1,%a0
	sub.l %a6,%a6
	lea rui_uart_raw,%a3
	move.l %a0,20(%sp)
	jra .L864
.L860:
	move.l 48(%sp),%a0
	mvz.b (%a0,%d2.l),%d0
	addq.l #1,%d2
	move.l %d0,-(%sp)
	jsr uart_byte
	addq.l #4,%sp
.L859:
	cmp.l 44(%sp),%d2
	jlt .L860
	clr.l %d0
.L857:
	movem.l (%sp),#19468
	lea (40,%sp),%sp
	rts
.L865:
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
	jeq .L862
	cmp.l 20(%sp),%a6
	jne .L863
.L862:
	pea 24(%sp)
	move.l %d3,-(%sp)
	jsr (%a3)
	addq.l #8,%sp
	clr.l %d3
.L863:
	addq.l #1,%a6
	move.l %d3,%d2
.L864:
	cmp.l 44(%sp),%a6
	jlt .L865
	mov3q.l #1,%d0
	jra .L857
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
	jcc .L874
.L878:
	clr.l %d0
.L873:
	move.l (%sp)+,%d2
	rts
.L874:
	tst.l sq
	jeq .L876
	move.l sq+4,%a0
	move.l %a0,%d2
	btst %d1,%d2
	jeq .L876
	addq.l #1,sq+448
	mov3q.l #1,%d0
	jra .L873
.L876:
	tst.l %d0
	jlt .L879
	moveq #63,%d2
	cmp.l %d0,%d2
	jlt .L880
.L877:
	lea pc,%a0
	move.b %d0,48(%a0,%d1.l)
	moveq #1,%d0
	lea st+8,%a1
	move.l (%a1),(%a0,%d1.l*4)
	move.b %d0,60(%a0,%d1.l)
	jra .L878
.L879:
	clr.b %d0
	jra .L877
.L880:
	moveq #63,%d0
	jra .L877
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
	jcs .L887
	mov3q.l #1,%d1
	cmp.l 1079807120.l,%d1
	jeq .L889
	clr.l sq+540
	clr.l sq+544
.L887:
	movem.l (%sp),#3132
	lea (24,%sp),%sp
	rts
.L889:
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
	jeq .L891
	mvz.b 516(%a0),%d1
	cmp.l %d4,%d1
	jeq .L892
.L893:
	clr.l %d0
.L891:
	mov3q.l #1,%d1
	lsl.l %d2,%d1
	move.l %a1,%d5
	move.b %d3,516(%a0)
	move.b 35(%sp),528(%a0)
	or.l %d1,%d5
	move.l sq+360,%d1
	move.l %d5,sq+540
	btst #8,%d1
	jeq .L895
	tst.l %d0
	jne .L887
	tst.l %d4
	jeq .L896
	tst.l sq+544
	jeq .L897
.L896:
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
.L897:
	lsr.l #7,%d4
	jne .L887
	tst.l (%a2)
	jeq .L887
	move.l sq+8,%d0
	btst %d2,%d0
	jeq .L887
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
	jne .L898
	mvz.w #917,%d0
	muls.l %d2,%d0
	add.l #709,%d0
	move.b (%a0,%d0.l),%d0
	jpl .L900
	moveq #127,%d0
.L900:
#APP
| 1624 "rui.c" 1
	move.w %sr,%d1
| 0 "" 2
#NO_APP
	move.l %d1,%d5
	move.l %d1,%d4
	and.l #1792,%d5
	mvz.w %d4,%d4
	cmp.l #1792,%d5
	jeq .L902
	and.l #63743,%d1
	or.l #1792,%d1
#APP
| 1628 "rui.c" 1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
.L902:
	move.l sq+268,%d1
	sub.l sq+272,%d1
	lsr.l #5,%d1
	jeq .L903
	addq.l #1,sq+380
.L904:
#APP
| 1633 "rui.c" 1
	move.w %d4,%sr
| 0 "" 2
#NO_APP
	jra .L887
.L892:
	mvz.b 528(%a0),%d1
	cmp.l 32(%sp),%d1
	jeq .L893
	addq.l #1,sq+548
	mov3q.l #1,sq+544
	jra .L891
.L895:
	tst.l %d0
	jne .L887
	jra .L897
.L898:
	move.l #85683,%d0
	move.b (%a0,%d0.l),%d0
	move.l #85684,%d1
	mvz.b (%a0,%d1.l),%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	moveq #127,%d1
	cmp.l %d0,%d1
	jcc .L900
	moveq #127,%d0
	jra .L900
.L903:
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
	jra .L904
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
	jcc .L918
	clr.l %d2
.L918:
	tst.l sq+348
	jne .L919
	move.l %d2,sq+352
	move.l %d3,sq+356
	mov3q.l #1,sq+348
.L919:
	lea sq,%a6
	tst.l (%a6)
	jeq .L920
	cmp.l sq+352.l,%d2
	jeq .L921
	move.l %d2,%d1
	mvz.b %d1,%d1
	move.l %d4,-(%sp)
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr sq_event
	lea (20,%sp),%sp
.L921:
	move.l sq+356,%d0
	cmp.l %d0,%d3
	jeq .L922
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jne .L923
	bset #8,%d0
	move.l %d0,sq+360
.L920:
	move.l %d2,sq+352
	move.l %d3,sq+356
.L925:
	tst.l sq+344
	jne .L930
	move.l %sp,%d3
	move.l %sp,%d2
	add.l #42,%d3
	add.l #36,%d2
.L931:
	move.l sq+272,%d4
	cmp.l sq+268.l,%d4
	jne .L937
.L936:
	move.l -66650100,%d0
	sub.l 32(%sp),%d0
	cmp.l sq+396.l,%d0
	jls .L917
	move.l %d0,sq+396
.L917:
	movem.l (%sp),#23612
	lea (104,%sp),%sp
	rts
.L923:
	mvz.b %d0,%d0
	move.l %d4,-(%sp)
	mov3q.l #2,-(%sp)
	move.l %d5,-(%sp)
	move.l %d0,-(%sp)
	mov3q.l #3,-(%sp)
	jsr sq_event
	lea (20,%sp),%sp
.L924:
	move.l sq+360,%d0
	btst #8,%d0
	jeq .L920
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
	jra .L920
.L922:
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jne .L924
	jra .L920
.L930:
	mvz.b sq+340,%d0
	move.l %d0,-(%sp)
	pea sq+276
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L917
	move.l sq+344,%d3
	clr.l %d1
	addq.l #1,sq+376
	lea sq+340,%a0
.L927:
	cmp.l %d3,%d0
	jlt .L929
	subq.l #1,%d3
	move.l %d3,sq+344
	jra .L925
.L929:
	mvz.w %d0,%d2
	lea sq+276,%a2
	sub.l %a1,%a1
	sub.l %d1,%a2
	lsl.l #4,%d2
.L928:
	move.l %a2,%d4
	add.l %d1,%d4
	move.l %d4,%a4
	addq.l #1,%a1
	move.b (%a4,%d2.l),(%a2)+
	moveq #16,%d4
	cmp.l %a1,%d4
	jne .L928
	move.b 1(%a0),(%a0)
	addq.l #1,%a0
	addq.l #1,%d0
	add.l #-16,%d1
	jra .L927
.L937:
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
.L932:
	move.l sq+272,%d0
	add.l %d4,%d0
	cmp.l sq+268.l,%d0
	jeq .L933
	moveq #14,%d0
	cmp.l %d4,%d0
	jeq .L933
	move.l sq+272,%d0
	moveq #31,%d1
	add.l %d4,%d0
	and.l %d1,%d0
	lsl.l #3,%d0
	cmp.l 12(%a6,%d0.l),%d5
	jeq .L934
.L933:
	move.b %d4,46(%sp)
	move.b #-9,(%a0)+
	sub.l %d2,%a0
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L936
	add.l %d4,sq+272
	addq.l #1,sq+372
	jra .L931
.L934:
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
	jra .L932
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
	jne .L958
	move.l pin+16,%d0
	move.l pin+12,%d1
	addq.l #1,pin+32
	move.l %d0,50(%sp)
	or.l 58(%sp),%d0
	or.l %d1,%d0
	jeq .L958
	move.l pin+20,%a1
	tst.l %a1
	jne .L960
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
.L960:
	clr.b %d4
	clr.b %d5
	sub.l %a0,%a0
	clr.l %d3
	move.l pin+8,%d2
	clr.l %d6
	move.l pin+48,%a6
	move.b %d4,63(%sp)
	move.b %d5,62(%sp)
.L974:
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
	jcs .L961
	move.l 58(%sp),%d5
	move.l %a4,%d7
	btst %d7,%d5
	jeq .L961
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
	jeq .L962
	move.l #128,(%a3)
	move.l #128,(%a2)
	move.l %a1,4(%a3)
	move.l %a1,4(%a2)
	tst.l %a5
	jeq .L963
	addq.l #1,pin+44
.L963:
	moveq #1,%d0
	and.l 54(%sp),%d2
	move.b %d0,62(%sp)
.L964:
	move.l 46(%sp),%a2
	add.l #-2147457816,%a2
	clr.l (%a2)
	cmp.l #32512,%d5
	jeq .L979
	cmp.l #255,%d5
	jls .L967
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
	jls .L968
	mvz.w #65535,%d4
.L968:
	mulu.w #32512,%d0
	move.w %d4,(%a3)
	divu.l %d5,%d0
	cmp.l #65535,%d0
	jls .L969
	mvz.w #65535,%d0
.L969:
	move.w %d0,(%a2)
.L967:
	moveq #1,%d0
	move.w #32512,(%a0)
	addq.l #1,%a6
	move.b %d0,63(%sp)
.L979:
	move.w #1,%a0
	jra .L966
.L962:
	tst.l %a5
	jeq .L965
	moveq #127,%d0
	moveq #127,%d4
	move.l %d0,(%a3)
	move.l pin+28,%d0
	move.l %d4,(%a2)
	move.l %d0,4(%a3)
	move.l %d0,4(%a2)
	jra .L964
.L965:
	moveq #1,%d4
	move.l pin+24,%d7
	move.l #1073741951,(%a3)
	move.l #1073741951,(%a2)
	move.l %d7,4(%a3)
	or.l %d0,%d2
	move.l %d7,4(%a2)
	addq.l #1,pin+40
	move.b %d4,62(%sp)
	jra .L964
.L961:
	move.l 50(%sp),%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L970
	move.l %d0,%d4
	not.l %d4
	and.l %d4,%d2
	moveq #1,%d4
	or.l %d0,%d1
	move.w #1,%a0
	move.b %d4,62(%sp)
.L970:
	move.l %d1,%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L966
	btst #6,(%a2)
	jeq .L972
	not.l %d0
	and.l %d0,%d1
	jra .L979
.L972:
	move.l #128,(%a3)
	move.l #128,(%a2)
	move.l %a1,4(%a3)
	move.l %a1,4(%a2)
.L966:
	addq.l #1,%d3
	moveq #8,%d5
	cmp.l %d3,%d5
	jne .L974
	tst.b 63(%sp)
	jeq .L975
	move.l %a6,pin+48
.L975:
	tst.b 62(%sp)
	jeq .L976
	move.l %d2,pin+8
.L976:
	move.w %a0,%d7
	tst.b %d7
	jeq .L977
	move.l %d1,pin+12
.L977:
	tst.l %d6
	jeq .L978
	addq.l #1,pin+36
.L978:
	move.l -66650100,%d0
	move.l %d6,pin+16
	sub.l 68(%sp),%d0
	cmp.l pin+52.l,%d0
	jls .L958
	move.l %d0,pin+52
.L958:
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
	jcc .L1006
.L1008:
	clr.l %d1
.L1007:
	move.l %d1,16(%sp)
	move.l %a0,%d1
	mvz.b %d1,%d1
	clr.l 12(%sp)
	move.l %d0,4(%sp)
	move.l %d1,8(%sp)
	jra ed_queue
.L1006:
	mvz.w #4368,%d1
	btst %d0,%d1
	jeq .L1008
	mov3q.l #3,%d1
	and.l 12(%sp),%d1
	jra .L1007
	.size	ed_report, .-ed_report
	.align	2
	.globl	pm_menu_add
	.type	pm_menu_add, @function
pm_menu_add:
	link.w %fp,#-68
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	tst.l 8(%fp)
	jeq .L1012
	lea (-64,%fp),%a2
	clr.l %d0
	move.l %a2,%a0
.L1014:
	clr.l 12(%a0)
	clr.l 8(%a0)
	clr.l (%a0)
	clr.l 4(%a0)
	addq.l #1,%d0
	lea (16,%a0),%a0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L1014
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
	jeq .L1012
	tst.l %a3
	jeq .L1012
	tst.l -32(%fp)
	jeq .L1012
	tst.l %d0
	jeq .L1012
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
.L1015:
	mvz.w -66(%fp),%d0
	lsl.l #4,%d0
	pea (%a2,%d0.l)
	jsr 1075251654
	subq.l #1,-68(%fp)
	addq.l #4,%sp
	mov3q.l #-1,%d0
	cmp.l -68(%fp),%d0
	jne .L1015
	addq.l #1,pm+4
.L1012:
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
	jcc .L1028
	addq.l #1,pm+24
	pea pm_t_track
.L1032:
	move.l %a0,-(%sp)
	jsr pm_popup
	addq.l #8,%sp
	rts
.L1028:
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L1030
	move.l commits,%d1
	cmp.l pm+28.l,%d1
	jne .L1031
.L1030:
	addq.l #1,pm+20
	pea pm_t_none
	jra .L1032
.L1031:
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
	jeq .L1033
	move.l 4(%sp),-(%sp)
	addq.l #1,cu+12
	jsr cu_src_setup
	move.l 8(%sp),%d0
	mov3q.l #2,%d1
	add.l #-48,%d0
	addq.l #4,%sp
	cmp.l %d0,%d1
	jcs .L1033
	moveq #11,%d0
	cmp.l 8(%sp),%d0
	jcs .L1033
	move.l #1075731444,%d1
	cmp.l sv+88.l,%d1
	jne .L1033
	lea (7,%sp),%a0
	move.b (%a0),cu+9
	lea (11,%sp),%a0
	move.b (%a0),cu+10
	lea st+8,%a0
	move.l (%a0),cu+16
.L1033:
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
	jne .L1037
	move.l st+8,%d0
	moveq #15,%d1
	sub.l cu+24,%d0
	cmp.l %d0,%d1
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1035:
	rts
.L1037:
	clr.l %d0
	jra .L1035
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
.L1039:
	mov3q.l #1,%d0
	cmp.l fp+20.l,%d0
	jeq .L1039
.L1040:
	mov3q.l #2,%d1
	cmp.l fp+20.l,%d1
	jeq .L1041
	move.l 1100667228,%d0
	cmp.l #cu_text,%d0
	jeq .L1042
	cmp.l 1100664624.l,%d0
	jne .L1042
	move.l #cu_text,%d2
	move.l %d2,1100667228
.L1042:
	tst.b cu.l
	jne .L1043
	move.l #1128813124,%d3
	cmp.l 1073849308.l,%d3
	jne .L1043
	pea 52.w
	move.l #cu_steps,%d5
	moveq #1,%d4
	move.l #cu_setup,%d6
	move.b %d4,cu
	jsr cu_src_setup
	move.l %d5,1073849316
	move.l %d6,1073849312
	addq.l #4,%sp
.L1043:
	move.l rx,%d2
	move.l #-66650100,%a0
	addq.l #1,st+8
	move.l (%a0),st+300
	tst.l st
	jne .L1044
	lea rui_sysex,%a1
	move.l %a1,1075551840
	move.l #1381321040,%a2
	move.l %a2,1075551836
	mov3q.l #1,st
	move.l %d2,st+16
.L1045:
	move.l #ux,%d5
	jra .L1234
.L1041:
	pea 10000.w
	jsr 1074367512
	addq.l #4,%sp
	jra .L1040
.L1044:
	tst.b host_close.l
	jeq .L1046
	clr.b %d0
	lea commits,%a0
	move.b %d0,host_close
	move.b %d0,host_open
	move.l (%a0),sv+12
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	addq.l #8,%sp
.L1046:
	tst.b host_open.l
	jeq .L1047
	clr.b %d0
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	move.b %d0,host_open
	jsr enter
	lea (12,%sp),%sp
.L1047:
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L1048
	move.l st+956,%d0
	cmp.l #65534,%d0
	jhi .L1049
	addq.l #1,%d0
	move.l %d0,st+956
	moveq #10,%d3
	cmp.l %d0,%d3
	jne .L1049
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
.L1050:
	tst.b st+992.l
	jne .L1054
.L1055:
	tst.l splash_req
	jeq .L1056
	move.l splash_req,%d0
	clr.l splash_req
	tst.l st+4
	jne .L1057
	moveq #127,%d1
	and.l %d1,%d0
	tst.l %d0
	jeq .L1058
	tst.l commits
	jne .L1059
.L1057:
	addq.l #1,st+984
.L1056:
	tst.l st+4
	jeq .L1061
	cmp.l st+16.l,%d2
	jeq .L1062
	clr.l st+12
.L1063:
	move.l %d2,st+16
	clr.b %d0
	move.l st+8,%a1
	lea st+408,%a0
	clr.l -184(%fp)
.L1069:
	move.l (%a0)+,%d1
	tst.l %d1
	jeq .L1067
	move.l %a1,%d3
	sub.l %d1,%d3
	jmi .L1067
	moveq #1,%d0
	clr.l -4(%a0)
.L1067:
	addq.l #1,-184(%fp)
	moveq #16,%d5
	cmp.l -184(%fp),%d5
	jne .L1069
	tst.b %d0
	jeq .L1070
	mov3q.l #1,st+344
.L1070:
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr sv_tick
	addq.l #8,%sp
	tst.b ls.l
	jeq .L1071
	tst.b sv.l
	jeq .L1072
	tst.b sv+8.l
	jeq .L1072
	move.l sv,%d0
	move.l ls,%d6
	eor.l %d6,%d0
	and.l #16776960,%d0
	or.l st+4,%d0
	jeq .L1071
.L1072:
	mov3q.l #5,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1071:
	move.l ls_in_gen,%d7
	cmp.l ls+48.l,%d7
	jeq .L1073
	move.l ls_in_v,%d1
	lea ls_in_gen,%a0
	move.l (%a0),ls+48
	tst.b ls.l
	jeq .L1073
	move.l %d1,%d0
	lsr.l #8,%d0
	mvz.b ls+1,%d2
	cmp.l %d0,%d2
	jne .L1073
	mov3q.l #1,%d0
	and.l %d1,%d0
	mov3q.l #1,ls+40
	move.l %d0,ls+36
.L1073:
	tst.l ls+36
	jeq .L1074
	tst.l ls+40
	jne .L1074
	move.l st+8,%d0
	moveq #20,%d1
	sub.l ls+44,%d0
	cmp.l %d0,%d1
	jcc .L1074
	clr.l ls+36
	addq.l #1,ls+56
.L1074:
	move.l u46+8,%d0
	tst.l %d0
	jeq .L1075
	tst.b ls.l
	jne .L1076
	tst.l st+4
	jne .L1076
	move.l st+8,%d1
	moveq #20,%d2
	sub.l %d0,%d1
	cmp.l %d1,%d2
	jcs .L1076
	move.l #1093765506,%a1
	moveq #11,%d3
	mvz.b (%a1),%d0
	cmp.l %d0,%d3
	jcs .L1076
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
	jeq .L1077
.L1076:
	clr.l u46+8
.L1075:
	move.l pm,%d2
	tst.l %d2
	jeq .L1078
	clr.l pm
	add.l #31,%d2
	tst.b ls.l
	jeq .L1079
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1079:
	clr.l st+1038
	tst.l st+4
	jeq .L1080
	moveq #1,%d6
	mvz.w #256,%d5
	moveq #1,%d7
	move.b %d2,st+993
	addq.l #1,pm+16
	move.l %d5,st+296
	move.b %d6,st+161
	move.w %d7,st+162
.L1081:
	tst.l st+1058
	jne .L1083
	tst.l sv+96
	jne .L1084
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jeq .L1082
	lea st+8,%a0
	mov3q.l #1,st+1058
	mov3q.l #1,st+1062
	move.l (%a0),st+1066
	addq.l #1,st+1070
	addq.l #1,st+1090
.L1083:
	tst.l st+4
	jne .L1085
	clr.l st+1058
.L1086:
	tst.l st+972
	jne .L1090
	tst.b sv+8.l
	jne .L1090
.L1091:
	move.l st+1082,%d0
	tst.l %d0
	jeq .L1093
	sub.l st+8,%d0
	tst.l %d0
	jgt .L1094
	clr.l st+1082
.L1094:
	moveq #1,%d4
	move.b %d4,32(%a2)
.L1093:
	move.l sq_gen,%d0
	move.b 1093765506,%d2
	cmp.l sq+400.l,%d0
	jeq .L1095
	mov3q.l #1,%d1
	and.l %d0,%d1
	btst #0,%d0
	jne .L1095
	sub.l %a0,%a0
	lea sq_req,%a1
.L1096:
	lea (%a1,%a0.l),%a3
	mov3q.l #7,%d3
	lea (-140,%fp),%a2
	move.b (%a3),(%a2,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d3
	jne .L1096
	cmp.l sq_gen.l,%d0
	jne .L1095
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
	jeq .L1098
	move.l sq+4,%d1
.L1098:
	mvz.b -134(%fp),%d0
	mvz.b -135(%fp),%d4
	lsl.l #7,%d0
	or.l %d4,%d0
	and.l #4095,%d0
	or.l %d1,%d0
	move.l %d0,pin
	tst.l sq
	jeq .L1099
	btst #1,%d3
	jeq .L1100
.L1099:
	mvz.w #255,%d4
	mvz.w #8191,%d5
	addq.l #1,sq+452
	mov3q.l #1,ed+92
	move.l %d4,sq+404
	move.l %d5,ed+260
.L1100:
	mov3q.l #1,sq
.L1095:
	tst.l sq
	jne .L1101
	clr.l sq+408
.L1102:
	move.l st+4,%d0
	move.l led_gen,%d1
	or.l sq+408,%d0
	jeq .L1152
	tst.l sq+468
	jne .L1153
	lea led_gen,%a1
	move.l (%a1),st+1002
	lea pg_gen,%a2
	move.l #2139062143,%a3
	clr.l st+1006
	mov3q.l #1,sq+476
	move.l (%a2),sq+472
	move.l %a3,sq+480
.L1153:
	mov3q.l #1,sq+468
	cmp.l st+1002.l,%d1
	jeq .L1155
	btst #0,%d1
	jne .L1155
	move.b led_req_mode,%d2
	clr.l %d0
	lea led_req,%a1
	lea (-140,%fp),%a0
.L1156:
	lea (%a1,%d0.l),%a2
	moveq #16,%d3
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d3
	jne .L1156
	cmp.l led_gen.l,%d1
	jne .L1155
	mvz.b %d2,%d2
	move.l %d1,st+1002
	clr.l %d0
	lea st+1022,%a1
	move.l %d2,st+1006
.L1158:
	lea (%a0,%d0.l),%a2
	moveq #16,%d1
	move.b (%a2),(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1158
	moveq #1,%d2
	move.b %d2,led_owed
.L1155:
	mov3q.l #1,%d3
	cmp.l st+1006.l,%d3
	jne .L1154
	clr.l led_again
	tst.b ov_on.l
	jeq .L1163
	tst.b led_owed.l
	jeq .L1161
.L1163:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jeq .L1640
	clr.l %d0
	lea st+1022,%a2
	lea ov_col,%a0
.L1164:
	lea (%a2,%d0.l),%a1
	moveq #16,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1164
	moveq #1,%d2
	move.l %fp,%d3
	add.l #-140,%d3
	lea led_send4,%a3
	move.b %d2,ov_on
	clr.l %d2
.L1165:
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
	jne .L1165
	clr.b %d5
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #1,st+1010
	move.b %d5,led_owed
	jra .L1641
.L1049:
	move.l st+960,%d3
	move.l %d3,%d1
	subq.l #1,%d1
	lsr.l #1,%d1
	jne .L1050
	moveq #20,%d1
	moveq #20,%d5
	muls.l %d3,%d1
	cmp.l %d1,%d5
	seq %d1
	neg.l %d1
	tst.b %d1
	jeq .L1051
	moveq #30,%d1
.L1052:
	cmp.l %d1,%d0
	jne .L1050
	cmp.l st+964.l,%d2
	jne .L1053
	moveq #1,%d6
	move.w #4095,%d7
	addq.l #1,%d3
	move.l %d3,st+960
	move.b %d6,st+992
	move.b %d6,mr+13
	move.b %d6,mr+19
	move.w %d7,ar+60
.L1054:
	tst.b sv.l
	jeq .L1055
	moveq #1,%d0
	move.w #257,%a1
	lea sv+1,%a0
	move.b (%a0),sv+5
	move.b %d0,sv+4
	move.w %a1,sv+6
	jra .L1055
.L1051:
	moveq #50,%d1
	jra .L1052
.L1053:
	mov3q.l #3,st+960
	jra .L1050
.L1048:
	clr.b %d0
	clr.l st+956
	clr.l st+960
	clr.l ls_host_presets
	move.b %d0,st+992
	tst.l sq
	jeq .L1055
	jsr sq_forget
	jra .L1055
.L1058:
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr splash_end
	addq.l #8,%sp
	jra .L1056
.L1059:
	tst.l st+972
	jne .L1060
	mov3q.l #1,st+972
	addq.l #1,st+980
	mov3q.l #-1,st+20
	clr.l st+12
	mov3q.l #1,st+344
.L1060:
	move.l %d0,st+976
.L1061:
	tst.l st+972
	jeq .L1063
	cmp.l st+16.l,%d2
	jeq .L1064
	clr.l st+12
.L1065:
	move.l st+976,%d0
	subq.l #1,%d0
	move.l %d0,st+976
	tst.l %d0
	jne .L1063
	mov3q.l #1,-(%sp)
	jra .L1639
.L1062:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d3
	cmp.l %d0,%d3
	jcc .L1063
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	clr.l mask_set
.L1638:
	addq.l #8,%sp
	jra .L1063
.L1064:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d4
	cmp.l %d0,%d4
	jcc .L1065
	mov3q.l #3,-(%sp)
.L1639:
	move.l %a2,-(%sp)
	jsr splash_end
	jra .L1638
.L1077:
	tst.b sv.l
	jeq .L1075
	tst.b sv+8.l
	jeq .L1075
	mvz.b sv+1,%d2
	mvz.b (%a1),%d1
	cmp.l %d2,%d1
	jne .L1075
	mvz.b sv+2,%d1
	cmp.l %d0,%d1
	jne .L1075
	clr.l -(%sp)
	clr.l -(%sp)
	jsr ls_enc
	addq.l #8,%sp
	tst.l %d0
	jeq .L1075
	clr.l u46+8
	addq.l #1,u46+28
	jra .L1075
.L1080:
	mvz.b %d2,%d2
	move.l %d2,-(%sp)
	clr.l -(%sp)
	move.l %a2,-(%sp)
	jsr enter
	lea (12,%sp),%sp
	addq.l #1,pm+12
.L1078:
	tst.l st+4
	jne .L1081
.L1082:
	tst.l st+1058
	jne .L1083
.L1084:
	tst.l st+4
	jeq .L1086
.L1090:
	tst.l st+1058
	jne .L1091
	move.l commits,%d2
	cmp.l st+20.l,%d2
	jne .L1092
	tst.l st+344
	jeq .L1091
.L1092:
	moveq #1,%d3
	move.b %d3,32(%a2)
	jra .L1091
.L1085:
	move.l sv+88,%d0
	cmp.l #1075650164,%d0
	jeq .L1087
	move.l %d0,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jeq .L1088
.L1087:
	mov3q.l #1,st+1062
	jra .L1084
.L1088:
	tst.l st+1062
	jne .L1089
	move.l st+8,%d0
	moveq #20,%d1
	sub.l st+1066,%d0
	cmp.l %d0,%d1
	jcc .L1084
.L1089:
	clr.l st+1058
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
	jra .L1084
.L1101:
	mvz.b %d2,%d2
	lea sq_grid,%a2
	moveq #11,%d6
	cmp.l %d2,%d6
	jcs .L1103
	move.l sq+4,%d0
	btst %d2,%d0
	jne .L1104
.L1103:
	clr.l %d0
.L1105:
	cmp.l sq+408.l,%d0
	jne .L1106
	tst.l %d0
	jeq .L1107
	cmp.l sq+412.l,%d2
	jeq .L1107
.L1106:
	mov3q.l #1,%d7
	or.l %d7,sq+404
	move.l %d0,sq+408
	move.l %d2,sq+412
.L1107:
	move.b 1093615249,%d0
	move.b 1093615250,%d2
	moveq #127,%d3
	move.b 1079807236,%d1
	and.l %d3,%d1
	move.l sq+360,%d3
	btst #8,%d3
	jeq .L1108
	move.l %d1,%d0
	moveq #127,%d1
	and.l %d3,%d1
.L1109:
	cmp.l %d0,%d1
	jeq .L1343
.L1110:
	cmp.l sq+420.l,%d1
	jne .L1111
	cmp.l sq+424.l,%d0
	jeq .L1112
.L1111:
	mov3q.l #4,%d5
	or.l %d5,sq+404
	move.l %d1,sq+420
	move.l %d0,sq+424
.L1112:
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
	jne .L1113
	cmp.l sq+432.l,%d0
	jeq .L1114
.L1113:
	moveq #16,%d6
	or.l %d6,sq+404
	move.l %d2,sq+428
	move.l %d0,sq+432
.L1114:
	move.l 1076395164,%d0
	and.l #2097151,%d0
	cmp.l sq+436.l,%d0
	jeq .L1115
	moveq #32,%d7
	or.l %d7,sq+404
	move.l %d0,sq+436
.L1115:
	move.b 1081877443,%d0
	mvz.b 1081877444,%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #8191,%d0
	cmp.l sq+440.l,%d0
	jeq .L1116
	move.l %d0,sq+440
	moveq #8,%d0
	or.l %d0,sq+404
.L1116:
	move.b 1081877445,%d0
	mvz.b 1081877446,%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #8191,%d0
	cmp.l sq+552.l,%d0
	jeq .L1117
	mvz.w #128,%d1
	move.l %d0,sq+552
	or.l %d1,sq+404
.L1117:
	mov3q.l #1,%d3
	move.l 1079807120,%d2
	cmp.l %d2,%d3
	jne .L1118
	move.l st+8,%d0
	moveq #19,%d4
	sub.l sq+444,%d0
	cmp.l %d0,%d4
	jcc .L1118
	moveq #64,%d5
	or.l %d5,sq+404
.L1118:
	move.l sq+404,%d0
	btst #0,%d0
	jeq .L1119
	move.l sq+408,%d0
	move.b %d0,-140(%fp)
	tst.l %d0
	jeq .L1344
	move.b sq+415,%d0
.L1120:
	mov3q.l #2,-(%sp)
	pea -140(%fp)
	pea 8.w
	move.b %d0,-139(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1102
	moveq #-2,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1119:
	btst #1,%d0
	jeq .L1121
	mov3q.l #2,%d6
	cmp.l %d2,%d6
	jcc .L1345
	clr.l %d0
.L1122:
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
	jeq .L1102
	moveq #-3,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1121:
	move.w %d0,%ccr
	jne .L1123
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
	jeq .L1102
	moveq #-5,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1123:
	move.w %d0,%ccr
	jpl .L1124
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
	jeq .L1102
	moveq #-9,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1124:
	tst.b %d0
	jpl .L1125
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
	jeq .L1102
	move.l sq+404,%d0
	bclr #7,%d0
	move.l %d0,sq+404
.L1125:
	btst #4,%d0
	jeq .L1126
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
	jeq .L1102
	moveq #-17,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1126:
	btst #5,%d0
	jeq .L1127
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
	jeq .L1102
	moveq #-33,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1127:
	btst #6,%d0
	jeq .L1128
	move.l 1100784300,-(%sp)
	move.l %fp,%d3
	add.l #-140,%d3
	move.l %d3,-(%sp)
	jsr blk4
	addq.l #8,%sp
	mov3q.l #2,%d5
	cmp.l %d2,%d5
	jcc .L1129
	clr.l %d2
.L1129:
	move.b %d2,-136(%fp)
	moveq #127,%d6
	move.w 1079807124,%d0
	subq.l #1,%d0
	and.l %d6,%d0
	move.b %d0,-135(%fp)
	move.l sq+380,%d0
	cmp.l %d0,%d6
	jcc .L1130
	moveq #127,%d0
.L1130:
	mov3q.l #7,-(%sp)
	move.l %d3,-(%sp)
	pea 9.w
	move.b %d0,-134(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1102
	moveq #-65,%d7
	and.l %d7,sq+404
	lea st+8,%a0
	move.l (%a0),sq+444
.L1128:
	move.l sq+360,%d0
	btst #8,%d0
	jeq .L1131
	moveq #127,%d1
	and.l %d1,%d0
.L1132:
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
.L1138:
	move.l #85689,%d5
	moveq #12,%d0
	mvz.b (%a2,%d5.l),%d4
	cmp.l %d1,%d0
	jeq .L1133
	mvz.b (%a0),%d0
	move.b 2(%a0),%d3
.L1134:
	mvz.b %d3,%d3
	cmp.l (%a1),%d0
	jne .L1135
	cmp.l 52(%a1),%d3
	jne .L1135
	cmp.l 104(%a1),%d4
	jne .L1135
	moveq #12,%d2
	cmp.l %d1,%d2
	jne .L1136
	move.l #85685,%d2
	move.b (%a2,%d2.l),%d2
	move.l #85686,%a5
	mvz.b (%a2,%a5.l),%d5
	mvz.b %d2,%d2
	lsl.l #8,%d2
	or.l %d5,%d2
	cmp.l ed+256.l,%d2
	jeq .L1136
.L1135:
	move.l %d0,(%a1)
	moveq #12,%d0
	move.l %d3,52(%a1)
	move.l %d4,104(%a1)
	cmp.l %d1,%d0
	jne .L1137
	move.b (%a2,%d6.l),%d0
	mvz.b (%a2,%d7.l),%d2
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d2,%d0
	move.l %d0,ed+256
.L1137:
	tst.l -180(%fp)
	jeq .L1136
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	or.l %d0,ed+260
.L1136:
	addq.l #1,%d1
	addq.l #4,%a1
	lea (917,%a0),%a0
	moveq #13,%d2
	cmp.l %d1,%d2
	jne .L1138
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
	jeq .L1139
	move.l %d1,ed+272
	clr.l ed+268
	clr.l ed+372
.L1139:
	move.l ed+268,%d2
	move.l %d2,%d3
	addq.l #1,%d3
	move.l %d3,%d1
	moveq #10,%d4
	lsl.l %d4,%d1
	cmp.l %d0,%d1
	jls .L1346
	move.l %d2,%d1
	move.l %d0,%d5
	lsl.l %d4,%d1
	sub.l %d1,%d5
.L1140:
	move.l %d2,%d1
	moveq #12,%d6
	lsl.l %d6,%d1
	clr.l %d4
	add.l %d1,%a1
	clr.l %d1
.L1141:
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
	jne .L1141
	move.l ed+372,%d4
	move.l %d2,%a0
	lea (69,%a0),%a0
	btst %d2,%d4
	jeq .L1142
	cmp.l (%a4,%a0.l*4),%d1
	jeq .L1142
	mov3q.l #1,ed+376
.L1142:
	move.l %d1,(%a4,%a0.l*4)
	mov3q.l #1,%d1
	add.l #1023,%d0
	lsl.l %d2,%d1
	or.l %d4,%d1
	move.l %d1,ed+372
	moveq #10,%d1
	lsr.l %d1,%d0
	cmp.l %d3,%d0
	jhi .L1143
	clr.l %d3
.L1143:
	move.l %d3,ed+268
	move.l %fp,%d3
	clr.l %d2
	add.l #-172,%d3
.L1148:
	move.l ed+260,%d0
	btst %d2,%d0
	jeq .L1144
	moveq #12,%d5
	cmp.l %d2,%d5
	jne .L1347
	moveq #127,%d0
.L1145:
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
	jeq .L1348
	mov3q.l #5,%d0
.L1146:
	move.l %d0,-(%sp)
	move.l %d3,-(%sp)
	mov3q.l #4,-(%sp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1102
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	addq.l #1,ed+264
	not.l %d0
	and.l %d0,ed+260
.L1144:
	addq.l #1,%d2
	addq.l #4,%a3
	moveq #13,%d1
	cmp.l %d2,%d1
	jne .L1148
.L1149:
	move.l ed+68,%d0
	cmp.l ed+64.l,%d0
	jne .L1150
	tst.l ed+92
	jeq .L1151
	lea ed+91,%a0
	move.b (%a0),-172(%fp)
	mov3q.l #1,-(%sp)
	pea -172(%fp)
	pea 12.w
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1102
	clr.l ed+92
.L1151:
	tst.l ed+376
	jeq .L1102
	move.l st+8,%d0
	sub.l ed+380,%d0
	lsr.l #2,%d0
	jeq .L1102
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
	jeq .L1102
	lea st+8,%a0
	clr.l ed+376
	move.l (%a0),ed+380
	addq.l #1,ed+384
	jra .L1102
.L1104:
	jsr (%a2)
	jra .L1105
.L1108:
	mvz.b %d0,%d0
	mvz.b %d2,%d2
	moveq #127,%d4
	lsl.l #8,%d0
	or.l %d2,%d0
	cmp.l %d0,%d4
	jge .L1109
.L1343:
	moveq #127,%d0
	jra .L1110
.L1344:
	moveq #127,%d0
	jra .L1120
.L1345:
	move.l %d2,%d0
	jra .L1122
.L1131:
	move.b 1079807236,%d0
	moveq #127,%d2
	and.l %d2,%d0
	jra .L1132
.L1133:
	move.l #85683,%d2
	move.b (%a2,%d2.l),%d0
	move.l #85684,%d3
	move.l #85690,%d5
	mvz.b (%a2,%d3.l),%d2
	move.b (%a2,%d5.l),%d3
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d2,%d0
	jra .L1134
.L1346:
	mvz.w #1024,%d5
	jra .L1140
.L1347:
	move.l %d2,%d0
	jra .L1145
.L1348:
	mov3q.l #7,%d0
	jra .L1146
.L1150:
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
	jeq .L1102
	addq.l #1,ed+68
	addq.l #1,ed+76
	jra .L1149
.L1152:
	clr.l sq+468
	clr.l st+1006
.L1154:
	clr.b %d4
	move.b %d4,led_owed
	jsr led_restore
	move.l led_again,%d0
	tst.l %d0
	jeq .L1161
	tst.b ov_on.l
	jne .L1161
	move.l st+8,%d1
	sub.l %d0,%d1
	jmi .L1161
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1162
.L1640:
	addq.l #1,st+1018
.L1161:
	move.l sq+468,%d2
	move.l pg_gen,%d0
	mvz.b ovp_on,%d3
	tst.l %d2
	jeq .L1166
	cmp.l sq+472.l,%d0
	jeq .L1167
	btst #0,%d0
	jne .L1167
	move.b pg_req,%d5
	move.b pg_req+1,%d4
	move.b pg_req+2,%d2
	move.b pg_req+3,%d1
	cmp.l pg_gen.l,%d0
	jne .L1167
	move.b %d5,sq+480
	move.b %d4,sq+481
	move.b %d2,sq+482
	move.b %d1,sq+483
	move.l %d0,sq+472
	mov3q.l #1,sq+476
.L1167:
	clr.l %d2
	clr.l %d0
	lea sq+480,%a0
.L1169:
	mvz.b (%a0,%d0.l),%d4
	moveq #111,%d6
	cmp.l %d4,%d6
	jcs .L1168
	mov3q.l #1,%d4
	lsl.l %d0,%d4
	or.l %d4,%d2
.L1168:
	addq.l #1,%d0
	mov3q.l #4,%d7
	cmp.l %d0,%d7
	jne .L1169
.L1166:
	cmp.l %d3,%d2
	jne .L1170
	tst.l sq+476
	jeq .L1171
.L1170:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1350
	addq.l #1,st+1018
.L1171:
	tst.l st+4
	jeq .L1351
	tst.l st+1058
	seq %d2
	mvs.b %d2,%d2
	neg.l %d2
.L1179:
	move.l st+8,%d0
	moveq #10,%d3
	divu.l %d3,%d0
	btst #0,%d0
	jeq .L1352
	clr.b %d3
.L1180:
	mvz.b k44+24,%d0
	cmp.l %d2,%d0
	jne .L1181
	tst.l %d2
	jeq .L1182
	mvz.b k44+25,%d1
	mvz.b %d3,%d0
	cmp.l %d1,%d0
	jeq .L1182
.L1181:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1183
	addq.l #1,st+1018
.L1182:
	jsr flush
	move.b pc+79,%d2
	move.l pc_seq,%d1
	lea pc,%a2
	tst.b %d2
	jne .L1186
	btst #0,%d1
	jne .L1187
	cmp.l pc+72.l,%d1
	jeq .L1187
	clr.l %d0
	lea pc_req,%a0
	lea (-140,%fp),%a3
.L1188:
	lea (%a0,%d0.l),%a1
	mov3q.l #6,%d3
	move.b (%a1),(%a3,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d3
	jne .L1188
	cmp.l pc_seq.l,%d1
	jne .L1187
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
	jlt .L1190
	jsr 1075320104
	move.l %d0,-(%sp)
	jsr 1073963888
	addq.l #4,%sp
	tst.l %d0
	jne .L1191
.L1190:
	moveq #3,%d2
.L1192:
	move.b %d2,pc+78
	mvz.b %d2,%d2
	move.b %d3,pc+76
	add.l #42,%d2
	move.w (%a2,%d2.l*2),%d0
	addq.l #1,%d0
	move.w %d0,(%a2,%d2.l*2)
	moveq #1,%d0
	move.b %d0,pc+79
.L1186:
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
	jeq .L1187
	move.w pc+92,%d0
	clr.b %d1
	addq.l #1,%d0
	move.b %d1,pc+79
	move.w %d0,pc+92
.L1187:
	move.b st+992,%d0
	move.b st+161,%d1
	or.l %d1,%d0
	tst.b %d0
	jne .L1207
	jsr mr_tick
	tst.l %d0
	jeq .L1207
	tst.b sv+4.l
	jeq .L1208
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
	jeq .L1210
	clr.b %d0
	addq.l #1,sv+64
	move.b %d0,sv+4
.L1208:
	tst.b sv+102.l
	jeq .L1211
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
	jcc .L1212
	moveq #127,%d0
.L1212:
	move.b %d0,-159(%fp)
	clr.l %d0
	lea (-140,%fp),%a0
	lea (-172,%fp),%a1
.L1213:
	lea (%a1,%d0.l),%a2
	moveq #14,%d1
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1213
	moveq #-9,%d3
	pea 15.w
	move.l %a0,-(%sp)
	move.b %d3,-126(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1210
	clr.b %d4
	lea sv+100,%a0
	move.b (%a0),sv+101
	lea st+8,%a1
	move.l %d2,sv+104
	move.l (%a1),sv+108
	addq.l #1,sv+112
	move.b %d4,sv+102
.L1211:
	tst.b sv.l
	jeq .L1210
	mvz.b sv+1,%d0
	not.l %d0
	move.l %d0,-(%sp)
	jsr cu_steps
	addq.l #4,%sp
	tst.l %d0
	jne .L1210
	move.l sv+120,%a2
	cmp.l sv+116.l,%a2
	jeq .L1215
	moveq #1,%d0
	move.b %d0,sv+7
.L1215:
	lea (-172,%fp),%a3
	clr.l %d3
	lea sv,%a4
	mov3q.l #-1,%d2
	move.l %a3,%a2
.L1220:
	mvz.b sv+1,%d0
	move.l sv+116,-(%sp)
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	jsr sv_word
	lea (12,%sp),%sp
	move.b sv+7,%d4
	move.w %d0,(%a3)
	tst.b %d4
	jne .L1216
	mvz.w %d0,%d1
	mvz.w 24(%a4),%d6
	cmp.l %d1,%d6
	jeq .L1217
.L1216:
	cmp.l -184(%fp),%d3
	jge .L1218
	move.l %d3,-184(%fp)
.L1218:
	move.l %d3,%d2
.L1217:
	mov3q.l #7,%d1
	cmp.l %d3,%d1
	jge .L1219
	tst.w %d0
	jeq .L1219
	mvz.b sv+1,%d0
	move.l %d0,-(%sp)
	jsr cu_mi_settling
	addq.l #4,%sp
	tst.l %d0
	jne .L1210
.L1219:
	addq.l #2,%a3
	addq.l #1,%d3
	addq.l #2,%a4
	moveq #16,%d0
	cmp.l %d3,%d0
	jne .L1220
	tst.b %d4
	jne .L1354
	mov3q.l #-1,%d1
	cmp.l %d2,%d1
	jne .L1221
.L1210:
	jsr arp_tick
.L1207:
	tst.l st
	jne .L1045
.L1231:
	mvz.b cu+9,%d2
	tst.l %d2
	jeq .L1260
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
	jeq .L1261
	move.l st+8,%d0
	mov3q.l #4,%d3
	sub.l cu+16,%d0
	cmp.l %d0,%d3
	jcc .L1260
.L1264:
	clr.b %d4
	move.b %d4,cu+9
.L1260:
	tst.l st
	jeq .L1265
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L1266
	tst.l st+968
	jeq .L1266
	move.l dp,%d0
	move.b 1093765506,%d2
	tst.l %d0
	jeq .L1267
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
	jeq .L1269
	clr.l dp
.L1267:
	tst.b k44+20.l
	jeq .L1270
	move.l k44+20,%d0
	and.l #16776960,%d0
	tst.l %d0
	jne .L1270
	tst.l st+4
	jeq .L1271
	tst.l st+1058
	jne .L1270
.L1271:
	move.l st+8,%d0
	sub.l k44,%d0
	lsr.l #3,%d0
	jeq .L1270
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	or.l ov_list,%d0
	jne .L1270
	tst.l st+4
	sne %d0
	move.w #257,%d7
	neg.l %d0
	move.b %d0,k44+26
	move.w %d7,k44+22
.L1270:
	move.b k44+23,%d0
	jeq .L1272
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
	jeq .L1269
	mvz.b k44+23,%d0
	tst.b k44+26.l
	jeq .L1275
	mov3q.l #1,%d4
	cmp.l %d0,%d4
	jne .L1276
	addq.l #1,k44+28
.L1277:
	clr.b %d0
	move.b %d0,k44+23
.L1272:
	mvz.b %d2,%d1
	moveq #11,%d3
	cmp.l %d1,%d3
	jcs .L1269
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
	jeq .L1280
	clr.b %d6
	move.l %d0,dp+8
	move.b %d6,dp+22
.L1281:
	moveq #52,%d7
	cmp.l %d4,%d7
	jcs .L1357
	move.b %d5,%d0
	move.l #1075572644,%a0
	ext.w %d0
	mvz.w %d0,%d0
	lsl.l #3,%d0
	move.l (%a0,%d0.l),%a0
.L1283:
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
	jeq .L1358
	move.l %a0,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	sls %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1284:
	clr.l %d1
	lea (-140,%fp),%a1
.L1286:
	tst.l %d0
	jeq .L1643
	move.b (%a0,%d1.l),%d6
	move.l %d6,%d7
	subq.l #1,%d7
	mvz.b %d7,%d7
	move.l %d7,%a2
	moveq #125,%d7
	cmp.l %a2,%d7
	jcs .L1360
.L1285:
	move.b %d6,9(%a1,%d1.l)
	addq.l #1,%d1
	moveq #12,%d6
	cmp.l %d1,%d6
	jne .L1286
	moveq #-9,%d7
	pea 22.w
	move.l %a1,-(%sp)
	move.b %d7,-119(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1269
	move.w #257,%a0
	move.b %d2,dp+20
	move.b %d5,dp+21
	addq.l #1,dp+12
	move.w %a0,dp+22
	jra .L1282
.L1162:
	jsr led_stock
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.l led_again
.L1641:
	addq.l #4,%sp
	jra .L1161
.L1350:
	clr.l %d0
	lea sq+480,%a0
	lea ovp_col,%a1
.L1172:
	btst %d0,%d2
	jeq .L1173
	lea (%a0,%d0.l),%a2
	move.b (%a2),(%a1,%d0.l)
.L1173:
	addq.l #1,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L1172
	move.l %d3,%d4
	clr.l %d3
	move.b %d2,ovp_on
	or.l %d2,%d4
	lea shp,%a2
	lea sq+480,%a4
	lea (-140,%fp),%a3
	lea rui_uart_raw,%a5
.L1178:
	btst %d3,%d4
	jeq .L1174
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
.L1177:
	tst.l %d0
	jeq .L1175
	move.b (%a4,%d3.l),%d1
.L1176:
	move.b %d1,2(%a3,%a0.l)
	addq.l #1,%a0
	mov3q.l #4,%d7
	cmp.l %a0,%d7
	jne .L1177
	move.l %a3,-(%sp)
	mov3q.l #6,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
.L1174:
	addq.l #1,%d3
	addq.l #4,%a2
	mov3q.l #4,%d0
	cmp.l %d3,%d0
	jne .L1178
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.l sq+476
	addq.l #4,%sp
	jra .L1171
.L1175:
	move.b (%a2,%a0.l),%d1
	jra .L1176
.L1351:
	clr.l %d2
	jra .L1179
.L1352:
	moveq #111,%d3
	jra .L1180
.L1183:
	move.b %d3,ovt_col
	move.b %d2,%d4
	move.b %d2,ovt_on
	lea led_send4,%a0
	tst.l %d2
	jeq .L1184
	move.b %d3,-137(%fp)
	move.b %d3,-138(%fp)
	move.b %d3,-139(%fp)
	move.b %d3,-140(%fp)
	pea -140(%fp)
	pea 55.w
	jsr (%a0)
	addq.l #1,k44+12
.L1642:
	addq.l #4,%sp
	move.l #1100088672,(%sp)
	jsr 1073746414
	addq.l #4,%sp
	move.b %d4,k44+24
	move.b %d3,k44+25
	jra .L1182
.L1184:
	pea sht
	pea 55.w
	jsr (%a0)
	addq.l #1,k44+16
	jra .L1642
.L1191:
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
	jeq .L1190
	tst.b 60(%a2,%d5.l)
	jeq .L1193
	move.l st+8,%d0
	moveq #20,%d1
	sub.l (%a2,%d5.l*4),%d0
	cmp.l %d0,%d1
	jcc .L1194
.L1193:
	moveq #1,%d2
	jra .L1192
.L1194:
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
	jeq .L1190
	move.l (%a5),%a0
	move.l %a5,-(%sp)
	move.l 40(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l 32(%a5),%a1
	move.l %d0,-180(%fp)
	tst.l %a1
	jeq .L1195
	move.l %a1,%d5
	move.l %a1,%a0
	add.l #4752,%d5
	clr.l %d1
.L1199:
	mvz.b (%a0),%d6
	cmp.l #255,%d6
	jeq .L1197
	mvz.b 1(%a0),%d6
	cmp.l #255,%d6
	jeq .L1197
	addq.l #1,%d1
.L1197:
	lea (66,%a0),%a0
	cmp.l %d5,%a0
	jne .L1199
	mulu.w #5674,%d4
	mvz.b %d3,%d0
	move.l #1075599904,%a5
	add.l -180(%fp),%d4
.L1204:
	mvz.b 3(%a5),%d6
	move.l %a1,%a0
.L1202:
	mvz.b (%a0),%d7
	cmp.l %d7,%d6
	jne .L1200
	mvz.b 1(%a0),%d7
	cmp.l %d0,%d7
	jeq .L1201
.L1200:
	lea (66,%a0),%a0
	cmp.l %d5,%a0
	jne .L1202
	move.l %d4,%a0
	tst.b 5653(%a0)
	jne .L1340
	mov3q.l #1,%a0
	jra .L1341
.L1340:
	mov3q.l #2,%a0
.L1341:
	add.l %a0,%d1
	moveq #71,%d6
	cmp.l %d1,%d6
	jlt .L1353
.L1201:
	addq.l #4,%a5
	addq.l #1,%d4
	cmp.l #1075599920,%a5
	jne .L1204
.L1195:
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
.L1205:
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
	jne .L1205
	jra .L1192
.L1353:
	moveq #2,%d2
	jra .L1192
.L1354:
	clr.l -184(%fp)
	moveq #15,%d2
.L1221:
	move.l sv+116,%d0
	not.l %d0
	add.l %d0,%d0
	subx.l %d0,%d0
	neg.l %d0
	move.b sv+1,%d1
	move.l #-260222380,%d3
	move.w #10753,%d4
	move.b -181(%fp),-133(%fp)
	lea (-140,%fp),%a0
	move.l %d3,-140(%fp)
	lea (9,%a0),%a1
	lsl.l #6,%d0
	move.w %d4,-136(%fp)
	or.l %d1,%d0
	move.l %d2,%d1
	addq.l #1,%d1
	move.b %d0,-134(%fp)
	move.l %d1,%d0
	sub.l -184(%fp),%d0
	move.b %d0,-132(%fp)
	move.l -184(%fp),%d0
.L1222:
	cmp.l %d2,%d0
	jle .L1223
	cmp.l -184(%fp),%d1
	sge %d1
	move.l %d1,%d0
	neg.l %d0
	tst.b %d0
	jeq .L1224
	move.l %d2,%d0
	sub.l -184(%fp),%d0
	add.l %d0,%d0
	add.l #11,%d0
.L1225:
	moveq #-9,%d6
	lea (%fp,%d0.l),%a1
	neg.l %d1
	move.b %d6,-140(%a1)
	tst.b %d1
	jeq .L1226
	move.l %d2,%d0
	addq.l #6,%d0
	sub.l -184(%fp),%d0
	add.l %d0,%d0
.L1227:
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1210
	lea sv+24,%a0
.L1228:
	cmp.l -184(%fp),%d2
	jge .L1229
	clr.b %d2
	move.l sv+116,%d0
	addq.l #1,sv+68
	move.b %d2,sv+7
	tst.l %d0
	jlt .L1230
	addq.l #1,sv+124
.L1230:
	move.l %d0,sv+120
	jra .L1210
.L1223:
	move.w (%a2,%d0.l*2),%d3
	moveq #127,%d5
	addq.l #1,%d0
	addq.l #2,%a1
	move.l %d3,%d4
	lsr.l #7,%d4
	and.l %d5,%d3
	move.b %d4,-2(%a1)
	move.b %d3,-1(%a1)
	jra .L1222
.L1224:
	moveq #9,%d0
	jra .L1225
.L1226:
	moveq #10,%d0
	jra .L1227
.L1229:
	move.l -184(%fp),%d1
	lea (%a2,%d1.l*2),%a3
	move.w (%a3),(%a0,%d1.l*2)
	addq.l #1,%d1
	move.l %d1,-184(%fp)
	jra .L1228
.L1235:
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
	jeq .L1231
	move.l ux+3944,%d1
	mov3q.l #1,%d0
	lea ux+3920,%a0
.L1232:
	cmp.l %d0,%d1
	jhi .L1233
	subq.l #1,%d1
	move.l %d1,ux+3944
	addq.l #1,ux+32
.L1234:
	tst.l ux+3944
	jne .L1235
.L1236:
	move.l ux+3880,%d1
	cmp.l ux+3884.l,%d1
	jeq .L1231
	mov3q.l #7,%d2
	cmp.l ux+3944.l,%d2
	jcs .L1231
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
	jle .L1355
	mvz.b 2(%a2),%d2
	mvz.b 3(%a2),%d0
	lsl.l #8,%d2
	add.l %d0,%d0
	or.l %d0,%d2
	mov3q.l #7,%d0
	cmp.l %a1,%d0
	jlt .L1238
	move.l %a3,%d0
	add.l #-46,%d0
	mvz.b %d0,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jcc .L1239
	moveq #52,%d0
	cmp.l %a5,%d0
	jne .L1240
.L1239:
	cmp.l 1075595760.l,%a5
	jne .L1241
.L1240:
	tst.l %a1
	jne .L1243
.L1244:
	move.l %a0,%d1
	mov3q.l #7,%d0
	and.l %d0,%d1
	move.l %d5,%a0
	add.l %d1,%a0
	move.b 3952(%a0),%d0
	btst #0,%d0
	jeq .L1243
	move.l ls+60,%d0
	or.l ls+64,%d0
	jeq .L1243
	cmp.l ls+68.l,%d3
	jne .L1243
	move.l st+8,%d0
	moveq #20,%d1
	sub.l ls+72,%d0
	cmp.l %d0,%d1
	jcs .L1243
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
	jeq .L1243
	move.l (%a5),%a0
	move.l %a5,-(%sp)
	move.l 40(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l 32(%a5),%d0
	tst.l %d0
	jeq .L1245
	move.l %d0,%a0
	add.l #4753,%d0
	move.l %d0,-180(%fp)
	move.w %a3,%d0
	addq.l #1,%a0
	sub.l %a4,%a4
	sub.l %a1,%a1
	mvz.b %d0,%d0
	move.l %d0,%a3
.L1250:
	mvz.b -1(%a0),%d1
	cmp.l #255,%d1
	jeq .L1247
	mvz.b (%a0),%d0
	cmp.l #255,%d0
	jeq .L1247
	addq.l #1,%a1
.L1247:
	cmp.l %d1,%a3
	jne .L1249
	mvz.b (%a0),%d1
	move.l %a4,%d0
	cmp.l %d1,%d3
	seq %d1
	mvs.b %d1,%d1
	neg.l %d1
	or.l %d1,%d0
	move.l %d0,%a4
.L1249:
	lea (66,%a0),%a0
	cmp.l -180(%fp),%a0
	jne .L1250
	tst.l %a4
	jne .L1245
	moveq #69,%d1
	cmp.l %a1,%d1
	jlt .L1251
.L1245:
	move.l %a2,-(%sp)
	moveq #64,%d3
	jsr 1074529464
	addq.l #4,%sp
	move.l %d0,%a3
	cmp.l %d0,%d3
	jge .L1252
	move.w #64,%a3
.L1252:
	clr.l %d3
.L1253:
	cmp.l %a3,%d3
	jlt .L1257
	moveq #4,%d0
	clr.l ls+64
	clr.l ls+60
	addq.l #1,ux+3960
.L1258:
	move.l ux+3944,%a0
	lea (%a0,%a0.l*2),%a1
	addq.l #1,%a0
	move.l %a0,ux+3944
	addq.l #1,ux+3884
	add.l %d5,%a1
	move.b %d7,3920(%a1)
	move.b %d6,3921(%a1)
	move.b %d0,3922(%a1)
	jra .L1236
.L1233:
	addq.l #3,%a0
	move.b (%a0),-3(%a0)
	move.b 1(%a0),-2(%a0)
	move.b 2(%a0),-1(%a0)
	addq.l #1,%d0
	jra .L1232
.L1238:
	move.l %a5,%d0
	mov3q.l #2,%d1
	add.l #-48,%d0
	cmp.l %d0,%d1
	jcs .L1242
	mvz.b cu+1,%d0
	cmp.l %a5,%d0
	jne .L1241
.L1243:
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
	jra .L1258
.L1242:
	moveq #10,%d0
	cmp.l %a1,%d0
	jne .L1243
	moveq #45,%d1
	cmp.l %a5,%d1
	jeq .L1244
	jra .L1243
.L1257:
	moveq #31,%d0
	cmp.l %d3,%d0
	jlt .L1254
	move.l ls+60,%d1
	lsr.l %d3,%d1
.L1255:
	btst #0,%d1
	jeq .L1256
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	move.l %d4,-(%sp)
	move.l %d3,-(%sp)
	move.l %a2,-(%sp)
	jsr 1074529568
	lea (20,%sp),%sp
	addq.l #1,ls+96
.L1256:
	addq.l #1,%d3
	jra .L1253
.L1254:
	move.l %d3,%d0
	add.l #-32,%d0
	move.l ls+64,%d1
	lsr.l %d0,%d1
	jra .L1255
.L1251:
	moveq #3,%d0
	addq.l #1,ux+3964
.L1237:
	addq.l #1,ux+24
	jra .L1258
.L1241:
	moveq #1,%d0
	jra .L1237
.L1355:
	moveq #2,%d0
	jra .L1237
.L1261:
	move.l #1075731444,%d5
	cmp.l sv+88.l,%d5
	jeq .L1260
	move.l st+8,%d0
	sub.l cu+16,%d0
	lsr.l #1,%d0
	jeq .L1260
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	move.l %d0,%a2
	tst.l %d0
	jeq .L1260
	move.l %d2,-(%sp)
	moveq #17,%d3
	jsr cu_setup
	lea (11,%a2),%a2
	addq.l #4,%sp
.L1263:
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr 1073770536
	addq.l #8,%sp
	move.l %d0,%d5
	tst.l %d0
	jle .L1262
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
.L1262:
	addq.l #1,%d3
	lea (14,%a2),%a2
	moveq #25,%d0
	cmp.l %d3,%d0
	jne .L1263
	addq.l #1,cu+20
	moveq #50,%d1
	cmp.l %d2,%d1
	jne .L1264
	addq.l #1,%d4
	lea st+8,%a0
	move.b %d4,cu+11
	move.l (%a0),cu+24
	jra .L1264
.L1276:
	addq.l #1,k44+32
.L1278:
	subq.l #2,%d0
	tst.l %d0
	jne .L1277
	clr.b %d7
	move.b %d7,k44+26
	jra .L1277
.L1275:
	mov3q.l #1,%d5
	cmp.l %d0,%d5
	jne .L1279
	addq.l #1,k44+4
	jra .L1277
.L1279:
	addq.l #1,k44+8
	jra .L1278
.L1280:
	tst.b dp+22.l
	jeq .L1281
	mvz.b dp+20,%d0
	cmp.l %d1,%d0
	jne .L1281
	mvz.b dp+21,%d0
	cmp.l %d4,%d0
	jne .L1281
.L1282:
	add.l #1092966707,%d3
	lea dp,%a4
	sub.l %a3,%a3
	move.l %d3,-180(%fp)
	lea dp+32,%a2
	move.l %a4,%a5
.L1293:
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
	jgt .L1287
	clr.l -172(%fp)
.L1288:
	mvz.b 24(%a5),%d7
	move.b -172(%fp),%d6
	move.b -171(%fp),%d5
	move.b -170(%fp),%d1
	move.b -169(%fp),%d0
	cmp.l %d3,%d7
	jne .L1291
	mvs.b (%a2),%d7
	move.l %d7,%a1
	mvs.b %d6,%d7
	cmp.l %a1,%d7
	jne .L1291
	mvs.b 1(%a2),%d7
	move.l %d7,%a1
	mvs.b %d5,%d7
	cmp.l %a1,%d7
	jne .L1291
	mvs.b 2(%a2),%d7
	move.l %d7,%a1
	mvs.b %d1,%d7
	cmp.l %a1,%d7
	jne .L1291
	mvs.b 3(%a2),%d7
	move.l %d7,%a1
	mvs.b %d0,%d7
	cmp.l %a1,%d7
	jeq .L1292
.L1291:
	move.b %d3,24(%a5)
	move.b %d0,3(%a2)
	moveq #1,%d0
	move.b %d6,(%a2)
	move.b %d5,1(%a2)
	move.b %d1,2(%a2)
	move.b %d0,dp+23
.L1292:
	addq.l #1,%a3
	addq.l #4,%a2
	addq.l #1,%a5
	moveq #8,%d1
	cmp.l %a3,%d1
	jne .L1293
	tst.b dp+23.l
	jeq .L1269
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
.L1295:
	move.b (%a2)+,(%a1)
	mov3q.l #1,%a0
.L1294:
	lea 31(%a4,%a0.l),%a3
	mov3q.l #5,%d2
	move.b (%a3),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d2
	jne .L1294
	addq.l #5,%a1
	addq.l #5,%d0
	addq.l #4,%a4
	moveq #49,%d3
	cmp.l %d0,%d3
	jne .L1295
	moveq #-9,%d4
	pea 49.w
	move.l %d1,-(%sp)
	move.b %d4,-92(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1269
	clr.b %d5
	addq.l #1,dp+16
	move.b %d5,dp+23
.L1269:
	tst.l st
	jeq .L1265
.L1266:
	mov3q.l #1,%d6
	cmp.l 1094562388.l,%d6
	jne .L1265
	tst.l st+968
	jeq .L1265
	move.b 1079807565,%d2
	mvs.b %d2,%d0
	lsr.l #7,%d0
	jne .L1362
	addq.l #1,%d2
.L1296:
	move.l pj+160,%d0
	cmp.l pj+156.l,%d0
	jeq .L1300
	move.l pj+156,%d3
	sub.l %d0,%d3
	clr.l -(%sp)
	move.l %d3,%d0
	cmp.l #16383,%d3
	jls .L1298
	mvz.w #16383,%d0
.L1298:
	move.l %d0,-(%sp)
	mov3q.l #6,-(%sp)
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1330
	moveq #2,%d0
	add.l %d3,pj+160
	move.w %d0,pj+180
.L1300:
	move.l pj,%d1
	cmp.l pj+4.l,%d1
	jne .L1301
	tst.b pj+139.l
	jeq .L1302
	mvz.b pj+138,%d1
	mvz.b %d2,%d0
	cmp.l %d1,%d0
	jeq .L1303
.L1302:
	clr.l %d0
.L1304:
	move.l #1081903571,%a0
	lea pj-1081903431,%a1
.L1305:
	tst.l %d0
	jne .L1307
.L1308:
	move.l st+968,%d6
	cmp.l pj+164.l,%d6
	jeq .L1325
	moveq #2,%d7
	move.w %d7,pj+180
.L1325:
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
.L1326:
	move.l #1081903571,%a2
	add.l %a0,%a2
	tst.b (%a2)
	jeq .L1327
	move.b (%a2),%d0
	moveq #127,%d1
	moveq #15,%d3
	and.l %d1,%d0
	move.b %d0,9(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d3
	jne .L1326
.L1327:
	moveq #-9,%d4
	lea (%fp,%a0.l),%a2
	move.b %d4,-131(%a2)
	pea 10(%a0)
	move.l %a1,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1330
	moveq #1,%d5
	move.b %d2,pj+138
	lea st+968,%a0
	lea st+8,%a1
	move.l (%a0),pj+164
	move.l (%a1),pj+168
	move.l #1081903571,%a0
	lea pj-1081903431,%a1
	move.b %d5,pj+139
.L1329:
	move.b (%a0),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L1329
	addq.l #1,pj+176
	jra .L1330
.L1357:
	sub.l %a0,%a0
	jra .L1283
.L1358:
	clr.l %d0
	jra .L1284
.L1360:
	clr.l %d0
.L1643:
	clr.b %d6
	jra .L1285
.L1287:
	moveq #52,%d1
	muls.l %d1,%d0
	move.l #1075575112,%a0
	move.l (%a0,%d0.l),%d6
	clr.l -172(%fp)
	move.l %d6,%d0
	sub.l %a0,%a0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L1288
.L1289:
	moveq #125,%d5
	move.b (%a0,%d6.l),%d1
	move.l %d1,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d5
	jcs .L1288
	lea (-172,%a0),%a1
	mov3q.l #4,%d0
	move.b %d1,(%a1,%fp.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L1289
	jra .L1288
.L1362:
	clr.b %d2
	jra .L1296
.L1301:
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
	jeq .L1330
	addq.l #1,pj+4
	addq.l #1,pj+172
	jra .L1300
.L1303:
	move.l st+968,%d3
	cmp.l pj+164.l,%d3
	jne .L1302
	move.l st+8,%d0
	moveq #99,%d4
	sub.l pj+168,%d0
	cmp.l %d0,%d4
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L1304
.L1307:
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
	jne .L1305
	mvz.b %d3,%d3
	mvz.b %d1,%d1
	cmp.l %d3,%d1
	jne .L1308
	tst.b pj+181.l
	jeq .L1330
	move.l 1100949640,%d0
	mov3q.l #3,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L1309
	move.l %d0,%d1
	add.l #-1073741824,%d1
	cmp.l #129892351,%d1
	jhi .L1309
	move.l %d0,%a0
	add.l #1073744908,%d1
	lea (12,%a0),%a0
	move.l %a0,%a1
.L1312:
	mvz.b (%a1),%d0
	lsr.l #1,%d0
	jeq .L1310
.L1309:
	mvz.w #16383,%d0
	clr.l %d3
.L1311:
	clr.l -(%sp)
	move.l %d0,-(%sp)
	pea 9.w
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1330
	addq.l #1,pj+184
	tst.l %d3
	jeq .L1316
	move.b pj+181,%d0
	mvz.b %d0,%d1
	lsr.l #1,%d1
	jeq .L1316
	clr.b %d7
	subq.l #1,%d0
	move.b %d0,pj+181
	move.b %d7,pj+180
.L1330:
	tst.l st
	jeq .L1334
	mov3q.l #1,%d3
	cmp.l 1094562388.l,%d3
	jne .L1334
	tst.l st+968
	jeq .L1334
	move.l st+44,%d1
	move.l txsx_over,%d0
	cmp.l kd_drop.l,%d1
	jne .L1335
	cmp.l kd_over.l,%d0
	jeq .L1334
.L1335:
	move.l st+8,%a0
	moveq #19,%d4
	sub.l kd_t,%a0
	cmp.l %a0,%d4
	jcc .L1334
	cmp.l #16383,%d1
	jls .L1337
	mvz.w #16383,%d1
.L1337:
	cmp.l #16383,%d0
	jls .L1338
	mvz.w #16383,%d0
.L1338:
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
	jeq .L1334
	lea st+44,%a0
	lea txsx_over,%a1
	lea st+8,%a2
	move.l (%a0),kd_drop
	move.l (%a1),kd_over
	move.l (%a2),kd_t
.L1334:
	move.l -66650100,%d0
	sub.l -176(%fp),%d0
	addq.l #1,st+336
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L1038
	move.l %d0,st+332
.L1038:
	movem.l -228(%fp),#15612
	unlk %fp
	rts
.L1310:
	lea (24,%a1),%a1
	cmp.l %d1,%a1
	jne .L1312
	move.b pj+180,%d0
	move.l %a0,%d3
	tst.b %d0
	jge .L1313
	clr.l %d0
.L1314:
	tst.b (%a0)
	sne %d2
	lea (24,%a0),%a0
	mvs.b %d2,%d2
	sub.l %d2,%d0
	cmp.l %d1,%a0
	jne .L1314
	jra .L1311
.L1316:
	clr.b %d0
	move.b %d0,pj+181
	jra .L1330
.L1313:
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
.L1324:
	mvz.b pj+180,%d0
	sub.l %a3,%a3
	add.l %d1,%d0
	muls.w #24,%d0
	lea (%a0,%d0.l),%a1
	tst.b (%a1)
	sne %d0
	neg.l %d0
	move.b %d0,(%a2)
.L1318:
	move.b (%a1),%d0
	jeq .L1317
	move.b 8(%a1,%a3.l),%d0
	moveq #127,%d5
	and.l %d5,%d0
.L1317:
	addq.l #1,%a3
	move.b %d0,(%a2,%a3.l)
	moveq #15,%d6
	cmp.l %a3,%d6
	jne .L1318
	sub.l %a1,%a1
.L1319:
	move.l %a1,%a3
	addq.l #1,%a1
	tst.b (%a2,%a1.l)
	jne .L1321
.L1322:
	moveq #15,%d3
	cmp.l %a3,%d3
	jeq .L1320
	clr.b %d0
	addq.l #1,%a3
	move.b %d0,(%a2,%a3.l)
	jra .L1322
.L1321:
	moveq #15,%d7
	cmp.l %a1,%d7
	jne .L1319
.L1320:
	addq.l #1,%d1
	lea (16,%a2),%a2
	moveq #8,%d4
	cmp.l %d1,%d4
	jne .L1324
	moveq #-9,%d5
	pea 139.w
	move.l %d2,-(%sp)
	move.b %d5,-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1330
	move.b pj+180,%d0
	addq.l #8,%d0
	move.b %d0,pj+180
	jra .L1330
.L1265:
	lea pj,%a0
	move.l (%a0),%d0
.L1331:
	cmp.l pj+4.l,%d0
	jeq .L1330
	moveq #31,%d1
	moveq #10,%d2
	and.l pj+4,%d1
	mvz.b 8(%a0,%d1.l*4),%d1
	cmp.l %d1,%d2
	jeq .L1332
	addq.l #1,pj+156
.L1332:
	addq.l #1,pj+4
	jra .L1331
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
	jeq .L1645
	sub.l st+8,%d0
	tst.l %d0
	jgt .L1646
.L1645:
	clr.l 44(%sp)
.L1647:
	move.l 16(%a2),%a2
	move.l %a2,52(%sp)
	tst.l st+4
	jne .L1649
	tst.l st+972
	jne .L1650
	tst.b sv+8.l
	jne .L1650
	tst.l 44(%sp)
	jeq .L1652
	jra .L1684
.L1646:
	move.l %d3,%a0
	move.l %d3,%d0
	addq.l #6,%a0
	lea (108,%sp),%a1
	add.l #566,%d0
.L1648:
	move.b 1(%a0),(%a1)
	addq.l #8,%a0
	move.b -8(%a0),1(%a1)
	addq.l #2,%a1
	cmp.l %a0,%d0
	jne .L1648
	mov3q.l #1,44(%sp)
	jra .L1647
.L1649:
	tst.l st+1058
	jne .L1652
	move.l commits,%a6
	cmp.l st+24.l,%a6
	jne .L1654
	move.l 52(%sp),%a0
	move.l %a0,%d0
	add.l #1024,%d0
.L1655:
	clr.l (%a0)+
	cmp.l %a0,%d0
	jne .L1655
	move.l %a6,st+20
.L1656:
	tst.l 44(%sp)
	jeq .L1652
	tst.l st+4
	jne .L1680
	tst.l st+972
	jne .L1681
.L1684:
	tst.b sv+8.l
	jne .L1681
.L1652:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 60(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L1644
	move.l %d0,st+332
.L1644:
	movem.l (%sp),#31996
	lea (248,%sp),%sp
	rts
.L1650:
	move.l commits,%a6
.L1654:
	cmp.l st+340.l,%a6
	jne .L1657
	tst.l st+344
	jeq .L1658
.L1657:
	move.l -66650100,%d2
	move.l sh_seq,%d4
	lea copy32,%a2
	move.l %d2,64(%sp)
	btst #0,%d4
	jne .L1659
	pea 256.w
	pea shadow
	pea comp_in
	jsr (%a2)
	pea 704.w
	pea txt_sh
	pea (tl.0)
	jsr (%a2)
	lea (24,%sp),%sp
	cmp.l sh_seq.l,%d4
	jne .L1659
	pea 256.w
	pea comp_in
	pea comp
	jsr (%a2)
	lea (12,%sp),%sp
	tst.l st+872
	jne .L1660
	clr.l -(%sp)
	pea comp
	pea 64.w
	pea 128.w
	pea st+872
	jsr 1074198978
	lea (20,%sp),%sp
.L1660:
	lea (tl.0),%a2
	clr.l %d5
.L1673:
	tst.b 4(%a2)
	jeq .L1661
	move.l %a2,%d4
	clr.l %d7
	addq.l #8,%d4
	lea st+408,%a5
	lea st+552,%a0
.L1672:
	tst.l (%a5)+
	jeq .L1663
	mvz.b (%a0),%d0
	cmp.l %d0,%d5
	jne .L1663
	lea st+472,%a1
	mvz.b 5(%a0),%d1
	mvz.b (%a1,%d7.l),%d4
	lea (6,%a0),%a3
	sub.l %a1,%a1
.L1665:
	cmp.l %d1,%a1
	jlt .L1666
	move.b 4(%a0),%d0
	lea 72(%sp,%d1.l),%a3
	btst #1,%d0
	jeq .L1685
	move.l %d4,%d0
	add.l #-64,%d0
	move.l %d0,56(%sp)
	tst.l %d0
	jle .L1668
	move.b #43,(%a3)
	addq.l #1,%d1
	lea 72(%sp,%d1.l),%a3
.L1686:
	sub.l %a1,%a1
	jra .L1667
.L1666:
	lea (%a3,%a1.l),%a4
	move.b (%a4),72(%sp,%a1.l)
	addq.l #1,%a1
	jra .L1665
.L1668:
	tst.l 56(%sp)
	jeq .L1686
	move.b #45,(%a3)
	moveq #64,%d2
	mov3q.l #1,%a1
	sub.l %d4,%d2
	move.l %d2,56(%sp)
.L1667:
	lea (68,%sp),%a4
	clr.l %d4
.L1670:
	move.l 56(%sp),%d6
	moveq #10,%d0
	addq.l #1,%d4
	rems.l %d0,%d2:%d6
	divs.l %d0,%d6
	add.l #48,%d2
	move.b %d2,(%a4)
	move.l %d6,56(%sp)
	tst.l %d6
	jeq .L1669
	addq.l #1,%a4
	mov3q.l #4,%d6
	cmp.l %d4,%d6
	jne .L1670
.L1669:
	add.l %a1,%a3
	move.l %d4,%d0
.L1671:
	subq.l #1,%d0
	move.b 68(%sp,%d0.l),(%a3)+
	tst.l %d0
	jne .L1671
	mvz.w #248,%d0
	add.l %sp,%d0
	add.l %d1,%d0
	add.l %d4,%d0
	add.l %d0,%a1
	clr.b %d0
	move.l %sp,%d4
	add.l #72,%d4
	move.b %d0,-176(%a1)
.L1663:
	addq.l #1,%d7
	lea (20,%a0),%a0
	moveq #16,%d1
	cmp.l %d7,%d1
	jne .L1672
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
	jgt .L1661
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
.L1661:
	addq.l #1,%d5
	lea (44,%a2),%a2
	moveq #64,%d0
	cmp.l %d5,%d0
	jne .L1673
	move.l -66650100,%d0
	move.l %a6,st+340
	addq.l #1,st+348
	sub.l 64(%sp),%d0
	add.l %d0,st+356
	cmp.l st+360.l,%d0
	jls .L1674
	move.l %d0,st+360
.L1674:
	clr.l st+344
.L1658:
	pea 256.w
	pea comp
	move.l 60(%sp),-(%sp)
	jsr copy32
	lea (12,%sp),%sp
	cmp.l st+20.l,%a6
	jeq .L1675
	move.l -66650100,%d0
	addq.l #1,st+308
	sub.l t_commit,%d0
	add.l %d0,st+304
	cmp.l st+312.l,%d0
	jls .L1675
	move.l %d0,st+312
.L1675:
	move.l st+388,%d1
	tst.l %d1
	jeq .L1676
	cmp.l st+392.l,%a6
	jeq .L1676
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+396
	addq.l #1,st+400
	cmp.l st+404.l,%d0
	jls .L1677
	move.l %d0,st+404
.L1677:
	clr.l st+388
.L1676:
	move.l st+368,%d1
	tst.l %d1
	jeq .L1678
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+372
	addq.l #1,st+376
	cmp.l st+380.l,%d0
	jls .L1679
	move.l %d0,st+380
.L1679:
	clr.l st+368
.L1678:
	move.l %a6,st+20
	move.l -66650100,%d0
	move.l %d0,st+56
	sub.l t_commit,%d0
	addq.l #1,st+28
	move.l %d0,st+60
	jra .L1656
.L1685:
	move.l %d4,56(%sp)
	jra .L1686
.L1659:
	pea 256.w
	pea comp
	move.l 60(%sp),-(%sp)
	addq.l #1,st+32
	jsr (%a2)
	lea (12,%sp),%sp
	jra .L1656
.L1680:
	tst.l st+1058
	jne .L1652
.L1681:
	move.l %d3,%a0
	add.l #566,%d3
	lea (108,%sp),%a1
	addq.l #6,%a0
.L1682:
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
	jne .L1682
	jra .L1652
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
	jne .L1710
	cmp.l ed+88.l,%d1
	jeq .L1710
	move.l %d1,ed+88
	mov3q.l #1,ed+92
.L1710:
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
	jne .L1711
	moveq #66,%d5
	cmp.l %d2,%d5
	jne .L1712
	tst.b k44+20.l
	jeq .L1713
	clr.b %d6
	move.b %d6,k44+20
	tst.b k44+22.l
	jeq .L1713
	moveq #2,%d7
	move.w %d7,k44+22
.L1713:
	clr.l u46
	tst.b u46+48.l
	jeq .L1714
	clr.b %d0
	move.b %d0,u46+48
.L1721:
	mov3q.l #1,%d0
.L1715:
	move.l -66650100,%d1
	addq.l #1,st+336
	sub.l 64(%sp),%d1
	add.l %d1,st+328
	cmp.l st+332.l,%d1
	jls .L1709
	move.l %d1,st+332
.L1709:
	movem.l (%sp),#31996
	lea (100,%sp),%sp
	rts
.L1712:
	cmp.l #134,%d2
	jne .L1716
	clr.l tk
	tst.l tk+8
	jeq .L1714
	move.l st+248,%d0
	clr.l tk+8
	btst #6,%d0
	jeq .L1717
	moveq #-65,%d1
	and.l %d0,%d1
	move.l %d1,st+248
	tst.l st+4
	jne .L1994
.L1717:
	clr.l %d0
	jra .L1715
.L1716:
	move.l %d2,%d0
	add.l #-68,%d0
	lsr.l #1,%d0
	jne .L1714
	moveq #31,%d1
	mov3q.l #1,%d0
	and.l %d4,%d1
	lsl.l %d1,%d0
	and.l st+208,%d0
	tst.l %d0
	jeq .L1719
	move.l st+200,%d3
	move.l %d3,%d5
	move.l st+220,%d1
	move.l %d1,%d0
	and.l #2097152,%d0
	and.l #786432,%d5
	or.l %d5,%d0
	jeq .L1720
	addq.l #1,nk+16
.L1720:
	and.l #-786433,%d3
	bclr #21,%d1
	move.l %d3,st+200
	move.l %d1,st+220
.L1719:
	moveq #69,%d6
	cmp.l %d2,%d6
	jne .L1714
	tst.l nk
	jeq .L1714
	moveq #-33,%d7
	and.l %d7,st+240
	clr.l nk
	tst.l st+4
	jeq .L1721
	mov3q.l #1,-(%sp)
	pea 69.w
	lea queue_key,%a2
	jsr (%a2)
	clr.l -(%sp)
	pea 69.w
	jsr (%a2)
.L2001:
	jsr flush
.L1989:
	lea (16,%sp),%sp
	jra .L1721
.L1714:
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
	jeq .L1722
	not.l %d0
	and.l %d5,%d0
	move.l %d0,(%a2,%a0.l*4)
	jra .L1721
.L1722:
	move.l %d2,%d4
	mov3q.l #5,%d5
	add.l #-64,%d4
	cmp.l %d4,%d5
	jcs .L1723
	move.l ls+28,%d5
	btst %d4,%d5
	jeq .L1723
	mov3q.l #1,%d0
	lsl.l %d4,%d0
	move.l ls+32,%d1
	not.l %d0
	and.l %d0,%d5
	move.l %d5,ls+28
	btst %d4,%d1
	jeq .L1721
	and.l %d1,%d0
	move.l %d0,ls+32
.L1999:
	clr.l -(%sp)
.L2000:
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
.L1990:
	addq.l #8,%sp
	jra .L1721
.L1723:
	move.l %d1,%a1
	move.l %d0,%d4
	lea (121,%a1),%a1
	lea sq,%a0
	move.l (%a0,%a1.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L1724
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a0,%a1.l*4)
	jra .L1999
.L1724:
	move.l %d1,%a0
	move.l %d0,%d4
	lea (50,%a0),%a0
	move.l (%a2,%a0.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L1725
	not.l %d0
	and.l %d3,%d0
	move.l %d2,%d1
	mov3q.l #7,%d6
	add.l #-112,%d1
	move.l %d0,(%a2,%a0.l*4)
	cmp.l %d1,%d6
	jcs .L1717
	move.l ux,%d3
	btst %d1,%d3
	jeq .L1717
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	not.l %d0
	and.l %d3,%d0
	move.l %d0,ux
.L1994:
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
.L1995:
	addq.l #8,%sp
	jra .L1717
.L1725:
	move.l %d1,%a0
	move.l %d0,%d4
	lea (226,%a0),%a0
	move.l (%a2,%a0.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L1726
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a2,%a0.l*4)
	move.l st+4,%d0
	or.l sq+408,%d0
	jeq .L1717
	jra .L1994
.L1726:
	add.l #58,%d1
	move.l %d0,%d4
	move.l (%a2,%d1.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L1717
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a2,%d1.l*4)
	tst.l st+4
	jeq .L1721
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jra .L1990
.L1711:
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
	jne .L1721
	move.l %d7,%d5
	move.l %d3,%d0
	add.l #58,%d5
	and.l (%a2,%d5.l*4),%d0
	tst.l %d0
	jne .L1721
	move.l %d7,%d0
	add.l #121,%d0
	lea sq,%a5
	move.l (%a5,%d0.l*4),%d0
	and.l %d3,%d0
	tst.l %d0
	jne .L1721
	move.l %d7,%d6
	move.l %d3,%d0
	add.l #50,%d6
	and.l (%a2,%d6.l*4),%d0
	tst.l %d0
	jne .L1717
	move.l %d7,%d0
	add.l #226,%d0
	move.l (%a2,%d0.l*4),%d0
	and.l %d3,%d0
	tst.l %d0
	jne .L1717
	tst.l nk
	jeq .L1727
	move.l %d2,%d1
	add.l #-18,%d1
	lsr.l #1,%d1
	jeq .L1730
	cmp.l #181,%d2
	jne .L1729
.L1730:
	lea (%a4,%d0.l),%a0
	moveq #32,%d1
	move.l (%a0),68(%sp,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L1730
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
	jra .L1995
.L1729:
	clr.l nk
	addq.l #1,nk+8
	tst.l st+4
	jeq .L1727
	mov3q.l #1,-(%sp)
	pea 69.w
	jsr queue_key
	jsr flush
	addq.l #8,%sp
.L1727:
	moveq #66,%d6
	cmp.l %d2,%d6
	jne .L1731
	move.l st+4,%d0
	tst.l %d0
	jeq .L1732
	tst.l st+1058
	jne .L1733
.L1732:
	move.l st+216,%d1
	or.l st+248,%d1
	or.l st+920,%d1
	btst #0,%d1
	jne .L1733
	move.w #256,%d7
	lea st+8,%a0
	move.l (%a0),k44
	move.w %d7,k44+20
.L1733:
	lea st+8,%a0
	move.l (%a0),u46+4
	tst.l sq+408
	jeq .L1764
	tst.l %d0
	jeq .L1736
	tst.l st+1058
	jne .L1764
	move.l sq+484,%d1
	move.l st+232,%d0
.L1738:
	or.l %d1,%d0
	tst.w %d0
	jeq .L1764
	moveq #1,%d0
	clr.b %d1
	addq.l #1,u46+32
	move.b %d0,u46+48
	move.b %d1,k44+20
	jra .L1721
.L1731:
	cmp.l #128,%d2
	jne .L1734
	lea masks,%a0
	move.l (%a0),nk+20
.L1764:
	tst.l st+4
	jeq .L1780
	cmp.l #132,%d2
	jne .L1779
	move.l st+216,%d1
	move.l %d1,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L1779
	moveq #16,%d5
	or.l %d1,%d5
	move.l %d5,st+216
	tst.l st+1058
	jne .L1786
	lea st+8,%a0
	mov3q.l #1,st+1058
	clr.l st+1062
	move.l (%a0),st+1066
	addq.l #1,st+1070
.L1786:
	moveq #1,%d0
	move.l 32(%a3),%a0
	move.b %d0,32(%a0)
	jra .L1717
.L1736:
	move.l sq+484,%d1
	jra .L1738
.L1734:
	moveq #68,%d6
	cmp.l %d2,%d6
	jne .L1739
	move.l tk,%d0
	or.l u46,%d0
	jeq .L1740
	tst.l st+4
	jeq .L1740
	addq.l #1,tk+4
	jra .L1764
.L1740:
	move.l st+216,%d0
	moveq #64,%d7
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d0,%d7
	move.l %d7,%a0
	btst #6,%d0
	jne .L1742
	move.l st+240,%d0
	move.l st+208,%d7
	move.l %d7,%d1
	move.l st+912,%d6
	or.l %d0,%d1
	or.l %d6,%d1
	move.w %d1,%ccr
	jeq .L1743
	tst.b u46+48.l
	jeq .L1744
.L1743:
	move.l st+8,%a1
	mov3q.l #2,%d1
	sub.l u46+4,%a1
	cmp.l %a1,%d1
	jcc .L1745
.L1742:
	moveq #16,%d2
	or.l %d2,st+272
	tst.l %a0
	jne .L1746
	moveq #1,%d4
	addq.l #1,u46+20
	addq.l #1,u46+16
	move.b %d4,k44+21
.L1746:
	tst.l st+4
	jeq .L1747
	tst.b k44+22.l
	jeq .L1748
	tst.b k44+26.l
	jne .L1748
	tst.l %a0
	jne .L1748
	moveq #1,%d6
	moveq #1,%d7
	clr.b %d0
	mvz.w #256,%d5
	move.l %d5,st+296
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
.L1991:
	jsr flush
	jra .L1721
.L1748:
	mov3q.l #3,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr leave
	jra .L1990
.L1747:
	clr.l -(%sp)
.L1997:
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	jra .L1993
.L1745:
	move.w %d7,%ccr
	jeq .L1749
.L1744:
	or.l %d6,%d0
	move.w %d0,%ccr
	jeq .L1749
	tst.b u46+48.l
	jeq .L1764
.L1749:
	addq.l #1,u46+40
	jra .L1764
.L1739:
	moveq #53,%d1
	cmp.l %d2,%d1
	jne .L1750
	move.l st+216,%d6
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d6,50(%sp)
	btst #6,%d6
	jne .L1751
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
	jne .L1752
	tst.b u46+48.l
	jeq .L1764
.L1753:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L1751
.L1752:
	tst.l %d6
	jeq .L1753
.L1751:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #32,%d4
	swap %d4
	or.l %d7,%d1
	or.l %d4,st+268
	btst #6,%d1
	jeq .L1755
	mov3q.l #1,tk
.L1755:
	clr.l st+1038
	tst.l st+4
	jeq .L1756
	moveq #1,%d6
	mvz.w #256,%d5
	moveq #1,%d7
	moveq #1,%d0
	move.l %d5,st+296
	addq.l #1,st+998
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
	jra .L1991
.L1756:
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	addq.l #1,st+994
.L1993:
	lea (12,%sp),%sp
	jra .L1721
.L1750:
	moveq #16,%d1
	cmp.l %d2,%d1
	jne .L1735
	move.l st+216,%d6
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d6,50(%sp)
	btst #6,%d6
	jne .L1757
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
	jne .L1758
	tst.b u46+48.l
	jeq .L1764
.L1759:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L1757
.L1758:
	tst.l %d6
	jeq .L1759
.L1757:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #1,%d4
	swap %d4
	or.l %d7,%d1
	or.l %d4,st+264
	btst #6,%d1
	jeq .L1761
	mov3q.l #1,tk
.L1761:
	clr.l st+1038
	tst.l st+4
	jeq .L1762
	moveq #1,%d6
	mvz.w #256,%d5
	moveq #1,%d7
	moveq #2,%d0
	move.l %d5,st+296
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
.L1996:
	addq.l #1,st+1078
	jra .L1991
.L1762:
	mov3q.l #2,-(%sp)
.L1998:
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	addq.l #1,st+1074
	jra .L1993
.L1735:
	moveq #52,%d1
	cmp.l %d2,%d1
	jne .L1737
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L1763
	tst.b u46+48.l
	jeq .L1764
.L1763:
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #6,%d0
	jne .L1764
	tst.l sq+408
	jeq .L1765
	tst.w sq+486.l
	jne .L1764
.L1765:
	tst.w st+202.l
	jne .L1764
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
	jeq .L1766
	moveq #1,%d6
	moveq #3,%d7
	mvz.w #256,%d5
	move.b %d2,st+161
	move.l %d5,st+296
	move.w %d6,st+162
	move.b %d7,st+993
	jra .L1996
.L1766:
	mov3q.l #3,-(%sp)
	jra .L1998
.L1737:
	moveq #51,%d0
	cmp.l %d2,%d0
	jne .L1741
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L1767
	tst.b u46+48.l
	jeq .L1764
.L1767:
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #6,%d0
	jne .L1764
	tst.l sq+408
	jeq .L1768
	tst.w sq+486.l
	jne .L1764
.L1768:
	tst.w st+202.l
	jne .L1764
	moveq #1,%d1
	moveq #8,%d2
	swap %d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	clr.l st+1038
	move.b %d1,k44+21
	or.l %d2,st+268
	tst.l st+4
	jeq .L1769
	moveq #1,%d5
	moveq #4,%d6
	mvz.w #256,%d4
	move.b %d1,st+161
	move.l %d4,st+296
	move.w %d5,st+162
	move.b %d6,st+993
	jra .L1991
.L1769:
	mov3q.l #4,-(%sp)
	jra .L1997
.L1741:
	moveq #48,%d7
	cmp.l %d2,%d7
	jne .L1754
	move.l st+216,%d0
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d0,50(%sp)
	btst #6,%d0
	jne .L1770
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
	jne .L1771
	tst.b u46+48.l
	jeq .L1764
.L1772:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L1770
.L1771:
	tst.l %d6
	jeq .L1772
.L1770:
	mvz.b 1093765506,%d0
	moveq #11,%d4
	cmp.l %d0,%d4
	jcs .L1850
	move.b 1093765506,%d0
	add.l #16,%d0
.L1773:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #1,%d5
	swap %d5
	or.l %d7,%d1
	or.l %d5,st+268
	btst #6,%d1
	jeq .L1774
	mov3q.l #1,tk
.L1774:
	tst.l st+4
	jeq .L1775
	tst.l st+1038
	jeq .L1776
	mov3q.l #3,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr leave
	addq.l #1,st+1050
	jra .L1990
.L1850:
	moveq #16,%d0
	jra .L1773
.L1776:
	moveq #1,%d7
	moveq #1,%d1
	mvz.w #256,%d6
	move.b %d0,st+993
	mov3q.l #1,st+1038
	addq.l #1,st+1046
	move.l %d6,st+296
	move.b %d7,st+161
	move.w %d1,st+162
	jra .L1991
.L1775:
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	mov3q.l #1,st+1038
	addq.l #1,st+1042
	jra .L1993
.L1754:
	moveq #12,%d6
	cmp.l %d2,%d6
	jcs .L1760
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L1777
	tst.b u46+48.l
	jeq .L1764
.L1777:
	addq.l #1,%d2
	or.l %d3,st+264
	move.l %d2,dp
	addq.l #1,dp+4
	tst.b k44+22.l
	jne .L1721
	moveq #1,%d7
	move.b %d7,k44+21
	jra .L1721
.L1760:
	moveq #49,%d0
	cmp.l %d2,%d0
	jne .L1764
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L1778
	tst.b u46+48.l
	jeq .L1764
.L1778:
	tst.l st+4
	jne .L1779
	tst.l st+972
	jne .L1780
	tst.l sq+408
	jeq .L1781
	tst.w sq+486.l
	jne .L1780
.L1781:
	move.l st+200,%d6
	mvz.w %d6,%d6
	tst.l %d6
	jne .L1780
	move.b 1093765506,%d1
	moveq #11,%d4
	mvz.b %d1,%d2
	cmp.l %d2,%d4
	jlt .L1782
	moveq #127,%d0
	ext.w %d1
	and.l -2147457096,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d6
.L1782:
	moveq #1,%d5
	addq.l #1,u46+24
	addq.l #1,u46+16
	move.b %d5,k44+21
	tst.b ls.l
	jeq .L1783
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1783:
	clr.l u46+8
	moveq #11,%d7
	cmp.l %d2,%d7
	jlt .L1784
	move.l %d6,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L1785
	moveq #45,%d0
	cmp.l %d6,%d0
	jne .L1784
.L1785:
	move.l %d6,-(%sp)
	move.l %d2,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	moveq #127,%d1
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jeq .L1784
	mov3q.l #1,%d2
	or.l st+8,%d2
	move.l %d6,u46+12
	move.l %d2,u46+8
.L1784:
	moveq #2,%d4
	swap %d4
	or.l %d4,st+204
	jra .L1717
.L1780:
	tst.b ls.l
	jeq .L1787
	move.l %d2,%d1
	mov3q.l #5,%d6
	add.l #-64,%d1
	cmp.l %d1,%d6
	jcs .L1788
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	lea flush,%a2
	moveq #68,%d7
	or.l %d0,ls+28
	cmp.l %d2,%d7
	jne .L1789
	tst.l ls+36
	jne .L1790
	move.l st+216,%d0
	or.l st+920,%d0
	or.l st+248,%d0
	btst #0,%d0
	jeq .L1791
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
.L1992:
	jsr (%a2)
	jra .L1990
.L1789:
	moveq #69,%d1
	cmp.l %d2,%d1
	jne .L1790
	tst.l ls+36
	jeq .L1851
.L1790:
	mov3q.l #1,-(%sp)
	or.l %d0,ls+32
	move.l %d2,-(%sp)
	addq.l #1,ls+88
	jsr queue_key
	jra .L1992
.L1791:
	move.l 1100949720,%a3
	move.l %a3,%d0
	clr.l ls+64
	clr.l ls+60
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L1793
	jsr sq_grid
	tst.l %d0
	jeq .L1793
	lea (348,%a3),%a0
	move.l (%a0),ls+60
	lea (344,%a3),%a3
	move.l (%a3),ls+64
.L1793:
	mvz.b ls+1,%d0
	lea st+8,%a0
	move.l (%a0),ls+72
	move.l %d0,ls+68
	moveq #1,%d0
.L1792:
	mov3q.l #3,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	jsr ls_close
	jsr (%a2)
	addq.l #4,%sp
	jra .L1721
.L1851:
	moveq #2,%d0
	jra .L1792
.L1788:
	move.l %d4,%d0
	and.l #240,%d0
	tst.l %d0
	jeq .L1787
	cmp.l #128,%d2
	jeq .L1787
	move.l %d2,%d0
	mov3q.l #2,%d6
	add.l #-80,%d0
	cmp.l %d0,%d6
	jcc .L1787
	add.l #-64,%d0
	moveq #11,%d7
	cmp.l %d0,%d7
	jcc .L1787
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
	tst.l st+4
	jne .L1779
.L1787:
	move.l st+972,%d0
	tst.b ls.l
	jne .L1794
	moveq #68,%d1
	cmp.l %d2,%d1
	jne .L1794
	tst.l %d0
	jne .L1795
	tst.b sv.l
	jeq .L1779
	tst.b sv+8.l
	jeq .L1779
	move.b sv+3,%d7
	jne .L1779
	move.l ls+24,%d0
	mov3q.l #4,%d6
	addq.l #2,%d0
	cmp.l %d0,%d6
	jcs .L1779
	move.b sv+1,%d1
	move.b %d1,59(%sp)
	mvz.b %d1,%d6
	mvz.b 1093765506,%d0
	cmp.l %d6,%d0
	jne .L1779
	move.b sv+2,%d6
	mvz.b %d6,%d1
	move.l %d1,-(%sp)
	move.l %d1,58(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L1796
	moveq #45,%d0
	cmp.l 54(%sp),%d0
	jne .L1779
.L1796:
	tst.l sq+408
	jeq .L1797
	tst.w sq+486.l
	jne .L1779
.L1797:
	move.l st+216,%d0
	or.l st+920,%d0
	or.l st+248,%d0
	btst #0,%d0
	jeq .L1779
	move.b 59(%sp),%d1
	move.b %d6,ls+2
	mvz.b %d6,%d6
	moveq #45,%d2
	move.b %d1,ls+1
	cmp.l %d6,%d2
	jne .L1798
	moveq #10,%d7
.L1798:
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
	jra .L2001
.L1794:
	tst.l %d0
	jeq .L1779
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-80,%d0
	cmp.l %d0,%d1
	jcc .L1779
	add.l #-64,%d0
	moveq #11,%d6
	cmp.l %d0,%d6
	jcc .L1779
.L1795:
	mov3q.l #4,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr splash_end
	addq.l #8,%sp
	mov3q.l #5,%d7
	move.l %d2,%d0
	add.l #-64,%d0
	cmp.l %d0,%d7
	jcs .L1779
	or.l %d3,st+272
	jra .L1721
.L1779:
	move.l st+4,%d0
	tst.l sq+408
	jeq .L1799
	tst.l %d0
	jeq .L1800
	tst.l st+1058
	jne .L1801
.L1800:
	move.l %d2,%d1
	mov3q.l #2,%d6
	add.l #-80,%d1
	cmp.l %d1,%d6
	jcs .L1802
	move.l st+920,%d1
	move.l st+248,%d7
	move.l st+208,%d6
	or.l st+216,%d1
	move.l %d7,46(%sp)
	or.l st+240,%d6
	or.l %d7,%d1
	btst #0,%d1
	jeq .L1803
	move.l sq+484,%a0
	tst.l %d0
	jeq .L1852
	move.l st+232,%a1
.L1804:
	move.l %a0,%d7
	move.l %a1,%d1
	or.l %d7,%d1
	move.l %d1,%d7
	moveq #16,%d1
	mvz.w %d7,%d7
	and.l sq+500,%d1
	or.l %d7,%d1
	jne .L1806
	tst.l %d0
	jeq .L1803
	move.l 46(%sp),%d7
	btst #4,%d7
	jne .L1806
.L1803:
	move.l %d6,%d1
	or.l st+912,%d1
	move.w %d1,%ccr
	jeq .L1808
	tst.b u46+48.l
	jeq .L1809
.L1808:
	move.l sq+484,%a0
	tst.l %d0
	jeq .L1853
	move.l st+232,%d1
.L1810:
	move.l %a0,%d7
	or.l %d7,%d1
	tst.w %d1
	jeq .L1809
.L1806:
	or.l st+912,%d6
	move.w %d6,%ccr
	jeq .L1811
	tst.b u46+48.l
	jeq .L1812
.L1811:
	addq.l #1,u46+36
.L1812:
	tst.l %d0
	jeq .L1813
	move.l st+232,%d0
.L1813:
	move.l %a0,%d1
	or.l %d1,%d0
	move.l %d0,%d1
	mvz.w %d1,%d1
	tst.w %d0
	jeq .L1814
	moveq #80,%d4
	cmp.l %d2,%d4
	jeq .L1854
	moveq #82,%d5
	cmp.l %d2,%d5
	jne .L1855
	moveq #14,%d0
.L1815:
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	mov3q.l #1,-(%sp)
	or.l %d3,st+272
	move.l %d0,-(%sp)
	jsr ed_queue
	jra .L1989
.L1852:
	sub.l %a1,%a1
	jra .L1804
.L1853:
	clr.l %d1
	jra .L1810
.L1814:
	moveq #80,%d6
	cmp.l %d2,%d6
	jeq .L1856
	moveq #82,%d7
	cmp.l %d2,%d7
	jne .L1857
	moveq #10,%d0
	jra .L1815
.L1854:
	moveq #13,%d0
	jra .L1815
.L1855:
	moveq #15,%d0
	jra .L1815
.L1856:
	moveq #9,%d0
	jra .L1815
.L1857:
	moveq #11,%d0
	jra .L1815
.L1849:
	cmp.l #132,%d2
	jne .L1816
	move.l st+216,%d0
	move.l %d0,%d1
	or.l st+920,%d1
	btst #0,%d1
	jeq .L1816
	moveq #16,%d1
	or.l %d0,%d1
	addq.l #1,ed+84
	move.l %d1,st+216
	jra .L1717
.L1817:
	move.l %d4,%d0
	and.l #240,%d0
	tst.l %d0
	jeq .L1819
	and.l #251,%d4
	cmp.l #128,%d4
	jeq .L1819
	moveq #48,%d7
	cmp.l %d2,%d7
	jne .L1820
.L1819:
	lea sq,%a0
	addq.l #1,sq+460
	cmp.l #128,%d2
	jne .L1821
	mov3q.l #1,%d0
	or.l %d0,st+920
.L1822:
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	addq.l #8,%sp
	cmp.l #128,%d2
	sne %d0
.L2002:
	mvs.b %d0,%d0
	neg.l %d0
	jra .L1715
.L1821:
	lea (121,%a6),%a6
	or.l %d3,(%a0,%a6.l*4)
	jra .L1822
.L1827:
	move.l %d2,%d0
	add.l #-66,%d0
	lsr.l #1,%d0
	jne .L1830
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L1829
	move.l masks,%d6
	cmp.l nk+20.l,%d6
	jeq .L1828
.L1829:
	cmp.l #181,%d2
	jne .L1834
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L1838
.L1834:
	tst.l mask_set
	jeq .L1839
	lea mask_keys,%a0
	move.l (%a0,%a6.l*4),%d0
	move.l 60(%sp),%d7
	btst %d7,%d0
	jeq .L1838
.L1839:
	cmp.l #128,%d2
	jne .L1986
	mov3q.l #2,%d4
	jra .L1840
.L1831:
	addq.l #1,nk+24
	jra .L1832
.L1858:
	mov3q.l #1,%d0
	jra .L1835
.L1987:
	move.l %d2,%d0
	mov3q.l #2,%d6
	add.l #-80,%d0
	cmp.l %d0,%d6
	jcs .L1829
.L1837:
	addq.l #1,st+944
.L1823:
	lea (50,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
	jra .L1717
.L1986:
	mov3q.l #1,%d4
.L1840:
	addq.l #1,st+936
	mov3q.l #2,%d1
	cmp.l %d4,%d1
	jne .L1842
	lea (226,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
.L1843:
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	mov3q.l #2,%d2
	addq.l #8,%sp
	cmp.l %d4,%d2
	sne %d0
	jra .L2002
.L1842:
	or.l %d3,(%a2,%d5.l*4)
	jra .L1843
.L1830:
	moveq #69,%d0
	cmp.l %d2,%d0
	jne .L1987
	tst.l mask_set
	jeq .L1833
	lea mask_keys+8,%a0
	btst #5,3(%a0)
	jeq .L1834
.L1833:
	lea st+232,%a1
	clr.l %d1
	sub.l %a0,%a0
.L1836:
	tst.l (%a1)+
	jne .L1858
	tst.l 668(%a1)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1835:
	or.l %d0,%d1
	addq.l #1,%a0
	moveq #8,%d0
	cmp.l %a0,%d0
	jne .L1836
	move.l st+216,%d0
	mov3q.l #1,%d4
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d4,%d0
	or.l %d1,%d0
	jne .L1834
	moveq #32,%d5
	or.l %d5,st+240
	addq.l #1,st+936
	mov3q.l #1,nk
	jra .L1721
.L1826:
	moveq #69,%d1
	cmp.l %d2,%d1
	jeq .L1838
	add.l #-80,%d2
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	jcc .L1837
.L1838:
	addq.l #1,st+940
	jra .L1823
.L1802:
	tst.l %d0
	jeq .L1849
.L1801:
	move.l %d2,%d0
	moveq #11,%d6
	add.l #-144,%d0
	cmp.l %d0,%d6
	jcs .L1824
	moveq #64,%d0
	and.l st+248,%d0
	tst.l %d0
	jeq .L1824
	move.l tk+8,%d0
	tst.l %d0
	jne .L1824
.L1825:
	lea (%a4,%d0.l),%a0
	moveq #32,%d1
	move.l (%a0),68(%sp,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L1825
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
.L1824:
	tst.l st+4
	jeq .L1823
	tst.l st+1058
	jne .L1826
	moveq #68,%d7
	cmp.l %d2,%d7
	jne .L1827
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
	move.l st+232,%d1
	mvz.w %d1,%d1
	or.l %d1,%d0
	jeq .L1834
.L1828:
	addq.l #1,st+936
	moveq #68,%d7
	cmp.l %d2,%d7
	jne .L1831
	addq.l #1,nk+12
.L1832:
	or.l %d3,st+240
	jra .L2003
.L1799:
	tst.l %d0
	jne .L1801
.L1820:
	tst.b sv.l
	jeq .L1801
	moveq #111,%d1
	cmp.l %d2,%d1
	jcc .L1823
	moveq #119,%d4
	cmp.l %d2,%d4
	jcs .L1801
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
	jra .L1995
.L1809:
	tst.l %d0
	jne .L1824
.L1816:
	tst.w sq+486.l
	jeq .L1817
	move.l %d2,%d0
	mov3q.l #5,%d6
	add.l #-48,%d0
	cmp.l %d0,%d6
	jcc .L1818
	moveq #16,%d7
	cmp.l %d2,%d7
	jeq .L1818
	add.l #-20,%d0
	mov3q.l #1,%d1
	cmp.l %d0,%d1
	jcc .L1818
	add.l #-44,%d0
	lsr.l #3,%d0
	jne .L1817
.L1818:
	lea (121,%a6),%a6
	or.l %d3,(%a5,%a6.l*4)
	addq.l #1,st+1054
.L2003:
	mov3q.l #1,-(%sp)
	jra .L2000
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
	jne .L2005
	tst.l sq+408
	jeq .L2006
	tst.w sq+486.l
	jeq .L2006
	mov3q.l #7,%d0
	cmp.l %a6,%d0
	jcs .L2006
	tst.b 20(%a0)
	jne .L2034
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+920,%d0
	and.l %d1,%d0
.L2007:
	add.l %d2,96(%a2,%a6.l*4)
	move.b %d0,st+160
	addq.l #1,sq+464
	jsr flush
.L2008:
	mov3q.l #1,%d2
	jra .L2011
.L2034:
	mov3q.l #1,%d0
	jra .L2007
.L2006:
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr ls_enc
	addq.l #8,%sp
	move.l %d0,%d2
	tst.l %d0
	jne .L2011
	moveq #8,%d3
	cmp.l %a6,%d3
	jne .L2010
	tst.b sv+8.l
	jeq .L2010
	move.l st+8,%a0
	addq.l #1,st+1086
	lea (47,%a0),%a0
	move.l %a0,st+1082
.L2010:
	tst.l st+972
	jeq .L2011
	mov3q.l #5,-(%sp)
	move.l 76(%sp),%a1
	move.l 32(%a1),-(%sp)
	jsr splash_end
	addq.l #8,%sp
.L2011:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 44(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L2004
	move.l %d0,st+332
.L2004:
	move.l %d2,%d0
	movem.l (%sp),#23804
	lea (68,%sp),%sp
	rts
.L2005:
	tst.l st+1058
	jeq .L2012
	addq.l #1,st+952
.L2013:
	clr.l %d2
	jra .L2011
.L2012:
	tst.l mask_set
	jeq .L2014
	moveq #15,%d0
	cmp.l %a6,%d0
	jcs .L2015
	move.l mask_enc,%d0
	move.l %a6,%d1
	btst %d1,%d0
	jne .L2014
.L2015:
	addq.l #1,st+952
	moveq #8,%d3
	cmp.l %a6,%d3
	jne .L2013
	move.l st+8,%a0
	addq.l #1,st+1086
	lea (47,%a0),%a0
	move.l %a0,st+1082
	jra .L2013
.L2014:
	addq.l #1,st+948
	tst.b 20(%a0)
	jne .L2035
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
.L2017:
	move.b %d0,st+160
	moveq #15,%d3
	cmp.l %a6,%d3
	jcs .L2008
	move.l %a6,%d4
	add.l #24,%d4
	add.l %d2,(%a2,%d4.l*4)
	tst.l st+64
	jne .L2019
	move.l #-66650100,%a0
	move.l (%a0),st+64
.L2019:
	tst.l st+388
	jne .L2020
	move.l #-66650100,%a1
	lea commits,%a0
	move.l (%a1),st+388
	move.l (%a0),st+392
.L2020:
	move.l %a6,%d5
	add.l #122,%d5
	lea bind_gen,%a4
	move.l (%a4,%a6.l*4),%d6
	move.l (%a2,%d5.l*4),%a3
	cmp.l %d6,%a3
	jeq .L2023
	btst #0,%d6
	jne .L2023
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
	jne .L2023
	move.l %d3,%d0
	move.l %a6,%d1
	add.l #st+552,%d0
	add.l #102,%d1
	tst.l (%a2,%d1.l*4)
	jeq .L2036
	move.l %d0,%a1
	move.b 48(%sp),%d3
	move.b (%a1),%d1
	eor.l %d1,%d3
	tst.b %d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
.L2025:
	mov3q.l #5,-(%sp)
	move.l %d7,-(%sp)
	move.l %d0,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	tst.l %d3
	jne .L2026
	lea (%a2,%a6.l),%a0
	move.b 49(%sp),472(%a0)
.L2026:
	move.l %d6,(%a2,%d5.l*4)
	move.l %d6,%a3
.L2023:
	tst.l %a3
	jeq .L2027
	move.l %a6,%d0
	moveq #20,%d3
	muls.l %d3,%d0
	lea (%a2,%d0.l),%a0
	mvz.b 552(%a0),%d1
	lsr.l #6,%d1
	jne .L2027
	lea (102,%a6),%a1
	add.l #st,%a6
	tst.l (%a2,%a1.l*4)
	jne .L2028
	move.b 553(%a0),472(%a6)
.L2028:
	move.l %d0,%a0
	add.l #st+556,%a0
	move.b (%a0),%d1
	mvz.b 472(%a6),%d3
	btst #0,%d1
	jeq .L2037
	tst.b st+160.l
	jne .L2038
.L2037:
	mov3q.l #1,%d1
.L2029:
	muls.l %d1,%d2
	move.l %d0,%a0
	add.l #st+554,%a0
	mvz.b (%a0),%d1
	add.l %d3,%d2
	cmp.l %d2,%d1
	jle .L2030
	move.l %d1,%d2
.L2030:
	move.l %d0,%a0
	add.l #st+555,%a0
	mvz.b (%a0),%d1
	cmp.l %d2,%d1
	jge .L2031
	move.l %d1,%d2
.L2031:
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
	jne .L2032
	move.l #-66650100,%a1
	move.l (%a1),st+368
.L2032:
	moveq #1,%d0
	move.l 72(%sp),%a1
	move.l 32(%a1),%a0
	move.b %d0,32(%a0)
.L2027:
	jsr flush
	tst.l (%a2,%d4.l*4)
	jne .L2008
	addq.l #1,st+384
	jra .L2008
.L2035:
	mov3q.l #1,%d0
	jra .L2017
.L2036:
	clr.l %d3
	jra .L2025
.L2038:
	moveq #8,%d1
	jra .L2029
	.size	rui_enc, .-rui_enc
	.align	2
	.globl	pj_write
	.type	pj_write, @function
pj_write:
	move.l 4(%sp),%d0
	move.l 8(%sp),%d1
	cmp.l #1074464814,%d0
	jeq .L2048
	cmp.l #1073958730,%d0
	jeq .L2048
	lea pj_push,%a0
	cmp.l #1074076072,%d0
	jne .L2050
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #5,-(%sp)
.L2063:
	jsr (%a0)
	lea (12,%sp),%sp
.L2048:
	rts
.L2050:
	cmp.l #1074076390,%d0
	jeq .L2051
	cmp.l #1074076276,%d0
	jne .L2052
.L2051:
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #3,-(%sp)
	jra .L2063
.L2052:
	cmp.l #1073959500,%d0
	jne .L2053
	mvz.b pj+137,%d0
	move.l %d1,-(%sp)
	move.l %d0,%a1
	pea -1(%a1)
	mov3q.l #2,-(%sp)
	jra .L2063
.L2053:
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #7,-(%sp)
	jra .L2063
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
	jcs .L2067
	addq.l #1,%d0
.L2066:
	move.b %d0,pj+137
	rts
.L2067:
	clr.b %d0
	jra .L2066
	.size	pj_copy, .-pj_copy
	.align	2
	.globl	pj_save
	.type	pj_save, @function
pj_save:
	move.l 4(%sp),%d0
	tst.l %d0
	jlt .L2068
	move.b 1079807565,%d1
	move.l %d0,-(%sp)
	mvs.b %d1,%d1
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr pj_push
	lea (12,%sp),%sp
.L2068:
	rts
	.size	pj_save, .-pj_save
	.align	2
	.globl	pj_activate
	.type	pj_activate, @function
pj_activate:
	move.l 4(%sp),%d0
	tst.l %d0
	jlt .L2070
	move.l #1074457822,%d1
	cmp.l 8(%sp),%d1
	jne .L2070
	move.l #1074479198,%d1
	cmp.l 12(%sp),%d1
	jne .L2070
	move.l %d0,12(%sp)
	moveq #10,%d0
	mov3q.l #-1,8(%sp)
	move.l %d0,4(%sp)
	jra pj_push
.L2070:
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
	jge .L2073
	moveq #127,%d0
.L2074:
	move.l %d0,-(%sp)
	pea 65.w
	jsr pj_push
	lea (12,%sp),%sp
	rts
.L2073:
	tst.l %d0
	jge .L2074
	clr.l %d0
	jra .L2074
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
	.type	CSWTCH.505, @object
	.size	CSWTCH.505, 7
CSWTCH.505:
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
	.type	CSWTCH.503, @object
	.size	CSWTCH.503, 28
CSWTCH.503:
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
	.size	sv, 128
sv:
	.zero	128
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
	.local	comp_in
	.comm	comp_in,1024,4
	.local	comp
	.comm	comp,1024,4
	.local	staging
	.comm	staging,1024,4
	.local	shadow
	.comm	shadow,1024,4
	.ident	"GCC: (GNU) 16.2.0"
