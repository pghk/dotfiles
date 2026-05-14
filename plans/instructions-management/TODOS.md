# Tasks

## Phase 1: Content audit

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1.1 | Review full content of `~/.copilot/copilot-instructions.md` and categorise each section as universal or local | done | |
| 1.2 | Review `~/.agents/AGENTS.md` for any content that should move or be consolidated | done | |

## Phase 2: Migration

| # | Task | Status | Notes |
|---|------|--------|-------|
| 2.1 | Move universal instructions (behaviour rules, skill conventions) from copilot-instructions.md to `~/.agents/AGENTS.md` | done | |
| 2.2 | Strip copilot-instructions.md down to local-only content (paths, file map local rows) | done | |
| 2.3 | Commit changes to agents repo | done | `~/.agents/AGENTS.md` added to chezmoi (`source/dot_agents/AGENTS.md`) |

## Phase 3: Verification

| # | Task | Status | Notes |
|---|------|--------|-------|
| 3.1 | Start a new session and confirm instructions load correctly from AGENTS.md | done | Confirmed: rules present in context at session start |
| 3.2 | Confirm no universal content remains in copilot-instructions.md | done | |

## Phase 4: Documentation

| # | Task | Status | Notes |
|---|------|--------|-------|
| 4.1 | Update dotfiles `AGENTS.md` to document the two-file convention | done | Added "Agent instructions: two-file convention" section |
| 4.2 | Decide how to track `~/.agents/AGENTS.md` — chezmoi or extend the skills repo | done | Added to chezmoi as `source/dot_agents/AGENTS.md` |

