#!/usr/bin/env fish
# Sync operations

# Sync all worktrees
function wt_sync_all
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt sync-all [--force] [--reset]

Sync all worktrees with their remote branches

Options:
  --force        Stash uncommitted changes before syncing
  --reset        Hard reset to origin instead of syncing"
    and return 0

    set -l force false
    set -l reset false

    # Parse options
    for arg in $argv
        switch $arg
            case --force
                set force true
            case --reset
                set reset true
        end
    end

    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1

    set -l repo_root (_wt_get_repo_root)
    set -l saved_pwd (pwd)
    cd $repo_root
    _wt_get_repo_config

    _wt_action "Syncing all worktrees..."

    for worktree_dir in $WORKTREES_PATH/*
        if test -d $worktree_dir
            set -l name (basename $worktree_dir)
            echo ""
            _wt_action "Syncing $name..."
            cd $worktree_dir
            _wt_sync_single $force $reset
        end
    end
    cd $saved_pwd
end

# Sync single worktree
function _wt_sync_single
    set -l force $argv[1]
    set -l reset $argv[2]
    
    set -l branch (git branch --show-current)
    
    if test $reset = true
        _wt_action "Resetting to origin/$branch..."
        git fetch origin $branch
        git reset --hard origin/$branch
        return
    end
    
    # Check for uncommitted changes
    if test (git status --porcelain | count) -gt 0
        if test $force = true
            _wt_action "Stashing changes..."
            git stash push -m "wt sync auto-stash"
        else
            echo "Error: Uncommitted changes. Use --force to stash" >&2
            return 1
        end
    end
    
    # Sync with remote
    _wt_action "Syncing with remote..."
    gt sync
    
    # Restore stash if needed
    if test $force = true -a (git stash list | head -1 | string match -q "*wt sync auto-stash*")
        _wt_action "Restoring stashed changes..."
        git stash pop
    end
end

