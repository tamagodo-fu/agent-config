---
max_turns: 10
timeout_seconds: 300
allowed_tools: [Skill]
model: opus
runs: 3
plugins: [../../skills/natural-japanese]
---
以下のMarkdownを、self-containedな単一HTMLファイルとして出力してください。日本語対応で読みやすく。返答の中にHTML全文を含めてください。

## 2026年度下期の重点施策

### 1. 在庫連携APIの刷新
現行APIはバッチ同期のため、在庫反映に最大30分の遅延がある。準リアルタイム化を目指す。

### 2. 料金体系の簡素化
現在7プランあるものを3プランに集約する。12月1日施行。

### 3. 解約導線の見直し
解約理由の取得率が低く、改善の手がかりが得られていない。
