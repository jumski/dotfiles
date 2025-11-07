# Stack-Based Worktree Workflow

## Problem

**Current**: Worktree name = branch name (rigid)
- Can't handle branches with slashes (e.g., `jumski/add-profiles`)
- Worktree named after first branch, not milestone
- Confusing when working on stacks with `gt create/up/down`

**Needed**:
1. Milestone worktrees (use `gt` freely inside)
2. Decoupled naming (custom worktree names)
3. Spawn siblings for parallel work

## Solution

### 1. Enhance `wt new` - Decoupled Naming
```fish
wt new <worktree-name> [branch-name]

# Claude Web branches (existing branch with slash)
wt new add-profiles jumski/add-user-profiles

# Milestone worktree (new branch, different name)
wt new auth-system auth-db

# Quick mode (current behavior)
wt new quick-fix  # worktree=branch=quick-fix
```

### 2. Keep `wt branch` - Context-Aware Spawn
```fish
# In auth-system/ on auth-api branch
wt branch auth-api-hotfix --switch
# → Branches from CURRENT via gt create
# → Creates worktree + switches
```

## Workflows

### Milestone Stack (Single Worktree)
```fish
wt new auth-system auth-db --switch
gt create auth-api -am "..."
gt create auth-middleware -am "..."
gt up/down  # Navigate stack in place
```

| Worktree | Branch | Session |
|----------|--------|---------|
| `auth-system` | `auth-db` → `auth-api` → `auth-middleware` | `myapp_auth-system` |

### Parallel Work (Spawn Sibling)
```fish
# In auth-system/ on auth-middleware
wt branch auth-hotfix --switch  # Fix auth-api bug in parallel
```

| Worktree | Branch | Session |
|----------|--------|---------|
| `auth-system` | `auth-middleware` | `myapp_auth-system` |
| `auth-hotfix` | `auth-hotfix` (from current) | `myapp_auth-hotfix` |

## Key Insight

**One worktree per milestone** (default), `gt` manages stack inside.
**Spawn siblings** when parallel contexts needed (different tools/Claude sessions).
