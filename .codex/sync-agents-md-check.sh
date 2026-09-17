#!/bin/sh
# ~/.codex/AGENTS.md は ~/.claude/CLAUDE.md + ~/.claude/rules/*.md + docs/ の policy 3本
# (orchestration / performance / terminal-commands-details) から手動で派生させたファイル。
# 自動生成ではなく、Claude固有のツール名を人手で言い換えて作っているため、このスクリプトは
# 「同期元が変わったかどうか」を検知するだけで、AGENTS.md自体は再生成しない。
#
# 使い方:
#   ~/.codex/sync-agents-md-check.sh          差分の有無を確認する
#   ~/.codex/sync-agents-md-check.sh --update  AGENTS.mdを手動更新した後、現在の同期元を新しい基準として記録する

set -eu

BASELINE_FILE="$HOME/.codex/.agents_md_source.sha256"
# docs/hooks.md は環境固有なので対象外。policy に関わる docs/ の 3本だけを含める。
SOURCE_FILES="$HOME/.claude/CLAUDE.md $HOME/.claude/rules/*.md \
$HOME/.claude/docs/orchestration.md \
$HOME/.claude/docs/performance.md \
$HOME/.claude/docs/terminal-commands-details.md"

hash_sources() {
  cat $SOURCE_FILES | shasum -a 256 | awk '{print $1}'
}

CURRENT_HASH="$(hash_sources)"

if [ "${1:-}" = "--update" ]; then
  echo "$CURRENT_HASH" > "$BASELINE_FILE"
  echo "基準ハッシュを更新しました: $CURRENT_HASH"
  exit 0
fi

if [ ! -f "$BASELINE_FILE" ]; then
  echo "基準ハッシュが未設定です。同期元と手動派生AGENTS.mdの確認・反映後に --update を実行してください。"
  exit 2
fi

BASELINE_HASH="$(cat "$BASELINE_FILE")"

if [ "$CURRENT_HASH" = "$BASELINE_HASH" ]; then
  echo "変更なし: 同期元は前回の確認記録から変わっていません（AGENTS.mdの内容一致は判定しません）"
  exit 0
else
  echo "要確認: 同期元のいずれかが前回の確認記録から変わっています（設定エラーや内容の矛盾を意味しません）"
  echo "同期元を確認し、必要な方針を ~/.codex/AGENTS.md に手動反映してから $0 --update を実行してください"
  exit 1
fi
