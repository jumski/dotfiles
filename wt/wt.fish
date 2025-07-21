#!/usr/bin/env fish
# Worktree Toolkit - Git worktree management with Graphite integration

# Verify dependencies
if not command -q jq
    echo "Error: jq is required but not installed. Please install jq." >&2
    exit 1
end

if not command -q gt
    echo "Error: Graphite CLI (gt) is required but not installed." >&2
    echo "Install with: npm install -g @withgraphite/graphite-cli@stable" >&2
    exit 1
end

if not command -q git
    echo "Error: git is required but not installed." >&2
    exit 1
end

# Environment Variables
set -g WT_VERSION "0.1.0"
set -g DEFAULT_CODE_DIR "$HOME/Code"
set -g TMUX_SESSION_PREFIX "wt"
set -g USE_MUXIT "true"
set -g AUTO_PRUNE_DAYS 30
set -g WARN_STALE_WORKTREES "true"

# Guard clause helper
function _wt_assert
    set -l condition $argv[1]
    set -l error_msg $argv[2..-1]
    
    if not eval $condition
        echo "Error: $error_msg" >&2
        return 1
    end
end


# Get repository config
function _wt_get_repo_config
    set -l config_file ".wt-config"
    
    if not test -f $config_file
        return 1
    end
    
    # Parse config file
    while read -l line
        if string match -qr '^[A-Z_]+=.*' $line
            set -l key (string split -m1 '=' $line)[1]
            set -l value (string split -m1 '=' $line)[2]
            set -g $key $value
        end
    end < $config_file
end

# Check if in worktree repository
function _wt_in_worktree_repo
    if test -f .wt-config
        return 0
    end
    
    # Check parent directories
    set -l current_dir (pwd)
    while test "$current_dir" != "/"
        if test -f "$current_dir/.wt-config"
            return 0
        end
        set current_dir (dirname $current_dir)
    end
    
    return 1
end

# Get repository root
function _wt_get_repo_root
    set -l current_dir (pwd)
    while test "$current_dir" != "/"
        if test -f "$current_dir/.wt-config"
            echo $current_dir
            return 0
        end
        set current_dir (dirname $current_dir)
    end
    
    return 1
end

