# 🤖 Claude Code + Neovim Integration

## 🚀 Quick Start Cheatsheet

### ⚡ Setup (One Time)
```bash
# 1. Install plugin
nvim  # then :Lazy sync

# 2. Reload configs  
tmux source-file ~/.tmux.conf
exec fish
```

### 🎯 Daily Usage
```bash
# 1. Start in any project
nvim                          # Open Neovim in window 1
:ClaudeCodeStart              # Or <leader>cc - starts WebSocket (no terminal!)

# 2. Switch to Claude window & start
Alt+2                         # Switch to window 2 (or any window)
claude-hybrid --continue     # Start Claude with integration

# Quick alternatives:
# M-C          # New dedicated Claude window
# C-q C        # Claude popup for quick tasks
```

### 🔥 Key Commands
| What | Key | Action |
|------|-----|--------|
| 🧠 **Start server** | `:ClaudeCodeStart` or `<leader>cc` | Start WebSocket server (no terminal!) |
| 📤 **Send code** | `<leader>cs` (visual) | Send selection to Claude |
| 📊 **Status** | `<leader>cr` | Check server status |
| ❌ **Stop server** | `<leader>cx` | Stop WebSocket server |
| 🪟 **New window** | `M-C` (tmux) | New Claude window |
| 🎯 **Popup** | `C-q C` (tmux) | Claude popup (80% screen) |
| 📍 **Current window** | `claude-hybrid --continue` | Use existing window/pane |

### ✨ Magic Workflow
1. **Select code** in Neovim (visual mode)
2. **Hit `<leader>cs`** → Code instantly appears in Claude with context
3. **Type in Claude terminal** normally or use Neovim for more selections
4. **Files auto-reload** when Claude changes them

### 🔍 Troubleshooting
```fish
claude-status    # Check if everything is connected
```

---

## Architecture

```
┌─────────────────┐    WebSocket MCP     ┌──────────────────┐
│ Neovim          │◄──────────────────────┤ Claude Code CLI  │
│ (claudecode.nvim)│     JSON-RPC         │ (tmux window)    │
└─────────────────┘                      └──────────────────┘
       ▲                                           ▲
       │ Visual selections                         │ Direct typing
       │ File operations                           │ Full terminal
       ▼                                           ▼
┌─────────────────┐                      ┌──────────────────┐
│ Your code files │                      │ Your interaction │
└─────────────────┘                      └──────────────────┘
```

## Files in this Integration

```
claude-neovim/
├── README.md              # This comprehensive guide
├── claude-hybrid.fish     # Fish function for WebSocket connection
├── claude-status.fish     # Fish function for status checking  
├── tmux-keys.conf         # Tmux keybindings (sourced by main config)
└── nvim plugin at: nvim/lua/plugins/claudecode.lua
```

## Installation & Setup

### 1. Install Neovim Plugin
The plugin is already configured at `nvim/lua/plugins/claudecode.lua`. Run in Neovim:
```vim
:Lazy sync
```

### 2. Source Tmux Config
Add this line to your main `tmux.conf`:
```bash
source-file ~/.dotfiles/claude-neovim/tmux-keys.conf
```

### 3. Reload Configurations
```bash
# Reload tmux config
tmux source-file ~/.tmux.conf

# Reload fish (functions auto-load from *.fish files)
exec fish
```

## Usage

### Daily Workflow

1. **Start session**: Open project in tmux
2. **Window 1**: Neovim → `:ClaudeCode` (or `<leader>cc`)
3. **Window 2**: `claude-hybrid --continue` (or `M-C` for new window)
4. **Work normally**:
   - Select code in Neovim → `<leader>cs` (sends to Claude)
   - Type directly in Claude terminal
   - Files auto-reload when Claude changes them

### Key Mappings

#### Neovim (`<leader>c` prefix)
| Key | Action |
|-----|--------|
| `<leader>cc` | Start Claude WebSocket server |
| `<leader>cs` | Send visual selection to Claude |
| `<leader>cr` | Resume Claude conversation |
| `<leader>cC` | Continue Claude conversation |
| `<leader>co` | Open Claude terminal |
| `<leader>cx` | Close Claude connection |

#### Tmux
| Key | Action |
|-----|--------|
| `M-C` | New window with Claude Code |
| `C-q C` | Claude Code popup (80% screen) |

### Advanced Features

#### File Operations from Neovim
```vim
" Add specific file with line range
:ClaudeCodeAdd src/main.lua 50 100

" Add entire directory  
:ClaudeCodeAdd tests/

" Add file from tree explorer (nvim-tree/neo-tree)
" Position cursor on file, press <leader>cs
```

#### Tree Integration
- **In nvim-tree/neo-tree**: `<leader>cs` adds file(s) to Claude context
- **Visual mode**: `<leader>cs` sends selected code
- **Telescope integration**: Find files → `<leader>cs` to add them

## How WebSocket MCP Works

1. **Plugin starts WebSocket server** on random port (10000-65535)
2. **Writes lock file** to `~/.claude/ide/[port].lock` with connection info
3. **claude-hybrid function** reads lock file and sets environment variables
4. **Claude Code CLI** detects environment and connects to WebSocket
5. **Bidirectional communication**: Neovim ↔ Claude via JSON-RPC

## Troubleshooting

### Check Integration Status
```fish
claude-status  # Shows WebSocket connections, environment vars, usage tips
```

### Common Issues

**Plugin not loading?**
```vim
:Lazy health claudecode
```

**WebSocket not connecting?**
```bash
claude-status
netstat -tln | grep 10000  # Check if port is listening
```

**Fish functions not working?**
```fish
functions | grep claude
# Should show: claude-hybrid, claude-status
```

**Environment variables not set?**
- Make sure you ran `:ClaudeCodeStart` in Neovim first
- Check `claude-status` output for active connections

### Manual Cleanup
```bash
# Remove stale lock files if needed
rm ~/.claude/ide/*.lock
```

## Benefits Achieved

✅ **Keep tmux mastery**: Alt+1-7 navigation, copy-mode, scrollback  
✅ **Gain IDE features**: Visual selections, context sharing, auto-reload  
✅ **Session isolation**: One pair per project  
✅ **Terminal access**: Full Claude Code features in tmux  
✅ **Simple setup**: Functions handle environment coordination  
✅ **Organized**: All integration files in one folder

## Workflow Benefits

### Before
1. Select code in Neovim → Copy → Alt+2 switch → Paste → Ask question → Alt+1 back → Manual reload

### After  
1. Select code in Neovim → `<leader>cs` → Claude gets it instantly with context

### Plus You Still Have
- Full tmux terminal features (scrollback, search, copy-mode)
- Direct typing in Claude terminal
- Your optimized tmux navigation (Alt+1-7)
- Session-per-project isolation

This hybrid approach enhances your workflow without disrupting the tmux mastery you've built.