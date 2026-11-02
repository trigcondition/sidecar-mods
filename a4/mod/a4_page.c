/* SPDX-License-Identifier: GPL-2.0-or-later */
/* a4_page.c - the SIDECAR page, behind the OSC1 key after stock's pages: knob A picks the machine of the selected track's sound.
 * The choice is a field of the sound (mod storage: 0 OFF, so every sound of every project starts off and a track stays the
 * analog voice it always was). id 51 is a stock parameter no page shows [read]; core_params answers for it. And the names: a track with a machine
 * shows them on the stock pages' knobs. */
#include "analog-four-mk2/pages.h"
#include "analog-four-mk2/store.h"
#include "a4.h"

#define PAGE 48
#define KNOB 51
#define SCREEN 49
#define STEP_GAP 90u            /* blocks between steps: 60 ms */

STORE_FIELD(a4_machine);

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

static uint32_t stepped_at;

static void *selection;

/* The selected track; before the page key first reached this page, track 1. UI task only: the call is virtual. */
static uint32_t ui_track(void)
{
    return selection ? (uint32_t)SELECTION_TRACK(selection) : 0;
}

static void *ui_sound(void)
{
    return KIT_SOUND(KIT_INDEX, ui_track());
}

/* The page key on its way here: the view tells which selection object the pages share. */
static int32_t a4_shown(void *view)
{
    if (view)
        selection = VIEW_SELECTION(view);
    return 1;
}

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
    int32_t m;
    (void)id; (void)func;
    selection = VIEW_SELECTION(view);
    if (ui_track() >= A4_VOICES)
        return 0;
    if (!d)
        return 1;
    if (a4_now - stepped_at < STEP_GAP)         /* a list, not a value: a turn's size says nothing, an accelerated turn would skip machines */
        return 1;
    stepped_at = a4_now;
    m = (int32_t)(core_store_get(STORE(a4_machine), ui_sound(), 0) & A4_MACHINE_BITS) + (d > 0 ? 1 : -1);
    m = m < 0 ? 0 : m > A4_MACHINES ? A4_MACHINES : m;
    core_store_set(STORE(a4_machine), ui_sound(), 0, (unsigned)m);
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

const struct core_param a4_params = {KNOB, KNOB, get, delta, text};
const struct core_page a4_page = {PAGE, "SIDECAR", {KNOB}};
const struct core_view_page a4_view = {CORE_TRACK_SYNTH, CORE_KEY_OSC1, PAGE, a4_shown};

/* The way to the Sidecar's screen: a view after the SIDECAR page that never shows. The OSC1 key's step asks it there, and only there: with a Sidecar that answers that press
 * opens the screen, and the step goes on to stock's OSC1 page, under it. Without one the key does what it did. */
static int32_t a4_screen_shown(void *view)
{
    (void)view;
    if (a4_screen_can_open())
        a4_screen_open();
    return 0;
}

const struct core_page a4_screen_page = {SCREEN, "SCREEN", {0}};
const struct core_view_page a4_screen_view = {CORE_TRACK_SYNTH, CORE_KEY_OSC1, SCREEN, a4_screen_shown};

/* The machine's name of each knob, on the stock OSC1, OSC2, NOISE and OSC 1&2 pages: the P a stock parameter id reports, 0 none [measured: each knob turned in the emulator]. */
static const uint8_t p_of_id[A4_ID_LAST - A4_ID_FIRST + 1] = {
    1, 0, 2, 0, 0, 0, 0, 3, 4, 5,               /* 40.. OSC1  TUN FIN DET TRK LEV WAV SUB PW SPD PWM */
    0, 0, 0,                                    /* 50.. AM1 PM2 FM2 */
    6, 0, 7, 0, 0, 0, 0, 8, 9, 10,              /* 53.. OSC2 */
    0, 0, 0, 0, 0,                              /* 63.. AM2 PMX FMX SMD SNC */
    13, 14, 0, 15, 0, 0, 0,                     /* 68.. BND SLI TRG FAD SPD VIB SNH */
    11, 12,                                     /* 75.. NOISE COL FAD */
};

static const char labels[5][A4_ON_PAGE][4] = {
    {"ENG", "HRM", "TIM", "MOR", "DEC", "LPG", "TUN", "LEV", "FM", "FIN", "AUX", "TMD", "MMD", "VEL", "GLD"},   /* PLTS */
    {"PAT", "CUT", "RES", "ENV", "ATK", "DEC", "REL", "LEN"},                                                   /* JUNO */
    {"ENG", "STR", "BRI", "DMP", "INP", "EXC", "TUN", "LEV", "XTN", "XDC", "FB", "OUT", "XP4", "XLV", "XP5"},   /* DSY */
    {"PAT", "TIM", "MOR", "DEC", "LPG", "TUN", "LEV", "LEN"},                                                   /* FM6 */
    {"CT1", "CT2", "CT3", "CT4", "CT5", "CT6", "CT7", "CT8", "ENG", "TYP", "LEV"},                              /* MD, B2 */
};
#define LISTED 6                /* the sound's field up to B2 has names; U1..U5 keep P numbers */

/* The selected sound's machine, if id is a knob it reads: *m 1.. and the P; 0 stock's. UI task. */
static uint32_t p_here(int32_t id, uint32_t *m)
{
    uint32_t t, p;
    if (id < A4_ID_FIRST || id > A4_ID_LAST || !(p = p_of_id[id - A4_ID_FIRST]))
        return 0;
    if ((t = ui_track()) >= A4_VOICES)
        return 0;
    *m = core_store_get(STORE(a4_machine), KIT_SOUND(KIT_INDEX, t), 0) & A4_MACHINE_BITS;
    return *m && *m <= A4_MACHINES ? p : 0;
}

/* The draw of a page's knob asks here for its label: 0 is stock's (a4_label.s). A knob the machine does not read keeps stock's: it is the analog voice's. */
const char *a4_label(void *view, int32_t id)
{
    static char user[4];
    uint32_t m, p;
    if (id == KNOB)
        return "MCH";
    selection = VIEW_SELECTION(view);
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
    v = v < 0 ? 0 : v > 127 ? 127 : v;
    if (v >= 100)
        t->buf[i++] = '1';
    if (v >= 10)
        t->buf[i++] = (char)('0' + v / 10 % 10);
    t->buf[i++] = (char)('0' + v % 10);
    t->buf[i] = 0;
    return CORE_TEXT_DONE;
}

const struct core_param a4_knob_text = {A4_ID_FIRST, A4_ID_LAST, 0, 0, p_text};

/* The UI loop: each track's machine, for the render. A kit's change is seen within a tick. */
void a4_machines_read(void)
{
    uint32_t t, k = KIT_INDEX;
    for (t = 0; t < A4_VOICES; ++t) {
        uint32_t m = core_store_get(STORE(a4_machine), KIT_SOUND(k, t), 0) & A4_MACHINE_BITS;
        a4_machine_now[t] = (uint8_t)(m <= A4_MACHINES ? m : 0);
    }
}
