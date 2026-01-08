#!/usr/bin/env fish
# Add a window to an existing hive session

function hive_window
    set -l worktree_path $argv[1]
    set -l session_name $argv[2]
    
    # Show help if requested
    if test "$worktree_path" = "--help" -o "$worktree_path" = "-h"
        echo "Usage: hive window <worktree_path> [session_name]"
        echo ""
        echo "Adds a new window to an existing hive session."
        echo "If session_name is omitted, uses the current session."
        echo "Window name is derived from the worktree/branch name."
        return 0
    end
    
    # Require path argument
    if test -z "$worktree_path"
        _hive_error "Worktree path required"
        echo "Usage: hive window <worktree_path> [session_name]"
        return 1
    end
    
    # Resolve to absolute path
    if not test -d "$worktree_path"
        _hive_error "Directory not found: $worktree_path"
        return 1
    end
    set worktree_path (realpath "$worktree_path")
    
    # Default to current session if not specified
    if test -z "$session_name"
        if test -z "$TMUX"
            _hive_error "Not in tmux and no session specified"
            return 1
        end
        set session_name (tmux display-message -p '#S')
    end
    
    # Verify it's a hive session
    if not _hive_is_hive_session "$session_name"
        _hive_error "'$session_name' is not a hive session"
        return 1
    end
    
    # Derive window name
    set -l window_name (_hive_get_window_name "$worktree_path")
    
    # Check for duplicate window name
    if _hive_window_exists "$session_name" "$window_name"
        _hive_error "Window '$window_name' already exists in session '$session_name'"
        return 1
    end
    
    _hive_action "Adding window '$window_name' to session '$session_name'"
    
    # Create the window
    tmux new-window -t "$session_name" -n "$window_name" -c "$worktree_path"
    
    _hive_success "Added window '$window_name' to '$session_name'"
end
