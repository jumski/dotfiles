#!/bin/bash
if ! which fd 2>&1 >/dev/null; then
  wget -O /tmp/fd.deb https://github.com/sharkdp/fd/releases/download/v7.4.0/fd-musl_7.4.0_amd64.deb
  sudo dpkg -i /tmp/fd.deb
fi
