#!/bin/bash
# Clear badge from window name on focus
# Called by tmux pane-focus-in hook

# Must be in tmux
[ -z "${TMUX:-}" ] && exit 0

# Get current session ID and window name
CURRENT_SESSION_ID=$(tmux display-message -p '#{session_id}')
WINDOW_NAME=$(tmux display-message -p '#W')

# Check if window name starts with badge pattern [X] where X is R, I, !, or A
if [[ "$WINDOW_NAME" =~ ^\[[RIA!]\]\ (.*)$ ]]; then
    # Extract the clean name (everything after "[X] ")
    CLEAN_NAME="${BASH_REMATCH[1]}"
    tmux rename-window "$CLEAN_NAME"
    
    # Clear window badge option
    tmux set-option -w @hive_window_badge ""
    
    # Check if session badge should be cleared (run silently)
    SCRIPT_DIR="$(dirname "$0")"
    "$SCRIPT_DIR/hive-clear-session-badge.sh" "$CURRENT_SESSION_ID" >/dev/null 2>&1 || true
fi
