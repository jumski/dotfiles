#!/usr/bin/env fish
# Common utilities and configuration for Worktree Toolkit

# Environment Variables
set -g WT_VERSION "0.1.0"
set -g DEFAULT_CODE_DIR "$HOME/Code"
set -g TMUX_SESSION_PREFIX "wt"
set -g USE_MUXIT "true"
set -g AUTO_PRUNE_DAYS 30
set -g WARN_STALE_WORKTREES "true"

# Verify dependencies
function wt_check_dependencies
    if not command -q jq
        echo "Error: jq is required but not installed. Please install jq." >&2
        return 1
    end

    if not command -q gt
        echo "Error: Graphite CLI (gt) is required but not installed." >&2
        echo "Install with: npm install -g @withgraphite/graphite-cli@stable" >&2
        return 1
    end

    if not command -q git
        echo "Error: git is required but not installed." >&2
        return 1
    end
    
    return 0
end

# Guard clause helper
function _wt_assert
    set -l condition $argv[1]
    set -l error_msg $argv[2..-1]
    
    if not eval $condition
        echo "Error: $error_msg" >&2
        return 1
    end
end

# Get current worktree name
function _wt_get_current_worktree
    set -l current_path (pwd)
    set -l repo_root (_wt_get_repo_root)
    
    if test -z "$repo_root"
        return 1
    end
    
    # Check if we're in a worktree subdirectory
    if string match -q "$repo_root/worktrees/*" $current_path
        # Extract worktree name from path
        set -l worktree_path (string replace "$repo_root/worktrees/" "" $current_path)
        echo (string split "/" $worktree_path)[1]
        return 0
    end
    
    return 1
end

# Get list of worktrees
function _wt_get_worktrees
    set -l repo_root (_wt_get_repo_root)
    if test -z "$repo_root"
        return 1
    end
    
    for dir in $repo_root/worktrees/*
        if test -d $dir
            basename $dir
        end
    end
end

# Get repository config
function _wt_get_repo_config
    set -l config_file ".wt-config"
    
    if not test -f $config_file
        return 1
    end
    
    # Set defaults first
    set -g BARE_PATH ".bare"
    set -g WORKTREES_PATH "worktrees"
    set -g ENVS_PATH "envs"
    set -g DEFAULT_TRUNK "main"
    
    # Parse config file (overrides defaults)
    while read -l line
        # Skip comments and empty lines
        if string match -qr '^[A-Z_]+=.*' $line
            set -l key (string split -m1 '=' $line)[1]
            set -l value (string split -m1 '=' $line)[2]
            set -g $key $value
        end
    end < $config_file
end

# Check if in worktree repository
function _wt_in_worktree_repo
    if test -f .wt-config
        return 0
    end
    
    # Check parent directories
    set -l current_dir (pwd)
    while test "$current_dir" != "/"
        if test -f "$current_dir/.wt-config"
            return 0
        end
        set current_dir (dirname $current_dir)
    end
    
    return 1
end

# Get repository root
function _wt_get_repo_root
    set -l current_dir (pwd)
    while test "$current_dir" != "/"
        if test -f "$current_dir/.wt-config"
            echo $current_dir
            return 0
        end
        set current_dir (dirname $current_dir)
    end
    
    return 1
end

# Get worktree sync status
function _wt_get_worktree_status
    set -l worktree_path $argv[1]
    
    # Check if branch exists on remote
    set -l branch (git -C $worktree_path branch --show-current)
    set -l remote_exists (git -C $worktree_path ls-remote --heads origin $branch 2>/dev/null | count)
    
    if test $remote_exists -eq 0
        echo "✓ local only"
        return
    end
    
    # Fetch latest
    git -C $worktree_path fetch origin $branch --quiet 2>/dev/null
    
    # Check if behind/ahead
    set -l behind (git -C $worktree_path rev-list --count HEAD..origin/$branch 2>/dev/null)
    set -l ahead (git -C $worktree_path rev-list --count origin/$branch..HEAD 2>/dev/null)
    
    if test -z "$behind"
        set behind 0
    end
    if test -z "$ahead"
        set ahead 0
    end
    
    if test $behind -gt 0 -a $ahead -gt 0
        echo "⚠ diverged (↓$behind ↑$ahead)"
    else if test $behind -gt 0
        echo "⚠ behind by $behind commits"
    else if test $ahead -gt 0
        echo "↑ ahead by $ahead commits"
    else
        # Check if needs rebase from parent
        set -l parent (gt -C $worktree_path log --parent 2>/dev/null | head -1)
        if test -n "$parent"
            set -l needs_rebase (git -C $worktree_path rev-list --count $branch..$parent 2>/dev/null)
            if test -n "$needs_rebase" -a $needs_rebase -gt 0
                echo "⚠ needs rebase from $parent"
            else
                echo "✓ up-to-date"
            end
        else
            echo "✓ up-to-date"
        end
    end
end

# Helper to print colored text
function _wt_color
    set -l color $argv[1]
    set -l text $argv[2..-1]
    set_color $color
    echo -n $text
    set_color normal
end

# Helper to print colored text with newline
function _wt_color_line
    set -l color $argv[1]
    set -l text $argv[2..-1]
    set_color $color
    echo $text
    set_color normal
end

# Get git remote origin URL
function _wt_get_remote_origin
    set -l repo_root (_wt_get_repo_root)
    if test -z "$repo_root"
        return 1
    end
    
    set -l bare_path "$repo_root/.bare"
    if test -d "$bare_path"
        git -C $bare_path remote get-url origin 2>/dev/null
    else
        git -C $repo_root remote get-url origin 2>/dev/null
    end
end

# Helper to print a horizontal line
function _wt_line
    set -l width $argv[1]
    set -l char "─"
    echo (string repeat -n $width $char)
end