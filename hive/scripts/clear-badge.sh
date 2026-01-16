#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/badge-config.sh"

WINDOW_ID="${1:-$TMUX_PANE}"

if [ -z "$WINDOW_ID" ]; then
  echo "Usage: $0 <window_id>" >&2
  exit 1
fi

CURRENT_NAME=$(tmux display-message -t "$WINDOW_ID" -p '#{window_name}')

if [[ "$CURRENT_NAME" == "$HIVE_BADGE "* ]]; then
  tmux rename-window -t "$WINDOW_ID" "${CURRENT_NAME#"$HIVE_BADGE "}"
fi

"$(dirname "$0")/hive-clear-session-badge.sh"
