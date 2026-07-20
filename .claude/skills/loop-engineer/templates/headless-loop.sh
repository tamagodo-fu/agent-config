#!/usr/bin/env bash
#
# headless-loop.sh — single agentic loop around `claude -p`, with all guardrails.
# Pattern: ONE agent iterates toward ONE binary exit condition.
#
# Guardrails baked in: verifiable exit check (run FIRST), max-iteration cap,
# in-code budget enforcement (stop BEFORE the call that would exceed it),
# session chaining so the agent keeps context across turns.
#
# Usage:
#   EXIT_CHECK='npm test --silent' \
#   TASK_PROMPT='Make all unit tests pass. Run the suite to verify.' \
#   MAX_ITERS=10 BUDGET_USD=5.00 \
#   ./headless-loop.sh
#
set -euo pipefail

# ---- Config (override via env) --------------------------------------------
MAX_ITERS="${MAX_ITERS:-10}"
BUDGET_USD="${BUDGET_USD:-5.00}"
STATE_DIR="${STATE_DIR:-.loop-state}"
TASK_PROMPT="${TASK_PROMPT:-Make all unit tests pass. Run the test suite to verify your work.}"
# EXIT_CHECK MUST be binary: exit 0 ONLY when the goal is truly done.
# This is the single most important line — no exit check, no loop.
EXIT_CHECK="${EXIT_CHECK:-npm test --silent}"
# ---------------------------------------------------------------------------

mkdir -p "$STATE_DIR"
spent=0
session_id=""

# float-aware "a < b"
under() { awk "BEGIN{exit !($1 < $2)}"; }

echo "Loop start | max_iters=$MAX_ITERS budget=\$$BUDGET_USD"
echo "Exit check: $EXIT_CHECK"

for ((i=1; i<=MAX_ITERS; i++)); do
  echo "=== Iteration $i/$MAX_ITERS (spent \$$spent) ==="

  # 1) Exit FIRST — a check is far cheaper than another LLM turn.
  if eval "$EXIT_CHECK" >/dev/null 2>&1; then
    echo "✅ Exit condition met. Done in $((i-1)) iteration(s)."
    exit 0
  fi

  # 2) Budget gate BEFORE spending.
  if ! under "$spent" "$BUDGET_USD"; then
    echo "🛑 Budget cap reached (\$$spent >= \$$BUDGET_USD). Stopping."
    exit 2
  fi

  # 3) One agent turn, chaining the session for continuity.
  if [[ -z "$session_id" ]]; then
    out=$(claude -p "$TASK_PROMPT" --output-format json)
  else
    out=$(claude -p "Continue. Address the remaining failures, then re-verify." \
                 --resume "$session_id" --output-format json)
  fi

  # 4) Capture session id + accumulate cost.
  session_id=$(printf '%s' "$out" | jq -r '.session_id // empty')
  printf '%s\n' "$session_id" > "$STATE_DIR/session_id"
  iter_cost=$(printf '%s' "$out" | jq -r '.total_cost_usd // 0')
  spent=$(awk "BEGIN{print $spent + $iter_cost}")
  echo "iter cost=\$$iter_cost  cumulative=\$$spent  session=$session_id"
done

# Hitting the cap is a SUCCESSFUL guardrail, not a crash — but flag it loudly.
echo "⚠️  Hit MAX_ITERS=$MAX_ITERS without meeting the exit condition. Stopping (no loopmaxxing)."
exit 3
