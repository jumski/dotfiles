#!/usr/bin/env fish
# List all worktrees

function wt_list
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    set -l repo_root (_wt_get_repo_root)
    set -l current_dir (pwd)
    
    # Load config without changing directory
    set -l saved_pwd (pwd)
    cd $repo_root
    _wt_get_repo_config
    cd $saved_pwd
    
    echo "Worktrees in $REPO_NAME:"
    echo ""
    
    # Use the helper function to get worktrees
    set -l worktrees (_wt_get_worktrees)
    
    for wt_name in $worktrees
        set -l wt_path "$repo_root/$WORKTREES_PATH/$wt_name"
        
        # Get branch info
        set -l branch_info ""
        if test -d $wt_path
            set branch_info (git -C $wt_path branch --show-current 2>/dev/null)
        end
        
        # Check if current directory
        if test (realpath $wt_path 2>/dev/null) = (realpath $current_dir 2>/dev/null)
            echo -n "● $wt_name"
        else
            echo -n "  $wt_name"
        end
        
        # Show branch if different from worktree name
        if test -n "$branch_info" -a "$branch_info" != "$wt_name"
            echo " ($branch_info)"
        else
            echo ""
        end
    end
end

# Alias
function wt_ls
    wt_list $argv
end