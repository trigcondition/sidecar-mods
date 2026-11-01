/* SPDX-License-Identifier: GPL-2.0-or-later */
/* a4_report.c - the four synth tracks as Sidecar voices, reported as the Rytm's EXT engine and the Digitakt mod do
 * (docs/device-profiles.md "How to pace them"):
 *   - latest value wins: one pending snapshot a voice, overwritten by every change; no queue of changes
 *   - a parameter-only 03 at most every REPORT_GAP blocks of a voice
 *   - a trig 04 at once, with the current values
 *   - no answer per message; one voice in turn is sent again every RESEND blocks, which repairs a lost message
 *   - at most MAX_PASS messages a pass, trigs first, and one message every RATE blocks in all with a burst of CREDIT_MAX
 *   - a note's end 11 from the OS's own note-off event (a key, MIDI), or when the voice's amp has closed (the sequencer's LEN), never ahead of its trig
 * The render only reads and posts. The OS's sender runs on the mod's task. A track with no machine costs one byte test a block
 * and sends nothing. The hello: when the USB port comes up and HELLOS more times, and on while a track has a machine, so a
 * computer with no Sidecar on it sees a few short SysEx at connect and nothing after; a Sidecar that boots later resets the port
 * and is greeted again. Its answer is not read: no receive path. */
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

/* The stock words a machine's P1..P15 read: the OS's working values for voice v, 8.8, after locks and LFOs [measured: each knob
 * moved in an emulator; a4 docs]. Each entry: its address for voice 0 and the step to voice 1. */
static const struct { uint32_t at; uint8_t step; } source[A4_ON_PAGE] = {
    {0x80005B18u, 2},   /* OSC1 TUN + FIN */
    {0x80005B28u, 2},   /* OSC1 DET */
    {0x80005B48u, 4},   /* OSC1 SPD */
    {0x80005E00u, 4},   /* OSC1 PW */
    {0x80005B58u, 4},   /* OSC1 PWM */
    {0x80005B20u, 2},   /* OSC2 TUN + FIN */
    {0x80005B30u, 2},   /* OSC2 DET */
    {0x80005B4Au, 4},   /* OSC2 SPD */
    {0x80005E02u, 4},   /* OSC2 PW */
    {0x80005B5Au, 4},   /* OSC2 PWM */
    {0x80005BA8u, 2},   /* NOISE, knob B */
    {0x80005E18u, 2},   /* NOISE, knob C */
    {0x80005E38u, 2},   /* OSC 1&2, knob D */
    {0x80005E40u, 2},   /* OSC 1&2, knob E */
    {0x80005E30u, 2},   /* OSC 1&2, knob H */
};

struct a4_voice {
    uint16_t seen[A4_ON_PAGE];  /* value << 7 | fraction: as the render last read them */
    uint16_t pend[A4_ON_PAGE];  /* what goes out next */
    uint32_t sent_at, on_at;
    uint8_t note, vel, machine; /* its machine + 1, 0 none */
    uint8_t pend_trig, pend_params, pend_off, late_off, open, shut;
};
static struct a4_voice vo[A4_VOICES];
volatile uint8_t a4_machine_now[A4_VOICES];
volatile uint32_t a4_now;
static uint32_t hello_at, resend_at;
#define now a4_now
static uint8_t was_up, hellos, scan, resend_v, turn, rate_tick;
static volatile int32_t credit = CREDIT_MAX;
volatile uint32_t a4_trigs, a4_reports, a4_offs, a4_hellos, a4_deferred;    /* to look at in the emulator */

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
                x->pend_off = 1, x->open = 0, x->pend_trig = 0, x->late_off = 0, wake = 1;  /* it left a machine: its note ends */
            x->machine = (uint8_t)m;
            if (m)
                read_voice(v, x, 1);
        }
        if (!m)
            continue;
        ev = VOICE_EVENT(v);
        if (ev == 1) {
            x->note = (uint8_t)(VOICE_NOTE(v) & 0x7f);
            x->vel = VOICE_VEL(v) & 0x7f;
            x->pend_trig = 1, x->open = 1, x->late_off = 0, x->shut = 0, x->on_at = now;
            read_voice(v, x, 1);
        } else if (ev == 2 && x->open) {
            x->open = 0;
            if (x->pend_trig)
                x->late_off = 1;        /* never ahead of its own trig */
            else
                x->pend_off = 1;
        } else if (v == scan) {
            read_voice(v, x, 0);
        }
        if (x->open && ev != 1 && now - x->on_at >= GATE_MIN) {   /* its amp has closed */
            if (VOICE_VCA_L(v) >= VCA_SHUT && VOICE_VCA_R(v) >= VCA_SHUT) {
                if (++x->shut >= GATE_SHUT) {
                    x->open = 0, x->shut = 0;
                    if (x->pend_trig)
                        x->late_off = 1;
                    else
                        x->pend_off = 1;
                }
            } else {
                x->shut = 0;
            }
        }
        if (x->pend_trig || x->pend_off || (x->pend_params && now - x->sent_at >= REPORT_GAP && credit > CREDIT_FLOOR))
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
        x->pend_trig = 0, x->pend_params = 0;
        return 0;
    }
    d = &a4_machine_of[machine - 1];
    m[n++] = 0xf0; m[n++] = 0x7d; m[n++] = 0x52; m[n++] = 0x54;
    m[n++] = trig ? 0x04 : 0x03;
    m[n++] = (uint8_t)(d->flag | v);
    IRQ_OFF(sr);                                /* the snapshot whole */
    if (trig) {
        m[n++] = x->note;
        m[n++] = x->vel;
    }
    for (k = 0; k < A4_ON_PAGE; ++k) {
        m[n++] = (uint8_t)(x->pend[k] >> 7) & 0x7f;
        m[n++] = (uint8_t)x->pend[k] & 0x7f;
    }
    x->pend_params = 0;
    if (trig)
        x->pend_trig = 0;
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
            if (x->late_off)
                x->late_off = 0, x->pend_off = 1;
        } else {
            ++a4_reports;
        }
        return 1;
    }
    if (trig)
        x->pend_trig = 1;
    x->pend_params = 1;
    return 0;
}

static int report_off(uint32_t v)
{
    uint8_t m[7] = {0xf0, 0x7d, 0x52, 0x54, 0x11, (uint8_t)v, 0xf7};
    if (!send(m, sizeof m))
        return 0;
    vo[v].pend_off = 0;
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
        }
        return;
    }
    for (v = 0; v < A4_VOICES; ++v) {           /* the trigs first; a voice's note-off goes ahead of its trig: it is older */
        struct a4_voice *x = &vo[v];
        if (!x->pend_trig)
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
