# Claude Code + Neovim Hybrid Setup - Manual Steps

## What Was Done

✅ **Integration guide**: `claude/neovim-integration.md` - comprehensive documentation  
✅ **Plugin configuration**: `nvim/lua/plugins/claudecode.lua` - coder/claudecode.nvim setup  
✅ **Wrapper scripts**: `bin/claude-status` and `fish/functions/claude-hybrid.fish` - automatic env var management  
✅ **Tmux keybindings**: Added `C-q C` (popup) and `M-C` (new window) for Claude  

## Manual Steps Required

### 1. Install the Plugin

Since lazy.nvim auto-detects plugins, restart Neovim or run:

```vim
:Lazy sync
```

The plugin should install automatically from the `nvim/lua/plugins/claudecode.lua` file.

### 2. Reload Shell Configuration

For the `claude-hybrid` fish function to work:

```bash
# Reload fish functions
exec fish

# Or source the function manually
source ~/.dotfiles/fish/functions/claude-hybrid.fish
```

### 3. Reload Tmux Configuration

```bash
# In tmux session
tmux source-file ~/.tmux.conf
```

### 4. Test the Integration

**Basic test**:
```bash
# Check scripts are working
claude-status
which claude-hybrid
```

**Full integration test**:

1. **Start Neovim in a project**:
   ```vim
   :ClaudeCode
   ```
   You should see: "WebSocket server started on port XXXXX"

2. **In another tmux window**:
   ```bash
   claude-hybrid --continue
   ```
   You should see: "🔗 Connecting to Neovim WebSocket on port XXXXX"

3. **Test visual selection**:
   - Select some code in Neovim
   - Press `<leader>cs`
   - Claude should receive the code with context

### 5. Optional: Add Aliases

Add to your fish config for convenience:

```fish
# ~/.config/fish/config.fish
alias ch='claude-hybrid'
alias cs='claude-status'
```

## New Workflow

### Starting a Session
1. Open project in tmux session
2. **Window 1**: Neovim → `:ClaudeCode` (or `<leader>cc`)
3. **Window 2**: `claude-hybrid --continue` (or `M-C` for new window)

### Daily Usage
- **Visual selections**: Select code → `<leader>cs`
- **File operations**: `:ClaudeCodeAdd file.lua 10 20`
- **Direct typing**: Use Claude terminal as normal
- **Quick access**: `C-q C` for Claude popup

### Key Mappings Added
| Key | Action |
|-----|--------|
| `<leader>cc` | Start Claude WebSocket |
| `<leader>cs` | Send visual selection |
| `<leader>cr` | Resume conversation |
| `<leader>cC` | Continue conversation |
| `C-q C` | Claude popup (tmux) |
| `M-C` | New Claude window (tmux) |

## Troubleshooting

**Plugin not loading?**
```vim
:Lazy health claudecode
```

**WebSocket not connecting?**
```bash
claude-status
netstat -tln | grep 10000  # Check if port is listening
```

**Fish function not working?**
```fish
functions | grep claude
# Should show claude-hybrid
```


## Integration Complete!

You now have the hybrid Claude Code + Neovim setup that:
- Preserves your tmux workflow
- Adds IDE-like visual selection features  
- Maintains session-per-project isolation
- Provides both terminal and Neovim access to Claude

See `claude/neovim-integration.md` for detailed usage guide and troubleshooting.