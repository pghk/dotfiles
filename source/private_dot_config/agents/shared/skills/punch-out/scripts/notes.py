#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["markdown-it-py>=3,<5"]
# ///
"""Inspect or refresh a daily note's Summary section without changing other sections."""

import argparse
from datetime import date
import hashlib
import json
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile
import time
from urllib.parse import quote, urlencode

from markdown_it import MarkdownIt


def load_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def vault_path(explicit):
    if explicit:
        vault = explicit.expanduser().resolve()
        if not (vault / ".obsidian").is_dir():
            raise ValueError(f"Not an Obsidian vault: {vault}")
        return vault
    registry = load_json(
        Path.home() / "Library/Application Support/obsidian/obsidian.json"
    )["vaults"]
    opened = [Path(item["path"]) for item in registry.values() if item.get("open")]
    if len(opened) != 1:
        raise ValueError("Select one Obsidian vault with --vault PATH.")
    return opened[0].resolve()


def inside_vault(vault, relative):
    path = (vault / relative).resolve()
    if not path.is_relative_to(vault):
        raise ValueError(f"Path leaves the vault: {relative}")
    return path


def daily_settings(vault):
    config = vault / ".obsidian"
    periodic = config / "plugins/periodic-notes/data.json"
    enabled = load_json(config / "community-plugins.json")
    if "periodic-notes" in enabled and periodic.exists():
        settings = load_json(periodic).get("daily", {})
        if settings.get("enabled"):
            return settings
    core = load_json(config / "core-plugins.json")
    if isinstance(core, dict):
        core_enabled = core.get("daily-notes", False)
    else:
        core_enabled = "daily-notes" in core
    if core_enabled:
        settings_file = config / "daily-notes.json"
        return load_json(settings_file) if settings_file.exists() else {}
    raise ValueError("Enable daily notes in Periodic Notes or Obsidian Daily Notes.")


def daily_path(vault, settings, day):
    if settings.get("format") not in (None, "", "YYYY-MM-DD"):
        raise ValueError("punch-out requires the daily-note format YYYY-MM-DD.")
    return inside_vault(vault, Path(settings.get("folder") or "") / f"{day}.md")


def digest(content):
    return hashlib.sha256(content).hexdigest()


def snapshot(path):
    return digest(path.read_bytes()) if path.exists() else "missing"


def headings(content):
    lines = content.splitlines(keepends=True)
    frontmatter_end = 0
    if lines and lines[0].rstrip("\r\n") == "---":
        for index, line in enumerate(lines[1:], 1):
            if line.rstrip("\r\n") in ("---", "..."):
                frontmatter_end = index + 1
                break
    offsets = [0]
    for line in lines:
        offsets.append(offsets[-1] + len(line))
    tokens = MarkdownIt().parse("".join(lines[frontmatter_end:]))
    result = []
    for index, token in enumerate(tokens):
        if token.type == "heading_open" and token.level == 0:
            result.append(
                (
                    offsets[token.map[0] + frontmatter_end],
                    int(token.tag[1:]),
                    tokens[index + 1].content,
                )
            )
    return result


def refresh_section(content, summary):
    sections = headings(content)
    matching = [
        (index, offset)
        for index, (offset, level, title) in enumerate(sections)
        if level == 2 and title == "Summary"
    ]
    if len(matching) > 1:
        raise ValueError("Multiple Summary sections; consolidate them before updating.")
    newline = "\r\n" if "\r\n" in content else "\n"
    body = summary.replace("\r\n", "\n").strip().replace("\n", newline)
    replacement = f"## Summary{newline}{newline}{body}{newline}"
    if not matching:
        separator = newline * 2
        if not content or content.endswith(newline * 2):
            separator = ""
        elif content.endswith(newline):
            separator = newline
        return content + separator + replacement
    index, start = matching[0]
    end = next(
        (offset for offset, level, _ in sections[index + 1 :] if level <= 2),
        len(content),
    )
    if end < len(content):
        replacement += newline
    return content[:start] + replacement + content[end:]


