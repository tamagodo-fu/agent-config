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
└── agents/
    └── advisor.md     # see below
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
