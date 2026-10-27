#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["markdown-it-py>=3,<5"]
# ///

from datetime import date
import json
import os
from pathlib import Path
import sqlite3
import subprocess
import tempfile
import time
import unittest
from unittest.mock import patch
from urllib.parse import unquote, urlparse

import evidence
import notes


DAY = date(2026, 10, 27)


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value), encoding="utf-8")


def write_events(path, events):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        "".join(json.dumps(event) + "\n" for event in events), encoding="utf-8"
    )


def prepare_vault(vault):
    config = vault / ".obsidian"
    write_json(config / "community-plugins.json", ["periodic-notes", "templater-obsidian"])
    write_json(
        config / "plugins/periodic-notes/data.json",
        {"daily": {"enabled": True, "format": "", "folder": "Daily", "template": "Templates/Daily"}},
    )
    write_json(
        config / "plugins/templater-obsidian/data.json",
        {"trigger_on_file_creation": True},
    )
    template = vault / "Templates/Daily.md"
    template.parent.mkdir(parents=True)
    template.write_text("# <% tp.file.title %>\n\nExisting daily structure.\n", encoding="utf-8")
    (vault / "Daily").mkdir()
    return vault / f"Daily/{DAY}.md"


class EvidenceTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.previous_tz = os.environ.get("TZ")
        os.environ["TZ"] = "America/New_York"
        time.tzset()
        self.addCleanup(self.restore_timezone)

    def restore_timezone(self):
        if self.previous_tz is None:
            os.environ.pop("TZ", None)
        else:
            os.environ["TZ"] = self.previous_tz
        time.tzset()

    def test_calendar_day_includes_resumed_sessions_from_both_harnesses(self):
        write_events(
            self.root / "copilot/session-state/old-session/events.jsonl",
            [
                {"type": "session.start", "timestamp": "2026-10-01T10:00:00Z", "data": {"context": {"cwd": "/projects/hub"}}},
                {"type": "user.message", "timestamp": "2026-10-27T03:59:59Z", "data": {"content": "Yesterday's request"}},
                {"type": "assistant.message", "timestamp": "2026-10-27T04:00:00Z", "data": {"content": "Resolved the cache invalidation defect."}},
                {"type": "tool.execution_complete", "timestamp": "2026-10-27T12:00:00Z", "data": {"content": "Private tool payload"}},
                {"type": "assistant.message", "timestamp": "2026-10-28T03:59:59Z", "data": {"content": "Documented the recovery decision."}},
                {"type": "assistant.message", "timestamp": "2026-10-28T04:00:00Z", "data": {"content": "Tomorrow's work"}},
            ],
        )
        pi_path = self.root / "pi/sessions/project/old-session.jsonl"
        write_events(
            pi_path,
            [
                {"type": "session", "id": "pi-session", "timestamp": "2026-09-01T10:00:00Z", "cwd": "/projects/design"},
                {"type": "message", "timestamp": "2026-10-27T15:00:00Z", "message": {"role": "assistant", "content": [{"type": "thinking", "thinking": "Internal reasoning"}, {"type": "text", "text": "Settled the navigation design."}]}},
                {"type": "message", "timestamp": "2026-10-27T15:01:00Z", "message": {"role": "toolResult", "content": [{"type": "text", "text": "Tool output"}]}},
            ],
        )
        with pi_path.open("a") as stream:
            stream.write('{"type": "message"')
        command = [
            "python3", str(Path(evidence.__file__)),
            "--date", str(DAY), "--output", str(self.root / "output"),
            "--copilot-dir", str(self.root / "copilot"), "--pi-dir", str(self.root / "pi"),
        ]
        result = subprocess.run(command, check=True, capture_output=True, text=True)
        manifest = json.loads(result.stdout)
        transcripts = {
            entry["cwd"]: "".join(Path(chunk).read_text() for chunk in entry["chunks"])
            for entry in manifest["sessions"]
        }
        self.assertIn("Resolved the cache invalidation defect.", transcripts["/projects/hub"])
        self.assertIn("Documented the recovery decision.", transcripts["/projects/hub"])
        self.assertIn("Settled the navigation design.", transcripts["/projects/design"])
        combined = "\n".join(transcripts.values())
        for excluded in ("Yesterday's request", "Tomorrow's work", "Private tool payload", "Internal reasoning", "Tool output"):
            self.assertNotIn(excluded, combined)
        self.assertEqual(result.stderr, "")

    def test_database_fallback_preserves_local_day_without_duplicating_raw_sessions(self):
        root = self.root / "copilot"
        root.mkdir()
        with sqlite3.connect(root / "session-store.db") as db:
            db.executescript(
                "CREATE TABLE sessions (id TEXT, cwd TEXT);"
                "CREATE TABLE turns (session_id TEXT, timestamp TEXT, turn_index INTEGER, user_message TEXT, assistant_response TEXT);"
                "INSERT INTO sessions VALUES ('archived', '/projects/api'), ('raw', '/projects/ui');"
                "INSERT INTO turns VALUES ('archived', '2026-10-28 03:00:00', 0, 'Investigate the timeout', 'Identified queue starvation.');"
                "INSERT INTO turns VALUES ('archived', '2026-10-28 04:00:00', 1, 'Next day', 'Outside the selected day.');"
                "INSERT INTO turns VALUES ('raw', '2026-10-27 12:00:00', 0, 'Duplicate database turn', 'Duplicate response');"
            )
        write_events(
            root / "session-state/raw/events.jsonl",
            [{"type": "assistant.message", "timestamp": "2026-10-27T12:00:00Z", "data": {"content": "Canonical event."}}],
        )
        sessions = evidence.copilot_sessions(root, DAY)
        messages = [message["text"] for session in sessions for message in session["messages"]]
        self.assertCountEqual(messages, ["Canonical event.", "Investigate the timeout", "Identified queue starvation."])

    def test_missing_histories_produce_no_evidence_without_warnings(self):
        self.assertEqual(evidence.copilot_sessions(self.root / "absent", DAY), [])
        self.assertEqual(evidence.pi_sessions(self.root / "absent", DAY), [])

    def test_large_conversations_are_split_without_losing_text(self):
        text = "Navigation decision: " + "x" * 25000 + "\nUnfinished: keyboard support."
        session = {
            "source": "pi", "id": "large", "cwd": "/projects/ui",
            "messages": [{"timestamp": "2026-10-27T12:00:00Z", "role": "assistant", "text": text}],
        }
        manifest = evidence.write_evidence([session], DAY, self.root / "output")
        chunks = [Path(path).read_text() for path in manifest["sessions"][0]["chunks"]]
        restored = "".join(chunk.split(f"Date: {DAY}\n\n", 1)[1] for chunk in chunks)
        self.assertEqual(restored, f"[2026-10-27T12:00:00Z] assistant\n{text}")
        self.assertTrue(all(len(chunk) < 12500 for chunk in chunks))


class NoteTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.vault = Path(self.temporary.name).resolve()
        self.path = prepare_vault(self.vault)
        home = self.vault / "home"
        write_json(
            home / "Library/Application Support/obsidian/obsidian.json",
            {"vaults": {"fixture-vault": {"path": str(self.vault), "open": True}}},
        )
        self.home = patch.object(notes.Path, "home", return_value=home)
        self.home.start()
        self.addCleanup(self.home.stop)

    def test_refresh_preserves_other_sections_and_fenced_heading_examples(self):
        prefix = (
            "---\nexample: |\n  ## Summary\n---\n"
            "# Tuesday\n\n```dataview\n## Summary\n```\n\n"
            "- [ ] Existing task\n\n"
        )
        suffix = "Personal notes\n--------------\n\nKeep this exactly.\n"
        self.path.write_text(
            prefix + "## Summary\n\n- Old summary\n\n### Detail\n\nOld detail\n\n" + suffix,
            encoding="utf-8",
        )
        result = notes.update_note(self.vault, DAY, "- Resolved the timeout.", notes.snapshot(self.path), 1)
        expected = prefix + "## Summary\n\n- Resolved the timeout.\n\n" + suffix
        self.assertEqual(self.path.read_text(), expected)
        second = notes.update_note(self.vault, DAY, "- Resolved the timeout.", notes.snapshot(self.path), 1)
        self.assertEqual(self.path.read_text(), expected)
        self.assertEqual(result["status"], "updated")
        self.assertEqual(second["status"], "unchanged")

    def test_append_preserves_crlf_and_existing_content(self):
        original = b"# Tuesday\r\n\r\n- Existing note\r\n"
        self.path.write_bytes(original)
        notes.update_note(self.vault, DAY, "- New progress.\n- Next step.", notes.snapshot(self.path), 1)
        self.assertEqual(
            self.path.read_bytes(),
            original + b"\r\n## Summary\r\n\r\n- New progress.\r\n- Next step.\r\n",
        )

    def test_stale_snapshot_preserves_the_newer_edit(self):
        self.path.write_text("# Tuesday\n", encoding="utf-8")
        snapshot = notes.snapshot(self.path)
        changed = "# Tuesday\n\nAn edit made while gathering evidence.\n"
        self.path.write_text(changed, encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "changed"):
            notes.update_note(self.vault, DAY, "- Progress", snapshot, 1)
        self.assertEqual(self.path.read_text(), changed)

    def test_empty_summary_neither_creates_nor_erases_a_note(self):
        with patch.object(notes.subprocess, "run") as launch:
            notes.update_note(self.vault, DAY, " \n", "missing", 1)
            self.assertFalse(self.path.exists())
            self.path.write_text("## Summary\n\n- Keep the existing summary.\n")
            original = self.path.read_bytes()
            notes.update_note(self.vault, DAY, "", notes.snapshot(self.path), 1)
            self.assertEqual(self.path.read_bytes(), original)
            launch.assert_not_called()

    def test_missing_dated_note_waits_for_obsidian_template_rendering(self):
        rendered = "# 2026-10-27\n\nExisting daily structure.\n"

        def launch(command, **kwargs):
            parameters = {
                unquote(key): unquote(value)
                for key, value in (
                    pair.split("=", 1) for pair in urlparse(command[1]).query.split("&")
                )
            }
            self.assertEqual(parameters["vault"], "fixture-vault")
            self.assertEqual(self.vault / parameters["file"], self.path)
            self.assertEqual(
                parameters["content"],
                (self.vault / "Templates/Daily.md").read_text(),
            )
            self.path.write_text(rendered, encoding="utf-8")

        with patch.object(notes.subprocess, "run", side_effect=launch):
            notes.update_note(self.vault, DAY, "- Implemented the recovery path.", "missing", 2)
        self.assertEqual(
            self.path.read_text(),
            rendered + "\n## Summary\n\n- Implemented the recovery path.\n",
        )

    def test_unrendered_template_receives_no_summary(self):
        unrendered = "# <% tp.file.title %>\n"

        def launch(*args, **kwargs):
            self.path.write_text(unrendered)

        with patch.object(notes.subprocess, "run", side_effect=launch):
            with self.assertRaisesRegex(ValueError, "rendering did not finish"):
                notes.update_note(self.vault, DAY, "- Progress", "missing", 0.1)
        self.assertEqual(self.path.read_text(), unrendered)


@unittest.skipUnless(os.environ.get("PUNCH_OUT_LIVE_VAULT"), "Opt-in live Obsidian check")
class LiveObsidianTests(unittest.TestCase):
    def test_uri_creation_renders_the_real_template_for_an_explicit_date(self):
        vault = Path(os.environ["PUNCH_OUT_LIVE_VAULT"]).resolve()
        day = date(2099, 12, 31)
        path = notes.daily_path(vault, notes.daily_settings(vault), day)
        if path.exists():
            self.skipTest(f"Live check will not modify an existing note: {path}")
        summary = "- punch-out temporary integration check."
        try:
            notes.update_note(vault, day, summary, "missing", 30)
            rendered = path.read_text()
            self.assertIn("December 31st, 2099", rendered)
            self.assertIn("# Thursday", rendered)
            self.assertIn('date("2099-12-31")', rendered)
            self.assertNotIn("<%", rendered)
            self.assertIn(summary, rendered)
            notes.update_note(vault, day, summary, notes.snapshot(path), 1)
            self.assertEqual(path.read_text(), rendered)
        finally:
            if path.exists() and summary in path.read_text():
                path.unlink()


if __name__ == "__main__":
    unittest.main()
