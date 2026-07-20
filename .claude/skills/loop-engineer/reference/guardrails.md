# Failure modes & guardrails

The three things that actually go wrong, the numbers that prove they're real, and
the mitigations. This file is the "why" behind the SKILL's five-point checklist.

## Failure mode 1 — loopmaxxing (runaway loops)

The dominant failure: an agent loops indefinitely against a **vague objective**
("improve user experience," "make it better") that has **no binary pass/fail**.
With no concrete exit condition the loop never terminates and converts your
infrastructure budget into a large API bill with zero measurable progress.

**Mitigations**
- **Verifiable exit condition.** Replace "improve X" with "make all unit tests
  pass," "lint exits 0," "this assertion holds." Check it *before* each iteration.
- **Max-iteration cap in code.** A hard `for ((i=1;i<=MAX;i++))` bound. Anthropic
  explicitly recommends a maximum-iterations stopping condition to "maintain
  control." A cap in the *prompt* is not a cap.
- **Sandbox.** Anthropic recommends extensive testing in sandboxed environments
  with guardrails because autonomous loops mean higher cost and compounding errors.

## Failure mode 2 — cost blowups

Real incidents, not hypotheticals:

- A **4-agent loop ran 11 days → ~$47,000** because there were no per-agent budget
  caps and no mechanism to terminate before the next API call.
- A broken tool got called **400× in 5 minutes.**
- A loop bug / oversized context / model-routing mistake can turn a **$50/day
  budget into a $5,000 overnight bill.**
- Agents burn tokens **10–100× faster than chat** because each reasoning step's
  context is re-sent on every tool call (a 5-step loop ≈ 3.2× one call; 200 steps
  > 100×).

**The key lesson: budget *alerts* are not budget *enforcement*.** An alert fires
after the spend; enforcement blocks the next call.

**Mitigations**
- Sum `total_cost_usd` (from `--output-format json`) and **stop before** the call
  that would exceed the cap — in code, before the API request.
- Cap tokens/iterations/recursion-depth per run; abort gracefully when exceeded.
- For nested loops, budget the **product** of the caps, not the sum.

## Failure mode 3 — evaluator collusion / drift (meta & generator-critic loops)

Specific to self-improving and prompt-refinement loops:

- **Evaluator collusion** — the critic and generator co-adapt until the critic
  rubber-stamps the generator.
- **Evaluator collapse / bias amplification** — the judge drifts and amplifies its
  own bias each round.
- **Overfitting to synthetic preferences** — quality climbs on the loop's own
  metric while real-world quality stalls or drops.
- **Self-evaluation bias** — a model judging its own output is lenient (magnitude
  debated, but real). This is *why* the writer and checker must be different agents.

**Mitigations**
- **Separate critic** from generator (different model and/or different instructions).
- **Inject adversarial counterexamples** each round.
- **Small human-labeled anchor set** the loop is scored against.
- **Fixed holdout set** + periodic human audits; **monitor evaluator-vs-human
  disagreement** to detect drift early.
- Keep a human in the loop for selecting the winning prompt/output.

## The five-point checklist (enforce before shipping any loop)

1. Verifiable, binary exit condition — checked each iteration.
2. Max-iteration cap — hard bound in code.
3. Budget cap — summed cost, enforced before the next call.
4. Sandbox — worktree/container/branch, never unattended on `main`.
5. Human checkpoint — for any push/deploy/send/irreversible action.

If you can't satisfy #1, the goal isn't loop-ready. Fix the goal, not the loop.
