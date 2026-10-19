#!/usr/bin/env python3
"""tools/test_build_excludes.py - build.py refuses mutually exclusive mods in one image.

    .venv/bin/python tools/test_build_excludes.py

layout.validate skips overlaps between mods that declare `excludes`, so build.py must
refuse such a combination outright rather than rely on a cave or expect collision.
"""
import os
import sys
import unittest
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build  # noqa: E402
import layout  # noqa: E402

EXCL = layout.load_excludes(Path(build.ROOT))


class Excludes(unittest.TestCase):
    def refused(self, mods):
        with self.assertRaises(SystemExit) as cm:
            build.check_excludes(set(mods), EXCL)
        self.assertIn("mutually exclusive", str(cm.exception))

    def test_0020_and_0021(self):
        self.refused(["0000-shared", "0020-dmach", "0021-ext"])

    def test_0002_and_0021(self):
        self.refused(["0002-euclid-accents", "0021-ext"])

    def test_0009_and_0021(self):
        # 0009's cave (cave7's head) holds 0021's .us5 since the Task 11 review (2026-10-10)
        self.refused(["0009-main-rms", "0021-ext"])

    def test_0004_and_0021(self):
        # 0004 packs its settings into sound index 0, the user slots' sound tag; its cave2 holds 0021's .us6 (2026-10-10)
        self.refused(["0004-lfo-rnd", "0021-ext"])

    def test_0003_and_0021(self):
        # 0003 needs 0002, which 0021 excludes: without this, euclid's accents would go silently (2026-10-11)
        self.refused(["0003-velocity-humanise", "0021-ext"])

    def test_0006_and_0021(self):
        # 0006's caves (cave4, cave9) hold the user slots
        self.refused(["0006-comp-preview", "0021-ext"])

    def test_0013_and_0021(self):
        # 0013's caves (cave3, cave5) hold the user slots
        self.refused(["0013-voice-dac", "0021-ext"])

    def test_the_user_slot_build_passes(self):
        build.check_excludes({"0014-hidden-machines", "0021-ext", "0022-looper",
                              "0023-teensy-drive"}, EXCL)

    def test_the_symmetric_map_is_used(self):
        # 0021 declares the exclusion; a map from 0002's side alone must still refuse.
        with self.assertRaises(SystemExit):
            build.check_excludes({"0002-euclid-accents", "0021-ext"},
                                 {"0002-euclid-accents": {"0021-ext"}})


class ParamExcludes(unittest.TestCase):
    """0021's user slots take over 0014's FUNC. GEN. and TEST records: refused with funcgen or test on."""

    def mods(self, **p0014):
        mods = build.load_mods({"0014-hidden-machines", "0021-ext", "0022-looper", "0023-teensy-drive"})
        mods["0014-hidden-machines"]["_params"].update(p0014)
        return mods, {m for m, d in mods.items() if d.get("enabled")}

    def test_funcgen_refused(self):
        with self.assertRaises(SystemExit) as cm:
            build.check_param_excludes(*self.mods(variants=1, funcgen=1, test=0))
        self.assertIn("funcgen=1", str(cm.exception))

    def test_test_refused(self):
        with self.assertRaises(SystemExit) as cm:
            build.check_param_excludes(*self.mods(variants=1, funcgen=0, test=1))
        self.assertIn("test=1", str(cm.exception))

    def test_us1_passes(self):
        build.check_param_excludes(*self.mods(variants=1, funcgen=0, test=0))

    def test_without_0021_passes(self):
        mods = build.load_mods({"0014-hidden-machines"})
        mods["0014-hidden-machines"]["_params"].update(funcgen=1, test=1)
        build.check_param_excludes(mods, {"0014-hidden-machines"})


class LinkedParams(unittest.TestCase):
    """0021's, 0022's and 0023's `slots` go together (0021 calls 0023's td_pool_tab, 0022 routes 1A..1D)."""
    ALL = {"0014-hidden-machines", "0021-ext", "0022-looper", "0023-teensy-drive"}

    def mods(self, **slots):
        mods = build.load_mods(self.ALL)
        for who, v in slots.items():
            mods[who.replace("_", "-")]["_params"]["slots"] = v
        return mods, {m for m, d in mods.items() if d.get("enabled")}

    def test_defaults_agree(self):
        # every slots defaults to 0: the hardware builds stay the pre-slot image
        mods, en = self.mods()
        self.assertEqual({mods[m]["_params"]["slots"] for m in ("0021-ext", "0022-looper", "0023-teensy-drive")}, {0})
        build.check_linked_params(mods, en)

    def test_all_on_passes(self):
        build.check_linked_params(*self.mods(**{"0021_ext": 1, "0022_looper": 1, "0023_teensy_drive": 1}))

    def test_0021_without_0023_refused(self):
        # 0021 slots=1 reads td_pool_tab from the third mailbox word; 0023 slots=0 has 8 B there
        with self.assertRaises(SystemExit) as cm:
            build.check_linked_params(*self.mods(**{"0021_ext": 1, "0022_looper": 1}))
        self.assertIn("linked param slots", str(cm.exception))

    def test_0022_alone_refused(self):
        with self.assertRaises(SystemExit):
            build.check_linked_params(*self.mods(**{"0022_looper": 1}))

    def test_a_disabled_mod_is_not_checked(self):
        # 0023 (not in the image) has slots=1; 0021 and 0022 agree on 0
        mods = build.load_mods({"0021-ext", "0022-looper"})
        mods["0023-teensy-drive"]["_params"]["slots"] = 1
        build.check_linked_params(mods, {"0021-ext", "0022-looper"})

    def test_0021_slots_without_0022_0023_refused(self):
        # review 2026-10-11: slots=1 needs every mod that lists slots in the image
        for only in ({"0021-ext"}, {"0021-ext", "0022-looper"}, {"0021-ext", "0023-teensy-drive"}):
            mods = build.load_mods(only)
            for m in only:
                mods[m]["_params"]["slots"] = 1
            with self.assertRaises(SystemExit) as cm:
                build.check_linked_params(mods, only)
            self.assertIn("needs", str(cm.exception))

    def test_0021_alone_slots_0_passes(self):
        build.check_linked_params(build.load_mods({"0021-ext"}), {"0021-ext"})


if __name__ == "__main__":
    unittest.main()
