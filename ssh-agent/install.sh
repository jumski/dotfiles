#!/bin/bash
set -e

echo "Setting up SSH agent systemd service..."

# Reload systemd to pick up the new service file
systemctl --user daemon-reload

# Enable the service (socket activation will start it on first use)
systemctl --user enable ssh-agent.service

echo "SSH agent service enabled"
echo "Socket location: $XDG_RUNTIME_DIR/ssh-agent.socket"
echo ""
echo "You may need to log out and back in for environment.d changes to take effect."
