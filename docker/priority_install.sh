#!/bin/bash

if ! which docker-compose 2>&1 >/dev/null; then
  sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo groupadd docker
  sudo usermod -aG docker jumski
fi
