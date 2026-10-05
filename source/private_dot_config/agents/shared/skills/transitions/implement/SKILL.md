---
name: implement
description: "Use for an explicit /skill:implement invocation or an unambiguous request to implement, build, or fix a defined piece of work. Accept a scoped request, specification, or stable vertical ticket files; do not use as a universal router."
license: MIT
metadata:
  source: "https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd/skills/engineering/implement"
  additional-source: "https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd/skills/in-progress/implement-spec"
  upstream-revision: "74ca5fe077456a0b3b2f5310cf9430999fd0b5fd"
  provenance: "adapted-from-upstream"
---

# Implement

This transition adopts accepted implementation work as the current session goal
and uses its governing request, specification, or tickets as authority through
integration.
Activate it for `/skill:implement` or an unambiguous natural-language request to
implement, build, or fix a defined piece of work. It is not a universal router.
Do not activate it for general planning, design, brainstorming, or an
underspecified request.

## Accept the work

Accept a direct scoped request, a specification, or stable vertical ticket
files. Invocation accepts the current tickets. A direct request or lone spec
may execute without manufacturing tickets. When the accepted work is a
reported defect, apply the [bug-fix playbook](../../playbooks/bug-fix/SKILL.md)
before implementation investigation; this transition still owns execution and
integration. When a spec and tickets coexist, the spec owns product behavior
and constraints; tickets own execution slices and dependencies. Surface
conflicts between them rather than silently choosing an authority.

Read enough of the accepted sources to understand intent, constraints, the
repository context, and the ticket graph. Establish whether each material
acceptance criterion describes current behavior, intended new behavior, or an
unresolved assumption; observe current behavior when a preservation constraint
depends on it. If a required outcome is currently false while another accepted
constraint prohibits the necessary change, stop and surface the conflict.
Resolve the ready frontier from each ticket's `Blocked by` sections. Continue
through authorized ready tickets without asking routine continuation questions.
Stop for unresolved product intent or constraints, conflicting authority,
unsafe or external actions, unavailable credible validation, or a blocker with
no independent ready work.

The primary agent owns intent, dependencies, integration, and communication
with the user. Keep worker prompts sparse: point workers to stable spec,
ticket, research, and other relevant artifact paths rather than copying their
contents. When a worker will commit, include the exact path to the governing
commit convention instead of relying on skill discovery.

## Execute and integrate

Choose the least costly effective topology. Apply [Subtract Before You Add](../../principles/principle-subtract-before-you-add/SKILL.md)
when selecting change sequencing. Lean toward subagents for coherent
vertical tickets and bounded specialist work; implement directly when the work
is tiny, tightly coupled, or cheaper than a handoff. Parallelize only ready
tickets with independent write ownership, using isolated worktrees where the
active subagent runtime requires them. Serialize shared contracts, registries,
entrypoints, generated artifacts, and overlapping writes under one owner.

When writing or changing an automated test, apply [Test Behavior, Not Implementation](../../principles/principle-test-behavior-not-implementation/SKILL.md) at the test-writing point. It governs test discrimination without requiring a universal TDD workflow.

Integrate delegated changes in dependency order. Require each delegated ticket
handoff to account for every acceptance criterion as verified existing,
implemented and verified, or blocked. Omitted criteria and required checks that
were not executed leave the ticket incomplete for integration. Keep the primary
agent as the integration owner and resolve discoveries against the accepted
authority before expanding scope. Apply relevant focused skills and playbooks
proportionately; do not mandate TDD or a universal workflow.

Use [show-your-work](../../continuity/show-your-work/SKILL.md) for multi-agent,
multi-session, unattended, or otherwise hard-to-audit execution. Keep its one
decision trail instead of creating a report hierarchy or ledger. Request
independent review or cleanup only when risk, breadth, uncertainty,
hard-to-observe behavior, or the user warrants it. There are no mandatory
per-ticket reviewer loops or final review gate.

## Check and finish

Apply [Prove It Works](../../principles/principle-prove-it-works/SKILL.md) when
completing the work. Validate each delivered slice with the cheapest credible
check that could falsify its acceptance criteria. Expand validation for breadth,
risk, uncertainty, environment sensitivity, or hard-to-observe behavior.
After all slices pass, re-read the governing request or specification at its
highest level and inspect the integrated result at the level named by that
outcome, such as behavior, public interface, ownership, organization, generated
artifact, or user experience. Local acceptance is necessary but does not
establish completion when the integrated result still permits the governing
problem. Perform a focused self-check by default and record what was checked and
what could not be checked. When safety depends on integration beyond the local
module, apply [Blast Radius](../../blast-radius/SKILL.md) to establish the
non-local fact rather than relying on a caller list.

Commit each verified discrete unit under the repository's Git instructions.
Continue until the accepted scope is implemented and credibly checked. Report
commits, checks and limits, unresolved risks, and the decision-trail path when
`show-your-work` was used. Never merge, push, publish, delete branches or
worktrees, or clean workspaces unless separately requested.
