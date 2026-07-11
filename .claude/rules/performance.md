# Performance Optimization

## Model Selection Strategy

現行モデル: Fable 5 (`claude-fable-5`) / Opus 4.8 (`claude-opus-4-8`) / Sonnet 5 (`claude-sonnet-5`) / Haiku 4.5 (`claude-haiku-4-5-20251001`)。

**Orchestrator**（メインループ。`~/.claude/settings.json` の `model`）
- 既定 = Fable。サブスクで使える限りFableを使う。
- Fableが使えない時だけ手動で `opus` に切替える(自動フォールバックの仕組みは無いので、その場のセッションで手動判断)。

**Worker**（`Agent` ツールで呼ぶサブエージェント。`.claude/agents/*.md` の `model:`）
- 既定 = Sonnet 5。各agent frontmatterはsonnetを既定値にする。
- 例外: そのタスクが「深い推論が要る」とオーケストレーターが判断した時だけ、`Agent` 呼び出しの `model` パラメータでそのタスク単位に `opus` を指定する(アーキテクチャ判断、行き詰まったデバッグ、セキュリティクリティカルなレビュー等)。frontmatter自体を恒久的にopus固定にはしない。
- Haiku 4.5は「本当に単純作業」の時だけ明示的に使う。Usage枠に余裕があってもそれを理由にHaikuへ寄せない(既定はSonnet)。

## Context Window Management

Avoid last 20% of context window for:
- Large-scale refactoring
- Feature implementation spanning multiple files
- Debugging complex interactions

Lower context sensitivity tasks:
- Single-file edits
- Independent utility creation
- Documentation updates
- Simple bug fixes

## Ultrathink + Plan Mode

For complex tasks requiring deep reasoning:
1. Use `ultrathink` for enhanced thinking
2. Enable **Plan Mode** for structured approach
3. "Rev the engine" with multiple critique rounds
4. Use split role sub-agents for diverse analysis

## Build Troubleshooting

If build fails:
1. Analyze error messages
2. Fix incrementally
3. Verify after each fix
