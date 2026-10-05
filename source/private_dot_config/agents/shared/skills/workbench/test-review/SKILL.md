---
name: test-review
description: >
  Use when reviewing, auditing, or judging existing or proposed tests, test
  plans, and test acceptance criteria. Finds tests that pass but catch nothing,
  planned claims with no observable SUT boundary, tests that assert the harness
  instead of the subject, tests at a layer that adds no observation power,
  assertions that cannot fail, and selector or instrument misuse. Use when
  asked whether tests are meaningful, test realistic failures, read like a
  behavioral spec, cover the right behavior, or could have caught a bug—even
  when no test files exist yet or the request does not use the word “review.”
---

# Test Review

Judge whether existing tests or proposed test claims can distinguish correct
behavior from incorrect behavior. Report findings with evidence.

For a class- or suite-level review, first state the subject's public input,
output, and responsibility in one sentence. Map the test groups to that
responsibility before inspecting individual assertions. When the subject
assembles several kinds of output, require a representative composition
scenario; isolated component coverage does not establish that the whole result
composes correctly. Treat opaque fixture vocabulary, delivery-history names,
and a suite whose organization hides the responsibility map as test-quality
findings when the requested review includes legibility or executable
specification.

**A request to fix, improve, clean up, or rewrite a test is a review request
first.** Produce the findings, then propose the change and wait for agreement.
Editing before the review is complete means editing without knowing which
claims the test protects, and the edits land on whichever symptom is loudest —
usually a failure the test did not cause.

A test file cannot be reviewed by reading it. Every finding below requires
reading the code the test exercises. A review conducted on the test text alone
will find style problems and miss every defect that matters.

## Prospective reviews

When tests do not exist yet, review the proposed claims rather than pretending
to review their implementation. Read the intended SUT, upstream behavior and
named repository references. For each claim, identify the production boundary,
representable stimulus, distinguishing observation, cheapest reliable layer and
a plausible accidental production edit that would change the result.

Separate runtime behavior from source-at-rest constraints. A proposed test for
an extra enum case, forbidden property, type modifier or absent abstraction is
structural unless consuming behavior observably depends on that shape. Reject a
runtime claim when its SUT cannot receive the stimulus or expose the asserted
distinction; reframe it around the owner that can, or report a testability gap.
Check compound guards, scoped data, ordered precedence and fallbacks case by
case rather than crediting a broad section citation.

Do not require or invent a baseline run, mutation result or test-body finding
when no implementation exists. State that discrimination remains prospective
until the test is implemented, run green and proven red by a plausible
production mutation. Apply the claim-and-layer allocation below to planned
claims; apply artifact, assertion and instrument checks only where concrete
artifacts or proposed mechanisms exist.

## Evidence standard

Confirm findings; do not infer them.

Before any finding derives from a test run, run the tests unmodified and
record what they do. **If they are not green, the review is blocked.** Report
the observed failure and stop. Do not repair the environment, and do not
convert the failure into a finding about the test's design — a red run whose
cause you have not established says nothing about whether the test
discriminates, and a hidden environmental fault reads exactly like a broken
test. You are not required to diagnose it; you are required not to build on it.

- A test that "cannot fail" is confirmed by searching for the asserted token
  or by mutating the production code and observing the test stay green.
- A claim about how a framework resolves, renders, or dispatches something is
  confirmed by running it, not recalled.
- An intentional-looking oddity is confirmed by looking for a sibling test,
  manifest, or comment that specifies it before calling it a defect.

State plainly when a finding rests on inspection alone, and name the
observation that would settle it. Withdraw findings that evidence contradicts.
When implementation and documentation disagree about product policy, report a
contract conflict until an accepted authority establishes the intended
behavior; do not promote the discrepancy to a subject defect on documentation
alone.

A sibling test's pattern is evidence about what the *SUT* is meant to do, not
validated precedent for a *test's* own structure. Citing "the neighboring test
also selects/bypasses/asserts it this way" only carries weight once that
sibling has itself passed review — otherwise it launders an unreviewed choice
into apparent convention. Evaluate the choice on its own merits, and say when
a cited pattern is unverified rather than presenting it as established.

