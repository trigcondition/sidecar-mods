/* SPDX-License-Identifier: GPL-2.0-or-later */
/* a4.h - the Sidecar on an Analog Four MKII: what the mod's files share, and OS 1.56's addresses in one place. Each was read in
 * the OS 1.56 image, and the voice state and parameter words measured in an emulator (README.md, and the Sidecar's docs/device-profiles.md). OS 1.56 only: never assume
 * they carry over. */
#ifndef A4_H
#define A4_H
#include <stdint.h>

#define A4_VOICES   4
#define A4_PARAMS   16          /* P1..P16, as the Rytm's reports */
#define A4_ON_PAGE  15          /* the stock values a machine reads; P16 is fixed per machine */
#define A4_MACHINES 11         /* PLTS..B2 and U1..U5; the sound's field is 4 bits: 0 OFF, 1..11 */
#define A4_MACHINE_BITS 15u
#define A4_CHORD    4u          /* the notes of a trig [read: four slots, 0x40101b80]: the queue, a power of two */
#define A4_LAYOUTS  4           /* which knob feeds which P: a4_src_of */
#define A4_ID_TUN   40          /* the stock ids with something special: OSC1 TUN and FIN are one word, its high and low byte; OSC2 TUN its high byte */
#define A4_ID_FIN   41
#define A4_ID_TUN2  53

/* The stock words a machine can read: a4_source, a4_src_of. */
enum { S_TUN, S_DET, S_PW, S_SPD, S_PWM, S_FIN, S_TRK, S_WAV, S_SUB, S_PM1, S_FM1, S_ACC, S_AM1, S_TUN2, S_DET2, S_PW2, S_SPD2, S_PWM2, S_TRK2, A4_SOURCES, S_NONE = 0xFF };
struct a4_source { uint32_t at; uint8_t step, id; };   /* the OS's working value for voice 0, 8.8, after locks and LFOs; the step to voice 1; the parameter id */
extern const struct a4_source a4_source[A4_SOURCES];

/* A machine: what its reports say to the Sidecar (core/machines.h). */
struct a4_machine {
    const char *name;
    uint8_t flag;               /* the voice byte's machine */
    uint8_t p16;                /* P16, which no knob sets */
    uint16_t tag;               /* the sound tag: MD's page, else 0 */
};
extern const struct a4_machine a4_machine_of[A4_MACHINES];
extern const uint8_t a4_layout_of[A4_MACHINES];                     /* its row of a4_src_of */
extern const uint8_t a4_src_of[A4_LAYOUTS * 2][A4_ON_PAGE];         /* layout x 2 + OS2: P1..P15's source */
extern const uint8_t a4_defaults[A4_MACHINES][A4_ON_PAGE];          /* a pick from OFF writes them; a P with no knob sends its own */
extern volatile uint8_t a4_machine_now[A4_VOICES];      /* each track's machine + 1, 0 none */
extern volatile uint8_t a4_os2_now[A4_VOICES];          /* its OS2, 1 MACHINE: only where it has parameters to give OSC2's page */
extern volatile uint32_t a4_now;                        /* blocks since boot */

int a4_usb_up(void);                                    /* a host has the port */
int a4_usb_send(const uint8_t *m, uint32_t n);          /* 1 gone; 0 not now, nothing sent, try again */
void a4_wake(void);                                     /* the render: the task has work */
void a4_service(void);                                  /* the task */
void a4_remote_service(void);                           /* the task, after the trigs: a4_remote.c */

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
#define VOICE_NOTE(v, k) (*(const volatile uint32_t *)(0x428799B8u + 76u * (v) + 4u * (k)))    /* a trig's notes: all of a sequencer chord are here, in the one event [measured] */
#define VOICE_VEL(v, k)  (*(const volatile uint8_t *)(0x428799C8u + 76u * (v) + 2u * (k)))
#define VOICE_COUNT(v)  (*(const volatile int32_t *)(0x428799A4u + 76u * (v)))      /* notes in the event, whatever POLY CONFIG gives the track [measured]; the OS itself plays no more than the track's voices, +0x08 [read: 0x4010249a, 0x401024b0] */
#define POLY_MASK       (*(const volatile uint32_t *)0x800047E8u)                   /* the tracks in KIT > POLY CONFIG [read: 0x401022d6; measured] */
#define VOICE_OWNER(w)  (*(const volatile int32_t *)(0x80006008u + 4u * (w)))       /* the track analog voice w last played for [read: 0x401024ea; measured] */

