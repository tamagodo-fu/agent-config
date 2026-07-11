# Claude Code Guidelines

## Grounding & Judgment (CRITICAL)

既定は no-speculation。一次ソース(公式doc/最新code)から始め、推測で埋めない。トレードオフ・選好は黙って既定値を選ばず `AskUserQuestion` で返す。判断が要る場面での確認・選択も `AskUserQuestion` を使う。

詳細ルール: `~/.claude/rules/grounding-judgment.md`

## Memory Writing (CRITICAL)

作業中に得た「失敗 → 原因特定 → 解決」の学びは、**ユーザー指示を待たず** if-then 形式でプロジェクトメモリへ即保存する。失敗ナレーションは書かず正解だけ書く。

詳細ルール: `~/.claude/rules/memory-writing.md`

## Terminal Commands Delivery (CRITICAL)

ユーザーが自分で実行する必要がある鍵情報を含むコマンドは必ず **プロジェクトローカル** の `<project-root>/.claude/tmp/<task-name>.sh` に書き (`.gitignore` 推奨)、`open` でエディタを起動してから「ファイルを開いたのでそこからコピーしてください」と伝える。

理由: TUI 直接貼り付けは改行折り返し・マークダウンエスケープで壊れ、ユーザーが手動編集する必要があり workflow を停滞させる。

詳細ルール: `~/.claude/rules/terminal-commands.md`

## オーケストレーション方針

メインループは**ユーザー指示の解釈と作業の分担に専念**し、実作業はサブスレッド(named sub-agent)に委譲する。固定ワーカー役は最初から作らず、都度skill/その場のプロンプトで委譲するかjudgeする。

詳細ルール: `~/.claude/rules/orchestration.md`
