# Minimal, beautiful dashboard
function wt_dashboard
    _wt_assert "_wt_in_worktree_repo" "Not in a worktree repository"
    or return 1
    
    set -l repo_root (_wt_get_repo_root)
    cd $repo_root
    _wt_get_repo_config
    
    # Get current worktree
    set -l current_dir (realpath (pwd))
    set -l current_worktree ""
    set -l worktrees_dir (realpath "$repo_root/$WORKTREES_PATH")
    
    if string match -q "$worktrees_dir/*" $current_dir
        set current_worktree (string replace "$worktrees_dir/" "" $current_dir | string split "/" | head -1)
    end
    
    echo ""
    
    # Repository name - subtle and elegant
    set_color brblack
    echo -n "  "
    set_color bryellow
    echo -n "$REPO_NAME"
    set_color brblack
    echo " repository"
    set_color normal
    
    echo ""
    
    # Worktrees - clean list
    set -l worktrees (_wt_get_worktrees)
    for wt in $worktrees
        echo -n "  "
        
        # Current indicator - subtle
        if test "$wt" = "$current_worktree"
            set_color brwhite
            echo -n "• "
        else
            set_color brblack
            echo -n "  "
        end
        
        # Worktree name
        if test "$wt" = "$current_worktree"
            set_color white
        else
            set_color brwhite
        end
        echo -n "$wt"
        
        # Branch - very subtle
        set_color brblack
        if test -d "$repo_root/$WORKTREES_PATH/$wt"
            set -l branch (git -C "$repo_root/$WORKTREES_PATH/$wt" branch --show-current 2>/dev/null)
            if test -n "$branch" -a "$branch" != "$wt"
                echo -n "  $branch"
            end
        end
        
        # Stack info if exists
        if test -d "$repo_root/$WORKTREES_PATH/$wt"
            set -l stack (gt -C "$repo_root/$WORKTREES_PATH/$wt" stack 2>/dev/null | string match -r "on stack '(.*)'" | string replace -r ".*'(.*)'" '$1')
            if test -n "$stack"
                set_color brblack
                echo -n "  ↳ $stack"
            end
        end
        
        echo
    end
    
    echo ""
    
    # Quick commands - minimal, two columns
    set_color brwhite
    echo -n "  new"
    set_color brblack
    echo -n " <name>     "
    set_color brwhite
    echo -n "switch"
    set_color brblack
    echo " (fzf)    "
    
    set_color brwhite
    echo -n "  list"
    set_color brblack
    echo -n "           "
    set_color brwhite
    echo -n "status"
    set_color brblack
    echo " --all"
    
    set_color brwhite
    echo -n "  up"
    set_color brblack
    echo -n "/down       "
    set_color brwhite
    echo -n "sync"
    set_color brblack
    echo " --all"
    
    set_color normal
    echo ""
end