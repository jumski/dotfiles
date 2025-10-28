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
end
