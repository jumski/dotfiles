#!/bin/bash
# Parse cached urgent tasks JSON and exit with status code
set -e

CACHE_FILE="$HOME/.cache/todoist-urgent.json"

# If cache doesn't exist or is older than 30 seconds, assume no tasks
if [[ ! -f "$CACHE_FILE" ]] || [[ $(find "$CACHE_FILE" -mmin +0.5 2>/dev/null | wc -l) -gt 0 ]]; then
    exit 0
fi

# Read and parse JSON
if HAS_TASKS=$(jq -r '.has_tasks // false' "$CACHE_FILE" 2>/dev/null); then
    if [[ "$HAS_TASKS" == "true" ]]; then
        # Print simple indicator and exit 1
        echo "TODO"
        exit 1
    fi
fi

# No urgent tasks
exit 0