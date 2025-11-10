#!/usr/bin/env fish
# Sync environment files - internal helper for wt_env

function _wt_env_sync
    set -l sync_all false
    set -l target_worktree ""
    set -l skip_confirm false
    set -l confirm_flag ""

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --all
                set sync_all true
            case --to
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set target_worktree $argv[$i]
                end
            case --yes
                set skip_confirm true
                set confirm_flag --yes
        end
        set i (math $i + 1)
    end

    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1

    # Get current worktree name BEFORE changing directories
    set -l current_worktree_name (_wt_get_current_worktree)

    # Get and validate repo root
    set -l repo_root (_wt_get_repo_root)
    if test -z "$repo_root"
        echo "Error: Could not find worktree repository root" >&2
        return 1
    end

    # Additional safety: verify it looks like a worktree repo
    if not test -f "$repo_root/.wt-config"
        echo "Error: Invalid repository root: $repo_root" >&2
        return 1
    end

    set -l saved_pwd (pwd)
    cd $repo_root

    # Source the common functions if not already loaded
    if not functions -q _wt_get_repo_config
        set -l wt_dir (dirname (dirname (status filename)))
        source "$wt_dir/lib/common.fish"
    end

    _wt_get_repo_config

    # Build source path and validate it exists within repo_root
    set -l source_path "$repo_root/envs"

    if not test -d "$source_path"
        if test $skip_confirm = true
            # Auto mode (called from wt-new) - show warning and continue
            _wt_warning "No envs directory found at $source_path - skipping environment sync"
            cd $saved_pwd
            return 0
        else
            # Manual mode - show error and stop
            echo "Error: No envs directory found at $source_path" >&2
            cd $saved_pwd
            return 1
        end
    end

    # Get list of files to copy using rsync dry-run
    set -l files_to_copy (rsync -an --exclude='.git' --itemize-changes "$source_path/" "$sample_worktree/" 2>/dev/null | grep '^>' | awk '{print $2}')

    if test (count $files_to_copy) -eq 0
        echo "No environment files found in $source_path"
        cd $saved_pwd
        return 0
    end

    # Determine target worktrees
    set -l target_worktrees

    # If not in a worktree, default to --all behavior
    if test -z "$current_worktree_name"
        set sync_all true
    end

    if test $sync_all = true
        for worktree_dir in $WORKTREES_PATH/*
            if test -d $worktree_dir
                set -l wt_name (basename $worktree_dir)
                set -a target_worktrees $wt_name
            end
        end
    else
        if test -n "$target_worktree"
            # User specified target
            set -a target_worktrees $target_worktree
        else
            # Use current worktree
            set -a target_worktrees $current_worktree_name
        end
    end

    # Show preview (skip if auto-confirming for minimal output)
    if test $skip_confirm = false
        echo
        echo -e "\033[1;34mEnvironment Files Sync\033[0m"
        echo -e "\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo
        echo -e "\033[36mSource:\033[0m $source_path"
        echo -e "\033[36mEnvironment files to copy:\033[0m" (count $files_to_copy) "files"

        # Show first few files as preview
        set -l preview_count 5
        if test (count $files_to_copy) -le 10
            set preview_count (count $files_to_copy)
        end

        for i in (seq 1 $preview_count)
            set -l file $files_to_copy[$i]
            set -l dir_path (dirname "$file")
            set -l file_name (basename "$file")

            if test "$dir_path" = "."
                # File is in root, just show filename
                echo -e "  \033[90m•\033[0m $file_name"
            else
                # Show muted directory path + normal filename
                echo -e "  \033[90m•\033[0m \033[90m$dir_path/\033[0m$file_name"
            end
        end

        if test (count $files_to_copy) -gt $preview_count
            echo -e "  \033[90m... and" (math (count $files_to_copy) - $preview_count) "more files\033[0m"
        end

        echo
        echo -e "\033[36mTarget worktree(s):\033[0m"
        for target in $target_worktrees
            if test "$target" = "$current_worktree_name"
                # Highlight current worktree in green with muted green label
                echo -e "  \033[90m•\033[0m \033[32m$target\033[0m \033[92m(current)\033[0m"
            else
                echo -e "  \033[90m•\033[0m $target"
            end
        end
        echo -e "\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    end

    # Prompt for confirmation
    if not _wt_confirm --prompt "Proceed with sync" $confirm_flag
        echo -e "\033[31m✗\033[0m Sync cancelled"
        cd $saved_pwd
        return 1
    end

    # Perform the sync
    if test $skip_confirm = false
        echo
    end

    set -l any_failed false

    for target in $target_worktrees
        # Determine target path
        set -l target_path "$WORKTREES_PATH/$target"
        if not test -d "$target_path"
            echo -e "  \033[31m✗\033[0m Target worktree '$target' not found"
            set any_failed true
            continue
        end

        # Only show detailed output if not in auto mode
        if test $skip_confirm = false
            _wt_action "Syncing files..."
            echo -e "  \033[34m→\033[0m Syncing to: $target"
        end

        # Copy files from envs/ to target worktree root using rsync
        rsync -a --exclude='.git' "$source_path/" "$target_path/"

        if test $status -eq 0
            if test $skip_confirm = false
                echo -e "    \033[32m✓\033[0m Successfully synced" (count $files_to_copy) "files"
            end
        else
            echo -e "    \033[31m✗\033[0m Sync failed"
            set any_failed true
        end
    end

    if test $any_failed = true
        echo -e "\033[31m✗\033[0m Some targets failed to sync"
        cd $saved_pwd
        return 1
    end

    # Only show final success message if not in auto mode
    if test $skip_confirm = false
        _wt_success "Files synced successfully"
    end
    cd $saved_pwd
end
