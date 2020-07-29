#!/bin/bash

if !which fish &>/dev/null; then
  chsh -s $(which fish)
fi

if which fisher &>/dev/null; then
  echo Updating fisher
  fisher self-update
else
  echo Installing fisher
  curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
fi

