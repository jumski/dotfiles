#!/bin/bash
# Simple wrapper for tmux left status line
if /home/jumski/.dotfiles/todoist-helper/bin/urgent-status.sh >/dev/null 2>&1; then
    echo "" # No urgent tasks
else
    # Medium red background with white text
    echo "#[bg=#CC0000,fg=#FFFFFF,bold] TODO #[default] "
fi