#!/usr/bin/env fish
# Reload wt functions and completions

function wt_reload
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt reload

Reload wt functions and completions

This is useful when you've made changes to wt code and want to reload it
without restarting your shell."
    and return 0

    # Get the directory where wt is installed
    set -l wt_dir (dirname (status -f))/../

    echo -e "\033[34m→\033[0m Reloading wt..."

    # Source main wt.fish (which sources all functions)
    source $wt_dir/wt.fish
    or begin
        echo -e "\033[31m✗\033[0m Failed to reload wt.fish" >&2
        return 1
    end

    # Source completions
    source $wt_dir/completions.fish
    or begin
        echo -e "\033[31m✗\033[0m Failed to reload completions.fish" >&2
        return 1
    end

    echo -e "\033[32m✓\033[0m Worktree Toolkit reloaded successfully!"
end
