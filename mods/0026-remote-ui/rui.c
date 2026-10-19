/*
 * 0026-remote-ui: the Rytm as a dumb terminal for pages the Sidecar draws (milestone M1).
 * rytm-teensy docs/superpowers/specs/2026-10-16-remote-ui-research.md; design.md here.
 *
 * Code in elekloader's DDR area (area = "elek"), on core-ar2's events only - no patch site of its own:
 *   ev_tick (UI task, 20 Hz): enter/leave, the 1 s timeout, reports out (coalesced encoder turns), and a
 *           redraw request when the Sidecar committed a new frame;
 *   ev_draw (after the stock drawAll, before the panel diff): in remote mode the 1 KB shadow over the canvas,
 *           so the stock double-buffer diff sends only the tiles that changed;
 *   ev_key / ev_enc: in remote mode the keys and encoders the Sidecar's catch mask (37) names go to it (31 / 32), the
 *           rest to stock as on the stock screen; PLAY, STOP and RECORD always to stock, TRK + YES always 0026's; a
 *           key's owner is taken at its press, so its release goes to the same side (also across a new mask and leaving).
 *           Before any 37 (and for a host that never sends one): every key and encoder caught but the transport.
 * 1023, the connect splash: when the USB port comes up 0026 says hello (35, with its uptime); a host that wants to
 *           greet sends a frame and 36 <ticks>, and the screen shows it for that long while every key and knob stays
 *           stock's (none goes to the host); a navigation key or another non-playing key or a turn ends it early,
 *           transport and pads play under it. Never while the page is open.
 * Host -> Rytm through 0022's SysEx router (rui=1): 0x30..0x3F -> the 8 B mailbox 'RUIP' at 0x401b9e5c.
 *
 * Messages (F0 7D 52 54 <cmd> <ver 1> ... F7; rytm-teensy sim/protocol.py):
 *   host -> Rytm  38 1 <seq> <col0 0..15> <page0 0..7> <ncols 1..16> <npages 1..8> <packed>   a rectangle of
 *                      framebuffer bytes (column-major, byte = page + 8 x column) into staging
 *                 39 1 <seq>          commit: staging -> shadow (if seq is the last 38's)
 *                 3A 1 <page> <on>    open (on 1) / close (0) remote mode
 *                 3C 1                keepalive (every valid 3x counts)
 *                 37 1 <e0> <e1> <e2> <k0 .. k36>   1022: the catch mask; encoder i caught: bit i % 7 of e(i / 7)
 *                      (0..15), key code c caught: bit c % 7 of k(c / 7) (0..255; keys past the last byte sent: passed)
 *                 36 1 <ticks 0..127>   1023: show the last committed frame as a splash for ticks x 50 ms (0: end it)
 *                 34 1 <mode> [<c1> .. <c16>]   1026: the trig keys' LEDs while the page is open: mode 0 stock's,
 *                      1 the host's, c the palette colour 0..111 of T1..T16 (below, "1026")
 *   Rytm -> host  30 1 <page> <on> <reason 0 user, 1 host, 2 timeout, 3 local escape>   1026: page, the page to show
 *                      on an open: 0 the host's default (SIDECAR), 1 LFO (TRK + LFO; again while open: go there)
 *                 31 1 <code >> 7> <code & 0x7f> <down>   (the firmware's key code, e.g. TRK 0x86 = 1 6)
 *                 32 1 <encoder> <delta + 64> <func>
 *                 35 1 <uptime >> 7> <uptime & 0x7f> <caps>   1023: hello, 0.5 s after the USB port came up (again
 *                      1 s and 2 s later while no valid host message came): uptime in ticks since 0026 started
 *                      (saturated at 16383), caps bit 0: 36 understood
 *                 3B 1 <kit 0..127>   1026: the active kit, after the snapshot of each 35 and each open, and when it
 *                      changes
 *                 33 1 <t0> <n> {<machine> <vb>} x n   1025: the tracks' machines (a change: n 1; the snapshot: t0 0,
 *                      n 12, when the page opens and with each 35); vb 0021's voice byte or 0x7F (below, "1025")
 * packed: groups of up to 7 bytes, each a byte of their MSBs (bit i = byte i's bit 7) then the 7 low parts.
 *
 * Tasks: rui_sysex runs in the MIDI task and is the only writer of staging and the shadow (seqlock: odd while
 * copying); everything else runs in the UI task. Nothing here waits: reports go out only through a try-lock of
 * the USB MIDI mutex, with the sender's own wait conditions checked first; otherwise they wait for the next tick
 * (keys in a small queue, turns summed) and the UI goes on.
 */
#include <stdint.h>

typedef void (*send_fn)(int32_t len, const uint8_t *data);
typedef int32_t (*trylock_fn)(void *m);
typedef void (*unlock_fn)(void *m);
#define MIDI_MUTEX   ((void *)0x42f67a28u)          /* what MIDI_LOCK 0x40002914 / UNLOCK 0x40002924 pass   */
#define MUTEX_TRY    ((trylock_fn)0x4000119cu)      /* owner 0 -> current task, 1; else 0 (no wait)         */
#define MUTEX_GIVE   ((unlock_fn)0x400011eeu)       /* MIDI_UNLOCK's callee                                  */
#define MIDI_SEND    ((send_fn)0x400029e0u)
#define PORT_STATE   (*(volatile uint32_t *)0x413db254u)   /* 1: configured (the sender's first test)      */
#define TX_LEVEL     (*(volatile int32_t *)0x413db258u)    /* the sender spins while level + n > 4091      */
#define USB_POOL     (*(const volatile uint32_t *const volatile *)0x413db390u)  /* free requests, next +52 */
#define TIMER        (*(volatile uint32_t *)0xfc07000cu)   /* DTCN0, the OS's free-running bus-clock count  */
#define MBOX         ((volatile uint32_t *)0x401b9e5cu)    /* 'RUIP', rui_sysex                             */
/* The Rytm's own text drawing, called at runtime (nothing of it copied): text_draw 0x400714e0 (bitmap, font, x, y,
   align 0 left / 1 centre / 2 right, box 0 none / 1 inverted, width string, fmt, ...) [code + measured, design.md
   section 9], as 0029's enum knobs and stock's PRE / POST draw call it; the font from text_font(ctx) 0x40071b7c, ctx
   one of the 17 font objects at 0x417e381c + 8 i (vtable, font data; set up at boot by 0x4018947a) [code]; a bitmap
   over our own 1 KB by bitmap_ctor 0x4006f9c2 (bitmap, w, h, pixels, mask) [code], the stock canvas's geometry. */
typedef void (*tdraw_fn)(void *bmp, void *font, int32_t x, int32_t y, int32_t align, int32_t box, const char *w,
                         const char *fmt, ...);
typedef void *(*font_fn)(void *ctx);
typedef void (*bmctor_fn)(void *bmp, int32_t w, int32_t h, void *pixels, void *mask);
#define TEXT_DRAW    ((tdraw_fn)0x400714e0u)
#define TEXT_FONT    ((font_fn)0x40071b7cu)
#define BITMAP_CTOR  ((bmctor_fn)0x4006f9c2u)
#define FONT_CTX(i)  ((void *)(0x417e381cu + 8u * (uint32_t)(i)))
#define NFONT  17
#define NTXT   64                                   /* text slots (3D) */
#define TXTLEN 32
#define NBIND  16                                   /* encoders with a local echo (3F) */
#define ECHO_TICKS 8                                /* a local echo holds 400 ms after its last turn */

#define K_TRK  0x86
#define K_FUNC 0x80
#define K_REC  0x50       /* RECORD 0x50, PLAY 0x51, STOP 0x52 [measured, rytm-emu panel.rs RYTM_KEYS] */
#define K_STOP 0x52
#define K_LFO  0x35       /* 1026: LFO [measured: panel.rs RYTM_KEYS; stock 1.73's TRK + LFO = LFO alone, rytm-emu] */
#define PG_LFO 1          /* 30's page: the Sidecar's LFO page */
#define LED_MUTEX ((void *)0x41920560u)   /* led_set 0x40095d2c / led_colour 0x40095f54 lock it around their sends */
#define LED_NCOL  112     /* 34's colours: palette 0..111 (the OS animates 0x74..0x78 [measured]); 112.. refused */
#ifndef ENC_IDX_OFF
#define ENC_IDX_OFF 12    /* [measured] --turn 2:-3: +12 = 2, +16 = -3, +8 a time stamp, +20 FUNC */
#define ENC_DELTA_OFF 16
#endif
#ifndef K_YES
#define K_YES  0x44       /* [measured] YES 0x44, NO 0x45 (key event +12) */
#endif
#define NENC   16
#define NKQ    16
#define TIMEOUT_TICKS 20                            /* 1 s of the 20 Hz tick without a host message */
#define HELLO_TICKS 10                              /* 35 this long after the port came up (the host reads by then) */
#define K_NAV0 0x40       /* LEFT RIGHT UP DOWN YES NO 0x40..0x45 */
#define K_NAV1 0x45
#define K_PAD0 0x90       /* the 12 pads 0x90..0x9b */
#define K_PAD1 0x9b

