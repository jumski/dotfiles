#!/usr/bin/env fish
# Dashboard display

function wt_dashboard
    # Check if we're in a wt repository, but don't fail if not
    set -l in_wt_repo false
    if _wt_in_worktree_repo 2>/dev/null
        set in_wt_repo true
    end
    
    echo ""
    
    # Title
    set_color brblack
    echo -n "  "
    set_color bryellow
    echo -n "wt"
    set_color white
    echo " - worktree toolkit for graphite"
    set_color normal
    
    echo ""
    
    # Configuration context
    if test "$in_wt_repo" = "true"
        set -l repo_root (_wt_get_repo_root)
        set -l saved_pwd (pwd)
        cd $repo_root
        
        # Check for config file
        if test -f .wt-config
            # Load config to show key info
            _wt_get_repo_config
            
            # Show repository name and origin
            set_color brwhite
            echo -n "  repository: "
            set_color bryellow
            echo "$REPO_NAME"
            
            # Get and show remote origin
            set -l origin (_wt_get_remote_origin)
            if test -n "$origin"
                set_color brwhite
                echo -n "  origin: "
                set_color brblue
                echo "$origin"
            end
            
            echo ""
            
            # Show repository path and structure
            set_color brwhite
            echo "$repo_root/"
            
            set_color brblack
            echo -n "  ├─ "
            set_color brwhite
            echo ".wt-config"
            
            set_color brblack
            echo -n "  ├─ "
            set_color normal
            echo -n ".bare/"
            set_color brblack
            echo " (git bare repository)"
            
            set_color brblack
            echo -n "  ├─ "
            set_color normal
            echo -n "worktrees/"
            set_color brblack
            echo " (feature branches)"
            
            # List all worktrees
            set -l worktrees (_wt_get_worktrees)
            set -l current_worktree (_wt_get_current_worktree)
            set -l worktree_count (count $worktrees)
            
            if test $worktree_count -gt 0
                set -l index 0
                for worktree in $worktrees
                    set index (math $index + 1)
                    set_color brblack
                    
                    # Use └─ for last item, ├─ for others
                    if test $index -eq $worktree_count
                        echo -n "  │  └─ "
                    else
                        echo -n "  │  ├─ "
                    end
                    
                    # Highlight current worktree
                    if test "$worktree" = "$current_worktree"
                        set_color brwhite
                        echo -n "$worktree/"
                        set_color brgreen
                        echo " ← current"
                    else
                        set_color normal
                        echo "$worktree/"
                    end
                end
            end
            
            set_color brblack
            echo -n "  └─ "
            set_color normal
            echo -n "envs/"
            set_color brblack
            echo " (environment files)"
        else
            set_color brred
            echo "  no .wt-config found"
            set_color brblack
            echo "  └─ commands will use current directory"
        end
        
        cd $saved_pwd
    else
        set_color bryellow
        echo "detached mode"
        set_color brblack
        echo "  └─ not in a wt repository"
    end
    set_color normal
    
    echo ""
    
    # Core Commands section
    set_color white
    echo "  core commands"
    set_color normal
    
    # init/clone
    echo -n "    "
    set_color cyan
    printf "%-12s" "init"
    set_color normal
    echo "initialize new repository with worktree structure"
    
    echo -n "    "
    set_color cyan
    printf "%-12s" "new"
    set_color normal
    echo "create new worktree for a feature branch"
    
    echo -n "    "
    set_color cyan
    printf "%-12s" "branch"
    set_color normal
    echo "create new branch with worktree"
    
    echo -n "    "
    set_color cyan
    printf "%-12s" "switch"
    set_color normal
    echo "switch to another worktree using muxit/tmux"
    
    echo -n "    "
    set_color cyan
    printf "%-12s" "remove"
    set_color normal
    echo "remove worktree (auto-detects current if no name)"
    
    echo ""
    
    # Stack Commands section
    set_color white
    echo "  stack navigation"
    set_color normal
    
    echo -n "    "
    set_color cyan
    printf "%-12s" "up"
    set_color normal
    echo "move up the stack to parent branch"
    
    echo -n "    "
    set_color cyan
    printf "%-12s" "down"
    set_color normal
    echo "move down the stack to child branch"
    
    echo -n "    "
    set_color cyan
    printf "%-12s" "bottom"
    set_color normal
    echo "move to bottom of current stack"
    
    echo ""
    
    # Sync Commands section
    set_color white
    echo "  synchronization"
    set_color normal

    echo -n "    "
    set_color cyan
    printf "%-12s" "sync-all"
    set_color normal
    echo "sync all worktrees with upstream"

    echo ""
    
    # Info Commands section
    set_color white
    echo "  information"
    set_color normal
    
    echo -n "    "
    set_color cyan
    printf "%-12s" "list"
    set_color normal
    echo "list all worktrees"
    
    echo -n "    "
    set_color cyan
    printf "%-12s" "status"
    set_color normal
    echo "show status of current or all worktrees"
    
    echo ""
    
    # Quick usage hint
    set_color white
    echo -n "  "
    echo "tip: use 'wt help' for detailed command options"
    set_color normal
    
    echo ""
end