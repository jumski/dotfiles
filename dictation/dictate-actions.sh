#!/usr/bin/env bash
# Wrapper script that handles different actions based on key pressed during dictation

# Source environment variables
if [ -f ~/.env.local ]; then
    set -a  # automatically export all variables
    source ~/.env.local
    set +a  # turn off automatic export
fi

# Change to the directory where the script is located
cd ~/.dotfiles/dictation || exit 1

# Run dictation and capture output and exit code
# Use a temp file to capture output while showing stderr
tmpfile=$(mktemp)
python3 dictate.py > "$tmpfile"
exit_code=$?
output=$(cat "$tmpfile")
rm -f "$tmpfile"

# In tmux popup, we need to target the pane that opened the popup
# Use TARGET_PANE if set (from popup), otherwise current pane
target_pane="${TARGET_PANE:-$(tmux display -p '#{pane_id}')}"

# Handle different actions based on exit code
case $exit_code in
    0)  # Enter key - paste and execute
        echo -n "$output" | tmux load-buffer -
        tmux paste-buffer -p -t "$target_pane"
        tmux send-keys -t "$target_pane" Enter
        ;;
    
    1)  # C key - copy to clipboard
        # Save to temp file and copy in background like Firefox
        tmpfile=$(mktemp)
        echo -n "$output" > "$tmpfile"
        nohup sh -c "cat '$tmpfile' | xclip -selection clipboard; rm -f '$tmpfile'" >/dev/null 2>&1 &
        tmux display-message "Copied to clipboard!"
        ;;
    
    2)  # S key - search in Firefox
        if [ -n "$output" ]; then
            # URL encode the output
            encoded=$(echo -n "$output" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read()))")
            # Use nohup to detach firefox from the popup
            nohup firefox "https://www.perplexity.ai/search?q=$encoded" >/dev/null 2>&1 &
            tmux display-message "Opened in Firefox!"
        fi
        ;;
    
    3)  # F key - format as markdown
        if [ -n "$output" ]; then
            # Clear screen and show formatting message
            printf "\033[2J\033[H" >&2  # Clear screen and home cursor
            printf "\n\n\n\n" >&2
            printf "          \033[34m╭─╮\n" >&2
            printf "          │●│ ～～～\n" >&2
            printf "          ╰─╯\n" >&2
            printf "           │ \n" >&2
            printf "          ═╧═\033[0m\n" >&2
            printf "\n         \033[34mFormatting...\033[0m\n" >&2
            
            # Format with aichat
            formatted=$(echo "$output" | aichat --prompt "Take these loose thoughts and improve them: organize, expand slightly, fix grammar, and format as clean markdown. Keep the original meaning and voice but make it more polished and structured. Output only the improved markdown text without code fences:" --no-stream)
            
            # Load formatted text and paste
            echo -n "$formatted" | tmux load-buffer -
            tmux paste-buffer -p -t "$target_pane"
        fi
        ;;
    
    99) # Any other key - just paste (no execute)
        echo -n "$output" | tmux load-buffer -
        tmux paste-buffer -p -t "$target_pane"
        ;;
    
    130) # Ctrl-C or Escape - cancel completely
        # Clear any stale buffer to prevent pasting old content
        tmux delete-buffer 2>/dev/null || true
        exit 0
        ;;
    
    *)  # Other errors
        exit 0
        ;;
esac