#!/bin/bash

SUPERPOWERS_DIR="$HOME/.config/opencode/superpowers"

# Clone superpowers repo if it doesn't exist, otherwise pull latest
if [ ! -d "$SUPERPOWERS_DIR" ]; then
  git clone https://github.com/obra/superpowers "$SUPERPOWERS_DIR"
else
  cd "$SUPERPOWERS_DIR" && git pull
fi
