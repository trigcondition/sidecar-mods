/*
 * 0020-dmach: digital machines on the Rytm's digital layer.
 *
 * Each engine replaces a hidden machine's engine routine,
 * routine(voice, frame, params, pitch), called once per 32-sample block for each
 * voice that plays it. It renders into the voice's digital-layer buffer A
 * (0x80006bf8 + 128v, 32 Q31 samples), which voice_output_mix sends to the voice's
 * DAC channel and so through its analog filter, overdrive and amp; buffer B and
 * the sample gain are zeroed and the voice's analog oscillators muted (BD, SD and
 * RS/CP: their LEVEL CVs). State lives in the voice's own 32-byte block at
 * 0x8000fef8 + 32v, which the firmware zeroes on a trig. Pitch is the trig's note
 * (chromatic play moves it) plus TUN; velocity is read per track at the trig.
 *
 * Engines (machine: stored parameters):
 *   42 EFM    two-operator FM drum      LEV TUN DEC FMT FMD NOD NOL FMA
 *   41 FMBD   FM kick with pitch sweep  LEV TUN DEC FMA SWT FMS FMD FMT
 *   39 GND    swept sine percussion     LEV TUN DEC SWD TIC NOL SYM SWT
 *   38 SWAV   superwave (5 saws)        LEV TUN DEC DET SNP NOD NOL BAL
 *   35 FM4    four-operator FM          IXA TUN DEC IXB RTA RTB ALG FB (slots LEV..TIC)
 *             page 2 on SMPL            DTN PSW ATK END DCB VEL RTC LEV (slots 8..15)
 *
 * The phase-modulation and interpolated-sine cores follow Mutable Instruments
 * Braids (MIT, (c) 2012 Emilie Gillet); the rest is this mod's.
 */
#include <stdint.h>

#define TEXT __attribute__((section(".text")))
#include "dmach_tables.h"

#define BUF_A(v)    ((int32_t *)(0x80006bf8u + 128u * (v)))
#define BUF_B(v)    ((int32_t *)(0x80007040u + 128u * (v)))
#define SGAIN(v)    ((int32_t *)(0x80007000u + 8u * (v)))
#define STATE(v)    ((int32_t *)(0x8000fef8u + 32u * (v)))
/* The track that owns a physical voice; the trig velocity per track (high byte
   of a 16-bit word). Found in rytm-emu by diffing RAM between hits, 2026-10-06. */
#define OWNER(v)    (((const uint8_t *)0x40290dd8u)[v])
#define VELOCITY(t) (((const uint8_t *)0x800067c4u)[2u * (t)])

#define P(i) ((uint32_t)(uint16_t)params[i] >> 8)   /* stored param i, 0..127 */

static const uint8_t ratio_q2[16] TEXT = {2, 4, 6, 8, 10, 12, 14, 16, 20, 24, 28, 32, 36, 44, 52, 64};

static inline int32_t sine(uint32_t phase) {
  uint32_t i = phase >> 24;
  int32_t a = sine_table[i], b = sine_table[i + 1];
  int32_t f = (phase >> 9) & 0x7fff;
  return a + (((b - a) * f) >> 15);
}

/* Phase increment for a note in 1/128 semitones (MIDI numbering), 48 kHz. */
static uint32_t note_increment(int32_t n7) {
  int32_t n = n7 >> 7, frac = n7 & 127, shifts = 0;
  if (n > 119) { n = 119; frac = 127; }
  int32_t k = n - 108;
  while (k < 0) { k += 12; ++shifts; }
  if (shifts > 31) return 0;
  uint32_t a = note_inc[k], b = note_inc[k + 1];
  return (a + (((int32_t)(b - a) >> 7) * frac)) >> shifts;
}

/* Envelope levels are Q30 (1.0 = 1 << 30); one block's decay at a 0..127 knob. */
static inline int32_t decay(int32_t env, uint32_t knob) {
  return (env >> 15) * decay_q15[knob & 127];
}

/* Per block: clear B and the sample gain, mute the analog oscillators, handle a
   trig (state word 0 == 0: returns 1 and stores the velocity scale 48..128 in
   word 7). Returns -1 when the voice is idle (A already zeroed). */
static int begin(int32_t voice, uint8_t *frame, int32_t *st, int32_t *a) {
  int32_t *b = BUF_B(voice), *g = SGAIN(voice);
  int i;
  g[0] = g[1] = 0;
  for (i = 0; i < 32; ++i) b[i] = 0;
  int cv = voice == 0 ? 90 : voice == 2 ? 98 : voice == 7 ? 106 : 0;
  if (cv) frame[cv + 4] = frame[cv + 5] = frame[cv + 6] = frame[cv + 7] = 0;
  if (st[0] == 0) {
    st[0] = 1;
    st[7] = 48 + ((int32_t)(VELOCITY(OWNER(voice)) & 127) * 80) / 127;
    return 1;
  }
  if (st[0] != 1) {
    for (i = 0; i < 32; ++i) a[i] = 0;
    return -1;
  }
  return 0;
}

