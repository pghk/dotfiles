#!/usr/bin/env python3
"""Assign the net change of a branch to concerns and build it as commits.

Hunks are those of `git diff --no-renames <base> <orig>`, numbered per path
from 1. Ids are stable for a given base and orig: `path` names the whole file,
`path#2` or `path#1,3` names hunks of it. A rename is a deleted path and an
added path; binary, added, deleted, and mode-only changes are whole files.

base and orig come from the map's front matter. The map assigns ids under
`## Concerns`, in each `### <n>. <name>` entry's indented `- members:` list,
and under `## Dropped`, one `- <id> — <reason>` per line. A concern with
`- disposition: split:<branch>` is assigned but never built. A concern's
commit message is the indented block under `- message: |`.

Subcommands:

  list <base> <orig> [--hunks [PATH ...]]
      Without --hunks: one line per changed path:
        path  status  hunk-count  +added -removed
      With --hunks: one line per hunk of the named paths (all if none):
        path#n  +added -removed  @@ header  |  first changed line

  check MAP
      Every hunk assigned exactly once and every id known. Prints one
      problem per line (kind, id, owners) and exits 1 when any exist.

  stage MAP N
      Sets index and working tree for every changed path to base plus the
      hunks of built concerns 1..N. Absolute, so it can be rerun.

  build MAP [--dry-run]
      From a clean checkout of base, stages and commits each built concern
      in map order with its message.

  verify MAP [--rev REV]
      Compares REV (default HEAD) with base plus every built concern.
      Prints each differing path and exits 1 when any differ.

Exit codes: 0 ok, 1 problems found, 2 usage or git error.
"""
import argparse
import os
import re
import subprocess
import sys

HUNK_RE = re.compile(r"^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@")
ENTRY_RE = re.compile(r"^###\s+(\d+)\.\s*(.*)$")


def die(message):
    sys.stderr.write(message.rstrip() + "\n")
    sys.exit(2)


def git(*args, input=None, env=None, check=True):
    r = subprocess.run(["git", *args], input=input, stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE, env=env)
    if check and r.returncode != 0:
        die("git {} failed:\n{}".format(" ".join(args), r.stderr.decode(errors="replace")))
    return r.stdout


class Change:
    def __init__(self, path, status, binary):
        self.path = path
        self.status = status
        self.binary = binary
        self.hunks = []

    @property
    def splittable(self):
        return self.status == "M" and not self.binary and len(self.hunks) > 1


class Hunk:
    def __init__(self, header, old_start, old_len):
        self.header = header
        self.old_start = old_start
        self.old_len = old_len
        self.new_lines = []
        self.added = 0
        self.removed = 0
        self.first = None


def parse_hunks(diff):
    hunks, last = [], None
    for raw in diff.splitlines(keepends=True):
        if raw.startswith(b"@@"):
            m = HUNK_RE.match(raw.decode(errors="replace"))
            old_len = int(m.group(2)) if m.group(2) is not None else 1
            hunks.append(Hunk(raw.decode(errors="replace").rstrip("\n"), int(m.group(1)), old_len))
            last = None
            continue
        if not hunks:
            continue
        hunk, op, text = hunks[-1], raw[:1], raw[1:]
        if op == b"\\":
            # The previous line has no trailing newline on the side(s) it belongs to.
            if last in (b" ", b"+"):
                hunk.new_lines[-1] = hunk.new_lines[-1].rstrip(b"\n")
            continue
        if op in (b" ", b"+"):
            hunk.new_lines.append(text)
        if op in (b"+", b"-"):
            hunk.added += op == b"+"
            hunk.removed += op == b"-"
            if hunk.first is None or (op == b"+" and hunk.first[0] == "-"):
                hunk.first = op.decode() + text.decode(errors="replace").rstrip("\n")
        last = op
    return hunks


def changes(base, orig):
    out = {}
    fields = git("diff", "--no-renames", "--name-status", "-z", base, orig).split(b"\0")
    for status, path in zip(fields[0::2], fields[1::2]):
        if path:
            out[path.decode()] = Change(path.decode(), status.decode()[:1], False)
    numstat = git("diff", "--no-renames", "--numstat", "-z", base, orig).split(b"\0")
    for entry in numstat:
        parts = entry.split(b"\t", 2)
        if len(parts) == 3 and parts[2].decode() in out and parts[0] == b"-":
            out[parts[2].decode()].binary = True
    for change in out.values():
        if not change.binary:
            diff = git("diff", "--no-renames", "--no-ext-diff", base, orig, "--", change.path)
            change.hunks = parse_hunks(diff)
    return out


