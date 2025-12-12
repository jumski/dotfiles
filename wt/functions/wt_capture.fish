#!/usr/bin/env fish
# Capture current branch to a new worktree

function wt_capture
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt capture [worktree-name] [--switch] [--force] [--no-claude-session] [--yes]

Capture current branch to a new worktree

This command is designed for Graphite stacks: it creates a worktree for the
current branch and switches the original worktree to trunk.

Arguments:
  [worktree-name]       Optional name for the worktree (default: branch name)

Options:
  --switch              Switch to new worktree after creation
  --force               Skip Graphite checks, use git reflog fallback
  --no-claude-session   Skip Claude session migration
  --yes                 Auto-confirm all prompts

Session migration:
  By default, ALL Claude sessions matching the current branch (by gitBranch
  field) are copied to the new worktree. The most recent session is resumed.

Examples:
  wt capture                     # Worktree name = branch name
  wt capture myfeature           # Custom worktree name
  wt capture --switch            # Capture and switch to new worktree
  wt capture --no-claude-session # Skip session migration

Requirements:
  - Graphite must be installed (unless --force)
  - Branch must be tracked by Graphite (unless --force)
  - Cannot capture trunk branch
  - tmux must be running
  - jq required for Claude session migration

Note:
  To create a worktree for a different branch, use: wt new <branch-name>"
    and return 0

    # Save original directory - restore on any error after cd
    # Note: Phase 1-2 errors don't need restoration (haven't cd'd yet)
    set -l saved_pwd (pwd)

    # ============================================================
    # PHASE 1: GATHER INFO & VALIDATE (fail fast, no side effects)
    # ============================================================

    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1

    _wt_check_legacy_format
    or return 1

    # Parse arguments
    set -l switch_after false
    set -l force false
    set -l auto_yes false
    set -l skip_claude_session false
    set -l custom_worktree_name ""

    for arg in $argv
        switch $arg
            case --switch
                set switch_after true
            case --force
                set force true
            case --yes
                set auto_yes true
            case --no-claude-session
                set skip_claude_session true
            case '-*'
                echo "Error: Unknown option '$arg'" >&2
                echo "  Run 'wt capture --help' for usage" >&2
                return 1
            case '*'
                # First positional arg is optional worktree name
                if test -z "$custom_worktree_name"
                    set custom_worktree_name $arg
                else
                    echo "Error: Too many positional arguments" >&2
                    echo "  wt capture accepts at most one: [worktree-name]" >&2
                    return 1
                end
        end
    end

    # Get current branch
    set -l branch_to_capture (git branch --show-current)
    if test -z "$branch_to_capture"
        echo "Error: Not on a branch (detached HEAD)" >&2
        echo "  Cannot capture a detached HEAD" >&2
        echo "" >&2
        echo "To create a worktree for a specific branch:" >&2
        echo "  wt new <branch-name>" >&2
        return 1
    end

    # Use custom name if provided, otherwise default to branch name
    set -l worktree_name $branch_to_capture
    if test -n "$custom_worktree_name"
        set worktree_name $custom_worktree_name
    end

    # Get repo config (cd briefly, then return)
    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config
    cd $saved_pwd

    # Get trunk branch
    set -l trunk_branch $DEFAULT_TRUNK
    if command -q gt
        set -l gt_trunk (gt trunk 2>/dev/null)
        if test -n "$gt_trunk"
            set trunk_branch $gt_trunk
        end
    end

    # --- VALIDATION (fail fast before showing plan) ---

    # Check: Graphite available (unless --force)
    if not command -q gt
        if test $force = false
            echo "Error: Graphite (gt) required for wt capture" >&2
            echo "" >&2
            echo "Install Graphite:" >&2
            echo "  npm install -g @withgraphite/graphite-cli@stable" >&2
            echo "" >&2
            echo "Or use --force to skip Graphite checks" >&2
            return 1
        end
    end

    # Check: tmux running
    if not test -n "$TMUX"
        echo "Error: Must be running inside tmux for wt capture" >&2
        echo "  Start tmux first: tmux new -s mysession" >&2
        return 1
    end

    # Check: jq available (if session migration)
    if test "$skip_claude_session" = false
        if not command -q jq
            echo "Error: jq required for Claude session migration" >&2
            echo "  Install jq or use --no-claude-session to skip" >&2
            return 1
        end
    end

    # Check: not on trunk
    if test "$branch_to_capture" = "$trunk_branch"
        echo "Error: Cannot capture trunk branch '$trunk_branch'" >&2
        echo "  Trunk has no parent to switch back to" >&2
        echo "" >&2
        echo "Use instead:" >&2
        echo "  wt new <name>  # Create new worktree from trunk" >&2
        return 1
    end

    # Check: branch tracked by Graphite (unless --force)
    set -l is_tracked false
    if command -q gt
        # gt log short includes tree characters before branch names, so match anywhere
        if gt log short 2>/dev/null | grep -qF "$branch_to_capture"
            set is_tracked true
        end
    end

    if test $is_tracked = false -a $force = false
        echo "Error: Branch '$branch_to_capture' not tracked by Graphite" >&2
        echo "  Current branch must have a parent in the stack" >&2
        echo "" >&2
        echo "Track it first:" >&2
        echo "  gt branch track --parent <parent-branch>" >&2
        echo "" >&2
        echo "Or force (uses git reflog):" >&2
        echo "  wt capture --force" >&2
        return 1
    end

    # ============================================================
    # PHASE 2: FIND CLAUDE SESSIONS & SHOW PLAN
    # ============================================================

    # Build Claude project directory path
    set -l old_project_dir "$HOME/.claude/projects/"(echo $saved_pwd | sed 's|/|-|g')

    # Find all sessions for this branch (before showing plan)
    set -l branch_sessions
    set -l most_recent_session ""

    if test "$skip_claude_session" = false
        for session_file in (ls -t "$old_project_dir"/*.jsonl 2>/dev/null)
            # Skip agent sessions (subagent files)
            if string match -q "agent-*" (basename $session_file .jsonl)
                continue
            end

            set -l session_branch (jq -r 'select(.gitBranch) | .gitBranch' "$session_file" 2>/dev/null | head -1)
            if test "$session_branch" = "$branch_to_capture"
                set -a branch_sessions $session_file
                if test -z "$most_recent_session"
                    set most_recent_session (basename $session_file .jsonl)
                end
            end
        end
    end

    echo ""
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[1;36m  Capture Branch to Worktree\033[0m"
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    echo -e "\033[33m  Branch:  \033[0m \033[1m$branch_to_capture\033[0m"
    echo -e "\033[33m  Worktree:\033[0m \033[1m$worktree_name\033[0m"

    echo ""
    echo -e "\033[1mWill:\033[0m"

    # Show plan based on --force flag
    if test $force = true
        echo -e "\033[33m  ⚠\033[0m Switch current worktree to previous branch (via git checkout -)"
        echo -e "\033[90m      Note: Using git reflog, may be unreliable\033[0m"
    else
        echo -e "\033[32m  ✓\033[0m Switch current worktree to trunk (via gt checkout $trunk_branch)"
    end

    echo -e "\033[32m  ✓\033[0m Kill Claude window (window 4) and start fresh Claude session"
    echo -e "\033[32m  ✓\033[0m Create worktree '\033[1m$worktree_name\033[0m' for branch '\033[1m$branch_to_capture\033[0m'"

    # Session migration info
    if test "$skip_claude_session" = false
        if test (count $branch_sessions) -gt 0
            echo -e "\033[32m  ✓\033[0m Migrate "(count $branch_sessions)" Claude session(s):"
            for session_file in $branch_sessions
                set -l session_id (basename $session_file .jsonl)

                # Get summary or first user message as display text
                set -l summary (jq -r 'select(.summary) | .summary' "$session_file" 2>/dev/null | head -1)
                set -l display_text ""
                if test -n "$summary"
                    set display_text (string sub -l 50 "$summary")
                else
                    set display_text (jq -r 'select(.type=="user") | .message.content' "$session_file" 2>/dev/null | head -1 | string sub -l 50)
                end

                # Get relative time from first user message timestamp
                set -l timestamp (jq -r 'select(.type=="user") | .timestamp' "$session_file" 2>/dev/null | head -1)
                set -l relative_time (_wt_relative_time "$timestamp")

                # Display with indicator for most recent
                if test "$session_id" = "$most_recent_session"
                    echo -e "\033[90m      → $display_text ($relative_time) \033[32m[will resume]\033[0m"
                else
                    echo -e "\033[90m      → $display_text ($relative_time)\033[0m"
                end
            end
        else
            echo -e "\033[90m  →\033[0m No Claude sessions found for this branch"
        end
    else
        echo -e "\033[90m  →\033[0m Skip Claude session migration"
    end

    # Switch info
    if test $switch_after = true
        echo -e "\033[32m  ✓\033[0m Switch to new tmux session"
    else
        echo -e "\033[90m  →\033[0m Stay in current location"
    end

    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    # Confirm
    _wt_confirm --prompt "Proceed" --default-yes $argv
    or begin
        echo -e "\033[90mCancelled\033[0m"
        return 1
    end

    echo ""

    # ============================================================
    # PHASE 3: EXECUTE (cd to repo_root, restore on any error)
    # ============================================================

    # Build remaining paths needed for execution
    set -l worktree_path "$WORKTREES_PATH/$worktree_name"
    set -l new_worktree_path "$repo_root/$worktree_path"
    set -l new_project_dir "$HOME/.claude/projects/"(echo $new_worktree_path | sed 's|/|-|g')

    # Get current worktree name from saved path
    set -l current_worktree_name (echo $saved_pwd | sed -n 's|.*/worktrees/\([^/]*\).*|\1|p')
    if test -z "$current_worktree_name"
        set current_worktree_name (basename $saved_pwd)
    end
    set -l old_tmux_session "$current_worktree_name@$REPO_NAME"

    cd $repo_root

    # Step 1: Switch current worktree to trunk (MUST do this first!)
    _wt_action "Switching current worktree away from '$branch_to_capture'..."

    if test $is_tracked = true
        gt checkout $trunk_branch
        or begin
            echo "Error: Failed to switch to trunk branch '$trunk_branch'" >&2
            cd $saved_pwd
            return 1
        end
    else if test $force = true
        git checkout -
        or begin
            echo "Error: Failed to switch to previous branch" >&2
            cd $saved_pwd
            return 1
        end
    end

    # Step 2: Reset Claude in old tmux session
    _wt_action "Resetting Claude window in $old_tmux_session..."

    tmux kill-window -t "$old_tmux_session:4" 2>/dev/null
    tmux new-window -t "$old_tmux_session:4" -n repl -c "$saved_pwd"
    tmux send-keys -t "$old_tmux_session:4" 'claude' Enter

    # Step 3: Create worktree for captured branch
    _wt_action "Creating worktree for '$branch_to_capture'..."

    wt_new $worktree_name $branch_to_capture --yes
    or begin
        echo "Error: Failed to create worktree" >&2
        cd $saved_pwd
        return 1
    end

    # Step 4: Copy ALL Claude sessions for this branch to new worktree
    set -l new_tmux_session "$worktree_name@$REPO_NAME"
    set -l sessions_copied 0

    if test (count $branch_sessions) -gt 0
        _wt_action "Copying "(count $branch_sessions)" Claude session(s) to new worktree..."

        mkdir -p "$new_project_dir"

        for session_file in $branch_sessions
            if cp "$session_file" "$new_project_dir/" 2>/dev/null
                set sessions_copied (math $sessions_copied + 1)
            end
        end
    end

    # Step 5: Start Claude in new worktree (with resume if we copied sessions)
    if test $sessions_copied -gt 0 -a -n "$most_recent_session"
        _wt_action "Starting Claude with resumed session in new worktree..."

        tmux send-keys -t "$new_tmux_session:4" C-c 2>/dev/null
        sleep 1
        tmux send-keys -t "$new_tmux_session:4" "claude --resume $most_recent_session" Enter
    end

    echo ""
    _wt_success "Captured '$branch_to_capture' to worktree '$worktree_name'"

    if test $sessions_copied -gt 0
        echo -e "\033[90m  Migrated $sessions_copied session(s), resuming: $most_recent_session\033[0m"
    end

    # Step 6: Switch to new worktree if requested
    if test $switch_after = true
        _wt_action "Switching to new tmux session..."
        tmux switch-client -t "$new_tmux_session"
    else
        echo -e "\033[90m  Use 'wt switch $worktree_name' to switch\033[0m"
    end

    # Restore original directory (in case not switching)
    cd $saved_pwd
end
