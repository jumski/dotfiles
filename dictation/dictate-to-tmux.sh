#!/usr/bin/env bash
# This script runs dictation and sends the output to tmux

# Run the dictation utility and capture the output
output=$(python3 ~/.dotfiles/dictation/03_app/speak.py 2>&1)

# Extract only the transcript (everything after "TRANSCRIPT:")
transcript=$(echo "$output" | sed -n '/^TRANSCRIPT:/,$ p' | sed '1d' | tr '\n' ' ' | sed 's/[[:space:]]*$//')

# Send the transcript to tmux if not empty
if [ -n "$transcript" ]; then
    tmux send-keys -l "$transcript"
fi