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

    _wt_action "Reloading wt..."

    # Source lib files first (common utilities and tutor)
    source $wt_dir/lib/common.fish
    or begin
        echo -e "\033[31m✗\033[0m Failed to reload lib/common.fish" >&2
        return 1
    end

    source $wt_dir/lib/tutor.fish
    or begin
        echo -e "\033[31m✗\033[0m Failed to reload lib/tutor.fish" >&2
        return 1
    end

    # Explicitly reload all function files (don't rely on autoloading)
    for func_file in $wt_dir/functions/*.fish
        source $func_file
        or begin
            echo -e "\033[31m✗\033[0m Failed to reload $(basename $func_file)" >&2
            return 1
        end
    end

    # Source completions
    source $wt_dir/completions.fish
    or begin
        echo -e "\033[31m✗\033[0m Failed to reload completions.fish" >&2
        return 1
    end

    _wt_success "Worktree Toolkit reloaded successfully!"
end
