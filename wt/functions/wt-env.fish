#!/usr/bin/env fish
# Environment file operations

function wt_env
    set -l subcommand ""
    if test (count $argv) -ge 1
        set subcommand $argv[1]
    end

    set -l remaining_args
    if test (count $argv) -gt 1
        set remaining_args $argv[2..-1]
    end

    switch $subcommand
        case sync
            _wt_env_sync $remaining_args
        case '*'
            echo "Usage: wt env sync [options]"
            echo ""
            echo "Sync all files between worktrees (excluding .git directory)"
            echo ""
            echo "Options:"
            echo "  --all          Sync to all worktrees (except source)"
            echo "  --from <name>  Source worktree (auto-detected if not specified)"
            echo "  --to <name>    Target worktree (default: current)"
            echo "  -y, --yes      Skip confirmation prompt"
            echo ""
            echo "Examples:"
            echo "  wt env sync                        # Copy all files from trunk to current"
            echo "  wt env sync --all                  # Copy from trunk to all worktrees"
            echo "  wt env sync --from dev --to prod   # Copy from dev to prod worktree"
            echo ""
            echo "Note: This will overwrite existing files in the target worktree!"
            return 1
    end
end

# Sync environment files
function _wt_env_sync
    set -l sync_all false
    set -l source_worktree ""
    set -l target_worktree ""
    set -l skip_confirm false
    set -l env_only false

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --all
                set sync_all true
            case --from
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set source_worktree $argv[$i]
                end
            case --to
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set target_worktree $argv[$i]
                end
            case -y --yes
                set skip_confirm true
            case --env-only
                set env_only true
        end
        set i (math $i + 1)
    end

    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1

    set -l repo_root (_wt_get_repo_root)
    set -l saved_pwd (pwd)
    cd $repo_root

    # Source the common functions if not already loaded
    if not functions -q _wt_get_repo_config
        set -l wt_dir (dirname (status filename))
        source "$wt_dir/wt-common.fish"
    end

    _wt_get_repo_config

    # Determine default source if not specified
    if test -z "$source_worktree"
        # Try to detect the trunk/main branch
        if command -q gt
            set source_worktree (gt trunk 2>/dev/null)
        end

        # Fallback to common names if gt doesn't work
        if test -z "$source_worktree"
            for branch_name in main master develop
                if test -d "$WORKTREES_PATH/$branch_name"
                    set source_worktree $branch_name
                    break
                end
            end
        end

        # If still not found, error out
        if test -z "$source_worktree"
            echo "Error: Could not determine source worktree. Use --from to specify." >&2
            cd $saved_pwd
            return 1
        end
    end

    # Determine source path - ALL worktrees are in WORKTREES_PATH
    set -l source_path "$WORKTREES_PATH/$source_worktree"

    if not test -d "$source_path"
        echo "Error: Source worktree '$source_worktree' not found at $source_path" >&2
        cd $saved_pwd
        return 1
    end

    # Get list of files to copy
    set -l files_to_copy

    if test $env_only = true
        # Only copy environment files from the source worktree
        set -l env_patterns ".envrc" ".envrc.local" ".env" ".env.local" ".env.*.local" "*.env"
        for pattern in $env_patterns
            set -l found_files (find $source_path -maxdepth 3 -name "$pattern" -type f \
                -not -path '*/.git/*' \
                -not -path '*/node_modules/*' \
                -not -path '*/.bare/*' \
                -not -path '*/worktrees/*' \
                2>/dev/null)
            if test -n "$found_files"
                set -a files_to_copy $found_files
            end
        end

        # Also check for shared env files in repo_root/envs if it exists
        if test -d "$repo_root/envs"
            set -l shared_env_files (find "$repo_root/envs" -type f -not -path '*/.git/*' 2>/dev/null)
            if test -n "$shared_env_files"
                set -a files_to_copy $shared_env_files
            end
        end

        # Remove duplicates
        if test (count $files_to_copy) -gt 0
            set files_to_copy (printf '%s\n' $files_to_copy | sort -u)
        end
    else
        # Copy all files (excluding .git, .bare, and worktrees)
        set files_to_copy (find $source_path -type f \
            -not -path '*/.git/*' \
            -not -path '*/.bare/*' \
            -not -path '*/worktrees/*' \
            -not -path '*/.graphite_cache_persist' \
            -not -path '*/.graphite_pr_info' \
            2>/dev/null | sort)
    end

    if test (count $files_to_copy) -eq 0
        if test $env_only = true
            # Silent return when no env files found (common case)
            cd $saved_pwd
            return 0
        else
            echo "No files found in $source_worktree worktree"
            cd $saved_pwd
            return 0
        end
    end

    # Determine target worktrees
    set -l target_worktrees
    if test $sync_all = true
        for worktree_dir in $WORKTREES_PATH/*
            if test -d $worktree_dir
                set -l wt_name (basename $worktree_dir)
                # Skip source worktree if syncing all
                if test "$wt_name" != "$source_worktree"
                    set -a target_worktrees $wt_name
                end
            end
        end
    else
        if test -n "$target_worktree"
            # User specified target
            set -a target_worktrees $target_worktree
        else
            # Get current worktree name
            set -l current_worktree_name (_wt_get_current_worktree)
            if test -z "$current_worktree_name"
                # If not in a worktree subdirectory, use the current directory
                set -a target_worktrees "current"
            else
                set -a target_worktrees $current_worktree_name
            end
        end
    end

    # Show preview (skip if auto-confirming for minimal output)
    if test $skip_confirm = false
        echo
        echo -e "\033[1;34mWorktree Files Sync\033[0m"
        echo -e "\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo
        echo -e "\033[36mSource:\033[0m $source_worktree worktree"
        if test $env_only = true
            echo -e "\033[36mEnvironment files to copy:\033[0m" (count $files_to_copy) "files"
        else
            echo -e "\033[36mFiles to copy:\033[0m" (count $files_to_copy) "files"
        end

        # Show first few files as preview
        set -l preview_count 5
        if test (count $files_to_copy) -le 10
            set preview_count (count $files_to_copy)
        end

        for i in (seq 1 $preview_count)
            set -l file $files_to_copy[$i]
            set -l relative_file (string replace "$source_path/" "" $file)
            echo -e "  \033[90m•\033[0m $relative_file"
        end

        if test (count $files_to_copy) -gt $preview_count
            echo -e "  \033[90m... and" (math (count $files_to_copy) - $preview_count) "more files\033[0m"
        end

        echo
        echo -e "\033[36mTarget worktree(s):\033[0m"
        for target in $target_worktrees
            echo -e "  \033[90m•\033[0m $target"
        end
        echo -e "\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    end

    # Prompt for confirmation if not skipped
    if test $skip_confirm = false
        echo -n "Proceed with sync? [y/N]: "

        # Read user input with proper interrupt handling
        read -l -P "" confirm
        set -l read_status $status

        # Check if read was interrupted (Ctrl-C)
        if test $read_status -ne 0
            echo
            echo -e "\033[31m✗\033[0m Sync cancelled"
            cd $saved_pwd
            return 1
        end

        # Check user response
        if not string match -q -i "y" "$confirm"
            echo -e "\033[31m✗\033[0m Sync cancelled"
            cd $saved_pwd
            return 1
        end
    end

    # Perform the sync
    if test $skip_confirm = false
        echo
    end

    set -l any_failed false

    for target in $target_worktrees
        # Determine target path
        set -l target_path
        if test "$target" = "current"
            set target_path $saved_pwd
        else
            set target_path "$WORKTREES_PATH/$target"
            if not test -d "$target_path"
                echo -e "  \033[31m✗\033[0m Target worktree '$target' not found"
                set any_failed true
                continue
            end
        end

        # Only show detailed output if not in auto mode
        if test $skip_confirm = false
            echo -e "\033[34m→\033[0m Syncing files..."
            echo -e "  \033[34m→\033[0m Syncing to: $target"
        end

        if test $env_only = true
            # Copy individual env files preserving paths
            set -l copied_count 0
            for file in $files_to_copy
                set -l relative_file
                set -l target_file

                # Handle files from different sources
                if string match -q "$repo_root/envs/*" $file
                    # Files from shared envs directory - copy to target root
                    set relative_file (string replace "$repo_root/envs/" "" $file)
                    set target_file "$target_path/$relative_file"
                else
                    # Files from source worktree - preserve relative path
                    set relative_file (string replace "$source_path/" "" $file)
                    set target_file "$target_path/$relative_file"
                end

                set -l target_dir (dirname "$target_file")

                # Create target directory if needed
                if not test -d "$target_dir"
                    mkdir -p "$target_dir"
                end

                # Copy the file
                cp -p "$file" "$target_file" 2>/dev/null
                if test $status -eq 0
                    set copied_count (math $copied_count + 1)
                end
            end

            if test $skip_confirm = false
                echo -e "    \033[32m✓\033[0m Copied $copied_count environment files"
            end
        else
            # Use rsync for all files
            rsync -a \
                --exclude='.git' \
                --exclude='.git/**' \
                --exclude='.bare' \
                --exclude='.bare/**' \
                --exclude='worktrees' \
                --exclude='worktrees/**' \
                --exclude='.graphite_cache_persist' \
                --exclude='.graphite_pr_info' \
                "$source_path/" "$target_path/"

            if test $status -eq 0
                if test $skip_confirm = false
                    echo -e "    \033[32m✓\033[0m Successfully synced" (count $files_to_copy) "files"
                end
            else
                echo -e "    \033[31m✗\033[0m Sync failed"
                set any_failed true
            end
        end
    end

    if test $any_failed = true
        echo -e "\033[31m✗\033[0m Some targets failed to sync"
        cd $saved_pwd
        return 1
    end

    # Only show final success message if not in auto mode
    if test $skip_confirm = false
        echo -e "\033[32m✓\033[0m Files synced successfully"
    end
    cd $saved_pwd
end