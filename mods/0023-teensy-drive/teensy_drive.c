/* Mod 0023 - the Teensy's SD card as a folder TEENSY in the Rytm's own file
 * browser (design.md). Milestone 1: the hooks, with a fixed test listing.
 *
 * The browser fills a folder through readdir(dir handle, record) and asks node
 * functions about each entry's id [measured, OS 1.73; design.md]. Teensy ids
 * are 0x7E000000 | kind << 23 | folder << 12 | entry (kind 1: a file); folder
 * 0 is TEENSY itself. Four functions are wrapped:
 *   readdir  0x4007c048  Teensy folders served here; after the +Drive root's
 *                        last entry, one more: TEENSY
 *   resolve  0x40080498  Teensy ids -> a fake node (bit 0 of byte 0: folder),
 *                        outside the node cache, which release ignores
 *   exists   0x40080766  Teensy ids exist
 *   size     0x400808a4, 0x4008084a  Teensy files: their size
 * Nothing here writes to the card.
 */
#include <stdint.h>

#define TD __attribute__((section(".td")))
#define TDD __attribute__((section(".tdd")))   /* constant data */
#define TDS __attribute__((section(".tds")))   /* the fake nodes, the cache (written) */
#define TD2 __attribute__((section(".td2"), noinline))   /* the Teensy side: ask, wait, 0E */
#define TDN __attribute__((section(".tdn")))   /* the two fake nodes (written) */

#define TID 0x7E000000u
#define IS_TID(id) (((uint32_t)(id) & 0xFF000000u) == TID)
#define FILE_BIT 0x00800000u
#define ROOT_ID 2u                    /* the +Drive root's id [measured] */
#define DONE_MARK 0x7E7E7E7Eu         /* dir handle +12: TEENSY already given */

struct dirh { uint32_t id, block, offset, index; };
struct rec {                          /* the browser's entry record [measured] */
  uint32_t id;
  uint16_t type;                      /* 1 folder, 0 file */
  uint16_t pad;
  uint32_t parent, pos0, pos1;
  char name[256];
};
/* A node, full size [review, 2026-10-08]: the filesystem reads past the first
   16 bytes (+16, the extent count at +30), so the fake ones are 128 zeroed bytes
   rather than whatever follows them. */
struct node { uint8_t b0, b1; uint16_t pad; uint32_t f4, f8, f12; uint8_t rest[112]; };

/* The Teensy's listings (milestone 2). The browser fills a folder in one go
 * (readdir until the end, in the UI task); the first readdir of a Teensy folder
 * asks the Teensy for it and sleeps in 10 ms steps (sleep_us, 0x40098c18: a
 * DMA-timer wait that blocks only the calling task, measured in rytm-emu) until
 * the answer is complete, at most ~400 ms. One folder is cached at a time, up
 * to kCap entries, in a buffer from the firmware's allocator (0x400829d4).
 *   Rytm -> Teensy  F0 7D 52 54 0D <folder hi> <lo> F7
 *   Teensy -> Rytm  F0 7D 52 54 0E <folder hi lo> <parent hi lo> <first hi lo>
 *                   <total hi lo> { <kind> <id hi lo> <size 4 x 7 bits, high
 *                   first> <name length> <name> } F7
 * kind 1: a subfolder (id: its folder number), 0: a file (id: its position).
 * Teensy folder numbers are the Teensy index's (0: /Samples = TEENSY). The
 * Teensy's SysEx reaches 0e_handler through 0022's router, which calls the
 * hook in the mailbox at 0x401b9a74 (magic 'TDRV') when it is there. The mailbox
 * is 12 B since 2026-10-10: magic, td_hook (0E listings, 14 pool tables; MIDI
 * task) and td_pool_tab (0021's pool knobs read the project's pool table through
 * it, UI task; 0021 reads the third word only after the magic, and both are built
 * from one tree). */
#define kCap 512
#define SLEEP_US ((void (*)(uint32_t))0x40098c18u)
#define NEW ((void *(*)(uint32_t))0x400829d4u)
typedef void (*void_fn)(void);
typedef void (*send_fn)(int32_t len, const uint8_t *data);
/* At least n free USB requests (free list 0x413db390, next at +52): else the
   sender waits for the host, freezing this task (review 2026-10-09). */
#define USB_FREE(n) td_usb_free(n)
int td_usb_free(int n);
#define MIDI_LOCK    ((void_fn)0x40002914u)
#define MIDI_UNLOCK  ((void_fn)0x40002924u)
#define USB_MIDI_SEND ((send_fn)0x400029e0u)

struct tentry { uint8_t kind, pad; uint16_t id; uint32_t size; char name[24]; };   /* 32 B */
struct tcache {
  uint16_t folder, parent, total, received;
  uint8_t valid, failed, pad[2];     /* failed: the host did not answer the last wait (none: 0) */
  uint32_t t_ask, t_fail;            /* US_NOW() of the last 0D sent / of the last wait that got no answer */
  struct tentry *e;
};
/* The audio block counter, 1500 a second (48 kHz / 32) [measured, OS 1.73: +1500 per 200M instructions; 0021's
   US_NOW]: the clock of the ask and the give-up below. */
