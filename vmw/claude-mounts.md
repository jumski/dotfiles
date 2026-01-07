# Claude Directory Mounting in VMW

Selective mounting of `~/.claude/` into VMW virtual machines.

## Overview

When spawning a VM, specific files/directories from host's `~/.claude/` are mounted read-only at `/home/jumski/.claude/`. Local state directories (projects, sessions, todos, memory) are excluded since they contain host-specific paths.

## Architecture

```
Host                              VM
~/.claude/                        /home/jumski/.claude/
├── .credentials.json ──────────► ├── .credentials.json (ro)
├── CLAUDE.md ──────────────────► ├── CLAUDE.md (ro)
├── settings.json ──────────────► ├── settings.json (ro)
├── file-suggestion.sh ─────────► ├── file-suggestion.sh (ro)
├── statusline.sh ──────────────► ├── statusline.sh (ro)
├── skills/ ────────────────────► ├── skills/ (ro)
├── commands/ ──────────────────► ├── commands/ (ro)
├── projects/        (NOT MOUNTED - host-specific state)
├── sessions/        (NOT MOUNTED - host-specific state)
├── todos/           (NOT MOUNTED - host-specific state)
└── memory/          (NOT MOUNTED - host-specific state)

~/.dotfiles/claude/               /home/jumski/.dotfiles/claude/
├── commands/ ──────────────────► ├── commands/ (ro)
├── skills/ ────────────────────► ├── skills/ (ro)
├── settings.json ──────────────► ├── settings.json (ro)
└── ... ────────────────────────► └── ... (ro)
```

The `~/.dotfiles/claude/` mount ensures symlinks in `~/.claude/` that point to dotfiles resolve correctly inside the VM.

## Configuration

Edit `vmw/claude-mount.list` to customize what's mounted:

```
# One path per line, relative to ~/.claude/
.credentials.json
CLAUDE.md
settings.json
file-suggestion.sh
statusline.sh
skills
commands
```

## Implementation

| Component | Purpose |
|-----------|---------|
| `vmw/claude-mount.list` | Config listing paths to mount |
| `vmw/functions/_vmw_stage_claude.fish` | Creates staging dir with symlinks |
| `vmw_spawn.fish` | Starts virtiofsd for claude staging and dotfiles-claude |
| `domain.xml.template` | Defines virtiofs filesystem entries |
| `user-data.template` | Mounts claude and dotfiles-claude shares as read-only |

The staging approach (symlinks in a temp directory) allows selective mounting without exposing the entire `~/.claude/` directory. The separate `~/.dotfiles/claude/` mount ensures symlinks resolve correctly.
