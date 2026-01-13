#!/bin/bash
# Hive notification script with debugging
# Called by OpenCode plugin or other agents with: --type <type> --message <msg>
# Adds badge to window name and optionally sends system notification

set -euo pipefail

NOTIFY_TYPE=""
MESSAGE=""
LOG_FILE="$HOME/.cache/hive-notify.log"

# Log function (only to file, not stdout)
log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $*" >> "$LOG_FILE"
}

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

log INFO "NOTIFY: type=$NOTIFY_TYPE message='$MESSAGE'"

# Must be in tmux for badge functionality
if [ -z "${TMUX:-}" ]; then
    log INFO "Not in tmux, using notify-send"
    # Fallback to system notification only
    notify-send -u normal -i /home/jumski/.dotfiles/claude/icon.png "OpenCode" "$MESSAGE" 2>/dev/null || true
    exit 0
fi

# Get tmux context of THIS process (where OpenCode is running)
TARGET_SESSION=$(tmux display-message -p '#S')
TARGET_WINDOW=$(tmux display-message -p '#I')
TARGET_PANE=$(tmux display-message -p '#{pane_id}')

log DEBUG "TMUX context: session=$TARGET_SESSION window=$TARGET_WINDOW pane=$TARGET_PANE"

# Check if this is a hive session
IS_HIVE=$(tmux show-options -t "$TARGET_SESSION" -qv @hive 2>/dev/null || echo "")
log DEBUG "IS_HIVE: $IS_HIVE"

if [ "$IS_HIVE" != 'true' ]; then
    log INFO "Not a hive session, using notify-send"
    # Not a hive session - fallback to system notification
    notify-send -u normal -i /home/jumski/.dotfiles/claude/icon.png "OpenCode" "$MESSAGE" 2>/dev/null || true
    exit 0
fi

# Get session and window currently being viewed
CURRENT_SESSION=$(tmux display-message -p '#{client_session}' 2>/dev/null || echo "$TARGET_SESSION")
CURRENT_WINDOW=$(tmux display-message -p '#{window_index}' 2>/dev/null || echo "$TARGET_WINDOW")
CURRENT_PANE=$(tmux display-message -p '#{pane_id}' 2>/dev/null || echo "$TARGET_PANE")

log DEBUG "Current view: session=$CURRENT_SESSION window=$CURRENT_WINDOW pane=$CURRENT_PANE"
log DEBUG "Target session: $TARGET_SESSION == Current: $CURRENT_SESSION"
log DEBUG "Target window: $TARGET_WINDOW == Current: $CURRENT_WINDOW"
log DEBUG "Target pane: $TARGET_PANE == Current: $CURRENT_PANE"

# Check if target pane/window is currently active
# Only show badge if user is NOT already looking at that pane
if [ "$TARGET_SESSION" = "$CURRENT_SESSION" ] && [ "$TARGET_PANE" = "$CURRENT_PANE" ]; then
    log INFO "Target pane is currently active, skipping notification"
    exit 0
fi

log INFO "Target pane not active, proceeding with badge"

# Select badge based on notification type
case "$NOTIFY_TYPE" in
    permission) BADGE='R' ;;  # Request/Permission
    idle)       BADGE='I' ;;  # Idle/waiting
    error)      BADGE='!' ;;  # Error
    *)           BADGE='A' ;;  # Activity (default)
esac

log INFO "Badge: $BADGE"

# Get target window name from pane ID
TARGET_WINDOW=$(tmux display-message -t "$TARGET_PANE" -p '#{window_index}')

log DEBUG "Target window (from pane): $TARGET_WINDOW"
log DEBUG "Target window == Current: $TARGET_WINDOW == Current: $CURRENT_WINDOW"

# Prepend badge to window name (update existing or add new)
if [[ "$TARGET_WINDOW_NAME" =~ ^\[[RIA!]\]\ (.*)$ ]]; then
    # Already badged, update the badge
    CLEAN_NAME="${BASH_REMATCH[1]}"
    log INFO "Updating badge from existing: '$TARGET_WINDOW_NAME' -> '[$BADGE] $CLEAN_NAME'"
    tmux rename-window -t "$TARGET_SESSION:$TARGET_WINDOW" "[$BADGE] $CLEAN_NAME"
else
    # No badge, add one
    log INFO "Adding badge to: '$TARGET_WINDOW_NAME'"
    tmux rename-window -t "$TARGET_SESSION:$TARGET_WINDOW" "[$BADGE] $TARGET_WINDOW_NAME"
fi

# Check if we need system notification (different session focused)
if [ "$CURRENT_SESSION" != "$TARGET_SESSION" ]; then
    log INFO "System notification: session '$TARGET_SESSION' != current '$CURRENT_SESSION'"
    notify-send -u normal "OpenCode: $TARGET_SESSION" "$MESSAGE" 2>/dev/null || true
else
    log INFO "No system notification (same session focused)"
fi

log INFO "Notification complete"
