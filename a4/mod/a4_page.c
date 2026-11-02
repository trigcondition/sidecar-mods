/* SPDX-License-Identifier: GPL-2.0-or-later */
/* a4_page.c - a machine on a sound. The NOISE page holds the selector: knob D MCH picks the selected track's machine, knob F OS2 says who has OSC2's page, ANALOG or MACHINE. Both
 * are fields of the sound (mod storage: 0 OFF, 0 ANALOG), so every sound of every project starts off and a track stays the analog voice it always was. Their ids 51 and 52 are
 * stock parameters no page shows [read]; core_params answers for them, on a page view only, so stock's own PM2 and FM2 are as they were. And a machine's page: OSC1's knobs are its
 * parameters, plain 0..127 dials with its names; NOISE G..J four more; OSC2's page too with OS2: MACHINE. LEV stays analog everywhere, and OSC2, NOISE and OSC 1&2 are stock's
 * otherwise. The ranges and dials follow the selected track by writes to stock's parameter table and knob descriptors (a4_knobs_follow), which only the UI reads. */
#include "analog-four-mk2/pages.h"
#include "analog-four-mk2/store.h"
#include "a4.h"

#define KNOB 51
#define OS2 52
#define STEP_GAP 90u            /* blocks between steps: 60 ms */
#define ID_DET 42               /* the plain dial every machine knob draws */
#define ID_LEV1 44              /* OSC1, OSC2, NOISE LEV */
#define ID_LEV2 57
#define ID_LEV3 77
#define ID_PM1 38
#define ID_FM1 39
#define ID_ACC 99
#define ID_AM1 50
#define ID_MAX 99
#define CENTRE 16384
#define PAGE_OSC1 6
#define PAGE_NOISE 7
#define PAGE_OSC2 8

STORE_FIELD(a4_machine);
STORE_FIELD(a4_osc2);

const struct a4_machine a4_machine_of[A4_MACHINES] = {
    {"PLTS", 0x00, 100, 0},
    {"JUNO", 0x08, 0, 0},
    {"DSY", 0x10, 64, 0},
    {"FM6", 0x48, 0, 0},
    {"MD", 0x40, 0, 0x224D},
    {"B2", 0x40, 0, 0x224D},
    {"U1", 0x50, 0, 0},         /* the user slots (core/machines.h): tag 0, whatever the Sidecar's User machines tab put there */
    {"U2", 0x58, 0, 0},
    {"U3", 0x60, 0, 0},
    {"U4", 0x68, 0, 0},
    {"U5", 0x70, 0, 0},
};

/* Which knob feeds which P. The P's meaning stays the machine's (core/machines.h, the Rytm's SRC page); P1..P5 stay on TUN DET PW SPD PWM. Rows: ANALOG, MACHINE. */
#define N S_NONE
#define OSC1(fin, trk, wav, sub) S_TUN, S_DET, S_PW, S_SPD, S_PWM, fin, trk, wav, sub
#define OSC2_GIVES S_TUN2, S_DET2, S_PW2, S_SPD2, S_PWM2, S_TRK2
const uint8_t a4_src_of[A4_LAYOUTS * 2][A4_ON_PAGE] = {
    {OSC1(S_TRK, S_FIN, S_WAV, S_SUB), S_PM1, S_FM1, S_ACC, S_AM1, N, N},       /* PLTS, DSY, U1..U5: P6 TRK, P7 FIN, P8 WAV, P9 SUB */
    {OSC1(S_TRK, S_FIN, S_WAV, S_SUB), OSC2_GIVES},
    {S_TUN, S_DET, S_PW, S_SPD, S_PWM, S_TRK, S_WAV, S_SUB, N, N, N, N, N, N, N},   /* JUNO: nothing for OSC2's page */
    {S_TUN, S_DET, S_PW, S_SPD, S_PWM, S_TRK, S_WAV, S_SUB, N, N, N, N, N, N, N},
    {S_TUN, S_DET, S_PW, S_SPD, S_PWM, S_FIN, S_TRK, S_WAV, N, N, N, N, N, N, N},   /* FM6: P6 FIN, P7 TRK, P8 WAV */
    {S_TUN, S_DET, S_PW, S_SPD, S_PWM, S_FIN, S_TRK, S_WAV, N, N, N, N, N, N, N},
    {S_TUN, S_DET, S_PW, S_SPD, S_PWM, S_TRK, S_WAV, S_SUB, S_FIN, S_PM1, S_FM1, N, N, N, N},   /* MD, B2: P6 TRK, P7 WAV, P8 SUB, P9 FIN */
    {S_TUN, S_DET, S_PW, S_SPD, S_PWM, S_TRK, S_WAV, S_SUB, S_FIN, S_TUN2, S_DET2, N, N, N, N},
};
#undef N
const uint8_t a4_layout_of[A4_MACHINES] = {0, 1, 0, 2, 3, 3, 0, 0, 0, 0, 0};
#define GIVES_OSC2(m) (a4_layout_of[(m) - 1] == 0 || a4_layout_of[(m) - 1] == 3)

