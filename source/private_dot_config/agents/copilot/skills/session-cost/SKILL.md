---
name: session-cost
description: "Report where a Copilot CLI session's AI credits went. Use for session cost, token usage, AIU, or subagent spend review."
disable-model-invocation: true
---

# Session cost report

Run `python3 scripts/session_cost.py <session-id-or-prefix>` (or `--latest`) from this skill's directory. `--list` prints recent session ids with branch, AIU and summary. `--help` lists the flags.

The report reads `~/.copilot/session-store.db` and the session's `events.jsonl`, and prints markdown:

- **Headline:** total AIU, split by main vs subagents and by model.
- **Top spenders:** the costliest actors with agent type, who chose the model, and the prompt that began the turn.
- **Cost by turn:** main vs subagent AIU, main context size, checkpoints, and the triggering prompt.
- **Flags:** subagents that inherited Opus, context rewritten after idle gaps, uncompacted contexts, and call counts that suggest loops.
- **Recent sessions:** the same totals for neighbouring sessions.

Present the report to the user and point out the flags that carry the most AIU. Offer the fix each flag implies; do not apply it unprompted.
