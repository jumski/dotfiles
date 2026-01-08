# Fish completions for Hive
# Source this file in your fish config to enable completions

# Disable file completions for most subcommands
complete -c hive -f

# Main commands
complete -c hive -n "__fish_use_subcommand" -a "spawn sp" -d "Interactive wizard to open worktree in hive"
complete -c hive -n "__fish_use_subcommand" -a "session ses" -d "Create new hive session from worktree"
complete -c hive -n "__fish_use_subcommand" -a "window win" -d "Add window to current/specified hive session"
complete -c hive -n "__fish_use_subcommand" -a "split" -d "Split current window with new worktree pane"
complete -c hive -n "__fish_use_subcommand" -a "list ls" -d "List hive sessions and their windows"
complete -c hive -n "__fish_use_subcommand" -a "help" -d "Show help"
complete -c hive -n "__fish_use_subcommand" -a "version" -d "Show version"

# Complete with directories for session, window, split commands
complete -c hive -n "__fish_seen_subcommand_from session ses window win split" -a "(__fish_complete_directories)" -d "Directory"

# Complete hive sessions for window command (second argument)
complete -c hive -n "__fish_seen_subcommand_from window win; and test (count (commandline -opc)) -eq 3" -a "(_hive_list_sessions)" -d "Hive session"
