function focus-mode -d "Manage window focus mode (activities or windows)"
    set -l mode_file "$HOME/.config/window-focus-mode"
    set -l valid_modes activities windows kitties
    set -l move_windows false

    # Parse arguments
    set -l mode_arg
    for arg in $argv
        if test "$arg" = "--move"
            set move_windows true
        else
            set mode_arg $arg
        end
    end

    # If no mode argument, show current mode
    if test -z "$mode_arg"
        if test -f "$mode_file"
            set -l current_mode (cat "$mode_file" | string trim)
            if test -z "$current_mode"
                echo "kitties (default)"
            else
                echo "$current_mode"
            end
        else
            echo "kitties (default)"
        end
        return 0
    end

    # Validate mode
    if not contains $mode_arg $valid_modes
        echo "Error: Invalid mode '$mode_arg'" >&2
        echo "Valid modes: activities, windows, kitties" >&2
        return 1
    end

    # Write mode to file
    echo $mode_arg > "$mode_file"
    echo "Focus mode set to: $mode_arg"

    # Move windows only if --move flag is provided
    if test "$move_windows" = true
        set -l script_dir (dirname (status --current-filename))/../
        if test "$mode_arg" = "windows"
            # Windows mode: move to secondary screen (HDMI-0) and maximize
            echo "Moving windows to secondary screen (maximized)..."
            bash "$script_dir/move_windows_to_screen.sh" HDMI-0 --maximize
        else if test "$mode_arg" = "activities"
            # Activities mode: move to primary screen (DP-4) and unmaximize for tiling
            echo "Moving windows to primary screen (unmaximized for tiling)..."
            bash "$script_dir/move_windows_to_screen.sh" DP-4 --unmaximize
        end
    end
end
