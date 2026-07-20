# Claude Code loop primitives

Everything you can build a loop out of, today. The first four are **primary-docs,
high-confidence**; Routines/Tasks are real features corroborated by docs + press.

## 1. Headless mode — `claude -p` / `--print`

Runs non-interactively: reads stdin, writes stdout like any CLI tool. This is the
foundation of every shell loop.

```bash
cat build-error.txt | claude -p "Suggest a fix" > fix.txt
git diff main | claude -p "Review this diff"
```

## 2. Session chaining — `--continue` / `--resume`

Turn one-shot runs into a multi-turn loop that keeps memory.

- `--continue` — resume the **most recent** session in this project dir.
- `--resume <session_id>` — resume a **specific** session.

Capture the id from JSON output:

```bash
sid=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$sid"
```

> Scoped to the current project directory.

## 3. Cost gating — `--output-format json`

The JSON payload includes **`total_cost_usd`** plus a per-model breakdown, so a
scripted loop can track spend and stop before the next call.

```bash
out=$(claude -p "$prompt" --output-format json)
cost=$(printf '%s' "$out" | jq -r '.total_cost_usd // 0')
text=$(printf '%s' "$out" | jq -r '.result // .response // empty')
```

> Verify whether `total_cost_usd` is per-call or session-cumulative in your
> version, and sum or read-max accordingly. Templates here sum per-call.

## 4. First-party slash commands

- **`/loop`** — run a prompt or slash command on a **fixed interval** or
  self-paced. `/loop 5m /run-tests`. Omit the interval to let the model pace itself.
  Good for polling and recurring checks *within a session*.
- **`/goal`** (v2.1.139+) — **condition-based**: Claude keeps working until a
  completion condition is graded true. After each turn a **separate small/fast
  model (defaults to Haiku)** returns a yes/no on whether the condition holds.
  This is a built-in generator/checker split — prefer it over hand-rolling when
  the goal fits in one session.

  See `templates/goal-loop.md`.

## 5. Tasks — durable, shareable state (`~/.claude/tasks`, v2.1.16+)

Filesystem-backed task state that survives crashes and coordinates work across
sessions, subagents, and context windows.

```bash
# Point multiple Claude Code instances at ONE shared task list:
CLAUDE_CODE_TASK_LIST_ID=my-project claude
```

Instances self-claim work via file locking and observe each other's status —
multi-agent coordination without external tools.

> Caveat: `~/.claude/tasks` is **local** state. There is no automatic cross-machine
> sync or event push; "shared" means a shared named directory.

## 6. Cloud Routines

Scheduled/triggered **cloud** agents (via the Agent SDK) that monitor a queue and
act without a human starting them: listen for tickets/issues/bug reports, pick up
an issue, push a fix, ping the PR owner. Anthropic frames these as the first
obvious Agent-SDK use: **code review, PR babysitting, CI fixes, rebasing** —
"Claude prompts Claude Code."

Use a Routine (not `/loop`) when the loop must run **without your machine on** and
react to external events. A human still merges.

## Choosing where a loop runs

| Need | Use |
|---|---|
| Iterate now, in my terminal, I'm watching | `claude -p` while-loop or `/loop` |
| Work until a goal, one session | `/goal` |
| Keep durable state / multiple agents coordinate | Tasks + `CLAUDE_CODE_TASK_LIST_ID` |
| Run on a schedule / react to events, machine off | cloud Routine |
| Dynamic fan-out with verify | Workflow tool or `fanout-orchestrator.sh` |
