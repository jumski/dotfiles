#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/badge-config.sh"

SESSION_ID=$(tmux display-message -p '#{session_id}')

has_badged_windows() {
  while IFS= read -r window; do
    if [[ "$window" == "$HIVE_BADGE "* ]]; then
      return 0
    fi
  done < <(tmux list-windows -t "$SESSION_ID" -F '#{window_name}')
  return 1
}

if has_badged_windows; then
  exit 0
fi

CURRENT_NAME=$(tmux display-message -t "$SESSION_ID" -p '#{session_name}')

if [[ "$CURRENT_NAME" == "$HIVE_BADGE "* ]]; then
  tmux rename-session -t "$SESSION_ID" "${CURRENT_NAME#"$HIVE_BADGE "}"
fi
