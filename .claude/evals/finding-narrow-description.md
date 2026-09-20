# 所見: description から議事録を外す提案

**この差分は未適用。** eval の対象プラグインは測定中 READ-ONLY のため、
`skills/natural-japanese/SKILL.md` には手を入れていない。適用は別途。

## 根拠

`06-neg-minutes`（文字起こし→議事録化）で natural-japanese が発火する。

| 実行 | 発火 |
|---|---|
| パイロット 1〜5回目 | 5/5 |
| 本番 runs:3 | 3/3 |

**通算 8/8、例外なし。** 議事録の中身自体は with/without とも合格しており
（`minutes-structured` 3/3）、スキルが仕事を壊しているわけではない。
問題は呼ばれるべきでない場面で呼ばれること。

実トラフィック調査では、history.jsonl に「議事録」関連プロンプトが84件あり、
サンプルした範囲で実際に処理していたのは `call-summary` skill だった。
natural-japanese が議事録化に使われた実例は0件。
つまり description の記述と実運用が食い違っている。

## 差分案

`skills/natural-japanese/SKILL.md` の frontmatter `description:`

```diff
-仕事の日本語文書を読みやすくわかりやすく書く・直すためのスキル。議事録（文字起こしからの議事録化を含む）、調査レポート・分析レポート、
+仕事の日本語文書を読みやすくわかりやすく書く・直すためのスキル。調査レポート・分析レポート、
```

末尾の対象外を述べている箇所に、次を追記する。

```diff
-技術文書の章構成やMarkdownフォーマットの整形自体（一文一行化・引用ブロック・脚注記法など）は対象外
+技術文書の章構成やMarkdownフォーマットの整形自体（一文一行化・引用ブロック・脚注記法など）、
+および文字起こしから議事録を作る作業自体（call-summary skill の領域）は対象外
```

**既にある議事録ドラフトの日本語を直す依頼は引き続き対象**であり、
これが落ちないことを確認する必要がある。

## 適用後に確認すること

1. `claude plugin eval . --ablation with-without --judge-model sonnet --allow-tools Write Edit --case '06-neg-minutes'`
   を回し、`skill-must-not-fire` が 3/3 で通ること。
2. 発火側のケース（`01`〜`05`）が全て従来どおり発火すること
   （`skill-fired` が各 3/3）。description を削ったことで
   本来の守備範囲まで落ちていないかの確認。
3. 「この議事録ドラフトの日本語を直して」という依頼で発火するかを
   新規ケースとして追加する。今回の suite には無い。

## 留保

eval サンドボックスには競合する `call-summary` skill が存在しない。
この結果が示すのは「競合が居ない状態で natural-japanese が議事録を掴みにいくか」
であって、実環境での誤発火率ではない。実環境では call-summary が勝っている可能性がある。
description を狭める判断は、この留保を承知の上で行うこと。