/* What a pick from OFF writes, the Rytm's page words where they are known (its PLAITS page 2: 64 64 0 0 0 120 0, rytm-mods 0021): a machine that sounds, with its lists on their first entry. */
#define U5X {64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64}
const uint8_t a4_defaults[A4_MACHINES][A4_ON_PAGE] = {
    {0, 64, 64, 64, 127, 64, 64, 100, 64, 64, 0, 0, 0, 120, 0},                 /* PLTS: ENG HRM TIM MOR DEC LPG TUN LEV FM FIN AUX TMD MMD VEL GLD */
    {0, 64, 0, 0, 0, 64, 64, 127},                                              /* JUNO: PAT CUT RES ENV ATK DEC REL LEN */
    {0, 64, 64, 64, 0, 64, 64, 100, 64, 64, 0, 0, 0, 120, 0},                   /* DSY: ENG STR BRI DMP INP EXC TUN LEV XTN XDC FB OUT XP4 XLV XP5 */
    {0, 64, 64, 127, 64, 64, 100, 127},                                         /* FM6: PAT TIM MOR DEC LPG TUN LEV LEN */
    {64, 64, 64, 64, 64, 64, 64, 64, 0, 0, 100},                                /* MD: CT1..CT8 ENG TYP LEV */
    {64, 64, 64, 64, 64, 64, 64, 64, 0, 0, 100},
    U5X, U5X, U5X, U5X, U5X,
};

static const char labels[5][A4_ON_PAGE][4] = {
    {"ENG", "HRM", "TIM", "MOR", "DEC", "LPG", "TUN", "LEV", "FM", "FIN", "AUX", "TMD", "MMD", "VEL", "GLD"},   /* PLTS */
    {"PAT", "CUT", "RES", "ENV", "ATK", "DEC", "REL", "LEN"},                                                   /* JUNO */
    {"ENG", "STR", "BRI", "DMP", "INP", "EXC", "TUN", "LEV", "XTN", "XDC", "FB", "OUT", "XP4", "XLV", "XP5"},   /* DSY */
    {"PAT", "TIM", "MOR", "DEC", "LPG", "TUN", "LEV", "LEN"},                                                   /* FM6 */
    {"CT1", "CT2", "CT3", "CT4", "CT5", "CT6", "CT7", "CT8", "ENG", "TYP", "LEV"},                              /* MD, B2 */
};
#define LISTED 6                /* the sound's field up to B2 has names; U1..U5 keep P numbers */

static uint32_t stepped_at;
static uint8_t ticked;          /* the first tick has run: the knob descriptors exist */
static uint8_t p_by_id[ID_MAX + 1], map_key = 0xFF;

/* The selected track. UI task only: the call is virtual. */
static uint32_t ui_track(void)
{
    return (uint32_t)SELECTION_TRACK(UI_SELECTION);
}

static void *ui_sound(void)
{
    return KIT_SOUND(KIT_INDEX, ui_track());
}

static uint32_t machine_of(void *sound)
{
    uint32_t m = core_store_get(STORE(a4_machine), sound, 0) & A4_MACHINE_BITS;
    return m <= A4_MACHINES ? m : 0;
}

