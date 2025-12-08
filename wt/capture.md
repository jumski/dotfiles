# wt capture - Claude Session Migration

## Overview

The `wt capture` command captures the current branch to a dedicated worktree, designed for Graphite stacks. This document describes the Claude Code session migration feature added to preserve conversation context when "graduating" exploratory work from the main worktree.

## Problem Statement

When working in the main worktree (`main@pgflow` tmux session):
1. You start exploring an idea, create branches with `gt create`
2. The main worktree gets "hijacked" - it's no longer on main branch
3. You have a Claude Code session with valuable context about the work
4. When you "graduate" to a dedicated worktree with `wt new`, the Claude session is lost

The Claude Code session is tied to the directory path. Sessions are stored in:
```
~/.claude/projects/[encoded-directory-path]/[session-id].jsonl
```

Where path encoding replaces `/` with `-`:
```
/home/jumski/Code/pgflow-dev/pgflow/worktrees/main
-> -home-jumski-Code-pgflow-dev-pgflow-worktrees-main
```

## Key Discoveries

### Session Lookup is Local

Verified empirically: `claude --resume <session-id>` only looks in the current directory's project folder, not globally. This means we must **copy** the session file to the new worktree's Claude project directory.

### --resume vs --fork-session

- `--resume <id>` alone: Reuses same session ID, writes to same file
- `--resume <id> --fork-session`: Creates new session ID, writes to new file

**Decision**: Use `--resume` without `--fork-session`. Since sessions are in different directories (different encoded paths), same ID doesn't conflict. Feels like "continuation" rather than "fork".

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Session migration default | ON with `--switch` | You're moving your working context |
| Session selection | Most recent by default | Usually what you want |
| fzf picker | Available via `--claude-session` | For selecting specific session |
| Old Claude window | Kill + recreate fresh | Clean slate in main worktree |
| Switch to trunk | `gt checkout main` | Go all the way back, not just `gt down` |
| Window number | Hardcoded as 4 | Convention: window 4 is Claude |
| Tmux naming | `worktree@repo` | Convention: `main@pgflow`, `feature-x@pgflow` |
| Parsing tool | `jq` | Native JSONL streaming, common dependency |

## Command Interface

```
Usage: wt capture [options]

Options:
  --switch              Switch to new worktree after creation
  --claude-session[=ID] Migrate Claude session (fzf picker or explicit ID)
  --no-claude-session   Skip Claude session migration
  --yes                 Auto-confirm (uses most recent session)
  --force               Skip Graphite checks

Default behavior:
  wt capture                       -> no migration (not switching)
  wt capture --switch              -> migrate most recent session
  wt capture --switch --yes        -> migrate most recent, no prompts
  wt capture --switch --claude-session -> fzf picker
  wt capture --switch --no-claude-session -> skip migration
```

## Execution Flow

1. **Gather state**: branch name, trunk, session files
2. **Resolve session**: most recent, fzf picker, or explicit ID
3. **Show plan**: what will happen, ask confirmation
4. **Switch to trunk**: `gt checkout main` (not `gt down`)
5. **Reset old Claude**: kill window 4, start fresh `claude`
6. **Create worktree**: `wt_new $branch $branch --yes`
7. **Copy session**: `cp session.jsonl` to new project dir
8. **Start resumed Claude**: `claude --resume $session_id` in new window 4
9. **Switch tmux**: `tmux switch-client -t new-session`

## Tool Dependencies

| Tool | Required | Purpose |
|------|----------|---------|
| `gt` | Yes (unless --force) | Navigate stack, get trunk |
| `tmux` | Yes | Must be running inside tmux |
| `jq` | Yes (if migrating) | Parse session JSONL for fzf |
| `fzf` | Conditional | Only for `--claude-session` picker |

## Session File Format

Sessions are stored as JSONL (one JSON object per line):

```jsonl
{"uuid":"...","sessionId":"...","timestamp":"2025-...","type":"user","message":{"role":"user","content":"..."}}
{"uuid":"...","sessionId":"...","timestamp":"2025-...","type":"assistant","message":{"role":"assistant","content":[...]}}
```

Key fields for display:
- `sessionId`: UUID identifying the session
- `timestamp`: ISO 8601 timestamp
- `type`: "user" or "assistant"
- `message.content`: Message text (for preview)

## fzf Picker

Shows recent sessions with:
- Timestamp (human readable)
- First user message preview (60 chars)
- Full preview pane showing first 20 lines of user messages

```
SESSION ID | TIMESTAMP | FIRST MESSAGE
b953f80e   | 2 hours ago | implementing auth flow for...
bc4409c0   | 5 hours ago | refactoring user model to...
```

## Edge Cases

| Case | Handling |
|------|----------|
| No Claude sessions exist | Skip migration, warn user |
| Session file not found | Error with message |
| Session copy fails | Warn, start fresh Claude instead |
| Not in tmux | Error: tmux required |
| fzf cancelled (ESC) | Abort capture |
| `--yes` with `--claude-session` | Fall back to most recent |

## Window Layout Convention

```
Window 1: server (web server, etc.)
Window 2: bash (shell for commands)
Window 3: vim (neovim)
Window 4: repl (Claude Code)
Window 5+: Additional Claude instances
```

## Future Considerations

- Multi-select in fzf to migrate multiple sessions
- Session cleanup/archival for old worktrees
- Integration with Claude Code slash commands (decided against - shell is sufficient)
