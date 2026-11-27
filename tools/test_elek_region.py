#!/usr/bin/env python3
"""tools/test_elek_region.py - the pinned elekloader accepts a bundle's resources.regions inside the profile's `big` area.

    .venv/bin/python tools/test_elek_region.py

The next mods build claims a region of `big` (0x47938000-0x47FFF000, the Rytm profile's bigger DDR area) for its
bundle. A builder that does not know the area refuses it with "outside every free area" (elekloader c150ac5).
Region bounds are the builder's own check (elekloader.elemod.parse_resources, the one the patcher runs on each mod
of a bundle); nothing here builds an image.
"""
import contextlib
import copy
import io
import json
import os
import sys
import unittest
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build  # noqa: E402
import layout  # noqa: E402
import ostarget  # noqa: E402
import verify  # noqa: E402

sys.path.insert(0, str(build.ELEK_DIR))
from elekloader import elemod  # noqa: E402
from elekloader.devices import analog_rytm_mk2 as prof  # noqa: E402

BIG_LO, BIG_HI = 0x47938000, 0x47FFF000
BUF_LO, BUF_HI = 0x47C00000, 0x47F00000      # the Sidecar's 3 MB block (registry pool sidecar_buffers)
ROOT = Path(build.ROOT)
OSV = "1.74"      # the only supported OS


def doc(lo, hi):
    return {"resources": {"regions": [{"name": "sidecar-room", "lo": lo, "hi": hi}]}}


class BigRegion(unittest.TestCase):
    def test_the_profile_has_big(self):
        self.assertEqual(prof.DEVICE.areas.get("big"), (BIG_LO, BIG_HI))

    def test_a_region_inside_big_is_accepted(self):
        regions, _names = elemod.parse_resources(doc(0x47C00000, 0x47F00000), "rytm-sidecar", prof.DEVICE)
        self.assertEqual([(r["lo"], r["hi"], r["area"]) for r in regions], [(0x47C00000, 0x47F00000, "big")])

    def test_the_whole_of_big_is_accepted(self):
        regions, _names = elemod.parse_resources(doc(BIG_LO, BIG_HI), "rytm-sidecar", prof.DEVICE)
        self.assertEqual(regions[0]["area"], "big")

    def test_a_region_past_big_is_refused(self):
        with self.assertRaises(elemod.ModError) as cm:
            elemod.parse_resources(doc(BIG_HI - 0x1000, BIG_HI + 0x1000), "rytm-sidecar", prof.DEVICE)
        self.assertIn("outside every free area", str(cm.exception))


