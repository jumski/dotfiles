#!/bin/bash

# Simple window toggling (no activity switching)
# Used when focus mode is set to "windows"

# Toggle between browser and terminal
active=$(dotool getactivewindow)
browser=$(dotool search --name "Mozilla Firefox" | tail -1)
terminal=$(dotool search --classname "Kitty" | tail -1)

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
