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

# Make the API request and stream to audio player
curl -X POST "https://api.groq.com/openai/v1/audio/speech" \
    -H "Authorization: Bearer $GROQ_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"playai-tts\",
        \"input\": \"$TEXT\",
        \"voice\": \"$VOICE\",
        \"response_format\": \"wav\"
    }" \
    --silent --fail | $PLAYER

if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    echo -e "\033[31mError: Failed to generate speech from Groq API\033[0m" >&2
    exit 1
fi