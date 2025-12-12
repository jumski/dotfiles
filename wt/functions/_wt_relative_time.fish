function _wt_relative_time --description "Convert ISO timestamp to relative time string"
    set -l timestamp $argv[1]

    if test -z "$timestamp"
        echo "unknown"
        return
    end

    # Parse ISO timestamp to epoch seconds
    set -l epoch (date -d "$timestamp" +%s 2>/dev/null)
    if test -z "$epoch"
        echo "unknown"
        return
    end

    set -l now (date +%s)
    set -l diff (math $now - $epoch)

    # Handle future timestamps
    if test $diff -lt 0
        echo "just now"
        return
    end

    # Calculate relative time
    set -l minutes (math "floor($diff / 60)")
    set -l hours (math "floor($diff / 3600)")
    set -l days (math "floor($diff / 86400)")
    set -l weeks (math "floor($diff / 604800)")

    if test $minutes -lt 1
        echo "just now"
    else if test $minutes -eq 1
        echo "1 minute ago"
    else if test $hours -lt 1
        echo "$minutes minutes ago"
    else if test $hours -eq 1
        echo "1 hour ago"
    else if test $days -lt 1
        echo "$hours hours ago"
    else if test $days -eq 1
        echo "1 day ago"
    else if test $weeks -lt 1
        echo "$days days ago"
    else if test $weeks -eq 1
        echo "1 week ago"
    else
        echo "$weeks weeks ago"
    end
end
