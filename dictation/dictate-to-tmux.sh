#!/usr/bin/env bash
# This script runs dictation and sends the output to tmux

# Source environment variables
if [ -f ~/.env.local ]; then
    set -a  # automatically export all variables
    source ~/.env.local
    set +a  # turn off automatic export
fi

# Change to the directory where the script is located
cd ~/.dotfiles/dictation/03_app || exit 1

# Check if GROQ_API_KEY is set
if [ -z "$GROQ_API_KEY" ]; then
    echo "ERROR: GROQ_API_KEY environment variable is not set!" >&2
    echo "Press Enter to exit..." >&2
    read -n 1
    exit 1
fi

# Run the dictation utility
# Capture only stdout (transcript) to variable
# Let stderr (status messages) display in the popup
transcript=$(python3 speak_simple.py)

# Send the transcript to tmux if not empty
if [ -n "$transcript" ]; then
    tmux send-keys -l "$transcript"
fi