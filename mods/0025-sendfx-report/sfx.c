/*
 * 0025-sendfx-report: a read-only reporter for the Sidecar send FX
 * (rytm-teensy docs/superpowers/specs/2026-10-16-sidecar-send-fx-storage.md).
 * Every audio block it compares the words the trig loop last wrote to the
 * per-track trig array (trig_sound_array, 0x8000e5b0 + 84 t: after p-locks,
 * before the LFO) with what it last sent, and sends a changed track to the USB
 * host as host-link SysEx 0x20 SENDFX (rytm-teensy sim/protocol.py):
 *
 *   F0 7D 52 54 20 <ver 1> <track 0..11> <hi> <lo> F7          sound index 0
 *   F0 7D 52 54 20 <ver 1> 0C <hi lo> x 6 F7                   FX words 0, 29,
 *                                                              38, 39, 40, 41
 *
 * hi = word bits 8..14, lo = word bits 1..7: the two 7-bit halves a stock
 * p-lock writes (a lock slot's value and its 0x80 0x80 fine slot). So a lock
 * on a step arrives in the block its trig plays. Besides changes, one track in
 * turn is sent again every P_RR blocks (0: never), so a host that attaches or
 * lost a message has every value within 13 x P_RR blocks.
 *
 * It writes nothing the firmware reads. It runs in the audio interrupt
 * (level 5), from the block driver right after fx_generate (detour at
 * 0x401213a0, 0006's site), so it never waits. It calls the OS's USB MIDI
 * sender (0x400029e0) only when that is safe from here, with 0021's tests
 * [measured, OS 1.73, mods/0021-ext/ext.c]: the sender's mutex (0x42f67a28)
 * free, its SysEx state (0x413db244) idle, its 4 KB ring fill (0x413db258)
 * under 3800, at least two free USB requests in the pool (head 0x413db390,
 * next at +52), and a host has configured the port (0x413db254 == 1: else the
 * sender would drop it and the shadow would claim it sent). Otherwise the
 * track stays pending for the next block. At most P_MAXB messages a block.
 */
#include <stdint.h>

typedef void (*send_fn)(int32_t len, const uint8_t *data);
#define USB_MIDI_SEND  ((send_fn)0x400029e0u)
#define SENDER_MUTEX   (*(volatile uint32_t *)0x42f67a28u)
#define SYSEX_STATE    (*(volatile uint32_t *)0x413db244u)
#define PORT_STATE     (*(volatile uint32_t *)0x413db254u)
#define RING_FILL      (*(volatile uint32_t *)0x413db258u)
#define POOL_HEAD      (*(const volatile uint32_t *const volatile *)0x413db390u)

extern const volatile uint16_t trig_sound_array[];   /* 13 x 42 words */

#define TW 42                                        /* words a track */
#define FX 12

/* Written at run time: the shadows (track t < 12: word 0; t = 12: six words),
   0xffffffff = not sent; the block divider and the round-robin track. */
static struct { uint32_t sh[12 + 6]; uint16_t rr_div; uint8_t rr_t, next_t; } st = {
  {0xffffffffu, 0xffffffffu, 0xffffffffu, 0xffffffffu, 0xffffffffu, 0xffffffffu,
   0xffffffffu, 0xffffffffu, 0xffffffffu, 0xffffffffu, 0xffffffffu, 0xffffffffu,
   0xffffffffu, 0xffffffffu, 0xffffffffu, 0xffffffffu, 0xffffffffu, 0xffffffffu}, 1, 0, 0};
#define sh st.sh
#define rr_div st.rr_div
#define rr_t st.rr_t
#define next_t st.next_t

static const uint8_t fxw[6] = {0, 29, 38, 39, 40, 41};

static int can_send(void) {
  const volatile uint32_t *h;
  int n = 2;
  if (SENDER_MUTEX != 0 || SYSEX_STATE != 0 || PORT_STATE != 1 || RING_FILL > 3800)
    return 0;
  h = POOL_HEAD;
  while (n-- > 0) {
    if (!h) return 0;
    h = (const volatile uint32_t *)h[13];
  }
  return 1;
}

/* The track's words now: one for t < 12, six for the FX track. Returns the count. */
static int words(int t, uint16_t *w) {
  const volatile uint16_t *a = trig_sound_array + TW * t;
  int i;
  if (t < FX) {
    w[0] = a[0];
    return 1;
  }
  for (i = 0; i < 6; i++)
    w[i] = a[fxw[i]];
  return 6;
}

