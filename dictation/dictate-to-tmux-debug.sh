#!/usr/bin/env bash
# This script runs dictation and sends the output to tmux

# Source environment variables
if [ -f ~/.env.local ]; then
    set -a  # automatically export all variables
    source ~/.env.local
    set +a  # turn off automatic export
    echo "Sourced ~/.env.local" >&2
else
    echo "~/.env.local not found" >&2
fi

# Debug: Check if GROQ_API_KEY is set after sourcing
echo "GROQ_API_KEY length: ${#GROQ_API_KEY}" >&2

# Change to the directory where the script is located
cd ~/.dotfiles/dictation/03_app || {
    echo "Failed to change directory" >&2
    read -p "Press Enter to exit..."
    exit 1
}

# Check if GROQ_API_KEY is set
if [ -z "$GROQ_API_KEY" ]; then
    echo "ERROR: GROQ_API_KEY environment variable is not set!" >&2
    read -p "Press Enter to exit..."
    exit 1
fi

# Check if python3 is available
if ! command -v python3 &> /dev/null; then
    echo "ERROR: python3 not found!" >&2
    read -p "Press Enter to exit..."
    exit 1
fi

# Check if speak_simple.py exists
if [ ! -f speak_simple.py ]; then
    echo "ERROR: speak_simple.py not found!" >&2
    read -p "Press Enter to exit..."
    exit 1
fi

# Run the dictation utility and capture stdout (transcript only)
echo "Starting dictation script..." >&2

# Run python script, capturing only stdout
# stderr will be displayed in the popup
transcript=$(python3 speak_simple.py)
exit_code=$?

if [ $exit_code -ne 0 ]; then
    echo "Script exited with code $exit_code" >&2
    read -p "Press Enter to exit..."
    exit $exit_code
fi

# Debug: Show what we captured
echo -e "\n--- DEBUG INFO ---" >&2
echo "Transcript captured: '$transcript'" >&2
echo "Transcript length: ${#transcript}" >&2

# Send the transcript to tmux if not empty
if [ -n "$transcript" ]; then
    echo "Sending transcript to tmux..." >&2
    tmux send-keys -l "$transcript"
    echo "Sent successfully!" >&2
else
    echo "No transcript to send (empty)" >&2
fi

# Pause to see results
echo -e "\nPress Enter to close..." >&2
read