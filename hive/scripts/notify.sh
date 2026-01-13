#!/bin/bash
# Hive notification script - orchestrates badge notifications
# Called by OpenCode plugin or other agents with: --type <type> --message <msg>
#
# Uses modular scripts:
#   - hive-get-context.sh: Get pane's session/window using $TMUX_PANE
#   - hive-should-notify.sh: Check if target is focused
#   - hive-add-badge.sh: Add badge to window name

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
NOTIFY_TYPE=""
MESSAGE=""
LOG_FILE="$HOME/.cache/hive-notify.log"

# Log function (only to file, not stdout)
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" >> "$LOG_FILE"
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

log INFO "=== NOTIFY START: type=$NOTIFY_TYPE message='$MESSAGE' ==="

# Must be in tmux for badge functionality
if [ -z "${TMUX:-}" ]; then
    log INFO "Not in tmux, using notify-send"
    notify-send -u normal -i /home/jumski/.dotfiles/claude/icon.png "OpenCode" "$MESSAGE" 2>/dev/null || true
    exit 0
fi

# Get context using TMUX_PANE (the pane where this script runs)
CONTEXT=$("$SCRIPT_DIR/hive-get-context.sh" 2>&1) || {
    log ERROR "hive-get-context.sh failed: $CONTEXT"
    notify-send -u normal -i /home/jumski/.dotfiles/claude/icon.png "OpenCode" "$MESSAGE" 2>/dev/null || true
    exit 0
}

TARGET_SESSION=$(echo "$CONTEXT" | cut -d: -f1)
TARGET_WINDOW=$(echo "$CONTEXT" | cut -d: -f2)
TARGET_PANE=$(echo "$CONTEXT" | cut -d: -f3)

log DEBUG "Context from TMUX_PANE: session=$TARGET_SESSION window=$TARGET_WINDOW pane=$TARGET_PANE"

# Check if this is a hive session
IS_HIVE=$(tmux show-options -t "$TARGET_SESSION" -qv @hive 2>/dev/null || echo "")
log DEBUG "IS_HIVE: '$IS_HIVE'"

if [ "$IS_HIVE" != 'true' ]; then
    log INFO "Not a hive session, using notify-send"
    notify-send -u normal -i /home/jumski/.dotfiles/claude/icon.png "OpenCode" "$MESSAGE" 2>/dev/null || true
    exit 0
fi

# Check if we should notify (target not focused)
SHOULD_NOTIFY_OUTPUT=$("$SCRIPT_DIR/hive-should-notify.sh" "$TARGET_SESSION" "$TARGET_WINDOW" 2>&1) || {
    log INFO "Target window is focused, skipping badge"
    log DEBUG "hive-should-notify.sh output: $SHOULD_NOTIFY_OUTPUT"
    exit 0
}

log DEBUG "hive-should-notify.sh output: $SHOULD_NOTIFY_OUTPUT"
log INFO "Target window not focused, proceeding with badge"

# Select badge based on notification type
case "$NOTIFY_TYPE" in
    permission) BADGE='R' ;;
    idle)       BADGE='I' ;;
    error)      BADGE='!' ;;
    *)          BADGE='A' ;;
esac

log INFO "Adding badge '$BADGE' to $TARGET_SESSION:$TARGET_WINDOW"

# Add badge to window
BADGE_OUTPUT=$("$SCRIPT_DIR/hive-add-badge.sh" "$TARGET_SESSION" "$TARGET_WINDOW" "$BADGE" 2>&1) || {
    log ERROR "hive-add-badge.sh failed: $BADGE_OUTPUT"
    exit 1
}

log DEBUG "hive-add-badge.sh output: $BADGE_OUTPUT"

# Add session badge
SESSION_BADGE_OUTPUT=$("$SCRIPT_DIR/hive-add-session-badge.sh" "$TARGET_SESSION" 2>&1) || {
    log ERROR "hive-add-session-badge.sh failed: $SESSION_BADGE_OUTPUT"
    # Non-fatal, continue with window badge
}

# System notification if different session focused
CURRENT_SESSION=$(tmux display-message -p '#{client_session}' 2>/dev/null || echo "$TARGET_SESSION")
if [ "$CURRENT_SESSION" != "$TARGET_SESSION" ]; then
    log INFO "Different session focused, sending system notification"
    notify-send -u normal "OpenCode: $TARGET_SESSION" "$MESSAGE" 2>/dev/null || true
fi

log INFO "=== NOTIFY COMPLETE ==="