def read_map(path):
    try:
        with open(path) as f:
            lines = f.read().splitlines()
    except OSError as e:
        die("Cannot read map {}: {}".format(path, e))
    front = {}
    if lines and lines[0].strip() == "---":
        for i, line in enumerate(lines[1:], 1):
            if line.strip() == "---":
                lines = lines[i + 1:]
                break
            key, _, value = line.partition(":")
            front[key.strip()] = value.strip()
    for key in ("base", "orig"):
        if not front.get(key) or front[key].startswith("<"):
            die("Map front matter needs `{}: <sha>`; got {!r}.".format(key, front.get(key)))

    concerns, dropped, section, entry, field = [], [], None, None, None
    for line in lines:
        if line.startswith("## "):
            section, entry, field = line[3:].strip().lower(), None, None
            continue
        if section == "dropped" and line.startswith("- "):
            dropped.append(member_id(line[2:]))
            continue
        if section != "concerns":
            continue
        m = ENTRY_RE.match(line)
        if m:
            entry = {"n": int(m.group(1)), "name": m.group(2).strip(), "members": [],
                     "split": False, "message": []}
            concerns.append(entry)
            field = None
            continue
        if entry is None:
            continue
        top = re.match(r"^- ([^:]+):\s*(.*)$", line)
        if top:
            field, value = top.group(1), top.group(2).strip()
            if field == "disposition":
                entry["split"] = value.startswith("split")
            continue
        if field == "members" and re.match(r"^\s+- ", line):
            entry["members"].append(member_id(line.strip()[2:]))
        elif field == "message":
            entry["message"].append(line)
    for entry in concerns:
        entry["message"] = dedent(entry["message"])
    return front, concerns, dropped


def member_id(text):
    return text.split(" — ")[0].strip().strip("`").strip()


def dedent(lines):
    while lines and not lines[-1].strip():
        lines.pop()
    indents = [len(l) - len(l.lstrip()) for l in lines if l.strip()]
    cut = min(indents) if indents else 0
    return "\n".join(l[cut:] for l in lines) + "\n" if lines else ""


def parse_id(text):
    path, _, numbers = text.partition("#")
    if not numbers:
        return path, None
    try:
        return path, {int(n) for n in numbers.split(",") if n.strip()}
    except ValueError:
        return path, "bad"


def assignments(concerns, dropped, known):
    """Map each change to {hunk_number_or_None: [owners]} and collect problems."""
    owners, problems = {}, []
    labelled = [(str(e["n"]), m) for e in concerns for m in e["members"]]
    labelled += [("dropped", m) for m in dropped]
    for owner, text in labelled:
        path, numbers = parse_id(text)
        change = known.get(path)
        if change is None:
            problems.append(("unknown", text, owner))
            continue
        if numbers == "bad" or (numbers and any(n < 1 or n > len(change.hunks) for n in numbers)):
            problems.append(("unknown", text, owner))
            continue
        if numbers and not change.splittable:
            problems.append(("whole-file-only", text, owner))
            continue
        slots = owners.setdefault(path, {})
        for n in numbers or [None]:
            slots.setdefault(n, []).append(owner)
    for path, change in sorted(known.items()):
        slots = owners.get(path, {})
        if None in slots and len(slots) > 1:
            problems.append(("multiple", path, ",".join(sorted({o for v in slots.values() for o in v}))))
            continue
        if None in slots:
            if len(slots[None]) > 1:
                problems.append(("multiple", path, ",".join(slots[None])))
            continue
        for n in range(1, len(change.hunks) + 1) if slots else [None]:
            label = path if n is None else "{}#{}".format(path, n)
            assigned = slots.get(n, [])
            if not assigned:
                problems.append(("unassigned", label, ""))
            elif len(assigned) > 1:
                problems.append(("multiple", label, ",".join(assigned)))
    return owners, problems


def load(map_path):
    front, concerns, dropped = read_map(map_path)
    known = changes(front["base"], front["orig"])
    owners, problems = assignments(concerns, dropped, known)
    return front, concerns, known, owners, problems


def require_clean(map_path):
    _, concerns, known, owners, problems = load(map_path)
    if problems:
        die("Map has unassigned or conflicting ids; run: hunks.py check {}".format(map_path))
    return concerns, known, owners


def expected(front, change, slots, built):
    """(mode, bytes) of the path after `built` concern numbers, or None if absent."""
    base, orig = front["base"], front["orig"]
    whole = slots.get(None)
    if whole is not None or not change.splittable:
        owner = (whole or [None])[0]
        source = orig if owner in built else base
        return blob(source, change.path)
    chosen = sorted(n for n, o in slots.items() if o[0] in built)
    if len(chosen) == len(change.hunks):
        return blob(orig, change.path)
    mode, content = blob(base, change.path)
    lines = content.splitlines(keepends=True)
    for n in reversed(chosen):
        hunk = change.hunks[n - 1]
        start = hunk.old_start if hunk.old_len == 0 else hunk.old_start - 1
        lines[start:start + hunk.old_len] = hunk.new_lines
    return mode, b"".join(lines)


def blob(rev, path):
    entry = git("ls-tree", "-z", rev, "--", path).rstrip(b"\0")
    if not entry:
        return None
    mode = entry.split(b" ", 1)[0].decode()
    return mode, git("cat-file", "blob", "{}:{}".format(rev, path))


