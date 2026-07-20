---
name: morning-routine
description: 朝のルーティン - ニュースレターサマリー、昨日の進捗、今日のタスク
user_invocable: true
triggers:
  - /morning-routine
  - /gm
  - 朝のルーティン
  - おはよう
  - good morning
---

# 朝のルーティン（Morning Routine）

一日の始まりに必要な情報を自動で収集・整理するアシスタント。

## 実行内容

1. **ニュースレターサマリー** - Gmailから過去24時間の重要なニュースレターを取得し、要点を日本語でまとめる
2. **昨日の進捗** - Linearから昨日完了したタスクを取得し、成果を振り返る
3. **今日のフォーカス** - Linearから今日取り組むべき優先タスクを3つ提案

> **rewildプロジェクトで作業中の場合のみ**、追加で `review-rewild` skill（`/review-rewild`）を提案する。プロジェクト固有のため本skillでは実行しない。アカウント横断の日次レビューを生成し、`accounts/<name>/analytics/reviews/YYYY-MM-DD.md` に書き出す。

---

## Step 1: ニュースレターサマリー

**参照コマンド**: `/Users/takuya.toyama/Areas/Obsidian/.claude/commands/newsletter-research.md`

### ワークフロー

`newsletter-research` コマンドのワークフローを簡略化して実行:

1. **ニュースレターURLを取得**:
   - `/Users/takuya.toyama/Areas/Obsidian/Sources/Newsletters/newsletter_links.md` から読み込む
   - 含まれるソース: Stratechery, Simon Willison, A Smart Bear, Vitalik Buterin, Hugging Face Papers, The Decoder, The Batch, Lilian Weng, Alex Finn AI, Import AI

2. **WebFetch で最新コンテンツを取得**:
   - 各ニュースレターの最新投稿をフェッチ
   - 主要なトピックとアングルを抽出

3. **トレンド分析**:
   - 複数のニュースレターで共通するトピックを特定
   - 時間的に重要なアングルを抽出
   - コンテンツギャップと機会を分析

### 出力形式

```markdown
## 📰 ニュースレターサマリー

### トレンドトピック
- 📌 [複数のニュースレターで見つかったトピック]
- 📌 [共通テーマ]

### 時間的に重要なアングル
- ⏰ [緊急または時宜を得たトピック]

### 各ニュースレター要約
#### [ニュースレター名]
- [重要ポイント1]
- [重要ポイント2]

#### [ニュースレター名]
- [重要ポイント1]
- [重要ポイント2]

*取得できなかった場合: 「ニュースレターを取得できませんでした」*
```

---

## Step 2: 昨日の進捗（Linear）

### ツール読み込み

```
ToolSearch: query="linear"
```

### 進捗取得

Linear MCPツールで以下を実行:

1. `list_issues` で昨日完了したタスクを取得:
   - フィルター: completedAt が昨日以降
   - または: updatedAt が昨日以降 かつ state が "Done"

2. 進行中のタスクも取得して、進捗を確認

### 出力形式

```markdown
## ✅ 昨日の進捗

### 完了したタスク (N件)
- ✅ **[タスク名]** ([プロジェクト名])
- ✅ **[タスク名]** ([プロジェクト名])

### 主な成果
- [成果1の簡潔なサマリー]
- [成果2の簡潔なサマリー]

*完了タスクがなかった場合: 「昨日完了したタスクはありませんでした」*
```

---

## Step 3: 今日のフォーカス（Linear）

### タスク取得

Linear MCPツールで以下を実行:

1. `list_issues` で自分にアサインされたタスクを取得:
   - state: "In Progress", "Todo"
   - 優先度順（Urgent > High > Medium > Low）

2. 締め切りが近いものを優先

### フォーカス選定ロジック

1. **P0（最優先）**:
   - 優先度が Urgent または High
   - 締め切りが今日または過ぎているもの
   - 最大1件

2. **P1（次点）**:
   - In Progress のタスク
   - 締め切りが今週中のもの
   - 最大2件

3. **ブロック中**:
   - stateがBlockedのもの
   - 次のアクションを提案

### 出力形式

```markdown
## 🎯 今日のフォーカス

### 最優先 🔴
1. **[タスク名]** - [プロジェクト名]
   - 理由: [優先度/締め切り/依存関係]
   - 見積もり: [時間があれば]

### 次点 🟡
2. **[タスク名]** - [プロジェクト名]
3. **[タスク名]** - [プロジェクト名]

### ブロック中 ⚠️
- **[タスク名]**: [ブロック理由]
  → 次のアクション: [提案]

### 残りのバックログ
- [N件のタスクが待機中]
```

---

## 最終出力フォーマット

すべてのステップを統合して以下の形式で出力:

```markdown
# 🌅 Good Morning! - YYYY年MM月DD日（曜日）

---

[Step 1: ニュースレターサマリー]

---

[Step 2: 昨日の進捗]

---

[Step 3: 今日のフォーカス]

---

💡 **今日の一言**: [状況に応じたモチベーションメッセージ]

*Generated at HH:MM JST*
```

---

## エラーハンドリング

| エラー | 対応 |
|--------|------|
| Gmail接続失敗 | スキップして「ニュースレター取得をスキップしました」と表示 |
| Linear接続失敗 | スキップして「Linear接続をスキップしました」と表示 |
| タスクが0件 | 「タスクがありません。バックログを確認してください」と表示 |

---

## カスタマイズオプション

ユーザーが追加指定できるオプション:

- `--newsletter-only`: ニュースレターサマリーのみ
- `--tasks-only`: Linear進捗とタスクのみ
- `--quick`: 簡潔版（各セクション最大3行）

---

## 関連ツール

- **WebFetch**: ニュースレターコンテンツ取得
- **Linear MCP**: `list_issues`, `list_projects`, `get_issue`

## 関連コマンド・スキル

- **newsletter-research** (`/Users/takuya.toyama/Areas/Obsidian/.claude/commands/newsletter-research.md`): ニュースレターのフル分析とドラフト作成
- `linear-planning`: Linear計画の詳細設定
