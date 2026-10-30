/*
 * 0022-looper: a looper mode for an Overbridge host's master looper
 * (rytm-teensy docs/looper.md).
 *
 * TRK + REC toggles looper mode. In looper mode the 12 pads are clip slots and
 * UP/DOWN page through them (12 a page); their presses go to the host instead of
 * the Rytm, TRK held or not (TRK only matters for TRK + REC). The host
 * records and plays the clips, quantised to bars from the Rytm's MIDI clock.
 *
 * Reports, SysEx over USB MIDI (manufacturer 0x7D, rytm-teensy sim/protocol.py):
 *   F0 7D 52 54 05 <on 0/1> <page> F7        looper mode, page
 *   F0 7D 52 54 06 <slot> <down 1/0> F7      a pad: slot = page * 12 + pad
 * and from the host:
 *   F0 7D 52 54 07 <slot> <state> F7         a slot's state: 0 empty, 1 queued,
 *                                            2 recording, 3 playing, 4 stopped
 *   F0 7D 52 54 08 <on> F7                   1: keep the track mutes and mute all
 *                                            12 (a loop took over); 0: put the
 *                                            kept mutes back
 * Track mutes are a bit mask (bit t = track t) at 0x8000ed98 (the sequencer's,
 * 32-bit) and at 0x41318997 (the settings', unaligned, big-endian) [measured:
 * MUTE + BD, SD, CH gave 0x103 in both; writing 0xfff at 0x8000ed98 alone
 * silenced the pattern].
 * In looper mode the pads show their slot's state: dark, amber, red, blue, dim
 * blue (palette 0, 63, 15, 47, 43 [measured]). The firmware animates pad LEDs on
 * several paths (two colour setters, slot selectors for the glow), so the mod
 * owns them at the panel link instead: while looper mode is on it drops the
 * firmware's colour messages for the pads' LEDs (B0..B4 for hardware LEDs
 * 72..83, [measured: rytm-emu panel.rs]) through the UART8 writer 0x400019e4,
 * and their selector groups 18..20 (pads only) through the selector callback
 * (pointer 0x40287a10, stock 0x40095b48), and paints each pad with
 * B4 id c c c c (the colour in all four slots, so any selector shows it). On
 * leaving it re-sends the firmware's own cached slot colours (0x42fb6f49 +
 * 4 x logical LED; pads are logical 16..27) and last-sent selectors (0x41920534),
 * so the panel matches what the firmware believes.
 * Host SysEx is taken at the router's entry (0x40083d6c: data, len, interface;
 * the MIDI task) before stock sees it.
 */
#include <stdint.h>

#define TEXT __attribute__((section(".text")))

typedef void (*dispatch_fn)(void *ui, void *event);
typedef void (*void_fn)(void);
typedef void (*send_fn)(int32_t len, const uint8_t *data);
#define KEY_DISPATCH ((dispatch_fn)0x400a02cau)
#define MIDI_LOCK    ((void_fn)0x40002914u)
#define MIDI_UNLOCK  ((void_fn)0x40002924u)
#define MIDI_SEND    ((send_fn)0x400029e0u)

#define K_TRK   0x86
#define K_REC   0x50
#define K_UP    0x42
#define K_DOWN  0x43
#define K_PAD0  0x90
#define PAGES   8
#define SLOTS   (PAGES * 12)

typedef void (*mutex_fn)(void *m);
typedef void (*uart_fn)(int32_t len, const uint8_t *msg);
typedef void (*sel_fn)(int32_t group, int32_t value);
#define LED_LOCK    ((mutex_fn)0x400010bcu)
#define LED_UNLOCK  ((mutex_fn)0x400011eeu)
#define LED_MUTEX   ((void *)0x41920560u)
#define PANEL_SEND  ((uart_fn)0x400019e4u)
#define SEL_SEND    ((sel_fn)0x40095b48u)
#define SLOT_CACHE  ((const int8_t *)0x42fb6f49u)
#define SEL_SENT    ((const uint8_t *)0x41920534u)

struct looper_state {
  uint8_t on, page, trk_held, eat_rec_up;
  uint16_t pads_down;   /* pads whose press was taken: their release is too */
  uint8_t pad[2];
};
__attribute__((section(".lps"))) struct looper_state looper;
/* Per slot: its state from the host. */
__attribute__((section(".lps"))) uint8_t slot_state[SLOTS];
__attribute__((section(".lps"))) uint8_t mod_call, mutes_held;
__attribute__((section(".lps"))) uint32_t mutes_kept;

