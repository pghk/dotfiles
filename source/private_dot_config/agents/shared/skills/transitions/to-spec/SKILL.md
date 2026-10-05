---
name: to-spec
description: "Use when the user explicitly asks to turn the current conversation or request into a spec, such as ‘turn this into a spec’. Synthesize a local Markdown specification; do not route or implement the work."
license: MIT
metadata:
  source: "https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd/skills/engineering/to-spec"
  upstream-revision: "74ca5fe077456a0b3b2f5310cf9430999fd0b5fd"
  provenance: "adapted-from-upstream"
---

# To Spec

This transition adopts specification writing as the current session goal and
makes the resulting specification durable authority for later work. It is not a
router or end-to-end workflow. Activate it for an explicit `/skill:to-spec`
invocation or an unambiguous request such as “turn this into a spec”. Do not
activate it for general planning, design, or delivery requests.

## Produce the specification

Synthesize the current conversation and relevant repository evidence into one
local Markdown file at:

`docs/plans/YYYY-MM-DD-<slug>/spec.md`

Use the repository's domain vocabulary and relevant ADRs when present. Keep
solution intent distinct from incidental repository mechanics. Preserve a
concrete decision when omitting it would permit a materially different outcome,
including selected boundaries, ownership, organization, interfaces, artifact
shape, or workflow; leave only interchangeable details to implementation and
let `to-tickets` surface consequential cross-ticket choices for discussion.
Apply [Subtract Before You Add](../../principles/principle-subtract-before-you-add/SKILL.md)
when determining solution scope and non-goals. Do not mutate `CONTEXT.md`,
create ADRs, publish externally, or add issue-tracker wiring. Do not require
frontmatter or packet identifiers.

Ask focused questions only when writing would otherwise invent product intent.
Do not conduct a broad interview by default. Write these sections:

- **Problem** — the user or system problem and its context.
- **Solution** — the intended product outcome, without incidental realization.
- **Behavior** — atomic cases by default; each states a scenario or precondition
  and its observable outcome. Add user stories only when they provide product
  context not already expressed by Problem or Solution.
- **Constraints** — required boundaries, compatibility, and relevant evidence.
- **Non-goals** — explicit exclusions.

Before finishing, trace every explicit user decision into the specification or
identify it as unresolved; do not replace a concrete decision with a broader
principle that permits a materially different result. For work that preserves
some behavior while changing other behavior, classify material claims as
**preserve**, **change**, or **unverified**, and verify current behavior when it
constrains implementation. Surface any conflict between a required outcome and
a preservation constraint. Then check completeness, contradictions,
unsupported assumptions, and unresolved product intent. Do not require
fresh-context review or a separate approval gate: a later explicit
`/skill:to-tickets` invocation accepts the current spec. Finish after writing
and report the spec path and any unresolved questions; do not invoke another
transition automatically.
