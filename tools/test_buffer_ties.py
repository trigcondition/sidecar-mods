#!/usr/bin/env python3
"""tools/test_buffer_ties.py - build.py's check_buffer_ties: 0026's SFU_OVL literal is sfu_p's claim + 4704 (F1).

    .venv/bin/python tools/test_buffer_ties.py
"""
import copy
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build   # noqa: E402
import layout  # noqa: E402

BOTH = {"0026-remote-ui", "0029-sendfx-ui"}
REG = layout.load(build.ROOT / "registry" / "allocations.toml")


class BufferTies(unittest.TestCase):
    def test_the_tree_agrees(self):
        self.assertEqual(build.check_buffer_ties(REG, BOTH), [])

    def test_a_moved_claim_fails(self):
        moved = copy.deepcopy(REG)
        for c in moved["buffer"]:
            if c["name"] == "sfu_p":
                c["addr"] += 16
        errs = build.check_buffer_ties(moved, BOTH)
        self.assertEqual(len(errs), 1, errs)
        self.assertIn("SFU_OVL", errs[0])

    def test_a_changed_offset_fails(self):
        tie = [("0026-remote-ui", "rui.c", "SFU_OVL", "0029-sendfx-ui", "sfu_p", 4708)]
        self.assertEqual(len(build.check_buffer_ties(REG, BOTH, tie)), 1)

    def test_a_build_without_one_of_the_mods_is_not_checked(self):
        moved = copy.deepcopy(REG)
        for c in moved["buffer"]:
            if c["name"] == "sfu_p":
                c["addr"] += 16
        self.assertEqual(build.check_buffer_ties(moved, {"0026-remote-ui"}), [])
        self.assertEqual(build.check_buffer_ties(moved, {"0029-sendfx-ui"}), [])

    def test_a_missing_define_fails(self):
        tie = [("0026-remote-ui", "rui.c", "NO_SUCH_MACRO", "0029-sendfx-ui", "sfu_p", 4704)]
        self.assertEqual(len(build.check_buffer_ties(REG, BOTH, tie)), 1)


if __name__ == "__main__":
    unittest.main()