static inline uint32_t lfsr_next(uint32_t x) { return (x >> 1) ^ (-(x & 1u) & 0xd0000001u); }

/* ---------------------------------------------------------------- 42 EFM */
void efm_render(int32_t voice, uint8_t *frame, const int16_t *params, int32_t pitch) {
  int32_t *st = STATE(voice), *a = BUF_A(voice);
  int i, r = begin(voice, frame, st, a);
  if (r < 0) return;
  uint32_t lev = P(0), tun = P(1), dec = P(2), fmt = P(3), fmd = P(4), nod = P(5), nol = P(6), fma = P(7);
  if (r) {  /* state: 1 carrier, 2 modulator, 3 amp, 4 mod env, 5 noise env, 6 lfsr */
    st[1] = st[2] = 0;
    st[3] = st[4] = st[5] = 1 << 30;
    if (st[6] == 0) st[6] = 0x1234567;
  }
  int32_t vel = st[7];
  uint32_t cinc = note_increment((pitch >> 9) + ((int32_t)tun - 64) * 64);
  uint32_t minc = (cinc >> 2) * ratio_q2[(fmt >> 3) & 15];
  int32_t amp0 = st[3], amp1 = decay(amp0, dec), mod0 = st[4], mod1 = decay(mod0, fmd);
  int32_t noi0 = st[5], noi1 = decay(noi0, nod);
  int32_t damp = (amp1 - amp0) >> 5, dmod = (mod1 - mod0) >> 5, dnoi = (noi1 - noi0) >> 5;
  uint32_t cph = st[1], mph = st[2], lfsr = st[6];
  int32_t amp = amp0, mod = mod0, noi = noi0;
  int32_t depth = ((int32_t)fma << 8) * vel >> 7;
  nol = (nol * (uint32_t)vel) >> 7;
  for (i = 0; i < 32; ++i) {
    mph += minc;
    cph += cinc;
    int32_t m = sine(mph);
    int32_t idx = (depth * (mod >> 15)) >> 15;
    int32_t s = sine(cph + (uint32_t)((m * idx) << 3));
    lfsr = lfsr_next(lfsr);
    int32_t n = ((int32_t)(int16_t)lfsr * (int32_t)nol) >> 7;
    int32_t y = ((s * (amp >> 15)) >> 15) + ((n * (noi >> 15)) >> 15);
    a[i] = (y * (int32_t)lev) << 9;
    amp += damp; mod += dmod; noi += dnoi;
  }
  st[1] = cph; st[2] = mph; st[3] = amp1; st[4] = mod1; st[5] = noi1; st[6] = lfsr;
  if (amp1 < (1 << 16) && noi1 < (1 << 16)) st[0] = -1;
}

/* --------------------------------------------------------------- 41 FMBD */
/* An FM kick: the carrier falls from TUN + FMS (up to 4 octaves above) to TUN
   with time SWT; a sine modulator at FMT's ratio, depth FMA decaying with FMD. */
__attribute__((section(".fmbd")))
void fmbd_render(int32_t voice, uint8_t *frame, const int16_t *params, int32_t pitch) {
  int32_t *st = STATE(voice), *a = BUF_A(voice);
  int i, r = begin(voice, frame, st, a);
  if (r < 0) return;
  uint32_t lev = P(0), tun = P(1), dec = P(2), fma = P(3), swt = P(4), fms = P(5), fmd = P(6), fmt = P(7);
  if (r) {  /* state: 1 carrier, 2 modulator, 3 amp, 4 mod env, 5 sweep env */
    st[1] = st[2] = 0;
    st[3] = st[4] = st[5] = 1 << 30;
  }
  int32_t vel = st[7];
  int32_t sw0 = st[5], sw1 = decay(sw0, swt >> 1);
  /* Pitch for this block from the sweep at its middle (1/128 semitones). */
  int32_t swmid = (sw0 + sw1) >> 1;
  int32_t n7 = (pitch >> 9) + ((int32_t)tun - 64) * 64 + (((swmid >> 15) * (int32_t)fms * 3) >> 9) * 2;
  uint32_t cinc = note_increment(n7);
  uint32_t minc = (cinc >> 2) * ratio_q2[(fmt >> 3) & 15];
  int32_t amp0 = st[3], amp1 = decay(amp0, dec), mod0 = st[4], mod1 = decay(mod0, fmd);
  int32_t damp = (amp1 - amp0) >> 5, dmod = (mod1 - mod0) >> 5;
  uint32_t cph = st[1], mph = st[2];
  int32_t amp = amp0, mod = mod0;
  int32_t depth = ((int32_t)fma << 8) * vel >> 7;
  for (i = 0; i < 32; ++i) {
    mph += minc;
    cph += cinc;
    int32_t idx = (depth * (mod >> 15)) >> 15;
    int32_t s = sine(cph + (uint32_t)((sine(mph) * idx) << 3));
    a[i] = (((s * (amp >> 15)) >> 15) * (int32_t)lev) << 9;
    amp += damp; mod += dmod;
  }
  st[1] = cph; st[2] = mph; st[3] = amp1; st[4] = mod1; st[5] = sw1;
  if (amp1 < (1 << 16)) st[0] = -1;
}

