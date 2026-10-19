/*
 * 0021-ext: the EXT machine's engine. It runs the stock DISABLE engine (the
 * voice's own source stays silent; its Overbridge input plays through the voice's
 * analog chain while triggered), then reports trigs and P1..P8 to the USB host as
 * SysEx (manufacturer 0x7D, rytm-teensy sim/protocol.py):
 *
 *   F0 7D 52 54 04 <voice> <note> <velocity> <P1..P16> F7  a trig, with the
 *                                  parameters it plays with (p-locks land on it)
 *   F0 7D 52 54 03 <voice> <P1..P16> F7                    P1..P16 changed
 *                                  (knob turns, LFO, parameter slides)
 *
 * P1..P8 are the SRC page (the sound's machine words 0..7), P9..P16 its second
 * page (press SRC again, or SMPL: the sound's sample words 8..15, so they are
 * stored, p-locked and LFO'd as stock's sample parameters are).
 *
 * Each P is 14-bit, two bytes: the value 0..127, then the top 7 bits of its
 * fraction (the stored parameter's low byte: slides and LFO move it).
 *
 * It runs in the audio interrupt (level 5) like every machine engine, so it never
 * waits: it calls the OS's USB MIDI sender only when that is safe from here, and
 * otherwise keeps the message pending for the next block. Safe means [measured,
 * OS 1.73 disassembly, 2026-10-08]:
 *   - the sender's mutex (0x42f67a28, owner word +0; every task caller takes it
 *     through 0x40002914 / releases 0x40002924) is free, so no task is inside the
 *     sender (a task cannot run while this interrupt does);
 *   - its SysEx state (0x413db244) is idle, so no task's SysEx is half sent;
 *   - its ring (4 KB at 0x4b80c000) is far from full: the sender spins while the
 *     fill (0x413db258) plus what it adds exceeds 4091, and these messages (under
 *     48 bytes) never take its wrap-wait path.
 * The sender itself returns at once when no host has configured the port.
 */
#include <stdint.h>

#define SENDER_MUTEX  (*(volatile uint32_t *)0x42f67a28u)
#define SYSEX_STATE   (*(volatile uint32_t *)0x413db244u)
#define RING_FILL     (*(volatile uint32_t *)0x413db258u)
#define STATE0(v)     (*(volatile int32_t *)(0x8000fef8u + 32u * (v)))
#define OWNER(v)      (((const uint8_t *)0x40290dd8u)[v])
#define VELOCITY(t)   (((const uint8_t *)0x800067c4u)[2u * (t)])

#define TEXT __attribute__((section(".text")))
#define EXT2 __attribute__((section(".ext2")))
#define EXT3 __attribute__((section(".ext3")))
#define EXT5 __attribute__((section(".ext5")))   /* DAISYSP's code */
#define EXT6 __attribute__((section(".ext6")))   /* and its names */

/* Machine 51 (CY TEST, hidden) is DAISYSP: the same engine, its voices reported
   with 0x10 in the voice byte, and the host plays them with DaisySP's physical
   models (Electrosmith, MIT; rytm-teensy sim/daisyvoice.py). Its knobs: ENG
   (MODAL STRING RESON in three zones), STR BRI DMP, INP (what strikes it:
   INT, or an analog voice's Overbridge output, in nine zones), EXC, TUN, LEV.
   Records 449..456 (CY TEST's, slots 9..16, already in order on its SRC page).
   It keeps stock's SMPL page and sample layer. */
#define DSP_MACHINE 51
#define DSPS_MACHINE 45   /* DSP SAMPLE: SD TEST, below */
#define DD_MACHINE 42     /* DIGIDRUM: RS FM 2, below */
#define JUNO_MACHINE 41   /* JUNO: BD FM 2, below */
#define FM_MACHINE 40     /* 6-OP FM: RS CLASSIC 2, below */
void dsp_descriptors2(void);
int dsp_excite(int32_t voice, uint8_t *frame, const int16_t *params, int32_t pitch);
int32_t ext_vflag(int32_t m);        /* user slots (.us1, below): the voice byte's machine flag */
int32_t ext_layer_kept(int32_t vb);  /* the voice's sample layer plays */
#define MACHINE_OF(t) (((const uint8_t *)0x8000ea00u)[t])
const char dsp_long[] EXT6 = "DAISYSP";
const char dsp_short[] EXT6 = "DSP";
const char dsp_n2[] EXT6 = "Structure";
const char dsp_n3[] EXT6 = "Brightness";
const char dsp_n4[] EXT6 = "Damping";
const char dsp_n5[] EXT6 = "Input";
const char dsp_n6[] EXT6 = "Exciter";
const char dsp_s2[] EXT6 = "STR";
const char dsp_s3[] EXT6 = "BRI";
const char dsp_s4[] EXT6 = "DMP";
const char dsp_s5[] EXT6 = "INP";
const char dsp_s6[] EXT6 = "EXC";

/* Names of machine 44 (PLAITS) and its knobs (registry patches point here): the
   Plaits parameters the host plays them as (rytm-teensy sim/obhost.py). */
const char ext_long[] TEXT = "PLAITS";
const char ext_short[] TEXT = "PLTS";
const char ext_n1[] TEXT = "Engine";
const char ext_n2[] TEXT = "Harmonics";
const char ext_n3[] TEXT = "Timbre";
const char ext_n4[] TEXT = "Morph";
const char ext_n5[] TEXT = "Decay";
const char ext_n6[] TEXT = "LPG Colour";
const char ext_n7[] TEXT = "Tune";
const char ext_n8[] TEXT = "Level";
const char ext_s1[] TEXT = "ENG";
const char ext_s2[] TEXT = "HRM";
const char ext_s3[] TEXT = "TIM";
const char ext_s4[] TEXT = "MOR";
const char ext_s5[] TEXT = "DEC";
const char ext_s6[] TEXT = "LPG";
const char ext_s7[] TEXT = "TUN";
const char ext_s8[] TEXT = "LEV";
/* Page 2 (records 422..429 = sample words 17..24, in that order). */
const char ext_n9[] EXT3 = "Pitch Env";
const char ext_n10[] EXT3 = "Fine Tune";
const char ext_n11[] EXT3 = "Aux Mix";
const char ext_n12[] EXT3 = "Timbre Env";
const char ext_n13[] EXT3 = "Morph Env";
const char ext_n14[] EXT3 = "Velocity";
const char ext_n15[] EXT3 = "Glide";
const char ext_n16[] EXT3 = "Volume";
const char ext_s9[] EXT3 = "FM";
const char ext_s10[] EXT3 = "FIN";
const char ext_s11[] EXT3 = "AUX";
const char ext_s12[] EXT3 = "TMD";
const char ext_s13[] EXT3 = "MMD";
const char ext_s14[] EXT3 = "VEL";
const char ext_s15[] EXT3 = "GLD";
const char ext_s16[] EXT3 = "VOL";

typedef void (*engine_fn)(int32_t voice, uint8_t *frame, const int16_t *params, int32_t pitch);
typedef void (*send_fn)(int32_t len, const uint8_t *data);
#define DISABLE_ENGINE ((engine_fn)0x40113efcu)
#define USB_MIDI_SEND  ((send_fn)0x400029e0u)

#define NP 16
/* Per voice: the last parameters reported and what is pending. */
struct ext_voice {
  uint16_t sent[NP];
  uint16_t pend_p[NP];
  uint8_t note, vel;
  uint8_t pend_trig, pend_params, hold;   /* hold: blocks until the next 0x03 */
  uint8_t gate;   /* the owner track's note is open (or its note-off pending) */
};
/* A parameter-only report (0x03) goes at most every REPORT_GAP blocks of the
   voice: the firmware glides a turned parameter toward its new value, and in
   14-bit steps that changes nearly every block (measured in rytm-emu: ~1100
   reports/s, 45 KB/s, for one knob, which macOS's virtual MIDI port drops,
   trigs with them). Trigs go at once and carry the current values. */
#define REPORT_GAP 16
__attribute__((section(".exts"))) struct ext_voice ext_state[8];
#define SGAIN(v) ((volatile int32_t *)(0x80007000u + 8u * (v)))

static void ext_project(void);
void ext_gate(int32_t voice);
/* Free USB requests (review 2026-10-09, critical): the sender's flush pops a
   request from a pool of 32 (free list head 0x413db390, next at +52; pop
   0x40003a10) and, when the pool is empty, 0x40003a64 waits on a semaphore -
   a task switch, fatal inside the audio interrupt. The pool empties when the
   host stops reading MIDI (a sleeping laptop, a stalled Teensy). So at least n
   free requests, or no send (the wrap path flushes twice: n = 2 here). */
__attribute__((section(".exto"), noinline)) int usb_free(int n) {
  const volatile uint32_t *h = *(const volatile uint32_t *const volatile *)0x413db390u;
  while (n-- > 0) {
    if (!h) return 0;
    h = (const volatile uint32_t *)h[13];
  }
  return 1;
}

/* In cave12 (.ext9): .text is full. */
#if EXT_SLOTS
/* The UI task's sends (2026-10-16, the hardware freeze after host brown-outs): never wait on USB, as 0026 / 0029.
   MIDI_LOCK pends while another task owns the mutex 0x42f67a28 and the sender spins while its ring is full; so the
   port configured (0x413db254 == 1), the ring's room (+64 <= 4091), 4 free requests, then a try-lock (0x4000119c:
   takes it only when free, never pends [code, 1.73]); 1: held (give it with MIDI_UNLOCK), 0: not now. */
__attribute__((section(".us2"), noinline)) int ext_ui_lock(void) {   /* .us2: cave12 is full */
  if (*(volatile uint32_t *)0x413db254u != 1 || RING_FILL + 64 > 4091 || !usb_free(4)) return 0;
  return ((int (*)(void *))0x4000119cu)((void *)0x42f67a28u);
}
#endif

__attribute__((section(".ext9"), noinline)) static int ext_try_send(const uint8_t *msg, int len) {
  if (SENDER_MUTEX != 0 || SYSEX_STATE != 0 || RING_FILL > 3800 || !usb_free(2)) return 0;
  USB_MIDI_SEND(len, msg);
  return 1;
}

/* ---------------------------------------------------------------------------
 * How the knobs look and read. Each parameter record has a descriptor at
 * 0x419a4888 + 84 x record, built at boot [measured, OS 1.73]: +0..+19 flags
 * and a style, then std::function slots of 16 bytes (storage, 0, manager,
 * invoker): +20 the value text (param_value_text jumps to +32 with (functor,
 * value 8.8, string)), +36 the widget, +52 and +68 more. They hold no record
 * data, only functions shared by type (the plain dial by 238 records, the
 * bipolar text by 67), so a knob takes on another record's look by copying its
 * descriptor. BD TEST's were bipolar P1/P2 and list switches P7/P8. Done once,
 * in the UI task, at the first param_value_text (0x400a85e0; the bottom bar
 * prints a value from the first screen on) - after boot built the table, before
 * any page can show EXT's knobs [measured: a descriptor changed after boot takes
 * effect when the page is drawn].
 * ------------------------------------------------------------------------- */
#define DESC(r) ((uint32_t *)(0x419a4888u + 84u * (r)))
#define REC_ADDR(r) ((const int32_t *)(0x401bf918u + 0x34u * (uint32_t)(r)))
#define REC_P1 408
#define REC_DIAL 410        /* P3: plain dial, number */
#define REC_TUNE 100        /* BD HARD TUN: centred dial, +-N */
#define REC_LEVEL 101       /* BD HARD LEV: fader */
#define REC_BIPOLAR 40      /* SMPL FIN: centred dial, +-N */
#define REC_P2 422          /* EXT page 2: RS TEST's records, rewritten */
typedef int32_t (*sprintf_fn)(void *str, const char *fmt, ...);
#define STR_PRINTF ((sprintf_fn)0x40098602u)

/* Plaits' models as curated 2026-10-09 (17 of 24): its 6-op FM models (2..4)
   are the 6-OP FM machine's, NOISE (17) went, its drums (21..23) are
   DIGIDRUM's. The host maps zone i to Plaits model 0 1 5 6 7 8 9 10 11 12 13 14
   15 16 18 19 20. */
#define EXT_MODELS 17
static const char ext_engine_names[EXT_MODELS][8] EXT3 = {
    "VA VCF", "PHASDST", "WAVTERR", "STRMACH", "CHIPTUN", "VA", "WAVSHAP", "2OP FM",
    "GRANULR", "HARMONC", "WAVETBL", "CHORDS", "SPEECH", "SWARM", "PARTICL", "STRING", "MODAL"};
static const char ext_fmt_s[] EXT3 = "%s";

/* P1's value text: the Plaits model. */
/* ENG spans the whole knob, 0..127, in EXT_MODELS equal zones: zone = value x
   N / 128 (value 8.8 here; the host maps the same way, so a sweep or an LFO
   crosses them all). */
EXT2 int32_t ext_engine_text(void *functor, int32_t value, void *str) {
  int32_t i = (value * EXT_MODELS) >> 15;
  (void)functor;
  if (i < 0) i = 0;
  if (i > EXT_MODELS - 1) i = EXT_MODELS - 1;
  return STR_PRINTF(str, ext_fmt_s, ext_engine_names[i]);
}

__attribute__((section(".exts"))) uint8_t ext_desc_done;

EXT2 static void copy_desc(int to, int from) {
  uint32_t *d = DESC(to), *s = DESC(from);
  int i;
  for (i = 0; i < 21; ++i) d[i] = s[i];
}

/* DAISYSP's (and DSP SAMPLE's) ENG: three models over the whole knob, model =
   value x 3 / 128 (DRIP dropped 2026-10-09). */
#define REC_DSP 449
static const char dsp_engine_names[3][8] EXT6 = {"MODAL", "STRING", "RESON"};
/* INP, what strikes the resonator, in eleven zones (value x 11 / 128): INT the
   host's own strike; NAT the track's native machine and NOISE UT NOISE, played
   on this voice (dsp_excite); or another voice, BD..CY/CB, through its
   Overbridge output (channels 2..9, track order). */
static const char dsp_input_names[11][6] EXT6 = {"INT", "NAT", "NOISE", "BD", "SD", "RS/CP", "BT", "LT", "MT/HT", "CH/OH", "CY/CB"};
EXT5 int32_t dsp_engine_text(void *functor, int32_t value, void *str) {
  int32_t i = (value * 3) >> 15;
  (void)functor;
  if (i < 0) i = 0;
  if (i > 2) i = 2;
  return STR_PRINTF(str, ext_fmt_s, dsp_engine_names[i]);
}

EXT5 int32_t dsp_input_text(void *functor, int32_t value, void *str) {
  int32_t i = (value * 11) >> 15;
  (void)functor;
  if (i < 0) i = 0;
  if (i > 10) i = 10;
  return STR_PRINTF(str, ext_fmt_s, dsp_input_names[i]);
}

/* DAISYSP's knobs: plain dials, TUN centred, LEV a fader (CY TEST's own were
   list switches). */
EXT5 void dsp_descriptors(void) {
  int i;
  for (i = 0; i < 6; ++i) copy_desc(REC_DSP + i, REC_DIAL);
  DESC(REC_DSP)[8] = (uint32_t)dsp_engine_text;
  DESC(REC_DSP + 4)[8] = (uint32_t)dsp_input_text;
  copy_desc(REC_DSP + 6, REC_TUNE);
  copy_desc(REC_DSP + 7, REC_LEVEL);
  dsp_descriptors2();
}

void dd_descriptors(void);
void jn_descriptors(void);
void fm_descriptors(void);
int32_t jn_pat_text(void *functor, int32_t value, void *str);
EXT2 void ext_descriptors(void) {
  int i;
  copy_desc(REC_P1, REC_DIAL);
  DESC(REC_P1)[8] = (uint32_t)ext_engine_text;   /* slot 1 invoker: the model name */
  copy_desc(REC_P1 + 1, REC_DIAL);
  copy_desc(REC_P1 + 6, REC_TUNE);
  copy_desc(REC_P1 + 7, REC_LEVEL);
  /* Page 2 (RS TEST's records 422..429, slots 17..24): FM and FIN bipolar as
     stock's SMPL FIN (record 40), VOL a fader, the rest plain dials. */
  copy_desc(REC_P2 + 0, REC_BIPOLAR);   /* FM  */
  copy_desc(REC_P2 + 1, REC_BIPOLAR);   /* FIN */
  for (i = 2; i < 7; ++i) copy_desc(REC_P2 + i, REC_DIAL);
  copy_desc(REC_P2 + 7, REC_LEVEL);     /* VOL */
  dsp_descriptors();
  dd_descriptors();
  jn_descriptors();
  ext_desc_done = 1;
}

/* ---------------------------------------------------------------------------
 * Page 2, on the SMPL key (page ids 4/5) [measured, as 0020's FM4 page 2]. Not
 * on SRC: pressing SRC again opens the machine list, on every machine [measured:
 * a page list {0, 4} for the SRC view, constructor 0x400cae98, never cycled].
 * Three lookups answer EXT's page-2 records on machine 44 and stock's otherwise
 * (each replaced whole):
 *   0x4003795a  a parameter page's record of knob k
 *   0x4003793c  a parameter page's title
 *   0x40007028  sound_param_record(index, machine): the sample words 17..24 on
 *               machine 44 are records 422..429 (ranges, p-locks, LFO, text)
 * (0020's FM4 page 2 replaces the last three the same way, for machine 35; the
 * two mods are not built together.)
 * ------------------------------------------------------------------------- */
#define EXT4 __attribute__((section(".ext4")))
typedef int32_t (*fn1)(int32_t);
typedef int32_t (*fn2)(int32_t, int32_t);
#define PAGE_INFO(id)   ((const int32_t *)((fn1)0x400ff574)(id))
#define VCALL(v, off)   (((fn1)(*(int32_t **)(v))[(off) / 4])((int32_t)(v)))
#define EXT_MACHINE 44
#define REC_DSP2 430        /* DAISYSP page 2: BT TEST's and LT TEST's records */
extern const char dsp_p2_title[];
extern const int32_t dsp_p2_order[8];
#define REC_DSPS2 441       /* DSP SAMPLE's SD SAMPLE page: MT/HH TEST's 441..448 */
extern const char dsps_p2_title[];
extern const int32_t dsps_p2_order[8];

/* Knob order on page 2: TMD MMD FM AUX / FIN VEL GLD VOL. */
static const int32_t ext_p2_order[8] EXT3 = {425, 426, 422, 424, 423, 427, 428, 429};
const char ext_p2_title[] EXT3 = "PLAITS PAGE 2";

EXT4 static int32_t ext_view_machine(const int32_t *view) {
  int32_t slot = VCALL(view, 0x90), sound;
  if (slot < 0) sound = ((fn2)0x400a675e)(view[30], ((fn1)0x400b68d2)(view[29]));
  else sound = ((fn2)0x400ae494)(view[26], slot);
  return ((fn1)0x400bca70)(sound);
}

/* The machines' page-2 answers live in .us1 (us_page_record, us_page_title, us_param_record): PLAITS,
   DAISYSP, DSP SAMPLE and the user slots whose page 2 is knobs; 0 there: stock's. */
int32_t us_page_record(int32_t m, uint32_t k);
int32_t us_page_title(int32_t m);
int32_t us_param_record(uint32_t index, uint32_t machine);

#if EXT_SLOTS
EXT4 int32_t ext_page_record(const int32_t *view, uint32_t k) {
  int32_t id = VCALL(view, 0x68), r;
  if (k > 7) return 0;
  if ((id == 4 || id == 5) && (r = us_page_record(ext_view_machine(view), k)) != 0) return r < 0 ? 0 : r;   /* -1: unused */
  return PAGE_INFO(id)[1 + k];
}

EXT4 int32_t ext_page_title(const int32_t *view) {
  int32_t id = VCALL(view, 0x68), t;
  if ((id == 4 || id == 5) && (t = us_page_title(ext_view_machine(view))) != 0) return t;
  return PAGE_INFO(id)[0];
}
#else   /* slots=0: the pre-slot image (c127fe8), byte for byte */
EXT4 int32_t ext_page_record(const int32_t *view, uint32_t k) {
  int32_t id = VCALL(view, 0x68), m;
  if (k > 7) return 0;
  if (id == 4 || id == 5) {
    m = ext_view_machine(view);
    if (m == EXT_MACHINE) return ext_p2_order[k];
    if (m == DSP_MACHINE) return dsp_p2_order[k];
    if (m == DSPS_MACHINE) return dsps_p2_order[k];
  }
  return PAGE_INFO(id)[1 + k];
}

