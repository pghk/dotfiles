---
name: code-review
description: >
  Use when asked to review, audit, inspect, or find issues in one or more Git
  commits, a commit range, a branch, or changes since a base.
---

# Code Review

Conduct a read-only review of an immutable target-to-source three-dot patch.
Report evidence-backed issues introduced by that patch; do not edit the code or
create a report file.

## Resolve Scope

Interpret the request as up to three natural-language inputs: a Git target and
source, strictness, and context. They are not formal named arguments. Defaults
are a missing source to `HEAD`, strictness to `defects`, and context to `local`.

Normalize every commit review to `<target>...<source>` diff semantics:

- A lone `A...B`, `A..B`, or explicit base-to-head pair means target `A` and
  source `B`.
- A single commit `C` means target `C^` and source `C` only when the requester
  explicitly asks to review that commit rather than the branch ending at it.
- A single branch or ref is the source; it never selects its own target.
- With no revision input, the source is `HEAD`.

The patch is always the output of local Git for the pinned target and source:
`git diff <TARGET_OID>...<SOURCE_OID>`. Pinning both inputs prevents later ref
movement from changing the review.

This skill does not review arbitrary disconnected commit sets, commits unique
to both sides symmetrically, or working-tree changes. Ask the requester to
provide one target/source pair. If working-tree changes are requested, state the
scope mismatch and STOP before inspecting, listing, or classifying them. A
prospective merged-tree simulation is a separate integration review and must be
requested explicitly; do not substitute one for the three-dot patch.

Resolve normalized inputs with `scripts/resolve-scope.sh`; do not compose the
metadata commands yourself. Its first argument is the repository path; pass the
current working directory as `"$PWD"` unless another repository was identified.
Do not change directories for scope resolution.

- `scripts/resolve-scope.sh "$PWD" candidates [<source>]` when the target is
  missing; omitted source means `HEAD`.
- `scripts/resolve-scope.sh "$PWD" review <target> <source>` when both are known.

The resolver fetches and prunes every configured remote before resolving refs,
then fails closed if fetching fails. Place `--no-fetch` after the repository path
only when the requester explicitly accepts offline, potentially stale refs.
Treat every `ERROR` result as a scope-resolution stop; do not recreate the Git
commands or fall back to guessed metadata. The resolver gathers topology only
and produces no diff.

When the target is missing, show the available `develop` and `master` candidates
with immutable tips, ancestry, and source-only counts, then stop for the
requester to select one. A candidate with the fewest source-only commits may be
presented as the proposed default, but proximity does not establish intent and
must not silently select the target.

For a resolved review, retain `TARGET_OID`, `SOURCE_OID`, `GIT_VERSION`, and the
immutable `DIFF_SPEC`. Inspect exactly:

```text
git diff --find-renames --end-of-options <DIFF_SPEC>
```

Capture the command's exit status and stderr. Warnings, including Git's choice
when multiple merge bases exist, are verification context rather than alternate
scope or a confirmation trigger. Stop only when Git cannot produce the patch.

Confirm before reviewing when the target or another value was selected
automatically, or the source-only set is empty or unusually large. Show one
combined confirmation containing the immutable target, source, commit count, and
proposed settings. Whenever strictness or context was omitted, include the
complete five-option scale for that dimension. Explicit target/source reviews
with both levels supplied may proceed directly.

## Strictness: Concerns in Scope

Levels are cumulative:

| Level | Review concerns |
| --- | --- |
| `blockers` | Exploitable security, authorization failures, data loss or corruption, crashes, severe regressions |
| `defects` | Blockers plus other likely incorrect behavior and broken edge cases |
| `risks` | Defects plus fragility, weak error handling, material performance or accessibility issues, insufficient tests |
| `maintainability` | Risks plus design, coupling, duplication, clarity, documentation, conventions, commit scope |
| `polish` | Everything above plus naming preferences, minor style, formatting, low-impact consistency |

Investigate only the selected level and those above it. Lower-severity matters
may be mentioned only when noticed incidentally during in-scope work; do not
search for, investigate, or expand them.

## Context: Evidence Depth

Levels are cumulative:

| Level | Gather and verify |
| --- | --- |
| `patch` | Commit metadata, patch, changed tests; inspection only unless tests are requested |
| `local` | Patch plus surrounding code, immediate callers/callees, nearby tests, cheap targeted checks |
| `informed` | Local plus relevant user/project skills, standards, specifications, documentation, prescribed checks |
| `behavioral` | Informed plus end-to-end flows, analogues, broader tests, history, targeted behavioral probes |
| `external` | Behavioral plus dependency/framework source or authoritative external documentation when repository evidence is insufficient |

Do not inspect unchanged files or gather broader context at `patch`. At this
level, do not report a finding whose trigger or exploitability depends on
unchanged ingress validation, framework normalization, or other evidence beyond
the patch. Do not infer an exhaustive dispatcher from a changed allowlist when
its continuation or fallback is unchanged. Treat an apparent client/server
contract mismatch as residual uncertainty unless the complete dispatch path is
in the patch. When security impact depends on unchanged routes, middleware,
callers, or downstream checks, treat it as residual uncertainty or ask the
requester to approve deeper context.

Gather supplementary skills and documentation at `informed` or above only when
relevant to concerns included by strictness. Request approval before destructive,
unusually slow, or environment-dependent verification. If verification required
for the requested context depends on an unavailable service, STOP before
conducting or reporting the review. State exactly what evidence is unavailable
and ask for direction. Resume only if the requester explicitly changes the
context or verification requirement.

## Conduct the Review

1. Establish intended behavior from the request, source-only commits, and permitted evidence.
2. Inspect the complete immutable three-dot patch; do not sample changed areas.
3. Map changed entry points, contracts, state transitions, trust boundaries, and visible outcomes.
4. Inspect only concern classes included by strictness.
5. Trace changed values and control flow far enough to test relevant invariants, bounded by context.
6. Determine what tests establish, what remains unverified, and run checks permitted by context.
7. Validate a concrete trigger, impact, attribution, and location before calling anything a finding.
   At `patch` context, do not classify an apparent behavioral regression when its
   baseline behavior is unchanged; record residual uncertainty unless the patch
   itself establishes the prior contract.
8. Trace implicated lines to source-only commits as needed; do not expand the primary surface into exhaustive parent-patch review.
9. Revisit every changed behavioral area; evaluate it or name it as residual uncertainty.

Delegate independent areas only when breadth justifies it. One reviewer
validates, deduplicates, ranks, and reports every result. If the patch remains too
broad for reliable inspection and decomposition fails, STOP and request a
narrower target/source pair. Pattern searches or broad scans do not substitute
for complete coverage.

A finding must appear in the resolved patch and be caused or made reachable by a
source-only commit. Exclude pre-existing problems unless the patch makes one
reachable, materially worsens it, or newly relies on it unsafely. Unsupported
suspicions are questions or residual uncertainty, not findings.

## Report

Return these sections:

1. **Review scope** — immutable target, source, three-dot diff spec, Git version, strictness, context, topology, source-only total, merge, and non-merge commit counts, and one inspected patch. Include any warning emitted while producing the patch.
2. **Review evidence** — every reviewed non-merge source-only commit as `<short hash> <first subject line>`; a brief subsystem-oriented summary of actual changes established from the patch; and plausible in-scope concerns investigated and dismissed, with the evidence that ruled each out.
3. **Findings** — ordered from blockers through the selected level.
4. **Incidental observations** — optional lower-severity matters noticed without additional investigation. Label them unverified, outside strictness, and not findings; omit when empty.
5. **Verification** — tests, checks, probes, documents, and other evidence.
6. **Residual uncertainty** — relevant behavior the context or environment could not establish.

On first reference to a commit, identify it as `<short hash> <first subject
line>`; later references may use the short hash alone. Derive the change summary
from inspected code, not commit-message claims. Keep dismissed concerns brief
and evidence-backed.

Each finding has a taxonomy level, concise title, exact `path:line` or commit,
evidence tying the issue to the patch, concrete impact, and correction direction.
Combine duplicate symptoms with one cause. Omit praise, scorecards, and
speculation. If there are no findings, say so directly and still include review
evidence, verification, and residual uncertainty.

Stop and ask rather than guessing when Git cannot resolve the expression,
histories are unrelated, the scope is empty, no target candidate exists, or
breadth makes complete review unreliable. Apply the unavailable-service stop
before conducting or reporting when required verification depends on an
unavailable service.
