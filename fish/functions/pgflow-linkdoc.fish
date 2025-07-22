function pgflow-linkdoc --description "Select file/dir from pgflow using fzf and link to current directory"
    set -l pgflow_dir ~/SynologyDrive/Projects/pgflow
    
    # Check if pgflow directory exists
    if not test -d $pgflow_dir
        echo "Error: pgflow directory not found at $pgflow_dir"
        return 1
    end
    
    # Use rg to list files respecting gitignore and other sensible defaults
    set -l selected (rg --files --hidden --follow --no-messages --glob '!.git' --glob '!node_modules' $pgflow_dir 2>/dev/null | \
                     sed "s|^$pgflow_dir/||" | \
                     sort | \
                     awk -F'/' '{
                         if (NF > 1) {
                             for (i=1; i<NF; i++) {
                                 printf "\033[38;5;244m%s/\033[0m", $i
                             }
                             printf "\033[97m%s\033[0m\n", $NF
                         } else {
                             printf "\033[97m%s\033[0m\n", $0
                         }
                     }' | \
                     fzf --prompt="Select file/dir to link: " \
                         --ansi \
                         --preview "test -f '$pgflow_dir/{}' && bat --style=numbers --color=always --line-range :50 '$pgflow_dir/{}' || ls -la '$pgflow_dir/{}' 2>/dev/null" | \
                     sed 's/\x1b\[[0-9;]*m//g')
    
    if test -z "$selected"
        echo "No file selected"
        return 1
    end
    
    set -l source_path (realpath "$pgflow_dir/$selected")
    set -l dest_path (realpath ./)/(basename "$selected")
    
    # Check if destination already exists
    if test -e "$dest_path"
        echo "Warning: $dest_path already exists"
        read -P "Overwrite? [y/N] " -n 1 confirm
        if not string match -qi "y" "$confirm"
            echo "Cancelled"
            return 1
        end
        rm -rf "$dest_path"
    end
    
    echo "Linking: $source_path → $dest_path"
    ln -s "$source_path" "$dest_path"
    
    if test $status -eq 0
        echo "Successfully linked!"
        ls -la "$dest_path"
    else
        echo "Failed to create link"
        return 1
    end
end