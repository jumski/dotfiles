#!/bin/bash

# if there is no /home/jumski/qmk_firmware directory, then clone it
if [ ! -f "/home/jumski/qmk_firmware/util/udev/50-qmk.rules" ]; then
  git clone https://github.com/qmk/qmk_firmware.git /home/jumski/qmk_firmware
fi

sudo cp /home/jumski/qmk_firmware/util/udev/50-qmk.rules /etc/udev/rules.d/
