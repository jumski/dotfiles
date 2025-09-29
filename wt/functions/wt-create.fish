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

    # Check if Graphite is available and current branch is tracked
    set -l has_graphite false
    set -l trunk_branch "main"

    # Try to get repo info from Graphite - this will fail if not initialized
    if command -q gt
        # Check if this repo is initialized with Graphite by trying to get repo info
        gt repo 2>/dev/null >/dev/null
        if test $status -eq 0
            # Repo is initialized with Graphite, get the trunk
            set trunk_branch (gt trunk 2>/dev/null)
            if test -n "$trunk_branch"
                # Check if current branch is tracked by Graphite
                # gt branch info will succeed only if the branch is tracked
                gt branch info $original_branch 2>/dev/null >/dev/null
                if test $status -eq 0
                    set has_graphite true
                end
            else
                set trunk_branch "main"
            end
        end
    end

    # Always show what will happen
    echo ""
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    if test $has_graphite = true
        echo -e "\033[1;36m  Graphite Branch Creation\033[0m"
    else
        echo -e "\033[1;36m  Git Branch Creation\033[0m"
    end
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo -e "\033[33m  Current branch:\033[0m \033[1m$original_branch\033[0m"

    if test $has_graphite = true
        if test "$original_branch" = "$trunk_branch"
            echo -e "\033[32m  Base branch:   \033[0m \033[1;32m$trunk_branch\033[0m \033[90m(trunk)\033[0m"
            echo ""
            echo -e "\033[32m  ✓\033[0m Will create a new stack based on \033[1;32m$trunk_branch\033[0m"
        else
            echo -e "\033[31m  Base branch:   \033[0m \033[1;31m$original_branch\033[0m \033[90m(NOT trunk)\033[0m"
            echo ""
            echo -e "\033[31m  ⚠\033[0m Will stack on top of \033[1;31m$original_branch\033[0m, not \033[1m$trunk_branch\033[0m"
            echo -e "\033[90m    To start a new stack, switch to $trunk_branch first\033[0m"
        end
        echo ""
        echo -e "\033[90m  Command: gt create $gt_args\033[0m"
    else
        echo -e "\033[32m  Base branch:   \033[0m \033[1;32m$original_branch\033[0m"
        echo ""
        if test -z "$branch_name"
            echo -e "\033[31m  ⚠\033[0m No branch name provided"
            echo -e "\033[90m    Usage: wt create <branch-name>\033[0m"
            echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
            return 1
        end
        echo -e "\033[32m  ✓\033[0m Will create branch '\033[1m$branch_name\033[0m' from \033[1;32m$original_branch\033[0m"
        echo ""
        echo -e "\033[90m  Note: Current branch not tracked by Graphite, using standard git\033[0m"
    end
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    # Ask for confirmation to proceed
    read -l -P "$(echo -e '\033[1mProceed with branch creation?\033[0m (Y/n) ')" response
    set -l read_status $status

    # Check if read was interrupted (ctrl+c) or user said no
    if test $read_status -ne 0 -o "$response" = "n" -o "$response" = "N"
        echo -e "\033[90mCancelled\033[0m"
        return 1
    end

    echo ""

    if test $has_graphite = true
        echo -e "\033[34m→\033[0m Creating stacked branch with Graphite..."

        # Run gt create with all passed arguments (except --switch)
        gt create $gt_args
        or begin
            echo "Error: Failed to create branch with Graphite" >&2
            return 1
        end
    else
        echo -e "\033[34m→\033[0m Creating branch with git..."

        if test -z "$branch_name"
            echo "Error: Branch name is required when not using Graphite" >&2
            return 1
        end

        # Create and checkout the new branch
        git checkout -b $branch_name
        or begin
            echo "Error: Failed to create branch '$branch_name'" >&2
            return 1
        end
    end

    # Get the newly created branch name (we're now on it)
    set -l new_branch (git branch --show-current)
    
    if test "$new_branch" = "$original_branch"
        echo "Error: Branch was not created or switched" >&2
        return 1
    end
    
    if test $has_graphite = true
        echo -e "\033[32m✓\033[0m Created branch '$new_branch' stacked on '$original_branch'"
    else
        echo -e "\033[32m✓\033[0m Created branch '$new_branch' from '$original_branch'"
    end
    
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