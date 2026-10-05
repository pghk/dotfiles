---
name: pickup
description: >
  Reconstruct durable project progress and resume an accepted task from the
  live repository state. Use when the user says pickup, pick this back up,
  resume this project or work, where did this project leave off, or asks to
  reconstruct progress because adequate guidance is missing. Keywords: pickup,
  resume work, pick back up, where did this leave off, reconstruct progress.
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/recall"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream-and-composed-with-local-dig"
---

# Pickup

Recover enough verified context to orient the user or resume the accepted
work. Pickup is a rediscovery procedure, not a general memory search and not
an implementation authority. Establish the topic, repository or workspace,
and the relevant time or scope boundary from the request and available
context. Ask one focused question only when multiple materially different
scopes remain plausible; otherwise investigate the most specific plausible
scope.

Inspect durable and live evidence first. Start at the repository root and
check:

1. `git status`, the current branch, and `HEAD`;
2. linked worktrees and their branches;
3. relevant local and remote-tracking branches, then recent commits and
   source-only commits that touch the topic;
4. accepted specs, tickets, ADRs, plans, and other named authority;
5. `.audit` trails and other explicitly named durable artifacts; and
6. stashes, only as read-only evidence when relevant.

Use exact paths and bounded searches. Do not scan unrelated projects, broad
private chat history, issue trackers, or external systems by default. Consult
user-named reachable evidence only when repository evidence cannot establish
the state. Never switch branches, apply or alter stashes, merge, push, clean,
or discard work merely to orient.

When progress or rationale is distributed across branches, rebased or copied
history, or thin commit context, use [dig](../../dig/SKILL.md) rather than
repeating its archaeology. A commit message alone does not prove completion:
read the relevant artifacts and diff, and run the cheapest credible observation
when a behavior claim is load-bearing. Do not mine unrelated transcripts.

## Reconstruct the state

Separate the result into **confirmed**, **supported inference**, and
**unknown or conflicting authority**. Confirmed facts come from current files,
repository state, accepted artifacts, or observed behavior. Label inferences
and preserve conflicts; ask before continuing when they change scope,
behavior, ownership, or safety.

Reconstruct these facts:

- the accepted goal and scope;
- the governing authority and its precedence;
- relevant work actually completed, with artifact or diff evidence;
- current branch, `HEAD`, worktree, and uncommitted state;
- unresolved blockers, decisions, and authority gaps;
- the ready frontier: the smallest safe next unit of work; and
- the next concrete action and applicable current transition or playbook.

Do not infer completion from commit subjects, branch names, timestamps, or a
clean worktree. If the evidence is insufficient, say what remains unknown and
what observation or authority would settle it. Do not convert a proposal,
scratch note, stale branch, or abandoned attempt into an accepted decision.

## Continue or orient

If the user asks only where the work stands, provide the verified brief and
stop. If the user asks to resume and the governing authority plus next action
are unambiguous, proceed through the appropriate current transition or
playbook after stating the frontier. A manual method still requires its own
explicit invocation. Pickup hands execution to the selected method after
rediscovery; it does not
replace the method or prescribe implementation.

If authority is missing or conflicts with live state, do not guess or begin
irreversible work. Report the conflict and ask the smallest question needed to
make continuation safe. Keep the result bounded to the named project and
scope, and distinguish observed state from conclusions throughout.

A useful orientation output is concise but complete: **Scope and authority**,
**Confirmed state**, **Supported inference**, **Unknowns or conflicts**,
**Ready frontier**, and **Next action**. Include exact paths, branch names,
SHAs, and commands when they make the result reproducible.
