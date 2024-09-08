#!/bin/bash

# if there is pnpm installed
if [ -x "$(command -v pnpm)" ]; then
  pnpm install
fi
