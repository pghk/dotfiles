# Decisions

## Open questions (to become decisions)

From OVERVIEW.md:

1. Should the `## Startup` section in copilot-instructions.md move to AGENTS.md,
   be removed, or stay in the local file?
2. Are there static file map rows (non-path entries) worth moving to AGENTS.md?

## Decision log

### ADR-1: `~/.copilot/copilot-instructions.md` stays fully local and untracked

**Date:** 2026-05-14  
**Status:** accepted

**Context:** Using Copilot CLI is itself a system-specific choice, not a universal one.
Templating the file via chezmoi would add Copilot-specific machinery to dotfiles shared
across all machines.

**Decision:** The file stays local and untracked. It holds only system-specific content
(paths, local file map rows). Universal instructions live in `~/.agents/AGENTS.md`.

**Consequences:** Setting up `~/.copilot/copilot-instructions.md` on a new machine is a
manual step. Accepted.

---

### ADR-2: `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` stays in `.zshrc_custom` (untracked)

**Date:** 2026-05-14  
**Status:** accepted

**Context:** The env var is Copilot-specific. Machines that don't use Copilot shouldn't
have it. Conditional exports add complexity to shared shell config.

**Decision:** Leave the export in `~/.config/zsh/.zshrc_custom`, which is a
machine-local, untracked customisation file. Accepted as a manual setup step.

**Consequences:** New machine setup requires remembering to add this export. No tracking
or automation. Acceptable given how infrequently new machines are set up.

---

### ADR-3: Drop `## Startup` section from copilot-instructions.md

**Date:** 2026-05-14  
**Status:** accepted

**Context:** The section documented how `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` loads AGENTS.md.
It was meta-commentary, not an instruction.

**Decision:** Dropped. Agents don't need to be told how they were loaded.

**Consequences:** None.

---

## ADR Template

```
## ADR-N: [Title]

**Date:** YYYY-MM-DD  
**Status:** accepted | superseded by ADR-X

### Context
[What situation or constraint prompted this decision?]

### Decision
[What was decided?]

### Consequences
[What does this enable or foreclose?]
```