/* OS2 as it acts: JUNO and FM6 have nothing to give OSC2's page. */
static uint32_t os2_of(void *sound, uint32_t m)
{
    return m && GIVES_OSC2(m) && (core_store_get(STORE(a4_osc2), sound, 0) & 1);
}

/* id to P, 0 none, for a machine and its OS2. */
static const uint8_t *p_map(uint32_t m, uint32_t os2)
{
    uint32_t k, key = m << 1 | os2;
    if (key != map_key) {
        const uint8_t *src = a4_src_of[a4_layout_of[m - 1] * 2u + os2];
        map_key = (uint8_t)key;
        for (k = 0; k <= ID_MAX; ++k)
            p_by_id[k] = 0;
        for (k = 0; k < A4_ON_PAGE; ++k)
            if (src[k] != S_NONE)
                p_by_id[a4_source[src[k]].id] = (uint8_t)(k + 1);
    }
    return p_by_id;
}

/* The selected sound's machine, if id is a knob it reads: *m 1.. and the P; 0 stock's. UI task. */
static uint32_t p_here(int32_t id, uint32_t *m)
{
    void *s;
    if (id < 0 || id > ID_MAX || ui_track() >= A4_VOICES || !(*m = machine_of(s = ui_sound())))
        return 0;
    return p_map(*m, os2_of(s, *m))[id];
}

/* ---- the ranges and dials: stock's table and descriptors follow the selected track ---- */

static const struct { uint8_t id; int16_t max; } narrow[5] = {{43, 256}, {45, 1792}, {46, 1024}, {50, 256}, {56, 256}};  /* TRK WAV SUB AM1, OSC2 TRK: stock's switches and lists */
static uint32_t stock_knob[5][KNOB_WORDS];
static uint8_t wide_now, first_done;

static void hidden_opens(int32_t id)            /* a hidden id: no OFF track can reach it, so once. PM and FM's table says min = max [read]; word 0 and the widget as the dial's [measured] */
{
    uint32_t k;
    PARAM_MIN(id) = 0, PARAM_MAX(id) = 32512;
    KNOB_DESC(id)[0] = KNOB_DESC(ID_DET)[0];
    for (k = 9; k < 13; ++k)
        KNOB_DESC(id)[k] = KNOB_DESC(ID_DET)[k];
}

/* A tick and every page_info ask, and a turn asks page_info first: so a knob's first turn on a track, a held trig's too, already has that track's range. UI task. */
static void knobs_follow(void)
{
    uint32_t i, k, m, w, wide = 0;
    const uint8_t *map;
    void *s = 0;
    if (!ticked)
        return;
    if (!first_done) {
        first_done = 1;
        for (i = 0; i < 5; ++i)
            for (k = 0; k < KNOB_WORDS; ++k)
                stock_knob[i][k] = KNOB_DESC(narrow[i].id)[k];
        hidden_opens(ID_PM1), hidden_opens(ID_FM1), hidden_opens(ID_ACC);
    }
    m = ui_track() < A4_VOICES ? machine_of(s = ui_sound()) : 0;
    map = m ? p_map(m, os2_of(s, m)) : 0;
    for (i = 0; i < 5; ++i)
        if (map && map[narrow[i].id])
            wide |= 1u << i;
    w = m ? (uint32_t)SOUND_WORD(s, 0) & 0x7FFF : 0;    /* TUN and FIN are one word: each keeps to its byte, so that FIN never moves TUN's P, nor TUN FIN's [measured]; stock's FIN carries into it */
    PARAM_MIN(A4_ID_TUN) = m ? (int32_t)(w & 0xFF) : 128;
    PARAM_MAX(A4_ID_TUN) = m ? (int32_t)(0x7F00 | (w & 0xFF)) : 32638;
    PARAM_MIN(A4_ID_FIN) = m ? (int32_t)(w & 0x7F00) : 128;
    PARAM_MAX(A4_ID_FIN) = m ? (int32_t)((w & 0x7F00) | 0xFF) : 32638;
    w = map && map[A4_ID_TUN2] ? (uint32_t)SOUND_WORD(s, 1) & 0xFF : 0;
    PARAM_MIN(A4_ID_TUN2) = map && map[A4_ID_TUN2] ? (int32_t)w : 128;
    PARAM_MAX(A4_ID_TUN2) = map && map[A4_ID_TUN2] ? (int32_t)(0x7F00 | w) : 32638;
    if (wide == wide_now)
        return;
    for (i = 0; i < 5; ++i) {
        if (!((wide ^ wide_now) >> i & 1))
            continue;
        PARAM_MAX(narrow[i].id) = wide >> i & 1 ? 32512 : narrow[i].max;
        for (k = 0; k < KNOB_WORDS; ++k)
            KNOB_DESC(narrow[i].id)[k] = wide >> i & 1 ? KNOB_DESC(ID_DET)[k] : stock_knob[i][k];
    }
    wide_now = (uint8_t)wide;
}

