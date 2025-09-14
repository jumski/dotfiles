#!/bin/bash
set -e

INSTALL_DIR="$HOME/.local/bin"
BINARY_NAME="todoist-cli"

# Check if already installed
if command -v "$BINARY_NAME" &> /dev/null; then
    echo "todoist-cli already installed"
else
    # Create install directory
    mkdir -p "$INSTALL_DIR"

    # Download latest release for linux amd64
    curl -sL "https://github.com/sachaos/todoist/releases/latest/download/todoist_linux_amd64" -o "$INSTALL_DIR/$BINARY_NAME"
    chmod +x "$INSTALL_DIR/$BINARY_NAME"

    echo "Installed todoist-cli to $INSTALL_DIR/$BINARY_NAME"
    echo "Make sure $INSTALL_DIR is in your PATH"
fi


echo ""
echo "Installing cron job..."
"$HOME/.dotfiles/cron/install.sh"

echo ""
echo "✓ Todoist helper setup complete!"
echo "  - Updates urgent tasks cache every minute"
echo "  - Shows red TODO in tmux/starship when you have p1/p2/p3 tasks"
echo ""
echo "Next steps:"
if [[ ! -f "$HOME/.dotfiles/todoist-helper/.env" ]]; then
    echo -e "\033[1;31m⚠ WARNING: Missing .env file!\033[0m"
    echo -e "\033[1;31m1. Create todoist-helper/.env with: TODOIST_API_KEY=your_token_here\033[0m"
    echo -e "\033[1;31m2. Get your token from: https://todoist.com/prefs/integrations\033[0m"
else
    echo "1. ✓ .env file found"
fi
echo "3. Test with: ./todoist-helper/bin/update-urgent-cache.sh"