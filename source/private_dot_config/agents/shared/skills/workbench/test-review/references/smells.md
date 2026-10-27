# Test smells

Each cue is a prompt to investigate, not a verdict. Confirm it against the subject's contract and, where it matters, by mutation. Cues are grouped under the principle that decides them.

## Tests Are Not Receipts

- **Session proof.** The test was written to show the new work functions, and asserts nothing a later accidental edit could plausibly break. Ask what enduring concern it guards.
- **Preserved surroundings.** Assertions that neighboring details stay "unchanged" — characterizing the fixture rather than guarding a claim.
- **Pinned choice.** The test asserts the particular value, mechanism, or arrangement the work chose, where another correct choice would serve consumers equally.
- **Reconstructed model.** The test recomputes the subject's calculation or rebuilds its rendering model to compare against.
- **Narrow arrangement, broad claim.** A tightly arranged state is used to claim a general guarantee.
- **Re-added defect as proof.** The test was only ever shown to fail against the exact defect it was written for, not a plausible accidental edit.
- **Costly duplicate.** The same claim is already falsified at a cheaper layer.
- **Machinery out of proportion.** Fixture, harness, or execution cost exceeds the regression evidence it buys.

## Test Behavior, Not Implementation

Claim:

- **Bundled name.** The name joins claims with "and" or a comma list, under-counts its own body, or the body asserts things the name never mentions.
- **Mixed layers.** One test asserts rendered output and internal state of the read model, or a response and a stored record, for unrelated claims.
- **Chained claims.** The first failure masks the rest, so one run reports one problem out of many. Demonstrate it: break one claim and observe which the runner names.
- **Combined boolean.** Several conditions folded into one assertion that reports only `false`.
- **Loop of expectations.** A loop where a dataset would name the failing case.

Boundary:

- **Wrong entry.** The test calls internals, assembles intermediate objects, or seeds state by hand that production produces itself, instead of stimulating the subject the way production does.
- **Harness assertion.** The assertion reads harness or fixture detail; a fixture element that exists only to be asserted on characterizes the fixture.
- **Framework assertion.** The test proves the framework or platform works.
- **Over-wide bypass.** A setup-time bypass — disabled middleware, elevated permissions, a forced flag — is scoped wider than what blocks the subject, hiding which constraint the test depends on and silently skipping gating its name implies.

Discrimination:

- **Inert under nullification.** The test would still pass if every imported production function returned `undefined` or did nothing.
- **Mock proof.** The assertion verifies the substitute was called, not the subject's result or effect.
- **Call choreography.** Spies, call counts, or internal call order stand in for observable state.
- **Self-reference.** The expected value is computed by the code under test or a copy of it.
- **Constant pin.** A literal that a correct design change would alter: a tag name, heading level, class, position, ordering index, formatting, copy that is not itself the requirement.
- **Under-specified positive.** The assertion confirms a category, a count, or an isolated field when the claim is about which member. Swap the value for a sibling and see whether anything reddens.
- **Negative only.** Guards are tested with no positive case proving the output can be produced at all.
- **Absence without contrast.** An absence assertion that would also pass if nothing rendered.
- **Unvaried guard.** A guard case changes more than one material precondition.
- **Unmapped composition.** A builder or assembler has only per-part tests and no representative case proving its parts compose in the result.
- **Enum coverage as decision coverage.** A state machine is tested by reaching each outcome rather than giving each documented outcome, exceptional input, and precedence rule its own case.
- **Source-text check.** A script or configuration is tested by reading its text rather than its output, exit behavior, or effect.
- **Structural claim as runtime test.** The test asserts an extra enum case, forbidden property, type modifier, or absent abstraction that no consuming behavior depends on.

## Query the Structure

- **Substring over serialized output.** `toContain`, `substr_count`, regex, or string equality over HTML, JSON, logs, or CLI text, where the claim concerns an element, field, or record.
- **Counting a proxy.** "Appears once" measured on a tag or string that accompanies the thing rather than the thing itself.
- **Escape hatch.** Raw script evaluation, direct DOM access, or computed styles where the project's query hierarchy offers a first-tier query. Each usually costs automatic waiting, a readable failure message, and the contract/implementation distinction.
- **Incidental selector.** A selector that names properties true of the fixture but unrelated to the claim: a specific tag, state value, nesting depth, or class.
- **Self-satisfying instrument.** A hand-written query that returns true against a DOM the test constructed itself, concealing a stimulus that never produced the asserted state.
