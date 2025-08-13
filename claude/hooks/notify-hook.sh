#!/bin/bash
# disabled for now
exit 0

# Read JSON input from stdin
json_input=$(cat)

# Extract message from JSON
message=$(echo "$json_input" | jq -r '.message')

# Get tmux session name if available
if [ -n "$TMUX" ]; then
    session_name=$(tmux display-message -p '#S' 2>/dev/null || echo "Unknown")
else
    session_name="Unknown"
fi

# Send notification
notify-send -u critical -i /home/jumski/.dotfiles/claude/icon.png "Claude: $session_name" "$message"
