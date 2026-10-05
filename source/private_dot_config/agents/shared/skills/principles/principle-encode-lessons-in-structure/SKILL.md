---
name: principle-encode-lessons-in-structure
description: "Use when the same instruction or correction recurs, compliance fails repeatedly, or you are deciding how to make a recurring rule enforceable. Prefer a structural mechanism over another textual instruction."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/principle-encode-lessons-in-structure"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
---

# Encode Lessons in Structure

Recurring corrections are learning signals. When the same instruction or correction recurs, ask what mechanism can make the rule durable instead of adding another reminder.

## Choose the strongest practical mechanism

Ask whether the rule can become:

- a type constraint that makes invalid states unrepresentable
- static analysis, a lint rule, or a CI check
- metadata or a configuration flag
- a canonical API or helper that owns the behavior
- a runtime validation or safety check
- a script, generator, or other automation
- a test that fails when the invariant is broken

Choose the strongest practical mechanism for the failure. Prefer making invalid states unrepresentable, then enforceable checks or canonical interfaces, and use textual judgment guidance only when structure cannot express the rule reliably. When structural enforcement fully owns the behavior, delete redundant textual instructions so there is one authority.

Route the fix to the owning layer and close the loop by applying the approved change and checking that the recurring failure is addressed. Do not stop at acknowledgment without persistence, recording without routing, or fixing one instance while the recurring pattern remains.

## Scope and authorization

Within approved scope, implement the structural fix and remove instruction made redundant by it. Outside approved scope, propose the exact mechanism, destination, and owner, then wait for approval. Do not auto-modify instructions, tools, configuration, or repository state merely because a structural fix seems preferable.

For a one-off mistake, discard it or report it as a one-off; do not create a universal ledger. If a recurring issue is outside scope, propose a concrete authorized follow-up naming the mechanism and owner instead of generic todo or “brain note” language.

## Anti-patterns

- **Acknowledgment without persistence:** “I’ll keep that in mind” does not change future behavior.
- **Recording without routing:** a note about a lint rule is not a lint rule.
- **Fixing without generalizing:** correcting one occurrence while leaving the recurring pattern available.
- **Text competing with structure:** retaining duplicated prose after the owning mechanism enforces the rule.
