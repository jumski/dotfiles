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

CURRENT_SESSION_ID=$(tmux display-message -p '#{session_id}' 2>/dev/null || echo "")
CURRENT_WINDOW_ID=$(tmux display-message -p '#{window_id}' 2>/dev/null || echo "")

# Check if terminal window has OS-level focus
TERMINAL_FOCUSED=$(tmux display-message -p '#{client_flags}' 2>/dev/null | grep -q 'focused' && echo "yes" || echo "no")

if [ "$TARGET_SESSION_ID" = "$CURRENT_SESSION_ID" ] && \
   [ "$TARGET_WINDOW_ID" = "$CURRENT_WINDOW_ID" ] && \
   [ "$TERMINAL_FOCUSED" = "yes" ]; then
    exit 1
else
    exit 0
fi
