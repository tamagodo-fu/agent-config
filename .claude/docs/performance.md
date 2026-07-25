# Performance Optimization

## Model Selection Strategy

現行モデル: Fable 5 (`claude-fable-5`) / Opus 4.8 (`claude-opus-4-8`) / Sonnet 5 (`claude-sonnet-5`) / Haiku 4.5 (`claude-haiku-4-5-20251001`)。

**Orchestrator**（メインループ。`~/.claude/settings.json` の `model`）
- 既定 = Fable（設定値は `claude-fable-5[1m]`）。サブスクで使える限りFableを使う。
- Fableが可用性の問題で使えない時だけ手動で `opus` に切替える(可用性起因の自動フォールバックは無いので、その場のセッションで手動判断)。
- ただし**安全分類器による自動フォールバックは存在する**: Fable 5 はcyber/bio分類器付きで、フラグされると自動でOpusに切替わり以降そのセッションはOpusのまま継続する(初回リクエストのCLAUDE.md/ワークスペースコンテキストでも発火し得る)。Opusになっていたら `/model fable` で復帰。詳細はメモリ `fable-opus-fallback` 参照。

**Worker**（`Agent` ツールで呼ぶサブエージェント。`.claude/agents/*.md` の `model:`）
- 既定 = Sonnet 5。各agent frontmatterはsonnetを既定値にする。
- 例外: そのタスクが「深い推論が要る」とオーケストレーターが判断した時だけ、`Agent` 呼び出しの `model` パラメータでそのタスク単位に `opus` を指定する(アーキテクチャ判断、行き詰まったデバッグ、セキュリティクリティカルなレビュー等)。frontmatter自体を恒久的にopus固定にはしない。
- Haiku 4.5は「本当に単純作業」の時だけ明示的に使う。Usage枠に余裕があってもそれを理由にHaikuへ寄せない(既定はSonnet)。
