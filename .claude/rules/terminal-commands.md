# Terminal Commands Delivery Rule

## ABSOLUTE RULE

When asking the user to copy-paste shell commands (or any code that they need to run themselves), **NEVER paste the commands directly in the TUI chat output**. Always:

1. Write the commands to a **project-local temp file**: `<project-root>/.claude/tmp/<descriptive-name>.sh` (or `.txt`)
   - Create `.claude/tmp/` if it doesn't exist
   - Ensure `.claude/` (or at least `.claude/tmp/`) is gitignored
2. Use the `open` command to open the file in their default text editor
3. Tell the user to copy from that file

Use `/tmp/` only as last resort (e.g., when there is no clear project root).

## Why

Direct chat-paste introduces copy issues:
- Wrap-around characters / line breaks corrupt commands
- Markdown formatting artifacts (backticks, indentation)
- User has to manually edit before paste, breaking flow

## Pattern to follow

```bash
mkdir -p <project-root>/.claude/tmp
cat > <project-root>/.claude/tmp/<task-name>.sh <<'EOF'
# <comment explaining what this does>
COMMAND_1
COMMAND_2
EOF
# .gitignore に .claude/tmp/ が無ければ追加
# ⚠️ macOS の `open <file>.sh` は実行を試みて permission denied で失敗するので NG
# テキストとして開くために以下のいずれかを使う:
cursor <project-root>/.claude/tmp/<task-name>.sh    # Cursor / VS Code
# or
open -t <project-root>/.claude/tmp/<task-name>.sh   # TextEdit (-t = テキスト強制)
```

代替: ファイル名を `<task-name>.txt` で保存すれば `open` でもテキストエディタで開く。

Then in chat: tell the user the file is open, what each section does, and any values they need to fill in (placeholders like `PASTE_HERE`).

## When to apply (NARROW SCOPE)

**Only** when the user genuinely cannot delegate execution to Claude. Concretely:

1. **Interactive credential input required**: `gcloud auth login`, `ssh-add`, `aws sso login`, keychain unlock prompt, browser-driven OAuth callback, 2FA code entry.
2. **Sudo password prompt** that Claude's shell cannot satisfy.
3. **Web UI actions**: "open this URL and click X" type instructions (paired with shell commands the user runs around them).
4. **User explicitly says** "I'll run it myself" / "give me the command" / revokes permission for that class of operation in this session.
5. **Long multi-step interactive scripts** where individual line approval matters (e.g. migration with branch points).

## When NOT to apply (DEFAULT: just execute)

- 単一ファイルの `rm` (token残骸、自分が作った backup/tmp/log の掃除) — execute directly
- `mv` / `cp` / `mkdir` / `touch` 等の非破壊系 — execute directly
- パッケージ install (`npm i`, `pip install`, `uv sync` 等) — execute (preflight hook が危険なら止める)
- そのセッションで既に同種の操作を自分で実行できているなら、後続も自分で実行する

権限制御は **permission prompt 側** に任せる。ユーザーは危なければそこで拒否できる。
事前に txt 化して「念のため確認お願いします」する必要は無い。

## Hard line — txt-handoff にする破壊操作

以下は破壊規模が大きく事故時の復旧コストも大きいため、**permission prompt 任せにせず明示的に txt 経由**で渡す:

- `rm -rf` でディレクトリ丸ごと削除
- `rm -rf` でワイルドカード(`~/.foo/*` 等)で複数ファイル一括削除
- `git reset --hard` / `git clean -fd` / `git push --force` 等の git destructive
- DB drop / truncate
- `mise uninstall` 等のツールチェイン丸ごと削除

要は「うっかり実行すると数時間〜数日分の作業が飛ぶ」ものは事前確認。
単発ファイルの掃除 (1ファイル `rm`、`.bak.*` パターンでも対象が数個まで) は self-execute。

## Exception

If the command is a single short word (under ~30 chars) and contains no special chars, inline chat is fine.

## How to honor revoked permissions

If the user says "I haven't given you permission for X" or similar (e.g. "rm系は権限ない"), respect that **for the remainder of the session only**. Do NOT generalize it into the rule above for future sessions, and do NOT apply it to operations beyond what was actually revoked. Capture the revocation as a session-scoped fact.
