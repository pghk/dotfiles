#!/usr/bin/env python3
"""Report where a Copilot CLI session's AI credits (AIU) went.

Reads ~/.copilot/session-store.db (read-only) and the session's events.jsonl.
Prints a markdown report: headline, top spenders, cost by turn, avoidable-cost
flags, and a comparison with recent sessions.
"""
import argparse
import json
import sqlite3
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path

COPILOT = Path.home() / ".copilot"
NANO = 1e9
IDLE_SECONDS = 300
BIG_WRITE_TOKENS = 100_000
BIG_CONTEXT_TOKENS = 200_000
CALL_LOOP_THRESHOLD = 60


def parse_time(value):
    return datetime.fromisoformat(value.replace("Z", "+00:00"))


def resolve_session(db, prefix):
    rows = db.execute("SELECT id FROM sessions WHERE id LIKE ?", (prefix + "%",)).fetchall()
    if len(rows) != 1:
        sys.exit(f"Expected one session matching '{prefix}', found {len(rows)}. "
                 "Try: a longer id prefix, or --latest.")
    return rows[0][0]


def latest_session(db):
    row = db.execute(
        "SELECT session_id FROM assistant_usage_events GROUP BY session_id "
        "ORDER BY MAX(created_at) DESC LIMIT 1"
    ).fetchone()
    if not row:
        sys.exit("No usage events found in session-store.db.")
    return row[0]


def load_agents(session_id):
    """agent_id -> type, description and model source, from subagent.started events."""
    agents = {}
    path = COPILOT / "session-state" / session_id / "events.jsonl"
    if not path.exists():
        return agents
    with path.open() as handle:
        for line in handle:
            if '"subagent.started"' not in line:
                continue
            event = json.loads(line)
            data = event["data"]
            agents[event.get("agentId")] = {
                "type": data.get("agentType") or data.get("agentName"),
                "description": data.get("agentDescription", ""),
                "model_source": data.get("modelSelectionSource", ""),
            }
    return agents


def aiu(nano):
    return nano / NANO


def table(headers, rows):
    cells = [[str(c) for c in row] for row in rows]
    widths = [max(len(h), *(len(r[i]) for r in cells), 3) for i, h in enumerate(headers)]

    def line(values):
        return "| " + " | ".join(v.ljust(w) for v, w in zip(values, widths)) + " |"

    return "\n".join([line(headers), "|" + "|".join("-" * (w + 2) for w in widths) + "|"]
                     + [line(r) for r in cells])


def snippet(text, width=70):
    text = " ".join((text or "").replace("|", "/").split())
    return text if len(text) <= width else text[: width - 1] + "…"


