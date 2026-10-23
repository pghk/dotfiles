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
4. **Is it true?** Verify the surviving claim at the chosen level of precision against authoritative code, configuration, or other reachable sources. Use the cheapest sufficient evidence and distinguish inspection from observed behavior. Correct descriptive errors; keep conflicts with requirements and unavailable evidence visible. Distinguish implemented behavior from intended or supported use; ask the user when sources do not establish the latter. Propose a focused test when it would resolve meaningful uncertainty.

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

1. **Assess the whole scope.** Read the named scope in full before choosing local edits. Establish its audience, reader tasks, governing authorities and knowledge owners. Decide what each document contributes and what structure serves those tasks. Evaluate the existing sections by that purpose, including whether they earn a place at all.
2. **Align on substantive changes.** Present the whole-scope diagnosis, proposed structure, substantive removals and relocations, and unresolved intent for approval before editing. Explain the value being preserved or removed. For each proposed relocation, name the destination and the contract or rationale it will carry. Routine wording and unambiguous factual corrections remain autonomous.
3. **Evaluate and edit.** Apply the four questions to every statement within the agreed structure. Record the reader need and chosen owner for non-obvious knowledge-placement decisions. For retained material, identify the work it saves compared with source or another owner. Verify claims, complete authorized removals and relocations, then repair references and navigation.
4. **Review the whole result.** Read in reader order against the agreed tasks and structure. Completion requires a cohesive, useful scope: every retained section contributes, necessary knowledge is preserved, and each extraction has a complete, reachable owner while the original document remains useful. Check claim support, links, discoverability and duplication. Briefly report substantive changes, unresolved conflicts and proposals requiring authorization. State inspection limits without claiming runtime verification.

Use [code-style](../../code-style/SKILL.md) for comments and normal repository prose. For substantial document restructuring, use [technical-writing](../technical-writing/SKILL.md); for the final prose cleanup, use [unslop](../unslop/SKILL.md).

Existing writing, testing, and artifact-specific skills own their detailed methods. This skill owns cleanup sequencing and knowledge-placement judgment. Use purpose-appropriate review for prose; do not manufacture runtime testing for documentation edits.
