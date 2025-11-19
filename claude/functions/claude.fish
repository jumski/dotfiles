function claude --description "Wrapper for claude command that disables focus-events in tmux"
    # Check if we're in tmux
    if test -n "$TMUX"
        # Disable focus-events for this pane to prevent [O[I sequences
        tmux set-option -p focus-events off >/dev/null 2>&1

        # Run the actual claude command from local installation with bash shell
        env SHELL=/bin/bash ~/.claude/local/claude $argv
        set -l claude_exit_status $status

        # Always unset pane-specific option to inherit from session (focus-events on)
        # This ensures cleanup even if claude crashes/is killed
        tmux set-option -pu focus-events >/dev/null 2>&1

        return $claude_exit_status
    else
        # Not in tmux, just run claude normally from local installation with bash shell
        env SHELL=/bin/bash ~/.claude/local/claude $argv
    end
end