/* ---------------------------------------------------------------- 39 GND */
/* Digital percussion: a sine swept down by SWD over SWT, shaped toward a square
   by SYM, a click (TIC) at the start and noise (NOL) under the same decay. */
__attribute__((section(".gnd")))
void gnd_render(int32_t voice, uint8_t *frame, const int16_t *params, int32_t pitch) {
  int32_t *st = STATE(voice), *a = BUF_A(voice);
  int i, r = begin(voice, frame, st, a);
  if (r < 0) return;
  uint32_t lev = P(0), tun = P(1), dec = P(2), swd = P(3), tic = P(4), nol = P(5), sym = P(6), swt = P(7);
  if (r) {  /* state: 1 phase, 2 amp, 3 sweep env, 4 click env, 5 lfsr */
    st[1] = 0;
    st[2] = st[3] = st[4] = 1 << 30;
    if (st[5] == 0) st[5] = 0x2468ace;
  }
  int32_t vel = st[7];
  int32_t sw0 = st[3], sw1 = decay(sw0, swt >> 1);
  int32_t n7 = (pitch >> 9) + ((int32_t)tun - 64) * 64 + ((((sw0 + sw1) >> 16) >> 15) * (int32_t)swd * 6 >> 0);
  uint32_t inc = note_increment(n7);
  int32_t amp0 = st[2], amp1 = decay(amp0, dec), ck0 = st[4], ck1 = decay(ck0, 8);
  int32_t damp = (amp1 - amp0) >> 5, dck = (ck1 - ck0) >> 5;
  uint32_t ph = st[1], lfsr = st[5];
  int32_t amp = amp0, ck = ck0;
  int32_t drive = 1 + (int32_t)sym / 8;            /* 1..16: sine toward square */
  int32_t tl = ((int32_t)tic * vel) >> 7, nl = ((int32_t)nol * vel) >> 7;
  for (i = 0; i < 32; ++i) {
    ph += inc;
    int32_t s = sine(ph) * drive;
    if (s > 32767) s = 32767;
    if (s < -32767) s = -32767;
    lfsr = lfsr_next(lfsr);
    int32_t n = (int32_t)(int16_t)lfsr;
    int32_t y = s + ((n * nl) >> 7);
    y = (y * (amp >> 15)) >> 15;
    y += (((ck >> 15) * tl) >> 7) * ((lfsr & 1) ? 1 : -1) >> 1;  /* the click */
    if (y > 32767) y = 32767;
    if (y < -32767) y = -32767;
    a[i] = (y * (int32_t)lev) << 9;
    amp += damp; ck += dck;
  }
  st[1] = ph; st[2] = amp1; st[3] = sw1; st[4] = ck1; st[5] = lfsr;
  if (amp1 < (1 << 16)) st[0] = -1;
}

/* --------------------------------------------------------------- 38 SWAV */
/* A superwave: five saws spread by DET (up to about +-27 cents), the centre's
   level against the sides by BAL, a one-pole low-pass opened by SNP (and by
   velocity), a breath of noise under NOD/NOL. */