/* Back on stock's range, what stock's knob cannot show: a value above it stays out of stock's lists. The set clamps. */
static void stock_again(void *model)
{
    uint32_t i;
    for (i = 0; i < 5; ++i) {
        int32_t id = narrow[i].id;
        if (!(wide_now >> i & 1) && SOUND_WORD(ui_sound(), PARAM_SLOT(id)) > narrow[i].max)
            MODEL_SET(model, id, narrow[i].max);
    }
}

/* A machine's defaults on its knobs and OSC1 LEV 0: written, or compared with the sound: 1 it holds them all. */
static int defaults(void *model, uint32_t m, int write)
{
    const uint8_t *src = a4_src_of[a4_layout_of[m - 1] * 2u + os2_of(ui_sound(), m)], *d = a4_defaults[m - 1];
    int32_t word = 0;
    uint32_t k;
    for (k = 0; k <= A4_ON_PAGE; ++k) {
        int32_t id = ID_LEV1, v = 0;
        if (k < A4_ON_PAGE) {
            if (src[k] == S_NONE)
                continue;
            if (src[k] == S_TUN || src[k] == S_FIN) {
                word |= src[k] == S_TUN ? d[k] << 8 : d[k] * 2;
                continue;
            }
            id = a4_source[src[k]].id, v = d[k] << 8;
        }
        if (write)
            MODEL_SET(model, id, v);
        else if (SOUND_WORD(ui_sound(), PARAM_SLOT(id)) != v)
            return 0;
    }
    if (write) {
        PARAM_MIN(A4_ID_TUN) = 0, PARAM_MAX(A4_ID_TUN) = 32767;     /* knobs_follow's clamp is the old word's */
        MODEL_SET(model, A4_ID_TUN, word);
    }
    return SOUND_WORD(ui_sound(), 0) == word;
}

/* ---- the two knobs of the NOISE page ---- */

static int get(int32_t id, int32_t *value)
{
    (void)id;
    if (ui_track() >= A4_VOICES)
        return 0;
    *value = (int32_t)(core_store_get(STORE(a4_machine), ui_sound(), 0) & A4_MACHINE_BITS) << 8;
    return 1;
}

static int delta(void *view, int32_t id, int32_t d, int32_t func)
{
    int32_t was, m, fresh;
    void *model;
    (void)id; (void)func;
    if (ui_track() >= A4_VOICES)
        return 0;
    if (!d)
        return 1;
    if (a4_now - stepped_at < STEP_GAP)         /* a list, not a value: a turn's size says nothing, an accelerated turn would skip machines */
        return 1;
    stepped_at = a4_now;
    was = (int32_t)(core_store_get(STORE(a4_machine), ui_sound(), 0) & A4_MACHINE_BITS);
    m = was + (d > 0 ? 1 : -1);
    m = m < 0 ? 0 : m > A4_MACHINES ? A4_MACHINES : m;
    if (m == was)
        return 1;
    fresh = !was || defaults(0, (uint32_t)was, 0);      /* a pick from OFF: the sound's stock values are bad ones for a machine, FIN 0, TRK 1, WAV 3, SUB 0. It holds until a knob moves, or a turn through the list leaves only the first its defaults */
    core_store_set(STORE(a4_machine), ui_sound(), 0, (unsigned)m);
    knobs_follow();
    model = VIEW_MODEL(view);
    if (m && fresh)
        defaults(model, (uint32_t)m, 1);
    if (!m)                                     /* an analog voice must not stay detuned on a word no knob of stock's reaches */
        MODEL_SET(model, ID_PM1, CENTRE), MODEL_SET(model, ID_FM1, CENTRE);
    stock_again(model);
    return 1;
}

