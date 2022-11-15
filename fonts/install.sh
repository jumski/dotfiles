#!/bin/bash

destination_path=/usr/share/fonts/truetype/ttf-monaco/

if [ ! -f $destination_path ]; then
  sudo mkdir -p $destination_path
  sudo cp fonts/*.{ttf,otf} $destination_path &&
    sudo fc-cache -fv
fi
