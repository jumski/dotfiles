#!/bin/bash

if !which fish &>/dev/null; then
  chsh -s $(which fish)
fi

