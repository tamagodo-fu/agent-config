---
name: cost-effective-harness
description: >
  Design guidance for cost-effective multi-agent harnesses: when to spend
  frontier intelligence (Fable) as orchestrator / advisor / verifier vs. let
  cheap executors absorb tokens. Read BEFORE designing a Workflow script,
  a multi-agent fan-out, or any delegation structure — and when deciding
  whether to delegate at all. Covers task-shape analysis, delegation
  heuristics, coordination cost, and prompt caching.
---

# cost-effective-harness

multi-agent harness（Workflow スクリプト・Agent fan-out・executor/verifier ループ）を
設計する前に読む判断基準。frontier モデル（Fable）の知能をタスクのどこに
配置するかを、以下の 4 観点で決める。

[Source: RLanceMartin "Cost effective harnesses with Fable" (2026-07-11),
https://x.com/RLanceMartin/status/2075641284635799865]

## 1. Task shape を見る

タスクのトークン列のどこに知能が要るかは非対称。形に応じて Fable の役割を選ぶ:

| 判断の分布 | パターン | このマシンでの実装 |
|---|---|---|
| 事前に集中（計画が命） | Fable **orchestrator** が計画し安価な worker に委譲 | メインループ(Fable) + `Agent`/`Workflow` で Sonnet worker |
| 途中に散在（結果を見て方針転換が要る） | 安価な executor + Fable **advisor** をチェックポイントに配置 | `advisor` agent。固定チェックポイント（例: N 実験ごと）で呼ぶ |
| 事後に集中（成果物の合否判定） | 安価な executor + Fable **verifier** | `verifier` agent / `fable-verify` skill |

経験則: 探索的なタスク（結果が次の一手を変える）は事前計画の価値が低く、
**途中の再ランク付け**に価値がある。Parameter Golf の実測では、Fable の初期計画は
効かず（初期ランキングは結果と逆相関）、途中チェックポイントの steering が
効いた（Fable solo の改善の ~90% を ~34% のコストで達成）。

## 2. 委譲ヒューリスティクス（モデル選定）

`~/.claude/rules/performance.md` の Model Selection Strategy に従う:
orchestrator = Fable、worker 既定 = Sonnet、深い推論が要るタスク単位でのみ
opus 格上げ、Haiku は本当に単純な作業のみ。

追加の prior: 判定・審美眼が要る stage（judge, verify, rank）ほど上位モデル、
トークン量が支配的な stage（読む・書く・探す）ほど下位モデルに寄せる。

## 3. 調整コストを見積もる（委譲しない判断）

委譲には handoff ごとの固定コストがある:

- **Boundary duplication**: 境界を越えるトークンは最低 2 回課金される
  （lead が brief を書き worker が読む / worker が report を書き lead が読む）
- **Fan-out overlap**: worker 同士は通信しないので調査が部分重複する

**worker が吸収するトークン量が調整コストを上回るときだけ委譲する。**
実測例（BrowseComp）: 1 問 ~0.4M トークン読みの小タスクでは委譲が 60% の
コスト増で性能向上なし。~31M トークン読みの大タスクでは orchestration が
96% のスコアを 46% のコストで達成。

判定チェック（設計前に自問する）:
- [ ] worker 1 体が吸収するトークンは brief+report の往復より十分大きいか
- [ ] Fable はトークン効率が良い（少ないトークンで解く）ので、
      「$/token が安い」だけを理由に委譲していないか
- [ ] fan-out する worker 間で調査が重複しない分割になっているか

小さければ **自分でやる**。委譲しないのも設計判断。

## 4. Prompt caching を守る

- **同じ worker に呼び出しをルーティングして cache を蓄積させる。**
  リクエストごとに fresh spawn すると context write を毎回払い直す。
  Claude Code では: 名前付き `Agent` を spawn し、続きは `SendMessage` で
  同一 agent を resume する（`fable-verify` skill の再検証がこの形）。
- cache TTL は 5 分。ループの待ち時間設計もこれを跨がないように
  （跨ぐなら 1 回の cache miss で長く待つ方に倒す）。
- cache hit 率が低いと、$/token の安い worker を使うコスト利点が
  相殺されることがある。

## Anti-patterns

- 全 stage を一律 Fable で fan-out する（知能の非対称性を無視）
- 逆に、判定 stage まで Haiku/Sonnet に落として合否がブレる
- 1 往復で済む小タスクを「並列化のため」に分割し、boundary duplication で
  かえって高くつく
- 再検証・追質問のたびに fresh spawn して cache を捨てる
- 事前計画に frontier トークンを全額投入する（探索的タスクでは途中の
  advisor チェックポイントに分散させる方が効く）
