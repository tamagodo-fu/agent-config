---
name: fable-verify
description: >
  Run an executor-verifier loop: verify completed work with the Fable-powered
  verifier agent against explicit acceptance criteria, apply its fix
  instructions, and re-verify until PASS (max 3 rounds). Use when work should
  be independently judged by a stronger model before being declared done —
  after implementing a feature, before commit/PR, after a worker sub-agent
  returns, or as the checkpoint inside a /goal loop. Not for trivial diffs
  (docs, one-liners) — built-in /verify self-check is enough there.
argument-hint: "[検証対象の説明 or 受入基準] (省略時は直前の作業を対象)"
---

# fable-verify

直前に完了した作業（または `$ARGUMENTS` で指定された対象）を、独立コンテキストの
`verifier` agent（Fable）に判定させ、FAIL なら修正指示を適用して再検証するループを回す。

## Phase 1: 受入基準の明文化

verifier に渡す**受入基準**を確定する。曖昧な基準は判定不能で差し戻されるので、
必ず以下の形に落とす:

- **測定可能な終了状態**: テスト結果・exit code・ファイル数・出力内容など
- **検証手段**: verifier が自分で実行できるコマンド（`npm test`、`pytest`、
  `make build` 等）。コマンドで検証できない基準は「何を読めば確認できるか」を明記
- **不変条件**: 途中で壊してはいけないもの（「他のテストを変更しない」等）

基準がユーザー指示から一意に導けない場合は `AskUserQuestion` で確認する。
自分で勝手に基準を緩めない。

## Phase 2: verifier 起動

`Agent` ツールで `subagent_type: "verifier"` を **名前付きで** 起動する
（例: `name: "verifier-<task-slug>"`。名前付きにするのは Phase 3 の再検証で
同一 agent を resume して prompt cache と失敗履歴を引き継ぐため）。

brief に必ず含めるもの（verifier は transcript を見られない）:

1. タスクの原文（ユーザーが何を頼んだか）
2. Phase 1 の受入基準
3. 変更されたファイル一覧（`git diff --stat` の結果 or 変更パス列挙）
4. 検証コマンドと実行時の前提（作業ディレクトリ、env 等）
5. executor の主張は**書かない**か、書くなら「主張であって証拠ではない」と明記

## Phase 3: 判定処理とループ

- **PASS** → verdict の要点（基準ごとの証拠）をユーザーへの応答に転記して終了。
  *Out of scope observations* があれば併せて報告する（勝手に直さない）。
- **FAIL** → verifier の修正指示を適用する（自分で直すか、実装を担った
  sub-agent に `SendMessage` で差し戻す）。適用後、**同じ verifier** に
  `SendMessage` で「fixes applied, re-verify」と変更点を送って再判定させる。
  新しい verifier を spawn し直さない。
- **ループ上限: 3 ラウンド。** 3 回 FAIL したら止めて、残っている失敗と
  verifier の見解をユーザーに報告し判断を仰ぐ。無限に回さない。

## /goal 連携

長時間の自律作業に使う場合、/goal の evaluator（small fast model・tool なし・
transcript のみ）が verifier の判定を読めるように、**verdict を毎回テキストとして
transcript に表出させる**こと。goal 条件のテンプレート:

```
/goal <作業内容>。完了条件: verifier agent が全受入基準に PASS を返し、
その verdict が会話に表示されていること。または 20 ターンで停止。
```

## コスト規律

- 検証対象が小さい（1 ファイル・自明な diff）なら、このループは調整コストの
  ほうが高い。built-in の `/verify` / `/code-review` で自己検証して済ませる。
- verifier は判定のみに使う。修正実装まで verifier にやらせない
  （frontier トークンを implementation に燃やさない）。
- harness 全体の設計判断（そもそも委譲すべきか等）は
  `cost-effective-harness` skill を参照。
