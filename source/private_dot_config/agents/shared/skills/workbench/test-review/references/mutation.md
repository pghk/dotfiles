# Mutating to confirm

Breaking production code on purpose is the strongest evidence a review has, and the only step that leaves the tree dirty. It is the claim-matched evidence [Prove It Works](../../../principles/principle-prove-it-works/SKILL.md) requires before reporting that a test discriminates.

- Mutate with a plausible accidental edit — a dropped rule, a renamed value, an unrelated cleanup — not by re-adding the exact defect the test was written against.
- Restore with `git checkout -- <file>` when the file was clean before the mutation; otherwise copy it first and restore from the copy. Do not edit it back by hand.
- Re-run to the recorded baseline afterwards. Restoration is not confirmed by the absence of an error.
- Rebuild whatever the test actually loads. A mutation of a source that a bundle is built from proves nothing until the bundle is rebuilt, and a staleness guard that misses that source shows a false green.
- When a rebuild is costly, batch mutations that reach disjoint tests into one run; re-run any surprising green in isolation.
- Confirm the tree with a check that sees ignored files. `git status` reports clean for a deleted build artifact or runtime marker, so a clean `git status` alone does not show a mutation was undone.

Mutate the subject under review, never the environment that runs it. Needing to change build or server state to get a run is the blocked case in the evidence standard.

A mutation result applies only to the assertions it exercises.
