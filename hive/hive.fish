#!/usr/bin/env fish
# Hive - Tmux workspace management for agentic coding
# Bootstrap file that sources lib files

# Get the directory where this script is located
set -l hive_dir (dirname (status -f))

# Source library files (utilities that don't autoload)
source $hive_dir/lib/common.fish

# All command functions will be autoloaded from hive/functions/ by Fish
# when the hive command is called (from hive/functions/hive.fish)
