/* SPDX-License-Identifier: GPL-2.0-or-later */
/* a4_remote.c - the Sidecar's pages on the A4's screen: the Rytm's remote UI (mods/0026-remote-ui, its messages and rules) cut to what a 128 x 64 terminal needs.
 * The way in and out: UP held, then YES, as on the Rytm, while a Sidecar answers: stock tests no held UP anywhere [read: 0x400647a2's callers], and with none answering YES is
 * stock's. UP stays stock's: on a parameter page its press is the keyboard's octave up [measured]. The way out: NO, a stock page key, 1 s with no host message, the USB port going. Nothing is saved: a power cut leaves stock's screen. Closed, a key and a turn cost one flag test and the frame one more.
 *   host -> A4  38 a tile rectangle into staging, 39 commit, 3A 0 close, 3C alive, 37 the catch mask, 36 the last frame as a splash for ticks x 50 ms, 4F the hello's answer
 *   A4 -> host  30 opened or closed, 31 a key, 32 a turn, 36 hello: never the Rytm's 35, which asks a Sidecar for /.rytm: an engine with no pages restarts on it, and drops a 36
 * The engine draws text into the frame for a box (core/ui/remote.cpp), so no font lives here. Its 34, 3D, 3E and 3F are filtered by the profile, never sent.
 * Tasks: a4_rx runs in the MIDI task (priority 7) and alone writes staging, the shadow and the mask: it copies a message's bytes and returns, it never waits, and the
 * audio interrupt never comes here. The UI task owns the rest and queues what goes out, the mod's task (14) sends it through a4_usb_send, after the trigs. Nothing here runs
 * in the render. */
#include "a4.h"

#define W 128
#define PAGES 8
#define BYTES (W * PAGES)
#define SEC        1500u        /* blocks */
#define TIMEOUT    SEC          /* the Rytm's: 1 s with no host message and stock's screen is back */
#define SPLASH_TICK 75u         /* blocks: 36's ticks, 50 ms */
#define HELLOS36   3            /* 36, 1 s apart, until the host answers */
#define MASK_E     3            /* 37: encoder bytes, then key bytes */
#define MASK_K     37
#define CAPS       1            /* 36 understood */
#define NQ         32
#define NENC       8
#define K_PAGE     0x84
#define K_UP       0x42
#define K_YES      0x44
#define UP_HELD    150u         /* blocks, 100 ms: the Rytm's UP_YES_TICKS. A menu's UP then YES rolled over stays stock's */

enum { R_USER, R_HOST, R_TIMEOUT, R_ESCAPE };

static uint8_t staging[BYTES] __attribute__((aligned(4)));
static uint8_t shadow[BYTES] __attribute__((aligned(4)));
static volatile uint32_t sh_seq, committed;             /* MIDI task: odd while it copies; frames committed */
static uint8_t mask[MASK_E + MASK_K];
static volatile uint8_t mask_valid, link_ok, host_seen, want_close, splash_new;
static volatile uint8_t splash_ticks;
static volatile uint32_t rx_at;                         /* a4_now of the last host message */
volatile uint32_t a4_rx_msgs, a4_rx_bad, a4_rui_torn, a4_rui_drop;   /* to look at in the emulator */

/* The UI task's */
static uint8_t open, shown, was_up, hellos, open_req, up_down, yes_eaten;
static uint32_t splash_until, hello_at, seen_frame, opened_frame, up_at;
static void *ui_ctrl;
static uint8_t owner[32];                               /* a key's press was the host's: its release too */
static struct { uint8_t cmd, a, b, c; } q[NQ];
static volatile uint8_t qh, qt;                         /* the UI task adds, the mod's task takes */
static volatile int8_t turned[NENC];
static uint8_t turned_func;

/* ---- the MIDI task ---- */

static void rect(const uint8_t *b, int32_t n)
{
    uint32_t c0 = b[1], p0 = b[2], nc = b[3], np = b[4], x, p, i = 0, g = 0, hi = 0;
    uint8_t *o;
    if (c0 + nc > W / 8 || p0 + np > PAGES || !nc || !np)
        return;
    b += 5, n -= 5;
    for (x = c0 * 8; x < (c0 + nc) * 8; ++x) {
        o = staging + 8 * x + p0;
        for (p = 0; p < np; ++p) {
            if (!g) {                                   /* a byte of the next seven's top bits */
                if (i >= (uint32_t)n)
                    return;
                hi = b[i++], g = 7;
            }
            if (i >= (uint32_t)n)
                return;
            *o++ = (uint8_t)(b[i++] | (hi & 1) << 7);
            hi >>= 1, --g;
        }
    }
}

static void commit(void)
{
    const uint32_t *s = (const uint32_t *)staging;
    uint32_t *o = (uint32_t *)shadow, i;
    ++sh_seq;
    for (i = 0; i < BYTES / 4; ++i)
        o[i] = s[i];
    ++sh_seq;
    ++committed;
}

