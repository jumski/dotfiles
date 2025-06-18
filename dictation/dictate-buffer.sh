#!/usr/bin/env bash
# This script runs dictation and outputs only the transcript to stdout

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

# Run the dictation utility
# Output only goes to stdout (transcript)
# Status messages go to stderr (visible in popup)
exec python3 speak_simple.py