/*
 * 0029-sendfx-ui: the Rytm's pages for the Sidecar send FX (M4 of rytm-teensy
 * docs/superpowers/specs/2026-10-16-sidecar-send-fx-research.md; storage in
 * -storage.md; mapping as the M2 side's sim/protocol.py). Code in elekloader's
 * DDR area (area = "elek"); every hook runs in the UI task.
 *
 * Pages (a second press of the page key, the stock multi-page cycle):
 *   AMP    -> AMPLITUDE 2 (page 12): SFX1 SFX2 = sound index 0 hi / lo
 *   DELAY  -> SEND FX 1   (page 13): TYPE P1 = FX word 29 hi/lo, P2 P3 = 38, P4 P5 = 39
 *   REVERB -> SEND FX 2   (page 14): TYPE P1 = FX word  0 hi/lo, P2 P3 = 40, P4 P5 = 41
 * (on the FX track SRC opens DELAY and SMPL REVERB).
 *
 * The knobs are parameter records 14..27 (dead 'Error' records: no CC maps to
 * them [measured: the CC tables 0x413dc2d8 / 0x413dcb14 hold none of 1..27]),
 * filled at the first ev_tick with a real container index (sound 0, FX 29 / 0 /
 * 38..41), range 0..0x7f00, no CC, so the stock paths store, save and lock the
 * word. Two knobs share a word (hi = bits 8..14, lo = bits 1..7, a lock's coarse
 * and fine slots), so the parameter sets' read, write, lock-get and lock-set
 * (Sound/FxParameterSet vtables +0x28, +0x70, +0x3c, +0x40) are wrapped: for these
 * ids the value is the half, a write merges it into the word.
 * TYPE and P1 (the halves of words 29 and 0) are kit only: lock-set is refused for
 * them, so those two words never carry a lock (a lock on P1 would hold TYPE too).
 *
 * Stepped knobs (sfx-enum-knobs, 2026-10-18): TYPE (the Sidecar's name list), P1 ROUTE
 * (PRE / POST) and a P2..P5 whose zones carry the 24's step bit are enum records like
 * stock's FILTER TYPE (record 49): range 0..(N-1) << 8, the enum encoder profile
 * (descriptor +0x10, as record 49's), a text in place of the dial. Through the
 * wrappers the knob's value is the step index; the word keeps what the Sidecar
 * reads (the TYPE id, P1 0 / 127, the zone's lo), so kits, locks and an older
 * Sidecar or Rytm keep working.
 */
#include <stdint.h>

#define ID0     14
#define NID     14
#define OURS(id) ((uint32_t)((id) - ID0) < NID)
/* sfx-basewidth (0.5.0): SEND FX 1 / 2's knobs G and H, BASE and WIDTH of the Sidecar's send FX return filter (its bus
   1 / 2 POST EQ: HPF = BASE, LPF at BASE + WIDTH; rytm-teensy docs/INSERT-FX.md "BASE / WIDTH"). Records 1..4 (dead
   'Error' records, 0004-lfo-rnd's ids 1..4, which 0029 excludes with 0013): FX k's BASE = 1 + 2k, WIDTH = 2 + 2k. Their
   values live on the host (its kit file's PEQ line), not in the Rytm's kit (its words are full): the FX set's wrappers
   answer them from bw[][], a turn goes to the host as 22 ver 2 (FX, BASE, WIDTH) and the host's 22 ver 2 sets them. No
   p-locks (lock-set refused, as TYPE's). */
#define BW0     1
#define BW(id)  ((uint32_t)((id) - BW0) < 4)
#define BW_HOLD (132000u * 500u)   /* 500 ms of DTCN0 (132 MHz): a host value this soon after our turn's send crossed it */

typedef int32_t (*rd_fn)(void *set, int32_t id);
typedef int32_t (*wr_fn)(void *set, int32_t id, int32_t v, int32_t a, int32_t b);
typedef int32_t (*lg_fn)(void *set, int32_t id, int32_t step);
typedef int32_t (*ls_fn)(void *set, int32_t id, int32_t v, int32_t step);
typedef int32_t (*sprintf_fn)(void *str, const char *fmt, ...);
typedef void (*send_fn)(int32_t len, const uint8_t *data);
typedef void (*void_fn)(void);

#define S_READ  ((rd_fn)0x400a8dfau)
#define S_WRITE ((wr_fn)0x400a9f9eu)
#define S_LGET  ((lg_fn)0x400a9848u)
#define S_LSET  ((ls_fn)0x400a98bau)
#define F_READ  ((rd_fn)0x400a8e90u)
#define F_WRITE ((wr_fn)0x400aa01cu)
#define F_LGET  ((lg_fn)0x400a99bau)
#define F_LSET  ((ls_fn)0x400a9a2cu)
#define STR_PRINTF ((sprintf_fn)0x40098602u)
#define MIDI_SEND   ((send_fn)0x400029e0u)
/* Never wait on USB (the UI task): 0026-remote-ui's pattern. MIDI_LOCK 0x40002914 = take(0x42f67a28) pends while
   another task owns it, and the sender spins while its 4 KB ring is full; so a try-lock of the same mutex
   (0x4000119c: owner 0 -> the current task, 1; else 0, never pends [code, 1.73]) given back with MIDI_UNLOCK's callee
   0x400011ee, after the sender's own tests: port configured, ring room, free USB requests. Else: next tick. */
typedef int32_t (*trylock_fn)(void *m);
typedef void (*unlock_fn)(void *m);
#define MIDI_MUTEX  ((void *)0x42f67a28u)
#define MUTEX_TRY   ((trylock_fn)0x4000119cu)
#define MUTEX_GIVE  ((unlock_fn)0x400011eeu)
#define ACTIVE_KIT  (*(const volatile uint32_t *)0x800067b8u)   /* the kit number (0025, 0026 read it as well) */
#define PORT_STATE  (*(volatile uint32_t *)0x413db254u)   /* 1: configured (the sender's first test) */
#define TX_LEVEL    (*(volatile int32_t *)0x413db258u)    /* the sender spins while level + n > 4091 */
#define USB_POOL    (*(const volatile uint32_t *const volatile *)0x413db390u)   /* free requests, next +52 */

#define REC(r)  ((uint32_t *)(0x401bf918u + 0x34u * (uint32_t)(r)))   /* fields set at build (registry); names here */
#define DESC(r) ((uint32_t *)(0x419a4888u + 84u * (uint32_t)(r)))
#define REC_DIAL 410   /* a plain numeric dial (0021's REC_DIAL) */
#define REC_DEL  60    /* AMP DEL: the stock send knob's look */
#define REC_FTYP 49    /* FILTER TYPE: the stock enum (range 0..0x600, encoder profile 0x417e37ac) [measured, 1.73] */
#define REC_LOOP 45    /* SAMPLE LOOP: the stock OFF / ON toggle (the same profile, the switch draw 0x400fed88) */
#define REC_DROUT 81   /* DISTORTION DEL: the stock PRE / POST text draw 0x400fbe1e */
#define DESC_BASE 0x419a4888u
typedef void *(*font_fn)(void *ctx);
typedef void (*tdraw_fn)(int32_t x, void *font, int32_t y, int32_t h, int32_t a, int32_t b, const char *w,
                         const char *fmt, ...);
#define TEXT_FONT ((font_fn)0x40071b7cu)   /* text_font(ctx) */
#define TEXT_DRAW ((tdraw_fn)0x400714e0u)  /* text_draw, as the PRE / POST draw 0x400fbe1e calls it */
#define TEXT_CTX  ((void *)0x417e389cu)

/* per knob: container index, half (0 hi, 1 lo), kit only, kind (record +0) */
static const uint8_t k_cidx[NID] = {0, 0, 29, 29, 38, 38, 39, 39, 0, 0, 40, 40, 41, 41};
#define HALF(i) ((i) & 1)
#define KITONLY(i) ((i) >= 2 && ((i) - 2) % 6 < 2)   /* TYPE and P1 of each FX */
#define ISTYPE(i) ((i) >= 2 && ((i) - 2) % 6 == 0)
#define ISP1(i) ((i) >= 2 && ((i) - 2) % 6 == 1)
#define FXOF(i) ((i) >= 8)
#define PJ(i) (((i) - 2) % 6 - 2)                     /* P2..P5 = 0..3 (for i with PJ >= 0) */

static const char s_sfx1[] = "SFX1", s_sfx2[] = "SFX2", s_type[] = "TYPE", s_route[] = "ROUT";
static const char s_pre[] = "PRE", s_post[] = "POST", fmt_n[] = "%s%d", fmt_sn[] = "%s %d";
static const char l_sfx1[] = "Send FX 1", l_sfx2[] = "Send FX 2";
static const char l_fx1[] = "Send FX 1", l_fx2[] = "Send FX 2";
static const char s_empty[] = "";
static const char fmt_s[] = "%s", fmt_bang[] = "!%s", fmt_d[] = "%s%d", s_wide[] = "XXXX";
static const char s_fx[] = "FX", s_ufx[] = "UFX";
static const char s_base[] = "BASE", s_wid[] = "WID";

/* page descriptors {name, ids[8]} for page ids 12, 13, 14 (page_info answers them) */
static const char n_amp2[] = "AMPLITUDE 2", n_fx1[] = "SEND FX 1", n_fx2[] = "SEND FX 2";
struct page { const char *name; uint32_t id[8]; };
/* (sendfx-pages: written at run time - the title "SEND FX 1 2/3" and page 3's empty knobs E..H) */
struct page sfu_pages[3] = {
  {n_amp2, {ID0 + 0, ID0 + 1, 0, 0, 0, 0, 0, 0}},
  {n_fx1, {ID0 + 2, ID0 + 3, ID0 + 4, ID0 + 5, ID0 + 6, ID0 + 7, BW0 + 0, BW0 + 1}},
  {n_fx2, {ID0 + 8, ID0 + 9, ID0 + 10, ID0 + 11, ID0 + 12, ID0 + 13, BW0 + 2, BW0 + 3}},
};
/* the three views' page vectors (view factory 0x400ca9b2), count 2 each */
const uint32_t sfu_vec_amp[2] = {7, 12}, sfu_vec_del[2] = {8, 13}, sfu_vec_rev[2] = {9, 14};

/* The TYPE names: built-in ids as rytm-teensy sim/protocol.py SENDFX_TYPES until the Sidecar sends its
   list (21); a NUL first byte = no name (shown FX<n> / UFX<n>). miss[k]: FX k+1's TYPE id the Sidecar
   reported MISSING (22), shown !NAME; 0xff none. */
struct sfu_state {
  char name[128][8];
  uint8_t miss_id[2];
  uint8_t init, asked;
  uint16_t ask_div;
  uint32_t calls, ticks;
  uint32_t full_n, full_t;   /* fxfull-refuse (appended): FX locks refused (lock memory full), TIMER | 1 at the last popup */
  volatile uint8_t full_p;   /* fxfull-refuse round 4 (appended): a popup wanted; set by any task, shown and cleared by sfu_tick */
};
struct sfu_state sfu_st = {
  {"OFF", "CHORUS", "COMB", "DELAY", "PINGPNG", "TAPEDLY", "RINGS", "S4 RESO", "CLDSEED", "PLASMA", "PLATE",
   "HALL", "SHIMMER", "FLANGER", "PHASER"},
  {0xff, 0xff}, 0, 0, 0, 0, 0, 0, 0};
#define st sfu_st   /* global: the emulator tests read it (tools/emu/sfu_emu.py) */

/* 24 SENDFX LABELS (rytm-teensy sim/protocol.py sendfx_labels): per TYPE the labels of P2..P5 and its zones. Fixed
   tables, NLT TYPEs of NZ zones (the message's cap); written by the MIDI task (sfu_sysex), read by the UI task. An
   entry is free while idp1 (id + 1) is 0; a 21 with replace frees them all. 1049: 16 (8 before; the Sidecar has 9
   TYPEs with labels since SPACE: a host past rui1049's hello caps bit 1 sends up to 16). The emulator tests' offsets of
   the fields after lab[] follow NLT (tools/emu/sfu_emu.py DL, us_emu.py). */
