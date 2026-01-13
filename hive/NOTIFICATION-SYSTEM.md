# Hive Notification System - Complete Implementation

## Overview

The Hive notification system provides tmux workspace-aware notifications for OpenCode sessions, with:
- Window badges: Emoji indicators (`🔐`, `💤`, `🔴`, `🔔`) on window names
- Session badges: Star emoji (`⭐`) on session names  
- Click-to-switch: Clicking notification focuses kitty terminal and switches tmux session
- Badge clearing: Automatic on window/session focus
- Modular scripts: Each component independently testable

## Architecture

### Components

| Script                      | Purpose                                                   |
| --------------------------- | --------------------------------------------------------- |
| `hive/get-context.sh`   | Returns session/window/pane IDs using `$TMUX_PANE`      |
| `hive/add-badge.sh`     | Adds emoji badge to window via ID                  |
| `hive/add-session-badge.sh` | Adds star badge to session via ID                |
| `hive/should-notify.sh` | Checks if target differs from current view      |
| `hive/clear-session-badge.sh` | Clears session badge when no windows need attention |
| `hive/clear-badge.sh` | Clears window badge on focus                     |
| `hive/scripts/notify.sh` | Orchestrates full notification flow                  |

## Flow

```
OpenCode becomes idle → event fires → notify.sh
  ├─ hive-get-context.sh (get target context)
  ├─ hive/should-notify.sh (check if should notify)
  ├─ hive/add-badge.sh (add window badge)
  └─ hive/add-session-badge.sh (add session badge)
  └─ notify-send (system notification if different session focused)

User clicks notification → focuses kitty + switches tmux
  ├─ dotool windowactivate (focus terminal)
  └─ tmux switch-client (switch to target session/window)

User focuses window → clear-badge.sh
  ├─ Strips badge from window name
  ├─ Clears @hive_window_badge option
  └─ Calls hive/clear-session-badge.sh (check session badge)

User focuses window with no badges → hive/clear-session-badge.sh
  └─ Checks all windows for @hive_window_badge
  └─ If none found, clears session badge
```

## Emoji Mappings

| Type       | Window Badge | Session Badge | Meaning           |
| ---------- | -------------- | ------------- | --------------- |
| permission | 🔐            | ⭐          | Permission needed  |
| idle       | 󰭻           | ⭐          | Waiting for input |
| error      | 🔴            | ⭐          | Error occurred   |
| activity   | 🔔            | ⭐          | General activity |

## Usage

### Trigger notification manually
```bash
~/.dotfiles/hive/scripts/notify.sh --type idle --message 'Test'
```

### Test individual components
```bash
# Get context
~/.dotfiles/hive/scripts/hive-get-context.sh

# Add window badge
~/.dotfiles/hive/scripts/hive-add-badge.sh @window_id I

# Add session badge  
~/.dotfiles/hive/scripts/hive-add-session-badge.sh $session_id

# Clear badges
~/.dotfiles/hive/scripts/clear-badge.sh
```

### View logs
```bash
tail -f ~/.cache/hive-notify.log
```

## Configuration

### Tmux

Source `hive/tmux-hive.conf` in tmux config:
```conf
source-file ~/.dotfiles/hive/tmux-hive.conf
```

This provides:
- `prefix+h`: Open spawn wizard
- `pane-focus-in` hook: Clear badges on focus

### OpenCode

Plugin symlinked to `~/.config/opencode/plugin/hive-notify.ts`:
```yaml
- link:
    ~/.config/opencode/plugin/hive-notify.ts: hive/plugin/hive-notify.ts
```

The plugin listens for `session.status` events and calls `notify.sh`.

## Files

### Core Scripts

- `hive/scripts/hive-get-context.sh` - Context retrieval
- `hive/scripts/hive-add-badge.sh` - Window badging
- `hive/scripts/hive-add-session-badge.sh` - Session badging
- `hive/scripts/hive-should-notify.sh` - Notification check
- `hive/scripts/hive-clear-session-badge.sh` - Session badge clearing
- `hive/scripts/clear-badge.sh` - Window badge clearing
- `hive/scripts/notify.sh` - Main orchestrator

### Tmux Integration

- `hive/tmux-hive.conf` - Hooks and keybindings

### OpenCode Plugin

- `hive/plugin/hive-notify.ts` - Event handler

## Features

✅ Window badges with emoji indicators (🔐💤🔴🔔)
✅ Session badges with star emoji (⭐)
✅ Click-to-switch via notify-send (kitty + tmux)
✅ Automatic badge clearing on focus
✅ ID-based precision (session/window IDs, not names)
✅ Modular testable scripts
✅ Comprehensive logging (~/.cache/hive-notify.log)
✅ Handles manual window renames (stores original name)
✅ Works across multiple tmux sessions

## Known Limitations

- System notifications only appear when viewing different session
- Requires kitty terminal (uses dotool wrapper)
- Session badge clearing requires pane-focus-in hook loaded

## Future Enhancements

- Configurable emoji per session (custom theme)
- Badge state persistence across tmux reloads
- Enhanced notification filtering
- Badge priority (multiple badges → show highest)
