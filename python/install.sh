#!/bin/bash

if [ ! -d ~/.pyenv ]; then
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
fi

pyenv install --skip-existing 2.7.8
pyenv install --skip-existing 3.6.4