enum { R_USER, R_HOST, R_TIMEOUT, R_ESCAPE };
enum { S_TIME = 1, S_HOST, S_IDLE, S_KEY, S_ENC, S_OPEN };   /* why the splash ended */

static uint8_t shadow[1024] __attribute__((aligned(4)));
static uint8_t staging[1024] __attribute__((aligned(4)));
static uint8_t comp[1024] __attribute__((aligned(4)));      /* UI task: the shadow with the text drawn over it */

/* A text slot (3D): glass x, top y, font 0..16, flags (bits 0-1 align, bit 2 inverted), len, the characters. */
struct txt { uint8_t x, y, font, flags, len, pad[3]; char s[TXTLEN + 4]; };   /* 44 B */
static struct txt txt_st[NTXT] __attribute__((aligned(4)));    /* MIDI task: staging */
static struct txt txt_sh[NTXT] __attribute__((aligned(4)));    /* committed with the shadow (same seqlock) */
/* An encoder's local echo (3F): the slot it writes, the value, range, flags (bit 0 FUNC x 8, bit 1 shown -64..63),
   the prefix. Written by the MIDI task under gen (odd while writing). */
struct bind { uint8_t slot, value, lo, hi, flags, plen; char pre[14]; };   /* 20 B */
static struct bind bind_in[NBIND] __attribute__((aligned(4)));
static volatile uint32_t bind_gen[NBIND] __attribute__((aligned(4)));

/* MIDI task -> UI task */
static volatile uint32_t sh_seq __attribute__((aligned(4)));      /* seqlock over shadow: odd while the MIDI task copies */
static volatile uint32_t commits __attribute__((aligned(4)));     /* frames committed */
static volatile uint32_t rx __attribute__((aligned(4)));        /* valid host messages */
static volatile uint32_t rx_bad __attribute__((aligned(4)));      /* malformed / out of range */
static volatile uint8_t host_open, host_close;
static volatile uint32_t t_commit __attribute__((aligned(4)));    /* TIMER at the last commit */
static uint8_t st_seq, st_valid;      /* MIDI task only: the 38s' seq since the last commit */
static uint32_t mt_sum, mt_max, mt_calls;   /* MIDI task: TIMER counts inside rui_sysex */
/* 1022: the catch mask (37), written by the MIDI task word by word (a key's decision reads one word); mask_set 0: none
   yet (the default: everything caught but the transport) - cleared again when the page leaves by the timeout. */
static volatile uint32_t mask_keys[8] __attribute__((aligned(4)));
static volatile uint32_t mask_enc __attribute__((aligned(4)));
static volatile uint32_t mask_set __attribute__((aligned(4)));
static volatile uint32_t masks __attribute__((aligned(4)));        /* 37s taken */
/* 1023: a 36 for the UI task: 0x100 | ticks (one word: the newest wins) */
static volatile uint32_t splash_req __attribute__((aligned(4)));

/* 1026: the host's 34 for the UI task (seqlock: led_gen odd while the MIDI task writes) */
static volatile uint32_t led_gen __attribute__((aligned(4)));
static volatile uint8_t led_req_mode, led_req[16];

/* UI task */
struct rui {
  uint32_t init, active, ticks, idle, rx_seen, shown, enter_commits;
  uint32_t blits, torn, tx_ok, tx_busy, tx_drop, enters, leaves;
  uint32_t t_blit, lat_commit_blit, t_enc, lat_enc_report;   /* TIMER stamps (bus clocks) */
  uint32_t last_key, last_enc[5];                            /* the last raw events (diagnostics) */
  int32_t acc[NENC];
  uint8_t func, pend_open, pend_reason, pend_on;
  uint8_t kq[NKQ][2];
  uint32_t kq_n;
  uint32_t stock_down[8], our_down[8], eat[8];   /* key code bitmaps: whose release goes where */
  uint32_t last_reason, t_tick;      /* t_tick: TIMER at the last tick (calibration) */
  uint32_t cb_sum, cb_n, cb_max, er_sum, er_n, er_max;   /* commit -> blit, first turn -> report (TIMER) */
  uint32_t ui_sum, ui_max, ui_calls;   /* TIMER counts inside the UI-task entries (ISRs included: upper bounds) */
  /* 1021: text and the local echo (after the fields rui_emu.py reads by offset) */
  uint32_t composed, need_comp, comps, texts_drawn, comp_sum, comp_max;   /* commits composed; TIMER inside compose */
  uint32_t echoes, t_echo, ee_sum, ee_n, ee_max;   /* turns echoed; turn -> the blit showing it (TIMER) */
  uint32_t enc_sent_now;                           /* turns reported at the event (not at the next tick) */
  uint32_t t_e2e, e2e_c, e2e_sum, e2e_n, e2e_max;  /* a turn -> the first blit of a frame committed after it */
  uint32_t echo_until[NBIND];                      /* tick until which the echo holds (0: none) */
  uint8_t echo_val[NBIND];
  uint32_t echo_gen[NBIND];                        /* bind_gen copied into echo_bind */
  struct bind echo_bind[NBIND] __attribute__((aligned(4)));
  uint32_t bm[8];                                  /* the bitmap over comp (28 B, bitmap_ctor) */
  /* 1022 (after every field the tests read by offset) */
  uint32_t both_down[8];                           /* a caught FUNC: stock's and the host's */
  uint32_t k_caught, k_passed, k_transport, e_caught, e_passed;   /* presses / turns by where they went */
  /* 1023: the connect splash (after every field the tests read by offset) */
  uint32_t port_ticks, hello_n, hello_rx, hellos;  /* ticks the port is up; 35s queued and sent; rx at the first */
  uint32_t splash_on, splash_left, splashes, splash_ignored, splash_why;
  uint8_t pend_hello;
  /* 1026 (after every field the tests read by offset) */
  uint8_t pend_page;
  uint32_t lfo_opens, lfo_hints;                   /* TRK + LFO: opened on the LFO page; sent again while open */
  uint32_t led_seen, led_want, led_paints, led_restores, led_busy;   /* the host's 34 (gen), applied, try-lock misses */
  uint8_t led_col[16];
};
static struct rui st __attribute__((aligned(4)));

#define BIT(m, k) ((m)[(k) >> 5] & (1u << ((k) & 31)))
#define SET(m, k) ((m)[(k) >> 5] |= (1u << ((k) & 31)))
#define CLR(m, k) ((m)[(k) >> 5] &= ~(1u << ((k) & 31)))

static void copy32(uint32_t *d, const volatile uint32_t *s, int32_t n) {
  while (n-- > 0) *d++ = *s++;
}

/* ---- out: never waits ------------------------------------------------------------------------------ */
static int32_t usb_free(int32_t n) {
  const volatile uint32_t *h = USB_POOL;
  while (n-- > 0) {
    if (!h) return 0;
    h = (const volatile uint32_t *)h[13];
  }
  return 1;
}

/* 1 sent; 0 not now (the port, the mutex, the ring or the request pool) - the caller keeps it for later */
static int32_t send(const uint8_t *m, int32_t n) {
  if (PORT_STATE != 1) return 0;   /* the sender returns at once on its own tests (this, 0xfc0b01c4) */
  if (!MUTEX_TRY(MIDI_MUTEX)) { st.tx_busy++; return 0; }
  if (TX_LEVEL + 64 > 4091 || !usb_free(4)) {
    MUTEX_GIVE(MIDI_MUTEX);
    st.tx_busy++;
    return 0;
  }
  MIDI_SEND(n, m);
  MUTEX_GIVE(MIDI_MUTEX);
  st.tx_ok++;
  return 1;
}

static int32_t send3(uint8_t cmd, uint8_t a, uint8_t b, uint8_t c) {
  uint8_t m[10] = {0xf0, 0x7d, 0x52, 0x54, cmd, 0x01, a, b, c, 0xf7};
  return send(m, 10);
}

static void flush(void) {
  uint32_t i, k;
  if (st.pend_hello) {
    uint32_t up = st.ticks < 16383 ? st.ticks : 16383;
    if (!send3(0x35, (uint8_t)(up >> 7), (uint8_t)(up & 0x7f), 1)) return;
    st.pend_hello = 0;
    st.hellos++;
  }
  if (st.pend_open) {
    uint8_t m[10] = {0xf0, 0x7d, 0x52, 0x54, 0x30, 0x01, st.pend_page, st.pend_on, st.pend_reason, 0xf7};
    if (!send(m, 10)) return;    /* in order: 30 before the keys and turns after it */
    st.pend_open = 0;
  }
  for (k = 0; k < st.kq_n; ++k)
    if (!send3(0x31, st.kq[k][0] >> 7, st.kq[k][0] & 0x7f, st.kq[k][1])) break;
  for (i = k; i < st.kq_n; ++i) { st.kq[i - k][0] = st.kq[i][0]; st.kq[i - k][1] = st.kq[i][1]; }
  st.kq_n -= k;
  if (st.kq_n) return;
  for (i = 0; i < NENC; ++i) {
    int32_t d = st.acc[i];
    if (!d) continue;
    if (d > 63) d = 63;
    if (d < -63) d = -63;
    if (!send3(0x32, (uint8_t)i, (uint8_t)(d + 64), st.func)) return;
    st.acc[i] -= d;
    if (st.t_enc) {
      uint32_t l = TIMER - st.t_enc;
      st.lat_enc_report = l;
      st.er_sum += l; st.er_n++;
      if (l > st.er_max) st.er_max = l;
      st.t_enc = 0;
    }
  }
}

