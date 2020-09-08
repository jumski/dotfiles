#!/bin/bash

if ! which slack &>/dev/null; then
  yay -S slack-desktop
fi
