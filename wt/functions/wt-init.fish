#!/usr/bin/env fish
# Initialize new repository with worktree structure

function wt_init
    set -l repo_url $argv[1]
    set -l repo_name $argv[2]
    
    _wt_assert "test -n '$repo_url'" "Repository URL required"
    or return 1
    
    # Extract repo name if not provided
    set -l repo_path
    if test -z "$repo_name"
        set repo_name (basename $repo_url .git)
        # Use DEFAULT_CODE_DIR when no explicit name given
        set repo_path "$DEFAULT_CODE_DIR/$repo_name"
    else
        # Use current directory when name is provided
        set repo_path (pwd)/$repo_name
    end
    
    if test -d $repo_path
        echo "Error: Directory $repo_path already exists" >&2
        return 1
    end
    
    echo "Initializing worktree repository: $repo_name"
    
    # Create directory structure
    mkdir -p $repo_path
    cd $repo_path
    
    # Clone as bare repository
    echo "Cloning repository as bare..."
    
    # Check if it's a short format (org/repo) and gh is available
    set -l clone_success false
    if string match -qr '^[^/]+/[^/]+$' $repo_url; and command -q gh
        gh repo clone $repo_url .bare -- --bare
        and set clone_success true
    else
        git clone --bare $repo_url .bare
        and set clone_success true
    end
    
    if test "$clone_success" = "false"
        echo "Error: Failed to clone repository" >&2
        cd -
        rm -rf $repo_path
        return 1
    end
    
    # Create worktrees directory
    mkdir -p worktrees
    
    # Get default branch
    set -l default_branch (git -C .bare symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$default_branch"
        set default_branch "main"
    end
    
    # Create main worktree
    echo "Creating main worktree..."
    git -C .bare worktree add ../worktrees/$default_branch $default_branch
    or begin
        echo "Error: Failed to create main worktree" >&2
        return 1
    end
    
    # Create envs directory
    mkdir -p envs
    
    # Create config file with defaults commented
    echo "# Worktree repository configuration
REPO_NAME=$repo_name

# Default paths (uncomment to override)
# BARE_PATH=.bare
# WORKTREES_PATH=worktrees
# ENVS_PATH=envs

# Default branch detected from repository
DEFAULT_TRUNK=$default_branch" > .wt-config
    
    # Initialize Graphite in main worktree
    cd worktrees/$default_branch
    gt init --trunk $default_branch
    
    echo "✓ Repository initialized at $repo_path"
    echo "✓ Main worktree at worktrees/$default_branch"
    echo ""
    echo "Next steps:"
    echo "  cd $repo_path/worktrees/$default_branch"
    echo "  wt new <feature-name>"
end

# Alias for init
function wt_clone
    wt_init $argv
end