# agent-config

Shareable [Claude Code](https://docs.claude.com/en/docs/claude-code) orchestration
config: an orchestrator `CLAUDE.md`, a set of core rules, and subagents.

## Repository layout

```
.claude/
├── CLAUDE.md          # orchestrator entry point — main-loop policy
├── rules/             # individual rule files, referenced from CLAUDE.md
│   ├── orchestration.md
│   ├── performance.md
│   ├── grounding-judgment.md
│   ├── memory-writing.md
│   ├── agents.md
│   └── terminal-commands.md
├── agents/
│   ├── advisor.md     # stronger-model reviewer — see below
│   └── verifier.md    # stronger-model PASS/FAIL checker — see below
└── skills/
    ├── fable-verify/            # executor-verifier loop skill
    └── cost-effective-harness/  # harness design-guidance skill
.codex/
├── AGENTS.md                    # cross-CLI instructions generated from .claude/CLAUDE.md + rules
├── sync-agents-md-check.sh      # drift detector: warns when the .claude sources change
└── config.toml                  # sanitized Codex CLI config (machine-local state removed)
.config/herdr/
└── config.toml                  # herdr (terminal multiplexer for agents) keybinds / UI prefs
.agents/skills/agmsg/plugins/types/devin/
└── ...                          # custom Devin type driver for agmsg cross-agent messaging
```

### Rules

| File | What it does |
|---|---|
| `orchestration.md` | The main loop focuses on interpreting user instructions and dividing work; actual execution is delegated to subagents. |
| `performance.md` | Model selection strategy — orchestrator defaults to the top-tier model, workers default to a mid-tier model. |
| `grounding-judgment.md` | No-speculation by default — prioritize primary sources, and return judgment calls via `AskUserQuestion`. |
| `memory-writing.md` | Immediately persist failure → resolution learnings to memory in if-then form. |
| `agents.md` | Guidance for using parallel subagents and multi-perspective analysis effectively. |
| `terminal-commands.md` | Commands the user must run themselves are handed off via a file, not pasted inline. |

### Usage

Drop these under `~/.claude/` to apply them globally across every project:

- `.claude/CLAUDE.md` → `~/.claude/CLAUDE.md`
- `.claude/rules/` → `~/.claude/rules/`

(Or place them per-project instead, the same way as the `advisor` agent below.)

## `advisor` — a stronger-model reviewer for your Claude Code sessions

`advisor` is a Claude Code emulation of Anthropic's Messages API
[advisor tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool).

The idea: your main Claude Code session does the mechanical work (the *executor*),
and consults a **stronger model** (the *advisor*) at key decision points. The
advisor reviews the situation and returns a **plan or course-correction** — it
never implements anything. You get close to advisor-quality decisions while most
of the work happens at your executor model's speed and cost.

It runs as a subagent, so it gets an **isolated context**, its **own model**
(`fable` by default), and **read-only tools** — it can inspect your code but can't
edit files or run state-changing commands.

### When it fires

The subagent's description makes Claude consult it **proactively** at the moments
that matter most:

- **Before** the first file write / state-changing command on a task
- **When stuck** — recurring errors, an approach that won't converge, results
  that don't fit
- **Before** declaring a task done

You can also invoke it explicitly: `@advisor review this design before I build it`.

## `verifier` — a stronger-model PASS/FAIL check on finished work

`verifier` is the counterpart to `advisor`: where the advisor steers you
**before and during** a task, the verifier judges the result **after** it. It
runs on a stronger model (`fable` by default) in an isolated context with
read-only tools plus `Bash` for verification commands only (tests, builds,
`git diff`) — it checks the work against explicit acceptance criteria and
returns a `PASS` / `FAIL` verdict with concrete fix instructions. It never
implements the fix itself.

### When it fires

- **After** work is done, before you declare a task complete
- At checkpoints inside a multi-step or `/goal` loop
- To judge a worker / sub-agent's output before accepting it

It defaults to `FAIL` when evidence is missing (an unverifiable claim is not a
pass), and it re-checks **every** criterion on re-verification, since a fix
often regresses a neighbor. For re-verification, resume the *same* verifier via
`SendMessage` rather than spawning a fresh one — that keeps its prompt cache and
its memory of the prior failures.

## Skills

Two skills wire the verifier into a repeatable workflow and the cost reasoning
behind it. Drop them under `~/.claude/skills/` (or a project's `.claude/skills/`).

| Skill | What it does |
|---|---|
| `fable-verify` | Runs the full executor-verifier loop: pin down acceptance criteria, launch the `verifier` agent, apply its fix instructions, and re-verify until `PASS` (max 3 rounds). Skip it for trivial diffs where the built-in `/verify` self-check is enough. |
| `cost-effective-harness` | Design guidance for where to spend frontier intelligence in a multi-agent harness — orchestrator vs. advisor vs. verifier, delegation heuristics, coordination cost, and prompt caching. Read it *before* designing a fan-out or deciding whether to delegate at all. |

## Install

Global (available in every project):

```sh
mkdir -p ~/.claude/agents
curl -fsSL https://raw.githubusercontent.com/tamagodo-fu/agent-config/main/.claude/agents/advisor.md \
  -o ~/.claude/agents/advisor.md
```

Or per-project — drop the file into that repo's `.claude/agents/advisor.md`.

Restart Claude Code (or start a new session) and it will pick up the agent.

## Configuration

Edit the frontmatter in `advisor.md`:

- **`model:`** — the advisor must be **at least as capable as your main session's
  model**; a smarter second opinion is the entire point. Claude Code can't pick
  this per session, so it's a fixed value. Accepted: `fable` (default), `opus`,
  `sonnet`, `haiku`, a full model ID (e.g. `claude-opus-4-8`), or `inherit`.

  | Your main model | Recommended `model:` |
  |---|---|
  | Haiku / Sonnet | `fable` (best) or `opus` (cheaper, still stronger) |
  | Opus | `fable` |
  | Fable | `fable` (peer — still useful for a fresh, unbiased review) |

  `fable` is the default because it stays ≥ the executor for every Haiku / Sonnet /
  Opus main. If you don't have Fable access, drop to `opus` — fine when your main
  is Sonnet or Haiku. **Never set a model weaker than your main, and never
  `inherit`** (that gives you a peer, erasing the advantage).
- **`tools:`** — kept read-only (`Read, Grep, Glob`) so the advisor can verify
  claims against your code without changing anything.

## How it differs from the real advisor tool

The Messages API advisor tool auto-forwards the executor's **full transcript**
and runs the advisor **in a single API call**. A Claude Code subagent instead
gets a **fresh, isolated context**, so it only knows what the main session hands
it when delegating. In practice that means: give it a good brief — the task,
what you've tried and observed, and the specific decision — and it will point you
in the right direction. If the brief is thin, it will tell you what else it needs
rather than guess.

## Credit

Pattern and prompting adapted from Anthropic's
[advisor tool documentation](https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool).
