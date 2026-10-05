---
name: how
description: >
  Explain how a system, subsystem, feature, request, or code path works when
  the user asks “how does X work?”, requests a runtime or code walkthrough,
  or needs ownership, placement, layering, lifecycle, or a subsystem mental
  model. Trace present mechanics and cite real paths and symbols. Do not use
  for historical motivation, design rationale, or tradeoffs (use why), or for
  a pedagogical synthesis (use teach).
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/how"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
---

# How

Explain present operation and ownership. Build a bounded mental model of the
thing the user named, not a code dump or an exhaustive caller inventory.

## Establish the behavior

Start with the observable behavior when it is practical: identify the
stimulus, the visible result, and the boundary at which that result can be
observed. Use a focused test, command, log, request, or other cheap credible
probe when one exists. Then trace the implementation that accounts for it.
If behavior cannot be run, say so and treat source inspection as the evidence
for mechanics rather than claiming runtime confirmation.

## Trace the mechanics

Answer the parts that matter to the question:

- **Purpose and authoritative boundary:** what this component owns, and which
  file, symbol, schema, configuration, or external contract is authoritative.
- **Inputs and outputs:** what enters and leaves, including transformations,
  errors, side effects, and observable effects.
- **Flow and layering:** the runtime, control, or data path in causal order;
  identify where each hand-off occurs and which layer owns it.
- **State and lifecycle:** initialization, mutation, persistence, cleanup,
  retries, caching, concurrency, and relevant terminal states.
- **Dependencies and placement:** which dependency supplies each behavior,
  where ownership changes, and what boundary remains unverified.

Cite reachable repository paths and symbols (for example,
`src/router.ts:dispatch`), plus the command or test used for an observation.
Separate **fact** (directly observed in a run or source), **inference** (the
best explanation supported by those facts), and **unknown** (the evidence did
not establish). Name unverified integration, environment, or dependency
boundaries instead of filling them with assumptions.

## Keep the boundary

This skill owns the present mechanics: purpose, authority, inputs/outputs,
flow, state, dependencies, ownership, and effects. Do not explain historical
motivation, rejected alternatives, regressions, or tradeoffs; route those
questions to [why](../why/SKILL.md). If the user needs a learning sequence or
is asking “teach me” or “help me understand,” route to [teach](../teach/SKILL.md).
Do not require a multi-agent investigation, a fixed report, or broad follow-up
work. Scale probing and tracing to the question and consequence, and stop
once the named behavior is explained with bounded evidence.
