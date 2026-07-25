# Claude Code Guidelines

## Context Hygiene (CRITICAL)

設定(CLAUDE.md/rules/skills)は「足す」より「痩せさせる」。常時ロードは安全・判断の土台だけに絞り、状況依存ルールは skill / paths: ゲートへ。絶対命令は security 等の highly important area に限定。定期的に /doctor で棚卸し。

詳細ルール: `~/.claude/rules/context-hygiene.md`

## File Naming

新規作成するファイル名は project 問わず**なるべく英語の slug 形式**（kebab-case、ASCII のみ）にする。例: `dal-ai-usage-guide.html`。理由: herdr-edit 等の CLI がマルチバイトパスで壊れることがあり、GBrain 的にも slug の方が読み取りやすい。文書タイトル（中身の見出し）は日本語のままでよい。

## オーケストレーション方針

メインループは**ユーザー指示の解釈と作業の分担に専念**し、実作業は named sub-agent に委譲する。4体以上の並列 fan-out / `Workflow` / ultracode は事前に `AskUserQuestion` で承認を得る。モデルは Orchestrator=Fable / Worker既定=Sonnet。

詳細: `~/.claude/docs/orchestration.md`(委譲の細目)、`~/.claude/docs/performance.md`(モデル選択)

## 状況依存ルール（発火トリガ）

- git commit/push/PR 作業時は `git-workflow` skill を使う（push が 404/Repository not found で失敗したら特に必須 — アカウント切替手順がある）
- hook にブロックされたら `~/.claude/docs/hooks.md` を参照
- 新機能実装時は battle-tested なスケルトンプロジェクトを探して土台にすることを検討
