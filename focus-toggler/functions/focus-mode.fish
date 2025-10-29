function focus-mode -d "Manage window focus mode (activities or windows)"
    set -l mode_file "$HOME/.config/window-focus-mode"
    set -l valid_modes activities windows

    # If no argument, show current mode
    if test (count $argv) -eq 0
        if test -f "$mode_file"
            set -l current_mode (cat "$mode_file" | string trim)
            if test -z "$current_mode"
                echo "activities (default)"
            else
                echo "$current_mode"
            end
        else
            echo "activities (default)"
        end
        return 0
    end

    # Set mode
    set -l requested_mode $argv[1]

    # Validate mode
    if not contains $requested_mode $valid_modes
        echo "Error: Invalid mode '$requested_mode'" >&2
        echo "Valid modes: activities, windows" >&2
        return 1
    end

    # Write mode to file
    echo $requested_mode > "$mode_file"
    echo "Focus mode set to: $requested_mode"

    # Move windows to appropriate screen based on mode
    set -l script_dir (dirname (status --current-filename))/../
    if test "$requested_mode" = "windows"
        # Windows mode: move to secondary screen (HDMI-0)
        echo "Moving windows to secondary screen..."
        bash "$script_dir/move_windows_to_screen.sh" HDMI-0
    else if test "$requested_mode" = "activities"
        # Activities mode: move to primary screen (DP-4)
        echo "Moving windows to primary screen..."
        bash "$script_dir/move_windows_to_screen.sh" DP-4
    end
end
