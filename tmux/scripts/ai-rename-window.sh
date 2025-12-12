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

# Get pane metadata
PANE_PWD=$(tmux display-message -t "$TARGET" -p '#{pane_current_path}')
PANE_CMD=$(tmux display-message -t "$TARGET" -p '#{pane_current_command}')

# Get pane height and capture 2x that amount of content
PANE_HEIGHT=$(tmux display-message -t "$TARGET" -p '#{pane_height}')
LINES_TO_CAPTURE=$((PANE_HEIGHT * 2))

# Capture pane content
CONTENT=$(tmux capture-pane -p -t "$TARGET" -S -"$LINES_TO_CAPTURE" 2>/dev/null || echo "")

if [[ -z "$CONTENT" ]]; then
  echo "Error: Could not capture pane content" >&2
  exit 1
fi

# Detect empty Claude Code window (cleared or fresh session)
# Check for Claude markers AND empty content indicators
if echo "$CONTENT" | grep -qE '(⏵⏵ accept edits|Opus|Sonnet).*(shift\+tab|Thinking)'; then
  # It's Claude Code - check if empty
  if echo "$CONTENT" | grep -qE '(\(no content\)|Claude Code v[0-9]|Try "refactor)'; then
    tmux rename-window -t "$TARGET" "💬"
    echo "Window $TARGET: empty Claude session → '💬'"
    exit 0
  fi
fi

# Show thinking indicator
tmux rename-window -t "$TARGET" "🤔${CURRENT_NAME}"

# Generate window name via LLM
PROMPT="Current window name: ${CURRENT_NAME}
Current directory: ${PANE_PWD}
Running command: ${PANE_CMD}

IMPORTANT: If the current name ALREADY FITS the terminal content, return it UNCHANGED.
Only generate a new name if the current one is generic (like 'bash', 'fish', 'zsh', 'vim') or clearly mismatches the content.
PRESERVE existing good names - stability is preferred over novelty.

Use 'Running command' to identify the app:
- nvim, vim, nano → ✏️ (editor)
- fish, bash, zsh → check content: could be 💬 (claude) or 💲 (idle shell)
- node, npm, pnpm, yarn → 🚀 (server) or ✅ (test) based on content
- htop, top, tail → 📊 (monitor)
- jest, vitest, pytest → ✅ (test)

Use 'Current directory' basename for shell names (e.g., /home/user/pgflow → 'pgflow').

CLAUDE CODE DETECTION (use 💬):
If you see ANY of these patterns, it's Claude Code:
- '⏵⏵ accept edits' or '⏸ plan mode' with '(shift+tab to cycle)'
- 'Opus'/'Sonnet' model names, '% left', 'turns', time like '73h 21m'
- Tool calls: '● Read', '● Update', '● Bash', '⎿' output markers
- 'ctrl-g to edit in Nvim'
- Plan confirmation: 'Would you like to proceed?' with 'Yes, and auto-accept edits'
- Question dialogs with '☐' checkbox, numbered options, 'Enter to select · Tab/Arrow keys'
- 'Here is Claude\\'s plan:'

EMPTY CLAUDE WINDOW: If Claude Code is detected but content is empty/cleared (shows '/clear', '(no content)', or just empty prompt with status bar), return ONLY the emoji with NO text: {"name": "💬"}

ONLY USE THESE 6 EMOJIS. Pick based on the RUNNING APP, not shell commands.

Rules:
1. CHAR LIMIT (emoji doesn't count): regular windows ≤12 chars, Claude windows ≤16 chars
2. NO SPACE between emoji and name, use hyphens between words
3. KEEP IT SHORT: 1-2 words max, use abbreviations (cfg, fn, srv, db)
4. Icon = WHAT APP is running
5. Text = the MAIN FEATURE being built/discussed (ignore diff artifacts, tool output)
6. For Claude: look at what USER is asking about, not internal tool output

Examples:
- ✏️api-routes (nvim editing api routes)
- ✏️tmux-cfg (nvim editing tmux config)
- 💬tmux-rename (claude discussing tmux rename feature)
- 💬fish-tests (claude working on fish tests)
- ✅api-auth (running auth tests)
- ✅unit-db (running db unit tests)
- 🚀next-dev (next.js dev server)
- 🚀api-srv (api server running)
- 📊cpu-mem (htop monitoring)
- 📊app-logs (tailing app logs)
- 💲dotfiles (shell in dotfiles dir)
- 💲pgflow (shell in pgflow project)

Output ONLY valid JSON:
{\"name\": \"emoji-plus-name\"}"

# Call aichat and parse response
RESULT=$(echo "$CONTENT" | aichat -m openai:gpt-4o-mini --code "$PROMPT" 2>/dev/null)

# Extract name from JSON
NAME=$(echo "$RESULT" | jq -r '.name // empty' 2>/dev/null)

if [[ -z "$NAME" ]]; then
  # Restore original name on error
  tmux rename-window -t "$TARGET" "$CURRENT_NAME"
  echo "Error: Could not parse LLM response" >&2
  echo "Raw response: $RESULT" >&2
  exit 1
fi

# Rename the window
if [[ "$NAME" == "$CURRENT_NAME" ]]; then
  # Restore original (remove 🤔)
  tmux rename-window -t "$TARGET" "$CURRENT_NAME"
  echo "Window $TARGET: keeping '$NAME' (still fits)"
else
  tmux rename-window -t "$TARGET" "$NAME"
  echo "Window $TARGET: '$CURRENT_NAME' → '$NAME'"
fi
