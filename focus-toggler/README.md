# Focus Toggler

A dual-mode window focus system that adapts to different desk setups.

## Modes

### Activities Mode (default)
Toggles between KDE activities AND windows:
- Browser → switches to "browsing" activity + activates Firefox
- Terminal → switches to "coding" activity + activates Kitty

### Windows Mode
Simple window toggling without activity switching:
- Browser ↔ Terminal (Firefox ↔ Kitty)
- No KDE activity changes

## Usage

### Toggling Focus
Use the global keyboard shortcut bound to:
```bash
~/bin/toggle_window_focus
```

The script automatically uses the current mode.

### Managing Modes

Using Fish function:
```fish
focus-mode                # Show current mode
focus-mode activities     # Switch to activities mode
focus-mode windows        # Switch to windows mode
```

## Configuration

Mode state persists in: `~/.config/window-focus-mode`

**Default:** `activities` (if file doesn't exist)

## Why Two Modes?

Different physical desk setups require different behavior:

- **Activities mode**: Full desktop setup with multiple monitors
- **Windows mode**: Small monitor setup where activity switching isn't needed

The mode persists across reboots to match your physical configuration.

## Files

- `bin/toggle_window_focus` - Main wrapper (reads mode, dispatches)
- `focus-toggler/toggle_activities.sh` - Activities + windows implementation
- `focus-toggler/toggle_windows.sh` - Windows-only implementation
- `focus-toggler/functions/focus-mode.fish` - Mode management function
- `focus-toggler/completions.fish` - Tab completion for focus-mode

## Future Extensibility

The "windows" mode can be extended to support configurable window sets without changing the core mode system.
