# Releasing the A4 mod

The A4 mod lives in this repository under `a4/`, with its own tags, `a4-v<mod version>` (`a4-v0.12`), and its own GitHub releases. It reaches people with Sidecar 0.4.0, not before: its docs and patcher entry stay unreleased until then.

**A release holds `.elemod` files and their papers. Never a `.syx`.** A built `.syx` holds Elektron's firmware, and so does nothing else here. `a4/out/` is ignored, and its `.syx.json` holds local paths.

## What CI can run

| Where | What |
|---|---|
| `test` workflow, on a change under `a4/` or `.github/` | No firmware tracked; the tools and the mod's JSON parse; `test_release_assets.py`; the mod's C sources through a cross compiler with elekloader's headers |
| `test` workflow, on any other change | The Rytm's tool tests. A change that is only under `a4/` skips them |
| `a4-release` workflow, on a release | `release_assets.py` on the release's real assets; a refusal takes them down and makes the release a draft |
| **Only on your own machine** | `a4_suite.py`, `a4_e2e.py`, the flash rehearsals, `build.sh`. All need a stock `Analog-Four_MKII_OS1.56.syx`, which cannot be in this repository or in CI, and analog-emu. The Rytm's emulator suites are the same |

So CI never builds the mod and never proves it works. The local runs below are the proof.

## Steps

1. **On your own machine, at the release commit:** set `mod.json`'s version and the `STAMP` default in `build.sh`, build, then run `a4_suite.py`, `a4_e2e.py` and the rehearsals stock to the build and back, as in [README.md](README.md). All on the same bytes.
2. **On a real A4:** flash that build, play it, and go back to stock. A build that has not run on a unit is not released.
3. **Pack:** `ELEKLOADER=/path/elekloader a4/tools/pack_release.sh a4/out RELEASE_DIR` copies the two `.elemod` files by name, the lock file, `LICENSE`, `NOTICE`, elekloader's source and `TOOLCHAIN.txt`, writes `SHA256SUMS`, and runs `release_assets.py` on the folder. It must end with `nothing refused`.
4. **Snapshot:** publish as a snapshot export, as the Rytm's releases, never private history. Scan it: no personal name, Mac username or e-mail, only trigcondition; no local path; no firmware.
5. **Pull request** to `dev`, then `main`. The code owner merges.
6. **Tag** the merged commit: `a4-v<version>`, annotated.
7. **Draft first:** `gh release create a4-v<version> --draft --title "..." --notes "..." RELEASE_DIR/*`, read the file list, then publish with `gh release edit a4-v<version> --draft=false`. Publishing runs the `a4-release` workflow; wait for it to pass.
8. **Docs:** the site's patcher entry and A4 page lose their unreleased marks ([PATCHER.md](https://github.com/trigcondition/sidecar-expander/blob/main/PATCHER.md)).

Adding an asset to a release already published fires no workflow: GitHub has no such event. Do not add one; if you must, follow it with `gh release edit` so the check runs again.

## The patcher's file

The web patcher does not read `.elemod` files. It applies a record file made from the stock file and the built `.syx`, which holds no Elektron bytes: `a4/tools/a4_patch.py`, run by the docs repository's `scripts/make_patches.py`. Its result is byte for byte the build that was tested.

## Building from the `.elemod` files by hand

The tested bytes need the lock file and the build's stamp:

```sh
python3 -m elekloader.patch --stock Analog-Four_MKII_OS1.56.syx --mod core-0.3.elemod --mod sidecar-a4-0.12.elemod \
    --lockfile a4156.lock.json --version SA12 --out sidecar.syx
```

Without `--lockfile`, or with another `--version`, the `.syx` has other bytes from the tested one, and the hash will not match.