#define NLT 16
#define LNG 16                  /* 51's full names: 16 characters (rytm-teensy core/fx/knob_labels.h kLongChars) */
#define NZ 12
#define XR0 334                 /* 0021's records: the user slots 334..373, JUNO / FM 374..389, DIGIDRUM 390.., */
#define NXR 127                 /* PLAITS 408.., DSP SAMPLE / DAISYSP 416..453, page 2 457..460 */
#define XBOX ((const volatile uint32_t *)0x4001a23cu)   /* 0021's ext_stepbox: 'XSTP', ext_steps, us_live (.usm) */
struct sfu_zone { uint8_t kf, lo, base; char name[6]; };   /* kf: knob 0..3 (P2..P5) | show << 2 */
struct sfu_lab { uint8_t idp1, nz; char lab[4][5]; struct sfu_zone z[NZ]; };
struct sfu_x {
  struct sfu_lab lab[NLT];
  volatile uint32_t gen;          /* bumped by every 21 replace / 24 (MIDI task) */
  uint32_t shown_gen;             /* the gen the label buffers were made for (UI task) */
  uint8_t cur[2], shown[2];       /* FX k's TYPE (from the FX set), and the TYPE the label buffers show */
  char lbl[2][4][5];              /* the record short names of P2..P5 (FX 1, FX 2) */
  void *fxset;                    /* the FX parameter set, as the page's reads pass it */
  int32_t (*dial)(void *, int32_t, void *);   /* the plain dial's value text (record 410's) */
  uint32_t fxset_changes, lab_drop, lab_rx, asks, tx_busy, relabels;
  uint32_t ui_sum, ui_max, ui_n, mt_sum, mt_max, mt_n;   /* DTCN0 counts inside sfu_tick + the value texts, sfu_sysex */
  /* sfx-enum-knobs (appended: the fields above keep their offsets for sfu_emu.py) */
  uint8_t order[128];             /* the 21 list's ids in order, OFF first (MIDI task) */
  uint32_t norder;
  volatile uint32_t ogen;         /* odd while the MIDI task writes order */
  uint8_t ulist[128];             /* the UI task's copy, taken when ogen is even and new */
  uint32_t un, ugen;
  uint8_t kn[2][4];               /* P2..P5 of FX k: 0 continuous, else the step count (zones) */
  uint8_t klo[2][4][NZ];          /* the steps' stored values (the zones' lo, in order) */
  uint8_t look[NID];              /* the record's look now: 0 dial, 1 text enum, 2 toggle, 3 PRE / POST */
  uint8_t tu[2];                  /* TYPE cache: for id tu (and ulist gen ugen), the list index (0xff none) */
  uint8_t tli[2], tins[2];        /*   and where an unlisted tu sits */
  uint32_t tgen[2];
  uint32_t steps, list_rx;        /* stepped writes, 21 lists taken */
  /* 0021's list knobs (records XR0..XR0 + NXR - 1, ext_steps through ext_stepbox) */
  uint8_t xm[NXR], xn[NXR];       /* mode (0 continuous, 1 zones, 2 list, 3 all 128), N */
  uint32_t xtick[NXR];            /* the tick xm / xn were asked for (+ 1; 0 never) */
  uint32_t xtext[NXR];            /* the record's own value text (0021's), called with the stored value */
  uint32_t xsave[NXR][5];         /* its descriptor words 0 1 2 4 12 before the enum look */
  uint32_t xsteps, xwraps;
  uint32_t lv_sum, lv_max, lv_n;  /* DTCN0 inside 0021's us_live (its own work, timed apart from 0029's) */
  /* rui1031 (appended): a list whose value beyond its end reads as entry 0 (ext_steps' bit 10: the chord knobs, as the
     host's core/poly.cpp idx()), not the last */
  uint8_t xf[NXR];
  /* rui1038 (appended): a banked knob (ext_steps' bit 11: 0026's GRANULAR SRC / WAVETABLE TBL / MULTISAMPLE INST, index
     << 8 | bank << 5): the knob's value carries the word's fraction bits 0xe0, a turn or a lock keeps the stored bank */
  uint8_t xk[NXR];
  /* sfx-basewidth (appended): FX k's BASE / WIDTH (0..127) as the host last sent them or the knob last set them; bw_tx
     bit k: FX k's turn not sent yet (UI task); bw_rx: a host value taken (MIDI task), the views redraw */
  uint8_t bw[2][2];
  uint8_t bw_tx;
  volatile uint8_t bw_rx;
  uint32_t bw_sent, bw_got;
  /* sfx-basewidth review (appended): TIMER | 1 when FX k's last turn was sent (0 never); a host value for it within
     BW_HOLD crossed that turn on the wire and is not taken (the host keeps the turn and its 2 s refresh says it) */
  uint32_t bw_hold[2];
  /* sfx-full-names (appended, issue #14): 51 SENDFX FULL NAMES. lng[k]: lab[k]'s TYPE's full names of P2..P5 (NUL first
     byte: none, the record keeps "Send FX n"); written by the MIDI task beside lab[k] (hidden while written: a new entry's
     idp1 is 0 until it is complete, lng_ok bit k clear). lname[fx][j]: P2..P5's record long names now (UI task, relabel). */
  char lng[NLT][4][LNG + 1];
  uint16_t lng_ok;
  char lname[2][4][LNG + 1];
  uint32_t lng_rx, lng_drop;
};
/* sendfx-pages (issue #15; based on twwwy's #19): a user effect's P5..P16 on SEND FX pages 2 (A..H = P5..P12) and 3 (A..D =
   P13..P16), held by the Sidecar as BASE / WIDTH are (22 ver 3 both ways), never in the kit, no locks. No parameter record
   is free (the 1.74 table's 469 records: 0..27 all used or CC-mapped, design.md section 13), so the FX's own 8 records on
   its page (TYPE P1 P2..P5 BASE WID) switch to the page's knobs while a page past 1 shows: the FX set's wrappers answer
   them from pv[][] first. The page key (SRC for FX 1, SMPL for FX 2) pressed on its own SEND FX page steps to the next
   page while the effect has one, and is eaten; on the last page it is stock's, which leaves for DELAY / REVERB. Leaving
   the page by any way (another page or track, a kit change, a host 21 replace) puts it back on page 1. A struct of its
   own (not appended to sfu_x), so the emulator tests read it by its symbol. */
#define NPX 12
struct sfu_p {
  char xsh[NLT][NPX][5];          /* lab[k]'s TYPE's P5..P16 short / full names (51 first p 5..16; MIDI task, as lng) */
  char xlng[NLT][NPX][LNG + 1];
  uint8_t np[NLT];                /* the highest P the 51s named for lab[k] (0 none): the page count follows it */
  uint8_t pg[2], npg[2], nx[2];   /* FX k's page (0 = TYPE..WID), its pages (1..3) and its P5.. count (0..12) */
  uint8_t pv[2][NPX];             /* P5..P16 as the host last sent them or a knob last set them */
  uint16_t pv_tx[2];              /* bit j: FX k's P(5 + j) turned, not sent yet (UI task) */
  volatile uint8_t pv_rx;         /* a host value taken (MIDI task): the views redraw */
  uint8_t ontop;                  /* 1 / 2: SEND FX 1 / 2 is the screen (the tick, from the view list), 0 neither */
  uint8_t kdn, ate, mods;         /* bit k: SRC / SMPL down; its press was eaten (its repeats and release are too); bit 0 / 1: FUNC / UP down */
  uint32_t pv_hold[2];            /* TIMER | 1 at FX k's last send (BW_HOLD's crossing rule) */
  uint32_t pv_sent, pv_got, steps, resets, retitles;   /* counters (tests) */
  void *fxview;                   /* the page view the SEND FX knobs were last read through (sfu_get) */
  uint32_t fxvt;                  /* its vtable then */
  char pl_s[2][8][5], pl_l[2][8][LNG + 1];   /* FX k's paged records' short / long names now */
  char ttl[2][16];                /* the page's title: "SEND FX 1 2/3" (an effect with pages), else n_fx1 / n_fx2 */
  void *ctrl;                     /* the UI controller the tick was last given (its view list: top_page) */
  uint32_t ovl;                   /* nonzero: 0026's host page or splash is the screen (0026 writes it at 0x47C071F0; a key is not ours then) */
  uint32_t kit[2];                /* ACTIVE_KIT when FX k's page past 1 was entered, and the six FX words then (ksig): a kit change that */
  uint32_t ksig[2];               /* keeps the TYPE (another kit, the same slot loaded again) is seen as a difference */
  uint8_t rt, up;                 /* bit k: FX k's title to push again (a reset); the port was up at the last tick */
  uint8_t pad[10];                /* the claim is 16-byte aligned (4,736 B): the zeroing covers all of it */
};
/* ---- big-ram (design.md "big-ram"): sfu_x (7.9 KB) and sfu_p (4.8 KB) live in the bundle's DDR region (registry [[buffer]]
   sfu_x and sfu_p of the pool sidecar_buffers, 0x47C00000-0x47F00000), not in elekloader's 128 KB area. build.py gives this
   mod RAM_SFU_X and RAM_SFU_P (the claims' addresses) and their _SIZE as assembler symbols; DDR() declares each as an
   absolute symbol of its name. To put one back in .bss: replace its DDR() line by `struct sfu_x sfu_x;` and drop it from
   the zeroing in tick_body. Nothing zeroes this RAM at boot (only the area's .bss is): tick_body zeroes both in its first
   call, before anything of this mod's own reads them (the F-set wrappers below guard their reads with st.ticks and answer
   the stored half, 1 or 0 before it; pq() says "not paged" and sfu_get leaves sfu_p alone before it; the one exception is
   see_fxset's comparison, which feeds a diagnostic counter), and st.ticks (in .data, the copy the boot makes) says it is
   done. Only the UI task and the MIDI task touch them, never the audio interrupt. What stays in the area: sfu_st (.data:
   the TYPE names the host replaces, init flags) and sfu_pages (.data, 108 B: the OS reads the page descriptors before the
   first tick, and the tick writes titles and ids into them). */
#define DDR(decl, name, claim) extern decl; __asm__(".globl " #name "\n.set " #name ", RAM_" #claim)
DDR(struct sfu_x sfu_x, sfu_x, SFU_X);
DDR(struct sfu_p sfu_p, sfu_p, SFU_P);
/* 0026 writes ovl at the claim's base + 4704 (rui.c SFU_OVL, a literal there): a field added before it moves it, and tools/build.py
   (check_buffer_ties) compares the same number with the registry's claim and rui.c */
_Static_assert(__builtin_offsetof(struct sfu_p, ovl) == 4704, "sfu_p.ovl moved: 0026's SFU_OVL and build.py's BUFFER_TIES name its offset");
#define X sfu_x
#define PG sfu_p
#define TIMER (*(volatile uint32_t *)0xfc07000cu)   /* DTCN0, the OS's free-running count (0026's TIMER) */
static void timed(uint32_t t0, int32_t mt) {
  uint32_t d = TIMER - t0;
  if (mt) { X.mt_sum += d; X.mt_n++; if (d > X.mt_max) X.mt_max = d; }
  else { X.ui_sum += d; X.ui_n++; if (d > X.ui_max) X.ui_max = d; }
}

static int32_t half_of(int32_t i, int32_t raw) {
  return HALF(i) ? (raw & 0xfe) << 7 : raw & 0x7f00;
}
static int32_t merge(int32_t i, int32_t raw, int32_t v) {
  if (v < 0) v = 0;
  if (v > 0x7f00) v = 0x7f00;
  return HALF(i) ? (raw & 0x7f00) | ((v >> 7) & 0xfe) : (v & 0x7f00) | (raw & 0xfe);
}

/* ---- stepped knobs: index <-> stored value ---- */
static void tcache(int32_t fx, int32_t u) {
  uint32_t k, ins = 1;
  int32_t li = -1;
  if (X.tu[fx] == u && X.tgen[fx] == X.ugen + 1) return;
  for (k = 0; k < X.un; ++k) {
    if (X.ulist[k] == u) li = (int32_t)k;
    if (k && X.ulist[k] < u) ins++;
  }
  X.tu[fx] = (uint8_t)u;
  X.tli[fx] = li < 0 ? 0xff : (uint8_t)li;
  X.tins[fx] = (uint8_t)ins;
  X.tgen[fx] = X.ugen + 1;
}
/* the TYPE list as the knob steps it: OFF and the 21's ids in order, plus the kit's id u where it is not listed
   (MISSING, an id a newer project names) - selectable until moved away, between its numeric neighbours */