#define US_NOW() (*(volatile const uint32_t *)0x419ca2acu)
#define WAIT_BLOCKS 600u                     /* 400 ms: the longest the UI waits for one listing */
#define GIVE_UP_BLOCKS 90000u                /* 60 s: after a wait with no answer the UI does not wait again */
int td_sysex(const uint8_t *d, int32_t len);
int td_hook(const uint8_t *d, int32_t len);   /* 0E -> td_sysex, 14 -> the pool */
#if TD_SLOTS   /* build param slots: 1 with 0021's user slots (the 12 B mailbox; 8 B and .td2 4 B lower without) */
struct pslot;
struct pslot *td_pool_tab(void);   /* the project's pool table for 0021's pool knobs (below) */
struct tmailbox {
  uint32_t magic;                            /* 'TDRV': live */
  int (*hook)(const uint8_t *, int32_t);     /* 0022's router: 0E, 14 */
  struct pslot *(*pool_tab)(void);           /* 0021 (UI task): the table, asked for when stale */
};
struct tmailbox td_mailbox __attribute__((section(".tdm"))) = {0x54445256u, td_hook, td_pool_tab};
#define TD_POOL_TAB
#else
struct tmailbox { uint32_t magic; int (*hook)(const uint8_t *, int32_t); };
struct tmailbox td_mailbox __attribute__((section(".tdm"))) = {0x54445256u, td_hook};
#define TD_POOL_TAB static
#endif
struct tcache td_cache TDS = {0, 0, 0, 0, 0, 0, {0, 0}, 0, 0, 0};

static const char td_dot[] TDD = ".";
static const char td_dotdot[] TDD = "..";
static const char td_teensy[] TDD = "SIDECAR";   /* the folder's name (1021: was TEENSY) */

/* +1 bit 0: write-protected - DELETE, RENAME, MOVE answer "WRITE PROTECTED". */
struct node td_dir_node TDN = {1, 1, 0, 0, 0, 0, {0}};
/* A file node as the browser wants it [measured]: +12 bit 0 set (else the row
   draws a bar instead of the size), +1 bit 1 = size at +8 held, +1 bit 0 set
   (write-protected; else YES does not tick the file, so LOAD TO PROJ is not
   offered). */
struct node td_file_node TDN = {0, 3, 0, 0, 0, 1, {0}};

typedef int32_t (*readdir_fn)(struct dirh *, struct rec *);
typedef void *(*resolve_fn)(uint32_t);
typedef int32_t (*id_fn)(uint32_t);
int32_t td_readdir_stock(struct dirh *, struct rec *);
void *td_resolve_stock(uint32_t);
int32_t td_exists_stock(uint32_t);
int32_t td_size_stock(uint32_t);
int32_t td_count_stock(uint32_t);

TD static void td_name(char *dst, const char *src) {
  int i;
  for (i = 0; i < 255 && src[i]; ++i) dst[i] = src[i];
  dst[i] = 0;
}

TD static void td_fill(struct rec *r, uint32_t id, uint16_t type, uint32_t parent, const char *name) {
  r->id = id;
  r->type = type;
  r->parent = parent;
  r->pos0 = r->pos1 = 0;
  td_name(r->name, name);
}

TD static uint32_t td_file_size(uint32_t id) {
  struct tcache *c = &td_cache;
  uint32_t f = (id >> 12) & 0x3ff, e = id & 0xfff, k;
  if (!c->valid || !c->e || c->folder != f) return 0;
  for (k = 0; k < c->received && k < kCap; ++k)
    if (c->e[k].kind == 0 && c->e[k].id == e) return c->e[k].size;
  return 0;
}

__attribute__((section(".td5"), noinline)) static void td_ask(uint32_t f) {
  uint8_t m[8] = {0xf0, 0x7d, 0x52, 0x54, 0x0d, (uint8_t)((f >> 7) & 0x7f), (uint8_t)(f & 0x7f), 0xf7};
  if (!USB_FREE(4)) return;
  MIDI_LOCK();
  USB_MIDI_SEND(8, m);
  MIDI_UNLOCK();
}

/* The cache's 16 KB, from the firmware's allocator on first use; 0: none. */
__attribute__((section(".td5"), noinline)) static int td_alloc(void) {
  struct tcache *c = &td_cache;
  int k;
  if (!c->e) {
    uint32_t *w = (uint32_t *)NEW(kCap * sizeof(struct tentry));
    if (!w) return 0;
    for (k = 0; k < kCap * (int)sizeof(struct tentry) / 4; ++k) w[k] = 0;
    c->e = (struct tentry *)w;
  }
  return 1;
}

/* Folder f asked for, once: the cache emptied for it, 0D out (never waits). */
__attribute__((section(".td5"), noinline)) static void td_start(uint32_t f, uint32_t now) {
  struct tcache *c = &td_cache;
  c->valid = 0;
  c->folder = (uint16_t)f;
  c->received = 0;
  c->total = 0xffff;
  c->t_ask = now;
  td_ask(f);
}

