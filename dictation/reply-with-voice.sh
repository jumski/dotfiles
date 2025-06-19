#!/bin/bash

# Source environment file
ENV_FILE="$HOME/.env.local"

if [[ ! -f "$ENV_FILE" ]]; then
    echo -e "\033[31mError: Environment file $ENV_FILE not found\033[0m" >&2
    exit 1
fi

source "$ENV_FILE"

# Check for GROQ_API_KEY
if [[ -z "$GROQ_API_KEY" ]]; then
    echo -e "\033[31mError: GROQ_API_KEY is not set or empty\033[0m" >&2
    exit 1
fi

# Get text from first argument
TEXT="$1"

if [[ -z "$TEXT" ]]; then
    echo -e "\033[31mError: No text provided as argument\033[0m" >&2
    echo "Usage: $0 \"Text to speak\"" >&2
    exit 1
fi

# Use the groq-tts script with the text
echo "$TEXT" | /home/jumski/.dotfiles/dictation/groq-tts.sh