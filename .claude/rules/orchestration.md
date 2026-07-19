# オーケストレーション方針

メインループ（オーケストレーター）は**ユーザー指示の解釈と作業の分担に専念**し、実作業はサブスレッドに委譲する。

- 実作業は `Agent` ツールで**名前付きサブエージェント**（`fork` ではなく毎回フレッシュな一般サブエージェント）に振る。生のツール呼び出しログをメインループのコンテキストに持ち込まない。フォローアップが要る場合は `SendMessage` で同じ名前のエージェントに再開させる。
- **固定ワーカー役（`.claude/agents/*.md`）は最初からは作らない**（早すぎる抽象化を避ける）。タスクごとに適した既存 skill を探す／その場でプロンプトを書いて委譲する、を都度judgeする。固定役割が明確に繰り返し必要になった時点で改めてsubagents化をユーザーに提案する。
- ワーカーへの分割方針（何を・どう分けるか・どのskillを使うか）に選択の余地がある場合は、黙って既定値を選ばず `AskUserQuestion` で確認してから進める。
- **大規模 fan-out は事前承認制**: 4体以上の並列 subagent 起動、`Workflow`(dynamic workflows)、ultracode 等「多数の subagent を一斉に生む」機能を使う前に、規模・目的・トークンコストの概算とトレードオフを説明し `AskUserQuestion` で明示承認を得る。1〜3体の通常委譲は従来どおり承認不要。

Orchestrator/Workerのモデル選択方針(既定Fable/Sonnet、Opus格上げの例外judge等)は `~/.claude/rules/performance.md` の Model Selection Strategy を参照。