---
name: principle-fix-root-causes
description: "Apply during bug diagnosis to select a fix at the causal authority rather than guard a symptom."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/principle-fix-root-causes"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
disable-model-invocation: true
---

# Fix Root Causes

Fix the cause at the authority that owns the incorrect behavior. Reproduce the failure first; do not infer a cause from a plausible code path.

## Trace to the authority

Ask why the observed failure occurs, repeatedly, until the answer reaches the configuration, state, contract, or component that can actually prevent it. Prefer changing that authority over adding a downstream guard that hides its output. A symptom guard is appropriate only when the boundary itself owns the contract.

Check the pattern, not only the reported instance. Compare nearby working cases, callers, inputs, environments, and state transitions. Look for the smallest shared condition that explains both the failure and its scope.

Instrument the relevant boundary or data flow when evidence is missing. Measure inputs, outputs, state, and timing rather than guessing from source inspection. For failures that appear only after restart, suspect persistent state, initialization, migration, or cache restoration before blaming transient runtime logic.

The resulting fix should make the reported behavior correct at its source and preserve the invariant for equivalent cases.
