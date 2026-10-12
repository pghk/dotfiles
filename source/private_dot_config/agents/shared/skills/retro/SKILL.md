---
name: retro
description: "Review the conversation and propose lasting improvements to skills, instructions, and tooling. Use for an explicit retro ('retro', 'what did we learn'). Suggest unprompted only after repeated corrections, rework, or mounting friction."
license: MIT
metadata:
  source: "https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd/skills/in-progress/retro"
  additional-source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/reflect"
  upstream-revision: "74ca5fe077456a0b3b2f5310cf9430999fd0b5fd"
  additional-source-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "local-composition"
---

# Retrospective

Review the active conversation or transcript, not a generic session summary.
Turn its evidence into lasting improvements: changes whose expected future
savings exceed their carrying cost. A removal is an improvement. A session
with no meaningful signal needs no ceremony.

## Build the effort ledger

List where this session spent effort a future session would spend again, as
concrete observations without diagnosis:

- agent effort on discovery or on recovering from failure: turns, tool calls,
  retries, rework, and repeated manual work;
- user turns that did not advance the task: corrections, verification
  questions, re-asks, misread questions, and requests for output the agent
  should have produced;
- context spent on loaded guidance that did not change behavior or that
  contradicted another source.

A user's pushback when a signal is dismissed means the signal requires real
trigger and cause analysis; do not dismiss it again as generic diligence.

## Check admissibility

Keep an entry only if the session evidences it and no authority already owns
it. Check structural owners (code, tests, lint, CI, hooks, configuration,
canonical helpers, runtime checks), then use the available skill descriptions
as an index: shortlist skills whose triggers intersect the entry and read
those bodies in full. For each shortlisted skill, determine whether:

- it should have activated but its description did not expose the trigger;
- it activated correctly but its body lacked needed guidance;
- the entry fits its existing scope;
- its guidance is stale, overlapping, or made redundant by the entry.

An owner that exists but failed is a candidate against that owner, not proof
of coverage: determine which trigger or enforcement failed. Settle it by
whether the skill was loaded:

- never loaded: the trigger failed; change the description;
- loaded, guidance missing or unclear: change the body;
- loaded, guidance ignored: a compliance failure; consider structure.

## Weigh net value

- **Savings:** per-occurrence cost, rated low, medium, or high from the
  ledger's observed turns, tool calls, rework, and user turns, multiplied by
  expected recurrence. Discount it when the codified form names one example
  rather than the underlying construct, or cannot be applied at a
  recognizable decision point.
- **Carrying cost:** bytes × residency, plus drift risk and maintenance.
  Residency runs from resident instructions, through loaded skill bodies and
  on-demand references, to code and configuration, which cost almost no
  context.

Recommend only when savings clearly exceed carrying cost. A removal's savings
are the carrying cost it frees.

## Route

Synthesize a reusable rule or mechanism; never copy the user's wording or write
an incident narrative. Identify whether the entry arose during discovery,
planning, authoring, execution, or review, and prefer the earliest authority
that can improve the outcome. A review rule that detects a defect is secondary
to an authoring rule that prevents it; change both only when they govern
distinct behavior.

Use the lowest responsible owner and read its destination in full before
proposing a change:

- a specific existing skill at `skills/<name>/SKILL.md` for skill behavior;
- the repository's `AGENTS.md` for one repository's broad conventions;
- user-level agent instructions only for genuinely cross-project behavior;
- host runtime policy or configuration for host-specific behavior;
- code, tests, lint, CI, hooks, configuration, metadata, canonical APIs or
  helpers, and runtime checks for structural mechanisms.

Do not invent destinations outside this hierarchy. Do not create a companion
skill for a third-party amendment; identify the host policy, configuration,
enforcement extension, or maintained fork as appropriate and present it as
outside the normal skill/rule route.

When the session contains two or more fixes to one mechanism, apply
[Attack the Premise](../principles/principle-attack-the-premise/SKILL.md)
before proposing rules that assume the mechanism.
Apply [Encode Lessons in Structure](../principles/principle-encode-lessons-in-structure/SKILL.md)
when a recurring rule or compliance failure needs durable enforcement. Read
[Build the Lever](../principles/principle-build-the-lever/SKILL.md) whenever
the ledger contains repeated manual work, a hand-reproduced check, or rework;
its description cannot trigger it, so this step is how it enters a retro. Keep
these responsibilities distinct; do not copy their bodies into this skill.

A fresh independent view is optional only when breadth, uncertainty, or
conflicting signals justify its cost under current subagent policy.

## Propose, then apply

Consolidate entries into one non-overlapping set, naming any earlier proposal
it supersedes, and present it grouped by verdict before changing anything:

- **Recommend:** one block each with the signal and evidence, savings,
  carrying cost, exact destination, proposed wording or mechanism, and limits
  on confidence.
- **Already owned:** one line each naming the owner.
- **Skip:** one line each naming the deciding factor.

Repeat the consolidation after follow-up discussion and before applying.
Prefer one canonical owner with narrow pointers from other skills over
duplicated rules.

Wait for explicit user approval. Apply only the explicitly approved subset in
the same invocation. For skill edits, apply
[Skill Management](../skill-management/SKILL.md); use the appropriate
implementation path for code, configuration, tooling, or other owners. Re-read
each destination, verify the scoped diff and behavior, report byte deltas for
resident instructions or skills, and commit each verified discrete unit using
the repository's [commit conventions](../writing/commit/SKILL.md). If approval
is absent, stop after the proposal.
