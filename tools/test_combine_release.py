#!/usr/bin/env python3
"""tools/combine_release.py on dummy release folders (no build, no stock firmware)."""
import hashlib
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import combine_release  # noqa: E402


def make_folder(d, os_name, suffix, core, extra=None, toolchain=None):
    os.makedirs(d)
    files = {
        f"core-0.1{suffix}.elemod": f"core {os_name}",
        f"rytm-sidecar-0.4.0{suffix}.elemod": f"bundle {os_name}",
        f"elekloader-{core}-core-ar2-src.tar.gz": f"core source {core}",
        "elekloader-c150ac5-src.tar.gz": "builder source",
        "LICENSE": "GPL",
        "NOTICE": "notice",
        "TOOLCHAIN.txt": toolchain or f"release 0.4.0 for OS {os_name}, built from sidecar-mods abc\nas 2.47\n",
    }
    files.update(extra or {})
    for n, text in files.items():
        with open(os.path.join(d, n), "w") as fh:
            fh.write(text)
    write_sums(d)


def write_sums(d):
    names = sorted(n for n in os.listdir(d) if n != "SHA256SUMS")
    with open(os.path.join(d, "SHA256SUMS"), "w") as fh:
        for n in names:
            fh.write(f"{hashlib.sha256(open(os.path.join(d, n), 'rb').read()).hexdigest()}  {n}\n")


class Combine(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.a = os.path.join(self.tmp.name, "0.4.0")
        self.b = os.path.join(self.tmp.name, "0.4.0-os1.74")
        self.out = os.path.join(self.tmp.name, "0.4.0-assets")

    def tearDown(self):
        self.tmp.cleanup()

    def run_it(self):
        return combine_release.main([self.a, self.b, self.out, "--os-b", "1.74"])

    def test_twelve_files(self):
        make_folder(self.a, "1.73", "", "8972d70")
        make_folder(self.b, "1.74", "-os1.74", "13fa795")
        self.assertEqual(self.run_it(), 0)
        names = sorted(os.listdir(self.out))
        self.assertEqual(names, sorted([
            "core-0.1.elemod", "rytm-sidecar-0.4.0.elemod", "core-0.1-os1.74.elemod", "rytm-sidecar-0.4.0-os1.74.elemod",
            "elekloader-8972d70-core-ar2-src.tar.gz", "elekloader-13fa795-core-ar2-src.tar.gz",
            "elekloader-c150ac5-src.tar.gz", "LICENSE", "NOTICE", "TOOLCHAIN.txt", "TOOLCHAIN-os1.74.txt",
            "SHA256SUMS"]))
        self.assertIn("for OS 1.73,", open(os.path.join(self.out, "TOOLCHAIN.txt")).read())
        self.assertIn("for OS 1.74,", open(os.path.join(self.out, "TOOLCHAIN-os1.74.txt")).read())
        # the combined SHA256SUMS lists exactly the other eleven files, with their hashes
        combine_release.read_folder(self.out)
        self.assertEqual(len(open(os.path.join(self.out, "SHA256SUMS")).read().splitlines()), 11)

    def assert_refused(self):
        self.assertEqual(self.run_it(), 1)
        self.assertFalse(os.path.exists(self.out))

    def test_shared_file_differs(self):
        for shared in ("LICENSE", "NOTICE", "elekloader-c150ac5-src.tar.gz"):
            with self.subTest(shared):
                self.tearDown(); self.setUp()
                make_folder(self.a, "1.73", "", "8972d70")
                make_folder(self.b, "1.74", "-os1.74", "13fa795", extra={shared: "something else"})
                self.assert_refused()

    def test_shared_file_missing(self):
        make_folder(self.a, "1.73", "", "8972d70")
        make_folder(self.b, "1.74", "-os1.74", "13fa795")
        os.remove(os.path.join(self.b, "NOTICE"))
        write_sums(self.b)
        self.assert_refused()

    def test_stale_sums(self):
        make_folder(self.a, "1.73", "", "8972d70")
        make_folder(self.b, "1.74", "-os1.74", "13fa795")
        with open(os.path.join(self.b, "core-0.1-os1.74.elemod"), "w") as fh:
            fh.write("rebuilt")
        self.assert_refused()

    def test_syx_refused(self):
        make_folder(self.a, "1.73", "", "8972d70", extra={"Analog-Rytm_MKII_OS1.73_rel0-4-0.syx": "firmware"})
        make_folder(self.b, "1.74", "-os1.74", "13fa795")
        self.assert_refused()

    def test_folders_swapped(self):
        make_folder(self.a, "1.74", "-os1.74", "13fa795")
        make_folder(self.b, "1.73", "", "8972d70")
        self.assert_refused()

    def test_uncommitted(self):
        make_folder(self.a, "1.73", "", "8972d70",
                    toolchain="release 0.4.0 for OS 1.73, built from sidecar-mods abc (uncommitted changes)\n")
        make_folder(self.b, "1.74", "-os1.74", "13fa795")
        self.assert_refused()

    def test_out_not_empty(self):
        make_folder(self.a, "1.73", "", "8972d70")
        make_folder(self.b, "1.74", "-os1.74", "13fa795")
        os.makedirs(self.out)
        open(os.path.join(self.out, "old"), "w").close()
        self.assertEqual(self.run_it(), 1)
        self.assertEqual(os.listdir(self.out), ["old"])


if __name__ == "__main__":
    unittest.main()
