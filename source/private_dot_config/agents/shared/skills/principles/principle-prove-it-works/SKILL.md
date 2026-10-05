---
name: principle-prove-it-works
description: "Use when about to claim work is complete, fixed, correct, or passing; before committing; or when asked whether something works. Require fresh, claim-matched evidence."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/principle-prove-it-works"
  additional-source: "https://github.com/obra/superpowers/tree/b36e0829c6d0140e93cfef2ca599b1b07d4a7797/skills/verification-before-completion"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  additional-source-revision: "b36e0829c6d0140e93cfef2ca599b1b07d4a7797"
  provenance: "adapted-from-upstream"
---

# Prove It Works

Use this principle only when completion or correctness is about to be claimed, before committing, or when asked whether something works.

Require fresh evidence matched to the exact claim:

1. State the exact claim.
2. Choose the cheapest credible observation that could falsify it at the relevant system boundary.
3. Run it fresh on the actual revision and environment, then read the result.
4. Bound the claim to what was observed and state material limits.

A proxy that cannot distinguish good from bad is not evidence for the claim. Source inspection supports an observation but does not replace runtime behavior when behavior can be observed. A passing build, compilation, lint, or diff review proves only that check unless the claim is specifically about it.

Scale breadth with blast radius, uncertainty, environment sensitivity, and observability. Do not require a full suite, an independent verifier, one observation per trivial subclaim, or a rigid report template by default. Report checks, results, and material limits concisely; retain residual uncertainty instead of upgrading partial evidence into a stronger claim.
