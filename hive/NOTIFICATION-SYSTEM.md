# Hive Notification System - Complete Implementation

## Overview

The Hive notification system provides tmux workspace-aware notifications for OpenCode sessions, with:
- Window badges: `🔔` emoji indicator on window names
- Session badges: `🔔` emoji indicator on session names  
- Click-to-switch: Clicking notification focuses kitty terminal and switches tmux session
- Badge clearing: Automatic on window/session focus
- Modular scripts: Each component independently testable
- **All tmux sessions supported**: No opt-in required, badges work in any tmux session

## Architecture

### Components

| Script                          | Purpose                                                   |
| ------------------------------- | --------------------------------------------------------- |
| `badge-config.sh`               | Shared config: `HIVE_BADGE="🔔"`                          |
| `hive-get-context.sh`           | Returns session/window/pane IDs using `$TMUX_PANE`       |
| `hive-add-badge.sh`             | Adds `🔔` badge to window name if not already present     |
| `hive-add-session-badge.sh`     | Adds `🔔` badge to session name if not already present    |
| `hive-should-notify.sh`         | Checks if target differs from current view               |
| `hive-clear-session-badge.sh`   | Clears session badge when no windows need attention      |
| `clear-badge.sh`                | Clears window badge by stripping `🔔` prefix               |
| `notify.sh`                     | Orchestrates full notification flow                      |

## Flow

```
OpenCode becomes idle → event fires → notify.sh
  ├─ hive-get-context.sh (get target context)
  ├─ hive-should-notify.sh (check if should notify)
  ├─ hive-add-badge.sh (prepend 🔔 to window name if missing)
  └─ hive-add-session-badge.sh (prepend 🔔 to session name if missing)
  └─ notify-send (system notification if different session focused)

User clicks notification → focuses kitty + switches tmux
  ├─ dotool windowactivate (focus terminal)
  └─ tmux switch-client (switch to target session/window)

User focuses window → clear-badge.sh
  ├─ Strips 🔔 prefix from window name if present
  └─ Calls hive-clear-session-badge.sh (check session badge)

User focuses window with no badges → hive-clear-session-badge.sh
  └─ Checks all windows for 🔔 prefix
  └─ If none found, strips 🔔 prefix from session name
```

## Badge Configuration

The badge emoji is defined in a single location for easy customization:

**`hive/scripts/badge-config.sh`**
```bash
export HIVE_BADGE="🔔"
```

All scripts source this file to reference the badge emoji. Change it once to update the entire system.

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
~/.dotfiles/hive/scripts/hive-add-badge.sh @window_id

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
- Focus hooks: Clear badges on focus (after-select-pane, after-select-window, client-session-changed)

### OpenCode

Plugin symlinked to `~/.config/opencode/plugin/hive-notify.ts`:
```yaml
- link:
    ~/.config/opencode/plugin/hive-notify.ts: hive/plugin/hive-notify.ts
```

The plugin listens for `session.status` events and calls `notify.sh`.

## Files

### Core Scripts

- `hive/scripts/badge-config.sh` - Badge emoji configuration
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

✅ Single badge emoji (🔔) for all notification types
✅ ID-based precision (session/window IDs, not names)
✅ Modular testable scripts
✅ Comprehensive logging (~/.cache/hive-notify.log)
✅ Works across multiple tmux sessions
✅ **Works in any tmux session** - no opt-in required
✅ Simple prefix-based badge clearing (no state tracking)

## Implementation Notes

The simplified badge system uses a prefix-based approach:

- **Adding badge**: Prepend `🔔 ` to window/session name if not already present
- **Clearing badge**: Strip `🔔 ` prefix from name if present
- **Session clearing**: Check if any window still has badge; if not, strip from session name

This approach eliminates:
- State tracking via tmux options (`@hive_window_badge`, `@hive_window_original_name`, etc.)
- Complex sync logic for manual renames
- Race conditions between badge addition and rename hooks
- Need for different badge types per notification category

## Known Limitations

- System notifications only appear when viewing different session
- Requires kitty terminal (uses dotool wrapper)

## Future Enhancements

- Configurable emoji per session (edit badge-config.sh)
- Enhanced notification filtering
- Badge priority (currently ignored - all use same emoji)
