# Using Scripts in Skills

Scripts live in `scripts/` and are referenced via relative paths from the skill root.
List them in `SKILL.md` so the agent knows they exist, then instruct when to run them.

## One-off commands (no bundled script needed)

When an existing package does the job, reference it directly without a `scripts/` directory.
Pin versions for reproducibility.

| Tool | Command | Notes |
|------|---------|-------|
| `uvx` | `uvx ruff@0.8.0 check .` | Python; ships with uv; aggressive caching |
| `pipx` | `pipx run 'black==24.10.0' .` | Python; install via apt/brew |
| `npx` | `npx eslint@9 --fix .` | Node; ships with npm |
| `bunx` | `bunx eslint@9 --fix .` | Bun-only environments |
| `go run` | `go run golang.org/x/tools/cmd/goimports@v0.28.0 .` | Go; built into go toolchain |

Move to a bundled script when the command grows complex enough that it's hard
to get right on the first try.

## Self-contained scripts (with inline dependencies)

### Python (PEP 723)

```python
# /// script
# dependencies = [
#   "beautifulsoup4>=4.12,<5",
# ]
# ///

from bs4 import BeautifulSoup
# ...
```

Run with: `uv run scripts/extract.py`

- `uv run` creates an isolated environment, installs deps, runs the script.
- Pin with PEP 508 specifiers: `"package>=x,<y"`.
- Use `uv lock --script` for a lockfile.

### Deno

```typescript
#!/usr/bin/env -S deno run

import * as cheerio from "npm:cheerio@1.0.0";
// ...
```

Run with: `deno run scripts/extract.ts`

- `npm:` for npm packages, `jsr:` for Deno-native packages.
- Permission flags required for filesystem/network: `--allow-read`, `--allow-net`.
- Packages with native addons (node-gyp) may not work.

### Bun

```typescript
#!/usr/bin/env bun

import * as cheerio from "cheerio@1.0.0";
// ...
```

Run with: `bun run scripts/extract.ts`

- Auto-installs missing packages at runtime (when no `node_modules` exists).
- TypeScript works natively, no compilation step.
- If `node_modules` exists anywhere up the tree, auto-install is disabled.

### Ruby

```ruby
require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'nokogiri', '~> 1.16'
end
# ...
```

Run with: `ruby scripts/extract.rb`

- Pin versions explicitly — no lockfile support.
- An existing `Gemfile` or `BUNDLE_GEMFILE` env var can interfere.

## Designing scripts for agentic use

### No interactive prompts (hard requirement)

Agents operate in non-interactive shells. A script that blocks on TTY input hangs indefinitely.

```
# Bad: hangs
$ python scripts/deploy.py
Target environment: _

# Good: clear error
$ python scripts/deploy.py
Error: --env is required. Options: development, staging, production.
Usage: python scripts/deploy.py --env staging --tag v1.2.3
```

### `--help` output

This is how the agent learns the interface. Include a brief description, all flags,
and usage examples. Keep it concise — it enters the context window.

```
Usage: scripts/process.py [OPTIONS] INPUT_FILE

Options:
  --format FORMAT    Output format: json, csv, table (default: json)
  --output FILE      Write output to FILE instead of stdout
  --verbose          Print progress to stderr

Examples:
  scripts/process.py data.csv
  scripts/process.py --format csv --output report.csv data.csv
```

### Helpful error messages

```
# Opaque — wastes a turn
Error: invalid input

# Actionable
Error: --format must be one of: json, csv, table. Received: "xml"
```

### Structured output

Send structured data (JSON/CSV) to stdout; diagnostics to stderr.
This makes scripts composable and parseable by both the agent and standard tools.

```json
{"name": "my-service", "status": "running", "created": "2025-01-15"}
```

### Further considerations

- **Idempotent** — agents may retry; "create if not exists" over "fail on duplicate"
- **Input constraints** — reject ambiguous input with a clear error; use enums
- **`--dry-run`** for destructive/stateful operations
- **Meaningful exit codes** — document distinct codes in `--help`
- **Predictable output size** — many harnesses truncate beyond 10–30K chars; default to summaries; provide `--offset` for pagination or require `--output FILE`
- **Safe defaults** — require `--confirm` or `--force` for destructive operations

## When to bundle vs. reference one-off commands

Bundle a script when:
- The logic is complex enough that inline commands would be error-prone
- The same logic repeats across multiple test runs (agent reinvents it each time)
- You need validation, error handling, or structured output

Use a one-off command when an existing tool already handles it with a few flags.
