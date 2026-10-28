---
name: punch-out
description: "Use to punch out or clock out: run the end-of-day routines."
---

# Punch out

Run the routines below in order for one day: today in local time, or the date the user names. Use that date for every routine, even across midnight. An invocation authorizes each routine's writes.

1. Summarize the day's work with the `summarize-sessions` skill.
2. Write that summary to the `Summary` section of the daily note with the `daily-note` skill. Skip this when the summary found no substantive work.

Report one line per routine: what it did, or why it was skipped.
