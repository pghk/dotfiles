---
name: principle-redesign-from-first-principles
description: "Apply when a new requirement lands on an existing design, spec, or document and the easy move is to bolt it on; redesign as if it had always been required."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/principle-redesign-from-first-principles"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
---

# Redesign From First Principles

When integrating a change, don't bolt it onto the existing design. Redesign as if the requirement had been there from the start.

- Read all affected files and understand the current design
- Ask: "if we were writing this from scratch with this new requirement, what would we build?"
- Propagate the change through every reference: types, docs, examples, rationale sections
- Think about the whole redesign, then deliver it incrementally

This is the method for preserving option value when integrating changes into an existing design.
