#!/usr/bin/env fish
# Stack list operation

# List all stacks
function wt_stack_list
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1

    set -l repo_root (_wt_get_repo_root)
    set -l saved_pwd (pwd)
    cd $repo_root
    _wt_get_repo_config

    # Get all branches with their stacks
    set -l stacks

    for worktree_dir in $WORKTREES_PATH/*
        if test -d $worktree_dir
            set -l branch (git -C $worktree_dir branch --show-current)
            set -l stack_info (gt -C $worktree_dir stack 2>/dev/null | string match -r "on stack '(.*)'" | string replace -r ".*'(.*)'" '$1')

            if test -n "$stack_info"
                # Add to stacks if not already present
                if not contains $stack_info $stacks
                    set -a stacks $stack_info
                end
            end
        end
    end

    if test (count $stacks) -eq 0
        echo "No stacks found"
        cd $saved_pwd
        return
    end

    # Display each stack
    for stack in $stacks
        echo "Stack: $stack"

        # Get all branches in this stack
        for worktree_dir in $WORKTREES_PATH/*
            if test -d $worktree_dir
                set -l branch (git -C $worktree_dir branch --show-current)
                set -l this_stack (gt -C $worktree_dir stack 2>/dev/null | string match -r "on stack '(.*)'" | string replace -r ".*'(.*)'" '$1')

                if test "$this_stack" = "$stack"
                    set -l status (_wt_get_worktree_status $worktree_dir)
                    set -l worktree_name (basename $worktree_dir)
                    printf "  ├─ %-20s [worktree: %-15s] %s\n" $branch "$worktree_name/" $status
                end
            end
        end

        echo ""
    end

    cd $saved_pwd
end
