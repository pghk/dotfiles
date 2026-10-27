---
name: skill-management
description: >
  Create, update, review, or maintain Agent Skills and their SKILL.md files, including fixing a skill's description or diagnosing why a skill did or did not trigger.
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
| `description` | Yes | 1–1024 chars. The trigger, as short as it can be; see [Descriptions](#descriptions). |
| `license` | No | License name or bundled file reference |
| `compatibility` | No | Environment requirements (product, packages, network) |
| `metadata` | No | Arbitrary key-value pairs |
| `allowed-tools` | No | Space-separated pre-approved tools (experimental) |

## Creating a skill

1. Establish the observed failure or recurring gap the skill should address. Apply [Express Intent](../principles/principle-express-intent/SKILL.md) when deciding which method lessons belong in the skill.
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
7. Track the change: skills live under `~/.config/agents`, which is not a git repository. Follow [Tracking changes](../../README.md#tracking-changes).

## Descriptions

The description is the **only** discovery mechanism. The listing shows each skill's name and description at startup; the body loads only after the model invokes the skill. The model matches the current task against the listing, so a description needs only enough to be picked over the other listed skills.

A description must carry no more than it takes to win that match:

- **Start from the name.** A name that says what the skill does (`bug-fix`, `to-tickets`, `commit`) is matched on its own. Add only what the name lacks.
- **State the trigger, not the contents.** One clause or a keyword list, such as `review tests, audit tests, test plan, before rewriting tests`. A comma list of keywords triggers as reliably as a full sentence. Leave out what the skill finds, produces, or contains; the body covers that.
- **Spend extra characters only on discrimination.** Name the trigger that separates the skill from its nearest overlapping neighbour (`dig` against `why`), or the scope limit that stops it firing on near-miss tasks. Both are worth their cost; repeated phrasings, example queries, and "even if they don't mention X" clauses are not.
- **Size.** Aim for 150–250 characters; the hard limit is 1024. Harnesses may cap the combined size of all listed descriptions and drop the ones that do not fit; the harness instructions give the limit. A skill with `disable-model-invocation: true` is not listed and is exempt.

These rules come from trigger tests on Copilot CLI 1.0.95 with Sonnet 5.5, where a keyword list matched a full sentence, and an empty description still triggered on every skill whose name is self-describing except the one that overlaps a neighbour.

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
