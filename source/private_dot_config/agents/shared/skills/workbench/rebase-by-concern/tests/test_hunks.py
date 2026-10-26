"""Behavior of scripts/hunks.py against throwaway repositories.

Run from the skill root: python3 -m unittest discover -s tests
"""
import os
import subprocess
import sys
import tempfile
import unittest

SCRIPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "scripts", "hunks.py")

BASE_APP = "".join("line {}\n".format(i) for i in range(1, 31))
ORIG_APP = BASE_APP.replace("line 2\n", "line 2 changed\nline 2b\n").replace(
    "line 15\n", "line 15 changed\n").replace("line 28\n", "line 28 changed\n")
WITH_FIRST_AND_LAST = BASE_APP.replace("line 2\n", "line 2 changed\nline 2b\n").replace(
    "line 28\n", "line 28 changed\n")
WITH_FIRST = BASE_APP.replace("line 2\n", "line 2 changed\nline 2b\n")


class Repo:
    def __init__(self, root):
        self.root = root
        self.git("init", "-q", "-b", "main")
        self.git("config", "user.email", "t@example.com")
        self.git("config", "user.name", "T")

    def git(self, *args):
        return subprocess.run(["git", *args], cwd=self.root, check=True,
                              stdout=subprocess.PIPE, text=True).stdout

    def write(self, path, content):
        with open(os.path.join(self.root, path), "w") as f:
            f.write(content)

    def commit(self, message):
        self.git("add", "-A")
        self.git("commit", "-q", "-m", message)
        return self.git("rev-parse", "HEAD").strip()

    def show(self, rev, path):
        return self.git("show", "{}:{}".format(rev, path))

    def run(self, *args):
        return subprocess.run([sys.executable, SCRIPT, *args], cwd=self.root,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)


def concern(n, members, message, disposition=None):
    lines = ["### {}. concern {}".format(n, n)]
    if disposition:
        lines.append("- disposition: {}".format(disposition))
    lines.append("- members:")
    lines += ["    - {}".format(m) for m in members]
    lines.append("- message: |")
    lines += ["    " + l if l else "" for l in message.splitlines()]
    lines.append("- depends on: none")
    return "\n".join(lines)


class HunksTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.notes = tempfile.TemporaryDirectory()
        self.repo = Repo(self.tmp.name)
        self.repo.write("app.txt", BASE_APP)
        self.repo.write("old.txt", "old\n")
        self.base = self.repo.commit("base")
        self.repo.git("switch", "-q", "-c", "feature")
        self.repo.write("app.txt", ORIG_APP)
        os.remove(os.path.join(self.tmp.name, "old.txt"))
        self.repo.write("new.txt", "new\n")
        self.orig = self.repo.commit("feature")
        self.map = os.path.join(self.notes.name, "map.md")

    def tearDown(self):
        self.tmp.cleanup()
        self.notes.cleanup()

    def write_map(self, *concerns, dropped=()):
        body = ["---", "base: " + self.base, "orig: " + self.orig, "---", "", "## Concerns", ""]
        body += [c + "\n" for c in concerns]
        body += ["## Dropped", ""] + ["- {} — not wanted".format(d) for d in dropped]
        with open(self.map, "w") as f:
            f.write("\n".join(body) + "\n")

    def test_list_summarizes_each_changed_path_with_its_hunk_count(self):
        out = self.repo.run("list", self.base, self.orig).stdout.splitlines()
        self.assertEqual(out, ["app.txt\tM\t3\t+4 -3", "new.txt\tA\t1\t+1 -0", "old.txt\tD\t1\t+0 -1"])

    def test_list_hunks_numbers_each_hunk_with_its_first_change(self):
        out = self.repo.run("list", self.base, self.orig, "--hunks", "app.txt").stdout.splitlines()
        self.assertEqual([l.split("\t")[0] for l in out], ["app.txt#1", "app.txt#2", "app.txt#3"])
        self.assertTrue(out[2].endswith("+line 28 changed"))

    def test_check_passes_when_every_hunk_has_one_owner(self):
        self.write_map(concern(1, ["app.txt#1", "new.txt"], "one"),
                       concern(2, ["app.txt#2,3"], "two"), dropped=["old.txt"])
        result = self.repo.run("check", self.map)
        self.assertEqual((result.returncode, result.stdout), (0, ""))

    def test_check_reports_unassigned_hunks(self):
        self.write_map(concern(1, ["app.txt#1", "app.txt#3", "new.txt", "old.txt"], "one"))
        result = self.repo.run("check", self.map)
        self.assertEqual((result.returncode, result.stdout), (1, "unassigned\tapp.txt#2\t\n"))

    def test_check_reports_a_hunk_claimed_twice(self):
        self.write_map(concern(1, ["app.txt", "new.txt", "old.txt"], "one"),
                       concern(2, ["app.txt#2"], "two"))
        result = self.repo.run("check", self.map)
        self.assertEqual((result.returncode, result.stdout), (1, "multiple\tapp.txt\t1,2\n"))

    def test_check_rejects_ids_that_do_not_exist(self):
        self.write_map(concern(1, ["app.txt", "new.txt", "old.txt", "app.txt#4", "missing.txt"], "one"))
        result = self.repo.run("check", self.map)
        self.assertEqual(result.stdout, "unknown\tapp.txt#4\t1\nunknown\tmissing.txt\t1\n")

    def test_check_rejects_hunk_ids_on_whole_file_changes(self):
        self.write_map(concern(1, ["app.txt", "new.txt#1", "old.txt"], "one"))
        result = self.repo.run("check", self.map)
        self.assertEqual(result.stdout, "whole-file-only\tnew.txt#1\t1\nunassigned\tnew.txt\t\n")

    def test_build_commits_each_concern_with_its_hunks_in_map_order(self):
        self.write_map(concern(1, ["app.txt#1", "app.txt#3"], "🐛 First\n\nBody one."),
                       concern(2, ["app.txt#2", "new.txt", "old.txt"], "✨ Second"))
        self.repo.git("switch", "-q", "-c", "clean", self.base)
        result = self.repo.run("build", self.map)
        self.assertEqual(result.returncode, 0, result.stderr)

        self.assertEqual(self.repo.git("log", "-1", "--format=%B", "HEAD~1"), "🐛 First\n\nBody one.\n\n")
        self.assertEqual(self.repo.show("HEAD~1", "app.txt"), WITH_FIRST_AND_LAST)
        self.assertEqual(self.repo.git("ls-tree", "--name-only", "HEAD~1"), "app.txt\nold.txt\n")
        self.assertEqual(self.repo.git("rev-parse", "HEAD^{tree}"), self.repo.git("rev-parse", self.orig + "^{tree}"))

    def test_build_leaves_out_dropped_hunks_and_split_concerns(self):
        self.write_map(concern(1, ["app.txt#1", "old.txt"], "one"),
                       concern(2, ["new.txt"], "two", disposition="split:other-branch"),
                       dropped=["app.txt#2,3"])
        self.repo.git("switch", "-q", "-c", "clean", self.base)
        self.repo.run("build", self.map)
        self.assertEqual(self.repo.git("log", "--format=%s", self.base + "..HEAD"), "one\n")
        self.assertEqual(self.repo.git("diff", "--name-only", "HEAD", self.orig), "app.txt\nnew.txt\n")
        self.assertEqual(self.repo.show("HEAD", "app.txt"), WITH_FIRST)

    def test_build_refuses_to_start_away_from_base(self):
        self.write_map(concern(1, ["app.txt", "new.txt", "old.txt"], "one"))
        result = self.repo.run("build", self.map)
        self.assertEqual(result.returncode, 2)
        self.assertEqual(self.repo.git("rev-parse", "HEAD").strip(), self.orig)

    def test_build_preserves_a_missing_final_newline(self):
        self.repo.git("switch", "-q", "main")
        self.repo.write("tail.txt", "a\nb\nc\nd\ne\nf\ng\nh\nend")
        self.base = self.repo.commit("tail base")
        self.repo.git("switch", "-q", "-c", "tail")
        self.repo.write("tail.txt", "A\nb\nc\nd\ne\nf\ng\nh\nEND")
        self.orig = self.repo.commit("tail change")
        self.write_map(concern(1, ["tail.txt#2"], "end"), concern(2, ["tail.txt#1"], "start"))
        self.repo.git("switch", "-q", "-c", "clean", self.base)
        self.repo.run("build", self.map)
        self.assertEqual(self.repo.show("HEAD~1", "tail.txt"), "a\nb\nc\nd\ne\nf\ng\nh\nEND")
        self.assertEqual(self.repo.show("HEAD", "tail.txt"), "A\nb\nc\nd\ne\nf\ng\nh\nEND")

    def test_build_separates_changes_one_unchanged_line_apart(self):
        self.repo.git("switch", "-q", "main")
        self.repo.write("near.txt", "a\nb\nc\n")
        self.base = self.repo.commit("near base")
        self.repo.git("switch", "-q", "-c", "near")
        self.repo.write("near.txt", "A\nb\nC\n")
        self.orig = self.repo.commit("near change")
        self.write_map(concern(1, ["near.txt#2"], "last"), concern(2, ["near.txt#1"], "first"))
        self.repo.git("switch", "-q", "-c", "clean", self.base)
        self.repo.run("build", self.map)
        self.assertEqual(self.repo.show("HEAD~1", "near.txt"), "a\nb\nC\n")
        self.assertEqual(self.repo.show("HEAD", "near.txt"), "A\nb\nC\n")

    def test_build_applies_bare_insertions_and_deletions_separately(self):
        self.repo.git("switch", "-q", "main")
        self.repo.write("near.txt", "a\nb\nc\nd\n")
        self.base = self.repo.commit("near base")
        self.repo.git("switch", "-q", "-c", "near")
        self.repo.write("near.txt", "start\na\nb\nd\nend\n")
        self.orig = self.repo.commit("near change")
        self.write_map(concern(1, ["near.txt#2"], "delete"), concern(2, ["near.txt#1,3"], "insert"))
        self.repo.git("switch", "-q", "-c", "clean", self.base)
        self.repo.run("build", self.map)
        self.assertEqual(self.repo.show("HEAD~1", "near.txt"), "a\nb\nd\n")
        self.assertEqual(self.repo.show("HEAD", "near.txt"), "start\na\nb\nd\nend\n")

    def test_verify_names_paths_that_depart_from_the_map(self):
        self.write_map(concern(1, ["app.txt", "new.txt", "old.txt"], "one"))
        self.repo.git("switch", "-q", "-c", "clean", self.base)
        self.repo.run("build", self.map)
        self.assertEqual(self.repo.run("verify", self.map).returncode, 0)
        self.repo.write("new.txt", "edited\n")
        self.repo.write("extra.txt", "extra\n")
        self.repo.commit("stray")
        result = self.repo.run("verify", self.map)
        self.assertEqual((result.returncode, result.stdout), (1, "new.txt\nextra.txt\n"))

    def test_stage_sets_the_tree_for_concerns_up_to_n(self):
        self.write_map(concern(1, ["app.txt#1"], "one"), concern(2, ["app.txt#2,3", "new.txt", "old.txt"], "two"))
        self.repo.git("switch", "-q", "-c", "clean", self.base)
        self.repo.run("stage", self.map, "2")
        self.repo.run("stage", self.map, "1")
        self.assertEqual(self.repo.git("diff", "--cached", "--name-only"), "app.txt\n")
        with open(os.path.join(self.tmp.name, "app.txt")) as f:
            self.assertEqual(f.read(), WITH_FIRST)


if __name__ == "__main__":
    unittest.main()
