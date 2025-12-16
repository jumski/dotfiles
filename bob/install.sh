#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up Bob (Neovim version manager)..."

# Verify bob is installed
if ! command -v bob &> /dev/null; then
    echo "ERROR: bob is not installed. This should have been installed by script/install_pacman_packages"
    exit 1
fi

# Create config directory
mkdir -p "$HOME/.config/bob"

# Copy config file if it doesn't exist or is different
if [ ! -f "$HOME/.config/bob/config.toml" ] || ! cmp -s "$SCRIPT_DIR/config.toml" "$HOME/.config/bob/config.toml"; then
    echo "Installing Bob configuration..."
    cp "$SCRIPT_DIR/config.toml" "$HOME/.config/bob/config.toml"
fi

# Install Neovim if no versions are installed yet
if ! bob list 2>/dev/null | grep -q "Used"; then
    echo "Installing latest Neovim via Bob..."
    bob install latest
    bob use latest
    echo "Neovim latest installed and activated"
else
    echo "Neovim already installed and active"
fi

echo "Bob setup complete!"
echo "Restart your shell or run: source ~/.config/fish/config.fish"
