---
name: retro
description: "Use for an explicit retrospective request such as retro, reflect, session learnings, what did we learn, or an end-of-session retrospective. Review the active conversation for reusable learning: corrections, successful techniques, clarified domain knowledge, missed skill triggers, friction, and preventable rework. Suggest it proactively only after repeated corrections, repeated tool errors, preventable rework, or clear mounting friction; do not run it for every session or a one-off mistake."
license: MIT
metadata:
  source: "https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd/skills/in-progress/retro"
  additional-source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/reflect"
  upstream-revision: "74ca5fe077456a0b3b2f5310cf9430999fd0b5fd"
  additional-source-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "local-composition"
---

# Retrospective

Review the active conversation or transcript, not a generic session summary. The
purpose is to carry evidenced failures and newly established knowledge into a
smaller and more reliable system. A short session with no meaningful signal
needs no ceremony.

## Gather and filter signals

First list concrete observations without diagnosis or proposed fixes. Include:

- explicit corrections, redirected work, rejected output, and repeated
  instructions;
- failed or misordered tool calls, retries, no-op work, repeated manual work,
  and preventable rework;
- successful techniques, clarified domain rules, and quality standards that
  became evident during the work;
- environment friction: navigation and discoverability, information access,
  automated checks, coding standards, tool economy, and unclear ownership;
- multi-round refinement of one artifact and mounting back-and-forth.

A user's pushback when a signal is dismissed means the signal requires real
trigger and cause analysis; do not dismiss it again as generic diligence.

Filter out one-offs, simple typos, session-specific facts, generic best
practices, speculative improvements, guidance already adequately owned, and
routine successes that produced no new knowledge. Do not treat a compliance
failure as closed merely because an instruction exists: determine which trigger
or enforcement mechanism failed.

For each remaining candidate, apply every gate:

- **Evidence:** did the session establish the learning, or is it speculative?
- **Novelty:** does it add something not already encoded by an authority?
- **Prevention and leverage:** would preserving it earlier have prevented
  failure or made later work materially clearer, safer, or cheaper?
- **Recurrence and transferability:** is it useful beyond this artifact or
  session?
- **Generality:** does it name the underlying construct rather than one example?
- **Actionability:** can an agent apply it at a recognizable decision point?
- **Existing enforcement and fit:** is the behavior already owned by code,
  tests, lint, CI, hooks, configuration, metadata, a canonical API/helper, or a
  runtime check? Prefer that owner over duplicating prose, and state any limit
  on causal confidence.

## Inspect relevant skills

Use the available skill descriptions as an index. Shortlist skills whose
triggers intersect the session's work or retained learning, then read those
skill bodies in full. Do not load every skill unconditionally.

For each shortlisted skill, determine whether:

- it should have activated but its description did not expose the trigger;
- it activated correctly but its body lacked needed guidance;
- the new knowledge fits its existing scope and would improve future work;
- another skill or structural mechanism already owns the behavior; or
- its current guidance is stale, overlapping, or made redundant by the lesson.

Change a description when discovery failed. Change a body when the skill was
correctly selected but its guidance was insufficient. Do not change a trigger
merely because the agent failed to follow guidance already present in the body.

## Diagnose and route

Synthesize a reusable rule or mechanism; never copy the user's wording or write
an incident narrative. Identify whether the failure or learning arose during
discovery, planning, authoring, execution, or review, and prefer the earliest
authority that can improve the outcome. A review rule that detects a defect is
secondary to an authoring rule that prevents it; change both only when they
govern distinct behavior.

Use the lowest responsible owner and read its proposed destination in full
before proposing a change:

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
the signal list contains repeated manual work, a hand-reproduced check, or
rework; its description cannot trigger it, so this step is how it enters a
retro. Apply [Subtract
Before You Add](../principles/principle-subtract-before-you-add/SKILL.md) when
choosing among changes: refine an existing owner and remove redundant process
before adding machinery. Keep these responsibilities distinct; do not copy
their bodies into this skill.

A fresh independent view is optional only when breadth, uncertainty, or
conflicting signals justify its cost under current subagent policy.

## Propose, then apply

Present a compact table or list before changing anything. Each proposal must
include: signal and evidence, recurring pattern or cause, proposed rule or
mechanism, exact destination, prevention case, and confidence or limits. Keep
proposals concrete and synthesize them into actionable reusable wording.

Before presenting proposals, consolidate them into one non-overlapping set and
name any earlier proposal they supersede. Repeat that consolidation after
follow-up discussion and before applying changes. Prefer one canonical owner
with narrow pointers from other skills over duplicated rules.

Wait for explicit user approval. Apply only the explicitly approved subset in
the same invocation. For skill edits, apply
[Skill Management](../skill-management/SKILL.md); use the appropriate
implementation path for code, configuration, tooling, or other owners. Re-read
each destination, verify the scoped diff and behavior, report byte deltas for
resident instructions or skills, and commit each verified discrete unit using
the repository's [commit conventions](../writing/commit/SKILL.md). If approval
is absent, stop after the proposal.
