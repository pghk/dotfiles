---
name: close-plan
description: "Manual only. Close finished plans under docs/plans: move their surviving intent into the artifacts that own it, then delete them."
disable-model-invocation: true
---

# Close Plan

This transition retires one finished plan, or a set of plans linked by
supersession, so `docs/plans/` holds only open work. Activate it for
`/skill:close-plan` or an unambiguous request to close, clean up or retire
finished plans. Name the plan directories being closed before starting; if
which plans are finished is unclear, ask.

## Confirm the work is done

For every ticket, or every step of a plan without tickets, identify the commit
that delivered it, and run the project's required checks. A plan with
undelivered work or failing checks stays open: report what remains and stop.

## Resolve what still governs

Apply each newer spec's supersession statements to the older specs it names.
A superseded part governs nothing and needs no new home. List the surviving
contracts across the plans being closed.

## Dissolve the surviving intent

Apply [Express Intent](../../principles/principle-express-intent/SKILL.md) with
the plans as the governing source. Code expresses behavior; discriminating
tests protect it. Standing documentation carries enduring contracts and
constraints independently of implementation and test coverage.

Extend the document that owns each standing contract. If no owner exists,
create focused feature or architecture documentation using the project's
conventions. Link it from the project's normal documentation entry point.
Choose the artifact for its purpose; use existing adequate documentation
without creating a duplicate or copying the plan wholesale.

Before deletion, complete a working checklist for every surviving contract:
governing source, destination passage, and behavioral evidence where
applicable. Compare each destination against its source clause by clause.
Missing clauses, missing documentation, changed facts, or contradictions
block closure; keep the plan until they are resolved. Include the checklist
in the closure explanation rather than creating a permanent repository
ledger. Apply these rules to the destinations:

- **Contradiction.** When the code contradicts a surviving contract, report it
  and leave it unresolved. Do not rewrite the contract to match the code; the
  plan remains the authority until it is closed.
- **Untested behavior.** Required behavior no test observes gets a test, or is
  recorded as untested beside its documented contract.
- **Reasons.** A surviving contract a reader would take for a mistake keeps a
  one-clause reason beside it, taken from the plan's spec or research.
- **Deferrals.** A deferral, including a question the plan's research raised
  and its spec left undecided, goes beside the idea it constrains in the
  architecture documentation when it constrains present design. Any other
  deferral goes to `.notes/backlog.md` when the project keeps one, naming any
  research note it rests on, and is otherwise dropped.
- **Research.** Research notes outlive the plan. Move them to the project's
  research directory when it keeps one; otherwise Git keeps them.
- **Dropped.** Scope limits that bounded only that plan, rejected alternatives
  and history need no new home; Git keeps them.

Update references to the closed plans, including any instruction that treats
them as authority, and the relative links inside moved research notes.

## Delete and commit

Delete the closed plan directories. Commit the dissolution and the deletion
together, so one commit shows where the plans' intent went. The message
describes the commit's own changes; backlog additions are untracked, so report
them to the user instead. Report the commit, the checks run, and any
unresolved contradictions.
