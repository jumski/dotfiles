#!/bin/bash

set -e

BASE_DIR="$HOME/Code/pgflow-dev/supatemp"

if [ ! -d "$BASE_DIR" ]; then
  echo "Cloning supatemp repository..."
  gh repo clone pgflow-dev/supatemp "$BASE_DIR"
  if [ $? -eq 0 ]; then
    echo "✓ Repository cloned successfully: $BASE_DIR"
  else
    echo "✗ Failed to clone repository"
    echo "You can clone it manually later with:"
    echo "  gh repo clone pgflow-dev/supatemp $BASE_DIR"
    exit 1
  fi
else
  echo "Supabase temp projects directory already exists: $BASE_DIR"

  # Check if it's a git repo
  if [ ! -d "$BASE_DIR/.git" ]; then
    echo "⚠ Warning: Directory exists but is not a git repository"
    echo "Please remove it and run install again, or clone manually:"
    echo "  rm -rf $BASE_DIR"
    echo "  gh repo clone pgflow-dev/supatemp $BASE_DIR"
  fi
fi
