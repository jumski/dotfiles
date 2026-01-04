#!/bin/bash
# Find the best Kitty window to target
# Priority: kitty-remote > kitty-local > any kitty

find_kitty_window() {
  local remote=$(dotool search --class '^kitty-remote$' 2>/dev/null | tail -1)
  local local_kitty=$(dotool search --class '^kitty-local$' 2>/dev/null | tail -1)
  local any_kitty=$(dotool search --class '^kitty$' 2>/dev/null | tail -1)

  if [ -n "$remote" ]; then
    echo "$remote"
  elif [ -n "$local_kitty" ]; then
    echo "$local_kitty"
  else
    echo "$any_kitty"
  fi
}
