# Fish completions for Worktree Toolkit (wt)
# Source this file in your fish config to enable completions

# Disable file completions for most subcommands
complete -c wt -f

# Main commands
complete -c wt -n "__fish_use_subcommand" -a "init clone" -d "Initialize new worktree repository"
complete -c wt -n "__fish_use_subcommand" -a "new" -d "Create new worktree"
complete -c wt -n "__fish_use_subcommand" -a "list ls" -d "List all worktrees"
complete -c wt -n "__fish_use_subcommand" -a "remove rm" -d "Remove worktree"
complete -c wt -n "__fish_use_subcommand" -a "status st" -d "Show worktree status"
complete -c wt -n "__fish_use_subcommand" -a "switch sw" -d "Switch to worktree"
complete -c wt -n "__fish_use_subcommand" -a "up" -d "Navigate to upstack worktree"
complete -c wt -n "__fish_use_subcommand" -a "down" -d "Navigate to downstack worktree"
complete -c wt -n "__fish_use_subcommand" -a "bottom" -d "Navigate to stack bottom"
complete -c wt -n "__fish_use_subcommand" -a "sync" -d "Sync with remote"
complete -c wt -n "__fish_use_subcommand" -a "restack" -d "Rebase current stack"
complete -c wt -n "__fish_use_subcommand" -a "stack" -d "Stack operations"
complete -c wt -n "__fish_use_subcommand" -a "submit" -d "Submit stack to GitHub"
complete -c wt -n "__fish_use_subcommand" -a "env" -d "Environment file operations"
complete -c wt -n "__fish_use_subcommand" -a "help" -d "Show help"
complete -c wt -n "__fish_use_subcommand" -a "version" -d "Show version"

# Options for specific commands
complete -c wt -n "__fish_seen_subcommand_from new" -l from -d "Base branch for new worktree"
complete -c wt -n "__fish_seen_subcommand_from new" -l trunk -d "Trunk branch for Graphite"

complete -c wt -n "__fish_seen_subcommand_from status st" -l all -d "Show status of all worktrees"

complete -c wt -n "__fish_seen_subcommand_from sync" -l all -d "Sync all worktrees"
complete -c wt -n "__fish_seen_subcommand_from sync" -l force -d "Force sync (stash changes)"
complete -c wt -n "__fish_seen_subcommand_from sync" -l reset -d "Hard reset to remote"

# Stack subcommands
complete -c wt -n "__fish_seen_subcommand_from stack" -a "list" -d "List all stacks"
complete -c wt -n "__fish_seen_subcommand_from stack" -a "sync" -d "Sync entire stack"

# Env subcommands
complete -c wt -n "__fish_seen_subcommand_from env" -a "sync" -d "Sync environment files"
complete -c wt -n "__fish_seen_subcommand_from env sync" -l all -d "Sync to all worktrees"

# Dynamic worktree name completion
function __wt_worktrees
    # Try to find worktrees if in a wt repository
    set -l repo_root (pwd)
    while test "$repo_root" != "/"
        if test -f "$repo_root/.wt-config"
            # Found the repository root
            for dir in $repo_root/worktrees/*
                if test -d $dir
                    basename $dir
                end
            end
            return
        end
        set repo_root (dirname $repo_root)
    end
end

# Complete worktree names for relevant commands
complete -c wt -n "__fish_seen_subcommand_from switch sw remove rm" -a "(__wt_worktrees)" -d "Worktree"

# Complete branch names for --from option
complete -c wt -n "__fish_seen_subcommand_from new; and __fish_contains_opt from" -a "(git branch --format='%(refname:short)')" -d "Branch"