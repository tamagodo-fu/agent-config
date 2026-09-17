---
paths:
  - "**/CLAUDE.md"
  - "**/.claude/rules/**"
  - "**/.claude/skills/**"
  - "**/.claude/docs/**"
  - "**/.claude/agents/**"
  - "**/.claude/settings.json"
  - "**/.claude/settings.local.json"
---

# Context Hygiene (Claude 5)

設定コンテキスト(CLAUDE.md / rules / skills)は「足す」より「痩せさせる」を既定にする。
Claude 5系は判断力が高く、過剰な明示ルールは矛盾指示を生んで判断を鈍らせる。

- **常時ロードは安全・判断の土台だけ**: grounding / security / 破壊操作ガード / memory規律のみ無条件ロード。手続き的・状況依存のルールは skill 化または paths: ゲートし、CLAUDE.md には発火トリガ1行だけ残す。
- **「明白なこと」を書かない**: ファイルシステムや repo を見れば分かることは書かない。
- **絶対命令(ALWAYS/NEVER)は highly important area に限定**: security・cloud spend・破壊操作以外は「既定は X、例外は判断」の形にする。
- **定期的に /doctor で棚卸し**: skills / CLAUDE.md を rightsize する。

## References — コード優先

Claude に文脈を渡すときは説明文より "code as reference" を優先する。
- 仕様は散文より、詳細なテストスイートや別コードベースの参照実装で渡す。
- デザインは説明やスクショより HTML モックアップで渡す方が結果が良い。
- 「良し悪しの選好」(例: 良い API 設計とは)は rubric 化し、verifier agent(/fable-verify)を必要に応じて使い、重要な判断や変更を検証する。

## 自作ツール/skill のインタフェース設計

使用例を並べるより、パラメータ名・enum・制約で望ましい挙動を表現する(例示は探索空間を狭める)。
