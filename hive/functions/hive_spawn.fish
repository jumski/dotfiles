#!/usr/bin/env fish
# Interactive wizard to spawn worktree in hive session

function hive_spawn
    # Show help if requested
    if test "$argv[1]" = "--help" -o "$argv[1]" = "-h"
        echo "Usage: hive spawn"
        echo ""
        echo "Interactive wizard to open a worktree in a hive session."
        echo ""
        echo "Flow:"
        echo "  1. Select worktree from fzf picker"
        echo "  2. Select destination:"
        echo "     - [+] New Session - creates new hive session"
        echo "     - Existing hive session - proceed to step 3"
        echo "  3. Select window target (if existing session):"
        echo "     - [+] New Window - creates new window"
        echo "     - Existing window - splits that window"
        return 0
    end
    
    # Step 1: Select worktree
    set -l worktree_path (_hive_pick_worktree)
    if test -z "$worktree_path"
        return 0  # User cancelled
    end
    
    # Step 2: Select destination
    set -l destination (_hive_pick_destination)
    
    switch $destination
        case 'new-session'
            hive_session "$worktree_path"
            return $status
        case 'cancel'
            return 0
        case '*'
            # Selected existing session, go to step 3
            set -l session_name $destination
            set -l window_target (_hive_pick_window "$session_name")
            
            switch $window_target
                case 'new-window'
                    hive_window "$worktree_path" "$session_name"
                    # Switch to the session after adding window
                    if test -n "$TMUX"
                        tmux switch-client -t "$session_name"
                    else
                        tmux attach-session -t "$session_name"
                    end
                    return $status
                case 'cancel'
                    return 0
                case '*'
                    # Selected existing window, split it
                    # First switch to that window, then split
                    if test -n "$TMUX"
                        tmux switch-client -t "$session_name"
                        tmux select-window -t "$session_name:$window_target"
                    else
                        # Outside tmux, we need to attach first
                        tmux attach-session -t "$session_name" \; select-window -t "$window_target"
                    end
                    hive_split "$worktree_path"
                    return $status
            end
    end
end