static int32_t tcount(int32_t fx, int32_t u) { tcache(fx, u); return (int32_t)X.un + (X.tli[fx] == 0xff); }
static int32_t tpos(int32_t fx, int32_t u) {
  tcache(fx, u);
  return X.tli[fx] == 0xff ? X.tins[fx] : X.tli[fx];
}
static int32_t tid(int32_t fx, int32_t u, int32_t p) {
  int32_t n = tcount(fx, u);
  if (p < 0) p = 0;
  if (p >= n) p = n - 1;
  if (X.tli[fx] == 0xff) {
    if (p == X.tins[fx]) return u;
    if (p > X.tins[fx]) p--;
  }
  return X.ulist[p];
}
/* half (0..0x7f00, the 7-bit value << 8) -> the knob's value: the step index << 8 for a stepped knob */
static int32_t to_knob(int32_t i, int32_t h) {
  int32_t v = h >> 8, k, n;
  if (ISTYPE(i)) return tpos(FXOF(i), v) << 8;
  if (ISP1(i)) return v >= 64 ? 0x100 : 0;
  if (i < 2 || !(n = X.kn[FXOF(i)][PJ(i)])) return h;
  for (k = n - 1; k > 0 && X.klo[FXOF(i)][PJ(i)][k] > v; --k) {}
  return k << 8;
}
/* the knob's value -> the half to store; u: the TYPE id the word holds now (TYPE only) */
static int32_t to_half(int32_t i, int32_t v, int32_t u) {
  int32_t k = v >> 8, n;
  if (k < 0) k = 0;
  if (ISTYPE(i)) return tid(FXOF(i), u, k) << 8;
  if (ISP1(i)) return k ? 0x7f00 : 0;
  if (i < 2 || !(n = X.kn[FXOF(i)][PJ(i)])) return v;
  if (k >= n) k = n - 1;
  X.steps++;
  return X.klo[FXOF(i)][PJ(i)][k] << 8;
}
static void relabel(void);
/* FX k's TYPE from the set (base, the kit's: TYPE is not lockable); the labels, steps and looks follow it at once,
   so a kit or pattern change, a TYPE turn or a 24 never steps a knob by the old TYPE's zones */
static void sync(void *set) {
  int32_t t0 = (F_READ(set, ID0 + 2) >> 8) & 0x7f, t1 = (F_READ(set, ID0 + 8) >> 8) & 0x7f;
  X.cur[0] = (uint8_t)t0;
  X.cur[1] = (uint8_t)t1;
  if (X.gen != X.shown_gen || t0 != X.shown[0] || t1 != X.shown[1]) {
    X.shown_gen = X.gen;
    relabel();
  }
  if (!PG.pg[0]) REC(ID0 + 2)[3] = (uint32_t)((tcount(0, t0) - 1) << 8);   /* (paged: knob A is P5's dial) */
  if (!PG.pg[1]) REC(ID0 + 8)[3] = (uint32_t)((tcount(1, t1) - 1) << 8);
}

/* ---- 0021's list knobs: the same enum look, the step through ext_steps (mode << 8 | N) ---- */
int32_t sfu_xtext(void *functor, int32_t value, void *str);
int32_t sfu_draw(void *functor, int32_t value, int32_t x, int32_t y, int32_t h, int32_t one);
static int32_t xmode(int32_t r) {
  uint32_t i = (uint32_t)(r - XR0), *d, *rec;
  if (i >= NXR || !st.init || XBOX[0] != 0x58535450u) return 0;
  if (X.xtick[i] != st.ticks + 1) {   /* asked once a UI tick: a list's length follows the host's 16 / 17 / 1B */
    int32_t m = ((int32_t (*)(int32_t))XBOX[1])(r);
    X.xsteps++;
    X.xm[i] = (uint8_t)(m >> 8 & 3);
    X.xn[i] = (uint8_t)m;
    X.xf[i] = (uint8_t)(m >> 10 & 1);
    X.xk[i] = (uint8_t)(m >> 11 & 1);
    if (X.xn[i] < 2) X.xm[i] = 0;
    X.xtick[i] = st.ticks + 1;
  }
  d = DESC(r);
  rec = REC(r);
  if (X.xm[i]) {
    if (d[8] != (uint32_t)sfu_xtext) {   /* first time, or 0021 copied a look in since (ext_descriptors, a 1A) */
      const uint32_t *f = DESC(REC_FTYP);
      X.xsave[i][0] = d[0]; X.xsave[i][1] = d[1]; X.xsave[i][2] = d[2]; X.xsave[i][3] = d[4]; X.xsave[i][4] = d[12];
      X.xtext[i] = d[8];
      d[0] = f[0]; d[1] = f[1]; d[2] = f[2]; d[4] = f[4];
      d[12] = (uint32_t)sfu_draw;
      d[8] = (uint32_t)sfu_xtext;
      X.xwraps++;
    }
    rec[3] = (uint32_t)(X.xn[i] - 1) << 8 | (X.xk[i] ? 0xe0u : 0);   /* every time: 0021 writes a slot's ranges at its
                                                                      page set-up; rui1038: a banked knob up to bank H */
  } else if (d[8] == (uint32_t)sfu_xtext) {   /* a list gone (another project, no presets): the dial back */
    d[0] = X.xsave[i][0]; d[1] = X.xsave[i][1]; d[2] = X.xsave[i][2]; d[4] = X.xsave[i][3]; d[12] = X.xsave[i][4];
    d[8] = X.xtext[i];
    rec[3] = 0x7f00;
  }
  return X.xm[i];
}
static int32_t x_knob(int32_t r, int32_t h) {
  int32_t i = r - XR0, v = h >> 8, n = X.xn[i];
  if (v < 0) v = 0;
  if (v > 127) v = 127;
  if (X.xm[i] == 1) v = (v * n) >> 7;
  else if (X.xm[i] == 2 && v > n - 1) v = X.xf[i] ? 0 : n - 1;
  return v << 8 | (X.xk[i] ? h & 0xe0 : 0);   /* rui1038: a banked knob shows its bank */
}
static int32_t x_half(int32_t r, int32_t v) {
  int32_t i = r - XR0, k = v >> 8, n = X.xn[i];
  if (k < 0) k = 0;
  if (k > n - 1) k = X.xf[i] && X.xm[i] == 2 ? 0 : n - 1;
  if (X.xm[i] == 1) k = (128 * k + n - 1) / n;   /* the zone's lowest value: v x N / 128 reads k again */
  X.steps++;
  return k << 8 | (X.xk[i] ? v & 0xe0 : 0);
}
/* rui1038: a banked knob's write keeps the bank the word holds (cur), whatever the knob's arithmetic did to the fraction */
static int32_t x_keep(int32_t r, int32_t v, int32_t cur) {
  return X.xk[r - XR0] && cur >= 0 ? (v & 0x7f00) | (cur & 0xe0) : v;
}
/* 0021's value text, given the stored value (its zone / entry rule), for the knob's step */
static int32_t xname(void *functor, int32_t value, void *str) {
  int32_t r = (int32_t)(((uint32_t)functor - DESC_BASE - 20u) / 84u), i = r - XR0;
  if ((uint32_t)i >= NXR || !X.xtext[i]) return STR_PRINTF(str, fmt_d, s_empty, value >> 8);
  if (X.xm[i]) value = x_half(r, value), X.steps--;
  return ((int32_t (*)(void *, int32_t, void *))X.xtext[i])(functor, value, str);
}
/* The record's value text, which the stock UI shows where the label is while the knob turns (the name is drawn where
   the dial was, by sfu_draw through xname): for a named step (zones, a list) the step's number, 1-based, so the name
   is not on the screen twice (hardware report 2026-10-17: a 6-OP FM patch name twice while scrolling). The 128-value
   knobs print their number in the dial already and keep 0021's text. */
int32_t sfu_xtext(void *functor, int32_t value, void *str) {
  int32_t r = (int32_t)(((uint32_t)functor - DESC_BASE - 20u) / 84u), i = r - XR0, k;
  if ((uint32_t)i < NXR && X.xtext[i] && (X.xm[i] == 1 || X.xm[i] == 2)) {
    k = value >> 8;
    if (k < 0) k = 0;
    if (k > X.xn[i] - 1) k = X.xf[i] && X.xm[i] == 2 ? 0 : X.xn[i] - 1;
    return STR_PRINTF(str, fmt_d, s_empty, k + 1);
  }
  return xname(functor, value, str);
}
/* sendfx-pages: record id's knob on its FX's page (0..7: TYPE P1 P2..P5 BASE WID) and that FX, -1 none of them */
static int32_t slot_of(int32_t id, int32_t *k) {
  if (OURS(id) && id - ID0 >= 2) { *k = FXOF(id - ID0); return (id - ID0 - 2) % 6; }
  if (BW(id)) { *k = (id - BW0) >> 1; return 6 + ((id - BW0) & 1); }
  return -1;
}
/* the P5.. index (0..11) record id shows now: -1 not paged (its own knob), -2 paged and empty (past the effect's last) */
static int32_t pq(int32_t id, int32_t *k) {
  int32_t s = slot_of(id, k), q;
  if (s < 0 || !st.ticks || !PG.pg[*k]) return -1;   /* (before the first tick sfu_p is not zeroed: not paged) */
  q = 8 * (PG.pg[*k] - 1) + s;
  return q < PG.nx[*k] ? q : -2;
}

/* page_get_value's gate: our records, and 0021's while stepped (their locks through the set, not the raw word) */
int32_t sfu_isext(int32_t id) { return BW(id) || xmode(id) != 0; }

/* the wrapped vtable entries (ptr patches in the registry) */
int32_t sfu_s_read(void *set, int32_t id) {
  int32_t r = S_READ(set, id);
  if (OURS(id)) return half_of(id - ID0, r);
  return xmode(id) ? x_knob(id, r) : r;
}
static __attribute__((noinline)) void see_fxset(void *set) {   /* (a symbol: sfu_emu pretick calls it) */
  if (!st.ticks) return;   /* (before the first tick sfu_x is not zeroed: junk) */
  if (set != X.fxset) { if (X.fxset) X.fxset_changes++; X.fxset = set; }
}
int32_t sfu_f_read(void *set, int32_t id) {
  int32_t r, k, q = pq(id, &k);
  if (q != -1) return q >= 0 ? PG.pv[k][q] << 8 : 0;   /* sendfx-pages: the Sidecar's P5..P16 */
  if (BW(id)) return st.ticks ? X.bw[(id - BW0) >> 1][(id - BW0) & 1] << 8 : 0;   /* (0 before the first tick zeroed X) */
  r = F_READ(set, id);
  see_fxset(set);
  if (!OURS(id)) return r;
  if (!st.ticks) return half_of(id - ID0, r);   /* before the first tick zeroed X: the stored half, no knob mapping (it reads X) */
  if (st.init) sync(set);
  return to_knob(id - ID0, half_of(id - ID0, r));
}
int32_t sfu_s_write(void *set, int32_t id, int32_t v, int32_t a, int32_t b) {
  if (OURS(id)) { st.calls++; v = merge(id - ID0, S_READ(set, id), v); }
  else if (xmode(id)) v = x_keep(id, x_half(id, v), S_READ(set, id));
  return S_WRITE(set, id, v, a, b);
}
/* FX words 38..41 have no stock storage map: the stock write's project-copy observer indexes the 38-entry
   FX reverse map with them and writes a wrong slot [measured: a stray byte in stored FX slot 0]. So their
   base is written here: the set's FX words (as F_READ reads them), the FX track's trig array (what plays
   and what 0025 reports) and the project copy's kit storage 0x816 (0025's slots, as its FX saver writes). */
