function __mksupa_new_temp -d "Create new temporary Supabase project"
    set -l prefix $argv[1]
    set -l base_dir "$HOME/Code/pgflow-dev/supatemp"

    # Ensure base directory exists
    if not test -d "$base_dir"
        echo "Creating base directory: $base_dir"
        mkdir -p "$base_dir"
    end

    # Create temporary directory with prefix
    set -l temp_dir (mktemp -d "$base_dir/$prefix-XXXXXX")
    if test $status -ne 0
        echo "Error: Failed to create temporary directory"
        return 1
    end

    set -l dir_name (basename "$temp_dir")
    set -l session_name "supatemp-$dir_name"

    # Create tmux session with 4 windows
    # new-session creates window 0, then we add 3 more windows (1, 2, 3)
    tmux new-session -d -s "$session_name" -c "$temp_dir"
    tmux new-window -t "$session_name" -c "$temp_dir"
    tmux new-window -t "$session_name" -c "$temp_dir"
    tmux new-window -t "$session_name" -c "$temp_dir"

    # Trigger mksupa --init in window 1 (second window, 0-indexed)
    tmux send-keys -t "$session_name:1" "mksupa --init" C-m

    # Pretty print information
    echo ""
    echo "✨ Created new Supabase temp project"
    echo ""
    echo "  Directory: $temp_dir"
    echo "  Session:   $session_name"
    echo ""

    # Ask user if should switch to session
    read -l -P "Switch to this tmux session? [y/N] " response

    if test "$response" = "y" -o "$response" = "Y"
        # Check if we're inside tmux
        if test -n "$TMUX"
            # Inside tmux - use switch-client
            tmux switch-client -t "$session_name"
            tmux select-window -t "$session_name:1"
        else
            # Outside tmux - use attach-session
            tmux attach-session -t "$session_name"
            tmux select-window -t "$session_name:1"
        end
    else
        if test -n "$TMUX"
            echo "Session created but not switched. Use: tmux switch-client -t \"$session_name\""
        else
            echo "Session created but not attached. Use: tmux attach-session -t \"$session_name\""
        end
    end
end
