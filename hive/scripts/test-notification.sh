#!/bin/bash
# Test hive notification system

echo "=== Hive Notification Test ==="
echo ""

echo "1. Checking plugin file..."
if [ -f ~/.config/opencode/plugin/hive-notify.ts ]; then
    echo "   ✓ Plugin file exists at ~/.config/opencode/plugin/hive-notify.ts"
else
    echo "   ✗ Plugin file NOT found"
    echo ""
    echo "Run: sudo .dotbot/install"
    echo "Or manually:"
    echo "   mkdir -p ~/.config/opencode/plugin"
    echo "   ln -s ~/.dotfiles/hive/plugin/hive-notify.ts ~/.config/opencode/plugin/hive-notify.ts"
    exit 1
fi

echo ""
echo "2. Checking notify.sh script..."
if [ -f ~/.dotfiles/hive/scripts/notify.sh ]; then
    echo "   ✓ notify.sh exists"
    chmod +x ~/.dotfiles/hive/scripts/notify.sh 2>/dev/null
else
    echo "   ✗ notify.sh NOT found"
    exit 1
fi

echo ""
echo "3. Testing notify.sh execution..."

# Test 1: Not in tmux
echo "   Test 3a: Not in tmux (should use notify-send)..."
if command -v notify-send >/dev/null 2>&1; then
    echo "      → notify-send is available"
else
    echo "      → notify-send NOT installed (notifications will fail)"
fi

# Test 2: In tmux (simulated)
echo ""
echo "   Test 3b: With TMUX set (will check tmux commands)..."
if command -v tmux >/dev/null 2>&1; then
    echo "      → tmux is available"

    # Check if we can list sessions
    SESSION_COUNT=$(tmux list-sessions 2>/dev/null | wc -l)
    echo "      → Found $SESSION_COUNT tmux session(s)"
else
    echo "      → tmux NOT available"
fi

echo ""
echo "4. Checking tmux hooks..."
if tmux show-options -g 2>/dev/null | grep -q "@hive"; then
    echo "   ℹ Some session has @hive marker"
fi

# List all hooks
HOOKS=$(tmux show-hooks -g 2>/dev/null | grep pane-focus-in || echo "none")
if [ "$HOOKS" = "none" ]; then
    echo "   ✗ pane-focus-in hook NOT set"
    echo ""
    echo "Expected in ~/.dotfiles/hive/tmux-hive.conf:"
    echo '  set-hook -g pane-focus-in '"'"'"'run-shell -b ~/.dotfiles/hive/scripts/clear-badge.sh'"'"'"''
else
    echo "   ✓ pane-focus-in hook is set"
fi

echo ""
echo "=== OpenCode Plugin Troubleshooting ==="
echo ""
echo "If notifications still aren't working:"
echo ""
echo "1. Restart OpenCode"
echo "   - The plugin is loaded on startup, so restart may be needed"
echo ""
echo "2. Check OpenCode logs"
echo "   - Run: opencode logs"
echo "   - Look for errors related to plugin loading"
echo ""
echo "3. Verify plugin is enabled"
echo "   - Check ~/.config/opencode/settings.json"
echo "   - Look for plugin configuration"
echo ""
echo "4. Manually test notify.sh"
echo "   - In a hive session, run:"
echo "     ~/.dotfiles/hive/scripts/notify.sh --type idle --message 'Test'"
echo "   - Should add [I] badge to current window"