def built_numbers(concerns, upto=None):
    return {str(e["n"]) for e in concerns if not e["split"] and (upto is None or e["n"] <= upto)}


def write_state(front, known, owners, built):
    root = git("rev-parse", "--show-toplevel").decode().strip()
    for path, change in known.items():
        state = expected(front, change, owners.get(path, {}), built)
        target = os.path.join(root, path)
        if state is None:
            git("rm", "-q", "--cached", "--ignore-unmatch", "--", path)
            if os.path.lexists(target):
                os.remove(target)
            continue
        mode, content = state
        os.makedirs(os.path.dirname(target) or ".", exist_ok=True)
        if os.path.lexists(target):
            os.remove(target)
        if mode == "120000":
            os.symlink(content.decode(), target)
        else:
            with open(target, "wb") as f:
                f.write(content)
            os.chmod(target, 0o755 if mode == "100755" else 0o644)
        git("add", "--", path)


def cmd_list(args):
    known = changes(args.base, args.orig)
    if args.hunks is None:
        for change in sorted(known.values(), key=lambda c: c.path):
            added = sum(h.added for h in change.hunks)
            removed = sum(h.removed for h in change.hunks)
            count = "binary" if change.binary else len(change.hunks)
            print("{}\t{}\t{}\t+{} -{}".format(change.path, change.status, count, added, removed))
        return 0
    paths = args.hunks or sorted(known)
    for path in paths:
        if path not in known:
            die("{} is not changed between {} and {}. Try: hunks.py list {} {}".format(
                path, args.base, args.orig, args.base, args.orig))
        for n, hunk in enumerate(known[path].hunks, 1):
            print("{}#{}\t+{} -{}\t{}\t|  {}".format(
                path, n, hunk.added, hunk.removed, hunk.header[:60], (hunk.first or "")[:80]))
    return 0


def cmd_check(args):
    _, _, _, _, problems = load(args.map)
    for kind, label, owner in problems:
        print("{}\t{}\t{}".format(kind, label, owner))
    return 1 if problems else 0


def cmd_stage(args):
    front = read_map(args.map)[0]
    concerns, known, owners = require_clean(args.map)
    write_state(front, known, owners, built_numbers(concerns, args.n))
    return 0


def cmd_build(args):
    front = read_map(args.map)[0]
    concerns, known, owners = require_clean(args.map)
    plan = [e for e in concerns if not e["split"]]
    for e in plan:
        if not e["message"].strip():
            die("Concern {} has no `- message: |` block.".format(e["n"]))
    if args.dry_run:
        for e in plan:
            print("{}\t{}".format(e["n"], e["message"].splitlines()[0]))
        return 0
    head = git("rev-parse", "HEAD").strip()
    base = git("rev-parse", front["base"] + "^{commit}").strip()
    if head != base or git("status", "--porcelain"):
        die("build needs a clean checkout of base {}. Try: git switch -c <clean_branch> {}".format(
            front["base"], front["base"]))
    for e in plan:
        write_state(front, known, owners, built_numbers(concerns, e["n"]))
        if not git("diff", "--cached", "--name-only"):
            die("Concern {} stages nothing; its members are already at orig or empty.".format(e["n"]))
        git("commit", "-q", "-F", "-", input=e["message"].encode())
        print("{}\t{}".format(git("rev-parse", "--short", "HEAD").decode().strip(), e["message"].splitlines()[0]))
    return 0


def cmd_verify(args):
    front = read_map(args.map)[0]
    concerns, known, owners = require_clean(args.map)
    built = built_numbers(concerns)
    differing = []
    for path, change in sorted(known.items()):
        if expected(front, change, owners.get(path, {}), built) != blob(args.rev, path):
            differing.append(path)
    others = git("diff", "--no-renames", "--name-only", "-z", front["orig"], args.rev).split(b"\0")
    differing += sorted(p.decode() for p in others if p and p.decode() not in known)
    for path in differing:
        print(path)
    return 1 if differing else 0


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("list")
    p.add_argument("base")
    p.add_argument("orig")
    p.add_argument("--hunks", nargs="*", metavar="PATH")
    p.set_defaults(func=cmd_list)

    p = sub.add_parser("check")
    p.add_argument("map")
    p.set_defaults(func=cmd_check)

    p = sub.add_parser("stage")
    p.add_argument("map")
    p.add_argument("n", type=int)
    p.set_defaults(func=cmd_stage)

    p = sub.add_parser("build")
    p.add_argument("map")
    p.add_argument("--dry-run", action="store_true")
    p.set_defaults(func=cmd_build)

    p = sub.add_parser("verify")
    p.add_argument("map")
    p.add_argument("--rev", default="HEAD")
    p.set_defaults(func=cmd_verify)

    args = parser.parse_args()
    sys.exit(args.func(args))


if __name__ == "__main__":
    main()
