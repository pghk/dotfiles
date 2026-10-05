---
name: technical-writing
description: "Use when explicitly invoked for substantial technical documentation or technical-document review, including RFCs, READMEs, tutorials, how-to guides, references, and explanations."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/technical-writing"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
disable-model-invocation: true
---

# Technical writing

Write documentation that a tired engineer can understand on the first read. Use
this skill for substantial technical documents and reviews, not for every line
of repository prose. [Code-style](../../code-style/SKILL.md) remains the lighter
authority for source comments, docblocks, and normal repository prose.

## Choose the document's job

Choose one [Diátaxis](https://diataxis.fr/) mode before drafting. Split and
link documents when their jobs differ.

- **Tutorial:** Teach a beginner by having them build something. Open with the
  result, give commands in small steps, and show the visible result after each
  useful step. Use "we" when guiding the learner.
- **How-to:** Help a competent reader reach a specific goal. Use direct steps,
  skip teaching and background, and name the guide after the task. Include
  forks where the reader must choose.
- **Reference:** Give facts for lookup. Describe the API, options, limits, and
  errors completely and without persuasion. Mirror the structure of the thing
  described and generate from code where possible.
- **Explanation:** Build understanding of one bounded topic. Answer a real
  "why" question with context, constraints, alternatives, and a stated view.

Do not put tutorial hand-holding in a reference, reference tables in a
how-to, or argument in a tutorial. Link to the companion mode instead.

## Build a navigable document

Open with the reader's goal or question. Address the reader directly and use
present tense. Headings should carry the point, not merely name a topic. Use
sentence case, one H1, and no skipped heading levels. A task heading is a bare
verb phrase, such as "Create an instance". A concept heading is a noun phrase.

Use numbered lists for sequences and bullets for unordered material. Introduce
a list with a complete sentence. Keep list items parallel. Link with the page
title or a short description, never "click here". Use code font for symbols,
paths, commands, and literal values. Use bold for UI labels. Do not document
product UI copy here; use the product's copy authority.

## Make prose executable and unambiguous

- Cut every word that does no work. Prefer "to" over "in order to" and the
  short everyday word over a longer synonym.
- Write commands as commands: "Run `make check`", not "the check should be
  run". Put the condition before the action: "To delete the document, click
  **Delete**." State the common case first, then exceptions.
- Give each sentence one instruction or thought. Split instructions longer
  than about 20 words and other sentences longer than about 25 when the split
  improves parsing. A longer sentence is fine when it carries one clear fact
  with its condition or consequence.
- Name the actor and prefer active voice: "the compiler checks the schema".
  Use passive voice only when the actor is unknown or does not matter.
- Keep articles: "Remove the backup file", not "Remove backup file". Keep
  verbs in every clause. Repeat an article when it distinguishes two things.
- Keep `only` and `not` next to the words they modify. Make every `it`, `they`,
  `this`, and `which` point to one unmistakable noun. Use `both...and`,
  `either...or`, or `if...then` when conjunction scope could be misread.
- Break up long noun strings. Avoid slashes, parenthetical plurals, idioms,
  Latin abbreviations, and metaphors when a literal phrase works. Use periods
  rather than semicolons or em dashes.
- Give each concept one name. Use the real symbol, path, flag, or domain term;
  do not cycle through synonyms or invent jargon. Define a necessary named
  pattern at first use.

Vary sentence length and include concrete facts. "A column rename fails the
build" tells the reader more than "schema changes can cause issues". A rule
that makes a sentence worse has failed its purpose; rewrite it for clarity.

## Plan the information

Start from the reader's task, not from the order in which the code was built.
List the decisions the reader must make and the facts needed for each decision.
Put the common path first. Move edge cases next to the step they affect instead
of collecting warnings at the end.

For a tutorial, choose a small result that can work end to end. Keep setup to
what the lesson needs and verify each milestone. For a how-to, state the goal,
requirements, procedure, and expected result. For reference, define each item
in the same order and shape. For explanation, state the question, establish
context, compare the meaningful alternatives, and conclude with the constraint
that decides the design. These shapes help the reader navigate without turning
the document into a template.

Turn vague steps into observable actions. Name the file to edit, the command to
run, the value to enter, and the output to expect. Say what happens when a
condition is false. Do not hide a decision in a paragraph that appears to be a
fact. If an operation can destroy data or affect another environment, state the
scope before the command.

Use examples that exercise the real interface. Keep symbols, paths, flags, and
output consistent with the surrounding text. A code sample should be runnable
or clearly marked as pseudocode. When a count, tree, or generated file matters,
verify it at the commit and state how to regenerate it. Do not add a sample
whose only purpose is to decorate an abstract explanation.

## Review for reader effort

Read the document in the order a reader will use it. Check that each heading
answers "why am I here?" and that each link earns its place. Remove a paragraph
that repeats a nearby command or restates a heading. Keep a paragraph when it
answers a question the reader will otherwise ask at that point.

Check conditions and consequences, not only grammar. "If the token is expired,
refresh it before retrying" is executable. "The token can be refreshed as
needed" leaves the trigger and action unclear. Check that nouns remain stable
across headings, examples, tables, and links. Use a domain term when it is the
term in the product, even when a plainer synonym would sound smoother.

Do not write around an unknown fact. Find the source, qualify the statement,
or leave the gap visible for the owner to resolve. Technical documentation
must be maintainable by the people who own the system, not merely persuasive on
the day it is written.

## Keep ownership clear

- [Unslop](../unslop/SKILL.md) is the final cleanup pass for AI tells, filler,
  hedging, and mannered prose. Apply it after the document is structurally
  complete; do not copy its pattern catalogue here.
- Use [describe-changeset](../describe-changeset/SKILL.md) for PR descriptions.
- Use [plan-qa](../plan-qa/SKILL.md) for browser QA procedures.
- Use [commit](../commit/SKILL.md) for commit messages.

Do not turn this skill into an automatic baseline for every repository edit.
The dedicated authorities above own their artifact formats and procedures.

## Final self-check

Before you finish, verify that the document has one Diátaxis mode, a clear
reader goal, executable and conditional instructions, unambiguous pronouns and
modifiers, one name per concept, navigable headings and links, real symbols and
paths, and no duplicated owner guidance. Then run [Unslop](../unslop/SKILL.md).
