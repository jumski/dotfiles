#!/usr/bin/env fish

# Source the function to test
source /home/jumski/.dotfiles/wt/lib/common.fish

# Basic functionality
@test "generates correct session name format" \
    (_wt_get_session_name "feature-branch" "my-repo") = "feature-branch@my-repo"

@test "preserves hyphens in names" \
    (_wt_get_session_name "my-feature" "my-repo") = "my-feature@my-repo"

@test "preserves underscores in names" \
    (_wt_get_session_name "my_feature" "my_repo") = "my_feature@my_repo"

@test "preserves alphanumeric characters" \
    (_wt_get_session_name "feature123" "repo456") = "feature123@repo456"

# Sanitization
@test "removes spaces from session names" \
    (_wt_get_session_name "feature branch" "my repo") = "featurebranch@myrepo"

@test "removes special characters" \
    (_wt_get_session_name "feature!branch" "my#repo") = "featurebranch@myrepo"

@test "removes dots" \
    (_wt_get_session_name "feature.branch" "my.repo") = "featurebranch@myrepo"

@test "removes slashes" \
    (_wt_get_session_name "feature/branch" "my/repo") = "featurebranch@myrepo"

# Error handling
@test "returns error for missing worktree name" \
    (_wt_get_session_name "" "repo"; echo $status) -eq 1

@test "returns error for missing repo name" \
    (_wt_get_session_name "worktree" ""; echo $status) -eq 1

@test "returns error for no arguments" \
    (_wt_get_session_name; echo $status) -eq 1