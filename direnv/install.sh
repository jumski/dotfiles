#!/bin/bash

if command -v asdf &> /dev/null
then
  asdf plugin add direnv
  asdf direnv setup --shell fish --version system
else
  echo "asdf is not installed. Please install it first."
fi
