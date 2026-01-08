#!/bin/bash
# Clear badge from window name on focus
# Called by tmux window-focus-in hook

# Must be in tmux
[ -z "${TMUX:-}" ] && exit 0

# Get window name
WINDOW_NAME=$(tmux display-message -p '#W')

# Check if window name starts with badge pattern [X] where X is R, I, !, or A
if [[ "$WINDOW_NAME" =~ ^\[[RIA!]\]\ (.*)$ ]]; then
    # Extract the clean name (everything after "[X] ")
    CLEAN_NAME="${BASH_REMATCH[1]}"
    tmux rename-window "$CLEAN_NAME"
fi