#define PROJ_KIT 0x407658e5u
#define TRIG_FX  ((volatile uint16_t *)(0x8000e5b0u + 84u * 12u))
static void fx_write_hi(void *set, int32_t c, int32_t w) {
  void **obj = *(void ***)((uint8_t *)set + 20);
  volatile uint16_t *base = (volatile uint16_t *)((void *(*)(void *))((uint32_t *)*obj)[40 / 4])(obj);
  volatile uint8_t *pk = (volatile uint8_t *)(PROJ_KIT + 0x816u + 2u * (uint32_t)(c - 38));
  base[c] = (uint16_t)w;
  TRIG_FX[c] = (uint16_t)w;
  pk[0] = (uint8_t)(w >> 8);
  pk[1] = (uint8_t)w;
}
int32_t sfu_f_write(void *set, int32_t id, int32_t v, int32_t a, int32_t b) {
  int32_t pk, q = pq(id, &pk);
  if (q != -1) {   /* sendfx-pages: the host's, as BASE / WIDTH: kept here and sent (sfu_tick), never into the kit */
    v >>= 8;
    if (v < 0) v = 0;
    if (v > 127) v = 127;
    if (q >= 0 && PG.pv[pk][q] != v) { PG.pv[pk][q] = (uint8_t)v; PG.pv_tx[pk] |= (uint16_t)(1u << q); }
    return 1;
  }
  if (BW(id)) {   /* the host's: kept here and sent (sfu_tick), never into the kit */
    int32_t i = id - BW0;
    if (!st.ticks) return 1;   /* (before the first tick sfu_x is not zeroed: nothing is kept; the host's 2 s refresh says it again) */
    v >>= 8;
    if (v < 0) v = 0;
    if (v > 127) v = 127;
    if (X.bw[i >> 1][i & 1] != v) { X.bw[i >> 1][i & 1] = (uint8_t)v; X.bw_tx |= (uint8_t)(1 << (i >> 1)); }
    return 1;
  }
  if (OURS(id)) {
    int32_t i = id - ID0, c = k_cidx[i];
    int32_t raw = F_READ(set, id);
    if (!st.ticks) return 1;   /* before the first tick zeroed X: no write (to_half reads X); the host's value comes again */
    st.calls++;
    see_fxset(set);
    v = merge(i, raw, to_half(i, v, (raw >> 8) & 0x7f));
    if (ISTYPE(i)) X.cur[i >= 8] = (uint8_t)((v >> 8) & 0x7f);
    if (c >= 38) { fx_write_hi(set, c, v); return 1; }
  }
  return F_WRITE(set, id, v, a, b);
}
int32_t sfu_s_lget(void *set, int32_t id, int32_t step) {
  int32_t r;
  if (OURS(id) && KITONLY(id - ID0)) return -1;
  r = S_LGET(set, id, step);
  if (r < 0) return r;
  if (OURS(id)) return half_of(id - ID0, r);
  return xmode(id) ? x_knob(id, r) : r;
}
int32_t sfu_f_lget(void *set, int32_t id, int32_t step) {
  int32_t r, k;
  if (pq(id, &k) != -1) return -1;   /* sendfx-pages: no locks on P5..P16 */
  if (BW(id) || (OURS(id) && KITONLY(id - ID0))) return -1;
  r = F_LGET(set, id, step);
  if (!OURS(id) || r < 0) return r;
  if (!st.ticks) return half_of(id - ID0, r);   /* (as sfu_f_read: X is not zeroed yet) */
  if (st.init) sync(set);
  return to_knob(id - ID0, half_of(id - ID0, r));
}
int32_t sfu_s_lset(void *set, int32_t id, int32_t v, int32_t step) {
  if (OURS(id)) {
    int32_t cur;
    if (KITONLY(id - ID0)) return 0;
    st.calls++;
    cur = S_LGET(set, id, step);
    if (cur < 0) cur = S_READ(set, id);
    v = merge(id - ID0, cur, v);
  } else if (xmode(id)) {   /* a stepped list knob locks the stored value; rui1038: a banked one the lock's (or word's) bank */
    int32_t cur = S_LGET(set, id, step);
    v = x_keep(id, x_half(id, v), cur >= 0 ? cur : S_READ(set, id));
  }
  return S_LSET(set, id, v, step);
}
/* fxfull-refuse (0.5.2): stock's full rebuild (SAVE PROJECT, 0x40009216) stores at most 71 lock rows a pattern: per lock
   index 0..41, per track 0..12, a row when a step of the track locks the index (word >= 0 on a step whose lock count, the
   step's long at +84, is > 0), two rows with the track's fine flag for the index (+5632); a row pair that would pass 71 is
   skipped whole (0x400092a2). The FX words 38..41 come last, so a lock made on a full pattern pushed the Send FX locks
   out at the next save. Round 2 (owner, 2026-11-25): any new lock that would not be saved is refused, at stock's one
   lock-set (track_lock_set 0x400c0520, detour sfu_tls_det: the sound / FX lock-sets of every page, live record, trig
   paste, FREEZE TRACK) and before the three pastes write (sfu_tg_det, sfu_tk_det, sfu_pg_det: PASTE TRIGS / TRACK /
   PAGE, the whole paste or nothing). UNDO / RELOAD TRACK restore locks wholesale, not checked (0.5.2). A lock
   that adds no row (the step's own, another step of an index the track already locks) is set as before, found from the lock's
   own track alone. A refusal shows stock's own LOCK MEM FULL! popup (the handler stock's PatternParamLocks::updateMirror
   registers, called with ok = 0) at most every 500 ms, always from sfu_tick (UI task): a CC recorded live reaches
   track_lock_set in the MIDI task, and the popup builds a window and pushes it on the UI's view stack. The FX track's
   Send FX words 38..41 always take the fine flag (their lo half is P3 / P5): stock's pastes pass or keep 0 there and the
   save dropped the lo half. */
#define LOCK_FULL   ((void (*)(void *, int32_t))0x400acb66u)     /* stock's LOCK MEM FULL! popup (ok = 0) */
#define TG_SET_RET  0x400c3b96u                                  /* trig paste's track_lock_set call returns here */
#define ROW_CAP 71
static int32_t track_rows(const uint8_t *t, const uint8_t *f, uint32_t *m) {   /* rows of 64 steps t with flags f; m: the
                                                                                   locked indexes (0..31, 32..41) */
  int32_t s, k, n = 0;
  m[0] = m[1] = 0;
  for (s = 0; s < 64; ++s) {
    const uint8_t *p = t + 88 * s;
    if (*(const int32_t *)(p + 84) <= 0) continue;
    for (k = 0; k < 42; ++k)
      if (((const int16_t *)p)[k] >= 0) m[k >> 5] |= 1u << (k & 31);
  }
  for (k = 0; k < 42; ++k)
    if (m[k >> 5] >> (k & 31) & 1) n += 1 + (f[k] != 0);
  return n;
}
static uint8_t *pat_locks(const uint8_t *tp) {   /* the pattern's 13 tracks of locks, as track_lock_set reaches them */
  void **pool = *(void ***)(tp + 44);
  if (!pool || (uint32_t)*(const int32_t *)(tp + 64) > 12u) return 0;   /* stock refuses these itself */
  return (uint8_t *)((void *(*)(void *))((uint32_t *)*pool)[40 / 4])(pool);   /* 0: stock's set gives up too */
}
static int32_t rows_but(const uint8_t *l, int32_t trk) {   /* the other 12 tracks' rows */
  int32_t t, n = 0;
  uint32_t m[2];
  for (t = 0; t < 13; ++t)
    if (t != trk) n += track_rows(l + 5674 * t, l + 5674 * t + 5632, m);
  return n;
}
static int32_t refuse(void) {   /* any task (UI; MIDI for a CC recorded live): no UI call here, sfu_tick shows the popup */
  st.full_n++;
  if (!st.full_t) st.full_p = 1;   /* one byte store; only sfu_tick clears it and writes full_t */
  return 1;
}
#define SENDFX(trk, k) ((trk) == 12 && (uint32_t)(k) - 38u < 4u)
/* track_lock_set(track, step, index, value, fine) at its entry: a[0] the return address, a[1..5] the arguments (a[5]'s low
   byte the flag). 1: refused (the stub returns 0, as stock's own refusals). */
int32_t sfu_tls(uint32_t *a) {
  const uint8_t *tp = (const uint8_t *)a[1], *l, *t;
  int32_t trk = *(const int32_t *)(tp + 64), c = (int32_t)a[3], n, have = 0, need;
  uint32_t m[2];
  if (SENDFX(trk, c)) a[5] |= 1;
  if (a[0] == TG_SET_RET || (uint32_t)c > 41u || a[2] > 63u || (int16_t)a[4] < 0 || !(l = pat_locks(tp))) return 0;
  t = l + 5674 * trk;
  need = 1 + ((uint8_t)a[5] != 0);
  n = track_rows(t, t + 5632, m);   /* the lock's own track first: no new row, no scan of the others */
  if (m[c >> 5] >> (c & 31) & 1) have = 1 + (t[5632 + c] != 0);
  if (need <= have || n - have + need + rows_but(l, trk) <= ROW_CAP) return 0;
  return refuse();
}
/* PASTE TRIGS (0x400c396a) after its first loop: the clipboard's records (64 B: +0 the target step, +4 / +5 trig /
   trigless, +52 .. +56 the lock entries, 12 B: +0 value, +4 index, +8 flag) each clear their step and set its locks. The
   track's rows after it are counted as it will leave them; refused (1) when they pass 71 and the paste adds rows. */
int32_t sfu_tgpaste(const uint8_t *tp, const uint8_t *clip) {
  const uint8_t *l, *t, *r, *e, *r1 = *(const uint8_t **)(clip + 8);
  int32_t trk = *(const int32_t *)(tp + 64), s, k, n0, n = 0;
  uint32_t m[2], p[2] = {0, 0};
  uint8_t f[42];
  if (!(l = pat_locks(tp))) return 0;
  t = l + 5674 * trk;
  n0 = track_rows(t, t + 5632, m);
  for (r = *(const uint8_t **)(clip + 4); r != r1; r += 64)
    if ((r[4] || r[5]) && (s = *(const int32_t *)r) >= 0 && s < 64) p[s >> 5] |= 1u << (s & 31);
  m[0] = m[1] = 0;
  for (s = 0; s < 64; ++s) {
    const uint8_t *q = t + 88 * s;
    if (p[s >> 5] >> (s & 31) & 1 || *(const int32_t *)(q + 84) <= 0) continue;
    for (k = 0; k < 42; ++k)
      if (((const int16_t *)q)[k] >= 0) m[k >> 5] |= 1u << (k & 31);
  }
  for (k = 0; k < 42; ++k) f[k] = t[5632 + k];
  for (r = *(const uint8_t **)(clip + 4); r != r1; r += 64) {
    if (!r[4] && !r[5]) continue;
    for (e = *(const uint8_t **)(r + 52); e != *(const uint8_t **)(r + 56); e += 12) {
      k = *(const int32_t *)(e + 4);
      if ((uint32_t)k > 41u || *(const int32_t *)e < 0) continue;   /* lock_pool_set writes nothing for a value < 0 */
      f[k] = e[8] || SENDFX(trk, k);
      if (*(const int16_t *)(e + 2) >= 0) m[k >> 5] |= 1u << (k & 31);
    }
  }
  for (k = 0; k < 42; ++k)
    if (m[k >> 5] >> (k & 31) & 1) n += 1 + (f[k] != 0);
  if (n <= n0 || n + rows_but(l, trk) <= ROW_CAP) return 0;
  return refuse();
}
/* PASTE PAGE (0x400c3342) with the clipboard's data in hand: the clipboard's page (+6596) of 16 steps (+921, 88 B each)
   over the selected page's 16 steps of the track (it clears each, then copies the words; the flags stay). Refused (1)
   as the other pastes; else the FX track's Send FX indexes it brings get the flag. */
#define PROJECT   ((void *(*)(void))0x4017f83eu)              /* project_singleton */
#define TRK_SEL   ((void *(*)(void *))0x400ae426u)            /* track_selection */
#define SEL_PAGE  ((int32_t (*)(void *))0x400b6abeu)          /* the selection's page, as PASTE PAGE reads it */
int32_t sfu_pgpaste(const uint8_t *tp, const uint8_t *clip) {
  uint8_t *l, *t, f[42];
  int32_t trk = *(const int32_t *)(tp + 64), s, k, n0, n = 0, c = *(const int32_t *)(clip + 6596) * 16, d;
  uint32_t m[2], b[2] = {0, 0};
  if (!(l = pat_locks(tp))) return 0;
  d = SEL_PAGE(TRK_SEL(PROJECT())) * 16;
  if ((uint32_t)c > 48u || (uint32_t)d > 48u) return 0;
  t = l + 5674 * trk;
  n0 = track_rows(t, t + 5632, m);
  m[0] = m[1] = 0;
  for (s = 0; s < 64; ++s) {
    int32_t in = (uint32_t)(s - d) < 16u;
    const uint8_t *q = in ? clip + 921 + 88 * (c + s - d) : t + 88 * s;
    if (*(const int32_t *)(q + 84) <= 0) continue;
    for (k = 0; k < 42; ++k)
      if (((const int16_t *)q)[k] >= 0) { m[k >> 5] |= 1u << (k & 31); if (in) b[k >> 5] |= 1u << (k & 31); }
  }
  for (k = 0; k < 42; ++k) {
    f[k] = t[5632 + k] || (SENDFX(trk, k) && b[k >> 5] >> (k & 31) & 1);
    if (m[k >> 5] >> (k & 31) & 1) n += 1 + (f[k] != 0);
  }
  if (n > n0 && n + rows_but(l, trk) > ROW_CAP) return refuse();
  for (k = 38; k < 42; ++k) t[5632 + k] = f[k];
  return 0;
}
/* Track paste (0x400c4754) with the clipboard's data in hand (+921: 64 steps x 88 B, which it copies over the track; the
   track's fine flags stay). Refused (1) as the trig paste; else the FX track's Send FX indexes it brings get the flag. */
