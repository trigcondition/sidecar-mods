/* SPDX-License-Identifier: GPL-2.0-or-later */
/* a4_report.c - the four synth tracks as Sidecar voices, reported as the Rytm's EXT engine and the Digitakt mod do
 * (docs/device-profiles.md "How to pace them"):
 *   - latest value wins: one pending snapshot a voice, overwritten by every change; no queue of changes
 *   - a parameter-only 03 at most every REPORT_GAP blocks of a voice
 *   - a trig 04 at once, with the current values; a chord is one 04 a note, in order: a sequencer chord comes as one event with all
 *     its notes, on a mono track too, a keyboard's or MIDI's one note a block, so a poly track queues them; on a mono track a new event
 *     takes the place of whatever is left of the last, latest value wins. A note preview plays no more notes than the track has voices, one a block: the OS's first note brings the
 *     others (a4_preview), so that no gap rule has to tell a preview's notes from a quick line
 *   - no answer per message; one voice in turn is sent again every RESEND blocks, which repairs a lost message
 *   - at most MAX_PASS messages a pass, trigs first, and one message every RATE blocks in all with a burst of CREDIT_MAX
 *   - a note's end 11 from the OS's own note-off event (a key, MIDI), or when the voice's amp has closed (the sequencer's LEN), never ahead of its trig;
 *     on a poly track when the last key is up, or when every analog voice the track owns has closed
 * The render only reads and posts. The OS's sender runs on the mod's task. A track with no machine costs one byte test a block
 * and sends nothing. The hello: when the USB port comes up and HELLOS more times, and on while a track has a machine, so a
 * computer with no Sidecar on it sees a few short SysEx at connect and nothing after; a Sidecar that boots later resets the port
 * and is greeted again. The reports do not read its answer: a4_rx does, for the pages' own hello (a4_remote.c). */
#include "a4.h"

#define REPORT_GAP 16u          /* blocks of 32 frames: 10.7 ms */
#define RESEND     188u         /* blocks: each of 4 voices every 0.5 s */
#define HELLO_GAP  3000u        /* blocks: 2 s */
#define HELLOS     5
#define MAX_PASS   4
#define RATE       5u           /* blocks a message: 300/s */
#define CREDIT_MAX 32
#define CREDIT_FLOOR 12         /* 4 voices x note-off, trig, a spare */
#define VCA_SHUT   0x7F00
#define GATE_MIN   32u          /* blocks after a trig before a closed amp means the note ended: its attack has started */
#define GATE_SHUT  8u           /* blocks closed in a row */
#define DEVICE_ID  3            /* core/device/a4.h */
#define CHORD      A4_CHORD
#define PREVIEW_GAP 30u         /* blocks, 20 ms: a preview's own note comes a block or two after its notes [measured] */
#define CHORD_GAP  30u          /* blocks, 20 ms: core/device/device.h kChordMs. A mono track's two events closer than it get an 11 between them, or the Sidecar would take a chord */
#define NO_NOTE    0xFFu

/* The stock words a machine's P1..P15 read: the OS's working values for voice v, 8.8, after locks and LFOs [measured: each knob
 * moved in an emulator; a4 docs]. Each entry: its address for voice 0 and the step to voice 1. */
static const struct { uint32_t at; uint8_t step; } source[A4_ON_PAGE] = {
    {0x80005B18u, 2},   /* OSC1 TUN + FIN */
    {0x80005B28u, 2},   /* OSC1 DET */
    {0x80005B48u, 4},   /* OSC1 PW */
    {0x80005E00u, 4},   /* OSC1 SPD */
    {0x80005B58u, 4},   /* OSC1 PWM */
    {0x80005B20u, 2},   /* OSC2 TUN + FIN */
    {0x80005B30u, 2},   /* OSC2 DET */
    {0x80005B4Au, 4},   /* OSC2 PW */
    {0x80005E02u, 4},   /* OSC2 SPD */
    {0x80005B5Au, 4},   /* OSC2 PWM */
    {0x80005BA8u, 2},   /* NOISE COL */
    {0x80005E18u, 2},   /* NOISE FAD */
    {0x80005E38u, 2},   /* OSC 1&2 BND */
    {0x80005E40u, 2},   /* OSC 1&2 SLI */
    {0x80005E30u, 2},   /* OSC 1&2 FAD */
};

