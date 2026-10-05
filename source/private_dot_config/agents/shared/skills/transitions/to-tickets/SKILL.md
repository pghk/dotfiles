---
name: to-tickets
description: "Use when the user explicitly asks to turn a specification into tickets, such as ‘turn this spec into tickets’. Decompose the accepted spec into vertical tracer-bullet ticket files; do not implement or route the work."
license: MIT
metadata:
  source: "https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd/skills/engineering/to-tickets"
  upstream-revision: "74ca5fe077456a0b3b2f5310cf9430999fd0b5fd"
  provenance: "adapted-from-upstream"
---

# To Tickets

This transition adopts ticket decomposition as the current session goal and
makes the resulting tickets authoritative for execution slices and dependencies.
It is not a router or implementation workflow. Activate it for
`/skill:to-tickets` or an unambiguous request such as “turn this spec into
tickets”. Do not activate it for general planning, design, or delivery requests.

## Accept the specification

Treat invocation as acceptance of the current specification for decomposition.
Consume an identified specification, or the clearly current
`docs/plans/YYYY-MM-DD-<slug>/spec.md`. If more than one candidate is current
or the source is unclear, ask for its path; do not guess. Do not rewrite the
specification, create an ADR, publish externally, or integrate with an issue
tracker.

## Inspect and settle slicing decisions

Inspect the relevant repository structure, domain vocabulary, existing
boundaries, accepted target state, and applicable references before deciding
slices. Derive ticket boundaries from the target ownership and behavior, not
automatically from the current repository layout; existing files and modules
are evidence about the starting point, not default delivery boundaries.
Discuss only choices where user judgment materially changes the decomposition:

- vertical boundaries and genuine end-to-end value;
- genuine blockers and execution order;
- prerequisite refactors or migrations;
- architecture, interfaces, or compatibility shared by several tickets;
- whether a slice should be merged or split.

Record settled cross-ticket choices in the affected ticket constraints or
references. When the specification fixes a target structure or ownership map,
make establishing it an explicit deliverable or prerequisite so dependent
tickets cannot independently extend the old structure. Exact accepted paths,
names, moves, merges, and removals are decisions rather than speculative file
inventories. Use an ADR instead when a long-lived architectural trade-off must
be understood independently of this delivery.

Ask independent questions together in one compact round. Defer questions whose
answer depends on an earlier decision until that decision is settled. Do not
present a complete proposed ticket graph merely for approval. Equivalent local
implementation mechanics belong to the implementer.

Tickets are vertical tracer bullets: each delivers observable end-to-end
behavior, fits one fresh implementation context, and names only genuine
blocking dependencies. Judge independence by behavior, not file ownership: a
ticket's acceptance must pass against its declared predecessors. If a scenario
asserts behavior introduced by another ticket, add that dependency or keep the
scenario with the ticket that owns the behavior. For criteria using “all,”
“any,” “every,” or “only,” identify materially distinct paths that can satisfy
or violate the claim; one representative is sufficient only when those paths
share the same owner and decision logic. A wide mechanical change that cannot
remain green as a vertical slice may use an explicit expand–migrate–contract
sequence; migration batches must remain coherent slices where possible.

## Write tickets

After material slicing decisions are settled, write one stable contract per
ticket, numbered in dependency order, at:

`docs/plans/YYYY-MM-DD-<slug>/tickets/NN-<ticket>.md`

Use this shape:

```markdown
# NN: <Ticket title>

## Delivered outcome

<Observable end-to-end behavior this ticket makes possible.>

## Acceptance criteria

- <Observable scenario and result.>
- <Observable scenario and result.>

## Repository context and references

<Relevant existing paths, symbols, domain terms, or authoritative artifacts a
fresh implementer needs. Omit speculative file inventories.>

## Constraints

<Required boundaries and decisions; omit routine implementation steps and source
code.>

## Blocked by

- <NN: ticket title>, or `None`
```

Ticket files contain no mutable status, execution claims or evidence,
frontmatter, issue-tracker fields, or external identifiers. Include only the
delivered outcome, observable acceptance criteria, relevant repository
context/references, constraints, and blocked-by relationships. Acceptance must
be testable or otherwise observable; avoid layer-by-layer task lists and
step-by-step implementation instructions.

## Self-check and finish

Before finishing, check every specification behavior, constraint, and preserved
concrete decision is covered; each ticket has independent value and fits a
fresh context; boundaries follow the target state rather than the current
layout; universal claims distinguish materially different paths; acceptance is
observable; and dependencies are genuine and acyclic. Check that the dependency
frontier establishes shared target structure before parallel work can create
competing local patterns. Check links and ticket numbering. Correct
source-at-rest properties belong in Constraints, not invented runtime tests.

Stop after writing. Report the ticket paths and dependency frontier. Do not
invoke `implement` automatically; a later explicit `implement` invocation
accepts these tickets.
