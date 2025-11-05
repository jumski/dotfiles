# Focus Toggler

A dual-mode window focus system that adapts to different desk setups.

## Modes

### Activities Mode (default)
Toggles between KDE activities AND windows:
- Browser → switches to "browsing" activity + activates Firefox
- Terminal → switches to "coding" activity + activates Kitty
- Windows automatically moved to primary screen (DP-4) and **unmaximized** (for tiling WM)

### Windows Mode
Simple window toggling without activity switching:
- Browser ↔ Terminal (Firefox ↔ Kitty)
- No KDE activity changes
- Windows automatically moved to secondary screen (HDMI-0) and **maximized**

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

- **Activities mode**: Full desktop setup with multiple monitors - windows on primary screen (DP-4)
- **Windows mode**: Small monitor setup where activity switching isn't needed - windows on secondary screen (HDMI-0)

The mode persists across reboots to match your physical configuration.

### Multi-Screen Support

The system automatically moves Firefox, Kitty, and Logseq windows between screens when switching modes:
- **Activities mode**: Windows moved to DP-4 (5120x1440 ultrawide primary) and **unmaximized** for tiling WM
- **Windows mode**: Windows moved to HDMI-0 (1920x1080 secondary) and **maximized**

Window positions are calculated dynamically using xrandr, so they'll work even if you rearrange your monitor layout.

**Technical detail**: The script unmaximizes windows before moving them (maximized windows can't be moved in most WMs), then re-maximizes if needed for the target screen.

## Files

- `bin/toggle_window_focus` - Main wrapper (reads mode, dispatches)
- `focus-toggler/toggle_activities.sh` - Activities + windows implementation
- `focus-toggler/toggle_windows.sh` - Windows-only implementation
- `focus-toggler/move_windows_to_screen.sh` - Multi-screen window positioning
- `focus-toggler/functions/focus-mode.fish` - Mode management function
- `focus-toggler/completions.fish` - Tab completion for focus-mode

## Future Extensibility

The "windows" mode can be extended to support configurable window sets without changing the core mode system.