struct a4_voice {
    uint16_t seen[A4_ON_PAGE];  /* value << 7 | fraction: as the render last read them */
    uint16_t pend[A4_ON_PAGE];  /* what goes out next */
    uint32_t sent_at, on_at;
    uint8_t note[CHORD], vel[CHORD];    /* the trigs to send, a ring: the task takes qh, the render adds at qt, each under no lock but the mask */
    uint8_t qh, qt, last, held;         /* last: the newest trig's note, NO_NOTE after a chord; held: a poly track's keys down */
    uint8_t event, took;                /* a mono track's events, and the one the task took its note from */
    uint8_t machine;            /* its machine + 1, 0 none */
    uint8_t pend_params, pend_off, late_off, open, shut;
};
static struct a4_voice vo[A4_VOICES];
static struct { uint32_t at; uint8_t n, base, note[CHORD]; } extra[A4_VOICES];  /* a note preview's notes the OS will not play: the next trig brings them, shifted as it is */
volatile uint8_t a4_machine_now[A4_VOICES];
volatile uint32_t a4_now;
static uint32_t hello_at, resend_at;
#define now a4_now
static int16_t kit_said = -1;
static uint8_t was_up, hellos, scan, resend_v, turn, rate_tick;
static volatile int32_t credit = CREDIT_MAX;
volatile uint32_t a4_trigs, a4_reports, a4_offs, a4_hellos, a4_deferred;    /* to look at in the emulator */

#define TRIGS(x) ((uint8_t)((x)->qt - (x)->qh))
#define POLY(v)  (POLY_MASK >> (v) & 1)

static void queue(struct a4_voice *x, uint32_t note, uint32_t vel)
{
    if (TRIGS(x) >= CHORD)
        ++x->qh;                                /* the oldest goes: the latest values win here too */
    x->note[x->qt & (CHORD - 1)] = (uint8_t)note;
    x->vel[x->qt & (CHORD - 1)] = (uint8_t)vel;
    x->last = (uint8_t)note;
    ++x->qt;
}

/* The amp's end of a note: a mono track's own voice. A poly track's notes sit on the voices it owns, any of which may close first. */
static int amp_shut(uint32_t v)
{
    uint32_t w;
    if (!POLY(v))
        return VOICE_VCA_L(v) >= VCA_SHUT && VOICE_VCA_R(v) >= VCA_SHUT;
    for (w = 0; w < A4_VOICES; ++w)
        if ((uint32_t)VOICE_OWNER(w) == v && (VOICE_VCA_L(w) < VCA_SHUT || VOICE_VCA_R(w) < VCA_SHUT))
            return 0;
    return 1;
}

/* The UI task, ahead of a preview: the OS plays the first notes, one for each of the track's voices. */
void a4_preview_notes(uint32_t v, const uint8_t *note, uint32_t n)
{
    uint32_t i, keep = 1, m;
    uint16_t sr;
    if (POLY(v))
        for (m = POLY_MASK & 15, keep = 0; m; m >>= 1)
            keep += m & 1;
    if (n <= keep)
        return;
    IRQ_OFF(sr);
    for (i = keep; i < n; ++i)
        extra[v].note[i - keep] = note[i];
    extra[v].base = note[0], extra[v].n = (uint8_t)(n - keep), extra[v].at = now;
    IRQ_ON(sr);
}

static void read_voice(uint32_t v, struct a4_voice *x, int trig)
{
    uint32_t k;
    int changed = 0;
    for (k = 0; k < A4_ON_PAGE; ++k) {
        int32_t w = *(const volatile int16_t *)(source[k].at + v * source[k].step);
        uint16_t p = w < 0 ? 0 : (uint16_t)(w >> 1);
        if (p != x->seen[k])
            x->seen[k] = p, changed = 1;
    }
    if (changed || trig) {
        for (k = 0; k < A4_ON_PAGE; ++k)
            x->pend[k] = x->seen[k];
        x->pend_params = 1;
    }
}

