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
    
    # Regular repo: use directory name
    basename "$path"
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
    
    set -l selection (cat "$cache_file" | fzf --prompt='Worktree: ')
    
    if test -z "$selection"
        return 1
    end
    
    _hive_resolve_path "$selection"
end

# Pick a path using fzf (current directory, custom path, or worktree)
# Usage: _hive_pick_path
# Returns: full path to selected location
function _hive_pick_path
    set -l cache_file ~/.cache/muxit-projects
    set -l current_dir (pwd)
    set -l current_dir_display "$current_dir"
    
    # Shorten display for current directory if under home
    set -l home_display (string replace -r "^$HOME" "~" "$current_dir_display")
    
    set -l options "$current_dir_display|Current directory" "Custom path"
    
    # Add muxit worktrees if cache exists
    if test -f "$cache_file"
        for entry in (cat "$cache_file")
            set -l resolved (_hive_resolve_path "$entry")
            set -l display (string replace -r "^$HOME" "~" "$resolved")
            set -a options "$resolved|$display"
        end
    end
    
    set -l selection (printf '%s\n' $options | cut -d'|' -f2 | fzf --prompt='Path: ' --header="Press Enter for $home_display")
    
    if test -z "$selection"
        return 1
    end
    
    if test "$selection" = "Custom path"
        read -l -P "Enter path: " custom_path
        
        if test -z "$custom_path"
            return 1
        end
        
        # Expand ~ to home
        set custom_path (string replace -r "^~" "$HOME" "$custom_path")
        
        if not test -d "$custom_path"
            echo "Error: Directory not found: $custom_path" >&2
            return 1
        end
        
        realpath "$custom_path"
        return 0
    end
    
    # Find the full path from selection
    for opt in $options
        if string match -q "*|$selection" "$opt"
            set -l full_path (string split '|' "$opt")[1]
            echo "$full_path"
            return 0
        end
    end
    
    return 1
end

# Pick destination (new session or existing hive session)
# Usage: _hive_pick_destination
# Returns: "new-session" or session name
function _hive_pick_destination
    set -l sessions (_hive_list_sessions)
    set -l current_session ""
    
    # Get current session if in tmux
    if test -n "$TMUX"
        set current_session (tmux display-message -p '#S' 2>/dev/null)
    end
    
    # Build options list - current session first (so it's highlighted)
    set -l options
    
    set -l is_current_hive false
    if test -n "$current_session"; and _hive_is_hive_session "$current_session"
        set is_current_hive true
    end

    if test "$is_current_hive" = true
        # Current session is a hive session - put it first (highlighted)
        set -a options "$current_session"
        # Then add "[+] New Session"
        set -a options "[+] New Session"
    else
        # Not in a hive session - just show "[+] New Session" first
        set -a options "[+] New Session"
    end
    
    # Add other hive sessions (exclude current if already added)
    for s in $sessions
        if test "$s" != "$current_session"
            set -a options $s
        end
    end
    
    set -l choice (printf '%s\n' $options | fzf --prompt='Destination: ')
    
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
    
    set -l choice (printf '%s\n' $options | fzf --prompt='Window: ')
    
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

# Get next available window name with auto-suffix
# Usage: _hive_next_window_name <session_name> <base_name>
# Returns: base_name, base_name-2, base_name-3, etc.
function _hive_next_window_name
    set -l session_name $argv[1]
    set -l base_name $argv[2]
    
    if test -z "$session_name"
        echo "$base_name"
        return 0
    end
    
    set -l counter 1
    set -l candidate "$base_name"
    
    while _hive_window_exists "$session_name" "$candidate"
        set counter (math $counter + 1)
        set candidate "$base_name-$counter"
    end
    
    echo "$candidate"
end

# Prompt for window name with default preselected
# Usage: _hive_prompt_window_name <session_name> <base_name>
# Returns: selected window name
function _hive_prompt_window_name
    set -l session_name $argv[1]
    set -l base_name $argv[2]
    
    set -l suggested (_hive_next_window_name "$session_name" "$base_name")
    
    set -l choices "$suggested" "Custom name"
    set -l choice (printf '%s\n' $choices | fzf --prompt='Window name: ' --header="Press Enter for $suggested or select 'Custom name'")
    
    if test -z "$choice"
        echo "$suggested"
        return 0
    end
    
    if test "$choice" = "Custom name"
        read -l -P "Enter window name: " custom_name
        
        if test -z "$custom_name"
            echo "$suggested"
            return 0
        end
        
        # Auto-suffix if custom name collides
        set -l resolved (_hive_next_window_name "$session_name" "$custom_name")
        echo "$resolved"
    else
        echo "$choice"
    end
end
