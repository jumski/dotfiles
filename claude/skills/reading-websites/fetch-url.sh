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

curl -sS "https://r.jina.ai/${URL}" | head -c "$LIMIT"