__attribute__((section(".swav")))
void swav_render(int32_t voice, uint8_t *frame, const int16_t *params, int32_t pitch) {
  int32_t *st = STATE(voice), *a = BUF_A(voice);
  int i, k, r = begin(voice, frame, st, a);
  if (r < 0) return;
  uint32_t lev = P(0), tun = P(1), dec = P(2), det = P(3), snp = P(4), nod = P(5), nol = P(6), bal = P(7);
  /* state: 1..5 saw phases, 6 amp (Q30), 7 velocity (low byte) | noise env (high 16) */
  if (r) {
    for (k = 1; k <= 5; ++k) st[k] = (uint32_t)k * 0x33333333u;  /* spread start phases */
    st[6] = 1 << 30;
    st[7] = (st[7] & 0xff) | (0x7fff << 16);
  }
  int32_t vel = st[7] & 0xff;
  int32_t noi0 = (int32_t)((uint32_t)st[7] >> 16) << 15, noi1 = decay(noi0, nod);
  uint32_t inc = note_increment((pitch >> 9) + ((int32_t)tun - 64) * 64);
  int32_t d = (int32_t)((inc >> 7) * det >> 7);
  uint32_t incs[5] = {inc - 2 * d, inc - d, inc, inc + d, inc + 2 * d};
  int32_t side = (int32_t)bal * 2, centre = 256 - side;     /* /256 */
  int32_t amp0 = st[6], amp1 = decay(amp0, dec);
  int32_t damp = (amp1 - amp0) >> 5, dnoi = (noi1 - noi0) >> 5;
  int32_t amp = amp0, noi = noi0;
  /* Low-pass coefficient (Q15): SNP plus velocity, 0..127 -> about 400 Hz .. open. */
  int32_t cut = (int32_t)snp + ((vel - 88) >> 1);
  if (cut < 4) cut = 4;
  if (cut > 127) cut = 127;
  int32_t coef = cut * 258;
  int32_t lp = st[5] >> 31 ? 0 : 0;  /* filter state is not kept across blocks */
  uint32_t ph0 = st[1], ph1 = st[2], ph2 = st[3], ph3 = st[4], ph4 = st[5];
  uint32_t rnd = ph1 ^ (ph3 >> 7);
  for (i = 0; i < 32; ++i) {
    ph0 += incs[0]; ph1 += incs[1]; ph2 += incs[2]; ph3 += incs[3]; ph4 += incs[4];
    int32_t sides = ((int32_t)(ph0 >> 16) - 32768) + ((int32_t)(ph1 >> 16) - 32768)
                  + ((int32_t)(ph3 >> 16) - 32768) + ((int32_t)(ph4 >> 16) - 32768);
    int32_t mid = (int32_t)(ph2 >> 16) - 32768;
    int32_t s = ((sides >> 2) * side + mid * centre) >> 8;
    rnd = rnd * 1664525u + 1013904223u;
    s += ((((int32_t)(int16_t)(rnd >> 16)) * (int32_t)nol) >> 7) * (noi >> 15) >> 15;
    lp += ((s - lp) * coef) >> 15;
    a[i] = ((((lp * (amp >> 15)) >> 15) * (int32_t)lev) << 9);
    amp += damp; noi += dnoi;
  }
  st[1] = ph0; st[2] = ph1; st[3] = ph2; st[4] = ph3; st[5] = ph4; st[6] = amp1;
  st[7] = (st[7] & 0xff) | ((noi1 >> 15) << 16);
  if (amp1 < (1 << 16)) st[0] = -1;
}

/* ---------------------------------------------------------------- 35 FM4 */
/* A small four-operator FM voice. Operators 1..4, each a sine; 1 is the carrier
   (ratio RTC to the note), 2 runs at ratio RTA with level IXA, 3 and 4 at ratio
   RTB with level IXB, and 4 feeds back on itself (FB). ALG picks one of the eight
   classic four-operator routings (modulation flows from higher to lower numbers):
     0  4>3>2>1          4  4>3, 2>1; carriers 1, 3
     1  (3+4)>2>1        5  4>1, 4>2, 4>3; carriers 1, 2, 3
     2  3>2>1, 4>1       6  4>3; carriers 1, 2, 3
     3  4>3>1, 2>1       7  all four carriers
   Two modulator envelopes: after an attack (ATK) A falls with DEC and B with DCB
   (0: twice as fast as A) toward the sustain level END; 127 holds. IXA follows A,
   IXB follows B. Velocity scales both by VEL's amount. PSW sweeps the pitch with
   envelope A (64 none), DTN detunes operators 2..4 against 1. No amp envelope of
   its own: the voice's AMP page shapes the level.

   Page 1 (SRC): machine 35's own records, renamed; slots 0..7 used as IXA TUN DEC
   IXB RTA RTB ALG FB. Page 2 (SMPL): the track's sample slots 8..15 (the sample
   layer is muted while a digital machine plays), shown through FM4's own records
   by fm4_param_record below; used as DTN PSW ATK END DCB VEL RTC LEV. The SMPL
   defaults (64 64 0 0 0 120 0 100) are this page's neutral settings, since a
   machine change does not reload them.

   Since 2026-10-07 (after DT-FM's engine, MIT): the voice sleeps once its AMP
   envelope has ended (a 128-sample fade, then nothing is rendered until the next
   trig); IXA, IXB, FB and LEV glide over a few blocks; a retrigger crossfades
   from the last sample; the mod param fm4_half renders at 24 kHz. */
#define FM4 __attribute__((section(".fm4")))
#define FM4H __attribute__((section(".fm4h")))
#define FM4D __attribute__((section(".fm4d"), used))
#define PM(v) ((uint32_t)(v) << 3)   /* Q30 level x sine -> phase, 2 cycles at full */
#define ONE30 (1 << 30)

/* Ratios in quarters, one per RTA/RTB step (0..21): 0.25 .. 16. */
static const uint8_t fm4_ratio_q2[22] FM4D = {1, 2, 3, 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 64};
/* Carrier ratios in quarters, RTC 0..8: 1 first (the SMPL default 0), then 0.5, 2..8. */
static const uint8_t fm4_rtc_q2[9] FM4D = {4, 2, 8, 12, 16, 20, 24, 28, 32};
/* The algorithms as routing bits: 0 4>3, 1 3>2, 2 4>2, 3 2>1, 4 3>1, 5 4>1,
   6..8 operators 2, 3, 4 are carriers (1 always is). */
