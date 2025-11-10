# Session Synchronization Review

## Current Architecture ✅

**Session names are based on WORKTREE NAME, not BRANCH NAME.**

```fish
session_name = <worktree_name>@<repo_name>
```

### Session Name Generation

```fish
# lib/common.fish:226
function _wt_get_session_name
    set -l worktree_name $argv[1]  # ← Worktree name
    set -l repo_name $argv[2]

    # Format: worktree@repo
    echo "$worktree_name@$repo_name" | tr -cd '[:alnum:]-_@'
end
```

### Used By All Commands

| Command | Uses | Input |
|---------|------|-------|
| `wt new <name> ...` | `_wt_get_session_name $name $repo_name` | `$name` = worktree name |
| `wt switch <name>` | `_wt_get_session_name $name $repo_name` | `$name` = worktree name |
| `wt remove <name>` | `_wt_get_session_name $name $repo_name` | `$name` = worktree name |

---

## Decoupling Safety ✅

**Decoupling branch name from worktree name is SAFE.**

### Current Behavior (coupled)
```fish
wt new auth-db
# Worktree: auth-db/
# Branch: auth-db
# Session: auth-db@myapp
```

Sync chain: `worktree_name → session_name`
(Branch name not involved!)

### New Behavior (decoupled)
```fish
wt new auth-system auth-db
# Worktree: auth-system/
# Branch: auth-db
# Session: auth-system@myapp
```

Sync chain: `worktree_name → session_name`
(Still works perfectly!)

### Claude Web Example
```fish
wt new add-profiles jumski/add-user-profiles
# Worktree: add-profiles/
# Branch: jumski/add-user-profiles
# Session: add-profiles@myapp
```

No problem! Session name derived from worktree, not branch.

---

## What Would Break (None!)

### ❌ If session names used BRANCH names:
```fish
session_name = <branch_name>@<repo_name>  # Hypothetical (NOT current!)

wt new auth-system auth-db
# Session: auth-db@myapp  ← Wrong! Doesn't match worktree

wt switch auth-system
# Looks for: auth-system@myapp  ← Won't find auth-db@myapp session
```

This would break, but it's **NOT how WT works**.

### ✅ Actual implementation (worktree-based):
```fish
session_name = <worktree_name>@<repo_name>  # Actual!

wt new auth-system auth-db
# Session: auth-system@myapp  ← Correct! Matches worktree

wt switch auth-system
# Looks for: auth-system@myapp  ← Finds it!
```

---

## Implementation Verification

### wt_new.fish:183
```fish
set -l session_name (_wt_get_session_name $name $repo_name)
#                                          ^^^^^
#                                          Worktree name (first arg)
```

### wt_switch.fish:74
```fish
set -l session_name (_wt_get_session_name $name $repo_name)
#                                          ^^^^^
#                                          Worktree name (from arg/fzf)
```

### wt_remove.fish:119
```fish
set -l session_name (_wt_get_session_name $name $repo_name)
#                                          ^^^^^
#                                          Worktree name to remove
```

---

## Conclusion

**No changes needed to session sync logic.**

The synchronization is:
```
worktree directory name ←→ tmux session name
```

Branch name is independent and can be anything.

Decoupling is safe. Ship it! 🚀
