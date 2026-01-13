#!/bin/bash
# hive-add-badge.sh - Add badge to a specific tmux window
# 
# Usage: ./hive-add-badge.sh <session> <window> <badge>
#   session: tmux session name (e.g., "pgflow")
#   window:  window index (e.g., "1")
#   badge:   single char badge (R=permission, I=idle, !=error, A=activity)
#
# Test: ./hive-add-badge.sh pgflow 1 I
#       Should show "[I] <window_name>" in status bar

set -euo pipefail

if [ $# -lt 3 ]; then
    echo "Usage: $0 <session> <window> <badge>" >&2
    echo "Example: $0 pgflow 1 I" >&2
    exit 1
fi

SESSION="$1"
WINDOW="$2"
BADGE="$3"

# Validate badge
case "$BADGE" in
    R|I|!|A) ;;
    *) echo "ERROR: Invalid badge '$BADGE'. Must be R, I, !, or A" >&2; exit 1 ;;
esac

# Get current window name
WINDOW_NAME=$(tmux display-message -t "$SESSION:$WINDOW" -p '#W' 2>/dev/null)
if [ -z "$WINDOW_NAME" ]; then
    echo "ERROR: Could not get window name for $SESSION:$WINDOW" >&2
    exit 1
fi

# Strip existing badge if present
if [[ "$WINDOW_NAME" =~ ^\[[RIA!]\]\ (.*)$ ]]; then
    CLEAN_NAME="${BASH_REMATCH[1]}"
else
    CLEAN_NAME="$WINDOW_NAME"
fi

# Add new badge
NEW_NAME="[$BADGE] $CLEAN_NAME"
tmux rename-window -t "$SESSION:$WINDOW" "$NEW_NAME"

# Set window badge option (for tracking)
tmux set-option -w -t "$SESSION:$WINDOW" @hive_window_badge "$BADGE"

echo "OK: '$WINDOW_NAME' -> '$NEW_NAME' (set @hive_window_badge=$BADGE)"

