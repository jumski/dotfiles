#!/bin/bash
if which atuin 2>&1 >/dev/null; then
  atuin gen-completions --shell fish > atuin/completions.fish
fi
