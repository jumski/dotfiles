#!/usr/bin/env fish
# Clone existing repository with worktree structure

function wt_clone
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt clone <repo-url> [repo-name] [--switch]

Clone existing repository with worktree structure

Arguments:
  <repo-url>     Git repository URL or short format (org/repo)
  [repo-name]    Optional: custom repository name or path

Options:
  --switch       Automatically switch to the main worktree after cloning"
    and return 0

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
        set -l parsed (_wt_parse_repo_url $repo_url)
        if test $status -ne 0
            echo "Error: Failed to parse repository URL" >&2
            return 1
        end
        set repo_dir_name $parsed[1]
        set repo_name $parsed[2]
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
    
    echo -e "\033[34m→\033[0m Initializing worktree repository: "(basename $repo_path)
    
    # Create directory structure
    echo -e "\033[34m→\033[0m Creating directory structure..."
    mkdir -p $repo_path
    mkdir -p $repo_path/worktrees
    mkdir -p $repo_path/envs
    
    # Clone as bare repository
    echo -e "\033[34m→\033[0m Cloning repository as bare..."
    
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

    # Configure remote fetch refspec for bare repository
    echo -e "\033[34m→\033[0m Configuring remote fetch refspec..."
    _wt_configure_remote_fetch $repo_path/.bare origin
    or begin
        echo "Warning: Failed to configure remote fetch refspec" >&2
    end

    # Get default branch
    set -l default_branch (git -C $repo_path/.bare symbolic-ref --short HEAD 2>/dev/null)
    if test -z "$default_branch"
        set default_branch "main"
    end
    
    # Create main worktree
    echo -e "\033[34m→\033[0m Creating main worktree..."
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
    
    # Create empty post-creation hook script
    echo "#!/bin/bash
# Post-creation hook for new worktrees
# This script runs in the new worktree directory after creation
# Add commands like: pnpm install, npm install, etc.

echo \"Post-creation hook executed in: \$(pwd)\"
# Add your setup commands here" > $repo_path/.wt-post-create
    
    # Make hook script executable
    chmod +x $repo_path/.wt-post-create
    
    # Initialize Graphite in main worktree
    echo -e "\033[34m→\033[0m Initializing Graphite in main worktree..."
    pushd $repo_path/worktrees/$default_branch
    gt init --trunk $default_branch
    or echo "Warning: Failed to initialize Graphite in main worktree" >&2
    popd
    
    echo -e "\033[32m✓\033[0m Repository initialized at $repo_path"
    echo -e "\033[32m✓\033[0m Main worktree at worktrees/$default_branch"
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

