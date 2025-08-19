#!/bin/bash
#
# Install mise and set up basic configuration

set -e

echo "Installing mise..."

# Check if mise is already installed
if command -v mise >/dev/null 2>&1; then
    echo "mise is already installed"
    exit 0
fi

# Install mise using the official installer
if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to install mise"
    exit 1
fi

# Download and install mise
curl -sSL https://mise.run | sh

echo "mise installed successfully"

# Create basic configuration directory
mkdir -p ~/.config/mise

echo "mise installation complete"
echo "Please run 'mise activate fish | source' or add it to your shell config"