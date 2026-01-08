#!/usr/bin/env fish
# Split the current window with a new worktree pane

function hive_split
    set -l worktree_path $argv[1]
    
    # Show help if requested
    if test "$worktree_path" = "--help" -o "$worktree_path" = "-h"
        echo "Usage: hive split <worktree_path>"
        echo ""
        echo "Splits the current tmux window horizontally (side-by-side)"
        echo "with a new pane for the specified worktree."
        echo "Must be run from within a hive session."
        return 0
    end
    
    # Require path argument
    if test -z "$worktree_path"
        _hive_error "Worktree path required"
        echo "Usage: hive split <worktree_path>"
        return 1
    end
    
    # Must be in tmux
    if test -z "$TMUX"
        _hive_error "Not inside tmux"
        return 1
    end
    
    # Resolve to absolute path
    if not test -d "$worktree_path"
        _hive_error "Directory not found: $worktree_path"
        return 1
    end
    set worktree_path (realpath "$worktree_path")
    
    # Verify we're in a hive session
    set -l session_name (tmux display-message -p '#S')
    if not _hive_is_hive_session "$session_name"
        _hive_error "Not in a hive session"
        return 1
    end
    
    set -l worktree_name (_hive_get_window_name "$worktree_path")
    
    _hive_action "Splitting window with '$worktree_name'"
    
    # Horizontal split (side-by-side columns for ultrawide)
    tmux split-window -h -c "$worktree_path"
    
    _hive_success "Split window with '$worktree_name'"
end
