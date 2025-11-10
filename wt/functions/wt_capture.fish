#!/usr/bin/env fish
# Capture current branch to a new worktree

function wt_capture
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt capture [worktree-name] [--switch] [--from <branch>] [--force]

Capture current (or specified) branch to a new worktree

This command is designed for Graphite stacks: it creates a worktree for the
current branch and switches the original worktree to the parent branch.

Arguments:
  [worktree-name]    Name for new worktree (default: branch name)

Options:
  --switch           Switch to new worktree after creation (default: no)
  --from <branch>    Capture specific branch instead of current
  --force            Skip Graphite checks, use git reflog fallback

Examples:
  wt capture                    # Capture current branch
  wt capture --switch           # Capture and switch
  wt capture auth-hotfix        # Custom worktree name
  wt capture --from auth-api    # Capture different branch

Requirements:
  - Graphite must be installed (unless --force)
  - Branch must be tracked by Graphite (unless --force)
  - Cannot capture trunk branch"
    and return 0

    set -l worktree_name ""
    set -l branch_to_capture ""
    set -l switch_after false
    set -l force false

    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --switch
                set switch_after true
            case --from
                set i (math $i + 1)
                set branch_to_capture $argv[$i]
            case --force
                set force true
            case --yes
                # Pass through to wt new
            case '*'
                # First non-flag argument is worktree name
                if not string match -q -- '-*' $argv[$i]
                    if test -z "$worktree_name"
                        set worktree_name $argv[$i]
                    end
                end
        end
        set i (math $i + 1)
    end

    # Determine branch to capture
    if test -z "$branch_to_capture"
        set branch_to_capture (git branch --show-current)
        if test -z "$branch_to_capture"
            echo "Error: Not on a branch (detached HEAD)" >&2
            echo "  Use --from <branch> to specify branch to capture" >&2
            return 1
        end
    end

    # Default worktree name to branch name
    if test -z "$worktree_name"
        set worktree_name $branch_to_capture
    end

    # ============================================================
    # PHASE 1: SAFETY CHECKS
    # ============================================================

    # Check 1: Graphite available
    if not command -q gt
        if test $force = false
            echo "Error: Graphite (gt) required for wt capture" >&2
            echo "" >&2
            echo "Install Graphite:" >&2
            echo "  npm install -g @withgraphite/graphite-cli@stable" >&2
            echo "" >&2
            echo "Or use manual worktree creation:" >&2
            echo "  wt new <name> <branch>" >&2
            echo "" >&2
            echo "Or force using git reflog (less reliable):" >&2
            echo "  wt capture --force" >&2
            return 1
        else
            echo "Warning: Graphite not available, will use git reflog fallback" >&2
        end
    end

    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config

    # Check 2: Not on trunk
    set -l trunk_branch $DEFAULT_TRUNK
    if command -q gt
        set -l gt_trunk (gt trunk 2>/dev/null)
        if test -n "$gt_trunk"
            set trunk_branch $gt_trunk
        end
    end

    if test "$branch_to_capture" = "$trunk_branch"
        echo "Error: Cannot capture trunk branch '$trunk_branch'" >&2
        echo "  Trunk has no parent to switch back to" >&2
        echo "" >&2
        echo "Use instead:" >&2
        echo "  wt new <name>  # Create new worktree from trunk" >&2
        return 1
    end

    # Check 3: Branch is tracked by Graphite
    set -l is_tracked false
    if command -q gt
        if gt log short 2>/dev/null | grep -q "^$branch_to_capture\$"
            set is_tracked true
        end
    end

    if test $is_tracked = false -a $force = false
        echo "Error: Branch '$branch_to_capture' not tracked by Graphite" >&2
        echo "  Current branch must have a parent in the stack" >&2
        echo "" >&2
        echo "Track it first:" >&2
        echo "  gt branch track --parent <parent-branch>" >&2
        echo "" >&2
        echo "Or force (uses git reflog):" >&2
        echo "  wt capture --force" >&2
        return 1
    end

    # ============================================================
    # PHASE 2: PLAN & CONFIRM
    # ============================================================

    echo ""
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[1;36m  Capture Branch to Worktree\033[0m"
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    echo -e "\033[33m  Branch:  \033[0m \033[1m$branch_to_capture\033[0m"
    echo -e "\033[33m  Worktree:\033[0m \033[1m$worktree_name\033[0m"

    if test $is_tracked = true
        set -l parent_info (gt log short 2>/dev/null | grep -B1 "^$branch_to_capture\$" | head -1)
        if test -n "$parent_info"
            echo -e "\033[33m  Parent:  \033[0m \033[1;32m$parent_info\033[0m"
        end
    end

    echo ""
    echo -e "\033[1mWill:\033[0m"
    echo -e "\033[32m  ✓\033[0m Create worktree '\033[1m$worktree_name\033[0m' for branch '\033[1m$branch_to_capture\033[0m'"

    if test $is_tracked = true
        echo -e "\033[32m  ✓\033[0m Switch current worktree to parent branch (via gt down)"
    else if test $force = true
        echo -e "\033[33m  ⚠\033[0m Switch current worktree to previous branch (via git checkout -)"
        echo -e "\033[90m      Note: Using git reflog, may be unreliable\033[0m"
    end

    if test $switch_after = true
        echo -e "\033[32m  ✓\033[0m Switch to new worktree"
    else
        echo -e "\033[90m  →\033[0m Stay in current location"
    end

    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    # Confirm
    _wt_confirm --prompt "Proceed" --default-yes $argv
    or begin
        echo -e "\033[90mCancelled\033[0m"
        return 1
    end

    echo ""

    # ============================================================
    # PHASE 3: EXECUTE
    # ============================================================

    # Step 1: Switch current worktree to parent (MUST do this first!)
    _wt_action "Switching current worktree to parent..."

    if test $is_tracked = true
        # Use Graphite to navigate to parent
        gt down
        or begin
            echo "Error: Failed to switch to parent branch" >&2
            echo "  Cannot create worktree while branch is checked out here" >&2
            return 1
        end
    else if test $force = true
        # Fallback to git checkout -
        git checkout -
        or begin
            echo "Error: Failed to switch to previous branch" >&2
            echo "  Cannot create worktree while branch is checked out here" >&2
            return 1
        end
    end

    # Step 2: Create worktree for captured branch (now safe - branch not checked out)
    _wt_action "Creating worktree for '$branch_to_capture'..."

    wt_new $worktree_name $branch_to_capture --yes
    or begin
        echo "Error: Failed to create worktree" >&2
        return 1
    end

    echo ""
    _wt_success "Captured '$branch_to_capture' to worktree '$worktree_name'"

    # Step 3: Switch to new worktree if requested
    if test $switch_after = true
        wt_switch $worktree_name
    else
        echo -e "\033[90m  Use 'wt switch $worktree_name' to switch\033[0m"
    end
end