static const uint16_t fm4_route[8] FM4D = {
  0x00b,  /* 0  4>3>2>1 */
  0x00e,  /* 1  (3+4)>2>1 */
  0x02a,  /* 2  3>2>1, 4>1 */
  0x019,  /* 3  4>3>1, 2>1 */
  0x089,  /* 4  4>3, 2>1; carriers 1, 3 */
  0x0e5,  /* 5  4>1, 4>2, 4>3; carriers 1, 2, 3 */
  0x0c1,  /* 6  4>3; carriers 1, 2, 3 */
  0x1c0,  /* 7  all four carriers */
};
/* Output gain (Q15) per algorithm: about 1 / sqrt(number of carriers), the sum
   clipped after it. */
static const int16_t fm4_gain[8] FM4D = {32767, 32767, 32767, 32767, 23170, 18919, 18919, 16384};

/* Names for machine 35, its knobs and its page 2 (the parameter records and the
   machine name table point here; registry patches). */
const char fm4_long[] FM4D = "FM4 4-OP";
const char fm4_short[] FM4D = "FM4";
const char fm4_n_ixa[] FM4D = "Index A";
const char fm4_s_ixa[] FM4D = "IXA";
const char fm4_n_dec[] FM4D = "Decay A";
const char fm4_n_ixb[] FM4D = "Index B";
const char fm4_s_ixb[] FM4D = "IXB";
const char fm4_n_rta[] FM4D = "Ratio A";
const char fm4_s_rta[] FM4D = "RTA";
const char fm4_n_rtb[] FM4D = "Ratio B";
const char fm4_s_rtb[] FM4D = "RTB";
const char fm4_n_alg[] FM4D = "Algorithm";
const char fm4_s_alg[] FM4D = "ALG";
const char fm4_n_fb[] FM4D = "Feedback";
const char fm4_s_fb[] FM4D = "FB";
const char fm4_n_dtn[] FM4D = "Detune";
const char fm4_s_dtn[] FM4D = "DTN";
const char fm4_n_psw[] FM4D = "Pitch Sweep";
const char fm4_s_psw[] FM4D = "PSW";
const char fm4_n_atk[] FM4D = "Attack";
const char fm4_s_atk[] FM4D = "ATK";
const char fm4_n_end[] FM4D = "Env End Level";
const char fm4_s_end[] FM4D = "END";
const char fm4_n_dcb[] FM4D = "Decay B";
const char fm4_s_dcb[] FM4D = "DCB";
const char fm4_n_vel[] FM4D = "Velocity Mod";
const char fm4_s_vel[] FM4D = "VEL";
const char fm4_n_rtc[] FM4D = "Ratio C";
const char fm4_s_rtc[] FM4D = "RTC";
const char fm4_n_lev[] FM4D = "Level";
const char fm4_s_lev[] FM4D = "LEV";

/* sound_param_record(index, machine) at 0x40007028, replaced whole (detour,
   rejoin none): the parameter record for a sound parameter index. Stock behaviour
   [measured, disassembly 2026-10-07]: indices above 41 have none (0); 9..16 are the
   machine's, from the per-machine table 0x413db5fc (53 x 8, built at boot); the
   rest from 0x413db554 by index. The one change: SMPL's indices 17..24 on machine
   35 give FM4's page-2 records (449..456, CY TEST's, rewritten by the registry),
   on any other machine the stock SMPL records 39..46. Computed rather than read
   from 0x413db554, because the boot scan files the rewritten records there too. */
#define RID_SMPL 39
#define RID_FM4P2 449
FM4H int32_t fm4_param_record(uint32_t index, uint32_t machine) {
  if (index > 41) return 0;
  if (index - 9 <= 7) {
    if (machine > 52) return 0;
    return ((const int32_t *)0x413db5fcu)[machine * 8 + index - 9];
  }
  if (index - 17 <= 7) return (machine == 35 ? RID_FM4P2 : RID_SMPL) + (int32_t)index - 17;
  return ((const int32_t *)0x413db554u)[index];
}

/* The SMPL page itself does not ask sound_param_record: a parameter page view
   (base class shared by the TRIG/SMPL/FLTR/AMP/LFO pages; vtable slots 0x68
   page id, 0x90 and the record/title methods are common [measured, vtables at
   0x401e31bc.. compared 2026-10-07]) takes its eight records and title from the
   static page table page_info(id) = 0x4028843c + 36 id {title, 8 records in
   display order}; ids 4 and 5 are SMPL. The two generic methods are replaced
   whole: on an SMPL page whose sound plays machine 35 they answer FM4's page 2.
   The view's machine is found as the SRC page's own record method (0x400d3544)
   finds it: vtable 0x90 (a sound slot, or < 0), then the sound from the view's
   track (+116, +120) or that slot (+104), then the sound's machine. */
