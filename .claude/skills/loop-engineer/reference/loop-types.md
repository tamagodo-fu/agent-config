# Loop types — the execution-shape taxonomy (Stage 0)

Source: the Claude Code team's "Getting started with loops"
(@ClaudeDevs / @delba_oliveira, x.com/ClaudeDevs/status/2074208949205881033,
2026-07-07). Definition: **loops are agents repeating cycles of work until a
stop condition is met.** They are classified by four axes: how they are
**triggered**, how they are **stopped**, which Claude Code **primitive** runs
them, and what **task type** fits each.

This is the *execution shape* — orthogonal to `taxonomy.md`'s five *reasoning
shapes*. Classify here first (Stage 0), then pick the reasoning pattern
(Stage 1).

## The four types

| | Turn-based | Goal-based | Time-based | Proactive |
|---|---|---|---|---|
| **Triggered by** | a user prompt | a manual prompt in real-time | a time interval / schedule | an event or schedule, no human in real time |
| **Stop criteria** | Claude judges it's done or needs context | goal achieved OR max turns reached | you cancel it, or the work completes (PR merged, queue empty) | each task exits at its goal; the routine runs until turned off |
| **You hand off** | the check | the stop condition | the trigger | the prompt |
| **Best for** | shorter tasks, exploring/deciding, not recurring | tasks with verifiable exit criteria | recurring work; interfacing with external systems | recurring streams of well-defined work (triage, migrations, dependency upgrades) |
| **Primitive** | plain prompting + a verification skill | `/goal` (evaluator model grades the condition each turn) | `/loop` (in-session) or `/schedule` (cloud) | `/schedule` + `/goal` + skills + workflows + auto mode, composed |
| **Manage usage by** | specific prompts; encode verification as a SKILL.md | specific completion criteria + explicit turn caps ("stop after 5 tries") | longer intervals; react to events rather than time | routing routines to smaller/faster models; capable model only for judgment calls |

Notes per type:

- **Turn-based** is the default agentic loop every prompt starts — usually *not
  loop-engineering work*. The lever is a verification skill (e.g.
  `verify-frontend-change`) so Claude checks more of its own work end-to-end;
  the more quantitative the checks, the better the self-verification. If the
  user is here, don't scaffold a loop — offer to write the verification skill.
- **Goal-based** is where this skill's "one rule" bites: deterministic criteria
  (tests passed, score threshold) work; vague ones loopmaxx. `/goal` gives a
  built-in generator/checker split before you hand-roll one.
- **Time-based** runs on your machine with `/loop` (dies with the session) or
  in the cloud with `/schedule`. Match the interval to how often the watched
  thing actually changes.
- **Proactive** is a composition, not a primitive: schedule the trigger, define
  done with `/goal`, encode verification as skills, orchestrate with workflows,
  and run in auto mode. Example shape: "/schedule every hour: check the
  feedback channel. /goal: don't stop until every report is triaged, actioned,
  responded to. Use a workflow to explore three fixes in parallel worktrees
  with an adversarial judge."

## Stage 0 → Stage 1 mapping

| Stage 0 type | Likely Stage 1 pattern (taxonomy.md) | Scaffold |
|---|---|---|
| Turn-based | none — write a **verification skill** instead | SKILL.md with quantitative end-to-end checks |
| Goal-based | single agentic loop; **evaluator-optimizer** if "done" is a judgment call; **meta/prompt-refinement** if the prompt itself is the artifact | `/goal`, `templates/headless-loop.sh`, `templates/evaluator-optimizer.sh`, `templates/meta-prompt-refine.sh` |
| Time-based | wraps any pattern; often plain report/check work | `/loop`, `/schedule` (see `primitives.md`) |
| Proactive | **orchestrator-workers** inside a scheduled trigger | `/schedule` + Workflow tool / `templates/fanout-orchestrator.sh` |

## Quality & token discipline (applies to every type)

- Keep the codebase clean — the loop follows existing conventions.
- Give the loop a way to verify its own work (skills); use a **second agent
  with fresh context** for review (built-in `/code-review`).
- When one result fails the bar, don't just fix it — encode the fix into the
  system (skill/prompt/check) so all future iterations improve.
- Choose the right primitive AND model; pilot before a large run; use scripts
  for deterministic steps; don't run routines more often than the watched thing
  changes; review with `/usage`, `/goal` (no args), `/workflows`.
