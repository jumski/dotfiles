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
        git -C $BARE_PATH fetch origin --quiet
        if git -C $BARE_PATH show-ref --verify --quiet refs/remotes/origin/$name
            echo "Remote branch 'origin/$name' found."
            read -P "Create worktree tracking it? [Y/n] " -n 1 confirm
            if test -z "$confirm" -o "$confirm" = "y" -o "$confirm" = "Y"
                set base_branch origin/$name
                set tracking_remote true
            else
                echo "Creating new local branch instead..."
            end
        end
    end
    
    echo "Creating worktree: $name"
    
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
            echo "Warning: Branch '$name' already exists locally"
            read -P "Use existing branch? [Y/n] " -n 1 use_existing
            if test -z "$use_existing" -o "$use_existing" = "y" -o "$use_existing" = "Y"
                git -C $BARE_PATH worktree add ../$worktree_path $name
            else
                echo "Aborting worktree creation"
                return 1
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
    pushd "$repo_root/$worktree_path"
    if test -n "$trunk_branch"
        gt init --trunk $trunk_branch
        or echo "Warning: Failed to initialize Graphite in worktree" >&2
    else
        gt init --trunk $DEFAULT_TRUNK
        or echo "Warning: Failed to initialize Graphite in worktree" >&2
    end
    popd
    
    # Copy environment files if they exist
    if test -d "$repo_root/$ENVS_PATH"
        echo "Copying environment files..."
        cp -r "$repo_root/$ENVS_PATH/." .
    end
    
    echo "✓ Worktree created at $worktree_path"
    echo "✓ Branch '$name' created from '$base_branch'"
    
    # Restore original directory
    cd $saved_pwd
    
    # Switch to new worktree if requested
    if test "$switch_after" = "true"
        wt_switch $name $repo_root
    end
end