/* The browser's root read has TEENSY in it: ask for TEENSY's own listing now, without waiting, so entering
   it finds the answer in the cache (the host's round trip overlaps the user's key press). The UI task never waits
   here, and not at all when a wait got no answer lately. */
TD static void td_prefetch(void) {
  struct tcache *c = &td_cache;
  uint32_t now = US_NOW();
  if ((c->failed && now - c->t_fail < GIVE_UP_BLOCKS) || !td_alloc()) return;
  if (c->folder == 0 && (c->valid || now - c->t_ask < WAIT_BLOCKS)) return;   /* given, or asked just now */
  td_start(0, now);
}

/* The Teensy's listing of folder f in the cache: asked for (unless asked already) and waited on - 10 ms steps, at
   most WAIT_BLOCKS from the ask (an ask older than that, from td_prefetch, is given up at once) - unless complete. A host that has not answered within the wait is not waited
   for again for GIVE_UP_BLOCKS: the folder shows empty at once (the ask goes out again, at most once a second, so
   a late or newly attached host fills the cache for the next visit). */
TD2 static void td_ensure(uint32_t f) {
  struct tcache *c = &td_cache;
  uint32_t now = US_NOW(), k;
  if (!td_alloc()) return;
  if (c->valid && c->folder == f && c->received >= c->total) return;
  if (c->failed && now - c->t_fail < GIVE_UP_BLOCKS) {
    if (now - c->t_ask > 1500u || c->folder != f) td_start(f, now);
    return;
  }
  if (c->folder != f || c->valid || c->total != 0xffff) td_start(f, now);   /* else asked already (td_prefetch): wait for that */
  for (k = (now - c->t_ask) / 15; k < 40; ++k) {
    SLEEP_US(10000);
    if (c->valid && c->folder == f && c->received >= c->total) return;
  }
  c->failed = 1;
  c->t_fail = US_NOW();
  c->total = 0;                       /* nothing asked and waited for any more */
}

/* One entry of Teensy folder f at position i: ".", "..", then the cached
   subfolders and files, as the Teensy listed them. */
TD2 static int32_t td_serve(struct dirh *d, struct rec *r) {
  struct tcache *c = &td_cache;
  uint32_t f = d->id & 0x3ff, i = d->index;
  d->index = i + 1;
  if (i == 0) {
    td_ensure(f);
    td_fill(r, d->id, 1, d->id, td_dot);
    return 1;
  }
  if (i == 1) {
    td_fill(r, (f && c->valid && c->folder == f) ? TID | c->parent : ROOT_ID, 1, d->id, td_dotdot);
    return 1;
  }
  i -= 2;
  if (!c->valid || !c->e || c->folder != f || i >= c->received || i >= kCap) return 0;
  {
    struct tentry *e = &c->e[i];
    char nm[25];
    int k;
    for (k = 0; k < 24 && e->name[k]; ++k) nm[k] = e->name[k];
    nm[k] = 0;
    if (e->kind) td_fill(r, TID | (e->id & 0x3ff), 1, d->id, nm);
    else td_fill(r, TID | FILE_BIT | f << 12 | (e->id & 0xfff), 0, d->id, nm);
  }
  return 1;
}

/* 0E from the Teensy (through 0022's router): entries into the cache. */
TD2 int td_sysex(const uint8_t *d, int32_t len) {
  struct tcache *c = &td_cache;
  uint32_t f, first, total, k;
  int32_t p;
  if (len < 14 || d[4] != 0x0e || !c->e) return 0;
  f = (uint32_t)d[5] << 7 | d[6];
  first = (uint32_t)d[9] << 7 | d[10];
  total = (uint32_t)d[11] << 7 | d[12];
  if (f != c->folder) return 1;              /* not the folder being read */
  c->parent = (uint16_t)(((uint32_t)d[7] << 7 | d[8]) & 0x3ff);
  c->failed = 0;
  c->total = (uint16_t)(total < kCap ? total : kCap);
  for (p = 13, k = first; p + 8 <= len - 1; ++k) {
    struct tentry *e;
    uint32_t n, j;
    if (k >= kCap) break;
    e = &c->e[k];
    e->kind = d[p];
    e->id = (uint16_t)((uint32_t)d[p + 1] << 7 | d[p + 2]);
    e->size = (uint32_t)d[p + 3] << 21 | (uint32_t)d[p + 4] << 14 | (uint32_t)d[p + 5] << 7 | d[p + 6];
    n = d[p + 7];
    p += 8;
    for (j = 0; j < n && j < 23 && p + (int32_t)j < len - 1; ++j) e->name[j] = (char)d[p + j];
    e->name[j] = 0;
    p += n;
    if (k + 1 > c->received) c->received = (uint16_t)(k + 1);
  }
  c->valid = 1;
  return 1;
}

TD int32_t td_readdir(struct dirh *d, struct rec *r) {
  int32_t got;
  if (!d || !r) return -1;
  if (IS_TID(d->id)) return td_serve(d, r);
  if (d->id == ROOT_ID && d->index == DONE_MARK) return 0;
  got = td_readdir_stock(d, r);
  if (got == 0 && d->id == ROOT_ID) {           /* an error (< 0) stays one */
    td_fill(r, TID, 1, ROOT_ID, td_teensy);
    d->index = DONE_MARK;
    td_prefetch();
    return 1;
  }
  return got;
}

