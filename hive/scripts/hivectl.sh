#!/usr/bin/env bash
# hivectl.sh - Internal CLI for hive notification management

set -euo pipefail

HIVE_NOTIFY_TS_OPTION="@hive_notify_ts"

usage() {
  echo "Usage: $0 <subcommand> [args]" >&2
  echo "Subcommands:" >&2
  echo "  notify mark   --session-id <id> --window-id <id>" >&2
  echo "  notify clear  --window-id <id>" >&2
  echo "  notify oldest" >&2
  echo "  notify newest" >&2
  exit 1
}

notify_mark() {
  local session_id=""
  local window_id=""

  while [[ $# -gt 0 ]]; do
    case $1 in
      --session-id) session_id="$2"; shift 2 ;;
      --window-id) window_id="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  if [[ -z "$session_id" || -z "$window_id" ]]; then
    echo "Error: --session-id and --window-id required" >&2
    exit 1
  fi

  local ts
  ts=$(date +%s%6N)

  tmux set-option -w -t "$session_id:$window_id" "$HIVE_NOTIFY_TS_OPTION" "$ts"
}

notify_clear() {
  local window_id=""

  while [[ $# -gt 0 ]]; do
    case $1 in
      --window-id) window_id="$2"; shift 2 ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  if [[ -z "$window_id" ]]; then
    echo "Error: --window-id required" >&2
    exit 1
  fi

  tmux set-option -w -t "$window_id" -u "$HIVE_NOTIFY_TS_OPTION"
}

notify_oldest() {
  local result
  result=$(tmux list-windows -a -F "#{session_id} #{window_id} #{@hive_notify_ts}" |
    while read -r session_id window_id ts; do
      if [[ -n "$ts" ]]; then
        echo "$ts $session_id $window_id"
      fi
    done |
    sort -n |
    head -n1 |
    awk '{print $2, $3}')

  if [[ -n "$result" ]]; then
    echo "$result"
    exit 0
  else
    exit 1
  fi
}

notify_newest() {
  local result
  result=$(tmux list-windows -a -F "#{session_id} #{window_id} #{@hive_notify_ts}" |
    while read -r session_id window_id ts; do
      if [[ -n "$ts" ]]; then
        echo "$ts $session_id $window_id"
      fi
    done |
    sort -rn |
    head -n1 |
    awk '{print $2, $3}')

  if [[ -n "$result" ]]; then
    echo "$result"
    exit 0
  else
    exit 1
  fi
}

if [[ $# -eq 0 ]]; then
  usage
fi

subcommand="$1"
shift

case "$subcommand" in
  notify)
    if [[ $# -eq 0 ]]; then
      usage
    fi
    notify_sub="$1"
    shift
    case "$notify_sub" in
      mark) notify_mark "$@" ;;
      clear) notify_clear "$@" ;;
      oldest) notify_oldest ;;
      newest) notify_newest ;;
      *) echo "Unknown notify subcommand: $notify_sub" >&2; exit 1 ;;
    esac
    ;;
  *) echo "Unknown subcommand: $subcommand" >&2; exit 1 ;;
esac
