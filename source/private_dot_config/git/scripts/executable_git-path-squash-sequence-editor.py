#!/usr/bin/env python3

import os
import re
import subprocess
import sys
from dataclasses import dataclass, field

TODO_FILE = sys.argv[1]

PATH_FILTER = os.environ.get("GPS_PATH", "").rstrip("/")
DEBUG = os.environ.get("GPS_DEBUG") == "1"

if not PATH_FILTER:
    raise RuntimeError("GPS_PATH must be set")


def debug(*args):
    if DEBUG:
        print(*args, file=sys.stderr)


PICK_RE = re.compile(
    r"^pick\s+([0-9a-fA-F]+)\s+(.*)$"
)


@dataclass
class Commit:
    sha: str
    subject: str


@dataclass
class CommitInfo:
    commit: Commit
    files: set
    key: str


@dataclass
class Group:
    key: str
    tracked_files: set
    members: list = field(default_factory=list)
    closed: bool = False


#
# Load commits from the rebase todo.
#
commits = []

with open(TODO_FILE) as f:
    for line in f:
        line = line.rstrip()

        match = PICK_RE.match(line)

        if not match:
            continue

        commits.append(
            Commit(
                sha=match.group(1),
                subject=match.group(2),
            )
        )


def changed_files(commit_sha):
    result = subprocess.run(
        [
            "git",
            "diff-tree",
            "--no-commit-id",
            "--name-only",
            "-r",
            commit_sha,
        ],
        check=True,
        capture_output=True,
        text=True,
    )

    return {
        line.strip()
        for line in result.stdout.splitlines()
        if line.strip()
    }


def commit_only_within_path(files, path):
    if not files:
        return False

    for file in files:
        if file == path:
            continue

        if file.startswith(path + "/"):
            continue

        return False

    return True


infos = []

for commit in commits:
    files = changed_files(commit.sha)

    if commit_only_within_path(files, PATH_FILTER):
        key = PATH_FILTER
    else:
        key = None

    infos.append(
        CommitInfo(
            commit=commit,
            files=files,
            key=key,
        )
    )


groups = []
active_groups = []


for index, info in enumerate(infos):

    #
    # A commit that touches the path but also changes files
    # outside it closes the open group.
    #
    for group in active_groups[:]:
        if info.key is None:
            touches_path = any(
                f == PATH_FILTER
                or f.startswith(PATH_FILTER + "/")
                for f in info.files
            )

            if touches_path:
                group.closed = True
                active_groups.remove(group)

                debug(
                    "CLOSE PATH GROUP due to",
                    info.commit.sha,
                )

    #
    # Not eligible.
    #
    if info.key is None:
        continue

    group = None

    for candidate in active_groups:
        if candidate.key == info.key:
            group = candidate
            break

    if group:
        group.members.append(index)

        debug(
            "ADD",
            info.commit.sha,
            "to",
            group.key,
        )

        continue

    group = Group(
        key=info.key,
        tracked_files=set(info.files),
        members=[index],
    )

    groups.append(group)
    active_groups.append(group)

    debug(
        "OPEN",
        group.key,
        "at",
        info.commit.sha,
    )


anchor_map = {}
skip_indexes = set()

for group in groups:
    if len(group.members) < 2:
        continue

    anchor_map[group.members[0]] = group

    for member in group.members[1:]:
        skip_indexes.add(member)


if DEBUG:
    debug("")
    debug("=== GROUPS ===")

    for group in groups:
        if len(group.members) < 2:
            continue

        debug("")
        debug("key:", group.key)

        for member in group.members:
            commit = infos[member].commit

            debug(
                " ",
                commit.sha[:10],
                commit.subject,
            )


output = []

for index, info in enumerate(infos):

    if index in anchor_map:
        group = anchor_map[index]

        for position, member in enumerate(group.members):
            commit = infos[member].commit

            action = (
                "pick"
                if position == 0
                else "squash"
            )

            output.append(
                f"{action} {commit.sha} {commit.subject}"
            )

        continue

    if index in skip_indexes:
        continue

    commit = info.commit

    output.append(
        f"pick {commit.sha} {commit.subject}"
    )

with open(TODO_FILE, "w") as f:
    for line in output:
        f.write(line)
        f.write("\n")
