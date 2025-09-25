#!/bin/bash

# Screen Flicker Diagnostic Script
# Investigates graphics/display issues

set -euo pipefail

echo "========================================="
echo "SCREEN FLICKER DIAGNOSTIC REPORT"
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

# Display server info
section "DISPLAY SERVER"
echo "Display Server: $XDG_SESSION_TYPE"
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    echo "X11 Version: $(xdpyinfo | grep "X.Org version" 2>/dev/null || echo "unknown")"
fi
echo "Desktop Environment: $XDG_CURRENT_DESKTOP"
echo "Session: $DESKTOP_SESSION"

# Graphics hardware
section "GRAPHICS HARDWARE"
lspci | grep -E "VGA|3D|Display" || echo "No graphics devices found"

# Current driver info
section "NVIDIA DRIVER INFO"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,driver_version,vbios_version --format=csv
    echo
    echo "Module info:"
    lsmod | grep -E "nvidia|nouveau" || echo "No NVIDIA modules loaded"
else
    echo "nvidia-smi not found - checking for nouveau:"
    lsmod | grep nouveau || echo "No nouveau driver loaded"
fi

# Check for NVIDIA/graphics errors in recent logs (last hour)
section "RECENT GRAPHICS ERRORS (Last Hour)"
journalctl --since "1 hour ago" --no-pager | grep -iE "nvidia|nouveau|drm|gpu|display|xorg|x11" | grep -iE "error|fail|warning|flicker|tear|corruption|artifact" | tail -50 || echo "No recent graphics errors"

# Check Xorg logs
section "XORG LOG ERRORS"
if [ -f /var/log/Xorg.0.log ]; then
    grep -iE "error|warning|fail|EE|WW" /var/log/Xorg.0.log | tail -30 || echo "No Xorg errors found"
else
    echo "Xorg.0.log not found"
fi

# Monitor configuration
section "MONITOR CONFIGURATION"
xrandr --verbose 2>/dev/null | head -50 || echo "xrandr not available"

# Compositor info
section "COMPOSITOR"
if pgrep -x picom > /dev/null; then
    echo "Picom is running"
    ps aux | grep picom | grep -v grep
elif pgrep -x compton > /dev/null; then
    echo "Compton is running"
    ps aux | grep compton | grep -v grep
elif pgrep -x kwin > /dev/null; then
    echo "KWin is running"
    ps aux | grep kwin | grep -v grep
else
    echo "No common compositor detected"
fi

# Check for screen tearing/vsync issues
section "VSYNC/TEARING PREVENTION"
if [ -f /etc/X11/xorg.conf.d/20-nvidia.conf ]; then
    echo "NVIDIA X11 Config:"
    cat /etc/X11/xorg.conf.d/20-nvidia.conf
elif [ -f /etc/X11/xorg.conf ]; then
    echo "Xorg Config (NVIDIA section):"
    grep -A 20 -i nvidia /etc/X11/xorg.conf 2>/dev/null || echo "No NVIDIA section found"
else
    echo "No NVIDIA X11 configuration found"
fi

# Check NVIDIA settings
section "NVIDIA SETTINGS"
if command -v nvidia-settings &> /dev/null; then
    echo "Checking ForceCompositionPipeline:"
    nvidia-settings -q CurrentMetaMode 2>/dev/null | grep -i composition || echo "Could not query composition pipeline"
    echo
    echo "Sync to VBlank setting:"
    nvidia-settings -q SyncToVBlank 2>/dev/null || echo "Could not query VSync setting"
fi

# Memory usage (VRAM)
section "VIDEO MEMORY USAGE"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=memory.used,memory.free,memory.total --format=csv
else
    echo "nvidia-smi not available"
fi

# Recent display-related kernel messages
section "RECENT DISPLAY KERNEL MESSAGES"
dmesg | grep -iE "nvidia|drm|display|hdmi|dp|vga|edid|modeset" | tail -30

# Check for power management issues
section "POWER MANAGEMENT"
if command -v nvidia-smi &> /dev/null; then
    echo "NVIDIA Power Mode:"
    nvidia-smi -q -d POWER | grep -E "Power Mode|Performance State" || echo "Could not query power mode"
fi

# Summary
section "POTENTIAL ISSUES"
echo "Common causes of screen flickering:"
echo
echo "1. NVIDIA ForceCompositionPipeline not enabled (most common)"
echo "   Fix: nvidia-settings -> X Server Display Configuration -> Advanced -> Force Composition Pipeline"
echo
echo "2. Conflicting compositor settings"
echo "   Fix: Disable compositor or adjust vsync settings"
echo
echo "3. Incorrect refresh rate"
echo "   Current refresh rates:"
xrandr 2>/dev/null | grep -E "\*" | awk '{print "   - " $1 " @ " $2}'
echo
echo "4. Power management causing GPU clock changes"
echo "   Fix: Set to 'Prefer Maximum Performance' in nvidia-settings"
echo
echo "5. Cable issues (especially DisplayPort)"
echo "   Try: Different cable or HDMI instead of DP"

echo
echo "========================================="
echo "END OF DIAGNOSTIC REPORT"
echo "========================================="