# Performance Optimization

## Model Selection Strategy

現行モデル: Fable 5.1 (`claude-fable-5-1`) / Opus 5 (`claude-opus-5`) / Sonnet 5 (`claude-sonnet-5`) / Haiku 4.5 (`claude-haiku-4-5-20251001`)。(Fable 5 / Opus 4.8 は legacy)

**Orchestrator**（メインループ。`~/.claude/settings.json` の `model`）
- 既定 = Fable（`settings.json` の値は `claude-fable-5-1`。`[1m]` 等の context サフィックスは公式記法に無く、Fable 5.1 は 1M context がネイティブなので不要）。サブスクで使える限りFableを使う。
- Fableが可用性の問題で使えない時だけ手動で `opus` に切替える(可用性起因の自動フォールバックは無いので、その場のセッションで手動判断)。
- **安全分類器による自動フォールバックの実測**(公式ドキュメントには記載が無く、以下は自環境での観測に基づく): cyber/bio分類器にフラグされると自動でOpusに切替わり、以降そのセッションはOpusのまま継続する(初回リクエストのCLAUDE.md/ワークスペースコンテキストでも発火し得る)。Opusになっていたら `/model fable` で復帰。詳細はメモリ `fable-opus-fallback` 参照。

**Worker**（`Agent` ツールで呼ぶサブエージェント。`.claude/agents/*.md` の `model:`）
- 委譲する場合の既定 = Sonnet 5。各agent frontmatterはsonnetを既定値にする(frontmatter の `model:` は short name で書く: `fable` / `opus` / `sonnet` / `haiku`。`fable` は Fable 5.1 を指す)。
- 例外: そのタスクが「深い推論が要る」とオーケストレーターが判断した時だけ、`Agent` 呼び出しの `model` パラメータでそのタスク単位に `opus` を指定する(アーキテクチャ判断、行き詰まったデバッグ、セキュリティクリティカルなレビュー等)。frontmatter自体を恒久的にopus固定にはしない。
- Haiku 4.5は「本当に単純作業」の時だけ明示的に使う。Usage枠に余裕があってもそれを理由にHaikuへ寄せない(委譲時の既定はSonnet)。

## Codex Model Selection Strategy

この節は Codex に適用する。上記の Claude Code のモデル選択は変更しない。

- Orchestrator の既定は Astra (`gpt-6-astra`)。手順と完了条件が明確な定型タスクでは、ユーザーの指定に応じて Sol (`gpt-6-sol`) を使う。
- 委譲する場合の Worker 既定は Sol (`gpt-6-sol`)。通常の実装・修正・検証を委譲する時は Sol を使う。focusedな探索・一次ソース調査には Luna を使う。深い推論が必要な設計判断・原因不明のデバッグ・重要なレビューは Astra に格上げする。
- `explorer` と `researcher_worker` は必要な場合にだけ `gpt-6-luna / max` で使う。実装workerの既定にはしない。GPT-6 Terra のモデルIDは公式資料で確認できていないため指定しない。
- Codex で通常の委譲を行う場合は `sol_worker` を使う。focusedな探索・一次ソース調査には `gpt-6-luna`、実装・修正には `gpt-6-sol` を使う。利用できない場合は、モデルを指定できる汎用サブエージェントで `gpt-6-sol` を明示する。親モデルの継承だけに任せない。モデル指定を伴う新規委譲では、必要な文脈をタスクに渡し、全履歴の継承とモデル上書きを併用しない。
