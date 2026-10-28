#!/usr/bin/env python3
"""Behavioral tests for section.py, run as the CLI with a temporary NOTES_DIR."""

import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).with_name("section.py")


class WriteSectionTests(unittest.TestCase):
    def setUp(self):
        self.root = tempfile.TemporaryDirectory()
        self.addCleanup(self.root.cleanup)
        self.note = Path(self.root.name) / "Daily" / "2026-10-28.md"

    def run_script(self, body, section="Summary"):
        return subprocess.run(
            [sys.executable, SCRIPT, "--date", "2026-10-28", "--section", section],
            input=body,
            capture_output=True,
            text=True,
            env={**os.environ, "NOTES_DIR": self.root.name},
        )

    def write_note(self, text):
        self.note.parent.mkdir(parents=True)
        self.note.write_text(text, encoding="utf-8")

    def test_missing_note_is_created_with_only_the_section(self):
        result = self.run_script("- shipped\n")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.note.read_text(), "## Summary\n\n- shipped\n")

    def test_existing_section_is_replaced_and_surrounding_content_kept(self):
        self.write_note(
            "---\ntags: [daily]\n---\n# Today\n\n## Summary\n\n- old\n\n### Detail\n\nold detail\n\n## Tasks\n\n- [ ] keep\n"
        )

        result = self.run_script("- new\n")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            self.note.read_text(),
            "---\ntags: [daily]\n---\n# Today\n\n## Summary\n\n- new\n\n## Tasks\n\n- [ ] keep\n",
        )

    def test_headings_inside_fenced_code_do_not_bound_the_section(self):
        self.write_note("## Summary\n\n```md\n## Tasks\n```\n\n## Tasks\n\n- keep\n")

        result = self.run_script("- new\n")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.note.read_text(), "## Summary\n\n- new\n\n## Tasks\n\n- keep\n")

    def test_absent_section_is_appended(self):
        self.write_note("# Today\n\n## Tasks\n\n- keep\n\n")

        result = self.run_script("- new\n")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            self.note.read_text(), "# Today\n\n## Tasks\n\n- keep\n\n## Summary\n\n- new\n"
        )

    def test_duplicate_sections_leave_the_note_unchanged(self):
        original = "## Summary\n\n- a\n\n## Summary\n\n- b\n"
        self.write_note(original)

        result = self.run_script("- new\n")

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.note.read_text(), original)


if __name__ == "__main__":
    unittest.main()
