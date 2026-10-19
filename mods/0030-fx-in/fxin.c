/* Mod 0030 - FX in: the Rytm's delay + reverb return on Overbridge IN L/R (channels 10/11) in place of
 * AUDIO IN, switched at run time by the USB host (host-link 26), state reported back (27). design.md.
 *
 * Code in elekloader's DDR area (build.sh, mod.toml area = "elek"). Every address is OS 1.73's; the
 * named ones come from re/symbols.toml through symbols.inc (build.py's), which elekloader links.
 *
 * The switch lives in cave23's last 6 B (registry, 0030's claim), written by 0022's router (fxin=1) in
 * the MIDI task when the host sends F0 7D 52 54 26 <v> F7:
 *   0x401b9e64  u32  'FXI1' (0x46584931) on, 'FXI0' off; anything else (stock's dead code bytes at
 *                    boot, 4a816ed8) is off, so the image boots with AUDIO IN on 10/11 as stock.
 *   0x401b9e68  u16  bumped by the router on every 26 (an ask too): fxin_tick answers with 27.
 * Aligned long / word stores, one writer each in the MIDI task (the router) - plus fxin_tick's reset to
 * off when the port is down, when no host can be sending.
 */
#include <stdint.h>

#define FXIN_WORD  (*(volatile uint32_t *)0x401b9e64u)
#define FXIN_REQ   (*(volatile uint16_t *)0x401b9e68u)
#define FXIN_ON    0x46584931u   /* 'FXI1' */
#define FXIN_OFF   0x46584930u   /* 'FXI0' */

/* fxin_ob - called in place of ob_in_write(rx_buffer, 0, 32) at both of its callers in the audio
 * interrupt's block driver (jsr operands 0x4012144e and 0x4011fe0a, from_symbol patches). Off (the
 * word is not 'FXI1'): a compare and a jump, stock's call unchanged. On: 0024-ob-mix's obfx_in loop
 * (rytm-mods ob-fx f01cdbb, measured there): this block's fx_generate has run, so fx_delay_out /
 * fx_reverb_out hold this block's returns, and 0x4009ef40 (sampler / meters) has already read the
 * buffer, so only the USB copy changes. Words 10/11 of each of the 32 frames become
 * gd * delay + 2 gr * reverb per side, Q31 x Q31 in EMAC fractional mode, saturating (MACSR 0xa0);
 * gd / gr the PRE + POST return gain targets (the router 0x4010e8a0 zeroes the bank an effect is not
 * in); the 2: both stock return mixers MAC the reverb sample twice per side [code, 0024 research.md].
 * Interrupt context: d0/d1/a0/a1 free (a call clobbers them), d2-d4 saved, MACSR saved and put back
 * exactly, the accumulators cleared on entry and left clear. ~534 instructions a block when on. */
__asm__(
"	.text\n"
"	.align	2\n"
"	.globl	fxin_ob\n"
"	.if	fx_reverb_out != fx_delay_out - 256\n"
"	.error	\"fxin_ob reads the reverb at fx_delay_out - 256\"\n"
"	.endif\n"
"fxin_ob:\n"
"	move.l	0x401b9e64,%d0\n"
"	cmp.l	#0x46584931,%d0\n"
"	bne.w	2f\n"
"	lea	-12(%sp),%sp\n"
"	movem.l	%d2-%d4,(%sp)\n"
"	move.l	%macsr,%d4\n"
"	move.l	#0xa0,%macsr\n"
"	movclr.l %acc0,%d0\n"
"	movclr.l %acc1,%d0\n"
"	move.l	fx_return_gain_pre,%d1\n"
"	add.l	fx_return_gain_post,%d1\n"        /* gd */
"	move.l	fx_return_gain_pre+4,%d2\n"
"	add.l	fx_return_gain_post+4,%d2\n"      /* gr */
"	lea	fx_delay_out,%a0\n"                /* the reverb's buffer is at -256 */
"	lea	0x80007440+40,%a1\n"               /* rx_buffer (image = hardware, not in symbols.inc): frame 0, word 10 */
"	moveq	#32,%d3\n"
"1:	move.l	(%a0),%d0\n"                      /* delay L */
"	mac.l	%d0,%d1,-256(%a0),%d0,%acc0\n"      /* gd * delay L; load reverb L */
"	mac.l	%d0,%d2,%acc0\n"                   /* gr * reverb L */
"	mac.l	%d0,%d2,4(%a0),%d0,%acc0\n"        /* again, as stock's mixers do; load delay R */
"	mac.l	%d0,%d1,-252(%a0),%d0,%acc1\n"     /* gd * delay R; load reverb R */
"	mac.l	%d0,%d2,%acc1\n"                   /* gr * reverb R, twice */
"	mac.l	%d0,%d2,%acc1\n"
"	addq.l	#8,%a0\n"
"	movclr.l %acc0,%d0\n"
"	move.l	%d0,(%a1)+\n"                      /* word 10 */
"	movclr.l %acc1,%d0\n"
"	move.l	%d0,(%a1)\n"                       /* word 11 */
"	lea	44(%a1),%a1\n"                     /* the next frame's word 10 (48 B a frame) */
"	subq.l	#1,%d3\n"
"	bne.s	1b\n"
"	move.l	%d4,%macsr\n"
"	movem.l	(%sp),%d2-%d4\n"
"	lea	12(%sp),%sp\n"
"2:	jmp	ob_in_write\n");                   /* its three arguments are still on the stack */

