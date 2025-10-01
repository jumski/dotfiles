#!/usr/bin/env fish
# Create new branch (via Graphite if available) and worktree for it

function wt_branch
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

    # ============================================================
    # PHASE 1: GATHER - Collect all information (read-only)
    # ============================================================

    # Get current branch to restore later
    set -l original_branch (git branch --show-current)
    if test -z "$original_branch"
        echo "Error: Not on a branch" >&2
        return 1
    end

    # Check if target branch already exists
    set -l branch_exists false
    if test -n "$branch_name"
        git show-ref --verify --quiet refs/heads/$branch_name
        and set branch_exists true
    end

    # Check if Graphite is available and get trunk
    set -l has_graphite false
    set -l trunk_branch "main"

    if command -q gt
        set trunk_branch (gt trunk 2>/dev/null)
        if test -n "$trunk_branch"
            set has_graphite true
        else
            set trunk_branch "main"
        end
    end

    # Check if current branch is tracked by Graphite
    set -l current_branch_tracked false
    if test $has_graphite = true
        gt branch info $original_branch 2>/dev/null >/dev/null
        and set current_branch_tracked true
    end

    # Check if target branch is tracked by Graphite (if it exists)
    set -l target_branch_tracked false
    if test $branch_exists = true -a $has_graphite = true
        gt branch info $branch_name 2>/dev/null >/dev/null
        and set target_branch_tracked true
    end

    # Determine actions needed
    set -l will_create_branch false
    if test $branch_exists = false
        set will_create_branch true
    end

    set -l will_use_graphite_create false
    if test $will_create_branch = true -a $current_branch_tracked = true
        set will_use_graphite_create true
    end

    set -l can_track_with_graphite false
    if test $branch_exists = true -a $has_graphite = true -a $target_branch_tracked = false
        set can_track_with_graphite true
    end

    # Validate branch name is provided
    if test -z "$branch_name"
        echo "Error: Branch name is required" >&2
        echo -e "\033[90m  Usage: wt branch <branch-name> [--switch]\033[0m" >&2
        return 1
    end

    # ============================================================
    # PHASE 2: PLAN - Show user what will happen
    # ============================================================

    echo ""
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    if test $branch_exists = true
        echo -e "\033[1;36m  Worktree for Existing Branch\033[0m"
    else if test $will_use_graphite_create = true
        echo -e "\033[1;36m  Graphite Branch + Worktree\033[0m"
    else
        echo -e "\033[1;36m  Git Branch + Worktree\033[0m"
    end
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo -e "\033[33m  Current:\033[0m \033[1m$original_branch\033[0m"

    if test $branch_exists = true
        echo -e "\033[33m  Target: \033[0m \033[1m$branch_name\033[0m \033[90m(exists)\033[0m"
        if test $target_branch_tracked = true
            echo -e "\033[32m  Graphite:\033[0m \033[1;32mtracked\033[0m"
        else if test $has_graphite = true
            echo -e "\033[33m  Graphite:\033[0m \033[1;33muntracked\033[0m"
        end
    else
        echo -e "\033[33m  New:    \033[0m \033[1m$branch_name\033[0m"

        if test $will_use_graphite_create = true
            if test "$original_branch" = "$trunk_branch"
                echo -e "\033[32m  Base:   \033[0m \033[1;32m$trunk_branch\033[0m \033[90m(trunk)\033[0m"
            else
                echo -e "\033[31m  Base:   \033[0m \033[1;31m$original_branch\033[0m \033[90m(NOT trunk)\033[0m"
            end
        else
            echo -e "\033[32m  Base:   \033[0m \033[1;32m$original_branch\033[0m"
        end
    end

    echo ""
    echo -e "\033[1mWill:\033[0m"

    if test $branch_exists = true
        echo -e "\033[32m  ✓\033[0m Use existing '\033[1m$branch_name\033[0m'"
    else
        if test $will_use_graphite_create = true
            echo -e "\033[32m  ✓\033[0m Create with Graphite, stack on '\033[1m$original_branch\033[0m'"
            if test "$original_branch" != "$trunk_branch"
                echo -e "\033[33m    ⚠\033[0m Stacking on '\033[1m$original_branch\033[0m', not trunk"
            end
        else
            echo -e "\033[32m  ✓\033[0m Create from '\033[1m$original_branch\033[0m'"
        end
    end

    echo -e "\033[32m  ✓\033[0m Create worktree"

    if test $switch_after = true
        echo -e "\033[32m  ✓\033[0m Switch to worktree"
    else
        echo -e "\033[90m  →\033[0m Stay in current worktree"
    end

    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    # ============================================================
    # PHASE 3: QUESTIONS - Ask all questions upfront
    # ============================================================

    set -l should_track_with_graphite false

    # Ask about Graphite tracking if applicable
    if test $can_track_with_graphite = true
        _wt_confirm --prompt "Track '$branch_name' with Graphite on '$original_branch'" --default-yes
        and set should_track_with_graphite true

        echo ""
    end

    # Final confirmation
    _wt_confirm --prompt "Proceed" --default-yes
    or begin
        echo -e "\033[90mCancelled\033[0m"
        return 1
    end

    echo ""

    # ============================================================
    # PHASE 4: EXECUTE - Do all the work (no more prompts)
    # ============================================================

    # Track with Graphite if decided
    if test $should_track_with_graphite = true
        echo -e "\033[34m→\033[0m Tracking with Graphite..."
        git checkout $branch_name --quiet
        or begin
            echo "Error: Failed to checkout '$branch_name'" >&2
            return 1
        end

        gt branch track --parent $original_branch 2>&1
        set -l track_status $status

        git checkout $original_branch --quiet

        if test $track_status -ne 0
            echo "Warning: Failed to track with Graphite" >&2
            # Continue anyway - worktree can still be created
        else
            echo -e "\033[32m✓\033[0m Tracked with Graphite"
        end
    end

    # Create branch if it doesn't exist
    set -l new_branch ""
    if test $will_create_branch = true
        if test $will_use_graphite_create = true
            echo -e "\033[34m→\033[0m Creating with Graphite..."

            gt create $gt_args
            or begin
                echo "Error: Failed to create with Graphite" >&2
                return 1
            end
        else
            echo -e "\033[34m→\033[0m Creating with git..."

            git checkout -b $branch_name
            or begin
                echo "Error: Failed to create '$branch_name'" >&2
                return 1
            end
        end

        # Get the newly created branch name (we're now on it)
        set new_branch (git branch --show-current)

        if test "$new_branch" = "$original_branch"
            echo "Error: Branch was not created" >&2
            return 1
        end

        if test $will_use_graphite_create = true
            echo -e "\033[32m✓\033[0m Created '$new_branch' stacked on '$original_branch'"
        else
            echo -e "\033[32m✓\033[0m Created '$new_branch' from '$original_branch'"
        end

        # Switch back to original branch
        echo -e "\033[34m→\033[0m Returning to '$original_branch'..."
        git switch $original_branch --quiet
        or begin
            echo "Error: Failed to return to '$original_branch'" >&2
            return 1
        end
    else
        # Branch already exists, use it
        set new_branch $branch_name
        echo -e "\033[32m✓\033[0m Using existing '$new_branch'"
    end

    # Create worktree using wt_new
    echo -e "\033[34m→\033[0m Creating worktree..."

    # Build wt_new arguments
    set -l wt_new_args $new_branch --force-new
    if test $switch_after = true
        set -a wt_new_args --switch
    end

    # Call wt_new to create the worktree
    wt_new $wt_new_args
    or begin
        echo "Error: Failed to create worktree for '$new_branch'" >&2
        return 1
    end

    if test $switch_after = false
        echo -e "\033[32m✓\033[0m Staying on '$original_branch'"
        echo -e "\033[90m  Use 'wt switch $new_branch' to switch\033[0m"
    end
end