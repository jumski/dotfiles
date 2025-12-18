#!/usr/bin/env fish

# Test vmw_extract_name function - extracts VM name from worktree path

set -l functions_dir (dirname (status filename))/../functions
source $functions_dir/vmw_extract_name.fish

@test "extracts dirname from full path" (
    vmw_extract_name "/home/jumski/Code/pgflow-dev/pgflow/worktrees/flow-refactor"
) = "flow-refactor"

@test "extracts dirname from path with trailing slash" (
    vmw_extract_name "/home/jumski/Code/pgflow-dev/pgflow/worktrees/flow-refactor/"
) = "flow-refactor"

@test "extracts dirname from simple path" (
    vmw_extract_name "/tmp/my-worktree"
) = "my-worktree"

@test "handles path with spaces" (
    vmw_extract_name "/home/jumski/Code/my project/worktrees/feature-1"
) = "feature-1"

@test "fails on empty path" (
    vmw_extract_name ""
    echo $status
) -eq 1

@test "sanitizes name with dots to dashes" (
    vmw_extract_name "/path/to/my.feature.branch"
) = "my-feature-branch"

@test "sanitizes name with underscores to dashes" (
    vmw_extract_name "/path/to/my_feature_branch"
) = "my-feature-branch"
