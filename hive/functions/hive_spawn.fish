#!/usr/bin/env fish
# Interactive wizard to spawn worktree in hive session

function hive_spawn
    argparse 'h/help' 'p/path=' 's/session-name=' 'w/window-name=' -- $argv
    or return 1
    
    if set -q _flag_help
        echo "Usage: hive spawn [options]"
        echo ""
        echo "Interactive wizard to open a worktree in a hive session."
        echo ""
        echo "Flow:"
        echo "  1. Select path (current dir, custom, or worktree from picker)"
        echo "  2. Select destination:"
        echo "     - [+] New Session - creates new hive session"
        echo "     - Existing hive session - proceed to step 3"
        echo "  3. Select window target (if existing session):"
        echo "     - [+] New Window - creates new window with name prompt"
        echo "     - Existing window - splits that window"
        echo ""
        echo "Options:"
        echo "  -p, --path <path>           Skip path picker (use this path)"
        echo "  -s, --session-name <name>   Skip destination picker (use this session)"
        echo "  -w, --window-name <name>    Skip window picker (always create new window)"
        echo "  -h, --help                  Show this help"
        return 0
    end
    
    # Step 1: Select path
    set -l worktree_path
    
    if set -q _flag_path
        set worktree_path $_flag_path
        
        if not test -d "$worktree_path"
            _hive_error "Directory not found: $worktree_path"
            return 1
        end
        set worktree_path (realpath "$worktree_path")
    else
        set worktree_path (_hive_pick_path)
        if test -z "$worktree_path"
            return 0  # User cancelled
        end
    end
    
    # Step 2: Select destination
    set -l destination
    
    if set -q _flag_session_name
        set destination $_flag_session_name
        
        if not _hive_is_hive_session "$destination"
            _hive_error "Session '$destination' is not a hive session"
            return 1
        end
    else
        set destination (_hive_pick_destination)
    end
    
    switch $destination
        case 'new-session'
            # Build flags for hive_session
            set -l session_args "$worktree_path"
            if set -q _flag_session_name
                set -a session_args --session-name "$_flag_session_name"
            end
            if set -q _flag_window_name
                set -a session_args --window-name "$_flag_window_name"
            end
            hive_session $session_args
            return $status
        case 'cancel'
            return 0
        case '*'
            # Selected existing session, go to step 3
            set -l session_name $destination
            
            # Skip window selection if --window-name is provided
            if set -q _flag_window_name
                # Always create new window
                hive_window "$worktree_path" "$session_name" --window-name "$_flag_window_name"
                set -l window_status $status

                # Switch to the session after adding window
                if test $window_status -eq 0
                    if test -n "$TMUX"
                        tmux switch-client -t "$session_name"
                    else
                        tmux attach-session -t "$session_name"
                    end
                end
                return $window_status
            end
            
            # Normal window selection flow
            set -l window_target (_hive_pick_window "$session_name")
            
            switch $window_target
                case 'new-window'
                    # Prompt for window name in spawn wizard, then pass to hive_window
                    set -l base_name (_hive_get_window_name "$worktree_path")
                    set -l window_name (_hive_prompt_window_name "$session_name" "$base_name")

                    hive_window "$worktree_path" "$session_name" --window-name "$window_name"
                    set -l window_status $status

                    # Switch to the session after adding window
                    if test $window_status -eq 0
                        if test -n "$TMUX"
                            tmux switch-client -t "$session_name"
                        else
                            tmux attach-session -t "$session_name"
                        end
                    end
                    return $window_status
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