static void report_mode(uint8_t on, uint8_t reason, uint8_t page) {
  st.last_reason = (uint32_t)on << 8 | reason;
  st.pend_open = 1; st.pend_on = on; st.pend_reason = reason;   /* the newest replaces an unsent one */
  st.pend_page = page;
}

static void queue_key(uint32_t code, uint32_t down) {
  if (st.kq_n >= NKQ) { st.tx_drop++; return; }
  st.kq[st.kq_n][0] = (uint8_t)code;
  st.kq[st.kq_n][1] = (uint8_t)(down ? 1 : 0);
  st.kq_n++;
}

/* ---- mode ------------------------------------------------------------------------------------------- */
/* ---- 1025: the tracks' machines, for the Sidecar's voice pages -----------------------------------------------
 * Rytm -> host  33 1 <t0> <n> {<machine> <vb>} x n   track t0 + i is set to `machine` (0..52: the active kit's sound
 *               of the track, as its SRC page shows it; the SRC list's preview (the cursor, before YES), its YES / NO,
 *               a kit, sound or project load all move it [measured, rytm-emu rui1025]); vb the voice byte its 0021
 *               03 / 04 reports carry (voice | 0021's machine flag), or 0x7F: not a Sidecar machine.
 *               n = 1: one track changed; t0 = 0, n = 12: the snapshot - when the page opens (TRK + YES or the host's
 *               3A), with each hello (35: the port came up), and when more than one track changed in one tick.
 * Polled every tick (20 Hz, ~12 byte compares), sent through the same try-lock as the rest: a change goes out at the
 * next tick, or the tick after while the sender is busy (the shadow keeps what the host was last told). */
/* the active kit's sound of track t, its machine byte: kit k's sound at 0x4125590d + 2531 k + 152 t (the trig's copy
   source, 0x40120670), +104 the machine [measured, rytm-emu rui1025: kit 0 / kit 1's BD 0x15 / 0x1c there, and the
   SRC list's preview writes it as it does the live byte 0x8000ea00, which a kit load only moves at the track's next
   trig]; the active kit 0x800067b8 (an int, <= 127) */
#define ACTIVE_KIT    (*(const volatile uint32_t *)0x800067b8u)
#define MACHINE_OF(t) (*(const volatile uint8_t *)(0x4125590du + 2531u * (ACTIVE_KIT & 127u) + 152u * (uint32_t)(t) + 104u))
#define ENGINE(m)     (((const volatile uint32_t *)0x4029037cu)[m])   /* machine_engine_table */
/* track -> voice, 1027: the voice owner table 0x40290dd8 (voice v's track) = 00 04 01 05 08 06 0a 02 [measured], so BD 0,
   SD 2, RS/CP 7, BT 1, LT 3, MT/HT 5, CH/OH 4, CY/CB 6 (1025's table was the panel order, wrong for SD..CY) */
static const uint8_t mr_voice[12] = {0, 2, 7, 7, 1, 3, 5, 5, 4, 4, 6, 6};   /* BD SD RS CP BT LT MT HT CH OH CY CB */
/* 0021's voice flags (ext.c us_flag_tab, machines 35..51; 0x7F: not one of its machines there) */
static const uint8_t mr_flag[17] = {0x50, 0x58, 0x60, 0x68, 0x70, 0x48, 0x08, 0x40, 0x7f, 0x00, 0x20,
                                    0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x10};
static struct {
  uint8_t m[12];       /* the machine the host was last told (or the boot's) */
  uint8_t init, all;   /* all: a snapshot owed */
  uint16_t sent1, sentall;   /* reports sent (diagnostics) */
  uint8_t kit, kit_owed;     /* 1026: the kit the host was last told (3B); a 3B owed (hello, open) */
  uint16_t kits;             /* 3Bs sent */
} mr __attribute__((section(".bss"), aligned(4)));

/* A Sidecar machine: 0021's ext_render in the machine's engine entry (machine 44, PLAITS, is one in every 0021 build;
   35..39 only with its user slots, else 0020's) */
static uint8_t mr_vb(int32_t t, uint32_t m) {
  uint8_t f;
  if (m < 35 || m > 51 || ENGINE(m) != ENGINE(44)) return 0x7f;
  f = mr_flag[m - 35];
  return f == 0x7f ? 0x7f : (uint8_t)(mr_voice[t] | f);
}

static int32_t mr_send(int32_t t0, int32_t n, const uint8_t *cur) {
  uint8_t b[33];
  int32_t i, k = 0;
  b[k++] = 0xf0; b[k++] = 0x7d; b[k++] = 0x52; b[k++] = 0x54; b[k++] = 0x33; b[k++] = 0x01;
  b[k++] = (uint8_t)t0; b[k++] = (uint8_t)n;
  for (i = t0; i < t0 + n; ++i) {
    b[k++] = cur[i] & 0x7f;
    b[k++] = mr_vb(i, cur[i]);
  }
  b[k++] = 0xf7;
  return send(b, k);
}

/* 1026, the active kit for the host's per-kit settings: 3B 1 <kit 0..127> (8 bytes) after each hello's and each open's snapshot,
   and whenever the active kit changes (polled with the machines, behind them) */
static void kit_tick(void) {
  uint8_t k = (uint8_t)(ACTIVE_KIT & 127u);
  uint8_t m[8] = {0xf0, 0x7d, 0x52, 0x54, 0x3b, 0x01, 0, 0xf7};
  if (!mr.kit_owed && k == mr.kit) return;
  m[6] = k;
  if (!send(m, 8)) return;
  mr.kit = k;
  mr.kit_owed = 0;
  mr.kits++;
}

static int32_t mr_tick(void) {   /* 1: nothing left to send */
  uint8_t cur[12];
  int32_t t, nch = 0;
  for (t = 0; t < 12; ++t) {
    cur[t] = MACHINE_OF(t);
    if (cur[t] != mr.m[t]) nch++;
  }
  if (!mr.init) {
    for (t = 0; t < 12; ++t) mr.m[t] = cur[t];
    mr.kit = (uint8_t)(ACTIVE_KIT & 127u);
    mr.init = 1;
    return 1;
  }
  if (nch > 1) mr.all = 1;
  if (mr.all) {
    if (!mr_send(0, 12, cur)) return 0;
    for (t = 0; t < 12; ++t) mr.m[t] = cur[t];
    mr.all = 0;
    mr.sentall++;
    kit_tick();
    return 1;
  }
  for (t = 0; t < 12; ++t)
    if (cur[t] != mr.m[t]) {
      if (!mr_send(t, 1, cur)) return 0;
      mr.m[t] = cur[t];
      mr.sent1++;
    }
  kit_tick();
  return 1;
}

/* ---- 1027: the SRC view - the host's page over the stock SRC page of a Sidecar machine ---------------------------
 * When the stock SRC page (SynthPageView) is the screen and the selected track's machine is a Sidecar machine (vb not
 * 0x7F), 0026 shows the host's last committed frame (with its 3D text) over the stock page - every key and knob stays
 * stock's, nothing is caught. Rytm -> host:
 *   29 1 <track 0..11> <on 0/1>              the SRC view of track t started (1) / ended (0); 1 again for a new track
 *                                            or machine, and after each hello (35) while it is on
 *   2A 1 <track> <first 0..15> <n> {<hi> <lo>} x n   P(first+1) .. P(first+n) of the track: P1..P8 the SRC knobs (kit
 *                                            words 0..7), P9..P16 the SMPL page (kit words 8..15), 0021's order; hi =
 *                                            the value 0..127, lo = the top 7 bits of its fraction (as 0021's 03 / 04);
 *                                            all 16 after each 29 1, then each tick the changed span (n 1: one knob)
 * The frame shows only once the host committed a frame (39) since the view's 29 1 (or since the TRK + YES page or a
 * 3A x 0 gave the screen back), while host messages keep coming (1 s timeout), and while nothing covers the page
 * (another view stacked on the list - the machine list, a popup, TRK held - or the pattern selection): then stock's
 * screen, the frame back when the cover goes. The TRK + YES page and the splash take precedence.
 * The view list [measured, rytm-emu rui1026]: drawAll 0x40079086 draws ctrl's views from *(ctrl + 28) along node +0 up
 * to ctrl + 20, the view at node +8; on the SRC page they are MainScreenView, TransportView, PatternGridView,
 * KeyboardView, SynthPageView (vtable 0x401e34fc), PatternSelectionView (0x401cca04), HelpBubbleView, QuickPerformanceView,
 * SamplerLedView (0x40234cfc) - the last drawn. SMPL / FLTR swap the page view (SamplePageView / SoundPageView); the
 * machine list, TRK held, TEMPO, PERF add a view after SamplerLedView; a menu (GLOBAL, the SOUND menu) replaces the list.
 * PatternSelectionView's byte +0x84 is 1 while a BANK key is held (the [A01] selection in the bottom bar). */
