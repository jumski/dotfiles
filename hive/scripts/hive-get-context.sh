#!/bin/bash
# hive-get-context.sh - Get tmux context for the pane where this script runs
# Uses $TMUX_PANE env var (set by tmux for each pane) to get correct context
#
# Usage: ./hive-get-context.sh
# Output: session_name:window_index:pane_id:session_id:window_id
#         (e.g., "pgflow:1:%123:$456:@789")
#
# Test: Run from any tmux pane, switch windows, run again - should show original pane's context

set -euo pipefail

if [ -z "${TMUX:-}" ]; then
    echo "ERROR: Not in tmux" >&2
    exit 1
fi

if [ -z "${TMUX_PANE:-}" ]; then
    echo "ERROR: TMUX_PANE not set" >&2
    exit 1
fi

# Use TMUX_PANE to get the context of THIS pane (not the currently focused one)
SESSION_NAME=$(tmux display-message -t "$TMUX_PANE" -p '#S')
WINDOW_INDEX=$(tmux display-message -t "$TMUX_PANE" -p '#{window_index}')
PANE_ID="$TMUX_PANE"
SESSION_ID=$(tmux display-message -t "$TMUX_PANE" -p '#{session_id}')
WINDOW_ID=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}')

echo "$SESSION_NAME:$WINDOW_INDEX:$PANE_ID:$SESSION_ID:$WINDOW_ID"
