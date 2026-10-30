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
 *                 28 1 <track> <root> <CHD> <INV> <SPR> <VOI>   1030: the chord write-back (below, "1030"; 0022's
 *                      router passes 28 here); answered 28 2 <track> <step | 7F> <status>
 *                 37 1 <e0> <e1> <e2> <k0 .. k36>   1022: the catch mask; encoder i caught: bit i % 7 of e(i / 7)
 *                      (0..15), key code c caught: bit c % 7 of k(c / 7) (0..255; keys past the last byte sent: passed)
 *                 36 1 <ticks 0..127>   1023: show the last committed frame as a splash for ticks x 50 ms (0: end it)
 *                 34 1 <mode> [<c1> .. <c16>]   1026: the trig keys' LEDs while the page is open: mode 0 stock's,
 *                      1 the host's, c the palette colour 0..111 of T1..T16 (below, "1026")
 *   Rytm -> host  30 1 <page> <on> <reason 0 user, 1 host, 2 timeout, 3 local escape>   1026: page, the page to show
 *                      on an open: 0 the host's default (SIDECAR), 1 LFO (TRK + LFO; again while open: go there),
 *                      1036: 0x10 + track the SEQ page of that track (1037: TRK + TRIG; again: leave),
 *                      1041: 2 INSERT (TRK + FX; again while open: go there), 1047: 3 INSERT on its OUT view (UP + AMP;
 *                      an older host takes an unknown page as 0)
 *                 31 1 <code >> 7> <code & 0x7f> <down>   (the firmware's key code, e.g. TRK 0x86 = 1 6)
 *                 32 1 <encoder> <delta + 64> <func>
 *                 35 1 <uptime >> 7> <uptime & 0x7f> <caps>   1023: hello, 0.5 s after the USB port came up (again
 *                      1 s and 2 s later while no valid host message came): uptime in ticks since 0026 started
 *                      (saturated at 16383), caps bit 0: 36 understood, bit 1 (1049): 16 send FX label tables kept
 *                      (0029's 24s; before, 8: a host sends the labels of 8 TYPEs at most to an older build), bit 2
 *                      (1052): the project slot reports 4B (below, "1052")
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
#define K_PAGE 0x84       /* 1032: PAGE [measured: panel.rs RYTM_KEYS] */
#define K_FILL 0xb2       /* 1033: FILL [measured: panel.rs RYTM_KEYS] */
#define K_LFO  0x35       /* 1026: LFO [measured: panel.rs RYTM_KEYS; stock 1.73's TRK + LFO = LFO alone, rytm-emu] */
#define PG_LFO 1          /* 30's page: the Sidecar's LFO page */
#define PG_INSOUT 3       /* 1047: 30's page 3: the INSERT page opened on its OUT view (UP + AMP; an older host: its SIDECAR page) */
#define PG_INS 2          /* 1041: 30's page 2: the Sidecar's INSERT page (TRK + FX; rytm-teensy core/ui/remote.cpp kPageIns) */
#define PG_SEQ 0x10       /* 1036: 30's page 0x10 + track (16..27): the Sidecar's SEQ page of that track (1037: TRK + TRIG) */
#define PG_POLY 0x20      /* 1048: 30's page 0x20 + track (32..43): the POLY CONFIG page of that track (the track menu's
                             item; an older host reads it as 0, its SIDECAR page) */
#define K_PLAYMODE 0xb5   /* 1037b: PLAY MODE (the pads' play mode; FUNC + it = the KIT menu) [panel.rs RYTM_KEYS] */
#define K_TRIG 0x30       /* 1037: TRIG [panel.rs RYTM_KEYS; stock 1.73's TRK + TRIG = TRIG alone, rytm-emu] */
#define K_AMP  0x34       /* 1047: AMP [panel.rs RYTM_KEYS] */
#define K_SRC  0x31       /* 1046: SRC, SMPL [panel.rs RYTM_KEYS] */
#define K_SMPL 0x32
#define K_NO   0x45
#define K_SCNE 0x13       /* 1052d: NO + SCNE / CHRO / PLAYMODE reload the pattern / track / kit (YES + them save) [measured,
                             rytm-emu rui1052: 0x400af5e0 / 0x400af64a / 0x400af0d2 once each; panel.rs RYTM_KEYS] */
#define K_CHRO 0x12
#define K_PG0  0x30       /* 1036: the page keys TRIG SRC SMPL FLTR AMP LFO 0x30..0x35 and FX 0x10 [panel.rs RYTM_KEYS] */
#define K_FX   0x10
#define K_PUSH0 0x70      /* 1036: the encoders' pushes PUSH_A .. PUSH_H 0x70..0x77 */
#define K_PUSH7 0x77
#define K_DOWN 0x43       /* 1052d: DOWN [panel.rs RYTM_KEYS] */
#define K_UP   0x42       /* 1036b: UP held + T1..T5: the Pi display's page (49 1) - no stock combo [measured] */
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
static volatile uint32_t pc_seq __attribute__((aligned(4)));      /* 1030: odd while a 28 1 chord is copied, +2 each */
static volatile uint8_t pc_req[6];                                /* 1030: the chord request (pc_tick takes it) */
static volatile uint32_t ls_in_v, ls_in_gen __attribute__((aligned(4)));   /* 1040: the host's 4A <track> <browse> (ls_tick) */
static uint8_t st_seq, st_valid;     /* MIDI task only: the 38s' seq since the last commit */
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
  /* 1036 (after every field the tests read by offset) */
  uint32_t seq_view;                               /* the page shows (or was sent to) the SEQ page by TRK + TRIG */
  uint32_t tt_opens, tt_hints, tt_closes;          /* 1037 TRK + TRIG (1036 FUNC + LFO): opened, sent again, closed */
  uint32_t lock_keys;                              /* seq mode, page closed, a trig held: page keys / NO / YES / pushes */
  /* 1038 (after every field the tests read by offset): FUNC + PAGE with the page open - stock's SCALE menu shown, the
     page aside until it closes */
  uint32_t aside, aside_seen, aside_tick, asides;
  /* 1041 (after every field the tests read by offset) */
  uint32_t ins_opens, ins_hints;                   /* TRK + FX: opened on the INSERT page; sent again while open */
  uint32_t hdr_until, hdrs;                        /* the stock header's TRK LEVEL readout over the page: until, turns */
  /* 1042 (after every field the tests read by offset) */
  uint32_t ov_asides;                              /* the page stepped aside for a stock overlay (TEMPO, a menu, ...) */
};
static struct rui st __attribute__((aligned(4)));
/* 1037b: TRK + TRIG / TRK + LFO used this TRK hold (cleared at TRK's release); YES on the page they opened is the page's
   while TRK is still held (yes_page counts those), not TRK + YES's leave */
static struct { uint32_t used, yes_page, stock_trk, injects; } tk __attribute__((aligned(4)));
/* 1052d, the user's key rules (2026-10-27): NO + a reload key under a page, YES's timing. no_def: NO pressed on the
   page (caught, nothing else of the page's held) kept back until its release (the page's back then) or the next key;
   combos: NO + SCNE / CHRO / PLAYMODE handed to stock; no_late: NO sent at the next key; yes_host: YES the host's
   because FUNC or a page trig was down */
static struct { uint32_t no_def, combos, no_late, yes_host, unbooked, func_masks, updn_host; } nk __attribute__((aligned(4)));
/* 1046: UP the one Sidecar modifier (the user: TRK is stock's busiest key, UP held alone shows the map already). UP +
   TRIG / LFO / FX / YES as TRK's (kept as aliases), UP + SRC the source list, on a poly track with a trig held UP +
   RECORD / STOP / PLAY the steps' copy / paste / clear. up_used: an UP + key opened the page this hold (YES on it is
   the page's, as tk.used); up_d0: UP's press tick; seq: UP taken on a poly track with a trig held (never stock's);
   src_t / src_m: UP + SRC waiting for the view to open its list (the tick | 1, the machine) */
#define HELD(k) (BIT(st.stock_down, k) || BIT(st.our_down, k) || BIT(st.both_down, k))
#define UPH() (HELD(K_UP) || u46.seq)   /* UP held: stock's, the page's, or taken on a poly track */
#define UP_YES_TICKS 3          /* UP held >= 100..150 ms before YES: a menu's UP-then-YES rolled over stays stock's */
static struct {
  uint32_t up_used, up_d0, src_t, src_m;
  uint32_t combos, yes, src, src_lists, seq_ups, seq_ops, yes_early, amp;   /* diagnostics */
  uint8_t seq;
} u46 __attribute__((section(".bss"), aligned(4)));
/* 1048: POLY CONFIG, an item of stock's track menu (FUNC + CHRO; "1048" below). owed: track + 1 whose POLY CONFIG page
   the next tick opens (30 page PG_POLY + track); the rest diagnostics */
static struct {
  uint32_t owed, adds, picks, opens, hints, nohost, notrack;
  uint32_t c_hello;                    /* commits at the port's first hello: a host that drew since has more */
} pm __attribute__((section(".bss"), aligned(4)));
/* 1040: stock's key handler, the call the ev_key site makes (0x400a47cc: jsr 0x400a02ca with (brain, ev), the event
   built by 0x40071e10 [code, the stock image]); 0026 calls it once to give stock a caught TRK's press (TRK + pad) */
#define STOCK_KEY ((int32_t (*)(void *, void *))0x400a02cau)

/* 1032: the sequencer link (below, "1032"). sq.mask / sq.on: the UI task writes them (from the host's 2E), the
   sequencer interrupt and the UI task read them (one word each). */
#define SQ_NQ 32
struct sq_tick { uint32_t blk; uint8_t t, step, len, spd; };
static struct {
  volatile uint32_t on, mask, ticks;   /* reports on (a 2E since the last hello); the seq tracks; the ticked tracks */
  /* the sequencer interrupt (level 2) */
  struct sq_tick q[SQ_NQ];             /* step ticks not sent yet: q[qt % SQ_NQ] .. q[(qh - 1) % SQ_NQ] */
  volatile uint32_t qh, qt;
  uint8_t ev[4][16];                   /* 2D 01 / 03 from the interrupt, whole messages (ev_n of them) */
  uint8_t ev_len[4];
  uint32_t ev_n;
  uint32_t init, last_play, last_pat, sw_from;   /* sw_from: a switch seen, its 03 owed at the new pattern's step 0 (| 0x100) */
  uint32_t fires, queued, sent2c, sentev, drops, ev_drops, busy, ends, isr_max;   /* diagnostics */
  /* the UI task */
  uint32_t seen, owed, mode, mode_track, play, pat, next, live, grid, tempo, mutes, pos_tick, refused, resyncs;
  uint32_t s2d, keys, encs, own_was, pg_seen, pg_fresh;
  uint8_t pg_col[4];
  uint32_t down[8];                    /* keys pressed in seq mode (the host's): their releases go there too */
  /* 1042 (after every field the tests read by offset): each track's last call (its starting step, the pattern trig_fire
     scheduled from), the tracks with one; a pattern jump's re-schedule seen; ticks not pushed (re-schedules, no step) */
  uint8_t lprev[12], lpat[12];
  uint32_t lvalid, jumped, rescheds;
  uint32_t solos;                      /* 1049: the soloed tracks last sent (2D 0D) */
} sq __attribute__((section(".bss"), aligned(4)));
static volatile uint32_t sq_gen __attribute__((aligned(4)));   /* 2E (MIDI task; seqlock: odd while writing) */
static volatile uint8_t sq_req[7];
/* 1033: the analog pin (Mod B, rytm-teensy docs/POLYPHONY.md 5; below, "1033"). mask: the UI task (2E), silent: the
   MIDI task (46); the transport hook (the audio interrupt) reads both, one word each. */
static struct {
  volatile uint32_t mask, silent;      /* pinned tracks; of them, the ones the host says sound nothing (VCA closed) */
  uint32_t open, closing, was;         /* the transport hook's: voices opened, closing (unpinned), pinned last block */
  uint32_t decay, attack, hold;        /* the records' second words: stock's decay at DEC 40, attack and hold at ATK 0 */
  uint32_t calls, blocks, starts, closes, vel_fix, isr_max, silents;   /* diagnostics */
} pin __attribute__((section(".bss"), aligned(4)));
/* 1033: the edit reports (2D 0A), queued by the stock edit functions' wrappers (UI task), sent by sq_tick */
#define ED_NQ 8
static struct {
  uint8_t q[ED_NQ][8];                 /* op pattern track ok src a0 a1 a2 */
  uint32_t qh, qt, drops, sent, calls, scale_keys, fill, fill_owed;
  uint32_t sc_seen, sc_len[13], sc_spd[13], sc_mode[13], sc_chg, sc_owed, sc_sent;   /* 2D 04 SCALE (13: the pattern) */
  uint32_t dk_pos, dk_pat, dk_sum[24], dk_init, dirty, dirty_tick, dirty_sent, dirty_pat;   /* 2D 0B DIRTY */
} ed __attribute__((section(".bss"), aligned(4)));
static volatile uint32_t pg_gen __attribute__((aligned(4)));   /* 2F (MIDI task; seqlock) */
static volatile uint8_t pg_req[4];
/* 1036: the SRC view's encoder pushes (31, not caught), the source lists' names (47), the host's parameter writes (48) */
#define NM_LISTS 3                     /* 0 GRANULAR SRC, 1 WAVETABLE TBL, 2 MULTISAMPLE INST */
#define NM_LEN 10                      /* 9 characters kept of the 13 sent (0021's JN_NAME: what a knob shows) */
#define WQ_N 8
static struct {
  uint32_t push;                       /* pushes reported at their press (their release goes too) */
  uint32_t pushes, nm_msgs, nm_bad, w_rx, w_done, w_refused, w_drop, w_sent;   /* diagnostics */
  uint8_t nm_total[NM_LISTS], pad;
  char nm[NM_LISTS][128][NM_LEN];      /* the names, by the knob's value (0..127) */
  volatile uint32_t wq_h, wq_t;        /* 48s: the MIDI task writes q[h % WQ_N] then h++; the UI task takes up to h */
  uint8_t wq[WQ_N][4];                 /* track, param, value, fraction */
  uint8_t wr[WQ_N][3];                 /* the replies owed (48 1 <track> <param> <status>) */
  uint32_t wr_n;
  /* 1038 (appended: the fields above keep their offsets for sv_emu.py) */
  uint8_t nm_bank[NM_LISTS], pad3;     /* the bank (0..7, A..H) whose names nm[l] holds (47's bank byte; 0 an old 47) */
  uint8_t wq_flags[WQ_N];              /* 48's fifth byte (bit 0: from the bank list) */
  uint32_t w_locked, w_full;           /* 48s that locked the held steps; refused for a full lock budget */
} ux __attribute__((section(".bss"), aligned(4)));
/* 1036b: the Pi display (49): UP + T1..T5 asks for its page; the selected track, its machine and name, its P1..P8 with
   their labels, for the display's voice view (polled at the UI tick, sent on a change and after each hello) */
static struct {
  uint32_t page_req, pages, hellos, sent2, sent3;
  uint8_t t, m, valid, owed3;
  uint8_t v[8];
  char lab[8][4];
} dp __attribute__((section(".bss"), aligned(4)));

/* 1044 (rytm-teensy UX review N3, R5): UP held alone on the stock screen asks the host for its combo map (49 1 4 1 at
   UP_MAP_TICKS, 49 1 4 0 at UP's release); TRK's LED blinks slowly while the page has the keys */
#define UP_MAP_TICKS 8          /* 400 ms */
#define TRK_LED   55            /* TRK's LED [rytm-emu panel.rs RYTM_LEDS: a mode key lights its own, measured on 1.73] */
#define TRK_ON    0x6f          /* the play position's white (stock's own bright colour on the keys) */
#define TRK_BLINK 10            /* ticks a half (1 Hz) */
static struct {
  uint32_t up_t0, map_on, map_off, trk_paints, trk_restores;
  uint8_t up_on, up_trig, up_map, map_req;      /* UP down (stock's, page closed), a trig with it, the map asked, 49 owed */
  uint8_t trk_on, trk_col;                      /* TRK's LED the host's now, its colour on the glass */
  uint8_t map_page;                             /* 1050: the map asked over the open page (49 1 5), not the stock screen */
  uint8_t pad50;
  uint32_t pmap_on, pmap_off;                   /* 1050: 49 1 5 1 / 0 sent */
} k44 __attribute__((section(".bss"), aligned(4)));

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

/* 1 sent; 0 not now (the port, the mutex, a stock SysEx under way, the ring or the request pool) - the caller keeps it
   for later. 1052d: a stock dump (a pattern / kit / sound dump) gives the mutex back between its parts while the
   sender's SysEx state (0x413db244, SQ_SYSEX below; isr_send tests it too) stays set: a message sent then lands inside
   the dump and cuts it (the sq fetch race, found by the REMOTE KEYS work), so the message waits for the next tick */
#define TX_SYSEX (*(const volatile uint32_t *)0x413db244u)
/* round 5 (M2) / round 6 (N1, N2): the wait is bounded by the sender's progress - the flag seen set at every look for
   TXSX_TICKS (a dump cut by a cable pull or a port reset could leave it set) and 0026 sends anyway, so its output
   never stops for good (txsx_over counts those). The flag is set and cleared per stock message [measured, --watch]; the
   audio interrupt's entry (rui_render_in, 1500 times a second) notes any moment it is clear (txsx_gap), which restarts
   the count: back-to-back stock messages (a C6 transfer) are waited out whole, only a flag that stays set runs it out.
   txsx_on: the count running (its own flag: t0 may be any tick, N1). txsx_test (tests, --poke): the flag held this many
   ticks from the next key queued, with no gap (the key queue's overflow and the bound can be driven in rytm-emu). */
#define TXSX_TICKS 40                 /* 2 s of the 20 Hz tick with the flag never seen clear */
static uint32_t txsx_t0, txsx_on, txsx_over;
static volatile uint32_t txsx_gap;    /* the audio interrupt's: the flag seen clear */
static volatile uint32_t txsx_test;
static uint32_t txsx_test_end, txsx_test_on;
/* Freeze probe (2026-10-29, the user's rel0-3-0 froze twice: the UI task stopped, audio and the sequencer went on). The
   audio interrupt's entry counts blocks (1500 a second); rui_tick (the UI task) notes the count and its own TCB. When
   the UI task has not ticked for 2 s, the probe reads where it is: blocked (another task runs) - its saved stack
   pointer (TCB + 72: the context switch saves d0-sp at TCB + 12 [code, 0x4000041e]) and from that stack the PC it
   will resume at and the next 8 long words (its callers' return addresses among them); or running (it is the current
   task: a loop in it) - and sends them to the host from the interrupt, every 5 s while it stays so:
   4E 01 <running 0/1> <stalled s> {<word: 5 x 7 bits>} x 9 (rytm-teensy host_link logs it). fp.test (tests, --poke):
   1 the UI task spins in rui_tick, 2 it sleeps there in a loop (blocked). */
