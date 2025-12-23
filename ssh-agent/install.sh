#!/bin/bash
set -e

echo "Setting up SSH agent systemd service..."

# Reload systemd to pick up the new service file
systemctl --user daemon-reload

# Enable and start the service
systemctl --user enable ssh-agent.service
systemctl --user start ssh-agent.service

echo "SSH agent service enabled and started"
echo "Socket location: $XDG_RUNTIME_DIR/ssh-agent.socket"
echo ""
echo "You may need to log out and back in for environment.d changes to take effect."
echo "Or run: export SSH_AUTH_SOCK=\"\$XDG_RUNTIME_DIR/ssh-agent.socket\""
