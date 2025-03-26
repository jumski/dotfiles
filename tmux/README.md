# TMUX Cheatsheet

## 🚀 Getting Started

### Muxit - Main Entry Point
```fish
muxit [directory]  # Create/attach to tmux session (fuzzy finds projects)
mux                # Alias for muxit
dotfiles           # Open dotfiles in tmux
tmexit/mex         # Kill current session
```

## 🔑 Essential Shortcuts

### Session Management
| Shortcut | Description |
|----------|-------------|
| `C-q`    | Prefix key (instead of default C-b) |
| `C-g`    | Send prefix to nested sessions |
| `M-0`    | Choose session |
| `M-8/9`  | Previous/next session |
| `prefix d` | Detach session |
| `prefix m` | Muxit popup |

### Window Navigation
| Shortcut | Description |
|----------|-------------|
| `M-1` to `M-7` | Jump to window 1-7 |
| `M-n/p`  | Next/previous window |
| `M-;`    | Last window |
| `M-c`    | New window |

### Pane Management
| Shortcut | Description |
|----------|-------------|
| `M-\`    | Split horizontally |
| `M--`    | Split vertically |
| `C-h/j/k/l` | Vim-style pane navigation |
| `M-h/j/k/l` | Resize panes |
| `M-q`    | Kill pane |

## 📋 Copy/Paste
| Shortcut | Description |
|----------|-------------|
| `M-u`    | Enter copy mode |
| `M-i`    | Paste buffer |
| `y`      | (Copy mode) Copy selection |
| `M-y`    | Copy to system clipboard |
| `prefix p` | Paste from clipboard |

## 🛠️ Utility Commands
| Shortcut | Description |
|----------|-------------|
| `prefix r` | Reload config |
| `prefix v` | Open alsamixer |
| `prefix h` | Open htop |
| `prefix b` | Browse GitHub repo |
| `prefix D` | Edit dotfiles |

## 🎨 Layout Management
| Shortcut | Description |
|----------|-------------|
| `M-=`    | Even horizontal layout |
| `M-+`    | Even vertical layout |
| `prefix j/J` | Join panes |
| `prefix B` | Break pane to window |

## ⚙️ Advanced Features
| Shortcut | Description |
|----------|-------------|
| `prefix F` | Send `C-z fg;alert` |
| `prefix m` | Open man page |
| `M-r`     | Refresh client |
| `M-PPage` | Copy mode + scroll |

## 🔌 Plugins
- tpm (Tmux Plugin Manager)
- tmux-sensible
- tmux-menus

## 🌈 Theme
Using Tokyo Night theme (night variant)

## 💡 Pro Tips
1. Use `muxit` for project-based sessions
2. `M-1` to `M-7` for lightning window switching
3. Vim-style navigation works in both tmux and nested vim
4. Prefix `m` gives quick access to projects via fuzzy finder
