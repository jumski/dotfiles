#!/usr/bin/env bash
# Hostname segment - only shows on laptop (has battery)

run_segment() {
	for bat in /sys/class/power_supply/*/type; do
		if [ -r "$bat" ] && grep -q "Battery" "$bat" 2>/dev/null; then
			hostname
			return 0
		fi
	done
	return 1  # No battery = no output
}
