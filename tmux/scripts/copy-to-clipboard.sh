#!/bin/bash
# Copy to clipboard - works both locally and over SSH

# Read from stdin
input=$(cat)

# Always copy to X11 clipboard locally
echo -n "$input" | xclip -i -sel c

# If we have OSC 52 support (kitty, modern terminals), also send via OSC 52
# This ensures copy works over SSH
if [ -n "$SSH_TTY" ] || [ -n "$KITTY_WINDOW_ID" ]; then
  # Send OSC 52 sequence to terminal
  printf "\033]52;c;%s\007" "$(echo -n "$input" | base64 -w0)"
fi