class BundleRegion(unittest.TestCase):
    """The build's own side: the bundle declares the registry's pool as its region, per OS, and refuses the rest."""

    def setUp(self):
        self.reg = layout.load(ROOT / "registry" / "allocations.toml")
        self.os_doc = ostarget.load(OSV)
        self.dev = prof.DEVICE

    def regions(self, reg=None, os_doc=None):
        return build.bundle_regions(reg or self.reg, os_doc or self.os_doc, OSV, self.dev)

    def pool(self, reg):
        return next(p for p in reg["pool"] if p["name"] == "sidecar_buffers")

    def test_the_registry_has_the_pool(self):
        p = self.pool(self.reg)
        self.assertEqual((p["kind"], p["start"], p["end"]), ("ddr", BUF_LO, BUF_HI))
        self.assertIn(p["status"], ("verified", "probably-verified", "candidate"))

    def test_the_bundle_declares_the_region(self):
        self.assertEqual(self.regions(), [{"name": "sidecar buffers", "lo": "0x47c00000", "hi": "0x47f00000"}])

    def test_the_declared_region_passes_the_builders_check(self):
        regions = self.regions()
        parsed, _ = elemod.parse_resources({"resources": {"regions": regions}}, "rytm-sidecar", self.dev)
        self.assertEqual([(g["lo"], g["hi"], g["area"]) for g in parsed], [(BUF_LO, BUF_HI, "big")])

    def moved(self, start, end):
        """The registry's pool and this OS's entry, both moved (a consistent but wrong block)."""
        reg, os_doc = copy.deepcopy(self.reg), copy.deepcopy(self.os_doc)
        self.pool(reg).update(start=start, end=end)
        os_doc["pool"]["sidecar_buffers"].update(start=start, end=end)
        return reg, os_doc

    def test_a_pool_outside_the_big_area_is_refused(self):
        for start, end in ((BIG_LO - 0x1000, BUF_HI), (BUF_LO, BIG_HI + 0x1000)):
            with self.assertRaises(SystemExit, msg=f"0x{start:08x}-0x{end:08x}") as cm:
                self.regions(*self.moved(start, end))
            self.assertIn("outside", str(cm.exception))

    def test_a_pool_overlapping_elekloaders_area_is_refused(self):
        lo, hi = self.dev.ddr
        for start, end in ((lo, BUF_HI), (BUF_LO - 0x1000, BUF_HI), (BIG_LO, hi + 0x1000)):
            with self.assertRaises(SystemExit, msg=f"0x{start:08x}-0x{end:08x}") as cm:
                self.regions(*self.moved(start, end))
            self.assertIn("elekloader's area", str(cm.exception))

    def test_a_pool_below_elekloaders_area_is_refused(self):
        """A2 review M2: the block must not reach below elekloader's area: 0x47938000-0x47BE0000 holds the OS's
        boot-cleared block (0x479372E0 on), and the step tags of core 0.11 and later (0x47938000-0x47B10000)."""
        for start, end in ((BIG_LO, BIG_LO + 0x100000), (0x47A00000, 0x47BE0000), (0x47BC0000, 0x47BE0000)):
            with self.assertRaises(SystemExit, msg=f"0x{start:08x}-0x{end:08x}") as cm:
                self.regions(*self.moved(start, end))
            self.assertIn("below", str(cm.exception))

    def claims(self, *claims):
        reg = copy.deepcopy(self.reg)
        reg["pool"] = [p for p in reg["pool"] if p["name"] == "sidecar_buffers"]
        self.pool(reg)["status"] = "verified"
        reg["buffer"] = [dict({"owner": "reserved:t", "name": "t", "addr": BUF_LO, "size": 0x1000}, **c) for c in claims]
        return [e for e in layout.validate(reg) if "buffer" in e]

    def test_a_buffer_claim_of_no_size_is_refused(self):
        """A2 review L1: size 0 or negative (a claim that fits any pool and overlaps nothing)"""
        for size in (0, -0x1000):
            self.assertTrue(any("size" in e for e in self.claims({"size": size})), size)

    def test_a_misaligned_buffer_claim_is_refused(self):
        for c in ({"addr": BUF_LO + 4}, {"addr": BUF_LO + 8}, {"size": 0x1004}, {"size": 0x10f}):
            self.assertTrue(any("16-byte" in e for e in self.claims(c)), c)

    def test_a_buffer_claim_needs_a_name_and_a_new_one(self):
        self.assertTrue(any("name" in e for e in self.claims({"name": ""})))
        self.assertTrue(any("name" in e for e in self.claims({"name": "Upper"})))
        two = self.claims({"name": "x"}, {"name": "x", "addr": BUF_LO + 0x1000})
        self.assertTrue(any("both" in e and "'x'" in e for e in two), two)
        self.assertEqual(self.claims({"name": "x"}, {"name": "y", "addr": BUF_LO + 0x1000}), [])

    def test_a_claim_next_to_its_size_named_claim_is_refused(self):
        """A3 review L4: foo and foo_size both give RAM_FOO_SIZE (the first's size, the second's address)"""
        for a, b in (("foo", "foo_size"), ("foo_size", "foo")):
            errs = self.claims({"name": a}, {"name": b, "addr": BUF_LO + 0x1000})
            self.assertTrue(any("RAM_FOO_SIZE" in e for e in errs), (a, b, errs))
        self.assertEqual(self.claims({"name": "foo"}, {"name": "foo_sizes", "addr": BUF_LO + 0x1000}), [])

    def test_an_os_without_the_pool_is_refused(self):
        os_doc = copy.deepcopy(self.os_doc)
        del os_doc["pool"]["sidecar_buffers"]
        with self.assertRaises(SystemExit) as cm:
            self.regions(os_doc=os_doc)
        self.assertIn(f"re/os/{OSV}.toml", str(cm.exception))

    def test_an_os_with_other_addresses_is_refused(self):
        os_doc = copy.deepcopy(self.os_doc)
        os_doc["pool"]["sidecar_buffers"]["end"] = BUF_HI - 0x1000
        with self.assertRaises(SystemExit) as cm:
            self.regions(os_doc=os_doc)
        self.assertIn("differ", str(cm.exception))

    def test_an_os_without_evidence_is_refused(self):
        for key in ("status", "evidence"):
            os_doc = copy.deepcopy(self.os_doc)
            del os_doc["pool"]["sidecar_buffers"][key]
            with self.assertRaises(SystemExit, msg=key):
                self.regions(os_doc=os_doc)

    def test_the_os_file_has_the_pool(self):
        # only OS 1.74 is supported: re/os/1.73.toml has no entry, and a bundle build for 1.73 is refused
        p = ostarget.load("1.74")["pool"]["sidecar_buffers"]
        self.assertEqual((p["start"], p["end"]), (BUF_LO, BUF_HI))
        self.assertTrue(p["status"] and p["evidence"])
        self.assertNotIn("sidecar_buffers", ostarget.load("1.73").get("pool", {}))

    def test_a_buffer_claim_inside_the_pool_is_accepted(self):
        reg = copy.deepcopy(self.reg)
        reg["buffer"] = [{"owner": "reserved:test", "name": "t", "addr": BUF_LO, "size": 0x1000}]
        reg["pool"] = [p for p in reg["pool"] if p["name"] == "sidecar_buffers"]
        pool = self.pool(reg)
        pool["status"] = "verified"
        self.assertEqual([e for e in layout.validate(reg) if "buffer" in e], [])

    def test_a_buffer_claim_outside_the_pool_is_refused(self):
        reg = copy.deepcopy(self.reg)
        reg["pool"] = [p for p in reg["pool"] if p["name"] == "sidecar_buffers"]
        self.pool(reg)["status"] = "verified"
        for addr, size in ((BUF_LO - 0x100, 0x200),           # across the pool's bottom, into elekloader's area
                           (BUF_HI - 0x100, 0x200),           # across its top
                           (self.dev.ddr[0], 0x100),          # inside elekloader's area
                           (BUF_HI, 0x100)):                  # above it
            reg["buffer"] = [{"owner": "reserved:test", "name": "t", "addr": addr, "size": size}]
            errs = layout.validate(reg)
            self.assertTrue(any("buffer claim" in e and "does not fit" in e for e in errs), f"0x{addr:08x}: {errs}")

    def test_two_buffer_claims_may_not_overlap(self):
        reg = copy.deepcopy(self.reg)
        reg["pool"] = [p for p in reg["pool"] if p["name"] == "sidecar_buffers"]
        self.pool(reg)["status"] = "verified"
        reg["buffer"] = [{"owner": "reserved:a", "name": "a", "addr": BUF_LO, "size": 0x2000},
                         {"owner": "reserved:b", "name": "b", "addr": BUF_LO + 0x1000, "size": 0x2000}]
        self.assertTrue(any("overlaps" in e for e in layout.validate(reg)))

    def test_a_candidate_pool_takes_no_claim(self):
        reg = copy.deepcopy(self.reg)
        reg["pool"] = [p for p in reg["pool"] if p["name"] == "sidecar_buffers"]
        self.pool(reg)["status"] = "candidate"
        reg["buffer"] = [{"owner": "0026-remote-ui", "name": "t", "addr": BUF_LO, "size": 0x1000}]
        self.assertTrue(any("candidate" in e for e in layout.validate(reg)))


