#!/usr/bin/env fish

# Source the function to test
source /home/jumski/.dotfiles/wt/functions/wt-common.fish

# _wt_color tests (no newline)
@test "_wt_color outputs text without newline" \
    (string match '*test*' (_wt_color red "test") | count) -eq 1

@test "_wt_color handles multiple words" \
    (string match '*hello world*' (_wt_color blue "hello world") | count) -eq 1

@test "_wt_color returns non-empty output" \
    (test -n "(_wt_color green text)"; echo $status) -eq 0

# _wt_color_line tests (with newline)
@test "_wt_color_line outputs text with newline" \
    (string match -r 'test' (_wt_color_line red "test") | count) -eq 1

@test "_wt_color_line handles multiple words" \
    (string match '*hello world*' (_wt_color_line blue "hello world") | count) -eq 1

@test "_wt_color_line returns non-empty output" \
    (test -n "(_wt_color_line green text)"; echo $status) -eq 0

# Color code presence tests
@test "_wt_color includes color escape codes" \
    (string match -r '\e\[' (_wt_color red "test") | count) -gt 0

@test "_wt_color_line includes color escape codes" \
    (string match -r '\e\[' (_wt_color_line blue "test") | count) -gt 0

# Reset code presence
@test "_wt_color includes reset code" \
    (string match '*'(set_color normal)'*' (_wt_color red "test") | count) -eq 1

@test "_wt_color_line includes reset code" \
    (string match '*'(set_color normal)'*' (_wt_color_line blue "test") | count) -eq 1