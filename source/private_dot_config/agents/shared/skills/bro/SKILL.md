---
name: bro
description: "Manual only. Use when the user explicitly invokes bro or says the immediately preceding response did not land, and re-pitch that response in plain human language. Do not use for a new explanation, analysis, or general technical writing."
license: MIT
metadata:
  source: "https://github.com/cursor/plugins/tree/e31650eea443aaea1e84cc15d88c13f40080b275/pstack/skills/bro"
  additional-source: "https://github.com/mattpocock/skills/tree/74ca5fe077456a0b3b2f5310cf9430999fd0b5fd/skills/productivity/wait-what"
  upstream-revision: "e31650eea443aaea1e84cc15d88c13f40080b275"
  additional-source-revision: "74ca5fe077456a0b3b2f5310cf9430999fd0b5fd"
  provenance: "adapted-from-upstream"
disable-model-invocation: true
---

# Bro

Re-pitch the immediately preceding response when the user explicitly invokes
`bro` or says it did not land. Keep the same point and implication. Restate it
in plain human language with enough context to reconnect; define or remove
jargon and make the practical consequence explicit.

Do not add analysis, evidence, decisions, examples that change the claim, or
scope. Do not answer a new question or become a general technical-writing
skill. Stop after the clearer re-pitch.
