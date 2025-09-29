# Fish completions for Worktree Toolkit (wt)
# Source this file in your fish config to enable completions

# Disable file completions for most subcommands
complete -c wt -f

# Main commands
complete -c wt -n "__fish_use_subcommand" -a "init" -d "Initialize new local repository"
complete -c wt -n "__fish_use_subcommand" -a "clone" -d "Clone and set up worktree structure"
complete -c wt -n "__fish_use_subcommand" -a "new" -d "Create new worktree"
complete -c wt -n "__fish_use_subcommand" -a "branch br" -d "Create new branch with worktree"
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
complete -c wt -n "__fish_use_subcommand" -a "git" -d "Run git in bare repository"
complete -c wt -n "__fish_use_subcommand" -a "tutor" -d "Interactive workflow tutorials"
complete -c wt -n "__fish_use_subcommand" -a "help" -d "Show help"
complete -c wt -n "__fish_use_subcommand" -a "version" -d "Show version"

# Options for specific commands
complete -c wt -n "__fish_seen_subcommand_from init" -l switch -d "Open in muxit after creation"
complete -c wt -n "__fish_seen_subcommand_from clone" -l switch -d "Open in muxit after clone"

complete -c wt -n "__fish_seen_subcommand_from new" -l from -d "Base branch for new worktree"
complete -c wt -n "__fish_seen_subcommand_from new" -l trunk -d "Trunk branch for Graphite"
complete -c wt -n "__fish_seen_subcommand_from new" -l force-new -d "Skip remote check, always create new"
complete -c wt -n "__fish_seen_subcommand_from new" -l switch -d "Open in muxit after creation"

complete -c wt -n "__fish_seen_subcommand_from branch br" -s m -l message -d "Commit message"
complete -c wt -n "__fish_seen_subcommand_from branch br" -l switch -d "Open in muxit after creation"
complete -c wt -n "__fish_seen_subcommand_from branch br" -s a -l all -d "Stage all unstaged changes"
complete -c wt -n "__fish_seen_subcommand_from branch br" -s u -l update -d "Stage all updates to tracked files"
complete -c wt -n "__fish_seen_subcommand_from branch br" -s p -l patch -d "Pick hunks to stage"

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

# Complete worktree names for relevant commands
complete -c wt -n "__fish_seen_subcommand_from switch sw remove rm" -a "(_wt_get_worktrees)" -d "Worktree"

# Tutor topics
complete -c wt -n "__fish_seen_subcommand_from tutor" -a "hotfix" -d "Creating urgent fixes on main branch"
complete -c wt -n "__fish_seen_subcommand_from tutor" -a "update" -d "Syncing all stacks after merging changes"
complete -c wt -n "__fish_seen_subcommand_from tutor" -a "branch" -d "Creating a new feature branch"
complete -c wt -n "__fish_seen_subcommand_from tutor" -a "stack" -d "Creating next branch in a stack"
complete -c wt -n "__fish_seen_subcommand_from tutor" -a "commit" -d "Committing with amend workflows"
complete -c wt -n "__fish_seen_subcommand_from tutor" -a "workflow" -d "Complete development workflow walkthrough"

# Complete branch names for --from option
complete -c wt -n "__fish_seen_subcommand_from new; and __fish_contains_opt from" -a "(git branch --format='%(refname:short)')" -d "Branch"