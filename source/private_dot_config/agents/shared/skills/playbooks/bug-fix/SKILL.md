---
name: bug-fix
description: "Use for a reported defect, broken or failing behavior, or an explicit request to debug and fix a bug. Establish a credible reproduction before investigating implementation or changing production code."
license: MIT
metadata:
  source: "https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd/skills/engineering/diagnosing-bugs"
  upstream-revision: "74ca5fe077456a0b3b2f5310cf9430999fd0b5fd"
  provenance: "adapted-from-upstream"
  additional-source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/tdd"
  additional-source-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
---

# Bug Fix

Use this playbook for reported defects, broken or failing behavior, and explicit debugging or fix requests. It advises scope and test form; its firm boundary is epistemic: establish a credible red-capable reproduction before investigating implementation or changing production code.

## Reproduce the report

Start with the narrowest existing relevant test. Then perform the reported input, interaction, request, command, or state transition directly. Then run the cheapest credible executable probe at the closest authoritative seam. The reproduction must exercise the reported behavior and distinguish the bad state from the intended state. Tighten it to be fast, deterministic, and minimal where practical.

If no credible reproduction can be built, stop. Report exactly what was tried, the missing environment, artifact, or access, and the observation that would unblock work. Do not generate implementation hypotheses or modify production code. The user may explicitly begin a different investigation later.

A flaky defect needs a stable signal before diagnosis: increase and measure the reproduction rate, control inputs, timing, and concurrency, and obtain a sufficiently reliable RED result. For a performance regression, stay in this playbook: capture a repeatable baseline, profile or trace to identify the measured bottleneck, change one cause, and compare with the same measurement.

## Diagnose after RED

Once RED reaches the target behavior, inspect implementation and form a small ranked set of falsifiable hypotheses. Test one hypothesis at a time; no user checkpoint is required before each probe. Instrument rather than guess when the evidence is incomplete.

Load and apply [the root-cause principle](../../principles/principle-fix-root-causes/SKILL.md) now. Choose a fix at the causal authority, not a downstream symptom guard; check the pattern across equivalent cases and suspect persistent state for restart-only failures.

## Implement and preserve

When a cheap credible maintained-test seam exists, write the focused regression test before the fix, observe RED, make the smallest fix, then observe GREEN. Apply [Test Behavior, Not Implementation](../../principles/principle-test-behavior-not-implementation/SKILL.md) when preserving that automated regression. Do not force a weak test. If no credible maintained-test seam exists but a credible executable reproduction does, fix against that reproduction and record the confidence and preservation limit.

Keep independent review conditional under the implement transition; this playbook adds no review ceremony. Do not reproduce legacy debugging phases, rationalization tables, or report templates here.

Finish by applying [Prove It Works](../../principles/principle-prove-it-works/SKILL.md), rerunning the original reproduction, and performing the smallest nearby validation justified by blast radius. Report the evidence and limitations: reproduction stimulus and discriminator, RED and GREEN observations, fix authority, validations, and any confidence lost at an environment or preservation boundary.