def create_note(vault, path, settings, timeout):
    template = settings.get("template")
    if not template:
        raise ValueError("Configure a daily-note template before creating a note.")
    template_path = inside_vault(
        vault, template if template.endswith(".md") else template + ".md"
    )
    content = template_path.read_text(encoding="utf-8")
    if "<%" in content:
        plugins = load_json(vault / ".obsidian/community-plugins.json")
        templater = vault / ".obsidian/plugins/templater-obsidian/data.json"
        if "templater-obsidian" not in plugins or not load_json(templater).get(
            "trigger_on_file_creation"
        ):
            raise ValueError("Enable Templater's trigger on new file creation.")
    registry = load_json(
        Path.home() / "Library/Application Support/obsidian/obsidian.json"
    )["vaults"]
    identifiers = [
        identifier
        for identifier, item in registry.items()
        if Path(item["path"]).resolve() == vault
    ]
    if len(identifiers) != 1:
        raise ValueError("Register this vault in Obsidian before creating its daily note.")
    uri = "obsidian://new?" + urlencode(
        {
            "vault": identifiers[0],
            "file": str(path.relative_to(vault)),
            "content": content,
            "silent": "true",
        },
        quote_via=quote,
    )
    subprocess.run(["open", uri], check=True, capture_output=True)
    deadline = time.monotonic() + timeout
    previous = None
    while time.monotonic() < deadline:
        if path.exists():
            current = path.read_bytes()
            if current and b"<%" not in current and current == previous:
                return current
            previous = current
        time.sleep(0.3)
    raise ValueError(f"Daily-note creation/template rendering did not finish: {path}")


def update_note(vault, day, summary, expected_hash, timeout):
    if not summary.strip():
        return {"status": "unchanged", "reason": "empty summary"}
    if any(level <= 2 for _, level, _ in headings(summary)):
        raise ValueError("Supply the section body, without level-one or level-two headings.")
    settings = daily_settings(vault)
    path = daily_path(vault, settings, day)
    if path.exists():
        original = path.read_bytes()
        if digest(original) != expected_hash:
            raise ValueError("Daily note changed; inspect it again before updating.")
        if b"<%" in original:
            raise ValueError("Daily-note template is still unrendered; leave it unchanged.")
    else:
        if expected_hash != "missing":
            raise ValueError("Daily note changed; inspect it again before updating.")
        original = create_note(vault, path, settings, timeout)
    updated = refresh_section(original.decode("utf-8"), summary).encode("utf-8")
    if updated != original:
        temporary = None
        try:
            with tempfile.NamedTemporaryFile(
                dir=path.parent, prefix=".punch-out-", suffix=".tmp", delete=False
            ) as stream:
                temporary = Path(stream.name)
                stream.write(updated)
                os.fchmod(stream.fileno(), stat.S_IMODE(path.stat().st_mode))
            if path.read_bytes() != original:
                raise ValueError("Daily note changed while preparing the update; retry.")
            temporary.replace(path)
        finally:
            if temporary and temporary.exists():
                temporary.unlink()
    if path.read_bytes() != updated:
        raise ValueError("Daily note changed after saving; inspect the saved section.")
    return {"status": "updated" if updated != original else "unchanged", "path": str(path)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    subcommands = parser.add_subparsers(dest="command", required=True)
    for command in ("inspect", "update"):
        command_parser = subcommands.add_parser(command)
        command_parser.add_argument("--date", type=date.fromisoformat, default=date.today())
        command_parser.add_argument("--vault", type=Path)
        if command == "update":
            command_parser.add_argument("--summary", type=Path, required=True)
            command_parser.add_argument("--expected-hash", required=True)
            command_parser.add_argument("--timeout", type=float, default=30)
    args = parser.parse_args()
    try:
        vault = vault_path(args.vault)
        if args.command == "inspect":
            path = daily_path(vault, daily_settings(vault), args.date)
            result = {"date": str(args.date), "path": str(path), "hash": snapshot(path)}
        else:
            result = update_note(
                vault,
                args.date,
                args.summary.read_text(encoding="utf-8"),
                args.expected_hash,
                args.timeout,
            )
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        print(str(error), file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
