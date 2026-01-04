#!/bin/bash

# Move specific windows (Firefox, Kitty, Logseq) to a target screen
# Usage: ./move_windows_to_screen.sh <target_output_name> [--maximize|--unmaximize]
# Example: ./move_windows_to_screen.sh HDMI-0 --maximize
# Example: ./move_windows_to_screen.sh DP-4 --unmaximize

set -e

# Get target output name from argument
TARGET_OUTPUT="$1"
MAXIMIZE_MODE="$2"

if [ -z "$TARGET_OUTPUT" ]; then
  echo "Error: No target output specified" >&2
  echo "Usage: $0 <output_name> [--maximize|--unmaximize]" >&2
  echo "Example: $0 HDMI-0 --maximize" >&2
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
FIREFOX_WINDOWS=$(dotool search --class firefox 2>/dev/null || true)
if [ -n "$FIREFOX_WINDOWS" ]; then
  # Get the main Firefox window (usually the last one, which has actual dimensions)
  FIREFOX_MAIN=$(echo "$FIREFOX_WINDOWS" | tail -1)

  # Check if window has valid dimensions (not a popup/notification)
  CURRENT_GEOM=$(dotool getwindowgeometry --shell "$FIREFOX_MAIN" | grep -E '^(WIDTH|HEIGHT)=')
  CURRENT_WIDTH=$(echo "$CURRENT_GEOM" | grep '^WIDTH=' | cut -d'=' -f2)
  CURRENT_HEIGHT=$(echo "$CURRENT_GEOM" | grep '^HEIGHT=' | cut -d'=' -f2)

  # Only move if it's a real window (not 1x1 or 10x10)
  if [ "$CURRENT_WIDTH" -gt 100 ] && [ "$CURRENT_HEIGHT" -gt 100 ]; then
    echo "Moving Firefox (window $FIREFOX_MAIN) to $TARGET_OUTPUT at $TARGET_X,$TARGET_Y"

    # Unmaximize first to allow movement
    dotool windowstate --remove MAXIMIZED_VERT --remove MAXIMIZED_HORZ "$FIREFOX_MAIN"

    # Move window
    dotool windowmove "$FIREFOX_MAIN" "$TARGET_X" "$TARGET_Y"

    # Handle maximization based on mode
    if [ "$MAXIMIZE_MODE" = "--maximize" ]; then
      echo "  Maximizing Firefox window"
      # Small delay to let WM register the window position before maximizing
      sleep 0.1
      dotool windowstate --add MAXIMIZED_VERT --add MAXIMIZED_HORZ "$FIREFOX_MAIN"
    fi
  else
    echo "Skipping Firefox window $FIREFOX_MAIN (dimensions: ${CURRENT_WIDTH}x${CURRENT_HEIGHT})"
  fi
fi

# Find and move Kitty (all variants: kitty-remote, kitty-local, generic kitty)
KITTY_WINDOWS=$(
  { dotool search --class '^kitty-remote$' 2>/dev/null
    dotool search --class '^kitty-local$' 2>/dev/null
    dotool search --class '^kitty$' 2>/dev/null
  } | sort -u
)
if [ -n "$KITTY_WINDOWS" ]; then
  # Kitty might have multiple windows, move all of them
  while IFS= read -r KITTY_WIN; do
    if [ -n "$KITTY_WIN" ]; then
      echo "Moving Kitty (window $KITTY_WIN) to $TARGET_OUTPUT at $TARGET_X,$TARGET_Y"

      # Unmaximize first to allow movement
      dotool windowstate --remove MAXIMIZED_VERT --remove MAXIMIZED_HORZ "$KITTY_WIN"

      # Move window
      dotool windowmove "$KITTY_WIN" "$TARGET_X" "$TARGET_Y"

      # Handle maximization based on mode
      if [ "$MAXIMIZE_MODE" = "--maximize" ]; then
        echo "  Maximizing Kitty window"
        # Small delay to let WM register the window position before maximizing
        sleep 0.1
        dotool windowstate --add MAXIMIZED_VERT --add MAXIMIZED_HORZ "$KITTY_WIN"
      fi
      # Offset subsequent windows slightly so they don't overlap completely
      TARGET_X=$((TARGET_X + 30))
      TARGET_Y=$((TARGET_Y + 30))
    fi
  done <<< "$KITTY_WINDOWS"
fi

# Find and move Logseq
LOGSEQ_WINDOWS=$(dotool search --class logseq 2>/dev/null || true)
if [ -n "$LOGSEQ_WINDOWS" ]; then
  # Get the main Logseq window (usually the last one, which has actual dimensions)
  LOGSEQ_MAIN=$(echo "$LOGSEQ_WINDOWS" | tail -1)

  # Check if window has valid dimensions (not a popup/notification)
  CURRENT_GEOM=$(dotool getwindowgeometry --shell "$LOGSEQ_MAIN" | grep -E '^(WIDTH|HEIGHT)=')
  CURRENT_WIDTH=$(echo "$CURRENT_GEOM" | grep '^WIDTH=' | cut -d'=' -f2)
  CURRENT_HEIGHT=$(echo "$CURRENT_GEOM" | grep '^HEIGHT=' | cut -d'=' -f2)

  # Only move if it's a real window (not 1x1 or 10x10)
  if [ "$CURRENT_WIDTH" -gt 100 ] && [ "$CURRENT_HEIGHT" -gt 100 ]; then
    echo "Moving Logseq (window $LOGSEQ_MAIN) to $TARGET_OUTPUT at $TARGET_X,$TARGET_Y"

    # Unmaximize first to allow movement
    dotool windowstate --remove MAXIMIZED_VERT --remove MAXIMIZED_HORZ "$LOGSEQ_MAIN"

    # Move window
    dotool windowmove "$LOGSEQ_MAIN" "$TARGET_X" "$TARGET_Y"

    # Handle maximization based on mode
    if [ "$MAXIMIZE_MODE" = "--maximize" ]; then
      echo "  Maximizing Logseq window"
      # Small delay to let WM register the window position before maximizing
      sleep 0.1
      dotool windowstate --add MAXIMIZED_VERT --add MAXIMIZED_HORZ "$LOGSEQ_MAIN"
    fi
  else
    echo "Skipping Logseq window $LOGSEQ_MAIN (dimensions: ${CURRENT_WIDTH}x${CURRENT_HEIGHT})"
  fi
fi

echo "Done moving windows to $TARGET_OUTPUT"
