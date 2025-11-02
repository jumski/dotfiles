#!/bin/bash

# Simple window toggling (no activity switching)
# Used when focus mode is set to "windows"

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
