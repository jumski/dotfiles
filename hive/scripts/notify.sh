#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/badge-config.sh"

LOG_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/hive-notify.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

usage() {
  echo "Usage: $0 --type <type> --message <message>" >&2
  exit 1
}

TYPE=""
MESSAGE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)
      TYPE="$2"
      shift 2
      ;;
    --message)
      MESSAGE="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z "$TYPE" ] || [ -z "$MESSAGE" ]; then
  usage
fi

log "NOTIFY type=$TYPE message=$MESSAGE pane=$TMUX_PANE"

TARGET_CONTEXT=$("$SCRIPT_DIR/hive-get-context.sh")
TARGET_SESSION=$(echo "$TARGET_CONTEXT" | cut -d':' -f4)
TARGET_WINDOW=$(echo "$TARGET_CONTEXT" | cut -d':' -f5)

if ! "$SCRIPT_DIR/hive-should-notify.sh" "$TARGET_SESSION" "$TARGET_WINDOW"; then
  log "SKIP: Target is focused"
  exit 0
fi

"$SCRIPT_DIR/hive-add-badge.sh" "$TARGET_WINDOW"
"$SCRIPT_DIR/hive-add-session-badge.sh" "$TARGET_SESSION"

log "NOTIFIED session=$TARGET_SESSION window=$TARGET_WINDOW badge=$HIVE_BADGE"

if command -v notify-send &> /dev/null; then
  notify-send "$HIVE_BADGE $MESSAGE"
fi
