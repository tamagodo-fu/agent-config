---
name: ccusage
description: Claude Code等のトークン利用状況・コストを ccusage CLI で集計表示する。引数でサブコマンド指定可（daily/monthly/weekly/session/blocks 等）。
argument-hint: "[daily|monthly|weekly|session|blocks|...] [options]"
allowed-tools: Bash(ccusage:*)
---

# ccusage

`ccusage` CLI を実行して利用状況を表示する。

`$ARGUMENTS` が指定されていればそれをそのまま `ccusage` に渡す。空なら `ccusage daily`（デフォルト）を実行する。

実行後、出力テーブルの要点（対象期間・合計コスト・目立つ増減）を日本語で1〜2行だけ添えて要約する。テーブル自体はそのまま見せる。

```
ccusage $ARGUMENTS
```
