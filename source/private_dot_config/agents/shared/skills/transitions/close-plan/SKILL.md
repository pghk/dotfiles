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
the plans as the governing source: before a plan is deleted, every surviving
contract is carried by the artifact that owns it. Inspect every contract, not a
sample. Closing a plan adds these rules:

- **Contradiction.** When the code contradicts a surviving contract, report it
  and leave it unresolved. Do not rewrite the contract to match the code; the
  plan remains the authority until it is closed.
- **Untested behavior.** Required behavior no test observes gets a test, or is
  recorded as untested in the project's architecture documentation.
- **Deferrals.** A deferral that constrains present design goes beside the idea
  it constrains in the architecture documentation. Any other deferral goes to
  `.notes/backlog.md` when the project keeps one, and is otherwise dropped.
- **Dropped.** Scope limits that bounded only that plan, rejected alternatives
  and history need no new home; Git keeps them.

Update references to the closed plans, including any instruction that treats
them as authority.

## Delete and commit

Delete the closed plan directories. Commit the dissolution and the deletion
together, so one commit shows where the plans' intent went. Report the commit,
the checks run, and any unresolved contradictions.
