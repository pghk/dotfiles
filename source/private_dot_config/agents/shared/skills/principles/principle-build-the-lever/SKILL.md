---
name: principle-build-the-lever
description: "Apply when work repeats across many files or units, or when a check or analysis should be rerunnable: build a script, codemod, or generator instead of working by hand."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/principle-build-the-lever"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
disable-model-invocation: true
---
# Build the Lever

When work repeats across many files or units, or a check or analysis should be rerunnable, build the tool that does it instead of doing it by hand.

**Why:** Two payoffs. Throughput: a codemod, generator, or script does the work the same way every time and reruns for free. Confidence: the tool is one artifact a reviewer can read and rerun to check the work. Hand-done changes can only be re-verified by redoing them. A deterministic script turns "trust me" into "run this".

**Pattern:** Build the lever when the work repeats or a reviewer should be able to rerun it. Skip it when the task is a couple of obvious edits you can see at a glance.

- Do the first unit by hand to learn the recipe, then build the tool. Prove it by rerunning it on that unit and diffing against your hand-done version. Make the lever safe to rerun.
- Codemod or script for edits, generator for repetitive files, a dump-to-sqlite query for analysis, a rerunnable check for verification.
- A deterministic lever beats fan-out. If the tool can process every unit in one pass, run it yourself. Don't fan out delegates to hand-apply what a script can do.
- When you fan work out to subagents, write the lever as a skill they all read: the recipe, the verification contract, and the do-not-touch fences in one artifact. Keep it outside the delegates' write scope so they can't quietly edit the contract.
- Applying this principle produces a file. If you cited it and there is no codemod, script, generator, or delegate skill in the diff, you didn't apply it.
- Commit the lever when the work outlives the session.

**Balance:** Repetition justifies a lever, and so does checkability: a one-off still earns one when the lever is what makes the work checkable. Build the smallest script that does or proves the job, never a framework.

This is throughput and reviewability for the work in front of you.
