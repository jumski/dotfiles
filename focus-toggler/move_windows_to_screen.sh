#!/bin/bash

# Move specific windows (Firefox, Kitty) to a target screen
# Usage: ./move_windows_to_screen.sh <target_output_name>
# Example: ./move_windows_to_screen.sh HDMI-0
# Example: ./move_windows_to_screen.sh DP-4

set -e

# Get target output name from argument
TARGET_OUTPUT="$1"

if [ -z "$TARGET_OUTPUT" ]; then
  echo "Error: No target output specified" >&2
  echo "Usage: $0 <output_name>" >&2
  echo "Example: $0 HDMI-0" >&2
  exit 1
fi

# Parse monitor geometry from xrandr
# Returns: WIDTHxHEIGHT+XOFFSET+YOFFSET
get_monitor_geometry() {
  local output_name=$1
  xrandr --query | grep "^${output_name} connected" | grep -oP '\d+x\d+\+\d+\+\d+' | head -1
}

# Extract individual components from geometry string
parse_geometry() {
  local geometry=$1
  local width=$(echo "$geometry" | cut -d'x' -f1)
  local height=$(echo "$geometry" | cut -d'x' -f2 | cut -d'+' -f1)
  local x_offset=$(echo "$geometry" | cut -d'+' -f2)
  local y_offset=$(echo "$geometry" | cut -d'+' -f3)
  echo "$width $height $x_offset $y_offset"
}

# Get target monitor geometry
TARGET_GEOM=$(get_monitor_geometry "$TARGET_OUTPUT")

if [ -z "$TARGET_GEOM" ]; then
  echo "Error: Could not find geometry for output '$TARGET_OUTPUT'" >&2
  echo "Available outputs:" >&2
  xrandr --query | grep " connected" | cut -d' ' -f1 >&2
  exit 1
fi

# Parse geometry components
read -r WIDTH HEIGHT X_OFFSET Y_OFFSET <<< $(parse_geometry "$TARGET_GEOM")

echo "Target: $TARGET_OUTPUT ($TARGET_GEOM)"
echo "  Width: $WIDTH, Height: $HEIGHT"
echo "  Offset: +$X_OFFSET+$Y_OFFSET"

# Calculate center position for windows
# We'll place windows at 10 pixels from the top-left of the target screen
TARGET_X=$((X_OFFSET + 10))
TARGET_Y=$((Y_OFFSET + 10))

# Find and move Firefox
FIREFOX_WINDOWS=$(xdotool search --class firefox 2>/dev/null || true)
if [ -n "$FIREFOX_WINDOWS" ]; then
  # Get the main Firefox window (usually the last one, which has actual dimensions)
  FIREFOX_MAIN=$(echo "$FIREFOX_WINDOWS" | tail -1)

  # Check if window has valid dimensions (not a popup/notification)
  CURRENT_GEOM=$(xdotool getwindowgeometry --shell "$FIREFOX_MAIN" | grep -E '^(WIDTH|HEIGHT)=')
  CURRENT_WIDTH=$(echo "$CURRENT_GEOM" | grep '^WIDTH=' | cut -d'=' -f2)
  CURRENT_HEIGHT=$(echo "$CURRENT_GEOM" | grep '^HEIGHT=' | cut -d'=' -f2)

  # Only move if it's a real window (not 1x1 or 10x10)
  if [ "$CURRENT_WIDTH" -gt 100 ] && [ "$CURRENT_HEIGHT" -gt 100 ]; then
    echo "Moving Firefox (window $FIREFOX_MAIN) to $TARGET_OUTPUT at $TARGET_X,$TARGET_Y"
    xdotool windowmove "$FIREFOX_MAIN" "$TARGET_X" "$TARGET_Y"
  else
    echo "Skipping Firefox window $FIREFOX_MAIN (dimensions: ${CURRENT_WIDTH}x${CURRENT_HEIGHT})"
  fi
fi

# Find and move Kitty
KITTY_WINDOWS=$(xdotool search --class kitty 2>/dev/null || true)
if [ -n "$KITTY_WINDOWS" ]; then
  # Kitty might have multiple windows, move all of them
  while IFS= read -r KITTY_WIN; do
    if [ -n "$KITTY_WIN" ]; then
      echo "Moving Kitty (window $KITTY_WIN) to $TARGET_OUTPUT at $TARGET_X,$TARGET_Y"
      xdotool windowmove "$KITTY_WIN" "$TARGET_X" "$TARGET_Y"
      # Offset subsequent windows slightly so they don't overlap completely
      TARGET_X=$((TARGET_X + 30))
      TARGET_Y=$((TARGET_Y + 30))
    fi
  done <<< "$KITTY_WINDOWS"
fi

echo "Done moving windows to $TARGET_OUTPUT"
