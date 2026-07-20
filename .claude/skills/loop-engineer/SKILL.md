---
name: loop-engineer
description: >-
  Set up, scaffold, and administer agentic loops in Claude Code — headless
  while-loops around `claude -p`, evaluator-optimizer (generator/critic) loops,
  meta / prompt-refinement loops (a loop that refines the prompts another loop
  runs), and orchestrator fan-out. Starts by triaging the use case with
  AskUserQuestion (trigger / stop criteria / recurrence) into turn-based,
  goal-based, time-based, or proactive loops, then maps to a pattern and
  primitive. Every loop ships with non-negotiable guardrails: a verifiable exit
  condition, a max-iteration cap, and in-code budget enforcement. Use whenever
  the user wants to build, design, run, wire, or supervise loops / agent loops
  / "loop engineering" / nested sub-loops, or asks how to make Claude prompt
  Claude on a schedule or until a goal is met.
---

# Loop Engineer

Loops are the third object of attention in coding: **source code → agent → loop.**
Your job with this skill is to turn a user's goal into the *right* loop pattern,
scaffolded with guardrails so it can't "loopmaxx" (run forever against a vague
objective and burn money).

## The one rule that prevents most disasters

**Refuse to build a loop without a binary, verifiable exit condition.** "Improve
the UX" has no pass/fail and produces infinite loops + large API bills. "Make
`npm test` exit 0" does. If the user's goal isn't binary, your first job is to
help them make it binary — not to scaffold the loop.

## Stage 0 — triage the use case before picking a pattern

The decision tree below picks the *reasoning shape*. Before that, classify the
*execution shape* — how the loop is triggered and stopped (the Claude Code
team's four loop types; see `reference/loop-types.md` for the full taxonomy).

**In the main conversation, ask via AskUserQuestion** (one call, up to three
questions). Subagents cannot use AskUserQuestion — if you are one, infer the
answers from the brief and state your assumptions explicitly.

1. **Trigger** — what starts an iteration?
   - I prompt it right now, once
   - I prompt it and it should keep going until done
   - A time interval / schedule
   - An external event or an incoming stream of work
2. **Stop criteria** — how does it know it's done?
   - I look at the result and decide (human judgment)
   - A machine-checkable condition (tests pass, threshold met, queue empty)
   - It shouldn't stop — it runs until I cancel it
3. **Human involvement** — watching in real time / async review / unattended

Map the answers:

| Answers | Type | Reach for |
|---|---|---|
| manual trigger + human judges | **Turn-based** | no loop — a verification skill |
| manual trigger + verifiable condition | **Goal-based** | `/goal` or a guarded loop (Stage 1) |
| time trigger, runs until cancelled | **Time-based** | `/loop` (in-session) or `/schedule` (cloud) |
| event/stream trigger + unattended | **Proactive** | `/schedule` + `/goal` + skills + workflows composed |

Two triage outcomes end here without scaffolding a loop:
- **Turn-based** → offer to encode the user's manual checks as a verification
  SKILL.md instead. That's the leverage, not a loop.
- **Vague stop criteria** on anything else → apply "the one rule" above: make
  the goal binary first.

Otherwise carry the type into Stage 1: Goal-based selects among the first three
branches; Time-based/Proactive wrap a Stage 1 pattern in a schedule.

## Stage 1: Decision tree — pick the pattern

```
Is the goal one binary check the agent iterates toward (tests pass, lint clean)?
│
├─ YES, one agent is enough .......................... HEADLESS WHILE-LOOP
│        (templates/headless-loop.sh)                  or first-party /goal
│
├─ Quality matters & "done" is a judgment call ...... EVALUATOR-OPTIMIZER
│        (writing, code that must meet a bar)          (templates/evaluator-optimizer.sh)
│        → ALWAYS a separate critic agent
│
├─ You're improving the PROMPT itself, not the output  META / PROMPT-REFINEMENT
│        (a loop that rewrites the prompt another      (templates/meta-prompt-refine.sh)
│         loop runs, scored on a test set)             → needs holdout + anchor set
│
├─ Subtasks can't be predicted up front ............. ORCHESTRATOR FAN-OUT
│        (delegate dynamically, then verify each)      (templates/fanout-orchestrator.sh
│                                                        or the Workflow tool)
│
└─ Just run something on a schedule / interval ...... /loop or cloud Routines
         (poll, babysit PRs, recurring checks)         (reference/primitives.md)
```

Nest these: an **orchestrator** loop can spawn **evaluator-optimizer** inner loops;
a **meta** loop wraps a **headless** loop and rewrites its prompt between runs.

## Non-negotiable guardrail checklist

Before scaffolding ANY loop, confirm all five. See `reference/guardrails.md` for the why.

1. **Verifiable exit condition** — a command/check that returns binary done/not-done.
2. **Max-iteration cap** — a hard `for` bound, enforced in code, not in the prompt.
3. **Budget cap in code** — sum `total_cost_usd` from `--output-format json`; stop
   *before* the next call when over budget. Alerts are not enforcement.
4. **Sandbox** — loops that edit files/run commands run in a worktree, container,
   or branch — never unattended on `main`.
5. **Human checkpoint** — for anything outward-facing (push, deploy, send), the
   loop stops and asks, or only proposes.

A loop missing #1 or #2 is a bug, not a loop. Don't ship it.

## How to use this skill

1. Triage the use case (Stage 0, AskUserQuestion) into turn-based / goal-based
   / time-based / proactive; then map to a pattern via the decision tree.
2. If the goal isn't binary/verifiable, fix that first (with the user).
3. Copy the matching template from `templates/`, fill the config block, and wire
   the real exit check. Keep the guardrails.
4. Walk the user through the five-point checklist for their specific loop.
5. Tell them how to run it, how to stop it, and what it costs per iteration.

## Reference (load as needed)

- `reference/primitives.md` — every Claude Code loop primitive: `claude -p`,
  `--continue`/`--resume`, `--output-format json` (cost), `/loop`, `/goal`,
  Tasks (`~/.claude/tasks`, `CLAUDE_CODE_TASK_LIST_ID`), cloud Routines.
- `reference/loop-types.md` — Stage 0: the four execution-shape loop types
  (turn/goal/time/proactive), triage questions, and the Stage 0→1 mapping.
- `reference/taxonomy.md` — the five patterns in depth + when to use each.
- `reference/guardrails.md` — failure modes (loopmaxxing, cost blowups, evaluator
  collusion/drift) and the mitigations, with the cautionary numbers.
- `templates/*.sh`, `templates/goal-loop.md` — runnable scaffolds.

## What NOT to claim

Anthropic's *Building Effective Agents* is the canonical taxonomy source, but it
does **not** officially endorse "shell fan-out loops" or "headless-in-CI with Task
tracking" — those are community patterns. Attribute them as such.