int32_t sfu_tkpaste(const uint8_t *tp, const uint8_t *clip) {
  uint8_t *l, *t, f[42];
  int32_t trk = *(const int32_t *)(tp + 64), k, n0, n = 0;
  uint32_t m[2];
  if (!(l = pat_locks(tp))) return 0;
  t = l + 5674 * trk;
  n0 = track_rows(t, t + 5632, m);
  track_rows(clip + 921, t + 5632, m);
  for (k = 0; k < 42; ++k) {
    f[k] = t[5632 + k] || (SENDFX(trk, k) && m[k >> 5] >> (k & 31) & 1);
    if (m[k >> 5] >> (k & 31) & 1) n += 1 + (f[k] != 0);
  }
  if (n > n0 && n + rows_but(l, trk) > ROW_CAP) return refuse();
  for (k = 38; k < 42; ++k) t[5632 + k] = f[k];
  return 0;
}
int32_t sfu_f_lset(void *set, int32_t id, int32_t v, int32_t step) {
  int32_t k;
  if (pq(id, &k) != -1) return 0;
  if (BW(id)) return 0;
  if (OURS(id)) {
    int32_t cur;
    if (KITONLY(id - ID0) || !st.ticks) return 0;   /* (no lock before the first tick zeroed X: to_half reads it) */
    st.calls++;
    cur = F_LGET(set, id, step);
    if (cur < 0) cur = F_READ(set, id);
    v = merge(id - ID0, cur, to_half(id - ID0, v, 0));   /* a stepped P2..P5 locks the zone's lo */
  }
  return F_LSET(set, id, v, step);
}

/* page_get_value for our ids (the gate below): the set's value, a step's lock first */
int32_t sfu_get(void **view, int32_t id, int32_t lock) {
  void **set = ((void **(*)(void *, int32_t))((uint32_t *)*view)[160 / 4])(view, -1);
  uint32_t *vt = (uint32_t *)*set;
  int32_t v = -1, k;
  if (st.ticks && slot_of(id, &k) >= 0) { PG.fxview = view; PG.fxvt = *(uint32_t *)view; }   /* sendfx-pages: the SEND FX page's view */
  if (lock >= 0) v = ((lg_fn)vt[0x3c / 4])(set, id, lock);
  if (v < 0) v = ((rd_fn)vt[0x28 / 4])(set, id);
  return v;
}

/* TYPE's value text: the name, !NAME when the Sidecar reported that id missing for that FX */
int32_t sfu_type_text(void *functor, int32_t value, void *str);
static int32_t type_text(int32_t fx, int32_t value, void *str) {
  int32_t i = tid(fx, X.cur[fx], value >> 8);   /* the knob's value is the list position */
  const char *n;
  if (i < 0) i = 0;
  if (i > 127) i = 127;
  n = st.name[i];
  if (!n[0]) return STR_PRINTF(str, fmt_d, i < 64 ? s_fx : s_ufx, i < 64 ? i : i - 63);
  return STR_PRINTF(str, st.miss_id[fx] == i ? fmt_bang : fmt_s, n);
}
int32_t sfu_type1_text(void *functor, int32_t value, void *str) { (void)functor; return type_text(0, value, str); }
int32_t sfu_type2_text(void *functor, int32_t value, void *str) { (void)functor; return type_text(1, value, str); }

/* P1 = ROUTE on every TYPE (rytm-teensy core/fx/send_fx.h, hardware-measured 2026-10-16): 0..63 PRE (Overbridge OUT
   3-4, before the analog distortion / compressor), 64..127 POST (OUT 1-2). Static: no message. */
int32_t sfu_route_text(void *functor, int32_t value, void *str) {
  (void)functor;
  return STR_PRINTF(str, fmt_s, (value >> 8) ? s_post : s_pre);   /* the knob's value: 0 PRE, 1 POST */
}

static const struct sfu_lab *lab_of(int32_t t) {
  int32_t k;
  for (k = 0; k < NLT; ++k)
    if (X.lab[k].idp1 == t + 1) return &X.lab[k];
  return 0;
}

/* P2..P5's value text: the zone's name (with show: and v - lo + base, a space when 7 characters allow it) for the
   TYPE's labels; a knob without zones, or a TYPE without labels, the plain dial's number. */
static int32_t ptext(int32_t fx, int32_t j, void *functor, int32_t value, void *str) {
  const struct sfu_lab *e = lab_of(X.shown[fx]);
  int32_t v = value >> 8, k, hit = -1, n = X.kn[fx][j];
  if (v < 0) v = 0;
  if (n) v = X.klo[fx][j][v < n ? v : n - 1];   /* a stepped knob's value is the step: its zone's lo */
  if (v > 127) v = 127;
  if (e)
    for (k = 0; k < e->nz && k < NZ; ++k)
      if ((e->z[k].kf & 3) == j && e->z[k].lo <= v) hit = k;
  if (hit >= 0) {
    const struct sfu_zone *z = &e->z[hit];
    int32_t n = v - z->lo + z->base, len = 0, dg = n >= 100 ? 3 : n >= 10 ? 2 : 1;
    if (!(z->kf & 4)) return STR_PRINTF(str, fmt_s, z->name);
    while (len < 5 && z->name[len]) ++len;
    return STR_PRINTF(str, len + 1 + dg <= 7 ? fmt_sn : fmt_n, z->name, n);
  }
  if (X.dial) return X.dial(functor, value, str);
  return STR_PRINTF(str, fmt_d, s_empty, v);
}
#define PT(f, j) int32_t sfu_p##f##j##_text(void *fn, int32_t v, void *s) { \
    uint32_t t0 = TIMER; int32_t r = ptext(f, j, fn, v, s); timed(t0, 0); return r; }
PT(0, 0) PT(0, 1) PT(0, 2) PT(0, 3) PT(1, 0) PT(1, 1) PT(1, 2) PT(1, 3)
static int32_t (*const ptexts[2][4])(void *, int32_t, void *) = {
  {sfu_p00_text, sfu_p01_text, sfu_p02_text, sfu_p03_text}, {sfu_p10_text, sfu_p11_text, sfu_p12_text, sfu_p13_text}};

/* 24 SENDFX LABELS: F0 7D 52 54 24 01 <id> <label 4> x 4 {<knob | show << 2> <lo> <base> <name 5>} F7 (MIDI task) */
static void take_labels(const uint8_t *d, int32_t len) {
  int32_t k, j, nz, id = d[6];
  struct sfu_lab *e = 0;
  if (len < 24 || (len - 24) % 8 || id > 127) { X.lab_drop++; return; }
  for (k = 0; k < NLT && !e; ++k)
    if (X.lab[k].idp1 == id + 1) e = &X.lab[k];
  for (k = 0; k < NLT && !e; ++k)
    if (!X.lab[k].idp1) e = &X.lab[k];
  if (!e) { X.lab_drop++; return; }     /* the table is full: that TYPE keeps P2..P5 generic */
  if (!e->idp1) {                       /* a new TYPE in the table: its 51 follows (an older Sidecar sends none) */
    X.lng_ok &= (uint16_t)~(1u << (e - X.lab));
    PG.np[e - X.lab] = 0;               /* (sendfx-pages: and the 51s say how many P it has. A 24 sent again for a TYPE */
  }                                     /* the table has keeps them, and the page the user is on: the 51s follow it) */
  /* (an entry in use stays visible while it is rewritten: hiding it let a relabel in that window see "no labels" and put a
     paged FX back on page 1. The copies are bounded by the sizes and the gen bump below makes the next tick redo them) */
  for (j = 0; j < 4; ++j) {
    for (k = 0; k < 4; ++k) {
      uint8_t c = d[7 + 4 * j + k];
      if (c < 0x20 || c > 0x7e) break;
      e->lab[j][k] = (char)c;
    }
    e->lab[j][k] = 0;
  }
  nz = (len - 24) / 8;
  if (nz > NZ) nz = NZ;
  for (j = 0; j < nz; ++j) {
    const uint8_t *z = d + 23 + 8 * j;
    e->z[j].kf = z[0] & 15;   /* knob | show << 2 | step << 3 (sfx-enum-knobs; an older Sidecar sends no step) */
    e->z[j].lo = z[1] & 0x7f;
    e->z[j].base = z[2] & 0x7f;
    for (k = 0; k < 5; ++k) {
      uint8_t c = z[3 + k];
      if (c < 0x20 || c > 0x7e) break;
      e->z[j].name[k] = (char)c;
    }
    e->z[j].name[k] = 0;
  }
  e->nz = (uint8_t)nz;
  e->idp1 = (uint8_t)(id + 1);
  X.lab_rx++;
  X.gen++;
}

/* 51 SENDFX FULL NAMES: F0 7D 52 54 51 01 <id> <first p 1..16> <n 1..4> {<short 4> <long 16>} x n F7 (MIDI task), sent
   by the host right after the TYPE's 24. P2..P5 are the effect's P1..P4 (first p 1); P5..P16 (sendfx-pages, first p 5, 9,
   13) are pages 2 / 3's, short names too, and the highest P named is the page count's. The TYPE's 24 must have come first
   (its entry holds the names). */
static void take_names(const uint8_t *d, int32_t len) {
  int32_t k, j, c, id = d[6], p0 = d[7], n = d[8];
  struct sfu_lab *e = 0;
  if (len < 10 || id > 127 || p0 < 1 || p0 > 16 || n < 1 || n > 4 || len < 9 + 20 * n + 1) { X.lng_drop++; return; }   /* (p0 > 16: past P16, no name to keep) */
  for (k = 0; k < NLT && !e; ++k)
    if (X.lab[k].idp1 == id + 1) e = &X.lab[k];
  if (!e) { X.lng_drop++; return; }
  k = e - X.lab;
  X.lng_ok &= (uint16_t)~(1u << k);   /* not seen while written */
  for (j = 0; j < n; ++j) {
    int32_t q = p0 - 1 + j;           /* the effect's P(q + 1) = the Rytm's P(q + 2) */
    const uint8_t *src = d + 9 + 20 * j + 4;
    char *L;
    if (q > 15) break;
    L = q < 4 ? X.lng[k][q] : PG.xlng[k][q - 4];
    for (c = 0; c < LNG; ++c) {
      uint8_t ch = src[c];
      if (ch < 0x20 || ch > 0x7e) break;
      L[c] = (char)ch;
    }
    while (c > 0 && L[c - 1] == ' ') --c;
    L[c] = 0;
    if (q >= 4) {                     /* sendfx-pages: P5..P16's short name too (the 24 has P2..P5's only) */
      for (c = 0; c < 4; ++c) {
        uint8_t ch = src[c - 4];
        if (ch < 0x20 || ch > 0x7e) break;
        PG.xsh[k][q - 4][c] = (char)ch;
      }
      PG.xsh[k][q - 4][c] = 0;
    }
    if (q + 1 > PG.np[k]) PG.np[k] = (uint8_t)(q + 1);
  }
  X.lng_ok |= (uint16_t)(1u << k);
  X.lng_rx++;
  X.gen++;
}

/* 21 NAMES / 22 STATE from the host (0022's router, through the mailbox) */
static int32_t sysex_body(const uint8_t *d, int32_t len);
int32_t sfu_sysex(const uint8_t *d, int32_t len) {
  uint32_t t0 = TIMER;
  int32_t r = sysex_body(d, len);
  timed(t0, 1);
  return r;
}
static int32_t sysex_body(const uint8_t *d, int32_t len) {
  /* sendfx-pages: 22 ver 3 <fx> <first p 5..16> <n 1..12> <values>: the host's P5..P16 of FX d[6] (a turn not sent yet, or
     sent within BW_HOLD, wins: as BASE / WIDTH) */
  if (len >= 11 && d[4] == 0x22 && d[5] == 3 && d[6] < 2 && d[7] >= 5 && d[8] >= 1 && d[7] + d[8] <= 17 && len >= 10 + d[8]) {
    int32_t k = d[6], j, ch = 0;
    if (!PG.pv_tx[k] && !(PG.pv_hold[k] && TIMER - PG.pv_hold[k] < BW_HOLD))
      for (j = 0; j < d[8]; ++j) {
        uint8_t v = d[9 + j] & 0x7f;
        if (PG.pv[k][d[7] - 5 + j] != v) PG.pv[k][d[7] - 5 + j] = v, ch = 1;
      }
    if (ch) PG.pv_rx = 1;
    PG.pv_got++;
    return 1;
  }
  if (len >= 10 && d[4] == 0x22 && d[5] == 2 && d[6] < 2) {   /* sfx-basewidth: the host's BASE / WIDTH of FX d[6] */
    /* (a turn not sent yet wins: the host takes it next; one sent just now too: this value crossed it) */
    if (!(X.bw_tx >> d[6] & 1) && !(X.bw_hold[d[6]] && TIMER - X.bw_hold[d[6]] < BW_HOLD) &&
        (X.bw[d[6]][0] != (d[7] & 0x7f) || X.bw[d[6]][1] != (d[8] & 0x7f))) {
      X.bw[d[6]][0] = d[7] & 0x7f;
      X.bw[d[6]][1] = d[8] & 0x7f;
      X.bw_rx = 1;   /* (only a change redraws: the host says both again every 2 s) */
    }
    X.bw_got++;
    return 1;
  }
  if (len < 8 || d[5] != 1) return 1;
  if (d[4] == 0x21) {
    int32_t k, j;
    X.ogen++;     /* odd: the UI task leaves order alone */
    if (d[6]) {   /* replace: forget the old list, keep the built-in defaults' ids unnamed until sent */
      X.order[0] = 0;
      X.norder = 1;
      for (k = 0; k < 128; ++k) st.name[k][0] = 0;
      for (k = 0; k < NLT; ++k) X.lab[k].idp1 = 0;   /* and the labels: the 24s follow the 21s */
      X.gen++;
      st.name[0][0] = 'O'; st.name[0][1] = 'F'; st.name[0][2] = 'F'; st.name[0][3] = 0;
    }
    for (k = 8; k + 14 <= len - 1; k += 14) {
      uint8_t id = d[k];
      if (id > 127) continue;
      for (j = 0; j < 7; ++j) {
        uint8_t c = d[k + 1 + j];
        st.name[id][j] = (c >= 0x20 && c <= 0x7e) ? (char)c : 0;
        if (!c) break;
      }
      st.name[id][7] = 0;
      for (j = 0; j < (int32_t)X.norder && X.order[j] != id; ++j) {}
      if (j == (int32_t)X.norder && X.norder < 128) X.order[X.norder++] = id;   /* TYPE steps in list order */
    }
    X.list_rx++;
    X.ogen++;
    st.asked = 2;
  } else if (d[4] == 0x24) {
    take_labels(d, len);
  } else if (d[4] == 0x51) {
    take_names(d, len);
  } else if (d[4] == 0x22 && len >= 9 && d[6] < 2) {
    uint8_t id = d[7];
    st.miss_id[d[6]] = d[8] == 3 ? id : 0xff;
    /* a MISSING id the list does not name (a reserved built-in the Sidecar lacks, an empty user slot): its name
       from the 22 (10 bytes from d[9]), so the knob shows !NAME, not FX<n> [rytm-teensy sim/sendfx_e2e.py names] */
    if (d[8] == 3 && id < 128 && !st.name[id][0]) {
      int32_t j;
      for (j = 0; j < 7 && 9 + j < len - 1; ++j) {
        uint8_t c = d[9 + j];
        if (c < 0x20 || c > 0x7e) break;
        st.name[id][j] = (char)c;
      }
      st.name[id][j] = 0;
    }
  }
  return 1;
}

