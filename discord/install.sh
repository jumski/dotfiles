#!/bin/bash

if [ ! -f ~/.config/discord/settings.json ]; then
  mkdir -p ~/.config/discord
  echo '{SKIP_HOST_UPDATE: true}' > ~/.config/discord/settings.json
else
  jq '. + {SKIP_HOST_UPDATE: true}' < ~/.config/discord/settings.json > ~/.config/discord/settings.json.new
  mv ~/.config/discord/settings.json.new ~/.config/discord/settings.json
fi
