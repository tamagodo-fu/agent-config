# Terminal Commands Delivery — 詳細パターン

`~/.claude/rules/terminal-commands.md` から移設した実装詳細。txt-handoff を実際に書くときの具体手順。

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

## Opening files for the user to look at (herdr environments)

When `HERDR_ENV=1` (running inside herdr) and you want to show the user a file rather than have them run a command, use `herdr-edit <file> [line]` instead of `cursor <file>`. It opens the file in a Neovim instance in a split pane of the same herdr tab, reusing an existing editor pane if one is already running (so repeated calls don't spawn more panes). Outside herdr (`HERDR_ENV` unset), `herdr-edit` itself falls back to `cursor <file>`, so it's safe to use unconditionally once available. See `~/.local/bin/herdr-edit` (comments explain the split+swap mechanics used to place the editor pane above the caller) and `~/.config/nvim/lua/herdr.lua` (keymaps for sending file refs/messages from Neovim back to the agent pane).

## 適用範囲の詳細判定(rules から移設)

### Why

Direct chat-paste introduces copy issues:
- Wrap-around characters / line breaks corrupt commands
- Markdown formatting artifacts (backticks, indentation)
- User has to manually edit before paste, breaking flow

### When to apply (NARROW SCOPE)

**Only** when the user genuinely cannot delegate execution to Claude. Concretely:

1. **Interactive credential input required**: `gcloud auth login`, `ssh-add`, `aws sso login`, keychain unlock prompt, browser-driven OAuth callback, 2FA code entry.
2. **Sudo password prompt** that Claude's shell cannot satisfy.
3. **Web UI actions**: "open this URL and click X" type instructions (paired with shell commands the user runs around them).
4. **User explicitly says** "I'll run it myself" / "give me the command" / revokes permission for that class of operation in this session.
5. **Long multi-step interactive scripts** where individual line approval matters (e.g. migration with branch points).

### When NOT to apply (DEFAULT: just execute)

- 単一ファイルの `rm` (token残骸、自分が作った backup/tmp/log の掃除) — execute directly
- `mv` / `cp` / `mkdir` / `touch` 等の非破壊系 — execute directly
- パッケージ install (`npm i`, `pip install`, `uv sync` 等) — execute (preflight hook が危険なら止める)
- そのセッションで既に同種の操作を自分で実行できているなら、後続も自分で実行する

権限制御は **permission prompt 側** に任せる。ユーザーは危なければそこで拒否できる。
事前に txt 化して「念のため確認お願いします」する必要は無い。

### Exception

If the command is a single short word (under ~30 chars) and contains no special chars, inline chat is fine.
