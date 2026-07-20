#!/usr/bin/env bash
#
# meta-prompt-refine.sh — a loop that refines the PROMPT another loop runs.
#
# This is the meta-loop: the output is a better *prompt*, not a better answer.
# It runs a candidate prompt over a TRAIN set, scores results against ground
# truth with a SEPARATE evaluator, asks an OPTIMIZER to rewrite the prompt from
# the failures, then validates on a HELD-OUT set so it improves real quality
# instead of overfitting the evaluator.
#
# Lineage: evaluator-optimizer + Self-Taught-Evaluators (arXiv 2408.02666).
# Reality check: published self-improvement is mostly training-time. This is a
# runtime approximation — keep a human on the final prompt selection.
#
# Test-case layout (you provide these):
#   cases/train/<name>.input      cases/train/<name>.expected
#   cases/holdout/<name>.input    cases/holdout/<name>.expected
#
# Usage:
#   PROMPT_FILE=prompt.txt CASES=cases MAX_ITERS=5 BUDGET_USD=10 \
#   PASS_THRESHOLD=0.9 ./meta-prompt-refine.sh
#
set -euo pipefail

# ---- Config ---------------------------------------------------------------
PROMPT_FILE="${PROMPT_FILE:-prompt.txt}"     # the prompt being improved (seed it)
CASES="${CASES:-cases}"
MAX_ITERS="${MAX_ITERS:-5}"
BUDGET_USD="${BUDGET_USD:-10.00}"
PASS_THRESHOLD="${PASS_THRESHOLD:-0.9}"      # stop when holdout score >= this
STATE_DIR="${STATE_DIR:-.meta-state}"
# ---------------------------------------------------------------------------

mkdir -p "$STATE_DIR"
spent=0
under() { awk "BEGIN{exit !($1 < $2)}"; }
ge()    { awk "BEGIN{exit !($1 >= $2)}"; }
add_cost(){ local c; c=$(printf '%s' "$1" | jq -r '.total_cost_usd // 0'); spent=$(awk "BEGIN{print $spent + $c}"); }

# Run the current prompt over a split, score each case with a SEPARATE evaluator
# against ground truth, and emit "score<TAB>failure_notes".
run_split() {           # $1 = split dir (cases/train | cases/holdout)
  local dir="$1" prompt; prompt=$(cat "$PROMPT_FILE")
  local n=0 pass=0 notes=""
  for inp in "$dir"/*.input; do
    [[ -e "$inp" ]] || continue
    local name exp got grade
    name=$(basename "$inp" .input)
    exp=$(cat "$dir/$name.expected")
    # 1) run the candidate prompt on the input
    local g; g=$(claude -p "$prompt

INPUT:
$(cat "$inp")" --output-format json)
    add_cost "$g"
    got=$(printf '%s' "$g" | jq -r '.result // .response // empty')
    # 2) SEPARATE evaluator grades got-vs-expected (binary, strict)
    local e; e=$(claude -p "You grade an output against the expected answer.
EXPECTED:
$exp
ACTUAL:
$got
Reply 'YES' on line 1 if ACTUAL is correct/equivalent to EXPECTED, else 'NO'
then one line on what's wrong. Be strict; equivalence not vibes." --output-format json)
    add_cost "$e"
    grade=$(printf '%s' "$e" | jq -r '.result // .response // empty')
    n=$((n+1))
    if printf '%s' "$grade" | head -1 | grep -qi '^[^A-Za-z]*YES'; then
      pass=$((pass+1))
    else
      notes+="- case '$name': $(printf '%s' "$grade" | tail -n +2 | head -1)"$'\n'
    fi
  done
  local score; score=$(awk "BEGIN{print ($n? $pass/$n : 0)}")
  printf '%s\t%s' "$score" "$notes"
}

cp "$PROMPT_FILE" "$STATE_DIR/prompt.v0.txt"

for ((i=1; i<=MAX_ITERS; i++)); do
  echo "=== Meta-iteration $i/$MAX_ITERS (spent \$$spent) ==="
  if ! under "$spent" "$BUDGET_USD"; then
    echo "🛑 Budget cap reached (\$$spent >= \$$BUDGET_USD). Stopping."; exit 2
  fi

  # Score on TRAIN to drive refinement.
  IFS=$'\t' read -r train_score train_notes < <(run_split "$CASES/train")
  echo "train score = $train_score"

  # Validate on HOLDOUT to catch overfitting — this is the real stopping signal.
  IFS=$'\t' read -r hold_score _ < <(run_split "$CASES/holdout")
  echo "holdout score = $hold_score"
  printf '%s\titer=%s\ttrain=%s\tholdout=%s\n' "$(date 2>/dev/null || echo iter$i)" "$i" "$train_score" "$hold_score" >> "$STATE_DIR/scores.tsv"

  if ge "$hold_score" "$PASS_THRESHOLD"; then
    echo "✅ Holdout score $hold_score >= $PASS_THRESHOLD. Winning prompt: $PROMPT_FILE"
    echo "   (Human review recommended before adopting.)"; exit 0
  fi

  # OPTIMIZER rewrites the prompt from the train failures.
  o=$(claude -p "You improve a task prompt. Current prompt:
---
$(cat "$PROMPT_FILE")
---
It failed these cases:
$train_notes
Rewrite the prompt so it fixes these failures WITHOUT special-casing individual
inputs (no overfitting, no hardcoded answers). Output ONLY the new prompt text." --output-format json)
  add_cost "$o"
  printf '%s' "$o" | jq -r '.result // .response // empty' > "$PROMPT_FILE"
  cp "$PROMPT_FILE" "$STATE_DIR/prompt.v$i.txt"
done

echo "⚠️  Hit MAX_ITERS=$MAX_ITERS. Best prompt + score history in $STATE_DIR/. Pick a winner by hand."
echo "    DRIFT CHECK: if train climbed while holdout stalled/fell, the evaluator is being gamed — add adversarial cases + a human-labeled anchor set."
exit 3
