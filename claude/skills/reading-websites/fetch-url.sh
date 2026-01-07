#!/bin/bash
# Fetch URL content as markdown via Jina Reader API
# Usage: fetch-url.sh <url> [char_limit]

set -euo pipefail

URL="${1:-}"
LIMIT="${2:-512}"

if [[ -z "$URL" ]]; then
  echo "Usage: fetch-url.sh <url> [char_limit]" >&2
  echo "  url        - Full URL including protocol (https://example.com)" >&2
  echo "  char_limit - Max characters to return (default: 512)" >&2
  exit 1
fi

if ! [[ "$LIMIT" =~ ^[0-9]+$ ]]; then
  echo "Error: char_limit must be a number" >&2
  exit 1
fi

CURL_ARGS=(-sS)
if [[ -n "${JINA_API_KEY:-}" ]]; then
  CURL_ARGS+=(-H "Authorization: Bearer ${JINA_API_KEY}")
fi

# Capture output - exit 23 (broken pipe) is expected when head closes early
# Real errors have different exit codes (6=dns fail, 7=connect fail, etc.)
output=$(curl "${CURL_ARGS[@]}" "https://r.jina.ai/${URL}" 2>&1) || true
# Truncate to limit, ignoring SIGPIPE from head closing early
printf '%s' "$output" | head -c "$LIMIT" || true