static void set_rec(int32_t i) {
  uint32_t *r = REC(ID0 + i);
  int32_t fx = i >= 2 ? (i - 2) / 6 : -1;
  r[0] = fx < 0 ? 0x35 : fx == 0 ? 0x39 : 0x38;   /* kind: AMP / DELAY / REVERB group (>= 53: set) */
  r[1] = k_cidx[i];
  r[2] = 0;                                       /* min */
  r[3] = 0x7f00;                                  /* max */
  r[5] = 1;                                       /* fine: locks keep the lo half (0x400071a6) */
  r[4] = 0;                                       /* default */
  r[6] = 0xffffffffu;                             /* no CC */
  r[7] = 0xffffffffu;                             /* no NRPN */
  r[9] = 0;                                       /* modflags: none */
  if (fx < 0) {
    r[10] = (uint32_t)(i ? l_sfx2 : l_sfx1);
    r[12] = (uint32_t)(i ? s_sfx2 : s_sfx1);
  } else {
    int32_t p = (i - 2) % 6;
    r[10] = (uint32_t)(fx ? l_fx2 : l_fx1);
    r[12] = (uint32_t)(p == 0 ? s_type : p == 1 ? s_route : X.lbl[fx][p - 2]);
  }
  r[11] = (uint32_t)s_empty;
}

/* sfx-basewidth: record BW0 + j (FX j >> 1; BASE j even, WIDTH odd), a plain dial 0..127 in the DELAY / REVERB group.
   The container index (FX 29 / 0, the kit-only TYPE words) is never used: the FX set's wrappers answer these ids. */
static void set_bw_rec(int32_t j) {
  uint32_t *r = REC(BW0 + j);
  r[0] = j < 2 ? 0x39 : 0x38;
  r[1] = j < 2 ? 29 : 0;
  r[2] = 0;
  r[3] = 0x7f00;
  r[4] = j & 1 ? 0x7f00 : 0;   /* the default: BASE 0, WID 127 (the filter off) */
  r[5] = 0;
  r[6] = 0xffffffffu;
  r[7] = 0xffffffffu;
  r[9] = 0;
  r[10] = (uint32_t)(j < 2 ? l_fx1 : l_fx2);
  r[11] = (uint32_t)s_empty;
  r[12] = (uint32_t)(j & 1 ? s_wid : s_base);
}

static void copy_desc(int32_t to, int32_t from) {
  uint32_t *d = DESC(to), *s = DESC(from);
  int32_t i;
  for (i = 0; i < 21; ++i) d[i] = s[i];
}

static int32_t usb_free(int32_t n) {
  const volatile uint32_t *h = USB_POOL;
  while (n-- > 0) {
    if (!h) return 0;
    h = (const volatile uint32_t *)h[13];
  }
  return 1;
}

/* 1 sent; 0 not now (the port, the mutex, the ring or the request pool): the caller tries again next tick */
static int32_t try_send(const uint8_t *m, int32_t n) {
  if (PORT_STATE != 1) return 0;
  if (!MUTEX_TRY(MIDI_MUTEX)) { X.tx_busy++; return 0; }
  if (TX_LEVEL + 64 > 4091 || !usb_free(4)) {
    MUTEX_GIVE(MIDI_MUTEX);
    X.tx_busy++;
    return 0;
  }
  MIDI_SEND(n, m);
  MUTEX_GIVE(MIDI_MUTEX);
  return 1;
}

static int32_t send_ask(void) {
  static const uint8_t m[7] = {0xf0, 0x7d, 0x52, 0x54, 0x23, 0x01, 0xf7};
  if (!try_send(m, 7)) return 0;
  X.asks++;
  return 1;
}

/* P2..P5's labels for FX k's TYPE: the 24's, else P2..P5 */
/* A record's look: 0 the plain dial (range 0..0x7f00), 1 a text enum (FILTER TYPE's range form and encoder profile,
   the step's text drawn in place of the dial, as DISTORTION's PRE / POST), 2 the OFF / ON switch (SAMPLE LOOP's),
   3 PRE / POST (DISTORTION DEL's text draw). n: the steps. Descriptor words: 0 flags, 1 / 2 the step per count
   (normal / pushed), 4 the encoder profile, 12 the draw invoker (+0x30; functor = descriptor + 0x24). */
int32_t sfu_draw(void *functor, int32_t value, int32_t x, int32_t y, int32_t h, int32_t one);
static void set_look(int32_t i, int32_t look, int32_t n) {
  uint32_t *d = DESC(ID0 + i);
  const uint32_t *f = DESC(look ? REC_FTYP : REC_DIAL);
  REC(ID0 + i)[3] = look ? (uint32_t)((n > 1 ? n - 1 : 1) << 8) : 0x7f00u;
  if (X.look[i] == look) return;
  d[0] = f[0];
  d[1] = f[1];
  d[2] = f[2];
  d[4] = f[4];
  d[12] = look == 0 ? DESC(REC_DIAL)[12] : look == 2 ? DESC(REC_LOOP)[12] : look == 3 ? DESC(REC_DROUT)[12]
                                                                                    : (uint32_t)sfu_draw;
  X.look[i] = (uint8_t)look;
}
static int32_t is_offon(const struct sfu_lab *e, int32_t j) {
  int32_t k, m = 0;
  for (k = 0; k < e->nz && k < NZ; ++k)
    if ((e->z[k].kf & 3) == j) {
      const char *n = e->z[k].name, *w = m ? "ON" : "OFF";
      while (*w && *n == *w) { n++; w++; }
      if (*w || *n || ++m > 2) return 0;
    }
  return m == 2;
}
/* sendfx-pages: FX k's records back to TYPE P1 P2..P5 BASE WID (page 1); relabel() then gives P2..P5 their TYPE's
   labels, steps and looks, sync() TYPE's range */
static void restore_recs(int32_t k) {
  int32_t s, i;
  for (s = 0; s < 6; ++s) {
    i = 2 + 6 * k + s;
    set_rec(i);
    DESC(ID0 + i)[8] = s == 0 ? (uint32_t)(k ? sfu_type2_text : sfu_type1_text) : s == 1 ? (uint32_t)sfu_route_text
                                                                                       : (uint32_t)ptexts[k][s - 2];
  }
  set_look(2 + 6 * k, 1, 2);   /* TYPE: the text enum (its range: sync) */
  set_look(3 + 6 * k, 3, 2);   /* P1 ROUTE: PRE / POST */
  set_bw_rec(2 * k);
  set_bw_rec(2 * k + 1);
  for (s = 0; s < 8; ++s) sfu_pages[1 + k].id[s] = s < 6 ? (uint32_t)(ID0 + 2 + 6 * k + s) : (uint32_t)(BW0 + 2 * k + s - 6);
}
/* sendfx-pages: FX k's 8 records as page PG.pg[k]'s knobs (>= 1): P(5 + 8 (pg - 1) + s), plain dials 0..127, the 51's
   names (the upper left: the full name, else "Send FX n"); a knob past the effect's last is empty (id 0: the stock page
   draws and turns nothing there, as REVERB's gaps) */
static void apply_page(int32_t k) {
  const struct sfu_lab *e = lab_of(X.cur[k]);
  int32_t s, c, ei = e ? e - X.lab : -1, named = ei >= 0 && (X.lng_ok >> ei & 1);
  for (s = 0; s < 8; ++s) {
    int32_t id = s < 6 ? ID0 + 2 + 6 * k + s : BW0 + 2 * k + s - 6, q = 8 * (PG.pg[k] - 1) + s;
    uint32_t *r = REC(id);
    char *S = PG.pl_s[k][s], *L = PG.pl_l[k][s];
    S[0] = L[0] = 0;
    if (named && q < PG.nx[k]) {
      for (c = 0; c < 4 && PG.xsh[ei][q][c]; ++c) S[c] = PG.xsh[ei][q][c];
      S[c] = 0;
      for (c = 0; c < LNG && PG.xlng[ei][q][c]; ++c) L[c] = PG.xlng[ei][q][c];
      L[c] = 0;
    }
    if (q < PG.nx[k] && !S[0]) { S[0] = 'P'; S[1] = (char)('0' + (q + 5) / 10); S[2] = (char)('0' + (q + 5) % 10); S[3] = 0; }
    r[12] = (uint32_t)S;
    r[10] = (uint32_t)(L[0] ? L : k ? l_fx2 : l_fx1);
    r[3] = 0x7f00u;
    r[4] = 0;
    if (s < 6) {
      set_look(id - ID0, 0, 0);
      DESC(id)[8] = (uint32_t)X.dial;
    }
    sfu_pages[1 + k].id[s] = q < PG.nx[k] ? (uint32_t)id : 0;
  }
}
/* FX k's page count from its TYPE's 51s (the highest P named past P4), and its title */
static void page_count(int32_t k) {
  const struct sfu_lab *e = lab_of(X.cur[k]);
  int32_t ei = e ? e - X.lab : -1, np = ei >= 0 && PORT_STATE == 1 ? PG.np[ei] : 0;   /* (no pages while the port is down: the key is stock's) */
  char *t = PG.ttl[k];
  PG.nx[k] = (uint8_t)(np > 4 ? np - 4 : 0);
  PG.npg[k] = (uint8_t)(PG.nx[k] > 8 ? 3 : PG.nx[k] ? 2 : 1);
  if (PG.pg[k] && (PG.pg[k] >= PG.npg[k] || X.cur[k] != X.shown[k])) {   /* another TYPE (a kit change, a turn: not on a */
    PG.pg[k] = 0;                                                          /* page past 1) or a 21 replace: page 1 again */
    restore_recs(k);
    PG.resets++;
    PG.rt |= (uint8_t)(1u << k);   /* (the title on the glass follows, in the tick) */
  }
  if (PG.npg[k] > 1) {   /* "SEND FX 1 2/3" */
    const char *n = k ? n_fx2 : n_fx1;
    int32_t c;
    for (c = 0; n[c]; ++c) t[c] = n[c];
    t[c++] = ' ';
    t[c++] = (char)('1' + PG.pg[k]);
    t[c++] = '/';
    t[c++] = (char)('0' + PG.npg[k]);
    t[c] = 0;
    sfu_pages[1 + k].name = t;
  } else
    sfu_pages[1 + k].name = k ? n_fx2 : n_fx1;
}
/* P2..P5's labels, steps and looks for FX k's TYPE: the 24's, else P2..P5 and dials */
static void relabel(void) {
  int32_t k, j, c, z;
  for (k = 0; k < 2; ++k) page_count(k);   /* (sendfx-pages: a paged FX's P2..P5 records are its page's knobs) */
  for (k = 0; k < 2; ++k) {
    const struct sfu_lab *e = lab_of(X.cur[k]);
    for (j = 0; j < 4; ++j) {
      char *b = X.lbl[k][j];
      int32_t n = 0, step = 0;
      char *L = X.lname[k][j];
      L[0] = 0;
      if (e) {
        int32_t ei = e - X.lab;
        for (c = 0; c < 4 && e->lab[j][c]; ++c) b[c] = e->lab[j][c];
        b[c] = 0;
        if (X.lng_ok >> ei & 1)
          for (c = 0; c <= LNG; ++c)
            if (!(L[c] = X.lng[ei][j][c])) break;
        for (z = 0; z < e->nz && z < NZ; ++z)
          if ((e->z[z].kf & 3) == j) {
            step |= e->z[z].kf & 8;
            X.klo[k][j][n++] = e->z[z].lo;
          }
      } else {
        b[0] = 'P'; b[1] = (char)('2' + j); b[2] = 0;
      }
      L[LNG] = 0;
      if (!step || n < 2) n = 0;   /* no step bit (an older Sidecar): continuous */
      X.kn[k][j] = (uint8_t)n;
      if (PG.pg[k]) continue;      /* sendfx-pages: the record is page 2 / 3's knob now (apply_page below) */
      /* the upper left while turning: the effect's full name, else "Send FX n" (an older Sidecar, a built-in without) */
      REC(ID0 + 4 + 6 * k + j)[10] = (uint32_t)(L[0] ? L : k ? l_fx2 : l_fx1);
      set_look(4 + 6 * k + j, n ? (n == 2 && is_offon(e, j) ? 2 : 1) : 0, n);
    }
    X.shown[k] = X.cur[k];
    if (PG.pg[k]) apply_page(k);
  }
  X.relabels++;
}

