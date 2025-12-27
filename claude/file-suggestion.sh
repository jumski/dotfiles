#!/bin/bash
# Custom file suggestion script for Claude Code
# Uses fd + fzf for fuzzy matching with directory support
# Prioritizes direct matches (where query matches last path component)

# Parse JSON input to get query
QUERY=$(jq -r '.query // ""')

# Use project dir from env, fallback to pwd
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# cd into project dir so fd outputs relative paths
cd "$PROJECT_DIR" || exit 1

# Escape special regex characters in query
ESCAPED_QUERY=$(printf '%s' "$QUERY" | sed 's/[.[\*^$()+?{|\\]/\\&/g')

# Collect all files and directories
get_all_entries() {
  {
    # Main search - respects .gitignore, includes hidden files, follows symlinks
    fd --type f --type d --follow --hidden . 2>/dev/null

    # Additional paths - include even if gitignored
    [ -e .claude ] && fd --type f --type d --follow --hidden --no-ignore-vcs . .claude 2>/dev/null
    [ -e .notes ] && fd --type f --type d --follow --hidden --no-ignore-vcs . .notes 2>/dev/null
  } | sort -u
}

# If no query, just list entries
if [ -z "$QUERY" ]; then
  get_all_entries | head -15
  exit 0
fi

ALL=$(get_all_entries)

# Direct matches: query matches the last path component (filename or dirname)
# Regex: matches "query" at end of path, optionally followed by extension or slash
DIRECT=$(echo "$ALL" | grep -iE "(^|/)${ESCAPED_QUERY}[^/]*/?$" 2>/dev/null)
DIRECT_COUNT=$(echo "$DIRECT" | grep -c .)

# Fuzzy matches: everything else through fzf
REMAINING=$((15 - DIRECT_COUNT))
if [ "$REMAINING" -lt 0 ]; then
  REMAINING=0
fi

if [ -n "$DIRECT" ] && [ "$REMAINING" -gt 0 ]; then
  # Exclude direct matches from fuzzy results (use -f to read patterns from stdin)
  FUZZY=$(echo "$ALL" | fzf --filter "$QUERY" 2>/dev/null | grep -vxFf <(echo "$DIRECT") | head -"$REMAINING")
elif [ -z "$DIRECT" ]; then
  FUZZY=$(echo "$ALL" | fzf --filter "$QUERY" 2>/dev/null | head -15)
else
  FUZZY=""
fi

# Output direct matches first, then fuzzy matches
{
  [ -n "$DIRECT" ] && echo "$DIRECT"
  [ -n "$FUZZY" ] && echo "$FUZZY"
} | head -15
