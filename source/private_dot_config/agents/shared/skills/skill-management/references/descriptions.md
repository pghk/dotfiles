# Optimizing Skill Descriptions

The description carries the entire burden of triggering. If it doesn't convey when the skill is useful, the agent won't reach for it.

One nuance: agents typically only consult skills for tasks beyond what they can handle alone. A simple one-step request may not trigger a skill even with a perfect description. Specialized knowledge, domain-specific workflows, and unfamiliar APIs are where description quality makes the difference.

## Designing trigger eval queries

Build a set of ~20 realistic prompts labeled `should_trigger: true/false`.

```json
[
  {
    "query": "I've got a spreadsheet in ~/data/q4.xlsx — can you add a profit margin column?",
    "should_trigger": true
  },
  {
    "query": "write a python script that reads a csv and uploads rows to postgres",
    "should_trigger": false
  }
]
```

### Should-trigger queries

Vary along these axes:

- **Phrasing** — formal, casual, typos, abbreviations
- **Explicitness** — some name the domain directly, others describe the need without naming it
- **Detail** — terse vs. context-heavy
- **Complexity** — single-step tasks alongside multi-step workflows

The most useful should-trigger queries are where the skill would help but the connection isn't obvious. These are the cases where description wording matters.

### Should-not-trigger queries (near-misses)

The most valuable negatives are **near-misses** — queries that share keywords but need something different. These test precision.

Weak: "Write a fibonacci function" — no overlap, tests nothing. Strong: "Can you write a python script that reads a csv and uploads each row to postgres?" — involves CSV but the task is ETL, not analysis.

### Making queries realistic

Include file paths, personal context, column names, casual language, typos. "Process this data" is too vague. "My manager asked me to analyze `~/Downloads/report_final_v2.csv` and highlight rows over budget" tests real conditions.

## Running the eval

For each query, run it with the skill installed and observe whether the skill was loaded through the client's skill-loading trace or tool history. When wording is the likely failure point, micro-test description variants before running expensive behavioral evals.

A query **passes** if:

- `should_trigger: true` and the skill was invoked, or
- `should_trigger: false` and the skill was not invoked.

**Model behavior is nondeterministic.** Run each query 3 times and compute a trigger rate. A should-trigger query passes if trigger rate > 0.5; a should-not-trigger query passes if trigger rate < 0.5.

Detection logic varies by agent client — check execution logs, tool call histories, or verbose output to see which skills were loaded during a run. The [spec's evaluation guide](https://agentskills.io/skill-creation/evaluating-skills) includes a sample shell script for clients that support JSON output.

## Avoiding overfitting

Split your query set:

- **Train (~60%)** — use to identify failures and guide improvements
- **Validation (~40%)** — hold out; check only whether improvements generalize

Keep the split fixed across iterations so you're comparing apples to apples.

## The optimization loop

1. Evaluate on train and validation sets
2. Identify failures in the **train set only**
   - Should-trigger failures → description too narrow; broaden scope or add context
   - Should-not-trigger failures → description too broad; add specificity or exclusions
3. Revise the description — address the general category, not the specific query (keyword-matching specific failed queries is overfitting)
4. Repeat until train set passes or improvement stalls
5. Select the best iteration by **validation pass rate** — the last iteration may have overfit

Five iterations is usually enough. If no improvement, the issue may be with the query set, not the description.

## Applying the result

1. Update `description` in `SKILL.md` frontmatter
2. Verify under 1024 characters
3. Sanity-check: run 5–10 fresh prompts (never part of the eval set)

Before/after example:

```yaml
# Before
description: Process CSV files.

# After
description: >
  Analyze CSV and tabular data files — compute summary statistics, add derived columns, generate charts, and clean messy data. Use this skill when the user has a CSV, TSV, or Excel file and wants to explore, transform, or visualize the data, even if they don't explicitly mention "CSV" or "analysis."
```