class BufferSymbols(unittest.TestCase):
    """build.buffer_symbols: each enabled mod's claims as the assembler symbols RAM_<NAME> / RAM_<NAME>_SIZE"""
    REG = {"buffer": [
        {"owner": "0026-remote-ui", "name": "rui_a", "addr": BUF_LO, "size": 0x400},
        {"owner": "0026-remote-ui", "name": "rui_b", "addr": BUF_LO + 0x400, "size": 0x800},
        {"owner": "0029-sendfx-ui", "name": "sfu_x", "addr": BUF_LO + 0x1000, "size": 0x1a40},
        {"owner": "0029-sendfx-ui", "name": "sfu_g", "addr": BUF_LO + 0x3000, "size": 0x100, "gate": "big"},
        {"owner": "0099-other", "name": "oth", "addr": BUF_LO + 0x4000, "size": 0x100}]}

    def mods(self, big=0):
        return {"0026-remote-ui": {"_params": {}}, "0029-sendfx-ui": {"_params": {"big": big}},
                "0099-other": {"_params": {}}}

    def test_each_claim_gives_its_mod_the_address_and_the_size(self):
        mods = self.mods(big=1)
        build.buffer_symbols(self.REG, mods, ["0026-remote-ui", "0029-sendfx-ui"], True)
        self.assertEqual(mods["0026-remote-ui"]["_ram"], {"RAM_RUI_A": BUF_LO, "RAM_RUI_A_SIZE": 0x400,
                                                          "RAM_RUI_B": BUF_LO + 0x400, "RAM_RUI_B_SIZE": 0x800})
        self.assertEqual(mods["0029-sendfx-ui"]["_ram"],
                         {"RAM_SFU_X": BUF_LO + 0x1000, "RAM_SFU_X_SIZE": 0x1a40,
                          "RAM_SFU_G": BUF_LO + 0x3000, "RAM_SFU_G_SIZE": 0x100})

    def test_a_gated_out_claim_gives_no_symbols(self):
        mods = self.mods(big=0)
        build.buffer_symbols(self.REG, mods, ["0026-remote-ui", "0029-sendfx-ui"], True)
        self.assertEqual(sorted(mods["0029-sendfx-ui"]["_ram"]), ["RAM_SFU_X", "RAM_SFU_X_SIZE"])

    def test_a_mod_that_is_not_enabled_gets_none_and_its_claims_are_not_needed(self):
        mods = self.mods()
        build.buffer_symbols(self.REG, mods, ["0026-remote-ui"], True)
        self.assertNotIn("_ram", mods["0029-sendfx-ui"])
        self.assertNotIn("_ram", mods["0099-other"])

    def test_a_build_without_a_bundle_is_refused(self):
        with self.assertRaises(SystemExit) as cm:
            build.buffer_symbols(self.REG, self.mods(), ["0026-remote-ui", "0029-sendfx-ui"], False)
        self.assertIn("--elek-bundle", str(cm.exception))

    def test_a_build_without_a_claiming_mod_needs_no_bundle(self):
        mods = self.mods()
        mods["0050-none"] = {"_params": {}}
        build.buffer_symbols(self.REG, mods, ["0050-none"], False)
        self.assertEqual(mods["0050-none"]["_ram"], {})


