# Skill framework

This directory contains a personal framework for composing agent guidance. It explains where the pieces come from, how they fit together, and how they were assembled. Skill frontmatter and bodies remain the operational authority.

## How the framework fits together

The framework composes the smallest relevant set of guidance for a task. It has no universal router.

- **Transitions** adopt a new governing goal and authority within the current session. [`to-spec`](transitions/to-spec/SKILL.md) turns a conversation into accepted product intent. [`to-tickets`](transitions/to-tickets/SKILL.md) divides that intent into vertical slices and real dependencies. [`implement`](transitions/implement/SKILL.md) carries accepted work through execution and integration. A transition starts only from its explicit command or an unambiguous natural-language request.
- **Playbooks** supply methods for recognizable task shapes. [`bug-fix`](playbooks/bug-fix/SKILL.md) starts from a credible reproduction. [`refactor`](playbooks/refactor/SKILL.md) starts from known-good behavior. [`ad-hoc-playbook`](playbooks/ad-hoc-playbook/SKILL.md) is an explicit manual method for substantial work that has no narrower playbook.
- **Principles** supply reusable judgment at a decision point. They cover concerns such as subtraction, evidence, domain modeling, test quality, reader load, and structural enforcement.
- **Writing skills** compose and revise human-facing artifacts such as commit messages, changeset descriptions, and QA plans.
- **Explanation skills** distinguish present mechanics, rationale, and teaching.
- **Continuity skills** preserve or transfer active work across agents, sessions, and audit boundaries.
- **Focused capabilities** remain at the skills root. They own bounded operations such as code archaeology, review, skill management, and retrospective analysis rather than a workflow phase.
- **Workbench skills** are evolving or deliberately specialized. Broadly applicable, proven skills may graduate to the root. Intentionally narrow skills may remain in `workbench/`.

The lowest responsible artifact owns each rule. Transitions own changes to the session's governing goal and authority. Playbooks own task methods. Principles own decisions that recur across methods. Focused capabilities own operations with their own entry conditions.

## Layout and invocation

`transitions/`, `playbooks/`, and `principles/` hold the three compositional layers. `writing/`, `explanation/`, and `continuity/` group focused capabilities by responsibility. `workbench/` holds evolving or deliberately specialized skills. A skill may place branch-specific material in `references/`, reusable tools in `scripts/`, and static templates in `assets/`. [`AGENTS.md`](../AGENTS.md) carries a small foundation of cross-cutting judgment. Other principles remain discrete skills so they can be loaded only at the decision points where they help. Model invocation is chosen per skill rather than by category.

The skill loader recursively discovers `SKILL.md` files. Model-visible skills expose their descriptions as discovery pointers. A skill is model-visible when autonomous use is valuable, missing it has meaningful cost, its responsibility does not overlap heavily with another visible skill, and its context cost is justified. Its description must also identify matching work reliably. When only the description fails that test, improve and evaluate the trigger before making the skill manual.

Manual skills set `disable-model-invocation: true` and remain available through explicit invocation. Disabling model invocation removes automatic discovery while preserving composition. A loaded playbook or skill may follow an explicit relative link to load a manual skill where it applies. This keeps guidance at its point of use instead of copying it into every workflow.

Descriptions, resident bodies, and loaded references all spend context. The framework therefore keeps common steps near their point of use, discloses branch-specific detail through references, and measures skill size in bytes. [`skill-management`](skill-management/SKILL.md) and its [writing-for-agents reference](skill-management/references/writing-for-agents.md) own the detailed authoring method.

## Methodology

The durable delivery flow is **conversation → spec → vertical tickets → implement**. The spec owns product intent and constraints. Tickets own execution slices and dependencies. The implementation primary owns intent, ordering, and integration. Bounded subagents fit coherent vertical tickets or specialist work; direct work fits tiny or tightly coupled changes.

Task methods compose with this flow. Bug fixes establish failure before implementation investigation. Refactors establish a green baseline before structural edits. Both use the cheapest credible observation that could falsify the relevant claim. Focused self-check is the default; independent review grows with risk, breadth, uncertainty, or poor observability. [`show-your-work`](continuity/show-your-work/SKILL.md) supports work that would otherwise be hard to audit.

[`retro`](retro/SKILL.md) routes recurring lessons. [`Encode Lessons in Structure`](principles/principle-encode-lessons-in-structure/SKILL.md) selects durable enforcement for repeated failures. [`Build the Lever`](principles/principle-build-the-lever/SKILL.md) identifies substantial repeated work that deserves reusable tooling. [`Subtract Before You Add`](principles/principle-subtract-before-you-add/SKILL.md) keeps both paths from accumulating redundant process.

