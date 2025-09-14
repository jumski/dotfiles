#!/bin/bash
set -e

INSTALL_DIR="$HOME/.local/bin"
BINARY_NAME="todoist-cli"

# Check if already installed
if command -v "$BINARY_NAME" &> /dev/null; then
    echo "todoist-cli already installed"
    exit 0
fi

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download latest release for linux amd64
curl -sL "https://github.com/sachaos/todoist/releases/latest/download/todoist_linux_amd64" -o "$INSTALL_DIR/$BINARY_NAME"
chmod +x "$INSTALL_DIR/$BINARY_NAME"

echo "Installed todoist-cli to $INSTALL_DIR/$BINARY_NAME"
echo "Make sure $INSTALL_DIR is in your PATH"