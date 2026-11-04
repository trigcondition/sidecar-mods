#!/usr/bin/env python3
"""Stops the release while an UNRELEASED mark is left in the tree.

    python3 tools/check_unreleased.py

A mark is an HTML comment that opens with UNRELEASED (`<!--` then the word) beside text that waits on the release (a
hardware status, a hash). The comments do not show on GitHub's rendered page, but they are in the public snapshot and
the text beside them is not final. `make release-assets` and a4/tools/pack_release.sh run this first; everyday builds
do not. Exit status 1 while a tracked file holds one. Only the comment form counts, case-sensitive: prose or code that
names the word does not trip it.
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MARK = re.compile(r"<!--\s*UNRELEASED")

try:
    files = subprocess.run(["git", "-C", HERE, "ls-files", "-z"], check=True, capture_output=True).stdout
    files = [f for f in files.decode().split("\0") if f]
except (OSError, subprocess.CalledProcessError):     # an export without .git: every file but build output
    files = []
    for root, dirs, names in os.walk(HERE):
        dirs[:] = [d for d in dirs if d not in (".git", "build", "vendor", ".venv", "out")]
        files += [os.path.relpath(os.path.join(root, n), HERE) for n in names]
marked = []
for f in sorted(files):
    p = os.path.join(HERE, f)
    if not os.path.isfile(p):
        continue
    with open(p, "rb") as fh:
        data = fh.read()
    if b"\0" in data[:8192]:                        # binary
        continue
    marked += [f"{f}:{n}" for n, line in enumerate(data.decode(errors="replace").splitlines(), 1) if MARK.search(line)]
if marked:
    print("NOT RELEASING: UNRELEASED marks left in " + ", ".join(marked), file=sys.stderr)
    sys.exit(1)
print("no UNRELEASED mark left")