TD void *td_resolve(uint32_t id) {
  if (IS_TID(id)) {
    if (id & FILE_BIT) {
      td_file_node.f4 = td_file_node.f8 = td_file_size(id);
      return &td_file_node;
    }
    return &td_dir_node;
  }
  return td_resolve_stock(id);
}

TD int32_t td_exists(uint32_t id) {
  if (IS_TID(id)) return 1;
  return td_exists_stock(id);
}

TD int32_t td_size(uint32_t id) {
  if (IS_TID(id)) return (id & FILE_BIT) ? (int32_t)td_file_size(id) : -1;
  return td_size_stock(id);
}

TD int32_t td_count(uint32_t id) {
  if (IS_TID(id)) return (id & FILE_BIT) ? (int32_t)td_file_size(id) : -1;
  return td_count_stock(id);
}

/* ---------------------------------------------------------------------------
 * Milestone 3: LOAD TO PROJ on TEENSY files adds them to the Teensy's pool (the
 * "static" list, streamed from its card) instead of the Rytm's memory ("flex").
 * The load job (lambda 0x400ea710) runs per ticked entry [measured, OS 1.73]:
 *   slot = 0x400b81c4(...)                  a free sample slot (< 0: memory full)
 *   ref  = 0x4007e62c(model, index)         16-byte file reference (via
 *                                           0x4007fa6e(id, ...)), struct return
 *   ok   = 0x400b712e(manager, &ref, slot)  load; counted for "N SAMPLES LOADED"
 * The job's call of 0x4007e62c (0x400ea7b4) goes to td_ref_entry - not the
 * function itself, which the browser also calls per visible row. For a Teensy
 * file it sends 0F <folder hi lo> <file hi lo> to the Teensy and returns a
 * marked reference. The load function itself is wrapped (td_load_entry): a
 * marked reference counts as loaded, touching neither the card nor the Rytm's
 * sample memory; any other Teensy reference fails before the stock code copies
 * it into the slot (it does that first, so a project could save it).
 *
 * Milestone 4 guards [review, 2026-10-08; design.md]:
 *   0x4007c5d4  id -> path: Teensy ids have none (0), at once - not after a
 *               walk of the fake node
 *   0x4007fff4  a reference's check: Teensy ids are not found (-1), so the
 *               stock loaders (the slot browser 0x400e37fe, ..) pass them over
 *   0x400ea646  CREATE DIR's mkdir: refused (-1, "ERROR") when the folder's
 *               path is "" - inside TEENSY, which has none; else it made the
 *               folder in the +Drive's root
 * ------------------------------------------------------------------------- */
#define POOL_MARK 0x7E504F4Fu      /* "~POO" */

/* 10 <name>: the active project (16 bytes at 0x407c89d3, up to 15 characters
   [measured]), so the Teensy adds to that project's pool. 0021 sends it too. */
#define TD4 __attribute__((section(".td4"), noinline))
TD4 static void td_project(void) {
  const volatile uint8_t *name = (const volatile uint8_t *)0x407c89d3u;
  uint8_t m[22];
  int i, n = 5;
  m[0] = 0xf0; m[1] = 0x7d; m[2] = 0x52; m[3] = 0x54; m[4] = 0x10;
  for (i = 0; i < 15 && name[i]; ++i) m[n++] = name[i] & 0x7f;
  m[n++] = 0xf7;
  if (!USB_FREE(4)) return;
  MIDI_LOCK();
  USB_MIDI_SEND(n, m);
  MIDI_UNLOCK();
}

__attribute__((section(".td5"), noinline)) int32_t td_ref(uint32_t *out, const uint8_t *model, int32_t index) {
  const uint8_t *begin = *(const uint8_t *const *)(model + 260);
  const uint8_t *end = *(const uint8_t *const *)(model + 264);
  const struct rec *r;
  uint32_t id, f, e;
  if (index < 0 || begin + 8 * index >= end) return 0;
  r = *(const struct rec *const *)(begin + 8 * index);
  if (!r) return 0;
  id = r->id;
  if (!IS_TID(id) || !(id & FILE_BIT)) return 0;
  f = (id >> 12) & 0x3ff;
  e = id & 0xfff;
  if (!USB_FREE(4)) return 0;   /* the host is not reading: the load fails visibly */
  td_project();
  {
    uint8_t m[10] = {0xf0, 0x7d, 0x52, 0x54, 0x0f, (uint8_t)((f >> 7) & 0x7f), (uint8_t)(f & 0x7f),
                     (uint8_t)((e >> 7) & 0x7f), (uint8_t)(e & 0x7f), 0xf7};
    MIDI_LOCK();
    USB_MIDI_SEND(10, m);
    MIDI_UNLOCK();
  }
  out[0] = POOL_MARK;
  out[1] = id;
  out[2] = out[3] = 0;
  return 1;
}

