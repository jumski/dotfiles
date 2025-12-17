#!/bin/bash

AUTOSTART_DIR="$HOME/.config/autostart"
DESKFLOW_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$AUTOSTART_DIR"

# Remove any existing deskflow autostart
rm -f "$AUTOSTART_DIR/deskflow-server.desktop"
rm -f "$AUTOSTART_DIR/deskflow-client.desktop"

case "$(hostname)" in
    pc)
        echo "Setting up Deskflow as SERVER"
        ln -sf "$DESKFLOW_DIR/deskflow-server.desktop" "$AUTOSTART_DIR/"
        ;;
    laptop|franek-pc)
        echo "Setting up Deskflow as CLIENT (connecting to pc)"
        ln -sf "$DESKFLOW_DIR/deskflow-client.desktop" "$AUTOSTART_DIR/"
        ;;
    *)
        echo "Unknown hostname '$(hostname)' - skipping Deskflow setup"
        ;;
esac
