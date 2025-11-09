# Tmux Clipboard Scripts

These scripts provide smart clipboard integration for tmux that works both locally and over SSH.

## Scripts

### `smart-paste.sh`
Intelligently pastes from the system clipboard:
- **Local**: Reads from X11 clipboard via `xclip`
- **SSH**: Syncs via OSC 52 using `tmux refresh-client -l`

### `copy-to-clipboard.sh`
Copies to clipboard with dual strategy:
- Always copies to X11 clipboard locally
- Also sends OSC 52 sequence when in SSH or using kitty
- Ensures copy works both locally and remotely

## How It Works

```
Local:  tmux → xclip → X11 clipboard
SSH:    tmux → OSC 52 → terminal → local clipboard
```

## Key Bindings

- `prefix + p` - Smart paste
- `M-i` - Smart paste (no prefix)
- `y` (in copy mode) - Copy selection
- Mouse drag + release - Copy selection

## Requirements

- tmux 3.3a+ (for `allow-passthrough on`)
- OSC 52 compatible terminal (kitty, foot, iterm2, etc.)
- `xclip` installed locally
- Neovim with OSC 52 support (0.10+)

## Troubleshooting

1. **Paste not working over SSH**: Ensure `allow-passthrough on` is set in tmux
2. **Kitty prompts for clipboard**: Set `clipboard_control read-clipboard` in kitty.conf
3. **Old clipboard content**: Scripts now always sync before paste