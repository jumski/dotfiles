#!/bin/bash

sudo usermod -a -G uucp jumski

if ! test -f /home/jumski/.platformio/penv/bin/pio; then
  curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py -o get-platformio.py
  python3 get-platformio.py
fi
