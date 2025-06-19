#!/bin/bash
if ! which cs; then
  curl -fsSL https://raw.githubusercontent.com/stmg-ai/claude-squad/main/install.sh | bash
fi
