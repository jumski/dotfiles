#!/usr/bin/env fish
# Remove worktree

function wt_remove
    set -l force_flag 0
    set -l name ""
    
    # Parse arguments
    for arg in $argv
        switch $arg
            case --force -f
                set force_flag 1
            case '-*'
                # Ignore other flags
            case '*'
                if test -z "$name"
                    set name $arg
                end
        end
    end
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    # If no name provided, try to get current worktree
    if test -z "$name"
        set name (_wt_get_current_worktree)
        if test -z "$name"
            echo "Error: Not in a worktree directory, please specify worktree name" >&2
            return 1
        end
        echo "Detected current worktree: $name"
    end
    
    set -l repo_root (_wt_get_repo_root)
    set -l saved_pwd (pwd)
    cd $repo_root
    _wt_get_repo_config
    
    set -l worktree_path "$WORKTREES_PATH/$name"
    set -l abs_worktree_path (realpath "$worktree_path" 2>/dev/null; or echo "$repo_root/$worktree_path")

    # Check if worktree exists in git or as directory
    # Use absolute path for git check since git worktree list returns absolute paths
    set -l git_has_worktree (git -C $BARE_PATH worktree list --porcelain | grep -q "^worktree $abs_worktree_path\$"; echo $status)
    set -l dir_exists (test -d $worktree_path; echo $status)
    
    if test $git_has_worktree -ne 0 -a $dir_exists -ne 0
        echo "Error: Worktree '$name' not found (neither in git nor as directory)" >&2
        return 1
    end
    
    # Confirm deletion
    echo -e "\033[34m→\033[0m This will remove worktree: $name"
    echo "Path: $worktree_path"
    
    if test $force_flag -eq 0
        read -P "Continue? [y/N] " -n 1 confirm
        
        if test "$confirm" != "y"
            echo "Cancelled"
            return 0
        end
    else
        echo "Force flag specified, proceeding without confirmation..."
    end
    
    # If we're removing the current worktree, move to repo root first
    set -l current_worktree (_wt_get_current_worktree)
    set -l original_session ""
    if test "$current_worktree" = "$name"
        echo "Moving out of current worktree before removal..."
        cd $repo_root
        # Remember the current tmux session for later check
        if set -q TMUX
            set original_session (tmux display-message -p '#S')
        end
    end
    
    # Remove worktree from git if it exists there
    if test $git_has_worktree -eq 0
        echo -e "\033[34m→\033[0m Removing worktree from git..."
        git -C $BARE_PATH worktree remove $worktree_path --force
        or echo "Warning: Failed to remove worktree from git, but continuing cleanup..." >&2
    else
        echo "Worktree not tracked by git, skipping git worktree remove"
    end
    
    # Remove directory if it exists
    if test $dir_exists -eq 0
        echo -e "\033[34m→\033[0m Removing worktree directory: $worktree_path"
        if not rm -rf $worktree_path
            echo "Error: Failed to remove directory $worktree_path" >&2
            return 1
        end
    else
        echo "Worktree directory doesn't exist, skipping directory removal"
    end
    
    # Remove branch if not checked out elsewhere
    echo -e "\033[34m→\033[0m Cleaning up branch..."
    git -C $BARE_PATH branch -d $name 2>/dev/null
    
    echo -e "\033[32m✓\033[0m Worktree '$name' removed"
    
    # Kill tmux session for the removed worktree if it exists
    set -l repo_name (basename $repo_root)
    set -l session_name "$name@$repo_name"
    if tmux has-session -t "$session_name" 2>/dev/null
        echo -e "\033[34m→\033[0m Killing tmux session: $session_name"
        tmux kill-session -t "$session_name"
    end
    
    # Switch to main worktree if we removed the current one and user is still in original session
    if test "$current_worktree" = "$name" -a -n "$original_session"
        set -l current_session ""
        if set -q TMUX
            set current_session (tmux display-message -p '#S')
        end
        
        if test "$current_session" = "$original_session"
            echo -e "\033[34m→\033[0m Switching to main@$repo_name"
            wt_switch "main"
        else
            echo "User switched to different session, skipping auto-switch"
        end
    end
    
    cd $saved_pwd
end

# Alias
function wt_rm
    wt_remove $argv
end