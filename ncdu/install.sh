#!/bin/bash

if ! test -f /usr/local/bin/ncdu; then
  sudo cp bin/ncdu /usr/local/bin/
fi
