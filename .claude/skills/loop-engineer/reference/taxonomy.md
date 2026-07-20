# Loop architecture taxonomy

The canonical source is Anthropic's *Building Effective Agents*
(anthropic.com/research/building-effective-agents). It distinguishes **workflows**
(LLMs orchestrated through predefined code paths — predictable, consistent) from
**agents** (LLMs dynamically directing their own process — flexible at scale).
Loops sit on top of both.

## 1. Single agentic loop

One agent iterates toward one binary check. Cheapest, simplest.

- **Use when:** the goal is one verifiable condition (tests pass, lint clean, file
  exists with the right shape) and one agent with tools can get there.
- **Implement:** `templates/headless-loop.sh` or `/goal`.
- **Risk:** if the check isn't truly binary, this is the classic loopmaxxing trap.

## 2. Evaluator-optimizer (generator–critic)

One model **generates**; a **second, differently-instructed model evaluates** and
feeds critique back. Loop until the critic passes it (or max-iters).

- **The single most consequential design choice in all of loop engineering:**
  split the writer from the checker. A model grading its own output is too
  lenient; a separate critic with different instructions catches the failures the
  generator reasoned itself into.
- **Use when:** there are clear evaluation criteria AND iterative refinement adds
  measurable value — writing, code that must meet a bar, anything where "good
  enough" is a judgment.
- **Implement:** `templates/evaluator-optimizer.sh`. Anthropic ships a reference
  notebook (anthropic-cookbook `patterns/agents/evaluator_optimizer.ipynb`).
- **Risk:** evaluator collusion/collapse — see `guardrails.md`.

## 3. Meta / prompt-refinement loop  ← the high-value, under-served one

A loop whose *output is a better prompt* for another loop. It runs a candidate
prompt over a test set, scores the results against ground truth with a separate
evaluator, and asks an optimizer to rewrite the prompt from the failures — then
re-checks on a **held-out set** so it doesn't just overfit.

- **Use when:** you'll run the same task prompt many times and small quality gains
  compound (a skill's instructions, a classifier prompt, a sub-agent's brief).
- **Lineage:** evaluator-optimizer + the *Self-Taught Evaluators* technique
  (Wang et al., Meta FAIR, arXiv 2408.02666): generate contrasting outputs, train
  a judge to emit reasoning + verdicts, iterate — improved a judge 75.4→88.3 on
  RewardBench with no human labels.
- **Implement:** `templates/meta-prompt-refine.sh`.
- **Reality check:** the published self-improvement work is mostly *training-time*,
  not a turnkey Claude Code runtime loop. This template assembles it from runtime
  primitives — treat the prompt-rewrite step as assistive, keep a human in the
  selection of the winning prompt.
- **Risk (high):** the evaluator and the prompt co-adapt and overfit. Mandatory
  defenses: a fixed **holdout set**, a small **human-labeled anchor set**, and
  periodic audits of evaluator-vs-human disagreement. Without these it silently
  drifts.

## 4. Orchestrator-workers (fan-out + verify)

A central agent **dynamically** decides the subtasks, dispatches them to workers
(often in parallel), and a verify pass checks each result.

- **Use when:** you can't predict the subtasks up front (vs. static
  parallelization, where you can). Broad refactors, audits, migrations, research
  sweeps.
- **Implement:** the **Workflow tool** (deterministic fan-out/pipeline with
  built-in verify stages) is the cleanest path; `templates/fanout-orchestrator.sh`
  shows the raw shell version.
- **Pair with:** Tasks (`CLAUDE_CODE_TASK_LIST_ID`) so workers coordinate and
  results survive crashes.

## 5. Scheduled / triggered (interval & event)

Not a reasoning shape but an *execution* shape: `/loop` (interval, in-session) and
cloud **Routines** (schedule/webhook, machine-off). Wrap any of patterns 1–4.

## Nesting — the part the sources leave as an open question

The primitives are documented in isolation; the worked nested architecture is
where you add value. Useful compositions:

- **Outer meta-loop → inner headless loop:** the meta-loop rewrites the task
  prompt; each candidate is run by a guarded headless loop; the meta-loop scores
  the run, not a single output.
- **Orchestrator → per-worker evaluator-optimizer:** the orchestrator fans out;
  each worker is a generator/critic loop so its piece is verified before merge.
- **Always cap every level.** Nested loops multiply: an outer cap of 5 × inner cap
  of 5 = up to 25 agent runs. Budget for the product, not the sum.
