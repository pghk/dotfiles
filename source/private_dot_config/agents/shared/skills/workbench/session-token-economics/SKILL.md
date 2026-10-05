---
name: session-token-economics
description: >
  Measure where a Pi session's billed tokens actually go. Use when asked to analyse token cost, context bloat, or spend for a coordinator or agent session; to compare runs before and after a skill, prompt, or extension change; or to answer why a run cost so much, what is filling the context window, or whether a change genuinely reduced token use. Also use before claiming a context-economy change worked. Keywords: token economics, token cost, context bloat, billed tokens, cacheRead, residency, expensive run, session analysis, ~/.config/pi/sessions.
---

# Session Token Economics

Sessions are JSONL under `~/.config/pi/sessions/<encoded-cwd>/`, one file per session plus `forks/` and per-child transcripts. Records with `type: "message"` carry `role` of `assistant`, `user`, or `toolResult`. A `toolResult` names its `toolName` and content; its arguments live on the matching `toolCall` in the preceding assistant message.

## The model

A turn is billed for everything resident in its context, so a tool result costs its own size multiplied by the number of turns that follow it. Late-arriving bulk is cheap and early-arriving bulk is expensive, independent of whether it was ever used again.

```sh
skills/workbench/session-token-economics/scripts/token-economics SESSION_JSONL [--json] [--top N]
```

It reports turns, billed prompt tokens, peak context, the residency multiplier, the cost split, residency by category, repeat reads, the largest individual residents, and a hash for every instruction file read. `--help` lists the rest.

## Establish before concluding

**Pin the version that ran.** A session loads a skill when it reads it, which is not when the session started and not what is on disk now. Match the reported `sha256` of each instruction read against the candidate revisions before attributing anything to a change:

```sh
for c in REV_A REV_B; do printf '%s %s\n' "$c" "$(git show $c:path/to/SKILL.md | shasum -a 256 | cut -c1-12)"; done
```

**Calibrate bytes per token.** The tool measures the ratio from turns where one result dominates the context delta and reports the sample count. Prose runs about 4 bytes per token; aligned Markdown tables and their diffs have measured over 11. Assuming 4 across a session dominated by table diffs overstates that content roughly threefold. Where one content type dominates a conclusion, recalibrate against only the turns carrying it.

**Separate extension-injected text from what the agent asked for.** Formatter echoes, tool-result decorations, and similar additions are billed to whichever tool call carried them and will otherwise be credited to the agent's judgement — or to whatever skill changed in the same window. The tool splits them out; report shares both ways when an extension changed too.

**Read the turn after a failure.** A metric can improve because the agent complied or because it was forced into a cheaper recovery path. Failed edits followed immediately by targeted greps are recovery, not discipline. Check what the next turn does before crediting a rule.

## Comparing runs

Compare at equal turn index, not on totals: a longer run has a higher peak and a higher multiplier regardless of efficiency. Per-turn residency and category shares are the comparable figures.

Absence of a post-change run is the finding. Report it and stop; do not estimate what a run would have cost.

## Reading the result

The cost split decides where leverage exists. When `cacheRead` dominates, the run is paying for residency and the only lever is what enters context and how early — output and `cacheWrite` optimisation cannot reach it. A high `cacheWrite` share instead points at cache invalidation, which is a different problem.

Attribute by category before ranking individual results. A single 50KB read is conspicuous; twenty instruction files loaded in the first ten turns are not, and routinely cost more.

For a coordinator, ask what each resident is _for_. Guidance the coordinator never applies, corpus gathered where an answer would do, and evidence it wrote itself are the recurring three, and each is a placement error rather than a size problem.

## Tests

`tests/token-economics.sh` runs the tool against a fixture whose arithmetic is checkable by hand, covering residency weighting, calibration, and echo separation.
