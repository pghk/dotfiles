---
name: test-review
description: "Use when judging existing or proposed tests: whether a test is weak, brittle, or worth keeping, or can tell correct behavior from incorrect. Before fixing or rewriting a test."
---

# Test Review

Judge whether tests or proposed test claims distinguish correct behavior from incorrect, and whether each earns retention. Load the standard first: [Test Behavior, Not Implementation](../../principles/principle-test-behavior-not-implementation/SKILL.md), [Tests Are Not Receipts](../../principles/principle-tests-are-not-receipts/SKILL.md), and [Query the Structure](../../principles/principle-query-the-structure/SKILL.md). Read [references/smells.md](references/smells.md) for the concrete cues each move looks for.

**A request to fix, improve, clean up, or rewrite a test is a review request first.** Produce the findings, then propose the change and wait for agreement. Editing before the review is complete means editing without knowing which claims the test protects, and the edits land on whichever symptom is loudest, usually a failure the test did not cause. Shape proposals under [Subtract Before You Add](../../principles/principle-subtract-before-you-add/SKILL.md): deletion is a proposal, and it comes before a stronger assertion.

Once a change is agreed, the review is over for that finding and a different skill owns the edit. A rewritten or new test is authored under the principles above. A finding resolved in the *subject* is a production change: load the applicable area skill and any change-impact skill before editing, then re-enter this review for the test that results.

A test file cannot be reviewed by reading it. Every finding requires reading the code the test exercises; a review of the test text alone finds style problems and misses every defect that matters.

## Suite-level reviews

When the scope is a class or suite, or the requested outcome is that tests explain a subject, first state the subject's public input, output, and responsibility in one sentence from its production boundary. Map each responsibility to files and named tests, then report missing, duplicated, misplaced, or obscured responsibilities. When legibility is in scope, evaluate whether filenames, grouping, fixture vocabulary, and the first representative test let a reader recover the contract. Propose the target organization before optimizing assertions in place.

## Prospective reviews

When tests do not exist yet, review the proposed claims. Read the intended subject, upstream behavior, and named repository references. For each claim, identify the production boundary, a representable stimulus, the distinguishing observation, the cheapest reliable layer, and a plausible accidental production edit that would change the result. Reject a runtime claim when its subject cannot receive the stimulus or expose the asserted distinction; reframe it around the owner that can, or report a testability gap. Check compound guards, scoped data, ordered precedence, and fallbacks case by case rather than crediting a broad section citation.

Do not require or invent a baseline run, mutation result, or test-body finding when no implementation exists. State that discrimination remains prospective until the test is implemented, run green, and proven red by a plausible production mutation. Apply move 3 to planned claims; apply the other moves only where concrete artifacts or proposed mechanisms exist.

## Evidence standard

Before any finding derives from a test run, run the tests unmodified and record what they do. **A red run whose cause is not established blocks the review.** Report the observed failure and stop. Do not repair the environment, and do not convert the failure into a finding about the test's design: a hidden environmental fault reads exactly like a broken test. When the failure is itself the subject of the review, establish its cause by observation first; a red run with an observed cause is evidence like any other.

- A test that "cannot fail" is confirmed by searching for the asserted token or by mutating the production code and observing the test stay green.
- A claim about how a framework resolves, renders, or dispatches something is confirmed by running it, not recalled.
- An intentional-looking oddity is confirmed by looking for a sibling test, manifest, or comment that specifies it before calling it a defect.

State plainly when a finding rests on inspection alone, and name the observation that would settle it. Withdraw findings that evidence contradicts. When implementation and documentation disagree about product policy, report a contract conflict until an accepted authority establishes the intended behavior.

Before mutating production code to confirm a finding, read [references/mutation.md](references/mutation.md).

## The five moves

Run them in order after any suite-level map. Each surfaces defects the others structurally cannot, so a partial pass is a partial review. Apply every move to constructs already present in the file: a selector, harness bypass, or setup call being there is not evidence it was chosen deliberately.

### 1. Artifact inventory

List every artifact the test's stimulus passes through: source files, templates, generated bundles, stylesheets, registries, configuration. Classify each one's kind, and check that the kind matches how it is authored and consumed. This catches files written as one kind and consumed as another, template inputs shadowed by a class that never passes them, and built assets the test depends on.

### 2. Subject boundary

Name the system under test and separate it from the harness, preferring the project's own declaration (a manifest, registry, or docblock) over your reading. Classify each observation against the boundary rule in Test Behavior, Not Implementation, and check every setup-time harness bypass against what the subject actually needs.

### 3. Claim, layer, and retention

Find the other tests of the same subject. They are not in the file you were handed and nobody will name them: search every test directory for the subject's class names, element names, routes, and identifiers, and read what you find. Find the project's own layer map. This step is skipped more often than any other.

Build one row per distinct claim:

| claim | cheapest layer that can falsify it | existing test that already does | earns retention? |

Fill the third column from what a test *exercises*, not from its filename or subject. A test that registers, imports, or addresses the subject under a name of its own does not cover the binding to the real name; write "none" rather than the nearest plausible file. Fill the fourth from Tests Are Not Receipts.

The table is the finding. Report claims that are **duplicated** at a layer observing nothing a cheaper one does not, **unclaimed** by any layer (especially contracts that exist only between artifacts), and **unwarranted** under the retention test. When every row for a file is duplicated or unwarranted, say so as one conclusion: the file contributes no unique protection, however sound its assertions look.

### 4. Assertion discrimination

For each assertion, name the plausible accidental edit that turns it red and a correct design change that must leave it green, then check that its failure would localize the break. Confirm an under-specified positive by swapping the value for a sibling. Demonstrate a granularity defect rather than naming it: break one claim and observe which claim the runner reports.

### 5. Instrument selection

Find the project's preferred query or selector hierarchy, then check each assertion against it and against Query the Structure. For every assertion below the hierarchy, decide whether the claim has a first-tier expression that was bypassed (rewrite it) or none (presentation detail that leaves the test, or an accessibility gap in the subject). Check any rewrite against the real stimulus: a first-tier instrument usually cannot be satisfied by a DOM the test built itself, which is how a bad instrument conceals a stimulus that never produced the asserted state.

## Reporting

Order findings by consequence, not by line number:

1. **Inert** — the test cannot fail, or cannot fail for the reason it claims
2. **Unwarranted** — the distinction does not earn retention; say what removal loses and why that loss is acceptable
3. **Unclaimed** — real behavior no test protects
4. **Misallocated** — the claim is real but the layer or instrument is wrong
5. **Brittle** — the test fails on correct changes
6. **Noisy** — redundant, or collapses its own diagnostics

For each: the location, the claim it purports to make, the evidence, and the mutation that does or does not reach it. Distinguish defects in the *test* from defects in the *subject*; both are worth reporting, and they need different decisions.

Do not write a report file unless asked.

## Scope

This skill evaluates existing or proposed tests; authoring belongs to the principles. A rewrite that changes which behavior is protected is a design decision, not a cleanup.
