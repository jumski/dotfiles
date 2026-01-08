# Hive - Tmux Workspace Management

Quick reference for managing worktrees across multiple repos in a single tmux session.

## Quick Start

```fish
# Start using hive immediately
hive spawn

# Or press: Ctrl-b h  (tmux prefix + h)
```

## Keyboard Shortcuts (in tmux)

| Key | Action |
|-----|--------|
| `prefix + h` | Open spawn wizard (fzf picker) |

*Note: Your tmux prefix is typically `Ctrl-b`*

## Core Concepts

- **Session** = One repository (e.g., `pgflow`, `dotfiles`)
- **Window** = One worktree/branch (e.g., `main`, `feat-auth`)
- **Badge** = Notification indicator on window name

**Naming:**
```
Session: repo name
Window:  worktree name (or "main" for non-worktree repos)
```

## Commands

### `hive spawn` (or `sp`)
**Interactive wizard** to open a worktree.

```
Step 1: Select worktree (from muxit cache)
Step 2: Choose destination
  • [+ New Session]    → creates new hive session
  • current session     → (if in hive session) highlighted by default
  • existing session    → proceed to step 3
Step 3: Choose window (only if existing session)
  • [+ New Window]    → creates new window
  • existing window    → splits that window
```

### `hive session <path>` (or `ses`)
Create a new hive session from a directory.

```fish
# Current directory
hive session .

# Specific path
hive session ~/Code/pgflow-dev/pgflow/worktrees/feat-auth
```

### `hive window <path> [session]` (or `win`)
Add a window to an existing hive session.

```fish
# Add to current session
hive window ~/Code/repo/worktrees/feature-x

# Add to specific session
hive window ~/Code/repo/worktrees/fix-bug pgflow
```

### `hive split <path>`
Split current window horizontally with another worktree.

```fish
# Side-by-side columns (for ultrawide monitors)
hive split ~/Code/other/worktrees/task
```

### `hive list` (or `ls`)
List all hive sessions and their windows.

```
# pgflow
# dotfiles
  1: main
```

## Notification Badges

Windows show badges when agents need attention:

| Badge | Meaning |
|--------|----------|
| `[R]` | Permission needed |
| `[I]` | Idle/waiting for input |
| `[!]` | Error occurred |
| `[A]` | Activity/other |

Badges **auto-clear** when you focus the window.

## Workflow Examples

### Scenario 1: Start working on a new feature
```fish
# In tmux, press: Ctrl-b h
# Select: pgflow-dev/pgflow/worktrees/feat-new-auth
# Select: [+ New Session]
```

Result: New tmux session named `pgflow` with window `feat-new-auth`.

### Scenario 2: Add a related worktree
```fish
# In tmux, press: Ctrl-b h
# Select: pgflow-dev/pgflow/worktrees/fix-auth-bug
# Select: pgflow (existing)
# Select: [+ New Window]
```

Result: Adds window `fix-auth-bug` to the `pgflow` session.

### Scenario 3: Compare two worktrees side-by-side
```fish
# First, navigate to window: feat-new-auth
hive split ~/Code/pgflow-dev/pgflow/worktrees/fix-auth-bug
```

Result: Window splits horizontally, both worktrees visible at once.

### Scenario 4: Review all active work
```fish
hive list
```

Result: Shows all hive sessions and their windows.

## Troubleshooting

### "muxit cache not found"
```fish
muxit-update-cache
```

### "Session already exists"
The session name already exists (possibly from `muxit` or `wt`). Use:
```fish
# Switch to existing session
tmux switch-client -t <session-name>

# Or create a new window instead
hive window <path> <session-name>
```

### "Not a hive session"
The session was created by `muxit` or `wt`, not `hive`. Either:
- Use `muxit`/`wt` commands to manage it, or
- Create a new hive session with different name

### Badges not clearing
Make sure `focus-events` is enabled in your terminal:
```conf
# In ~/.config/tmux.conf or ~/.tmux.conf
set-option -g focus-events on
```

## Comparison: Hive vs Muxit

| | Hive | Muxit |
|---|-------|--------|
| **Organization** | Session per repo | Session per worktree |
| **Switching** | `prefix + 1` (windows) | `prefix + w` (sessions) |
| **Visibility** | See all worktrees for a repo | Spread across sessions |
| **Use case** | Multi-worktree workflows | Single-worktree focus |

**Best practices:**
- Use **Hive** when actively working across multiple worktrees in same repo
- Use **Muxit** for single-worktree tasks or jumping between different repos

## Configuration

Files:
- `hive/hive.fish` - Main module (loaded by fish)
- `hive/functions/` - Command definitions
- `hive/lib/common.fish` - Helper functions
- `hive/scripts/` - Notification scripts
- `tmux-hive.conf` - Tmux bindings (sourced from tmux.conf.symlink)

Environment:
- `HIVE_VERSION` - Current version
- `~/.cache/muxit-projects` - Worktree picker cache

## See Also

- `wt` - Git worktree management toolkit
- `muxit` - Tmux session launcher for projects
- `claude` - OpenCode CLI for agentic coding
