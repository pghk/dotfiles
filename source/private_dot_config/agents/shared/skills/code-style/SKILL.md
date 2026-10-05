---
name: code-style
description: >
  Personal code style preferences that apply across all projects. Use when
  writing or reviewing anything in a repository — application code, tests,
  comments, docblocks, and documentation.
---

Write self-documenting code first. Prose covers what the code can't carry:
non-obvious constraints, historical reasons, or surprising behaviour that
would otherwise look like a bug.

## Naming

Name variables for what they represent, not their ownership perspective.
Prefer domain terms (`$studentEventIds`, `$familyEventIds`) over ownership
labels (`$ownEventIds`, `$myEventIds`). The reader cares what the data IS,
not whose it is.

## What prose may say

Open with what the code is for — the failure it prevents, the case it handles.
Tuning, tradeoffs, and caveats follow.

Prose explains the code it sits above. What reaches that code, what else
guards it, how a sibling behaves, what another component is configured to do —
those belong to the files that own them.

Claim only what a reader can check from here. A statement about the wider
codebase can't be maintained from this file, so it gets falsified without
anyone noticing.

Never restate what the code already says: not the name of the method being
documented, not the literals on the line below, and not a property every
sibling shares — naming it on one implies the others differ.

Only justify code ordering when the constraint driving it is non-obvious (a DB
constraint, concurrency requirement, framework quirk). Don't explain ordering
that simply reflects "build before use" — the code structure already shows that.

Describe the underlying system behaviour or concept — not implementation labels
(config keys, variable names, method names). Labels are arbitrary; they carry
no inherent meaning and may change.

Address the abstract future reader, not the current developer or debugging
session. Avoid: error consequences discovered mid-session, warnings born from
a specific incident, cross-references motivated by things just discussed.
Explain the system; don't document the discovery.

Bad: `# Exit 2 surfaces our stderr (Pint's, left unredirected) to the user as
a warning.` — narrates the specific mechanism just wired up, naming an
implementation detail (which stream, which flag) that only makes sense to
someone mid-fix. If a comment would only ever have been written while
building the code, not once the code was mature, omit it rather than
compress it.

Document what the system is, not what it was changed to be. If a statement
would never have been written had the code always been this way, omit it.

A comment earns its place from what the code does — a construct that reads as
an error without it. Don't justify one by predicting how someone might
mis-modify the code; a change you want prevented is the job of a test.

Before keeping a comment, delete it and reread the code. Keep it only if a
specific question remains that the code cannot answer. For a comment written
in the same edit as the code it describes, deletion is the default outcome.

Once a comment has earned its place, length is the only thing left to fix.
When prose runs long, compress it to capture just the essence — don't delete
it. One short sentence that preserves the *why* is better than either a
paragraph or silence.

## Docblock form

Use `/** */` block style, not `//` or `/* */`. Omit a method docblock entirely
if the name and signature are self-documenting.

Class and method docblocks divide responsibility: the class docblock covers
context that can't be attributed to any single method; method docblocks cover
what's specific to each method. Neither should repeat what the other says.

A class docblock can carry context that is genuinely useful and not covered
elsewhere. The bar is duplication, not length — if a README or other
documentation already covers it, don't repeat it here. Leave out usage
examples, "when to use / when not to use" guidance, and migration strategies
unless there is no better place for that information.

Prefer a `//` line comment over a docblock for properties that benefit from
a brief label. Docblocks on private fields add visual weight without adding
value.

Remove `@param` and `@return` tags when the information is already expressed
by type hints in the signature.

## Skill references in application code

Application source files and project documentation (READMEs, inline docs)
should reference other documentation files — not skills. Skills are agent
tooling and belong out of sight of developers reading the codebase.

Skills may freely reference each other.
