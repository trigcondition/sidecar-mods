| Mod 0026 - remote UI: the Rytm as a terminal for Sidecar-drawn pages (M1).
| GENERATED from rui.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit rui.c.
#NO_APP
	.file	"rui.c"
	.text
#APP
	  .include "symbols.inc"
  .text
  .globl smpl_cycle_det
  .align 2
smpl_cycle_det:
  move.l 140(%a2),%d1
  addq.l #1,%d1
  lea -16(%sp),%sp
  movem.l %d0-%d1/%a0-%a1,(%sp)
  move.l %a2,-(%sp)
  jsr smpl_hold
  addq.l #4,%sp
  move.l %d0,%d2
  movem.l (%sp),%d0-%d1/%a0-%a1
  lea 16(%sp),%sp
  tst.l %d2
  beq.s 1f
  moveq #0,%d1
1:
  jmp page_cycle_remsl

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
  .globl pmo_lfo_det, pmo_vel_det
  .align 2
pmo_lfo_det:
  jsr pmo_pre
  move.l (%sp),-(%sp)
  jsr 0x4009e790
  addq.l #4,%sp
  jsr pmo_post
  jmp 0x40120fb4
  .align 2
pmo_vel_det:
  move.l 60(%sp),%d0
  adda.l %a2,%a3
  move.l %d0,-(%sp)
  move.l 96(%sp),-(%sp)
  jsr pmo_vel
  addq.l #8,%sp
  moveq #-1,%d1
  cmp.l 72(%sp),%d1
  beq.s 1f
  move.l %d0,%d1
  lsl.l #8,%d1
  move.l %d1,72(%sp)
1:
  jmp 0x4009afa6

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
	lea (-32,%sp),%sp
	movem.l #3196,(%sp)
	move.w 38(%sp),%d3
	move.l -2147457096,%d1
	moveq #43,%d4
	move.l 40(%sp),%d0
	move.l 44(%sp),%d2
	mulu.w #152,%d3
	move.l %d3,%a1
	moveq #127,%d3
	and.l -2147457096,%d3
	mulu.w #2531,%d3
	move.l %d3,%a0
	add.l #1092966773,%a0
	mvz.b (%a0,%a1.l),%d3
	cmp.l %d3,%d4
	jne .L25
	mov3q.l #7,%d5
	cmp.l %d0,%d5
	jge .L45
.L25:
	moveq #127,%d6
	moveq #45,%d3
	and.l %d6,%d1
	mulu.w #2531,%d1
	move.l %d1,%a0
	add.l #1092966707,%a0
	mvz.w %d0,%d1
	lea (%a0,%d1.l*2),%a2
	moveq #127,%d1
	and.l -2147457096,%d1
	add.l %a1,%a2
	mulu.w #2531,%d1
	move.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0,%a1.l),%d1
	cmp.l %d1,%d3
	jne .L27
	moveq #10,%d4
	cmp.l %d0,%d4
	jeq .L46
	tst.l %d0
	jeq .L29
.L30:
	mov3q.l #7,%d4
	cmp.l %d0,%d4
	jge .L28
.L29:
	move.b (%a2),%d0
	mvz.b 1(%a2),%d1
	lsr.l #1,%d1
	lsl.l #7,%d0
	and.l #16256,%d0
	jra .L65
.L27:
	moveq #127,%d1
	moveq #43,%d5
	and.l -2147457096,%d1
	mulu.w #2531,%d1
	move.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0,%a1.l),%d1
	cmp.l %d1,%d5
	jne .L30
	move.l %d0,%d1
	mov3q.l #5,%d6
	subq.l #8,%d1
	cmp.l %d1,%d6
	jcs .L32
	lea CSWTCH.483,%a0
	mvs.b (%a0,%d1.l),%d0
.L28:
	move.l sv+80,%a0
	tst.l %a0
	jeq .L29
	move.l (%a0),%a3
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	move.l 156(%a3),%a0
	jsr (%a0)
	addq.l #8,%sp
	move.l %d0,%d4
	tst.l %d0
	jle .L29
	tst.l %d2
	jlt .L33
	mov3q.l #-1,-(%sp)
	move.l 160(%a3),%a0
	move.l sv+80,-(%sp)
	jsr (%a0)
	addq.l #8,%sp
	move.l %d0,%a0
	tst.l %d0
	jeq .L33
	move.l (%a0),%a1
	move.l %d2,-(%sp)
	move.l %d4,-(%sp)
	move.l 60(%a1),%a0
	move.l %d0,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jge .L47
.L33:
	mov3q.l #-1,-(%sp)
	move.l %d4,-(%sp)
	move.l 84(%a3),%a0
	clr.l %d3
	move.l sv+80,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	move.l %d0,%d2
.L34:
	move.l %d2,%d1
	move.l #1481856080,%d5
	asr.l #8,%d1
	cmp.l 1073848892.l,%d5
	jne .L35
	move.l 1073848896,%a0
	mov3q.l #2,%d5
	move.l %d4,-(%sp)
	move.l %d1,32(%sp)
	jsr (%a0)
	move.b (%a2),%d6
	addq.l #4,%sp
	move.l %d0,%d4
	asr.l #8,%d4
	move.l 28(%sp),%d1
	move.l %d4,%a1
	subq.l #1,%a1
	move.w %d6,%a0
	cmp.l %a1,%d5
	jcs .L35
	move.l %d0,%d6
	mvz.b %d6,%d6
	move.l %d6,%a1
	tst.b %d0
	jeq .L35
	mvz.b %d1,%d1
	tst.l %d3
	jne .L36
	moveq #127,%d5
	move.l %a0,%d0
	and.l %d5,%d0
	mov3q.l #1,%d5
	cmp.l %d4,%d5
	jne .L37
	move.l %d6,%d2
	muls.l %d0,%d2
	asr.l #7,%d2
	cmp.l %d1,%d2
	jne .L39
.L38:
	move.l %d0,%d1
	lsl.l #7,%d1
	mvz.b 1(%a2),%d0
	lsr.l #1,%d0
.L65:
	or.l %d1,%d0
	jra .L24
.L32:
	moveq #13,%d3
	cmp.l %d0,%d3
	jge .L29
	move.l %d1,%d0
	jra .L30
.L46:
	clr.l %d0
	jra .L28
.L47:
	mov3q.l #1,%d3
	jra .L34
.L37:
	cmp.l %d1,%d0
	jeq .L38
	subq.l #3,%d4
	tst.l %d4
	jne .L42
	jra .L44
.L36:
	mov3q.l #3,%d6
	cmp.l %d4,%d6
	jne .L41
.L44:
	move.l %d2,%d3
	asr.l #1,%d3
	moveq #112,%d0
	and.l %d0,%d3
.L42:
	moveq #127,%d4
	cmp.l %d1,%d4
	jlt .L49
	move.l %d1,%d0
	lsl.l #7,%d0
.L43:
	or.l %d3,%d0
.L24:
	movem.l (%sp),#3196
	lea (32,%sp),%sp
	rts
.L41:
	subq.l #1,%d4
	tst.l %d4
	jne .L48
.L39:
	mvs.w %d1,%d1
	move.l %a1,%d2
	lsl.l #7,%d1
	lea -1(%a1,%d1.l),%a0
	move.l %a0,%d1
	divs.l %d2,%d1
.L48:
	clr.l %d3
	jra .L42
.L49:
	move.w #16256,%d0
	jra .L43
.L35:
	lsl.l #7,%d1
	asr.l #1,%d2
	moveq #127,%d5
	and.l %d5,%d2
	and.l #16256,%d1
	move.l %d1,%d0
	or.l %d2,%d0
	jra .L24
.L45:
	clr.w %d0
	jra .L24
	.size	sv_word, .-sv_word
	.align	2
	.type	splash_end, @function
splash_end:
	tst.l st+972
	jeq .L66
	moveq #1,%d0
	lea (8,%sp),%a0
	move.l (%a0),st+988
	move.l 4(%sp),%a0
	clr.l st+972
	move.b %d0,32(%a0)
.L66:
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
	jne .L69
	move.b %d0,ps_pos
	mvz.b %d2,%d0
	move.b %d2,ps_hdr
	mov3q.l #1,%d3
	move.l %d0,%d1
	lsr.l #4,%d1
	cmp.l %d1,%d3
	jeq .L86
	moveq #11,%d3
	cmp.l %d1,%d3
	jeq .L71
	tst.l %d1
	jne .L87
.L90:
	mov3q.l #1,%d0
	jra .L70
.L71:
	cmp.l #179,%d0
	jhi .L72
.L73:
	mov3q.l #3,%d0
.L70:
	subq.l #1,%d0
	move.b %d0,ps_left
.L74:
	move.b %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L72:
	cmp.l #182,%d0
	jeq .L73
	cmp.l #180,%d0
	jeq .L88
	cmp.l #181,%d0
	jeq .L89
	cmp.l #184,%d0
	jeq .L90
.L87:
	mov3q.l #2,%d0
	jra .L70
.L86:
	moveq #10,%d0
	jra .L70
.L88:
	mov3q.l #6,%d0
	jra .L70
.L89:
	mov3q.l #5,%d0
	jra .L70
.L69:
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
	jcs .L75
	and.l %d3,%d0
	lea shs,%a0
	move.b %d2,(%a0,%d0.l)
	jra .L74
.L75:
	move.l %d0,%a0
	lea (80,%a0),%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #4,%d3
	cmp.l %a0,%d3
	jcs .L74
	mvz.b %d1,%d1
	mov3q.l #1,%d3
	cmp.l %d1,%d3
	jne .L77
	move.b %d2,ps_id
	jra .L74
.L77:
	move.b ps_id,%d3
	move.w %d3,%a0
	mvz.b %d3,%d3
	move.l %d3,%a1
	moveq #55,%d3
	cmp.l %a1,%d3
	jne .L78
	mvz.b %d0,%d3
	cmp.l #180,%d3
	jne .L79
	move.l %d1,%d0
	subq.l #2,%d0
.L80:
	lea sht,%a0
	move.b %d2,(%a0,%d0.l)
	tst.b ovt_on.l
	jeq .L74
	move.b ovt_col,%d2
	addq.l #1,uart_sub
	jra .L74
.L79:
	mov3q.l #3,%d1
	and.l %d1,%d0
	jra .L80
.L78:
	lea (-40,%a0),%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #3,%d3
	cmp.l %a0,%d3
	jcs .L81
	move.w #43,%a0
	mvz.b %d0,%d3
	sub.l %a1,%a0
	cmp.l #180,%d3
	jne .L82
	subq.l #2,%d1
.L83:
	move.l %a0,%d0
	lsl.l #2,%d0
	move.l %d0,%a1
	add.l #shp,%a1
	mvz.b ovp_on,%d0
	move.b %d2,(%a1,%d1.l)
	move.l %a0,%d1
	btst %d1,%d0
	jeq .L74
	addq.l #1,uart_sub
	lea ovp_col,%a1
.L103:
	move.b (%a0,%a1.l),%d2
	jra .L74
.L82:
	mov3q.l #3,%d1
	and.l %d0,%d1
	jra .L83
.L81:
	moveq #15,%d3
	cmp.l %a1,%d3
	jcs .L74
	mvz.b %d0,%d3
	cmp.l #180,%d3
	jne .L84
	subq.l #2,%d1
.L85:
	move.l %a1,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #sh,%a0
	move.b %d2,(%a0,%d1.l)
	tst.b ov_on.l
	jeq .L74
	addq.l #1,uart_sub
	lea ov_col,%a0
	jra .L103
.L84:
	mov3q.l #3,%d1
	and.l %d0,%d1
	jra .L85
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
	jcc .L106
	addq.l #1,sq+384
.L105:
	move.l (%sp)+,%a2
	rts
.L106:
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
	jeq .L108
	move.l %a2,%d0
	addq.l #8,%d0
.L109:
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
	jra .L105
.L108:
	move.l %a2,%d0
	add.l #9,%d0
	move.b 19(%sp),8(%a2)
	jra .L109
	.size	sq_event, .-sq_event
	.align	2
	.type	sq_grid, @function
sq_grid:
	move.l 1100949720,%a0
	move.l %a0,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L113
	tst.b 353(%a0)
	jeq .L113
	tst.b 360(%a0)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L110:
	rts
.L113:
	clr.l %d0
	jra .L110
	.size	sq_grid, .-sq_grid
	.align	2
	.type	sq_forget, @function
sq_forget:
	clr.l sq
	tst.b dk_off.l
	jeq .L116
	clr.b %d0
	clr.l ed+268
	clr.l ed+372
	move.b %d0,dk_off
.L116:
	clr.b %d0
	clr.l sq+4
	clr.l pin
	clr.l pin+4
	clr.l sq+8
	clr.l sq+404
	clr.l sq+408
	move.b %d0,dk_arm
	rts
	.size	sq_forget, .-sq_forget
	.align	2
	.type	ls_banked, @function
ls_banked:
	move.l 4(%sp),%d0
	moveq #41,%d1
	cmp.l %d0,%d1
	jcs .L118
	moveq #39,%d1
	cmp.l %d0,%d1
	jcs .L119
.L120:
	clr.l %d0
	jra .L117
.L118:
	move.l %d0,%d1
	mov3q.l #6,%d0
	add.l #-46,%d1
	cmp.l %d1,%d0
	jcs .L120
	moveq #75,%d0
	lsr.l %d1,%d0
	mov3q.l #1,%d1
	and.l %d1,%d0
.L117:
	rts
