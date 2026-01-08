#!/usr/bin/env fish
# Create a new hive session from a worktree path

function hive_session
    set -l worktree_path $argv[1]
    
    # Show help if requested
    if test "$worktree_path" = "--help" -o "$worktree_path" = "-h"
        echo "Usage: hive session <worktree_path>"
        echo ""
        echo "Creates a new hive-marked tmux session for the given worktree."
        echo "Session name is derived from the repository name."
        echo "Window name is derived from the worktree/branch name."
        return 0
    end
    
    # Require path argument
    if test -z "$worktree_path"
        _hive_error "Worktree path required"
        echo "Usage: hive session <worktree_path>"
        return 1
    end
    
    # Resolve to absolute path
    if not test -d "$worktree_path"
        _hive_error "Directory not found: $worktree_path"
        return 1
    end
    set worktree_path (realpath "$worktree_path")
    
    # Derive names
    set -l session_name (_hive_get_session_name "$worktree_path")
    set -l window_name (_hive_get_window_name "$worktree_path")
    
    # Check if session already exists
    if tmux has-session -t "=$session_name" 2>/dev/null
        _hive_error "Session '$session_name' already exists"
        return 1
    end
    
    _hive_action "Creating hive session: $session_name"
    
    # Create session with @hive marker
    if test -n "$TMUX"
        # Inside tmux: create detached then switch
        tmux new-session -d -c "$worktree_path" -s "$session_name"
        tmux set-option -t "$session_name" @hive true
        tmux rename-window -t "$session_name:1" "$window_name"
        tmux switch-client -t "$session_name"
    else
        # Outside tmux: create detached, set options, then attach
        tmux new-session -d -c "$worktree_path" -s "$session_name"
        tmux set-option -t "$session_name" @hive true
        tmux rename-window -t "$session_name:1" "$window_name"
        tmux attach-session -t "$session_name"
    end
    
    _hive_success "Created hive session '$session_name' with window '$window_name'"
end
