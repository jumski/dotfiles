#!/usr/bin/env fish
# Add a window to an existing hive session

function hive_window
    argparse 'h/help' 'p/path=' 's/session-name=' 'w/window-name=' -- $argv
    or return 1
    
    if set -q _flag_help
        echo "Usage: hive window <worktree_path> [session_name] [options]"
        echo ""
        echo "Adds a new window to an existing hive session."
        echo "If session_name is omitted, uses the current session."
        echo "Window name is derived from the worktree/branch name."
        echo ""
        echo "Options:"
        echo "  -p, --path <path>           Path to directory (overrides positional arg)"
        echo "  -s, --session-name <name>   Hive session to add window to"
        echo "  -w, --window-name <name>    Custom window name"
        echo "  -h, --help                  Show this help"
        echo ""
        echo "If --window-name is not provided, you'll be prompted for a name."
        return 0
    end
    
    set -l worktree_path $argv[1]
    
    # Use --path flag if provided
    if set -q _flag_path
        set worktree_path $_flag_path
    end
    
    set -l session_name $argv[2]
    
    # Use --session-name flag if provided
    if set -q _flag_session_name
        set session_name $_flag_session_name
    end
    
    # Require path argument
    if test -z "$worktree_path"
        _hive_error "Path required (use positional arg or --path)"
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
    
    # Determine window name
    set -l window_name
    
    if set -q _flag_window_name
        # Use provided name with auto-suffix
        set window_name (_hive_next_window_name "$session_name" "$_flag_window_name")
    else
        # Prompt for name
        set -l base_name (_hive_get_window_name "$worktree_path")
        set window_name (_hive_prompt_window_name "$session_name" "$base_name")
    end
    
    _hive_action "Adding window '$window_name' to session '$session_name'"

    # Create the window (-a appends at next available index)
    tmux new-window -a -t "$session_name" -n "$window_name" -c "$worktree_path"

    _hive_success "Added window '$window_name' to '$session_name'"
end
