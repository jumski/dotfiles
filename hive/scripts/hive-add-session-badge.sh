#!/bin/bash
# hive-add-session-badge.sh - Add generic badge to tmux session name
#
# Usage: ./hive-add-session-badge.sh <session>
#   session: tmux session name (e.g., "pgflow")
#
# Test: ./hive-add-session-badge.sh pgflow
#       Should add "[*] pgflow" to session list

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <session>" >&2
    echo "Example: $0 pgflow" >&2
    exit 1
fi

SESSION="$1"

# Get current session name
SESSION_NAME=$(tmux display-message -t "$SESSION" -p '#S' 2>/dev/null)
if [ -z "$SESSION_NAME" ]; then
    echo "ERROR: Could not get session name for $SESSION" >&2
    exit 1
fi

# Strip existing badge if present
if [[ "$SESSION_NAME" =~ ^\[\*\]\ (.*)$ ]]; then
    CLEAN_NAME="${BASH_REMATCH[1]}"
else
    CLEAN_NAME="$SESSION_NAME"
fi

# Add generic attention badge
NEW_NAME="[*] $CLEAN_NAME"
tmux rename-session -t "$SESSION" "$NEW_NAME"

# Set session badge option
tmux set-option -t "$SESSION" @hive_session_badge "*"

echo "OK: '$SESSION_NAME' -> '$NEW_NAME' (set @hive_session_badge=*)"
