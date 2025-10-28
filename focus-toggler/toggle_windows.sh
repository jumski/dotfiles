#!/bin/bash

active=$(xdotool getactivewindow)
browser=$(xdotool search --name "Mozilla Firefox")
terminal=$(xdotool search --classname "Kitty")

echo active=$active
echo browser=$browser
echo terminal=$terminal

if [ "$active" == "$terminal" ]; then
  echo activating browser
  xdotool windowactivate $browser
else
  echo activating terminal
  xdotool windowactivate $terminal
fi
