#!/usr/bin/env python3
"""tools/ostarget.py's map and port, without firmware: re/os/1.74.toml as committed, against the registry and sources.

    python3 tools/test_ostarget.py
"""
import sys
import tempfile
import tomllib
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import layout      # noqa: E402
import ostarget    # noqa: E402

ROOT = ostarget.ROOT


class MapTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.m = ostarget.the_map("1.74")
        cls.doc = ostarget.load("1.74")

    def test_shifts(self):
        # the study's segments and elekloader's own core 0.1 port (13fa795 mod.json) agree on these
        self.assertEqual(self.m.tr(0x400008c0), 0x400008c0)          # boot site, below the first change
        self.assertEqual(self.m.tr(0x400a2bee), 0x400a2c5a)          # ev_tick: +0x6c
        self.assertEqual(self.m.tr(0x4011fb02), 0x4011fb6e)          # ev_render_in
        self.assertEqual(self.m.tr(0x40193f4e), 0x4019411a)          # FN_MGR: +0x1cc
        self.assertEqual(self.m.tr(0x401e34fc), 0x401e37ac)          # a vtable: +0x2b0

    def test_untranslate(self):
        for a in (0x400008c0, 0x400a2bee, 0x401bf918, 0x40287ccc, 0x80000000):
            self.assertEqual(self.m.untr(self.m.tr(a)), a)
        with self.assertRaises(ostarget.Refused):
            self.m.untr(0x402cc920)              # 1.73's padding there, and 1.74's code moved over it: two answers
        self.assertEqual(ostarget.address_in("1.73", 0x401bf918), 0x401bf918)     # the sources' own tree

    def test_outside_the_image(self):
        for a in (0x80000000, 0x8000e508, 0x41318982, 0x47be0000, 0xfc070000, 0x2ca):
            self.assertEqual(self.m.tr(a), a)

    def test_changed_region_refuses(self):
        with self.assertRaises(ostarget.Refused):
            self.m.tr(0x40057460)                                    # SELECT TRACKS: 1.74's 16 rows
        with self.assertRaises(ostarget.Refused):
            self.m.tr(0x40123e00)                                    # the Outbox settings code

    def test_text(self):
        t = ostarget.Translator(self.m)
        out = t.text("jsr 0x400a2bee\n#define X ((void *)0x400A2BEEu)\nmove.l #1074408430,%d0\n0x80000000\n",
                     "x.s", dec=True)
        self.assertEqual(out, "jsr 0x400a2c5a\n#define X ((void *)0x400A2C5Au)\nmove.l #1074408538,%d0\n"
                              "0x80000000\n")
        t.text("lea 0x40057460,%a0\n", "y.s")
        self.assertEqual(len(t.refused), 1)

    def test_gas_long_decimal(self):
        """9279e63: gcc writes some absolute operands as `N.l`."""
        t = ostarget.Translator(self.m)
        out = t.text("\tcmp.l 1074408430.l,%d2\n\tmove.l 0x400a2bee.w,%d0\n", "stub.s", dec=True)
        self.assertEqual(out, "\tcmp.l 1074408538.l,%d2\n\tmove.l 0x400a2c5a.w,%d0\n")
        self.assertEqual(t.refused, [])

    def refused(self, text, dec=False, allow=()):
        t = ostarget.Translator(self.m, allow)
        out = t.text(text, "x.c", dec=dec)
        return t.refused, out

    def test_net_refuses_untranslated_forms(self):
        for text, why in (("jsr 1074408430\n", "decimal in a hand-written file"),
                          ("move.l #$400a2bee,%d0\n", "Motorola $hex"),
                          ("{0x40, 0x0a, 0x2b, 0xee}\n", "a byte array"),
                          ("{0x400a, 0x2bee}\n", "two halves"),
                          ("(0x400a << 16) | lo\n", "a high half"),
                          ("BASE + 0xa27ee\n", "the image base plus an offset"),
                          ("0x40000400 + 0xa27ee\n", "the base literal plus an offset"),
                          ("0x40_0a_2b_ee\n", "another digit grouping")):
            with self.subTest(why):
                ref, out = self.refused(text)
                self.assertEqual(len(ref), 1, ref)
                self.assertEqual(out, text)                              # left as it was, never half-translated

    def test_net_refuses_changed_regions(self):
        ref, _ = self.refused("lea $40057460,%a0\n")
        self.assertEqual(len(ref), 1)
        self.assertIn("changed", ref[0])

    def test_net_leaves_values(self):
        for text in ("0x4000 | FP_A\n", "{0x4000, 0x0001}\n", "x = 1073741824\n", "BASE + ms // 5\n",
                     "0x80000000 + 0x10\n"):
            with self.subTest(text):
                self.assertEqual(self.refused(text)[0], [])

    def test_not_address_allow_list(self):
        ref, out = self.refused("jsr 0x400a2bee\n{0x400a, 0x2bee}\n", allow={("x.c", 0x400a2bee)})
        self.assertEqual((ref, out), ([], "jsr 0x400a2bee\n{0x400a, 0x2bee}\n"))
        for x in self.doc.get("not_address", []):
            with self.subTest(x["file"]):
                self.assertTrue(x.get("reason"))
                hit = ostarget.Translator(self.m)
                hit.text((ROOT / x["file"]).read_text(), x["file"], bare=x["file"].startswith("tools/"))
                self.assertTrue(any(f"0x{x['value']:08x}" in r for r in hit.refused),
                                f"{x['file']}: no longer holds 0x{x['value']:08x}: drop the entry")

    def test_every_claim_has_a_target_hash(self):
        """A new detour or patch needs its 1.74 hash (tools/ostarget.py derive), or the port refuses it."""
        reg = layout.load(ROOT / "registry" / "allocations.toml")
        exp = self.doc.get("expect", {})
        missing = [f"{t} {c['owner']} 0x{c['addr']:08x}" for t in ("detour", "patch") for c in reg.get(t, [])
                   if "expect_sha256" in c
                   and ostarget.expect_key(c["addr"], c["expect_len"], c["expect_sha256"]) not in exp]
        self.assertEqual(missing, [])
        pools = {p["name"] for p in reg.get("pool", [])}
        self.assertEqual(pools - set(self.doc.get("pool", {})), set())

    def test_data_entries_agree(self):
        """[[data]] (0.5.0): the same RAM in both OSes, each 1.74 site the map's translation of the 1.73 one (the
        bytes themselves: tools/ostarget.py data OS, which needs the stock images)."""
        a = {d["name"]: d for d in ostarget.load("1.73").get("data", [])}
        b = {d["name"]: d for d in self.doc.get("data", [])}
        self.assertEqual(set(a), set(b))
        self.assertIn("qperf_pos", a)
        for n in a:
            with self.subTest(n):
                self.assertEqual((a[n]["value"], a[n]["size"], a[n]["at"]), (b[n]["value"], b[n]["size"], b[n]["at"]))
                self.assertEqual(self.m.tr(a[n]["site"]), b[n]["site"])
                if a[n]["size"] == 4:   # an address the port leaves as it is (RAM)
                    self.assertEqual(self.m.tr(a[n]["value"]), a[n]["value"])

    def test_port_refuses_nothing(self):
        with tempfile.TemporaryDirectory() as d:
            rc = ostarget.port("1.74", Path(d) / "t", quiet=True)
            log = (Path(d) / "t" / "port.log").read_text()
            self.assertEqual(rc, 0, log[:2000])
            with open(Path(d) / "t" / "re" / "symbols.toml", "rb") as f:
                meta = tomllib.load(f)["meta"]
            self.assertEqual(meta["target"], "OS1.74")
            self.assertEqual(meta["mainos_sha256"], self.doc["meta"]["mainos_sha256"])
            self.assertEqual(ostarget.tree_os(Path(d) / "t"), "1.74")


if __name__ == "__main__":
    unittest.main()
