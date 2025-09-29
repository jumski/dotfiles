#!/bin/bash

if ! [ -f ~/.config/fish/functions/fisher.fish ]; then
  echo Installing fisher
  curl https://git.io/fisher --create-dirs -sLo ~/.config/fish/functions/fisher.fish
else
  echo Fisher installed, skipping
fi

# Install packages from fishfile
if [ -f ~/.config/fish/functions/fisher.fish ] && [ -f ~/.dotfiles/fish/fishfile ]; then
  echo "Installing fish packages from fishfile..."
  fish -c "fisher install < ~/.dotfiles/fish/fishfile"
else
  echo "Fisher or fishfile not found, skipping package installation"
fi

# set fish shell for user jumski
if [ $(getent passwd jumski | cut -d: -f7) != /usr/bin/fish ]; then
  chsh -s /usr/bin/fish jumski
else
  echo "User 'jumski' already has a 'fish' shell."
fi
