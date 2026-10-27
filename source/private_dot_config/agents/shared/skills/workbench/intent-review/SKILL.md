---
name: intent-review
description: >
  Manually review whether bounded work expresses its governing intent accurately and sufficiently across its artifacts, and propose corrections.
disable-model-invocation: true
---

# Intent Review

Use only when the user explicitly invokes this skill. Conduct a read-only review using [Express Intent](../../principles/principle-express-intent/SKILL.md); propose corrections without editing files, committing, or rewriting history.

The review asks whether a future reader can discover each intent item where they would look: in code names and structure, tests, docs, comments, or messages. Whether the implementation behaves as intended is a separate review; do not hunt for defects or verify behavior against intent.

## Establish scope and intent

Accept an explicit commit or range, staged or unstaged changes, or a bounded set of authored artifacts. Ask when the requested surface is ambiguous. Pin Git revisions when applicable; inspect uncommitted work in the requested index or working-tree state. Named artifacts need no Git history.

Establish purpose, required behavior, constraints, and material reasoning from governing sources: the user's statements, accepted specifications and decisions, tickets, a survey-branch concern map at `.notes/<slug>/map.md`, and the sessions that produced the work. Derive the intent items from those sources before reading the implementation; the diff locates artifacts, not items. Retain the source of each intent item. Governing sources, messages, and implementation are evidence to assess against that authority, not review targets; review only artifacts in the requested scope. Ask before judging an item whose governing intent is unresolved.

## Check expression

Before judging, list each intent item with the artifacts its reader would consult (code names and structure, tests, docs, comments, messages, skills), and mark each inspected and sufficient, deficient, or not inspected. Before proposing a comment, state the structural alternative weighed.

For each established item, inspect those artifacts' actual contents and relationships. Check for sufficient expression, omissions, contradictions, misleading representations, and information placed where its reader will not find it. Adequate code structure can carry an item without prose. Do not demand an addition to every artifact.

Review directly unless independent breadth justifies delegation under the active agent instructions. For an authorized delegated slice, use [references/intent-review-brief.md](references/intent-review-brief.md) with its explicit scope, governing sources, and the paths of this procedure and the principle.

## Report proposed corrections

State the reviewed scope, governing sources, and each intent item's artifact coverage, including what was not inspected. Group findings by affected work, with commit attribution when applicable. For each finding, provide:

- The intent item and its source.
- The affected path or message, quoted evidence or the inspected location of an omission, and what its reader cannot recover or would misunderstand.
- The smallest correction. Draft proposed prose fully; for a structural change, identify the names or structure to change, the intent it makes apparent, the behavior to preserve, and how to check preservation.

List suspected defects noticed in passing under a separate heading, one line each, uninvestigated. Summarize sufficient expression without producing an exhaustive inventory. Distinguish source inspection from behavioral observation, and state unresolved intent, uninspected relevant material, or unverified effects as uncertainty rather than findings. Leave corrections as proposals for separately requested work.
