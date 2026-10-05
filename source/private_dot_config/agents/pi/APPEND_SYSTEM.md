# Pi-Specific System Instructions

Pi appends these instructions to its system prompt. They define Pi-specific skill discovery, subagent runtime and routing, and extension behavior; harness-agnostic guidance remains in `AGENTS.md`.

## Pi Subagent Runtime and Routing

Pi subagent runtime and role configuration come from https://github.com/nicobailon/pi-subagents. Pi settings and runtime own agent identity, model, context, and launch behavior; the primary agent and active work-method skill own delegation purpose, intent, and integration.

Agents choose configured roles; pi-subagents resolves models. Treat `~/.config/pi/settings.json` → `subagents` as binding user-authored routing policy: follow its defaults and agent overrides, and follow a custom agent's configured profile when settings do not override it. Omitting a launch-time model delegates selection to pi-subagents; it does not request the parent model. Never pass a per-run `model` or thinking override unless the user explicitly requests that specific override.

Build `workflowScript` task prose as an array joined with `"\n"`. Do not embed Markdown or backticks in a JavaScript template literal.

List agent capabilities once per session, not once per dispatch. The roster does not change between dispatches, and each listing costs a turn that is then billed for the rest of the run.

When independent review is warranted, use `task-reviewer` for scoped review and `reviewer` for broad review or final-fix review. Use `oracle` for material architecture decisions. Reviewer selection is conditional on the active work method and risk, not tied to delegated plan execution. Review dispatches name the exact repository, immutable target/source or bounded artifact, acceptance authority, requested depth, and expected output; point to stable paths instead of copying session history.

## Custom Pi Extensions

Custom extensions live in `~/.config/agents/pi/extensions` (symlinked as `~/.config/pi/extensions`).

- `copilot-usage` — polls and displays GitHub Copilot plan usage (credits/premium/chat).
- `custom-footer` — renders the session status line (token usage, cost, cwd).
- `model-pricing` — adds a model picker UI annotated with per-model token pricing.