EXT4 int32_t ext_page_title(const int32_t *view) {
  int32_t id = VCALL(view, 0x68), m;
  if (id == 4 || id == 5) {
    m = ext_view_machine(view);
    if (m == EXT_MACHINE) return (int32_t)ext_p2_title;
    if (m == DSP_MACHINE) return (int32_t)dsp_p2_title;
    if (m == DSPS_MACHINE) return (int32_t)dsps_p2_title;
  }
  return PAGE_INFO(id)[0];
}
#endif

EXT4 int32_t ext_param_record(uint32_t index, uint32_t machine) {
  if (index > 41) return 0;
  if (index - 9 <= 7) {
    if (machine > 52) return 0;
    return ((const int32_t *)0x413db5fcu)[machine * 8 + index - 9];
  }
  if (index == 19 && machine == DSPS_MACHINE) return 41;   /* SMP: stock's slot record */
#if EXT_SLOTS
  if (index - 17 <= 7) return us_param_record(index, machine);
#else
  if (index - 17 <= 7)
    return (machine == EXT_MACHINE ? REC_P2 : machine == DSP_MACHINE ? REC_DSP2
            : machine == DSPS_MACHINE ? REC_DSPS2 : 39) + (int32_t)index - 17;
#endif
  return ((const int32_t *)0x413db554u)[index];
}

__asm__(
    "  .section .ext2,\"ax\"\n"
    "  .globl ext_pvt\n"
    "ext_pvt:\n"
    "  jsr ext_ui_tick\n"
    "  lea %sp@(-20),%sp\n"
    "  moveml %d2-%d4/%a2-%a3,%sp@\n"
    "  jmp 0x400a85e8\n");