#define SEL_TRACK    (*(const volatile uint8_t *)0x41318982u)   /* the selected track (0021's US_SEL_TRACK) */
#define VT_SYNTHPAGE 0x401e34fcu
#define VT_PATSEL    0x401cca04u
#define VT_SAMPLELED 0x40234cfcu
/* rui1027b: P1..P8 as the page itself shows them, by its own methods (the knob loop's): knob -> record id by the view's
   vtable +0x9c (0x400d3544 on SynthPageView; 0 an unused knob), the value by vtable +0x54 (page_get_value 0x40038462,
   lock -1: the sound's own value, not a p-lock) [code]. The kit word lags a turn by the bank's drain (~0.5..1.3 s while
   the knob moves [measured, rytm-emu rui1027: word 1 stayed 0x40 for 1.3 s of turning]); the page's value does not. */
typedef int32_t (*pv_id_fn)(void *view, int32_t knob);
/* 1027c: 0021's list knobs are stepped by 0029 (its page_get_value wrapper answers the step index); ext_steps(record) via
   0021's ext_stepbox ('XSTP', ext_steps, us_live at 0x4001a23c): 0 continuous, else mode << 8 | N - 1 zones (stored
   ceil(128 k / N)), 2 list, 3 all 128 (stored as the index) [code: ext.c, 0029 sfu.c] */
#define XBOX ((const volatile uint32_t *)0x4001a23cu)
typedef int32_t (*pv_get_fn)(void *view, int32_t id, int32_t lock);
#define KWORD(t, w)  ((const volatile uint8_t *)(0x41255933u + 2531u * (ACTIVE_KIT & 127u) + 152u * (uint32_t)(t) + 2u * (uint32_t)(w)))
static struct {
  uint8_t on, track, mach, covered;    /* the view (logically: the SRC page of a Sidecar track), its track and machine */
  uint8_t pend29, p_track, p_on, vals_all;   /* a 29 owed (the newest replaces an unsent one); all 16 values owed */
  uint8_t show, was_show, pad[2];      /* the host's frame on the glass now / at the last tick */
  uint32_t base, idle, rx_seen;        /* commits at the view's start (or the last give-back); ticks without a message */
  uint16_t val[16];                    /* the values the host was last told */
  uint32_t starts, ends, s29, s2a, shows, covers;   /* diagnostics */
  void *view;                          /* the SynthPageView this tick (0: none) */
  /* 1027d: the cover decision and the 2B diagnostic */
  const void *top;                     /* the last view drawn (this tick) */
  uint32_t top_vt, nviews, top_age;    /* its vtable; the list's length; ticks since the top view changed */
  uint8_t diag, diag_sent, diag_owed, pad2;   /* 2B's state byte now / last sent; 2B owed */
  uint32_t diag_vt_sent_w;             /* the top vtable in the last 2B */
  uint32_t diag_tick, d2b;             /* tick of the last 2B; 2Bs sent */
} sv __attribute__((section(".bss"), aligned(4)));

/* 0 not the SRC page, 1 the SRC page is the screen, 2 the SRC page is there but covered */
/* 1027d: a view stacked after SamplerLedView covers the page when it is one of the stock covers measured or found by
   class name (vtables by their typeinfo in the stock image [code]), or, any other class, for its first UNKNOWN_TICKS
   (3 s): a transient popup of an unlisted class still shows, and a view that stays on top without drawing (hardware
   report rui1027c: after a USB replug the view never came back while TRK + YES worked - a stock view stacked at the
   re-enumeration [inferred; 2B names it]) no longer blocks the view for good. */
#define UNKNOWN_TICKS 60
static const uint32_t sv_covers[] = {
  0x401e5bf4u,   /* MachineListView (SRC twice) [measured] */
  0x401e36f0u,   /* TrackSelectionView (TRK held) [measured] */
  0x401e2414u,   /* PerformanceView (PERF) [measured] */
  0x401d55dcu,   /* TempoMenuView (TEMPO) [measured] */
  0x401d6e18u,   /* PopupWindow [code] */
  0x401d6f84u,   /* TextWindow [code] */
  0x401e70d4u,   /* SampleListView [code] */
  0x40230d44u,   /* QuickPerformanceSelectionView [code] */
};
static int32_t sv_page(void *ctrl) {
  const uint8_t *c = (const uint8_t *)ctrl;
  const uint32_t *n = *(const uint32_t *const *)(c + 28);
  const uint32_t *top = 0;
  uint32_t last = 0;
  int32_t k, j, found = 0, cov = 0, after = 0, unknown = 0;
  sv.view = 0;
  for (k = 0; k < 16 && n && (const uint8_t *)n != c + 20; ++k) {
    const uint32_t *v = (const uint32_t *)n[2];
    if (!v) return 0;
    last = v[0];
    top = v;
    if (last == VT_SYNTHPAGE) { found = 1; sv.view = (void *)v; }
    if (last == VT_PATSEL && ((const uint8_t *)v)[0x84]) cov = 1;
    if (after) {
      for (j = 0; j < (int32_t)(sizeof sv_covers / 4) && sv_covers[j] != last; ++j) ;
      if (j < (int32_t)(sizeof sv_covers / 4)) cov = 1; else unknown = 1;
    }
    if (last == VT_SAMPLELED) after = 1;
    n = (const uint32_t *)n[0];
  }
  if (top != sv.top || last != sv.top_vt) { sv.top = top; sv.top_vt = last; sv.top_age = 0; }
  else if (sv.top_age < 0xffff) sv.top_age++;
  sv.nviews = (uint32_t)k;
  if (!found || k == 16 || !n) { sv.view = 0; return 0; }
  if (!after) cov = 1;                 /* SamplerLedView gone: not the plain SRC screen */
  if (unknown && last != VT_SAMPLELED && sv.top_age < UNKNOWN_TICKS) cov = 1;
  return cov ? 2 : 1;
}

static uint16_t sv_word(int32_t t, int32_t i) {
  const volatile uint8_t *w = KWORD(t, i);   /* P1..P16 contiguous: 0021's knob word 9 + i at sound + 18 + 2 i */
  if (i < 8 && sv.view) {              /* the page's own value (8.8, as the kit word) */
    const uint32_t *vt = *(const uint32_t *const *)sv.view;
    int32_t id = ((pv_id_fn)vt[0x9c / 4])(sv.view, i);
    if (id > 0) {
      int32_t v = ((pv_get_fn)vt[0x54 / 4])(sv.view, id, -1);
      if (XBOX[0] == 0x58535450u) {    /* 0021's list knob: 0029's wrapper answers the step index, not the word */
        int32_t m = ((int32_t (*)(int32_t))XBOX[1])(id), md = m >> 8, n = m & 0xff, k = (v >> 8) & 0xff, kv = w[0] & 0x7f;
        if (md >= 1 && md <= 3 && n > 0) {
          if ((md == 1 ? kv * n / 128 : kv) == k) return (uint16_t)(kv << 7 | (w[1] >> 1));   /* the word, exact */
          v = md == 1 ? (128 * k + n - 1) / n : k;                                          /* the step's stored value */
          return (uint16_t)((v > 127 ? 127 : v) << 7);
        }
      }
      return (uint16_t)(((v >> 8) & 0x7f) << 7 | ((v & 0xff) >> 1));
    }
  }
  return (uint16_t)((w[0] & 0x7f) << 7 | (w[1] >> 1));
}

static void sv_tick(void *ctrl, uint32_t r) {
  int32_t t = SEL_TRACK, pg = sv_page(ctrl), on;
  uint8_t m = 0;
  if (t > 11) pg = 0;
  if (pg) m = MACHINE_OF(t);
  on = pg && mr_vb(t, m) != 0x7f;
  if (on && (!sv.on || sv.track != t || sv.mach != m)) {
    sv.on = 1; sv.track = (uint8_t)t; sv.mach = m;
    sv.base = commits;
    sv.pend29 = 1; sv.p_track = (uint8_t)t; sv.p_on = 1; sv.vals_all = 1;
    sv.starts++;
  } else if (!on && sv.on) {
    sv.on = 0;
    sv.pend29 = 1; sv.p_track = sv.track; sv.p_on = 0;
    sv.ends++;
  }
  sv.covered = pg == 2;
  if (r != sv.rx_seen) sv.idle = 0; else if (sv.idle < 0xffff) sv.idle++;
  sv.rx_seen = r;
  sv.show = sv.on && !sv.covered && commits != sv.base && sv.idle < TIMEOUT_TICKS && !st.active && !st.splash_on;
  {                                    /* 1027d: 2B's state byte; owed on a change, and each second on the SRC page */
    uint8_t d = (uint8_t)(sv.on | sv.covered << 1 | (commits != sv.base) << 2 | (sv.idle >= TIMEOUT_TICKS) << 3 |
                          (st.active ? 1 : 0) << 4 | (st.splash_on ? 1 : 0) << 5 | sv.show << 6);
    if (d != sv.diag_sent || sv.top_vt != sv.diag_vt_sent_w || (pg && (int32_t)(st.ticks - sv.diag_tick) >= 20)) sv.diag_owed = 1;
    sv.diag = d;
  }
  if (sv.show != sv.was_show) {        /* in or out: the views redraw (stock's, then ours over them) */
    if (sv.show) { sv.shows++; st.shown = 0xffffffffu; st.need_comp = 1; } else if (sv.covered) sv.covers++;
    sv.was_show = sv.show;
    *((volatile uint8_t *)ctrl + 0x20) = 1;
  }
}

