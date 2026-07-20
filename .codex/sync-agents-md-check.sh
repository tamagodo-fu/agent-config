#!/bin/sh
# ~/.codex/AGENTS.md は ~/.claude/CLAUDE.md + ~/.claude/rules/*.md から手動で派生させたファイル。
# 自動生成ではなく、Claude固有のツール名を人手で言い換えて作っているため、このスクリプトは
# 「同期元が変わったかどうか」を検知するだけで、AGENTS.md自体は再生成しない。
#
# 使い方:
#   ~/.codex/sync-agents-md-check.sh          差分の有無を確認する
#   ~/.codex/sync-agents-md-check.sh --update  AGENTS.mdを手動更新した後、現在の同期元を新しい基準として記録する

set -eu

BASELINE_FILE="$HOME/.codex/.agents_md_source.sha256"
SOURCE_FILES="$HOME/.claude/CLAUDE.md $HOME/.claude/rules"/*.md

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
  echo "基準ハッシュが未設定です。AGENTS.md生成後に --update を実行してください。"
  exit 2
fi

BASELINE_HASH="$(cat "$BASELINE_FILE")"

if [ "$CURRENT_HASH" = "$BASELINE_HASH" ]; then
  echo "同期済み: ~/.claude/CLAUDE.md + rules/ に前回生成時からの変更なし"
  exit 0
else
  echo "要再生成: ~/.claude/CLAUDE.md または rules/ が前回のAGENTS.md生成時から変更されています"
  echo "~/.codex/AGENTS.md を確認し、必要な変更を反映した上で $0 --update を実行してください"
  exit 1
fi
