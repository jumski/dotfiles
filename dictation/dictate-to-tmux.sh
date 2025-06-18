#!/usr/bin/env bash
# This script runs dictation and sends the output to tmux

# Run the dictation utility and capture stdout (transcript only)
# stderr will still be shown in the popup for status messages
transcript=$(python3 ~/.dotfiles/dictation/03_app/speak.py)

# Send the transcript to tmux if not empty
if [ -n "$transcript" ]; then
    tmux send-keys -l "$transcript"
fi