#!/usr/bin/env python3
"""Collect daily work evidence and current publication status without network access."""

import argparse
from contextlib import closing
from datetime import date, datetime, time, timedelta
import json
import os
from pathlib import Path
import re
import sqlite3
import subprocess

REQUEST_CHARS = 200
REPLY_CHARS = 600


def run(*arguments):
    return subprocess.run(
        arguments, check=True, capture_output=True, text=True,
        env={**os.environ, "GIT_OPTIONAL_LOCKS": "0"},
    ).stdout


def git(root, *arguments):
    return run("git", "-C", str(root), "--no-pager", *arguments)


def atuin_activity(day):
    records = []
    offset = 0
    while True:
        output = run(
            "atuin", "search", "--after", f"{day - timedelta(days=1)} 23:59:59",
            "--before", f"{day + timedelta(days=1)} 00:00:00",
            "--timezone", "local", "--filter-mode", "host", "--include-duplicates",
            "--format", "{time}\t{directory}", "--print0",
            "--limit", "1000", "--offset", str(offset),
        )
        page = [record for record in output.split("\0") if record]
        for record in page:
            timestamp, path = record.split("\t", 1)
            if datetime.fromisoformat(timestamp).date() == day:
                records.append({"time": timestamp, "path": path})
        if len(page) < 1000:
            return sorted(records, key=lambda record: record["time"])
        offset += len(page)


