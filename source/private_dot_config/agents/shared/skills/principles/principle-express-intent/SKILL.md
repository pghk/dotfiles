---
name: principle-express-intent
description: "Apply when authoring or reviewing how code, tests, documentation, comments, commit messages, or skills express the purpose, behavior, constraints, and reasoning behind work."
---

# Express Intent

Establish intent from the governing request, specification, and accepted decisions. Distinguish required behavior from observed behavior and assumptions. Surface conflicting or unclear authority rather than inventing intent from the implementation or its descriptions.

Each artifact carries the part its reader needs:

- **Code** expresses behavior and structure through names, types, interfaces, and control flow.
- **Tests** protect required behavior with observations that distinguish it from a credible failure.
- **Documentation** carries standing contracts and constraints contributors need without reading history.
- **Comments** explain non-obvious local constraints where the code would otherwise read as a mistake.
- **Commit messages** explain why this change, now, in this form, including alternatives when they explain the choice.
- **Skills** carry reusable method lessons and procedures.

An artifact can be authoritative within its responsibility without expressing all the intent. Check representations against their governing sources, not merely against each other: a test can agree with code while encoding a contract incorrectly.

Prefer the most direct expression at the place the reader naturally encounters. Consider a focused behavior-preserving refactor before adding a comment when clearer names or structure can express the missing intent. Weigh structural churn against a precise explanation; external reasons and constraints may still require prose.

Preserve each necessary facet without repeating the whole account everywhere. A standing contract belongs in documentation even when its rationale also belongs in history. Sufficient expression needs no addition, and not every change needs every artifact.
