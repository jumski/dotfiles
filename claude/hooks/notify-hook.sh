#!/bin/bash

# Debug logging
HOOK_LOG="$HOME/.cache/claude-hook-debug.log"
log_debug() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$HOOK_LOG"
}

json_input=$(cat)
message=$(echo "$json_input" | jq -r '.message')
notification_type=$(echo "$json_input" | jq -r '.notification_type')

log_debug "=== HOOK START ==="
log_debug "TMUX=$TMUX"
log_debug "TMUX_PANE=$TMUX_PANE"
log_debug "CLAUDE_TMUX_TARGET=$CLAUDE_TMUX_TARGET"
log_debug "notification_type=$notification_type"

# Get tmux context
if [ -z "$TMUX" ]; then
    # Not in tmux, always notify
    log_debug "Not in tmux, using notify-send"
    notify-send -u normal -i /home/jumski/.dotfiles/claude/icon.png "Claude" "$message"
    exit 0
fi

# Check if this is a hive session
is_hive=$(tmux show-options -qv @hive 2>/dev/null || echo "")
log_debug "is_hive=$is_hive (from tmux show-options -qv @hive)"

if [ "$is_hive" = "true" ]; then
    # --- HIVE PATH ---
    log_debug "Taking HIVE path"
    # Map Claude notification types to hive types
    case "$notification_type" in
        permission_prompt|elicitation_dialog) hive_type="permission" ;;
        idle_prompt)                          hive_type="idle" ;;
        *)                                    hive_type="default" ;;
    esac

    log_debug "Calling notify.sh with type=$hive_type"
    # Delegate to hive notification system
    ~/.dotfiles/hive/scripts/notify.sh --type "$hive_type" --message "$message"
else
    log_debug "Taking LEGACY path"
    # --- LEGACY PATH ---
    # Use env var set by claude.fish wrapper (captures session:index at claude start)
if [ -n "$CLAUDE_TMUX_TARGET" ]; then
    session_name=$(echo "$CLAUDE_TMUX_TARGET" | cut -d: -f1)
    window_index=$(echo "$CLAUDE_TMUX_TARGET" | cut -d: -f2)
else
    # Fallback to current window if env var not set
    session_name=$(tmux display-message -p '#S' 2>/dev/null || echo "?")
    window_index=$(tmux display-message -p '#I' 2>/dev/null || echo "?")
fi

# Look up current window name (may have changed since claude started)
window_name=$(tmux display-message -t "$session_name:$window_index" -p '#W' 2>/dev/null || echo "?")

# Format: session / index name
window_id="$session_name / $window_index $window_name"
target="$session_name:$window_index"

# Check if Kitty terminal is focused
active_window_class=$(xdotool getactivewindow getwindowclassname 2>/dev/null || echo "")
terminal_focused=0
if [[ "$active_window_class" == "kitty" ]]; then
    terminal_focused=1
fi

# Check if target window is the active one in its session
current_window=$(tmux display-message -t "$session_name" -p '#{window_index}' 2>/dev/null || echo "")
target_is_active=0
if [ "$current_window" = "$window_index" ]; then
    target_is_active=1
fi

# Skip if terminal focused AND target tmux window is active
if [ "$terminal_focused" = "1" ] && [ "$target_is_active" = "1" ]; then
    exit 0
fi

# Title and body based on notification type
case "$notification_type" in
    permission_prompt)
        title="⚠️ $window_id"
        body="Permission needed: $message"
        ;;
    idle_prompt)
        title="💤 $window_id"
        body="Waiting for input: $message"
        ;;
    elicitation_dialog)
        title="❓ $window_id"
        body="Input required: $message"
        ;;
    *)
        title="🤖 $window_id"
        body="$message"
        ;;
esac

# Export TMUX env for subshell
export TMUX="$TMUX"

# Run notification with action in background
(
  action=$(notify-send -u normal \
    --action="default=" \
    --action="focus=Focus" \
    -i /home/jumski/.dotfiles/claude/icon.png \
    "$title" "$body")

  if [ "$action" = "default" ] || [ "$action" = "focus" ]; then
    # Focus kitty terminal
    kitty_window=$(xdotool search --class kitty | head -1)
    if [ -n "$kitty_window" ]; then
      xdotool windowactivate "$kitty_window"
    fi

    # Switch all tmux clients to the target session/window
    sleep 0.1
    for client in $(tmux list-clients -F '#{client_tty}'); do
      tmux switch-client -c "$client" -t "$target"
    done
  fi
) &
fi
