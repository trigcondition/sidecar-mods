| Mod 0026 - remote UI: the Rytm as a terminal for Sidecar-drawn pages (M1).
| GENERATED from rui.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit rui.c.
#NO_APP
	.file	"rui.c"
	.text
#APP
	.globl shadow
.set shadow, RAM_RUI_SHADOW
	.globl staging
.set staging, RAM_RUI_STAGING
	.globl comp
.set comp, RAM_RUI_COMP
	.globl comp_in
.set comp_in, RAM_RUI_COMP_IN
	.globl txt_st
.set txt_st, RAM_RUI_TXT_ST
	.globl txt_sh
.set txt_sh, RAM_RUI_TXT_SH
	.globl txt_tl
.set txt_tl, RAM_RUI_TXT_TL
	.globl ux
.set ux, RAM_RUI_UX
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
  .globl ms_pad_det
  .align 2
ms_pad_det:
  move.l %d0,-(%sp)
  move.l 36(%sp),-(%sp)
  move.l 36(%sp),-(%sp)
  move.l %d0,-(%sp)
  move.l 40(%sp),-(%sp)
  move.l 40(%sp),-(%sp)
  jsr ms_pad
  lea 20(%sp),%sp
  tst.l %d0
  bne.s 1f
  move.l (%sp)+,%d0
  movea.l (%a2),%a0
  pea 0xffffffff
  jmp 0x400378c8
1:
  addq.l #8,%sp
  movem.l (%sp),%d2-%d3/%a2
  lea 12(%sp),%sp
  moveq #0,%d0
  rts

	  .text
  .globl ms_knob_det
  .align 2
ms_knob_det:
  lea -16(%sp),%sp
  movem.l %d0-%d1/%a0-%a1,(%sp)
  move.l %d4,-(%sp)
  move.l %d2,-(%sp)
  move.l %a2,-(%sp)
  jsr ms_knob
  lea 12(%sp),%sp
  tst.l %d0
  bne.s 1f
  movem.l (%sp),%d0-%d1/%a0-%a1
  lea 16(%sp),%sp
  move.l %d0,-20(%fp)
  tst.l %d4
  jmp 0x4003a602
1:
  lea 16(%sp),%sp
  moveq #1,%d3
  jmp 0x4003ac56

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
	lea CSWTCH.526,%a0
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
	.type	uart_byte, @function
uart_byte:
	move.b ps_left,%d0
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.b 15(%sp),%d2
	addq.l #1,uart_bytes
	tst.b %d0
	jne .L67
	move.b %d0,ps_pos
	mvz.b %d2,%d0
	move.b %d2,ps_hdr
	mov3q.l #1,%d3
	move.l %d0,%d1
	lsr.l #4,%d1
	cmp.l %d1,%d3
	jeq .L85
	moveq #11,%d3
	cmp.l %d1,%d3
	jeq .L69
	tst.l %d1
	jne .L86
.L89:
	mov3q.l #1,%d0
	jra .L68
.L69:
	cmp.l #179,%d0
	jhi .L70
.L71:
	mov3q.l #3,%d0
.L68:
	subq.l #1,%d0
	move.b %d0,ps_left
.L72:
	move.b %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L70:
	cmp.l #182,%d0
	jeq .L71
	cmp.l #180,%d0
	jeq .L87
	cmp.l #181,%d0
	jeq .L88
	cmp.l #184,%d0
	jeq .L89
.L86:
	mov3q.l #2,%d0
	jra .L68
.L85:
	moveq #10,%d0
	jra .L68
.L87:
	mov3q.l #6,%d0
	jra .L68
.L88:
	mov3q.l #5,%d0
	jra .L68
.L67:
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
	jcs .L73
	and.l %d3,%d0
	lea shs,%a0
	move.b %d2,(%a0,%d0.l)
	jra .L72
.L73:
	move.l %d0,%a0
	lea (80,%a0),%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #4,%d3
	cmp.l %a0,%d3
	jcs .L72
	mvz.b %d1,%d1
	mov3q.l #1,%d3
	cmp.l %d1,%d3
	jne .L75
	move.b %d2,ps_id
	jra .L72
.L75:
	move.b ps_id,%d3
	move.w %d3,%a1
	mvz.b %d3,%d3
	move.l %d3,%a0
	moveq #55,%d3
	cmp.l %a0,%d3
	jne .L76
	mvz.b %d0,%d3
	cmp.l #180,%d3
	jne .L77
	move.l %d1,%d0
	subq.l #2,%d0
.L78:
	lea sht,%a0
	move.b %d2,(%a0,%d0.l)
	tst.b ovt_on.l
	jeq .L72
	move.b ovt_col,%d2
	addq.l #1,uart_sub
	jra .L72
.L77:
	mov3q.l #3,%d1
	and.l %d1,%d0
	jra .L78
.L76:
	lea (-40,%a1),%a1
	move.w %a1,%d3
	mvz.b %d3,%d3
	move.l %d3,%a1
	mov3q.l #3,%d3
	cmp.l %a1,%d3
	jcs .L79
	move.w #43,%a1
	mvz.b %d0,%d3
	sub.l %a0,%a1
	cmp.l #180,%d3
	jne .L80
	subq.l #2,%d1
.L81:
	move.l %a1,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #shp,%a0
	mvz.b ovp_on,%d0
	move.b %d2,(%a0,%d1.l)
	move.l %a1,%d1
	btst %d1,%d0
	jeq .L72
	addq.l #1,uart_sub
	lea ovp_col,%a0
.L105:
	move.b (%a1,%a0.l),%d2
	jra .L72
.L80:
	mov3q.l #3,%d1
	and.l %d0,%d1
	jra .L81
.L79:
	moveq #15,%d3
	cmp.l %a0,%d3
	jcs .L72
	mvz.b %d0,%d3
	cmp.l #180,%d3
	jne .L82
	subq.l #2,%d1
.L83:
	move.l %a0,%d0
	lsl.l #2,%d0
	move.l %d0,%a1
	add.l #sh,%a1
	move.b %d2,(%a1,%d1.l)
	tst.b ov_on.l
	jne .L84
	moveq #13,%d0
	cmp.l %a0,%d0
	jcc .L84
	mvz.b ovm_on,%d1
	move.l %a0,%d0
	add.l #-14,%d0
	btst %d0,%d1
	jeq .L84
	lea ovm_col,%a0
	move.b (%a0,%d0.l),%d2
	addq.l #1,uart_sub
	jra .L72
.L82:
	mov3q.l #3,%d1
	and.l %d0,%d1
	jra .L83
.L84:
	tst.b ov_on.l
	jeq .L72
	addq.l #1,uart_sub
	lea ov_col,%a1
	jra .L105
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
	jcc .L108
	addq.l #1,sq+384
.L107:
	move.l (%sp)+,%a2
	rts
.L108:
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
	jeq .L110
	move.l %a2,%d0
	addq.l #8,%d0
.L111:
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
	jra .L107
.L110:
	move.l %a2,%d0
	add.l #9,%d0
	move.b 19(%sp),8(%a2)
	jra .L111
	.size	sq_event, .-sq_event
	.align	2
	.type	sq_grid, @function
sq_grid:
	move.l 1100949720,%a0
	move.l %a0,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L115
	tst.b 353(%a0)
	jeq .L115
	tst.b 360(%a0)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L112:
	rts
.L115:
	clr.l %d0
	jra .L112
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
	jcs .L119
	moveq #39,%d1
	cmp.l %d0,%d1
	jcs .L120
.L121:
	clr.l %d0
	jra .L118
.L119:
	move.l %d0,%d1
	mov3q.l #6,%d0
	add.l #-46,%d1
	cmp.l %d1,%d0
	jcs .L121
	moveq #75,%d0
	lsr.l %d1,%d0
	mov3q.l #1,%d1
	and.l %d1,%d0
.L118:
	rts
.L120:
	tst.l ls_host_presets
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L118
	.size	ls_banked, .-ls_banked
	.align	2
	.type	ls_queue, @function
ls_queue:
	lea (-16,%sp),%sp
	movem.l #1052,(%sp)
	mvz.b ls+128,%d0
	mov3q.l #-1,-(%sp)
	lea ls,%a2
	mov3q.l #3,%d2
	move.l %d0,-(%sp)
	mvz.b ls+1,%d0
	move.l %d0,-(%sp)
	jsr sv_word
	lea (12,%sp),%sp
	move.l ls+28,%d1
	cmp.l %d1,%d2
	jcc .L125
	addq.l #1,ls+96
.L124:
	movem.l (%sp),#1052
	lea (16,%sp),%sp
	rts
.L125:
	mov3q.l #6,%d2
	muls.l %d1,%d2
	lea ls+1,%a1
	mov3q.l #6,%d4
	lea (%a2,%d2.l),%a0
	move.b (%a1),4(%a0)
	move.l %d1,%a1
	addq.l #1,%a1
	move.l %a1,%d3
	muls.l %d4,%d3
	move.b 23(%sp),5(%a0)
	move.b 27(%sp),8(%a0)
	moveq #12,%d4
	move.l %d3,%a1
	move.l %d0,%d3
	lsr.l #7,%d3
	move.b %d3,(%a2,%a1.l)
	moveq #127,%d3
	and.l %d3,%d0
	move.b %d0,7(%a0)
	move.b ls+128,%d0
	mvz.b %d0,%d3
	cmp.l %d3,%d4
	jeq .L127
	clr.b %d0
.L127:
	addq.l #1,%d1
	move.b %d0,9(%a2,%d2.l)
	move.l %d1,ls+28
	jra .L124
	.size	ls_queue, .-ls_queue
	.align	2
	.type	ls_p13, @function
ls_p13:
	move.b 1093765506,%d1
	tst.l ls_host_p13
	jne .L130
.L132:
	clr.l %d0
.L129:
	rts
.L130:
	mvz.b %d1,%d0
	move.l %d0,%a1
	moveq #11,%d0
	cmp.l %a1,%d0
	jlt .L132
	mov3q.l #1,%d0
	cmp.l sv+148.l,%d0
	jne .L132
	moveq #127,%d0
	ext.w %d1
	and.l -2147457096,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d0
	moveq #46,%d1
	cmp.l %d0,%d1
	jne .L132
	pea 46.w
	move.l %a1,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	moveq #127,%d1
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jeq .L132
	move.l st+4,%d0
	or.l st+972,%d0
	jne .L132
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L132
	moveq #19,%d1
	cmp.l sv+16.l,%d1
	jcs .L132
	tst.l commits
	jeq .L132
	move.l st+968,%d0
	addq.l #1,%d0
	cmp.l ls+138.l,%d0
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L129
	.size	ls_p13, .-ls_p13
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
	jeq .L140
	tst.l %d0
	jeq .L140
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
.L140:
	move.l %d3,-(%sp)
	jsr 1075557020
	move.l -32(%fp),%d2
	addq.l #4,%sp
	move.l -28(%fp),%d3
	unlk %fp
	rts
	.size	pm_popup, .-pm_popup
	.align	2
	.type	ram_zero, @function
ram_zero:
	move.l %d2,-(%sp)
	move.l 12(%sp),%d1
	addq.l #3,%d1
	lsr.l #2,%d1
	move.l 8(%sp),%a0
	clr.l %d0
.L148:
	mvz.w %d0,%d2
	addq.l #1,%d0
	clr.l (%a0,%d2.l*4)
	cmp.l %d0,%d1
	jne .L148
	move.l (%sp)+,%d2
	rts
	.size	ram_zero, .-ram_zero
	.align	2
	.type	ms_stock_ok, @function
ms_stock_ok:
	tst.l ms
	jne .L151
.L153:
	clr.l %d0
.L150:
	rts
.L151:
	tst.b ls.l
	jne .L153
	move.l st+4,%d0
	or.l st+972,%d0
	or.l sq+408,%d0
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L150
	.size	ms_stock_ok, .-ms_stock_ok
	.align	2
	.type	ms_say, @function
ms_say:
	move.l 4(%sp),%a0
	clr.l %d0
	lea ms+192,%a1
.L155:
	move.b (%a0,%d0.l),%d1
	jeq .L156
	move.b %d1,(%a1,%d0.l)
	addq.l #1,%d0
	moveq #19,%d1
	cmp.l %d0,%d1
	jne .L155
.L156:
	clr.b %d1
	add.l #ms,%d0
	move.l %d0,%a0
	move.b %d1,192(%a0)
	move.l st+8,%a0
	lea (20,%a0),%a0
	move.l %a0,%d0
	tst.l %a0
	jne .L158
	mov3q.l #1,%d0
.L158:
	move.l %d0,ms+188
	rts
	.size	ms_say, .-ms_say
	.align	2
	.type	cu_tab, @function
cu_tab:
	move.l %d2,-(%sp)
	moveq #12,%d2
	move.l 8(%sp),%d1
	add.l #-40,%d1
	move.l 12(%sp),%d0
	cmp.l %d1,%d2
	jcs .L173
	move.w .L165(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&13
.L165:
	.word .L172-.L165
	.word .L173-.L165
	.word .L173-.L165
	.word .L171-.L165
	.word .L173-.L165
	.word .L173-.L165
	.word .L170-.L165
	.word .L169-.L165
	.word .L168-.L165
	.word .L167-.L165
	.word .L166-.L165
	.word .L173-.L165
	.word .L164-.L165
.L170:
	tst.l %d0
	jeq .L174
	move.l #cu_wtp2k,%d0
.L162:
	move.l (%sp)+,%d2
	rts
.L169:
	tst.l %d0
	jeq .L175
	move.l #cu_grp2k,%d0
	jra .L162
.L164:
	tst.l %d0
	jne .L181
	move.l #cu_srck,%d0
	jra .L162
.L168:
	tst.l %d0
	jeq .L177
	move.l #cu_lip2k,%d0
	jra .L162
.L167:
	tst.l %d0
	jeq .L178
	move.l #cu_cpp2k,%d0
	jra .L162
.L166:
	tst.l %d0
	jeq .L179
	move.l #cu_mip2k,%d0
	jra .L162
.L171:
	tst.l %d0
	jeq .L162
	move.l #cu_sap2k,%d0
	jra .L162
.L172:
	tst.l %d0
	jeq .L162
.L181:
	move.l #cu_p2k,%d0
	jra .L162
.L173:
	clr.l %d0
	jra .L162
.L174:
	move.l #cu_wtk,%d0
	jra .L162
.L175:
	move.l #cu_grk,%d0
	jra .L162
.L177:
	move.l #cu_lik,%d0
	jra .L162
.L178:
	move.l #cu_cpk,%d0
	jra .L162
.L179:
	move.l #cu_mik,%d0
	jra .L162
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
.L187:
	mvs.w (%a3,%a0.l),%d5
	cmp.l %d5,%d6
	jne .L183
	tst.l %d7
	jeq .L185
	mvz.b (%a1),%d1
.L185:
	add.l #16,%d0
	lea (16,%a1),%a1
	addq.l #2,%a0
	moveq #16,%d5
	cmp.l %a0,%d5
	jne .L187
	cmp.l #441,%d6
	jne .L188
	moveq #12,%d1
.L188:
	move.l %d3,%d0
	moveq #127,%d5
	cmp.l %d3,%d5
	jge .L189
	moveq #127,%d0
.L190:
	addq.l #1,cu+4
	subq.l #1,%d1
	moveq #33,%d5
	cmp.l %d1,%d5
	jcs .L191
	move.w .L193(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&34
.L193:
	.word .L224-.L193
	.word .L223-.L193
	.word .L222-.L193
	.word .L221-.L193
	.word .L220-.L193
	.word .L219-.L193
	.word .L218-.L193
	.word .L217-.L193
	.word .L214-.L193
	.word .L216-.L193
	.word .L215-.L193
	.word .L214-.L193
	.word .L213-.L193
	.word .L212-.L193
	.word .L211-.L193
	.word .L210-.L193
	.word .L209-.L193
	.word .L208-.L193
	.word .L207-.L193
	.word .L206-.L193
	.word .L191-.L193
	.word .L205-.L193
	.word .L204-.L193
	.word .L203-.L193
	.word .L202-.L193
	.word .L201-.L193
	.word .L200-.L193
	.word .L199-.L193
	.word .L198-.L193
	.word .L195-.L193
	.word .L196-.L193
	.word .L195-.L193
	.word .L194-.L193
	.word .L192-.L193
.L183:
	mvs.w (%a4,%a0.l),%d5
	cmp.l %d5,%d6
	jne .L185
	tst.l %a2
	jeq .L185
	move.l %d0,%a5
	mvz.b (%a5),%d1
	jra .L185
.L189:
	tst.l %d3
	jge .L190
	clr.l %d0
	jra .L190
.L224:
	moveq #63,%d0
	cmp.l %d3,%d0
	jge .L241
	move.l #cu_loop+10,%d0
.L275:
	move.l %d0,60(%sp)
	move.l #cu_fmt_s,%d1
.L264:
	move.l %d1,56(%sp)
	jra .L260
.L241:
	move.l #cu_loop+5,%d0
	jra .L275
.L223:
	muls.w #3,%d0
	asr.l #7,%d0
	mulu.w #5,%d0
	add.l #cu_loop,%d0
.L272:
	move.l %d0,60(%sp)
	move.l #cu_fmt_s,%d3
	jra .L266
.L222:
	moveq #15,%d5
	cmp.l %d3,%d5
	jge .L226
	clr.l %d0
.L226:
	mulu.w #5,%d0
	add.l #cu_chd,%d0
.L278:
	move.l %d0,60(%sp)
	lea cu_fmt_s,%a0
	jra .L265
.L221:
	mov3q.l #3,%d1
	cmp.l %d3,%d1
	jge .L227
	clr.l %d0
.L227:
	move.l %d0,60(%sp)
	move.l #cu_fmt_inv,%d3
.L266:
	move.l %d3,56(%sp)
.L260:
	move.l %d2,52(%sp)
	movem.l (%sp),#15612
	lea (48,%sp),%sp
	jmp 1074365954
.L220:
	mov3q.l #2,%d5
	cmp.l %d3,%d5
	jge .L228
	clr.l %d0
.L228:
	move.l %d0,60(%sp)
	lea cu_fmt_spr,%a0
.L265:
	move.l %a0,56(%sp)
	jra .L260
.L219:
	move.l %d0,%d1
	mov3q.l #5,%d3
	subq.l #1,%d1
	cmp.l %d1,%d3
	jcs .L229
.L276:
	move.l %d0,60(%sp)
	move.l #cu_fmt_d,%d5
	jra .L267
.L229:
	lea cu_loop,%a0
	move.l %a0,60(%sp)
.L263:
	lea cu_fmt_s,%a5
	jra .L261
.L218:
	muls.w #9,%d0
	asr.l #7,%d0
	mulu.w #5,%d0
	add.l #cu_warp,%d0
.L268:
	move.l %d0,60(%sp)
	jra .L270
.L217:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #6,%d0
	add.l #cu_win,%d0
	jra .L275
.L216:
	moveq #119,%d5
	cmp.l %d3,%d5
	jlt .L230
	muls.w #99,%d0
	divs.l %d5,%d0
.L269:
	move.l %d0,60(%sp)
	lea cu_fmt_d,%a0
	jra .L265
.L230:
	lea cu_frz,%a5
	move.l %a5,60(%sp)
.L270:
	move.l #cu_fmt_s,%d0
	move.l %d0,56(%sp)
	jra .L260
.L215:
	tst.l %d3
	jle .L231
	asr.l #4,%d0
	mulu.w #5,%d0
	add.l #cu_anim,%d0
	jra .L275
.L213:
	mvs.w %d0,%d0
	lsr.l #3,%d0
	and.l #262140,%d0
	add.l #cu_inpt,%d0
	jra .L278
.L212:
	mvs.w %d0,%d0
	asr.l #6,%d0
	mulu.w #5,%d0
	add.l #cu_mon,%d0
.L262:
	move.l %d0,60(%sp)
	jra .L263
.L211:
	tst.l %d3
	jle .L231
	muls.w #60,%d0
	moveq #126,%d3
	move.l #cu_fmt_db,%d5
	addq.l #3,%d0
	divs.l %d3,%d0
	add.l #-80,%d0
	move.l %d0,60(%sp)
.L267:
	move.l %d5,56(%sp)
	jra .L260
.L210:
	asr.l #1,%d0
	addq.l #1,%d0
	jra .L269
.L209:
	moveq #63,%d1
	cmp.l %d3,%d1
	jge .L232
	muls.w #48,%d0
	moveq #126,%d3
	add.l #-3009,%d0
	divs.l %d3,%d0
	tst.l %d0
	jeq .L246
.L274:
	move.l #cu_fmt_pd,%d1
.L235:
	move.l %d0,60(%sp)
	jra .L264
.L232:
	moveq #64,%d1
	moveq #-126,%d5
	sub.l %d0,%d1
	muls.w #48,%d1
	move.l %d1,%d0
	add.l #63,%d0
	divs.l %d5,%d0
.L246:
	move.l #cu_fmt_d,%d1
	jra .L235
.L208:
	muls.w #100,%d0
	moveq #127,%d3
	move.l #cu_fmt_pct,%d5
	add.l #63,%d0
	divs.l %d3,%d0
	move.l %d0,60(%sp)
	jra .L267
.L207:
	tst.l %d3
	jgt .L269
.L231:
	move.l #cu_off,%d3
.L271:
	move.l %d3,60(%sp)
	jra .L273
.L206:
	mvs.w %d0,%d0
	asr.l #3,%d0
	jeq .L234
	addq.l #1,%d0
	move.l %d0,60(%sp)
	lea cu_fmt_x,%a5
.L261:
	move.l %a5,56(%sp)
	jra .L260
.L205:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_tape,%d0
	jra .L272
.L204:
	muls.w #3,%d0
	lsr.l #5,%d0
	and.l #262140,%d0
	add.l #cu_dir,%d0
	move.l %d0,60(%sp)
.L273:
	move.l #cu_fmt_s,%d5
	jra .L267
.L203:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_cloop,%d0
	jra .L278
.L202:
	tst.l %d3
	jle .L234
.L191:
	move.l %d0,60(%sp)
	lea cu_fmt_d,%a5
	jra .L261
.L200:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_dst,%d0
	jra .L268
.L199:
	mvs.w %d0,%d0
	asr.l #3,%d0
	move.l #cu_fmt_d,%d1
	addq.l #1,%d0
	move.l %d0,60(%sp)
	jra .L264
.L198:
	tst.l %d3
	jle .L231
	add.l #-64,%d0
	moveq #64,%d5
	cmp.l %d3,%d5
	jge .L246
	jra .L274
.L196:
	tst.l %d3
	jle .L231
	subq.l #1,%d0
	muls.w #127,%d0
	moveq #126,%d3
	divs.l %d3,%d0
	jra .L276
.L195:
	tst.l %d3
	jle .L231
	subq.l #1,%d0
	jra .L269
.L194:
	muls.w #9,%d0
	asr.l #7,%d0
	mulu.w #6,%d0
	add.l #cu_play,%d0
	jra .L262
.L192:
	asr.l #4,%d0
	mulu.w #5,%d0
	add.l #cu_ftyp,%d0
	jra .L268
.L201:
	moveq #126,%d1
	cmp.l %d3,%d1
	jge .L236
	move.l #cu_hold,%d3
	jra .L271
.L236:
	tst.l %d3
	jgt .L269
.L234:
	move.l #cu_slc,%d0
	jra .L275
.L214:
	cmp.l #441,%d6
	jeq .L247
	move.b 43(%sp),%d5
	mov3q.l #6,%d1
	add.l #-46,%d5
	mvz.b %d5,%d5
	cmp.l %d5,%d1
	jcs .L248
	lea CSWTCH.599,%a0
	mvs.b (%a0,%d5.l),%d1
.L237:
	tst.l %d3
	jle .L231
	asr.l #5,%d4
	mov3q.l #7,%d3
	mov3q.l #-1,%d5
	and.l %d3,%d4
	cmp.l %d1,%d5
	jeq .L238
	tst.l st
	jeq .L238
	lea ux,%a1
	lea (%a1,%d1.l),%a0
	mvz.b 3948(%a0),%d3
	cmp.l %d3,%d4
	jne .L238
	mvz.w #1280,%d3
	moveq #10,%d5
	muls.l %d0,%d5
	muls.l %d1,%d3
	move.l %d5,%a0
	add.l %d3,%a0
	tst.b 40(%a1,%a0.l)
	jeq .L238
	mulu.w #10,%d0
	mulu.w #1280,%d1
	move.l %d0,%a0
	lea 40(%a0,%d1.l),%a0
	move.l %a0,%d0
	add.l %a1,%d0
	jra .L262
.L247:
	clr.l %d1
	jra .L237
.L248:
	mov3q.l #-1,%d1
	jra .L237
.L238:
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
.L281:
	lea (%a2,%d0.l),%a4
	moveq #84,%d2
	move.l %d1,%a3
	move.l (%a4),(%a3,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d2
	jne .L281
	tst.b 10(%a1)
	jeq .L282
	lea cu_text,%a2
	move.l %a2,32(%a3)
.L282:
	move.l (%a1),40(%a0)
	move.l 4(%a1),48(%a0)
	move.l 28(%sp),44(%a0)
	mvz.b 14(%a1),%d0
	move.w 12(%a1),%d1
	lsl.l #8,%d0
	and.l #2048,%d1
	move.l %d0,8(%a0)
	move.b 15(%a1),%d0
	jeq .L283
	mvz.b %d0,%d0
	lsl.l #8,%d0
.L284:
	move.l %d0,12(%a0)
	mvz.b 11(%a1),%d0
	lsl.l #8,%d0
	move.l %d0,16(%a0)
	tst.w %d1
	jeq .L280
	mov3q.l #1,20(%a0)
.L280:
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	rts
.L283:
	tst.w %d1
	jeq .L286
	mvz.w #32736,%d0
	jra .L284
.L286:
	mvz.w #32512,%d0
	jra .L284
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
	jeq .L291
	moveq #40,%d0
	cmp.l %d2,%d0
	jeq .L291
	move.l #1094564988,%a0
.L293:
	move.l (%a0),%d0
	addq.l #4,%a0
	move.l %d0,-68(%a0)
	move.l %d0,-100(%a0)
	move.l %d0,-132(%a0)
	move.l %d0,-164(%a0)
	move.l %d0,-196(%a0)
	cmp.l #1094565020,%a0
	jne .L293
	mvz.b cu+8,%d0
	cmp.l %d0,%d2
	jeq .L294
.L296:
	move.l %d2,%d5
	clr.l %d3
	add.l #-43,%d5
	lea cu_src,%a6
	lea CSWTCH.597,%a5
	lea cu_knob,%a4
	move.l #1075575064,%a3
.L295:
	moveq #9,%d0
	cmp.l %d5,%d0
	jcs .L298
	move.l (%a5,%d5.l*4),%d0
.L297:
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
	jne .L295
	move.b %d2,cu+8
	jra .L291
.L294:
	move.l 1075595808,%d0
	cmp.l 4(%a2),%d0
	jne .L296
	move.l 1075596276,%d0
	cmp.l 116(%a2),%d0
	jne .L296
	cmp.l 1075595760.l,%d2
	jne .L296
.L291:
	movem.l (%sp),#31804
	lea (36,%sp),%sp
	rts
.L298:
	move.l #cu_fm_short,%d0
	jra .L297
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
	jle .L308
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
	jgt .L309
	mvz.b %d0,%d2
	mov3q.l #2,%d4
	move.l %d2,%a0
	lea (-48,%a0),%a0
	cmp.l %a0,%d4
	jcc .L310
	moveq #43,%d3
	cmp.l %d2,%d3
	jne .L309
.L310:
	move.b %d0,cu+9
	mvz.b cu+30,%d0
	lea st+8,%a0
	move.b %d1,cu+10
	move.l (%a0),cu+16
	cmp.l %d0,%d1
	jne .L323
	move.b cu+28,%d0
.L311:
	move.b %d0,cu+29
.L309:
	clr.l %d0
.L307:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L323:
	clr.b %d0
	jra .L311
.L308:
	tst.l %d2
	jge .L313
	mvz.b cu+9,%d0
	moveq #50,%d1
	cmp.l %d0,%d1
	jne .L314
	mvz.b cu+10,%d1
	move.l %d2,%d0
	not.l %d0
	cmp.l %d1,%d0
	jeq .L324
.L314:
	mvz.b cu+11,%d0
	neg.l %d2
	cmp.l %d0,%d2
	jne .L309
	move.l st+8,%d0
	mov3q.l #3,%d2
	sub.l cu+24,%d0
	cmp.l %d0,%d2
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L307
.L313:
	cmp.l #441,%d2
	jeq .L325
	lea cu_src,%a0
	clr.l %d3
.L316:
	mvs.w (%a0),%d1
	cmp.l %d1,%d2
	jne .L315
	mvz.b cu+8,%d0
	clr.l -(%sp)
	move.l %d0,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L309
	mvz.w %d3,%d3
	move.l %d0,%a0
	lsl.l #4,%d3
	mvz.w 12(%a0,%d3.l),%d0
	jra .L307
.L315:
	addq.l #2,%a0
	addq.l #1,%d3
	moveq #8,%d1
	cmp.l %d3,%d1
	jne .L316
	mvz.b %d0,%d0
	moveq #11,%d3
	cmp.l %d0,%d3
	jge .L317
	clr.l %d0
.L317:
	moveq #127,%d1
	and.l -2147457096,%d1
	mulu.w #152,%d0
	mulu.w #2531,%d1
	move.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0,%d0.l),%d3
	mvz.b cu+1,%d0
	cmp.l %d3,%d0
	jne .L309
	mov3q.l #1,-(%sp)
	move.l %d3,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L309
	move.l 1075596172,%d1
	move.l %d0,%a0
	cmp.l 116(%a0),%d1
	jne .L309
	lea cu_p2,%a0
	clr.l %d1
.L318:
	mvs.w (%a0),%d4
	cmp.l %d4,%d2
	jne .L319
	moveq #40,%d2
	cmp.l %d3,%d2
	jne .L322
	mov3q.l #3,%d2
	cmp.l %d1,%d2
	jge .L309
.L322:
	mvz.w %d1,%d1
	move.l %d0,%a0
	lsl.l #4,%d1
	mvz.w 12(%a0,%d1.l),%d0
	jra .L307
.L319:
	addq.l #2,%a0
	addq.l #1,%d1
	moveq #8,%d4
	cmp.l %d1,%d4
	jne .L318
	jra .L309
.L324:
	mov3q.l #1,%d0
	jra .L307
.L325:
	mvz.w #2944,%d0
	jra .L307
	.size	cu_steps, .-cu_steps
	.align	2
	.type	pmo_off, @function
pmo_off:
	move.l %d2,-(%sp)
	move.l 8(%sp),%a0
	move.l 12(%sp),%d0
	move.l 16(%sp),%d1
	move.l %d0,12(%a0)
	tst.l %d1
	jne .L339
	move.l %d0,4(%a0)
.L340:
	move.b %d1,2(%a0)
	move.l (%sp)+,%d2
	rts
.L339:
	sub.l 4(%a0),%d0
	moveq #9,%d2
	lea pmo_rcp,%a1
	asr.l %d2,%d0
	moveq #127,%d2
	and.l %d1,%d2
	mvz.w (%a1,%d2.l*2),%d2
	muls.l %d2,%d0
	asr.l #6,%d0
	move.l %d0,8(%a0)
	jra .L340
	.size	pmo_off, .-pmo_off
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
	jne .L342
	move.l %d0,28(%a0)
	clr.b %d0
	move.l %d1,16(%a0)
.L343:
	move.b %d0,3(%a0)
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L342:
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
	jra .L343
	.size	pmo_mix, .-pmo_mix
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
.L347:
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr (%a2)
	addq.l #1,%a6
	addq.l #4,%d2
	addq.l #8,%sp
	moveq #16,%d0
	cmp.l %a6,%d0
	jne .L347
	move.l %sp,%d2
	sub.l %a6,%a6
	lea shs,%a3
	add.l #22,%d2
	lea rui_uart_raw,%a2
.L349:
	move.b (%a3,%a6.l),%d0
	mvz.b %d0,%d1
	cmp.l #255,%d1
	jeq .L348
	move.l %a6,%d1
	moveq #32,%d3
	or.l %d3,%d1
	move.b %d0,23(%sp)
	move.b %d1,22(%sp)
	move.l %d2,-(%sp)
	mov3q.l #2,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
.L348:
	addq.l #1,%a6
	mov3q.l #4,%d0
	cmp.l %a6,%d0
	jne .L349
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
	jne .L356
	lea txsx_wait,%a2
	jsr (%a2)
	move.l %d0,%d2
	tst.l %d0
	jeq .L357
	addq.l #1,st+40
.L356:
	clr.l %d2
.L355:
	move.l %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L357:
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L359
	addq.l #1,st+40
	jra .L355
.L359:
	jsr (%a2)
	tst.l %d0
	jne .L360
	mvz.w #4027,%d0
	cmp.l 1094562392.l,%d0
	jlt .L360
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L361:
	tst.l %a0
	jeq .L360
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L361
	move.l 12(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	mov3q.l #1,%d2
	addq.l #1,st+36
	jra .L355
.L360:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #1,st+40
	addq.l #4,%sp
	jra .L355
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
.L370:
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
	jgt .L370
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
	jne .L373
	mvz.b mr+18,%d0
	cmp.l -12(%fp),%d0
	jeq .L372
.L373:
	pea 8.w
	pea -8(%fp)
	move.b -9(%fp),-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L372
	clr.b %d0
	lea (-9,%fp),%a0
	move.b (%a0),mr+18
	move.b %d0,mr+19
	move.w mr+20,%d0
	addq.l #1,%d0
	move.w %d0,mr+20
.L372:
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
.L380:
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
	jeq .L379
	addq.l #1,%d1
.L379:
	lea (152,%a1),%a1
	cmp.l #1824,%a1
	jne .L380
	tst.b mr+12.l
	jne .L381
	sub.l %a0,%a0
.L382:
	lea (%a2,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a3,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L382
	moveq #127,%d0
	and.l -2147457096,%d0
	move.b %d0,mr+18
	moveq #1,%d0
	move.b %d0,mr+12
.L383:
	mov3q.l #1,%a6
	jra .L378
.L381:
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L384
	move.b %d0,mr+13
.L385:
	move.l %a2,-(%sp)
	pea 12.w
	clr.l -(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L378
	sub.l %a0,%a0
.L388:
	lea (%a2,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a3,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L388
	clr.b %d0
	move.b %d0,mr+13
	move.w mr+16,%d0
	addq.l #1,%d0
	move.w %d0,mr+16
	jsr kit_tick
.L378:
	move.l %a6,%d0
	movem.l (%sp),#23556
	lea (32,%sp),%sp
	rts
.L384:
	clr.l %d2
	tst.b mr+13.l
	jne .L385
.L386:
	mvz.b (%a3,%d2.l),%d0
	mvz.b (%a2)+,%d1
	cmp.l %d1,%d0
	jeq .L390
	pea 20(%sp)
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L378
	lea (-1,%a2),%a0
	move.b (%a0),(%a3,%d2.l)
	move.w mr+14,%d0
	addq.l #1,%d0
	move.w %d0,mr+14
.L390:
	addq.l #1,%d2
	moveq #12,%d0
	cmp.l %d2,%d0
	jne .L386
	jsr kit_tick
	jra .L383
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
.L409:
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
	jeq .L404
	clr.w %d7
	lea ar+48,%a3
	move.w %d7,(%a5,%d1.l*2)
	moveq #127,%d1
	and.l -2147457096,%d1
	mvz.b (%a3,%a6.l),%d6
	cmp.l %d6,%d1
	jne .L404
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
.L404:
	move.b 1(%a0),%d6
	move.b (%a0),%d0
	lsl.l #2,%d6
	mvz.b %d0,%d1
	and.l #768,%d6
	or.l %d1,%d6
	mvz.w (%a2),%d1
	cmp.l %d1,%d6
	jne .L405
	mvz.w ar+60,%d1
	move.l %a6,%d7
	btst %d7,%d1
	jeq .L406
.L405:
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
	jeq .L403
	move.w %d6,(%a2)
	move.l %a6,%d1
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	addq.l #1,ar+62
	move.w ar+60,%d1
	not.l %d0
	and.l %d1,%d0
	move.w %d0,ar+60
.L406:
	addq.l #1,%a6
	add.l #152,%d5
	addq.l #2,%a2
	add.l #162,%d4
	moveq #12,%d6
	cmp.l %a6,%d6
	jne .L409
.L403:
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
.L418:
	lea (%a1,%d0.l),%a2
	move.b (%a2),-9(%fp,%d0.l)
	move.l %d0,%a0
	addq.l #1,%d0
	cmp.l 16(%fp),%d0
	jne .L418
	moveq #-9,%d0
	move.b %d0,-8(%fp,%a0.l)
	pea 9(%a0)
	pea -16(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L417
	addq.l #1,sq+456
.L417:
	move.l -20(%fp),%a2
	unlk %fp
	rts
	.size	sq_send2, .-sq_send2
	.align	2
	.type	ms_send, @function
ms_send:
	lea (-40,%sp),%sp
	movem.l #23564,(%sp)
	lea ms+88,%a2
	sub.l %a6,%a6
	move.l #-260222380,%d2
	lea (25,%sp),%a3
.L425:
	cmp.l ms+152.l,%a6
	jcc .L431
	move.w #11521,%d0
	move.l %d2,25(%sp)
	moveq #18,%d1
	move.w %d0,29(%sp)
	move.b (%a2),%d0
	move.b %d0,31(%sp)
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jne .L434
	mov3q.l #7,%d0
.L426:
	sub.l %a0,%a0
.L427:
	addq.l #1,%a0
	lea (%a2,%a0.l),%a1
	move.b (%a1),31(%a0,%sp.l)
	cmp.l %a0,%d0
	jne .L427
	moveq #-9,%d0
	move.b %d0,32(%sp,%a0.l)
	pea 8(%a0)
	move.l %a3,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jne .L428
.L431:
	move.l ms+152,%a2
	move.l %a6,%d0
	clr.l %d1
.L429:
	cmp.l %a2,%d0
	jcs .L433
	sub.l %a6,%a2
	move.l %a2,ms+152
	movem.l (%sp),#23564
	lea (40,%sp),%sp
	rts
.L434:
	mov3q.l #3,%d0
	jra .L426
.L428:
	addq.l #8,%a2
	addq.l #1,%a6
	addq.l #1,ms+244
	jra .L425
.L433:
	move.l %d0,%d2
	sub.l %a0,%a0
	lsl.l #3,%d2
	lea ms+88,%a1
	sub.l %d1,%a1
.L432:
	lea (%a1,%d1.l),%a3
	addq.l #1,%a0
	move.b (%a3,%d2.l),(%a1)+
	moveq #8,%d3
	cmp.l %a0,%d3
	jne .L432
	addq.l #1,%d0
	subq.l #8,%d1
	jra .L429
	.size	ms_send, .-ms_send
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
.L441:
	moveq #15,%d3
	cmp.l %d0,%d3
	jcs .L456
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
	jeq .L442
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
.L442:
	addq.l #1,%d1
	cmp.l #256,%d1
	jne .L441
.L456:
	tst.b %d2
	jeq .L440
	move.l %a0,kq_owes
	move.l %d0,st+196
.L440:
	movem.l (%sp),#3324
	lea (32,%sp),%sp
	rts
	.size	kq_owed_in.part.0, .-kq_owed_in.part.0
	.align	2
	.type	flush, @function
flush:
	link.w %fp,#-44
	movem.l #15372,(%sp)
	tst.b st+992.l
	jeq .L458
	move.l st+8,%d0
	cmp.l #16383,%d0
	jls .L459
	mvz.w #16383,%d0
.L459:
	move.l #-260222380,%d1
	move.l %d1,-13(%fp)
	move.l %d0,%d1
	lsr.l #7,%d1
	move.w #13569,%d3
	clr.l ms
	move.b %d1,-7(%fp)
	moveq #127,%d1
	and.l %d1,%d0
	move.w %d3,-9(%fp)
	move.w #32575,%d3
	move.b %d0,-6(%fp)
	moveq #-9,%d0
	move.w %d3,-5(%fp)
	move.b %d0,-3(%fp)
	tst.l st+1106
	jeq .L460
	clr.l ms+152
	clr.l ms+16
	clr.l ms+60
	clr.l ms+4
	clr.l ms+8
.L460:
	pea 11.w
	pea -13(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L457
	clr.b %d1
	addq.l #1,st+968
	addq.l #1,qp+8
	mov3q.l #1,qp+48
	mov3q.l #1,qp+100
	move.b %d1,st+992
	tst.l st+1106
	jeq .L458
	clr.l st+1106
	addq.l #1,pmo+68
.L458:
	tst.b st+161.l
	jeq .L464
	move.w st+162,%d1
	lea st+993,%a1
	move.l #-260222380,%d3
	move.w #12289,%a0
	move.b (%a1),-7(%fp)
	pea 10.w
	pea -13(%fp)
	move.l %d3,-13(%fp)
	mvz.w %d1,%d0
	lsr.l #8,%d0
	lsl.l #8,%d1
	move.w %a0,-9(%fp)
	add.l %d1,%d0
	move.w %d0,-6(%fp)
	moveq #-9,%d0
	move.b %d0,-4(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L457
	clr.b %d1
	move.b %d1,st+161
.L464:
	move.w #18945,%a4
	lea ls+4,%a0
	sub.l %a2,%a2
	move.l %fp,%d2
	move.l #-260222380,%a3
	move.l %a0,-20(%fp)
	add.l #-13,%d2
.L466:
	cmp.l ls+28.l,%a2
	jcs .L470
.L469:
	move.l ls+28,%d1
	move.l %a2,%d0
	move.l %d1,-20(%fp)
	clr.l %d1
.L471:
	cmp.l -20(%fp),%d0
	jcs .L473
	move.l -20(%fp),%d1
	sub.l %a2,%d1
	move.l %d1,-20(%fp)
	move.l %d1,ls+28
	tst.l %d1
	jne .L457
	lea st+164,%a2
	move.l %a2,%a3
.L474:
	move.l -20(%fp),%d3
	cmp.l st+196.l,%d3
	jcc .L478
	move.b (%a3),%d0
	mvz.b 1(%a3),%d1
	moveq #127,%d3
	move.l %d1,-(%sp)
	mov3q.l #1,%d1
	and.l %d0,%d3
	lsr.l #7,%d0
	and.l %d0,%d1
	move.l %d3,-(%sp)
	move.l %d1,-(%sp)
	pea 49.w
	jsr send3
	lea (16,%sp),%sp
	tst.l %d0
	jne .L475
.L478:
	move.l st+196,%d0
	move.l -20(%fp),%d1
.L476:
	cmp.l %d0,%d1
	jcs .L479
	sub.l -20(%fp),%d0
	move.l %d0,st+196
	tst.l %d0
	jne .L457
	move.l kq_owes,%d2
	tst.l %d2
	jeq .L480
	movem.l -44(%fp),#15372
	unlk %fp
	jra (kq_owed_in.part.0)
.L470:
	move.l -20(%fp),%a1
	move.l -20(%fp),%a0
	move.w %a4,-9(%fp)
	move.b (%a1),-7(%fp)
	move.b 1(%a1),-6(%fp)
	move.b 2(%a1),-5(%fp)
	move.b 3(%a1),-4(%fp)
	move.b 4(%a1),-3(%fp)
	move.w #-2304,%a1
	move.b 5(%a0),%d0
	move.l %a3,-13(%fp)
	move.w %a1,-2(%fp)
	tst.b %d0
	jeq .L486
	move.b %d0,-2(%fp)
	moveq #-9,%d0
	move.b %d0,-1(%fp)
	moveq #13,%d0
.L467:
	move.l %d0,-(%sp)
	move.l %d2,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L469
	addq.l #6,-20(%fp)
	addq.l #1,%a2
	jra .L466
.L486:
	moveq #12,%d0
	jra .L467
.L473:
	mov3q.l #6,%d2
	muls.l %d0,%d2
	lea ls+4,%a1
	sub.l %a0,%a0
	sub.l %d1,%a1
.L472:
	lea (%a1,%d1.l),%a4
	addq.l #1,%a0
	move.b (%a4,%d2.l),(%a1)+
	mov3q.l #6,%d3
	cmp.l %a0,%d3
	jne .L472
	addq.l #1,%d0
	subq.l #6,%d1
	jra .L471
.L475:
	addq.l #2,%a3
	addq.l #1,-20(%fp)
	jra .L474
.L479:
	move.l -20(%fp),%a0
	addq.l #1,%d1
	move.b (%a2,%a0.l*2),(%a2)
	lea 1(%a2,%a0.l*2),%a1
	addq.l #2,%a2
	move.b (%a1),-1(%a2)
	jra .L476
.L480:
	lea st+96,%a3
.L485:
	move.l (%a3)+,-20(%fp)
	tst.l -20(%fp)
	jeq .L481
	moveq #-63,%d0
	cmp.l -20(%fp),%d0
	jle .L482
	moveq #-63,%d1
.L501:
	move.l %d1,-20(%fp)
.L483:
	mvz.b st+160,%d0
	move.l %d2,%d3
	mvz.b %d3,%d3
	move.l %d0,-(%sp)
	move.l -20(%fp),%d0
	add.l #64,%d0
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	move.l %d3,-(%sp)
	pea 50.w
	jsr send3
	lea (16,%sp),%sp
	tst.l %d0
	jeq .L457
	move.l -20(%fp),%d1
	sub.l %d1,-4(%a3)
	move.l st+64,%d1
	tst.l %d1
	jeq .L481
	move.l -66650100,%d0
	sub.l %d1,%d0
	move.l %d0,st+68
	add.l %d0,st+316
	addq.l #1,st+320
	cmp.l st+324.l,%d0
	jls .L484
	move.l %d0,st+324
.L484:
	clr.l st+64
.L481:
	addq.l #1,%d2
	moveq #16,%d3
	cmp.l %d2,%d3
	jne .L485
.L457:
	movem.l -44(%fp),#15372
	unlk %fp
	rts
.L482:
	moveq #63,%d3
	cmp.l -20(%fp),%d3
	jge .L483
	moveq #63,%d1
	jra .L501
	.size	flush, .-flush
	.align	2
	.type	ovl_pub, @function
ovl_pub:
	move.l #1397119061,%d0
	cmp.l 1075551828.l,%d0
	jne .L502
	move.l st+4,%d0
	or.l st+972,%d0
	move.l %d0,1203794416
.L502:
	rts
	.size	ovl_pub, .-ovl_pub
	.align	2
	.type	splash_end, @function
splash_end:
	tst.l st+972
	jeq .L504
	clr.l st+972
	jsr ovl_pub
	moveq #1,%d0
	lea (8,%sp),%a0
	move.l (%a0),st+988
	move.l 4(%sp),%a0
	move.b %d0,32(%a0)
.L504:
	rts
	.size	splash_end, .-splash_end
	.align	2
	.type	ed_queue_pat, @function
ed_queue_pat:
	move.l %d2,-(%sp)
	move.l 8(%sp),%a1
	move.l 20(%sp),%d1
	addq.l #1,ed+80
	mov3q.l #1,ed+376
	tst.l sq
	jeq .L506
	move.l ed+64,%d0
	move.l %d0,%a0
	mov3q.l #7,%d2
	sub.l ed+68,%a0
	cmp.l %a0,%d2
	jcc .L508
	addq.l #1,ed+72
.L506:
	move.l (%sp)+,%d2
	rts
.L508:
	mov3q.l #7,%d2
	and.l %d2,%d0
	mov3q.l #4,%d2
	lsl.l #3,%d0
	move.l %d0,%a0
	add.l #ed,%a0
	move.w %a1,%d0
	move.b %d0,(%a0)
	moveq #127,%d0
	and.l 24(%sp),%d0
	move.b %d0,1(%a0)
	cmp.l %a1,%d2
	jcc .L509
	lea (-16,%a1),%a1
	mov3q.l #1,%d0
	cmp.l %a1,%d0
	jcc .L509
	mvz.b 1093765506,%d0
	moveq #11,%d2
	cmp.l %d0,%d2
	jcc .L510
.L509:
	moveq #127,%d0
.L511:
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
	jra .L506
.L510:
	move.b 1093765506,%d0
	jra .L511
	.size	ed_queue_pat, .-ed_queue_pat
	.align	2
	.type	ls_close, @function
ls_close:
	lea ls,%a0
	tst.b ls.l
	jeq .L515
	clr.b %d0
	mvz.b ls+129,%d1
	clr.l ls+40
	addq.l #1,ls+84
	clr.l ls_smpl
	move.b %d0,ls
	mvz.b 7(%sp),%d0
	addq.l #1,104(%a0,%d0.l*4)
	lea st,%a0
	clr.l 96(%a0,%d1.l*4)
	move.l %d0,-(%sp)
	clr.l -(%sp)
	clr.l st+124
	jsr ls_queue
	addq.l #8,%sp
.L515:
	rts
	.size	ls_close, .-ls_close
	.text
.LC0:
	.string	"NOT LOCKABLE"
	.text
	.align	2
	.type	ls_enc, @function
ls_enc:
	lea (-20,%sp),%sp
	movem.l #124,(%sp)
	move.b ls,%d3
	move.l 24(%sp),%d2
	move.l 28(%sp),%d5
	tst.b %d3
	jeq .L518
	tst.l ls+40
	jeq .L519
	move.b ls+2,%d0
	add.l #-40,%d0
	mvz.b %d0,%d0
	lsr.l #1,%d0
	jeq .L519
	mov3q.l #7,%d0
	cmp.l %d2,%d0
	jne .L519
	add.l %d5,st+124
.L546:
	jsr flush
	jra .L520
.L519:
	mvz.b ls+129,%d0
	cmp.l %d0,%d2
	jeq .L518
	mov3q.l #3,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L533:
	clr.l %d0
	jra .L517
.L518:
	moveq #-5,%d0
	and.l %d2,%d0
	lea st,%a0
	or.l st+972,%d0
	jne .L533
	tst.b %d3
	jne .L523
	tst.l %d2
	jne .L524
	tst.b sv.l
	jeq .L533
	tst.b sv+8.l
	jeq .L533
	move.b sv+2,%d6
	mvz.b %d6,%d4
	move.l %d4,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L527
	moveq #45,%d1
	cmp.l %d4,%d1
	jeq .L527
	moveq #43,%d1
	cmp.l %d4,%d1
	jne .L517
.L527:
	lea sv+1,%a0
	moveq #45,%d0
	move.b (%a0),ls+1
	move.b %d6,ls+2
	cmp.l %d4,%d0
	jeq .L532
	moveq #43,%d1
	cmp.l %d4,%d1
	jne .L528
.L532:
	moveq #10,%d3
.L528:
	move.b %d3,ls+128
.L529:
	tst.l ms
	jeq .L530
	tst.l ms+16
	jeq .L530
	clr.l ls_smpl
	tst.l %d5
	jeq .L533
	pea .LC0
	addq.l #1,ms+248
	jsr ms_say
	addq.l #4,%sp
.L520:
	mov3q.l #1,%d0
.L517:
	movem.l (%sp),#124
	lea (20,%sp),%sp
	rts
.L524:
	jsr ls_p13
	tst.l %d0
	jeq .L517
	moveq #46,%d1
	move.b 1093765506,%d0
	move.b %d1,ls+2
	moveq #12,%d1
	move.b %d0,ls+1
	mvz.b %d0,%d0
	addq.l #1,%d0
	move.l %d0,ls_smpl
	move.b %d1,ls+128
	jra .L529
.L530:
	moveq #1,%d0
	lea st+8,%a0
	move.l (%a0),ls+130
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.b %d2,ls+129
	addq.l #1,ls+80
	move.b %d0,ls
	jsr ls_queue
	jsr flush
	addq.l #8,%sp
	jra .L520
.L523:
	mvz.b ls+129,%d0
	addq.l #1,ls+88
	add.l %d5,96(%a0,%d0.l*4)
	jra .L546
	.size	ls_enc, .-ls_enc
	.align	2
	.type	ms_push, @function
ms_push:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	moveq #19,%d2
	move.l 12(%sp),%a1
	move.l ms+152,%d1
	mvz.b (%a1),%d0
	cmp.l %d0,%d2
	jne .L552
	tst.b 1(%a1)
	jeq .L553
.L552:
	mov3q.l #7,%d0
.L548:
	cmp.l %d1,%d0
	jhi .L549
	addq.l #1,ms+156
.L547:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L553:
	moveq #8,%d0
	jra .L548
.L549:
	move.l %d1,%d0
	lsl.l #3,%d0
	move.l %d0,%a0
	clr.l %d0
	add.l #ms,%a0
.L551:
	lea (%a1,%d0.l),%a2
	moveq #8,%d2
	move.b (%a2),88(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d2
	jne .L551
	addq.l #1,%d1
	move.l %d1,ms+152
	jra .L547
	.size	ms_push, .-ms_push
	.align	2
	.type	ms_acc_out, @function
ms_acc_out:
	link.w %fp,#-12
	move.l ms+76,%a1
	move.l %d2,-(%sp)
	tst.l %a1
	jeq .L559
	moveq #16,%d1
.L556:
	tst.l ms+60
	jeq .L555
	move.l ms+84,%a0
	move.l %a0,%d0
	divs.l %d1,%d0
	moveq #63,%d2
	cmp.l %d0,%d2
	jlt .L560
	moveq #-63,%d2
	cmp.l %d0,%d2
	jgt .L561
	tst.l %d0
	jeq .L555
.L558:
	mov3q.l #6,%d2
	cmp.l ms+152.l,%d2
	jcs .L555
	muls.l %d0,%d1
	move.w %a1,%d2
	sub.l %d1,%a0
	moveq #18,%d1
	move.l %a0,ms+84
	lea ms+71,%a0
	move.b %d2,-3(%fp)
	moveq #127,%d2
	move.b (%a0),-6(%fp)
	lea ms+75,%a0
	move.b (%a0),-5(%fp)
	pea -8(%fp)
	move.b %d1,-8(%fp)
	move.l ms+64,%d1
	subq.l #1,%d1
	move.b %d1,-7(%fp)
	moveq #127,%d1
	and.l %d1,%d0
	move.b %d0,-4(%fp)
	move.l ms+80,%d0
	move.l %d0,%d1
	lsr.l #7,%d1
	and.l %d2,%d0
	and.l %d2,%d1
	move.b %d0,-1(%fp)
	move.b %d1,-2(%fp)
	jsr ms_push
	addq.l #1,ms+240
	addq.l #4,%sp
.L555:
	move.l -16(%fp),%d2
	unlk %fp
	rts
.L559:
	mvz.w #256,%d1
	jra .L556
.L560:
	moveq #63,%d0
	jra .L558
.L561:
	moveq #-63,%d0
	jra .L558
	.size	ms_acc_out, .-ms_acc_out
	.align	2
	.type	ms_ev, @function
ms_ev:
	moveq #19,%d0
	link.w %fp,#-8
	move.b 11(%fp),-7(%fp)
	move.b 15(%fp),-6(%fp)
	move.b 19(%fp),-5(%fp)
	clr.l -4(%fp)
	move.b %d0,-8(%fp)
	jsr ms_acc_out
	pea -8(%fp)
	jsr ms_push
	addq.l #4,%sp
	unlk %fp
	rts
	.size	ms_ev, .-ms_ev
	.align	2
	.type	ms_acc_drop, @function
ms_acc_drop:
	move.l %d2,-(%sp)
	tst.l ms+60
	jeq .L566
	move.l ms+84,%d0
	tst.l ms+76
	jeq .L569
	moveq #16,%d1
.L568:
	divs.l %d1,%d0
	tst.l %d0
	jeq .L566
	addq.l #1,ms+156
.L566:
	move.l (%sp)+,%d2
	rts
.L569:
	mvz.w #256,%d1
	jra .L568
	.size	ms_acc_drop, .-ms_acc_drop
	.align	2
	.type	pmo_word_ok, @function
pmo_word_ok:
	move.l %d2,-(%sp)
	moveq #12,%d2
	move.l 8(%sp),%d0
	move.l 12(%sp),%d1
	cmp.l %d0,%d2
	jcc .L574
.L577:
	clr.l %d0
.L573:
	move.l (%sp)+,%d2
	rts
.L574:
	move.l %d1,%a0
	moveq #40,%d2
	subq.l #1,%a0
	cmp.l %a0,%d2
	jcs .L576
	mov3q.l #4,%d2
	cmp.l %d1,%d2
	jeq .L577
	moveq #12,%d2
	cmp.l %d0,%d2
	jne .L579
	moveq #29,%d0
	cmp.l %d1,%d0
	jeq .L577
	moveq #37,%d2
	cmp.l %d1,%d2
	scc %d1
	mvs.b %d1,%d0
.L590:
	neg.l %d0
	jra .L573
.L576:
	move.l %d1,%a0
	mov3q.l #7,%d2
	lea (-48,%a0),%a0
	cmp.l %a0,%d2
	jcs .L578
	moveq #12,%d1
	cmp.l %d0,%d1
	jeq .L577
	mov3q.l #4,%d2
	cmp.l 16(%sp),%d2
	seq %d0
.L589:
	mvs.b %d0,%d0
	jra .L590
.L578:
	moveq #56,%d2
	cmp.l %d1,%d2
	jne .L577
	moveq #12,%d1
	cmp.l %d0,%d1
	sne %d0
	jra .L589
.L579:
	mov3q.l #1,%d0
	jra .L573
	.size	pmo_word_ok, .-pmo_word_ok
	.align	2
	.type	pmo_get, @function
pmo_get:
	lea (-24,%sp),%sp
	movem.l #1148,(%sp)
	move.l 28(%sp),%d4
	move.l %d4,%d3
	lsl.l #6,%d3
	lea pmo,%a1
	move.l 32(%sp),%d6
	lea (%a1,%d3.l),%a0
	add.l %d6,%a0
	mvz.b 584(%a0),%d0
	tst.l %d0
	jne .L592
	clr.b %d1
	move.l pmo+104,%d5
	move.l pmo+9096,%d0
	lea pmo+9100,%a0
.L593:
	tst.l %d0
	jne .L595
	tst.b %d1
	jeq .L596
	clr.l pmo+9096
.L596:
	moveq #127,%d0
	cmp.l %d5,%d0
	jcc .L602
	clr.l %d0
	jra .L591
.L592:
	mulu.w #44,%d0
	add.l #pmo+3420,%d0
.L591:
	movem.l (%sp),#1148
	lea (24,%sp),%sp
	rts
.L595:
	subq.l #1,%d0
	moveq #1,%d1
	mvz.b (%a0,%d0.l),%d2
	cmp.l %d2,%d5
	jls .L593
	lea (%a1,%d0.l),%a0
	mvz.b 9100(%a0),%d2
	move.l %d0,pmo+9096
	jra .L600
.L602:
	move.l %d5,%d2
.L600:
	moveq #44,%d1
	muls.l %d2,%d1
	move.w %d2,%d0
	move.l %d6,%a2
	addq.l #1,(%a1)
	lea (%a1,%d1.l),%a0
	move.l %d4,%d1
	addq.l #1,%d1
	move.b %d1,3464(%a0)
	clr.w %d1
	mulu.w #42,%d4
	mulu.w #44,%d0
	move.b %d6,3465(%a0)
	clr.l 3500(%a0)
	clr.l 3492(%a0)
	clr.l 3488(%a0)
	clr.l 3480(%a0)
	clr.l 3476(%a0)
	clr.l 3468(%a0)
	add.l #pmo+3464,%d0
	lea 26(%a2,%d4.l),%a2
	move.w %d1,3466(%a0)
	moveq #12,%d1
	muls.l %d2,%d1
	addq.l #1,%d2
	move.l %a2,3504(%a0)
	move.l %d1,%a0
	add.l #pmo+10108,%a0
	clr.l (%a0)
	lea (%a1,%d3.l),%a0
	add.l %d6,%a0
	move.b %d2,584(%a0)
	cmp.l %d5,%d2
	jls .L591
	move.l %d2,pmo+104
	jra .L591
	.size	pmo_get, .-pmo_get
	.align	2
	.type	pj_push, @function
pj_push:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.l 20(%sp),%d1
	move.l 24(%sp),%a1
#APP
| 5645 "rui.c" 1
	tas pj+136
	smi %d2
| 0 "" 2
#NO_APP
	tst.b %d2
	jeq .L608
	addq.l #1,pj+156
.L607:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L608:
	move.l pj,%d3
	move.l %d3,%d0
	sub.l pj+4,%d0
	lsr.l #5,%d0
	jeq .L610
	addq.l #1,pj+156
.L611:
	clr.b %d0
	move.b %d0,pj+136
	jra .L607
.L610:
	moveq #31,%d0
	and.l %d3,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #pj+8,%a0
	move.b 19(%sp),(%a0)
	moveq #127,%d0
	cmp.l %d1,%d0
	jcs .L614
	move.l %d1,%d0
	addq.l #1,%d0
.L612:
	move.b %d0,1(%a0)
	moveq #127,%d4
	cmp.l %a1,%d4
	jcs .L613
	move.l %a1,%d2
	addq.l #1,%d2
.L613:
	move.b %d2,2(%a0)
	addq.l #1,%d3
	move.l %d3,pj
	jra .L611
.L614:
	clr.b %d0
	jra .L612
	.size	pj_push, .-pj_push
	.align	2
	.type	led_restore, @function
led_restore:
	tst.b ov_on.l
	jeq .L615
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L617
	addq.l #1,st+1018
.L615:
	rts
.L617:
	clr.b %d0
	move.b %d0,ov_on
	jsr led_stock
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #4,%sp
	move.l st+8,%d0
	addq.l #4,%d0
	tst.l %d0
	jne .L618
	mov3q.l #1,%d0
.L618:
	move.l %d0,led_again
	addq.l #1,st+1014
	jra .L615
	.size	led_restore, .-led_restore
	.align	2
	.type	pmo_mph_end.constprop.0, @function
pmo_mph_end.constprop.0:
	move.l %d2,-(%sp)
	move.l #-1171354716,%d2
	move.l 8(%sp),%d1
	move.l %d1,%d0
	sub.l #pmo+3464,%d0
	asr.l #2,%d0
	muls.l %d2,%d0
	move.l %d0,%a0
	add.l #pmo+10108,%a0
	tst.l (%a0)
	jeq .L623
	clr.l (%a0)
	subq.l #1,pmo+10096
.L623:
	move.l 12(%sp),-(%sp)
	clr.l -(%sp)
	move.l %d1,-(%sp)
	jsr pmo_mix
	lea (12,%sp),%sp
	move.l (%sp)+,%d2
	rts
	.size	pmo_mph_end.constprop.0, .-pmo_mph_end.constprop.0
	.align	2
	.type	pmo_fade, @function
pmo_fade:
	lea (-12,%sp),%sp
	movem.l #3076,(%sp)
	lea pmo+3464,%a2
	clr.l %d2
	lea pmo_off,%a3
.L625:
	cmp.l pmo+104.l,%d2
	jcs .L628
	movem.l (%sp),#3076
	lea (12,%sp),%sp
	rts
.L628:
	move.b (%a2),%d0
	jeq .L626
	mvz.b %d0,%d0
	move.l 16(%sp),%d1
	subq.l #1,%d0
	btst %d0,%d1
	jeq .L626
	move.l 20(%sp),-(%sp)
	clr.l -(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l pmo+10096
	jeq .L627
	move.l 20(%sp),-(%sp)
	move.l %a2,-(%sp)
	jsr (pmo_mph_end.constprop.0)
	addq.l #8,%sp
.L626:
	addq.l #1,%d2
	lea (44,%a2),%a2
	jra .L625
.L627:
	move.l 20(%sp),-(%sp)
	clr.l -(%sp)
	move.l %a2,-(%sp)
	jsr pmo_mix
	lea (12,%sp),%sp
	jra .L626
	.size	pmo_fade, .-pmo_fade
	.align	2
	.type	ms_stock_key.constprop.0, @function
ms_stock_key.constprop.0:
	lea (-32,%sp),%sp
	clr.l %d0
	move.l 40(%sp),%a0
.L636:
	lea (%a0,%d0.l),%a1
	moveq #32,%d1
	move.l (%a1),(%sp,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L636
	moveq #-124,%d0
	move.b %d0,15(%sp)
	moveq #-2,%d0
	and.l 16(%sp),%d0
	or.l 44(%sp),%d0
	move.l %d0,16(%sp)
	pea 0(%sp)
	move.l 40(%sp),-(%sp)
	jsr 1074397898
	lea (40,%sp),%sp
	rts
	.size	ms_stock_key.constprop.0, .-ms_stock_key.constprop.0
	.align	2
	.type	sq_tick, @function
sq_tick:
	link.w %fp,#-68
	move.l sq_gen,%d0
	movem.l #15612,(%sp)
	move.b 1093765506,%d2
	cmp.l sq+400.l,%d0
	jeq .L639
	mov3q.l #1,%d3
	and.l %d0,%d3
	btst #0,%d0
	jne .L639
	clr.l %d1
	lea sq_req,%a0
.L640:
	lea (%a0,%d1.l),%a1
	mov3q.l #7,%d4
	move.b (%a1),-9(%fp,%d1.l)
	addq.l #1,%d1
	cmp.l %d1,%d4
	jne .L640
	cmp.l sq_gen.l,%d0
	jne .L639
	move.l %d0,sq+400
	mvz.b -8(%fp),%d0
	mvz.b -9(%fp),%d1
	lsl.l #7,%d0
	or.l %d1,%d0
	mvz.b -6(%fp),%d1
	and.l #4095,%d0
	move.l %d0,sq+4
	mvz.b -5(%fp),%d0
	lsl.l #7,%d0
	or.l %d1,%d0
	move.b -7(%fp),%d1
	and.l #4095,%d0
	or.l sq+4,%d0
	move.l %d0,sq+8
	move.w %d1,%ccr
	jeq .L642
	move.l sq+4,%d3
.L642:
	mvz.b -3(%fp),%d0
	mvz.b -4(%fp),%d4
	lsl.l #7,%d0
	or.l %d4,%d0
	and.l #4095,%d0
	or.l %d3,%d0
	move.l %d0,pin
	tst.l sq
	jeq .L643
	btst #1,%d1
	jeq .L644
.L643:
	mvz.w #255,%d5
	move.w #8191,%a0
	addq.l #1,sq+452
	mov3q.l #1,ed+92
	move.l %d5,sq+404
	move.l %a0,ed+260
.L644:
	mov3q.l #1,sq
.L639:
	tst.l sq
	jne .L645
	clr.l sq+408
.L638:
	movem.l -68(%fp),#15612
	unlk %fp
	rts
.L645:
	mvz.b %d2,%d2
	lea sq_grid,%a2
	moveq #11,%d0
	cmp.l %d2,%d0
	jcs .L647
	move.l sq+4,%d0
	btst %d2,%d0
	jne .L648
.L647:
	clr.l %d0
.L649:
	cmp.l sq+408.l,%d0
	jne .L650
	tst.l %d0
	jeq .L651
	cmp.l sq+412.l,%d2
	jeq .L651
.L650:
	mov3q.l #1,%d1
	or.l %d1,sq+404
	move.l %d0,sq+408
	move.l %d2,sq+412
.L651:
	move.b 1093615249,%d0
	move.b 1093615250,%d2
	moveq #127,%d3
	move.b 1079807236,%d1
	and.l %d3,%d1
	move.l sq+360,%d3
	btst #8,%d3
	jeq .L652
	move.l %d1,%a0
	moveq #127,%d1
	and.l %d3,%d1
.L653:
	cmp.l %d1,%a0
	jne .L654
	move.w #127,%a0
.L654:
	cmp.l sq+420.l,%d1
	jne .L655
	cmp.l sq+424.l,%a0
	jeq .L656
.L655:
	mov3q.l #4,%d5
	or.l %d5,sq+404
	move.l %d1,sq+420
	move.l %a0,sq+424
.L656:
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
	jne .L657
	cmp.l sq+432.l,%d0
	jeq .L658
.L657:
	move.l %d0,sq+432
	moveq #16,%d0
	or.l %d0,sq+404
	move.l %d2,sq+428
.L658:
	move.l 1076395164,%d0
	and.l #2097151,%d0
	cmp.l sq+436.l,%d0
	jeq .L659
	moveq #32,%d1
	or.l %d1,sq+404
	move.l %d0,sq+436
.L659:
	move.b 1081877443,%d0
	mvz.b 1081877444,%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #8191,%d0
	cmp.l sq+440.l,%d0
	jeq .L660
	moveq #8,%d2
	or.l %d2,sq+404
	move.l %d0,sq+440
.L660:
	move.b 1081877445,%d0
	mvz.b 1081877446,%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #8191,%d0
	cmp.l sq+552.l,%d0
	jeq .L661
	mvz.w #128,%d3
	move.l %d0,sq+552
	or.l %d3,sq+404
.L661:
	mov3q.l #1,%d4
	move.l 1079807120,%d2
	cmp.l %d2,%d4
	jne .L662
	move.l st+8,%d0
	moveq #19,%d5
	sub.l sq+444,%d0
	cmp.l %d0,%d5
	jcc .L662
	moveq #64,%d0
	or.l %d0,sq+404
.L662:
	move.l sq+404,%d0
	btst #0,%d0
	jeq .L663
	move.l sq+408,%d0
	move.b %d0,-9(%fp)
	tst.l %d0
	jeq .L698
	move.b sq+415,%d0
.L664:
	mov3q.l #2,-(%sp)
	pea -9(%fp)
	pea 8.w
	move.b %d0,-8(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L638
	moveq #-2,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L663:
	btst #1,%d0
	jeq .L665
	mov3q.l #2,%d1
	cmp.l %d2,%d1
	jcc .L699
	clr.l %d0
.L666:
	move.b %d0,-9(%fp)
	move.l 1100784300,-(%sp)
	pea -8(%fp)
	jsr blk4
	mov3q.l #5,-(%sp)
	pea -9(%fp)
	mov3q.l #1,-(%sp)
	jsr sq_send2
	lea (20,%sp),%sp
	tst.l %d0
	jeq .L638
	moveq #-3,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L665:
	move.w %d0,%ccr
	jne .L667
	lea sq+423,%a0
	lea sq+427,%a1
	move.b (%a0),-9(%fp)
	move.b (%a1),-8(%fp)
	mov3q.l #2,-(%sp)
	pea -9(%fp)
	mov3q.l #2,-(%sp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L638
	moveq #-5,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L667:
	move.w %d0,%ccr
	jpl .L668
	move.l sq+440,%d0
	moveq #127,%d1
	mov3q.l #2,-(%sp)
	pea -9(%fp)
	and.l %d0,%d1
	lsr.l #7,%d0
	mov3q.l #5,-(%sp)
	move.b %d1,-9(%fp)
	moveq #63,%d1
	and.l %d1,%d0
	move.b %d0,-8(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L638
	moveq #-9,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L668:
	tst.b %d0
	jpl .L669
	move.l sq+552,%d0
	moveq #127,%d1
	moveq #63,%d3
	mov3q.l #2,-(%sp)
	and.l %d0,%d1
	lsr.l #7,%d0
	pea -9(%fp)
	pea 13.w
	and.l %d3,%d0
	move.b %d1,-9(%fp)
	move.b %d0,-8(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L638
	move.l sq+404,%d0
	bclr #7,%d0
	move.l %d0,sq+404
.L669:
	btst #4,%d0
	jeq .L670
	lea sq+431,%a0
	lea sq+435,%a1
	move.b (%a0),-9(%fp)
	move.b (%a1),-8(%fp)
	mov3q.l #2,-(%sp)
	pea -9(%fp)
	mov3q.l #6,-(%sp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L638
	moveq #-17,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L670:
	btst #5,%d0
	jeq .L671
	moveq #14,%d3
	moveq #127,%d4
	move.l sq+436,%d0
	move.l %d0,%d1
	lsr.l %d3,%d1
	mov3q.l #3,-(%sp)
	pea -9(%fp)
	mov3q.l #7,-(%sp)
	and.l %d4,%d1
	move.b %d1,-9(%fp)
	move.l %d0,%d1
	lsr.l #7,%d1
	and.l %d4,%d0
	and.l %d4,%d1
	move.b %d0,-7(%fp)
	move.b %d1,-8(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L638
	moveq #-33,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L671:
	btst #6,%d0
	jeq .L672
	move.l 1100784300,-(%sp)
	move.l %fp,%d3
	add.l #-9,%d3
	move.l %d3,-(%sp)
	jsr blk4
	addq.l #8,%sp
	mov3q.l #2,%d5
	cmp.l %d2,%d5
	jcc .L673
	clr.l %d2
.L673:
	move.b %d2,-5(%fp)
	moveq #127,%d1
	move.w 1079807124,%d0
	subq.l #1,%d0
	and.l %d1,%d0
	move.b %d0,-4(%fp)
	move.l sq+380,%d0
	cmp.l %d0,%d1
	jcc .L674
	moveq #127,%d0
.L674:
	mov3q.l #7,-(%sp)
	move.l %d3,-(%sp)
	pea 9.w
	move.b %d0,-3(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L638
	moveq #-65,%d2
	and.l %d2,sq+404
	lea st+8,%a0
	move.l (%a0),sq+444
.L672:
	move.l sq+360,%d0
	btst #8,%d0
	jeq .L675
	moveq #127,%d1
	and.l %d1,%d0
.L676:
	move.l #85760,%d3
	clr.l %d1
	muls.l %d3,%d0
	move.l ed+96,%a1
	move.l #85685,%d7
	lea ed,%a2
	move.l %a2,%a3
	move.l %a1,-24(%fp)
	lea ed+100,%a1
	move.l %d0,%a0
	add.l #1081989347,%a0
	move.l %a0,-28(%fp)
	lea (709,%a0),%a0
.L682:
	move.l -28(%fp),%a4
	move.l #85689,%a5
	moveq #12,%d0
	mvz.b (%a4,%a5.l),%d4
	cmp.l %d1,%d0
	jeq .L677
	mvz.b (%a0),%d0
	move.b 2(%a0),%d3
.L678:
	mvz.b %d3,%d3
	cmp.l (%a1),%d0
	jne .L679
	cmp.l 52(%a1),%d3
	jne .L679
	cmp.l 104(%a1),%d4
	jne .L679
	moveq #12,%d2
	cmp.l %d1,%d2
	jne .L680
	move.l -28(%fp),%a4
	move.l #85685,%d2
	move.l #85686,%a5
	move.b (%a4,%d2.l),%d2
	mvz.b (%a4,%a5.l),%d5
	mvz.b %d2,%d2
	lsl.l #8,%d2
	or.l %d5,%d2
	cmp.l ed+256.l,%d2
	jeq .L680
.L679:
	move.l %d0,(%a1)
	moveq #12,%d0
	move.l %d3,52(%a1)
	move.l %d4,104(%a1)
	cmp.l %d1,%d0
	jne .L681
	move.l #85686,%a5
	move.l -28(%fp),%a4
	move.b (%a4,%d7.l),%d0
	mvz.b (%a4,%a5.l),%d2
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d2,%d0
	move.l %d0,ed+256
.L681:
	tst.l -24(%fp)
	jeq .L680
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	or.l %d0,ed+260
.L680:
	addq.l #1,%d1
	addq.l #4,%a1
	lea (917,%a0),%a0
	moveq #13,%d0
	cmp.l %d1,%d0
	jne .L682
	move.b 1079807236,%d1
	moveq #127,%d2
	move.l #85760,%d0
	mov3q.l #1,ed+96
	and.l %d2,%d1
	muls.l %d1,%d0
	move.l %d0,%a1
	add.l #1081989344,%a1
	mvz.w #21441,%d0
	cmp.l ed+272.l,%d1
	jeq .L683
	move.l %d1,ed+272
	clr.l ed+268
	clr.l ed+372
.L683:
	move.l ed+268,%d2
	move.l %d2,%d3
	addq.l #1,%d3
	move.l %d3,%d1
	moveq #10,%d4
	lsl.l %d4,%d1
	cmp.l %d0,%d1
	jls .L700
	move.l %d2,%d1
	move.l %d0,%d5
	lsl.l %d4,%d1
	sub.l %d1,%d5
.L684:
	moveq #12,%d4
	move.l %d2,%d1
	lsl.l %d4,%d1
	clr.l %d4
	add.l %d1,%a1
	clr.l %d1
.L685:
	move.l %d1,%d6
	addq.l #1,%d4
	add.l %d6,%d6
	subx.l %d6,%d6
	neg.l %d6
	move.l %d6,%a4
	lea (%a4,%d1.l*2),%a0
	move.l %a0,%d1
	add.l (%a1)+,%d1
	cmp.l %d4,%d5
	jne .L685
	move.l ed+372,%d4
	move.l %d2,%a0
	lea (69,%a0),%a0
	btst %d2,%d4
	jeq .L686
	cmp.l (%a3,%a0.l*4),%d1
	jeq .L686
	mov3q.l #1,ed+376
.L686:
	move.l %d1,(%a3,%a0.l*4)
	mov3q.l #1,%d1
	add.l #1023,%d0
	lsl.l %d2,%d1
	or.l %d4,%d1
	move.l %d1,ed+372
	moveq #10,%d1
	lsr.l %d1,%d0
	cmp.l %d3,%d0
	jhi .L687
	clr.l %d3
.L687:
	move.l %d3,ed+268
	move.l %fp,%d3
	clr.l %d2
	add.l #-17,%d3
.L692:
	move.l ed+260,%d0
	btst %d2,%d0
	jeq .L688
	moveq #12,%d5
	cmp.l %d2,%d5
	jne .L701
	moveq #127,%d0
.L689:
	move.b %d0,-17(%fp)
	move.l 100(%a2),%d0
	moveq #127,%d1
	moveq #127,%d5
	and.l %d0,%d1
	lsr.l #7,%d0
	move.b %d1,-16(%fp)
	moveq #127,%d1
	and.l %d1,%d0
	move.b %d0,-15(%fp)
	moveq #127,%d0
	and.l 152(%a2),%d0
	move.b %d0,-14(%fp)
	moveq #127,%d0
	and.l 204(%a2),%d0
	move.b %d0,-13(%fp)
	move.l ed+256,%d0
	and.l %d0,%d1
	lsr.l #7,%d0
	and.l %d5,%d0
	move.b %d1,-12(%fp)
	move.b %d0,-11(%fp)
	moveq #12,%d0
	cmp.l %d2,%d0
	jeq .L702
	mov3q.l #5,%d0
.L690:
	move.l %d0,-(%sp)
	move.l %d3,-(%sp)
	mov3q.l #4,-(%sp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L638
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	addq.l #1,ed+264
	not.l %d0
	and.l %d0,ed+260
.L688:
	addq.l #1,%d2
	addq.l #4,%a2
	moveq #13,%d1
	cmp.l %d2,%d1
	jne .L692
.L693:
	move.l ed+68,%d0
	cmp.l ed+64.l,%d0
	jne .L694
	tst.l ed+92
	jeq .L695
	lea ed+91,%a0
	move.b (%a0),-17(%fp)
	mov3q.l #1,-(%sp)
	pea -17(%fp)
	pea 12.w
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L638
	clr.l ed+92
.L695:
	tst.l ed+376
	jeq .L638
	move.l st+8,%d0
	sub.l ed+380,%d0
	lsr.l #2,%d0
	jeq .L638
	move.b 1079807236,%d0
	moveq #127,%d2
	mov3q.l #1,-(%sp)
	pea -17(%fp)
	pea 11.w
	and.l %d2,%d0
	move.b %d0,-17(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L638
	lea st+8,%a0
	clr.l ed+376
	move.l (%a0),ed+380
	addq.l #1,ed+384
	jra .L638
.L648:
	jsr (%a2)
	jra .L649
.L652:
	mvz.b %d0,%d0
	mvz.b %d2,%d2
	move.w #127,%a0
	moveq #127,%d4
	lsl.l #8,%d0
	or.l %d2,%d0
	cmp.l %d0,%d4
	jlt .L654
	move.l %d0,%a0
	jra .L653
.L698:
	moveq #127,%d0
	jra .L664
.L699:
	move.l %d2,%d0
	jra .L666
.L675:
	move.b 1079807236,%d0
	moveq #127,%d2
	and.l %d2,%d0
	jra .L676
.L677:
	move.l -28(%fp),%a4
	move.l #85683,%a5
	move.l #85684,%d3
	move.l #85690,%d5
	move.b (%a4,%a5.l),%d0
	mvz.b (%a4,%d3.l),%d2
	move.b (%a4,%d5.l),%d3
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d2,%d0
	jra .L678
.L700:
	mvz.w #1024,%d5
	jra .L684
.L701:
	move.l %d2,%d0
	jra .L689
.L702:
	mov3q.l #7,%d0
	jra .L690
.L694:
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
	jeq .L638
	addq.l #1,ed+68
	addq.l #1,ed+76
	jra .L693
	.size	sq_tick, .-sq_tick
	.align	2
	.globl	rui_sysex
	.type	rui_sysex, @function
rui_sysex:
	link.w %fp,#-92
	move.l -66650100,%d1
	move.l 12(%fp),%d0
	movem.l #15612,(%sp)
	move.l %d1,-38(%fp)
	mov3q.l #6,%d2
	cmp.l %d0,%d2
	jge .L789
	move.l 8(%fp),%a0
	mvz.b 5(%a0),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L789
	mvz.b -1(%a0,%d0.l),%d1
	cmp.l #247,%d1
	jeq .L787
.L789:
	addq.l #1,rx_bad
	jra .L788
.L787:
	move.l 8(%fp),%a0
	move.l %d0,%d4
	moveq #50,%d2
	subq.l #7,%d4
	move.b 4(%a0),%d3
	move.l %d3,%d1
	add.l #-40,%d1
	mvz.b %d1,%d1
	cmp.l %d1,%d2
	jcs .L789
	move.w .L791(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&51
.L791:
	.word .L810-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L809-.L791
	.word .L808-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L807-.L791
	.word .L789-.L791
	.word .L806-.L791
	.word .L805-.L791
	.word .L804-.L791
	.word .L803-.L791
	.word .L802-.L791
	.word .L789-.L791
	.word .L801-.L791
	.word .L800-.L791
	.word .L799-.L791
	.word .L798-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L797-.L791
	.word .L796-.L791
	.word .L795-.L791
	.word .L794-.L791
	.word .L789-.L791
	.word .L793-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L792-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L789-.L791
	.word .L790-.L791
.L804:
	mov3q.l #4,%d3
	cmp.l %d4,%d3
	jge .L811
	move.l 8(%fp),%a0
	moveq #15,%d1
	move.b 7(%a0),%d2
	mvz.b %d2,%d4
	cmp.l %d4,%d1
	jcs .L811
	mvz.b 8(%a0),%d5
	mov3q.l #7,%d3
	cmp.l %d5,%d3
	jcs .L811
	move.b 9(%a0),%d1
	jeq .L811
	move.b 10(%a0),%d3
	jeq .L811
	mvz.b %d1,%d6
	add.l %d6,%d4
	moveq #16,%d6
	cmp.l %d4,%d6
	jlt .L811
	mvz.b %d3,%d4
	move.l %d5,%a0
	moveq #8,%d7
	add.l %d4,%a0
	cmp.l %a0,%d7
	jlt .L811
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
	jne .L811
	mvs.b %d2,%d2
	move.l 8(%fp),%a2
	clr.l %d0
	lsl.l #6,%d2
	lea (11,%a2),%a2
	move.l %d2,%a0
	add.l %d5,%a0
	add.l #staging,%a0
.L815:
	move.l %d1,%a1
	mov3q.l #7,%d2
	cmp.l %d1,%d2
	jge .L812
	mov3q.l #7,%a1
.L812:
	move.l %a2,%a3
	sub.l %a1,%d1
	mvz.b (%a3)+,%d3
	clr.l %d2
.L814:
	move.l %d3,%d5
	lsr.l #1,%d3
	move.b 1(%a2,%d2.l),%d6
	lsl.l #7,%d5
	or.l %d6,%d5
	move.b %d5,(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d4,%d0
	jne .L813
	addq.l #8,%a0
	clr.l %d0
.L813:
	addq.l #1,%d2
	cmp.l %a1,%d2
	jne .L814
	lea (%a3,%a1.l),%a2
	tst.l %d1
	jgt .L815
.L1046:
	move.l 8(%fp),%a0
	moveq #1,%d0
	lea (6,%a0),%a1
	move.b (%a1),st_seq
	jra .L1044
.L811:
	clr.b %d1
	addq.l #1,rx_bad
	move.b %d1,st_valid
.L788:
	move.l -66650100,%d0
	addq.l #1,mt_calls
	sub.l -38(%fp),%d0
	add.l %d0,mt_sum
	cmp.l mt_max.l,%d0
	jls .L987
	move.l %d0,mt_max
.L987:
	movem.l -92(%fp),#15612
	mov3q.l #1,%d0
	unlk %fp
	rts
.L803:
	tst.l %d4
	jeq .L789
	tst.b st_valid.l
	jeq .L818
	move.l 8(%fp),%a0
	mvz.b st_seq,%d0
	mvz.b 6(%a0),%d1
	cmp.l %d1,%d0
	jne .L818
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
	move.l #-66650100,%a1
	lea (24,%sp),%sp
	addq.l #1,sh_seq
	addq.l #1,commits
	move.l (%a1),t_commit
.L818:
	clr.b %d0
.L1044:
	move.b %d0,st_valid
.L816:
	addq.l #1,rx
	jra .L788
.L802:
	mov3q.l #1,%d1
	cmp.l %d4,%d1
	jge .L789
	move.l 8(%fp),%a0
	tst.b 7(%a0)
	jeq .L820
	moveq #1,%d0
	move.b %d0,host_open
	jra .L816
.L820:
	moveq #1,%d1
	move.b %d1,host_close
	jra .L816
.L801:
	tst.l %d4
	jeq .L816
	move.l 8(%fp),%a0
	move.b 6(%a0),%d0
	btst #0,%d0
	jeq .L816
	addq.l #1,host_rehello
	jra .L816
.L790:
	move.l qp+56,%d5
	tst.l %d4
	jeq .L821
	move.l 8(%fp),%a1
	move.b 6(%a1),%d3
	move.l %d3,%d0
	subq.l #4,%d0
	mvz.b %d0,%d0
	lsr.l #2,%d0
	jeq .L952
	move.l %d3,%d0
	add.l #-9,%d0
	mvz.b %d0,%d0
	lsr.l #1,%d0
	jne .L823
.L952:
	clr.l %d0
.L825:
	move.l 8(%fp),%a0
	tst.b 6(%a0,%d0.l)
	jlt .L824
	addq.l #1,%d0
	cmp.l %d4,%d0
	jlt .L825
	mvz.b %d3,%d2
	moveq #9,%d0
	cmp.l %d2,%d0
	jeq .L826
	moveq #10,%d1
	cmp.l %d2,%d1
	jeq .L827
	mov3q.l #6,%d6
	cmp.l %d2,%d6
	jeq .L828
	mov3q.l #7,%d7
	cmp.l %d2,%d7
	jne .L829
	mov3q.l #1,%d0
	cmp.l %d4,%d0
	jne .L824
	addq.l #1,pmo+64
.L830:
	addq.l #1,qp+72
	jra .L816
.L828:
	mov3q.l #5,%d1
	cmp.l %d4,%d1
	jne .L824
	move.l 8(%fp),%a0
	mvz.b 10(%a0),%d0
	lsr.l #6,%d0
	jeq .L831
.L824:
	addq.l #1,pmo+20
.L821:
	mov3q.l #1,%d0
	jra .L860
.L826:
	move.l 8(%fp),%a0
	moveq #19,%d6
	move.b 8(%a0),%d0
	mvz.b %d0,%d7
	move.l %d7,%d1
	subq.l #1,%d1
	cmp.l %d1,%d6
	jcs .L824
	ext.w %d0
	muls.w #7,%d0
	addq.l #3,%d0
	cmp.l %d4,%d0
	jne .L824
	lea (9,%a0),%a2
	clr.l %d6
.L832:
	mvz.b 1(%a2),%d0
	moveq #63,%d1
	cmp.l %d0,%d1
	jcs .L824
	mvz.b 2(%a2),%d1
	move.l %d1,%a0
	mov3q.l #3,%d1
	cmp.l %a0,%d1
	jcs .L824
	mov3q.l #5,-(%sp)
	move.l %d0,-(%sp)
	mvz.b (%a2),%d0
	move.l %d0,-(%sp)
	jsr pmo_word_ok
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L824
	addq.l #1,%d6
	addq.l #7,%a2
	cmp.l %d7,%d6
	jlt .L832
.L831:
	moveq #127,%d0
	and.l -2147457096,%d0
	move.l 8(%fp),%a0
	mvz.b 7(%a0),%d1
	cmp.l %d1,%d0
	jeq .L837
	addq.l #1,pmo+8
	jra .L830
.L827:
	mov3q.l #5,%d6
	cmp.l %d4,%d6
	jne .L824
	jra .L831
.L829:
	mov3q.l #4,%d7
	cmp.l %d2,%d7
	jne .L953
	mov3q.l #4,%d6
.L833:
	mov3q.l #3,%d0
	cmp.l %d4,%d0
	jge .L824
	move.l 8(%fp),%a0
	move.b 9(%a0),%d0
	mvz.b %d0,%d7
	tst.b %d0
	jeq .L824
	mov3q.l #4,%d1
	cmp.l %d2,%d1
	jne .L954
	moveq #28,%d1
.L834:
	cmp.l %d7,%d1
	jlt .L824
	ext.w %d0
	muls.w %d6,%d0
	addq.l #4,%d0
	cmp.l %d4,%d0
	jne .L824
	move.l 8(%fp),%a2
	sub.l %a5,%a5
	lea (10,%a2),%a2
.L836:
	move.b 1(%a2),%d0
	move.l %d2,-(%sp)
	move.w %d0,%a3
	moveq #63,%d0
	move.l %a3,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	mvz.b (%a2),%d0
	move.l %d0,-(%sp)
	jsr pmo_word_ok
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L824
	mov3q.l #4,%d1
	cmp.l %d2,%d1
	jne .L835
	move.l %a3,%d0
	btst #6,%d0
	jne .L824
.L835:
	addq.l #1,%a5
	add.l %d6,%a2
	cmp.l %d7,%a5
	jlt .L836
	jra .L831
.L953:
	mov3q.l #5,%d6
	jra .L833
.L954:
	moveq #22,%d1
	jra .L834
.L837:
	move.l 8(%fp),%a2
	mov3q.l #6,%d1
	lea fp,%a1
	move.l (%a1),pmo+60
	move.b 7(%a2),%d0
	move.b 8(%a2),%d5
	move.b %d0,-33(%fp)
	cmp.l %d2,%d1
	jeq .L838
	moveq #10,%d4
	cmp.l %d2,%d4
	jne .L839
.L838:
	mov3q.l #1,%a2
.L840:
	mov3q.l #4,%d1
	cmp.l %d2,%d1
	seq %d0
	move.l 8(%fp),%a0
	lea (9,%a0),%a0
	neg.l %d0
	tst.b %d0
	jeq .L842
	mov3q.l #4,-42(%fp)
.L843:
	move.l 8(%fp),%a1
	clr.l -46(%fp)
	lea pmo,%a3
	lea (10,%a1),%a1
.L844:
	cmp.l -46(%fp),%a2
	jeq .L830
	mov3q.l #6,%d4
	cmp.l %d2,%d4
	jne .L845
	move.l 8(%fp),%a4
	mvz.b 10(%a4),%d1
	mvz.b 9(%a4),%d0
	lsl.l #7,%d1
	or.l %d1,%d0
.L1042:
	clr.b %d4
	clr.b %d7
	sub.l %a5,%a5
	jra .L846
.L839:
	moveq #9,%d6
	cmp.l %d2,%d6
	jne .L841
	mvz.b %d5,%d7
	move.l %d7,%a2
	jra .L840
.L841:
	move.l 8(%fp),%a0
	mvz.b 9(%a0),%d0
	move.l %d0,%a2
	jra .L840
.L842:
	mov3q.l #5,-42(%fp)
	jra .L843
.L845:
	moveq #9,%d0
	cmp.l %d2,%d0
	jne .L847
	move.b (%a0),%d1
	mvz.b 3(%a0),%d0
	moveq #14,%d4
	move.b 1(%a0),%d7
	move.b 5(%a0),%d5
	lsl.l #7,%d0
	move.w %d1,%a5
	mvz.b 2(%a0),%d1
	lsl.l %d4,%d1
	move.b 6(%a0),%d4
	or.l %d0,%d1
	mvz.b 4(%a0),%d0
	or.l %d1,%d0
.L846:
	move.l pmo+56,%a4
	move.l %a4,%d1
	sub.l pmo+80,%d1
	lsr.l #8,%d1
	jeq .L849
	addq.l #1,pmo+4
.L850:
	add.l -42(%fp),%a1
	addq.l #1,-46(%fp)
	addq.l #7,%a0
	jra .L844
.L847:
	moveq #10,%d6
	cmp.l %d2,%d6
	jne .L848
	move.l 8(%fp),%a4
	mvz.b 8(%a4),%d1
	mvz.b 9(%a4),%d0
	move.b 10(%a4),%d5
	lsl.l #7,%d1
	or.l %d1,%d0
	jra .L1042
.L848:
	move.b (%a1),%d0
	mvz.b 2(%a1),%d1
	move.b 1(%a1),%d7
	lsl.l #7,%d1
	move.w %d0,%a5
	mvz.b 3(%a1),%d0
	or.l %d1,%d0
	mov3q.l #5,%d1
	cmp.l %d2,%d1
	jne .L955
	move.b 4(%a1),%d4
	jra .L846
.L955:
	clr.b %d4
	jra .L846
.L849:
	move.l %a4,%d6
	mvz.b %d6,%d6
	move.w %a5,%d1
	move.l %d6,-50(%fp)
	add.l #177,%d6
	lsl.l #3,%d6
	move.b %d1,(%a3,%d6.l)
	move.l -50(%fp),%d1
	move.b %d7,1(%a3,%d6.l)
	lsl.l #3,%d1
	lea (%a3,%d1.l),%a5
	move.b %d3,1418(%a5)
	move.b %d5,1419(%a5)
	move.w %d0,1420(%a5)
	move.b %d4,1422(%a5)
	move.b -33(%fp),1423(%a5)
	addq.l #1,%a4
	move.l %a4,pmo+56
	jra .L850
.L823:
	mvz.b %d3,%d3
	mov3q.l #1,%d1
	cmp.l %d3,%d1
	jne .L852
	mov3q.l #5,%d2
	cmp.l %d4,%d2
	jne .L852
	move.l 8(%fp),%a0
	clr.l %d6
	mvz.b 8(%a0),%d3
	mvz.b 10(%a0),%d2
	mvz.b 7(%a0),%d0
	lsl.l #7,%d3
	lsl.l #7,%d2
	and.l #3968,%d3
	and.l #3968,%d2
	or.l %d0,%d3
	mvz.b 9(%a0),%d0
	or.l %d0,%d2
	or.l %d3,%d2
.L854:
	btst %d6,%d2
	jeq .L853
	jsr 1075312702
	mov3q.l #1,%d7
	clr.l -(%sp)
	move.l %d3,%d1
	lsr.l %d6,%d1
	move.l %d0,%a0
	and.l %d1,%d7
	move.l %d7,-(%sp)
	move.l %d6,-(%sp)
	pea 48(%a0)
	jsr 1074493548
	lea (16,%sp),%sp
.L853:
	addq.l #1,%d6
	moveq #12,%d0
	cmp.l %d6,%d0
	jne .L854
.L855:
	clr.l %d0
.L860:
	addq.l #1,qp+72
	tst.l %d0
	jeq .L866
	addq.l #1,qp+76
.L866:
	move.l %d5,%d1
	sub.l qp+60,%d1
	lsr.l #2,%d1
	jeq .L867
	addq.l #1,qp+80
	tst.l %d0
	jeq .L816
	tst.l %d4
	jeq .L957
	move.l 8(%fp),%a0
	moveq #127,%d1
	move.b 6(%a0),%d0
	and.l %d1,%d0
.L868:
	move.l %d0,qp+88
	addq.l #1,qp+92
	jra .L816
.L852:
	mov3q.l #2,%d1
	cmp.l %d4,%d1
	jne .L856
	cmp.l %d3,%d1
	jne .L857
	move.l 8(%fp),%a0
	moveq #12,%d0
	mvz.b 7(%a0),%d2
	cmp.l %d2,%d0
	jcs .L821
	jsr 1075312702
	clr.l -(%sp)
	move.l %d2,%a0
	pea -1(%a0)
	move.l %d0,%a1
	pea 352(%a1)
	jsr 1074429188
.L1043:
	lea (12,%sp),%sp
	jra .L855
.L856:
	mov3q.l #3,%d0
	cmp.l %d4,%d0
	jne .L858
	cmp.l %d3,%d0
	jne .L859
	move.l 8(%fp),%a0
	moveq #11,%d1
	move.b 7(%a0),%d2
	move.l %d2,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jcs .L821
	move.b 8(%a0),%d3
	jmi .L821
	lsl.l #8,%d3
	jsr 1075398792
	mvz.b %d2,%d2
	move.l %d2,%a0
	and.l #65280,%d3
	move.l %d3,-(%sp)
	pea -1(%a0)
	move.l %d0,-(%sp)
	jsr 1074499748
	jra .L1043
.L857:
	moveq #11,%d0
	cmp.l %d3,%d0
	jne .L821
	move.l 8(%fp),%a0
	mov3q.l #1,%d1
	mvz.b 7(%a0),%d0
	cmp.l %d0,%d1
	jcs .L821
	move.l %d0,ms
	jra .L855
.L858:
	mov3q.l #2,%d2
	cmp.l %d4,%d2
	jge .L821
.L859:
	subq.l #8,%d3
	tst.l %d3
	jne .L821
	move.l 8(%fp),%a0
	move.b 7(%a0),%d0
	move.l %d0,%d1
	subq.l #1,%d1
	mvz.b %d1,%d1
	lsr.l #4,%d1
	jne .L821
	mvz.b %d0,%d0
	move.l %d0,%d1
	addq.l #2,%d1
	cmp.l %d4,%d1
	jne .L821
	clr.l %d1
.L861:
	move.l 8(%fp),%a0
	move.b 8(%a0,%d1.l),%d2
	add.l #-32,%d2
	mvz.b %d2,%d2
	lsr.l #6,%d2
	jne .L862
	addq.l #1,%d1
	cmp.l %d0,%d1
	jlt .L861
.L862:
	cmp.l %d0,%d1
	jne .L821
	addq.l #1,ms+160
	clr.l %d0
	move.l #ms,%d1
.L864:
	move.l 8(%fp),%a3
	mvz.b 7(%a3),%d2
	cmp.l %d0,%d2
	jgt .L865
	clr.b %d0
	add.l %d2,%d1
	move.l %d1,%a0
	move.b %d0,164(%a0)
	addq.l #1,ms+160
	jra .L855
.L865:
	move.l 8(%fp),%a1
	move.l %d1,%a0
	add.l %d0,%a0
	lea 8(%a1,%d0.l),%a2
	addq.l #1,%d0
	move.b (%a2),164(%a0)
	jra .L864
.L957:
	clr.l %d0
	jra .L868
.L867:
	tst.l %d4
	jeq .L958
	move.l 8(%fp),%a0
	moveq #127,%d2
	move.b 6(%a0),%d1
	and.l %d2,%d1
.L869:
	mov3q.l #3,%d2
	and.l %d5,%d2
	lea qp,%a0
	move.b %d1,64(%a0,%d2.l*2)
	move.b %d0,65(%a0,%d2.l*2)
	addq.l #1,%d5
	move.l %d5,qp+56
	jra .L816
.L958:
	clr.b %d1
	jra .L869
.L793:
	mov3q.l #2,%d3
	cmp.l %d4,%d3
	jne .L870
	move.l 8(%fp),%a0
	moveq #127,%d1
	mvz.b 6(%a0),%d0
	cmp.l %d0,%d1
	jne .L871
	mvz.b 7(%a0),%d0
	mov3q.l #1,%d2
	cmp.l %d0,%d2
	jcs .L872
	move.l %d0,ls_host_presets
	jra .L816
.L871:
	moveq #125,%d3
	cmp.l %d0,%d3
	jne .L872
	move.l 8(%fp),%a0
	mov3q.l #1,%d1
	mvz.b 7(%a0),%d0
	cmp.l %d0,%d1
	jcs .L872
	move.l %d0,ls_host_p13
	jra .L816
.L870:
	mov3q.l #1,%d2
	cmp.l %d4,%d2
	jge .L789
.L872:
	move.l 8(%fp),%a0
	moveq #126,%d1
	mvz.b 6(%a0),%d0
	cmp.l %d0,%d1
	jne .L874
	move.b 7(%a0),%d0
	mov3q.l #1,%d2
	and.l %d0,%d2
	move.l %d2,fk_claim
	jra .L816
.L874:
	subq.l #2,%d4
	tst.l %d4
	jne .L789
	moveq #11,%d4
	cmp.l %d0,%d4
	jcs .L789
	move.l 8(%fp),%a0
	mvz.b 7(%a0),%d0
	lsr.l #1,%d0
	jne .L789
	move.l 8(%fp),%a0
	mvz.w 6(%a0),%d0
	move.l %d0,ls_in_v
	addq.l #1,ls_in_gen
	jra .L816
.L810:
	subq.l #6,%d4
	tst.l %d4
	jne .L789
	move.l 8(%fp),%a0
	addq.l #6,%a0
	move.l 8(%fp),%d0
	add.l #12,%d0
.L878:
	tst.b (%a0)
	jlt .L789
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L878
	addq.l #1,pc_seq
	clr.l %d0
	lea pc_req,%a0
.L879:
	move.l 8(%fp),%a1
	mov3q.l #6,%d1
	lea 6(%a1,%d0.l),%a2
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L879
	addq.l #1,pc_seq
	jra .L816
.L807:
	tst.l %d4
	jeq .L789
	move.l 8(%fp),%a0
	mov3q.l #1,%d2
	move.b 6(%a0),%d0
	mvz.b %d0,%d1
	cmp.l %d1,%d2
	jcs .L789
	jne .L881
	moveq #17,%d3
	cmp.l %d4,%d3
	jne .L789
	move.l 8(%fp),%a0
	addq.l #7,%a0
	move.l 8(%fp),%d1
	add.l #23,%d1
.L884:
	mvz.b (%a0),%d2
	moveq #111,%d4
	cmp.l %d2,%d4
	jcs .L789
	addq.l #1,%a0
	cmp.l %a0,%d1
	jne .L884
.L881:
	addq.l #1,led_gen
	move.b %d0,led_req_mode
	clr.l %d0
	lea led_req,%a0
.L885:
	move.l 8(%fp),%a3
	mvz.b 6(%a3),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L886
	moveq #16,%d3
	cmp.l %d0,%d3
	jne .L887
.L886:
	addq.l #1,led_gen
	jra .L816
.L887:
	move.l 8(%fp),%a1
	lea 7(%a1,%d0.l),%a2
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	jra .L885
.L809:
	moveq #14,%d5
	cmp.l %d0,%d5
	jcs .L789
	mvz.w #21504,%d1
	btst %d0,%d1
	jeq .L789
	move.l 8(%fp),%a0
	moveq #31,%d1
	mvz.b 7(%a0),%d0
	cmp.l %d0,%d1
	jcs .L789
	mov3q.l #4,%d2
	cmp.l %d4,%d2
	jge .L889
	mvz.b 10(%a0),%d0
	cmp.l %d0,%d1
	jcs .L789
	mov3q.l #7,%d3
	cmp.l %d4,%d3
	jne .L889
	mvz.b 12(%a0),%d0
	cmp.l %d0,%d1
	jcs .L789
.L889:
	addq.l #1,sq_gen
	clr.l %d0
	lea sq_req,%a0
.L891:
	cmp.l %d4,%d0
	jge .L959
	moveq #127,%d2
	move.l 8(%fp),%a1
	move.b 6(%a1,%d0.l),%d1
	and.l %d2,%d1
.L890:
	move.b %d1,(%a0,%d0.l)
	addq.l #1,%d0
	mov3q.l #7,%d3
	cmp.l %d0,%d3
	jne .L891
	addq.l #1,sq_gen
	jra .L816
.L959:
	clr.b %d1
	jra .L890
.L796:
	subq.l #2,%d4
	tst.l %d4
	jne .L789
	move.l 8(%fp),%a0
	moveq #31,%d1
	mvz.b 7(%a0),%d0
	cmp.l %d0,%d1
	jcs .L789
	lsl.l #7,%d0
	move.l 8(%fp),%a0
	addq.l #1,pin+56
	mvz.b 6(%a0),%d1
	or.l %d0,%d1
	move.l %d1,pin+4
	jra .L816
.L795:
	move.l %d0,%d1
	moveq #14,%d2
	add.l #-10,%d1
	rems.l %d2,%d6:%d1
	tst.l %d6
	jne .L960
	mov3q.l #3,%d1
.L894:
	mov3q.l #2,%d3
	cmp.l %d4,%d3
	jge .L895
	move.l 8(%fp),%a0
	mov3q.l #2,%d2
	move.b 6(%a0),%d3
	mvz.b %d3,%d5
	cmp.l %d5,%d2
	jcs .L895
	move.b 7(%a0),%d2
	mvz.b %d2,%d7
	move.l %d7,%a0
	mov3q.l #1,%d7
	cmp.l %a0,%d7
	jcs .L895
	tst.l %d6
	jeq .L896
	add.l #-11,%d0
	moveq #14,%d7
	rems.l %d7,%d6:%d0
	tst.l %d6
	jne .L895
.L896:
	mov3q.l #4,%d0
	cmp.l %d1,%d0
	jne .L897
	move.l 8(%fp),%a0
	mvz.b 9(%a0),%d0
	lsr.l #3,%d0
	jeq .L897
.L895:
	addq.l #1,ux+12
	jra .L789
.L960:
	mov3q.l #4,%d1
	jra .L894
.L897:
	ext.w %d3
	tst.b %d2
	jne .L898
	move.l %d5,%a0
	add.l #ux,%a0
	mvz.b 3948(%a0),%d0
	mov3q.l #4,%d7
	cmp.l %d1,%d7
	jne .L899
	move.l 8(%fp),%a0
	mvz.b 9(%a0),%d2
	cmp.l %d0,%d2
	jeq .L900
.L898:
	move.w %d3,%d0
	mulu.w #1280,%d0
	move.l %d0,%a0
	add.l #ux+40,%a0
	mvz.w #128,%d0
.L901:
	clr.b (%a0)
	subq.l #1,%d0
	lea (10,%a0),%a0
	tst.l %d0
	jne .L901
	mov3q.l #4,%d0
	cmp.l %d1,%d0
	jne .L961
.L900:
	move.l 8(%fp),%a0
	move.b 9(%a0),%d2
.L902:
	lea ux,%a0
	lea (%a0,%d5.l),%a1
	move.b %d2,3948(%a1)
	move.l 8(%fp),%a1
	moveq #127,%d2
	mulu.w #1280,%d3
	move.b 8(%a1),%d0
	lea (%a1,%d1.l),%a2
	addq.l #1,%d1
	and.l %d2,%d0
	move.b %d0,36(%a0,%d5.l)
.L903:
	move.l %d1,%d0
	add.l #12,%d0
	cmp.l %d4,%d0
	jlt .L908
	addq.l #1,ux+8
	jra .L816
.L961:
	clr.b %d2
	jra .L902
.L908:
	move.b 6(%a2),%d0
	jmi .L904
	ext.w %d0
	move.l %d3,%a0
	mulu.w #10,%d0
	lea 40(%a0,%d0.l),%a1
	sub.l %a0,%a0
	add.l #ux,%a1
.L905:
	move.b 7(%a2,%a0.l),%d2
	moveq #94,%d5
	move.l %d2,%d0
	add.l #-32,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d5
	jcs .L906
	move.b %d2,(%a1,%a0.l)
	addq.l #1,%a0
	moveq #9,%d0
	cmp.l %a0,%d0
	jne .L905
.L906:
	clr.b %d6
	move.b %d6,(%a1,%a0.l)
.L904:
	lea (14,%a2),%a2
	add.l #14,%d1
	jra .L903
.L792:
	move.l 8(%fp),%a0
	moveq #96,%d0
	moveq #64,%d2
	move.b 6(%a0),%d1
	and.l %d1,%d0
	cmp.l %d0,%d2
	jne .L962
	tst.l %d4
	jeq .L789
	mov3q.l #1,%a1
	mov3q.l #2,%d0
.L909:
	cmp.l %d4,%d0
	jne .L789
	mvz.b %d1,%d0
	moveq #111,%d3
	cmp.l %d0,%d3
	jcs .L789
	moveq #-128,%d0
	or.l %d1,%d0
	move.l 8(%fp),%a0
	move.b %d0,-32(%fp)
	move.b 7(%a0),-31(%fp)
	tst.l %a1
	jne .L963
	move.b 8(%a0),%d0
.L912:
	move.b %d0,-30(%fp)
	moveq #16,%d3
	move.l 1094559344,%a0
	move.l 1094559356,%d2
	move.w -66825036,%d0
	mvz.w %d0,%d0
	sub.l %d2,%d0
	mvz.w -66825028,%d2
	add.l %a0,%d0
	move.l 1094559352,%a0
	add.l %d4,%a0
	sub.l %d2,%d0
	and.l #4095,%d0
	mvz.w #4096,%d2
	sub.l %d0,%d2
	moveq #112,%d0
	and.l %d0,%d1
	cmp.l %d1,%d3
	jne .L913
	tst.l %a1
	jne .L966
	move.l 8(%fp),%a1
	tst.b 8(%a1)
	jeq .L966
	mvz.w #512,%d0
.L914:
	add.l %a0,%d0
	cmp.l %d0,%d2
	jge .L915
	addq.l #1,din_drop
	jra .L816
.L962:
	sub.l %a1,%a1
	mov3q.l #3,%d0
	jra .L909
.L963:
	clr.b %d0
	jra .L912
.L913:
	lsr.l #5,%d1
	jeq .L966
	mvz.w #1536,%d0
	jra .L914
.L966:
	moveq #8,%d0
	jra .L914
.L915:
	mov3q.l #3,-(%sp)
	pea -32(%fp)
	move.l %d4,-(%sp)
	jsr 1074288478
	lea (12,%sp),%sp
	addq.l #1,din_sent
	jra .L816
.L797:
	subq.l #3,%d4
	tst.l %d4
	jne .L789
	move.l 8(%fp),%a0
	moveq #11,%d1
	mvz.b 6(%a0),%d0
	cmp.l %d0,%d1
	jcs .L789
	tst.b 7(%a0)
	jlt .L789
	mvz.b 8(%a0),%d1
	lsr.l #3,%d1
	jne .L789
	moveq #127,%d1
	and.l -2147457096,%d1
	lea ar,%a0
	move.l 8(%fp),%a1
	move.b %d1,48(%a0,%d0.l)
	mvz.b 8(%a1),%d1
	mvz.b 7(%a1),%d0
	mvz.b 6(%a1),%d2
	lsl.l #7,%d1
	or.l %d1,%d0
	or.l #-32768,%d0
	move.w %d0,24(%a0,%d2.l*2)
	jra .L816
.L794:
	move.l ux+3880,%d2
	add.l #-10,%d0
	mov3q.l #2,%d1
	cmp.l %d0,%d1
	jcs .L789
	move.l 8(%fp),%a0
	moveq #11,%d3
	move.b 6(%a0),%d1
	mvz.b %d1,%d0
	cmp.l %d0,%d3
	jcs .L789
	mvz.b 7(%a0),%d0
	lsr.l #4,%d0
	jne .L789
	tst.b 8(%a0)
	jlt .L789
	mov3q.l #3,%d6
	cmp.l %d4,%d6
	jge .L920
	tst.b 9(%a0)
	jlt .L789
	mov3q.l #5,%d7
	cmp.l %d4,%d7
	jne .L920
	tst.b 10(%a0)
	jlt .L789
.L920:
	move.l %d2,%d0
	sub.l ux+3884,%d0
	lea ux,%a0
	lsr.l #3,%d0
	jeq .L921
	addq.l #1,ux+28
	jra .L816
.L921:
	mov3q.l #7,%d0
	and.l %d2,%d0
	move.l 8(%fp),%a2
	move.l %d0,%a1
	lea (972,%a1),%a1
	move.b %d1,(%a0,%a1.l*4)
	lea (%a0,%d0.l*4),%a1
	mov3q.l #3,%d1
	move.b 7(%a2),3889(%a1)
	move.b 8(%a2),3890(%a1)
	cmp.l %d4,%d1
	jlt .L922
	clr.b %d3
	move.b %d3,3891(%a1)
.L923:
	clr.b %d1
.L925:
	add.l %d0,%a0
	addq.l #1,%d2
	move.b %d1,3952(%a0)
	move.l %d2,ux+3880
	addq.l #1,ux+16
	jra .L816
.L922:
	move.l 8(%fp),%a2
	subq.l #5,%d4
	move.b 9(%a2),3891(%a1)
	tst.l %d4
	jne .L923
	move.l 8(%fp),%a1
	move.b 10(%a1),%d1
	jra .L925
.L808:
	subq.l #4,%d4
	tst.l %d4
	jne .L789
	move.l 8(%fp),%a0
	addq.l #6,%a0
	move.l 8(%fp),%d1
	add.l #10,%d1
.L928:
	mvz.b (%a0),%d0
	moveq #111,%d2
	cmp.l %d0,%d2
	jcc .L927
	moveq #127,%d3
	cmp.l %d0,%d3
	jne .L789
.L927:
	addq.l #1,%a0
	cmp.l %d1,%a0
	jne .L928
	addq.l #1,pg_gen
	clr.l %d0
	lea pg_req,%a0
.L929:
	move.l 8(%fp),%a1
	mov3q.l #4,%d1
	lea 6(%a1,%d0.l),%a2
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L929
	addq.l #1,pg_gen
	jra .L816
.L806:
	tst.l %d4
	jeq .L789
	move.l 8(%fp),%a0
	moveq #127,%d1
	move.b 6(%a0),%d0
	and.l %d1,%d0
	bset #8,%d0
	move.l %d0,splash_req
	jra .L816
.L805:
	add.l #-10,%d0
	moveq #37,%d2
	cmp.l %d0,%d2
	jcs .L789
	move.l 8(%fp),%a0
	moveq #127,%d2
	clr.l -32(%fp)
	moveq #127,%d4
	clr.l -28(%fp)
	moveq #14,%d3
	clr.l -24(%fp)
	clr.l -20(%fp)
	clr.l -16(%fp)
	clr.l -12(%fp)
	clr.l -8(%fp)
	clr.l -4(%fp)
	move.b 8(%a0),%d1
	and.l %d2,%d1
	move.b 7(%a0),%d2
	lsl.l %d3,%d1
	and.l %d4,%d2
	lsl.l #7,%d2
	or.l %d2,%d1
	move.b 6(%a0),%d2
	and.l %d4,%d2
	or.l %d2,%d1
	clr.l %d2
.L932:
	cmp.l %d2,%d0
	jgt .L935
	mvz.w %d1,%d1
	lea (-32,%fp),%a0
	clr.l %d0
	lea mask_keys,%a1
	move.l %d1,mask_enc
.L936:
	move.l (%a0)+,(%a1,%d0.l*4)
	moveq #8,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L936
	mov3q.l #1,mask_set
	addq.l #1,masks
	jra .L816
.L935:
	move.w %d2,%d3
	move.l 8(%fp),%a0
	clr.l %d4
	mvz.b 9(%a0,%d2.l),%d6
	mulu.w #7,%d3
.L934:
	btst %d4,%d6
	jeq .L933
	cmp.l #255,%d3
	jgt .L933
	moveq #31,%d5
	mov3q.l #1,%d7
	and.l %d3,%d5
	lsl.l %d5,%d7
	move.l %d3,%d5
	asr.l #5,%d5
	or.l %d7,-32(%fp,%d5.l*4)
.L933:
	addq.l #1,%d4
	addq.l #1,%d3
	mov3q.l #7,%d7
	cmp.l %d4,%d7
	jne .L934
	addq.l #1,%d2
	jra .L932
.L800:
	mov3q.l #5,%d2
	cmp.l %d4,%d2
	jge .L937
	move.l 8(%fp),%a0
	moveq #63,%d3
	move.b 7(%a0),%d1
	mvz.b %d1,%d2
	cmp.l %d2,%d3
	jcs .L937
	move.b 8(%a0),%d4
	jmi .L937
	mvz.b 9(%a0),%d3
	lsr.l #6,%d3
	jne .L937
	mvz.b 10(%a0),%d3
	moveq #16,%d6
	cmp.l %d3,%d6
	jcs .L937
	add.l #-13,%d0
	moveq #32,%d7
	cmp.l %d0,%d7
	jge .L967
.L937:
	clr.b %d0
	addq.l #1,rx_bad
	move.b %d0,st_valid
	jra .L788
.L940:
	move.l 8(%fp),%a1
	moveq #94,%d5
	move.b 12(%a1,%a0.l),%d3
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcc .L939
	clr.b %d6
	addq.l #1,rx_bad
	move.b %d6,st_valid
	jra .L788
.L939:
	addq.l #1,%a0
.L938:
	cmp.l %d0,%a0
	jlt .L940
	moveq #44,%d7
	ext.w %d1
	muls.l %d7,%d2
	lea txt_st,%a1
	move.l 8(%fp),%a2
	mulu.w #44,%d1
	lea (9,%a2),%a3
	lea (10,%a2),%a4
	move.b %d4,(%a1,%d2.l)
	lea (11,%a2),%a5
	lea (%a1,%d1.l),%a0
	clr.l %d1
	move.b (%a3),1(%a1,%d2.l)
	move.b (%a4),2(%a1,%d2.l)
	move.b (%a5),3(%a1,%d2.l)
	move.b %d0,4(%a1,%d2.l)
.L941:
	cmp.l %d0,%d1
	jlt .L942
	clr.b %d1
	add.l %d2,%a1
	move.b %d1,8(%a1,%d0.l)
	jra .L1046
.L967:
	sub.l %a0,%a0
	jra .L938
.L942:
	move.l 8(%fp),%a2
	lea 12(%a2,%d1.l),%a3
	move.b (%a3),8(%a0,%d1.l)
	addq.l #1,%d1
	jra .L941
.L799:
	tst.l %d4
	jeq .L789
	lea txt_st+4,%a0
	moveq #64,%d0
.L944:
	clr.b (%a0)
	subq.l #1,%d0
	lea (44,%a0),%a0
	tst.l %d0
	jne .L944
	jra .L1046
.L798:
	mov3q.l #5,%d1
	cmp.l %d4,%d1
	jge .L789
	move.l 8(%fp),%a0
	moveq #15,%d4
	move.b 6(%a0),%d1
	mvz.b %d1,%d2
	cmp.l %d2,%d4
	jcs .L789
	add.l #-13,%d0
	moveq #11,%d5
	cmp.l %d0,%d5
	jlt .L789
	move.l 8(%fp),%a0
	lea bind_gen,%a1
	addq.l #1,(%a1,%d2.l*4)
	move.b 7(%a0),%d4
	mvz.b %d4,%d5
	lsr.l #6,%d5
	jeq .L947
	st %d4
.L947:
	moveq #20,%d7
	ext.w %d1
	muls.l %d7,%d2
	lea bind_in,%a0
	move.l 8(%fp),%a2
	mulu.w #20,%d1
	lea (8,%a2),%a3
	lea (9,%a2),%a4
	move.b %d4,(%a0,%d2.l)
	lea (10,%a2),%a5
	move.b (%a3),1(%a0,%d2.l)
	lea (11,%a2),%a3
	move.b (%a4),2(%a0,%d2.l)
	move.b (%a5),3(%a0,%d2.l)
	move.b (%a3),4(%a0,%d2.l)
	move.b %d0,5(%a0,%d2.l)
	move.l %d1,%a0
	clr.l %d1
	add.l #bind_in,%a0
.L948:
	cmp.l %d0,%d1
	jlt .L950
	move.l 8(%fp),%a0
	mvz.b 6(%a0),%d0
	addq.l #1,(%a1,%d0.l*4)
	jra .L816
.L950:
	move.l 8(%fp),%a4
	moveq #94,%d5
	move.b 12(%a4,%d1.l),%d2
	move.l %d2,%d4
	add.l #-32,%d4
	mvz.b %d4,%d4
	cmp.l %d4,%d5
	jcc .L949
	move.b %d3,%d2
.L949:
	move.b %d2,6(%a0,%d1.l)
	addq.l #1,%d1
	jra .L948
.L899:
	tst.l %d0
	jne .L898
	jra .L902
	.size	rui_sysex, .-rui_sysex
	.align	2
	.type	ov_suffix, @function
ov_suffix:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	clr.l %d0
.L1048:
	move.l 20(%sp),%a0
	tst.b (%a0,%d0.l)
	jne .L1049
	cmp.l %d1,%d0
	jle .L1054
.L1052:
	clr.l %d0
.L1047:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L1049:
	addq.l #1,%d0
	jra .L1048
.L1053:
	move.l 20(%sp),%a2
	mvs.b (%a0,%a1.l),%d2
	mvs.b (%a2,%a1.l),%d1
	cmp.l %d2,%d1
	jne .L1052
	addq.l #1,%a1
.L1050:
	cmp.l %a1,%d0
	jne .L1053
	mov3q.l #1,%d0
	jra .L1047
.L1054:
	add.l 12(%sp),%d1
	sub.l %a1,%a1
	move.l %d1,%a0
	sub.l %d0,%a0
	jra .L1050
	.size	ov_suffix, .-ov_suffix
	.text
.LC1:
	.string	"List"
.LC2:
	.string	"Browser"
.LC3:
	.string	"MenuView"
.LC4:
	.string	"QuickMuteMenuView"
.LC5:
	.string	"Window"
.LC6:
	.string	"ListView"
	.text
	.align	2
	.type	overlay, @function
overlay:
	lea (-20,%sp),%sp
	move.l 24(%sp),%d0
	movem.l #7180,(%sp)
	cmp.l ov_vt.l,%d0
	jne .L1056
.L1068:
	move.l ov_is,%d0
	jra .L1055
.L1056:
	move.l %d0,%d1
	add.l #-1073742852,%d1
	move.l %d0,ov_vt
	clr.l ov_is
	clr.l ov_list
	addq.l #1,ov_n
	cmp.l #2997243,%d1
	jls .L1058
.L1059:
	clr.l %d0
.L1055:
	movem.l (%sp),#7180
	lea (20,%sp),%sp
	rts
.L1058:
	mov3q.l #3,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L1059
	move.l %d0,%a0
	move.l -4(%a0),%d0
	move.l %d0,%d1
	add.l #-1073742848,%d1
	cmp.l #2997247,%d1
	jhi .L1059
	btst #0,%d0
	jne .L1059
	move.l %d0,%a0
	move.l 4(%a0),%a2
	move.l %a2,%d0
	add.l #-1073742848,%d0
	cmp.l #2997247,%d0
	jhi .L1059
.L1060:
	move.b (%a2),%d0
	moveq #9,%d1
	add.l #-48,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jcc .L1061
	clr.l %d2
.L1062:
	tst.b (%a2,%d2.l)
	jne .L1063
	pea .LC6
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	lea ov_suffix,%a3
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L1065
	pea .LC1
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L1065
	pea .LC2
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
.L1065:
	pea .LC3
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	move.l %d0,ov_list
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1066
	moveq #17,%d1
	cmp.l %d2,%d1
	jne .L1067
	pea .LC4
	pea 17.w
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	mov3q.l #1,%d1
	eor.l %d1,%d0
.L1067:
	move.l %d0,ov_is
	jra .L1068
.L1061:
	addq.l #1,%a2
	jra .L1060
.L1063:
	addq.l #1,%d2
	moveq #48,%d0
	cmp.l %d2,%d0
	jne .L1062
	jra .L1059
.L1066:
	pea .LC5
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1069
	mov3q.l #1,ov_is
	jra .L1068
.L1069:
	lea ov_names,%a4
	clr.l %d3
.L1073:
	move.l (%a4)+,%a0
	clr.l %d0
.L1070:
	tst.b (%a0,%d0.l)
	jne .L1071
	cmp.l %d0,%d2
	jne .L1072
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1072
	mov3q.l #1,ov_is
.L1072:
	addq.l #1,%d3
	moveq #14,%d0
	cmp.l %d3,%d0
	jne .L1073
	jra .L1068
.L1071:
	addq.l #1,%d0
	jra .L1070
	.size	overlay, .-overlay
	.align	2
	.type	sv_tick, @function
sv_tick:
	lea (-52,%sp),%sp
	clr.l %d1
	movem.l #31996,(%sp)
	move.l 56(%sp),%a4
	sub.l %a5,%a5
	clr.l sv+80
	clr.l sv+128
	move.l 28(%a4),%a2
	sub.l %a6,%a6
	lea (20,%a4),%a0
	clr.l %d0
	clr.l sv+148
	mov3q.l #1,sv+144
	clr.l %d7
	clr.l %d5
	clr.l %d3
	move.b 1093765506,%d6
	move.l %a0,48(%sp)
	mvz.b %d6,%d4
.L1085:
	tst.l %a2
	jeq .L1098
	cmp.l 48(%sp),%a2
	jeq .L1098
	move.l 8(%a2),%a3
	tst.l %a3
	jne .L1086
.L1107:
	clr.l %d2
.L1087:
	move.l sv+128,%a2
	tst.l %a2
	jeq .L1112
	addq.l #1,sv+136
	tst.l sv+144
	jne .L1113
	tst.l 140(%a2)
	jeq .L1113
	moveq #11,%d0
	cmp.l %d4,%d0
	jlt .L1113
	move.b %d6,%d1
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
	move.l %d4,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	moveq #127,%d1
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jeq .L1113
	move.l (%a2),%a0
	clr.l -(%sp)
	move.l %a2,-(%sp)
	move.l 96(%a0),%a0
	jsr (%a0)
	moveq #1,%d0
	addq.l #1,sv+140
	addq.l #8,%sp
	move.b %d0,32(%a4)
.L1113:
	lea (140,%a2),%a2
	move.l (%a2),sv+132
.L1112:
	tst.l %d2
	jne .L1114
	move.l %d4,%d0
	addq.l #1,%d0
	cmp.l ls_smpl.l,%d0
	jne .L1116
	moveq #11,%d1
	cmp.l %d4,%d1
	jlt .L1116
	move.l sv+148,%d2
	tst.l %d2
	jeq .L1116
.L1139:
	move.b %d6,%d1
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
	jeq .L1116
	tst.b sv.l
	jeq .L1117
	mvz.b sv+1,%d0
	cmp.l %d4,%d0
	jne .L1117
	mvz.b sv+2,%d0
	cmp.l %d0,%d5
	jeq .L1118
.L1117:
	moveq #1,%d4
	move.w #257,%d0
	move.b %d6,sv+1
	move.b %d3,sv+2
	move.b %d6,sv+5
	lea commits,%a0
	move.l (%a0),sv+12
	addq.l #1,sv+56
	move.b %d4,sv
	move.b %d4,sv+4
	move.w %d0,sv+6
.L1118:
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	seq %d4
	move.b sv,%d5
	neg.l %d4
	move.b %d4,sv+3
	tst.b %d5
	jeq .L1121
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jeq .L1122
.L1121:
	mov3q.l #-1,%d0
.L1123:
	move.l 60(%sp),%a0
	move.l %d0,sv+116
	cmp.l sv+20.l,%a0
	jeq .L1129
	clr.l sv+16
	sub.l %a0,%a0
.L1130:
	move.l 60(%sp),%d1
	move.l st+4,%a1
	move.l %d1,sv+20
	move.l sv+12,%d1
	move.l st+972,%d7
	tst.b %d5
	jeq .L1131
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	jne .L1132
.L1131:
	clr.l %d3
.L1133:
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
	jne .L1134
	move.l sv+104,%a0
	cmp.l sv+88.l,%a0
	jne .L1134
	tst.l %d2
	jeq .L1135
	move.l st+8,%d1
	moveq #19,%d4
	sub.l sv+108,%d1
	cmp.l %d1,%d4
	jge .L1135
.L1134:
	moveq #1,%d1
	move.b %d1,sv+102
.L1135:
	move.b %d0,sv+100
	mvz.b %d6,%d0
	mvz.b sv+9,%d1
	cmp.l %d0,%d1
	jeq .L1084
	tst.l %d3
	jeq .L1137
	addq.l #1,sv+72
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
.L1138:
	moveq #1,%d0
	move.b %d6,sv+9
	move.b %d0,32(%a4)
.L1084:
	movem.l (%sp),#31996
	lea (52,%sp),%sp
	rts
.L1086:
	move.l (%a3),%d2
	tst.l %d3
	jeq .L1088
	cmp.l #1075718412,%d2
	jeq .L1089
	cmp.l #1075712228,%d2
	jeq .L1089
	cmp.l #1075719596,%d2
	jeq .L1089
	cmp.l #1075717140,%d2
	jne .L1088
.L1089:
	move.l (%a2),%a2
.L1090:
	addq.l #1,%d7
	moveq #16,%d2
	cmp.l %d7,%d2
	jne .L1085
.L1098:
	cmp.l sv+84.l,%d0
	jne .L1102
	cmp.l sv+88.l,%a6
	jeq .L1103
.L1102:
	move.l %d0,sv+84
	move.l %a6,sv+88
	clr.l sv+96
.L1104:
	move.l %d7,sv+92
	tst.l %d5
	jeq .L1105
	moveq #16,%d0
	cmp.l %d7,%d0
	jeq .L1105
	tst.l %a2
	jne .L1106
.L1105:
	clr.l sv+80
	jra .L1107
.L1088:
	move.l %d2,%a6
	cmp.l #1075721468,%d2
	jne .L1091
	move.l %a3,sv+80
	mov3q.l #1,%d5
.L1092:
	tst.l %d3
	jeq .L1094
	lea sv_covers,%a0
	sub.l %a1,%a1
.L1095:
	cmp.l (%a0),%d2
	jne .L1097
.L1143:
	move.l %d3,%d1
.L1094:
	cmp.l #1076055292,%d2
	seq %d2
	move.l (%a2),%a2
	move.l %a3,%d0
	mvs.b %d2,%d2
	neg.l %d2
	or.l %d2,%d3
	jra .L1090
.L1091:
	cmp.l #1075720560,%d2
	jne .L1093
	mov3q.l #2,%d0
	or.l %d0,%d5
	move.l %a3,sv+128
	jra .L1092
.L1093:
	cmp.l #1075628548,%d2
	jne .L1092
	tst.b 127(%a3)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d1
	jra .L1092
.L1097:
	addq.l #4,%a0
	addq.l #1,%a1
	moveq #8,%d0
	cmp.l %a1,%d0
	jne .L1095
	move.l %d2,-(%sp)
	move.l %d1,48(%sp)
	jsr overlay
	addq.l #4,%sp
	move.l 44(%sp),%d1
	tst.l %d0
	jne .L1143
	move.l %d3,%a5
	jra .L1094
.L1103:
	move.l sv+96,%d0
	cmp.l #65534,%d0
	jhi .L1104
	addq.l #1,%d0
	move.l %d0,sv+96
	jra .L1104
.L1106:
	mov3q.l #1,%d2
	eor.l %d2,%d3
	or.l %d1,%d3
	tst.l %a5
	jeq .L1109
	cmp.l #1076055292,%a6
	jeq .L1109
	moveq #59,%d1
	cmp.l sv+96.l,%d1
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d3
.L1109:
	mov3q.l #1,%d2
	and.l %d5,%d2
	move.l %d3,sv+144
	btst #0,%d5
	jne .L1111
	addq.l #1,%d3
	clr.l sv+80
	move.l %d3,sv+148
	jra .L1087
.L1111:
	move.l %d3,%d2
	addq.l #1,%d2
	jra .L1087
.L1122:
	move.l 1100949720,%a2
	move.l %a2,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L1121
	jsr sq_grid
	tst.l %d0
	jeq .L1121
	move.l 348(%a2),%d1
	tst.l %d1
	jeq .L1196
	clr.l %d0
	jra .L1124
.L1126:
	addq.l #1,%d0
.L1124:
	btst %d0,%d1
	jeq .L1126
	jra .L1123
.L1196:
	move.l 344(%a2),%d1
	clr.l %d0
	tst.l %d1
	jeq .L1121
.L1127:
	btst %d0,%d1
	jeq .L1128
	add.l #32,%d0
	jra .L1123
.L1128:
	addq.l #1,%d0
	jra .L1127
.L1129:
	move.l sv+16,%a0
	cmp.l #65534,%a0
	jhi .L1130
	addq.l #1,%a0
	move.l %a0,sv+16
	jra .L1130
.L1132:
	cmp.l commits.l,%d1
	jeq .L1131
	moveq #19,%d0
	cmp.l %a0,%d0
	jcs .L1131
	move.l %a1,%d3
	or.l %d7,%d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
	jra .L1133
.L1137:
	subq.l #2,%d2
	tst.l %d2
	jne .L1138
	addq.l #1,sv+76
	jra .L1138
.L1114:
	moveq #11,%d1
	cmp.l %d4,%d1
	jge .L1139
	clr.l %d2
.L1116:
	tst.b sv.l
	jeq .L1118
	clr.b %d1
	moveq #1,%d4
	lea sv+1,%a0
	move.b (%a0),sv+5
	addq.l #1,sv+60
	move.b %d1,sv
	move.b %d4,sv+4
	move.b %d1,sv+6
	jra .L1118
	.size	sv_tick, .-sv_tick
	.align	2
	.type	enter, @function
enter:
	tst.l st+4
	jne .L1197
	tst.l st
	jeq .L1197
	tst.l st+972
	jeq .L1199
	clr.l st+972
	mov3q.l #6,st+988
.L1199:
	mov3q.l #1,st+4
	jsr ovl_pub
	clr.l st+12
	mov3q.l #-1,st+20
	lea commits,%a0
	moveq #16,%d0
	move.l (%a0),st+24
	addq.l #1,st+48
	lea st+96,%a0
.L1200:
	clr.l (%a0)+
	subq.l #1,%d0
	tst.l %d0
	jne .L1200
	lea st+408,%a0
.L1201:
	clr.l (%a0)+
	moveq #16,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1201
	mvz.b 11(%sp),%d0
	move.b 11(%sp),%d1
	lea (15,%sp),%a0
	move.b (%a0),st+993
	bset #8,%d0
	move.l 4(%sp),%a0
	clr.l st+196
	move.b %d1,st+162
	moveq #1,%d1
	move.l %d0,st+296
	moveq #1,%d0
	move.b %d0,st+161
	move.b %d0,st+163
	move.b %d0,mr+13
	move.b %d0,mr+19
	move.w #4095,%d0
	move.w %d0,ar+60
	move.b %d1,32(%a0)
.L1197:
	rts
	.size	enter, .-enter
	.align	2
	.type	leave, @function
leave:
	tst.l st+4
	jeq .L1204
	clr.l st+4
	jsr ovl_pub
	addq.l #1,st+52
	clr.l st+1038
	clr.l st+1058
	clr.l st+196
	tst.l nk
	jeq .L1206
	moveq #-33,%d0
	moveq #32,%d1
	and.l %d0,st+240
	or.l %d1,st+272
	clr.l nk
.L1206:
	clr.l %d0
	lea kq_nodown,%a1
	lea kq_owed,%a0
.L1207:
	clr.l (%a1,%d0.l)
	moveq #32,%d1
	clr.l (%a0,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L1207
	lea commits,%a0
	moveq #1,%d1
	mvs.b 11(%sp),%d0
	clr.l kq_owes
	move.l (%a0),sv+12
	move.l %d0,st+296
	clr.b %d0
	move.b %d1,st+161
	move.b 11(%sp),%d1
	move.b %d0,st+163
	move.b %d0,st+993
	move.b %d1,st+162
	tst.l sq+408
	jne .L1208
	clr.l st+1006
	jsr led_restore
.L1208:
	moveq #1,%d0
	move.l 4(%sp),%a0
	move.b %d0,32(%a0)
.L1204:
	rts
	.size	leave, .-leave
	.align	2
	.type	queue_key, @function
queue_key:
	lea (-20,%sp),%sp
	movem.l #1084,(%sp)
	move.l 24(%sp),%d3
	tst.l txsx_test
	jeq .L1211
	move.l st+8,%d0
	mov3q.l #1,txsx_test_on
	add.l txsx_test,%d0
	clr.l txsx_test
	move.l %d0,txsx_test_end
.L1211:
	tst.l kq_owes
	jeq .L1212
	jsr (kq_owed_in.part.0)
.L1212:
	moveq #31,%d1
	mov3q.l #1,%d0
	and.l %d3,%d1
	move.l %d3,%d2
	lsr.l #5,%d2
	lea kq_nodown,%a0
	move.l (%a0,%d2.l*4),%d4
	lsl.l %d1,%d0
	tst.l 28(%sp)
	jeq .L1213
	move.l %d0,%d1
	not.l %d1
	and.l %d4,%d1
	move.l %d1,(%a0,%d2.l*4)
	tst.l kq_owes
	jne .L1214
	move.l st+196,%d1
	moveq #15,%d5
	move.l %d1,%a1
	addq.l #6,%a1
	cmp.l %a1,%d5
	jcc .L1215
.L1214:
	or.l %d0,%d4
	addq.l #1,st+44
	move.l %d4,(%a0,%d2.l*4)
.L1210:
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L1213:
	move.l %d4,%d1
	and.l %d0,%d1
	tst.l %d1
	jeq .L1217
	not.l %d0
	and.l %d4,%d0
	move.l %d0,(%a0,%d2.l*4)
	jra .L1210
.L1217:
	move.l st+196,%d1
	moveq #15,%d4
	cmp.l %d1,%d4
	jcc .L1215
	move.l %d1,%a1
	subq.l #1,%a1
	lea st+164,%a0
.L1218:
	tst.l %a1
	jlt .L1219
	mvz.b (%a0,%a1.l*2),%d4
	cmp.l %d4,%d3
	jne .L1220
	move.l %a1,%d3
	add.l %d3,%d3
	move.l %d3,%d4
	add.l #st,%d4
	move.l %d4,%a2
	tst.b 165(%a2)
	jeq .L1219
	add.l %d3,%a0
.L1221:
	addq.l #1,%a1
	cmp.l %d1,%a1
	jlt .L1222
	subq.l #1,%d1
	move.l %d1,st+196
	addq.l #1,st+44
	jra .L1210
.L1220:
	subq.l #1,%a1
	jra .L1218
.L1222:
	addq.l #2,%a0
	move.b (%a0),-2(%a0)
	move.b 1(%a0),-1(%a0)
	jra .L1221
.L1219:
	lea kq_owed,%a0
	move.l (%a0,%d2.l*4),%d1
	move.l %d1,%d3
	and.l %d0,%d3
	tst.l %d3
	jne .L1210
	or.l %d0,%d1
	addq.l #1,kq_owes
	move.l %d1,(%a0,%d2.l*4)
	jra .L1210
.L1215:
	lea st,%a0
	move.l %d1,%d0
	add.l #82,%d0
	move.b %d3,(%a0,%d0.l*2)
	lea (%a0,%d1.l*2),%a0
	addq.l #1,%d1
	move.l %d1,st+196
	move.b 31(%sp),165(%a0)
	jra .L1210
	.size	queue_key, .-queue_key
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
	jeq .L1226
	move.l %d2,-(%sp)
	jsr cu_src_setup
	mvz.b cu+1,%d0
	move.l %d2,%d4
	addq.l #4,%sp
	add.l #-43,%d4
	cmp.l %d0,%d2
	jne .L1228
	move.l 1075597888,%d0
	cmp.l 4(%a2),%d0
	jne .L1228
	move.l 1075596172,%d0
	cmp.l 116(%a2),%d0
	jne .L1228
	move.l 1075597884,%d1
	moveq #9,%d0
	cmp.l %d4,%d0
	jcs .L1232
	lea CSWTCH.597,%a0
	move.l (%a0,%d4.l*4),%d0
.L1229:
	cmp.l %d0,%d1
	jeq .L1226
.L1228:
	lea cu_p2,%a3
	clr.l %d3
	lea CSWTCH.597,%a5
	lea cu_knob,%a4
.L1231:
	moveq #9,%d0
	cmp.l %d4,%d0
	jcs .L1233
	move.l (%a5,%d4.l*4),%d0
.L1230:
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
	jne .L1231
	move.w cu+2,%d0
	move.b %d2,cu+1
	addq.l #1,%d0
	move.w %d0,cu+2
.L1226:
	movem.l (%sp),#15388
	lea (28,%sp),%sp
	rts
.L1232:
	move.l #cu_fm_short,%d0
	jra .L1229
.L1233:
	move.l #cu_fm_short,%d0
	jra .L1230
	.size	cu_setup, .-cu_setup
	.align	2
	.type	isr_send, @function
isr_send:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jeq .L1239
.L1247:
	clr.l %d0
.L1238:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L1239:
#APP
| 1900 "rui.c" 1
	move.w %sr,%d0
| 0 "" 2
#NO_APP
	move.l %d0,%d3
	move.l %d0,%d2
	and.l #1792,%d3
	mvz.w %d2,%d2
	cmp.l #1279,%d3
	jhi .L1241
	and.l #63743,%d0
	or.l #1280,%d0
#APP
| 1904 "rui.c" 1
	move.w %d0,%sr
| 0 "" 2
#NO_APP
.L1241:
	tst.l 1123449384
	jeq .L1242
.L1244:
#APP
| 1909 "rui.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	addq.l #1,sq+388
	jra .L1247
.L1242:
	tst.l 1094562372
	jne .L1244
	move.l %d1,%d0
	add.l 1094562392,%d0
	cmp.l #3800,%d0
	jgt .L1244
	move.l 1094562704,%a0
	tst.l %a0
	jeq .L1244
	move.l 52(%a0),%a0
	tst.l %a0
	jeq .L1244
	move.l 52(%a0),%d0
	move.l 12(%sp),-(%sp)
	move.l %d1,-(%sp)
	jsr 1073752544
#APP
| 1909 "rui.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	mov3q.l #1,%d0
	addq.l #8,%sp
	jra .L1238
	.size	isr_send, .-isr_send
	.align	2
	.globl	rui_render_in
	.type	rui_render_in, @function
rui_render_in:
	link.w %fp,#-108
	movem.l #1052,(%sp)
	tst.l 1094562372
	jne .L1255
	mov3q.l #1,txsx_gap
.L1255:
	lea fp,%a0
	addq.l #1,(%a0)
	tst.l fp+8
	jeq .L1256
	move.l (%a0),%d0
	sub.l fp+4,%d0
	cmp.l #3000,%d0
	jls .L1256
	move.l fp+8,%a0
	move.l fp,%d0
	move.l fp+4,%d1
	move.l 1123449124,%d2
	tst.l fp+12
	jeq .L1257
	move.l fp,%a1
	sub.l fp+12,%a1
	cmp.l #7499,%a1
	jls .L1256
.L1257:
	cmp.l %a0,%d2
	seq %d3
	sub.l %d1,%d0
	lea (-90,%fp),%a1
	clr.l %d1
	move.l %a1,%a2
	neg.l %d3
.L1258:
	clr.l (%a2)+
	moveq #9,%d4
	addq.l #1,%d1
	cmp.l %d1,%d4
	jne .L1258
	cmp.l %a0,%d2
	jeq .L1259
	mov3q.l #1,%d1
	move.l 72(%a0),%d2
	and.l %d2,%d1
	btst #0,%d2
	jne .L1259
	move.l %d2,%a0
	add.l #-1073741824,%a0
	cmp.l #129892303,%a0
	jhi .L1259
.L1260:
	move.l %d2,%a0
	moveq #36,%d4
	lea 4(%a0,%d1.l),%a2
	move.l (%a2),(%a1,%d1.l)
	addq.l #4,%d1
	cmp.l %d1,%d4
	jne .L1260
.L1259:
	move.w #19969,%a2
	move.l #-260222380,%a0
	move.b %d3,-48(%fp)
	move.l %a0,-54(%fp)
	move.w %a2,-50(%fp)
	cmp.l #191999,%d0
	jhi .L1272
	mvz.w #1500,%d2
	divu.l %d2,%d0
.L1261:
	move.b %d0,-47(%fp)
	lea (-46,%fp),%a0
	clr.l %d1
.L1262:
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
	jne .L1262
	moveq #-9,%d1
	pea 54.w
	pea -54(%fp)
	move.b %d1,-1(%fp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1256
	lea fp,%a0
	tst.l (%a0)
	jeq .L1273
	move.l (%a0),%d0
.L1264:
	move.l %d0,fp+12
	addq.l #1,fp+16
.L1256:
	move.l 1123623180,%a0
	move.l qp,%d1
	move.l qp+8,%d3
	tst.l qp+12
	jne .L1265
	tst.l %a0
	sne %d0
	mov3q.l #1,qp+12
	move.l #1123623184,%a1
	move.l %a0,qp+16
	move.l (%a1),qp+20
	mov3q.l #-1,qp+28
	mvs.b %d0,%d0
	neg.l %d0
	move.l %d0,qp+24
.L1265:
	tst.l qp+24
	jne .L1266
	cmp.l qp+16.l,%a0
	jne .L1267
	move.l qp+20,%a2
	cmp.l 1123623184.l,%a2
	jeq .L1266
.L1267:
	mov3q.l #1,qp+24
.L1266:
	tst.l qp+4
	jeq .L1254
	move.l %a0,%d0
	mvz.b %d0,%d0
	and.l #4095,%d1
	move.l %d0,%a1
	move.l %a1,%d2
	move.l -2147422860,%d0
	move.l %d1,%d4
	lsl.l #4,%d4
	tst.l %d0
	sne %d0
	swap %d2
	clr.w %d2
	mvs.b %d0,%d0
	or.l %d4,%d2
	mov3q.l #1,%d4
	neg.l %d0
	lsl.l #2,%d0
	or.l %d0,%d2
	tst.l qp+24
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	add.l %d0,%d0
	or.l %d0,%d2
	mvz.b 1099764550,%d0
	lsr.l #5,%d0
	and.l %d4,%d0
	or.l %d0,%d2
	cmp.l qp+28.l,%d2
	jne .L1269
	cmp.l qp+36.l,%d3
	jeq .L1254
.L1269:
	move.l fp,%d0
	moveq #11,%d4
	sub.l qp+32,%d0
	cmp.l %d0,%d4
	jcc .L1254
	move.w #11521,%d0
	moveq #14,%d4
	pea 13.w
	move.l #-260222380,%a2
	pea -54(%fp)
	move.l %a2,-54(%fp)
	move.w %d0,-50(%fp)
	move.l %a1,%d0
	lsr.l #7,%d0
	move.b %d4,-48(%fp)
	moveq #127,%d4
	move.b %d0,-47(%fp)
	move.l %a0,%d0
	and.l %d4,%d0
	move.b %d0,-46(%fp)
	moveq #127,%d0
	and.l %d1,%d0
	lsr.l #7,%d1
	move.b %d1,-44(%fp)
	move.b %d0,-45(%fp)
	mov3q.l #7,%d0
	and.l %d2,%d0
	move.b %d0,-43(%fp)
	moveq #-9,%d0
	move.b %d0,-42(%fp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1254
	move.l qp+40,%d0
	tst.l %d0
	jeq .L1270
	move.l qp+84,%a0
	move.l qp+32,%d1
	tst.l %a0
	jeq .L1271
	move.l fp,%a1
	sub.l %d1,%a1
	cmp.l %a0,%a1
	jcc .L1270
.L1271:
	move.l fp,%d4
	sub.l %d1,%d4
	move.l %d4,qp+84
.L1270:
	lea fp,%a1
	addq.l #1,%d0
	move.l %d2,qp+28
	move.l %d3,qp+36
	move.l %d0,qp+40
	move.l (%a1),qp+32
.L1254:
	movem.l -108(%fp),#1052
	unlk %fp
	rts
.L1272:
	moveq #127,%d0
	jra .L1261
.L1273:
	mov3q.l #1,%d0
	jra .L1264
	.size	rui_render_in, .-rui_render_in
	.align	2
	.globl	smpl_hold
	.type	smpl_hold, @function
smpl_hold:
	move.l 4(%sp),%a0
	move.l #1075720560,%d0
	move.b 1093765506,%d1
	cmp.l (%a0),%d0
	jeq .L1299
.L1301:
	clr.l %d0
.L1300:
	rts
.L1299:
	mvz.b %d1,%d0
	move.l %d0,%a1
	moveq #11,%d0
	cmp.l %a1,%d0
	jlt .L1301
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
	jra .L1300
	.size	smpl_hold, .-smpl_hold
	.align	2
	.globl	rui_uart
	.type	rui_uart, @function
rui_uart:
	lea (-40,%sp),%sp
	movem.l #19468,(%sp)
	tst.b ov_on.l
	jne .L1313
	tst.b ovp_on.l
	jne .L1313
	tst.b ovt_on.l
	jne .L1313
	clr.l %d2
	tst.b ovm_on.l
	jeq .L1304
.L1318:
	move.l 44(%sp),%a0
	subq.l #1,%a0
	sub.l %a6,%a6
	lea rui_uart_raw,%a3
	move.l %a0,20(%sp)
	jra .L1309
.L1305:
	move.l 48(%sp),%a0
	mvz.b (%a0,%d2.l),%d0
	addq.l #1,%d2
	move.l %d0,-(%sp)
	jsr uart_byte
	addq.l #4,%sp
.L1304:
	cmp.l 44(%sp),%d2
	jlt .L1305
	clr.l %d0
.L1302:
	movem.l (%sp),#19468
	lea (40,%sp),%sp
	rts
.L1310:
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
	jeq .L1307
	cmp.l 20(%sp),%a6
	jne .L1308
.L1307:
	pea 24(%sp)
	move.l %d3,-(%sp)
	jsr (%a3)
	addq.l #8,%sp
	clr.l %d3
.L1308:
	addq.l #1,%a6
	move.l %d3,%d2
.L1309:
	cmp.l 44(%sp),%a6
	jlt .L1310
	mov3q.l #1,%d0
	jra .L1302
.L1313:
	clr.l %d2
	jra .L1318
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
	jcc .L1320
.L1324:
	clr.l %d0
.L1319:
	move.l (%sp)+,%d2
	rts
.L1320:
	tst.l sq
	jeq .L1322
	move.l sq+4,%a0
	move.l %a0,%d2
	btst %d1,%d2
	jeq .L1322
	addq.l #1,sq+448
	mov3q.l #1,%d0
	jra .L1319
.L1322:
	tst.l %d0
	jlt .L1325
	moveq #63,%d2
	cmp.l %d0,%d2
	jlt .L1326
.L1323:
	lea pc,%a0
	move.b %d0,48(%a0,%d1.l)
	moveq #1,%d0
	lea st+8,%a1
	move.l (%a1),(%a0,%d1.l*4)
	move.b %d0,60(%a0,%d1.l)
	jra .L1324
.L1325:
	clr.b %d0
	jra .L1323
.L1326:
	moveq #63,%d0
	jra .L1323
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
	jcs .L1333
	mov3q.l #1,%d1
	cmp.l 1079807120.l,%d1
	jeq .L1335
	clr.l sq+540
	clr.l sq+544
.L1333:
	movem.l (%sp),#3132
	lea (24,%sp),%sp
	rts
.L1335:
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
	jeq .L1337
	mvz.b 516(%a0),%d1
	cmp.l %d4,%d1
	jeq .L1338
.L1339:
	clr.l %d0
.L1337:
	mov3q.l #1,%d1
	lsl.l %d2,%d1
	move.l %a1,%d5
	move.b %d3,516(%a0)
	move.b 35(%sp),528(%a0)
	or.l %d1,%d5
	move.l sq+360,%d1
	move.l %d5,sq+540
	btst #8,%d1
	jeq .L1341
	tst.l %d0
	jne .L1333
	tst.l %d4
	jeq .L1342
	tst.l sq+544
	jeq .L1343
.L1342:
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
.L1343:
	lsr.l #7,%d4
	jne .L1333
	tst.l (%a2)
	jeq .L1333
	move.l sq+8,%d0
	btst %d2,%d0
	jeq .L1333
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
	jne .L1344
	mvz.w #917,%d0
	muls.l %d2,%d0
	add.l #709,%d0
	move.b (%a0,%d0.l),%d0
	jpl .L1346
	moveq #127,%d0
.L1346:
#APP
| 1900 "rui.c" 1
	move.w %sr,%d1
| 0 "" 2
#NO_APP
	move.l %d1,%d5
	move.l %d1,%d4
	and.l #1792,%d5
	mvz.w %d4,%d4
	cmp.l #1792,%d5
	jeq .L1348
	and.l #63743,%d1
	or.l #1792,%d1
#APP
| 1904 "rui.c" 1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
.L1348:
	move.l sq+268,%d1
	sub.l sq+272,%d1
	lsr.l #5,%d1
	jeq .L1349
	addq.l #1,sq+380
.L1350:
#APP
| 1909 "rui.c" 1
	move.w %d4,%sr
| 0 "" 2
#NO_APP
	jra .L1333
.L1338:
	mvz.b 528(%a0),%d1
	cmp.l 32(%sp),%d1
	jeq .L1339
	addq.l #1,sq+548
	mov3q.l #1,sq+544
	jra .L1337
.L1341:
	tst.l %d0
	jne .L1333
	jra .L1343
.L1344:
	move.l #85683,%d0
	move.b (%a0,%d0.l),%d0
	move.l #85684,%d1
	mvz.b (%a0,%d1.l),%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	moveq #127,%d1
	cmp.l %d0,%d1
	jcc .L1346
	moveq #127,%d0
	jra .L1346
.L1349:
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
	jra .L1350
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
	jcc .L1364
	clr.l %d2
.L1364:
	tst.l sq+348
	jne .L1365
	move.l %d2,sq+352
	move.l %d3,sq+356
	mov3q.l #1,sq+348
.L1365:
	lea sq,%a6
	tst.l (%a6)
	jeq .L1366
	cmp.l sq+352.l,%d2
	jeq .L1367
	move.l %d2,%d1
	mvz.b %d1,%d1
	move.l %d4,-(%sp)
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr sq_event
	lea (20,%sp),%sp
.L1367:
	move.l sq+356,%d0
	cmp.l %d0,%d3
	jeq .L1368
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jne .L1369
	bset #8,%d0
	move.l %d0,sq+360
.L1366:
	move.l %d2,sq+352
	move.l %d3,sq+356
.L1371:
	tst.l sq+344
	jne .L1376
	move.l %sp,%d3
	move.l %sp,%d2
	add.l #42,%d3
	add.l #36,%d2
.L1377:
	move.l sq+272,%d4
	cmp.l sq+268.l,%d4
	jne .L1383
.L1382:
	move.l -66650100,%d0
	sub.l 32(%sp),%d0
	cmp.l sq+396.l,%d0
	jls .L1363
	move.l %d0,sq+396
.L1363:
	movem.l (%sp),#23612
	lea (104,%sp),%sp
	rts
.L1369:
	mvz.b %d0,%d0
	move.l %d4,-(%sp)
	mov3q.l #2,-(%sp)
	move.l %d5,-(%sp)
	move.l %d0,-(%sp)
	mov3q.l #3,-(%sp)
	jsr sq_event
	lea (20,%sp),%sp
.L1370:
	move.l sq+360,%d0
	btst #8,%d0
	jeq .L1366
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
	jra .L1366
.L1368:
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jne .L1370
	jra .L1366
.L1376:
	mvz.b sq+340,%d0
	move.l %d0,-(%sp)
	pea sq+276
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1363
	move.l sq+344,%d3
	clr.l %d1
	addq.l #1,sq+376
	lea sq+340,%a0
.L1373:
	cmp.l %d3,%d0
	jlt .L1375
	subq.l #1,%d3
	move.l %d3,sq+344
	jra .L1371
.L1375:
	mvz.w %d0,%d2
	lea sq+276,%a2
	sub.l %a1,%a1
	sub.l %d1,%a2
	lsl.l #4,%d2
.L1374:
	move.l %a2,%d4
	add.l %d1,%d4
	move.l %d4,%a4
	addq.l #1,%a1
	move.b (%a4,%d2.l),(%a2)+
	moveq #16,%d4
	cmp.l %a1,%d4
	jne .L1374
	move.b 1(%a0),(%a0)
	addq.l #1,%a0
	addq.l #1,%d0
	add.l #-16,%d1
	jra .L1373
.L1383:
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
.L1378:
	move.l sq+272,%d0
	add.l %d4,%d0
	cmp.l sq+268.l,%d0
	jeq .L1379
	moveq #14,%d0
	cmp.l %d4,%d0
	jeq .L1379
	move.l sq+272,%d0
	moveq #31,%d1
	add.l %d4,%d0
	and.l %d1,%d0
	lsl.l #3,%d0
	cmp.l 12(%a6,%d0.l),%d5
	jeq .L1380
.L1379:
	move.b %d4,46(%sp)
	move.b #-9,(%a0)+
	sub.l %d2,%a0
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1382
	add.l %d4,sq+272
	addq.l #1,sq+372
	jra .L1377
.L1380:
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
	jra .L1378
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
	jne .L1404
	move.l pin+16,%d0
	move.l pin+12,%d1
	addq.l #1,pin+32
	move.l %d0,50(%sp)
	or.l 58(%sp),%d0
	or.l %d1,%d0
	jeq .L1404
	move.l pin+20,%a1
	tst.l %a1
	jne .L1406
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
.L1406:
	clr.b %d4
	clr.b %d5
	sub.l %a0,%a0
	clr.l %d3
	move.l pin+8,%d2
	clr.l %d6
	move.l pin+48,%a6
	move.b %d4,63(%sp)
	move.b %d5,62(%sp)
.L1420:
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
	jcs .L1407
	move.l 58(%sp),%d5
	move.l %a4,%d7
	btst %d7,%d5
	jeq .L1407
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
	jeq .L1408
	move.l #128,(%a3)
	move.l #128,(%a2)
	move.l %a1,4(%a3)
	move.l %a1,4(%a2)
	tst.l %a5
	jeq .L1409
	addq.l #1,pin+44
.L1409:
	moveq #1,%d0
	and.l 54(%sp),%d2
	move.b %d0,62(%sp)
.L1410:
	move.l 46(%sp),%a2
	add.l #-2147457816,%a2
	clr.l (%a2)
	cmp.l #32512,%d5
	jeq .L1425
	cmp.l #255,%d5
	jls .L1413
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
	jls .L1414
	mvz.w #65535,%d4
.L1414:
	mulu.w #32512,%d0
	move.w %d4,(%a3)
	divu.l %d5,%d0
	cmp.l #65535,%d0
	jls .L1415
	mvz.w #65535,%d0
.L1415:
	move.w %d0,(%a2)
.L1413:
	moveq #1,%d0
	move.w #32512,(%a0)
	addq.l #1,%a6
	move.b %d0,63(%sp)
.L1425:
	move.w #1,%a0
	jra .L1412
.L1408:
	tst.l %a5
	jeq .L1411
	moveq #127,%d0
	moveq #127,%d4
	move.l %d0,(%a3)
	move.l pin+28,%d0
	move.l %d4,(%a2)
	move.l %d0,4(%a3)
	move.l %d0,4(%a2)
	jra .L1410
.L1411:
	moveq #1,%d4
	move.l pin+24,%d7
	move.l #1073741951,(%a3)
	move.l #1073741951,(%a2)
	move.l %d7,4(%a3)
	or.l %d0,%d2
	move.l %d7,4(%a2)
	addq.l #1,pin+40
	move.b %d4,62(%sp)
	jra .L1410
.L1407:
	move.l 50(%sp),%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L1416
	move.l %d0,%d4
	not.l %d4
	and.l %d4,%d2
	moveq #1,%d4
	or.l %d0,%d1
	move.w #1,%a0
	move.b %d4,62(%sp)
.L1416:
	move.l %d1,%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L1412
	btst #6,(%a2)
	jeq .L1418
	not.l %d0
	and.l %d0,%d1
	jra .L1425
.L1418:
	move.l #128,(%a3)
	move.l #128,(%a2)
	move.l %a1,4(%a3)
	move.l %a1,4(%a2)
.L1412:
	addq.l #1,%d3
	moveq #8,%d5
	cmp.l %d3,%d5
	jne .L1420
	tst.b 63(%sp)
	jeq .L1421
	move.l %a6,pin+48
.L1421:
	tst.b 62(%sp)
	jeq .L1422
	move.l %d2,pin+8
.L1422:
	move.w %a0,%d7
	tst.b %d7
	jeq .L1423
	move.l %d1,pin+12
.L1423:
	tst.l %d6
	jeq .L1424
	addq.l #1,pin+36
.L1424:
	move.l -66650100,%d0
	move.l %d6,pin+16
	sub.l 68(%sp),%d0
	cmp.l pin+52.l,%d0
	jls .L1404
	move.l %d0,pin+52
.L1404:
	movem.l (%sp),#31996
	lea (72,%sp),%sp
	rts
	.size	pin_frame, .-pin_frame
	.align	2
	.globl	ed_report
	.type	ed_report, @function
ed_report:
	lea (-16,%sp),%sp
	moveq #12,%d0
	movem.l #60,(%sp)
	move.l 20(%sp),%d3
	cmp.l %d3,%d0
	jcs .L1457
	mvz.w #4368,%d2
	lsr.l %d3,%d2
	mov3q.l #1,%d1
	and.l %d1,%d2
.L1452:
	move.l %d3,%d0
	subq.l #1,%d0
	lsr.l #1,%d0
	mvs.b 1079807236,%d4
	tst.l %d0
	jne .L1455
	jsr 1075312702
	move.l 24(%sp),%d1
	add.l #-16092,%d1
	sub.l %d0,%d1
	cmp.l #187903,%d1
	jhi .L1455
	mvz.w #1468,%d5
	remu.l %d5,%d0:%d1
	divu.l %d5,%d1
	tst.l %d0
	jne .L1455
	move.l %d1,%d4
.L1455:
	tst.l %d2
	jeq .L1458
	mov3q.l #3,%d0
	and.l 28(%sp),%d0
.L1456:
	move.l %d4,-(%sp)
	move.l %d0,-(%sp)
	clr.l -(%sp)
	move.l 44(%sp),%d0
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	move.l %d3,-(%sp)
	jsr ed_queue_pat
	movem.l 20(%sp),#60
	lea (36,%sp),%sp
	rts
.L1457:
	clr.l %d2
	jra .L1452
.L1458:
	clr.l %d0
	jra .L1456
	.size	ed_report, .-ed_report
	.align	2
	.globl	pm_menu_add
	.type	pm_menu_add, @function
pm_menu_add:
	link.w %fp,#-68
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	tst.l 8(%fp)
	jeq .L1459
	lea (-64,%fp),%a2
	clr.l %d0
	move.l %a2,%a0
.L1461:
	clr.l 12(%a0)
	clr.l 8(%a0)
	clr.l (%a0)
	clr.l 4(%a0)
	addq.l #1,%d0
	lea (16,%a0),%a0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L1461
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
	jeq .L1459
	tst.l %a3
	jeq .L1459
	tst.l -32(%fp)
	jeq .L1459
	tst.l %d0
	jeq .L1459
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
.L1462:
	mvz.w -66(%fp),%d0
	lsl.l #4,%d0
	pea (%a2,%d0.l)
	jsr 1075251654
	subq.l #1,-68(%fp)
	addq.l #4,%sp
	mov3q.l #-1,%d0
	cmp.l -68(%fp),%d0
	jne .L1462
	addq.l #1,pm+4
.L1459:
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
	jcc .L1475
	addq.l #1,pm+24
	pea pm_t_track
.L1479:
	move.l %a0,-(%sp)
	jsr pm_popup
	addq.l #8,%sp
	rts
.L1475:
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L1477
	move.l commits,%d1
	cmp.l pm+28.l,%d1
	jne .L1478
.L1477:
	addq.l #1,pm+20
	pea pm_t_none
	jra .L1479
.L1478:
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
	jeq .L1480
	move.l %d2,-(%sp)
	addq.l #1,cu+12
	jsr cu_src_setup
	addq.l #4,%sp
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-48,%d0
	cmp.l %d0,%d1
	jcc .L1482
	moveq #43,%d0
	cmp.l %d2,%d0
	jne .L1480
.L1482:
	moveq #11,%d1
	cmp.l 12(%sp),%d1
	jcs .L1480
	move.l #1075731444,%a0
	cmp.l sv+88.l,%a0
	jne .L1480
	lea (15,%sp),%a0
	mvz.b cu+30,%d0
	move.b (%a0),cu+10
	lea st+8,%a0
	move.b %d2,cu+9
	move.l (%a0),cu+16
	cmp.l 12(%sp),%d0
	jne .L1484
	move.b cu+28,%d0
.L1483:
	move.b %d0,cu+29
.L1480:
	move.l (%sp)+,%d2
	rts
.L1484:
	clr.b %d0
	jra .L1483
	.size	cu_prep, .-cu_prep
	.align	2
	.globl	cu_mi_settling
	.type	cu_mi_settling, @function
cu_mi_settling:
	mvz.b cu+11,%d1
	move.l 4(%sp),%d0
	addq.l #1,%d0
	cmp.l %d1,%d0
	jne .L1487
	move.l st+8,%d0
	moveq #15,%d1
	sub.l cu+24,%d0
	cmp.l %d0,%d1
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1485:
	rts
.L1487:
	clr.l %d0
	jra .L1485
	.size	cu_mi_settling, .-cu_mi_settling
	.align	2
	.globl	ms_pad
	.type	ms_pad, @function
ms_pad:
	lea (-20,%sp),%sp
	movem.l #124,(%sp)
	move.l ms+16,%d6
	move.l 28(%sp),%d5
	addq.l #1,ms+260
	tst.l %d6
	jne .L1489
.L1491:
	clr.l %d2
.L1488:
	move.l %d2,%d0
	movem.l (%sp),#124
	lea (20,%sp),%sp
	rts
.L1489:
	tst.l ms
	jeq .L1491
	moveq #27,%d0
	cmp.l %d5,%d0
	jcc .L1492
	move.l %d5,%d0
	add.l #-39,%d0
	cmp.l #429,%d0
	jhi .L1493
.L1492:
	moveq #52,%d0
	moveq #40,%d1
	muls.l %d5,%d0
	move.l %d0,%a0
	add.l #1075575068,%a0
	move.l (%a0),%d4
	move.l %d4,%d0
	subq.l #1,%d0
	cmp.l %d0,%d1
	jcs .L1493
	mov3q.l #5,-(%sp)
	move.l %d4,-(%sp)
	move.l 40(%sp),-(%sp)
	jsr pmo_word_ok
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jne .L1494
.L1493:
	pea .LC0
	addq.l #1,ms+248
	jsr ms_say
	addq.l #4,%sp
	mov3q.l #1,%d2
	jra .L1488
.L1494:
	tst.b 43(%sp)
	sne %d3
	mvs.b %d3,%d3
	neg.l %d3
	tst.l ms+60
	jeq .L1495
	move.l 32(%sp),%a0
	cmp.l ms+68.l,%a0
	jne .L1496
	cmp.l ms+72.l,%d4
	jne .L1496
	cmp.l ms+76.l,%d3
	jne .L1496
	cmp.l ms+64.l,%d6
	jeq .L1497
.L1496:
	jsr ms_acc_out
	jsr ms_acc_drop
	clr.l ms+60
.L1495:
	move.l 24(%sp),%a1
	move.l (%a1),%a0
	mov3q.l #-1,-(%sp)
	move.l %a1,-(%sp)
	move.l 160(%a0),%a0
	jsr (%a0)
	move.l %d0,%a0
	move.l (%a0),%a1
	move.l %d5,-(%sp)
	move.l %d0,-(%sp)
	move.l 40(%a1),%a0
	jsr (%a0)
	lea (16,%sp),%sp
	move.l %d0,ms+264
	cmp.l #32767,%d0
	jle .L1498
	mvz.w #16383,%d0
.L1499:
	move.l 32(%sp),%d1
	lea ms+16,%a0
	move.l %d0,ms+80
	mov3q.l #1,ms+60
	move.l %d1,ms+68
	move.l %d4,ms+72
	move.l %d3,ms+76
	clr.l ms+84
	move.l (%a0),ms+64
.L1497:
	move.l 36(%sp),%d0
	add.l %d0,ms+84
	jra .L1488
.L1498:
	asr.l #1,%d0
	jpl .L1499
	clr.l %d0
	jra .L1499
	.size	ms_pad, .-ms_pad
	.align	2
	.globl	ms_knob
	.type	ms_knob, @function
ms_knob:
	link.w %fp,#-12
	move.l 12(%fp),%a0
	mov3q.l #7,%d0
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 12(%a0),%d2
	mvz.b %d2,%d2
	move.l 16(%fp),%d1
	add.l #-112,%d2
	cmp.l %d2,%d0
	jcs .L1504
	mov3q.l #1,%d3
	and.l 16(%a0),%d3
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	move.l ms+272,%d2
	tst.l %d3
	jne .L1505
	move.l %d0,%d1
	and.l %d2,%d1
	tst.l %d1
	jeq .L1504
	not.l %d0
	and.l %d2,%d0
	move.l %d0,ms+272
.L1506:
	mov3q.l #1,-12(%fp)
	jra .L1503
.L1505:
	tst.l ms
	jeq .L1507
	tst.l ms+16
	jne .L1508
.L1507:
	not.l %d0
	and.l %d2,%d0
	move.l %d0,ms+272
.L1504:
	clr.l -12(%fp)
.L1503:
	move.l -12(%fp),%d0
	move.l -20(%fp),%d2
	move.l -16(%fp),%d3
	unlk %fp
	rts
.L1508:
	move.l %d0,%d3
	and.l %d2,%d3
	tst.l %d3
	jne .L1506
	or.l %d2,%d0
	move.l %d0,ms+272
	moveq #27,%d0
	cmp.l %d1,%d0
	jcc .L1511
	move.l %d1,%d0
	add.l #-39,%d0
	cmp.l #429,%d0
	jhi .L1515
.L1511:
	moveq #52,%d0
	muls.l %d0,%d1
	move.l %d1,%a0
	add.l #1075575068,%a0
	move.l (%a0),%d2
.L1512:
	move.l 8(%fp),%a0
	move.l 116(%a0),-(%sp)
	jsr 1074489554
	addq.l #4,%sp
	moveq #40,%d1
	move.l %d0,%d3
	move.l %d2,%d0
	subq.l #1,%d0
	cmp.l %d0,%d1
	jcs .L1513
	mov3q.l #5,-(%sp)
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr pmo_word_ok
	lea (12,%sp),%sp
	move.l %d0,-12(%fp)
	tst.l %d0
	jne .L1514
.L1513:
	pea .LC0
	addq.l #1,ms+248
	jsr ms_say
	addq.l #4,%sp
	jra .L1506
.L1515:
	mov3q.l #-1,%d2
	jra .L1512
.L1514:
	jsr ms_acc_out
	jsr ms_acc_drop
	moveq #20,%d0
	pea -8(%fp)
	move.b %d3,-6(%fp)
	move.b %d2,-5(%fp)
	clr.l ms+60
	clr.l -4(%fp)
	move.b %d0,-8(%fp)
	move.l ms+16,%d0
	subq.l #1,%d0
	move.b %d0,-7(%fp)
	jsr ms_push
	addq.l #1,ms+268
	addq.l #4,%sp
	jra .L1503
	.size	ms_knob, .-ms_knob
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
	jne .L1523
	move.l pmo+96,%d2
	cmp.l pmo+76.l,%d2
	jeq .L1524
.L1523:
	lea pmo+76,%a0
	move.l %d0,pmo+100
	move.l (%a0),pmo+96
	tst.l pmo
	jeq .L1524
	lea pmo+584,%a0
	clr.l %d0
.L1525:
	clr.l (%a0)+
	addq.l #1,%d0
	cmp.l #208,%d0
	jne .L1525
	lea pmo+3464,%a0
	clr.l %d0
.L1526:
	clr.b (%a0)
	addq.l #1,%d0
	lea (44,%a0),%a0
	cmp.l #128,%d0
	jne .L1526
	clr.l %d0
.L1527:
	move.l %d0,%d1
	add.l #36,%d1
	clr.l (%a2,%d1.l*4)
	moveq #13,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1527
	clr.l pmo
	clr.l pmo+104
	clr.l pmo+9096
	clr.l pmo+300
	clr.l pmo+10096
	addq.l #1,pmo+32
.L1524:
	move.l pmo+56,%d7
	move.l pmo+88,%d2
	cmp.l pmo+68.l,%d2
	jne .L1528
	move.l pmo+92,%d3
	cmp.l pmo+72.l,%d3
	jeq .L1606
.L1528:
	move.l %d7,%d0
	add.l pmo+9228,%d0
	lea pmo+68,%a0
	move.l (%a0),pmo+88
	lea pmo+72,%a4
	sub.l pmo+80,%d0
	move.l (%a4),pmo+92
	pea 32.w
	pea 8191.w
	move.l %d0,pmo+9228
	move.l %d7,pmo+80
	jsr pmo_fade
	addq.l #8,%sp
	mov3q.l #1,52(%sp)
.L1529:
	moveq #65,%d6
	sub.l %a4,%a4
	clr.l %d4
	lea pmo_get,%a5
.L1530:
	move.l pmo+80,%d3
	cmp.l %d3,%d7
	jeq .L1550
	subq.l #1,%d6
	tst.l %d6
	jne .L1551
.L1550:
	tst.l %d4
	jeq .L1552
.L1534:
	move.l %a4,-(%sp)
	move.l %d4,-(%sp)
	jsr pmo_fade
	addq.l #8,%sp
	mov3q.l #1,52(%sp)
.L1552:
	move.l pmo+10092,%d0
	tst.l %d0
	jeq .L1553
	move.l %d0,%d6
	subq.l #1,%d6
	move.l %d6,pmo+10092
	subq.l #1,%d0
	tst.l %d0
	jeq .L1554
	move.l pmo+10084,%d0
	add.l %d0,pmo+10080
.L1553:
	tst.l pmo
	jne .L1555
.L1596:
	move.l 56(%sp),-(%sp)
	jsr pmo_time
	addq.l #4,%sp
	movem.l (%sp),#31996
	lea (80,%sp),%sp
	rts
.L1606:
	clr.l 52(%sp)
	jra .L1529
.L1551:
	mvz.b %d3,%d3
	move.l %d3,%d2
	lsl.l #3,%d2
	lea (%a2,%d2.l),%a0
	mvz.b 1423(%a0),%d0
	cmp.l pmo+100.l,%d0
	jeq .L1531
	addq.l #1,pmo+8
.L1537:
	move.l %d4,%d0
.L1532:
	addq.l #1,pmo+80
	move.l %d0,%d4
	jra .L1530
.L1531:
	mvz.b 1418(%a0),%d0
	mov3q.l #6,%d1
	move.l %d0,%a1
	cmp.l %d0,%d1
	jne .L1533
	mvz.w 1420(%a0),%d0
	mvz.b 1419(%a0),%d2
	addq.l #1,pmo+28
	or.l %d4,%d0
	move.l %d2,%a4
	jra .L1532
.L1533:
	tst.l %d4
	jne .L1534
	add.l #177,%d3
	move.l %d3,%d1
	lsl.l #3,%d1
	addq.l #1,pmo+28
	move.b 1(%a2,%d1.l),%d5
	mvz.b (%a2,%d1.l),%d0
	moveq #63,%d1
	and.l %d5,%d1
	mov3q.l #4,%d5
	move.l %d1,60(%sp)
	cmp.l %a1,%d5
	jne .L1535
	mvz.w 1420(%a0),%d3
	moveq #18,%d1
	lsl.l %d1,%d3
	move.l %d3,%a0
	asr.l %d1,%d3
	tst.l %a0
	jne .L1536
	move.l %d0,%d5
	lsl.l #6,%d5
	lea (%a2,%d5.l),%a0
	add.l 60(%sp),%a0
	tst.b 584(%a0)
	jeq .L1537
.L1536:
	move.l 60(%sp),-(%sp)
	move.l %d0,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
	tst.l %d0
	jne .L1538
	addq.l #1,pmo+16
	mov3q.l #4,pmo+120
	jra .L1537
.L1538:
	move.l %d2,%a0
	add.l #pmo+1419,%a0
	mvz.b (%a0),%d1
	move.l %d1,-(%sp)
	moveq #10,%d1
	lsl.l %d1,%d3
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	jsr pmo_off
.L1696:
	lea (12,%sp),%sp
	jra .L1537
.L1535:
	moveq #10,%d5
	cmp.l %a1,%d5
	jne .L1539
	move.w 1420(%a0),%d1
	moveq #9,%d0
	mvz.w #16383,%d3
	and.l #16383,%d1
	lsl.l %d0,%d1
	move.l %d1,%d0
	add.l #8191,%d0
	divu.l %d3,%d0
	add.l %d1,%d0
	move.b 1419(%a0),%d1
	move.l %d0,pmo+10088
	tst.b %d1
	jne .L1540
	move.l %d0,pmo+10080
	clr.l pmo+10092
	jra .L1537
.L1540:
	moveq #127,%d2
	moveq #9,%d5
	and.l %d1,%d2
	sub.l pmo+10080,%d0
	lea pmo_rcp,%a0
	mvz.b %d1,%d1
	asr.l %d5,%d0
	move.l %d1,pmo+10092
	mvz.w (%a0,%d2.l*2),%d2
	muls.l %d2,%d0
	asr.l #6,%d0
	move.l %d0,pmo+10084
	jra .L1537
.L1539:
	moveq #9,%d1
	cmp.l %a1,%d1
	jne .L1541
	mvz.w 1420(%a0),%d3
	moveq #14,%d5
	lsr.l %d5,%d3
	jne .L1542
	lsl.l #6,%d0
	lea (%a2,%d0.l),%a0
	add.l 60(%sp),%a0
	mvz.b 584(%a0),%d0
	tst.l %d0
	jeq .L1532
	move.l %d0,%d1
	moveq #12,%d0
	subq.l #1,%d1
	muls.l %d1,%d0
	move.l %d0,%a0
	add.l #pmo+10108,%a0
	move.l (%a0),%d0
	tst.l %d0
	jeq .L1532
	mulu.w #44,%d1
	pea 8.w
	add.l #pmo+3464,%d1
	move.l %d1,-(%sp)
	jsr (pmo_mph_end.constprop.0)
	addq.l #8,%sp
	jra .L1537
.L1542:
	move.l 60(%sp),-(%sp)
	move.l %d0,-(%sp)
	jsr pmo_get
	addq.l #8,%sp
	tst.l %d0
	jne .L1543
	moveq #9,%d0
	addq.l #1,pmo+16
	move.l %d0,pmo+120
	jra .L1537
.L1543:
	sub.l #pmo+3464,%d0
	asr.l #2,%d0
	mvz.w %d3,%d5
	move.l #-1171354716,%d3
	muls.l %d0,%d3
	move.l %d3,%a0
	add.l #pmo+10108,%a0
	move.l (%a0),%d3
	tst.l %d3
	jne .L1544
	mvz.w #2048,%d3
	addq.l #1,pmo+10096
.L1544:
	move.l #-1171354716,%d1
	muls.l %d1,%d0
	lea (%a2,%d2.l),%a1
	lea (%a2,%d0.l),%a0
	move.w 1420(%a1),%d0
	move.l %d0,%d2
	and.l #16383,%d2
	mvz.b 1419(%a1),%d0
	lsl.l #7,%d0
	move.l %d2,10100(%a0)
	mvz.b 1422(%a1),%d2
	or.l %d2,%d0
	move.l %d0,10104(%a0)
	moveq #-4,%d0
	and.l %d0,%d3
	or.l %d5,%d3
	move.l %d3,10108(%a0)
	jra .L1537
.L1541:
	move.b 1422(%a0),%d1
	mvz.b %d1,%d5
	move.w %d1,%a1
	moveq #126,%d1
	move.l %d5,%a6
	cmp.l %d5,%d1
	jcs .L1607
	move.w %a1,%d5
	tst.b %d5
	jeq .L1546
	move.l %a6,%d1
	move.l #66052,%d5
	muls.l %d5,%d1
	move.l %d1,%a6
.L1545:
	move.l 60(%sp),-(%sp)
	move.l %d0,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
	move.l %d0,%a0
	tst.l %d0
	jne .L1547
	addq.l #1,pmo+16
	mov3q.l #5,pmo+120
	jra .L1537
.L1546:
	move.l %d0,%d1
	lsl.l #6,%d1
	lea (%a2,%d1.l),%a0
	add.l 60(%sp),%a0
	tst.b 584(%a0)
	jeq .L1537
	sub.l %a6,%a6
	jra .L1545
.L1607:
	move.l #8388608,%a6
	jra .L1545
.L1547:
	move.l %d2,%a1
	add.l #pmo+1420,%a1
	mvz.w (%a1),%d1
	moveq #9,%d5
	lsl.l %d5,%d1
	move.l %d1,24(%a0)
	tst.l 28(%a0)
	jne .L1548
	tst.b 3(%a0)
	jne .L1548
	move.l %d1,16(%a0)
.L1548:
	lsl.l #3,%d3
	move.b 1(%a2,%d3.l),%d1
	btst #6,%d1
	jne .L1608
	move.l %d2,%a1
	add.l #pmo+1419,%a1
	mvz.b (%a1),%d1
.L1549:
	move.l %d1,-(%sp)
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	jsr pmo_mix
	jra .L1696
.L1608:
	clr.l %d1
	jra .L1549
.L1554:
	lea pmo+10088,%a0
	move.l (%a0),pmo+10080
	jra .L1553
.L1555:
	tst.l 52(%sp)
	jne .L1557
	move.l pmo+84,%a4
	cmp.l pmo+60.l,%a4
	jeq .L1557
	move.l (%a3),%d0
	sub.l pmo+60,%d0
	cmp.l #375,%d0
	jls .L1557
	lea pmo+60,%a5
	move.l (%a5),pmo+84
	pea 32.w
	pea 8191.w
	addq.l #1,pmo+12
	jsr pmo_fade
	addq.l #8,%sp
.L1557:
	tst.l -2147418904
	jeq .L1558
	lea pmo+512,%a0
	clr.l %d0
.L1559:
	clr.l (%a0)+
	moveq #18,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1559
	move.l #-2147423060,%a0
.L1561:
	move.w (%a0),%d1
	mvz.w %d1,%d0
	cmp.l #571,%d0
	jhi .L1560
	moveq #31,%d3
	lsr.l #5,%d0
	and.l %d3,%d1
	mov3q.l #1,%d3
	add.l #128,%d0
	lsl.l %d1,%d3
	or.l %d3,(%a2,%d0.l*4)
.L1560:
	addq.l #2,%a0
	cmp.l #-2147422964,%a0
	jne .L1561
.L1558:
	move.l pmo+10096,%d3
	move.l pmo+104,%a1
	clr.l pmo+300
	tst.l %d3
	jeq .L1562
	move.l pmo+10080,%d4
	move.l %d4,%d5
	asr.l #7,%d5
	lea pmo+3464,%a0
	clr.l %d2
	lea pmo+10100,%a3
	lea pmo_rcp,%a4
	move.l %d5,52(%sp)
.L1563:
	cmp.l %d2,%a1
	jne .L1570
.L1562:
	lea pmo,%a3
	clr.l %d2
	lea pmo+3464,%a0
	lea pmo+10108,%a4
	jra .L1585
.L1570:
	move.l 8(%a3),%d5
	mov3q.l #3,%d0
	and.l %d5,%d0
	tst.l %d0
	jeq .L1564
	tst.b (%a0)
	jeq .L1564
	move.l %d5,%d1
	mov3q.l #3,%d6
	lsr.l #8,%d1
	cmp.l %d0,%d6
	jne .L1565
	move.l 52(%sp),%d7
	moveq #15,%d6
	move.l (%a3),%a5
	move.l 4(%a3),%d0
	sub.l %a5,%d0
	muls.l %d7,%d0
	add.l #16384,%d0
	asr.l %d6,%d0
	move.l %d0,%a6
	move.l #8388608,%d0
	lea (%a6,%a5.l*2),%a6
	move.l %a6,%d7
.L1566:
	tst.l %d1
	jeq .L1568
	mov3q.l #1,%d6
	cmp.l %d1,%d6
	jeq .L1569
	move.l 28(%a0),%a5
	moveq #9,%d6
	sub.l %a5,%d0
	asr.l %d6,%d0
	moveq #127,%d6
	and.l %d6,%d1
	mvz.w (%a4,%d1.l*2),%d1
	muls.l %d1,%d0
	asr.l #6,%d0
	add.l %a5,%d0
.L1569:
	add.l #-256,%d5
	move.l %d5,8(%a3)
.L1568:
	lsl.l #8,%d7
	move.l %d0,36(%a0)
	move.l %d0,28(%a0)
	move.l %d7,24(%a0)
	move.l %d7,16(%a0)
	clr.b %d7
	move.b %d7,3(%a0)
.L1564:
	addq.l #1,%d2
	lea (44,%a0),%a0
	lea (12,%a3),%a3
	jra .L1563
.L1565:
	subq.l #1,%d0
	tst.l %d0
	jne .L1567
	move.l (%a3),%d0
	move.l %d0,%d7
	add.l %d7,%d7
	move.l #8388608,%d0
	sub.l %d4,%d0
	jra .L1566
.L1567:
	move.l 4(%a3),%d0
	move.l %d0,%d7
	add.l %d7,%d7
	move.l %d4,%d0
	jra .L1566
.L1586:
	move.b (%a0),%d1
	jeq .L1571
	move.b 2(%a0),%d0
	jeq .L1572
	subq.l #1,%d0
	move.b %d0,2(%a0)
	jeq .L1573
	move.l 8(%a0),%d0
	add.l %d0,4(%a0)
.L1572:
	move.b 3(%a0),%d0
	jeq .L1574
	subq.l #1,%d0
	move.b %d0,3(%a0)
	jeq .L1575
	move.l 20(%a0),%d4
	move.l 32(%a0),%d5
	add.l %d4,16(%a0)
	add.l %d5,28(%a0)
.L1574:
	move.l 4(%a0),%d0
	tst.l %d0
	jne .L1576
	tst.b 2(%a0)
	jne .L1576
	tst.l 28(%a0)
	jne .L1576
	tst.b 3(%a0)
	jne .L1576
	tst.l %d3
	jeq .L1577
	tst.l (%a4)
	jne .L1576
.L1577:
	mvz.b %d1,%d1
	clr.b %d6
	mvz.b 1(%a0),%d0
	subq.l #1,%d1
	lsl.l #6,%d1
	lea (%a2,%d1.l),%a5
	add.l %d0,%a5
	move.b %d6,584(%a5)
	clr.b (%a0)
	move.l pmo+9096,%d0
	move.l %d0,%d7
	addq.l #1,%d7
	subq.l #1,(%a2)
	lea (%a2,%d0.l),%a5
	move.b %d2,9100(%a5)
	move.l %d7,pmo+9096
.L1571:
	addq.l #1,%d2
	lea (44,%a0),%a0
	lea (12,%a4),%a4
.L1585:
	cmp.l %d2,%a1
	jne .L1586
	clr.b %d0
	lea pmo+3464,%a0
.L1589:
	tst.l %a1
	jne .L1587
	tst.b %d0
	jeq .L1588
	clr.l pmo+104
.L1588:
	move.l pmo+300,%d2
	move.l #-2147420170,%a2
	lea pmo,%a0
	clr.l %d1
	move.l #-2147457058,%a1
	jra .L1594
.L1573:
	move.l 12(%a0),4(%a0)
	jra .L1572
.L1575:
	move.l 24(%a0),16(%a0)
	move.l 36(%a0),28(%a0)
	jra .L1574
.L1576:
	move.b 1(%a0),%d4
	moveq #8,%d6
	mvz.b %d4,%d5
	cmp.l %d5,%d6
	jcs .L1578
	move.l 40(%a0),%d1
	move.l %d1,%d4
	add.l %d4,%d4
	move.l 28(%a0),%d5
	move.l %d4,%a5
	add.l #-2147420300,%a5
	mvz.w (%a5),%d4
	tst.l %d5
	jeq .L1581
	tst.l -2147418904
	jeq .L1580
	move.l %d1,%d6
	lsr.l #5,%d6
	lea pmo,%a6
	add.l #128,%d6
	move.l (%a6,%d6.l*4),%d7
	moveq #31,%d6
	and.l %d1,%d6
	btst %d6,%d7
	jeq .L1580
	lea fp,%a6
	addq.l #1,pmo+52
	move.l (%a6),pmo+108
.L1581:
	asr.l #8,%d0
	add.l %d4,%d0
	tst.l %d0
	jlt .L1609
	cmp.l #32767,%d0
	jgt .L1610
.L1582:
	move.w %d0,(%a5)
	jra .L1571
.L1580:
	lsl.l #2,%d1
	asr.l #8,%d5
	move.l %d1,%a6
	add.l #-2147422588,%a6
	move.l (%a6),%d6
	move.l 16(%a0),%d1
	asr.l #8,%d1
	clr.w %d6
	swap %d6
	sub.l %d6,%d1
	muls.l %d5,%d1
	moveq #15,%d5
	asr.l %d5,%d1
	add.l %d1,%d4
	jra .L1581
.L1609:
	clr.w %d0
	jra .L1582
.L1610:
	move.w #32767,%d0
	jra .L1582
.L1578:
	move.l %d4,%d5
	add.l #-48,%d5
	mvz.b %d5,%d5
	lsr.l #3,%d5
	jne .L1571
	mvz.b %d1,%d1
	move.l pmo+300,%d6
	asr.l #8,%d0
	move.l %d1,%d5
	subq.l #1,%d5
	btst %d5,%d6
	jne .L1583
	mov3q.l #1,%d7
	lsl.l %d5,%d7
	add.l #18,%d1
	lsl.l #4,%d1
	or.l %d6,%d7
	move.l %d7,pmo+300
	clr.w %d7
	move.w %d7,(%a2,%d1.l)
	move.l %d5,%d1
	lsl.l #4,%d1
	move.l %d1,%a5
	add.l #pmo,%a5
	move.w %d7,306(%a5)
	clr.l 308(%a5)
	clr.l 312(%a5)
	clr.l 316(%a5)
.L1583:
	cmp.l #-32768,%d0
	jlt .L1611
	cmp.l #32767,%d0
	jgt .L1612
.L1584:
	lsl.l #3,%d5
	mvz.b %d4,%d4
	move.l %d4,%a6
	lea 104(%a6,%d5.l),%a5
	move.w %d0,(%a2,%a5.l*2)
	jra .L1571
.L1611:
	move.w #-32768,%d0
	jra .L1584
.L1612:
	move.w #32767,%d0
	jra .L1584
.L1613:
	moveq #1,%d0
	move.l %d1,%a1
	jra .L1589
.L1587:
	move.l %a1,%d1
	subq.l #1,%d1
	move.w %d1,%d2
	mulu.w #44,%d2
	tst.b (%a0,%d2.l)
	jeq .L1613
	tst.b %d0
	jeq .L1588
	move.l %a1,pmo+104
	jra .L1588
.L1595:
	btst #0,%d0
	jeq .L1591
	move.l %d1,%d3
	add.l #-536856241,%d3
	lsl.l #2,%d3
	mvz.w -26(%a1),%d0
	move.l %d3,%a4
	btst #3,3(%a4)
	jeq .L1614
	mvs.w (%a2),%d3
.L1592:
	move.l %d0,%a5
	add.l %d3,%a5
	move.l %a5,196(%a0)
	move.l %a5,%d0
	cmp.l #32767,%a5
	jle .L1593
	mvz.w #32767,%d0
.L1593:
	move.l %d0,196(%a0)
	mvs.w (%a1),%d0
	move.l %d0,248(%a0)
.L1591:
	addq.l #1,%d1
	addq.l #4,%a0
	addq.l #2,%a1
	lea (84,%a2),%a2
.L1594:
	move.l %d2,%d0
	lsr.l %d1,%d0
	jne .L1595
	tst.l %d2
	jeq .L1596
	lea pmo+9248,%a2
	clr.l %d5
	move.l #pmo+304,%d6
	lea pmo,%a5
.L1605:
	mov3q.l #1,%d1
	and.l %d2,%d1
	move.l %d1,64(%sp)
	btst #0,%d2
	jeq .L1597
	move.w %d5,%d0
	mvz.w %d5,%d4
	lea (16,%a2),%a1
	clr.l %d3
	move.l %d6,44(%sp)
	clr.l %d7
	lsl.l #4,%d4
	mulu.w #21,%d0
	add.l #26,%d0
	move.l %d0,68(%sp)
.L1603:
	move.l 44(%sp),%a6
	sub.l %a0,%a0
	lea (-32,%a1),%a4
	move.l %a6,52(%sp)
	move.l %d4,%a6
	add.l #-2147423684,%a6
	move.l %a6,72(%sp)
.L1602:
	move.l 72(%sp),%a6
	move.l (%a6,%a0.l),%d1
	move.l 52(%sp),%a6
	addq.l #2,52(%sp)
	mvz.w %d1,%d1
	mvz.w (%a6)+,%d0
	move.l %d0,48(%sp)
	tst.l %d0
	jeq .L1598
	move.l %d1,%d0
	sub.l 68(%sp),%d0
	move.l %d0,60(%sp)
	subq.l #1,%d0
	move.l %d0,76(%sp)
	moveq #40,%d0
	cmp.l 76(%sp),%d0
	jcc .L1599
.L1598:
	move.l %d1,(%a1,%a0.l)
	move.l %d1,(%a4,%a0.l)
.L1600:
	addq.l #4,%a0
	moveq #16,%d1
	cmp.l %a0,%d1
	jne .L1602
	lea (16,%a1),%a1
	add.l #16,%d4
	addq.l #8,44(%sp)
	subq.l #1,%d7
	tst.l %d7
	jne .L1615
	move.b %d3,10064(%a5)
	btst #0,%d3
	jeq .L1604
	pea -16(%a2)
	move.l 196(%a3),-(%sp)
	jsr 1074912702
	addq.l #8,%sp
.L1604:
	btst #1,%d3
	jeq .L1597
	move.l %a2,-(%sp)
	move.l 248(%a3),-(%sp)
	jsr 1074912702
	addq.l #8,%sp
.L1597:
	lsr.l #1,%d2
	addq.l #4,%a3
	lea (64,%a2),%a2
	addq.l #1,%a5
	addq.l #2,%d5
	add.l #16,%d6
	tst.l %d2
	jne .L1605
	jra .L1596
.L1614:
	clr.l %d3
	jra .L1592
.L1615:
	move.l 64(%sp),%d7
	jra .L1603
.L1599:
	move.l 48(%sp),%d0
	swap %d0
	clr.w %d0
	or.l %d1,%d0
	move.l %d0,%a6
	moveq #8,%d0
	cmp.l 60(%sp),%d0
	jcs .L1601
	move.l %a6,(%a4,%a0.l)
	move.l %d1,(%a1,%a0.l)
	mov3q.l #1,%d0
.L1697:
	lsl.l %d7,%d0
	or.l %d0,%d3
	jra .L1600
.L1601:
	move.l %a6,(%a1,%a0.l)
	move.l %d1,(%a4,%a0.l)
	mov3q.l #4,%d0
	jra .L1697
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
	jeq .L1699
	move.w #12,%a6
	lea (44,%sp),%a2
	move.l %a2,%a0
.L1700:
	clr.l (%a0)+
	subq.l #1,%a6
	tst.l %a6
	jne .L1700
	move.l pmo+104,%d1
	clr.l %d5
	lea pmo,%a4
	lea pmo+3464,%a0
	move.l %d1,36(%sp)
.L1701:
	cmp.l 36(%sp),%d5
	jne .L1710
	move.l pmo+300,%d2
	tst.l %d2
	jeq .L1715
	lea pmo+9280,%a5
	move.l #pmo,%d3
.L1714:
	btst #0,%d2
	jeq .L1712
	move.b 10064(%a4),%d0
	move.w %d0,%ccr
	jne .L1713
	pea -16(%a5)
	move.l %d3,%a0
	move.l 196(%a0),-(%sp)
	jsr 1074912702
	addq.l #8,%sp
.L1713:
	move.b 10064(%a4),%d0
	move.w %d0,%ccr
	jpl .L1712
	move.l %a5,-(%sp)
	move.l %d3,%a1
	move.l 248(%a1),-(%sp)
	jsr 1074912702
	addq.l #8,%sp
.L1712:
	lsr.l #1,%d2
	addq.l #1,%a4
	addq.l #4,%d3
	lea (64,%a5),%a5
	tst.l %d2
	jne .L1714
.L1715:
	move.l %a6,%d0
	add.l #36,%d0
	move.l (%a2)+,(%a3,%d0.l*4)
	addq.l #1,%a6
	moveq #12,%d0
	cmp.l %a6,%d0
	jne .L1715
	mov3q.l #1,pmo+140
.L1716:
	move.l 40(%sp),-(%sp)
	jsr pmo_time
	addq.l #4,%sp
	move.l pmo+116,%d0
	cmp.l pmo+36.l,%d0
	jls .L1718
	move.l %d0,pmo+36
.L1718:
	movem.l (%sp),#31804
	add.l %d0,pmo+40
	addq.l #1,pmo+44
	lea (92,%sp),%sp
	rts
.L1710:
	move.b (%a0),%d1
	jeq .L1702
	mvz.b 1(%a0),%d0
	moveq #41,%d2
	cmp.l %d0,%d2
	jcs .L1703
	moveq #8,%d3
	cmp.l %d0,%d3
	jcc .L1702
	move.l 40(%a0),%d0
	move.l %d0,%d1
	add.l %d1,%d1
	move.l 28(%a0),%d3
	move.l %d1,%a5
	add.l #-2147420300,%a5
	mvz.w (%a5),%d2
	tst.l %d3
	jeq .L1706
	tst.l -2147418904
	jeq .L1705
	move.l %d0,%d1
	lsr.l #5,%d1
	add.l #128,%d1
	move.l (%a3,%d1.l*4),%d4
	moveq #31,%d1
	and.l %d0,%d1
	btst %d1,%d4
	jeq .L1705
	lea fp,%a1
	addq.l #1,pmo+52
	move.l (%a1),pmo+108
.L1706:
	move.l 4(%a0),%d0
	asr.l #8,%d0
	add.l %d2,%d0
	tst.l %d0
	jlt .L1719
	cmp.l #32767,%d0
	jgt .L1720
.L1707:
	move.w %d0,(%a5)
.L1702:
	addq.l #1,%d5
	lea (44,%a0),%a0
	jra .L1701
.L1705:
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
	jra .L1706
.L1719:
	clr.w %d0
	jra .L1707
.L1720:
	move.w #32767,%d0
	jra .L1707
.L1703:
	moveq #56,%d2
	cmp.l %d0,%d2
	jne .L1702
	move.l 4(%a0),%d0
	asr.l #8,%d0
	cmp.l #32767,%d0
	jle .L1708
	mvz.w #32767,%d0
.L1708:
	mvz.b %d1,%d1
	move.l 16(%a0),%d2
	subq.l #1,%d1
	and.l #8323072,%d2
	cmp.l #-32768,%d0
	jge .L1709
	mvs.w #-32768,%d0
.L1709:
	mvz.w %d0,%d0
	moveq #24,%d3
	or.l %d0,%d2
	mvs.w 28(%a0),%d0
	lsl.l %d3,%d0
	or.l %d0,%d2
	move.l %d2,44(%sp,%d1.l*4)
	jra .L1702
.L1699:
	tst.l pmo+140
	jeq .L1716
.L1717:
	move.l %d0,%d1
	add.l #36,%d1
	clr.l (%a3,%d1.l*4)
	moveq #12,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1717
	clr.l pmo+140
	jra .L1716
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
	jcs .L1751
	add.l #36,%d1
	lea pmo,%a0
	move.l (%a0,%d1.l*4),%a0
	tst.l %a0
	jeq .L1751
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
	jge .L1753
	moveq #127,%d0
.L1751:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L1753:
	tst.l %d0
	jgt .L1751
	mov3q.l #1,%d0
	jra .L1751
	.size	pmo_vel, .-pmo_vel
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
.L1759:
	mov3q.l #1,%d0
	cmp.l fp+20.l,%d0
	jeq .L1759
.L1760:
	mov3q.l #2,%d1
	cmp.l fp+20.l,%d1
	jeq .L1761
	move.l 1100667228,%d0
	cmp.l #cu_text,%d0
	jeq .L1762
	cmp.l 1100664624.l,%d0
	jne .L1762
	move.l #cu_text,%d2
	move.l %d2,1100667228
.L1762:
	move.l #1075731444,%d3
	cmp.l sv+88.l,%d3
	jeq .L1763
	move.l #1093765506,%a1
	moveq #11,%d4
	mvz.b (%a1),%d0
	cmp.l %d0,%d4
	jcs .L1763
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
.L1763:
	tst.b cu.l
	jne .L1764
	move.l #1128813124,%d6
	cmp.l 1073849308.l,%d6
	jne .L1764
	moveq #1,%d7
	pea 52.w
	move.b %d7,cu
	jsr cu_src_setup
	addq.l #4,%sp
	lea cu_steps,%a0
	move.l %a0,1073849316
	lea cu_setup,%a1
	move.l %a1,1073849312
.L1764:
	move.l rx,%d2
	move.l #-66650100,%a3
	addq.l #1,st+8
	move.l (%a3),st+300
	tst.l st
	jne .L1765
#APP
| 2815 "rui.c" 1
	.if RAM_RUI_SHADOW_SIZE < 1024
.error "registry buffer RUI_SHADOW is too small"
.endif
| 0 "" 2
#NO_APP
	pea 1024.w
	pea shadow
	lea ram_zero,%a2
	jsr (%a2)
#APP
| 2815 "rui.c" 1
	.if RAM_RUI_STAGING_SIZE < 1024
.error "registry buffer RUI_STAGING is too small"
.endif
| 0 "" 2
#NO_APP
	pea 1024.w
	pea staging
	jsr (%a2)
#APP
| 2815 "rui.c" 1
	.if RAM_RUI_COMP_SIZE < 1024
.error "registry buffer RUI_COMP is too small"
.endif
| 0 "" 2
#NO_APP
	pea 1024.w
	pea comp
	jsr (%a2)
#APP
| 2815 "rui.c" 1
	.if RAM_RUI_COMP_IN_SIZE < 1024
.error "registry buffer RUI_COMP_IN is too small"
.endif
| 0 "" 2
#NO_APP
	pea 1024.w
	pea comp_in
	jsr (%a2)
#APP
| 2816 "rui.c" 1
	.if RAM_RUI_TXT_ST_SIZE < 2816
.error "registry buffer RUI_TXT_ST is too small"
.endif
| 0 "" 2
#NO_APP
	lea (32,%sp),%sp
	pea 2816.w
	pea txt_st
	jsr (%a2)
#APP
| 2816 "rui.c" 1
	.if RAM_RUI_TXT_SH_SIZE < 2816
.error "registry buffer RUI_TXT_SH is too small"
.endif
| 0 "" 2
#NO_APP
	pea 2816.w
	pea txt_sh
	jsr (%a2)
#APP
| 2816 "rui.c" 1
	.if RAM_RUI_TXT_TL_SIZE < 2816
.error "registry buffer RUI_TXT_TL is too small"
.endif
| 0 "" 2
#NO_APP
	pea 2816.w
	pea txt_tl
	jsr (%a2)
#APP
| 2816 "rui.c" 1
	.if RAM_RUI_UX_SIZE < 3968
.error "registry buffer RUI_UX is too small"
.endif
| 0 "" 2
#NO_APP
	pea 3968.w
	pea ux
	jsr (%a2)
	move.l #rui_sysex,%d0
	move.l %d0,1075551840
	move.l #1381321040,%d1
	move.l %d1,1075551836
	mov3q.l #1,st
	move.l %d2,st+16
	lea (32,%sp),%sp
.L1766:
	move.l #ux,%d6
	jra .L1922
.L1761:
	pea 10000.w
	jsr 1074367512
	addq.l #4,%sp
	jra .L1760
.L1765:
	tst.b host_close.l
	jeq .L1767
	clr.b %d3
	lea commits,%a0
	move.b %d3,host_close
	move.b %d3,host_open
	move.l (%a0),sv+12
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	addq.l #8,%sp
.L1767:
	tst.b host_open.l
	jeq .L1768
	clr.b %d0
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	move.b %d0,host_open
	jsr enter
	lea (12,%sp),%sp
.L1768:
	move.l st+956,%d0
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L1769
	cmp.l #65534,%d0
	jhi .L1770
	tst.l %d0
	jne .L1771
	moveq #50,%d3
	cmp.l st+8.l,%d3
	jcc .L1772
.L1771:
	addq.l #1,%d0
	move.l %d0,st+956
	moveq #10,%d4
	cmp.l %d0,%d4
	jne .L1770
.L1773:
	moveq #1,%d6
	move.w #4095,%d7
	move.l %d2,st+964
	mov3q.l #1,st+960
	mov3q.l #1,st+1106
	move.b %d6,st+992
	move.b %d6,mr+13
	move.b %d6,mr+19
	move.w %d7,ar+60
	jsr sq_forget
	lea commits,%a0
	move.l (%a0),pm+28
	clr.l ls_host_p13
.L1774:
	move.l host_rehello,%d0
	cmp.l st+1102.l,%d0
	jeq .L1778
	move.l %d0,st+1102
	moveq #9,%d0
	cmp.l st+956.l,%d0
	jcc .L1778
	move.l st+1098,%d1
	move.l st+8,%d0
	tst.l %d1
	jeq .L1779
	move.l %d0,%a0
	sub.l %d1,%a0
	moveq #19,%d1
	cmp.l %a0,%d1
	jcc .L1778
.L1779:
	moveq #1,%d3
	move.w #4095,%d4
	move.l %d0,st+1098
	addq.l #1,st+1094
	mov3q.l #3,st+960
	move.b %d3,st+992
	move.b %d3,mr+13
	move.b %d3,mr+19
	move.w %d4,ar+60
	jsr sq_forget
	clr.l ls_host_p13
.L1778:
	tst.b st+992.l
	jeq .L1780
	tst.b sv.l
	jeq .L1780
	moveq #1,%d5
	lea sv+1,%a0
	move.w #257,%a1
	move.b (%a0),sv+5
	move.b %d5,sv+4
	move.w %a1,sv+6
.L1780:
	tst.l splash_req
	jeq .L1782
	move.l splash_req,%d3
	clr.l splash_req
	tst.l st+4
	jne .L1783
	moveq #127,%d0
	and.l %d0,%d3
	tst.l %d3
	jeq .L1784
	tst.l commits
	jne .L1785
.L1783:
	addq.l #1,st+984
.L1782:
	tst.l st+4
	jeq .L1787
	cmp.l st+16.l,%d2
	jeq .L1788
	clr.l st+12
.L1789:
	move.l %d2,st+16
	clr.b %d0
	move.l st+8,%a1
	lea st+408,%a0
	clr.l -184(%fp)
.L1795:
	move.l (%a0)+,%d1
	tst.l %d1
	jeq .L1793
	move.l %a1,%d3
	sub.l %d1,%d3
	jmi .L1793
	moveq #1,%d0
	clr.l -4(%a0)
.L1793:
	addq.l #1,-184(%fp)
	moveq #16,%d4
	cmp.l -184(%fp),%d4
	jne .L1795
	tst.b %d0
	jeq .L1796
	mov3q.l #1,st+344
.L1796:
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr sv_tick
	addq.l #8,%sp
	tst.b ls.l
	jeq .L1797
	move.l ls_smpl,%d1
	lea sv,%a0
	move.b (%a0),%d0
	tst.l %d1
	jeq .L1798
	tst.b sv+8.l
	jne .L1799
	tst.b %d0
	jeq .L1800
	tst.b sv+3.l
	jne .L1800
	mvz.b sv+1,%d1
	mvz.b ls+1,%d0
	cmp.l %d1,%d0
	jne .L1800
	tst.l st+4
	jne .L1800
	move.l commits,%d5
	cmp.l sv+12.l,%d5
	jne .L1800
	move.l st+8,%d0
	moveq #20,%d6
	sub.l ls+130,%d0
	cmp.l %d0,%d6
	jcc .L1797
.L1800:
	move.l commits,%a0
	cmp.l sv+12.l,%a0
	jne .L1802
	move.l st+8,%d0
	moveq #20,%d1
	sub.l ls+130,%d0
	cmp.l %d0,%d1
	jcc .L1802
	move.l st+968,%d2
	addq.l #1,%d2
	move.l %d2,ls+138
	jra .L1802
.L1772:
	move.l st+4,%d0
	tst.l %d0
	jeq .L1770
	moveq #10,%d5
	move.l %d5,st+956
	jra .L1773
.L1770:
	move.l st+960,%d3
	move.l %d3,%d1
	subq.l #1,%d1
	lsr.l #1,%d1
	jne .L1774
	moveq #20,%d1
	moveq #20,%d5
	muls.l %d3,%d1
	cmp.l %d1,%d5
	seq %d1
	neg.l %d1
	tst.b %d1
	jeq .L1775
	moveq #30,%d1
.L1776:
	cmp.l %d1,%d0
	jne .L1774
	cmp.l st+964.l,%d2
	jne .L1777
	moveq #1,%d6
	move.w #4095,%d7
	addq.l #1,%d3
	move.l %d3,st+960
	mov3q.l #1,st+1106
	move.b %d6,st+992
	move.b %d6,mr+13
	move.b %d6,mr+19
	move.w %d7,ar+60
	jra .L1774
.L1775:
	moveq #50,%d1
	jra .L1776
.L1777:
	mov3q.l #3,st+960
	jra .L1774
.L1769:
	tst.l %d0
	jeq .L1781
	addq.l #1,pmo+72
.L1781:
	clr.b %d0
	lea host_rehello,%a0
	move.l (%a0),st+1102
	clr.l qp+4
	lea qp+56,%a1
	move.l (%a1),qp+60
	lea qp+92,%a3
	clr.l st+956
	move.l (%a3),qp+96
	clr.l ls_host_presets
	clr.l ls_host_p13
	clr.l fk_claim
	clr.l st+960
	clr.l st+1106
	clr.l st+1098
	clr.l qp+100
	clr.l ms
	clr.l ms+152
	clr.l ms+16
	clr.l ms+60
	clr.l ms+4
	clr.l ms+8
	move.b %d0,st+992
	tst.l sq
	jeq .L1780
	jsr sq_forget
	jra .L1780
.L1784:
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr splash_end
	addq.l #8,%sp
	jra .L1782
.L1785:
	tst.l st+972
	jne .L1786
	mov3q.l #1,st+972
	jsr ovl_pub
	addq.l #1,st+980
	mov3q.l #-1,st+20
	clr.l st+12
	mov3q.l #1,st+344
.L1786:
	move.l %d3,st+976
	jra .L1782
.L1788:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d1
	cmp.l %d0,%d1
	jcc .L1789
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	clr.l mask_set
.L2336:
	addq.l #8,%sp
	jra .L1789
.L1787:
	tst.l st+972
	jeq .L1789
	cmp.l st+16.l,%d2
	jeq .L1790
	clr.l st+12
.L1791:
	move.l st+976,%d0
	subq.l #1,%d0
	move.l %d0,st+976
	tst.l %d0
	jne .L1789
	mov3q.l #1,-(%sp)
	jra .L2337
.L1790:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d3
	cmp.l %d0,%d3
	jcc .L1791
	mov3q.l #3,-(%sp)
.L2337:
	move.l %a2,-(%sp)
	jsr splash_end
	jra .L2336
.L1808:
	tst.b sv.l
	jeq .L1806
	tst.b sv+8.l
	jeq .L1806
	mvz.b sv+1,%d2
	mvz.b 1093765506,%d1
	cmp.l %d2,%d1
	jne .L1806
	mvz.b sv+2,%d1
	cmp.l %d0,%d1
	jne .L1806
	clr.l -(%sp)
	clr.l -(%sp)
	jsr ls_enc
	addq.l #8,%sp
	tst.l %d0
	jeq .L1806
	clr.l u46+8
	addq.l #1,u46+28
	jra .L1806
.L1811:
	mvz.b %d2,%d2
	move.l %d2,-(%sp)
	clr.l -(%sp)
	move.l %a2,-(%sp)
	jsr enter
	lea (12,%sp),%sp
	addq.l #1,pm+12
.L1809:
	tst.l st+4
	jne .L1812
.L1813:
	tst.l st+1058
	jne .L1814
.L1815:
	tst.l st+4
	jeq .L1817
.L1821:
	tst.l st+1058
	jne .L1822
	move.l commits,%d2
	cmp.l st+20.l,%d2
	jne .L1823
	tst.l st+344
	jeq .L1822
.L1823:
	moveq #1,%d3
	move.b %d3,32(%a2)
	jra .L1822
.L1816:
	move.l sv+88,%d0
	cmp.l #1075650164,%d0
	jeq .L1818
	move.l %d0,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jeq .L1819
.L1818:
	mov3q.l #1,st+1062
	jra .L1815
.L1819:
	tst.l st+1062
	jne .L1820
	move.l st+8,%d0
	moveq #20,%d1
	sub.l st+1066,%d0
	cmp.l %d0,%d1
	jcc .L1815
.L1820:
	clr.l st+1058
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
	jra .L1815
.L1826:
	clr.l sq+468
	clr.l st+1006
.L1828:
	clr.b %d4
	move.b %d4,led_owed
	jsr led_restore
	move.l led_again,%d0
	tst.l %d0
	jeq .L1835
	tst.b ov_on.l
	jne .L1835
	move.l st+8,%d1
	sub.l %d0,%d1
	jmi .L1835
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1836
.L2338:
	addq.l #1,st+1018
.L1835:
	move.l sq+468,%d2
	move.l pg_gen,%d0
	mvz.b ovp_on,%d4
	tst.l %d2
	jeq .L1840
	cmp.l sq+472.l,%d0
	jeq .L1841
	btst #0,%d0
	jne .L1841
	move.b pg_req,%d5
	move.b pg_req+1,%d3
	move.b pg_req+2,%d2
	move.b pg_req+3,%d1
	cmp.l pg_gen.l,%d0
	jne .L1841
	move.b %d5,sq+480
	move.b %d3,sq+481
	move.b %d2,sq+482
	move.b %d1,sq+483
	move.l %d0,sq+472
	mov3q.l #1,sq+476
.L1841:
	clr.l %d2
	clr.l %d0
	lea sq+480,%a0
.L1843:
	mvz.b (%a0,%d0.l),%d3
	moveq #111,%d6
	cmp.l %d3,%d6
	jcs .L1842
	mov3q.l #1,%d3
	lsl.l %d0,%d3
	or.l %d3,%d2
.L1842:
	addq.l #1,%d0
	mov3q.l #4,%d7
	cmp.l %d0,%d7
	jne .L1843
.L1840:
	cmp.l %d4,%d2
	jne .L1844
	tst.l sq+476
	jeq .L1845
.L1844:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L2055
	addq.l #1,st+1018
.L1845:
	tst.l st+4
	jeq .L2056
	tst.l st+1058
	seq %d2
	mvs.b %d2,%d2
	neg.l %d2
.L1853:
	move.l st+8,%d0
	moveq #10,%d7
	divu.l %d7,%d0
	btst #0,%d0
	jeq .L2057
	clr.b %d3
.L1854:
	mvz.b k44+24,%d0
	cmp.l %d2,%d0
	jne .L1855
	tst.l %d2
	jeq .L1856
	mvz.b k44+25,%d1
	mvz.b %d3,%d0
	cmp.l %d1,%d0
	jeq .L1856
.L1855:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1857
	addq.l #1,st+1018
.L1856:
	lea ms,%a3
	tst.l (%a3)
	jeq .L1860
	tst.l ms+4
	jne .L1861
.L1860:
	clr.l %d2
.L1862:
	cmp.l ms+212.l,%d2
	jeq .L1863
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1864
	addq.l #1,st+1018
.L1863:
	move.l ms+160,%d1
	cmp.l ms+184.l,%d1
	jeq .L1867
	btst #0,%d1
	jne .L1867
	clr.l %d0
	lea (-140,%fp),%a0
.L1868:
	lea (%a3,%d0.l),%a1
	moveq #20,%d2
	lea (164,%a1),%a1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d2
	jne .L1868
	cmp.l ms+160.l,%d1
	jne .L1867
	clr.b %d3
	move.l %a0,-(%sp)
	move.l %d1,ms+184
	move.b %d3,-121(%fp)
	jsr ms_say
	addq.l #4,%sp
.L1867:
	move.l ms+188,%d0
	tst.l %d0
	jeq .L1870
	sub.l st+8,%d0
	tst.l %d0
	jgt .L1871
	clr.l ms+188
.L1871:
	moveq #1,%d4
	move.b %d4,32(%a2)
.L1870:
	tst.l ms+8
	jeq .L1872
	move.l st+8,%d0
	mov3q.l #5,%d5
	sub.l ms+12,%d0
	cmp.l %d0,%d5
	jcc .L1872
	clr.l ms+8
	jsr ms_stock_ok
	tst.l %d0
	jeq .L1873
	pea ms+28
	moveq #16,%d6
	move.l ms+24,-(%sp)
	or.l %d6,st+216
	addq.l #1,ms+224
	jsr 1074397898
	addq.l #8,%sp
.L1872:
	jsr ms_acc_out
	jsr ms_send
	jsr flush
	move.b pc+79,%d2
	move.l pc_seq,%d1
	lea pc,%a2
	tst.b %d2
	jne .L1874
	btst #0,%d1
	jne .L1875
	cmp.l pc+72.l,%d1
	jeq .L1875
	clr.l %d0
	lea pc_req,%a0
	lea (-140,%fp),%a3
.L1876:
	lea (%a0,%d0.l),%a1
	mov3q.l #6,%d3
	move.b (%a1),(%a3,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d3
	jne .L1876
	cmp.l pc_seq.l,%d1
	jne .L1875
	move.b -140(%fp),%d3
	move.w pc+82,%d0
	moveq #127,%d5
	move.l %d1,pc+72
	moveq #11,%d6
	mvz.b %d3,%d4
	addq.l #1,%d0
	move.w %d0,pc+82
	move.b %d5,pc+77
	cmp.l %d4,%d6
	jlt .L1878
	jsr 1075320104
	move.l %d0,-(%sp)
	jsr 1073963888
	addq.l #4,%sp
	tst.l %d0
	jne .L1879
.L1878:
	moveq #3,%d2
.L1880:
	move.b %d2,pc+78
	mvz.b %d2,%d2
	move.b %d3,pc+76
	add.l #42,%d2
	move.w (%a2,%d2.l*2),%d0
	addq.l #1,%d0
	move.w %d0,(%a2,%d2.l*2)
	moveq #1,%d0
	move.b %d0,pc+79
.L1874:
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
	jeq .L1875
	move.w pc+92,%d0
	clr.b %d1
	addq.l #1,%d0
	move.b %d1,pc+79
	move.w %d0,pc+92
.L1875:
	move.b st+992,%d0
	move.b st+161,%d1
	or.l %d1,%d0
	tst.b %d0
	jne .L1895
	jsr mr_tick
	tst.l %d0
	jeq .L1895
	tst.b sv+4.l
	jeq .L1896
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
	jeq .L1898
	clr.b %d0
	addq.l #1,sv+64
	move.b %d0,sv+4
.L1896:
	tst.b sv+102.l
	jeq .L1899
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
	jcc .L1900
	moveq #127,%d0
.L1900:
	move.b %d0,-159(%fp)
	clr.l %d0
	lea (-140,%fp),%a0
	lea (-172,%fp),%a1
.L1901:
	lea (%a1,%d0.l),%a2
	moveq #14,%d1
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1901
	moveq #-9,%d3
	pea 15.w
	move.l %a0,-(%sp)
	move.b %d3,-126(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1898
	clr.b %d4
	lea sv+100,%a0
	move.b (%a0),sv+101
	lea st+8,%a1
	move.l %d2,sv+104
	move.l (%a1),sv+108
	addq.l #1,sv+112
	move.b %d4,sv+102
.L1899:
	tst.b sv.l
	jeq .L1898
	mvz.b sv+1,%d0
	not.l %d0
	move.l %d0,-(%sp)
	jsr cu_steps
	addq.l #4,%sp
	tst.l %d0
	jne .L1898
	move.l sv+120,%a2
	cmp.l sv+116.l,%a2
	jeq .L1903
	moveq #1,%d0
	move.b %d0,sv+7
.L1903:
	lea (-172,%fp),%a3
	clr.l %d3
	lea sv,%a4
	mov3q.l #-1,%d2
	move.l %a3,%a2
.L1908:
	mvz.b sv+1,%d0
	move.l sv+116,-(%sp)
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	jsr sv_word
	lea (12,%sp),%sp
	move.b sv+7,%d4
	move.w %d0,(%a3)
	tst.b %d4
	jne .L1904
	mvz.w %d0,%d1
	mvz.w 24(%a4),%d6
	cmp.l %d1,%d6
	jeq .L1905
.L1904:
	cmp.l -184(%fp),%d3
	jge .L1906
	move.l %d3,-184(%fp)
.L1906:
	move.l %d3,%d2
.L1905:
	mov3q.l #7,%d1
	cmp.l %d3,%d1
	jge .L1907
	tst.w %d0
	jeq .L1907
	mvz.b sv+1,%d0
	move.l %d0,-(%sp)
	jsr cu_mi_settling
	addq.l #4,%sp
	tst.l %d0
	jne .L1898
.L1907:
	addq.l #2,%a3
	addq.l #1,%d3
	addq.l #2,%a4
	moveq #16,%d0
	cmp.l %d3,%d0
	jne .L1908
	tst.b %d4
	jne .L2059
	mov3q.l #-1,%d1
	cmp.l %d2,%d1
	jne .L1909
.L1898:
	jsr arp_tick
.L1895:
	tst.l st
	jne .L1766
.L1919:
	mvz.b cu+9,%d2
	tst.l %d2
	jeq .L1949
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
	jeq .L1950
	move.l st+8,%d0
	mov3q.l #4,%d4
	sub.l cu+16,%d0
	cmp.l %d0,%d4
	jcc .L1949
.L1954:
	clr.b %d5
	move.b %d5,cu+9
.L1949:
	tst.l st
	jeq .L1955
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L1956
	tst.l st+968
	jeq .L1956
	move.l dp,%d0
	move.b 1093765506,%d2
	tst.l %d0
	jeq .L1957
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
	jeq .L1959
	clr.l dp
.L1957:
	tst.b k44+20.l
	jeq .L1960
	move.l k44+20,%d0
	and.l #16776960,%d0
	tst.l %d0
	jne .L1960
	tst.l st+4
	jeq .L1961
	tst.l st+1058
	jne .L1960
.L1961:
	move.l st+8,%d0
	sub.l k44,%d0
	lsr.l #3,%d0
	jeq .L1960
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	or.l ov_list,%d0
	jne .L1960
	tst.l st+4
	sne %d0
	move.w #257,%d7
	neg.l %d0
	move.b %d0,k44+26
	move.w %d7,k44+22
.L1960:
	move.b k44+23,%d0
	jeq .L1962
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
	jeq .L1959
	mvz.b k44+23,%d0
	tst.b k44+26.l
	jeq .L1965
	mov3q.l #1,%d4
	cmp.l %d0,%d4
	jne .L1966
	addq.l #1,k44+28
.L1967:
	clr.b %d0
	move.b %d0,k44+23
.L1962:
	mvz.b %d2,%d1
	moveq #11,%d3
	cmp.l %d1,%d3
	jcs .L1959
	move.b %d2,%d4
	moveq #127,%d0
	and.l -2147457096,%d0
	ext.w %d4
	mulu.w #2531,%d0
	mulu.w #152,%d4
	move.l %d4,%a0
	add.l %d0,%a0
	add.l #1092966773,%a0
	move.b (%a0),%d3
	move.l st+968,%d0
	move.l %d4,-180(%fp)
	mvz.b %d3,%d5
	cmp.l dp+8.l,%d0
	jeq .L1970
	clr.b %d4
	move.l %d0,dp+8
	move.b %d4,dp+22
.L1971:
	moveq #52,%d6
	cmp.l %d5,%d6
	jcs .L2062
	move.b %d3,%d0
	move.l #1075572644,%a0
	ext.w %d0
	mvz.w %d0,%d0
	lsl.l #3,%d0
	move.l (%a0,%d0.l),%a0
.L1973:
	moveq #2,%d0
	move.w #18689,%a1
	move.l #-260222380,%d7
	move.b %d2,-133(%fp)
	move.l %d7,-140(%fp)
	move.b %d0,-134(%fp)
	moveq #127,%d0
	and.l %d3,%d0
	move.w %a1,-136(%fp)
	move.b %d0,-132(%fp)
	tst.l %a0
	jeq .L2063
	move.l %a0,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	sls %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1974:
	clr.l %d1
	lea (-140,%fp),%a1
.L1976:
	tst.l %d0
	jeq .L2342
	move.b (%a0,%d1.l),%d6
	move.l %d6,%d7
	subq.l #1,%d7
	mvz.b %d7,%d4
	moveq #125,%d7
	cmp.l %d4,%d7
	jcs .L2065
.L1975:
	move.b %d6,9(%a1,%d1.l)
	addq.l #1,%d1
	moveq #12,%d4
	cmp.l %d1,%d4
	jne .L1976
	moveq #-9,%d6
	pea 22.w
	move.l %a1,-(%sp)
	move.b %d6,-119(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1959
	move.w #257,%d7
	move.b %d2,dp+20
	move.b %d3,dp+21
	addq.l #1,dp+12
	move.w %d7,dp+22
	jra .L1972
.L1836:
	jsr led_stock
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.l led_again
.L2339:
	addq.l #4,%sp
	jra .L1835
.L2055:
	clr.l %d0
	lea sq+480,%a0
	lea ovp_col,%a1
.L1846:
	btst %d0,%d2
	jeq .L1847
	lea (%a0,%d0.l),%a3
	move.b (%a3),(%a1,%d0.l)
.L1847:
	addq.l #1,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L1846
	move.b %d2,ovp_on
	or.l %d2,%d4
	move.l %fp,%d5
	clr.l %d3
	lea shp,%a3
	add.l #-140,%d5
	lea sq+480,%a4
	lea rui_uart_raw,%a5
.L1852:
	btst %d3,%d4
	jeq .L1848
	moveq #-76,%d6
	moveq #43,%d0
	mov3q.l #1,%d7
	sub.l %d3,%d0
	move.b %d0,-139(%fp)
	move.l %d2,%d0
	lsr.l %d3,%d0
	sub.l %a0,%a0
	and.l %d7,%d0
	move.b %d6,-140(%fp)
.L1851:
	tst.l %d0
	jeq .L1849
	move.b (%a4,%d3.l),%d1
.L1850:
	move.b %d1,2(%a0,%d5.l)
	addq.l #1,%a0
	mov3q.l #4,%d1
	cmp.l %a0,%d1
	jne .L1851
	move.l %d5,-(%sp)
	mov3q.l #6,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
.L1848:
	addq.l #1,%d3
	addq.l #4,%a3
	mov3q.l #4,%d6
	cmp.l %d3,%d6
	jne .L1852
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.l sq+476
	addq.l #4,%sp
	jra .L1845
.L1849:
	move.b (%a3,%a0.l),%d1
	jra .L1850
.L2056:
	clr.l %d2
	jra .L1853
.L2057:
	moveq #111,%d3
	jra .L1854
.L1857:
	move.b %d3,ovt_col
	move.b %d2,%d4
	move.b %d2,ovt_on
	lea led_send4,%a0
	tst.l %d2
	jeq .L1858
	move.b %d3,-137(%fp)
	move.b %d3,-138(%fp)
	move.b %d3,-139(%fp)
	move.b %d3,-140(%fp)
	pea -140(%fp)
	pea 55.w
	jsr (%a0)
	addq.l #1,k44+12
.L2340:
	addq.l #4,%sp
	move.l #1100088672,(%sp)
	jsr 1073746414
	addq.l #4,%sp
	move.b %d4,k44+24
	move.b %d3,k44+25
	jra .L1856
.L1858:
	pea sht
	pea 55.w
	jsr (%a0)
	addq.l #1,k44+16
	jra .L2340
.L1861:
	tst.l st+4
	jne .L1860
	tst.b ov_on.l
	seq %d2
	mvs.b %d2,%d2
	neg.l %d2
	jra .L1862
.L1864:
	tst.l %d2
	jeq .L1865
	moveq #47,%d0
	moveq #60,%d1
	moveq #3,%d3
	move.l #791621423,%d4
	lea led_send4,%a4
	move.l %d4,-140(%fp)
	move.l #1010580540,%d5
	move.b %d0,ovm_col
	move.b %d1,ovm_col+1
	move.b %d3,ovm_on
	move.l %fp,%d3
	add.l #-140,%d3
	move.l %d3,-(%sp)
	pea 14.w
	jsr (%a4)
	move.l %d3,-(%sp)
	pea 15.w
	move.l %d5,-140(%fp)
	jsr (%a4)
	lea (16,%sp),%sp
.L1866:
	move.l #1100088672,-(%sp)
	jsr 1073746414
	move.l %d2,ms+212
	addq.l #4,%sp
	jra .L1863
.L1865:
	clr.b %d6
	move.b %d6,ovm_on
	tst.b ov_on.l
	jne .L1866
	pea sh+56
	pea 14.w
	lea led_send4,%a4
	jsr (%a4)
	pea sh+60
	pea 15.w
	jsr (%a4)
	move.b shs+3,%d0
	lea (16,%sp),%sp
	mvz.b %d0,%d1
	cmp.l #255,%d1
	jeq .L1866
	moveq #35,%d7
	pea -140(%fp)
	mov3q.l #2,-(%sp)
	move.b %d0,-139(%fp)
	move.b %d7,-140(%fp)
	jsr rui_uart_raw
	addq.l #8,%sp
	jra .L1866
.L1873:
	moveq #16,%d7
	or.l %d7,st+280
	jra .L1872
.L1879:
	move.b %d3,%d6
	moveq #127,%d0
	moveq #127,%d7
	and.l -2147457096,%d0
	ext.w %d6
	mulu.w #2531,%d0
	move.w %d6,%d5
	move.l %d0,%a0
	mulu.w #152,%d5
	add.l %d5,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d0
	move.l %d0,-(%sp)
	move.l %d4,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	mvz.b %d0,%d0
	cmp.l %d0,%d7
	jeq .L1878
	moveq #127,%d0
	moveq #46,%d1
	and.l -2147457096,%d0
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d5,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d0
	cmp.l %d0,%d1
	jeq .L1878
	tst.b 60(%a2,%d4.l)
	jeq .L1881
	move.l st+8,%d0
	moveq #20,%d5
	sub.l (%a2,%d4.l*4),%d0
	cmp.l %d0,%d5
	jcc .L1882
.L1881:
	moveq #1,%d2
	jra .L1880
.L1882:
	lea 48(%a2,%d4.l),%a0
	move.b (%a0),77(%a2)
	jsr 1075312702
	move.l %d0,-(%sp)
	jsr 1074458688
	move.l %d4,-(%sp)
	move.l %d0,-(%sp)
	jsr 1074442802
	lea (12,%sp),%sp
	move.l %d0,%a4
	move.l 44(%a4),%a5
	tst.l %a5
	jeq .L1878
	move.l (%a5),%a0
	move.l %a5,-(%sp)
	move.l 40(%a0),%a0
	jsr (%a0)
	move.l 32(%a5),%d4
	addq.l #4,%sp
	move.l %d0,-180(%fp)
	tst.l %d4
	jeq .L1883
	move.l %d4,%d5
	move.l %d4,%a0
	add.l #4752,%d5
	clr.l %d1
.L1887:
	mvz.b (%a0),%d7
	cmp.l #255,%d7
	jeq .L1885
	mvz.b 1(%a0),%d7
	cmp.l #255,%d7
	jeq .L1885
	addq.l #1,%d1
.L1885:
	lea (66,%a0),%a0
	cmp.l %d5,%a0
	jne .L1887
	mulu.w #5674,%d6
	mvz.b %d3,%d0
	move.l -180(%fp),%a5
	move.l #1075599904,%a1
	add.l %d6,%a5
.L1892:
	mvz.b 3(%a1),%d6
	move.l %d4,%a0
.L1890:
	mvz.b (%a0),%d7
	cmp.l %d7,%d6
	jne .L1888
	mvz.b 1(%a0),%d7
	cmp.l %d0,%d7
	jeq .L1889
.L1888:
	lea (66,%a0),%a0
	cmp.l %d5,%a0
	jne .L1890
	tst.b 5653(%a5)
	jne .L2051
	mov3q.l #1,%a0
	jra .L2052
.L2051:
	mov3q.l #2,%a0
.L2052:
	add.l %a0,%d1
	moveq #71,%d6
	cmp.l %d1,%d6
	jlt .L2058
.L1889:
	addq.l #4,%a1
	addq.l #1,%a5
	cmp.l #1075599920,%a1
	jne .L1892
.L1883:
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
.L1893:
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
	jne .L1893
	jra .L1880
.L2058:
	moveq #2,%d2
	jra .L1880
.L2059:
	clr.l -184(%fp)
	moveq #15,%d2
.L1909:
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
.L1910:
	cmp.l %d2,%d0
	jle .L1911
	cmp.l -184(%fp),%d1
	sge %d1
	move.l %d1,%d0
	neg.l %d0
	tst.b %d0
	jeq .L1912
	move.l %d2,%d0
	sub.l -184(%fp),%d0
	add.l %d0,%d0
	add.l #11,%d0
.L1913:
	moveq #-9,%d6
	lea (%fp,%d0.l),%a1
	neg.l %d1
	move.b %d6,-140(%a1)
	tst.b %d1
	jeq .L1914
	move.l %d2,%d0
	addq.l #6,%d0
	sub.l -184(%fp),%d0
	add.l %d0,%d0
.L1915:
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1898
	lea sv+24,%a0
.L1916:
	cmp.l -184(%fp),%d2
	jge .L1917
	clr.b %d2
	move.l sv+116,%d0
	addq.l #1,sv+68
	move.b %d2,sv+7
	tst.l %d0
	jlt .L1918
	addq.l #1,sv+124
.L1918:
	move.l %d0,sv+120
	jra .L1898
.L1911:
	move.w (%a2,%d0.l*2),%d3
	moveq #127,%d5
	addq.l #1,%d0
	addq.l #2,%a1
	move.l %d3,%d4
	lsr.l #7,%d4
	and.l %d5,%d3
	move.b %d4,-2(%a1)
	move.b %d3,-1(%a1)
	jra .L1910
.L1912:
	moveq #9,%d0
	jra .L1913
.L1914:
	moveq #10,%d0
	jra .L1915
.L1917:
	move.l -184(%fp),%d1
	lea (%a2,%d1.l*2),%a3
	move.w (%a3),(%a0,%d1.l*2)
	addq.l #1,%d1
	move.l %d1,-184(%fp)
	jra .L1916
.L1923:
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
	jeq .L1919
	move.l ux+3944,%d1
	mov3q.l #1,%d0
	lea ux+3920,%a0
.L1920:
	cmp.l %d0,%d1
	jhi .L1921
	subq.l #1,%d1
	move.l %d1,ux+3944
	addq.l #1,ux+32
.L1922:
	tst.l ux+3944
	jne .L1923
.L1924:
	move.l ux+3880,%d2
	cmp.l ux+3884.l,%d2
	jeq .L1919
	mov3q.l #7,%d3
	cmp.l ux+3944.l,%d3
	jcs .L1919
	mov3q.l #7,%d0
	and.l ux+3884,%d0
	lsl.l #2,%d0
	move.l %d0,%a2
	add.l #ux+3888,%a2
	move.b 1(%a2),%d7
	moveq #127,%d0
	and.l -2147457096,%d0
	move.b (%a2),%d3
	mvz.b %d7,%d4
	mulu.w #2531,%d0
	move.w %d3,%a3
	move.l %d4,%a1
	move.l %a1,%d5
	mvz.b %d3,%d4
	add.l #9,%d5
	move.l %d0,%a0
	add.l #1092966773,%a0
	move.w %d4,%d0
	mulu.w #152,%d0
	move.b (%a0,%d0.l),%d0
	mvz.b %d0,%d2
	move.w %d0,%a4
	move.l %d2,-(%sp)
	move.l %d5,-(%sp)
	move.l %a1,-188(%fp)
	jsr 1073770536
	addq.l #8,%sp
	move.l ux+3884,%a0
	move.l -188(%fp),%a1
	move.l %d0,%a5
	tst.l %d0
	jle .L2060
	mvz.b 2(%a2),%d3
	mvz.b 3(%a2),%d0
	lsl.l #8,%d3
	add.l %d0,%d0
	or.l %d0,%d3
	mov3q.l #7,%d0
	cmp.l %a1,%d0
	jlt .L1926
	move.l %a4,%d0
	add.l #-46,%d0
	mvz.b %d0,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jcc .L1927
	moveq #52,%d0
	cmp.l %d2,%d0
	jne .L1928
.L1927:
	cmp.l 1075595760.l,%d2
	jne .L1929
.L1928:
	tst.l %a1
	jne .L1931
.L1932:
	move.l %a0,%d1
	mov3q.l #7,%d2
	and.l %d2,%d1
	move.l %d6,%a0
	add.l %d1,%a0
	move.b 3952(%a0),%d0
	btst #0,%d0
	jeq .L1931
	move.l ls+64,%d0
	or.l ls+68,%d0
	jeq .L1931
	cmp.l ls+72.l,%d4
	jne .L1931
	move.l st+8,%d0
	moveq #20,%d1
	sub.l ls+76,%d0
	cmp.l %d0,%d1
	jcs .L1931
	move.l #1075599820,%a0
	move.l (%a0,%d5.l*4),%d2
	jsr 1075312702
	move.l %d0,-(%sp)
	jsr 1074458688
	move.l %d4,-(%sp)
	move.l %d0,-(%sp)
	jsr 1074442802
	lea (12,%sp),%sp
	move.l %d0,%a2
	move.l 44(%a2),%a4
	tst.l %a4
	jeq .L1931
	move.l (%a4),%a0
	move.l %a4,-(%sp)
	move.l 40(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l 32(%a4),%d0
	tst.l %d0
	jeq .L1934
	mvz.b %d2,%d2
	move.l %d0,%a0
	add.l #4753,%d0
	addq.l #1,%a0
	move.l %d0,-180(%fp)
	sub.l %a4,%a4
	sub.l %a1,%a1
.L1939:
	mvz.b -1(%a0),%d1
	cmp.l #255,%d1
	jeq .L1936
	mvz.b (%a0),%d0
	cmp.l #255,%d0
	jeq .L1936
	addq.l #1,%a1
.L1936:
	cmp.l %d1,%d2
	jne .L1938
	mvz.b (%a0),%d1
	move.l %a4,%d0
	cmp.l %d1,%d4
	seq %d1
	mvs.b %d1,%d1
	neg.l %d1
	or.l %d1,%d0
	move.l %d0,%a4
.L1938:
	lea (66,%a0),%a0
	cmp.l -180(%fp),%a0
	jne .L1939
	tst.l %a4
	jne .L1934
	moveq #69,%d1
	cmp.l %a1,%d1
	jlt .L1940
.L1934:
	move.l %a2,-(%sp)
	moveq #64,%d2
	jsr 1074529464
	addq.l #4,%sp
	move.l %d0,%d4
	cmp.l %d0,%d2
	jge .L1941
	moveq #64,%d4
.L1941:
	clr.l %d2
.L1942:
	cmp.l %d4,%d2
	jlt .L1946
	moveq #4,%d0
	clr.l ls+68
	clr.l ls+64
	addq.l #1,ux+3960
.L1947:
	move.l ux+3944,%a0
	lea (%a0,%a0.l*2),%a1
	move.w %a3,%d1
	addq.l #1,%a0
	move.l %a0,ux+3944
	addq.l #1,ux+3884
	add.l %d6,%a1
	move.b %d1,3920(%a1)
	move.b %d7,3921(%a1)
	move.b %d0,3922(%a1)
	jra .L1924
.L1921:
	addq.l #3,%a0
	move.b (%a0),-3(%a0)
	move.b 1(%a0),-2(%a0)
	move.b 2(%a0),-1(%a0)
	addq.l #1,%d0
	jra .L1920
.L1926:
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-48,%d0
	cmp.l %d0,%d1
	jcs .L1930
	mvz.b cu+1,%d0
	cmp.l %d2,%d0
	jne .L1929
.L1931:
	move.l %d5,-(%sp)
	move.l %d4,-(%sp)
	move.l %d3,-(%sp)
	jsr 1074918394
	jsr 1075398168
	move.l %d3,-(%sp)
	move.l %a5,-(%sp)
	move.l %d4,-(%sp)
	move.l %d0,-(%sp)
	jsr 1073952092
	lea (28,%sp),%sp
	clr.b %d0
	addq.l #1,ux+20
	jra .L1947
.L1930:
	moveq #10,%d0
	cmp.l %a1,%d0
	jne .L1933
	moveq #45,%d1
	cmp.l %d2,%d1
	jeq .L1932
	moveq #43,%d0
.L2341:
	cmp.l %d2,%d0
	jeq .L1932
	jra .L1931
.L1933:
	moveq #12,%d1
	cmp.l %a1,%d1
	jne .L1931
	moveq #46,%d0
	jra .L2341
.L1946:
	moveq #31,%d0
	cmp.l %d2,%d0
	jlt .L1943
	move.l ls+64,%d1
	lsr.l %d2,%d1
.L1944:
	btst #0,%d1
	jeq .L1945
	mov3q.l #1,-(%sp)
	move.l %d3,-(%sp)
	move.l %d5,-(%sp)
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr 1074529568
	lea (20,%sp),%sp
	addq.l #1,ls+100
.L1945:
	addq.l #1,%d2
	jra .L1942
.L1943:
	move.l %d2,%d0
	add.l #-32,%d0
	move.l ls+68,%d1
	lsr.l %d0,%d1
	jra .L1944
.L1940:
	moveq #3,%d0
	addq.l #1,ux+3964
.L1925:
	addq.l #1,ux+24
	jra .L1947
.L1929:
	moveq #1,%d0
	jra .L1925
.L2060:
	moveq #2,%d0
	jra .L1925
.L1950:
	move.l #1075731444,%d7
	cmp.l sv+88.l,%d7
	jeq .L1949
	move.l st+8,%d0
	sub.l cu+16,%d0
	lsr.l #1,%d0
	jeq .L1949
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	move.l %d0,%a2
	tst.l %d0
	jeq .L1949
	move.l %d2,-(%sp)
	moveq #8,%d3
	jsr cu_setup
	lea (11,%a2),%a2
	addq.l #4,%sp
.L1953:
	move.l %d3,%a3
	move.l %d2,-(%sp)
	lea (9,%a3),%a3
	move.l %a3,-(%sp)
	jsr 1073770536
	addq.l #8,%sp
	move.l %d0,%d5
	tst.l %d0
	jle .L1951
	moveq #43,%d7
	cmp.l %d2,%d7
	jne .L1952
	moveq #10,%d0
	cmp.l %d3,%d0
	jne .L1952
	mvz.b cu+29,%d0
	moveq #45,%d1
	cmp.l %d0,%d1
	jeq .L1951
	cmp.l %d0,%d7
	jeq .L1951
.L1952:
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
.L1951:
	addq.l #1,%d3
	lea (16,%a2),%a2
	moveq #16,%d5
	cmp.l %d3,%d5
	jne .L1953
	addq.l #1,cu+20
	moveq #50,%d6
	cmp.l %d2,%d6
	jne .L1954
	addq.l #1,%d4
	lea st+8,%a0
	move.b %d4,cu+11
	move.l (%a0),cu+24
	jra .L1954
.L1966:
	addq.l #1,k44+32
.L1968:
	subq.l #2,%d0
	tst.l %d0
	jne .L1967
	clr.b %d7
	move.b %d7,k44+26
	jra .L1967
.L1965:
	mov3q.l #1,%d5
	cmp.l %d0,%d5
	jne .L1969
	addq.l #1,k44+4
	jra .L1967
.L1969:
	addq.l #1,k44+8
	jra .L1968
.L1970:
	tst.b dp+22.l
	jeq .L1971
	mvz.b dp+20,%d0
	cmp.l %d1,%d0
	jne .L1971
	mvz.b dp+21,%d0
	cmp.l %d5,%d0
	jne .L1971
.L1972:
	lea dp,%a4
	sub.l %a3,%a3
	lea dp+32,%a2
	move.l %a4,%a5
.L1984:
	moveq #43,%d0
	cmp.l %d5,%d0
	jeq .L2066
	moveq #127,%d0
	moveq #127,%d1
	and.l -2147457096,%d0
	move.l -180(%fp),%a0
	mulu.w #2531,%d0
	add.l %d0,%a0
	mvz.w %a3,%d0
	add.l #1092966707,%a0
	move.b (%a0,%d0.l*2),%d3
	and.l %d1,%d3
.L1977:
	move.l %d5,-(%sp)
	pea 9(%a3)
	jsr 1073770536
	addq.l #8,%sp
	tst.l %d0
	jgt .L1978
	clr.l -172(%fp)
.L1979:
	mvz.b 24(%a5),%d4
	move.b -172(%fp),%d7
	move.b -171(%fp),%d6
	move.l %d4,%a1
	mvz.b %d3,%d4
	move.b -170(%fp),%d1
	move.b -169(%fp),%d0
	cmp.l %a1,%d4
	jne .L1982
	mvs.b (%a2),%d4
	move.l %d4,%a1
	mvs.b %d7,%d4
	cmp.l %a1,%d4
	jne .L1982
	mvs.b 1(%a2),%d4
	move.l %d4,%a1
	mvs.b %d6,%d4
	cmp.l %a1,%d4
	jne .L1982
	mvs.b 2(%a2),%d4
	move.l %d4,%a1
	mvs.b %d1,%d4
	cmp.l %a1,%d4
	jne .L1982
	mvs.b 3(%a2),%d4
	move.l %d4,%a1
	mvs.b %d0,%d4
	cmp.l %a1,%d4
	jeq .L1983
.L1982:
	move.b %d3,24(%a5)
	move.b %d6,1(%a2)
	moveq #1,%d6
	move.b %d7,(%a2)
	move.b %d1,2(%a2)
	move.b %d0,3(%a2)
	move.b %d6,dp+23
.L1983:
	addq.l #1,%a3
	addq.l #4,%a2
	addq.l #1,%a5
	moveq #8,%d7
	cmp.l %a3,%d7
	jne .L1984
	tst.b dp+23.l
	jeq .L1959
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
.L1986:
	move.b (%a2)+,(%a1)
	mov3q.l #1,%a0
.L1985:
	lea 31(%a4,%a0.l),%a3
	mov3q.l #5,%d2
	move.b (%a3),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d2
	jne .L1985
	addq.l #5,%a1
	addq.l #5,%d0
	addq.l #4,%a4
	moveq #49,%d3
	cmp.l %d0,%d3
	jne .L1986
	moveq #-9,%d4
	pea 49.w
	move.l %d1,-(%sp)
	move.b %d4,-92(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1959
	clr.b %d5
	addq.l #1,dp+16
	move.b %d5,dp+23
.L1959:
	tst.l st
	jeq .L1955
.L1956:
	mov3q.l #1,%d6
	cmp.l 1094562388.l,%d6
	jne .L1955
	tst.l st+968
	jeq .L1955
	move.b 1079807565,%d2
	mvs.b %d2,%d0
	lsr.l #7,%d0
	jne .L2068
	addq.l #1,%d2
.L1987:
	move.l pj+160,%d0
	cmp.l pj+156.l,%d0
	jeq .L1991
	move.l pj+156,%d3
	sub.l %d0,%d3
	clr.l -(%sp)
	move.l %d3,%d0
	cmp.l #16383,%d3
	jls .L1989
	mvz.w #16383,%d0
.L1989:
	move.l %d0,-(%sp)
	mov3q.l #6,-(%sp)
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L2021
	moveq #2,%d0
	add.l %d3,pj+160
	move.w %d0,pj+180
.L1991:
	move.l pj,%d1
	cmp.l pj+4.l,%d1
	jne .L1992
	tst.b pj+139.l
	jeq .L1993
	mvz.b pj+138,%d1
	mvz.b %d2,%d0
	cmp.l %d1,%d0
	jeq .L1994
.L1993:
	clr.l %d0
.L1995:
	move.l #1081903571,%a0
	lea pj-1081903431,%a1
.L1996:
	tst.l %d0
	jne .L1998
.L1999:
	move.l st+968,%d6
	cmp.l pj+164.l,%d6
	jeq .L2016
	moveq #2,%d7
	move.w %d7,pj+180
.L2016:
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
.L2017:
	move.l #1081903571,%a2
	add.l %a0,%a2
	tst.b (%a2)
	jeq .L2018
	move.b (%a2),%d0
	moveq #127,%d1
	moveq #15,%d3
	and.l %d1,%d0
	move.b %d0,9(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d3
	jne .L2017
.L2018:
	moveq #-9,%d4
	lea (%fp,%a0.l),%a2
	move.b %d4,-131(%a2)
	pea 10(%a0)
	move.l %a1,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L2021
	moveq #1,%d5
	move.b %d2,pj+138
	lea st+968,%a0
	lea st+8,%a1
	move.l (%a0),pj+164
	move.l (%a1),pj+168
	move.l #1081903571,%a0
	lea pj-1081903431,%a1
	move.b %d5,pj+139
.L2020:
	move.b (%a0),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L2020
	addq.l #1,pj+176
	jra .L2021
.L2062:
	sub.l %a0,%a0
	jra .L1973
.L2063:
	clr.l %d0
	jra .L1974
.L2065:
	clr.l %d0
.L2342:
	clr.b %d6
	jra .L1975
.L2066:
	clr.b %d3
	jra .L1977
.L1978:
	moveq #52,%d4
	muls.l %d4,%d0
	move.l #1075575112,%a0
	move.l (%a0,%d0.l),%d4
	clr.l -172(%fp)
	move.l %d4,%d0
	sub.l %a0,%a0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L1979
.L1980:
	moveq #125,%d6
	move.b (%a0,%d4.l),%d1
	move.l %d1,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d6
	jcs .L1979
	lea (-172,%a0),%a1
	mov3q.l #4,%d0
	move.b %d1,(%a1,%fp.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L1980
	jra .L1979
.L2068:
	clr.b %d2
	jra .L1987
.L1992:
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
	jeq .L2021
	addq.l #1,pj+4
	addq.l #1,pj+172
	jra .L1991
.L1994:
	move.l st+968,%d3
	cmp.l pj+164.l,%d3
	jne .L1993
	move.l st+8,%d0
	moveq #99,%d4
	sub.l pj+168,%d0
	cmp.l %d0,%d4
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L1995
.L1998:
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
	jne .L1996
	mvz.b %d3,%d3
	mvz.b %d1,%d1
	cmp.l %d3,%d1
	jne .L1999
	tst.b pj+181.l
	jeq .L2021
	move.l 1100949640,%d0
	mov3q.l #3,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L2000
	move.l %d0,%d1
	add.l #-1073741824,%d1
	cmp.l #129892351,%d1
	jhi .L2000
	move.l %d0,%a0
	add.l #1073744908,%d1
	lea (12,%a0),%a0
	move.l %a0,%a1
.L2003:
	mvz.b (%a1),%d0
	lsr.l #1,%d0
	jeq .L2001
.L2000:
	mvz.w #16383,%d0
	clr.l %d3
.L2002:
	clr.l -(%sp)
	move.l %d0,-(%sp)
	pea 9.w
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L2021
	addq.l #1,pj+184
	tst.l %d3
	jeq .L2007
	move.b pj+181,%d0
	mvz.b %d0,%d1
	lsr.l #1,%d1
	jeq .L2007
	clr.b %d7
	subq.l #1,%d0
	move.b %d0,pj+181
	move.b %d7,pj+180
.L2021:
	tst.l st
	jeq .L2025
	mov3q.l #1,%d3
	cmp.l 1094562388.l,%d3
	jne .L2026
	tst.l st+968
	jeq .L2026
	move.l st+44,%d1
	move.l txsx_over,%d0
	cmp.l kd_drop.l,%d1
	jne .L2027
	cmp.l kd_over.l,%d0
	jeq .L2028
.L2027:
	move.l st+8,%a0
	moveq #19,%d4
	sub.l kd_t,%a0
	cmp.l %a0,%d4
	jcc .L2028
	cmp.l #16383,%d1
	jls .L2029
	mvz.w #16383,%d1
.L2029:
	cmp.l #16383,%d0
	jls .L2030
	mvz.w #16383,%d0
.L2030:
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
	jeq .L2028
	lea st+44,%a0
	lea txsx_over,%a1
	lea st+8,%a2
	move.l (%a0),kd_drop
	move.l (%a1),kd_over
	move.l (%a2),kd_t
.L2028:
	tst.l st
	jeq .L2025
.L2026:
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L2031
	tst.l st+968
	jeq .L2031
	jsr 1075312702
	move.l %d0,%d2
	add.l #352,%d2
	move.l %d2,-(%sp)
	move.l %d0,%a3
	jsr 1074425250
	addq.l #4,%sp
	tst.l qp+100
	jeq .L2032
	cmp.l #4095,%d0
	jle .L2033
	mvz.w #4095,%d0
.L2034:
	move.l 352(%a3),%a0
	lea qp,%a2
	move.l %d0,(%a2)
	move.l %d2,-(%sp)
	move.l 52(%a0),%a0
	mov3q.l #1,qp+4
	jsr (%a0)
	addq.l #4,%sp
	tst.l %d0
	jeq .L2035
	move.l %d0,%a0
	moveq #11,%d0
	mvz.b 2430(%a0),%d2
	cmp.l %d2,%d0
	jcc .L2036
.L2035:
	clr.l %d2
.L2037:
	move.w #11521,%d3
	move.l #-260222380,%d1
	move.l %d1,-140(%fp)
	move.w %d3,-136(%fp)
	cmp.l qp+44.l,%d2
	jne .L2038
	tst.l qp+48
	jeq .L2039
.L2038:
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
	jeq .L2032
	move.l %d2,qp+44
	clr.l qp+48
	addq.l #1,qp+52
.L2039:
	move.l %fp,%d2
	add.l #-140,%d2
	jra .L2040
.L2001:
	lea (24,%a1),%a1
	cmp.l %d1,%a1
	jne .L2003
	move.b pj+180,%d0
	move.l %a0,%d3
	tst.b %d0
	jge .L2004
	clr.l %d0
.L2005:
	tst.b (%a0)
	sne %d2
	lea (24,%a0),%a0
	mvs.b %d2,%d2
	sub.l %d2,%d0
	cmp.l %d1,%a0
	jne .L2005
	jra .L2002
.L2007:
	clr.b %d0
	move.b %d0,pj+181
	jra .L2021
.L2004:
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
.L2015:
	mvz.b pj+180,%d0
	sub.l %a3,%a3
	add.l %d1,%d0
	muls.w #24,%d0
	lea (%a0,%d0.l),%a1
	tst.b (%a1)
	sne %d0
	neg.l %d0
	move.b %d0,(%a2)
.L2009:
	move.b (%a1),%d0
	jeq .L2008
	move.b 8(%a1,%a3.l),%d0
	moveq #127,%d5
	and.l %d5,%d0
.L2008:
	addq.l #1,%a3
	move.b %d0,(%a2,%a3.l)
	moveq #15,%d6
	cmp.l %a3,%d6
	jne .L2009
	sub.l %a1,%a1
.L2010:
	move.l %a1,%a3
	addq.l #1,%a1
	tst.b (%a2,%a1.l)
	jne .L2012
.L2013:
	moveq #15,%d3
	cmp.l %a3,%d3
	jeq .L2011
	clr.b %d0
	addq.l #1,%a3
	move.b %d0,(%a2,%a3.l)
	jra .L2013
.L2012:
	moveq #15,%d7
	cmp.l %a1,%d7
	jne .L2010
.L2011:
	addq.l #1,%d1
	lea (16,%a2),%a2
	moveq #8,%d4
	cmp.l %d1,%d4
	jne .L2015
	moveq #-9,%d5
	pea 139.w
	move.l %d2,-(%sp)
	move.b %d5,-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L2021
	move.b pj+180,%d0
	addq.l #8,%d0
	move.b %d0,pj+180
	jra .L2021
.L1955:
	lea pj,%a0
	move.l (%a0),%d0
.L2022:
	cmp.l pj+4.l,%d0
	jeq .L2021
	moveq #31,%d1
	moveq #10,%d2
	and.l pj+4,%d1
	mvz.b 8(%a0,%d1.l*4),%d1
	cmp.l %d1,%d2
	jeq .L2023
	addq.l #1,pj+156
.L2023:
	addq.l #1,pj+4
	jra .L2022
.L2033:
	tst.l %d0
	jge .L2034
	clr.l %d0
	jra .L2034
.L2036:
	addq.l #1,%d2
	jra .L2037
.L2041:
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
	jeq .L2032
	addq.l #1,qp+60
.L2040:
	move.l qp+60,%d0
	cmp.l qp+56.l,%d0
	jne .L2041
	move.l qp+92,%d1
	cmp.l qp+96.l,%d1
	jeq .L2032
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
	jeq .L2032
	move.l %d2,qp+96
.L2032:
	tst.l st
	jeq .L2025
.L2031:
	mov3q.l #1,%d5
	cmp.l 1094562388.l,%d5
	jne .L2025
	tst.l st+968
	jeq .L2025
	move.l pmo+64,%d2
	tst.l qp+100
	jeq .L2025
	move.w #11521,%d7
	move.l #-260222380,%d6
	move.l %d6,-140(%fp)
	move.w %d7,-136(%fp)
	cmp.l pmo+124.l,%d2
	jeq .L2043
	moveq #17,%d0
	moveq #127,%d1
	move.b %d0,-134(%fp)
	move.l pmo,%d0
	cmp.l %d0,%d1
	jcc .L2044
	moveq #127,%d0
.L2044:
	move.b %d0,-133(%fp)
	move.l pmo+4,%d0
	cmp.l #16383,%d0
	jls .L2045
	mvz.w #16383,%d0
.L2045:
	move.l %d0,%d1
	moveq #127,%d3
	and.l %d3,%d0
	lsr.l #7,%d1
	move.b %d1,-132(%fp)
	move.b %d0,-131(%fp)
	move.l pmo+8,%d0
	cmp.l #16383,%d0
	jls .L2046
	mvz.w #16383,%d0
.L2046:
	move.l %d0,%d1
	moveq #127,%d4
	and.l %d4,%d0
	lsr.l #7,%d1
	move.b %d1,-130(%fp)
	move.b %d0,-129(%fp)
	move.l pmo+12,%d0
	cmp.l %d0,%d4
	jcc .L2047
	moveq #127,%d0
.L2047:
	move.b %d0,-128(%fp)
	lea fp,%a0
	tst.l pmo+52
	jeq .L2069
	move.l (%a0),%d1
	sub.l pmo+108,%d1
	cmp.l #1499,%d1
	sls %d1
	neg.l %d1
.L2048:
	move.l (%a0),%d0
	mov3q.l #1,%d5
	moveq #127,%d6
	sub.l pmo+112,%d0
	cmp.l %d0,%d5
	scc %d0
	neg.l %d0
	add.l %d0,%d0
	or.l %d1,%d0
	move.b %d0,-127(%fp)
	move.l pmo+10096,%d0
	cmp.l %d0,%d6
	jcc .L2049
	moveq #127,%d0
.L2049:
	moveq #-9,%d7
	pea 16.w
	pea -140(%fp)
	move.b %d0,-126(%fp)
	move.b %d7,-125(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L2025
	move.l %d2,pmo+124
.L2043:
	move.l pmo+16,%d2
	cmp.l pmo+128.l,%d2
	jeq .L2025
	move.l st+8,%d0
	moveq #19,%d1
	sub.l pmo+132,%d0
	cmp.l %d0,%d1
	jcc .L2025
	move.w #759,%a1
	moveq #16,%d3
	lea pmo+123,%a0
	move.b (%a0),-133(%fp)
	pea 10.w
	pea -140(%fp)
	move.w %a1,-132(%fp)
	move.b %d3,-134(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L2025
	lea st+8,%a2
	move.l %d2,pmo+128
	move.l (%a2),pmo+132
.L2025:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l -176(%fp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L1758
	move.l %d0,st+332
.L1758:
	movem.l -228(%fp),#15612
	unlk %fp
	rts
.L2069:
	clr.b %d1
	jra .L2048
.L1798:
	tst.b %d0
	jeq .L1802
.L2053:
	tst.b sv+8.l
	jeq .L1801
	move.l (%a0),%d0
	move.l ls,%d7
	eor.l %d7,%d0
	and.l #16776960,%d0
	or.l st+4,%d0
	jeq .L1797
.L1801:
	tst.l %d1
	jne .L1800
.L1802:
	mov3q.l #5,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1797:
	move.l ls_in_gen,%d3
	cmp.l ls+52.l,%d3
	jeq .L1803
	move.l ls_in_v,%d0
	lea ls_in_gen,%a1
	move.l ls+40,%a0
	move.l (%a1),ls+52
	tst.b ls.l
	jeq .L1803
	move.l %d0,%d1
	lsr.l #8,%d1
	mvz.b ls+1,%d2
	cmp.l %d1,%d2
	jne .L1803
	mov3q.l #1,%d1
	and.l %d1,%d0
	tst.l %a0
	jeq .L1804
	tst.l %d0
	jne .L1804
	clr.l st+124
.L1804:
	move.l %d0,ls+40
	mov3q.l #1,ls+44
.L1803:
	tst.l ls+40
	jeq .L1805
	tst.l ls+44
	jne .L1805
	move.l st+8,%d0
	moveq #20,%d2
	sub.l ls+48,%d0
	cmp.l %d0,%d2
	jcc .L1805
	clr.l ls+40
	addq.l #1,ls+60
	clr.l st+124
.L1805:
	move.l u46+8,%d0
	tst.l %d0
	jeq .L1806
	tst.b ls.l
	jne .L1807
	tst.l st+4
	jne .L1807
	move.l st+8,%d1
	moveq #20,%d3
	sub.l %d0,%d1
	cmp.l %d1,%d3
	jcs .L1807
	mvz.b 1093765506,%d0
	moveq #11,%d4
	cmp.l %d0,%d4
	jcs .L1807
	move.l -2147457096,%d0
	moveq #127,%d5
	mvz.b 1093765506,%d1
	and.l %d5,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d1
	move.l u46+12,%d0
	cmp.l %d1,%d0
	jne .L1807
	tst.l ms
	jeq .L1808
	tst.l ms+16
	jeq .L1808
.L1807:
	clr.l u46+8
.L1806:
	move.l pm,%d2
	tst.l %d2
	jeq .L1809
	clr.l pm
	add.l #31,%d2
	tst.b ls.l
	jeq .L1810
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1810:
	clr.l st+1038
	tst.l st+4
	jeq .L1811
	moveq #1,%d7
	mvz.w #256,%d6
	moveq #1,%d0
	move.b %d2,st+993
	addq.l #1,pm+16
	move.l %d6,st+296
	move.b %d7,st+161
	move.w %d0,st+162
.L1812:
	tst.l st+1058
	jne .L1814
	tst.l sv+96
	jne .L1815
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jeq .L1813
	lea st+8,%a0
	mov3q.l #1,st+1058
	mov3q.l #1,st+1062
	move.l (%a0),st+1066
	addq.l #1,st+1070
	addq.l #1,st+1090
.L1814:
	tst.l st+4
	jne .L1816
	clr.l st+1058
.L1817:
	tst.l st+972
	jne .L1821
	tst.b sv+8.l
	jne .L1821
.L1822:
	move.l st+1082,%d0
	tst.l %d0
	jeq .L1824
	sub.l st+8,%d0
	tst.l %d0
	jgt .L1825
	clr.l st+1082
.L1825:
	moveq #1,%d4
	move.b %d4,32(%a2)
.L1824:
	jsr sq_tick
	move.l st+4,%d0
	move.l led_gen,%d1
	or.l sq+408,%d0
	jeq .L1826
	tst.l sq+468
	jne .L1827
	lea led_gen,%a0
	move.l (%a0),st+1002
	lea pg_gen,%a1
	move.l #2139062143,%a3
	clr.l st+1006
	mov3q.l #1,sq+476
	move.l (%a1),sq+472
	move.l %a3,sq+480
.L1827:
	mov3q.l #1,sq+468
	cmp.l st+1002.l,%d1
	jeq .L1829
	btst #0,%d1
	jne .L1829
	move.b led_req_mode,%d2
	clr.l %d0
	lea led_req,%a0
.L1830:
	lea (%a0,%d0.l),%a3
	moveq #16,%d3
	lea (-140,%fp),%a1
	move.b (%a3),(%a1,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d3
	jne .L1830
	cmp.l led_gen.l,%d1
	jne .L1829
	mvz.b %d2,%d2
	move.l %d1,st+1002
	clr.l %d0
	lea st+1022,%a0
	move.l %d2,st+1006
.L1832:
	lea (-140,%fp),%a1
	moveq #16,%d1
	lea (%a1,%d0.l),%a3
	move.b (%a3),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1832
	moveq #1,%d2
	move.b %d2,led_owed
.L1829:
	mov3q.l #1,%d3
	cmp.l st+1006.l,%d3
	jne .L1828
	clr.l led_again
	tst.b ov_on.l
	jeq .L1837
	tst.b led_owed.l
	jeq .L1835
.L1837:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jeq .L2338
	clr.l %d0
	lea st+1022,%a3
	lea ov_col,%a0
.L1838:
	lea (%a3,%d0.l),%a1
	moveq #16,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1838
	moveq #1,%d2
	move.l %fp,%d3
	add.l #-140,%d3
	lea led_send4,%a4
	move.b %d2,ov_on
	clr.l %d2
.L1839:
	move.b (%a3,%d2.l),%d0
	move.l %d3,-(%sp)
	moveq #16,%d4
	move.l %d2,-(%sp)
	addq.l #1,%d2
	move.b %d0,-137(%fp)
	move.b %d0,-138(%fp)
	move.b %d0,-139(%fp)
	move.b %d0,-140(%fp)
	jsr (%a4)
	addq.l #8,%sp
	cmp.l %d2,%d4
	jne .L1839
	clr.b %d5
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #1,st+1010
	move.b %d5,led_owed
	jra .L2339
.L1799:
	tst.b %d0
	jne .L2053
	jra .L1800
	.size	rui_tick, .-rui_tick
	.text
.LC7:
	.string	"%s"
	.text
	.align	2
	.globl	rui_draw
	.type	rui_draw, @function
rui_draw:
	lea (-248,%sp),%sp
	move.l -66650100,%d1
	move.l 252(%sp),%a0
	move.l st+1082,%d0
	movem.l #31996,(%sp)
	move.l 16(%a0),%a6
	move.l %d1,60(%sp)
	tst.l %d0
	jeq .L2344
	sub.l st+8,%d0
	tst.l %d0
	jgt .L2345
.L2344:
	clr.l 44(%sp)
.L2346:
	move.l 252(%sp),%a1
	move.l 16(%a1),%a1
	move.l %a1,52(%sp)
	tst.l st+4
	jne .L2348
	tst.l st+972
	jne .L2349
	tst.b sv+8.l
	jne .L2349
	tst.l 44(%sp)
	jeq .L2351
	jra .L2385
.L2345:
	move.l %a6,%d0
	add.l #566,%d0
	lea (6,%a6),%a0
	lea (108,%sp),%a1
.L2347:
	move.b 1(%a0),(%a1)
	addq.l #8,%a0
	move.b -8(%a0),1(%a1)
	addq.l #2,%a1
	cmp.l %a0,%d0
	jne .L2347
	mov3q.l #1,44(%sp)
	jra .L2346
.L2348:
	tst.l st+1058
	jne .L2351
	move.l commits,%d2
	cmp.l st+24.l,%d2
	jne .L2353
	move.l 52(%sp),%a0
	move.l %a0,%d0
	add.l #1024,%d0
.L2354:
	clr.l (%a0)+
	cmp.l %a0,%d0
	jne .L2354
	move.l %d2,st+20
.L2355:
	tst.l 44(%sp)
	jeq .L2351
	tst.l st+4
	jne .L2379
	tst.l st+972
	jne .L2380
.L2385:
	tst.b sv+8.l
	jne .L2380
.L2351:
	tst.l ms+188
	jeq .L2382
	move.l st+4,%d0
	or.l st+972,%d0
	jne .L2382
	move.l #1098791068,-(%sp)
	jsr 1074207612
	addq.l #4,%sp
	lea (6,%a6),%a0
	move.l %d0,%a1
	mvz.w 6(%a1),%d1
	lea (566,%a6),%a6
.L2383:
	move.b (%a0),%d0
	mov3q.l #1,%d2
	st %d6
	addq.l #8,%a0
	or.l %d2,%d0
	move.b %d6,-7(%a0)
	move.b %d0,-8(%a0)
	cmp.l %a6,%a0
	jne .L2383
	pea ms+192
	moveq #62,%d3
	pea .LC7
	pea ms+192
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	sub.l %d1,%d3
	move.l %d3,-(%sp)
	mov3q.l #2,-(%sp)
	move.l %a1,-(%sp)
	move.l 284(%sp),-(%sp)
	jsr 1074205920
	lea (36,%sp),%sp
	addq.l #1,st+352
.L2382:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 60(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L2343
	move.l %d0,st+332
.L2343:
	movem.l (%sp),#31996
	lea (248,%sp),%sp
	rts
.L2349:
	move.l commits,%d2
.L2353:
	cmp.l st+340.l,%d2
	jne .L2356
	tst.l st+344
	jeq .L2357
.L2356:
	move.l -66650100,%a4
	move.l sh_seq,%d4
	lea copy32,%a2
	move.l %a4,64(%sp)
	btst #0,%d4
	jne .L2358
	pea 256.w
	pea shadow
	pea comp_in
	jsr (%a2)
	pea 704.w
	pea txt_sh
	pea txt_tl
	jsr (%a2)
	lea (24,%sp),%sp
	cmp.l sh_seq.l,%d4
	jne .L2358
	pea 256.w
	pea comp_in
	pea comp
	jsr (%a2)
	lea (12,%sp),%sp
	tst.l st+872
	jne .L2359
	clr.l -(%sp)
	pea comp
	pea 64.w
	pea 128.w
	pea st+872
	jsr 1074198978
	lea (20,%sp),%sp
.L2359:
	lea txt_tl,%a2
	clr.l %d5
.L2372:
	tst.b 4(%a2)
	jeq .L2360
	move.l %a2,%d4
	clr.l %d7
	addq.l #8,%d4
	lea st+408,%a5
	lea st+552,%a0
.L2371:
	tst.l (%a5)+
	jeq .L2362
	mvz.b (%a0),%d0
	cmp.l %d0,%d5
	jne .L2362
	lea st+472,%a1
	mvz.b 5(%a0),%d1
	mvz.b (%a1,%d7.l),%d4
	lea (6,%a0),%a3
	sub.l %a1,%a1
.L2364:
	cmp.l %d1,%a1
	jlt .L2365
	move.b 4(%a0),%d0
	lea 72(%sp,%d1.l),%a3
	btst #1,%d0
	jeq .L2386
	move.l %d4,%d0
	add.l #-64,%d0
	move.l %d0,56(%sp)
	tst.l %d0
	jle .L2367
	move.b #43,(%a3)
	addq.l #1,%d1
	lea 72(%sp,%d1.l),%a3
.L2387:
	sub.l %a1,%a1
	jra .L2366
.L2365:
	lea (%a3,%a1.l),%a4
	move.b (%a4),72(%sp,%a1.l)
	addq.l #1,%a1
	jra .L2364
.L2367:
	tst.l 56(%sp)
	jeq .L2387
	move.b #45,(%a3)
	moveq #64,%d3
	mov3q.l #1,%a1
	sub.l %d4,%d3
	move.l %d3,56(%sp)
.L2366:
	lea (68,%sp),%a4
	clr.l %d4
.L2369:
	move.l 56(%sp),%d6
	moveq #10,%d0
	addq.l #1,%d4
	rems.l %d0,%d3:%d6
	divs.l %d0,%d6
	add.l #48,%d3
	move.b %d3,(%a4)
	move.l %d6,56(%sp)
	tst.l %d6
	jeq .L2368
	addq.l #1,%a4
	mov3q.l #4,%d6
	cmp.l %d4,%d6
	jne .L2369
.L2368:
	add.l %a1,%a3
	move.l %d4,%d0
.L2370:
	subq.l #1,%d0
	move.b 68(%sp,%d0.l),(%a3)+
	tst.l %d0
	jne .L2370
	mvz.w #248,%d0
	add.l %sp,%d0
	add.l %d1,%d0
	add.l %d4,%d0
	add.l %d0,%a1
	clr.b %d0
	move.l %sp,%d4
	add.l #72,%d4
	move.b %d0,-176(%a1)
.L2362:
	addq.l #1,%d7
	lea (20,%a0),%a0
	moveq #16,%d1
	cmp.l %d7,%d1
	jne .L2371
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
	jgt .L2360
	move.b 3(%a2),%d1
	move.l %d4,-(%sp)
	pea .LC7
	move.l %d4,-(%sp)
	mov3q.l #1,%d3
	mov3q.l #3,%d6
	move.l %d1,%d4
	lsr.l #2,%d4
	and.l %d1,%d6
	and.l %d4,%d3
	move.l %d3,-(%sp)
	move.l %d6,-(%sp)
	move.l %d0,-(%sp)
	mvz.b (%a2),%d0
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	pea st+872
	jsr 1074205920
	lea (36,%sp),%sp
	addq.l #1,st+352
.L2360:
	addq.l #1,%d5
	lea (44,%a2),%a2
	moveq #64,%d0
	cmp.l %d5,%d0
	jne .L2372
	move.l -66650100,%d0
	move.l %d2,st+340
	addq.l #1,st+348
	sub.l 64(%sp),%d0
	add.l %d0,st+356
	cmp.l st+360.l,%d0
	jls .L2373
	move.l %d0,st+360
.L2373:
	clr.l st+344
.L2357:
	pea 256.w
	pea comp
	move.l 60(%sp),-(%sp)
	jsr copy32
	lea (12,%sp),%sp
	cmp.l st+20.l,%d2
	jeq .L2374
	move.l -66650100,%d0
	addq.l #1,st+308
	sub.l t_commit,%d0
	add.l %d0,st+304
	cmp.l st+312.l,%d0
	jls .L2374
	move.l %d0,st+312
.L2374:
	move.l st+388,%d1
	tst.l %d1
	jeq .L2375
	cmp.l st+392.l,%d2
	jeq .L2375
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+396
	addq.l #1,st+400
	cmp.l st+404.l,%d0
	jls .L2376
	move.l %d0,st+404
.L2376:
	clr.l st+388
.L2375:
	move.l st+368,%d1
	tst.l %d1
	jeq .L2377
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+372
	addq.l #1,st+376
	cmp.l st+380.l,%d0
	jls .L2378
	move.l %d0,st+380
.L2378:
	clr.l st+368
.L2377:
	move.l %d2,st+20
	move.l -66650100,%d0
	move.l %d0,st+56
	sub.l t_commit,%d0
	addq.l #1,st+28
	move.l %d0,st+60
	jra .L2355
.L2386:
	move.l %d4,56(%sp)
	jra .L2387
.L2358:
	pea 256.w
	pea comp
	move.l 60(%sp),-(%sp)
	addq.l #1,st+32
	jsr (%a2)
	lea (12,%sp),%sp
	jra .L2355
.L2379:
	tst.l st+1058
	jne .L2351
.L2380:
	move.l %a6,%d2
	add.l #566,%d2
	lea (108,%sp),%a1
	lea (6,%a6),%a0
.L2381:
	move.b (%a0),%d0
	move.b (%a1),1(%a0)
	moveq #-2,%d1
	mov3q.l #1,%d3
	addq.l #2,%a1
	addq.l #8,%a0
	and.l %d1,%d0
	move.b -1(%a1),%d1
	and.l %d3,%d1
	or.l %d1,%d0
	move.b %d0,-8(%a0)
	cmp.l %d2,%a0
	jne .L2381
	jra .L2351
	.size	rui_draw, .-rui_draw
	.align	2
	.globl	rui_key
	.type	rui_key, @function
rui_key:
	lea (-96,%sp),%sp
	movem.l #31996,(%sp)
	move.l 104(%sp),%a4
	move.l -66650100,%d1
	move.l 100(%sp),%a3
	move.l 12(%a4),%d4
	move.l %d4,%d2
	mvz.b %d2,%d2
	move.l %d1,60(%sp)
	mov3q.l #1,%d1
	and.l 16(%a4),%d1
	cmp.l #178,%d2
	jne .L2412
	cmp.l ed+88.l,%d1
	jeq .L2412
	move.l %d1,ed+88
	mov3q.l #1,ed+92
.L2412:
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
	jne .L2413
	move.l ms+16,%a0
	tst.l %a0
	jeq .L2414
	move.l %a0,%d0
	add.l #13,%d0
	cmp.l %d2,%d0
	jne .L2414
	pea 127.w
	pea -1(%a0)
	clr.l -(%sp)
	jsr ms_ev
	jsr ms_acc_drop
	clr.l ms+16
	clr.l ms+60
	lea (12,%sp),%sp
.L2414:
	move.l ms+20,%d0
	tst.l %d0
	jeq .L2415
	add.l #13,%d0
	cmp.l %d2,%d0
	jne .L2415
	clr.l ms+20
.L2415:
	cmp.l #132,%d2
	jne .L2416
	tst.l ms+4
	jeq .L2417
	clr.l ms+4
	tst.l ms+8
	jeq .L2417
	mov3q.l #1,-(%sp)
	move.l %a4,-(%sp)
	move.l %a3,-(%sp)
	clr.l ms+8
	addq.l #1,ms+220
	jsr (ms_stock_key.constprop.0)
	lea (12,%sp),%sp
.L2422:
	clr.l %d7
.L2418:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 60(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L2411
	move.l %d0,st+332
.L2411:
	move.l %d7,%d0
	movem.l (%sp),#31996
	lea (96,%sp),%sp
	rts
.L2416:
	moveq #66,%d5
	cmp.l %d2,%d5
	jne .L2419
	tst.b k44+20.l
	jeq .L2420
	clr.b %d7
	move.b %d7,k44+20
	tst.b k44+22.l
	jeq .L2420
	moveq #2,%d0
	move.w %d0,k44+22
.L2420:
	clr.l u46
	tst.b u46+48.l
	jeq .L2417
	clr.b %d1
	move.b %d1,u46+48
.L2425:
	mov3q.l #1,%d7
	jra .L2418
.L2419:
	cmp.l #134,%d2
	jne .L2421
	clr.l tk
	tst.l tk+8
	jeq .L2417
	move.l st+248,%d0
	clr.l tk+8
	btst #6,%d0
	jeq .L2422
	moveq #-65,%d4
	and.l %d0,%d4
	move.l %d4,st+248
	tst.l st+4
	jeq .L2422
.L2782:
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
.L2770:
	addq.l #8,%sp
	jra .L2422
.L2421:
	move.l %d2,%d0
	add.l #-68,%d0
	lsr.l #1,%d0
	jne .L2417
	moveq #31,%d1
	mov3q.l #1,%d0
	and.l %d4,%d1
	lsl.l %d1,%d0
	and.l st+208,%d0
	tst.l %d0
	jeq .L2423
	move.l st+200,%d3
	move.l %d3,%d5
	move.l st+220,%d1
	move.l %d1,%d0
	and.l #2097152,%d0
	and.l #786432,%d5
	or.l %d5,%d0
	jeq .L2424
	addq.l #1,nk+16
.L2424:
	and.l #-786433,%d3
	bclr #21,%d1
	move.l %d3,st+200
	move.l %d1,st+220
.L2423:
	moveq #69,%d7
	cmp.l %d2,%d7
	jne .L2417
	tst.l nk
	jeq .L2417
	moveq #-33,%d0
	and.l %d0,st+240
	clr.l nk
	tst.l st+4
	jeq .L2425
	mov3q.l #1,-(%sp)
	pea 69.w
	lea queue_key,%a2
	jsr (%a2)
	clr.l -(%sp)
	pea 69.w
	jsr (%a2)
	jsr flush
.L2772:
	lea (16,%sp),%sp
	jra .L2425
.L2417:
	moveq #31,%d7
	mov3q.l #1,%d0
	and.l %d7,%d4
	move.l %d2,%d1
	lsr.l #5,%d1
	move.l %d1,%a0
	lea (66,%a0),%a0
	lsl.l %d4,%d0
	move.l (%a2,%a0.l*4),%d5
	move.l %d5,%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L2426
	not.l %d0
	and.l %d5,%d0
	move.l %d0,(%a2,%a0.l*4)
	jra .L2425
.L2426:
	move.l %d2,%d4
	mov3q.l #5,%d5
	add.l #-64,%d4
	cmp.l %d4,%d5
	jcs .L2427
	move.l ls+32,%d5
	btst %d4,%d5
	jeq .L2427
	mov3q.l #1,%d0
	lsl.l %d4,%d0
	move.l ls+36,%d1
	not.l %d0
	and.l %d0,%d5
	move.l %d5,ls+32
	btst %d4,%d1
	jeq .L2425
	and.l %d1,%d0
	move.l %d0,ls+36
.L2783:
	clr.l -(%sp)
.L2773:
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	jra .L2771
.L2427:
	move.l %d1,%a1
	move.l %d0,%d4
	lea (121,%a1),%a1
	lea sq,%a0
	move.l (%a0,%a1.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L2428
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a0,%a1.l*4)
	jra .L2783
.L2428:
	move.l %d1,%a0
	move.l %d0,%d4
	lea (50,%a0),%a0
	move.l (%a2,%a0.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L2429
	not.l %d0
	and.l %d3,%d0
	move.l %d2,%d1
	mov3q.l #7,%d7
	add.l #-112,%d1
	move.l %d0,(%a2,%a0.l*4)
	cmp.l %d1,%d7
	jcs .L2422
	tst.l st
	jeq .L2422
	move.l ux,%d3
	btst %d1,%d3
	jeq .L2422
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	not.l %d0
	and.l %d3,%d0
	move.l %d0,ux
	jra .L2782
.L2429:
	move.l %d1,%a0
	move.l %d0,%d4
	lea (226,%a0),%a0
	move.l (%a2,%a0.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L2430
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a2,%a0.l*4)
	move.l st+4,%d0
	or.l sq+408,%d0
	jeq .L2422
	jra .L2782
.L2430:
	add.l #58,%d1
	move.l %d0,%d4
	move.l (%a2,%d1.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L2422
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a2,%d1.l*4)
	tst.l st+4
	jeq .L2425
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
.L2771:
	addq.l #8,%sp
	jra .L2425
.L2413:
	moveq #31,%d1
	mov3q.l #1,%d3
	and.l %d4,%d1
	move.l %d2,%d0
	lsr.l #5,%d0
	move.l %d0,%a6
	add.l #66,%d0
	move.l (%a2,%d0.l*4),%d0
	lsl.l %d1,%d3
	move.l %d1,56(%sp)
	move.l %d0,%d1
	and.l %d3,%d1
	tst.l %d1
	jne .L2425
	lea (58,%a6),%a0
	move.l %d3,%d1
	and.l (%a2,%a0.l*4),%d1
	move.l %a0,52(%sp)
	tst.l %d1
	jne .L2425
	lea sq,%a5
	move.l %a6,%d6
	move.l %d3,%d1
	add.l #121,%d6
	and.l (%a5,%d6.l*4),%d1
	tst.l %d1
	jne .L2425
	move.l %a6,%d1
	add.l #50,%d1
	move.l (%a2,%d1.l*4),%d1
	and.l %d3,%d1
	tst.l %d1
	jne .L2422
	move.l %a6,%d1
	move.l %d3,%d5
	add.l #226,%d1
	and.l (%a2,%d1.l*4),%d5
	tst.l %d5
	jne .L2422
	cmp.l #132,%d2
	jne .L2431
	tst.l ms+8
	jne .L2425
.L2431:
	move.l ms+16,%a0
	tst.l %a0
	jeq .L2432
	move.l %d4,%d7
	and.l #240,%d7
	tst.l %d7
	jne .L2432
	or.l %d3,%d0
	move.l %d0,st+264
	moveq #11,%d0
	cmp.l %d2,%d0
	jcs .L2425
	move.l %d2,-(%sp)
	pea -1(%a0)
	mov3q.l #2,-(%sp)
	jsr ms_ev
	addq.l #1,ms+236
	jsr ms_send
.L2776:
	lea (12,%sp),%sp
	jra .L2425
.L2432:
	jsr ms_stock_ok
	move.l %d0,%d7
	tst.l %d0
	jeq .L2433
	cmp.l #132,%d2
	jne .L2434
	move.l st+216,%d1
	mov3q.l #1,%d0
	or.l st+248,%d1
	or.l st+920,%d1
	and.l %d1,%d0
	btst #0,%d1
	jne .L2433
	lea st+8,%a0
	move.l (%a0),ms+12
	mov3q.l #1,ms+4
	mov3q.l #1,ms+8
	move.l %a3,ms+24
	lea ms+28,%a0
.L2435:
	lea (%a4,%d0.l),%a1
	moveq #32,%d1
	move.l (%a1),(%a0,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L2435
	addq.l #1,ms+216
	jra .L2418
.L2434:
	move.l %d2,%d0
	mov3q.l #1,%d1
	add.l #-14,%d0
	cmp.l %d0,%d1
	jcs .L2433
	tst.l ms+4
	jeq .L2433
	tst.l ms+8
	jeq .L2436
	clr.l ms+8
.L2437:
	pea 127.w
	moveq #16,%d5
	move.l %d0,-(%sp)
	add.l #-13,%d2
	mov3q.l #1,-(%sp)
	move.l %d2,ms+16
	clr.l ms+60
	or.l %d5,st+280
	or.l %d3,st+264
	addq.l #1,ms+232
	jsr ms_ev
	jsr ms_send
	lea (12,%sp),%sp
	jra .L2418
.L2436:
	move.l st+216,%d1
	btst #4,%d1
	jeq .L2437
	moveq #-17,%d4
	and.l %d1,%d4
	clr.l -(%sp)
	move.l %a4,-(%sp)
	move.l %a3,-(%sp)
	move.l %d0,60(%sp)
	move.l %d4,st+216
	jsr (ms_stock_key.constprop.0)
	lea (12,%sp),%sp
	addq.l #1,ms+252
	move.l 48(%sp),%d0
	jra .L2437
.L2433:
	tst.l ms+8
	jeq .L2439
	mov3q.l #1,-(%sp)
	moveq #16,%d7
	pea ms+28
	move.l %a3,-(%sp)
	clr.l ms+8
	addq.l #1,ms+228
	jsr (ms_stock_key.constprop.0)
	or.l %d7,st+216
	lea (12,%sp),%sp
.L2439:
	move.l st+4,%d0
	tst.l %d0
	jeq .L2440
	tst.l st+1058
	jne .L2440
	tst.l ms
	jeq .L2440
	move.l %d4,%d7
	and.l #240,%d7
	tst.l %d7
	jne .L2440
	move.l %d2,%a1
	mov3q.l #1,%d1
	move.l ms+20,%a0
	lea (-14,%a1),%a1
	cmp.l %a1,%d1
	jcs .L2441
	tst.l %a0
	jne .L2440
	move.l st+248,%d7
	or.l st+920,%d7
	btst #4,%d7
	jne .L2442
.L2440:
	tst.l nk
	jeq .L2444
	move.l %d2,%a0
	mov3q.l #1,%d1
	lea (-18,%a0),%a0
	cmp.l %a0,%d1
	jcc .L2447
	cmp.l #181,%d2
	jne .L2446
.L2447:
	lea (%a4,%d5.l),%a0
	moveq #32,%d0
	move.l (%a0),64(%sp,%d5.l)
	addq.l #4,%d5
	cmp.l %d5,%d0
	jne .L2447
	moveq #69,%d1
	mov3q.l #1,%d2
	or.l %d2,80(%sp)
	moveq #-33,%d4
	and.l %d4,st+240
	or.l %d0,st+208
	clr.l nk
	addq.l #1,nk+4
	move.b %d1,79(%sp)
	pea 64(%sp)
	move.l %a3,-(%sp)
	jsr 1074397898
	lea (50,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
	jra .L2770
.L2441:
	tst.l %a0
	jeq .L2440
	moveq #11,%d7
	cmp.l %d2,%d7
	jcs .L2440
.L2443:
	or.l %d3,st+232
	addq.l #1,ms+256
	addq.l #1,st+936
.L2775:
	mov3q.l #1,-(%sp)
	jra .L2773
.L2442:
	move.l %d2,%a0
	lea (-13,%a0),%a0
	move.l %a0,ms+20
	jra .L2443
.L2446:
	clr.l nk
	addq.l #1,nk+8
	tst.l %d0
	jeq .L2444
	mov3q.l #1,-(%sp)
	pea 69.w
	jsr queue_key
	jsr flush
	addq.l #8,%sp
.L2444:
	moveq #66,%d5
	cmp.l %d2,%d5
	jne .L2448
	move.l st+4,%d1
	tst.l %d1
	jeq .L2449
	tst.l st+1058
	jne .L2450
.L2449:
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jne .L2450
	move.w #256,%d7
	lea st+8,%a0
	move.l (%a0),k44
	move.w %d7,k44+20
.L2450:
	lea st+8,%a0
	move.l (%a0),u46+4
	tst.l sq+408
	jeq .L2477
	tst.l %d1
	jeq .L2453
	tst.l st+1058
	jne .L2477
	move.l sq+484,%d0
	move.l st+232,%d1
.L2455:
	or.l %d1,%d0
	tst.w %d0
	jeq .L2477
	moveq #1,%d0
	clr.b %d1
	addq.l #1,u46+32
	move.b %d0,u46+48
	move.b %d1,k44+20
	jra .L2425
.L2448:
	cmp.l #128,%d2
	jne .L2451
	lea masks,%a1
	move.l (%a1),nk+20
.L2477:
	move.l %d2,%d5
	mov3q.l #1,%d0
	move.l st+4,%d1
	add.l #-64,%d5
	cmp.l %d5,%d0
	jcs .L2496
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jne .L2495
	tst.l fk_claim
	jeq .L2498
	move.b ls,%d0
	move.b u46+48,%d7
	or.l %d7,%d0
	tst.b %d0
	jne .L2498
	move.l st+216,%d0
	moveq #65,%d7
	or.l st+972,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d7,%d0
	or.l %d1,%d0
	jne .L2498
	tst.l sq+408
	jeq .L2499
	tst.w sq+486.l
	jne .L2498
.L2499:
	tst.w st+202.l
	jne .L2498
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	or.l ov_list,%d0
	jne .L2498
	or.l %d3,st+272
	moveq #64,%d0
	cmp.l %d2,%d0
	jne .L2583
	moveq #15,%d0
.L2500:
	lea fk,%a0
	addq.l #1,(%a0,%d5.l*4)
	move.l %d0,dp
	addq.l #1,dp+4
	jra .L2781
.L2453:
	move.l sq+484,%d0
	jra .L2455
.L2451:
	moveq #68,%d5
	cmp.l %d2,%d5
	jne .L2456
	move.l tk,%d0
	or.l u46,%d0
	jeq .L2457
	tst.l st+4
	jeq .L2457
	addq.l #1,tk+4
	jra .L2477
.L2457:
	move.l st+216,%d0
	moveq #64,%d7
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d0,%d7
	move.l %d7,%a1
	btst #6,%d0
	jne .L2459
	move.l st+240,%d0
	move.l st+208,%d5
	move.l %d5,%d1
	move.l st+912,%d7
	or.l %d0,%d1
	or.l %d7,%d1
	move.w %d1,%ccr
	jeq .L2460
	tst.b u46+48.l
	jeq .L2461
.L2460:
	move.l st+8,%a0
	mov3q.l #2,%d1
	sub.l u46+4,%a0
	cmp.l %a0,%d1
	jcc .L2462
.L2459:
	moveq #16,%d2
	or.l %d2,st+272
	tst.l %a1
	jne .L2463
	moveq #1,%d4
	addq.l #1,u46+20
	addq.l #1,u46+16
	move.b %d4,k44+21
.L2463:
	tst.l st+4
	jeq .L2464
	tst.b k44+22.l
	jeq .L2465
	tst.b k44+26.l
	jne .L2465
	tst.l %a1
	jne .L2465
	moveq #1,%d7
	moveq #1,%d0
	clr.b %d1
	mvz.w #256,%d5
	move.l %d5,st+296
	move.b %d7,st+161
	move.w %d0,st+162
	move.b %d1,st+993
.L2777:
	jsr flush
	jra .L2425
.L2465:
	mov3q.l #3,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr leave
	jra .L2771
.L2464:
	clr.l -(%sp)
.L2778:
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	jra .L2776
.L2462:
	move.w %d5,%ccr
	jeq .L2466
.L2461:
	or.l %d7,%d0
	move.w %d0,%ccr
	jeq .L2466
	tst.b u46+48.l
	jeq .L2477
.L2466:
	addq.l #1,u46+40
	jra .L2477
.L2456:
	moveq #53,%d5
	cmp.l %d2,%d5
	jne .L2467
	move.l st+216,%d7
	move.l st+248,%a1
	move.l st+920,%d5
	move.l %d7,44(%sp)
	btst #6,%d7
	jne .L2468
	move.l %a1,%d7
	moveq #64,%d0
	or.l %d5,%d7
	mov3q.l #4,%d1
	and.l %d0,%d7
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	and.l %d1,%d0
	or.l %d7,%d0
	jne .L2469
	tst.b u46+48.l
	jeq .L2477
.L2470:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L2468
.L2469:
	tst.l %d7
	jeq .L2470
.L2468:
	move.l %a1,%d1
	or.l 44(%sp),%d1
	moveq #32,%d4
	swap %d4
	or.l %d5,%d1
	or.l %d4,st+268
	btst #6,%d1
	jeq .L2472
	mov3q.l #1,tk
.L2472:
	clr.l st+1038
	tst.l st+4
	jeq .L2473
	moveq #1,%d7
	mvz.w #256,%d5
	moveq #1,%d0
	moveq #1,%d1
	move.l %d5,st+296
	addq.l #1,st+998
	move.b %d7,st+161
	move.w %d0,st+162
	move.b %d1,st+993
	jra .L2777
.L2473:
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	addq.l #1,st+994
	jra .L2776
.L2467:
	moveq #16,%d5
	cmp.l %d2,%d5
	jne .L2452
	move.l st+216,%d7
	move.l st+248,%a1
	move.l st+920,%d5
	move.l %d7,44(%sp)
	btst #6,%d7
	jne .L2474
	move.l %a1,%d7
	moveq #64,%d0
	or.l %d5,%d7
	mov3q.l #4,%d1
	and.l %d0,%d7
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	and.l %d1,%d0
	or.l %d7,%d0
	jne .L2475
	tst.b u46+48.l
	jeq .L2477
.L2476:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L2474
.L2475:
	tst.l %d7
	jeq .L2476
.L2474:
	move.l %a1,%d1
	or.l 44(%sp),%d1
	moveq #1,%d4
	swap %d4
	or.l %d5,%d1
	or.l %d4,st+264
	btst #6,%d1
	jeq .L2478
	mov3q.l #1,tk
.L2478:
	clr.l st+1038
	tst.l st+4
	jeq .L2479
	moveq #1,%d7
	mvz.w #256,%d5
	moveq #1,%d0
	moveq #2,%d1
	move.l %d5,st+296
	move.b %d7,st+161
	move.w %d0,st+162
	move.b %d1,st+993
.L2780:
	addq.l #1,st+1078
	jra .L2777
.L2479:
	mov3q.l #2,-(%sp)
.L2779:
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	addq.l #1,st+1074
	jra .L2776
.L2452:
	moveq #52,%d5
	cmp.l %d2,%d5
	jne .L2454
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L2480
	tst.b u46+48.l
	jeq .L2477
.L2480:
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #6,%d0
	jne .L2477
	tst.l sq+408
	jeq .L2481
	tst.w sq+486.l
	jne .L2477
.L2481:
	tst.w st+202.l
	jne .L2477
	moveq #1,%d7
	moveq #16,%d0
	swap %d0
	mov3q.l #1,u46
	addq.l #1,u46+16
	addq.l #1,u46+44
	clr.l st+1038
	move.b %d7,k44+21
	or.l %d0,st+268
	tst.l st+4
	jeq .L2482
	moveq #1,%d2
	moveq #3,%d4
	mvz.w #256,%d1
	move.b %d7,st+161
	move.l %d1,st+296
	move.w %d2,st+162
	move.b %d4,st+993
	jra .L2780
.L2482:
	mov3q.l #3,-(%sp)
	jra .L2779
.L2454:
	moveq #51,%d5
	cmp.l %d2,%d5
	jne .L2458
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L2483
	tst.b u46+48.l
	jeq .L2477
.L2483:
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #6,%d0
	jne .L2477
	tst.l sq+408
	jeq .L2484
	tst.w sq+486.l
	jne .L2477
.L2484:
	tst.w st+202.l
	jne .L2477
	moveq #1,%d7
	moveq #8,%d0
	swap %d0
	mov3q.l #1,u46
	addq.l #1,u46+16
	clr.l st+1038
	move.b %d7,k44+21
	or.l %d0,st+268
	tst.l st+4
	jeq .L2485
	moveq #1,%d2
	moveq #4,%d4
	mvz.w #256,%d1
	move.b %d7,st+161
	move.l %d1,st+296
	move.w %d2,st+162
	move.b %d4,st+993
	jra .L2777
.L2485:
	mov3q.l #4,-(%sp)
	jra .L2778
.L2458:
	moveq #48,%d5
	cmp.l %d2,%d5
	jne .L2471
	move.l st+216,%d7
	move.l st+248,%a1
	move.l st+920,%d5
	move.l %d7,44(%sp)
	btst #6,%d7
	jne .L2486
	move.l %a1,%d7
	moveq #64,%d0
	or.l %d5,%d7
	mov3q.l #4,%d1
	and.l %d0,%d7
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	and.l %d1,%d0
	or.l %d7,%d0
	jne .L2487
	tst.b u46+48.l
	jeq .L2477
.L2488:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L2486
.L2487:
	tst.l %d7
	jeq .L2488
.L2486:
	mvz.b 1093765506,%d0
	moveq #11,%d4
	cmp.l %d0,%d4
	jcs .L2582
	move.b 1093765506,%d0
	add.l #16,%d0
.L2489:
	move.l %a1,%d1
	or.l 44(%sp),%d1
	moveq #1,%d7
	swap %d7
	or.l %d5,%d1
	or.l %d7,st+268
	btst #6,%d1
	jeq .L2490
	mov3q.l #1,tk
.L2490:
	tst.l st+4
	jeq .L2491
	tst.l st+1038
	jeq .L2492
	mov3q.l #3,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr leave
	addq.l #1,st+1050
	jra .L2771
.L2582:
	moveq #16,%d0
	jra .L2489
.L2492:
	moveq #1,%d1
	moveq #1,%d2
	move.w #256,%a0
	move.b %d0,st+993
	mov3q.l #1,st+1038
	addq.l #1,st+1046
	move.l %a0,st+296
	move.b %d1,st+161
	move.w %d2,st+162
	jra .L2777
.L2491:
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	mov3q.l #1,st+1038
	addq.l #1,st+1042
	jra .L2776
.L2471:
	moveq #13,%d5
	cmp.l %d2,%d5
	jcs .L2477
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L2493
	tst.b u46+48.l
	jeq .L2494
.L2493:
	or.l %d3,st+264
	addq.l #1,%d2
	move.l %d2,dp
	addq.l #1,dp+4
.L2781:
	tst.b k44+22.l
	jne .L2425
	moveq #1,%d7
	move.b %d7,k44+21
	jra .L2425
.L2494:
	move.l %d2,%d5
	add.l #-64,%d5
.L2495:
	tst.l st+4
	jeq .L2510
	cmp.l #132,%d2
	jne .L2511
	move.l st+216,%d1
	move.l %d1,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L2511
	moveq #16,%d5
	or.l %d1,%d5
	move.l %d5,st+216
	tst.l st+1058
	jne .L2512
	lea st+8,%a0
	mov3q.l #1,st+1058
	clr.l st+1062
	move.l (%a0),st+1066
	addq.l #1,st+1070
.L2512:
	moveq #1,%d0
	move.l 32(%a3),%a0
	move.b %d0,32(%a0)
	jra .L2422
.L2583:
	moveq #16,%d0
	jra .L2500
.L2498:
	addq.l #1,fk+8
	jra .L2495
.L2496:
	moveq #49,%d7
	cmp.l %d2,%d7
	jne .L2495
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L2503
	tst.b u46+48.l
	jeq .L2504
.L2503:
	move.l %d1,%d0
	or.l st+972,%d0
	jne .L2504
	tst.l sq+408
	jeq .L2505
	tst.w sq+486.l
	jne .L2504
.L2505:
	move.l st+200,%d7
	mvz.w %d7,%d7
	tst.l %d7
	jne .L2504
	move.b 1093765506,%d1
	moveq #11,%d0
	mvz.b %d1,%d2
	cmp.l %d2,%d0
	jlt .L2506
	moveq #127,%d0
	ext.w %d1
	and.l -2147457096,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d7
.L2506:
	moveq #1,%d1
	addq.l #1,u46+24
	addq.l #1,u46+16
	move.b %d1,k44+21
	tst.b ls.l
	jeq .L2507
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L2507:
	clr.l u46+8
	moveq #11,%d4
	cmp.l %d2,%d4
	jlt .L2508
	move.l %d7,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L2509
	moveq #45,%d5
	cmp.l %d7,%d5
	jeq .L2509
	moveq #43,%d0
	cmp.l %d7,%d0
	jne .L2508
.L2509:
	move.l %d7,-(%sp)
	move.l %d2,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	moveq #127,%d1
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jeq .L2508
	mov3q.l #1,%d2
	or.l st+8,%d2
	move.l %d7,u46+12
	move.l %d2,u46+8
.L2508:
	moveq #2,%d4
	swap %d4
	or.l %d4,st+204
	jra .L2422
.L2504:
	moveq #-15,%d5
	jra .L2495
.L2510:
	tst.b ls.l
	jeq .L2513
	mov3q.l #5,%d1
	cmp.l %d5,%d1
	jcs .L2514
	move.l st+216,%d0
	mov3q.l #1,%d3
	lsl.l %d5,%d3
	mov3q.l #1,%d4
	or.l st+920,%d0
	lea flush,%a3
	moveq #68,%d5
	or.l %d3,ls+32
	or.l st+248,%d0
	and.l %d4,%d0
	cmp.l %d2,%d5
	jne .L2515
	tst.l ls+40
	jne .L2516
	tst.l %d0
	jeq .L2517
	lea st+8,%a0
	lea ls_in_gen,%a1
	move.l (%a0),ls+48
	move.l (%a1),ls+52
	clr.l -(%sp)
	mov3q.l #1,ls+40
	clr.l ls+44
	mov3q.l #3,-(%sp)
	addq.l #1,ls+56
	jsr ls_queue
.L2784:
	jsr (%a3)
	jra .L2771
.L2515:
	moveq #69,%d1
	cmp.l %d2,%d1
	jne .L2516
	tst.l %d0
	jeq .L2518
	move.b ls+2,%d1
	add.l #-40,%d1
	mvz.b %d1,%d1
	lsr.l #1,%d1
	jne .L2516
.L2518:
	tst.l ls+40
	jeq .L2584
.L2516:
	move.l %d0,%a0
	pea 1(%a0)
	or.l %d3,ls+36
	move.l %d2,-(%sp)
	addq.l #1,ls+92
	jsr queue_key
	jra .L2784
.L2517:
	move.l 1100949720,%a2
	move.l %a2,%d0
	clr.l ls+68
	clr.l ls+64
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L2520
	jsr sq_grid
	tst.l %d0
	jeq .L2520
	lea (348,%a2),%a0
	move.l (%a0),ls+64
	lea (344,%a2),%a2
	move.l (%a2),ls+68
.L2520:
	mvz.b ls+1,%d0
	lea st+8,%a1
	move.l (%a1),ls+76
	move.l %d0,ls+72
	moveq #1,%d0
.L2519:
	mov3q.l #3,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	jsr ls_close
	jsr (%a3)
.L2774:
	addq.l #4,%sp
	jra .L2425
.L2584:
	moveq #2,%d0
	jra .L2519
.L2514:
	move.l %d4,%d0
	and.l #240,%d0
	tst.l %d0
	jeq .L2513
	cmp.l #128,%d2
	jeq .L2513
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-80,%d0
	cmp.l %d0,%d1
	jcc .L2513
	add.l #-64,%d0
	moveq #11,%d7
	cmp.l %d0,%d7
	jcc .L2513
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
	tst.l st+4
	jne .L2511
.L2513:
	move.b ls,%d7
	move.l st+972,%d0
	tst.b %d7
	jne .L2521
	moveq #68,%d1
	cmp.l %d2,%d1
	jne .L2521
	tst.l %d0
	jne .L2522
	move.l ls+28,%d0
	mov3q.l #4,%d5
	addq.l #2,%d0
	cmp.l %d0,%d5
	jcs .L2511
	tst.b sv.l
	jeq .L2523
	tst.b sv+8.l
	jeq .L2523
	tst.b sv+3.l
	jne .L2523
	mvz.b sv+1,%d1
	mvz.b 1093765506,%d0
	cmp.l %d1,%d0
	jne .L2523
	mvz.b sv+2,%d5
	move.l %d5,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L2524
	moveq #45,%d0
	cmp.l %d5,%d0
	jeq .L2524
	moveq #43,%d1
	cmp.l %d5,%d1
	jeq .L2524
.L2523:
	jsr ls_p13
	tst.l %d0
	jeq .L2511
.L2524:
	tst.l sq+408
	jeq .L2525
	tst.w sq+486.l
	jne .L2511
.L2525:
	move.l st+216,%d0
	or.l st+920,%d0
	or.l st+248,%d0
	btst #0,%d0
	jeq .L2511
	lea flush,%a2
	tst.l ms
	jeq .L2526
	tst.l ms+16
	jeq .L2526
	pea .LC0
	moveq #16,%d2
	addq.l #1,ms+248
	jsr ms_say
	or.l %d2,st+272
	jsr (%a2)
	jra .L2774
.L2526:
	jsr ls_p13
	tst.l %d0
	jeq .L2527
	moveq #46,%d4
	move.w #3076,%d5
	move.b 1093765506,%d0
	move.b %d4,ls+2
	move.w %d5,ls+128
	move.b %d0,ls+1
	mvz.b %d0,%d0
	addq.l #1,%d0
	move.l %d0,ls_smpl
.L2528:
	moveq #1,%d5
	lea st+8,%a0
	move.l (%a0),ls+130
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	lea ls_queue,%a3
	addq.l #1,ls+80
	move.b %d5,ls
	addq.l #1,ls+134
	jsr (%a3)
	mov3q.l #1,ls+40
	clr.l ls+44
	lea st+8,%a1
	lea ls_in_gen,%a0
	move.l (%a1),ls+48
	move.l (%a0),ls+52
	mov3q.l #6,-(%sp)
	mov3q.l #3,-(%sp)
	addq.l #1,ls+56
	jsr (%a3)
	moveq #16,%d0
	or.l %d0,st+272
	jsr (%a2)
	jra .L2772
.L2527:
	mvz.b sv+2,%d0
	lea sv+1,%a0
	moveq #45,%d1
	move.w (%a0),ls+1
	cmp.l %d0,%d1
	jeq .L2586
	moveq #43,%d2
	cmp.l %d0,%d2
	jne .L2529
.L2586:
	moveq #10,%d7
.L2529:
	clr.b %d4
	move.b %d7,ls+128
	move.b %d4,ls+129
	jra .L2528
.L2511:
	move.l st+4,%d0
	tst.l sq+408
	jeq .L2530
	tst.l %d0
	jeq .L2531
	tst.l st+1058
	jne .L2532
.L2531:
	move.l %d2,%d1
	mov3q.l #2,%d5
	add.l #-80,%d1
	cmp.l %d1,%d5
	jcs .L2533
	move.l st+920,%d1
	move.l st+208,%d5
	move.l st+248,%d7
	or.l st+216,%d1
	or.l st+240,%d5
	or.l %d7,%d1
	move.l %d5,%a1
	btst #0,%d1
	jeq .L2534
	move.l sq+484,%d5
	tst.l %d0
	jeq .L2587
	move.l st+232,%d1
.L2535:
	or.l %d5,%d1
	mvz.w %d1,%d1
	move.l %d1,44(%sp)
	moveq #16,%d1
	and.l sq+500,%d1
	or.l 44(%sp),%d1
	jne .L2537
	tst.l %d0
	jeq .L2534
	btst #4,%d7
	jne .L2537
.L2534:
	move.l %a1,%d1
	or.l st+912,%d1
	move.w %d1,%ccr
	jeq .L2539
	tst.b u46+48.l
	jeq .L2540
.L2539:
	move.l sq+484,%d5
	tst.l %d0
	jeq .L2588
	move.l st+232,%d1
.L2541:
	or.l %d5,%d1
	tst.w %d1
	jeq .L2540
.L2537:
	move.l %a1,%d1
	or.l st+912,%d1
	move.w %d1,%ccr
	jeq .L2542
	tst.b u46+48.l
	jeq .L2543
.L2542:
	addq.l #1,u46+36
.L2543:
	tst.l %d0
	jeq .L2544
	move.l st+232,%d0
.L2544:
	or.l %d5,%d0
	move.l %d0,%d1
	mvz.w %d1,%d1
	tst.w %d0
	jeq .L2545
	moveq #80,%d4
	cmp.l %d2,%d4
	jeq .L2589
	moveq #82,%d5
	cmp.l %d2,%d5
	jne .L2590
	moveq #14,%d0
.L2546:
	mvs.b 1079807236,%d2
	or.l %d3,st+272
	move.l %d2,-(%sp)
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	mov3q.l #1,-(%sp)
	move.l %d0,-(%sp)
	jsr ed_queue_pat
	lea (20,%sp),%sp
	jra .L2425
.L2587:
	clr.l %d1
	jra .L2535
.L2588:
	clr.l %d1
	jra .L2541
.L2545:
	moveq #80,%d7
	cmp.l %d2,%d7
	jeq .L2591
	moveq #82,%d0
	cmp.l %d2,%d0
	jne .L2592
	moveq #10,%d0
	jra .L2546
.L2589:
	moveq #13,%d0
	jra .L2546
.L2590:
	moveq #15,%d0
	jra .L2546
.L2591:
	moveq #9,%d0
	jra .L2546
.L2592:
	moveq #11,%d0
	jra .L2546
.L2581:
	cmp.l #132,%d2
	jne .L2547
	move.l st+216,%d0
	move.l %d0,%d1
	or.l st+920,%d1
	btst #0,%d1
	jeq .L2547
	moveq #16,%d4
	or.l %d0,%d4
	addq.l #1,ed+84
	move.l %d4,st+216
	jra .L2422
.L2548:
	move.l %d4,%d0
	and.l #240,%d0
	tst.l %d0
	jeq .L2550
	and.l #251,%d4
	cmp.l #128,%d4
	jeq .L2550
	moveq #48,%d7
	cmp.l %d2,%d7
	jne .L2551
.L2550:
	lea sq,%a0
	addq.l #1,sq+460
	cmp.l #128,%d2
	jne .L2552
	mov3q.l #1,%d0
	or.l %d0,st+920
.L2553:
	mov3q.l #1,-(%sp)
	cmp.l #128,%d2
	sne %d7
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	addq.l #8,%sp
.L2785:
	mvs.b %d7,%d7
	neg.l %d7
	jra .L2418
.L2552:
	lea (121,%a6),%a6
	or.l %d3,(%a0,%a6.l*4)
	jra .L2553
.L2558:
	move.l %d2,%d0
	add.l #-66,%d0
	lsr.l #1,%d0
	jne .L2561
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L2560
	move.l masks,%d5
	cmp.l nk+20.l,%d5
	jeq .L2559
.L2560:
	cmp.l #181,%d2
	jne .L2565
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L2569
.L2565:
	tst.l mask_set
	jeq .L2570
	lea mask_keys,%a0
	move.l (%a0,%a6.l*4),%d0
	move.l 56(%sp),%d1
	btst %d1,%d0
	jeq .L2569
.L2570:
	cmp.l #128,%d2
	jne .L2767
	mov3q.l #2,%d7
	jra .L2571
.L2562:
	addq.l #1,nk+24
	jra .L2563
.L2593:
	mov3q.l #1,%d0
	jra .L2566
.L2768:
	move.l %d2,%d0
	mov3q.l #2,%d7
	add.l #-80,%d0
	cmp.l %d0,%d7
	jcs .L2560
.L2568:
	addq.l #1,st+944
.L2554:
	lea (50,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
	jra .L2422
.L2767:
	mov3q.l #1,%d7
.L2571:
	addq.l #1,st+936
	mov3q.l #2,%d5
	cmp.l %d7,%d5
	jne .L2573
	lea (226,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
.L2574:
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	addq.l #8,%sp
	mov3q.l #2,%d0
	cmp.l %d7,%d0
	sne %d7
	jra .L2785
.L2573:
	move.l 52(%sp),%a0
	or.l %d3,(%a2,%a0.l*4)
	jra .L2574
.L2521:
	tst.l %d0
	jeq .L2511
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-80,%d0
	cmp.l %d0,%d1
	jcc .L2511
	add.l #-64,%d0
	moveq #11,%d7
	cmp.l %d0,%d7
	jcc .L2511
.L2522:
	mov3q.l #4,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr splash_end
	addq.l #8,%sp
	mov3q.l #5,%d0
	cmp.l %d5,%d0
	jcs .L2511
	or.l %d3,st+272
	jra .L2425
.L2561:
	moveq #69,%d0
	cmp.l %d2,%d0
	jne .L2768
	tst.l mask_set
	jeq .L2564
	lea mask_keys+8,%a0
	btst #5,3(%a0)
	jeq .L2565
.L2564:
	lea st+232,%a1
	clr.l %d1
	sub.l %a0,%a0
.L2567:
	tst.l (%a1)+
	jne .L2593
	tst.l 668(%a1)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L2566:
	or.l %d0,%d1
	addq.l #1,%a0
	moveq #8,%d0
	cmp.l %a0,%d0
	jne .L2567
	move.l st+216,%d0
	mov3q.l #1,%d4
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d4,%d0
	or.l %d1,%d0
	jne .L2565
	moveq #32,%d5
	or.l %d5,st+240
	addq.l #1,st+936
	mov3q.l #1,nk
	jra .L2425
.L2557:
	moveq #69,%d1
	cmp.l %d2,%d1
	jeq .L2569
	add.l #-80,%d2
	mov3q.l #2,%d4
	cmp.l %d2,%d4
	jcc .L2568
.L2569:
	addq.l #1,st+940
	jra .L2554
.L2530:
	tst.l %d0
	jne .L2532
.L2551:
	tst.b sv.l
	jeq .L2532
	moveq #111,%d1
	cmp.l %d2,%d1
	jcc .L2554
	moveq #119,%d4
	cmp.l %d2,%d4
	jcs .L2532
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
	jra .L2770
.L2540:
	tst.l %d0
	jne .L2555
.L2547:
	tst.w sq+486.l
	jeq .L2548
	move.l %d2,%d0
	mov3q.l #5,%d5
	add.l #-48,%d0
	cmp.l %d0,%d5
	jcc .L2549
	moveq #16,%d7
	cmp.l %d2,%d7
	jeq .L2549
	add.l #-20,%d0
	mov3q.l #1,%d1
	cmp.l %d0,%d1
	jcc .L2549
	add.l #-44,%d0
	lsr.l #3,%d0
	jne .L2548
.L2549:
	or.l %d3,(%a5,%d6.l*4)
	addq.l #1,st+1054
	jra .L2775
.L2533:
	tst.l %d0
	jeq .L2581
.L2532:
	move.l %d2,%d0
	moveq #11,%d5
	add.l #-144,%d0
	cmp.l %d0,%d5
	jcs .L2555
	moveq #64,%d0
	and.l st+248,%d0
	tst.l %d0
	jeq .L2555
	move.l tk+8,%d0
	tst.l %d0
	jne .L2555
.L2556:
	lea (%a4,%d0.l),%a0
	moveq #32,%d1
	move.l (%a0),64(%sp,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L2556
	moveq #-122,%d4
	mov3q.l #1,%d5
	or.l %d5,80(%sp)
	mov3q.l #1,tk+8
	addq.l #1,tk+12
	move.b %d4,79(%sp)
	pea 64(%sp)
	move.l %a3,-(%sp)
	jsr 1074397898
	addq.l #8,%sp
.L2555:
	tst.l st+4
	jeq .L2554
	tst.l st+1058
	jne .L2557
	moveq #68,%d7
	cmp.l %d2,%d7
	jne .L2558
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
	move.l st+232,%d1
	mvz.w %d1,%d1
	or.l %d1,%d0
	jeq .L2565
.L2559:
	addq.l #1,st+936
	moveq #68,%d7
	cmp.l %d2,%d7
	jne .L2562
	addq.l #1,nk+12
.L2563:
	or.l %d3,st+240
	jra .L2775
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
	jne .L2787
	tst.l sq+408
	jeq .L2788
	tst.w sq+486.l
	jeq .L2788
	mov3q.l #7,%d0
	cmp.l %a6,%d0
	jcs .L2788
	tst.b 20(%a0)
	jne .L2816
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+920,%d0
	and.l %d1,%d0
.L2789:
	add.l %d2,96(%a2,%a6.l*4)
	move.b %d0,st+160
	addq.l #1,sq+464
	jsr flush
.L2790:
	mov3q.l #1,%d2
	jra .L2793
.L2816:
	mov3q.l #1,%d0
	jra .L2789
.L2788:
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr ls_enc
	addq.l #8,%sp
	move.l %d0,%d2
	tst.l %d0
	jne .L2793
	moveq #8,%d3
	cmp.l %a6,%d3
	jne .L2792
	tst.b sv+8.l
	jeq .L2792
	move.l st+8,%a0
	addq.l #1,st+1086
	lea (47,%a0),%a0
	move.l %a0,st+1082
.L2792:
	tst.l st+972
	jeq .L2793
	mov3q.l #5,-(%sp)
	move.l 76(%sp),%a1
	move.l 32(%a1),-(%sp)
	jsr splash_end
	addq.l #8,%sp
.L2793:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 44(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L2786
	move.l %d0,st+332
.L2786:
	move.l %d2,%d0
	movem.l (%sp),#23804
	lea (68,%sp),%sp
	rts
.L2787:
	tst.l st+1058
	jeq .L2794
	addq.l #1,st+952
.L2795:
	clr.l %d2
	jra .L2793
.L2794:
	tst.l mask_set
	jeq .L2796
	moveq #15,%d0
	cmp.l %a6,%d0
	jcs .L2797
	move.l mask_enc,%d0
	move.l %a6,%d1
	btst %d1,%d0
	jne .L2796
.L2797:
	addq.l #1,st+952
	moveq #8,%d3
	cmp.l %a6,%d3
	jne .L2795
	move.l st+8,%a0
	addq.l #1,st+1086
	lea (47,%a0),%a0
	move.l %a0,st+1082
	jra .L2795
.L2796:
	addq.l #1,st+948
	tst.b 20(%a0)
	jne .L2817
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
.L2799:
	move.b %d0,st+160
	moveq #15,%d3
	cmp.l %a6,%d3
	jcs .L2790
	move.l %a6,%d4
	add.l #24,%d4
	add.l %d2,(%a2,%d4.l*4)
	tst.l st+64
	jne .L2801
	move.l #-66650100,%a0
	move.l (%a0),st+64
.L2801:
	tst.l st+388
	jne .L2802
	move.l #-66650100,%a1
	lea commits,%a0
	move.l (%a1),st+388
	move.l (%a0),st+392
.L2802:
	move.l %a6,%d5
	add.l #122,%d5
	lea bind_gen,%a4
	move.l (%a4,%a6.l*4),%d6
	move.l (%a2,%d5.l*4),%a3
	cmp.l %d6,%a3
	jeq .L2805
	btst #0,%d6
	jne .L2805
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
	jne .L2805
	move.l %d3,%d0
	move.l %a6,%d1
	add.l #st+552,%d0
	add.l #102,%d1
	tst.l (%a2,%d1.l*4)
	jeq .L2818
	move.l %d0,%a1
	move.b 48(%sp),%d3
	move.b (%a1),%d1
	eor.l %d1,%d3
	tst.b %d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
.L2807:
	mov3q.l #5,-(%sp)
	move.l %d7,-(%sp)
	move.l %d0,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	tst.l %d3
	jne .L2808
	lea (%a2,%a6.l),%a0
	move.b 49(%sp),472(%a0)
.L2808:
	move.l %d6,(%a2,%d5.l*4)
	move.l %d6,%a3
.L2805:
	tst.l %a3
	jeq .L2809
	move.l %a6,%d0
	moveq #20,%d3
	muls.l %d3,%d0
	lea (%a2,%d0.l),%a0
	mvz.b 552(%a0),%d1
	lsr.l #6,%d1
	jne .L2809
	lea (102,%a6),%a1
	add.l #st,%a6
	tst.l (%a2,%a1.l*4)
	jne .L2810
	move.b 553(%a0),472(%a6)
.L2810:
	move.l %d0,%a0
	add.l #st+556,%a0
	move.b (%a0),%d1
	mvz.b 472(%a6),%d3
	btst #0,%d1
	jeq .L2819
	tst.b st+160.l
	jne .L2820
.L2819:
	mov3q.l #1,%d1
.L2811:
	muls.l %d1,%d2
	move.l %d0,%a0
	add.l #st+554,%a0
	mvz.b (%a0),%d1
	add.l %d3,%d2
	cmp.l %d2,%d1
	jle .L2812
	move.l %d1,%d2
.L2812:
	move.l %d0,%a0
	add.l #st+555,%a0
	mvz.b (%a0),%d1
	cmp.l %d2,%d1
	jge .L2813
	move.l %d1,%d2
.L2813:
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
	jne .L2814
	move.l #-66650100,%a1
	move.l (%a1),st+368
.L2814:
	moveq #1,%d0
	move.l 72(%sp),%a1
	move.l 32(%a1),%a0
	move.b %d0,32(%a0)
.L2809:
	jsr flush
	tst.l (%a2,%d4.l*4)
	jne .L2790
	addq.l #1,st+384
	jra .L2790
.L2817:
	mov3q.l #1,%d0
	jra .L2799
.L2818:
	clr.l %d3
	jra .L2807
.L2820:
	moveq #8,%d1
	jra .L2811
	.size	rui_enc, .-rui_enc
	.align	2
	.globl	pj_write
	.type	pj_write, @function
pj_write:
	move.l 4(%sp),%d0
	move.l 8(%sp),%d1
	cmp.l #1074464814,%d0
	jeq .L2830
	cmp.l #1073958730,%d0
	jeq .L2830
	lea pj_push,%a0
	cmp.l #1074076072,%d0
	jne .L2832
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #5,-(%sp)
.L2845:
	jsr (%a0)
	lea (12,%sp),%sp
.L2830:
	rts
.L2832:
	cmp.l #1074076390,%d0
	jeq .L2833
	cmp.l #1074076276,%d0
	jne .L2834
.L2833:
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #3,-(%sp)
	jra .L2845
.L2834:
	cmp.l #1073959500,%d0
	jne .L2835
	mvz.b pj+137,%d0
	move.l %d1,-(%sp)
	move.l %d0,%a1
	pea -1(%a1)
	mov3q.l #2,-(%sp)
	jra .L2845
.L2835:
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #7,-(%sp)
	jra .L2845
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
	jcs .L2849
	addq.l #1,%d0
.L2848:
	move.b %d0,pj+137
	rts
.L2849:
	clr.b %d0
	jra .L2848
	.size	pj_copy, .-pj_copy
	.align	2
	.globl	pj_save
	.type	pj_save, @function
pj_save:
	move.l 4(%sp),%d0
	tst.l %d0
	jlt .L2850
	move.b 1079807565,%d1
	move.l %d0,-(%sp)
	mvs.b %d1,%d1
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr pj_push
	lea (12,%sp),%sp
.L2850:
	rts
	.size	pj_save, .-pj_save
	.align	2
	.globl	pj_activate
	.type	pj_activate, @function
pj_activate:
	move.l 4(%sp),%d0
	tst.l %d0
	jlt .L2852
	move.l #1074457822,%d1
	cmp.l 8(%sp),%d1
	jne .L2852
	move.l #1074479198,%d1
	cmp.l 12(%sp),%d1
	jne .L2852
	move.l %d0,12(%sp)
	moveq #10,%d0
	mov3q.l #-1,8(%sp)
	move.l %d0,4(%sp)
	jra pj_push
.L2852:
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
	jge .L2855
	moveq #127,%d0
.L2856:
	move.l %d0,-(%sp)
	pea 65.w
	jsr pj_push
	lea (12,%sp),%sp
	rts
.L2855:
	tst.l %d0
	jge .L2856
	clr.l %d0
	jra .L2856
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
	.type	CSWTCH.599, @object
	.size	CSWTCH.599, 7
CSWTCH.599:
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
	.type	CSWTCH.597, @object
	.size	CSWTCH.597, 40
CSWTCH.597:
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
	.type	CSWTCH.526, @object
	.size	CSWTCH.526, 6
CSWTCH.526:
	.byte	4
	.byte	5
	.byte	0
	.byte	3
	.byte	1
	.byte	2
	.zero	2
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
.LC8:
	.string	"Tune"
.LC9:
	.string	"TUNE"
.LC10:
	.string	"Fine Tune"
.LC11:
	.string	"FINE"
.LC12:
	.string	"-"
.LC13:
	.string	"Play Mode"
.LC14:
	.string	"PLAY"
.LC15:
	.string	"Start"
.LC16:
	.string	"STRT"
.LC17:
	.string	"End"
.LC18:
	.string	"END"
.LC19:
	.string	"Loop"
.LC20:
	.string	"LOOP"
.LC21:
	.string	"Level"
.LC22:
	.string	"LEV"
	.text
	.align	2
	.type	cu_sap2k, @object
	.size	cu_sap2k, 128
cu_sap2k:
	.long	.LC8
	.long	.LC9
	.word	39
	.byte	0
	.byte	64
	.word	0
	.byte	4
	.byte	124
	.long	.LC10
	.long	.LC11
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC12
	.long	.LC12
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC13
	.long	.LC14
	.word	410
	.byte	33
	.byte	0
	.word	265
	.zero	2
	.long	.LC15
	.long	.LC16
	.word	410
	.byte	0
	.byte	0
	.word	0
	.byte	0
	.byte	120
	.long	.LC17
	.long	.LC18
	.word	410
	.byte	0
	.byte	120
	.word	0
	.byte	0
	.byte	120
	.long	.LC19
	.long	.LC20
	.word	410
	.byte	19
	.byte	0
	.word	0
	.byte	0
	.byte	120
	.long	.LC21
	.long	.LC22
	.word	101
	.byte	0
	.byte	100
	.word	0
	.zero	2
	.text
.LC23:
	.string	"CC 1 Value"
.LC24:
	.string	"VAL1"
.LC25:
	.string	"CC 2 Value"
.LC26:
	.string	"VAL2"
.LC27:
	.string	"CC 3 Value"
.LC28:
	.string	"VAL3"
.LC29:
	.string	"CC 4 Value"
.LC30:
	.string	"VAL4"
.LC31:
	.string	"CC 1 Select"
.LC32:
	.string	"SEL1"
.LC33:
	.string	"CC 2 Select"
.LC34:
	.string	"SEL2"
.LC35:
	.string	"CC 3 Select"
.LC36:
	.string	"SEL3"
.LC37:
	.string	"CC 4 Select"
.LC38:
	.string	"SEL4"
	.text
	.align	2
	.type	cu_mip2k, @object
	.size	cu_mip2k, 128
cu_mip2k:
	.long	.LC23
	.long	.LC24
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC25
	.long	.LC26
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC27
	.long	.LC28
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC29
	.long	.LC30
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC31
	.long	.LC32
	.word	410
	.byte	32
	.byte	0
	.word	0
	.zero	2
	.long	.LC33
	.long	.LC34
	.word	410
	.byte	32
	.byte	0
	.word	0
	.zero	2
	.long	.LC35
	.long	.LC36
	.word	410
	.byte	32
	.byte	0
	.word	0
	.zero	2
	.long	.LC37
	.long	.LC38
	.word	410
	.byte	32
	.byte	0
	.word	0
	.zero	2
	.text
.LC39:
	.string	"Destination"
.LC40:
	.string	"DST"
.LC41:
	.string	"Channel"
.LC42:
	.string	"CHAN"
.LC43:
	.string	"Bank"
.LC44:
	.string	"BANK"
.LC45:
	.string	"Sub Bank"
.LC46:
	.string	"SBNK"
.LC47:
	.string	"Program"
.LC48:
	.string	"PROG"
.LC49:
	.string	"Pitch Bend"
.LC50:
	.string	"PB"
.LC51:
	.string	"Aftertouch"
.LC52:
	.string	"AT"
.LC53:
	.string	"Mod Wheel"
.LC54:
	.string	"MW"
	.text
	.align	2
	.type	cu_mik, @object
	.size	cu_mik, 128
cu_mik:
	.long	.LC39
	.long	.LC40
	.word	410
	.byte	27
	.byte	32
	.word	260
	.zero	2
	.long	.LC41
	.long	.LC42
	.word	410
	.byte	28
	.byte	0
	.word	272
	.zero	2
	.long	.LC43
	.long	.LC44
	.word	410
	.byte	30
	.byte	0
	.word	0
	.zero	2
	.long	.LC45
	.long	.LC46
	.word	410
	.byte	30
	.byte	0
	.word	0
	.zero	2
	.long	.LC47
	.long	.LC48
	.word	410
	.byte	19
	.byte	0
	.word	0
	.zero	2
	.long	.LC49
	.long	.LC50
	.word	410
	.byte	29
	.byte	0
	.word	0
	.zero	2
	.long	.LC51
	.long	.LC52
	.word	410
	.byte	31
	.byte	0
	.word	0
	.zero	2
	.long	.LC53
	.long	.LC54
	.word	410
	.byte	31
	.byte	0
	.word	0
	.zero	2
	.text
.LC55:
	.string	"Stutter"
.LC56:
	.string	"STUT"
.LC57:
	.string	"Stutter Len"
.LC58:
	.string	"SLEN"
.LC59:
	.string	"Tape"
.LC60:
	.string	"TAPE"
.LC61:
	.string	"Tape Time"
.LC62:
	.string	"TTIM"
.LC63:
	.string	"Attack"
.LC64:
	.string	"ATK"
.LC65:
	.string	"Decay"
.LC66:
	.string	"DEC"
.LC67:
	.string	"Direction"
.LC68:
	.string	"DIR"
	.text
	.align	2
	.type	cu_cpp2k, @object
	.size	cu_cpp2k, 128
cu_cpp2k:
	.long	.LC55
	.long	.LC56
	.word	410
	.byte	20
	.byte	0
	.word	272
	.zero	2
	.long	.LC57
	.long	.LC58
	.word	410
	.byte	25
	.byte	0
	.word	0
	.zero	2
	.long	.LC59
	.long	.LC60
	.word	410
	.byte	22
	.byte	0
	.word	260
	.zero	2
	.long	.LC61
	.long	.LC62
	.word	410
	.byte	25
	.byte	0
	.word	0
	.zero	2
	.long	.LC63
	.long	.LC64
	.word	410
	.byte	25
	.byte	0
	.word	0
	.zero	2
	.long	.LC65
	.long	.LC66
	.word	410
	.byte	26
	.byte	0
	.word	0
	.zero	2
	.long	.LC67
	.long	.LC68
	.word	410
	.byte	23
	.byte	0
	.word	259
	.zero	2
	.long	.LC19
	.long	.LC20
	.word	410
	.byte	24
	.byte	0
	.word	260
	.zero	2
	.text
.LC69:
	.string	"Sample"
.LC70:
	.string	"SRC"
.LC71:
	.string	"Slice"
.LC72:
	.string	"SLC"
.LC73:
	.string	"Morph"
.LC74:
	.string	"MRPH"
.LC75:
	.string	"Shuffle Seed"
.LC76:
	.string	"SEED"
.LC77:
	.string	"Neighbour"
.LC78:
	.string	"NBR"
.LC79:
	.string	"Velocity"
.LC80:
	.string	"VEL"
	.text
	.align	2
	.type	cu_cpk, @object
	.size	cu_cpk, 128
cu_cpk:
	.long	.LC69
	.long	.LC70
	.word	410
	.byte	9
	.byte	10
	.word	2944
	.zero	2
	.long	.LC71
	.long	.LC72
	.word	410
	.byte	16
	.byte	0
	.word	320
	.zero	2
	.long	.LC8
	.long	.LC9
	.word	40
	.byte	17
	.byte	64
	.word	0
	.zero	2
	.long	.LC73
	.long	.LC74
	.word	410
	.byte	18
	.byte	0
	.word	0
	.zero	2
	.long	.LC75
	.long	.LC76
	.word	410
	.byte	19
	.byte	0
	.word	0
	.zero	2
	.long	.LC77
	.long	.LC78
	.word	410
	.byte	18
	.byte	0
	.word	0
	.zero	2
	.long	.LC79
	.long	.LC80
	.word	410
	.byte	18
	.byte	64
	.word	0
	.zero	2
	.long	.LC21
	.long	.LC22
	.word	101
	.byte	0
	.byte	100
	.word	0
	.zero	2
	.text
.LC81:
	.string	"Release"
.LC82:
	.string	"REL"
	.text
	.align	2
	.type	cu_lip2k, @object
	.size	cu_lip2k, 128
cu_lip2k:
	.long	.LC81
	.long	.LC82
	.word	410
	.byte	0
	.byte	77
	.word	0
	.zero	2
	.long	.LC12
	.long	.LC12
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC12
	.long	.LC12
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC12
	.long	.LC12
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC12
	.long	.LC12
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC12
	.long	.LC12
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC12
	.long	.LC12
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC12
	.long	.LC12
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.text
.LC83:
	.string	"Input"
.LC84:
	.string	"INPT"
.LC85:
	.string	"Gain"
.LC86:
	.string	"GAIN"
.LC87:
	.string	"Gate"
.LC88:
	.string	"GATE"
.LC89:
	.string	"Hold"
.LC90:
	.string	"HOLD"
.LC91:
	.string	"Monitor"
.LC92:
	.string	"MON"
.LC93:
	.string	"Sustain"
.LC94:
	.string	"SUS"
	.text
	.align	2
	.type	cu_lik, @object
	.size	cu_lik, 128
cu_lik:
	.long	.LC83
	.long	.LC84
	.word	410
	.byte	13
	.byte	80
	.word	260
	.zero	2
	.long	.LC85
	.long	.LC86
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC87
	.long	.LC88
	.word	101
	.byte	15
	.byte	0
	.word	0
	.zero	2
	.long	.LC89
	.long	.LC90
	.word	410
	.byte	0
	.byte	28
	.word	0
	.zero	2
	.long	.LC91
	.long	.LC92
	.word	410
	.byte	14
	.byte	0
	.word	258
	.zero	2
	.long	.LC63
	.long	.LC64
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC65
	.long	.LC66
	.word	410
	.byte	0
	.byte	77
	.word	0
	.zero	2
	.long	.LC93
	.long	.LC94
	.word	101
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.text
.LC95:
	.string	"Hold/Freeze"
.LC96:
	.string	"Animate"
.LC97:
	.string	"ANIM"
.LC98:
	.string	"Chord"
.LC99:
	.string	"CHD"
.LC100:
	.string	"Inversion"
.LC101:
	.string	"INV"
.LC102:
	.string	"Spread"
.LC103:
	.string	"SPR"
.LC104:
	.string	"Voices"
.LC105:
	.string	"VOI"
	.text
	.align	2
	.type	cu_grp2k, @object
	.size	cu_grp2k, 128
cu_grp2k:
	.long	.LC63
	.long	.LC64
	.word	410
	.byte	0
	.byte	10
	.word	0
	.zero	2
	.long	.LC81
	.long	.LC82
	.word	410
	.byte	0
	.byte	60
	.word	0
	.zero	2
	.long	.LC95
	.long	.LC90
	.word	410
	.byte	10
	.byte	0
	.word	0
	.zero	2
	.long	.LC96
	.long	.LC97
	.word	410
	.byte	11
	.byte	0
	.word	0
	.zero	2
	.long	.LC98
	.long	.LC99
	.word	410
	.byte	3
	.byte	0
	.word	1552
	.zero	2
	.long	.LC100
	.long	.LC101
	.word	410
	.byte	4
	.byte	0
	.word	1540
	.zero	2
	.long	.LC102
	.long	.LC103
	.word	410
	.byte	5
	.byte	0
	.word	1539
	.zero	2
	.long	.LC104
	.long	.LC105
	.word	410
	.byte	6
	.byte	0
	.word	1543
	.zero	2
	.text
.LC106:
	.string	"Source"
.LC107:
	.string	"Position"
.LC108:
	.string	"POS"
.LC109:
	.string	"Spray"
.LC110:
	.string	"SPRY"
.LC111:
	.string	"Grain Size"
.LC112:
	.string	"SIZE"
.LC113:
	.string	"Density"
.LC114:
	.string	"DENS"
.LC115:
	.string	"Pitch Rand"
.LC116:
	.string	"PRND"
.LC117:
	.string	"Reverse"
.LC118:
	.string	"REV"
.LC119:
	.string	"WIN"
	.text
	.align	2
	.type	cu_grk, @object
	.size	cu_grk, 128
cu_grk:
	.long	.LC106
	.long	.LC70
	.word	410
	.byte	9
	.byte	10
	.word	2944
	.zero	2
	.long	.LC107
	.long	.LC108
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC109
	.long	.LC110
	.word	410
	.byte	0
	.byte	20
	.word	0
	.zero	2
	.long	.LC111
	.long	.LC112
	.word	410
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC113
	.long	.LC114
	.word	410
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC115
	.long	.LC116
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC117
	.long	.LC118
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC5
	.long	.LC119
	.word	410
	.byte	8
	.byte	0
	.word	260
	.zero	2
	.text
.LC120:
	.string	"Env>Pos"
.LC121:
	.string	"ENV"
.LC122:
	.string	"Table B"
.LC123:
	.string	"TBLB"
.LC124:
	.string	"Position B"
.LC125:
	.string	"POSB"
.LC126:
	.string	"Mix A-B"
.LC127:
	.string	"MIX"
.LC128:
	.string	"Filter Type"
.LC129:
	.string	"FTYP"
	.text
	.align	2
	.type	cu_wtp2k, @object
	.size	cu_wtp2k, 128
cu_wtp2k:
	.long	.LC63
	.long	.LC64
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC65
	.long	.LC66
	.word	410
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC93
	.long	.LC94
	.word	410
	.byte	0
	.byte	100
	.word	0
	.zero	2
	.long	.LC120
	.long	.LC121
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC122
	.long	.LC123
	.word	410
	.byte	12
	.byte	0
	.word	2944
	.zero	2
	.long	.LC124
	.long	.LC125
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC126
	.long	.LC127
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC128
	.long	.LC129
	.word	410
	.byte	34
	.byte	0
	.word	264
	.zero	2
	.text
.LC130:
	.string	"Table"
.LC131:
	.string	"TBL"
.LC132:
	.string	"Warp"
.LC133:
	.string	"WARP"
.LC134:
	.string	"Amount"
.LC135:
	.string	"AMT"
.LC136:
	.string	"Unison"
.LC137:
	.string	"UNI"
.LC138:
	.string	"Sub Osc"
.LC139:
	.string	"SUB"
.LC140:
	.string	"Cutoff"
.LC141:
	.string	"CUT"
.LC142:
	.string	"Resonance"
.LC143:
	.string	"RES"
	.text
	.align	2
	.type	cu_wtk, @object
	.size	cu_wtk, 128
cu_wtk:
	.long	.LC130
	.long	.LC131
	.word	410
	.byte	12
	.byte	1
	.word	2944
	.zero	2
	.long	.LC107
	.long	.LC108
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC132
	.long	.LC133
	.word	410
	.byte	7
	.byte	0
	.word	265
	.zero	2
	.long	.LC134
	.long	.LC135
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC136
	.long	.LC137
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC138
	.long	.LC139
	.word	101
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC140
	.long	.LC141
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC142
	.long	.LC143
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.align	2
	.type	cu_p2k, @object
	.size	cu_p2k, 128
cu_p2k:
	.long	.LC8
	.long	.LC9
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC10
	.long	.LC11
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC15
	.long	.LC16
	.word	410
	.byte	0
	.byte	0
	.word	0
	.zero	2
	.long	.LC19
	.long	.LC20
	.word	410
	.byte	2
	.byte	0
	.word	259
	.zero	2
	.long	.LC98
	.long	.LC99
	.word	410
	.byte	3
	.byte	0
	.word	1552
	.zero	2
	.long	.LC100
	.long	.LC101
	.word	410
	.byte	4
	.byte	0
	.word	1540
	.zero	2
	.long	.LC102
	.long	.LC103
	.word	410
	.byte	5
	.byte	0
	.word	1539
	.zero	2
	.long	.LC104
	.long	.LC105
	.word	410
	.byte	6
	.byte	0
	.word	1543
	.zero	2
	.text
.LC144:
	.string	"Instrument"
.LC145:
	.string	"INST"
.LC146:
	.string	"Release Trig"
.LC147:
	.string	"RTRG"
	.text
	.align	2
	.type	cu_srck, @object
	.size	cu_srck, 128
cu_srck:
	.long	.LC144
	.long	.LC145
	.word	410
	.byte	12
	.byte	0
	.word	2944
	.zero	2
	.long	.LC79
	.long	.LC80
	.word	410
	.byte	0
	.byte	127
	.word	0
	.zero	2
	.long	.LC21
	.long	.LC22
	.word	101
	.byte	0
	.byte	100
	.word	0
	.zero	2
	.long	.LC146
	.long	.LC147
	.word	410
	.byte	1
	.byte	0
	.word	258
	.zero	2
	.long	.LC63
	.long	.LC64
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC65
	.long	.LC66
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC93
	.long	.LC94
	.word	40
	.byte	0
	.byte	64
	.word	0
	.zero	2
	.long	.LC81
	.long	.LC82
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
	.type	cu_ftyp, @object
	.size	cu_ftyp, 40
cu_ftyp:
	.string	"DJ"
	.zero	2
	.string	"LP12"
	.string	"LP24"
	.string	"BP12"
	.string	"BP24"
	.string	"HP12"
	.string	"HP24"
	.string	"LDR"
	.zero	1
	.type	cu_warp, @object
	.size	cu_warp, 45
cu_warp:
	.string	"OFF"
	.zero	1
	.string	"SYNC"
	.string	"PWM"
	.zero	1
	.string	"FM"
	.zero	2
	.string	"FRMT"
	.string	"QNT"
	.zero	1
	.string	"BEND"
	.string	"SQZE"
	.string	"RM"
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
	.size	ls, 142
ls:
	.zero	142
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
	.local	ovm_col
	.comm	ovm_col,2,1
	.local	ovm_on
	.comm	ovm_on,1,1
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
.LC148:
	.string	"SoundBrowser"
.LC149:
	.string	"KitBrowserView"
.LC150:
	.string	"SongBrowserView"
.LC151:
	.string	"NameView"
.LC152:
	.string	"TapTempoView"
.LC153:
	.string	"ProjectManager"
.LC154:
	.string	"SoundManager"
.LC155:
	.string	"SampleManager"
.LC156:
	.string	"SongEditView"
.LC157:
	.string	"SoundSlotListView"
.LC158:
	.string	"SampleListView"
.LC159:
	.string	"TwoColumnMenu"
.LC160:
	.string	"SceneEditView"
.LC161:
	.string	"PerformanceEditView"
	.text
	.align	2
	.type	ov_names, @object
	.size	ov_names, 56
ov_names:
	.long	.LC148
	.long	.LC149
	.long	.LC150
	.long	.LC151
	.long	.LC152
	.long	.LC153
	.long	.LC154
	.long	.LC155
	.long	.LC156
	.long	.LC157
	.long	.LC158
	.long	.LC159
	.long	.LC160
	.long	.LC161
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
	.size	sv, 152
sv:
	.zero	152
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
	.size	pmo, 11636
pmo:
	.zero	11636
	.local	ms
	.comm	ms,276,4
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
	.comm	st,1112,4
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
	.local	ls_smpl
	.comm	ls_smpl,4,2
	.local	ls_host_p13
	.comm	ls_host_p13,4,2
	.local	ls_host_presets
	.comm	ls_host_presets,4,2
	.local	pc_req
	.comm	pc_req,6,1
	.local	pc_seq
	.comm	pc_seq,4,4
	.local	t_commit
	.comm	t_commit,4,4
	.local	host_rehello
	.comm	host_rehello,4,2
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
	.ident	"GCC: (GNU) 16.2.0"
