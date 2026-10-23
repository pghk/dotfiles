---
name: doc-cleanup
description: "Manually invoked cleanup of a named documentation scope: verify claims, simplify prose, and put useful knowledge at its appropriate owner."
disable-model-invocation: true
metadata:
  provenance: "local-composition"
---

# Documentation cleanup

Make a named documentation scope accurate, useful, discoverable, and cheaper to maintain. Preserve useful knowledge rather than its current wording or location. Success is that readers can find trustworthy information where they need it, not a smaller word count or fewer files.

## Authority and scope

Start with named documents or a named documentation area. Follow references and consumers only as needed to verify claims or complete coherent relocations. Complete independent cleanup when another part is blocked.

Apply documentation and comment changes within that scope. Suggest concrete code refactors, tests, application behavior changes, and governing-instruction changes; obtain separate authorization before executing them. This includes running existing tests, writing new ones, and moving procedures into skills. Preserve source knowledge until its replacement is complete.

## Evaluate every statement

Evaluate the underlying knowledge, not just its current wording. For every statement, answer these questions in order:

1. **Is it valuable as documentation?** Identify the reader question it answers and how it helps someone understand, decide, or act. Remove filler, established duplication, and narration of readily readable code. Preserve explanations whose reconstruction would require substantial reader effort. A poorly written or partly incorrect statement may still contain useful knowledge.
2. **Is it in the right place?** Choose its maintainable owner using the placement rules below. Prefer an existing canonical destination and link rather than duplicate. Move useful but misplaced knowledge instead of discarding it as irrelevant to this page. Retain enough local context for the original document to remain useful.
3. **Is its level of detail appropriate for that placement?** Match the explanation to the destination's audience and reader task. Keep the necessary conditions, exceptions, domain terms, and rationale; remove detail the reader can obtain directly from that owner. Settle value and placement before polishing the wording.
4. **Is it true?** Verify the surviving claim at the chosen level of precision against authoritative code, configuration, or other reachable sources. Use the cheapest sufficient evidence and distinguish inspection from observed behavior. Correct descriptive errors; surface conflicts with requirements or intended behavior rather than silently making them agree with implementation. Keep unavailable evidence and uncertainty visible. Propose a focused test when it would resolve meaningful uncertainty.

This is an order of judgment and effort, not four full-document passes or a ban on early fact checks. Check facts earlier when needed to decide value or placement, including suspected obsolescence. Disagreement with code alone does not invalidate a requirement.

## Placement rules

Choose the least costly home that preserves the necessary meaning:

| Home | When it earns its place |
| --- | --- |
| Code itself | Names, signatures, types, domain values, or control flow can express the fact clearly at the point of use. Suggest a refactor when prose compensates for misleading names, unexplained booleans, hidden dependencies, or unnecessarily tangled logic. |
| Docblock | A caller or maintainer needs a symbol-level contract that its name and signature cannot express: semantic preconditions, side effects, lifecycle obligations, or meaningful failure behavior. Class-wide context belongs on the class; method-specific obligations belong on the method. Omit restated types and implementation narration. |
| Inline comment | A particular implementation choice would otherwise be surprising or look incorrect. Explain its local constraint or rationale beside that choice. Put caller obligations at the symbol boundary rather than inside the implementation. |
| Document file | Readers need a task guide, conceptual model, cross-component relationship, external contract, or broader rationale. |
| Test | An example, edge case, or invariant needs executable verification. A test protects behavior; it does not automatically replace an explanation or usage guide. Suggest the observation and seek authorization. |
| Skill | The content directs an agent through a task or decision procedure. Keep knowledge human contributors also need in ordinary documentation. Propose governing-instruction changes for approval. |

Split or create a document only when a distinct reader task, ownership boundary, or maintenance pattern justifies it. File length alone does not justify a split. Repair affected links and navigation when material moves.

### When clearer code can eliminate prose

Recommend a concrete change and name the explanation it would make unnecessary. Replacing `process(true)` with an explicit domain operation, for example, may remove a paragraph explaining the boolean.

Remove that explanation only after the replacement is authorized, implemented, and verified, and readers can recover the same necessary meaning at the relevant boundary. Preserve rationale and external constraints that better naming cannot express. Do not replace a paragraph with an elaborate abstraction or a sentence-length identifier.

## Complete the cleanup

1. **Orient.** Establish scope, audience, reader task, applicable instructions, governing authorities, and existing knowledge owners. Skim the bounded area before choosing local edits.
2. **Evaluate and edit.** Apply the four questions to every statement in scope. Complete authorized removals, corrections, and relocations, then repair references and navigation. Preserve source knowledge until its replacement is complete.
3. **Check and report.** Read the result in the order readers will use it. Check claim support, coherence, links, discoverability, duplication, and preservation of necessary information. Check that each completed extraction has a reachable owner and the original document still serves its purpose. Briefly report substantive removals, corrections, relocations, unresolved conflicts or uncertainty, and concrete proposals requiring authorization. State the limits of inspection without claiming runtime verification.

Use [code-style](../../code-style/SKILL.md) for comments and normal repository prose. For substantial document restructuring, use [technical-writing](../technical-writing/SKILL.md); for the final prose cleanup, use [unslop](../unslop/SKILL.md).

Existing writing, testing, and artifact-specific skills own their detailed methods. This skill owns cleanup sequencing and knowledge-placement judgment. Use purpose-appropriate review for prose; do not manufacture runtime testing for documentation edits.
