#!/bin/bash
set -e

echo "Setting up Beads daemon systemd service..."

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
