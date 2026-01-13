#!/bin/bash
# hive-add-session-badge.sh - Add generic badge to tmux session name
#
# Usage: ./hive-add-session-badge.sh <session_id>
#   session_id: tmux session ID (e.g., "$123")
#
# Test: ./hive-add-session-badge.sh \$123
#       Should add "[*] <session_name>" to session list

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <session_id>" >&2
    echo "Example: $0 \$123" >&2
    exit 1
fi

SESSION_ID="$1"

# Get current session name using session ID
SESSION_NAME=$(tmux display-message -t "$SESSION_ID" -p '#S' 2>/dev/null)
if [ -z "$SESSION_NAME" ]; then
    echo "ERROR: Could not get session name for $SESSION_ID" >&2
    exit 1
fi

# Strip existing badge if present
if [[ "$SESSION_NAME" =~ ^\[\*\]\ (.*)$ ]]; then
    CLEAN_NAME="${BASH_REMATCH[1]}"
else
    CLEAN_NAME="$SESSION_NAME"
fi

# Add generic attention badge using emoji as badge marker
NEW_NAME="󰭻 $CLEAN_NAME"
tmux rename-session -t "$SESSION_ID" "$NEW_NAME"

# Set session badge option
tmux set-option -t "$SESSION_ID" @hive_session_badge "*"

echo "OK: '$SESSION_NAME' -> '$NEW_NAME' (set @hive_session_badge=*)"
