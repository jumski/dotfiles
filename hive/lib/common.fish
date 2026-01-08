#!/usr/bin/env fish
# Common utilities and configuration for Hive

# Environment Variables
set -g HIVE_VERSION "0.1.0"

# Check if a session is a hive session
# Usage: _hive_is_hive_session [session_name]
# Returns 0 if it's a hive session, 1 otherwise
function _hive_is_hive_session
    set -l session_name $argv[1]
    
    if test -z "$session_name"
        set session_name (tmux display-message -p '#S' 2>/dev/null)
    end
    
    if test -z "$session_name"
        return 1
    end
    
    set -l hive_val (tmux show-options -t "$session_name" -qv @hive 2>/dev/null)
    test "$hive_val" = 'true'
end

# Get session name from path
# Usage: _hive_get_session_name <path>
# Returns: repo basename (e.g., "pgflow", "dotfiles")
function _hive_get_session_name
    set -l path $argv[1]
    
    if test -z "$path"
        echo "Error: path required" >&2
        return 1
    end
    
    # Normalize path
    set path (realpath "$path" 2>/dev/null; or echo "$path")
    
    # Special case: .dotfiles
    if string match -q "*/.dotfiles*" "$path"; or string match -q "*/.dotfiles" "$path"
        echo "dotfiles"
        return 0
    end
    
    # Worktree path: extract repo name from parent of worktrees/
    # e.g., ~/Code/org/repo/worktrees/feature -> repo
    if string match -q "*/worktrees/*" "$path"
        set -l parent_path (string replace -r '/worktrees/[^/]+/?$' '' "$path")
        basename "$parent_path"
        return 0
    end
    
    # Regular repo: just use basename
    # e.g., ~/Code/org/repo -> repo
    basename "$path"
end

# Get window/worktree name from path
# Usage: _hive_get_window_name <path>
# Returns: worktree name or "main" for regular repos
function _hive_get_window_name
    set -l path $argv[1]
    
    if test -z "$path"
        echo "Error: path required" >&2
        return 1
    end
    
    # Normalize path
    set path (realpath "$path" 2>/dev/null; or echo "$path")
    
    # Special case: .dotfiles
    if string match -q "*/.dotfiles*" "$path"; or string match -q "*/.dotfiles" "$path"
        echo "dotfiles"
        return 0
    end
    
    # Worktree path: extract worktree name from after worktrees/
    # e.g., ~/Code/org/repo/worktrees/feature -> feature
    if string match -q "*/worktrees/*" "$path"
        # Extract just the worktree name (first component after worktrees/)
        set -l after_worktrees (string replace -r '.*/worktrees/' '' "$path")
        echo (string split "/" $after_worktrees)[1]
        return 0
    end
    
    # Regular repo: default to "main"
    echo "main"
end

# List all hive sessions
# Usage: _hive_list_sessions
# Returns: newline-separated list of hive session names
function _hive_list_sessions
    tmux list-sessions -F '#{session_name}' 2>/dev/null | while read session
        set -l hive_val (tmux show-options -t "$session" -qv @hive 2>/dev/null)
        if test "$hive_val" = 'true'
            echo $session
        end
    end
end

# List windows in a session
# Usage: _hive_list_windows <session_name>
# Returns: newline-separated list of "index:name" format
function _hive_list_windows
    set -l session_name $argv[1]
    
    if test -z "$session_name"
        echo "Error: session name required" >&2
        return 1
    end
    
    tmux list-windows -t "$session_name" -F '#{window_index}:#{window_name}' 2>/dev/null
end

# Get window names in a session (just the names, no indices)
# Usage: _hive_get_window_names <session_name>
function _hive_get_window_names
    set -l session_name $argv[1]
    tmux list-windows -t "$session_name" -F '#{window_name}' 2>/dev/null
end

# Check if a window with given name exists in session
# Usage: _hive_window_exists <session_name> <window_name>
function _hive_window_exists
    set -l session_name $argv[1]
    set -l window_name $argv[2]
    
    _hive_get_window_names "$session_name" | string match -q "$window_name"
end

# Get full path from muxit cache entry
# Usage: _hive_resolve_path <cache_entry>
# Returns: full filesystem path
function _hive_resolve_path
    set -l entry $argv[1]
    
    if test -z "$entry"
        return 1
    end
    
    # .dotfiles special case
    if test "$entry" = ".dotfiles"
        echo "$HOME/.dotfiles"
        return 0
    end
    
    # Everything else is under ~/Code
    echo "$HOME/Code/$entry"
end

# Pick a worktree using fzf
# Usage: _hive_pick_worktree
# Returns: full path to selected worktree
function _hive_pick_worktree
    set -l cache_file ~/.cache/muxit-projects
    
    if not test -f "$cache_file"
        echo "Error: muxit cache not found. Run muxit-update-cache first." >&2
        return 1
    end
    
    set -l selection (cat "$cache_file" | fzf --prompt='Worktree: ' --height=40%)
    
    if test -z "$selection"
        return 1
    end
    
    _hive_resolve_path "$selection"
end

# Pick destination (new session or existing hive session)
# Usage: _hive_pick_destination
# Returns: "new-session" or session name
function _hive_pick_destination
    set -l sessions (_hive_list_sessions)
    
    set -l options "[+] New Session"
    for s in $sessions
        set -a options $s
    end
    
    set -l choice (printf '%s\n' $options | fzf --prompt='Destination: ' --height=40%)
    
    if test -z "$choice"
        echo "cancel"
        return 1
    end
    
    if test "$choice" = "[+] New Session"
        echo "new-session"
    else
        echo "$choice"
    end
end

# Pick window target (new window or existing window)
# Usage: _hive_pick_window <session_name>
# Returns: "new-window" or window index
function _hive_pick_window
    set -l session_name $argv[1]
    
    set -l windows (_hive_list_windows "$session_name")
    
    set -l options "[+] New Window"
    for w in $windows
        set -a options $w
    end
    
    set -l choice (printf '%s\n' $options | fzf --prompt='Window: ' --height=40%)
    
    if test -z "$choice"
        echo "cancel"
        return 1
    end
    
    if test "$choice" = "[+] New Window"
        echo "new-window"
    else
        # Extract window index (before the colon)
        echo $choice | cut -d: -f1
    end
end

# Print colored status message
function _hive_action
    set -l message $argv[1]
    echo -e "\033[34m->\033[0m $message"
end

function _hive_success
    set -l message $argv[1]
    echo -e "\033[32m+\033[0m $message"
end

function _hive_error
    set -l message $argv[1]
    echo -e "\033[31m!\033[0m $message" >&2
end
