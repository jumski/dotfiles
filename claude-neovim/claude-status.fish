function claude-status
    set -l claude_lock_dir "$HOME/.claude/ide"
    
    echo "🔍 Claude Code + Neovim Integration Status"
    echo "=========================================="
    
    # Check if lock directory exists
    if not test -d "$claude_lock_dir"
        echo "❌ No lock directory found at $claude_lock_dir"
        echo "   → Start Neovim and run :ClaudeCodeStart first"
        return 1
    end
    
    # List active lock files
    set -l lock_files (ls "$claude_lock_dir"/*.lock 2>/dev/null)
    
    if test (count $lock_files) -eq 0
        echo "❌ No active WebSocket connections"
        echo "   → Start Neovim and run :ClaudeCodeStart to create WebSocket server"
    else
        echo "✅ Active WebSocket connections:"
        for lock_file in $lock_files
            set -l port (basename "$lock_file" .lock)
            echo "   → Port: $port"
            
            # Check if port is actually listening
            if ss -tln 2>/dev/null | grep -q ":$port "
                echo "     Status: ✅ Listening"
            else
                echo "     Status: ❌ Not listening (stale lock file)"
            end
        end
    end
    
    echo ""
    echo "Environment variables:"
    if set -q CLAUDE_IDE_PORT
        echo "   CLAUDE_IDE_PORT: $CLAUDE_IDE_PORT"
    else
        echo "   CLAUDE_IDE_PORT: (not set)"
    end
    
    if set -q CLAUDE_IDE_HOST
        echo "   CLAUDE_IDE_HOST: $CLAUDE_IDE_HOST"
    else
        echo "   CLAUDE_IDE_HOST: (not set)"
    end
    
    echo ""
    echo "💡 Usage:"
    echo "   1. In Neovim: :ClaudeCodeStart"
    echo "   2. In tmux: claude-hybrid --continue"
    echo "   3. Select code in Neovim and use <leader>cs"
end