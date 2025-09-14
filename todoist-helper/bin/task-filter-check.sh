#!/bin/bash
# Generic script to check tasks against a filter and return JSON
set -e

FILTER="$1"
CACHE_FILE="$2"

if [[ -z "$FILTER" || -z "$CACHE_FILE" ]]; then
    echo "Usage: $0 '<filter>' '<cache_file>'" >&2
    exit 1
fi

# Ensure cache directory exists
mkdir -p "$(dirname "$CACHE_FILE")"

# Run todoist API with filter and capture JSON output
SCRIPT_DIR="$(dirname "$0")"
if ! JSON_OUTPUT=$("$SCRIPT_DIR/todoist-api.sh" "$FILTER" 2>/dev/null); then
    # If command fails, write empty result
    echo '{"tasks": [], "count": 0, "has_tasks": false, "error": "failed to query todoist"}' > "$CACHE_FILE"
    exit 0
fi

# Parse JSON response to get task count and first task
TASK_COUNT=$(echo "$JSON_OUTPUT" | jq 'length' 2>/dev/null || echo 0)
FIRST_TASK=$(echo "$JSON_OUTPUT" | jq -r '.[0].content // ""' 2>/dev/null || echo "")

# Generate structured result
cat > "$CACHE_FILE" <<EOF
{
  "tasks": $JSON_OUTPUT,
  "count": $TASK_COUNT,
  "has_tasks": $(if [[ $TASK_COUNT -gt 0 ]]; then echo "true"; else echo "false"; fi),
  "first_task": $(echo "$FIRST_TASK" | jq -R .),
  "timestamp": $(date +%s)
}
EOF