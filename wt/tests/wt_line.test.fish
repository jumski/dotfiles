#!/usr/bin/env fish

# Source the function to test
source /home/jumski/.dotfiles/wt/lib/common.fish

# Basic functionality
@test "_wt_line creates line of correct length" \
    (string length (_wt_line 10)) -eq 10

@test "_wt_line creates line of 1 character" \
    (string length (_wt_line 1)) -eq 1

@test "_wt_line creates line of 50 characters" \
    (string length (_wt_line 50)) -eq 50

@test "_wt_line uses box drawing character" \
    (_wt_line 5) = "─────"

@test "_wt_line creates correct pattern" \
    (_wt_line 3) = "───"

# Different lengths
@test "_wt_line handles zero width" \
    (_wt_line 0) = ""

@test "_wt_line handles large width" \
    (string length (_wt_line 100)) -eq 100

# Character verification
@test "_wt_line uses consistent character" \
    (string match -r '^─+$' (_wt_line 20) | count) -eq 1

@test "_wt_line contains only box drawing chars" \
    (string replace -a "─" "" (_wt_line 10)) = ""