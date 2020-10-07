#!/bin/bash

echo '> Linking PrusaSlicer profiles...'
for profile_type in print printer filament; do
  source_dir=~/Dropbox/3d-printing/prusa-slicer-inis/${profile_type}
  destination_dir=~/.PrusaSlicer/${profile_type}

  if [ ! -d $source_dir ]; then
    echo "  --- Source $source_dir does not exists, aborting"
    exit 1
  fi

  echo "  - Linking $profile_type"
  if [ -d ~/.PrusaSlicer/${profile_type} ]; then
    echo "  --- Destination $destination_dir already exists, skipping"
  else
    ln -s $source_dir $destination_dir
    echo "  --- $destination_dir Linked!"
  fi
done
