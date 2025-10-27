#!/usr/bin/env fish
# Git wrapper for bare repository operations

function wt_git
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt git <git-command> [args...]

Git wrapper for bare repository operations

Arguments:
  <git-command>  Any git command to run in the bare repository
  [args...]      Arguments to pass to git

Examples:
  wt git branch -a            # List all branches
  wt git fetch --all          # Fetch from all remotes
  wt git remote -v            # Show remotes"
    and return 0

    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    set -l repo_root (_wt_get_repo_root)
    set -l saved_pwd (pwd)
    cd $repo_root
    _wt_get_repo_config
    cd $saved_pwd
    
    # Pass all arguments to git in the bare repo
    git -C "$repo_root/$BARE_PATH" $argv
end