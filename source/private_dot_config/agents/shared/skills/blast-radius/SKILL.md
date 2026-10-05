---
name: blast-radius
description: "Use for an explicit blast-radius or what-could-this-break request, or when assessing a change whose safety depends on effects beyond the diff or local module. Find and prove the one or two non-local safety facts; do not stop at listing callers."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/blast-radius"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
---

# Blast Radius

Use this skill for an explicit blast-radius or “what could this break?”
request, or when a change is safe only if effects beyond the diff or local
module are understood. Its purpose is to find the one or two non-local facts
that make the change safe and prove them, not to produce a long caller list.

## Trace beyond the diff

Read the actual diff or proposed change: symbols added, changed, and removed,
including behavior the diff leaves implicit. Read direct dependents and
consumers, but do not stop at listing callers. Follow facts grep can miss:
wire and persistence formats, timing and lifecycle, pinned dependency behavior,
cross-language consumers, feature flags, indirect state, and code several
hops downstream. Check the relevant pinned source, contract, or local patch
when a dependency is load-bearing.

Ask: “What is the one fact this change is safe because of?” Keep the answer
specific enough to falsify. Examples include a changed call receiving only
already-dead entries, a compatibility field remaining present on the wire, or
a lifecycle path making teardown idempotent.

## Prove each load-bearing fact

For every safety fact that matters, obtain the cheapest credible proof:

1. Read the pinned dependency source or authoritative contract.
2. Show directly that the bad case cannot reach the changed boundary.
3. Run a small script or test against the real code and fail loudly if the fact
   is false.
4. Reproduce the relevant path in the running application when that is the
   cheapest reliable observation.

Prefer executable evidence when it is cheap. Source inspection and plausible
reasoning support an observation but do not replace it when behavior can be
observed. If a fact cannot be proven, mark it **unproven** and name the
specific observation needed. Do not upgrade a grep result or an unexecuted
inference into certainty.

Apply [Prove It Works](../principles/principle-prove-it-works/SKILL.md) where
completion depends on a runtime claim. Scale investigation to coupling,
uncertainty, and consequence; do not require a full suite for a local fact.

## Return concise findings

State the load-bearing safety facts and their evidence, confirmed risks,
material risks the evidence cleared, and the smallest remaining falsifier.
Name affected boundaries and exact commands, sources, contracts, or runtime
observations where they matter. If nothing remains, say so while retaining the
limits of the evidence.

Do not require a report file, multi-model review, merge or ship framing, or a
fixed report template. Keep the conclusion bounded by what was actually
observed.
