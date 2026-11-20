/*
 * 0025-sendfx-report: a read-only reporter for the Sidecar send FX
 * (rytm-teensy docs/superpowers/specs/2026-10-16-sidecar-send-fx-storage.md).
 * Every audio block it compares the words the trig loop last wrote to the
 * per-track trig array (trig_sound_array, 0x8000e5b0 + 84 t: after p-locks,
 * before the LFO), as the message halves below, with what it last sent, and sends a changed track to the USB
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
 *
 * A kit switch (a pattern on another kit, while stopped or before a track's next trig) leaves the trig array on the
 * old kit's sounds until each track trigs: the trig loop copies the kit only then (trig_kit_copied != the trig's
 * kit). So from an active kit change on, each track reports its words from the active kit itself (live kit k at
 * 0x412558e3 + 2531 k: sound t's words at + 42 + 152 t + 20, the FX track's at + 1866) until its trig_kit_copied is
 * the active kit (its first trig has copied it, its p-locks on top). RELOAD KIT / RELOAD ALL / LOAD need none of
 * this: kit_push (0x4011f89e) copies every track's sound into the trig array itself [code; measured, rytm-emu].
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
#define ACTIVE_KIT  (*(const volatile int32_t *)0x800067b8u)
#define KIT_COPIED  ((const volatile int32_t *)0x8000fc58u)   /* per track: the kit its trig array holds (-1: none) */
#define LIVE_KITS   ((const volatile uint8_t *)0x412558e3u)   /* live kit k at + 2531 k (all 128 resident) */

#define TW 42                                        /* words a track */
#define FX 12

/* Written at run time: the shadows (the message bytes last sent: track t < 12 at 2 t, two; the FX track at 24,
   twelve) and the tracks to send again (bit t: not sent yet, or the round robin's); the block divider and the
   round-robin track; the active kit last seen and the tracks that read it (bit t) instead of the trig array. */
static struct { uint8_t sh[24 + 12]; uint32_t pend, km; int32_t kit; uint8_t rr_div, rr_t, next_t; } st = {
  {0}, 0x1fff, 0, 0, 1, 0, 0};
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

/* The track's words now as message bytes (hi, lo each) in b: one word for t < 12, six for the FX track (fxw[0] is 0:
   sound index 0 too). From the trig array, or after a kit change from the active kit k until the track's trig has
   copied it. Returns the byte count. */
static int bytes(int t, uint8_t *b, int32_t k) {
  const volatile uint8_t *p = (const volatile uint8_t *)(trig_sound_array + TW * t);
  int i, n = t < FX ? 2 : 12;
  if (st.km >> t & 1) {
    if (KIT_COPIED[t] == k)
      st.km &= ~(1u << t);
    else
      p = LIVE_KITS + 2531 * k + 42 + 152 * t + (t < FX ? 20 : 0);
  }
  for (i = 0; i < n; i += 2) {
    const volatile uint8_t *q = p + 2 * fxw[i >> 1];
    b[i] = q[0] & 0x7f;
    b[i + 1] = q[1] >> 1;
  }
  return n;
}

