#!/bin/bash

kwinscript_url="https://github.com/anametologin/krohnkite/releases/download/0.9.8.5/krohnkite-0.9.8.5.kwinscript"
download_path=/tmp/krohnkite.kwinscript

wget -O $download_path "$kwinscript_url"
# kpackagetool6 -t KWin/Script -i $download_path

kwriteconfig5 --file kwinrc --group Plugins --key krohnkiteEnabled true
qdbus org.kde.KWin /KWin reconfigure