.L119:
	tst.l ls_host_presets
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L117
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
	jeq .L124
	tst.l %d0
	jeq .L124
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
.L124:
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
	jcs .L142
	move.w .L134(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&13
.L134:
	.word .L141-.L134
	.word .L142-.L134
	.word .L142-.L134
	.word .L140-.L134
	.word .L142-.L134
	.word .L142-.L134
	.word .L139-.L134
	.word .L138-.L134
	.word .L137-.L134
	.word .L136-.L134
	.word .L135-.L134
	.word .L142-.L134
	.word .L133-.L134
.L139:
	tst.l %d0
	jeq .L143
	move.l #cu_wtp2k,%d0
.L131:
	move.l (%sp)+,%d2
	rts
.L138:
	tst.l %d0
	jeq .L144
	move.l #cu_grp2k,%d0
	jra .L131
.L133:
	tst.l %d0
	jne .L150
	move.l #cu_srck,%d0
	jra .L131
.L137:
	tst.l %d0
	jeq .L146
	move.l #cu_lip2k,%d0
	jra .L131
.L136:
	tst.l %d0
	jeq .L147
	move.l #cu_cpp2k,%d0
	jra .L131
.L135:
	tst.l %d0
	jeq .L148
	move.l #cu_mip2k,%d0
	jra .L131
.L140:
	tst.l %d0
	jeq .L131
	move.l #cu_sap2k,%d0
	jra .L131
.L141:
	tst.l %d0
	jeq .L131
.L150:
	move.l #cu_p2k,%d0
	jra .L131
.L142:
	clr.l %d0
	jra .L131
.L143:
	move.l #cu_wtk,%d0
	jra .L131
.L144:
	move.l #cu_grk,%d0
	jra .L131
.L146:
	move.l #cu_lik,%d0
	jra .L131
.L147:
	move.l #cu_cpk,%d0
	jra .L131
.L148:
	move.l #cu_mik,%d0
	jra .L131
	.size	cu_tab, .-cu_tab
	.align	2
	.globl	cu_text
	.type	cu_text, @function
cu_text:
	lea (-48,%sp),%sp
	moveq #84,%d1
	movem.l #15612,(%sp)
	move.l 52(%sp),%d6
	add.l #-1100630172,%d6
	divu.l %d1,%d6
	move.b cu+8,%d5
	move.l 56(%sp),%d4
	move.l %d4,%d3
	move.l 60(%sp),%d2
	asr.l #8,%d3
	lea cu_tab,%a2
	lea cu_src,%a3
	lea cu_p2,%a4
	move.b %d5,43(%sp)
	mvz.b %d5,%d0
	clr.l -(%sp)
	move.l %d0,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
	mov3q.l #1,-(%sp)
	move.l %d0,%d7
	mvz.b cu+1,%d0
	move.l %d0,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
	move.l %d7,%a1
	sub.l %a0,%a0
	move.l %d0,%a2
	clr.l %d1
	add.l #10,%d0
	lea (10,%a1),%a1
.L156:
	mvs.w (%a3,%a0.l),%d5
	cmp.l %d5,%d6
	jne .L152
	tst.l %d7
	jeq .L154
	mvz.b (%a1),%d1
.L154:
	add.l #16,%d0
	lea (16,%a1),%a1
	addq.l #2,%a0
	moveq #16,%d5
	cmp.l %a0,%d5
	jne .L156
	cmp.l #441,%d6
	jne .L157
	moveq #12,%d1
.L157:
	move.l %d3,%d0
	moveq #127,%d5
	cmp.l %d3,%d5
	jge .L158
	moveq #127,%d0
.L159:
	addq.l #1,cu+4
	subq.l #1,%d1
	moveq #32,%d5
	cmp.l %d1,%d5
	jcs .L160
	move.w .L162(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&33
.L162:
	.word .L192-.L162
	.word .L191-.L162
	.word .L190-.L162
	.word .L189-.L162
	.word .L188-.L162
	.word .L187-.L162
	.word .L186-.L162
	.word .L185-.L162
	.word .L182-.L162
	.word .L184-.L162
	.word .L183-.L162
	.word .L182-.L162
	.word .L181-.L162
	.word .L180-.L162
	.word .L179-.L162
	.word .L178-.L162
	.word .L177-.L162
	.word .L176-.L162
	.word .L175-.L162
	.word .L174-.L162
	.word .L160-.L162
	.word .L173-.L162
	.word .L172-.L162
	.word .L171-.L162
	.word .L170-.L162
	.word .L169-.L162
	.word .L168-.L162
	.word .L167-.L162
	.word .L166-.L162
	.word .L163-.L162
	.word .L164-.L162
	.word .L163-.L162
	.word .L161-.L162
.L152:
	mvs.w (%a4,%a0.l),%d5
	cmp.l %d5,%d6
	jne .L154
	tst.l %a2
	jeq .L154
	move.l %d0,%a5
	mvz.b (%a5),%d1
	jra .L154
.L158:
	tst.l %d3
	jge .L159
	clr.l %d0
	jra .L159
.L192:
	moveq #63,%d0
	cmp.l %d3,%d0
	jge .L209
	move.l #cu_loop+10,%d0
.L243:
	move.l %d0,60(%sp)
	move.l #cu_fmt_s,%d1
.L232:
	move.l %d1,56(%sp)
	jra .L228
.L209:
	move.l #cu_loop+5,%d0
	jra .L243
.L191:
	muls.w #3,%d0
	asr.l #7,%d0
	mulu.w #5,%d0
	add.l #cu_loop,%d0
.L240:
	move.l %d0,60(%sp)
	move.l #cu_fmt_s,%d3
	jra .L234
.L190:
	moveq #15,%d5
	cmp.l %d3,%d5
	jge .L194
	clr.l %d0
.L194:
	mulu.w #5,%d0
	add.l #cu_chd,%d0
.L246:
	move.l %d0,60(%sp)
	lea cu_fmt_s,%a0
	jra .L233
.L189:
	mov3q.l #3,%d1
	cmp.l %d3,%d1
	jge .L195
	clr.l %d0
.L195:
	move.l %d0,60(%sp)
	move.l #cu_fmt_inv,%d3
.L234:
	move.l %d3,56(%sp)
.L228:
	move.l %d2,52(%sp)
	movem.l (%sp),#15612
	lea (48,%sp),%sp
	jmp 1074365954
.L188:
	mov3q.l #2,%d5
	cmp.l %d3,%d5
	jge .L196
	clr.l %d0
.L196:
	move.l %d0,60(%sp)
	lea cu_fmt_spr,%a0
.L233:
	move.l %a0,56(%sp)
	jra .L228
.L187:
	move.l %d0,%d1
	mov3q.l #5,%d3
	subq.l #1,%d1
	cmp.l %d1,%d3
	jcs .L197
.L244:
	move.l %d0,60(%sp)
	move.l #cu_fmt_d,%d5
	jra .L235
.L197:
	lea cu_loop,%a0
	move.l %a0,60(%sp)
.L231:
	lea cu_fmt_s,%a5
	jra .L229
.L186:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_warp,%d0
.L236:
	move.l %d0,60(%sp)
	jra .L238
.L185:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #6,%d0
	add.l #cu_win,%d0
	jra .L243
.L184:
	moveq #119,%d5
	cmp.l %d3,%d5
	jlt .L198
	muls.w #99,%d0
	divs.l %d5,%d0
.L237:
	move.l %d0,60(%sp)
	lea cu_fmt_d,%a0
	jra .L233
.L198:
	lea cu_frz,%a5
	move.l %a5,60(%sp)
.L238:
	move.l #cu_fmt_s,%d0
	move.l %d0,56(%sp)
	jra .L228
.L183:
	tst.l %d3
	jle .L199
	asr.l #4,%d0
	mulu.w #5,%d0
	add.l #cu_anim,%d0
	jra .L243
.L181:
	mvs.w %d0,%d0
	lsr.l #3,%d0
	and.l #262140,%d0
	add.l #cu_inpt,%d0
	jra .L246
.L180:
	mvs.w %d0,%d0
	asr.l #6,%d0
	mulu.w #5,%d0
	add.l #cu_mon,%d0
.L230:
	move.l %d0,60(%sp)
	jra .L231
.L179:
	tst.l %d3
	jle .L199
	muls.w #60,%d0
	moveq #126,%d3
	move.l #cu_fmt_db,%d5
	addq.l #3,%d0
	divs.l %d3,%d0
	add.l #-80,%d0
	move.l %d0,60(%sp)
.L235:
	move.l %d5,56(%sp)
	jra .L228
.L178:
	asr.l #1,%d0
	addq.l #1,%d0
	jra .L237
.L177:
	moveq #63,%d1
	cmp.l %d3,%d1
	jge .L200
	muls.w #48,%d0
	moveq #126,%d3
	add.l #-3009,%d0
	divs.l %d3,%d0
	tst.l %d0
	jeq .L214
.L242:
	move.l #cu_fmt_pd,%d1
.L203:
	move.l %d0,60(%sp)
	jra .L232
.L200:
	moveq #64,%d1
	moveq #-126,%d5
	sub.l %d0,%d1
	muls.w #48,%d1
	move.l %d1,%d0
	add.l #63,%d0
	divs.l %d5,%d0
.L214:
	move.l #cu_fmt_d,%d1
	jra .L203
.L176:
	muls.w #100,%d0
	moveq #127,%d3
	move.l #cu_fmt_pct,%d5
	add.l #63,%d0
	divs.l %d3,%d0
	move.l %d0,60(%sp)
	jra .L235
.L175:
	tst.l %d3
	jgt .L237
.L199:
	move.l #cu_off,%d3
.L239:
	move.l %d3,60(%sp)
	jra .L241
.L174:
	mvs.w %d0,%d0
	asr.l #3,%d0
	jeq .L202
	addq.l #1,%d0
	move.l %d0,60(%sp)
	lea cu_fmt_x,%a5
.L229:
	move.l %a5,56(%sp)
	jra .L228
.L173:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_tape,%d0
	jra .L240
.L172:
	muls.w #3,%d0
	lsr.l #5,%d0
	and.l #262140,%d0
	add.l #cu_dir,%d0
	move.l %d0,60(%sp)
.L241:
	move.l #cu_fmt_s,%d5
	jra .L235
.L171:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_cloop,%d0
	jra .L246
.L170:
	tst.l %d3
	jle .L202
.L160:
	move.l %d0,60(%sp)
	lea cu_fmt_d,%a5
	jra .L229
.L168:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_dst,%d0
	jra .L236
.L167:
	mvs.w %d0,%d0
	asr.l #3,%d0
	move.l #cu_fmt_d,%d1
	addq.l #1,%d0
	move.l %d0,60(%sp)
	jra .L232
.L166:
	tst.l %d3
	jle .L199
	add.l #-64,%d0
	moveq #64,%d5
	cmp.l %d3,%d5
	jge .L214
	jra .L242
.L164:
	tst.l %d3
	jle .L199
	subq.l #1,%d0
	muls.w #127,%d0
	moveq #126,%d3
	divs.l %d3,%d0
	jra .L244
.L163:
	tst.l %d3
	jle .L199
	subq.l #1,%d0
	jra .L237
.L161:
	muls.w #9,%d0
	asr.l #7,%d0
	mulu.w #6,%d0
	add.l #cu_play,%d0
	jra .L230
.L169:
	moveq #126,%d1
	cmp.l %d3,%d1
	jge .L204
	move.l #cu_hold,%d3
	jra .L239
.L204:
	tst.l %d3
	jgt .L237
.L202:
	move.l #cu_slc,%d0
	jra .L243
.L182:
	cmp.l #441,%d6
	jeq .L215
	move.b 43(%sp),%d5
	mov3q.l #6,%d1
	add.l #-46,%d5
	mvz.b %d5,%d5
	cmp.l %d5,%d1
	jcs .L216
	lea CSWTCH.543,%a0
	mvs.b (%a0,%d5.l),%d1
.L205:
	tst.l %d3
	jle .L199
	asr.l #5,%d4
	mov3q.l #7,%d3
	mov3q.l #-1,%d5
	and.l %d3,%d4
	cmp.l %d1,%d5
	jeq .L206
	lea ux,%a1
	lea (%a1,%d1.l),%a0
	mvz.b 3948(%a0),%d3
	cmp.l %d3,%d4
	jne .L206
	mvz.w #1280,%d3
	moveq #10,%d5
	muls.l %d0,%d5
	muls.l %d1,%d3
	move.l %d5,%a0
	add.l %d3,%a0
	tst.b 40(%a1,%a0.l)
	jeq .L206
	mulu.w #10,%d0
	mulu.w #1280,%d1
	move.l %d0,%a0
	lea 40(%a0,%d1.l),%a0
	move.l %a0,%d0
	add.l %a1,%d0
	jra .L230
.L215:
	clr.l %d1
	jra .L205
.L216:
	mov3q.l #-1,%d1
	jra .L205
.L206:
	move.l %d0,-(%sp)
	move.l %d4,%a0
	pea 65(%a0)
	pea cu_fmt_bk
	move.l %d2,-(%sp)
	jsr 1074365954
	movem.l 16(%sp),#15612
	lea (64,%sp),%sp
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
.L249:
	lea (%a2,%d0.l),%a4
	moveq #84,%d2
	move.l %d1,%a3
	move.l (%a4),(%a3,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d2
	jne .L249
	tst.b 10(%a1)
	jeq .L250
	lea cu_text,%a2
	move.l %a2,32(%a3)
.L250:
	move.l (%a1),40(%a0)
	move.l 4(%a1),48(%a0)
	move.l 28(%sp),44(%a0)
	mvz.b 14(%a1),%d0
	move.w 12(%a1),%d1
	lsl.l #8,%d0
	and.l #2048,%d1
	move.l %d0,8(%a0)
	move.b 15(%a1),%d0
	jeq .L251
	mvz.b %d0,%d0
	lsl.l #8,%d0
.L252:
	move.l %d0,12(%a0)
	mvz.b 11(%a1),%d0
	lsl.l #8,%d0
	move.l %d0,16(%a0)
	tst.w %d1
	jeq .L248
	mov3q.l #1,20(%a0)
.L248:
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	rts
.L251:
	tst.w %d1
	jeq .L254
	mvz.w #32736,%d0
	jra .L252
.L254:
	mvz.w #32512,%d0
	jra .L252
	.size	cu_knob, .-cu_knob
	.align	2
	.type	cu_src_setup, @function
cu_src_setup:
	lea (-36,%sp),%sp
	movem.l #31804,(%sp)
	move.l 40(%sp),%d2
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	move.l %d0,%a2
	tst.l %d0
	jeq .L259
	moveq #40,%d0
	cmp.l %d2,%d0
	jeq .L259
	move.l #1094564988,%a0
.L261:
	move.l (%a0),%d0
	addq.l #4,%a0
	move.l %d0,-68(%a0)
	move.l %d0,-100(%a0)
	move.l %d0,-132(%a0)
	move.l %d0,-164(%a0)
	move.l %d0,-196(%a0)
	cmp.l #1094565020,%a0
	jne .L261
	mvz.b cu+8,%d0
	cmp.l %d0,%d2
	jeq .L262
.L264:
	move.l %d2,%d5
	clr.l %d3
	add.l #-43,%d5
	lea cu_src,%a6
	lea CSWTCH.541,%a5
	lea cu_knob,%a4
	move.l #1075575064,%a3
.L263:
	moveq #9,%d0
	cmp.l %d5,%d0
	jcs .L266
	move.l (%a5,%d5.l*4),%d0
.L265:
	move.w (%a6)+,%d4
	move.l %d0,-(%sp)
	mvz.w %d3,%d0
	addq.l #1,%d3
	lsl.l #4,%d0
	pea (%a2,%d0.l)
	mvs.w %d4,%d0
	mulu.w #52,%d4
	move.l %d0,-(%sp)
	jsr (%a4)
	lea (12,%sp),%sp
	move.l %d2,(%a3,%d4.l)
	moveq #8,%d0
	cmp.l %d3,%d0
	jne .L263
	move.b %d2,cu+8
	jra .L259
.L262:
	move.l 1075595808,%d0
	cmp.l 4(%a2),%d0
	jne .L264
	move.l 1075596276,%d0
	cmp.l 116(%a2),%d0
	jne .L264
	cmp.l 1075595760.l,%d2
	jne .L264
.L259:
	movem.l (%sp),#31804
	lea (36,%sp),%sp
	rts
.L266:
	move.l #cu_fm_short,%d0
	jra .L265
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
	jle .L276
	moveq #127,%d0
	moveq #-13,%d1
	and.l -2147457096,%d0
	sub.l %d2,%d1
	moveq #-24,%d3
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l #1092966773,%a0
	mvz.w #152,%d0
	muls.l %d1,%d0
	move.b (%a0,%d0.l),%d0
	cmp.l %d2,%d3
	jgt .L277
	mvz.b %d0,%d2
	mov3q.l #2,%d4
	move.l %d2,%a0
	lea (-48,%a0),%a0
	cmp.l %a0,%d4
	jcc .L278
	moveq #43,%d3
	cmp.l %d2,%d3
	jne .L277
.L278:
	move.b %d0,cu+9
	mvz.b cu+30,%d0
	lea st+8,%a0
	move.b %d1,cu+10
	move.l (%a0),cu+16
	cmp.l %d0,%d1
	jne .L291
	move.b cu+28,%d0
.L279:
	move.b %d0,cu+29
.L277:
	clr.l %d0
.L275:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L291:
	clr.b %d0
	jra .L279
.L276:
	tst.l %d2
	jge .L281
	mvz.b cu+9,%d0
	moveq #50,%d1
	cmp.l %d0,%d1
	jne .L282
	mvz.b cu+10,%d1
	move.l %d2,%d0
	not.l %d0
	cmp.l %d1,%d0
	jeq .L292
.L282:
	mvz.b cu+11,%d0
	neg.l %d2
	cmp.l %d0,%d2
	jne .L277
	move.l st+8,%d0
	mov3q.l #3,%d2
	sub.l cu+24,%d0
	cmp.l %d0,%d2
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L275
.L281:
	cmp.l #441,%d2
	jeq .L293
	lea cu_src,%a0
	clr.l %d3
.L284:
	mvs.w (%a0),%d1
	cmp.l %d1,%d2
	jne .L283
	mvz.b cu+8,%d0
	clr.l -(%sp)
	move.l %d0,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L277
	mvz.w %d3,%d3
	move.l %d0,%a0
	lsl.l #4,%d3
	mvz.w 12(%a0,%d3.l),%d0
	jra .L275
.L283:
	addq.l #2,%a0
	addq.l #1,%d3
	moveq #8,%d1
	cmp.l %d3,%d1
	jne .L284
	mvz.b %d0,%d0
	moveq #11,%d3
	cmp.l %d0,%d3
	jge .L285
	clr.l %d0
.L285:
	moveq #127,%d1
	and.l -2147457096,%d1
	mulu.w #152,%d0
	mulu.w #2531,%d1
	move.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0,%d0.l),%d3
	mvz.b cu+1,%d0
	cmp.l %d3,%d0
	jne .L277
	mov3q.l #1,-(%sp)
	move.l %d3,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L277
	move.l 1075596172,%d1
	move.l %d0,%a0
	cmp.l 116(%a0),%d1
	jne .L277
	lea cu_p2,%a0
	clr.l %d1
.L286:
	mvs.w (%a0),%d4
	cmp.l %d4,%d2
	jne .L287
	moveq #40,%d2
	cmp.l %d3,%d2
	jne .L290
	mov3q.l #3,%d2
	cmp.l %d1,%d2
	jge .L277
.L290:
	mvz.w %d1,%d1
	move.l %d0,%a0
	lsl.l #4,%d1
	mvz.w 12(%a0,%d1.l),%d0
	jra .L275
.L287:
	addq.l #2,%a0
	addq.l #1,%d1
	moveq #8,%d4
	cmp.l %d1,%d4
	jne .L286
	jra .L277
.L292:
	mov3q.l #1,%d0
	jra .L275
.L293:
	mvz.w #2944,%d0
	jra .L275
	.size	cu_steps, .-cu_steps
	.align	2
	.type	pmo_time, @function
pmo_time:
	move.l -66650100,%d0
	add.l pmo+116,%d0
	sub.l 4(%sp),%d0
	move.l %d0,pmo+116
	rts
	.size	pmo_time, .-pmo_time
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
.L309:
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr (%a2)
	addq.l #1,%a6
	addq.l #4,%d2
	addq.l #8,%sp
	moveq #16,%d0
	cmp.l %a6,%d0
	jne .L309
	move.l %sp,%d2
	sub.l %a6,%a6
	lea shs,%a3
	add.l #22,%d2
	lea rui_uart_raw,%a2
.L311:
	move.b (%a3,%a6.l),%d0
	mvz.b %d0,%d1
	cmp.l #255,%d1
	jeq .L310
	move.l %a6,%d1
	moveq #32,%d3
	or.l %d3,%d1
	move.b %d0,23(%sp)
	move.b %d1,22(%sp)
	move.l %d2,-(%sp)
	mov3q.l #2,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
.L310:
	addq.l #1,%a6
	mov3q.l #4,%d0
	cmp.l %a6,%d0
	jne .L311
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
	jne .L318
	lea txsx_wait,%a2
	jsr (%a2)
	move.l %d0,%d2
	tst.l %d0
	jeq .L319
	addq.l #1,st+40
.L318:
	clr.l %d2
.L317:
	move.l %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L319:
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L321
	addq.l #1,st+40
	jra .L317
.L321:
	jsr (%a2)
	tst.l %d0
	jne .L322
	mvz.w #4027,%d0
	cmp.l 1094562392.l,%d0
	jlt .L322
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L323:
	tst.l %a0
	jeq .L322
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L323
	move.l 12(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	mov3q.l #1,%d2
	addq.l #1,st+36
	jra .L317
.L322:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #1,st+40
	addq.l #4,%sp
	jra .L317
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
.L332:
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
	jgt .L332
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
	jne .L335
	mvz.b mr+18,%d0
	cmp.l -12(%fp),%d0
	jeq .L334
.L335:
	pea 8.w
	pea -8(%fp)
	move.b -9(%fp),-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L334
	clr.b %d0
	lea (-9,%fp),%a0
	move.b (%a0),mr+18
	move.b %d0,mr+19
	move.w mr+20,%d0
	addq.l #1,%d0
	move.w %d0,mr+20
.L334:
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
.L342:
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
	jeq .L341
	addq.l #1,%d1
.L341:
	lea (152,%a1),%a1
	cmp.l #1824,%a1
	jne .L342
	tst.b mr+12.l
	jne .L343
	sub.l %a0,%a0
.L344:
	lea (%a2,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a3,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L344
	moveq #127,%d0
	and.l -2147457096,%d0
	move.b %d0,mr+18
	moveq #1,%d0
	move.b %d0,mr+12
.L345:
	mov3q.l #1,%a6
	jra .L340
.L343:
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L346
	move.b %d0,mr+13
.L347:
	move.l %a2,-(%sp)
	pea 12.w
	clr.l -(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L340
	sub.l %a0,%a0
.L350:
	lea (%a2,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a3,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L350
	clr.b %d0
	move.b %d0,mr+13
	move.w mr+16,%d0
	addq.l #1,%d0
	move.w %d0,mr+16
	jsr kit_tick
.L340:
	move.l %a6,%d0
	movem.l (%sp),#23556
	lea (32,%sp),%sp
	rts
.L346:
	clr.l %d2
	tst.b mr+13.l
	jne .L347
.L348:
	mvz.b (%a3,%d2.l),%d0
	mvz.b (%a2)+,%d1
	cmp.l %d1,%d0
	jeq .L352
	pea 20(%sp)
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L340
	lea (-1,%a2),%a0
	move.b (%a0),(%a3,%d2.l)
	move.w mr+14,%d0
	addq.l #1,%d0
	move.w %d0,mr+14
.L352:
	addq.l #1,%d2
	moveq #12,%d0
	cmp.l %d2,%d0
	jne .L348
	jsr kit_tick
	jra .L345
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
.L371:
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
	jeq .L366
	clr.w %d7
	lea ar+48,%a3
	move.w %d7,(%a5,%d1.l*2)
	moveq #127,%d1
	and.l -2147457096,%d1
	mvz.b (%a3,%a6.l),%d6
	cmp.l %d6,%d1
	jne .L366
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
.L366:
	move.b 1(%a0),%d6
	move.b (%a0),%d0
	lsl.l #2,%d6
	mvz.b %d0,%d1
	and.l #768,%d6
	or.l %d1,%d6
	mvz.w (%a2),%d1
	cmp.l %d1,%d6
	jne .L367
	mvz.w ar+60,%d1
	move.l %a6,%d7
	btst %d7,%d1
	jeq .L368
.L367:
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
	jeq .L365
	move.w %d6,(%a2)
	move.l %a6,%d1
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	addq.l #1,ar+62
	move.w ar+60,%d1
	not.l %d0
	and.l %d1,%d0
	move.w %d0,ar+60
.L368:
	addq.l #1,%a6
	add.l #152,%d5
	addq.l #2,%a2
	add.l #162,%d4
	moveq #12,%d6
	cmp.l %a6,%d6
	jne .L371
.L365:
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
.L380:
	lea (%a1,%d0.l),%a2
	move.b (%a2),-9(%fp,%d0.l)
	move.l %d0,%a0
	addq.l #1,%d0
	cmp.l 16(%fp),%d0
	jne .L380
	moveq #-9,%d0
	move.b %d0,-8(%fp,%a0.l)
	pea 9(%a0)
	pea -16(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L379
	addq.l #1,sq+456
.L379:
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
.L390:
	moveq #15,%d3
	cmp.l %d0,%d3
	jcs .L405
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
	jeq .L391
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
.L391:
	addq.l #1,%d1
	cmp.l #256,%d1
	jne .L390
.L405:
	tst.b %d2
	jeq .L389
	move.l %a0,kq_owes
	move.l %d0,st+196
.L389:
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
	jeq .L407
	move.l st+8,%d0
	cmp.l #16383,%d0
	jls .L408
	mvz.w #16383,%d0
.L408:
	move.l #-260222380,%d1
	move.l %d1,-12(%fp)
	move.l %d0,%d1
	lsr.l #7,%d1
	move.w #13569,%a0
	pea 11.w
	pea -12(%fp)
	move.b %d1,-6(%fp)
	moveq #127,%d1
	and.l %d1,%d0
	move.w %a0,-8(%fp)
	move.w #32513,%a0
	move.b %d0,-5(%fp)
	moveq #-9,%d0
	move.w %a0,-4(%fp)
	move.b %d0,-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L406
	clr.b %d1
	addq.l #1,qp+8
	addq.l #1,st+968
	mov3q.l #1,qp+48
	mov3q.l #1,qp+100
	addq.l #1,pmo+68
	move.b %d1,st+992
.L407:
	tst.b st+161.l
	jeq .L411
	move.w st+162,%d1
	move.l #-260222380,%a0
	move.w #12289,%a1
	move.l %a0,-12(%fp)
	lea st+993,%a0
	move.b (%a0),-6(%fp)
	pea 10.w
	pea -12(%fp)
	mvz.w %d1,%d0
	lsr.l #8,%d0
	lsl.l #8,%d1
	move.w %a1,-8(%fp)
	add.l %d1,%d0
	move.w %d0,-5(%fp)
	moveq #-9,%d0
	move.b %d0,-3(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L406
	clr.b %d1
	move.b %d1,st+161
.L411:
	lea ls+4,%a0
	clr.l %d2
	move.l %fp,%d3
	move.l #-260222380,%a3
	lea ls,%a2
	add.l #-12,%d3
	move.l %a0,-16(%fp)
.L413:
	cmp.l ls+24.l,%d2
	jcs .L416
.L415:
	move.w %d2,%d0
	move.l ls+24,%d1
	move.l %d1,-16(%fp)
	mulu.w #5,%d0
	lea (%a2,%d0.l),%a0
	move.l %d2,%d0
.L417:
	cmp.l -16(%fp),%d0
	jcs .L418
	move.l -16(%fp),%d1
	sub.l %d2,%d1
	move.l %d1,-16(%fp)
	move.l %d1,ls+24
	tst.l %d1
	jne .L406
	lea st+164,%a2
	move.l %a2,%a4
.L419:
	move.l -16(%fp),%a0
	cmp.l st+196.l,%a0
	jcc .L423
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
	jne .L420
.L423:
	move.l st+196,%d0
	move.l -16(%fp),%d1
.L421:
	cmp.l %d0,%d1
	jcs .L424
	sub.l -16(%fp),%d0
	move.l %d0,st+196
	tst.l %d0
	jne .L406
	move.l kq_owes,%d2
	tst.l %d2
	jeq .L425
	movem.l -36(%fp),#7180
	unlk %fp
	jra (kq_owed_in.part.0)
.L416:
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
	jeq .L415
	addq.l #5,-16(%fp)
	addq.l #1,%d2
	jra .L413
.L418:
	addq.l #5,%a0
	addq.l #5,%a2
	move.b -1(%a0),-1(%a2)
	addq.l #1,%d0
	move.b (%a0),(%a2)
	move.b 1(%a0),1(%a2)
	move.b 2(%a0),2(%a2)
	move.b 3(%a0),3(%a2)
	jra .L417
.L420:
	addq.l #2,%a4
	addq.l #1,-16(%fp)
	jra .L419
.L424:
	move.l -16(%fp),%a1
	addq.l #1,%d1
	move.b (%a2,%a1.l*2),(%a2)
	lea 1(%a2,%a1.l*2),%a0
	addq.l #2,%a2
	move.b (%a0),-1(%a2)
	jra .L421
.L425:
	lea st+96,%a2
.L430:
	move.l (%a2)+,-16(%fp)
	tst.l -16(%fp)
	jeq .L426
	moveq #-63,%d0
	cmp.l -16(%fp),%d0
	jle .L427
	moveq #-63,%d1
.L444:
	move.l %d1,-16(%fp)
.L428:
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
	jeq .L406
	move.l -16(%fp),%d1
	sub.l %d1,-4(%a2)
	move.l st+64,%d1
	tst.l %d1
	jeq .L426
	move.l -66650100,%d0
	sub.l %d1,%d0
	move.l %d0,st+68
	add.l %d0,st+316
	addq.l #1,st+320
	cmp.l st+324.l,%d0
	jls .L429
	move.l %d0,st+324
.L429:
	clr.l st+64
.L426:
	addq.l #1,%d2
	moveq #16,%d0
	cmp.l %d2,%d0
	jne .L430
.L406:
	movem.l -36(%fp),#7180
	unlk %fp
	rts
.L427:
	moveq #63,%d0
	cmp.l -16(%fp),%d0
	jge .L428
	moveq #63,%d1
	jra .L444
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
	jeq .L445
	move.l ed+64,%d0
	move.l %d0,%a0
	mov3q.l #7,%d2
	sub.l ed+68,%a0
	cmp.l %a0,%d2
	jcc .L447
	addq.l #1,ed+72
.L445:
	move.l (%sp)+,%d2
	rts
.L447:
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
	jcc .L448
	lea (-16,%a1),%a1
	mov3q.l #1,%d2
	cmp.l %a1,%d2
	jcc .L448
	mvz.b 1093765506,%d0
	moveq #11,%d2
	cmp.l %d0,%d2
	jcc .L449
.L448:
	moveq #127,%d0
.L450:
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
	jra .L445
.L449:
	move.b 1093765506,%d0
	jra .L450
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
	jcc .L455
	addq.l #1,ls+92
.L454:
	move.l (%sp)+,%a2
	move.l (%sp)+,%a3
	rts
.L455:
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
	jra .L454
	.size	ls_queue, .-ls_queue
	.align	2
	.type	ls_close, @function
ls_close:
	lea ls,%a0
	tst.b ls.l
	jeq .L457
	clr.b %d0
	clr.l ls+36
	addq.l #1,ls+80
	clr.l st+96
	clr.l st+124
	move.b %d0,ls
	mvz.b 7(%sp),%d0
	addq.l #1,100(%a0,%d0.l*4)
	move.l %d0,-(%sp)
	clr.l -(%sp)
	jsr ls_queue
	addq.l #8,%sp
.L457:
	rts
	.size	ls_close, .-ls_close
	.align	2
	.type	ls_enc, @function
ls_enc:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.b ls,%d2
	move.l 16(%sp),%d0
	move.l 20(%sp),%d3
	tst.b %d2
	jeq .L460
	tst.l ls+36
	jeq .L461
	move.b ls+2,%d1
	add.l #-40,%d1
	mvz.b %d1,%d1
	lsr.l #1,%d1
	jeq .L461
	mov3q.l #7,%d1
	cmp.l %d0,%d1
	jne .L461
	add.l %d3,st+124
.L476:
	jsr flush
	jra .L462
.L461:
	mvz.b ls+125,%d1
	cmp.l %d1,%d0
	jeq .L460
	mov3q.l #3,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L464:
	clr.l %d0
.L459:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L460:
	or.l st+972,%d0
	jne .L464
	tst.b %d2
	jne .L465
	tst.b sv.l
	jeq .L464
	tst.b sv+8.l
	jeq .L464
	move.b sv+2,%d4
	mvz.b %d4,%d3
	move.l %d3,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L466
	moveq #45,%d1
	cmp.l %d3,%d1
	jeq .L466
	moveq #43,%d1
	cmp.l %d3,%d1
	jne .L459
.L466:
	lea sv+1,%a0
	moveq #45,%d0
	move.b (%a0),ls+1
	move.b %d4,ls+2
	cmp.l %d3,%d0
	jeq .L469
	moveq #43,%d1
	cmp.l %d3,%d1
	jne .L467
.L469:
	moveq #10,%d2
.L467:
	clr.b %d0
	moveq #1,%d4
	lea st+8,%a0
	move.l (%a0),ls+126
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.b %d2,ls+124
	move.b %d0,ls+125
	move.b %d4,ls
	addq.l #1,ls+76
	jsr ls_queue
	jsr flush
	addq.l #8,%sp
.L462:
	mov3q.l #1,%d0
	jra .L459
.L465:
	add.l %d3,st+96
	addq.l #1,ls+84
	jra .L476
	.size	ls_enc, .-ls_enc
	.align	2
	.type	pmo_get, @function
pmo_get:
	lea (-28,%sp),%sp
	movem.l #3196,(%sp)
	move.l 32(%sp),%d3
	move.l %d3,%d2
	lsl.l #6,%d2
	lea pmo,%a2
	move.l 36(%sp),%d5
	lea (%a2,%d2.l),%a0
	add.l %d5,%a0
	mvz.b 584(%a0),%d0
	tst.l %d0
	jne .L478
	clr.b %d1
	move.l pmo+104,%d4
	move.l pmo+9096,%d0
	lea pmo+9100,%a1
.L479:
	tst.l %d0
	jne .L481
	tst.b %d1
	jeq .L482
	clr.l pmo+9096
.L482:
	moveq #127,%d0
	cmp.l %d4,%d0
	jcc .L488
	clr.l %d0
	jra .L477
.L478:
	mulu.w #44,%d0
	add.l #pmo+3420,%d0
.L477:
	movem.l (%sp),#3196
	lea (28,%sp),%sp
	rts
.L481:
	subq.l #1,%d0
	moveq #1,%d1
	mvz.b (%a1,%d0.l),%d6
	cmp.l %d6,%d4
	jls .L479
	move.l %d0,pmo+9096
	lea (%a2,%d0.l),%a0
	mvz.b 9100(%a0),%d0
	move.l %d0,%a1
	jra .L486
.L488:
	move.l %d4,%a1
.L486:
	move.l %a1,%d1
	moveq #44,%d6
	muls.l %d6,%d1
	move.w %a1,%d0
	move.l %d5,%a3
	addq.l #1,(%a2)
	lea (%a2,%d1.l),%a0
	move.l %d3,%d1
	addq.l #1,%d1
	mulu.w #42,%d3
	move.b %d1,3464(%a0)
	clr.w %d1
	mulu.w #44,%d0
	move.b %d5,3465(%a0)
	clr.l 3500(%a0)
	clr.l 3492(%a0)
	lea 26(%a3,%d3.l),%a3
	clr.l 3488(%a0)
	clr.l 3480(%a0)
	clr.l 3476(%a0)
	clr.l 3468(%a0)
	add.l #pmo+3464,%d0
	move.w %d1,3466(%a0)
	move.l %a3,3504(%a0)
	lea (%a2,%d2.l),%a0
	add.l %d5,%a0
	move.l %a1,%d1
	addq.l #1,%d1
	move.b %d1,584(%a0)
	cmp.l %d4,%d1
	jls .L477
	move.l %d1,pmo+104
	jra .L477
	.size	pmo_get, .-pmo_get
	.align	2
	.type	pj_push, @function
pj_push:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.l 20(%sp),%d1
	move.l 24(%sp),%a1
#APP
| 5058 "rui.c" 1
	tas pj+136
	smi %d2
| 0 "" 2
#NO_APP
	tst.b %d2
	jeq .L494
	addq.l #1,pj+156
.L493:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L494:
	move.l pj,%d3
	move.l %d3,%d0
	sub.l pj+4,%d0
	lsr.l #5,%d0
	jeq .L496
	addq.l #1,pj+156
.L497:
	clr.b %d0
	move.b %d0,pj+136
	jra .L493
.L496:
	moveq #31,%d0
	and.l %d3,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #pj+8,%a0
	move.b 19(%sp),(%a0)
	moveq #127,%d0
	cmp.l %d1,%d0
	jcs .L500
	move.l %d1,%d0
	addq.l #1,%d0
.L498:
	move.b %d0,1(%a0)
	moveq #127,%d4
	cmp.l %a1,%d4
	jcs .L499
	move.l %a1,%d2
	addq.l #1,%d2
.L499:
	move.b %d2,2(%a0)
	addq.l #1,%d3
	move.l %d3,pj
	jra .L497
.L500:
	clr.b %d0
	jra .L498
	.size	pj_push, .-pj_push
	.align	2
	.type	led_restore, @function
led_restore:
	tst.b ov_on.l
	jeq .L501
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L503
	addq.l #1,st+1018
.L501:
	rts
.L503:
	clr.b %d0
	move.b %d0,ov_on
	jsr led_stock
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #4,%sp
	move.l st+8,%d0
	addq.l #4,%d0
	tst.l %d0
	jne .L504
	mov3q.l #1,%d0
.L504:
	move.l %d0,led_again
	addq.l #1,st+1014
	jra .L501
	.size	led_restore, .-led_restore
	.align	2
	.type	led_tick, @function
led_tick:
	move.l st+4,%d0
	lea (-32,%sp),%sp
	movem.l #19460,(%sp)
	or.l sq+408,%d0
	move.l led_gen,%d1
	tst.l %d0
	jne .L509
	clr.l sq+468
	clr.l st+1006
.L510:
	clr.b %d1
	move.b %d1,led_owed
	jsr led_restore
	move.l led_again,%d0
	tst.l %d0
	jeq .L508
	tst.b ov_on.l
	jne .L508
	move.l st+8,%d1
	sub.l %d0,%d1
	jmi .L508
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L519
.L535:
	addq.l #1,st+1018
.L508:
	movem.l (%sp),#19460
	lea (32,%sp),%sp
	rts
.L509:
	tst.l sq+468
	jne .L511
	lea led_gen,%a0
	move.l (%a0),st+1002
	lea pg_gen,%a1
	move.l #2139062143,%a2
	clr.l st+1006
	mov3q.l #1,sq+476
	move.l (%a1),sq+472
	move.l %a2,sq+480
.L511:
	mov3q.l #1,sq+468
	cmp.l st+1002.l,%d1
	jeq .L512
	btst #0,%d1
	jne .L512
	move.b led_req_mode,%d0
	lea led_req,%a1
	move.w %d0,%a0
	clr.l %d0
.L513:
	lea (%a1,%d0.l),%a2
	moveq #16,%d2
	move.b (%a2),16(%sp,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d2
	jne .L513
	cmp.l led_gen.l,%d1
	jne .L512
	move.l %d1,st+1002
	move.w %a0,%d1
	lea st+1022,%a0
	mvz.b %d1,%d0
	move.l %d0,st+1006
	clr.l %d0
.L515:
	lea 16(%sp,%d0.l),%a1
	moveq #16,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L515
	moveq #1,%d2
	move.b %d2,led_owed
.L512:
	mov3q.l #1,%d0
	cmp.l st+1006.l,%d0
	jne .L510
	clr.l led_again
	tst.b ov_on.l
	jeq .L520
	tst.b led_owed.l
	jeq .L508
.L520:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jeq .L535
	clr.l %d0
	lea st+1022,%a2
	lea ov_col,%a0
.L521:
	lea (%a2,%d0.l),%a1
	moveq #16,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L521
	moveq #1,%d2
	sub.l %a6,%a6
	lea led_send4,%a3
	move.b %d2,ov_on
.L522:
	move.b (%a2,%a6.l),%d0
	move.b %d0,19(%sp)
	move.b %d0,18(%sp)
	move.b %d0,17(%sp)
	move.b %d0,16(%sp)
	pea 16(%sp)
	move.l %a6,-(%sp)
	jsr (%a3)
	addq.l #1,%a6
	addq.l #8,%sp
	moveq #16,%d0
	cmp.l %a6,%d0
	jne .L522
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.b %d1
	addq.l #1,st+1010
	move.b %d1,led_owed
	jra .L534
.L519:
	jsr led_stock
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.l led_again
.L534:
	addq.l #4,%sp
	jra .L508
	.size	led_tick, .-led_tick
	.align	2
	.globl	rui_sysex
	.type	rui_sysex, @function
rui_sysex:
	link.w %fp,#-80
	move.l -66650100,%d1
	move.l 12(%fp),%d0
	movem.l #15612,(%sp)
	move.l %d1,-38(%fp)
	move.l 8(%fp),%a5
	mov3q.l #6,%d2
	cmp.l %d0,%d2
	jge .L540
	mvz.b 5(%a5),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L540
	mvz.b -1(%a5,%d0.l),%d1
	cmp.l #247,%d1
	jeq .L538
.L540:
	addq.l #1,rx_bad
	jra .L539
.L538:
	move.b 4(%a5),%d3
	move.l %d0,%d2
	moveq #50,%d4
	subq.l #7,%d2
	move.l %d3,%d1
	add.l #-40,%d1
	mvz.b %d1,%d1
	cmp.l %d1,%d4
	jcs .L540
	move.w .L542(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&51
.L542:
	.word .L561-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L560-.L542
	.word .L559-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L558-.L542
	.word .L540-.L542
	.word .L557-.L542
	.word .L556-.L542
	.word .L555-.L542
	.word .L554-.L542
	.word .L553-.L542
	.word .L540-.L542
	.word .L552-.L542
	.word .L551-.L542
	.word .L550-.L542
	.word .L549-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L548-.L542
	.word .L547-.L542
	.word .L546-.L542
	.word .L545-.L542
	.word .L540-.L542
	.word .L544-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L543-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L540-.L542
	.word .L541-.L542
.L555:
	mov3q.l #4,%d5
	cmp.l %d2,%d5
	jge .L562
	move.b 7(%a5),%d2
	moveq #15,%d6
	mvz.b %d2,%d4
	cmp.l %d4,%d6
	jcs .L562
	mvz.b 8(%a5),%d5
	mov3q.l #7,%d7
	cmp.l %d5,%d7
	jcs .L562
	move.b 9(%a5),%d1
	jeq .L562
	move.b 10(%a5),%d3
	jeq .L562
	mvz.b %d1,%d6
	add.l %d6,%d4
	moveq #16,%d6
	cmp.l %d4,%d6
	jlt .L562
	mvz.b %d3,%d4
	move.l %d5,%a0
	moveq #8,%d7
	add.l %d4,%a0
	cmp.l %a0,%d7
	jlt .L562
	ext.w %d3
	ext.w %d1
	mov3q.l #7,%d7
	add.l #-12,%d0
	muls.w %d3,%d1
	lsl.l #3,%d1
	move.l %d1,%d3
	addq.l #6,%d3
	divs.l %d7,%d3
	add.l %d1,%d3
	cmp.l %d0,%d3
	jne .L562
	mvs.b %d2,%d2
	lea (11,%a5),%a2
	clr.l %d0
	lsl.l #6,%d2
	move.l %d2,%a0
	add.l %d5,%a0
	add.l #staging,%a0
.L566:
	move.l %d1,%a1
	mov3q.l #7,%d2
	cmp.l %d1,%d2
	jge .L563
	mov3q.l #7,%a1
.L563:
	move.l %a2,%a3
	sub.l %a1,%d1
	mvz.b (%a3)+,%d3
	clr.l %d2
.L565:
	move.l %d3,%d5
	lsr.l #1,%d3
	move.b 1(%a2,%d2.l),%d6
	lsl.l #7,%d5
	or.l %d6,%d5
	move.b %d5,(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d4,%d0
	jne .L564
	addq.l #8,%a0
	clr.l %d0
.L564:
	addq.l #1,%d2
	cmp.l %a1,%d2
	jne .L565
	lea (%a3,%a1.l),%a2
	tst.l %d1
	jgt .L566
.L777:
	moveq #1,%d3
	addq.l #6,%a5
	move.b (%a5),st_seq
	move.b %d3,st_valid
	jra .L552
.L562:
	clr.b %d4
	addq.l #1,rx_bad
	move.b %d4,st_valid
.L539:
	move.l -66650100,%d0
	addq.l #1,mt_calls
	sub.l -38(%fp),%d0
	add.l %d0,mt_sum
	cmp.l mt_max.l,%d0
	jls .L722
	move.l %d0,mt_max
.L722:
	movem.l -80(%fp),#15612
	mov3q.l #1,%d0
	unlk %fp
	rts
.L554:
	tst.l %d2
	jeq .L540
	tst.b st_valid.l
	jeq .L568
	mvz.b 6(%a5),%d1
	mvz.b st_seq,%d0
	cmp.l %d1,%d0
	jne .L568
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
.L568:
	clr.b %d0
	move.b %d0,st_valid
.L552:
	addq.l #1,rx
	jra .L539
.L553:
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jge .L540
	tst.b 7(%a5)
	jeq .L570
	moveq #1,%d2
	move.b %d2,host_open
	jra .L552
.L570:
	moveq #1,%d3
	move.b %d3,host_close
	jra .L552
.L541:
	move.l qp+56,%d4
	tst.l %d2
	jeq .L571
	move.b 6(%a5),%d5
	mov3q.l #3,%d6
	mvz.b %d5,%d0
	move.b %d5,-40(%fp)
	cmp.l %d0,%d6
	jcc .L572
	mov3q.l #7,%d7
	cmp.l %d0,%d7
	jcs .L573
	clr.l %d1
.L575:
	tst.b 6(%a5,%d1.l)
	jlt .L574
	addq.l #1,%d1
	cmp.l %d2,%d1
	jlt .L575
	mov3q.l #7,%d1
	cmp.l %d0,%d1
	jne .L576
	mov3q.l #1,%d3
	cmp.l %d2,%d3
	jne .L574
	addq.l #1,pmo+64
.L577:
	addq.l #1,qp+72
	jra .L552
.L576:
	mov3q.l #6,%d5
	cmp.l %d0,%d5
	jne .L578
	mov3q.l #5,%d6
	cmp.l %d2,%d6
	jne .L574
	mvz.b 10(%a5),%d1
	lsr.l #6,%d1
	jeq .L579
.L574:
	addq.l #1,pmo+20
.L571:
	mov3q.l #1,%d0
.L598:
	addq.l #1,qp+72
	tst.l %d0
	jeq .L603
	addq.l #1,qp+76
.L603:
	move.l %d4,%d1
	sub.l qp+60,%d1
	lsr.l #2,%d1
	jeq .L604
	addq.l #1,qp+80
	tst.l %d0
	jeq .L552
	tst.l %d2
	jeq .L692
	move.b 6(%a5),%d0
	moveq #127,%d4
	and.l %d4,%d0
.L605:
	move.l %d0,qp+88
	addq.l #1,qp+92
	jra .L552
.L578:
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L688
	mov3q.l #4,%d5
.L580:
	mov3q.l #3,%d3
	cmp.l %d2,%d3
	jge .L574
	move.b 9(%a5),%d1
	mvz.b %d1,%d6
	tst.b %d1
	jeq .L574
	mov3q.l #4,%d7
	cmp.l %d0,%d7
	jne .L689
	move.w #28,%a0
.L581:
	cmp.l %d6,%a0
	jlt .L574
	ext.w %d1
	muls.w %d5,%d1
	addq.l #4,%d1
	cmp.l %d2,%d1
	jne .L574
	lea (10,%a5),%a0
	sub.l %a1,%a1
.L587:
	mvz.b (%a0),%d3
	moveq #12,%d1
	cmp.l %d3,%d1
	jcs .L574
	move.b 1(%a0),%d7
	move.w %d7,%a2
	moveq #63,%d7
	move.l %a2,%d1
	and.l %d7,%d1
	moveq #40,%d7
	move.l %d1,%a3
	subq.l #1,%a3
	cmp.l %a3,%d7
	jcs .L582
	mov3q.l #4,%d7
	cmp.l %d1,%d7
	jeq .L574
	moveq #12,%d7
	cmp.l %d3,%d7
	jne .L583
	moveq #29,%d3
	cmp.l %d1,%d3
	jeq .L574
	moveq #37,%d7
	cmp.l %d1,%d7
	jcs .L574
.L583:
	mov3q.l #4,%d3
	cmp.l %d0,%d3
	jeq .L585
.L586:
	addq.l #1,%a1
	add.l %d5,%a0
	cmp.l %d6,%a1
	jlt .L587
.L579:
	moveq #127,%d1
	and.l -2147457096,%d1
	mvz.b 7(%a5),%d2
	cmp.l %d2,%d1
	jeq .L588
	addq.l #1,pmo+8
	jra .L577
.L688:
	mov3q.l #5,%d5
	jra .L580
.L689:
	move.w #22,%a0
	jra .L581
.L582:
	move.l %d1,%a3
	mov3q.l #7,%d7
	lea (-48,%a3),%a3
	cmp.l %a3,%d7
	jcs .L584
	moveq #12,%d1
	cmp.l %d3,%d1
	jeq .L574
	mov3q.l #4,%d3
	cmp.l %d0,%d3
	jne .L574
.L585:
	move.l %a2,%d7
	btst #6,%d7
	jeq .L586
	jra .L574
.L584:
	moveq #56,%d7
	cmp.l %d1,%d7
	jne .L574
	moveq #12,%d1
	cmp.l %d3,%d1
	jne .L583
	jra .L574
.L588:
	lea fp,%a0
	mov3q.l #6,%d3
	move.l (%a0),pmo+60
	move.b 8(%a5),%d1
	move.b 7(%a5),%d2
	move.b %d1,-34(%fp)
	move.b %d2,-33(%fp)
	cmp.l %d0,%d3
	jeq .L690
	mvz.b 9(%a5),%d6
.L589:
	mov3q.l #4,%d4
	cmp.l %d0,%d4
	seq %d1
	neg.l %d1
	tst.b %d1
	jeq .L590
	mov3q.l #4,%a3
.L591:
	lea (10,%a5),%a0
	clr.l %d3
	lea pmo,%a2
.L592:
	cmp.l %d3,%d6
	jeq .L577
	mov3q.l #6,%d5
	cmp.l %d0,%d5
	jne .L593
	mvz.b 10(%a5),%d1
	clr.b %d7
	mvz.b 9(%a5),%d2
	clr.b %d5
	lsl.l #7,%d1
	sub.l %a4,%a4
	move.b %d7,-39(%fp)
	or.l %d1,%d2
	move.l %d2,%a1
.L594:
	move.l pmo+56,%d4
	move.l %d4,%d1
	sub.l pmo+80,%d1
	lsr.l #8,%d1
	jeq .L595
	addq.l #1,pmo+4
.L596:
	addq.l #1,%d3
	add.l %a3,%a0
	jra .L592
.L690:
	mov3q.l #1,%d6
	jra .L589
.L590:
	mov3q.l #5,%a3
	jra .L591
.L593:
	move.b 1(%a0),%d1
	mvz.b 3(%a0),%d2
	move.b (%a0),-39(%fp)
	move.w %d1,%a4
	mvz.b 2(%a0),%d1
	lsl.l #7,%d1
	or.l %d1,%d2
	move.l %d2,%a1
	mov3q.l #5,%d2
	cmp.l %d0,%d2
	jne .L691
	move.b 4(%a0),%d5
	jra .L594
.L691:
	clr.b %d5
	jra .L594
.L595:
	move.l %d4,%d1
	mvz.b %d1,%d1
	move.b -39(%fp),%d7
	move.l %d1,%d2
	add.l #177,%d2
	lsl.l #3,%d2
	lsl.l #3,%d1
	move.b %d7,(%a2,%d2.l)
	move.w %a4,%d7
	lea (%a2,%d1.l),%a4
	move.b -40(%fp),1418(%a4)
	move.b -34(%fp),1419(%a4)
	move.w %a1,1420(%a4)
	move.b %d5,1422(%a4)
	move.b -33(%fp),1423(%a4)
	move.b %d7,1(%a2,%d2.l)
	addq.l #1,%d4
	move.l %d4,pmo+56
	jra .L596
.L572:
	mov3q.l #1,%d6
	cmp.l %d0,%d6
	jne .L573
	mov3q.l #5,%d7
	cmp.l %d2,%d7
	jne .L573
	mvz.b 8(%a5),%d5
	mvz.b 10(%a5),%d3
	mvz.b 7(%a5),%d0
	clr.l %d6
	lsl.l #7,%d5
	lsl.l #7,%d3
	and.l #3968,%d5
	and.l #3968,%d3
	or.l %d0,%d5
	mvz.b 9(%a5),%d0
	or.l %d0,%d3
	or.l %d5,%d3
.L600:
	btst %d6,%d3
	jeq .L599
	jsr 1075312702
	mov3q.l #1,%d7
	clr.l -(%sp)
	move.l %d5,%d1
	lsr.l %d6,%d1
	move.l %d0,%a0
	and.l %d1,%d7
	move.l %d7,-(%sp)
	move.l %d6,-(%sp)
	pea 48(%a0)
	jsr 1074493548
	lea (16,%sp),%sp
.L599:
	addq.l #1,%d6
	moveq #12,%d0
	cmp.l %d6,%d0
	jne .L600
.L601:
	clr.l %d0
	jra .L598
.L573:
	mov3q.l #2,%d1
	cmp.l %d2,%d1
	jne .L602
	cmp.l %d0,%d1
	jne .L571
	mvz.b 7(%a5),%d3
	moveq #12,%d5
	cmp.l %d3,%d5
	jcs .L571
	jsr 1075312702
	clr.l -(%sp)
	move.l %d3,%a0
	pea -1(%a0)
	move.l %d0,%a1
	pea 352(%a1)
	jsr 1074429188
.L776:
	lea (12,%sp),%sp
	jra .L601
.L602:
	mov3q.l #3,%d1
	cmp.l %d2,%d1
	jne .L571
	cmp.l %d0,%d1
	jne .L571
	move.b 7(%a5),%d3
	moveq #11,%d5
	move.l %d3,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d5
	jcs .L571
	move.b 8(%a5),%d5
	jmi .L571
	lsl.l #8,%d5
	jsr 1075398792
	mvz.b %d3,%d3
	move.l %d3,%a0
	and.l #65280,%d5
	move.l %d5,-(%sp)
	pea -1(%a0)
	move.l %d0,-(%sp)
	jsr 1074499748
	jra .L776
.L692:
	clr.l %d0
	jra .L605
.L604:
	tst.l %d2
	jeq .L693
	move.b 6(%a5),%d1
	moveq #127,%d5
	and.l %d5,%d1
.L606:
	mov3q.l #3,%d2
	and.l %d4,%d2
	lea qp,%a0
	move.b %d1,64(%a0,%d2.l*2)
	move.b %d0,65(%a0,%d2.l*2)
	addq.l #1,%d4
	move.l %d4,qp+56
	jra .L552
.L693:
	clr.b %d1
	jra .L606
.L544:
	mov3q.l #2,%d6
	cmp.l %d2,%d6
	jne .L607
	mvz.b 6(%a5),%d0
	moveq #127,%d7
	cmp.l %d0,%d7
	jne .L608
	mvz.b 7(%a5),%d0
	mov3q.l #1,%d1
	cmp.l %d0,%d1
	jcs .L608
	move.l %d0,ls_host_presets
	jra .L552
.L607:
	mov3q.l #1,%d3
	cmp.l %d2,%d3
	jge .L540
.L608:
	mvz.b 6(%a5),%d0
	moveq #126,%d4
	cmp.l %d0,%d4
	jne .L610
	move.b 7(%a5),%d0
	mov3q.l #1,%d5
	and.l %d0,%d5
	move.l %d5,fk_claim
	jra .L552
.L610:
	subq.l #2,%d2
	tst.l %d2
	jne .L540
	moveq #11,%d7
	cmp.l %d0,%d7
	jcs .L540
	mvz.b 7(%a5),%d0
	lsr.l #1,%d0
	jne .L540
	mvz.w 6(%a5),%d0
	move.l %d0,ls_in_v
	addq.l #1,ls_in_gen
	jra .L552
.L561:
	subq.l #6,%d2
	tst.l %d2
	jne .L540
	move.l %a5,%d0
	add.l #12,%d0
	lea (6,%a5),%a0
.L614:
	tst.b (%a0)
	jlt .L540
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L614
	addq.l #1,pc_seq
	clr.l %d0
	lea pc_req,%a0
.L615:
	lea 6(%a5,%d0.l),%a1
	mov3q.l #6,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L615
	addq.l #1,pc_seq
	jra .L552
.L558:
	tst.l %d2
	jeq .L540
	move.b 6(%a5),%d0
	mov3q.l #1,%d3
	mvz.b %d0,%d1
	cmp.l %d1,%d3
	jcs .L540
	jne .L617
	moveq #17,%d4
	cmp.l %d2,%d4
	jne .L540
	move.l %a5,%d1
	add.l #23,%d1
	lea (7,%a5),%a0
.L620:
	mvz.b (%a0),%d2
	moveq #111,%d5
	cmp.l %d2,%d5
	jcs .L540
	addq.l #1,%a0
	cmp.l %a0,%d1
	jne .L620
.L617:
	addq.l #1,led_gen
	move.b %d0,led_req_mode
	clr.l %d0
	lea led_req,%a0
.L621:
	mvz.b 6(%a5),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L622
	moveq #16,%d3
	cmp.l %d0,%d3
	jne .L623
.L622:
	addq.l #1,led_gen
	jra .L552
.L623:
	lea 7(%a5,%d0.l),%a1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	jra .L621
.L560:
	moveq #14,%d4
	cmp.l %d0,%d4
	jcs .L540
	mvz.w #21504,%d1
	btst %d0,%d1
	jeq .L540
	mvz.b 7(%a5),%d0
	moveq #31,%d5
	cmp.l %d0,%d5
	jcs .L540
	mov3q.l #4,%d6
	cmp.l %d2,%d6
	jge .L625
	mvz.b 10(%a5),%d0
	cmp.l %d0,%d5
	jcs .L540
	mov3q.l #7,%d7
	cmp.l %d2,%d7
	jne .L625
	mvz.b 12(%a5),%d0
	cmp.l %d0,%d5
	jcs .L540
.L625:
	addq.l #1,sq_gen
	clr.l %d0
	lea sq_req,%a0
.L627:
	cmp.l %d2,%d0
	jge .L694
	moveq #127,%d3
	move.b 6(%a5,%d0.l),%d1
	and.l %d3,%d1
.L626:
	move.b %d1,(%a0,%d0.l)
	addq.l #1,%d0
	mov3q.l #7,%d4
	cmp.l %d0,%d4
	jne .L627
	addq.l #1,sq_gen
	jra .L552
.L694:
	clr.b %d1
	jra .L626
.L547:
	subq.l #2,%d2
	tst.l %d2
	jne .L540
	mvz.b 7(%a5),%d0
	moveq #31,%d6
	cmp.l %d0,%d6
	jcs .L540
	lsl.l #7,%d0
	mvz.b 6(%a5),%d1
	addq.l #1,pin+56
	or.l %d0,%d1
	move.l %d1,pin+4
	jra .L552
.L546:
	move.l %d0,%d1
	moveq #14,%d7
	add.l #-10,%d1
	rems.l %d7,%d6:%d1
	tst.l %d6
	jne .L695
	mov3q.l #3,%d1
.L630:
	mov3q.l #2,%d3
	cmp.l %d2,%d3
	jge .L631
	move.b 6(%a5),%d4
	mvz.b %d4,%d5
	cmp.l %d5,%d3
	jcs .L631
	move.b 7(%a5),%d3
	mvz.b %d3,%d7
	move.l %d7,%a0
	mov3q.l #1,%d7
	cmp.l %a0,%d7
	jcs .L631
	tst.l %d6
	jeq .L632
	add.l #-11,%d0
	moveq #14,%d7
	rems.l %d7,%d6:%d0
	tst.l %d6
	jne .L631
.L632:
	mov3q.l #4,%d0
	cmp.l %d1,%d0
	jne .L633
	mvz.b 9(%a5),%d0
	lsr.l #3,%d0
	jeq .L633
.L631:
	addq.l #1,ux+12
	jra .L540
.L695:
	mov3q.l #4,%d1
	jra .L630
.L633:
	ext.w %d4
	tst.b %d3
	jne .L634
	move.l %d5,%a0
	add.l #ux,%a0
	mvz.b 3948(%a0),%d0
	mov3q.l #4,%d7
	cmp.l %d1,%d7
	jne .L635
	mvz.b 9(%a5),%d3
	cmp.l %d0,%d3
	jeq .L636
.L634:
	move.w %d4,%d0
	mulu.w #1280,%d0
	move.l %d0,%a0
	add.l #ux+40,%a0
	mvz.w #128,%d0
.L637:
	clr.b (%a0)
	subq.l #1,%d0
	lea (10,%a0),%a0
	tst.l %d0
	jne .L637
	mov3q.l #4,%d0
	cmp.l %d1,%d0
	jne .L696
.L636:
	move.b 9(%a5),%d3
.L638:
	lea ux,%a0
	lea (%a0,%d5.l),%a1
	move.b %d3,3948(%a1)
	moveq #127,%d3
	mulu.w #1280,%d4
	lea (%a5,%d1.l),%a2
	addq.l #1,%d1
	move.b 8(%a5),%d0
	and.l %d3,%d0
	move.b %d0,36(%a0,%d5.l)
.L639:
	move.l %d1,%d0
	add.l #12,%d0
	cmp.l %d2,%d0
	jlt .L644
	addq.l #1,ux+8
	jra .L552
.L696:
	clr.b %d3
	jra .L638
.L644:
	move.b 6(%a2),%d0
	jmi .L640
	ext.w %d0
	move.l %d4,%a0
	mulu.w #10,%d0
	lea 40(%a0,%d0.l),%a1
	sub.l %a0,%a0
	add.l #ux,%a1
.L641:
	move.b 7(%a2,%a0.l),%d3
	moveq #94,%d5
	move.l %d3,%d0
	add.l #-32,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d5
	jcs .L642
	move.b %d3,(%a1,%a0.l)
	addq.l #1,%a0
	moveq #9,%d0
	cmp.l %a0,%d0
	jne .L641
.L642:
	clr.b %d6
	move.b %d6,(%a1,%a0.l)
.L640:
	lea (14,%a2),%a2
	add.l #14,%d1
	jra .L639
.L543:
	move.b 6(%a5),%d1
	moveq #96,%d0
	moveq #64,%d7
	and.l %d1,%d0
	cmp.l %d0,%d7
	jne .L697
	tst.l %d2
	jeq .L540
	mov3q.l #1,%a1
	mov3q.l #2,%d0
.L645:
	cmp.l %d2,%d0
	jne .L540
	mvz.b %d1,%d0
	moveq #111,%d3
	cmp.l %d0,%d3
	jcs .L540
	moveq #-128,%d0
	or.l %d1,%d0
	move.b %d0,-32(%fp)
	move.b 7(%a5),-31(%fp)
	tst.l %a1
	jne .L698
	move.b 8(%a5),%d0
.L648:
	move.b %d0,-30(%fp)
	moveq #112,%d4
	moveq #16,%d5
	and.l %d4,%d1
	move.l 1094559344,%a0
	move.l 1094559356,%d3
	move.w -66825036,%d0
	mvz.w %d0,%d0
	sub.l %d3,%d0
	mvz.w -66825028,%d3
	add.l %a0,%d0
	move.l 1094559352,%a0
	add.l %d2,%a0
	sub.l %d3,%d0
	and.l #4095,%d0
	mvz.w #4096,%d3
	sub.l %d0,%d3
	cmp.l %d1,%d5
	jne .L649
	tst.l %a1
	jne .L701
	tst.b 8(%a5)
	jeq .L701
	mvz.w #512,%d0
.L650:
	add.l %a0,%d0
	cmp.l %d0,%d3
	jge .L651
	addq.l #1,din_drop
	jra .L552
.L697:
	sub.l %a1,%a1
	mov3q.l #3,%d0
	jra .L645
.L698:
	clr.b %d0
	jra .L648
.L649:
	lsr.l #5,%d1
	jeq .L701
	mvz.w #1536,%d0
	jra .L650
.L701:
	moveq #8,%d0
	jra .L650
.L651:
	mov3q.l #3,-(%sp)
	pea -32(%fp)
	move.l %d2,-(%sp)
	jsr 1074288478
	lea (12,%sp),%sp
	addq.l #1,din_sent
	jra .L552
.L548:
	subq.l #3,%d2
	tst.l %d2
	jne .L540
	mvz.b 6(%a5),%d0
	moveq #11,%d1
	cmp.l %d0,%d1
	jcs .L540
	tst.b 7(%a5)
	jlt .L540
	mvz.b 8(%a5),%d1
	lsr.l #3,%d1
	jne .L540
	moveq #127,%d1
	and.l -2147457096,%d1
	lea ar,%a0
	move.b %d1,48(%a0,%d0.l)
	mvz.b 8(%a5),%d1
	mvz.b 7(%a5),%d0
	mvz.b 6(%a5),%d2
	lsl.l #7,%d1
	or.l %d1,%d0
	or.l #-32768,%d0
	move.w %d0,24(%a0,%d2.l*2)
	jra .L552
.L545:
	move.l ux+3880,%d3
	add.l #-10,%d0
	mov3q.l #2,%d4
	cmp.l %d0,%d4
	jcs .L540
	move.b 6(%a5),%d1
	moveq #11,%d5
	mvz.b %d1,%d0
	cmp.l %d0,%d5
	jcs .L540
	mvz.b 7(%a5),%d0
	lsr.l #4,%d0
	jne .L540
	tst.b 8(%a5)
	jlt .L540
	mov3q.l #3,%d7
	cmp.l %d2,%d7
	jge .L656
	tst.b 9(%a5)
	jlt .L540
	mov3q.l #5,%d0
	cmp.l %d2,%d0
	jne .L656
	tst.b 10(%a5)
	jlt .L540
.L656:
	move.l %d3,%d0
	sub.l ux+3884,%d0
	lea ux,%a0
	lsr.l #3,%d0
	jeq .L657
	addq.l #1,ux+28
	jra .L552
.L657:
	mov3q.l #7,%d0
	and.l %d3,%d0
	mov3q.l #3,%d5
	move.l %d0,%a1
	lea (972,%a1),%a1
	move.b %d1,(%a0,%a1.l*4)
	lea (%a0,%d0.l*4),%a1
	move.b 7(%a5),3889(%a1)
	move.b 8(%a5),3890(%a1)
	cmp.l %d2,%d5
	jlt .L658
	clr.b %d6
	move.b %d6,3891(%a1)
.L659:
	clr.b %d1
.L661:
	add.l %d0,%a0
	addq.l #1,%d3
	move.b %d1,3952(%a0)
	move.l %d3,ux+3880
	addq.l #1,ux+16
	jra .L552
.L658:
	move.b 9(%a5),3891(%a1)
	subq.l #5,%d2
	tst.l %d2
	jne .L659
	move.b 10(%a5),%d1
	jra .L661
.L559:
	subq.l #4,%d2
	tst.l %d2
	jne .L540
	move.l %a5,%d1
	add.l #10,%d1
	lea (6,%a5),%a0
.L664:
	mvz.b (%a0),%d0
	moveq #111,%d2
	cmp.l %d0,%d2
	jcc .L663
	moveq #127,%d3
	cmp.l %d0,%d3
	jne .L540
.L663:
	addq.l #1,%a0
	cmp.l %d1,%a0
	jne .L664
	addq.l #1,pg_gen
	clr.l %d0
	lea pg_req,%a0
.L665:
	lea 6(%a5,%d0.l),%a1
	mov3q.l #4,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L665
	addq.l #1,pg_gen
	jra .L552
.L557:
	tst.l %d2
	jeq .L540
	move.b 6(%a5),%d0
	moveq #127,%d2
	and.l %d2,%d0
	bset #8,%d0
	move.l %d0,splash_req
	jra .L552
.L556:
	add.l #-10,%d0
	moveq #37,%d3
	cmp.l %d0,%d3
	jcs .L540
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
	move.b 8(%a5),%d1
	move.b 7(%a5),%d2
	and.l %d4,%d1
	and.l %d4,%d2
	lsl.l %d5,%d1
	lsl.l #7,%d2
	or.l %d2,%d1
	move.b 6(%a5),%d2
	and.l %d4,%d2
	or.l %d2,%d1
	clr.l %d2
.L668:
	cmp.l %d2,%d0
	jgt .L671
	mvz.w %d1,%d1
	lea (-32,%fp),%a0
	clr.l %d0
	lea mask_keys,%a1
	move.l %d1,mask_enc
.L672:
	move.l (%a0)+,(%a1,%d0.l*4)
	moveq #8,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L672
	mov3q.l #1,mask_set
	addq.l #1,masks
	jra .L552
.L671:
	move.w %d2,%d3
	mvz.b 9(%a5,%d2.l),%d6
	clr.l %d4
	mulu.w #7,%d3
.L670:
	btst %d4,%d6
	jeq .L669
	cmp.l #255,%d3
	jgt .L669
	moveq #31,%d7
	and.l %d3,%d7
	move.l %d7,%d5
	mov3q.l #1,%d7
	lsl.l %d5,%d7
	move.l %d3,%d5
	asr.l #5,%d5
	or.l %d7,-32(%fp,%d5.l*4)
.L669:
	addq.l #1,%d4
	addq.l #1,%d3
	mov3q.l #7,%d7
	cmp.l %d4,%d7
	jne .L670
	addq.l #1,%d2
	jra .L668
.L551:
	mov3q.l #5,%d3
	cmp.l %d2,%d3
	jge .L673
	move.b 7(%a5),%d1
	moveq #63,%d4
	mvz.b %d1,%d2
	cmp.l %d2,%d4
	jcs .L673
	move.b 8(%a5),%d4
	jmi .L673
	mvz.b 9(%a5),%d3
	lsr.l #6,%d3
	jne .L673
	mvz.b 10(%a5),%d3
	moveq #16,%d6
	cmp.l %d3,%d6
	jcs .L673
	add.l #-13,%d0
	moveq #32,%d7
	cmp.l %d0,%d7
	jge .L702
.L673:
	clr.b %d0
	addq.l #1,rx_bad
	move.b %d0,st_valid
	jra .L539
.L676:
	move.b 12(%a5,%a0.l),%d3
	moveq #94,%d5
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcc .L675
	clr.b %d6
	addq.l #1,rx_bad
	move.b %d6,st_valid
	jra .L539
.L675:
	addq.l #1,%a0
.L674:
	cmp.l %d0,%a0
	jlt .L676
	moveq #44,%d7
	ext.w %d1
	muls.l %d7,%d2
	lea txt_st,%a1
	mulu.w #44,%d1
	move.b %d4,(%a1,%d2.l)
	lea (%a1,%d2.l),%a0
	move.b 9(%a5),1(%a0)
	move.b 10(%a5),2(%a0)
	move.b 11(%a5),3(%a0)
	move.b %d0,4(%a0)
	lea (%a1,%d1.l),%a0
	clr.l %d1
.L677:
	cmp.l %d0,%d1
	jlt .L678
	clr.b %d1
	add.l %d2,%a1
	moveq #1,%d2
	addq.l #6,%a5
	move.b %d1,8(%a1,%d0.l)
	move.b %d2,st_valid
	move.b (%a5),st_seq
	jra .L552
.L702:
	sub.l %a0,%a0
	jra .L674
.L678:
	lea 12(%a5,%d1.l),%a2
	move.b (%a2),8(%a0,%d1.l)
	addq.l #1,%d1
	jra .L677
.L550:
	tst.l %d2
	jeq .L540
	lea txt_st+4,%a0
	moveq #64,%d0
.L680:
	clr.b (%a0)
	subq.l #1,%d0
	lea (44,%a0),%a0
	tst.l %d0
	jne .L680
	jra .L777
.L549:
	mov3q.l #5,%d4
	cmp.l %d2,%d4
	jge .L540
	move.b 6(%a5),%d1
	moveq #15,%d5
	mvz.b %d1,%d2
	cmp.l %d2,%d5
	jcs .L540
	add.l #-13,%d0
	moveq #11,%d6
	cmp.l %d0,%d6
	jlt .L540
	lea bind_gen,%a1
	addq.l #1,(%a1,%d2.l*4)
	move.b 7(%a5),%d4
	mvz.b %d4,%d5
	lsr.l #6,%d5
	jeq .L683
	st %d4
.L683:
	moveq #20,%d5
	ext.w %d1
	muls.l %d5,%d2
	lea bind_in,%a0
	mulu.w #20,%d1
	move.b %d4,(%a0,%d2.l)
	add.l %d2,%a0
	move.b 8(%a5),1(%a0)
	move.b 9(%a5),2(%a0)
	move.b 10(%a5),3(%a0)
	move.b 11(%a5),4(%a0)
	move.b %d0,5(%a0)
	move.l %d1,%a0
	clr.l %d1
	add.l #bind_in,%a0
.L684:
	cmp.l %d0,%d1
	jlt .L686
	mvz.b 6(%a5),%d0
	addq.l #1,(%a1,%d0.l*4)
	jra .L552
.L686:
	move.b 12(%a5,%d1.l),%d2
	moveq #94,%d6
	move.l %d2,%d4
	add.l #-32,%d4
	mvz.b %d4,%d4
	cmp.l %d4,%d6
	jcc .L685
	move.b %d3,%d2
.L685:
	move.b %d2,6(%a0,%d1.l)
	addq.l #1,%d1
	jra .L684
.L635:
	tst.l %d0
	jne .L634
	jra .L638
	.size	rui_sysex, .-rui_sysex
	.align	2
	.type	ov_suffix, @function
ov_suffix:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	clr.l %d0
.L780:
	move.l 20(%sp),%a0
	tst.b (%a0,%d0.l)
	jne .L781
	cmp.l %d1,%d0
	jle .L786
.L784:
	clr.l %d0
.L779:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L781:
	addq.l #1,%d0
	jra .L780
.L785:
	move.l 20(%sp),%a2
	mvs.b (%a0,%a1.l),%d2
	mvs.b (%a2,%a1.l),%d1
	cmp.l %d2,%d1
	jne .L784
	addq.l #1,%a1
.L782:
	cmp.l %a1,%d0
	jne .L785
	mov3q.l #1,%d0
	jra .L779
.L786:
	add.l 12(%sp),%d1
	sub.l %a1,%a1
	move.l %d1,%a0
	sub.l %d0,%a0
	jra .L782
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
	jne .L788
.L800:
	move.l ov_is,%d0
	jra .L787
.L788:
	move.l %d0,%d1
	add.l #-1073742852,%d1
	move.l %d0,ov_vt
	clr.l ov_is
	clr.l ov_list
	addq.l #1,ov_n
	cmp.l #2997243,%d1
	jls .L790
.L791:
	clr.l %d0
.L787:
	movem.l (%sp),#7180
	lea (20,%sp),%sp
	rts
.L790:
	mov3q.l #3,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L791
	move.l %d0,%a0
	move.l -4(%a0),%d0
	move.l %d0,%d1
	add.l #-1073742848,%d1
	cmp.l #2997247,%d1
	jhi .L791
	btst #0,%d0
	jne .L791
	move.l %d0,%a0
	move.l 4(%a0),%a2
	move.l %a2,%d0
	add.l #-1073742848,%d0
	cmp.l #2997247,%d0
	jhi .L791
.L792:
	move.b (%a2),%d0
	moveq #9,%d1
	add.l #-48,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jcc .L793
	clr.l %d2
.L794:
	tst.b (%a2,%d2.l)
	jne .L795
	pea .LC5
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	lea ov_suffix,%a3
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L797
	pea .LC0
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L797
	pea .LC1
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
.L797:
	pea .LC2
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	move.l %d0,ov_list
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L798
	moveq #17,%d1
	cmp.l %d2,%d1
	jne .L799
	pea .LC3
	pea 17.w
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	mov3q.l #1,%d1
	eor.l %d1,%d0
.L799:
	move.l %d0,ov_is
	jra .L800
.L793:
	addq.l #1,%a2
	jra .L792
.L795:
	addq.l #1,%d2
	moveq #48,%d0
	cmp.l %d2,%d0
	jne .L794
	jra .L791
.L798:
	pea .LC4
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L801
	mov3q.l #1,ov_is
	jra .L800
.L801:
	lea ov_names,%a4
	clr.l %d3
.L805:
	move.l (%a4)+,%a0
	clr.l %d0
.L802:
	tst.b (%a0,%d0.l)
	jne .L803
	cmp.l %d0,%d2
	jne .L804
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L804
	mov3q.l #1,ov_is
.L804:
	addq.l #1,%d3
	moveq #14,%d0
	cmp.l %d3,%d0
	jne .L805
	jra .L800
.L803:
	addq.l #1,%d0
	jra .L802
	.size	overlay, .-overlay
	.align	2
	.type	sv_tick, @function
sv_tick:
	lea (-52,%sp),%sp
	clr.l %d0
	movem.l #31996,(%sp)
	move.l 56(%sp),%a4
	clr.l %d7
	clr.l sv+80
	clr.l sv+128
	move.l 28(%a4),%a2
	sub.l %a5,%a5
	lea (20,%a4),%a0
	sub.l %a6,%a6
	mov3q.l #1,sv+144
	clr.l %d6
	clr.l %d1
	clr.l %d2
	move.b 1093765506,%d4
	move.l %a0,48(%sp)
	mvz.b %d4,%d5
.L817:
	tst.l %a2
	jeq .L830
	cmp.l 48(%sp),%a2
	jeq .L830
	move.l 8(%a2),%a3
	tst.l %a3
	jne .L818
.L839:
	clr.l %d2
.L819:
	move.l sv+128,%a3
	lea sv,%a2
	tst.l %a3
	jeq .L843
	addq.l #1,sv+136
	tst.l sv+144
	jne .L844
	tst.l 140(%a3)
	jeq .L844
	moveq #11,%d0
	cmp.l %d5,%d0
	jlt .L844
	move.b %d4,%d1
	moveq #127,%d0
	and.l -2147457096,%d0
	ext.w %d1
	mulu.w #2531,%d0
	mulu.w #152,%d1
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d0
	move.l %d0,-(%sp)
	move.l %d5,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	moveq #127,%d1
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jeq .L844
	moveq #1,%d3
	move.l (%a3),%a0
	clr.l -(%sp)
	move.l %a3,-(%sp)
	move.l 96(%a0),%a0
	jsr (%a0)
	addq.l #1,sv+140
	addq.l #8,%sp
	move.b %d3,32(%a4)
.L844:
	lea (140,%a3),%a3
	move.l (%a3),sv+132
.L843:
	move.b (%a2),%d3
	moveq #11,%d0
	cmp.l %d5,%d0
	jlt .L869
	tst.l %d2
	jeq .L845
	move.b %d4,%d1
	moveq #127,%d0
	and.l -2147457096,%d0
	ext.w %d1
	mulu.w #2531,%d0
	mulu.w #152,%d1
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	move.b (%a0),%d6
	mvz.b %d6,%d7
	move.l %d7,-(%sp)
	move.l %d5,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	moveq #127,%d1
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jeq .L845
	tst.b %d3
	jeq .L847
	mvz.b sv+1,%d0
	cmp.l %d5,%d0
	jne .L847
	mvz.b sv+2,%d0
	cmp.l %d0,%d7
	jeq .L848
.L847:
	moveq #1,%d3
	move.w #257,%d0
	move.b %d4,sv+1
	move.b %d6,sv+2
	move.b %d4,sv+5
	lea commits,%a0
	move.l (%a0),sv+12
	addq.l #1,sv+56
	move.b %d3,sv
	move.b %d3,sv+4
	move.w %d0,sv+6
.L848:
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	seq %d4
	move.b (%a2),%d5
	neg.l %d4
	move.b %d4,sv+3
	tst.b %d5
	jeq .L851
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jeq .L852
.L851:
	mov3q.l #-1,%d0
.L853:
	move.l 60(%sp),%d3
	move.l %d0,sv+116
	cmp.l sv+20.l,%d3
	jeq .L859
	clr.l sv+16
	sub.l %a0,%a0
.L860:
	move.l 60(%sp),%d1
	move.l st+4,%a1
	move.l %d1,sv+20
	move.l sv+12,%d1
	move.l st+972,%d7
	tst.b %d5
	jeq .L861
	mov3q.l #2,%d3
	cmp.l %d2,%d3
	jne .L862
.L861:
	clr.l %d3
.L863:
	cmp.l commits.l,%d1
	sne %d0
	tst.l %a1
	sne %d1
	tst.l %d7
	sne %d7
	add.l %d4,%d4
	move.b %d3,%d6
	move.b %d3,sv+8
	neg.l %d0
	neg.l %d1
	lsl.l #4,%d1
	lsl.l #2,%d0
	neg.l %d7
	lsl.l #5,%d7
	or.l %d1,%d0
	or.l %d5,%d0
	or.l %d7,%d0
	or.l %d4,%d0
	moveq #19,%d4
	cmp.l %a0,%d4
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
	jne .L864
	move.l sv+104,%a0
	cmp.l sv+88.l,%a0
	jne .L864
	tst.l %d2
	jeq .L865
	move.l st+8,%d1
	moveq #19,%d4
	sub.l sv+108,%d1
	cmp.l %d1,%d4
	jge .L865
.L864:
	moveq #1,%d1
	move.b %d1,sv+102
.L865:
	move.b %d0,sv+100
	mvz.b %d6,%d0
	mvz.b sv+9,%d1
	cmp.l %d0,%d1
	jeq .L816
	tst.l %d3
	jeq .L867
	addq.l #1,sv+72
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
.L868:
	moveq #1,%d4
	move.b %d6,sv+9
	move.b %d4,32(%a4)
.L816:
	movem.l (%sp),#31996
	lea (52,%sp),%sp
	rts
.L818:
	move.l (%a3),%d3
	tst.l %d2
	jeq .L820
	cmp.l #1075718412,%d3
	jeq .L821
	cmp.l #1075712228,%d3
	jeq .L821
	cmp.l #1075719596,%d3
	jeq .L821
	cmp.l #1075717140,%d3
	jne .L820
.L821:
	move.l (%a2),%a2
.L822:
	addq.l #1,%d6
	moveq #16,%d3
	cmp.l %d6,%d3
	jne .L817
.L830:
	cmp.l sv+84.l,%d0
	jne .L834
	cmp.l sv+88.l,%a6
	jeq .L835
.L834:
	move.l %d0,sv+84
	move.l %a6,sv+88
	clr.l sv+96
.L836:
	move.l %d6,sv+92
	tst.l %d1
	jeq .L837
	moveq #16,%d0
	cmp.l %d6,%d0
	jeq .L837
	tst.l %a2
	jne .L838
.L837:
	clr.l sv+80
	jra .L839
.L820:
	move.l %d3,%a6
	cmp.l #1075721468,%d3
	jne .L823
	move.l %a3,sv+80
	mov3q.l #1,%d1
.L824:
	tst.l %d2
	jeq .L826
	lea sv_covers,%a0
	sub.l %a1,%a1
.L827:
	cmp.l (%a0),%d3
	jne .L829
.L872:
	move.l %d2,%d7
.L826:
	cmp.l #1076055292,%d3
	seq %d3
	move.l (%a2),%a2
	move.l %a3,%d0
	mvs.b %d3,%d3
	neg.l %d3
	or.l %d3,%d2
	jra .L822
.L823:
	cmp.l #1075720560,%d3
	jne .L825
	mov3q.l #2,%d0
	or.l %d0,%d1
	move.l %a3,sv+128
	jra .L824
.L825:
	cmp.l #1075628548,%d3
	jne .L824
	tst.b 127(%a3)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d7
	jra .L824
.L829:
	addq.l #4,%a0
	addq.l #1,%a1
	moveq #8,%d0
	cmp.l %a1,%d0
	jne .L827
	move.l %d3,-(%sp)
	move.l %d1,48(%sp)
	jsr overlay
	addq.l #4,%sp
	move.l 44(%sp),%d1
	tst.l %d0
	jne .L872
	move.l %d2,%a5
	jra .L826
.L835:
	move.l sv+96,%d0
	cmp.l #65534,%d0
	jhi .L836
	addq.l #1,%d0
	move.l %d0,sv+96
	jra .L836
.L838:
	mov3q.l #1,%d3
	eor.l %d3,%d2
	or.l %d7,%d2
	tst.l %a5
	jeq .L841
	cmp.l #1076055292,%a6
	jeq .L841
	moveq #59,%d3
	cmp.l sv+96.l,%d3
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d2
.L841:
	move.l %d2,sv+144
	btst #0,%d1
	jeq .L837
	addq.l #1,%d2
	jra .L819
.L869:
	clr.l %d2
.L845:
	tst.b %d3
	jeq .L848
	clr.b %d1
	moveq #1,%d3
	lea sv+1,%a0
	move.b (%a0),sv+5
	addq.l #1,sv+60
	move.b %d1,sv
	move.b %d3,sv+4
	move.b %d1,sv+6
	jra .L848
.L852:
	move.l 1100949720,%a2
	move.l %a2,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L851
	jsr sq_grid
	tst.l %d0
	jeq .L851
	move.l 348(%a2),%d1
	tst.l %d1
	jeq .L934
	clr.l %d0
	jra .L854
.L856:
	addq.l #1,%d0
.L854:
	btst %d0,%d1
	jeq .L856
	jra .L853
.L934:
	move.l 344(%a2),%d1
	clr.l %d0
	tst.l %d1
	jeq .L851
.L857:
	btst %d0,%d1
	jeq .L858
	add.l #32,%d0
	jra .L853
.L858:
	addq.l #1,%d0
	jra .L857
.L859:
	move.l sv+16,%a0
	cmp.l #65534,%a0
	jhi .L860
	addq.l #1,%a0
	move.l %a0,sv+16
	jra .L860
.L862:
	cmp.l commits.l,%d1
	jeq .L861
	moveq #19,%d0
	cmp.l %a0,%d0
	jcs .L861
	move.l %a1,%d3
	or.l %d7,%d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
	jra .L863
.L867:
	subq.l #2,%d2
	tst.l %d2
	jne .L868
	addq.l #1,sv+76
	jra .L868
	.size	sv_tick, .-sv_tick
	.align	2
	.type	enter, @function
enter:
	move.l %d2,-(%sp)
	move.b 15(%sp),%d1
	tst.l st+4
	jne .L935
	tst.l st+972
	jeq .L937
	clr.l st+972
	mov3q.l #6,st+988
.L937:
	lea commits,%a0
	moveq #16,%d0
	move.l (%a0),st+24
	mov3q.l #1,st+4
	clr.l st+12
	mov3q.l #-1,st+20
	lea st+96,%a0
	addq.l #1,st+48
.L938:
	clr.l (%a0)+
	subq.l #1,%d0
	tst.l %d0
	jne .L938
	lea st+408,%a0
.L939:
	clr.l (%a0)+
	moveq #16,%d2
	addq.l #1,%d0
	cmp.l %d0,%d2
	jne .L939
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
.L935:
	move.l (%sp)+,%d2
	rts
	.size	enter, .-enter
	.align	2
	.type	leave, @function
leave:
	move.l %d2,-(%sp)
	move.b 15(%sp),%d1
	tst.l st+4
	jeq .L942
	clr.l st+4
	clr.l st+1038
	addq.l #1,st+52
	clr.l st+1058
	clr.l st+196
	tst.l nk
	jeq .L944
	moveq #-33,%d0
	moveq #32,%d2
	and.l %d0,st+240
	or.l %d2,st+272
	clr.l nk
.L944:
	clr.l %d0
	lea kq_nodown,%a1
	lea kq_owed,%a0
.L945:
	clr.l (%a1,%d0.l)
	moveq #32,%d2
	clr.l (%a0,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d2
	jne .L945
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
	jne .L946
	clr.l st+1006
	jsr led_restore
.L946:
	moveq #1,%d0
	move.l 8(%sp),%a0
	move.b %d0,32(%a0)
.L942:
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
	jeq .L949
	move.l st+8,%d0
	mov3q.l #1,txsx_test_on
	add.l txsx_test,%d0
	clr.l txsx_test
	move.l %d0,txsx_test_end
.L949:
	tst.l kq_owes
	jeq .L950
	jsr (kq_owed_in.part.0)
.L950:
	moveq #31,%d1
	mov3q.l #1,%d0
	and.l %d3,%d1
	move.l %d3,%d2
	lsr.l #5,%d2
	lea kq_nodown,%a0
	move.l (%a0,%d2.l*4),%d4
	lsl.l %d1,%d0
	tst.l 28(%sp)
	jeq .L951
	move.l %d0,%d1
	not.l %d1
	and.l %d4,%d1
	move.l %d1,(%a0,%d2.l*4)
	tst.l kq_owes
	jne .L952
	move.l st+196,%d1
	moveq #15,%d5
	move.l %d1,%a1
	addq.l #6,%a1
	cmp.l %a1,%d5
	jcc .L953
.L952:
	or.l %d0,%d4
	addq.l #1,st+44
	move.l %d4,(%a0,%d2.l*4)
.L948:
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L951:
	move.l %d4,%d1
	and.l %d0,%d1
	tst.l %d1
	jeq .L955
	not.l %d0
	and.l %d4,%d0
	move.l %d0,(%a0,%d2.l*4)
	jra .L948
.L955:
	move.l st+196,%d1
	moveq #15,%d4
	cmp.l %d1,%d4
	jcc .L953
	move.l %d1,%a1
	subq.l #1,%a1
	lea st+164,%a0
.L956:
	tst.l %a1
	jlt .L957
	mvz.b (%a0,%a1.l*2),%d4
	cmp.l %d4,%d3
	jne .L958
	move.l %a1,%d3
	add.l %d3,%d3
	move.l %d3,%d4
	add.l #st,%d4
	move.l %d4,%a2
	tst.b 165(%a2)
	jeq .L957
	add.l %d3,%a0
.L959:
	addq.l #1,%a1
	cmp.l %d1,%a1
	jlt .L960
	subq.l #1,%d1
	move.l %d1,st+196
	addq.l #1,st+44
	jra .L948
.L958:
	subq.l #1,%a1
	jra .L956
.L960:
	addq.l #2,%a0
	move.b (%a0),-2(%a0)
	move.b 1(%a0),-1(%a0)
	jra .L959
.L957:
	lea kq_owed,%a0
	move.l (%a0,%d2.l*4),%d1
	move.l %d1,%d3
	and.l %d0,%d3
	tst.l %d3
	jne .L948
	or.l %d0,%d1
	addq.l #1,kq_owes
	move.l %d1,(%a0,%d2.l*4)
	jra .L948
.L953:
	lea st,%a0
	move.l %d1,%d0
	add.l #82,%d0
	move.b %d3,(%a0,%d0.l*2)
	lea (%a0,%d1.l*2),%a0
	addq.l #1,%d1
	move.l %d1,st+196
	move.b 31(%sp),165(%a0)
	jra .L948
	.size	queue_key, .-queue_key
	.align	2
	.type	pmo_mix, @function
pmo_mix:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 12(%sp),%a0
	move.l 16(%sp),%d0
	move.l 24(%a0),%d1
	move.l %d0,36(%a0)
	tst.l 20(%sp)
	jne .L965
	move.l %d0,28(%a0)
	clr.b %d0
	move.l %d1,16(%a0)
.L966:
	move.b %d0,3(%a0)
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L965:
	moveq #127,%d3
	and.l 20(%sp),%d3
	sub.l 28(%a0),%d0
	lea pmo_rcp,%a1
	sub.l 16(%a0),%d1
	mvz.w (%a1,%d3.l*2),%d2
	moveq #9,%d3
	asr.l %d3,%d0
	asr.l %d3,%d1
	muls.l %d2,%d0
	muls.l %d2,%d1
	asr.l #6,%d0
	asr.l #6,%d1
	move.l %d0,32(%a0)
	move.b 23(%sp),%d0
	move.l %d1,20(%a0)
	jra .L966
	.size	pmo_mix, .-pmo_mix
	.align	2
	.type	pmo_fade, @function
pmo_fade:
	lea (-16,%sp),%sp
	movem.l #3084,(%sp)
	move.l 24(%sp),%d2
	clr.l %d3
	lea pmo+3464,%a2
	lea pmo_mix,%a3
.L968:
	cmp.l pmo+104.l,%d3
	jcs .L972
	movem.l (%sp),#3084
	lea (16,%sp),%sp
	rts
.L972:
	move.b (%a2),%d0
	jeq .L969
	mvz.b %d0,%d0
	move.l 20(%sp),%d1
	subq.l #1,%d0
	btst %d0,%d1
	jeq .L969
	clr.l 12(%a2)
	tst.l %d2
	jne .L970
	clr.b %d0
	clr.l 4(%a2)
.L971:
	move.b %d0,2(%a2)
	move.l %d2,-(%sp)
	clr.l -(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
.L969:
	addq.l #1,%d3
	lea (44,%a2),%a2
	jra .L968
.L970:
	moveq #9,%d1
	move.l 4(%a2),%d0
	neg.l %d0
	asr.l %d1,%d0
	moveq #127,%d1
	and.l %d2,%d1
	lea pmo_rcp,%a0
	mvz.w (%a0,%d1.l*2),%d1
	muls.l %d1,%d0
	asr.l #6,%d0
	move.l %d0,8(%a2)
	move.b %d2,%d0
	jra .L971
	.size	pmo_fade, .-pmo_fade
	.align	2
	.globl	cu_setup
	.type	cu_setup, @function
cu_setup:
	lea (-28,%sp),%sp
	movem.l #15388,(%sp)
	move.l 32(%sp),%d2
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	move.l %d0,%a2
	tst.l %d0
	jeq .L979
	move.l %d2,-(%sp)
	jsr cu_src_setup
	mvz.b cu+1,%d0
	move.l %d2,%d4
	addq.l #4,%sp
	add.l #-43,%d4
	cmp.l %d0,%d2
	jne .L981
	move.l 1075597888,%d0
	cmp.l 4(%a2),%d0
	jne .L981
	move.l 1075596172,%d0
	cmp.l 116(%a2),%d0
	jne .L981
	move.l 1075597884,%d1
	moveq #9,%d0
	cmp.l %d4,%d0
	jcs .L985
	lea CSWTCH.541,%a0
	move.l (%a0,%d4.l*4),%d0
.L982:
	cmp.l %d0,%d1
	jeq .L979
.L981:
	lea cu_p2,%a3
	clr.l %d3
	lea CSWTCH.541,%a5
	lea cu_knob,%a4
.L984:
	moveq #9,%d0
	cmp.l %d4,%d0
	jcs .L986
	move.l (%a5,%d4.l*4),%d0
.L983:
	move.l %d0,-(%sp)
	mvz.w %d3,%d0
	addq.l #1,%d3
	lsl.l #4,%d0
	pea (%a2,%d0.l)
	mvs.w (%a3)+,%d0
	move.l %d0,-(%sp)
	jsr (%a4)
	lea (12,%sp),%sp
	moveq #8,%d0
	cmp.l %d3,%d0
	jne .L984
	move.w cu+2,%d0
	move.b %d2,cu+1
	addq.l #1,%d0
	move.w %d0,cu+2
.L979:
	movem.l (%sp),#15388
	lea (28,%sp),%sp
	rts
.L985:
	move.l #cu_fm_short,%d0
	jra .L982
.L986:
	move.l #cu_fm_short,%d0
	jra .L983
	.size	cu_setup, .-cu_setup
	.align	2
	.type	isr_send, @function
isr_send:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jeq .L992
.L1000:
	clr.l %d0
.L991:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L992:
#APP
| 1773 "rui.c" 1
	move.w %sr,%d0
| 0 "" 2
#NO_APP
	move.l %d0,%d3
	move.l %d0,%d2
	and.l #1792,%d3
	mvz.w %d2,%d2
	cmp.l #1279,%d3
	jhi .L994
	and.l #63743,%d0
	or.l #1280,%d0
#APP
| 1777 "rui.c" 1
	move.w %d0,%sr
| 0 "" 2
#NO_APP
.L994:
	tst.l 1123449384
	jeq .L995
.L997:
#APP
| 1782 "rui.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	addq.l #1,sq+388
	jra .L1000
.L995:
	tst.l 1094562372
	jne .L997
	move.l %d1,%d0
	add.l 1094562392,%d0
	cmp.l #3800,%d0
	jgt .L997
	move.l 1094562704,%a0
	tst.l %a0
	jeq .L997
	move.l 52(%a0),%a0
	tst.l %a0
	jeq .L997
	move.l 52(%a0),%d0
	move.l 12(%sp),-(%sp)
	move.l %d1,-(%sp)
	jsr 1073752544
#APP
| 1782 "rui.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	mov3q.l #1,%d0
	addq.l #8,%sp
	jra .L991
	.size	isr_send, .-isr_send
	.align	2
	.globl	rui_render_in
	.type	rui_render_in, @function
rui_render_in:
	link.w %fp,#-112
	movem.l #1084,(%sp)
	tst.l 1094562372
	jne .L1008
	mov3q.l #1,txsx_gap
.L1008:
	lea fp,%a0
	addq.l #1,(%a0)
	tst.l fp+8
	jeq .L1009
	move.l (%a0),%d0
	sub.l fp+4,%d0
	cmp.l #3000,%d0
	jls .L1009
	move.l fp+8,%a0
	move.l fp,%d0
	move.l fp+4,%d1
	move.l 1123449124,%d2
	tst.l fp+12
	jeq .L1010
	move.l fp,%a1
	sub.l fp+12,%a1
	cmp.l #7499,%a1
	jls .L1009
.L1010:
	cmp.l %a0,%d2
	seq %d3
	sub.l %d1,%d0
	lea (-90,%fp),%a1
	clr.l %d1
	move.l %a1,%d4
	neg.l %d3
.L1011:
	move.l %d4,%a2
	addq.l #1,%d1
	clr.l (%a2)+
	moveq #9,%d5
	move.l %a2,%d4
	cmp.l %d1,%d5
	jne .L1011
	cmp.l %a0,%d2
	jeq .L1012
	mov3q.l #1,%d1
	move.l 72(%a0),%d2
	and.l %d2,%d1
	btst #0,%d2
	jne .L1012
	move.l %d2,%a0
	add.l #-1073741824,%a0
	cmp.l #129892303,%a0
	jhi .L1012
.L1013:
	move.l %d2,%a0
	moveq #36,%d4
	lea 4(%a0,%d1.l),%a2
	move.l (%a2),(%a1,%d1.l)
	addq.l #4,%d1
	cmp.l %d1,%d4
	jne .L1013
.L1012:
	move.w #19969,%a0
	move.l #-260222380,%d5
	move.b %d3,-48(%fp)
	move.l %d5,-54(%fp)
	move.w %a0,-50(%fp)
	cmp.l #191999,%d0
	jhi .L1025
	mvz.w #1500,%d2
	divu.l %d2,%d0
.L1014:
	move.b %d0,-47(%fp)
	lea (-46,%fp),%a0
	clr.l %d1
.L1015:
	moveq #28,%d3
	moveq #21,%d4
	move.l (%a1)+,%d0
	move.l %d0,%d2
	lsr.l %d3,%d2
	moveq #127,%d5
	moveq #14,%d3
	addq.l #1,%d1
	addq.l #5,%a0
	move.b %d2,-5(%a0)
	move.l %d0,%d2
	lsr.l %d4,%d2
	moveq #9,%d4
	and.l %d5,%d2
	move.b %d2,-4(%a0)
	move.l %d0,%d2
	lsr.l %d3,%d2
	and.l %d5,%d2
	move.b %d2,-3(%a0)
	move.l %d0,%d2
	lsr.l #7,%d2
	and.l %d5,%d0
	and.l %d5,%d2
	move.b %d0,-1(%a0)
	move.b %d2,-2(%a0)
	cmp.l %d1,%d4
	jne .L1015
	moveq #-9,%d5
	pea 54.w
	pea -54(%fp)
	move.b %d5,-1(%fp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1009
	lea fp,%a0
	tst.l (%a0)
	jeq .L1026
	move.l (%a0),%d0
.L1017:
	move.l %d0,fp+12
	addq.l #1,fp+16
.L1009:
	move.l 1123623180,%d0
	move.l qp,%d4
	move.l qp+8,%d3
	tst.l qp+12
	jne .L1018
	tst.l %d0
	sne %d1
	mov3q.l #1,qp+12
	move.l #1123623184,%a1
	move.l %d0,qp+16
	move.l (%a1),qp+20
	mov3q.l #-1,qp+28
	mvs.b %d1,%d1
	neg.l %d1
	move.l %d1,qp+24
.L1018:
	tst.l qp+24
	jne .L1019
	cmp.l qp+16.l,%d0
	jne .L1020
	move.l qp+20,%a2
	cmp.l 1123623184.l,%a2
	jeq .L1019
.L1020:
	mov3q.l #1,qp+24
.L1019:
	tst.l qp+4
	jeq .L1007
	move.l %d0,%d1
	mov3q.l #1,%d5
	mvz.b %d1,%d1
	and.l #4095,%d4
	move.l %d1,%d2
	move.l %d1,%a0
	swap %d2
	clr.w %d2
	move.l %d4,%d1
	lsl.l #4,%d1
	or.l %d1,%d2
	tst.l qp+24
	sne %d1
	mvs.b %d1,%d1
	neg.l %d1
	add.l %d1,%d1
	or.l %d1,%d2
	mvz.b 1099764550,%d1
	lsr.l #5,%d1
	and.l %d5,%d1
	or.l %d1,%d2
	cmp.l qp+28.l,%d2
	jne .L1022
	cmp.l qp+36.l,%d3
	jeq .L1007
.L1022:
	move.l fp,%d1
	moveq #11,%d5
	sub.l qp+32,%d1
	cmp.l %d1,%d5
	jcc .L1007
	moveq #127,%d5
	and.l %d5,%d0
	moveq #14,%d1
	move.w #11521,%a2
	pea 13.w
	move.l #-260222380,%a1
	pea -54(%fp)
	move.l %a1,-54(%fp)
	move.b %d0,-46(%fp)
	moveq #127,%d0
	and.l %d4,%d0
	move.b %d1,-48(%fp)
	move.l %a0,%d1
	lsr.l #7,%d4
	lsr.l #7,%d1
	move.w %a2,-50(%fp)
	move.b %d4,-44(%fp)
	move.b %d1,-47(%fp)
	move.b %d0,-45(%fp)
	mov3q.l #3,%d0
	and.l %d2,%d0
	move.b %d0,-43(%fp)
	moveq #-9,%d0
	move.b %d0,-42(%fp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1007
	move.l qp+40,%d0
	tst.l %d0
	jeq .L1023
	move.l qp+84,%a0
	move.l qp+32,%d1
	tst.l %a0
	jeq .L1024
	move.l fp,%a1
	sub.l %d1,%a1
	cmp.l %a0,%a1
	jcc .L1023
.L1024:
	move.l fp,%d4
	sub.l %d1,%d4
	move.l %d4,qp+84
.L1023:
	lea fp,%a1
	addq.l #1,%d0
	move.l %d2,qp+28
	move.l %d3,qp+36
	move.l %d0,qp+40
	move.l (%a1),qp+32
.L1007:
	movem.l -112(%fp),#1084
	unlk %fp
	rts
.L1025:
	moveq #127,%d0
	jra .L1014
.L1026:
	mov3q.l #1,%d0
	jra .L1017
	.size	rui_render_in, .-rui_render_in
	.align	2
	.globl	smpl_hold
	.type	smpl_hold, @function
smpl_hold:
	move.l 4(%sp),%a0
	move.l #1075720560,%d0
	move.b 1093765506,%d1
	cmp.l (%a0),%d0
	jeq .L1052
.L1054:
	clr.l %d0
.L1053:
	rts
.L1052:
	mvz.b %d1,%d0
	move.l %d0,%a1
	moveq #11,%d0
	cmp.l %a1,%d0
	jlt .L1054
	moveq #127,%d0
	ext.w %d1
	and.l -2147457096,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d0
	move.l %d0,-(%sp)
	move.l %a1,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	moveq #127,%d1
	eor.l %d1,%d0
	tst.b %d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L1053
	.size	smpl_hold, .-smpl_hold
	.align	2
	.globl	rui_uart
	.type	rui_uart, @function
rui_uart:
	lea (-40,%sp),%sp
	movem.l #19468,(%sp)
	clr.l %d2
	tst.b ov_on.l
	jne .L1070
	tst.b ovp_on.l
	jne .L1070
	tst.b ovt_on.l
	jeq .L1057
.L1070:
	move.l 44(%sp),%a0
	subq.l #1,%a0
	sub.l %a6,%a6
	lea rui_uart_raw,%a3
	move.l %a0,20(%sp)
	jra .L1062
.L1058:
	move.l 48(%sp),%a0
	mvz.b (%a0,%d2.l),%d0
	addq.l #1,%d2
	move.l %d0,-(%sp)
	jsr uart_byte
	addq.l #4,%sp
.L1057:
	cmp.l 44(%sp),%d2
	jlt .L1058
	clr.l %d0
.L1055:
	movem.l (%sp),#19468
	lea (40,%sp),%sp
	rts
.L1063:
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
	jeq .L1060
	cmp.l 20(%sp),%a6
	jne .L1061
.L1060:
	pea 24(%sp)
	move.l %d3,-(%sp)
	jsr (%a3)
	addq.l #8,%sp
	clr.l %d3
.L1061:
	addq.l #1,%a6
	move.l %d3,%d2
.L1062:
	cmp.l 44(%sp),%a6
	jlt .L1063
	mov3q.l #1,%d0
	jra .L1055
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
	jcc .L1072
.L1076:
	clr.l %d0
.L1071:
	move.l (%sp)+,%d2
	rts
.L1072:
	tst.l sq
	jeq .L1074
	move.l sq+4,%a0
	move.l %a0,%d2
	btst %d1,%d2
	jeq .L1074
	addq.l #1,sq+448
	mov3q.l #1,%d0
	jra .L1071
.L1074:
	tst.l %d0
	jlt .L1077
	moveq #63,%d2
	cmp.l %d0,%d2
	jlt .L1078
.L1075:
	lea pc,%a0
	move.b %d0,48(%a0,%d1.l)
	moveq #1,%d0
	lea st+8,%a1
	move.l (%a1),(%a0,%d1.l*4)
	move.b %d0,60(%a0,%d1.l)
	jra .L1076
.L1077:
	clr.b %d0
	jra .L1075
.L1078:
	moveq #63,%d0
	jra .L1075
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
	jcs .L1085
	mov3q.l #1,%d1
	cmp.l 1079807120.l,%d1
	jeq .L1087
	clr.l sq+540
	clr.l sq+544
.L1085:
	movem.l (%sp),#3132
	lea (24,%sp),%sp
	rts
.L1087:
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
	jeq .L1089
	mvz.b 516(%a0),%d1
	cmp.l %d4,%d1
	jeq .L1090
.L1091:
	clr.l %d0
.L1089:
	mov3q.l #1,%d1
	lsl.l %d2,%d1
	move.l %a1,%d5
	move.b %d3,516(%a0)
	move.b 35(%sp),528(%a0)
	or.l %d1,%d5
	move.l sq+360,%d1
	move.l %d5,sq+540
	btst #8,%d1
	jeq .L1093
	tst.l %d0
	jne .L1085
	tst.l %d4
	jeq .L1094
	tst.l sq+544
	jeq .L1095
.L1094:
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
.L1095:
	lsr.l #7,%d4
	jne .L1085
	tst.l (%a2)
	jeq .L1085
	move.l sq+8,%d0
	btst %d2,%d0
	jeq .L1085
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
	jne .L1096
	mvz.w #917,%d0
	muls.l %d2,%d0
	add.l #709,%d0
	move.b (%a0,%d0.l),%d0
	jpl .L1098
	moveq #127,%d0
.L1098:
#APP
| 1773 "rui.c" 1
	move.w %sr,%d1
| 0 "" 2
#NO_APP
	move.l %d1,%d5
	move.l %d1,%d4
	and.l #1792,%d5
	mvz.w %d4,%d4
	cmp.l #1792,%d5
	jeq .L1100
	and.l #63743,%d1
	or.l #1792,%d1
#APP
| 1777 "rui.c" 1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
.L1100:
	move.l sq+268,%d1
	sub.l sq+272,%d1
	lsr.l #5,%d1
	jeq .L1101
	addq.l #1,sq+380
.L1102:
#APP
| 1782 "rui.c" 1
	move.w %d4,%sr
| 0 "" 2
#NO_APP
	jra .L1085
.L1090:
	mvz.b 528(%a0),%d1
	cmp.l 32(%sp),%d1
	jeq .L1091
	addq.l #1,sq+548
	mov3q.l #1,sq+544
	jra .L1089
.L1093:
	tst.l %d0
	jne .L1085
	jra .L1095
.L1096:
	move.l #85683,%d0
	move.b (%a0,%d0.l),%d0
	move.l #85684,%d1
	mvz.b (%a0,%d1.l),%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	moveq #127,%d1
	cmp.l %d0,%d1
	jcc .L1098
	moveq #127,%d0
	jra .L1098
.L1101:
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
	jra .L1102
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
	jcc .L1116
	clr.l %d2
.L1116:
	tst.l sq+348
	jne .L1117
	move.l %d2,sq+352
	move.l %d3,sq+356
	mov3q.l #1,sq+348
.L1117:
	lea sq,%a6
	tst.l (%a6)
	jeq .L1118
	cmp.l sq+352.l,%d2
	jeq .L1119
	move.l %d2,%d1
	mvz.b %d1,%d1
	move.l %d4,-(%sp)
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr sq_event
	lea (20,%sp),%sp
.L1119:
	move.l sq+356,%d0
	cmp.l %d0,%d3
	jeq .L1120
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jne .L1121
	bset #8,%d0
	move.l %d0,sq+360
.L1118:
	move.l %d2,sq+352
	move.l %d3,sq+356
.L1123:
	tst.l sq+344
	jne .L1128
	move.l %sp,%d3
	move.l %sp,%d2
	add.l #42,%d3
	add.l #36,%d2
.L1129:
	move.l sq+272,%d4
	cmp.l sq+268.l,%d4
	jne .L1135
.L1134:
	move.l -66650100,%d0
	sub.l 32(%sp),%d0
	cmp.l sq+396.l,%d0
	jls .L1115
	move.l %d0,sq+396
.L1115:
	movem.l (%sp),#23612
	lea (104,%sp),%sp
	rts
.L1121:
	mvz.b %d0,%d0
	move.l %d4,-(%sp)
	mov3q.l #2,-(%sp)
	move.l %d5,-(%sp)
	move.l %d0,-(%sp)
	mov3q.l #3,-(%sp)
	jsr sq_event
	lea (20,%sp),%sp
.L1122:
	move.l sq+360,%d0
	btst #8,%d0
	jeq .L1118
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
	jra .L1118
.L1120:
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jne .L1122
	jra .L1118
.L1128:
	mvz.b sq+340,%d0
	move.l %d0,-(%sp)
	pea sq+276
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1115
	move.l sq+344,%d3
	clr.l %d1
	addq.l #1,sq+376
	lea sq+340,%a0
.L1125:
	cmp.l %d3,%d0
	jlt .L1127
	subq.l #1,%d3
	move.l %d3,sq+344
	jra .L1123
.L1127:
	mvz.w %d0,%d2
	lea sq+276,%a2
	sub.l %a1,%a1
	sub.l %d1,%a2
	lsl.l #4,%d2
.L1126:
	move.l %a2,%d4
	add.l %d1,%d4
	move.l %d4,%a4
	addq.l #1,%a1
	move.b (%a4,%d2.l),(%a2)+
	moveq #16,%d4
	cmp.l %a1,%d4
	jne .L1126
	move.b 1(%a0),(%a0)
	addq.l #1,%a0
	addq.l #1,%d0
	add.l #-16,%d1
	jra .L1125
.L1135:
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
.L1130:
	move.l sq+272,%d0
	add.l %d4,%d0
	cmp.l sq+268.l,%d0
	jeq .L1131
	moveq #14,%d0
	cmp.l %d4,%d0
	jeq .L1131
	move.l sq+272,%d0
	moveq #31,%d1
	add.l %d4,%d0
	and.l %d1,%d0
	lsl.l #3,%d0
	cmp.l 12(%a6,%d0.l),%d5
	jeq .L1132
.L1131:
	move.b %d4,46(%sp)
	move.b #-9,(%a0)+
	sub.l %d2,%a0
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1134
	add.l %d4,sq+272
	addq.l #1,sq+372
	jra .L1129
.L1132:
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
	jra .L1130
	.size	sq_end, .-sq_end
	.align	2
	.globl	pin_frame
	.type	pin_frame, @function
pin_frame:
	lea (-72,%sp),%sp
	movem.l #31996,(%sp)
	move.l pin,%d0
	move.l #-2147458112,%d5
	move.l pin+4,%d4
	move.l %d0,58(%sp)
	move.l %d4,64(%sp)
	cmp.l 76(%sp),%d5
	jne .L1156
	move.l pin+16,%d7
	move.l %d7,%d0
	or.l 58(%sp),%d0
	move.l pin+12,%d1
	addq.l #1,pin+32
	move.l %d7,50(%sp)
	or.l %d1,%d0
	jeq .L1156
	move.l -66650100,%d0
	move.l pin+20,%a1
	move.l %d0,68(%sp)
	tst.l %a1
	jne .L1158
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
.L1158:
	clr.b %d4
	clr.b %d5
	sub.l %a0,%a0
	clr.l %d3
	move.l pin+8,%d2
	clr.l %d6
	move.l pin+48,%a6
	move.b %d4,63(%sp)
	move.b %d5,62(%sp)
.L1172:
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
	jcs .L1159
	move.l 58(%sp),%d5
	move.l %a4,%d7
	btst %d7,%d5
	jeq .L1159
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
	jeq .L1160
	move.l #128,(%a3)
	move.l #128,(%a2)
	move.l %a1,4(%a3)
	move.l %a1,4(%a2)
	tst.l %a5
	jeq .L1161
	addq.l #1,pin+44
.L1161:
	moveq #1,%d0
	and.l 54(%sp),%d2
	move.b %d0,62(%sp)
.L1162:
	move.l 46(%sp),%a2
	add.l #-2147457816,%a2
	clr.l (%a2)
	cmp.l #32512,%d5
	jeq .L1177
	cmp.l #255,%d5
	jls .L1165
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
	jls .L1166
	mvz.w #65535,%d4
.L1166:
	mulu.w #32512,%d0
	move.w %d4,(%a3)
	divu.l %d5,%d0
	cmp.l #65535,%d0
	jls .L1167
	mvz.w #65535,%d0
.L1167:
	move.w %d0,(%a2)
.L1165:
	moveq #1,%d0
	move.w #32512,(%a0)
	addq.l #1,%a6
	move.b %d0,63(%sp)
.L1177:
	move.w #1,%a0
	jra .L1164
.L1160:
	tst.l %a5
	jeq .L1163
	moveq #127,%d0
	moveq #127,%d4
	move.l %d0,(%a3)
	move.l pin+28,%d0
	move.l %d4,(%a2)
	move.l %d0,4(%a3)
	move.l %d0,4(%a2)
	jra .L1162
.L1163:
	moveq #1,%d4
	move.l pin+24,%d7
	move.l #1073741951,(%a3)
	move.l #1073741951,(%a2)
	move.l %d7,4(%a3)
	or.l %d0,%d2
	move.l %d7,4(%a2)
	addq.l #1,pin+40
	move.b %d4,62(%sp)
	jra .L1162
.L1159:
	move.l 50(%sp),%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L1168
	move.l %d0,%d4
	not.l %d4
	and.l %d4,%d2
	moveq #1,%d4
	or.l %d0,%d1
	move.w #1,%a0
	move.b %d4,62(%sp)
.L1168:
	move.l %d1,%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L1164
	btst #6,(%a2)
	jeq .L1170
	not.l %d0
	and.l %d0,%d1
	jra .L1177
.L1170:
	move.l #128,(%a3)
	move.l #128,(%a2)
	move.l %a1,4(%a3)
	move.l %a1,4(%a2)
.L1164:
	addq.l #1,%d3
	moveq #8,%d5
	cmp.l %d3,%d5
	jne .L1172
	tst.b 63(%sp)
	jeq .L1173
	move.l %a6,pin+48
.L1173:
	tst.b 62(%sp)
	jeq .L1174
	move.l %d2,pin+8
.L1174:
	move.w %a0,%d7
	tst.b %d7
	jeq .L1175
	move.l %d1,pin+12
.L1175:
	tst.l %d6
	jeq .L1176
	addq.l #1,pin+36
.L1176:
	move.l -66650100,%d0
	move.l %d6,pin+16
	sub.l 68(%sp),%d0
	cmp.l pin+52.l,%d0
	jls .L1156
	move.l %d0,pin+52
.L1156:
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
	jcc .L1204
.L1206:
	clr.l %d1
.L1205:
	move.l %d1,16(%sp)
	move.l %a0,%d1
	mvz.b %d1,%d1
	clr.l 12(%sp)
	move.l %d0,4(%sp)
	move.l %d1,8(%sp)
	jra ed_queue
.L1204:
	mvz.w #4368,%d1
	btst %d0,%d1
	jeq .L1206
	mov3q.l #3,%d1
	and.l 12(%sp),%d1
	jra .L1205
	.size	ed_report, .-ed_report
	.align	2
	.globl	pm_menu_add
	.type	pm_menu_add, @function
pm_menu_add:
	link.w %fp,#-68
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	tst.l 8(%fp)
	jeq .L1210
	lea (-64,%fp),%a2
	clr.l %d0
	move.l %a2,%a0
.L1212:
	clr.l 12(%a0)
	clr.l 8(%a0)
	clr.l (%a0)
	clr.l 4(%a0)
	addq.l #1,%d0
	lea (16,%a0),%a0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L1212
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
	jeq .L1210
	tst.l %a3
	jeq .L1210
	tst.l -32(%fp)
	jeq .L1210
	tst.l %d0
	jeq .L1210
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
.L1213:
	mvz.w -66(%fp),%d0
	lsl.l #4,%d0
	pea (%a2,%d0.l)
	jsr 1075251654
	subq.l #1,-68(%fp)
	addq.l #4,%sp
	mov3q.l #-1,%d0
	cmp.l -68(%fp),%d0
	jne .L1213
	addq.l #1,pm+4
.L1210:
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
	jcc .L1226
	addq.l #1,pm+24
	pea pm_t_track
.L1230:
	move.l %a0,-(%sp)
	jsr pm_popup
	addq.l #8,%sp
	rts
.L1226:
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L1228
	move.l commits,%d1
	cmp.l pm+28.l,%d1
	jne .L1229
.L1228:
	addq.l #1,pm+20
	pea pm_t_none
	jra .L1230
.L1229:
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
	move.l %d2,-(%sp)
	move.l 8(%sp),%d2
	tst.b cu.l
	jeq .L1231
	move.l %d2,-(%sp)
	addq.l #1,cu+12
	jsr cu_src_setup
	addq.l #4,%sp
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-48,%d0
	cmp.l %d0,%d1
	jcc .L1233
	moveq #43,%d0
	cmp.l %d2,%d0
	jne .L1231
.L1233:
	moveq #11,%d1
	cmp.l 12(%sp),%d1
	jcs .L1231
	move.l #1075731444,%a0
	cmp.l sv+88.l,%a0
	jne .L1231
	lea (15,%sp),%a0
	mvz.b cu+30,%d0
	move.b (%a0),cu+10
	lea st+8,%a0
	move.b %d2,cu+9
	move.l (%a0),cu+16
	cmp.l 12(%sp),%d0
	jne .L1235
	move.b cu+28,%d0
.L1234:
	move.b %d0,cu+29
.L1231:
	move.l (%sp)+,%d2
	rts
.L1235:
	clr.b %d0
	jra .L1234
	.size	cu_prep, .-cu_prep
	.align	2
	.globl	cu_mi_settling
	.type	cu_mi_settling, @function
cu_mi_settling:
	mvz.b cu+11,%d1
	move.l 4(%sp),%d0
	addq.l #1,%d0
	cmp.l %d1,%d0
	jne .L1238
	move.l st+8,%d0
	moveq #15,%d1
	sub.l cu+24,%d0
	cmp.l %d0,%d1
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1236:
	rts
.L1238:
	clr.l %d0
	jra .L1236
	.size	cu_mi_settling, .-cu_mi_settling
	.align	2
	.type	sv_flush, @function
sv_flush:
	link.w %fp,#-112
	movem.l #15420,(%sp)
	tst.b sv+4.l
	jeq .L1240
	lea sv+5,%a0
	move.w #10497,%d1
	move.w #-2304,%a1
	move.w (%a0),-36(%fp)
	pea 9.w
	move.l #-260222380,%d0
	pea -42(%fp)
	move.l %d0,-42(%fp)
	move.w %d1,-38(%fp)
	move.w %a1,-34(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1239
	clr.b %d0
	addq.l #1,sv+64
	move.b %d0,sv+4
.L1240:
	tst.b sv+102.l
	jeq .L1243
	moveq #127,%d0
	moveq #127,%d4
	and.l sv+92,%d0
	move.w #11009,%d3
	move.l #-260222380,%d1
	moveq #14,%d5
	move.l %d1,-74(%fp)
	moveq #28,%d1
	move.l sv+88,%d2
	lea sv+100,%a0
	move.b (%a0),-68(%fp)
	move.b %d0,-67(%fp)
	move.l %d2,%d0
	lsr.l %d1,%d0
	move.w %d3,-70(%fp)
	moveq #21,%d3
	moveq #127,%d1
	move.b %d0,-66(%fp)
	move.l %d2,%d0
	lsr.l %d3,%d0
	and.l %d4,%d0
	move.b %d0,-65(%fp)
	move.l %d2,%d0
	lsr.l %d5,%d0
	and.l %d4,%d0
	move.b %d0,-64(%fp)
	move.l %d2,%d0
	lsr.l #7,%d0
	and.l %d4,%d0
	move.b %d0,-63(%fp)
	moveq #127,%d0
	and.l %d2,%d0
	move.b %d0,-62(%fp)
	move.l sv+96,%d0
	cmp.l %d0,%d1
	jcc .L1244
	moveq #127,%d0
.L1244:
	move.b %d0,-61(%fp)
	clr.l %d0
	lea (-42,%fp),%a0
.L1245:
	lea -74(%fp,%d0.l),%a1
	addq.l #1,%d0
	moveq #14,%d1
	move.b (%a1),-1(%a0,%d0.l)
	cmp.l %d0,%d1
	jne .L1245
	moveq #-9,%d3
	pea 15.w
	move.l %a0,-(%sp)
	move.b %d3,-28(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1239
	clr.b %d4
	lea sv+100,%a0
	move.b (%a0),sv+101
	lea st+8,%a1
	move.l %d2,sv+104
	move.l (%a1),sv+108
	addq.l #1,sv+112
	move.b %d4,sv+102
.L1243:
	tst.b sv.l
	jeq .L1239
	mvz.b sv+1,%d0
	not.l %d0
	move.l %d0,-(%sp)
	jsr cu_steps
	addq.l #4,%sp
	tst.l %d0
	jne .L1239
	move.l sv+120,%d0
	cmp.l sv+116.l,%d0
	jeq .L1247
	moveq #1,%d1
	move.b %d1,sv+7
.L1247:
	lea (-74,%fp),%a3
	moveq #16,%d4
	lea sv,%a4
	clr.l %d3
	mov3q.l #-1,%d2
	move.l %d4,-80(%fp)
	move.l %a3,%a2
.L1252:
	mvz.b sv+1,%d0
	move.l sv+116,-(%sp)
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	jsr sv_word
	lea (12,%sp),%sp
	move.b sv+7,%d4
	move.w %d0,(%a3)
	tst.b %d4
	jne .L1248
	mvz.w %d0,%d1
	mvz.w 24(%a4),%d5
	cmp.l %d1,%d5
	jeq .L1249
.L1248:
	cmp.l -80(%fp),%d3
	jge .L1250
	move.l %d3,-80(%fp)
.L1250:
	move.l %d3,%d2
.L1249:
	mov3q.l #7,%d1
	cmp.l %d3,%d1
	jge .L1251
	tst.w %d0
	jeq .L1251
	mvz.b sv+1,%d0
	move.l %d0,-(%sp)
	jsr cu_mi_settling
	addq.l #4,%sp
	tst.l %d0
	jne .L1239
.L1251:
	addq.l #2,%a3
	addq.l #1,%d3
	addq.l #2,%a4
	moveq #16,%d5
	cmp.l %d3,%d5
	jne .L1252
	tst.b %d4
	jne .L1263
	mov3q.l #-1,%d0
	cmp.l %d2,%d0
	jne .L1253
.L1239:
	movem.l -112(%fp),#15420
	unlk %fp
	rts
.L1263:
	clr.l -80(%fp)
	moveq #15,%d2
.L1253:
	move.l sv+116,%d0
	not.l %d0
	add.l %d0,%d0
	subx.l %d0,%d0
	neg.l %d0
	move.l #-260222380,%d1
	move.l %d1,-42(%fp)
	move.b sv+1,%d1
	move.w #10753,%d3
	move.b -77(%fp),-35(%fp)
	lea (-33,%fp),%a0
	lsl.l #6,%d0
	move.w %d3,-38(%fp)
	or.l %d1,%d0
	move.b %d0,-36(%fp)
	move.l %d2,%d0
	addq.l #1,%d0
	move.l %d0,%d1
	sub.l -80(%fp),%d1
	move.b %d1,-34(%fp)
	move.l -80(%fp),%d1
.L1254:
	cmp.l %d2,%d1
	jle .L1255
	cmp.l -80(%fp),%d0
	sge %d0
	move.l %d0,%d1
	neg.l %d1
	tst.b %d1
	jeq .L1256
	move.l %d2,%d1
	sub.l -80(%fp),%d1
	add.l %d1,%d1
	add.l #11,%d1
.L1257:
	moveq #-9,%d5
	neg.l %d0
	move.b %d5,-42(%fp,%d1.l)
	tst.b %d0
	jeq .L1258
	move.l %d2,%d0
	addq.l #6,%d0
	sub.l -80(%fp),%d0
	add.l %d0,%d0
.L1259:
	move.l %d0,-(%sp)
	pea -42(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1239
	lea sv+24,%a0
.L1260:
	cmp.l -80(%fp),%d2
	jge .L1261
	clr.b %d3
	move.l sv+116,%d0
	addq.l #1,sv+68
	move.b %d3,sv+7
	tst.l %d0
	jlt .L1262
	addq.l #1,sv+124
.L1262:
	move.l %d0,sv+120
	jra .L1239
.L1255:
	move.w (%a2,%d1.l*2),%d3
	addq.l #1,%d1
	addq.l #2,%a0
	move.l %d3,%d4
	lsr.l #7,%d4
	move.b %d4,-2(%a0)
	moveq #127,%d4
	and.l %d4,%d3
	move.b %d3,-1(%a0)
	jra .L1254
.L1256:
	moveq #9,%d1
	jra .L1257
.L1258:
	moveq #10,%d0
	jra .L1259
.L1261:
	move.l -80(%fp),%d1
	lea (%a2,%d1.l*2),%a1
	move.w (%a1),(%a0,%d1.l*2)
	addq.l #1,%d1
	move.l %d1,-80(%fp)
	jra .L1260
	.size	sv_flush, .-sv_flush
	.align	2
	.globl	pmo_pre
	.type	pmo_pre, @function
pmo_pre:
	move.l -66650100,%d1
	moveq #127,%d0
	and.l -2147457096,%d0
	lea (-80,%sp),%sp
	movem.l #31996,(%sp)
	lea fp,%a3
	move.l %d1,56(%sp)
	clr.l pmo+116
	addq.l #1,pmo+24
	move.l (%a3),pmo+112
	lea pmo,%a2
	cmp.l pmo+100.l,%d0
	jne .L1276
	move.l pmo+96,%d2
	cmp.l pmo+76.l,%d2
	jeq .L1277
.L1276:
	lea pmo+76,%a0
	move.l %d0,pmo+100
	move.l (%a0),pmo+96
	tst.l pmo
	jeq .L1277
	lea pmo+584,%a0
	clr.l %d0
.L1278:
	clr.l (%a0)+
	addq.l #1,%d0
	cmp.l #208,%d0
	jne .L1278
	lea pmo+3464,%a0
	clr.l %d0
.L1279:
	clr.b (%a0)
	addq.l #1,%d0
	lea (44,%a0),%a0
	cmp.l #128,%d0
	jne .L1279
	clr.l %d0
.L1280:
	move.l %d0,%d1
	add.l #36,%d1
	clr.l (%a2,%d1.l*4)
	moveq #13,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1280
	clr.l pmo
	clr.l pmo+104
	clr.l pmo+9096
	clr.l pmo+300
	addq.l #1,pmo+32
.L1277:
	move.l pmo+56,%d7
	move.l pmo+88,%d2
	cmp.l pmo+68.l,%d2
	jne .L1281
	move.l pmo+92,%d3
	cmp.l pmo+72.l,%d3
	jeq .L1343
.L1281:
	move.l %d7,%d0
	mov3q.l #1,%d5
	add.l pmo+9228,%d0
	lea pmo+68,%a0
	move.l (%a0),pmo+88
	lea pmo+72,%a5
	sub.l pmo+80,%d0
	move.l (%a5),pmo+92
	pea 32.w
	pea 8191.w
	move.l %d0,pmo+9228
	move.l %d7,pmo+80
	jsr pmo_fade
	addq.l #8,%sp
.L1282:
	moveq #65,%d6
	sub.l %a4,%a4
	clr.l %d4
	lea pmo_get,%a5
.L1283:
	move.l pmo+80,%d2
	cmp.l %d2,%d7
	jeq .L1299
	subq.l #1,%d6
	tst.l %d6
	jne .L1300
.L1299:
	tst.l %d4
	jeq .L1301
.L1287:
	move.l %a4,-(%sp)
	move.l %d4,-(%sp)
	jsr pmo_fade
	addq.l #8,%sp
	mov3q.l #1,%d5
.L1301:
	tst.l pmo
	jne .L1302
.L1333:
	move.l 56(%sp),-(%sp)
	jsr pmo_time
	addq.l #4,%sp
	movem.l (%sp),#31996
	lea (80,%sp),%sp
	rts
.L1343:
	clr.l %d5
	jra .L1282
.L1300:
	mvz.b %d2,%d2
	move.l %d2,%d3
	lsl.l #3,%d3
	lea (%a2,%d3.l),%a0
	mvz.b 1423(%a0),%d0
	cmp.l pmo+100.l,%d0
	jeq .L1284
	addq.l #1,pmo+8
.L1285:
	addq.l #1,pmo+80
	jra .L1283
.L1284:
	mvz.b 1418(%a0),%d0
	mov3q.l #6,%d1
	move.l %d0,%a1
	cmp.l %d0,%d1
	jne .L1286
	mvz.w 1420(%a0),%d0
	mvz.b 1419(%a0),%d2
	addq.l #1,pmo+28
	or.l %d0,%d4
	move.l %d2,%a4
	jra .L1285
.L1286:
	tst.l %d4
	jne .L1287
	add.l #177,%d2
	move.l %d2,%d0
	lsl.l #3,%d0
	move.l %d2,60(%sp)
	addq.l #1,pmo+28
	move.b 1(%a2,%d0.l),%d2
	mvz.b (%a2,%d0.l),%d1
	moveq #63,%d0
	and.l %d2,%d0
	mov3q.l #4,%d2
	move.l %d0,52(%sp)
	cmp.l %a1,%d2
	jne .L1288
	mvz.w 1420(%a0),%d2
	moveq #18,%d0
	lsl.l %d0,%d2
	move.l %d2,%a0
	asr.l %d0,%d2
	tst.l %a0
	jne .L1289
	move.l %d1,%d0
	lsl.l #6,%d0
	lea (%a2,%d0.l),%a0
	add.l 52(%sp),%a0
	tst.b 584(%a0)
	jeq .L1285
.L1289:
	move.l 52(%sp),-(%sp)
	move.l %d1,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
	move.l %d0,%a0
	tst.l %d0
	jne .L1291
	addq.l #1,pmo+16
	mov3q.l #4,pmo+120
	jra .L1285
.L1291:
	moveq #10,%d1
	lsl.l %d1,%d2
	move.l %d3,%a1
	add.l #pmo+1419,%a1
	move.b (%a1),%d0
	move.l %d2,12(%a0)
	tst.b %d0
	jne .L1292
	move.l %d2,4(%a0)
.L1293:
	move.b %d0,2(%a0)
	jra .L1285
.L1292:
	moveq #127,%d1
	moveq #9,%d3
	and.l %d0,%d1
	sub.l 4(%a0),%d2
	lea pmo_rcp,%a1
	asr.l %d3,%d2
	mvz.w (%a1,%d1.l*2),%d1
	muls.l %d1,%d2
	asr.l #6,%d2
	move.l %d2,8(%a0)
	jra .L1293
.L1288:
	move.b 1422(%a0),%d0
	mvz.b %d0,%d2
	move.w %d0,%a1
	moveq #126,%d0
	move.l %d2,%a6
	cmp.l %d2,%d0
	jcs .L1344
	move.w %a1,%d2
	tst.b %d2
	jeq .L1295
	move.l %a6,%d0
	move.l #66052,%d2
	muls.l %d2,%d0
	move.l %d0,%a6
.L1294:
	move.l 52(%sp),-(%sp)
	move.l %d1,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
	move.l %d0,%a0
	tst.l %d0
	jne .L1296
	addq.l #1,pmo+16
	mov3q.l #5,pmo+120
	jra .L1285
.L1295:
	move.l %d1,%d0
	lsl.l #6,%d0
	lea (%a2,%d0.l),%a0
	add.l 52(%sp),%a0
	tst.b 584(%a0)
	jeq .L1285
	sub.l %a6,%a6
	jra .L1294
.L1344:
	move.l #8388608,%a6
	jra .L1294
.L1296:
	move.l %d3,%a1
	add.l #pmo+1420,%a1
	mvz.w (%a1),%d1
	moveq #9,%d2
	lsl.l %d2,%d1
	move.l %d1,24(%a0)
	tst.l 28(%a0)
	jne .L1297
	tst.b 3(%a0)
	jne .L1297
	move.l %d1,16(%a0)
.L1297:
	move.l 60(%sp),%d2
	lsl.l #3,%d2
	move.b 1(%a2,%d2.l),%d1
	btst #6,%d1
	jne .L1345
	move.l %d3,%a1
	add.l #pmo+1419,%a1
	mvz.b (%a1),%d1
.L1298:
	move.l %d1,-(%sp)
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	jsr pmo_mix
	lea (12,%sp),%sp
	jra .L1285
.L1345:
	clr.l %d1
	jra .L1298
.L1302:
	tst.l %d5
	jne .L1304
	move.l pmo+84,%d3
	cmp.l pmo+60.l,%d3
	jeq .L1304
	move.l (%a3),%d0
	sub.l pmo+60,%d0
	cmp.l #375,%d0
	jls .L1304
	lea pmo+60,%a0
	move.l (%a0),pmo+84
	pea 32.w
	pea 8191.w
	addq.l #1,pmo+12
	jsr pmo_fade
	addq.l #8,%sp
.L1304:
	tst.l -2147418904
	jeq .L1305
	lea pmo+512,%a0
	clr.l %d0
.L1306:
	clr.l (%a0)+
	moveq #18,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1306
	move.l #-2147423060,%a0
.L1308:
	move.w (%a0),%d1
	mvz.w %d1,%d0
	cmp.l #571,%d0
	jhi .L1307
	moveq #31,%d3
	lsr.l #5,%d0
	and.l %d3,%d1
	mov3q.l #1,%d3
	add.l #128,%d0
	lsl.l %d1,%d3
	or.l %d3,(%a2,%d0.l*4)
.L1307:
	addq.l #2,%a0
	cmp.l #-2147422964,%a0
	jne .L1308
.L1305:
	move.l pmo+104,%a1
	clr.l %d2
	clr.l pmo+300
	lea pmo,%a4
	lea pmo+3464,%a0
.L1309:
	cmp.l %a1,%d2
	jne .L1323
	lea pmo+3464,%a0
	clr.b %d0
.L1326:
	tst.l %d2
	jne .L1324
	tst.b %d0
	jeq .L1325
	clr.l pmo+104
.L1325:
	move.l pmo+300,%d2
	move.l #-2147420170,%a2
	lea pmo,%a0
	clr.l %d1
	move.l #-2147457058,%a1
	jra .L1331
.L1323:
	move.b (%a0),%d1
	jeq .L1310
	move.b 2(%a0),%d0
	jeq .L1311
	subq.l #1,%d0
	move.b %d0,2(%a0)
	jeq .L1312
	move.l 8(%a0),%d4
	add.l %d4,4(%a0)
.L1311:
	move.b 3(%a0),%d0
	jeq .L1313
	subq.l #1,%d0
	move.b %d0,3(%a0)
	jeq .L1314
	move.l 20(%a0),%d5
	move.l 32(%a0),%d0
	add.l %d5,16(%a0)
	add.l %d0,28(%a0)
.L1313:
	move.b 1(%a0),%d4
	move.l 4(%a0),%d0
	mvz.b %d4,%d3
	tst.l %d0
	jne .L1315
	tst.b 2(%a0)
	jne .L1315
	tst.l 28(%a0)
	jne .L1315
	tst.b 3(%a0)
	jne .L1315
	mvz.b %d1,%d1
	subq.l #1,%d1
	lsl.l #6,%d1
	lea (%a2,%d1.l),%a5
	clr.b %d1
	add.l %d3,%a5
	move.b %d1,584(%a5)
	clr.b (%a0)
	move.l pmo+9096,%d0
	move.l %d0,%d3
	addq.l #1,%d3
	subq.l #1,(%a2)
	lea (%a2,%d0.l),%a5
	move.b %d2,9100(%a5)
	move.l %d3,pmo+9096
.L1310:
	addq.l #1,%d2
	lea (44,%a0),%a0
	jra .L1309
.L1312:
	move.l 12(%a0),4(%a0)
	jra .L1311
.L1314:
	move.l 24(%a0),16(%a0)
	move.l 36(%a0),28(%a0)
	jra .L1313
.L1315:
	moveq #8,%d5
	cmp.l %d3,%d5
	jcs .L1316
	move.l 40(%a0),%d1
	move.l %d1,%d3
	add.l %d3,%d3
	move.l 28(%a0),%d4
	move.l %d3,%a5
	add.l #-2147420300,%a5
	mvz.w (%a5),%d3
	tst.l %d4
	jeq .L1319
	tst.l -2147418904
	jeq .L1318
	move.l %d1,%d5
	lsr.l #5,%d5
	add.l #128,%d5
	move.l (%a2,%d5.l*4),%d6
	moveq #31,%d5
	and.l %d1,%d5
	btst %d5,%d6
	jeq .L1318
	addq.l #1,pmo+52
	move.l (%a3),pmo+108
.L1319:
	asr.l #8,%d0
	add.l %d3,%d0
	tst.l %d0
	jlt .L1346
	cmp.l #32767,%d0
	jgt .L1347
.L1320:
	move.w %d0,(%a5)
	jra .L1310
.L1318:
	lsl.l #2,%d1
	asr.l #8,%d4
	move.l %d1,%a6
	add.l #-2147422588,%a6
	move.l (%a6),%d5
	move.l 16(%a0),%d1
	asr.l #8,%d1
	clr.w %d5
	swap %d5
	sub.l %d5,%d1
	muls.l %d4,%d1
	moveq #15,%d4
	asr.l %d4,%d1
	add.l %d1,%d3
	jra .L1319
.L1346:
	clr.w %d0
	jra .L1320
.L1347:
	move.w #32767,%d0
	jra .L1320
.L1316:
	add.l #-48,%d4
	mvz.b %d4,%d4
	lsr.l #3,%d4
	jne .L1310
	mvz.b %d1,%d1
	move.l pmo+300,%d6
	asr.l #8,%d0
	move.l %d1,%d4
	subq.l #1,%d4
	btst %d4,%d6
	jne .L1321
	mov3q.l #1,%d5
	lsl.l %d4,%d5
	add.l #18,%d1
	lsl.l #4,%d1
	or.l %d6,%d5
	move.l %d5,pmo+300
	clr.w %d5
	move.w %d5,(%a2,%d1.l)
	move.l %d4,%d1
	lsl.l #4,%d1
	move.l %d1,%a5
	add.l #pmo,%a5
	move.w %d5,306(%a5)
	clr.l 308(%a5)
	clr.l 312(%a5)
	clr.l 316(%a5)
.L1321:
	cmp.l #-32768,%d0
	jlt .L1348
	cmp.l #32767,%d0
	jgt .L1349
.L1322:
	lsl.l #3,%d4
	move.l %d4,%a6
	lea 104(%a6,%d3.l),%a5
	move.w %d0,(%a2,%a5.l*2)
	jra .L1310
.L1348:
	move.w #-32768,%d0
	jra .L1322
.L1349:
	move.w #32767,%d0
	jra .L1322
.L1350:
	moveq #1,%d0
	move.l %d1,%d2
	jra .L1326
.L1324:
	move.l %d2,%d1
	subq.l #1,%d1
	move.w %d1,%d3
	mulu.w #44,%d3
	tst.b (%a0,%d3.l)
	jeq .L1350
	tst.b %d0
	jeq .L1325
	move.l %d2,pmo+104
	jra .L1325
.L1332:
	btst #0,%d0
	jeq .L1328
	move.l %d1,%d3
	add.l #-536856241,%d3
	lsl.l #2,%d3
	mvz.w -26(%a1),%d0
	move.l %d3,%a3
	btst #3,3(%a3)
	jeq .L1351
	mvs.w (%a2),%d3
.L1329:
	move.l %d0,%a5
	add.l %d3,%a5
	move.l %a5,196(%a0)
	move.l %a5,%d0
	cmp.l #32767,%a5
	jle .L1330
	mvz.w #32767,%d0
.L1330:
	move.l %d0,196(%a0)
	mvs.w (%a1),%d0
	move.l %d0,248(%a0)
.L1328:
	addq.l #1,%d1
	addq.l #4,%a0
	addq.l #2,%a1
	lea (84,%a2),%a2
.L1331:
	move.l %d2,%d0
	lsr.l %d1,%d0
	jne .L1332
	tst.l %d2
	jeq .L1333
	lea pmo+9248,%a2
	clr.l %d5
	move.l #pmo+304,%d6
	lea pmo,%a6
.L1342:
	mov3q.l #1,%d1
	and.l %d2,%d1
	move.l %d1,64(%sp)
	btst #0,%d2
	jeq .L1334
	move.w %d5,%d0
	mvz.w %d5,%d4
	lea (16,%a2),%a1
	clr.l %d3
	move.l %d6,48(%sp)
	clr.l %d7
	lsl.l #4,%d4
	mulu.w #21,%d0
	add.l #26,%d0
	move.l %d0,68(%sp)
.L1340:
	move.l %d4,%a5
	add.l #-2147423684,%a5
	lea (-32,%a1),%a3
	sub.l %a0,%a0
	move.l 48(%sp),52(%sp)
	move.l %a5,72(%sp)
.L1339:
	move.l 72(%sp),%a5
	move.l (%a5,%a0.l),%d1
	move.l 52(%sp),%a5
	addq.l #2,52(%sp)
	mvz.w %d1,%d1
	mvz.w (%a5)+,%d0
	move.l %d0,44(%sp)
	tst.l %d0
	jeq .L1335
	move.l %d1,%d0
	sub.l 68(%sp),%d0
	move.l %d0,60(%sp)
	subq.l #1,%d0
	move.l %d0,76(%sp)
	moveq #40,%d0
	cmp.l 76(%sp),%d0
	jcc .L1336
.L1335:
	move.l %d1,(%a1,%a0.l)
	move.l %d1,(%a3,%a0.l)
.L1337:
	addq.l #4,%a0
	moveq #16,%d1
	cmp.l %a0,%d1
	jne .L1339
	lea (16,%a1),%a1
	add.l #16,%d4
	addq.l #8,48(%sp)
	subq.l #1,%d7
	tst.l %d7
	jne .L1352
	move.b %d3,10064(%a6)
	btst #0,%d3
	jeq .L1341
	pea -16(%a2)
	move.l 196(%a4),-(%sp)
	jsr 1074912702
	addq.l #8,%sp
.L1341:
	btst #1,%d3
	jeq .L1334
	move.l %a2,-(%sp)
	move.l 248(%a4),-(%sp)
	jsr 1074912702
	addq.l #8,%sp
.L1334:
	lsr.l #1,%d2
	addq.l #4,%a4
	lea (64,%a2),%a2
	addq.l #1,%a6
	addq.l #2,%d5
	add.l #16,%d6
	tst.l %d2
	jne .L1342
	jra .L1333
.L1351:
	clr.l %d3
	jra .L1329
.L1352:
	move.l 64(%sp),%d7
	jra .L1340
.L1336:
	move.l 44(%sp),%d0
	swap %d0
	clr.w %d0
	or.l %d1,%d0
	move.l %d0,%a5
	moveq #8,%d0
	cmp.l 60(%sp),%d0
	jcs .L1338
	move.l %a5,(%a3,%a0.l)
	move.l %d1,(%a1,%a0.l)
	mov3q.l #1,%d0
.L1409:
	lsl.l %d7,%d0
	or.l %d0,%d3
	jra .L1337
.L1338:
	move.l %a5,(%a1,%a0.l)
	move.l %d1,(%a3,%a0.l)
	mov3q.l #4,%d0
	jra .L1409
	.size	pmo_pre, .-pmo_pre
	.align	2
	.globl	pmo_post
	.type	pmo_post, @function
pmo_post:
	move.l -66650100,%d0
	lea (-92,%sp),%sp
	movem.l #31804,(%sp)
	move.l %d0,40(%sp)
	lea pmo,%a3
	move.l (%a3),%d0
	tst.l %d0
	jeq .L1411
	move.w #12,%a6
	lea (44,%sp),%a2
	move.l %a2,%a0
.L1412:
	clr.l (%a0)+
	subq.l #1,%a6
	tst.l %a6
	jne .L1412
	move.l pmo+104,%d1
	clr.l %d5
	lea pmo,%a4
	lea pmo+3464,%a0
	move.l %d1,36(%sp)
.L1413:
	cmp.l 36(%sp),%d5
	jne .L1422
	move.l pmo+300,%d2
	tst.l %d2
	jeq .L1427
	lea pmo+9280,%a5
	move.l #pmo,%d3
.L1426:
	btst #0,%d2
	jeq .L1424
	move.b 10064(%a4),%d0
	move.w %d0,%ccr
	jne .L1425
	pea -16(%a5)
	move.l %d3,%a0
	move.l 196(%a0),-(%sp)
	jsr 1074912702
	addq.l #8,%sp
.L1425:
	move.b 10064(%a4),%d0
	move.w %d0,%ccr
	jpl .L1424
	move.l %a5,-(%sp)
	move.l %d3,%a1
	move.l 248(%a1),-(%sp)
	jsr 1074912702
	addq.l #8,%sp
.L1424:
	lsr.l #1,%d2
	addq.l #1,%a4
	addq.l #4,%d3
	lea (64,%a5),%a5
	tst.l %d2
	jne .L1426
.L1427:
	move.l %a6,%d0
	add.l #36,%d0
	move.l (%a2)+,(%a3,%d0.l*4)
	addq.l #1,%a6
	moveq #12,%d0
	cmp.l %a6,%d0
	jne .L1427
	mov3q.l #1,pmo+140
.L1428:
	move.l 40(%sp),-(%sp)
	jsr pmo_time
	addq.l #4,%sp
	move.l pmo+116,%d0
	cmp.l pmo+36.l,%d0
	jls .L1430
	move.l %d0,pmo+36
.L1430:
	movem.l (%sp),#31804
	add.l %d0,pmo+40
	addq.l #1,pmo+44
	lea (92,%sp),%sp
	rts
.L1422:
	move.b (%a0),%d1
	jeq .L1414
	mvz.b 1(%a0),%d0
	moveq #41,%d2
	cmp.l %d0,%d2
	jcs .L1415
	moveq #8,%d3
	cmp.l %d0,%d3
	jcc .L1414
	move.l 40(%a0),%d0
	move.l %d0,%d1
	add.l %d1,%d1
	move.l 28(%a0),%d3
	move.l %d1,%a5
	add.l #-2147420300,%a5
	mvz.w (%a5),%d2
	tst.l %d3
	jeq .L1418
	tst.l -2147418904
	jeq .L1417
	move.l %d0,%d1
	lsr.l #5,%d1
	add.l #128,%d1
	move.l (%a3,%d1.l*4),%d4
	moveq #31,%d1
	and.l %d0,%d1
	btst %d1,%d4
	jeq .L1417
	lea fp,%a1
	addq.l #1,pmo+52
	move.l (%a1),pmo+108
.L1418:
	move.l 4(%a0),%d0
	asr.l #8,%d0
	add.l %d2,%d0
	tst.l %d0
	jlt .L1431
	cmp.l #32767,%d0
	jgt .L1432
.L1419:
	move.w %d0,(%a5)
.L1414:
	addq.l #1,%d5
	lea (44,%a0),%a0
	jra .L1413
.L1417:
	lsl.l #2,%d0
	move.l 16(%a0),%d1
	asr.l #8,%d1
	asr.l #8,%d3
	add.l #-2147422588,%d0
	move.l %d0,%a1
	move.l (%a1),%d0
	clr.w %d0
	swap %d0
	sub.l %d0,%d1
	muls.l %d3,%d1
	moveq #15,%d0
	asr.l %d0,%d1
	add.l %d1,%d2
	jra .L1418
.L1431:
	clr.w %d0
	jra .L1419
.L1432:
	move.w #32767,%d0
	jra .L1419
.L1415:
	moveq #56,%d2
	cmp.l %d0,%d2
	jne .L1414
	move.l 4(%a0),%d0
	asr.l #8,%d0
	cmp.l #32767,%d0
	jle .L1420
	mvz.w #32767,%d0
.L1420:
	mvz.b %d1,%d1
	move.l 16(%a0),%d2
	subq.l #1,%d1
	and.l #8323072,%d2
	cmp.l #-32768,%d0
	jge .L1421
	mvs.w #-32768,%d0
.L1421:
	mvz.w %d0,%d0
	moveq #24,%d3
	or.l %d0,%d2
	mvs.w 28(%a0),%d0
	lsl.l %d3,%d0
	or.l %d0,%d2
	move.l %d2,44(%sp,%d1.l*4)
	jra .L1414
.L1411:
	tst.l pmo+140
	jeq .L1428
.L1429:
	move.l %d0,%d1
	add.l #36,%d1
	clr.l (%a3,%d1.l*4)
	moveq #12,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1429
	clr.l pmo+140
	jra .L1428
	.size	pmo_post, .-pmo_post
	.align	2
	.globl	pmo_vel
	.type	pmo_vel, @function
pmo_vel:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	moveq #11,%d2
	move.l 12(%sp),%d1
	move.l 16(%sp),%d0
	cmp.l %d1,%d2
	jcs .L1463
	add.l #36,%d1
	lea pmo,%a0
	move.l (%a0,%d1.l*4),%a0
	tst.l %a0
	jeq .L1463
	move.l %a0,%d1
	moveq #127,%d3
	clr.w %d1
	swap %d1
	move.l %a0,%d2
	addq.l #1,pmo+48
	and.l %d3,%d1
	moveq #24,%d3
	lsr.l %d3,%d2
	sub.l %d0,%d1
	muls.l %d2,%d1
	add.l #64,%d1
	asr.l #7,%d1
	add.l %d1,%d0
	mvs.w %a0,%d1
	add.l #128,%d1
	asr.l #8,%d1
	add.l %d1,%d0
	moveq #127,%d1
	cmp.l %d0,%d1
	jge .L1465
	moveq #127,%d0
.L1463:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L1465:
	tst.l %d0
	jgt .L1463
	mov3q.l #1,%d0
	jra .L1463
	.size	pmo_vel, .-pmo_vel
	.align	2
	.globl	rui_tick
	.type	rui_tick, @function
rui_tick:
	link.w %fp,#-204
	move.l #1123449124,%a0
	move.l -66650100,%d1
	movem.l #15612,(%sp)
	lea fp,%a1
	move.l (%a0),fp+8
	move.l 8(%fp),%a2
	move.l (%a1),fp+4
	move.l %d1,-152(%fp)
	clr.l fp+12
.L1471:
	mov3q.l #1,%d0
	cmp.l fp+20.l,%d0
	jeq .L1471
.L1472:
	mov3q.l #2,%d1
	cmp.l fp+20.l,%d1
	jeq .L1473
	move.l 1100667228,%d0
	cmp.l #cu_text,%d0
	jeq .L1474
	cmp.l 1100664624.l,%d0
	jne .L1474
	move.l #cu_text,%d2
	move.l %d2,1100667228
.L1474:
	move.l #1075731444,%d3
	cmp.l sv+88.l,%d3
	jeq .L1475
	move.l #1093765506,%a1
	moveq #11,%d4
	mvz.b (%a1),%d0
	cmp.l %d0,%d4
	jcs .L1475
	move.l -2147457096,%d0
	moveq #127,%d5
	mvz.b (%a1),%d1
	and.l %d5,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	move.b (%a0),cu+28
	move.b (%a1),cu+30
.L1475:
	tst.b cu.l
	jne .L1476
	move.l #1128813124,%d6
	cmp.l 1073849308.l,%d6
	jne .L1476
	moveq #1,%d7
	pea 52.w
	move.b %d7,cu
	jsr cu_src_setup
	addq.l #4,%sp
	lea cu_steps,%a0
	move.l %a0,1073849316
	lea cu_setup,%a1
	move.l %a1,1073849312
.L1476:
	move.l rx,%d2
	move.l #-66650100,%a4
	addq.l #1,st+8
	move.l (%a4),st+300
	tst.l st
	jne .L1477
	lea rui_sysex,%a5
	move.l %a5,1075551840
	move.l #1381321040,%d0
	move.l %d0,1075551836
	mov3q.l #1,st
	move.l %d2,st+16
.L1478:
	move.l #ux,%d5
	jra .L1636
.L1473:
	pea 10000.w
	jsr 1074367512
	addq.l #4,%sp
	jra .L1472
.L1477:
	tst.b host_close.l
	jeq .L1479
	clr.b %d1
	lea commits,%a0
	move.b %d1,host_close
	move.b %d1,host_open
	move.l (%a0),sv+12
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	addq.l #8,%sp
.L1479:
	tst.b host_open.l
	jeq .L1480
	clr.b %d0
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	move.b %d0,host_open
	jsr enter
	lea (12,%sp),%sp
.L1480:
	move.l st+956,%d0
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L1481
	cmp.l #65534,%d0
	jhi .L1482
	tst.l %d0
	jne .L1483
	moveq #50,%d3
	cmp.l st+8.l,%d3
	jcc .L1484
.L1483:
	addq.l #1,%d0
	move.l %d0,st+956
	moveq #10,%d4
	cmp.l %d0,%d4
	jne .L1482
.L1485:
	moveq #1,%d6
	move.w #4095,%d7
	move.l %d2,st+964
	mov3q.l #1,st+960
	move.b %d6,st+992
	move.b %d6,mr+13
	move.b %d6,mr+19
	move.w %d7,ar+60
	jsr sq_forget
	lea commits,%a0
	move.l (%a0),pm+28
.L1486:
	tst.b st+992.l
	jne .L1490
.L1491:
	tst.l splash_req
	jeq .L1493
	move.l splash_req,%d0
	clr.l splash_req
	tst.l st+4
	jne .L1494
	moveq #127,%d1
	and.l %d1,%d0
	tst.l %d0
	jeq .L1495
	tst.l commits
	jne .L1496
.L1494:
	addq.l #1,st+984
.L1493:
	tst.l st+4
	jeq .L1498
	cmp.l st+16.l,%d2
	jeq .L1499
	clr.l st+12
.L1500:
	move.l %d2,st+16
	clr.b %d1
	move.l st+8,%d3
	clr.l %d0
	lea st+408,%a0
.L1506:
	move.l (%a0)+,%a1
	tst.l %a1
	jeq .L1504
	move.l %d3,%d4
	sub.l %a1,%d4
	jmi .L1504
	moveq #1,%d1
	clr.l -4(%a0)
.L1504:
	addq.l #1,%d0
	moveq #16,%d5
	cmp.l %d0,%d5
	jne .L1506
	tst.b %d1
	jeq .L1507
	mov3q.l #1,st+344
.L1507:
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr sv_tick
	addq.l #8,%sp
	tst.b ls.l
	jeq .L1508
	tst.b sv.l
	jeq .L1509
	tst.b sv+8.l
	jeq .L1509
	move.l sv,%d0
	move.l ls,%d6
	eor.l %d6,%d0
	and.l #16776960,%d0
	or.l st+4,%d0
	jeq .L1508
.L1509:
	mov3q.l #5,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1508:
	move.l ls_in_gen,%d7
	cmp.l ls+48.l,%d7
	jeq .L1510
	move.l ls_in_v,%d0
	lea ls_in_gen,%a1
	move.l ls+36,%a0
	move.l (%a1),ls+48
	tst.b ls.l
	jeq .L1510
	move.l %d0,%d1
	lsr.l #8,%d1
	mvz.b ls+1,%d2
	cmp.l %d1,%d2
	jne .L1510
	mov3q.l #1,%d1
	and.l %d1,%d0
	tst.l %a0
	jeq .L1511
	tst.l %d0
	jne .L1511
	clr.l st+124
.L1511:
	move.l %d0,ls+36
	mov3q.l #1,ls+40
.L1510:
	tst.l ls+36
	jeq .L1512
	tst.l ls+40
	jne .L1512
	move.l st+8,%d0
	moveq #20,%d2
	sub.l ls+44,%d0
	cmp.l %d0,%d2
	jcc .L1512
	clr.l ls+36
	addq.l #1,ls+56
	clr.l st+124
.L1512:
	move.l u46+8,%d0
	tst.l %d0
	jeq .L1513
	tst.b ls.l
	jne .L1514
	tst.l st+4
	jne .L1514
	move.l st+8,%d1
	moveq #20,%d3
	sub.l %d0,%d1
	cmp.l %d1,%d3
	jcs .L1514
	move.l #1093765506,%a1
	moveq #11,%d4
	mvz.b (%a1),%d0
	cmp.l %d0,%d4
	jcs .L1514
	move.l -2147457096,%d0
	moveq #127,%d5
	mvz.b (%a1),%d1
	and.l %d5,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d0
	cmp.l u46+12.l,%d0
	jeq .L1515
.L1514:
	clr.l u46+8
.L1513:
	move.l pm,%d2
	tst.l %d2
	jeq .L1516
	clr.l pm
	add.l #31,%d2
	tst.b ls.l
	jeq .L1517
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1517:
	clr.l st+1038
	tst.l st+4
	jeq .L1518
	moveq #1,%d7
	mvz.w #256,%d6
	moveq #1,%d0
	move.b %d2,st+993
	addq.l #1,pm+16
	move.l %d6,st+296
	move.b %d7,st+161
	move.w %d0,st+162
.L1519:
	tst.l st+1058
	jne .L1521
	tst.l sv+96
	jne .L1522
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jeq .L1520
	lea st+8,%a0
	mov3q.l #1,st+1058
	mov3q.l #1,st+1062
	move.l (%a0),st+1066
	addq.l #1,st+1070
	addq.l #1,st+1090
.L1521:
	tst.l st+4
	jne .L1523
	clr.l st+1058
.L1524:
	tst.l st+972
	jne .L1528
	tst.b sv+8.l
	jne .L1528
.L1529:
	move.l st+1082,%d0
	tst.l %d0
	jeq .L1531
	sub.l st+8,%d0
	tst.l %d0
	jgt .L1532
	clr.l st+1082
.L1532:
	moveq #1,%d4
	move.b %d4,32(%a2)
.L1531:
	move.l sq_gen,%d0
	move.b 1093765506,%d2
	cmp.l sq+400.l,%d0
	jeq .L1533
	mov3q.l #1,%d3
	and.l %d0,%d3
	btst #0,%d0
	jne .L1533
	clr.l %d1
	lea sq_req,%a0
.L1534:
	lea (%a0,%d1.l),%a2
	mov3q.l #7,%d4
	lea (-140,%fp),%a1
	move.b (%a2),(%a1,%d1.l)
	addq.l #1,%d1
	cmp.l %d1,%d4
	jne .L1534
	cmp.l sq_gen.l,%d0
	jne .L1533
	move.l %d0,sq+400
	mvz.b -139(%fp),%d0
	mvz.b -140(%fp),%d1
	lsl.l #7,%d0
	or.l %d1,%d0
	mvz.b -137(%fp),%d1
	and.l #4095,%d0
	move.l %d0,sq+4
	mvz.b -136(%fp),%d0
	lsl.l #7,%d0
	or.l %d1,%d0
	and.l #4095,%d0
	or.l sq+4,%d0
	move.l %d0,sq+8
	move.b -138(%fp),%d0
	move.w %d0,%ccr
	jeq .L1536
	move.l sq+4,%d3
.L1536:
	mvz.b -134(%fp),%d1
	mvz.b -135(%fp),%d4
	lsl.l #7,%d1
	or.l %d4,%d1
	and.l #4095,%d1
	or.l %d3,%d1
	move.l %d1,pin
	tst.l sq
	jeq .L1537
	btst #1,%d0
	jeq .L1538
.L1537:
	mvz.w #255,%d5
	mvz.w #8191,%d6
	addq.l #1,sq+452
	mov3q.l #1,ed+92
	move.l %d5,sq+404
	move.l %d6,ed+260
.L1538:
	lsr.l #3,%d0
	mov3q.l #1,%d7
	mov3q.l #1,sq
	and.l %d7,%d0
	mvz.b dk_off,%d1
	cmp.l %d0,%d1
	jeq .L1533
	mov3q.l #1,%d1
	eor.l %d0,%d1
	move.b %d0,dk_off
	move.b %d1,dk_arm
	tst.b %d0
	jne .L1533
	clr.l ed+268
	clr.l ed+372
.L1533:
	tst.l sq
	jne .L1539
	clr.l sq+408
.L1540:
	jsr led_tick
	move.l sq+468,%d2
	move.l pg_gen,%d0
	mvz.b ovp_on,%d3
	tst.l %d2
	jeq .L1591
	cmp.l sq+472.l,%d0
	jeq .L1592
	btst #0,%d0
	jne .L1592
	move.b pg_req,%d5
	move.b pg_req+1,%d4
	move.b pg_req+2,%d2
	move.b pg_req+3,%d1
	cmp.l pg_gen.l,%d0
	jne .L1592
	move.b %d5,sq+480
	move.b %d4,sq+481
	move.b %d2,sq+482
	move.b %d1,sq+483
	move.l %d0,sq+472
	mov3q.l #1,sq+476
.L1592:
	clr.l %d2
	clr.l %d0
	lea sq+480,%a0
.L1594:
	mvz.b (%a0,%d0.l),%d4
	moveq #111,%d5
	cmp.l %d4,%d5
	jcs .L1593
	mov3q.l #1,%d4
	lsl.l %d0,%d4
	or.l %d4,%d2
.L1593:
	addq.l #1,%d0
	mov3q.l #4,%d6
	cmp.l %d0,%d6
	jne .L1594
.L1591:
	cmp.l %d3,%d2
	jne .L1595
	tst.l sq+476
	jeq .L1596
.L1595:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1771
	addq.l #1,st+1018
.L1596:
	tst.l st+4
	jeq .L1772
	tst.l st+1058
	seq %d2
	mvs.b %d2,%d2
	neg.l %d2
.L1604:
	move.l st+8,%d0
	moveq #10,%d3
	divu.l %d3,%d0
	btst #0,%d0
	jeq .L1773
	clr.b %d3
.L1605:
	mvz.b k44+24,%d0
	cmp.l %d2,%d0
	jne .L1606
	tst.l %d2
	jeq .L1607
	mvz.b k44+25,%d1
	mvz.b %d3,%d0
	cmp.l %d1,%d0
	jeq .L1607
.L1606:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1608
	addq.l #1,st+1018
.L1607:
	jsr flush
	move.b pc+79,%d2
	move.l pc_seq,%d1
	lea pc,%a2
	tst.b %d2
	jne .L1611
	btst #0,%d1
	jne .L1612
	cmp.l pc+72.l,%d1
	jeq .L1612
	clr.l %d0
	lea pc_req,%a0
	lea (-140,%fp),%a3
.L1613:
	lea (%a0,%d0.l),%a1
	mov3q.l #6,%d3
	move.b (%a1),(%a3,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d3
	jne .L1613
	cmp.l pc_seq.l,%d1
	jne .L1612
	move.b -140(%fp),%d4
	move.w pc+82,%d0
	moveq #127,%d5
	move.l %d1,pc+72
	moveq #11,%d6
	mvz.b %d4,%d3
	addq.l #1,%d0
	move.w %d0,pc+82
	move.b %d5,pc+77
	cmp.l %d3,%d6
	jlt .L1615
	jsr 1075320104
	move.l %d0,-(%sp)
	jsr 1073963888
	addq.l #4,%sp
	tst.l %d0
	jne .L1616
.L1615:
	moveq #3,%d2
.L1617:
	move.b %d2,pc+78
	mvz.b %d2,%d2
	moveq #1,%d1
	move.b %d4,pc+76
	add.l #42,%d2
	move.w (%a2,%d2.l*2),%d0
	move.b %d1,pc+79
	addq.l #1,%d0
	move.w %d0,(%a2,%d2.l*2)
.L1611:
	moveq #-9,%d0
	move.w #10242,%d3
	lea pc+76,%a0
	lea pc+78,%a1
	move.w (%a0),-134(%fp)
	move.b (%a1),-132(%fp)
	pea 10.w
	move.l #-260222380,%d2
	pea -140(%fp)
	move.l %d2,-140(%fp)
	move.w %d3,-136(%fp)
	move.b %d0,-131(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1612
	move.w pc+92,%d0
	clr.b %d1
	addq.l #1,%d0
	move.b %d1,pc+79
	move.w %d0,pc+92
.L1612:
	move.b st+992,%d0
	move.b st+161,%d1
	or.l %d1,%d0
	tst.b %d0
	jne .L1632
	jsr mr_tick
	tst.l %d0
	jeq .L1632
	jsr sv_flush
	jsr arp_tick
.L1632:
	tst.l st
	jne .L1478
.L1633:
	mvz.b cu+9,%d2
	tst.l %d2
	jeq .L1661
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
	jeq .L1662
	move.l st+8,%d0
	mov3q.l #4,%d3
	sub.l cu+16,%d0
	cmp.l %d0,%d3
	jcc .L1661
.L1666:
	clr.b %d4
	move.b %d4,cu+9
.L1661:
	tst.l st
	jeq .L1667
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L1668
	tst.l st+968
	jeq .L1668
	move.l dp,%d0
	move.b 1093765506,%d2
	tst.l %d0
	jeq .L1669
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
	jeq .L1671
	clr.l dp
.L1669:
	tst.b k44+20.l
	jeq .L1672
	move.l k44+20,%d0
	and.l #16776960,%d0
	tst.l %d0
	jne .L1672
	tst.l st+4
	jeq .L1673
	tst.l st+1058
	jne .L1672
.L1673:
	move.l st+8,%d0
	sub.l k44,%d0
	lsr.l #3,%d0
	jeq .L1672
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	or.l ov_list,%d0
	jne .L1672
	tst.l st+4
	sne %d0
	move.w #257,%d7
	neg.l %d0
	move.b %d0,k44+26
	move.w %d7,k44+22
.L1672:
	move.b k44+23,%d0
	jeq .L1674
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
	jeq .L1671
	mvz.b k44+23,%d0
	tst.b k44+26.l
	jeq .L1677
	mov3q.l #1,%d4
	cmp.l %d0,%d4
	jne .L1678
	addq.l #1,k44+28
.L1679:
	clr.b %d0
	move.b %d0,k44+23
.L1674:
	mvz.b %d2,%d1
	moveq #11,%d3
	cmp.l %d1,%d3
	jcs .L1671
	move.b %d2,%d4
	moveq #127,%d0
	and.l -2147457096,%d0
	ext.w %d4
	mulu.w #2531,%d0
	mulu.w #152,%d4
	move.l %d0,%a0
	move.l st+968,%d0
	add.l %d4,%a0
	add.l #1092966773,%a0
	move.b (%a0),%d3
	mvz.b %d3,%d5
	cmp.l dp+8.l,%d0
	jeq .L1682
	clr.b %d6
	move.l %d0,dp+8
	move.b %d6,dp+22
.L1683:
	moveq #52,%d7
	cmp.l %d5,%d7
	jcs .L1777
	move.b %d3,%d0
	move.l #1075572644,%a0
	ext.w %d0
	mvz.w %d0,%d0
	lsl.l #3,%d0
	move.l (%a0,%d0.l),%a0
.L1685:
	moveq #2,%d0
	move.w #18689,%a2
	move.l #-260222380,%a1
	move.b %d2,-133(%fp)
	move.l %a1,-140(%fp)
	move.b %d0,-134(%fp)
	moveq #127,%d0
	and.l %d3,%d0
	move.w %a2,-136(%fp)
	move.b %d0,-132(%fp)
	tst.l %a0
	jeq .L1778
	move.l %a0,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	sls %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1686:
	clr.l %d1
	lea (-140,%fp),%a1
.L1688:
	tst.l %d0
	jeq .L2081
	move.b (%a0,%d1.l),%d6
	move.l %d6,%d7
	subq.l #1,%d7
	mvz.b %d7,%d7
	move.l %d7,%a2
	moveq #125,%d7
	cmp.l %a2,%d7
	jcs .L1780
.L1687:
	move.b %d6,9(%a1,%d1.l)
	addq.l #1,%d1
	moveq #12,%d6
	cmp.l %d1,%d6
	jne .L1688
	moveq #-9,%d7
	pea 22.w
	move.l %a1,-(%sp)
	move.b %d7,-119(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1671
	move.w #257,%a0
	move.b %d2,dp+20
	move.b %d3,dp+21
	addq.l #1,dp+12
	move.w %a0,dp+22
	jra .L1684
.L1484:
	move.l st+4,%d0
	tst.l %d0
	jeq .L1482
	moveq #10,%d5
	move.l %d5,st+956
	jra .L1485
.L1482:
	move.l st+960,%d3
	move.l %d3,%d1
	subq.l #1,%d1
	lsr.l #1,%d1
	jne .L1486
	moveq #20,%d1
	moveq #20,%d5
	muls.l %d3,%d1
	cmp.l %d1,%d5
	seq %d1
	neg.l %d1
	tst.b %d1
	jeq .L1487
	moveq #30,%d1
.L1488:
	cmp.l %d1,%d0
	jne .L1486
	cmp.l st+964.l,%d2
	jne .L1489
	moveq #1,%d6
	move.w #4095,%d7
	addq.l #1,%d3
	move.l %d3,st+960
	move.b %d6,st+992
	move.b %d6,mr+13
	move.b %d6,mr+19
	move.w %d7,ar+60
.L1490:
	tst.b sv.l
	jeq .L1491
	moveq #1,%d0
	move.w #257,%a1
	lea sv+1,%a0
	move.b (%a0),sv+5
	move.b %d0,sv+4
	move.w %a1,sv+6
	jra .L1491
.L1487:
	moveq #50,%d1
	jra .L1488
.L1489:
	mov3q.l #3,st+960
	jra .L1486
.L1481:
	tst.l %d0
	jeq .L1492
	addq.l #1,pmo+72
.L1492:
	clr.b %d0
	clr.l qp+4
	lea qp+56,%a0
	lea qp+92,%a1
	move.l (%a0),qp+60
	clr.l st+956
	move.l (%a1),qp+96
	clr.l ls_host_presets
	clr.l st+960
	clr.l qp+100
	clr.l fk_claim
	move.b %d0,st+992
	tst.l sq
	jeq .L1491
	jsr sq_forget
	jra .L1491
.L1495:
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr splash_end
	addq.l #8,%sp
	jra .L1493
.L1496:
	tst.l st+972
	jne .L1497
	mov3q.l #1,st+972
	addq.l #1,st+980
	mov3q.l #-1,st+20
	clr.l st+12
	mov3q.l #1,st+344
.L1497:
	move.l %d0,st+976
.L1498:
	tst.l st+972
	jeq .L1500
	cmp.l st+16.l,%d2
	jeq .L1501
	clr.l st+12
.L1502:
	move.l st+976,%d0
	subq.l #1,%d0
	move.l %d0,st+976
	tst.l %d0
	jne .L1500
	mov3q.l #1,-(%sp)
	jra .L2079
.L1499:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d3
	cmp.l %d0,%d3
	jcc .L1500
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	clr.l mask_set
.L2078:
	addq.l #8,%sp
	jra .L1500
.L1501:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d4
	cmp.l %d0,%d4
	jcc .L1502
	mov3q.l #3,-(%sp)
.L2079:
	move.l %a2,-(%sp)
	jsr splash_end
	jra .L2078
.L1515:
	tst.b sv.l
	jeq .L1513
	tst.b sv+8.l
	jeq .L1513
	mvz.b sv+1,%d2
	mvz.b (%a1),%d1
	cmp.l %d2,%d1
	jne .L1513
	mvz.b sv+2,%d1
	cmp.l %d0,%d1
	jne .L1513
	clr.l -(%sp)
	clr.l -(%sp)
	jsr ls_enc
	addq.l #8,%sp
	tst.l %d0
	jeq .L1513
	clr.l u46+8
	addq.l #1,u46+28
	jra .L1513
.L1518:
	mvz.b %d2,%d2
	move.l %d2,-(%sp)
	clr.l -(%sp)
	move.l %a2,-(%sp)
	jsr enter
	lea (12,%sp),%sp
	addq.l #1,pm+12
.L1516:
	tst.l st+4
	jne .L1519
.L1520:
	tst.l st+1058
	jne .L1521
.L1522:
	tst.l st+4
	jeq .L1524
.L1528:
	tst.l st+1058
	jne .L1529
	move.l commits,%d2
	cmp.l st+20.l,%d2
	jne .L1530
	tst.l st+344
	jeq .L1529
.L1530:
	moveq #1,%d3
	move.b %d3,32(%a2)
	jra .L1529
.L1523:
	move.l sv+88,%d0
	cmp.l #1075650164,%d0
	jeq .L1525
	move.l %d0,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jeq .L1526
.L1525:
	mov3q.l #1,st+1062
	jra .L1522
.L1526:
	tst.l st+1062
	jne .L1527
	move.l st+8,%d0
	moveq #20,%d1
	sub.l st+1066,%d0
	cmp.l %d0,%d1
	jcc .L1522
.L1527:
	clr.l st+1058
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
	jra .L1522
.L1539:
	mvz.b %d2,%d2
	lea sq_grid,%a2
	moveq #11,%d0
	cmp.l %d2,%d0
	jcs .L1541
	move.l sq+4,%d0
	btst %d2,%d0
	jne .L1542
.L1541:
	clr.l %d0
.L1543:
	cmp.l sq+408.l,%d0
	jne .L1544
	tst.l %d0
	jeq .L1545
	cmp.l sq+412.l,%d2
	jeq .L1545
.L1544:
	mov3q.l #1,%d1
	or.l %d1,sq+404
	move.l %d0,sq+408
	move.l %d2,sq+412
.L1545:
	move.b 1093615249,%d0
	move.b 1093615250,%d2
	moveq #127,%d3
	move.b 1079807236,%d1
	and.l %d3,%d1
	move.l sq+360,%d3
	btst #8,%d3
	jeq .L1546
	move.l %d1,%d0
	moveq #127,%d1
	and.l %d3,%d1
.L1547:
	cmp.l %d1,%d0
	jeq .L1765
.L1548:
	cmp.l sq+420.l,%d1
	jne .L1549
	cmp.l sq+424.l,%d0
	jeq .L1550
.L1549:
	mov3q.l #4,%d5
	or.l %d5,sq+404
	move.l %d1,sq+420
	move.l %d0,sq+424
.L1550:
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
	jne .L1551
	cmp.l sq+432.l,%d0
	jeq .L1552
.L1551:
	moveq #16,%d6
	or.l %d6,sq+404
	move.l %d2,sq+428
	move.l %d0,sq+432
.L1552:
	move.l 1076395164,%d0
	and.l #2097151,%d0
	cmp.l sq+436.l,%d0
	jeq .L1553
	moveq #32,%d7
	or.l %d7,sq+404
	move.l %d0,sq+436
.L1553:
	move.b 1081877443,%d0
	mvz.b 1081877444,%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #8191,%d0
	cmp.l sq+440.l,%d0
	jeq .L1554
	move.l %d0,sq+440
	moveq #8,%d0
	or.l %d0,sq+404
.L1554:
	move.b 1081877445,%d0
	mvz.b 1081877446,%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #8191,%d0
	cmp.l sq+552.l,%d0
	jeq .L1555
	mvz.w #128,%d1
	move.l %d0,sq+552
	or.l %d1,sq+404
.L1555:
	mov3q.l #1,%d3
	move.l 1079807120,%d2
	cmp.l %d2,%d3
	jne .L1556
	move.l st+8,%d0
	moveq #19,%d4
	sub.l sq+444,%d0
	cmp.l %d0,%d4
	jcc .L1556
	moveq #64,%d5
	or.l %d5,sq+404
.L1556:
	move.l sq+404,%d0
	btst #0,%d0
	jeq .L1557
	move.l sq+408,%d0
	move.b %d0,-140(%fp)
	tst.l %d0
	jeq .L1766
	move.b sq+415,%d0
.L1558:
	mov3q.l #2,-(%sp)
	pea -140(%fp)
	pea 8.w
	move.b %d0,-139(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1540
	moveq #-2,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1557:
	btst #1,%d0
	jeq .L1559
	mov3q.l #2,%d6
	cmp.l %d2,%d6
	jcc .L1767
	clr.l %d0
.L1560:
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
	jeq .L1540
	moveq #-3,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1559:
	move.w %d0,%ccr
	jne .L1561
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
	jeq .L1540
	moveq #-5,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1561:
	move.w %d0,%ccr
	jpl .L1562
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
	jeq .L1540
	moveq #-9,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1562:
	tst.b %d0
	jpl .L1563
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
	jeq .L1540
	move.l sq+404,%d0
	bclr #7,%d0
	move.l %d0,sq+404
.L1563:
	btst #4,%d0
	jeq .L1564
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
	jeq .L1540
	moveq #-17,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1564:
	btst #5,%d0
	jeq .L1565
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
	jeq .L1540
	moveq #-33,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L1565:
	btst #6,%d0
	jeq .L1566
	move.l 1100784300,-(%sp)
	move.l %fp,%d3
	add.l #-140,%d3
	move.l %d3,-(%sp)
	jsr blk4
	addq.l #8,%sp
	mov3q.l #2,%d5
	cmp.l %d2,%d5
	jcc .L1567
	clr.l %d2
.L1567:
	move.b %d2,-136(%fp)
	moveq #127,%d6
	move.w 1079807124,%d0
	subq.l #1,%d0
	and.l %d6,%d0
	move.b %d0,-135(%fp)
	move.l sq+380,%d0
	cmp.l %d0,%d6
	jcc .L1568
	moveq #127,%d0
.L1568:
	mov3q.l #7,-(%sp)
	move.l %d3,-(%sp)
	pea 9.w
	move.b %d0,-134(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1540
	moveq #-65,%d7
	and.l %d7,sq+404
	lea st+8,%a0
	move.l (%a0),sq+444
.L1566:
	move.l sq+360,%d0
	btst #8,%d0
	jeq .L1569
	moveq #127,%d1
	and.l %d1,%d0
.L1570:
	move.l #85760,%d3
	clr.l %d1
	muls.l %d3,%d0
	move.l ed+96,%d4
	move.l #85685,%d7
	lea ed,%a3
	lea ed+100,%a1
	move.l %d4,-156(%fp)
	move.l #85686,%a5
	move.l %a3,%a4
	move.l %d0,%a2
	move.l %d0,%a0
	add.l #1081989347,%a2
	add.l #1081990056,%a0
.L1576:
	move.l #85689,%d5
	moveq #12,%d0
	mvz.b (%a2,%d5.l),%d4
	cmp.l %d1,%d0
	jeq .L1571
	mvz.b (%a0),%d0
	move.b 2(%a0),%d3
.L1572:
	mvz.b %d3,%d3
	cmp.l (%a1),%d0
	jne .L1573
	cmp.l 52(%a1),%d3
	jne .L1573
	cmp.l 104(%a1),%d4
	jne .L1573
	moveq #12,%d2
	cmp.l %d1,%d2
	jne .L1574
	move.l #85685,%d2
	move.b (%a2,%d2.l),%d2
	move.l #85686,%d5
	mvz.b (%a2,%d5.l),%d5
	mvz.b %d2,%d2
	lsl.l #8,%d2
	or.l %d5,%d2
	cmp.l ed+256.l,%d2
	jeq .L1574
.L1573:
	move.l %d0,(%a1)
	moveq #12,%d0
	move.l %d3,52(%a1)
	move.l %d4,104(%a1)
	cmp.l %d1,%d0
	jne .L1575
	move.b (%a2,%d7.l),%d0
	mvz.b (%a2,%a5.l),%d2
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d2,%d0
	move.l %d0,ed+256
.L1575:
	tst.l -156(%fp)
	jeq .L1574
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	or.l %d0,ed+260
.L1574:
	addq.l #1,%d1
	addq.l #4,%a1
	lea (917,%a0),%a0
	moveq #13,%d2
	cmp.l %d1,%d2
	jne .L1576
	mov3q.l #1,ed+96
	tst.b dk_off.l
	jne .L1577
	move.b 1079807236,%d1
	moveq #127,%d3
	move.l #85760,%d0
	and.l %d3,%d1
	muls.l %d1,%d0
	move.l %d0,%a1
	add.l #1081989344,%a1
	mvz.w #21441,%d0
	cmp.l ed+272.l,%d1
	jeq .L1578
	move.l %d1,ed+272
	clr.l ed+268
	clr.l ed+372
.L1578:
	move.l ed+268,%d2
	move.l %d2,%d3
	addq.l #1,%d3
	move.l %d3,%d1
	moveq #10,%d4
	lsl.l %d4,%d1
	cmp.l %d0,%d1
	jls .L1768
	move.l %d2,%d1
	move.l %d0,%d5
	lsl.l %d4,%d1
	sub.l %d1,%d5
.L1579:
	move.l %d2,%d1
	moveq #12,%d6
	lsl.l %d6,%d1
	clr.l %d4
	add.l %d1,%a1
	clr.l %d1
.L1580:
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
	jne .L1580
	move.l ed+372,%d4
	move.l %d2,%a0
	lea (69,%a0),%a0
	btst %d2,%d4
	jeq .L1581
	cmp.l (%a4,%a0.l*4),%d1
	jeq .L1581
	mov3q.l #1,ed+376
.L1581:
	move.l %d1,(%a4,%a0.l*4)
	mov3q.l #1,%d1
	add.l #1023,%d0
	lsl.l %d2,%d1
	or.l %d4,%d1
	move.l %d1,ed+372
	moveq #10,%d1
	lsr.l %d1,%d0
	cmp.l %d3,%d0
	jhi .L1582
	clr.l %d3
.L1582:
	move.l %d3,ed+268
	tst.b dk_arm.l
	jeq .L1577
	tst.l %d3
	jne .L1577
	clr.b %d2
	mov3q.l #1,ed+376
	move.l st+8,%d3
	subq.l #4,%d3
	move.l %d3,ed+380
	move.b %d2,dk_arm
.L1577:
	move.l %fp,%d3
	clr.l %d2
	add.l #-148,%d3
.L1587:
	move.l ed+260,%d0
	btst %d2,%d0
	jeq .L1583
	moveq #12,%d5
	cmp.l %d2,%d5
	jne .L1769
	moveq #127,%d0
.L1584:
	move.b %d0,-148(%fp)
	move.l 100(%a3),%d0
	moveq #127,%d1
	moveq #127,%d6
	moveq #127,%d7
	and.l %d0,%d1
	lsr.l #7,%d0
	and.l %d6,%d0
	move.b %d1,-147(%fp)
	moveq #127,%d1
	move.b %d0,-146(%fp)
	moveq #127,%d0
	and.l 152(%a3),%d0
	move.b %d0,-145(%fp)
	moveq #127,%d0
	and.l 204(%a3),%d0
	move.b %d0,-144(%fp)
	move.l ed+256,%d0
	and.l %d0,%d1
	lsr.l #7,%d0
	and.l %d7,%d0
	move.b %d1,-143(%fp)
	move.b %d0,-142(%fp)
	moveq #12,%d0
	cmp.l %d2,%d0
	jeq .L1770
	mov3q.l #5,%d0
.L1585:
	move.l %d0,-(%sp)
	move.l %d3,-(%sp)
	mov3q.l #4,-(%sp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1540
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	addq.l #1,ed+264
	not.l %d0
	and.l %d0,ed+260
.L1583:
	addq.l #1,%d2
	addq.l #4,%a3
	moveq #13,%d1
	cmp.l %d2,%d1
	jne .L1587
.L1588:
	move.l ed+68,%d0
	cmp.l ed+64.l,%d0
	jne .L1589
	tst.l ed+92
	jeq .L1590
	lea ed+91,%a0
	move.b (%a0),-148(%fp)
	mov3q.l #1,-(%sp)
	pea -148(%fp)
	pea 12.w
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1540
	clr.l ed+92
.L1590:
	tst.l ed+376
	jeq .L1540
	tst.b dk_arm.l
	jne .L1540
	move.l st+8,%d0
	sub.l ed+380,%d0
	lsr.l #2,%d0
	jeq .L1540
	move.b 1079807236,%d0
	moveq #127,%d2
	mov3q.l #1,-(%sp)
	pea -148(%fp)
	pea 11.w
	and.l %d2,%d0
	move.b %d0,-148(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1540
	lea st+8,%a0
	clr.l ed+376
	move.l (%a0),ed+380
	addq.l #1,ed+384
	jra .L1540
.L1542:
	jsr (%a2)
	jra .L1543
.L1546:
	mvz.b %d0,%d0
	mvz.b %d2,%d2
	moveq #127,%d4
	lsl.l #8,%d0
	or.l %d2,%d0
	cmp.l %d0,%d4
	jge .L1547
.L1765:
	moveq #127,%d0
	jra .L1548
.L1766:
	moveq #127,%d0
	jra .L1558
.L1767:
	move.l %d2,%d0
	jra .L1560
.L1569:
	move.b 1079807236,%d0
	moveq #127,%d2
	and.l %d2,%d0
	jra .L1570
.L1571:
	move.l #85683,%d2
	move.b (%a2,%d2.l),%d0
	move.l #85684,%d3
	move.l #85690,%d5
	mvz.b (%a2,%d3.l),%d2
	move.b (%a2,%d5.l),%d3
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d2,%d0
	jra .L1572
.L1768:
	mvz.w #1024,%d5
	jra .L1579
.L1769:
	move.l %d2,%d0
	jra .L1584
.L1770:
	mov3q.l #7,%d0
	jra .L1585
.L1589:
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
	jeq .L1540
	addq.l #1,ed+68
	addq.l #1,ed+76
	jra .L1588
.L1771:
	clr.l %d0
	lea sq+480,%a0
	lea ovp_col,%a1
.L1597:
	btst %d0,%d2
	jeq .L1598
	lea (%a0,%d0.l),%a2
	move.b (%a2),(%a1,%d0.l)
.L1598:
	addq.l #1,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L1597
	move.l %d3,%d4
	clr.l %d3
	move.b %d2,ovp_on
	or.l %d2,%d4
	lea shp,%a2
	lea sq+480,%a4
	lea (-140,%fp),%a3
	lea rui_uart_raw,%a5
.L1603:
	btst %d3,%d4
	jeq .L1599
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
.L1602:
	tst.l %d0
	jeq .L1600
	move.b (%a4,%d3.l),%d1
.L1601:
	move.b %d1,2(%a3,%a0.l)
	addq.l #1,%a0
	mov3q.l #4,%d7
	cmp.l %a0,%d7
	jne .L1602
	move.l %a3,-(%sp)
	mov3q.l #6,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
.L1599:
	addq.l #1,%d3
	addq.l #4,%a2
	mov3q.l #4,%d0
	cmp.l %d3,%d0
	jne .L1603
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.l sq+476
	addq.l #4,%sp
	jra .L1596
.L1600:
	move.b (%a2,%a0.l),%d1
	jra .L1601
.L1772:
	clr.l %d2
	jra .L1604
.L1773:
	moveq #111,%d3
	jra .L1605
.L1608:
	move.b %d3,ovt_col
	move.b %d2,%d4
	move.b %d2,ovt_on
	lea led_send4,%a0
	tst.l %d2
	jeq .L1609
	move.b %d3,-137(%fp)
	move.b %d3,-138(%fp)
	move.b %d3,-139(%fp)
	move.b %d3,-140(%fp)
	pea -140(%fp)
	pea 55.w
	jsr (%a0)
	addq.l #1,k44+12
.L2080:
	addq.l #4,%sp
	move.l #1100088672,(%sp)
	jsr 1073746414
	addq.l #4,%sp
	move.b %d4,k44+24
	move.b %d3,k44+25
	jra .L1607
.L1609:
	pea sht
	pea 55.w
	jsr (%a0)
	addq.l #1,k44+16
	jra .L2080
.L1616:
	move.b %d4,%d6
	moveq #127,%d0
	moveq #127,%d7
	and.l -2147457096,%d0
	ext.w %d6
	mulu.w #2531,%d0
	move.w %d6,%d1
	move.l %d0,%a0
	mulu.w #152,%d1
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d0
	move.l %d0,-(%sp)
	move.l %d3,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	mvz.b %d0,%d0
	cmp.l %d0,%d7
	jeq .L1615
	tst.b 60(%a2,%d3.l)
	jeq .L1618
	move.l st+8,%d0
	moveq #20,%d1
	sub.l (%a2,%d3.l*4),%d0
	cmp.l %d0,%d1
	jcc .L1619
.L1618:
	moveq #1,%d2
	jra .L1617
.L1619:
	lea 48(%a2,%d3.l),%a0
	move.b (%a0),77(%a2)
	jsr 1075312702
	move.l %d0,-(%sp)
	jsr 1074458688
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	jsr 1074442802
	lea (12,%sp),%sp
	move.l %d0,%a4
	move.l 44(%a4),%a5
	tst.l %a5
	jeq .L1615
	move.l (%a5),%a0
	move.l %a5,-(%sp)
	move.l 40(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l 32(%a5),%d1
	move.l %d0,%d3
	tst.l %d1
	jeq .L1620
	move.l %d1,%d5
	move.l %d1,%a0
	add.l #4752,%d5
	clr.l %d0
.L1624:
	mvz.b (%a0),%d7
	cmp.l #255,%d7
	jeq .L1622
	mvz.b 1(%a0),%d7
	cmp.l #255,%d7
	jeq .L1622
	addq.l #1,%d0
.L1622:
	lea (66,%a0),%a0
	cmp.l %d5,%a0
	jne .L1624
	mulu.w #5674,%d6
	move.l %d3,%a5
	move.l #1075599904,%a1
	add.l %d6,%a5
	mvz.b %d4,%d6
	move.l %d6,-160(%fp)
.L1629:
	mvz.b 3(%a1),%d7
	move.l %d1,%a0
.L1627:
	mvz.b (%a0),%d6
	cmp.l %d6,%d7
	jne .L1625
	mvz.b 1(%a0),%d6
	cmp.l -160(%fp),%d6
	jeq .L1626
.L1625:
	lea (66,%a0),%a0
	cmp.l %d5,%a0
	jne .L1627
	tst.b 5653(%a5)
	jne .L1762
	mov3q.l #1,%a0
	jra .L1763
.L1762:
	mov3q.l #2,%a0
.L1763:
	add.l %a0,%d0
	moveq #71,%d7
	cmp.l %d0,%d7
	jlt .L1774
.L1626:
	addq.l #4,%a1
	addq.l #1,%a5
	cmp.l #1075599920,%a1
	jne .L1629
.L1620:
	mvz.b -139(%fp),%d0
	moveq #21,%d5
	move.l %d0,-(%sp)
	mvz.b pc+77,%d0
	move.l %d0,-(%sp)
	move.l %a4,-(%sp)
	jsr 1074530058
	move.b %d4,%d0
	lea (12,%sp),%sp
	ext.w %d0
	mulu.w #5674,%d0
	add.l %d0,%d3
	move.l %d3,%a5
	lea (5632,%a5),%a5
.L1630:
	tst.b (%a5,%d5.l)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	move.l %d0,-(%sp)
	mvz.b -19(%a3,%d5.l),%d0
	lsl.l #8,%d0
	move.l %d0,-(%sp)
	mvz.b pc+77,%d0
	move.l %d5,-(%sp)
	addq.l #1,%d5
	move.l %d0,-(%sp)
	move.l %a4,-(%sp)
	jsr 1074529568
	lea (20,%sp),%sp
	moveq #25,%d0
	cmp.l %d5,%d0
	jne .L1630
	jra .L1617
.L1774:
	moveq #2,%d2
	jra .L1617
.L1637:
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
	jeq .L1633
	move.l ux+3944,%d1
	mov3q.l #1,%d0
	lea ux+3920,%a0
.L1634:
	cmp.l %d0,%d1
	jhi .L1635
	subq.l #1,%d1
	move.l %d1,ux+3944
	addq.l #1,ux+32
.L1636:
	tst.l ux+3944
	jne .L1637
.L1638:
	move.l ux+3880,%d1
	cmp.l ux+3884.l,%d1
	jeq .L1633
	mov3q.l #7,%d2
	cmp.l ux+3944.l,%d2
	jcs .L1633
	mov3q.l #7,%d0
	and.l ux+3884,%d0
	lsl.l #2,%d0
	move.l %d0,%a2
	moveq #127,%d0
	and.l -2147457096,%d0
	add.l #ux+3888,%a2
	move.b (%a2),%d7
	move.b 1(%a2),%d6
	mulu.w #2531,%d0
	mvz.b %d7,%d3
	mvz.b %d6,%d2
	move.l %d0,%a0
	add.l #1092966773,%a0
	move.w %d3,%d0
	mulu.w #152,%d0
	move.b (%a0,%d0.l),%d0
	mvz.b %d0,%d4
	move.w %d0,%a3
	move.l %d4,%a5
	move.l %d2,%d4
	move.l %a5,-(%sp)
	add.l #9,%d4
	move.l %d4,-(%sp)
	move.l %d2,-164(%fp)
	jsr 1073770536
	addq.l #8,%sp
	move.l ux+3884,%a0
	move.l -164(%fp),%a1
	move.l %d0,%a4
	tst.l %d0
	jle .L1775
	mvz.b 2(%a2),%d2
	mvz.b 3(%a2),%d0
	lsl.l #8,%d2
	add.l %d0,%d0
	or.l %d0,%d2
	mov3q.l #7,%d0
	cmp.l %a1,%d0
	jlt .L1640
	move.l %a3,%d0
	add.l #-46,%d0
	mvz.b %d0,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jcc .L1641
	moveq #52,%d0
	cmp.l %a5,%d0
	jne .L1642
.L1641:
	cmp.l 1075595760.l,%a5
	jne .L1643
.L1642:
	tst.l %a1
	jne .L1645
.L1646:
	move.l %a0,%d1
	mov3q.l #7,%d0
	and.l %d0,%d1
	move.l %d5,%a0
	add.l %d1,%a0
	move.b 3952(%a0),%d0
	btst #0,%d0
	jeq .L1645
	move.l ls+60,%d0
	or.l ls+64,%d0
	jeq .L1645
	cmp.l ls+68.l,%d3
	jne .L1645
	move.l st+8,%d0
	moveq #20,%d1
	sub.l ls+72,%d0
	cmp.l %d0,%d1
	jcs .L1645
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
	jeq .L1645
	move.l (%a5),%a0
	move.l %a5,-(%sp)
	move.l 40(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l 32(%a5),%d0
	tst.l %d0
	jeq .L1647
	move.l %d0,%a0
	add.l #4753,%d0
	move.l %d0,-156(%fp)
	move.w %a3,%d0
	addq.l #1,%a0
	sub.l %a4,%a4
	sub.l %a1,%a1
	mvz.b %d0,%d0
	move.l %d0,%a3
.L1652:
	mvz.b -1(%a0),%d1
	cmp.l #255,%d1
	jeq .L1649
	mvz.b (%a0),%d0
	cmp.l #255,%d0
	jeq .L1649
	addq.l #1,%a1
.L1649:
	cmp.l %d1,%a3
	jne .L1651
	mvz.b (%a0),%d1
	move.l %a4,%d0
	cmp.l %d1,%d3
	seq %d1
	mvs.b %d1,%d1
	neg.l %d1
	or.l %d1,%d0
	move.l %d0,%a4
.L1651:
	lea (66,%a0),%a0
	cmp.l -156(%fp),%a0
	jne .L1652
	tst.l %a4
	jne .L1647
	moveq #69,%d1
	cmp.l %a1,%d1
	jge .L1647
	moveq #3,%d0
	addq.l #1,ux+3964
.L1639:
	addq.l #1,ux+24
	jra .L1659
.L1635:
	addq.l #3,%a0
	move.b (%a0),-3(%a0)
	move.b 1(%a0),-2(%a0)
	move.b 2(%a0),-1(%a0)
	addq.l #1,%d0
	jra .L1634
.L1640:
	move.l %a5,%d0
	mov3q.l #2,%d1
	add.l #-48,%d0
	cmp.l %d0,%d1
	jcs .L1644
	mvz.b cu+1,%d0
	cmp.l %a5,%d0
	jne .L1643
.L1645:
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
	jra .L1659
.L1644:
	moveq #10,%d0
	cmp.l %a1,%d0
	jne .L1645
	moveq #45,%d1
	cmp.l %a5,%d1
	jeq .L1646
	moveq #43,%d0
	cmp.l %a5,%d0
	jeq .L1646
	jra .L1645
.L1647:
	move.l %a2,-(%sp)
	moveq #64,%d3
	jsr 1074529464
	addq.l #4,%sp
	move.l %d0,%a3
	cmp.l %d0,%d3
	jge .L1653
	move.w #64,%a3
.L1653:
	clr.l %d3
.L1654:
	cmp.l %a3,%d3
	jlt .L1658
	moveq #4,%d0
	clr.l ls+64
	clr.l ls+60
	addq.l #1,ux+3960
.L1659:
	move.l ux+3944,%a0
	lea (%a0,%a0.l*2),%a1
	addq.l #1,%a0
	move.l %a0,ux+3944
	addq.l #1,ux+3884
	add.l %d5,%a1
	move.b %d7,3920(%a1)
	move.b %d6,3921(%a1)
	move.b %d0,3922(%a1)
	jra .L1638
.L1658:
	moveq #31,%d0
	cmp.l %d3,%d0
	jlt .L1655
	move.l ls+60,%d1
	lsr.l %d3,%d1
.L1656:
	btst #0,%d1
	jeq .L1657
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	move.l %d4,-(%sp)
	move.l %d3,-(%sp)
	move.l %a2,-(%sp)
	jsr 1074529568
	lea (20,%sp),%sp
	addq.l #1,ls+96
.L1657:
	addq.l #1,%d3
	jra .L1654
.L1655:
	move.l %d3,%d0
	add.l #-32,%d0
	move.l ls+64,%d1
	lsr.l %d0,%d1
	jra .L1656
.L1643:
	moveq #1,%d0
	jra .L1639
.L1775:
	moveq #2,%d0
	jra .L1639
.L1662:
	move.l #1075731444,%d5
	cmp.l sv+88.l,%d5
	jeq .L1661
	move.l st+8,%d0
	sub.l cu+16,%d0
	lsr.l #1,%d0
	jeq .L1661
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	move.l %d0,%a2
	tst.l %d0
	jeq .L1661
	move.l %d2,-(%sp)
	moveq #8,%d3
	jsr cu_setup
	lea (11,%a2),%a2
	addq.l #4,%sp
.L1665:
	move.l %d3,%a3
	move.l %d2,-(%sp)
	lea (9,%a3),%a3
	move.l %a3,-(%sp)
	jsr 1073770536
	addq.l #8,%sp
	move.l %d0,%d5
	tst.l %d0
	jle .L1663
	moveq #43,%d0
	cmp.l %d2,%d0
	jne .L1664
	moveq #10,%d1
	cmp.l %d3,%d1
	jne .L1664
	mvz.b cu+29,%d0
	moveq #45,%d7
	cmp.l %d0,%d7
	jeq .L1663
	moveq #43,%d1
	cmp.l %d0,%d1
	jeq .L1663
.L1664:
	mvz.b (%a2),%d7
	move.l %a3,-(%sp)
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
.L1663:
	addq.l #1,%d3
	lea (16,%a2),%a2
	moveq #16,%d5
	cmp.l %d3,%d5
	jne .L1665
	addq.l #1,cu+20
	moveq #50,%d6
	cmp.l %d2,%d6
	jne .L1666
	addq.l #1,%d4
	lea st+8,%a0
	move.b %d4,cu+11
	move.l (%a0),cu+24
	jra .L1666
.L1678:
	addq.l #1,k44+32
.L1680:
	subq.l #2,%d0
	tst.l %d0
	jne .L1679
	clr.b %d7
	move.b %d7,k44+26
	jra .L1679
.L1677:
	mov3q.l #1,%d5
	cmp.l %d0,%d5
	jne .L1681
	addq.l #1,k44+4
	jra .L1679
.L1681:
	addq.l #1,k44+8
	jra .L1680
.L1682:
	tst.b dp+22.l
	jeq .L1683
	mvz.b dp+20,%d0
	cmp.l %d1,%d0
	jne .L1683
	mvz.b dp+21,%d0
	cmp.l %d5,%d0
	jne .L1683
.L1684:
	lea dp,%a3
	sub.l %a2,%a2
	lea dp+32,%a1
	move.l %a1,-156(%fp)
	move.l %a3,%a4
.L1696:
	moveq #43,%d0
	cmp.l %d5,%d0
	jeq .L1781
	moveq #127,%d0
	moveq #127,%d1
	and.l -2147457096,%d0
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d4,%a0
	mvz.w %a2,%d0
	add.l #1092966707,%a0
	move.b (%a0,%d0.l*2),%d3
	and.l %d1,%d3
.L1689:
	move.l %d5,-(%sp)
	pea 9(%a2)
	jsr 1073770536
	addq.l #8,%sp
	tst.l %d0
	jgt .L1690
	clr.l -148(%fp)
.L1691:
	move.b -148(%fp),%d7
	move.b -147(%fp),%d0
	mvz.b %d3,%d6
	move.b -146(%fp),%d1
	move.w %d7,%a1
	mvz.b 24(%a4),%d7
	move.w %d0,%a0
	move.b -145(%fp),%d0
	cmp.l %d7,%d6
	jne .L1694
	move.l -156(%fp),%a5
	mvs.b %a1,%d6
	mvs.b (%a5),%d7
	cmp.l %d7,%d6
	jne .L1694
	mvs.b 1(%a5),%d7
	mvs.b %a0,%d6
	cmp.l %d7,%d6
	jne .L1694
	mvs.b 2(%a5),%d7
	mvs.b %d1,%d6
	cmp.l %d7,%d6
	jne .L1694
	mvs.b 3(%a5),%d7
	mvs.b %d0,%d6
	cmp.l %d7,%d6
	jeq .L1695
.L1694:
	move.b %d3,24(%a4)
	move.w %a1,%d3
	move.l -156(%fp),%a5
	moveq #1,%d6
	move.b %d1,2(%a5)
	move.b %d0,3(%a5)
	move.b %d3,(%a5)
	move.w %a0,%d3
	move.b %d3,1(%a5)
	move.b %d6,dp+23
.L1695:
	addq.l #1,%a2
	addq.l #4,-156(%fp)
	addq.l #1,%a4
	moveq #8,%d7
	cmp.l %a2,%d7
	jne .L1696
	tst.b dp+23.l
	jeq .L1671
	move.w #18689,%a1
	moveq #3,%d0
	move.b %d2,-133(%fp)
	move.l #-260222380,%a0
	move.l %fp,%d1
	add.l #-140,%d1
	move.l %a0,-140(%fp)
	lea dp+24,%a2
	move.w %a1,-136(%fp)
	move.b %d0,-134(%fp)
	move.l %d1,%a1
	moveq #9,%d0
	addq.l #8,%a1
.L1698:
	move.b (%a2)+,(%a1)
	mov3q.l #1,%a0
.L1697:
	lea 31(%a3,%a0.l),%a4
	mov3q.l #5,%d2
	move.b (%a4),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d2
	jne .L1697
	addq.l #5,%a1
	addq.l #5,%d0
	addq.l #4,%a3
	moveq #49,%d3
	cmp.l %d0,%d3
	jne .L1698
	moveq #-9,%d4
	pea 49.w
	move.l %d1,-(%sp)
	move.b %d4,-92(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1671
	clr.b %d5
	addq.l #1,dp+16
	move.b %d5,dp+23
.L1671:
	tst.l st
	jeq .L1667
.L1668:
	mov3q.l #1,%d6
	cmp.l 1094562388.l,%d6
	jne .L1667
	tst.l st+968
	jeq .L1667
	move.b 1079807565,%d2
	mvs.b %d2,%d0
	lsr.l #7,%d0
	jne .L1783
	addq.l #1,%d2
.L1699:
	move.l pj+160,%d0
	cmp.l pj+156.l,%d0
	jeq .L1703
	move.l pj+156,%d3
	sub.l %d0,%d3
	clr.l -(%sp)
	move.l %d3,%d0
	cmp.l #16383,%d3
	jls .L1701
	mvz.w #16383,%d0
.L1701:
	move.l %d0,-(%sp)
	mov3q.l #6,-(%sp)
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1733
	moveq #2,%d0
	add.l %d3,pj+160
	move.w %d0,pj+180
.L1703:
	move.l pj,%d1
	cmp.l pj+4.l,%d1
	jne .L1704
	tst.b pj+139.l
	jeq .L1705
	mvz.b pj+138,%d1
	mvz.b %d2,%d0
	cmp.l %d1,%d0
	jeq .L1706
.L1705:
	clr.l %d0
.L1707:
	move.l #1081903571,%a0
	lea pj-1081903431,%a1
.L1708:
	tst.l %d0
	jne .L1710
.L1711:
	move.l st+968,%d6
	cmp.l pj+164.l,%d6
	jeq .L1728
	moveq #2,%d7
	move.w %d7,pj+180
.L1728:
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
.L1729:
	move.l #1081903571,%a2
	add.l %a0,%a2
	tst.b (%a2)
	jeq .L1730
	move.b (%a2),%d0
	moveq #127,%d1
	moveq #15,%d3
	and.l %d1,%d0
	move.b %d0,9(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d3
	jne .L1729
.L1730:
	moveq #-9,%d4
	lea (%fp,%a0.l),%a2
	move.b %d4,-131(%a2)
	pea 10(%a0)
	move.l %a1,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1733
	moveq #1,%d5
	move.b %d2,pj+138
	lea st+968,%a0
	lea st+8,%a1
	move.l (%a0),pj+164
	move.l (%a1),pj+168
	move.l #1081903571,%a0
	lea pj-1081903431,%a1
	move.b %d5,pj+139
.L1732:
	move.b (%a0),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L1732
	addq.l #1,pj+176
	jra .L1733
.L1777:
	sub.l %a0,%a0
	jra .L1685
.L1778:
	clr.l %d0
	jra .L1686
.L1780:
	clr.l %d0
.L2081:
	clr.b %d6
	jra .L1687
.L1781:
	clr.b %d3
	jra .L1689
.L1690:
	moveq #52,%d6
	muls.l %d6,%d0
	move.l #1075575112,%a0
	move.l (%a0,%d0.l),%a1
	clr.l -148(%fp)
	move.l %a1,%d0
	sub.l %a0,%a0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L1691
.L1692:
	moveq #125,%d6
	move.b (%a1,%a0.l),%d1
	move.l %d1,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d6
	jcs .L1691
	lea (-148,%a0),%a5
	mov3q.l #4,%d0
	move.b %d1,(%a5,%fp.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L1692
	jra .L1691
.L1783:
	clr.b %d2
	jra .L1699
.L1704:
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
	jeq .L1733
	addq.l #1,pj+4
	addq.l #1,pj+172
	jra .L1703
.L1706:
	move.l st+968,%d3
	cmp.l pj+164.l,%d3
	jne .L1705
	move.l st+8,%d0
	moveq #99,%d4
	sub.l pj+168,%d0
	cmp.l %d0,%d4
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L1707
.L1710:
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
	jne .L1708
	mvz.b %d3,%d3
	mvz.b %d1,%d1
	cmp.l %d3,%d1
	jne .L1711
	tst.b pj+181.l
	jeq .L1733
	move.l 1100949640,%d0
	mov3q.l #3,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L1712
	move.l %d0,%d1
	add.l #-1073741824,%d1
	cmp.l #129892351,%d1
	jhi .L1712
	move.l %d0,%a0
	add.l #1073744908,%d1
	lea (12,%a0),%a0
	move.l %a0,%a1
.L1715:
	mvz.b (%a1),%d0
	lsr.l #1,%d0
	jeq .L1713
.L1712:
	mvz.w #16383,%d0
	clr.l %d3
.L1714:
	clr.l -(%sp)
	move.l %d0,-(%sp)
	pea 9.w
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1733
	addq.l #1,pj+184
	tst.l %d3
	jeq .L1719
	move.b pj+181,%d0
	mvz.b %d0,%d1
	lsr.l #1,%d1
	jeq .L1719
	clr.b %d7
	subq.l #1,%d0
	move.b %d0,pj+181
	move.b %d7,pj+180
.L1733:
	tst.l st
	jeq .L1737
	mov3q.l #1,%d3
	cmp.l 1094562388.l,%d3
	jne .L1738
	tst.l st+968
	jeq .L1738
	move.l st+44,%d1
	move.l txsx_over,%d0
	cmp.l kd_drop.l,%d1
	jne .L1739
	cmp.l kd_over.l,%d0
	jeq .L1740
.L1739:
	move.l st+8,%a0
	moveq #19,%d4
	sub.l kd_t,%a0
	cmp.l %a0,%d4
	jcc .L1740
	cmp.l #16383,%d1
	jls .L1741
	mvz.w #16383,%d1
.L1741:
	cmp.l #16383,%d0
	jls .L1742
	mvz.w #16383,%d0
.L1742:
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
	jeq .L1740
	lea st+44,%a0
	lea txsx_over,%a1
	lea st+8,%a2
	move.l (%a0),kd_drop
	move.l (%a1),kd_over
	move.l (%a2),kd_t
.L1740:
	tst.l st
	jeq .L1737
.L1738:
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L1743
	tst.l st+968
	jeq .L1743
	jsr 1075312702
	move.l %d0,%d2
	add.l #352,%d2
	move.l %d2,-(%sp)
	move.l %d0,%a3
	jsr 1074425250
	addq.l #4,%sp
	tst.l qp+100
	jeq .L1744
	cmp.l #4095,%d0
	jle .L1745
	mvz.w #4095,%d0
.L1746:
	move.l 352(%a3),%a0
	lea qp,%a2
	move.l %d0,(%a2)
	move.l %d2,-(%sp)
	move.l 52(%a0),%a0
	mov3q.l #1,qp+4
	jsr (%a0)
	addq.l #4,%sp
	tst.l %d0
	jeq .L1747
	move.l %d0,%a0
	moveq #11,%d0
	mvz.b 2430(%a0),%d2
	cmp.l %d2,%d0
	jcc .L1748
.L1747:
	clr.l %d2
.L1749:
	move.w #11521,%d3
	move.l #-260222380,%d1
	move.l %d1,-140(%fp)
	move.w %d3,-136(%fp)
	cmp.l qp+44.l,%d2
	jne .L1750
	tst.l qp+48
	jeq .L1751
.L1750:
	moveq #15,%d4
	moveq #-9,%d5
	pea 9.w
	pea -140(%fp)
	move.b %d2,-133(%fp)
	move.b %d4,-134(%fp)
	move.b %d5,-132(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1744
	move.l %d2,qp+44
	clr.l qp+48
	addq.l #1,qp+52
.L1751:
	move.l %fp,%d2
	add.l #-140,%d2
	jra .L1752
.L1713:
	lea (24,%a1),%a1
	cmp.l %d1,%a1
	jne .L1715
	move.b pj+180,%d0
	move.l %a0,%d3
	tst.b %d0
	jge .L1716
	clr.l %d0
.L1717:
	tst.b (%a0)
	sne %d2
	lea (24,%a0),%a0
	mvs.b %d2,%d2
	sub.l %d2,%d0
	cmp.l %d1,%a0
	jne .L1717
	jra .L1714
.L1719:
	clr.b %d0
	move.b %d0,pj+181
	jra .L1733
.L1716:
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
.L1727:
	mvz.b pj+180,%d0
	sub.l %a3,%a3
	add.l %d1,%d0
	muls.w #24,%d0
	lea (%a0,%d0.l),%a1
	tst.b (%a1)
	sne %d0
	neg.l %d0
	move.b %d0,(%a2)
.L1721:
	move.b (%a1),%d0
	jeq .L1720
	move.b 8(%a1,%a3.l),%d0
	moveq #127,%d5
	and.l %d5,%d0
.L1720:
	addq.l #1,%a3
	move.b %d0,(%a2,%a3.l)
	moveq #15,%d6
	cmp.l %a3,%d6
	jne .L1721
	sub.l %a1,%a1
.L1722:
	move.l %a1,%a3
	addq.l #1,%a1
	tst.b (%a2,%a1.l)
	jne .L1724
.L1725:
	moveq #15,%d3
	cmp.l %a3,%d3
	jeq .L1723
	clr.b %d0
	addq.l #1,%a3
	move.b %d0,(%a2,%a3.l)
	jra .L1725
.L1724:
	moveq #15,%d7
	cmp.l %a1,%d7
	jne .L1722
.L1723:
	addq.l #1,%d1
	lea (16,%a2),%a2
	moveq #8,%d4
	cmp.l %d1,%d4
	jne .L1727
	moveq #-9,%d5
	pea 139.w
	move.l %d2,-(%sp)
	move.b %d5,-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1733
	move.b pj+180,%d0
	addq.l #8,%d0
	move.b %d0,pj+180
	jra .L1733
.L1667:
	lea pj,%a0
	move.l (%a0),%d0
.L1734:
	cmp.l pj+4.l,%d0
	jeq .L1733
	moveq #31,%d1
	moveq #10,%d2
	and.l pj+4,%d1
	mvz.b 8(%a0,%d1.l*4),%d1
	cmp.l %d1,%d2
	jeq .L1735
	addq.l #1,pj+156
.L1735:
	addq.l #1,pj+4
	jra .L1734
.L1745:
	tst.l %d0
	jge .L1746
	clr.l %d0
	jra .L1746
.L1748:
	addq.l #1,%d2
	jra .L1749
.L1753:
	mov3q.l #3,%d7
	and.l %d7,%d0
	moveq #16,%d6
	lea 64(%a2,%d0.l*2),%a0
	lea 65(%a2,%d0.l*2),%a1
	moveq #-9,%d0
	move.b %d6,-134(%fp)
	move.b (%a0),-133(%fp)
	move.b (%a1),-132(%fp)
	pea 10.w
	move.l %d2,-(%sp)
	move.b %d0,-131(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1744
	addq.l #1,qp+60
.L1752:
	move.l qp+60,%d0
	cmp.l qp+56.l,%d0
	jne .L1753
	move.l qp+92,%d1
	cmp.l qp+96.l,%d1
	jeq .L1744
	move.l qp+92,%d2
	moveq #16,%d3
	move.w #503,%d4
	move.l qp+88,%d0
	pea 10.w
	pea -140(%fp)
	move.b %d0,-133(%fp)
	move.b %d3,-134(%fp)
	move.w %d4,-132(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1744
	move.l %d2,qp+96
.L1744:
	tst.l st
	jeq .L1737
.L1743:
	mov3q.l #1,%d5
	cmp.l 1094562388.l,%d5
	jne .L1737
	tst.l st+968
	jeq .L1737
	move.l pmo+64,%d2
	tst.l qp+100
	jeq .L1737
	move.w #11521,%d7
	move.l #-260222380,%d6
	move.l %d6,-140(%fp)
	move.w %d7,-136(%fp)
	cmp.l pmo+124.l,%d2
	jeq .L1755
	moveq #17,%d0
	moveq #127,%d1
	move.b %d0,-134(%fp)
	move.l pmo,%d0
	cmp.l %d0,%d1
	jcc .L1756
	moveq #127,%d0
.L1756:
	move.b %d0,-133(%fp)
	move.l pmo+4,%d0
	cmp.l #16383,%d0
	jls .L1757
	mvz.w #16383,%d0
.L1757:
	move.l %d0,%d1
	moveq #127,%d3
	and.l %d3,%d0
	lsr.l #7,%d1
	move.b %d1,-132(%fp)
	move.b %d0,-131(%fp)
	move.l pmo+8,%d0
	cmp.l #16383,%d0
	jls .L1758
	mvz.w #16383,%d0
.L1758:
	move.l %d0,%d1
	moveq #127,%d4
	and.l %d4,%d0
	lsr.l #7,%d1
	move.b %d1,-130(%fp)
	move.b %d0,-129(%fp)
	move.l pmo+12,%d0
	cmp.l %d0,%d4
	jcc .L1759
	moveq #127,%d0
.L1759:
	move.b %d0,-128(%fp)
	lea fp,%a0
	tst.l pmo+52
	jeq .L1784
	move.l (%a0),%d1
	sub.l pmo+108,%d1
	cmp.l #1499,%d1
	sls %d1
	neg.l %d1
.L1760:
	move.l (%a0),%d0
	mov3q.l #1,%d5
	moveq #-9,%d6
	pea 15.w
	sub.l pmo+112,%d0
	pea -140(%fp)
	cmp.l %d0,%d5
	scc %d0
	move.b %d6,-126(%fp)
	neg.l %d0
	add.l %d0,%d0
	or.l %d1,%d0
	move.b %d0,-127(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1737
	move.l %d2,pmo+124
.L1755:
	move.l pmo+16,%d2
	cmp.l pmo+128.l,%d2
	jeq .L1737
	move.l st+8,%d0
	moveq #19,%d7
	sub.l pmo+132,%d0
	cmp.l %d0,%d7
	jcc .L1737
	moveq #16,%d0
	move.w #759,%a1
	lea pmo+123,%a0
	move.b (%a0),-133(%fp)
	pea 10.w
	pea -140(%fp)
	move.b %d0,-134(%fp)
	move.w %a1,-132(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1737
	lea st+8,%a2
	move.l %d2,pmo+128
	move.l (%a2),pmo+132
.L1737:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l -152(%fp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L1470
	move.l %d0,st+332
.L1470:
	movem.l -204(%fp),#15612
	unlk %fp
	rts
.L1784:
	clr.b %d1
	jra .L1760
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
	jeq .L2083
	sub.l st+8,%d0
	tst.l %d0
	jgt .L2084
.L2083:
	clr.l 44(%sp)
.L2085:
	move.l 16(%a2),%a2
	move.l %a2,52(%sp)
	tst.l st+4
	jne .L2087
	tst.l st+972
	jne .L2088
	tst.b sv+8.l
	jne .L2088
	tst.l 44(%sp)
	jeq .L2090
	jra .L2122
.L2084:
	move.l %d3,%a0
	move.l %d3,%d0
	addq.l #6,%a0
	lea (108,%sp),%a1
	add.l #566,%d0
.L2086:
	move.b 1(%a0),(%a1)
	addq.l #8,%a0
	move.b -8(%a0),1(%a1)
	addq.l #2,%a1
	cmp.l %a0,%d0
	jne .L2086
	mov3q.l #1,44(%sp)
	jra .L2085
.L2087:
	tst.l st+1058
	jne .L2090
	move.l commits,%a6
	cmp.l st+24.l,%a6
	jne .L2092
	move.l 52(%sp),%a0
	move.l %a0,%d0
	add.l #1024,%d0
.L2093:
	clr.l (%a0)+
	cmp.l %a0,%d0
	jne .L2093
	move.l %a6,st+20
.L2094:
	tst.l 44(%sp)
	jeq .L2090
	tst.l st+4
	jne .L2118
	tst.l st+972
	jne .L2119
.L2122:
	tst.b sv+8.l
	jne .L2119
.L2090:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 60(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L2082
	move.l %d0,st+332
.L2082:
	movem.l (%sp),#31996
	lea (248,%sp),%sp
	rts
.L2088:
	move.l commits,%a6
.L2092:
	cmp.l st+340.l,%a6
	jne .L2095
	tst.l st+344
	jeq .L2096
.L2095:
	move.l -66650100,%d2
	move.l sh_seq,%d4
	lea copy32,%a2
	move.l %d2,64(%sp)
	btst #0,%d4
	jne .L2097
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
	jne .L2097
	pea 256.w
	pea comp_in
	pea comp
	jsr (%a2)
	lea (12,%sp),%sp
	tst.l st+872
	jne .L2098
	clr.l -(%sp)
	pea comp
	pea 64.w
	pea 128.w
	pea st+872
	jsr 1074198978
	lea (20,%sp),%sp
.L2098:
	lea (tl.0),%a2
	clr.l %d5
.L2111:
	tst.b 4(%a2)
	jeq .L2099
	move.l %a2,%d4
	clr.l %d7
	addq.l #8,%d4
	lea st+408,%a5
	lea st+552,%a0
.L2110:
	tst.l (%a5)+
	jeq .L2101
	mvz.b (%a0),%d0
	cmp.l %d0,%d5
	jne .L2101
	lea st+472,%a1
	mvz.b 5(%a0),%d1
	mvz.b (%a1,%d7.l),%d4
	lea (6,%a0),%a3
	sub.l %a1,%a1
.L2103:
	cmp.l %d1,%a1
	jlt .L2104
	move.b 4(%a0),%d0
	lea 72(%sp,%d1.l),%a3
	btst #1,%d0
	jeq .L2123
	move.l %d4,%d0
	add.l #-64,%d0
	move.l %d0,56(%sp)
	tst.l %d0
	jle .L2106
	move.b #43,(%a3)
	addq.l #1,%d1
	lea 72(%sp,%d1.l),%a3
.L2124:
	sub.l %a1,%a1
	jra .L2105
.L2104:
	lea (%a3,%a1.l),%a4
	move.b (%a4),72(%sp,%a1.l)
	addq.l #1,%a1
	jra .L2103
.L2106:
	tst.l 56(%sp)
	jeq .L2124
	move.b #45,(%a3)
	moveq #64,%d2
	mov3q.l #1,%a1
	sub.l %d4,%d2
	move.l %d2,56(%sp)
.L2105:
	lea (68,%sp),%a4
	clr.l %d4
.L2108:
	move.l 56(%sp),%d6
	moveq #10,%d0
	addq.l #1,%d4
	rems.l %d0,%d2:%d6
	divs.l %d0,%d6
	add.l #48,%d2
	move.b %d2,(%a4)
	move.l %d6,56(%sp)
	tst.l %d6
	jeq .L2107
	addq.l #1,%a4
	mov3q.l #4,%d6
	cmp.l %d4,%d6
	jne .L2108
.L2107:
	add.l %a1,%a3
	move.l %d4,%d0
.L2109:
	subq.l #1,%d0
	move.b 68(%sp,%d0.l),(%a3)+
	tst.l %d0
	jne .L2109
	mvz.w #248,%d0
	add.l %sp,%d0
	add.l %d1,%d0
	add.l %d4,%d0
	add.l %d0,%a1
	clr.b %d0
	move.l %sp,%d4
	add.l #72,%d4
	move.b %d0,-176(%a1)
.L2101:
	addq.l #1,%d7
	lea (20,%a0),%a0
	moveq #16,%d1
	cmp.l %d7,%d1
	jne .L2110
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
	jgt .L2099
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
.L2099:
	addq.l #1,%d5
	lea (44,%a2),%a2
	moveq #64,%d0
	cmp.l %d5,%d0
	jne .L2111
	move.l -66650100,%d0
	move.l %a6,st+340
	addq.l #1,st+348
	sub.l 64(%sp),%d0
	add.l %d0,st+356
	cmp.l st+360.l,%d0
	jls .L2112
	move.l %d0,st+360
.L2112:
	clr.l st+344
.L2096:
	pea 256.w
	pea comp
	move.l 60(%sp),-(%sp)
	jsr copy32
	lea (12,%sp),%sp
	cmp.l st+20.l,%a6
	jeq .L2113
	move.l -66650100,%d0
	addq.l #1,st+308
	sub.l t_commit,%d0
	add.l %d0,st+304
	cmp.l st+312.l,%d0
	jls .L2113
	move.l %d0,st+312
.L2113:
	move.l st+388,%d1
	tst.l %d1
	jeq .L2114
	cmp.l st+392.l,%a6
	jeq .L2114
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+396
	addq.l #1,st+400
	cmp.l st+404.l,%d0
	jls .L2115
	move.l %d0,st+404
.L2115:
	clr.l st+388
.L2114:
	move.l st+368,%d1
	tst.l %d1
	jeq .L2116
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+372
	addq.l #1,st+376
	cmp.l st+380.l,%d0
	jls .L2117
	move.l %d0,st+380
.L2117:
	clr.l st+368
.L2116:
	move.l %a6,st+20
	move.l -66650100,%d0
	move.l %d0,st+56
	sub.l t_commit,%d0
	addq.l #1,st+28
	move.l %d0,st+60
	jra .L2094
.L2123:
	move.l %d4,56(%sp)
	jra .L2124
.L2097:
	pea 256.w
	pea comp
	move.l 60(%sp),-(%sp)
	addq.l #1,st+32
	jsr (%a2)
	lea (12,%sp),%sp
	jra .L2094
.L2118:
	tst.l st+1058
	jne .L2090
.L2119:
	move.l %d3,%a0
	add.l #566,%d3
	lea (108,%sp),%a1
	addq.l #6,%a0
.L2120:
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
	jne .L2120
	jra .L2090
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
	jne .L2148
	cmp.l ed+88.l,%d1
	jeq .L2148
	move.l %d1,ed+88
	mov3q.l #1,ed+92
.L2148:
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
	jne .L2149
	moveq #66,%d5
	cmp.l %d2,%d5
	jne .L2150
	tst.b k44+20.l
	jeq .L2151
	clr.b %d6
	move.b %d6,k44+20
	tst.b k44+22.l
	jeq .L2151
	moveq #2,%d7
	move.w %d7,k44+22
.L2151:
	clr.l u46
	tst.b u46+48.l
	jeq .L2152
	clr.b %d0
	move.b %d0,u46+48
.L2159:
	mov3q.l #1,%d0
.L2153:
	move.l -66650100,%d1
	addq.l #1,st+336
	sub.l 64(%sp),%d1
	add.l %d1,st+328
	cmp.l st+332.l,%d1
	jls .L2147
	move.l %d1,st+332
.L2147:
	movem.l (%sp),#31996
	lea (100,%sp),%sp
	rts
.L2150:
	cmp.l #134,%d2
	jne .L2154
	clr.l tk
	tst.l tk+8
	jeq .L2152
	move.l st+248,%d0
	clr.l tk+8
	btst #6,%d0
	jeq .L2155
	moveq #-65,%d1
	and.l %d0,%d1
	move.l %d1,st+248
	tst.l st+4
	jne .L2464
.L2155:
	clr.l %d0
	jra .L2153
.L2154:
	move.l %d2,%d0
	add.l #-68,%d0
	lsr.l #1,%d0
	jne .L2152
	moveq #31,%d1
	mov3q.l #1,%d0
	and.l %d4,%d1
	lsl.l %d1,%d0
	and.l st+208,%d0
	tst.l %d0
	jeq .L2157
	move.l st+200,%d3
	move.l %d3,%d5
	move.l st+220,%d1
	move.l %d1,%d0
	and.l #2097152,%d0
	and.l #786432,%d5
	or.l %d5,%d0
	jeq .L2158
	addq.l #1,nk+16
.L2158:
	and.l #-786433,%d3
	bclr #21,%d1
	move.l %d3,st+200
	move.l %d1,st+220
.L2157:
	moveq #69,%d6
	cmp.l %d2,%d6
	jne .L2152
	tst.l nk
	jeq .L2152
	moveq #-33,%d7
	and.l %d7,st+240
	clr.l nk
	tst.l st+4
	jeq .L2159
	mov3q.l #1,-(%sp)
	pea 69.w
	lea queue_key,%a2
	jsr (%a2)
	clr.l -(%sp)
	pea 69.w
	jsr (%a2)
.L2463:
	jsr flush
.L2453:
	lea (16,%sp),%sp
	jra .L2159
.L2152:
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
	jeq .L2160
	not.l %d0
	and.l %d5,%d0
	move.l %d0,(%a2,%a0.l*4)
	jra .L2159
.L2160:
	move.l %d2,%d4
	mov3q.l #5,%d5
	add.l #-64,%d4
	cmp.l %d4,%d5
	jcs .L2161
	move.l ls+28,%d5
	btst %d4,%d5
	jeq .L2161
	mov3q.l #1,%d0
	lsl.l %d4,%d0
	move.l ls+32,%d1
	not.l %d0
	and.l %d0,%d5
	move.l %d5,ls+28
	btst %d4,%d1
	jeq .L2159
	and.l %d1,%d0
	move.l %d0,ls+32
.L2465:
	clr.l -(%sp)
.L2454:
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	jra .L2452
.L2161:
	move.l %d1,%a1
	move.l %d0,%d4
	lea (121,%a1),%a1
	lea sq,%a0
	move.l (%a0,%a1.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L2162
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a0,%a1.l*4)
	jra .L2465
.L2162:
	move.l %d1,%a0
	move.l %d0,%d4
	lea (50,%a0),%a0
	move.l (%a2,%a0.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L2163
	not.l %d0
	and.l %d3,%d0
	move.l %d2,%d1
	mov3q.l #7,%d6
	add.l #-112,%d1
	move.l %d0,(%a2,%a0.l*4)
	cmp.l %d1,%d6
	jcs .L2155
	move.l ux,%d3
	btst %d1,%d3
	jeq .L2155
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	not.l %d0
	and.l %d3,%d0
	move.l %d0,ux
.L2464:
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
.L2458:
	addq.l #8,%sp
	jra .L2155
.L2163:
	move.l %d1,%a0
	move.l %d0,%d4
	lea (226,%a0),%a0
	move.l (%a2,%a0.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L2164
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a2,%a0.l*4)
	move.l st+4,%d0
	or.l sq+408,%d0
	jeq .L2155
	jra .L2464
.L2164:
	add.l #58,%d1
	move.l %d0,%d4
	move.l (%a2,%d1.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L2155
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a2,%d1.l*4)
	tst.l st+4
	jeq .L2159
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
.L2452:
	addq.l #8,%sp
	jra .L2159
.L2149:
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
	move.l %d1,58(%sp)
	and.l %d3,%d0
	tst.l %d0
	jne .L2159
	move.l %d7,%d5
	move.l %d3,%d0
	add.l #58,%d5
	and.l (%a2,%d5.l*4),%d0
	tst.l %d0
	jne .L2159
	move.l %d7,%d0
	add.l #121,%d0
	lea sq,%a5
	move.l (%a5,%d0.l*4),%d0
	and.l %d3,%d0
	tst.l %d0
	jne .L2159
	move.l %d7,%d6
	move.l %d3,%d0
	add.l #50,%d6
	and.l (%a2,%d6.l*4),%d0
	tst.l %d0
	jne .L2155
	move.l %d7,%d0
	add.l #226,%d0
	move.l (%a2,%d0.l*4),%d0
	and.l %d3,%d0
	tst.l %d0
	jne .L2155
	tst.l nk
	jeq .L2165
	move.l %d2,%d1
	add.l #-18,%d1
	lsr.l #1,%d1
	jeq .L2168
	cmp.l #181,%d2
	jne .L2167
.L2168:
	lea (%a4,%d0.l),%a0
	moveq #32,%d1
	move.l (%a0),68(%sp,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L2168
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
	jra .L2458
.L2167:
	clr.l nk
	addq.l #1,nk+8
	tst.l st+4
	jeq .L2165
	mov3q.l #1,-(%sp)
	pea 69.w
	jsr queue_key
	jsr flush
	addq.l #8,%sp
.L2165:
	moveq #66,%d6
	cmp.l %d2,%d6
	jne .L2169
	move.l st+4,%d0
	tst.l %d0
	jeq .L2170
	tst.l st+1058
	jne .L2171
.L2170:
	move.l st+216,%d1
	or.l st+248,%d1
	or.l st+920,%d1
	btst #0,%d1
	jne .L2171
	move.w #256,%d7
	lea st+8,%a0
	move.l (%a0),k44
	move.w %d7,k44+20
.L2171:
	lea st+8,%a0
	move.l (%a0),u46+4
	tst.l sq+408
	jeq .L2198
	tst.l %d0
	jeq .L2174
	tst.l st+1058
	jne .L2198
	move.l sq+484,%d1
	move.l st+232,%d0
.L2176:
	or.l %d1,%d0
	tst.w %d0
	jeq .L2198
	moveq #1,%d0
	clr.b %d1
	addq.l #1,u46+32
	move.b %d0,u46+48
	move.b %d1,k44+20
	jra .L2159
.L2169:
	cmp.l #128,%d2
	jne .L2172
	lea masks,%a0
	move.l (%a0),nk+20
.L2198:
	move.l %d2,%d6
	mov3q.l #1,%d0
	move.l st+4,%d7
	add.l #-64,%d6
	cmp.l %d6,%d0
	jcs .L2217
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jne .L2216
	tst.l fk_claim
	jeq .L2219
	move.b ls,%d0
	move.b u46+48,%d1
	or.l %d1,%d0
	tst.b %d0
	jne .L2219
	move.l st+216,%d0
	moveq #65,%d1
	or.l st+972,%d7
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
	or.l %d7,%d0
	jne .L2219
	tst.l sq+408
	jeq .L2220
	tst.w sq+486.l
	jne .L2219
.L2220:
	tst.w st+202.l
	jne .L2219
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	or.l ov_list,%d0
	jne .L2219
	or.l %d3,st+272
	moveq #64,%d4
	cmp.l %d2,%d4
	jne .L2299
	moveq #15,%d0
.L2221:
	lea fk,%a0
	addq.l #1,(%a0,%d6.l*4)
	move.l %d0,dp
	addq.l #1,dp+4
	jra .L2462
.L2174:
	move.l sq+484,%d1
	jra .L2176
.L2172:
	moveq #68,%d6
	cmp.l %d2,%d6
	jne .L2177
	move.l tk,%d0
	or.l u46,%d0
	jeq .L2178
	tst.l st+4
	jeq .L2178
	addq.l #1,tk+4
	jra .L2198
.L2178:
	move.l st+216,%d0
	moveq #64,%d7
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d0,%d7
	move.l %d7,%a0
	btst #6,%d0
	jne .L2180
	move.l st+240,%d0
	move.l st+208,%d7
	move.l %d7,%d1
	move.l st+912,%d6
	or.l %d0,%d1
	or.l %d6,%d1
	move.w %d1,%ccr
	jeq .L2181
	tst.b u46+48.l
	jeq .L2182
.L2181:
	move.l st+8,%a1
	mov3q.l #2,%d1
	sub.l u46+4,%a1
	cmp.l %a1,%d1
	jcc .L2183
.L2180:
	moveq #16,%d2
	or.l %d2,st+272
	tst.l %a0
	jne .L2184
	moveq #1,%d4
	addq.l #1,u46+20
	addq.l #1,u46+16
	move.b %d4,k44+21
.L2184:
	tst.l st+4
	jeq .L2185
	tst.b k44+22.l
	jeq .L2186
	tst.b k44+26.l
	jne .L2186
	tst.l %a0
	jne .L2186
	moveq #1,%d6
	moveq #1,%d7
	clr.b %d0
	mvz.w #256,%d5
	move.l %d5,st+296
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
.L2456:
	jsr flush
	jra .L2159
.L2186:
	mov3q.l #3,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr leave
	jra .L2452
.L2185:
	clr.l -(%sp)
.L2460:
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	jra .L2457
.L2183:
	move.w %d7,%ccr
	jeq .L2187
.L2182:
	or.l %d6,%d0
	move.w %d0,%ccr
	jeq .L2187
	tst.b u46+48.l
	jeq .L2198
.L2187:
	addq.l #1,u46+40
	jra .L2198
.L2177:
	moveq #53,%d1
	cmp.l %d2,%d1
	jne .L2188
	move.l st+216,%d6
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d6,50(%sp)
	btst #6,%d6
	jne .L2189
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
	jne .L2190
	tst.b u46+48.l
	jeq .L2198
.L2191:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L2189
.L2190:
	tst.l %d6
	jeq .L2191
.L2189:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #32,%d4
	swap %d4
	or.l %d7,%d1
	or.l %d4,st+268
	btst #6,%d1
	jeq .L2193
	mov3q.l #1,tk
.L2193:
	clr.l st+1038
	tst.l st+4
	jeq .L2194
	moveq #1,%d6
	mvz.w #256,%d5
	moveq #1,%d7
	moveq #1,%d0
	move.l %d5,st+296
	addq.l #1,st+998
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
	jra .L2456
.L2194:
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	addq.l #1,st+994
.L2457:
	lea (12,%sp),%sp
	jra .L2159
.L2188:
	moveq #16,%d1
	cmp.l %d2,%d1
	jne .L2173
	move.l st+216,%d6
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d6,50(%sp)
	btst #6,%d6
	jne .L2195
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
	jne .L2196
	tst.b u46+48.l
	jeq .L2198
.L2197:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L2195
.L2196:
	tst.l %d6
	jeq .L2197
.L2195:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #1,%d4
	swap %d4
	or.l %d7,%d1
	or.l %d4,st+264
	btst #6,%d1
	jeq .L2199
	mov3q.l #1,tk
.L2199:
	clr.l st+1038
	tst.l st+4
	jeq .L2200
	moveq #1,%d6
	mvz.w #256,%d5
	moveq #1,%d7
	moveq #2,%d0
	move.l %d5,st+296
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
.L2459:
	addq.l #1,st+1078
	jra .L2456
.L2200:
	mov3q.l #2,-(%sp)
.L2461:
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	addq.l #1,st+1074
	jra .L2457
.L2173:
	moveq #52,%d1
	cmp.l %d2,%d1
	jne .L2175
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L2201
	tst.b u46+48.l
	jeq .L2198
.L2201:
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #6,%d0
	jne .L2198
	tst.l sq+408
	jeq .L2202
	tst.w sq+486.l
	jne .L2198
.L2202:
	tst.w st+202.l
	jne .L2198
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
	jeq .L2203
	moveq #1,%d6
	moveq #3,%d7
	mvz.w #256,%d5
	move.b %d2,st+161
	move.l %d5,st+296
	move.w %d6,st+162
	move.b %d7,st+993
	jra .L2459
.L2203:
	mov3q.l #3,-(%sp)
	jra .L2461
.L2175:
	moveq #51,%d0
	cmp.l %d2,%d0
	jne .L2179
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L2204
	tst.b u46+48.l
	jeq .L2198
.L2204:
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #6,%d0
	jne .L2198
	tst.l sq+408
	jeq .L2205
	tst.w sq+486.l
	jne .L2198
.L2205:
	tst.w st+202.l
	jne .L2198
	moveq #1,%d1
	moveq #8,%d2
	swap %d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	clr.l st+1038
	move.b %d1,k44+21
	or.l %d2,st+268
	tst.l st+4
	jeq .L2206
	moveq #1,%d5
	moveq #4,%d6
	mvz.w #256,%d4
	move.b %d1,st+161
	move.l %d4,st+296
	move.w %d5,st+162
	move.b %d6,st+993
	jra .L2456
.L2206:
	mov3q.l #4,-(%sp)
	jra .L2460
.L2179:
	moveq #48,%d7
	cmp.l %d2,%d7
	jne .L2192
	move.l st+216,%d0
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d0,50(%sp)
	btst #6,%d0
	jne .L2207
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
	jne .L2208
	tst.b u46+48.l
	jeq .L2198
.L2209:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L2207
.L2208:
	tst.l %d6
	jeq .L2209
.L2207:
	mvz.b 1093765506,%d0
	moveq #11,%d4
	cmp.l %d0,%d4
	jcs .L2298
	move.b 1093765506,%d0
	add.l #16,%d0
.L2210:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #1,%d5
	swap %d5
	or.l %d7,%d1
	or.l %d5,st+268
	btst #6,%d1
	jeq .L2211
	mov3q.l #1,tk
.L2211:
	tst.l st+4
	jeq .L2212
	tst.l st+1038
	jeq .L2213
	mov3q.l #3,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr leave
	addq.l #1,st+1050
	jra .L2452
.L2298:
	moveq #16,%d0
	jra .L2210
.L2213:
	moveq #1,%d7
	moveq #1,%d1
	mvz.w #256,%d6
	move.b %d0,st+993
	mov3q.l #1,st+1038
	addq.l #1,st+1046
	move.l %d6,st+296
	move.b %d7,st+161
	move.w %d1,st+162
	jra .L2456
.L2212:
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	mov3q.l #1,st+1038
	addq.l #1,st+1042
	jra .L2457
.L2192:
	moveq #13,%d6
	cmp.l %d2,%d6
	jcs .L2198
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L2214
	tst.b u46+48.l
	jeq .L2215
.L2214:
	or.l %d3,st+264
	addq.l #1,%d2
	move.l %d2,dp
	addq.l #1,dp+4
.L2462:
	tst.b k44+22.l
	jne .L2159
	moveq #1,%d7
	move.b %d7,k44+21
	jra .L2159
.L2215:
	move.l %d2,%d6
	add.l #-64,%d6
.L2216:
	tst.l st+4
	jeq .L2231
	cmp.l #132,%d2
	jne .L2232
	move.l st+216,%d1
	move.l %d1,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L2232
	moveq #16,%d6
	or.l %d1,%d6
	move.l %d6,st+216
	tst.l st+1058
	jne .L2233
	lea st+8,%a0
	mov3q.l #1,st+1058
	clr.l st+1062
	move.l (%a0),st+1066
	addq.l #1,st+1070
.L2233:
	moveq #1,%d0
	move.l 32(%a3),%a0
	move.b %d0,32(%a0)
	jra .L2155
.L2299:
	moveq #16,%d0
	jra .L2221
.L2219:
	addq.l #1,fk+8
	jra .L2216
.L2217:
	moveq #49,%d0
	cmp.l %d2,%d0
	jne .L2216
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L2224
	tst.b u46+48.l
	jeq .L2225
.L2224:
	or.l st+972,%d7
	jne .L2225
	tst.l sq+408
	jeq .L2226
	tst.w sq+486.l
	jne .L2225
.L2226:
	move.l st+200,%d6
	mvz.w %d6,%d6
	tst.l %d6
	jne .L2225
	move.b 1093765506,%d1
	moveq #11,%d4
	mvz.b %d1,%d2
	cmp.l %d2,%d4
	jlt .L2227
	moveq #127,%d0
	ext.w %d1
	and.l -2147457096,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d6
.L2227:
	moveq #1,%d5
	addq.l #1,u46+24
	addq.l #1,u46+16
	move.b %d5,k44+21
	tst.b ls.l
	jeq .L2228
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L2228:
	clr.l u46+8
	moveq #11,%d7
	cmp.l %d2,%d7
	jlt .L2229
	move.l %d6,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L2230
	moveq #45,%d0
	cmp.l %d6,%d0
	jeq .L2230
	moveq #43,%d1
	cmp.l %d6,%d1
	jne .L2229
.L2230:
	move.l %d6,-(%sp)
	move.l %d2,-(%sp)
	moveq #127,%d2
	jsr mr_vb
	addq.l #8,%sp
	mvz.b %d0,%d0
	cmp.l %d0,%d2
	jeq .L2229
	mov3q.l #1,%d4
	or.l st+8,%d4
	move.l %d6,u46+12
	move.l %d4,u46+8
.L2229:
	moveq #2,%d5
	swap %d5
	or.l %d5,st+204
	jra .L2155
.L2225:
	moveq #-15,%d6
	jra .L2216
.L2231:
	tst.b ls.l
	jeq .L2234
	mov3q.l #5,%d1
	cmp.l %d6,%d1
	jcs .L2235
	move.l st+216,%d0
	mov3q.l #1,%d3
	lsl.l %d6,%d3
	mov3q.l #1,%d4
	or.l st+920,%d0
	lea flush,%a2
	moveq #68,%d5
	or.l %d3,ls+28
	or.l st+248,%d0
	and.l %d4,%d0
	cmp.l %d2,%d5
	jne .L2236
	tst.l ls+36
	jne .L2237
	tst.l %d0
	jeq .L2238
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
.L2466:
	jsr (%a2)
	jra .L2452
.L2236:
	moveq #69,%d1
	cmp.l %d2,%d1
	jne .L2237
	tst.l %d0
	jeq .L2239
	move.b ls+2,%d1
	add.l #-40,%d1
	mvz.b %d1,%d1
	lsr.l #1,%d1
	jne .L2237
.L2239:
	tst.l ls+36
	jeq .L2300
.L2237:
	move.l %d0,%a0
	pea 1(%a0)
	or.l %d3,ls+32
	move.l %d2,-(%sp)
	addq.l #1,ls+88
	jsr queue_key
	jra .L2466
.L2238:
	move.l 1100949720,%a3
	move.l %a3,%d0
	clr.l ls+64
	clr.l ls+60
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L2241
	jsr sq_grid
	tst.l %d0
	jeq .L2241
	lea (348,%a3),%a0
	move.l (%a0),ls+60
	lea (344,%a3),%a3
	move.l (%a3),ls+64
.L2241:
	mvz.b ls+1,%d0
	lea st+8,%a0
	move.l (%a0),ls+72
	move.l %d0,ls+68
	moveq #1,%d0
.L2240:
	mov3q.l #3,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	jsr ls_close
	jsr (%a2)
	addq.l #4,%sp
	jra .L2159
.L2300:
	moveq #2,%d0
	jra .L2240
.L2235:
	move.l %d4,%d0
	and.l #240,%d0
	tst.l %d0
	jeq .L2234
	cmp.l #128,%d2
	jeq .L2234
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-80,%d0
	cmp.l %d0,%d1
	jcc .L2234
	add.l #-64,%d0
	moveq #11,%d7
	cmp.l %d0,%d7
	jcc .L2234
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
	tst.l st+4
	jne .L2232
.L2234:
	move.l st+972,%d0
	tst.b ls.l
	jne .L2242
	moveq #68,%d1
	cmp.l %d2,%d1
	jne .L2242
	tst.l %d0
	jne .L2243
	tst.b sv.l
	jeq .L2232
	tst.b sv+8.l
	jeq .L2232
	move.b sv+3,%d7
	jne .L2232
	move.l ls+24,%d0
	mov3q.l #4,%d6
	addq.l #2,%d0
	cmp.l %d0,%d6
	jcs .L2232
	move.b sv+1,%d1
	move.b %d1,63(%sp)
	mvz.b %d1,%d6
	mvz.b 1093765506,%d0
	cmp.l %d6,%d0
	jne .L2232
	move.b sv+2,%d6
	mvz.b %d6,%d1
	move.l %d1,-(%sp)
	move.l %d1,58(%sp)
	jsr ls_banked
	addq.l #4,%sp
	move.l 54(%sp),%d1
	tst.l %d0
	jne .L2244
	moveq #45,%d0
	cmp.l %d1,%d0
	jeq .L2244
	moveq #43,%d0
	cmp.l %d1,%d0
	jne .L2232
.L2244:
	tst.l sq+408
	jeq .L2245
	tst.w sq+486.l
	jne .L2232
.L2245:
	move.l st+216,%d0
	or.l st+920,%d0
	or.l st+248,%d0
	btst #0,%d0
	jeq .L2232
	move.b 63(%sp),%d1
	move.b %d6,ls+2
	mvz.b %d6,%d6
	moveq #45,%d2
	move.b %d1,ls+1
	cmp.l %d6,%d2
	jeq .L2302
	moveq #43,%d4
	cmp.l %d6,%d4
	jne .L2246
.L2302:
	moveq #10,%d7
.L2246:
	moveq #1,%d5
	clr.b %d6
	lea st+8,%a0
	move.l (%a0),ls+126
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	lea ls_queue,%a2
	move.b %d7,ls+124
	move.b %d5,ls
	move.b %d6,ls+125
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
	jra .L2463
.L2242:
	tst.l %d0
	jeq .L2232
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-80,%d0
	cmp.l %d0,%d1
	jcc .L2232
	add.l #-64,%d0
	moveq #11,%d7
	cmp.l %d0,%d7
	jcc .L2232
.L2243:
	mov3q.l #4,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr splash_end
	addq.l #8,%sp
	mov3q.l #5,%d0
	cmp.l %d6,%d0
	jcs .L2232
	or.l %d3,st+272
	jra .L2159
.L2232:
	move.l st+4,%d0
	tst.l sq+408
	jeq .L2247
	tst.l %d0
	jeq .L2248
	tst.l st+1058
	jne .L2249
.L2248:
	move.l %d2,%d1
	mov3q.l #2,%d6
	add.l #-80,%d1
	cmp.l %d1,%d6
	jcs .L2250
	move.l st+920,%d1
	move.l st+248,%d7
	move.l st+208,%d6
	or.l st+216,%d1
	move.l %d7,46(%sp)
	or.l st+240,%d6
	or.l %d7,%d1
	btst #0,%d1
	jeq .L2251
	move.l sq+484,%a0
	tst.l %d0
	jeq .L2303
	move.l st+232,%a1
.L2252:
	move.l %a0,%d7
	move.l %a1,%d1
	or.l %d7,%d1
	move.l %d1,%d7
	moveq #16,%d1
	mvz.w %d7,%d7
	and.l sq+500,%d1
	or.l %d7,%d1
	jne .L2254
	tst.l %d0
	jeq .L2251
	move.l 46(%sp),%d7
	btst #4,%d7
	jne .L2254
.L2251:
	move.l %d6,%d1
	or.l st+912,%d1
	move.w %d1,%ccr
	jeq .L2256
	tst.b u46+48.l
	jeq .L2257
.L2256:
	move.l sq+484,%a0
	tst.l %d0
	jeq .L2304
	move.l st+232,%d1
.L2258:
	move.l %a0,%d7
	or.l %d7,%d1
	tst.w %d1
	jeq .L2257
.L2254:
	or.l st+912,%d6
	move.w %d6,%ccr
	jeq .L2259
	tst.b u46+48.l
	jeq .L2260
.L2259:
	addq.l #1,u46+36
.L2260:
	tst.l %d0
	jeq .L2261
	move.l st+232,%d0
.L2261:
	move.l %a0,%d1
	or.l %d1,%d0
	move.l %d0,%d1
	mvz.w %d1,%d1
	tst.w %d0
	jeq .L2262
	moveq #80,%d4
	cmp.l %d2,%d4
	jeq .L2305
	moveq #82,%d5
	cmp.l %d2,%d5
	jne .L2306
	moveq #14,%d0
.L2263:
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	mov3q.l #1,-(%sp)
	or.l %d3,st+272
	move.l %d0,-(%sp)
	jsr ed_queue
	jra .L2453
.L2303:
	sub.l %a1,%a1
	jra .L2252
.L2304:
	clr.l %d1
	jra .L2258
.L2262:
	moveq #80,%d6
	cmp.l %d2,%d6
	jeq .L2307
	moveq #82,%d7
	cmp.l %d2,%d7
	jne .L2308
	moveq #10,%d0
	jra .L2263
.L2305:
	moveq #13,%d0
	jra .L2263
.L2306:
	moveq #15,%d0
	jra .L2263
.L2307:
	moveq #9,%d0
	jra .L2263
.L2308:
	moveq #11,%d0
	jra .L2263
.L2297:
	cmp.l #132,%d2
	jne .L2264
	move.l st+216,%d0
	move.l %d0,%d1
	or.l st+920,%d1
	btst #0,%d1
	jeq .L2264
	moveq #16,%d1
	or.l %d0,%d1
	addq.l #1,ed+84
	move.l %d1,st+216
	jra .L2155
.L2265:
	move.l %d4,%d0
	and.l #240,%d0
	tst.l %d0
	jeq .L2267
	and.l #251,%d4
	cmp.l #128,%d4
	jeq .L2267
	moveq #48,%d7
	cmp.l %d2,%d7
	jne .L2268
.L2267:
	lea sq,%a0
	addq.l #1,sq+460
	cmp.l #128,%d2
	jne .L2269
	mov3q.l #1,%d0
	or.l %d0,st+920
.L2270:
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	addq.l #8,%sp
	cmp.l #128,%d2
	sne %d0
.L2467:
	mvs.b %d0,%d0
	neg.l %d0
	jra .L2153
.L2269:
	lea (121,%a6),%a6
	or.l %d3,(%a0,%a6.l*4)
	jra .L2270
.L2275:
	move.l %d2,%d0
	add.l #-66,%d0
	lsr.l #1,%d0
	jne .L2278
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L2277
	move.l masks,%d6
	cmp.l nk+20.l,%d6
	jeq .L2276
.L2277:
	cmp.l #181,%d2
	jne .L2282
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L2286
.L2282:
	tst.l mask_set
	jeq .L2287
	lea mask_keys,%a0
	move.l (%a0,%a6.l*4),%d0
	move.l 58(%sp),%d7
	btst %d7,%d0
	jeq .L2286
.L2287:
	cmp.l #128,%d2
	jne .L2449
	mov3q.l #2,%d4
	jra .L2288
.L2279:
	addq.l #1,nk+24
	jra .L2280
.L2309:
	mov3q.l #1,%d0
	jra .L2283
.L2450:
	move.l %d2,%d0
	mov3q.l #2,%d6
	add.l #-80,%d0
	cmp.l %d0,%d6
	jcs .L2277
.L2285:
	addq.l #1,st+944
.L2271:
	lea (50,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
	jra .L2155
.L2449:
	mov3q.l #1,%d4
.L2288:
	addq.l #1,st+936
	mov3q.l #2,%d1
	cmp.l %d4,%d1
	jne .L2290
	lea (226,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
.L2291:
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	mov3q.l #2,%d2
	addq.l #8,%sp
	cmp.l %d4,%d2
	sne %d0
	jra .L2467
.L2290:
	or.l %d3,(%a2,%d5.l*4)
	jra .L2291
.L2278:
	moveq #69,%d0
	cmp.l %d2,%d0
	jne .L2450
	tst.l mask_set
	jeq .L2281
	lea mask_keys+8,%a0
	btst #5,3(%a0)
	jeq .L2282
.L2281:
	lea st+232,%a1
	clr.l %d1
	sub.l %a0,%a0
.L2284:
	tst.l (%a1)+
	jne .L2309
	tst.l 668(%a1)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L2283:
	or.l %d0,%d1
	addq.l #1,%a0
	moveq #8,%d0
	cmp.l %a0,%d0
	jne .L2284
	move.l st+216,%d0
	mov3q.l #1,%d4
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d4,%d0
	or.l %d1,%d0
	jne .L2282
	moveq #32,%d5
	or.l %d5,st+240
	addq.l #1,st+936
	mov3q.l #1,nk
	jra .L2159
.L2274:
	moveq #69,%d1
	cmp.l %d2,%d1
	jeq .L2286
	add.l #-80,%d2
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	jcc .L2285
.L2286:
	addq.l #1,st+940
	jra .L2271
.L2247:
	tst.l %d0
	jne .L2249
.L2268:
	tst.b sv.l
	jeq .L2249
	moveq #111,%d1
	cmp.l %d2,%d1
	jcc .L2271
	moveq #119,%d4
	cmp.l %d2,%d4
	jcs .L2249
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
	jra .L2458
.L2257:
	tst.l %d0
	jne .L2272
.L2264:
	tst.w sq+486.l
	jeq .L2265
	move.l %d2,%d0
	mov3q.l #5,%d6
	add.l #-48,%d0
	cmp.l %d0,%d6
	jcc .L2266
	moveq #16,%d7
	cmp.l %d2,%d7
	jeq .L2266
	add.l #-20,%d0
	mov3q.l #1,%d1
	cmp.l %d0,%d1
	jcc .L2266
	add.l #-44,%d0
	lsr.l #3,%d0
	jne .L2265
.L2266:
	lea (121,%a6),%a6
	or.l %d3,(%a5,%a6.l*4)
	addq.l #1,st+1054
.L2455:
	mov3q.l #1,-(%sp)
	jra .L2454
.L2250:
	tst.l %d0
	jeq .L2297
.L2249:
	move.l %d2,%d0
	moveq #11,%d6
	add.l #-144,%d0
	cmp.l %d0,%d6
	jcs .L2272
	moveq #64,%d0
	and.l st+248,%d0
	tst.l %d0
	jeq .L2272
	move.l tk+8,%d0
	tst.l %d0
	jne .L2272
.L2273:
	lea (%a4,%d0.l),%a0
	moveq #32,%d1
	move.l (%a0),68(%sp,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L2273
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
.L2272:
	tst.l st+4
	jeq .L2271
	tst.l st+1058
	jne .L2274
	moveq #68,%d7
	cmp.l %d2,%d7
	jne .L2275
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
	move.l st+232,%d1
	mvz.w %d1,%d1
	or.l %d1,%d0
	jeq .L2282
.L2276:
	addq.l #1,st+936
	moveq #68,%d7
	cmp.l %d2,%d7
	jne .L2279
	addq.l #1,nk+12
.L2280:
	or.l %d3,st+240
	jra .L2455
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
	jne .L2469
	tst.l sq+408
	jeq .L2470
	tst.w sq+486.l
	jeq .L2470
	mov3q.l #7,%d0
	cmp.l %a6,%d0
	jcs .L2470
	tst.b 20(%a0)
	jne .L2498
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+920,%d0
	and.l %d1,%d0
.L2471:
	add.l %d2,96(%a2,%a6.l*4)
	move.b %d0,st+160
	addq.l #1,sq+464
	jsr flush
.L2472:
	mov3q.l #1,%d2
	jra .L2475
.L2498:
	mov3q.l #1,%d0
	jra .L2471
.L2470:
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr ls_enc
	addq.l #8,%sp
	move.l %d0,%d2
	tst.l %d0
	jne .L2475
	moveq #8,%d3
	cmp.l %a6,%d3
	jne .L2474
	tst.b sv+8.l
	jeq .L2474
	move.l st+8,%a0
	addq.l #1,st+1086
	lea (47,%a0),%a0
	move.l %a0,st+1082
.L2474:
	tst.l st+972
	jeq .L2475
	mov3q.l #5,-(%sp)
	move.l 76(%sp),%a1
	move.l 32(%a1),-(%sp)
	jsr splash_end
	addq.l #8,%sp
.L2475:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 44(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L2468
	move.l %d0,st+332
.L2468:
	move.l %d2,%d0
	movem.l (%sp),#23804
	lea (68,%sp),%sp
	rts
.L2469:
	tst.l st+1058
	jeq .L2476
	addq.l #1,st+952
.L2477:
	clr.l %d2
	jra .L2475
.L2476:
	tst.l mask_set
	jeq .L2478
	moveq #15,%d0
	cmp.l %a6,%d0
	jcs .L2479
	move.l mask_enc,%d0
	move.l %a6,%d1
	btst %d1,%d0
	jne .L2478
.L2479:
	addq.l #1,st+952
	moveq #8,%d3
	cmp.l %a6,%d3
	jne .L2477
	move.l st+8,%a0
	addq.l #1,st+1086
	lea (47,%a0),%a0
	move.l %a0,st+1082
	jra .L2477
.L2478:
	addq.l #1,st+948
	tst.b 20(%a0)
	jne .L2499
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
.L2481:
	move.b %d0,st+160
	moveq #15,%d3
	cmp.l %a6,%d3
	jcs .L2472
	move.l %a6,%d4
	add.l #24,%d4
	add.l %d2,(%a2,%d4.l*4)
	tst.l st+64
	jne .L2483
	move.l #-66650100,%a0
	move.l (%a0),st+64
.L2483:
	tst.l st+388
	jne .L2484
	move.l #-66650100,%a1
	lea commits,%a0
	move.l (%a1),st+388
	move.l (%a0),st+392
.L2484:
	move.l %a6,%d5
	add.l #122,%d5
	lea bind_gen,%a4
	move.l (%a4,%a6.l*4),%d6
	move.l (%a2,%d5.l*4),%a3
	cmp.l %d6,%a3
	jeq .L2487
	btst #0,%d6
	jne .L2487
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
	jne .L2487
	move.l %d3,%d0
	move.l %a6,%d1
	add.l #st+552,%d0
	add.l #102,%d1
	tst.l (%a2,%d1.l*4)
	jeq .L2500
	move.l %d0,%a1
	move.b 48(%sp),%d3
	move.b (%a1),%d1
	eor.l %d1,%d3
	tst.b %d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
.L2489:
	mov3q.l #5,-(%sp)
	move.l %d7,-(%sp)
	move.l %d0,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	tst.l %d3
	jne .L2490
	lea (%a2,%a6.l),%a0
	move.b 49(%sp),472(%a0)
.L2490:
	move.l %d6,(%a2,%d5.l*4)
	move.l %d6,%a3
.L2487:
	tst.l %a3
	jeq .L2491
	move.l %a6,%d0
	moveq #20,%d3
	muls.l %d3,%d0
	lea (%a2,%d0.l),%a0
	mvz.b 552(%a0),%d1
	lsr.l #6,%d1
	jne .L2491
	lea (102,%a6),%a1
	add.l #st,%a6
	tst.l (%a2,%a1.l*4)
	jne .L2492
	move.b 553(%a0),472(%a6)
.L2492:
	move.l %d0,%a0
	add.l #st+556,%a0
	move.b (%a0),%d1
	mvz.b 472(%a6),%d3
	btst #0,%d1
	jeq .L2501
	tst.b st+160.l
	jne .L2502
.L2501:
	mov3q.l #1,%d1
.L2493:
	muls.l %d1,%d2
	move.l %d0,%a0
	add.l #st+554,%a0
	mvz.b (%a0),%d1
	add.l %d3,%d2
	cmp.l %d2,%d1
	jle .L2494
	move.l %d1,%d2
.L2494:
	move.l %d0,%a0
	add.l #st+555,%a0
	mvz.b (%a0),%d1
	cmp.l %d2,%d1
	jge .L2495
	move.l %d1,%d2
.L2495:
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
	jne .L2496
	move.l #-66650100,%a1
	move.l (%a1),st+368
.L2496:
	moveq #1,%d0
	move.l 72(%sp),%a1
	move.l 32(%a1),%a0
	move.b %d0,32(%a0)
.L2491:
	jsr flush
	tst.l (%a2,%d4.l*4)
	jne .L2472
	addq.l #1,st+384
	jra .L2472
.L2499:
	mov3q.l #1,%d0
	jra .L2481
.L2500:
	clr.l %d3
	jra .L2489
.L2502:
	moveq #8,%d1
	jra .L2493
	.size	rui_enc, .-rui_enc
	.align	2
	.globl	pj_write
	.type	pj_write, @function
pj_write:
	move.l 4(%sp),%d0
	move.l 8(%sp),%d1
	cmp.l #1074464814,%d0
	jeq .L2512
	cmp.l #1073958730,%d0
	jeq .L2512
	lea pj_push,%a0
	cmp.l #1074076072,%d0
	jne .L2514
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #5,-(%sp)
.L2527:
	jsr (%a0)
	lea (12,%sp),%sp
.L2512:
	rts
.L2514:
	cmp.l #1074076390,%d0
	jeq .L2515
	cmp.l #1074076276,%d0
	jne .L2516
.L2515:
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #3,-(%sp)
	jra .L2527
.L2516:
	cmp.l #1073959500,%d0
	jne .L2517
	mvz.b pj+137,%d0
	move.l %d1,-(%sp)
	move.l %d0,%a1
	pea -1(%a1)
	mov3q.l #2,-(%sp)
	jra .L2527
.L2517:
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #7,-(%sp)
	jra .L2527
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
	jcs .L2531
	addq.l #1,%d0
.L2530:
	move.b %d0,pj+137
	rts
.L2531:
	clr.b %d0
	jra .L2530
	.size	pj_copy, .-pj_copy
	.align	2
	.globl	pj_save
	.type	pj_save, @function
pj_save:
	move.l 4(%sp),%d0
	tst.l %d0
	jlt .L2532
	move.b 1079807565,%d1
	move.l %d0,-(%sp)
	mvs.b %d1,%d1
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr pj_push
	lea (12,%sp),%sp
.L2532:
	rts
	.size	pj_save, .-pj_save
	.align	2
	.globl	pj_activate
	.type	pj_activate, @function
pj_activate:
	move.l 4(%sp),%d0
	tst.l %d0
	jlt .L2534
	move.l #1074457822,%d1
	cmp.l 8(%sp),%d1
	jne .L2534
	move.l #1074479198,%d1
	cmp.l 12(%sp),%d1
	jne .L2534
	move.l %d0,12(%sp)
	moveq #10,%d0
	mov3q.l #-1,8(%sp)
	move.l %d0,4(%sp)
	jra pj_push
.L2534:
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
	jge .L2537
	moveq #127,%d0
.L2538:
	move.l %d0,-(%sp)
	pea 65.w
	jsr pj_push
	lea (12,%sp),%sp
	rts
.L2537:
	tst.l %d0
	jge .L2538
	clr.l %d0
	jra .L2538
	.size	kt_saved, .-kt_saved
	.align	2
	.globl	kt_reloaded
	.type	kt_reloaded, @function
kt_reloaded:
	addq.l #1,pmo+76
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
	.type	CSWTCH.543, @object
	.size	CSWTCH.543, 7
CSWTCH.543:
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
	.type	CSWTCH.541, @object
	.size	CSWTCH.541, 40
CSWTCH.541:
	.long	cu_sa_short
	.long	cu_fm_short
	.long	cu_fm_short
	.long	cu_wt_short
	.long	cu_gr_short
	.long	cu_li_short
	.long	cu_cp_short
	.long	cu_mi_name
	.long	cu_fm_short
	.long	cu_ms_short
	.text
	.type	CSWTCH.483, @object
	.size	CSWTCH.483, 6
CSWTCH.483:
	.byte	4
	.byte	5
	.byte	0
	.byte	3
	.byte	1
	.byte	2
	.zero	2
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
	.text
	.align	2
	.type	pmo_rcp, @object
	.size	pmo_rcp, 256
pmo_rcp:
	.word	-32768
	.word	-32768
	.word	16384
	.word	10922
	.word	8192
	.word	6553
	.word	5461
	.word	4681
	.word	4096
	.word	3640
	.word	3276
	.word	2978
	.word	2730
	.word	2520
	.word	2340
	.word	2184
	.word	2048
	.word	1927
	.word	1820
	.word	1724
	.word	1638
	.word	1560
	.word	1489
	.word	1424
	.word	1365
	.word	1310
	.word	1260
	.word	1213
	.word	1170
	.word	1129
	.word	1092
	.word	1057
	.word	1024
	.word	992
	.word	963
	.word	936
	.word	910
	.word	885
	.word	862
	.word	840
	.word	819
	.word	799
	.word	780
	.word	762
	.word	744
	.word	728
	.word	712
	.word	697
	.word	682
	.word	668
	.word	655
	.word	642
	.word	630
	.word	618
	.word	606
	.word	595
	.word	585
	.word	574
	.word	564
	.word	555
	.word	546
	.word	537
	.word	528
	.word	520
	.word	512
	.word	504
	.word	496
	.word	489
	.word	481
	.word	474
	.word	468
	.word	461
	.word	455
	.word	448
	.word	442
	.word	436
	.word	431
	.word	425
	.word	420
	.word	414
	.word	409
	.word	404
	.word	399
	.word	394
	.word	390
	.word	385
	.word	381
	.word	376
	.word	372
	.word	368
	.word	364
	.word	360
	.word	356
	.word	352
	.word	348
	.word	344
	.word	341
	.word	337
	.word	334
	.word	330
	.word	327
	.word	324
	.word	321
	.word	318
	.word	315
	.word	312
	.word	309
	.word	306
	.word	303
	.word	300
	.word	297
	.word	295
	.word	292
	.word	289
	.word	287
	.word	284
	.word	282
	.word	280
	.word	277
	.word	275
	.word	273
	.word	270
	.word	268
	.word	266
	.word	264
	.word	262
	.word	260
	.word	258
	.local	cu
	.comm	cu,32,4
	.text
.LC7:
	.string	"Tune"
.LC8:
	.string	"TUNE"
.LC9:
	.string	"Fine Tune"
.LC10:
	.string	"FINE"
.LC11:
	.string	"-"
.LC12:
	.string	"Play Mode"
.LC13:
	.string	"PLAY"
.LC14:
	.string	"Start"
.LC15:
	.string	"STRT"
.LC16:
	.string	"End"
.LC17:
	.string	"END"
.LC18:
	.string	"Loop"
.LC19:
	.string	"LOOP"
.LC20:
	.string	"Level"
.LC21:
	.string	"LEV"
	.text
	.align	2
	.type	cu_sap2k, @object
	.size	cu_sap2k, 128
cu_sap2k:
	.long	.LC7
	.long	.LC8
	.word	39
	.byte	0
	.byte	64
	.word	0
	.byte	4
	.byte	124
	.long	.LC9
	.long	.LC10
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC11
	.long	.LC11
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC12
	.long	.LC13
	.word	410
	.byte	33
	.byte	0
	.word	265
	.zero	2
	.long	.LC14
	.long	.LC15
	.word	410
	.byte	0
	.byte	0
	.word	0
	.byte	0
	.byte	120
	.long	.LC16
	.long	.LC17
	.word	410
	.byte	0
	.byte	120
	.word	0
	.byte	0
	.byte	120
	.long	.LC18
	.long	.LC19
	.word	410
	.byte	19
	.byte	0
	.word	0
	.byte	0
	.byte	120
	.long	.LC20
	.long	.LC21
	.word	101
	.byte	0
	.byte	100
	.word	0
	.zero	2
	.text
.LC22:
	.string	"CC 1 Value"
.LC23:
	.string	"VAL1"
.LC24:
	.string	"CC 2 Value"
.LC25:
	.string	"VAL2"
.LC26:
	.string	"CC 3 Value"
.LC27:
	.string	"VAL3"
.LC28:
	.string	"CC 4 Value"
.LC29:
	.string	"VAL4"
.LC30:
	.string	"CC 1 Select"
.LC31:
	.string	"SEL1"
.LC32:
	.string	"CC 2 Select"
.LC33:
	.string	"SEL2"
.LC34:
	.string	"CC 3 Select"
.LC35:
	.string	"SEL3"
.LC36:
	.string	"CC 4 Select"
.LC37:
	.string	"SEL4"
	.text
	.align	2
	.type	cu_mip2k, @object
	.size	cu_mip2k, 128
cu_mip2k:
	.long	.LC22
	.long	.LC23
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC24
	.long	.LC25
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC26
	.long	.LC27
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC28
	.long	.LC29
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC30
	.long	.LC31
	.word	410
	.byte	32
	.byte	0
	.word	0
	.zero	2
	.long	.LC32
	.long	.LC33
	.word	410
	.byte	32
	.byte	0
	.word	0
	.zero	2
	.long	.LC34
	.long	.LC35
	.word	410
	.byte	32
	.byte	0
	.word	0
	.zero	2
	.long	.LC36
	.long	.LC37
	.word	410
	.byte	32
	.byte	0
	.word	0
	.zero	2
	.text
.LC38:
	.string	"Destination"
.LC39:
	.string	"DST"
.LC40:
	.string	"Channel"
.LC41:
	.string	"CHAN"
.LC42:
	.string	"Bank"
.LC43:
	.string	"BANK"
.LC44:
	.string	"Sub Bank"
.LC45:
	.string	"SBNK"
.LC46:
	.string	"Program"
.LC47:
	.string	"PROG"
.LC48:
	.string	"Pitch Bend"
.LC49:
	.string	"PB"
.LC50:
	.string	"Aftertouch"
.LC51:
	.string	"AT"
.LC52:
	.string	"Mod Wheel"
.LC53:
	.string	"MW"
	.text
	.align	2
	.type	cu_mik, @object
	.size	cu_mik, 128
cu_mik:
	.long	.LC38
	.long	.LC39
	.word	410
	.byte	27
	.byte	32
	.word	260
	.zero	2
	.long	.LC40
	.long	.LC41
	.word	410
	.byte	28
	.byte	0
	.word	272
	.zero	2
	.long	.LC42
	.long	.LC43
	.word	410
	.byte	30
	.byte	0
	.word	0
	.zero	2
	.long	.LC44
	.long	.LC45
	.word	410
	.byte	30
	.byte	0
	.word	0
	.zero	2
	.long	.LC46
	.long	.LC47
	.word	410
	.byte	19
	.byte	0
	.word	0
	.zero	2
	.long	.LC48
	.long	.LC49
	.word	410
	.byte	29
	.byte	0
	.word	0
	.zero	2
	.long	.LC50
	.long	.LC51
	.word	410
	.byte	31
	.byte	0
	.word	0
	.zero	2
	.long	.LC52
	.long	.LC53
	.word	410
	.byte	31
	.byte	0
	.word	0
	.zero	2
	.text
.LC54:
	.string	"Stutter"
.LC55:
	.string	"STUT"
.LC56:
	.string	"Stutter Len"
.LC57:
	.string	"SLEN"
.LC58:
	.string	"Tape"
.LC59:
	.string	"TAPE"
.LC60:
	.string	"Tape Time"
.LC61:
	.string	"TTIM"
.LC62:
	.string	"Attack"
.LC63:
	.string	"ATK"
.LC64:
	.string	"Decay"
.LC65:
	.string	"DEC"
.LC66:
	.string	"Direction"
.LC67:
	.string	"DIR"
	.text
	.align	2
	.type	cu_cpp2k, @object
	.size	cu_cpp2k, 128
cu_cpp2k:
	.long	.LC54
	.long	.LC55
	.word	410
	.byte	20
	.byte	0
	.word	272
	.zero	2
	.long	.LC56
	.long	.LC57
	.word	410
	.byte	25
	.byte	0
	.word	0
	.zero	2
	.long	.LC58
	.long	.LC59
	.word	410
	.byte	22
	.byte	0
	.word	260
	.zero	2
	.long	.LC60
	.long	.LC61
	.word	410
	.byte	25
	.byte	0
	.word	0
	.zero	2
	.long	.LC62
	.long	.LC63
	.word	410
	.byte	25
	.byte	0
	.word	0
	.zero	2
	.long	.LC64
	.long	.LC65
	.word	410
	.byte	26
	.byte	0
	.word	0
	.zero	2
	.long	.LC66
	.long	.LC67
	.word	410
	.byte	23
	.byte	0
	.word	259
	.zero	2
	.long	.LC18
	.long	.LC19
	.word	410
	.byte	24
	.byte	0
	.word	260
	.zero	2
	.text
.LC68:
	.string	"Sample"
.LC69:
	.string	"SRC"
.LC70:
	.string	"Slice"
.LC71:
	.string	"SLC"
.LC72:
	.string	"Morph"
.LC73:
	.string	"MRPH"
.LC74:
	.string	"Shuffle Seed"
.LC75:
	.string	"SEED"
.LC76:
	.string	"Neighbour"
.LC77:
	.string	"NBR"
.LC78:
	.string	"Velocity"
.LC79:
	.string	"VEL"
	.text
	.align	2
	.type	cu_cpk, @object
	.size	cu_cpk, 128
cu_cpk:
	.long	.LC68
	.long	.LC69
	.word	410
	.byte	9
	.byte	10
	.word	2944
	.zero	2
	.long	.LC70
	.long	.LC71
	.word	410
	.byte	16
	.byte	0
	.word	320
	.zero	2
	.long	.LC7
	.long	.LC8
	.word	40
	.byte	17
	.byte	64
	.word	0
	.zero	2
	.long	.LC72
	.long	.LC73
	.word	410
	.byte	18
	.byte	0
	.word	0
	.zero	2
	.long	.LC74
	.long	.LC75
	.word	410
	.byte	19
	.byte	0
	.word	0
	.zero	2
	.long	.LC76
	.long	.LC77
	.word	410
	.byte	18
	.byte	0
	.word	0
	.zero	2
	.long	.LC78
	.long	.LC79
	.word	410
	.byte	18
	.byte	64
	.word	0
	.zero	2
	.long	.LC20
	.long	.LC21
	.word	101
	.byte	0
	.byte	100
	.word	0
	.zero	2
	.text
.LC80:
	.string	"Release"
.LC81:
	.string	"REL"
	.text
	.align	2
	.type	cu_lip2k, @object
	.size	cu_lip2k, 128
cu_lip2k:
	.long	.LC80
	.long	.LC81
	.word	410
	.byte	0
	.byte	77
	.word	0
	.zero	2
	.long	.LC11
	.long	.LC11
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC11
	.long	.LC11
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC11
	.long	.LC11
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC11
	.long	.LC11
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC11
	.long	.LC11
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC11
	.long	.LC11
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC11
	.long	.LC11
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.text
.LC82:
	.string	"Input"
.LC83:
	.string	"INPT"
.LC84:
	.string	"Gain"
.LC85:
	.string	"GAIN"
.LC86:
	.string	"Gate"
.LC87:
	.string	"GATE"
.LC88:
	.string	"Hold"
.LC89:
	.string	"HOLD"
.LC90:
	.string	"Monitor"
.LC91:
	.string	"MON"
.LC92:
	.string	"Sustain"
.LC93:
	.string	"SUS"
	.text
	.align	2
	.type	cu_lik, @object
	.size	cu_lik, 128
cu_lik:
	.long	.LC82
	.long	.LC83
	.word	410
	.byte	13
	.byte	80
	.word	260
	.zero	2
	.long	.LC84
	.long	.LC85
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC86
	.long	.LC87
	.word	101
	.byte	15
	.byte	0
	.word	0
	.zero	2
	.long	.LC88
	.long	.LC89
	.word	410
	.byte	0
	.byte	28
	.word	0
	.zero	2
	.long	.LC90
	.long	.LC91
	.word	410
	.byte	14
	.byte	0
	.word	258
	.zero	2
	.long	.LC62
	.long	.LC63
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC64
	.long	.LC65
	.word	410
	.byte	0
	.byte	77
	.word	0
	.zero	2
	.long	.LC92
	.long	.LC93
	.word	101
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.text
.LC94:
	.string	"Hold/Freeze"
.LC95:
	.string	"Animate"
.LC96:
	.string	"ANIM"
.LC97:
	.string	"Chord"
.LC98:
	.string	"CHD"
.LC99:
	.string	"Inversion"
.LC100:
	.string	"INV"
.LC101:
	.string	"Spread"
.LC102:
	.string	"SPR"
.LC103:
	.string	"Voices"
.LC104:
	.string	"VOI"
	.text
	.align	2
	.type	cu_grp2k, @object
	.size	cu_grp2k, 128
cu_grp2k:
	.long	.LC62
	.long	.LC63
	.word	410
	.byte	0
	.byte	10
	.word	0
	.zero	2
	.long	.LC80
	.long	.LC81
	.word	410
	.byte	0
	.byte	60
	.word	0
	.zero	2
	.long	.LC94
	.long	.LC89
	.word	410
	.byte	10
	.byte	0
	.word	0
	.zero	2
	.long	.LC95
	.long	.LC96
	.word	410
	.byte	11
	.byte	0
	.word	0
	.zero	2
	.long	.LC97
	.long	.LC98
	.word	410
	.byte	3
	.byte	0
	.word	1552
	.zero	2
	.long	.LC99
	.long	.LC100
	.word	410
	.byte	4
	.byte	0
	.word	1540
	.zero	2
	.long	.LC101
	.long	.LC102
	.word	410
	.byte	5
	.byte	0
	.word	1539
	.zero	2
	.long	.LC103
	.long	.LC104
	.word	410
	.byte	6
	.byte	0
	.word	1543
	.zero	2
	.text
.LC105:
	.string	"Source"
.LC106:
	.string	"Position"
.LC107:
	.string	"POS"
.LC108:
	.string	"Spray"
.LC109:
	.string	"SPRY"
.LC110:
	.string	"Grain Size"
.LC111:
	.string	"SIZE"
.LC112:
	.string	"Density"
.LC113:
	.string	"DENS"
.LC114:
	.string	"Pitch Rand"
.LC115:
	.string	"PRND"
.LC116:
	.string	"Reverse"
.LC117:
	.string	"REV"
.LC118:
	.string	"WIN"
	.text
	.align	2
	.type	cu_grk, @object
	.size	cu_grk, 128
cu_grk:
	.long	.LC105
	.long	.LC69
	.word	410
	.byte	9
	.byte	10
	.word	2944
	.zero	2
	.long	.LC106
	.long	.LC107
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC108
	.long	.LC109
	.word	410
	.byte	0
	.byte	20
	.word	0
	.zero	2
	.long	.LC110
	.long	.LC111
	.word	410
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC112
	.long	.LC113
	.word	410
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC114
	.long	.LC115
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC116
	.long	.LC117
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC4
	.long	.LC118
	.word	410
	.byte	8
	.byte	0
	.word	260
	.zero	2
	.text
.LC119:
	.string	"Env>Pos"
.LC120:
	.string	"ENV"
	.text
	.align	2
	.type	cu_wtp2k, @object
	.size	cu_wtp2k, 128
cu_wtp2k:
	.long	.LC62
	.long	.LC63
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC64
	.long	.LC65
	.word	410
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC92
	.long	.LC93
	.word	410
	.byte	0
	.byte	100
	.word	0
	.zero	2
	.long	.LC119
	.long	.LC120
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC97
	.long	.LC98
	.word	410
	.byte	3
	.byte	0
	.word	1552
	.zero	2
	.long	.LC99
	.long	.LC100
	.word	410
	.byte	4
	.byte	0
	.word	1540
	.zero	2
	.long	.LC101
	.long	.LC102
	.word	410
	.byte	5
	.byte	0
	.word	1539
	.zero	2
	.long	.LC103
	.long	.LC104
	.word	410
	.byte	6
	.byte	0
	.word	1543
	.zero	2
	.text
.LC121:
	.string	"Table"
.LC122:
	.string	"TBL"
.LC123:
	.string	"Warp"
.LC124:
	.string	"WARP"
.LC125:
	.string	"Amount"
.LC126:
	.string	"AMT"
.LC127:
	.string	"Unison"
.LC128:
	.string	"UNI"
.LC129:
	.string	"Sub Osc"
.LC130:
	.string	"SUB"
.LC131:
	.string	"Cutoff"
.LC132:
	.string	"CUT"
.LC133:
	.string	"Resonance"
.LC134:
	.string	"RES"
	.text
	.align	2
	.type	cu_wtk, @object
	.size	cu_wtk, 128
cu_wtk:
	.long	.LC121
	.long	.LC122
	.word	410
	.byte	12
	.byte	1
	.word	2944
	.zero	2
	.long	.LC106
	.long	.LC107
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC123
	.long	.LC124
	.word	410
	.byte	7
	.byte	0
	.word	260
	.zero	2
	.long	.LC125
	.long	.LC126
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC127
	.long	.LC128
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC129
	.long	.LC130
	.word	101
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC131
	.long	.LC132
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC133
	.long	.LC134
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.align	2
	.type	cu_p2k, @object
	.size	cu_p2k, 128
cu_p2k:
	.long	.LC7
	.long	.LC8
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC9
	.long	.LC10
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC14
	.long	.LC15
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC18
	.long	.LC19
	.word	410
	.byte	2
	.byte	0
	.word	259
	.zero	2
	.long	.LC97
	.long	.LC98
	.word	410
	.byte	3
	.byte	0
	.word	1552
	.zero	2
	.long	.LC99
	.long	.LC100
	.word	410
	.byte	4
	.byte	0
	.word	1540
	.zero	2
	.long	.LC101
	.long	.LC102
	.word	410
	.byte	5
	.byte	0
	.word	1539
	.zero	2
	.long	.LC103
	.long	.LC104
	.word	410
	.byte	6
	.byte	0
	.word	1543
	.zero	2
	.text
.LC135:
	.string	"Instrument"
.LC136:
	.string	"INST"
.LC137:
	.string	"Release Trig"
.LC138:
	.string	"RTRG"
	.text
	.align	2
	.type	cu_srck, @object
	.size	cu_srck, 128
cu_srck:
	.long	.LC135
	.long	.LC136
	.word	410
	.byte	12
	.byte	0
	.word	2944
	.zero	2
	.long	.LC78
	.long	.LC79
	.word	410
	.byte	0
	.byte	127
	.word	0
	.zero	2
	.long	.LC20
	.long	.LC21
	.word	101
	.byte	0
	.byte	100
	.word	0
	.zero	2
	.long	.LC137
	.long	.LC138
	.word	410
	.byte	1
	.byte	0
	.word	258
	.zero	2
	.long	.LC62
	.long	.LC63
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC64
	.long	.LC65
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC92
	.long	.LC93
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC80
	.long	.LC81
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
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
	.type	cu_play, @object
	.size	cu_play, 54
cu_play:
	.string	"FWD"
	.zero	2
	.string	"REV"
	.zero	2
	.string	"FLP"
	.zero	2
	.string	"RLP"
	.zero	2
	.string	"SLICE"
	.string	"GRAIN"
	.string	"STRCH"
	.string	"PLUCK"
	.string	"WAVE"
	.zero	1
	.globl	cu_sa_short
	.type	cu_sa_short, @object
	.size	cu_sa_short, 5
cu_sa_short:
	.string	"SMPR"
	.globl	cu_sa_name
	.type	cu_sa_name, @object
	.size	cu_sa_name, 8
cu_sa_name:
	.string	"SAMPLER"
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
	.local	dk_arm
	.comm	dk_arm,1,1
	.local	dk_off
	.comm	dk_off,1,1
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
.LC139:
	.string	"SoundBrowser"
.LC140:
	.string	"KitBrowserView"
.LC141:
	.string	"SongBrowserView"
.LC142:
	.string	"NameView"
.LC143:
	.string	"TapTempoView"
.LC144:
	.string	"ProjectManager"
.LC145:
	.string	"SoundManager"
.LC146:
	.string	"SampleManager"
.LC147:
	.string	"SongEditView"
.LC148:
	.string	"SoundSlotListView"
.LC149:
	.string	"SampleListView"
.LC150:
	.string	"TwoColumnMenu"
.LC151:
	.string	"SceneEditView"
.LC152:
	.string	"PerformanceEditView"
	.text
	.align	2
	.type	ov_names, @object
	.size	ov_names, 56
ov_names:
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
	.long	.LC149
	.long	.LC150
	.long	.LC151
	.long	.LC152
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
	.size	sv, 148
sv:
	.zero	148
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
	.string	"PX`hpH\b@ "
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
	.section	.bss
	.align	4
	.type	pmo, @object
	.size	pmo, 10078
pmo:
	.zero	10078
	.local	qp
	.comm	qp,104,4
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
	.align	4
	.type	fk, @object
	.size	fk, 12
fk:
	.zero	12
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
	.local	fk_claim
	.comm	fk_claim,4,2
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
