#!/bin/bash
# Direct Todoist REST API client using curl with filter support
set -e

# Load API key from .env if it exists
if [[ -f "$HOME/.dotfiles/todoist-helper/.env" ]]; then
    source "$HOME/.dotfiles/todoist-helper/.env"
fi

if [[ -z "$TODOIST_API_KEY" ]]; then
    echo "Error: TODOIST_API_KEY not set" >&2
    exit 1
fi

FILTER="$1"
if [[ -z "$FILTER" ]]; then
    echo "Usage: $0 '<filter>'" >&2
    echo "Example: $0 '(p1 | p2 | p3) & #Wojtek*'" >&2
    exit 1
fi

# URL encode the filter
ENCODED_FILTER=$(printf '%s' "$FILTER" | jq -sRr @uri)

# Get filtered tasks via REST API - return full JSON response
curl -s -G \
    "https://api.todoist.com/rest/v2/tasks" \
    -H "Authorization: Bearer $TODOIST_API_KEY" \
    -d "filter=$ENCODED_FILTER"