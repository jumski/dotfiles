#!/bin/bash

# Toggle between kitty-remote and kitty-local
# Used when focus mode is set to "kitties"

# Get directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get window IDs
active=$(dotool getactivewindow)
remote=$(dotool search --class '^kitty-remote$' 2>/dev/null | tail -1)
local_kitty=$(dotool search --class '^kitty-local$' 2>/dev/null | tail -1)

echo "active=$active"
echo "remote=$remote"
echo "local=$local_kitty"

# Toggle logic: if in remote → go to local, otherwise → go to remote
if [ "$active" == "$remote" ]; then
  if [ -n "$local_kitty" ]; then
    echo "activating local-kitty"
    dotool windowactivate "$local_kitty"
  else
    echo "no local-kitty found"
  fi
else
  if [ -n "$remote" ]; then
    echo "activating remote-kitty"
    dotool windowactivate "$remote"
  elif [ -n "$local_kitty" ]; then
    echo "activating local-kitty (no remote available)"
    dotool windowactivate "$local_kitty"
  else
    echo "no kitty windows found"
  fi
fi
