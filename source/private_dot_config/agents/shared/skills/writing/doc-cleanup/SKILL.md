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

## Principles

- **Purpose determines retention.** Identify the audience and reader task. Keep information that serves them. Distinguish knowledge irrelevant to this page from knowledge irrelevant everywhere.
- **Simplify before polishing.** Remove established redundancy and unnecessary material before detailed verification and wording work. Preserve concrete constraints, exceptions, domain terms, and rationale that still explain a relevant decision.
- **Use the cheapest sufficient evidence.** Start with authoritative code, configuration, and other reachable sources. Distinguish what inspection establishes from what remains unobserved. Suggest a focused test when it would resolve meaningful uncertainty.
- **Separate description from intent.** Correct descriptive errors when their authority settles the fact. Surface conflicts involving requirements, guarantees, or intended behavior instead of silently making prose or implementation agree.
- **Keep knowledge at a maintainable owner.** Prefer an existing canonical destination and link rather than duplicate. Extract only when ownership or use improves. Retain enough local context for the original document to remain useful.

## Decide what to remove or move

For each passage, identify the reader question it answers and whether that question still matters. Remove filler and exact duplication when the surviving authority is clear. Move useful but misplaced knowledge. Verify suspected obsolescence before deletion; disagreement with code alone does not invalidate a requirement.

Choose the least costly home that preserves the necessary meaning:

| Home | When it earns its place |
| --- | --- |
| Code itself | Names, signatures, types, domain values, or control flow can express the fact clearly at the point of use. Suggest a refactor when prose compensates for misleading names, unexplained booleans, hidden dependencies, or unnecessarily tangled logic. |
| Docblock | A caller or maintainer needs a symbol-level contract that its name and signature cannot express: semantic preconditions, side effects, lifecycle obligations, or meaningful failure behavior. Class-wide context belongs on the class; method-specific obligations belong on the method. Omit restated types and implementation narration. |
| Inline comment | A particular implementation choice would otherwise be surprising or look incorrect. Explain its local constraint or rationale beside that choice. Put caller obligations at the symbol boundary rather than inside the implementation. |
| Document file | Readers need a task guide, conceptual model, cross-component relationship, external contract, or broader rationale. Facts being reconstructible from code does not eliminate explanatory value when reconstruction requires substantial reader effort. |
| Test | An example, edge case, or invariant needs executable verification. A test protects behavior; it does not automatically replace an explanation or usage guide. Suggest the observation and seek authorization. |
| Skill | The content directs an agent through a task or decision procedure. Keep knowledge human contributors also need in ordinary documentation. Propose governing-instruction changes for approval. |

Split or create a document only when a distinct reader task, ownership boundary, or maintenance pattern justifies it. File length alone does not justify a split. Repair affected links and navigation when material moves.

### When clearer code can eliminate prose

Recommend a concrete change and name the explanation it would make unnecessary. Replacing `process(true)` with an explicit domain operation, for example, may remove a paragraph explaining the boolean.

Remove that explanation only after the replacement is authorized, implemented, and verified, and readers can recover the same necessary meaning at the relevant boundary. Preserve rationale and external constraints that better naming cannot express. Do not replace a paragraph with an elaborate abstraction or a sentence-length identifier.

## Ordered sweeps

These sweeps order effort; they do not require repeated full-file passes or a claim ledger. A discovered dependency may require an earlier check.

1. **Orient.** Establish scope, audience, reader task, applicable instructions, governing authorities, and existing knowledge owners. Skim the bounded area before choosing local edits.
2. **Prune.** Remove clearly unnecessary material, filler, and established duplication. Flag uncertain removals. Preserve useful knowledge that needs a different home rather than discarding it as irrelevant.
3. **Route.** Assess the surviving structure and ownership using the placement rules. Identify consolidation, relocations, and concrete changes that could eliminate the need for prose. Prefer existing owners.
4. **Verify.** Check material surviving claims, commands, examples, references, uncertain removals, and proposed corrections against their authorities. Inspect code and configuration first where they govern the claim; consult authoritative external sources when needed. For an unresolved behavioral claim, propose a specific test and explain the uncertainty it would resolve. Keep unavailable evidence and uncertainty visible rather than silently certifying or deleting useful knowledge.
5. **Edit.** Complete authorized corrections and relocations, repair references, then tighten the remaining prose. Use [code-style](../../code-style/SKILL.md) for comments and normal repository prose. For substantial document restructuring, use [technical-writing](../technical-writing/SKILL.md); for the final prose cleanup, use [unslop](../unslop/SKILL.md). Preserve necessary conditions and meaning while removing filler and correction residue. Describe present purpose, responsibilities, and behavior.
6. **Check and report.** Read the result in the order readers will use it. Check claim support, coherence, links, discoverability, duplication, and preservation of necessary information. Check that each completed extraction has a reachable owner and the original document still serves its purpose. Briefly report substantive corrections and relocations, unresolved conflicts or uncertainty, and proposed actions requiring authorization. State the limits of inspection without claiming runtime verification.

Existing writing, testing, and artifact-specific skills own their detailed methods. This skill owns cleanup sequencing and knowledge-placement judgment. Use purpose-appropriate review for prose; do not manufacture runtime testing for documentation edits.
