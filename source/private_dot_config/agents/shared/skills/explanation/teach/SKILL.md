---
name: teach
description: >
  Teach a subsystem, change, concept, or code path when the user asks “teach
  me”, “help me understand”, or requests a pedagogical explanation. Build a
  learning sequence and mental model from purpose through flow, example,
  rationale, and consequences. Use how or why directly for a focused mechanics
  or rationale question instead of forcing a lesson.
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/teach"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
---

# Teach

Create understanding, not merely an answer. Infer the reader's starting point
from the request and conversation; if it matters and cannot be inferred,
briefly state the assumption. Introduce only the terms needed for the model.

Build the explanation in this order, adjusting it to the subject:

1. **Purpose:** what problem the thing solves and what the reader should be
   able to predict afterward.
2. **Core model:** the few concepts, boundaries, and ownership relationships
   that make the system legible.
3. **Flow:** the present input-to-output path, lifecycle, and visible effects.
   Gather mechanics from [how](../how/SKILL.md) only where they are needed.
4. **One concrete example:** walk one realistic request, state change, or
   change scenario through the model; cite real paths and symbols when useful.
5. **Rationale and consequences:** explain supported design reasons from
   [why](../why/SKILL.md) only where they clarify the lesson, then state what
   follows for use, debugging, or modification.

Label known facts, supported inference, and unknowns. A short analogy is useful
only if it preserves the important boundary; do not translate jargon without
building the underlying model. Avoid code dumps, compulsory quizzes,
patronizing language, and broad follow-up work. Compose `how` and `why`
selectively, not as a mandatory two-skill investigation. Keep the lesson
bounded by the reader's question and stop once they can use the model.
