#!/usr/bin/env fish
# Tests for wt new argument parsing

# Note: These are basic syntax tests. Full integration tests would require
# a git repository setup with worktrees, which is beyond unit test scope.

source /home/jumski/.dotfiles/wt/functions/wt_new.fish
source /home/jumski/.dotfiles/wt/lib/common.fish

# Test help output
@test "wt new shows help with --help" \
    (wt_new --help 2>&1 | grep -q "Usage: wt new") -eq 0

@test "wt new help mentions two-arg syntax" \
    (wt_new --help 2>&1 | grep -q "worktree-name.*branch-name") -eq 0

@test "wt new help shows examples" \
    (wt_new --help 2>&1 | grep -q "Examples:") -eq 0
