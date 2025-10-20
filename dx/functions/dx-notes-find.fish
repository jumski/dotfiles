function dx-notes-find -d "Find and select notes using fzf with bat preview"
    # Determine source directory with priority order
    set -l source_dir ""
    set -l files_list ""

    if test -n "$notes"
        # Priority 1: $notes env variable
        if test -d "$notes"
            set source_dir "$notes"
            set files_list (find "$source_dir" -type f -name "*.md" 2>/dev/null | sort)
        else
            echo "Error: \$notes is set but directory not found: $notes" >&2
            return 1
        end
    else if test -d "./branch-docs"
        # Priority 2: ./branch-docs directory
        set source_dir "./branch-docs"
        set files_list (find "$source_dir" -type f -name "*.md" 2>/dev/null | sort)
    else
        # Priority 3: All markdown files in current directory (excluding node_modules and .git)
        set files_list (find . -type f -name "*.md" \
            -not -path "*/node_modules/*" \
            -not -path "*/.git/*" \
            2>/dev/null | sort)
    end

    # Check if we have any files
    if test (count $files_list) -eq 0
        echo "Error: No markdown files found" >&2
        return 1
    end

    # Use fzf to select a file with bat preview
    set -l selected (printf '%s\n' $files_list | \
        fzf --height=100% \
            --preview 'bat --style=numbers,changes --color=always --language=markdown {}' \
            --preview-window=right:60%:wrap \
            --prompt='Select note > ')

    # Output the selected file path
    if test -n "$selected"
        echo "$selected"
    else
        return 1
    end
end
