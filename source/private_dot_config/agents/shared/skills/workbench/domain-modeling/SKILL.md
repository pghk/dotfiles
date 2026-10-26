---
name: domain-modeling
description: "Use when a project's domain terms are being chosen, challenged or settled: naming a concept, choosing between words for one thing, deciding whether to adopt an external system's term, noticing a term that fits only some cases or conflicts with the code, or writing or editing CONTEXT.md. Records each settled term in the root glossary as it settles. Not for design decisions (brainstorming) or specs (to-spec)."
license: MIT
metadata:
  source: "https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd/skills/engineering/domain-modeling"
  upstream-revision: "74ca5fe077456a0b3b2f5310cf9430999fd0b5fd"
  provenance: "adapted-from-upstream"
---

# Domain Modeling

`CONTEXT.md` at the repository root is the project's glossary: terms and their
definitions, nothing else. Implementation details, decisions and plans belong
in specs, code and architecture docs, which use the glossary's terms.

While terms are in play:

1. **Challenge against the glossary.** When a term in use conflicts with
   `CONTEXT.md`, name the conflict and ask which meaning holds.
2. **Test a term against every case it covers.** A term that fits only one
   medium, source, arrangement or variant of the concept is too narrow;
   propose one that covers all of them.
3. **Sharpen overloaded terms.** When one word names two concepts, or two
   words name one, propose a canonical term and list the others to avoid.
4. **Place external vocabulary deliberately.** When an external system's term
   names a concept, settle whether the project adopts it as its own term or
   keeps it at the integration boundary.
5. **Cross-check the code.** Compare the term with how code, schema and docs
   use it, and surface contradictions.
6. **Record as it settles.** When the user settles a term, update
   `CONTEXT.md` in the same turn, in the format in
   [CONTEXT-FORMAT.md](CONTEXT-FORMAT.md). Create the file when the first
   term settles. Done when every term settled in the session is in the
   glossary, and every retired term is listed under `_Avoid_`.
