#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/badge-config.sh"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <window_id>" >&2
  exit 1
fi

WINDOW_ID="$1"

CURRENT_NAME=$(tmux display-message -t "$WINDOW_ID" -p '#{window_name}')

if [[ "$CURRENT_NAME" != "$HIVE_BADGE "* ]]; then
  tmux rename-window -t "$WINDOW_ID" "$HIVE_BADGE $CURRENT_NAME"
fi
