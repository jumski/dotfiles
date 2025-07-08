# Global configuration - can be overridden by environment variables
set -g __PGFLOW_ROOT $PGFLOW_ROOT
set -g __PGFLOW_WORKTREES_DIR $PGFLOW_WORKTREES_DIR
set -g __PGFLOW_ENVS_DIR $PGFLOW_ENVS_DIR

# Set defaults if not already defined
test -z "$__PGFLOW_ROOT"; and set -g __PGFLOW_ROOT "/home/jumski/Code/pgflow-dev/pgflow"
test -z "$__PGFLOW_WORKTREES_DIR"; and set -g __PGFLOW_WORKTREES_DIR "/home/jumski/Code/pgflow-dev/worktrees"
test -z "$__PGFLOW_ENVS_DIR"; and set -g __PGFLOW_ENVS_DIR "/home/jumski/Code/pgflow-dev/envs"

function pgflow-worktree
    # Parse arguments
    set -l cmd $argv[1]
    set -l branch_name $argv[2]
    set -l force_flag false
    set -l no_tmux_flag false

    # Check for flags
    for arg in $argv[3..-1]
        switch $arg
            case --force
                set force_flag true
            case --no-tmux
                set no_tmux_flag true
        end
    end

    # Show help if no command provided
    if test -z "$cmd"
        _pgflow_worktree_help
        return 0
    end

    # Handle different commands
    switch $cmd
        case new create
            if test -z "$branch_name"
                echo "Error: Branch name required"
                echo "Usage: pgflow-worktree new <branch-name>"
                return 1
            end
            _pgflow_worktree_create $branch_name $force_flag $no_tmux_flag

        case list ls
            _pgflow_worktree_list

        case remove rm delete
            if test -z "$branch_name"
                echo "Error: Branch name required"
                echo "Usage: pgflow-worktree remove <branch-name>"
                return 1
            end
            _pgflow_worktree_remove $branch_name $force_flag

        case switch sw
            if test -z "$branch_name"
                echo "Error: Worktree name required"
                echo "Usage: pgflow-worktree switch <worktree-name>"
                return 1
            end
            _pgflow_worktree_switch $branch_name

        case help --help -h
            _pgflow_worktree_help

        case '*'
            echo "Error: Unknown command '$cmd'"
            _pgflow_worktree_help
            return 1
    end
end

function _pgflow_worktree_help
    echo "pgflow-worktree - Manage pgflow git worktrees"
    echo ""
    echo "Usage:"
    echo "  pgflow-worktree new <branch-name> [--force] [--no-tmux]  Create new worktree"
    echo "  pgflow-worktree list                                      List all worktrees"
    echo "  pgflow-worktree remove <branch-name> [--force]           Remove worktree"
    echo "  pgflow-worktree switch <worktree-name>                   Switch to worktree in tmux"
    echo "  pgflow-worktree help                                      Show this help"
    echo ""
    echo "Options:"
    echo "  --force     Override safety checks"
    echo "  --no-tmux   Skip tmux session creation (for 'new' command)"
end