/* The text enum's draw (look 1): the knob's value text where the dial was, as DISTORTION's PRE / POST draw does
   (text_draw(x, font, y, h - 2, 1, 0, width, "%s", text)); the record from the functor (descriptor + 0x24). */
int32_t sfu_draw(void *functor, int32_t value, int32_t x, int32_t y, int32_t h, int32_t one) {
  uint32_t t0 = TIMER, r = ((uint32_t)functor - DESC_BASE - 0x24u) / 84u;
  char b[24];
  int32_t i = (int32_t)r - ID0;
  (void)one;
  b[0] = 0;
  if (r - XR0 < NXR) xname(DESC(r) + 5, value, b);
  else if (OURS(r) && i >= 2) {
    int32_t fx = FXOF(i);
    if (ISTYPE(i)) type_text(fx, value, b);
    else if (ISP1(i)) sfu_route_text(0, value, b);
    else ptext(fx, PJ(i), 0, value, b);
  }
  b[8] = 0;
  TEXT_DRAW(x, TEXT_FONT(TEXT_CTX), y, h - 2, 1, 0, b[0] ? b : s_wide, fmt_s, b);   /* measured on itself: centred */
  timed(t0, 0);
  return 0;
}

/* ---- sendfx-pages: the keys (ev_key, before 0026's) */
#define K_SRC  0x31
#define K_SMPL 0x32
#define K_UP   0x42
#define K_FUNC 0x80
#define VT_SAMPLELED 0x40234cfcu                               /* SamplerLedView: stacked after the page (0026) */
static const uint32_t padviews[4] = {0x401e290cu, 0x401e10e4u, 0x401e2dacu, 0x401e2414u};   /* the pad modes' (0026) */
typedef const char *(*title_fn)(void *view);
typedef void (*sfc_fn)(void *s, const char *c, void *alloc);
typedef void (*uit_fn)(void *ui, void *s);
typedef void (*sdt_fn)(void *s);
#define STR_FROM_C ((sfc_fn)0x401bcd4cu)
#define UI_TITLE   ((uit_fn)0x40035fe8u)
#define STR_DTOR   ((sdt_fn)0x401bb29cu)
#define INVALIDATE ((void (*)(void *))0x40078514u)
/* 1 / 2: SEND FX 1 / 2 is the screen - the view the SEND FX knobs were read through is in the view list (ctrl + 28) before
   SamplerLedView, nothing but a pad mode's view after that (a menu, a popup, the machine list: covered; as 0026's sv_page
   walks it), and its knob A is TYPE's record (DELAY / REVERB's is not). [measured, rytm-emu 1.74: MainScreenView
   TransportView PatternGridView KeyboardView FxPageView PatternSelectionView HelpBubbleView QuickPerformanceView
   SamplerLedView on SEND FX 1; another FxPageView object on REVERB; one GlobalMenu-class view alone in GLOBAL] */
static int32_t top_page(void *ctrl) {
  const uint8_t *c = (const uint8_t *)ctrl;
  const uint32_t *n = *(const uint32_t *const *)(c + 28);
  int32_t k, j, led = 0, found = 0;
  if (!PG.fxview) return 0;
  for (k = 0; k < 16 && n && (const uint8_t *)n != c + 20; ++k) {
    const uint32_t *v = (const uint32_t *)n[2];
    if (!v) return 0;
    if (led) {
      for (j = 0; j < 4 && padviews[j] != v[0]; ++j) {}
      if (j == 4) return 0;
    } else if (v[0] == VT_SAMPLELED) led = 1;
    else if (v == (const uint32_t *)PG.fxview && v[0] == PG.fxvt) found = 1;
    n = (const uint32_t *)n[0];
  }
  if (!led || !found) return 0;
  j = ((int32_t (*)(void *, int32_t))((const uint32_t *)PG.fxvt)[0x9c / 4])(PG.fxview, 0);
  return j == ID0 + 2 ? 1 : j == ID0 + 8 ? 2 : 0;
}
/* the page's title again (sfu_title's push, as page_view_activate does: page_info(selected).name, now PG.ttl) */
static void retitle(void *view) {
  uint32_t s = 0;
  char alloc;
  const char *t = ((title_fn)((const uint32_t *)*(void **)view)[0x4c / 4])(view);
  STR_FROM_C(&s, t, &alloc);
  UI_TITLE(*(void **)((uint8_t *)view + 108), &s);
  STR_DTOR(&s);
  PG.retitles++;
}
/* FX k's six FX words as the set holds them (raw: the kit's, no lock), folded: a kit load or reload changes them, a page never does */
static uint32_t kitsig(int32_t k) {
  uint32_t h = 0;
  int32_t s;
  if (!X.fxset) return 0;
  for (s = 0; s < 6; ++s) h = h * 0x9e3779b1u + (uint32_t)F_READ(X.fxset, ID0 + 2 + 6 * k + s);
  return h;
}
static void page_set(int32_t k, int32_t p) {
  if (p < 0) p = 0;
  if (p > PG.npg[k] - 1) p = PG.npg[k] - 1;
  if (p == PG.pg[k]) return;
  if (p && !PG.pg[k]) { PG.kit[k] = ACTIVE_KIT; PG.ksig[k] = kitsig(k); }   /* (the kit this page was entered on) */
  PG.pg[k] = (uint8_t)p;
  if (!p) restore_recs(k);
  relabel();   /* (pages: apply_page; page 1: P2..P5's labels and looks again) and the title */
  if (X.fxset) sync(X.fxset);
}
/* The page key (SRC for SEND FX 1, SMPL for SEND FX 2) pressed on its own SEND FX page, for an effect with pages left: the
   next page, and the press is eaten (stock would leave the page: its page cycle; its repeats and its release are eaten
   too). On the last page, with FUNC or UP held (0026's combos), on any other page or for an effect with one page, it is
   stock's, as before (and 0026's). top_page is worked out here, not taken from the tick: the view may have changed since.
   0 stock's (and 0026's), 1 taken. */
static int32_t key_body(void *brain, void *ev) {
  uint32_t code = *(uint32_t *)((uint8_t *)ev + 12) & 0xff;
  uint32_t down = *(uint32_t *)((uint8_t *)ev + 16) & 1;
  int32_t k = code == K_SRC ? 0 : code == K_SMPL ? 1 : -1, m = code == K_FUNC ? 1 : code == K_UP ? 2 : 0;
  (void)brain;
  if (!st.init) return 0;
  if (m) { PG.mods = (uint8_t)(down ? PG.mods | m : PG.mods & ~m); return 0; }
  if (k < 0) return 0;
  if (!down) {
    PG.kdn &= (uint8_t)~(1u << k);
    if (!(PG.ate >> k & 1)) return 0;
    PG.ate &= (uint8_t)~(1u << k);
    return 1;
  }
  if (PG.kdn >> k & 1) return PG.ate >> k & 1;   /* a repeat: where its press went */
  PG.kdn |= (uint8_t)(1u << k);
  PG.ate &= (uint8_t)~(1u << k);
  /* (not while 0026's page or splash is the screen: the hidden stock page is not ours to step, the key goes on to 0026; nor
     with the port down: no pages then, SRC / SMPL are stock's) */
  if (PG.mods || PG.ovl || PORT_STATE != 1 || !PG.ctrl || PG.pg[k] + 1 >= PG.npg[k] || top_page(PG.ctrl) != k + 1) return 0;
  page_set(k, PG.pg[k] + 1);
  PG.steps++;
  PG.ate |= (uint8_t)(1u << k);
  INVALIDATE(PG.fxview);
  retitle(PG.fxview);
  return 1;
}
int32_t sfu_key(void *brain, void *ev) {
  uint32_t t0 = TIMER;
  int32_t r;
  if (!st.init) return 0;   /* (sfu_x is zeroed by the first tick: timed() writes it) */
  r = key_body(brain, ev);
  timed(t0, 0);
  return r;
}

/* ev_tick (core-ar2, the UI loop, ~20 Hz): set the records and looks up once the boot built the
   descriptors; ask the host for the TYPE list every ~5 s until it answers. */
