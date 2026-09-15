# Terminal Commands Delivery Rule

ユーザー自身が実行する必要があるコマンド(interactive credential 入力・sudo password・Web UI 手順・ユーザーが「自分で実行する」と言った場合等の narrow scope のみ)は、TUI に直接貼らず `<project-root>/.claude/tmp/<task-name>.sh` に書いて渡す。開き方: **HERDR_ENV=1 なら herdr pane を split して `druk <path>` で表示**(`open -t` の外部エディタは使わない)。herdr外のみ `open`(テキストとして)。`.claude/tmp/` が無ければ作り、`.claude/` は gitignore する。

それ以外は既定で self-execute(権限制御は permission prompt 任せ)。事前に txt 化して「念のため確認」する必要は無い。

適用範囲の詳細判定(narrow scope の具体列挙・self-execute する非破壊系・Exception)と txt 書き出しの具体手順・herdr 環境での `herdr-edit` の使い方: `~/.claude/docs/terminal-commands-details.md`

## Hard line — txt-handoff にする破壊操作

以下は破壊規模が大きく事故時の復旧コストも大きいため、**permission prompt 任せにせず明示的に txt 経由**で渡す:

- `rm -rf` でディレクトリ丸ごと削除
- `rm -rf` でワイルドカード(`~/.foo/*` 等)で複数ファイル一括削除
- `git reset --hard` / `git clean -fd` / `git push --force` 等の git destructive
- DB drop / truncate
- `mise uninstall` 等のツールチェイン丸ごと削除

要は「うっかり実行すると数時間〜数日分の作業が飛ぶ」ものは事前確認。
単発ファイルの掃除 (1ファイル `rm`、`.bak.*` パターンでも対象が数個まで) は self-execute。

## How to honor revoked permissions

If the user says "I haven't given you permission for X" or similar (e.g. "rm系は権限ない"), respect that **for the remainder of the session only**. Do NOT generalize it into the rule above for future sessions, and do NOT apply it to operations beyond what was actually revoked. Capture the revocation as a session-scoped fact.
