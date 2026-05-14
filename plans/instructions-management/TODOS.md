# Tasks

## Phase 1: Discovery

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1.1 | Find where `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` is currently set | pending | Not in zshenv, zshrc, or any tracked file found so far |
| 1.2 | Confirm what chezmoi data variables are already defined in `.chezmoi.toml.tmpl` | pending | Ensure new vars don't conflict |
| 1.3 | Audit full content of `~/.copilot/copilot-instructions.md` for anything that should NOT go in the template | pending | Check for anything session-specific or experimental |

## Phase 2: Design

| # | Task | Status | Notes |
|---|------|--------|-------|
| 2.1 | Add `obsidianVault` and `admitCodebase` promptStringOnce vars to `.chezmoi.toml.tmpl` | pending | Decide naming convention for path vars |
| 2.2 | Design the template structure for `copilot-instructions.md.tmpl` | pending | Universal content + `{{ .chezmoidata.obsidianVault }}` style refs |
| 2.3 | Decide where `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` should be set and how | pending | zshenv vs. zshrc vs. launchctl — whichever is tracked and runs before CLI |

## Phase 3: Implementation

| # | Task | Status | Notes |
|---|------|--------|-------|
| 3.1 | Add path vars to `.chezmoi.toml.tmpl` | pending | Depends on 2.1 |
| 3.2 | Create `source/dot_copilot/copilot-instructions.md.tmpl` | pending | Replaces untracked live file |
| 3.3 | Track `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` in shell config | pending | Depends on 2.3 |
| 3.4 | Run `chezmoi apply` and verify rendered file is correct | pending | |
| 3.5 | Verify CLI loads instructions at session start (no manual steps) | pending | |

## Phase 4: Cleanup

| # | Task | Status | Notes |
|---|------|--------|-------|
| 4.1 | Remove any now-redundant content from `~/.agents/AGENTS.md` | pending | Only if content has moved to template |
| 4.2 | Update AGENTS.md in dotfiles repo to reflect the new system | pending | |