static void tick_body(void *ctrl);
void sfu_tick(void *ctrl) {
  uint32_t t0 = TIMER, d;
  tick_body(ctrl);
  timed(t0, 0);
  if (st.full_t && TIMER - st.full_t >= BW_HOLD) st.full_t = 0;   /* fxfull-refuse: the popup's 500 ms, cleared long before DTCN0 wraps */
  if (st.full_p && !st.full_t) {   /* a refusal since the last tick: LOCK MEM FULL!, at most every 500 ms (a request that
                                      raced a show stays pending until the 500 ms are over) */
    st.full_t = TIMER | 1;
    st.full_p = 0;
    LOCK_FULL(0, 0);
  }
  /* 0021's user slots (us_live), so the slot menu - which runs no value text, so no us_tick - takes a pushed 1D and
     the new 1A while it is open; a committed 1A redraws the views. Timed apart: 0021's work, not 0029's. */
  if (st.init && XBOX[0] == 0x58535450u && XBOX[2]) {
    t0 = TIMER;
    if (((int32_t (*)(void *))XBOX[2])(ctrl)) *((volatile uint8_t *)ctrl + 0x20) = 1;
    d = TIMER - t0;
    X.lv_sum += d; X.lv_n++;
    if (d > X.lv_max) X.lv_max = d;
  }
}
static void tick_body(void *ctrl) {
  uint32_t g;
  if (!st.ticks) {   /* big-ram: the first call zeroes sfu_x and sfu_p (the registry claims must hold them: the assembler checks) */
    volatile uint32_t *z = (volatile uint32_t *)&sfu_x;
    uint32_t n;
    __asm__ volatile(".if RAM_SFU_X_SIZE < %c0\n.error \"registry buffer sfu_x is too small\"\n.endif" :: "i"((sizeof sfu_x + 3) & ~3u));
    __asm__ volatile(".if RAM_SFU_P_SIZE < %c0\n.error \"registry buffer sfu_p is too small\"\n.endif" :: "i"((sizeof sfu_p + 3) & ~3u));
    for (n = (sizeof sfu_x + 3) / 4; n; --n) *z++ = 0;   /* (m68k aligns ints to 2: the size may be 2 mod 4) */
    for (z = (volatile uint32_t *)&sfu_p, n = (sizeof sfu_p + 3) / 4; n; --n) *z++ = 0;
    __asm__ volatile("" ::: "memory");
  }
  st.ticks++;
  if (!st.init) {
    int32_t i;
    if (!DESC(REC_DIAL)[8] || !DESC(REC_DEL)[8]) return;
    for (i = 0; i < NID; ++i) {
      set_rec(i);
      copy_desc(ID0 + i, i < 2 ? REC_DEL : REC_DIAL);
    }
    for (i = 0; i < 4; ++i) {
      set_bw_rec(i);
      copy_desc(BW0 + i, REC_DIAL);
    }
    if (!X.bw_got) X.bw[0][1] = X.bw[1][1] = 127;   /* BASE 0, WIDTH 127: the filter off, until the host says */
    X.dial = (int32_t (*)(void *, int32_t, void *))DESC(REC_DIAL)[8];
    DESC(ID0 + 2)[8] = (uint32_t)sfu_type1_text;
    DESC(ID0 + 8)[8] = (uint32_t)sfu_type2_text;
    DESC(ID0 + 3)[8] = (uint32_t)sfu_route_text;
    DESC(ID0 + 9)[8] = (uint32_t)sfu_route_text;
    for (i = 0; i < 4; ++i) {
      DESC(ID0 + 4 + i)[8] = (uint32_t)ptexts[0][i];
      DESC(ID0 + 10 + i)[8] = (uint32_t)ptexts[1][i];
    }
    /* the TYPE list until the first 21: the built-in names' ids (OFF first) */
    for (i = 0; i < 128; ++i)
      if (st.name[i][0]) X.order[X.norder++] = (uint8_t)i;
    for (i = 0; i < (int32_t)X.norder; ++i) X.ulist[i] = X.order[i];
    X.un = X.norder;
    for (i = 0; i < NID; ++i) X.look[i] = 0;
    set_look(2, 1, 2);    /* TYPE: a text enum, range set by sync() */
    set_look(8, 1, 2);
    set_look(3, 3, 2);    /* P1 ROUTE: PRE / POST */
    set_look(9, 3, 2);
    relabel();
    ((volatile uint32_t *)0x401b9e54u)[1] = (uint32_t)sfu_sysex;
    ((volatile uint32_t *)0x401b9e54u)[0] = 0x53465855u;   /* 'SFXU' */
    st.init = 1;
  }
  /* the 21 list: a copy for the UI task when the MIDI task is not writing it (ogen even) and it is new */
  g = X.ogen;
  if (!(g & 1) && g != X.ugen) {
    uint32_t k, n = X.norder;
    for (k = 0; k < n && k < 128; ++k) X.ulist[k] = X.order[k];
    if (X.ogen == g && n) { X.un = n; X.ugen = g; *((volatile uint8_t *)ctrl + 0x20) = 1; }
  }
  /* FX k's TYPE as the FX set holds it (the kit, a kit load, a pattern change); the labels, steps and looks follow it
     and the 24s (sync() does the same from the knobs' reads, so a turn never sees stale steps) */
  if (X.fxset) {
    uint32_t r0 = X.relabels;
    sync(X.fxset);
    if (X.relabels != r0) *((volatile uint8_t *)ctrl + 0x20) = 1;   /* the views redraw (labels and value texts) */
  } else if (X.gen != X.shown_gen) {
    X.shown_gen = X.gen;
    relabel();
    *((volatile uint8_t *)ctrl + 0x20) = 1;
  }
  /* sendfx-pages: which SEND FX page is the screen (the key handler works it out again); a page left (another page or
     track, a menu) or the port gone puts that FX on page 1; a host value redraws; a turn goes to the host (22 ver 3,
     all of the FX's P5..), when USB lets */
  PG.ctrl = ctrl;
  PG.ontop = (uint8_t)top_page(ctrl);
  for (g = 0; g < 2; ++g)
    if (PG.pg[g] && (PG.ontop != g + 1 || PORT_STATE != 1 || ACTIVE_KIT != PG.kit[g] || kitsig(g) != PG.ksig[g])) {
      page_set(g, 0);
      PG.resets++;
      PG.rt |= (uint8_t)(1u << g);
      *((volatile uint8_t *)ctrl + 0x20) = 1;
    }
  if ((PORT_STATE == 1) != PG.up) {   /* the port went or came back: the pages are counted again (page_count: none while it is down) */
    PG.up = (uint8_t)(PORT_STATE == 1);
    relabel();
    PG.rt |= 3;
    *((volatile uint8_t *)ctrl + 0x20) = 1;
  }
  for (g = 0; g < 2; ++g)   /* a reset (here or by page_count) while that SEND FX is the screen: its title on the glass again, never "2/3" */
    if (PG.rt >> g & 1) {
      PG.rt &= (uint8_t)~(1u << g);
      if (PG.ontop == g + 1) retitle(PG.fxview);
    }
  if (PG.pv_rx) { PG.pv_rx = 0; *((volatile uint8_t *)ctrl + 0x20) = 1; }
  for (g = 0; g < 2; ++g)
    if (PG.pv_hold[g] && TIMER - PG.pv_hold[g] >= BW_HOLD) PG.pv_hold[g] = 0;
  for (g = 0; g < 2; ++g)
    if (PG.pv_tx[g] && PG.nx[g]) {
      uint8_t m[10 + NPX];
      int32_t j, n = PG.nx[g];
      m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x22; m[5] = 0x03; m[6] = (uint8_t)g; m[7] = 5;
      m[8] = (uint8_t)n;
      for (j = 0; j < n; ++j) m[9 + j] = PG.pv[g][j];
      m[9 + n] = 0xf7;
      if (!try_send(m, 10 + n)) break;
      PG.pv_tx[g] = 0;
      PG.pv_hold[g] = TIMER | 1u;
      PG.pv_sent++;
    } else PG.pv_tx[g] = 0;
  /* sfx-basewidth: a host value redraws the page; a turn goes to the host (22 ver 2), the latest per FX, when USB lets */
  if (X.bw_rx) { X.bw_rx = 0; *((volatile uint8_t *)ctrl + 0x20) = 1; }
  for (g = 0; g < 2; ++g)   /* an expired hold cleared, so DTCN0's wrap (32.5 s) cannot bring it back */
    if (X.bw_hold[g] && TIMER - X.bw_hold[g] >= BW_HOLD) X.bw_hold[g] = 0;
  for (g = 0; g < 2; ++g)
    if (X.bw_tx >> g & 1) {
      uint8_t m[10] = {0xf0, 0x7d, 0x52, 0x54, 0x22, 0x02, (uint8_t)g, X.bw[g][0], X.bw[g][1], 0xf7};
      if (!try_send(m, 10)) break;
      X.bw_tx &= (uint8_t)~(1u << g);
      X.bw_hold[g] = TIMER | 1u;
      X.bw_sent++;
    }
  if (st.asked < 2 && st.ask_div < 100) st.ask_div++;
  if (st.asked < 2 && st.ask_div >= 100 && send_ask()) st.ask_div = 0;   /* not sent: again next tick */
}

/* Gates (detours). page_info 0x400ff574: ids 12..14 are ours. page_get_value 0x40038462: our ids.
   The page key's cycle 0x4003ab94: push the new page's title (stock pushes it only on activate). */
__asm__(
    "  .text\n"
    "  .globl sfu_pinfo, sfu_getv, sfu_title\n"
    "  .align 2\n"
    "sfu_pinfo:\n"
    "  move.l 4(%sp),%d0\n"
    "  moveq #-12,%d1\n"
    "  add.l %d1,%d0\n"
    "  moveq #2,%d1\n"
    "  cmp.l %d0,%d1\n"
    "  bcs.s 1f\n"
    "  mulu.w #36,%d0\n"
    "  add.l #sfu_pages,%d0\n"
    "  rts\n"
    "1:\n"
    "  moveq #11,%d1\n"
    "  move.l 4(%sp),%d0\n"
    "  jmp 0x400ff57a\n"
    "  .align 2\n"
    "sfu_getv:\n"
    "  move.l 8(%sp),%d0\n"
    "  moveq #-14,%d1\n"
    "  add.l %d1,%d0\n"
    "  moveq #13,%d1\n"
    "  cmp.l %d0,%d1\n"
    "  bcc.w sfu_get\n"
    "  move.l 8(%sp),-(%sp)\n"
    "  jsr sfu_isext\n"
    "  addq.l #4,%sp\n"
    "  tst.l %d0\n"
    "  bne.w sfu_get\n"
    "  lea -12(%sp),%sp\n"
    "  movem.l %d2-%d3/%a2,(%sp)\n"
    "  jmp 0x4003846a\n"
    "  .align 2\n"
    "sfu_title:\n"
    "  move.l %a2,-(%sp)\n"
    "  jsr 0x40078514\n"
    "  lea -24(%sp),%sp\n"
    "  movem.l %d0-%d1/%a0-%a1,(%sp)\n"
    "  move.l %a2,-(%sp)\n"
    "  move.l (%a2),%a0\n"
    "  move.l 0x4c(%a0),%a0\n"
    "  jsr (%a0)\n"
    "  addq.l #4,%sp\n"
    "  pea 19(%sp)\n"
    "  move.l %d0,-(%sp)\n"
    "  pea 28(%sp)\n"
    "  jsr 0x401bcd4c\n"
    "  lea 12(%sp),%sp\n"
    "  pea 20(%sp)\n"
    "  move.l 108(%a2),-(%sp)\n"
    "  jsr 0x40035fe8\n"
    "  addq.l #8,%sp\n"
    "  pea 20(%sp)\n"
    "  jsr 0x401bb29c\n"
    "  addq.l #4,%sp\n"
    "  movem.l (%sp),%d0-%d1/%a0-%a1\n"
    "  lea 24(%sp),%sp\n"
    "  jmp 0x4003ab9c\n");

/* fxfull-refuse round 2 (detours). sfu_tls_det: track_lock_set's entry (its 8 B re-emitted, nothing pc-relative): sfu_tls
   sees the arguments in place (and may set the fine flag); refused, it returns 0 as stock's own refusals do. sfu_tg_det:
   PASTE TRIGS past its step loop (a2 the track, -72(%fp) the clipboard; re-emits `movea.l -72(%fp),%a0; clr.l %d2`),
   refused: the first record's copy's lock vector (-12(%fp), only freed at the normal end 0x400c3bda) freed, d2 = 0 and
   its exit (0x400c3bf6, the clipboard released). sfu_pg_det: PASTE PAGE with the clipboard's data tested (a0 = -16(%fp),
   a2 the track; re-emits `move.l 6596(%a0),%d3; movea.l %d5,%a0`), refused: its failure exit (0x400c35dc: d2 = 0, the
   clipboard and the undo copy released, no undo record). sfu_tk_det: track paste with the clipboard's data in
   hand (a2 the track, -16(%fp) the data; re-emits `movea.l (%a2),%a0; moveq #1,%d2; move.l %a2,-(%sp)`), refused: its
   failure exit (0x400c4922: d2 = 0, the clipboard and the undo copy released). The C calls keep d2-d7 / a2-a6. */
__asm__(
    "  .text\n"
    "  .globl sfu_tls_det, sfu_tg_det, sfu_tk_det, sfu_pg_det\n"
    "  .align 2\n"
    "sfu_tls_det:\n"
    "  pea (%sp)\n"
    "  jsr sfu_tls\n"
    "  addq.l #4,%sp\n"
    "  tst.l %d0\n"
    "  bne.s 1f\n"
    "  lea -12(%sp),%sp\n"
    "  movem.l %d2-%d3/%a2,(%sp)\n"
    "  jmp 0x400c0528\n"
    "1:\n"
    "  moveq #0,%d0\n"
    "  rts\n"
    "  .align 2\n"
    "sfu_tg_det:\n"
    "  move.l -72(%fp),-(%sp)\n"
    "  move.l %a2,-(%sp)\n"
    "  jsr sfu_tgpaste\n"
    "  addq.l #8,%sp\n"
    "  tst.l %d0\n"
    "  bne.s 1f\n"
    "  movea.l -72(%fp),%a0\n"
    "  clr.l %d2\n"
    "  jmp 0x400c39ea\n"
    "1:\n"
    "  pea -12(%fp)\n"
    "  jsr 0x401a0018\n"
    "  addq.l #4,%sp\n"
    "  moveq #0,%d2\n"
    "  jmp 0x400c3bf6\n"
    "  .align 2\n"
    "sfu_tk_det:\n"
    "  move.l -16(%fp),-(%sp)\n"
    "  move.l %a2,-(%sp)\n"
    "  jsr sfu_tkpaste\n"
    "  addq.l #8,%sp\n"
    "  tst.l %d0\n"
    "  bne.s 1f\n"
    "  movea.l (%a2),%a0\n"
    "  moveq #1,%d2\n"
    "  move.l %a2,-(%sp)\n"
    "  jmp 0x400c4840\n"
    "1:\n"
    "  jmp 0x400c4922\n"
    "  .align 2\n"
    "sfu_pg_det:\n"
    "  move.l %a0,-(%sp)\n"
    "  move.l %a2,-(%sp)\n"
    "  jsr sfu_pgpaste\n"
    "  addq.l #8,%sp\n"
    "  tst.l %d0\n"
    "  bne.s 1f\n"
    "  movea.l -16(%fp),%a0\n"
    "  move.l 6596(%a0),%d3\n"
    "  movea.l %d5,%a0\n"
    "  jmp 0x400c3452\n"
    "1:\n"
    "  jmp 0x400c35dc\n");
