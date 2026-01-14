#!/bin/bash
# hive-add-badge.sh - Add badge to a specific tmux window
# 
# Usage: ./hive-add-badge.sh <window_id> <badge>
#   window_id: tmux window ID (e.g., "@123")
#   badge:     single char badge (R=permission, I=idle, !=error, A=activity)
#
# Test: ./hive-add-badge.sh @123 I
#       Should show "[I] <window_name>" in status bar

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <window_id> <badge>" >&2
    echo "Example: $0 @123 I" >&2
    exit 1
fi

WINDOW_ID="$1"
BADGE="$2"

# No validation - emoji-based badges
# Just pass through the badge type

# Get current window name using window ID
WINDOW_NAME=$(tmux display-message -t "$WINDOW_ID" -p '#W' 2>/dev/null)
if [ -z "$WINDOW_NAME" ]; then
    echo "ERROR: Could not get window name for $WINDOW_ID" >&2
    exit 1
fi

# Resolve original window name (stored or current)
ORIGINAL_NAME=$(tmux show-options -w -t "$WINDOW_ID" -qv @hive_window_original_name 2>/dev/null || echo "")
if [ -z "$ORIGINAL_NAME" ]; then
    ORIGINAL_NAME="$WINDOW_NAME"
    tmux set-option -w -t "$WINDOW_ID" @hive_window_original_name "$ORIGINAL_NAME"
fi

# Add new badge
NEW_NAME="$BADGE $ORIGINAL_NAME"
tmux rename-window -t "$WINDOW_ID" "$NEW_NAME"

# Set window badge option (for tracking)
tmux set-option -w -t "$WINDOW_ID" @hive_window_badge "$BADGE"

echo "OK: '$WINDOW_NAME' -> '$NEW_NAME' (set @hive_window_badge=$BADGE, original=$ORIGINAL_NAME)"

