# Claude Code + Neovim Hybrid Integration Guide

## Overview

This guide implements a hybrid approach combining the best of tmux terminal workflow with modern IDE integration. You get:

- **Terminal control**: Claude Code runs in your familiar tmux window
- **IDE features**: Visual selections, real-time context sharing, file operations from Neovim
- **Session isolation**: One Neovim-Claude pair per project/tmux session
- **No workflow disruption**: Keep your Alt+1-7 window navigation and tmux mastery

## How It Works

### WebSocket MCP Protocol

The integration uses Claude Code's built-in WebSocket MCP (Model Context Protocol):

1. **Neovim plugin** (`coder/claudecode.nvim`) starts a WebSocket server
2. **Claude Code CLI** detects environment variables and connects to that server
3. **Bidirectional communication**: Neovim can send context, Claude can open files/show diffs
4. **Terminal access**: You can still type directly in Claude's tmux window

### Architecture Diagram

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

## Workflow Benefits

### Before (Current)
1. Select code in Neovim
2. Copy (y)
3. Alt+2 to switch to Claude window
4. Paste and ask question
5. Alt+1 back to Neovim
6. Manually reload files if Claude changes them

### After (Hybrid)
1. Select code in Neovim
2. `<leader>cs` → Claude gets it instantly with context
3. Continue in either:
   - Type directly in Claude tmux window, OR
   - Use Neovim for more selections/operations
4. Files auto-update when Claude changes them

## Implementation

### 1. Plugin Configuration

File: `nvim/lua/plugins/claudecode.lua`

```lua
return {
  "coder/claudecode.nvim",
  config = true,
  keys = {
    { "<leader>a", nil, desc = "AI/Claude Code" },
    { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Start Claude WebSocket" },
    { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
    { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
    { "<leader>ao", "<cmd>ClaudeCodeOpen<cr>", desc = "Open Claude terminal" },
    { "<leader>ax", "<cmd>ClaudeCodeClose<cr>", desc = "Close Claude connection" },
  },
  opts = {
    -- Server options
    port_range = { min = 10000, max = 65535 },
    auto_start = true,
    log_level = "info",

    -- Terminal options (we use external tmux, not plugin's terminal)
    terminal = {
      provider = "native",
      auto_close = false,  -- Keep connection open
    },

    -- Diff options
    diff_opts = {
      auto_close_on_accept = true,
      vertical_split = true,
    },
  },
}
```

### 2. Wrapper Scripts

File: `bin/claude-hybrid`

```bash
#!/bin/bash
# Claude Code wrapper that connects to Neovim WebSocket

CLAUDE_LOCK_DIR="$HOME/.claude/ide"
LOCK_FILE_PATTERN="$CLAUDE_LOCK_DIR/*.lock"

# Function to find active WebSocket port
find_websocket_port() {
    if [ -d "$CLAUDE_LOCK_DIR" ]; then
        # Find the most recent lock file
        LATEST_LOCK=$(ls -t $LOCK_FILE_PATTERN 2>/dev/null | head -n1)
        if [ -n "$LATEST_LOCK" ]; then
            # Extract port from filename (format: [port].lock)
            PORT=$(basename "$LATEST_LOCK" .lock)
            echo "$PORT"
        fi
    fi
}

# Check if we should connect to WebSocket
WEBSOCKET_PORT=$(find_websocket_port)

if [ -n "$WEBSOCKET_PORT" ]; then
    echo "🔗 Connecting to Neovim WebSocket on port $WEBSOCKET_PORT"
    export CLAUDE_IDE_PORT="$WEBSOCKET_PORT"
    export CLAUDE_IDE_HOST="localhost"
    echo "✅ Claude will integrate with Neovim"
else
    echo "ℹ️  No Neovim WebSocket found, running in standalone mode"
fi

# Run Claude Code with all passed arguments
exec claude "$@"
```

File: `bin/claude-status`

