#!/usr/bin/env python3
"""Daily evidence and publication checks against disposable local repositories."""

from contextlib import closing
from datetime import date, datetime
import os
from pathlib import Path
import sqlite3
import subprocess
import tempfile
import time
import unittest
from unittest.mock import patch

import gather


DAY = date(2026, 10, 28)


class EvidenceTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.directory = Path(temporary.name).resolve()
        environment = patch.dict(os.environ, {
            "TZ": "America/New_York", "GIT_CONFIG_GLOBAL": os.devnull,
            "GIT_CONFIG_NOSYSTEM": "1", "GIT_AUTHOR_NAME": "Test",
            "GIT_AUTHOR_EMAIL": "test@example.invalid", "GIT_COMMITTER_NAME": "Test",
            "GIT_COMMITTER_EMAIL": "test@example.invalid",
            "GIT_AUTHOR_DATE": "2026-10-27T12:00:00-04:00",
            "GIT_COMMITTER_DATE": "2026-10-27T12:00:00-04:00",
        })
        environment.start()
        self.addCleanup(time.tzset)
        self.addCleanup(environment.stop)
        time.tzset()
        self.root = self.directory / "repo"
        self.command("init", "-q", "-b", "main", str(self.root), cwd=self.directory)
        self.commit("baseline")

    def command(self, *arguments, cwd=None, timestamp=None):
        environment = dict(os.environ)
        if timestamp:
            environment["GIT_COMMITTER_DATE"] = timestamp
        return subprocess.run(
            ["git", "-c", "core.hooksPath=/dev/null", "-C", str(cwd or self.root), *arguments],
            check=True, capture_output=True, text=True, env=environment,
        ).stdout.strip()

    def commit(self, subject, timestamp=None, cwd=None):
        self.command("commit", "-q", "--allow-empty", "-m", subject, timestamp=timestamp, cwd=cwd)
        return self.command("rev-parse", "HEAD", cwd=cwd)

    def database(self, cwd):
        path = self.directory / "sessions.db"
        with closing(sqlite3.connect(path)) as db, db:
            db.executescript(
                "CREATE TABLE sessions (id TEXT, cwd TEXT, repository TEXT, branch TEXT, summary TEXT);"
                "CREATE TABLE turns (session_id TEXT, timestamp TEXT);"
            )
            db.execute("INSERT INTO sessions VALUES ('work', ?, 'repo', 'RAV-123/dev', 'work')", (str(cwd),))
            db.execute("INSERT INTO sessions VALUES ('self', ?, '', '', 'punch-out')", (str(cwd),))
            db.executemany("INSERT INTO turns VALUES (?, ?)", [
                ("work", "2026-10-28T03:59:59Z"),
                ("work", "2026-10-28T04:00:00Z"),
                ("work", "2026-10-28T14:35:05Z"),
                ("work", "2026-10-28T14:45:20Z"),
                ("work", "2026-10-29T04:00:00Z"),
                ("self", "2026-10-28T14:00:00Z"),
            ])
        return path

    def test_shell_collection_pages_without_losing_repeated_paths_and_scopes_local_day(self):
        record = "2026-10-28 09:00:00\t/work/project\0"
        with patch("gather.run", side_effect=[
            record * 1000,
            "2026-10-28 10:00:00\t/work/other\0"
            "2026-10-29 00:00:00\t/work/tomorrow\0",
        ]):
            records = gather.atuin_activity(DAY)

        self.assertEqual(len(records), 1001)
        self.assertEqual({record["path"] for record in records}, {"/work/project", "/work/other"})

    def test_sessions_use_days_turns_and_interaction_windows_not_whole_session_lifetime(self):
        sessions = gather.session_activity(self.database(self.root), DAY, "self")

        self.assertEqual([session["id"] for session in sessions], ["work"])
        self.assertEqual(sessions[0]["turns"], 3)
        self.assertEqual(sessions[0]["first"], "2026-10-28 00:00:00")
        self.assertEqual(sessions[0]["last"], "2026-10-28 10:45:20")
        self.assertEqual(sessions[0]["interaction_windows"], [
            "2026-10-28T00:00:00", "2026-10-28T10:30:00",
        ])

    def test_git_finds_days_commits_and_issue_branches_in_other_worktrees(self):
        worktree = self.directory / "worktree"
        self.command(
            "worktree", "add", "-q", "-b", "RAV-456/dev", str(worktree),
            timestamp="2026-10-28T10:00:00-04:00",
        )
        commit = self.commit("Implement page states", "2026-10-28T11:00:00-04:00", worktree)
        self.commit("Next day", "2026-10-29T00:00:00-04:00", worktree)
        evidence = gather.repository_evidence(
            str(self.root),
            datetime.fromisoformat("2026-10-28T00:00:00-04:00"),
            datetime.fromisoformat("2026-10-29T00:00:00-04:00"),
        )

        self.assertEqual([record["commit"] for record in evidence["commits"]], [commit])
        self.assertIn("RAV-456", evidence["issue_keys"])
        self.assertTrue(any(
            event["commit"] == commit and event.get("worktree") == str(worktree)
            for event in evidence["reflog"]
        ))

    def test_publication_checks_all_branches_and_distinguishes_tracking_from_publication(self):
        remote = self.directory / "remote.git"
        self.command("init", "--bare", "-q", str(remote))
        self.command("remote", "add", "origin", str(remote))
        self.command("push", "-q", "-u", "origin", "main")
        self.command("branch", "published-without-upstream")
        self.command("switch", "-q", "-c", "RAV-123/dev")
        self.commit("Local work")
        self.command("branch", "--set-upstream-to", "main")
        self.command("switch", "-q", "main")
        self.commit("Ahead of origin")
        self.command("branch", "gone")
        self.command("update-ref", "refs/remotes/origin/gone", "main")
        self.command("branch", "--set-upstream-to", "origin/gone", "gone")
        self.command("update-ref", "-d", "refs/remotes/origin/gone")
        branches = {branch["branch"]: branch for branch in gather.publication_status(self.root)}

        self.assertEqual(branches["main"]["ahead"], 1)
        self.assertEqual(branches["main"]["unpublished_commits"], 1)
        self.assertEqual(branches["RAV-123/dev"]["tracking"], "local")
        self.assertEqual(branches["RAV-123/dev"]["unpublished_commits"], 1)
        self.assertEqual(branches["published-without-upstream"]["tracking"], "none")
        self.assertEqual(branches["published-without-upstream"]["unpublished_commits"], 0)
        self.assertEqual(branches["gone"]["tracking"], "missing")

    def test_day_includes_local_branch_activity_even_when_the_commit_is_older(self):
        self.command(
            "switch", "-q", "-c", "RAV-789/review",
            timestamp="2026-10-28T15:00:00-04:00",
        )
        events = gather.reflog_activity(
            self.root,
            datetime.fromisoformat("2026-10-28T00:00:00-04:00"),
            datetime.fromisoformat("2026-10-29T00:00:00-04:00"),
        )

        self.assertTrue(any(
            event["time"] == "2026-10-28T15:00:00-04:00"
            and "RAV-789" in event["issue_keys"]
            for event in events
        ))

    def test_publication_ignores_trash_branches_even_with_unpublished_code(self):
        remote = self.directory / "remote.git"
        self.command("init", "--bare", "-q", str(remote))
        self.command("remote", "add", "origin", str(remote))
        self.command("push", "-q", "-u", "origin", "main")
        self.command("branch", "RAV-123/retained")
        self.command("switch", "-q", "-c", "trash/RAV-123/dev")
        self.commit("Abandoned work", "2026-10-28T10:00:00-04:00")
        evidence = gather.repository_evidence(
            str(self.root),
            datetime.fromisoformat("2026-10-28T00:00:00-04:00"),
            datetime.fromisoformat("2026-10-29T00:00:00-04:00"),
            ["trash/RAV-123/dev"],
        )

        self.assertEqual(
            {branch["branch"] for branch in evidence["publication"]},
            {"main", "RAV-123/retained"},
        )
        report = evidence["publication_report"]
        self.assertEqual(report["day_relevant"], [])
        self.assertEqual(report["historical"], {
            "checked_branches": 2, "unpublished_branches": 0,
            "ahead_of_remote_upstream": 0, "missing_upstreams": 0,
        })

    def test_publication_report_prioritizes_local_daily_concerns_and_collapses_history(self):
        remote = self.directory / "remote.git"
        self.command("init", "--bare", "-q", str(remote))
        self.command("remote", "add", "origin", str(remote))
        self.command("push", "-q", "-u", "origin", "main")
        self.command("branch", "old/published")
        self.command("switch", "-q", "-c", "old/unpublished")
        self.commit("Historical local work")
        self.command("branch", "--set-upstream-to", "origin/main")
        self.command("branch", "old/missing")
        self.command("update-ref", "refs/remotes/origin/gone", "HEAD")
        self.command("branch", "--set-upstream-to", "origin/gone", "old/missing")
        self.command("update-ref", "-d", "refs/remotes/origin/gone")
        self.command("switch", "-q", "main")
        self.command("branch", "RAV-123/pr")
        self.command(
            "switch", "-q", "-c", "RAV-123/dev",
            timestamp="2026-10-28T10:00:00-04:00",
        )
        self.commit("Daily work", "2026-10-28T10:05:00-04:00")
        self.command(
            "switch", "-q", "-c", "review",
            timestamp="2026-10-28T10:10:00-04:00",
        )
        self.command("branch", "RAV-999/dev")
        self.command(
            "update-ref", "-m", "fetch origin", "refs/remotes/origin/RAV-999/dev", "HEAD",
            timestamp="2026-10-28T11:00:00-04:00",
        )
        evidence = gather.repository_evidence(
            str(self.root),
            datetime.fromisoformat("2026-10-28T00:00:00-04:00"),
            datetime.fromisoformat("2026-10-29T00:00:00-04:00"),
        )
        report = evidence["publication_report"]

        self.assertEqual(
            {branch["branch"] for branch in report["day_relevant"]},
            {"main", "RAV-123/dev", "RAV-123/pr", "review"},
        )
        self.assertEqual(report["historical"], {
            "checked_branches": 4, "unpublished_branches": 2,
            "ahead_of_remote_upstream": 1, "missing_upstreams": 1,
        })
        self.assertIn("old/unpublished", {
            branch["branch"] for branch in evidence["publication"]
        })

    def test_collection_combines_managed_shell_paths_and_session_only_worktrees_once(self):
        target = self.directory / "config"
        target.mkdir()
        worktree = self.directory / "worktree"
        self.command("worktree", "add", "-q", "-b", "RAV-123/dev", str(worktree))
        database = self.database(worktree)
        original_run = gather.run

        def commands(*arguments):
            if arguments[0] == "atuin":
                return f"2026-10-28 10:00:00\t{target}\0"
            if arguments[0] == "chezmoi":
                return str(self.root)
            return original_run(*arguments)

        with patch("gather.run", side_effect=commands):
            evidence = gather.collect(DAY, database, [], "self")

        self.assertEqual(evidence["warnings"], [])
        self.assertEqual(len(evidence["repositories"]), 1)
        self.assertEqual(set(evidence["repositories"][0]["paths"]), {str(target), str(worktree)})
        self.assertEqual(
            [branch["branch"] for branch in evidence["repositories"][0]["publication_report"]["day_relevant"]],
            ["RAV-123/dev"],
        )
        self.assertEqual(
            evidence["repositories"][0]["publication_report"]["historical"]["checked_branches"], 1,
        )

    def test_unavailable_source_is_partial_evidence_not_a_clean_bill_of_health(self):
        with patch("gather.atuin_activity", return_value=[]):
            evidence = gather.collect(DAY, self.directory / "missing.db", [str(self.root)], "")

        self.assertTrue(any(warning.startswith("sessions:") for warning in evidence["warnings"]))
        self.assertEqual(evidence["repositories"][0]["root"], str(self.root))


if __name__ == "__main__":
    unittest.main()
