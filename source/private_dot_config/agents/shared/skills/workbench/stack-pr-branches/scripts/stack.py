#!/usr/bin/env python3
"""Create stacked PR branches from a clean branch without touching the checkout.

Usage: stack.py MANIFEST.json [--repo DIR] [--dry-run]

Manifest:
  {
    "ticket": "RAV-16860",
    "base": "fb79ae0d",
    "source": "RAV-16860/dev-clean",
    "step": 10,
    "parts": [
      {"slug": "heading-roles", "commits": [
        {"source": "d243fd6247", "subject": "Style Alpha headings by role"}
      ]}
    ]
  }

Part N is named <ticket>/<N*step zero-padded to 3>-<slug>, based on part N-1
(the first on "base"). Each commit keeps its source tree and author; its
subject becomes "<ticket> <subject>" ("subject" is optional: the source
subject minus a leading gitmoji or other non-word prefix) and the message is
wrapped by the commit skill's wrap-commit-message.py. All refs are created in
one transaction. The last tree must equal the source tip's tree. Writes the
resulting mapping to stdout as JSON.
"""
import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

WRAPPER = Path(__file__).resolve().parents[3] / "writing/commit/wrap-commit-message.py"


def fail(message):
    sys.exit(f"stack.py: {message}")


def main():
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("manifest")
    parser.add_argument("--repo", default=".")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    manifest = json.loads(Path(args.manifest).read_text())
    ticket, step = manifest["ticket"], manifest.get("step", 10)

    def git(*cmd, text=None, env=None):
        done = subprocess.run(
            ["git", *cmd], cwd=args.repo, input=text, text=True,
            capture_output=True, env=env,
        )
        if done.returncode:
            fail(f"git {' '.join(cmd)}: {done.stderr.strip()}")
        return done.stdout.strip()

    def rev(name):
        return git("rev-parse", name)

    base, source_tip = rev(manifest["base"]), rev(manifest["source"])
    expected = git("rev-list", "--reverse", f"{base}..{source_tip}").splitlines()
    listed = [rev(c["source"]) for p in manifest["parts"] for c in p["commits"]]
    if expected != listed:
        fail("manifest commits differ from base..source; "
             f"missing {sorted(set(expected) - set(listed))}, "
             f"extra {sorted(set(listed) - set(expected))}, or order differs")

    names = [f"{ticket}/{(i + 1) * step:03d}-{p['slug']}"
             for i, p in enumerate(manifest["parts"])]
    for name in names:
        if git("branch", "--list", name):
            fail(f"branch exists: {name}")

    parent, tips, commits = base, {}, []
    for name, part in zip(names, manifest["parts"]):
        for entry in part["commits"]:
            source = rev(entry["source"])
            original = git("show", "-s", "--format=%B", source)
            head, sep, body = original.partition("\n\n")
            subject = entry.get("subject") or re.sub(r"^\W+", "", head.splitlines()[0])
            draft = f"{ticket} {subject}" + ("\n\n" + body if sep else "\n")
            message = subprocess.run(
                [sys.executable, str(WRAPPER)], input=draft, text=True,
                capture_output=True,
            ).stdout
            if not message:
                fail(f"could not wrap message for {source}")
            author = git("show", "-s", "--format=%an%n%ae%n%aI", source).splitlines()
            env = {**os.environ, "GIT_AUTHOR_NAME": author[0],
                   "GIT_AUTHOR_EMAIL": author[1], "GIT_AUTHOR_DATE": author[2]}
            tree = rev(f"{source}^{{tree}}")
            parent = git("commit-tree", tree, "-p", parent, text=message, env=env)
            subject_line = message.splitlines()[0]
            if len(subject_line) > 50:
                print(f"stack.py: subject is {len(subject_line)} characters "
                      f"(over 50): {subject_line}", file=sys.stderr)
            commits.append({"source": source, "rewritten": parent, "branch": name,
                            "subject": subject_line, "tree": tree})
        tips[name] = parent

    if rev(f"{parent}^{{tree}}") != rev(f"{source_tip}^{{tree}}"):
        fail("final tree differs from the source tip's tree")

    if not args.dry_run:
        lines = ["start", *(f"create refs/heads/{n} {t}" for n, t in tips.items()),
                 "prepare", "commit"]
        git("update-ref", "--stdin", text="\n".join(lines) + "\n")
    print(json.dumps({"base": base, "source_tip": source_tip, "tips": tips,
                      "commits": commits, "created": not args.dry_run}, indent=2))


main()
