---
name: punch-out
description: "Use to punch out or clock out: run the end-of-day routines."
---

# Punch out

Gather evidence once, then run the routines below for one day: today in local time, or the date the user names. Keep that date across midnight. An invocation authorizes the daily-note write; repository checks are read-only.

## Gather

Run [scripts/gather.py](scripts/gather.py) with `python3`, passing `--date YYYY-MM-DD`, `--exclude-session <current-session-id>` and `--output <session-files>/punch-out-YYYY-MM-DD.json`. Use `--help` for additional paths or an alternate local session database.

The JSON is shared input for every routine: local-host Atuin timestamps and paths, same-day session metadata and half-hour interaction windows, discovered repositories and worktrees, dated commits and reflog events, branch issue keys, and current publication status of every local branch. Managed dotfile paths resolve through chezmoi. Raw shell commands are omitted.

Read the relevant JSON sections rather than loading the entire file. Exit 1 means partial evidence: inspect warnings and report the affected coverage. Investigate unresolved paths using session context; add known source repositories with `--path` and rerun when needed. Missing sources or inaccessible repositories leave coverage unknown.

Group evidence by repository and issue/concern, retaining timestamps and source IDs for follow-up. Branch metadata and commit dates are clues; local reflogs and conversation content establish work performed. Remote fetch events alone establish downloaded history.

## Routines

1. Summarize the day's work with the `summarize-sessions` skill, supplying the gathered evidence for discovery, corroboration and relative emphasis.
2. Write that summary to the `Summary` section of the daily note with the `daily-note` skill. Skip this when the summary found no substantive work.
3. Check `publication` for every discovered repository, including branches outside the day's activity. Report repository, branch and unpublished-commit count, plus branches ahead of a remote upstream or with missing upstreams. Separate tracking gaps from unpublished commits: commits reachable from another remote ref are published. For many findings, give per-repository totals and the day's relevant branches first, linking the evidence file for the complete list. Report incomplete checks explicitly.

Publication status is current at collection time, even for a historical punch-out. Comparisons use cached remote refs and can be stale. Do not fetch, push, commit, or change branches as part of this routine.

Report each routine's outcome or skip reason concisely, expanding the publication check only for actionable findings. Keep the evidence inventory out of the written summary.

Validate the collector with `python3 <skill-dir>/scripts/test_gather.py`.
