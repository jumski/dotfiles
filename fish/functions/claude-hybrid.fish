function claude-hybrid
    set -l claude_lock_dir "$HOME/.claude/ide"
    
    # Find active WebSocket port
    if test -d "$claude_lock_dir"
        set -l latest_lock (ls -t "$claude_lock_dir"/*.lock 2>/dev/null | head -n1)
        if test -n "$latest_lock"
            set -l port (basename "$latest_lock" .lock)
            set -x CLAUDE_IDE_PORT "$port"
            set -x CLAUDE_IDE_HOST "localhost"
            echo "🔗 Connecting to Neovim WebSocket on port $port"
        else
            echo "ℹ️  No Neovim WebSocket found, running in standalone mode"
        end
    end
    
    # Run Claude Code with all arguments
    claude $argv
end