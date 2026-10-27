---
name: principle-query-the-structure
description: "Observe structured artifacts through their structure, not their serialized text."
disable-model-invocation: true
metadata:
  author: "Paul Hendrick"
  provenance: "local-composition"
---

# Query the Structure

Markup, documents, data formats, and machine-readable output carry their meaning in structure. Their serialized text is one incidental encoding of it. Observe them through the structure.

Matching the encoding fails in both directions. It is too loose: a substring or pattern matches anywhere, including places the claim is not about, and cannot say which element it matched. It is too tight: whitespace, ordering, nesting, element choice, and formatting change without changing meaning, and the match breaks.

- Parse, then query for the element, field, or record that carries the meaning, not for where it currently happens to sit.
- Query by meaning before shape. Prefer what a consumer would use to find the thing, such as its role, name, label, or key, over its position, element type, or styling. Follow the project's own query hierarchy where one exists.
- Name only the properties the claim is about. A query that also names details true of the instance in hand over-specifies as surely as a substring.
- Count the meaningful unit. A presence or count claim measured on something that merely accompanies the thing does not measure the thing.
- When no meaningful query reaches the thing, ask why. Either the detail is presentation rather than behavior and does not belong in the observation, or the artifact lacks a meaningful handle, which is a gap to fix at its source.