[`handoff`](continuity/handoff/SKILL.md) emits a standalone prompt that another agent can follow without consumption instructions. [`pickup`](continuity/pickup/SKILL.md) independently rediscovers progress from live repository state and durable authority when no adequate guidance exists.

## How the framework was assembled

The framework was built in verified vertical slices rather than as one wholesale import:

1. **Collect candidate material.** Existing local skills supplied the user's established working methods. External collections supplied additional principles, task methods, and writing patterns.
2. **Classify responsibility.** Each candidate was evaluated as a transition, playbook, principle, focused capability, reference, or omission. The classification followed what the guidance does, not the directory where its source stored it.
3. **Choose invocation deliberately.** A skill became model-visible only when it had a reliable trigger, autonomous value, meaningful miss cost, low overlap, and acceptable context cost. Human-invoked or situational guidance remained manual.
4. **Reconcile at the point of authority.** Overlapping material was merged, linked, or removed. In several cases the imported principle became authoritative and surrounding skills were deduplicated around it. Required behavior was retained while rejected workflow behavior was intentionally removed.
5. **Adapt to the local method.** External ideas were rewritten to match the explicit transition flow, bounded delegation, risk-scaled review, evidence standards, and repository constraints. Source-specific tooling, model routing, issue trackers, and mandatory ceremony were not carried over unless they served the accepted method.
6. **Verify each slice.** Every slice checked frontmatter, unique names, invocation state, relative links, loader diagnostics, scoped diffs, and byte changes before commit.

This process treats provenance as evidence, not authority. Local judgment and accepted constraints decide the resulting behavior. An upstream source explains where an idea came from; the current skill body defines what is true here.

## Maintenance

Refine an existing owner before adding another artifact. A new skill needs a distinct responsibility and a trigger that reliably identifies it. Recurring instructions should become structural enforcement where a type, check, canonical interface, configuration, or tool can own the behavior. Manual skills are preferable when human invocation is reliable and autonomous activation adds little value.

External adaptations record source, revision, provenance, and license metadata in frontmatter. Maintenance checks names, frontmatter, invocation state, loader diagnostics, links, scoped diffs, and byte deltas. Use [`technical-writing`](writing/technical-writing/SKILL.md) and [`unslop`](writing/unslop/SKILL.md) when revising this page.

## Provenance and attribution

Local composition and Paul Hendrick's user-authored judgment and operations are primary authority. Earlier local handoff and execution-heuristic material also informed the resulting framework. Individual skill frontmatter records the exact source for each adaptation.

The external source snapshots are:

- [Superpowers](https://github.com/obra/superpowers/tree/b36e0829c6d0140e93cfef2ca599b1b07d4a7797/skills), revision `b36e0829c6d0140e93cfef2ca599b1b07d4a7797`.
- [Matt Pocock skills](https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd), revision `74ca5fe077456a0b3b2f5310cf9430999fd0b5fd`.
- [Poteto/Pstack Cursor plugins](https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills), revision `e31650eea443aaea1e84cc15d88c13f40080b275`.

### Adaptation map

**Superpowers** contributes the base design-conversation method in [`brainstorming`](brainstorming/SKILL.md), the technical-feedback discipline in [`receiving-code-review`](receiving-code-review/SKILL.md), and parts of the completion and test-quality principles.

**Matt Pocock skills** contribute the three delivery transitions, the diagnosing-bugs basis of `bug-fix`, the frontier protocol in `brainstorming`, the external handoff pattern, one source for `retro`, the `wait-what` behavior incorporated into [`bro`](bro/SKILL.md), and the [writing-for-agents reference](skill-management/references/writing-for-agents.md).

**Poteto/Pstack** contributes a selection of principles and [`show-your-work`](continuity/show-your-work/SKILL.md), plus the bases for [`blast-radius`](blast-radius/SKILL.md), `ad-hoc-playbook`, `retro`, `pickup`, `bro`, [`how`](explanation/how/SKILL.md), [`why`](explanation/why/SKILL.md), [`teach`](explanation/teach/SKILL.md), `technical-writing`, and `unslop`. Its test guidance also informs `bug-fix` and the test-quality principle.

### MIT license

The external material above is used under the MIT License with these copyright notices:

Copyright (c) 2025 Jesse Vincent

Copyright (c) 2026 Matt Pocock

Copyright (c) 2026 Lauren Tan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notices and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
