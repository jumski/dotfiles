#!/usr/bin/env bash
# This script runs dictation and sets up delayed paste

# Get the target pane from argument
TARGET_PANE="$1"

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
    exit 1
fi

# Run the dictation utility and capture stdout
transcript=$(python3 speak_simple.py)

# If we got a transcript, load it into buffer
if [ -n "$transcript" ]; then
    echo "$transcript" | tmux load-buffer -
fi