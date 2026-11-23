| Mod 0026 - remote UI: the Rytm as a terminal for Sidecar-drawn pages (M1).
| GENERATED from rui.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os); edit rui.c.
#NO_APP
	.file	"rui.c"
	.text
#APP
	.ifndef RAM_RUI_FRAME
.pushsection .bss
.balign 16
rui_frame_bss: .space 12560
.popsection
.set RAM_RUI_FRAME, rui_frame_bss
.set RAM_RUI_FRAME_SIZE, 12560
.set RAM_IN_AREA, 1
.endif

	.globl rui_big
.set rui_big, RAM_RUI_FRAME+8
.globl shadow
.set shadow, RAM_RUI_FRAME+8
.globl staging
.set staging, RAM_RUI_FRAME+0x408
.globl comp
.set comp, RAM_RUI_FRAME+0x808
.globl comp_in
.set comp_in, RAM_RUI_FRAME+0xc08
.globl ux
.set ux, RAM_RUI_NAMES+8
.globl pmo
.set pmo, RAM_RUI_PMO+8

	.ifndef RAM_RUI_NAMES
.pushsection .bss
.balign 16
rui_names_bss: .space 3984
.popsection
.set RAM_RUI_NAMES, rui_names_bss
.set RAM_RUI_NAMES_SIZE, 3984
.endif

	.ifndef RAM_RUI_PMO
.pushsection .bss
.balign 16
rui_pmo_bss: .space 10096
.popsection
.set RAM_RUI_PMO, rui_pmo_bss
.set RAM_RUI_PMO_SIZE, 10096
.endif

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
  moveq #4,%d0
  and.l ram_ok,%d0
  beq.s 2f
  jsr pmo_pre
  move.l (%sp),-(%sp)
  jsr 0x4009e790
  addq.l #4,%sp
  jsr pmo_post
  jmp 0x40120fb4
2:
  move.l (%sp),-(%sp)
  jsr 0x4009e790
  addq.l #4,%sp
  jmp 0x40120fb4
  .align 2
pmo_vel_det:
  move.l 60(%sp),%d0
  adda.l %a2,%a3
  moveq #4,%d1
  and.l ram_ok,%d1
  beq.s 3f
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
3:
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
	.type	ram_seal, @function
ram_seal:
	move.l %d2,-(%sp)
	move.l #1380011347,%d2
	move.l 8(%sp),%d1
	move.l %d1,%a0
	move.l 12(%sp),%d0
	subq.l #8,%d0
	add.l %d1,%d0
	move.l %d1,%a1
	eor.l %d1,%d2
	move.l #1380011347,%d1
	eor.l %d0,%d1
	move.l %d2,(%a0)+
	move.l %a0,%d2
	move.l %d0,%a0
	eor.l #1380011347,%d2
	move.l %d2,4(%a1)
	move.l %d1,(%a0)+
	move.l %a0,%d2
	move.l %d0,%a1
	eor.l #1380011347,%d2
	move.l %d2,4(%a1)
	move.l (%sp)+,%d2
	rts
	.size	ram_seal, .-ram_seal
	.align	2
	.type	ram_broken, @function
ram_broken:
	move.l 4(%sp),%a0
	move.l %a0,%d0
	eor.l #1380011347,%d0
	cmp.l (%a0),%d0
	jne .L4
	move.l %a0,%d0
	move.l #1380011347,%d1
	addq.l #4,%d0
	eor.l %d0,%d1
	cmp.l 4(%a0),%d1
	jne .L2
	move.l 8(%sp),%a1
	move.l #1380011347,%d1
	lea -8(%a0,%a1.l),%a1
	move.l %a1,%d0
	eor.l %d0,%d1
	cmp.l (%a1),%d1
	jne .L2
	addq.l #4,%d0
	move.l #1380011347,%d1
	eor.l %d0,%d1
	move.l 4(%a1),%a0
	cmp.l %a0,%d1
	jne .L2
	clr.l %d0
.L2:
	rts
.L4:
	move.l %a0,%d0
	jra .L2
	.size	ram_broken, .-ram_broken
	.align	2
	.type	copy32, @function
copy32:
	move.l %a2,-(%sp)
	mvz.w 18(%sp),%d1
	move.l 8(%sp),%a0
	clr.l %d0
	move.l 12(%sp),%a1
	lsl.l #2,%d1
.L6:
	cmp.l %d0,%d1
	jne .L7
	move.l (%sp)+,%a2
	rts
.L7:
	lea (%a1,%d0.l),%a2
	move.l (%a2),(%a0,%d0.l)
	addq.l #4,%d0
	jra .L6
	.size	copy32, .-copy32
	.align	2
	.type	txsx_wait, @function
txsx_wait:
	move.l txsx_test_on,%d0
	tst.l %d0
	jeq .L10
	move.l st+8,%d1
	sub.l txsx_test_end,%d1
	jmi .L10
	clr.l txsx_test_on
	clr.l %d0
.L10:
	move.l 1094562372,%d1
	or.l %d0,%d1
	jne .L12
	clr.l txsx_on
	clr.l txsx_gap
.L17:
	clr.l %d0
.L8:
	rts
.L12:
	tst.l txsx_on
	jeq .L14
	tst.l txsx_gap
	jeq .L15
	tst.l %d0
	jne .L15
.L14:
	lea st+8,%a0
	mov3q.l #1,txsx_on
	move.l (%a0),txsx_t0
	clr.l txsx_gap
.L16:
	mov3q.l #1,%d0
	jra .L8
.L15:
	move.l st+8,%d0
	moveq #39,%d1
	sub.l txsx_t0,%d0
	cmp.l %d0,%d1
	jge .L16
	addq.l #1,txsx_over
	jra .L17
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
	jcc .L22
.L24:
	moveq #127,%d0
.L21:
	move.l (%sp)+,%d2
	rts
.L22:
	mvz.w %d0,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #1076429692,%a0
	move.l 1076429868,%d0
	cmp.l (%a0),%d0
	jne .L24
	lea mr_flag,%a0
	moveq #127,%d2
	move.b (%a0,%d1.l),%d0
	mvz.b %d0,%d1
	cmp.l %d1,%d2
	jeq .L21
	move.l 8(%sp),%d1
	lea mr_voice,%a0
	move.b (%a0,%d1.l),%d1
	or.l %d1,%d0
	jra .L21
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
	jne .L29
	mov3q.l #7,%d5
	cmp.l %d0,%d5
	jge .L49
.L29:
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
	jne .L31
	moveq #10,%d4
	cmp.l %d0,%d4
	jeq .L50
	tst.l %d0
	jeq .L33
.L34:
	mov3q.l #7,%d4
	cmp.l %d0,%d4
	jge .L32
.L33:
	move.b (%a2),%d0
	mvz.b 1(%a2),%d1
	lsr.l #1,%d1
	lsl.l #7,%d0
	and.l #16256,%d0
	jra .L69
.L31:
	moveq #127,%d1
	moveq #43,%d5
	and.l -2147457096,%d1
	mulu.w #2531,%d1
	move.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0,%a1.l),%d1
	cmp.l %d1,%d5
	jne .L34
	move.l %d0,%d1
	mov3q.l #5,%d6
	subq.l #8,%d1
	cmp.l %d1,%d6
	jcs .L36
	lea CSWTCH.557,%a0
	mvs.b (%a0,%d1.l),%d0
.L32:
	move.l sv+80,%a0
	tst.l %a0
	jeq .L33
	move.l (%a0),%a3
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	move.l 156(%a3),%a0
	jsr (%a0)
	addq.l #8,%sp
	move.l %d0,%d4
	tst.l %d0
	jle .L33
	tst.l %d2
	jlt .L37
	mov3q.l #-1,-(%sp)
	move.l 160(%a3),%a0
	move.l sv+80,-(%sp)
	jsr (%a0)
	addq.l #8,%sp
	move.l %d0,%a0
	tst.l %d0
	jeq .L37
	move.l (%a0),%a1
	move.l %d2,-(%sp)
	move.l %d4,-(%sp)
	move.l 60(%a1),%a0
	move.l %d0,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	move.l %d0,%d2
	tst.l %d0
	jge .L51
.L37:
	mov3q.l #-1,-(%sp)
	move.l %d4,-(%sp)
	move.l 84(%a3),%a0
	clr.l %d3
	move.l sv+80,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	move.l %d0,%d2
.L38:
	move.l %d2,%d1
	move.l #1481856080,%d5
	asr.l #8,%d1
	cmp.l 1073848892.l,%d5
	jne .L39
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
	jcs .L39
	move.l %d0,%d6
	mvz.b %d6,%d6
	move.l %d6,%a1
	tst.b %d0
	jeq .L39
	mvz.b %d1,%d1
	tst.l %d3
	jne .L40
	moveq #127,%d5
	move.l %a0,%d0
	and.l %d5,%d0
	mov3q.l #1,%d5
	cmp.l %d4,%d5
	jne .L41
	move.l %d6,%d2
	muls.l %d0,%d2
	asr.l #7,%d2
	cmp.l %d1,%d2
	jne .L43
.L42:
	move.l %d0,%d1
	lsl.l #7,%d1
	mvz.b 1(%a2),%d0
	lsr.l #1,%d0
.L69:
	or.l %d1,%d0
	jra .L28
.L36:
	moveq #13,%d3
	cmp.l %d0,%d3
	jge .L33
	move.l %d1,%d0
	jra .L34
.L50:
	clr.l %d0
	jra .L32
.L51:
	mov3q.l #1,%d3
	jra .L38
.L41:
	cmp.l %d1,%d0
	jeq .L42
	subq.l #3,%d4
	tst.l %d4
	jne .L46
	jra .L48
.L40:
	mov3q.l #3,%d6
	cmp.l %d4,%d6
	jne .L45
.L48:
	move.l %d2,%d3
	asr.l #1,%d3
	moveq #112,%d0
	and.l %d0,%d3
.L46:
	moveq #127,%d4
	cmp.l %d1,%d4
	jlt .L53
	move.l %d1,%d0
	lsl.l #7,%d0
.L47:
	or.l %d3,%d0
.L28:
	movem.l (%sp),#3196
	lea (32,%sp),%sp
	rts
.L45:
	subq.l #1,%d4
	tst.l %d4
	jne .L52
.L43:
	mvs.w %d1,%d1
	move.l %a1,%d2
	lsl.l #7,%d1
	lea -1(%a1,%d1.l),%a0
	move.l %a0,%d1
	divs.l %d2,%d1
.L52:
	clr.l %d3
	jra .L46
.L53:
	move.w #16256,%d0
	jra .L47
.L39:
	lsl.l #7,%d1
	asr.l #1,%d2
	moveq #127,%d5
	and.l %d5,%d2
	and.l #16256,%d1
	move.l %d1,%d0
	or.l %d2,%d0
	jra .L28
.L49:
	clr.w %d0
	jra .L28
	.size	sv_word, .-sv_word
	.align	2
	.type	splash_end, @function
splash_end:
	tst.l st+972
	jeq .L70
	moveq #1,%d0
	lea (8,%sp),%a0
	move.l (%a0),st+988
	move.l 4(%sp),%a0
	clr.l st+972
	move.b %d0,32(%a0)
.L70:
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
	jne .L73
	move.b %d0,ps_pos
	mvz.b %d2,%d0
	move.b %d2,ps_hdr
	mov3q.l #1,%d3
	move.l %d0,%d1
	lsr.l #4,%d1
	cmp.l %d1,%d3
	jeq .L90
	moveq #11,%d3
	cmp.l %d1,%d3
	jeq .L75
	tst.l %d1
	jne .L91
.L94:
	mov3q.l #1,%d0
	jra .L74
.L75:
	cmp.l #179,%d0
	jhi .L76
.L77:
	mov3q.l #3,%d0
.L74:
	subq.l #1,%d0
	move.b %d0,ps_left
.L78:
	move.b %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L76:
	cmp.l #182,%d0
	jeq .L77
	cmp.l #180,%d0
	jeq .L92
	cmp.l #181,%d0
	jeq .L93
	cmp.l #184,%d0
	jeq .L94
.L91:
	mov3q.l #2,%d0
	jra .L74
.L90:
	moveq #10,%d0
	jra .L74
.L92:
	mov3q.l #6,%d0
	jra .L74
.L93:
	mov3q.l #5,%d0
	jra .L74
.L73:
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
	jcs .L79
	and.l %d3,%d0
	lea shs,%a0
	move.b %d2,(%a0,%d0.l)
	jra .L78
.L79:
	move.l %d0,%a0
	lea (80,%a0),%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #4,%d3
	cmp.l %a0,%d3
	jcs .L78
	mvz.b %d1,%d1
	mov3q.l #1,%d3
	cmp.l %d1,%d3
	jne .L81
	move.b %d2,ps_id
	jra .L78
.L81:
	move.b ps_id,%d3
	move.w %d3,%a0
	mvz.b %d3,%d3
	move.l %d3,%a1
	moveq #55,%d3
	cmp.l %a1,%d3
	jne .L82
	mvz.b %d0,%d3
	cmp.l #180,%d3
	jne .L83
	move.l %d1,%d0
	subq.l #2,%d0
.L84:
	lea sht,%a0
	move.b %d2,(%a0,%d0.l)
	tst.b ovt_on.l
	jeq .L78
	move.b ovt_col,%d2
	addq.l #1,uart_sub
	jra .L78
.L83:
	mov3q.l #3,%d1
	and.l %d1,%d0
	jra .L84
.L82:
	lea (-40,%a0),%a0
	move.w %a0,%d3
	mvz.b %d3,%d3
	move.l %d3,%a0
	mov3q.l #3,%d3
	cmp.l %a0,%d3
	jcs .L85
	move.w #43,%a0
	mvz.b %d0,%d3
	sub.l %a1,%a0
	cmp.l #180,%d3
	jne .L86
	subq.l #2,%d1
.L87:
	move.l %a0,%d0
	lsl.l #2,%d0
	move.l %d0,%a1
	add.l #shp,%a1
	mvz.b ovp_on,%d0
	move.b %d2,(%a1,%d1.l)
	move.l %a0,%d1
	btst %d1,%d0
	jeq .L78
	addq.l #1,uart_sub
	lea ovp_col,%a1
.L107:
	move.b (%a0,%a1.l),%d2
	jra .L78
.L86:
	mov3q.l #3,%d1
	and.l %d0,%d1
	jra .L87
.L85:
	moveq #15,%d3
	cmp.l %a1,%d3
	jcs .L78
	mvz.b %d0,%d3
	cmp.l #180,%d3
	jne .L88
	subq.l #2,%d1
.L89:
	move.l %a1,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #sh,%a0
	move.b %d2,(%a0,%d1.l)
	tst.b ov_on.l
	jeq .L78
	addq.l #1,uart_sub
	lea ov_col,%a0
	jra .L107
.L88:
	mov3q.l #3,%d1
	and.l %d0,%d1
	jra .L89
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
	jcc .L110
	addq.l #1,sq+384
.L109:
	move.l (%sp)+,%a2
	rts
.L110:
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
	jeq .L112
	move.l %a2,%d0
	addq.l #8,%d0
.L113:
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
	jra .L109
.L112:
	move.l %a2,%d0
	add.l #9,%d0
	move.b 19(%sp),8(%a2)
	jra .L113
	.size	sq_event, .-sq_event
	.align	2
	.type	sq_grid, @function
sq_grid:
	move.l 1100949720,%a0
	move.l %a0,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L117
	tst.b 353(%a0)
	jeq .L117
	tst.b 360(%a0)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L114:
	rts
.L117:
	clr.l %d0
	jra .L114
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
	jcs .L121
	moveq #39,%d1
	cmp.l %d0,%d1
	jcs .L122
.L123:
	clr.l %d0
	jra .L120
.L121:
	move.l %d0,%d1
	mov3q.l #6,%d0
	add.l #-46,%d1
	cmp.l %d1,%d0
	jcs .L123
	moveq #75,%d0
	lsr.l %d1,%d0
	mov3q.l #1,%d1
	and.l %d1,%d0
.L120:
	rts
.L122:
	tst.l ls_host_presets
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L120
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
	jeq .L127
	tst.l %d0
	jeq .L127
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
.L127:
	move.l %d3,-(%sp)
	jsr 1075557020
	move.l -32(%fp),%d2
	addq.l #4,%sp
	move.l -28(%fp),%d3
	unlk %fp
	rts
	.size	pm_popup, .-pm_popup
	.align	2
	.type	put35, @function
put35:
	move.l %d2,-(%sp)
	moveq #28,%d2
	move.l 12(%sp),%d1
	move.l %d1,%d0
	lsr.l %d2,%d0
	move.l 8(%sp),%a0
	moveq #21,%d2
	move.b %d0,(%a0)
	move.l %d1,%d0
	lsr.l %d2,%d0
	moveq #127,%d2
	and.l %d2,%d0
	moveq #14,%d2
	move.b %d0,1(%a0)
	move.l %d1,%d0
	lsr.l %d2,%d0
	moveq #127,%d2
	and.l %d2,%d0
	move.b %d0,2(%a0)
	move.l %d1,%d0
	lsr.l #7,%d0
	and.l %d2,%d1
	and.l %d2,%d0
	move.b %d1,4(%a0)
	move.b %d0,3(%a0)
	move.l %a0,%d0
	addq.l #5,%d0
	move.l (%sp)+,%d2
	rts
	.size	put35, .-put35
	.align	2
	.type	cu_tab, @function
