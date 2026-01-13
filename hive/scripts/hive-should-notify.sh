#!/bin/bash
# hive-should-notify.sh - Check if notification badge should be shown
#
# Usage: ./hive-should-notify.sh <target_session_id> <target_window_id>
# Returns: 0 if should notify (target not focused), 1 if should skip (target is focused)
#
# Test: 
#   1. Run from window @123: ./hive-should-notify.sh \$456 @123  → exits 1 (skip, you're viewing it)
#   2. Run from window @123: ./hive-should-notify.sh \$456 @789  → exits 0 (notify, different window)

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <target_session_id> <target_window_id>" >&2
    exit 2
fi

TARGET_SESSION_ID="$1"
TARGET_WINDOW_ID="$2"

if [ -z "${TMUX:-}" ]; then
    echo "NOTIFY: Not in tmux, should use notify-send"
    exit 0
fi

# Get currently focused session/window IDs
CURRENT_SESSION_ID=$(tmux display-message -p '#{session_id}' 2>/dev/null || echo "")
CURRENT_WINDOW_ID=$(tmux display-message -p '#{window_id}' 2>/dev/null || echo "")

echo "Target:  $TARGET_SESSION_ID:$TARGET_WINDOW_ID"
echo "Current: $CURRENT_SESSION_ID:$CURRENT_WINDOW_ID"

if [ "$TARGET_SESSION_ID" = "$CURRENT_SESSION_ID" ] && [ "$TARGET_WINDOW_ID" = "$CURRENT_WINDOW_ID" ]; then
    echo "SKIP: Target window is currently focused"
    exit 1
else
    echo "NOTIFY: Target window is NOT focused"
    exit 0
fi
