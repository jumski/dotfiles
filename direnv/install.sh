#!/bin/bash

if asdf plugin list | grep -q 'direnv'; then
  echo "direnv plugin is already installed."
else
  asdf plugin add direnv
  asdf direnv setup --shell fish --version system
fi
