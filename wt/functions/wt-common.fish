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

# Generate tmux session name for a worktree
# Usage: _wt_get_session_name <worktree_name> <repo_name>
# Returns sanitized session name in format: worktree@repo
function _wt_get_session_name
    set -l worktree_name $argv[1]
    set -l repo_name $argv[2]

    if test -z "$worktree_name"
        echo "Error: worktree name required" >&2
        return 1
    end

    if test -z "$repo_name"
        echo "Error: repo name required" >&2
        return 1
    end

    # Create session name in format: worktree@repo
    set -l session_name "$worktree_name@$repo_name"

    # Sanitize: keep only alphanumeric, hyphens, underscores, and @ symbol
    echo $session_name | tr -cd '[:alnum:]-_@'
end

# Parse repository URL to extract organization/user and repository name
# Usage: _wt_parse_repo_url <url>
# Returns two lines:
#   1. repo_dir_name (e.g., "supabase/smart-office-demo")
#   2. repo_name (e.g., "smart-office-demo")
function _wt_parse_repo_url
    set -l repo_url $argv[1]
    set -l repo_dir_name
    set -l repo_name

    if test -z "$repo_url"
        echo "Error: Repository URL required" >&2
        return 1
    end

    # Handle org/repo short format (e.g., supabase/smart-office-demo)
    # Must not contain : or @ to avoid matching full URLs
    if string match -qr '^[^/:@]+/[^/:@]+$' $repo_url
        set repo_dir_name $repo_url
        set repo_name (basename $repo_url)

    # Handle GitHub SSH URLs (git@github.com:org/repo.git)
    else if string match -qr 'git@github\.com:([^/]+)/(.+)' $repo_url
        set -l matches (string match -r 'git@github\.com:([^/]+)/(.+)' $repo_url)
        set -l org_name $matches[2]
        set -l project_name (string replace -r '\.git$' '' $matches[3])
        set repo_dir_name "$org_name/$project_name"
        set repo_name $project_name

    # Handle GitHub HTTPS URLs (https://github.com/org/repo.git)
    else if string match -qr 'https?://github\.com/([^/]+)/(.+)' $repo_url
        set -l matches (string match -r 'https?://github\.com/([^/]+)/(.+)' $repo_url)
        set -l org_name $matches[2]
        set -l project_name (string replace -r '\.git$' '' $matches[3])
        set repo_dir_name "$org_name/$project_name"
        set repo_name $project_name

    # Handle GitLab SSH URLs (git@gitlab.com:org/repo.git)
    else if string match -qr 'git@gitlab\.com:(.+)' $repo_url
        set -l matches (string match -r 'git@gitlab\.com:(.+)' $repo_url)
        set -l full_path (string replace -r '\.git$' '' $matches[2])
        set repo_dir_name $full_path
        set repo_name (basename $full_path)

    # Handle GitLab HTTPS URLs
    else if string match -qr 'https?://gitlab\.com/(.+)' $repo_url
        set -l matches (string match -r 'https?://gitlab\.com/(.+)' $repo_url)
        set -l full_path (string replace -r '\.git$' '' $matches[2])
        set repo_dir_name $full_path
        set repo_name (basename $full_path)

    # Fallback: just use the basename
    else
        set repo_name (basename $repo_url .git)
        set repo_dir_name $repo_name
    end

    # Return both values
    echo $repo_dir_name
    echo $repo_name
end

# Configure remote fetch refspec for bare repository
# This is needed because git clone --bare doesn't set up remote tracking
# Usage: _wt_configure_remote_fetch <bare_repo_path> [remote_name]
function _wt_configure_remote_fetch
    set -l bare_path $argv[1]
    set -l remote_name $argv[2]

    if test -z "$bare_path"
        echo "Error: bare repository path required" >&2
        return 1
    end

    if test -z "$remote_name"
        set remote_name "origin"
    end

    if not test -d "$bare_path"
        echo "Error: $bare_path is not a directory" >&2
        return 1
    end

    # Configure fetch refspec for the remote
    git -C $bare_path config remote.$remote_name.fetch "+refs/heads/*:refs/remotes/$remote_name/*"
    return $status
end

# Reusable confirmation function with proper input handling
# Flags:
#   --prompt "text"     Question text (auto-adds ? and [y/N])
#   --default-yes       Shows [Y/n] and defaults to yes
#   --yes, --force      Auto-confirm without prompting (shows grayed ✓)
function _wt_confirm
    set -l prompt_text "Confirm"
    set -l default_response "N"
    set -l auto_confirm false

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --prompt
                set i (math $i + 1)
                if test $i -le (count $argv)
                    set prompt_text $argv[$i]
                end
            case --default-yes
                set default_response "Y"
            case --default-no
                set default_response "N"
            case --yes --force
                set auto_confirm true
        end
        set i (math $i + 1)
    end

    # Handle auto-confirm
    if test $auto_confirm = true
        echo -e "\033[90m✓ $prompt_text\033[0m"
        return 0
    end

    # Format prompt: add ? if needed
    set -l last_char (string sub -s -1 "$prompt_text")
    if not string match -qr '[?!.]' "$last_char"
        set prompt_text "$prompt_text?"
    end

    # Add [y/N] or [Y/n] indicator
    if test $default_response = "Y"
        set prompt_text "$prompt_text [Y/n]"
    else
        set prompt_text "$prompt_text [y/N]"
    end

    # Show prompt and read response using fish's built-in prompt
    read -l -P "$prompt_text: " response
    set -l read_status $status

    # Handle Ctrl-C interruption
    if test $read_status -ne 0
        echo
        return 1
    end

    # Handle empty response (use default)
    if test -z "$response"
        set response $default_response
    end

    # Check response
    switch (string lower $response)
        case y yes 1 true
            return 0
        case '*'
            return 1
    end
end