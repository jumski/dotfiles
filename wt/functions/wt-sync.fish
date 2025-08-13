#!/usr/bin/env fish
# Sync operations

# Sync current worktree
function wt_sync
    set -l sync_all false
    set -l force false
    set -l reset false
    
    # Parse options
    for arg in $argv
        switch $arg
            case --all
                set sync_all true
            case --force
                set force true
            case --reset
                set reset true
        end
    end
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    if test $sync_all = true
        set -l repo_root (_wt_get_repo_root)
        set -l saved_pwd (pwd)
        cd $repo_root
        _wt_get_repo_config
        
        echo "Syncing all worktrees..."
        
        for worktree_dir in $WORKTREES_PATH/*
            if test -d $worktree_dir
                set -l name (basename $worktree_dir)
                echo ""
                echo "Syncing $name..."
                cd $worktree_dir
                _wt_sync_single $force $reset
            end
        end
        cd $saved_pwd
    else
        _wt_sync_single $force $reset
    end
end

# Sync single worktree
function _wt_sync_single
    set -l force $argv[1]
    set -l reset $argv[2]
    
    set -l branch (git branch --show-current)
    
    if test $reset = true
        echo "Resetting to origin/$branch..."
        git fetch origin $branch
        git reset --hard origin/$branch
        return
    end
    
    # Check for uncommitted changes
    if test (git status --porcelain | count) -gt 0
        if test $force = true
            echo "Stashing changes..."
            git stash push -m "wt sync auto-stash"
        else
            echo "Error: Uncommitted changes. Use --force to stash" >&2
            return 1
        end
    end
    
    # Sync with remote
    gt sync
    
    # Restore stash if needed
    if test $force = true -a (git stash list | head -1 | string match -q "*wt sync auto-stash*")
        echo "Restoring stashed changes..."
        git stash pop
    end
end

# Restack current stack
function wt_restack
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    echo "Restacking current branch and upstack..."
    gt restack
end

# Submit current branch and upstack
function wt_submit
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    echo "Submitting current branch and upstack..."
    gt submit --stack
end