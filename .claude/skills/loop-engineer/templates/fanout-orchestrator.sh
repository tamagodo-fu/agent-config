#!/usr/bin/env bash
#
# fanout-orchestrator.sh — orchestrator-workers (fan-out + verify), raw shell.
#
# An orchestrator decides the work items, dispatches a worker per item IN
# PARALLEL, then a SEPARATE verifier checks each result. Use when subtasks can't
# be predicted up front. For anything beyond a quick sweep, prefer the in-app
# Workflow tool (deterministic fan-out/pipeline with built-in verify stages) and
# share state via Tasks: `CLAUDE_CODE_TASK_LIST_ID=run1 claude`.
#
# Usage:
#   PLAN_PROMPT='List the files that need the deprecated API migrated, one per line.' \
#   WORKER_PROMPT='Migrate the deprecated API in this file:' \
#   MAX_WORKERS=20 CONCURRENCY=4 BUDGET_USD=15 \
#   ./fanout-orchestrator.sh
#
set -euo pipefail

# ---- Config ---------------------------------------------------------------
PLAN_PROMPT="${PLAN_PROMPT:-List the work items, one per line, no numbering.}"
WORKER_PROMPT="${WORKER_PROMPT:-Do the task for this item:}"
VERIFY_PROMPT="${VERIFY_PROMPT:-Reply PASS or FAIL: did this item get done correctly?}"
MAX_WORKERS="${MAX_WORKERS:-20}"        # hard cap on fan-out width (guardrail)
CONCURRENCY="${CONCURRENCY:-4}"         # parallel workers at once
BUDGET_USD="${BUDGET_USD:-15.00}"
OUT_DIR="${OUT_DIR:-.fanout-out}"
# ---------------------------------------------------------------------------

mkdir -p "$OUT_DIR"

# 1) ORCHESTRATOR decides the items dynamically.
echo "Planning…"
items=$(claude -p "$PLAN_PROMPT" --output-format json | jq -r '.result // .response // empty' \
        | grep -v '^[[:space:]]*$' | head -n "$MAX_WORKERS")
count=$(printf '%s\n' "$items" | grep -c . || true)
echo "Got $count item(s) (capped at $MAX_WORKERS)."
[[ "$count" -eq 0 ]] && { echo "Nothing to do."; exit 0; }

# 2) WORKERS run in parallel (xargs bounds concurrency).
echo "Dispatching workers (concurrency=$CONCURRENCY)…"
export WORKER_PROMPT OUT_DIR
printf '%s\n' "$items" | xargs -P "$CONCURRENCY" -I{} bash -c '
  item="$1"; safe=$(printf "%s" "$item" | tr -c "A-Za-z0-9._-" "_")
  claude -p "$WORKER_PROMPT
$item" --output-format json > "$OUT_DIR/$safe.json" 2>/dev/null \
    && echo "  ✓ $item" || echo "  ✗ $item"
' _ {}

# 3) VERIFIER checks each result (SEPARATE pass — workers do not grade themselves).
echo "Verifying…"
spent=0; pass=0; fail=0
for f in "$OUT_DIR"/*.json; do
  [[ -e "$f" ]] || continue
  cost=$(jq -r '.total_cost_usd // 0' "$f"); spent=$(awk "BEGIN{print $spent + $cost}")
  result=$(jq -r '.result // .response // empty' "$f")
  v=$(claude -p "$VERIFY_PROMPT
RESULT:
$result" --output-format json)
  vcost=$(printf '%s' "$v" | jq -r '.total_cost_usd // 0'); spent=$(awk "BEGIN{print $spent + $vcost}")
  if printf '%s' "$v" | jq -r '.result // .response // empty' | grep -qi 'PASS'; then
    pass=$((pass+1)); else fail=$((fail+1)); echo "  ⚠ verify FAIL: $(basename "$f")"; fi
done

echo "Done. pass=$pass fail=$fail  spent=\$$spent  (outputs in $OUT_DIR/)"
[[ "$fail" -gt 0 ]] && exit 1 || exit 0
