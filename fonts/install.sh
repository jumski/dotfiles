#!/bin/bash

destination_path=/usr/share/fonts/truetype/ttf-monaco/Monaco_Linux.ttf

if [ ! -f $destination_path ]; then
  sudo mkdir -p $(dirname $destination_path)
  sudo cp fonts/Monaco_Linux.ttf $destination_path &&
    sudo fc-cache -fv
fi