void sfx_block(void) {
  uint8_t m[20];
  int k, t, i, n, d, sent = 0, maxb;
  uint8_t *s;
  int32_t kit = ACTIVE_KIT;
  if (kit != st.kit) {
    st.kit = kit;
    st.km = 0x1fff;                           /* every track reads the new kit until its trig */
  }
  __asm__("moveq #P_RR,%0" : "=d"(k));       /* build params, range-checked in stub */
  if (k && !--rr_div) {
    rr_div = k;
    st.pend |= 1u << rr_t;                    /* send this track again */
    if (++rr_t > FX) rr_t = 0;
  }
  __asm__("moveq #P_MAXB,%0" : "=d"(maxb));
  t = next_t;
  for (k = 0; k <= FX; k++, t = (t == FX ? 0 : t + 1)) {
    n = bytes(t, m + 7, kit);
    s = sh + 2 * t;
    d = st.pend >> t & 1;
    for (i = 0; i < n; i++)
      if (s[i] != m[7 + i]) d = 1;
    if (!d)
      continue;
    if (sent >= maxb || !can_send())
      break;                                  /* pending: retried next block */
    m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x20; m[5] = 1; m[6] = t;
    m[7 + n] = 0xf7;
    USB_MIDI_SEND(8 + n, m);
    for (i = 0; i < n; i++)
      s[i] = m[7 + i];
    st.pend &= ~(1u << t);
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

/* Lock words of FX 38..41, the two halves independent (lock-halves, 2026-11-20). Each word holds two knobs (hi = bits
   8..14, lo = bits 1..7) and the live lock array has one word a step, so the word says which halves are locked:
     0xffff                     no lock (stock's)
     hi << 8 | lo << 1          both halves locked (bit 0 clear: the stock form, and every lock saved before)
     hi << 8 | 1                the hi half only (the lo half plays the kit's)
     lo << 8 | 3                the lo half only (the hi half plays the kit's)
   Never negative but for 0xffff, so stock's lock tests (-1 / < 0) see a lock or none as before. The same encoding is in
   0029 (its lock get / set / clear wrappers). The project file keeps one lock type per half (42..45 hi, 46..49 lo):
   a half without a lock is 0xff in its slot. */
#define LK_HI 1
#define LK_LO 2
static int lk_get(uint32_t w, int *h, int *l) {
  w &= 0xffff;
  if (w & 0x8000) return 0;
  if (!(w & 1)) { *h = w >> 8 & 0x7f; *l = w >> 1 & 0x7f; return LK_HI | LK_LO; }
  if (w & 2) { *l = w >> 8 & 0x7f; return LK_LO; }
  *h = w >> 8 & 0x7f;
  return LK_HI;
}
static uint16_t lk_make(int m, int h, int l) {
  if (m == (LK_HI | LK_LO)) return (uint16_t)(h << 8 | l << 1);
  if (m == LK_HI) return (uint16_t)(h << 8 | 1);
  if (m == LK_LO) return (uint16_t)(l << 8 | 3);
  return 0xffff;
}

/* Load (0x40008f98): a slot's 64 values into one half of lock index k's words on track tr (keep: the halves the word
   already had that stay; a value >= 0x80 leaves its step's half as it is). The step's lock count is bumped when its
   word had no lock; a lo half sets the index's fine flag. */
static void lk_load(const volatile uint8_t *s, volatile uint8_t *tr, int k, int half, int keep) {
  int st;
  for (st = 0; st < 64; st++) {
    int v = s[st], h = 0, l = 0, m;
    volatile uint16_t *w = (volatile uint16_t *)(tr + LOCK_STEP * st + 2 * k);
    m = lk_get(*w, &h, &l) & keep;
    if (!(v & 0x80)) {
      if (!m) ++*(volatile uint32_t *)(tr + LOCK_STEP * st + 84);
      if (half == LK_HI) h = v; else l = v;
      m |= half;
    }
    *w = lk_make(m, h, l);
  }
  if (half == LK_LO) tr[LOCK_FINE + k] = 1;
}
/* A slot of type 42..49 on track 12 (t = 12): FX index 38..41, each type its own half (a step's other half stays as
   another slot of the pattern gives it, or unlocked). amp-halves (2026-11-20), t < 12: the 0x80 0x80 fine slot after a
   voice track's type 41 slot (sound index 0: SFX1 hi, SFX2 lo). Stock's coarse pass has written hi << 8 on every step
   its slot locks; this slot says per step whether the lo half is locked too: a value is both halves (the stock form,
   every lock saved before), 0xff after a coarse value the hi half only, a value after a coarse 0xff the lo half only
   (stock ORs that into 0xffff: no lock). */
void sfx_lock_merge(const volatile uint8_t *slot, volatile uint8_t *live, int t) {
  int ty = slot[0] - 42, k = 0, half = LK_LO, keep = LK_HI;
  if (t == FX) {
    k = 38 + (ty & 3);
    keep = LK_HI | LK_LO;
    if (ty < 4) half = LK_HI;
  }
  lk_load(slot + 2, live + LOCK_TRACK * t, k, half, keep);
}

/* Full rebuild (0x40009216) at FX index k >= 38 of track 12, or sound index 0 (k4 = 0) of a voice track t, with locks:
   the hi slot at n, the lo slot at n + 1 when the index has its fine flag (exactly the slots stock counted for it). w:
   the index's word on step 0. Only the locked halves are written: a step locked on one half has 0xff in the other
   half's slot. FX: types 42 + k - 38 / 46 + k - 38 (0025's); voice tracks: type 41 and stock's 0x80 0x80 fine slot. */
void sfx_rebuild_c(volatile uint8_t *slots, const volatile int16_t *w, int n, int k4, int fine, int t) {
  volatile uint8_t *hs = slots + 66 * n, *ls = hs + 66;
  int st, k = k4 >> 2, fx = t == FX;
  hs[0] = fx ? k + 4 : 41; hs[1] = t;
  if (fine) { ls[0] = fx ? k + 8 : 0x80; ls[1] = fx ? t : 0x80; }
  for (st = 0; st < 64; st++, w += LOCK_STEP / 2) {
    int h = 0, l = 0, m = lk_get((uint16_t)*w, &h, &l);
    hs[2 + st] = m & LK_HI ? h : 0xff;
    if (fine) ls[2 + st] = m & LK_LO ? l : 0xff;
  }
}

/* Playback (the audio interrupt's trig loop, 0x40120968: a trig's lock list, entries {track, sound index, value,
   flags} of 8 B, each value written into the trig array and the two copies beside it). An FX 38..41 entry locked on
   one half: its value becomes that half and the other half the trig array's word, which the trig loop has just copied
   from the kit (a trig after a step with locks always copies it: the loop's dirty byte counts the lock entries) or
   which a knob turn has written since [code]. Written back into the entry, so the stock body after the detour stores
   the merged word everywhere it stores the value. */
void sfx_play_c(volatile uint16_t *e) {
  uint32_t t = e[0], k = e[1];
  int h = 0, l = 0, m;
  uint32_t cur;
  if (t == FX ? k - 38 > 3 : t > FX || k) return;   /* amp-halves: sound index 0 of a voice track too */
  m = lk_get(e[2], &h, &l);
  cur = trig_sound_array[TW * t + k];
  if (m == LK_HI) e[2] = (uint16_t)(h << 8 | (cur & 0xff));
  else if (m == LK_LO) e[2] = (uint16_t)((cur & 0xff00) | l << 1);
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
"	move.l	%d2,-(%sp)\n"
"	move.l	%a3,-(%sp)\n"
"	move.l	%a2,-(%sp)\n"
"	jsr	sfx_lock_merge\n"
"	lea	12(%sp),%sp\n"
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
"	tst.l	%d3\n"                            /* amp-halves: a voice track's index 0 is ours too */
"	beq.s	3f\n"
"	jmp	0x40009354\n"
"1:	cmp.l	#152,%d3\n"
"	blt.s	2f\n"
"3:	lea	-12(%sp),%sp\n"
"	movem.l	%d1/%a0-%a1,(%sp)\n"
"	move.l	%d1,-(%sp)\n"
"	move.l	%d2,-(%sp)\n"
"	move.l	%d3,-(%sp)\n"
"	move.l	%d0,-(%sp)\n"
"	move.l	%a1,-(%sp)\n"
"	move.l	%a0,-(%sp)\n"
"	jsr	sfx_rebuild_c\n"
"	lea	24(%sp),%sp\n"
"	movem.l	(%sp),%d1/%a0-%a1\n"
"	lea	12(%sp),%sp\n"
"	jmp	0x4000932c\n"
"2:	jmp	0x400092b2\n"
/* 0x40009454 (movel %a1@(0,%a0:l:4),%d5; clrl %d4) in the incremental save: d0 = 12, d3 the track, a0 the index.
   FX index >= 38: the save's own tail call into the full rebuild (0x40009572: d1, a2, a4 still its arguments). */
"	.globl	sfx_incr\n"
"sfx_incr:\n"
"	cmp.l	%d0,%d3\n"
"	bne.s	3f\n"
"	moveq	#37,%d2\n"
"	cmp.l	%a0,%d2\n"
"	bcs.s	4f\n"
"	bra.s	1f\n"
"3:	move.l	%a0,%d2\n"                       /* amp-halves: a voice track's index 0 too (d2 is set again at 0x4000945e) */
"	bne.s	1f\n"
"4:	jmp	0x40009572\n"
"1:	move.l	(0,%a1,%a0.l*4),%d5\n"         /* displaced, verbatim */
"	clr.l	%d4\n"
"	jmp	0x4000945a\n"
/* amp-halves: 0x400090d8 (movel #5674,%d2), the loader's 0x80 0x80 fine slot once its context is valid (d0 the index,
   d1 the track, a2 the slot, a3 the live locks; d0 / d1 stay the context, as stock keeps them). A voice track's index 0
   goes to sfx_lock_merge, then the next slot (0x40009128); everything else on to stock's OR loop (0x400090de). */
"	.globl	sfx_fine\n"
"sfx_fine:\n"
"	tst.l	%d0\n"
"	bne.s	1f\n"
"	moveq	#12,%d2\n"
"	cmp.l	%d1,%d2\n"
"	beq.s	1f\n"
"	move.l	%d0,-(%sp)\n"
"	move.l	%d1,-(%sp)\n"
"	move.l	%d1,-(%sp)\n"
"	move.l	%a3,-(%sp)\n"
"	move.l	%a2,-(%sp)\n"
"	jsr	sfx_lock_merge\n"
"	lea	12(%sp),%sp\n"
"	move.l	(%sp)+,%d1\n"
"	move.l	(%sp)+,%d0\n"
"	jmp	0x40009128\n"
"1:	move.l	#5674,%d2\n"                     /* displaced, verbatim */
"	jmp	0x400090de\n"
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
"	jmp	0x40007f92\n"
/* 0x40120968 (movew %a0@,%d6; movew %a0@(4),%d4), the trig loop's lock list loop (a0 the entry, a1 0x8000e57c, a5
   0x80005f10, d1 the count left, d0 the list's count; d4 d6 d7 a3 scratch of the body): reimplemented, rejoining at
   0x4012096e. Bit 0 clear (every stock value: an 8.8 lock's bit 0 is 0) goes straight on; set: sfx_play_c rewrites an
   FX 38..41 half lock, then d4 again. */
"	.globl	sfx_play\n"
"sfx_play:\n"
"	move.w	(%a0),%d6\n"
"	move.w	4(%a0),%d4\n"
"	btst	#0,%d4\n"
"	bne.s	1f\n"
"	jmp	0x4012096e\n"
"1:	lea	-16(%sp),%sp\n"
"	movem.l	%d0-%d1/%a0-%a1,(%sp)\n"
"	move.l	%a0,-(%sp)\n"
"	jsr	sfx_play_c\n"
"	addq.l	#4,%sp\n"
"	movem.l	(%sp),%d0-%d1/%a0-%a1\n"
"	lea	16(%sp),%sp\n"
"	move.w	4(%a0),%d4\n"
"	jmp	0x4012096e\n");
