import json
from pathlib import Path
import subprocess
import tempfile
import unittest


VALIDATOR = Path(__file__).with_name("validate-skills.py")


class ValidateSkillsTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)

    def skill(self, name="example-skill", frontmatter=None, body=""):
        directory = self.root / name
        directory.mkdir(exist_ok=True)
        if frontmatter is None:
            frontmatter = f"name: {name}\ndescription: Validate a skill."
        (directory / "SKILL.md").write_text(
            f"---\n{frontmatter}\n---\n{body}", encoding="utf-8"
        )
        return directory

    def validate(self, *directories):
        result = subprocess.run(
            ["uv", "run", "--script", str(VALIDATOR), *map(str, directories)],
            capture_output=True,
            text=True,
        )
        self.assertIn(result.returncode, (0, 1), result.stderr)
        return result.returncode, json.loads(result.stdout)

    def test_accepts_multiple_skills_and_resolves_markdown_links(self):
        first = self.skill(
            frontmatter="name: example-skill\ndescription: >\n  A folded\n  description.",
            body=(
                "[Notes][notes]\n\n[notes]: notes%20file.md#details\n\n"
                "![Image](image.svg)\n\n[External](https://example.invalid/missing)\n\n"
                "```markdown\n[Example](missing.md)\n```\n"
            ),
        )
        (first / "notes file.md").write_text("# Details\n", encoding="utf-8")
        (first / "image.svg").write_text("<svg/>", encoding="utf-8")
        second = self.skill(
            "manual-skill",
            "name: manual-skill\ndescription: Manual review.\ndisable-model-invocation: true",
        )

        code, report = self.validate(first, second)

        self.assertEqual(code, 0)
        self.assertTrue(report["valid"])
        self.assertEqual(
            {entry["path"] for entry in report["skills"]}, {str(first), str(second)}
        )

    def test_rejects_invalid_frontmatter_and_skill_names(self):
        cases = [
            ("example-skill", "name: different-name\ndescription: Valid."),
            ("Bad_Name", "name: Bad_Name\ndescription: Valid."),
            ("example-skill", "name: example-skill"),
            ("example-skill", "name: example-skill\ndescription: true"),
            ("example-skill", "name: [unterminated"),
        ]
        for name, frontmatter in cases:
            with self.subTest(frontmatter=frontmatter):
                directory = self.skill(name, frontmatter)
                code, report = self.validate(directory)
                self.assertEqual(code, 1)
                self.assertFalse(report["valid"])
                self.assertTrue(report["skills"][0]["errors"])

    def test_description_limit_accepts_boundary_and_rejects_overflow(self):
        for length, expected_code in [(1024, 0), (1025, 1)]:
            with self.subTest(length=length):
                directory = self.skill(
                    frontmatter=f"name: example-skill\ndescription: {'x' * length}"
                )
                code, _ = self.validate(directory)
                self.assertEqual(code, expected_code)

    def test_reports_broken_links_in_bundled_references(self):
        directory = self.skill(body="[Notes](references/notes.md)")
        reference = directory / "references" / "notes.md"
        reference.parent.mkdir()
        reference.write_text("[Missing](missing.md)", encoding="utf-8")

        code, report = self.validate(directory)

        self.assertEqual(code, 1)
        self.assertTrue(
            any(
                error["path"] == str(reference) and "missing.md" in error["message"]
                for error in report["skills"][0]["errors"]
            )
        )


if __name__ == "__main__":
    unittest.main()