void a4_render(void)
{
    uint32_t v;
    int wake = 0;
    ++now;
    if (++rate_tick >= RATE) {
        rate_tick = 0;
        if (credit < CREDIT_MAX)
            ++credit;
    }
    for (v = 0; v < A4_VOICES; ++v) {
        struct a4_voice *x = &vo[v];
        uint32_t m = a4_machine_now[v], ev;
        if (m != x->machine) {
            if (x->machine)
                x->pend_off = 1, x->open = 0, x->qh = x->qt, x->late_off = 0, x->held = 0, wake = 1;  /* it left a machine: its note ends */
            x->machine = (uint8_t)m;
            if (m)
                read_voice(v, x, 1);
        }
        if (!m)
            continue;
        ev = VOICE_EVENT(v);
        if (ev == 1) {
            int32_t c = VOICE_COUNT(v);
            uint32_t n = c < 1 ? 1 : c > (int32_t)CHORD ? CHORD : (uint32_t)c, k, first = VOICE_NOTE(v, 0) & 0x7f, e = extra[v].n;
            extra[v].n = 0;
            if (e && now - extra[v].at >= PREVIEW_GAP)
                e = 0;
            if (!POLY(v)) {
                x->qh = x->qt, ++x->event;      /* latest value wins */
                if (x->open && (n + e > 1 || first != x->last) && now - x->on_at < CHORD_GAP)
                    x->pend_off = 1;
            }
            for (k = 0; k < n; ++k)
                if (!k || VOICE_NOTE(v, k))     /* a slot left empty on the trig reads 0 */
                    queue(x, VOICE_NOTE(v, k) & 0x7f, VOICE_VEL(v, k) & 0x7f);
            for (k = 0; k < e; ++k)
                queue(x, (extra[v].note[k] + first - extra[v].base) & 0x7f, VOICE_VEL(v, 0) & 0x7f);
            if (n + e > 1)
                x->last = NO_NOTE;      /* the next trig differs, whatever its note */
            if (x->held < CHORD)
                x->held = (uint8_t)(x->held + n > CHORD ? CHORD : x->held + n);
            x->open = 1, x->late_off = 0, x->shut = 0, x->on_at = now;
            read_voice(v, x, 1);
        } else if (ev == 2 && x->open) {
            if (!POLY(v) || x->held <= 1) { /* a chord's last key */
                x->open = 0, x->held = 0;
                if (TRIGS(x))
                    x->late_off = 1;    /* never ahead of its own trig */
                else
                    x->pend_off = 1;
            } else {
                --x->held;
            }
        } else if (v == scan) {
            read_voice(v, x, 0);
        }
        if (x->open && ev != 1 && now - x->on_at >= GATE_MIN) {   /* its amp has closed */
            if (amp_shut(v)) {
                if (++x->shut >= GATE_SHUT) {
                    x->open = 0, x->shut = 0, x->held = 0;
                    if (TRIGS(x))
                        x->late_off = 1;
                    else
                        x->pend_off = 1;
                }
            } else {
                x->shut = 0;
            }
        }
        if (TRIGS(x) || x->pend_off || (x->pend_params && now - x->sent_at >= REPORT_GAP && credit > CREDIT_FLOOR))
            wake = 1;
    }
    scan = (scan + 1) & (A4_VOICES - 1);
    if (wake)
        a4_wake();
}

static int send(const uint8_t *m, uint32_t n)
{
    if (!a4_usb_send(m, n)) {
        ++a4_deferred;
        return 0;
    }
    --credit;
    return 1;
}

static uint32_t build(uint8_t *m, uint32_t v, struct a4_voice *x, int trig)
{
    uint32_t n = 0, k, machine = x->machine;     /* once: the render may take it away under us */
    const struct a4_machine *d;
    uint16_t sr;
    if (!machine) {
        x->qh = x->qt, x->pend_params = 0;
        return 0;
    }
    d = &a4_machine_of[machine - 1];
    m[n++] = 0xf0; m[n++] = 0x7d; m[n++] = 0x52; m[n++] = 0x54;
    m[n++] = trig ? 0x04 : 0x03;
    m[n++] = (uint8_t)(d->flag | v);
    IRQ_OFF(sr);                                /* the snapshot whole */
    if (trig) {
        m[n++] = x->note[x->qh & (CHORD - 1)];
        m[n++] = x->vel[x->qh & (CHORD - 1)];
        x->took = x->event;
    }
    for (k = 0; k < A4_ON_PAGE; ++k) {
        m[n++] = (uint8_t)(x->pend[k] >> 7) & 0x7f;
        m[n++] = (uint8_t)x->pend[k] & 0x7f;
    }
    x->pend_params = 0;
    if (trig)
        ++x->qh;
    IRQ_ON(sr);
    m[n++] = d->p16;
    m[n++] = 0;
    m[n++] = (uint8_t)(d->tag >> 7) & 0x7f;
    m[n++] = (uint8_t)d->tag & 0x7f;
    m[n++] = 0xf7;
    return n;
}

