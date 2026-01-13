#!/bin/bash
# hive-get-context.sh - Get tmux context for the pane where this script runs
# Uses $TMUX_PANE env var (set by tmux for each pane) to get correct context
#
# Usage: ./hive-get-context.sh
# Output: session:window:pane_id (e.g., "pgflow:1:%123")
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
SESSION=$(tmux display-message -t "$TMUX_PANE" -p '#S')
WINDOW=$(tmux display-message -t "$TMUX_PANE" -p '#{window_index}')
PANE_ID="$TMUX_PANE"

echo "$SESSION:$WINDOW:$PANE_ID"
