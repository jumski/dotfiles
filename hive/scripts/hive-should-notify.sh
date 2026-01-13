#!/bin/bash
# hive-should-notify.sh - Check if notification badge should be shown
#
# Usage: ./hive-should-notify.sh <target_session> <target_window>
# Returns: 0 if should notify (target not focused), 1 if should skip (target is focused)
#
# Test: 
#   1. Run from window 1: ./hive-should-notify.sh pgflow 1  → exits 1 (skip, you're viewing it)
#   2. Run from window 1: ./hive-should-notify.sh pgflow 2  → exits 0 (notify, different window)

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <target_session> <target_window>" >&2
    exit 2
fi

TARGET_SESSION="$1"
TARGET_WINDOW="$2"

if [ -z "${TMUX:-}" ]; then
    echo "NOTIFY: Not in tmux, should use notify-send"
    exit 0
fi

# Get currently focused session/window
CURRENT_SESSION=$(tmux display-message -p '#{client_session}' 2>/dev/null || echo "")
CURRENT_WINDOW=$(tmux display-message -p '#{window_index}' 2>/dev/null || echo "")

echo "Target:  $TARGET_SESSION:$TARGET_WINDOW"
echo "Current: $CURRENT_SESSION:$CURRENT_WINDOW"

if [ "$TARGET_SESSION" = "$CURRENT_SESSION" ] && [ "$TARGET_WINDOW" = "$CURRENT_WINDOW" ]; then
    echo "SKIP: Target window is currently focused"
    exit 1
else
    echo "NOTIFY: Target window is NOT focused"
    exit 0
fi
