#!/bin/bash
# Copy to clipboard - works local and SSH

input=$(cat)

# Always send OSC 52 (works over SSH too)
printf "\033]52;c;%s\007" "$(echo -n "$input" | base64 -w0)"

# Also xclip locally (to both selections, fix stdout bug with redirection)
if [ -z "$SSH_TTY" ]; then
  echo -n "$input" | xclip -i -sel clipboard >/dev/null 2>&1
  echo -n "$input" | xclip -i -sel primary >/dev/null 2>&1
fi
