---
name: principle-test-behavior-not-implementation
description: "Load before writing or changing any automated test or assertion."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/principle-test-behavior-not-implementation"
  additional-source: "https://github.com/obra/superpowers/tree/b36e0829c6d0140e93cfef2ca599b1b07d4a7797/skills/test-driven-development"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  additional-source-revision: "b36e0829c6d0140e93cfef2ca599b1b07d4a7797"
  provenance: "adapted-from-upstream"
---

# Test Behavior, Not Implementation

Apply [Express Intent](../principle-express-intent/SKILL.md) when selecting the required behavior a test must protect, and [Tests Are Not Receipts](../principle-tests-are-not-receipts/SKILL.md) when deciding whether it stays. The rules below govern how a test observes that behavior. [Test smells](../../workbench/test-review/references/smells.md) lists concrete cues for each.

- **Name the claim first.** State the behavior and a credible failure of it before writing an assertion. Keep one coherent claim per test, name the test for it, and assert nothing the name does not claim. Before writing several tests for one subject, state its public input, output, and responsibility in one sentence, and organize the test names as a map of it.
- **Observe at the boundary its consumers rely on.** Stimulate the subject the way production does and observe what its consumers observe. An observation is too narrow when it reads harness or fixture detail, too wide when it exercises the framework or platform, wrongly entered when it reaches its state by a route production never takes, and too distant when it watches from further away than the claim needs.
- **Discriminate in both directions.** An assertion must fail for a plausible accidental change to the subject and pass through a legitimate one. Name both edits before keeping it: the accidental change that turns it red, and a correct design change that must leave it green. If no accidental change reaches it, it guards nothing. If a correct change turns it red, it pins an incidental choice; assert a relationship between observations of the subject instead.
- **Derive expectations independently** of the implementation. A test that recomputes the subject's logic agrees with it by construction.
- **Identify the result completely enough for its consumer.** A category, count, or isolated field does not establish which thing was produced.
- **Prefer real behavior.** Substitute only a true boundary or an impractical dependency, and assert the subject's effect rather than the substitute's.
- **Leave structural guarantees to structure.** A constraint that types, schemas, or the framework enforce cannot be broken by accident in a way a test adds to. Test the behavior that depends on it.
- **Prove a capability before its guards.** A positive case shows the output can be produced; only then does a guard case, varying one precondition, show it is withheld.
- **Let a failure name what broke.** Separate claims so one failure cannot mask another and the test's name describes whatever it reports.
- **Test a behavior where it is implemented.** Observing it through another layer adds only what that layer contributes.
- **Use the cheapest layer that can falsify the claim.** A claim a cheaper layer already falsifies is duplication, not coverage.

If no credible maintained test seam exists, do not add a weak test. Use the applicable executable or manual observation and state its preservation limit.

This governs test quality, not whether every change uses red-green TDD. Bug fixes, new behavior, refactors, and completion claims follow their applicable playbook or [Prove It Works](../principle-prove-it-works/SKILL.md).
