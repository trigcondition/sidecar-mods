# Contributing

Thanks for helping with the Sidecar's Rytm mods. Hardware test reports, fixes and new mods are welcome.

`main` holds the releases, `dev` is the development branch: work goes on a feature branch off `dev`, and pull requests go
to `dev`. Releases reach `main` from `dev`, and the maintainer merges those. Feature branches are public too. `dev` moves and can be
broken; it is not a release. On every branch: no firmware (see Rules), and run the tests below before you open the pull
request.

## Before you start

- **Find or open an issue first** for anything bigger than a small fix, and say you'd like to take it. Wait for a
  "go" (the `claimed` label and your name on the issue) before you build. The roadmap (trigcondition/sidecar-firmware#68, pinned; board: https://github.com/users/trigcondition/projects/3) shows what is
  planned and who is on it.
- **One topic per pull request**, linked with `Closes #n`. A pull request that bundles several topics, or depends on
  another open one, is hard to review: say the order in the description.
- **Changes on both sides** (a Sidecar message and the Rytm mod that uses it) get one issue and two pull requests
  that link each other. Both must work with the other side's previous release: an older Sidecar with your mod, and
  your Sidecar with the previous mod release.
- **Protocol additions** (a new message, a new version of one, a new kit-file line) are documented in the same pull
  request: what it carries, who sends it, and what an older side does with it.
- **Sound changes** for existing kits, cards or plugins (a default that moves, a range that changes) get a line for the
  release notes in the pull request.
- AI-assisted code is fine; you are still the one who tested it. Say what you ran and on what.

## Workflow

1. **Fork** this repository on GitHub and clone your fork, then `git checkout dev`.
2. Create a branch for your change from `dev`: `git checkout -b 0026-fix-keys dev`.
3. Make the change. For a new mod, follow "Adding a mod" in the README: symbols with an honest `status`, claims in
   `registry/allocations.toml`, `mods/NNNN-slug/{mod.toml,stub.s,design.md}`.
4. Build and verify against your own stock OS 1.73 (`make setup`, then `make verify`, or the Sidecar build in the
   README), and run the tests (below).
5. Push the branch to your fork and open a **pull request** against `dev`. Fill in the template.
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

## Rytm mods: shared resources

The mods share the Rytm with each other and with stock. Most conflicts come from these, so a change that touches one
says so in its pull request:

- **RAM.** The elekloader RAM left with the full mod set is small. Every pull request states its RAM and code-space
  cost (the build reports it) and what is left with the full set. A change that leaves less than the agreed reserve
  (8 KB) needs a "go" first. New buffers go to the areas `registry/allocations.toml` lists, with a claim.
- **Keys.** Key handlers run in a fixed order (`ev_key` subscribers by their order number; 0026 is at 10). A new combo or a
  held-back key is listed in the mod's `design.md` with every existing combo it could touch (UP + Tn, UP + SRC,
  UP + arrows for FILL / GENERATOR, page-key cycles). Prefer the Rytm's own patterns (a page key that cycles
  pages) over new two-key gestures.
- **Parameter records and kit words.** There are no free parameter records on OS 1.74; a mod that borrows records
  restores them on every exit (page leave, kit change, project load, the Sidecar dropping out). Kit words that mods
  use are listed in the registry; nothing is written into the kit or pattern that the registry does not claim.
- **Tests.** Every change has an emulator test (`tools/emu/*_emu.py`, OS 1.74, `DTEMU_STRICT=1`) that fails without
  it, and the pull request runs `tools/emu/suites.py <tag> --changed <base>`. Hardware reports are welcome and say the
  OS, the build tag, the Pi model and the Sidecar version. Nothing is flashed from a pull request: the maintainer's
  release path (full suites, flash rehearsals both ways) decides what ships.

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
