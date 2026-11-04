/* SPDX-License-Identifier: GPL-2.0-or-later */
/* a4_usb.c - into the OS's USB MIDI sender only when it cannot wait. The tests are the Digitakt mod's and the Rytm's 0025, at
 * OS 1.56's addresses (the same limits in the code: 0xFFB, 0xFBF, 0x2F). The sender waits on a counter only its completion
 * interrupt lowers, so with interrupts masked a wait would never end: the tests run inside the mask, against what it will see. */
#include "a4.h"

#define RING        0x1000u
#define RING_ROOM   0x0FFBu     /* it waits while queued + this message's USB bytes are over this */
#define NEAR_END    0x0FBFu     /* past it a long message wraps first, and waits for the ring to drain */
#define LONG_MSG    0x2Fu

int a4_usb_up(void) { return USB_ON == 1 && USB_EP1 != 0; }

/* 3 MIDI bytes a 4-byte USB packet */
static uint32_t usb_bytes(uint32_t n) { return (n + 2u) / 3u * 4u; }

static int wont_wait(uint32_t n)
{
    uint32_t q = USB_QUEUED, i = USB_INDEX, need = usb_bytes(n);
    volatile uint32_t *p;
    if (USB_OWNER != 0)                 /* a stock sender may be mid-message under us */
        return 0;
    if (!a4_usb_up() || USB_SYSEX != 0 || i >= RING)
        return 0;
    p = USB_POOL;                       /* two free requests: with none the sender sleeps on the pool */
    if (!p || !p[13])
        return 0;
    if (q > RING_ROOM || need > RING_ROOM - q)
        return 0;
    return !(n > LONG_MSG && i > NEAR_END && q + 0x3Fu >= i);
}

int a4_usb_send(const uint8_t *m, uint32_t n)
{
    uint16_t sr;
    int sent;
    IRQ_OFF(sr);
    sent = wont_wait(n);
    if (sent)
        USB_MIDI_SEND((int32_t)n, m);
    IRQ_ON(sr);
    return sent;
}
