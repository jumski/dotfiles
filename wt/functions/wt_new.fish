#!/usr/bin/env fish
# Create new worktree

function wt_new
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt new <name> [--from <branch>] [--trunk <branch>] [--force-new] [--switch] [--yes]

Create new worktree

Arguments:
  <name>         Name for the new worktree

Options:
  --from <branch>    Base branch (default: DEFAULT_TRUNK from config)
  --trunk <branch>   Trunk branch for Graphite
  --force-new        Force creation even if branch exists
  --switch           Automatically switch to the new worktree after creation
  --yes, --force     Skip confirmation prompts"
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
            case --yes --force
                # These will be passed to _wt_confirm
        end
        set i (math $i + 1)
    end

    set -l repo_root (_wt_get_repo_root)
    set -l saved_pwd (pwd)
    cd $repo_root
    _wt_get_repo_config

    # ============================================================
    # PHASE 1: GATHER - Collect all information (read-only)
    # ============================================================

    # Default to main trunk if not specified
    if test -z "$base_branch"
        set base_branch $DEFAULT_TRUNK
    end

    set -l worktree_path "$WORKTREES_PATH/$name"

    # Check 1: Worktree directory already exists
    if test -d $worktree_path
        echo "Error: Worktree directory '$name' already exists at $worktree_path" >&2
        cd $saved_pwd
        return 1
    end

    # Clean up any stale worktree references first
    git -C $BARE_PATH worktree prune

    # Check 2: Branch already checked out in another worktree
    set -l existing_worktree (git -C $BARE_PATH worktree list --porcelain | string match -r "worktree.*\nbranch.*/$name\$" | head -1)
    if test -n "$existing_worktree"
        set -l worktree_location (echo $existing_worktree | string match -r 'worktree (.+)' | tail -1)
        echo "Error: Branch '$name' is already checked out in another worktree" >&2
        echo "  Location: $worktree_location" >&2
        echo "" >&2
        echo "Suggestions:" >&2
        echo "  - Switch to existing worktree: wt switch $name" >&2
        echo "  - Remove existing worktree: wt remove $name" >&2
        echo "  - Use a different branch name" >&2
        cd $saved_pwd
        return 1
    end

    # Check 3: Check for remote branch
    set -l tracking_remote false
    set -l remote_exists false
    if test "$force_new" = "false"
        git -C $BARE_PATH fetch origin --quiet 2>/dev/null
        if git -C $BARE_PATH show-ref --verify --quiet refs/remotes/origin/$name
            set remote_exists true
        end
    end

    # Check 4: Check if local branch exists
    set -l local_branch_exists false
    if git -C $BARE_PATH show-ref --verify --quiet refs/heads/$name
        set local_branch_exists true
    end

    # ============================================================
    # PHASE 2: PLAN - Show user what will happen
    # ============================================================

    echo ""
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[1;36m  Create Worktree\033[0m"
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    echo -e "\033[33m  Name:    \033[0m \033[1m$name\033[0m"
    echo -e "\033[33m  Path:    \033[0m \033[90m$repo_root/$worktree_path\033[0m"

    # Determine what action will be taken with the branch
    if test $local_branch_exists = true -a $remote_exists = true
        echo ""
        echo -e "\033[33m  Branch:  \033[0m \033[1;33m$name\033[0m \033[90m(exists locally and remotely)\033[0m"
        echo -e "\033[33m  Remote:  \033[0m \033[1;32morigin/$name\033[0m"
    else if test $local_branch_exists = true
        echo ""
        echo -e "\033[33m  Branch:  \033[0m \033[1;33m$name\033[0m \033[90m(exists locally)\033[0m"
    else if test $remote_exists = true
        echo ""
        echo -e "\033[33m  Branch:  \033[0m \033[1m$name\033[0m \033[90m(new, tracking remote)\033[0m"
        echo -e "\033[33m  Remote:  \033[0m \033[1;32morigin/$name\033[0m"
    else
        echo ""
        echo -e "\033[33m  Branch:  \033[0m \033[1m$name\033[0m \033[90m(new)\033[0m"
        echo -e "\033[33m  Base:    \033[0m \033[1;32m$base_branch\033[0m"
    end

    echo ""
    echo -e "\033[1mWill:\033[0m"

    if test $local_branch_exists = true
        if test $remote_exists = true
            echo -e "\033[32m  ✓\033[0m Use existing local branch '\033[1m$name\033[0m'"
        else
            echo -e "\033[32m  ✓\033[0m Use existing local branch '\033[1m$name\033[0m'"
        end
    else if test $remote_exists = true
        echo -e "\033[32m  ✓\033[0m Create local branch tracking '\033[1morigin/$name\033[0m'"
    else
        echo -e "\033[32m  ✓\033[0m Create new branch from '\033[1m$base_branch\033[0m'"
    end

    echo -e "\033[32m  ✓\033[0m Create worktree at '\033[1m$worktree_path\033[0m'"
    echo -e "\033[32m  ✓\033[0m Copy environment files"
    echo -e "\033[32m  ✓\033[0m Create tmux session"

    if test $switch_after = true
        echo -e "\033[32m  ✓\033[0m Switch to worktree"
    else
        echo -e "\033[90m  →\033[0m Stay in current location"
    end

    # Graphite stack warning if applicable
    if test $remote_exists = true
        # Check if Graphite is initialized
        if git config --get graphite.trunk >/dev/null 2>&1
            # Graphite is in use - check if branch is tracked
            set -l gt_trunk (git config --get graphite.trunk)

            echo ""
            echo -e "\033[33m⚠️  Graphite Detection:\033[0m"
            echo -e "   This repo uses Graphite (trunk: \033[1m$gt_trunk\033[0m)"
            echo ""
            echo -e "\033[90m   Remote branch found, but Graphite stack metadata unknown.\033[0m"
            echo -e "\033[90m   To sync stack relationships, run:\033[0m"
            echo -e "\033[36m   gt downstack get $name\033[0m"
            echo -e "\033[90m   before creating this worktree.\033[0m"
        end
    end

    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    # ============================================================
    # PHASE 3: QUESTIONS - Ask all questions upfront
    # ============================================================

    # Ask about tracking remote if it exists
    if test $remote_exists = true -a "$force_new" = "false"
        _wt_confirm --prompt "Track remote branch 'origin/$name'" --default-yes $argv
        and set tracking_remote true
        or begin
            echo "Will create new local branch instead"
        end
        echo ""
    end

    # Final confirmation
    _wt_confirm --prompt "Proceed" --default-yes $argv
    or begin
        echo -e "\033[90mCancelled\033[0m"
        cd $saved_pwd
        return 1
    end

    echo ""

    # ============================================================
    # PHASE 4: EXECUTE - Do all the work (no more prompts)
    # ============================================================

    echo -e "\033[34m→\033[0m Creating worktree..."

    # Create the worktree
    if test "$tracking_remote" = "true"
        # Check if local branch already exists
        if test $local_branch_exists = true
            # Local branch exists, just use it
            git -C $BARE_PATH worktree add ../$worktree_path $name
        else
            # Create new local branch tracking the remote
            git -C $BARE_PATH worktree add ../$worktree_path -b $name --track $base_branch
        end
    else
        # Check if local branch already exists
        if test $local_branch_exists = true
            # Use existing branch (user already confirmed in PHASE 2)
            git -C $BARE_PATH worktree add ../$worktree_path $name
        else
            # Create new branch
            git -C $BARE_PATH worktree add ../$worktree_path -b $name $base_branch
        end
    end
    or begin
        echo "Error: Failed to create worktree" >&2
        cd $saved_pwd
        return 1
    end

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

    echo -e "\033[32m✓\033[0m Worktree created"

    if test "$tracking_remote" = "true"
        echo -e "\033[32m✓\033[0m Branch '$name' tracking 'origin/$name'"
    else if test $local_branch_exists = false
        echo -e "\033[32m✓\033[0m Branch '$name' created from '$base_branch'"
    end

    # Run post-creation hook if it exists
    set -l hook_script "$repo_root/.wt-post-create"
    if test -f "$hook_script" -a -x "$hook_script"
        echo -e "\033[34m→\033[0m Running post-creation hook..."
        pushd "$repo_root/$worktree_path"
        $hook_script
        or begin
            echo "Warning: Post-creation hook failed" >&2
            # Notify user if they're not switching (they might have switched away during long hook)
            if test "$switch_after" != "true"
                _wt_notify "❌ Worktree '$name': post-create hook failed"
            end
        end
        popd
    end

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

        # Create detached session with standard windows (use absolute path!)
        set -l absolute_worktree_path "$repo_root/$worktree_path"
        tmux \
            new-session -d -c "$absolute_worktree_path" -s $session_name \;\
            rename-window -t $session_name:1 server \;\
            new-window -n bash -c "$absolute_worktree_path" -t $session_name \;\
            new-window -n vim -c "$absolute_worktree_path" -t $session_name \;\
            new-window -n repl -c "$absolute_worktree_path" -t $session_name

        or begin
            echo "Warning: Failed to create tmux session" >&2
            # Notify user if they're not switching
            if test "$switch_after" != "true"
                _wt_notify "❌ Worktree '$name': tmux session creation failed"
            end
            # Restore directory and return (worktree is created successfully, just skip tmux session)
            cd $saved_pwd
            return 0
        end

        echo -e "\033[32m✓\033[0m Tmux session created"
    end

    # Now decide: switch or notify
    if test "$switch_after" = "true"
        echo -e "\033[34m→\033[0m Switching to session..."
        if test -n "$TMUX"
            tmux switch-client -t $session_name
            or echo "Warning: Failed to switch to session" >&2
        else
            tmux attach-session -t $session_name
            or echo "Warning: Failed to attach to session" >&2
        end
    else
        # Restore original directory
        cd $saved_pwd

        # Notify user that session is ready
        _wt_notify "✨ Worktree '$name' ready in session '$session_name'"
        echo -e "\033[32m✓\033[0m Session ready: $session_name"
        echo -e "\033[90m  Use 'wt switch $name' to switch\033[0m"
    end
end