#!/usr/bin/env fish
# Remove worktree

function wt_remove
    set -l name $argv[1]
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    _wt_assert "test -n '$name'" "Worktree name required"
    or return 1
    
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