typedef int32_t (*fn1)(int32_t);
typedef int32_t (*fn2)(int32_t, int32_t);
#define PAGE_INFO(id)   ((const int32_t *)((fn1)0x400ff574)(id))
#define VCALL(v, off)   (((fn1)(*(int32_t **)(v))[(off) / 4])((int32_t)(v)))
static const int32_t fm4_p2_records[8] FM4D = {449, 450, 452, 451, 453, 454, 455, 456};  /* display order */
const char fm4_p2_title[] FM4D = "FM4 PAGE 2";

FM4H static int fm4_view_is_fm4(const int32_t *view, int32_t id) {
  if (id != 4 && id != 5) return 0;
  int32_t slot = VCALL(view, 0x90), sound;
  if (slot < 0) sound = ((fn2)0x400a675e)(view[30], ((fn1)0x400b68d2)(view[29]));
  else sound = ((fn2)0x400ae494)(view[26], slot);
  return ((fn1)0x400bca70)(sound) == 35;
}

/* 0x4003795a: record of knob k (0..7) on a parameter page. */
FM4H int32_t fm4_page_record(const int32_t *view, uint32_t k) {
  if (k > 7) return 0;
  int32_t id = VCALL(view, 0x68);
  if (fm4_view_is_fm4(view, id)) return fm4_p2_records[k];
  return PAGE_INFO(id)[1 + k];
}

/* 0x4003793c: a parameter page's title. */
FM4H int32_t fm4_page_title(const int32_t *view) {
  int32_t id = VCALL(view, 0x68);
  if (fm4_view_is_fm4(view, id)) return (int32_t)fm4_p2_title;
  return PAGE_INFO(id)[0];
}

/* An envelope (Q30) one block on toward `end` at a 0..127 decay knob (127 holds). */
FM4H static inline int32_t fm4_fall(int32_t e, int32_t end, uint32_t knob) {
  return knob >= 127 ? e : end + decay(e - end, knob);
}

/* Per-voice state beyond the voice's 32-byte block, in a cave claimed as RAM
   (zero at boot): slewed IXA/IXB/FB/LEV (Q1, 0..254), the last output and the
   retrigger crossfade, the release-fade counter and the release travel. */
struct fm4x {
  uint8_t s[4];
  int16_t last, tail;
  uint8_t tr, fade, live, pad;
  uint32_t travel;
  uint32_t spare[4];
};
__attribute__((section(".fm4s"))) struct fm4x fm4_ext[8];

/* FM4_HALF (mod param fm4_half): render at 24 kHz and interpolate to 48. */
extern char P_FM4_HALF[];
#define FM4_HALF ((uint32_t)P_FM4_HALF & 1)

/* 1 when the voice's AMP envelope has surely reached silence: its record (control
   frame +168 + 8v: start 2, target 3, mode nibble 4, then a 20-bit rate, 4-bit
   exponent over 16-bit mantissa, as the OS's encoder 0x4011e7ae writes and its
   decoder 0x4011e780 reads) has a target at or below 0 and is ramping, and the
   ramp has covered 160 levels since. Ramping: bit 20 set (a finite AMP DEC's
   release: `.. 0080 0010 0000`) or a ramp mode (9, B, F). Not ramping: a hold
   (mode 3), or bit 20 clear (AMP DEC infinite after a release: all zero; the
   held attack: `.. 007f 0000 0000`) [records measured in rytm-emu, 2026-10-07]. */
FM4H static int fm4_amp_done(const uint8_t *r, struct fm4x *x) {
  uint32_t w = (uint32_t)r[4] << 24 | (uint32_t)r[5] << 16 | (uint32_t)r[6] << 8 | r[7];
  uint32_t mode = r[4] >> 4;
  int ramp = (w >> 20 & 1) || mode == 0x9 || mode == 0xb || mode == 0xf;
  if ((int8_t)r[3] > 0 || mode == 3 || !ramp) {
    x->travel = 0;
    return 0;
  }
  /* Levels << 23 per two samples (the OS's decoder 0x4011e780), x16 a block. */
  uint32_t step = (0x7fffffffu - ((w & 0xffff) << 14)) >> ((w >> 16) & 15);
  uint32_t add = step >= (1u << 28) ? 0xffffffffu : step << 4;
  x->travel = x->travel + add < x->travel ? 0xffffffffu : x->travel + add;
  return x->travel >= (160u << 23);
}

FM4H static inline uint8_t fm4_slew(uint8_t s, uint32_t knob) {
  int32_t d = (int32_t)(knob << 1) - s;
  return (uint8_t)(s + (d > 0 ? (d + 3) >> 2 : -((3 - d) >> 2)));
}

/* sine(), forced inline in FM4's sample loop (-Os otherwise calls it, which
   cost about 45 instructions a sample). */
static inline __attribute__((always_inline)) int32_t fm4_sine(uint32_t phase) {
  uint32_t i = phase >> 24;
  int32_t a = sine_table[i], b = sine_table[i + 1];
  int32_t f = (phase >> 9) & 0x7fff;
  return a + (((b - a) * f) >> 15);
}

