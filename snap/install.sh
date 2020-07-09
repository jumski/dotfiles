#!/bin/bash

sudo systemctl enable --now snapd.socket

if [ ! -d /snap ]; then
  sudo ln -s /var/lib/snapd/snap /snap
fi
