function esphome --wraps='__fish_complete_path' --description 'alias esphome=docker run --rm --privileged --device=/dev/ttyUSB0 -v .:/config -it ghcr.io/esphome/esphome'
  docker run --rm --privileged --net=host --device=/dev/ttyUSB0 -v .:/config -it ghcr.io/esphome/esphome:stable $argv
end

