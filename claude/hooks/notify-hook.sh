#!/bin/bash

json_input=$(cat)
message=$(echo "$json_input" | jq -r '.message')
notification_type=$(echo "$json_input" | jq -r '.notification_type')

# Get tmux context
if [ -z "$TMUX" ]; then
    # Not in tmux, always notify
    notify-send -u normal -i /home/jumski/.dotfiles/claude/icon.png "Claude" "$message"
    exit 0
fi

session_name=$(tmux display-message -p '#S' 2>/dev/null || echo "?")
window_index=$(tmux display-message -p '#I' 2>/dev/null || echo "?")
window_name=$(tmux display-message -p '#W' 2>/dev/null || echo "?")
window_active=$(tmux display-message -p '#{window_active}' 2>/dev/null || echo "0")

# Format: session / index name
window_id="$session_name / $window_index $window_name"

# Check if Kitty terminal is focused
active_window_class=$(xdotool getactivewindow getwindowclassname 2>/dev/null || echo "")
terminal_focused=0
if [[ "$active_window_class" == "kitty" ]]; then
    terminal_focused=1
fi

# Skip if terminal focused AND this tmux window is active
if [ "$terminal_focused" = "1" ] && [ "$window_active" = "1" ]; then
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

notify-send -u normal -i /home/jumski/.dotfiles/claude/icon.png "$title" "$body"
