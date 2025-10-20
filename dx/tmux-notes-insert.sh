#!/usr/bin/env bash
# Insert selected note path into tmux pane

set -e

# Get target pane from environment (set by tmux binding)
target_pane="${TARGET_PANE:-}"

if [ -z "$target_pane" ]; then
    echo "Error: TARGET_PANE not set" >&2
    exit 1
fi

# Run the fish function to select a note
# We need to run it in fish shell context
selected_note=$(fish -c "source ~/.dotfiles/dx/functions/dx-notes-find.fish; dx-notes-find")
exit_code=$?

# If selection was made, insert it into the pane
if [ $exit_code -eq 0 ] && [ -n "$selected_note" ]; then
    # Escape to normal mode, then A to append at end of line
    tmux send-keys -t "$target_pane" Escape
    tmux send-keys -t "$target_pane" A

    # Load the path into buffer and paste it
    echo -n "$selected_note" | tmux load-buffer -
    tmux paste-buffer -p -t "$target_pane"
else
    # User cancelled or error occurred
    tmux display-message "No note selected"
fi
