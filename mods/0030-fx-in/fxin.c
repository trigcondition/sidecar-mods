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
 *
 * Also the mix report for the Sidecar's through mode (host-link 50, design.md "The mix report"): each voice stem's pan
 * and who is off ROUTE TO MAIN, from fxin_tick. Reads only.
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
"	tst.l	0x413db244\n"                      /* the sender's SysEx state clear: note it (try_send's bound) */
"	bne.s	3f\n"
"	moveq	#1,%d0\n"
"	move.l	%d0,fxin_txsx_gap\n"
"3:	move.l	0x401b9e64,%d0\n"
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
 * the port configured, no stock SysEx under way, a try-lock of the MIDI mutex (0x4000119c never pends),
 * the ring's room and four free USB requests, else not now (the next tick tries again).
 * 0.5.0 (design.md "No report inside a stock dump"): a stock dump (pattern / kit / sound / song) gives the
 * mutex back between its parts while the sender's SysEx state 0x413db244 stays set; a 27 or 50 sent then
 * lands inside the dump and cuts it. So, as 0026's send() (1052d): not while it is set, tested before the
 * try-lock and again holding it, with 0026's 2 s bound (txsx_wait, below). */
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
#define TX_SYSEX    (*(const volatile uint32_t *)0x413db244u)   /* the sender's SysEx state (0026's TX_SYSEX) */

static struct {
  uint16_t seen;    /* the last FXIN_REQ answered */
  uint8_t init;
  uint8_t was_up;   /* the port was configured at the last tick */
  uint8_t tell;     /* a report owed without an ask: the port came up */
  uint8_t quiet;    /* ticks since the last 50 */
  uint8_t mix[10];  /* the last 50's bytes */
  uint32_t ticks, tx_t0, tx_on, tx_over;   /* fxin_tick's count; try_send's SysEx wait (fix round 1) */
} st __attribute__((section(".bss")));
/* The SysEx wait's bound, as 0026's txsx_wait (1052d rounds 5 / 6): the flag seen set at every look for TXSX_TICKS
 * (a dump cut by a port reset could leave it set) and the report goes anyway (tx_over counts those). fxin_ob, in the
 * audio interrupt (1500 a second), notes any moment the flag is clear (fxin_txsx_gap), which restarts the count: a
 * long transfer of back-to-back stock messages (a SONG / C6) is waited out whole, only a flag that stays set runs it out. */
#define TXSX_TICKS 40                 /* 2 s of the 20 Hz tick */
volatile uint32_t fxin_txsx_gap __attribute__((section(".bss")));

static int32_t txsx_wait(void) {
  if (!TX_SYSEX) { st.tx_on = 0; fxin_txsx_gap = 0; return 0; }
  if (!st.tx_on || fxin_txsx_gap) { st.tx_on = 1; st.tx_t0 = st.ticks; fxin_txsx_gap = 0; }
  if ((int32_t)(st.ticks - st.tx_t0) < TXSX_TICKS) return 1;
  st.tx_over++;
  return 0;
}

static int32_t try_send(const uint8_t *m, int32_t n) {
  const volatile uint32_t *h;
  int32_t k;
  if (PORT_STATE != 1 || txsx_wait()) return 0;
  if (!MUTEX_TRY(MIDI_MUTEX)) return 0;
  h = USB_POOL;
  for (k = 0; k < 4 && h; ++k) h = (const volatile uint32_t *)h[13];
  if (txsx_wait() || TX_LEVEL + 64 > 4091 || k < 4) {
    MUTEX_GIVE(MIDI_MUTEX);
    return 0;
  }
  MIDI_SEND(n, m);
  MUTEX_GIVE(MIDI_MUTEX);
  return 1;
}

/* The mix report: F0 7D 52 54 50 <pan 0..7> <route bit 7> <route bits 0..6> F7 to the USB host, on a change and once a second
 * (a host that restarted learns it). Stem s is physical voice stem_voice[s] (IN 2..9: BD SD RS/CP BT LT MT/HT CH/OH CY/CB);
 * its pan is that voice's owning track's word 38 of the modulated copy, p-locks, slides and the LFO included, rounded as
 * the unreleased 0024-ob-mix's mix CCs (measured there). The route byte: a set bit, that voice off the main bus, packed
 * from physical voices 7,6,5,4,0,1,2,3 MSB first (re/subsystems/compressor-hardware.md); the host unpacks it. */
extern const volatile int16_t lfo_track_array[];
#define W_PAN        38
#define TRACK_WORDS  42
#define OWNER(v)     (((const volatile uint8_t *)0x40290dd8u)[v])
#define ROUTE_BYTE   (*(const volatile uint8_t *)0x80006466u)
#define MIX_EVERY    20          /* ev_tick is about 20 Hz */
static const uint8_t stem_voice[8] = {0, 2, 7, 1, 3, 5, 4, 6};

static void mix_tick(void) {
  uint8_t m[16], b[10];
  int32_t i, changed = st.quiet >= MIX_EVERY;
  for (i = 0; i < 8; ++i) {
    int32_t v = lfo_track_array[OWNER(stem_voice[i]) * TRACK_WORDS + W_PAN];
    v = v < 0 ? 0 : (v + 0x80) >> 8;
    b[i] = (uint8_t)(v > 127 ? 127 : v);
  }
  b[8] = ROUTE_BYTE >> 7;
  b[9] = ROUTE_BYTE & 0x7f;
  m[0] = 0xf0, m[1] = 0x7d, m[2] = 0x52, m[3] = 0x54, m[4] = 0x50, m[15] = 0xf7;
  for (i = 0; i < 10; ++i) {
    changed |= b[i] != st.mix[i];
    m[5 + i] = b[i];
  }
  if (st.quiet < 255) ++st.quiet;
  if (changed && try_send(m, 16)) {
    for (i = 0; i < 10; ++i) st.mix[i] = b[i];
    st.quiet = 0;
  }
}

/* ev_tick (core-ar2, the UI loop): answer a 26 with 27, and send a 27 once each time the USB port comes
 * up (a host that connects learns the state unasked); back to off (AUDIO IN) when the port goes down,
 * so a host that left, or another host (a DAW's Overbridge), never finds the FX on its IN L/R without
 * asking for it. */
void fxin_tick(void *ctrl) {
  uint16_t r = FXIN_REQ;
  int32_t up = PORT_STATE == 1;
  (void)ctrl;
  st.ticks++;
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
  if (up) mix_tick();
}
