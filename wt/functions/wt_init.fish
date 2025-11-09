#!/usr/bin/env fish
# Initialize new local repository with worktree structure

function wt_init
    # Show help if requested
    _wt_show_help_if_requested $argv "Usage: wt init <repo-name> [--switch]

Initialize new local repository with worktree structure

Arguments:
  <repo-name>    Repository name or path

Options:
  --switch       Automatically switch to the main worktree after creation"
    and return 0

    # Parse arguments
    set -l switch_after false
    set -l repo_name
    
    # Save the original directory
    set -l original_dir (pwd)
    
    for arg in $argv
        switch $arg
            case --switch
                set switch_after true
            case '*'
                if test -z "$repo_name"
                    set repo_name $arg
                end
        end
    end
    
    _wt_assert "test -n '$repo_name'" "Repository name required"
    or return 1
    
    # Determine repo path
    set -l repo_path
    
    # Handle absolute paths, relative paths, and simple names
    if string match -q '/*' $repo_name
        # Absolute path - use as-is
        set repo_path $repo_name
        set repo_name (basename $repo_name)  # Extract just the name for config
    else if string match -q '*/*' $repo_name
        # Contains slash but not absolute - treat as relative path
        set repo_path (pwd)/$repo_name
        set repo_name (basename $repo_name)  # Extract just the name for config
    else
        # No path specified - use DEFAULT_CODE_DIR
        set repo_path "$DEFAULT_CODE_DIR/$repo_name"
    end
    
    if test -d $repo_path
        echo "Error: Directory $repo_path already exists" >&2
        return 1
    end
    
    # Show confirmation screen
    echo ""
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[1;37m  Initialize New Worktree Repository\033[0m"
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo -e "  \033[1;33mRepository Name:\033[0m  $repo_name"
    echo -e "  \033[1;33mLocation:\033[0m        $repo_path"
    echo ""
    echo -e "  \033[1;37mThis will create:\033[0m"
    echo -e "    \033[36m$repo_path/\033[0m"
    echo -e "    \033[90m├──\033[0m \033[32m.bare/\033[0m              \033[90m(bare git repository)\033[0m"
    echo -e "    \033[90m├──\033[0m \033[32mworktrees/\033[0m"
    echo -e "    \033[90m│   └──\033[0m \033[32mmain/\033[0m          \033[90m(initial worktree)\033[0m"
    echo -e "    \033[90m├──\033[0m \033[32menvs/\033[0m              \033[90m(environment files)\033[0m"
    echo -e "    \033[90m├──\033[0m \033[33m.wt-config\033[0m        \033[90m(configuration)\033[0m"
    echo -e "    \033[90m└──\033[0m \033[33m.wt-post-create\033[0m   \033[90m(hook script)\033[0m"
    echo ""
    echo -e "  \033[1;37mActions to perform:\033[0m"
    echo -e "    \033[32m✓\033[0m Initialize bare Git repository"
    echo -e "    \033[32m✓\033[0m Create main branch with initial commit"
    echo -e "    \033[32m✓\033[0m Set up Graphite for stacked PRs"
    if test "$switch_after" = "true"
        echo -e "    \033[32m✓\033[0m Open in tmux/muxit after creation"
    end
    echo ""
    echo -e "\033[1;36m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""

    # Prompt for confirmation
    if not _wt_confirm --prompt "Proceed with initialization"
        echo -e "\033[31m✗\033[0m Initialization cancelled"
        return 1
    end

    echo ""
    echo -e "\033[34m→\033[0m Initializing new worktree repository: "(basename $repo_path)
    
    # Create directory structure
    echo -e "\033[34m→\033[0m Creating directory structure..."
    mkdir -p $repo_path
    mkdir -p $repo_path/worktrees
    mkdir -p $repo_path/envs
    
    # Initialize bare repository
    echo -e "\033[34m→\033[0m Initializing bare repository..."
    git init --bare $repo_path/.bare
    or begin
        echo "Error: Failed to initialize bare repository" >&2
        rm -rf $repo_path
        return 1
    end
    
    # Set default branch to main
    echo -e "\033[34m→\033[0m Setting default branch to main..."
    git -C $repo_path/.bare symbolic-ref HEAD refs/heads/main
    
    # Create main worktree
    echo -e "\033[34m→\033[0m Creating main worktree..."
    git -C $repo_path/.bare worktree add $repo_path/worktrees/main
    or begin
        echo "Error: Failed to create main worktree" >&2
        rm -rf $repo_path
        return 1
    end
    
    # Create initial empty commit
    echo -e "\033[34m→\033[0m Creating initial commit..."
    pushd $repo_path/worktrees/main
    git commit --allow-empty -m "Initial commit"
    or begin
        echo "Error: Failed to create initial commit" >&2
        popd
        rm -rf $repo_path
        return 1
    end
    popd
    
    # Create config file with defaults commented
    echo "# Worktree repository configuration
REPO_NAME=$repo_name

# Default paths (uncomment to override)
# BARE_PATH=.bare
# WORKTREES_PATH=worktrees
# ENVS_PATH=envs

# Default branch
DEFAULT_TRUNK=main" > $repo_path/.wt-config
    
    # Create empty post-creation hook script
    echo "#!/bin/bash
# Post-creation hook for new worktrees
# This script runs in the new worktree directory after creation
# Add commands like: pnpm install, npm install, etc.

echo \"Post-creation hook executed in: \$(pwd)\"
# Add your setup commands here" > $repo_path/.wt-post-create
    
    # Make hook script executable
    chmod +x $repo_path/.wt-post-create

    echo -e "\033[32m✓\033[0m Repository initialized at $repo_path"
    echo -e "\033[32m✓\033[0m Main worktree at worktrees/main"
    echo ""
    echo "Next steps:"
    echo "  cd $repo_path/worktrees/main"
    echo "  # Add your remote: git remote add origin <url>"
    echo "  # Create features: wt new <feature-name>"
    
    # Switch to the main worktree if requested
    if test "$switch_after" = "true"
        echo ""
        echo "Opening main worktree in tmux..."
        # Pass the repo path to wt_switch so it doesn't need to cd
        wt_switch main $repo_path
    end
end