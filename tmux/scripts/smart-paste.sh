#!/bin/bash
# Smart paste for tmux - reads from CLIPBOARD, falls back to PRIMARY

if [ -n "$SSH_TTY" ]; then
  # SSH: just paste from tmux buffer (use Ctrl+Shift+V for local clipboard)
  tmux paste-buffer
  exit 0
fi

# Local: try CLIPBOARD first (Ctrl+C), then PRIMARY (mouse selection)
content=$(xclip -o -sel clipboard 2>/dev/null)
if [ -z "$content" ]; then
  content=$(xclip -o -sel primary 2>/dev/null)
fi

if [ -n "$content" ]; then
  echo -n "$content" | tmux load-buffer -b sysclip - 2>/dev/null
  tmux paste-buffer -b sysclip -d
fi
