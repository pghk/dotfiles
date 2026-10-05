#!/usr/bin/env bash

set -euo pipefail

skill_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tool="$skill_dir/scripts/token-economics"
temporary_directory=$(mktemp -d)
test_count=0
trap 'rm -rf "$temporary_directory"' EXIT

fail() { printf 'not ok %d - %s\n' "$((test_count + 1))" "$1" >&2; exit 1; }
pass() { test_count=$((test_count + 1)); printf 'ok %d - %s\n' "$test_count" "$1"; }

# Reports the value at a dotted path in the tool's JSON output.
field() { python3 -c 'import json,sys
value = json.load(sys.stdin)
for key in sys.argv[1].split("."):
    value = value[int(key)] if isinstance(value, list) else value[key]
print(value)' "$1"; }

assert_equal() {
  [[ "$1" == "$2" ]] || fail "$3: expected $2, got $1"
}

# A session whose arithmetic is checkable by hand.
#
#   turn 1  context  100   then a 4,000B read lands
#   turn 2  context 1100   then an 8,000B edit lands, 6,000B of it an extension echo
#   turn 3  context 3100
#
# billed 4,300; peak 3,100; each inter-turn delta is 1,000 and 2,000 against
# payloads of 4,000 and 8,000, so the measured ratio is 4.0 bytes per token.
# Agent residency: 4000/4*2 + 2000/4*1 = 2,500. Echo residency: 6000/4*1 = 1,500.
build_session() {
  python3 - "$1" <<'PYTHON'
import json, sys

def turn(context, calls=()):
    return {"type": "message", "message": {"role": "assistant",
            "usage": {"input": context, "cacheRead": 0, "cacheWrite": 0, "output": 0,
                      "cost": {"input": 0.1, "cacheRead": 0.2, "cacheWrite": 0.0, "output": 0.05, "total": 0.35}},
            "content": [{"type": "toolCall", "id": i, "name": n, "arguments": a} for i, n, a in calls]}}

def result(call_id, name, text):
    return {"type": "message", "message": {"role": "toolResult", "toolCallId": call_id,
            "toolName": name, "content": [{"type": "text", "text": text}]}}

records = [
    {"type": "session", "id": "fixture", "timestamp": "2026-01-01T00:00:00.000Z"},
    turn(100, [("c1", "read", {"path": "/repo/plan.md"})]),
    result("c1", "read", "P" * 4000),
    turn(1100, [("c2", "edit", {"path": "/repo/notes.md"})]),
    result("c2", "edit", "E" * 2000 + "Canonical final patch:" + "D" * (6000 - len("Canonical final patch:"))),
    turn(3100),
]
with open(sys.argv[1], "w", encoding="utf-8") as handle:
    for record in records:
        handle.write(json.dumps(record) + "\n")
PYTHON
}

session="$temporary_directory/session.jsonl"
build_session "$session"
report=$("$tool" "$session" --json)

assert_equal "$(field turns <<<"$report")" "3" "turn count"
pass "counts assistant turns carrying usage"

assert_equal "$(field billed_prompt_tokens <<<"$report")" "4300" "billed"
assert_equal "$(field peak_context <<<"$report")" "3100" "peak"
pass "bills resident context per turn and reports the peak"

assert_equal "$(field bytes_per_token.measured <<<"$report")" "4.0" "measured ratio"
assert_equal "$(field bytes_per_token.samples <<<"$report")" "2" "calibration samples"
pass "measures bytes per token from context deltas rather than assuming a constant"

override=$("$tool" "$session" --json --bytes-per-token 11.3)
assert_equal "$(field bytes_per_token.used <<<"$override")" "11.3" "override"
assert_equal "$(field bytes_per_token.measured <<<"$override")" "4.0" "measurement survives override"
pass "an explicit ratio overrides the measurement without hiding it"

assert_equal "$(field resident_tokens.agent <<<"$report")" "2500" "agent residency"
assert_equal "$(field resident_tokens.extension_echo <<<"$report")" "1500" "echo residency"
pass "bills extension-injected text separately from agent-initiated bytes"

assert_equal "$(field categories.plan.resident_share <<<"$report")" "80.0" "plan share"
assert_equal "$(field categories.edit-write.resident_share <<<"$report")" "20.0" "edit share"
pass "weights each result by the turns it is held, not by its size alone"

unmarked=$("$tool" "$session" --json --marker 'No Such Marker')
assert_equal "$(field resident_tokens.agent <<<"$unmarked")" "4000" "unmarked agent residency"
pass "an unrecognised echo marker leaves the text billed to the agent"

assert_equal "$(field cost.total <<<"$report")" "1.05" "total cost"
assert_equal "$(field dollars_per_prompt_megatoken <<<"$report")" "209.3023" "unit cost"
pass "totals reported cost and derives the prompt unit rate"

empty="$temporary_directory/empty.jsonl"
: > "$empty"
if "$tool" "$empty" >/dev/null 2>&1; then fail "expected a session with no turns to be rejected"; fi
pass "rejects a session with no assistant turns"

if "$tool" "$temporary_directory/absent.jsonl" >/dev/null 2>&1; then fail "expected a missing session to be rejected"; fi
pass "rejects a missing session file"

printf '1..%d\n' "$test_count"