def list_sessions(db, limit):
    rows = db.execute(
        "SELECT s.id, s.updated_at, s.branch, s.summary, COALESCE(SUM(e.total_nano_aiu), 0) nano "
        "FROM sessions s LEFT JOIN assistant_usage_events e ON e.session_id = s.id "
        "GROUP BY s.id ORDER BY s.updated_at DESC LIMIT ?", (limit,)).fetchall()
    print(table(["Id", "Updated (UTC)", "Branch", "AIU", "Summary"],
                [[r["id"], r["updated_at"][:16].replace("T", " "), r["branch"] or "",
                  f"{aiu(r['nano']):,.0f}", snippet(r["summary"] or "", 50)] for r in rows]))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("session", nargs="?", help="Session id or unique prefix")
    parser.add_argument("--latest", action="store_true", help="Use the most recently active session")
    parser.add_argument("--list", type=int, nargs="?", const=15, metavar="N",
                        help="List the N most recently active sessions with their ids (default 15) and exit")
    parser.add_argument("--top", type=int, default=8, help="Rows in the top-spenders table (default 8)")
    parser.add_argument("--trend", type=int, default=5, help="Recent sessions to compare against (default 5, 0 to skip)")
    parser.add_argument("--db", default=str(COPILOT / "session-store.db"), help="Path to session-store.db")
    args = parser.parse_args()

    if not args.session and not args.latest and args.list is None:
        parser.error("give a session id, --latest, or --list")

    db = sqlite3.connect(f"file:{args.db}?mode=ro", uri=True)
    db.row_factory = sqlite3.Row
    if args.list is not None:
        list_sessions(db, args.list)
        return
    session_id = latest_session(db) if args.latest else resolve_session(db, args.session)

    calls = db.execute(
        "SELECT turn_index, agent_id, model, input_tokens, output_tokens, cache_write_tokens, "
        "total_nano_aiu, duration_ms, created_at "
        "FROM assistant_usage_events WHERE session_id = ? ORDER BY created_at",
        (session_id,),
    ).fetchall()
    if not calls:
        sys.exit(f"No usage events for session {session_id}.")

    meta = db.execute("SELECT summary, branch FROM sessions WHERE id = ?", (session_id,)).fetchone()
    prompts = db.execute(
        "SELECT timestamp, user_message FROM turns WHERE session_id = ? ORDER BY timestamp", (session_id,)
    ).fetchall()
    checkpoints = [r[0] for r in db.execute(
        "SELECT created_at FROM checkpoints WHERE session_id = ? ORDER BY created_at", (session_id,))]
    agents = load_agents(session_id)

    total = sum(c["total_nano_aiu"] for c in calls)
    start, end = parse_time(calls[0]["created_at"]), parse_time(calls[-1]["created_at"])
    print(f"# Session cost: {snippet(meta['summary'] if meta else session_id, 90)}")
    print(f"\n`{session_id}` · {meta['branch'] if meta else ''} · "
          f"{start:%Y-%m-%d %H:%M} → {end:%Y-%m-%d %H:%M} UTC\n")

    # Headline
    split = defaultdict(lambda: [0, 0, 0, 0])
    for c in calls:
        row = split[("subagent" if c["agent_id"] else "main", c["model"])]
        row[0] += 1
        row[1] += c["total_nano_aiu"]
        row[2] += c["input_tokens"]
        row[3] += c["output_tokens"]
    print(f"## Headline\n\n**{aiu(total):,.0f} AIU** across {len(calls)} calls.\n")
    print(table(
        ["Actor", "Model", "Calls", "AIU", "Share", "Input", "Output"],
        [[k[0], k[1], v[0], f"{aiu(v[1]):,.0f}", f"{v[1] / total:.0%}", f"{v[2]:,}", f"{v[3]:,}"]
         for k, v in sorted(split.items(), key=lambda kv: -kv[1][1])],
    ))

    # A turn's prompt is the latest user message sent before its first call
    turn_start, turn_end = {}, {}
    for c in calls:
        turn_start.setdefault(c["turn_index"], c["created_at"])
        turn_end[c["turn_index"]] = max(turn_end.get(c["turn_index"], ""), c["created_at"])

    def prompt_for(turn):
        found = ""
        for p in prompts:
            if p["timestamp"] <= turn_start[turn]:
                found = p["user_message"]
        return snippet(found)

    # Top spenders
    actors = defaultdict(lambda: {"calls": 0, "nano": 0, "first_turn": None, "model": ""})
    for c in calls:
        a = actors[c["agent_id"] or "MAIN"]
        a["calls"] += 1
        a["nano"] += c["total_nano_aiu"]
        a["first_turn"] = c["turn_index"] if a["first_turn"] is None else a["first_turn"]
        a["model"] = c["model"]
    print("\n## Top spenders\n")
    rows = []
    for key, a in sorted(actors.items(), key=lambda kv: -kv[1]["nano"])[: args.top]:
        info = agents.get(key, {})
        label = "main agent" if key == "MAIN" else f"{info.get('type', '?')}: {snippet(info.get('description', ''), 45)}"
        rows.append([label, "-" if key == "MAIN" else key[:8], a["model"], info.get("model_source", ""),
                     a["calls"], f"{aiu(a['nano']):,.0f}", f"{a['nano'] / total:.0%}",
                     f"t{a['first_turn']}: {prompt_for(a['first_turn'])}"])
    print(table(["Actor", "Id", "Model", "Model chosen by", "Calls", "AIU", "Share", "Turn prompt"], rows))

    # By turn
    by_turn = defaultdict(lambda: {"calls": 0, "main": 0, "sub": 0, "ctx": 0})
    for c in calls:
        t = by_turn[c["turn_index"]]
        t["calls"] += 1
        t["sub" if c["agent_id"] else "main"] += c["total_nano_aiu"]
        if not c["agent_id"]:
            t["ctx"] = max(t["ctx"], c["input_tokens"])
    print("\n## Cost by turn\n")
    rows = []
    for turn, t in sorted(by_turn.items()):
        checkpoint = "yes" if any(turn_start[turn] <= cp <= turn_end[turn] for cp in checkpoints) else ""
        rows.append([turn, f"{aiu(t['main'] + t['sub']):,.0f}", f"{aiu(t['main']):,.0f}", f"{aiu(t['sub']):,.0f}",
                     t["calls"], f"{t['ctx'] // 1000}K", checkpoint, prompt_for(turn)])
    print(table(["Turn", "AIU", "Main", "Subagents", "Calls", "Main ctx", "Checkpoint", "Prompt"], rows))

    # Avoidable-cost flags
    print("\n## Flags\n")
    flags = []
    for key, a in actors.items():
        info = agents.get(key)
        if info and info["model_source"] == "session_inheritance" and a["model"].startswith("claude-opus"):
            flags.append(f"Subagent `{key[:8]}` ({info['type']}: {snippet(info['description'], 50)}) inherited "
                         f"{a['model']} and cost {aiu(a['nano']):,.0f} AIU ({a['nano'] / total:.0%}). "
                         "Pass an explicit `model`, or set a `/subagents` preference for that agent type.")
    last_end, expired = {}, []
    for c in calls:
        key = c["agent_id"] or "MAIN"
        finished = parse_time(c["created_at"]).timestamp()
        gap = finished - c["duration_ms"] / 1000 - last_end[key] if key in last_end else 0
        if c["cache_write_tokens"] >= BIG_WRITE_TOKENS and gap > IDLE_SECONDS:
            expired.append((c["total_nano_aiu"], c["turn_index"], key, c["cache_write_tokens"], gap))
        last_end[key] = finished
    if expired:
        cost, turn, key, written, gap = max(expired)
        flags.append(f"{len(expired)} calls re-wrote {sum(e[3] for e in expired):,} tokens of context after an idle gap "
                     f"over {IDLE_SECONDS // 60} min (cache likely expired); those calls cost {aiu(sum(e[0] for e in expired)):,.0f} AIU in total. "
                     f"Worst: turn {turn} ({'main' if key == 'MAIN' else key[:8]}), {written:,} tokens after {gap / 60:.0f} min.")
    peak = max((c["input_tokens"] for c in calls if not c["agent_id"]), default=0)
    if peak >= BIG_CONTEXT_TOKENS and not checkpoints:
        flags.append(f"Main context peaked at {peak:,} tokens with no checkpoint; consider `/compact` or a fresh session.")
    per_turn_calls = defaultdict(int)
    for c in calls:
        per_turn_calls[(c["agent_id"], c["turn_index"])] += 1
    for (agent, turn), n in sorted(per_turn_calls.items(), key=lambda kv: -kv[1])[:3]:
        if n >= CALL_LOOP_THRESHOLD:
            flags.append(f"{'Main' if not agent else 'Subagent ' + agent[:8]} made {n} calls in turn {turn}; "
                         "check for loops or over-broad scope.")
    print("\n".join(f"- {f}" for f in flags) if flags else "None found.")

    # Trend
    if args.trend:
        print("\n## Recent sessions\n")
        rows = []
        for r in db.execute(
            "SELECT e.session_id, MAX(e.created_at) last, COUNT(*) calls, SUM(e.total_nano_aiu) nano, "
            "SUM(CASE WHEN e.agent_id IS NULL THEN e.total_nano_aiu ELSE 0 END) main_nano, s.summary "
            "FROM assistant_usage_events e LEFT JOIN sessions s ON s.id = e.session_id "
            "GROUP BY e.session_id ORDER BY last DESC LIMIT ?", (args.trend,)):
            marker = " ←" if r["session_id"] == session_id else ""
            rows.append([r["session_id"][:8] + marker, snippet(r["summary"] or "", 40), r["calls"],
                         f"{aiu(r['nano']):,.0f}", f"{r['main_nano'] / r['nano']:.0%}"])
        print(table(["Session", "Summary", "Calls", "AIU", "Main share"], rows))


if __name__ == "__main__":
    main()