/* The report: F0 7D 52 54 27 <on> F7 to the USB host. Never waits (the UI task): 0029's try_send -
 * the port configured, a try-lock of the MIDI mutex (0x4000119c never pends), the ring's room and four
 * free USB requests, else not now (the next tick tries again). */
typedef void (*send_fn)(int32_t n, const uint8_t *m);
typedef int32_t (*trylock_fn)(void *m);
typedef void (*unlock_fn)(void *m);
#define MIDI_SEND   ((send_fn)0x400029e0u)
#define MIDI_MUTEX  ((void *)0x42f67a28u)
#define MUTEX_TRY   ((trylock_fn)0x4000119cu)
#define MUTEX_GIVE  ((unlock_fn)0x400011eeu)
#define PORT_STATE  (*(volatile uint32_t *)0x413db254u)
#define TX_LEVEL    (*(volatile int32_t *)0x413db258u)
#define USB_POOL    (*(const volatile uint32_t *const volatile *)0x413db390u)

static struct {
  uint16_t seen;    /* the last FXIN_REQ answered */
  uint8_t init;
  uint8_t was_up;   /* the port was configured at the last tick */
  uint8_t tell;     /* a report owed without an ask: the port came up */
} st __attribute__((section(".bss")));

static int32_t try_send(const uint8_t *m, int32_t n) {
  const volatile uint32_t *h;
  int32_t k;
  if (PORT_STATE != 1) return 0;
  if (!MUTEX_TRY(MIDI_MUTEX)) return 0;
  h = USB_POOL;
  for (k = 0; k < 4 && h; ++k) h = (const volatile uint32_t *)h[13];
  if (TX_LEVEL + 64 > 4091 || k < 4) {
    MUTEX_GIVE(MIDI_MUTEX);
    return 0;
  }
  MIDI_SEND(n, m);
  MUTEX_GIVE(MIDI_MUTEX);
  return 1;
}

/* ev_tick (core-ar2, the UI loop): answer a 26 with 27, and send a 27 once each time the USB port comes
 * up (a host that connects learns the state unasked); back to off (AUDIO IN) when the port goes down,
 * so a host that left, or another host (a DAW's Overbridge), never finds the FX on its IN L/R without
 * asking for it. */
void fxin_tick(void *ctrl) {
  uint16_t r = FXIN_REQ;
  int32_t up = PORT_STATE == 1;
  (void)ctrl;
  if (!st.init) {           /* the word at boot: stock's bytes, i.e. off; nothing asked yet */
    st.seen = r;
    st.init = 1;
  }
  if (st.was_up && !up && FXIN_WORD == FXIN_ON) FXIN_WORD = FXIN_OFF;
  if (!st.was_up && up) st.tell = 1;
  st.was_up = (uint8_t)up;
  if (r != st.seen || st.tell) {
    uint8_t m[7] = {0xf0, 0x7d, 0x52, 0x54, 0x27, 0, 0xf7};
    m[5] = FXIN_WORD == FXIN_ON;
    if (try_send(m, 7)) {
      st.seen = r;
      st.tell = 0;
    }
  }
}
