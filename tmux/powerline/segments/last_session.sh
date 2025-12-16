#!/usr/bin/env bash
# Last session segment - shows previously selected session (less prominent)

run_segment() {
	local last_session
	last_session=$(tmux display-message -p '#{client_last_session}' 2>/dev/null)

	if [ -n "$last_session" ]; then
		echo "$last_session"
		return 0
	fi
	return 1  # No last session = no output
}