/* The stock functions' first instructions, re-emitted, then back in. */
__asm__(
    "  .section .td,\"ax\"\n"
    "  .align 2\n"
    "  .globl td_readdir_entry\n"
    "td_readdir_entry:\n"
    "  jmp td_readdir\n"
    "  .globl td_readdir_stock\n"
    "td_readdir_stock:\n"
    "  lea %sp@(-24),%sp\n"
    "  moveml %d2-%d5/%a2-%a3,%sp@\n"
    "  jmp 0x4007c050\n"
    "  .globl td_resolve_entry\n"
    "td_resolve_entry:\n"
    "  jmp td_resolve\n"
    "  .globl td_resolve_stock\n"
    "td_resolve_stock:\n"
    "  lea %sp@(-16),%sp\n"
    "  moveml %d2-%d3/%a2-%a3,%sp@\n"
    "  jmp 0x400804a0\n"
    "  .globl td_exists_entry\n"
    "td_exists_entry:\n"
    "  jmp td_exists\n"
    "  .globl td_exists_stock\n"
    "td_exists_stock:\n"
    "  movel %d2,%sp@-\n"
    "  movel %sp@(8),%d1\n"
    "  jmp 0x4008076c\n"
    "  .globl td_size_entry\n"
    "td_size_entry:\n"
    "  jmp td_size\n"
    "  .globl td_size_stock\n"
    "td_size_stock:\n"
    "  lea %sp@(-32),%sp\n"
    "  moveml %d2-%d5/%a2,%sp@\n"
    "  jmp 0x400808ac\n"
    /* No real folder or file named TEENSY (any case) in the +Drive's root: it
       would list as a second TEENSY beside the Teensy's (review MEDIUM 6;
       Transfer's mkdir /TEENSY/x made one, as on stock). td_tname(a0 = a name):
       d0 = -1 (flags set) when it is TEENSY ended by 0 or '/', else 0. */
    "td_tname:\n"
    "  lea td_teensy,%a1\n"
    "1:\n"
    "  moveb %a1@+,%d1\n"
    "  jeq 2f\n"
    "  moveb %a0@+,%d0\n"
    "  oril #0x20,%d0\n"
    "  oril #0x20,%d1\n"
    "  cmpb %d1,%d0\n"
    "  jeq 1b\n"
    "3:\n"
    "  moveq #0,%d0\n"
    "  rts\n"
    "2:\n"
    "  moveb %a0@,%d0\n"
    "  jeq 4f\n"
    "  cmpib #47,%d0\n"
    "  jne 3b\n"
    "4:\n"
    "  moveq #-1,%d0\n"
    "  rts\n"
    /* 0x4007b3b0(parent, name, node, ..) -> 0, -1: every new entry in a folder
       (mkdir, file create, rename, move): none named TEENSY in the root (id 2) */
    "  .globl td_link_entry\n"
    "td_link_entry:\n"
    "  moveq #2,%d0\n"
    "  cmpl %sp@(4),%d0\n"
    "  jne 5f\n"
    "  moveal %sp@(8),%a0\n"
    "  bsr td_tname\n"
    "  jne 6f\n"
    "5:\n"
    "  lea %sp@(-56),%sp\n"
    "  moveml %d2-%d7/%a2-%fp,%sp@\n"
    "  jmp 0x4007b3b8\n"
    /* 0x4007c170(path) -> 0, -1: mkdir. Refused for /TEENSY and anything under
       it: Transfer's mkdir makes each level in turn, and stock mkdir reads the
       name at a stale offset when the parent is missing [measured: stock 1.73,
       mkdir /factory/x/y, a wild read at 0x4007c1d2] */
    "  .globl td_mkdir_entry\n"
    "td_mkdir_entry:\n"
    "  movel %sp@(4),%d0\n"
    "  jeq 7f\n"
    "  moveal %d0,%a0\n"
    "  moveb %a0@+,%d0\n"
    "  cmpib #47,%d0\n"
    "  jne 7f\n"
    "  bsr td_tname\n"
    "  jeq 7f\n"
    "6:\n"
    "  moveq #-1,%d0\n"
    "  rts\n"
    "7:\n"
    "  linkw %fp,#-24\n"
    "  moveml %d2-%d3/%a2-%a3,%sp@\n"
    "  jmp 0x4007c178\n"
    "  .globl td_count_entry\n"
    "td_count_entry:\n"
    "  jmp td_count\n"
    "  .globl td_count_stock\n"
    "td_count_stock:\n"
    "  movel %a2,%sp@-\n"
    "  movel %d2,%sp@-\n"
    "  tstl 0x41843c70\n"
    "  jmp 0x40080854\n"
    /* 0x4007e62c(model, index), the reference returned through a0: Teensy files
       get a marked one (td_ref), the rest stock's */
    "  .globl td_ref_entry\n"
    "td_ref_entry:\n"
    "  movel %a0,%sp@-\n"
    "  movel %sp@(12),%sp@-\n"
    "  movel %sp@(12),%sp@-\n"
    "  movel %sp@(8),%sp@-\n"
    "  jsr td_ref\n"
    "  lea %sp@(12),%sp\n"
    "  moveal %sp@+,%a0\n"
    "  tstl %d0\n"
    "  jeq 1f\n"
    "  movel %a0,%d0\n"
    "  rts\n"
    "1:\n"
    "  linkw %fp,#-16\n"
    "  moveal %fp@(8),%a1\n"
    "  jmp 0x4007e634\n"
    "  .section .td3,\"ax\"\n"
    "  .align 2\n"
    /* 0x4007c5d4(id, .., buffer) -> path or 0 */
    "  .globl td_path_entry\n"
    "td_path_entry:\n"
    "  movel %sp@(4),%d0\n"
    "  andil #0xFF000000,%d0\n"
    "  cmpil #0x7E000000,%d0\n"
    "  jne 1f\n"
    "  moveq #0,%d0\n"
    "  rts\n"
    "1:\n"
    "  lea %sp@(-324),%sp\n"
    "  moveml %d2-%d7/%a2-%fp,%sp@\n"
    "  jmp 0x4007c5dc\n"
    /* 0x4007fff4(&ref, out) -> 1..4 found, -1 not */
    "  .globl td_check_entry\n"
    "td_check_entry:\n"
    "  movel %sp@(4),%d0\n"
    "  jeq 1f\n"
    "  moveal %d0,%a0\n"
    "  movel %a0@,%d0\n"
    "  andil #0xFF000000,%d0\n"
    "  cmpil #0x7E000000,%d0\n"
    "  jne 1f\n"
    "  moveq #-1,%d0\n"
    "  rts\n"
    "1:\n"
    "  lea %sp@(-24),%sp\n"
    "  moveml %d2/%a2-%fp,%sp@\n"
    "  jmp 0x4007fffc\n"
    /* CREATE DIR (invoker 0x400ea54a): mkdir(path) -> 0 made. a4 is the
       invoker's, its +4 the folder's path */
    "  .globl td_mkdir_guard\n"
    "td_mkdir_guard:\n"
    "  movel %a4@(4),%d0\n"
    "  jeq 1f\n"
    "  moveal %d0,%a0\n"
    "  tstb %a0@\n"
    "  jne 2f\n"
    "1:\n"
    "  moveq #-1,%d0\n"
    "  rts\n"
    "2:\n"
    "  jmp 0x4007c170\n");

