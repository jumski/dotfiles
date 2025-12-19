# Clipboard Integration - Invalid Behaviour Analysis

## Current Issue (2025-12-19)

`<leader>p` in Neovim doesn't paste content copied from Firefox or other X11 applications.
User must use Kitty's Ctrl+Shift+V as workaround.

## Environment

- Terminal: Kitty (`copy_on_select clipboard`, full clipboard_control)
- Multiplexer: tmux (`set-clipboard external`)
- Editor: Neovim with custom clipboard provider

## Clipboard Destinations on Linux

| Clipboard | Description |
|-----------|-------------|
| X CLIPBOARD | Standard Ctrl+C/Ctrl+V clipboard |
| X PRIMARY | Selection clipboard (select to copy, middle-click to paste) |
| tmux buffer | tmux's internal paste buffer |

## Where Content Goes (Copy Source → Destinations)

| Copy Source | X CLIPBOARD | X PRIMARY | tmux buffer |
|-------------|:-----------:|:---------:|:-----------:|
| Firefox Ctrl+C | ✓ | | |
| Firefox select | | ✓ | |
| tmux yank (y) | ✓ | ✓ | ✓ |
| xclip -sel clip < file | ✓ | | |
| Mouse select in Kitty | ✓ | | |
| Neovim "+y | ✓ (via OSC52) | | ✓ |

Note: tmux yank populates all three because `copy-to-clipboard.sh` explicitly writes to xclip + sends OSC52.

## How Paste Methods Read

| Paste Method | Reads From |
|--------------|------------|
| `xclip -o -sel clipboard` | X CLIPBOARD |
| `xclip -o -sel primary` | X PRIMARY |
| `tmux save-buffer -` | tmux buffer |
| Kitty Ctrl+Shift+V | X CLIPBOARD |
| Middle-click | X PRIMARY |

## Current Neovim Clipboard Provider (BROKEN)

```lua
-- nvim/lua/core/clipboard.lua
local paste = {'bash', '-c', 'tmux refresh-client -l && sleep 0.05 && tmux save-buffer -'}
```

This ONLY reads from tmux buffer.

## What Works and What Doesn't

| Copy Source | `<leader>p` works? | Why? |
|-------------|:------------------:|------|
| Firefox Ctrl+C | NO | X CLIPBOARD not read |
| Firefox select | NO | X PRIMARY not read |
| tmux yank | YES | Goes to tmux buffer |
| Kitty mouse select | NO | X CLIPBOARD not read |
| Neovim "+y | YES | Provider puts in tmux buffer |

## Root Cause

The clipboard provider paste command only reads from tmux buffer.
Firefox/Kitty copies go to X CLIPBOARD, never touching tmux buffer.

Previous working version (before commit 90a28c9) had fallback logic:
```bash
content=$(xclip -o -sel clipboard 2>/dev/null)
[ -z "$content" ] && content=$(xclip -o -sel primary 2>/dev/null)
[ -n "$content" ] && echo -n "$content" || tmux save-buffer -
```

This tried xclip first, then fell back to tmux buffer.

## Required Fix

Restore xclip-first fallback in the clipboard provider paste command,
so `"+p` can read from both X CLIPBOARD and tmux buffer.
