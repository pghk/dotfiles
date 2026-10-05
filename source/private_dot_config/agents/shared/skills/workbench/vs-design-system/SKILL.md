---
name: vs-design-system
description: Use when inspecting, reviewing, or comparing the VenturEd Solutions Design System, its components, tokens, Storybook stories, Ravenna prototypes, or gaps against Hub behavior.
---

# VenturEd Solutions Design System

Use the Design System as a source of primitive intent and the Ravenna prototype
as a source of composition intent.

## Evidence source order

| Question | Source |
|---|---|
| What does a component or prototype look like? | `https://design.venturedsolutions.com/` |
| What exact markup, states, tokens, or behavior does it define? | `~/Projects/us-suite-design-system` source |
| What appears together on Ravenna screens? | `ravenna-suite/core/` or the Admissions prototype source |

The local `~/Projects/us-suite-design-system` clone is canonical and
git-tracked. Do not use `~/Projects/vs-storybook`; it is stale and untracked.

Before reporting that a Design System source is absent, read its named path
under the canonical clone. Do not search the active Hub checkout for it.

## Story source map

Read [the source map](references/source-map.md) before inspecting a component.
It maps Storybook titles to exact `stories/*.stories.js` files.

Shared sources:

```text
lib/tokens.css        generated primitives and semantic tokens
lib/tokens.js         token data
lib/ravennaShared.js  helpers reused by Ravenna stories
ravenna-suite/core/   standalone Ravenna Core prototype
```

## Comparison rules

- A consuming repository's design-system document owns its translation
  decisions. In Hub that is `docs/frontend/DESIGN_SYSTEM.md`; read it before
  recommending a mechanism, and extend its translation table when adding one.
- Stories are authoritative for primitive states, values, and accessibility
  intent.
- Ravenna prototypes are authoritative for composition, not literal values.
- Hub determines its own component boundaries: translate capabilities, not
  Storybook class scaffolds.
- Distinguish visual evidence from source evidence. Use the online Storybook
  for rendering; read source before making a markup or behavior claim.
- When comparing with Hub, inspect the Design System source and Hub source as
  separate evidence targets before synthesizing a recommendation.

## Online Storybook

Use `https://design.venturedsolutions.com/` when a visual question needs a
rendered answer. Do not start a local server unless the online site is
unavailable and source-based visual inspection is insufficient.

The local source can be inspected without Storybook running.
