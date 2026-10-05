---
name: why
description: >
  Explain why a system, subsystem, feature, or code shape works this way when
  the user asks “why does X work this way?”, asks for design rationale,
  historical choices, regressions, postmortems, or evidence-backed tradeoffs.
  Establish the decision and reconstruct its rationale from reachable evidence.
  Do not use for present runtime mechanics (use how) or a learning sequence
  (use teach).
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/why"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
---

# Why

Recover rationale, history, and tradeoffs without inventing institutional
memory. This skill owns why a decision or shape exists, not a walkthrough of
how the current system executes. Use [how](../how/SKILL.md) for present
mechanics and [teach](../teach/SKILL.md) when the goal is a pedagogical
synthesis.

## Establish the decision

First state what decision, constraint, or code shape needs explaining and what
would count as an answer. Identify the relevant current implementation,
behavior, regression, or boundary so the history is attached to a real thing.
Do not assume the current shape is the original decision: record later fixes,
workarounds, and changed constraints separately.

## Gather reachable evidence

Use the cheapest sources that can discriminate among explanations:

- current code, configuration, schemas, and dependency contracts;
- commits, blame, branches, reflog, and commit-linked artifacts;
- ADRs, design notes, documentation, tests, and regression tests;
- issue, chat, analytics, or observability evidence only when the user names
  that source or the current environment exposes a relevant reachable artifact.

When commit-history archaeology is material, use the existing
[dig](../../dig/SKILL.md) skill rather than recreating its search strategy. Do not
require every evidence category, add integration wiring, or turn a bounded
question into a repository-wide census. Establish observable behavior first
when the claimed rationale depends on it, then inspect the evidence explaining
that behavior.

## Separate evidence from explanation

Report the result in three layers:

1. **Established rationale:** directly supported by a reachable source; cite
   the exact path, symbol, commit, test, or artifact.
2. **Plausible inference:** a reason supported by the shape of the evidence but
   not stated or proven; label it as inference and explain the link.
3. **Unknown:** evidence does not establish why. Say what remains unknown and
   name the observation or source that would settle it.

Explain the chosen tradeoff and rejected constraints only when the evidence
supports them. Distinguish the original constraint from present-day effects;
current code can show what a choice protects, but not by itself who chose it
or why. A regression or postmortem needs the observed failure, the causal
change supported by evidence, and the limit of the reconstruction.

Keep citations reachable and conclusions bounded. Never supply a plausible
story as fact, claim access to unavailable institutional context, or use a
mechanics dump as a substitute for rationale. Stop when the decision is
explained or the evidence boundary is explicit; do not require broad follow-up
work or a fixed investigation ceremony.
