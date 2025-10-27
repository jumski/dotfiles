#!/usr/bin/env fish
# Navigate down in stack

function wt_down
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt down

Navigate down in the Graphite stack to the parent branch"
    and return 0

    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1

    # Get parent branch
    set -l parent (gt log --parent 2>/dev/null | head -1)

    if test -z "$parent"
        echo "No parent branch found"
        return 1
    end

    # Find worktree for this branch
    set -l repo_root (_wt_get_repo_root)
    set -l saved_pwd (pwd)
    cd $repo_root
    _wt_get_repo_config

    for worktree_dir in $WORKTREES_PATH/*
        if test -d $worktree_dir
            set -l branch (git -C $worktree_dir branch --show-current 2>/dev/null)
            if test "$branch" = "$parent"
                echo "Switching to parent: $parent"
                cd $saved_pwd
                wt_switch (basename $worktree_dir)
                return 0
            end
        end
    end

    echo "Warning: No worktree found for parent branch '$parent'"
    cd $saved_pwd
end
