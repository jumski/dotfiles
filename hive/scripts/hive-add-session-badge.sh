#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/badge-config.sh"

SESSION_ID="${1:-}"

if [ -z "$SESSION_ID" ]; then
  SESSION_ID=$(tmux display-message -p '#{session_id}')
fi

CURRENT_NAME=$(tmux display-message -t "$SESSION_ID" -p '#{session_name}')

if [[ "$CURRENT_NAME" != "$HIVE_BADGE "* ]]; then
  tmux rename-session -t "$SESSION_ID" "$HIVE_BADGE $CURRENT_NAME"
fi
