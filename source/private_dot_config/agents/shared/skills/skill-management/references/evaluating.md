# Evaluating Skill Output Quality

Structured evals answer whether your skill works reliably across varied prompts, in edge cases, and better than a relevant baseline. Choose the lightest evaluation that can answer the question:

- **Discipline skills**: verify the required decisions and constraints.
- **Technique skills**: verify the prescribed method and its result.
- **Pattern skills**: compare quality across representative cases.
- **Reference skills**: verify factual accuracy, coverage, and findability.

For frequently loaded skills, keep the main file especially small and measure whether added guidance earns its token and elapsed-time cost.

## Designing test cases

Store test cases in `evals/evals.json` inside the skill directory:

```json
{
  "skill_name": "csv-analyzer",
  "evals": [
    {
      "id": 1,
      "prompt": "I have a CSV of monthly sales data in data/sales_2025.csv. Find the top 3 months by revenue and make a bar chart.",
      "expected_output": "A bar chart showing the top 3 months by revenue, with labeled axes.",
      "files": ["evals/files/sales_2025.csv"]
    }
  ]
}
```

**Tips:**

- Start with 2–3 test cases. Expand after seeing first results.
- Vary phrasing, formality, and detail level.
- Include at least one edge case (malformed input, unusual request, ambiguous instruction).
- Use realistic context: file paths, column names, personal framing.

Don't define assertions yet — write them after seeing what the first run produces.

## Isolate subject input from grading material

Evaluation subjects receive only the prompt and declared fixture files. They must not read `expected_output`, assertions, grades, sibling cases, comparison outputs, or prior responses. Project each case into a prompt-only input before dispatch rather than sending the subject `evals.json`.

The evaluator owns expected output and assertions. Retain the exact prompt projection or its digest so a reviewer can confirm what the subject saw.

Before launching the full corpus, run one case end to end. Inspect its subject input, lifecycle status, saved output, provenance metadata, and the routing from saved output to its grader; assertions are defined only after observing the first-round output. Fan out only after that pilot demonstrates that grader-only material stays hidden and artifacts are attributable.

## Workspace structure

Each iteration gets its own directory. Each test case has `with_skill/` and `without_skill/` runs:

```
csv-analyzer/
├── SKILL.md
└── evals/
    └── evals.json
csv-analyzer-workspace/
└── iteration-1/
    ├── eval-top-months-chart/
    │   ├── with_skill/
    │   │   ├── outputs/
    │   │   ├── timing.json
    │   │   └── grading.json
    │   └── without_skill/
    │       ├── outputs/
    │       ├── timing.json
    │       └── grading.json
    └── benchmark.json
```

The baseline (`without_skill/`) lets you measure what the agent does alone. When improving an existing skill, use the previous version as the baseline. Compare pass-rate gains with token and elapsed-time costs; a longer evaluation is justified only when it reveals a meaningful quality difference.

### Run provenance and timing

Retain a manifest that ties each result to:

- scenario ID and prompt projection or digest;
- tested skill revision or digest;
- fresh context with no carried-over subject session, plus child run identity;
- terminal lifecycle status;
- output path or digest;
- elapsed time and token/cost fields when available.

```json
{
  "scenario_id": "top-months-chart",
  "prompt_sha256": "...",
  "skill_revision": "...",
  "context": "fresh",
  "run_id": "...",
  "status": "completed",
  "output_sha256": "...",
  "total_tokens": 84852,
  "duration_ms": 23332
}
```

Record per run. This quantifies what the skill costs versus what it buys and lets a reviewer verify that outputs came from the intended prompt, skill, and context.

## Writing assertions

Add assertions after seeing the first round of outputs.

Good assertions:

- "The output file is valid JSON" — programmatically verifiable
- "The bar chart has labeled axes" — specific and observable
- "The report includes at least 3 recommendations" — countable

Weak assertions:

- "The output is good" — unverifiable
- `"Total Revenue: $X"` exact match — too brittle; correct output with different wording fails

Reserve assertions for things that can be checked objectively. Hard-to-specify qualities (writing style, visual polish) belong in human review.

Add assertions to `evals.json`:

```json
"assertions": [
  "The output includes a bar chart image file",
  "The chart shows exactly 3 months",
  "Both axes are labeled",
  "The chart title mentions revenue"
]
```

## Grading

Grade each assertion against actual outputs: PASS or FAIL with specific evidence.

```json
{
  "assertion_results": [
    {
      "text": "Both axes are labeled",
      "passed": false,
      "evidence": "Y-axis labeled 'Revenue ($)' but X-axis has no label"
    }
  ],
  "summary": {
    "passed": 3,
    "failed": 1,
    "total": 4,
    "pass_rate": 0.75
  }
}
```

Grading principles:

- Require concrete evidence for PASS. Don't give benefit of the doubt.
- Grade only outputs from terminal successful runs. A stale, partial, or plausible-looking file never overrides failed lifecycle status; invalidate and rerun that case.
- Review the assertions themselves — fix ones that always pass/fail regardless of skill quality.
- Use an LLM to grade subjective assertions; use scripts for mechanical checks (file exists, valid JSON, correct row count).

**Blind comparison:** for holistic quality differences between two versions, present both outputs to an LLM judge without revealing which is which. Scores organization, formatting, and usability free from confirmation bias.

## Aggregating results

```json
{
  "run_summary": {
    "with_skill": {
      "pass_rate": { "mean": 0.83, "stddev": 0.06 },
      "time_seconds": { "mean": 45.0, "stddev": 12.0 },
      "tokens": { "mean": 3800, "stddev": 400 }
    },
    "without_skill": {
      "pass_rate": { "mean": 0.33, "stddev": 0.1 }
    },
    "delta": {
      "pass_rate": 0.5,
      "time_seconds": 13.0,
      "tokens": 1700
    }
  }
}
```

The `delta` tells you what the skill costs vs. what it buys. `stddev` is only meaningful with multiple runs — focus on raw pass counts in early iterations.

## Analyzing patterns

After computing benchmarks:

- **Always-pass assertions (both configs)** — remove; they're not testing skill value.
- **Always-fail assertions (both configs)** — broken or too hard; fix before next iteration.
- **Pass with skill, fail without** — where the skill adds value; understand why.
- **Inconsistent results** — high stddev signals flaky evals or ambiguous instructions; add examples or specificity.
- **Time/token outliers** — read the execution transcript to find the bottleneck.

## Human review

Assertion grading only checks what you thought to write assertions for. Human review catches what you didn't anticipate and outputs that are technically correct but miss the point.

```json
{
  "eval-top-months-chart": "Months in alphabetical order, not chronological. Axis labels missing.",
  "eval-clean-missing-emails": ""
}
```

Empty feedback = output looked fine. Focus iteration on cases with specific complaints.

## Iterating

Three signal sources per iteration:

1. **Failed assertions** — specific gaps: missing step, unclear instruction, unhandled case
2. **Human feedback** — broader quality issues: wrong approach, poor structure
3. **Execution transcripts** — _why_ things went wrong; wasted steps signal over-constrained or ambiguous instructions

Give all three plus the current `SKILL.md` to an LLM and ask it to propose changes.

When prompting for improvements:

- Generalize from feedback — fixes should address underlying issues, not patch specific test cases
- Keep the skill lean — fewer, better instructions often outperform exhaustive rules
- Explain the why — "Do X because Y causes Z" beats "ALWAYS do X, NEVER do Y"
- Bundle repeated work — if every run invents the same helper script, bundle it in `scripts/`

**Loop:** propose changes → apply → rerun in `iteration-N+1/` → grade → human review → repeat. Stop when feedback is consistently empty or improvement stalls.