static int report(uint32_t v, int trig)
{
    struct a4_voice *x = &vo[v];
    uint8_t m[8 + 2 * A4_PARAMS + 3];
    uint32_t n = build(m, v, x, trig);
    if (!n)
        return 1;                               /* it left its machine: nothing to say */
    if (send(m, n)) {
        x->sent_at = now;
        if (trig) {
            ++a4_trigs;
            if (x->late_off && !TRIGS(x))
                x->late_off = 0, x->pend_off = 1;
        } else {
            ++a4_reports;
        }
        return 1;
    }
    if (trig) {                                 /* not sent: back in front, unless newer notes took its place */
        uint16_t sr;
        IRQ_OFF(sr);
        if (TRIGS(x) < CHORD && (POLY(v) || x->took == x->event))
            --x->qh;
        IRQ_ON(sr);
    }
    x->pend_params = 1;
    return 0;
}

static int report_off(uint32_t v)
{
    uint8_t m[7] = {0xf0, 0x7d, 0x52, 0x54, 0x11, (uint8_t)v, 0xf7};
    vo[v].pend_off = 0;                         /* ahead of the send: the render may set it again meanwhile, and that off must stay */
    if (!send(m, sizeof m)) {
        vo[v].pend_off = 1;
        return 0;
    }
    ++a4_offs;
    return 1;
}

static int any_machine(void)
{
    uint32_t v;
    for (v = 0; v < A4_VOICES; ++v)
        if (vo[v].machine)
            return 1;
    return 0;
}

/* The kit in use, as the Rytm's 3B (1 <kit>, core/ui/remote.cpp), on a change and at each hello: the Sidecar's LFOs and inserts are per kit. */
static int report_kit(void)
{
    uint32_t k = KIT_INDEX;
    uint8_t m[8] = {0xf0, 0x7d, 0x52, 0x54, 0x3b, 1, (uint8_t)(k & 0x7f), 0xf7};
    if (k > 127 || !send(m, sizeof m))
        return 0;
    kit_said = (int16_t)k;
    return 1;
}

void a4_service(void)
{
    static const uint8_t hi[] = {0xf0, 0x7d, 0x52, 0x54, 0x4f, 1, DEVICE_ID >> 7, DEVICE_ID & 0x7f, 1, 'A', '4', 0xf7};
    uint32_t v, left = MAX_PASS, at = now;
    if (!a4_usb_up()) {
        was_up = 0;
        return;
    }
    if (!was_up) {
        was_up = 1, hellos = 0, hello_at = at - HELLO_GAP;
    }
    if ((hellos <= HELLOS || any_machine()) && at - hello_at >= HELLO_GAP) {
        if (send(hi, sizeof hi)) {
            hello_at = at, ++a4_hellos;
            if (hellos <= HELLOS)
                ++hellos;
            for (v = 0; v < A4_VOICES; ++v)     /* a new Sidecar has no values yet */
                if (vo[v].machine)
                    vo[v].pend_params = 1;
            kit_said = -1;
        }
        return;
    }
    if (any_machine() && kit_said != (int16_t)KIT_INDEX && credit > CREDIT_FLOOR && report_kit())
        --left;
    for (v = 0; v < A4_VOICES; ++v) {           /* the trigs first; a voice's note-off goes ahead of its trig: it is older */
        struct a4_voice *x = &vo[v];
        if (!TRIGS(x))
            continue;
        if (left < 1u + x->pend_off || credit < (int32_t)(1u + x->pend_off))
            return;
        if (x->pend_off) {
            if (!report_off(v))
                return;
            --left;
        }
        if (!report(v, 1))
            return;
        --left;
    }
    for (v = 0; v < A4_VOICES && left && credit > 0; ++v)
        if (vo[v].pend_off) {
            if (!report_off(v))
                return;
            --left;
        }
    if (at - resend_at >= RESEND) {
        resend_at = at;
        if (vo[resend_v].machine)
            vo[resend_v].pend_params = 1;
        resend_v = (resend_v + 1) & (A4_VOICES - 1);
    }
    for (v = 0; v < A4_VOICES && left && credit > CREDIT_FLOOR; ++v) {  /* then parameters, from the voice after the last one served */
        uint32_t i = (turn + v) & (A4_VOICES - 1);
        struct a4_voice *x = &vo[i];
        if (!x->machine || !x->pend_params || now - x->sent_at < REPORT_GAP)
            continue;
        if (!report(i, 0))
            return;
        turn = (uint8_t)(i + 1);
        --left;
    }
}

extern void a4_start(void);
extern void a4_machines_read(void);

void a4_tick(void *ctrl)
{
    (void)ctrl;
    a4_start();
    a4_machines_read();
    a4_wake();
}
