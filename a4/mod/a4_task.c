/* SPDX-License-Identifier: GPL-2.0-or-later */
/* a4_task.c - the sender's task. The render only posts: a stock task may be inside the OS's sender when the render interrupts
 * it, and the OS's sender is never called from the audio interrupt. The tick (about 20 Hz) starts the task, once, and posts as
 * well, for the hello, the repeats and a message the sender had no room for. Stock's tasks run at 1..10 [read]: this one outranks
 * them, as on the Digitakt, so a trig leaves within the render's own exit. */
#include "a4.h"

#define PRIORITY 14
#define STACK    (8192 / 4)     /* interrupts run on it too: the audio interrupt's frame alone is 0xec B */

static uint32_t tcb[21] __attribute__((aligned(16)));   /* the OS writes up to +0x50 */
static uint32_t sem[2] __attribute__((aligned(16)));    /* count, waiter */
static uint32_t stack[STACK] __attribute__((aligned(16)));
static volatile uint8_t running;

static void loop(void)
{
    for (;;) {
        SEM_WAIT(sem);
        a4_service();
        a4_remote_service();
    }
}

void a4_wake(void)
{
    if (running && (int32_t)sem[0] < 1)         /* one post is enough: a pass does all that is due */
        SEM_POST(sem);
}

void a4_start(void)
{
    if (running)
        return;
    SEM_INIT(sem, 0);
    if (!TASK_CREATE(tcb, loop, PRIORITY, stack, sizeof stack))
        return;
    running = 1;
    TASK_START(tcb);
}
