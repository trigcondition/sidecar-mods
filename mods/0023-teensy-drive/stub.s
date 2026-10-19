| Mod 0023 - the Teensy's SD card as a folder TEENSY in the file browser.
| GENERATED from teensy_drive.c by build.sh (m68k-elf-gcc -mcpu=5475 -Os, TD_SLOTS=1 and 0); edit teensy_drive.c.
	.ifne P_SLOTS
#NO_APP
	.file	"teensy_drive.c"
	.text
#APP
	  .section .td,"ax"
  .align 2
  .globl td_readdir_entry
td_readdir_entry:
  jmp td_readdir
  .globl td_readdir_stock
td_readdir_stock:
  lea %sp@(-24),%sp
  moveml %d2-%d5/%a2-%a3,%sp@
  jmp 0x4007c050
  .globl td_resolve_entry
td_resolve_entry:
  jmp td_resolve
  .globl td_resolve_stock
td_resolve_stock:
  lea %sp@(-16),%sp
  moveml %d2-%d3/%a2-%a3,%sp@
  jmp 0x400804a0
  .globl td_exists_entry
td_exists_entry:
  jmp td_exists
  .globl td_exists_stock
td_exists_stock:
  movel %d2,%sp@-
  movel %sp@(8),%d1
  jmp 0x4008076c
  .globl td_size_entry
td_size_entry:
  jmp td_size
  .globl td_size_stock
td_size_stock:
  lea %sp@(-32),%sp
  moveml %d2-%d5/%a2,%sp@
  jmp 0x400808ac
td_tname:
  lea td_teensy,%a1
1:
  moveb %a1@+,%d1
  jeq 2f
  moveb %a0@+,%d0
  oril #0x20,%d0
  oril #0x20,%d1
  cmpb %d1,%d0
  jeq 1b
3:
  moveq #0,%d0
  rts
2:
  moveb %a0@,%d0
  jeq 4f
  cmpib #47,%d0
  jne 3b
4:
  moveq #-1,%d0
  rts
  .globl td_link_entry
td_link_entry:
  moveq #2,%d0
  cmpl %sp@(4),%d0
  jne 5f
  moveal %sp@(8),%a0
  bsr td_tname
  jne 6f
5:
  lea %sp@(-56),%sp
  moveml %d2-%d7/%a2-%fp,%sp@
  jmp 0x4007b3b8
  .globl td_mkdir_entry
td_mkdir_entry:
  movel %sp@(4),%d0
  jeq 7f
  moveal %d0,%a0
  moveb %a0@+,%d0
  cmpib #47,%d0
  jne 7f
  bsr td_tname
  jeq 7f
6:
  moveq #-1,%d0
  rts
7:
  linkw %fp,#-24
  moveml %d2-%d3/%a2-%a3,%sp@
  jmp 0x4007c178
  .globl td_count_entry
td_count_entry:
  jmp td_count
  .globl td_count_stock
td_count_stock:
  movel %a2,%sp@-
  movel %d2,%sp@-
  tstl 0x41843c70
  jmp 0x40080854
  .globl td_ref_entry
td_ref_entry:
  movel %a0,%sp@-
  movel %sp@(12),%sp@-
  movel %sp@(12),%sp@-
  movel %sp@(8),%sp@-
  jsr td_ref
  lea %sp@(12),%sp
  moveal %sp@+,%a0
  tstl %d0
  jeq 1f
  movel %a0,%d0
  rts
1:
  linkw %fp,#-16
  moveal %fp@(8),%a1
  jmp 0x4007e634
  .section .td3,"ax"
  .align 2
  .globl td_path_entry
td_path_entry:
  movel %sp@(4),%d0
  andil #0xFF000000,%d0
  cmpil #0x7E000000,%d0
  jne 1f
  moveq #0,%d0
  rts
1:
  lea %sp@(-324),%sp
  moveml %d2-%d7/%a2-%fp,%sp@
  jmp 0x4007c5dc
  .globl td_check_entry
td_check_entry:
  movel %sp@(4),%d0
  jeq 1f
  moveal %d0,%a0
  movel %a0@,%d0
  andil #0xFF000000,%d0
  cmpil #0x7E000000,%d0
  jne 1f
  moveq #-1,%d0
  rts
1:
  lea %sp@(-24),%sp
  moveml %d2/%a2-%fp,%sp@
  jmp 0x4007fffc
  .globl td_mkdir_guard
td_mkdir_guard:
  movel %a4@(4),%d0
  jeq 1f
  moveal %d0,%a0
  tstb %a0@
  jne 2f
1:
  moveq #-1,%d0
  rts
2:
  jmp 0x4007c170

	  .section .td5,"ax"
  .align 2
  .globl td_load_entry
td_load_entry:
  movel %sp@(12),%d0
  andil #0x1000,%d0
  jeq 4f
  movel %sp@(12),%sp@-
  movel %sp@(12),%sp@-
  jsr td_assign
  addql #8,%sp
  rts
4:
  moveal %sp@(8),%a0
  movel %a0@,%d0
  cmpil #0x7E504F4F,%d0
  jne 2f
  moveq #1,%d0
  rts
2:
  andil #0xFF000000,%d0
  cmpil #0x7E000000,%d0
  jne 3f
  moveq #0,%d0
  rts
3:
  linkw %fp,#-28
  moveml %d2-%d4/%a2,%sp@
  jmp 0x400b7136
  .globl td_empty_stock
td_empty_stock:
  moveq #127,%d1
  movel %sp@(8),%d0
  jmp 0x400b812c
  .globl td_name_entry
td_name_entry:
  movel %a0,%sp@-
  movel %sp@(12),%sp@-
  jsr td_pool_name
  addql #4,%sp
  moveal %sp@+,%a0
  tstl %d0
  jne 1f
  jmp 0x400b80ae
1:
  subql #4,%sp
  movel %a0,%sp@-
  pea %sp@(4)
  movel %d0,%sp@-
  movel %a0,%sp@-
  jsr 0x401bcd4c
  lea %sp@(12),%sp
  movel %sp@+,%d0
  addql #4,%sp
  rts
  .globl td_browse_entry
td_browse_entry:
  jsr td_pool_ctx
  tstl %d0
  jeq 2f
  movel %sp@(8),%d0
  oril #0x1000,%d0
  movel %d0,%sp@(8)
2:
  jmp 0x400e37fe
  .globl td_slotref_entry
td_slotref_entry:
  movel %sp@(8),%d0
  andil #0x1000,%d0
  jne 3f
  jmp 0x400b7228
3:
  moveq #-1,%d0
  movel %d0,%a0@
  clrl %a0@(4)
  clrl %a0@(8)
  clrl %a0@(12)
  movel %a0,%d0
  rts
  .globl td_mark_entry
td_mark_entry:
  movel %sp@(8),%d0
  andil #0xFF800000,%d0
  cmpil #0x7E800000,%d0
  jeq 4f
  jmp 0x400b8348
4:
  jsr td_pool_ctx
  tstl %d0
  jne 5f
  moveq #-1,%d0
  rts
5:
  movel %sp@(8),%sp@-
  jsr td_mark
  addql #4,%sp
  rts

#NO_APP
	.section	.td,"ax",@progbits
	.align	2
	.type	td_name, @function
td_name:
	move.l 4(%sp),%a0
	clr.l %d0
	move.l 8(%sp),%a1
