---
applyTo: "**"
---

# Copilot CLI Instructions

Apply these instructions together with the shared `AGENTS.md` configuration.

## Configuration layout

Skills and `AGENTS.md` resolve through `~/.copilot` → `~/.config/copilot` →
`~/.config/agents/copilot`. `~/.config/agents` is a chezmoi-managed target, not
a git repository: see `shared/README.md` for how to track changes.
