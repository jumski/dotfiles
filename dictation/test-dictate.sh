#!/usr/bin/env bash
# Test script for dictation with different key actions

echo "Testing dictation with key actions..."
echo "Press:"
echo "  Enter - to paste and execute (if in tmux)"
echo "  C - to copy to clipboard"
echo "  S - to search in Firefox"
echo "  Any other key - to just output/paste"
echo ""

# Run the wrapper script
~/.dotfiles/dictation/dictate-actions.sh