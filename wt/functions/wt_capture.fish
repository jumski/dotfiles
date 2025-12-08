#!/usr/bin/env fish
# Capture current branch to a new worktree

function wt_capture
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt capture [--switch] [--force] [--claude-session[=ID]] [--no-claude-session]

Capture current branch to a new worktree

This command is designed for Graphite stacks: it creates a worktree for the
current branch and switches the original worktree to trunk (main).

The worktree name will be the same as the branch name.

Options:
  --switch              Switch to new worktree after creation (default: no)
  --force               Skip Graphite checks, use git reflog fallback
  --claude-session[=ID] Migrate Claude Code session to new worktree
                        - Without ID: fzf picker to select session (requires fzf)
                        - With ID: migrate specific session (e.g., --claude-session=abc123)
  --no-claude-session   Skip Claude session migration (when --switch is used)
  --yes                 Auto-confirm all prompts (uses most recent session)

Default behavior:
  - With --switch: migrates most recent Claude session automatically
  - Without --switch: no session migration

Examples:
  wt capture                              # Capture, stay here, no session migration
  wt capture --switch                     # Capture, switch, migrate most recent session
  wt capture --switch --claude-session    # Capture, switch, fzf picker for session
  wt capture --switch --no-claude-session # Capture, switch, skip session migration
  wt capture --switch --yes               # Capture, switch, auto-confirm, most recent session

Requirements:
  - Graphite must be installed (unless --force)
  - Branch must be tracked by Graphite (unless --force)
  - Cannot capture trunk branch
  - tmux must be running
  - jq required for Claude session migration
  - fzf required for interactive session picker

