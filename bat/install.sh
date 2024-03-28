#!/bin/bash

set -e

if ! bat --list-themes | grep tokyonight 2>&1 >/dev/null; then
  echo Caching bat themes
  bat cache --build
fi
