"""Validate registry/allocations.toml: every claim inside its pool, no overlaps."""

import hashlib
import re
import tomllib
from pathlib import Path

# claim table -> the pattern of the pool names a claim may live in; each claim must fit
# wholly in one. Every pool named cave, cave2, cave3, ... holds cave claims.
POOL_OF = {"cave": r"cave\d*",
           "ram": r"patch_ram"}

# A pool at status "candidate" has not been proven on hardware, so the only thing
# allowed to claim it is the mod that does the proving. Without this the pools would
# simply be listed and the next feature mod would help itself to unverified space -
# which is the mistake octatrack-mods made once already. A probe earns the exception
# by being the experiment: it puts nothing in the image it is not willing to lose.
PROBE_SUFFIXES = ("-probe", "-canary")


def load(path: Path) -> dict:
    with open(path, "rb") as fh:
        return tomllib.load(fh)


# A claim's `expect` - the stock bytes at its host - is kept out of the registry: it holds `expect_len` and
# `expect_sha256` (tools/hash_expect.py), and resolve_expect reads the bytes from the stock image once a build has it.
# `expect` as hex is still accepted (a claim being written, the tests' own registries).
def expect_len(c: dict) -> int:
    return len(bytes.fromhex(c["expect"])) if "expect" in c else c["expect_len"]


def same_as_expect(c: dict, hexstr: str) -> bool:
    """True if these bytes are the claim's expect, from the hex or from its length and hash."""
    if "expect" in c:
        return c["expect"] == hexstr
    b = bytes.fromhex(hexstr)
    return len(b) == c["expect_len"] and hashlib.sha256(b).hexdigest() == c["expect_sha256"]


def resolve_expect(reg: dict, image: bytes, base: int) -> None:
    """Fill each patch's and detour's `expect` from the stock image, checked against its `expect_sha256`; a guard's
    `replace` is its expect, and a patch's `replace_from` (a copy of stock bytes elsewhere, e.g. a parameter record)
    becomes its `replace`. A mismatch aborts: the registry and the pinned stock image disagree."""
    for c in reg.get("patch", []):
        if "replace_from" in c and "replace" not in c:
            off = c["replace_from"] - base
            c["replace"] = bytes(image[off:off + c["size"]]).hex()
    for table in ("patch", "detour"):
        for c in reg.get(table, []):
            if "expect" in c or "expect_sha256" not in c:
                continue
            off = c["addr"] - base
            b = bytes(image[off:off + c["expect_len"]])
            if len(b) != c["expect_len"] or hashlib.sha256(b).hexdigest() != c["expect_sha256"]:
                raise SystemExit(f"{table} by {c['owner']} at 0x{c['addr']:08x}: the stock bytes there do not match "
                                 f"its expect_sha256 - the address is wrong or the image is not the pinned stock")
            c["expect"] = b.hex()
            if c.get("guard") and "replace" not in c:
                c["replace"] = c["expect"]


def _overlaps(a_start, a_size, b_start, b_size):
    return a_start < b_start + b_size and b_start < a_start + a_size


def gated_out(gate, params, owner):
    """True if a claim's `gate` says to skip it.

    A gate names a mod param; the claim applies only when that param is truthy, a
    leading "!" inverts it, and `name==value` selects one of several. That is what lets
    two claims cover the same region with exactly one selected, so a mod can stage
    several phases from one region and still build each of them.

    Terms joined by "&" must all hold, so a claim can apply only when several params
    are off at once.

    An unknown param name aborts rather than silently disabling a claim.
    """
    if gate is None:
        return False
    if "&" in gate:
        return any(gated_out(g.strip(), params, owner) for g in gate.split("&"))
    if "==" in gate:
        name, _, want = gate.partition("==")
        name = name.strip()
        if name not in params:
            raise SystemExit(f"{owner}: gate {gate!r} names no param in mod.toml [params]")
        # "phase==3|4" selects a SET, so a claim shared by several phases needs one entry
        # rather than one per phase.
        return str(params[name]) not in {w.strip() for w in want.split("|")}
    negate = gate.startswith("!")
    name = gate[1:] if negate else gate
    if name not in params:
        raise SystemExit(f"{owner}: gate {gate!r} names no param in mod.toml [params]")
    return bool(params[name]) == negate