### Mutating to confirm

Breaking production code on purpose is the strongest evidence available here
and the only step that leaves the tree dirty. Bound it:

- Copy the file before editing it, and restore from that copy rather than
  editing it back.
- Re-run to the recorded baseline afterwards. Restoration is not confirmed by
  the absence of an error.
- Rebuild whatever the test actually loads. A mutation of a source that a
  bundle is built from proves nothing until the bundle is rebuilt, and a
  staleness guard that misses that source will show you a false green.
- Confirm the tree with a check that sees ignored files. `git status` reports
  clean for a deleted build artifact or runtime marker, so "clean tree" from
  it alone is not evidence that a mutation was undone.

Mutate the subject under review, never the environment that runs it. Needing
to change build or server state to get a run is the blocked case above.

A mutation that demonstrates discrimination must model a plausible *accidental*
change — a rename, a refactor, an unrelated cleanup. A mutation that
deliberately reimplements the exact behavior the test claims to guard (adding
back the code path it exists to prevent) proves the assertion can go red, not
that the behavior is worth guarding: a change that conspicuous would surface in
code review regardless of the test. If the only mutation that reddens an
assertion is that kind, the finding is "this test cannot fail by accident," not
"this test is valuable."

## Suite-level responsibility map

When the scope is a test suite or the requested outcome is that tests explain a
subject, first identify the subject's public responsibilities from its
production boundary. Map each responsibility to files and named tests, then
report missing, duplicated, misplaced, or obscured responsibilities. Evaluate
whether filenames, grouping, fixture vocabulary, and the first representative
test let a reader recover the subject's contract. Propose the target suite
organization before optimizing existing assertions in place.

## The five moves

Run them in order after any suite-level responsibility map. Each is capable of
surfacing defects the others structurally cannot, so a partial pass is a partial
review.

Apply every move to constructs already present in the file, not only to ones
you would write fresh. A selector, a harness bypass, or a setup call being
already there is not evidence it was chosen deliberately — it gets the same
scrutiny as new code.

### 1. Artifact inventory

List every artifact the test's stimulus passes through — source files,
templates, generated bundles, stylesheets, registries, configuration. For
each, classify its *kind*, and check that the kind matches how it is authored
and consumed.

Catches: files written as one kind and consumed as another; a template whose
declared inputs are shadowed by a class that never passes them; assets the
test depends on that are built rather than read.

### 2. SUT boundary

Name the system under test and separate it from the harness. Prefer the
project's own declaration — a manifest, registry, or docblock — over your
reading. Then classify each failure of the boundary:

- **too narrow** → the test asserts on harness or fixture detail
- **too wide** → the test asserts framework or platform behavior
- **wrong entry** → the stimulus reaches the state by a route production
  never takes, including any state the test sets up by hand that production
  produces itself
- **wrong distance** → the observation is made from further away than needed

Treat a fixture element that exists only to be asserted on as circular: the
test then characterizes the fixture, not the subject.

Check any setup-time harness bypass — disabled middleware, elevated
permissions, a feature flag forced on — against what the SUT actually needs to
render. A bypass scoped wider than that (a blanket "disable everything" call
where one specific check needed to go) hides which real constraint the test
depends on and can silently stop exercising auth, permission, or gating
behavior the test's name implies it still covers. Prefer bypassing the named
thing that blocks the SUT, with the reason stated, over an unscoped call
carried forward from an earlier version of the test.

### 3. Claim and layer allocation

Start by finding the other tests of the same subject. They are not in the file
you were handed and nobody will name them: search every test directory for the
subject's class names, element names, routes, and identifiers, and read what
you find. A layer you did not open cannot appear in the allocation, and this
step is skipped more often than any other in this skill.

Find the project's own layer map; most repositories document one.

Then build the table — one row per distinct claim, both columns filled:

| claim | cheapest layer that can falsify it | existing test that already does |

Fill the third column from what a test *exercises*, not from what its filename
or subject suggests. Read the covering test's setup before crediting it: a
test that registers, imports, or addresses the subject under a name of its own
does not cover the binding to the real name, and crediting it there converts a
gap into apparent coverage. Write "none" rather than the nearest plausible
file.

