#!/usr/bin/env fish
# Create stacked branch using Graphite and create worktree for it

function wt_create
    set -l branch_name ""
    set -l switch_after false
    set -l gt_args
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    # Parse arguments - separate wt-specific from gt create args
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --switch
                set switch_after true
            case '*'
                # Everything else goes to gt create
                set -a gt_args $argv[$i]
                # If this is a branch name (first non-flag arg), capture it
                if not string match -q -- '-*' $argv[$i]
                    and test -z "$branch_name"
                    set branch_name $argv[$i]
                end
        end
        set i (math $i + 1)
    end
    
    # Get current branch to restore later
    set -l original_branch (git branch --show-current)
    if test -z "$original_branch"
        echo "Error: Not on a branch" >&2
        return 1
    end
    
    echo -e "\033[34m→\033[0m Creating stacked branch with Graphite..."
    
    # Run gt create with all passed arguments (except --switch)
    gt create $gt_args
    or begin
        echo "Error: Failed to create branch with Graphite" >&2
        return 1
    end
    
    # Get the newly created branch name (we're now on it)
    set -l new_branch (git branch --show-current)
    
    if test "$new_branch" = "$original_branch"
        echo "Error: Branch was not created or switched" >&2
        return 1
    end
    
    echo -e "\033[32m✓\033[0m Created branch '$new_branch' stacked on '$original_branch'"
    
    # Switch back to original branch in current worktree
    echo -e "\033[34m→\033[0m Switching back to '$original_branch' in current worktree..."
    git switch $original_branch --quiet
    or begin
        echo "Error: Failed to switch back to original branch" >&2
        return 1
    end
    
    # Create worktree for the new branch using wt_new
    echo -e "\033[34m→\033[0m Creating worktree for '$new_branch'..."
    
    # Build wt_new arguments
    set -l wt_new_args $new_branch --force-new
    if test "$switch_after" = "true"
        set -a wt_new_args --switch
    end
    
    # Call wt_new to create the worktree
    wt_new $wt_new_args
    or begin
        echo "Error: Failed to create worktree for branch '$new_branch'" >&2
        return 1
    end
    
    if test "$switch_after" = "false"
        echo -e "\033[32m✓\033[0m Staying in current worktree on branch '$original_branch'"
        echo -e "\033[90m  Use 'wt switch $new_branch' to switch to the new worktree\033[0m"
    end
end