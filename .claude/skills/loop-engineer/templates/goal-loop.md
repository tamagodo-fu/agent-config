# First-party loops: `/goal` and `/loop`

When the loop fits inside one Claude Code session, you usually don't need a shell
script — use the built-in commands. They're the lowest-effort, best-guardrailed
option.

## `/goal` — condition-based, with a built-in separate evaluator

`/goal` keeps working until a completion condition is graded true. After **every
turn**, a **separate small/fast model (defaults to Haiku)** returns yes/no on
whether the condition holds. That separation is the generator/checker split for
free — the model doing the work doesn't get to declare itself done.

**Use it when:** the goal fits in one session and you can phrase it as a binary
condition.

```
/goal All tests in `npm test` pass and `npm run lint` reports zero errors.
```

```
/goal The function `parseInvoice` handles the three malformed-input cases in
      tests/fixtures/ and every test in invoice.test.ts is green.
```

**Make the condition binary and verifiable** — the same rule as every other loop.
`/goal make the code nicer` has nothing for the evaluator to grade and will spin.

## `/loop` — interval or self-paced repetition

`/loop` runs a prompt or slash command on a fixed interval, or self-paced if you
omit the interval.

```
/loop 5m /run-tests          # every 5 minutes
/loop /check-ci-and-fix      # self-paced; the model decides cadence
```

**Use it for:** polling and recurring checks while you're in a session
(watch CI, re-run a flaky check, poll a queue).

## Choosing between them and a shell loop

| Situation | Reach for |
|---|---|
| Work until a binary goal, one session, watching | `/goal` |
| Repeat on an interval, in-session | `/loop` |
| Need cost gating, custom exit checks, runs outside a session, or to chain many sessions | `headless-loop.sh` |
| Must run with your machine off / react to events | cloud **Routine** (see `reference/primitives.md`) |

## Guardrails still apply

`/goal` gives you the separate-evaluator and stopping behavior, but **you** still
own:
- a **binary** condition (no "make it better"),
- knowing it can run many turns — watch the cost,
- a **sandbox** if it edits files (branch/worktree),
- a **human checkpoint** before anything irreversible.
