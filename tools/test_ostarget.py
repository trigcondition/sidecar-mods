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
