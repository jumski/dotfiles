#!/bin/bash

if ! which sqruff > /dev/null; then
  echo "Installing sqruff"
  curl -fsSL https://raw.githubusercontent.com/quarylabs/sqruff/main/install.sh | bash
fi