#define MUTES_SEQ  (*(volatile uint32_t *)0x8000ed98u)
#define MUTES_SET  ((volatile uint8_t *)0x41318997u)

#define LP2 __attribute__((section(".lp2")))
#define LP3 __attribute__((section(".lp3")))
#define LP4 __attribute__((section(".lp4")))

/* A pad's hardware LED (pad order BD..CB). */
LP2 static int pad_hw(int p) {
  return p < 4 ? 80 + p : p < 8 ? 72 + p : 64 + p;   /* BD..CP 80, BT..HT 76, CH..CB 72 */
}

/* A slot state's palette colour: dark, amber, red, blue, dim blue. */
LP2 static int32_t state_colour(uint8_t st) {
  switch (st) {
    case 1: return 63;
    case 2: return 15;
    case 3: return 47;
    case 4: return 43;
    default: return 0;
  }
}

LP2 __attribute__((noinline)) static void send6(int hw, int c0, int c1, int c2, int c3) {
  uint8_t m[6];
  m[0] = 0xb4; m[1] = (uint8_t)hw;
  m[2] = (uint8_t)c0; m[3] = (uint8_t)c1; m[4] = (uint8_t)c2; m[5] = (uint8_t)c3;
  LED_LOCK(LED_MUTEX);
  mod_call = 1;
  PANEL_SEND(6, m);
  mod_call = 0;
  LED_UNLOCK(LED_MUTEX);
}

LP2 __attribute__((noinline)) static void paint(int p) {
  int32_t c = state_colour(slot_state[looper.page * 12 + p]);
  send6(pad_hw(p), c, c, c, c);
}

LP3 __attribute__((noinline)) static void paint_all(void) {
  int p, g;
  if (looper.on) {
    for (p = 0; p < 12; ++p) paint(p);
    return;
  }
  /* Leaving: the firmware's own state back on the panel. */
  for (p = 0; p < 12; ++p) {
    const int8_t *c = SLOT_CACHE + 4 * (16 + p);
    send6(pad_hw(p), c[0], c[1], c[2], c[3]);
  }
  LED_LOCK(LED_MUTEX);
  mod_call = 1;
  for (g = 18; g <= 20; ++g) SEL_SEND(g, SEL_SENT[g]);
  mod_call = 0;
  LED_UNLOCK(LED_MUTEX);
}

/* The panel link: 1 drops a firmware message for a pad LED in looper mode. */
LP3 int looper_uart_drop(int32_t len, const uint8_t *m) {
  return looper.on && !mod_call && len >= 2 && m[0] >= 0xb0 && m[0] <= 0xb4 && m[1] >= 72 && m[1] <= 83;
}

/* The selector callback: the pads' groups wait while looper mode is on. */
LP3 void looper_sel(int32_t group, int32_t value) {
  if (looper.on && !mod_call && group >= 18 && group <= 20) return;
  SEL_SEND(group, value);
}