/* ---------------------------------------------------------------------------
 * The project's Teensy pool in the stock slot list (2026-10-09; research:
 * rytm-emu docs/smpl-slot-list-research.md). On a DSP SAMPLE track (0021,
 * machine 45) the SMPL page's SMP knob is stock's record 41, so it opens the
 * stock slot list ("0:OFF", "1:name", "2:---", ..). Six of the list's and the
 * slot browser's calls come here (registry patches); on that track they answer
 * with the Teensy pool instead of the Rytm's sample slots:
 *   0x400e3c54  row label, slot empty?       td_empty: the pool slot's
 *   0x400e3cae  row label, slot name         td_name_entry: its name
 *   0x400e44ba  YES: slot empty?             td_empty (empty: the browser)
 *   0x400e45e8  YES/FUNC+YES: new browser    td_browse_entry: slot | 0x1000
 *   0x400e38c8  the browser's slot file      td_slotref_entry: none for
 *                                            | 0x1000 (opens at the root)
 *   0x400e60ac  a row's ">N" mark            td_mark_entry: a TEENSY file's
 *                                            pool slot
 * Picking a TEENSY file in such a browser reaches td_load_entry (the load,
 * 0x400b712e) with slot | 0x1000: td_assign sends 10 <project> and
 * 12 <slot> <f hi lo> <e hi lo>, and puts the file in the table at once. The
 * Teensy keeps the pool (slot N = line N-1 of its pool file) and pushes the
 * table: 14 <replace> <count> {<slot> <f hi lo> <e hi lo> <13 name bytes>};
 * asked for with 13 when a list draws a table that is missing or another
 * project's. The table (128 x 18 B) comes from the firmware's allocator, in the
 * UI task (td_pool_sysex, in the MIDI task, drops a table that is not there:
 * the next draw asks again).
 * ------------------------------------------------------------------------- */
#define TD5 __attribute__((section(".td5"), noinline))
#define TD6 __attribute__((section(".td6")))
#define SEL_TRACK (*(volatile uint8_t *)0x41318982u)
#define MACHINE(t) (((volatile uint8_t *)0x8000ea00u)[t])
#define DSPS_MACHINE 45
#define PROJECT ((const volatile uint8_t *)0x407c89d3u)
#define POOL_SLOT 0x1000u
#define NO_FILE 0x3fffu

struct pslot { uint16_t f, e; char name[14]; };   /* 18 B; name[0] 0: empty */
struct pool {
  struct pslot *s;            /* 128, from the allocator */
  uint8_t valid, wait, pad[2];
  uint8_t proj[16];           /* the project the table is for */
};
struct pool td_pool TD6 = {0, 0, 0, {0, 0}, {0}};

TD5 int td_pool_ctx(void) {
  uint8_t t = SEL_TRACK;
  return t < 12 && MACHINE(t) == DSPS_MACHINE;
}

