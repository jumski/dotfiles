function __mksupa_path
    set -l base_dir ~/Code/pgflow-dev/supatemp

    if not test -d "$base_dir"
        echo "Error: supatemp directory not found: $base_dir"
        return 1
    end

    # Use fzf to select project directory
    set -l selected_dir (find "$base_dir" -maxdepth 1 -type d -name "*-*" | \
        sort -r | \
        fzf --preview "echo -e '### .env\n'; cat {}/.env 2>/dev/null | head -20; echo -e '\n### Directory\n'; ls -la {} | head -10" \
            --preview-window=right:60% \
            --prompt="Select project: " \
            --height=80% \
            --border)

    if test -z "$selected_dir"
        echo "No selection made"
        return 0
    end

    echo "$selected_dir"
end
