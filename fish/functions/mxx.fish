function mxx
    while true
        # Use fzf to select a directory, suppress wildcard error with fish_noglob
        set -l fish_noglob true

        set selected_dir (fd --type d --max-depth 1 | fzf --height 40% --border)

        # If fzf is cancelled or no selection is made, break the loop
        if not set -q selected_dir[1]
            echo "Exiting mxx."
            break
        end

        # Change to the selected directory
        if test -d "$selected_dir"
            cd "$selected_dir"
            echo "Changed directory to $(pwd)"
        else
            echo "'$selected_dir' is not a directory, staying in $(pwd)"
        end
    end
end
