---
name: brainstorming
description: "Use for a bounded design conversation: brainstorm or stress-test an idea or proposal, or explicitly grill a design decision. Facilitate one decision subject within supplied or established boundaries; do not choose the broader workflow, write durable artifacts, decompose tickets, implement, or perform generic code review."
license: MIT
metadata:
  source: "https://github.com/obra/superpowers/tree/b36e0829c6d0140e93cfef2ca599b1b07d4a7797/skills/brainstorming"
  upstream-revision: "b36e0829c6d0140e93cfef2ca599b1b07d4a7797"
  frontier-source: "https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd/skills/productivity/grilling"
  frontier-source-revision: "74ca5fe077456a0b3b2f5310cf9430999fd0b5fd"
  challenge-source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/interrogate"
  challenge-source-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-and-composed"
---

# Brainstorming

Turn one decision subject into an approved design through evidence-led frontier rounds.

## Boundary

This skill facilitates one subject only. Preserve the user's authority, settled decisions, exclusions, and vocabulary unless the user explicitly reopens them. It returns the approved design in chat; the caller owns any transition, durable artifact, ticket decomposition, or implementation.

At the start, establish:

- the subject and the authority that governs it;
- settled constraints and exclusions;
- open decisions and the return condition (including conflicts or scope breaches).

If context already makes these clear, state the boundary and first frontier in the same response; do not require a ceremonial confirmation turn. Inspect relevant project state, documents, and reachable evidence before proposing a design. Resolve repository and environment facts yourself rather than asking the user for facts you can establish. Delegated fact-finding is optional only when authorized and independently useful.

## Frontier protocol

Model the subject as a decision tree. A decision is ready only when its prerequisites are settled. At each round:

1. Compute the current material frontier: every ready choice whose alternatives materially affect behavior, correctness, architecture, compatibility, security, operations, user experience, or cross-component integration.
2. Ask the whole frontier in one numbered message. Each question must include concise context, viable options where they genuinely exist, and your recommended answer with reasoning. Never include a question that depends on another unresolved question in that same round.
3. Wait for the user's answers. Record settled decisions, surface any contradiction, hidden assumption, scope breach, or unsupported premise before expanding dependent branches, then recompute the frontier.

Resolve routine mechanics autonomously. Do not grow the tree with trivial choices. For material alternatives, lead with the recommendation and normally give two or three viable approaches with trade-offs. Exercise judgment: distinguish an actionable design conflict from a consideration or unsupported speculation. Actively test intent, contradictions, blind spots, failure modes, boundary cases, and whether a proposed mechanism serves the actual goal. State intent before adversarial challenge.

When all material branches are settled, present one coherent, compact design and request explicit approval once. Do not seek approval after each section or each round. Return the approved design in chat, then stop. Approval is required before treating the design as settled.

## Design quality

- Inspect current structure and follow established patterns, domain vocabulary, and interfaces.
- Prefer subtraction and YAGNI. Include targeted improvements that serve this subject, not unrelated refactors.
- Keep units isolated, with clear responsibilities and interfaces; identify what each does, how it is used, and what it depends on when that boundary is material.
- For technical realization, settle distinct concepts, their grouping, and the language mechanisms that carry them. Name the existing patterns followed and explain meaningful departures.
- Explicitly agree when a local implementation choice should remain with the implementer; an approved implementation-owned choice is not an unresolved design branch.
- Do not import multi-model fan-out, fixed reviewers or models, code-review scope, PR framing, agreement maps, or report templates.