/* A voice's analog VCA as the control frame has it: 0x7FFF closed [measured, a4voice.rs]. The sequencer's LEN ends a note with no event of its own that
 * was found; when both words are closed nothing of the voice can be heard, so that is where a note ends for the Sidecar too. */
#define VOICE_VCA_L(v)  (*(const volatile int16_t *)(0x80003D82u + 26u * (v)))
#define VOICE_VCA_R(v)  (*(const volatile int16_t *)(0x80003D84u + 26u * (v)))

/* The selected track, through a page view, and the live kit's sounds: core-a4's own layout. */
typedef int32_t (*a4_track_fn)(void *selection);
typedef char *(*a4_model_fn)(void);
#define UI_SELECTION ((void *)(((a4_model_fn)0x401494DEu)() + 48))  /* the selection object every page view holds at +116: the UI model's [read: 0x40025274] */
#define SELECTION_TRACK ((a4_track_fn)0x400ADBD2u)                  /* its track, 0..3 the synth tracks */
#define KIT_INDEX       (*(const volatile uint32_t *)0x405F5CA4u)
#define KIT_SOUND(k, t) ((void *)(0x411E9936u + 0x960u * (k) + 0x1Cu + 0x152u * (t)))
#define PAGE_ENTRY(p) ((const int32_t *)(0x401B31E8u + 44u * (p)))  /* stock's page table: the name, then ten knob ids, 0 an empty knob */
#define SOUND_WORD(s, k) (*(volatile int16_t *)((char *)(s) + 0x14 + 2 * (k)))  /* a sound's slot k, 104 of them [read: 0x40023db6, 0x40007632 maps an id to its slot] */

/* The parameter table, 56 B an id [read]: its clamp is read on each turn (0x40025ec0, 0x400a00a6), by the MIDI task's CC path (0x4006818e, the model's set) and by no audio code: a CC on another track takes the selected track's range; and each id's knob: step, accel, text, widget, 84 B, RAM.
 * The table is image RAM: ACR0 0x4007E020 covers it with W clear, no MMU [read]. A model's set: (this, id, value, 0, 0, 0): the sound's word and the voices' [read: 0x400a0046, called at 0x40025ea2]. */
#define PARAM_SLOT(id) (*(volatile int32_t *)(0x40186AF4u + 56u * (id) + 4u))
#define PARAM_MIN(id) (*(volatile int32_t *)(0x40186AF4u + 56u * (id) + 8u))
#define PARAM_MAX(id) (*(volatile int32_t *)(0x40186AF4u + 56u * (id) + 12u))
#define KNOB_DESC(id) ((volatile uint32_t *)(0x41856C44u + 84u * (id)))
#define KNOB_WORDS  21
typedef void *(*a4_model_of_fn)(void *view, int32_t lock);
typedef void (*a4_model_set_fn)(void *model, int32_t id, int32_t value, int32_t a, int32_t b, int32_t c);
#define VIEW_MODEL(view) ((*(a4_model_of_fn *)(*(char **)(view) + 168))((view), -1))
#define MODEL_SET(model, id, value) ((*(a4_model_set_fn *)(*(char **)(model) + 48))((model), (id), (value), 0, 0, 0))

/* A trig's notes as stock's preview gets them, a deque of bytes [read: 0x400b9e16]; what is here is what it reads. */
struct a4_notes {
    void *map;
    uint32_t size;
    const int8_t *cur, *first, *last;
    int8_t *const *node;
    const int8_t *end;
};
void a4_preview_notes(uint32_t track, const uint8_t *note, uint32_t n);
#endif
