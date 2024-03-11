#!/bin/bash

if !which fish &>/dev/null; then
  chsh -s $(which fish)
fi

if ! [ -f ~/.config/fish/functions/fisher.fish ]; then
  echo Installing fisher
  curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
else
  echo Fisher installed, skipping
fi

# set fish shell for user jumski
if [ $(getent passwd jumski | cut -d: -f7) != /usr/bin/fish ]; then
  chsh -s /usr/bin/fish jumski
else
  echo "User 'jumski' already has a 'fish' shell."
fi
