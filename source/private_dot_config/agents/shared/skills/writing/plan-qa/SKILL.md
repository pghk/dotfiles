---
name: plan-qa
description: >
  Plan manual browser QA for a branch against a deployed environment. Use when asked to "write QA steps", "write a test plan", "what should QA check", "write QA notes", "how do we verify this in staging/preview", or to describe verification for a ticket or release. The reader knows the application but not the code, infrastructure, or diff, so every step must be an action they take and an outcome they can see. Distinct from describe-changeset, which briefs reviewers, and from automated test authoring.
---

# Plan QA

The reader is a tester who uses this application competently and has never seen its source. They cannot read a diff, open a log, query a database, or reach a server. Everything you ask them to do happens in a browser, and everything you ask them to confirm is something they can see on a screen.

Their time is the scarce resource. A plan that lists every touched surface wastes it; the value is in knowing which few checks would actually catch this branch breaking something.

## Establish what changed

Read the range before writing anything:

```
git log --oneline <base>..HEAD
git diff --stat <base>..HEAD
```

Then read each commit's message and diff. The diff tells you what changed; the message tells you what problem it solves and therefore what "broken" would look like. Where a commit claims something was unused or unreachable, note it — that claim is the branch's biggest QA-visible risk, because it is the one thing the author could not prove without a browser.

Read the views and routes involved, not just the controllers. What the user sees is decided in the template.

## Establish what's reachable

Before sorting changes into kinds, ask or confirm which surfaces a real user can reach today — live routes, flags already promoted — versus what sits behind a gate and is still under construction. Scope every check below to the reachable surface. For anything still gated and unfinished, add one short paragraph describing what's there, including known rough edges (a control that isn't wired up yet, a link that errors), so a tester who stumbles onto it isn't surprised — but write no checks against it. It isn't part of the product yet.

## Sort every change into one of four kinds

**New behaviour.** State what the tester should now see, in their words. Give them the case that proves it, not just the happy path.

**Changed behaviour.** Give both the old and the new expectation. Testers who know the application will otherwise report the new behaviour as a bug.

**Touched but unchanged.** Refactors, renames, retargeted forms. There is nothing to verify, only something to catch. Name the shape the failure would take — "the sign-in does nothing, errors, or lands somewhere unexpected" — so the tester knows what they are watching for.

**Invisible.** Produces no observable difference. Write no step. Silence here is what makes room for the checks that matter.

## Write the steps

Number actions; keep one action per line. State each expectation as **Expect:** followed by what appears on screen.

Use relative URLs (`/forgot-password`). Never name a class, file, config key, route name, or environment variable. "If reCAPTCHA is switched on in this environment, you will see the badge in a bottom corner" — not the config flag that controls it.

Where two responses must be **identical**, say so explicitly and say that any difference at all is a defect, including wording, styling, and position on the page. Testers discount cosmetic differences unless told not to.

Where behaviour is deliberately unchanged and the tester may assume otherwise, say so at the step: "This is unchanged — confirm it still appears."

## Account for the environment the tester is in

The environment is deployed and shared, but its fixed characteristics usually aren't unknowable. Before writing a step that forks on environment state, ask whether the condition is actually fixed for the real environment testers use, or genuinely varies. A fixed condition gets one expectation, not a tester-facing branch for a case that won't occur there — reserve forks for what truly varies, and give the tester a way to tell which case they're in.

- A gate a prior visit may already have satisfied — a cached credential, an existing session — is an acceptable alternate outcome at the same step, not a separate case to diagnose.
- A feature that may be on or off: name a page where it is known to be on, so "off here" is distinguishable from "broken". Confirm in the code that the tell you are naming actually renders — a feature being active does not mean it is visible, and an invented signifier sends the tester hunting for something that was never there. Where a feature genuinely has no visible presence, say so and give a behavioural check instead.
- A threshold counted per server: the stated number is a lower bound. Say so, or the tester will report a false negative when the limit does not trip.
- A quantity you cannot predict: ask them to record what actually happened.

## Setup

Open with what they must have in hand before starting: accounts they can sign into, a mailbox they can actually open, addresses that must _not_ have an account, and anything they can only obtain from another system or another team. Say where it comes from. A URL that is a bare identifier, unreachable by browsing, is a blocker if they find out about it at the step that needs it. If no setup is needed, say that too.

## Check each step is worth a person's time

Count what the tester physically does. A step that reads "submit until it blocks" is a hundred form fills and button clicks if the threshold is high, and no one will do it. Anything driven by repeated submission of a form carrying a payload is a manual check only at small numbers; above roughly a dozen it belongs in an automated test, and the plan should say so and mark it untested rather than leave a step nobody completes.

Do not describe a POST as though it were a URL the tester can load. Loading a page and submitting a form are different actions and often hit different limits, gates, and handlers.

Where a threshold is out of manual reach, the mechanism can usually still be checked somewhere cheaper — a lower threshold on a sibling form proves the same machinery works, releases, and doesn't catch ordinary use.

## Order the steps so they don't block each other

Some checks leave the tester locked out, rate limited, with a consumed one-time token, or with state that changes later results. Put those last and say why. For every such state, say how long it lasts and how to escape it, because they will enter it by accident.

## Ask for observations, not just pass/fail

Ask for an observation only where the outcome is genuinely unpredictable in advance and useful to the branch author — how many attempts a threshold took, which way a configuration was set, how an unpredictable failure actually presented. Attach the ask to the specific step it belongs to. Most checks resolve cleanly against the stated expectation and need nothing further — don't manufacture a reporting ask for those, and don't collect them into a closing summary section that restates every check.

## Keep out

- Steps that restate the commit messages.
- Anything already covered by automated tests, unless the browser is the only place the assumption can fail.
- Requests to read logs, inspect data, or check infrastructure.
- Coverage for its own sake. Every step earns its place by being able to fail.