TD5 int td_usb_free(int n) {
  const volatile uint32_t *h = *(const volatile uint32_t *const volatile *)0x413db390u;
  while (n-- > 0) {
    if (!h) return 0;
    h = (const volatile uint32_t *)h[13];
  }
  return 1;
}

TD5 static void td_send(const uint8_t *m, int32_t n) {
  if (!USB_FREE(4)) return;
  MIDI_LOCK();
  USB_MIDI_SEND(n, m);
  MIDI_UNLOCK();
}

/* The table, current or asked for (once in ~200 draws while it is not). */
TD5 TD_POOL_TAB struct pslot *td_pool_tab(void) {
  struct pool *q = &td_pool;
  int k, same = 1;
  if (!q->s) {
    uint32_t *w = (uint32_t *)NEW(128 * sizeof(struct pslot));
    if (!w) return 0;
    for (k = 0; k < 128 * (int)sizeof(struct pslot) / 4; ++k) w[k] = 0;
    q->s = (struct pslot *)w;
  }
  for (k = 0; k < 16; ++k)
    if (q->proj[k] != PROJECT[k]) same = 0;
  if (!same) q->valid = 0;
  if (!q->valid) {
    if (q->wait) {
      --q->wait;
    } else {
      static const uint8_t ask[6] TDD = {0xf0, 0x7d, 0x52, 0x54, 0x13, 0xf7};
      for (k = 0; k < 16; ++k) q->proj[k] = PROJECT[k];
      q->wait = 200;
      td_project();
      td_send(ask, 6);
    }
  }
  return q->s;
}

/* 14 from the Teensy (MIDI task, through 0022's router and td_sysex). */
TD5 int td_pool_sysex(const uint8_t *d, int32_t len) {
  struct pool *q = &td_pool;
  int32_t p, n, k, j;
  if (len < 8 || !q->s) return 1;
  if (d[5]) {
    for (k = 0; k < 128; ++k) q->s[k].name[0] = 0;
    q->valid = 1;
  }
  n = d[6];
  for (p = 7, k = 0; k < n && p + 18 <= len - 1; ++k, p += 18) {
    struct pslot *e;
    if (d[p] == 0 || d[p] > 127) continue;
    e = &q->s[d[p]];
    e->f = (uint16_t)((uint32_t)d[p + 1] << 7 | d[p + 2]);
    e->e = (uint16_t)((uint32_t)d[p + 3] << 7 | d[p + 4]);
    for (j = 0; j < 13 && d[p + 5 + j]; ++j) e->name[j] = (char)d[p + 5 + j];
    e->name[j] = 0;
    if (!j) e->name[0] = '?', e->name[1] = 0;   /* a slot in use shows */
  }
  return 1;
}

TD5 int td_hook(const uint8_t *d, int32_t len) {
  return d[4] == 0x14 ? td_pool_sysex(d, len) : td_sysex(d, len);
}

/* 0x400b8126(acc, i) on the list's two call sites: is slot i empty? */
int32_t td_empty_stock(void *acc, int32_t i);
TD5 int32_t td_empty(void *acc, int32_t i) {
  struct pslot *s;
  if (!td_pool_ctx()) return td_empty_stock(acc, i);
  if (i == 0) return 0;
  if (i < 0 || i > 127) return 1;
  s = td_pool_tab();
  return !s || !s[i].name[0];
}

/* The label's name of slot i, 0: stock's (OFF, the Rytm's slot names). */
TD5 const char *td_pool_name(int32_t i) {
  struct pslot *s;
  if (i <= 0 || i > 127 || !td_pool_ctx()) return 0;
  s = td_pool_tab();
  return s && s[i].name[0] ? s[i].name : 0;
}

/* The pool slot holding TEENSY file id (first one), else -1. */
TD5 int32_t td_mark(uint32_t id) {
  struct pslot *s = td_pool.s;
  uint32_t f = (id >> 12) & 0x3ff, e = id & 0xfff;
  int32_t k;
  if (!s) return -1;
  for (k = 1; k < 128; ++k)
    if (s[k].name[0] && s[k].f == f && s[k].e == e) return k;
  return -1;
}

/* A file picked in a pool slot's browser: a TEENSY file goes into the slot
   (12 to the Teensy, and the table at once); a +Drive file is refused (0). */
TD5 int32_t td_assign(const uint32_t *ref, uint32_t slot) {
  uint32_t id = ref ? ref[0] : 0, f, e, k;
  struct pslot *s;
  slot &= 0x7f;
  if ((id & 0xFF800000u) != (TID | FILE_BIT) || slot == 0) return 0;
  f = (id >> 12) & 0x3ff;
  e = id & 0xfff;
  td_project();
  {
    uint8_t m[11] = {0xf0, 0x7d, 0x52, 0x54, 0x12, (uint8_t)slot, (uint8_t)((f >> 7) & 0x7f), (uint8_t)(f & 0x7f),
                     (uint8_t)((e >> 7) & 0x7f), (uint8_t)(e & 0x7f), 0xf7};
    td_send(m, 11);
  }
  s = td_pool_tab();
  if (s) {
    struct tcache *c = &td_cache;
    s[slot].f = (uint16_t)f;
    s[slot].e = (uint16_t)e;
    s[slot].name[0] = '?';
    s[slot].name[1] = 0;
    if (c->valid && c->e && c->folder == f)
      for (k = 0; k < c->received && k < kCap; ++k)
        if (c->e[k].kind == 0 && c->e[k].id == e) {
          int j;
          for (j = 0; j < 13 && c->e[k].name[j]; ++j) s[slot].name[j] = c->e[k].name[j];
          s[slot].name[j] = 0;
          break;
        }
  }
  return 1;
}

