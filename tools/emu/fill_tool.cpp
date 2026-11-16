// tools/emu/fill_tool.cpp - sq_emu.py fillwrite's helper: the Sidecar host's own FILL code (core/seq/lockfill.cpp,
// core/seq/rytm_dump.cpp from the RYTM_TEENSY checkout, built by the test) on pattern dumps the emulator answered.
//   dump IN.syx                                   the record's tracks: length and trig steps
//   fill IN.syx OUT.syx OUT.rec ORIG.rec          BD's SAMPLE (P11 + fine) on its trigs (TRIGS ALL, ORDER UP, values
//                                                 10..13 fine 0x20), as FILL's YES patches the read record
//   undo ORIG.rec WRITTEN.rec IN.syx OUT.syx OUT.rec
//                                                 FUNC + NO: the target as before the fill put back on a fresh read IN,
//                                                 refused (exit 3, CHANGED SINCE) when IN's target is not as written
//   verify REC IN.syx                             lockfill::same both ways (the Rytm re-sorts its lock list); exit 0 same
// Prints "steps: a b c" (fill) and "smp: s=value .." (verify) for the test to read.
#include <cstdio>
#include <cstring>
#include <vector>

#include "seq/lockfill.h"
#include "seq/rytm_dump.h"

using namespace core;
namespace lf = lockfill;
static std::vector<uint8_t> M(rytm_dump::kAnswer);
static const lf::Target kSmp = {lf::kLock, 10, true};

static bool load_syx(const char* f, std::vector<uint8_t>& rec) {
  FILE* fp = fopen(f, "rb");
  if (!fp) return false;
  size_t n = fread(M.data(), 1, M.size(), fp);
  fclose(fp);
  rec.assign(lf::kRecord, 0);
  return n == M.size() && rytm_dump::parse_id(M.data(), (int)n, 0x5A, rec.data(), nullptr);
}
static bool load_rec(const char* f, std::vector<uint8_t>& rec) {
  FILE* fp = fopen(f, "rb");
  if (!fp) return false;
  rec.assign(lf::kRecord, 0);
  size_t n = fread(rec.data(), 1, rec.size(), fp);
  fclose(fp);
  return n == rec.size();
}
static void save(const char* f, const uint8_t* p, size_t n) {
  FILE* fp = fopen(f, "wb");
  fwrite(p, 1, n, fp);
  fclose(fp);
}
static void write_out(std::vector<uint8_t>& rec, const char* syx, const char* r) {   // M: the answer the record came in
  rytm_dump::repack(M.data(), rec.data());
  save(syx, M.data(), M.size()), save(r, rec.data(), rec.size());
}

int main(int argc, char** argv) {
  std::vector<uint8_t> r, a, b;
  const char* c = argc > 1 ? argv[1] : "";
  if (!strcmp(c, "dump") && argc == 3) {
    if (!load_syx(argv[2], r)) return printf("parse failed\n"), 1;
    printf("slots %d\n", lf::slots_used(r.data()));
    for (int t = 0; t < 12; ++t) {
      printf("t%d len %d trigs:", t, lf::track_len(r.data(), t));
      for (int s = 0; s < 64; ++s)
        if (lf::trig_on(r.data(), t, s)) printf(" %d", s);
      printf("\n");
    }
    return 0;
  }
  if (!strcmp(c, "fill") && argc == 6) {
    if (!load_syx(argv[2], r)) return printf("parse failed\n"), 1;
    save(argv[5], r.data(), r.size());
    lf::Options o;   // TRIGS ALL, EVERY 1, OFFSET 0, ORDER UP
    uint8_t st[lf::kSteps];
    int n = lf::steps_for(r.data(), 0, kSmp, o, st);
    printf("steps:");
    for (int i = 0; i < n; ++i) printf(" %d", st[i]);
    printf("\n");
    uint16_t set[4] = {lf::value(10, 0x20), lf::value(11, 0x20), lf::value(12, 0x20), lf::value(13, 0x20)};
    uint16_t v[lf::kSteps];
    lf::sequence(set, 4, n, o, v);
    if (!n) return printf("no trigs\n"), 1;
    int res = lf::fill(r.data(), 0, kSmp, st, v, n);
    if (res) return printf("fill: %s\n", lf::result_text(res)), 1;
    write_out(r, argv[3], argv[4]);
    return 0;
  }
  if (!strcmp(c, "undo") && argc == 7) {
    if (!load_rec(argv[2], a) || !load_rec(argv[3], b) || !load_syx(argv[4], r)) return printf("load failed\n"), 1;
    lf::Saved undo, after, now;
    lf::save(a.data(), 0, kSmp, &undo);    // the page's pending (before the patch)
    lf::save(b.data(), 0, kSmp, &after);   // its pafter (as the patch left it)
    lf::save(r.data(), 0, kSmp, &now);     // patch_undo's check on the fresh read
    if (!lf::equal(now, after)) return printf("undo: %s\n", lf::result_text(lf::kChanged)), 3;
    int res = lf::restore(r.data(), undo);
    if (res) return printf("undo: %s\n", lf::result_text(res)), 1;
    write_out(r, argv[5], argv[6]);
    return 0;
  }
  if (!strcmp(c, "verify") && argc == 4) {
    if (!load_rec(argv[2], a) || !load_syx(argv[3], b)) return printf("load failed\n"), 1;
    bool ok = lf::same(a.data(), b.data());
    int d = 0;
    for (int i = 0; i < lf::kRecord; ++i) d += a[i] != b[i];
    printf("same %s (raw bytes differing %d)\nsmp:", ok ? "YES" : "NO", d);
    for (int s = 0; s < lf::kSteps; ++s)
      if (lf::has_value(b.data(), 0, kSmp, s)) printf(" %d=%04x", s, lf::get(b.data(), 0, kSmp, s));
    printf("\n");
    return ok ? 0 : 1;
  }
  fprintf(stderr, "usage: see the head of fill_tool.cpp\n");
  return 2;
}
