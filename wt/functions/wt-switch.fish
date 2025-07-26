#!/usr/bin/env fish
# Switch to worktree using muxit

function wt_switch
    set -l name $argv[1]
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    set -l repo_root (_wt_get_repo_root)
    set -l current_dir (pwd)
    cd $repo_root
    _wt_get_repo_config
    
    # If no name provided, use fzf to select
    if test -z "$name"
        if not command -q fzf
            echo "Error: fzf required for interactive selection" >&2
            echo "Install fzf or provide worktree name: wt switch <name>" >&2
            return 1
        end
        
        # Get list of worktrees
        set -l worktrees (_wt_get_worktrees)
        
        if test (count $worktrees) -eq 0
            echo "No worktrees found"
            return 1
        end
        
        # Use fzf to select
        set name (printf '%s\n' $worktrees | fzf --prompt="Select worktree: " --height=40%)
        
        # Exit if user cancelled
        if test -z "$name"
            return 0
        end
    end
    
    set -l worktree_path "$repo_root/$WORKTREES_PATH/$name"
    
    if not test -d $worktree_path
        echo "Error: Worktree '$name' not found" >&2
        return 1
    end
    
    # Don't change directory, just open muxit
    cd $current_dir  # Go back to original directory
    
    # Check if muxit function exists
    if functions -q muxit
        muxit $worktree_path
    else if command -q muxit
        muxit $worktree_path
    else
        echo "Error: muxit not found" >&2
        echo "Would open: $worktree_path"
    end
end

# Alias
function wt_sw
    wt_switch $argv
end