function _pgflow_worktree_create
    set -l branch_name $argv[1]
    set -l force_flag $argv[2]
    set -l no_tmux_flag $argv[3]
    set -l worktree_path "$__PGFLOW_WORKTREES_DIR/$branch_name"

    # Verify directories exist
    for dir in $__PGFLOW_ROOT $__PGFLOW_WORKTREES_DIR $__PGFLOW_ENVS_DIR
        if not test -d "$dir"
            echo "Error: Directory '$dir' does not exist"
            echo "Check your PGFLOW_* environment variables"
            return 1
        end
    end

    # Check if required tools are available
    for tool in git direnv pnpm
        if not command -v $tool >/dev/null
            echo "Error: Required tool '$tool' not found"
            return 1
        end
    end

    if test "$no_tmux_flag" = "false"; and not functions -q muxit
        echo "Error: 'muxit' function not found (required for tmux session)"
        return 1
    end

    # Prune stale worktrees
    git -C "$__PGFLOW_ROOT" worktree prune

    # Check if branch exists locally or remotely
    set -l branch_exists false
    set -l remote_branch ""
    
    # Check for local branch
    if git -C "$__PGFLOW_ROOT" show-ref --verify --quiet "refs/heads/$branch_name"
        set branch_exists true
    else
        # Check for remote branch
        for remote in (git -C "$__PGFLOW_ROOT" remote)
            if git -C "$__PGFLOW_ROOT" show-ref --verify --quiet "refs/remotes/$remote/$branch_name"
                set remote_branch "$remote/$branch_name"
                break
            end
        end
    end

    # Check if worktree already exists
    if test "$force_flag" = "false"
        if git -C "$__PGFLOW_ROOT" worktree list | grep -q -- "$worktree_path"
            echo "Error: Worktree at '$worktree_path' already exists"
            echo "Use --force to override"
            return 1
        end
    end

    # Check if worktree directory already exists
    if test -d "$worktree_path"
        echo "Error: Directory '$worktree_path' already exists"
        echo "Cannot create worktree in existing directory"
        return 1
    end

    # Create worktree - use existing branch, track remote, or create new one
    if test "$branch_exists" = "true"
        echo "Using existing local branch '$branch_name' for worktree at '$worktree_path'..."
        if not git -C "$__PGFLOW_ROOT" worktree add "$worktree_path" "$branch_name"
            echo "Error: Failed to create worktree with existing branch"
            return 1
        end
    else if test -n "$remote_branch"
        echo "Creating local branch '$branch_name' tracking '$remote_branch' with worktree at '$worktree_path'..."
        if not git -C "$__PGFLOW_ROOT" worktree add -b "$branch_name" "$worktree_path" "$remote_branch"
            echo "Error: Failed to create worktree tracking remote branch"
            return 1
        end
    else
        echo "Creating new branch '$branch_name' with worktree at '$worktree_path'..."
        set -l add_flag "-b"
        if test "$force_flag" = "true"
            set add_flag "-B"
        end
        
        if not git -C "$__PGFLOW_ROOT" worktree add $add_flag "$branch_name" "$worktree_path"
            echo "Error: Failed to create worktree and branch"
            return 1
        end
    end

    # Setup environment in worktree (use subshell to avoid changing user's directory)
    echo "Setting up direnv..."
    fish -c "cd '$worktree_path' && direnv allow"; or echo "  ⚠ Warning: direnv allow failed"

    # Run pnpm install
    echo "Installing dependencies with pnpm..."
    if not fish -c "cd '$worktree_path' && pnpm install"
        echo "Error: pnpm install failed - rolling back"
        git -C "$__PGFLOW_ROOT" worktree remove --force "$worktree_path"
        git -C "$__PGFLOW_ROOT" branch -D "$branch_name" 2>/dev/null
        return 1
    end

    # Copy environment files
    echo "Copying environment files..."
    
    # Copy all env files preserving directory structure
    if test -d "$__PGFLOW_ENVS_DIR"
        # Find all files in envs dir and copy them preserving structure
        set -l copied_count 0
        set -l skipped_count 0
        
        # Find files without changing directory
        find "$__PGFLOW_ENVS_DIR" -type f | while read -l source_file
            # Get relative path by removing the envs directory prefix
            set -l rel_path (string replace "$__PGFLOW_ENVS_DIR/" "" "$source_file")
            set -l target_file "$worktree_path/$rel_path"
            set -l target_dir (dirname "$target_file")
            
            # Create target directory if needed
            mkdir -p "$target_dir"
            
            # Copy file if it doesn't exist
            if not test -f "$target_file"
                cp "$source_file" "$target_file"
                echo "  ✓ Copied $rel_path"
                set copied_count (math $copied_count + 1)
            else
                set skipped_count (math $skipped_count + 1)
            end
        end
        
        if test $skipped_count -gt 0
            echo "  ⚠ Skipped $skipped_count existing files"
        end
    else
        echo "  ⚠ Warning: $__PGFLOW_ENVS_DIR directory not found"
    end

    echo ""
    echo "✅ Worktree '$branch_name' created successfully!"

    # Launch tmux session unless --no-tmux was specified
    if test "$no_tmux_flag" = "false"
        echo "Launching tmux session..."
        muxit "$worktree_path"
    else
        echo ""
        echo "Worktree ready at: $worktree_path"
        echo "To start tmux session later, run: muxit $worktree_path"
    end
