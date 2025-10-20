function dx-file-select -d "Generic file selector with fzf and customizable options"
    # Usage: dx-file-select [options]
    #
    # Options:
    #   --dirs DIR1 DIR2 ...      Directories to search (in priority order)
    #                             Can use env vars like \$notes
    #                             Use 'RECURSIVE:.' to search recursively from current dir
    #   --pattern PATTERN         File pattern (default: *.md)
    #   --exclude-dir DIR         Directories to exclude (can be repeated)
    #   --preview-cmd CMD         Preview command (use {} as placeholder for file)
    #   --preview-window LAYOUT   fzf preview window layout (default: right:60%:wrap)
    #   --prompt TEXT             fzf prompt text (default: 'Select file > ')
    #   --sort                    Sort files alphabetically (default: true)

    argparse \
        'dirs=+' \
        'pattern=' \
        'exclude-dir=+' \
        'preview-cmd=' \
        'preview-window=' \
        'prompt=' \
        'sort' \
        -- $argv
    or return 1

    # Default values
    set -l pattern $_flag_pattern
    test -z "$pattern"; and set pattern "*.md"

    set -l preview_cmd $_flag_preview_cmd
    test -z "$preview_cmd"; and set preview_cmd 'bat --style=numbers,changes --color=always --language=markdown {}'

    set -l preview_window $_flag_preview_window
    test -z "$preview_window"; and set preview_window "right:60%:wrap"

    set -l prompt $_flag_prompt
    test -z "$prompt"; and set prompt "Select file > "

    set -l do_sort true
    if set -q _flag_sort
        set do_sort $_flag_sort
    end

    # Build list of files
    set -l files_list

    # Try each directory in priority order
    if set -q _flag_dirs
        for dir_spec in $_flag_dirs
            set -l dir ""

            # Check if it's a RECURSIVE: spec
            if string match -q "RECURSIVE:*" -- $dir_spec
                set dir (string replace "RECURSIVE:" "" -- $dir_spec)

                # Build find command with exclusions
                set -l find_cmd find "$dir" -type f -name "$pattern"

                # Add exclusions
                if set -q _flag_exclude_dir
                    for exclude in $_flag_exclude_dir
                        set find_cmd $find_cmd -not -path "*/$exclude/*"
                    end
                end

                # Execute find and store results
                set files_list (eval $find_cmd 2>/dev/null)

                if test (count $files_list) -gt 0
                    break
                end
            else
                # Expand env variables or use as-is
                set dir (eval echo $dir_spec 2>/dev/null)

                if test -d "$dir"
                    set files_list (find "$dir" -type f -name "$pattern" 2>/dev/null)

                    if test (count $files_list) -gt 0
                        break
                    end
                end
            end
        end
    end

    # Check if we have any files
    if test (count $files_list) -eq 0
        echo "Error: No files matching '$pattern' found" >&2
        return 1
    end

    # Sort if requested
    if test "$do_sort" = true
        set files_list (printf '%s\n' $files_list | sort)
    end

    # Use fzf to select a file
    set -l selected (printf '%s\n' $files_list | \
        fzf --height=100% \
            --preview "$preview_cmd" \
            --preview-window="$preview_window" \
            --prompt="$prompt")

    # Output the selected file path
    if test -n "$selected"
        echo "$selected"
    else
        return 1
    end
end
