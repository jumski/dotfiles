# Kitty Configuration

## Dual Kitty Setup

This setup allows running two distinct Kitty terminal instances - one for local work and one for remote (SSH) sessions.

### Launchers

Launch via Alt+F2 (KRunner) or command line:

```bash
local-kitty   # Local terminal (class: kitty-local)
remote-kitty  # Remote terminal (class: kitty-remote)
```

Each launcher sets:
- **Window class** - for window manager identification
- **Window title** - "Local Kitty" or "Remote Kitty"
- **Environment variable** - `KITTY_INSTANCE=local` or `KITTY_INSTANCE=remote`

### Environment Variable

Inside each terminal, check which instance you're in:

```bash
echo $KITTY_INSTANCE  # prints "local" or "remote"
```

Use this in scripts or shell config to customize behavior per instance.

### Window Focus Toggle

The `toggle_window_focus` script prioritizes Kitty windows in this order:

1. `kitty-remote` (if exists)
2. `kitty-local` (if exists)
3. Any generic `kitty` window (fallback)

This means if you have both local and remote Kitty running, the toggle will always switch to the remote one.

### Typical Workflow

1. Start `local-kitty` for local work
2. Start `remote-kitty`, then `ssh pc` and `tmux attach`
3. Use `toggle_window_focus` keybind - it will prefer the remote Kitty
4. When remote Kitty is closed, toggle falls back to local Kitty

### Focus Modes

Set focus mode with `focus-mode <mode>`:

| Mode | Behavior |
|------|----------|
| `kitties` | Toggle kitty-remote ↔ kitty-local **(default)** |
| `activities` | Toggle browser ↔ terminal (with KDE activity switching) |
| `windows` | Toggle browser ↔ terminal (no activity switching) |

```bash
# Check current mode
focus-mode           # shows "kitties (default)"

# Switch to browser/terminal toggle if needed
focus-mode activities
```

### Verifying Window Classes

```bash
# Check which Kitty windows exist
dotool search --class '^kitty-local$'
dotool search --class '^kitty-remote$'
dotool search --class '^kitty$'
```
