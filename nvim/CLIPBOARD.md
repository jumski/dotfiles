# Neovim Clipboard Integration

Clipboard configuration for Neovim running inside tmux in Kitty terminal on Linux.

## Design Philosophy

- **Vim registers are kept SEPARATE from system clipboard** - prevents external copies from overwriting vim yanks
- **`<leader>p`** pastes from system clipboard (browser Ctrl+C, etc.)
- **`"+y`** explicitly yanks to system clipboard
- **Regular `yy` / `p`** uses vim internal registers

## Clipboard Flow Matrix

### Where Content Goes (Copy Sources -> Destinations)

| Copy Source | X CLIPBOARD | X PRIMARY | tmux buffer |
|-------------|:-----------:|:---------:|:-----------:|
| **Firefox Ctrl+C** | Y | | |
| **Firefox select** | | Y | |
| **tmux yank (y)** | Y | Y | Y |
| **Kitty mouse select** | Y | | |
| **Neovim `"+y`** | Y | | Y |

### Where Each Paste Method Reads From

| Paste Method | Reads From |
|--------------|------------|
| nvim `"+p` / `<leader>p` | X CLIPBOARD (xclip), fallback to tmux buffer |
| tmux `<prefix>p` | tmux buffer |
| Ctrl+V (GUI apps) | X CLIPBOARD |
| Ctrl+Shift+V (Kitty) | X CLIPBOARD |
| Middle-click | X PRIMARY |

### Complete Compatibility Matrix

| Copy Source | nvim `"+p` | tmux `<prefix>p` | Ctrl+V (apps) | Ctrl+Shift+V (Kitty) | Middle-click |
|-------------|:----------:|:----------------:|:-------------:|:--------------------:|:------------:|
| **Firefox Ctrl+C** | Y | - | Y | Y | - |
| **Firefox select** | -* | - | - | - | Y |
| **tmux yank** | Y | Y | Y | Y | Y |
| **Kitty mouse select** | Y | - | Y | Y | - |
| **Neovim `"+y`** | Y | Y | Y | Y | - |

`*` Use `"*p` for X PRIMARY (Firefox text selection)

## Configuration

### Kitty (`~/.config/kitty/kitty.conf`)
```
clipboard_control write-clipboard write-primary read-clipboard read-primary no-append
copy_on_select clipboard
```

### tmux (`~/.dotfiles/tmux/clipboard.conf`)
```bash
set -g set-clipboard external

# Copy-mode yanks go through copy-to-clipboard.sh which populates:
# - X CLIPBOARD (via xclip)
# - X PRIMARY (via xclip)
# - System clipboard (via OSC 52)
# - tmux buffer (via copy-pipe-and-cancel)
bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel "~/.dotfiles/tmux/scripts/copy-to-clipboard.sh"
```

### Neovim

**Leader key** (`~/.dotfiles/nvim/lua/core/settings.lua`):
```lua
g.mapleader = ','
g.maplocalleader = ','
```
Note: Leader must be set before clipboard.lua loads (load order in init.lua matters).

**Clipboard provider** (`~/.dotfiles/nvim/lua/core/clipboard.lua`):
- **Copy**: Uses `tmux load-buffer -w -` (writes to tmux buffer + OSC 52)
- **Paste**: Tries xclip first (X CLIPBOARD), falls back to tmux buffer

**Key mappings**:
- `,p` (`<leader>p`) - Paste from system clipboard at cursor
- `gp` - Paste from system clipboard on new line below
- `gP` - Paste from system clipboard on new line above

## Troubleshooting

### Check what's in each clipboard
```bash
# X CLIPBOARD
xclip -o -sel clipboard

# X PRIMARY
xclip -o -sel primary

# tmux buffer
tmux save-buffer -
```

### Verify Neovim clipboard provider
```vim
:checkhealth provider.clipboard
```

### Test clipboard from within Neovim
```vim
:lua print(vim.fn.system('xclip -o -sel clipboard'))
```

### Check + register content
```vim
:echo getreg('+')
:registers +
```

### Verify mapping is loaded
```vim
:verbose map <leader>p
```
Should show mapping from `clipboard.lua`. If "No mapping found", check load order in init.lua.
