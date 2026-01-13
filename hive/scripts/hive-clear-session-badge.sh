#!/bin/bash
# hive-clear-session-badge.sh - Clear session badge when no windows have badges
#
# Usage: ./hive-clear-session-badge.sh <session_id>
#   session_id: tmux session ID (e.g., "$123")
#
# Test: ./hive-clear-session-badge.sh $65
#       Should remove "󰭻]" from session name if no windows have @hive_window_badge set
#
# Design: Stores original name in tmux option before clearing, restores it when clearing.
# This handles user manual renames gracefully - uses the name at time of clearing, not stale saved name.

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <session_id>" >&2
    exit 1
fi

SESSION_ID="$1"

# Get current session name using session ID
SESSION_NAME=$(tmux display-message -t "$SESSION_ID" -p '#S' 2>/dev/null)
if [ -z "$SESSION_NAME" ]; then
    echo "ERROR: Could not get session name for $SESSION_ID" >&2
    exit 1
fi

# Store current session name as original BEFORE clearing (for restoration)
# This handles user manual renames - we restore to name as it was when badge was added,
# not to some stale saved name.
# Only store if original name option doesn't already exist (avoid overwriting user changes)
ORIGINAL_NAME=$(tmux show-options -t "$SESSION_ID" -qv @hive_session_original_name 2>/dev/null || echo "")
if [ -z "$ORIGINAL_NAME" ]; then
    tmux set-option -t "$SESSION_ID" @hive_session_original_name "$SESSION_NAME"
fi

# Check if session has badge (using name with possible emoji prefix)
if [[ ! "$SESSION_NAME" =~ ^\[\*\]\ (.*)$ ]]; then
    # Session has badge, check if any windows still need it
    for window_id in $(tmux list-windows -t "$SESSION_ID" -F '#{window_id}' 2>/dev/null); do
        badge=$(tmux show-options -w -t "$window_id" -qv @hive_window_badge 2>/dev/null || echo "")
        if [ -n "$badge" ]; then
            # Window still has badge, keep session badge
            exit 0
        fi
    done
    
    # Clear session badge - restore to original name (stored in tmux option)
    CLEAN_NAME="${BASH_REMATCH[1]}"
    tmux rename-session -t "$SESSION_ID" "$CLEAN_NAME"
    tmux set-option -t "$SESSION_ID" @hive_session_badge ""
else
    # Session doesn't have badge (already clean), ensure tmux option is cleared
    tmux set-option -t "$SESSION_ID" @hive_session_badge ""
    # Also clear original name option (stale)
    tmux set-option -t "$SESSION_ID" -u @hive_session_original_name
fi

# Check if any window in this session still has a badge
for window_id in $(tmux list-windows -t "$SESSION_ID" -F '#{window_id}' 2>/dev/null); do
    badge=$(tmux show-options -w -t "$window_id" -qv @hive_window_badge 2>/dev/null || echo "")
    if [ -n "$badge" ]; then
        # Window still has badge, keep session badge
        exit 0
    fi
done

# No windows have badges, clear session badge
CLEAN_NAME="${BASH_REMATCH[1]}"
tmux rename-session -t "$SESSION_ID" "$CLEAN_NAME"
tmux set-option -t "$SESSION_ID" @hive_session_badge ""
