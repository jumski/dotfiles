#!/bin/bash
# Custom file suggestion script for Claude Code
# Uses rg + fzf for reliable symlink support and fuzzy matching
# Includes .notes and .claude folders despite gitignore

# Parse JSON input to get query
QUERY=$(jq -r '.query // ""')

# Use project dir from env, fallback to pwd
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# Use rg to list files:
# --files: list files instead of searching content
# --follow: follow symlinks (critical for .notes symlink)
# --hidden: include dotfiles
# --no-ignore-vcs: ignore .gitignore (we control exclusions manually)
# --glob '!pattern': exclude specific patterns we don't want
rg --files \
  --follow \
  --hidden \
  --no-ignore-vcs \
  --glob '!.git' \
  --glob '!node_modules' \
  --glob '!*.pyc' \
  --glob '!__pycache__' \
  --glob '!.cache' \
  --glob '!dist' \
  --glob '!build' \
  --glob '!coverage' \
  --glob '!.nx' \
  "$PROJECT_DIR" 2>/dev/null | \
  fzf --filter "$QUERY" | \
  head -15
