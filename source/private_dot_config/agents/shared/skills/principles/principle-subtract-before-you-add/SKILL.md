---
name: principle-subtract-before-you-add
description: "Apply when planning or implementing a change that adds or alters behavior, validation, abstractions, prompts, compatibility, scaffolding, or process: remove unnecessary complexity before adding what the contract requires."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/principle-subtract-before-you-add"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
---

# Subtract Before You Add

When changing a system, simplify the existing design before extending it.

Remove dead, redundant, compensatory, speculative, and duplicate complexity
before adding behavior, validation, abstractions, prompts, compatibility
layers, scaffolding, or process. Add only what current behavior, the
specification, or an approved contract requires.

Preserve required behavior, explicit compatibility boundaries, approved product
intent, and concrete constraints. Subtraction does not permit discarding
authority or information.

Apply the sequence deliberately:
- Remove stale references instead of leaving content-free stubs.
- Remove duplicated instructions and speculative extensions.
- Simplify before polishing or adding scaffolding.
- Fix the problem at the point of authority; do not delete downstream symptoms
  while leaving the cause.

Prefer the smallest clear change that satisfies the contract. Treat every new
rule, layer, guard, prompt, and process step as a cost requiring evidence.
