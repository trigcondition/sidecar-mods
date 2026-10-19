# Contributing

Thanks for helping with the Sidecar's Rytm mods. Hardware test reports, fixes and new mods are welcome.

## Workflow

1. **Fork** this repository on GitHub and clone your fork.
2. Create a branch for your change: `git checkout -b 0026-fix-keys`.
3. Make the change. For a new mod, follow "Adding a mod" in the README: symbols with an honest `status`, claims in
   `registry/allocations.toml`, `mods/NNNN-slug/{mod.toml,stub.s,design.md}`.
4. Build and verify against your own stock OS 1.73 (`make setup`, then `make verify`, or the Sidecar build in the
   README), and run the tests (below).
5. Push the branch to your fork and open a **pull request** against `main`. Fill in the template.
6. The `test` check must pass, and a code owner reviews and approves before the pull request is merged.
   `main` takes no direct pushes or force pushes.

Say in the pull request what the change was tested on: the build and verify, the emulator, or a real Rytm (and which
build tag). Flashing a modded OS carries risk: read `docs/HAZARDS.md` before you try anything on hardware.

## Tests

```
python3 tools/hash_expect.py --check     # the registry holds no stock bytes
python3 tools/test_build_excludes.py
python3 tools/test_layout.py
python3 tools/test_cavescan.py           # the image tests skip without a build
make comp-selftest                       # needs requirements.txt (make setup)
```

## Rules

- **No Elektron firmware, and nothing derived from it**: no `.syx`, sections, disassembly listings, dumps or bytes
  copied out of the OS image. Patch sources (assembly and C you write), addresses and symbol names as documentation
  are fine. A claim's `expect` bytes are stored hashed: run `python3 tools/hash_expect.py --image build/stock_mainos.bin`
  before you commit.
- **No personal data** in code, docs or commits: no e-mail addresses, home-directory paths or the like. Use paths
  relative to the repository (sibling checkouts as `../rytm-emu`, or the environment variables the tools read).
- **Licences.** This repository is GPL-2.0-or-later. Third-party tools are fetched by `make setup` at pinned commits
  (`NOTICE`), not copied in.
- By contributing you agree that your contribution is licensed under GPL-2.0-or-later.

## Reporting bugs

Open an issue with the bug template: the Rytm build tag, the Sidecar version and platform, and steps to reproduce. Do
not attach firmware files.