The table is the finding, not preparation for it. From it, report:

- **duplicated** — asserted at a layer that observes nothing a cheaper one
  already observes
- **unclaimed** — no layer asserts it, especially contracts that exist only
  *between* artifacts, such as a name bound in one file and consumed in
  another

When every row for a file is duplicated, say so as a single conclusion: the
file contributes no unique falsification, however sound its individual
assertions look. That conclusion is invisible assertion-by-assertion, which is
why the table comes before the verdict.

### 4. Assertion discrimination

For each assertion:

1. **Can it fail?** Name the production edit that turns it red.
2. **Does it fail only for the right reason?** Assertions on mechanisms —
   spies, call counts, internal calls — go red on refactors and stay green
   when behavior changes. Prefer the observable state the mechanism produces.
3. **Is the instrument shaped like the artifact?** Structured artifacts want
   structured queries. Substring matching over serialized output is both too
   loose, matching anywhere, and too tight, breaking on irrelevant formatting.
4. **Does failure localize the break?** See granularity below.

Watch for the under-specified positive: an assertion that confirms a category
when the claim is about which member of the category. Confirm these by
mutation — swap the value for a sibling and see whether anything reddens.

#### Granularity

A failure must name what broke. The same defect appears at three scopes:

- **within an assertion** — conditions combined into one boolean, reporting
  `false` for many claims
- **within a test** — claims chained so the first failure masks the rest, so
  one run reports one problem out of many and each fix needs another run
- **across a test** — one test carrying unrelated claims, so its name cannot
  describe any particular failure

Read the test names first; they confess this cheaply. A name joining claims
with "and", or listing them with commas, is a bundled test. So is a name that
under-counts its own body, or a body asserting things the name never mentions.

Bundling is not only a reporting problem. Unrelated claims sharing one stimulus
cannot be quarantined or skipped independently, and a claim hidden inside a
test named for something else escapes the duplication check in move 3.

Demonstrate the cost; do not just name it. Break one claim and observe which
claim the runner reports — a bundled test characteristically names a different
one, or stops before reaching the claim in its own title. "The first failure
masks the rest" asserted without that observation is a style note, and reads
as one.

### 5. Instrument selection

Most browser and integration suites define a preferred selector or query
hierarchy. Find it, then check each assertion against it.

Flag every assertion that drops below the hierarchy entirely — raw script
evaluation, direct DOM access, manual style computation. Each one usually
costs three things: automatic waiting, a readable failure message, and the
distinction between contract and implementation.

Then ask why the escape hatch was reached for:

- the claim **has** a first-tier expression and it was bypassed → instrument
  error, and rewrite it
- the claim **has none** → either it is presentation detail that does not
  belong in a behavior test, or the subject has a genuine accessibility gap

Check the rewrite against the real stimulus. A hand-written script can be made
to return true against a DOM the test constructed itself; the first-tier
instrument usually cannot, which is why a bad instrument can conceal a stimulus
that never produced the asserted state.

A selector that clears the hierarchy check can still over-specify. A
structural selector legitimately reached for a genuine structural claim can
still encode incidental fixture details unrelated to the claim itself — a
specific state value, a specific tag name — that just happen to be true of the
fixture in front of you. Ask what the claim is actually about, then check the
selector names only that.

## Reporting

Order findings by consequence, not by line number:

1. **Inert** — the test cannot fail, or cannot fail for the reason it claims
2. **Unclaimed** — real behavior no test protects
3. **Misallocated** — the claim is real but the layer or instrument is wrong
4. **Brittle** — the test fails on correct changes
5. **Noisy** — redundant, or collapses its own diagnostics

For each: the location, the claim it purports to make, the evidence, and the
mutation that does or does not reach it. Distinguish defects in the *test*
from defects in the *subject* the review uncovered — both are worth
reporting, and they need different decisions.

Do not write a report file unless asked.

## Scope

[Test Behavior, Not Implementation](../../principles/principle-test-behavior-not-implementation/SKILL.md)
governs authoring; this skill remains focused on evaluating existing or proposed
tests. A rewrite that changes which behavior is protected is a design decision,
not a cleanup.
