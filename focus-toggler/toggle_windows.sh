#!/bin/bash

# Simple window toggling (no activity switching)
# Used when focus mode is set to "windows"

# Configuration
PRIMARY_SCREEN="DP-4"    # 4K ultrawide
SECONDARY_SCREEN="HDMI-0" # Full HD secondary

# Get directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure windows are on the secondary screen for windows mode (maximized)
"$SCRIPT_DIR/move_windows_to_screen.sh" "$SECONDARY_SCREEN" --maximize > /dev/null 2>&1

# Toggle between browser and terminal
active=$(xdotool getactivewindow)
browser=$(xdotool search --name "Mozilla Firefox" | tail -1)
terminal=$(xdotool search --classname "Kitty" | tail -1)

echo active=$active
echo browser=$browser
echo terminal=$terminal

if [ "$active" == "$terminal" ]; then
  echo activating browser
  xdotool windowactivate $browser
else
  echo activating terminal
  xdotool windowactivate $terminal
fi
