#!/bin/bash
# Claude Code statusline - shows model name and context usage

# ANSI color codes
RESET="\033[0m"
DIM="\033[2m"
BOLD="\033[1m"
UNDERLINE="\033[4m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
ORANGE="\033[38;5;208m"
# Model colors
OPUS_COLOR="\033[38;5;208m"    # Orange for Opus
SONNET_COLOR="\033[38;5;141m"  # Purple for Sonnet
HAIKU_COLOR="\033[38;5;123m"   # Cyan for Haiku
GLM_COLOR="\033[38;5;82m"      # Lime green for GLM

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

# Override for z.ai API
if [ "$ANTHROPIC_BASE_URL" = "https://api.z.ai/api/anthropic" ]; then
    MODEL_DISPLAY="GLM 4.7"
    MODEL_COLOR="$GLM_COLOR"
fi

# Get transcript path for context calculation
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path // empty')

# Calculate context usage from transcript
CONTEXT_INFO=""
TURNS_INFO=""
SUMMARY_INFO=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    # Get the most recent non-sidechain message with usage data
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
            # Calculate remaining percentage
            PERCENT_REMAINING=$(( (MAX_CONTEXT - TOTAL_TOKENS) * 100 / MAX_CONTEXT ))

            # Format tokens in K notation
            if [ "$TOTAL_TOKENS" -ge 1000 ]; then
                TOKENS_K=$(awk "BEGIN {printf \"%.1f\", $TOTAL_TOKENS / 1000}")
                TOKENS_DISPLAY="${TOKENS_K}K"
            else
                TOKENS_DISPLAY="$TOTAL_TOKENS"
            fi

            # Color based on remaining percentage
            # ≥40%: muted, 30-39%: green, 20-29%: yellow, 10-19%: orange, <10%: red
            if [ "$PERCENT_REMAINING" -lt 10 ]; then
                COLOR="${RED}"
            elif [ "$PERCENT_REMAINING" -lt 20 ]; then
                COLOR="${ORANGE}"
            elif [ "$PERCENT_REMAINING" -lt 30 ]; then
                COLOR="${YELLOW}"
            elif [ "$PERCENT_REMAINING" -lt 40 ]; then
                COLOR="${GREEN}"
            else
                COLOR="${DIM}"
            fi

            CONTEXT_INFO=" ${COLOR}${PERCENT_REMAINING}% left${RESET}"
        fi
    fi

    # Count turns (assistant messages that are not sidechains)
    TURN_COUNT=$(jq -s '[.[] | select(.type == "assistant") | select(.isSidechain | not)] | length' "$TRANSCRIPT_PATH" 2>/dev/null)
    if [ -n "$TURN_COUNT" ] && [ "$TURN_COUNT" -gt 0 ]; then
        if [ "$TURN_COUNT" -eq 1 ]; then
            TURNS_INFO="1 turn"
        else
            TURNS_INFO="${TURN_COUNT} turns"
        fi
    fi

    # Get summary from transcript (first summary entry) - will be truncated later to fit terminal
    SUMMARY=$(head -50 "$TRANSCRIPT_PATH" 2>/dev/null | jq -r 'select(.type == "summary") | .summary // empty' 2>/dev/null | head -1)
    if [ -n "$SUMMARY" ]; then
        SUMMARY_INFO="$SUMMARY"
    fi
fi

# Get lines changed from cost object
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
LINES_INFO=""
if [ "$LINES_ADDED" -gt 0 ] || [ "$LINES_REMOVED" -gt 0 ]; then
    LINES_INFO="${GREEN}+${LINES_ADDED}${RESET} ${RED}-${LINES_REMOVED}${RESET}"
fi

# Get session duration from cost object and format as human readable
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
DURATION_INFO=""
if [ "$DURATION_MS" -gt 0 ]; then
    # Convert to seconds
    DURATION_SEC=$((DURATION_MS / 1000))
    if [ "$DURATION_SEC" -ge 3600 ]; then
        HOURS=$((DURATION_SEC / 3600))
        MINS=$(((DURATION_SEC % 3600) / 60))
        DURATION_INFO="${HOURS}h ${MINS}m"
    elif [ "$DURATION_SEC" -ge 60 ]; then
        MINS=$((DURATION_SEC / 60))
        SECS=$((DURATION_SEC % 60))
        DURATION_INFO="${MINS}m ${SECS}s"
    else
        DURATION_INFO="${DURATION_SEC}s"
    fi
fi

# Build output parts (prefix - everything before summary)
# Model: first letter colored, rest muted
MODEL_FIRST="${MODEL_DISPLAY:0:1}"
MODEL_REST="${MODEL_DISPLAY:1}"
OUTPUT="${MODEL_COLOR}${MODEL_FIRST}${RESET}${DIM}${MODEL_REST}${RESET}"

# Add context info
if [ -n "$CONTEXT_INFO" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET}${CONTEXT_INFO}"
fi

# Add lines changed (before turns)
if [ -n "$LINES_INFO" ]; then
    OUTPUT="${OUTPUT} ${DIM}|${RESET} ${LINES_INFO}"
fi

# Add turns and duration (muted)
if [ -n "$TURNS_INFO" ] || [ -n "$DURATION_INFO" ]; then
    OUTPUT="${OUTPUT} ${DIM}|"
    if [ -n "$TURNS_INFO" ]; then
        OUTPUT="${OUTPUT} ${TURNS_INFO}"
    fi
    if [ -n "$DURATION_INFO" ]; then
        if [ -n "$TURNS_INFO" ]; then
            OUTPUT="${OUTPUT},"
        fi
        OUTPUT="${OUTPUT} ${DURATION_INFO}"
    fi
    OUTPUT="${OUTPUT}${RESET}"
fi

# Add summary (muted, truncated to 100 chars)
if [ -n "$SUMMARY_INFO" ]; then
    if [ ${#SUMMARY_INFO} -gt 100 ]; then
        SUMMARY_INFO="${SUMMARY_INFO:0:97}..."
    fi
    OUTPUT="${OUTPUT} ${DIM}| ${SUMMARY_INFO}${RESET}"
fi

echo -e "$OUTPUT"
