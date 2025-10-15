function dictation-browse -d "Browse recent dictations with fzf and paste selected content"
    set -l dictation_dir ~/SynologyDrive/Areas/Dev/dictation-data

    # Check if directory exists
    if not test -d $dictation_dir
        echo "Error: Dictation directory not found: $dictation_dir" >&2
        return 1
    end

    # Sort by filename (already chronological), then format for display
    # Include first 200 chars of content inline for searching
    set -l now (date +%s)
    set -l selected (find $dictation_dir -type f -name "*.txt" 2>/dev/null | sort -r | \
        awk -v now=$now '{
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

            # Get word count and first 200 chars of content
            cmd = "wc -w < \"" filepath "\" 2>/dev/null"
            cmd | getline word_count
            close(cmd)

            # Read first 200 chars, replace newlines with spaces
            cmd = "head -c 200 \"" filepath "\" 2>/dev/null | tr \"\\n\" \" \""
            cmd | getline content_preview
            close(cmd)

            # Format relative time
            if (age < 60)
                rel_time = age "s ago"
            else if (age < 3600)
                rel_time = int(age / 60) "m ago"
            else if (age < 86400)
                rel_time = int(age / 3600) "h ago"
            else if (age < 604800)
                rel_time = int(age / 86400) "d ago"
            else
                rel_time = int(age / 604800) "w ago"

            # Output: time | words | filename | content_preview \t filepath
            printf "%s | %d words | %s | %s\t%s\n", rel_time, word_count, filename, content_preview, filepath
            fflush()
        }' | \
        fzf --height=50% \
            --delimiter='\t' \
            --with-nth=1 \
            --prompt='Dictation > ' \
            --header='Select dictation to paste')

    # Extract the full path (after the tab) and paste content
    if test -n "$selected"
        set -l filepath (string split -f2 \t -- $selected)
        cat $filepath
    end
end
