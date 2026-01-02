function claude --description "Wrapper for claude command that disables focus-events in tmux"
    # Check if we're in tmux
    if test -n "$TMUX"
        # Capture session:window for auto-rename and notifications
        set -l target (tmux display-message -p '#S:#I')
        set -gx CLAUDE_TMUX_TARGET $target
        set -gx CLAUDE_TMUX_WINDOW_NAME (tmux display-message -p '#W')

        # Disable focus-events for this pane to prevent [O[I sequences
        tmux set-option -p focus-events off >/dev/null 2>&1

        # Schedule auto-rename after 3 minutes (background, detached)
        fish -c "sleep 180; ~/.dotfiles/tmux/scripts/ai-rename-window.sh '$target' >/dev/null 2>&1" &
        disown

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
