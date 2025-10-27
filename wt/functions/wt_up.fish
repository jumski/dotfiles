#!/usr/bin/env fish
# Navigate up in stack

function wt_up
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt up

Navigate up in the Graphite stack to the upstack branch"
    and return 0

    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1

    # Get upstack branch
    set -l upstack (gt log --upstack 2>/dev/null | head -2 | tail -1)

    if test -z "$upstack"
        echo "No upstack branch found"
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
            if test "$branch" = "$upstack"
                echo "Switching to upstack: $upstack"
                cd $saved_pwd
                wt_switch (basename $worktree_dir)
                return 0
            end
        end
    end

    echo "Warning: No worktree found for upstack branch '$upstack'"
    echo "Create with: wt new $upstack --from (git branch --show-current)"
    cd $saved_pwd
end
