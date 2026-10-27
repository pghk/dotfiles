# /// script
# requires-python = ">=3.11"
# dependencies = ["PyYAML==6.0.2", "markdown-it-py==3.0.0"]
# ///

import argparse
import json
from pathlib import Path
import re
from urllib.parse import unquote, urlsplit

from markdown_it import MarkdownIt
import yaml


def validate_frontmatter(text, directory_name):
    lines = text.splitlines(keepends=True)
    if not lines or lines[0].rstrip("\r\n") != "---":
        return "", ["SKILL.md must start with YAML frontmatter delimited by ---."]
    closing = next(
        (index for index in range(1, len(lines)) if lines[index].rstrip("\r\n") == "---"),
        None,
    )
    if closing is None:
        return "", ["YAML frontmatter needs a closing --- delimiter."]
    body = "".join(lines[closing + 1 :])
    try:
        fields = yaml.safe_load("".join(lines[1:closing]))
    except yaml.YAMLError as error:
        return body, [f"Invalid YAML frontmatter: {error}"]
    if not isinstance(fields, dict):
        return body, ["YAML frontmatter must be a mapping."]

    errors = []
    name = fields.get("name")
    if (
        not isinstance(name, str)
        or not 1 <= len(name) <= 64
        or re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name) is None
    ):
        errors.append(
            "name must be 1-64 lowercase letters, digits, or single separating hyphens."
        )
    elif name != directory_name:
        errors.append(f"name {name!r} must match directory {directory_name!r}.")
    description = fields.get("description")
    if (
        not isinstance(description, str)
        or not description.strip()
        or len(description) > 1024
    ):
        errors.append("description must be a nonempty string of at most 1024 characters.")
    return body, errors


def relative_targets(markdown):
    for token in MarkdownIt().parse(markdown):
        for child in token.children or []:
            target = None
            if child.type == "link_open":
                target = child.attrGet("href")
            elif child.type == "image":
                target = child.attrGet("src")
            if target:
                url = urlsplit(target)
                if not url.scheme and not url.netloc and url.path and not url.path.startswith("/"):
                    yield unquote(url.path)


def validate_skill(directory):
    entrypoint = directory / "SKILL.md"
    result = {
        "path": str(directory),
        "skill_bytes": None,
        "markdown_bytes": 0,
        "errors": [],
    }
    if not entrypoint.is_file():
        result["errors"].append(
            {"path": str(entrypoint), "message": "Expected a skill directory containing SKILL.md."}
        )
        return result

    try:
        paths = sorted(directory.rglob("*.md"))
        for path in paths:
            raw = path.read_bytes()
            text = raw.decode("utf-8")
            result["markdown_bytes"] += len(raw)
            if path == entrypoint:
                result["skill_bytes"] = len(raw)
                text, errors = validate_frontmatter(text, directory.name)
                result["errors"].extend(
                    {"path": str(path), "message": error} for error in errors
                )
            for target in relative_targets(text):
                if not (path.parent / target).exists():
                    result["errors"].append(
                        {"path": str(path), "message": f"Relative link target does not exist: {target}"}
                    )
    except (OSError, UnicodeError, ValueError) as error:
        result["errors"].append({"path": str(directory), "message": str(error)})
    return result


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Validate selected skill directories: required YAML fields and names, "
            "relative Markdown links/images in bundled .md files, and byte sizes. "
            "Links are checked for target existence, not heading anchors. "
            "Print JSON; exit 0 when valid, 1 for validation errors, 2 for usage errors."
        )
    )
    parser.add_argument("directories", nargs="+", type=Path, help="Directories containing SKILL.md")
    arguments = parser.parse_args()
    skills = [
        validate_skill(directory.expanduser().absolute())
        for directory in arguments.directories
    ]
    valid = all(not skill["errors"] for skill in skills)
    print(json.dumps({"valid": valid, "skills": skills}, indent=2))
    return 0 if valid else 1


if __name__ == "__main__":
    raise SystemExit(main())
