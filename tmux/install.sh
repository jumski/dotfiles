#!/bin/bash

if [ ! -r ~/.tmux/plugins/tpm/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
