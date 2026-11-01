/* SPDX-License-Identifier: GPL-2.0-or-later */
/* a4.h - the Sidecar on an Analog Four MKII: what the mod's files share, and OS 1.56's addresses in one place. Each was read in
 * the OS 1.56 image, and the voice state and parameter words measured in an emulator (docs/A4.md). OS 1.56 only: never assume
 * they carry over. */
#ifndef A4_H
#define A4_H
#include <stdint.h>

#define A4_VOICES   4
#define A4_PARAMS   16          /* P1..P16, as the Rytm's reports */
#define A4_ON_PAGE  15          /* the stock values a machine reads; P16 is fixed per machine */
#define A4_MACHINES 6

/* A machine: what its reports say to the Sidecar (core/machines.h). */
struct a4_machine {
    const char *name;
    uint8_t flag;               /* the voice byte's machine */
    uint8_t p16;                /* P16, which no knob sets */
    uint16_t tag;               /* the sound tag: MD's page, else 0 */
};
extern const struct a4_machine a4_machine_of[A4_MACHINES];
extern volatile uint8_t a4_machine_now[A4_VOICES];      /* each track's machine + 1, 0 none */
extern volatile uint32_t a4_now;                        /* blocks since boot */

int a4_usb_up(void);                                    /* a host has the port */
int a4_usb_send(const uint8_t *m, uint32_t n);          /* 1 gone; 0 not now, nothing sent, try again */
void a4_wake(void);                                     /* the render: the task has work */
void a4_service(void);                                  /* the task */

/* Every interrupt masked, and back. */
#define IRQ_OFF(sr) __asm__ volatile ("move.w %%sr,%0\n\tmove.w #0x2700,%%sr" : "=d"(sr) :: "memory")
#define IRQ_ON(sr)  __asm__ volatile ("move.w %0,%%sr" :: "d"(sr) : "memory")

/* The USB MIDI sender (0x40003578) and what it waits on. */
#define USB_OWNER   (*(volatile uint32_t *)0x4287C6A8u)     /* its mutex (0x400034ac / bc): the owner task, 0 free */
#define USB_SYSEX   (*(volatile uint32_t *)0x4133DB48u)     /* nonzero: a SysEx half sent */
#define USB_ON      (*(volatile uint32_t *)0x4133DB58u)     /* the port's state, 1 up */
#define USB_QUEUED  (*(volatile uint32_t *)0x4133DB5Cu)     /* bytes in flight; only the completion lowers them */
#define USB_INDEX   (*(volatile uint32_t *)0x4133DB60u)     /* the ring's write index */
#define USB_POOL    (*(volatile uint32_t *volatile *)0x4133DC94u)   /* the free USB requests' head; next at + 52 B */
#define USB_EP1     (*(volatile uint32_t *)0xFC0B01C4u)     /* the controller's ENDPTCTRL1: the port is configured */
typedef void (*a4_send_fn)(int32_t len, const uint8_t *data);
#define USB_MIDI_SEND ((a4_send_fn)0x40003578u)

/* The RTOS. */
typedef int (*a4_task_create_fn)(void *task, void (*entry)(void), uint32_t prio, void *stack, uint32_t bytes);
typedef void (*a4_task_fn)(void *task);
typedef void (*a4_sem_init_fn)(void *sem, uint32_t count);
typedef void (*a4_sem_fn)(void *sem);
#define TASK_CREATE ((a4_task_create_fn)0x4000197Cu)
#define TASK_START  ((a4_task_fn)0x400019C8u)
#define SEM_INIT    ((a4_sem_init_fn)0x40001A4Cu)
#define SEM_WAIT    ((a4_sem_fn)0x40001ACEu)            /* a task only: it blocks */
#define SEM_POST    ((a4_sem_fn)0x40001B40u)            /* from an interrupt too */

/* A voice's events of this block, 76 B a voice, as the audio interrupt leaves them for its own later stages and clears them
 * at the next block's start: read in ev_render_out [measured: a note on and off by MIDI]. */
#define VOICE_EVENT(v)  (*(const volatile uint32_t *)(0x428799ACu + 76u * (v)))     /* 1 note on, 2 note off, 0 nothing */
#define VOICE_NOTE(v)   (*(const volatile uint32_t *)(0x428799B8u + 76u * (v)))
#define VOICE_VEL(v)    (*(const volatile uint8_t *)(0x428799C8u + 76u * (v)))

/* A voice's analog VCA as the control frame has it: 0x7FFF closed [measured, a4voice.rs]. The sequencer's LEN ends a note with no event of its own that
 * was found; when both words are closed nothing of the voice can be heard, so that is where a note ends for the Sidecar too. */
#define VOICE_VCA_L(v)  (*(const volatile int16_t *)(0x80003D82u + 26u * (v)))
#define VOICE_VCA_R(v)  (*(const volatile int16_t *)(0x80003D84u + 26u * (v)))

/* The selected track, through a page view, and the live kit's sounds: core-a4's own layout. */
typedef int32_t (*a4_track_fn)(void *selection);
#define VIEW_SELECTION(view) (*(void **)((char *)(view) + 116))     /* a page view's selection object */
#define SELECTION_TRACK ((a4_track_fn)0x400ADBD2u)                  /* its track, 0..3 the synth tracks */
#define KIT_INDEX       (*(const volatile uint32_t *)0x405F5CA4u)
#define KIT_SOUND(k, t) ((void *)(0x411E9936u + 0x960u * (k) + 0x1Cu + 0x152u * (t)))
#endif
