#!/usr/bin/env fish
# Remove worktree

function wt_remove
    set -l name $argv[1]
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    # If no name provided, try to get current worktree
    if test -z "$name"
        set name (_wt_get_current_worktree)
        if test -z "$name"
            echo "Error: Not in a worktree directory, please specify worktree name" >&2
            return 1
        end
        echo "Detected current worktree: $name"
    end
    
    set -l repo_root (_wt_get_repo_root)
    set -l saved_pwd (pwd)
    cd $repo_root
    _wt_get_repo_config
    
    set -l worktree_path "$WORKTREES_PATH/$name"
    
    if not test -d $worktree_path
        echo "Error: Worktree '$name' not found" >&2
        return 1
    end
    
    # Confirm deletion
    echo "This will remove worktree: $name"
    echo "Path: $worktree_path"
    read -P "Continue? [y/N] " -n 1 confirm
    
    if test "$confirm" != "y"
        echo "Cancelled"
        return 0
    end
    
    # If we're removing the current worktree, move to repo root first
    set -l current_worktree (_wt_get_current_worktree)
    if test "$current_worktree" = "$name"
        echo "Moving out of current worktree before removal..."
        cd $repo_root
    end
    
    # Remove worktree
    git -C $BARE_PATH worktree remove $worktree_path --force
    or begin
        echo "Error: Failed to remove worktree" >&2
        return 1
    end
    
    # Remove branch if not checked out elsewhere
    git -C $BARE_PATH branch -d $name 2>/dev/null
    
    echo "✓ Worktree '$name' removed"
    
    cd $saved_pwd
end

# Alias
function wt_rm
    wt_remove $argv
end