def session_activity(database, day, excluded):
    sessions = {}
    with closing(sqlite3.connect(database.resolve().as_uri() + "?mode=ro", uri=True)) as db:
        rows = db.execute(
            """
            SELECT s.id, s.cwd, s.repository, s.branch, s.summary,
                   datetime(t.timestamp, 'localtime'), t.user_message, t.assistant_response
            FROM turns t JOIN sessions s ON s.id = t.session_id
            WHERE date(t.timestamp, 'localtime') = ? AND s.id != ?
            ORDER BY julianday(t.timestamp)
            """,
            (day.isoformat(), excluded),
        )
        for identifier, cwd, repository, branch, summary, timestamp, request, reply in rows:
            session = sessions.setdefault(identifier, {
                "id": identifier, "cwd": cwd, "repository": repository,
                "branch": branch, "summary": summary, "turns": 0,
                "first": timestamp, "last": timestamp, "interaction_windows": set(),
                "requests": [], "last_reply": None,
            })
            session["turns"] += 1
            session["last"] = timestamp
            session["requests"].append((request or "")[:REQUEST_CHARS])
            if reply:
                session["last_reply"] = reply[:REPLY_CHARS]
            moment = datetime.fromisoformat(timestamp)
            session["interaction_windows"].add(
                moment.replace(minute=moment.minute // 30 * 30, second=0, microsecond=0).isoformat()
            )
    for session in sessions.values():
        session["interaction_windows"] = sorted(session["interaction_windows"])
    return list(sessions.values())


def repository_for(path):
    directory = Path(path).expanduser().resolve()
    if directory.is_file():
        directory = directory.parent
    try:
        root = git(directory, "rev-parse", "--show-toplevel").strip()
    except subprocess.CalledProcessError:
        try:
            source = run("chezmoi", "source-path", str(directory)).strip()
            root = git(source, "rev-parse", "--show-toplevel").strip()
        except (OSError, subprocess.CalledProcessError):
            return None
    common = git(root, "rev-parse", "--path-format=absolute", "--git-common-dir").strip()
    return root, common


def issue_keys(text):
    return sorted(set(re.findall(r"(?<![A-Z0-9])[A-Z][A-Z0-9]+-\d+\b", text)))


def reflog_activity(root, start, end, reference=None):
    arguments = [reference] if reference else ["--all"]
    output = git(
        root, "reflog", "show", *arguments, "--date=iso-strict",
        f"--since={start.isoformat()}", f"--until={end.isoformat()}",
        "--format=%H%x00%gD%x00%gs",
    )
    events = []
    for line in output.splitlines():
        commit, selector, action = line.split("\0")
        ref, _, timestamp = selector.rpartition("@{")
        moment = datetime.fromisoformat(timestamp.removesuffix("}"))
        if start <= moment < end:
            kind = "remote" if ref.startswith("refs/remotes/") else "local"
            events.append({
                "commit": commit, "ref": ref, "time": moment.isoformat(),
                "action": action, "kind": kind,
                "issue_keys": issue_keys(ref + " " + action) if kind == "local" else [],
            })
    return events


def publication_status(root):
    output = git(root, "for-each-ref", "--format=%(refname)%00%(upstream)", "refs/heads")
    branches = []
    for line in output.splitlines():
        ref, upstream = line.split("\0")
        if ref.startswith("refs/heads/trash/"):
            continue
        unpublished = int(git(root, "rev-list", "--count", ref, "--not", "--remotes"))
        branch = {
            "branch": ref.removeprefix("refs/heads/"), "upstream": upstream or None,
            "issue_keys": issue_keys(ref), "unpublished_commits": unpublished,
        }
        if not upstream:
            branch["tracking"] = "none"
        else:
            try:
                behind, ahead = git(
                    root, "rev-list", "--left-right", "--count", f"{upstream}...{ref}",
                ).split()
                branch.update(
                    tracking="remote" if upstream.startswith("refs/remotes/") else "local",
                    ahead=int(ahead), behind=int(behind),
                )
            except subprocess.CalledProcessError:
                branch["tracking"] = "missing"
        branches.append(branch)
    return branches


def publication_report(branches, events, session_branches):
    active = set(session_branches)
    for event in events:
        if event["kind"] != "local":
            continue
        if event["ref"].startswith("refs/heads/"):
            active.add(event["ref"].removeprefix("refs/heads/"))
        checkout = re.fullmatch(r"checkout: moving from (\S+) to (\S+)", event["action"])
        if checkout:
            active.update(checkout.groups())
    active = {branch for branch in active if not branch.startswith("trash/")}
    concerns = set(issue_keys(" ".join(active)))
    relevant = []
    historical = {
        "checked_branches": 0, "unpublished_branches": 0,
        "ahead_of_remote_upstream": 0, "missing_upstreams": 0,
    }
    for branch in branches:
        if branch["branch"] in active or concerns.intersection(branch["issue_keys"]):
            relevant.append(branch)
        else:
            historical["checked_branches"] += 1
            historical["unpublished_branches"] += branch["unpublished_commits"] > 0
            historical["ahead_of_remote_upstream"] += (
                branch["tracking"] == "remote" and branch["ahead"] > 0
            )
            historical["missing_upstreams"] += branch["tracking"] == "missing"
    return {"day_relevant": relevant, "historical": historical}


def own_email(root):
    ident = git(root, "var", "GIT_AUTHOR_IDENT")
    return re.search(r"<([^>]*)>", ident).group(1)


def repository_evidence(root, start, end, session_branches=()):
    worktrees = [
        field.removeprefix("worktree ")
        for field in git(root, "worktree", "list", "--porcelain", "-z").split("\0")
        if field.startswith("worktree ")
    ]
    events = reflog_activity(root, start, end)
    for worktree in worktrees:
        if worktree != root and Path(worktree).is_dir():
            for event in reflog_activity(worktree, start, end, "HEAD"):
                events.append({**event, "worktree": worktree})
    commits = []
    email = own_email(root)
    output = git(
        root, "log", "--all", "--reflog",
        f"--since-as-filter={start.isoformat()}", f"--until={end.isoformat()}",
        "--format=%H%x00%aI%x00%cI%x00%an%x00%ae%x00%s",
    )
    for line in output.splitlines():
        commit, authored, committed, author, author_email, subject = line.split("\0")
        if start <= datetime.fromisoformat(committed) < end:
            commits.append({
                "commit": commit, "authored": authored, "committed": committed,
                "author": author, "own": author_email == email, "subject": subject, "issue_keys": issue_keys(subject),
            })
    branches = publication_status(root)
    return {
        "root": root, "worktrees": worktrees, "commits": commits, "reflog": events,
        "issue_keys": sorted({
            key for event in events if event["kind"] == "local"
            for key in event["issue_keys"]
        }),
        "publication": branches,
        "publication_report": publication_report(branches, events, session_branches),
    }


def collect(day, database, paths, excluded):
    start = datetime.combine(day, time.min).astimezone()
    end = datetime.combine(day + timedelta(days=1), time.min).astimezone()
    evidence = {
        "date": day.isoformat(), "start": start.isoformat(), "end": end.isoformat(),
        "collected_at": datetime.now().astimezone().isoformat(), "warnings": [],
    }
    for name, gather in (
        ("shell", lambda: atuin_activity(day)),
        ("sessions", lambda: session_activity(database, day, excluded)),
    ):
        try:
            evidence[name] = gather()
        except (OSError, subprocess.CalledProcessError, sqlite3.Error, ValueError) as error:
            evidence[name] = []
            evidence["warnings"].append(f"{name}: {error}")
    if day == date.today():
        try:
            evidence["jira"] = run("jira", "activity")
        except (OSError, subprocess.CalledProcessError) as error:
            evidence["jira"] = None
            evidence["warnings"].append(f"jira: {error}")
    else:
        evidence["jira"] = None
    paths = sorted(set(
        paths + [record["path"] for record in evidence["shell"]]
        + [session["cwd"] for session in evidence["sessions"] if session["cwd"]]
    ))
    repositories = {}
    evidence["unresolved_paths"] = []
    for path in paths:
        resolved = repository_for(path)
        if resolved is None:
            evidence["unresolved_paths"].append(path)
            continue
        root, common = resolved
        repository = repositories.setdefault(common, {"root": root, "paths": []})
        repository["paths"].append(path)
    evidence["repositories"] = []
    for repository in repositories.values():
        try:
            session_branches = [
                session["branch"] for session in evidence["sessions"]
                if session["cwd"] in repository["paths"] and session["branch"]
            ]
            repository.update(repository_evidence(
                repository["root"], start, end, session_branches,
            ))
        except (OSError, subprocess.CalledProcessError, ValueError) as error:
            repository["error"] = str(error)
            evidence["warnings"].append(f"{repository['root']}: {error}")
        evidence["repositories"].append(repository)
    return evidence


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Gather a local day's Atuin paths, Copilot session metadata and Git activity, "
            "plus current publication status of local branches except trash/*. "
            "Read-only; no fetch/push. Write full JSON to --output; print counts and "
            "publication reports with day-relevant branches and historical totals. "
            "Exit 0 for complete collection, 1 for partial evidence, 2 for usage errors."
        ),
    )
    parser.add_argument("--date", type=date.fromisoformat, default=date.today())
    parser.add_argument("--path", action="append", default=[], help="Additional touched path; repeatable")
    parser.add_argument("--exclude-session", default="", help="Current punch-out session ID")
    parser.add_argument("--db", type=Path, default=Path.home() / ".copilot/session-store.db")
    parser.add_argument("--output", type=Path, required=True, help="Local evidence JSON file")
    arguments = parser.parse_args()
    evidence = collect(arguments.date, arguments.db, arguments.path, arguments.exclude_session)
    arguments.output.parent.mkdir(parents=True, exist_ok=True)
    arguments.output.write_text(json.dumps(evidence, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({
        "output": str(arguments.output), "shell_records": len(evidence["shell"]),
        "sessions": len(evidence["sessions"]), "repositories": len(evidence["repositories"]),
        "warnings": evidence["warnings"], "unresolved_paths": evidence["unresolved_paths"],
        "publication_reports": [
            {"root": repository["root"], **repository["publication_report"]}
            for repository in evidence["repositories"] if "publication_report" in repository
        ],
    }))
    return 1 if evidence["warnings"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