class CheckBuffers(unittest.TestCase):
    """verify.check_buffers on the manifest of a bundle with the registry's claims: clean, and the six refusals"""

    def setUp(self):
        reg = layout.load(ROOT / "registry" / "allocations.toml")
        enabled = ["0026-remote-ui", "0029-sendfx-ui"]
        self.manifest = {"enabled": enabled, "params": {}}
        claims = [c for c in reg["buffer"] if c["owner"] in enabled and not c.get("gate")]
        self.assertGreaterEqual(len(claims), 10)
        self.elek = {"area": [0x47BE0000, 0x47C00000], "regions": [{"name": "sidecar buffers", "lo": BUF_LO, "hi": BUF_HI}],
                     "buffers": [{"owner": c["owner"], "name": c["name"], "lo": c["addr"], "hi": c["addr"] + c["size"]}
                                 for c in claims]}

    def run_check(self):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            ok = verify.check_buffers(self.manifest, self.elek)
        return ok, out.getvalue()

    def refused(self, text):
        ok, out = self.run_check()
        self.assertFalse(ok, out)
        self.assertIn(text, out)

    def test_the_registrys_claims_pass(self):
        ok, out = self.run_check()
        self.assertTrue(ok, out)
        self.assertIn("ok   10 DDR buffers", out)

    def test_a_claim_missing_from_the_manifest_is_refused(self):
        del self.elek["buffers"][3]
        self.refused("are not the registry's")

    def test_a_claim_the_registry_does_not_have_is_refused(self):
        self.elek["buffers"][0]["name"] = "rui_other"
        self.refused("are not the registry's")

    def test_two_overlapping_claims_are_refused(self):
        b = self.elek["buffers"]
        reg = {(x["owner"], x["name"]): x for x in b}
        reg[("0026-remote-ui", "rui_staging")]["lo"] = reg[("0026-remote-ui", "rui_shadow")]["lo"] + 16
        self.refused("overlaps")

    def test_a_claim_beyond_the_region_is_refused(self):
        self.elek["regions"][0]["hi"] = self.elek["buffers"][-1]["hi"] - 16
        self.refused("not inside a region")

    def test_a_claim_in_elekloaders_area_is_refused(self):
        self.elek["area"] = [self.elek["buffers"][0]["lo"] - 0x1000, self.elek["buffers"][0]["lo"] + 16]
        self.refused("overlaps elekloader's area")

    def test_a_bundle_without_a_region_is_refused(self):
        self.elek["regions"] = []
        self.refused("not inside a region")


class BuiltBundle(unittest.TestCase):
    """A bundle that was built (build/release/*/rytm-sidecar-*.elemod, here or in the port) declares its OS's region.
    Skipped where nothing was built."""

    def test_the_built_bundles_declare_the_region(self):
        files = sorted(ROOT.glob("build/release/*/rytm-sidecar-*.elemod")) + \
            sorted(ROOT.glob("build/os/*/build/release/*/rytm-sidecar-*.elemod"))
        docs = [(f, json.loads(f.read_text())) for f in files]
        docs = [(f, d) for f, d in docs if d["target"]["os"] == OSV]     # only OS 1.74 is supported
        if not docs:
            self.skipTest("no built bundle for OS 1.74")
        for f, doc in docs:
            p = ostarget.load(OSV)["pool"]["sidecar_buffers"]
            want = [{"name": "sidecar buffers", "lo": f"0x{p['start']:08x}", "hi": f"0x{p['end']:08x}"}]
            self.assertEqual(doc.get("resources", {}).get("regions"), want, f.name)


if __name__ == "__main__":
    unittest.main()
