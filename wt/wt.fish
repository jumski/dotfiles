#!/usr/bin/env fish
# Worktree Toolkit - Bootstrap file that sources lib files

# Get the directory where this script is located
set -l wt_dir (dirname (status -f))

# Source library files first (utilities that don't autoload)
source $wt_dir/lib/common.fish
source $wt_dir/lib/tutor.fish

# All command functions will be autoloaded from wt/functions/ by Fish
# when the wt command is called (from wt/functions/wt.fish)
