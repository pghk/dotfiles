---
name: handoff
description: >
  Produce a standalone, paste-ready prompt that lets a fresh agent continue
  an accepted task from durable authority and its current transition. Use only
  when the user explicitly asks for a handoff prompt, transfer prompt, or
  context for another agent. Keywords: handoff, handoff prompt, transfer to
  another agent, continue in a new session.
license: MIT
metadata:
  source: "https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd/skills/productivity/handoff"
  upstream-revision: "74ca5fe077456a0b3b2f5310cf9430999fd0b5fd"
  provenance: "adapted-from-upstream-and-local-handoff-frame-and-handoff-work"
disable-model-invocation: true
---

# Handoff

Produce one standalone prompt for a fresh agent. The result is the prompt
itself: it must not tell the receiving agent to use this skill, find another
summary, or follow separate consumption instructions. Keep it paste-ready and
normally inline. Write a file only when the user explicitly asks for one.

## Distill the accepted work

Produce one prompt that carries the durable context needed to act correctly
now. Distill conclusions rather than summarizing the session.

Before writing, verify the present repository or workspace state and every
reference you intend to cite. Read accepted specifications, tickets, ADRs,
audit trails, and other named durable authority. Check branches, commits, and
paths where they materially govern the next action. A reference is useful only
when its path, URL, or commit is stable and its role is clear. Do not turn an
inference, an unaccepted proposal, or a stale working note into authority.
Redact secrets and private identifiers.

Include, in direct executable language:

- the complete accepted goal and scope;
- the agreed method or current transition;
- binding, non-obvious constraints and invariants;
- known challenge classes that the agent must solve;
- exact references to accepted durable authority, stating what each artifact
authorizes and what to do after reading it;
- the relevant transition or playbook, with its repository-relative path when
available; and
- a concrete opening instruction that tells the receiving agent what to read,
verify, or do first.

Phrase references as instructions, not bibliography: “Read
`path/to/spec`; it defines the accepted behavior. Then inspect X and proceed
through Y.” Prefer stable references over copied content. Mention a failed path
only when it is a binding constraint on future work. Exclude reasoning trails,
failed or aborted attempts, superseded drafts, scratch work, commit logs, raw
diffs, session narration, and deferred or unaccepted decisions. This is not a
status report, ticket decomposition, retrospective, audit trail, or automatic
session summary.

## Shape and quality bar

Write flowing prose with short labelled sections only when they reduce reader
load. It should let an agent begin without reconstructing context, while
leaving durable artifacts as the source of detail. State uncertainty only when
it changes what the receiving agent may do; otherwise omit it. Do not invent
completion, authority, or a next step.

End with an actionable opening such as: read the named authority, inspect the
current branch/worktree, verify the stated frontier, then execute the named
transition. The receiving agent must be able to follow that instruction with
no additional skill, handoff, or explanation.
