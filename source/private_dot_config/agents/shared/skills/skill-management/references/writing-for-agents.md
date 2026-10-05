---
license: MIT
metadata:
  source: "https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd/skills/productivity/writing-for-agents"
  upstream-revision: "74ca5fe077456a0b3b2f5310cf9430999fd0b5fd"
  provenance: "adapted-from-upstream"
---

# Writing for agents

Use this reference when drafting or restructuring a skill's instructions, description, context pointers, or linked references. It governs agent-consumed writing; `skill-management` remains authoritative for frontmatter constraints, trigger tuning, scripts, evals, and byte reporting.

## Spend context deliberately

A pointer is behavior, not navigation prose. Its wording determines whether the agent follows it, and when it reaches the target. Name the actual trigger branches: say what task, decision, or uncertainty requires the lookup. Remove duplicate synonyms that do not add a distinct branch. A vague “see this for more” pointer spends context without reliably changing behavior.

Separate two costs:

- **Context load:** bytes the model receives. Descriptions and resident instructions recur on every turn while the skill is loaded; references cost context from the turn they are read.
- **Human cognitive load:** scanning, interpreting, and remembering the guidance.

Optimize both. A shorter line is not automatically cheaper if it makes the model infer a missing condition; a longer line earns its cost when it makes activation or completion checkable.

Evaluate every body line and pointer against the default behavior: what behavior does it change, for which input, and what ongoing context cost does it impose? If the answer is none, remove it. Environment facts, configuration, and scripts are authorities; do not preserve a stale documentation cache when a cheap lookup can establish the current fact.

## Put guidance where it is used

Use an information hierarchy:

1. Put required, always-applicable steps inline in the resident instructions.
2. Put a procedure's detailed explanation beside the skill when it is needed to perform that procedure.
3. Put branch-specific lookup material in references reached by explicit, stable pointers.

Co-locate rules and their caveats. Keep one meaning in one authority; point to it rather than duplicating it in a second body or reference. Duplication drifts and forces the agent to reconcile apparent alternatives. A reference can contain a compact reminder when that reminder is necessary for independent use, but do not copy a whole rule set merely to make a page feel complete.

Split content only when sequence or invocation differs. A separate skill, playbook, or reference is justified when the agent must follow a different order, has a different entry condition, or needs a different lookup branch. Do not split a single sequence into artifacts just to shorten a file.

## Make instructions executable

Each step needs a checkable completion condition. State the observable result, artifact, command outcome, or decision that proves the step is done. If the task demands an exhaustive result, say so: “inspect every applicable entry” is different from “inspect representative entries.” Name boundaries, required inputs, and stopping conditions where omission would change the result.

Use established leading words when they sharpen a concept—such as “Required,” “Optional,” “Verify,” or “Do not”—but do not make a label carry a definition the surrounding text has not supplied. Prefer positive target behavior: tell the agent what to do and what successful completion looks like. Use a prohibition for a hard guardrail, and pair it with the replacement action (for example, “Do not infer the current setting; read the configuration and report the observed value”). Avoid vague exhortations such as “be careful,” “use best judgment,” or “provide sufficient detail.”

Descriptions and pointers should state the activation condition, the work covered, and any meaningful boundary. They should not summarize every section. A model-visible skill omits `disable-model-invocation`; its description is available for discovery. A manual skill sets `disable-model-invocation: true`; its description is not model-visible by default, while explicit user invocation remains available. Another skill may explicitly direct the agent to read a manual skill or reference by stable relative path. Do not treat manual status as unreachable status.

## Prune sediment

Remove stale caches of environment facts, irrelevant branches, historical explanation, and no-op instructions. Keep a line when it changes the agent's behavior or makes a required result verifiable. Move a low-frequency branch to a reference when its detailed material is not needed for the common path, then write the pointer so the branch is reachable at the moment it matters. Revisit pointers when the target moves, its trigger changes, or the default behavior changes.

Before finishing, inspect the complete linked surface:

- every relative link resolves from the file containing it;
- every pointer names a real condition and a stable target;
- required steps are inline or explicitly reachable;
- each instruction has a behavioral purpose and an appropriate context cost;
- no duplicated authority or stale environment claim remains.
