#!/usr/bin/env fish

# Tests for wt config-link command

# Source the function
source ~/.dotfiles/wt/functions/wt_config_link.fish
source ~/.dotfiles/wt/lib/common.fish

# Setup and teardown helpers
function setup_config_link_test
    # Create test repo
    set -g test_repo_path (mktemp -d)
    set -g test_repo_name (basename "$test_repo_path")

    # Create fake git repo
    mkdir -p "$test_repo_path/.bare"
    mkdir -p "$test_repo_path/worktrees"

    # Create test dotfiles directory
    set -g test_dotfiles_path (mktemp -d)
    mkdir -p "$test_dotfiles_path/wt/repos"
end

function cleanup_config_link_test
    if test -n "$test_repo_path" -a -d "$test_repo_path"
        rm -rf "$test_repo_path"
    end
    if test -n "$test_dotfiles_path" -a -d "$test_dotfiles_path"
        rm -rf "$test_dotfiles_path"
    end
end

@test "config-link: detects existing dotfiles config and shows diff" (
    setup_config_link_test

    # Create local .wt-config
    echo "local_setting=value1" > "$test_repo_path/.wt-config"

    # Create existing config in dotfiles
    mkdir -p "$test_dotfiles_path/wt/repos/$test_repo_name"
    echo "dotfiles_setting=value2" > "$test_dotfiles_path/wt/repos/$test_repo_name/config"

    # Override HOME to use test dotfiles
    set -lx HOME "$test_dotfiles_path"

    cd "$test_repo_path"
    wt_config_link 2>&1 | grep -q "Config already exists in dotfiles"
    set result $status

    cleanup_config_link_test
    echo $result
) -eq 0

@test "config-link: exits with error when dotfiles config exists" (
    setup_config_link_test

    # Create local .wt-config
    echo "local_setting=value1" > "$test_repo_path/.wt-config"

    # Create existing config in dotfiles
    mkdir -p "$test_dotfiles_path/wt/repos/$test_repo_name"
    echo "dotfiles_setting=value2" > "$test_dotfiles_path/wt/repos/$test_repo_name/config"

    # Override HOME to use test dotfiles
    set -lx HOME "$test_dotfiles_path"

    cd "$test_repo_path"
    wt_config_link 2>/dev/null
    set result $status

    cleanup_config_link_test
    echo $result
) -eq 1

@test "config-link: shows removal instructions when dotfiles config exists" (
    setup_config_link_test

    # Create local .wt-config
    echo "local_setting=value1" > "$test_repo_path/.wt-config"

    # Create existing config in dotfiles
    mkdir -p "$test_dotfiles_path/wt/repos/$test_repo_name"
    echo "dotfiles_setting=value2" > "$test_dotfiles_path/wt/repos/$test_repo_name/config"

    # Override HOME to use test dotfiles
    set -lx HOME "$test_dotfiles_path"

    cd "$test_repo_path"
    wt_config_link 2>&1 | grep -q "rm .wt-config"
    set result $status

    cleanup_config_link_test
    echo $result
) -eq 0

@test "config-link: creates symlink when no dotfiles config exists" (
    setup_config_link_test

    # Create local .wt-config
    echo "local_setting=value1" > "$test_repo_path/.wt-config"

    # Override HOME to use test dotfiles
    set -lx HOME "$test_dotfiles_path"

    cd "$test_repo_path"
    wt_config_link >/dev/null 2>&1

    # Check symlink was created
    test -L "$test_repo_path/.wt"
    set result $status

    cleanup_config_link_test
    echo $result
) -eq 0

@test "config-link: creates symlink after removing conflicting local config" (
    setup_config_link_test

    # Create local .wt-config
    echo "local_setting=value1" > "$test_repo_path/.wt-config"

    # Create existing config in dotfiles
    mkdir -p "$test_dotfiles_path/wt/repos/$test_repo_name"
    echo "dotfiles_setting=value2" > "$test_dotfiles_path/wt/repos/$test_repo_name/config"

    # Override HOME to use test dotfiles
    set -lx HOME "$test_dotfiles_path"

    cd "$test_repo_path"

    # First attempt should fail
    wt_config_link 2>/dev/null

    # Remove local config and try again
    rm "$test_repo_path/.wt-config"
    wt_config_link >/dev/null 2>&1

    # Check symlink was created
    test -L "$test_repo_path/.wt"
    set result $status

    cleanup_config_link_test
    echo $result
) -eq 0
