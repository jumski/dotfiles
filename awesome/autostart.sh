#!/usr/bin/env bash

function run {
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

run firefox
run gnome-terminal
/home/jumski/.dotfiles/bin/setup_input_devices
