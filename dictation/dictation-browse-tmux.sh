#!/usr/bin/env bash
# Wrapper script for dictation-browse to work in tmux popup
# Outputs selected text to stdout for tmux to paste

# Source environment variables
if [ -f ~/.env.local ]; then
    set -a  # automatically export all variables
    source ~/.env.local
    set +a  # turn off automatic export
fi

# Debug: log to temp file
echo "Wrapper started at $(date)" >> /tmp/dictation-browse-debug.log

# Run dictation-browse through fish and capture output
result=$(/usr/bin/fish -c "source ~/.dotfiles/dictation/functions/dictation-browse.fish; dictation-browse" 2>&1)
exit_code=$?

echo "Exit code: $exit_code" >> /tmp/dictation-browse-debug.log
echo "Result length: ${#result}" >> /tmp/dictation-browse-debug.log
echo "Result: $result" >> /tmp/dictation-browse-debug.log

# Output result to stdout
echo -n "$result"
exit $exit_code
