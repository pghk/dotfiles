---
name: unslop
description: "Use when explicitly invoked to remove AI tells and robotic prose, or when a composing writing skill requests a final cleanup pass. Preserve meaning, facts, tone, and intentional voice."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/unslop"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  provenance: "adapted-from-upstream"
disable-model-invocation: true
---

# Unslop

Use this focused cleanup pass after composing. Scan the text, rewrite the
patterns below while preserving meaning, facts, tone, and intentional human
voice, then self-audit for remaining obvious AI tells. Do not change a claim,
remove a necessary technical term, or take over document structure and
technical correctness.

## Patterns to detect and fix

Rule numbers are stable IDs that other skills may cite. A removed rule leaves a
gap.

### Content and language

3. **Superficial -ing phrases.** Remove "highlighting", "ensuring",
   "reflecting", "showcasing", and "fostering" when they add no source or
   concrete action. Expand them only when they carry a real fact.
5. **Vague attribution.** Name the source behind "experts believe", "industry
   reports suggest", or "some critics argue", or remove the attribution.
7. **AI vocabulary.** Replace words such as "additionally", "crucial",
   "delve", "enduring", "enhance", "fostering", "garner", "interplay",
   "intricate", "landscape" (abstract), "pivotal", "showcase", "tapestry",
   "testament", "underscore", and "vibrant" with the plain word.
8. **Fancy copulas.** Replace "serves as", "stands as", "boasts", and
   "features" with "is" or "has" when that states the fact.
9. **Not-just construction.** State the point directly instead of "not just X,
   but Y".
10. **Forced threes.** Use the natural number of items rather than arranging
    ideas into a rule of three.
11. **Synonym cycling.** Choose one name and repeat it. Do not alternate
    "protagonist", "main character", "central figure", and "hero" for one thing.
12. **False ranges.** List topics directly when "from X to Y" does not name a
    meaningful scale.

### Style and communication artifacts

13. **Em dashes.** Retain paired em dashes only when they clearly set off a
    parenthetical interruption and improve clarity over commas, parentheses, or
    separate sentences. Replace a single em dash with a period, colon,
    semicolon, comma, or parentheses according to the relationship between the
    ideas.
14. **Colons.** Retain a colon when a complete clause introduces a list,
    example, explanation, restatement, or emphasis and improves clarity over a
    period, semicolon, comma, or parentheses. Replace a colon between a verb or
    preposition and its object.
15. **Boldface.** Retain boldface for headings and literal UI labels. In prose,
    retain it only for a short term readers must find or distinguish. Remove
    boldface that merely decorates a proper noun, acronym, or ordinary
    sentence.
16. **Inline-header lists.** Turn a bold label that merely restates the next
    sentence into prose. Keep a bold lead-in when it names an item and the
    following sentence adds new detail.
17. **Title-case headings.** Use sentence case.
18. **Decorative emojis.** Remove them from headings and bullets.
19. **Quotation marks.** Retain typographic quotation marks and apostrophes in
    prose. Use straight quotes only for literal text, including code, commands,
    identifiers, configuration, user input, and output.
20. **Chatbot phrases.** Remove "I hope this helps", "Let me know if", "Of
    course", "Certainly", and similar conversational sign-offs.
22. **Sycophancy.** Remove praise such as "Great question" and "You're
    absolutely right". Respond to the substance.

### Filler, jargon, and sentence shape

23. **Filler.** Replace "in order to" with "to" and "due to the fact that"
    with "because". Delete "it is important to note that".
24. **Hedging.** Replace stacked qualifiers such as "could potentially possibly
    be argued that it might" with the accurate, shorter degree of uncertainty.
25. **Generic conclusions.** State a specific plan or fact instead of "the
    future looks bright".
26. **Abstract metaphor jargon.** Treat nouns such as "substrate", "wedge",
    "vector", "locus", "vantage", "nexus", "primitive" (as a noun),
    "harness" (as a metaphor), "surface" (as in API surface), "bedrock",
    "scaffolding", "modality", "paradigm", "gold-plating", "ratchet",
    "evacuate", "endgame", "north star", and "flywheel" as smells when they
    hide the mechanism or add no established domain meaning. Keep necessary
    technical terms, and name the mechanism when a concrete term exists.
27. **Vague feeling language.** Say what the system does, with a mechanism,
    number, or instruction. Replace "the database stays close at hand" with
    the behavior that makes it so. If a sentence could appear in any project's
    docs unchanged, make it specific or cut it.
28. **Dense sentences.** Split a sentence when readers must backtrack to
    parse it. Keep one main instruction or thought per sentence, but retain
    conditions and consequences that make the relationship clear.
29. **Passive voice.** Prefer an active actor: "the compiler validates
    queries", not "queries are validated". Keep passive voice when the actor is
    unknown or does not matter.
30. **Weak adverbs.** Remove an adverb that adds no useful degree,
    frequency, or scope. Otherwise retain it, or replace a weak verb with a
    measured fact.
31. **Fancy synonyms.** Prefer "use", "help", "many", and "if" over
    "utilize", "leverage", "facilitate", "numerous", and "in the event that".
32. **Mannered prose.** Replace flourish, aphorisms, rhetorical fragments,
    personification, and figurative verbs with literal statements.
33. **Over-compression.** Restore dropped articles, verbs, and whole sentences.
    Write "The parser rejects a bad date, exits with code 2, and writes
    nothing" instead of symbol fragments.

## Self-audit

Read the result once without the source beside it. Look for a remaining phrase
that sounds generated, generic, overly polished, or hard to parse. Replace it
with a concrete statement or remove it. Check that the rewrite preserved every
claim, fact, technical term, and intended tone.
