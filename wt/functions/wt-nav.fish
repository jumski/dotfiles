#!/usr/bin/env fish
# Navigation commands (up, down, bottom)

# Navigate up in stack
function wt_up
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

# Navigate down in stack
function wt_down
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

# Navigate to stack bottom
function wt_bottom
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    # Get stack bottom
    set -l bottom (gt stack bottom 2>/dev/null | string match -r "Bottom of stack: (.*)" | string replace -r "Bottom of stack: " "")
    
    if test -z "$bottom"
        echo "Could not determine stack bottom"
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
            if test "$branch" = "$bottom"
                echo "Switching to stack bottom: $bottom"
                cd $saved_pwd
                wt_switch (basename $worktree_dir)
                return 0
            end
        end
    end
    
    echo "Warning: No worktree found for stack bottom '$bottom'"
    cd $saved_pwd
end