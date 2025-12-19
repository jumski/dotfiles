#!/bin/bash
# Custom file suggestion script for Claude Code
# Includes .notes and .claude folders despite gitignore

# Parse JSON input to get query
QUERY=$(jq -r '.query // ""')

# Use project dir from env, fallback to pwd
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

{
  # 1. Main search (respects gitignore, includes hidden files)
  fd --type f --hidden --color never "$QUERY" "$PROJECT_DIR" 2>/dev/null

  # 2. Explicit search in .notes (ignore gitignore)
  if [ -d "$PROJECT_DIR/.notes" ]; then
    fd --type f --hidden --no-ignore --color never "$QUERY" "$PROJECT_DIR/.notes" 2>/dev/null
  fi

  # 3. Explicit search in .claude (ignore gitignore)
  if [ -d "$PROJECT_DIR/.claude" ]; then
    fd --type f --hidden --no-ignore --color never "$QUERY" "$PROJECT_DIR/.claude" 2>/dev/null
  fi
} | sort -u | head -15
