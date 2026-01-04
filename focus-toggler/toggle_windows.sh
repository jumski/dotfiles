#!/bin/bash

# Simple window toggling (no activity switching)
# Used when focus mode is set to "windows"

# Get directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source helper for smart Kitty window detection
source "$SCRIPT_DIR/find_kitty_window.sh"

# Toggle between browser and terminal
active=$(dotool getactivewindow)
browser=$(dotool search --name "Mozilla Firefox" | tail -1)
terminal=$(find_kitty_window)

echo active=$active
echo browser=$browser
echo terminal=$terminal

if [ "$active" == "$terminal" ]; then
  echo activating browser
  dotool windowactivate $browser
else
  echo activating terminal
  dotool windowactivate $terminal
fi
