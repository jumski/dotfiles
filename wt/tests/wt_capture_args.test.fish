#!/usr/bin/env fish
# Tests for wt capture argument parsing

# Note: These are basic syntax tests. Full integration tests would require
# a git repository setup with Graphite, which is beyond unit test scope.

source /home/jumski/.dotfiles/wt/functions/wt_capture.fish
source /home/jumski/.dotfiles/wt/lib/common.fish

# Test help output
@test "wt capture shows help with --help" \
    (wt_capture --help 2>&1 | grep -q "Usage: wt capture"; echo $status) -eq 0

@test "wt capture help mentions Graphite requirement" \
    (wt_capture --help 2>&1 | grep -q "Graphite"; echo $status) -eq 0

@test "wt capture help shows --force option" \
    (wt_capture --help 2>&1 | grep -q "\--force"; echo $status) -eq 0

@test "wt capture help shows examples" \
    (wt_capture --help 2>&1 | grep -q "Examples:"; echo $status) -eq 0
