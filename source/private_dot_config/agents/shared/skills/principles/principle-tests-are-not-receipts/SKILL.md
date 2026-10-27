---
name: principle-tests-are-not-receipts
description: "Apply before committing, or claiming done on, work that added or changed tests."
metadata:
  author: "Paul Hendrick"
  provenance: "local-composition"
---

# Tests Are Not Receipts

A test written to show that new work functions is a receipt: evidence that something was true during the session. Writing one is good practice. Keeping it unexamined leaves the suite paying indefinitely for an assurance nobody needs again. A retained test is a guard, justified only by what it protects against.

Before finishing work that added or changed tests, treat each such test as a deletion candidate until it earns retention. It earns it only with all three:

- **An enduring concern.** It protects behavior the subject's consumers will keep relying on, not a value, mechanism, or arrangement chosen for this change.
- **A realistic accidental break.** Someone could plausibly break that behavior without meaning to. What only a deliberate redesign changes needs no guard.
- **No cheaper guard.** No cheaper test, type, schema, or structure already catches the same break.

Then choose the smallest outcome: **remove** what fails; **trim** incidental assertions from what passes; **reshape** a durable claim whose expression is brittle or expensive into the lightest observation that still catches the break; **keep** what protects at reasonable cost. A valuable requirement does not make every test about it valuable, and an exact value can itself be the requirement: the subject's contract decides.

Sensitivity is not value. A test that goes red under mutation catches that change; whether the change is worth catching is a separate question.