def load_excludes(root: Path) -> dict:
    """owner -> the owners it declares `excludes`, made symmetric.

    Two mods may implement the same feature different ways and deliberately claim the
    same region. They can never be in one image, so a collision between them is not a
    bug; a collision between either and anything else still is. Without this a
    standalone run, which treats every mod as active, reports the overlap forever and
    trains you to ignore the one check that catches real ones.
    """
    ex: dict[str, set] = {}
    for f in sorted((root / "mods").glob("*/mod.toml")):
        with open(f, "rb") as fh:
            m = tomllib.load(fh)
        mid = m["mod"]["id"]
        for other in m["mod"].get("excludes", []):
            ex.setdefault(mid, set()).add(other)
            ex.setdefault(other, set()).add(mid)
        # excludes_params "MOD:PARAM": never in one image with MOD's PARAM on (build.py's
        # check_param_excludes refuses it), so MOD's claims gated on exactly PARAM are
        # exclusive with this mod's. Kept as "MOD:PARAM" entries, never equal to a mod id.
        for spec in m["mod"].get("excludes_params", []):
            ex.setdefault(mid, set()).add(spec)
    return ex


def validate(reg: dict, enabled: set[str] | None = None, params: dict | None = None,
             excludes: dict | None = None) -> list[str]:
    """Return a list of human-readable problems; empty means the layout is sound.

    `params` maps owner -> that mod's [params]. Without it, gated claims are all treated
    as active, which makes two mutually exclusive claims on one region look like a
    collision - so build.py always passes it.
    """
    errors: list[str] = []
    excludes = excludes or {}
    pools = {p["name"]: p for p in reg.get("pool", [])}

    def exclusive(a, b):
        """True if these two claims belong to mods that can never share an image."""
        if b["owner"] in excludes.get(a["owner"], ()):
            return True
        # a mod's excludes_params: the other's claims gated on exactly that param
        return any(f"{y['owner']}:{y.get('gate')}" in excludes.get(x["owner"], ())
                   for x, y in ((a, b), (b, a)))

    def active(claim):
        if not (enabled is None or claim["owner"] in enabled
                or claim["owner"].startswith("reserved:")):
            return False
        if params is None or claim["owner"] not in params:
            return True
        return not gated_out(claim.get("gate"), params[claim["owner"]], claim["owner"])

    for table, pattern in POOL_OF.items():
        claims = [c for c in reg.get(table, []) if active(c)]
        table_pools = [p for n, p in pools.items() if re.fullmatch(pattern, n)]
        if not table_pools:
            if claims:
                errors.append(f"{table}: no pool matching {pattern!r} is defined")
            continue
        for c in claims:
            lo, hi = c["addr"], c["addr"] + c["size"]
            home = next((p for p in table_pools
                         if p["start"] <= lo and hi <= p["end"]), None)
            if home is None:
                spans = ", ".join(f"{p['name']} 0x{p['start']:08x}..0x{p['end']:08x}"
                                  for p in table_pools)
                errors.append(
                    f"{table} claim by {c['owner']} at 0x{lo:08x}+0x{c['size']:x} "
                    f"does not fit wholly inside any pool ({spans})"
                )
            elif (home.get("status") == "candidate"
                  and not c["owner"].endswith(PROBE_SUFFIXES)):
                errors.append(
                    f"{table} claim by {c['owner']} at 0x{lo:08x}+0x{c['size']:x} is in "
                    f"pool {home['name']}, which is status \"candidate\" - not proven on "
                    f"hardware. Only a probe may claim it: run the experiment that "
                    f"promotes the pool, record the result in its note, and change its "
                    f"status. See the dead-code pool preamble in allocations.toml."
                )
        for i, a in enumerate(claims):
            for b in claims[i + 1:]:
                if exclusive(a, b):
                    continue
                if _overlaps(a["addr"], a["size"], b["addr"], b["size"]):
                    errors.append(
                        f"{table}: {a['owner']} (0x{a['addr']:08x}+0x{a['size']:x}) overlaps "
                        f"{b['owner']} (0x{b['addr']:08x}+0x{b['size']:x})"
                    )

    # A patch whose replacement equals what it expects changes nothing. That is always
    # either a copy-paste slip or a claim left behind after the value it targeted moved,
    # and it is invisible in the build log among dozens of real patches.
    # The exception is a guard (`guard = true`): bytes a mod relies on and stock already
    # holds, claimed so that another mod patching them collides here instead of silently
    # changing what the first mod relies on. A guard must say replace == expect.
    for c in [q for q in reg.get("patch", []) if active(q)]:
        if c.get("foreign"):
            # bytes another tool writes (elekloader's core sites): claimed for the overlap
            # checks only, so no replace / from_symbol; expect is still the stock bytes
            if "replace" in c or "from_symbol" in c:
                errors.append(f"patch by {c['owner']} at 0x{c['addr']:08x}: a foreign patch "
                              f"names no replace or from_symbol (another tool writes it)")
            elif expect_len(c) != c["size"]:
                errors.append(f"patch by {c['owner']} at 0x{c['addr']:08x}: expect must be "
                              f"exactly {c['size']} bytes")
            continue
        if c.get("guard"):
            if "replace" in c and not same_as_expect(c, c["replace"]):
                errors.append(
                    f"patch by {c['owner']} at 0x{c['addr']:08x}: a guard must have replace == expect")
        elif "replace" in c and same_as_expect(c, c["replace"]):
            errors.append(
                f"patch by {c['owner']} at 0x{c['addr']:08x}: replace == expect "
                f"({c['replace']}) - the claim does nothing")

    patches = [q for q in reg.get("patch", []) if active(q)]
    for q in patches:
        if q.get("foreign"):
            continue
        # a guard may leave out `replace`: it is its expect (resolve_expect fills it in)
        hashed_guard = q.get("guard") and "replace" not in q and "from_symbol" not in q
        has_replace = "replace" in q or "replace_from" in q
        if not hashed_guard and has_replace == ("from_symbol" in q):
            errors.append(
                f"patch by {q['owner']} at 0x{q['addr']:08x}: needs exactly one of "
                f"`replace` (literal bytes, or `replace_from`: stock bytes at that address) or `from_symbol` "
                f"(a label in its own stub)")
            continue
        n_want = expect_len(q)
        # from_symbol writes a 4-byte address resolved at build time, so that a stub edit
        # cannot leave a pointer aimed at where a routine used to be.
        n_repl = (len(bytes.fromhex(q["replace"])) if "replace" in q
                  else q["size"] if "replace_from" in q or hashed_guard else 4)
        if n_want != q["size"] or n_repl != q["size"]:
            errors.append(
                f"patch by {q['owner']} at 0x{q['addr']:08x}: expect/replace must both be "
                f"exactly {q['size']} bytes (got {n_want}/{n_repl})"
            )

    detours = [d for d in reg.get("detour", []) if active(d)]
    for i, a in enumerate(patches):
        for b in patches[i + 1:]:
            if exclusive(a, b):   # never in one image: they may patch the same bytes differently
                continue
            if _overlaps(a["addr"], a["size"], b["addr"], b["size"]):
                errors.append(
                    f"patch: {a['owner']} and {b['owner']} both claim 0x{a['addr']:08x}"
                )
        for b in detours:
            if exclusive(a, b):
                continue
            if _overlaps(a["addr"], a["size"], b["addr"], b["size"]):
                errors.append(
                    f"patch by {a['owner']} at 0x{a['addr']:08x} overlaps detour by "
                    f"{b['owner']} at 0x{b['addr']:08x}"
                )
    for i, a in enumerate(detours):
        for b in detours[i + 1:]:
            # Mutually exclusive mods may share a host: they are never in one image, so
            # there is nothing to chain.
            if exclusive(a, b):
                continue
            if _overlaps(a["addr"], a["size"], b["addr"], b["size"]):
                errors.append(
                    f"detour: {a['owner']} and {b['owner']} both claim 0x{a['addr']:08x}. "
                    f"Two mods on one host must chain explicitly: give them distinct "
                    f"chain_pos values and have the earlier stub jmp to the later one "
                    f"instead of back to the host."
                )
    for d in detours:
        if d["size"] != 6:
            errors.append(
                f"detour by {d['owner']} at 0x{d['addr']:08x} has size {d['size']}; "
                f"only 6 (jmp abs.l) is supported"
            )
        # expect covers the whole displaced span the stub re-emits, which may be longer
        # than the 6 bytes actually overwritten by the jmp.
        if expect_len(d) < d["size"]:
            errors.append(
                f"detour by {d['owner']} at 0x{d['addr']:08x}: expect is only "
                f"{expect_len(d)} bytes, must cover at least "
                f"the {d['size']} overwritten"
            )
        if not d.get("entry"):
            errors.append(
                f"detour by {d['owner']} at 0x{d['addr']:08x} has no entry symbol. "
                f"Name the stub label it jumps to, so the target is resolved from the "
                f"linked ELF rather than assumed to be the start of the cave block."
            )
    return errors


def load_params(root: Path) -> dict:
    """owner -> its mod.toml [params], so a standalone run gates claims the way a build does.

    Without this every gated claim looks active at once and mutually exclusive claims on
    one region read as a collision.
    """
    out = {}
    for f in sorted((root / "mods").glob("*/mod.toml")):
        with open(f, "rb") as fh:
            m = tomllib.load(fh)
        out[m["mod"]["id"]] = dict(m.get("params", {}))
    return out


if __name__ == "__main__":
    root = Path(__file__).resolve().parent.parent
    reg = load(root / "registry" / "allocations.toml")
    # the claims of mods whose folder is not in this tree (not published: 0002, 0003, 0031) are history, not checked
    mods = {f.parent.name for f in (root / "mods").glob("*/mod.toml")}
    enabled = {c["owner"] for t in reg.values() if isinstance(t, list) for c in t
               if isinstance(c, dict) and "owner" in c and c["owner"] in mods}
    problems = validate(reg, enabled, load_params(root), load_excludes(root))
    if problems:
        for p in problems:
            print("ERROR:", p)
        raise SystemExit(1)
    print("layout ok")