end

function _pgflow_worktree_list
    echo "pgflow worktrees:"
    echo ""
    
    # Collect all worktrees info first
    set -l all_info
    set -l max_name_length 0
    
    git -C "$__PGFLOW_ROOT" worktree list | while read -l line
        set -l parts (string split " " $line)
        set -l path $parts[1]
        set -l name (basename $path)
        set -l branch (string replace -r '^\[(.+)\]$' '$1' $parts[3])
        
        # Track longest name
        set -l len (string length $name)
        if test $len -gt $max_name_length
            set max_name_length $len
        end
        
        # Store info for second pass
        set all_info $all_info "$name|$path|$branch"
    end
    
    # Get parent directory to mute common path prefix
    set -l parent_dir (dirname $__PGFLOW_ROOT)
    
    # Display with proper alignment
    for info in $all_info
        set -l parts (string split "|" $info)
        set -l name $parts[1]
        set -l path $parts[2]
        set -l branch $parts[3]
        
        # Pad name to max length
        set -l padded_name (printf "%-*s" $max_name_length $name)
        
        # For main repo
        if test "$path" = "$__PGFLOW_ROOT"
            # Print branch name in yellow
            set_color yellow
            echo -n "$padded_name"
            set_color normal
            echo -n "  "
            
            # Print muted path prefix
            set_color --dim
            echo -n "$parent_dir/"
            set_color normal
            
            # Print repo name and (main) marker in yellow
            set_color yellow
            echo "pgflow (main)"
            set_color normal
        else
            # For worktrees - print branch name in normal color
            echo -n "$padded_name  "
            
            # Print muted path up to and including 'worktrees/'
            set_color --dim
            echo -n "$__PGFLOW_WORKTREES_DIR/"
            set_color normal
            
            # Print branch name again (as directory name) in normal color
            echo $name
        end
    end
end

function _pgflow_worktree_remove
    set -l branch_name $argv[1]
    set -l force_flag $argv[2]
    set -l worktree_path "$__PGFLOW_WORKTREES_DIR/$branch_name"

    # Check if worktree exists
    if not git -C "$__PGFLOW_ROOT" worktree list | grep -q "$worktree_path"
        echo "Error: Worktree '$branch_name' not found"
        return 1
    end

    # Confirm removal unless --force
    if test "$force_flag" = "false"
        echo "This will remove worktree at: $worktree_path"
        echo -n "Are you sure? [y/N] "
        read -l confirm
        if not string match -qi "y" $confirm
            echo "Cancelled"
            return 0
        end
    end

    # Remove worktree
    echo "Removing worktree '$branch_name'..."
    if not git -C "$__PGFLOW_ROOT" worktree remove "$worktree_path"
        if test "$force_flag" = "true"
            echo "Force removing worktree..."
            git -C "$__PGFLOW_ROOT" worktree remove --force "$worktree_path"
        else
            echo "Error: Failed to remove worktree"
            echo "Use --force to force removal"
            return 1
        end
    end

    # Ask about branch removal
    echo ""
    echo -n "Also delete branch '$branch_name'? [y/N] "
    read -l confirm
    if string match -qi "y" $confirm
        if git -C "$__PGFLOW_ROOT" branch -d "$branch_name" 2>/dev/null
            echo "✓ Branch deleted"
        else
            echo "Branch has unmerged changes. Force delete? [y/N] "
            read -l force_confirm
            if string match -qi "y" $force_confirm
                git -C "$__PGFLOW_ROOT" branch -D "$branch_name"
                echo "✓ Branch force deleted"
            end
        end
    end

    echo ""
    echo "✅ Worktree '$branch_name' removed successfully!"
