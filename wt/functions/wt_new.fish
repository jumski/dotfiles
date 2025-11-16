#!/usr/bin/env fish
# Create new worktree

function wt_new
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt new <worktree-name> [branch-name] [--switch] [--yes]

Create new worktree for an existing branch

Arguments:
  <worktree-name>    Name for the new worktree directory
  [branch-name]      Optional branch name (default: same as worktree-name)

Options:
  --switch           Automatically switch to the new worktree after creation
  --yes              Skip confirmation prompts

Examples:
  wt new auth-system              # Worktree and branch both 'auth-system'
  wt new auth-system auth-db      # Worktree 'auth-system', branch 'auth-db'
  wt new profiles jumski/add-profiles  # Handle branches with slashes

Note:
  This command requires the branch to exist locally.
  If branch doesn't exist, create it first with one of:
    - gt get <branch>               (for Graphite repos, syncs from remote)
    - gt create <branch>            (for Graphite repos, creates new)
    - git checkout -b <branch>      (for non-Graphite repos)"
    and return 0

    set -l name $argv[1]
    set -l branch_name ""
    set -l switch_after false

    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1

    _wt_assert "test -n '$name'" "Worktree name required"
    or return 1

    # Parse arguments: check if second arg is a branch name (not a flag)
    set -l i 2
    if test $i -le (count $argv)
        if not string match -q -- '-*' $argv[$i]
            set branch_name $argv[$i]
            set i (math $i + 1)
        end
    end

    # If no branch name provided, use worktree name
    if test -z "$branch_name"
        set branch_name $name
    end

    # Parse options
    while test $i -le (count $argv)
        switch $argv[$i]
            case --switch
                set switch_after true
            case --yes
                # Will be passed to _wt_confirm
            case '*'
                echo "Error: Unknown option '$argv[$i]'" >&2
                echo "  Run 'wt new --help' for usage" >&2
                return 1
        end
        set i (math $i + 1)
    end

    set -l repo_root (_wt_get_repo_root)
    set -l saved_pwd (pwd)
    cd $repo_root
    _wt_get_repo_config

    # ============================================================
    # PHASE 1: SAFETY CHECKS - Fail fast if branch doesn't exist
    # ============================================================

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
    set -l existing_worktree (git -C $BARE_PATH worktree list --porcelain | string match -r "worktree.*\nbranch.*/$branch_name\$" | head -1)
    if test -n "$existing_worktree"
        set -l worktree_location (echo $existing_worktree | string match -r 'worktree (.+)' | tail -1)
        echo "Error: Branch '$branch_name' is already checked out in another worktree" >&2
        echo "  Location: $worktree_location" >&2
        echo "" >&2
        echo "Suggestions:" >&2
        echo "  - Switch to that worktree instead: wt switch <worktree>" >&2
        echo "  - Remove that worktree first: wt remove <worktree>" >&2
        echo "  - Use a different branch name" >&2
        cd $saved_pwd
        return 1
    end

    # Check 3: FAIL FAST - Branch must exist locally
    if not git -C $BARE_PATH show-ref --verify --quiet refs/heads/$branch_name
        echo "Error: Branch '$branch_name' does not exist locally" >&2
        echo "" >&2

        # Check if remote exists
        git -C $BARE_PATH fetch origin --quiet 2>/dev/null
        set -l remote_exists false
        if git -C $BARE_PATH show-ref --verify --quiet refs/remotes/origin/$branch_name
            set remote_exists true
        end

        # Check if Graphite is in use
        set -l graphite_detected false
        if command -q gt
            if git config --get graphite.trunk >/dev/null 2>&1
                set graphite_detected true
            end
        end

        # Provide helpful error message
        if test $remote_exists = true -a $graphite_detected = true
            echo -e "\033[33mRemote branch '\033[1morigin/$branch_name\033[0;33m' found in Graphite repo.\033[0m" >&2
            echo "" >&2
            echo "Sync Graphite stack first:" >&2
            echo -e "  \033[36mgt get $branch_name\033[0m" >&2
            echo "" >&2
            echo "Then create worktree:" >&2
            echo -e "  \033[36mwt new $name $branch_name\033[0m" >&2
        else if test $remote_exists = true
            echo -e "\033[33mRemote branch '\033[1morigin/$branch_name\033[0;33m' found.\033[0m" >&2
            echo "" >&2
            echo "Option 1 (recommended - proper tracking):" >&2
            echo -e "  \033[36mgt get $branch_name\033[0m" >&2
            echo -e "  \033[36mwt new $name $branch_name\033[0m" >&2
            echo "" >&2
            echo "Option 2 (git-only - if not using Graphite):" >&2
            echo -e "  \033[36mgit checkout --track origin/$branch_name\033[0m" >&2
            echo -e "  \033[36mwt new $name $branch_name\033[0m" >&2
            echo "" >&2
            echo -e "\033[90mNote: 'git fetch origin branch:branch' creates untracked branches\033[0m" >&2
            echo -e "\033[90m      Use '--track' or 'gt get' for proper tracking\033[0m" >&2
        else if test $graphite_detected = true
            echo "Branch not found locally or remotely." >&2
            echo "" >&2
            echo "Create branch first:" >&2
            echo -e "  \033[36mgt create $branch_name\033[0m" >&2
            echo "" >&2
            echo "Then create worktree:" >&2
            echo -e "  \033[36mwt new $name $branch_name\033[0m" >&2
        else
            echo "Branch not found locally or remotely." >&2
            echo "" >&2
            echo "Create branch first:" >&2
            echo -e "  \033[36mgit checkout -b $branch_name\033[0m" >&2
            echo "" >&2
            echo "Then create worktree:" >&2
            echo -e "  \033[36mwt new $name $branch_name\033[0m" >&2
        end

        cd $saved_pwd
        return 1
    end

    # ============================================================
    # PHASE 2: CONFIRM - Show user what will happen
    # ============================================================

    echo ""
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[1;36m  Create Worktree\033[0m"
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    echo -e "\033[33m  Worktree:\033[0m \033[1m$name\033[0m"
    echo -e "\033[33m  Branch:  \033[0m \033[1m$branch_name\033[0m"
    echo -e "\033[33m  Path:    \033[0m \033[90m$worktree_path\033[0m"

    echo ""
    echo -e "\033[1mWill:\033[0m"
    echo -e "\033[32m  ✓\033[0m Create worktree for existing branch '\033[1m$branch_name\033[0m'"
    echo -e "\033[32m  ✓\033[0m Copy environment files"
    echo -e "\033[32m  ✓\033[0m Create tmux session"

    if test $switch_after = true
        echo -e "\033[32m  ✓\033[0m Switch to worktree"
    else
        echo -e "\033[90m  →\033[0m Stay in current location"
    end

    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    # Final confirmation
    _wt_confirm --prompt "Proceed" --default-yes $argv
    or begin
        echo -e "\033[90mCancelled\033[0m"
        cd $saved_pwd
        return 1
    end

    echo ""

    # ============================================================
    # PHASE 3: EXECUTE - Create worktree for existing branch
    # ============================================================

    _wt_action "Creating worktree..."

    # Branch exists locally - just create worktree for it
    git -C $BARE_PATH worktree add ../$worktree_path $branch_name
    or begin
        echo "Error: Failed to create worktree" >&2
        cd $saved_pwd
        return 1
    end

    # Copy environment files to the new worktree
    _wt_action "Copying environment files..."

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

    _wt_success "Worktree created for branch '$branch_name'"

    # Run post-creation hook if it exists
    set -l hook_script "$repo_root/.wt-post-create"
    if test -f "$hook_script" -a -x "$hook_script"
        _wt_action "Running post-creation hook..."
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
        _wt_action "Creating tmux session: $session_name"

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

        _wt_success "Tmux session created"
    end

    # Now decide: switch or notify
    if test "$switch_after" = "true"
        # Restore directory before switching (tmux will inherit new directory)
        cd $saved_pwd

        _wt_action "Switching to session..."
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
        _wt_success "Session ready: $session_name"
        echo -e "\033[90m  Use 'wt switch $name' to switch\033[0m"
    end
end