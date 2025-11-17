#!/usr/bin/env fish

# Tests for legacy format detection and enforcement

# Source the common library
source ~/.dotfiles/wt/lib/common.fish

# Setup and teardown helpers
function setup_test_repo
    set -g test_repo_path (mktemp -d)
    mkdir -p "$test_repo_path/.bare"
    mkdir -p "$test_repo_path/worktrees"
end

function cleanup_test_repo
    if test -n "$test_repo_path" -a -d "$test_repo_path"
        rm -rf "$test_repo_path"
    end
end

@test "legacy detection: returns success when no config exists" (
    setup_test_repo
    cd "$test_repo_path"
    _wt_check_legacy_format
    set result $status
    cleanup_test_repo
    echo $result
) -eq 0

@test "legacy detection: returns success when new format exists" (
    setup_test_repo
    cd "$test_repo_path"
    mkdir -p .wt
    touch .wt/config
    _wt_check_legacy_format
    set result $status
    cleanup_test_repo
    echo $result
) -eq 0

@test "legacy detection: fails when .wt-config exists without .wt/" (
    setup_test_repo
    cd "$test_repo_path"
    touch .wt-config
    _wt_check_legacy_format 2>/dev/null
    set result $status
    cleanup_test_repo
    echo $result
) -eq 1

@test "legacy detection: fails when .wt-post-create exists with .wt-config but no .wt/" (
    setup_test_repo
    cd "$test_repo_path"
    touch .wt-config
    touch .wt-post-create
    _wt_check_legacy_format 2>/dev/null
    set result $status
    cleanup_test_repo
    echo $result
) -eq 1

@test "legacy detection: returns success when legacy files exist but .wt/ symlink also exists" (
    setup_test_repo
    cd "$test_repo_path"
    touch .wt-config
    mkdir -p /tmp/wt-test-target
    ln -s /tmp/wt-test-target .wt
    _wt_check_legacy_format
    set result $status
    rm -rf /tmp/wt-test-target
    cleanup_test_repo
    echo $result
) -eq 0
