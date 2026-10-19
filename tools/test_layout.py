#!/usr/bin/env python3
"""tools/test_layout.py - layout.validate's overlap rules on small registries.

    .venv/bin/python tools/test_layout.py
"""
import hashlib
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import layout  # noqa: E402

EXCL = {"a": {"b"}, "b": {"a"}}


def reg(patches, detours=()):
    return {"pool": [], "patch": list(patches), "detour": list(detours)}


def patch(owner, addr):
    return dict(owner=owner, addr=addr, size=4, expect="00000000", replace="11111111")


def detour(owner, addr):
    return dict(owner=owner, addr=addr, size=6, expect="000000000000", entry="x")


class Overlaps(unittest.TestCase):
    def test_two_mods_patching_the_same_bytes(self):
        errs = layout.validate(reg([patch("a", 0x1000), patch("b", 0x1002)]), None, {}, {})
        self.assertTrue(any("both claim" in e for e in errs), errs)

    def test_mutually_exclusive_mods_may_patch_the_same_bytes(self):
        errs = layout.validate(reg([patch("a", 0x1000), patch("b", 0x1002)]), None, {}, EXCL)
        self.assertEqual([e for e in errs if "both claim" in e], [])

    def test_a_patch_over_a_detour(self):
        errs = layout.validate(reg([patch("a", 0x1002)], [detour("b", 0x1000)]), None, {}, {})
        self.assertTrue(any("overlaps detour" in e for e in errs), errs)

    def test_a_patch_over_an_exclusive_mods_detour(self):
        errs = layout.validate(reg([patch("a", 0x1002)], [detour("b", 0x1000)]), None, {}, EXCL)
        self.assertEqual([e for e in errs if "overlaps detour" in e], [])


class Guards(unittest.TestCase):
    """A guard (replace == expect, guard = true) is allowed, and another mod's patch over it is caught."""

    def guard(self, owner, addr, **kw):
        return dict(owner=owner, addr=addr, size=4, expect="11111111", replace="11111111", guard=True, **kw)

    def test_a_no_op_patch_is_refused(self):
        errs = layout.validate(reg([dict(self.guard("a", 0x1000), guard=False)]), None, {}, {})
        self.assertTrue(any("does nothing" in e for e in errs), errs)

    def test_a_guard_is_allowed(self):
        self.assertEqual(layout.validate(reg([self.guard("a", 0x1000)]), None, {}, {}), [])

    def test_a_guard_must_not_change_bytes(self):
        errs = layout.validate(reg([dict(self.guard("a", 0x1000), replace="22222222")]), None, {}, {})
        self.assertTrue(any("guard must" in e for e in errs), errs)

    def test_another_mods_patch_over_a_guard(self):
        errs = layout.validate(reg([self.guard("a", 0x1000), patch("c", 0x1002)]), None, {}, {})
        self.assertTrue(any("both claim" in e for e in errs), errs)


def hashed(c):
    """The claim as the registry holds it: expect as length + sha256 (tools/hash_expect.py)."""
    c = dict(c)
    b = bytes.fromhex(c.pop("expect"))
    if c.get("guard") and c.get("replace") == b.hex():
        c.pop("replace")
    return dict(c, expect_len=len(b), expect_sha256=hashlib.sha256(b).hexdigest())


class HashedExpect(unittest.TestCase):
    """A registry without stock bytes validates and resolves as the hex one did."""

    BASE = 0x1000
    IMAGE = bytes.fromhex("0000000011111111000000000000")

    def test_the_same_checks_without_the_image(self):
        g = Guards().guard("a", 0x1004)
        self.assertEqual(layout.validate(reg([hashed(patch("a", 0x1000)), hashed(g)],
                                             [hashed(detour("b", 0x1008))]), None, {}, {}), [])
        errs = layout.validate(reg([hashed(dict(g, guard=False))]), None, {}, {})
        self.assertTrue(any("does nothing" in e for e in errs), errs)

    def test_resolve_fills_expect_and_a_guards_replace(self):
        g = Guards().guard("a", 0x1004)
        r = reg([hashed(patch("a", 0x1000)), hashed(g)], [hashed(detour("b", 0x1008))])
        layout.resolve_expect(r, self.IMAGE, self.BASE)
        self.assertEqual(r["patch"][0]["expect"], "00000000")
        self.assertEqual((r["patch"][1]["expect"], r["patch"][1]["replace"]), ("11111111", "11111111"))
        self.assertEqual(r["detour"][0]["expect"], "000000000000")

    def test_replace_from_copies_stock_bytes(self):
        p = dict(hashed(patch("a", 0x1000)), size=4)
        p.pop("replace")
        p["replace_from"] = 0x1004
        r = reg([p])
        self.assertEqual(layout.validate(r, None, {}, {}), [])
        layout.resolve_expect(r, self.IMAGE, self.BASE)
        self.assertEqual(r["patch"][0]["replace"], "11111111")

    def test_resolve_refuses_other_bytes(self):
        r = reg([hashed(patch("a", 0x1004))])   # expects 00000000, the image holds 11111111 there
        with self.assertRaises(SystemExit):
            layout.resolve_expect(r, self.IMAGE, self.BASE)


if __name__ == "__main__":
    unittest.main()
