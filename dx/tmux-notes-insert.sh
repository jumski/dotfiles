#!/usr/bin/env bash
# Insert selected note path into tmux pane

# Hardcoded notes directory
NOTES_DIR="$HOME/Code/pgflow-dev/notes"

# Get target pane from environment (set by tmux binding)
target_pane="${TARGET_PANE:-}"

if [ -z "$target_pane" ]; then
    echo "Error: TARGET_PANE not set" >&2
    exit 1
fi

# Check if notes directory exists with markdown files
if [ ! -d "$NOTES_DIR" ] || [ -z "$(find -L "$NOTES_DIR" -name '*.md' 2>/dev/null | head -1)" ]; then
    echo ""
    echo "  No notes found in $NOTES_DIR"
    echo ""
    read -t 3 -n 1 2>/dev/null || true
    exit 0
fi

# Run the fish function to select a note (from notes dir so paths are relative)
selected_note=$(cd "$NOTES_DIR" && fish -c "
    source ~/.dotfiles/dx/functions/dx-file-select.fish
    dx-file-select \
        --dirs . \
        --pattern '*.md' \
        --sort-mtime \
        --preview-cmd 'bat --style=numbers,changes --color=always --language=markdown {}' \
        --preview-window 'right:65%' \
        --prompt 'Select note > '
")
exit_code=$?

# If selection was made, insert it into the pane
if [ $exit_code -eq 0 ] && [ -n "$selected_note" ]; then
    # Use .notes/ prefix for relative path
    relative_path=".notes/$selected_note"

    # Escape to normal mode, then A to append at end of line
    tmux send-keys -t "$target_pane" Escape
    tmux send-keys -t "$target_pane" A

    # Load the path into buffer and paste it
    echo -n "$relative_path" | tmux load-buffer -
    tmux paste-buffer -p -t "$target_pane"
fi
# Silent exit if cancelled
