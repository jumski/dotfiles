#!/bin/bash

# Accept voice parameter as first argument, default to Chip-PlayAI
# Other preferred voices: Quinn-PlayAI, Mitch-PlayAI, Briggs-PlayAI
VOICE="${1:-Chip-PlayAI}"

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

# Read text from stdin
TEXT=$(cat)

if [[ -z "$TEXT" ]]; then
    echo -e "\033[31mError: No input text provided\033[0m" >&2
    exit 1
fi

# Stream TTS audio directly to speakers
# Detect audio player
if command -v aplay &> /dev/null; then
    PLAYER="aplay -"
elif command -v afplay &> /dev/null; then
    PLAYER="afplay -"
elif command -v play &> /dev/null; then
    PLAYER="play -t wav -"
else
    echo -e "\033[31mError: No audio player found (aplay, afplay, or play)\033[0m" >&2
    exit 1
fi

# Create a temporary file for stderr
STDERR_FILE=$(mktemp)

# Make the API request and stream to audio player
# Use --fail-with-body to get error responses
curl -X POST "https://api.groq.com/openai/v1/audio/speech" \
    -H "Authorization: Bearer $GROQ_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"playai-tts\",
        \"input\": \"$TEXT\",
        \"voice\": \"$VOICE\",
        \"response_format\": \"wav\"
    }" \
    --silent --fail-with-body 2>"$STDERR_FILE" | $PLAYER

# Capture exit codes
CURL_EXIT=${PIPESTATUS[0]}
PLAYER_EXIT=${PIPESTATUS[1]}

# Check if curl failed
if [[ $CURL_EXIT -ne 0 ]]; then
    echo -e "\033[31mError: Failed to generate speech from Groq API\033[0m" >&2
    
    # Show stderr if any
    if [[ -s "$STDERR_FILE" ]]; then
        echo -e "\033[31mDetails:\033[0m" >&2
        cat "$STDERR_FILE" >&2
    fi
    
    rm -f "$STDERR_FILE"
    exit 1
fi

# Check if player failed
if [[ $PLAYER_EXIT -ne 0 ]]; then
    echo -e "\033[31mError: Failed to play audio (player exit code: $PLAYER_EXIT)\033[0m" >&2
    rm -f "$STDERR_FILE"
    exit 1
fi

# Clean up
rm -f "$STDERR_FILE"