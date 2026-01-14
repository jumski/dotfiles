#!/bin/bash
# Clear badge from window name on focus
# Called by tmux after-select-pane and after-select-window hooks

# Must be in tmux
[ -z "${TMUX:-}" ] && exit 0

# Get window ID from argument or derive from TMUX_PANE
CURRENT_WINDOW_ID="${1:-}"
if [ -z "$CURRENT_WINDOW_ID" ]; then
    CURRENT_PANE="$TMUX_PANE"
    [ -z "$CURRENT_PANE" ] && exit 0
    CURRENT_WINDOW_ID=$(tmux display-message -t "$CURRENT_PANE" -p '#{window_id}')
fi

# Get session ID from window
CURRENT_SESSION_ID=$(tmux display-message -t "$CURRENT_WINDOW_ID" -p '#{session_id}')

# Get stored original name from the target window
ORIGINAL_NAME=$(tmux show-options -w -t "$CURRENT_WINDOW_ID" -qv @hive_window_original_name 2>/dev/null || echo "")

if [ -n "$ORIGINAL_NAME" ]; then
    tmux rename-window -t "$CURRENT_WINDOW_ID" "$ORIGINAL_NAME"

    # Clear window badge options
    tmux set-option -w -t "$CURRENT_WINDOW_ID" -u @hive_window_badge
    tmux set-option -w -t "$CURRENT_WINDOW_ID" -u @hive_window_original_name

    # Check if session badge should be cleared (run silently)
    SCRIPT_DIR="$(dirname "$0")"
    "$SCRIPT_DIR/hive-clear-session-badge.sh" "$CURRENT_SESSION_ID" >/dev/null 2>&1 || true
fi
