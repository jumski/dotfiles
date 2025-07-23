#!/usr/bin/env fish
# Stack operations

function wt_stack
    set -l subcommand $argv[1]
    set -l remaining_args $argv[2..-1]
    
    switch $subcommand
        case list
            _wt_stack_list
        case sync
            _wt_stack_sync $remaining_args
        case '*'
            echo "Usage: wt stack [list|sync]"
            return 1
    end
end

# List all stacks
function _wt_stack_list
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

# Sync entire stack
function _wt_stack_sync
    set -l stack_name $argv[1]
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    if test -z "$stack_name"
        # Sync current stack
        set -l current_stack (gt stack 2>/dev/null | string match -r "on stack '(.*)'" | string replace -r ".*'(.*)'" '$1')
        if test -z "$current_stack"
            echo "Error: Not on a stack" >&2
            return 1
        end
        set stack_name $current_stack
    end
    
    echo "Syncing stack: $stack_name"
    
    set -l repo_root (_wt_get_repo_root)
    set -l saved_pwd (pwd)
    cd $repo_root
    _wt_get_repo_config
    
    # Find all worktrees in this stack
    set -l stack_worktrees
    
    for worktree_dir in $WORKTREES_PATH/*
        if test -d $worktree_dir
            set -l this_stack (gt -C $worktree_dir stack 2>/dev/null | string match -r "on stack '(.*)'" | string replace -r ".*'(.*)'" '$1')
            
            if test "$this_stack" = "$stack_name"
                set -a stack_worktrees $worktree_dir
            end
        end
    end
    
    # Sync each worktree in order
    for worktree in $stack_worktrees
        echo ""
        echo "🔄 Syncing $(basename $worktree)..."
        cd $worktree
        _wt_sync_single false false
    end
    
    echo ""
    echo "📤 Submitting stack..."
    gt submit --stack
    cd $saved_pwd
end