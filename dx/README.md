# dx - Developer Experience Utilities

Smart file navigation and note management with fzf.

## Cheatsheet

```fish
# Find and select notes
dx-notes-find

# Open note in editor
nvim (dx-notes-find)

# Tmux: Insert note path at cursor
# Press: <prefix> + a
```

## Commands

### `dx-notes-find`

Find markdown notes with automatic directory detection.

**Priority (stops at first match):**
1. `./.notes/` - Project notes
2. `./branch-docs/` - Branch documentation
3. `./` - All markdown files (recursive)

**Exclusions:** `node_modules/`, `.git/`

```fish
dx-notes-find              # Interactive selection
nvim (dx-notes-find)       # Edit selected note
dx-notes-find --help       # Show help
```

### `dx-file-select`

Generic file picker with directory fallback and preview.

**Options:**
- `--dirs DIR1 --dirs DIR2` - Search directories (recursive, priority order)
- `--pattern PATTERN` - File pattern (default: `*.md`)
- `--exclude-dir DIR` - Exclude directories (repeatable)
- `--preview-cmd CMD` - Preview command (`{}` = file path)
- `--preview-window LAYOUT` - fzf layout (default: `right:60%:wrap`)
- `--prompt TEXT` - Prompt text

```fish
# Find configs
dx-file-select \
    --dirs ~/.config \
    --pattern '*.{yaml,json}' \
    --preview-cmd 'bat --language=yaml {}'

# Find logs
dx-file-select \
    --dirs /var/log --dirs ./logs \
    --pattern '*.log' \
    --exclude-dir archive
```

## Tmux Integration

**Binding:** `<prefix> + a` - Insert note path at cursor

Workflow:
1. Press `<prefix> + a`
2. Select note in fzf popup
3. Path inserted at cursor position

Useful for: `cat <path>`, `nvim <path>`, command completion

## Creating Custom Selectors

```fish
# Find shell scripts
function my-scripts
    dx-file-select \
        --dirs ./scripts --dirs ~/bin \
        --pattern '*.{sh,fish}' \
        --prompt 'Select script > '
end

# Find tests
function my-tests
    dx-file-select \
        --dirs ./tests \
        --pattern '*.test.{js,ts}' \
        --exclude-dir node_modules
end
```

## Installation

Functions auto-load via Fish. For tmux binding:

```bash
tmux source-file ~/.tmux.conf
```