.L2:
	move.b (%a1,%d0.l),%d1
	jeq .L3
	move.b %d1,(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l #255,%d0
	jne .L2
.L3:
	clr.b %d1
	move.b %d1,(%a0,%d0.l)
	rts
	.size	td_name, .-td_name
	.align	2
	.type	td_file_size, @function
td_file_size:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	tst.b td_cache+8.l
	jne .L8
.L10:
	clr.l %d0
.L7:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L8:
	move.l td_cache+20,%a0
	tst.l %a0
	jeq .L10
	moveq #12,%d3
	move.l 12(%sp),%d1
	lsr.l %d3,%d1
	mvz.w td_cache,%d2
	and.l #1023,%d1
	cmp.l %d2,%d1
	jne .L10
	move.l 12(%sp),%d1
	mvz.w td_cache+6,%d0
	and.l #4095,%d1
	move.l %d0,%a1
	clr.l %d0
.L11:
	cmp.l %a1,%d0
	jcc .L10
	cmp.l #512,%d0
	jeq .L10
	tst.b (%a0)
	jne .L12
	mvz.w 2(%a0),%d2
	cmp.l %d2,%d1
	jne .L12
	move.l 4(%a0),%d0
	jra .L7
.L12:
	addq.l #1,%d0
	lea (32,%a0),%a0
	jra .L11
	.size	td_file_size, .-td_file_size
	.section	.td5,"ax",@progbits
	.align	2
	.type	td_alloc, @function
td_alloc:
	tst.l td_cache+20
	jeq .L18
.L21:
	mov3q.l #1,%d0
.L17:
	rts
.L18:
	pea 16384.w
	jsr 1074276820
	addq.l #4,%sp
	tst.l %d0
	jeq .L17
	move.l %d0,%d1
	move.l %d0,%a0
	add.l #16384,%d1
.L20:
	clr.l (%a0)+
	cmp.l %a0,%d1
	jne .L20
	move.l %d0,td_cache+20
	jra .L21
	.size	td_alloc, .-td_alloc
	.section	.td2,"ax",@progbits
	.align	2
	.globl	td_sysex
	.type	td_sysex, @function
td_sysex:
	lea (-28,%sp),%sp
	moveq #13,%d0
	move.l 36(%sp),%a1
	movem.l #7228,(%sp)
	move.l 32(%sp),%a0
	cmp.l %a1,%d0
	jge .L25
	mvz.b 4(%a0),%d0
	moveq #14,%d1
	cmp.l %d0,%d1
	jeq .L26
.L25:
	clr.l %d0
.L24:
	movem.l (%sp),#7228
	lea (28,%sp),%sp
	rts
.L26:
	tst.l td_cache+20
	jeq .L25
	mvz.b 5(%a0),%d0
	mvz.b 6(%a0),%d2
	mvz.w td_cache,%d1
	lsl.l #7,%d0
	or.l %d2,%d0
	cmp.l %d1,%d0
	jne .L28
	mvz.b 7(%a0),%d3
	mvz.b 9(%a0),%d1
	mvz.b 8(%a0),%d2
	mvz.b 10(%a0),%d0
	lsl.l #7,%d3
	lsl.l #7,%d1
	mvz.b 12(%a0),%d4
	or.l %d3,%d2
	or.l %d0,%d1
	mvz.b 11(%a0),%d0
	lsl.l #7,%d0
	and.l #1023,%d2
	or.l %d4,%d0
	move.w %d2,td_cache+2
	clr.b %d2
	move.b %d2,td_cache+9
	cmp.l #512,%d0
	jls .L29
	mvz.w #512,%d0
.L29:
	move.w %d0,td_cache+4
	move.l %a1,%d3
	moveq #13,%d0
	subq.l #1,%d3
.L30:
	move.l %d0,%a1
	addq.l #7,%a1
	cmp.l %a1,%d3
	jgt .L36
.L31:
	moveq #1,%d1
	move.b %d1,td_cache+8
.L28:
	mov3q.l #1,%d0
	jra .L24
.L36:
	cmp.l #511,%d1
	jhi .L31
	mvz.w %d1,%d2
	move.l td_cache+20,%a1
	moveq #14,%d5
	lsl.l #5,%d2
	add.l %d2,%a1
	move.b (%a0,%d0.l),(%a1)
	move.l %a1,%a3
	sub.l %d0,%a3
	mvz.b 1(%a0,%d0.l),%d4
	mvz.b 2(%a0,%d0.l),%d2
	lsl.l #7,%d4
	or.l %d4,%d2
	moveq #21,%d4
	move.w %d2,2(%a1)
	mvz.b 3(%a0,%d0.l),%d2
	lsl.l %d4,%d2
	mvz.b 4(%a0,%d0.l),%d4
	lsl.l %d5,%d4
	or.l %d4,%d2
	mvz.b 6(%a0,%d0.l),%d4
	or.l %d4,%d2
	mvz.b 5(%a0,%d0.l),%d4
	lsl.l #7,%d4
	or.l %d4,%d2
	move.l %d0,%d4
	addq.l #8,%d4
	move.l %d4,%a2
	move.l %d2,4(%a1)
	mvz.b 7(%a0,%d0.l),%d5
	clr.l %d2
.L32:
	cmp.l %d2,%d5
	jls .L33
	moveq #23,%d0
	cmp.l %d2,%d0
	jeq .L33
	cmp.l %d3,%a2
	jlt .L34
.L33:
	clr.b %d0
	addq.l #1,%d1
	move.b %d0,8(%a1,%d2.l)
	mvz.w td_cache+6,%d2
	move.l %d5,%d0
	add.l %d4,%d0
	cmp.l %d1,%d2
	jcc .L30
	move.w %d1,td_cache+6
	jra .L30
.L34:
	lea (%a0,%a2.l),%a4
	addq.l #1,%d2
	move.b (%a4),(%a3,%a2.l)
	addq.l #1,%a2
	jra .L32
	.size	td_sysex, .-td_sysex
	.section	.td
	.align	2
	.globl	td_resolve
	.type	td_resolve, @function
td_resolve:
	move.l 4(%sp),%d0
	move.l %d0,%d1
	and.l #-16777216,%d1
	cmp.l #2113929216,%d1
	jne .L41
	btst #23,%d0
	jeq .L43
	move.l %d0,-(%sp)
	jsr td_file_size
	addq.l #4,%sp
	move.l %d0,td_file_node+8
	move.l %d0,td_file_node+4
	move.l #td_file_node,%d0
.L40:
	rts
.L41:
	move.l %d0,4(%sp)
	jra td_resolve_stock
.L43:
	move.l #td_dir_node,%d0
	jra .L40
	.size	td_resolve, .-td_resolve
	.align	2
	.globl	td_exists
	.type	td_exists, @function
td_exists:
	move.l 4(%sp),%d0
	and.l #-16777216,%d0
	cmp.l #2113929216,%d0
	jeq .L45
	jra td_exists_stock
.L45:
	mov3q.l #1,%d0
	rts
	.size	td_exists, .-td_exists
	.align	2
	.globl	td_size
	.type	td_size, @function
td_size:
	move.l 4(%sp),%d0
	move.l %d0,%d1
	and.l #-16777216,%d1
	cmp.l #2113929216,%d1
	jne .L47
	btst #23,%d0
	jeq .L50
	move.l %d0,4(%sp)
	jra td_file_size
.L47:
	move.l %d0,4(%sp)
	jra td_size_stock
.L50:
	mov3q.l #-1,%d0
	rts
	.size	td_size, .-td_size
	.align	2
	.globl	td_count
	.type	td_count, @function
td_count:
	move.l 4(%sp),%d0
	move.l %d0,%d1
	and.l #-16777216,%d1
	cmp.l #2113929216,%d1
	jne .L52
	btst #23,%d0
	jeq .L55
	move.l %d0,4(%sp)
	jra td_file_size
.L52:
	move.l %d0,4(%sp)
	jra td_count_stock
.L55:
	mov3q.l #-1,%d0
	rts
	.size	td_count, .-td_count
	.section	.td5
	.align	2
	.globl	td_pool_ctx
	.type	td_pool_ctx, @function
td_pool_ctx:
	mvz.b 1093765506,%d0
	moveq #11,%d1
	cmp.l %d0,%d1
	jcs .L58
	move.l %d0,%a0
	add.l #-2147423744,%a0
	move.b (%a0),%d0
	moveq #45,%d1
	eor.l %d1,%d0
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
.L56:
	rts
.L58:
	clr.l %d0
	jra .L56
	.size	td_pool_ctx, .-td_pool_ctx
	.align	2
	.globl	td_usb_free
	.type	td_usb_free, @function
td_usb_free:
	move.l 4(%sp),%d0
	move.l 1094562704,%a0
.L60:
	tst.l %d0
	jgt .L62
	mov3q.l #1,%d0
.L59:
	rts
.L62:
	tst.l %a0
	jeq .L63
	move.l 52(%a0),%a0
	subq.l #1,%d0
	jra .L60
.L63:
	clr.l %d0
	jra .L59
	.size	td_usb_free, .-td_usb_free
	.align	2
	.type	td_ask, @function
td_ask:
	link.w %fp,#-8
	move.l #-260222380,%d1
	move.l %d1,-8(%fp)
	moveq #13,%d1
	mov3q.l #4,-(%sp)
	move.l 8(%fp),%d0
	move.b %d1,-4(%fp)
	move.l %d0,%d1
	lsr.l #7,%d1
	move.b %d1,-3(%fp)
	moveq #127,%d1
	and.l %d1,%d0
	move.b %d0,-2(%fp)
	moveq #-9,%d0
	move.b %d0,-1(%fp)
	jsr td_usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L64
	jsr 1073752340
	pea -8(%fp)
	pea 8.w
	jsr 1073752544
	jsr 1073752356
	addq.l #8,%sp
.L64:
	unlk %fp
	rts
	.size	td_ask, .-td_ask
	.align	2
	.type	td_start, @function
td_start:
	move.l #-65536,%d1
	move.l %d1,td_cache+4
	clr.b %d1
	move.l 4(%sp),%d0
	lea (8,%sp),%a0
	move.l (%a0),td_cache+12
	move.w %d0,td_cache
	move.l %d0,4(%sp)
	move.b %d1,td_cache+8
	jra td_ask
	.size	td_start, .-td_start
	.section	.td2
	.align	2
	.type	td_ensure, @function
td_ensure:
	lea (-12,%sp),%sp
	movem.l #1036,(%sp)
	move.l 16(%sp),%d3
	move.l 1100784300,%d2
	jsr td_alloc
	tst.l %d0
	jeq .L70
	move.b td_cache+8,%d0
	lea td_cache,%a2
	tst.b %d0
	jeq .L72
	mvz.w (%a2),%d1
	cmp.l %d1,%d3
	jne .L72
	mvz.w td_cache+6,%d1
	move.l %d1,%a0
	mvz.w td_cache+4,%d1
	cmp.l %a0,%d1
	jls .L70
.L72:
	tst.b td_cache+9.l
	jeq .L73
	move.l %d2,%d1
	sub.l td_cache+16,%d1
	cmp.l #89999,%d1
	jhi .L73
	move.l %d2,%d0
	sub.l td_cache+12,%d0
	cmp.l #1500,%d0
	jhi .L74
	mvz.w (%a2),%d0
	cmp.l %d0,%d3
	jeq .L70
.L74:
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr td_start
	addq.l #8,%sp
.L70:
	movem.l (%sp),#1036
	lea (12,%sp),%sp
	rts
.L73:
	mvz.w (%a2),%d1
	cmp.l %d1,%d3
	jne .L75
	tst.b %d0
	jne .L75
	mvz.w td_cache+4,%d0
	cmp.l #65535,%d0
	jeq .L76
.L75:
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr td_start
	addq.l #8,%sp
.L76:
	moveq #15,%d1
	sub.l td_cache+12,%d2
	divu.l %d1,%d2
.L77:
	moveq #39,%d0
	cmp.l %d2,%d0
	jcc .L79
	moveq #1,%d1
	clr.w %d0
	move.l #1100784300,%a0
	move.b %d1,td_cache+9
	move.l (%a0),td_cache+16
	move.w %d0,td_cache+4
	jra .L70
.L79:
	pea 10000.w
	jsr 1074367512
	addq.l #4,%sp
	tst.b td_cache+8.l
	jeq .L78
	mvz.w (%a2),%d0
	cmp.l %d0,%d3
	jne .L78
	mvz.w td_cache+6,%d1
	mvz.w td_cache+4,%d0
	cmp.l %d1,%d0
	jls .L70
.L78:
	addq.l #1,%d2
	jra .L77
	.size	td_ensure, .-td_ensure
	.align	2
	.type	td_serve, @function
td_serve:
	lea (-48,%sp),%sp
	movem.l #19468,(%sp)
	move.l 52(%sp),%a2
	move.l 56(%sp),%a6
	move.l 12(%a2),%d0
	move.l %d0,%d2
	move.l (%a2),%a1
	addq.l #1,%d2
	move.l %a1,%d1
	and.l #1023,%d1
	move.l %d2,12(%a2)
	tst.l %d0
	jne .L90
	moveq #1,%d3
	move.l %d1,-(%sp)
	jsr td_ensure
	move.l (%a2),%d0
	clr.l 16(%a6)
	clr.l 12(%a6)
	move.l %d0,(%a6)
	move.l %d0,8(%a6)
	move.w %d3,4(%a6)
	pea td_dot
	pea 20(%a6)
	jsr td_name
	lea (12,%sp),%sp
.L91:
	mov3q.l #1,%d0
.L89:
	movem.l (%sp),#19468
	lea (48,%sp),%sp
	rts
.L90:
	mov3q.l #1,%d2
	cmp.l %d0,%d2
	jne .L92
	tst.l %d1
	jeq .L93
	tst.b td_cache+8.l
	jne .L94
.L93:
	mov3q.l #2,%d0
.L95:
	moveq #1,%d3
	move.l %d0,(%a6)
	move.l %a1,8(%a6)
	clr.l 16(%a6)
	clr.l 12(%a6)
	move.w %d3,4(%a6)
	pea td_dotdot
	pea 20(%a6)
	jsr td_name
.L110:
	addq.l #8,%sp
	jra .L91
.L94:
	mvz.w td_cache,%d0
	cmp.l %d0,%d1
	jne .L93
	mvz.w td_cache+2,%d0
	or.l #2113929216,%d0
	jra .L95
.L92:
	tst.b td_cache+8.l
	jeq .L97
	move.l td_cache+20,%a0
	tst.l %a0
	jne .L98
.L97:
	clr.l %d0
	jra .L89
.L98:
	mvz.w td_cache,%d2
	cmp.l %d2,%d1
	jne .L97
	mvz.w td_cache+6,%d2
	subq.l #2,%d0
	cmp.l %d2,%d0
	jcc .L97
	cmp.l #511,%d0
	jhi .L97
	lsl.l #5,%d0
	lea (23,%sp),%a2
	add.l %d0,%a0
	clr.l %d0
.L99:
	move.b 8(%a0,%d0.l),%d2
	jeq .L100
	move.b %d2,(%a2,%d0.l)
	addq.l #1,%d0
	moveq #24,%d2
	cmp.l %d0,%d2
	jne .L99
.L100:
	clr.b %d3
	move.l %a6,%d2
	add.l #20,%d2
	lea td_name,%a3
	move.b %d3,23(%sp,%d0.l)
	move.w 2(%a0),%d0
	tst.b (%a0)
	jeq .L102
	and.l #1023,%d0
	or.l #2113929216,%d0
	move.l %d0,(%a6)
	moveq #1,%d0
.L111:
	move.w %d0,4(%a6)
	move.l %a1,8(%a6)
	clr.l 16(%a6)
	clr.l 12(%a6)
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	jsr (%a3)
	jra .L110
.L102:
	moveq #12,%d3
	and.l #4095,%d0
	lsl.l %d3,%d1
	or.l %d0,%d1
	clr.w %d0
	or.l #2122317824,%d1
	move.l %d1,(%a6)
	jra .L111
	.size	td_serve, .-td_serve
	.section	.td
	.align	2
	.globl	td_readdir
	.type	td_readdir, @function
td_readdir:
	subq.l #4,%sp
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	move.l 16(%sp),%a3
	move.l 20(%sp),%a2
	tst.l %a3
	jne .L113
.L115:
	mov3q.l #-1,%d0
.L112:
	move.l (%sp)+,%a2
	move.l (%sp)+,%a3
	addq.l #4,%sp
	rts
.L113:
	tst.l %a2
	jeq .L115
	move.l (%a3),%d0
	move.l %d0,%d1
	and.l #-16777216,%d1
	cmp.l #2113929216,%d1
	jne .L116
	move.l %a2,20(%sp)
	move.l %a3,16(%sp)
	move.l (%sp)+,%a2
	move.l (%sp)+,%a3
	addq.l #4,%sp
	jra td_serve
.L116:
	subq.l #2,%d0
	tst.l %d0
	jne .L117
	move.l #2122219134,%d0
	cmp.l 12(%a3),%d0
	jeq .L125
.L117:
	move.l %a2,-(%sp)
	move.l %a3,-(%sp)
	jsr td_readdir_stock
	addq.l #8,%sp
	tst.l %d0
	jne .L112
	mov3q.l #2,%d1
	cmp.l (%a3),%d1
	jne .L112
	moveq #1,%d0
	move.l #2113929216,(%a2)
	mov3q.l #2,8(%a2)
	clr.l 16(%a2)
	clr.l 12(%a2)
	move.w %d0,4(%a2)
	pea td_teensy
	pea 20(%a2)
	jsr td_name
	addq.l #8,%sp
	move.l #2122219134,%d1
	move.l %d1,12(%a3)
	move.l 1100784300,%a2
	tst.b td_cache+9.l
	jeq .L120
	move.l %a2,%d0
	sub.l td_cache+16,%d0
	cmp.l #89999,%d0
	jls .L121
.L120:
	jsr td_alloc
	tst.l %d0
	jne .L122
.L121:
	mov3q.l #1,%d0
	jra .L112
.L122:
	tst.w td_cache.l
	jne .L123
	tst.b td_cache+8.l
	jne .L112
	move.l %a2,%d1
	sub.l td_cache+12,%d1
	cmp.l #599,%d1
	jls .L112
.L123:
	move.l %a2,-(%sp)
	clr.l -(%sp)
	move.l %d0,16(%sp)
	jsr td_start
	addq.l #8,%sp
	move.l 8(%sp),%d0
	jra .L112
.L125:
	clr.l %d0
	jra .L112
	.size	td_readdir, .-td_readdir
	.section	.td4,"ax",@progbits
	.align	2
	.type	td_project, @function
td_project:
	moveq #16,%d1
	link.w %fp,#-28
	move.l #-260222380,%d0
	move.l %d0,-22(%fp)
	mov3q.l #5,-28(%fp)
	move.b %d1,-18(%fp)
.L130:
	move.l -28(%fp),%a0
	add.l #1081903566,%a0
	tst.b (%a0)
	jeq .L131
	move.b (%a0),%d0
	moveq #127,%d1
	addq.l #1,-28(%fp)
	move.l -28(%fp),%a0
	and.l %d1,%d0
	move.b %d0,-23(%a0,%fp.l)
	moveq #20,%d0
	cmp.l %a0,%d0
	jne .L130
.L131:
	moveq #-9,%d1
	move.l -28(%fp),%a0
	move.b %d1,-22(%fp,%a0.l)
	mov3q.l #4,-(%sp)
	jsr td_usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L129
	jsr 1073752340
	pea -22(%fp)
	move.l -28(%fp),%a0
	pea 1(%a0)
	jsr 1073752544
	jsr 1073752356
	addq.l #8,%sp
.L129:
	unlk %fp
	rts
	.size	td_project, .-td_project
	.section	.td5
	.align	2
	.globl	td_ref
	.type	td_ref, @function
td_ref:
	link.w %fp,#-36
	move.l 16(%fp),%d0
	movem.l #1084,(%sp)
	move.l 8(%fp),%a2
	move.l 12(%fp),%a1
	tst.l %d0
	jge .L141
.L143:
	clr.l -16(%fp)
.L140:
	movem.l -36(%fp),#1084
	move.l -16(%fp),%d0
	unlk %fp
	rts
.L141:
	lsl.l #3,%d0
	move.l 260(%a1),%a0
	add.l %d0,%a0
	cmp.l 264(%a1),%a0
	jcc .L143
	move.l (%a0),%a0
	tst.l %a0
	jeq .L143
	move.l (%a0),%d2
	move.l %d2,%d0
	and.l #-8388608,%d0
	cmp.l #2122317824,%d0
	jne .L143
	mov3q.l #4,-(%sp)
	jsr td_usb_free
	addq.l #4,%sp
	move.l %d0,-16(%fp)
	tst.l %d0
	jeq .L140
	moveq #12,%d0
	move.l %d2,%d3
	lsr.l %d0,%d3
	jsr td_project
	move.l %d2,%d4
	and.l #4095,%d4
	move.l %d3,%d5
	move.l #-260222380,%d0
	move.l %d0,-10(%fp)
	moveq #15,%d0
	and.l #1023,%d5
	lsr.l #7,%d4
	move.b %d0,-6(%fp)
	moveq #127,%d0
	lsr.l #7,%d5
	and.l %d0,%d3
	and.l %d2,%d0
	move.b %d4,-3(%fp)
	move.b %d5,-5(%fp)
	move.b %d3,-4(%fp)
	move.b %d0,-2(%fp)
	moveq #-9,%d0
	move.b %d0,-1(%fp)
	jsr 1073752340
	pea -10(%fp)
	pea 10.w
	jsr 1073752544
	jsr 1073752356
	move.l #2119192399,(%a2)
	move.l %d2,4(%a2)
	clr.l 12(%a2)
	clr.l 8(%a2)
	addq.l #8,%sp
	jra .L140
	.size	td_ref, .-td_ref
	.align	2
	.type	td_send, @function
td_send:
	subq.l #8,%sp
	move.l 12(%sp),(%sp)
	move.l 16(%sp),4(%sp)
	mov3q.l #4,-(%sp)
	jsr td_usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L151
	jsr 1073752340
	move.l (%sp),-(%sp)
	move.l 8(%sp),-(%sp)
	jsr 1073752544
	lea (16,%sp),%sp
	jmp 1073752356
.L151:
	addq.l #8,%sp
	rts
	.size	td_send, .-td_send
	.align	2
	.globl	td_pool_tab
	.type	td_pool_tab, @function
td_pool_tab:
	subq.l #4,%sp
	move.l %d2,-(%sp)
	tst.l td_pool
	jne .L154
	pea 2304.w
	jsr 1074276820
	addq.l #4,%sp
	tst.l %d0
	jeq .L153
	move.l %d0,%d1
	move.l %d0,%a0
	add.l #2304,%d1
.L156:
	clr.l (%a0)+
	cmp.l %a0,%d1
	jne .L156
	move.l %d0,td_pool
.L154:
	move.l #1081903571,%a0
	mov3q.l #1,%d1
	lea td_pool-1081903563,%a1
.L157:
	move.b (%a0),7(%sp)
	addq.l #1,%a0
	move.b -1(%a0,%a1.l),%d0
	move.b 7(%sp),%d2
	eor.l %d2,%d0
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
	and.l %d0,%d1
	cmp.l #1081903587,%a0
	jne .L157
	tst.l %d1
	jne .L158
	clr.b %d0
	move.b %d0,td_pool+4
.L159:
	move.b td_pool+5,%d0
	jeq .L162
	subq.l #1,%d0
	move.b %d0,td_pool+5
	jra .L160
.L158:
	tst.b td_pool+4.l
	jeq .L159
.L160:
	move.l td_pool,%d0
.L153:
	move.l (%sp)+,%d2
	addq.l #4,%sp
	rts
.L162:
	move.l #1081903571,%a0
.L161:
	move.b (%a0),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L161
	moveq #-56,%d2
	move.b %d2,td_pool+5
	jsr td_project
	mov3q.l #6,-(%sp)
	pea (ask.0)
	jsr td_send
	addq.l #8,%sp
	jra .L160
	.size	td_pool_tab, .-td_pool_tab
	.align	2
	.globl	td_pool_sysex
	.type	td_pool_sysex, @function
td_pool_sysex:
	lea (-24,%sp),%sp
	mov3q.l #7,%d0
	move.l 32(%sp),%d1
	movem.l #1148,(%sp)
	move.l 28(%sp),%a0
	cmp.l %d1,%d0
	jge .L182
	move.l td_pool,%d2
	tst.l %d2
	jeq .L182
	tst.b 5(%a0)
	jeq .L172
	move.l %d2,%a1
	move.l %d2,%d0
	addq.l #4,%a1
	add.l #2308,%d0
.L173:
	clr.b (%a1)
	lea (18,%a1),%a1
	cmp.l %a1,%d0
	jne .L173
	moveq #1,%d6
	move.b %d6,td_pool+4
.L172:
	mvz.b 6(%a0),%d5
	addq.l #7,%a0
	moveq #12,%d3
	clr.l %d4
	subq.l #1,%d1
.L174:
	cmp.l %d4,%d5
	jle .L182
	move.l %d3,%d0
	add.l #12,%d0
	cmp.l %d1,%d0
	jlt .L179
.L182:
	movem.l (%sp),#1148
	mov3q.l #1,%d0
	lea (24,%sp),%sp
	rts
.L179:
	move.b (%a0),%d0
	jle .L175
	ext.w %d0
	move.l %d2,%a2
	sub.l %a1,%a1
	mulu.w #18,%d0
	add.l %d0,%a2
	mvz.b 1(%a0),%d0
	lsl.l #7,%d0
	move.l %d0,%d6
	mvz.b 2(%a0),%d0
	or.l %d6,%d0
	move.w %d0,(%a2)
	mvz.b 3(%a0),%d0
	lsl.l #7,%d0
	move.l %d0,%d6
	mvz.b 4(%a0),%d0
	or.l %d6,%d0
	move.w %d0,2(%a2)
.L176:
	move.b 5(%a0,%a1.l),%d0
	jeq .L177
	move.b %d0,4(%a2,%a1.l)
	addq.l #1,%a1
	moveq #13,%d0
	cmp.l %a1,%d0
	jne .L176
.L177:
	clr.b %d6
	move.b %d6,4(%a2,%a1.l)
	tst.l %a1
	jne .L175
	move.w #16128,%d0
	move.w %d0,4(%a2)
.L175:
	addq.l #1,%d4
	lea (18,%a0),%a0
	add.l #18,%d3
	jra .L174
	.size	td_pool_sysex, .-td_pool_sysex
	.align	2
	.globl	td_hook
	.type	td_hook, @function
td_hook:
	move.l 4(%sp),%a0
	moveq #20,%d1
	mvz.b 4(%a0),%d0
	move.l %a0,4(%sp)
	cmp.l %d0,%d1
	jne .L189
	jra td_pool_sysex
.L189:
	jra td_sysex
	.size	td_hook, .-td_hook
	.align	2
	.globl	td_empty
	.type	td_empty, @function
td_empty:
	subq.l #4,%sp
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 20(%sp),%d2
	move.l 16(%sp),8(%sp)
	jsr td_pool_ctx
	move.l %d0,%d3
	tst.l %d0
	jne .L191
	move.l %d2,20(%sp)
	move.l 8(%sp),16(%sp)
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	addq.l #4,%sp
	jra td_empty_stock
.L191:
	tst.l %d2
	jeq .L192
	moveq #127,%d0
	cmp.l %d2,%d0
	jcc .L193
.L194:
	move.l %d3,%d2
.L192:
	move.l %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	addq.l #4,%sp
	rts
.L193:
	jsr td_pool_tab
	tst.l %d0
	jeq .L194
	moveq #18,%d1
	muls.l %d1,%d2
	move.l %d0,%a0
	tst.b 4(%a0,%d2.l)
	seq %d2
	mvs.b %d2,%d2
	neg.l %d2
	jra .L192
	.size	td_empty, .-td_empty
	.align	2
	.globl	td_pool_name
	.type	td_pool_name, @function
td_pool_name:
	move.l %d2,-(%sp)
	moveq #126,%d1
	move.l 8(%sp),%d0
	subq.l #1,%d0
	cmp.l %d0,%d1
	jcc .L202
.L204:
	clr.l %d0
.L201:
	move.l (%sp)+,%d2
	rts
.L202:
	jsr td_pool_ctx
	tst.l %d0
	jeq .L204
	jsr td_pool_tab
	tst.l %d0
	jeq .L201
	move.l 8(%sp),%d1
	moveq #18,%d2
	muls.l %d2,%d1
	add.l %d1,%d0
	move.l %d0,%a0
	tst.b 4(%a0)
	jeq .L204
	addq.l #4,%d0
	jra .L201
	.size	td_pool_name, .-td_pool_name
	.align	2
	.globl	td_mark
	.type	td_mark, @function
td_mark:
	move.l td_pool,%a0
	move.l %d2,-(%sp)
	tst.l %a0
	jne .L212
.L216:
	mov3q.l #-1,%d0
.L211:
	move.l (%sp)+,%d2
	rts
.L212:
	moveq #12,%d2
	mov3q.l #1,%d0
	move.l 8(%sp),%d1
	lsr.l %d2,%d1
	lea (18,%a0),%a0
	and.l #1023,%d1
	move.l %d1,%a1
	move.l 8(%sp),%d1
	and.l #4095,%d1
.L215:
	tst.b 4(%a0)
	jeq .L214
	mvz.w (%a0),%d2
	cmp.l %d2,%a1
	jne .L214
	mvz.w 2(%a0),%d2
	cmp.l %d2,%d1
	jeq .L211
.L214:
	addq.l #1,%d0
	lea (18,%a0),%a0
	cmp.l #128,%d0
	jne .L215
	jra .L216
	.size	td_mark, .-td_mark
	.align	2
	.globl	td_assign
	.type	td_assign, @function
td_assign:
	link.w %fp,#-32
	move.l 8(%fp),%a0
	movem.l #60,(%sp)
	tst.l %a0
	jeq .L219
	move.l (%a0),%d2
	move.l %d2,%d0
	and.l #-8388608,%d0
	cmp.l #2122317824,%d0
	jeq .L220
.L219:
	clr.l %d0
.L218:
	movem.l -32(%fp),#60
	unlk %fp
	rts
.L220:
	moveq #127,%d1
	and.l 12(%fp),%d1
	move.l %d1,-16(%fp)
	tst.l %d1
	jeq .L219
	moveq #12,%d0
	move.l %d2,%d3
	lsr.l %d0,%d3
	jsr td_project
	move.l %d2,%d4
	moveq #18,%d0
	move.l %d3,%d5
	move.l #-260222380,%d1
	move.l %d1,-11(%fp)
	moveq #127,%d1
	and.l %d1,%d2
	and.l #1023,%d5
	and.l #4095,%d4
	pea 11.w
	and.l %d1,%d3
	pea -11(%fp)
	move.b %d0,-7(%fp)
	move.b -13(%fp),-6(%fp)
	move.b %d2,-2(%fp)
	moveq #-9,%d2
	move.l %d5,%d0
	lsr.l #7,%d0
	move.b %d3,-4(%fp)
	move.b %d0,-5(%fp)
	move.l %d4,%d0
	lsr.l #7,%d0
	move.b %d2,-1(%fp)
	move.b %d0,-3(%fp)
	jsr td_send
	jsr td_pool_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L222
	move.w -14(%fp),%d1
	move.l %d0,%a0
	move.w #16128,%d0
	mulu.w #18,%d1
	add.l %d1,%a0
	move.w %d5,(%a0)
	move.w %d4,2(%a0)
	move.w %d0,4(%a0)
	tst.b td_cache+8.l
	jne .L223
.L222:
	mov3q.l #1,%d0
	jra .L218
.L223:
	move.l td_cache+20,%a1
	tst.l %a1
	jeq .L222
	mvz.w td_cache,%d0
	cmp.l %d0,%d5
	jne .L222
	mvz.w td_cache+6,%d0
	clr.l %d1
.L224:
	cmp.l %d0,%d1
	jcc .L222
	cmp.l #512,%d1
	jeq .L222
	tst.b (%a1)
	jne .L225
	mvz.w 2(%a1),%d2
	cmp.l %d2,%d4
	jne .L225
	mvz.w %d1,%d1
	clr.l %d0
	lsl.l #5,%d1
.L226:
	move.l td_cache+20,%a1
	add.l %d0,%a1
	move.b 8(%a1,%d1.l),%d2
	jeq .L227
	move.b %d2,4(%a0,%d0.l)
	addq.l #1,%d0
	moveq #13,%d2
	cmp.l %d0,%d2
	jne .L226
.L227:
	clr.b %d1
	move.b %d1,4(%a0,%d0.l)
	jra .L222
.L225:
	addq.l #1,%d1
	lea (32,%a1),%a1
	jra .L224
	.size	td_assign, .-td_assign
	.section	.tdd,"a"
	.type	ask.0, @object
	.size	ask.0, 6
ask.0:
	.base64	"8H1SVBP3"
	.globl	td_pool
	.section	.td6,"aw"
	.align	2
	.type	td_pool, @object
	.size	td_pool, 24
td_pool:
	.zero	24
	.globl	td_file_node
	.section	.tdn,"aw"
	.align	2
	.type	td_file_node, @object
	.size	td_file_node, 128
td_file_node:
	.byte	0
	.byte	3
	.word	0
	.long	0
	.long	0
	.long	1
	.zero	2
	.zero	110
	.globl	td_dir_node
	.align	2
	.type	td_dir_node, @object
	.size	td_dir_node, 128
td_dir_node:
	.byte	1
	.byte	1
	.word	0
	.long	0
	.long	0
	.long	0
	.zero	2
	.zero	110
	.section	.tdd
	.type	td_teensy, @object
	.size	td_teensy, 8
td_teensy:
	.string	"SIDECAR"
	.type	td_dotdot, @object
	.size	td_dotdot, 3
td_dotdot:
	.string	".."
	.type	td_dot, @object
	.size	td_dot, 2
td_dot:
	.string	"."
	.globl	td_cache
	.section	.tds,"aw"
	.align	2
	.type	td_cache, @object
	.size	td_cache, 24
td_cache:
	.zero	24
	.globl	td_mailbox
	.section	.tdm,"aw"
	.align	2
	.type	td_mailbox, @object
	.size	td_mailbox, 12
td_mailbox:
	.long	1413763670
	.long	td_hook
	.long	td_pool_tab
	.ident	"GCC: (GNU) 16.2.0"
	.else
#NO_APP
	.file	"teensy_drive.c"
	.text
#APP
	  .section .td,"ax"
  .align 2
  .globl td_readdir_entry
td_readdir_entry:
  jmp td_readdir
  .globl td_readdir_stock
td_readdir_stock:
  lea %sp@(-24),%sp
  moveml %d2-%d5/%a2-%a3,%sp@
  jmp 0x4007c050
  .globl td_resolve_entry
td_resolve_entry:
  jmp td_resolve
  .globl td_resolve_stock
td_resolve_stock:
  lea %sp@(-16),%sp
  moveml %d2-%d3/%a2-%a3,%sp@
  jmp 0x400804a0
  .globl td_exists_entry
td_exists_entry:
  jmp td_exists
  .globl td_exists_stock
td_exists_stock:
  movel %d2,%sp@-
  movel %sp@(8),%d1
  jmp 0x4008076c
  .globl td_size_entry
td_size_entry:
  jmp td_size
  .globl td_size_stock
td_size_stock:
  lea %sp@(-32),%sp
  moveml %d2-%d5/%a2,%sp@
  jmp 0x400808ac
td_tname:
  lea td_teensy,%a1
1:
  moveb %a1@+,%d1
  jeq 2f
  moveb %a0@+,%d0
  oril #0x20,%d0
  oril #0x20,%d1
  cmpb %d1,%d0
  jeq 1b
3:
  moveq #0,%d0
  rts
2:
  moveb %a0@,%d0
  jeq 4f
  cmpib #47,%d0
  jne 3b
4:
  moveq #-1,%d0
  rts
  .globl td_link_entry
td_link_entry:
  moveq #2,%d0
  cmpl %sp@(4),%d0
  jne 5f
  moveal %sp@(8),%a0
  bsr td_tname
  jne 6f
5:
  lea %sp@(-56),%sp
  moveml %d2-%d7/%a2-%fp,%sp@
  jmp 0x4007b3b8
  .globl td_mkdir_entry
td_mkdir_entry:
  movel %sp@(4),%d0
  jeq 7f
  moveal %d0,%a0
  moveb %a0@+,%d0
  cmpib #47,%d0
  jne 7f
  bsr td_tname
  jeq 7f
6:
  moveq #-1,%d0
  rts
7:
  linkw %fp,#-24
  moveml %d2-%d3/%a2-%a3,%sp@
  jmp 0x4007c178
  .globl td_count_entry
td_count_entry:
  jmp td_count
  .globl td_count_stock
td_count_stock:
  movel %a2,%sp@-
  movel %d2,%sp@-
  tstl 0x41843c70
  jmp 0x40080854
  .globl td_ref_entry
td_ref_entry:
  movel %a0,%sp@-
  movel %sp@(12),%sp@-
  movel %sp@(12),%sp@-
  movel %sp@(8),%sp@-
  jsr td_ref
  lea %sp@(12),%sp
  moveal %sp@+,%a0
  tstl %d0
  jeq 1f
  movel %a0,%d0
  rts
1:
  linkw %fp,#-16
  moveal %fp@(8),%a1
  jmp 0x4007e634
  .section .td3,"ax"
  .align 2
  .globl td_path_entry
td_path_entry:
  movel %sp@(4),%d0
  andil #0xFF000000,%d0
  cmpil #0x7E000000,%d0
  jne 1f
  moveq #0,%d0
  rts
1:
  lea %sp@(-324),%sp
  moveml %d2-%d7/%a2-%fp,%sp@
  jmp 0x4007c5dc
  .globl td_check_entry
td_check_entry:
  movel %sp@(4),%d0
  jeq 1f
  moveal %d0,%a0
  movel %a0@,%d0
  andil #0xFF000000,%d0
  cmpil #0x7E000000,%d0
  jne 1f
  moveq #-1,%d0
  rts
1:
  lea %sp@(-24),%sp
  moveml %d2/%a2-%fp,%sp@
  jmp 0x4007fffc
  .globl td_mkdir_guard
td_mkdir_guard:
  movel %a4@(4),%d0
  jeq 1f
  moveal %d0,%a0
  tstb %a0@
  jne 2f
1:
  moveq #-1,%d0
  rts
2:
  jmp 0x4007c170

	  .section .td5,"ax"
  .align 2
  .globl td_load_entry
td_load_entry:
  movel %sp@(12),%d0
  andil #0x1000,%d0
  jeq 4f
  movel %sp@(12),%sp@-
  movel %sp@(12),%sp@-
  jsr td_assign
  addql #8,%sp
  rts
4:
  moveal %sp@(8),%a0
  movel %a0@,%d0
  cmpil #0x7E504F4F,%d0
  jne 2f
  moveq #1,%d0
  rts
2:
  andil #0xFF000000,%d0
  cmpil #0x7E000000,%d0
  jne 3f
  moveq #0,%d0
  rts
3:
  linkw %fp,#-28
  moveml %d2-%d4/%a2,%sp@
  jmp 0x400b7136
  .globl td_empty_stock
td_empty_stock:
  moveq #127,%d1
  movel %sp@(8),%d0
  jmp 0x400b812c
  .globl td_name_entry
td_name_entry:
  movel %a0,%sp@-
  movel %sp@(12),%sp@-
  jsr td_pool_name
  addql #4,%sp
  moveal %sp@+,%a0
  tstl %d0
  jne 1f
  jmp 0x400b80ae
1:
  subql #4,%sp
  movel %a0,%sp@-
  pea %sp@(4)
  movel %d0,%sp@-
  movel %a0,%sp@-
  jsr 0x401bcd4c
  lea %sp@(12),%sp
  movel %sp@+,%d0
  addql #4,%sp
  rts
  .globl td_browse_entry
td_browse_entry:
  jsr td_pool_ctx
  tstl %d0
  jeq 2f
  movel %sp@(8),%d0
  oril #0x1000,%d0
  movel %d0,%sp@(8)
2:
  jmp 0x400e37fe
  .globl td_slotref_entry
td_slotref_entry:
  movel %sp@(8),%d0
  andil #0x1000,%d0
  jne 3f
  jmp 0x400b7228
3:
  moveq #-1,%d0
  movel %d0,%a0@
  clrl %a0@(4)
  clrl %a0@(8)
  clrl %a0@(12)
  movel %a0,%d0
  rts
  .globl td_mark_entry
td_mark_entry:
  movel %sp@(8),%d0
  andil #0xFF800000,%d0
  cmpil #0x7E800000,%d0
  jeq 4f
  jmp 0x400b8348
4:
  jsr td_pool_ctx
  tstl %d0
  jne 5f
  moveq #-1,%d0
  rts
5:
  movel %sp@(8),%sp@-
  jsr td_mark
  addql #4,%sp
  rts

#NO_APP
	.section	.td,"ax",@progbits
	.align	2
	.type	td_name, @function
td_name:
	move.l 4(%sp),%a0
	clr.l %d0
	move.l 8(%sp),%a1
.L2:
	move.b (%a1,%d0.l),%d1
	jeq .L3
	move.b %d1,(%a0,%d0.l)
	addq.l #1,%d0
	cmp.l #255,%d0
	jne .L2
.L3:
	clr.b %d1
	move.b %d1,(%a0,%d0.l)
	rts
	.size	td_name, .-td_name
	.align	2
	.type	td_file_size, @function
td_file_size:
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	tst.b td_cache+8.l
	jne .L8
.L10:
	clr.l %d0
.L7:
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	rts
.L8:
	move.l td_cache+20,%a0
	tst.l %a0
	jeq .L10
	moveq #12,%d3
	move.l 12(%sp),%d1
	lsr.l %d3,%d1
	mvz.w td_cache,%d2
	and.l #1023,%d1
	cmp.l %d2,%d1
	jne .L10
	move.l 12(%sp),%d1
	mvz.w td_cache+6,%d0
	and.l #4095,%d1
	move.l %d0,%a1
	clr.l %d0
.L11:
	cmp.l %a1,%d0
	jcc .L10
	cmp.l #512,%d0
	jeq .L10
	tst.b (%a0)
	jne .L12
	mvz.w 2(%a0),%d2
	cmp.l %d2,%d1
	jne .L12
	move.l 4(%a0),%d0
	jra .L7
.L12:
	addq.l #1,%d0
	lea (32,%a0),%a0
	jra .L11
	.size	td_file_size, .-td_file_size
	.section	.td5,"ax",@progbits
	.align	2
	.type	td_alloc, @function
td_alloc:
	tst.l td_cache+20
	jeq .L18
.L21:
	mov3q.l #1,%d0
.L17:
	rts
.L18:
	pea 16384.w
	jsr 1074276820
	addq.l #4,%sp
	tst.l %d0
	jeq .L17
	move.l %d0,%d1
	move.l %d0,%a0
	add.l #16384,%d1
.L20:
	clr.l (%a0)+
	cmp.l %a0,%d1
	jne .L20
	move.l %d0,td_cache+20
	jra .L21
	.size	td_alloc, .-td_alloc
	.section	.td2,"ax",@progbits
	.align	2
	.globl	td_sysex
	.type	td_sysex, @function
td_sysex:
	lea (-28,%sp),%sp
	moveq #13,%d0
	move.l 36(%sp),%a1
	movem.l #7228,(%sp)
	move.l 32(%sp),%a0
	cmp.l %a1,%d0
	jge .L25
	mvz.b 4(%a0),%d0
	moveq #14,%d1
	cmp.l %d0,%d1
	jeq .L26
.L25:
	clr.l %d0
.L24:
	movem.l (%sp),#7228
	lea (28,%sp),%sp
	rts
.L26:
	tst.l td_cache+20
	jeq .L25
	mvz.b 5(%a0),%d0
	mvz.b 6(%a0),%d2
	mvz.w td_cache,%d1
	lsl.l #7,%d0
	or.l %d2,%d0
	cmp.l %d1,%d0
	jne .L28
	mvz.b 7(%a0),%d3
	mvz.b 9(%a0),%d1
	mvz.b 8(%a0),%d2
	mvz.b 10(%a0),%d0
	lsl.l #7,%d3
	lsl.l #7,%d1
	mvz.b 12(%a0),%d4
	or.l %d3,%d2
	or.l %d0,%d1
	mvz.b 11(%a0),%d0
	lsl.l #7,%d0
	and.l #1023,%d2
	or.l %d4,%d0
	move.w %d2,td_cache+2
	clr.b %d2
	move.b %d2,td_cache+9
	cmp.l #512,%d0
	jls .L29
	mvz.w #512,%d0
.L29:
	move.w %d0,td_cache+4
	move.l %a1,%d3
	moveq #13,%d0
	subq.l #1,%d3
.L30:
	move.l %d0,%a1
	addq.l #7,%a1
	cmp.l %a1,%d3
	jgt .L36
.L31:
	moveq #1,%d1
	move.b %d1,td_cache+8
.L28:
	mov3q.l #1,%d0
	jra .L24
.L36:
	cmp.l #511,%d1
	jhi .L31
	mvz.w %d1,%d2
	move.l td_cache+20,%a1
	moveq #14,%d5
	lsl.l #5,%d2
	add.l %d2,%a1
	move.b (%a0,%d0.l),(%a1)
	move.l %a1,%a3
	sub.l %d0,%a3
	mvz.b 1(%a0,%d0.l),%d4
	mvz.b 2(%a0,%d0.l),%d2
	lsl.l #7,%d4
	or.l %d4,%d2
	moveq #21,%d4
	move.w %d2,2(%a1)
	mvz.b 3(%a0,%d0.l),%d2
	lsl.l %d4,%d2
	mvz.b 4(%a0,%d0.l),%d4
	lsl.l %d5,%d4
	or.l %d4,%d2
	mvz.b 6(%a0,%d0.l),%d4
	or.l %d4,%d2
	mvz.b 5(%a0,%d0.l),%d4
	lsl.l #7,%d4
	or.l %d4,%d2
	move.l %d0,%d4
	addq.l #8,%d4
	move.l %d4,%a2
	move.l %d2,4(%a1)
	mvz.b 7(%a0,%d0.l),%d5
	clr.l %d2
.L32:
	cmp.l %d2,%d5
	jls .L33
	moveq #23,%d0
	cmp.l %d2,%d0
	jeq .L33
	cmp.l %d3,%a2
	jlt .L34
.L33:
	clr.b %d0
	addq.l #1,%d1
	move.b %d0,8(%a1,%d2.l)
	mvz.w td_cache+6,%d2
	move.l %d5,%d0
	add.l %d4,%d0
	cmp.l %d1,%d2
	jcc .L30
	move.w %d1,td_cache+6
	jra .L30
.L34:
	lea (%a0,%a2.l),%a4
	addq.l #1,%d2
	move.b (%a4),(%a3,%a2.l)
	addq.l #1,%a2
	jra .L32
	.size	td_sysex, .-td_sysex
	.section	.td
	.align	2
	.globl	td_resolve
	.type	td_resolve, @function
td_resolve:
	move.l 4(%sp),%d0
	move.l %d0,%d1
	and.l #-16777216,%d1
	cmp.l #2113929216,%d1
	jne .L41
	btst #23,%d0
	jeq .L43
	move.l %d0,-(%sp)
	jsr td_file_size
	addq.l #4,%sp
	move.l %d0,td_file_node+8
	move.l %d0,td_file_node+4
	move.l #td_file_node,%d0
.L40:
	rts
.L41:
	move.l %d0,4(%sp)
	jra td_resolve_stock
.L43:
	move.l #td_dir_node,%d0
	jra .L40
	.size	td_resolve, .-td_resolve
	.align	2
	.globl	td_exists
	.type	td_exists, @function
td_exists:
	move.l 4(%sp),%d0
	and.l #-16777216,%d0
	cmp.l #2113929216,%d0
	jeq .L45
	jra td_exists_stock
.L45:
	mov3q.l #1,%d0
	rts
	.size	td_exists, .-td_exists
	.align	2
	.globl	td_size
	.type	td_size, @function
td_size:
	move.l 4(%sp),%d0
	move.l %d0,%d1
	and.l #-16777216,%d1
	cmp.l #2113929216,%d1
	jne .L47
	btst #23,%d0
	jeq .L50
	move.l %d0,4(%sp)
	jra td_file_size
.L47:
	move.l %d0,4(%sp)
	jra td_size_stock
.L50:
	mov3q.l #-1,%d0
	rts
	.size	td_size, .-td_size
	.align	2
	.globl	td_count
	.type	td_count, @function
td_count:
	move.l 4(%sp),%d0
	move.l %d0,%d1
	and.l #-16777216,%d1
	cmp.l #2113929216,%d1
	jne .L52
	btst #23,%d0
	jeq .L55
	move.l %d0,4(%sp)
	jra td_file_size
.L52:
	move.l %d0,4(%sp)
	jra td_count_stock
.L55:
	mov3q.l #-1,%d0
	rts
	.size	td_count, .-td_count
	.section	.td5
	.align	2
	.globl	td_pool_ctx
	.type	td_pool_ctx, @function
td_pool_ctx:
	mvz.b 1093765506,%d0
	moveq #11,%d1
	cmp.l %d0,%d1
	jcs .L58
	move.l %d0,%a0
	add.l #-2147423744,%a0
	move.b (%a0),%d0
	moveq #45,%d1
	eor.l %d1,%d0
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
.L56:
	rts
.L58:
	clr.l %d0
	jra .L56
	.size	td_pool_ctx, .-td_pool_ctx
	.align	2
	.globl	td_usb_free
	.type	td_usb_free, @function
td_usb_free:
	move.l 4(%sp),%d0
	move.l 1094562704,%a0
.L60:
	tst.l %d0
	jgt .L62
	mov3q.l #1,%d0
.L59:
	rts
.L62:
	tst.l %a0
	jeq .L63
	move.l 52(%a0),%a0
	subq.l #1,%d0
	jra .L60
.L63:
	clr.l %d0
	jra .L59
	.size	td_usb_free, .-td_usb_free
	.align	2
	.type	td_ask, @function
td_ask:
	link.w %fp,#-8
	move.l #-260222380,%d1
	move.l %d1,-8(%fp)
	moveq #13,%d1
	mov3q.l #4,-(%sp)
	move.l 8(%fp),%d0
	move.b %d1,-4(%fp)
	move.l %d0,%d1
	lsr.l #7,%d1
	move.b %d1,-3(%fp)
	moveq #127,%d1
	and.l %d1,%d0
	move.b %d0,-2(%fp)
	moveq #-9,%d0
	move.b %d0,-1(%fp)
	jsr td_usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L64
	jsr 1073752340
	pea -8(%fp)
	pea 8.w
	jsr 1073752544
	jsr 1073752356
	addq.l #8,%sp
.L64:
	unlk %fp
	rts
	.size	td_ask, .-td_ask
	.align	2
	.type	td_start, @function
td_start:
	move.l #-65536,%d1
	move.l %d1,td_cache+4
	clr.b %d1
	move.l 4(%sp),%d0
	lea (8,%sp),%a0
	move.l (%a0),td_cache+12
	move.w %d0,td_cache
	move.l %d0,4(%sp)
	move.b %d1,td_cache+8
	jra td_ask
	.size	td_start, .-td_start
	.section	.td2
	.align	2
	.type	td_ensure, @function
td_ensure:
	lea (-12,%sp),%sp
	movem.l #1036,(%sp)
	move.l 16(%sp),%d3
	move.l 1100784300,%d2
	jsr td_alloc
	tst.l %d0
	jeq .L70
	move.b td_cache+8,%d0
	lea td_cache,%a2
	tst.b %d0
	jeq .L72
	mvz.w (%a2),%d1
	cmp.l %d1,%d3
	jne .L72
	mvz.w td_cache+6,%d1
	move.l %d1,%a0
	mvz.w td_cache+4,%d1
	cmp.l %a0,%d1
	jls .L70
.L72:
	tst.b td_cache+9.l
	jeq .L73
	move.l %d2,%d1
	sub.l td_cache+16,%d1
	cmp.l #89999,%d1
	jhi .L73
	move.l %d2,%d0
	sub.l td_cache+12,%d0
	cmp.l #1500,%d0
	jhi .L74
	mvz.w (%a2),%d0
	cmp.l %d0,%d3
	jeq .L70
.L74:
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr td_start
	addq.l #8,%sp
.L70:
	movem.l (%sp),#1036
	lea (12,%sp),%sp
	rts
.L73:
	mvz.w (%a2),%d1
	cmp.l %d1,%d3
	jne .L75
	tst.b %d0
	jne .L75
	mvz.w td_cache+4,%d0
	cmp.l #65535,%d0
	jeq .L76
.L75:
	move.l %d2,-(%sp)
	move.l %d3,-(%sp)
	jsr td_start
	addq.l #8,%sp
.L76:
	moveq #15,%d1
	sub.l td_cache+12,%d2
	divu.l %d1,%d2
.L77:
	moveq #39,%d0
	cmp.l %d2,%d0
	jcc .L79
	moveq #1,%d1
	clr.w %d0
	move.l #1100784300,%a0
	move.b %d1,td_cache+9
	move.l (%a0),td_cache+16
	move.w %d0,td_cache+4
	jra .L70
.L79:
	pea 10000.w
	jsr 1074367512
	addq.l #4,%sp
	tst.b td_cache+8.l
	jeq .L78
	mvz.w (%a2),%d0
	cmp.l %d0,%d3
	jne .L78
	mvz.w td_cache+6,%d1
	mvz.w td_cache+4,%d0
	cmp.l %d1,%d0
	jls .L70
.L78:
	addq.l #1,%d2
	jra .L77
	.size	td_ensure, .-td_ensure
	.align	2
	.type	td_serve, @function
td_serve:
	lea (-48,%sp),%sp
	movem.l #19468,(%sp)
	move.l 52(%sp),%a2
	move.l 56(%sp),%a6
	move.l 12(%a2),%d0
	move.l %d0,%d2
	move.l (%a2),%a1
	addq.l #1,%d2
	move.l %a1,%d1
	and.l #1023,%d1
	move.l %d2,12(%a2)
	tst.l %d0
	jne .L90
	moveq #1,%d3
	move.l %d1,-(%sp)
	jsr td_ensure
	move.l (%a2),%d0
	clr.l 16(%a6)
	clr.l 12(%a6)
	move.l %d0,(%a6)
	move.l %d0,8(%a6)
	move.w %d3,4(%a6)
	pea td_dot
	pea 20(%a6)
	jsr td_name
	lea (12,%sp),%sp
.L91:
	mov3q.l #1,%d0
.L89:
	movem.l (%sp),#19468
	lea (48,%sp),%sp
	rts
.L90:
	mov3q.l #1,%d2
	cmp.l %d0,%d2
	jne .L92
	tst.l %d1
	jeq .L93
	tst.b td_cache+8.l
	jne .L94
.L93:
	mov3q.l #2,%d0
.L95:
	moveq #1,%d3
	move.l %d0,(%a6)
	move.l %a1,8(%a6)
	clr.l 16(%a6)
	clr.l 12(%a6)
	move.w %d3,4(%a6)
	pea td_dotdot
	pea 20(%a6)
	jsr td_name
.L110:
	addq.l #8,%sp
	jra .L91
.L94:
	mvz.w td_cache,%d0
	cmp.l %d0,%d1
	jne .L93
	mvz.w td_cache+2,%d0
	or.l #2113929216,%d0
	jra .L95
.L92:
	tst.b td_cache+8.l
	jeq .L97
	move.l td_cache+20,%a0
	tst.l %a0
	jne .L98
.L97:
	clr.l %d0
	jra .L89
.L98:
	mvz.w td_cache,%d2
	cmp.l %d2,%d1
	jne .L97
	mvz.w td_cache+6,%d2
	subq.l #2,%d0
	cmp.l %d2,%d0
	jcc .L97
	cmp.l #511,%d0
	jhi .L97
	lsl.l #5,%d0
	lea (23,%sp),%a2
	add.l %d0,%a0
	clr.l %d0
.L99:
	move.b 8(%a0,%d0.l),%d2
	jeq .L100
	move.b %d2,(%a2,%d0.l)
	addq.l #1,%d0
	moveq #24,%d2
	cmp.l %d0,%d2
	jne .L99
.L100:
	clr.b %d3
	move.l %a6,%d2
	add.l #20,%d2
	lea td_name,%a3
	move.b %d3,23(%sp,%d0.l)
	move.w 2(%a0),%d0
	tst.b (%a0)
	jeq .L102
	and.l #1023,%d0
	or.l #2113929216,%d0
	move.l %d0,(%a6)
	moveq #1,%d0
.L111:
	move.w %d0,4(%a6)
	move.l %a1,8(%a6)
	clr.l 16(%a6)
	clr.l 12(%a6)
	move.l %a2,-(%sp)
	move.l %d2,-(%sp)
	jsr (%a3)
	jra .L110
.L102:
	moveq #12,%d3
	and.l #4095,%d0
	lsl.l %d3,%d1
	or.l %d0,%d1
	clr.w %d0
	or.l #2122317824,%d1
	move.l %d1,(%a6)
	jra .L111
	.size	td_serve, .-td_serve
	.section	.td
	.align	2
	.globl	td_readdir
	.type	td_readdir, @function
td_readdir:
	subq.l #4,%sp
	move.l %a3,-(%sp)
	move.l %a2,-(%sp)
	move.l 16(%sp),%a3
	move.l 20(%sp),%a2
	tst.l %a3
	jne .L113
.L115:
	mov3q.l #-1,%d0
.L112:
	move.l (%sp)+,%a2
	move.l (%sp)+,%a3
	addq.l #4,%sp
	rts
.L113:
	tst.l %a2
	jeq .L115
	move.l (%a3),%d0
	move.l %d0,%d1
	and.l #-16777216,%d1
	cmp.l #2113929216,%d1
	jne .L116
	move.l %a2,20(%sp)
	move.l %a3,16(%sp)
	move.l (%sp)+,%a2
	move.l (%sp)+,%a3
	addq.l #4,%sp
	jra td_serve
.L116:
	subq.l #2,%d0
	tst.l %d0
	jne .L117
	move.l #2122219134,%d0
	cmp.l 12(%a3),%d0
	jeq .L125
.L117:
	move.l %a2,-(%sp)
	move.l %a3,-(%sp)
	jsr td_readdir_stock
	addq.l #8,%sp
	tst.l %d0
	jne .L112
	mov3q.l #2,%d1
	cmp.l (%a3),%d1
	jne .L112
	moveq #1,%d0
	move.l #2113929216,(%a2)
	mov3q.l #2,8(%a2)
	clr.l 16(%a2)
	clr.l 12(%a2)
	move.w %d0,4(%a2)
	pea td_teensy
	pea 20(%a2)
	jsr td_name
	addq.l #8,%sp
	move.l #2122219134,%d1
	move.l %d1,12(%a3)
	move.l 1100784300,%a2
	tst.b td_cache+9.l
	jeq .L120
	move.l %a2,%d0
	sub.l td_cache+16,%d0
	cmp.l #89999,%d0
	jls .L121
.L120:
	jsr td_alloc
	tst.l %d0
	jne .L122
.L121:
	mov3q.l #1,%d0
	jra .L112
.L122:
	tst.w td_cache.l
	jne .L123
	tst.b td_cache+8.l
	jne .L112
	move.l %a2,%d1
	sub.l td_cache+12,%d1
	cmp.l #599,%d1
	jls .L112
.L123:
	move.l %a2,-(%sp)
	clr.l -(%sp)
	move.l %d0,16(%sp)
	jsr td_start
	addq.l #8,%sp
	move.l 8(%sp),%d0
	jra .L112
.L125:
	clr.l %d0
	jra .L112
	.size	td_readdir, .-td_readdir
	.section	.td4,"ax",@progbits
	.align	2
	.type	td_project, @function
td_project:
	moveq #16,%d1
	link.w %fp,#-28
	move.l #-260222380,%d0
	move.l %d0,-22(%fp)
	mov3q.l #5,-28(%fp)
	move.b %d1,-18(%fp)
.L130:
	move.l -28(%fp),%a0
	add.l #1081903566,%a0
	tst.b (%a0)
	jeq .L131
	move.b (%a0),%d0
	moveq #127,%d1
	addq.l #1,-28(%fp)
	move.l -28(%fp),%a0
	and.l %d1,%d0
	move.b %d0,-23(%a0,%fp.l)
	moveq #20,%d0
	cmp.l %a0,%d0
	jne .L130
.L131:
	moveq #-9,%d1
	move.l -28(%fp),%a0
	move.b %d1,-22(%fp,%a0.l)
	mov3q.l #4,-(%sp)
	jsr td_usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L129
	jsr 1073752340
	pea -22(%fp)
	move.l -28(%fp),%a0
	pea 1(%a0)
	jsr 1073752544
	jsr 1073752356
	addq.l #8,%sp
.L129:
	unlk %fp
	rts
	.size	td_project, .-td_project
	.section	.td5
	.align	2
	.globl	td_ref
	.type	td_ref, @function
td_ref:
	link.w %fp,#-36
	move.l 16(%fp),%d0
	movem.l #1084,(%sp)
	move.l 8(%fp),%a2
	move.l 12(%fp),%a1
	tst.l %d0
	jge .L141
.L143:
	clr.l -16(%fp)
.L140:
	movem.l -36(%fp),#1084
	move.l -16(%fp),%d0
	unlk %fp
	rts
.L141:
	lsl.l #3,%d0
	move.l 260(%a1),%a0
	add.l %d0,%a0
	cmp.l 264(%a1),%a0
	jcc .L143
	move.l (%a0),%a0
	tst.l %a0
	jeq .L143
	move.l (%a0),%d2
	move.l %d2,%d0
	and.l #-8388608,%d0
	cmp.l #2122317824,%d0
	jne .L143
	mov3q.l #4,-(%sp)
	jsr td_usb_free
	addq.l #4,%sp
	move.l %d0,-16(%fp)
	tst.l %d0
	jeq .L140
	moveq #12,%d0
	move.l %d2,%d3
	lsr.l %d0,%d3
	jsr td_project
	move.l %d2,%d4
	and.l #4095,%d4
	move.l %d3,%d5
	move.l #-260222380,%d0
	move.l %d0,-10(%fp)
	moveq #15,%d0
	and.l #1023,%d5
	lsr.l #7,%d4
	move.b %d0,-6(%fp)
	moveq #127,%d0
	lsr.l #7,%d5
	and.l %d0,%d3
	and.l %d2,%d0
	move.b %d4,-3(%fp)
	move.b %d5,-5(%fp)
	move.b %d3,-4(%fp)
	move.b %d0,-2(%fp)
	moveq #-9,%d0
	move.b %d0,-1(%fp)
	jsr 1073752340
	pea -10(%fp)
	pea 10.w
	jsr 1073752544
	jsr 1073752356
	move.l #2119192399,(%a2)
	move.l %d2,4(%a2)
	clr.l 12(%a2)
	clr.l 8(%a2)
	addq.l #8,%sp
	jra .L140
	.size	td_ref, .-td_ref
	.align	2
	.type	td_send, @function
td_send:
	subq.l #8,%sp
	move.l 12(%sp),(%sp)
	move.l 16(%sp),4(%sp)
	mov3q.l #4,-(%sp)
	jsr td_usb_free
	addq.l #4,%sp
	tst.l %d0
	jeq .L151
	jsr 1073752340
	move.l (%sp),-(%sp)
	move.l 8(%sp),-(%sp)
	jsr 1073752544
	lea (16,%sp),%sp
	jmp 1073752356
.L151:
	addq.l #8,%sp
	rts
	.size	td_send, .-td_send
	.align	2
	.type	td_pool_tab, @function
td_pool_tab:
	subq.l #4,%sp
	move.l %d2,-(%sp)
	tst.l td_pool
	jne .L154
	pea 2304.w
	jsr 1074276820
	addq.l #4,%sp
	tst.l %d0
	jeq .L153
	move.l %d0,%d1
	move.l %d0,%a0
	add.l #2304,%d1
.L156:
	clr.l (%a0)+
	cmp.l %a0,%d1
	jne .L156
	move.l %d0,td_pool
.L154:
	move.l #1081903571,%a0
	mov3q.l #1,%d1
	lea td_pool-1081903563,%a1
.L157:
	move.b (%a0),7(%sp)
	addq.l #1,%a0
	move.b -1(%a0,%a1.l),%d0
	move.b 7(%sp),%d2
	eor.l %d2,%d0
	tst.b %d0
	seq %d0
	mvs.b %d0,%d0
	neg.l %d0
	and.l %d0,%d1
	cmp.l #1081903587,%a0
	jne .L157
	tst.l %d1
	jne .L158
	clr.b %d0
	move.b %d0,td_pool+4
.L159:
	move.b td_pool+5,%d0
	jeq .L162
	subq.l #1,%d0
	move.b %d0,td_pool+5
	jra .L160
.L158:
	tst.b td_pool+4.l
	jeq .L159
.L160:
	move.l td_pool,%d0
.L153:
	move.l (%sp)+,%d2
	addq.l #4,%sp
	rts
.L162:
	move.l #1081903571,%a0
.L161:
	move.b (%a0),(%a1,%a0.l)
	addq.l #1,%a0
	cmp.l #1081903587,%a0
	jne .L161
	moveq #-56,%d2
	move.b %d2,td_pool+5
	jsr td_project
	mov3q.l #6,-(%sp)
	pea (ask.0)
	jsr td_send
	addq.l #8,%sp
	jra .L160
	.size	td_pool_tab, .-td_pool_tab
	.align	2
	.globl	td_pool_sysex
	.type	td_pool_sysex, @function
td_pool_sysex:
	lea (-24,%sp),%sp
	mov3q.l #7,%d0
	move.l 32(%sp),%d1
	movem.l #1148,(%sp)
	move.l 28(%sp),%a0
	cmp.l %d1,%d0
	jge .L182
	move.l td_pool,%d2
	tst.l %d2
	jeq .L182
	tst.b 5(%a0)
	jeq .L172
	move.l %d2,%a1
	move.l %d2,%d0
	addq.l #4,%a1
	add.l #2308,%d0
.L173:
	clr.b (%a1)
	lea (18,%a1),%a1
	cmp.l %a1,%d0
	jne .L173
	moveq #1,%d6
	move.b %d6,td_pool+4
.L172:
	mvz.b 6(%a0),%d5
	addq.l #7,%a0
	moveq #12,%d3
	clr.l %d4
	subq.l #1,%d1
.L174:
	cmp.l %d4,%d5
	jle .L182
	move.l %d3,%d0
	add.l #12,%d0
	cmp.l %d1,%d0
	jlt .L179
.L182:
	movem.l (%sp),#1148
	mov3q.l #1,%d0
	lea (24,%sp),%sp
	rts
.L179:
	move.b (%a0),%d0
	jle .L175
	ext.w %d0
	move.l %d2,%a2
	sub.l %a1,%a1
	mulu.w #18,%d0
	add.l %d0,%a2
	mvz.b 1(%a0),%d0
	lsl.l #7,%d0
	move.l %d0,%d6
	mvz.b 2(%a0),%d0
	or.l %d6,%d0
	move.w %d0,(%a2)
	mvz.b 3(%a0),%d0
	lsl.l #7,%d0
	move.l %d0,%d6
	mvz.b 4(%a0),%d0
	or.l %d6,%d0
	move.w %d0,2(%a2)
.L176:
	move.b 5(%a0,%a1.l),%d0
	jeq .L177
	move.b %d0,4(%a2,%a1.l)
	addq.l #1,%a1
	moveq #13,%d0
	cmp.l %a1,%d0
	jne .L176
.L177:
	clr.b %d6
	move.b %d6,4(%a2,%a1.l)
	tst.l %a1
	jne .L175
	move.w #16128,%d0
	move.w %d0,4(%a2)
.L175:
	addq.l #1,%d4
	lea (18,%a0),%a0
	add.l #18,%d3
	jra .L174
	.size	td_pool_sysex, .-td_pool_sysex
	.align	2
	.globl	td_hook
	.type	td_hook, @function
td_hook:
	move.l 4(%sp),%a0
	moveq #20,%d1
	mvz.b 4(%a0),%d0
	move.l %a0,4(%sp)
	cmp.l %d0,%d1
	jne .L189
	jra td_pool_sysex
.L189:
	jra td_sysex
	.size	td_hook, .-td_hook
	.align	2
	.globl	td_empty
	.type	td_empty, @function
td_empty:
	subq.l #4,%sp
	move.l %d3,-(%sp)
	move.l %d2,-(%sp)
	move.l 20(%sp),%d2
	move.l 16(%sp),8(%sp)
	jsr td_pool_ctx
	move.l %d0,%d3
	tst.l %d0
	jne .L191
	move.l %d2,20(%sp)
	move.l 8(%sp),16(%sp)
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	addq.l #4,%sp
	jra td_empty_stock
.L191:
	tst.l %d2
	jeq .L192
	moveq #127,%d0
	cmp.l %d2,%d0
	jcc .L193
.L194:
	move.l %d3,%d2
.L192:
	move.l %d2,%d0
	move.l (%sp)+,%d2
	move.l (%sp)+,%d3
	addq.l #4,%sp
	rts
.L193:
	jsr td_pool_tab
	tst.l %d0
	jeq .L194
	moveq #18,%d1
	muls.l %d1,%d2
	move.l %d0,%a0
	tst.b 4(%a0,%d2.l)
	seq %d2
	mvs.b %d2,%d2
	neg.l %d2
	jra .L192
	.size	td_empty, .-td_empty
	.align	2
	.globl	td_pool_name
	.type	td_pool_name, @function
td_pool_name:
	move.l %d2,-(%sp)
	moveq #126,%d1
	move.l 8(%sp),%d0
	subq.l #1,%d0
	cmp.l %d0,%d1
	jcc .L202
.L204:
	clr.l %d0
.L201:
	move.l (%sp)+,%d2
	rts
.L202:
	jsr td_pool_ctx
	tst.l %d0
	jeq .L204
	jsr td_pool_tab
	tst.l %d0
	jeq .L201
	move.l 8(%sp),%d1
	moveq #18,%d2
	muls.l %d2,%d1
	add.l %d1,%d0
	move.l %d0,%a0
	tst.b 4(%a0)
	jeq .L204
	addq.l #4,%d0
	jra .L201
	.size	td_pool_name, .-td_pool_name
	.align	2
	.globl	td_mark
	.type	td_mark, @function
td_mark:
	move.l td_pool,%a0
	move.l %d2,-(%sp)
	tst.l %a0
	jne .L212
.L216:
	mov3q.l #-1,%d0
.L211:
	move.l (%sp)+,%d2
	rts
.L212:
	moveq #12,%d2
	mov3q.l #1,%d0
	move.l 8(%sp),%d1
	lsr.l %d2,%d1
	lea (18,%a0),%a0
	and.l #1023,%d1
	move.l %d1,%a1
	move.l 8(%sp),%d1
	and.l #4095,%d1
.L215:
	tst.b 4(%a0)
	jeq .L214
	mvz.w (%a0),%d2
	cmp.l %d2,%a1
	jne .L214
	mvz.w 2(%a0),%d2
	cmp.l %d2,%d1
	jeq .L211
.L214:
	addq.l #1,%d0
	lea (18,%a0),%a0
	cmp.l #128,%d0
	jne .L215
	jra .L216
	.size	td_mark, .-td_mark
	.align	2
	.globl	td_assign
	.type	td_assign, @function
td_assign:
	link.w %fp,#-32
	move.l 8(%fp),%a0
	movem.l #60,(%sp)
	tst.l %a0
	jeq .L219
	move.l (%a0),%d2
	move.l %d2,%d0
	and.l #-8388608,%d0
	cmp.l #2122317824,%d0
	jeq .L220
.L219:
	clr.l %d0
.L218:
	movem.l -32(%fp),#60
	unlk %fp
	rts
.L220:
	moveq #127,%d1
	and.l 12(%fp),%d1
	move.l %d1,-16(%fp)
	tst.l %d1
	jeq .L219
	moveq #12,%d0
	move.l %d2,%d3
	lsr.l %d0,%d3
	jsr td_project
	move.l %d2,%d4
	moveq #18,%d0
	move.l %d3,%d5
	move.l #-260222380,%d1
	move.l %d1,-11(%fp)
	moveq #127,%d1
	and.l %d1,%d2
	and.l #1023,%d5
	and.l #4095,%d4
	pea 11.w
	and.l %d1,%d3
	pea -11(%fp)
	move.b %d0,-7(%fp)
	move.b -13(%fp),-6(%fp)
	move.b %d2,-2(%fp)
	moveq #-9,%d2
	move.l %d5,%d0
	lsr.l #7,%d0
	move.b %d3,-4(%fp)
	move.b %d0,-5(%fp)
	move.l %d4,%d0
	lsr.l #7,%d0
	move.b %d2,-1(%fp)
	move.b %d0,-3(%fp)
	jsr td_send
	jsr td_pool_tab
	addq.l #8,%sp
	tst.l %d0
	jeq .L222
	move.w -14(%fp),%d1
	move.l %d0,%a0
	move.w #16128,%d0
	mulu.w #18,%d1
	add.l %d1,%a0
	move.w %d5,(%a0)
	move.w %d4,2(%a0)
	move.w %d0,4(%a0)
	tst.b td_cache+8.l
	jne .L223
.L222:
	mov3q.l #1,%d0
	jra .L218
.L223:
	move.l td_cache+20,%a1
	tst.l %a1
	jeq .L222
	mvz.w td_cache,%d0
	cmp.l %d0,%d5
	jne .L222
	mvz.w td_cache+6,%d0
	clr.l %d1
.L224:
	cmp.l %d0,%d1
	jcc .L222
	cmp.l #512,%d1
	jeq .L222
	tst.b (%a1)
	jne .L225
	mvz.w 2(%a1),%d2
	cmp.l %d2,%d4
	jne .L225
	mvz.w %d1,%d1
	clr.l %d0
	lsl.l #5,%d1
.L226:
	move.l td_cache+20,%a1
	add.l %d0,%a1
	move.b 8(%a1,%d1.l),%d2
	jeq .L227
	move.b %d2,4(%a0,%d0.l)
	addq.l #1,%d0
	moveq #13,%d2
	cmp.l %d0,%d2
	jne .L226
.L227:
	clr.b %d1
	move.b %d1,4(%a0,%d0.l)
	jra .L222
.L225:
	addq.l #1,%d1
	lea (32,%a1),%a1
	jra .L224
	.size	td_assign, .-td_assign
	.section	.tdd,"a"
	.type	ask.0, @object
	.size	ask.0, 6
ask.0:
	.base64	"8H1SVBP3"
	.globl	td_pool
	.section	.td6,"aw"
	.align	2
	.type	td_pool, @object
	.size	td_pool, 24
td_pool:
	.zero	24
	.globl	td_file_node
	.section	.tdn,"aw"
	.align	2
	.type	td_file_node, @object
	.size	td_file_node, 128
td_file_node:
	.byte	0
	.byte	3
	.word	0
	.long	0
	.long	0
	.long	1
	.zero	2
	.zero	110
	.globl	td_dir_node
	.align	2
	.type	td_dir_node, @object
	.size	td_dir_node, 128
td_dir_node:
	.byte	1
	.byte	1
	.word	0
	.long	0
	.long	0
	.long	0
	.zero	2
	.zero	110
	.section	.tdd
	.type	td_teensy, @object
	.size	td_teensy, 8
td_teensy:
	.string	"SIDECAR"
	.type	td_dotdot, @object
	.size	td_dotdot, 3
td_dotdot:
	.string	".."
	.type	td_dot, @object
	.size	td_dot, 2
td_dot:
	.string	"."
	.globl	td_cache
	.section	.tds,"aw"
	.align	2
	.type	td_cache, @object
	.size	td_cache, 24
td_cache:
	.zero	24
	.globl	td_mailbox
	.section	.tdm,"aw"
	.align	2
	.type	td_mailbox, @object
	.size	td_mailbox, 8
td_mailbox:
	.long	1413763670
	.long	td_hook
	.ident	"GCC: (GNU) 16.2.0"
	.endif