/* behind the 33s: the 29, then the values (nothing waits: what does not go now goes at a later tick) */
static void sv_flush(void) {
  uint8_t b[9 + 32 + 1];               /* header 9, 16 values, F7 */
  uint16_t cur[16];
  int32_t i, lo = 16, hi = -1, k = 0;
  if (sv.pend29) {
    uint8_t m[10] = {0xf0, 0x7d, 0x52, 0x54, 0x29, 0x01, sv.p_track, sv.p_on, 0xf7};
    if (!send(m, 9)) return;
    sv.pend29 = 0;
    sv.s29++;
  }
  if (sv.diag_owed) {                  /* 1027d: F0 7D 52 54 2B 01 <state> <views> <vt 5 x 7 bits, MSB first> <age> F7 */
    uint32_t v = sv.top_vt;
    uint8_t m[14] = {0xf0, 0x7d, 0x52, 0x54, 0x2b, 0x01, sv.diag, (uint8_t)(sv.nviews & 0x7f),
                     (uint8_t)(v >> 28 & 0x0f), (uint8_t)(v >> 21 & 0x7f), (uint8_t)(v >> 14 & 0x7f),
                     (uint8_t)(v >> 7 & 0x7f), (uint8_t)(v & 0x7f), (uint8_t)(sv.top_age > 127 ? 127 : sv.top_age)};
    uint8_t e[15];
    for (i = 0; i < 14; ++i) e[i] = m[i];
    e[14] = 0xf7;
    if (!send(e, 15)) return;
    sv.diag_owed = 0; sv.diag_sent = sv.diag; sv.diag_vt_sent_w = v; sv.diag_tick = st.ticks; sv.d2b++;
  }
  if (!sv.on) return;
  for (i = 0; i < 16; ++i) {
    cur[i] = sv_word(sv.track, i);
    if (sv.vals_all || cur[i] != sv.val[i]) { if (i < lo) lo = i; hi = i; }
  }
  if (sv.vals_all) { lo = 0; hi = 15; }
  if (hi < 0) return;
  b[k++] = 0xf0; b[k++] = 0x7d; b[k++] = 0x52; b[k++] = 0x54; b[k++] = 0x2a; b[k++] = 0x01;
  b[k++] = sv.track; b[k++] = (uint8_t)lo; b[k++] = (uint8_t)(hi - lo + 1);
  for (i = lo; i <= hi; ++i) { b[k++] = (uint8_t)(cur[i] >> 7); b[k++] = (uint8_t)(cur[i] & 0x7f); }
  b[k++] = 0xf7;
  if (!send(b, k)) return;
  for (i = lo; i <= hi; ++i) sv.val[i] = cur[i];
  sv.vals_all = 0;
  sv.s2a++;
}

static void led_restore(void);

static void enter(void *ctrl, uint8_t reason, uint8_t page) {
  int32_t i;
  if (st.active) return;
  if (st.splash_on) { st.splash_on = 0; st.splash_why = S_OPEN; }
  st.active = 1;
  st.idle = 0;
  st.enter_commits = commits;
  st.shown = 0xffffffffu;
  st.enters++;
  for (i = 0; i < NENC; ++i) st.acc[i] = 0;
  for (i = 0; i < NBIND; ++i) st.echo_until[i] = 0;
  st.kq_n = 0;
  report_mode(1, reason, page);
  st.led_seen = led_gen;               /* 1026: the LEDs stay stock's until a 34 sent after this open */
  st.led_want = 0;
  mr.all = 1;                          /* 1025: the machines' snapshot after the 30 */
  mr.kit_owed = 1;                     /* 1026: and the kit (3B) after it */
  *((volatile uint8_t *)ctrl + 0x20) = 1;
}

static void splash_end(void *ctrl, uint32_t why) {
  if (!st.splash_on) return;
  st.splash_on = 0;
  st.splash_why = why;
  *((volatile uint8_t *)ctrl + 0x20) = 1;     /* the stock views redraw, as after leaving */
}

static void leave(void *ctrl, uint8_t reason) {
  if (!st.active) return;
  st.active = 0;
  st.leaves++;
  st.kq_n = 0;
  report_mode(0, reason, 0);
  sv.base = commits;                   /* 1027: the SRC view shows stock until the host commits again */
  st.led_want = 0;                     /* 1026: the LEDs always back to stock's (the tick retries a busy lock) */
  led_restore();
  *((volatile uint8_t *)ctrl + 0x20) = 1;     /* the stock views redraw; the diff repaints what differs */
}

/* ---- host -> Rytm (MIDI task, through 0022's router) --------------------------------------------- */
static int32_t unpack_rect(const uint8_t *p, int32_t n, int32_t c0, int32_t p0, int32_t nc, int32_t np) {
  int32_t left = nc * 8 * np, pg = 0;
  uint8_t *col = staging + c0 * 64 + p0;    /* byte = page + 8 x column, column = 8 c0 + .. */
  if (n != left + (left + 6) / 7) return 0;  /* exactly the packed size */
  while (left > 0) {
    int32_t g = left < 7 ? left : 7;
    uint32_t hi = *p++;
    left -= g;
    while (g-- > 0) {
      col[pg] = (uint8_t)(*p++ | (hi & 1) << 7);
      hi >>= 1;
      if (++pg == np) { pg = 0; col += 8; }
    }
  }
  return 1;
}

static int32_t sysex_body(const uint8_t *d, int32_t len) {
  int32_t n = len - 7;               /* bytes between <ver> and F7 */
  const uint8_t *b = d + 6;
  if (len < 7 || d[5] != 1 || d[len - 1] != 0xf7) { rx_bad++; return 1; }
  switch (d[4]) {
  case 0x38:
    if (n < 5 || b[1] > 15 || b[2] > 7 || b[3] < 1 || b[4] < 1 || b[1] + b[3] > 16 || b[2] + b[4] > 8 ||
        !unpack_rect(b + 5, n - 5, b[1], b[2], b[3], b[4])) { rx_bad++; st_valid = 0; return 1; }
    st_seq = b[0];
    st_valid = 1;
    break;
  case 0x39:
    if (n < 1) { rx_bad++; return 1; }
    if (st_valid && b[0] == st_seq) {
      sh_seq++;
      copy32((uint32_t *)shadow, (const volatile uint32_t *)staging, 256);
      copy32((uint32_t *)txt_sh, (const volatile uint32_t *)txt_st, sizeof txt_sh / 4);
      sh_seq++;
      commits++;
      t_commit = TIMER;
    }
    st_valid = 0;
    break;
  case 0x3a:
    if (n < 2) { rx_bad++; return 1; }
    if (b[1]) host_open = 1; else host_close = 1;
    break;
  case 0x3c:
    break;
  case 0x34: {   /* 1026: <mode> [<c1> .. <c16>]: the trig keys' LEDs (taken by the UI task at its next tick) */
    int32_t i;
    if (n < 1 || b[0] > 1 || (b[0] == 1 && n != 17)) { rx_bad++; return 1; }
    for (i = 0; b[0] == 1 && i < 16; ++i)
      if (b[1 + i] >= LED_NCOL) { rx_bad++; return 1; }
    led_gen++;
    led_req_mode = b[0];
    for (i = 0; b[0] == 1 && i < 16; ++i) led_req[i] = b[1 + i];
    led_gen++;
    break;
  }
  case 0x36:   /* <ticks>: the splash (taken by the UI task at its next tick) */
    if (n < 1) { rx_bad++; return 1; }
    splash_req = 0x100u | (b[0] & 0x7f);
    break;
  case 0x37: {   /* <e0 e1 e2> <k0 .. k36>: the catch mask, 7 bits a byte */
    uint32_t e = 0, k[8];
    int32_t i, j;
    if (n < 3 || n > 3 + 37) { rx_bad++; return 1; }
    for (i = 0; i < 8; ++i) k[i] = 0;   /* not an initialiser: gcc makes that a memset call */
    for (i = 0; i < 3; ++i) e |= (uint32_t)(b[i] & 0x7f) << (7 * i);
    for (j = 0; j < n - 3; ++j)
      for (i = 0; i < 7; ++i)
        if (b[3 + j] >> i & 1 && 7 * j + i < 256) k[(7 * j + i) >> 5] |= 1u << ((7 * j + i) & 31);
    mask_enc = e & 0xffff;
    for (i = 0; i < 8; ++i) mask_keys[i] = k[i];
    mask_set = 1;
    masks++;
    break;
  }
  case 0x3d: {   /* <seq> <slot> <x> <y> <font> <flags> <chars> */
    struct txt *t;
    int32_t i, k = n - 6;
    if (n < 6 || b[1] >= NTXT || b[2] > 127 || b[3] > 63 || b[4] >= NFONT || k > TXTLEN) { rx_bad++; st_valid = 0; return 1; }
    for (i = 0; i < k; ++i)
      if (b[6 + i] < 0x20 || b[6 + i] > 0x7e) { rx_bad++; st_valid = 0; return 1; }
    t = &txt_st[b[1]];
    t->x = b[2]; t->y = b[3]; t->font = b[4]; t->flags = b[5]; t->len = (uint8_t)k;
    for (i = 0; i < k; ++i) t->s[i] = (char)b[6 + i];
    t->s[k] = 0;
    st_seq = b[0];
    st_valid = 1;
    break;
  }
  case 0x3e: {   /* <seq>: every staging text slot empty (a whole frame follows) */
    int32_t i;
    if (n < 1) { rx_bad++; return 1; }
    for (i = 0; i < NTXT; ++i) txt_st[i].len = 0;
    st_seq = b[0];
    st_valid = 1;
    break;
  }
  case 0x3f: {   /* <enc> <slot | 7F none> <value> <lo> <hi> <flags> <prefix> */
    struct bind *w;
    int32_t i, k = n - 6;
    if (n < 6 || b[0] >= NBIND || k > 11) { rx_bad++; return 1; }
    w = &bind_in[b[0]];
    bind_gen[b[0]]++;
    w->slot = b[1] < NTXT ? b[1] : 0xff; w->value = b[2]; w->lo = b[3]; w->hi = b[4]; w->flags = b[5];
    w->plen = (uint8_t)k;
    for (i = 0; i < k; ++i) w->pre[i] = (char)(b[6 + i] >= 0x20 && b[6 + i] <= 0x7e ? b[6 + i] : '?');
    bind_gen[b[0]]++;
    break;
  }
  default:
    rx_bad++;
    return 1;
  }
  rx++;
  return 1;
}