#define FP_TCB (*(volatile uint32_t *)0x42f67924u)   /* the running task's TCB [code, 0x40000418 / 0x4000044a] */
#define FP_SLEEP ((void (*)(uint32_t))0x40098c18u)  /* task sleep (0021's US_SLEEP) */
static struct { volatile uint32_t blocks, tick_blk, ui_tcb, sent_blk, probes, test; } fp __attribute__((aligned(4)));
static void fp_check(void);
void rui_render_in(void) {
  if (!TX_SYSEX) txsx_gap = 1;
  fp.blocks++;
  if (fp.ui_tcb && fp.blocks - fp.tick_blk > 3000u) fp_check();
}
static int32_t txsx_wait(void) {
  int32_t held;
  if (txsx_test_on && (int32_t)(st.ticks - txsx_test_end) >= 0) txsx_test_on = 0;
  held = TX_SYSEX != 0 || txsx_test_on;
  if (!held) { txsx_on = 0; txsx_gap = 0; return 0; }
  if (!txsx_on || (txsx_gap && !txsx_test_on)) { txsx_on = 1; txsx_t0 = st.ticks; txsx_gap = 0; }
  if ((int32_t)(st.ticks - txsx_t0) < TXSX_TICKS) return 1;
  txsx_over++;
  return 0;
}
static int32_t send(const uint8_t *m, int32_t n) {
  if (PORT_STATE != 1) return 0;   /* the sender returns at once on its own tests (this, 0xfc0b01c4) */
  if (txsx_wait()) { st.tx_busy++; return 0; }
  if (!MUTEX_TRY(MIDI_MUTEX)) { st.tx_busy++; return 0; }
  if (txsx_wait() || TX_LEVEL + 64 > 4091 || !usb_free(4)) {
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

static int32_t ls_flush(void);
static uint32_t kq_nodown[8], kq_owed[8], kq_owes;   /* 1052d (round 5, M2): queue_key below */
static void kq_owed_in(void);
static void flush(void) {
  uint32_t i, k;
  if (st.pend_hello) {
    uint32_t up = st.ticks < 16383 ? st.ticks : 16383;
    if (!send3(0x35, (uint8_t)(up >> 7), (uint8_t)(up & 0x7f), 7)) return;   /* caps: 36, 1049's 16 label tables, 1052's 4B */
    st.pend_hello = 0;
    st.hellos++;
  }
  if (st.pend_open) {
    uint8_t m[10] = {0xf0, 0x7d, 0x52, 0x54, 0x30, 0x01, st.pend_page, st.pend_on, st.pend_reason, 0xf7};
    if (!send(m, 10)) return;    /* in order: 30 before the keys and turns after it */
    st.pend_open = 0;
  }
  if (!ls_flush()) return;           /* 1038: the bank list's 4A, before its keys and turns */
  for (k = 0; k < st.kq_n; ++k)
    if (!send3(0x31, st.kq[k][0] >> 7, st.kq[k][0] & 0x7f, st.kq[k][1])) break;
  for (i = k; i < st.kq_n; ++i) { st.kq[i - k][0] = st.kq[i][0]; st.kq[i - k][1] = st.kq[i][1]; }
  st.kq_n -= k;
  if (st.kq_n) return;
  if (kq_owes) { kq_owed_in(); return; }   /* 1052d: owed releases, at the next flush */
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

/* 1052d (round 5, M2): a release is never dropped - a key the host saw go down would stay down there. A press is
   dropped (counted) when fewer than KQ_REL places are left (they are the releases'), and then its release too (the
   pair, kq_nodown). A release that finds the queue full: its own press still queued is taken out with it (the pair);
   else it is owed (kq_owed) and goes first as room comes (kq_owed_in, before anything newer). */
#define KQ_REL 6
static void kq_owed_in(void) {
  uint32_t c;
  if (!kq_owes) return;
  for (c = 0; c < 256 && st.kq_n < NKQ; ++c)
    if (BIT(kq_owed, c)) {
      CLR(kq_owed, c);
      kq_owes--;
      st.kq[st.kq_n][0] = (uint8_t)c;
      st.kq[st.kq_n][1] = 0;
      st.kq_n++;
    }
}
static void queue_key(uint32_t code, uint32_t down) {
  if (txsx_test) { txsx_test_end = st.ticks + txsx_test; txsx_test_on = 1; txsx_test = 0; }   /* (tests) */
  kq_owed_in();
  if (down) {
    CLR(kq_nodown, code);
    if (kq_owes || st.kq_n + KQ_REL >= NKQ) { st.tx_drop++; SET(kq_nodown, code); return; }
  } else if (BIT(kq_nodown, code)) {   /* its press was dropped: the pair */
    CLR(kq_nodown, code);
    return;
  } else if (st.kq_n >= NKQ) {
    int32_t i;
    for (i = (int32_t)st.kq_n - 1; i >= 0 && st.kq[i][0] != code; --i) {}
    if (i >= 0 && st.kq[i][1]) {   /* its press not sent yet: both out */
      for (; i + 1 < (int32_t)st.kq_n; ++i) { st.kq[i][0] = st.kq[i + 1][0]; st.kq[i][1] = st.kq[i + 1][1]; }
      st.kq_n--;
      st.tx_drop++;
      return;
    }
    if (!BIT(kq_owed, code)) { SET(kq_owed, code); kq_owes++; }
    return;
  }
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
/* 0021's voice flags (ext.c us_flag_tab, machines 35..52; 0x7F: not one of its machines there; 1031: 52 MULTISAMPLE 0x30;
   1034: 46 WAVETABLE 0x28, 47 GRANULAR 0x38; 1051: 48 LIVE IN 0x78, 49 CHOP 0x18) */
static const uint8_t mr_flag[18] = {0x50, 0x58, 0x60, 0x68, 0x70, 0x48, 0x08, 0x40, 0x7f, 0x00, 0x20,
                                    0x28, 0x38, 0x78, 0x18, 0x7f, 0x10, 0x30};
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
  if (m < 35 || m > 52 || ENGINE(m) != ENGINE(44)) return 0x7f;
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
#define VT_SCALEMENU 0x401d1e74u   /* 1038: ScaleMenuView, stacked on top while FUNC + PAGE's SCALE menu is open [measured] */
#define VT_SAMPLEPAGE 0x401e3170u  /* 1045: SamplePageView, the SMPL page (its typeinfo "14SamplePageView" [code]) */
/* 1045: the bank list opened by DSP SAMPLE's SMP on its SMPL page (ls below): its track + 1 while open, else 0 - the
   view (29 1) is on over that page for as long as the list is (sv_tick) */
static uint32_t ls_smpl;
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
  uint8_t show, was_show, spage, pad;  /* the host's frame on the glass now / at the last tick; 1045: the SMPL page
                                          is the screen (1) / there but covered (2), else 0 */
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
  0x401d55dcu,   /* TempoMenuView (TEMPO) [measured] */
  0x401d6e18u,   /* PopupWindow [code] */
  0x401d6f84u,   /* TextWindow [code] */
  0x401e70d4u,   /* SampleListView [code] */
  0x40230d44u,   /* QuickPerformanceSelectionView [code] */
  VT_SCALEMENU,  /* 1038: ScaleMenuView (FUNC + PAGE) [measured] */
};
/* 1041 (hardware report on rui1040: the SRC view came seconds late in MUTE, CHRO and SCENE pad mode, never in PERF):
   each pad mode other than PLAY stacks its own view on top of SamplerLedView for as long as the mode lasts -
   QuickMuteMenuView (MUTE), ChromPadsView (CHRO), SceneSelectView (SCNE), PerformanceView (PERF) [measured, rytm-emu
   rui1041, 2B; the class names by typeinfo in the stock image]. They draw nothing over the SRC page: the stock SRC
   screen in each pad mode equals the PLAY mode's, 0.2 / 0.6 / 1.7 s after the mode key and with a pad held [measured,
   sv_emu.py padmode]. 1027d counted an unlisted one as a cover for its first 3 s (the late view) and PerformanceView
   (1027's PERF, then taken for a screen) as a cover always (never). They are skipped, as if not stacked. */
static const uint32_t sv_padviews[] = { 0x401e290cu, 0x401e10e4u, 0x401e2dacu, 0x401e2414u };
/* 1042: a stock overlay - a menu, a popup window, a browser, a prompt - by its class name (the vtable's typeinfo at
   vtable - 4, its name at typeinfo + 4: MAIN OS keeps RTTI [code: TempoMenuView 0x401d55dc -> "13TempoMenuView"]).
   Every class whose name ends in MenuView (but QuickMuteMenuView, the MUTE pad mode's view, 1041) or Window, and the
   browsers, managers, name editor and tap tempo. The probe of every stock key and FUNC + key the host's mask leaves to
   stock, with the page open [measured, rytm-emu rui1042, bk_emu.py popups]: TEMPO TempoMenuView, FUNC + TEMPO
   TapTempoView, FUNC + BANK PopupWindow (PTN: SEQUENTIAL), FUNC + REC / PLAY PopupWindow (COPY / CLEAR PATTERN), FUNC +
   FIX FixSetupMenuView, FUNC + RTRG MetronomeMenuView, FUNC + MUTE SoundMenuView, FUNC + PERF SongMenuView, FUNC + SCNE
   PatternMenuView (RELOAD / SAVE PATTERN), FUNC + CHRO TrackMenuView, FUNC + LEVEL's push SoundBrowser; each was drawn
   under the page, hidden, its keys the host's. The last answer is kept (one compare a tick). */
static const char *const ov_names[] = { "SoundBrowser", "KitBrowserView", "SongBrowserView", "NameView", "TapTempoView",
  "ProjectManager", "SoundManager", "SampleManager", "SongEditView", "SoundSlotListView", "SampleListView",
  "TwoColumnMenu", "SceneEditView", "PerformanceEditView" };
static uint32_t ov_vt, ov_is, ov_n, ov_list;   /* ov_list (1051): a stock list whose cursor UP moves (below) */
static int32_t ov_len(const char *x) { int32_t m = 0; while (x[m]) m++; return m; }
static int32_t ov_suffix(const char *s, int32_t n, const char *x) {
  int32_t m = ov_len(x), i;
  if (m > n) return 0;
  for (i = 0; i < m; ++i) if (s[n - m + i] != x[i]) return 0;
  return 1;
}
static int32_t overlay(uint32_t vt) {
  uint32_t ti, nm;
  const char *s;
  int32_t n = 0, j;
  if (vt == ov_vt) return (int32_t)ov_is;
  ov_vt = vt; ov_is = 0; ov_list = 0; ov_n++;
  if (vt < 0x40000404u || vt >= 0x402dc000u || (vt & 3)) return 0;
  ti = *(const uint32_t *)(vt - 4);
  if (ti < 0x40000400u || ti >= 0x402dc000u || (ti & 1)) return 0;
  nm = *(const uint32_t *)(ti + 4);
  if (nm < 0x40000400u || nm >= 0x402dc000u) return 0;
  s = (const char *)nm;
  while (*s >= '0' && *s <= '9') s++;
  while (n < 48 && s[n]) n++;
  if (n >= 48) return 0;
  /* 1051 (a hardware report on rui1049: UP held to scroll the machine list popped the host's map): a list view - the
     machine list (MachineListView, SRC twice) and every class ending in ListView or List - takes UP as its cursor and
     its held UP as stock's auto-repeat: no map there (up_cursor). Not an overlay for the page (the SRC view's covers
     keep their own rule, sv_covers). */
  ov_list = ov_suffix(s, n, "ListView") || ov_suffix(s, n, "List") || ov_suffix(s, n, "Browser");
  if (ov_suffix(s, n, "MenuView")) ov_is = !(n == 17 && ov_suffix(s, n, "QuickMuteMenuView"));
  else if (ov_suffix(s, n, "Window")) ov_is = 1;
  else
    for (j = 0; j < (int32_t)(sizeof ov_names / sizeof ov_names[0]); ++j)
      if (ov_len(ov_names[j]) == n && ov_suffix(s, n, ov_names[j])) ov_is = 1;
  return (int32_t)ov_is;
}
/* 1051: UP is a stock cursor on this view (a menu, a window, a browser, a list): a held UP is stock's auto-repeat, no map */
static int32_t up_cursor(uint32_t vt) { return overlay(vt) || (int32_t)ov_list; }
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
    if (after) {                       /* 1041: a pad mode's view: not a cover, not the top */
      for (j = 0; j < (int32_t)(sizeof sv_padviews / 4) && sv_padviews[j] != v[0]; ++j) ;
      if (j < (int32_t)(sizeof sv_padviews / 4)) { n = (const uint32_t *)n[0]; continue; }
    }
    last = v[0];
    top = v;
    if (last == VT_SYNTHPAGE) { found = 1; sv.view = (void *)v; }
    if (last == VT_SAMPLEPAGE) found |= 2;   /* 1045: the SMPL page */
    if (last == VT_PATSEL && ((const uint8_t *)v)[0x84]) cov = 1;
    if (after) {
      for (j = 0; j < (int32_t)(sizeof sv_covers / 4) && sv_covers[j] != last; ++j) ;
      if (j < (int32_t)(sizeof sv_covers / 4) || overlay(last)) cov = 1; else unknown = 1;   /* 1042: any overlay */
    }
    if (last == VT_SAMPLELED) after = 1;
    n = (const uint32_t *)n[0];
  }
  if (top != sv.top || last != sv.top_vt) { sv.top = top; sv.top_vt = last; sv.top_age = 0; }
  else if (sv.top_age < 0xffff) sv.top_age++;
  sv.nviews = (uint32_t)k;
  sv.spage = 0;
  if (!found || k == 16 || !n) { sv.view = 0; return 0; }
  if (!after) cov = 1;                 /* SamplerLedView gone: not the plain SRC screen */
  if (unknown && last != VT_SAMPLELED && sv.top_age < UNKNOWN_TICKS) cov = 1;
  if (!(found & 1)) { sv.view = 0; sv.spage = cov ? 2 : 1; return 0; }   /* 1045: the SMPL page, not the view */
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
          {                                                                                  /* the step's stored value */
            int32_t f = md == 3 ? (v & 0xe0) >> 1 : 0;   /* 1038: a banked knob's value keeps its bank (0029 bit 11) */
            v = md == 1 ? (128 * k + n - 1) / n : k;
            return (uint16_t)((v > 127 ? 127 : v) << 7 | f);
          }
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
  if (!pg && ls_smpl == (uint32_t)t + 1 && sv.spage) pg = sv.spage;   /* 1045: DSP SAMPLE's list over its SMPL page */
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
  /* 1026: the LEDs stay stock's until a 34 sent after this open (1032: led_own, unless seq mode had them) */
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
  st.seq_view = 0;                     /* 1036 */
  st.aside = 0;                        /* 1038 */
  st.kq_n = 0;
  if (nk.no_def) {                     /* 1052d (round 5, L7): a NO kept back: its release eaten (no back on a page */
    nk.no_def = 0;                     /* opened again before it) */
    CLR(st.our_down, K_NO);
    SET(st.eat, K_NO);
  }
  {                                    /* (the keys owed to the page go with its queue) */
    int32_t i;
    for (i = 0; i < 8; ++i) kq_owed[i] = kq_nodown[i] = 0;
    kq_owes = 0;
  }
  report_mode(0, reason, 0);
  sv.base = commits;                   /* 1027: the SRC view shows stock until the host commits again */
  if (!sq.mode) {                      /* 1026: the LEDs back to stock's (the tick retries a busy lock); 1032: not in seq mode */
    st.led_want = 0;
    led_restore();
  }
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
  case 0x4a:     /* 1040: <track 0..11> <browse 0/1>: the host's file browser over the bank list (YES / NO its own while 1) */
    if (n != 2 || b[0] > 11 || b[1] > 1) { rx_bad++; return 1; }
    ls_in_v = (uint32_t)b[0] << 8 | b[1];
    ls_in_gen++;
    break;
  case 0x28: {   /* 1030: <track> <root> <CHD> <INV> <SPR> <VOI>: the chord write-back (the UI task applies it) */
    int32_t i;
    if (n != 6) { rx_bad++; return 1; }
    for (i = 0; i < 6; ++i)
      if (b[i] > 0x7f) { rx_bad++; return 1; }
    pc_seq++;
    for (i = 0; i < 6; ++i) pc_req[i] = b[i];
    pc_seq++;
    break;
  }
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
  case 0x2e: {   /* 1032: <mask lo7> <mask hi5> <flags> [<clock lo7> <clock hi5> [<pin lo7> <pin hi5>]]: the seq tracks
                    (taken by the UI task at its next tick); 1033: the pin mask (more tracks pinned: the host's poly ones) */
    int32_t i;
    if ((n != 3 && n != 5 && n != 7) || b[1] > 0x1f || (n >= 5 && b[4] > 0x1f) || (n == 7 && b[6] > 0x1f)) {
      rx_bad++;
      return 1;
    }
    sq_gen++;
    for (i = 0; i < 7; ++i) sq_req[i] = i < n ? b[i] & 0x7f : 0;
    sq_gen++;
    break;
  }
  case 0x46:     /* 1033: <silent lo7> <silent hi5>: the pinned tracks on which nothing of the host's sounds (VCA closed) */
    if (n != 2 || b[1] > 0x1f) { rx_bad++; return 1; }
    pin.silent = ((uint32_t)b[0] | (uint32_t)b[1] << 7) & 0xfffu;
    pin.silents++;
    break;
  case 0x47: {   /* 1036: <list> <replace> <total> [<bank>] {<slot> <13 name bytes>} x 0..8: the source lists' names
                    (list 0 GRANULAR SRC, 1 WAVETABLE TBL, 2 MULTISAMPLE INST), the value texts of those knobs (cu_text);
                    1038: the bank byte (0..7; without it bank A): one bank's names per list, another bank's replace them */
    int32_t i, j, l, h0 = (n - 3) % 14 == 0 ? 3 : 4;   /* 1038: a bank byte after total (4 + 14 k), else bank A */
    if (n < 3 || b[0] >= NM_LISTS || b[1] > 1 || ((n - 3) % 14 && (n - 4) % 14) || (h0 == 4 && b[3] > 7)) {
      ux.nm_bad++; rx_bad++; return 1;
    }
    l = b[0];
    if (b[1] || ux.nm_bank[l] != (h0 == 4 ? b[3] : 0))
      for (i = 0; i < 128; ++i) ux.nm[l][i][0] = 0;
    ux.nm_bank[l] = h0 == 4 ? b[3] : 0;
    ux.nm_total[l] = b[2] & 0x7f;
    for (i = h0; i + 14 <= n; i += 14) {
      char *o;
      if (b[i] > 127) continue;
      o = ux.nm[l][b[i]];
      for (j = 0; j < NM_LEN - 1 && b[i + 1 + j] >= 0x20 && b[i + 1 + j] < 0x7f; ++j) o[j] = (char)b[i + 1 + j];
      o[j] = 0;
    }
    ux.nm_msgs++;
    break;
  }
  case 0x48: {   /* 1036: <track 0..11> <param 0..15> <value 0..127> [<fraction 0..127> [<flags>]]: P(param + 1) of the
                    track's sound set as a knob turn sets it (the UI task: the live copy and the kit, through 0021's
                    writer); 1038: flags bit 0, the bank list's commit: the steps held at its YES get a lock instead */
    uint32_t h = ux.wq_h;
    if ((n < 3 || n > 5) || b[0] > 11 || b[1] > 15 || b[2] > 0x7f || (n >= 4 && b[3] > 0x7f) || (n == 5 && b[4] > 0x7f)) {
      rx_bad++;
      return 1;
    }
    if (h - ux.wq_t >= WQ_N) { ux.w_drop++; break; }
    ux.wq[h % WQ_N][0] = b[0]; ux.wq[h % WQ_N][1] = b[1]; ux.wq[h % WQ_N][2] = b[2];
    ux.wq[h % WQ_N][3] = n >= 4 ? b[3] : 0;
    ux.wq_flags[h % WQ_N] = n == 5 ? b[4] : 0;   /* 1038: bit 0 the bank list's YES (locks the steps held then) */
    ux.wq_h = h + 1;
    ux.w_rx++;
    break;
  }
  case 0x2f: {   /* 1032: <page 1> .. <page 4>: the PAGE LEDs' colours (0..111, 7F stock's) */
    int32_t i;
    if (n != 4) { rx_bad++; return 1; }
    for (i = 0; i < 4; ++i)
      if (b[i] >= LED_NCOL && b[i] != 0x7f) { rx_bad++; return 1; }
    pg_gen++;
    for (i = 0; i < 4; ++i) pg_req[i] = b[i];
    pg_gen++;
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
/* 1051: stock's last selector byte of groups 0..3 (LEDs 0..15, 2 bits each: which slot shows), 0xff never sent, and the
   tick a second restore is owed at (0: none) */
static uint8_t shs[4] = {0xff, 0xff, 0xff, 0xff};
static uint32_t led_again;
/* 1032: the PAGE key's 4 LEDs (panel LEDs 43 42 41 40 = page 1..4 [measured: rytm-emu panel::PAGE_LEDS]), the same way:
   stock's last slot colours, and while the host owns one (bit i of ovp_on: page i + 1) its colour */
static volatile uint8_t ovp_on, ovp_col[4];
static uint8_t shp[4][4];
/* 1044: TRK's LED, the same way: stock's last slot colours, and while the page has the keys the host side's colour */
static volatile uint8_t ovt_on, ovt_col;
static uint8_t sht[4];
#define PG_LED(i) (43 - (i))                 /* page i + 1's LED id */
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
  if (ps_hdr >= 0x20 && ps_hdr <= 0x23) { shs[ps_hdr & 3] = b; return b; }   /* 1051: a trig LED group's selector */
  if (ps_hdr < 0xb0 || ps_hdr > 0xb4) return b;
  if (ps_pos == 1) { ps_id = b; return b; }
  if (ps_id == TRK_LED) {               /* 1044: TRK's LED */
    sht[ps_hdr == 0xb4 ? ps_pos - 2 : ps_hdr & 3] = b;
    if (!ovt_on) return b;
    uart_sub++;
    return ovt_col;
  }
  if (ps_id >= 40 && ps_id <= 43) {     /* 1032: a page LED */
    int32_t i = 43 - ps_id;
    shp[i][ps_hdr == 0xb4 ? ps_pos - 2 : ps_hdr & 3] = b;
    if (!(ovp_on >> i & 1)) return b;
    uart_sub++;
    return ovp_col[i];
  }
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
  if (!ov_on && !ovp_on && !ovt_on) {
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

/* stock's slot colours and selectors of T1..T16 as stock last sent them (the lock held) */
static void led_stock(void) {
  int32_t i;
  for (i = 0; i < 16; ++i) led_send4(i, sh[i]);
  for (i = 0; i < 4; ++i)
    if (shs[i] != 0xff) { uint8_t m[2]; m[0] = (uint8_t)(0x20 | i); m[1] = shs[i]; rui_uart_raw(2, m); }
}

/* stock's own colours back on T1..T16. 1051 (the hardware report on rui1050: GRID REC's red left on all 16 after REC
   off on a seq track, until stock changed each LED itself): the selectors are written back too, and the whole of it a
   second time LED_AGAIN ticks later, so a hand-back that crossed stock's own repaint of the same moment (REC off) ends
   with what stock last sent, whatever order the two went out in. Not reproduced in rytm-emu (seq_e2e recleds and
   sq_emu recleds pass before and after): defensive. */
#define LED_AGAIN 4
static void led_restore(void) {
  if (!ov_on) return;
  if (!MUTEX_TRY(LED_MUTEX)) { st.led_busy++; return; }
  ov_on = 0;
  led_stock();
  MUTEX_GIVE(LED_MUTEX);
  led_again = st.ticks + LED_AGAIN;
  if (!led_again) led_again = 1;
  st.led_restores++;
}

static void led_again_tick(void) {
  if (!led_again || ov_on || (int32_t)(st.ticks - led_again) < 0) return;
  if (!MUTEX_TRY(LED_MUTEX)) { st.led_busy++; return; }
  led_stock();
  MUTEX_GIVE(LED_MUTEX);
  led_again = 0;
}

/* 1032: the host owns the LEDs while the page is open or seq mode is on; from the moment it takes them, only a 34 / 2F
   sent after that counts */
static void led_own(void) {
  uint32_t own = st.active || sq.mode;
  int32_t i;
  if (own && !sq.own_was) {
    st.led_seen = led_gen;
    st.led_want = 0;
    sq.pg_seen = pg_gen;
    for (i = 0; i < 4; ++i) sq.pg_col[i] = 0x7f;
    sq.pg_fresh = 1;
  }
  sq.own_was = own;
}

/* 1051 (the hardware report on rui1050: GRID REC stopped, PAGE moved the PAGE LEDs, the trig LEDs stayed on page 1): a 34
   whose paint missed the LED lock was dropped (fresh lasted one tick), so the trig LEDs kept the last 34 painted until
   the next one (while playing the playhead sends one every step: it looked right). Owed now until painted, as pg_tick's
   pg_fresh. */
static uint8_t led_owed;
static void led_tick(void) {
  uint32_t g = led_gen;
  int32_t i, fresh = 0;
  led_own();
  if (sq.own_was && g != st.led_seen && !(g & 1)) {   /* a 34 since the page opened (or since the last one) */
    uint8_t md = led_req_mode, c[16];
    for (i = 0; i < 16; ++i) c[i] = led_req[i];
    if (led_gen == g) {
      st.led_seen = g;
      st.led_want = md;
      for (i = 0; i < 16; ++i) st.led_col[i] = c[i];
      fresh = 1;
    }
  }
  if (!sq.own_was) st.led_want = 0;
  if (fresh) led_owed = 1;
  if (st.led_want != 1) { led_owed = 0; led_restore(); led_again_tick(); return; }
  led_again = 0;
  if ((!ov_on || led_owed) && led_paint()) led_owed = 0;
}

/* 1044 (UX review R5): TRK's LED blinks slowly (white / off, 1 Hz) while the page has the keys - open and not stepped
   aside for a stock view - so "the Sidecar has my keys" can be told from "stock has them" at a glance; stock's own
   colours back when it does not (B4 TRK sht, what stock believes the panel shows). Try-lock as the others. */
static void trk_tick(void) {
  uint32_t want = st.active && !st.aside;
  uint8_t col = (st.ticks / TRK_BLINK) & 1 ? 0 : TRK_ON, c[4];
  if (want == k44.trk_on && (!want || col == k44.trk_col)) return;
  if (!MUTEX_TRY(LED_MUTEX)) { st.led_busy++; return; }
  ovt_col = col;
  ovt_on = (uint8_t)want;
  if (want) { c[0] = c[1] = c[2] = c[3] = col; led_send4(TRK_LED, c); k44.trk_paints++; }
  else { led_send4(TRK_LED, sht); k44.trk_restores++; }
  MUTEX_GIVE(LED_MUTEX);
  k44.trk_on = (uint8_t)want;
  k44.trk_col = col;
}

/* 1032: the PAGE LEDs (2F): page i + 1 the host's colour while it owns the LEDs and its 2F names one (7F: stock's) */
static void pg_tick(void) {
  uint32_t g = pg_gen, want = 0, old = ovp_on;
  int32_t i;
  if (sq.own_was && g != sq.pg_seen && !(g & 1)) {
    uint8_t c[4];
    for (i = 0; i < 4; ++i) c[i] = pg_req[i];
    if (pg_gen == g) {
      sq.pg_seen = g;
      for (i = 0; i < 4; ++i) sq.pg_col[i] = c[i];
      sq.pg_fresh = 1;
    }
  }
  if (sq.own_was)
    for (i = 0; i < 4; ++i)
      if (sq.pg_col[i] < LED_NCOL) want |= 1u << i;
  if (want == old && !sq.pg_fresh) return;
  if (!MUTEX_TRY(LED_MUTEX)) { st.led_busy++; return; }
  for (i = 0; i < 4; ++i)
    if (want >> i & 1) ovp_col[i] = sq.pg_col[i];
  ovp_on = (uint8_t)want;
  for (i = 0; i < 4; ++i) {
    uint8_t m[6];
    int32_t k;
    if (!((want | old) >> i & 1)) continue;
    m[0] = 0xb4; m[1] = (uint8_t)PG_LED(i);
    for (k = 0; k < 4; ++k) m[2 + k] = want >> i & 1 ? sq.pg_col[i] : shp[i][k];
    rui_uart_raw(6, m);
  }
  MUTEX_GIVE(LED_MUTEX);
  sq.pg_fresh = 0;
}

/* ---- 1030: the chord write-back (poly chord, proof of concept) ----------------------------------------------------
 * host -> Rytm  28 1 <track 0..11> <root 0..127> <CHD> <INV> <SPR> <VOI>   (13 B; 0022's router passes 28 to 0026 with
 *               rui=1; like every valid host message it also counts for the 1 s host timeout)
 * Rytm -> host  28 2 <track> <step | 7F> <status>   status 0 ok, 1 no step live-recorded on the track in the last 1 s,
 *               2 the pattern's lock slots full (nothing written), 3 not live recording / not a Sidecar track / track > 11
 * While the Rytm live-records (RECORD + PLAY), stock's live-record writer rec_trig 0x400b45e0 (this, track, note, vel,
 * step, micro, len, d7) [measured, rytm-emu rui1027: its only caller 0x400a13e2 is the UI task's record-event handler,
 * gated by rec_active 0x40036370(0x40181528()); a CHRO pad on BD at step 7 passed (0, 0x3c, 0x7f, 7, -9, -1, -1)] places
 * the trig, its note (track_note_set 0x400c070a), velocity, micro timing and length. 0026's detour at its entry notes
 * (track, step, tick) first. A 28 1 within 20 ticks (1 s) of that sets the step's NOTE to <root> with track_note_set
 * and locks sound words 21..24 (P13..P16) to CHD, INV, SPR, VOI (value << 8, 8.8 as stored) with track_lock_set
 * 0x400c0520, the writer stock's live knob recording calls (live_lock_rec 0x400af6f6 -> 0x400af7ca [measured]), so the
 * live dense array, the change posts and the pattern's stored lock slots are stock's. Lock slots: stock's incremental
 * mirror update 0x4000940c refuses a new (type, track) when used + cost > 71 (cost 2 with the fine flag) and the lock
 * then lives only until the next save [code]; 0026 makes the same count first over the mirror's 72 slots (the lock
 * pool's +0x20 [measured]) and writes nothing when one of the four would not fit (status 2). The fine flag is the one
 * the track already has for the word (live pool +5632 + 5674 t + k), so a hand-made fine lock keeps its slot pair.
 * MIDI task: the request (seqlock pc_seq); UI task (rec_trig's detour, the tick): everything else. */
typedef void *(*vp_fn)(void);
typedef void *(*vpp_fn)(void *);
typedef void *(*trk_fn)(void *pat, int32_t track);
typedef int32_t (*rec_fn)(void *);
typedef void (*note_fn)(void *blk, int32_t step, int32_t note);
typedef int32_t (*lock_fn)(void *blk, int32_t step, int32_t k, int32_t value, int32_t flag);
#define PROJECT       ((vp_fn)0x4017f83eu)        /* project_singleton */
#define PAT_ACTIVE    ((vpp_fn)0x400af040u)       /* the active pattern (as the lock wrapper 0x400a98ba gets it) */
#define PAT_TRACK     ((trk_fn)0x400ab232u)       /* pattern_track */
#define REC_STATE     ((vp_fn)0x40181528u)
#define REC_ACTIVE    ((rec_fn)0x40036370u)       /* live recording on (both stock record paths test it) */
#define NOTE_SET      ((note_fn)0x400c070au)      /* track_note_set: +0x80 + step, posts the change */
#define LOCK_SET      ((lock_fn)0x400c0520u)      /* track_lock_set */
#define LOCK_TYPE(k)  (((const int32_t *)0x401c59ccu)[k])   /* sound index -> stored lock type, voice tracks [code] */
#define PC_TICKS 20
static struct {
  uint32_t tick[12];          /* st.ticks at the track's last live-recorded trig */
  uint8_t step[12], have[12];
  uint32_t seen;              /* the last request taken */
  uint8_t rep[3], rep_owed;   /* the reply */
  uint16_t recs, reqs, done[4], replies;   /* diagnostics: rec_trig calls, requests, by status, replies sent */
} pc __attribute__((section(".bss"), aligned(4)));

int32_t rui_rec_note(int32_t track, int32_t note, int32_t step);
int32_t rui_rec_note(int32_t track, int32_t note, int32_t step) {
  (void)note;
  pc.recs++;
  if (track < 0 || track > 11) return 0;
  if (sq.on && (sq.mask >> track & 1)) { sq.refused++; return 1; }   /* 1032: a seq track: stock records nothing */
  pc.step[track] = (uint8_t)(step < 0 ? 0 : step > 63 ? 63 : step);   /* rec_trig's own clamp */
  pc.tick[track] = st.ticks;
  pc.have[track] = 1;
  return 0;
}

static uint8_t pc_apply(const uint8_t *q, uint8_t *step) {
  int32_t t = q[0], i, j, used = 0;
  uint8_t *blk, *pool, *mirror, *live;
  *step = 0x7f;
  if (t > 11 || !REC_ACTIVE(REC_STATE()) || mr_vb(t, MACHINE_OF(t)) == 0x7f) return 3;
  if (!pc.have[t] || st.ticks - pc.tick[t] > PC_TICKS) return 1;
  *step = pc.step[t];
  blk = (uint8_t *)PAT_TRACK(PAT_ACTIVE(PROJECT()), t);
  pool = *(uint8_t **)(blk + 44);
  if (!pool) return 3;
  live = (uint8_t *)((vpp_fn)(*(void ***)pool)[10])(pool);   /* vtable +40: the dense array, as lock_pool_set */
  mirror = *(uint8_t **)(pool + 0x20);
  if (mirror) {
    for (j = 0; j < 72; ++j)
      if (mirror[66 * j] != 0xff && mirror[66 * j + 1] != 0xff) used++;
    for (i = 0; i < 4; ++i) {
      int32_t k = 21 + i, ty = LOCK_TYPE(k), have = 0;
      for (j = 0; j < 72; ++j)
        if (mirror[66 * j] == (uint8_t)ty && mirror[66 * j + 1] == t) { have = 1; break; }
      if (have) continue;
      used += live[5674 * t + 5632 + k] ? 2 : 1;
      if (used > 71) return 2;
    }
  }
  NOTE_SET(blk, *step, q[1]);
  for (i = 0; i < 4; ++i)
    LOCK_SET(blk, *step, 21 + i, (int32_t)q[2 + i] << 8, live[5674 * t + 5632 + 21 + i] ? 1 : 0);
  return 0;
}

static void pc_tick(void) {
  uint32_t s = pc_seq;
  if (!pc.rep_owed && !(s & 1) && s != pc.seen) {
    uint8_t q[6];
    int32_t i;
    for (i = 0; i < 6; ++i) q[i] = pc_req[i];
    if (pc_seq == s) {
      pc.seen = s;
      pc.reqs++;
      pc.rep[2] = pc_apply(q, &pc.rep[1]);
      pc.rep[0] = q[0];
      pc.done[pc.rep[2] & 3]++;
      pc.rep_owed = 1;
    }
  }
  if (pc.rep_owed) {                 /* the reply; the sender busy: the next tick (a newer request waits behind it) */
    uint8_t m[10] = {0xf0, 0x7d, 0x52, 0x54, 0x28, 0x02, pc.rep[0], pc.rep[1], pc.rep[2], 0xf7};
    if (send(m, 10)) { pc.rep_owed = 0; pc.replies++; }
  }
}

/* ---- 1032: the sequencer link (Sidecar seq MVP; rytm-teensy docs/SEQUENCER.md, design.md "1032") -------------------
 * host -> Rytm  2E 1 <mask lo7: tracks 0..6> <mask hi5: tracks 7..11> <flags> [<clock lo7> <clock hi5>]   the tracks
 *               the Sidecar sequences (ticked, seq mode, no live record); the optional clock mask: tracks only ticked
 *               (2C) for the host's clock; flags bit 1: a resync now (bit 0 reserved, 0). Any 2E turns the reports on
 *               (a resync follows the first); the Rytm forgets it at its hello (35) and when the port goes down.
 *               2F 1 <page 1> <page 2> <page 3> <page 4>   the PAGE LEDs (43 42 41 40) while the host owns the LEDs (the
 *               page open or seq mode on): palette 0..111, 7F stock's
 * Rytm -> host  2C 1 <blk4> <n> {<track> <step> <len> <speed>} x n   step ticks of one audio block
 *               2D 1 <kind> ...   01 TRANSPORT <0 stop 1 play 2 pause> <blk4>, 02 PATTERN <now> <next | 7F>, 03 SWITCH
 *               <from> <to> <blk4>, 05 MUTES <lo7> <hi6>, 0D SOLO <lo7> <hi6> (1049: the soloed tracks, bit t =
 *               track t; none soloed 0 0: then the mutes alone say who is heard; an older host ignores 0D), 06 REC <live> <grid>, 07 TEMPO <bpm x 120: 3 x 7 bits>,
 *               08 SEQMODE <on> <track | 7F>, 09 POS <blk4> <play> <master step & 7F> <dropped ticks, 127 max>
 *               (09's master step: 0x405c8c94 - 1, the counter holds the next step and moves one 24-PPQN tick before
 *               the tracks' steps fire [measured]: for display and resync; 2C is the exact one)
 * blk4: the audio block counter 0x419ca2ac (1500 a second, the one 0021's 60 s window reads) as 4 x 7 bits, MSB first.
 * Step ticks: a detour at trig_fire's entry (0x4009a9bc, (track, pattern, step, slot); called once per track per step,
 * trig or not, from the sequencer clock 0x4009b048, a software interrupt at level 2 [measured, rytm-emu: 221 calls =
 * 13 x 17 steps in 2 s; the clock 203/s at 127 BPM, its only exit 0x4009bf9e (movem, lea, rte) 610 / 3 s]) queues
 * (block, track, step, length, speed) for the seq tracks; a detour at the clock's exit polls transport (0x405c8c90:
 * 0 stop, 1 play, 2 pause [measured]) and the active pattern (0x405c8d04) and sends what is queued, the 2D 01 / 03
 * first. That send obeys 0021's interrupt rules (no task holds the USB MIDI mutex, the sender not inside a SysEx, the
 * ring under 3800, 2 free requests), at IPL 5 so 0021's own sender in the audio interrupt cannot cut in; else the
 * ticks wait for the next clock call (5 ms at 127 BPM). A full queue drops and counts (2D 09). Nothing else changes in
 * the clock. The rest (02, 05..09) is polled in the 20 Hz UI tick and goes through 0026's try-lock as all its reports.
 * Seq mode: reports on, the selected track (0x41318982) one of the mask's and GRID REC on (the grid object's +360
 * while +353 is set, as 0x4003625c reads it; the object at 0x419f28d8 [measured, rytm-emu: RECORD writes +360 1 / 0,
 * 0x4003625c's argument]). Then T1..T16 and PAGE are the host's (31, press and release, the page open or not), FUNC
 * both sides' (stock keeps its combos), and encoders A..H while one of those trig keys is held (32); the host owns
 * the trig LEDs (34) and the PAGE LEDs (2F). On a seq track, live recording writes nothing (rec_trig's detour returns
 * at once); the pads still play and report as always. */
#define SQ_PLAY      (*(const volatile uint32_t *)0x405c8c90u)
#define SQ_MSTEP     (*(const volatile uint16_t *)0x405c8c94u)
#define SQ_PAT       (*(const volatile int8_t *)0x405c8d04u)
#define SQ_SPEED(t)  (((const volatile uint8_t *)0x405c8d25u)[t])
#define SQ_PREV(t)   (((const volatile uint8_t *)0x405c8ceau)[t])   /* the step starting now (cur - 1) [measured] */
#define SQ_BLK       (*(const volatile uint32_t *)0x419ca2acu)
#define SQ_PATD(p)   ((const volatile uint8_t *)(0x407dd8e3u + 85760u * (uint32_t)(p)))   /* as trig_fire's base */
#define SQ_NEXT      ((const volatile uint8_t *)0x412f3e91u)   /* BE word: the pattern after this one [measured] */
#define SQ_TEMPO     (*(const volatile uint32_t *)0x40287c9cu)  /* 1/120 BPM [measured, re/subsystems/tempo.md] */
#define SQ_MUTES     ((const volatile uint8_t *)0x407c23c3u)   /* BE word, bit t = track t [measured, SEQUENCER.md] */
#define SQ_SOLOS     ((const volatile uint8_t *)0x407c23c5u)   /* 1049: BE word, bit t = track t soloed [measured, rytm-emu:
                                                                  CC 93 (Track Solo) 1 on SD's channel -> 0x0002, on BD's
                                                                  0x0001; mirrors 0x8000ed9e, 0x4131899d] */
#define SQ_GRIDOBJ   (*(const volatile uint32_t *)0x419f28d8u)
#define SQ_SENDER    (*(const volatile uint32_t *)0x42f67a28u)  /* the USB MIDI mutex's owner (0: free) */
#define SQ_SYSEX     (*(const volatile uint32_t *)0x413db244u)  /* the sender's SysEx state (0021's SYSEX_STATE) */
enum { Q_MODE = 1, Q_TRANS = 2, Q_PAT = 4, Q_MUTES = 8, Q_REC = 16, Q_TEMPO = 32, Q_POS = 64, Q_SOLO = 128, Q_ALL = 255 };

static uint32_t ipl_raise(uint32_t lvl) {   /* the old SR; the mask raised to lvl (0x0500 / 0x0700) if lower */
  uint32_t sr, n;
  __asm__ volatile("move.w %%sr,%0" : "=d"(sr));
  sr &= 0xffff;
  if ((sr & 0x0700) < lvl) {
    n = (sr & ~0x0700u) | lvl;
    __asm__ volatile("move.w %0,%%sr" : : "d"(n) : "memory");
  }
  return sr;
}
static void ipl_restore(uint32_t sr) {
  __asm__ volatile("move.w %0,%%sr" : : "d"(sr) : "memory");
}

static uint8_t *blk4(uint8_t *o, uint32_t b) {
  o[0] = (uint8_t)(b >> 21 & 0x7f); o[1] = (uint8_t)(b >> 14 & 0x7f); o[2] = (uint8_t)(b >> 7 & 0x7f);
  o[3] = (uint8_t)(b & 0x7f);
  return o + 4;
}

static uint8_t sq_cap(uint32_t v) { return (uint8_t)(v > 127 ? 127 : v); }

/* the length the step wraps at: the track's (+0x2c5) when the pattern's scale mode byte (+85689) is 1 (per track),
   else the pattern's (+85683, a word) [code: trig_fire 0x4009aa5a, the step loop] */
static uint8_t sq_len(int32_t p, int32_t t) {
  const volatile uint8_t *d = SQ_PATD(p & 127);
  if (d[85689] == 1) return sq_cap(d[917 * t + 0x2c5]);
  return sq_cap((uint32_t)d[85683] << 8 | d[85684]);
}

static void sq_push(int32_t t, int32_t step, uint8_t len, uint8_t spd) {
  uint32_t sr = ipl_raise(0x0700);
  if (sq.qh - sq.qt >= SQ_NQ) sq.drops++;
  else {
    struct sq_tick *e = &sq.q[sq.qh % SQ_NQ];
    e->blk = SQ_BLK; e->t = (uint8_t)t; e->step = (uint8_t)(step & 0x7f); e->len = len; e->spd = spd;
    sq.qh++;
    sq.queued++;
  }
  ipl_restore(sr);
}

static void sq_event(uint8_t kind, uint8_t a, uint8_t b, int32_t nargs, uint32_t blk);

/* trig_fire's detour (C half): a seq track's step. trig_fire runs one step ahead (it schedules the step it is given,
   the current step byte, for the track's next step boundary [code: the time (ticks - 1) x 900 000 at 0x4009b5c4]),
   so the step that starts now is the byte before (0x405c8cea + t) [measured: with 0x04 trig reports of 6-OP FM on
   BD, 2D 01's play block = the first tick's]; called with play 0 / 2 too (STOP's reset): only while playing. */
void sq_fire(int32_t t, int32_t p, int32_t step);
/* 1042: the pattern modes [measured, rytm-emu rui1042, FUNC + BANK_A..D = SEQUENTIAL / DIRECT START / DIRECT JUMP /
   TEMP JUMP, BANK_A + T2 at BD's step 7]. SEQUENTIAL: the new pattern's step 0 at the bar (as 1032). DIRECT START:
   trig_fire is called at once with the new pattern and a starting-step byte 0xff (no step yet: was reported as a tick
   of step 127), then step 0 at the next boundary. DIRECT JUMP / TEMP JUMP: called at once with the new pattern and the
   same starting step as the call before (a re-schedule of the next step: was reported as that step again), the new
   pattern's steps from the next boundary at the old position - its step 0 only a bar or more later, so 03 came that
   late (DIRECT JUMP, 2 s at 127 BPM) or never (TEMP JUMP: back to the old pattern before its step 0). Now a
   re-schedule call is no tick, and after one 03 goes at the next boundary (the next call with a new starting step). */
void sq_fire(int32_t t, int32_t p, int32_t step) {
  uint32_t pv, dup = 0;
  sq.fires++;
  (void)step;
  if (t < 0 || t > 11) return;
  if (SQ_PLAY != 1) { sq.lvalid = 0; sq.jumped = 0; return; }
  pv = SQ_PREV(t);
  if ((sq.lvalid >> t & 1) && pv == sq.lprev[t] && (uint32_t)p != sq.lpat[t]) {   /* a jump's re-schedule: no new step
                                          (the same step again of the same pattern stays a tick: a 1-step track) */
    dup = 1;
    sq.rescheds++;
    sq.jumped = 1;
  }
  sq.lprev[t] = (uint8_t)pv; sq.lpat[t] = (uint8_t)p; sq.lvalid |= 1u << t;
  if ((sq.sw_from & 0x100) && !dup && (pv == 0 || sq.jumped)) {   /* the new pattern's first step: step 0, or a jump's */
    sq_event(0x03, (uint8_t)(sq.sw_from & 0x7f), (uint8_t)sq.last_pat, 2, SQ_BLK);
    sq.sw_from = 0;
    sq.jumped = 0;
  }
  if (dup || pv > 127) return;
  if (!sq.on || !(sq.ticks >> t & 1)) return;
  sq_push(t, (int32_t)pv, sq_len(p, t), SQ_SPEED(t));
}

/* 1: sent (the sequencer interrupt, level 2: 0021's rules, at IPL 5) */
static int32_t isr_send(const uint8_t *m, int32_t n) {
  uint32_t sr;
  int32_t ok = 0;
  if (PORT_STATE != 1) return 0;
  sr = ipl_raise(0x0500);
  if (SQ_SENDER == 0 && SQ_SYSEX == 0 && TX_LEVEL + n <= 3800 && usb_free(2)) {
    MIDI_SEND(n, m);
    ok = 1;
  }
  ipl_restore(sr);
  if (!ok) sq.busy++;
  return ok;
}

static void fp_word(uint8_t *o, uint32_t v) {
  o[0] = (uint8_t)(v >> 28 & 0x0f); o[1] = (uint8_t)(v >> 21 & 0x7f); o[2] = (uint8_t)(v >> 14 & 0x7f);
  o[3] = (uint8_t)(v >> 7 & 0x7f); o[4] = (uint8_t)(v & 0x7f);
}
static void fp_check(void) {   /* the audio interrupt: the UI task has not ticked for over 2 s */
  uint8_t m[54];
  uint32_t tcb = fp.ui_tcb, sp, w[9], s = (fp.blocks - fp.tick_blk) / 1500u;
  int32_t i, run = FP_TCB == tcb;
  if (fp.sent_blk && fp.blocks - fp.sent_blk < 7500u) return;   /* every 5 s while it lasts */
  for (i = 0; i < 9; ++i) w[i] = 0;
  if (!run) {
    sp = *(const volatile uint32_t *)(tcb + 72u);
    if (!(sp & 1) && sp >= 0x40000000u && sp < 0x47be0000u - 48u)
      for (i = 0; i < 9; ++i) w[i] = *(const volatile uint32_t *)(sp + 4u + 4u * (uint32_t)i);   /* PC, then 8 */
  }
  m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x4e; m[5] = 0x01;
  m[6] = (uint8_t)run; m[7] = (uint8_t)(s > 127 ? 127 : s);
  for (i = 0; i < 9; ++i) fp_word(m + 8 + 5 * i, w[i]);
  m[53] = 0xf7;
  if (isr_send(m, 54)) { fp.sent_blk = fp.blocks ? fp.blocks : 1; fp.probes++; }
}

static void sq_event(uint8_t kind, uint8_t a, uint8_t b, int32_t nargs, uint32_t blk) {
  uint8_t *m, *o;
  if (sq.ev_n >= 4) { sq.ev_drops++; return; }
  m = o = sq.ev[sq.ev_n];
  *o++ = 0xf0; *o++ = 0x7d; *o++ = 0x52; *o++ = 0x54; *o++ = 0x2d; *o++ = 0x01; *o++ = kind; *o++ = a;
  if (nargs > 1) *o++ = b;
  o = blk4(o, blk);
  *o++ = 0xf7;
  sq.ev_len[sq.ev_n++] = (uint8_t)(o - m);
}

/* the clock's exit (C half), every sequencer clock call (96 PPQN), at the clock's own level */
void sq_end(void);
void sq_end(void) {
  uint32_t pl = SQ_PLAY, pt = (uint32_t)SQ_PAT & 0x7f, blk = SQ_BLK, t0 = TIMER, dt;
  int32_t i;
  sq.ends++;
  if (pl > 2) pl = 0;
  if (!sq.init) { sq.last_play = pl; sq.last_pat = pt; sq.init = 1; }
  if (sq.on) {
    if (pl != sq.last_play) sq_event(0x01, (uint8_t)pl, 0, 1, blk);
    if (pt != sq.last_pat) {           /* written a step ahead (trig_fire schedules the new pattern's step 0 while the
                                          old one's last step starts [measured]): 03 at that step 0 (sq_fire); stopped: now */
      if (pl == 1) sq.sw_from = 0x100 | sq.last_pat;
      else sq_event(0x03, (uint8_t)sq.last_pat, (uint8_t)pt, 2, blk);
    }
    if (pl != 1 && (sq.sw_from & 0x100)) {   /* stopped before that step: the switch is done now */
      sq_event(0x03, (uint8_t)(sq.sw_from & 0x7f), (uint8_t)pt, 2, blk);
      sq.sw_from = 0;
    }
  }
  sq.last_play = pl;
  sq.last_pat = pt;
  while (sq.ev_n) {                    /* the 2D first, in order */
    if (!isr_send(sq.ev[0], sq.ev_len[0])) return;
    sq.sentev++;
    for (i = 1; i < (int32_t)sq.ev_n; ++i) {
      int32_t k;
      for (k = 0; k < 16; ++k) sq.ev[i - 1][k] = sq.ev[i][k];
      sq.ev_len[i - 1] = sq.ev_len[i];
    }
    sq.ev_n--;
  }
  while (sq.qh != sq.qt) {             /* then the ticks, a message per audio block */
    uint8_t m[6 + 4 + 1 + 4 * 14 + 1], *o = m + 6;
    const struct sq_tick *e = &sq.q[sq.qt % SQ_NQ];
    uint32_t b = e->blk, k = 0;
    m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x2c; m[5] = 0x01;
    o = blk4(o, b);
    o++;                               /* n */
    while (sq.qt + k != sq.qh && k < 14 && sq.q[(sq.qt + k) % SQ_NQ].blk == b) {
      e = &sq.q[(sq.qt + k) % SQ_NQ];
      *o++ = e->t; *o++ = e->step; *o++ = e->len; *o++ = e->spd;
      k++;
    }
    m[10] = (uint8_t)k;
    *o++ = 0xf7;
    if (!isr_send(m, (int32_t)(o - m))) break;
    sq.qt += k;
    sq.sent2c++;
  }
  dt = TIMER - t0;
  if (dt > sq.isr_max) sq.isr_max = dt;
}

/* ---- 1033: the analog pin (Mod B; rytm-teensy docs/POLYPHONY.md 5) ------------------------------------------------
 * On a pinned track (a seq track, unless 2E's flags bit 2; and the 2E pin mask's tracks: the host's poly ones) the voice's
 * analog chain is a static path for the Sidecar's audio: its amp envelope held open, its filter envelope depth 0 and its
 * VCA at velocity 127, so an EMPTY Rytm track sounds and every note's envelope is the host's. A detour at the transport
 * entry 0x4007a538 (the control frame's sender: every block path calls it after the filter and amp consumers wrote the
 * frame [code, POLYPHONY.md 5.1]) rewrites, per voice v whose owner track (0x40290dd8[v], the amp consumer's own table
 * [code: 0x401098fe]) is pinned: the amp records +168+8v / +232+8v = 0000007f 00000000 (held at 127, rate 0 [measured:
 * stock's held ATK 0 / DEC INF record; its second word stock's ATK-0 hold, mode 3], the first block 4000007f (stock's
 * trig record at ATK 0: the start command, a mode-B ramp; once); every stock retrig's
 * start command is masked by that; the filter record's first word +296+8v = 0 (stock's ENV 64: no envelope
 * [measured]); the track's velocity word 0x800067c4 + 2t = 0x7f00, which the amp consumer multiplies into the VCA words
 * +10/+26+2v every block [code: 0x401099c6; measured: VCA linear in velocity] (in a trig's own block the words are
 * rescaled x 0x7f00 / vel, so a softer trig never dips the ringing notes). The host's 46 marks pinned tracks silent: the
 * amp records then carry stock's decay (00000080, 0xb0100000 | rate: the consumer's DEC case [code: 0x40109b82], the
 * rate its table 0x401ee36c at DEC 40) every block, closing the VCA (the open voice's hiss); not silent again: one
 * start, then held. A voice that stops being pinned (the mask, an owner change of a shared voice, a hello) gets the
 * same decay until stock starts it again (a record with the start command). Shared voices follow their owner track.
 * OVR, FRQ, RES, the filter type, level, pan and sends stay stock's. */
#define PIN_OWNER(v)  (((const volatile uint8_t *)0x40290dd8u)[v])
#define PIN_VEL       ((volatile uint16_t *)0x800067c4u)
#define PIN_DECTAB    ((const uint32_t *)0x401ee36cu)   /* the consumer's DEC rates [code: 0x40109b82] */
#define PIN_ATKTAB    ((const uint32_t *)0x401ee76cu)   /* its ATK rates [code: 0x40109ae2] */
void pin_frame(uint8_t *f);
void pin_frame(uint8_t *f) {
  uint32_t m = pin.mask, sil = pin.silent, now = 0, v, t0 = TIMER, dt;
  if ((uint32_t)f != 0x800063c0u) return;   /* the voices' frame only (other callers send test / calibration frames) */
  pin.calls++;
  if (!m && !pin.was && !pin.closing) return;
  if (!pin.decay) {                    /* the amp consumer's own encodings [code: 0x40109ae2..0x40109b9c] */
    pin.decay = (PIN_DECTAB[40] & 0xfffffu) | 0xb0100000u;
    pin.attack = (PIN_ATKTAB[0] & 0xfffffu) | 0xb0000000u;
    pin.hold = (PIN_ATKTAB[0] & 0xfffffu) | 0x30000000u;
  }
  for (v = 0; v < 8; ++v) {
    uint32_t t = PIN_OWNER(v), bit = 1u << v;
    volatile uint32_t *al = (volatile uint32_t *)(f + 168 + 8 * v), *ar = (volatile uint32_t *)(f + 232 + 8 * v);
    if (t < 12 && (m >> t & 1)) {
      uint32_t vel = PIN_VEL[t];
      now |= bit;
      pin.closing &= ~bit;
      if (sil >> t & 1) {
        al[0] = ar[0] = 0x00000080u;
        al[1] = ar[1] = pin.decay;
        if (pin.open & bit) pin.closes++;
        pin.open &= ~bit;
      } else if (pin.open & bit) {     /* held: stock's ATK-0 hold (target 127, mode 3) */
        al[0] = ar[0] = 0x0000007fu;
        al[1] = ar[1] = pin.hold;
      } else {                         /* opened: stock's trig record at ATK 0 (start command, mode B ramp to 127) */
        al[0] = ar[0] = 0x4000007fu;
        al[1] = ar[1] = pin.attack;
        pin.open |= bit;
        pin.starts++;
      }
      *(volatile uint32_t *)(f + 296 + 8 * v) = 0;
      if (vel != 0x7f00u) {
        if (vel >= 0x100u) {
          volatile uint16_t *vl = (volatile uint16_t *)(f + 10 + 2 * v), *vr = (volatile uint16_t *)(f + 26 + 2 * v);
          uint32_t l = (uint32_t)*vl * 0x7f00u / vel, r = (uint32_t)*vr * 0x7f00u / vel;
          *vl = (uint16_t)(l > 0xffffu ? 0xffffu : l);
          *vr = (uint16_t)(r > 0xffffu ? 0xffffu : r);
        }
        PIN_VEL[t] = 0x7f00u;
        pin.vel_fix++;
      }
    } else {
      if (pin.was & bit) { pin.closing |= bit; pin.open &= ~bit; }
      if (pin.closing & bit) {
        if (al[0] & 0x40000000u) pin.closing &= ~bit;   /* stock starts it: stock's from here */
        else { al[0] = ar[0] = 0x00000080u; al[1] = ar[1] = pin.decay; }
      }
    }
  }
  if (now) pin.blocks++;
  pin.was = now;
  dt = TIMER - t0;
  if (dt > pin.isr_max) pin.isr_max = dt;
}

/* ---- 1033: the edit reports (2D 0A), SCALE (2D 04), pattern dirty (2D 0B) ------------------------------------------
 * The stock edit functions (re/symbols.toml; rytm-teensy docs/SEQUENCER.md 2 [measured: each tied to its gesture]) are
 * wrapped (detours at their entries, below): the stock function runs, then ed_report(op, arg1, arg2, result) queues
 *   2D 0A <op> <pattern 0..127> <track 0..11 | 7F> <ok 0/1> <src 0 stock / 1 seq mode> <a0> <a1> <a2>
 * pattern = the working pattern (0x405c8d04: every op acts on it, a paste on another pattern after selecting it),
 * track = the selected track for track / page / trig ops (they act on current_track_pattern), 7F for pattern ops;
 * ok = the function's result byte (a paste with nothing copied, an undo with nothing to undo: 0); a0..a2 a 21-bit arg:
 * the undo kind (1 clear, 2 paste: the kind the function was asked to undo), the held trig mask (src 1), else 0. Ops:
 * 1 COPY PAT, 2 PASTE PAT, 3 CLEAR PAT, 4 UNDO PAT, 5 COPY TRK, 6 PASTE TRK, 7 CLEAR TRK, 8 UNDO TRK, 9 COPY PAGE,
 * 10 PASTE PAGE, 11 CLEAR PAGE, 12 UNDO PAGE, 13 COPY TRIGS, 14 PASTE TRIGS, 15 CLEAR TRIGS; 1042: 16 RELOAD PAT
 * (0x400af5e0), 17 SAVE PAT (0x400ae588), 18 RELOAD TRK (0x400af64a), 19 SAVE TRK (0x400ae614) [measured, rytm-emu: each
 * function ran once for its menu item, FUNC + SCNE's PATTERN menu and FUNC + CHRO's TRACK menu; ok their d0, not a
 * success flag]. 2D 0C FILL <held 0/1>: the
 * FILL key (seen in ev_key before stock; stock keeps it). src 1: seq mode's own
 * gesture (a host trig or PAGE held + FUNC + REC / STOP / PLAY: caught, stock does nothing, the host applies it to its
 * page / held steps). Stock's UI shows UNDO when the undo function returns 1: the host undoes when ok = 1. */
static int32_t sq_send2(uint8_t kind, const uint8_t *a, int32_t n);
enum { ED_PCOPY = 1, ED_PPASTE, ED_PCLEAR, ED_PUNDO, ED_TCOPY, ED_TPASTE, ED_TCLEAR, ED_TUNDO, ED_GCOPY, ED_GPASTE,
       ED_GCLEAR, ED_GUNDO, ED_RCOPY, ED_RPASTE, ED_RCLEAR, ED_PRELOAD, ED_PSAVE, ED_TRELOAD, ED_TSAVE };
static void ed_queue(uint32_t op, uint32_t ok, uint32_t src, uint32_t arg) {
  uint8_t *e;
  ed.calls++;
  ed.dirty = 1;                        /* the pattern changed: 0B at once */
  if (!sq.on) return;
  if (ed.qh - ed.qt >= ED_NQ) { ed.drops++; return; }
  e = ed.q[ed.qh % ED_NQ];
  e[0] = (uint8_t)op;
  e[1] = (uint8_t)((uint32_t)SQ_PAT & 0x7f);
  e[2] = op <= ED_PUNDO || op == ED_PRELOAD || op == ED_PSAVE ? 0x7f : (uint8_t)(SEL_TRACK < 12 ? SEL_TRACK : 0x7f);
  e[3] = (uint8_t)(ok ? 1 : 0);
  e[4] = (uint8_t)src;
  e[5] = (uint8_t)(arg & 0x7f); e[6] = (uint8_t)(arg >> 7 & 0x7f); e[7] = (uint8_t)(arg >> 14 & 0x7f);
  ed.qh++;
}
/* the wrappers' C half (UI task): op, the stock function's first two arguments, its result (d0) */
void ed_report(int32_t op, uint32_t a1, uint32_t a2, uint32_t res);
void ed_report(int32_t op, uint32_t a1, uint32_t a2, uint32_t res) {
  uint32_t undo = op == ED_PUNDO || op == ED_TUNDO || op == ED_GUNDO;
  (void)a1;
  ed_queue((uint32_t)op, res & 0xff, 0, undo ? (a2 & 3) : 0);
}

/* the SCALE poll (UI tick): per track (+0x2c5 length, +0x2c7 speed index) and the pattern's (+85683 length, a BE word;
   +85690 speed; +85689 mode, 1 = per-track lengths; +85685 change length, a BE word: in that mode a queued pattern
   starts at a multiple of it [code: 0x4009baae..0x4009bada, 0x4009bfa8]) of the working pattern. 2D 04:
   <track 0..11 | 7F the pattern> <len lo7> <len hi7> <speed> <mode> [<chg lo7> <chg hi7>: the pattern's only] */
static void sc_poll(void) {
  uint32_t p = sq.sw_from & 0x100 ? sq.sw_from & 0x7f : (uint32_t)SQ_PAT & 127;   /* the playing one (as 02) */
  const volatile uint8_t *d = SQ_PATD(p);
  uint32_t t;
  for (t = 0; t < 13; ++t) {
    uint32_t len, spd, mode = d[85689];
    if (t < 12) { len = d[917 * t + 0x2c5]; spd = d[917 * t + 0x2c7]; }
    else { len = (uint32_t)d[85683] << 8 | d[85684]; spd = d[85690]; }
    if (len != ed.sc_len[t] || spd != ed.sc_spd[t] || mode != ed.sc_mode[t] ||
        (t == 12 && ((uint32_t)d[85685] << 8 | d[85686]) != ed.sc_chg)) {
      ed.sc_len[t] = len; ed.sc_spd[t] = spd; ed.sc_mode[t] = mode;
      if (t == 12) ed.sc_chg = (uint32_t)d[85685] << 8 | d[85686];
      if (ed.sc_seen) ed.sc_owed |= 1u << t;
    }
  }
  ed.sc_seen = 1;
}

/* pattern dirty: a rolling checksum of the working pattern (85760 B), 4 KB a UI tick (a pass in 1.05 s); a chunk whose
   sum moved (any writer: the trig keys, the encoders' locks, live record, SysEx, a stock edit) marks it dirty; 2D 0B
   <pattern> then goes out at most every 4 ticks (200 ms). The host refetches the pattern (its SysEx dump) on it.
   1037b: summed a long word at a time over the aligned span around the pattern (it starts at an odd address, so up to
   3 bytes of the patterns either side are in it: those change only when that pattern is written), 1024 loads a tick
   instead of 4096 byte loads [measured: 0026's UI-task time per tick, the hardware report "the UI slow with the SEQ
   page playing"; design.md 1037b] */
#define DK_CHUNK 1024u                 /* long words a tick */
static void dk_poll(void) {
  uint32_t p = (uint32_t)SQ_PAT & 127, i, k, sum = 0, n, a = (uint32_t)SQ_PATD(p);
  uint32_t a0 = a & ~3u, nw = (((a + 85760u + 3u) & ~3u) - a0) >> 2;
  const volatile uint32_t *d = (const volatile uint32_t *)a0;
  if (p != ed.dk_pat) { ed.dk_pat = p; ed.dk_pos = 0; ed.dk_init = 0; }   /* another pattern: a fresh pass (2D 02 says it) */
  k = ed.dk_pos;
  n = k * DK_CHUNK + DK_CHUNK > nw ? nw - k * DK_CHUNK : DK_CHUNK;
  d += k * DK_CHUNK;
  for (i = 0; i < n; ++i) sum = (sum << 1 | sum >> 31) + d[i];
  if ((ed.dk_init >> k & 1) && sum != ed.dk_sum[k]) ed.dirty = 1;
  ed.dk_sum[k] = sum;
  ed.dk_init |= 1u << k;
  ed.dk_pos = k + 1 >= (nw + DK_CHUNK - 1) / DK_CHUNK ? 0 : k + 1;
}

/* the UI tick's 1033 sends, after 1032's (seq mode, pattern first): SCALE, the edits, dirty; 0 when the sender is busy */
static int32_t ed_send(void) {
  uint8_t a[8];
  uint32_t t;
  for (t = 0; t < 13; ++t) {
    if (!(ed.sc_owed >> t & 1)) continue;
    a[0] = t < 12 ? (uint8_t)t : 0x7f;
    a[1] = (uint8_t)(ed.sc_len[t] & 0x7f); a[2] = (uint8_t)(ed.sc_len[t] >> 7 & 0x7f);
    a[3] = (uint8_t)(ed.sc_spd[t] & 0x7f); a[4] = (uint8_t)(ed.sc_mode[t] & 0x7f);
    a[5] = (uint8_t)(ed.sc_chg & 0x7f); a[6] = (uint8_t)(ed.sc_chg >> 7 & 0x7f);
    if (!sq_send2(0x04, a, t < 12 ? 5 : 7)) return 0;
    ed.sc_owed &= ~(1u << t);
    ed.sc_sent++;
  }
  while (ed.qt != ed.qh) {
    if (!sq_send2(0x0a, ed.q[ed.qt % ED_NQ], 8)) return 0;
    ed.qt++;
    ed.sent++;
  }
  if (ed.fill_owed) {                  /* FILL held (the key; a latched fill is not followed) */
    a[0] = (uint8_t)ed.fill;
    if (!sq_send2(0x0c, a, 1)) return 0;
    ed.fill_owed = 0;
  }
  if (ed.dirty && st.ticks - ed.dirty_tick >= 4) {
    a[0] = (uint8_t)((uint32_t)SQ_PAT & 0x7f);
    if (!sq_send2(0x0b, a, 1)) return 0;
    ed.dirty = 0;
    ed.dirty_tick = st.ticks;
    ed.dirty_sent++;
  }
  return 1;
}

/* GRID REC on: the grid object's +360 while +353 is set (0x4003625c) */
static uint32_t sq_grid(void) {
  uint32_t o = SQ_GRIDOBJ;
  const volatile uint8_t *g = (const volatile uint8_t *)o;
  if (o < 0x40000000u || o >= 0x44000000u) return 0;
  return g[353] && g[360] ? 1 : 0;
}

static int32_t sq_send2(uint8_t kind, const uint8_t *a, int32_t n) {
  uint8_t m[16];
  int32_t i, k = 0;
  m[k++] = 0xf0; m[k++] = 0x7d; m[k++] = 0x52; m[k++] = 0x54; m[k++] = 0x2d; m[k++] = 0x01; m[k++] = kind;
  for (i = 0; i < n; ++i) m[k++] = a[i];
  m[k++] = 0xf7;
  if (!send(m, k)) return 0;
  sq.s2d++;
  return 1;
}

/* the UI task, every tick */
static void sq_tick(void) {
  uint32_t g = sq_gen, v, mode, trk = SEL_TRACK, b;
  uint8_t a[9];
  if (g != sq.seen && !(g & 1)) {      /* a 2E */
    uint8_t q[7];
    int32_t i;
    for (i = 0; i < 7; ++i) q[i] = sq_req[i];
    if (sq_gen == g) {
      sq.seen = g;
      sq.mask = ((uint32_t)q[0] | (uint32_t)q[1] << 7) & 0xfffu;
      sq.ticks = sq.mask | (((uint32_t)q[3] | (uint32_t)q[4] << 7) & 0xfffu);
      pin.mask = ((q[2] & 4) ? 0 : sq.mask) | (((uint32_t)q[5] | (uint32_t)q[6] << 7) & 0xfffu);   /* 1033 */
      if (!sq.on || (q[2] & 2)) { sq.owed = Q_ALL; sq.resyncs++; ed.sc_owed = 0x1fffu; ed.fill_owed = 1; }   /* 1033: + SCALE, FILL */
      sq.on = 1;
    }
  }
  if (!sq.on) { sq.mode = 0; return; }
  mode = trk < 12 && (sq.mask >> trk & 1) && sq_grid();
  if (mode != sq.mode || (mode && trk != sq.mode_track)) { sq.mode = mode; sq.mode_track = trk; sq.owed |= Q_MODE; }
  v = SQ_NEXT[0] << 8 | SQ_NEXT[1];
  b = (uint32_t)SQ_PAT & 0x7f;
  if (sq.sw_from & 0x100) {            /* 1033: the active pattern is written a step before the switch (its 03 at the new
                                          step 0): until that 03 the playing pattern is still the old one, the new the next */
    v = b;
    b = sq.sw_from & 0x7f;
  }
  v = v < 128 && v != b ? v : 0x7f;
  if (b != sq.pat || v != sq.next) { sq.pat = b; sq.next = v; sq.owed |= Q_PAT; }
  v = REC_ACTIVE(REC_STATE()) ? 1 : 0;
  b = sq_grid();
  if (v != sq.live || b != sq.grid) { sq.live = v; sq.grid = b; sq.owed |= Q_REC; }
  v = SQ_TEMPO & 0x1fffff;
  if (v != sq.tempo) { sq.tempo = v; sq.owed |= Q_TEMPO; }
  v = ((uint32_t)SQ_MUTES[0] << 8 | SQ_MUTES[1]) & 0x1fff;
  if (v != sq.mutes) { sq.mutes = v; sq.owed |= Q_MUTES; }
  v = ((uint32_t)SQ_SOLOS[0] << 8 | SQ_SOLOS[1]) & 0x1fff;   /* 1049 */
  if (v != sq.solos) { sq.solos = v; sq.owed |= Q_SOLO; }
  v = SQ_PLAY;
  if (v == 1 && st.ticks - sq.pos_tick >= 20) sq.owed |= Q_POS;
  if (sq.owed & Q_MODE) {
    a[0] = (uint8_t)sq.mode; a[1] = sq.mode ? (uint8_t)sq.mode_track : 0x7f;
    if (!sq_send2(0x08, a, 2)) return;
    sq.owed &= ~(uint32_t)Q_MODE;
  }
  if (sq.owed & Q_TRANS) {             /* a resync's: the state now (the moment's own goes from the interrupt) */
    a[0] = (uint8_t)(v > 2 ? 0 : v);
    blk4(a + 1, SQ_BLK);
    if (!sq_send2(0x01, a, 5)) return;
    sq.owed &= ~(uint32_t)Q_TRANS;
  }
  if (sq.owed & Q_PAT) {
    a[0] = (uint8_t)sq.pat; a[1] = (uint8_t)sq.next;
    if (!sq_send2(0x02, a, 2)) return;
    sq.owed &= ~(uint32_t)Q_PAT;
  }
  if (sq.owed & Q_MUTES) {
    a[0] = (uint8_t)(sq.mutes & 0x7f); a[1] = (uint8_t)(sq.mutes >> 7 & 0x3f);
    if (!sq_send2(0x05, a, 2)) return;
    sq.owed &= ~(uint32_t)Q_MUTES;
  }
  if (sq.owed & Q_SOLO) {              /* 1049: the host follows solo as it follows the mutes */
    a[0] = (uint8_t)(sq.solos & 0x7f); a[1] = (uint8_t)(sq.solos >> 7 & 0x3f);
    if (!sq_send2(0x0d, a, 2)) return;
    sq.owed &= ~(uint32_t)Q_SOLO;
  }
  if (sq.owed & Q_REC) {
    a[0] = (uint8_t)sq.live; a[1] = (uint8_t)sq.grid;
    if (!sq_send2(0x06, a, 2)) return;
    sq.owed &= ~(uint32_t)Q_REC;
  }
  if (sq.owed & Q_TEMPO) {
    a[0] = (uint8_t)(sq.tempo >> 14 & 0x7f); a[1] = (uint8_t)(sq.tempo >> 7 & 0x7f); a[2] = (uint8_t)(sq.tempo & 0x7f);
    if (!sq_send2(0x07, a, 3)) return;
    sq.owed &= ~(uint32_t)Q_TEMPO;
  }
  if (sq.owed & Q_POS) {
    blk4(a, SQ_BLK);
    a[4] = (uint8_t)(v > 2 ? 0 : v); a[5] = (uint8_t)((SQ_MSTEP - 1) & 0x7f); a[6] = sq_cap(sq.drops);
    if (!sq_send2(0x09, a, 7)) return;
    sq.owed &= ~(uint32_t)Q_POS;
    sq.pos_tick = st.ticks;
  }
  sc_poll();                           /* 1033: SCALE, the edits, dirty */
  dk_poll();
  ed_send();
}

/* the hello (and the port going down): the host must say again what it sequences */
static void sq_forget(void) {
  sq.on = 0;
  sq.mask = 0;
  pin.mask = 0;                        /* 1033: every pinned voice closes (the transport hook's closing) */
  pin.silent = 0;
  sq.ticks = 0;
  sq.owed = 0;
  sq.mode = 0;
}

/* ---- 1038: the source banks' list (rytm-teensy docs/SRC-BANKS.md; design.md "1038") ------------------------------
 * GRANULAR SRC, WAVETABLE TBL, MULTISAMPLE INST: P1's word = index << 8 | bank << 5 (index 0..127, bank 0..7 = A..H).
 * Turning knob A on the SRC view of such a track (the host draws the view: sv.show) opens the Sidecar's list, as stock's
 * SMPL knob D opens its SAMPLE SLOT list [measured, rytm-emu: the first turn opens it on the current entry without moving,
 * later turns move the cursor, NO closes with nothing changed, the list stays open without a key]. The turn that opens it
 * is not stock's (the value does not move); the host draws the list over the view (its frames, as the view's):
 *   Rytm -> host  4A 1 <track> <on> <hi> <lo> <why>   on 1: opened (why 0, a turn of knob A), hi.lo P1's 14-bit value then;
 *                                                     on 0: closed - why 1 YES (the host commits its cursor with 48 ..
 *                                                     <flags 1>), 2 NO, 3 another knob turned, 4 another key, 5 the view
 *                                                     ended (a page, a track or machine change, the TRK + YES page, the
 *                                                     host gone); hi.lo P1 then
 * While it is open: knob A's turns go to the host (32 0 ...), LEFT RIGHT UP DOWN too (31, press and release: bank -/+,
 * row -/+); YES and NO close it (4A 0 1 / 2; their release eaten); another knob or key closes it (4A 0 3 / 4) and goes
 * to stock as before. Transport, pads, trig keys and FUNC stay stock's and keep it open. Trigs held at the YES (GRID REC,
 * the grid object's 64-bit held-trig bitmap +0x158 / +0x15c [measured, rytm-emu: T1 T2 T4 T7 T9 held -> 0x14b]) make the
 * host's 48 (flags bit 0) a p-lock of P1 on those steps (track_lock_set, fine), not a kit write. Seq mode with a trig
 * held keeps 1032's rule (the turns are the host's anyway: no list).
 * 1045: DSP SAMPLE's SMP (P11, word 19, record 441: index << 8 | bank << 5 like P1 above, the SAMPLES pool's eight
 * banks) opens the same list from its SMPL page, knob D (SMP's place there; knob A on the SRC page stays ENG): when the
 * selected track is a Sidecar DSP SAMPLE, the SMPL page is the screen (SamplePageView, not covered), the page and the
 * splash closed, and a host is there that has drawn (PORT up, a message within the timeout, a commit since boot), the
 * first turn of D is eaten and 4A 1 <track> 1 <P11 hi lo> 0 goes out; the Rytm then turns the SRC view on for that track
 * over the SMPL page (29 1, sv_tick) so the host's list shows, until the list closes (29 0). D's turns go to the host as
 * 32 0 (the list's knob, as A's), the rest as above; the 48 that commits names P11 (48 1 <t> 10 <index> <bank << 4> 1),
 * with trigs held it locks P11 (k 19). A host that draws nothing within a second of the open (an older one) closes the
 * list (why 5) and leaves D stock's (0029's banked step) until the next hello.
 * 1049: FUNC + YES on the SRC view of such a track or of a DSP SAMPLE track (the host draws the view, the list closed;
 * the hardware pass 2026-10-23: "FUNC + YES on DSP SAMPLE's SRC page opens nothing", the pool empty so SMP only stepped
 * through empty rows) opens the list on the current entry (4A 1 .. why 0; DSP SAMPLE: P11, knob D) with the host's file
 * browser at once (4A 3 .. why 6: the host aims it at the first free row of the bank when the entry is OFF). Then as
 * 1040's FUNC + YES in the list: YES on a file sets the row, the list stays; YES commits it (48). The YES is eaten (its
 * release too); stock 1.73 binds nothing to FUNC + YES there. */
#define LS_NQ 4
static struct {
  uint8_t on, track, mach, pad;
  uint8_t q[LS_NQ][5];                 /* 4A owed: track on hi lo why */
  uint32_t qn;
  uint32_t down;                       /* the nav keys 0x40..0x45 pressed while open: their releases (to the host / eaten) */
  uint32_t fwd;                        /* 1040: of those, the ones whose press went to the host (31): their release too */
  uint32_t browse, br_ack, br_tick, br_gen, browses, br_timeouts;   /* 1040: FUNC + YES's file browser (the host's) */
  uint32_t lk_lo, lk_hi, lk_track, lk_tick;   /* the trigs held at the last YES (steps 0..31, 32..63), its track, tick */
  uint32_t opens, closes, turns, keys, drops, locks, why[6];   /* diagnostics */
  uint8_t p, knob, smpl, pad2;         /* 1045: the list's parameter (0 P1, 10 DSP SAMPLE's P11), the knob that opened
                                          it (A 0, D 3), opened from DSP SAMPLE's SMPL page */
  uint32_t tick0, nd_hello, smpls, smpl_nd;   /* its open tick; st.hellos + 1 of a host that drew no list (none: 0) */
  uint32_t srcyes;                     /* 1049: lists opened by FUNC + YES on the SRC view (the browser at once) */
} ls __attribute__((section(".bss"), aligned(4)));
#define LS_HELD_HI(o) (*(const volatile uint32_t *)((o) + 0x158u))
#define LS_HELD_LO(o) (*(const volatile uint32_t *)((o) + 0x15cu))
#define PAT_LEN       ((rec_fn)0x400c04b8u)   /* pattern_length(track pattern) */
#define CU_WT_M 46    /* WAVETABLE, GRANULAR, MULTISAMPLE (CU_WT / CU_GR / CU_MS below) */
#define CU_GR_M 47
#define CU_MS_M 52
#define CU_CP_M 49    /* 1051: CHOP's SRC is a SAMPLES row too (the bank list, its browser) */

static int32_t ls_banked(uint32_t m) { return m == CU_WT_M || m == CU_GR_M || m == CU_MS_M || m == CU_CP_M; }
#define DSPS_M 45     /* 1045: DSP SAMPLE (0021), its SMP P11 banked */
#define DSPS_P 10
/* 1045: may knob D open the list on this screen (DSP SAMPLE's SMPL page, a drawing host)? */
static int32_t ls_dsps(void) {
  int32_t t = SEL_TRACK;
  if (t > 11 || sv.spage != 1 || MACHINE_OF(t) != DSPS_M || mr_vb(t, DSPS_M) == 0x7f || st.active) return 0;
  return PORT_STATE == 1 && sv.idle < TIMEOUT_TICKS && commits && ls.nd_hello != st.hellos + 1;
}

static void ls_queue(uint8_t on, uint8_t why) {
  uint16_t v = sv_word(ls.track, ls.p);
  if (ls.qn >= LS_NQ) { ls.drops++; return; }
  ls.q[ls.qn][0] = ls.track; ls.q[ls.qn][1] = on; ls.q[ls.qn][2] = (uint8_t)(v >> 7); ls.q[ls.qn][3] = (uint8_t)(v & 0x7f);
  ls.q[ls.qn][4] = why;
  ls.qn++;
}

/* in flush(), after the 30, before the keys and turns */
static int32_t ls_flush(void) {
  uint32_t i, k;
  for (k = 0; k < ls.qn; ++k) {
    uint8_t m[12] = {0xf0, 0x7d, 0x52, 0x54, 0x4a, 0x01, ls.q[k][0], ls.q[k][1], ls.q[k][2], ls.q[k][3], ls.q[k][4], 0xf7};
    if (!send(m, 12)) break;
  }
  for (i = k; i < ls.qn; ++i) { int32_t j; for (j = 0; j < 5; ++j) ls.q[i - k][j] = ls.q[i][j]; }
  ls.qn -= k;
  return ls.qn == 0;
}

static void ls_close(uint8_t why) {
  if (!ls.on) return;
  ls.on = 0;
  ls.browse = 0;                       /* 1040: the host's browser ends with the list (its 4A 0 tells it) */
  ls.closes++;
  ls.why[why < 6 ? why : 5]++;
  ls_smpl = 0;                         /* 1045: the view over the SMPL page ends with it */
  st.acc[0] = 0;                       /* turns not yet sent belong to the list that closed */
  ls_queue(0, why);
}

/* ev_enc, the page closed: 1 the list's (the turn eaten) */
static int32_t ls_enc(int32_t idx, int32_t delta) {
  if (ls.on && idx != ls.knob) { ls_close(3); return 0; }
  if ((idx != 0 && idx != 3) || st.splash_on) return 0;
  if (!ls.on) {
    if (idx == 0 && sv.on && sv.show && ls_banked(sv.mach)) {
      ls.track = sv.track; ls.mach = sv.mach; ls.p = 0; ls.smpl = 0;
    } else if (idx == 3 && ls_dsps()) {   /* 1045: DSP SAMPLE's SMP on its SMPL page */
      ls.track = SEL_TRACK; ls.mach = DSPS_M; ls.p = DSPS_P; ls.smpl = 1;
      ls_smpl = (uint32_t)ls.track + 1;
      ls.smpls++;
    } else return 0;
    ls.on = 1; ls.knob = (uint8_t)idx; ls.tick0 = st.ticks;
    ls.opens++;
    ls_queue(1, 0);
    flush();
    return 1;                          /* the opening turn moves nothing (as stock's list) */
  }
  st.acc[0] += delta;
  ls.turns++;
  flush();
  return 1;
}

/* ev_key, the page closed, a press: 1 the list's */
static int32_t ls_key(uint32_t code) {
  if (!ls.on) return 0;
  if (code >= K_NAV0 && code <= K_NAV1) {
    ls.down |= 1u << (code - K_NAV0);
    /* 1040: FUNC + YES on a row: the host's file browser for that row (4A on 3; stock's sample list has the same
       Fn + YES hint). YES's press and release are eaten; stock had FUNC alone (nothing on its own). Until the host
       answers 4A <track> 1 (within a second, else the list's YES / NO again: an older host) and while its browser is
       open, YES and NO go to the host as 31 like LEFT RIGHT UP DOWN; its 4A <track> 0 gives them back to the list. */
    if (code == K_YES && !ls.browse &&
        (BIT(st.stock_down, K_FUNC) || BIT(st.both_down, K_FUNC) || BIT(st.our_down, K_FUNC))) {
      ls.browse = 1; ls.br_ack = 0; ls.br_tick = st.ticks; ls.br_gen = ls_in_gen; ls.browses++;
      ls_queue(3, 0);
      flush();
      return 1;
    }
    if ((code == K_YES || code == K_NO) && !ls.browse) {
      if (code == K_YES) {             /* the trigs held now: the host's 48 (flags 1) locks them */
        uint32_t o = SQ_GRIDOBJ;
        ls.lk_lo = ls.lk_hi = 0;
        if (o >= 0x40000000u && o < 0x44000000u && sq_grid()) { ls.lk_lo = LS_HELD_LO(o); ls.lk_hi = LS_HELD_HI(o); }
        ls.lk_track = ls.track;
        ls.lk_tick = st.ticks;
      }
      ls_close(code == K_YES ? 1 : 2);
      flush();
      return 1;
    }
    ls.keys++;
    ls.fwd |= 1u << (code - K_NAV0);
    queue_key(code, 1);
    flush();
    return 1;
  }
  if (code <= 0x0f || code == K_FUNC || (code >= K_REC && code <= K_STOP) || (code >= K_PAD0 && code <= K_PAD1)) return 0;
  ls_close(4);
  return 0;
}

/* ev_key, a release: 1 eaten (a nav key pressed while the list was open: LEFT..DOWN's release to the host) */
static int32_t ls_release(uint32_t code) {
  if (code < K_NAV0 || code > K_NAV1 || !(ls.down >> (code - K_NAV0) & 1)) return 0;
  ls.down &= ~(1u << (code - K_NAV0));
  if (ls.fwd >> (code - K_NAV0) & 1) { ls.fwd &= ~(1u << (code - K_NAV0)); queue_key(code, 0); flush(); }
  return 1;
}

/* the UI tick, after sv_tick: the view gone (another page, a cover, another track or machine, the page, the host gone) */
static void ls_tick(void) {
  /* 1045: opened on the SMPL page the view comes on a tick after (29 1) and shows at the host's first frame: closed
     when it never showed within a second (an older host: knob D stock's until the next hello), or stopped showing */
  if (ls.on && ls.smpl && !sv.show && sv.on && !sv.covered && sv.track == ls.track && !st.active &&
      commits == sv.base && st.ticks - ls.tick0 <= 20) {
  } else if (ls.on && (!sv.on || !sv.show || sv.track != ls.track || sv.mach != ls.mach || st.active)) {
    if (ls.smpl && commits == sv.base && st.ticks - ls.tick0 > 20) { ls.nd_hello = st.hellos + 1; ls.smpl_nd++; }
    ls_close(5);
  }
  if (ls_in_gen != ls.br_gen) {        /* 1040: the host's 4A <track> <browse> */
    uint32_t v = ls_in_v;
    ls.br_gen = ls_in_gen;
    if (ls.on && (v >> 8) == ls.track) { ls.browse = v & 1; ls.br_ack = 1; }
  }
  if (ls.browse && !ls.br_ack && st.ticks - ls.br_tick > 20) { ls.browse = 0; ls.br_timeouts++; }   /* no answer in 1 s */
}

/* 1046, the UI tick after ls_tick: UP + SRC's list, opened once the view shows the host's frame for that track (or,
   on DSP SAMPLE, the SMPL page with a drawing host: ls_dsps), as the knob's first turn opens it; given up after a
   second, or when the page, another track or a list came first */
static void u46_tick(void) {
  int32_t ok;
  if (!u46.src_t) return;
  if (ls.on || st.active || st.ticks - u46.src_t > 20 || SEL_TRACK > 11 || MACHINE_OF(SEL_TRACK) != u46.src_m) {
    u46.src_t = 0;
    return;
  }
  ok = u46.src_m == DSPS_M ? ls_dsps() : sv.on && sv.show && sv.track == SEL_TRACK && sv.mach == u46.src_m;
  if (ok && ls_enc(u46.src_m == DSPS_M ? 3 : 0, 0)) { u46.src_t = 0; u46.src_lists++; }
}

/* 48 with flags bit 0 (the list's commit), in wr_tick: lock P1 on the steps held at the YES (one second at most ago, the
   same track); 0 locked, 3 the pattern's lock slots full (nothing written), -1 nothing held (a kit write) */
static int32_t ls_lock(int32_t t, int32_t v, int32_t ix) {   /* 1045: ix the sound index (9 P1, 19 DSP SAMPLE's SMP) */
  uint8_t *blk, *pool, *mirror, *live;
  int32_t s, len, j, ty = LOCK_TYPE(ix), used = 0, have = 0;
  if ((!ls.lk_lo && !ls.lk_hi) || (int32_t)ls.lk_track != t || st.ticks - ls.lk_tick > 20) return -1;
  blk = (uint8_t *)PAT_TRACK(PAT_ACTIVE(PROJECT()), t);
  pool = *(uint8_t **)(blk + 44);
  if (!pool) return -1;
  live = (uint8_t *)((vpp_fn)(*(void ***)pool)[10])(pool);
  mirror = *(uint8_t **)(pool + 0x20);
  if (mirror) {                        /* stock's mirror refuses a new (type, track) past 71 slots: check first (1030's rule) */
    for (j = 0; j < 72; ++j) {
      if (mirror[66 * j] != 0xff && mirror[66 * j + 1] != 0xff) used++;
      if (mirror[66 * j] == (uint8_t)ty && mirror[66 * j + 1] == t) have = 1;
    }
    if (!have && used + 2 > 71) return 3;
  }
  (void)live;
  len = PAT_LEN(blk);
  if (len > 64) len = 64;
  for (s = 0; s < len; ++s)
    if ((s < 32 ? ls.lk_lo >> s : ls.lk_hi >> (s - 32)) & 1) { LOCK_SET(blk, s, ix, v, 1); ls.locks++; }
  ls.lk_lo = ls.lk_hi = 0;
  return 0;
}

/* ---- 1048: POLY CONFIG in stock's track menu (FUNC + CHRO) -------------------------------------------------------
 * The track menu (TrackMenuView, vtable 0x401ec0fc) is built once, at boot, by its constructor 0x400f9b38, called from
 * one site, 0x400cb5b8 (jsr; `this` in d6, also pushed) [code; measured, rytm-emu rui1048base cold boot: the break at
 * 0x400cb5be is reached once, a7 = 0x41bfad40 = the new view]. Its items are a vector of shared_ptr<MenuItem> at +4,
 * each built from four std::function objects (label, action, icon, empty) by menu_item_ctor 0x40072f50 and appended by
 * 0x40072786 (re/symbols.toml, 0012's and 0021's items the same way). After 0021's U1..U5 (its own detour in the
 * constructor's epilogue) the menu reads TRIGS SETUP, PAD SCALE, RELOAD TRACK, SAVE TRACK, U1 .. U5 [measured].
 * pm_menu_det (a detour at the caller's `lea %sp@(24),%sp; tstl %d6` after the constructor returned, registry) appends
 * POLY CONFIG last, the same way, with SAVE TRACK's std::function managers (their captures match: nothing for the label
 * and icon, the menu for the action); the stock items and 0021's are untouched. The detour is the constructor's caller,
 * not its epilogue, so 0012's and 0021's chain there stays as it is and nothing names another mod.
 * YES on it (pm_pick, the UI task, as any menu action): a sound track selected and a host there that has drawn (the
 * port up and a commit since the port's first hello: an idle host sends nothing while the page is closed, so no
 * timeout is tested; rui_e2e polycfg with the real core) -> the menu closes (its vtable +128, as SAVE TRACK's
 * action closes it) and the next tick opens the page on 30 page PG_POLY + track (with the page already open, aside
 * under the menu: the 30 again). Otherwise a popup says why (NO SIDECAR / SOUND TRACKS ONLY) and the menu stays. */
struct pm_fn { void *storage; uint32_t pad; void *manager; void *invoker; };   /* std::function, 16 B */
#define PM_ITEM_CTOR ((void (*)(void *, struct pm_fn *, struct pm_fn *, struct pm_fn *, struct pm_fn *, int32_t, int32_t))0x40072f50u)
#define PM_APPEND     ((void (*)(void *, void *))0x40072786u)
#define PM_FN_DTOR    ((void (*)(struct pm_fn *))0x401709c6u)
#define PM_NEW        ((void *(*)(uint32_t))0x400829d4u)
#define PM_STR        ((void (*)(void *, const char *, void *))0x401bcd4cu)
#define PM_STR_DTOR   ((void (*)(void *))0x401bb29cu)
#define PM_POPUP      ((void (*)(void *, void *))0x400766e8u)
#define PM_SHOW       ((void (*)(void *, void *, int32_t))0x400793f6u)
#define PM_SP_RELEASE ((void (*)(void *))0x40170a0cu)
#define PM_MGR_LABEL  ((void *)0x400f9a38u)   /* SAVE TRACK's managers (re/symbols.toml) */
#define PM_MGR_ACTION ((void *)0x400f9a8au)
#define PM_MGR_ICON   ((void *)0x400f9ae6u)
#define PM_SP_VT      0x401ccab4u             /* shared_ptr's control block vtable, as SAVE TRACK's popup */
const char pm_text[] = "POLY CONFIG";        /* the item (pm_label, below) */
static const char pm_t_none[] = "NO SIDECAR";
static const char pm_t_track[] = "SOUND TRACKS ONLY";
extern const uint8_t pm_label[], pm_action[], pm_icon[];
void pm_menu_add(void *menu);
void pm_pick(void *menu);

void pm_menu_add(void *menu) {
  struct pm_fn f[4];
  void **cap, *item;
  int32_t i;
  if (!menu) return;                   /* (the constructor's caller tests d6 the same way) */
  for (i = 0; i < 4; ++i) f[i].storage = f[i].manager = f[i].invoker = 0, f[i].pad = 0;
  f[0].storage = PM_NEW(1); f[0].manager = PM_MGR_LABEL; f[0].invoker = (void *)pm_label;
  cap = (void **)PM_NEW(4);
  f[2].storage = PM_NEW(1); f[2].manager = PM_MGR_ICON; f[2].invoker = (void *)pm_icon;
  item = PM_NEW(0x54);
  if (!f[0].storage || !cap || !f[2].storage || !item) return;   /* the heap is out at boot: no item */
  *cap = menu;
  f[1].storage = cap; f[1].manager = PM_MGR_ACTION; f[1].invoker = (void *)pm_action;
  PM_ITEM_CTOR(item, &f[0], &f[1], &f[2], &f[3], -1, 8);
  PM_APPEND(menu, item);
  for (i = 3; i >= 0; --i) PM_FN_DTOR(&f[i]);
  pm.adds++;
}

/* A popup over the menu, as SAVE TRACK shows its own (a std::string, the popup, a shared_ptr, the view manager +100). */
static void pm_popup(void *menu, const char *text) {
  uint32_t str[2], sp[2], *cb;
  char alloc;
  void *p;
  PM_STR(str, text, &alloc);
  p = PM_NEW(0xa0);
  cb = (uint32_t *)PM_NEW(0x10);
  if (p && cb) {
    PM_POPUP(p, str);
    cb[0] = PM_SP_VT; cb[1] = 1; cb[2] = 1; cb[3] = (uint32_t)p;
    sp[0] = (uint32_t)p; sp[1] = (uint32_t)cb;
    PM_SHOW(((void **)menu)[25], sp, 0);
    PM_SP_RELEASE(&sp[1]);
  }
  PM_STR_DTOR(str);
}

void pm_pick(void *menu) {
  uint32_t t = SEL_TRACK;
  pm.picks++;
  if (t > 11) { pm.notrack++; pm_popup(menu, pm_t_track); return; }
  if (!(PORT_STATE == 1 && commits != pm.c_hello)) { pm.nohost++; pm_popup(menu, pm_t_none); return; }
  pm.owed = t + 1;
  (*(void (**)(void *))(*(uint8_t **)menu + 128))(menu);   /* close the menu (its vtable +128) */
}

/* the tick after the pick: the page opens on that track's POLY CONFIG (or goes there, open and stepped aside) */
static void pm_tick(void *ctrl) {
  uint32_t o = pm.owed;
  uint8_t pg;
  if (!o) return;
  pm.owed = 0;
  pg = (uint8_t)(PG_POLY + o - 1);
  if (ls.on) ls_close(4);
  st.seq_view = 0;
  if (st.active) { report_mode(1, R_USER, pg); pm.hints++; }
  else { enter(ctrl, R_USER, pg); pm.opens++; }
}

/* the thunks: the detour after the constructor's call (`this` in d6; d0 / d1 / a0 / a1 are free there: the constructor
   returned), its displaced `lea %sp@(24),%sp; tstl %d6` and the rejoin at the `beqs` that tests it; the label's invoker
   (a0: the std::string to build, as SAVE TRACK's label takes it); the action's (sp + 4: the functor, its storage the
   menu); the icon (none) */
__asm__(
    "  .text\n"
    "  .globl pm_menu_det, pm_label, pm_action, pm_icon\n"
    "  .align 2\n"
    "pm_menu_det:\n"
    "  move.l %d6,-(%sp)\n"
    "  jsr pm_menu_add\n"
    "  addq.l #4,%sp\n"
    "  lea 24(%sp),%sp\n"
    "  tst.l %d6\n"
    "  jmp 0x400cb5c4\n"
    "  .align 2\n"
    "pm_label:\n"
    "  link.w %fp,#-4\n"
    "  move.l %a2,-(%sp)\n"
    "  move.l %a0,%a2\n"
    "  pea -1(%fp)\n"
    "  pea pm_text\n"
    "  move.l %a2,-(%sp)\n"
    "  jsr 0x401bcd4c\n"
    "  lea 12(%sp),%sp\n"
    "  move.l %a2,%d0\n"
    "  move.l (%sp)+,%a2\n"
    "  unlk %fp\n"
    "  rts\n"
    "  .align 2\n"
    "pm_action:\n"
    "  move.l 4(%sp),%a0\n"
    "  move.l (%a0),%a0\n"
    "  move.l (%a0),-(%sp)\n"
    "  jsr pm_pick\n"
    "  addq.l #4,%sp\n"
    "  rts\n"
    "  .align 2\n"
    "pm_icon:\n"
    "  rts\n");

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
    if (st.port_ticks == HELLO_TICKS) { st.hello_rx = r; st.hello_n = 1; st.pend_hello = 1; mr.all = 1; mr.kit_owed = 1; sq_forget(); pm.c_hello = commits; }
    else if (st.hello_n && st.hello_n < 3 && st.port_ticks == HELLO_TICKS + 20 * st.hello_n) {
      if (r == st.hello_rx) { st.hello_n++; st.pend_hello = 1; mr.all = 1; mr.kit_owed = 1; } else st.hello_n = 3;
    }
    if (st.pend_hello && sv.on) { sv.pend29 = 1; sv.p_track = sv.track; sv.p_on = 1; sv.vals_all = 1; }   /* 1027 */
  } else {
    st.port_ticks = 0;
    st.hello_n = 0;
    st.pend_hello = 0;
    if (sq.on) sq_forget();            /* 1032 */
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
  ls_tick();                         /* 1038: the bank list closes with the view */
  u46_tick();                        /* 1046: UP + SRC's list */
  pm_tick(ctrl);                     /* 1048: POLY CONFIG picked in the track menu */
  /* 1042: any stock overlay coming on top while the page is open (TEMPO's menu, a FUNC + key menu, a toast, a prompt)
     steps the page aside as 1038's SCALE menu does: stock draws, every key and knob is stock's, the page back when no
     overlay is on top any more (one that was on top when the page opened does not count: only a new top) */
  if (st.active && !st.aside && sv.top_age == 0 && overlay(sv.top_vt)) {
    st.aside = 1; st.aside_seen = 1; st.aside_tick = st.ticks; st.asides++; st.ov_asides++;
  }
  if (st.aside) {                    /* 1038: the SCALE menu came (its view on top), then went: the page back */
    if (!st.active) st.aside = 0;
    else if (sv.top_vt == VT_SCALEMENU || overlay(sv.top_vt)) st.aside_seen = 1;
    else if (st.aside_seen || st.ticks - st.aside_tick > 20) {
      st.aside = 0;
      st.shown = 0xffffffffu;
      st.need_comp = 1;
    }
  }
  if ((st.active || st.splash_on || sv.show) && !st.aside && (commits != st.shown || st.need_comp))
    *((volatile uint8_t *)ctrl + 0x20) = 1;
  if (st.hdr_until) {                /* 1041: the header readout: drawn each tick while it lasts, the page's at its end */
    if ((int32_t)(st.hdr_until - st.ticks) <= 0) st.hdr_until = 0;
    *((volatile uint8_t *)ctrl + 0x20) = 1;
  }
  sq_tick();                         /* 1032: the 2E, seq mode, the 2D reports (seq mode before the LEDs' owner) */
  led_tick();
  pg_tick();                         /* 1032: the PAGE LEDs */
  trk_tick();                        /* 1044: TRK's LED while the page has the keys */
  flush();
  pc_tick();                         /* 1030: the chord write-back */
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

/* 1041: the stock header's readout over the page (the hardware report: turning LEVEL with the page open changed the
   level, but stock's "TRK LEVEL 100" in the header was hidden). Stock 1.73 shows it in the header's left field - glass
   rows 0..8, columns 0..69, the separator at 70, BPM to its right unchanged - from the turn until ~2.4 s after the last
   one (shown 2.36 s after, gone 2.56 s after) [measured, rytm-emu, the stock image: LEVEL 3 x +3 on the main screen].
   Stock keeps drawing its whole screen under the page every draw (drawAll before this), so for that time that field of
   the canvas stays stock's: its own text, font and value, nothing for the host to know. Layout (core/ui/canvas.cpp):
   byte 8 x + 7 - (y >> 3), bit y & 7. */
#define ENC_LEVEL 8                    /* the LEVEL / DATA encoder [measured: rytm-emu encoder 8] */
#define HDR_TICKS 47                   /* 2.35 s: within stock's own time, so the field never shows stock's plain header */
#define HDR_COLS 70
static void hdr_save(const uint32_t *px, uint8_t *keep) {
  const uint8_t *b = (const uint8_t *)px;
  int32_t x;
  for (x = 0; x < HDR_COLS; ++x) keep[2 * x] = b[8 * x + 7], keep[2 * x + 1] = b[8 * x + 6];
}
static void hdr_put(uint32_t *px, const uint8_t *keep) {
  uint8_t *b = (uint8_t *)px;
  int32_t x;
  for (x = 0; x < HDR_COLS; ++x) b[8 * x + 7] = keep[2 * x], b[8 * x + 6] = (uint8_t)((b[8 * x + 6] & 0xfe) | (keep[2 * x + 1] & 1));
}
static void draw_page(void *bmp, void *ctrl);
static void draw_body(void *bmp, void *ctrl) {
  uint8_t keep[2 * HDR_COLS];
  uint32_t *px = *(uint32_t **)((uint8_t *)bmp + 16);   /* canvas(+4 w, +8 h, +16 pixels) 0x4006f9c2 */
  int32_t hdr = st.hdr_until && (int32_t)(st.hdr_until - st.ticks) > 0;
  if (hdr) hdr_save(px, keep);
  draw_page(bmp, ctrl);
  if (hdr && (st.active || st.splash_on || sv.show) && !(st.active && st.aside)) hdr_put(px, keep);
}
static void draw_page(void *bmp, void *ctrl) {
  uint32_t *px = *(uint32_t **)((uint8_t *)bmp + 16);   /* canvas(+4 w, +8 h, +16 pixels) 0x4006f9c2 */
  uint32_t c;
  int32_t i;
  (void)ctrl;
  if (!st.active && !st.splash_on && !sv.show) return;
  if (st.active && st.aside) return;   /* 1038: stock's SCALE menu on the glass */
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
  /* 1037b: PLAY MODE without FUNC is a pad-mode key like MUTE / CHRO (passed by every host mask): always stock's, so it
     leaves MUTE mode with the page open (the host's masks caught it: "from MUTE mode PLAY needs MUTE again", the hardware
     report on rui1037 with seq mode's page open) [measured: stock 1.73 MUTE then PLAYMODE = play mode again, LED 50;
     rui1037 with the page open: MUTE mode stays]. FUNC + PLAY MODE (the KIT menu, which would open under the page)
     stays the mask's. */
  if (code == K_PLAYMODE && !BIT(st.stock_down, K_FUNC) && !BIT(st.our_down, K_FUNC) && !BIT(st.both_down, K_FUNC))
    return 0;
  if (mask_set && !(mask_keys[code >> 5] >> (code & 31) & 1)) return 0;
  return code == K_FUNC ? 2 : 1;
}

static int32_t key_body(void *brain, void *ev) {
  uint32_t code = *(uint32_t *)((uint8_t *)ev + 12) & 0xff;
  uint32_t down = *(uint32_t *)((uint8_t *)ev + 16) & 1;
  int32_t o;
  (void)brain;
  if (code == K_FILL && down != ed.fill) { ed.fill = down; ed.fill_owed = 1; }   /* 1033: 2D 0C FILL (stock keeps it) */
  st.last_key = code | down << 8 | (*(uint32_t *)((uint8_t *)ev + 16) & 0xfe) << 8;
  if (!down) {   /* a release goes where its press went, whatever the mask or the mode is now */
    if (code == K_UP && k44.up_on) {  /* 1044: the combo map goes with UP */
      k44.up_on = 0;
      if (k44.up_map) { k44.up_map = 0; k44.map_req = 2; }
    }
    if (code == K_UP) {               /* 1046 */
      u46.up_used = 0;
      if (u46.seq) { u46.seq = 0; return 1; }   /* taken on a poly track: its release too */
    }
    if (code == K_TRK) tk.used = 0;   /* 1037b: the next TRK hold starts fresh */
    if (code == K_TRK && tk.stock_trk) {   /* 1040: stock had this TRK's press (TRK + pad): its release too */
      tk.stock_trk = 0;
      if (BIT(st.our_down, code)) { CLR(st.our_down, code); if (st.active) { queue_key(code, 0); flush(); } }
      return 0;
    }
    if ((code == K_NO || code == K_YES) && BIT(st.stock_down, code)) {   /* 1052d: stock's NO / YES + SCNE / CHRO /
      PLAYMODE (its reloads and quick saves) takes that key's release before 0026 sees it [measured, rytm-emu: the page
      open or not, the key stayed in stock_down]: unbooked at NO's / YES's release - only when NO / YES was stock's (the
      combo stock ran: round 5, L5) - a later release of it still goes to stock (a press nobody booked) */
      if (BIT(st.stock_down, K_SCNE) || BIT(st.stock_down, K_CHRO) || BIT(st.stock_down, K_PLAYMODE)) nk.unbooked++;
      CLR(st.stock_down, K_SCNE); CLR(st.stock_down, K_CHRO); CLR(st.stock_down, K_PLAYMODE);
    }
    if (code == K_NO && nk.no_def) {  /* 1052d: NO kept back, released alone: the page's back (press and release) */
      nk.no_def = 0;
      CLR(st.our_down, code);
      if (st.active) { queue_key(code, 1); queue_key(code, 0); flush(); }
      return 1;
    }
    if (BIT(st.eat, code)) { CLR(st.eat, code); return 1; }               /* the combo's YES: never seen */
    if (ls_release(code)) return 1;   /* 1038: a nav key pressed while the bank list was open */
    if (BIT(sq.down, code)) { CLR(sq.down, code); queue_key(code, 0); flush(); return 1; }   /* 1032: seq mode's */
    if (BIT(st.stock_down, code)) {   /* pressed before: stock's */
      CLR(st.stock_down, code);
      if (code >= K_PUSH0 && code <= K_PUSH7 && (ux.push >> (code - K_PUSH0) & 1)) {   /* 1036: the SRC view's push */
        ux.push &= ~(1u << (code - K_PUSH0));
        queue_key(code, 0);
        flush();
      }
      return 0;
    }
    if (BIT(st.both_down, code)) {
      CLR(st.both_down, code);
      if (st.active || sq.mode) { queue_key(code, 0); flush(); }
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
  if (BIT(st.our_down, code) || BIT(sq.down, code)) return 1;   /* a repeat of a held key: to whoever took its press */
  if (BIT(st.stock_down, code) || BIT(st.both_down, code)) return 0;
  /* 1052d (the user): NO held on a page + a reload key (SCNE the pattern, CHRO the track, PLAYMODE the kit): both are
     stock's, so its NO + key reload works under the page - NO's press given to stock now (it never went to the host:
     kept back below), its release then stock's too; the key stock's. Any other key while NO is kept back: NO's press to
     the host first (its order kept), then that key as always. */
  if (nk.no_def && (code == K_SCNE || code == K_CHRO || code == K_PLAYMODE)) {
    uint32_t e2[8];
    int32_t i;
    for (i = 0; i < 8; ++i) e2[i] = ((const uint32_t *)ev)[i];
    e2[3] = (e2[3] & ~0xffu) | K_NO;
    e2[4] |= 1;
    nk.no_def = 0;
    nk.combos++;
    CLR(st.our_down, K_NO);
    SET(st.stock_down, K_NO);
    STOCK_KEY(brain, e2);              /* NO down, as stock would have had it */
    SET(st.stock_down, code);
    return 0;
  }
  if (nk.no_def) {
    nk.no_def = 0;
    nk.no_late++;
    if (st.active) { queue_key(K_NO, 1); flush(); }   /* (NO stays the host's: its release goes there) */
  }
  /* 1044: UP pressed with the page closed (it goes to stock below, as before): held alone for UP_MAP_TICKS, the host is
     asked for its combo map (dp_tick); a trig meanwhile (UP + Tn) is a combo, no map */
  /* 1050: with the page open too (not stepped aside under a stock overlay: UP is that menu's cursor then): 49 1 5, the
     map over the page (the host shows that page again at the release; UP alone still steps no page there) */
  if (code == K_UP && !(st.active && st.aside) && !HELD(K_FUNC)) {   /* (round 5, L6: FUNC + UP is no map) */
    k44.up_on = 1; k44.up_trig = 0; k44.up_t0 = st.ticks;
  }
  if (code == K_FUNC) nk.func_masks = masks;   /* 1052d: the masks taken when FUNC went down (the UP / DOWN rule) */
  if (code == K_UP) u46.up_d0 = st.ticks;
  /* 1046: on a poly track (seq mode) with a trig held (the host's: sq.down, or the page's with the SEQ page open) UP is
     the Sidecar's at once (the user: stock's held trig + arrow is of no use there - stock never saw that trig): never
     stock's nor the host's page's, no map; RECORD / STOP / PLAY with it below are the steps' copy / paste / clear */
  if (code == K_UP && sq.mode && !(st.active && st.aside) && ((sq.down[0] | (st.active ? st.our_down[0] : 0)) & 0xffffu)) {
    u46.seq = 1; u46.seq_ups++;
    k44.up_on = 0;
    return 1;
  }
  /* 1037b: YES pressed while TRK is still held after TRK + TRIG / TRK + LFO opened the page (its make prompt) is the
     page's YES, below: the hardware report rui1037 "the make prompt's YES did nothing" - a TRK still down from TRK + TRIG
     made it TRK + YES, which left the page unanswered (no seq track), and GRID REC's trigs then went to stock's own
     track [measured, rytm-emu + the real core, sq_emu.py trkyes] */
  /* 1046: UP + YES as TRK + YES (UP held UP_YES_TICKS first: a menu's UP then YES pressed a little early stays
     stock's; u46.yes_early counts those). With UP's map on the glass (the host's KEYS page, opened by UP held) it is
     the SIDECAR page, not a leave: the map's release then leaves it open. */
  if (code == K_YES && (tk.used || u46.up_used) && st.active) tk.yes_page++;
  else if (code == K_YES && (HELD(K_TRK) || (UPH() && st.ticks - u46.up_d0 >= UP_YES_TICKS))) {
    SET(st.eat, code);              /* TRK + YES: in or out, never forwarded, nor its release */
    if (!HELD(K_TRK)) { u46.yes++; u46.combos++; k44.up_trig = 1; }
    if (st.active && k44.up_map && !k44.map_page && !HELD(K_TRK)) { report_mode(1, R_USER, 0); flush(); }   /* 1050: over a page: out */
    else if (st.active) leave(*(void **)((uint8_t *)brain + 32), R_ESCAPE);
    else enter(*(void **)((uint8_t *)brain + 32), R_USER, 0);
    return 1;
  }
  else if (code == K_YES && UPH()) u46.yes_early++;
  /* 1026, TRK + LFO: the page opens on the Sidecar's LFO page; while open, the host goes there (the 30 again). The LFO
     press and release never reach stock (its LFO page would open under ours) nor the host. */
  if (code == K_LFO && (HELD(K_TRK) || UPH())) {   /* 1046: UP + LFO the same */
    if (!HELD(K_TRK)) { u46.up_used = 1; u46.combos++; k44.up_trig = 1; }
    SET(st.eat, code);
    if (HELD(K_TRK)) tk.used = 1;                     /* 1037b */
    st.seq_view = 0;                   /* 1036: the LFO page now, not TRK + TRIG's SEQ */
    if (st.active) { report_mode(1, R_USER, PG_LFO); st.lfo_hints++; flush(); }
    else { enter(*(void **)((uint8_t *)brain + 32), R_USER, PG_LFO); st.lfo_opens++; }
    return 1;
  }
  /* 1041, TRK + FX: as TRK + LFO, on the Sidecar's INSERT page (30 page 2). Stock 1.73 binds nothing to TRK + FX: on
     the main screen and in GRID REC it leaves what FX alone leaves (plus TRK's own LED), and on the FX page TRK held +
     FX is TRK then FX, each key's own action [measured, rytm-emu, rled_emu.py stocktrkfx]. The FX press and release
     reach neither stock (its FX page would open under ours) nor the host. Before seq mode's held-trig keys, so a held
     trig + FX without TRK stays the host's FX lock key. */
  if (code == K_FX && (HELD(K_TRK) || UPH())) {   /* 1046: UP + FX the same */
    if (!HELD(K_TRK)) { u46.up_used = 1; u46.combos++; k44.up_trig = 1; }
    SET(st.eat, code);
    if (HELD(K_TRK)) tk.used = 1;                     /* 1037b: YES on its page while TRK is held is the page's */
    st.seq_view = 0;
    if (st.active) { report_mode(1, R_USER, PG_INS); st.ins_hints++; flush(); }
    else { enter(*(void **)((uint8_t *)brain + 32), R_USER, PG_INS); st.ins_opens++; }
    return 1;
  }
  /* 1047, UP + AMP: the Sidecar's INSERT page opened on its OUT view (the stereo / POST route: OUT, LEV, PAN, WID, DEC),
     for the selected track: 30 page 3, as UP + FX's 30 page 2 (again while open: go there). Stock 1.73 leaves UP + AMP
     free in all four measured contexts [rled_emu.py stockupkeys]; AMP is eaten, neither stock's AMP page nor the host's
     sees it. UP only (TRK + AMP stays stock's); not under a held trig (the lock page's AMP: seq mode's or stock's). */
  if (code == K_AMP && UPH() && !HELD(K_TRK) && !(sq.mode && (sq.down[0] & 0xffffu)) && !(st.stock_down[0] & 0xffffu)) {
    u46.up_used = 1; u46.combos++; u46.amp++; k44.up_trig = 1;
    SET(st.eat, code);
    st.seq_view = 0;
    if (st.active) { report_mode(1, R_USER, PG_INSOUT); st.ins_hints++; flush(); }
    else { enter(*(void **)((uint8_t *)brain + 32), R_USER, PG_INSOUT); st.ins_opens++; }
    return 1;
  }
  /* 1037, TRK + TRIG (1036's FUNC + LFO, which is stock's again): the page opens on the Sidecar's SEQ page of the
     selected track (30 page 0x10 + track); with the page open it goes there (the 30 again), and when TRK + TRIG sent it
     there, TRK + TRIG leaves (reason 3, as TRK + YES). Stock 1.73's TRK + TRIG is TRIG alone (TRK alone changes only
     its own LED) on the main screen, in GRID REC and on the TRIG page [measured, rytm-emu, rled_emu.py stocktrktrig]:
     the TRIG press and release reach neither stock nor the host; TRK stays whose it was. Before seq mode's held-trig
     keys, so a held trig still opens the SEQ page; TRIG without TRK under a held trig stays the host's lock key. */
  if (code == K_TRIG && (HELD(K_TRK) || UPH())) {   /* 1046: UP + TRIG the same */
    if (!HELD(K_TRK)) { u46.up_used = 1; u46.combos++; k44.up_trig = 1; }
    uint8_t pg = (uint8_t)(PG_SEQ + (SEL_TRACK < 12 ? SEL_TRACK : 0));
    SET(st.eat, code);
    if (HELD(K_TRK)) tk.used = 1;                     /* 1037b */
    if (st.active && st.seq_view) { leave(*(void **)((uint8_t *)brain + 32), R_ESCAPE); st.tt_closes++; }
    else if (st.active) { report_mode(1, R_USER, pg); st.seq_view = 1; st.tt_hints++; flush(); }
    else { enter(*(void **)((uint8_t *)brain + 32), R_USER, pg); st.seq_view = 1; st.tt_opens++; }
    return 1;
  }
  /* 1036b, UP held + T1..T5: the Pi display's page (1 HOME, 2 SEQ, 3 PAT, 4 VOICE, 5 SET; 49 1 <page>). Stock 1.73 has no
     UP + trig combo: on the main screen, in GRID REC, on FLTR, in CHRO and MUTE mode UP + T3 / T5 leave exactly what the
     trig alone leaves, and UP alone changes nothing on the main screen or in GRID REC [measured, rytm-emu]. The trig's
     press and release are eaten (no trig placed, nothing to the host's seq), UP stays whose it was. 1038: T6..T10 too
     (6 INSERT FX, 7 SAMPLE / AUTO, 8 REC, 9 SCOPE, 10 SIDECAR; stock's UP + T6..T10 = T alone [measured, rled_emu.py
     stockup]). 1046: T11..T13 too (11 SONG, 12 PROJECT, 13 POOL; stock's UP + T11..T13 = T alone, a menu open too
     [measured, stockup]); the page map is the host's (49 1 carries the trig's number only). */
  if (code <= 12 && UPH()) {
    SET(st.eat, code);
    dp.page_req = code + 1;
    dp.pages++;
    if (!k44.up_map) k44.up_trig = 1;   /* 1044: a combo, not the map (a trig while the map shows: both) */
    return 1;
  }
  /* 1046, UP + SRC (the page closed, no host trig held: a held trig + SRC stays the host's lock page): the selected
     track's source list in one press. SRC goes to stock (its SRC page: the 1027 view on a Sidecar machine); on
     GRANULAR / WAVETABLE / MULTISAMPLE the bank list opens on knob A once the view shows the host's frame (u46_tick,
     within a second), as knob A's first turn would. On DSP SAMPLE (its SMP on the SMPL page, 1045) stock gets SMPL
     instead (a press and release of its own) and the list opens on knob D. Any other track: SRC alone. A trig held
     (seq mode's, or stock's in GRID REC: its lock page) leaves SRC to them. */
  if (code == K_SRC && UPH() && !st.active && !st.splash_on && !(sq.mode && (sq.down[0] & 0xffffu)) &&
      !(st.stock_down[0] & 0xffffu)) {   /* (a stock trig held: SRC is its lock page, stock's) */
    int32_t t = SEL_TRACK;
    uint32_t m = t <= 11 ? MACHINE_OF(t) : 0;
    u46.src++; u46.combos++;
    k44.up_trig = 1;
    if (ls.on) ls_close(4);
    u46.src_t = 0;
    if (t <= 11 && (ls_banked(m) || m == DSPS_M) && mr_vb(t, m) != 0x7f) { u46.src_t = st.ticks | 1; u46.src_m = m; }
    if (u46.src_t && m == DSPS_M) {
      uint32_t e2[8];
      int32_t i;
      for (i = 0; i < 8; ++i) e2[i] = ((const uint32_t *)ev)[i];
      e2[3] = (e2[3] & ~0xffu) | K_SMPL;
      STOCK_KEY(brain, e2);              /* SMPL down */
      e2[4] &= ~1u;
      STOCK_KEY(brain, e2);              /* and up */
      SET(st.eat, code);
      return 1;
    }
    SET(st.stock_down, code);
    return 0;
  }
  /* 1038: FUNC + PAGE with the page open (hardware report rui1037: on a seq track in GRID REC the host's SEQ page hid
     stock's SCALE menu): PAGE goes to stock, which opens SCALE (its ScaleMenuView on top [measured]); the page steps
     aside - stock draws, every key and knob is stock's - until that view goes (NO, FUNC + PAGE again), then the host's
     last frame is back. 2D 04 reports the new scale as always (sc_poll). */
  if (st.active && code == K_PAGE && (BIT(st.stock_down, K_FUNC) || BIT(st.our_down, K_FUNC) || BIT(st.both_down, K_FUNC))) {
    SET(st.stock_down, code);
    if (!st.aside) { st.aside = 1; st.aside_seen = 0; st.aside_tick = st.ticks; st.asides++; }
    *((volatile uint8_t *)*(void **)((uint8_t *)brain + 32) + 0x20) = 1;
    return 0;
  }
  /* 1038: the bank list open (the page closed): the nav keys are the list's, another key closes it and goes on */
  if (!st.active && ls_key(code)) return 1;
  /* 1049: FUNC + YES on a banked machine's or DSP SAMPLE's SRC view (the host's): the list with the host's browser */
  if (!st.active && !ls.on && code == K_YES && !st.splash_on && sv.on && sv.show && !sv.covered && ls.qn + 2 <= LS_NQ &&
      (int32_t)sv.track == SEL_TRACK && (ls_banked(sv.mach) || sv.mach == DSPS_M) && !(sq.mode && (sq.down[0] & 0xffffu)) &&
      (BIT(st.stock_down, K_FUNC) || BIT(st.both_down, K_FUNC) || BIT(st.our_down, K_FUNC))) {
    ls.track = sv.track; ls.mach = sv.mach; ls.p = sv.mach == DSPS_M ? DSPS_P : 0; ls.smpl = 0;
    ls.on = 1; ls.knob = sv.mach == DSPS_M ? 3 : 0; ls.tick0 = st.ticks;
    ls.opens++; ls.srcyes++;
    ls_queue(1, 0);
    ls.browse = 1; ls.br_ack = 0; ls.br_tick = st.ticks; ls.br_gen = ls_in_gen; ls.browses++;
    ls_queue(3, 6);
    SET(st.eat, code);
    flush();
    return 1;
  }
  /* the splash: playing keys (transport, pads) play under it; any other key ends it, a navigation key only that (a
     confirm or cancel under a hidden menu never happens blind), the rest also reach stock */
  if (!st.active && st.splash_on && !(code >= K_REC && code <= K_STOP) && !(code >= K_PAD0 && code <= K_PAD1)) {
    splash_end(*(void **)((uint8_t *)brain + 32), S_KEY);
    if (code >= K_NAV0 && code <= K_NAV1) { SET(st.eat, code); return 1; }
  }
  /* 1033, seq mode: a host-held trig or PAGE + FUNC + RECORD / STOP / PLAY is the host's copy / paste / clear of those
     steps or of its page (2D 0A, src 1): caught (stock would copy / paste / clear the whole Rytm track, or its locks),
     the release eaten too. Without a held trig or PAGE, FUNC + RECORD / STOP / PLAY stays stock's (the track's, reported
     by the wrappers). FUNC + PAGE (SCALE) stays stock's: PAGE with FUNC held is not caught. */
  /* 1040: also with the page open (the hardware report on rui1039: "step copy breaks out of the seq track"). Seq mode
     opens the host's SEQ page (core/seq on 2D 08 1), so the trigs and PAGE held are the page's (st.our_down, its catch
     mask), not sq.down, and RECORD / STOP / PLAY went to stock (key_owner: always stock's): stock's FUNC + REC in GRID
     REC is COPY TRK, FUNC + STOP PASTE TRK, FUNC + PLAY CLEAR TRK of the whole track (2D 0A ops 5 / 6 / 7, src 0), and
     the host applied them to its whole track (CLEAR wiped every step) [measured, rytm-emu rui1039 + the real core]. Not
     with SCALE aside (every key stock's there). */
  /* 1046: UP + RECORD / STOP / PLAY the same with a trig held (the user's one-handed form; UP taken at its press,
     u46.seq): without a held trig UP + RECORD / STOP / PLAY is stock's transport as always, nothing new */
  if (sq.mode && !(st.active && st.aside) && code >= K_REC && code <= K_STOP &&
      (((BIT(st.both_down, K_FUNC) || BIT(st.stock_down, K_FUNC) || BIT(st.our_down, K_FUNC)) &&
        (((sq.down[0] | (st.active ? st.our_down[0] : 0)) & 0xffffu) || BIT(sq.down, K_PAGE) ||
         (st.active && BIT(st.our_down, K_PAGE)))) ||
       (UPH() && ((sq.down[0] | (st.active ? st.our_down[0] : 0)) & 0xffffu)))) {
    if (UPH()) u46.seq_ops++;
    uint32_t trigs = (sq.down[0] | (st.active ? st.our_down[0] : 0)) & 0xffffu;
    uint32_t op = trigs ? (code == K_REC ? ED_RCOPY : code == K_STOP ? ED_RPASTE : ED_RCLEAR)
                        : (code == K_REC ? ED_GCOPY : code == K_STOP ? ED_GPASTE : ED_GCLEAR);
    SET(st.eat, code);
    ed_queue(op, 1, 1, trigs);
    return 1;
  }
  if (!st.active && sq.mode && code == K_PAGE && (BIT(st.both_down, K_FUNC) || BIT(st.stock_down, K_FUNC))) {
    SET(st.stock_down, code);          /* 1033: FUNC + PAGE: stock's SCALE menu, also on a seq track in GRID REC */
    ed.scale_keys++;
    return 0;
  }
  /* 1036, seq mode with the page closed and a host trig held: the page keys (TRIG SRC SMPL FLTR AMP LFO, FX), NO and the
     encoders' pushes are the host's too (its p-lock pages: hold trig + SRC + turn locks the held steps; NO / a push clears),
     not stock's (its page would open with the sound's own values, and the turns, the host's under a held trig, would
     edit nothing there). The release goes where the press went (sq.down). 1037: YES too (the host's step preview: hold
     trig + YES plays the held steps' notes). Stock 1.73's trig held + YES is YES alone, in GRID REC and outside it
     [measured, rytm-emu, rled_emu.py stockyes]; seq mode is a Sidecar seq track selected in GRID REC, so other tracks
     keep stock's YES. */
  if (!st.active && sq.mode && (sq.down[0] & 0xffffu) &&
      ((code >= K_PG0 && code <= K_LFO) || code == K_FX || code == K_NO || code == K_YES ||
       (code >= K_PUSH0 && code <= K_PUSH7))) {
    st.lock_keys++;
    SET(sq.down, code);
    queue_key(code, 1);
    flush();
    return 1;
  }
  /* 1032, seq mode with the page closed: T1..T16 and PAGE the host's, FUNC both sides' (the page open: its mask).
     1040: TRIG too (the user's request after rui1039: on a seq track TRIG shows the Sidecar's SEQ page, again its trig
     values, as stock's TRIG page beside the grid; the host opens the page on it). TRK + TRIG (the SEQ page in / out)
     is above and never gets here. */
  if (!st.active && sq.mode && (code <= 0x0f || code == K_PAGE || code == K_FUNC || code == K_TRIG)) {
    sq.keys++;
    if (code == K_FUNC) SET(st.both_down, code); else SET(sq.down, code);
    queue_key(code, 1);
    flush();
    return code == K_FUNC ? 0 : 1;
  }
  /* 1036, the SRC view: an encoder's push goes to the host (31 down / up) and to stock, as before (nothing caught):
     the host's source list (GRANULAR SRC, WAVETABLE TBL, MULTISAMPLE INST) stays open while P1's push is held */
  if (!st.active && sv.on && code >= K_PUSH0 && code <= K_PUSH7) {
    ux.push |= 1u << (code - K_PUSH0);
    ux.pushes++;
    queue_key(code, 1);
    flush();
    SET(st.stock_down, code);
    return 0;
  }
  /* 1040 (hardware report on rui1039: "TRK + pad does not select the track in seq mode"): with the page open TRK is the
     host's alone (key_owner), so stock saw the pad without TRK - in CHRO mode or outside GRID REC a plain pad, no
     selection [measured, rytm-emu rui1039: seq mode on BD, CHRO, TRK + SD -> SD's chromatic note, still BD]. A pad
     pressed while that TRK is held gives stock the TRK press first (its own handler, a copy of this event as TRK down),
     then the pad: stock's TRK + pad (track select) as without the page; TRK's release then goes to stock as well. */
  if (code >= K_PAD0 && code <= K_PAD1 && BIT(st.our_down, K_TRK) && !tk.stock_trk) {
    uint32_t e2[8];
    int32_t i;
    for (i = 0; i < 8; ++i) e2[i] = ((const uint32_t *)ev)[i];
    e2[3] = (e2[3] & ~0xffu) | K_TRK;
    e2[4] |= 1;
    tk.stock_trk = 1;
    tk.injects++;
    STOCK_KEY(brain, e2);
  }
  /* 1052d, the YES timing rule (ux1027's review): on the page YES is the host's whenever FUNC or a page trig is down
     (FUNC + YES the Sidecar's UNDO, trig + YES its preview) - also inside the moment before the host's mask has YES;
     YES pressed with neither down goes by the mask as before, so YES held + SCNE / PLAYMODE / CHRO (stock's quick saves)
     works under a page whose mask leaves YES out. The release follows the press (our_down). The same for UP / DOWN
     with FUNC down (the controller, 2026-10-28: the poly SEQ page leaves UP / DOWN to the Rytm - CHRO's octave shift -
     and its track menu is FUNC + DOWN): FUNC then DOWN / UP is the host's even before its mask with them arrives;
     UP / DOWN without FUNC go by the mask. Round 5 (L6): UP / DOWN only until the host's next mask (masks unchanged
     since FUNC went down: the moment before the host can answer FUNC), then the mask decides; a host page only. */
  if (st.active && !st.aside && ((code == K_YES && (HELD(K_FUNC) || (st.our_down[0] & 0xffffu))) ||
                                 ((code == K_DOWN || code == K_UP) && HELD(K_FUNC) && masks == nk.func_masks))) {
    st.k_caught++;
    if (code == K_YES) nk.yes_host++; else nk.updn_host++;
    SET(st.our_down, code);
    queue_key(code, 1);
    flush();
    return 1;
  }
  /* 1052d: NO on the page (the mask catches it, no other key of the page's held): kept back to its release or the next
     key (above), so NO + a reload key can still be stock's; NO alone is the page's back as before, at its release */
  if (code == K_NO && st.active && !st.aside && key_owner(K_NO) == 1) {
    int32_t i, any = 0;
    for (i = 0; i < 8; ++i) any |= st.our_down[i] != 0 || st.both_down[i] != 0;   /* (round 5, M1: a caught FUNC too) */
    if (!any && !HELD(K_FUNC)) {   /* (FUNC + NO is the host's: its NOTE EDIT delete, never held back) */
      st.k_caught++;
      nk.no_def = 1;
      SET(st.our_down, code);
      return 1;
    }
  }
  o = st.active && !st.aside ? key_owner(code) : 0;   /* 1038: the SCALE menu aside: stock's */
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
  idx = *(const int32_t *)(e + ENC_IDX_OFF);
  delta = *(const int32_t *)(e + ENC_DELTA_OFF);
  if (!st.active && sq.mode && (sq.down[0] & 0xffffu) && idx >= 0 && idx < 8) {   /* 1032: a seq trig held: A..H */
    st.func = e[20] || BIT(st.stock_down, K_FUNC) || BIT(st.both_down, K_FUNC) ? 1 : 0;
    st.acc[idx] += delta;
    sq.encs++;
    flush();
    return 1;
  }
  if (!st.active) {
    if (ls_enc(idx, delta)) return 1;   /* 1038: the bank list (opened by knob A on a banked SRC view) */
    if (idx == ENC_LEVEL && sv.show) st.hdr_until = st.ticks + HDR_TICKS, st.hdrs++;   /* 1041: over the SRC view too */
    if (st.splash_on) splash_end(*(void **)((uint8_t *)brain + 32), S_ENC);   /* the turn reaches stock, seen at once */
    return 0;
  }
  if (st.aside) { st.e_passed++; return 0; }   /* 1038: the SCALE menu's */
  if (mask_set && !(idx >= 0 && idx < NENC && (mask_enc >> idx & 1))) {   /* stock's knob */
    st.e_passed++;
    if (idx == ENC_LEVEL) st.hdr_until = st.ticks + HDR_TICKS, st.hdrs++;   /* 1041: its header readout over the page */
    return 0;
  }
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

/* ---- 1031: 6-OP FM's chord knobs and MULTISAMPLE's labels (0021's us_cubox) -----------------------------------------
 * MULTISAMPLE is machine 52 (CB TEST; 0021: ext_render, voice flag 0x30 = rytm-teensy core/machines.h kMultiMachine).
 * Its SRC knobs are records 398 443 399 400 401 402 406 407 (BT IMPROVED's five, DSP SAMPLE's unused word-19 copy,
 * FUNC. GEN.'s last two; numbers, CCs and defaults by registry patch): INST VEL LEV RTRG ATK DEC SUS REL
 * (rytm-teensy core/msamp/msamp.h). Their names and looks are set once here. Page 2 (SMPL) of MULTISAMPLE and the E..H
 * knobs of 6-OP FM's are 0021's shared page-2 records (us_p2rec, also the user slots'): 0021's us_page_record calls
 * cu_setup(machine) for these two machines (and forgets its own slot set-up), which writes TUNE FINE STRT LOOP CHD INV
 * SPR VOI over them unless they still hold them. The value texts are the host's (core/poly.cpp value_text, sim/protocol.py
 * chord_value_text): CHD OFF MAJ MIN SUS2 SUS4 7 MAJ7 MIN7 DIM AUG 6 MIN6 9 ADD9 MIN9 5, INV0..3, SPR0..2, VOI AUTO 1..6,
 * each its value as the index, out of range the first; LOOP AUTO / OFF / ON in three zones (msamp.h), RTRG OFF / ON
 * (>= 64). cu_steps answers 0021's ext_steps for them (0029's stepped list knobs): the chord knobs lists of 16 4 3 7,
 * LOOP 3 zones, RTRG 2 zones, INST all 128. */
typedef int32_t (*cu_printf_fn)(void *str, const char *fmt, ...);
#define CU_PRINTF  ((cu_printf_fn)0x40098602u)
#define CU_REC(r)  ((uint32_t *)(0x401bf918u + 0x34u * (uint32_t)(r)))
#define CU_DESC(r) ((uint32_t *)(0x419a4888u + 84u * (uint32_t)(r)))
#define CUBOX      ((volatile uint32_t *)0x4001a3dcu)   /* 0021's us_cubox (.ush): 'CHRD', setup, steps */
#define CU_IDS     ((volatile uint32_t *)0x413db5fcu)   /* sound_param_id_for_index's per-machine table: [m * 8 + index - 9] */
#define CU_DIAL 410      /* 0021's REC_DIAL: a plain dial */
#define CU_BIPOLAR 40    /* SMPL FIN: centred dial */
#define CU_LEVEL 101     /* BD HARD LEV: fader */
#define CU_FM 40
#define CU_WT 46         /* 1034: WAVETABLE (RS TEST; 0021: ext_render, voice flag 0x28) */
#define CU_GR 47         /* 1034: GRANULAR (BT TEST; 0021: ext_render, voice flag 0x38) */
#define CU_LI 48         /* 1051: LIVE IN (LT TEST; 0021: ext_render, voice flag 0x78; rytm-teensy docs/LIVE-IN.md 4) */
#define CU_CP 49         /* 1051: CHOP (MT TEST; 0021: ext_render, voice flag 0x18; rytm-teensy docs/CHOP.md) */
#define CU_MS 52
/* steps: 0021's ext_steps answer (0029's stepped knobs: mode << 8 | N; 0 continuous) */
struct cu_knob { const char *lng, *sht; int16_t look; uint8_t text, def; uint16_t steps; };
static const int16_t cu_p2[8] = {438, 457, 458, 459, 460, 403, 404, 405};   /* 0021's us_p2rec: sample words 17..24 */
static const int16_t cu_src[8] = {398, 443, 399, 400, 401, 402, 406, 407};  /* MULTISAMPLE / WAVETABLE / GRANULAR P1..P8 */
static const char cu_chd[16][5] = {"OFF", "MAJ", "MIN", "SUS2", "SUS4", "7", "MAJ7", "MIN7",
                                   "DIM", "AUG", "6", "MIN6", "9", "ADD9", "MIN9", "5"};
static const char cu_loop[3][5] = {"AUTO", "OFF", "ON"};
/* 1034: the host's value texts (rytm-teensy docs/WAVETABLE.md 6, docs/GRANULAR.md 5) */
static const char cu_warp[4][5] = {"OFF", "SYNC", "PWM", "FM"};
static const char cu_win[4][6] = {"HANN", "TRI", "TUKEY", "PERC"};
static const char cu_anim[8][5] = {"8BAR", "4BAR", "2BAR", "1BAR", "1/2", "1/4", "1/8", "1/16"};
static const char cu_frz[] = "FRZ", cu_off[] = "OFF";
const char cu_ms_name[] = "MULTISAMP";   /* machine 52's names (registry patches); MULTISAMPLE is clipped in the list */
const char cu_ms_short[] = "MSMP";
const char cu_wt_name[] = "WAVETABLE";   /* 1034: machine 46's names (registry patches) */
const char cu_wt_short[] = "WTBL";
const char cu_gr_name[] = "GRANULAR";    /* 1034: machine 47's names (registry patches) */
const char cu_gr_short[] = "GRAN";
const char cu_li_name[] = "LIVE IN";     /* 1051: machine 48's names (registry patches) */
const char cu_li_short[] = "LVIN";
const char cu_cp_name[] = "CHOP";        /* 1051: machine 49's names (registry patches) */
const char cu_cp_short[] = "CHOP";
/* 1051: LIVE IN's and CHOP's list texts (rytm-teensy docs/LIVE-IN.md 4, docs/CHOP.md "On the Rytm") */
static const char cu_inpt[4][4] = {"L", "R", "L+R", "STR"};
static const char cu_mon[2][5] = {"ALW", "TRIG"};
static const char cu_slc[] = "SLC";
static const char cu_hold[] = "HOLD";   /* 1051: CHOP's DEC fully up (the host: no decay) */
static const char cu_tape[4][5] = {"SLC", "OFF", "STOP", "SPIN"};
static const char cu_dir[3][4] = {"SLC", "FWD", "REV"};
static const char cu_cloop[4][5] = {"SLC", "OFF", "FWD", "PING"};
static const char cu_fmt_db[] = "%dDB", cu_fmt_pd[] = "+%d", cu_fmt_x[] = "X%d", cu_fmt_pct[] = "%d%%";
static const char cu_fm_short[] = "6OP";
static const char cu_fmt_s[] = "%s", cu_fmt_d[] = "%d", cu_fmt_bk[] = "%c%03d", cu_fmt_inv[] = "INV%d", cu_fmt_spr[] = "SPR%d";
/* text: 0 the look's own, 1 OFF / ON, 2 LOOP, 3 CHD, 4 INV, 5 SPR, 6 VOI, 7 WARP (4 zones), 8 WIN (4 zones),
   9 SRC (the host's names (47), else names 0..11, a number above), 12 TBL / INST (the host's names, else a number),
   10 HOLD (0..119: v x 99 / 119, 120..127 FRZ), 11 ANIM (0 OFF, then 8BAR 4BAR 2BAR
   1BAR 1/2 1/4 1/8 1/16 by 16s) */
#define CU_CHORD                                                                                                      \
  {"Chord", "CHD", CU_DIAL, 3, 0, 0x610}, {"Inversion", "INV", CU_DIAL, 4, 0, 0x604},                                 \
      {"Spread", "SPR", CU_DIAL, 5, 0, 0x603}, {"Voices", "VOI", CU_DIAL, 6, 0, 0x607}
/* the chord lists of 16 4 3 7; bit 10: a value beyond the end reads as entry 0 (0029), as the host's idx() */
/* 1038, the source banks (docs: rytm-teensy docs/SRC-BANKS.md): GRANULAR SRC, WAVETABLE TBL and MULTISAMPLE INST hold
   index 0..127 in the word's integer byte and the bank 0..7 (A..H) in the fraction's top 3 bits (index << 8 | bank << 5).
   Their knob steps one index a detent (0029 mode 3, all 128) and keeps the bank (bit 11, new in 0029: the stored word's
   fraction bits 0xe0 survive a turn and a lock); the record gets the fine flag (+0x14 = 1, as stock's STA / END), so a
   saved p-lock keeps the fraction (stock's second lock sequence) [measured, rytm-emu: without the flag a saved lock
   keeps 7 bits], and the range 0..0x7fe0 lets bank H's index 127 through. */
#define CU_BANKED 0xb80
#define CU_KEEP   0x800
/* 1045: DSP SAMPLE's SMP (0021's record 441, word 19; fine flag and range by registry patch) banked the same way: its
   value text the SAMPLES list's names (list 0, as GRANULAR SRC), its step 0029's banked one */
#define CU_DSPS_SMP 441
static const struct cu_knob cu_srck[8] = {   /* MULTISAMPLE (rytm-teensy core/msamp/msamp.h) */
    {"Instrument", "INST", CU_DIAL, 12, 0, CU_BANKED}, {"Velocity", "VEL", CU_DIAL, 0, 127, 0},
    {"Level", "LEV", CU_LEVEL, 0, 100, 0},        {"Release Trig", "RTRG", CU_DIAL, 1, 0, 0x102},
    {"Attack", "ATK", CU_BIPOLAR, 0, 64, 0},      {"Decay", "DEC", CU_BIPOLAR, 0, 64, 0},
    {"Sustain", "SUS", CU_BIPOLAR, 0, 64, 0},     {"Release", "REL", CU_BIPOLAR, 0, 64, 0}};
static const struct cu_knob cu_p2k[8] = {
    {"Tune", "TUNE", CU_BIPOLAR, 0, 64, 0}, {"Fine Tune", "FINE", CU_BIPOLAR, 0, 64, 0},
    {"Start", "STRT", CU_DIAL, 0, 0, 0},    {"Loop", "LOOP", CU_DIAL, 2, 0, 0x103}, CU_CHORD};
/* 1034: WAVETABLE and GRANULAR (the host's docs above: names, looks, defaults, lists); 1043: TBL's default 1 (A001, the host's
   BASIC in its wavetable list template), was 0 */
static const struct cu_knob cu_wtk[8] = {
    {"Table", "TBL", CU_DIAL, 12, 1, CU_BANKED},           {"Position", "POS", CU_DIAL, 0, 0, 0},
    {"Warp", "WARP", CU_DIAL, 7, 0, 0x104},       {"Amount", "AMT", CU_DIAL, 0, 0, 0},
    {"Unison", "UNI", CU_DIAL, 0, 0, 0},          {"Sub Osc", "SUB", CU_LEVEL, 0, 0, 0},
    {"Cutoff", "CUT", CU_BIPOLAR, 0, 64, 0},      {"Resonance", "RES", CU_DIAL, 0, 0, 0}};
static const struct cu_knob cu_wtp2k[8] = {
    {"Attack", "ATK", CU_DIAL, 0, 0, 0},          {"Decay", "DEC", CU_DIAL, 0, 64, 0},
    {"Sustain", "SUS", CU_DIAL, 0, 100, 0},       {"Env>Pos", "ENV", CU_BIPOLAR, 0, 64, 0}, CU_CHORD};
static const struct cu_knob cu_grk[8] = {
    {"Source", "SRC", CU_DIAL, 9, 10, CU_BANKED},         {"Position", "POS", CU_DIAL, 0, 0, 0},
    {"Spray", "SPRY", CU_DIAL, 0, 20, 0},         {"Grain Size", "SIZE", CU_DIAL, 0, 64, 0},
    {"Density", "DENS", CU_DIAL, 0, 64, 0},       {"Pitch Rand", "PRND", CU_DIAL, 0, 0, 0},
    {"Reverse", "REV", CU_DIAL, 0, 0, 0},         {"Window", "WIN", CU_DIAL, 8, 0, 0x104}};
static const struct cu_knob cu_grp2k[8] = {   /* integ-0.3: P11 HOLD (FRZ + FB merged), P12 ANIM; both continuous */
    {"Attack", "ATK", CU_DIAL, 0, 10, 0},         {"Release", "REL", CU_DIAL, 0, 60, 0},
    {"Hold/Freeze", "HOLD", CU_DIAL, 10, 0, 0},   {"Animate", "ANIM", CU_DIAL, 11, 0, 0}, CU_CHORD};
/* p1m / p2m: the machine the SRC / page-2 records were last set up for */
/* 1051: LIVE IN (P1..P8 INPT GAIN GATE HOLD MON ATK DEC SUS, page 2 P9 REL) and CHOP (SRC SLC TUNE MRPH SEED NBR VEL LEV,
   page 2 STUT SLEN TAPE TTIM ATK DEC DIR LOOP: fully down the slice's own setting). Texts: 13 INPT (4 zones), 14 MON (2),
   15 GATE (0 OFF, then -80..-20 DB), 16 SLC (1..64: v / 2 + 1), 17 TUNE (-24..+24), 18 a percentage, 19 SEED (0 OFF),
   20 STUT (SLC, then X2..X16), 22 TAPE (SLC OFF STOP SPIN), 23 DIR (SLC FWD REV), 24 LOOP (SLC OFF FWD PING), 25 SLC
   at 0 else the number (the host's CHOP page shows the time), 26 DEC: 25 with HOLD at 127 (no decay) */
static const struct cu_knob cu_lik[8] = {
    {"Input", "INPT", CU_DIAL, 13, 80, 0x104},    {"Gain", "GAIN", CU_BIPOLAR, 0, 64, 0},
    {"Gate", "GATE", CU_LEVEL, 15, 0, 0},         {"Hold", "HOLD", CU_DIAL, 0, 28, 0},
    {"Monitor", "MON", CU_DIAL, 14, 0, 0x102},    {"Attack", "ATK", CU_DIAL, 0, 0, 0},
    {"Decay", "DEC", CU_DIAL, 0, 77, 0},          {"Sustain", "SUS", CU_LEVEL, 0, 0, 0}};
static const struct cu_knob cu_lip2k[8] = {
    {"Release", "REL", CU_DIAL, 0, 77, 0},        {"-", "-", CU_DIAL, 0, 0, 0}, {"-", "-", CU_DIAL, 0, 0, 0},
    {"-", "-", CU_DIAL, 0, 0, 0},                 {"-", "-", CU_DIAL, 0, 0, 0}, {"-", "-", CU_DIAL, 0, 0, 0},
    {"-", "-", CU_DIAL, 0, 0, 0},                 {"-", "-", CU_DIAL, 0, 0, 0}};
static const struct cu_knob cu_cpk[8] = {
    {"Sample", "SRC", CU_DIAL, 9, 10, CU_BANKED}, {"Slice", "SLC", CU_DIAL, 16, 0, 0x140},
    {"Tune", "TUNE", CU_BIPOLAR, 17, 64, 0},      {"Morph", "MRPH", CU_DIAL, 18, 0, 0},
    {"Shuffle Seed", "SEED", CU_DIAL, 19, 0, 0},  {"Neighbour", "NBR", CU_DIAL, 18, 0, 0},
    {"Velocity", "VEL", CU_DIAL, 18, 64, 0},      {"Level", "LEV", CU_LEVEL, 0, 100, 0}};
static const struct cu_knob cu_cpp2k[8] = {
    {"Stutter", "STUT", CU_DIAL, 20, 0, 0x110},   {"Stutter Len", "SLEN", CU_DIAL, 25, 0, 0},
    {"Tape", "TAPE", CU_DIAL, 22, 0, 0x104},      {"Tape Time", "TTIM", CU_DIAL, 25, 0, 0},
    {"Attack", "ATK", CU_DIAL, 25, 0, 0},         {"Decay", "DEC", CU_DIAL, 26, 0, 0},
    {"Direction", "DIR", CU_DIAL, 23, 0, 0x103},  {"Loop", "LOOP", CU_DIAL, 24, 0, 0x104}};
/* dm / dt / dtick (1051): a choice of LIVE IN or CHOP waiting for its page-2 defaults (cu_defs_tick) */
static struct { uint8_t init, p2m; uint16_t setups; uint32_t texts; uint8_t p1m, dm, dt, pad; uint32_t preps, dtick, defs; } cu
    __attribute__((aligned(4)));

/* machine m's knobs: SRC (p2 0) or page 2 (p2 1); 0: not ours (6-OP FM: page 2 only, MULTISAMPLE's, E..H shown) */
static const struct cu_knob *cu_tab(int32_t m, int32_t p2) {
  if (m == CU_WT) return p2 ? cu_wtp2k : cu_wtk;
  if (m == CU_GR) return p2 ? cu_grp2k : cu_grk;
  if (m == CU_MS) return p2 ? cu_p2k : cu_srck;
  if (m == CU_LI) return p2 ? cu_lip2k : cu_lik;   /* 1051 */
  if (m == CU_CP) return p2 ? cu_cpp2k : cu_cpk;
  return m == CU_FM && p2 ? cu_p2k : 0;
}
static const char *cu_grp(int32_t m) {
  return m == CU_MS ? cu_ms_short : m == CU_WT ? cu_wt_short : m == CU_GR ? cu_gr_short : m == CU_LI ? cu_li_short
       : m == CU_CP ? cu_cp_short : cu_fm_short;
}

/* the value text of our records (functor = the record's descriptor + 20, as 0021's R1 measured) */
int32_t cu_text(void *functor, int32_t value, void *str) {
  int32_t r = (int32_t)(((uint32_t)functor - 0x419a4888u - 20u) / 84u), v = value >> 8, i, kind = 0;
  const struct cu_knob *s = cu_tab(cu.p1m, 0), *p = cu_tab(cu.p2m, 1);
  for (i = 0; i < 8; ++i) {
    if (cu_src[i] == r && s) kind = s[i].text;
    if (cu_p2[i] == r && p) kind = p[i].text;
  }
  if (r == CU_DSPS_SMP) kind = 12;   /* 1045 */
  if (v < 0) v = 0;
  if (v > 127) v = 127;
  cu.texts++;
  switch (kind) {
    case 1: return CU_PRINTF(str, cu_fmt_s, v >= 64 ? cu_loop[2] : cu_loop[1]);
    case 2: return CU_PRINTF(str, cu_fmt_s, cu_loop[(v * 3) >> 7]);
    case 3: return CU_PRINTF(str, cu_fmt_s, cu_chd[v < 16 ? v : 0]);
    case 4: return CU_PRINTF(str, cu_fmt_inv, v < 4 ? v : 0);
    case 5: return CU_PRINTF(str, cu_fmt_spr, v < 3 ? v : 0);
    case 6: return v >= 1 && v <= 6 ? CU_PRINTF(str, cu_fmt_d, v) : CU_PRINTF(str, cu_fmt_s, cu_loop[0]);
    case 7: return CU_PRINTF(str, cu_fmt_s, cu_warp[(v * 4) >> 7]);
    case 8: return CU_PRINTF(str, cu_fmt_s, cu_win[(v * 4) >> 7]);
    case 10: return v < 120 ? CU_PRINTF(str, cu_fmt_d, v * 99 / 119) : CU_PRINTF(str, cu_fmt_s, cu_frz);
    case 11: return v ? CU_PRINTF(str, cu_fmt_s, cu_anim[v >> 4]) : CU_PRINTF(str, cu_fmt_s, cu_off);
    case 13: return CU_PRINTF(str, cu_fmt_s, cu_inpt[(v * 4) >> 7]);   /* 1051: LIVE IN, CHOP */
    case 14: return CU_PRINTF(str, cu_fmt_s, cu_mon[(v * 2) >> 7]);
    case 15: return v ? CU_PRINTF(str, cu_fmt_db, -80 + ((v - 1) * 60 + 63) / 126) : CU_PRINTF(str, cu_fmt_s, cu_off);   /* (rounded as the host) */
    case 16: return CU_PRINTF(str, cu_fmt_d, v / 2 + 1);
    case 17: {
      int32_t st = v >= 64 ? ((v - 64) * 48 + 63) / 126 : -(((64 - v) * 48 + 63) / 126);
      return CU_PRINTF(str, st > 0 ? cu_fmt_pd : cu_fmt_d, st);
    }
    case 18: return CU_PRINTF(str, cu_fmt_pct, (v * 100 + 63) / 127);
    case 19: return v ? CU_PRINTF(str, cu_fmt_d, v) : CU_PRINTF(str, cu_fmt_s, cu_off);
    case 20: return (v * 16) >> 7 ? CU_PRINTF(str, cu_fmt_x, ((v * 16) >> 7) + 1) : CU_PRINTF(str, cu_fmt_s, cu_slc);
    case 22: return CU_PRINTF(str, cu_fmt_s, cu_tape[(v * 4) >> 7]);
    case 23: return CU_PRINTF(str, cu_fmt_s, cu_dir[(v * 3) >> 7]);
    case 24: return CU_PRINTF(str, cu_fmt_s, cu_cloop[(v * 4) >> 7]);
    case 25: return v ? CU_PRINTF(str, cu_fmt_d, v) : CU_PRINTF(str, cu_fmt_s, cu_slc);
    case 26: return v >= 127 ? CU_PRINTF(str, cu_fmt_s, cu_hold) : v ? CU_PRINTF(str, cu_fmt_d, v) : CU_PRINTF(str, cu_fmt_s, cu_slc);
    case 9:
    case 12: {   /* 1036: the host's names (47) for GRANULAR SRC / WAVETABLE TBL / MULTISAMPLE INST. 1038: the bank
                    (value bits 5..7). 1043: every bank A..H alike: index 0 OFF, the host's name when it sent that bank's
                    names (bank A: a 47 with bank byte 0, or an old 47 without one) and the row has one, else A005 / B005
                    (no more min(v, total - 1) or GRANULAR's built-in IN MAIN .. texts for bank A) */
      int32_t l = r == CU_DSPS_SMP || cu.p1m == CU_GR || cu.p1m == CU_CP ? 0 : cu.p1m == CU_WT ? 1 : cu.p1m == CU_MS ? 2 : -1,
              bk = value >> 5 & 7;   /* (1051: CHOP's SRC the SAMPLES list's, as GRANULAR's) */
      if (!v) return CU_PRINTF(str, cu_fmt_s, cu_off);
      if (l >= 0 && ux.nm_bank[l] == bk && ux.nm[l][v][0])   /* (a bank's names: its rows that hold a file) */
        return CU_PRINTF(str, cu_fmt_s, ux.nm[l][v]);
      return CU_PRINTF(str, cu_fmt_bk, 'A' + bk, v);
    }
    default: return CU_PRINTF(str, cu_fmt_d, v);
  }
}

/* record r as knob k: look, value text, names; its range 0..127 and default, as 0021's us_record writes them */
static void cu_knob(int32_t r, const struct cu_knob *k, const char *grp) {
  uint32_t *rec = CU_REC(r), *d = CU_DESC(r);
  const uint32_t *s = CU_DESC(k->look);
  int32_t i;
  for (i = 0; i < 21; ++i) d[i] = s[i];
  if (k->text) d[8] = (uint32_t)cu_text;
  rec[10] = (uint32_t)k->lng;
  rec[11] = (uint32_t)grp;
  rec[12] = (uint32_t)k->sht;
  rec[2] = 0;
  rec[3] = k->steps & CU_KEEP ? 0x7fe0 : 0x7f00;
  rec[4] = (uint32_t)k->def << 8;
  if (k->steps & CU_KEEP) rec[5] = 1;   /* 1038: the fine flag (+0x14): saved locks keep the bank */
}

/* 1034: MULTISAMPLE, WAVETABLE and GRANULAR share the SRC records cu_src (no free records left: 334..460 are all
   0021's). Machine 46's and 47's SRC pages list them (0021's registry patches); sound_param_id_for_index's table gets
   machine 52's ids for 46 and 47 too (param_tables_build filled it at boot from the records' machine field, 52), and
   the records are set up (names, looks, texts, defaults, the machine field +0x00 = m) for the machine that uses them:
   the selected track's (cu_setup, every UI tick) and the one set_machine is about to give a track (cu_prep: its
   defaults are then this machine's). */
static void cu_src_setup(int32_t m) {
  const struct cu_knob *k = cu_tab(m, 0);
  int32_t j;
  if (!k || m == CU_FM) return;
  for (j = 0; j < 8; ++j)   /* (1051: LIVE IN 48 and CHOP 49 too) */
    CU_IDS[CU_WT * 8 + j] = CU_IDS[CU_GR * 8 + j] = CU_IDS[CU_LI * 8 + j] = CU_IDS[CU_CP * 8 + j] = CU_IDS[CU_MS * 8 + j];
  if (cu.p1m == m && CU_REC(cu_src[0])[12] == (uint32_t)k[0].sht && CU_REC(cu_src[7])[12] == (uint32_t)k[7].sht &&
      CU_REC(cu_src[0])[0] == (uint32_t)m)
    return;
  for (j = 0; j < 8; ++j) {
    cu_knob(cu_src[j], &k[j], cu_grp(m));
    CU_REC(cu_src[j])[0] = (uint32_t)m;
  }
  cu.p1m = (uint8_t)m;
}

/* 0021's us_page_record, machine 40, 46, 47 or 52 (UI task): the SRC records (not 6-OP FM's) and page 2's shared records
   as this machine's, unless they still are */
void cu_setup(int32_t m) {
  const struct cu_knob *k = cu_tab(m, 1);
  int32_t j;
  if (!k) return;
  cu_src_setup(m);
  if (cu.p2m == m && CU_REC(cu_p2[0])[12] == (uint32_t)k[0].sht && CU_REC(cu_p2[7])[12] == (uint32_t)k[7].sht &&
      CU_REC(cu_p2[0])[11] == (uint32_t)cu_grp(m))
    return;
  for (j = 0; j < 8; ++j) cu_knob(cu_p2[j], &k[j], cu_grp(m));
  cu.p2m = (uint8_t)m;
  cu.setups++;
}

/* 1034: set_machine's entry (0x400bd14e, registry detour cu_setm_det): the SRC records as machine m's before it writes
   the machine's defaults (sound_init_defaults reads them through the records) */
void cu_prep(int32_t m, int32_t t) {
  if (!cu.init) return;
  cu.preps++;
  cu_src_setup(m);
  /* 1051: LIVE IN and CHOP want page 2's defaults too, which set_machine leaves as the stock sample page's words (TUN 64,
     LOP 100 ... [measured, cu_emu]): CHOP's page 2 is per-hit overrides whose fully-down zone is the slice's own, so those
     words would stutter, tape-stop, reverse and loop every hit. Noted here, written by cu_defs_tick once the choice stays
     (the machine list closed: its cursor's previews call set_machine too) */
  /* (only a choice made in the machine list: a kit / sound / project load that calls set_machine keeps its own words) */
  if ((m == CU_LI || m == CU_CP) && (uint32_t)t < 12u && sv.top_vt == 0x401e5bf4u) {
    cu.dm = (uint8_t)m; cu.dt = (uint8_t)t; cu.dtick = st.ticks;
  }
}

/* 0021's ext_steps for a record no user slot owns: ours stepped (mode << 8 | N), 0 continuous */
int32_t cu_steps(int32_t r) {
  int32_t t = SEL_TRACK, m, i;
  const struct cu_knob *k = cu_tab(cu.p1m, 0);
  if (r == CU_DSPS_SMP) return CU_BANKED;   /* 1045 */
  for (i = 0; i < 8; ++i)
    if (cu_src[i] == r) return k ? k[i].steps : 0;
  if (t > 11) t = 0;
  m = MACHINE_OF(t);
  if (m != cu.p2m || !(k = cu_tab(m, 1)) || CU_REC(cu_p2[7])[12] != (uint32_t)k[7].sht) return 0;
  for (i = 0; i < 8 && cu_p2[i] != r; ++i) ;
  if (i == 8 || (m == CU_FM && i < 4)) return 0;   /* 6-OP FM: E..H only */
  return k[i].steps;
}

static void cu_tick(void) {
  uint32_t *d = CU_DESC(CU_DSPS_SMP);
  /* 1045: SMP's value text ours, once 0021 has given the record its dial (ext_descriptors, at its first value text);
     0029 then wraps it (keeping ours as the record's own text) */
  if (d[8] != (uint32_t)cu_text && d[8] == CU_DESC(CU_DIAL)[8]) d[8] = (uint32_t)cu_text;
  if (cu.init || CUBOX[0] != 0x43485244u) return;   /* once; not with a 0021 without us_cubox */
  cu.init = 1;
  cu_src_setup(CU_MS);
  CUBOX[2] = (uint32_t)cu_steps;
  CUBOX[1] = (uint32_t)cu_setup;
}

__asm__(
    "  .text\n"
    "  .globl cu_setm_det\n"
    "  .align 2\n"
    "cu_setm_det:\n"                 /* set_machine(sound, machine, track, flag): machine at 8(%sp), track at 12(%sp) */
    "  move.l 12(%sp),-(%sp)\n"      /* 1051: cu_prep(machine, track) */
    "  move.l 12(%sp),-(%sp)\n"
    "  jsr cu_prep\n"
    "  addq.l #8,%sp\n"
    "  link.w %fp,#-40\n"            /* displaced */
    "  movem.l %d2-%d6/%a2-%a4,(%sp)\n"   /* displaced */
    "  jmp 0x400bd156\n");

/* 1036: the host's 48 (a touchscreen's pick of a source / table / instrument) in the UI task: P(k + 1) of track t as a
   knob turn writes it - 0021's us_set: the live copy (SET_PARAM 0x4011f3fa, container index 9 + k) and kit_param_changed
   (0x4003355c) on the KitBank with the parameter's record (sound_param_id_for_index 0x40007028(9 + k, machine)), whose
   drain writes the kit word and the project's copy (saved, kept over a power-off). The drain keeps a record of the
   track's machine only: on MULTISAMPLE / WAVETABLE / GRANULAR (1051: LIVE IN and CHOP, their page 2 too), whose SRC
   records are shared (1034), the records must be
   set up for the track's machine (the selected track's; else refused: status 1). Answered 48 1 <track> <param>
   <status 0 written / 1 refused / 2 no such parameter on its machine>. 1038: a fifth byte, flags; bit 0 = the bank list's
   commit: when trigs were held at its YES (ls_lock) P1 is locked on those steps instead (status 4 locked, 3 the
   pattern's lock slots full: nothing written). */
typedef int32_t (*spid_fn)(int32_t index, int32_t machine);
typedef void (*setp_fn)(int32_t value, int32_t track, int32_t index);
#define SPID       ((spid_fn)0x40007028u)
#define SET_PARAM  ((setp_fn)0x4011f3fau)
#define US_BANK    ((void *(*)(void))0x40194618u)
#define US_COMMIT  ((void (*)(void *bank, int32_t track, int32_t record, int32_t value))0x4003355cu)
static void wr_tick(void) {
  while (ux.wr_n) {   /* the replies first (in order) */
    if (!send3(0x48, ux.wr[0][0], ux.wr[0][1], ux.wr[0][2])) return;
    uint32_t i;
    for (i = 1; i < ux.wr_n; ++i) { ux.wr[i - 1][0] = ux.wr[i][0]; ux.wr[i - 1][1] = ux.wr[i][1]; ux.wr[i - 1][2] = ux.wr[i][2]; }
    ux.wr_n--;
    ux.w_sent++;
  }
  while (ux.wq_t != ux.wq_h && ux.wr_n < WQ_N) {
    const uint8_t *q = ux.wq[ux.wq_t % WQ_N];
    int32_t t = q[0], k = q[1], m = MACHINE_OF(t), rec = SPID(9 + k, m), v = (int32_t)q[2] << 8 | (int32_t)q[3] << 1;
    uint8_t status = 0, fl = ux.wq_flags[ux.wq_t % WQ_N];
    int32_t lk = -1;
    if (rec <= 0) status = 2;
    else if (k < 8 && (m == CU_WT || m == CU_GR || m == CU_MS || m == CU_LI || m == CU_CP) &&
             CU_REC(cu_src[0])[0] != (uint32_t)m) status = 1;   /* (1051: LIVE IN and CHOP share the SRC records too) */
    else if (k >= 8 && (m == CU_LI || m == CU_CP) && cu.p2m != (uint32_t)m) status = 1;   /* 1051: their page 2 too */
    else if ((k == 0 || (k == DSPS_P && m == DSPS_M)) && (fl & 1) && (lk = ls_lock(t, v, 9 + k)) >= 0) {   /* 1038: the
                                                                     list's YES with trigs held: locks (1045: P11 too) */
      status = lk ? 3 : 4;
      if (lk) ux.w_full++; else ux.w_locked++;
    } else {
      SET_PARAM(v, t, 9 + k);
      US_COMMIT(US_BANK(), t, rec, v);
      ux.w_done++;
    }
    if (status && status != 4) ux.w_refused++;
    ux.wr[ux.wr_n][0] = (uint8_t)t; ux.wr[ux.wr_n][1] = (uint8_t)k; ux.wr[ux.wr_n][2] = status;
    ux.wr_n++;
    ux.wq_t++;
  }
}

/* 1051: LIVE IN's / CHOP's page-2 defaults (cu_prep noted the choice): once the track still plays that machine and the
   machine list has closed (MachineListView 0x401e5bf4 not on top), P9..P16 written as knob turns (us_set's way, as the
   host's 48: the live copy and kit_param_changed) from the shared records set up for it; a choice that went (NO, the
   cursor moved on) is dropped. */
static void cu_defs_tick(void) {
  int32_t t = cu.dt, m = cu.dm, k;
  const struct cu_knob *kn;
  if (!m) return;
  if (MACHINE_OF(t) != m) { if (st.ticks - cu.dtick > 4) cu.dm = 0; return; }
  if (sv.top_vt == 0x401e5bf4u || st.ticks - cu.dtick < 2 || !(kn = cu_tab(m, 1))) return;
  cu_setup(m);
  for (k = 8; k < 16; ++k) {
    int32_t rec = SPID(9 + k, m), v = (int32_t)kn[k - 8].def << 8;
    if (rec <= 0) continue;
    SET_PARAM(v, t, 9 + k);
    US_COMMIT(US_BANK(), t, rec, v);
  }
  cu.defs++;
  cu.dm = 0;
}

/* 1036b: the Pi display's reports (49), after everything else of the tick:
     49 1 1 <page 1..5>                              UP + T1..T5
     49 1 4 <on>                                     1044: UP held alone (1), let go (0): the host's combo map
     49 1 2 <track> <machine> <name 12 B>            the selected track, its machine (0..52) and long name: on a change, a
                                                     hello
     49 1 3 <track> {<value 0..127> <label 4 B>} x 8 its P1..P8 (the kit words, the SRC page's knobs) and their short
                                                     names (the records'): on a change, a hello
   The names: the machine table 0x401befa4 + 8 m (long, short; 0026's own for 46, 47, 52 by registry patch) [code]; the
   labels: the record (sound_param_id_for_index(9 + k, m)) +0x30 (its short name pointer, as cu_knob sets it). */
#define MNAME(m)  (*(const char *const *)(0x401befa4u + 8u * (uint32_t)(m)))
static int32_t dp_ptr_ok(const char *p) { return (uint32_t)p >= 0x40000000u && (uint32_t)p < 0x44000000u; }
static void dp_tick(void) {
  uint8_t m[56];
  int32_t t = SEL_TRACK, mc, i, k, n;
  if (dp.page_req) {
    uint8_t b[10] = {0xf0, 0x7d, 0x52, 0x54, 0x49, 0x01, 0x01, (uint8_t)dp.page_req, 0xf7, 0};
    if (!send(b, 9)) return;
    dp.page_req = 0;
  }
  /* 1044: 49 1 4 <1 / 0>: UP held alone on the stock screen (not in a stock menu: UP is its cursor there) / let go */
  /* 1050: 49 1 5 <1 / 0>: the same with the page open (not aside): the host shows the map over its page and that page
     again at the release. A new sub-id, so an older host (which would close its page at 49 1 4 0) ignores it. */
  if (k44.up_on && !k44.up_map && !k44.up_trig && !(st.active && st.aside) && st.ticks - k44.up_t0 >= UP_MAP_TICKS &&
      !up_cursor(sv.top_vt)) {   /* (1051: not in a stock list either: the machine list's held UP scrolls) */
    k44.up_map = 1;
    k44.map_page = st.active ? 1 : 0;
    k44.map_req = 1;
  }
  if (k44.map_req) {
    uint8_t b[10] = {0xf0, 0x7d, 0x52, 0x54, 0x49, 0x01, (uint8_t)(k44.map_page ? 0x05 : 0x04), (uint8_t)(k44.map_req == 1),
                     0xf7, 0};
    if (!send(b, 9)) return;
    if (k44.map_page) { if (k44.map_req == 1) k44.pmap_on++; else k44.pmap_off++; }
    else if (k44.map_req == 1) k44.map_on++; else k44.map_off++;
    if (k44.map_req == 2) k44.map_page = 0;
    k44.map_req = 0;
  }
  if (t < 0 || t > 11) return;
  mc = MACHINE_OF(t);
  if (dp.hellos != st.hellos) { dp.hellos = st.hellos; dp.valid = 0; }
  if (!dp.valid || dp.t != t || dp.m != mc) {
    const char *nm = mc >= 0 && mc <= 52 ? MNAME(mc) : 0;
    n = 0;
    m[n++] = 0xf0; m[n++] = 0x7d; m[n++] = 0x52; m[n++] = 0x54; m[n++] = 0x49; m[n++] = 0x01; m[n++] = 0x02;
    m[n++] = (uint8_t)t; m[n++] = (uint8_t)(mc & 0x7f);
    for (i = 0, k = nm && dp_ptr_ok(nm); i < 12; ++i) {   /* up to the NUL, then NULs */
      if (k && !(nm[i] > 0 && nm[i] < 0x7f)) k = 0;
      m[n + i] = (uint8_t)(k ? nm[i] : 0);
    }
    n += 12;
    m[n++] = 0xf7;
    if (!send(m, n)) return;
    dp.t = (uint8_t)t; dp.m = (uint8_t)mc; dp.valid = 1; dp.owed3 = 1;
    dp.sent2++;
  }
  for (k = 0; k < 8; ++k) {
    uint8_t v = (uint8_t)(*KWORD(t, k) & 0x7f);
    int32_t rec = SPID(9 + k, mc);
    const char *l = rec > 0 ? (const char *)CU_REC(rec)[12] : 0;
    char lb[4] = {0, 0, 0, 0};
    for (i = 0; i < 4 && l && dp_ptr_ok(l) && l[i] > 0 && l[i] < 0x7f; ++i) lb[i] = l[i];
    if (v != dp.v[k] || lb[0] != dp.lab[k][0] || lb[1] != dp.lab[k][1] || lb[2] != dp.lab[k][2] || lb[3] != dp.lab[k][3]) {
      dp.v[k] = v;
      for (i = 0; i < 4; ++i) dp.lab[k][i] = lb[i];
      dp.owed3 = 1;
    }
  }
  if (!dp.owed3) return;
  n = 0;
  m[n++] = 0xf0; m[n++] = 0x7d; m[n++] = 0x52; m[n++] = 0x54; m[n++] = 0x49; m[n++] = 0x01; m[n++] = 0x03; m[n++] = (uint8_t)t;
  for (k = 0; k < 8; ++k) {
    m[n++] = dp.v[k];
    for (i = 0; i < 4; ++i) m[n++] = (uint8_t)dp.lab[k][i];
  }
  m[n++] = 0xf7;
  if (!send(m, n)) return;
  dp.owed3 = 0;
  dp.sent3++;
}

static void pj_tick(void);
static void pj_drain(void);
/* round 6 (N2): 4D 01 <dropped hi lo>: the key presses 0026 dropped (st.tx_drop, its queue full: each with its
   release, never a release alone) and <over hi lo> the times the stock-dump wait ran out (txsx_over), sent when either
   changed, at most once a second, so the host can say so (rytm-teensy host_link logs it) */
static uint32_t kd_drop, kd_over, kd_t;
static void kd_tick(void) {
  uint8_t m[12];
  uint32_t d = st.tx_drop, o = txsx_over;
  if ((d == kd_drop && o == kd_over) || st.ticks - kd_t < 20) return;
  if (d > 16383) d = 16383;
  if (o > 16383) o = 16383;
  m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x4d; m[5] = 0x01;
  m[6] = (uint8_t)(d >> 7); m[7] = (uint8_t)(d & 0x7f); m[8] = (uint8_t)(o >> 7); m[9] = (uint8_t)(o & 0x7f); m[10] = 0xf7;
  if (!send(m, 11)) return;
  kd_drop = st.tx_drop; kd_over = txsx_over; kd_t = st.ticks;
}
void rui_tick(void *ctrl) {
  uint32_t t0 = TIMER, dt;
  fp.ui_tcb = FP_TCB;          /* the freeze probe: this task, ticking now */
  fp.tick_blk = fp.blocks;
  fp.sent_blk = 0;
  while (fp.test == 1) {}      /* (tests: a loop in the UI task) */
  while (fp.test == 2) FP_SLEEP(10000);   /* (tests: the UI task blocked) */
  cu_tick();
  tick_body(ctrl);
  if (st.init) wr_tick();     /* 1036 */
  cu_defs_tick();             /* 1051 */
  if (st.init && PORT_STATE == 1 && st.hellos) dp_tick();   /* 1036b: after the first hello went out */
  if (st.init && PORT_STATE == 1 && st.hellos) pj_tick();   /* 1052: the project slot reports, after the first hello */
  else pj_drain();                                          /* 1052b: no host: nothing stale kept for one later */
  if (st.init && PORT_STATE == 1 && st.hellos) kd_tick();   /* round 6: keys dropped / dump waits run out */
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

/* 1030: rec_trig's detour (0x400b45e0, registry): rui_rec_note(track, note, step) from the caller's arguments (this at
   4(%sp), track 8, note 12, vel 16, step 20), then rec_trig's two displaced instructions and 0x400b45e6. d0/d1/a0/a1
   are scratch at a function's entry. */
__asm__(
    "  .text\n"
    "  .globl rui_rec_det\n"
    "  .align 2\n"
    "rui_rec_det:\n"
    "  move.l 20(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  jsr rui_rec_note\n"
    "  lea 12(%sp),%sp\n"
    "  tst.l %d0\n"
    "  beq.s 1f\n"
    "  rts\n"                       /* 1032: refused (a seq track): rec_trig returns at once; its caller ignores d0 */
    "1:\n"
    "  link.w %fp,#-48\n"
    "  moveq #12,%d0\n"
    "  jmp 0x400b45e6\n");

/* 1032: trig_fire's detour (0x4009a9bc, registry): sq_fire(track, pattern, step) from its arguments (track 4(%sp),
   pattern 8, step 12, slot 16), then its two displaced instructions and 0x4009a9c4. d0/d1/a0/a1 are scratch at a
   function's entry. The clock's exit (0x4009bf9e, registry): sq_end, then the displaced movem and lea, then the rte at
   0x4009bfa6 (every register comes back from the frame, so sq_end may use the scratch ones). */
__asm__(
    "  .text\n"
    "  .globl sq_fire_det, sq_end_det\n"
    "  .align 2\n"
    "sq_fire_det:\n"
    "  move.l 12(%sp),-(%sp)\n"
    "  move.l 12(%sp),-(%sp)\n"
    "  move.l 12(%sp),-(%sp)\n"
    "  jsr sq_fire\n"
    "  lea 12(%sp),%sp\n"
    "  lea -88(%sp),%sp\n"
    "  move.l 96(%sp),%d0\n"
    "  jmp 0x4009a9c4\n"
    "  .align 2\n"
    "sq_end_det:\n"
    "  jsr sq_end\n"
    "  movem.l (%sp),%d0-%fp\n"
    "  lea 76(%sp),%sp\n"
    "  jmp 0x4009bfa6\n");

/* 1033: the edit wrappers (registry: a detour at each stock edit function's entry, 8 B displaced: its linkw and the
   instruction after it, nothing pc-relative). ed_X_det copies six argument words (the functions read two or three),
   calls the stock function through ed_X_orig (the displaced instructions, then the rest of it), keeps its d0 and calls
   ed_report(op, arg1, arg2, d0); the caller gets d0 back. d1 / a0 / a1 are scratch across a call, the rest the stock
   function and ed_report keep. */
__asm__(
    "  .text\n"
    "  .globl ed_pcopy_det\n"
    "  .align 2\n"
    "ed_pcopy_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_pcopy_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #1,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_pcopy_orig:\n"
    "  .short 0x4e56,0xffdc,0x48d7,0x1c0c\n"
    "  jmp 0x400abde8\n"
    "  .globl ed_ppaste_det\n"
    "  .align 2\n"
    "ed_ppaste_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_ppaste_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #2,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_ppaste_orig:\n"
    "  .short 0x4e56,0xffd4,0x48d7,0x3c04\n"
    "  jmp 0x400abffe\n"
    "  .globl ed_pclear_det\n"
    "  .align 2\n"
    "ed_pclear_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_pclear_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #3,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_pclear_orig:\n"
    "  .short 0x4e56,0xffd8,0x48d7,0x3c0c\n"
    "  jmp 0x400ac124\n"
    "  .globl ed_pundo_det\n"
    "  .align 2\n"
    "ed_pundo_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_pundo_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #4,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_pundo_orig:\n"
    "  .short 0x4e56,0xffe4,0x48d7,0x0c04\n"
    "  jmp 0x400abec8\n"
    "  .globl ed_tcopy_det\n"
    "  .align 2\n"
    "ed_tcopy_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_tcopy_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #5,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_tcopy_orig:\n"
    "  .short 0x4e56,0xffd8,0x48d7,0x3c0c\n"
    "  jmp 0x400c2f04\n"
    "  .globl ed_tpaste_det\n"
    "  .align 2\n"
    "ed_tpaste_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_tpaste_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #6,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_tpaste_orig:\n"
    "  .short 0x4e56,0xffc4,0x48d7,0x3c7c\n"
    "  jmp 0x400c475c\n"
    "  .globl ed_tclear_det\n"
    "  .align 2\n"
    "ed_tclear_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_tclear_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #7,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_tclear_orig:\n"
    "  .short 0x4e56,0xffd4,0x48d7,0x3c1c\n"
    "  jmp 0x400c4952\n"
    "  .globl ed_tundo_det\n"
    "  .align 2\n"
    "ed_tundo_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_tundo_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #8,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_tundo_orig:\n"
    "  .short 0x4e56,0xffd0,0x48d7,0x3c3c\n"
    "  jmp 0x400c3810\n"
    "  .globl ed_gcopy_det\n"
    "  .align 2\n"
    "ed_gcopy_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_gcopy_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #9,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_gcopy_orig:\n"
    "  .short 0x4e56,0xffd8,0x48d7,0x3c0c\n"
    "  jmp 0x400c4628\n"
    "  .globl ed_gpaste_det\n"
    "  .align 2\n"
    "ed_gpaste_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_gpaste_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #10,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_gpaste_orig:\n"
    "  .short 0x4e56,0xffb8,0x48d7,0x3cfc\n"
    "  jmp 0x400c334a\n"
    "  .globl ed_gclear_det\n"
    "  .align 2\n"
    "ed_gclear_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_gclear_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #11,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_gclear_orig:\n"
    "  .short 0x4e56,0xffc8,0x48d7,0x3cfc\n"
    "  jmp 0x400c4456\n"
    "  .globl ed_gundo_det\n"
    "  .align 2\n"
    "ed_gundo_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_gundo_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #12,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_gundo_orig:\n"
    "  .short 0x4e56,0xffc8,0x48d7,0x3cfc\n"
    "  jmp 0x400c3602\n"
    "  .globl ed_rcopy_det\n"
    "  .align 2\n"
    "ed_rcopy_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_rcopy_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #13,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_rcopy_orig:\n"
    "  .short 0x4e56,0xff84,0x48d7,0x3cfc\n"
    "  jmp 0x400c4ad4\n"
    "  .globl ed_rpaste_det\n"
    "  .align 2\n"
    "ed_rpaste_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_rpaste_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #14,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_rpaste_orig:\n"
    "  .short 0x4e56,0xff90,0x41ee,0xffb8\n"
    "  jmp 0x400c3972\n"
    /* 1042: RELOAD / SAVE PATTERN (the PATTERN menu, FUNC + SCNE), RELOAD / SAVE TRACK (the TRACK menu, FUNC + CHRO) */
    "  .globl ed_preload_det\n"
    "  .align 2\n"
    "ed_preload_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_preload_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #16,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_preload_orig:\n"
    "  .short 0x4fef,0xfff4,0x48d7,0x0c04\n"
    "  jmp 0x400af5e8\n"
    "  .globl ed_psave_det\n"
    "  .align 2\n"
    "ed_psave_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_psave_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #17,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_psave_orig:\n"
    "  .short 0x4fef,0xfff4,0x48d7,0x040c\n"
    "  jmp 0x400ae590\n"
    "  .globl ed_treload_det\n"
    "  .align 2\n"
    "ed_treload_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_treload_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #18,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_treload_orig:\n"
    "  .short 0x4fef,0xffe8,0x48d7,0x3c0c\n"
    "  jmp 0x400af652\n"
    "  .globl ed_tsave_det\n"
    "  .align 2\n"
    "ed_tsave_det:\n"
    "  lea -24(%sp),%sp\n"
    "  move.l 28(%sp),(%sp)\n"
    "  move.l 32(%sp),4(%sp)\n"
    "  move.l 36(%sp),8(%sp)\n"
    "  move.l 40(%sp),12(%sp)\n"
    "  move.l 44(%sp),16(%sp)\n"
    "  move.l 48(%sp),20(%sp)\n"
    "  jsr ed_tsave_orig\n"
    "  lea 24(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l 16(%sp),-(%sp)\n"
    "  move.l #19,-(%sp)\n"
    "  jsr ed_report\n"
    "  lea 16(%sp),%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "ed_tsave_orig:\n"
    "  .short 0x4fef,0xffe8,0x48d7,0x3c0c\n"
    "  jmp 0x400ae61c\n"
    );

/* 1033: the transport entry's detour (0x4007a538, registry: `lea %sp@(-20),%sp; moveq #1,%d0`, 6 B, nothing
   pc-relative): pin_frame(frame) from its argument, then the two displaced instructions and 0x4007a53e. */
__asm__(
    "  .text\n"
    "  .globl pin_det\n"
    "  .align 2\n"
    "pin_det:\n"
    "  move.l 4(%sp),-(%sp)\n"
    "  jsr pin_frame\n"
    "  addq.l #4,%sp\n"
    "  .short 0x4fef,0xffec,0x7001\n"
    "  jmp 0x4007a53e\n");

/* ---- 1052: the project slot reports (4B; rytm-teensy docs/superpowers/specs/2026-10-27-project-slot-keys-design.md) -----
 * The Sidecar keys a project's files by the Rytm's project slot (128 fixed slots, no ID inside a project: the slot is the
 * identity [measured, the research of 2026-10-26]). Rytm -> host, F0 7D 52 54 4B 01 <op> ... F7, slots 1-based in two
 * 7-bit bytes (hi = n >> 7, lo = n & 0x7f; 0 none):
 *   4B 1 00 <slot hi lo> <name>            ACTIVE: the active slot (0x405c8e4d, 0-based, -1 none) and the project's name
 *                                          (0x407c89d3, up to 15 characters): on a change, after each hello, every 5 s
 *   4B 1 01 <from hi lo> <to hi lo>        SAVE at save's entry (0x400b0738, slot >= 0): from the active slot then
 *   4B 1 02 <src hi lo> <dst hi lo>        PASTE (the paste's slot write): src the slot the last COPY (0x4003502c) took
 *   4B 1 03 / 04 / 05 <0 0> <slot hi lo>   CLEAR (the clear job's or the init job's slot write), DELETE (0x40034a54),
 *                                          RENAME (the rename job's slot write)
 *   4B 1 06 <n hi lo> <0 0>                LOST: n events dropped (the ring full, or a second task at the same instant)
 *   4B 1 07 <0 0> <slot hi lo>             WRITE: a slot write from a caller none of the above (logged by the host)
 *   4B 1 08 <first hi lo> <n> {<occ> <name 15>} x n   LIST: the slots' names (1052b), 8 a message, after the ACTIVE
 *                                          that follows a hello and after a LOST; occ 1 a project there, 0 none
 *   4B 1 09 <count hi lo> <0 0>            LIST END: the projects listed (0x3fff: the table not readable, no list)
 *   4B 1 0A <0 0> <slot hi lo>             LOAD: the active-slot setter 0x400fa694 called from LOAD PROJECT (the same
 *                                          slot too; 1052c: a save's or CREATE NEW's set filtered by its caller)
 * With no host (the port down, or no hello yet) the ring is drained into LOST: the host resyncs from the LIST.
 * The hooks (registry detours) run in the project job task [measured stacks]: they note three bytes in a ring under a TAS
 * lock (a second producer at once counts as LOST, never spins); pj_tick (UI task) sends through send()'s try-lock, events
 * first in order, the ACTIVE only when none waits. The hello's caps bit 2 says this build sends them. */
#define PJ_ACTIVE (*(volatile int8_t *)0x405c8e4du)          /* signed, 0-based, -1 none; its one setter 0x400fa694 */
#define PJ_NAME   ((const volatile uint8_t *)0x407c89d3u)    /* the active project's name (0021's PROJECT_NAME) */
#define PJ_RET_RENAME 0x400519a8u   /* write-slot's callers, by their return address [code; measured in the research's  */
#define PJ_RET_CLEAR  0x40051ae6u   /* break-point stacks and counts]: the rename job, the clear job (CLEAR, INIT NEW),  */
#define PJ_RET_INIT   0x40051a74u   /* the init job (FUNC + PLAY), the paste (0x40035248's jsr), save's own write        */
#define PJ_RET_PASTE  0x4003524cu
#define PJ_RET_SAVE   0x400b082eu
#define PJ_RET_SELF   0x40034f4au   /* write-slot's own call of itself (0x40034f46) */
enum { PJ_OP_ACTIVE = 0, PJ_OP_SAVE, PJ_OP_PASTE, PJ_OP_CLEAR, PJ_OP_DELETE, PJ_OP_RENAME, PJ_OP_LOST, PJ_OP_WRITE,
       PJ_OP_LIST, PJ_OP_LIST_END, PJ_OP_LOAD };
/* 1052d: the kit reports, 4C 01 <op> <kit hi lo> <src hi lo> (kits 1-based, 0 none), through the same ring as the 4B
   events (in order with them: a LOAD PROJECT's own kit work comes after its LOAD): KT_SAVE <target> <the active kit
   before> (SAVE KIT, YES + KIT: SAVE KIT to another kit makes that kit the active one [measured]), KT_RELOAD <kit>
   (RELOAD KIT, NO + KIT), KT_RELOAD_ALL <the active kit> (the KIT menu's RELOAD set to ALL). KT_RESTORE (03) is kept
   for 0010-kit-ab's EDITS RESTORED (its edits kept aside back), which cannot be in a build with 0021 (excluded since
   fix-1020: cave7) - so not in the rui set, and nothing sends it today. In the ring an op | 0x40 is a 4C one. */
enum { KT_SAVE = 0x41, KT_RELOAD, KT_RESTORE, KT_RELOAD_ALL };
/* 1052b: the slots' header table the project manager keeps in RAM: a pointer in .bss at 0x419f2888 (to 0x41b81340 in
   rytm-emu, every snapshot of the 1052 runs), the header of slot n (0-based) at +12 + 24 n: byte 0 1 a project there
   (0 empty or deleted), the name at +8 (16 B) [measured, rytm-emu rui1052: base, SAVE AS, PASTE, CLEAR, INIT, DELETE,
   RENAME each matched the card's slots]. Read only when the pointer is in DDR, aligned, and every flag 0 or 1. */
#define PJ_TABLE_PTR (*(const volatile uint32_t *)0x419f2888u)   /* inferred (re/symbols.toml project_slot_table_ptr) */
#define PJ_RET_LOADSITE 0x400b405eu   /* 1052c: 0x400aecc0's call from the LOAD PROJECT path (jsr at 0x400b405a) [measured] */
#define PJ_RET_HELPER   0x400aecdeu   /* 1052d: the setter's call inside the helper 0x400aecc0 (jsr at 0x400aecd8) [code] */
#define PJ_LIST_ROUNDS 2              /* 1052c: each LIST sent twice: the host acts only on two that agree */
#define PJ_LIST_N 8
#define PJ_RING  32
#define PJ_EVERY 100                /* the ACTIVE again after 5 s unchanged (a host that restarted) */
static struct {
  volatile uint32_t wr, rd;         /* wr: the job task's (under lock), rd: the UI task's */
  uint8_t ev[PJ_RING][4];           /* op, a, b (slots 1-based, 0 none) */
  uint8_t lock;                     /* TAS */
  uint8_t clip;                     /* the slot COPY took, 1-based (0 none) */
  uint8_t sent_slot, sent_ok;       /* the last ACTIVE sent: its slot (1-based) and whether one was */
  uint8_t sent_name[16];
  volatile uint32_t lost;           /* events dropped (the job task's) */
  uint32_t lost_sent;
  uint32_t hellos, last_tick;       /* st.hellos at the last ACTIVE, its tick */
  uint32_t n_ev, n_act;             /* sent: events, ACTIVEs (the emulator tests read them) */
  uint8_t list_pos, list_on;        /* 1052b: the LIST being sent (next slot, 0-based); 1052c: the rounds left */
  uint8_t pad2[2];
  uint32_t n_list;                  /* LISTs completed */
} pj __attribute__((section(".bss"), aligned(4)));

static int32_t pj_take(void) {      /* 1: the ring is this task's until pj.lock = 0 */
  uint8_t was;
  __asm__ volatile("tas %1\n\tsmi %0" : "=d"(was), "+m"(pj.lock) : : "cc", "memory");
  return was == 0;
}
static void pj_push(uint8_t op, int32_t a, int32_t b) {   /* a, b 0-based slots, -1 none */
  uint32_t w;
  if (!pj_take()) { pj.lost++; return; }
  w = pj.wr;
  if (w - pj.rd >= PJ_RING) pj.lost++;
  else {
    uint8_t *e = pj.ev[w % PJ_RING];
    e[0] = op;
    e[1] = (uint8_t)(a >= 0 && a < 128 ? a + 1 : 0);
    e[2] = (uint8_t)(b >= 0 && b < 128 ? b + 1 : 0);
    __asm__ volatile("" : : : "memory");
    pj.wr = w + 1;
  }
  __asm__ volatile("" : : : "memory");
  pj.lock = 0;
}
/* the detours' C halves (the project job task) */
void pj_write(uint32_t ret, int32_t slot) {
  if (ret == PJ_RET_SAVE || ret == PJ_RET_SELF) return;   /* save's own write: its SAVE went at its entry */
  if (ret == PJ_RET_RENAME) pj_push(PJ_OP_RENAME, -1, slot);
  else if (ret == PJ_RET_CLEAR || ret == PJ_RET_INIT) pj_push(PJ_OP_CLEAR, -1, slot);
  else if (ret == PJ_RET_PASTE) pj_push(PJ_OP_PASTE, (int32_t)pj.clip - 1, slot);
  else pj_push(PJ_OP_WRITE, -1, slot);
}
void pj_delete(int32_t slot) { pj_push(PJ_OP_DELETE, -1, slot); }
void pj_copy(int32_t slot) { pj.clip = (uint8_t)(slot >= 0 && slot < 128 ? slot + 1 : 0); }
void pj_save(int32_t slot) {
  if (slot >= 0) pj_push(PJ_OP_SAVE, PJ_ACTIVE, slot);
}
/* 1052c/d: the setter reports LOAD only for the LOAD PROJECT path's call through the helper 0x400aecc0 (obj, slot) - a
   save's (SAVE, SAVE AS, SAVE TO set the slot too, without reloading it), CREATE NEW's and the other 6 sites (not
   driven) are filtered. Read from the setter's own stack (1052d, no global: nothing stale when the helper's check
   fails, nothing another task can overwrite between the helper and the setter): at the setter's entry (sp) is its
   return address, 0x400aecde when the helper called it, and the helper (no frame, no saved registers [code]) has its
   own return address at 8(sp), above the slot argument. ret: (sp); caller: 8(sp). */
void pj_activate(int32_t slot, uint32_t ret, uint32_t caller) {
  if (slot >= 0 && ret == PJ_RET_HELPER && caller == PJ_RET_LOADSITE) pj_push(PJ_OP_LOAD, -1, slot);
}
/* 1052d: the kit functions' C halves (the UI task; kit_save also from 0x40103b62 / 0x40103f46 [code: callers not
   driven]). kit_save 0x400b119c (project, index, flag): index clamped 0..127 as it does [code]; pre: the active kit
   (0x800067b8) at its entry. kit_reload 0x400af0d2 (project) and the reload of every kit 0x400b131a (project): the
   active kit after. */
void kt_saved(int32_t index, uint32_t pre) {
  pj_push(KT_SAVE, index < 0 ? 0 : index > 127 ? 127 : index, (int32_t)(pre & 127u));
}
void kt_reloaded(uint32_t op) { pj_push((uint8_t)op, (int32_t)(ACTIVE_KIT & 127u), -1); }
/* 1052b: no host - the ring drained into LOST (one LOST at the next hello instead of stale events) */
static void pj_drain(void) {   /* (a LOAD needs no host: the ACTIVE after the hello says where the Rytm is) */
  uint32_t w = pj.wr;
  for (; pj.rd != w; pj.rd++)
    if (pj.ev[pj.rd % PJ_RING][0] != PJ_OP_LOAD) pj.lost++;
}
static int32_t pj_send(uint8_t op, uint32_t a, uint32_t b);
static const volatile uint8_t *pj_table(void) {   /* the slots' headers, or 0 when they do not look right */
  uint32_t p = PJ_TABLE_PTR, i;
  if ((p & 3) || p < 0x40000000u || p >= 0x47be0000u) return 0;
  for (i = 0; i < 128; ++i)
    if (((const volatile uint8_t *)p)[12 + 24 * i] > 1) return 0;
  return (const volatile uint8_t *)p + 12;
}
static int32_t pj_list_step(void) {   /* one LIST message (8 slots) or the END; 1 when it went */
  const volatile uint8_t *t = pj_table();
  uint8_t m[12 + 16 * PJ_LIST_N];
  int32_t i, k, n = 0;
  if (!t || pj.list_pos >= 128) {
    for (i = 0; t && i < 128; ++i) n += t[24 * i] ? 1 : 0;
    if (!pj_send(PJ_OP_LIST_END, t ? (uint32_t)n : 0x3fffu, 0)) return 0;
    pj.n_list++;
    if (t && pj.list_on > 1) { pj.list_on--; pj.list_pos = 0; }   /* 1052c: the second round */
    else pj.list_on = 0;
    return 1;
  }
  m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x4b; m[5] = 0x01; m[6] = PJ_OP_LIST;
  m[7] = (uint8_t)((pj.list_pos + 1) >> 7); m[8] = (uint8_t)((pj.list_pos + 1) & 0x7f); m[9] = PJ_LIST_N;
  for (i = 0; i < PJ_LIST_N; ++i) {
    const volatile uint8_t *e = t + 24 * (pj.list_pos + i);
    uint8_t *o = m + 10 + 16 * i;
    o[0] = e[0] ? 1 : 0;
    for (k = 0; k < 15; ++k) o[1 + k] = (uint8_t)(e[0] && k < 15 ? e[8 + k] & 0x7f : 0);
    for (k = 0; k < 15 && o[1 + k]; ++k) {}
    for (; k < 15; ++k) o[1 + k] = 0;   /* (past the NUL: the tail is not cleared on a rename [the research]) */
  }
  m[10 + 16 * PJ_LIST_N] = 0xf7;
  if (!send(m, 11 + 16 * PJ_LIST_N)) return 0;
  pj.list_pos += PJ_LIST_N;
  return 1;
}

static int32_t pj_send(uint8_t op, uint32_t a, uint32_t b) {
  uint8_t m[12] = {0xf0, 0x7d, 0x52, 0x54, (uint8_t)(op & 0x40 ? 0x4c : 0x4b), 0x01, (uint8_t)(op & 0x3f),
                   (uint8_t)(a >> 7 & 0x7f), (uint8_t)(a & 0x7f),
                   (uint8_t)(b >> 7 & 0x7f), (uint8_t)(b & 0x7f), 0xf7};
  return send(m, 12);
}
static void pj_tick(void) {
  int32_t i, same, slot = PJ_ACTIVE;
  uint8_t m[26], s1 = (uint8_t)(slot >= 0 && slot < 128 ? slot + 1 : 0);
  if (pj.lost != pj.lost_sent) {
    uint32_t n = pj.lost - pj.lost_sent;
    if (!pj_send(PJ_OP_LOST, n < 16383 ? n : 16383, 0)) return;
    pj.lost_sent += n;
    pj.list_on = PJ_LIST_ROUNDS, pj.list_pos = 0;   /* 1052b: the host resyncs from the LIST */
  }
  while (pj.rd != pj.wr) {
    const uint8_t *e = pj.ev[pj.rd % PJ_RING];
    __asm__ volatile("" : : : "memory");
    if (!pj_send(e[0], e[1], e[2])) return;   /* in order: the rest at the next tick */
    pj.rd++;
    pj.n_ev++;
  }
  same = pj.sent_ok && pj.sent_slot == s1 && pj.hellos == st.hellos && st.ticks - pj.last_tick < PJ_EVERY;
  for (i = 0; i < 16 && same; ++i)
    if (PJ_NAME[i] != pj.sent_name[i]) same = 0;
  if (same) {
    if (pj.list_on) pj_list_step();   /* 1052b: one LIST message a tick, behind the events and the ACTIVE */
    return;
  }
  if (pj.hellos != st.hellos) pj.list_on = PJ_LIST_ROUNDS, pj.list_pos = 0;   /* 1052b: a LIST after each hello's ACTIVE */
  m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x4b; m[5] = 0x01; m[6] = PJ_OP_ACTIVE;
  m[7] = s1 >> 7; m[8] = s1 & 0x7f;
  for (i = 0; i < 15 && PJ_NAME[i]; ++i) m[9 + i] = PJ_NAME[i] & 0x7f;
  m[9 + i] = 0xf7;
  if (!send(m, 10 + i)) return;
  pj.sent_ok = 1; pj.sent_slot = s1; pj.hellos = st.hellos; pj.last_tick = st.ticks;
  for (i = 0; i < 16; ++i) pj.sent_name[i] = PJ_NAME[i];
  pj.n_act++;
}

/* 1052: the detours (registry; displaced bytes re-emitted as words, as pin_det's). write-slot 0x40034e98 (lib, slot):
   `lea -32(sp),sp; moveq #127,d1` (6 B), its caller's return address at 0(sp); delete 0x40034a54 (lib, slot):
   `move.l d2,-(sp); moveq #-1,d0; move.l 12(sp),d2` (8 B); copy 0x4003502c (lib, slot): `link.w fp,#-28;
   movem.l d2-d3/a2,(sp)` (8 B); save 0x400b0738 (project, slot, cb): `lea -48(sp),sp; movem.l d2-d4/a2-fp,(sp)` (8 B).
   d0 / d1 / a0 / a1 are scratch at a function's entry; the C halves keep the rest. */
__asm__(
    "  .text\n"
    "  .globl pj_write_det, pj_delete_det, pj_copy_det, pj_save_det, pj_act_det\n"
    "  .globl kt_save_det, kt_reload_det, kt_all_det\n"
    "  .align 2\n"
    "pj_write_det:\n"
    "  move.l 8(%sp),-(%sp)\n"
    "  move.l 4(%sp),-(%sp)\n"
    "  jsr pj_write\n"
    "  addq.l #8,%sp\n"
    "  .short 0x4fef,0xffe0,0x727f\n"
    "  jmp 0x40034e9e\n"
    "  .align 2\n"
    "pj_delete_det:\n"
    "  move.l 8(%sp),-(%sp)\n"
    "  jsr pj_delete\n"
    "  addq.l #4,%sp\n"
    "  .short 0x2f02,0x70ff,0x242f,0x000c\n"
    "  jmp 0x40034a5c\n"
    "  .align 2\n"
    "pj_copy_det:\n"
    "  move.l 8(%sp),-(%sp)\n"
    "  jsr pj_copy\n"
    "  addq.l #4,%sp\n"
    "  .short 0x4e56,0xffe4,0x48d7,0x040c\n"
    "  jmp 0x40035034\n"
    "  .align 2\n"
    "pj_save_det:\n"
    "  move.l 8(%sp),-(%sp)\n"
    "  jsr pj_save\n"
    "  addq.l #4,%sp\n"
    "  .short 0x4fef,0xffd0,0x48d7,0x7c1c\n"
    "  jmp 0x400b0740\n"
    "  .align 2\n"
    "pj_act_det:\n"                 /* 1052b: the active-slot setter 0x400fa694 (slot): `mvs.b 0x405c8e4d,d1` (6 B) */
    "  move.l 8(%sp),-(%sp)\n"     /* caller: the helper's return address (entry 8(sp)) */
    "  move.l 4(%sp),-(%sp)\n"     /* ret: the setter's return address (entry (sp)) */
    "  move.l 12(%sp),-(%sp)\n"    /* slot (entry 4(sp)) */
    "  jsr pj_activate\n"
    "  lea 12(%sp),%sp\n"
    "  .short 0x7339,0x405c,0x8e4d\n"
    "  jmp 0x400fa69a\n"
    /* 1052d: kit_save 0x400b119c `lea -60(sp),sp; movem.l d2-d7/a2-fp,(sp)` (8 B): the stock function runs (called with
       its 3 arguments and one more copied), then kt_saved(index, the active kit at the entry) */
    "  .align 2\n"
    "kt_save_det:\n"
    "  move.l 0x800067b8,-(%sp)\n"   /* pre (the active kit), above the return address */
    "  lea -16(%sp),%sp\n"
    "  move.l 24(%sp),(%sp)\n"
    "  move.l 28(%sp),4(%sp)\n"
    "  move.l 32(%sp),8(%sp)\n"
    "  move.l 36(%sp),12(%sp)\n"
    "  jsr kt_save_orig\n"
    "  lea 16(%sp),%sp\n"
    "  move.l %d0,-(%sp)\n"          /* (pre at 4, the index at 16) */
    "  move.l 4(%sp),-(%sp)\n"
    "  move.l 20(%sp),-(%sp)\n"
    "  jsr kt_saved\n"
    "  addq.l #8,%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  addq.l #4,%sp\n"
    "  rts\n"
    "kt_save_orig:\n"
    "  .short 0x4fef,0xffc4,0x48d7,0x7cfc\n"
    "  jmp 0x400b11a4\n"
    /* kit_reload 0x400af0d2 `lea -20(sp),sp; movem.l d2-d4/a2-a3,(sp)` (8 B) and the reload of every kit 0x400b131a
       `lea -28(sp),sp; movem.l d2-d4/a2-a5,(sp)` (8 B): the stock function (its argument and one more), then
       kt_reloaded(op) */
    "  .align 2\n"
    "kt_reload_det:\n"
    "  move.l 8(%sp),-(%sp)\n"
    "  move.l 8(%sp),-(%sp)\n"
    "  jsr kt_reload_orig\n"
    "  addq.l #8,%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  pea 0x42\n"
    "  jsr kt_reloaded\n"
    "  addq.l #4,%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "kt_reload_orig:\n"
    "  .short 0x4fef,0xffec,0x48d7,0x0c1c\n"
    "  jmp 0x400af0da\n"
    "  .align 2\n"
    "kt_all_det:\n"
    "  move.l 8(%sp),-(%sp)\n"
    "  move.l 8(%sp),-(%sp)\n"
    "  jsr kt_all_orig\n"
    "  addq.l #8,%sp\n"
    "  move.l %d0,-(%sp)\n"
    "  pea 0x44\n"
    "  jsr kt_reloaded\n"
    "  addq.l #4,%sp\n"
    "  move.l (%sp)+,%d0\n"
    "  rts\n"
    "kt_all_orig:\n"
    "  .short 0x4fef,0xffe4,0x48d7,0x3c1c\n"
    "  jmp 0x400b1322\n"
    );