/* One block's precomputed values, from fm4_prep (block rate) for the sample loop. */
struct fm4blk {
  uint32_t i1, i2, i3, i4;
  int32_t la, lb, dla, dlb, lq, dlq, g, fbs;
  uint32_t rt;
  int n, half;
};

/* Block-rate work, in .fm4h (another cave): parameters, envelopes, slews, the
   retrigger and sleep bookkeeping. */
FM4H void fm4_prep(int32_t voice, uint8_t *frame, const int16_t *params, int32_t pitch,
                   int32_t *st, struct fm4x *x, int r, struct fm4blk *k) {
  int32_t ixa = P(0), tun = P(1), dec = P(2), ixb = P(3);
  uint32_t rta = P(4), rtb = P(5), alg = P(6) & 7, fb = P(7);
  int32_t dtn = (int32_t)P(8) - 64, psw = (int32_t)P(9) - 64;
  uint32_t atk = P(10), dcb = P(12), rtc = P(14);
  int32_t end = (int32_t)P(11) << 23, vam = P(13);
  uint32_t lev = P(15);
  if (rta > 21) rta = 21;
  if (rtb > 21) rtb = 21;
  if (rtc > 8) rtc = 8;
  if (end > ONE30) end = ONE30;
  /* state: 1..4 phases; 5 envelope A (Q30; bit 0 set once the attack is over);
     6 feedback history; 7 envelope B (Q23, bits 8..31) | velocity scale (bits 0..7) */
  if (r) {
    st[1] = st[2] = st[3] = st[4] = 0;
    st[5] = atk ? 0 : ONE30 | 1;
    st[6] = 0;
    st[7] = (st[7] & 0xff) | (0x7fffff << 8);
    /* A retrigger over a sounding note crossfades from its last sample. */
    if (x->last) {
      x->tail = x->last;
      x->tr = 64;
    } else {
      x->tr = 0;
    }
    x->s[0] = ixa << 1; x->s[1] = ixb << 1; x->s[2] = fb << 1; x->s[3] = lev << 1;
    x->fade = 0;
    x->travel = 0;
  }
  /* Sleep once the AMP envelope has ended: fade over 128 samples, then idle
     until the next trig (the block driver zeroes the state on a trig). */
  if (!x->fade && fm4_amp_done(frame + 168 + 8 * voice, x)) x->fade = 128;
  int32_t vel = 128 - (((128 - (st[7] & 0xff)) * vam) >> 7);
  int32_t e0 = st[5] & ~1, b0 = (int32_t)((uint32_t)st[7] >> 8) << 7, e1, b1, ga0, ga1, gb0, gb1;
  if (!(st[5] & 1)) {             /* attack: both groups rise together */
    e1 = e0 + ((32768 - decay_q15[atk]) << 15);
    if (e1 >= ONE30) e1 = ONE30;
    ga0 = gb0 = e0 >> 15; ga1 = gb1 = e1 >> 15;
    b1 = ONE30;
    st[5] = e1 | (e1 >= ONE30);
  } else {
    e1 = fm4_fall(e0, end, dec);
    b1 = fm4_fall(b0, end, dcb ? dcb : (dec > 12 ? dec - 12 : 0));
    ga0 = e0 >> 15; ga1 = e1 >> 15; gb0 = b0 >> 15; gb1 = b1 >> 15;
    st[5] = e1 | 1;
  }
  st[7] = (st[7] & 0xff) | ((uint32_t)(b1 >> 7) << 8);
  /* Slewed knobs: the block ramps from last block's values to this one's. */
  int32_t xa0 = x->s[0], xb0 = x->s[1], lv0 = x->s[3];
  x->s[0] = fm4_slew(x->s[0], ixa); x->s[1] = fm4_slew(x->s[1], ixb);
  x->s[2] = fm4_slew(x->s[2], fb); x->s[3] = fm4_slew(x->s[3], lev);
  int32_t xa1 = x->s[0], xb1 = x->s[1], lv1 = x->s[3];
  k->fbs = x->s[2] >> 1;
  int32_t n7 = (pitch >> 9) + (tun - 64) * 64 + ((psw * ((e0 + e1) >> 16)) >> 8);
  uint32_t note = note_increment(n7);
  uint32_t i2 = (note >> 2) * fm4_ratio_q2[rta], i3 = (note >> 2) * fm4_ratio_q2[rtb];
  i2 += (int32_t)(i2 >> 11) * dtn;
  i3 -= (int32_t)(i3 >> 11) * dtn;
  int half = FM4_HALF, sh = half ? 4 : 5;
  k->half = half;
  k->n = half ? 16 : 32;
  k->i1 = ((note >> 2) * fm4_rtc_q2[rtc]) << half;
  k->i2 = i2 << half;
  k->i3 = i3 << half;
  k->i4 = (i3 + (int32_t)(i3 >> 12) * dtn) << half;
  /* Operator levels (Q15) at the block's start and end (knobs in Q1). */
  k->la = (ga0 * xa0 * vel) >> 15;
  k->lb = (gb0 * xb0 * vel) >> 15;
  k->dla = (((ga1 * xa1 * vel) >> 15) - k->la) >> sh;
  k->dlb = (((gb1 * xb1 * vel) >> 15) - k->lb) >> sh;
  k->lq = lv0 << 8;
  k->dlq = ((lv1 - lv0) << 8) >> sh;          /* level, Q1 << 8 */
  k->g = fm4_gain[alg];
  k->rt = fm4_route[alg];
}

