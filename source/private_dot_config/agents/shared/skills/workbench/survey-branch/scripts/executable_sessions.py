#!/usr/bin/env python3
"""Read the local Copilot session store for a branch survey.

Subcommands:

  list <branch> <since-iso> [--cwd DIR] [--db PATH]
      Candidate sessions that may have produced the branch's commits:
      sessions on <branch> or started in <cwd>, whose last turn is at
      or after <since-iso>. Tab-separated: id, first turn, last turn,
      turn count, transcript size in bytes, summary.

  transcript <session-id> [--paths FILE] [--turns A-B] [--db PATH]
      The full conversation: checkpoint summaries, the session's
      artifact files, and every turn. A turn that first edited a path
      listed in FILE (one repository-relative path per line) is
      annotated with those paths, so a statement can be tied to the
      change it informed. The store records only the first touch of
      each file per session, so later edits carry no annotation.
      --turns A-B prints only those turns, without checkpoints or files.

  search <fts-query> [--sessions ID ...] [--limit N] [--db PATH]
      Full-text search over turns, checkpoints, and session artifacts,
      best match first. Tab-separated: session id, source, turn
      timestamp (turns only), snippet with matches in [brackets]. Read
      around a hit with `transcript <id> --turns A-B`.

  events <regex> [--sessions ID ...] [--since ISO] [--until ISO] [--agents]
      Case-insensitive search of each session's events.jsonl, which
      holds every message: the store's turns can stop at a session's
      first summary and omit subagent work. Tab-separated: session id,
      timestamp, role (user, assistant, reasoning), agent id or "-",
      excerpt around the first match. Session IDs may be prefixes.
      --agents includes subagent messages. Pass '.' with a session and
      a time window to read a stretch of conversation.
"""

import argparse
import glob
import json
import os
import re
import sqlite3
import sys

DEFAULT_DB = os.path.expanduser("~/.copilot/session-store.db")
SESSION_STATE = os.path.expanduser("~/.copilot/session-state")


def connect(path):
    if not os.path.exists(path):
        sys.exit(f"Session store not found at {path}. Try: --db <path>")
    return sqlite3.connect(f"file:{path}?mode=ro", uri=True)


