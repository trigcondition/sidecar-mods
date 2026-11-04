#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
"""release_assets.py's own tests: made-up files only, no firmware needed.

    python3 a4/tools/test_release_assets.py
"""
import hashlib
import io
import json
import os
import sys
import tarfile
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import release_assets as ra  # noqa: E402

SYSEX = b"\xf0\x00\x20\x3c\x0b\x00\x7e" + bytes(121) + b"\xf7"
LOCAL = b"/" + b"Users/someone/os.syx"


def elemod(id_, version, **more):
    doc = {"elemod": 1, "id": id_, "version": version, "target": {"device": "analog-four-mk2"},
           "sections": {".run": {"parts": [["stock", "0x400c6c8a", 8], ["hex", "7c7c2c6f"]]}},
           "sites": [{"addr": "0x40023678", "len": 6, "stock_sha256": "00"}]}
    doc.update(more)
    return json.dumps(doc).encode()


def tar(*members):
    b = io.BytesIO()
    with tarfile.open(fileobj=b, mode="w:gz") as t:
        for name, data in members:
            i = tarfile.TarInfo(name)
            i.size = len(data)
            t.addfile(i, io.BytesIO(data))
    return b.getvalue()


def good():
    return {"sidecar-a4-0.9.elemod": elemod("sidecar-a4", "0.9"), "core-0.3.elemod": elemod("core", "0.3"),
            "a4156.lock.json": json.dumps({"elekloader_store": 1, "device": "analog-four-mk2"}).encode(),
            "elekloader-c150ac5-src.tar.gz": tar(("elekloader/syx.py", b"MAGIC = b'ELE3'\n")),
            "LICENSE": b"GPL\n", "NOTICE": b"notice\n", "TOOLCHAIN.txt": b"gcc\n"}


class Assets(unittest.TestCase):
    def run_on(self, files, tag="a4-v0.9", sums=True):
        with tempfile.TemporaryDirectory() as d:
            files = dict(files)
            if sums:
                files["SHA256SUMS"] = "".join(f"{hashlib.sha256(v).hexdigest()}  {k}\n" for k, v in files.items()).encode()
            for k, v in files.items():
                with open(os.path.join(d, k), "wb") as fh:
                    fh.write(v)
            return ra.check_dir(d, tag)

    def refused(self, name, **more):
        self.assertIn(name, self.run_on({**good(), **more}), name)

    def test_a_good_release_passes(self):
        self.assertEqual(self.run_on(good()), {})

    def test_a_syx_by_name(self):
        f = {**good(), "a4156_sidecar.syx": b"x"}
        self.assertIn("a4156_sidecar.syx", self.run_on(f))

    def test_a_syx_in_any_case(self):
        f = {**good(), "A4.SYX": SYSEX}
        self.assertIn("A4.SYX", self.run_on(f))

    def test_a_syx_renamed_elemod(self):
        f = good()
        f["sidecar-a4-0.9.elemod"] = SYSEX
        self.assertIn("sidecar-a4-0.9.elemod", self.run_on(f))

    def test_a_syx_renamed_paper(self):
        f = good()
        f["NOTICE"] = SYSEX
        self.assertIn("NOTICE", self.run_on(f))

    def test_a_syx_in_the_source_tar(self):
        f = good()
        f["elekloader-c150ac5-src.tar.gz"] = tar(("a/os.syx", SYSEX))
        self.assertIn("elekloader-c150ac5-src.tar.gz", self.run_on(f))

    def test_firmware_bytes_under_another_name_in_the_tar(self):
        f = good()
        f["elekloader-c150ac5-src.tar.gz"] = tar(("a/notes.txt", SYSEX))
        self.assertIn("elekloader-c150ac5-src.tar.gz", self.run_on(f))

    def test_the_build_report_with_its_path(self):
        f = {**good(), "a4156_sidecar.syx.json": b'{"path": "' + LOCAL + b'"}'}
        self.assertIn("a4156_sidecar.syx.json", self.run_on(f))

    def test_a_local_path_in_a_paper(self):
        f = good()
        f["TOOLCHAIN.txt"] = b"built in " + LOCAL + b"\n"
        self.assertIn("TOOLCHAIN.txt", self.run_on(f))

    def test_an_unknown_file(self):
        f = {**good(), "os.zip": b"PK"}
        self.assertIn("os.zip", self.run_on(f))

    def test_a_big_json_elemod(self):
        f = good()
        f["core-0.3.elemod"] = elemod("core", "0.3", pad="x" * (1 << 21))
        self.assertIn("core-0.3.elemod", self.run_on(f))

    def test_an_elemod_with_stock_bytes_in_a_site(self):
        f = good()
        f["sidecar-a4-0.9.elemod"] = elemod("sidecar-a4", "0.9", sites=[{"addr": "0x1", "stock": "4e75"}])
        self.assertIn("sidecar-a4-0.9.elemod", self.run_on(f))

    def test_an_elemod_for_another_device(self):
        f = good()
        f["sidecar-a4-0.9.elemod"] = elemod("sidecar-a4", "0.9", target={"device": "analog-rytm-mk2"})
        self.assertIn("sidecar-a4-0.9.elemod", self.run_on(f))

    def test_the_tag_and_the_version_differ(self):
        self.assertIn("sidecar-a4-0.9.elemod", self.run_on(good(), tag="a4-v0.8"))

    def test_a_rytm_tag(self):
        self.assertIn("", self.run_on(good(), tag="v0.4.0"))

    def test_no_sums(self):
        self.assertIn("", self.run_on(good(), sums=False))

    def test_a_wrong_sum(self):
        with tempfile.TemporaryDirectory() as d:
            f = good()
            f["SHA256SUMS"] = b"".join(b"0" * 64 + b"  " + k.encode() + b"\n" for k in good())
            for k, v in f.items():
                with open(os.path.join(d, k), "wb") as fh:
                    fh.write(v)
            self.assertIn("SHA256SUMS", ra.check_dir(d, "a4-v0.9"))

    def test_a_file_the_sums_miss(self):
        with tempfile.TemporaryDirectory() as d:
            f = good()
            f["SHA256SUMS"] = "".join(f"{hashlib.sha256(v).hexdigest()}  {k}\n" for k, v in f.items()
                                      if k != "NOTICE").encode()
            for k, v in f.items():
                with open(os.path.join(d, k), "wb") as fh:
                    fh.write(v)
            self.assertIn("SHA256SUMS", ra.check_dir(d, "a4-v0.9"))

    def test_a_symlink(self):
        with tempfile.TemporaryDirectory() as d:
            os.symlink("/etc/hosts", os.path.join(d, "NOTICE"))
            self.assertIn("NOTICE", ra.check_dir(d, "a4-v0.9"))


if __name__ == "__main__":
    unittest.main()
