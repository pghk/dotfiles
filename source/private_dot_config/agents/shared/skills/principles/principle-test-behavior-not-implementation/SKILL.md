---
name: principle-test-behavior-not-implementation
description: "Use whenever writing, changing, or reviewing automated tests, test cases, or test assertions. Name the behavior and a known bad case, then assert the observable result at the subject boundary."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/principle-test-behavior-not-implementation"
  additional-source: "https://github.com/obra/superpowers/tree/b36e0829c6d0140e93cfef2ca599b1b07d4a7797/skills/test-driven-development"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  additional-source-revision: "b36e0829c6d0140e93cfef2ca599b1b07d4a7797"
  provenance: "adapted-from-upstream"
---

# Test Behavior, Not Implementation

- Before writing several tests for one subject, state its public input, output,
  and responsibility in one sentence. Organize test names as a map of that
  responsibility. For a builder or assembler, include one representative case
  proving that its supported parts compose in the returned result; use focused
  tests for individual selection, transformation, and guard rules.
- Name the behavior and a known bad case before writing the assertion.
- Exercise the subject through the boundary its users use. Assert observable
  behavior there, not implementation paths, collaborator-call choreography, or
  harness state.
- Derive expectations independently from the implementation under test.
- Establish each promised output with a positive case before testing its
  guards. Vary one material precondition per guard case; negative cases alone
  do not prove that the capability exists.
- Treat a closed state machine as a decision table. Give every documented
  outcome, exceptional input, and precedence rule an independently named case;
  reaching every enum value is insufficient when distinct inputs can produce
  the same value.
- Every assertion must discriminate: it should fail for the known bad case or a
  credible perturbation. If replacing imported production functions with
  inert or `undefined` behavior would still pass, rewrite or delete the test.
- Before pinning a literal value, name a correct design change that would alter
  it. If one exists, assert a relationship between two observations of the
  subject instead, and reshape a brittle assertion before deleting it.
- Assert a semantic value completely enough to identify it to its consumer. An
  action normally requires its kind and target together; a notice requires its
  kind, target, and relevant occurrence data. Counts and isolated fields do not
  establish identity.
- Prefer real production behavior. Mock only a true boundary or an impractical
  dependency, and assert the subject's result or effect rather than proving the
  mock.
- Test scripts and behavior-changing configuration through actual outputs,
  exit behavior, or side effects, not source-text checks.
- Keep one coherent behavioral claim per test, and assert only behavior named
  by that test. Move independently meaningful output to its own test instead
  of using incidental assertions to characterize or stabilize a fixture.
  Avoid redundant claims across layers unless each layer adds observation
  power.
- If no credible maintained test seam exists, do not add a weak test. Use the
  applicable executable or manual observation and state its preservation limit.

Quick check: would this pass if every imported function returned `undefined`?
Weak, mock-only, self-referential, constant-pin, and fixture-self-asserting tests
usually observe no behavior. Replace them with one concrete input and a literal
result or observable effect; for absence, prove contrasting presence where useful.

This governs test quality, not whether every change uses red-green TDD. Bug
fixes, new behavior, refactors, and completion claims follow their applicable
playbook or [Prove It Works](../principle-prove-it-works/SKILL.md).
