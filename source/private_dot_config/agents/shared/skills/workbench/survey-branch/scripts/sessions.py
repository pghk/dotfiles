#!/usr/bin/env python3
"""Read the local Copilot session store for a branch survey.

Subcommands:

  list <branch> <since-iso> [--cwd DIR] [--db PATH]
      Candidate sessions that may have produced the branch's commits:
      sessions on <branch> or started in <cwd>, whose last turn is at
      or after <since-iso>. Tab-separated: id, first turn, last turn,
      turn count, summary.

  transcript <session-id> --paths FILE [--db PATH]
      The bounded transcript a digester may read: checkpoint
      summaries; every user message; the assistant response only for
      turns that first touched a path listed in FILE (one
      repository-relative path per line) and for the final turn. Each
      turn names the surviving paths it touched, so a statement can be
      tied to the change it informed.

The store records only the first touch of each file per session, so a
turn's path list is "files this session first edited here".
"""

import argparse
import os
import sqlite3
import sys

DEFAULT_DB = os.path.expanduser("~/.copilot/session-store.db")


def connect(path):
    if not os.path.exists(path):
        sys.exit(f"Session store not found at {path}. Try: --db <path>")
    return sqlite3.connect(f"file:{path}?mode=ro", uri=True)


def cmd_list(args):
    db = connect(args.db)
    rows = db.execute(
        """
        SELECT s.id, MIN(t.timestamp), MAX(t.timestamp), COUNT(t.id), COALESCE(s.summary, '')
        FROM sessions s JOIN turns t ON t.session_id = s.id
        WHERE (s.branch = ? OR s.cwd = ?)
        GROUP BY s.id
        HAVING MAX(t.timestamp) >= ?
        ORDER BY MIN(t.timestamp)
        """,
        (args.branch, args.cwd or "", args.since),
    ).fetchall()
    for row in rows:
        print("\t".join(str(c) for c in row))


def surviving(paths_file):
    with open(paths_file) as f:
        return [line.strip() for line in f if line.strip()]


def touched(db, session_id, paths):
    """Map turn_index -> surviving repo-relative paths first touched in that turn."""
    by_turn = {}
    for file_path, turn_index in db.execute(
        "SELECT file_path, turn_index FROM session_files WHERE session_id = ?",
        (session_id,),
    ):
        for rel in paths:
            if file_path == rel or file_path.endswith("/" + rel):
                by_turn.setdefault(turn_index, []).append(rel)
    return by_turn


def cmd_transcript(args):
    db = connect(args.db)
    session = db.execute(
        "SELECT branch, cwd, summary FROM sessions WHERE id = ?", (args.session_id,)
    ).fetchone()
    if session is None:
        sys.exit(f"No session {args.session_id}. Try: sessions.py list <branch> <since>")
    branch, cwd, summary = session
    print(f"# Session {args.session_id}\nbranch: {branch}\ncwd: {cwd}\nsummary: {summary}\n")

    for number, title, overview, work_done in db.execute(
        "SELECT checkpoint_number, title, overview, work_done FROM checkpoints "
        "WHERE session_id = ? ORDER BY checkpoint_number",
        (args.session_id,),
    ):
        print(f"## Checkpoint {number}: {title}\n{overview or ''}\n{work_done or ''}\n")

    by_turn = touched(db, args.session_id, surviving(args.paths))
    turns = db.execute(
        "SELECT turn_index, timestamp, user_message, assistant_response FROM turns "
        "WHERE session_id = ? ORDER BY turn_index",
        (args.session_id,),
    ).fetchall()
    last_index = turns[-1][0] if turns else None

    for turn_index, timestamp, user_message, assistant_response in turns:
        paths = by_turn.get(turn_index, [])
        print(f"## Turn {turn_index} ({timestamp})")
        if paths:
            print("touched: " + ", ".join(paths))
        print(f"\n### User\n{user_message or ''}\n")
        if paths or turn_index == last_index:
            print(f"### Assistant\n{assistant_response or ''}\n")
        else:
            print("### Assistant\n(omitted: no surviving path touched)\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--db", default=DEFAULT_DB)
    sub = parser.add_subparsers(dest="command", required=True)

    p_list = sub.add_parser("list")
    p_list.add_argument("branch")
    p_list.add_argument("since", help="ISO timestamp; sessions ending before it are excluded")
    p_list.add_argument("--cwd", help="worktree path, to include sessions recorded without the branch")
    p_list.set_defaults(func=cmd_list)

    p_tr = sub.add_parser("transcript")
    p_tr.add_argument("session_id")
    p_tr.add_argument("--paths", required=True, help="file of repo-relative paths surviving at <orig>")
    p_tr.set_defaults(func=cmd_transcript)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
