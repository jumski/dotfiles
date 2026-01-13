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

TARGET_SESSION_NAME=$(echo "$CONTEXT" | cut -d: -f1)
TARGET_WINDOW_INDEX=$(echo "$CONTEXT" | cut -d: -f2)
TARGET_PANE_ID=$(echo "$CONTEXT" | cut -d: -f3)
TARGET_SESSION_ID=$(echo "$CONTEXT" | cut -d: -f4)
TARGET_WINDOW_ID=$(echo "$CONTEXT" | cut -d: -f5)

log DEBUG "Context from TMUX_PANE: session=$TARGET_SESSION_NAME($TARGET_SESSION_ID) window=$TARGET_WINDOW_INDEX($TARGET_WINDOW_ID) pane=$TARGET_PANE_ID"

# Check if this is a hive session (use session ID for precision)
IS_HIVE=$(tmux show-options -t "$TARGET_SESSION_ID" -qv @hive 2>/dev/null || echo "")
log DEBUG "IS_HIVE: '$IS_HIVE'"

if [ "$IS_HIVE" != 'true' ]; then
    log INFO "Not a hive session, using notify-send"
    notify-send -u normal -i /home/jumski/.dotfiles/claude/icon.png "OpenCode" "$MESSAGE" 2>/dev/null || true
    exit 0
fi

# Check if we should notify (target not focused) - use IDs for precision
SHOULD_NOTIFY_OUTPUT=$("$SCRIPT_DIR/hive-should-notify.sh" "$TARGET_SESSION_ID" "$TARGET_WINDOW_ID" 2>&1) || {
    log INFO "Target window is focused, skipping badge"
    log DEBUG "hive-should-notify.sh output: $SHOULD_NOTIFY_OUTPUT"
    exit 0
}

log DEBUG "hive-should-notify.sh output: $SHOULD_NOTIFY_OUTPUT"
log INFO "Target window not focused, proceeding with badge"

# Select badge and emoji based on notification type
case "$NOTIFY_TYPE" in
    permission) BADGE='R'; EMOJI='🔐' ;;
    idle)       BADGE='I'; EMOJI='󰭻' ;;
    error)      BADGE='!'; EMOJI='🔴' ;;
    activity)    BADGE='A'; EMOJI='🔔' ;;
esac

log INFO "Adding badge '$BADGE' to $TARGET_SESSION_NAME:$TARGET_WINDOW_INDEX ($TARGET_WINDOW_ID)"

# Add badge to window (use window ID for precision)
BADGE_OUTPUT=$("$SCRIPT_DIR/hive-add-badge.sh" "$TARGET_WINDOW_ID" "$BADGE" 2>&1) || {
    log ERROR "hive-add-badge.sh failed: $BADGE_OUTPUT"
    exit 1
}

log DEBUG "hive-add-badge.sh output: $BADGE_OUTPUT"

# Add session badge (use session ID for precision)
SESSION_BADGE_OUTPUT=$("$SCRIPT_DIR/hive-add-session-badge.sh" "$TARGET_SESSION_ID" 2>&1) || {
    log ERROR "hive-add-session-badge.sh failed: $SESSION_BADGE_OUTPUT"
    true  # Non-fatal, continue
}
log DEBUG "hive-add-session-badge.sh output: $SESSION_BADGE_OUTPUT"

# System notification if different session focused (use session ID for comparison)
# Note: We need to get CLIENT's current session, not script's pane context
CURRENT_SESSION_NAME=$(tmux display-message -p '#{client_session}' 2>/dev/null)
CURRENT_SESSION_ID=$(tmux display-message -t "$CURRENT_SESSION_NAME" -p '#{session_id}' 2>/dev/null)
log DEBUG "Session comparison: TARGET=$TARGET_SESSION_ID CURRENT=$CURRENT_SESSION_ID (client viewing: $CURRENT_SESSION_NAME)"

if [ "$CURRENT_SESSION_ID" != "$TARGET_SESSION_ID" ]; then
    log INFO "Different session focused, sending system notification"
    
    # Get window name for notification title (use window ID for precision)
    TARGET_WINDOW_NAME=$(tmux display-message -t "$TARGET_WINDOW_ID" -p '#W' 2>/dev/null || echo "?")
    
    # Format: "💤 pgflow / 1 main" (use names for display)
    NOTIFY_TITLE="$EMOJI $TARGET_SESSION_NAME / $TARGET_WINDOW_INDEX $TARGET_WINDOW_NAME"
    
    # Export TMUX env for subshell
    export TMUX="$TMUX"
    
    # Run notification with click action in background
    (
        log INFO "Subshell: waiting for notification click..."
        
        action=$(notify-send -u normal --wait \
            --action="default=Open" \
            -i /home/jumski/.dotfiles/claude/icon.png \
            "$NOTIFY_TITLE" "$MESSAGE")
        
        log INFO "Subshell: action='$action'"
        
        if [ "$action" = "default" ]; then
            log INFO "Subshell: focusing kitty..."
            
            # Use full path in case PATH differs
            kitty_window=$(/home/jumski/.dotfiles/bin/dotool search --class kitty | head -1)
            log INFO "Subshell: kitty_window='$kitty_window'"
            
            if [ -n "$kitty_window" ]; then
                /home/jumski/.dotfiles/bin/dotool windowactivate "$kitty_window"
                log INFO "Subshell: activated kitty"
            fi
            
            # Switch all tmux clients to target session/window (use window ID for precision)
            sleep 0.1
            for client in $(tmux list-clients -F '#{client_tty}'); do
                log INFO "Subshell: switching client $client to $TARGET_WINDOW_ID"
                tmux switch-client -c "$client" -t "$TARGET_WINDOW_ID"
            done
            
            log INFO "Subshell: focus complete"
        else
            log INFO "Subshell: notification dismissed (action='$action')"
        fi
    ) &
fi

log INFO "=== NOTIFY COMPLETE ==="
