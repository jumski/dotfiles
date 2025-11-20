#!/bin/bash

set -e

BASE_DIR="$HOME/Code/pgflow-dev/supatemp"

if [ ! -d "$BASE_DIR" ]; then
  echo "Creating Supabase temp projects directory..."
  mkdir -p "$BASE_DIR"
  echo "Created: $BASE_DIR"
else
  echo "Supabase temp projects directory already exists: $BASE_DIR"
fi
