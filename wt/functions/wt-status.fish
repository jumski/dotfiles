#!/usr/bin/env fish
# Show status

function wt_status
    set -l show_all false
    
    if test "$argv[1]" = "--all"
        set show_all true
    end
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    set -l repo_root (_wt_get_repo_root)
    set -l current_worktree (basename (pwd))
    
    if test $show_all = true
        set -l saved_pwd (pwd)
        cd $repo_root
        _wt_get_repo_config
        
        echo "All worktrees status:"
        echo ""
        
        for worktree_dir in $WORKTREES_PATH/*
            if test -d $worktree_dir
                set -l name (basename $worktree_dir)
                set -l wt_status (_wt_get_worktree_status $worktree_dir)
                printf "%-20s %s\n" "$name:" "$wt_status"
            end
        end
        cd $saved_pwd
    else
        # Show current worktree status
        echo "Worktree: $current_worktree"
        
        set -l branch (git branch --show-current)
        echo "Branch: $branch"
        
        # Get stack info
        set -l stack_info (gt stack 2>/dev/null | string match -r "Current branch '.*' is on stack '(.*)'" | string replace -r ".*'(.*)'" '$1')
        if test -n "$stack_info"
            echo "Stack: $stack_info"
        end
        
        # Check sync status
        set -l wt_status (_wt_get_worktree_status (pwd))
        echo "Status: $wt_status"
        
        # Show modified files
        set -l modified_count (git status --porcelain | count)
        if test $modified_count -gt 0
            echo "Modified files: $modified_count"
        end
    end
end

# Alias
function wt_st
    wt_status $argv
end