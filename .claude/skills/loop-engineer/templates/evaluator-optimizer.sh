#!/usr/bin/env bash
#
# evaluator-optimizer.sh — generator/critic loop.
# A GENERATOR agent produces work; a SEPARATE CRITIC agent grades it and feeds
# critique back. The split is the whole point: a model grading its own output is
# too lenient. The critic runs in a FRESH session with different, stricter
# instructions every round.
#
# Usage:
#   WORK=draft.md \
#   TASK='Write a clear, accurate 200-word summary of spec.md.' \
#   MAX_ITERS=5 BUDGET_USD=3.00 \
#   ./evaluator-optimizer.sh
#
set -euo pipefail

# ---- Config ---------------------------------------------------------------
MAX_ITERS="${MAX_ITERS:-5}"
BUDGET_USD="${BUDGET_USD:-3.00}"
WORK="${WORK:-draft.md}"                       # file the generator writes/revises
TASK="${TASK:-Write a clear 200-word summary of spec.md.}"
# The bar the critic judges against. Make it concrete and demanding.
RUBRIC="${RUBRIC:-Accurate, no fluff, exactly meets the task, no factual errors.}"
# ---------------------------------------------------------------------------

spent=0
gen_session=""
feedback=""
under() { awk "BEGIN{exit !($1 < $2)}"; }
add_cost() {  # $1 = json output
  local c; c=$(printf '%s' "$1" | jq -r '.total_cost_usd // 0')
  spent=$(awk "BEGIN{print $spent + $c}")
}

for ((i=1; i<=MAX_ITERS; i++)); do
  echo "=== Round $i/$MAX_ITERS (spent \$$spent) ==="

  if ! under "$spent" "$BUDGET_USD"; then
    echo "🛑 Budget cap reached (\$$spent >= \$$BUDGET_USD). Stopping."; exit 2
  fi

  # --- GENERATOR (keeps its own session so it remembers prior drafts) ---
  if [[ -z "$gen_session" ]]; then
    g=$(claude -p "$TASK Write the result to $WORK." --output-format json)
  else
    g=$(claude -p "Revise $WORK using this critique. Then save it back to $WORK:
$feedback" --resume "$gen_session" --output-format json)
  fi
  gen_session=$(printf '%s' "$g" | jq -r '.session_id // empty')
  add_cost "$g"

  # --- CRITIC (FRESH session every round — no memory of the generator) ---
  # Stateless on purpose: it must not absorb the generator's rationalizations.
  c=$(claude -p "You are a strict, skeptical reviewer. Read the file $WORK.
Judge it ONLY against this bar: $RUBRIC
Original task: $TASK
Reply with 'PASS' as the FIRST word if it fully clears the bar.
Otherwise reply 'REVISE' then a short bullet list of concrete required fixes.
Do not be lenient. Do not praise. If unsure, REVISE." --output-format json)
  add_cost "$c"
  verdict=$(printf '%s' "$c" | jq -r '.result // .response // empty')

  echo "--- critic ---"; printf '%s\n' "$verdict"
  if printf '%s' "$verdict" | head -1 | grep -qi '^[^A-Za-z]*PASS'; then
    echo "✅ Critic passed it in round $i. Result in $WORK. (spent \$$spent)"
    exit 0
  fi
  feedback="$verdict"
done

echo "⚠️  Hit MAX_ITERS=$MAX_ITERS without a PASS. Best effort is in $WORK. Stopping."
exit 3
