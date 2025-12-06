#!/bin/bash
# Smart paste for tmux - reads from CLIPBOARD, falls back to PRIMARY

if [ -n "$SSH_TTY" ]; then
  # SSH: try to sync clipboard via OSC 52, then paste from tmux buffer
  tmux refresh-client -l
  sleep 0.05
  tmux paste-buffer 2>/dev/null || true
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
else
  # Fallback: paste from existing tmux buffer if no X11 content
  tmux paste-buffer 2>/dev/null || true
fi