cu_tab:
	move.l %d2,-(%sp)
	moveq #12,%d2
	move.l 8(%sp),%d1
	add.l #-40,%d1
	move.l 12(%sp),%d0
	cmp.l %d1,%d2
	jcs .L146
	move.w .L138(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&13
.L138:
	.word .L145-.L138
	.word .L146-.L138
	.word .L146-.L138
	.word .L144-.L138
	.word .L146-.L138
	.word .L146-.L138
	.word .L143-.L138
	.word .L142-.L138
	.word .L141-.L138
	.word .L140-.L138
	.word .L139-.L138
	.word .L146-.L138
	.word .L137-.L138
.L143:
	tst.l %d0
	jeq .L147
	move.l #cu_wtp2k,%d0
.L135:
	move.l (%sp)+,%d2
	rts
.L142:
	tst.l %d0
	jeq .L148
	move.l #cu_grp2k,%d0
	jra .L135
.L137:
	tst.l %d0
	jne .L154
	move.l #cu_srck,%d0
	jra .L135
.L141:
	tst.l %d0
	jeq .L150
	move.l #cu_lip2k,%d0
	jra .L135
.L140:
	tst.l %d0
	jeq .L151
	move.l #cu_cpp2k,%d0
	jra .L135
.L139:
	tst.l %d0
	jeq .L152
	move.l #cu_mip2k,%d0
	jra .L135
.L144:
	tst.l %d0
	jeq .L135
	move.l #cu_sap2k,%d0
	jra .L135
.L145:
	tst.l %d0
	jeq .L135
.L154:
	move.l #cu_p2k,%d0
	jra .L135
.L146:
	clr.l %d0
	jra .L135
.L147:
	move.l #cu_wtk,%d0
	jra .L135
.L148:
	move.l #cu_grk,%d0
	jra .L135
.L150:
	move.l #cu_lik,%d0
	jra .L135
.L151:
	move.l #cu_cpk,%d0
	jra .L135
.L152:
	move.l #cu_mik,%d0
	jra .L135
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
.L160:
	mvs.w (%a3,%a0.l),%d5
	cmp.l %d5,%d6
	jne .L156
	tst.l %d7
	jeq .L158
	mvz.b (%a1),%d1
.L158:
	add.l #16,%d0
	lea (16,%a1),%a1
	addq.l #2,%a0
	moveq #16,%d5
	cmp.l %a0,%d5
	jne .L160
	cmp.l #441,%d6
	jne .L161
	moveq #12,%d1
.L161:
	move.l %d3,%d0
	moveq #127,%d5
	cmp.l %d3,%d5
	jge .L162
	moveq #127,%d0
.L163:
	addq.l #1,cu+4
	subq.l #1,%d1
	moveq #32,%d5
	cmp.l %d1,%d5
	jcs .L164
	move.w .L166(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&33
.L166:
	.word .L196-.L166
	.word .L195-.L166
	.word .L194-.L166
	.word .L193-.L166
	.word .L192-.L166
	.word .L191-.L166
	.word .L190-.L166
	.word .L189-.L166
	.word .L186-.L166
	.word .L188-.L166
	.word .L187-.L166
	.word .L186-.L166
	.word .L185-.L166
	.word .L184-.L166
	.word .L183-.L166
	.word .L182-.L166
	.word .L181-.L166
	.word .L180-.L166
	.word .L179-.L166
	.word .L178-.L166
	.word .L164-.L166
	.word .L177-.L166
	.word .L176-.L166
	.word .L175-.L166
	.word .L174-.L166
	.word .L173-.L166
	.word .L172-.L166
	.word .L171-.L166
	.word .L170-.L166
	.word .L167-.L166
	.word .L168-.L166
	.word .L167-.L166
	.word .L165-.L166
.L156:
	mvs.w (%a4,%a0.l),%d5
	cmp.l %d5,%d6
	jne .L158
	tst.l %a2
	jeq .L158
	move.l %d0,%a5
	mvz.b (%a5),%d1
	jra .L158
.L162:
	tst.l %d3
	jge .L163
	clr.l %d0
	jra .L163
.L196:
	moveq #63,%d0
	cmp.l %d3,%d0
	jge .L213
	move.l #cu_loop+10,%d0
.L250:
	move.l %d0,60(%sp)
	move.l #cu_fmt_s,%d1
.L239:
	move.l %d1,56(%sp)
	jra .L235
.L213:
	move.l #cu_loop+5,%d0
	jra .L250
.L195:
	muls.w #3,%d0
	asr.l #7,%d0
	mulu.w #5,%d0
	add.l #cu_loop,%d0
.L247:
	move.l %d0,60(%sp)
	move.l #cu_fmt_s,%d3
	jra .L241
.L194:
	moveq #15,%d5
	cmp.l %d3,%d5
	jge .L198
	clr.l %d0
.L198:
	mulu.w #5,%d0
	add.l #cu_chd,%d0
.L253:
	move.l %d0,60(%sp)
	lea cu_fmt_s,%a0
	jra .L240
.L193:
	mov3q.l #3,%d1
	cmp.l %d3,%d1
	jge .L199
	clr.l %d0
.L199:
	move.l %d0,60(%sp)
	move.l #cu_fmt_inv,%d3
.L241:
	move.l %d3,56(%sp)
.L235:
	move.l %d2,52(%sp)
	movem.l (%sp),#15612
	lea (48,%sp),%sp
	jmp 1074365954
.L192:
	mov3q.l #2,%d5
	cmp.l %d3,%d5
	jge .L200
	clr.l %d0
.L200:
	move.l %d0,60(%sp)
	lea cu_fmt_spr,%a0
.L240:
	move.l %a0,56(%sp)
	jra .L235
.L191:
	move.l %d0,%d1
	mov3q.l #5,%d3
	subq.l #1,%d1
	cmp.l %d1,%d3
	jcs .L201
.L251:
	move.l %d0,60(%sp)
	move.l #cu_fmt_d,%d5
	jra .L242
.L201:
	lea cu_loop,%a0
	move.l %a0,60(%sp)
.L238:
	lea cu_fmt_s,%a5
	jra .L236
.L190:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_warp,%d0
.L243:
	move.l %d0,60(%sp)
	jra .L245
.L189:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #6,%d0
	add.l #cu_win,%d0
	jra .L250
.L188:
	moveq #119,%d5
	cmp.l %d3,%d5
	jlt .L202
	muls.w #99,%d0
	divs.l %d5,%d0
.L244:
	move.l %d0,60(%sp)
	lea cu_fmt_d,%a0
	jra .L240
.L202:
	lea cu_frz,%a5
	move.l %a5,60(%sp)
.L245:
	move.l #cu_fmt_s,%d0
	move.l %d0,56(%sp)
	jra .L235
.L187:
	tst.l %d3
	jle .L203
	asr.l #4,%d0
	mulu.w #5,%d0
	add.l #cu_anim,%d0
	jra .L250
.L185:
	mvs.w %d0,%d0
	lsr.l #3,%d0
	and.l #262140,%d0
	add.l #cu_inpt,%d0
	jra .L253
.L184:
	mvs.w %d0,%d0
	asr.l #6,%d0
	mulu.w #5,%d0
	add.l #cu_mon,%d0
.L237:
	move.l %d0,60(%sp)
	jra .L238
.L183:
	tst.l %d3
	jle .L203
	muls.w #60,%d0
	moveq #126,%d3
	move.l #cu_fmt_db,%d5
	addq.l #3,%d0
	divs.l %d3,%d0
	add.l #-80,%d0
	move.l %d0,60(%sp)
.L242:
	move.l %d5,56(%sp)
	jra .L235
.L182:
	asr.l #1,%d0
	addq.l #1,%d0
	jra .L244
.L181:
	moveq #63,%d1
	cmp.l %d3,%d1
	jge .L204
	muls.w #48,%d0
	moveq #126,%d3
	add.l #-3009,%d0
	divs.l %d3,%d0
	tst.l %d0
	jeq .L218
.L249:
	move.l #cu_fmt_pd,%d1
.L207:
	move.l %d0,60(%sp)
	jra .L239
.L204:
	moveq #64,%d1
	moveq #-126,%d5
	sub.l %d0,%d1
	muls.w #48,%d1
	move.l %d1,%d0
	add.l #63,%d0
	divs.l %d5,%d0
.L218:
	move.l #cu_fmt_d,%d1
	jra .L207
.L180:
	muls.w #100,%d0
	moveq #127,%d3
	move.l #cu_fmt_pct,%d5
	add.l #63,%d0
	divs.l %d3,%d0
	move.l %d0,60(%sp)
	jra .L242
.L179:
	tst.l %d3
	jgt .L244
.L203:
	move.l #cu_off,%d3
.L246:
	move.l %d3,60(%sp)
	jra .L248
.L178:
	mvs.w %d0,%d0
	asr.l #3,%d0
	jeq .L206
	addq.l #1,%d0
	move.l %d0,60(%sp)
	lea cu_fmt_x,%a5
.L236:
	move.l %a5,56(%sp)
	jra .L235
.L177:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_tape,%d0
	jra .L247
.L176:
	muls.w #3,%d0
	lsr.l #5,%d0
	and.l #262140,%d0
	add.l #cu_dir,%d0
	move.l %d0,60(%sp)
.L248:
	move.l #cu_fmt_s,%d5
	jra .L242
.L175:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_cloop,%d0
	jra .L253
.L174:
	tst.l %d3
	jle .L206
.L164:
	move.l %d0,60(%sp)
	lea cu_fmt_d,%a5
	jra .L236
.L172:
	mvs.w %d0,%d0
	asr.l #5,%d0
	mulu.w #5,%d0
	add.l #cu_dst,%d0
	jra .L243
.L171:
	mvs.w %d0,%d0
	asr.l #3,%d0
	move.l #cu_fmt_d,%d1
	addq.l #1,%d0
	move.l %d0,60(%sp)
	jra .L239
.L170:
	tst.l %d3
	jle .L203
	add.l #-64,%d0
	moveq #64,%d5
	cmp.l %d3,%d5
	jge .L218
	jra .L249
.L168:
	tst.l %d3
	jle .L203
	subq.l #1,%d0
	muls.w #127,%d0
	moveq #126,%d3
	divs.l %d3,%d0
	jra .L251
.L167:
	tst.l %d3
	jle .L203
	subq.l #1,%d0
	jra .L244
.L165:
	muls.w #9,%d0
	asr.l #7,%d0
	mulu.w #6,%d0
	add.l #cu_play,%d0
	jra .L237
.L173:
	moveq #126,%d1
	cmp.l %d3,%d1
	jge .L208
	move.l #cu_hold,%d3
	jra .L246
.L208:
	tst.l %d3
	jgt .L244
.L206:
	move.l #cu_slc,%d0
	jra .L250
.L186:
	cmp.l #441,%d6
	jeq .L219
	move.b 43(%sp),%d5
	mov3q.l #6,%d1
	add.l #-46,%d5
	mvz.b %d5,%d5
	cmp.l %d5,%d1
	jcs .L220
	lea CSWTCH.621,%a0
	mvs.b (%a0,%d5.l),%d1
.L209:
	tst.l %d3
	jle .L203
	asr.l #5,%d4
	mov3q.l #7,%d3
	mov3q.l #-1,%d5
	and.l %d3,%d4
	cmp.l %d1,%d5
	jeq .L210
	lea ram_ok,%a0
	btst #1,3(%a0)
	jeq .L210
	lea ux,%a1
	lea (%a1,%d1.l),%a0
	mvz.b 3948(%a0),%d3
	cmp.l %d3,%d4
	jne .L210
	mvz.w #1280,%d3
	moveq #10,%d5
	muls.l %d0,%d5
	muls.l %d1,%d3
	move.l %d5,%a0
	add.l %d3,%a0
	tst.b 40(%a1,%a0.l)
	jeq .L210
	mulu.w #10,%d0
	mulu.w #1280,%d1
	move.l %d0,%a0
	lea 40(%a0,%d1.l),%a0
	move.l %a0,%d0
	add.l %a1,%d0
	jra .L237
.L219:
	clr.l %d1
	jra .L209
.L220:
	mov3q.l #-1,%d1
	jra .L209
.L210:
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
.L256:
	lea (%a2,%d0.l),%a4
	moveq #84,%d2
	move.l %d1,%a3
	move.l (%a4),(%a3,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d2
	jne .L256
	tst.b 10(%a1)
	jeq .L257
	lea cu_text,%a2
	move.l %a2,32(%a3)
.L257:
	move.l (%a1),40(%a0)
	move.l 4(%a1),48(%a0)
	move.l 28(%sp),44(%a0)
	mvz.b 14(%a1),%d0
	move.w 12(%a1),%d1
	lsl.l #8,%d0
	and.l #2048,%d1
	move.l %d0,8(%a0)
	move.b 15(%a1),%d0
	jeq .L258
	mvz.b %d0,%d0
	lsl.l #8,%d0
.L259:
	move.l %d0,12(%a0)
	mvz.b 11(%a1),%d0
	lsl.l #8,%d0
	move.l %d0,16(%a0)
	tst.w %d1
	jeq .L255
	mov3q.l #1,20(%a0)
.L255:
	movem.l (%sp),#7172
	lea (16,%sp),%sp
	rts
.L258:
	tst.w %d1
	jeq .L261
	mvz.w #32736,%d0
	jra .L259
.L261:
	mvz.w #32512,%d0
	jra .L259
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
	jeq .L266
	moveq #40,%d0
	cmp.l %d2,%d0
	jeq .L266
	move.l #1094564988,%a0
.L268:
	move.l (%a0),%d0
	addq.l #4,%a0
	move.l %d0,-68(%a0)
	move.l %d0,-100(%a0)
	move.l %d0,-132(%a0)
	move.l %d0,-164(%a0)
	move.l %d0,-196(%a0)
	cmp.l #1094565020,%a0
	jne .L268
	mvz.b cu+8,%d0
	cmp.l %d0,%d2
	jeq .L269
.L271:
	move.l %d2,%d5
	clr.l %d3
	add.l #-43,%d5
	lea cu_src,%a6
	lea CSWTCH.619,%a5
	lea cu_knob,%a4
	move.l #1075575064,%a3
.L270:
	moveq #9,%d0
	cmp.l %d5,%d0
	jcs .L273
	move.l (%a5,%d5.l*4),%d0
.L272:
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
	jne .L270
	move.b %d2,cu+8
	jra .L266
.L269:
	move.l 1075595808,%d0
	cmp.l 4(%a2),%d0
	jne .L271
	move.l 1075596276,%d0
	cmp.l 116(%a2),%d0
	jne .L271
	cmp.l 1075595760.l,%d2
	jne .L271
.L266:
	movem.l (%sp),#31804
	lea (36,%sp),%sp
	rts
.L273:
	move.l #cu_fm_short,%d0
	jra .L272
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
	jle .L283
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
	jgt .L284
	mvz.b %d0,%d2
	mov3q.l #2,%d4
	move.l %d2,%a0
	lea (-48,%a0),%a0
	cmp.l %a0,%d4
	jcc .L285
	moveq #43,%d3
	cmp.l %d2,%d3
	jne .L284
.L285:
	move.b %d0,cu+9
	mvz.b cu+30,%d0
	lea st+8,%a0
	move.b %d1,cu+10
	move.l (%a0),cu+16
	cmp.l %d0,%d1
	jne .L298
	move.b cu+28,%d0
.L286:
	move.b %d0,cu+29
.L284:
	clr.l %d0
.L282:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L298:
	clr.b %d0
	jra .L286
.L283:
	tst.l %d2
	jge .L288
	mvz.b cu+9,%d0
	moveq #50,%d1
	cmp.l %d0,%d1
	jne .L289
	mvz.b cu+10,%d1
	move.l %d2,%d0
	not.l %d0
	cmp.l %d1,%d0
	jeq .L299
.L289:
	mvz.b cu+11,%d0
	neg.l %d2
	cmp.l %d0,%d2
	jne .L284
	move.l st+8,%d0
	mov3q.l #3,%d2
	sub.l cu+24,%d0
	cmp.l %d0,%d2
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L282
.L288:
	cmp.l #441,%d2
	jeq .L300
	lea cu_src,%a0
	clr.l %d3
.L291:
	mvs.w (%a0),%d1
	cmp.l %d1,%d2
	jne .L290
	mvz.b cu+8,%d0
	clr.l -(%sp)
	move.l %d0,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L284
	mvz.w %d3,%d3
	move.l %d0,%a0
	lsl.l #4,%d3
	mvz.w 12(%a0,%d3.l),%d0
	jra .L282
.L290:
	addq.l #2,%a0
	addq.l #1,%d3
	moveq #8,%d1
	cmp.l %d3,%d1
	jne .L291
	mvz.b %d0,%d0
	moveq #11,%d3
	cmp.l %d0,%d3
	jge .L292
	clr.l %d0
.L292:
	moveq #127,%d1
	and.l -2147457096,%d1
	mulu.w #152,%d0
	mulu.w #2531,%d1
	move.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0,%d0.l),%d3
	mvz.b cu+1,%d0
	cmp.l %d3,%d0
	jne .L284
	mov3q.l #1,-(%sp)
	move.l %d3,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L284
	move.l 1075596172,%d1
	move.l %d0,%a0
	cmp.l 116(%a0),%d1
	jne .L284
	lea cu_p2,%a0
	clr.l %d1
.L293:
	mvs.w (%a0),%d4
	cmp.l %d4,%d2
	jne .L294
	moveq #40,%d2
	cmp.l %d3,%d2
	jne .L297
	mov3q.l #3,%d2
	cmp.l %d1,%d2
	jge .L284
.L297:
	mvz.w %d1,%d1
	move.l %d0,%a0
	lsl.l #4,%d1
	mvz.w 12(%a0,%d1.l),%d0
	jra .L282
.L294:
	addq.l #2,%a0
	addq.l #1,%d1
	moveq #8,%d4
	cmp.l %d1,%d4
	jne .L293
	jra .L284
.L299:
	mov3q.l #1,%d0
	jra .L282
.L300:
	mvz.w #2944,%d0
	jra .L282
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
	.type	u10, @function
u10:
	lea (-28,%sp),%sp
	clr.l %d0
	move.l 36(%sp),%d1
	movem.l #16412,(%sp)
	lea (18,%sp),%a0
	move.l %a0,%a6
.L315:
	move.l %d1,%d2
	moveq #10,%d3
	remu.l %d3,%d4:%d2
	divu.l %d3,%d2
	addq.l #1,%d0
	move.l %d4,%a1
	moveq #9,%d4
	lea (48,%a1),%a1
	move.w %a1,%d3
	move.l %d1,%a1
	move.l %d2,%d1
	move.b %d3,(%a0)+
	cmp.l %a1,%d4
	jcs .L315
	move.l 32(%sp),%a0
	move.l %d0,%d1
.L316:
	subq.l #1,%d1
	move.b (%a6,%d1.l),(%a0)+
	tst.l %d1
	jne .L316
	movem.l (%sp),#16412
	lea (28,%sp),%sp
	rts
	.size	u10, .-u10
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
.L321:
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr (%a2)
	addq.l #1,%a6
	addq.l #4,%d2
	addq.l #8,%sp
	moveq #16,%d0
	cmp.l %a6,%d0
	jne .L321
	move.l %sp,%d2
	sub.l %a6,%a6
	lea shs,%a3
	add.l #22,%d2
	lea rui_uart_raw,%a2
.L323:
	move.b (%a3,%a6.l),%d0
	mvz.b %d0,%d1
	cmp.l #255,%d1
	jeq .L322
	move.l %a6,%d1
	moveq #32,%d3
	or.l %d3,%d1
	move.b %d0,23(%sp)
	move.b %d1,22(%sp)
	move.l %d2,-(%sp)
	mov3q.l #2,-(%sp)
	jsr (%a2)
	addq.l #8,%sp
.L322:
	addq.l #1,%a6
	mov3q.l #4,%d0
	cmp.l %a6,%d0
	jne .L323
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
	jne .L330
	lea txsx_wait,%a2
	jsr (%a2)
	move.l %d0,%d2
	tst.l %d0
	jeq .L331
	addq.l #1,st+40
.L330:
	clr.l %d2
.L329:
	move.l %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L331:
	move.l #1123449384,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L333
	addq.l #1,st+40
	jra .L329
.L333:
	jsr (%a2)
	tst.l %d0
	jne .L334
	mvz.w #4027,%d0
	cmp.l 1094562392.l,%d0
	jlt .L334
	move.l 1094562704,%a0
	mov3q.l #4,%d0
.L335:
	tst.l %a0
	jeq .L334
	move.l 52(%a0),%a0
	subq.l #1,%d0
	tst.l %d0
	jne .L335
	move.l 12(%sp),-(%sp)
	move.l 20(%sp),-(%sp)
	jsr 1073752544
	move.l #1123449384,-(%sp)
	jsr 1073746414
	lea (12,%sp),%sp
	mov3q.l #1,%d2
	addq.l #1,st+36
	jra .L329
.L334:
	move.l #1123449384,-(%sp)
	jsr 1073746414
	addq.l #1,st+40
	addq.l #4,%sp
	jra .L329
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
.L344:
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
	jgt .L344
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
	jne .L347
	mvz.b mr+18,%d0
	cmp.l -12(%fp),%d0
	jeq .L346
.L347:
	pea 8.w
	pea -8(%fp)
	move.b -9(%fp),-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L346
	clr.b %d0
	lea (-9,%fp),%a0
	move.b (%a0),mr+18
	move.b %d0,mr+19
	move.w mr+20,%d0
	addq.l #1,%d0
	move.w %d0,mr+20
.L346:
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
.L354:
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
	jeq .L353
	addq.l #1,%d1
.L353:
	lea (152,%a1),%a1
	cmp.l #1824,%a1
	jne .L354
	tst.b mr+12.l
	jne .L355
	sub.l %a0,%a0
.L356:
	lea (%a2,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a3,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L356
	moveq #127,%d0
	and.l -2147457096,%d0
	move.b %d0,mr+18
	moveq #1,%d0
	move.b %d0,mr+12
.L357:
	mov3q.l #1,%a6
	jra .L352
.L355:
	mov3q.l #1,%d0
	cmp.l %d1,%d0
	jge .L358
	move.b %d0,mr+13
.L359:
	move.l %a2,-(%sp)
	pea 12.w
	clr.l -(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L352
	sub.l %a0,%a0
.L362:
	lea (%a2,%a0.l),%a1
	moveq #12,%d0
	move.b (%a1),(%a3,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L362
	clr.b %d0
	move.b %d0,mr+13
	move.w mr+16,%d0
	addq.l #1,%d0
	move.w %d0,mr+16
	jsr kit_tick
.L352:
	move.l %a6,%d0
	movem.l (%sp),#23556
	lea (32,%sp),%sp
	rts
.L358:
	clr.l %d2
	tst.b mr+13.l
	jne .L359
.L360:
	mvz.b (%a3,%d2.l),%d0
	mvz.b (%a2)+,%d1
	cmp.l %d1,%d0
	jeq .L364
	pea 20(%sp)
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr mr_send
	lea (12,%sp),%sp
	move.l %d0,%a6
	tst.l %d0
	jeq .L352
	lea (-1,%a2),%a0
	move.b (%a0),(%a3,%d2.l)
	move.w mr+14,%d0
	addq.l #1,%d0
	move.w %d0,mr+14
.L364:
	addq.l #1,%d2
	moveq #12,%d0
	cmp.l %d2,%d0
	jne .L360
	jsr kit_tick
	jra .L357
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
.L383:
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
	jeq .L378
	clr.w %d7
	lea ar+48,%a3
	move.w %d7,(%a5,%d1.l*2)
	moveq #127,%d1
	and.l -2147457096,%d1
	mvz.b (%a3,%a6.l),%d6
	cmp.l %d6,%d1
	jne .L378
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
.L378:
	move.b 1(%a0),%d6
	move.b (%a0),%d0
	lsl.l #2,%d6
	mvz.b %d0,%d1
	and.l #768,%d6
	or.l %d1,%d6
	mvz.w (%a2),%d1
	cmp.l %d1,%d6
	jne .L379
	mvz.w ar+60,%d1
	move.l %a6,%d7
	btst %d7,%d1
	jeq .L380
.L379:
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
	jeq .L377
	move.w %d6,(%a2)
	move.l %a6,%d1
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	addq.l #1,ar+62
	move.w ar+60,%d1
	not.l %d0
	and.l %d1,%d0
	move.w %d0,ar+60
.L380:
	addq.l #1,%a6
	add.l #152,%d5
	addq.l #2,%a2
	add.l #162,%d4
	moveq #12,%d6
	cmp.l %a6,%d6
	jne .L383
.L377:
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
.L392:
	lea (%a1,%d0.l),%a2
	move.b (%a2),-9(%fp,%d0.l)
	move.l %d0,%a0
	addq.l #1,%d0
	cmp.l 16(%fp),%d0
	jne .L392
	moveq #-9,%d0
	move.b %d0,-8(%fp,%a0.l)
	pea 9(%a0)
	pea -16(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L391
	addq.l #1,sq+456
.L391:
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
.L402:
	moveq #15,%d3
	cmp.l %d0,%d3
	jcs .L417
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
	jeq .L403
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
.L403:
	addq.l #1,%d1
	cmp.l #256,%d1
	jne .L402
.L417:
	tst.b %d2
	jeq .L401
	move.l %a0,kq_owes
	move.l %d0,st+196
.L401:
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
	jeq .L419
	move.l st+8,%d0
	cmp.l #16383,%d0
	jls .L420
	mvz.w #16383,%d0
.L420:
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
	jeq .L418
	clr.b %d1
	addq.l #1,st+968
	addq.l #1,qp+8
	mov3q.l #1,qp+48
	mov3q.l #1,qp+100
	lea ram_ok,%a0
	move.b %d1,st+992
	btst #2,3(%a0)
	jeq .L423
	addq.l #1,pmo+68
.L423:
	tst.l ram_bad
	jeq .L419
	mov3q.l #1,ram_rep_owed
.L419:
	tst.b st+161.l
	jeq .L425
	lea st+993,%a0
	move.w #12289,%d0
	move.l #-260222380,%a1
	move.w st+162,%d1
	move.b (%a0),-6(%fp)
	pea 10.w
	pea -12(%fp)
	move.l %a1,-12(%fp)
	move.w %d0,-8(%fp)
	mvz.w %d1,%d0
	lsl.l #8,%d1
	lsr.l #8,%d0
	add.l %d1,%d0
	move.w %d0,-5(%fp)
	moveq #-9,%d0
	move.b %d0,-3(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L418
	clr.b %d1
	move.b %d1,st+161
.L425:
	lea ls+4,%a0
	clr.l %d2
	move.l %fp,%d3
	move.l #-260222380,%a3
	lea ls,%a2
	add.l #-12,%d3
	move.l %a0,-16(%fp)
.L427:
	cmp.l ls+24.l,%d2
	jcs .L430
.L429:
	move.w %d2,%d0
	move.l ls+24,%d1
	move.l %d1,-16(%fp)
	mulu.w #5,%d0
	lea (%a2,%d0.l),%a0
	move.l %d2,%d0
.L431:
	cmp.l -16(%fp),%d0
	jcs .L432
	move.l -16(%fp),%d1
	sub.l %d2,%d1
	move.l %d1,-16(%fp)
	move.l %d1,ls+24
	tst.l %d1
	jne .L418
	lea st+164,%a2
	move.l %a2,%a4
.L433:
	move.l -16(%fp),%a0
	cmp.l st+196.l,%a0
	jcc .L437
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
	jne .L434
.L437:
	move.l st+196,%d0
	move.l -16(%fp),%d1
.L435:
	cmp.l %d0,%d1
	jcs .L438
	sub.l -16(%fp),%d0
	move.l %d0,st+196
	tst.l %d0
	jne .L418
	move.l kq_owes,%d2
	tst.l %d2
	jeq .L439
	movem.l -36(%fp),#7180
	unlk %fp
	jra (kq_owed_in.part.0)
.L430:
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
	jeq .L429
	addq.l #5,-16(%fp)
	addq.l #1,%d2
	jra .L427
.L432:
	addq.l #5,%a0
	addq.l #5,%a2
	move.b -1(%a0),-1(%a2)
	addq.l #1,%d0
	move.b (%a0),(%a2)
	move.b 1(%a0),1(%a2)
	move.b 2(%a0),2(%a2)
	move.b 3(%a0),3(%a2)
	jra .L431
.L434:
	addq.l #2,%a4
	addq.l #1,-16(%fp)
	jra .L433
.L438:
	move.l -16(%fp),%a1
	addq.l #1,%d1
	move.b (%a2,%a1.l*2),(%a2)
	lea 1(%a2,%a1.l*2),%a0
	addq.l #2,%a2
	move.b (%a0),-1(%a2)
	jra .L435
.L439:
	lea st+96,%a2
.L444:
	move.l (%a2)+,-16(%fp)
	tst.l -16(%fp)
	jeq .L440
	moveq #-63,%d0
	cmp.l -16(%fp),%d0
	jle .L441
	moveq #-63,%d1
.L461:
	move.l %d1,-16(%fp)
.L442:
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
	jeq .L418
	move.l -16(%fp),%d1
	sub.l %d1,-4(%a2)
	move.l st+64,%d1
	tst.l %d1
	jeq .L440
	move.l -66650100,%d0
	sub.l %d1,%d0
	move.l %d0,st+68
	add.l %d0,st+316
	addq.l #1,st+320
	cmp.l st+324.l,%d0
	jls .L443
	move.l %d0,st+324
.L443:
	clr.l st+64
.L440:
	addq.l #1,%d2
	moveq #16,%d0
	cmp.l %d2,%d0
	jne .L444
.L418:
	movem.l -36(%fp),#7180
	unlk %fp
	rts
.L441:
	moveq #63,%d0
	cmp.l -16(%fp),%d0
	jge .L442
	moveq #63,%d1
	jra .L461
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
	jeq .L462
	move.l ed+64,%d0
	move.l %d0,%a0
	mov3q.l #7,%d2
	sub.l ed+68,%a0
	cmp.l %a0,%d2
	jcc .L464
	addq.l #1,ed+72
.L462:
	move.l (%sp)+,%d2
	rts
.L464:
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
	jcc .L465
	lea (-16,%a1),%a1
	mov3q.l #1,%d2
	cmp.l %a1,%d2
	jcc .L465
	mvz.b 1093765506,%d0
	moveq #11,%d2
	cmp.l %d0,%d2
	jcc .L466
.L465:
	moveq #127,%d0
.L467:
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
	jra .L462
.L466:
	move.b 1093765506,%d0
	jra .L467
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
	jcc .L472
	addq.l #1,ls+92
.L471:
	move.l (%sp)+,%a2
	move.l (%sp)+,%a3
	rts
.L472:
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
	jra .L471
	.size	ls_queue, .-ls_queue
	.align	2
	.type	ls_close, @function
ls_close:
	lea ls,%a0
	tst.b ls.l
	jeq .L474
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
.L474:
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
	jeq .L477
	tst.l ls+36
	jeq .L478
	move.b ls+2,%d1
	add.l #-40,%d1
	mvz.b %d1,%d1
	lsr.l #1,%d1
	jeq .L478
	mov3q.l #7,%d1
	cmp.l %d0,%d1
	jne .L478
	add.l %d3,st+124
.L493:
	jsr flush
	jra .L479
.L478:
	mvz.b ls+125,%d1
	cmp.l %d1,%d0
	jeq .L477
	mov3q.l #3,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L481:
	clr.l %d0
.L476:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L477:
	or.l st+972,%d0
	jne .L481
	tst.b %d2
	jne .L482
	tst.b sv.l
	jeq .L481
	tst.b sv+8.l
	jeq .L481
	move.b sv+2,%d4
	mvz.b %d4,%d3
	move.l %d3,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L483
	moveq #45,%d1
	cmp.l %d3,%d1
	jeq .L483
	moveq #43,%d1
	cmp.l %d3,%d1
	jne .L476
.L483:
	lea sv+1,%a0
	moveq #45,%d0
	move.b (%a0),ls+1
	move.b %d4,ls+2
	cmp.l %d3,%d0
	jeq .L486
	moveq #43,%d1
	cmp.l %d3,%d1
	jne .L484
.L486:
	moveq #10,%d2
.L484:
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
.L479:
	mov3q.l #1,%d0
	jra .L476
.L482:
	add.l %d3,st+96
	addq.l #1,ls+84
	jra .L493
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
	jne .L495
	clr.b %d1
	move.l pmo+104,%d4
	move.l pmo+9096,%d0
	lea pmo+9100,%a1
.L496:
	tst.l %d0
	jne .L498
	tst.b %d1
	jeq .L499
	clr.l pmo+9096
.L499:
	moveq #127,%d0
	cmp.l %d4,%d0
	jcc .L505
	clr.l %d0
	jra .L494
.L495:
	mulu.w #44,%d0
	add.l #pmo+3420,%d0
.L494:
	movem.l (%sp),#3196
	lea (28,%sp),%sp
	rts
.L498:
	subq.l #1,%d0
	moveq #1,%d1
	mvz.b (%a1,%d0.l),%d6
	cmp.l %d6,%d4
	jls .L496
	move.l %d0,pmo+9096
	lea (%a2,%d0.l),%a0
	mvz.b 9100(%a0),%d0
	move.l %d0,%a1
	jra .L503
.L505:
	move.l %d4,%a1
.L503:
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
	jls .L494
	move.l %d1,pmo+104
	jra .L494
	.size	pmo_get, .-pmo_get
	.align	2
	.type	pj_push, @function
pj_push:
	lea (-12,%sp),%sp
	movem.l #28,(%sp)
	move.l 20(%sp),%d1
	move.l 24(%sp),%a1
#APP
| 5291 "rui.c" 1
	tas pj+136
	smi %d2
| 0 "" 2
#NO_APP
	tst.b %d2
	jeq .L511
	addq.l #1,pj+156
.L510:
	movem.l (%sp),#28
	lea (12,%sp),%sp
	rts
.L511:
	move.l pj,%d3
	move.l %d3,%d0
	sub.l pj+4,%d0
	lsr.l #5,%d0
	jeq .L513
	addq.l #1,pj+156
.L514:
	clr.b %d0
	move.b %d0,pj+136
	jra .L510
.L513:
	moveq #31,%d0
	and.l %d3,%d0
	lsl.l #2,%d0
	move.l %d0,%a0
	add.l #pj+8,%a0
	move.b 19(%sp),(%a0)
	moveq #127,%d0
	cmp.l %d1,%d0
	jcs .L517
	move.l %d1,%d0
	addq.l #1,%d0
.L515:
	move.b %d0,1(%a0)
	moveq #127,%d4
	cmp.l %a1,%d4
	jcs .L516
	move.l %a1,%d2
	addq.l #1,%d2
.L516:
	move.b %d2,2(%a0)
	addq.l #1,%d3
	move.l %d3,pj
	jra .L514
.L517:
	clr.b %d0
	jra .L515
	.size	pj_push, .-pj_push
	.align	2
	.type	led_restore, @function
led_restore:
	tst.b ov_on.l
	jeq .L518
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L520
	addq.l #1,st+1018
.L518:
	rts
.L520:
	clr.b %d0
	move.b %d0,ov_on
	jsr led_stock
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #4,%sp
	move.l st+8,%d0
	addq.l #4,%d0
	tst.l %d0
	jne .L521
	mov3q.l #1,%d0
.L521:
	move.l %d0,led_again
	addq.l #1,st+1014
	jra .L518
	.size	led_restore, .-led_restore
	.align	2
	.type	sq_tick, @function
sq_tick:
	link.w %fp,#-68
	move.l sq_gen,%d0
	movem.l #15612,(%sp)
	move.b 1093765506,%d2
	cmp.l sq+400.l,%d0
	jeq .L526
	mov3q.l #1,%d3
	and.l %d0,%d3
	btst #0,%d0
	jne .L526
	clr.l %d1
	lea sq_req,%a0
.L527:
	lea (%a0,%d1.l),%a1
	mov3q.l #7,%d4
	move.b (%a1),-9(%fp,%d1.l)
	addq.l #1,%d1
	cmp.l %d1,%d4
	jne .L527
	cmp.l sq_gen.l,%d0
	jne .L526
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
	jeq .L529
	move.l sq+4,%d3
.L529:
	mvz.b -3(%fp),%d0
	mvz.b -4(%fp),%d4
	lsl.l #7,%d0
	or.l %d4,%d0
	and.l #4095,%d0
	or.l %d3,%d0
	move.l %d0,pin
	tst.l sq
	jeq .L530
	btst #1,%d1
	jeq .L531
.L530:
	mvz.w #255,%d5
	move.w #8191,%a0
	addq.l #1,sq+452
	mov3q.l #1,ed+92
	move.l %d5,sq+404
	move.l %a0,ed+260
.L531:
	mov3q.l #1,sq
.L526:
	tst.l sq
	jne .L532
	clr.l sq+408
.L525:
	movem.l -68(%fp),#15612
	unlk %fp
	rts
.L532:
	mvz.b %d2,%d2
	lea sq_grid,%a2
	moveq #11,%d0
	cmp.l %d2,%d0
	jcs .L534
	move.l sq+4,%d0
	btst %d2,%d0
	jne .L535
.L534:
	clr.l %d0
.L536:
	cmp.l sq+408.l,%d0
	jne .L537
	tst.l %d0
	jeq .L538
	cmp.l sq+412.l,%d2
	jeq .L538
.L537:
	mov3q.l #1,%d1
	or.l %d1,sq+404
	move.l %d0,sq+408
	move.l %d2,sq+412
.L538:
	move.b 1093615249,%d0
	move.b 1093615250,%d2
	moveq #127,%d3
	move.b 1079807236,%d1
	and.l %d3,%d1
	move.l sq+360,%d3
	btst #8,%d3
	jeq .L539
	move.l %d1,%a0
	moveq #127,%d1
	and.l %d3,%d1
.L540:
	cmp.l %d1,%a0
	jne .L541
	move.w #127,%a0
.L541:
	cmp.l sq+420.l,%d1
	jne .L542
	cmp.l sq+424.l,%a0
	jeq .L543
.L542:
	mov3q.l #4,%d5
	or.l %d5,sq+404
	move.l %d1,sq+420
	move.l %a0,sq+424
.L543:
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
	jne .L544
	cmp.l sq+432.l,%d0
	jeq .L545
.L544:
	move.l %d0,sq+432
	moveq #16,%d0
	or.l %d0,sq+404
	move.l %d2,sq+428
.L545:
	move.l 1076395164,%d0
	and.l #2097151,%d0
	cmp.l sq+436.l,%d0
	jeq .L546
	moveq #32,%d1
	or.l %d1,sq+404
	move.l %d0,sq+436
.L546:
	move.b 1081877443,%d0
	mvz.b 1081877444,%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #8191,%d0
	cmp.l sq+440.l,%d0
	jeq .L547
	moveq #8,%d2
	or.l %d2,sq+404
	move.l %d0,sq+440
.L547:
	move.b 1081877445,%d0
	mvz.b 1081877446,%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	and.l #8191,%d0
	cmp.l sq+552.l,%d0
	jeq .L548
	mvz.w #128,%d3
	move.l %d0,sq+552
	or.l %d3,sq+404
.L548:
	mov3q.l #1,%d4
	move.l 1079807120,%d2
	cmp.l %d2,%d4
	jne .L549
	move.l st+8,%d0
	moveq #19,%d5
	sub.l sq+444,%d0
	cmp.l %d0,%d5
	jcc .L549
	moveq #64,%d0
	or.l %d0,sq+404
.L549:
	move.l sq+404,%d0
	btst #0,%d0
	jeq .L550
	move.l sq+408,%d0
	move.b %d0,-9(%fp)
	tst.l %d0
	jeq .L585
	move.b sq+415,%d0
.L551:
	mov3q.l #2,-(%sp)
	pea -9(%fp)
	pea 8.w
	move.b %d0,-8(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L525
	moveq #-2,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L550:
	btst #1,%d0
	jeq .L552
	mov3q.l #2,%d1
	cmp.l %d2,%d1
	jcc .L586
	clr.l %d0
.L553:
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
	jeq .L525
	moveq #-3,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L552:
	move.w %d0,%ccr
	jne .L554
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
	jeq .L525
	moveq #-5,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L554:
	move.w %d0,%ccr
	jpl .L555
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
	jeq .L525
	moveq #-9,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L555:
	tst.b %d0
	jpl .L556
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
	jeq .L525
	move.l sq+404,%d0
	bclr #7,%d0
	move.l %d0,sq+404
.L556:
	btst #4,%d0
	jeq .L557
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
	jeq .L525
	moveq #-17,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L557:
	btst #5,%d0
	jeq .L558
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
	jeq .L525
	moveq #-33,%d0
	and.l sq+404,%d0
	move.l %d0,sq+404
.L558:
	btst #6,%d0
	jeq .L559
	move.l 1100784300,-(%sp)
	move.l %fp,%d3
	add.l #-9,%d3
	move.l %d3,-(%sp)
	jsr blk4
	addq.l #8,%sp
	mov3q.l #2,%d5
	cmp.l %d2,%d5
	jcc .L560
	clr.l %d2
.L560:
	move.b %d2,-5(%fp)
	moveq #127,%d1
	move.w 1079807124,%d0
	subq.l #1,%d0
	and.l %d1,%d0
	move.b %d0,-4(%fp)
	move.l sq+380,%d0
	cmp.l %d0,%d1
	jcc .L561
	moveq #127,%d0
.L561:
	mov3q.l #7,-(%sp)
	move.l %d3,-(%sp)
	pea 9.w
	move.b %d0,-3(%fp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L525
	moveq #-65,%d2
	and.l %d2,sq+404
	lea st+8,%a0
	move.l (%a0),sq+444
.L559:
	move.l sq+360,%d0
	btst #8,%d0
	jeq .L562
	moveq #127,%d1
	and.l %d1,%d0
.L563:
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
.L569:
	move.l -28(%fp),%a4
	move.l #85689,%a5
	moveq #12,%d0
	mvz.b (%a4,%a5.l),%d4
	cmp.l %d1,%d0
	jeq .L564
	mvz.b (%a0),%d0
	move.b 2(%a0),%d3
.L565:
	mvz.b %d3,%d3
	cmp.l (%a1),%d0
	jne .L566
	cmp.l 52(%a1),%d3
	jne .L566
	cmp.l 104(%a1),%d4
	jne .L566
	moveq #12,%d2
	cmp.l %d1,%d2
	jne .L567
	move.l -28(%fp),%a4
	move.l #85685,%d2
	move.l #85686,%a5
	move.b (%a4,%d2.l),%d2
	mvz.b (%a4,%a5.l),%d5
	mvz.b %d2,%d2
	lsl.l #8,%d2
	or.l %d5,%d2
	cmp.l ed+256.l,%d2
	jeq .L567
.L566:
	move.l %d0,(%a1)
	moveq #12,%d0
	move.l %d3,52(%a1)
	move.l %d4,104(%a1)
	cmp.l %d1,%d0
	jne .L568
	move.l #85686,%a5
	move.l -28(%fp),%a4
	move.b (%a4,%d7.l),%d0
	mvz.b (%a4,%a5.l),%d2
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d2,%d0
	move.l %d0,ed+256
.L568:
	tst.l -24(%fp)
	jeq .L567
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	or.l %d0,ed+260
.L567:
	addq.l #1,%d1
	addq.l #4,%a1
	lea (917,%a0),%a0
	moveq #13,%d0
	cmp.l %d1,%d0
	jne .L569
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
	jeq .L570
	move.l %d1,ed+272
	clr.l ed+268
	clr.l ed+372
.L570:
	move.l ed+268,%d2
	move.l %d2,%d3
	addq.l #1,%d3
	move.l %d3,%d1
	moveq #10,%d4
	lsl.l %d4,%d1
	cmp.l %d0,%d1
	jls .L587
	move.l %d2,%d1
	move.l %d0,%d5
	lsl.l %d4,%d1
	sub.l %d1,%d5
.L571:
	moveq #12,%d4
	move.l %d2,%d1
	lsl.l %d4,%d1
	clr.l %d4
	add.l %d1,%a1
	clr.l %d1
.L572:
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
	jne .L572
	move.l ed+372,%d4
	move.l %d2,%a0
	lea (69,%a0),%a0
	btst %d2,%d4
	jeq .L573
	cmp.l (%a3,%a0.l*4),%d1
	jeq .L573
	mov3q.l #1,ed+376
.L573:
	move.l %d1,(%a3,%a0.l*4)
	mov3q.l #1,%d1
	add.l #1023,%d0
	lsl.l %d2,%d1
	or.l %d4,%d1
	move.l %d1,ed+372
	moveq #10,%d1
	lsr.l %d1,%d0
	cmp.l %d3,%d0
	jhi .L574
	clr.l %d3
.L574:
	move.l %d3,ed+268
	move.l %fp,%d3
	clr.l %d2
	add.l #-17,%d3
.L579:
	move.l ed+260,%d0
	btst %d2,%d0
	jeq .L575
	moveq #12,%d5
	cmp.l %d2,%d5
	jne .L588
	moveq #127,%d0
.L576:
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
	jeq .L589
	mov3q.l #5,%d0
.L577:
	move.l %d0,-(%sp)
	move.l %d3,-(%sp)
	mov3q.l #4,-(%sp)
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L525
	mov3q.l #1,%d0
	lsl.l %d2,%d0
	addq.l #1,ed+264
	not.l %d0
	and.l %d0,ed+260
.L575:
	addq.l #1,%d2
	addq.l #4,%a2
	moveq #13,%d1
	cmp.l %d2,%d1
	jne .L579
.L580:
	move.l ed+68,%d0
	cmp.l ed+64.l,%d0
	jne .L581
	tst.l ed+92
	jeq .L582
	lea ed+91,%a0
	move.b (%a0),-17(%fp)
	mov3q.l #1,-(%sp)
	pea -17(%fp)
	pea 12.w
	jsr sq_send2
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L525
	clr.l ed+92
.L582:
	tst.l ed+376
	jeq .L525
	move.l st+8,%d0
	sub.l ed+380,%d0
	lsr.l #2,%d0
	jeq .L525
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
	jeq .L525
	lea st+8,%a0
	clr.l ed+376
	move.l (%a0),ed+380
	addq.l #1,ed+384
	jra .L525
.L535:
	jsr (%a2)
	jra .L536
.L539:
	mvz.b %d0,%d0
	mvz.b %d2,%d2
	move.w #127,%a0
	moveq #127,%d4
	lsl.l #8,%d0
	or.l %d2,%d0
	cmp.l %d0,%d4
	jlt .L541
	move.l %d0,%a0
	jra .L540
.L585:
	moveq #127,%d0
	jra .L551
.L586:
	move.l %d2,%d0
	jra .L553
.L562:
	move.b 1079807236,%d0
	moveq #127,%d2
	and.l %d2,%d0
	jra .L563
.L564:
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
	jra .L565
.L587:
	mvz.w #1024,%d5
	jra .L571
.L588:
	move.l %d2,%d0
	jra .L576
.L589:
	mov3q.l #7,%d0
	jra .L577
.L581:
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
	jeq .L525
	addq.l #1,ed+68
	addq.l #1,ed+76
	jra .L580
	.size	sq_tick, .-sq_tick
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
	jge .L679
	mvz.b 5(%a5),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L679
	mvz.b -1(%a5,%d0.l),%d1
	cmp.l #247,%d1
	jeq .L674
.L679:
	addq.l #1,rx_bad
	jra .L675
.L674:
	move.b 4(%a5),%d3
	lea ram_ok,%a0
	btst #0,3(%a0)
	jne .L676
	move.l %d3,%d1
	add.l #-56,%d1
	mvz.b %d1,%d1
	mov3q.l #1,%d2
	cmp.l %d1,%d2
	jcc .L677
	move.l %d3,%d1
	add.l #-61,%d1
	mvz.b %d1,%d1
	cmp.l %d1,%d2
	jcs .L676
.L677:
	clr.b %d3
	addq.l #1,ram_drops
	move.b %d3,st_valid
.L675:
	move.l -66650100,%d0
	addq.l #1,mt_calls
	sub.l -38(%fp),%d0
	add.l %d0,mt_sum
	cmp.l mt_max.l,%d0
	jls .L862
	move.l %d0,mt_max
.L862:
	movem.l -80(%fp),#15612
	mov3q.l #1,%d0
	unlk %fp
	rts
.L676:
	lea ram_ok,%a0
	btst #1,3(%a0)
	jne .L678
	move.l %d3,%d1
	add.l #-71,%d1
	mvz.b %d1,%d1
	lsr.l #1,%d1
	jne .L678
	addq.l #1,ram_drops
	jra .L675
.L678:
	move.l %d3,%d1
	add.l #-40,%d1
	mvz.b %d1,%d1
	move.l %d0,%d2
	moveq #50,%d4
	subq.l #7,%d2
	cmp.l %d1,%d4
	jcs .L679
	move.w .L681(%pc,%d1.l*2),%d1
	ext.l %d1
	jmp %pc@(2,%d1:l)
	.balignw 2,0x284c
	.swbeg	&51
.L681:
	.word .L700-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L699-.L681
	.word .L698-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L697-.L681
	.word .L679-.L681
	.word .L696-.L681
	.word .L695-.L681
	.word .L694-.L681
	.word .L693-.L681
	.word .L692-.L681
	.word .L679-.L681
	.word .L691-.L681
	.word .L690-.L681
	.word .L689-.L681
	.word .L688-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L687-.L681
	.word .L686-.L681
	.word .L685-.L681
	.word .L684-.L681
	.word .L679-.L681
	.word .L683-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L682-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L679-.L681
	.word .L680-.L681
.L694:
	mov3q.l #4,%d5
	cmp.l %d2,%d5
	jge .L701
	move.b 7(%a5),%d2
	moveq #15,%d6
	mvz.b %d2,%d4
	cmp.l %d4,%d6
	jcs .L701
	mvz.b 8(%a5),%d5
	mov3q.l #7,%d7
	cmp.l %d5,%d7
	jcs .L701
	move.b 9(%a5),%d1
	jeq .L701
	move.b 10(%a5),%d3
	jeq .L701
	mvz.b %d1,%d6
	add.l %d6,%d4
	moveq #16,%d6
	cmp.l %d4,%d6
	jlt .L701
	mvz.b %d3,%d4
	move.l %d5,%a0
	moveq #8,%d7
	add.l %d4,%a0
	cmp.l %a0,%d7
	jlt .L701
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
	jne .L701
	mvs.b %d2,%d2
	lea (11,%a5),%a2
	clr.l %d0
	lsl.l #6,%d2
	move.l %d2,%a0
	add.l %d5,%a0
	add.l #rui_big+1024,%a0
.L705:
	move.l %d1,%a1
	mov3q.l #7,%d2
	cmp.l %d1,%d2
	jge .L702
	mov3q.l #7,%a1
.L702:
	move.l %a2,%a3
	sub.l %a1,%d1
	mvz.b (%a3)+,%d3
	clr.l %d2
.L704:
	move.l %d3,%d5
	lsr.l #1,%d3
	move.b 1(%a2,%d2.l),%d6
	lsl.l #7,%d5
	or.l %d6,%d5
	move.b %d5,(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d4,%d0
	jne .L703
	addq.l #8,%a0
	clr.l %d0
.L703:
	addq.l #1,%d2
	cmp.l %a1,%d2
	jne .L704
	lea (%a3,%a1.l),%a2
	tst.l %d1
	jgt .L705
.L917:
	moveq #1,%d3
	addq.l #6,%a5
	move.b (%a5),st_seq
	move.b %d3,st_valid
	jra .L691
.L701:
	clr.b %d4
	addq.l #1,rx_bad
	move.b %d4,st_valid
	jra .L675
.L693:
	tst.l %d2
	jeq .L679
	tst.b st_valid.l
	jeq .L707
	mvz.b 6(%a5),%d1
	mvz.b st_seq,%d0
	cmp.l %d1,%d0
	jne .L707
	addq.l #1,sh_seq
	pea 256.w
	pea rui_big+1024
	pea rui_big
	lea copy32,%a2
	jsr (%a2)
	pea 704.w
	pea rui_big+4096
	pea rui_big+6912
	jsr (%a2)
	move.l #-66650100,%a0
	lea (24,%sp),%sp
	addq.l #1,sh_seq
	addq.l #1,commits
	move.l (%a0),t_commit
.L707:
	clr.b %d0
	move.b %d0,st_valid
.L691:
	addq.l #1,rx
	jra .L675
.L692:
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jge .L679
	tst.b 7(%a5)
	jeq .L709
	moveq #1,%d2
	move.b %d2,host_open
	jra .L691
.L709:
	moveq #1,%d3
	move.b %d3,host_close
	jra .L691
.L680:
	move.l qp+56,%d4
	tst.l %d2
	jeq .L710
	move.b 6(%a5),%d5
	mov3q.l #3,%d6
	mvz.b %d5,%d0
	move.b %d5,-40(%fp)
	cmp.l %d0,%d6
	jcc .L711
	mov3q.l #7,%d7
	cmp.l %d0,%d7
	jcs .L712
	lea ram_ok,%a0
	btst #2,3(%a0)
	jne .L827
	addq.l #1,ram_drops
.L714:
	addq.l #1,pmo+20
.L710:
	mov3q.l #1,%d0
.L737:
	addq.l #1,qp+72
	tst.l %d0
	jeq .L742
	addq.l #1,qp+76
.L742:
	move.l %d4,%d1
	sub.l qp+60,%d1
	lsr.l #2,%d1
	jeq .L743
	addq.l #1,qp+80
	tst.l %d0
	jeq .L691
	tst.l %d2
	jeq .L832
	move.b 6(%a5),%d0
	moveq #127,%d4
	and.l %d4,%d0
.L744:
	move.l %d0,qp+88
	addq.l #1,qp+92
	jra .L691
.L827:
	clr.l %d1
.L713:
	tst.b 6(%a5,%d1.l)
	jlt .L714
	addq.l #1,%d1
	cmp.l %d2,%d1
	jlt .L713
	mov3q.l #7,%d1
	cmp.l %d0,%d1
	jne .L715
	mov3q.l #1,%d3
	cmp.l %d2,%d3
	jne .L714
	addq.l #1,pmo+64
.L716:
	addq.l #1,qp+72
	jra .L691
.L715:
	mov3q.l #6,%d5
	cmp.l %d0,%d5
	jne .L717
	mov3q.l #5,%d6
	cmp.l %d2,%d6
	jne .L714
	mvz.b 10(%a5),%d1
	lsr.l #6,%d1
	jne .L714
.L718:
	moveq #127,%d1
	and.l -2147457096,%d1
	mvz.b 7(%a5),%d2
	cmp.l %d2,%d1
	jeq .L727
	addq.l #1,pmo+8
	jra .L716
.L717:
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L828
	mov3q.l #4,%d5
.L719:
	mov3q.l #3,%d3
	cmp.l %d2,%d3
	jge .L714
	move.b 9(%a5),%d1
	mvz.b %d1,%d6
	tst.b %d1
	jeq .L714
	mov3q.l #4,%d7
	cmp.l %d0,%d7
	jne .L829
	move.w #28,%a0
.L720:
	cmp.l %d6,%a0
	jlt .L714
	ext.w %d1
	muls.w %d5,%d1
	addq.l #4,%d1
	cmp.l %d2,%d1
	jne .L714
	lea (10,%a5),%a0
	sub.l %a1,%a1
.L726:
	mvz.b (%a0),%d3
	moveq #12,%d1
	cmp.l %d3,%d1
	jcs .L714
	move.b 1(%a0),%d7
	move.w %d7,%a2
	moveq #63,%d7
	move.l %a2,%d1
	and.l %d7,%d1
	moveq #40,%d7
	move.l %d1,%a3
	subq.l #1,%a3
	cmp.l %a3,%d7
	jcs .L721
	mov3q.l #4,%d7
	cmp.l %d1,%d7
	jeq .L714
	moveq #12,%d7
	cmp.l %d3,%d7
	jne .L722
	moveq #29,%d3
	cmp.l %d1,%d3
	jeq .L714
	moveq #37,%d7
	cmp.l %d1,%d7
	jcs .L714
.L722:
	mov3q.l #4,%d3
	cmp.l %d0,%d3
	jeq .L724
.L725:
	addq.l #1,%a1
	add.l %d5,%a0
	cmp.l %d6,%a1
	jlt .L726
	jra .L718
.L828:
	mov3q.l #5,%d5
	jra .L719
.L829:
	move.w #22,%a0
	jra .L720
.L721:
	move.l %d1,%a3
	mov3q.l #7,%d7
	lea (-48,%a3),%a3
	cmp.l %a3,%d7
	jcs .L723
	moveq #12,%d1
	cmp.l %d3,%d1
	jeq .L714
	mov3q.l #4,%d3
	cmp.l %d0,%d3
	jne .L714
.L724:
	move.l %a2,%d7
	btst #6,%d7
	jeq .L725
	jra .L714
.L723:
	moveq #56,%d7
	cmp.l %d1,%d7
	jne .L714
	moveq #12,%d1
	cmp.l %d3,%d1
	jne .L722
	jra .L714
.L727:
	lea fp,%a0
	mov3q.l #6,%d3
	move.l (%a0),pmo+60
	move.b 8(%a5),%d1
	move.b 7(%a5),%d2
	move.b %d1,-34(%fp)
	move.b %d2,-33(%fp)
	cmp.l %d0,%d3
	jeq .L830
	mvz.b 9(%a5),%d6
.L728:
	mov3q.l #4,%d4
	cmp.l %d0,%d4
	seq %d1
	neg.l %d1
	tst.b %d1
	jeq .L729
	mov3q.l #4,%a3
.L730:
	lea (10,%a5),%a0
	clr.l %d3
	lea pmo,%a2
.L731:
	cmp.l %d3,%d6
	jeq .L716
	mov3q.l #6,%d5
	cmp.l %d0,%d5
	jne .L732
	mvz.b 10(%a5),%d1
	clr.b %d7
	mvz.b 9(%a5),%d2
	clr.b %d5
	lsl.l #7,%d1
	sub.l %a4,%a4
	move.b %d7,-39(%fp)
	or.l %d1,%d2
	move.l %d2,%a1
.L733:
	move.l pmo+56,%d4
	move.l %d4,%d1
	sub.l pmo+80,%d1
	lsr.l #8,%d1
	jeq .L734
	addq.l #1,pmo+4
.L735:
	addq.l #1,%d3
	add.l %a3,%a0
	jra .L731
.L830:
	mov3q.l #1,%d6
	jra .L728
.L729:
	mov3q.l #5,%a3
	jra .L730
.L732:
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
	jne .L831
	move.b 4(%a0),%d5
	jra .L733
.L831:
	clr.b %d5
	jra .L733
.L734:
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
	jra .L735
.L711:
	mov3q.l #1,%d6
	cmp.l %d0,%d6
	jne .L712
	mov3q.l #5,%d7
	cmp.l %d2,%d7
	jne .L712
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
.L739:
	btst %d6,%d3
	jeq .L738
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
.L738:
	addq.l #1,%d6
	moveq #12,%d0
	cmp.l %d6,%d0
	jne .L739
.L740:
	clr.l %d0
	jra .L737
.L712:
	mov3q.l #2,%d1
	cmp.l %d2,%d1
	jne .L741
	cmp.l %d0,%d1
	jne .L710
	mvz.b 7(%a5),%d3
	moveq #12,%d5
	cmp.l %d3,%d5
	jcs .L710
	jsr 1075312702
	clr.l -(%sp)
	move.l %d3,%a0
	pea -1(%a0)
	move.l %d0,%a1
	pea 352(%a1)
	jsr 1074429188
.L916:
	lea (12,%sp),%sp
	jra .L740
.L741:
	mov3q.l #3,%d1
	cmp.l %d2,%d1
	jne .L710
	cmp.l %d0,%d1
	jne .L710
	move.b 7(%a5),%d3
	moveq #11,%d5
	move.l %d3,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d5
	jcs .L710
	move.b 8(%a5),%d5
	jmi .L710
	lsl.l #8,%d5
	jsr 1075398792
	mvz.b %d3,%d3
	move.l %d3,%a0
	and.l #65280,%d5
	move.l %d5,-(%sp)
	pea -1(%a0)
	move.l %d0,-(%sp)
	jsr 1074499748
	jra .L916
.L832:
	clr.l %d0
	jra .L744
.L743:
	tst.l %d2
	jeq .L833
	move.b 6(%a5),%d1
	moveq #127,%d5
	and.l %d5,%d1
.L745:
	mov3q.l #3,%d2
	and.l %d4,%d2
	lea qp,%a0
	move.b %d1,64(%a0,%d2.l*2)
	move.b %d0,65(%a0,%d2.l*2)
	addq.l #1,%d4
	move.l %d4,qp+56
	jra .L691
.L833:
	clr.b %d1
	jra .L745
.L683:
	mov3q.l #2,%d6
	cmp.l %d2,%d6
	jne .L746
	mvz.b 6(%a5),%d0
	moveq #127,%d7
	cmp.l %d0,%d7
	jne .L747
	mvz.b 7(%a5),%d0
	mov3q.l #1,%d1
	cmp.l %d0,%d1
	jcs .L747
	move.l %d0,ls_host_presets
	jra .L691
.L746:
	mov3q.l #1,%d3
	cmp.l %d2,%d3
	jge .L679
.L747:
	mvz.b 6(%a5),%d0
	moveq #126,%d4
	cmp.l %d0,%d4
	jne .L749
	move.b 7(%a5),%d0
	mov3q.l #1,%d5
	and.l %d0,%d5
	move.l %d5,fk_claim
	jra .L691
.L749:
	subq.l #2,%d2
	tst.l %d2
	jne .L679
	moveq #11,%d7
	cmp.l %d0,%d7
	jcs .L679
	mvz.b 7(%a5),%d0
	lsr.l #1,%d0
	jne .L679
	mvz.w 6(%a5),%d0
	move.l %d0,ls_in_v
	addq.l #1,ls_in_gen
	jra .L691
.L700:
	subq.l #6,%d2
	tst.l %d2
	jne .L679
	move.l %a5,%d0
	add.l #12,%d0
	lea (6,%a5),%a0
.L753:
	tst.b (%a0)
	jlt .L679
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L753
	addq.l #1,pc_seq
	clr.l %d0
	lea pc_req,%a0
.L754:
	lea 6(%a5,%d0.l),%a1
	mov3q.l #6,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L754
	addq.l #1,pc_seq
	jra .L691
.L697:
	tst.l %d2
	jeq .L679
	move.b 6(%a5),%d0
	mov3q.l #1,%d3
	mvz.b %d0,%d1
	cmp.l %d1,%d3
	jcs .L679
	jne .L756
	moveq #17,%d4
	cmp.l %d2,%d4
	jne .L679
	move.l %a5,%d1
	add.l #23,%d1
	lea (7,%a5),%a0
.L759:
	mvz.b (%a0),%d2
	moveq #111,%d5
	cmp.l %d2,%d5
	jcs .L679
	addq.l #1,%a0
	cmp.l %a0,%d1
	jne .L759
.L756:
	addq.l #1,led_gen
	move.b %d0,led_req_mode
	clr.l %d0
	lea led_req,%a0
.L760:
	mvz.b 6(%a5),%d1
	subq.l #1,%d1
	tst.l %d1
	jne .L761
	moveq #16,%d3
	cmp.l %d0,%d3
	jne .L762
.L761:
	addq.l #1,led_gen
	jra .L691
.L762:
	lea 7(%a5,%d0.l),%a1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	jra .L760
.L699:
	moveq #14,%d4
	cmp.l %d0,%d4
	jcs .L679
	mvz.w #21504,%d1
	btst %d0,%d1
	jeq .L679
	mvz.b 7(%a5),%d0
	moveq #31,%d5
	cmp.l %d0,%d5
	jcs .L679
	mov3q.l #4,%d6
	cmp.l %d2,%d6
	jge .L764
	mvz.b 10(%a5),%d0
	cmp.l %d0,%d5
	jcs .L679
	mov3q.l #7,%d7
	cmp.l %d2,%d7
	jne .L764
	mvz.b 12(%a5),%d0
	cmp.l %d0,%d5
	jcs .L679
.L764:
	addq.l #1,sq_gen
	clr.l %d0
	lea sq_req,%a0
.L766:
	cmp.l %d2,%d0
	jge .L834
	moveq #127,%d3
	move.b 6(%a5,%d0.l),%d1
	and.l %d3,%d1
.L765:
	move.b %d1,(%a0,%d0.l)
	addq.l #1,%d0
	mov3q.l #7,%d4
	cmp.l %d0,%d4
	jne .L766
	addq.l #1,sq_gen
	jra .L691
.L834:
	clr.b %d1
	jra .L765
.L686:
	subq.l #2,%d2
	tst.l %d2
	jne .L679
	mvz.b 7(%a5),%d0
	moveq #31,%d6
	cmp.l %d0,%d6
	jcs .L679
	lsl.l #7,%d0
	mvz.b 6(%a5),%d1
	addq.l #1,pin+56
	or.l %d0,%d1
	move.l %d1,pin+4
	jra .L691
.L685:
	move.l %d0,%d1
	moveq #14,%d7
	add.l #-10,%d1
	rems.l %d7,%d6:%d1
	tst.l %d6
	jne .L835
	mov3q.l #3,%d1
.L769:
	mov3q.l #2,%d3
	cmp.l %d2,%d3
	jge .L770
	move.b 6(%a5),%d4
	mvz.b %d4,%d5
	cmp.l %d5,%d3
	jcs .L770
	move.b 7(%a5),%d3
	mvz.b %d3,%d7
	move.l %d7,%a0
	mov3q.l #1,%d7
	cmp.l %a0,%d7
	jcs .L770
	tst.l %d6
	jeq .L771
	add.l #-11,%d0
	moveq #14,%d7
	rems.l %d7,%d6:%d0
	tst.l %d6
	jne .L770
.L771:
	mov3q.l #4,%d0
	cmp.l %d1,%d0
	jne .L772
	mvz.b 9(%a5),%d0
	lsr.l #3,%d0
	jeq .L772
.L770:
	addq.l #1,ux+12
	jra .L679
.L835:
	mov3q.l #4,%d1
	jra .L769
.L772:
	ext.w %d4
	tst.b %d3
	jne .L773
	move.l %d5,%a0
	add.l #ux,%a0
	mvz.b 3948(%a0),%d0
	mov3q.l #4,%d7
	cmp.l %d1,%d7
	jne .L774
	mvz.b 9(%a5),%d3
	cmp.l %d0,%d3
	jeq .L775
.L773:
	move.w %d4,%d0
	mulu.w #1280,%d0
	move.l %d0,%a0
	add.l #ux+40,%a0
	mvz.w #128,%d0
.L776:
	clr.b (%a0)
	subq.l #1,%d0
	lea (10,%a0),%a0
	tst.l %d0
	jne .L776
	mov3q.l #4,%d0
	cmp.l %d1,%d0
	jne .L836
.L775:
	move.b 9(%a5),%d3
.L777:
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
.L778:
	move.l %d1,%d0
	add.l #12,%d0
	cmp.l %d2,%d0
	jlt .L783
	addq.l #1,ux+8
	jra .L691
.L836:
	clr.b %d3
	jra .L777
.L783:
	move.b 6(%a2),%d0
	jmi .L779
	ext.w %d0
	move.l %d4,%a0
	mulu.w #10,%d0
	lea 40(%a0,%d0.l),%a1
	sub.l %a0,%a0
	add.l #ux,%a1
.L780:
	move.b 7(%a2,%a0.l),%d3
	moveq #94,%d5
	move.l %d3,%d0
	add.l #-32,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d5
	jcs .L781
	move.b %d3,(%a1,%a0.l)
	addq.l #1,%a0
	moveq #9,%d0
	cmp.l %a0,%d0
	jne .L780
.L781:
	clr.b %d6
	move.b %d6,(%a1,%a0.l)
.L779:
	lea (14,%a2),%a2
	add.l #14,%d1
	jra .L778
.L682:
	move.b 6(%a5),%d1
	moveq #96,%d0
	moveq #64,%d7
	and.l %d1,%d0
	cmp.l %d0,%d7
	jne .L837
	tst.l %d2
	jeq .L679
	mov3q.l #1,%a1
	mov3q.l #2,%d0
.L784:
	cmp.l %d2,%d0
	jne .L679
	mvz.b %d1,%d0
	moveq #111,%d3
	cmp.l %d0,%d3
	jcs .L679
	moveq #-128,%d0
	or.l %d1,%d0
	move.b %d0,-32(%fp)
	move.b 7(%a5),-31(%fp)
	tst.l %a1
	jne .L838
	move.b 8(%a5),%d0
.L787:
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
	jne .L788
	tst.l %a1
	jne .L841
	tst.b 8(%a5)
	jeq .L841
	mvz.w #512,%d0
.L789:
	add.l %a0,%d0
	cmp.l %d0,%d3
	jge .L790
	addq.l #1,din_drop
	jra .L691
.L837:
	sub.l %a1,%a1
	mov3q.l #3,%d0
	jra .L784
.L838:
	clr.b %d0
	jra .L787
.L788:
	lsr.l #5,%d1
	jeq .L841
	mvz.w #1536,%d0
	jra .L789
.L841:
	moveq #8,%d0
	jra .L789
.L790:
	mov3q.l #3,-(%sp)
	pea -32(%fp)
	move.l %d2,-(%sp)
	jsr 1074288478
	lea (12,%sp),%sp
	addq.l #1,din_sent
	jra .L691
.L687:
	subq.l #3,%d2
	tst.l %d2
	jne .L679
	mvz.b 6(%a5),%d0
	moveq #11,%d1
	cmp.l %d0,%d1
	jcs .L679
	tst.b 7(%a5)
	jlt .L679
	mvz.b 8(%a5),%d1
	lsr.l #3,%d1
	jne .L679
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
	jra .L691
.L684:
	move.l ux+3880,%d3
	add.l #-10,%d0
	mov3q.l #2,%d4
	cmp.l %d0,%d4
	jcs .L679
	move.b 6(%a5),%d1
	moveq #11,%d5
	mvz.b %d1,%d0
	cmp.l %d0,%d5
	jcs .L679
	mvz.b 7(%a5),%d0
	lsr.l #4,%d0
	jne .L679
	tst.b 8(%a5)
	jlt .L679
	mov3q.l #3,%d7
	cmp.l %d2,%d7
	jge .L795
	tst.b 9(%a5)
	jlt .L679
	mov3q.l #5,%d0
	cmp.l %d2,%d0
	jne .L795
	tst.b 10(%a5)
	jlt .L679
.L795:
	move.l %d3,%d0
	sub.l ux+3884,%d0
	lea ux,%a0
	lsr.l #3,%d0
	jeq .L796
	addq.l #1,ux+28
	jra .L691
.L796:
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
	jlt .L797
	clr.b %d6
	move.b %d6,3891(%a1)
.L798:
	clr.b %d1
.L800:
	add.l %d0,%a0
	addq.l #1,%d3
	move.b %d1,3952(%a0)
	move.l %d3,ux+3880
	addq.l #1,ux+16
	jra .L691
.L797:
	move.b 9(%a5),3891(%a1)
	subq.l #5,%d2
	tst.l %d2
	jne .L798
	move.b 10(%a5),%d1
	jra .L800
.L698:
	subq.l #4,%d2
	tst.l %d2
	jne .L679
	move.l %a5,%d1
	add.l #10,%d1
	lea (6,%a5),%a0
.L803:
	mvz.b (%a0),%d0
	moveq #111,%d2
	cmp.l %d0,%d2
	jcc .L802
	moveq #127,%d3
	cmp.l %d0,%d3
	jne .L679
.L802:
	addq.l #1,%a0
	cmp.l %d1,%a0
	jne .L803
	addq.l #1,pg_gen
	clr.l %d0
	lea pg_req,%a0
.L804:
	lea 6(%a5,%d0.l),%a1
	mov3q.l #4,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L804
	addq.l #1,pg_gen
	jra .L691
.L696:
	tst.l %d2
	jeq .L679
	move.b 6(%a5),%d0
	moveq #127,%d2
	and.l %d2,%d0
	bset #8,%d0
	move.l %d0,splash_req
	jra .L691
.L695:
	add.l #-10,%d0
	moveq #37,%d3
	cmp.l %d0,%d3
	jcs .L679
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
.L807:
	cmp.l %d2,%d0
	jgt .L810
	mvz.w %d1,%d1
	lea (-32,%fp),%a0
	clr.l %d0
	lea mask_keys,%a1
	move.l %d1,mask_enc
.L811:
	move.l (%a0)+,(%a1,%d0.l*4)
	moveq #8,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L811
	mov3q.l #1,mask_set
	addq.l #1,masks
	jra .L691
.L810:
	move.w %d2,%d3
	mvz.b 9(%a5,%d2.l),%d6
	clr.l %d4
	mulu.w #7,%d3
.L809:
	btst %d4,%d6
	jeq .L808
	cmp.l #255,%d3
	jgt .L808
	moveq #31,%d7
	and.l %d3,%d7
	move.l %d7,%d5
	mov3q.l #1,%d7
	lsl.l %d5,%d7
	move.l %d3,%d5
	asr.l #5,%d5
	or.l %d7,-32(%fp,%d5.l*4)
.L808:
	addq.l #1,%d4
	addq.l #1,%d3
	mov3q.l #7,%d7
	cmp.l %d4,%d7
	jne .L809
	addq.l #1,%d2
	jra .L807
.L690:
	mov3q.l #5,%d3
	cmp.l %d2,%d3
	jge .L812
	move.b 7(%a5),%d1
	moveq #63,%d4
	mvz.b %d1,%d2
	cmp.l %d2,%d4
	jcs .L812
	move.b 8(%a5),%d4
	jmi .L812
	mvz.b 9(%a5),%d3
	lsr.l #6,%d3
	jne .L812
	mvz.b 10(%a5),%d3
	moveq #16,%d6
	cmp.l %d3,%d6
	jcs .L812
	add.l #-13,%d0
	moveq #32,%d7
	cmp.l %d0,%d7
	jge .L842
.L812:
	clr.b %d0
	addq.l #1,rx_bad
	move.b %d0,st_valid
	jra .L675
.L815:
	move.b 12(%a5,%a0.l),%d3
	moveq #94,%d5
	add.l #-32,%d3
	mvz.b %d3,%d3
	cmp.l %d3,%d5
	jcc .L814
	clr.b %d6
	addq.l #1,rx_bad
	move.b %d6,st_valid
	jra .L675
.L814:
	addq.l #1,%a0
.L813:
	cmp.l %d0,%a0
	jlt .L815
	moveq #44,%d7
	ext.w %d1
	muls.l %d7,%d2
	lea rui_big,%a1
	mulu.w #44,%d1
	lea (%a1,%d2.l),%a0
	move.b %d4,4096(%a0)
	move.b 9(%a5),4097(%a0)
	move.b 10(%a5),4098(%a0)
	move.b 11(%a5),4099(%a0)
	move.b %d0,4100(%a0)
	move.l %d1,%a0
	clr.l %d1
	add.l #rui_big+4104,%a0
.L816:
	cmp.l %d0,%d1
	jlt .L817
	add.l %d2,%a1
	add.l %d0,%a1
	clr.b %d0
	moveq #1,%d1
	addq.l #6,%a5
	move.b %d0,4104(%a1)
	move.b %d1,st_valid
	move.b (%a5),st_seq
	jra .L691
.L842:
	sub.l %a0,%a0
	jra .L813
.L817:
	lea 12(%a5,%d1.l),%a2
	move.b (%a2),(%a0,%d1.l)
	addq.l #1,%d1
	jra .L816
.L689:
	tst.l %d2
	jeq .L679
	lea rui_big+4100,%a0
	clr.l %d0
.L819:
	clr.b (%a0)
	addq.l #1,%d0
	lea (44,%a0),%a0
	moveq #64,%d2
	cmp.l %d0,%d2
	jne .L819
	jra .L917
.L688:
	mov3q.l #5,%d4
	cmp.l %d2,%d4
	jge .L679
	move.b 6(%a5),%d1
	moveq #15,%d5
	mvz.b %d1,%d2
	cmp.l %d2,%d5
	jcs .L679
	add.l #-13,%d0
	moveq #11,%d6
	cmp.l %d0,%d6
	jlt .L679
	lea bind_gen,%a1
	addq.l #1,(%a1,%d2.l*4)
	move.b 7(%a5),%d4
	mvz.b %d4,%d5
	lsr.l #6,%d5
	jeq .L822
	st %d4
.L822:
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
.L823:
	cmp.l %d0,%d1
	jlt .L825
	mvz.b 6(%a5),%d0
	addq.l #1,(%a1,%d0.l*4)
	jra .L691
.L825:
	move.b 12(%a5,%d1.l),%d2
	moveq #94,%d6
	move.l %d2,%d4
	add.l #-32,%d4
	mvz.b %d4,%d4
	cmp.l %d4,%d6
	jcc .L824
	move.b %d3,%d2
.L824:
	move.b %d2,6(%a0,%d1.l)
	addq.l #1,%d1
	jra .L823
.L774:
	tst.l %d0
	jne .L773
	jra .L777
	.size	rui_sysex, .-rui_sysex
	.align	2
	.type	ov_suffix, @function
ov_suffix:
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	clr.l %d0
.L920:
	move.l 20(%sp),%a0
	tst.b (%a0,%d0.l)
	jne .L921
	cmp.l %d1,%d0
	jle .L926
.L924:
	clr.l %d0
.L919:
	move.l (%sp)+,%d2
	move.l (%sp)+,%a2
	rts
.L921:
	addq.l #1,%d0
	jra .L920
.L925:
	move.l 20(%sp),%a2
	mvs.b (%a0,%a1.l),%d2
	mvs.b (%a2,%a1.l),%d1
	cmp.l %d2,%d1
	jne .L924
	addq.l #1,%a1
.L922:
	cmp.l %a1,%d0
	jne .L925
	mov3q.l #1,%d0
	jra .L919
.L926:
	add.l 12(%sp),%d1
	sub.l %a1,%a1
	move.l %d1,%a0
	sub.l %d0,%a0
	jra .L922
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
	jne .L928
.L940:
	move.l ov_is,%d0
	jra .L927
.L928:
	move.l %d0,%d1
	add.l #-1073742852,%d1
	move.l %d0,ov_vt
	clr.l ov_is
	clr.l ov_list
	addq.l #1,ov_n
	cmp.l #2997243,%d1
	jls .L930
.L931:
	clr.l %d0
.L927:
	movem.l (%sp),#7180
	lea (20,%sp),%sp
	rts
.L930:
	mov3q.l #3,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L931
	move.l %d0,%a0
	move.l -4(%a0),%d0
	move.l %d0,%d1
	add.l #-1073742848,%d1
	cmp.l #2997247,%d1
	jhi .L931
	btst #0,%d0
	jne .L931
	move.l %d0,%a0
	move.l 4(%a0),%a2
	move.l %a2,%d0
	add.l #-1073742848,%d0
	cmp.l #2997247,%d0
	jhi .L931
.L932:
	move.b (%a2),%d0
	moveq #9,%d1
	add.l #-48,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d1
	jcc .L933
	clr.l %d2
.L934:
	tst.b (%a2,%d2.l)
	jne .L935
	pea .LC5
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	lea ov_suffix,%a3
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L937
	pea .LC0
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jne .L937
	pea .LC1
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
.L937:
	pea .LC2
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	move.l %d0,ov_list
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L938
	moveq #17,%d1
	cmp.l %d2,%d1
	jne .L939
	pea .LC3
	pea 17.w
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	mov3q.l #1,%d1
	eor.l %d1,%d0
.L939:
	move.l %d0,ov_is
	jra .L940
.L933:
	addq.l #1,%a2
	jra .L932
.L935:
	addq.l #1,%d2
	moveq #48,%d0
	cmp.l %d2,%d0
	jne .L934
	jra .L931
.L938:
	pea .LC4
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L941
	mov3q.l #1,ov_is
	jra .L940
.L941:
	lea ov_names,%a4
	clr.l %d3
.L945:
	move.l (%a4)+,%a0
	clr.l %d0
.L942:
	tst.b (%a0,%d0.l)
	jne .L943
	cmp.l %d0,%d2
	jne .L944
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L944
	mov3q.l #1,ov_is
.L944:
	addq.l #1,%d3
	moveq #14,%d0
	cmp.l %d3,%d0
	jne .L945
	jra .L940
.L943:
	addq.l #1,%d0
	jra .L942
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
.L957:
	tst.l %a2
	jeq .L970
	cmp.l 48(%sp),%a2
	jeq .L970
	move.l 8(%a2),%a3
	tst.l %a3
	jne .L958
.L979:
	clr.l %d2
.L959:
	move.l sv+128,%a3
	lea sv,%a2
	tst.l %a3
	jeq .L983
	addq.l #1,sv+136
	tst.l sv+144
	jne .L984
	tst.l 140(%a3)
	jeq .L984
	moveq #11,%d0
	cmp.l %d5,%d0
	jlt .L984
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
	jeq .L984
	moveq #1,%d3
	move.l (%a3),%a0
	clr.l -(%sp)
	move.l %a3,-(%sp)
	move.l 96(%a0),%a0
	jsr (%a0)
	addq.l #1,sv+140
	addq.l #8,%sp
	move.b %d3,32(%a4)
.L984:
	lea (140,%a3),%a3
	move.l (%a3),sv+132
.L983:
	move.b (%a2),%d3
	moveq #11,%d0
	cmp.l %d5,%d0
	jlt .L1009
	tst.l %d2
	jeq .L985
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
	jeq .L985
	tst.b %d3
	jeq .L987
	mvz.b sv+1,%d0
	cmp.l %d5,%d0
	jne .L987
	mvz.b sv+2,%d0
	cmp.l %d0,%d7
	jeq .L988
.L987:
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
.L988:
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	seq %d4
	move.b (%a2),%d5
	neg.l %d4
	move.b %d4,sv+3
	tst.b %d5
	jeq .L991
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jeq .L992
.L991:
	mov3q.l #-1,%d0
.L993:
	move.l 60(%sp),%d3
	move.l %d0,sv+116
	cmp.l sv+20.l,%d3
	jeq .L999
	clr.l sv+16
	sub.l %a0,%a0
.L1000:
	move.l 60(%sp),%d1
	move.l st+4,%a1
	move.l %d1,sv+20
	move.l sv+12,%d1
	move.l st+972,%d7
	tst.b %d5
	jeq .L1001
	mov3q.l #2,%d3
	cmp.l %d2,%d3
	jne .L1002
.L1001:
	clr.l %d3
.L1003:
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
	jne .L1004
	move.l sv+104,%a0
	cmp.l sv+88.l,%a0
	jne .L1004
	tst.l %d2
	jeq .L1005
	move.l st+8,%d1
	moveq #19,%d4
	sub.l sv+108,%d1
	cmp.l %d1,%d4
	jge .L1005
.L1004:
	moveq #1,%d1
	move.b %d1,sv+102
.L1005:
	move.b %d0,sv+100
	mvz.b %d6,%d0
	mvz.b sv+9,%d1
	cmp.l %d0,%d1
	jeq .L956
	tst.l %d3
	jeq .L1007
	addq.l #1,sv+72
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
.L1008:
	moveq #1,%d4
	move.b %d6,sv+9
	move.b %d4,32(%a4)
.L956:
	movem.l (%sp),#31996
	lea (52,%sp),%sp
	rts
.L958:
	move.l (%a3),%d3
	tst.l %d2
	jeq .L960
	cmp.l #1075718412,%d3
	jeq .L961
	cmp.l #1075712228,%d3
	jeq .L961
	cmp.l #1075719596,%d3
	jeq .L961
	cmp.l #1075717140,%d3
	jne .L960
.L961:
	move.l (%a2),%a2
.L962:
	addq.l #1,%d6
	moveq #16,%d3
	cmp.l %d6,%d3
	jne .L957
.L970:
	cmp.l sv+84.l,%d0
	jne .L974
	cmp.l sv+88.l,%a6
	jeq .L975
.L974:
	move.l %d0,sv+84
	move.l %a6,sv+88
	clr.l sv+96
.L976:
	move.l %d6,sv+92
	tst.l %d1
	jeq .L977
	moveq #16,%d0
	cmp.l %d6,%d0
	jeq .L977
	tst.l %a2
	jne .L978
.L977:
	clr.l sv+80
	jra .L979
.L960:
	move.l %d3,%a6
	cmp.l #1075721468,%d3
	jne .L963
	move.l %a3,sv+80
	mov3q.l #1,%d1
.L964:
	tst.l %d2
	jeq .L966
	lea sv_covers,%a0
	sub.l %a1,%a1
.L967:
	cmp.l (%a0),%d3
	jne .L969
.L1012:
	move.l %d2,%d7
.L966:
	cmp.l #1076055292,%d3
	seq %d3
	move.l (%a2),%a2
	move.l %a3,%d0
	mvs.b %d3,%d3
	neg.l %d3
	or.l %d3,%d2
	jra .L962
.L963:
	cmp.l #1075720560,%d3
	jne .L965
	mov3q.l #2,%d0
	or.l %d0,%d1
	move.l %a3,sv+128
	jra .L964
.L965:
	cmp.l #1075628548,%d3
	jne .L964
	tst.b 127(%a3)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d7
	jra .L964
.L969:
	addq.l #4,%a0
	addq.l #1,%a1
	moveq #8,%d0
	cmp.l %a1,%d0
	jne .L967
	move.l %d3,-(%sp)
	move.l %d1,48(%sp)
	jsr overlay
	addq.l #4,%sp
	move.l 44(%sp),%d1
	tst.l %d0
	jne .L1012
	move.l %d2,%a5
	jra .L966
.L975:
	move.l sv+96,%d0
	cmp.l #65534,%d0
	jhi .L976
	addq.l #1,%d0
	move.l %d0,sv+96
	jra .L976
.L978:
	mov3q.l #1,%d3
	eor.l %d3,%d2
	or.l %d7,%d2
	tst.l %a5
	jeq .L981
	cmp.l #1076055292,%a6
	jeq .L981
	moveq #59,%d3
	cmp.l sv+96.l,%d3
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	or.l %d0,%d2
.L981:
	move.l %d2,sv+144
	btst #0,%d1
	jeq .L977
	addq.l #1,%d2
	jra .L959
.L1009:
	clr.l %d2
.L985:
	tst.b %d3
	jeq .L988
	clr.b %d1
	moveq #1,%d3
	lea sv+1,%a0
	move.b (%a0),sv+5
	addq.l #1,sv+60
	move.b %d1,sv
	move.b %d3,sv+4
	move.b %d1,sv+6
	jra .L988
.L992:
	move.l 1100949720,%a2
	move.l %a2,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L991
	jsr sq_grid
	tst.l %d0
	jeq .L991
	move.l 348(%a2),%d1
	tst.l %d1
	jeq .L1074
	clr.l %d0
	jra .L994
.L996:
	addq.l #1,%d0
.L994:
	btst %d0,%d1
	jeq .L996
	jra .L993
.L1074:
	move.l 344(%a2),%d1
	clr.l %d0
	tst.l %d1
	jeq .L991
.L997:
	btst %d0,%d1
	jeq .L998
	add.l #32,%d0
	jra .L993
.L998:
	addq.l #1,%d0
	jra .L997
.L999:
	move.l sv+16,%a0
	cmp.l #65534,%a0
	jhi .L1000
	addq.l #1,%a0
	move.l %a0,sv+16
	jra .L1000
.L1002:
	cmp.l commits.l,%d1
	jeq .L1001
	moveq #19,%d0
	cmp.l %a0,%d0
	jcs .L1001
	move.l %a1,%d3
	or.l %d7,%d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
	jra .L1003
.L1007:
	subq.l #2,%d2
	tst.l %d2
	jne .L1008
	addq.l #1,sv+76
	jra .L1008
	.size	sv_tick, .-sv_tick
	.align	2
	.type	enter, @function
enter:
	move.l %d2,-(%sp)
	move.b 15(%sp),%d1
	move.l 8(%sp),%a0
	tst.l st+4
	jne .L1075
	lea ram_ok,%a1
	btst #0,3(%a1)
	jne .L1077
	moveq #1,%d0
	move.l st+8,%a1
	lea (60,%a1),%a1
	move.l %a1,ram_show_until
	move.b %d0,32(%a0)
.L1075:
	move.l (%sp)+,%d2
	rts
.L1077:
	tst.l st+972
	jeq .L1078
	clr.l st+972
	mov3q.l #6,st+988
.L1078:
	lea commits,%a1
	moveq #16,%d0
	move.l (%a1),st+24
	mov3q.l #1,st+4
	clr.l st+12
	mov3q.l #-1,st+20
	lea st+96,%a1
	addq.l #1,st+48
.L1079:
	clr.l (%a1)+
	subq.l #1,%d0
	tst.l %d0
	jne .L1079
	lea st+408,%a1
.L1080:
	clr.l (%a1)+
	moveq #16,%d2
	addq.l #1,%d0
	cmp.l %d0,%d2
	jne .L1080
	mvz.b %d1,%d0
	moveq #1,%d2
	lea (19,%sp),%a1
	move.b %d1,st+162
	bset #8,%d0
	move.b (%a1),st+993
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
	jra .L1075
	.size	enter, .-enter
	.align	2
	.type	leave, @function
leave:
	move.l %d2,-(%sp)
	move.b 15(%sp),%d1
	tst.l st+4
	jeq .L1083
	clr.l st+4
	clr.l st+1038
	addq.l #1,st+52
	clr.l st+1058
	clr.l st+196
	tst.l nk
	jeq .L1085
	moveq #-33,%d0
	moveq #32,%d2
	and.l %d0,st+240
	or.l %d2,st+272
	clr.l nk
.L1085:
	clr.l %d0
	lea kq_nodown,%a1
	lea kq_owed,%a0
.L1086:
	clr.l (%a1,%d0.l)
	moveq #32,%d2
	clr.l (%a0,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d2
	jne .L1086
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
	jne .L1087
	clr.l st+1006
	jsr led_restore
.L1087:
	moveq #1,%d0
	move.l 8(%sp),%a0
	move.b %d0,32(%a0)
.L1083:
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
	jeq .L1090
	move.l st+8,%d0
	mov3q.l #1,txsx_test_on
	add.l txsx_test,%d0
	clr.l txsx_test
	move.l %d0,txsx_test_end
.L1090:
	tst.l kq_owes
	jeq .L1091
	jsr (kq_owed_in.part.0)
.L1091:
	moveq #31,%d1
	mov3q.l #1,%d0
	and.l %d3,%d1
	move.l %d3,%d2
	lsr.l #5,%d2
	lea kq_nodown,%a0
	move.l (%a0,%d2.l*4),%d4
	lsl.l %d1,%d0
	tst.l 28(%sp)
	jeq .L1092
	move.l %d0,%d1
	not.l %d1
	and.l %d4,%d1
	move.l %d1,(%a0,%d2.l*4)
	tst.l kq_owes
	jne .L1093
	move.l st+196,%d1
	moveq #15,%d5
	move.l %d1,%a1
	addq.l #6,%a1
	cmp.l %a1,%d5
	jcc .L1094
.L1093:
	or.l %d0,%d4
	addq.l #1,st+44
	move.l %d4,(%a0,%d2.l*4)
.L1089:
	movem.l (%sp),#1084
	lea (20,%sp),%sp
	rts
.L1092:
	move.l %d4,%d1
	and.l %d0,%d1
	tst.l %d1
	jeq .L1096
	not.l %d0
	and.l %d4,%d0
	move.l %d0,(%a0,%d2.l*4)
	jra .L1089
.L1096:
	move.l st+196,%d1
	moveq #15,%d4
	cmp.l %d1,%d4
	jcc .L1094
	move.l %d1,%a1
	subq.l #1,%a1
	lea st+164,%a0
.L1097:
	tst.l %a1
	jlt .L1098
	mvz.b (%a0,%a1.l*2),%d4
	cmp.l %d4,%d3
	jne .L1099
	move.l %a1,%d3
	add.l %d3,%d3
	move.l %d3,%d4
	add.l #st,%d4
	move.l %d4,%a2
	tst.b 165(%a2)
	jeq .L1098
	add.l %d3,%a0
.L1100:
	addq.l #1,%a1
	cmp.l %d1,%a1
	jlt .L1101
	subq.l #1,%d1
	move.l %d1,st+196
	addq.l #1,st+44
	jra .L1089
.L1099:
	subq.l #1,%a1
	jra .L1097
.L1101:
	addq.l #2,%a0
	move.b (%a0),-2(%a0)
	move.b 1(%a0),-1(%a0)
	jra .L1100
.L1098:
	lea kq_owed,%a0
	move.l (%a0,%d2.l*4),%d1
	move.l %d1,%d3
	and.l %d0,%d3
	tst.l %d3
	jne .L1089
	or.l %d0,%d1
	addq.l #1,kq_owes
	move.l %d1,(%a0,%d2.l*4)
	jra .L1089
.L1094:
	lea st,%a0
	move.l %d1,%d0
	add.l #82,%d0
	move.b %d3,(%a0,%d0.l*2)
	lea (%a0,%d1.l*2),%a0
	addq.l #1,%d1
	move.l %d1,st+196
	move.b 31(%sp),165(%a0)
	jra .L1089
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
	jne .L1106
	move.l %d0,28(%a0)
	clr.b %d0
	move.l %d1,16(%a0)
.L1107:
	move.b %d0,3(%a0)
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L1106:
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
	jra .L1107
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
.L1109:
	cmp.l pmo+104.l,%d3
	jcs .L1113
	movem.l (%sp),#3084
	lea (16,%sp),%sp
	rts
.L1113:
	move.b (%a2),%d0
	jeq .L1110
	mvz.b %d0,%d0
	move.l 20(%sp),%d1
	subq.l #1,%d0
	btst %d0,%d1
	jeq .L1110
	clr.l 12(%a2)
	tst.l %d2
	jne .L1111
	clr.b %d0
	clr.l 4(%a2)
.L1112:
	move.b %d0,2(%a2)
	move.l %d2,-(%sp)
	clr.l -(%sp)
	move.l %a2,-(%sp)
	jsr (%a3)
	lea (12,%sp),%sp
.L1110:
	addq.l #1,%d3
	lea (44,%a2),%a2
	jra .L1109
.L1111:
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
	jra .L1112
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
	jeq .L1120
	move.l %d2,-(%sp)
	jsr cu_src_setup
	mvz.b cu+1,%d0
	move.l %d2,%d4
	addq.l #4,%sp
	add.l #-43,%d4
	cmp.l %d0,%d2
	jne .L1122
	move.l 1075597888,%d0
	cmp.l 4(%a2),%d0
	jne .L1122
	move.l 1075596172,%d0
	cmp.l 116(%a2),%d0
	jne .L1122
	move.l 1075597884,%d1
	moveq #9,%d0
	cmp.l %d4,%d0
	jcs .L1126
	lea CSWTCH.619,%a0
	move.l (%a0,%d4.l*4),%d0
.L1123:
	cmp.l %d0,%d1
	jeq .L1120
.L1122:
	lea cu_p2,%a3
	clr.l %d3
	lea CSWTCH.619,%a5
	lea cu_knob,%a4
.L1125:
	moveq #9,%d0
	cmp.l %d4,%d0
	jcs .L1127
	move.l (%a5,%d4.l*4),%d0
.L1124:
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
	jne .L1125
	move.w cu+2,%d0
	move.b %d2,cu+1
	addq.l #1,%d0
	move.w %d0,cu+2
.L1120:
	movem.l (%sp),#15388
	lea (28,%sp),%sp
	rts
.L1126:
	move.l #cu_fm_short,%d0
	jra .L1123
.L1127:
	move.l #cu_fm_short,%d0
	jra .L1124
	.size	cu_setup, .-cu_setup
	.align	2
	.type	isr_send, @function
isr_send:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 16(%sp),%d1
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jeq .L1133
.L1141:
	clr.l %d0
.L1132:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L1133:
#APP
| 1852 "rui.c" 1
	move.w %sr,%d0
| 0 "" 2
#NO_APP
	move.l %d0,%d3
	move.l %d0,%d2
	and.l #1792,%d3
	mvz.w %d2,%d2
	cmp.l #1279,%d3
	jhi .L1135
	and.l #63743,%d0
	or.l #1280,%d0
#APP
| 1856 "rui.c" 1
	move.w %d0,%sr
| 0 "" 2
#NO_APP
.L1135:
	tst.l 1123449384
	jeq .L1136
.L1138:
#APP
| 1861 "rui.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	addq.l #1,sq+388
	jra .L1141
.L1136:
	tst.l 1094562372
	jne .L1138
	move.l %d1,%d0
	add.l 1094562392,%d0
	cmp.l #3800,%d0
	jgt .L1138
	move.l 1094562704,%a0
	tst.l %a0
	jeq .L1138
	move.l 52(%a0),%a0
	tst.l %a0
	jeq .L1138
	move.l 52(%a0),%d0
	move.l 12(%sp),-(%sp)
	move.l %d1,-(%sp)
	jsr 1073752544
#APP
| 1861 "rui.c" 1
	move.w %d2,%sr
| 0 "" 2
#NO_APP
	mov3q.l #1,%d0
	addq.l #8,%sp
	jra .L1132
	.size	isr_send, .-isr_send
	.align	2
	.globl	rui_render_in
	.type	rui_render_in, @function
rui_render_in:
	link.w %fp,#-112
	movem.l #1084,(%sp)
	tst.l 1094562372
	jne .L1149
	mov3q.l #1,txsx_gap
.L1149:
	lea fp,%a0
	addq.l #1,(%a0)
	tst.l fp+8
	jeq .L1150
	move.l (%a0),%d0
	sub.l fp+4,%d0
	cmp.l #3000,%d0
	jls .L1150
	move.l fp+8,%a0
	move.l fp,%d0
	move.l fp+4,%d1
	move.l 1123449124,%d2
	tst.l fp+12
	jeq .L1151
	move.l fp,%a1
	sub.l fp+12,%a1
	cmp.l #7499,%a1
	jls .L1150
.L1151:
	cmp.l %a0,%d2
	seq %d3
	sub.l %d1,%d0
	lea (-90,%fp),%a1
	clr.l %d1
	move.l %a1,%d4
	neg.l %d3
.L1152:
	move.l %d4,%a2
	addq.l #1,%d1
	clr.l (%a2)+
	moveq #9,%d5
	move.l %a2,%d4
	cmp.l %d1,%d5
	jne .L1152
	cmp.l %a0,%d2
	jeq .L1153
	mov3q.l #1,%d1
	move.l 72(%a0),%d2
	and.l %d2,%d1
	btst #0,%d2
	jne .L1153
	move.l %d2,%a0
	add.l #-1073741824,%a0
	cmp.l #129892303,%a0
	jhi .L1153
.L1154:
	move.l %d2,%a0
	moveq #36,%d4
	lea 4(%a0,%d1.l),%a2
	move.l (%a2),(%a1,%d1.l)
	addq.l #4,%d1
	cmp.l %d1,%d4
	jne .L1154
.L1153:
	move.w #19969,%a0
	move.l #-260222380,%d5
	move.b %d3,-48(%fp)
	move.l %d5,-54(%fp)
	move.w %a0,-50(%fp)
	cmp.l #191999,%d0
	jhi .L1166
	mvz.w #1500,%d2
	divu.l %d2,%d0
.L1155:
	move.b %d0,-47(%fp)
	lea (-46,%fp),%a0
	clr.l %d1
.L1156:
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
	jne .L1156
	moveq #-9,%d5
	pea 54.w
	pea -54(%fp)
	move.b %d5,-1(%fp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1150
	lea fp,%a0
	tst.l (%a0)
	jeq .L1167
	move.l (%a0),%d0
.L1158:
	move.l %d0,fp+12
	addq.l #1,fp+16
.L1150:
	move.l 1123623180,%d0
	move.l qp,%d4
	move.l qp+8,%d3
	tst.l qp+12
	jne .L1159
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
.L1159:
	tst.l qp+24
	jne .L1160
	cmp.l qp+16.l,%d0
	jne .L1161
	move.l qp+20,%a2
	cmp.l 1123623184.l,%a2
	jeq .L1160
.L1161:
	mov3q.l #1,qp+24
.L1160:
	tst.l qp+4
	jeq .L1148
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
	jne .L1163
	cmp.l qp+36.l,%d3
	jeq .L1148
.L1163:
	move.l fp,%d1
	moveq #11,%d5
	sub.l qp+32,%d1
	cmp.l %d1,%d5
	jcc .L1148
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
	jeq .L1148
	move.l qp+40,%d0
	tst.l %d0
	jeq .L1164
	move.l qp+84,%a0
	move.l qp+32,%d1
	tst.l %a0
	jeq .L1165
	move.l fp,%a1
	sub.l %d1,%a1
	cmp.l %a0,%a1
	jcc .L1164
.L1165:
	move.l fp,%d4
	sub.l %d1,%d4
	move.l %d4,qp+84
.L1164:
	lea fp,%a1
	addq.l #1,%d0
	move.l %d2,qp+28
	move.l %d3,qp+36
	move.l %d0,qp+40
	move.l (%a1),qp+32
.L1148:
	movem.l -112(%fp),#1084
	unlk %fp
	rts
.L1166:
	moveq #127,%d0
	jra .L1155
.L1167:
	mov3q.l #1,%d0
	jra .L1158
	.size	rui_render_in, .-rui_render_in
	.align	2
	.globl	smpl_hold
	.type	smpl_hold, @function
smpl_hold:
	move.l 4(%sp),%a0
	move.l #1075720560,%d0
	move.b 1093765506,%d1
	cmp.l (%a0),%d0
	jeq .L1193
.L1195:
	clr.l %d0
.L1194:
	rts
.L1193:
	mvz.b %d1,%d0
	move.l %d0,%a1
	moveq #11,%d0
	cmp.l %a1,%d0
	jlt .L1195
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
	jra .L1194
	.size	smpl_hold, .-smpl_hold
	.align	2
	.globl	rui_uart
	.type	rui_uart, @function
rui_uart:
	lea (-40,%sp),%sp
	movem.l #19468,(%sp)
	clr.l %d2
	tst.b ov_on.l
	jne .L1211
	tst.b ovp_on.l
	jne .L1211
	tst.b ovt_on.l
	jeq .L1198
.L1211:
	move.l 44(%sp),%a0
	subq.l #1,%a0
	sub.l %a6,%a6
	lea rui_uart_raw,%a3
	move.l %a0,20(%sp)
	jra .L1203
.L1199:
	move.l 48(%sp),%a0
	mvz.b (%a0,%d2.l),%d0
	addq.l #1,%d2
	move.l %d0,-(%sp)
	jsr uart_byte
	addq.l #4,%sp
.L1198:
	cmp.l 44(%sp),%d2
	jlt .L1199
	clr.l %d0
.L1196:
	movem.l (%sp),#19468
	lea (40,%sp),%sp
	rts
.L1204:
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
	jeq .L1201
	cmp.l 20(%sp),%a6
	jne .L1202
.L1201:
	pea 24(%sp)
	move.l %d3,-(%sp)
	jsr (%a3)
	addq.l #8,%sp
	clr.l %d3
.L1202:
	addq.l #1,%a6
	move.l %d3,%d2
.L1203:
	cmp.l 44(%sp),%a6
	jlt .L1204
	mov3q.l #1,%d0
	jra .L1196
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
	jcc .L1213
.L1217:
	clr.l %d0
.L1212:
	move.l (%sp)+,%d2
	rts
.L1213:
	tst.l sq
	jeq .L1215
	move.l sq+4,%a0
	move.l %a0,%d2
	btst %d1,%d2
	jeq .L1215
	addq.l #1,sq+448
	mov3q.l #1,%d0
	jra .L1212
.L1215:
	tst.l %d0
	jlt .L1218
	moveq #63,%d2
	cmp.l %d0,%d2
	jlt .L1219
.L1216:
	lea pc,%a0
	move.b %d0,48(%a0,%d1.l)
	moveq #1,%d0
	lea st+8,%a1
	move.l (%a1),(%a0,%d1.l*4)
	move.b %d0,60(%a0,%d1.l)
	jra .L1217
.L1218:
	clr.b %d0
	jra .L1216
.L1219:
	moveq #63,%d0
	jra .L1216
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
	jcs .L1226
	mov3q.l #1,%d1
	cmp.l 1079807120.l,%d1
	jeq .L1228
	clr.l sq+540
	clr.l sq+544
.L1226:
	movem.l (%sp),#3132
	lea (24,%sp),%sp
	rts
.L1228:
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
	jeq .L1230
	mvz.b 516(%a0),%d1
	cmp.l %d4,%d1
	jeq .L1231
.L1232:
	clr.l %d0
.L1230:
	mov3q.l #1,%d1
	lsl.l %d2,%d1
	move.l %a1,%d5
	move.b %d3,516(%a0)
	move.b 35(%sp),528(%a0)
	or.l %d1,%d5
	move.l sq+360,%d1
	move.l %d5,sq+540
	btst #8,%d1
	jeq .L1234
	tst.l %d0
	jne .L1226
	tst.l %d4
	jeq .L1235
	tst.l sq+544
	jeq .L1236
.L1235:
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
.L1236:
	lsr.l #7,%d4
	jne .L1226
	tst.l (%a2)
	jeq .L1226
	move.l sq+8,%d0
	btst %d2,%d0
	jeq .L1226
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
	jne .L1237
	mvz.w #917,%d0
	muls.l %d2,%d0
	add.l #709,%d0
	move.b (%a0,%d0.l),%d0
	jpl .L1239
	moveq #127,%d0
.L1239:
#APP
| 1852 "rui.c" 1
	move.w %sr,%d1
| 0 "" 2
#NO_APP
	move.l %d1,%d5
	move.l %d1,%d4
	and.l #1792,%d5
	mvz.w %d4,%d4
	cmp.l #1792,%d5
	jeq .L1241
	and.l #63743,%d1
	or.l #1792,%d1
#APP
| 1856 "rui.c" 1
	move.w %d1,%sr
| 0 "" 2
#NO_APP
.L1241:
	move.l sq+268,%d1
	sub.l sq+272,%d1
	lsr.l #5,%d1
	jeq .L1242
	addq.l #1,sq+380
.L1243:
#APP
| 1861 "rui.c" 1
	move.w %d4,%sr
| 0 "" 2
#NO_APP
	jra .L1226
.L1231:
	mvz.b 528(%a0),%d1
	cmp.l 32(%sp),%d1
	jeq .L1232
	addq.l #1,sq+548
	mov3q.l #1,sq+544
	jra .L1230
.L1234:
	tst.l %d0
	jne .L1226
	jra .L1236
.L1237:
	move.l #85683,%d0
	move.b (%a0,%d0.l),%d0
	move.l #85684,%d1
	mvz.b (%a0,%d1.l),%d1
	mvz.b %d0,%d0
	lsl.l #8,%d0
	or.l %d1,%d0
	moveq #127,%d1
	cmp.l %d0,%d1
	jcc .L1239
	moveq #127,%d0
	jra .L1239
.L1242:
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
	jra .L1243
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
	jcc .L1257
	clr.l %d2
.L1257:
	tst.l sq+348
	jne .L1258
	move.l %d2,sq+352
	move.l %d3,sq+356
	mov3q.l #1,sq+348
.L1258:
	lea sq,%a6
	tst.l (%a6)
	jeq .L1259
	cmp.l sq+352.l,%d2
	jeq .L1260
	move.l %d2,%d1
	mvz.b %d1,%d1
	move.l %d4,-(%sp)
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr sq_event
	lea (20,%sp),%sp
.L1260:
	move.l sq+356,%d0
	cmp.l %d0,%d3
	jeq .L1261
	mov3q.l #1,%d1
	cmp.l %d2,%d1
	jne .L1262
	bset #8,%d0
	move.l %d0,sq+360
.L1259:
	move.l %d2,sq+352
	move.l %d3,sq+356
.L1264:
	tst.l sq+344
	jne .L1269
	move.l %sp,%d3
	move.l %sp,%d2
	add.l #42,%d3
	add.l #36,%d2
.L1270:
	move.l sq+272,%d4
	cmp.l sq+268.l,%d4
	jne .L1276
.L1275:
	move.l -66650100,%d0
	sub.l 32(%sp),%d0
	cmp.l sq+396.l,%d0
	jls .L1256
	move.l %d0,sq+396
.L1256:
	movem.l (%sp),#23612
	lea (104,%sp),%sp
	rts
.L1262:
	mvz.b %d0,%d0
	move.l %d4,-(%sp)
	mov3q.l #2,-(%sp)
	move.l %d5,-(%sp)
	move.l %d0,-(%sp)
	mov3q.l #3,-(%sp)
	jsr sq_event
	lea (20,%sp),%sp
.L1263:
	move.l sq+360,%d0
	btst #8,%d0
	jeq .L1259
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
	jra .L1259
.L1261:
	mov3q.l #1,%d0
	cmp.l %d2,%d0
	jne .L1263
	jra .L1259
.L1269:
	mvz.b sq+340,%d0
	move.l %d0,-(%sp)
	pea sq+276
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1256
	move.l sq+344,%d3
	clr.l %d1
	addq.l #1,sq+376
	lea sq+340,%a0
.L1266:
	cmp.l %d3,%d0
	jlt .L1268
	subq.l #1,%d3
	move.l %d3,sq+344
	jra .L1264
.L1268:
	mvz.w %d0,%d2
	lea sq+276,%a2
	sub.l %a1,%a1
	sub.l %d1,%a2
	lsl.l #4,%d2
.L1267:
	move.l %a2,%d4
	add.l %d1,%d4
	move.l %d4,%a4
	addq.l #1,%a1
	move.b (%a4,%d2.l),(%a2)+
	moveq #16,%d4
	cmp.l %a1,%d4
	jne .L1267
	move.b 1(%a0),(%a0)
	addq.l #1,%a0
	addq.l #1,%d0
	add.l #-16,%d1
	jra .L1266
.L1276:
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
.L1271:
	move.l sq+272,%d0
	add.l %d4,%d0
	cmp.l sq+268.l,%d0
	jeq .L1272
	moveq #14,%d0
	cmp.l %d4,%d0
	jeq .L1272
	move.l sq+272,%d0
	moveq #31,%d1
	add.l %d4,%d0
	and.l %d1,%d0
	lsl.l #3,%d0
	cmp.l 12(%a6,%d0.l),%d5
	jeq .L1273
.L1272:
	move.b %d4,46(%sp)
	move.b #-9,(%a0)+
	sub.l %d2,%a0
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	jsr isr_send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1275
	add.l %d4,sq+272
	addq.l #1,sq+372
	jra .L1270
.L1273:
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
	jra .L1271
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
	jne .L1297
	move.l pin+16,%d0
	move.l pin+12,%d1
	addq.l #1,pin+32
	move.l %d0,50(%sp)
	or.l 58(%sp),%d0
	or.l %d1,%d0
	jeq .L1297
	move.l pin+20,%a1
	tst.l %a1
	jne .L1299
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
.L1299:
	clr.b %d4
	clr.b %d5
	sub.l %a0,%a0
	clr.l %d3
	move.l pin+8,%d2
	clr.l %d6
	move.l pin+48,%a6
	move.b %d4,63(%sp)
	move.b %d5,62(%sp)
.L1313:
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
	jcs .L1300
	move.l 58(%sp),%d5
	move.l %a4,%d7
	btst %d7,%d5
	jeq .L1300
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
	jeq .L1301
	move.l #128,(%a3)
	move.l #128,(%a2)
	move.l %a1,4(%a3)
	move.l %a1,4(%a2)
	tst.l %a5
	jeq .L1302
	addq.l #1,pin+44
.L1302:
	moveq #1,%d0
	and.l 54(%sp),%d2
	move.b %d0,62(%sp)
.L1303:
	move.l 46(%sp),%a2
	add.l #-2147457816,%a2
	clr.l (%a2)
	cmp.l #32512,%d5
	jeq .L1318
	cmp.l #255,%d5
	jls .L1306
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
	jls .L1307
	mvz.w #65535,%d4
.L1307:
	mulu.w #32512,%d0
	move.w %d4,(%a3)
	divu.l %d5,%d0
	cmp.l #65535,%d0
	jls .L1308
	mvz.w #65535,%d0
.L1308:
	move.w %d0,(%a2)
.L1306:
	moveq #1,%d0
	move.w #32512,(%a0)
	addq.l #1,%a6
	move.b %d0,63(%sp)
.L1318:
	move.w #1,%a0
	jra .L1305
.L1301:
	tst.l %a5
	jeq .L1304
	moveq #127,%d0
	moveq #127,%d4
	move.l %d0,(%a3)
	move.l pin+28,%d0
	move.l %d4,(%a2)
	move.l %d0,4(%a3)
	move.l %d0,4(%a2)
	jra .L1303
.L1304:
	moveq #1,%d4
	move.l pin+24,%d7
	move.l #1073741951,(%a3)
	move.l #1073741951,(%a2)
	move.l %d7,4(%a3)
	or.l %d0,%d2
	move.l %d7,4(%a2)
	addq.l #1,pin+40
	move.b %d4,62(%sp)
	jra .L1303
.L1300:
	move.l 50(%sp),%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L1309
	move.l %d0,%d4
	not.l %d4
	and.l %d4,%d2
	moveq #1,%d4
	or.l %d0,%d1
	move.w #1,%a0
	move.b %d4,62(%sp)
.L1309:
	move.l %d1,%d4
	and.l %d0,%d4
	tst.l %d4
	jeq .L1305
	btst #6,(%a2)
	jeq .L1311
	not.l %d0
	and.l %d0,%d1
	jra .L1318
.L1311:
	move.l #128,(%a3)
	move.l #128,(%a2)
	move.l %a1,4(%a3)
	move.l %a1,4(%a2)
.L1305:
	addq.l #1,%d3
	moveq #8,%d5
	cmp.l %d3,%d5
	jne .L1313
	tst.b 63(%sp)
	jeq .L1314
	move.l %a6,pin+48
.L1314:
	tst.b 62(%sp)
	jeq .L1315
	move.l %d2,pin+8
.L1315:
	move.w %a0,%d7
	tst.b %d7
	jeq .L1316
	move.l %d1,pin+12
.L1316:
	tst.l %d6
	jeq .L1317
	addq.l #1,pin+36
.L1317:
	move.l -66650100,%d0
	move.l %d6,pin+16
	sub.l 68(%sp),%d0
	cmp.l pin+52.l,%d0
	jls .L1297
	move.l %d0,pin+52
.L1297:
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
	jcc .L1345
.L1347:
	clr.l %d1
.L1346:
	move.l %d1,16(%sp)
	move.l %a0,%d1
	mvz.b %d1,%d1
	clr.l 12(%sp)
	move.l %d0,4(%sp)
	move.l %d1,8(%sp)
	jra ed_queue
.L1345:
	mvz.w #4368,%d1
	btst %d0,%d1
	jeq .L1347
	mov3q.l #3,%d1
	and.l 12(%sp),%d1
	jra .L1346
	.size	ed_report, .-ed_report
	.align	2
	.globl	pm_menu_add
	.type	pm_menu_add, @function
pm_menu_add:
	link.w %fp,#-68
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	tst.l 8(%fp)
	jeq .L1351
	lea (-64,%fp),%a2
	clr.l %d0
	move.l %a2,%a0
.L1353:
	clr.l 12(%a0)
	clr.l 8(%a0)
	clr.l (%a0)
	clr.l 4(%a0)
	addq.l #1,%d0
	lea (16,%a0),%a0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L1353
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
	jeq .L1351
	tst.l %a3
	jeq .L1351
	tst.l -32(%fp)
	jeq .L1351
	tst.l %d0
	jeq .L1351
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
.L1354:
	mvz.w -66(%fp),%d0
	lsl.l #4,%d0
	pea (%a2,%d0.l)
	jsr 1075251654
	subq.l #1,-68(%fp)
	addq.l #4,%sp
	mov3q.l #-1,%d0
	cmp.l -68(%fp),%d0
	jne .L1354
	addq.l #1,pm+4
.L1351:
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
	jcc .L1367
	addq.l #1,pm+24
	pea pm_t_track
.L1371:
	move.l %a0,-(%sp)
	jsr pm_popup
	addq.l #8,%sp
	rts
.L1367:
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L1369
	move.l commits,%d1
	cmp.l pm+28.l,%d1
	jne .L1370
.L1369:
	addq.l #1,pm+20
	pea pm_t_none
	jra .L1371
.L1370:
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
	jeq .L1372
	move.l %d2,-(%sp)
	addq.l #1,cu+12
	jsr cu_src_setup
	addq.l #4,%sp
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-48,%d0
	cmp.l %d0,%d1
	jcc .L1374
	moveq #43,%d0
	cmp.l %d2,%d0
	jne .L1372
.L1374:
	moveq #11,%d1
	cmp.l 12(%sp),%d1
	jcs .L1372
	move.l #1075731444,%a0
	cmp.l sv+88.l,%a0
	jne .L1372
	lea (15,%sp),%a0
	mvz.b cu+30,%d0
	move.b (%a0),cu+10
	lea st+8,%a0
	move.b %d2,cu+9
	move.l (%a0),cu+16
	cmp.l 12(%sp),%d0
	jne .L1376
	move.b cu+28,%d0
.L1375:
	move.b %d0,cu+29
.L1372:
	move.l (%sp)+,%d2
	rts
.L1376:
	clr.b %d0
	jra .L1375
	.size	cu_prep, .-cu_prep
	.align	2
	.globl	cu_mi_settling
	.type	cu_mi_settling, @function
cu_mi_settling:
	mvz.b cu+11,%d1
	move.l 4(%sp),%d0
	addq.l #1,%d0
	cmp.l %d1,%d0
	jne .L1379
	move.l st+8,%d0
	moveq #15,%d1
	sub.l cu+24,%d0
	cmp.l %d0,%d1
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1377:
	rts
.L1379:
	clr.l %d0
	jra .L1377
	.size	cu_mi_settling, .-cu_mi_settling
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
	jne .L1381
	move.l pmo+96,%d2
	cmp.l pmo+76.l,%d2
	jeq .L1382
.L1381:
	lea pmo+76,%a0
	move.l %d0,pmo+100
	move.l (%a0),pmo+96
	tst.l pmo
	jeq .L1382
	lea pmo+584,%a0
	clr.l %d0
.L1383:
	clr.l (%a0)+
	addq.l #1,%d0
	cmp.l #208,%d0
	jne .L1383
	lea pmo+3464,%a0
	clr.l %d0
.L1384:
	clr.b (%a0)
	addq.l #1,%d0
	lea (44,%a0),%a0
	cmp.l #128,%d0
	jne .L1384
	clr.l %d0
.L1385:
	move.l %d0,%d1
	add.l #36,%d1
	clr.l (%a2,%d1.l*4)
	moveq #13,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1385
	clr.l pmo
	clr.l pmo+104
	clr.l pmo+9096
	clr.l pmo+300
	addq.l #1,pmo+32
.L1382:
	move.l pmo+56,%d7
	move.l pmo+88,%d2
	cmp.l pmo+68.l,%d2
	jne .L1386
	move.l pmo+92,%d3
	cmp.l pmo+72.l,%d3
	jeq .L1448
.L1386:
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
.L1387:
	moveq #65,%d6
	sub.l %a4,%a4
	clr.l %d4
	lea pmo_get,%a5
.L1388:
	move.l pmo+80,%d2
	cmp.l %d2,%d7
	jeq .L1404
	subq.l #1,%d6
	tst.l %d6
	jne .L1405
.L1404:
	tst.l %d4
	jeq .L1406
.L1392:
	move.l %a4,-(%sp)
	move.l %d4,-(%sp)
	jsr pmo_fade
	addq.l #8,%sp
	mov3q.l #1,%d5
.L1406:
	tst.l pmo
	jne .L1407
.L1438:
	move.l 56(%sp),-(%sp)
	jsr pmo_time
	addq.l #4,%sp
	movem.l (%sp),#31996
	lea (80,%sp),%sp
	rts
.L1448:
	clr.l %d5
	jra .L1387
.L1405:
	mvz.b %d2,%d2
	move.l %d2,%d3
	lsl.l #3,%d3
	lea (%a2,%d3.l),%a0
	mvz.b 1423(%a0),%d0
	cmp.l pmo+100.l,%d0
	jeq .L1389
	addq.l #1,pmo+8
.L1390:
	addq.l #1,pmo+80
	jra .L1388
.L1389:
	mvz.b 1418(%a0),%d0
	mov3q.l #6,%d1
	move.l %d0,%a1
	cmp.l %d0,%d1
	jne .L1391
	mvz.w 1420(%a0),%d0
	mvz.b 1419(%a0),%d2
	addq.l #1,pmo+28
	or.l %d0,%d4
	move.l %d2,%a4
	jra .L1390
.L1391:
	tst.l %d4
	jne .L1392
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
	jne .L1393
	mvz.w 1420(%a0),%d2
	moveq #18,%d0
	lsl.l %d0,%d2
	move.l %d2,%a0
	asr.l %d0,%d2
	tst.l %a0
	jne .L1394
	move.l %d1,%d0
	lsl.l #6,%d0
	lea (%a2,%d0.l),%a0
	add.l 52(%sp),%a0
	tst.b 584(%a0)
	jeq .L1390
.L1394:
	move.l 52(%sp),-(%sp)
	move.l %d1,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
	move.l %d0,%a0
	tst.l %d0
	jne .L1396
	addq.l #1,pmo+16
	mov3q.l #4,pmo+120
	jra .L1390
.L1396:
	moveq #10,%d1
	lsl.l %d1,%d2
	move.l %d3,%a1
	add.l #pmo+1419,%a1
	move.b (%a1),%d0
	move.l %d2,12(%a0)
	tst.b %d0
	jne .L1397
	move.l %d2,4(%a0)
.L1398:
	move.b %d0,2(%a0)
	jra .L1390
.L1397:
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
	jra .L1398
.L1393:
	move.b 1422(%a0),%d0
	mvz.b %d0,%d2
	move.w %d0,%a1
	moveq #126,%d0
	move.l %d2,%a6
	cmp.l %d2,%d0
	jcs .L1449
	move.w %a1,%d2
	tst.b %d2
	jeq .L1400
	move.l %a6,%d0
	move.l #66052,%d2
	muls.l %d2,%d0
	move.l %d0,%a6
.L1399:
	move.l 52(%sp),-(%sp)
	move.l %d1,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
	move.l %d0,%a0
	tst.l %d0
	jne .L1401
	addq.l #1,pmo+16
	mov3q.l #5,pmo+120
	jra .L1390
.L1400:
	move.l %d1,%d0
	lsl.l #6,%d0
	lea (%a2,%d0.l),%a0
	add.l 52(%sp),%a0
	tst.b 584(%a0)
	jeq .L1390
	sub.l %a6,%a6
	jra .L1399
.L1449:
	move.l #8388608,%a6
	jra .L1399
.L1401:
	move.l %d3,%a1
	add.l #pmo+1420,%a1
	mvz.w (%a1),%d1
	moveq #9,%d2
	lsl.l %d2,%d1
	move.l %d1,24(%a0)
	tst.l 28(%a0)
	jne .L1402
	tst.b 3(%a0)
	jne .L1402
	move.l %d1,16(%a0)
.L1402:
	move.l 60(%sp),%d2
	lsl.l #3,%d2
	move.b 1(%a2,%d2.l),%d1
	btst #6,%d1
	jne .L1450
	move.l %d3,%a1
	add.l #pmo+1419,%a1
	mvz.b (%a1),%d1
.L1403:
	move.l %d1,-(%sp)
	move.l %a6,-(%sp)
	move.l %a0,-(%sp)
	jsr pmo_mix
	lea (12,%sp),%sp
	jra .L1390
.L1450:
	clr.l %d1
	jra .L1403
.L1407:
	tst.l %d5
	jne .L1409
	move.l pmo+84,%d3
	cmp.l pmo+60.l,%d3
	jeq .L1409
	move.l (%a3),%d0
	sub.l pmo+60,%d0
	cmp.l #375,%d0
	jls .L1409
	lea pmo+60,%a0
	move.l (%a0),pmo+84
	pea 32.w
	pea 8191.w
	addq.l #1,pmo+12
	jsr pmo_fade
	addq.l #8,%sp
.L1409:
	tst.l -2147418904
	jeq .L1410
	lea pmo+512,%a0
	clr.l %d0
.L1411:
	clr.l (%a0)+
	moveq #18,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1411
	move.l #-2147423060,%a0
.L1413:
	move.w (%a0),%d1
	mvz.w %d1,%d0
	cmp.l #571,%d0
	jhi .L1412
	moveq #31,%d3
	lsr.l #5,%d0
	and.l %d3,%d1
	mov3q.l #1,%d3
	add.l #128,%d0
	lsl.l %d1,%d3
	or.l %d3,(%a2,%d0.l*4)
.L1412:
	addq.l #2,%a0
	cmp.l #-2147422964,%a0
	jne .L1413
.L1410:
	move.l pmo+104,%a1
	clr.l %d2
	clr.l pmo+300
	lea pmo,%a4
	lea pmo+3464,%a0
.L1414:
	cmp.l %a1,%d2
	jne .L1428
	lea pmo+3464,%a0
	clr.b %d0
.L1431:
	tst.l %d2
	jne .L1429
	tst.b %d0
	jeq .L1430
	clr.l pmo+104
.L1430:
	move.l pmo+300,%d2
	move.l #-2147420170,%a2
	lea pmo,%a0
	clr.l %d1
	move.l #-2147457058,%a1
	jra .L1436
.L1428:
	move.b (%a0),%d1
	jeq .L1415
	move.b 2(%a0),%d0
	jeq .L1416
	subq.l #1,%d0
	move.b %d0,2(%a0)
	jeq .L1417
	move.l 8(%a0),%d4
	add.l %d4,4(%a0)
.L1416:
	move.b 3(%a0),%d0
	jeq .L1418
	subq.l #1,%d0
	move.b %d0,3(%a0)
	jeq .L1419
	move.l 20(%a0),%d5
	move.l 32(%a0),%d0
	add.l %d5,16(%a0)
	add.l %d0,28(%a0)
.L1418:
	move.b 1(%a0),%d4
	move.l 4(%a0),%d0
	mvz.b %d4,%d3
	tst.l %d0
	jne .L1420
	tst.b 2(%a0)
	jne .L1420
	tst.l 28(%a0)
	jne .L1420
	tst.b 3(%a0)
	jne .L1420
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
.L1415:
	addq.l #1,%d2
	lea (44,%a0),%a0
	jra .L1414
.L1417:
	move.l 12(%a0),4(%a0)
	jra .L1416
.L1419:
	move.l 24(%a0),16(%a0)
	move.l 36(%a0),28(%a0)
	jra .L1418
.L1420:
	moveq #8,%d5
	cmp.l %d3,%d5
	jcs .L1421
	move.l 40(%a0),%d1
	move.l %d1,%d3
	add.l %d3,%d3
	move.l 28(%a0),%d4
	move.l %d3,%a5
	add.l #-2147420300,%a5
	mvz.w (%a5),%d3
	tst.l %d4
	jeq .L1424
	tst.l -2147418904
	jeq .L1423
	move.l %d1,%d5
	lsr.l #5,%d5
	add.l #128,%d5
	move.l (%a2,%d5.l*4),%d6
	moveq #31,%d5
	and.l %d1,%d5
	btst %d5,%d6
	jeq .L1423
	addq.l #1,pmo+52
	move.l (%a3),pmo+108
.L1424:
	asr.l #8,%d0
	add.l %d3,%d0
	tst.l %d0
	jlt .L1451
	cmp.l #32767,%d0
	jgt .L1452
.L1425:
	move.w %d0,(%a5)
	jra .L1415
.L1423:
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
	jra .L1424
.L1451:
	clr.w %d0
	jra .L1425
.L1452:
	move.w #32767,%d0
	jra .L1425
.L1421:
	add.l #-48,%d4
	mvz.b %d4,%d4
	lsr.l #3,%d4
	jne .L1415
	mvz.b %d1,%d1
	move.l pmo+300,%d6
	asr.l #8,%d0
	move.l %d1,%d4
	subq.l #1,%d4
	btst %d4,%d6
	jne .L1426
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
	move.w %d5,318(%a5)
	clr.l 306(%a5)
	clr.l 310(%a5)
	clr.l 314(%a5)
.L1426:
	cmp.l #-32768,%d0
	jlt .L1453
	cmp.l #32767,%d0
	jgt .L1454
.L1427:
	lsl.l #3,%d4
	move.l %d4,%a6
	lea 104(%a6,%d3.l),%a5
	move.w %d0,(%a2,%a5.l*2)
	jra .L1415
.L1453:
	move.w #-32768,%d0
	jra .L1427
.L1454:
	move.w #32767,%d0
	jra .L1427
.L1455:
	moveq #1,%d0
	move.l %d1,%d2
	jra .L1431
.L1429:
	move.l %d2,%d1
	subq.l #1,%d1
	move.w %d1,%d3
	mulu.w #44,%d3
	tst.b (%a0,%d3.l)
	jeq .L1455
	tst.b %d0
	jeq .L1430
	move.l %d2,pmo+104
	jra .L1430
.L1437:
	btst #0,%d0
	jeq .L1433
	move.l %d1,%d3
	add.l #-536856241,%d3
	lsl.l #2,%d3
	mvz.w -26(%a1),%d0
	move.l %d3,%a3
	btst #3,3(%a3)
	jeq .L1456
	mvs.w (%a2),%d3
.L1434:
	move.l %d0,%a5
	add.l %d3,%a5
	move.l %a5,196(%a0)
	move.l %a5,%d0
	cmp.l #32767,%a5
	jle .L1435
	mvz.w #32767,%d0
.L1435:
	move.l %d0,196(%a0)
	mvs.w (%a1),%d0
	move.l %d0,248(%a0)
.L1433:
	addq.l #1,%d1
	addq.l #4,%a0
	addq.l #2,%a1
	lea (84,%a2),%a2
.L1436:
	move.l %d2,%d0
	lsr.l %d1,%d0
	jne .L1437
	tst.l %d2
	jeq .L1438
	lea pmo+9248,%a2
	clr.l %d5
	move.l #pmo+304,%d6
	lea pmo,%a6
.L1447:
	mov3q.l #1,%d1
	and.l %d2,%d1
	move.l %d1,64(%sp)
	btst #0,%d2
	jeq .L1439
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
.L1445:
	move.l %d4,%a5
	add.l #-2147423684,%a5
	lea (-32,%a1),%a3
	sub.l %a0,%a0
	move.l 48(%sp),52(%sp)
	move.l %a5,72(%sp)
.L1444:
	move.l 72(%sp),%a5
	move.l (%a5,%a0.l),%d1
	move.l 52(%sp),%a5
	addq.l #2,52(%sp)
	mvz.w %d1,%d1
	mvz.w (%a5)+,%d0
	move.l %d0,44(%sp)
	tst.l %d0
	jeq .L1440
	move.l %d1,%d0
	sub.l 68(%sp),%d0
	move.l %d0,60(%sp)
	subq.l #1,%d0
	move.l %d0,76(%sp)
	moveq #40,%d0
	cmp.l 76(%sp),%d0
	jcc .L1441
.L1440:
	move.l %d1,(%a1,%a0.l)
	move.l %d1,(%a3,%a0.l)
.L1442:
	addq.l #4,%a0
	moveq #16,%d1
	cmp.l %a0,%d1
	jne .L1444
	lea (16,%a1),%a1
	add.l #16,%d4
	addq.l #8,48(%sp)
	subq.l #1,%d7
	tst.l %d7
	jne .L1457
	move.b %d3,10064(%a6)
	btst #0,%d3
	jeq .L1446
	pea -16(%a2)
	move.l 196(%a4),-(%sp)
	jsr 1074912702
	addq.l #8,%sp
.L1446:
	btst #1,%d3
	jeq .L1439
	move.l %a2,-(%sp)
	move.l 248(%a4),-(%sp)
	jsr 1074912702
	addq.l #8,%sp
.L1439:
	lsr.l #1,%d2
	addq.l #4,%a4
	lea (64,%a2),%a2
	addq.l #1,%a6
	addq.l #2,%d5
	add.l #16,%d6
	tst.l %d2
	jne .L1447
	jra .L1438
.L1456:
	clr.l %d3
	jra .L1434
.L1457:
	move.l 64(%sp),%d7
	jra .L1445
.L1441:
	move.l 44(%sp),%d0
	swap %d0
	clr.w %d0
	or.l %d1,%d0
	move.l %d0,%a5
	moveq #8,%d0
	cmp.l 60(%sp),%d0
	jcs .L1443
	move.l %a5,(%a3,%a0.l)
	move.l %d1,(%a1,%a0.l)
	mov3q.l #1,%d0
.L1514:
	lsl.l %d7,%d0
	or.l %d0,%d3
	jra .L1442
.L1443:
	move.l %a5,(%a1,%a0.l)
	move.l %d1,(%a3,%a0.l)
	mov3q.l #4,%d0
	jra .L1514
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
	jeq .L1516
	move.w #12,%a6
	lea (44,%sp),%a2
	move.l %a2,%a0
.L1517:
	clr.l (%a0)+
	subq.l #1,%a6
	tst.l %a6
	jne .L1517
	move.l pmo+104,%d1
	clr.l %d5
	lea pmo,%a4
	lea pmo+3464,%a0
	move.l %d1,36(%sp)
.L1518:
	cmp.l 36(%sp),%d5
	jne .L1527
	move.l pmo+300,%d2
	tst.l %d2
	jeq .L1532
	lea pmo+9280,%a5
	move.l #pmo,%d3
.L1531:
	btst #0,%d2
	jeq .L1529
	move.b 10064(%a4),%d0
	move.w %d0,%ccr
	jne .L1530
	pea -16(%a5)
	move.l %d3,%a0
	move.l 196(%a0),-(%sp)
	jsr 1074912702
	addq.l #8,%sp
.L1530:
	move.b 10064(%a4),%d0
	move.w %d0,%ccr
	jpl .L1529
	move.l %a5,-(%sp)
	move.l %d3,%a1
	move.l 248(%a1),-(%sp)
	jsr 1074912702
	addq.l #8,%sp
.L1529:
	lsr.l #1,%d2
	addq.l #1,%a4
	addq.l #4,%d3
	lea (64,%a5),%a5
	tst.l %d2
	jne .L1531
.L1532:
	move.l %a6,%d0
	add.l #36,%d0
	move.l (%a2)+,(%a3,%d0.l*4)
	addq.l #1,%a6
	moveq #12,%d0
	cmp.l %a6,%d0
	jne .L1532
	mov3q.l #1,pmo+140
.L1533:
	move.l 40(%sp),-(%sp)
	jsr pmo_time
	addq.l #4,%sp
	move.l pmo+116,%d0
	cmp.l pmo+36.l,%d0
	jls .L1535
	move.l %d0,pmo+36
.L1535:
	movem.l (%sp),#31804
	add.l %d0,pmo+40
	addq.l #1,pmo+44
	lea (92,%sp),%sp
	rts
.L1527:
	move.b (%a0),%d1
	jeq .L1519
	mvz.b 1(%a0),%d0
	moveq #41,%d2
	cmp.l %d0,%d2
	jcs .L1520
	moveq #8,%d3
	cmp.l %d0,%d3
	jcc .L1519
	move.l 40(%a0),%d0
	move.l %d0,%d1
	add.l %d1,%d1
	move.l 28(%a0),%d3
	move.l %d1,%a5
	add.l #-2147420300,%a5
	mvz.w (%a5),%d2
	tst.l %d3
	jeq .L1523
	tst.l -2147418904
	jeq .L1522
	move.l %d0,%d1
	lsr.l #5,%d1
	add.l #128,%d1
	move.l (%a3,%d1.l*4),%d4
	moveq #31,%d1
	and.l %d0,%d1
	btst %d1,%d4
	jeq .L1522
	lea fp,%a1
	addq.l #1,pmo+52
	move.l (%a1),pmo+108
.L1523:
	move.l 4(%a0),%d0
	asr.l #8,%d0
	add.l %d2,%d0
	tst.l %d0
	jlt .L1536
	cmp.l #32767,%d0
	jgt .L1537
.L1524:
	move.w %d0,(%a5)
.L1519:
	addq.l #1,%d5
	lea (44,%a0),%a0
	jra .L1518
.L1522:
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
	jra .L1523
.L1536:
	clr.w %d0
	jra .L1524
.L1537:
	move.w #32767,%d0
	jra .L1524
.L1520:
	moveq #56,%d2
	cmp.l %d0,%d2
	jne .L1519
	move.l 4(%a0),%d0
	asr.l #8,%d0
	cmp.l #32767,%d0
	jle .L1525
	mvz.w #32767,%d0
.L1525:
	mvz.b %d1,%d1
	move.l 16(%a0),%d2
	subq.l #1,%d1
	and.l #8323072,%d2
	cmp.l #-32768,%d0
	jge .L1526
	mvs.w #-32768,%d0
.L1526:
	mvz.w %d0,%d0
	moveq #24,%d3
	or.l %d0,%d2
	mvs.w 28(%a0),%d0
	lsl.l %d3,%d0
	or.l %d0,%d2
	move.l %d2,44(%sp,%d1.l*4)
	jra .L1519
.L1516:
	tst.l pmo+140
	jeq .L1533
.L1534:
	move.l %d0,%d1
	add.l #36,%d1
	clr.l (%a3,%d1.l*4)
	moveq #12,%d1
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1534
	clr.l pmo+140
	jra .L1533
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
	jcs .L1568
	add.l #36,%d1
	lea pmo,%a0
	move.l (%a0,%d1.l*4),%a0
	tst.l %a0
	jeq .L1568
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
	jge .L1570
	moveq #127,%d0
.L1568:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L1570:
	tst.l %d0
	jgt .L1568
	mov3q.l #1,%d0
	jra .L1568
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
.L1576:
	mov3q.l #1,%d0
	cmp.l fp+20.l,%d0
	jeq .L1576
.L1577:
	mov3q.l #2,%d1
	cmp.l fp+20.l,%d1
	jeq .L1578
	move.l 1100667228,%d0
	cmp.l #cu_text,%d0
	jeq .L1579
	cmp.l 1100664624.l,%d0
	jne .L1579
	move.l #cu_text,%d2
	move.l %d2,1100667228
.L1579:
	move.l #1075731444,%d3
	cmp.l sv+88.l,%d3
	jeq .L1580
	move.l #1093765506,%a1
	moveq #11,%d4
	mvz.b (%a1),%d0
	cmp.l %d0,%d4
	jcs .L1580
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
.L1580:
	tst.b cu.l
	jne .L1581
	move.l #1128813124,%d6
	cmp.l 1073849308.l,%d6
	jne .L1581
	moveq #1,%d7
	pea 52.w
	move.b %d7,cu
	jsr cu_src_setup
	addq.l #4,%sp
	lea cu_steps,%a0
	move.l %a0,1073849316
	lea cu_setup,%a1
	move.l %a1,1073849312
.L1581:
	move.l rx,%d3
	move.l #-66650100,%a3
	addq.l #1,st+8
	move.l (%a3),st+300
	tst.l st
	jeq .L1582
	addq.l #1,ram_checks
	tst.l ram_test
	jeq .L1583
	move.l ram_test,%d0
	subq.l #1,%d0
	move.l %d0,ram_test
	tst.l %d0
	jne .L1583
	tst.l ram_test_at
	jeq .L1583
	moveq #1,%d0
	swap %d0
	move.l ram_test_at,%a0
	eor.l %d0,(%a0)
.L1583:
	mov3q.l #1,%d2
	and.l ram_ok,%d2
	tst.l %d2
	jeq .L1881
#APP
| 2802 "rui.c" 1
	move.l #RAM_RUI_FRAME_SIZE,%d0
| 0 "" 2
#NO_APP
	move.l %d0,-(%sp)
	pea RAM_RUI_FRAME
	jsr ram_broken
	addq.l #8,%sp
	tst.l %d0
	sne %d2
	move.l %d0,%d4
	mvs.b %d2,%d2
	neg.l %d2
.L1584:
	lea ram_ok,%a0
	btst #1,3(%a0)
	jne .L1585
.L2177:
	move.l %d4,%a3
	jra .L1586
.L1578:
	pea 10000.w
	jsr 1074367512
	addq.l #4,%sp
	jra .L1577
.L1881:
	clr.l %d4
	jra .L1584
.L1585:
#APP
| 2803 "rui.c" 1
	move.l #RAM_RUI_NAMES_SIZE,%d0
| 0 "" 2
#NO_APP
	move.l %d0,-(%sp)
	pea RAM_RUI_NAMES
	jsr ram_broken
	addq.l #8,%sp
	move.l %d0,%a3
	tst.l %d0
	jeq .L2177
	mov3q.l #2,%d0
	or.l %d0,%d2
	tst.l %d4
	jne .L2177
.L1586:
	lea ram_ok,%a0
	btst #2,3(%a0)
	jeq .L1588
#APP
| 2804 "rui.c" 1
	move.l #RAM_RUI_PMO_SIZE,%d0
| 0 "" 2
#NO_APP
	move.l %d0,-(%sp)
	pea RAM_RUI_PMO
	jsr ram_broken
	addq.l #8,%sp
	tst.l %d0
	jeq .L1588
	mov3q.l #4,%d1
	or.l %d1,%d2
	tst.l %a3
	jeq .L1882
.L1589:
	move.l %d2,%d0
	not.l %d0
	and.l %d0,ram_ok
	move.l ram_bad,%d0
	tst.l %d0
	jne .L1591
	move.l %a3,ram_bad_at
	move.l (%a3),ram_bad_word
.L1591:
	or.l %d2,%d0
	move.l st+8,%a0
	mov3q.l #1,ram_rep_owed
	lea (100,%a0),%a0
	move.l %a0,ram_show_until
	move.l %d0,ram_bad
	btst #0,%d2
	jeq .L1592
	tst.l st+4
	jeq .L1593
	mov3q.l #4,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	addq.l #8,%sp
.L1593:
	mov3q.l #7,-(%sp)
	move.l %a2,-(%sp)
	jsr splash_end
	addq.l #8,%sp
.L1592:
	moveq #1,%d0
	move.b %d0,32(%a2)
	jra .L1590
.L1588:
	tst.l %d2
	jne .L1589
.L1590:
	tst.l dg
	jeq .L1594
	mvz.w #128,%d0
	move.l dg+4,%a0
.L1598:
	move.l %a0,%d1
	eor.l #-1059131379,%d1
	move.l (%a0),%d2
	cmp.l %d2,%d1
	jeq .L1595
	move.l dg+12,%a1
	tst.l %a1
	jne .L1596
	move.l %a0,dg+16
	move.l %d2,dg+20
.L1596:
	addq.l #1,%a1
	move.l %a1,dg+12
	move.l %d1,(%a0)
.L1595:
	addq.l #4,%a0
	cmp.l #1203634176,%a0
	jeq .L1883
	cmp.l #1207894016,%a0
	jne .L1597
	addq.l #1,dg+8
	move.l #1203011584,%a0
.L1597:
	subq.l #1,%d0
	tst.l %d0
	jne .L1598
	mvz.w #128,%d1
	move.l %a0,dg+4
	add.l %d1,dg+24
.L1594:
	mov3q.l #1,%d2
	cmp.l 1094562388.l,%d2
	jne .L1599
	tst.l st+968
	jeq .L1599
	tst.l ram_rep_owed
	jeq .L1600
	move.w #21761,%d5
	clr.b %d6
	lea ram_bad+3,%a0
	move.b (%a0),-133(%fp)
	move.l ram_bad_at,-(%sp)
	lea (-140,%fp),%a3
	move.l #-260222380,%d4
	pea 8(%a3)
	lea put35,%a4
	move.l ram_bad_word,%d2
	move.w %d5,-136(%fp)
	move.l %d4,-140(%fp)
	move.b %d6,-134(%fp)
	jsr (%a4)
	move.l %d2,-(%sp)
	move.l %d0,-(%sp)
	jsr (%a4)
	move.l %d0,%a0
	move.b #-9,(%a0)+
	sub.l %a3,%a0
	move.l %a0,-(%sp)
	move.l %a3,-(%sp)
	jsr send
	lea (24,%sp),%sp
	tst.l %d0
	jeq .L1599
	clr.l ram_rep_owed
	addq.l #1,ram_rep_sent
.L1599:
	tst.l ram_bad
	jeq .L1601
	move.l ram_show_until,%a1
	cmp.l st+8.l,%a1
	jne .L1601
	moveq #1,%d0
	move.b %d0,32(%a2)
.L1601:
	tst.l st
	jne .L1602
.L1582:
#APP
| 2772 "rui.c" 1
	.if RAM_RUI_FRAME_SIZE < 12560
.error "registry ddr claim rui_frame is too small"
.endif
.if RAM_RUI_NAMES_SIZE < 3984
.error "registry ddr claim rui_names is too small"
.endif
.if RAM_RUI_PMO_SIZE < 10094
.error "registry ddr claim rui_pmo is too small"
.endif
.if P_DDRDIAG
.ifdef RAM_IN_AREA
.error "ddrdiag=1 needs this OS's DDR claims (registry [[ddr]])"
.endif
.endif

| 0 "" 2
#NO_APP
	move.l ram_step,%d0
	tst.l %d0
	jne .L1603
#APP
| 2781 "rui.c" 1
	move.l #RAM_RUI_FRAME_SIZE,%d1
| 0 "" 2
#NO_APP
	lsr.l #2,%d1
	lea RAM_RUI_FRAME,%a1
	move.l %a1,%a0
.L1604:
	cmp.l %d1,%d0
	jne .L1605
#APP
| 2782 "rui.c" 1
	move.l #RAM_RUI_FRAME_SIZE,%d0
| 0 "" 2
#NO_APP
.L2178:
	move.l %d0,-(%sp)
	move.l %a1,-(%sp)
	jsr ram_seal
	addq.l #8,%sp
	addq.l #1,ram_step
.L1616:
	tst.l st
	jne .L1615
.L1749:
	mvz.b cu+9,%d2
	tst.l %d2
	jeq .L1778
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
	jeq .L1779
	move.l st+8,%d0
	mov3q.l #4,%d3
	sub.l cu+16,%d0
	cmp.l %d0,%d3
	jcc .L1778
.L1783:
	clr.b %d4
	move.b %d4,cu+9
.L1778:
	tst.l st
	jeq .L1784
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L1785
	tst.l st+968
	jeq .L1785
	move.l dp,%d0
	move.b 1093765506,%d2
	tst.l %d0
	jeq .L1786
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
	jeq .L1788
	clr.l dp
.L1786:
	tst.b k44+20.l
	jeq .L1789
	move.l k44+20,%d0
	and.l #16776960,%d0
	tst.l %d0
	jne .L1789
	tst.l st+4
	jeq .L1790
	tst.l st+1058
	jne .L1789
.L1790:
	move.l st+8,%d0
	sub.l k44,%d0
	lsr.l #3,%d0
	jeq .L1789
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	or.l ov_list,%d0
	jne .L1789
	tst.l st+4
	sne %d0
	move.w #257,%d7
	neg.l %d0
	move.b %d0,k44+26
	move.w %d7,k44+22
.L1789:
	move.b k44+23,%d0
	jeq .L1791
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
	jeq .L1788
	mvz.b k44+23,%d0
	tst.b k44+26.l
	jeq .L1794
	mov3q.l #1,%d4
	cmp.l %d0,%d4
	jne .L1795
	addq.l #1,k44+28
.L1796:
	clr.b %d0
	move.b %d0,k44+23
.L1791:
	mvz.b %d2,%d1
	moveq #11,%d3
	cmp.l %d1,%d3
	jcs .L1788
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
	jeq .L1799
	clr.b %d4
	move.l %d0,dp+8
	move.b %d4,dp+22
.L1800:
	moveq #52,%d6
	cmp.l %d5,%d6
	jcs .L1892
	move.b %d3,%d0
	move.l #1075572644,%a0
	ext.w %d0
	mvz.w %d0,%d0
	lsl.l #3,%d0
	move.l (%a0,%d0.l),%a0
.L1802:
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
	jeq .L1893
	move.l %a0,%d0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	sls %d0
	mvs.b %d0,%d0
	neg.l %d0
.L1803:
	clr.l %d1
	lea (-140,%fp),%a1
.L1805:
	tst.l %d0
	jeq .L2184
	move.b (%a0,%d1.l),%d6
	move.l %d6,%d7
	subq.l #1,%d7
	mvz.b %d7,%d4
	moveq #125,%d7
	cmp.l %d4,%d7
	jcs .L1895
.L1804:
	move.b %d6,9(%a1,%d1.l)
	addq.l #1,%d1
	moveq #12,%d4
	cmp.l %d1,%d4
	jne .L1805
	moveq #-9,%d6
	pea 22.w
	move.l %a1,-(%sp)
	move.b %d6,-119(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1788
	move.w #257,%d7
	move.b %d2,dp+20
	move.b %d3,dp+21
	addq.l #1,dp+12
	move.w %d7,dp+22
	jra .L1801
.L1882:
	move.l %d0,%a3
	jra .L1589
.L1883:
	move.l #1204027392,%a0
	jra .L1597
.L1600:
	tst.l dg
	jeq .L1599
	move.l st+8,%d0
	sub.l dg+32,%d0
	cmp.l #199,%d0
	jle .L1599
	move.w #21761,%a3
	moveq #1,%d0
	move.l dg+8,-(%sp)
	move.l #-260222380,%a1
	lea (-140,%fp),%a4
	pea 7(%a4)
	move.l %a1,-140(%fp)
	move.l dg+20,%d2
	move.l dg+16,%d4
	move.w %a3,-136(%fp)
	move.b %d0,-134(%fp)
	lea put35,%a3
	move.l dg+12,%d5
	jsr (%a3)
	move.l %d5,-(%sp)
	move.l %d0,-(%sp)
	jsr (%a3)
	move.l %d4,-(%sp)
	move.l %d0,-(%sp)
	jsr (%a3)
	move.l %d2,-(%sp)
	move.l %d0,-(%sp)
	jsr (%a3)
	lea (32,%sp),%sp
	lea ram_bad+3,%a1
	move.l %d0,%a0
	addq.l #3,%a0
	move.l ram_ok,%d0
	move.b %d0,-3(%a0)
	moveq #-9,%d0
	move.b (%a1),-2(%a0)
	move.b %d0,-1(%a0)
	sub.l %a4,%a0
	move.l %a0,-(%sp)
	move.l %a4,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1599
	lea st+8,%a0
	move.l (%a0),dg+32
	addq.l #1,dg+36
	jra .L1599
.L1605:
	clr.l (%a0)+
	addq.l #1,%d0
	jra .L1604
.L1603:
	subq.l #1,%d0
	tst.l %d0
	jne .L1607
#APP
| 2784 "rui.c" 1
	move.l #RAM_RUI_NAMES_SIZE,%d0
| 0 "" 2
#NO_APP
	lsr.l #2,%d0
	lea RAM_RUI_NAMES,%a1
	clr.l %d1
	move.l %a1,%a0
.L1608:
	cmp.l %d0,%d1
	jne .L1609
#APP
| 2785 "rui.c" 1
	move.l #RAM_RUI_NAMES_SIZE,%d0
| 0 "" 2
#NO_APP
	jra .L2178
.L1609:
	clr.l (%a0)+
	addq.l #1,%d1
	jra .L1608
.L1607:
#APP
| 2787 "rui.c" 1
	move.l #RAM_RUI_PMO_SIZE,%d0
| 0 "" 2
#NO_APP
	lsr.l #2,%d0
	lea RAM_RUI_PMO,%a1
	clr.l %d1
	move.l %a1,%a0
.L1610:
	cmp.l %d0,%d1
	jne .L1611
#APP
| 2788 "rui.c" 1
	move.l #RAM_RUI_PMO_SIZE,%d0
| 0 "" 2
#NO_APP
	move.l %d0,-(%sp)
	move.l %a1,-(%sp)
	jsr ram_seal
	addq.l #1,ram_init_n
	addq.l #8,%sp
#APP
| 2790 "rui.c" 1
	move.l #P_DDRDIAG,%d0
| 0 "" 2
#NO_APP
	tst.l %d0
	jeq .L1612
	move.l #1203011584,%d0
	move.l -66650100,%a0
.L1613:
	move.l %d0,%d1
	move.l #-1059131379,%d2
	eor.l %d1,%d2
	move.l %d1,%a1
	addq.l #4,%d0
	move.l %d2,(%a1)
	cmp.l #1203634176,%d0
	jne .L1613
	move.l #1204027392,%d0
.L1614:
	move.l %d0,%d1
	move.l #-1059131379,%d2
	move.l %d1,%a1
	addq.l #4,%d0
	eor.l %d1,%d2
	move.l %d2,(%a1)
	cmp.l #1207894016,%d0
	jne .L1614
	move.l -66650100,%d0
	move.l #1203011584,%d1
	sub.l %a0,%d0
	move.l %d0,dg+28
	move.l %d1,dg+4
	mov3q.l #1,dg
.L1612:
	mov3q.l #7,ram_ok
	move.l #rui_sysex,%d2
	move.l %d2,1075551840
	move.l #1381321040,%d4
	move.l %d4,1075551836
	mov3q.l #1,st
	move.l %d3,st+16
.L1615:
	lea ram_ok,%a0
	btst #1,3(%a0)
	jeq .L1749
	move.l #ux,%d5
.L1750:
	tst.l ux+3944
	jne .L1753
.L1754:
	move.l ux+3880,%d1
	cmp.l ux+3884.l,%d1
	jeq .L1749
	mov3q.l #7,%d2
	cmp.l ux+3944.l,%d2
	jcs .L1749
	mov3q.l #7,%d0
	and.l ux+3884,%d0
	lsl.l #2,%d0
	move.l %d0,%a2
	add.l #ux+3888,%a2
	move.b 1(%a2),%d6
	move.b (%a2),%d7
	mvz.b %d6,%d0
	mvz.b %d7,%d3
	move.l %d0,%a1
	moveq #127,%d0
	and.l -2147457096,%d0
	move.l %a1,%d4
	add.l #9,%d4
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l #1092966773,%a0
	move.w %d3,%d0
	mulu.w #152,%d0
	move.b (%a0,%d0.l),%d0
	mvz.b %d0,%d1
	move.w %d0,%a3
	move.l %d1,-(%sp)
	move.l %d4,-(%sp)
	move.l %a1,-188(%fp)
	move.l %d1,%a5
	jsr 1073770536
	addq.l #8,%sp
	move.l ux+3884,%a0
	move.l -188(%fp),%a1
	move.l %d0,%a4
	tst.l %d0
	jle .L1890
	mvz.b 2(%a2),%d2
	mvz.b 3(%a2),%d0
	lsl.l #8,%d2
	add.l %d0,%d0
	or.l %d0,%d2
	mov3q.l #7,%d0
	cmp.l %a1,%d0
	jlt .L1756
	move.l %a3,%d0
	add.l #-46,%d0
	mvz.b %d0,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jcc .L1757
	moveq #52,%d0
	cmp.l %a5,%d0
	jne .L1758
.L1757:
	cmp.l 1075595760.l,%a5
	jne .L1759
.L1758:
	tst.l %a1
	jne .L1761
.L1762:
	move.l %a0,%d1
	mov3q.l #7,%d0
	and.l %d0,%d1
	move.l %d5,%a0
	add.l %d1,%a0
	move.b 3952(%a0),%d0
	btst #0,%d0
	jeq .L1761
	move.l ls+60,%d0
	or.l ls+64,%d0
	jeq .L1761
	cmp.l ls+68.l,%d3
	jne .L1761
	move.l st+8,%d0
	moveq #20,%d1
	sub.l ls+72,%d0
	cmp.l %d0,%d1
	jcs .L1761
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
	jeq .L1761
	move.l (%a5),%a0
	move.l %a5,-(%sp)
	move.l 40(%a0),%a0
	jsr (%a0)
	addq.l #4,%sp
	move.l 32(%a5),%d0
	tst.l %d0
	jeq .L1763
	move.l %d0,%a0
	add.l #4753,%d0
	move.l %d0,-180(%fp)
	move.w %a3,%d0
	addq.l #1,%a0
	sub.l %a4,%a4
	sub.l %a1,%a1
	mvz.b %d0,%d0
	move.l %d0,%a3
.L1768:
	mvz.b -1(%a0),%d1
	cmp.l #255,%d1
	jeq .L1765
	mvz.b (%a0),%d0
	cmp.l #255,%d0
	jeq .L1765
	addq.l #1,%a1
.L1765:
	cmp.l %d1,%a3
	jne .L1767
	mvz.b (%a0),%d1
	move.l %a4,%d0
	cmp.l %d1,%d3
	seq %d1
	mvs.b %d1,%d1
	neg.l %d1
	or.l %d1,%d0
	move.l %d0,%a4
.L1767:
	lea (66,%a0),%a0
	cmp.l -180(%fp),%a0
	jne .L1768
	tst.l %a4
	jne .L1763
	moveq #69,%d1
	cmp.l %a1,%d1
	jlt .L1769
.L1763:
	move.l %a2,-(%sp)
	moveq #64,%d3
	jsr 1074529464
	addq.l #4,%sp
	move.l %d0,%a3
	cmp.l %d0,%d3
	jge .L1770
	move.w #64,%a3
.L1770:
	clr.l %d3
.L1771:
	cmp.l %a3,%d3
	jlt .L1775
	moveq #4,%d0
	clr.l ls+64
	clr.l ls+60
	addq.l #1,ux+3960
.L1776:
	move.l ux+3944,%a0
	lea (%a0,%a0.l*2),%a1
	addq.l #1,%a0
	move.l %a0,ux+3944
	addq.l #1,ux+3884
	add.l %d5,%a1
	move.b %d7,3920(%a1)
	move.b %d6,3921(%a1)
	move.b %d0,3922(%a1)
	jra .L1754
.L1611:
	clr.l (%a0)+
	addq.l #1,%d1
	jra .L1610
.L1602:
	tst.b host_close.l
	jeq .L1617
	clr.b %d5
	lea commits,%a0
	move.b %d5,host_close
	move.b %d5,host_open
	move.l (%a0),sv+12
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	addq.l #8,%sp
.L1617:
	tst.b host_open.l
	jeq .L1618
	clr.b %d0
	clr.l -(%sp)
	mov3q.l #1,-(%sp)
	move.l %a2,-(%sp)
	move.b %d0,host_open
	jsr enter
	lea (12,%sp),%sp
.L1618:
	move.l st+956,%d0
	mov3q.l #1,%d1
	cmp.l 1094562388.l,%d1
	jne .L1619
	cmp.l #65534,%d0
	jhi .L1620
	tst.l %d0
	jne .L1621
	moveq #50,%d2
	cmp.l st+8.l,%d2
	jcc .L1622
.L1621:
	addq.l #1,%d0
	move.l %d0,st+956
	moveq #10,%d4
	cmp.l %d0,%d4
	jne .L1620
.L1623:
	moveq #1,%d6
	move.w #4095,%d7
	move.l %d3,st+964
	mov3q.l #1,st+960
	move.b %d6,st+992
	move.b %d6,mr+13
	move.b %d6,mr+19
	move.w %d7,ar+60
	jsr sq_forget
	lea commits,%a0
	move.l (%a0),pm+28
.L1624:
	tst.b st+992.l
	jne .L1628
.L1629:
	tst.l splash_req
	jeq .L1631
	move.l splash_req,%d0
	clr.l splash_req
	tst.l st+4
	jne .L1632
	moveq #127,%d1
	and.l %d1,%d0
	tst.l %d0
	jeq .L1633
	tst.l commits
	jne .L1634
.L1632:
	addq.l #1,st+984
.L1631:
	tst.l st+4
	jeq .L1636
	cmp.l st+16.l,%d3
	jeq .L1637
	clr.l st+12
.L1638:
	move.l %d3,st+16
	clr.b %d0
	move.l st+8,%a1
	lea st+408,%a0
	clr.l -184(%fp)
.L1644:
	move.l (%a0)+,%d1
	tst.l %d1
	jeq .L1642
	move.l %a1,%d2
	sub.l %d1,%d2
	jmi .L1642
	moveq #1,%d0
	clr.l -4(%a0)
.L1642:
	addq.l #1,-184(%fp)
	moveq #16,%d5
	cmp.l -184(%fp),%d5
	jne .L1644
	tst.b %d0
	jeq .L1645
	mov3q.l #1,st+344
.L1645:
	move.l %d3,-(%sp)
	move.l %a2,-(%sp)
	jsr sv_tick
	addq.l #8,%sp
	tst.b ls.l
	jeq .L1646
	tst.b sv.l
	jeq .L1647
	tst.b sv+8.l
	jeq .L1647
	move.l sv,%d0
	move.l ls,%d6
	eor.l %d6,%d0
	and.l #16776960,%d0
	or.l st+4,%d0
	jeq .L1646
.L1647:
	mov3q.l #5,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1646:
	move.l ls_in_gen,%d7
	cmp.l ls+48.l,%d7
	jeq .L1648
	move.l ls_in_v,%d0
	lea ls_in_gen,%a1
	move.l ls+36,%a0
	move.l (%a1),ls+48
	tst.b ls.l
	jeq .L1648
	move.l %d0,%d1
	lsr.l #8,%d1
	mvz.b ls+1,%d2
	cmp.l %d1,%d2
	jne .L1648
	mov3q.l #1,%d1
	and.l %d1,%d0
	tst.l %a0
	jeq .L1649
	tst.l %d0
	jne .L1649
	clr.l st+124
.L1649:
	move.l %d0,ls+36
	mov3q.l #1,ls+40
.L1648:
	tst.l ls+36
	jeq .L1650
	tst.l ls+40
	jne .L1650
	move.l st+8,%d0
	moveq #20,%d2
	sub.l ls+44,%d0
	cmp.l %d0,%d2
	jcc .L1650
	clr.l ls+36
	addq.l #1,ls+56
	clr.l st+124
.L1650:
	move.l u46+8,%d0
	tst.l %d0
	jeq .L1651
	tst.b ls.l
	jne .L1652
	tst.l st+4
	jne .L1652
	move.l st+8,%d1
	moveq #20,%d3
	sub.l %d0,%d1
	cmp.l %d1,%d3
	jcs .L1652
	move.l #1093765506,%a1
	moveq #11,%d4
	mvz.b (%a1),%d0
	cmp.l %d0,%d4
	jcs .L1652
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
	jeq .L1653
.L1652:
	clr.l u46+8
.L1651:
	move.l pm,%d2
	tst.l %d2
	jeq .L1654
	clr.l pm
	add.l #31,%d2
	tst.b ls.l
	jeq .L1655
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L1655:
	clr.l st+1038
	tst.l st+4
	jeq .L1656
	moveq #1,%d7
	mvz.w #256,%d6
	moveq #1,%d0
	move.b %d2,st+993
	addq.l #1,pm+16
	move.l %d6,st+296
	move.b %d7,st+161
	move.w %d0,st+162
.L1657:
	tst.l st+1058
	jne .L1659
	tst.l sv+96
	jne .L1660
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jeq .L1658
	lea st+8,%a0
	mov3q.l #1,st+1058
	mov3q.l #1,st+1062
	move.l (%a0),st+1066
	addq.l #1,st+1070
	addq.l #1,st+1090
.L1659:
	tst.l st+4
	jne .L1661
	clr.l st+1058
.L1662:
	tst.l st+972
	jne .L1666
	tst.b sv+8.l
	jne .L1666
.L1667:
	move.l st+1082,%d0
	tst.l %d0
	jeq .L1669
	sub.l st+8,%d0
	tst.l %d0
	jgt .L1670
	clr.l st+1082
.L1670:
	moveq #1,%d4
	move.b %d4,32(%a2)
.L1669:
	jsr sq_tick
	move.l st+4,%d0
	move.l led_gen,%d1
	or.l sq+408,%d0
	jeq .L1671
	tst.l sq+468
	jne .L1672
	lea led_gen,%a0
	move.l (%a0),st+1002
	lea pg_gen,%a1
	move.l #2139062143,%a2
	clr.l st+1006
	mov3q.l #1,sq+476
	move.l (%a1),sq+472
	move.l %a2,sq+480
.L1672:
	mov3q.l #1,sq+468
	cmp.l st+1002.l,%d1
	jeq .L1674
	btst #0,%d1
	jne .L1674
	move.b led_req_mode,%d2
	clr.l %d0
	lea led_req,%a0
.L1675:
	lea (%a0,%d0.l),%a1
	moveq #16,%d3
	lea (-140,%fp),%a3
	move.b (%a1),(%a3,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d3
	jne .L1675
	cmp.l led_gen.l,%d1
	jne .L1674
	mvz.b %d2,%d2
	move.l %d1,st+1002
	clr.l %d0
	lea st+1022,%a0
	move.l %d2,st+1006
.L1677:
	lea (-140,%fp),%a1
	moveq #16,%d1
	lea (%a1,%d0.l),%a2
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1677
	moveq #1,%d2
	move.b %d2,led_owed
.L1674:
	mov3q.l #1,%d3
	cmp.l st+1006.l,%d3
	jne .L1673
	clr.l led_again
	tst.b ov_on.l
	jeq .L1682
	tst.b led_owed.l
	jeq .L1680
.L1682:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jeq .L2181
	clr.l %d0
	lea st+1022,%a2
	lea ov_col,%a0
.L1683:
	lea (%a2,%d0.l),%a1
	moveq #16,%d1
	move.b (%a1),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1683
	moveq #1,%d2
	move.l %fp,%d3
	add.l #-140,%d3
	lea led_send4,%a3
	move.b %d2,ov_on
	clr.l %d2
.L1684:
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
	jne .L1684
	clr.b %d5
	move.l #1100088672,-(%sp)
	jsr 1073746414
	addq.l #1,st+1010
	move.b %d5,led_owed
	jra .L2182
.L1622:
	move.l st+4,%d0
	tst.l %d0
	jeq .L1620
	moveq #10,%d5
	move.l %d5,st+956
	jra .L1623
.L1620:
	move.l st+960,%d2
	move.l %d2,%d1
	subq.l #1,%d1
	lsr.l #1,%d1
	jne .L1624
	moveq #20,%d1
	moveq #20,%d5
	muls.l %d2,%d1
	cmp.l %d1,%d5
	seq %d1
	neg.l %d1
	tst.b %d1
	jeq .L1625
	moveq #30,%d1
.L1626:
	cmp.l %d1,%d0
	jne .L1624
	cmp.l st+964.l,%d3
	jne .L1627
	moveq #1,%d6
	move.w #4095,%d7
	addq.l #1,%d2
	move.l %d2,st+960
	move.b %d6,st+992
	move.b %d6,mr+13
	move.b %d6,mr+19
	move.w %d7,ar+60
.L1628:
	tst.b sv.l
	jeq .L1629
	moveq #1,%d0
	move.w #257,%a1
	lea sv+1,%a0
	move.b (%a0),sv+5
	move.b %d0,sv+4
	move.w %a1,sv+6
	jra .L1629
.L1625:
	moveq #50,%d1
	jra .L1626
.L1627:
	mov3q.l #3,st+960
	jra .L1624
.L1619:
	tst.l %d0
	jeq .L1630
	lea ram_ok,%a3
	btst #2,3(%a3)
	jeq .L1630
	addq.l #1,pmo+72
.L1630:
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
	jeq .L1629
	jsr sq_forget
	jra .L1629
.L1633:
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr splash_end
	addq.l #8,%sp
	jra .L1631
.L1634:
	tst.l st+972
	jne .L1635
	mov3q.l #1,st+972
	addq.l #1,st+980
	mov3q.l #-1,st+20
	clr.l st+12
	mov3q.l #1,st+344
.L1635:
	move.l %d0,st+976
.L1636:
	tst.l st+972
	jeq .L1638
	cmp.l st+16.l,%d3
	jeq .L1639
	clr.l st+12
.L1640:
	move.l st+976,%d0
	subq.l #1,%d0
	move.l %d0,st+976
	tst.l %d0
	jne .L1638
	mov3q.l #1,-(%sp)
	jra .L2180
.L1637:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d2
	cmp.l %d0,%d2
	jcc .L1638
	mov3q.l #2,-(%sp)
	move.l %a2,-(%sp)
	jsr leave
	clr.l mask_set
.L2179:
	addq.l #8,%sp
	jra .L1638
.L1639:
	move.l st+12,%d0
	addq.l #1,%d0
	move.l %d0,st+12
	moveq #19,%d4
	cmp.l %d0,%d4
	jcc .L1640
	mov3q.l #3,-(%sp)
.L2180:
	move.l %a2,-(%sp)
	jsr splash_end
	jra .L2179
.L1653:
	tst.b sv.l
	jeq .L1651
	tst.b sv+8.l
	jeq .L1651
	mvz.b sv+1,%d2
	mvz.b (%a1),%d1
	cmp.l %d2,%d1
	jne .L1651
	mvz.b sv+2,%d1
	cmp.l %d0,%d1
	jne .L1651
	clr.l -(%sp)
	clr.l -(%sp)
	jsr ls_enc
	addq.l #8,%sp
	tst.l %d0
	jeq .L1651
	clr.l u46+8
	addq.l #1,u46+28
	jra .L1651
.L1656:
	mvz.b %d2,%d2
	move.l %d2,-(%sp)
	clr.l -(%sp)
	move.l %a2,-(%sp)
	jsr enter
	lea (12,%sp),%sp
	addq.l #1,pm+12
.L1654:
	tst.l st+4
	jne .L1657
.L1658:
	tst.l st+1058
	jne .L1659
.L1660:
	tst.l st+4
	jeq .L1662
.L1666:
	tst.l st+1058
	jne .L1667
	move.l commits,%d2
	cmp.l st+20.l,%d2
	jne .L1668
	tst.l st+344
	jeq .L1667
.L1668:
	moveq #1,%d3
	move.b %d3,32(%a2)
	jra .L1667
.L1661:
	move.l sv+88,%d0
	cmp.l #1075650164,%d0
	jeq .L1663
	move.l %d0,-(%sp)
	jsr overlay
	addq.l #4,%sp
	tst.l %d0
	jeq .L1664
.L1663:
	mov3q.l #1,st+1062
	jra .L1660
.L1664:
	tst.l st+1062
	jne .L1665
	move.l st+8,%d0
	moveq #20,%d1
	sub.l st+1066,%d0
	cmp.l %d0,%d1
	jcc .L1660
.L1665:
	clr.l st+1058
	mov3q.l #-1,st+20
	mov3q.l #1,st+344
	jra .L1660
.L1671:
	clr.l sq+468
	clr.l st+1006
.L1673:
	clr.b %d4
	move.b %d4,led_owed
	jsr led_restore
	move.l led_again,%d0
	tst.l %d0
	jeq .L1680
	tst.b ov_on.l
	jne .L1680
	move.l st+8,%d1
	sub.l %d0,%d1
	jmi .L1680
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1681
.L2181:
	addq.l #1,st+1018
.L1680:
	move.l sq+468,%d2
	move.l pg_gen,%d0
	mvz.b ovp_on,%d3
	tst.l %d2
	jeq .L1685
	cmp.l sq+472.l,%d0
	jeq .L1686
	btst #0,%d0
	jne .L1686
	move.b pg_req,%d5
	move.b pg_req+1,%d4
	move.b pg_req+2,%d2
	move.b pg_req+3,%d1
	cmp.l pg_gen.l,%d0
	jne .L1686
	move.b %d5,sq+480
	move.b %d4,sq+481
	move.b %d2,sq+482
	move.b %d1,sq+483
	move.l %d0,sq+472
	mov3q.l #1,sq+476
.L1686:
	clr.l %d2
	clr.l %d0
	lea sq+480,%a0
.L1688:
	mvz.b (%a0,%d0.l),%d4
	moveq #111,%d6
	cmp.l %d4,%d6
	jcs .L1687
	mov3q.l #1,%d4
	lsl.l %d0,%d4
	or.l %d4,%d2
.L1687:
	addq.l #1,%d0
	mov3q.l #4,%d7
	cmp.l %d0,%d7
	jne .L1688
.L1685:
	cmp.l %d3,%d2
	jne .L1689
	tst.l sq+476
	jeq .L1690
.L1689:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1885
	addq.l #1,st+1018
.L1690:
	tst.l st+4
	jeq .L1886
	tst.l st+1058
	seq %d2
	mvs.b %d2,%d2
	neg.l %d2
.L1698:
	move.l st+8,%d0
	moveq #10,%d3
	divu.l %d3,%d0
	btst #0,%d0
	jeq .L1887
	clr.b %d3
.L1699:
	mvz.b k44+24,%d0
	cmp.l %d2,%d0
	jne .L1700
	tst.l %d2
	jeq .L1701
	mvz.b k44+25,%d1
	mvz.b %d3,%d0
	cmp.l %d1,%d0
	jeq .L1701
.L1700:
	move.l #1100088672,-(%sp)
	jsr 1073746332
	addq.l #4,%sp
	tst.l %d0
	jne .L1702
	addq.l #1,st+1018
.L1701:
	jsr flush
	move.b pc+79,%d2
	move.l pc_seq,%d1
	lea pc,%a2
	tst.b %d2
	jne .L1705
	btst #0,%d1
	jne .L1706
	cmp.l pc+72.l,%d1
	jeq .L1706
	clr.l %d0
	lea pc_req,%a0
	lea (-140,%fp),%a3
.L1707:
	lea (%a0,%d0.l),%a1
	mov3q.l #6,%d3
	move.b (%a1),(%a3,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d3
	jne .L1707
	cmp.l pc_seq.l,%d1
	jne .L1706
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
	jlt .L1709
	jsr 1075320104
	move.l %d0,-(%sp)
	jsr 1073963888
	addq.l #4,%sp
	tst.l %d0
	jne .L1710
.L1709:
	moveq #3,%d2
.L1711:
	move.b %d2,pc+78
	mvz.b %d2,%d2
	move.b %d3,pc+76
	add.l #42,%d2
	move.w (%a2,%d2.l*2),%d0
	addq.l #1,%d0
	move.w %d0,(%a2,%d2.l*2)
	moveq #1,%d0
	move.b %d0,pc+79
.L1705:
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
	jeq .L1706
	move.w pc+92,%d0
	clr.b %d1
	addq.l #1,%d0
	move.b %d1,pc+79
	move.w %d0,pc+92
.L1706:
	move.b st+992,%d0
	move.b st+161,%d1
	or.l %d1,%d0
	tst.b %d0
	jne .L1616
	jsr mr_tick
	tst.l %d0
	jeq .L1616
	tst.b sv+4.l
	jeq .L1726
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
	jeq .L1728
	clr.b %d0
	addq.l #1,sv+64
	move.b %d0,sv+4
.L1726:
	tst.b sv+102.l
	jeq .L1729
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
	jcc .L1730
	moveq #127,%d0
.L1730:
	move.b %d0,-159(%fp)
	clr.l %d0
	lea (-140,%fp),%a0
	lea (-172,%fp),%a1
.L1731:
	lea (%a1,%d0.l),%a2
	moveq #14,%d1
	move.b (%a2),(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l %d0,%d1
	jne .L1731
	moveq #-9,%d3
	pea 15.w
	move.l %a0,-(%sp)
	move.b %d3,-126(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1728
	clr.b %d4
	lea sv+100,%a0
	move.b (%a0),sv+101
	lea st+8,%a1
	move.l %d2,sv+104
	move.l (%a1),sv+108
	addq.l #1,sv+112
	move.b %d4,sv+102
.L1729:
	tst.b sv.l
	jeq .L1728
	mvz.b sv+1,%d0
	not.l %d0
	move.l %d0,-(%sp)
	jsr cu_steps
	addq.l #4,%sp
	tst.l %d0
	jne .L1728
	move.l sv+120,%a2
	cmp.l sv+116.l,%a2
	jeq .L1733
	moveq #1,%d0
	move.b %d0,sv+7
.L1733:
	lea (-172,%fp),%a3
	clr.l %d3
	lea sv,%a4
	mov3q.l #-1,%d2
	move.l %a3,%a2
.L1738:
	mvz.b sv+1,%d0
	move.l sv+116,-(%sp)
	move.l %d3,-(%sp)
	move.l %d0,-(%sp)
	jsr sv_word
	lea (12,%sp),%sp
	move.b sv+7,%d4
	move.w %d0,(%a3)
	tst.b %d4
	jne .L1734
	mvz.w %d0,%d1
	mvz.w 24(%a4),%d6
	cmp.l %d1,%d6
	jeq .L1735
.L1734:
	cmp.l -184(%fp),%d3
	jge .L1736
	move.l %d3,-184(%fp)
.L1736:
	move.l %d3,%d2
.L1735:
	mov3q.l #7,%d1
	cmp.l %d3,%d1
	jge .L1737
	tst.w %d0
	jeq .L1737
	mvz.b sv+1,%d0
	move.l %d0,-(%sp)
	jsr cu_mi_settling
	addq.l #4,%sp
	tst.l %d0
	jne .L1728
.L1737:
	addq.l #2,%a3
	addq.l #1,%d3
	addq.l #2,%a4
	moveq #16,%d0
	cmp.l %d3,%d0
	jne .L1738
	tst.b %d4
	jne .L1889
	mov3q.l #-1,%d1
	cmp.l %d2,%d1
	jne .L1739
.L1728:
	jsr arp_tick
	jra .L1616
.L1681:
	jsr led_stock
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.l led_again
.L2182:
	addq.l #4,%sp
	jra .L1680
.L1885:
	clr.l %d0
	lea sq+480,%a0
	lea ovp_col,%a1
.L1691:
	btst %d0,%d2
	jeq .L1692
	lea (%a0,%d0.l),%a2
	move.b (%a2),(%a1,%d0.l)
.L1692:
	addq.l #1,%d0
	mov3q.l #4,%d1
	cmp.l %d0,%d1
	jne .L1691
	move.l %d3,%d4
	clr.l %d3
	move.b %d2,ovp_on
	or.l %d2,%d4
	lea shp,%a2
	lea sq+480,%a4
	lea (-140,%fp),%a3
	lea rui_uart_raw,%a5
.L1697:
	btst %d3,%d4
	jeq .L1693
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
.L1696:
	tst.l %d0
	jeq .L1694
	move.b (%a4,%d3.l),%d1
.L1695:
	move.b %d1,2(%a3,%a0.l)
	addq.l #1,%a0
	mov3q.l #4,%d7
	cmp.l %a0,%d7
	jne .L1696
	move.l %a3,-(%sp)
	mov3q.l #6,-(%sp)
	jsr (%a5)
	addq.l #8,%sp
.L1693:
	addq.l #1,%d3
	addq.l #4,%a2
	mov3q.l #4,%d0
	cmp.l %d3,%d0
	jne .L1697
	move.l #1100088672,-(%sp)
	jsr 1073746414
	clr.l sq+476
	addq.l #4,%sp
	jra .L1690
.L1694:
	move.b (%a2,%a0.l),%d1
	jra .L1695
.L1886:
	clr.l %d2
	jra .L1698
.L1887:
	moveq #111,%d3
	jra .L1699
.L1702:
	move.b %d3,ovt_col
	move.b %d2,%d4
	move.b %d2,ovt_on
	lea led_send4,%a0
	tst.l %d2
	jeq .L1703
	move.b %d3,-137(%fp)
	move.b %d3,-138(%fp)
	move.b %d3,-139(%fp)
	move.b %d3,-140(%fp)
	pea -140(%fp)
	pea 55.w
	jsr (%a0)
	addq.l #1,k44+12
.L2183:
	addq.l #4,%sp
	move.l #1100088672,(%sp)
	jsr 1073746414
	addq.l #4,%sp
	move.b %d4,k44+24
	move.b %d3,k44+25
	jra .L1701
.L1703:
	pea sht
	pea 55.w
	jsr (%a0)
	addq.l #1,k44+16
	jra .L2183
.L1710:
	move.b %d3,%d6
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
	move.l %d4,-(%sp)
	jsr mr_vb
	addq.l #8,%sp
	mvz.b %d0,%d0
	cmp.l %d0,%d7
	jeq .L1709
	tst.b 60(%a2,%d4.l)
	jeq .L1712
	move.l st+8,%d0
	moveq #20,%d1
	sub.l (%a2,%d4.l*4),%d0
	cmp.l %d0,%d1
	jcc .L1713
.L1712:
	moveq #1,%d2
	jra .L1711
.L1713:
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
	jeq .L1709
	move.l (%a5),%a0
	move.l %a5,-(%sp)
	move.l 40(%a0),%a0
	jsr (%a0)
	move.l 32(%a5),%d4
	addq.l #4,%sp
	move.l %d0,-180(%fp)
	tst.l %d4
	jeq .L1714
	move.l %d4,%d5
	move.l %d4,%a0
	add.l #4752,%d5
	clr.l %d1
.L1718:
	mvz.b (%a0),%d7
	cmp.l #255,%d7
	jeq .L1716
	mvz.b 1(%a0),%d7
	cmp.l #255,%d7
	jeq .L1716
	addq.l #1,%d1
.L1716:
	lea (66,%a0),%a0
	cmp.l %d5,%a0
	jne .L1718
	mulu.w #5674,%d6
	mvz.b %d3,%d0
	move.l -180(%fp),%a5
	move.l #1075599904,%a1
	add.l %d6,%a5
.L1723:
	mvz.b 3(%a1),%d6
	move.l %d4,%a0
.L1721:
	mvz.b (%a0),%d7
	cmp.l %d7,%d6
	jne .L1719
	mvz.b 1(%a0),%d7
	cmp.l %d0,%d7
	jeq .L1720
.L1719:
	lea (66,%a0),%a0
	cmp.l %d5,%a0
	jne .L1721
	tst.b 5653(%a5)
	jne .L1879
	mov3q.l #1,%a0
	jra .L1880
.L1879:
	mov3q.l #2,%a0
.L1880:
	add.l %a0,%d1
	moveq #71,%d6
	cmp.l %d1,%d6
	jlt .L1888
.L1720:
	addq.l #4,%a1
	addq.l #1,%a5
	cmp.l #1075599920,%a1
	jne .L1723
.L1714:
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
.L1724:
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
	jne .L1724
	jra .L1711
.L1888:
	moveq #2,%d2
	jra .L1711
.L1889:
	clr.l -184(%fp)
	moveq #15,%d2
.L1739:
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
.L1740:
	cmp.l %d2,%d0
	jle .L1741
	cmp.l -184(%fp),%d1
	sge %d1
	move.l %d1,%d0
	neg.l %d0
	tst.b %d0
	jeq .L1742
	move.l %d2,%d0
	sub.l -184(%fp),%d0
	add.l %d0,%d0
	add.l #11,%d0
.L1743:
	moveq #-9,%d6
	lea (%fp,%d0.l),%a1
	neg.l %d1
	move.b %d6,-140(%a1)
	tst.b %d1
	jeq .L1744
	move.l %d2,%d0
	addq.l #6,%d0
	sub.l -184(%fp),%d0
	add.l %d0,%d0
.L1745:
	move.l %d0,-(%sp)
	move.l %a0,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1728
	lea sv+24,%a0
.L1746:
	cmp.l -184(%fp),%d2
	jge .L1747
	clr.b %d2
	move.l sv+116,%d0
	addq.l #1,sv+68
	move.b %d2,sv+7
	tst.l %d0
	jlt .L1748
	addq.l #1,sv+124
.L1748:
	move.l %d0,sv+120
	jra .L1728
.L1741:
	move.w (%a2,%d0.l*2),%d3
	moveq #127,%d5
	addq.l #1,%d0
	addq.l #2,%a1
	move.l %d3,%d4
	lsr.l #7,%d4
	and.l %d5,%d3
	move.b %d4,-2(%a1)
	move.b %d3,-1(%a1)
	jra .L1740
.L1742:
	moveq #9,%d0
	jra .L1743
.L1744:
	moveq #10,%d0
	jra .L1745
.L1747:
	move.l -184(%fp),%d1
	lea (%a2,%d1.l*2),%a3
	move.w (%a3),(%a0,%d1.l*2)
	addq.l #1,%d1
	move.l %d1,-184(%fp)
	jra .L1746
.L1753:
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
	jeq .L1749
	move.l ux+3944,%d1
	mov3q.l #1,%d0
	lea ux+3920,%a0
.L1751:
	cmp.l %d0,%d1
	jhi .L1752
	subq.l #1,%d1
	move.l %d1,ux+3944
	addq.l #1,ux+32
	jra .L1750
.L1752:
	addq.l #3,%a0
	move.b (%a0),-3(%a0)
	move.b 1(%a0),-2(%a0)
	move.b 2(%a0),-1(%a0)
	addq.l #1,%d0
	jra .L1751
.L1756:
	move.l %a5,%d0
	mov3q.l #2,%d1
	add.l #-48,%d0
	cmp.l %d0,%d1
	jcs .L1760
	mvz.b cu+1,%d0
	cmp.l %a5,%d0
	jne .L1759
.L1761:
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
	jra .L1776
.L1760:
	moveq #10,%d0
	cmp.l %a1,%d0
	jne .L1761
	moveq #45,%d1
	cmp.l %a5,%d1
	jeq .L1762
	moveq #43,%d0
	cmp.l %a5,%d0
	jeq .L1762
	jra .L1761
.L1775:
	moveq #31,%d0
	cmp.l %d3,%d0
	jlt .L1772
	move.l ls+60,%d1
	lsr.l %d3,%d1
.L1773:
	btst #0,%d1
	jeq .L1774
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	move.l %d4,-(%sp)
	move.l %d3,-(%sp)
	move.l %a2,-(%sp)
	jsr 1074529568
	lea (20,%sp),%sp
	addq.l #1,ls+96
.L1774:
	addq.l #1,%d3
	jra .L1771
.L1772:
	move.l %d3,%d0
	add.l #-32,%d0
	move.l ls+64,%d1
	lsr.l %d0,%d1
	jra .L1773
.L1769:
	moveq #3,%d0
	addq.l #1,ux+3964
.L1755:
	addq.l #1,ux+24
	jra .L1776
.L1759:
	moveq #1,%d0
	jra .L1755
.L1890:
	moveq #2,%d0
	jra .L1755
.L1779:
	move.l #1075731444,%d5
	cmp.l sv+88.l,%d5
	jeq .L1778
	move.l st+8,%d0
	sub.l cu+16,%d0
	lsr.l #1,%d0
	jeq .L1778
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr cu_tab
	addq.l #8,%sp
	move.l %d0,%a2
	tst.l %d0
	jeq .L1778
	move.l %d2,-(%sp)
	moveq #8,%d3
	jsr cu_setup
	lea (11,%a2),%a2
	addq.l #4,%sp
.L1782:
	move.l %d3,%a3
	move.l %d2,-(%sp)
	lea (9,%a3),%a3
	move.l %a3,-(%sp)
	jsr 1073770536
	addq.l #8,%sp
	move.l %d0,%d5
	tst.l %d0
	jle .L1780
	moveq #43,%d0
	cmp.l %d2,%d0
	jne .L1781
	moveq #10,%d1
	cmp.l %d3,%d1
	jne .L1781
	mvz.b cu+29,%d0
	moveq #45,%d7
	cmp.l %d0,%d7
	jeq .L1780
	moveq #43,%d1
	cmp.l %d0,%d1
	jeq .L1780
.L1781:
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
.L1780:
	addq.l #1,%d3
	lea (16,%a2),%a2
	moveq #16,%d5
	cmp.l %d3,%d5
	jne .L1782
	addq.l #1,cu+20
	moveq #50,%d6
	cmp.l %d2,%d6
	jne .L1783
	addq.l #1,%d4
	lea st+8,%a0
	move.b %d4,cu+11
	move.l (%a0),cu+24
	jra .L1783
.L1795:
	addq.l #1,k44+32
.L1797:
	subq.l #2,%d0
	tst.l %d0
	jne .L1796
	clr.b %d7
	move.b %d7,k44+26
	jra .L1796
.L1794:
	mov3q.l #1,%d5
	cmp.l %d0,%d5
	jne .L1798
	addq.l #1,k44+4
	jra .L1796
.L1798:
	addq.l #1,k44+8
	jra .L1797
.L1799:
	tst.b dp+22.l
	jeq .L1800
	mvz.b dp+20,%d0
	cmp.l %d1,%d0
	jne .L1800
	mvz.b dp+21,%d0
	cmp.l %d5,%d0
	jne .L1800
.L1801:
	lea dp,%a4
	sub.l %a3,%a3
	lea dp+32,%a2
	move.l %a4,%a5
.L1813:
	moveq #43,%d0
	cmp.l %d5,%d0
	jeq .L1896
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
.L1806:
	move.l %d5,-(%sp)
	pea 9(%a3)
	jsr 1073770536
	addq.l #8,%sp
	tst.l %d0
	jgt .L1807
	clr.l -172(%fp)
.L1808:
	mvz.b 24(%a5),%d4
	move.b -172(%fp),%d7
	move.b -171(%fp),%d6
	move.l %d4,%a1
	mvz.b %d3,%d4
	move.b -170(%fp),%d1
	move.b -169(%fp),%d0
	cmp.l %a1,%d4
	jne .L1811
	mvs.b (%a2),%d4
	move.l %d4,%a1
	mvs.b %d7,%d4
	cmp.l %a1,%d4
	jne .L1811
	mvs.b 1(%a2),%d4
	move.l %d4,%a1
	mvs.b %d6,%d4
	cmp.l %a1,%d4
	jne .L1811
	mvs.b 2(%a2),%d4
	move.l %d4,%a1
	mvs.b %d1,%d4
	cmp.l %a1,%d4
	jne .L1811
	mvs.b 3(%a2),%d4
	move.l %d4,%a1
	mvs.b %d0,%d4
	cmp.l %a1,%d4
	jeq .L1812
.L1811:
	move.b %d3,24(%a5)
	move.b %d6,1(%a2)
	moveq #1,%d6
	move.b %d7,(%a2)
	move.b %d1,2(%a2)
	move.b %d0,3(%a2)
	move.b %d6,dp+23
.L1812:
	addq.l #1,%a3
	addq.l #4,%a2
	addq.l #1,%a5
	moveq #8,%d7
	cmp.l %a3,%d7
	jne .L1813
	tst.b dp+23.l
	jeq .L1788
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
.L1815:
	move.b (%a2)+,(%a1)
	mov3q.l #1,%a0
.L1814:
	lea 31(%a4,%a0.l),%a3
	mov3q.l #5,%d2
	move.b (%a3),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d2
	jne .L1814
	addq.l #5,%a1
	addq.l #5,%d0
	addq.l #4,%a4
	moveq #49,%d3
	cmp.l %d0,%d3
	jne .L1815
	moveq #-9,%d4
	pea 49.w
	move.l %d1,-(%sp)
	move.b %d4,-92(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1788
	clr.b %d5
	addq.l #1,dp+16
	move.b %d5,dp+23
.L1788:
	tst.l st
	jeq .L1784
.L1785:
	mov3q.l #1,%d6
	cmp.l 1094562388.l,%d6
	jne .L1784
	tst.l st+968
	jeq .L1784
	move.b 1079807565,%d2
	mvs.b %d2,%d0
	lsr.l #7,%d0
	jne .L1898
	addq.l #1,%d2
.L1816:
	move.l pj+160,%d0
	cmp.l pj+156.l,%d0
	jeq .L1820
	move.l pj+156,%d3
	sub.l %d0,%d3
	clr.l -(%sp)
	move.l %d3,%d0
	cmp.l #16383,%d3
	jls .L1818
	mvz.w #16383,%d0
.L1818:
	move.l %d0,-(%sp)
	mov3q.l #6,-(%sp)
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1850
	moveq #2,%d0
	add.l %d3,pj+160
	move.w %d0,pj+180
.L1820:
	move.l pj,%d1
	cmp.l pj+4.l,%d1
	jne .L1821
	tst.b pj+139.l
	jeq .L1822
	mvz.b pj+138,%d1
	mvz.b %d2,%d0
	cmp.l %d1,%d0
	jeq .L1823
.L1822:
	clr.l %d0
.L1824:
	move.l #1081903571,%a0
	lea pj-1081903431,%a1
.L1825:
	tst.l %d0
	jne .L1827
.L1828:
	move.l st+968,%d6
	cmp.l pj+164.l,%d6
	jeq .L1845
	moveq #2,%d7
	move.w %d7,pj+180
.L1845:
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
.L1846:
	move.l #1081903571,%a2
	add.l %a0,%a2
	tst.b (%a2)
	jeq .L1847
	move.b (%a2),%d0
	moveq #127,%d1
	moveq #15,%d3
	and.l %d1,%d0
	move.b %d0,9(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l %a0,%d3
	jne .L1846
.L1847:
	moveq #-9,%d4
	lea (%fp,%a0.l),%a2
	move.b %d4,-131(%a2)
	pea 10(%a0)
	move.l %a1,-(%sp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1850
	moveq #1,%d5
	move.b %d2,pj+138
	lea st+968,%a0
	lea st+8,%a1
	move.l (%a0),pj+164
	move.l (%a1),pj+168
	move.l #1081903571,%a0
	lea pj-1081903431,%a1
	move.b %d5,pj+139
.L1849:
	move.b (%a0),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L1849
	addq.l #1,pj+176
	jra .L1850
.L1892:
	sub.l %a0,%a0
	jra .L1802
.L1893:
	clr.l %d0
	jra .L1803
.L1895:
	clr.l %d0
.L2184:
	clr.b %d6
	jra .L1804
.L1896:
	clr.b %d3
	jra .L1806
.L1807:
	moveq #52,%d4
	muls.l %d4,%d0
	move.l #1075575112,%a0
	move.l (%a0,%d0.l),%d4
	clr.l -172(%fp)
	move.l %d4,%d0
	sub.l %a0,%a0
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L1808
.L1809:
	moveq #125,%d6
	move.b (%a0,%d4.l),%d1
	move.l %d1,%d0
	subq.l #1,%d0
	mvz.b %d0,%d0
	cmp.l %d0,%d6
	jcs .L1808
	lea (-172,%a0),%a1
	mov3q.l #4,%d0
	move.b %d1,(%a1,%fp.l)
	addq.l #1,%a0
	cmp.l %a0,%d0
	jne .L1809
	jra .L1808
.L1898:
	clr.b %d2
	jra .L1816
.L1821:
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
	jeq .L1850
	addq.l #1,pj+4
	addq.l #1,pj+172
	jra .L1820
.L1823:
	move.l st+968,%d3
	cmp.l pj+164.l,%d3
	jne .L1822
	move.l st+8,%d0
	moveq #99,%d4
	sub.l pj+168,%d0
	cmp.l %d0,%d4
	scc %d0
	mvs.b %d0,%d0
	neg.l %d0
	jra .L1824
.L1827:
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
	jne .L1825
	mvz.b %d3,%d3
	mvz.b %d1,%d1
	cmp.l %d3,%d1
	jne .L1828
	tst.b pj+181.l
	jeq .L1850
	move.l 1100949640,%d0
	mov3q.l #3,%d1
	and.l %d0,%d1
	tst.l %d1
	jne .L1829
	move.l %d0,%d1
	add.l #-1073741824,%d1
	cmp.l #129892351,%d1
	jhi .L1829
	move.l %d0,%a0
	add.l #1073744908,%d1
	lea (12,%a0),%a0
	move.l %a0,%a1
.L1832:
	mvz.b (%a1),%d0
	lsr.l #1,%d0
	jeq .L1830
.L1829:
	mvz.w #16383,%d0
	clr.l %d3
.L1831:
	clr.l -(%sp)
	move.l %d0,-(%sp)
	pea 9.w
	jsr pj_send
	lea (12,%sp),%sp
	tst.l %d0
	jeq .L1850
	addq.l #1,pj+184
	tst.l %d3
	jeq .L1836
	move.b pj+181,%d0
	mvz.b %d0,%d1
	lsr.l #1,%d1
	jeq .L1836
	clr.b %d7
	subq.l #1,%d0
	move.b %d0,pj+181
	move.b %d7,pj+180
.L1850:
	tst.l st
	jeq .L1854
	mov3q.l #1,%d3
	cmp.l 1094562388.l,%d3
	jne .L1855
	tst.l st+968
	jeq .L1855
	move.l st+44,%d1
	move.l txsx_over,%d0
	cmp.l kd_drop.l,%d1
	jne .L1856
	cmp.l kd_over.l,%d0
	jeq .L1857
.L1856:
	move.l st+8,%a0
	moveq #19,%d4
	sub.l kd_t,%a0
	cmp.l %a0,%d4
	jcc .L1857
	cmp.l #16383,%d1
	jls .L1858
	mvz.w #16383,%d1
.L1858:
	cmp.l #16383,%d0
	jls .L1859
	mvz.w #16383,%d0
.L1859:
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
	jeq .L1857
	lea st+44,%a0
	lea txsx_over,%a1
	lea st+8,%a2
	move.l (%a0),kd_drop
	move.l (%a1),kd_over
	move.l (%a2),kd_t
.L1857:
	tst.l st
	jeq .L1854
.L1855:
	mov3q.l #1,%d0
	cmp.l 1094562388.l,%d0
	jne .L1860
	tst.l st+968
	jeq .L1860
	jsr 1075312702
	move.l %d0,%d2
	add.l #352,%d2
	move.l %d2,-(%sp)
	move.l %d0,%a2
	jsr 1074425250
	addq.l #4,%sp
	tst.l qp+100
	jeq .L1861
	cmp.l #4095,%d0
	jle .L1862
	mvz.w #4095,%d0
.L1863:
	move.l 352(%a2),%a0
	lea qp,%a3
	move.l %d0,(%a3)
	move.l %d2,-(%sp)
	move.l 52(%a0),%a0
	mov3q.l #1,qp+4
	jsr (%a0)
	addq.l #4,%sp
	tst.l %d0
	jeq .L1864
	move.l %d0,%a0
	moveq #11,%d0
	mvz.b 2430(%a0),%d2
	cmp.l %d2,%d0
	jcc .L1865
.L1864:
	clr.l %d2
.L1866:
	move.w #11521,%d3
	move.l #-260222380,%d1
	move.l %d1,-140(%fp)
	move.w %d3,-136(%fp)
	cmp.l qp+44.l,%d2
	jne .L1867
	tst.l qp+48
	jeq .L1868
.L1867:
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
	jeq .L1861
	move.l %d2,qp+44
	clr.l qp+48
	addq.l #1,qp+52
.L1868:
	move.l %fp,%d2
	add.l #-140,%d2
	jra .L1869
.L1830:
	lea (24,%a1),%a1
	cmp.l %d1,%a1
	jne .L1832
	move.b pj+180,%d0
	move.l %a0,%d3
	tst.b %d0
	jge .L1833
	clr.l %d0
.L1834:
	tst.b (%a0)
	sne %d2
	lea (24,%a0),%a0
	mvs.b %d2,%d2
	sub.l %d2,%d0
	cmp.l %d1,%a0
	jne .L1834
	jra .L1831
.L1836:
	clr.b %d0
	move.b %d0,pj+181
	jra .L1850
.L1833:
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
.L1844:
	mvz.b pj+180,%d0
	sub.l %a3,%a3
	add.l %d1,%d0
	muls.w #24,%d0
	lea (%a0,%d0.l),%a1
	tst.b (%a1)
	sne %d0
	neg.l %d0
	move.b %d0,(%a2)
.L1838:
	move.b (%a1),%d0
	jeq .L1837
	move.b 8(%a1,%a3.l),%d0
	moveq #127,%d5
	and.l %d5,%d0
.L1837:
	addq.l #1,%a3
	move.b %d0,(%a2,%a3.l)
	moveq #15,%d6
	cmp.l %a3,%d6
	jne .L1838
	sub.l %a1,%a1
.L1839:
	move.l %a1,%a3
	addq.l #1,%a1
	tst.b (%a2,%a1.l)
	jne .L1841
.L1842:
	moveq #15,%d3
	cmp.l %a3,%d3
	jeq .L1840
	clr.b %d0
	addq.l #1,%a3
	move.b %d0,(%a2,%a3.l)
	jra .L1842
.L1841:
	moveq #15,%d7
	cmp.l %a1,%d7
	jne .L1839
.L1840:
	addq.l #1,%d1
	lea (16,%a2),%a2
	moveq #8,%d4
	cmp.l %d1,%d4
	jne .L1844
	moveq #-9,%d5
	pea 139.w
	move.l %d2,-(%sp)
	move.b %d5,-2(%fp)
	jsr send
	addq.l #8,%sp
	tst.l %d0
	jeq .L1850
	move.b pj+180,%d0
	addq.l #8,%d0
	move.b %d0,pj+180
	jra .L1850
.L1784:
	lea pj,%a0
	move.l (%a0),%d0
.L1851:
	cmp.l pj+4.l,%d0
	jeq .L1850
	moveq #31,%d1
	moveq #10,%d2
	and.l pj+4,%d1
	mvz.b 8(%a0,%d1.l*4),%d1
	cmp.l %d1,%d2
	jeq .L1852
	addq.l #1,pj+156
.L1852:
	addq.l #1,pj+4
	jra .L1851
.L1862:
	tst.l %d0
	jge .L1863
	clr.l %d0
	jra .L1863
.L1865:
	addq.l #1,%d2
	jra .L1866
.L1870:
	mov3q.l #3,%d7
	and.l %d7,%d0
	moveq #16,%d6
	lea 64(%a3,%d0.l*2),%a0
	lea 65(%a3,%d0.l*2),%a1
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
	jeq .L1861
	addq.l #1,qp+60
.L1869:
	move.l qp+60,%d0
	cmp.l qp+56.l,%d0
	jne .L1870
	move.l qp+92,%d1
	cmp.l qp+96.l,%d1
	jeq .L1861
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
	jeq .L1861
	move.l %d2,qp+96
.L1861:
	tst.l st
	jeq .L1854
.L1860:
	mov3q.l #1,%d5
	cmp.l 1094562388.l,%d5
	jne .L1854
	tst.l st+968
	jeq .L1854
	lea ram_ok,%a0
	btst #2,3(%a0)
	jeq .L1854
	move.l pmo+64,%d2
	tst.l qp+100
	jeq .L1854
	move.w #11521,%a2
	move.l #-260222380,%a1
	move.l %a1,-140(%fp)
	move.w %a2,-136(%fp)
	cmp.l pmo+124.l,%d2
	jeq .L1872
	moveq #17,%d0
	moveq #127,%d1
	move.b %d0,-134(%fp)
	move.l pmo,%d0
	cmp.l %d0,%d1
	jcc .L1873
	moveq #127,%d0
.L1873:
	move.b %d0,-133(%fp)
	move.l pmo+4,%d0
	cmp.l #16383,%d0
	jls .L1874
	mvz.w #16383,%d0
.L1874:
	move.l %d0,%d1
	moveq #127,%d3
	and.l %d3,%d0
	lsr.l #7,%d1
	move.b %d1,-132(%fp)
	move.b %d0,-131(%fp)
	move.l pmo+8,%d0
	cmp.l #16383,%d0
	jls .L1875
	mvz.w #16383,%d0
.L1875:
	move.l %d0,%d1
	moveq #127,%d4
	and.l %d4,%d0
	lsr.l #7,%d1
	move.b %d1,-130(%fp)
	move.b %d0,-129(%fp)
	move.l pmo+12,%d0
	cmp.l %d0,%d4
	jcc .L1876
	moveq #127,%d0
.L1876:
	move.b %d0,-128(%fp)
	lea fp,%a0
	tst.l pmo+52
	jeq .L1899
	move.l (%a0),%d1
	sub.l pmo+108,%d1
	cmp.l #1499,%d1
	sls %d1
	neg.l %d1
.L1877:
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
	jeq .L1854
	move.l %d2,pmo+124
.L1872:
	move.l pmo+16,%d2
	cmp.l pmo+128.l,%d2
	jeq .L1854
	move.l st+8,%d0
	moveq #19,%d7
	sub.l pmo+132,%d0
	cmp.l %d0,%d7
	jcc .L1854
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
	jeq .L1854
	lea st+8,%a2
	move.l %d2,pmo+128
	move.l (%a2),pmo+132
.L1854:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l -176(%fp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L1575
	move.l %d0,st+332
.L1575:
	movem.l -228(%fp),#15612
	unlk %fp
	rts
.L1899:
	clr.b %d1
	jra .L1877
	.size	rui_tick, .-rui_tick
	.text
.LC6:
	.string	"%s"
	.text
	.align	2
	.globl	rui_draw
	.type	rui_draw, @function
rui_draw:
	lea (-252,%sp),%sp
	movem.l #31996,(%sp)
	move.l 256(%sp),%a5
	move.l -66650100,%d1
	move.l st+1082,%d0
	move.l 16(%a5),%d3
	move.l %d1,64(%sp)
	tst.l %d0
	jeq .L2186
	sub.l st+8,%d0
	tst.l %d0
	jgt .L2187
.L2186:
	clr.l 44(%sp)
.L2188:
	lea ram_ok,%a0
	btst #0,3(%a0)
	jeq .L2190
	move.l 16(%a5),%a1
	move.l %a1,52(%sp)
	tst.l st+4
	jne .L2191
	tst.l st+972
	jne .L2192
	tst.b sv+8.l
	jne .L2192
	tst.l 44(%sp)
	jne .L2236
	jra .L2194
.L2187:
	move.l %d3,%a0
	move.l %d3,%d0
	addq.l #6,%a0
	lea (112,%sp),%a1
	add.l #566,%d0
.L2189:
	move.b 1(%a0),(%a1)
	addq.l #8,%a0
	move.b -8(%a0),1(%a1)
	addq.l #2,%a1
	cmp.l %a0,%d0
	jne .L2189
	mov3q.l #1,44(%sp)
	jra .L2188
.L2191:
	tst.l st+1058
	jne .L2194
	move.l commits,%a6
	cmp.l st+24.l,%a6
	jne .L2196
	move.l 52(%sp),%a0
	move.l %a0,%d0
	add.l #1024,%d0
.L2197:
	clr.l (%a0)+
	cmp.l %a0,%d0
	jne .L2197
	move.l %a6,st+20
.L2190:
	tst.l 44(%sp)
	jeq .L2194
	tst.l st+4
	jne .L2221
	tst.l st+972
	jne .L2222
.L2236:
	tst.b sv+8.l
	jne .L2222
.L2194:
	tst.l ram_bad
	jeq .L2224
	move.l ram_show_until,%d0
	move.l 16(%a5),%d3
	sub.l st+8,%d0
	tst.l %d0
	jgt .L2239
	tst.l dg
	jne .L2228
.L2227:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 64(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L2185
	move.l %d0,st+332
.L2185:
	movem.l (%sp),#31996
	lea (252,%sp),%sp
	rts
.L2192:
	move.l commits,%a6
.L2196:
	cmp.l st+340.l,%a6
	jne .L2198
	tst.l st+344
	jeq .L2199
.L2198:
	move.l -66650100,%a4
	move.l sh_seq,%d4
	lea copy32,%a2
	move.l %a4,68(%sp)
	btst #0,%d4
	jne .L2200
	pea 256.w
	pea rui_big
	pea rui_big+3072
	jsr (%a2)
	pea 704.w
	pea rui_big+6912
	pea rui_big+9728
	jsr (%a2)
	lea (24,%sp),%sp
	cmp.l sh_seq.l,%d4
	jne .L2200
	pea 256.w
	pea rui_big+3072
	pea rui_big+2048
	jsr (%a2)
	lea (12,%sp),%sp
	tst.l st+872
	jne .L2201
	clr.l -(%sp)
	pea rui_big+2048
	pea 64.w
	pea 128.w
	pea st+872
	jsr 1074198978
	lea (20,%sp),%sp
.L2201:
	lea rui_big+9728,%a2
	clr.l %d5
.L2214:
	tst.b 4(%a2)
	jeq .L2202
	lea st+408,%a0
	clr.l %d7
	move.l %a0,60(%sp)
	move.l %a2,%d4
	addq.l #8,%d4
	lea st+552,%a0
.L2213:
	move.l 60(%sp),%a1
	addq.l #4,60(%sp)
	tst.l (%a1)+
	jeq .L2204
	mvz.b (%a0),%d0
	cmp.l %d0,%d5
	jne .L2204
	lea st+472,%a4
	sub.l %a1,%a1
	mvz.b (%a4,%d7.l),%d4
	mvz.b 5(%a0),%d1
	lea (6,%a0),%a3
.L2206:
	cmp.l %d1,%a1
	jlt .L2207
	move.b 4(%a0),%d0
	lea 76(%sp,%d1.l),%a3
	btst #1,%d0
	jeq .L2237
	move.l %d4,%d0
	add.l #-64,%d0
	move.l %d0,56(%sp)
	tst.l %d0
	jle .L2209
	move.b #43,(%a3)
	addq.l #1,%d1
	lea 76(%sp,%d1.l),%a3
.L2238:
	sub.l %a1,%a1
	jra .L2208
.L2207:
	lea (%a3,%a1.l),%a4
	move.b (%a4),76(%sp,%a1.l)
	addq.l #1,%a1
	jra .L2206
.L2209:
	tst.l 56(%sp)
	jeq .L2238
	move.b #45,(%a3)
	moveq #64,%d2
	mov3q.l #1,%a1
	sub.l %d4,%d2
	move.l %d2,56(%sp)
.L2208:
	lea (72,%sp),%a4
	clr.l %d4
.L2211:
	move.l 56(%sp),%d6
	moveq #10,%d0
	addq.l #1,%d4
	rems.l %d0,%d2:%d6
	divs.l %d0,%d6
	add.l #48,%d2
	move.b %d2,(%a4)
	move.l %d6,56(%sp)
	tst.l %d6
	jeq .L2210
	addq.l #1,%a4
	mov3q.l #4,%d6
	cmp.l %d4,%d6
	jne .L2211
.L2210:
	add.l %a1,%a3
	move.l %d4,%d0
.L2212:
	subq.l #1,%d0
	move.b 72(%sp,%d0.l),(%a3)+
	tst.l %d0
	jne .L2212
	mvz.w #252,%d0
	add.l %sp,%d0
	add.l %d1,%d0
	add.l %d4,%d0
	add.l %d0,%a1
	clr.b %d0
	move.l %sp,%d4
	add.l #76,%d4
	move.b %d0,-176(%a1)
.L2204:
	addq.l #1,%d7
	lea (20,%a0),%a0
	moveq #16,%d1
	cmp.l %d7,%d1
	jne .L2213
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
	jgt .L2202
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
.L2202:
	addq.l #1,%d5
	lea (44,%a2),%a2
	moveq #64,%d0
	cmp.l %d5,%d0
	jne .L2214
	move.l -66650100,%d0
	move.l %a6,st+340
	addq.l #1,st+348
	sub.l 68(%sp),%d0
	add.l %d0,st+356
	cmp.l st+360.l,%d0
	jls .L2215
	move.l %d0,st+360
.L2215:
	clr.l st+344
.L2199:
	pea 256.w
	pea rui_big+2048
	move.l 60(%sp),-(%sp)
	jsr copy32
	lea (12,%sp),%sp
	cmp.l st+20.l,%a6
	jeq .L2216
	move.l -66650100,%d0
	addq.l #1,st+308
	sub.l t_commit,%d0
	add.l %d0,st+304
	cmp.l st+312.l,%d0
	jls .L2216
	move.l %d0,st+312
.L2216:
	move.l st+388,%d1
	tst.l %d1
	jeq .L2217
	cmp.l st+392.l,%a6
	jeq .L2217
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+396
	addq.l #1,st+400
	cmp.l st+404.l,%d0
	jls .L2218
	move.l %d0,st+404
.L2218:
	clr.l st+388
.L2217:
	move.l st+368,%d1
	tst.l %d1
	jeq .L2219
	move.l -66650100,%d0
	sub.l %d1,%d0
	add.l %d0,st+372
	addq.l #1,st+376
	cmp.l st+380.l,%d0
	jls .L2220
	move.l %d0,st+380
.L2220:
	clr.l st+368
.L2219:
	move.l %a6,st+20
	move.l -66650100,%d0
	move.l %d0,st+56
	sub.l t_commit,%d0
	addq.l #1,st+28
	move.l %d0,st+60
	jra .L2190
.L2237:
	move.l %d4,56(%sp)
	jra .L2238
.L2200:
	pea 256.w
	pea rui_big+2048
	move.l 60(%sp),-(%sp)
	addq.l #1,st+32
	jsr (%a2)
	lea (12,%sp),%sp
	jra .L2190
.L2221:
	tst.l st+1058
	jne .L2194
.L2222:
	move.l %d3,%a0
	add.l #566,%d3
	lea (112,%sp),%a1
	addq.l #6,%a0
.L2223:
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
	jne .L2223
	jra .L2194
.L2224:
	tst.l dg
	jeq .L2227
	move.l 16(%a5),%d3
.L2228:
	move.l st+216,%d0
	clr.l %d2
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L2227
	lea ram_t_ddr,%a0
	lea (112,%sp),%a2
.L2230:
	move.b (%a0,%d2.l),%d0
	jne .L2231
	move.l dg+8,-(%sp)
	pea (%a2,%d2.l)
	lea u10,%a3
	jsr (%a3)
	addq.l #8,%sp
	lea ram_t_bad,%a0
	add.l %d0,%d2
.L2232:
	move.b (%a0),%d0
	jne .L2233
	move.l dg+12,-(%sp)
	pea (%a2,%d2.l)
	mvz.w #260,%d6
	jsr (%a3)
	add.l %sp,%d6
	add.l %d6,%d2
	add.l %d0,%d2
	clr.b %d0
	move.l %d2,%a0
	addq.l #8,%sp
	move.b %d0,-140(%a0)
.L2225:
	tst.l %d3
	jeq .L2227
	clr.l -(%sp)
	move.l %d3,-(%sp)
	pea 64.w
	pea 128.w
	move.l %sp,%d2
	add.l #92,%d2
	move.l %d2,-(%sp)
	jsr 1074198978
	move.l #1098790956,-(%sp)
	jsr 1074207612
	move.l %a2,-(%sp)
	pea .LC6
	move.l %a2,-(%sp)
	mov3q.l #1,-(%sp)
	moveq #63,%d1
	move.l %d0,%a0
	mov3q.l #1,-(%sp)
	mvz.w 6(%a0),%d0
	sub.l %d0,%d1
	move.l %d1,-(%sp)
	pea 64.w
	move.l %a0,-(%sp)
	move.l %d2,-(%sp)
	jsr 1074205920
	lea (60,%sp),%sp
	jra .L2227
.L2231:
	move.b %d0,(%a2,%d2.l)
	addq.l #1,%d2
	jra .L2230
.L2233:
	move.b %d0,(%a2,%d2.l)
	addq.l #1,%a0
	addq.l #1,%d2
	jra .L2232
.L2239:
	lea ram_t_err,%a2
	jra .L2225
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
	jne .L2269
	cmp.l ed+88.l,%d1
	jeq .L2269
	move.l %d1,ed+88
	mov3q.l #1,ed+92
.L2269:
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
	jne .L2270
	moveq #66,%d5
	cmp.l %d2,%d5
	jne .L2271
	tst.b k44+20.l
	jeq .L2272
	clr.b %d6
	move.b %d6,k44+20
	tst.b k44+22.l
	jeq .L2272
	moveq #2,%d7
	move.w %d7,k44+22
.L2272:
	clr.l u46
	tst.b u46+48.l
	jeq .L2273
	clr.b %d0
	move.b %d0,u46+48
.L2280:
	mov3q.l #1,%d0
.L2274:
	move.l -66650100,%d1
	addq.l #1,st+336
	sub.l 64(%sp),%d1
	add.l %d1,st+328
	cmp.l st+332.l,%d1
	jls .L2268
	move.l %d1,st+332
.L2268:
	movem.l (%sp),#31996
	lea (100,%sp),%sp
	rts
.L2271:
	cmp.l #134,%d2
	jne .L2275
	clr.l tk
	tst.l tk+8
	jeq .L2273
	move.l st+248,%d0
	clr.l tk+8
	btst #6,%d0
	jeq .L2276
	moveq #-65,%d1
	and.l %d0,%d1
	move.l %d1,st+248
	tst.l st+4
	jne .L2591
.L2276:
	clr.l %d0
	jra .L2274
.L2275:
	move.l %d2,%d0
	add.l #-68,%d0
	lsr.l #1,%d0
	jne .L2273
	moveq #31,%d1
	mov3q.l #1,%d0
	and.l %d4,%d1
	lsl.l %d1,%d0
	and.l st+208,%d0
	tst.l %d0
	jeq .L2278
	move.l st+200,%d3
	move.l %d3,%d5
	move.l st+220,%d1
	move.l %d1,%d0
	and.l #2097152,%d0
	and.l #786432,%d5
	or.l %d5,%d0
	jeq .L2279
	addq.l #1,nk+16
.L2279:
	and.l #-786433,%d3
	bclr #21,%d1
	move.l %d3,st+200
	move.l %d1,st+220
.L2278:
	moveq #69,%d6
	cmp.l %d2,%d6
	jne .L2273
	tst.l nk
	jeq .L2273
	moveq #-33,%d7
	and.l %d7,st+240
	clr.l nk
	tst.l st+4
	jeq .L2280
	mov3q.l #1,-(%sp)
	pea 69.w
	lea queue_key,%a2
	jsr (%a2)
	clr.l -(%sp)
	pea 69.w
	jsr (%a2)
.L2590:
	jsr flush
.L2580:
	lea (16,%sp),%sp
	jra .L2280
.L2273:
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
	jeq .L2281
	not.l %d0
	and.l %d5,%d0
	move.l %d0,(%a2,%a0.l*4)
	jra .L2280
.L2281:
	move.l %d2,%d4
	mov3q.l #5,%d5
	add.l #-64,%d4
	cmp.l %d4,%d5
	jcs .L2282
	move.l ls+28,%d5
	btst %d4,%d5
	jeq .L2282
	mov3q.l #1,%d0
	lsl.l %d4,%d0
	move.l ls+32,%d1
	not.l %d0
	and.l %d0,%d5
	move.l %d5,ls+28
	btst %d4,%d1
	jeq .L2280
	and.l %d1,%d0
	move.l %d0,ls+32
.L2592:
	clr.l -(%sp)
.L2581:
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	jra .L2579
.L2282:
	move.l %d1,%a1
	move.l %d0,%d4
	lea (121,%a1),%a1
	lea sq,%a0
	move.l (%a0,%a1.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L2283
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a0,%a1.l*4)
	jra .L2592
.L2283:
	move.l %d1,%a0
	move.l %d0,%d4
	lea (50,%a0),%a0
	move.l (%a2,%a0.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L2284
	not.l %d0
	and.l %d3,%d0
	move.l %d2,%d1
	mov3q.l #7,%d6
	add.l #-112,%d1
	move.l %d0,(%a2,%a0.l*4)
	cmp.l %d1,%d6
	jcs .L2276
	lea ram_ok,%a0
	btst #1,3(%a0)
	jeq .L2276
	move.l ux,%d3
	btst %d1,%d3
	jeq .L2276
	mov3q.l #1,%d0
	lsl.l %d1,%d0
	not.l %d0
	and.l %d3,%d0
	move.l %d0,ux
.L2591:
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
.L2585:
	addq.l #8,%sp
	jra .L2276
.L2284:
	move.l %d1,%a0
	move.l %d0,%d4
	lea (226,%a0),%a0
	move.l (%a2,%a0.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L2285
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a2,%a0.l*4)
	move.l st+4,%d0
	or.l sq+408,%d0
	jeq .L2276
	jra .L2591
.L2285:
	add.l #58,%d1
	move.l %d0,%d4
	move.l (%a2,%d1.l*4),%d3
	and.l %d3,%d4
	tst.l %d4
	jeq .L2276
	not.l %d0
	and.l %d3,%d0
	move.l %d0,(%a2,%d1.l*4)
	tst.l st+4
	jeq .L2280
	clr.l -(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
.L2579:
	addq.l #8,%sp
	jra .L2280
.L2270:
	moveq #31,%d1
	mov3q.l #1,%d3
	and.l %d4,%d1
	move.l %d2,%d0
	lsr.l #5,%d0
	move.l %d0,%a6
	add.l #66,%d0
	move.l (%a2,%d0.l*4),%d0
	lsl.l %d1,%d3
	move.l %d1,58(%sp)
	and.l %d3,%d0
	tst.l %d0
	jne .L2280
	move.l %a6,%d5
	move.l %d3,%d0
	add.l #58,%d5
	and.l (%a2,%d5.l*4),%d0
	tst.l %d0
	jne .L2280
	move.l %a6,%d0
	add.l #121,%d0
	lea sq,%a5
	move.l (%a5,%d0.l*4),%d0
	and.l %d3,%d0
	tst.l %d0
	jne .L2280
	move.l %a6,%d6
	move.l %d3,%d0
	add.l #50,%d6
	and.l (%a2,%d6.l*4),%d0
	tst.l %d0
	jne .L2276
	move.l %a6,%d0
	add.l #226,%d0
	move.l (%a2,%d0.l*4),%d0
	and.l %d3,%d0
	tst.l %d0
	jne .L2276
	tst.l nk
	jeq .L2286
	move.l %d2,%d1
	add.l #-18,%d1
	lsr.l #1,%d1
	jeq .L2289
	cmp.l #181,%d2
	jne .L2288
.L2289:
	lea (%a4,%d0.l),%a0
	moveq #32,%d1
	move.l (%a0),68(%sp,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L2289
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
	jra .L2585
.L2288:
	clr.l nk
	addq.l #1,nk+8
	tst.l st+4
	jeq .L2286
	mov3q.l #1,-(%sp)
	pea 69.w
	jsr queue_key
	jsr flush
	addq.l #8,%sp
.L2286:
	moveq #66,%d6
	cmp.l %d2,%d6
	jne .L2290
	move.l st+4,%d0
	tst.l %d0
	jeq .L2291
	tst.l st+1058
	jne .L2292
.L2291:
	move.l st+216,%d1
	or.l st+248,%d1
	or.l st+920,%d1
	btst #0,%d1
	jne .L2292
	move.w #256,%d7
	lea st+8,%a0
	move.l (%a0),k44
	move.w %d7,k44+20
.L2292:
	lea st+8,%a0
	move.l (%a0),u46+4
	tst.l sq+408
	jeq .L2319
	tst.l %d0
	jeq .L2295
	tst.l st+1058
	jne .L2319
	move.l sq+484,%d1
	move.l st+232,%d0
.L2297:
	or.l %d1,%d0
	tst.w %d0
	jeq .L2319
	moveq #1,%d0
	clr.b %d1
	addq.l #1,u46+32
	move.b %d0,u46+48
	move.b %d1,k44+20
	jra .L2280
.L2290:
	cmp.l #128,%d2
	jne .L2293
	lea masks,%a0
	move.l (%a0),nk+20
.L2319:
	move.l %d2,%d6
	mov3q.l #1,%d0
	move.l st+4,%d7
	add.l #-64,%d6
	cmp.l %d6,%d0
	jcs .L2338
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jne .L2337
	tst.l fk_claim
	jeq .L2340
	move.b ls,%d0
	move.b u46+48,%d1
	or.l %d1,%d0
	tst.b %d0
	jne .L2340
	move.l st+216,%d0
	moveq #65,%d1
	or.l st+972,%d7
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
	or.l %d7,%d0
	jne .L2340
	tst.l sq+408
	jeq .L2341
	tst.w sq+486.l
	jne .L2340
.L2341:
	tst.w st+202.l
	jne .L2340
	move.l sv+88,-(%sp)
	jsr overlay
	addq.l #4,%sp
	or.l ov_list,%d0
	jne .L2340
	or.l %d3,st+272
	moveq #64,%d4
	cmp.l %d2,%d4
	jne .L2420
	moveq #15,%d0
.L2342:
	lea fk,%a0
	addq.l #1,(%a0,%d6.l*4)
	move.l %d0,dp
	addq.l #1,dp+4
	jra .L2589
.L2295:
	move.l sq+484,%d1
	jra .L2297
.L2293:
	moveq #68,%d6
	cmp.l %d2,%d6
	jne .L2298
	move.l tk,%d0
	or.l u46,%d0
	jeq .L2299
	tst.l st+4
	jeq .L2299
	addq.l #1,tk+4
	jra .L2319
.L2299:
	move.l st+216,%d0
	moveq #64,%d7
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d0,%d7
	move.l %d7,%a0
	btst #6,%d0
	jne .L2301
	move.l st+240,%d0
	move.l st+208,%d7
	move.l %d7,%d1
	move.l st+912,%d6
	or.l %d0,%d1
	or.l %d6,%d1
	move.w %d1,%ccr
	jeq .L2302
	tst.b u46+48.l
	jeq .L2303
.L2302:
	move.l st+8,%a1
	mov3q.l #2,%d1
	sub.l u46+4,%a1
	cmp.l %a1,%d1
	jcc .L2304
.L2301:
	moveq #16,%d2
	or.l %d2,st+272
	tst.l %a0
	jne .L2305
	moveq #1,%d4
	addq.l #1,u46+20
	addq.l #1,u46+16
	move.b %d4,k44+21
.L2305:
	tst.l st+4
	jeq .L2306
	tst.b k44+22.l
	jeq .L2307
	tst.b k44+26.l
	jne .L2307
	tst.l %a0
	jne .L2307
	moveq #1,%d6
	moveq #1,%d7
	clr.b %d0
	mvz.w #256,%d5
	move.l %d5,st+296
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
.L2583:
	jsr flush
	jra .L2280
.L2307:
	mov3q.l #3,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr leave
	jra .L2579
.L2306:
	clr.l -(%sp)
.L2587:
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	jra .L2584
.L2304:
	move.w %d7,%ccr
	jeq .L2308
.L2303:
	or.l %d6,%d0
	move.w %d0,%ccr
	jeq .L2308
	tst.b u46+48.l
	jeq .L2319
.L2308:
	addq.l #1,u46+40
	jra .L2319
.L2298:
	moveq #53,%d1
	cmp.l %d2,%d1
	jne .L2309
	move.l st+216,%d6
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d6,50(%sp)
	btst #6,%d6
	jne .L2310
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
	jne .L2311
	tst.b u46+48.l
	jeq .L2319
.L2312:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L2310
.L2311:
	tst.l %d6
	jeq .L2312
.L2310:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #32,%d4
	swap %d4
	or.l %d7,%d1
	or.l %d4,st+268
	btst #6,%d1
	jeq .L2314
	mov3q.l #1,tk
.L2314:
	clr.l st+1038
	tst.l st+4
	jeq .L2315
	moveq #1,%d6
	mvz.w #256,%d5
	moveq #1,%d7
	moveq #1,%d0
	move.l %d5,st+296
	addq.l #1,st+998
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
	jra .L2583
.L2315:
	mov3q.l #1,-(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	addq.l #1,st+994
.L2584:
	lea (12,%sp),%sp
	jra .L2280
.L2309:
	moveq #16,%d1
	cmp.l %d2,%d1
	jne .L2294
	move.l st+216,%d6
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d6,50(%sp)
	btst #6,%d6
	jne .L2316
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
	jne .L2317
	tst.b u46+48.l
	jeq .L2319
.L2318:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L2316
.L2317:
	tst.l %d6
	jeq .L2318
.L2316:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #1,%d4
	swap %d4
	or.l %d7,%d1
	or.l %d4,st+264
	btst #6,%d1
	jeq .L2320
	mov3q.l #1,tk
.L2320:
	clr.l st+1038
	tst.l st+4
	jeq .L2321
	moveq #1,%d6
	mvz.w #256,%d5
	moveq #1,%d7
	moveq #2,%d0
	move.l %d5,st+296
	move.b %d6,st+161
	move.w %d7,st+162
	move.b %d0,st+993
.L2586:
	addq.l #1,st+1078
	jra .L2583
.L2321:
	mov3q.l #2,-(%sp)
.L2588:
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	addq.l #1,st+1074
	jra .L2584
.L2294:
	moveq #52,%d1
	cmp.l %d2,%d1
	jne .L2296
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L2322
	tst.b u46+48.l
	jeq .L2319
.L2322:
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #6,%d0
	jne .L2319
	tst.l sq+408
	jeq .L2323
	tst.w sq+486.l
	jne .L2319
.L2323:
	tst.w st+202.l
	jne .L2319
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
	jeq .L2324
	moveq #1,%d6
	moveq #3,%d7
	mvz.w #256,%d5
	move.b %d2,st+161
	move.l %d5,st+296
	move.w %d6,st+162
	move.b %d7,st+993
	jra .L2586
.L2324:
	mov3q.l #3,-(%sp)
	jra .L2588
.L2296:
	moveq #51,%d0
	cmp.l %d2,%d0
	jne .L2300
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L2325
	tst.b u46+48.l
	jeq .L2319
.L2325:
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #6,%d0
	jne .L2319
	tst.l sq+408
	jeq .L2326
	tst.w sq+486.l
	jne .L2319
.L2326:
	tst.w st+202.l
	jne .L2319
	moveq #1,%d1
	moveq #8,%d2
	swap %d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	clr.l st+1038
	move.b %d1,k44+21
	or.l %d2,st+268
	tst.l st+4
	jeq .L2327
	moveq #1,%d5
	moveq #4,%d6
	mvz.w #256,%d4
	move.b %d1,st+161
	move.l %d4,st+296
	move.w %d5,st+162
	move.b %d6,st+993
	jra .L2583
.L2327:
	mov3q.l #4,-(%sp)
	jra .L2587
.L2300:
	moveq #48,%d7
	cmp.l %d2,%d7
	jne .L2313
	move.l st+216,%d0
	move.l st+248,%a0
	move.l st+920,%d7
	move.l %d0,50(%sp)
	btst #6,%d0
	jne .L2328
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
	jne .L2329
	tst.b u46+48.l
	jeq .L2319
.L2330:
	moveq #1,%d2
	mov3q.l #1,u46
	addq.l #1,u46+16
	move.b %d2,k44+21
	jra .L2328
.L2329:
	tst.l %d6
	jeq .L2330
.L2328:
	mvz.b 1093765506,%d0
	moveq #11,%d4
	cmp.l %d0,%d4
	jcs .L2419
	move.b 1093765506,%d0
	add.l #16,%d0
.L2331:
	move.l %a0,%d1
	or.l 50(%sp),%d1
	moveq #1,%d5
	swap %d5
	or.l %d7,%d1
	or.l %d5,st+268
	btst #6,%d1
	jeq .L2332
	mov3q.l #1,tk
.L2332:
	tst.l st+4
	jeq .L2333
	tst.l st+1038
	jeq .L2334
	mov3q.l #3,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr leave
	addq.l #1,st+1050
	jra .L2579
.L2419:
	moveq #16,%d0
	jra .L2331
.L2334:
	moveq #1,%d7
	moveq #1,%d1
	mvz.w #256,%d6
	move.b %d0,st+993
	mov3q.l #1,st+1038
	addq.l #1,st+1046
	move.l %d6,st+296
	move.b %d7,st+161
	move.w %d1,st+162
	jra .L2583
.L2333:
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	clr.l -(%sp)
	move.l 32(%a3),-(%sp)
	jsr enter
	mov3q.l #1,st+1038
	addq.l #1,st+1042
	jra .L2584
.L2313:
	moveq #13,%d6
	cmp.l %d2,%d6
	jcs .L2319
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L2335
	tst.b u46+48.l
	jeq .L2336
.L2335:
	or.l %d3,st+264
	addq.l #1,%d2
	move.l %d2,dp
	addq.l #1,dp+4
.L2589:
	tst.b k44+22.l
	jne .L2280
	moveq #1,%d7
	move.b %d7,k44+21
	jra .L2280
.L2336:
	move.l %d2,%d6
	add.l #-64,%d6
.L2337:
	tst.l st+4
	jeq .L2352
	cmp.l #132,%d2
	jne .L2353
	move.l st+216,%d1
	move.l %d1,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L2353
	moveq #16,%d6
	or.l %d1,%d6
	move.l %d6,st+216
	tst.l st+1058
	jne .L2354
	lea st+8,%a0
	mov3q.l #1,st+1058
	clr.l st+1062
	move.l (%a0),st+1066
	addq.l #1,st+1070
.L2354:
	moveq #1,%d0
	move.l 32(%a3),%a0
	move.b %d0,32(%a0)
	jra .L2276
.L2420:
	moveq #16,%d0
	jra .L2342
.L2340:
	addq.l #1,fk+8
	jra .L2337
.L2338:
	moveq #49,%d0
	cmp.l %d2,%d0
	jne .L2337
	move.l st+208,%d0
	or.l st+240,%d0
	or.l st+912,%d0
	move.w %d0,%ccr
	jeq .L2345
	tst.b u46+48.l
	jeq .L2346
.L2345:
	or.l st+972,%d7
	jne .L2346
	tst.l sq+408
	jeq .L2347
	tst.w sq+486.l
	jne .L2346
.L2347:
	move.l st+200,%d6
	mvz.w %d6,%d6
	tst.l %d6
	jne .L2346
	move.b 1093765506,%d1
	moveq #11,%d4
	mvz.b %d1,%d2
	cmp.l %d2,%d4
	jlt .L2348
	moveq #127,%d0
	ext.w %d1
	and.l -2147457096,%d0
	mulu.w #152,%d1
	mulu.w #2531,%d0
	move.l %d0,%a0
	add.l %d1,%a0
	add.l #1092966773,%a0
	mvz.b (%a0),%d6
.L2348:
	moveq #1,%d5
	addq.l #1,u46+24
	addq.l #1,u46+16
	move.b %d5,k44+21
	tst.b ls.l
	jeq .L2349
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
.L2349:
	clr.l u46+8
	moveq #11,%d7
	cmp.l %d2,%d7
	jlt .L2350
	move.l %d6,-(%sp)
	jsr ls_banked
	addq.l #4,%sp
	tst.l %d0
	jne .L2351
	moveq #45,%d0
	cmp.l %d6,%d0
	jeq .L2351
	moveq #43,%d1
	cmp.l %d6,%d1
	jne .L2350
.L2351:
	move.l %d6,-(%sp)
	move.l %d2,-(%sp)
	moveq #127,%d2
	jsr mr_vb
	addq.l #8,%sp
	mvz.b %d0,%d0
	cmp.l %d0,%d2
	jeq .L2350
	mov3q.l #1,%d4
	or.l st+8,%d4
	move.l %d6,u46+12
	move.l %d4,u46+8
.L2350:
	moveq #2,%d5
	swap %d5
	or.l %d5,st+204
	jra .L2276
.L2346:
	moveq #-15,%d6
	jra .L2337
.L2352:
	tst.b ls.l
	jeq .L2355
	mov3q.l #5,%d1
	cmp.l %d6,%d1
	jcs .L2356
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
	jne .L2357
	tst.l ls+36
	jne .L2358
	tst.l %d0
	jeq .L2359
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
.L2593:
	jsr (%a2)
	jra .L2579
.L2357:
	moveq #69,%d1
	cmp.l %d2,%d1
	jne .L2358
	tst.l %d0
	jeq .L2360
	move.b ls+2,%d1
	add.l #-40,%d1
	mvz.b %d1,%d1
	lsr.l #1,%d1
	jne .L2358
.L2360:
	tst.l ls+36
	jeq .L2421
.L2358:
	move.l %d0,%a0
	pea 1(%a0)
	or.l %d3,ls+32
	move.l %d2,-(%sp)
	addq.l #1,ls+88
	jsr queue_key
	jra .L2593
.L2359:
	move.l 1100949720,%a3
	move.l %a3,%d0
	clr.l ls+64
	clr.l ls+60
	add.l #-1073741824,%d0
	cmp.l #67108863,%d0
	jhi .L2362
	jsr sq_grid
	tst.l %d0
	jeq .L2362
	lea (348,%a3),%a0
	move.l (%a0),ls+60
	lea (344,%a3),%a3
	move.l (%a3),ls+64
.L2362:
	mvz.b ls+1,%d0
	lea st+8,%a0
	move.l (%a0),ls+72
	move.l %d0,ls+68
	moveq #1,%d0
.L2361:
	mov3q.l #3,%d1
	and.l %d0,%d1
	move.l %d1,-(%sp)
	jsr ls_close
	jsr (%a2)
	addq.l #4,%sp
	jra .L2280
.L2421:
	moveq #2,%d0
	jra .L2361
.L2356:
	move.l %d4,%d0
	and.l #240,%d0
	tst.l %d0
	jeq .L2355
	cmp.l #128,%d2
	jeq .L2355
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-80,%d0
	cmp.l %d0,%d1
	jcc .L2355
	add.l #-64,%d0
	moveq #11,%d7
	cmp.l %d0,%d7
	jcc .L2355
	mov3q.l #4,-(%sp)
	jsr ls_close
	addq.l #4,%sp
	tst.l st+4
	jne .L2353
.L2355:
	move.l st+972,%d0
	tst.b ls.l
	jne .L2363
	moveq #68,%d1
	cmp.l %d2,%d1
	jne .L2363
	tst.l %d0
	jne .L2364
	tst.b sv.l
	jeq .L2353
	tst.b sv+8.l
	jeq .L2353
	move.b sv+3,%d7
	jne .L2353
	move.l ls+24,%d0
	mov3q.l #4,%d6
	addq.l #2,%d0
	cmp.l %d0,%d6
	jcs .L2353
	move.b sv+1,%d1
	move.b %d1,63(%sp)
	mvz.b %d1,%d6
	mvz.b 1093765506,%d0
	cmp.l %d6,%d0
	jne .L2353
	move.b sv+2,%d6
	mvz.b %d6,%d1
	move.l %d1,-(%sp)
	move.l %d1,58(%sp)
	jsr ls_banked
	addq.l #4,%sp
	move.l 54(%sp),%d1
	tst.l %d0
	jne .L2365
	moveq #45,%d0
	cmp.l %d1,%d0
	jeq .L2365
	moveq #43,%d0
	cmp.l %d1,%d0
	jne .L2353
.L2365:
	tst.l sq+408
	jeq .L2366
	tst.w sq+486.l
	jne .L2353
.L2366:
	move.l st+216,%d0
	or.l st+920,%d0
	or.l st+248,%d0
	btst #0,%d0
	jeq .L2353
	move.b 63(%sp),%d1
	move.b %d6,ls+2
	mvz.b %d6,%d6
	moveq #45,%d2
	move.b %d1,ls+1
	cmp.l %d6,%d2
	jeq .L2423
	moveq #43,%d4
	cmp.l %d6,%d4
	jne .L2367
.L2423:
	moveq #10,%d7
.L2367:
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
	jra .L2590
.L2363:
	tst.l %d0
	jeq .L2353
	move.l %d2,%d0
	mov3q.l #2,%d1
	add.l #-80,%d0
	cmp.l %d0,%d1
	jcc .L2353
	add.l #-64,%d0
	moveq #11,%d7
	cmp.l %d0,%d7
	jcc .L2353
.L2364:
	mov3q.l #4,-(%sp)
	move.l 32(%a3),-(%sp)
	jsr splash_end
	addq.l #8,%sp
	mov3q.l #5,%d0
	cmp.l %d6,%d0
	jcs .L2353
	or.l %d3,st+272
	jra .L2280
.L2353:
	move.l st+4,%d0
	tst.l sq+408
	jeq .L2368
	tst.l %d0
	jeq .L2369
	tst.l st+1058
	jne .L2370
.L2369:
	move.l %d2,%d1
	mov3q.l #2,%d6
	add.l #-80,%d1
	cmp.l %d1,%d6
	jcs .L2371
	move.l st+920,%d1
	move.l st+248,%d7
	move.l st+208,%d6
	or.l st+216,%d1
	move.l %d7,46(%sp)
	or.l st+240,%d6
	or.l %d7,%d1
	btst #0,%d1
	jeq .L2372
	move.l sq+484,%a0
	tst.l %d0
	jeq .L2424
	move.l st+232,%a1
.L2373:
	move.l %a0,%d7
	move.l %a1,%d1
	or.l %d7,%d1
	move.l %d1,%d7
	moveq #16,%d1
	mvz.w %d7,%d7
	and.l sq+500,%d1
	or.l %d7,%d1
	jne .L2375
	tst.l %d0
	jeq .L2372
	move.l 46(%sp),%d7
	btst #4,%d7
	jne .L2375
.L2372:
	move.l %d6,%d1
	or.l st+912,%d1
	move.w %d1,%ccr
	jeq .L2377
	tst.b u46+48.l
	jeq .L2378
.L2377:
	move.l sq+484,%a0
	tst.l %d0
	jeq .L2425
	move.l st+232,%d1
.L2379:
	move.l %a0,%d7
	or.l %d7,%d1
	tst.w %d1
	jeq .L2378
.L2375:
	or.l st+912,%d6
	move.w %d6,%ccr
	jeq .L2380
	tst.b u46+48.l
	jeq .L2381
.L2380:
	addq.l #1,u46+36
.L2381:
	tst.l %d0
	jeq .L2382
	move.l st+232,%d0
.L2382:
	move.l %a0,%d1
	or.l %d1,%d0
	move.l %d0,%d1
	mvz.w %d1,%d1
	tst.w %d0
	jeq .L2383
	moveq #80,%d4
	cmp.l %d2,%d4
	jeq .L2426
	moveq #82,%d5
	cmp.l %d2,%d5
	jne .L2427
	moveq #14,%d0
.L2384:
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	mov3q.l #1,-(%sp)
	or.l %d3,st+272
	move.l %d0,-(%sp)
	jsr ed_queue
	jra .L2580
.L2424:
	sub.l %a1,%a1
	jra .L2373
.L2425:
	clr.l %d1
	jra .L2379
.L2383:
	moveq #80,%d6
	cmp.l %d2,%d6
	jeq .L2428
	moveq #82,%d7
	cmp.l %d2,%d7
	jne .L2429
	moveq #10,%d0
	jra .L2384
.L2426:
	moveq #13,%d0
	jra .L2384
.L2427:
	moveq #15,%d0
	jra .L2384
.L2428:
	moveq #9,%d0
	jra .L2384
.L2429:
	moveq #11,%d0
	jra .L2384
.L2418:
	cmp.l #132,%d2
	jne .L2385
	move.l st+216,%d0
	move.l %d0,%d1
	or.l st+920,%d1
	btst #0,%d1
	jeq .L2385
	moveq #16,%d1
	or.l %d0,%d1
	addq.l #1,ed+84
	move.l %d1,st+216
	jra .L2276
.L2386:
	move.l %d4,%d0
	and.l #240,%d0
	tst.l %d0
	jeq .L2388
	and.l #251,%d4
	cmp.l #128,%d4
	jeq .L2388
	moveq #48,%d7
	cmp.l %d2,%d7
	jne .L2389
.L2388:
	lea sq,%a0
	addq.l #1,sq+460
	cmp.l #128,%d2
	jne .L2390
	mov3q.l #1,%d0
	or.l %d0,st+920
.L2391:
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	addq.l #8,%sp
	cmp.l #128,%d2
	sne %d0
.L2594:
	mvs.b %d0,%d0
	neg.l %d0
	jra .L2274
.L2390:
	lea (121,%a6),%a6
	or.l %d3,(%a0,%a6.l*4)
	jra .L2391
.L2396:
	move.l %d2,%d0
	add.l #-66,%d0
	lsr.l #1,%d0
	jne .L2399
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L2398
	move.l masks,%d6
	cmp.l nk+20.l,%d6
	jeq .L2397
.L2398:
	cmp.l #181,%d2
	jne .L2403
	move.l st+216,%d0
	or.l st+248,%d0
	or.l st+920,%d0
	btst #0,%d0
	jeq .L2407
.L2403:
	tst.l mask_set
	jeq .L2408
	lea mask_keys,%a0
	move.l (%a0,%a6.l*4),%d0
	move.l 58(%sp),%d7
	btst %d7,%d0
	jeq .L2407
.L2408:
	cmp.l #128,%d2
	jne .L2576
	mov3q.l #2,%d4
	jra .L2409
.L2400:
	addq.l #1,nk+24
	jra .L2401
.L2430:
	mov3q.l #1,%d0
	jra .L2404
.L2577:
	move.l %d2,%d0
	mov3q.l #2,%d6
	add.l #-80,%d0
	cmp.l %d0,%d6
	jcs .L2398
.L2406:
	addq.l #1,st+944
.L2392:
	lea (50,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
	jra .L2276
.L2576:
	mov3q.l #1,%d4
.L2409:
	addq.l #1,st+936
	mov3q.l #2,%d1
	cmp.l %d4,%d1
	jne .L2411
	lea (226,%a6),%a6
	or.l %d3,(%a2,%a6.l*4)
.L2412:
	mov3q.l #1,-(%sp)
	move.l %d2,-(%sp)
	jsr queue_key
	jsr flush
	mov3q.l #2,%d2
	addq.l #8,%sp
	cmp.l %d4,%d2
	sne %d0
	jra .L2594
.L2411:
	or.l %d3,(%a2,%d5.l*4)
	jra .L2412
.L2399:
	moveq #69,%d0
	cmp.l %d2,%d0
	jne .L2577
	tst.l mask_set
	jeq .L2402
	lea mask_keys+8,%a0
	btst #5,3(%a0)
	jeq .L2403
.L2402:
	lea st+232,%a1
	clr.l %d1
	sub.l %a0,%a0
.L2405:
	tst.l (%a1)+
	jne .L2430
	tst.l 668(%a1)
	sne %d0
	mvs.b %d0,%d0
	neg.l %d0
.L2404:
	or.l %d0,%d1
	addq.l #1,%a0
	moveq #8,%d0
	cmp.l %a0,%d0
	jne .L2405
	move.l st+216,%d0
	mov3q.l #1,%d4
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d4,%d0
	or.l %d1,%d0
	jne .L2403
	moveq #32,%d5
	or.l %d5,st+240
	addq.l #1,st+936
	mov3q.l #1,nk
	jra .L2280
.L2395:
	moveq #69,%d1
	cmp.l %d2,%d1
	jeq .L2407
	add.l #-80,%d2
	mov3q.l #2,%d0
	cmp.l %d2,%d0
	jcc .L2406
.L2407:
	addq.l #1,st+940
	jra .L2392
.L2371:
	tst.l %d0
	jeq .L2418
.L2370:
	move.l %d2,%d0
	moveq #11,%d1
	add.l #-144,%d0
	cmp.l %d0,%d1
	jcs .L2393
	moveq #64,%d0
	and.l st+248,%d0
	tst.l %d0
	jeq .L2393
	move.l tk+8,%d0
	tst.l %d0
	jne .L2393
.L2394:
	lea (%a4,%d0.l),%a0
	moveq #32,%d1
	move.l (%a0),68(%sp,%d0.l)
	addq.l #4,%d0
	cmp.l %d0,%d1
	jne .L2394
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
.L2393:
	tst.l st+4
	jeq .L2392
	tst.l st+1058
	jne .L2395
	moveq #68,%d7
	cmp.l %d2,%d7
	jne .L2396
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
	move.l st+232,%d1
	mvz.w %d1,%d1
	or.l %d1,%d0
	jeq .L2403
.L2397:
	addq.l #1,st+936
	moveq #68,%d7
	cmp.l %d2,%d7
	jne .L2400
	addq.l #1,nk+12
.L2401:
	or.l %d3,st+240
	jra .L2582
.L2368:
	tst.l %d0
	jne .L2370
.L2389:
	tst.b sv.l
	jeq .L2370
	moveq #111,%d1
	cmp.l %d2,%d1
	jcc .L2392
	moveq #119,%d4
	cmp.l %d2,%d4
	jcs .L2370
	lea ram_ok,%a0
	btst #1,3(%a0)
	jeq .L2392
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
	jra .L2585
.L2378:
	tst.l %d0
	jne .L2393
.L2385:
	tst.w sq+486.l
	jeq .L2386
	move.l %d2,%d0
	mov3q.l #5,%d6
	add.l #-48,%d0
	cmp.l %d0,%d6
	jcc .L2387
	moveq #16,%d7
	cmp.l %d2,%d7
	jeq .L2387
	add.l #-20,%d0
	mov3q.l #1,%d1
	cmp.l %d0,%d1
	jcc .L2387
	add.l #-44,%d0
	lsr.l #3,%d0
	jne .L2386
.L2387:
	lea (121,%a6),%a6
	or.l %d3,(%a5,%a6.l*4)
	addq.l #1,st+1054
.L2582:
	mov3q.l #1,-(%sp)
	jra .L2581
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
	jne .L2596
	tst.l sq+408
	jeq .L2597
	tst.w sq+486.l
	jeq .L2597
	mov3q.l #7,%d0
	cmp.l %a6,%d0
	jcs .L2597
	tst.b 20(%a0)
	jne .L2625
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+920,%d0
	and.l %d1,%d0
.L2598:
	add.l %d2,96(%a2,%a6.l*4)
	move.b %d0,st+160
	addq.l #1,sq+464
	jsr flush
.L2599:
	mov3q.l #1,%d2
	jra .L2602
.L2625:
	mov3q.l #1,%d0
	jra .L2598
.L2597:
	move.l %d2,-(%sp)
	move.l %a6,-(%sp)
	jsr ls_enc
	addq.l #8,%sp
	move.l %d0,%d2
	tst.l %d0
	jne .L2602
	moveq #8,%d3
	cmp.l %a6,%d3
	jne .L2601
	tst.b sv+8.l
	jeq .L2601
	move.l st+8,%a0
	addq.l #1,st+1086
	lea (47,%a0),%a0
	move.l %a0,st+1082
.L2601:
	tst.l st+972
	jeq .L2602
	mov3q.l #5,-(%sp)
	move.l 76(%sp),%a1
	move.l 32(%a1),-(%sp)
	jsr splash_end
	addq.l #8,%sp
.L2602:
	move.l -66650100,%d0
	addq.l #1,st+336
	sub.l 44(%sp),%d0
	add.l %d0,st+328
	cmp.l st+332.l,%d0
	jls .L2595
	move.l %d0,st+332
.L2595:
	move.l %d2,%d0
	movem.l (%sp),#23804
	lea (68,%sp),%sp
	rts
.L2596:
	tst.l st+1058
	jeq .L2603
	addq.l #1,st+952
.L2604:
	clr.l %d2
	jra .L2602
.L2603:
	tst.l mask_set
	jeq .L2605
	moveq #15,%d0
	cmp.l %a6,%d0
	jcs .L2606
	move.l mask_enc,%d0
	move.l %a6,%d1
	btst %d1,%d0
	jne .L2605
.L2606:
	addq.l #1,st+952
	moveq #8,%d3
	cmp.l %a6,%d3
	jne .L2604
	move.l st+8,%a0
	addq.l #1,st+1086
	lea (47,%a0),%a0
	move.l %a0,st+1082
	jra .L2604
.L2605:
	addq.l #1,st+948
	tst.b 20(%a0)
	jne .L2626
	move.l st+216,%d0
	mov3q.l #1,%d1
	or.l st+248,%d0
	or.l st+920,%d0
	and.l %d1,%d0
.L2608:
	move.b %d0,st+160
	moveq #15,%d3
	cmp.l %a6,%d3
	jcs .L2599
	move.l %a6,%d4
	add.l #24,%d4
	add.l %d2,(%a2,%d4.l*4)
	tst.l st+64
	jne .L2610
	move.l #-66650100,%a0
	move.l (%a0),st+64
.L2610:
	tst.l st+388
	jne .L2611
	move.l #-66650100,%a1
	lea commits,%a0
	move.l (%a1),st+388
	move.l (%a0),st+392
.L2611:
	move.l %a6,%d5
	add.l #122,%d5
	lea bind_gen,%a4
	move.l (%a4,%a6.l*4),%d6
	move.l (%a2,%d5.l*4),%a3
	cmp.l %d6,%a3
	jeq .L2614
	btst #0,%d6
	jne .L2614
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
	jne .L2614
	move.l %d3,%d0
	move.l %a6,%d1
	add.l #st+552,%d0
	add.l #102,%d1
	tst.l (%a2,%d1.l*4)
	jeq .L2627
	move.l %d0,%a1
	move.b 48(%sp),%d3
	move.b (%a1),%d1
	eor.l %d1,%d3
	tst.b %d3
	seq %d3
	mvs.b %d3,%d3
	neg.l %d3
.L2616:
	mov3q.l #5,-(%sp)
	move.l %d7,-(%sp)
	move.l %d0,-(%sp)
	jsr (%a0)
	lea (12,%sp),%sp
	tst.l %d3
	jne .L2617
	lea (%a2,%a6.l),%a0
	move.b 49(%sp),472(%a0)
.L2617:
	move.l %d6,(%a2,%d5.l*4)
	move.l %d6,%a3
.L2614:
	tst.l %a3
	jeq .L2618
	move.l %a6,%d0
	moveq #20,%d3
	muls.l %d3,%d0
	lea (%a2,%d0.l),%a0
	mvz.b 552(%a0),%d1
	lsr.l #6,%d1
	jne .L2618
	lea (102,%a6),%a1
	add.l #st,%a6
	tst.l (%a2,%a1.l*4)
	jne .L2619
	move.b 553(%a0),472(%a6)
.L2619:
	move.l %d0,%a0
	add.l #st+556,%a0
	move.b (%a0),%d1
	mvz.b 472(%a6),%d3
	btst #0,%d1
	jeq .L2628
	tst.b st+160.l
	jne .L2629
.L2628:
	mov3q.l #1,%d1
.L2620:
	muls.l %d1,%d2
	move.l %d0,%a0
	add.l #st+554,%a0
	mvz.b (%a0),%d1
	add.l %d3,%d2
	cmp.l %d2,%d1
	jle .L2621
	move.l %d1,%d2
.L2621:
	move.l %d0,%a0
	add.l #st+555,%a0
	mvz.b (%a0),%d1
	cmp.l %d2,%d1
	jge .L2622
	move.l %d1,%d2
.L2622:
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
	jne .L2623
	move.l #-66650100,%a1
	move.l (%a1),st+368
.L2623:
	moveq #1,%d0
	move.l 72(%sp),%a1
	move.l 32(%a1),%a0
	move.b %d0,32(%a0)
.L2618:
	jsr flush
	tst.l (%a2,%d4.l*4)
	jne .L2599
	addq.l #1,st+384
	jra .L2599
.L2626:
	mov3q.l #1,%d0
	jra .L2608
.L2627:
	clr.l %d3
	jra .L2616
.L2629:
	moveq #8,%d1
	jra .L2620
	.size	rui_enc, .-rui_enc
	.align	2
	.globl	pj_write
	.type	pj_write, @function
pj_write:
	move.l 4(%sp),%d0
	move.l 8(%sp),%d1
	cmp.l #1074464814,%d0
	jeq .L2639
	cmp.l #1073958730,%d0
	jeq .L2639
	lea pj_push,%a0
	cmp.l #1074076072,%d0
	jne .L2641
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #5,-(%sp)
.L2654:
	jsr (%a0)
	lea (12,%sp),%sp
.L2639:
	rts
.L2641:
	cmp.l #1074076390,%d0
	jeq .L2642
	cmp.l #1074076276,%d0
	jne .L2643
.L2642:
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #3,-(%sp)
	jra .L2654
.L2643:
	cmp.l #1073959500,%d0
	jne .L2644
	mvz.b pj+137,%d0
	move.l %d1,-(%sp)
	move.l %d0,%a1
	pea -1(%a1)
	mov3q.l #2,-(%sp)
	jra .L2654
.L2644:
	move.l %d1,-(%sp)
	mov3q.l #-1,-(%sp)
	mov3q.l #7,-(%sp)
	jra .L2654
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
	jcs .L2658
	addq.l #1,%d0
.L2657:
	move.b %d0,pj+137
	rts
.L2658:
	clr.b %d0
	jra .L2657
	.size	pj_copy, .-pj_copy
	.align	2
	.globl	pj_save
	.type	pj_save, @function
pj_save:
	move.l 4(%sp),%d0
	tst.l %d0
	jlt .L2659
	move.b 1079807565,%d1
	move.l %d0,-(%sp)
	mvs.b %d1,%d1
	move.l %d1,-(%sp)
	mov3q.l #1,-(%sp)
	jsr pj_push
	lea (12,%sp),%sp
.L2659:
	rts
	.size	pj_save, .-pj_save
	.align	2
	.globl	pj_activate
	.type	pj_activate, @function
pj_activate:
	move.l 4(%sp),%d0
	tst.l %d0
	jlt .L2661
	move.l #1074457822,%d1
	cmp.l 8(%sp),%d1
	jne .L2661
	move.l #1074479198,%d1
	cmp.l 12(%sp),%d1
	jne .L2661
	move.l %d0,12(%sp)
	moveq #10,%d0
	mov3q.l #-1,8(%sp)
	move.l %d0,4(%sp)
	jra pj_push
.L2661:
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
	jge .L2664
	moveq #127,%d0
.L2665:
	move.l %d0,-(%sp)
	pea 65.w
	jsr pj_push
	lea (12,%sp),%sp
	rts
.L2664:
	tst.l %d0
	jge .L2665
	clr.l %d0
	jra .L2665
	.size	kt_saved, .-kt_saved
	.align	2
	.globl	kt_reloaded
	.type	kt_reloaded, @function
kt_reloaded:
	lea ram_ok,%a0
	btst #2,3(%a0)
	jeq .L2667
	addq.l #1,pmo+76
.L2667:
	move.l -2147457096,%d0
	moveq #127,%d1
	mov3q.l #-1,-(%sp)
	and.l %d0,%d1
	move.l %d1,-(%sp)
	move.l 12(%sp),%d0
	mvz.b %d0,%d0
	move.l %d0,-(%sp)
	jsr pj_push
	lea (12,%sp),%sp
	rts
	.size	kt_reloaded, .-kt_reloaded
	.text
	.type	CSWTCH.621, @object
	.size	CSWTCH.621, 7
CSWTCH.621:
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
	.type	CSWTCH.619, @object
	.size	CSWTCH.619, 40
CSWTCH.619:
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
	.type	CSWTCH.557, @object
	.size	CSWTCH.557, 6
CSWTCH.557:
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
	.text
	.type	ram_t_ddr, @object
	.size	ram_t_ddr, 5
ram_t_ddr:
	.string	"DDR "
	.type	ram_t_bad, @object
	.size	ram_t_bad, 6
ram_t_bad:
	.string	" BAD "
	.type	ram_t_err, @object
	.size	ram_t_err, 14
ram_t_err:
	.string	"MOD RAM ERROR"
	.local	kd_t
	.comm	kd_t,4,2
	.local	kd_over
	.comm	kd_over,4,2
	.local	kd_drop
	.comm	kd_drop,4,2
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
	.globl	dg
	.section	.bss
	.align	4
	.type	dg, @object
	.size	dg, 40
dg:
	.zero	40
	.text
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
	.section	.bss
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
	.globl	ram_test_at
	.section	.bss
	.align	2
	.type	ram_test_at, @object
	.size	ram_test_at, 4
ram_test_at:
	.zero	4
	.globl	ram_test
	.align	2
	.type	ram_test, @object
	.size	ram_test, 4
ram_test:
	.zero	4
	.globl	ram_step
	.align	2
	.type	ram_step, @object
	.size	ram_step, 4
ram_step:
	.zero	4
	.globl	ram_rep_owed
	.align	2
	.type	ram_rep_owed, @object
	.size	ram_rep_owed, 4
ram_rep_owed:
	.zero	4
	.globl	ram_drops
	.align	2
	.type	ram_drops, @object
	.size	ram_drops, 4
ram_drops:
	.zero	4
	.globl	ram_show_until
	.align	2
	.type	ram_show_until, @object
	.size	ram_show_until, 4
ram_show_until:
	.zero	4
	.globl	ram_rep_sent
	.align	2
	.type	ram_rep_sent, @object
	.size	ram_rep_sent, 4
ram_rep_sent:
	.zero	4
	.globl	ram_checks
	.align	2
	.type	ram_checks, @object
	.size	ram_checks, 4
ram_checks:
	.zero	4
	.globl	ram_init_n
	.align	2
	.type	ram_init_n, @object
	.size	ram_init_n, 4
ram_init_n:
	.zero	4
	.globl	ram_bad_word
	.align	2
	.type	ram_bad_word, @object
	.size	ram_bad_word, 4
ram_bad_word:
	.zero	4
	.globl	ram_bad_at
	.align	2
	.type	ram_bad_at, @object
	.size	ram_bad_at, 4
ram_bad_at:
	.zero	4
	.globl	ram_bad
	.align	2
	.type	ram_bad, @object
	.size	ram_bad, 4
ram_bad:
	.zero	4
	.globl	ram_ok
	.align	2
	.type	ram_ok, @object
	.size	ram_ok, 4
ram_ok:
	.zero	4
	.ident	"GCC: (GNU) 16.2.0"
