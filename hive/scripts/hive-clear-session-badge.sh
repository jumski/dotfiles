#!/bin/bash
# hive-clear-session-badge.sh - Clear session badge when no windows have badges
#
# Usage: ./hive-clear-session-badge.sh <session_id>
#   session_id: tmux session ID (e.g., "$123")
#
# Test: ./hive-clear-session-badge.sh \$123
#       Should remove "[*]" from session name if no windows have @hive_window_badge set

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

# Check if session has badge
if [[ ! "$SESSION_NAME" =~ ^\[\*\]\ (.*)$ ]]; then
    exit 0
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
