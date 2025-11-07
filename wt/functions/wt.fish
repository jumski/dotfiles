#!/usr/bin/env fish
# Worktree Toolkit - Main facade/dispatcher

function wt
    # Check dependencies on first run
    wt_check_dependencies
    or return 1

    set -l command $argv[1]
    set -l remaining_args $argv[2..-1]

    switch $command
        case init
            wt_init $remaining_args
        case clone
            wt_clone $remaining_args
        case new
            wt_new $remaining_args
        case branch br
            wt_branch $remaining_args
        case remove rm
            wt_remove $remaining_args
        case switch sw
            wt_switch $remaining_args
        case sync-all
            wt_sync_all $remaining_args
        case env
            wt_env $remaining_args
        case git
            wt_git $remaining_args
        case doctor
            wt_doctor $remaining_args
        case tutor
            wt_tutor $remaining_args
        case reload
            wt_reload $remaining_args
        case version --version -v
            echo "wt version $WT_VERSION"
        case help --help -h
            _wt_help
        case ''
            wt_dashboard
        case '*'
            echo "Unknown command: $command"
            _wt_help
            return 1
    end
end
