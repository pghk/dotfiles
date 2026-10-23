---
applyTo: "**"
---

# Copilot CLI Instructions

Apply these instructions together with the shared `AGENTS.md` configuration.

## Copilot documentation

For Copilot CLI questions, consult installed `copilot help <topic>` or `copilot <command> --help` for version-specific behavior. Discover topics with `copilot help --help`. Prefer installed help when published documentation describes a different version.

For broader guidance, use the [GitHub Docs APIs](https://docs.github.com/llms.txt):

- Discover current article paths with `https://docs.github.com/api/search/v1?query=<encoded-query>&language=en&version=free-pro-team%40latest`.
- Fetch a selected article as Markdown with `https://docs.github.com/api/article/body?pathname=<encoded-article-path>`.

Load only relevant topics or articles.

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

Ask a question that arises within a discussion in prose, and let the user
answer in chat. Use `ask_user` only once the chat text has presented the
options and the context needed to choose between them; a plan to present
them, in reasoning or a file, does not count.

## Configuration layout

Skills and `AGENTS.md` resolve through `~/.copilot` → `~/.config/copilot` →
`~/.config/agents/copilot`. `~/.config/agents` is a chezmoi-managed target, not
a git repository: see `shared/README.md` for how to track changes.
