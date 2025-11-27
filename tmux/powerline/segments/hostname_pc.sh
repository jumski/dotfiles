#!/usr/bin/env bash
# Hostname segment - only shows on PC (no battery)

run_segment() {
	for bat in /sys/class/power_supply/*/type; do
		if [ -r "$bat" ] && grep -q "Battery" "$bat" 2>/dev/null; then
			return 1  # Has battery = laptop, no output
		fi
	done
	hostname
	return 0
}
