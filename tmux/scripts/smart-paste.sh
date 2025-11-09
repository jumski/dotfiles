#!/bin/bash
# Smart paste for tmux - detects SSH and uses appropriate clipboard method

if [ -n "$SSH_TTY" ]; then
  # In SSH session: sync from terminal via OSC 52
  tmux refresh-client -l
  sleep 0.05
else
  # Local session: load from X11 clipboard
  xclip -o -sel c | tmux load-buffer -
fi

# Paste the buffer
tmux paste-buffer