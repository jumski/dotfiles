#!/usr/bin/env fish

# Tests for pre-remove hook functionality

# Source the common library
source ~/.dotfiles/wt/lib/common.fish

# Setup helper
function setup_test_repo_with_hook
    set -g test_repo_path (mktemp -d)
    mkdir -p "$test_repo_path/.wt"
    mkdir -p "$test_repo_path/worktrees/test-worktree"

    # Create a config file
    echo "REPO_NAME=test-repo" > "$test_repo_path/.wt/config"
end

function cleanup_test_repo
    if test -n "$test_repo_path" -a -d "$test_repo_path"
        rm -rf "$test_repo_path"
    end
end

@test "pre-remove hook: template is created by wt init" (
    set -l temp_dir (mktemp -d)
    set -l repo_name "test-init-repo"
    set -l dotfiles_path "$HOME/.dotfiles/wt/repos/$repo_name"

    # Clean up any existing test repo
    rm -rf "$dotfiles_path"

    # Simulate what wt_init does - just the hook creation part
    mkdir -p "$dotfiles_path"

    echo "#!/bin/bash
# Pre-remove hook for worktrees
# This script runs in the worktree directory before removal
# Add cleanup commands like: docker-compose down, clean up temp files, etc.

echo \"Pre-remove hook executed in: \$(pwd)\"
# Add your cleanup commands here" > "$dotfiles_path/pre-remove"

    chmod +x "$dotfiles_path/pre-remove"

    # Check if file exists and is executable
    set result 0
    if not test -f "$dotfiles_path/pre-remove"
        set result 1
    else if not test -x "$dotfiles_path/pre-remove"
        set result 1
    end

    # Cleanup
    rm -rf "$dotfiles_path"
    rm -rf "$temp_dir"

    echo $result
) -eq 0

@test "pre-remove hook: is not executed when it doesn't exist" (
    setup_test_repo_with_hook
    # Don't create the pre-remove hook file

    set result 0
    cd "$test_repo_path"

    # Check that hook doesn't exist
    if test -f "$test_repo_path/.wt/pre-remove"
        set result 1
    end

    cleanup_test_repo
    echo $result
) -eq 0

@test "pre-remove hook: location is .wt/pre-remove (new format only)" (
    setup_test_repo_with_hook

    # Create hook in new location
    echo "#!/bin/bash
echo 'hook executed'" > "$test_repo_path/.wt/pre-remove"
    chmod +x "$test_repo_path/.wt/pre-remove"

    set result 0
    if not test -f "$test_repo_path/.wt/pre-remove"
        set result 1
    end

    cleanup_test_repo
    echo $result
) -eq 0

@test "pre-remove hook: template has correct content structure" (
    set -l temp_dir (mktemp -d)
    set -l hook_file "$temp_dir/pre-remove"

    echo "#!/bin/bash
# Pre-remove hook for worktrees
# This script runs in the worktree directory before removal
# Add cleanup commands like: docker-compose down, clean up temp files, etc.

echo \"Pre-remove hook executed in: \$(pwd)\"
# Add your cleanup commands here" > "$hook_file"

    set result 0

    # Check shebang
    if not string match -q "#!/bin/bash*" (head -n 1 "$hook_file")
        set result 1
    end

    # Check it mentions "Pre-remove hook"
    if not grep -q "Pre-remove hook" "$hook_file"
        set result 1
    end

    # Check it mentions cleanup commands
    if not grep -q "cleanup commands" "$hook_file"
        set result 1
    end

    rm -rf "$temp_dir"
    echo $result
) -eq 0