__attribute__((noinline)) void ext_render_body(int32_t voice, uint8_t *frame, const int16_t *params, int32_t pitch) {
  /* A trig: the firmware zeroes word 0 of the voice's state block (0x8000fef8 +
     32v) on every trig [measured: FM4 and the 0020 engines rely on it]. DISABLE's
     engine runs with that word zero (it clears the voice's buffers while it is
     zero and never sets it), so it is zero while DISABLE runs and 1 between
     blocks: a zero on entry is a new trig. */
  int trig = STATE0(voice) == 0;
#if EXT_SLOTS
  uint8_t vb = (uint8_t)((voice & 7) | ext_vflag(MACHINE_OF(OWNER(voice))));
  /* DAISYSP with INP NAT/NOISE: that machine's engine plays the voice (its
     state block is its own, word 0 still zeroed on a trig); else DISABLE's. */
  /* DAISYSP exactly: the user slots' flags 0x50 0x58 0x70 have bit 4 too. */
  int ex = (vb & 0x78) == 0x10 ? dsp_excite(voice, frame, params, pitch) : 0;
#else
  uint8_t vb = (uint8_t)(voice & 7), mach = MACHINE_OF(OWNER(voice));
  if (mach == DSP_MACHINE) vb |= 0x10;
  else if (mach == DSPS_MACHINE) vb |= 0x20;
  else if (mach == DD_MACHINE) vb |= 0x40;
  else if (mach == JUNO_MACHINE) vb |= 0x08;
  else if (mach == FM_MACHINE) vb |= 0x48;
  /* DAISYSP with INP NAT/NOISE: that machine's engine plays the voice (its
     state block is its own, word 0 still zeroed on a trig); else DISABLE's. */
  int ex = (vb & 0x10) ? dsp_excite(voice, frame, params, pitch) : 0;
#endif
  if (!ex) {
    STATE0(voice) = 0;
    DISABLE_ENGINE(voice, frame, params, pitch);
    STATE0(voice) = 1;
  }
  struct ext_voice *x = &ext_state[voice & 7];
  int i, changed = 0;
  ext_gate(voice);
  uint16_t p[NP];
  /* The machines' second pages live in the sample words (DSP SAMPLE's picks a
     sample on the host's card): the Rytm's sample layer stays silent - except
     under UT NOISE (ex 2), which plays through it, and on DIGIDRUM. */
#if EXT_SLOTS
  if (ex != 2 && !ext_layer_kept(vb)) {   /* DIGIDRUM, and a user slot with the sample page: it plays */
#else
  if (ex != 2 && (vb & 0x78) != 0x40) {   /* DIGIDRUM: its sample plays under the drum */
#endif
    SGAIN(voice & 7)[0] = 0;
    SGAIN(voice & 7)[1] = 0;
  }
  for (i = 0; i < NP; ++i) {
    p[i] = ((uint16_t)params[i] >> 1) & 0x3fff;   /* value << 7 | fraction >> 1 */
    if (p[i] != x->sent[i]) changed = 1;
  }
  if (trig) {
    x->pend_trig = 1;
    x->note = (uint8_t)((pitch >> 16) & 0x7f);
    x->vel = VELOCITY(OWNER(voice)) & 0x7f;
  }
  if (changed || x->pend_trig) {
    for (i = 0; i < NP; ++i) x->pend_p[i] = p[i];
    x->pend_params = 1;
  }
  if (x->hold) --x->hold;
  if (!x->pend_params || (!x->pend_trig && x->hold)) return;
  uint8_t m[44];   /* the trig message is 43 bytes (41 and the sound tag) */
  int n = 0;
  m[n++] = 0xf0; m[n++] = 0x7d; m[n++] = 0x52; m[n++] = 0x54;
  if (x->pend_trig) {
    m[n++] = 0x04; m[n++] = vb; m[n++] = x->note; m[n++] = x->vel;
  } else {
    m[n++] = 0x03; m[n++] = vb;
  }
  for (i = 0; i < NP; ++i) {
    m[n++] = (uint8_t)(x->pend_p[i] >> 7) & 0x7f;
    m[n++] = (uint8_t)x->pend_p[i] & 0x7f;
  }
#if EXT_SLOTS
  {   /* the sound tag: the owner track's, as the trig copied its sound (us_tag; a sound lock's own) */
    extern volatile uint16_t us_tag[13];
    uint16_t tag = us_tag[OWNER(voice)];
    m[n++] = (uint8_t)(tag >> 7) & 0x7f;
    m[n++] = (uint8_t)tag & 0x7f;
  }
#endif
  m[n++] = 0xf7;
  if (ext_try_send(m, n)) {
    for (i = 0; i < NP; ++i) x->sent[i] = x->pend_p[i];
    x->pend_trig = 0;
    x->pend_params = 0;
    x->hold = REPORT_GAP;
  }
}

/* ---------------------------------------------------------------------------
 * DIGIDRUM (2026-10-09): machine 42 (RS FM 2, one of 0014's hidden "2" variants,
 * which 0014 no longer lists) for the host's DIGIDRUM voices - soejrd/digidrum's
 * Machinedrum-style TRX and EFM machines (MIT; rytm-teensy sim/digidrum). Same
 * engine entry, ext_render, reported with 0x40 in the voice byte; on every
 * track. Records 390..397 (RS FM 2's, slots 9..16) as ENG and the engine's
 * controls 1..7 (control 8 stays at the engine's default on the host). ENG:
 * 0..127 in 11 zones (EFM BD..CY, TRX RS CB CL; curated 2026-10-09); its value text names the
 * engine and points knobs 2..8's names at that engine's control names, so the
 * page reads PTCH DEC RAMP .. for TRX-B2, GAP DEC HPF .. for TRX-CH. The SMPL
 * page is stock's: the sound's own sample plays under the drum.
 * ------------------------------------------------------------------------- */
#define EXTD __attribute__((section(".extd"), noinline))   /* code */
#define EXTE __attribute__((section(".exte")))             /* names */

#define REC_DD 390
/* Curated 2026-10-09 (11 of 16): the EFM machines and TRX RS/CB/CL; TRX B2,
   SD, CH, OH and CY went (the Rytm's own analog voices do those). */
#define DD_MODELS 11
static const char dd_names[DD_MODELS][7] __attribute__((section(".extg"))) = {
    "EFM-BD", "EFM-SD", "EFM-XT", "EFM-CP", "EFM-RS", "EFM-CB", "EFM-HH", "EFM-CY",
    "TRX-RS", "TRX-CB", "TRX-CL"};
static const char dd_pool[39][5] EXTE = {
    "PTCH", "DEC", "RAMP", "HOLD", "TICK", "NOIS", "DIRT", "BUMP", "BENV", "SNAP",
    "TONE", "TUNE", "GAP", "HPF", "LPF", "MTAL", "-", "RICH", "TOP", "TTUN",
    "SIZE", "PEAK", "DIST", "ENH", "DUAL", "CLIC", "RDEC", "MOD", "MFRQ", "MDEC",
    "NDEC", "CLPS", "CDEC", "SNAR", "SPTC", "SDEC", "FB", "TREM", "TFRQ"};
static const uint8_t dd_label[DD_MODELS][7] EXTE = {
    {0, 1, 2, 26, 27, 28, 29},
    {0, 1, 5, 30, 27, 28, 29},
    {0, 1, 2, 26, 27, 28, 29},
    {0, 1, 31, 32, 27, 28, 29},
    {0, 1, 27, 13, 33, 34, 35},
    {0, 1, 9, 36, 27, 28, 29},
    {0, 1, 37, 38, 27, 28, 29},
    {0, 1, 36, 13, 27, 28, 29},
    {0, 1, 22, 16, 16, 16, 16},
    {0, 1, 23, 10, 7, 16, 16},
    {0, 1, 24, 23, 11, 25, 16}};
const char dd_long[] EXTE = "DIGIDRUM";
const char dd_short[] EXTE = "DDRM";
static const char dd_eng[] EXTE = "ENG";

/* Knobs 2..8 named as engine i's controls 1..7 (long and short name alike). */
EXTD static void dd_name_knobs(int32_t i) {
  int k;
  for (k = 0; k < 7; ++k) {
    uint32_t *r = (uint32_t *)REC_ADDR(REC_DD + 1 + k);
    r[10] = r[12] = (uint32_t)dd_pool[dd_label[i][k]];
  }
}

EXTD int32_t dd_engine_text(void *functor, int32_t value, void *str) {
  int32_t i = (value * DD_MODELS) >> 15;
  (void)functor;
  if (i < 0) i = 0;
  if (i > DD_MODELS - 1) i = DD_MODELS - 1;
  dd_name_knobs(i);
  return STR_PRINTF(str, ext_fmt_s, dd_names[i]);
}

EXTD void dd_descriptors(void) {
  uint32_t *r;
  int k;
  for (k = 0; k < 8; ++k) {
    copy_desc(REC_DD + k, REC_DIAL);
    ((uint32_t *)REC_ADDR(REC_DD + k))[11] = (uint32_t)dd_short;   /* group */
  }
  r = (uint32_t *)REC_ADDR(REC_DD);
  r[10] = r[12] = (uint32_t)dd_eng;
  DESC(REC_DD)[8] = (uint32_t)dd_engine_text;
  dd_name_knobs(0);
}

/* ---------------------------------------------------------------------------
 * JUNO (2026-10-09): machine 41 (BD FM 2, another of 0014's hidden "2"
 * variants, no longer listed there) for the host's JUNO voices - a Juno-106
 * voice on AMY's 106 model (rytm-teensy sim/juno). ext_render, reported with
 * 0x08 in the voice byte; on every track; the sample layer muted as PLAITS's.
 * Records 382..389 (BD FM 2's, slots 9..16): PAT (the factory patch 0..127,
 * named as the 106's buttons, A11..B88), CUT RES ENV ATK DEC REL (offsets on
 * the patch's own sliders, 64 = the patch: centred dials) and LEN (the gate,
 * as the Rytm sends trigs; 127 = until the next trig).
 * ------------------------------------------------------------------------- */
#define EXTJ __attribute__((section(".extj"), noinline))   /* PAT's text */
#define EXTL __attribute__((section(".extl"), noinline))   /* descriptors */
#define EXTK __attribute__((section(".extk")))             /* short names */
#define EXTM __attribute__((section(".extm")))             /* long names */
#define REC_JN 382
static const char jn_long[8][11] EXTM = {"Patch", "Cutoff", "Resonance", "Env Amount",
                                         "Attack", "Decay", "Release", "Gate"};
static const char jn_short[8][4] EXTK = {"PAT", "CUT", "RES", "ENV", "ATK", "DEC", "REL", "LEN"};
const char jn_name[] EXTK = "JUNO";
static const char jn_fmt[] EXTK = "%c%d%d";

/* PAT: bank A/B, group 1..8, number 1..8, as the 106's buttons. */
EXTJ int32_t jn_patch_text(void *functor, int32_t value, void *str) {
  int32_t p = value >> 8;
  (void)functor;
  if (p < 0) p = 0;
  if (p > 127) p = 127;
  return STR_PRINTF(str, jn_fmt, p < 64 ? 'A' : 'B', (p & 63) / 8 + 1, p % 8 + 1);
}

EXTL void jn_descriptors(void) {
  int k;
  for (k = 0; k < 8; ++k) {
    uint32_t *r = (uint32_t *)REC_ADDR(REC_JN + k);
    copy_desc(REC_JN + k, k >= 1 && k <= 6 ? REC_BIPOLAR : REC_DIAL);
    r[10] = (uint32_t)jn_long[k];
    r[11] = (uint32_t)jn_name;
    r[12] = (uint32_t)jn_short[k];
  }
  DESC(REC_JN)[8] = (uint32_t)jn_pat_text;
}

/* Note-offs to the host (2026-10-09): F0 7D 52 54 11 <voice> F7 when the owner
 * track's note ends - a pad or key released, a sequencer trig's LEN run out, or
 * the sequencer stopped. The Rytm keeps three held-note slots a track, int32
 * gate[13][3] at 0x8000fe58, -1 when free [measured, rytm-emu lp3]: 0 live play,
 * 1 the sequencer (LEN; INF never frees it, not even at STOP), 2 a fourth source.
 * They are updated in the audio interrupt before the engines run, so this block's
 * gate is seen here. Open = any slot set, the sequencer's only while it plays:
 * 0x405c8c90 (in .bss) is 1 from PLAY to STOP, 0 when stopped, also after a
 * double stop; the word after it counts the steps [measured, rytm-emu lp3n
 * 2026-10-09, sampled every 10M instructions through play/stop/stop: the design
 * note's 0x41329b54 was a typo for 0x41329c34, which reads 1 but drops to 3 within
 * steps while playing]. A retrig while open keeps the slot set: no note-off between
 * (and a trig always opens, so a pending note-off is dropped by it). Every voice
 * block of these machines, before the project check; in cave12 (.exto:
 * ext_render's .text is full). */
#define EXTQ __attribute__((section(".exto"), noinline))
#define GATES(t) ((const volatile int32_t *)(0x8000fe58u + 12u * (t)))
#define PLAYING (*(volatile int32_t *)0x405c8c90u)

EXTQ void ext_gate(int32_t voice) {
  struct ext_voice *x = &ext_state[voice & 7];
  const volatile int32_t *g = GATES(OWNER(voice));
  if (g[0] != -1 || g[2] != -1 || (g[1] != -1 && PLAYING)) {
    x->gate = 1;
  } else if (x->gate && !x->pend_trig) {   /* never ahead of its trig */
    uint8_t m[7] = {0xf0, 0x7d, 0x52, 0x54, 0x11, (uint8_t)(voice & 7), 0xf7};
    if (ext_try_send(m, 7)) x->gate = 0;
  }
  ext_project();
}

/* The Rytm's project to the host: 10 <name> when it changes, and every so
 * often anyway (a host that restarted) - the Teensy keeps a pool per project
 * (rytm-teensy sim/protocol.py). The active project's name: 16 bytes at
 * 0x407c89d3, up to 15 characters and a NUL [measured, rytm-emu: follows SAVE
 * AS NEW and LOAD, same address after a cold boot]. Checked every 256 voice
 * blocks of the machines here (a few times a second), sent again every 64th
 * check. */
#define EXTP __attribute__((section(".extp"), noinline))
#define PROJECT_NAME ((const uint8_t *)0x407c89d3u)
struct ext_proj { uint32_t n; uint8_t sent[16]; };
__attribute__((section(".exts"))) struct ext_proj ext_proj;

EXTP static void ext_project(void) {
  struct ext_proj *q = &ext_proj;
  uint8_t m[22];
  int i, n = 5, same = 1;
  if (++q->n & 255) return;
  for (i = 0; i < 16; ++i)
    if (PROJECT_NAME[i] != q->sent[i]) same = 0;
  if (same && (q->n & 0x3fff)) return;
  m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x10;
  for (i = 0; i < 15 && PROJECT_NAME[i]; ++i) m[n++] = PROJECT_NAME[i] & 0x7f;
  m[n++] = 0xf7;
  if (ext_try_send(m, n))
    for (i = 0; i < 16; ++i) q->sent[i] = PROJECT_NAME[i];
}

/* ---------------------------------------------------------------------------
 * DAISYSP page 2, EXCITER (SMPL; records 430..437 = sample words 17..24). A
 * machine change leaves the sample words as they were, so each knob sits on the
 * word whose stock default suits it (64 64 0 0 0 120 0 100, as PLAITS's page 2):
 * 17 XTN, 18 XDC, 19 FB, 20 OUT, 21 XP4, 22 XLV, 23 XP5, 24 WID [measured: with
 * XLV on word 19 the exciter played at the sample's BR, 0, and was silent].
 * Shown in the order OUT FB XLV XTN / XDC XP4 XP5 WID:
 *   OUT  where the host sends the resonance: VOICE (this voice's input, through
 *        its filter and amp; the voice's own output then carries it back, a
 *        feedback loop) or MAIN (the main outs, no loop)
 *   FB   how much of that loop the host keeps (VOICE)
 *   XLV XTN XDC XP4 XP5  the exciter machine's slots 9..13 (level, tune/tone,
 *        decay, then its own), each scaled over that slot's record range
 *   WID  stereo width of the resonance on MAIN
 * With INP NAT (the track's default machine, 0x401bf14c[track]) or NOISE (UT
 * NOISE, 15) dsp_excite runs that machine's engine (0x4029037c + 4m) on this
 * voice with a parameter block of its own: its records' defaults
 * (0x413db5fc[8m + slot - 9] -> record, +16 default, +8/+12 range) and the five
 * X knobs. The voice then sounds as that machine, and its Overbridge output
 * excites the host's resonator.
 * ------------------------------------------------------------------------- */
#define EXT7 __attribute__((section(".ext7")))   /* code */
#define EXT8 __attribute__((section(".ext8")))   /* names */
#define MACHINE_REC(m, s) (((const int32_t *)0x413db5fcu)[(m) * 8 + (s) - 9])
#define DEFAULT_MACHINE(t) (((const int32_t *)0x401bf14cu)[t])
#define ENGINE(m)         (((const engine_fn *)0x4029037cu)[m])
#define UT_NOISE 15

const char dsp_p2_title[] EXT8 = "EXCITER";
/* Names by record (430..437 = words 17..24). */
const char dsp_n9[] EXT8 = "Exc Tune";
const char dsp_n10[] EXT8 = "Exc Decay";
const char dsp_n11[] EXT8 = "Feedback";
const char dsp_n12[] EXT8 = "Output";
const char dsp_n13[] EXT8 = "Exc Param 4";
const char dsp_n14[] EXT8 = "Exc Level";
const char dsp_n15[] EXT8 = "Exc Param 5";
const char dsp_n16[] EXT8 = "Width";
const char dsp_s9[] EXT8 = "XTN";
const char dsp_s10[] EXT8 = "XDC";
const char dsp_s11[] EXT8 = "FB";
const char dsp_s12[] EXT8 = "OUT";
const char dsp_s13[] EXT8 = "XP4";
const char dsp_s14[] EXT8 = "XLV";
const char dsp_s15[] EXT8 = "XP5";
const char dsp_s16[] EXT8 = "WID";
/* Knob order on the page: OUT FB XLV XTN / XDC XP4 XP5 WID. */
const int32_t dsp_p2_order[8] EXT8 = {433, 432, 435, 430, 431, 434, 436, 437};
static const char dsp_out_names[2][6] EXT8 = {"VOICE", "MAIN"};
const char dsps_long[] EXT8 = "DSP SAMPLE";
const char dsps_short[] EXT8 = "DSPS";

EXT7 int32_t dsp_out_text(void *functor, int32_t value, void *str) {
  (void)functor;
  return STR_PRINTF(str, ext_fmt_s, dsp_out_names[value >= (64 << 8)]);
}

/* DSP SAMPLE (machine 45, SD TEST): a sample from the host's SD card rings its
   DaisySP resonator directly (no round trip); the analog source is off
   (DISABLE's engine). Reported with 0x20 in the voice byte. SRC: ENG STR BRI DMP
   MIX (dry/wet) FB (the voice's own output looped back in) TUN LEV, records
   416..419 (SD TEST's slots 9..12), 439/440 (MT TEST's, as slots 13/14) and
   420/421 (slots 15/16). Its SMPL page, SD SAMPLE: records 441..448 (MT/HH
   TEST's) as copies of stock's sample records 39..46 (sample words 17..24, the
   same ranges, defaults and CCs), word 19 SMP the slot of the project's Teensy
   pool (stock's record 41 and its slot list, 0 OFF) and word 20 (stock's BR)
   FLD, unused since the pool list replaced the folder walk (2026-10-09); laid
   out as stock's page: TUN FIN FLD SMP / STA END LOP LEV. */
static const int16_t dsps_rec[8] EXT8 = {416, 417, 418, 419, 439, 440, 420, 421};
/* SMP is stock's record 41 (the sample slot, word 19) since 2026-10-09: its
   knob opens the stock slot list, which 0023 fills with the project's Teensy
   pool on a DSP SAMPLE track (and FUNC+YES there assigns a TEENSY file). */
const int32_t dsps_p2_order[8] EXT8 = {441, 442, 444, 41, 445, 446, 447, 448};
const char dsps_p2_title[] EXT8 = "SD SAMPLE";
const char dsps_n5[] EXT8 = "Mix";
const char dsps_s5[] EXT8 = "MIX";
const char dsps_n_smp[] EXT8 = "Card Sample";
const char dsps_n_fld[] EXT8 = "Diag TUPKMRSC";
const char dsps_s_fld[] EXT8 = "DGN";

void diag_desc(void);
void mod_desc(void);
/* P_DIAG: the build's diag parameter (--defsym P_DIAG=0/1), read below */

EXT7 void dsp_descriptors2(void) {
  int i;
  for (i = 0; i < 8; ++i) copy_desc(REC_DSP2 + i, REC_DIAL);
  DESC(REC_DSP2 + 3)[8] = (uint32_t)dsp_out_text;   /* OUT, word 20 */
  for (i = 0; i < 6; ++i) copy_desc(dsps_rec[i], REC_DIAL);
  DESC(dsps_rec[0])[8] = (uint32_t)dsp_engine_text;
  copy_desc(dsps_rec[6], REC_TUNE);
  copy_desc(dsps_rec[7], REC_LEVEL);
  /* SD SAMPLE: stock's sample-page looks, SMP and FLD as plain numbers */
  for (i = 0; i < 8; ++i) copy_desc(REC_DSPS2 + i, 39 + i);
  copy_desc(REC_DSPS2 + 2, REC_DIAL);
  /* word 19 (SMP: now record 41, on the page above): a plain number; word 20
     (FLD until the pool list replaced the folder walk): MOD, or the diagnostic
     in a diag build (below) */
  {
    uint32_t on;   /* the symbol's value; asm, as GCC folds an object's address to non-zero */
    __asm__("movel #P_DIAG,%0" : "=d"(on));
    if (on) diag_desc();
    else mod_desc();
  }
}

/* The X knobs for the exciter's slots 9..13: XLV XTN XDC XP4 XP5, as indices
   into the block (word - 9). */
static const uint8_t dsp_x_word[5] EXT8 = {13, 8, 9, 12, 14};

EXT7 int dsp_excite(int32_t voice, uint8_t *frame, const int16_t *params, int32_t pitch) {
  int32_t inp = (((uint16_t)params[4] >> 8) * 11) >> 7, m, k, r, v;
  const int32_t *rec;
  int16_t fp[42];
  if (inp == 1) m = DEFAULT_MACHINE(OWNER(voice));
  else if (inp == 2) m = UT_NOISE;
  else return 0;
  for (k = 0; k < 42; ++k) fp[k] = params[k];
  for (k = 0; k < 8; ++k) {
    r = MACHINE_REC(m, 9 + k);
    if (r <= 0) continue;
    rec = REC_ADDR(r);
    v = rec[4];                                    /* default, 8.8 */
    if (k < 5) v = rec[2] + (rec[3] - rec[2]) / 127 * ((uint16_t)params[dsp_x_word[k]] >> 8);
    fp[k] = (int16_t)v;
  }
  ENGINE(m)(voice, frame, fp, pitch);
  return inp;   /* 1 NAT, 2 NOISE */
}

/* (2026-10-09) The names from the host's card for FLD and SMP (the folder walk:
 * 09/0A, 0022's 0B/0C, the mailbox at 0x400279c4 and the name caches in cave11
 * and cave12) are gone: SMP is stock's record 41 and its slot list of the
 * project's Teensy pool (0023). */

/* ---------------------------------------------------------------------------
 * 6-OP FM (2026-10-09): machine 40 (RS CLASSIC 2, a 0014 "2" variant it no
 * longer lists) for the host's six-op FM voices (Plaits' DX7 engine; rytm-teensy
 * PLAN 3b). ext_render, reported with 0x48 in the voice byte; on every track;
 * the sample layer muted as PLAITS's. Records 374..381 (RS CLASSIC 2's) as PAT
 * (the voice: the project's FM list, else the host's ROM voices; names by 17),
 * TIM MOR (offsets on the voice, 64 = as stored), DEC LPG (the LPG), TUN, LEV and
 * LEN (127 = the Rytm's note length, by note-offs).
 * ------------------------------------------------------------------------- */
#define EXTR __attribute__((section(".extr")))
#define REC_FM 374
int32_t fm_pat_text(void *functor, int32_t value, void *str);
static const char fm_long[8][9] EXTR = {"Voice", "Timbre", "Morph", "Decay", "LPG Col", "Tune", "Level", "Gate"};
static const char fm_short[8][4] EXTR = {"PAT", "TIM", "MOR", "DEC", "LPG", "TUN", "LEV", "LEN"};
const char fm_name[] EXTR = "6-OP FM";
const char fm_sname[] EXTR = "6OP";
static const char fm_fmt_d[] EXTR = "%d";
static const int16_t fm_look[8] EXTR = {REC_DIAL, REC_BIPOLAR, REC_BIPOLAR, REC_DIAL, REC_DIAL, REC_TUNE, REC_LEVEL, REC_DIAL};

__attribute__((section(".extc"), noinline)) void fm_descriptors(void) {
  int k;
  for (k = 0; k < 8; ++k) {
    uint32_t *r = (uint32_t *)REC_ADDR(REC_FM + k);
    copy_desc(REC_FM + k, fm_look[k]);
    r[10] = (uint32_t)fm_long[k];
    r[11] = (uint32_t)fm_sname;
    r[12] = (uint32_t)fm_short[k];
  }
  DESC(REC_FM)[8] = (uint32_t)fm_pat_text;
}

/* ---------------------------------------------------------------------------
 * JUNO's patches from the host (2026-10-09): the project's JUNO list names on
 * PAT, and a patch's own sliders written into the sound's knobs.
 *   host -> Rytm  16 <replace> <total> {<slot> <13 name bytes>}  the list PAT
 *                 steps through (slot = min(PAT, total - 1)); total 0: none,
 *                 PAT shows the factory patches (A11..B88)
 *   host -> Rytm  15 <voice> <CUT> <RES> <ENV> <ATK> <DEC> <REL>  sent when a
 *                 voice's patch changed (PAT turned): the patch's sliders,
 *                 written into the owner track's sound so the knobs show them
 *                 (the host takes CUT..REL as absolute slider values)
 *   Rytm -> host  10 <project>, 13  (asks for 14 and 16) when PAT draws a list
 *                 that is missing or another project's
 * Both reach jn_sysex through 0022's router (mailbox at a fixed address,
 * 0x40027a04, magic 'JUNO'), in the MIDI task; 15 is only noted there and
 * applied in the UI task (ext_ui_tick, every value text) as a knob turn leaves
 * it [measured, rytm-emu lp3n 2026-10-09]: the active kit's sound, track t's machine
 * words at 0x41255933 + 2531 k + 152 t (KIT_WORD; int16 8.8, packed; the screen
 * draws from it; same address in the user's own snapshot of another boot), and
 * the live copy through 0x4011f3fa(value, track, index) (what a CUT turn calls;
 * JUNO's records 383..388 are sound indices 10..15). Since 2026-10-10 (R11)
 * through us_set, as the turn does: the live copy, then kit_param_changed, whose
 * drain writes the kit word and the project's copy (kept by a save and the
 * power-off; the kit word alone was lost).
 * ------------------------------------------------------------------------- */
#define EXTN __attribute__((section(".extn")))
#define EXTU __attribute__((section(".ext9"), noinline))
typedef void (*void_fn)(void);
typedef void (*setp_fn)(int32_t value, int32_t track, int32_t index);
#define MIDI_LOCK    ((void_fn)0x40002914u)
#define MIDI_UNLOCK  ((void_fn)0x40002924u)
#if EXT_SLOTS
/* The active kit k (0..127): the 32-bit 0x800067b8, written only by 0x4011f82a, which refuses values above 127; all
   128 kits are resident at 0x412558e3 + 2531 k, and a trig copies track t's sound from 0x4125590d + 2531 k + 152 t,
   k the trig's kit byte (0x42ade134 + 56 t), set from 0x800067b8 (0x4011d054 / 0x4011d090) [read; measured: A02 sets
   it to 1, and its knobs and records write kit 1]. & 127 only keeps an address inside the kits. */
#define US_KIT()        (*(volatile const uint32_t *)0x800067b8u & 127u)
#define KIT_WORD(t, w)  ((volatile uint8_t *)(0x41255933u + 2531u * US_KIT() + 152u * (t) + 2u * (w)))
#define SET_PARAM    ((setp_fn)0x4011f3fau)
/* R11 [measured]: a stock knob turn is the live copy (SET_PARAM) and then kit_param_changed(bank, track,
   record, value 8.8) on the bank from its getter; the bank's drain (UI loop) writes the kit word and the
   project's copy (what a save and the power-off keep). UI task only: it takes the bank's mutex. The
   record's +0 kind must be the track's machine or >= 53 (the takeover's claims make it so). */
#define US_BANK   ((void *(*)(void))0x40194618u)
#define US_COMMIT ((void (*)(void *bank, int32_t track, int32_t record, int32_t value))0x4003355cu)
void us_set(int32_t t, int32_t index, int32_t record, int32_t v);
#define JN_NAME 10   /* 9 characters kept of the 13 sent (the knob shows ~8) */

int jn_sysex(const uint8_t *d, int32_t len);
int us_sysex(const uint8_t *d, int32_t len);   /* the hook: 15..17 to jn_sysex, the user slots' 1A..1D (.us2) */
struct jn_mailbox {
  uint32_t magic;                         /* 'JUNO': live */
  int (*hook)(const uint8_t *, int32_t);  /* 0022 calls it with 15..1D */
  uint8_t valid, total, wait, pend;       /* pend: 15's sequence (MIDI task): odd while written, + 2 a 15 */
  uint8_t pend_track, val[6], list;   /* list: the names' list (the key): 0 JUNO, 1 FM, 0x11..0x15 U1..U5's
                                          presets, 0x20 the installed machines */
  uint8_t lgen;                           /* a user-slot list's generation (the slot's, or the store's) */
  uint8_t proj[16];                       /* the project the list is for */
  char names[127][JN_NAME];               /* lists are 127 slots at most */
  uint8_t taken;                          /* the last pend the UI took (UI task; the struct's pad byte) */
};
typedef uint32_t __attribute__((may_alias)) jn_u32;
#define JN_BARRIER() __asm__ __volatile__("" ::: "memory")   /* the compiler keeps the order (one core) */
struct jn_mailbox jn_mailbox EXTN = {0x4a554e4fu, us_sysex, 0, 0, 0, 0, 0, {0}, 0, 0, {0}, {{0}}, 0};

EXTU int jn_sysex(const uint8_t *d, int32_t len) {
  struct jn_mailbox *q = &jn_mailbox;
  int32_t p, j;
  if (d[4] == 0x15) {
    uint8_t t, s;
    if (len < 13) return 1;
    t = OWNER(d[5] & 7);
    if (t >= 12 || MACHINE_OF(t) != JUNO_MACHINE) return 1;
    s = q->pend;   /* uint8: 128 15s between two UI ticks wrap it back to the taken value, and the last
                      patch then waits for the next 15 (accepted) */
    q->pend = ++s;               /* odd: writing (a seqlock, as us.wb's 1C; only this writes pend) */
    __asm__ __volatile__("" : "+d"(s) : : "memory");   /* the barrier; s kept in one register (2 B less) */
    for (j = 0; j < 6; ++j) q->val[j] = d[6 + j] & 0x7f;
    q->pend_track = t;
    JN_BARRIER();
    q->pend = ++s;               /* even: complete */
    return 1;
  }
  if ((d[4] != 0x16 && d[4] != 0x17) || len < 8) return 1;
  if (d[5]) {
    for (p = 0; p < 127; ++p) q->names[p][0] = 0;
    q->total = d[6] > 127 ? 127 : d[6];
    q->list = d[4] - 0x16;
    q->valid = 1;
  } else if (q->list != d[4] - 0x16) {
    return 1;   /* the rest of a list the cache no longer holds */
  }
  for (p = 7; p + 14 <= len - 1; p += 14) {
    char *n;
    if (d[p] > 126) continue;
    n = q->names[d[p]];
    for (j = 0; j < JN_NAME - 1 && d[p + 1 + j]; ++j) n[j] = (char)d[p + 1 + j];
    n[j] = 0;
  }
  return 1;
}

/* Every value text (UI task): the descriptors once, the user slots' tick, then 15's knobs. */
void us_tick(void);
__attribute__((section(".exto"), noinline)) void ext_ui_tick(void) {
  struct jn_mailbox *q = &jn_mailbox;
  uint32_t b[2];   /* pend_track, val[6], list: 8 B at +12 */
  const uint8_t *v = (const uint8_t *)b + 1;
  uint8_t seq, t;
  int k;
  if (!ext_desc_done) {
    ext_descriptors();
    fm_descriptors();
  }
  us_tick();   /* the user slots: commits, write-backs, asks */
  __asm__("" : "+a"(q));   /* q in a register: d16(An) accesses, shorter than absolute ones */
  seq = q->pend;
  if ((seq & 1) || seq == q->taken) return;   /* being written, or nothing new */
  JN_BARRIER();   /* the copy is not hoisted above the first read of pend */
  b[0] = ((const jn_u32 *)&q->pend_track)[0];   /* a seqlock read: one 15 whole, else the next tick */
  b[1] = ((const jn_u32 *)&q->pend_track)[1];   /* takes the newer */
  JN_BARRIER();
  if (q->pend != seq) return;
  q->taken = seq;
  t = v[-1];
  /* the track may have changed machine since 15 arrived (review 2026-10-09) */
  if (t >= 12 || MACHINE_OF(t) != JUNO_MACHINE) return;
  for (k = 0; k < 6; ++k) {
    us_set(t, 10 + k, REC_JN + 1 + k, (int32_t)v[k] << 8);   /* CUT..REL: records 383..388 */
  }
}

/* A value as a knob turn leaves it (R11): the live copy, then the kit word and the project's copy. */
__attribute__((section(".exto"), noinline)) void us_set(int32_t t, int32_t index, int32_t record, int32_t v) {
  SET_PARAM(v, t, index);
  US_COMMIT(US_BANK(), t, record, v);
}
#else   /* slots=0: the pre-slot JUNO mailbox and tick (c127fe8) */
#define KIT_WORD(t, k) ((volatile uint8_t *)(0x41255933u + 152u * (t) + 2u * (k)))
#define SET_PARAM    ((setp_fn)0x4011f3fau)
#define JN_NAME 10   /* 9 characters kept of the 13 sent (the knob shows ~8) */

int jn_sysex(const uint8_t *d, int32_t len);
struct jn_mailbox {
  uint32_t magic;                         /* 'JUNO': live */
  int (*hook)(const uint8_t *, int32_t);  /* 0022 calls it with 15 and 16 */
  uint8_t valid, total, wait, pend;       /* pend: 15's values wait for the UI */
  uint8_t pend_track, val[6], list;   /* list: the names' list, 0 JUNO 1 FM */
  uint8_t proj[16];                       /* the project the list is for */
  char names[127][JN_NAME];               /* lists are 127 slots at most */
};
struct jn_mailbox jn_mailbox EXTN = {0x4a554e4fu, jn_sysex, 0, 0, 0, 0, 0, {0}, 0, {0}, {{0}}};

EXTU int jn_sysex(const uint8_t *d, int32_t len) {
  struct jn_mailbox *q = &jn_mailbox;
  int32_t p, j;
  if (d[4] == 0x15) {
    uint8_t t;
    if (len < 13) return 1;
    t = OWNER(d[5] & 7);
    if (t >= 12 || MACHINE_OF(t) != JUNO_MACHINE) return 1;
    for (j = 0; j < 6; ++j) q->val[j] = d[6 + j] & 0x7f;
    q->pend_track = t;
    q->pend = 1;
    return 1;
  }
  if ((d[4] != 0x16 && d[4] != 0x17) || len < 8) return 1;
  if (d[5]) {
    for (p = 0; p < 127; ++p) q->names[p][0] = 0;
    q->total = d[6] > 127 ? 127 : d[6];
    q->list = d[4] - 0x16;
    q->valid = 1;
  } else if (q->list != d[4] - 0x16) {
    return 1;   /* the rest of a list the cache no longer holds */
  }
  for (p = 7; p + 14 <= len - 1; p += 14) {
    char *n;
    if (d[p] > 126) continue;
    n = q->names[d[p]];
    for (j = 0; j < JN_NAME - 1 && d[p + 1 + j]; ++j) n[j] = (char)d[p + 1 + j];
    n[j] = 0;
  }
  return 1;
}

/* Every value text (UI task): the descriptors once, then 15's knobs. */
__attribute__((section(".exto"), noinline)) void ext_ui_tick(void) {
  struct jn_mailbox *q = &jn_mailbox;
  int k;
  if (!ext_desc_done) {
    ext_descriptors();
    fm_descriptors();
  }
  if (!q->pend) return;
  q->pend = 0;
  /* the track may have changed machine since 15 arrived (review 2026-10-09) */
  if (q->pend_track >= 12 || MACHINE_OF(q->pend_track) != JUNO_MACHINE) return;
  for (k = 0; k < 6; ++k) {
    int32_t v = (int32_t)q->val[k] << 8;
    volatile uint8_t *w = KIT_WORD(q->pend_track, 1 + k);   /* CUT..REL: words 1..6 */
    w[0] = q->val[k];
    w[1] = 0;
    SET_PARAM(v, q->pend_track, 10 + k);
  }
}
#endif

/* PAT: the project's list entry (JUNO: 16, FM: 17; one cache, asked for with
   13 / 18 when it holds another list or project), else JUNO's factory patch
   (A11..B88) or FM's number. */
static const char jn_empty[] EXTK = "---";
EXTU static int32_t pat_text(void *functor, int32_t value, void *str, uint8_t list) {
  struct jn_mailbox *q = &jn_mailbox;
  int32_t p = value >> 8, k, same = q->list == list;
  for (k = 0; k < 16; ++k)
    if (q->proj[k] != PROJECT_NAME[k]) same = 0;
  if (!same) {
#if EXT_SLOTS   /* slots=0 stays c127fe8's image byte for byte */
    if (q->valid) q->wait = 0;   /* 1026: the cache was just taken by another list (FM's 17 after JUNO's 16 at a
                                    project load, a U slot's 1B): ask for ours at once, not after the throttle */
#endif
    q->valid = 0;
  }
  if (!q->valid) {
    if (q->wait) {
      --q->wait;
#if EXT_SLOTS
    } else if (ext_ui_lock()) {   /* never block the UI on a host that does not read: held from here */
#else
    } else if (usb_free(4)) {   /* never block the UI on a host that does not read */
#endif
      uint8_t m[22];
      int n = 5;
      m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x10;
      for (k = 0; k < 15 && PROJECT_NAME[k]; ++k) m[n++] = PROJECT_NAME[k] & 0x7f;
      m[n++] = 0xf7;
      for (k = 0; k < 16; ++k) q->proj[k] = PROJECT_NAME[k];
      q->wait = 200;
#if !EXT_SLOTS
      MIDI_LOCK();
#endif
      USB_MIDI_SEND(n, m);
      m[4] = list ? 0x18 : 0x13; m[5] = 0xf7;
      USB_MIDI_SEND(6, m);
      MIDI_UNLOCK();
    }
  } else if (q->total) {
    if (p < 0) p = 0;
    if (p >= q->total) p = q->total - 1;
    return STR_PRINTF(str, ext_fmt_s, q->names[p][0] ? q->names[p] : jn_empty);
  }
  if (list) return STR_PRINTF(str, fm_fmt_d, p);
  return jn_patch_text(functor, value, str);
}

EXTU int32_t jn_pat_text(void *functor, int32_t value, void *str) {
  return pat_text(functor, value, str, 0);
}

EXTU int32_t fm_pat_text(void *functor, int32_t value, void *str) {
  return pat_text(functor, value, str, 1);
}

/* ---------------------------------------------------------------------------
 * Diagnostic (2026-10-09, docs/REVIEW-2026-10-09.md fix 7), read-only, for the
 * first hardware runs: DSP SAMPLE's SMPL page (SD SAMPLE), knob C - DGN, word
 * 20, FLD until the pool list - shows one value per eighth of its range while
 * it turns (the knob's stored value only picks which; the word is otherwise
 * unused):
 *   T  the most DTIM2 counts any one ext_render call took since boot (or the
 *      last C): DTIM2's counter 0xfc07800c runs free on DTIN (the bootstrap
 *      sets DTMR 7; MAIN OS times a delay on it at 0x400055b2) [measured];
 *      DTIN 12.288 MHz [inferred], so one 32-sample block (0.667 ms) = 8192
 *   U  free USB requests (the sender's pool of 32: 27 when idle in rytm-emu)
 *   P  the play flag 0x405c8c90
 *   K  the selected track's first kit word in the active kit, KIT_WORD(t, 0) (SRC knob A)
 *   M  its machine byte, 0x8000ea00[t]
 *   R  the USB MIDI sender's ring fill 0x413db258
 *   S  the selected track 0x41318982
 *   C  clears T
 * Cost in the interrupt: two counter reads, a subtraction and a compare per
 * ext_render call.
 * ------------------------------------------------------------------------- */
#define DTIM2_COUNT (*(volatile uint32_t *)0xfc07800cu)
#define DIAG_TRACK (*(volatile uint8_t *)0x41318982u)
__attribute__((section(".exts"))) uint32_t ext_diag_max;
static const char diag_key[8] EXT3 = "TUPKMRSC";
static const char diag_fmt[] EXT3 = "%c%d";

__attribute__((section(".extw"), noinline)) void ext_render(int32_t voice, uint8_t *frame, const int16_t *params, int32_t pitch) {
  uint32_t t0 = DTIM2_COUNT, d;
  ext_render_body(voice, frame, params, pitch);
  d = DTIM2_COUNT - t0;
  if (d > ext_diag_max) ext_diag_max = d;
}

__attribute__((section(".extq"), noinline)) static int32_t diag_text(void *functor, int32_t value, void *str) {
  int32_t i = (value >> 12) & 7, v, t = DIAG_TRACK;
  (void)functor;
  if (t > 11) t = 0;
  if (i == 0) v = (int32_t)ext_diag_max;
  else if (i == 1) for (v = 0; v < 40 && usb_free(v + 1); ++v) ;
  else if (i == 2) v = PLAYING;
  else if (i == 3) v = *KIT_WORD(t, 0);
  else if (i == 4) v = MACHINE_OF(t);
  else if (i == 5) v = (int32_t)RING_FILL;
  else if (i == 6) v = t;
  else v = (int32_t)(ext_diag_max = 0);
  return STR_PRINTF(str, diag_fmt, diag_key[i], v);
}

__attribute__((section(".extq"), noinline)) void diag_desc(void) {
  copy_desc(REC_DSPS2 + 3, REC_DIAL);
  DESC(REC_DSPS2 + 3)[8] = (uint32_t)diag_text;
}

/* ---------------------------------------------------------------------------
 * MOD (2026-10-09; the normal builds, diag = 0): word 20 on DSP SAMPLE's SMPL
 * page picks the host's playback mode when it has PSRAM (rytm-teensy
 * docs/psram.md): ONE LOOP SLICE GRAIN STRCH PLUCK WAVE in seven zones, zone =
 * value x 7 / 128 as the host decodes it; MOD 0 (ONE) is the plain voice. Its
 * value text also names STA END LOP (records 445..447, words 21..23) for the
 * mode, as DIGIDRUM's ENG names its knobs (long and short name alike).
 * ------------------------------------------------------------------------- */
#define EXTX __attribute__((section(".exto"), noinline))
static const char mod_names[7][6] __attribute__((section(".ext3"))) = {
    "ONE", "LOOP", "SLICE", "GRAIN", "STRCH", "PLUCK", "WAVE"};
static const char mod_pool[11][4] __attribute__((section(".ext8"))) = {
    "STA", "END", "LOP", "SLC", "POS", "SIZ", "DNS", "SPD", "DEC", "BRI", "CYC"};   /* 11: "---" */
static const uint8_t mod_label[7][3] __attribute__((section(".extg"))) = {
    {0, 1, 2}, {0, 1, 2}, {0, 1, 3}, {4, 5, 6}, {0, 1, 7}, {0, 8, 9}, {4, 11, 10}};
static const char mod_long[] __attribute__((section(".extg"))) = "Mode";
static const char mod_short[] __attribute__((section(".extg"))) = "MOD";

EXTX static int32_t mod_text(void *functor, int32_t value, void *str) {
  int32_t i = (value * 7) >> 15, k;
  (void)functor;
  if (i < 0) i = 0;
  if (i > 6) i = 6;
  for (k = 0; k < 3; ++k) {
    uint32_t *r = (uint32_t *)REC_ADDR(REC_DSPS2 + 4 + k);
    uint8_t l = mod_label[i][k];
    r[10] = r[12] = (uint32_t)(l < 11 ? mod_pool[l] : jn_empty);
  }
  return STR_PRINTF(str, ext_fmt_s, mod_names[i]);
}

EXTX void mod_desc(void) {
  uint32_t *r = (uint32_t *)REC_ADDR(REC_DSPS2 + 3);
  copy_desc(REC_DSPS2 + 3, REC_DIAL);
  DESC(REC_DSPS2 + 3)[8] = (uint32_t)mod_text;
  r[10] = (uint32_t)mod_long;
  r[12] = (uint32_t)mod_short;
}


#if EXT_SLOTS   /* build param slots (mod.toml): 0 leaves out everything below */
/* ---------------------------------------------------------------------------
 * User slots (2026-10-10; rytm-teensy docs/superpowers/specs/2026-10-10-user-slots-rytm-design.md):
 * machines 35..39 (the hidden "2" variants) are U1..U5, machine plugins on the Teensy (voice flags
 * 0x50..0x70). Their names, knob labels, looks, ranges and value texts come from the Teensy at
 * runtime (1A metadata, 1B lists), knob write-backs as 1C, slot changes as 1D; the Rytm asks with 19
 * and assigns with 1E (rytm-teensy sim/protocol.py). Sections: .us1 the voice flag, descriptors,
 * value text, page 2; .us2 the Teensy's messages and the UI tick; .us3 the slot menu; .us4 its items,
 * popup and thunks; .us5 the machine choice's hooks; .us6 the sound tag (us_defaults, us_tick3, us_names); .usd
 * constant data; .usr RAM (zero but the name buffers). mods/0021-ext/user-slots-research.md has the findings
 * (R0..R15) this code relies on, sound-tag-research.md the tag's.
 * ------------------------------------------------------------------------- */
#define US1 __attribute__((section(".us1"), noinline))
#define US2 __attribute__((section(".us2"), noinline))
#define US3 __attribute__((section(".us3"), noinline))
#define US4 __attribute__((section(".us4"), noinline))
#define US5 __attribute__((section(".us5"), noinline))
#define US6 __attribute__((section(".us6"), noinline))   /* cave2 (0004-lfo-rnd's; 0021 excludes 0004): the sound tag */
#define US8 __attribute__((section(".us8"), noinline))   /* cave7's rest (0010-kit-ab's; 0021 excludes it): us_pend, us_untag */
#define UST __attribute__((section(".ust"), noinline))   /* 0002-euclid-accents' block (0021 excludes 0002): the tag's load/save/copy hooks */
#define USD __attribute__((section(".usd")))
#define USR __attribute__((section(".usr")))
#define US_FIRST 35            /* U1 = machine 35 .. U5 = 39 */
#define US_REC 334             /* U(s+1)'s knob k (0..7) is record 334 + 8 s + k */
#define US_SLOTS 5
#define US_SEL_TRACK (*(volatile uint8_t *)0x41318982u)
#define US_NEW ((void *(*)(uint32_t))0x400829d4u)
#define US_SLEEP ((void (*)(uint32_t))0x40098c18u)
/* R1: every caller of a record's value text passes the record's descriptor + 20 as the functor
   (US_THUNKS 0); 1: it does not, and each record gets a thunk that puts its own functor in.
   [measured, research R1: knob and p-lock paths and the machine list's preview pass descriptor + 20] */
#define US_THUNKS 0
/* R3: the sound's sample words follow its machine words in the kit (track t's word 9 + k at
   0x41255933 + 152 t + 2 k for k 0..15, in kit 0; kit n 2531 n further) and 0x4011f3fa takes their sound
   indices 9 + k. */
/* [measured, research R3: SMPL word 17 at kit + 16 a track, the setter's index 17] */
#define US_INDEX(k) (9 + (k))

/* What 1A says about a slot, and a knob (by P: k[p - 1]; p 0 = no such knob). */
struct us_knob { uint8_t p, look, kind, role, min, max, def, ne; char lng[13]; char sht[5]; uint8_t pad[2]; };
struct us_head { uint8_t gen, state, flags, nk; char name[11], sht[5], title[14]; uint16_t fp; };   /* fp: 1A part 0's */
/* A slot's cache (from the firmware's allocator in the UI task, 1524 B - the allocator rounds it to
   2048, 10 KB for the five; it does not clear it, us_init does): the committed 1A and up to eight enum
   lists (1B list k: P(k+1)'s names; a ninth is dropped and not asked for). */
struct us_cache {
  struct us_head h;
  struct us_knob k[16];
  uint8_t eknob[8], ecount[8];   /* which P index each enum list is for (0xff free), its count */
  char en[8][16][8];
};
/* 1A parts of one slot and generation, assembled in the MIDI task; got 0xff: complete, the UI task
   commits it (until then another part 0 is dropped: the Rytm asks again). */
struct us_stage { uint8_t slot, gen, nparts, got; struct us_head h; struct us_knob k[16]; };
/* A track's pending 1C, handed from the MIDI task (the only writer of slot, mask, v and wseq) to the
   UI task (the only writer of rseq) without a lock: wseq is odd while us_knobs_in writes, and moves
   on by 2 with each 1C; the UI copies slot, mask and values when wseq is even and not yet taken
   (rseq), and uses the copy only when wseq did not move meanwhile (else the next tick copies again):
   a seqlock, so a 1C's values are never applied under another 1C's slot. */
struct us_wb { uint8_t slot, wseq, rseq, pslot; uint16_t mask; uint8_t v[16]; uint8_t pgen, pad; uint32_t ptime; };
/* pslot, ptime (UI task, but us_loaded - also from the audio interrupt - clears pslot): the track was given slot pslot (1..5) by the user (the
   machine list's YES, the SOUND menu's MACHINE, the slot menu's assign) at audio block ptime (US_NOW); its
   defaults go in at the first UI tick that sees the slot's 1A current, if within US_PEND_WINDOW of the
   choice, no kit or project loaded since (us_loaded) and the track still plays the slot (us_tick3). pgen (UI task):
   for a slot menu assign, the slot's cache generation when the answer came - the defaults wait for another one;
   0 for the machine list and the SOUND menu (us_pend). */
struct us_ram {
  struct us_cache *c[US_SLOTS];
  struct us_stage *st;
  struct us_wb *wb;                      /* 12, one a track */
  uint8_t tgen[US_SLOTS], tinst, seen;   /* the Teensy's generations from 1D (seen: one arrived) */
  uint8_t wait[US_SLOTS], gap;           /* ask throttles, in UI ticks */
  uint8_t layer[US_SLOTS];               /* the voice's sample layer plays (page 2 is the sample) */
  uint8_t ans_slot, ans_res;             /* a 1D's answer to a 1E */
  uint8_t p2_slot, p2_gen, done;         /* page 2's shared records are set up for p2_slot (1..5) */
  uint8_t ch;                            /* the machine list previewed a machine on track ch - 1 (0: none) */
  uint8_t lgen;                          /* loads seen: us_loaded moves it on, us_tick3 checks it did not move */
  uint8_t mm;                            /* slot mm - 1 shows !NAME: the selected track's sound tag is not its fp */
  uint8_t ifail;                         /* the slot menu's last YES was slot ifail - 1's install, and it failed */
};
struct us_ram us USR __attribute__((aligned(4)));   /* pointers: 4-aligned (the cave starts so) */
/* Offsets the emulator tests read (tools/emu/us_emu.py: sym("us") + sym("us_off_...")), absolute symbols. */
_Static_assert(__builtin_offsetof(struct us_ram, tgen) == 28 && __builtin_offsetof(struct us_ram, layer) == 41 &&
               __builtin_offsetof(struct us_ram, ch) == 51 && __builtin_offsetof(struct us_ram, wb) == 24 &&
               __builtin_offsetof(struct us_wb, pslot) == 3 && __builtin_offsetof(struct us_wb, pgen) == 22 && sizeof(struct us_wb) == 28 &&
               __builtin_offsetof(struct us_cache, en) == 500,
               "us_ram's layout: update the offsets below");
__asm__(".globl us_off_tgen\n.set us_off_tgen, 28\n.globl us_off_layer\n.set us_off_layer, 41\n"
        ".globl us_off_ch\n.set us_off_ch, 51\n.globl us_off_wb\n.set us_off_wb, 24\n"
        ".globl us_wb_pslot\n.set us_wb_pslot, 3\n.globl us_wb_pgen\n.set us_wb_pgen, 22\n.globl us_wb_size\n.set us_wb_size, 28\n"
        ".globl us_off_en\n.set us_off_en, 500\n");
/* The machine list's names (0x401befa4 + 8 m points here): rewritten in the UI task, whole names. */
char us_l1[12] USR = "USER 1";
char us_l2[12] USR = "USER 2";
char us_l3[12] USR = "USER 3";
char us_l4[12] USR = "USER 4";
char us_l5[12] USR = "USER 5";
char us_s1[5] USR = "U1";
char us_s2[5] USR = "U2";
char us_s3[5] USR = "U3";
char us_s4[5] USR = "U4";
char us_s5[5] USR = "U5";
static char *const us_lnames[US_SLOTS] USD __attribute__((aligned(4))) = {us_l1, us_l2, us_l3, us_l4, us_l5};
static char *const us_snames[US_SLOTS] USD __attribute__((aligned(4))) = {us_s1, us_s2, us_s3, us_s4, us_s5};
/* Page 2's shared records (R2: read nowhere else by number): P9..P16 of whichever slot's page draws. */
static const int16_t us_p2rec[8] USD = {438, 457, 458, 459, 460, 403, 404, 405};
static const int16_t us_look_rec[4] USD = {REC_DIAL, REC_BIPOLAR, REC_LEVEL, REC_DIAL};   /* dial centred fader list */
static const char us_pn[16][4] USD = {"P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8",
                                      "P9", "P10", "P11", "P12", "P13", "P14", "P15", "P16"};
static const char us_notes[12][3] USD = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"};
static const char us_fmt_d[] USD = "%d";
static const char us_fmt_pd[] USD = "+%d";
static const char us_fmt_note[] USD = "%s%d";
static const char us_fmt_user[] USD = "USER %d";
static const char us_fmt_u[] USD = "U%d";
static const char us_fmt_empty[] USD = "USER %d ---";
static const char us_fmt_uempty[] USD = "U%d--";
static const char us_off[] USD = "OFF";
static const char us_none[] USD = "---";
/* The voice byte's machine flag of machines 35..51 (ext_render's machines; 0 for the others). */
static const uint8_t us_flag_tab[17] USD = {0x50, 0x58, 0x60, 0x68, 0x70, 0x48, 0x08, 0x40, 0, 0x00, 0x20,
                                            0, 0, 0, 0, 0, 0x10};

US1 int32_t ext_vflag(int32_t m) { return (uint32_t)(m - US_FIRST) < 17u ? us_flag_tab[m - US_FIRST] : 0; }
/* The voice's sample layer plays: DIGIDRUM, or a user slot whose page 2 is the sample (READY). */
US1 int32_t ext_layer_kept(int32_t vb) {
  int32_t m = vb & 0x78;
  if (m == 0x40) return 1;
  if (m >= 0x50 && m <= 0x70) return us.layer[(m - 0x50) >> 3];
  return 0;
}

US1 static void us_copy(void *dst, const void *src, int32_t n) {
  uint8_t *d = dst;
  const uint8_t *s = src;
  while (n-- > 0) *d++ = *s++;
}
/* n bytes of zero (n <= 0: nothing). */
US1 static void us_zero(void *dst, int32_t n) {
  uint8_t *d = dst;
  while (n-- > 0) *d++ = 0;
}
/* n bytes of text from a message, NUL-terminated (dst holds n + 1). */
US1 static void us_text_in(char *dst, const uint8_t *src, int32_t n) {
  int32_t i;
  for (i = 0; i < n && src[i]; ++i) dst[i] = (char)src[i];
  dst[i] = 0;
}

/* The slot (0..4) and knob (0..15) of a parameter record; -1 for another record. Page 2's records
   belong to the selected track's machine. */
US1 static int32_t us_which(int32_t r, int32_t *knob) {
  int32_t i, m;
  if (r >= US_REC && r < US_REC + 8 * US_SLOTS) {
    *knob = (r - US_REC) & 7;
    return (r - US_REC) >> 3;
  }
  for (i = 0; i < 8; ++i)
    if (us_p2rec[i] == r) {
      *knob = 8 + i;
      m = MACHINE_OF(US_SEL_TRACK > 11 ? 0 : US_SEL_TRACK) - US_FIRST;
      return (uint32_t)m < US_SLOTS ? m : -1;
    }
  return -1;
}
static int32_t us_ask(int32_t slot, int32_t gen, int32_t what, int32_t arg);
void us_tick3(void);
void us_fetch(int32_t s);
US1 static int32_t us_preset_text(int32_t s, int32_t v, void *str) {
  struct jn_mailbox *q = &jn_mailbox;
  struct us_cache *c = us.c[s];
  int32_t mine = c && q->valid && q->list == 0x11 + s && q->lgen == c->h.gen;
  if (mine) {
    if (!q->total) return STR_PRINTF(str, ext_fmt_s, us_none);
    if (v >= q->total) v = q->total - 1;
    if (q->names[v][0]) return STR_PRINTF(str, ext_fmt_s, q->names[v]);
  }
  /* not in the one-list cache (or that page not yet): asked for, throttled; page 0 replaces the cache */
  if (c && !us.gap && !us.wait[s] && us_ask(s + 1, c->h.gen, 2, mine ? v >> 4 : 0)) {
    us.gap = 10;
    us.wait[s] = 50;
  }
  return STR_PRINTF(str, us_fmt_d, v);
}
/* A pool knob: pool slot v's name from 0023's table (its mailbox's third word, td_pool_tab), OFF for 0;
   the number when 0023 is not in the image. */
US1 static int32_t us_pool_text(int32_t v, void *str) {
  const volatile uint32_t *mb = (const volatile uint32_t *)0x401b9a74u;
  const char *t;
  if (!v) return STR_PRINTF(str, ext_fmt_s, us_off);
  if (mb[0] == 0x54445256u && mb[2] && (t = (const char *)((void *(*)(void))mb[2])()) != 0)
    return STR_PRINTF(str, ext_fmt_s, t[18 * v + 4] ? t + 18 * v + 4 : us_none);
  return STR_PRINTF(str, us_fmt_d, v);
}
/* Every user-slot record's value text (functor = the record's descriptor + 20, R1). */
US1 int32_t us_text(void *functor, int32_t value, void *str) {
  int32_t r = ((int32_t)functor - 20 - 0x419a4888) / 84, k = 0, v = value >> 8, s = us_which(r, &k), e, n, i;
  char t[8];
  const char *nm;
  struct us_cache *c = s >= 0 ? us.c[s] : 0;
  const struct us_knob *q = c && c->h.gen && c->k[k].p ? &c->k[k] : 0;
  if (v < 0) v = 0;
  if (v > 127) v = 127;
  if (!q) return STR_PRINTF(str, us_fmt_d, v);
  switch (q->kind) {
    case 1:   /* bipolar */
      return STR_PRINTF(str, v > 64 ? us_fmt_pd : us_fmt_d, v - 64);
    case 2:   /* enum: equal zones over 0..127 */
      for (e = 0; e < 8 && c->eknob[e] != k; ++e) ;
      n = e < 8 ? c->ecount[e] : 0;
      if (!n) break;
      n = (v * n) >> 7 < n - 1 ? (v * n) >> 7 : n - 1;
      nm = c->en[e][n];   /* at most 7 characters, whatever the cache holds; --- for a name not sent */
      for (i = 0; i < 7 && nm[i]; ++i) t[i] = nm[i];
      t[i] = 0;
      return STR_PRINTF(str, ext_fmt_s, i ? t : us_none);
    case 4:   /* note: C-1..G9 */
      return STR_PRINTF(str, us_fmt_note, us_notes[v % 12], v / 12 - 1);
    case 6:
      return us_preset_text(s, v, str);
    case 7:
      return us_pool_text(v, str);
    default:
      break;
  }
  return STR_PRINTF(str, us_fmt_d, v);
}
#if US_THUNKS
/* R1's alternative: 48 thunks, one a record (40 SRC, 8 page 2), each replacing the functor argument
   with its own record's descriptor + 20 and going on in us_text; 12 bytes each. */
__asm__(
    "  .section .us1,\"ax\"\n"
    "  .globl us_thunks\n"
    "us_thunks:\n"
    "  .irp r,334,335,336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,"
    "358,359,360,361,362,363,364,365,366,367,368,369,370,371,372,373,438,457,458,459,460,403,404,405\n"
    "  movel #(0x419a4888 + 84 * \\r + 20),%sp@(4)\n"
    "  braw us_text\n"
    "  .endr\n");
extern const uint8_t us_thunks[];
#define US_INVOKER(i) ((uint32_t)us_thunks + 12u * (uint32_t)(i))
#else
#define US_INVOKER(i) ((uint32_t)us_text)
#endif

/* 1026: knob k (0..15) of a slot is unused once its 1A is in and does not name it (no P k + 1 in any part, or an entry
   with an empty long name, as the host sends for the P its manifest lacks): it shows
   as stock's unused box (record 0, as stock machines with fewer knobs have in the machine table) and its turn does
   nothing. Before any 1A it stays P<n>. */
/* Record r as slot s's knob k (inv: its value text's invoker, US_INVOKER of its index among the 48): the look's
   descriptor, the value text, the names and the range from the cache (or P<n>, 0..127 with 64) - the OS image runs
   from RAM, as dd_name_knobs' writes show. */
US1 static void us_record(int32_t r, int32_t s, int32_t k, uint32_t inv) {
  struct us_cache *c = us.c[s];
  const struct us_knob *q = c && c->h.gen && c->k[k].p ? &c->k[k] : 0;
  uint32_t *rec = (uint32_t *)REC_ADDR(r);
  copy_desc(r, us_look_rec[q ? q->look & 3 : 0]);
  DESC(r)[8] = inv;
  rec[10] = (uint32_t)(q ? q->lng : us_pn[k]);
  rec[11] = (uint32_t)us_snames[s];
  rec[12] = (uint32_t)(q ? q->sht : us_pn[k]);
  rec[2] = (uint32_t)(q ? q->min : 0) << 8;
  rec[3] = (uint32_t)(q ? q->max : 127) << 8;
  rec[4] = (uint32_t)(q ? q->def : 64) << 8;
}
/* SRC: U(s+1)'s records in the machine page table (0x40287cc8 + 36 m: name, 8 records; machine_page_info
   0x400ff59a, what the SRC view draws and its knobs edit [code, 0x400d3544]): 334 + 8 s + k, or 0 for an unused knob,
   as stock machines with fewer knobs have [measured: zero entries for machines 0..34]. */
_Static_assert(__builtin_offsetof(struct us_cache, k) == 36 && sizeof(struct us_knob) == 28 && __builtin_offsetof(struct us_head, state) == 1 &&
               __builtin_offsetof(struct us_knob, lng) == 8, "us_src_table");
void us_src_table(int32_t s);   /* in .us3 (asm: gcc's -Os loop was twice the size; .us3 has the room) */
__asm__(
    "  .section .us3,\"ax\"\n"
    "  .globl us_src_table\n"
    "  .align 2\n"
    "us_src_table:\n"
    "  move.l 4(%sp),%d0\n"
    "  lea us,%a1\n"
    "  move.l (%a1,%d0.l*4),%a1\n"     /* c = us.c[s] (0: no cache) */
    "  move.l %d0,%d1\n"
    "  lsl.l #3,%d1\n"
    "  add.l #334,%d1\n"               /* r = US_REC + 8 s */
    "  mulu.w #36,%d0\n"
    "  add.l #0x40287ccc+36*35,%d0\n"
    "  move.l %d0,%a0\n"               /* the machine's 8 records */
    "  tst.l %a1\n"
    "  jeq 2f\n"
    "  moveq #1,%d0\n"
    "  cmp.b 1(%a1),%d0\n"             /* h.state 1 READY (h.gen 0: no 1A yet; MISSING etc.: no knobs): else P<n> */
    "  jne 3f\n"
    "  lea 36(%a1),%a1\n"              /* q = c->k (28 B each, p first) */
    "  jra 2f\n"
    "3: sub.l %a1,%a1\n"
    "2: moveq #8,%d0\n"
    "1: move.l %d1,(%a0)\n"
    "  tst.l %a1\n"
    "  jeq 4f\n"
    "  tst.b (%a1)\n"
    "  jeq 6f\n"
    "  tst.b 8(%a1)\n"                 /* lng[0]: named */
    "  jne 5f\n"
    "6: clr.l (%a0)\n"                 /* not in the 1A, or no name: unused, record 0 */
    "5: lea 28(%a1),%a1\n"
    "4: addq.l #4,%a0\n"
    "  addq.l #1,%d1\n"
    "  subq.l #1,%d0\n"
    "  jne 1b\n"
    "  rts\n");
US1 static void us_slot_records(int32_t s) {
  int32_t k;
  for (k = 0; k < 8; ++k) us_record(US_REC + 8 * s + k, s, k, US_INVOKER(8 * s + k));
  us_src_table(s);
}
US1 static int32_t us_params(int32_t s) {   /* slot s's page 2 is knobs (P9..P16) */
  struct us_cache *c = us.c[s];
  return c && c->h.gen && c->h.state == 1 && (c->h.flags & 1);
}
/* Page 2's lookups (ext_page_record, ext_page_title, ext_param_record in .ext4 call these): PLAITS,
   DAISYSP and DSP SAMPLE as before, and a user slot whose page 2 is knobs - the eight shared records,
   set up for the slot when its page draws. 0: stock's. */
US1 int32_t us_page_record(int32_t m, uint32_t k) {
  struct us_cache *c;
  int32_t j, s = m - US_FIRST;
  if (m == EXT_MACHINE) return ext_p2_order[k];
  if (m == DSP_MACHINE) return dsp_p2_order[k];
  if (m == DSPS_MACHINE) return dsps_p2_order[k];
  if ((uint32_t)s >= US_SLOTS || !us_params(s)) return 0;
  c = us.c[s];
  if (us.p2_slot != s + 1 || us.p2_gen != c->h.gen) {
    for (j = 0; j < 8; ++j) us_record(us_p2rec[j], s, 8 + j, US_INVOKER(40 + j));
    us.p2_slot = (uint8_t)(s + 1);
    us.p2_gen = c->h.gen;
  }
  return c->k[8 + k].p && c->k[8 + k].lng[0] ? us_p2rec[k] : -1;   /* -1: unused (ext_page_record: record 0) */
}
US1 int32_t us_page_title(int32_t m) {
  int32_t s = m - US_FIRST;
  if (m == EXT_MACHINE) return (int32_t)ext_p2_title;
  if (m == DSP_MACHINE) return (int32_t)dsp_p2_title;
  if (m == DSPS_MACHINE) return (int32_t)dsps_p2_title;
  if ((uint32_t)s >= US_SLOTS || !us_params(s)) return 0;
  return (int32_t)(us.c[s]->h.title[0] ? us.c[s]->h.title : us.c[s]->h.name);
}
US1 int32_t us_param_record(uint32_t index, uint32_t machine) {   /* a sample word, index 17..24 */
  int32_t j = (int32_t)index - 17, s = (int32_t)machine - US_FIRST;
  if (machine == EXT_MACHINE) return REC_P2 + j;
  if (machine == DSP_MACHINE) return REC_DSP2 + j;
  if (machine == DSPS_MACHINE) return REC_DSPS2 + j;
  if ((uint32_t)s < US_SLOTS && us_params(s)) return us_p2rec[j];
  return 39 + j;
}

/* ---- the Teensy's messages (MIDI task, from 0022's router through the 'JUNO' mailbox) ---- */
US2 static void us_meta_in(const uint8_t *d, int32_t len) {   /* 1A */
  struct us_stage *st = us.st;
  int32_t s = d[6] - 1, gen = d[7], part = d[8], i;
  if (!st || (uint32_t)s >= US_SLOTS || st->got == 0xff) return;   /* no buffer yet, or a commit pending */
  if (part == 0x7f) return;                                         /* unchanged: the cache is current */
  if (part == 0) {
    if (len < 41 || d[12] < 1 || d[12] > 5) return;
    st->slot = (uint8_t)(s + 1); st->gen = (uint8_t)gen; st->nparts = d[12]; st->got = 1;
    st->h.gen = (uint8_t)gen; st->h.state = d[9]; st->h.flags = d[10]; st->h.nk = d[11];
    us_text_in(st->h.name, d + 13, 10);
    us_text_in(st->h.sht, d + 23, 4);
    us_text_in(st->h.title, d + 27, 13);
    st->h.fp = len >= 43 ? (uint16_t)((d[40] & 0x7f) << 7 | (d[41] & 0x7f)) : 0;   /* an older Teensy: untagged */
    for (i = 0; i < 16; ++i) st->k[i].p = 0;
  } else {
    if (st->slot != s + 1 || st->gen != gen || !(st->got & 1) || part >= st->nparts) return;
    if (len <= 10 || (len - 10) % 24) return;   /* whole 24-byte knob entries only (a short part: dropped, asked again) */
    for (i = 9; i + 24 <= len - 1; i += 24) {
      const uint8_t *e = d + i;
      struct us_knob *q;
      if (e[0] < 1 || e[0] > 16) continue;
      q = &st->k[e[0] - 1];
      q->p = e[0]; q->look = e[1]; q->kind = e[2]; q->role = e[3];
      q->min = e[4]; q->max = e[5] < e[4] ? e[4] : e[5]; q->def = e[6]; q->ne = e[7] > 16 ? 16 : e[7];
      us_text_in(q->lng, e + 8, 12);
      us_text_in(q->sht, e + 20, 4);
    }
    st->got |= (uint8_t)(1u << part);
  }
  if (st->got == (uint8_t)((1u << st->nparts) - 1)) st->got = 0xff;   /* every part: the UI task commits */
}
US2 static void us_list_in(const uint8_t *d, int32_t len) {   /* 1B */
  struct jn_mailbox *q = &jn_mailbox;
  int32_t s = d[6] - 1, lst = d[7], gen = d[8], p, j, e;
  uint8_t key;
  if (len < 12) return;
  if (lst < 16) {   /* P(lst+1)'s enum names: into the slot's cache, for its current generation */
    struct us_cache *c = (uint32_t)s < US_SLOTS ? us.c[s] : 0;
    if (!c || c->h.gen != gen) return;
    for (e = 0; e < 8 && c->eknob[e] != lst; ++e) ;
    if (e == 8) {
      if (!d[9]) return;   /* the rest of a list the cache does not hold */
      for (e = 0; e < 8 && c->eknob[e] != 0xff; ++e) ;
      if (e == 8) return;   /* eight lists held: dropped (us_tick does not ask for a ninth) */
    }
    if (d[9]) {   /* a list starts: names not (yet) sent read --- */
      us_zero(c->en[e], sizeof c->en[e]);
      c->ecount[e] = d[10] > 16 ? 16 : d[10];
      c->eknob[e] = (uint8_t)lst;
    }
    for (p = 11; p + 14 <= len - 1; p += 14) {
      char *n;
      if (d[p] > 15) continue;
      n = c->en[e][d[p]];
      for (j = 0; j < 7 && d[p + 1 + j]; ++j) n[j] = (char)d[p + 1 + j];
      n[j] = 0;
    }
    /* us_commit (UI task) may have replaced the slot's 1A while these were written: names of the old machine in a
       list of the new one - freed, asked for again */
    if (*(volatile uint8_t *)&c->h.gen != gen) c->eknob[e] = 0xff;
    return;
  }
  /* a slot's presets (0x20) and the installed machines (0x21): the one-list cache, keyed */
  key = lst == 0x21 ? 0x20 : (lst == 0x20 && (uint32_t)s < US_SLOTS) ? (uint8_t)(0x11 + s) : 0;
  if (!key) return;
  if (d[9]) {
    for (p = 0; p < 127; ++p) q->names[p][0] = 0;
    q->total = d[10] > 127 ? 127 : d[10];
    q->list = key;
    q->lgen = (uint8_t)gen;
    q->valid = 1;
  } else if (q->list != key || q->lgen != gen) {
    return;   /* the rest of a list the cache no longer holds */
  }
  for (p = 11; p + 14 <= len - 1; p += 14) {
    char *n;
    if (d[p] > 126) continue;
    n = q->names[d[p]];
    for (j = 0; j < JN_NAME - 1 && d[p + 1 + j]; ++j) n[j] = (char)d[p + 1 + j];
    n[j] = 0;
  }
}
US2 static void us_knobs_in(const uint8_t *d, int32_t len) {   /* 1C: noted for the voice's owner track */
  int32_t t = OWNER(d[6] & 7), slot = d[7], n = d[8], i;
  volatile struct us_wb *w = us.wb;
  uint32_t mask = 0;
  if (!w || t >= 12 || slot < 1 || slot > US_SLOTS || n > 16 || len < 10 + 2 * n) return;
  w += t;
  w->wseq = (uint8_t)(w->wseq | 1);   /* writing (a later 1C for the track replaces what is still pending) */
  w->slot = (uint8_t)slot;
  for (i = 0; i < n; ++i) {
    int32_t k = d[9 + 2 * i] & 15;
    w->v[k] = d[10 + 2 * i] & 0x7f;
    mask |= 1u << k;
  }
  w->mask = (uint16_t)mask;
  w->wseq = (uint8_t)(w->wseq + 1);   /* even: complete */
}
US2 static void us_slots_in(const uint8_t *d, int32_t len) {   /* 1D */
  int32_t s;
  if (len < 13) return;
  for (s = 0; s < US_SLOTS; ++s) us.tgen[s] = d[6 + s];
  us.tinst = d[11];
  us.seen = 1;
  if (len >= 15 && d[12] >= 1 && d[12] <= US_SLOTS) {   /* the answer to a 1E (the menu waits for it) */
    us.ans_res = d[13];
    us.ans_slot = d[12];
  }
}
/* The 'JUNO' mailbox's hook (0022's router passes 15..1D): JUNO's and FM's 15..17 as before, the user
   slots' 1A..1D (version 1; another version is ignored). */
US2 int us_sysex(const uint8_t *d, int32_t len) {
  if (d[4] <= 0x17) return jn_sysex(d, len);
  if (len < 8 || d[5] != 1) return 1;
  if (d[4] == 0x1a) us_meta_in(d, len);
  else if (d[4] == 0x1b) us_list_in(d, len);
  else if (d[4] == 0x1c) us_knobs_in(d, len);
  else if (d[4] == 0x1d) us_slots_in(d, len);
  return 1;
}

/* ---- the UI task (us_tick, from ext_ui_tick on every value text) ---- */
int ext_ui_lock(void);
US2 static int32_t us_send(const uint8_t *m, int32_t n) {
  if (!ext_ui_lock()) return 0;   /* not now: the caller asks again */
  USB_MIDI_SEND(n, m);
  MIDI_UNLOCK();
  return 1;
}
/* 19 ASK, when the USB request pool allows it (never blocks the UI on a host that does not read). */
US2 static int32_t us_ask(int32_t slot, int32_t gen, int32_t what, int32_t arg) {
  uint8_t m[11] = {0xf0, 0x7d, 0x52, 0x54, 0x19, 1, (uint8_t)slot, (uint8_t)gen, (uint8_t)what, (uint8_t)arg, 0xf7};
  return us_send(m, 11);
}
/* Slot s's names in the machine list, from what the Teensy said: USER n (nothing yet), USER n --- (EMPTY),
   the machine's name (READY), ! and the name otherwise - also READY while the selected track on the slot plays a
   sound tagged for another plugin (us.mm, us_tick3). */
US6 static void us_names(int32_t s) {
  char *l = us_lnames[s], *sh = us_snames[s];
  const struct us_cache *c = us.c[s];
  int32_t i;
  if (!c || !c->h.gen) {
    STR_PRINTF(l, us_fmt_user, s + 1);
    STR_PRINTF(sh, us_fmt_u, s + 1);
  } else if (c->h.state == 0) {
    STR_PRINTF(l, us_fmt_empty, s + 1);
    STR_PRINTF(sh, us_fmt_uempty, s + 1);
  } else if (c->h.state == 1 && us.mm != s + 1) {
    for (i = 0; i < 10 && c->h.name[i]; ++i) l[i] = c->h.name[i];
    l[i] = 0;
    for (i = 0; i < 4 && c->h.sht[i]; ++i) sh[i] = c->h.sht[i];
    sh[i] = 0;
  } else {
    l[0] = sh[0] = '!';
    for (i = 0; i < 10 && c->h.name[i]; ++i) l[1 + i] = c->h.name[i];
    l[1 + i] = 0;
    for (i = 0; i < 3 && c->h.sht[i]; ++i) sh[1 + i] = c->h.sht[i];
    sh[1 + i] = 0;
  }
}
/* Once: the caches, the staging buffer and the write-backs from the firmware's allocator (a slot without
   a cache shows USER n and numbers), and the 40 records' first looks. */
US2 static void us_init(void) {
  int32_t s, e;
  struct us_stage *st;
  struct us_wb *wb;
  us.done = 1;
  /* the allocator does not clear: each buffer is zeroed before us.st / us.wb publish it to the MIDI task */
  st = (struct us_stage *)US_NEW(sizeof(struct us_stage));
  if (st) us_zero(st, sizeof(struct us_stage));
  us.st = st;
  wb = (struct us_wb *)US_NEW(12 * sizeof(struct us_wb));
  if (wb) us_zero(wb, 12 * sizeof(struct us_wb));
  us.wb = wb;
  for (s = 0; s < US_SLOTS; ++s) {
    struct us_cache *c = (struct us_cache *)US_NEW(sizeof(struct us_cache));
    if (c) {
      us_zero(c, sizeof(struct us_cache));
      for (e = 0; e < 8; ++e) c->eknob[e] = 0xff;
    }
    us.c[s] = c;
    us_slot_records(s);
  }
}
/* A complete 1A into the slot's cache: names, records and looks rewritten; its enum names asked anew. */
US2 static void us_commit(void) {
  struct us_stage *st = us.st;
  int32_t s = st->slot - 1, e;
  struct us_cache *c = (uint32_t)s < US_SLOTS ? us.c[s] : 0;
  if (c) {
    us_copy(&c->h, &st->h, sizeof c->h);
    us_copy(c->k, st->k, sizeof c->k);
    /* this order matters - h (its generation) first, the lists' knobs reset after: us_list_in (MIDI task) re-checks
       h.gen after writing a list, so one written before the reset is freed by it, one under way after h sees the new
       generation and frees itself */
    for (e = 0; e < 8; ++e) c->eknob[e] = 0xff;
    us.layer[s] = c->h.state == 1 && !(c->h.flags & 1);
    us_names(s);
    us_slot_records(s);
    if (us.p2_slot == s + 1) us.p2_slot = 0;   /* page 2 set up again at its next draw */
    us.wait[s] = 0;
  }
  st->got = 0;
}
/* The slot menu's YES, after the 1D answer: the menu draws no value text, so no us_tick runs while it is open - the
   slot's new 1A is asked for and committed here (0.5 s at most), else the item's label and the next YES's step (from
   c->h.name) stay on the old machine. After us_menu_action's pends (their pgen is the old generation). */
US2 void us_fetch(int32_t s) {
  struct us_stage *st = us.st;
  struct us_cache *c = us.c[s];
  int32_t k;
  if (!st || !c) return;
  for (k = 0; k < 50; ++k) {
    if (st->got == 0xff) us_commit();
    if (c->h.gen == us.tgen[s]) return;
    if (k == 0 || k == 25) us_ask(s + 1, c->h.gen, 0, 0);
    US_SLEEP(10000);
  }
}
/* 1C's values for each track that still plays that slot (0x8000ea00[t] == 34 + slot), clamped to the
   knob's range, as a knob turn leaves them (us_set: the live copy, the kit word and the project's copy). */
US2 static void us_writeback(void) {
  int32_t t, k;
  for (t = 0; t < 12; ++t) {
    volatile struct us_wb *w = &us.wb[t];
    const struct us_cache *c;
    uint8_t v[16], seq = w->wseq, slot;
    uint32_t m;
    if ((seq & 1) || seq == w->rseq) continue;   /* being written, or nothing new */
    m = w->mask;   /* a seqlock read: copied, then wseq checked again */
    slot = w->slot;
    for (k = 0; k < 16; ++k) v[k] = w->v[k];
    if (w->wseq != seq) continue;                /* a 1C arrived while copying: the next tick takes it whole */
    w->rseq = seq;
    c = us.c[slot - 1];
    if (MACHINE_OF(t) != US_FIRST - 1 + slot || !c) continue;   /* the track plays another machine now */
    if (!us_params(slot - 1)) m &= 0xff;   /* P9..P16 only when page 2 is knobs (else they are the sample's) */
    for (k = 0; k < 16; ++k) {
      int32_t x, lo, hi;
      if (!(m >> k & 1)) continue;
      lo = c->k[k].p ? c->k[k].min : 0;
      hi = c->k[k].p ? c->k[k].max : 127;
      x = v[k] < lo ? lo : v[k] > hi ? hi : v[k];
      us_set(t, US_INDEX(k), k < 8 ? US_REC + 8 * (slot - 1) + k : us_p2rec[k - 8], x << 8);
    }
  }
}
US2 static int32_t us_has_enum(const struct us_cache *c, int32_t k) {
  int32_t e;
  for (e = 0; e < 8; ++e)
    if (c->eknob[e] == k) return 1;
  return 0;
}
/* Every value text (UI task): the first time us_init; a complete 1A committed; write-backs applied; then
   at most one ask every 10 ticks - a slot's metadata when its generation is not the Teensy's (or no 1D
   came yet), each slot at most once in 200 ticks; a READY slot's missing enum lists. */
US2 void us_tick(void) {
  int32_t s, k;
  if (!us.done) us_init();
  if (us.st && us.st->got == 0xff) us_commit();
  if (us.wb) us_writeback();
  us_tick3();   /* page 2's records for the selected track, the user's slot choices, !NAME (.us6) */
  for (s = 0; s < US_SLOTS; ++s)
    if (us.wait[s]) --us.wait[s];
  if (us.gap) {
    --us.gap;
    return;
  }
  for (s = 0; s < US_SLOTS; ++s) {
    struct us_cache *c = us.c[s];
    int32_t have = c ? c->h.gen : 0;
    if (us.wait[s]) continue;
    if (!us.seen || us.tgen[s] != have) {
      if (us_ask(s + 1, have, 0, 0)) {
        us.wait[s] = 200;
        us.gap = 10;
      }
      return;
    }
    if (!c || c->h.state != 1) continue;
    for (k = 0; k < 16; ++k)
      if (c->k[k].p && c->k[k].kind == 2 && c->k[k].ne && !us_has_enum(c, k) && us_has_enum(c, 0xff)) {
        /* (not when the cache's eight lists are taken: us_list_in would drop a ninth) */
        if (us_ask(s + 1, have, 1, k)) {
          us.wait[s] = 50;
          us.gap = 10;
        }
        return;
      }
  }
}

/* ---- choosing a user slot (the user's decision, 2026-10-10): a track the user gives U1..U5 - the machine
 * list's YES, the SOUND menu's MACHINE item, or the slot menu's assign - takes the plugin's 1A defaults on
 * all its knobs, P1..P16 (P9..P16 when page 2 is knobs), as a stock machine takes its records' defaults when
 * chosen; never on a kit or project load or a kit switch. [measured, rytm-emu us1 2026-10-10, --count; R12]
 * Every DOWN in the machine list previews: its cursor (0x400d40a4) calls 0x400bed62, which calls set_machine
 * 0x400bd14e(sound, machine, track, flag), which resets P1..P8 from the records (0x400bcbac) when the
 * machine changed; YES calls nothing more (the preview stays); NO puts the old machine back through
 * 0x400a68a2 and restores its P1..P8; both close the list through 0x400dea82(window, yes) (MachineListView's
 * own: its only constructor call is 0x400d3f5a). So the cursor's set_machine call notes the track (us.ch,
 * detour 0x400bee40) and the close with YES takes it (detour 0x400dea8e): the defaults go in only for a
 * confirmed list, and a preview passing a slot leaves the sample words alone. The list can also be left
 * without its close (GLOBAL, the TRACK menu: the preview stays, no defaults), so its opening clears the
 * note (us_open_thunk, at the constructor's call). 0x400bed62's other caller, the SOUND menu's MACHINE item
 * (FUNC + FLTR, LEFT/RIGHT; 0x400ef678), steps the machine at once, stock resetting P1..P8 on each step: a
 * step onto a slot is a choice of its own (us_step, by 0x400bed62's return address). The chosen track waits
 * (pslot) for the first UI tick that sees the slot's 1A current - at once, or when it arrives (no Teensy
 * yet, LOADING, stale) - within ~60 s of the choice, while no kit or project is loaded (us_loaded) and the
 * track still plays the slot. (A machine change by MIDI, 0x4010330c, is neither: no defaults, as a load.) */
#define US_NOW() (*(volatile const uint32_t *)0x419ca2acu)   /* audio blocks: 48 kHz / 32 = 1500 a second [R12] */
#define US_PEND_WINDOW 90000u                                /* 60 s */
/* The sound tag (the user's decision, 2026-10-10; sound-tag-research.md): sound index 0 holds the fingerprint of the
   plugin a U-sound was made for (1A part 0's fp, 1..16383; 0 untagged). Only a choice writes it (us_defaults): the
   active kit's word 0 (US_KIT: a pattern on another kit plays and edits that kit), the project copy's slot 41 and
   the live array's word 0 (byte stores in the kit and the copy: their parity changes with k and t) - power-off keeps
   the project copy, every save serializes the live kit [measured, M3]. The project copy 0x4076591f.. is the active
   kit's (a switch to A02's kit 1 rewrites all twelve tracks there with kit 1's sounds; its drain writes kit 1's
   knobs there) [measured]. No knob, load, 1A or 1C writes it. */
#define US_TAG_KIT(k, t) ((volatile uint8_t *)(0x41255921u + 2531u * (k) + 152u * (t)))
/* Since 2026-10-16 (rytm-teensy 2026-10-16-sidecar-send-fx-storage.md, "the sound tag out of sound index 0"): sound
   index 0 is the Sidecar's SEND FX 1/2 on every track; the tag lives in the sound's spare bytes +0x6e/+0x6f (live, 0x5a
   past word 0: US_TAG_OFF) and in stored slot 47 (+0x7a/+0x7b, the project copy's US_TAG_PROJ). sound_load /
   sound_save carry it (us_tag_load / us_tag_save, 0013's two detour sites; 0021 excludes 0013), only for machines
   35..39 (0 otherwise: the spare bytes are heap garbage on other sounds), and migrate a sound tagged the old way (slot
   47 zero, slot 41 set, a U machine): the tag from slot 41, slot 41 cleared in the record before stock loads it. The
   trig's copy of a sound (0x4011f558, kit or sound lock) puts its tag into us_tag[t] (us_tag_copy), which ext_render
   reports. Stock ignores slot 47 and zeroes it at its next save: the sound comes back untagged (plays). */
#define US_TAG_OFF 0x5a
#define US_TAG_PROJ(t)   ((volatile uint8_t *)(0x4076598du + 162u * (t)))
USR volatile uint16_t us_tag[13];   /* track t: the tag of the sound its last trig copied (us_tag_copy) */
/* sound_load (a2 live, a3 the stored record; after its memset, before the 42 slots are read) */
UST void us_tag_load_c(volatile uint8_t *live, volatile uint8_t *st) {
  uint32_t tag = (uint32_t)st[0x7a] << 8 | st[0x7b];
  if ((uint32_t)st[0x7c] - US_FIRST >= US_SLOTS)
    tag = 0;
  else if (!tag && (st[0x6e] | st[0x6f])) {   /* tagged the old way (index 0): migrate */
    tag = ((uint32_t)st[0x6e] << 8 | st[0x6f]) & 0x3fff;
    st[0x6e] = 0;
    st[0x6f] = 0;
    st[0x7a] = (uint8_t)(tag >> 8);
    st[0x7b] = (uint8_t)tag;
  }
  if (tag > 0x3fff) tag = 0;
  live[0x6e] = (uint8_t)(tag >> 8);
  live[0x6f] = (uint8_t)tag;
}
/* sound_save (a2 the stored record, a3 live; after its memset of slots 0..47) */
UST void us_tag_save_c(volatile uint8_t *st, const volatile uint8_t *live) {
  if ((uint32_t)live[0x68] - US_FIRST < US_SLOTS) {
    st[0x7a] = live[0x6e] & 0x3f;
    st[0x7b] = live[0x6f];
  }
}
/* 0x4011f558 copies sound a2 into track d2's live array (the trig loop: kit sound or sound lock; kit loads) */
UST void us_tag_copy_c(const volatile uint8_t *snd, uint32_t t) {
  if (t < 13)
    us_tag[t] = (uint32_t)snd[0x68] - US_FIRST < US_SLOTS ? (uint16_t)((snd[0x6e] << 8 | snd[0x6f]) & 0x3fff) : 0;
}
/* The three detours' stubs: the displaced instructions re-emitted verbatim after the call. */
__asm__(
"	.pushsection	.ust,\"ax\",@progbits\n"
"	.align	2\n"
"	.globl	us_tag_load\n"
"us_tag_load:\n"                          /* 0x4000826a: lea 0x401c5a74,%a0 */
"	move.l	%a3,-(%sp)\n"
"	move.l	%a2,-(%sp)\n"
"	jsr	us_tag_load_c\n"
"	addq.l	#8,%sp\n"
"	lea	0x401c5a74,%a0\n"
"	jmp	0x40008270\n"
"	.globl	us_tag_save\n"
"us_tag_save:\n"                          /* 0x40008492: lea 0x401c59cc,%a0 */
"	move.l	%a3,-(%sp)\n"
"	move.l	%a2,-(%sp)\n"
"	jsr	us_tag_save_c\n"
"	addq.l	#8,%sp\n"
"	lea	0x401c59cc,%a0\n"
"	jmp	0x40008498\n"
"	.globl	us_tag_copy\n"
"us_tag_copy:\n"                          /* 0x4011f58a: move.l %d2,-(%sp); pea 20(%a2) */
"	move.l	%d2,-(%sp)\n"
"	move.l	%a2,-(%sp)\n"
"	jsr	us_tag_copy_c\n"
"	addq.l	#8,%sp\n"
"	move.l	%d2,-(%sp)\n"
"	pea	20(%a2)\n"
"	jmp	0x4011f590\n"
"	.popsection\n");
/* IPL 7 on (sr: the old SR) and back: ColdFire has no ori to SR, so through a register */
#define US_MASK(sr) \
  __asm__ volatile("move.w %%sr,%0\n\tmove.l %0,%%d1\n\tori.l #0x0700,%%d1\n\tmove.w %%d1,%%sr" : "=d"(sr) : : "d1", "memory")
#define US_UNMASK(sr) __asm__ volatile("move.w %0,%%sr" : : "d"(sr) : "memory")
/* With IPL 7 (UI task): track t's sound in the active kit (its word 0) while it is still slot s's as us_tick3 saw it -
   no load moved the generation from g, the live machine and the kit sound's own machine byte (+0x68 from the sound,
   w[0x54] [measured, us1 2026-10-11: BD 0x15, then 0x23 once U1 chosen; kit 1's BD 0x1c]) both the slot, and the kit
   word 0x800067b8 the applied one 0x8000fc8c (a set not yet applied - up to one audio block - names a kit whose
   track t may play a stock machine). 0: none of the kit's words may be written (review 2026-10-11, MEDIUM 1). */
US6 static volatile uint8_t *us_kit_sound(int32_t t, int32_t s, uint8_t g) {
  uint32_t kit = *(volatile const uint32_t *)0x800067b8u;
  volatile uint8_t *w = US_TAG_KIT(kit & 127u, t);
  if (*(volatile uint8_t *)&us.lgen != g || *(volatile const uint8_t *)&MACHINE_OF(t) != US_FIRST + s ||
      kit != *(volatile const uint32_t *)0x8000fc8cu || w[0x54] != US_FIRST + s)
    return 0;
  return w;
}
/* The user chose slot s for track t (us_choose): the sound's old tag goes now, until us_defaults writes the slot's own
   (at the first tick that sees the slot's 1A READY). A sound moved from U1 (tagged with U1's plugin) to another slot
   that holds no plugin, or another one, kept the old tag, and the next 25 SLOT PRINTS told the Sidecar that slot s
   should hold the old plugin: it filled or replaced the slot (hardware report 2026-10-17: METAL in every slot).
   The same four stores as the tag's, masked, after us_kit_sound's checks (the track still plays the slot in the
   applied kit); nothing when a kit switch moved the generation. */
US8 static void us_untag(int32_t t, int32_t s) {
  uint32_t sr;
  volatile uint8_t *w;
  US_MASK(sr);
  if ((w = us_kit_sound(t, s, us.lgen)) != 0) {
    w[US_TAG_OFF] = 0;
    w[US_TAG_OFF + 1] = 0;
    us_tag[t] = 0;
    US_TAG_PROJ(t)[0] = 0;
    US_TAG_PROJ(t)[1] = 0;
  }
  US_UNMASK(sr);
}
/* Track t's sixteen knobs (eight when page 2 is the sample) to slot s's defaults, as a knob turn leaves them, and
   its sound tagged with the slot's plugin - the kit's words and the tag only while no load moved the generation from
   g (us_tick3's read), the track still plays the slot and the active kit is the applied one (us_kit_sound). */
US6 static void us_defaults(int32_t t, int32_t s, uint8_t g) {
  const struct us_knob *k = us.c[s]->k;
  int32_t i, n = us_params(s) ? 16 : 8;
  uint16_t fp = us.c[s]->h.fp;
  uint32_t sr;
  volatile uint8_t *w;
  for (i = 0; i < n; ++i, ++k) {
    uint8_t v = k->p ? k->def : 64;
    /* each knob word straight into the active kit first (word 9 + i at w + 18 + 2 i: 8.8, the integer byte first;
       byte stores, odd or even with the kit), then as a turn leaves it (the live copy, US_COMMIT queued): a trig
       whose copy of the kit sound lands before the queue drains (stock forces that copy at the first trig since
       boot, after a kit load, after a sound-lock step) brings the defaults, not the old words (review 2026-10-11,
       MEDIUM 4); one between the two stores of a knob brings the new word and the live store repeats it. Each
       knob's two stores masked, after us_kit_sound's checks: a kit switch since us_tick3's read, or one set and not
       yet applied, would put them into a kit whose track t may play a stock machine (and a save would keep them);
       none then - US_COMMIT's drain still writes them where the record is the track's machine's. */
    US_MASK(sr);
    if ((w = us_kit_sound(t, s, g)) != 0) {
      w[18 + 2 * i] = v;
      w[19 + 2 * i] = 0;
    }
    US_UNMASK(sr);
    us_set(t, US_INDEX(i), i < 8 ? US_REC + 8 * s + i : us_p2rec[i - 8], v << 8);
  }
  /* the kit's two bytes and the live word with interrupts masked (IPL 7): a trig may copy the kit sound to
     0x8000e5b0, and one between the stores would play a half-new tag; nothing - interrupt or task switch - runs
     between them now. Measured in rytm-emu (us1): SR 0x2004 here before the mask (UI task, supervisor, IPL 0),
     0x2704 after; the audio interrupt (v191, 0x4011fafa) enters at IPL 5 (US_MASK). The active kit is read inside the
     mask, with the stores.
     A trig copies the kit sound (0x4011f558: to 0x8000e5b0 and 0x8000f7a8 + 84 t, 0x80005f10 cleared; ext_render
     reads the tag from the first) only when 0x8000fc58[t], the kit last copied for t, is not the one it plays
     (0x4012062e). Index 0 has no record, so after a track's first trig nothing else brings word 0 over [measured,
     E2E bug 2]: the tag goes into the live word 0 here, as SET_PARAM stores a knob's (one move.w, even address;
     SET_PARAM(fp, t, 0) would also clear 0x80005f10[42 t], a smoothing step, as the full copy does). Not
     -1 in fc58 (b4a8f74): that made the next trig copy the kit's P1..P16 while US_COMMIT still held them queued
     (drained every 8th UI pass, ~11M instructions), so a trig in that window kept the old words for good.
     That window remains wherever stock forces the copy itself (user-slots-research.md, bug 2, "Remaining risk"): the
     first trig after a kit load (-1 for all twelve, 0x4011f8da), the first since boot (-1, 0x4011fa08), the step
     after a sound-lock step (-1, 0x401205e2) and a set 0x8000fe30[t] (its setter not traced). A trig within ~11M
     instructions of a choice copied the old P words into the live array until 2026-10-11; since then the loop above
     stores each knob word into the active kit before its us_set, so such a copy brings the defaults. The tag is never
     lost: it is written here into the kit word directly, not queued.
     A pattern's kit switch can land during the sixteen us_set calls above: the audio interrupt compares the kit word
     0x800067b8 with the applied kit 0x8000fc8c (0x40120ad6; -1 at boot, 0x4011fa3c), calls 0x4011f6bc (us_loaded:
     us.lgen moves on) and stores 0x800067b8 into 0x8000fc8c (0x40120afc) - its only writers [read]. So, inside the
     mask, the tag goes in only when us.lgen is still g (no switch since us_tick3's read), the track - live and in the
     kit sound - still plays the slot, and 0x800067b8 is 0x8000fc8c (a kit set by the UI task's 0x4011f82a, not yet
     applied - up to one audio block - would be switched to with the old kit's tag written): us_kit_sound, as for
     the knob words above. The project copy's two bytes are written there too, so nothing sees half a tag in any
     copy. */
  US_MASK(sr);
  if ((w = us_kit_sound(t, s, g)) != 0) {
    w[US_TAG_OFF] = (uint8_t)(fp >> 8);
    w[US_TAG_OFF + 1] = (uint8_t)fp;
    us_tag[t] = fp;
    US_TAG_PROJ(t)[0] = (uint8_t)(fp >> 8);
    US_TAG_PROJ(t)[1] = (uint8_t)fp;
  }
  US_UNMASK(sr);
}
/* The user gave track t its machine (UI task): when it is a user slot, its defaults at the first tick that
   sees the slot's 1A current (us_tick3). */
US8 static void us_pend(int32_t t) {
  int32_t s;
  struct us_wb *w = us.wb;
  if ((uint32_t)t >= 12) return;
  s = MACHINE_OF(t) - US_FIRST;
  if ((uint32_t)s >= US_SLOTS || !w) return;
  w += t;
  w->pslot = (uint8_t)(s + 1);
  w->pgen = 0;
  w->ptime = US_NOW();
}
/* The user chose track t's machine in the machine list (YES) or the SOUND menu (MACHINE item): us_pend, and the sound's
   old tag off. Not the slot menu's assign (us_menu_action: the tracks on the slot keep the old plugin's tag until the
   new 1A, as before). */
US8 static void us_choose(int32_t t) {
  int32_t s = (t < 12 && t >= 0) ? MACHINE_OF(t) - US_FIRST : -1;
  us_pend(t);
  if ((uint32_t)s < US_SLOTS) us_untag(t, s);
}
/* The machine list closes (UI task): after a preview in this list, YES chose its machine. */
US3 void us_confirm(int32_t yes) {
  int32_t t = us.ch - 1;
  us.ch = 0;
  if (yes && (uint32_t)t < 12) us_choose(t);
}
/* 0x400bed62 set track t's machine (UI task; ret: its caller): the machine list's cursor previews (noted for
   the list's YES), the SOUND menu's MACHINE item chooses. */
US5 void us_step(int32_t t, uint32_t ret) {
  if (ret == 0x400d40dau) us.ch = (uint8_t)(t + 1);
  else if (ret == 0x400ef67eu) us_choose(t);
}
/* 0x4011f6bc ran: a kit or a project was loaded (RELOAD KIT, LOAD KIT, a pattern's other kit, LOAD PROJECT;
   not SAVE KIT, a machine choice or a knob [measured, R12]). The tracks waiting for a choice's defaults keep
   what the load brought. Called from the UI/load context and from the audio interrupt on a pattern's kit
   switch (0x40120af0, in the handler ending 0x4012165e): it must stay interrupt-safe - byte stores only (the
   generation first, so a us_tick3 under way sees it moved before it commits). */
US5 void us_loaded(void) {
  struct us_wb *w = us.wb;
  int32_t t;
  *(volatile uint8_t *)&us.lgen = (uint8_t)(us.lgen + 1);
  *(volatile uint8_t *)&us.ch = 0;   /* a list left without its close, then a load: no preview any more (sp_tick) */
  if (w)
    for (t = 12; t; --t, ++w) {
      __asm__("" : "+d"(t));   /* a down-counter, shorter than an end pointer */
      w->pslot = 0;
    }
}
/* Every UI tick (us_tick): page 2's shared records set up for the selected track's slot (us_param_record,
   which may be asked outside the UI task, only reads them); the waiting tracks take their slot's defaults at
   the first tick its 1A is the Teensy's current one and READY (current in another state: none), or give up
   after US_PEND_WINDOW (32-bit audio blocks: no wrap for 33 days) or when the track plays another machine.
   us_loaded may run between the checks and the commit (the audio interrupt's kit switch): the load generation
   is read before them and again, with the machine, just before the defaults. Then !NAME: the selected track on a
   slot whose sound tag (the active kit's word 0, low 14 bits) is set and not the slot's fp (both nonzero) shows
   the slot's names with '!'. */
US6 void us_tick3(void) {
  struct us_ram *u = &us;
  int32_t t, s;
  uint8_t g, m = 0;
  const struct us_cache *c;
  __asm__("" : "+a"(u));   /* d16(An) accesses, shorter than absolute ones */
  t = US_SEL_TRACK;   /* read once: the firmware may move the selection between two reads */
  if (t > 11) t = 0;
  s = MACHINE_OF(t) - US_FIRST;
  us_page_record(MACHINE_OF(t), 0);
  if ((uint32_t)s < US_SLOTS && (c = u->c[s]) != 0 && c->h.fp) {
    /* 14 bits, as the Teensy reads the reported tag (two 7-bit bytes): an older word (0004's LFO RND, >= 0x4000)
       compares by its low 14 bits there and here */
    volatile uint8_t *w = US_TAG_KIT(US_KIT(), t);   /* the active kit's, as us_defaults writes it */
    uint16_t w0 = (uint16_t)(w[US_TAG_OFF] << 8 | w[US_TAG_OFF + 1]) & 0x3fff;
    if (w0 && w0 != c->h.fp) m = (uint8_t)(s + 1);
  }
  if (m != u->mm) {
    g = u->mm;
    u->mm = m;
    if (g) us_names(g - 1);
    if (m) us_names(m - 1);
  }
  if (!u->wb) return;
  g = *(volatile uint8_t *)&u->lgen;
  for (t = 0; t < 12; ++t) {
    struct us_wb *w = &u->wb[t];
    const struct us_cache *c;
    uint8_t p = *(volatile uint8_t *)&w->pslot;
    if (!p) continue;
    s = p - 1;
    c = u->c[s];
    if (US_NOW() - w->ptime >= US_PEND_WINDOW || MACHINE_OF(t) != US_FIRST + s) {
      w->pslot = 0;
      continue;
    }
    if (!c || !c->h.gen || (u->seen && c->h.gen != u->tgen[s]) || c->h.state == 2 || c->h.gen == w->pgen)
      continue;   /* not yet (an assign: not the machine the cache held when the answer came) */
    w->pslot = 0;
    if (c->h.state == 1 && *(volatile uint8_t *)&u->lgen == g && *(volatile const uint8_t *)&MACHINE_OF(t) == US_FIRST + s)
      us_defaults(t, s, g);
  }
}

/* ---- the slot menu: five items U1..U5 in the track menu (FUNC + CHRO), the spec's fallback (R5) ----
 * Appended by a detour over TrackMenuView's constructor's last instruction pair (`lea %sp@(128),%sp;
 * rts` at 0x400f9e9c, after 0012's SLICE LOOP item if 0012 is in the image: its stub rejoins there, so
 * the two chain without naming each other). Each item is built as stock's: four std::function objects
 * (label, action, icon, empty: menu_item_ctor's order, R5), a 0x54-byte MenuItem, appended, the four
 * destroyed; SAVE TRACK's managers (their captures match: nothing for the label and icon, the menu for
 * the action). Label: "U<n> <machine>" at draw time (the items are built once, at boot: R5); YES (the
 * action) steps the slot to the next installed machine (after the last: cleared), or installs a MISSING
 * slot's machine from the Teensy's card; a popup says how it went. The action waits for the Teensy in
 * the UI task, 10 ms steps, 2 s at most (as 0023's listings wait); no answer: NO TEENSY. An assign
 * answered READY or LOADING gives the tracks playing that slot its new machine's defaults (us_choose's
 * wait: the slot's next current 1A). */
struct us_fn { void *storage; uint32_t pad; void *manager; void *invoker; };   /* std::function, 16 B */
typedef void (*us_ctor_fn)(void *item, struct us_fn *label, struct us_fn *action, struct us_fn *icon,
                           struct us_fn *empty, int32_t a, int32_t b);
#define US_ITEM_CTOR  ((us_ctor_fn)0x40072f50u)
#define US_APPEND     ((void (*)(void *menu, void *item))0x40072786u)
#define US_FN_DTOR    ((void (*)(struct us_fn *))0x401709c6u)
#define US_STR        ((void (*)(void *s, const char *c, void *alloc))0x401bcd4cu)
#define US_STR_DTOR   ((void (*)(void *s))0x401bb29cu)
#define US_POPUP      ((void (*)(void *p, void *s))0x400766e8u)
#define US_SHOW       ((void (*)(void *mgr, void *sp, int32_t z))0x400793f6u)
#define US_SP_RELEASE ((void (*)(void *cb))0x40170a0cu)
#define US_MGR_LABEL  ((void *)0x400f9a38u)
#define US_MGR_ACTION ((void *)0x400f9a8au)
#define US_MGR_ICON   ((void *)0x400f9ae6u)
static const char us_t_res[7][16] USD = {"READY", "NOT INSTALLED", "NO ROOM", "STOP TO INSTALL", "NOT ON CARD",
                                          "BAD", "LOADING"};
static const char us_t_none[] USD = "NO SIDECAR";   /* 1021: was NO TEENSY */
static const char us_fmt_item[] USD = "U%d %s";
static const char us_unknown[] USD = "?";
char us_lbuf[20] USR;
/* the thunks below: us_label_1 + 4 s is U(s+1)'s label invoker, us_action_1 + 4 s its action's */
extern const uint8_t us_label_1[], us_action_1[], us_icon[];

/* The item's text (the label thunks build the std::string from it). */
US4 const char *us_label_text(int32_t s) {
  const struct us_cache *c = us.c[s];
  const char *n = !c || !c->h.gen ? us_unknown : c->h.state == 0 ? us_none : us_lnames[s];
  STR_PRINTF(us_lbuf, us_fmt_item, s + 1, n);
  return us_lbuf;
}
/* A popup on the menu, as SAVE TRACK shows its own (0012's sequence). */
US4 static void us_popup(void *menu, const char *text) {   /* in .us4 since 2026-10-11 (.us3's room went to the menu's fixes) */
  uint32_t str[2], sp[2], *cb;
  char alloc;
  void *p;
  US_STR(str, text, &alloc);
  p = US_NEW(0xa0);
  cb = (uint32_t *)US_NEW(0x10);
  if (!p || !cb) goto out;   /* the heap is out: no popup (one block may stay allocated) */
  US_POPUP(p, str);
  cb[0] = 0x401ccab4u;   /* shared_ptr's control block vtable, as SAVE TRACK's */
  cb[1] = 1;
  cb[2] = 1;
  cb[3] = (uint32_t)p;
  sp[0] = (uint32_t)p;
  sp[1] = (uint32_t)cb;
  US_SHOW(((void **)menu)[25], sp, 0);   /* the menu's view manager (+100) */
  US_SP_RELEASE(&sp[1]);
out:
  US_STR_DTOR(str);
}
US3 static int32_t us_same(const char *a, const char *b) {   /* the first 9 characters (the list keeps 9) */
  int32_t i;
  for (i = 0; i < JN_NAME - 1; ++i) {
    if (a[i] != b[i]) return 0;
    if (!a[i]) return 1;
  }
  return 1;
}
/* The 1E a (11 bytes) after 10 <project> (spec 2.1: a 1E is preceded by 10, as 12 is), under one lock. */
/* 10 <project>, then a (n bytes: the slot menu's 1E, sp_tick's 25), one lock: called with the mutex held (ext_ui_lock);
   gives it */
US5 void us_assign_send(const uint8_t *a, int32_t n0) {   /* global: sp_tick (asm) calls it too */
  uint8_t m[21];
  int32_t k, n = 5;
  m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x10;
  for (k = 0; k < 15 && PROJECT_NAME[k]; ++k) m[n++] = PROJECT_NAME[k] & 0x7f;
  m[n++] = 0xf7;
  USB_MIDI_SEND(n, m);   /* the caller holds the mutex (ext_ui_lock) */
  USB_MIDI_SEND(n0, a);
  MIDI_UNLOCK();
}
/* Waits (UI task, 10 ms steps) for the installed list current in the one-list cache (s < 0: asked for when it is
   not) or the 1D answering slot s's 1E; k: the steps already spent - one YES waits 2 s at most in all, both waits
   (200 steps). Returns the steps spent + 1, 0: it did not come. */
US3 static int32_t us_wait(int32_t s, int32_t k) {
  const struct jn_mailbox *q = &jn_mailbox;
  const struct us_ram *u = &us;
  __asm__("" : "+a"(u), "+a"(q));   /* d16(An) accesses, shorter than absolute ones */
  for (; k < 200; ++k) {
    if (s < 0 ? u->seen && q->valid && q->list == 0x20 && q->lgen == u->tinst : u->ans_slot == s + 1) return k + 1;
    if (s < 0 && !k && !us_ask(0, 0, 3, 0)) return 0;
    US_SLEEP(10000);
  }
  return 0;
}
/* YES on item U<s+1>: the installed list (1B 0x21) current in the one-list cache (asked for when it is not),
   then 1E - the next installed machine after the slot's, or clear after the last, or install a MISSING
   slot's machine from the card (1A flag bit 1; not when this slot's install failed at the last YES - no answer, or
   not READY / LOADING - so a slot whose install keeps failing can still be stepped or cleared) - and the 1D answer
   as a popup. */
US3 void us_menu_action(void *menu, int32_t s) {
  const struct jn_mailbox *q = &jn_mailbox;
  struct us_ram *u = &us;
  const struct us_cache *c;
  const char *r = us_t_none;
  int32_t i = 0, op = 0, live, k;
  uint8_t m[11], f = u->ifail;
  __asm__("" : "+a"(u));   /* d16(An) accesses, shorter than absolute ones */
  c = u->c[s];
  live = c && c->h.gen && c->h.state;
  u->ifail = 0;
  if ((k = us_wait(-1, 0)) != 0) {
    if (live && c->h.state == 3 && (c->h.flags & 2) && f != s + 1) {
      op = 2;
    } else {
      if (live) {
        while (i < q->total && !us_same(q->names[i], c->h.name)) ++i;
        i = i < q->total ? i + 1 : 0;
      }
      if (i >= q->total) op = 1, i = 0;
    }
    u->ans_slot = 0;
    m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x1e; m[5] = 1;
    m[6] = (uint8_t)(s + 1); m[7] = (uint8_t)op; m[8] = (uint8_t)i; m[9] = q->lgen; m[10] = 0xf7;
    /* the list may have been replaced (a 1B in the MIDI task) since the entry was picked: no 1E then; nor when the
       list took all but the last 300 ms of the 2 s (k > 170): the answer could not come in time, and the Teensy would
       assign behind a NO TEENSY (review 2026-10-11, LOW 3) */
    if (k <= 170 && *(volatile const uint8_t *)&q->list == 0x20 && *(volatile const uint8_t *)&q->lgen == u->tinst &&
        ext_ui_lock()) {   /* never waits: not now = no 1E, NO TEENSY after the wait, as before without requests */
      us_assign_send(m, 11);
      if (op == 2) u->ifail = (uint8_t)(s + 1);   /* sent: until its answer says READY or LOADING */
      if (us_wait(s, k)) {
        i = u->ans_res;
        r = us_t_res[i < 7 ? i : 5];
        if (i == 0 || i == 6) u->ifail = 0;
        u->wait[s] = 0;   /* its metadata at the next tick */
        /* an assign READY, LOADING: the tracks on the slot take the new machine's defaults (its 1D carries the
           generation, its 1A follows); an install (op 2) or a clear is no choice. Each pend notes the cache's
           generation now (pgen): us_tick3 waits for a 1A of another generation, so a 1D answer naming the old
           cache's generation (a stale Teensy) never gives the old machine's defaults and fp (at worst the pend
           runs out after US_PEND_WINDOW). (UI task, as us_commit, the writer of h.gen.) */
        if (!op && (i == 0 || i == 6))
          for (i = 0; i < 12; ++i)
            if (MACHINE_OF(i) == US_FIRST + s) {
              us_pend(i);
              if (u->wb && c) u->wb[i].pgen = c->h.gen;
            }
        us_fetch(s);
      }
    }
  }
  us_popup(menu, r);
}
/* TrackMenuView's constructor, last: the five items. */
US4 void us_menu_add(void *menu) {
  int32_t s, i;
  for (s = 0; s < US_SLOTS; ++s) {
    struct us_fn f[4];
    void **cap;
    void *item;
    for (i = 0; i < 4; ++i) f[i].storage = f[i].manager = f[i].invoker = 0, f[i].pad = 0;
    f[0].storage = US_NEW(1); f[0].manager = US_MGR_LABEL; f[0].invoker = (void *)(us_label_1 + 4 * s);
    cap = (void **)US_NEW(4);
    *cap = menu;
    f[1].storage = cap; f[1].manager = US_MGR_ACTION; f[1].invoker = (void *)(us_action_1 + 4 * s);
    f[2].storage = US_NEW(1); f[2].manager = US_MGR_ICON; f[2].invoker = (void *)us_icon;
    item = US_NEW(0x54);
    US_ITEM_CTOR(item, &f[0], &f[1], &f[2], &f[3], -1, 8);
    US_APPEND(menu, item);
    for (i = 3; i >= 0; --i) US_FN_DTOR(&f[i]);
  }
}
/* The thunks: the menu detour's entry (the constructor's `this` is at sp + 132 there), the label invokers
   (a0: the std::string to build, as SAVE TRACK's label lambda takes it), the action invokers (sp + 4:
   the functor; its storage holds the menu), the icon (none); 4 bytes a slot (moveq, bra.s); then the
   machine choice's hooks (see us_confirm, us_step, us_loaded). */
__asm__(
    "  .section .us4,\"ax\"\n"
    "  .globl us_menu_thunk\n"
    "us_menu_thunk:\n"
    "  movel %sp@(132),%sp@-\n"
    "  jsr us_menu_add\n"
    "  addql #4,%sp\n"
    "  lea %sp@(128),%sp\n"          /* displaced */
    "  rts\n"                        /* displaced */
    "  .globl us_label_1\n"
    "us_label_1: moveq #0,%d0\n  bras us_label\n"
    "  moveq #1,%d0\n  bras us_label\n"
    "  moveq #2,%d0\n  bras us_label\n"
    "  moveq #3,%d0\n  bras us_label\n"
    "  moveq #4,%d0\n"
    "us_label:\n"
    "  link %fp,#-4\n"
    "  movel %a2,%sp@-\n"
    "  movel %a0,%a2\n"
    "  movel %d0,%sp@-\n"
    "  jsr us_label_text\n"
    "  addql #4,%sp\n"
    "  pea %fp@(-1)\n"
    "  movel %d0,%sp@-\n"
    "  movel %a2,%sp@-\n"
    "  jsr 0x401bcd4c\n"             /* std_string_from_cstr */
    "  lea %sp@(12),%sp\n"
    "  movel %a2,%d0\n"
    "  movel %sp@+,%a2\n"
    "  unlk %fp\n"
    "  rts\n"
    "  .globl us_action_1\n"
    "us_action_1: moveq #0,%d0\n  bras us_action\n"
    "  moveq #1,%d0\n  bras us_action\n"
    "  moveq #2,%d0\n  bras us_action\n"
    "  moveq #3,%d0\n  bras us_action\n"
    "  moveq #4,%d0\n"
    "us_action:\n"
    "  moveal %sp@(4),%a0\n"         /* the functor */
    "  moveal %a0@,%a0\n"            /* its storage: the 4-byte block */
    "  movel %d0,%sp@-\n"
    "  movel %a0@,%sp@-\n"           /* the menu */
    "  jsr us_menu_action\n"
    "  addql #8,%sp\n"
    "  rts\n"
    "  .globl us_icon\n"
    "us_icon:\n"
    "  rts\n"
    /* the machine list's close (window, yes), past its prologue (d2: yes): us_confirm(yes) */
    "  .globl us_close_thunk\n"
    "us_close_thunk:\n"
    "  moveq #0,%d0\n"
    "  moveb %d2,%d0\n"
    "  movel %d0,%sp@-\n"
    "  jsr us_confirm\n"
    "  addql #4,%sp\n"
    "  moveal %fp@(8),%a2\n"         /* displaced */
    "  movel %a2,%sp@-\n"            /* displaced */
    "  jmp 0x400dea94\n"
    /* 0x400bed62 calls set_machine(sound, machine, track d3, flag) (0x400bee40's `movel %d2,%sp@-;
       jsr %pc@(0x400bd14e)`, reimplemented: pc-relative), then us_step(track, 0x400bed62's return address,
       sp + 64 there: 48 B of frame, three arguments, d2) */
    "  .section .us5,\"ax\"\n"
    "  .globl us_prev_thunk\n"
    "us_prev_thunk:\n"
    "  movel %d2,%sp@-\n"
    "  jsr 0x400bd14e\n"
    "  movel %sp@(64),%sp@-\n"
    "  movel %d3,%sp@-\n"
    "  jsr us_step\n"
    "  addql #8,%sp\n"
    "  jmp 0x400bee46\n"
    /* MachineListView's constructor call 0x400d3f5a (its target patched): the list opens with no note */
    "  .globl us_open_thunk\n"
    "us_open_thunk:\n"
    "  clrb us+us_off_ch\n"
    "  jmp 0x400def0a\n"
    /* 0x4011f6bc's entry: us_loaded, then `lea %sp@(-12),%sp; moveal %sp@(16),%a1` re-emitted */
    "  .globl us_load_thunk\n"
    "us_load_thunk:\n"
    "  jsr us_loaded\n"
    "  lea %sp@(-12),%sp\n"
    "  moveal %sp@(16),%a1\n"
    "  jmp 0x4011f6c4\n");

/* ---------------------------------------------------------------------------
 * Stepped list knobs (sfx-enum-knobs, 2026-10-18): which of 0021's knobs are lists, for 0029-sendfx-ui, which
 * turns them into stock-style enum records (FILTER TYPE's: N options = N detents, the step's name in place of the
 * dial) through the Sound set's wrappers it owns. ext_steps(record) -> 0 a continuous knob, else mode << 8 | N:
 *   1 zones: N equal zones over 0..127 (zone = v x N / 128, as the host decodes); a step stores its zone's lowest
 *     value, ceil(128 k / N), so an old project's values read as the zone they were in;
 *   2 list: entries 0..N-1 stored as the index (JUNO / FM PAT with the project's list, a U slot's presets);
 *   3 all 128 values one per detent (PAT without a list, a U slot's pool knob).
 * 0029 finds it through ext_stepbox (.usm, a fixed 8 B claim at the end of .us2's cave): magic 'XSTP', the
 * function. UI task only (0029's wrappers); reads the caches without writing them.
 * ------------------------------------------------------------------------- */
static const uint16_t ext_step_tab[7][2] USD = {
    {REC_P1, 0x100 | EXT_MODELS}, {REC_DD, 0x100 | DD_MODELS},   /* PLAITS / DIGIDRUM ENG */
    {REC_DSP, 0x103}, {416, 0x103}, {REC_DSP + 4, 0x10b},         /* DAISYSP / DSP SAMPLE ENG, INP */
    {REC_DSP2 + 3, 0x102}, {REC_DSPS2 + 3, 0x107}};               /* OUT (VOICE / MAIN), MOD (not in diag) */
static int32_t ext_steps_us(int32_t r, int32_t n);
US3 int32_t ext_steps(int32_t r) {
  struct jn_mailbox *q = &jn_mailbox;
  int32_t k, n;
  uint32_t diag;
  for (k = 0; k < 7; ++k)
    if (ext_step_tab[k][0] == r) {
      __asm__("movel #P_DIAG,%0" : "=d"(diag));
      return k == 6 && diag ? 0 : ext_step_tab[k][1];
    }
  n = q->valid && q->total ? q->total : 0;
  if (r == REC_JN || r == REC_FM)   /* JUNO / FM PAT: the project's list, else all 128 */
    return n && q->list == (r == REC_FM) ? 0x200 | n : 0x380;
  return ext_steps_us(r, n);
}
/* a U slot's knob: its kind from the slot's 1A (ext_steps in .us3, this in .us6: neither has room for both) */
US6 static int32_t ext_steps_us(int32_t r, int32_t n) {
  struct jn_mailbox *q = &jn_mailbox;
  int32_t k = 0, s, e;
  const struct us_cache *c;
  const struct us_knob *u;
  s = us_which(r, &k);
  if (s < 0 || !(c = us.c[s]) || !c->h.gen || !(u = &c->k[k])->p) return 0;
  if (u->kind == 2) {   /* enum: equal zones */
    for (e = 0; e < 8 && c->eknob[e] != k; ++e) ;
    return e < 8 && c->ecount[e] > 1 ? 0x100 | c->ecount[e] : 0;
  }
  if (u->kind == 6)     /* presets: the slot's list when the cache holds it */
    return n && q->list == 0x11 + s && q->lgen == c->h.gen ? 0x200 | n : 0x380;
  return u->kind == 7 ? 0x380 : 0;   /* pool: all 128 slots */
}
/* The slot menu open (FUNC + CHRO) draws no value text, so us_tick (from param_value_text) does not run: a 1D the
   Teensy pushes on an assign, rescan or delete, and the slot's new 1A, would wait until the menu closes. us_live runs
   from 0029's ev_tick (20 Hz, elekloader's UI loop): a staged 1A committed; a slot whose generation the Teensy moved
   (a 1D seen) asked again, 19 what 0, once in 50 ticks a slot. Not the whole us_tick: with no Teensy it would ask
   every slot every few ticks on every page. 1: a 1A was committed - the views redraw (the menu's labels). */
/* (two caves: .us4 and .ext4 each hold only part) */
__attribute__((section(".ext4"), noinline)) static void us_live_ask(struct us_ram *u) {
  int32_t s;
  for (s = 0; s < US_SLOTS; ++s) {
    struct us_cache *c = u->c[s];
    int32_t have = c ? c->h.gen : 0;
    if (u->wait[s]) --u->wait[s];
    else if (u->seen && u->tgen[s] != have && us_ask(s + 1, have, 0, 0)) u->wait[s] = 50;
  }
}
/* ---- 25 SLOT PRINTS (slot-resolve, 2026-10-19; rytm-teensy sim/protocol.py slot_prints): which plugin
 * fingerprints the project's sounds carry on each user slot, so a Sidecar with no map for the project resolves its
 * slots before PLAY. Every sound of the 128 resident kits (kit k, track t at SP_KIT: the live sound format, machine
 * +0x68, tag +0x6e/+0x6f, as US_TAG_KIT + US_TAG_OFF; all kits resident [measured, sound-tag-research.md]) and of
 * the project's sound pool (128 entries of the same 152-byte format at SP_POOL [measured, rytm-emu sfx1018:
 * names at +4 for entries 0..127 and zeros at 128; entry 0's tag 0x41313cb5 is the one us_emu's tagpool reads])
 * whose machine is 35..39 and whose tag & 0x3fff is nonzero; one entry per distinct (slot, fp), count capped at 127,
 * slot then fp ascending, at most 16 (flags bit 0: more). Sent after `10 <project>` under one MIDI lock, both taken
 * here without waiting: once a load settled (the project name or us.lgen - us_loaded - moved, then stable for
 * SP_SETTLE ticks), and every SP_REPEAT scans while nothing changed; seq moves when the content does. From us_live
 * (0029's ev_tick, the UI loop at 20 Hz): one scan a second, ~1664 sounds. UI task only. */
#define SP_KIT(k)  ((const volatile uint8_t *)(0x4125590du + 2531u * (k)))   /* track t at + 152 t */
#define SP_POOL    ((const volatile uint8_t *)0x41313c47u)                    /* entry i at + 152 i */
#define SP_SETTLE  10   /* ticks (0.5 s) with no load and the same name before a load's scan */
#define SP_SCAN    20   /* ticks between scans (1 s) */
#define SP_REPEAT  5    /* scans (5 s) between repeats of an unchanged report */
#define SP_MAX     16
struct sp_ram { uint32_t load, sum; uint8_t left, seq, rep, pad; };   /* rep >= SP_REPEAT: send */
USR struct sp_ram sp __attribute__((aligned(4)));
_Static_assert(__builtin_offsetof(struct us_ram, lgen) == 52 && __builtin_offsetof(struct sp_ram, left) == 8 &&
               __builtin_offsetof(struct sp_ram, seq) == 9 && __builtin_offsetof(struct sp_ram, rep) == 10,
               "sp_tick's offsets (asm, below)");
/* In assembly: gcc's take was 686 B, the cave's tail 548. As C:
 *
 *   struct sp_msg { uint8_t b[12]; uint32_t e[SP_MAX + 1]; } q;   // the 25 from b[3]: F0 7D 52 54 25 01 seq flags n
 *   // (b[10] flags, b[11] n), then each entry as one big-endian word (slot, fp hi7, fp lo7, count: the words sort
 *   // as slot, then fp), then F7
 *   void sp_sounds(struct sp_msg *q, const volatile uint8_t *d, int32_t n) {   // n sounds of 152 B from d
 *     for (; n; --n, d += 152) {
 *       uint32_t s = d[0x68] - 35, lo = d[0x6f], hi6 = d[0x6e] & 0x3f, w, i, k = q->b[11];
 *       if (s > 4 || !(hi6 | lo)) continue;                        // not U1..U5, or untagged
 *       w = (((s + 1) << 8 | hi6 << 1 | lo >> 7) << 8 | (lo & 0x7f)) << 8;
 *       for (i = 0; i < k && q->e[i] < w; ++i) {}
 *       if (i < k && (q->e[i] ^ w) < 256) { if ((q->e[i] & 0xff) < 127) ++q->e[i]; }   // count, capped
 *       else if (k == SP_MAX) q->b[10] = 1;                        // flags bit 0: more entries than sent
 *       else { for (; k > i; --k) q->e[k] = q->e[k - 1]; q->e[i] = w | 1; ++q->b[11]; }
 *     }
 *   }
 *   void sp_tick(void) {
 *     uint32_t h = us.lgen, i, n;
 *     for (i = 0; i < 16 && PROJECT_NAME[i]; ++i) h = h * 31 + PROJECT_NAME[i];
 *     if (h != sp.load) { sp.load = h; sp.left = SP_SETTLE; sp.rep = SP_REPEAT; return; }   // a load, a name, the boot
 *     if (sp.left && --sp.left) return;
 *     sp.left = SP_SCAN;
 *     q.b[10] = q.b[11] = 0;
 *     for (k = 0; k < 128; ++k) sp_sounds(&q, SP_KIT(k), 12);
 *     sp_sounds(&q, SP_POOL, 128);
 *     n = q.b[11]; h = q.b[10] + 1;
 *     for (i = 0; i < n; ++i) h = h * 31 + q.e[i];
 *     if (h != sp.sum) { sp.sum = h; sp.seq = (sp.seq + 1) & 0x7f; sp.rep = SP_REPEAT; }   // RAM starts 0: the first scan too
 *     if (sp.rep < SP_REPEAT && ++sp.rep < SP_REPEAT) return;   // unchanged: every SP_REPEAT scans
 *     sp.left = 4;                                                 // not sent: again in 4 ticks
 *     if (!ext_ui_lock()) { if (*(volatile uint32_t *)0x413db254 != 1) sp.left = SP_SCAN; return; }   // try-lock;
 *                                                                  // no host (port not configured): at the next scan
 *     if (RING_FILL > 4091 - 200 || !usb_free(8)) { MIDI_UNLOCK(); return; }
 *     // 21 + 73 bytes: room in the ring (the sender spins on a full one, and when it wraps a message over 47 bytes
 *     // while the ring holds wpos - 63 or more, 0x40002a0c) and requests; else not now
 *     q.b[3..9] = F0 7D 52 54 25 01 seq; ((uint8_t *)&q.e[n])[0] = 0xf7;
 *     us_assign_send(&q.b[3], 10 + 4 * n);                         // 10 <project>, the 25; gives the mutex
 *     sp.rep = 0; sp.left = SP_SCAN;
 *   }
 */
__asm__(
"	.pushsection	.us7,\"ax\",@progbits\n"
"	.align	2\n"
"sp_sounds:\n"                            /* a0 q (kept), a1 d, d1 n: sp_tick's own convention */
"	lea	-28(%sp),%sp\n"
"	movem.l	%d2-%d5/%a2-%a4,(%sp)\n"
"	move.l	%d1,%d5\n"                /* n */
"	lea	12(%a0),%a2\n"            /* &q->e[0] */
"1:	mvz.b	0x68(%a1),%d0\n"
"	moveq	#-35,%d1\n"
"	add.l	%d1,%d0\n"                /* s = machine - 35 */
"	moveq	#4,%d1\n"
"	cmp.l	%d1,%d0\n"
"	bhi.s	9f\n"                     /* not U1..U5 */
"	mvz.b	0x6f(%a1),%d2\n"          /* lo */
"	mvz.b	0x6e(%a1),%d1\n"
"	moveq	#0x3f,%d3\n"
"	and.l	%d3,%d1\n"                /* hi6 */
"	move.l	%d1,%d3\n"
"	or.l	%d2,%d3\n"
"	beq.s	9f\n"                     /* untagged */
"	add.l	%d1,%d1\n"
"	move.l	%d2,%d3\n"
"	lsr.l	#7,%d3\n"
"	or.l	%d3,%d1\n"                /* hi7 */
"	addq.l	#1,%d0\n"
"	lsl.l	#8,%d0\n"
"	or.l	%d1,%d0\n"
"	lsl.l	#8,%d0\n"
"	moveq	#0x7f,%d3\n"
"	and.l	%d3,%d2\n"
"	or.l	%d2,%d0\n"
"	lsl.l	#8,%d0\n"                 /* w */
"	mvz.b	11(%a0),%d3\n"            /* k */
"	move.l	%a2,%a3\n"                /* &e[i] */
"	moveq	#0,%d4\n"                 /* i */
"2:	cmp.l	%d3,%d4\n"
"	bcc.s	4f\n"                     /* i == k: a new entry at the end */
"	move.l	(%a3),%d1\n"
"	cmp.l	%d0,%d1\n"
"	bcc.s	3f\n"                     /* e[i] >= w */
"	addq.l	#4,%a3\n"
"	addq.l	#1,%d4\n"
"	bra.s	2b\n"
"3:	eor.l	%d0,%d1\n"
"	lsr.l	#8,%d1\n"
"	bne.s	4f\n"                     /* another (slot, fp): inserted before e[i] */
"	mvz.b	3(%a3),%d2\n"
"	moveq	#127,%d1\n"
"	cmp.l	%d1,%d2\n"
"	bcc.s	9f\n"                     /* count capped */
"	addq.l	#1,(%a3)\n"
"	bra.s	9f\n"
"4:	moveq	#16,%d1\n"                /* SP_MAX */
"	cmp.l	%d1,%d3\n"
"	bne.s	5f\n"
"	moveq	#1,%d1\n"
"	move.b	%d1,10(%a0)\n"            /* flags bit 0: more entries than sent */
"	bra.s	9f\n"
"5:	lea	(%a2,%d3.l*4),%a4\n"      /* &e[k] */
"6:	cmp.l	%a3,%a4\n"
"	bls.s	7f\n"
"	move.l	-(%a4),4(%a4)\n"          /* e[j] = e[j - 1] */
"	bra.s	6b\n"
"7:	addq.l	#1,%d0\n"
"	move.l	%d0,(%a3)\n"              /* e[i] = w | 1 */
"	addq.l	#1,%d3\n"
"	move.b	%d3,11(%a0)\n"
"9:	lea	152(%a1),%a1\n"
"	subq.l	#1,%d5\n"
"	bne.w	1b\n"
"	movem.l	(%sp),%d2-%d5/%a2-%a4\n"
"	lea	28(%sp),%sp\n"
"	rts\n"
"	.globl	sp_tick\n"
"sp_tick:\n"                              /* q at 0(%sp), 80 B; saved d2-d3/a2-a3 at 80 */
"	lea	-96(%sp),%sp\n"
"	movem.l	%d2-%d3/%a2-%a3,80(%sp)\n"
"	lea	sp,%a2\n"                 /* load 0, sum 4, left 8, seq 9, rep 10 */
"	mvz.b	us+52,%d0\n"              /* h = us.lgen */
"	lea	0x407c89d3,%a0\n"         /* PROJECT_NAME */
"	moveq	#16,%d2\n"
"1:	mvz.b	(%a0)+,%d1\n"
"	beq.s	2f\n"
"	moveq	#31,%d3\n"
"	muls.l	%d3,%d0\n"
"	add.l	%d1,%d0\n"
"	subq.l	#1,%d2\n"
"	bne.s	1b\n"
"2:	cmp.l	(%a2),%d0\n"
"	beq.s	3f\n"
"	move.l	%d0,(%a2)\n"              /* a load, another name, the boot: settle first */
"	moveq	#10,%d0\n"                /* SP_SETTLE */
"	move.b	%d0,8(%a2)\n"
"	moveq	#5,%d0\n"                 /* SP_REPEAT: send after the scan */
"	move.b	%d0,10(%a2)\n"
"	bra.w	9f\n"
"3:	mvz.b	8(%a2),%d0\n"
"	beq.s	4f\n"
"	subq.l	#1,%d0\n"
"	move.b	%d0,8(%a2)\n"
"	bne.w	9f\n"
"4:	moveq	#20,%d0\n"                /* SP_SCAN */
"	move.b	%d0,8(%a2)\n"
"	clr.w	10(%sp)\n"                /* q flags, n */
"	move.l	%sp,%a0\n"                /* q */
"	lea	0x4125590d,%a3\n"         /* SP_KIT(0) */
"	moveq	#64,%d3\n"
"	add.l	%d3,%d3\n"                /* 128 kits */
"5:	move.l	%a3,%a1\n"
"	moveq	#12,%d1\n"
"	bsr	sp_sounds\n"
"	lea	2531(%a3),%a3\n"
"	subq.l	#1,%d3\n"
"	bne.s	5b\n"
"	lea	0x41313c47,%a1\n"         /* SP_POOL */
"	moveq	#64,%d1\n"
"	add.l	%d1,%d1\n"                /* 128 sounds */
"	bsr	sp_sounds\n"
"	mvz.b	10(%sp),%d0\n"
"	addq.l	#1,%d0\n"                 /* h = flags + 1 */
"	mvz.b	11(%sp),%d2\n"            /* n */
"	lea	12(%sp),%a0\n"
"	move.l	%d2,%d3\n"
"	beq.s	6f\n"
"5:	moveq	#31,%d1\n"
"	muls.l	%d1,%d0\n"
"	add.l	(%a0)+,%d0\n"
"	subq.l	#1,%d3\n"
"	bne.s	5b\n"
"6:	cmp.l	4(%a2),%d0\n"
"	beq.s	7f\n"
"	move.l	%d0,4(%a2)\n"             /* the content moved: seq too */
"	mvz.b	9(%a2),%d0\n"
"	addq.l	#1,%d0\n"
"	moveq	#0x7f,%d1\n"
"	and.l	%d1,%d0\n"
"	move.b	%d0,9(%a2)\n"
"	moveq	#5,%d0\n"
"	move.b	%d0,10(%a2)\n"            /* rep = SP_REPEAT: send */
"7:	mvz.b	10(%a2),%d0\n"
"	moveq	#5,%d1\n"                 /* SP_REPEAT */
"	cmp.l	%d1,%d0\n"
"	bcc.s	8f\n"                     /* due */
"	addq.l	#1,%d0\n"
"	move.b	%d0,10(%a2)\n"
"	cmp.l	%d1,%d0\n"
"	bcs.w	9f\n"                     /* unchanged, not yet SP_REPEAT scans */
"8:\n"
"	moveq	#4,%d0\n"
"	move.b	%d0,8(%a2)\n"             /* not sent: again in 4 ticks */
"	jsr	ext_ui_lock\n"
"	tst.l	%d0\n"
"	bne.s	12f\n"
"	moveq	#1,%d0\n"
"	cmp.l	0x413db254,%d0\n"         /* the port configured (a host): busy, retry soon */
"	beq.s	9f\n"
"	moveq	#20,%d0\n"                /* no host: at the next scan */
"	move.b	%d0,8(%a2)\n"
"	bra.s	9f\n"
"12:\n"
"	move.l	0x413db258,%d0\n"         /* RING_FILL */
"	cmp.l	#3891,%d0\n"
"	bhi.s	10f\n"
"	pea	8.w\n"
"	jsr	usb_free\n"
"	addq.l	#4,%sp\n"
"	tst.l	%d0\n"
"	bne.s	11f\n"
"10:	jsr	0x40002924\n"             /* MIDI_UNLOCK */
"	bra.s	9f\n"
"11:	moveq	#-16,%d0\n"
"	move.l	%d0,(%sp)\n"              /* F0 in b[3] */
"	move.l	#0x7d525425,%d0\n"
"	move.l	%d0,4(%sp)\n"
"	moveq	#1,%d0\n"
"	move.b	%d0,8(%sp)\n"             /* ver 1 */
"	move.b	9(%a2),9(%sp)\n"          /* seq */
"	move.l	%d2,%d0\n"
"	lsl.l	#2,%d0\n"
"	lea	12(%sp),%a0\n"
"	moveq	#-9,%d1\n"
"	move.b	%d1,(%a0,%d0.l)\n"        /* F7 after the n entries */
"	moveq	#10,%d1\n"
"	add.l	%d1,%d0\n"
"	move.l	%d0,-(%sp)\n"             /* 10 + 4 n */
"	pea	7(%sp)\n"                 /* &q.b[3] */
"	jsr	us_assign_send\n"         /* 10 <project>, the 25; gives the mutex */
"	addq.l	#8,%sp\n"
"	clr.w	10(%a2)\n"                /* rep, pad */
"	moveq	#20,%d0\n"
"	move.b	%d0,8(%a2)\n"
"9:	movem.l	80(%sp),%d2-%d3/%a2-%a3\n"
"	lea	96(%sp),%sp\n"
"	rts\n"
"	.popsection\n");
void sp_tick(void);
US4 int32_t us_live(void) {
  struct us_ram *u = &us;
  int32_t r = 0;
  if (!u->ch) sp_tick();   /* 25 SLOT PRINTS (.us7, above); not while the machine list previews a machine (us_step) */
  if (!u->done) return 0;
  if (u->st && u->st->got == 0xff) {
    us_commit();
    r = 1;
  }
  us_live_ask(u);
  return r;
}
struct ext_stepbox { uint32_t magic; int32_t (*steps)(int32_t); int32_t (*live)(void); };
const struct ext_stepbox ext_stepbox __attribute__((section(".usm"), aligned(4))) = {0x58535450u, ext_steps, us_live};
#endif   /* EXT_SLOTS */
