#!/bin/bash
set -e

echo "Setting up Beads daemon systemd service..."

# Ensure user systemd directory exists
mkdir -p ~/.config/systemd/user

# Link the service file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ln -sf "$SCRIPT_DIR/beads-daemon.service" ~/.config/systemd/user/beads-daemon.service

# Reload systemd to pick up the new service file
systemctl --user daemon-reload

# Enable the service to start on boot
systemctl --user enable beads-daemon.service

# Start the service now
systemctl --user start beads-daemon.service

echo "Beads daemon service enabled and started"
echo "BEADS_DIR: /home/jumski/Code/pgflow-dev/beads/.beads"
echo ""
echo "Useful commands:"
echo "  systemctl --user status beads-daemon"
echo "  systemctl --user restart beads-daemon"
echo "  journalctl --user -u beads-daemon -f"
