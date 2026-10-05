---
name: refactor
description: "Use for an explicit behavior-preserving refactor or implementation simplification on a bounded scope. Do not use for feature behavior, bug fixes, formatting/naming/comment/docs-only cleanup, or architecture redesign that changes boundaries, contracts, or ownership."
metadata:
  author: "Paul Hendrick"
  provenance: "local-composition"
---

# Refactor

Use this playbook for an explicit behavior-preserving refactor or
implementation simplification on a bounded scope. A refactor may cross a
shared boundary when its contract and ownership remain the same; broaden
validation for that coupling rather than treating file count as the scope.

Do not activate for a feature, behavior change, bug fix, formatting or
naming-only change, comment or documentation cleanup, or architecture
redesign that changes boundaries, contracts, or ownership. If the desired
behavior changes, route the work through the appropriate feature, bug-fix, or
specification flow instead of preserving a refactor label.

## Establish the contract

Before editing, identify the behavior and contract to preserve: observable
inputs and outputs, errors, side effects, compatibility, and relevant timing
or lifecycle rules. Name the affected boundary and its dependents. Separate
invariants from incidental implementation details. If the boundary or
preserved behavior is unclear, stop and resolve that uncertainty before
changing structure.

Apply [Subtract Before You Add](../../principles/principle-subtract-before-you-add/SKILL.md)
as a strong framework rule. Remove dead, redundant, duplicate, or
compensatory structure before introducing its replacement. Keep required
behavior and compatibility; subtraction is not permission to discard a
contract or authority.

## Establish a green baseline

Run the existing relevant tests, or the narrowest credible executable
observation, before editing. This establishes GREEN for behavior-preserving
work; do not manufacture a RED test. If the seam is absent or weak, add only
the smallest credible characterization test or probe. When creating or
changing a test, apply [Test Behavior, Not Implementation](../../principles/principle-test-behavior-not-implementation/SKILL.md):
name the observable behavior and a known bad case, and assert at the subject
boundary. A weak test is not evidence.

If the baseline is already failing, localize whether the failure is unrelated
or whether the requested work is actually a bug fix. Do not silently absorb a
pre-existing failure into a refactor.

## Change one bounded unit

Make the smallest structural edit at the minimal contract boundary. Prefer
removing unnecessary layers and then replacing only what the preserved
contract requires. Keep active failures localized. After each independently
meaningful unit, rerun its focused checks and inspect the diff. If failures
spread beyond the unit, shrink or revert the current unit before widening
scope; do not stack speculative fixes.

Expand to a global or smoke check only when a shared contract, cross-module
coupling, or lifecycle concern justifies it. Apply [Blast Radius](../../blast-radius/SKILL.md)
when safety depends on a non-local fact that focused checks do not establish.

## Finish with evidence

Apply [Prove It Works](../../principles/principle-prove-it-works/SKILL.md).
Re-run the baseline checks and any justified expanded checks on the actual
revision. Confirm that the preserved contract still holds, report what was
observed and what remains unproven, and commit each verified discrete unit
under the repository's existing [commit conventions](../../writing/commit/SKILL.md).
This playbook adds no independent-review ceremony.