static int text(struct core_text *t)
{
    int32_t m = (t->value >> 8) & (int32_t)A4_MACHINE_BITS, i = 0;
    const char *s = m >= 1 && m <= A4_MACHINES ? a4_machine_of[m - 1].name : "OFF";
    while (s[i])
        t->buf[i] = s[i], ++i;
    t->buf[i] = 0;
    return CORE_TEXT_DONE;
}

static int get2(int32_t id, int32_t *value)
{
    (void)id;
    if (ui_track() >= A4_VOICES)
        return 0;
    *value = (int32_t)(core_store_get(STORE(a4_osc2), ui_sound(), 0) & 1) << 8;
    return 1;
}

static int delta2(void *view, int32_t id, int32_t d, int32_t func)
{
    (void)id; (void)func;
    if (ui_track() >= A4_VOICES)
        return 0;
    if (d) {
        core_store_set(STORE(a4_osc2), ui_sound(), 0, d > 0 ? 1u : 0u);
        knobs_follow();
        stock_again(VIEW_MODEL(view));
    }
    return 1;
}

static int text2(struct core_text *t)
{
    t->buf[0] = t->value >> 8 ? 'M' : 'A';
    t->buf[1] = t->value >> 8 ? 'C' : 'N';
    t->buf[2] = t->value >> 8 ? 'H' : 'A';
    t->buf[3] = 0;
    return CORE_TEXT_DONE;
}

const struct core_param a4_params = {KNOB, KNOB, get, delta, text};
const struct core_param a4_params2 = {OS2, OS2, get2, delta2, text2};

/* The draw of a page's knob asks here for its label: 0 is stock's (a4_label.s). */
const char *a4_label(void *view, int32_t id)
{
    static char user[4];
    uint32_t m, p;
    (void)view;
    if (id == KNOB)
        return "MCH";
    if (id == OS2)
        return "OS2";
    if (!(p = p_here(id, &m)))
        return 0;
    if (m > LISTED) {
        user[0] = 'P';
        user[1] = p >= 10 ? '1' : (char)('0' + p);
        user[2] = p >= 10 ? (char)('0' + p - 10) : 0;
        user[3] = 0;
        return user;
    }
    m = m == LISTED ? LISTED - 1 : m;
    return labels[m - 1][p - 1][0] ? labels[m - 1][p - 1] : 0;
}

/* The title a turn puts on the screen, stock's long name: the machine and the knob's name. */
const char *a4_title(void *view, int32_t id)
{
    static char title[12];
    const char *a, *b;
    uint32_t m, i = 0;
    if (id == KNOB)
        return "MACHINE";
    if (id == OS2)
        return "OSC2";
    if (!(b = a4_label(view, id)))
        return 0;
    p_here(id, &m);
    for (a = a4_machine_of[m - 1].name; *a; ++a)
        title[i++] = *a;
    title[i++] = ' ';
    while (*b)
        title[i++] = *b++;
    title[i] = 0;
    return title;
}

/* A knob of a machine shows the plain number the machine reads, not stock's tuning or percentage. */
static int p_text(struct core_text *t)
{
    uint32_t m, i = 0;
    int32_t v = t->value >> 8;
    if (!p_here(t->id, &m))
        return CORE_TEXT_PASS;
    if (t->id == A4_ID_FIN)
        v = (t->value & 0xFF) >> 1;
    v = v < 0 ? 0 : v > 127 ? 127 : v;
    if (v >= 100)
        t->buf[i++] = '1';
    if (v >= 10)
        t->buf[i++] = (char)('0' + v / 10 % 10);
    t->buf[i++] = (char)('0' + v % 10);
    t->buf[i] = 0;
    return CORE_TEXT_DONE;
}

const struct core_param a4_knob_text = {ID_PM1, ID_MAX, 0, 0, p_text};

