#!/bin/bash
# Cron script to update urgent tasks cache
set -e

SCRIPT_DIR="$(dirname "$0")"
FILTER="(p1 | p2 | p3) & #Wojtek*"
CACHE_FILE="$HOME/.cache/todoist-urgent.json"

# Source API key if available
if [[ -f "$HOME/.config/todoist/config.json" ]]; then
    export TODOIST_API_KEY=$(jq -r '.token' "$HOME/.config/todoist/config.json" 2>/dev/null || echo "")
fi

# Update cache
"$SCRIPT_DIR/task-filter-check.sh" "$FILTER" "$CACHE_FILE"