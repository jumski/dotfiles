#!/usr/bin/env fish
# Hive - Main facade/dispatcher

function hive
    set -l command $argv[1]
    set -l remaining_args $argv[2..-1]

    switch $command
        case spawn sp
            hive_spawn $remaining_args
        case session ses
            hive_session $remaining_args
        case window win
            hive_window $remaining_args
        case split
            hive_split $remaining_args
        case list ls
            hive_list $remaining_args
        case version --version -v
            echo "hive version $HIVE_VERSION"
        case help --help -h ''
            _hive_help
        case '*'
            echo "Unknown command: $command"
            _hive_help
            return 1
    end
end

function _hive_help
    echo "Hive - Tmux workspace management for agentic coding"
    echo ""
    echo "Usage: hive <command> [args]"
    echo ""
    echo "Commands:"
    echo "  spawn, sp          Interactive wizard to open worktree in hive"
    echo "  session, ses       Create new hive session from worktree"
    echo "  window, win        Add window to current/specified hive session"
    echo "  split              Split current window with new worktree pane"
    echo "  list, ls           List hive sessions and their windows"
    echo ""
    echo "Options:"
    echo "  --help, -h         Show this help"
    echo "  --version, -v      Show version"
end
