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

# Check if appropriate API key is set based on backend
BACKEND="${TRANSCRIPTION_BACKEND:-openai}"
if [ "$BACKEND" = "openai" ]; then
    if [ -z "$OPENAI_API_KEY" ]; then
        echo "ERROR: OPENAI_API_KEY environment variable is not set!" >&2
        exit 1
    fi
else
    if [ -z "$GROQ_API_KEY" ]; then
        echo "ERROR: GROQ_API_KEY environment variable is not set!" >&2
        exit 1
    fi
fi

# Run the dictation utility
# Output only goes to stdout (transcript)
# Status messages go to stderr (visible in popup)
exec python3 speak_simple.py