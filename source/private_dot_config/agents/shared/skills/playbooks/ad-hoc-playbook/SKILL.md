---
name: ad-hoc-playbook
description: "Use only when explicitly invoked for substantial, unusual, multi-part work that no narrower playbook fits. Design and execute one bounded playbook for that task; do not use for routine implementation, ordinary bug fixes, refactors, specs, or covered ticket work."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/figure-it-out"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "renamed-and-adapted-from-upstream"
disable-model-invocation: true
---

# Ad-hoc Playbook

Use this playbook only after an explicit invocation for substantial, unusual,
multi-part work that no narrower playbook fits. It is manual-only and is not an
automatic fallback or universal router. Do not use it for routine feature
implementation, ordinary bug fixes, refactors, specifications, or ticket
execution already covered by a narrower skill.

Invoking this skill authorizes designing and executing the one-off playbook for
that task. If the user asks only for the workflow, design it and stop before
execution.

## Frame the work

First inspect the current transition, playbook, and principle shelf. Compose the
authorities that actually apply before inventing procedure. Use the narrowest
existing transition for the execution boundary; this playbook does not replace
its execution rules.

State the exact falsifiable outcome, approved scope and constraints, material
unknowns, and risk. Identify what would count as evidence and what remains
unobservable. Do not manufacture durable artifacts or a separate plan packet by
default. Surface material tradeoffs before a long or consequential run and
align on decisions that change product intent, system design, external state, or
are costly to undo. After alignment, continue through reversible authorized
work without routine continuation checkpoints.

## Shape a bounded run

Design a short sequence of vertical experiments or units. Put the riskiest
unknown early when resolving it can change the rest of the run. For every unit,
name:

- the hypothesis or intended outcome;
- the smallest change or action;
- the credible observation at the relevant boundary; and
- the keep, revert, revise, or stop result.

Prefer subtraction and the smallest mechanism that can establish the outcome.
Compose [Subtract Before You Add](../../principles/principle-subtract-before-you-add/SKILL.md)
when shaping the workflow. Compose [Build the Lever](../../principles/principle-build-the-lever/SKILL.md)
only when substantial repeated work deserves a reusable tool. Focused skills
load only when their actual triggers apply.

Use [show-your-work](../../continuity/show-your-work/SKILL.md) only when breadth,
duration, delegation, multiple sessions, unattended work, or audit difficulty
makes a durable decision trail worthwhile. Keep one compact trail when used;
do not create a universal ledger.

## Execute and adapt

Use the [implement transition](../../transitions/implement/SKILL.md) for
execution topology, ready work, integration, conditional review, and commits.
Do not reproduce its runtime or delegation rules here.

Run each unit's observation before stacking further work. Keep advances. Revert
or revise failed experiments, and update the remaining sequence when evidence
changes dependencies. Do not silently widen approved scope: surface a new
material tradeoff and align before proceeding. Stop when the outcome is
falsified, a constraint is violated, evidence is unavailable, or the next step
requires an unapproved consequential decision.

## Finish with evidence

Compose [Prove It Works](../../principles/principle-prove-it-works/SKILL.md) for
final claims. Check the overall outcome on the real artifact or environment,
not only on an intermediate probe. Report the concise evidence, material
limits, kept or reverted units, commits, and—if used—the decision-trail path.
Leave no durable workflow artifact unless it is useful to the task or requested
by the user.
