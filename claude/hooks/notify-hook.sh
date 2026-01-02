#!/bin/bash

# Debug: log every invocation
echo "=== Hook invoked at $(date) ===" >> /tmp/claude-notify-debug.log

json_input=$(cat)
echo "json_input: $json_input" >> /tmp/claude-notify-debug.log
message=$(echo "$json_input" | jq -r '.message')
notification_type=$(echo "$json_input" | jq -r '.notification_type')

# Get tmux context
if [ -z "$TMUX" ]; then
    # Not in tmux, always notify
    notify-send -u normal -i /home/jumski/.dotfiles/claude/icon.png "Claude" "$message"
    exit 0
fi

# Use env vars set by claude.fish wrapper (captures window at claude start)
if [ -n "$CLAUDE_TMUX_TARGET" ]; then
    session_name=$(echo "$CLAUDE_TMUX_TARGET" | cut -d: -f1)
    window_index=$(echo "$CLAUDE_TMUX_TARGET" | cut -d: -f2)
    window_name="${CLAUDE_TMUX_WINDOW_NAME:-?}"
else
    # Fallback to current window if env vars not set
    session_name=$(tmux display-message -p '#S' 2>/dev/null || echo "?")
    window_index=$(tmux display-message -p '#I' 2>/dev/null || echo "?")
    window_name=$(tmux display-message -p '#W' 2>/dev/null || echo "?")
fi

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
    --action="focus=Focus" \
    -i /home/jumski/.dotfiles/claude/icon.png \
    "$title" "$body")

  echo "action=$action TMUX=$TMUX target=$target" >> /tmp/claude-notify-debug.log

  if [ "$action" = "focus" ]; then
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