int32_t rui_sysex(const uint8_t *d, int32_t len);

/* ---- 1026: the trig keys' LEDs ----------------------------------------------------------------------------
 * The panel MCU at the end of UART8 (rytm-emu panel.rs): every LED has four colour slots (B0..B3 <id> <colour>, or
 * B4 <id> <c0..c3> for all four) and a 2-bit selector (2g / 3g, four LEDs a byte) naming the slot it shows; colours are
 * indices into a 128-entry palette the OS loads at boot (B5 <i> <r> <g> <b>, 5 bits each) [measured, rytm-emu]. The
 * trig keys are LEDs 0..15 (T1..T16) [measured]. Stock shows trigs red 0x0f, the play position white 0x6f, off 0x00
 * (palette (1,1,1)) on them [measured, stock 1.73 in rytm-emu], so they are RGB [inferred].
 * Every byte for the panel passes the UART8 writer 0x400019e4 (the tile writer and the selector sender call it a byte
 * or a few at a time [code]), so 0026 sits there (a detour) and follows the stream with the MCU's own message lengths:
 * it keeps what stock last sent to each slot of LEDs 0..15 (sh), and while the host owns the LEDs it rewrites the
 * colour bytes of those messages to the host's colour as they pass (the stream itself never changes length, so the
 * MCU stays in step whatever stock sends, and the selectors can do what they like: every slot holds the host's colour).
 * Leaving gives stock's colours back (B4 <id> sh[id]), exactly what stock believes the panel shows. Locks: the LED mutex
 * stock's LED senders take (0x41920560), only by a try-lock; a miss waits for the next tick. Nothing here touches USB. */
typedef void (*uart_fn)(int32_t len, const uint8_t *msg);
void rui_uart_raw(int32_t len, const uint8_t *msg);   /* the stock writer past the detour (asm below) */
static volatile uint8_t ov_on, ov_col[16];   /* the host's colours on the glass (UI task writes, the writer reads) */
static uint8_t sh[16][4];                    /* stock's last colour per slot of LEDs 0..15 (0: never sent) */
static uint8_t ps_left, ps_hdr, ps_pos, ps_id;   /* the stream: bytes left in the message, its header, the byte's place */
static uint32_t uart_bytes __attribute__((aligned(4))), uart_sub __attribute__((aligned(4)));   /* diagnostics: bytes seen, colour bytes rewritten */

/* the MCU's message length by header (rytm-emu panel.rs, read from the MCU's own parser) */
static int32_t msg_len(uint32_t h) {
  switch (h >> 4) {
  case 0x0: return 1;
  case 0x1: return 10;
  case 0xb:
    if (h <= 0xb3 || h == 0xb6) return 3;
    if (h == 0xb4) return 6;
    if (h == 0xb5) return 5;
    if (h == 0xb8) return 1;
    return 2;
  default: return 2;
  }
}

/* one byte through the stream: the byte to send (the host's colour for a trig LED's slot while it owns them) */
static uint8_t uart_byte(uint8_t b) {
  uart_bytes++;
  if (!ps_left) {
    ps_hdr = b;
    ps_pos = 0;
    ps_left = (uint8_t)(msg_len(b) - 1);
    return b;
  }
  ps_left--;
  ps_pos++;
  if (ps_hdr < 0xb0 || ps_hdr > 0xb4) return b;
  if (ps_pos == 1) { ps_id = b; return b; }
  if (ps_id >= 16) return b;
  sh[ps_id][ps_hdr == 0xb4 ? ps_pos - 2 : ps_hdr & 3] = b;
  if (!ov_on) return b;
  uart_sub++;
  return ov_col[ps_id];
}

/* the detour's C half: 1 sent here (rewritten), 0 the stock writer sends the caller's bytes as they are */
int32_t rui_uart(int32_t len, const uint8_t *m) {
  uint8_t buf[16];
  int32_t i, k = 0;
  if (!ov_on) {
    for (i = 0; i < len; ++i) uart_byte(m[i]);
    return 0;
  }
  for (i = 0; i < len; ++i) {
    buf[k++] = uart_byte(m[i]);
    if (k == 16 || i == len - 1) { rui_uart_raw(k, buf); k = 0; }
  }
  return 1;
}

static void led_send4(int32_t id, const uint8_t *c) {
  uint8_t m[6];
  m[0] = 0xb4; m[1] = (uint8_t)id; m[2] = c[0]; m[3] = c[1]; m[4] = c[2]; m[5] = c[3];
  rui_uart_raw(6, m);
}

/* the host's colours on T1..T16 (1 done; 0 the lock was busy: the next tick tries again) */
static int32_t led_paint(void) {
  int32_t i;
  if (!MUTEX_TRY(LED_MUTEX)) { st.led_busy++; return 0; }
  for (i = 0; i < 16; ++i) ov_col[i] = st.led_col[i];
  ov_on = 1;                           /* stock's slot messages from now on carry the host's colour */
  for (i = 0; i < 16; ++i) {
    uint8_t c[4];
    c[0] = c[1] = c[2] = c[3] = st.led_col[i];
    led_send4(i, c);
  }
  MUTEX_GIVE(LED_MUTEX);
  st.led_paints++;
  return 1;
}

/* stock's own colours back on T1..T16 */
static void led_restore(void) {
  int32_t i;
  if (!ov_on) return;
  if (!MUTEX_TRY(LED_MUTEX)) { st.led_busy++; return; }
  ov_on = 0;
  for (i = 0; i < 16; ++i) led_send4(i, sh[i]);
  MUTEX_GIVE(LED_MUTEX);
  st.led_restores++;
}

static void led_tick(void) {
  uint32_t g = led_gen;
  int32_t i, fresh = 0;
  if (st.active && g != st.led_seen && !(g & 1)) {   /* a 34 since the page opened (or since the last one) */
    uint8_t md = led_req_mode, c[16];
    for (i = 0; i < 16; ++i) c[i] = led_req[i];
    if (led_gen == g) {
      st.led_seen = g;
      st.led_want = md;
      for (i = 0; i < 16; ++i) st.led_col[i] = c[i];
      fresh = 1;
    }
  }
  if (!st.active) st.led_want = 0;
  if (st.led_want != 1) { led_restore(); return; }
  if (!ov_on || fresh) led_paint();
}

