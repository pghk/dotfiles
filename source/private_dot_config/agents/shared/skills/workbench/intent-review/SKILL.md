---
name: intent-review
description: >
  Manually review whether bounded work expresses its governing intent accurately and sufficiently across its artifacts, and propose corrections.
disable-model-invocation: true
---

# Intent Review

Use only when the user explicitly invokes this skill. Conduct a read-only review using [Express Intent](../../principles/principle-express-intent/SKILL.md); propose corrections without editing files, committing, or rewriting history.

## Establish scope and intent

Accept an explicit commit or range, staged or unstaged changes, or a bounded set of authored artifacts. Ask when the requested surface is ambiguous. Pin Git revisions when applicable; inspect uncommitted work in the requested index or working-tree state. Named artifacts need no Git history.

Establish purpose, required behavior, constraints, and material reasoning from governing sources: the user's statements, accepted specifications and decisions, tickets, and a concern map or past sessions when relevant. Retain the source of each intent item. Messages and implementation are evidence to assess against that authority. Ask before judging an item whose governing intent is unresolved.

## Check expression

For each established item, identify the artifacts its readers need and inspect their actual contents and relationships. Check for sufficient expression, omissions, contradictions, misleading representations, and information placed where its reader will not find it. Adequate code structure can carry an item without prose. Do not demand an addition to every artifact or expand into unrelated code-quality review.

Review directly unless independent breadth justifies delegation under the active agent instructions. For an authorized delegated slice, use [references/intent-review-brief.md](references/intent-review-brief.md) with its explicit scope, governing sources, and the paths of this procedure and the principle.

## Report proposed corrections

State the reviewed scope and governing sources. Group findings by affected work, with commit attribution when applicable. For each finding, provide:

- The intent item and its source.
- The affected path or message, quoted evidence or the inspected location of an omission, and what its reader cannot recover or would misunderstand.
- The smallest correction. Draft proposed prose fully; for a structural change, identify the names or structure to change, the intent it makes apparent, the behavior to preserve, and how to check preservation.

Summarize sufficient expression without producing an exhaustive inventory. Distinguish source inspection from behavioral observation, and state unresolved intent, uninspected relevant material, or unverified effects as uncertainty rather than findings. Leave corrections as proposals for separately requested work.
