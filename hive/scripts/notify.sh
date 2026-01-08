#!/bin/bash
# Hive notification script
# Called by OpenCode plugin or other agents with: --type <type> --message <msg>
# Adds badge to window name and optionally sends system notification

set -euo pipefail

NOTIFY_TYPE=""
MESSAGE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --type) NOTIFY_TYPE="$2"; shift 2 ;;
        --message) MESSAGE="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# Default message if not provided
if [ -z "$MESSAGE" ]; then
    MESSAGE="Notification"
fi

# Must be in tmux for badge functionality
if [ -z "${TMUX:-}" ]; then
    # Fallback to system notification only
    notify-send "OpenCode" "$MESSAGE" 2>/dev/null || true
    exit 0
fi

# Get current context
SESSION=$(tmux display-message -p '#S')
WINDOW=$(tmux display-message -p '#I')

# Check if this is a hive session
IS_HIVE=$(tmux show-options -t "$SESSION" -qv @hive 2>/dev/null || echo "")
if [ "$IS_HIVE" != 'true' ]; then
    # Not a hive session - fallback to system notification
    notify-send "OpenCode" "$MESSAGE" 2>/dev/null || true
    exit 0
fi

# Check if target pane is focused (active window in active session)
ACTIVE_PANE=$(tmux display-message -p '#{pane_active}')
ACTIVE_WINDOW=$(tmux display-message -p '#{window_active}')

# If this window is active and focused, no badge needed
if [ "$ACTIVE_PANE" = '1' ] && [ "$ACTIVE_WINDOW" = '1' ]; then
    exit 0
fi

# Select badge based on notification type
case "$NOTIFY_TYPE" in
    permission) BADGE='R' ;;  # Request/Permission
    idle)       BADGE='I' ;;  # Idle/waiting
    error)      BADGE='!' ;;  # Error
    *)          BADGE='A' ;;  # Activity (default)
esac

# Get current window name
WINDOW_NAME=$(tmux display-message -p '#W')

# Prepend badge to window name (update existing or add new)
if [[ "$WINDOW_NAME" =~ ^\[[RIA!]\]\ (.*)$ ]]; then
    # Already badged, update the badge
    tmux rename-window "[$BADGE] ${BASH_REMATCH[1]}"
else
    # No badge, add one
    tmux rename-window "[$BADGE] $WINDOW_NAME"
fi

# Check if we need system notification (different session focused)
# Get the session that the client is currently viewing
CLIENT_SESSION=$(tmux display-message -p '#{client_session}' 2>/dev/null || echo "$SESSION")
if [ "$CLIENT_SESSION" != "$SESSION" ]; then
    notify-send -u normal "OpenCode: $SESSION" "$MESSAGE" 2>/dev/null || true
fi