/* The router's entry (a4_rx.s), every SysEx in: 1 ours, stock never sees it. A stock message costs the first compare. */
int32_t a4_rx(const uint8_t *d, int32_t len, int32_t iface)
{
    const uint8_t *b = d + 6;
    int32_t n = len - 7, i;
    if (d[1] != 0x7D)
        return 0;
    if (len < 7 || d[2] != 0x52 || d[3] != 0x54 || !(iface & 6))
        return 1;
    if (d[4] == 0x4F) {                                 /* 4F 1 <id> <status>: the hello's answer: only now the 36 goes */
        if (len >= 10 && d[6] == 0 && d[7] == 3 && d[8] == 1)
            link_ok = 1;
        return 1;
    }
    if (d[5] != 1 || d[4] < 0x36 || d[4] > 0x3C) {
        ++a4_rx_bad;
        return 1;
    }
    ++a4_rx_msgs;
    rx_at = a4_now, host_seen = 1;
    switch (d[4]) {
    case 0x38:
        if (n >= 6)
            rect(b, n);
        break;
    case 0x39:
        commit();
        break;
    case 0x3A:                                          /* <page> <on>: the host closes; an open is the user's alone */
        if (n >= 2 && !b[1])
            want_close = 1;
        break;
    case 0x36:
        if (n >= 1)
            splash_ticks = b[0], splash_new = 1;
        break;
    case 0x37:
        for (i = 0; i < MASK_E + MASK_K; ++i)
            mask[i] = i < n ? b[i] : 0;
        mask_valid = 1;
        break;
    }
    return 1;
}

/* ---- the UI task ---- */

static void put(uint32_t cmd, uint32_t a, uint32_t b, uint32_t c)
{
    uint8_t h = qh;
    if ((uint8_t)(h - qt) >= NQ) {
        ++a4_rui_drop;
        return;
    }
    q[h % NQ].cmd = (uint8_t)cmd, q[h % NQ].a = (uint8_t)a, q[h % NQ].b = (uint8_t)b, q[h % NQ].c = (uint8_t)c;
    qh = (uint8_t)(h + 1);
    a4_wake();
}

#define REDRAW() (*((uint8_t *)ui_ctrl + 0x20) = 1)     /* the view controller's dirty byte */

static void leave(uint32_t reason, int tell)
{
    open = shown = open_req = 0, mask_valid = 0, want_close = 0;
    REDRAW();                                           /* stock draws its own again */
    if (tell)
        put(0x30, 0, 0, reason);
}

static void hello(void)
{
    uint32_t up = a4_now / SPLASH_TICK;
    up = up > 16383 ? 16383 : up;
    put(0x36, up >> 7, up & 0x7F, CAPS);
    hello_at = a4_now, ++hellos;
}

/* The tick, on the UI task: enter, leave, time out, greet. */
void a4_ui_tick(void *ctrl)
{
    int up = a4_usb_up();
    uint32_t c = committed;
    ui_ctrl = ctrl;
    if (!up) {
        if (was_up) {
            was_up = 0, link_ok = 0, host_seen = 0, hellos = 0, splash_until = 0, open_req = 0;
            if (open)
                leave(R_TIMEOUT, 0);
            qt = qh;
            REDRAW();
        }
        return;
    }
    was_up = 1;
    if (link_ok && !host_seen && hellos < HELLOS36 && (!hellos || a4_now - hello_at >= SEC))
        hello();
    if (open_req && !open && host_seen) {
        open = 1, open_req = 0, shown = 0, opened_frame = c, splash_until = 0, rx_at = a4_now;
        put(0x30, 0, 1, R_USER);
    }
    if (splash_new) {
        splash_new = 0;
        splash_until = !open && splash_ticks ? a4_now + splash_ticks * SPLASH_TICK : 0;
        if (!open)                                      /* a one-frame popup: its commit may have come a tick ahead of this */
            REDRAW();
    }
    if (open && want_close)
        leave(R_HOST, 1);
    else if (open && a4_now - rx_at >= TIMEOUT) {
        if (!shown)                                     /* it never drew: a dead Pi with the port still up. The way in needs a live answer again */
            host_seen = 0, hellos = 0;
        leave(R_TIMEOUT, 1);
    }
    want_close = 0;
    if (splash_until && ((int32_t)(a4_now - splash_until) >= 0 || a4_now - rx_at >= TIMEOUT)) {
        splash_until = 0;
        REDRAW();
    }
    if (open && !shown && c != opened_frame)
        shown = 1;
    if (c != seen_frame) {
        seen_frame = c;
        if (shown || splash_until)
            REDRAW();
    }
}

/* On top of stock's frame: stock has drawn under it and keeps nothing of this. */
void a4_ui_draw(void *bmp, void *ctrl)
{
    uint32_t *px, s, i;
    (void)ctrl;
    if (!shown && !splash_until)
        return;
    px = *(uint32_t **)((uint8_t *)bmp + 16);
    s = sh_seq;
    if (s & 1) {                                        /* the next tick shows it */
        ++a4_rui_torn;
        return;
    }
    for (i = 0; i < BYTES / 4; ++i)
        px[i] = ((const uint32_t *)shadow)[i];
    if (s != sh_seq)
        ++a4_rui_torn;
}

