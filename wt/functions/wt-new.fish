#!/usr/bin/env fish
# Create new worktree

function wt_new
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
    
    # Switch to new worktree if requested
    if test "$switch_after" = "true"
        wt_switch $name $repo_root
    end
end