end

function _pgflow_worktree_switch
    set -l worktree_name $argv[1]
    set -l worktree_path "$__PGFLOW_WORKTREES_DIR/$worktree_name"

    # Check if it's the main worktree
    if test "$worktree_name" = "main" -o "$worktree_name" = "pgflow"
        set worktree_path $__PGFLOW_ROOT
    end

    # Check if worktree exists
    if not test -d "$worktree_path"
        echo "Error: Worktree directory '$worktree_path' not found"
        return 1
    end

    # Check if it's a valid git worktree
    if not git -C "$__PGFLOW_ROOT" worktree list | grep -q "$worktree_path"
        echo "Error: '$worktree_path' is not a valid pgflow worktree"
        return 1
    end

    # Launch or switch to tmux session
    echo "Switching to worktree '$worktree_name'..."
    muxit "$worktree_path"
end

# Helper function to get available worktrees for completion
function __fish_pgflow_worktree_list
    # Get worktree names excluding the main repo
    git -C "$__PGFLOW_ROOT" worktree list 2>/dev/null | while read -l line
        set -l path (string split " " $line)[1]
        if test "$path" != "$__PGFLOW_ROOT"
            basename $path
        end
    end
end

# Add completion
complete -c pgflow-worktree -f
complete -c pgflow-worktree -n "not __fish_seen_subcommand_from new create list ls remove rm delete switch sw help" -a "new" -d "Create new worktree"
complete -c pgflow-worktree -n "not __fish_seen_subcommand_from new create list ls remove rm delete switch sw help" -a "create" -d "Create new worktree"
complete -c pgflow-worktree -n "not __fish_seen_subcommand_from new create list ls remove rm delete switch sw help" -a "list" -d "List all worktrees"
complete -c pgflow-worktree -n "not __fish_seen_subcommand_from new create list ls remove rm delete switch sw help" -a "ls" -d "List all worktrees"
complete -c pgflow-worktree -n "not __fish_seen_subcommand_from new create list ls remove rm delete switch sw help" -a "remove" -d "Remove worktree"
complete -c pgflow-worktree -n "not __fish_seen_subcommand_from new create list ls remove rm delete switch sw help" -a "rm" -d "Remove worktree"
complete -c pgflow-worktree -n "not __fish_seen_subcommand_from new create list ls remove rm delete switch sw help" -a "delete" -d "Remove worktree"
complete -c pgflow-worktree -n "not __fish_seen_subcommand_from new create list ls remove rm delete switch sw help" -a "switch" -d "Switch to worktree"
complete -c pgflow-worktree -n "not __fish_seen_subcommand_from new create list ls remove rm delete switch sw help" -a "sw" -d "Switch to worktree"
complete -c pgflow-worktree -n "not __fish_seen_subcommand_from new create list ls remove rm delete switch sw help" -a "help" -d "Show help"

# Complete worktree names for remove and switch commands
complete -c pgflow-worktree -n "__fish_seen_subcommand_from remove rm delete" -a "(__fish_pgflow_worktree_list)" -d "Worktree to remove"
complete -c pgflow-worktree -n "__fish_seen_subcommand_from switch sw" -a "(__fish_pgflow_worktree_list)" -d "Worktree to switch to"
complete -c pgflow-worktree -n "__fish_seen_subcommand_from switch sw" -a "main" -d "Main pgflow repository"

# Complete flags
complete -c pgflow-worktree -n "__fish_seen_subcommand_from new create remove rm delete" -l force -d "Override safety checks"
complete -c pgflow-worktree -n "__fish_seen_subcommand_from new create" -l no-tmux -d "Skip tmux session"