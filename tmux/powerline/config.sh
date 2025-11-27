#!/usr/bin/env bash
# tmux-powerline configuration file

# General settings
export TMUX_POWERLINE_DEBUG_MODE_ENABLED="false"
export TMUX_POWERLINE_PATCHED_FONT_IN_USE="true"
export TMUX_POWERLINE_THEME="default"
export TMUX_POWERLINE_DIR_USER_THEMES="$HOME/.config/tmux-powerline/themes"
export TMUX_POWERLINE_DIR_USER_SEGMENTS="$HOME/.config/tmux-powerline/segments"

# Status bar settings
export TMUX_POWERLINE_STATUS_INTERVAL="1"
export TMUX_POWERLINE_STATUS_JUSTIFICATION="left"

# Status bar visibility
export TMUX_POWERLINE_STATUS_LEFT_LENGTH="60"
export TMUX_POWERLINE_STATUS_RIGHT_LENGTH="90"

# Session segment: show only session name (not window.pane)
export TMUX_POWERLINE_SEG_TMUX_SESSION_INFO_FORMAT="#S"
