#!/usr/bin/env bash
# Battery segment that only shows if a real battery exists

run_segment() {
	# Check if any battery exists in /sys/class/power_supply
	local has_battery=false
	for bat in /sys/class/power_supply/*/type; do
		if [ -r "$bat" ] && grep -q "Battery" "$bat" 2>/dev/null; then
			has_battery=true
			break
		fi
	done

	if [ "$has_battery" = false ]; then
		return 1  # No output, segment hidden
	fi

	# Source and run the original battery segment
	# shellcheck source=/dev/null
	source "${TMUX_POWERLINE_DIR_LIB}/lib.sh"
	# shellcheck source=/dev/null
	source "${TMUX_POWERLINE_DIR_SEGMENTS}/battery.sh"
	run_segment
}