/* The page's: the keys stock's page would change under it. */
static int leaves(uint32_t c)
{
    return (c >= 0x30 && c <= 0x38) || c == 0x24 || c == 0x25 || c == 0x83 || (c >= 0x90 && c <= 0x94) || c == 0xB0 || c == 0xB1 || c == 0xB3;
}

/* The mask names the Rytm's codes: only these mean the same on the A4 (LEFT RIGHT UP DOWN YES NO, PAGE, T1..T16, pushes A..H). */
static int taken(uint32_t c)
{
    if (!((c >= 0x40 && c <= 0x45) || c == K_PAGE || c < 16 || (c >= 0x70 && c <= 0x77)))
        return 0;
    return mask_valid ? mask[MASK_E + c / 7] >> (c % 7) & 1 : c >= 0x40 && c <= 0x45;
}

int32_t a4_ui_key(void *brain, void *ev)
{
    uint32_t c = *(uint32_t *)((uint8_t *)ev + 12), down = *(uint32_t *)((uint8_t *)ev + 16) & 1;
    (void)brain;
    if (c > 255)
        return 0;
    if (c == K_UP) {
        if (down && !up_down)                           /* a held key comes again and again */
            up_at = a4_now;
        up_down = (uint8_t)down;
    }
    if (c == K_YES && !down && yes_eaten) {
        yes_eaten = 0;
        return 1;
    }
    if (!down) {
        if (owner[c / 8] >> (c & 7) & 1) {
            owner[c / 8] &= (uint8_t)~(1u << (c & 7));
            put(0x31, c >> 7, c & 0x7F, 0);
            return 1;
        }
        return 0;
    }
    if (c == K_YES && up_down && host_seen && a4_now - up_at >= UP_HELD) {
        yes_eaten = 1;
        if (open)
            leave(R_ESCAPE, 1);
        else
            open_req = 1, splash_until = 0;
        return 1;
    }
    if (splash_until) {                                 /* it ends on a key, and the key is stock's; the host hears, its popup ends too */
        put(0x31, c >> 7, c & 0x7F, 1);
        put(0x31, c >> 7, c & 0x7F, 0);
        splash_until = 0;
        return 0;
    }
    if (!open)
        return 0;
    if (leaves(c)) {
        leave(R_ESCAPE, 1);
        return 0;
    }
    if (!taken(c))
        return 0;
    owner[c / 8] |= (uint8_t)(1u << (c & 7));
    put(0x31, c >> 7, c & 0x7F, 1);
    return 1;
}

int32_t a4_ui_enc(void *brain, void *ev)
{
    uint32_t e = *(uint32_t *)((uint8_t *)ev + 12);
    int32_t d = *(int32_t *)((uint8_t *)ev + 16), t;
    uint16_t sr;
    (void)brain;
    if (splash_until) {
        put(0x32, e & 7, 64, 0);
        splash_until = 0;
        return 0;
    }
    if (!open)
        return 0;
    if (e >= NENC)                                      /* I, J and LEVEL: no meaning on a page, nothing under the status pages */
        return mask_valid && (mask[1] & 2);
    if (mask_valid && !(mask[e / 7] >> (e % 7) & 1))    /* no meaning on this page: nothing under it either, or it turns a knob unseen */
        return 1;
    IRQ_OFF(sr);
    t = turned[e] + d;
    turned[e] = (int8_t)(t < -63 ? -63 : t > 63 ? 63 : t);
    turned_func = *((uint8_t *)ev + 20) != 0;
    IRQ_ON(sr);
    a4_wake();
    return 1;
}

/* ---- the mod's task ---- */

static int send(uint32_t cmd, uint32_t a, uint32_t b, uint32_t c)
{
    uint8_t m[10] = {0xF0, 0x7D, 0x52, 0x54, 0, 1, 0, 0, 0, 0xF7};
    m[4] = (uint8_t)cmd, m[6] = (uint8_t)a, m[7] = (uint8_t)b, m[8] = (uint8_t)c;
    return a4_usb_send(m, sizeof m);
}

void a4_remote_service(void)
{
    uint32_t e;
    uint16_t sr;
    int32_t d;
    while (qt != qh) {
        uint8_t i = qt % NQ;
        if (!send(q[i].cmd, q[i].a, q[i].b, q[i].c))
            return;
        qt = (uint8_t)(qt + 1);
    }
    for (e = 0; e < NENC; ++e) {
        if (!turned[e])
            continue;
        IRQ_OFF(sr);
        d = turned[e], turned[e] = 0;
        IRQ_ON(sr);
        if (!send(0x32, e, (uint32_t)(d + 64), turned_func)) {
            IRQ_OFF(sr);
            turned[e] = (int8_t)(turned[e] + d);
            IRQ_ON(sr);
            return;
        }
    }
}
