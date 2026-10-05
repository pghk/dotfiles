---
name: describe-changeset
description: >
  Describe a branch changeset for a pull request, focused on what reviewers need to know before merging. Use when asked to "describe this changeset", "write a PR description", "compose a PR message", "draft a pull request description", or "what should I put in the PR". This skill prepares review context. It does not conduct code review or create the pull request.
---

# Describe Changeset

Produce a PR description that helps reviewers understand what will happen on merge, what to look closely at, and what they need to do before or after merging.

**Bitbucket/GitHub will include individual commit messages automatically.** Do not duplicate them. Focus on cross-cutting context that isn't captured in any single commit.

---

## Phase 1: Gather context

```bash
git log origin/develop..HEAD --oneline
git diff origin/develop..HEAD --stat
```

Run the test suite before asking any questions — if something is broken, surface it so it can be fixed before composing the description.

Skim a few key files to understand the shape of the change before asking questions. Enough to offer concrete answer choices.

---

## Phase 2: Ask questions

Ask **one question at a time**. Useful things to establish:

- Who is the audience? (team-wide, backend-focused, unfamiliar with the domain?)
- Is this feature gated? If so, what turns it on and who controls that?
- Are there deployment dependencies (migrations, companion PRs, config changes)?
- Is any part of the diff a companion to something not yet merged?
- Are there security-sensitive areas reviewers should verify rather than assume?
- Are there known gaps, TODOs, or follow-on work to call out?
- Is there a mock/dev shortcut reviewers can use to exercise the feature locally? (Only mention if not already covered in the docs.)

---

## Phase 3: Checklist before writing

For any PR introducing a new integration, service, or significant feature, check these areas proactively — don't wait to be asked:

- **New routes** — list them with HTTP method, path, middleware, controller
- **New environment variables** — check `config/services.php`, `.env.example`, any other config files touched. Table: variable, required/optional, purpose
- **New database tables or schema changes** — note whether the migration here is test-only (e.g. Hub Artisan) vs. production (e.g. Admit Phinx)
- **New npm/composer dependencies** — name them and state why they were added
- **New Vite entry points or build changes** — note what gets compiled and when
- **Feature flags / gates** — what condition must be true for the feature to be visible? Who controls it?

---

## Phase 4: Structure

Use the sections that apply. Omit sections that add no information.

### What is [feature]?

One short paragraph. Required when the feature or external system is unlikely to be familiar to all reviewers. Skip if context is obvious.

### What changes on merge

Who is affected and under what conditions. Lead with the gate/guard if one exists — make it clear that nothing changes for unaffected users.

State model, journey steps, or UX flow: **one line + link to docs**. Do not reproduce tables or diagrams that already exist in the docs.

### New entry points

Routes table. Note the BFF pattern, auth requirements, or other architectural constraints that aren't obvious from the route list alone.

### Deployment dependencies

Call out anything that must land before this can be enabled in production: companion migrations, companion PRs, config values, feature flags.

### New environment variables

Table: `VARIABLE_NAME` | required/optional | purpose. Group by service if more than one service is involved.

### Things worth a close look

Targeted review requests — not a code tour. Frame each as: **what to look at** and **what to verify**. For security-sensitive code, state the intended mechanism and ask reviewers to verify it, rather than asserting it is correct.

---

## Conventions

- Save draft to session `files/` folder; paste into Bitbucket/GitHub manually
- Keep the description skimmable: tables over prose lists where structure helps
- Avoid apology, hedging, and throat-clearing ("this PR adds...", "we decided...")
- Write in third-person imperative or neutral declarative — not first-person
