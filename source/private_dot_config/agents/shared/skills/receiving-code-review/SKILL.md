---
name: receiving-code-review
description: Use when receiving, evaluating, responding to, or applying code-review feedback; verify claims before changing code.
license: MIT
metadata:
  source: "https://github.com/obra/superpowers/tree/b36e0829c6d0140e93cfef2ca599b1b07d4a7797/skills/receiving-code-review"
  upstream-revision: "b36e0829c6d0140e93cfef2ca599b1b07d4a7797"
  provenance: "adapted-from-upstream"
---

# Receiving Code Review

Read all applicable feedback before acting, and identify dependencies among findings.

For each material claim, verify it against current codebase or runtime evidence.
For behavioral claims, run existing relevant tests before investigating or changing code.
Classify each finding as valid, unclear, conflicting with accepted authority,
unsupported, or out of scope.

Order accepted work by dependency and risk, and validate each focused change.
Record unresolved uncertainty rather than treating it as an implicit acceptance.

Ask only for clarification that blocks dependent work. Proceed with independent
accepted items; one unclear finding does not stop unrelated work.

Explicit user decisions remain authoritative until revised. Reviewer feedback does
not silently override specifications, contracts, or user constraints.

Push back concisely with evidence when a suggestion is incorrect, unnecessary,
incompatible, or speculative. Do not perform agreement or implement blindly.

When asked to apply accepted findings, use the [implement transition](../transitions/implement/SKILL.md).
Preserve dependency and risk order, with focused validation. Apply
[Prove It Works](../principles/principle-prove-it-works/SKILL.md) before claiming
completion; reuse the focused validation rather than duplicating it.
