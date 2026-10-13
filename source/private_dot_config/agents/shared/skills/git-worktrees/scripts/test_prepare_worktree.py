import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("prepare-worktree.sh")


class PrepareWorktreeTest(unittest.TestCase):
    """Prepare absent dependencies without sharing Composer paths or overwriting files."""

    def setUp(self):
        self.fixture = tempfile.TemporaryDirectory(prefix="prepare-worktree-")
        self.addCleanup(self.fixture.cleanup)
        self.root = Path(self.fixture.name).resolve()
        self.source = self.root / "source"
        self.target = self.root / "target with spaces"
        self.source.mkdir()
        self.run_command("git", "init", "--quiet", str(self.source))
        self.run_command("git", "-C", str(self.source), "config", "user.name", "Fixture")
        self.run_command("git", "-C", str(self.source), "config", "user.email", "fixture@example.invalid")
        (self.source / ".gitignore").write_text("vendor/\nnode_modules/\n.env\nscripts-ran\n")
        (self.source / "composer.json").write_text(json.dumps({
            "name": "fixture/worktree",
            "repositories": [{"packagist.org": False}],
            "autoload": {"psr-4": {"WorktreeProbe\\": "src/"}},
            "scripts": {
                "post-autoload-dump": "@php -r \"file_put_contents('scripts-ran', 'ran');\"",
            },
        }))
        (self.source / "src").mkdir()
        (self.source / "src/Location.php").write_text(
            "<?php namespace WorktreeProbe; class Location { const VALUE = 'source'; }\n"
        )
        self.run_command(
            "composer", "install", "--no-scripts", "--no-plugins", "--no-interaction", "--quiet",
            cwd=self.source,
        )
        (self.source / "node_modules").mkdir()
        (self.source / ".env").write_text("WORKTREE_FIXTURE=true\n")
        self.run_command("git", "-C", str(self.source), "add", ".")
        self.run_command("git", "-C", str(self.source), "commit", "--quiet", "-m", "Fixture")
        self.run_command(
            "git", "-C", str(self.source), "worktree", "add", "--quiet", "--detach", str(self.target)
        )
        (self.target / "src/Location.php").write_text(
            "<?php namespace WorktreeProbe; class Location { const VALUE = 'target'; }\n"
        )

    def run_command(self, *args, cwd=None, env=None):
        result = subprocess.run(args, cwd=cwd, env=env, text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result.stdout.strip()

    def prepare(self, *args, env=None):
        return subprocess.run(
            ["bash", str(SCRIPT), *args, str(self.target)],
            env=env, text=True, capture_output=True,
        )

    def assert_prepared(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def command_environment(self, name, body):
        commands = self.root / "commands"
        commands.mkdir(exist_ok=True)
        command = commands / name
        command.write_text("#!/bin/sh\n" + body)
        command.chmod(0o755)
        return {**os.environ, "PATH": str(commands) + os.pathsep + os.environ["PATH"]}

    def test_default_dependencies_compose_local_vendor_and_shared_links(self):
        self.assert_prepared(self.prepare())
        self.assertTrue((self.target / "vendor").is_dir())
        self.assertFalse((self.target / "vendor").is_symlink())
        for item in ["node_modules", ".env"]:
            self.assertTrue((self.target / item).is_symlink())
            self.assertEqual((self.target / item).resolve(), self.source / item)
        output = self.run_command(
            "php", "-r", "require 'vendor/autoload.php'; echo WorktreeProbe\\Location::VALUE;",
            cwd=self.target,
        )
        self.assertEqual(output, "target")

    def test_vendor_changes_leave_source_unchanged(self):
        source_autoload = self.source / "vendor/autoload.php"
        original = source_autoload.read_bytes()
        self.assert_prepared(self.prepare("--item", "vendor"))
        target_autoload = self.target / "vendor/autoload.php"
        self.assertNotEqual(source_autoload.stat().st_ino, target_autoload.stat().st_ino)
        target_autoload.write_text("target-only change\n")
        self.assertEqual(source_autoload.read_bytes(), original)

    def test_autoload_generation_does_not_run_project_scripts(self):
        self.assert_prepared(self.prepare("--item", "vendor"))
        self.assertFalse((self.target / "scripts-ran").exists())
        self.assertFalse((self.source / "scripts-ran").exists())

    def test_dry_run_reports_local_vendor_without_creating_dependencies(self):
        result = self.prepare("--dry-run")
        self.assert_prepared(result)
        self.assertIn("local autoload", result.stdout)
        self.assertIn("would link", result.stdout)
        for item in ["vendor", "node_modules", ".env"]:
            self.assertFalse((self.target / item).exists())

    def test_repeat_preserves_existing_vendor(self):
        self.assert_prepared(self.prepare("--item", "vendor"))
        marker = self.target / "vendor/target-only"
        marker.write_text("keep")
        result = self.prepare("--item", "vendor")
        self.assert_prepared(result)
        self.assertIn("exists vendor", result.stdout)
        self.assertEqual(marker.read_text(), "keep")

    def test_existing_symlink_is_preserved(self):
        destination = self.target / "vendor"
        destination.symlink_to(self.source / "vendor", target_is_directory=True)
        result = self.prepare("--item", "vendor")
        self.assert_prepared(result)
        self.assertIn("exists vendor", result.stdout)
        self.assertEqual(destination.readlink(), self.source / "vendor")

    def test_existing_file_is_preserved(self):
        destination = self.target / ".env"
        destination.write_text("local settings\n")
        self.assert_prepared(self.prepare("--item", ".env"))
        self.assertFalse(destination.is_symlink())
        self.assertEqual(destination.read_text(), "local settings\n")

    def test_custom_items_are_linked_instead_of_defaults(self):
        dependency = self.source / "shared/cache"
        dependency.mkdir(parents=True)
        self.assert_prepared(self.prepare("--item", "shared/cache"))
        self.assertEqual((self.target / "shared/cache").resolve(), dependency)
        self.assertFalse((self.target / "vendor").exists())

    def test_missing_source_item_is_reported_without_creating_a_link(self):
        result = self.prepare("--item", "absent")
        self.assert_prepared(result)
        self.assertIn("missing absent", result.stdout)
        self.assertFalse((self.target / "absent").is_symlink())

    def test_lockfile_mismatch_refuses_vendor_reuse(self):
        with (self.target / "composer.lock").open("a") as lockfile:
            lockfile.write("\n")
        result = self.prepare("--item", "vendor")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("composer install", result.stderr)
        self.assertFalse((self.target / "vendor").exists())

    def test_missing_lockfile_refuses_vendor_reuse(self):
        (self.target / "composer.lock").unlink()
        result = self.prepare("--item", "vendor")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("composer.lock", result.stderr)
        self.assertFalse((self.target / "vendor").exists())

    def test_copy_fallback_still_provides_independent_local_paths(self):
        self.command_environment("uname", "printf 'Other\\n'\n")
        cp = shutil.which("cp")
        env = self.command_environment(
            "cp", f'if [ "$1" = "--help" ]; then exit 1; fi\nexec "{cp}" "$@"\n'
        )
        result = self.prepare("--item", "vendor", env=env)
        self.assert_prepared(result)
        self.assertIn("(copy;", result.stdout)
        self.assertFalse((self.target / "vendor").is_symlink())
        self.assertNotEqual(
            (self.source / "vendor/autoload.php").stat().st_ino,
            (self.target / "vendor/autoload.php").stat().st_ino,
        )

    @unittest.skipUnless(shutil.which("gcp"), "requires GNU cp installed as gcp")
    def test_gnu_reflink_copy_provides_worktree_local_autoload(self):
        env = self.command_environment("cp", f'exec "{shutil.which("gcp")}" "$@"\n')
        result = self.prepare("--item", "vendor", env=env)
        self.assert_prepared(result)
        self.assertIn("(reflink/copy;", result.stdout)
        output = self.run_command(
            "php", "-r", "require 'vendor/autoload.php'; echo WorktreeProbe\\Location::VALUE;",
            cwd=self.target,
        )
        self.assertEqual(output, "target")

    def test_failed_autoload_generation_does_not_publish_vendor_and_can_retry(self):
        env = self.command_environment("composer", "echo 'fixture autoload failure' >&2\nexit 9\n")
        result = self.prepare("--item", "vendor", env=env)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("fixture autoload failure", result.stderr)
        self.assertFalse((self.target / "vendor").exists())
        self.assertEqual(list(self.target.glob(".vendor-prepare.*")), [])
        self.assert_prepared(self.prepare("--item", "vendor"))


@unittest.skipUnless(
    os.environ.get("WORKTREE_PEST_SOURCE"),
    "set WORKTREE_PEST_SOURCE to a checkout with vendor/bin/pest installed",
)
class PestWorktreeTest(unittest.TestCase):
    def test_pest_loads_the_target_root_and_test_case_bindings(self):
        source = Path(os.environ["WORKTREE_PEST_SOURCE"]).resolve()
        self.assertTrue((source / "vendor/bin/pest").is_file())
        original_autoload = {
            path.name: path.read_bytes()
            for path in (source / "vendor/composer").glob("*.php")
        }
        with tempfile.TemporaryDirectory(prefix="prepare-pest-worktree-") as directory:
            target = Path(directory).resolve() / "target"
            subprocess.run(
                ["git", "-C", str(source), "worktree", "add", "--quiet", "--detach", str(target)],
                check=True,
            )
            try:
                result = subprocess.run(
                    ["bash", str(SCRIPT), "--source", str(source), str(target)],
                    text=True, capture_output=True,
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                (target / "tests/Unit").mkdir(parents=True, exist_ok=True)
                (target / "tests/Pest.php").write_text(
                    "<?php\n"
                    "class PreparedWorktreeTestCase extends \\PHPUnit\\Framework\\TestCase {}\n"
                    "pest()->extend(PreparedWorktreeTestCase::class)->in('Unit');\n"
                )
                (target / "tests/Unit/PreparedWorktreeTest.php").write_text(
                    "<?php\n"
                    "test('loads this worktree', function () {\n"
                    "    expect(\\Pest\\TestSuite::getInstance()->rootPath)->toBe(dirname(__DIR__, 2));\n"
                    "    expect($this)->toBeInstanceOf(PreparedWorktreeTestCase::class);\n"
                    "});\n"
                )
                (target / "phpunit.worktree.xml").write_text(
                    '<phpunit bootstrap="vendor/autoload.php">'
                    '<testsuites><testsuite name="Worktree"><directory>tests/Unit</directory>'
                    '</testsuite></testsuites></phpunit>\n'
                )
                result = subprocess.run(
                    [
                        str(target / "vendor/bin/pest"),
                        "--configuration", "phpunit.worktree.xml",
                        "tests/Unit/PreparedWorktreeTest.php", "--no-coverage",
                    ],
                    cwd=target, text=True, capture_output=True,
                )
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertEqual({
                    path.name: path.read_bytes()
                    for path in (source / "vendor/composer").glob("*.php")
                }, original_autoload)
            finally:
                subprocess.run(
                    ["git", "-C", str(source), "worktree", "remove", "--force", str(target)],
                    check=True,
                )


if __name__ == "__main__":
    unittest.main()
