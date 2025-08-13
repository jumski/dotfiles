#!/usr/bin/env fish
# Initialize new repository with worktree structure

function wt_init
    # Parse arguments
    set -l switch_after false
    set -l repo_url
    set -l repo_name
    
    # Save the original directory
    set -l original_dir (pwd)
    
    for arg in $argv
        switch $arg
            case --switch
                set switch_after true
            case '*'
                if test -z "$repo_url"
                    set repo_url $arg
                else if test -z "$repo_name"
                    set repo_name $arg
                end
        end
    end
    
    _wt_assert "test -n '$repo_url'" "Repository URL required"
    or return 1
    
    # Determine repo path
    set -l repo_path
    set -l repo_dir_name  # Full path for directory structure
    if test -z "$repo_name"
        # No name provided - extract from URL and use DEFAULT_CODE_DIR
        # For org/repo format, keep the full path for directory
        if string match -qr '^[^/]+/[^/]+$' $repo_url
            set repo_dir_name $repo_url
            set repo_name (basename $repo_url)  # Just the repo name for config
        else if string match -qr 'github\.com[:/]([^/]+/[^/]+)(\.git)?$' $repo_url
            # Extract org/repo from GitHub URLs
            set repo_dir_name (string match -r 'github\.com[:/]([^/]+/[^/]+)(\.git)?$' $repo_url)[2]
            set repo_name (basename $repo_dir_name)  # Just the repo name for config
        else if string match -qr 'gitlab\.com[:/]([^/]+/[^/]+)(\.git)?$' $repo_url
            # Extract org/repo from GitLab URLs
            set repo_dir_name (string match -r 'gitlab\.com[:/]([^/]+/[^/]+)(\.git)?$' $repo_url)[2]
            set repo_name (basename $repo_dir_name)  # Just the repo name for config
        else
            # Fallback to just the repo name
            set repo_name (basename $repo_url .git)
            set repo_dir_name $repo_name
        end
        set repo_path "$DEFAULT_CODE_DIR/$repo_dir_name"
    else
        # Name provided - treat as relative path from current directory
        set repo_path (pwd)/$repo_name
        set repo_name (basename $repo_name)  # Extract just the name for config
    end
    
    if test -d $repo_path
        echo "Error: Directory $repo_path already exists" >&2
        return 1
    end
    
    echo "Initializing worktree repository: "(basename $repo_path)
    
    # Create directory structure
    mkdir -p $repo_path
    mkdir -p $repo_path/worktrees
    mkdir -p $repo_path/envs
    
    # Clone as bare repository
    echo "Cloning repository as bare..."
    
    # Check if it's a short format (org/repo) and gh is available
    set -l clone_success false
    if string match -qr '^[^/]+/[^/]+$' $repo_url; and command -q gh
        gh repo clone $repo_url $repo_path/.bare -- --bare
        and set clone_success true
    else
        git clone --bare $repo_url $repo_path/.bare
        and set clone_success true
    end
    
    if test "$clone_success" = "false"
        echo "Error: Failed to clone repository" >&2
        rm -rf $repo_path
        return 1
    end
    
    # Get default branch
    set -l default_branch (git -C $repo_path/.bare symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$default_branch"
        set default_branch "main"
    end
    
    # Create main worktree
    echo "Creating main worktree..."
    git -C $repo_path/.bare worktree add $repo_path/worktrees/$default_branch $default_branch
    or begin
        echo "Error: Failed to create main worktree" >&2
        rm -rf $repo_path
        return 1
    end
    
    # Create config file with defaults commented
    echo "# Worktree repository configuration
REPO_NAME=$repo_name

# Default paths (uncomment to override)
# BARE_PATH=.bare
# WORKTREES_PATH=worktrees
# ENVS_PATH=envs

# Default branch detected from repository
DEFAULT_TRUNK=$default_branch" > $repo_path/.wt-config
    
    # Initialize Graphite in main worktree
    gt -C $repo_path/worktrees/$default_branch init --trunk $default_branch
    or echo "Warning: Failed to initialize Graphite in main worktree" >&2
    
    echo "✓ Repository initialized at $repo_path"
    echo "✓ Main worktree at worktrees/$default_branch"
    echo ""
    echo "Next steps:"
    echo "  cd $repo_path/worktrees/$default_branch"
    echo "  wt new <feature-name>"
    
    # Switch to the main worktree if requested
    if test "$switch_after" = "true"
        echo ""
        echo "Opening main worktree in tmux..."
        # Pass the repo path to wt_switch so it doesn't need to cd
        wt_switch $default_branch $repo_path
    end
end

# Alias for init
function wt_clone
    wt_init $argv
end