#!/bin/bash

# System Freeze Diagnostic Script
# Run with sudo to gather comprehensive system information after a freeze

set -euo pipefail

echo "========================================="
echo "SYSTEM FREEZE DIAGNOSTIC REPORT"
echo "Generated: $(date)"
echo "========================================="
echo

# Function to print section headers
section() {
    echo
    echo "========================================="
    echo "$1"
    echo "========================================="
}

# Basic system info
section "SYSTEM INFORMATION"
uname -a
echo "Uptime: $(uptime)"
echo "Current time: $(date)"

# Get the approximate time of the last boot (to help identify the freeze time)
section "BOOT TIME INFORMATION"
journalctl --list-boots | head -5

# Journal entries from the last boot (before current) - likely where the freeze occurred
section "CRITICAL/ERROR MESSAGES FROM PREVIOUS BOOT"
journalctl -b -1 -p err --no-pager | tail -100 || echo "No previous boot found or no errors"

# Last 50 lines from previous boot (right before the freeze)
section "LAST ENTRIES BEFORE REBOOT"
journalctl -b -1 --no-pager | tail -50 || echo "No previous boot found"

# Kernel panic or oops messages
section "KERNEL PANIC/OOPS MESSAGES"
journalctl -b -1 --no-pager | grep -iE "panic|oops|bug|warning|error|fail" | tail -50 || echo "No kernel issues found"

# MCE (Machine Check Exception) errors - hardware issues
section "HARDWARE ERRORS (MCE)"
journalctl -b -1 --no-pager | grep -i mce || echo "No MCE errors found"

# GPU/Graphics related issues
section "GPU/GRAPHICS ERRORS"
journalctl -b -1 --no-pager | grep -iE "nvidia|amdgpu|i915|nouveau|drm|gpu" | grep -iE "error|fail|crash|hang" | tail -30 || echo "No GPU errors found"

# Memory issues
section "MEMORY INFORMATION"
free -h
echo
echo "Memory pressure events:"
journalctl -b -1 --no-pager | grep -iE "out of memory|oom-killer|memory pressure" | tail -20 || echo "No memory issues found"

# CPU temperature/throttling issues
section "THERMAL EVENTS"
journalctl -b -1 --no-pager | grep -iE "thermal|temperature|throttl|overheat" | tail -20 || echo "No thermal events found"

# Disk errors
section "DISK ERRORS"
journalctl -b -1 --no-pager | grep -iE "ata|sata|nvme|sda|sdb|sdc|i/o error|read error|write error" | grep -iE "error|fail" | tail -30 || echo "No disk errors found"

# Network issues (sometimes can cause system hangs)
section "NETWORK ERRORS"
journalctl -b -1 --no-pager | grep -iE "networkmanager|ethernet|wifi|wlan" | grep -iE "error|fail|timeout" | tail -20 || echo "No network errors found"

# Check dmesg for hardware issues
section "DMESG HARDWARE ERRORS"
dmesg | grep -iE "error|fail|warning|critical" | tail -50 || echo "No dmesg errors found"

# Check for segfaults
section "SEGMENTATION FAULTS"
journalctl -b -1 --no-pager | grep -i segfault | tail -20 || echo "No segfaults found"

# System load before crash
section "SYSTEM LOAD HISTORY"
journalctl -b -1 --no-pager | grep "load average" | tail -10 || echo "No load average data found"

# Check for systemd service failures
section "FAILED SERVICES"
systemctl --failed --no-pager || echo "No failed services"

# Recent package updates (might have introduced instability)
section "RECENT PACKAGE UPDATES"
grep -E "upgraded|installed" /var/log/pacman.log 2>/dev/null | tail -20 || echo "No recent package updates found"

# Check swap usage
section "SWAP INFORMATION"
swapon --show || echo "No swap configured"

# Check for ACPI errors
section "ACPI ERRORS"
journalctl -b -1 --no-pager | grep -i acpi | grep -iE "error|fail" | tail -20 || echo "No ACPI errors found"

# Summary of potential issues
section "SUMMARY"
echo "Checking for common freeze indicators..."
echo

# Count critical issues
ERROR_COUNT=$(journalctl -b -1 -p err --no-pager 2>/dev/null | wc -l || echo 0)
echo "- Total error-level messages in previous boot: $ERROR_COUNT"

# Check for specific known issues
if journalctl -b -1 --no-pager 2>/dev/null | grep -qi "gpu hang"; then
    echo "- WARNING: GPU hang detected - possible graphics driver issue"
fi

if journalctl -b -1 --no-pager 2>/dev/null | grep -qi "oom-killer"; then
    echo "- WARNING: Out of memory killer was triggered"
fi

if journalctl -b -1 --no-pager 2>/dev/null | grep -qi "thermal throttling"; then
    echo "- WARNING: CPU thermal throttling detected"
fi

if journalctl -b -1 --no-pager 2>/dev/null | grep -qi "mce:.*error"; then
    echo "- WARNING: Machine Check Exception detected - possible hardware issue"
fi

echo
echo "========================================="
echo "END OF DIAGNOSTIC REPORT"
echo "========================================="