FM4 void fm4_render(int32_t voice, uint8_t *frame, const int16_t *params, int32_t pitch) {
  int32_t *st = STATE(voice), *a = BUF_A(voice);
  struct fm4x *x = &fm4_ext[voice & 7];
  struct fm4blk k;
  int i, r = begin(voice, frame, st, a);
  if (r < 0) {
    x->last = 0;
    return;
  }
  fm4_prep(voice, frame, params, pitch, st, x, r, &k);
  uint32_t p1 = st[1], p2 = st[2], p3 = st[3], p4 = st[4], rt = k.rt;
  int32_t y1 = (int16_t)st[6], y2 = st[6] >> 16;
  int32_t la = k.la, lb = k.lb, lq = k.lq, fbs = k.fbs, g = k.g, half = k.half;
  uint32_t i1 = k.i1, i2 = k.i2, i3 = k.i3, i4 = k.i4;
  int32_t dla = k.dla, dlb = k.dlb, dlq = k.dlq, n = k.n;
  int32_t m34 = -(int32_t)(rt & 1), m23 = -(int32_t)(rt >> 1 & 1), m24 = -(int32_t)(rt >> 2 & 1);
  int32_t m12 = -(int32_t)(rt >> 3 & 1), m13 = -(int32_t)(rt >> 4 & 1), m14 = -(int32_t)(rt >> 5 & 1);
  int32_t c2 = -(int32_t)(rt >> 6 & 1), c3 = -(int32_t)(rt >> 7 & 1), c4 = -(int32_t)(rt >> 8 & 1);
  /* The hot loop writes n samples (Q15 in the low half) at the start of A; the
     crossfade, release fade and half-rate expansion run after it, and only the
     first two only while they are active. */
  for (i = 0; i < n; ++i) {
    p1 += i1; p2 += i2; p3 += i3; p4 += i4;
    int32_t o4 = fm4_sine(p4 + ((uint32_t)((y1 + y2) * fbs) << 8));
    y2 = y1; y1 = o4;
    int32_t v4 = o4 * lb;
    /* The routing as masks: what modulates operators 3, 2 and 1, and which of
       2..4 are carriers besides 1 (fm4_route). */
    int32_t v3 = fm4_sine(p3 + PM(v4 & m34)) * lb;
    int32_t v2 = fm4_sine(p2 + PM((uint32_t)(v3 & m23) + (uint32_t)(v4 & m24))) * la;
    int32_t out = fm4_sine(p1 + PM((uint32_t)(v2 & m12) + (uint32_t)(v3 & m13) + (uint32_t)(v4 & m14)))
                + ((v2 & c2) >> 15) + ((v3 & c3) >> 15) + ((v4 & c4) >> 15);
    out = (out * g) >> 15;
    if (out > 32767) out = 32767;
    if (out < -32767) out = -32767;
    a[i] = (out * (lq >> 8)) >> 8;                /* Q15 x level (Q1 0..254) */
    la += dla; lb += dlb; lq += dlq;
  }
  int32_t tr = x->tr, fade = x->fade;
  if (tr | fade) {
    int32_t tail = x->tail, step = half ? 4 : 2, fstep = half ? 2 : 1;
    for (i = 0; i < n; ++i) {
      int32_t y = a[i];
      if (tr) {
        y = (y * (64 - tr) + tail * tr) >> 6;
        tr = tr > step ? tr - step : 0;
      }
      if (fade) {
        y = (y * fade) >> 7;
        fade -= fstep;
        if (fade <= 0) { fade = 0; st[0] = -1; }
      } else if (st[0] == -1) {
        y = 0;
      }
      a[i] = y;
    }
  }
  int32_t last = x->last;
  if (half) {
    /* Expand in place from the end: a[2i+1] = y_i, a[2i] = (y_(i-1) + y_i) / 2. */
    for (i = n - 1; i >= 0; --i) {
      int32_t y = a[i], prev = i ? a[i - 1] : last;
      a[2 * i + 1] = y << 16;
      a[2 * i] = (prev + y) << 15;
    }
    last = a[2 * n - 1] >> 16;
  } else {
    last = a[n - 1];
    for (i = 0; i < n; ++i) a[i] <<= 16;
  }
  x->last = st[0] == -1 ? 0 : last;
  x->tr = tr; x->fade = fade;
  st[1] = p1; st[2] = p2; st[3] = p3; st[4] = p4;
  st[6] = (y1 & 0xffff) | (y2 << 16);
}
