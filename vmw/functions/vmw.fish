function vmw --description "VM Worktree Manager - run Claude Code safely in KVM VMs"
    set -l cmd $argv[1]
    set -l args $argv[2..-1]

    # Show help if no command or help requested
    if test -z "$cmd"; or test "$cmd" = "--help"; or test "$cmd" = "-h"; or test "$cmd" = "help"
        __vmw_help
        return 0
    end

    switch $cmd
        case spawn
            vmw_spawn $args
        case list ls
            vmw_list $args
        case stop
            vmw_stop $args
        case ssh
            vmw_ssh $args
        case destroy rm
            vmw_destroy $args
        case '*'
            echo "Unknown command: $cmd" >&2
            __vmw_help >&2
            return 1
    end
end

function __vmw_help
    echo "Usage: vmw <command> [args]"
    echo ""
    echo "Commands:"
    echo "  spawn <path>   Start VM for worktree at <path>"
    echo "  list           List running VMs"
    echo "  stop <name>    Stop VM gracefully"
    echo "  ssh <name>     SSH into VM (with agent forwarding)"
    echo "  destroy <name> Stop and remove VM"
    echo ""
    echo "Setup: Run vmw/install.sh (requires sudo)"
    echo ""
    echo "Examples:"
    echo "  vmw spawn /path/to/worktree"
    echo "  vmw ssh my-feature"
    echo "  vmw list"
end
