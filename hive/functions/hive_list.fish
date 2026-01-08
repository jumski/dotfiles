#!/usr/bin/env fish
# List hive sessions and their windows

function hive_list
    # Show help if requested
    if test "$argv[1]" = "--help" -o "$argv[1]" = "-h"
        echo "Usage: hive list"
        echo ""
        echo "Lists all hive sessions and their windows."
        return 0
    end
    
    set -l sessions (_hive_list_sessions)
    
    if test -z "$sessions"
        echo "No hive sessions found."
        return 0
    end
    
    for session in $sessions
        set_color green
        echo -n "# "
        set_color normal
        set_color --bold
        echo "$session"
        set_color normal
        
        set -l windows (_hive_list_windows "$session")
        for window in $windows
            set -l idx (echo $window | cut -d: -f1)
            set -l name (echo $window | cut -d: -f2-)
            set_color brblack
            echo -n "  $idx: "
            set_color normal
            echo "$name"
        end
        echo ""
    end
end
