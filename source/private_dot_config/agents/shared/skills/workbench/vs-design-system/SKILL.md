---
name: vs-design-system
description: "Use for the VenturEd Solutions Design System: components, tokens, stories, Ravenna prototypes, or gaps against Hub behavior."
---

# VenturEd Solutions Design System

Use the Design System as a source of primitive intent and the Ravenna prototype
as a source of composition intent.

## Evidence source order

| Question | Source |
|---|---|
| What does a component or prototype look like? | A rendered page; see [Rendering](#rendering) |
| What exact markup, states, tokens, or behavior does it define? | `~/Projects/us-suite-design-system` source |
| What appears together on Ravenna screens? | `ravenna-suite/core/` or the Admissions prototype source |

The local `~/Projects/us-suite-design-system` clone is canonical and
git-tracked. Do not use `~/Projects/vs-storybook`; it is stale and untracked.

Before reporting that a Design System source is absent, read its named path
under the canonical clone. Do not search the active Hub checkout for it.

## Story source map

Read [the source map](references/source-map.md) before inspecting a component.
It maps Storybook titles to exact `stories/*.stories.js` files.

Read [the Admissions page map](references/admissions-prototype.md) before
locating, navigating to, or rendering a page of the Ravenna Admissions
prototype. It lists each page, how to reach it, and where its markup lives.

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
- Distinguish visual evidence from source evidence. Render for appearance;
  read source before making a markup or behavior claim.
- When comparing with Hub, inspect the Design System source and Hub source as
  separate evidence targets before synthesizing a recommendation.

## Rendering

`https://design.venturedsolutions.com/` requires Entra ID sign-in, so agents
cannot fetch it; point the user to it when they need to look themselves.
Render Admissions prototype pages with `scripts/render-prototype.mjs`, as the
Admissions page map describes. Do not start Storybook; the local source can
be inspected without it.
