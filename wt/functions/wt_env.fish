#!/usr/bin/env fish
# Environment file operations

function wt_env
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt env sync [options]

Sync environment files from repo_root/envs/ to worktrees

Options:
  --all          Sync to all worktrees
  --to <name>    Target worktree (default: current, or --all if outside worktree)
  --yes          Skip confirmation prompt

Examples:
  wt env sync                  # Copy envs/ to current worktree
  wt env sync --all            # Copy envs/ to all worktrees
  wt env sync --to prod        # Copy envs/ to prod worktree

Note: This will overwrite existing files in the target worktree(s)!"
    and return 0

    set -l subcommand ""
    if test (count $argv) -ge 1
        set subcommand $argv[1]
    end

    set -l remaining_args
    if test (count $argv) -gt 1
        set remaining_args $argv[2..-1]
    end

    switch $subcommand
        case sync
            _wt_env_sync $remaining_args
        case '*'
            echo "Usage: wt env sync [options]"
            echo ""
            echo "Sync environment files from repo_root/envs/ to worktrees"
            echo ""
            echo "Options:"
            echo "  --all          Sync to all worktrees"
            echo "  --to <name>    Target worktree (default: current, or --all if outside worktree)"
            echo "  --yes          Skip confirmation prompt"
            echo ""
            echo "Examples:"
            echo "  wt env sync                  # Copy envs/ to current worktree"
            echo "  wt env sync --all            # Copy envs/ to all worktrees"
            echo "  wt env sync --to prod        # Copy envs/ to prod worktree"
            echo ""
            echo "Note: This will overwrite existing files in the target worktree(s)!"
            return 1
    end
end
