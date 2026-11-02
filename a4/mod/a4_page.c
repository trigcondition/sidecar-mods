/* SPDX-License-Identifier: GPL-2.0-or-later */
/* a4_page.c - the SIDECAR page, behind the OSC1 key after stock's pages: knob A picks the machine of the selected track's sound.
 * The choice is a field of the sound (mod storage: 0 OFF, so every sound of every project starts off and a track stays the
 * analog voice it always was). id 51 is a stock parameter no page shows [read]; core_params answers for it. */
#include "analog-four-mk2/pages.h"
#include "analog-four-mk2/store.h"
#include "a4.h"

#define PAGE 48
#define KNOB 51
#define STEP_GAP 90u            /* blocks between steps: 60 ms */

STORE_FIELD(a4_machine);

const struct a4_machine a4_machine_of[A4_MACHINES] = {
    {"PLTS", 0x00, 100, 0},
    {"JUNO", 0x08, 0, 0},
    {"DSY", 0x10, 64, 0},
    {"FM6", 0x48, 0, 0},
    {"MD", 0x40, 0, 0x224D},
    {"B2", 0x40, 0, 0x224D},
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
    *value = (int32_t)(core_store_get(STORE(a4_machine), ui_sound(), 0) & 7u) << 8;
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
    m = (int32_t)(core_store_get(STORE(a4_machine), ui_sound(), 0) & 7u) + (d > 0 ? 1 : -1);
    m = m < 0 ? 0 : m > A4_MACHINES ? A4_MACHINES : m;
    core_store_set(STORE(a4_machine), ui_sound(), 0, (unsigned)m);
    return 1;
}

static int text(struct core_text *t)
{
    int32_t m = (t->value >> 8) & 7, i = 0;
    const char *s = m >= 1 && m <= A4_MACHINES ? a4_machine_of[m - 1].name : "OFF";
    while (s[i])
        t->buf[i] = s[i], ++i;
    t->buf[i] = 0;
    return CORE_TEXT_DONE;
}

const struct core_param a4_params = {KNOB, KNOB, get, delta, text};
const struct core_page a4_page = {PAGE, "SIDECAR", {KNOB}};
const struct core_view_page a4_view = {CORE_TRACK_SYNTH, CORE_KEY_OSC1, PAGE, a4_shown};

/* The UI loop: each track's machine, for the render. A kit's change is seen within a tick. */
void a4_machines_read(void)
{
    uint32_t t, k = KIT_INDEX;
    for (t = 0; t < A4_VOICES; ++t) {
        uint32_t m = core_store_get(STORE(a4_machine), KIT_SOUND(k, t), 0) & 7u;
        a4_machine_now[t] = (uint8_t)(m <= A4_MACHINES ? m : 0);
    }
}
