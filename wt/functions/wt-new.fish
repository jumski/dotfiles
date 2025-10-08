#!/usr/bin/env fish
# Create new worktree

function wt_new
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt new <name> [--from <branch>] [--trunk <branch>] [--force-new] [--switch]

Create new worktree

Arguments:
  <name>         Name for the new worktree

Options:
  --from <branch>    Base branch (default: DEFAULT_TRUNK from config)
  --trunk <branch>   Trunk branch for Graphite
  --force-new        Force creation even if branch exists
  --switch           Automatically switch to the new worktree after creation"
    and return 0

    set -l name $argv[1]
    set -l base_branch ""
    set -l trunk_branch ""
    set -l force_new false
    set -l switch_after false

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
            case --switch
                set switch_after true
        end
        set i (math $i + 1)
    end
    
    set -l repo_root (_wt_get_repo_root)
    set -l saved_pwd (pwd)
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
    set -l tracking_remote false
    if test "$force_new" = "false"
        echo -e "\033[34m→\033[0m Checking for remote branch..."
        git -C $BARE_PATH fetch origin --quiet
        if git -C $BARE_PATH show-ref --verify --quiet refs/remotes/origin/$name
            echo "Remote branch 'origin/$name' found."
            if _wt_confirm --prompt "Create worktree tracking it" --default-yes
                set base_branch origin/$name
                set tracking_remote true
            else
                echo "Creating new local branch instead..."
            end
        end
    end
    
    echo -e "\033[34m→\033[0m Creating worktree: $name"
    
    # Clean up any stale worktree references
    git -C $BARE_PATH worktree prune
    
    # Create the worktree
    if test "$tracking_remote" = "true"
        # Check if local branch already exists
        if git -C $BARE_PATH show-ref --verify --quiet refs/heads/$name
            # Local branch exists, just use it
            git -C $BARE_PATH worktree add ../$worktree_path $name
        else
            # Create new local branch tracking the remote
            git -C $BARE_PATH worktree add ../$worktree_path -b $name --track $base_branch
        end
    else
        # Check if local branch already exists
        if git -C $BARE_PATH show-ref --verify --quiet refs/heads/$name
            if test "$force_new" = "true"
                # With --force-new, always use existing branch without prompting
                git -C $BARE_PATH worktree add ../$worktree_path $name
            else
                echo "Warning: Branch '$name' already exists locally"
                read -P "Use existing branch? [Y/n] " -n 1 use_existing
                if test -z "$use_existing" -o "$use_existing" = "y" -o "$use_existing" = "Y"
                    git -C $BARE_PATH worktree add ../$worktree_path $name
                else
                    echo "Aborting worktree creation"
                    return 1
                end
            end
        else
            git -C $BARE_PATH worktree add ../$worktree_path -b $name $base_branch
        end
    end
    or begin
        echo "Error: Failed to create worktree" >&2
        return 1
    end
    
    # Initialize Graphite
    echo -e "\033[34m→\033[0m Initializing Graphite..."
    pushd "$repo_root/$worktree_path"
    if test -n "$trunk_branch"
        gt init --trunk $trunk_branch
        or echo "Warning: Failed to initialize Graphite in worktree" >&2
    else
        gt init --trunk $DEFAULT_TRUNK
        or echo "Warning: Failed to initialize Graphite in worktree" >&2
    end
    popd
    
    # Copy environment files to the new worktree
    echo -e "\033[34m→\033[0m Copying environment files..."

    # Call env sync with auto-confirm to copy env files to the new worktree
    set -l current_dir (pwd)
    cd "$repo_root/$worktree_path"

    # Source the env sync function if not already available
    if not functions -q _wt_env_sync
        set -l wt_dir (dirname (status filename))
        source "$wt_dir/wt-env.fish"
    end

    # Call env sync with --yes to skip confirmation
    _wt_env_sync --yes

    cd $current_dir
    
    echo -e "\033[32m✓\033[0m Worktree created at $worktree_path"
    echo -e "\033[32m✓\033[0m Branch '$name' created from '$base_branch'"
    
    # Run post-creation hook if it exists
    set -l hook_script "$repo_root/.wt-post-create"
    if test -f "$hook_script" -a -x "$hook_script"
        echo -e "\033[34m→\033[0m Running post-creation hook..."
        pushd "$repo_root/$worktree_path"
        $hook_script
        or echo "Warning: Post-creation hook failed" >&2
        popd
    end
    
    # Restore original directory
    cd $saved_pwd

    # Always create tmux session, then switch or notify
    # Get repo name for session naming
    set -l repo_name $REPO_NAME
    if test -z "$repo_name"
        set repo_name (basename $repo_root)
    end

    # Create tmux session name
    set -l session_name (_wt_get_session_name $name $repo_name)

    # Check if session already exists (shouldn't happen for new worktrees, but be safe)
    if not tmux has-session -t $session_name 2>/dev/null
        echo -e "\033[34m→\033[0m Creating tmux session: $session_name"

        # Create detached session with standard windows
        tmux \
            new-session -d -c "$worktree_path" -s $session_name \;\
            rename-window -t $session_name:1 server \;\
            new-window -n bash -c "$worktree_path" -t $session_name \;\
            new-window -n vim -c "$worktree_path" -t $session_name \;\
            new-window -n repl -c "$worktree_path" -t $session_name

        echo -e "\033[32m✓\033[0m Tmux session created"
    end

    # Now decide: switch or notify
    if test "$switch_after" = "true"
        echo -e "\033[34m→\033[0m Switching to session..."
        if test -n "$TMUX"
            tmux switch-client -t $session_name
        else
            tmux attach-session -t $session_name
        end
    else
        # Notify user that session is ready
        _wt_notify "✓ Worktree '$name' ready in session '$session_name'"
        echo -e "\033[32m✓\033[0m Session ready: $session_name"
        echo -e "\033[90m  Use 'wt switch $name' to switch\033[0m"
    end
end