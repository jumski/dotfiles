#!/usr/bin/env fish
# Switch to worktree using muxit

function wt_switch
    set -l name $argv[1]
    set -l repo_path $argv[2]  # Optional repo path
    
    # If repo_path provided, use it. Otherwise find repo root from current dir
    set -l repo_root
    if test -n "$repo_path"
        set repo_root $repo_path
    else
        _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
        or return 1
        set repo_root (_wt_get_repo_root)
    end
    
    set -l current_dir (pwd)
    cd $repo_root
    _wt_get_repo_config
    
    # If no name provided, use fzf to select
    if test -z "$name"
        if not command -q fzf
            echo "Error: fzf required for interactive selection" >&2
            echo "Install fzf or provide worktree name: wt switch <name>" >&2
            return 1
        end
        
        # Get list of worktrees
        set -l worktrees (_wt_get_worktrees)
        
        if test (count $worktrees) -eq 0
            echo "No worktrees found"
            return 1
        end
        
        # Use fzf to select
        set name (printf '%s\n' $worktrees | fzf --prompt="Select worktree: " --height=40%)
        
        # Exit if user cancelled
        if test -z "$name"
            return 0
        end
    end
    
    set -l worktree_path "$repo_root/$WORKTREES_PATH/$name"
    
    if not test -d $worktree_path
        echo "Error: Worktree '$name' not found" >&2
        return 1
    end
    
    # Don't change directory, just open muxit
    cd $current_dir  # Go back to original directory
    
    # Get repo name from config
    set -l repo_name $REPO_NAME
    if test -z "$repo_name"
        # Fallback to directory name if not in config
        set repo_name (basename $repo_root)
    end

    # Create custom session name using shared utility
    set -l session_name (_wt_get_session_name $name $repo_name)
    
    # Check if session already exists
    if tmux has-session -t $session_name 2>/dev/null
        # Session exists - switch or attach
        echo -e "\033[34m→\033[0m Switching to existing session: $session_name"
        if test -n "$TMUX"
            tmux switch-client -t $session_name
        else
            tmux attach-session -t $session_name
        end
    else
        # Create new session with windows
        echo -e "\033[34m→\033[0m Creating new tmux session: $session_name"
        if test -n "$TMUX"
            # Inside tmux - create detached and switch
            tmux \
                new-session -d -c "$worktree_path" -s $session_name \;\
                rename-window -t $session_name:1 server \;\
                new-window -n bash -c "$worktree_path" -t $session_name \;\
                new-window -n vim -c "$worktree_path" -t $session_name \;\
                new-window -n repl -c "$worktree_path" -t $session_name
            tmux switch-client -t $session_name
        else
            # Outside tmux - create and attach
            tmux \
                new-session -d -c "$worktree_path" -s $session_name \;\
                rename-window -t $session_name:1 server \;\
                new-window -n bash -c "$worktree_path" -t $session_name \;\
                new-window -n vim -c "$worktree_path" -t $session_name \;\
                new-window -n repl -c "$worktree_path" -t $session_name \;\
                attach-session -t $session_name
        end
    end
end

# Alias
function wt_sw
    wt_switch $argv
end