void sfx_block(void) {
  uint8_t m[20];
  uint16_t w[6];
  int k, t, i, n, d, sent = 0, maxb;
  uint32_t *s;
  __asm__("moveq #P_RR,%0" : "=d"(k));       /* build params, range-checked in stub */
  if (k && !--rr_div) {
    rr_div = k;
    s = sh + (rr_t < FX ? rr_t : FX);
    for (i = (rr_t < FX ? 1 : 6); i > 0; i--)
      *s++ = 0xffffffffu;                     /* send this track again */
    if (++rr_t > FX) rr_t = 0;
  }
  __asm__("moveq #P_MAXB,%0" : "=d"(maxb));
  t = next_t;
  for (k = 0; k <= FX; k++, t = (t == FX ? 0 : t + 1)) {
    n = words(t, w);
    s = sh + (t < FX ? t : FX);
    d = 0;
    for (i = 0; i < n; i++)
      if (s[i] != w[i]) d = 1;
    if (!d)
      continue;
    if (sent >= maxb || !can_send())
      break;                                  /* pending: retried next block */
    m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x20; m[5] = 1; m[6] = t;
    for (i = 0; i < n; i++) {
      m[7 + 2 * i] = (w[i] >> 8) & 0x7f;
      m[8 + 2 * i] = (w[i] >> 1) & 0x7f;
    }
    m[7 + 2 * n] = 0xf7;
    USB_MIDI_SEND(8 + 2 * n, m);
    for (i = 0; i < n; i++)
      s[i] = w[i];
    sent++;
  }
  next_t = t;                                 /* round robin over refused sends */
}

/* The detour at 0x401213a0 (addql #4,%sp; clrl %d1; lea 0x8000e508,%a1):
   sfx_block with d0/d1/a0/a1 kept, then the displaced instructions, rejoining
   at 0x401213aa. sfx_block is a C function (d2-d7/a2-a6 callee-saved); it
   uses no EMAC. */
__asm__(
"	.if	(P_RR < 0) + (P_RR > 127)\n"
"	.error	\"0025 rr: 0..127\"\n"
"	.endif\n"
"	.if	(P_MAXB < 1) + (P_MAXB > 8)\n"
"	.error	\"0025 maxb: 1..8\"\n"
"	.endif\n"
"	.align	2\n"
"	.globl	sfx_hook\n"
"sfx_hook:\n"
"	lea	-16(%sp),%sp\n"
"	movem.l	%d0-%d1/%a0-%a1,(%sp)\n"
"	jsr	sfx_block\n"
"	movem.l	(%sp),%d0-%d1/%a0-%a1\n"
"	lea	16(%sp),%sp\n"
"	addq.l	#4,%sp\n"                          /* displaced, verbatim */
"	clr.l	%d1\n"
"	lea	0x8000e508,%a1\n"
"	jmp	0x401213aa\n");

/* ---------------------------------------------------------------------------
 * Persistent FX words 38..41 (M1b-b, rytm-teensy 2026-10-16-sidecar-send-fx-storage.md): the four live-only FX words
 * get kit storage (storage 0x816..0x81D, after the FX block's 38 words) and p-lock storage as new lock types on the
 * FX track: 42..45 the hi halves (bits 8..14) of FX 38..41, 46..49 the lo halves (bits 1..7), each a plain 64-step
 * slot, never a 0x80 0x80 continuation. Stock skips types above 41 at load (0x40009040) and drops them at its next
 * full rebuild; it never reads 0x816. Without these hooks a live FX 38..41 lock would be saved by stock as types
 * 9..12 (its reverse map 0x401c589c has 38 entries and runs into the next table): FX 18..21 locks.
 * ------------------------------------------------------------------------- */
#define LOCK_TRACK 5674          /* live lock array: a track's bytes */
#define LOCK_STEP 88             /* a step: 42 words, then the u32 lock count at +84 */
#define LOCK_FINE 5632           /* a track's 42 fine flags */

/* Load (0x40008f98), a slot of type 42..49 on track 12: merge its 64 values into live FX index 38..41. */
void sfx_lock_merge(const volatile uint8_t *slot, volatile uint8_t *live) {
  int ty = slot[0] - 42, k = 38 + (ty & 3), st;
  volatile uint8_t *tr = live + LOCK_TRACK * 12;
  for (st = 0; st < 64; st++) {
    int v = slot[2 + st];
    volatile uint16_t *w = (volatile uint16_t *)(tr + LOCK_STEP * st + 2 * k);
    uint32_t o;
    if (v & 0x80) continue;
    o = *w;
    if (o == 0xffff) {
      o = 0;
      ++*(volatile uint32_t *)(tr + LOCK_STEP * st + 84);
    }
    *w = ty < 4 ? (uint16_t)((o & 0x00ff) | v << 8) : (uint16_t)((o & 0xff00) | v << 1);
  }
  if (ty >= 4) tr[LOCK_FINE + k] = 1;
}

/* Full rebuild (0x40009216) at FX index k >= 38 of track 12, with locks: the hi slot at n, the lo slot at n + 1 when
   the index has its fine flag (exactly the slots stock counted for it). w: the index's word on step 0. */
void sfx_rebuild_c(volatile uint8_t *slots, const volatile int16_t *w, int n, int k4, int fine) {
  volatile uint8_t *h = slots + 66 * n, *l = h + 66;
  int st, k = k4 >> 2;
  h[0] = 42 + k - 38; h[1] = 12;
  if (fine) { l[0] = 46 + k - 38; l[1] = 12; }
  for (st = 0; st < 64; st++, w += LOCK_STEP / 2) {
    int v = *w;
    h[2 + st] = v < 0 ? 0xff : (v >> 8) & 0x7f;
    if (fine) l[2 + st] = v < 0 ? 0xff : (v >> 1) & 0x7f;
  }
}

