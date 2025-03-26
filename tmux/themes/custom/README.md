# Enhanced Tmux Status Line

This is a custom status line configuration for tmux that enhances the Tokyo Night theme with additional functionality and beautiful Nerd Font icons.

## Features

- Modern, clean design based on Tokyo Night color scheme
- Powerline-style carets (> and <) for segment separation
- Nerd Font icons for all status elements
- Session name display
- Window list with clear current window highlighting
- System information (CPU, RAM, battery)
- Username and hostname display
- Date and time
- Prefix key indicator
- Synchronized panes indicator

## Required Plugins

This status line uses the following tmux plugins:

- tmux-battery
- tmux-cpu
- tmux-prefix-highlight

## Requirements

- A terminal that supports True Color (24-bit color)
- A [Nerd Font](https://www.nerdfonts.com/) installed and configured in your terminal (for the icons and carets)

## Installation

1. Make sure you have TPM (Tmux Plugin Manager) installed
2. Add the plugins to your tmux.conf:
   ```
   set -g @plugin 'tmux-plugins/tmux-battery'
   set -g @plugin 'tmux-plugins/tmux-cpu'
   set -g @plugin 'tmux-plugins/tmux-prefix-highlight'
   ```
3. Install the plugins by pressing `prefix` + `I` in tmux
4. Make sure you have a Nerd Font installed and configured in your terminal

## Customization

You can customize this status line by editing the `statusline.conf` file.