/* The knob's draw (a4_label.s), args {set, id, value, ...}: a machine's knob is a plain dial, whatever stock's icon for that id: the icon is per id [read: 0x4009eaaa]. FIN shows its own byte. */
void a4_widget(int32_t *a)
{
    uint32_t m;
    if (!p_here(a[1], &m))
        return;
    if (a[1] == A4_ID_FIN)
        a[2] = (a[2] & 0xFF) << 7;
    a[1] = ID_DET;
}

/* page_info on the three pages. Id 0 is stock's own empty knob: hatched by the draw (0x40025030), no title or value, a turn stops at it (0x400259de) [read; measured]. Each reader
 * of a knob asks afresh, and with no view at hand, so the selection is the UI model's. 0 is stock's own entry. UI task. */
static const struct core_page *a4_knobs(int32_t page)
{
    static struct core_page shown;
    const int32_t *e = PAGE_ENTRY(page);
    uint32_t t, m, k, os2;
    const uint8_t *map;
    void *s;
    knobs_follow();
    if ((t = ui_track()) >= A4_VOICES)
        return 0;
    m = machine_of(s = KIT_SOUND(KIT_INDEX, t));
    os2 = os2_of(s, m);
    map = m ? p_map(m, os2) : 0;
    shown.name = (const char *)e[0];
    if (page == PAGE_NOISE) {
        for (k = 0; k < 10; ++k)
            shown.ids[k] = e[k + 1];
        shown.ids[3] = KNOB;
        shown.ids[5] = !m || GIVES_OSC2(m) ? OS2 : 0;
        if (map && !os2) {
            shown.ids[6] = map[ID_PM1] ? ID_PM1 : 0;
            shown.ids[7] = map[ID_FM1] ? ID_FM1 : 0;
            shown.ids[8] = map[ID_ACC] ? ID_ACC : 0;
            shown.ids[9] = map[ID_AM1] ? ID_AM1 : 0;
        }
        return &shown;
    }
    if (!m || (page == PAGE_OSC2 && !os2))
        return 0;
    for (k = 0; k < 10; ++k) {
        int32_t id = e[k + 1];
        shown.ids[k] = id == ID_LEV1 || id == ID_LEV2 || id == ID_LEV3 || map[id] ? id : 0;
    }
    return &shown;
}

const struct core_page_fn a4_page_osc1 = {PAGE_OSC1, a4_knobs}, a4_page_noise = {PAGE_NOISE, a4_knobs}, a4_page_osc2 = {PAGE_OSC2, a4_knobs};

/* A chord's note preview (hold a trig, YES): stock's step asks here with the trig's notes, ahead of playing them, and plays as many as the track has voices, one a block; ARP on, all of them
 * [read: 0x40026e7e, 0x4009ca1c]. The rest goes to the report by this side door: a mono track's one note is all the audio side would see of the chord. UI task. */
void a4_preview(const struct a4_notes *d, uint32_t arp)
{
    uint8_t note[A4_CHORD];
    const int8_t *p = d->cur, *last = d->last;
    int8_t *const *node = d->node;
    uint32_t n = 0, t;
    if (arp || (t = ui_track()) >= A4_VOICES || !a4_machine_now[t])
        return;
    while (p != d->end && n < A4_CHORD) {
        if (*p >= 0)
            note[n++] = (uint8_t)*p;
        if (++p == last)
            p = *++node, last = p + 512;
    }
    a4_preview_notes(t, note, n);
}

/* The UI loop: each track's machine and OS2, for the render. A kit's change is seen within a tick. */
void a4_machines_read(void)
{
    uint32_t t, k = KIT_INDEX;
    for (t = 0; t < A4_VOICES; ++t) {
        void *s = KIT_SOUND(k, t);
        uint32_t m = core_store_get(STORE(a4_machine), s, 0) & A4_MACHINE_BITS;
        m = m <= A4_MACHINES ? m : 0;
        a4_os2_now[t] = (uint8_t)os2_of(s, m);
        a4_machine_now[t] = (uint8_t)m;
    }
    ticked = 1;
    knobs_follow();
}
