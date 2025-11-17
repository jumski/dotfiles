#!/usr/bin/env fish
# Diagnose and fix common issues in worktree repositories

function wt_doctor
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt doctor [--fix] [path/to/repo]

Diagnose and fix common issues in worktree repositories

Arguments:
  [path/to/repo]  Optional: path to repository (defaults to current)

Options:
  --fix           Automatically fix detected issues"
    and return 0

    set -l auto_fix false
    set -l repo_path

    # Parse arguments
    for arg in $argv
        switch $arg
            case --fix
                set auto_fix true
            case '*'
                set repo_path $arg
        end
    end

    # If no repo path provided, check if we're in a worktree repo
    if test -z "$repo_path"
        set repo_path (_wt_get_repo_root)
        if test -z "$repo_path"
            echo "Error: Not in a worktree repository" >&2
            return 1
        end
    end

    # Verify repo path exists and has .wt-config
    if not test -d "$repo_path"
        echo "Error: Directory does not exist: $repo_path" >&2
        return 1
    end

    if not test -d "$repo_path/.wt"; and not test -f "$repo_path/.wt-config"
        echo "Error: Not a worktree repository: $repo_path" >&2
        return 1
    end

    echo -e "\033[1m🔍 Diagnosing worktree repository:\033[0m $repo_path"
    echo ""

    set -l issues_found 0
    set -l issues_fixed 0

    # Check 1: Bare repository exists
    echo -n "  Checking bare repository... "
    if not test -d "$repo_path/.bare"
        echo -e "\033[31m✗ MISSING\033[0m"
        echo "    Expected: $repo_path/.bare"
        set issues_found (math $issues_found + 1)
    else
        echo -e "\033[32m✓\033[0m"
    end

    # Check 2: Remote fetch refspec configuration
    if test -d "$repo_path/.bare"
        echo -n "  Checking remote fetch refspec... "

        # Get list of remotes
        set -l remotes (git -C $repo_path/.bare remote 2>/dev/null)

        if test -z "$remotes"
            echo -e "\033[33m⚠ NO REMOTES\033[0m"
        else
            set -l fetch_issues 0
            set -l missing_refspecs

            for remote in $remotes
                set -l fetch_refspec (git -C $repo_path/.bare config --get remote.$remote.fetch 2>/dev/null)

                if test -z "$fetch_refspec"
                    set missing_refspecs $missing_refspecs $remote
                    set fetch_issues (math $fetch_issues + 1)
                end
            end

            if test $fetch_issues -gt 0
                echo -e "\033[31m✗ MISSING\033[0m"
                for remote in $missing_refspecs
                    echo "    Remote '$remote' missing fetch refspec"
                end
                set issues_found (math $issues_found + 1)

                # Offer to fix
                if test $auto_fix = true
                    echo "    Fixing..."
                    for remote in $missing_refspecs
                        _wt_configure_remote_fetch $repo_path/.bare $remote
                        and echo "      ✓ Configured $remote"
                        and set issues_fixed (math $issues_fixed + 1)
                        or echo "      ✗ Failed to configure $remote" >&2
                    end
                else
                    echo "    Run with --fix to automatically configure"
                end
            else
                echo -e "\033[32m✓\033[0m"
            end
        end
    end

    # Check 3: Worktrees directory exists
    echo -n "  Checking worktrees directory... "
    if not test -d "$repo_path/worktrees"
        echo -e "\033[31m✗ MISSING\033[0m"
        set issues_found (math $issues_found + 1)

        if test $auto_fix = true
            echo "    Creating worktrees directory..."
            mkdir -p "$repo_path/worktrees"
            and echo "      ✓ Created"
            and set issues_fixed (math $issues_fixed + 1)
            or echo "      ✗ Failed to create" >&2
        else
            echo "    Run with --fix to create"
        end
    else
        echo -e "\033[32m✓\033[0m"
    end

    # Check 4: Config format (new vs legacy)
    echo -n "  Checking config format... "
    if test -L "$repo_path/.wt"
        echo -e "\033[32m✓ NEW FORMAT\033[0m (symlinked to dotfiles)"
        set -l target (readlink "$repo_path/.wt")
        echo "    → $target"
    else if test -d "$repo_path/.wt"
        echo -e "\033[32m✓ NEW FORMAT\033[0m (local directory)"
    else if test -f "$repo_path/.wt-config"
        echo -e "\033[33m⚠ LEGACY FORMAT\033[0m"
        echo "    Using .wt-config (deprecated)"
        echo "    Migrate to new format: cd $repo_path && wt config-link"
        set issues_found (math $issues_found + 1)
    else
        echo -e "\033[31m✗ NO CONFIG\033[0m"
        set issues_found (math $issues_found + 1)
    end

    # Check 5: Envs directory exists
    echo -n "  Checking envs directory... "
    if not test -d "$repo_path/envs"
        echo -e "\033[33m⚠ MISSING\033[0m (optional)"

        if test $auto_fix = true
            echo "    Creating envs directory..."
            mkdir -p "$repo_path/envs"
            and echo "      ✓ Created"
            or echo "      ✗ Failed to create" >&2
        end
    else
        echo -e "\033[32m✓\033[0m"
    end

    # Check 6: Verify worktrees are valid
    if test -d "$repo_path/worktrees"
        echo -n "  Checking worktree validity... "
        set -l invalid_worktrees 0
        set -l git_worktrees (git -C $repo_path/.bare worktree list --porcelain 2>/dev/null | grep "^worktree " | sed 's/^worktree //')

        for dir in $repo_path/worktrees/*
            if test -d $dir
                set -l dir_path (realpath $dir)
                if not contains $dir_path $git_worktrees
                    set invalid_worktrees (math $invalid_worktrees + 1)
                end
            end
        end

        if test $invalid_worktrees -gt 0
            echo -e "\033[33m⚠ $invalid_worktrees ORPHANED\033[0m"
            echo "    Run 'git worktree prune' to clean up"
        else
            echo -e "\033[32m✓\033[0m"
        end
    end

    # Summary
    echo ""
    echo -e "\033[1mSummary:\033[0m"

    if test $issues_found -eq 0
        echo -e "  \033[32m✓ All checks passed!\033[0m"
        return 0
    else
        echo -e "  \033[33m⚠ Found $issues_found issue(s)\033[0m"

        if test $auto_fix = true
            if test $issues_fixed -gt 0
                echo -e "  \033[32m✓ Fixed $issues_fixed issue(s)\033[0m"
            end

            set -l remaining (math $issues_found - $issues_fixed)
            if test $remaining -gt 0
                echo -e "  \033[31m✗ $remaining issue(s) could not be auto-fixed\033[0m"
            end
        else
            echo ""
            echo "  Run 'wt doctor --fix' to automatically fix issues"
        end

        return 1
    end
end
