#!/bin/bash
# ai-rename-window.sh - Rename tmux window based on pane content using LLM
# Usage: ai-rename-window.sh [window_id]
#   window_id: optional, defaults to current window

set -euo pipefail

# Get target window (default to current)
TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  TARGET=$(tmux display-message -p '#I')
fi

# Get current window name
CURRENT_NAME=$(tmux display-message -t "$TARGET" -p '#{window_name}')

# Get pane height and capture 3x that amount of content
PANE_HEIGHT=$(tmux display-message -t "$TARGET" -p '#{pane_height}')
LINES_TO_CAPTURE=$((PANE_HEIGHT * 3))

# Capture pane content
CONTENT=$(tmux capture-pane -p -t "$TARGET" -S -"$LINES_TO_CAPTURE" 2>/dev/null || echo "")

if [[ -z "$CONTENT" ]]; then
  echo "Error: Could not capture pane content" >&2
  exit 1
fi

# Generate window name via LLM
PROMPT="Current window name: ${CURRENT_NAME}

IMPORTANT: If the current name ALREADY FITS the terminal content, return it UNCHANGED.
Only generate a new name if the current one is generic (like 'bash', 'fish', 'zsh') or clearly mismatches the content.
PRESERVE existing good names - stability is preferred over novelty.

Rules for NEW names (only if current name doesn't fit):
1. Start with ONE emoji representing the main topic/tool (🐟fish, 🔐auth, 📚docs, 🐛bug, ⚙️config, 🧪test, 📦npm, 🐍python, 🦀rust, 🌐web, 💾db, 🔧fix, 🚀deploy, 📝edit, 🔍search, 🖥️tmux, ⚡perf)
2. Follow with lowercase name, max 15 chars, use hyphens
3. NO SPACE between emoji and name
4. Be specific: \"fish-func-test\" not \"fish\"
5. Name should describe WHAT is being worked on

Examples: 🐟fish-fns-test, 🔐jwt-refresh, 📦pkg-upgrade, 🐛null-ptr-fix, ⚙️nvim-config

Output ONLY valid JSON:
{\"name\": \"emoji-plus-name\"}"

# Call aichat and parse response
RESULT=$(echo "$CONTENT" | aichat -m openai:gpt-4o-mini --code "$PROMPT" 2>/dev/null)

# Extract name from JSON
NAME=$(echo "$RESULT" | jq -r '.name // empty' 2>/dev/null)

if [[ -z "$NAME" ]]; then
  echo "Error: Could not parse LLM response" >&2
  echo "Raw response: $RESULT" >&2
  exit 1
fi

# Rename the window (skip if unchanged)
if [[ "$NAME" == "$CURRENT_NAME" ]]; then
  echo "Window $TARGET: keeping '$NAME' (still fits)"
else
  tmux rename-window -t "$TARGET" "$NAME"
  echo "Window $TARGET: '$CURRENT_NAME' → '$NAME'"
fi
