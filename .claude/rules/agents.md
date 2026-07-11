# Agent Orchestration
## Immediate Usage

No user prompt needed:
1. Complex feature requests - built-in `Plan` agent
2. Code just written/modified - built-in `code-review` skill
3. Bug fix or new feature - test-first方針をその場で指示
4. Architectural decision - built-in `Plan` agent か `advisor`
5. 判断に迷ったり実装前に一段強いレビューが欲しい時 - **advisor** agent

## Parallel Task Execution

ALWAYS use parallel Task execution for independent operations:

```markdown
# GOOD: Parallel execution
Launch 3 agents in parallel:
1. Agent 1: Security analysis of auth.ts
2. Agent 2: Performance review of cache system
3. Agent 3: Type checking of utils.ts

# BAD: Sequential when unnecessary
First agent 1, then agent 2, then agent 3
```

## Multi-Perspective Analysis

For complex problems, use split role sub-agents:
- Factual reviewer
- Senior engineer
- Security expert
- Consistency reviewer
- Redundancy checker
