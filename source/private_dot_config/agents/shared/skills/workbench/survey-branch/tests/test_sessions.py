"""Behavior of scripts/sessions.py against a fixture session store.

Run from the skill root: python3 -m unittest discover -s tests
"""
import os
import sqlite3
import subprocess
import sys
import tempfile
import unittest

SCRIPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "scripts", "sessions.py")


class SessionsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.db = os.path.join(self.tmp.name, "store.db")
        db = sqlite3.connect(self.db)
        db.executescript("""
            CREATE TABLE sessions (id TEXT PRIMARY KEY, branch TEXT, cwd TEXT, summary TEXT);
            CREATE TABLE turns (id INTEGER PRIMARY KEY, session_id TEXT, turn_index INTEGER,
                                user_message TEXT, assistant_response TEXT, timestamp TEXT);
            CREATE TABLE session_files (session_id TEXT, file_path TEXT, turn_index INTEGER);
            CREATE TABLE checkpoints (session_id TEXT, checkpoint_number INTEGER, title TEXT,
                                      overview TEXT, work_done TEXT);
            CREATE VIRTUAL TABLE search_index USING fts5(content, session_id UNINDEXED,
                                                         source_type UNINDEXED, source_id UNINDEXED);
        """)
        for sid in ("s1", "s2"):
            db.execute("INSERT INTO sessions VALUES (?, 'feature', '/repo', 'work')", (sid,))
            for i, text in enumerate(["set up tokens", "why density beats spacing props", "wrap up"]):
                db.execute("INSERT INTO turns (session_id, turn_index, user_message, assistant_response, timestamp) "
                           "VALUES (?, ?, ?, 'ok', ?)", (sid, i, text, "2026-01-0{}T00:00:00Z".format(i + 1)))
                db.execute("INSERT INTO search_index VALUES (?, ?, 'turn', ?)",
                           (text, sid, "{}:turn:{}".format(sid, i)))
        db.commit()
        db.close()

    def tearDown(self):
        self.tmp.cleanup()

    def run_script(self, *args):
        return subprocess.run([sys.executable, SCRIPT, "--db", self.db, *args],
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    def test_search_locates_the_turn_that_matches(self):
        out = self.run_script("search", "density", "--sessions", "s2").stdout
        self.assertEqual(out, "s2\tturn:1\t2026-01-02T00:00:00Z\twhy [density] beats spacing props\n")

    def test_transcript_turns_prints_only_the_requested_window(self):
        out = self.run_script("transcript", "s1", "--turns", "1-2").stdout
        self.assertEqual([l for l in out.splitlines() if l.startswith("## ")],
                         ["## Turn 1 (2026-01-02T00:00:00Z)", "## Turn 2 (2026-01-03T00:00:00Z)"])


if __name__ == "__main__":
    unittest.main()