__asm__(
    "  .section .td5,\"ax\"\n"
    "  .align 2\n"
    /* 0x400b712e(manager, &ref, slot): a pool slot's pick (slot | 0x1000) is
       td_assign's; a marked reference is loaded already, another Teensy one
       fails (0) */
    "  .globl td_load_entry\n"
    "td_load_entry:\n"
    "  movel %sp@(12),%d0\n"
    "  andil #0x1000,%d0\n"
    "  jeq 4f\n"
    "  movel %sp@(12),%sp@-\n"
    "  movel %sp@(12),%sp@-\n"
    "  jsr td_assign\n"
    "  addql #8,%sp\n"
    "  rts\n"
    "4:\n"
    "  moveal %sp@(8),%a0\n"
    "  movel %a0@,%d0\n"
    "  cmpil #0x7E504F4F,%d0\n"
    "  jne 2f\n"
    "  moveq #1,%d0\n"
    "  rts\n"
    "2:\n"
    "  andil #0xFF000000,%d0\n"
    "  cmpil #0x7E000000,%d0\n"
    "  jne 3f\n"
    "  moveq #0,%d0\n"
    "  rts\n"
    "3:\n"
    "  linkw %fp,#-28\n"
    "  moveml %d2-%d4/%a2,%sp@\n"
    "  jmp 0x400b7136\n"
    /* 0x400b8126(acc, i): stock's own first instructions, then back in */
    "  .globl td_empty_stock\n"
    "td_empty_stock:\n"
    "  moveq #127,%d1\n"
    "  movel %sp@(8),%d0\n"
    "  jmp 0x400b812c\n"
    /* 0x400b80ae(acc, i), the std::string out in a0: the pool's name, or stock */
    "  .globl td_name_entry\n"
    "td_name_entry:\n"
    "  movel %a0,%sp@-\n"
    "  movel %sp@(12),%sp@-\n"
    "  jsr td_pool_name\n"
    "  addql #4,%sp\n"
    "  moveal %sp@+,%a0\n"
    "  tstl %d0\n"
    "  jne 1f\n"
    "  jmp 0x400b80ae\n"
    "1:\n"
    "  subql #4,%sp\n"               /* the allocator byte 0x401bcd4c wants */
    "  movel %a0,%sp@-\n"
    "  pea %sp@(4)\n"
    "  movel %d0,%sp@-\n"
    "  movel %a0,%sp@-\n"
    "  jsr 0x401bcd4c\n"
    "  lea %sp@(12),%sp\n"
    "  movel %sp@+,%d0\n"
    "  addql #4,%sp\n"
    "  rts\n"
    /* 0x400e37fe(browser, slot): the pool's slots marked */
    "  .globl td_browse_entry\n"
    "td_browse_entry:\n"
    "  jsr td_pool_ctx\n"
    "  tstl %d0\n"
    "  jeq 2f\n"
    "  movel %sp@(8),%d0\n"
    "  oril #0x1000,%d0\n"
    "  movel %d0,%sp@(8)\n"
    "2:\n"
    "  jmp 0x400e37fe\n"
    /* 0x400b7228(project, slot), the 16-byte file reference out in a0: none
       (-1, as 0x4027c1e8) for a pool slot */
    "  .globl td_slotref_entry\n"
    "td_slotref_entry:\n"
    "  movel %sp@(8),%d0\n"
    "  andil #0x1000,%d0\n"
    "  jne 3f\n"
    "  jmp 0x400b7228\n"
    "3:\n"
    "  moveq #-1,%d0\n"
    "  movel %d0,%a0@\n"
    "  clrl %a0@(4)\n"
    "  clrl %a0@(8)\n"
    "  clrl %a0@(12)\n"
    "  movel %a0,%d0\n"
    "  rts\n"
    /* 0x400b8348(accessor, reference by value): a TEENSY file's pool slot */
    "  .globl td_mark_entry\n"
    "td_mark_entry:\n"
    "  movel %sp@(8),%d0\n"
    "  andil #0xFF800000,%d0\n"
    "  cmpil #0x7E800000,%d0\n"
    "  jeq 4f\n"
    "  jmp 0x400b8348\n"
    "4:\n"
    "  jsr td_pool_ctx\n"
    "  tstl %d0\n"
    "  jne 5f\n"
    "  moveq #-1,%d0\n"
    "  rts\n"
    "5:\n"
    "  movel %sp@(8),%sp@-\n"
    "  jsr td_mark\n"
    "  addql #4,%sp\n"
    "  rts\n");

