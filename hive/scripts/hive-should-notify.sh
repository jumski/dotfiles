#!/bin/bash
set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <target_session_id> <target_window_id>" >&2
    exit 2
fi

TARGET_SESSION_ID="$1"
TARGET_WINDOW_ID="$2"

if [ -z "${TMUX:-}" ]; then
    exit 0
fi

CLIENT_SESSION_NAME=$(tmux display-message -p '#{client_session}' 2>/dev/null || echo "")
if [ -n "$CLIENT_SESSION_NAME" ]; then
    CURRENT_SESSION_ID=$(tmux display-message -t "$CLIENT_SESSION_NAME" -p '#{session_id}' 2>/dev/null || echo "")
    CURRENT_WINDOW_ID=$(tmux display-message -t "$CLIENT_SESSION_NAME" -p '#{window_id}' 2>/dev/null || echo "")
else
    CURRENT_SESSION_ID=""
    CURRENT_WINDOW_ID=""
fi

if [ "$TARGET_SESSION_ID" = "$CURRENT_SESSION_ID" ] && [ "$TARGET_WINDOW_ID" = "$CURRENT_WINDOW_ID" ]; then
    exit 1
else
    exit 0
fi