__asm__(
"	.align	2\n"
/* 0x40009040 (cmpl %d4,%d6 / bltw 0x40009128; d6 = 41, d4 the slot's type, d2 its track, a2 the slot, a3 the live
   locks): reimplemented, not re-emitted (a pc-relative branch). Types 0..41 go on to 0x40009046 as before; 42..49
   on track 12 are merged, then the next slot with no continuation context (d0 = d1 = -1); anything else is skipped
   as stock skips it (d0/d1 kept). */
"	.globl	sfx_lock_load\n"
"sfx_lock_load:\n"
"	cmp.l	%d4,%d6\n"
"	blt.s	1f\n"
"	jmp	0x40009046\n"
"1:	moveq	#49,%d6\n"
"	cmp.l	%d4,%d6\n"
"	blt.s	2f\n"
"	moveq	#12,%d6\n"
"	cmp.l	%d2,%d6\n"
"	bne.s	2f\n"
"	move.l	%a3,-(%sp)\n"
"	move.l	%a2,-(%sp)\n"
"	jsr	sfx_lock_merge\n"
"	addq.l	#8,%sp\n"
"	moveq	#-1,%d0\n"
"	moveq	#-1,%d1\n"
"2:	jmp	0x40009128\n"
/* 0x400092aa (moveq #12,%d4; cmpl %d1,%d4; bnew 0x40009354), the rebuild's track test, reimplemented (a pc-relative
   branch; the stub's six bytes leave the branch's displacement word dead, nothing branches into it). Not 0x400092b2:
   tracks 0..11 branch back to 0x400092b6. Track 12 (d1): d3 = 4 k, d0 the next slot, a0 the slots, a1 the index's
   word on step 0, d2 1 with the fine flag. k >= 38: our slots, then 0x4000932c (d0 = the count stock reserved,
   sp@(44)) and on to the next track. */
"	.globl	sfx_rebuild\n"
"sfx_rebuild:\n"
"	moveq	#12,%d4\n"
"	cmp.l	%d1,%d4\n"
"	beq.s	1f\n"
"	jmp	0x40009354\n"
"1:	cmp.l	#152,%d3\n"
"	blt.s	2f\n"
"	lea	-12(%sp),%sp\n"
"	movem.l	%d1/%a0-%a1,(%sp)\n"
"	move.l	%d2,-(%sp)\n"
"	move.l	%d3,-(%sp)\n"
"	move.l	%d0,-(%sp)\n"
"	move.l	%a1,-(%sp)\n"
"	move.l	%a0,-(%sp)\n"
"	jsr	sfx_rebuild_c\n"
"	lea	20(%sp),%sp\n"
"	movem.l	(%sp),%d1/%a0-%a1\n"
"	lea	12(%sp),%sp\n"
"	jmp	0x4000932c\n"
"2:	jmp	0x400092b2\n"
/* 0x40009454 (movel %a1@(0,%a0:l:4),%d5; clrl %d4) in the incremental save: d0 = 12, d3 the track, a0 the index.
   FX index >= 38: the save's own tail call into the full rebuild (0x40009572: d1, a2, a4 still its arguments). */
"	.globl	sfx_incr\n"
"sfx_incr:\n"
"	cmp.l	%d0,%d3\n"
"	bne.s	1f\n"
"	moveq	#37,%d2\n"
"	cmp.l	%a0,%d2\n"
"	bcc.s	1f\n"
"	jmp	0x40009572\n"
"1:	move.l	(0,%a1,%a0.l*4),%d5\n"         /* displaced, verbatim */
"	clr.l	%d4\n"
"	jmp	0x4000945a\n"
/* FX loader 0x40007f42 (lsll #8,%d0; movew %d0,%a0@(8)): a0 the live FX words, a1 the storage block (0x7C6): then
   storage +0x50..+0x57 (kit 0x816..0x81D) -> live words 38..41 (+76). */
"	.globl	sfx_kload\n"
"sfx_kload:\n"
"	lsl.l	#8,%d0\n"
"	move.w	%d0,8(%a0)\n"
"	move.l	0x50(%a1),76(%a0)\n"   /* misaligned longs: ColdFire splits them (stock moves words at odd addresses) */
"	move.l	0x54(%a1),80(%a0)\n"
"	jmp	0x40007f48\n"
/* FX saver 0x40007f8c (lsll #8,%d0; movew %d0,%a2@(68)): a2 the storage block, a1 past the 38 live words (live + 76):
   live words 38..41 -> storage +0x50..+0x57. */
"	.globl	sfx_ksave\n"
"sfx_ksave:\n"
"	lsl.l	#8,%d0\n"
"	move.w	%d0,68(%a2)\n"
"	move.l	(%a1),0x50(%a2)\n"
"	move.l	4(%a1),0x54(%a2)\n"
"	jmp	0x40007f92\n");
