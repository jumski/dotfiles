# dx - Developer Experience Utilities

Collection of productivity tools for faster file navigation and workspace management.

## Functions

### `dx-file-select` - Generic File Selector

Reusable fzf-based file picker with directory fallback, exclusions, and customizable preview.

**Options:**
- `--dirs DIR1 DIR2 ...` - Search directories in priority order (supports env vars)
- `--pattern PATTERN` - File pattern (default: `*.md`)
- `--exclude-dir DIR` - Directories to exclude (repeatable)
- `--preview-cmd CMD` - Preview command (use `{}` as file placeholder)
- `--preview-window LAYOUT` - fzf preview layout (default: `right:60%:wrap`)
- `--prompt TEXT` - fzf prompt text

Use `RECURSIVE:.` to search recursively from current directory.

**Example Usage:**

```fish
# Find config files with YAML preview
dx-file-select \
    --dirs '$XDG_CONFIG_HOME' ~/.config \
    --pattern '*.{yaml,json,toml}' \
    --preview-cmd 'bat --language=yaml {}' \
    --prompt 'Select config > '

# Find logs with tail preview
dx-file-select \
    --dirs /var/log ./logs \
    --pattern '*.log' \
    --preview-cmd 'tail -n 50 {}' \
    --exclude-dir archive
```

---

### `dx-notes-find` - Smart Notes Finder

Find and select notes with automatic directory detection and markdown preview.

**Directory Priority:**
1. `$notes` environment variable
2. `./branch-docs` directory
3. All `*.md` files recursively (excludes `node_modules`, `.git`)

**Example Usage:**

```fish
# Simple usage - just run it
dx-notes-find

# Use in scripts
set selected_note (dx-notes-find)
if test -n "$selected_note"
    nvim "$selected_note"
end

# Quick edit
nvim (dx-notes-find)
```

---

## Tmux Integration

### `prefix + a` - Insert Note Path

Opens fzf popup to select a note, then inserts its path at cursor position in current pane.

Useful for quickly referencing notes in commands:
```bash
cat <prefix+a>  # Select note, path gets inserted
```

**How it works:**
- Sends `Escape` then `A` (vim-style: append at end of line)
- Loads selected path into tmux buffer
- Pastes into current pane

---

## Installation

The module auto-loads via Fish's function autoloading. Tmux binding requires reload:

```bash
tmux source-file ~/.tmux.conf
```

---

## Creating Custom Selectors

Build specialized selectors by wrapping `dx-file-select`:

```fish
# Find shell scripts
function my-script-find
    dx-file-select \
        --dirs ./scripts ~/bin \
        --pattern '*.{sh,fish}' \
        --preview-cmd 'bat --language=bash {}' \
        --prompt 'Select script > '
end

# Find test files
function my-test-find
    dx-file-select \
        --dirs 'RECURSIVE:./tests' \
        --pattern '*.test.{js,ts,fish}' \
        --exclude-dir node_modules \
        --preview-cmd 'bat {}'
end
```
