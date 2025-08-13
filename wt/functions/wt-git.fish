#!/usr/bin/env fish
# Git wrapper for bare repository operations

function wt_git
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