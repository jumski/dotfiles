#!/bin/bash

# Activities + window toggling
# Used when focus mode is set to "activities"

# Configuration
PRIMARY_SCREEN="DP-4"    # 4K ultrawide
SECONDARY_SCREEN="HDMI-0" # Full HD secondary

# Get directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure windows are on the primary screen for activities mode
"$SCRIPT_DIR/move_windows_to_screen.sh" "$PRIMARY_SCREEN" > /dev/null 2>&1

# Toggle between browser and terminal
active=$(xdotool getactivewindow)
browser=$(xdotool search --name "Mozilla Firefox" | tail -1)
terminal=$(xdotool search --classname "Kitty" | tail -1)

echo active=$active
echo browser=$browser
echo terminal=$terminal

function maybe_switch_activity() {
  local activity="$1"
  local current_hostname="$(hostname)"

  if [ "$current_hostname" == "pc" ] || [ "$current_hostname" == "laptop" ]; then
    echo "Switching to activity: $activity on $current_hostname"
    "$SCRIPT_DIR/switch_to_kde_activity.sh" "$activity"
  else
    echo "Not on 'pc' or 'laptop' host, skipping activity switch"
  fi
}

if [ "$active" == "$terminal" ]; then
  echo activating browser
  maybe_switch_activity "browsing"
  xdotool windowactivate $browser
else
  echo activating terminal
  maybe_switch_activity "coding"
  xdotool windowactivate $terminal
fi