/* ---- UI task ------------------------------------------------------------------------------------------ */
static void tick_body(void *ctrl) {
  uint32_t r = rx;
  int32_t i;
  st.ticks++;
  st.t_tick = TIMER;
  if (!st.init) {
    MBOX[1] = (uint32_t)rui_sysex;
    MBOX[0] = 0x52554950u;          /* 'RUIP' */
    st.init = 1;
    st.rx_seen = r;
    return;
  }
  if (host_close) { host_close = 0; host_open = 0; sv.base = commits; leave(ctrl, R_HOST); }   /* 1027: also the view's */
  if (host_open) { host_open = 0; enter(ctrl, R_HOST, 0); }
  /* the hello: the port up for HELLO_TICKS, then again at +1 s and +2 s while the host has said nothing */
  if (PORT_STATE == 1) {
    if (st.port_ticks < 0xffff) st.port_ticks++;
    if (st.port_ticks == HELLO_TICKS) { st.hello_rx = r; st.hello_n = 1; st.pend_hello = 1; mr.all = 1; mr.kit_owed = 1; }
    else if (st.hello_n && st.hello_n < 3 && st.port_ticks == HELLO_TICKS + 20 * st.hello_n) {
      if (r == st.hello_rx) { st.hello_n++; st.pend_hello = 1; mr.all = 1; mr.kit_owed = 1; } else st.hello_n = 3;
    }
    if (st.pend_hello && sv.on) { sv.pend29 = 1; sv.p_track = sv.track; sv.p_on = 1; sv.vals_all = 1; }   /* 1027 */
  } else {
    st.port_ticks = 0;
    st.hello_n = 0;
    st.pend_hello = 0;
  }
  if (splash_req) {
    uint32_t q = splash_req, t = q & 0x7f;
    splash_req = 0;
    if (st.active || (t && !commits)) st.splash_ignored++;   /* the page is the user's; or nothing to show */
    else if (!t) splash_end(ctrl, S_HOST);
    else {
      if (!st.splash_on) {
        st.splash_on = 1;
        st.splashes++;
        st.shown = 0xffffffffu;
        st.idle = 0;
        st.need_comp = 1;
      }
      st.splash_left = t;
    }
  }
  if (st.active) {
    if (r != st.rx_seen) st.idle = 0;
    else if (++st.idle >= TIMEOUT_TICKS) { leave(ctrl, R_TIMEOUT); mask_set = 0; }   /* host gone: the default again */
  } else if (st.splash_on) {
    if (r != st.rx_seen) st.idle = 0;
    else st.idle++;
    if (st.idle >= TIMEOUT_TICKS) splash_end(ctrl, S_IDLE);   /* host gone mid-splash: stock */
    else if (!--st.splash_left) splash_end(ctrl, S_TIME);
  }
  st.rx_seen = r;
  for (i = 0; i < NBIND; ++i)
    if (st.echo_until[i] && (int32_t)(st.ticks - st.echo_until[i]) >= 0) {
      st.echo_until[i] = 0;          /* the host's own text again (it has the value by now) */
      st.need_comp = 1;
    }
  sv_tick(ctrl, r);                  /* 1027: the SRC view */
  if ((st.active || st.splash_on || sv.show) && (commits != st.shown || st.need_comp)) *((volatile uint8_t *)ctrl + 0x20) = 1;
  led_tick();
  flush();
  if (!st.pend_hello && !st.pend_open && mr_tick()) sv_flush();   /* 1025: behind the hello and the 30; 1027 behind those */
}

/* ---- text: the shadow + the committed text slots (+ the local echoes) drawn by the Rytm's own text_draw ---------- */
static int32_t utoa(char *o, int32_t v) {   /* -999..999, the sign when negative */
  char t[4];
  int32_t n = 0, k = 0;
  if (v < 0) { o[n++] = '-'; v = -v; }
  do { t[k++] = (char)('0' + v % 10); v /= 10; } while (v && k < 4);
  while (k) o[n++] = t[--k];
  return n;
}

static void echo_text(int32_t e, char *o) {
  const struct bind *w = &st.echo_bind[e];
  int32_t n = w->plen, v = st.echo_val[e];
  int32_t i;
  for (i = 0; i < n; ++i) o[i] = w->pre[i];
  if (w->flags & 2) {
    v -= 64;
    if (v > 0) o[n++] = '+';
  }
  n += utoa(o + n, v);
  o[n] = 0;
}

static void draw_txt(const struct txt *t, const char *str) {
  void *font = TEXT_FONT(FONT_CTX(t->font));
  int32_t h = *(const uint16_t *)((const uint8_t *)font + 6);     /* font +4: (descent, height) [code, 0x40071506] */
  int32_t d = *(const uint16_t *)((const uint8_t *)font + 4);
  int32_t y = 64 - h - t->y;                                       /* glass top -> the canvas's y (0 at the bottom) */
  if (y - d < 0) return;            /* below the screen: not drawn (the glyph writer clips x and y itself [code]) */
  TEXT_DRAW(st.bm, font, t->x, y, t->flags & 3, (t->flags >> 2) & 1, str, "%s", str);
  st.texts_drawn++;
}

/* 1: comp holds the newest committed frame with its text (and the echoes); 0: the MIDI task was copying */
static int32_t compose(uint32_t c) {
  static struct txt tl[NTXT];
  char eb[TXTLEN + 4];
  uint32_t s0, t0 = TIMER, dt;
  int32_t i, e;
  s0 = sh_seq;
  if (s0 & 1) return 0;
  copy32((uint32_t *)comp, (const volatile uint32_t *)shadow, 256);
  copy32((uint32_t *)tl, (const volatile uint32_t *)txt_sh, sizeof tl / 4);
  if (sh_seq != s0) return 0;
  if (!st.bm[0]) BITMAP_CTOR(st.bm, 128, 64, comp, 0);
  for (i = 0; i < NTXT; ++i) {
    const char *str = tl[i].s;
    if (!tl[i].len) continue;
    for (e = 0; e < NBIND; ++e)
      if (st.echo_until[e] && st.echo_bind[e].slot == i) { echo_text(e, eb); str = eb; }
    draw_txt(&tl[i], str);
  }
  st.composed = c;
  st.comps++;
  dt = TIMER - t0;
  st.comp_sum += dt;
  if (dt > st.comp_max) st.comp_max = dt;
  return 1;
}

static void draw_body(void *bmp, void *ctrl) {
  uint32_t *px = *(uint32_t **)((uint8_t *)bmp + 16);   /* canvas(+4 w, +8 h, +16 pixels) 0x4006f9c2 */
  uint32_t c;
  int32_t i;
  (void)ctrl;
  if (!st.active && !st.splash_on && !sv.show) return;
  c = commits;
  if (st.active && c == st.enter_commits) {
    for (i = 0; i < 256; ++i) px[i] = 0;               /* nothing committed yet: a blank page */
    st.shown = c;
    return;
  }
  if (c != st.composed || st.need_comp) {
    if (!compose(c)) {             /* the MIDI task is copying: the last frame again, the new one next tick */
      st.torn++;
      copy32(px, (const volatile uint32_t *)comp, 256);
      return;
    }
    st.need_comp = 0;
  }
  copy32(px, (const volatile uint32_t *)comp, 256);
  if (c != st.shown) {             /* a new frame's first blit: commit -> pixels (the diff follows) */
    uint32_t l = TIMER - t_commit;
    st.cb_sum += l; st.cb_n++;
    if (l > st.cb_max) st.cb_max = l;
  }
  if (st.t_e2e && c != st.e2e_c) {   /* the host's answer to a turn reaches the pixels */
    uint32_t l = TIMER - st.t_e2e;
    st.e2e_sum += l; st.e2e_n++;
    if (l > st.e2e_max) st.e2e_max = l;
    st.t_e2e = 0;
  }
  if (st.t_echo) {                 /* a turn's echo reaches the pixels */
    uint32_t l = TIMER - st.t_echo;
    st.ee_sum += l; st.ee_n++;
    if (l > st.ee_max) st.ee_max = l;
    st.t_echo = 0;
  }
  st.shown = c;
  st.blits++;
  st.t_blit = TIMER;
  st.lat_commit_blit = st.t_blit - t_commit;
  return;
}

/* Where a key pressed on the page goes: 0 stock, 1 the host, 2 both (a caught FUNC: stock keeps it held, so FUNC + PLAY
   stays stock's combo, and the host still sees it). A caught TRK is the host's alone, as in 1021: stock opens a screen
   on a second TRK within ~1 s [measured, rytm-emu 2026-10-18], which a quick TRK + YES in and out would do. */
static int32_t key_owner(uint32_t code) {
  if (code >= K_REC && code <= K_STOP) return 0;             /* RECORD, PLAY, STOP: always stock's */
  if (mask_set && !(mask_keys[code >> 5] >> (code & 31) & 1)) return 0;
  return code == K_FUNC ? 2 : 1;
}

