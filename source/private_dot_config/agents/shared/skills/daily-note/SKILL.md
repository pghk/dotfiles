---
name: daily-note
description: "Read or write a section of the user's daily note for a date."
---

# Daily note

The note for a date is `$NOTES_DIR/Daily/YYYY-MM-DD.md`. Read it there.

Write a level-two section by passing its body on stdin, resolving the script path from this skill's directory:

```sh
python3 <skill-dir>/scripts/section.py --date YYYY-MM-DD --section Summary <<'EOF'
- body
EOF
```

The script creates a bare note when none exists, replaces the named section through the next level-one or level-two heading, or appends it when absent. The rest of the note is unchanged. The body must not contain level-one or level-two headings. Replacing discards the section's current body, so read the note first when that content should be kept.

The script prints the note path and whether it was created, updated, or unchanged. On failure, report its error and leave the note alone.

Run the tests with `python3 <skill-dir>/scripts/test_section.py`.
