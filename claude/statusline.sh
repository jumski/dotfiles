#!/bin/bash
# Claude Code statusline - shows model name and context usage

# ANSI color codes
RESET="\033[0m"
DIM="\033[2m"
BOLD="\033[1m"
UNDERLINE="\033[4m"
YELLOW="\033[33m"
RED="\033[31m"
GREEN="\033[32m"
# Model colors
OPUS_COLOR="\033[38;5;208m"    # Orange for Opus
SONNET_COLOR="\033[38;5;141m"  # Purple for Sonnet
HAIKU_COLOR="\033[38;5;123m"   # Cyan for Haiku

# Read JSON input from stdin
input=$(cat)

# Extract model ID and format it (claude-opus-4-1 -> Opus 4.1)
MODEL_ID=$(echo "$input" | jq -r '.model.id // empty')
MODEL_COLOR=""
if [ -n "$MODEL_ID" ]; then
    # Remove 'claude-' prefix and date suffix (e.g., -20250514)
    MODEL_NAME=$(echo "$MODEL_ID" | sed -E 's/^claude-//; s/-[0-9]{8}$//')
    # Convert to display format: opus-4-1 -> Opus 4.1, sonnet-4-5 -> Sonnet 4.5
    MODEL_DISPLAY=$(echo "$MODEL_NAME" | awk -F'-' '{
        first = toupper(substr($1, 1, 1)) substr($1, 2)
        version = ""
        for (i = 2; i <= NF; i++) {
            if (version != "") version = version "."
            version = version $i
        }
        if (version != "") print first " " version
        else print first
    }')
    # Set model color based on model type
    case "$MODEL_NAME" in
        opus*) MODEL_COLOR="$OPUS_COLOR" ;;
        sonnet*) MODEL_COLOR="$SONNET_COLOR" ;;
        haiku*) MODEL_COLOR="$HAIKU_COLOR" ;;
    esac
else
    MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
fi

# Get transcript path for context calculation
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path // empty')

# Calculate context usage from transcript
CONTEXT_INFO=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    # Get the most recent non-sidechain message with usage data
    # Use jq filter that avoids != escaping issues
    USAGE_DATA=$(tail -100 "$TRANSCRIPT_PATH" 2>/dev/null | \
        jq -s '[.[] | select(.message.usage) | select(.isSidechain | not) | select(.isApiErrorMessage | not)] | last | .message.usage // empty' 2>/dev/null)

    if [ -n "$USAGE_DATA" ] && [ "$USAGE_DATA" != "null" ] && [ "$USAGE_DATA" != "" ]; then
        # Sum up all input token types
        INPUT_TOKENS=$(echo "$USAGE_DATA" | jq -r '.input_tokens // 0')
        CACHE_READ=$(echo "$USAGE_DATA" | jq -r '.cache_read_input_tokens // 0')
        CACHE_CREATE=$(echo "$USAGE_DATA" | jq -r '.cache_creation_input_tokens // 0')

        TOTAL_TOKENS=$((INPUT_TOKENS + CACHE_READ + CACHE_CREATE))

        # Max context is 200K for all current models
        MAX_CONTEXT=200000

        if [ "$TOTAL_TOKENS" -gt 0 ]; then
            # Calculate percentage
            PERCENT=$((TOTAL_TOKENS * 100 / MAX_CONTEXT))

            # Format tokens in K notation
            if [ "$TOTAL_TOKENS" -ge 1000 ]; then
                TOKENS_K=$(awk "BEGIN {printf \"%.1f\", $TOTAL_TOKENS / 1000}")
                TOKENS_DISPLAY="${TOKENS_K}K"
            else
                TOKENS_DISPLAY="$TOTAL_TOKENS"
            fi

            # Color based on percentage
            # <25%: muted, <50%: normal, <75%: yellow, <90%: red, <100%: red bold underline
            if [ "$PERCENT" -ge 90 ]; then
                COLOR="${RED}${BOLD}${UNDERLINE}"
            elif [ "$PERCENT" -ge 75 ]; then
                COLOR="${RED}"
            elif [ "$PERCENT" -ge 50 ]; then
                COLOR="${YELLOW}"
            elif [ "$PERCENT" -ge 25 ]; then
                COLOR=""
            else
                COLOR="${DIM}"
            fi

            CONTEXT_INFO=" ${COLOR}${TOKENS_DISPLAY} (${PERCENT}%)${RESET}"
        fi
    fi

    # Count turns (assistant messages that are not sidechains)
    TURN_COUNT=$(jq -s '[.[] | select(.type == "assistant") | select(.isSidechain | not)] | length' "$TRANSCRIPT_PATH" 2>/dev/null)
    if [ -n "$TURN_COUNT" ] && [ "$TURN_COUNT" -gt 0 ]; then
        TURNS_INFO=" ${DIM}${TURN_COUNT} turns${RESET}"
    fi
fi

# Get lines changed from cost object
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
LINES_INFO=""
if [ "$LINES_ADDED" -gt 0 ] || [ "$LINES_REMOVED" -gt 0 ]; then
    LINES_INFO=" ${GREEN}+${LINES_ADDED}${RESET} ${DIM}/${RESET} ${RED}-${LINES_REMOVED}${RESET}"
fi

# Build output parts
OUTPUT="${MODEL_COLOR}${MODEL_DISPLAY}${RESET}"

# Add context info
if [ -n "$CONTEXT_INFO" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET}${CONTEXT_INFO}"
fi

# Add turns info
if [ -n "$TURNS_INFO" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET}${TURNS_INFO}"
fi

# Add lines changed
if [ -n "$LINES_INFO" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET}${LINES_INFO}"
fi

echo -e "$OUTPUT"
