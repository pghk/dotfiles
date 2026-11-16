---
name: principle-attack-the-premise
description: "Apply whenever work rests on a premise, such as a plan, design, diagnosis, fix, or experiment: name the premise and question it before building on it."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/principle-attack-the-premise"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
---

# Attack the Premise

Every plan, design, diagnosis, fix, or experiment assumes something it does not test. Name that premise and question it before building on it. An unstated premise is accepted by default.

**Why:** Work built on a false premise fails however well it is executed, and each refinement of it adds cost without adding evidence.

**Pattern:**
- **Write the premise down.** The premise is the one sentence the work assumes. After failures, it is the sentence every failed attempt assumed.
- **Name the observation that would falsify it.** Make that observation before building further when it is cheaper than the work that depends on the premise.
- **Question what the framing takes as fixed.** A constraint, exclusion, or inherited approach is a premise too. Check whether its reason is recorded and still holds.

**After two or more attempts sharing one premise fail the same gate,** suspect the premise, not the attempts:
- **Take a census before the next attempt.** Count the imbalance per actor. The census shows which actors hold the imbalance, not how large it is. Write the census as a rerunnable script per [Build the Lever](../principle-build-the-lever/SKILL.md).
- **Read the skew.** If the same few actors hold most of the imbalance on every run, something assigns them that role. Find what assigns the role. That assignment is the next "why".
- **Remove the asymmetry instead of compensating for it.** Rotate the role between actors, randomize the assignment, or move the role, so that no actor holds it on every run. A return path, a shared pool, a batched hand-off, or a periodic rebalance leaves the assignment in place and adds work on every run.

**Use this guidance proportionately:**
- A premise already established by evidence needs only naming.
- After repeated failure, the premise is written down and the census exists before the next attempt.
- If the census is even across actors, the premise is not the cause. Look for the cause elsewhere and keep the census as evidence.