```bash
#!/bin/bash
# Check status of Claude-Neovim integration

CLAUDE_LOCK_DIR="$HOME/.claude/ide"

echo "🔍 Claude Code + Neovim Integration Status"
echo "=========================================="

# Check if lock directory exists
if [ ! -d "$CLAUDE_LOCK_DIR" ]; then
    echo "❌ No lock directory found at $CLAUDE_LOCK_DIR"
    echo "   → Start Neovim and run :ClaudeCode first"
    exit 1
fi

# List active lock files
LOCK_FILES=$(ls "$CLAUDE_LOCK_DIR"/*.lock 2>/dev/null)

if [ -z "$LOCK_FILES" ]; then
    echo "❌ No active WebSocket connections"
    echo "   → Start Neovim and run :ClaudeCode to create WebSocket server"
else
    echo "✅ Active WebSocket connections:"
    for lock_file in $LOCK_FILES; do
        port=$(basename "$lock_file" .lock)
        echo "   → Port: $port"
        
        # Check if port is actually listening
        if netstat -tln 2>/dev/null | grep -q ":$port "; then
            echo "     Status: ✅ Listening"
        else
            echo "     Status: ❌ Not listening (stale lock file)"
        fi
    done
fi

echo ""
echo "Environment variables:"
if [ -n "$CLAUDE_IDE_PORT" ]; then
    echo "   CLAUDE_IDE_PORT: $CLAUDE_IDE_PORT"
else
    echo "   CLAUDE_IDE_PORT: (not set)"
fi

if [ -n "$CLAUDE_IDE_HOST" ]; then
    echo "   CLAUDE_IDE_HOST: $CLAUDE_IDE_HOST"
else
    echo "   CLAUDE_IDE_HOST: (not set)"
fi

echo ""
echo "💡 Usage:"
echo "   1. In Neovim: :ClaudeCode"
echo "   2. In tmux: claude-hybrid --continue"
echo "   3. Select code in Neovim and use <leader>as"
```

### 3. Fish Shell Integration

File: `fish/functions/claude-hybrid.fish`

```fish
function claude-hybrid
    set -l claude_lock_dir "$HOME/.claude/ide"
    
    # Find active WebSocket port
    if test -d "$claude_lock_dir"
        set -l latest_lock (ls -t "$claude_lock_dir"/*.lock 2>/dev/null | head -n1)
        if test -n "$latest_lock"
            set -l port (basename "$latest_lock" .lock)
            set -x CLAUDE_IDE_PORT "$port"
            set -x CLAUDE_IDE_HOST "localhost"
            echo "🔗 Connecting to Neovim WebSocket on port $port"
        else
            echo "ℹ️  No Neovim WebSocket found, running in standalone mode"
        end
    end
    
    # Run Claude Code with all arguments
    claude $argv
end
```

### 4. Tmux Integration

Add to `tmux/tmux.conf.symlink`:

```bash
# Claude Code hybrid integration
bind C popup -E -w 80% -h 80% "claude-hybrid --continue"
bind-key -n M-C run-shell "tmux new-window -n claude 'claude-hybrid --continue'"
```

## Usage Guide

### Starting the Integration

1. **In Neovim** (any project):
   ```
   :ClaudeCode
   ```
   This starts the WebSocket server and shows the port.

2. **In tmux window** (same project):
   ```bash
   claude-hybrid --continue
   ```
   This connects Claude to Neovim's WebSocket.

### Daily Workflow

1. **Open project in tmux session**
2. **Window 1**: Neovim with `:ClaudeCode`
3. **Window 2**: `claude-hybrid --continue`
4. **Work normally**:
   - Type directly in Claude terminal
   - Select code in Neovim → `<leader>as` to send
   - Claude can open files, show diffs in Neovim
   - Files auto-reload when Claude changes them

### Key Mappings

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ac` | Normal | Start Claude WebSocket server |
| `<leader>ar` | Normal | Resume Claude conversation |
| `<leader>aC` | Normal | Continue Claude conversation |
| `<leader>as` | Visual | Send selection to Claude |
| `<leader>ao` | Normal | Open Claude terminal |
| `<leader>ax` | Normal | Close Claude connection |
| `M-C` | Tmux | New window with Claude |
| `C-q C` | Tmux | Claude popup |

## Advanced Features

### File Operations from Neovim

```vim
" Add specific file with line range
:ClaudeCodeAdd src/main.lua 50 100

" Add entire directory
:ClaudeCodeAdd tests/

" Add file from tree explorer (nvim-tree/neo-tree)
" Position cursor on file, press <leader>as
```

### Integration with Your Existing Tools

- **Telescope**: Use `<leader>tt` to find files, then `<leader>as` to add them
- **Oil.nvim**: Navigate with `-`, select files, use `<leader>as`
- **Git integration**: Claude can see git context through MCP protocol

### Troubleshooting

```bash
# Check integration status
claude-status

# Manual cleanup if needed
rm ~/.claude/ide/*.lock

# Debug mode
:ClaudeCode
# Then check :ClaudeCodeStatus in Neovim
```

## Benefits Achieved

✅ **Keep tmux mastery**: Alt+1-7 navigation, copy-mode, scrollback  
✅ **Gain IDE features**: Visual selections, context sharing, auto-reload  
✅ **Session isolation**: One pair per project  
✅ **Terminal access**: Full Claude Code features in tmux  
✅ **No workflow disruption**: Enhancement, not replacement  
✅ **Simple setup**: Scripts handle environment coordination  

This hybrid approach gives you the best of both worlds while preserving your optimized tmux workflow.