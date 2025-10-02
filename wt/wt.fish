#!/usr/bin/env fish
# Worktree Toolkit - Main facade/dispatcher

# Get the directory where this script is located
set -l wt_dir (dirname (status -f))

# Source all function modules
source $wt_dir/functions/wt-common.fish
source $wt_dir/functions/wt-init.fish
source $wt_dir/functions/wt-clone.fish
source $wt_dir/functions/wt-new.fish
source $wt_dir/functions/wt-branch.fish
source $wt_dir/functions/wt-remove.fish
source $wt_dir/functions/wt-switch.fish
source $wt_dir/functions/wt-nav.fish
source $wt_dir/functions/wt-sync.fish
source $wt_dir/functions/wt-env.fish
source $wt_dir/functions/wt-git.fish
source $wt_dir/functions/wt-dashboard.fish
source $wt_dir/functions/wt-help.fish
source $wt_dir/functions/wt-tutor.fish

# Main command dispatcher
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
        case up
            wt_up $remaining_args
        case down
            wt_down $remaining_args
        case bottom
            wt_bottom $remaining_args
        case sync-all
            wt_sync_all $remaining_args
        case env
            wt_env $remaining_args
        case git
            wt_git $remaining_args
        case tutor
            wt_tutor $remaining_args
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