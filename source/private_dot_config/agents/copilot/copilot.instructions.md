---
applyTo: "**"
---

# Copilot CLI Instructions

Apply these instructions together with the shared `AGENTS.md` configuration.

## Skill listing budget

The skill listing in context has a character cap, set by the `SKILL_CHAR_BUDGET`
environment variable. Skills load in order (groups alphabetically); a skill that
no longer fits loses its description and appears by name only under "Additional
skills available", so it cannot auto-trigger. Observed on 1.0.95:

- The default cap is roughly 14,000 characters (estimated range 13,700–14,400),
  inferred from where the cut fell at the default and at `SKILL_CHAR_BUDGET=6000`.
  Each entry costs its description plus about 90–105 characters of name and
  markup, so the default fits about 37 skills at a median description length.
- The cost of a skill is its description length. Body size does not count.
- A skill with `disable-model-invocation: true` is absent from the listing and
  costs nothing.
- A description over 1024 characters causes the skill to be skipped entirely.

When adding or lengthening a description, check that every auto-triggering skill
still appears with its description.

## Question dialogs

The `ask_user` form collects an answer; it does not pose the question.
Reasoning is not output: a plan to "present this to the user" or "check in
with the user" is unfulfilled until the presentation appears as chat text, and
writing a file does not fulfil it either. Before opening the form, write the
question in chat — what is being decided, what it turns on, the recommended
answer and why. Referring to things already in the conversation or reachable
in the repository is fine. Option labels name the choices; the reasoning lives
in the chat text.

## Configuration layout

Skills and `AGENTS.md` resolve through `~/.copilot` → `~/.config/copilot` →
`~/.config/agents/copilot`. `~/.config/agents` is a chezmoi-managed target, not
a git repository: see `shared/README.md` for how to track changes.