# Initialize new repository with worktree structure
function wt_init
    set -l repo_url $argv[1]
    set -l repo_name $argv[2]
    
    _wt_assert "test -n '$repo_url'" "Repository URL required"
    or return 1
    
    # Extract repo name if not provided
    if test -z "$repo_name"
        set repo_name (basename $repo_url .git)
    end
    
    set -l repo_path "$DEFAULT_CODE_DIR/$repo_name"
    
    if test -d $repo_path
        echo "Error: Directory $repo_path already exists" >&2
        return 1
    end
    
    echo "Initializing worktree repository: $repo_name"
    
    # Create directory structure
    mkdir -p $repo_path
    cd $repo_path
    
    # Clone as bare repository
    echo "Cloning repository as bare..."
    git clone --bare $repo_url .bare
    or begin
        echo "Error: Failed to clone repository" >&2
        cd -
        rm -rf $repo_path
        return 1
    end
    
    # Create worktrees directory
    mkdir -p worktrees
    
    # Get default branch
    set -l default_branch (git -C .bare symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$default_branch"
        set default_branch "main"
    end
    
    # Create main worktree
    echo "Creating main worktree..."
    git -C .bare worktree add ../worktrees/$default_branch $default_branch
    or begin
        echo "Error: Failed to create main worktree" >&2
        return 1
    end
    
    # Create envs directory
    mkdir -p envs
    
    # Create config file
    echo "REPO_NAME=$repo_name" > .wt-config
    echo "BARE_PATH=.bare" >> .wt-config
    echo "WORKTREES_PATH=worktrees" >> .wt-config
    echo "ENVS_PATH=envs" >> .wt-config
    echo "DEFAULT_TRUNK=$default_branch" >> .wt-config
    
    # Initialize Graphite in main worktree
    cd worktrees/$default_branch
    gt init --trunk $default_branch
    
    echo "✓ Repository initialized at $repo_path"
    echo "✓ Main worktree at worktrees/$default_branch"
    echo ""
    echo "Next steps:"
    echo "  cd $repo_path/worktrees/$default_branch"
    echo "  wt new <feature-name>"
end

# Create new worktree
function wt_new
    set -l name $argv[1]
    set -l base_branch ""
    set -l trunk_branch ""
    set -l force_new false
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    _wt_assert "test -n '$name'" "Worktree name required"
    or return 1
    
    # Parse options
    set -l i 2
    while test $i -le (count $argv)
        switch $argv[$i]
            case --from
                set i (math $i + 1)
                set base_branch $argv[$i]
            case --trunk
                set i (math $i + 1)
                set trunk_branch $argv[$i]
            case --force-new
                set force_new true
        end
        set i (math $i + 1)
    end
    
    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config
    
    # Default to main trunk if not specified
    if test -z "$base_branch"
        set base_branch $DEFAULT_TRUNK
    end
    
    set -l worktree_path "$WORKTREES_PATH/$name"
    
    if test -d $worktree_path
        echo "Error: Worktree '$name' already exists" >&2
        return 1
    end
    
    # Check for remote branch
    if test "$force_new" = "false"
        git -C $BARE_PATH fetch origin --quiet
        if git -C $BARE_PATH show-ref --verify --quiet refs/remotes/origin/$name
            echo "Remote branch 'origin/$name' found."
            read -P "Create worktree tracking it? [Y/n] " -n 1 confirm
            if test -z "$confirm" -o "$confirm" = "y" -o "$confirm" = "Y"
                set base_branch origin/$name
            else
                echo "Creating new local branch instead..."
            end
        end
    end
    
    echo "Creating worktree: $name"
    
    # Create the worktree
    git -C $BARE_PATH worktree add ../$worktree_path -b $name $base_branch
    or begin
        echo "Error: Failed to create worktree" >&2
        return 1
    end
    
    # Initialize Graphite
    cd $worktree_path
    if test -n "$trunk_branch"
        gt init --trunk $trunk_branch
    else
        gt init --trunk $DEFAULT_TRUNK
    end
    
    # Copy environment files if they exist
    if test -d "$repo_root/$ENVS_PATH"
        echo "Copying environment files..."
        cp -r "$repo_root/$ENVS_PATH/." .
    end
    
    echo "✓ Worktree created at $worktree_path"
    echo "✓ Branch '$name' created from '$base_branch'"
    
    # Open in tmux/muxit if available
    if test "$USE_MUXIT" = "true"; and command -q muxit
        echo "Opening in muxit..."
        muxit
    end
end

# List all worktrees
function wt_list
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config
    
    echo "Worktrees in $REPO_NAME:"
    echo ""
    
    # Get worktree list from git
    set -l worktrees (git -C $BARE_PATH worktree list --porcelain | string match -r '^worktree (.*)' | string replace 'worktree ' '')
    
    for worktree in $worktrees
        set -l branch_name (basename $worktree)
        set -l branch_info (git -C $worktree branch --show-current 2>/dev/null)
        
        if test -z "$branch_info"
            set branch_info "detached"
        end
        
        # Check if current directory
        if test (realpath $worktree) = (realpath (pwd))
            echo "● $branch_name (current)"
        else
            echo "  $branch_name"
        end
    end
end

# Remove worktree
function wt_remove
    set -l name $argv[1]
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    _wt_assert "test -n '$name'" "Worktree name required"
    or return 1
    
    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config
    
    set -l worktree_path "$WORKTREES_PATH/$name"
    
    if not test -d $worktree_path
        echo "Error: Worktree '$name' not found" >&2
        return 1
    end
    
    # Confirm deletion
    echo "This will remove worktree: $name"
    echo "Path: $worktree_path"
    read -P "Continue? [y/N] " -n 1 confirm
    
    if test "$confirm" != "y"
        echo "Cancelled"
        return 0
    end
    
    # Remove worktree
    git -C $BARE_PATH worktree remove $worktree_path --force
    or begin
        echo "Error: Failed to remove worktree" >&2
        return 1
    end
    
    # Remove branch if not checked out elsewhere
    git -C $BARE_PATH branch -d $name 2>/dev/null
    
    echo "✓ Worktree '$name' removed"
end

# Show status
function wt_status
    set -l show_all false
    
    if test "$argv[1]" = "--all"
        set show_all true
    end
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    set -l repo_root (_wt_get_repo_root)
    set -l current_worktree (basename (pwd))
    
    if test $show_all = true
        cd $repo_root
        _wt_get_repo_config
        
        echo "All worktrees status:"
        echo ""
        
        for worktree_dir in $WORKTREES_PATH/*
            if test -d $worktree_dir
                set -l name (basename $worktree_dir)
                set -l status (_wt_get_worktree_status $worktree_dir)
                printf "%-20s %s\n" "$name:" "$status"
            end
        end
    else
        # Show current worktree status
        echo "Worktree: $current_worktree"
        
        set -l branch (git branch --show-current)
        echo "Branch: $branch"
        
        # Get stack info
        set -l stack_info (gt stack 2>/dev/null | string match -r "Current branch '.*' is on stack '(.*)'" | string replace -r ".*'(.*)'" '$1')
        if test -n "$stack_info"
            echo "Stack: $stack_info"
        end
        
        # Check sync status
        set -l status (_wt_get_worktree_status (pwd))
        echo "Status: $status"
        
        # Show modified files
        set -l modified_count (git status --porcelain | count)
        if test $modified_count -gt 0
            echo "Modified files: $modified_count"
        end
    end
end

# Get worktree sync status
function _wt_get_worktree_status
    set -l worktree_path $argv[1]
    
    cd $worktree_path
    
    # Check if branch exists on remote
    set -l branch (git branch --show-current)
    set -l remote_exists (git ls-remote --heads origin $branch 2>/dev/null | count)
    
    if test $remote_exists -eq 0
        echo "✓ local only"
        return
    end
    
    # Fetch latest
    git fetch origin $branch --quiet 2>/dev/null
    
    # Check if behind/ahead
    set -l behind (git rev-list --count HEAD..origin/$branch 2>/dev/null)
    set -l ahead (git rev-list --count origin/$branch..HEAD 2>/dev/null)
    
    if test -z "$behind"
        set behind 0
    end
    if test -z "$ahead"
        set ahead 0
    end
    
    if test $behind -gt 0 -a $ahead -gt 0
        echo "⚠ diverged (↓$behind ↑$ahead)"
    else if test $behind -gt 0
        echo "⚠ behind by $behind commits"
    else if test $ahead -gt 0
        echo "↑ ahead by $ahead commits"
    else
        # Check if needs rebase from parent
        set -l parent (gt log --parent 2>/dev/null | head -1)
        if test -n "$parent"
            set -l needs_rebase (git rev-list --count $branch..$parent 2>/dev/null)
            if test -n "$needs_rebase" -a $needs_rebase -gt 0
                echo "⚠ needs rebase from $parent"
            else
                echo "✓ up-to-date"
            end
        else
            echo "✓ up-to-date"
        end
    end
end

# Switch to worktree using muxit
function wt_switch
    set -l name $argv[1]
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    _wt_assert "test -n '$name'" "Worktree name required"
    or return 1
    
    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config
    
    set -l worktree_path "$WORKTREES_PATH/$name"
    
    if not test -d $worktree_path
        echo "Error: Worktree '$name' not found" >&2
        return 1
    end
    
    cd $worktree_path
    
    if command -q muxit
        muxit
    else
        echo "Switched to: $worktree_path"
    end
end

# Navigate up in stack
function wt_up
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    # Get upstack branch
    set -l upstack (gt log --upstack 2>/dev/null | head -2 | tail -1)
    
    if test -z "$upstack"
        echo "No upstack branch found"
        return 1
    end
    
    # Find worktree for this branch
    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config
    
    for worktree_dir in $WORKTREES_PATH/*
        if test -d $worktree_dir
            set -l branch (git -C $worktree_dir branch --show-current 2>/dev/null)
            if test "$branch" = "$upstack"
                echo "Switching to upstack: $upstack"
                wt_switch (basename $worktree_dir)
                return 0
            end
        end
    end
    
    echo "Warning: No worktree found for upstack branch '$upstack'"
    echo "Create with: wt new $upstack --from (git branch --show-current)"
end

# Navigate down in stack
function wt_down
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    # Get parent branch
    set -l parent (gt log --parent 2>/dev/null | head -1)
    
    if test -z "$parent"
        echo "No parent branch found"
        return 1
    end
    
    # Find worktree for this branch
    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config
    
    for worktree_dir in $WORKTREES_PATH/*
        if test -d $worktree_dir
            set -l branch (git -C $worktree_dir branch --show-current 2>/dev/null)
            if test "$branch" = "$parent"
                echo "Switching to parent: $parent"
                wt_switch (basename $worktree_dir)
                return 0
            end
        end
    end
    
    echo "Warning: No worktree found for parent branch '$parent'"
end

# Navigate to stack bottom
function wt_bottom
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    # Get stack bottom
    set -l bottom (gt stack bottom 2>/dev/null | string match -r "Bottom of stack: (.*)" | string replace -r "Bottom of stack: " "")
    
    if test -z "$bottom"
        echo "Could not determine stack bottom"
        return 1
    end
    
    # Find worktree for this branch
    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config
    
    for worktree_dir in $WORKTREES_PATH/*
        if test -d $worktree_dir
            set -l branch (git -C $worktree_dir branch --show-current 2>/dev/null)
            if test "$branch" = "$bottom"
                echo "Switching to stack bottom: $bottom"
                wt_switch (basename $worktree_dir)
                return 0
            end
        end
    end
    
    echo "Warning: No worktree found for stack bottom '$bottom'"
end

# Sync current worktree
function wt_sync
    set -l sync_all false
    set -l force false
    set -l reset false
    
    # Parse options
    for arg in $argv
        switch $arg
            case --all
                set sync_all true
            case --force
                set force true
            case --reset
                set reset true
        end
    end
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    if test $sync_all = true
        set -l repo_root (_wt_get_repo_root)
        cd $repo_root
        _wt_get_repo_config
        
        echo "Syncing all worktrees..."
        
        for worktree_dir in $WORKTREES_PATH/*
            if test -d $worktree_dir
                set -l name (basename $worktree_dir)
                echo ""
                echo "Syncing $name..."
                cd $worktree_dir
                _wt_sync_single $force $reset
            end
        end
    else
        _wt_sync_single $force $reset
    end
end

# Sync single worktree
function _wt_sync_single
    set -l force $argv[1]
    set -l reset $argv[2]
    
    set -l branch (git branch --show-current)
    
    if test $reset = true
        echo "Resetting to origin/$branch..."
        git fetch origin $branch
        git reset --hard origin/$branch
        return
    end
    
    # Check for uncommitted changes
    if test (git status --porcelain | count) -gt 0
        if test $force = true
            echo "Stashing changes..."
            git stash push -m "wt sync auto-stash"
        else
            echo "Error: Uncommitted changes. Use --force to stash" >&2
            return 1
        end
    end
    
    # Sync with remote
    gt sync
    
    # Restore stash if needed
    if test $force = true -a (git stash list | head -1 | string match -q "*wt sync auto-stash*")
        echo "Restoring stashed changes..."
        git stash pop
    end
end

# Restack current stack
function wt_restack
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    echo "Restacking current branch and upstack..."
    gt restack
end

# Stack operations
function wt_stack
    set -l subcommand $argv[1]
    set -l remaining_args $argv[2..-1]
    
    switch $subcommand
        case list
            _wt_stack_list
        case sync
            _wt_stack_sync $remaining_args
        case '*'
            echo "Usage: wt stack [list|sync]"
            return 1
    end
end

# List all stacks
function _wt_stack_list
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config
    
    # Get all branches with their stacks
    set -l stacks
    
    for worktree_dir in $WORKTREES_PATH/*
        if test -d $worktree_dir
            cd $worktree_dir
            set -l branch (git branch --show-current)
            set -l stack_info (gt stack 2>/dev/null | string match -r "on stack '(.*)'" | string replace -r ".*'(.*)'" '$1')
            
            if test -n "$stack_info"
                # Add to stacks if not already present
                if not contains $stack_info $stacks
                    set -a stacks $stack_info
                end
            end
        end
    end
    
    if test (count $stacks) -eq 0
        echo "No stacks found"
        return
    end
    
    # Display each stack
    for stack in $stacks
        echo "Stack: $stack"
        
        # Get all branches in this stack
        for worktree_dir in $WORKTREES_PATH/*
            if test -d $worktree_dir
                cd $worktree_dir
                set -l branch (git branch --show-current)
                set -l this_stack (gt stack 2>/dev/null | string match -r "on stack '(.*)'" | string replace -r ".*'(.*)'" '$1')
                
                if test "$this_stack" = "$stack"
                    set -l status (_wt_get_worktree_status $worktree_dir)
                    set -l worktree_name (basename $worktree_dir)
                    printf "  ├─ %-20s [worktree: %-15s] %s\n" $branch "$worktree_name/" $status
                end
            end
        end
        
        echo ""
    end
end

# Sync entire stack
function _wt_stack_sync
    set -l stack_name $argv[1]
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    if test -z "$stack_name"
        # Sync current stack
        set -l current_stack (gt stack 2>/dev/null | string match -r "on stack '(.*)'" | string replace -r ".*'(.*)'" '$1')
        if test -z "$current_stack"
            echo "Error: Not on a stack" >&2
            return 1
        end
        set stack_name $current_stack
    end
    
    echo "Syncing stack: $stack_name"
    
    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config
    
    # Find all worktrees in this stack
    set -l stack_worktrees
    
    for worktree_dir in $WORKTREES_PATH/*
        if test -d $worktree_dir
            cd $worktree_dir
            set -l this_stack (gt stack 2>/dev/null | string match -r "on stack '(.*)'" | string replace -r ".*'(.*)'" '$1')
            
            if test "$this_stack" = "$stack_name"
                set -a stack_worktrees $worktree_dir
            end
        end
    end
    
    # Sync each worktree in order
    for worktree in $stack_worktrees
        echo ""
        echo "🔄 Syncing $(basename $worktree)..."
        cd $worktree
        _wt_sync_single false false
    end
    
    echo ""
    echo "📤 Submitting stack..."
    gt submit --stack
end

# Submit current branch and upstack
function wt_submit
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    echo "Submitting current branch and upstack..."
    gt submit --stack
end

# Environment sync operations
function wt_env
    set -l subcommand $argv[1]
    set -l remaining_args $argv[2..-1]
    
    switch $subcommand
        case sync
            _wt_env_sync $remaining_args
        case '*'
            echo "Usage: wt env sync [--all]"
            return 1
    end
end

# Sync environment files
function _wt_env_sync
    set -l sync_all false
    
    if test "$argv[1]" = "--all"
        set sync_all true
    end
    
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config
    
    if not test -d $ENVS_PATH
        echo "No environment files found in $ENVS_PATH"
        return 0
    end
    
    if test $sync_all = true
        echo "Syncing environment files to all worktrees..."
        
        for worktree_dir in $WORKTREES_PATH/*
            if test -d $worktree_dir
                echo "  → $(basename $worktree_dir)"
                cp -r "$ENVS_PATH/." "$worktree_dir/"
            end
        end
    else
        set -l current_worktree (pwd)
        echo "Syncing environment files to current worktree..."
        cp -r "$repo_root/$ENVS_PATH/." "$current_worktree/"
    end
    
    echo "✓ Environment files synced"
end


# Main command dispatcher
function wt
    set -l command $argv[1]
    set -l remaining_args $argv[2..-1]
    
    
    switch $command
        case init clone
            wt_init $remaining_args
        case new
            wt_new $remaining_args
        case list ls
            wt_list $remaining_args
        case remove rm
            wt_remove $remaining_args
        case status st
            wt_status $remaining_args
        case switch sw
            wt_switch $remaining_args
        case up
            wt_up $remaining_args
        case down
            wt_down $remaining_args
        case bottom
            wt_bottom $remaining_args
        case sync
            wt_sync $remaining_args
        case restack
            wt_restack $remaining_args
        case stack
            wt_stack $remaining_args
        case submit
            wt_submit $remaining_args
        case env
            wt_env $remaining_args
        case version --version -v
            echo "wt version $WT_VERSION"
        case help --help -h ''
            _wt_help
        case '*'
            echo "Unknown command: $command"
            _wt_help
            return 1
    end
end

# Help text
function _wt_help
    echo "Worktree Toolkit (wt) - Git worktree management with Graphite integration"
    echo ""
    echo "Usage: wt <command> [options]"
    echo ""
    echo "Repository Management:"
    echo "  init <repo-url> [name]    Clone and set up worktree structure"
    echo "  clone <repo-url> [name]   Alias for init"
    echo ""
    echo "Worktree Operations:"
    echo "  new <name> [options]        Create new worktree (or checkout remote)"
    echo "    --from <base>             Base branch (default: trunk)"
    echo "    --force-new               Skip remote check, always create new"
    echo "  list                        List all worktrees"
    echo "  switch <name>               Open worktree in tmux/muxit"
    echo "  remove <name>               Remove worktree"
    echo ""
    echo "Stack Operations:"
    echo "  stack list                  Show all stacks"
    echo "  stack sync [name]           Sync entire stack"
    echo "  restack                     Rebase current stack"
    echo ""
    echo "Navigation:"
    echo "  up                          Switch to upstack worktree"
    echo "  down                        Switch to downstack worktree"
    echo "  bottom                      Switch to stack base"
    echo ""
    echo "Development:"
    echo "  status [--all]              Show worktree status"
    echo "  sync [--all] [--force]      Sync with remote"
    echo "  submit                      Submit stack to GitHub"
    echo ""
    echo "Environment:"
    echo "  env sync [--all]            Copy environment files"
    echo ""
    echo "Other:"
    echo "  help                        Show this help"
    echo "  version                     Show version"
end

# Export main function
wt $argv