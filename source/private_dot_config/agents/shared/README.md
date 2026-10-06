# Agent Configuration

Personal agent configuration for multiple harnesses, in `~/.config/agents`:

| Directory | Contents |
| --- | --- |
| `shared/` | Harness-neutral `AGENTS.md`, skills, and documentation. |
| `pi/` | Pi's `APPEND_SYSTEM.md` and `extensions/`; links to the shared files. |
| `copilot/` | `copilot.instructions.md`; links to the shared files. |

Shared changes go in `shared/`. Runtime-specific changes go in the owning
harness directory and must not alter shared guidance or another harness's
configuration.

## Tracking changes

`~/.config/agents` is not a git repository. It is the live target of the
chezmoi dotfiles repo at `~/.local/share/chezmoi/`, whose source is
`source/private_dot_config/agents/`. A change here is untracked until it
reaches that source and is committed there:

1. Edit the live file under `~/.config/agents`.
2. Sync it into the source: `chezmoi re-add <path>` for a file chezmoi already
   manages, `chezmoi add <path>` for a new file or directory. For a removed
   file, `chezmoi forget <path>`.
3. Confirm the source changed: `git -C ~/.local/share/chezmoi status`.
4. Commit in `~/.local/share/chezmoi/`, staging only the agent paths; the
   repo often holds unrelated changes.

The `dotfiles` skill covers the general chezmoi workflow.

## Runtime configuration

Pi loads `AGENTS.md`, `APPEND_SYSTEM.md`, and extensions from `pi/`. GitHub
Copilot CLI loads `AGENTS.md` with `copilot.instructions.md`; inspect its
active sources with `copilot instruction list`.