static int32_t key_body(void *brain, void *ev) {
  uint32_t code = *(uint32_t *)((uint8_t *)ev + 12) & 0xff;
  uint32_t down = *(uint32_t *)((uint8_t *)ev + 16) & 1;
  int32_t o;
  (void)brain;
  st.last_key = code | down << 8 | (*(uint32_t *)((uint8_t *)ev + 16) & 0xfe) << 8;
  if (!down) {   /* a release goes where its press went, whatever the mask or the mode is now */
    if (BIT(st.eat, code)) { CLR(st.eat, code); return 1; }               /* the combo's YES: never seen */
    if (BIT(st.stock_down, code)) { CLR(st.stock_down, code); return 0; }   /* pressed before: stock's */
    if (BIT(st.both_down, code)) {
      CLR(st.both_down, code);
      if (st.active) queue_key(code, 0);
      return 0;
    }
    if (BIT(st.our_down, code)) {
      CLR(st.our_down, code);
      if (st.active) queue_key(code, 0);
      return 1;                     /* ours (or the combo's): eaten, also after leaving */
    }
    return 0;                       /* a press nobody booked (before boot's init): stock's */
  }
  if (BIT(st.eat, code)) return 1;
  if (BIT(st.our_down, code)) return 1;          /* a repeat of a held key: to whoever took its press */
  if (BIT(st.stock_down, code) || BIT(st.both_down, code)) return 0;
  if (code == K_YES && (BIT(st.stock_down, K_TRK) || BIT(st.our_down, K_TRK) || BIT(st.both_down, K_TRK))) {
    SET(st.eat, code);              /* TRK + YES: in or out, never forwarded, nor its release */
    if (st.active) leave(*(void **)((uint8_t *)brain + 32), R_ESCAPE);
    else enter(*(void **)((uint8_t *)brain + 32), R_USER, 0);
    return 1;
  }
  /* 1026, TRK + LFO: the page opens on the Sidecar's LFO page; while open, the host goes there (the 30 again). The LFO
     press and release never reach stock (its LFO page would open under ours) nor the host. */
  if (code == K_LFO && (BIT(st.stock_down, K_TRK) || BIT(st.our_down, K_TRK) || BIT(st.both_down, K_TRK))) {
    SET(st.eat, code);
    if (st.active) { report_mode(1, R_USER, PG_LFO); st.lfo_hints++; flush(); }
    else { enter(*(void **)((uint8_t *)brain + 32), R_USER, PG_LFO); st.lfo_opens++; }
    return 1;
  }
  /* the splash: playing keys (transport, pads) play under it; any other key ends it, a navigation key only that (a
     confirm or cancel under a hidden menu never happens blind), the rest also reach stock */
  if (!st.active && st.splash_on && !(code >= K_REC && code <= K_STOP) && !(code >= K_PAD0 && code <= K_PAD1)) {
    splash_end(*(void **)((uint8_t *)brain + 32), S_KEY);
    if (code >= K_NAV0 && code <= K_NAV1) { SET(st.eat, code); return 1; }
  }
  o = st.active ? key_owner(code) : 0;
  if (o == 0) {
    if (st.active) { if (code >= K_REC && code <= K_STOP) st.k_transport++; else st.k_passed++; }
    SET(st.stock_down, code);
    return 0;
  }
  st.k_caught++;
  if (o == 2) SET(st.both_down, code); else SET(st.our_down, code);
  queue_key(code, 1);
  flush();
  return o == 2 ? 0 : 1;
}

/* The local echo: an encoder the host bound (3F) shows its new value at the next render, before the round trip. */
static void echo(void *brain, int32_t e, int32_t delta) {
  struct bind *w = &st.echo_bind[e];
  uint32_t g = bind_gen[e];
  int32_t v;
  if (g != st.echo_gen[e] && !(g & 1)) {   /* the host's binding changed: take it (and its value unless echoing) */
    struct bind nb __attribute__((aligned(4)));
    copy32((uint32_t *)&nb, (const volatile uint32_t *)&bind_in[e], sizeof nb / 4);
    if (bind_gen[e] == g) {
      int32_t keep = st.echo_until[e] && nb.slot == w->slot;
      copy32((uint32_t *)w, (const volatile uint32_t *)&nb, sizeof nb / 4);
      if (!keep) st.echo_val[e] = nb.value;
      st.echo_gen[e] = g;
    }
  }
  if (!st.echo_gen[e] || w->slot >= NTXT) return;
  if (!st.echo_until[e]) st.echo_val[e] = w->value;
  v = st.echo_val[e] + delta * ((w->flags & 1) && st.func ? 8 : 1);
  if (v < w->lo) v = w->lo;
  if (v > w->hi) v = w->hi;
  st.echo_val[e] = (uint8_t)v;
  w->value = (uint8_t)v;
  st.echo_until[e] = st.ticks + ECHO_TICKS;
  st.need_comp = 1;
  st.echoes++;
  if (!st.t_echo) st.t_echo = TIMER;
  *((volatile uint8_t *)*(void **)((uint8_t *)brain + 32) + 0x20) = 1;   /* the render redraws */
}

static int32_t enc_body(void *brain, void *ev) {
  const uint8_t *e = (const uint8_t *)ev;
  int32_t idx, delta;
  (void)brain;
  st.last_enc[0] = *(const uint32_t *)(e + 4);
  st.last_enc[1] = *(const uint32_t *)(e + 8);
  st.last_enc[2] = *(const uint32_t *)(e + 12);
  st.last_enc[3] = *(const uint32_t *)(e + 16);
  st.last_enc[4] = e[20];
  if (!st.active) {
    if (st.splash_on) splash_end(*(void **)((uint8_t *)brain + 32), S_ENC);   /* the turn reaches stock, seen at once */
    return 0;
  }
  idx = *(const int32_t *)(e + ENC_IDX_OFF);
  delta = *(const int32_t *)(e + ENC_DELTA_OFF);
  if (mask_set && !(idx >= 0 && idx < NENC && (mask_enc >> idx & 1))) { st.e_passed++; return 0; }   /* stock's knob */
  st.e_caught++;
  /* FUNC held: the event's +20, or FUNC down in 0026's own books (every key event passes here, whoever owns it: a
     FUNC passed to stock still steps x 8) [measured: +20 stayed 0 with FUNC held in rytm-emu, stock or caught] */
  st.func = e[20] || BIT(st.stock_down, K_FUNC) || BIT(st.our_down, K_FUNC) || BIT(st.both_down, K_FUNC) ? 1 : 0;
  if (idx >= 0 && idx < NENC) {
    st.acc[idx] += delta;
    if (!st.t_enc) st.t_enc = TIMER;
    if (!st.t_e2e) { st.t_e2e = TIMER; st.e2e_c = commits; }
    if (idx < NBIND) echo(brain, idx, delta);
    flush();                          /* the turn goes out now, not at the next tick (in order behind 30 and keys) */
    if (!st.acc[idx]) st.enc_sent_now++;
  }
  return 1;
}

int32_t rui_sysex(const uint8_t *d, int32_t len) {
  uint32_t t0 = TIMER, dt;
  int32_t r = sysex_body(d, len);
  dt = TIMER - t0;
  mt_sum += dt; mt_calls++;
  if (dt > mt_max) mt_max = dt;
  return r;
}

void rui_tick(void *ctrl) {
  uint32_t t0 = TIMER, dt;
  tick_body(ctrl);
  dt = TIMER - t0;
  st.ui_sum += dt; st.ui_calls++;
  if (dt > st.ui_max) st.ui_max = dt;
}

void rui_draw(void *bmp, void *ctrl) {
  uint32_t t0 = TIMER, dt;
  draw_body(bmp, ctrl);
  dt = TIMER - t0;
  st.ui_sum += dt; st.ui_calls++;
  if (dt > st.ui_max) st.ui_max = dt;
}

int32_t rui_key(void *brain, void *ev) {
  uint32_t t0 = TIMER, dt;
  int32_t r = key_body(brain, ev);
  dt = TIMER - t0;
  st.ui_sum += dt; st.ui_calls++;
  if (dt > st.ui_max) st.ui_max = dt;
  return r;
}

int32_t rui_enc(void *brain, void *ev) {
  uint32_t t0 = TIMER, dt;
  int32_t r = enc_body(brain, ev);
  dt = TIMER - t0;
  st.ui_sum += dt; st.ui_calls++;
  if (dt > st.ui_max) st.ui_max = dt;
  return r;
}

/* 1026: the UART8 writer's detour (0x400019e4, registry): rui_uart(len, msg) sends the rewritten bytes itself (1) or
   the stock writer goes on with the caller's (0). rui_uart_raw: the stock writer past the detour, for 0026's own
   messages (its two displaced instructions, then 0x400019ec) - called as a function: the same frame as the entry. */
__asm__(
    "  .text\n"
    "  .globl rui_uart_det, rui_uart_raw\n"
    "  .align 2\n"
    "rui_uart_det:\n"
    "  move.l 8(%sp),-(%sp)\n"
    "  move.l 8(%sp),-(%sp)\n"
    "  jsr rui_uart\n"
    "  addq.l #8,%sp\n"
    "  tst.l %d0\n"
    "  beq.s rui_uart_raw\n"
    "  rts\n"
    "  .align 2\n"
    "rui_uart_raw:\n"
    "  lea -12(%sp),%sp\n"
    "  movem.l %d2-%d4,(%sp)\n"
    "  jmp 0x400019ec\n");
