#!/usr/bin/env fish
# Environment file operations

function wt_env
    set -l subcommand $argv[1]
    set -l remaining_args $argv[2..-1]
    
    switch $subcommand
        case sync
            _wt_env_sync $remaining_args
        case '*'
            echo "Usage: wt env sync [--all]"
            return 1
    end
end

# Sync environment files
function _wt_env_sync
    set -l sync_all false
    
    if test "$argv[1]" = "--all"
        set sync_all true
    end
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    set -l repo_root (_wt_get_repo_root)
    set -l saved_pwd (pwd)
    cd $repo_root
    _wt_get_repo_config
    
    if not test -d $ENVS_PATH
        echo "No environment files found in $ENVS_PATH"
        cd $saved_pwd
        return 0
    end
    
    if test $sync_all = true
        echo "Syncing environment files to all worktrees..."
        
        for worktree_dir in $WORKTREES_PATH/*
            if test -d $worktree_dir
                echo "  → $(basename $worktree_dir)"
                cp -r "$ENVS_PATH/." "$worktree_dir/"
            end
        end
    else
        set -l current_worktree (pwd)
        echo "Syncing environment files to current worktree..."
        cp -r "$repo_root/$ENVS_PATH/." "$current_worktree/"
    end
    
    echo "✓ Environment files synced"
    cd $saved_pwd
end