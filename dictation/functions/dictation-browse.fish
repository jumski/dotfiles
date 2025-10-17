function dictation-browse -d "Browse recent dictations with fzf and paste selected content"
    set -l dictation_dir ~/SynologyDrive/Areas/Dev/dictation-data

    # Check if directory exists
    if not test -d $dictation_dir
        echo "Error: Dictation directory not found: $dictation_dir" >&2
        return 1
    end

    # Get terminal width and calculate max content display width
    # Format: 10 (time) + 3 (sep) + 4 (words) + 3 (sep) = 20 chars for metadata
    # Reserve 5 chars for fzf UI, so content_width = term_width - 25
    set -l term_width (tput cols)
    set -l content_width (math "max(50, $term_width - 25)")

    # Sort by filename (already chronological), then format for display
    # Include full content for searching but truncate display version
    set -l now (date +%s)
    set -l selected (find $dictation_dir -type f -name "*.txt" 2>/dev/null | sort -r | \
        awk -v now=$now -v cwidth=$content_width '{
            filepath = $0

            # Get filename and extract timestamp: YYYYMMDD-HHMMSS-mmm.txt
            n = split(filepath, parts, "/")
            filename = parts[n]

            # Parse timestamp from filename (YYYYMMDD-HHMMSS)
            if (match(filename, /^([0-9]{8})-([0-9]{6})/, ts)) {
                datestr = ts[1]
                timestr = ts[2]

                # Convert to epoch using date command
                cmd = "date -d \"" substr(datestr,1,4) "-" substr(datestr,5,2) "-" substr(datestr,7,2) " " substr(timestr,1,2) ":" substr(timestr,3,2) ":" substr(timestr,5,2) "\" +%s 2>/dev/null"
                cmd | getline file_epoch
                close(cmd)

                age = now - file_epoch
            } else {
                age = 0
            }

            # Get word count
            cmd = "wc -w < \"" filepath "\" 2>/dev/null"
            cmd | getline word_count
            close(cmd)

            # Read full content for searching, replace newlines with spaces
            cmd = "cat \"" filepath "\" 2>/dev/null | tr \"\\n\" \" \""
            cmd | getline full_content
            close(cmd)

            # Format relative time with fixed width
            if (age < 60)
                rel_time = sprintf("%4ds ago", age)
            else if (age < 3600)
                rel_time = sprintf("%4dm ago", int(age / 60))
            else if (age < 86400)
                rel_time = sprintf("%4dh ago", int(age / 3600))
            else if (age < 604800)
                rel_time = sprintf("%4dd ago", int(age / 86400))
            else
                rel_time = sprintf("%4dw ago", int(age / 604800))

            # Truncate content for display based on terminal width
            content_display = substr(full_content, 1, cwidth)

            # Output: time | words | truncated_content | full_content \t filepath
            # Field 1-3 for display, field 4 for searching (invisible)
            printf "%-10s | %3dw | %s\t%s\t%s\n", rel_time, word_count, content_display, full_content, filepath
            fflush()
        }' | \
        fzf --height=100% \
            --delimiter='\t' \
            --with-nth=1,2 \
            --prompt='Dictation > ' \
            --header='Select dictation to paste')

    # Extract the full path (field 3 after tabs) and paste content
    if test -n "$selected"
        # Debug: write selection to stderr to see what we got
        echo "Selected: $selected" >&2
        set -l filepath (string split -f3 \t -- $selected)
        echo "Filepath: $filepath" >&2
        if test -f "$filepath"
            cat $filepath
        else
            echo "Error: File not found: $filepath" >&2
        end
    else
        echo "No selection" >&2
    end
end
