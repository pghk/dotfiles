# Agent Configuration

This repository supplies personal agent configuration for multiple harnesses.
`main` owns the shared guidance, skills, and documentation. Each harness branch
adds only the runtime configuration that its harness loads.

## Branches

| Branch | Responsibility |
| --- | --- |
| `main` | Harness-neutral `AGENTS.md`, skills, and documentation. |
| `pi` | `main` plus Pi's `APPEND_SYSTEM.md` and `extensions/`. |
| `copilot` | `main` plus `copilot.instructions.md`. |

Keep shared changes on `main` and integrate them into both harness branches.
Keep runtime-specific changes on the owning harness branch; they must not alter
shared guidance or another harness's configuration.

## Runtime configuration

Pi loads `AGENTS.md`, `APPEND_SYSTEM.md`, and extensions from the `pi`
worktree. GitHub Copilot CLI loads `AGENTS.md` with
`copilot.instructions.md`; inspect its active sources with
`copilot instruction list`.