Note:
  To create a worktree for a different branch, use: wt new <branch-name>"
    and return 0

    set -l switch_after false
    set -l force false
    set -l auto_yes false
    set -l claude_session_mode "default"  # default, explicit, picker, skip
    set -l claude_session_id ""

    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1

    # Check for legacy format and fail if detected
    _wt_check_legacy_format
    or return 1

    # Parse arguments - only accept flags, no positional arguments
    for arg in $argv
        switch $arg
            case --switch
                set switch_after true
            case --force
                set force true
            case --yes
                set auto_yes true
            case --no-claude-session
                set claude_session_mode "skip"
            case '--claude-session=*'
                set claude_session_mode "explicit"
                set claude_session_id (string replace '--claude-session=' '' $arg)
            case --claude-session
                set claude_session_mode "picker"
            case '-*'
                echo "Error: Unknown option '$arg'" >&2
                echo "  Run 'wt capture --help' for usage" >&2
                return 1
            case '*'
                echo "Error: wt capture does not accept positional arguments" >&2
                echo "  It always captures the current branch" >&2
                echo "" >&2
                echo "  Current branch: $(git branch --show-current)" >&2
                echo "" >&2
                echo "To create a worktree for a different branch:" >&2
                echo "  wt new <branch-name>" >&2
                return 1
        end
    end

    # Resolve claude session mode based on flags
    # Default: migrate session if --switch is used (unless explicitly skipped)
    if test "$claude_session_mode" = "default"
        if test "$switch_after" = true
            set claude_session_mode "most_recent"
        else
            set claude_session_mode "skip"
        end
    end

    # If picker requested but --yes is set, fall back to most recent
    if test "$claude_session_mode" = "picker" -a "$auto_yes" = true
        set claude_session_mode "most_recent"
    end

    # Get current branch - this is what we're capturing
    set -l branch_to_capture (git branch --show-current)
    if test -z "$branch_to_capture"
        echo "Error: Not on a branch (detached HEAD)" >&2
        echo "  Cannot capture a detached HEAD" >&2
        echo "" >&2
        echo "To create a worktree for a specific branch:" >&2
        echo "  wt new <branch-name>" >&2
        return 1
    end

    # Worktree name is always the branch name
    set -l worktree_name $branch_to_capture

    # Save original worktree path BEFORE any cd commands
    set -l original_worktree_path (pwd)

    # ============================================================
    # PHASE 1: SAFETY CHECKS
    # ============================================================

    # Check 1: Graphite available
    if not command -q gt
        if test $force = false
            echo "Error: Graphite (gt) required for wt capture" >&2
            echo "" >&2
            echo "Install Graphite:" >&2
            echo "  npm install -g @withgraphite/graphite-cli@stable" >&2
            echo "" >&2
            echo "Or use manual worktree creation:" >&2
            echo "  wt new <name> <branch>" >&2
            echo "" >&2
            echo "Or force using git reflog (less reliable):" >&2
            echo "  wt capture --force" >&2
            return 1
        else
            echo "Warning: Graphite not available, will use git reflog fallback" >&2
        end
    end

    # Check 2: tmux required
    if not test -n "$TMUX"
        echo "Error: Must be running inside tmux for wt capture" >&2
        echo "  Start tmux first: tmux new -s mysession" >&2
        return 1
    end

    # Check 3: jq required for Claude session migration
    if test "$claude_session_mode" != "skip"
        if not command -q jq
            echo "Error: jq required for Claude session migration" >&2
            echo "  Install jq or use --no-claude-session to skip" >&2
            return 1
        end
    end

    # Check 4: fzf required for session picker
    if test "$claude_session_mode" = "picker"
        if not command -q fzf
            echo "Error: fzf required for interactive session picker" >&2
            echo "  Install fzf, or use --claude-session=<ID> to specify session" >&2
            echo "  Or use --yes to auto-select most recent session" >&2
            return 1
        end
    end

    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config

    # Check 5: Not on trunk
    set -l trunk_branch $DEFAULT_TRUNK
    if command -q gt
        set -l gt_trunk (gt trunk 2>/dev/null)
        if test -n "$gt_trunk"
            set trunk_branch $gt_trunk
        end
    end

    if test "$branch_to_capture" = "$trunk_branch"
        echo "Error: Cannot capture trunk branch '$trunk_branch'" >&2
        echo "  Trunk has no parent to switch back to" >&2
        echo "" >&2
        echo "Use instead:" >&2
        echo "  wt new <name>  # Create new worktree from trunk" >&2
        return 1
    end

    # Check 6: Branch is tracked by Graphite
    set -l is_tracked false
    if command -q gt
        if gt log short 2>/dev/null | grep -q "^$branch_to_capture\$"
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
    # PHASE 1.5: RESOLVE CLAUDE SESSION (interactive if needed)
    # ============================================================

    # Build Claude project directory paths (using original path saved before cd)
    set -l old_project_dir "$HOME/.claude/projects/"(echo $original_worktree_path | sed 's|/|-|g')
    set -l worktree_path "$WORKTREES_PATH/$worktree_name"
    set -l new_worktree_path "$repo_root/$worktree_path"
    set -l new_project_dir "$HOME/.claude/projects/"(echo $new_worktree_path | sed 's|/|-|g')

    # Get current worktree name from original path (extract last component after /worktrees/)
    set -l current_worktree_name (echo $original_worktree_path | sed -n 's|.*/worktrees/\([^/]*\).*|\1|p')
    if test -z "$current_worktree_name"
        # Fallback: use basename of original path
        set current_worktree_name (basename $original_worktree_path)
    end
    set -l old_tmux_session "$current_worktree_name@$REPO_NAME"

    # Resolve session ID based on mode
    if test "$claude_session_mode" != "skip"
        # Check if any sessions exist
        set -l session_files (ls -t "$old_project_dir"/*.jsonl 2>/dev/null | head -20)
        if test (count $session_files) -eq 0
            echo "Warning: No Claude sessions found in $old_project_dir" >&2
            echo "  Skipping session migration" >&2
            set claude_session_mode "skip"
        else if test "$claude_session_mode" = "most_recent"
            # Get most recent session
            set claude_session_id (basename $session_files[1] .jsonl)
        else if test "$claude_session_mode" = "picker"
            # Show fzf picker
            echo ""
            echo -e "\033[36mSelect Claude session to migrate:\033[0m"
            echo ""

            # Build fzf input with session info
            for session_file in $session_files
                set -l id (basename $session_file .jsonl)
                set -l timestamp (jq -r 'select(.type=="user") | .timestamp' "$session_file" 2>/dev/null | head -1)
                set -l preview (jq -r 'select(.type=="user") | .message.content' "$session_file" 2>/dev/null | head -1 | string sub -l 60)
                if test -n "$timestamp"
                    echo -e "$id\t$timestamp\t$preview"
                end
            end | fzf --prompt="Session: " \
                      --header="ID | TIMESTAMP | FIRST MESSAGE" \
                      --delimiter="\t" \
                      --with-nth=2,3 \
                      --preview="jq -r 'select(.type==\"user\") | .message.content' \"$old_project_dir/{1}.jsonl\" 2>/dev/null | head -20" \
                      --height=40% \
            | read -l selected_line

            if test -z "$selected_line"
                echo -e "\033[90mSession selection cancelled\033[0m"
                return 1
            end

            set claude_session_id (echo $selected_line | cut -f1)
        else if test "$claude_session_mode" = "explicit"
            # Validate explicit session ID exists
            if not test -f "$old_project_dir/$claude_session_id.jsonl"
                echo "Error: Session '$claude_session_id' not found in $old_project_dir" >&2
                return 1
            end
        end
    end

    # ============================================================
    # PHASE 2: PLAN & CONFIRM
    # ============================================================

    echo ""
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[1;36m  Capture Branch to Worktree\033[0m"
    echo -e "\033[36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    echo -e "\033[33m  Branch:  \033[0m \033[1m$branch_to_capture\033[0m"
    echo -e "\033[33m  Worktree:\033[0m \033[1m$worktree_name\033[0m"

    if test $is_tracked = true
        set -l parent_info (gt log short 2>/dev/null | grep -B1 "^$branch_to_capture\$" | head -1)
        if test -n "$parent_info"
            echo -e "\033[33m  Parent:  \033[0m \033[1;32m$parent_info\033[0m"
        end
    end

    # Show session info if migrating
    if test "$claude_session_mode" != "skip" -a -n "$claude_session_id"
        echo -e "\033[33m  Session:\033[0m \033[1m$claude_session_id\033[0m"
    end

    echo ""
    echo -e "\033[1mWill:\033[0m"

    # Step 1: Switch to trunk
    if test $is_tracked = true
        echo -e "\033[32m  ✓\033[0m Switch current worktree to trunk (via gt checkout $trunk_branch)"
    else if test $force = true
        echo -e "\033[33m  ⚠\033[0m Switch current worktree to previous branch (via git checkout -)"
        echo -e "\033[90m      Note: Using git reflog, may be unreliable\033[0m"
    end

    # Step 2: Reset Claude in old worktree
    echo -e "\033[32m  ✓\033[0m Kill Claude window (window 4) and start fresh Claude session"

    # Step 3: Create worktree
    echo -e "\033[32m  ✓\033[0m Create worktree '\033[1m$worktree_name\033[0m' for branch '\033[1m$branch_to_capture\033[0m'"

    # Step 4: Session migration
    if test "$claude_session_mode" != "skip" -a -n "$claude_session_id"
        echo -e "\033[32m  ✓\033[0m Copy Claude session to new worktree"
        echo -e "\033[32m  ✓\033[0m Start Claude with resumed session in new worktree"
    else
        echo -e "\033[90m  →\033[0m Skip Claude session migration"
    end

    # Step 5: Switch
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
    # PHASE 3: EXECUTE
    # ============================================================

    # Step 1: Switch current worktree to trunk (MUST do this first!)
    _wt_action "Switching current worktree to trunk ($trunk_branch)..."

    if test $is_tracked = true
        # Use Graphite to checkout trunk
        gt checkout $trunk_branch
        or begin
            echo "Error: Failed to switch to trunk branch '$trunk_branch'" >&2
            echo "  Cannot create worktree while branch is checked out here" >&2
            return 1
        end
    else if test $force = true
        # Fallback to git checkout -
        git checkout -
        or begin
            echo "Error: Failed to switch to previous branch" >&2
            echo "  Cannot create worktree while branch is checked out here" >&2
            return 1
        end
    end

    # Step 2: Reset Claude in old tmux session (kill window 4, create fresh)
    _wt_action "Resetting Claude window in $old_tmux_session..."

    # Kill window 4 if it exists, then create fresh window with new Claude
    tmux kill-window -t "$old_tmux_session:4" 2>/dev/null
    tmux new-window -t "$old_tmux_session:4" -n repl -c "$original_worktree_path"
    tmux send-keys -t "$old_tmux_session:4" 'claude' Enter

    # Step 3: Create worktree for captured branch (now safe - branch not checked out)
    _wt_action "Creating worktree for '$branch_to_capture'..."

    wt_new $worktree_name $branch_to_capture --yes
    or begin
        echo "Error: Failed to create worktree" >&2
        return 1
    end

    # Step 4: Copy Claude session to new worktree (if migrating)
    set -l new_tmux_session "$worktree_name@$REPO_NAME"

    set -l session_copy_success false
    if test "$claude_session_mode" != "skip" -a -n "$claude_session_id"
        _wt_action "Copying Claude session to new worktree..."

        # Create new project directory if needed
        mkdir -p "$new_project_dir"

        # Copy session file
        if cp "$old_project_dir/$claude_session_id.jsonl" "$new_project_dir/" 2>/dev/null
            set session_copy_success true
        else
            echo "Warning: Failed to copy Claude session" >&2
            echo "  Starting fresh Claude session instead" >&2
        end
    end

    # Step 5: Start Claude in new worktree (with resume if copy succeeded)
    if test "$session_copy_success" = true
        _wt_action "Starting Claude with resumed session in new worktree..."

        # Send resume command to window 4 in new tmux session
        # First interrupt any default claude that wt_new might have started
        tmux send-keys -t "$new_tmux_session:4" C-c 2>/dev/null
        sleep 1
        tmux send-keys -t "$new_tmux_session:4" "claude --resume $claude_session_id" Enter
    end

    echo ""
    _wt_success "Captured '$branch_to_capture' to worktree '$worktree_name'"

    if test "$session_copy_success" = true
        echo -e "\033[90m  Claude session migrated: $claude_session_id\033[0m"
    end

    # Step 6: Switch to new worktree if requested
    if test $switch_after = true
        _wt_action "Switching to new tmux session..."
        tmux switch-client -t "$new_tmux_session"
    else
        echo -e "\033[90m  Use 'wt switch $worktree_name' to switch\033[0m"
    end
end
