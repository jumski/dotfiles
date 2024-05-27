#!/bin/bash

if ! sudo systemctl is-active avahi-daemon.service 2>&1 >/dev/null; then
  echo "Avahi Daemon is not running. Starting it..."

  sudo systemctl start avahi-daemon.service
  sudo systemctl enable avahi-daemon.service
fi
