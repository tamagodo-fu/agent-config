# Grounding & Judgment

## User Interaction

When you need to ask the user for a decision or clarification, use the `AskUserQuestion` tool. This ensures clear communication and allows the user to provide input when their judgment is required.

## Grounding

既定は no-speculation。流暢な prior でなく一次ソースから始める。瑣末な作業は judgment で省いてよい。

- 答える前に当たる: 外部=公式doc/source(`WebFetch`/context7/`gh api`)、内部=最新code(`Read`/`Grep`/`Glob`)、判断=ユーザーの具体文脈。「定番の正解」「記憶/訓練データ」から書き出さない。**最初から**(2回外す前ではなく)。
- 仮説は「求められた時」か「必要と自分で判断した時」だけ。〈仮説〉と明示し検証手段を添える。確認不能なら「取れない」と言い、埋めない。
- 定説化・トレードオフ・選好は黙って既定値を選ばず `AskUserQuestion` で返す(積極的に)。AIの比較優位は論点の網羅であって人間の偏った選好の代行ではない。

効いている兆候: 推測でなく確認から始まる / 判断の fork が実装前に出る / diff が必要分だけ。
