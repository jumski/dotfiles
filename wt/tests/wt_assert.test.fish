#!/usr/bin/env fish

# Source the function to test
source /home/jumski/.dotfiles/wt/lib/common.fish

# Success cases
@test "_wt_assert succeeds on true condition" \
    (_wt_assert "test 1 -eq 1" "should not fail"; echo $status) -eq 0

@test "_wt_assert succeeds on file existence check" \
    (_wt_assert "test -f /home/jumski/.dotfiles/wt/lib/common.fish" "file should exist"; echo $status) -eq 0

@test "_wt_assert succeeds on string comparison" \
    (_wt_assert "test 'foo' = 'foo'" "strings should match"; echo $status) -eq 0

@test "_wt_assert succeeds on non-empty string check" \
    (_wt_assert "test -n 'hello'" "string should not be empty"; echo $status) -eq 0

# Failure cases
@test "_wt_assert fails on false condition" \
    (_wt_assert "test 1 -eq 2" "numbers don't match" 2>&1 >/dev/null; echo $status) -eq 1

@test "_wt_assert fails on non-existent file" \
    (_wt_assert "test -f /nonexistent/file" "file missing" 2>&1 >/dev/null; echo $status) -eq 1

@test "_wt_assert outputs error message on failure" \
    (_wt_assert "test 1 -eq 2" "numbers don't match" 2>&1) = "Error: numbers don't match"

@test "_wt_assert handles multi-word error messages" \
    (_wt_assert "false" "this is a long error message" 2>&1) = "Error: this is a long error message"

@test "_wt_assert returns nothing on success" \
    (_wt_assert "true" "should succeed" 2>&1) = ""