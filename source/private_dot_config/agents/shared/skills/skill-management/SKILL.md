---
name: skill-management
description: >
  Create, update, review, or maintain Agent Skills. Use when asked to "create a skill", "make a new skill", "scaffold a skill", "update a skill", "edit a skill", "improve a skill", "add a skill", or when modifying SKILL.md files or skill directories. Also use when asked to fix a skill's description, improve discoverability, or add scripts to a skill. Also use when evaluating why a skill did or did not trigger, or diagnosing whether a trigger change would fix a recurring gap.
---

# Skill Authoring

Self-contained guide for creating and updating Agent Skills from any working directory.

## Skill structure

```
skill-name/
├── SKILL.md          # Required: frontmatter + instructions
├── scripts/          # Optional: executable scripts
├── references/       # Optional: detailed docs, loaded on demand
└── assets/           # Optional: templates, static resources
```

Measure `SKILL.md` in bytes (`wc -c`), not lines: prose here is unwrapped, so a line is a paragraph and line count tracks nothing. A loaded skill is billed its full size on every turn it stays resident, so the expensive skills are the ones a long-running agent holds throughout a run — a workflow skill held for 400 turns costs its size 400 times, while a skill read once and exited costs it once. Keep the resident kind smallest. Move lookup material to `references/`, which is billed only from the turn it is read.

## Frontmatter fields

| Field | Required | Constraints |
| --- | --- | --- |
| `name` | Yes | 1–64 chars, lowercase letters/numbers/hyphens, no leading/trailing/consecutive hyphens, must match folder name |
| `description` | Yes | 1–1024 chars. What it does and when to use it. Include keywords. |
| `license` | No | License name or bundled file reference |
| `compatibility` | No | Environment requirements (product, packages, network) |
| `metadata` | No | Arbitrary key-value pairs |
| `allowed-tools` | No | Space-separated pre-approved tools (experimental) |

## Creating a skill

1. Establish the observed failure or recurring gap the skill should address.
2. Match the guidance form to that failure: use concise rules for judgment calls, structured steps for techniques, and references for lookup material. When drafting or restructuring instructions or context pointers, read [references/writing-for-agents.md](references/writing-for-agents.md).
3. Create folder: `<skills-dir>/<skill-name>/`
4. Write `SKILL.md` (frontmatter + instructions)
5. Add `references/`, `scripts/`, or `assets/` as needed

Minimal `SKILL.md`:

```yaml
---
name: skill-name
description: "What it does. Use when <triggers and keywords>."
---
```

## Updating a skill

1. Read the existing `SKILL.md`
2. Identify what changed: description accuracy, instruction gaps, stale content. If the request questions the skill's approach or efficacy rather than naming a specific gap, settle the design with `brainstorming` before editing.
3. Edit in place — full rewrite only if scope has fundamentally changed
4. Name what the edit makes redundant and remove it: text the new guidance subsumes, a restatement of a bundled asset or reference, or a rule the addition now covers. A skill that only ever grows is accreting — each addition answered a real failure, and none of them is why the skill became expensive to load.
5. If the description no longer reflects actual triggers, revise it (see [Descriptions](#descriptions))
6. Report the byte count before and after. Where the file grew, say what was removed to pay for it, or state that nothing was.

## Descriptions

The description is the **only** discovery mechanism. It loads at startup for every skill; the body only loads if the description matches the task.

Principles:

- **Write for activation, not summary.** Describe the situation that should trigger the skill, not what it contains.
- **Use imperative phrasing.** "Use when…" not "This skill does…"
- **Include keywords** a user might say — direct and indirect.
- **Be specific about scope.** Name what it does _not_ cover if adjacent skills exist.
- **Be pushy.** Explicitly list edge cases: "even if they don't mention X directly."
- Stay under 1024 characters.

Read [references/descriptions.md](references/descriptions.md) when you need to test whether a description triggers reliably or optimize an existing one.

## Scripts

Bundle reusable scripts in `scripts/`. Reference via relative paths from the skill root:

```markdown
Run: `bash scripts/validate.sh "$INPUT_FILE"`
```

Design scripts for agentic use:

- **No interactive prompts** — accept input via flags, env vars, or stdin
- **`--help` output** — primary interface the agent uses to learn available flags
- **Helpful errors** — "Expected X, got Y. Try: …" not "Error: invalid input"
- **Structured output** — JSON/CSV on stdout; diagnostics to stderr
- **Idempotent** — agents may retry; "create if not exists" over "fail on duplicate"
- **`--dry-run`** for destructive operations
- **Pin versions** in one-off commands (`npx eslint@9.0.0`, `uvx ruff@0.8.0`)

Read [references/scripts.md](references/scripts.md) when writing scripts or choosing a language/dependency approach.

## References

Load these on demand:

- [references/descriptions.md](references/descriptions.md) — Testing and optimizing descriptions for trigger accuracy; eval query design; the optimization loop
- [references/scripts.md](references/scripts.md) — Language-specific patterns (Python PEP 723, Deno, Bun), dependency management, full design guide
- [references/evaluating.md](references/evaluating.md) — Structured eval framework: test cases, assertions, grading, benchmarking, iteration; compare baselines and account for evaluation cost
- [references/writing-for-agents.md](references/writing-for-agents.md) — Writing instructions, descriptions, and context pointers for agent consumption; load when drafting or restructuring them