def cmd_list(args):
    db = connect(args.db)
    rows = db.execute(
        """
        SELECT s.id, MIN(t.timestamp), MAX(t.timestamp), COUNT(t.id),
               SUM(COALESCE(LENGTH(t.user_message), 0) + COALESCE(LENGTH(t.assistant_response), 0)),
               COALESCE(s.summary, '')
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

    for number, title, overview, work_done in [] if args.turns else db.execute(
        "SELECT checkpoint_number, title, overview, work_done FROM checkpoints "
        "WHERE session_id = ? ORDER BY checkpoint_number",
        (args.session_id,),
    ):
        print(f"## Checkpoint {number}: {title}\n{overview or ''}\n{work_done or ''}\n")

    first, last = args.turns or (None, None)
    files_dir = os.path.join(SESSION_STATE, args.session_id, "files")
    if args.turns is None and os.path.isdir(files_dir) and os.listdir(files_dir):
        print("## Files\n" + "\n".join(
            os.path.join(files_dir, name) for name in sorted(os.listdir(files_dir))) + "\n")

    by_turn = touched(db, args.session_id, surviving(args.paths)) if args.paths else {}
    turns = db.execute(
        "SELECT turn_index, timestamp, user_message, assistant_response FROM turns "
        "WHERE session_id = ? AND turn_index BETWEEN COALESCE(?, 0) AND COALESCE(?, 1e9) "
        "ORDER BY turn_index",
        (args.session_id, first, last),
    ).fetchall()

    for turn_index, timestamp, user_message, assistant_response in turns:
        paths = by_turn.get(turn_index, [])
        print(f"## Turn {turn_index} ({timestamp})")
        if paths:
            print("touched: " + ", ".join(paths))
        print(f"\n### User\n{user_message or ''}\n")
        print(f"### Assistant\n{assistant_response or ''}\n")


def cmd_search(args):
    db = connect(args.db)
    sql = (
        "SELECT f.session_id, f.source_type, f.source_id, t.timestamp, "
        "snippet(search_index, 0, '[', ']', '…', 24) "
        "FROM search_index f LEFT JOIN turns t ON f.source_type = 'turn' "
        "AND t.session_id = f.session_id "
        "AND t.turn_index = CAST(substr(f.source_id, instr(f.source_id, ':turn:') + 6) AS INTEGER) "
        "WHERE search_index MATCH ?"
    )
    params = [args.query]
    if args.sessions:
        sql += " AND f.session_id IN ({})".format(",".join("?" * len(args.sessions)))
        params += args.sessions
    sql += " ORDER BY rank LIMIT ?"
    params.append(args.limit)
    try:
        rows = db.execute(sql, params).fetchall()
    except sqlite3.OperationalError as e:
        sys.exit(f"Bad search query {args.query!r}: {e}. Quote phrases: '\"exact phrase\"'")
    for session_id, source_type, source_id, timestamp, snippet in rows:
        source = source_id[len(session_id) + 1:] if source_id.startswith(session_id) else source_type
        print("\t".join([session_id, source, timestamp or "", " ".join(snippet.split())]))


def event_texts(event):
    data = event.get("data") or {}
    kind = event.get("type")
    if kind == "user.message":
        yield "user", data.get("content")
    elif kind == "assistant.message":
        yield "assistant", data.get("content")
        yield "reasoning", data.get("reasoningText")


def cmd_events(args):
    pattern = re.compile(args.regex, re.IGNORECASE)
    files = sorted(glob.glob(os.path.join(SESSION_STATE, "*", "events.jsonl")))
    if args.sessions:
        files = [f for f in files if os.path.basename(os.path.dirname(f)).startswith(tuple(args.sessions))]
        if not files:
            sys.exit(f"No session matches {args.sessions}. Try: ls {SESSION_STATE}")
    for path in files:
        session_id = os.path.basename(os.path.dirname(path))
        with open(path) as f:
            for line in f:
                event = json.loads(line)
                timestamp = event.get("timestamp", "")
                agent = event.get("agentId") or "-"
                if (args.since and timestamp < args.since) or (args.until and timestamp > args.until):
                    continue
                if agent != "-" and not args.agents:
                    continue
                for role, text in event_texts(event):
                    match = pattern.search(text) if isinstance(text, str) else None
                    if match is None:
                        continue
                    start = max(0, match.start() - args.width // 2)
                    excerpt = " ".join(text[start:start + args.width].split())
                    print("\t".join([session_id, timestamp, role, agent, excerpt]))


def turn_range(text):
    first, _, last = text.partition("-")
    try:
        return int(first), int(last or first)
    except ValueError:
        raise argparse.ArgumentTypeError(f"expected A-B or N, got {text!r}")


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
    p_tr.add_argument("--paths", help="file of repo-relative paths surviving at <orig>")
    p_tr.add_argument("--turns", type=turn_range, help="A-B: only these turns")
    p_tr.set_defaults(func=cmd_transcript)

    p_search = sub.add_parser("search")
    p_search.add_argument("query", help="SQLite FTS5 query")
    p_search.add_argument("--sessions", nargs="+", metavar="ID")
    p_search.add_argument("--limit", type=int, default=20)
    p_search.set_defaults(func=cmd_search)

    p_events = sub.add_parser("events")
    p_events.add_argument("regex", help="Python regex, matched case-insensitively")
    p_events.add_argument("--sessions", nargs="+", metavar="ID", help="session id prefixes")
    p_events.add_argument("--since", help="ISO timestamp, e.g. 2026-10-19T15:00")
    p_events.add_argument("--until", help="ISO timestamp")
    p_events.add_argument("--agents", action="store_true", help="include subagent messages")
    p_events.add_argument("--width", type=int, default=600, help="excerpt characters")
    p_events.set_defaults(func=cmd_events)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
