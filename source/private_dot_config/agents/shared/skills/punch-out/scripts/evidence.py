#!/usr/bin/env python3
"""Gather local agent conversations for a calendar day into bounded text files."""

import argparse
from datetime import date, datetime, timezone
import json
import os
from pathlib import Path
import sqlite3


def local_date(value):
    timestamp = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if timestamp.tzinfo is None:
        timestamp = timestamp.replace(tzinfo=timezone.utc)
    return timestamp.astimezone().date()


def json_lines(path):
    try:
        with path.open(encoding="utf-8") as stream:
            for line in stream:
                try:
                    value = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if isinstance(value, dict):
                    yield value
    except (OSError, UnicodeError):
        return


def message_text(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return "\n".join(
            block["text"]
            for block in content
            if isinstance(block, dict)
            and block.get("type") == "text"
            and isinstance(block.get("text"), str)
        )
    return ""


def day_message(timestamp, role, content, day):
    if role not in ("user", "assistant") or not isinstance(timestamp, str):
        return None
    try:
        if local_date(timestamp) != day:
            return None
    except ValueError:
        return None
    text = message_text(content).strip()
    if text:
        return {"timestamp": timestamp, "role": role, "text": text}
    return None


def copilot_sessions(root, day):
    sessions = {}
    for path in sorted((root / "session-state").glob("*/events.jsonl")):
        session = {
            "source": "copilot",
            "id": path.parent.name,
            "cwd": "",
            "messages": [],
        }
        for event in json_lines(path):
            data = event.get("data")
            if not isinstance(data, dict):
                continue
            if event.get("type") == "session.start":
                context = data.get("context") or {}
                session["cwd"] = context.get("cwd", "")
            role = {
                "user.message": "user",
                "assistant.message": "assistant",
            }.get(event.get("type"))
            message = day_message(
                event.get("timestamp"), role, data.get("content"), day
            )
            if message:
                session["messages"].append(message)
        sessions[session["id"]] = session

    database = root / "session-store.db"
    if database.exists():
        try:
            with sqlite3.connect(database.resolve().as_uri() + "?mode=ro", uri=True) as db:
                for session_id, cwd, timestamp, user, assistant in db.execute(
                    """
                    SELECT s.id, s.cwd, t.timestamp, t.user_message, t.assistant_response
                    FROM sessions s JOIN turns t ON t.session_id = s.id
                    WHERE substr(t.timestamp, 1, 10) BETWEEN ? AND ?
                    ORDER BY t.timestamp, t.turn_index
                    """,
                    (
                        date.fromordinal(day.toordinal() - 1).isoformat(),
                        date.fromordinal(day.toordinal() + 1).isoformat(),
                    ),
                ):
                    if session_id in sessions:
                        continue
                    key = ("database", session_id)
                    session = sessions.setdefault(
                        key,
                        {
                            "source": "copilot",
                            "id": session_id,
                            "cwd": cwd or "",
                            "messages": [],
                        },
                    )
                    for role, text in (("user", user), ("assistant", assistant)):
                        message = day_message(timestamp, role, text, day)
                        if message:
                            session["messages"].append(message)
        except sqlite3.Error:
            pass
    return [session for session in sessions.values() if session["messages"]]


def pi_sessions(root, day):
    sessions = []
    for path in sorted((root / "sessions").glob("*/*.jsonl")):
        session = {"source": "pi", "id": path.stem, "cwd": "", "messages": []}
        for event in json_lines(path):
            if event.get("type") == "session":
                session["id"] = event.get("id", path.stem)
                session["cwd"] = event.get("cwd", "")
            if event.get("type") != "message":
                continue
            data = event.get("message")
            if not isinstance(data, dict):
                continue
            message = day_message(
                event.get("timestamp"), data.get("role"), data.get("content"), day
            )
            if message:
                session["messages"].append(message)
        if session["messages"]:
            sessions.append(session)
    return sessions


def write_evidence(sessions, day, output):
    output.mkdir(parents=True, exist_ok=True)
    manifest = {"date": day.isoformat(), "sessions": []}
    for index, session in enumerate(sessions, 1):
        header = (
            f"Source: {session['source']}\nSession: {session['id']}\n"
            f"Project directory: {session['cwd']}\nDate: {day}\n\n"
        )
        transcript = "\n\n".join(
            f"[{message['timestamp']}] {message['role']}\n{message['text']}"
            for message in session["messages"]
        )
        chunks = []
        for part, offset in enumerate(range(0, len(transcript), 12000), 1):
            path = output / f"{index:04d}-{session['source']}-{part:04d}.txt"
            path.write_text(header + transcript[offset : offset + 12000], encoding="utf-8")
            chunks.append(str(path.resolve()))
        manifest["sessions"].append(
            {
                "source": session["source"],
                "id": session["id"],
                "cwd": session["cwd"],
                "messages": len(session["messages"]),
                "chunks": chunks,
            }
        )
    (output / "index.json").write_text(
        json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
    )
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--date", type=date.fromisoformat, default=date.today())
    parser.add_argument("--output", type=Path, required=True, help="Local artifact directory")
    parser.add_argument(
        "--copilot-dir", type=Path, default=Path.home() / ".copilot"
    )
    parser.add_argument(
        "--pi-dir",
        type=Path,
        default=Path(os.environ.get("PI_CODING_AGENT_DIR", Path.home() / ".pi/agent")),
    )
    args = parser.parse_args()
    sessions = copilot_sessions(args.copilot_dir.expanduser(), args.date)
    sessions.extend(pi_sessions(args.pi_dir.expanduser(), args.date))
    print(json.dumps(write_evidence(sessions, args.date, args.output.expanduser()), indent=2))


if __name__ == "__main__":
    main()
