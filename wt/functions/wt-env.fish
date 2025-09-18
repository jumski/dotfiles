#!/usr/bin/env fish
# Environment file operations

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
    set -l saved_pwd (pwd)
    cd $repo_root
    _wt_get_repo_config

    if not test -d $ENVS_PATH
        echo "No environment files found in $ENVS_PATH"
        cd $saved_pwd
        return 0
    end

    # Get list of files that will be copied
    set -l files_to_copy (find $ENVS_PATH -type f -not -path '*/.git/*' 2>/dev/null | sort)

    if test (count $files_to_copy) -eq 0
        echo "No files to sync in $ENVS_PATH"
        cd $saved_pwd
        return 0
    end

    # Determine target worktrees
    set -l target_worktrees
    if test $sync_all = true
        for worktree_dir in $WORKTREES_PATH/*
            if test -d $worktree_dir
                set -a target_worktrees (basename $worktree_dir)
            end
        end
    else
        # Get current worktree name
        set -l current_worktree_name (_wt_get_current_worktree)
        if test -z "$current_worktree_name"
            # If not in a worktree subdirectory, use the current directory
            set -a target_worktrees "current directory"
        else
            set -a target_worktrees $current_worktree_name
        end
    end

    # Show preview
    echo -e "\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[1;34mEnvironment Sync Preview\033[0m"
    echo -e "\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo
    echo -e "\033[36mFiles to copy:\033[0m"
    for file in $files_to_copy
        set -l relative_file (string replace "$ENVS_PATH/" "" $file)
        echo -e "  \033[90m•\033[0m $relative_file"
    end
    echo
    echo -e "\033[36mTarget worktree(s):\033[0m"
    for target in $target_worktrees
        echo -e "  \033[90m•\033[0m $target"
    end
    echo -e "\033[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

    # Prompt for confirmation
    echo -e -n "\033[1;33mProceed with sync? [y/N]:\033[0m "

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

    # Perform the sync
    if test $sync_all = true
        echo -e "\033[34m→\033[0m Syncing environment files to all worktrees..."

        for worktree_dir in $WORKTREES_PATH/*
            if test -d $worktree_dir
                set -l worktree_name (basename $worktree_dir)
                echo -e "  \033[34m→\033[0m $worktree_name"
                rsync -av --exclude='.git' "$ENVS_PATH/" "$worktree_dir/" > /dev/null 2>&1
                if test $status -eq 0
                    echo -e "    \033[32m✓\033[0m Synced"
                else
                    echo -e "    \033[31m✗\033[0m Failed to sync"
                end
            end
        end
    else
        # Sync to current worktree
        set -l current_worktree_path
        set -l current_worktree_name (_wt_get_current_worktree)

        if test -n "$current_worktree_name"
            set current_worktree_path "$WORKTREES_PATH/$current_worktree_name"
        else
            # Use current directory if not in a worktree
            set current_worktree_path $saved_pwd
        end

        echo -e "\033[34m→\033[0m Syncing environment files to $current_worktree_path..."
        rsync -av --exclude='.git' "$repo_root/$ENVS_PATH/" "$current_worktree_path/" > /dev/null 2>&1

        if test $status -eq 0
            echo -e "  \033[32m✓\033[0m Synced"
        else
            echo -e "  \033[31m✗\033[0m Failed to sync"
            cd $saved_pwd
            return 1
        end
    end

    echo -e "\033[32m✓\033[0m Environment files synced successfully"
    cd $saved_pwd
end