/* Host SysEx: 1 when taken. */
LP4 int looper_sysex(const uint8_t *d, int32_t len) {
  if (len < 7 || d[0] != 0xf0 || d[1] != 0x7d || d[2] != 0x52 || d[3] != 0x54) return 0;
  if (d[4] == 0x08) {   /* 7 bytes */
    uint32_t m;
    if (d[5] && !mutes_held) {
      mutes_kept = MUTES_SEQ;
      mutes_held = 1;
      m = 0xfff;
    } else if (!d[5] && mutes_held) {
      mutes_held = 0;
      m = mutes_kept;
    } else {
      return 1;
    }
    MUTES_SEQ = m;
    MUTES_SET[0] = (uint8_t)(m >> 24); MUTES_SET[1] = (uint8_t)(m >> 16);
    MUTES_SET[2] = (uint8_t)(m >> 8);  MUTES_SET[3] = (uint8_t)m;
    return 1;
  }
  if (d[4] == 0x0e || d[4] == 0x14) {
    /* Listings (0E) and the project's pool table (14) for 0023: its mailbox at
       a fixed address (cave23), live when the magic 'TDRV' is there. */
    volatile uint32_t *mb = (volatile uint32_t *)0x401b9a74u;
    if (mb[0] == 0x54445256u) ((int (*)(const uint8_t *, int32_t))mb[1])(d, len);
    return 1;
  }
#if LP_SLOTS   /* build param slots: 1 with 0021's user slots */
  if (d[4] >= 0x15 && d[4] <= 0x1d) {
    /* JUNO's patch sliders (15), JUNO and 6-OP FM list names (16, 17) and the user slots' 1A..1D
       (19 and 1E only go to the host) for 0021: its mailbox at a fixed address (cave12), live when
       the magic 'JUNO' is there. */
#else
  if (d[4] >= 0x15 && d[4] <= 0x17) {
    /* JUNO's patch sliders (15), JUNO and 6-OP FM list names (16, 17) for 0021: its mailbox at
       a fixed address (cave12), live when the magic 'JUNO' is there. */
#endif
    volatile uint32_t *mb = (volatile uint32_t *)0x40027a04u;
    if (mb[0] == 0x4a554e4fu) ((int (*)(const uint8_t *, int32_t))mb[1])(d, len);
    return 1;
  }
#if LP_SFX   /* build param sfx: 1 with 0029-sendfx-ui */
  if (d[4] >= 0x21 && d[4] <= 0x24 && d[4] != 0x23) {
    /* SENDFX NAMES (21), STATE (22) and LABELS (24; 23 ASK only goes to the host) for 0029: its mailbox at a fixed address (0x401b9e54, cave23's tail),
       live when the magic 'SFXU' is there (0029 writes it at its first ev_tick). */
    volatile uint32_t *mb = (volatile uint32_t *)0x401b9e54u;
    if (mb[0] == 0x53465855u) ((int (*)(const uint8_t *, int32_t))mb[1])(d, len);
    return 1;
  }
#endif
#if LP_RUI   /* build param rui: 1 with 0026-remote-ui */
  if ((d[4] >= 0x30 && d[4] <= 0x3f) || d[4] == 0x28 || d[4] == 0x2e || d[4] == 0x2f || (d[4] >= 0x46 && d[4] <= 0x48) ||
      d[4] == 0x4a) {
    /* Remote UI (38 rect, 39 commit, 3A open/close, 3C keepalive; 1030: 28 the chord write-back) for 0026: its
       mailbox at a fixed address (0x401b9e5c, cave23's tail after 0029's), live when the magic 'RUIP' is there (0026's
       first ev_tick); 1032: 2E the seq tracks, 2F the PAGE LEDs; 1033: 46 the pinned tracks' silence; 1036: 47 the source lists' names, 48 a parameter write; 1040: 4A the host's file browser over the bank list. */
    volatile uint32_t *mb = (volatile uint32_t *)0x401b9e5cu;
    if (mb[0] == 0x52554950u) ((int (*)(const uint8_t *, int32_t))mb[1])(d, len);
    return 1;
  }
#endif
#if LP_FXIN   /* build param fxin: 1 with 0030-fx-in (needs rui = 1) */
  if (d[4] == 0x26) {
    /* FX IN (26 <v>): v 1 the FX return on Overbridge IN L/R, 0 AUDIO IN, 7F ask. 0030's switch at a fixed
       address (cave23's last 6 B): the word 'FXI1' / 'FXI0', then the request count its ev_tick answers (27). */
    if (len >= 7 && (d[5] == 0 || d[5] == 1)) *(volatile uint32_t *)0x401b9e64u = 0x46584930u + d[5];
    ++*(volatile uint16_t *)0x401b9e68u;
    return 1;
  }
#endif
  if (d[4] >= 0x0a) return 1;   /* the host's other commands: not for the Rytm */
  if (d[4] == 0x07 && len >= 8 && d[5] < SLOTS) {
    slot_state[d[5]] = d[6];
    if (looper.on && d[5] / 12 == looper.page) paint(d[5] % 12);
  }
  return 1;
}

__asm__(
    "  .section .lp2,\"ax\"\n"
    "  .globl looper_uart\n"
    "looper_uart:\n"
    "  movel %sp@(8),%sp@-\n"
    "  movel %sp@(8),%sp@-\n"
    "  jsr looper_uart_drop\n"
    "  addql #8,%sp\n"
    "  tstl %d0\n"
    "  jeq 1f\n"
    "  rts\n"
    "1:\n"
    "  lea %sp@(-12),%sp\n"
    "  moveml %d2-%d4,%sp@\n"
    "  jmp 0x400019ec\n"
    "  .globl looper_router\n"
    "looper_router:\n"
    "  movel %sp@(8),%sp@-\n"
    "  movel %sp@(8),%sp@-\n"
    "  jsr looper_sysex\n"
    "  addql #8,%sp\n"
    "  tstl %d0\n"
    "  jeq 2f\n"
    "  rts\n"
    "2:\n"
    "  lea %sp@(-16),%sp\n"
    "  moveml %d2-%d3/%a2-%a3,%sp@\n"
    "  jmp 0x40083d74\n");

int looper_pad_skip(void) {
  return looper.on;
}

__asm__(
    "  .text\n"
    "  .globl looper_pad\n"
    "looper_pad:\n"
    "  jsr looper_pad_skip\n"
    "  tstl %d0\n"
    "  jeq 1f\n"
    "  moveq #1,%d0\n"
    "  rts\n"
    "1:\n"
    "  lea %sp@(-76),%sp\n"
    "  moveml %d2-%d5/%a2-%fp,%sp@\n"
    "  jmp 0x400c785c\n");

/* At least n free USB requests (free list 0x413db390, next at +52), else the
   sender waits for the host and the UI freezes (review 2026-10-09). */
static int usb_free(int n) {
  const volatile uint32_t *h = *(const volatile uint32_t *const volatile *)0x413db390u;
  while (n-- > 0) {
    if (!h) return 0;
    h = (const volatile uint32_t *)h[13];
  }
  return 1;
}

#if LP_SFX
/* sfx=1 builds (2026-10-16): never wait on USB from the UI task, as 0026-remote-ui / 0029: a try-lock of the MIDI mutex
   (0x42f67a28; 0x4000119c takes it only when free, never pends [code, 1.73]; given back with 0x400011ee, MIDI_UNLOCK's
   callee), the port configured (0x413db254 == 1) and the ring's room (0x413db258 + 64 <= 4091, where the sender would
   spin), else the report is dropped (the host re-reads the mode and page from the next 05 / 06). */
static void report(uint8_t cmd, uint8_t a, uint8_t b) {
  uint8_t m[8] = {0xf0, 0x7d, 0x52, 0x54, cmd, (uint8_t)(a & 0x7f), (uint8_t)(b & 0x7f), 0xf7};
  if (*(volatile uint32_t *)0x413db254u != 1 || !usb_free(4)) return;
  if (!((int (*)(void *))0x4000119cu)((void *)0x42f67a28u)) return;
  if (*(volatile int32_t *)0x413db258u + 64 <= 4091) MIDI_SEND(8, m);
  ((void (*)(void *))0x400011eeu)((void *)0x42f67a28u);
}
#else
static void report(uint8_t cmd, uint8_t a, uint8_t b) {
  uint8_t m[8] = {0xf0, 0x7d, 0x52, 0x54, cmd, (uint8_t)(a & 0x7f), (uint8_t)(b & 0x7f), 0xf7};
  if (!usb_free(4)) return;
  MIDI_LOCK();
  MIDI_SEND(8, m);
  MIDI_UNLOCK();
}
#endif

void looper_key(void *ui, void *event) {
  struct looper_state *s = &looper;
  uint32_t code = *(volatile uint32_t *)((uint8_t *)event + 12);
  int down = *(volatile uint32_t *)((uint8_t *)event + 16) & 1;

  if (code == K_TRK)
    s->trk_held = (uint8_t)down;
  if (code == K_REC) {
    if (down && s->trk_held) {
      s->on ^= 1;
      s->eat_rec_up = 1;
      report(0x05, s->on, s->page);
      paint_all();
      return;
    }
    if (!down && s->eat_rec_up) {
      s->eat_rec_up = 0;
      return;
    }
  }
  if (code >= K_PAD0 && code < K_PAD0 + 12) {
    uint16_t bit = (uint16_t)(1u << (code - K_PAD0));
    if (down && s->on) {
      s->pads_down |= bit;
      report(0x06, (uint8_t)(s->page * 12 + (code - K_PAD0)), 1);
      return;
    }
    if (!down && (s->pads_down & bit)) {
      s->pads_down &= (uint16_t)~bit;
      report(0x06, (uint8_t)(s->page * 12 + (code - K_PAD0)), 0);
      return;
    }
  }
  if (s->on && (code == K_UP || code == K_DOWN)) {
    if (down) {
      if (code == K_UP && s->page + 1 < PAGES) s->page++;
      if (code == K_DOWN && s->page > 0) s->page--;
      report(0x05, 1, s->page);
      paint_all();
    }
    return;
  }
  KEY_DISPATCH(ui, event);
}
