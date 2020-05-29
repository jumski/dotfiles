#!/bin/bash

# install poetry
if ! which poetry 2>&1 >/dev/null; then
  curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python
fi
